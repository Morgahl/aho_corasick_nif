use aho_corasick::{BuildError, MatchError, MatchErrorKind};
use rustler::{Atom, Encoder, Env, Term};

use crate::atoms;

#[derive(Debug)]
pub enum Error {
    Atom(Atom),
    String(String),
}

impl From<String> for Error {
    fn from(string: String) -> Self {
        Error::String(string)
    }
}

impl From<Atom> for Error {
    fn from(atom: Atom) -> Self {
        Error::Atom(atom)
    }
}

impl From<BuildError> for Error {
    fn from(error: BuildError) -> Self {
        Error::String(error.to_string())
    }
}

impl From<MatchError> for Error {
    fn from(error: MatchError) -> Self {
        match error.kind() {
            MatchErrorKind::InvalidInputAnchored => Error::Atom(atoms::invalid_input_anchored()),
            MatchErrorKind::InvalidInputUnanchored => Error::Atom(atoms::invalid_input_unanchored()),
            MatchErrorKind::UnsupportedStream { .. } => Error::Atom(atoms::unsupported_stream()),
            MatchErrorKind::UnsupportedOverlapping { .. } => Error::Atom(atoms::unsupported_overlapping()),
            MatchErrorKind::UnsupportedEmpty => Error::Atom(atoms::unsupported_empty()),
            _ => Error::String(error.to_string()),
        }
    }
}

impl Encoder for Error {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            Error::Atom(atom) => atom.encode(env),
            Error::String(string) => string.encode(env),
        }
    }
}
