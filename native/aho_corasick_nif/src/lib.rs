mod wrapper;

use std::sync::RwLock;

use jemallocator::Jemalloc;
use rustler::resource::ResourceArc;
use rustler::{Atom, Env, Term};

use wrapper::{AhoCorasick, Error, Match};

#[global_allocator]
static GLOBAL_ALLOCATOR: Jemalloc = Jemalloc;

mod atoms {
    rustler::atoms! {
        ok,
        error,

        // error types
        unsupported_type,
        lock_fail,
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
fn new(patterns: Vec<String>) -> Result<AhoCorasickArc, Error> {
    let automata = AhoCorasick::new(patterns)?;
    let resource = AhoCorasickResource(RwLock::new(automata));
    Ok(ResourceArc::new(resource))
}

#[rustler::nif]
fn add_patterns(resource: AhoCorasickArc, patterns: Vec<String>) -> Result<Atom, Error> {
    resource
        .0
        .write()
        .map_err(|_| atoms::lock_fail())?
        .add_patterns(patterns)
        .and(Ok(atoms::ok()))
}

#[rustler::nif]
fn remove_patterns(resource: AhoCorasickArc, patterns: Vec<String>) -> Result<Atom, Error> {
    resource
        .0
        .write()
        .map_err(|_| atoms::lock_fail())?
        .remove_patterns(patterns)
        .and(Ok(atoms::ok()))
}

#[rustler::nif]
fn find_all(resource: AhoCorasickArc, haystack: String) -> Result<Vec<Match>, Error> {
    let resource = resource
        .0
        .read()
        .map_err(|_| atoms::lock_fail())?
        .find_all(haystack);
    Ok(resource)
}

#[rustler::nif]
fn find_all_overlapping(resource: AhoCorasickArc, haystack: String) -> Result<Vec<Match>, Error> {
    let resource = resource
        .0
        .read()
        .map_err(|_| atoms::lock_fail())?
        .find_all_overlapping(haystack);
    Ok(resource)
}
