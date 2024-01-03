use std::collections::HashSet;

use aho_corasick::{
    AhoCorasick as AhoCorasickImpl, AhoCorasickKind as AhoCorasickKindImpl,
    MatchKind as MatchKindImpl, StartKind as StartKindImpl,
};
use rustler::{NifStruct, NifUnitEnum};

use crate::error::Error;

#[derive(Debug)]
pub struct AhoCorasick {
    options: BuilderOptions,
    patterns: Vec<String>,
    automata: AhoCorasickImpl,
}

impl AhoCorasick {
    pub fn new(options: BuilderOptions, patterns: Vec<String>) -> Result<Self, Error> {
        let patterns = patterns
            .into_iter()
            .collect::<HashSet<String>>()
            .into_iter()
            .collect();
        let automata = new_automata(&options, &patterns)?;
        Ok(AhoCorasick {
            options,
            patterns,
            automata,
        })
    }

    pub fn add_patterns(&mut self, patterns: Vec<String>) -> Result<(), Error> {
        let mut new_patterns = self
            .patterns
            .clone()
            .into_iter()
            .collect::<HashSet<String>>();
        new_patterns.extend(patterns);

        if new_patterns.len() > self.patterns.len() {
            return self.update_automata(new_patterns.into_iter().collect());
        }

        Ok(())
    }

    pub fn remove_patterns(&mut self, patterns: Vec<String>) -> Result<(), Error> {
        let new_patterns: HashSet<String> = self
            .patterns
            .clone()
            .into_iter()
            .collect::<HashSet<String>>()
            .difference(&patterns.into_iter().collect::<HashSet<String>>())
            .cloned()
            .collect();

        if new_patterns.len() < self.patterns.len() {
            return self.update_automata(new_patterns.into_iter().collect());
        }

        Ok(())
    }

    pub fn find_all(&self, haystack: String) -> Result<Vec<Match>, Error> {
        let matches = self
            .automata
            .try_find_iter(&haystack)?
            .map(|m| Match {
                pattern: self.patterns[m.pattern()].to_string(),
                match_: haystack[m.range()].to_string(),
                start: m.start(),
                end: m.end(),
            })
            .collect();
        Ok(matches)
    }

    pub fn find_all_overlapping(&self, haystack: String) -> Result<Vec<Match>, Error> {
        let matches = self
            .automata
            .try_find_overlapping_iter(&haystack)?
            .map(|m| Match {
                pattern: self.patterns[m.pattern()].to_string(),
                match_: haystack[m.range()].to_string(),
                start: m.start(),
                end: m.end(),
            })
            .collect();
        Ok(matches)
    }

    #[inline]
    fn update_automata(&mut self, patterns: Vec<String>) -> Result<(), Error> {
        self.automata = new_automata(&self.options, &patterns)?;
        self.patterns = patterns;
        Ok(())
    }
}

fn new_automata(
    options: &BuilderOptions,
    patterns: &Vec<String>,
) -> Result<AhoCorasickImpl, Error> {
    match options.dense_depth {
        Some(_) => new_automata_with_dense_depth(options, patterns),
        None => new_automata_without_dense_depth(options, patterns),
    }
}

#[inline]
fn new_automata_with_dense_depth(
    options: &BuilderOptions,
    patterns: &Vec<String>,
) -> Result<AhoCorasickImpl, Error> {
    AhoCorasickImpl::builder()
        .ascii_case_insensitive(options.ascii_case_insensitive)
        .byte_classes(options.byte_classes)
        .dense_depth(options.dense_depth.unwrap())
        .kind(options.aho_corasick_kind.map(Into::into))
        .match_kind(options.match_kind.into())
        .prefilter(options.prefilter)
        .start_kind(options.start_kind.into())
        .build(patterns)
        .map_err(Error::from)
}

#[inline]
fn new_automata_without_dense_depth(
    options: &BuilderOptions,
    patterns: &Vec<String>,
) -> Result<AhoCorasickImpl, Error> {
    AhoCorasickImpl::builder()
        .ascii_case_insensitive(options.ascii_case_insensitive)
        .byte_classes(options.byte_classes)
        .kind(options.aho_corasick_kind.map(Into::into))
        .match_kind(options.match_kind.into())
        .prefilter(options.prefilter)
        .start_kind(options.start_kind.into())
        .build(patterns)
        .map_err(Error::from)
}

#[derive(Debug, NifStruct)]
#[module = "AhoCorasickNif.Native.Match"]
pub struct Match {
    pub pattern: String,
    pub match_: String,
    pub start: usize,
    pub end: usize,
}

#[derive(Debug, NifStruct)]
#[module = "AhoCorasickNif.Native.BuilderOptions"]
pub struct BuilderOptions {
    pub ascii_case_insensitive: bool,
    pub byte_classes: bool,
    pub dense_depth: Option<usize>,
    pub aho_corasick_kind: Option<AhoCorasickKind>,
    pub match_kind: MatchKind,
    pub prefilter: bool,
    pub start_kind: StartKind,
}

#[derive(Debug, Clone, Copy, NifUnitEnum)]
pub enum AhoCorasickKind {
    NoncontiguousNFA,
    ContiguousNFA,
    DFA,
}

impl From<AhoCorasickKind> for AhoCorasickKindImpl {
    fn from(kind: AhoCorasickKind) -> Self {
        match kind {
            AhoCorasickKind::NoncontiguousNFA => AhoCorasickKindImpl::NoncontiguousNFA,
            AhoCorasickKind::ContiguousNFA => AhoCorasickKindImpl::ContiguousNFA,
            AhoCorasickKind::DFA => AhoCorasickKindImpl::DFA,
        }
    }
}

#[derive(Debug, Clone, Copy, NifUnitEnum)]
pub enum MatchKind {
    Standard,
    LeftmostFirst,
    LeftmostLongest,
}

impl From<MatchKind> for MatchKindImpl {
    fn from(kind: MatchKind) -> Self {
        match kind {
            MatchKind::Standard => MatchKindImpl::Standard,
            MatchKind::LeftmostFirst => MatchKindImpl::LeftmostFirst,
            MatchKind::LeftmostLongest => MatchKindImpl::LeftmostLongest,
        }
    }
}

#[derive(Debug, Clone, Copy, NifUnitEnum)]
pub enum StartKind {
    Both,
    Anchored,
    Unanchored,
}

impl From<StartKind> for StartKindImpl {
    fn from(kind: StartKind) -> Self {
        match kind {
            StartKind::Both => StartKindImpl::Both,
            StartKind::Anchored => StartKindImpl::Anchored,
            StartKind::Unanchored => StartKindImpl::Unanchored,
        }
    }
}
