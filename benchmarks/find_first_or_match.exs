# require AhoCorasickNif.Benchmark.Util
:rand.seed(:exsss, {1, 2, 3})

alias AhoCorasickNif.Benchmark.Util
alias AhoCorasickNif.Native.BuilderOptions

counts = [10, 100, 1000, 10000]
haystack_sizes = [128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536]
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
  |> Enum.flat_map(fn needles ->
    Enum.map(haystack_sizes, fn size ->
      {"#{length(needles)}-#{size}", {needles, String.slice(haystack, 0..(size - 1))}}
    end)
  end)

IO.puts("Running find_first benchmarks")

[
  {"find_first/2 all_seasons", fn {automata, haystack} -> AhoCorasickNif.find_first(automata, haystack) end},
  {"find_first!/2 all_seasons", fn {automata, haystack} -> AhoCorasickNif.find_first!(automata, haystack) end},
  {"is_match/2 all_seasons", fn {automata, haystack} -> AhoCorasickNif.is_match(automata, haystack) end},
  {"is_match!/2 all_seasons", fn {automata, haystack} -> AhoCorasickNif.is_match!(automata, haystack) end}
]
|> Map.new()
|> Benchee.run(
  inputs: inputs,
  before_each: fn {needles, haystack} -> {AhoCorasickNif.new!(options, needles), haystack} end
)
