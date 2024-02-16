## TODO

1. Benchmark against native Elixir impls
2. Benchmark against native Rust impls (to determine overhead of NIF)
3. StoredEnv? to allow use of lifetimes for even more optimal `&str`  handling instead of `String`
4. Fuzzy searching?
    - Implement prefix, infix, suffix strategies with max offsets between sections
        - `a*p*l` becomes `a`, `p`, `l` and we later scan and stitch the matches together after the match iter completes while still following overlapping rules
    - OR impl ripgrep+fzf wrapper? implementing just the string searching strategies but not the regex?