mod supported_term;

use std::collections::HashSet;
use std::sync::RwLock;

use aho_corasick::{AhoCorasick as AhoCor, MatchKind, StartKind};
use rustler::resource::ResourceArc;
use rustler::types::tuple::get_tuple;
use rustler::{Atom, Env, Error, Term};

use crate::supported_term::SupportedTerm;

mod atoms {
    rustler::atoms! {
        ok,
        error,
    }
}

#[derive(Debug)]
pub struct AhoCorasick {
    patterns: HashSet<String>,
    automata: AhoCor,
}

impl AhoCorasick {
    pub fn new<I: Iterator<Item = String>>(patterns: I) -> Result<Self, Error> {
        let patterns: HashSet<String> = patterns.collect();
        let automata = new_automata(patterns.clone().into_iter())?;
        Ok(AhoCorasick { patterns, automata })
    }

    pub fn add_patterns<I: Iterator<Item = String>>(&mut self, patterns: I) -> Result<Atom, Error> {
        let mut new_patterns = self.patterns.clone();
        new_patterns.extend(patterns);

        if new_patterns.len() > self.patterns.len() {
            self.patterns = new_patterns;
            self.automata = new_automata(self.patterns.clone().into_iter())?;
        };
        Ok(atoms::ok())
    }

    pub fn remove_patterns<I: Iterator<Item = String>>(
        &mut self,
        patterns: I,
    ) -> Result<Atom, Error> {
        let new_patterns: HashSet<String> = self
            .patterns
            .clone()
            .difference(&patterns.collect())
            .cloned()
            .collect();

        if new_patterns.len() < self.patterns.len() {
            self.patterns = new_patterns;
            self.automata = new_automata(self.patterns.clone().into_iter())?;
        };
        Ok(atoms::ok())
    }

    pub fn find_all(&self, haystack: String) -> Vec<(String, usize, usize)> {
        self.automata
            .find_iter(&haystack)
            .map(|m| (haystack[m.range()].to_string(), m.start(), m.end()))
            .collect()
    }

    pub fn find_all_overlapping(&self, haystack: String) -> Vec<(String, usize, usize)> {
        self.automata
            .find_overlapping_iter(&haystack)
            .map(|m| (haystack[m.range()].to_string(), m.start(), m.end()))
            .collect()
    }
}

fn new_automata<I: Iterator<Item = String>>(patterns: I) -> Result<AhoCor, Error> {
    let automata = AhoCor::builder()
        .ascii_case_insensitive(true)
        .start_kind(StartKind::Unanchored)
        .match_kind(MatchKind::Standard)
        .build(patterns);

    match automata {
        Ok(automata) => Ok(automata),
        Err(e) => Err(Error::Term(Box::new(e.to_string()))),
    }
}

pub struct AhoCorasickResource(RwLock<AhoCorasick>);

type AhoCorasickArc = ResourceArc<AhoCorasickResource>;

rustler::init!(
    "Elixir.AhoCorasick.NifBridge",
    [
        add_patterns,
        find_all,
        find_all_overlapping,
        new,
        remove_patterns,
    ],
    load = load
);

fn load(env: Env, _info: Term) -> bool {
    rustler::resource!(AhoCorasickResource, env);
    true
}

#[rustler::nif]
fn new(term: Term) -> Result<AhoCorasickArc, Error> {
    let patterns = get_list_of_strings(term)?;

    match AhoCorasick::new(patterns) {
        Ok(automata) => {
            let resource = AhoCorasickResource(RwLock::new(automata));
            Ok(ResourceArc::new(resource))
        }
        Err(e) => Err(e),
    }
}

#[rustler::nif]
fn add_patterns(resource: AhoCorasickArc, term: Term) -> Result<Atom, Error> {
    let patterns = get_list_of_strings(term)?;
    let mut automata = match resource.0.write() {
        Err(_) => return Err(Error::Atom("lock_fail")),
        Ok(automata) => automata,
    };

    automata.add_patterns(patterns)
}

#[rustler::nif]
fn remove_patterns(resource: AhoCorasickArc, term: Term) -> Result<Atom, Error> {
    let patterns = get_list_of_strings(term)?;
    let mut automata = match resource.0.write() {
        Err(_) => return Err(Error::Atom("lock_fail")),
        Ok(automata) => automata,
    };

    automata.remove_patterns(patterns)
}

#[rustler::nif]
fn find_all(resource: AhoCorasickArc, term: Term) -> Result<Vec<(String, usize, usize)>, Error> {
    let haystack = get_string(term)?;
    match resource.0.read() {
        Err(_) => return Err(Error::Atom("lock_fail")),
        Ok(automata) => Ok(automata.find_all(haystack)),
    }
}

#[rustler::nif]
fn find_all_overlapping(
    resource: AhoCorasickArc,
    term: Term,
) -> Result<Vec<(String, usize, usize)>, Error> {
    let haystack = get_string(term)?;
    match resource.0.read() {
        Err(_) => return Err(Error::Atom("lock_fail")),
        Ok(automata) => Ok(automata.find_all_overlapping(haystack)),
    }
}

fn get_list_of_strings(term: Term) -> Result<impl Iterator<Item = String>, Error> {
    let patterns = match convert_to_supported_term(&term) {
        Some(SupportedTerm::List(patterns)) => patterns,
        _ => return Err(Error::Atom("unsupported_type")),
    };

    let patterns = patterns.into_iter().filter_map(|i| match i {
        SupportedTerm::Atom(a) => Some(a),
        SupportedTerm::Bitstring(b) => Some(b),
        _ => None,
    });
    Ok(patterns)
}

fn get_string(term: Term) -> Result<String, Error> {
    match convert_to_supported_term(&term) {
        Some(SupportedTerm::Bitstring(haystack)) => Ok(haystack),
        _ => return Err(Error::Atom("unsupported_type")),
    }
}

fn convert_to_supported_term(term: &Term) -> Option<SupportedTerm> {
    if term.is_number() {
        match term.decode() {
            Ok(i) => Some(SupportedTerm::Integer(i)),
            Err(_) => None,
        }
    } else if term.is_atom() {
        match term.atom_to_string() {
            Ok(a) => Some(SupportedTerm::Atom(a)),
            Err(_) => None,
        }
    } else if term.is_tuple() {
        match get_tuple(*term) {
            Ok(t) => {
                let initial_length = t.len();
                let inner_terms: Vec<SupportedTerm> = t
                    .into_iter()
                    .filter_map(|i: Term| convert_to_supported_term(&i))
                    .collect();
                if initial_length == inner_terms.len() {
                    Some(SupportedTerm::Tuple(inner_terms))
                } else {
                    None
                }
            }
            Err(_) => None,
        }
    } else if term.is_list() {
        match term.decode::<Vec<Term>>() {
            Ok(l) => {
                let initial_length = l.len();
                let inner_terms: Vec<SupportedTerm> = l
                    .into_iter()
                    .filter_map(|i: Term| convert_to_supported_term(&i))
                    .collect();
                if initial_length == inner_terms.len() {
                    Some(SupportedTerm::List(inner_terms))
                } else {
                    None
                }
            }
            Err(_) => None,
        }
    } else if term.is_binary() {
        match term.decode() {
            Ok(b) => Some(SupportedTerm::Bitstring(b)),
            Err(_) => None,
        }
    } else {
        None
    }
}
