mod error;
mod wrapper;

use std::sync::RwLock;

use jemallocator::Jemalloc;
use rustler::resource::ResourceArc;
use rustler::{Atom, Env, Term};

use error::Error;
use wrapper::{AhoCorasick, Match};

use crate::wrapper::BuilderOptions;

#[global_allocator]
static GLOBAL_ALLOCATOR: Jemalloc = Jemalloc;

mod atoms {
    rustler::atoms! {
        ok,
        error,

        // error types
        lock_fail,

        // match error kinds
        invalid_input_anchored,
        invalid_input_unanchored,
        unsupported_stream,
        unsupported_overlapping,
        unsupported_empty,
    }
}

pub struct AhoCorasickResource(RwLock<AhoCorasick>);

type AhoCorasickArc = ResourceArc<AhoCorasickResource>;

rustler::init!(
    "Elixir.AhoCorasickNif.NifBridge",
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
fn new(options: BuilderOptions, patterns: Vec<String>) -> Result<AhoCorasickArc, Error> {
    let automata = AhoCorasick::new(options, patterns)?;
    let resource = AhoCorasickResource(RwLock::new(automata));
    Ok(ResourceArc::new(resource))
}

#[rustler::nif]
fn add_patterns(resource: AhoCorasickArc, patterns: Vec<String>) -> Result<Atom, Error> {
    resource
        .0
        .write()
        .or(Err(atoms::lock_fail()))?
        .add_patterns(patterns)
        .and(Ok(atoms::ok()))
}

#[rustler::nif]
fn remove_patterns(resource: AhoCorasickArc, patterns: Vec<String>) -> Result<Atom, Error> {
    resource
        .0
        .write()
        .or(Err(atoms::lock_fail()))?
        .remove_patterns(patterns)
        .and(Ok(atoms::ok()))
}

#[rustler::nif]
fn find_all(resource: AhoCorasickArc, haystack: String) -> Result<Vec<Match>, Error> {
    resource
        .0
        .read()
        .or(Err(atoms::lock_fail()))?
        .find_all(haystack)
}

#[rustler::nif]
fn find_all_overlapping(resource: AhoCorasickArc, haystack: String) -> Result<Vec<Match>, Error> {
    resource
        .0
        .read()
        .or(Err(atoms::lock_fail()))?
        .find_all_overlapping(haystack)
}
