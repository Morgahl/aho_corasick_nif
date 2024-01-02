use aho_corasick::BuildError;
use rustler::{Atom, Encoder, Env, Term};

#[derive(Debug)]
pub enum Error {
    Atom(Atom),
    String(String),
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

impl From<String> for Error {
    fn from(string: String) -> Self {
        Error::String(string)
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

#[derive(Debug)]
pub struct Match(pub String, pub String, pub usize, pub usize);

impl Encoder for Match {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            Match(pattern, match_, start, end) => (pattern, match_, start, end).encode(env),
        }
    }
}
