use aho_corasick::{
    AhoCorasick as AhoCorasickImpl, AhoCorasickKind as AhoCorasickKindImpl, MatchKind as MatchKindImpl,
    StartKind as StartKindImpl,
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
    #[inline]
    pub fn new(options: BuilderOptions, patterns: Vec<String>) -> Result<Self, Error> {
        let automata = options.build(&patterns)?;
        Ok(AhoCorasick {
            options,
            patterns,
            automata,
        })
    }

    #[inline]
    pub fn add_patterns(&mut self, patterns: Vec<String>) -> Result<(), Error> {
        self.patterns.extend(patterns.into_iter());
        self.rebuild_automata()
    }

    #[inline]
    pub fn remove_patterns(&mut self, patterns: Vec<String>) -> Result<(), Error> {
        self.patterns.retain(|p| !patterns.contains(p));
        self.rebuild_automata()
    }

    #[inline]
    pub fn find_first(&self, haystack: &str) -> Result<Option<Match>, Error> {
        let match_ = self.automata.try_find(&haystack)?.map(|m| Match {
            pattern: self.patterns[m.pattern()].to_string(),
            match_: haystack[m.range()].to_string(),
            start: m.start(),
            end: m.end(),
        });
        Ok(match_)
    }

    #[inline]
    pub fn find_all(&self, haystack: &str) -> Result<Vec<Match>, Error> {
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

    #[inline]
    pub fn find_all_overlapping(&self, haystack: &str) -> Result<Vec<Match>, Error> {
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
    pub fn is_match(&self, haystack: &str) -> bool {
        self.automata.is_match(&haystack)
    }

    #[inline]
    pub fn replace_all(&self, haystack: &str, replace_with: &Vec<String>) -> Result<String, Error> {
        let replaced = self.automata.try_replace_all(&haystack, replace_with)?;
        Ok(replaced)
    }

    #[inline]
    fn rebuild_automata(&mut self) -> Result<(), Error> {
        self.automata = self.options.build(&self.patterns)?;
        Ok(())
    }
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

impl BuilderOptions {
    #[inline]
    fn build(&self, patterns: &Vec<String>) -> Result<AhoCorasickImpl, Error> {
        match self.dense_depth {
            Some(dense_depth) => self.new_automata_with_dense_depth(patterns, dense_depth),
            None => self.new_automata_without_dense_depth(patterns),
        }
    }

    #[inline]
    fn new_automata_with_dense_depth(
        &self,
        patterns: &Vec<String>,
        dense_depth: usize,
    ) -> Result<AhoCorasickImpl, Error> {
        let builder = AhoCorasickImpl::builder()
            .ascii_case_insensitive(self.ascii_case_insensitive)
            .byte_classes(self.byte_classes)
            .dense_depth(dense_depth)
            .kind(self.aho_corasick_kind.map(AhoCorasickKindImpl::from))
            .match_kind(MatchKindImpl::from(self.match_kind))
            .prefilter(self.prefilter)
            .start_kind(StartKindImpl::from(self.start_kind))
            .build(patterns)?;
        Ok(builder)
    }

    #[inline]
    fn new_automata_without_dense_depth(&self, patterns: &Vec<String>) -> Result<AhoCorasickImpl, Error> {
        let builder = AhoCorasickImpl::builder()
            .ascii_case_insensitive(self.ascii_case_insensitive)
            .byte_classes(self.byte_classes)
            .kind(self.aho_corasick_kind.map(AhoCorasickKindImpl::from))
            .match_kind(MatchKindImpl::from(self.match_kind))
            .prefilter(self.prefilter)
            .start_kind(StartKindImpl::from(self.start_kind))
            .build(patterns)?;
        Ok(builder)
    }
}

#[derive(Debug, Clone, Copy, NifUnitEnum)]
pub enum AhoCorasickKind {
    NoncontiguousNFA,
    ContiguousNFA,
    DFA,
}

impl From<AhoCorasickKind> for AhoCorasickKindImpl {
    #[inline]
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
    #[inline]
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
    #[inline]
    fn from(kind: StartKind) -> Self {
        match kind {
            StartKind::Both => StartKindImpl::Both,
            StartKind::Anchored => StartKindImpl::Anchored,
            StartKind::Unanchored => StartKindImpl::Unanchored,
        }
    }
}
