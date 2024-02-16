# require AhoCorasickNif.Benchmark.Util
:rand.seed(:exsss, {1, 2, 3})

alias AhoCorasickNif.Benchmark.Util
alias AhoCorasickNif.Native.BuilderOptions

counts = [10, 100, 1000, 10000]
options = %BuilderOptions{}

sourcefile = "priv/benchmarks/all_seasons.csv"
IO.puts("Loading data from #{sourcefile}")
data = Util.load_csv(sourcefile)
IO.puts("Building haystack")
haystack = Util.generate_haystacks(data)

IO.puts("Generating needle sets")

needles_sets =
  Util.generate_unique_strings(haystack, Enum.max(counts))

needles_sets =
  counts
  |> Enum.map(&Enum.take(needles_sets, &1))

IO.puts("Generating inputs")

inputs =
  needles_sets
  |> Enum.map(fn needles -> {"#{length(needles)}", {options, needles}} end)

IO.puts("Running benchmarks")

[
  {"AhoCorasickNif.new/2", fn {options, needles} -> AhoCorasickNif.new(options, needles) end},
  # {"AhoCorasickNif.new!/2", fn {options, needles} -> AhoCorasickNif.new!(options, needles) end},
  {"AhoCorasick.new/1", fn {_, needles} -> AhoCorasick.new(needles) end},
  {"AhoCorasearch.build_tree/2",
   {fn needles -> AhoCorasearch.build_tree(needles, insensitive: false) end,
    before_each: fn {_, needles} -> Util.build_corasearch_needles(needles) end}}
]
|> Map.new()
|> Benchee.run(inputs: inputs)
