## TODO

0. Struct, Tuple, or List for matches?
    - these are exact matches
1. Implement prefix, infix, suffix strategies with max offsets between sections
    - `a*p*l` becomes `a`, `p`, `l` and we later scan and stitch the matches together after the match iter completes while still following overlapping rules
2. OR impl ripgrep+fzf wrapper? implementing just the string searchign strategies but not the regex?
3. StoredEnv? to allow use of lifetimes for even more optimal `&str`  handling instead of `String`
4. Look into a Terms List Iterator impl
5. Look into a Terms List Collector impl
6. Benchmark Iterator/Collector impls vs Vec<String> passing
7. Benchmark against Native Elixir impls
8. Benchmark against native rust impls (to determine overhead of NIF)