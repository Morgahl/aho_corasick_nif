mod error;
mod wrapper;

use std::sync::Mutex;

use jemallocator::Jemalloc;
use rustler::resource::ResourceArc;
use rustler::{Atom, Env, Term};

use error::Error;
use wrapper::{AhoCorasick, BuilderOptions, Match};

#[global_allocator]
static GLOBAL_ALLOCATOR: Jemalloc = Jemalloc;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        nil,

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

pub struct AhoCorasickResource(Mutex<AhoCorasick>);

type AhoCorasickArc = ResourceArc<AhoCorasickResource>;

rustler::init!(
    "Elixir.AhoCorasickNif.NifBridge",
    [
        new,
        add_patterns,
        remove_patterns,
        find_first,
        find_all,
        find_all_overlapping,
        is_match,
        replace_all,
    ],
    load = load
);

fn load(env: Env, _info: Term) -> bool {
    rustler::resource!(AhoCorasickResource, env);
    true
}

#[rustler::nif]
#[inline]
fn new(options: BuilderOptions, patterns: Vec<String>) -> Result<AhoCorasickArc, Error> {
    let automata = AhoCorasick::new(options, patterns)?;
    let resource = AhoCorasickResource(Mutex::new(automata));
    Ok(ResourceArc::new(resource))
}

#[rustler::nif]
#[inline]
fn add_patterns(resource: AhoCorasickArc, patterns: Vec<String>) -> Result<Atom, Error> {
    let mut automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    automata.add_patterns(patterns).and(Ok(atoms::ok()))
}

#[rustler::nif]
#[inline]
fn remove_patterns(resource: AhoCorasickArc, patterns: Vec<String>) -> Result<Atom, Error> {
    let mut automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    automata.remove_patterns(patterns).and(Ok(atoms::ok()))
}

#[rustler::nif]
#[inline]
fn find_first(resource: AhoCorasickArc, haystack: &str) -> Result<Option<Match>, Error> {
    let automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    automata.find_first(haystack)
}

#[rustler::nif]
#[inline]
fn find_all(resource: AhoCorasickArc, haystack: &str) -> Result<Vec<Match>, Error> {
    let automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    automata.find_all(haystack)
}

#[rustler::nif]
#[inline]
fn find_all_overlapping(resource: AhoCorasickArc, haystack: &str) -> Result<Vec<Match>, Error> {
    let automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    automata.find_all_overlapping(haystack)
}

#[rustler::nif]
#[inline]
fn is_match(resource: AhoCorasickArc, haystack: &str) -> Result<bool, Error> {
    let automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    Ok(automata.is_match(haystack))
}

#[rustler::nif]
#[inline]
fn replace_all(resource: AhoCorasickArc, haystack: &str, replace_with: Vec<String>) -> Result<String, Error> {
    let automata = resource.0.lock().or(Err(atoms::lock_fail()))?;
    Ok(automata.replace_all(haystack, &replace_with)?)
}
