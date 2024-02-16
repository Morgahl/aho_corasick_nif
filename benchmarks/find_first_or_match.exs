# require AhoCorasickNif.Benchmark.Util
:rand.seed(:exsss, {1, 2, 3})

alias AhoCorasickNif.Benchmark.Util
alias AhoCorasickNif.Native.BuilderOptions

counts = [10, 100, 1000, 10000]
haystack_sizes = [64, 256, 1024, 4096, 16384, 65536, 262_144, 1_048_576]
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
  |> Enum.flat_map(fn needles ->
    Enum.map(haystack_sizes, fn size ->
      {"#{length(needles)}-#{size}", {needles, String.slice(haystack, 0..(size - 1))}}
    end)
  end)

IO.puts("Running find_first benchmarks")

[
  {"AhoCorasickNif.find_first/2", fn {automata, haystack} -> AhoCorasickNif.find_first(automata, haystack) end},
  # {"AhoCorasickNif.find_first!/2", fn {automata, haystack} -> AhoCorasickNif.find_first!(automata, haystack) end},
  {"AhoCorasickNif.is_match/2", fn {automata, haystack} -> AhoCorasickNif.is_match(automata, haystack) end}
  # {"AhoCorasickNif.is_match!/2", fn {automata, haystack} -> AhoCorasickNif.is_match!(automata, haystack) end}
]
|> Map.new()
|> Benchee.run(
  inputs: inputs,
  before_each: fn {needles, haystack} -> {AhoCorasickNif.new!(options, needles), haystack} end
)
