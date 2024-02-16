# require AhoCorasickNif.Benchmark.Util
:rand.seed(:exsss, {1, 2, 3})

alias AhoCorasickNif.Benchmark.Util
alias AhoCorasickNif.Native.BuilderOptions

counts = [10, 100, 1000, 10000]
options = %BuilderOptions{}

sourcefile = "priv/benchmarks/all_seasons.csv"
IO.puts("Loading data from #{sourcefile}")
data = Util.load_csv(sourcefile)
IO.puts("Building all_seasons haystack")
haystack = Util.generate_haystacks(data)

IO.puts("Generating all_seasons needles sets")

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
  {"new/2 all_seasons", fn {options, needles} -> AhoCorasickNif.new(options, needles) end},
  {"new!/2 all_seasons", fn {options, needles} -> AhoCorasickNif.new!(options, needles) end}
]
|> Map.new()
|> Benchee.run(inputs: inputs)
