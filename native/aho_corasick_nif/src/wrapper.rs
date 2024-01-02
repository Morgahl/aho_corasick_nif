use std::collections::HashSet;

use aho_corasick::{AhoCorasick as AhoCorasickImpl, MatchKind, StartKind};

use crate::types::{Error, Match};

#[derive(Debug)]
pub struct AhoCorasick {
    patterns: Vec<String>,
    automata: AhoCorasickImpl,
}

impl AhoCorasick {
    pub fn new(patterns: Vec<String>) -> Result<Self, Error> {
        let patterns = patterns
            .into_iter()
            .collect::<HashSet<String>>()
            .into_iter()
            .collect();
        let automata = new_automata(&patterns)?;
        Ok(AhoCorasick { patterns, automata })
    }

    pub fn add_patterns(&mut self, patterns: Vec<String>) -> Result<(), Error> {
        let mut new_patterns = self
            .patterns
            .clone()
            .into_iter()
            .collect::<HashSet<String>>();
        new_patterns.extend(patterns);

        if new_patterns.len() > self.patterns.len() {
            let new_patterns = new_patterns.into_iter().collect();
            self.automata = new_automata(&new_patterns)?;
            self.patterns = new_patterns;
        };
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
            let new_patterns = new_patterns.into_iter().collect();
            self.automata = new_automata(&new_patterns)?;
            self.patterns = new_patterns;
        };
        Ok(())
    }

    pub fn find_all(&self, haystack: String) -> Vec<Match> {
        self.automata
            .find_iter(&haystack)
            .map(|m| {
                Match(
                    self.patterns[m.pattern()].to_string(),
                    haystack[m.range()].to_string(),
                    m.start(),
                    m.end(),
                )
            })
            .collect()
    }

    pub fn find_all_overlapping(&self, haystack: String) -> Vec<Match> {
        self.automata
            .find_overlapping_iter(&haystack)
            .map(|m| {
                Match(
                    self.patterns[m.pattern()].to_string(),
                    haystack[m.range()].to_string(),
                    m.start(),
                    m.end(),
                )
            })
            .collect()
    }
}

#[inline]
fn new_automata(patterns: &Vec<String>) -> Result<AhoCorasickImpl, Error> {
    AhoCorasickImpl::builder()
        .ascii_case_insensitive(true)
        .start_kind(StartKind::Unanchored)
        .match_kind(MatchKind::Standard)
        .build(patterns)
        .map_err(|e| Error::from(e))
}
