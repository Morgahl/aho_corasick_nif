alias AhoCorasickNif.Native.BuilderOptions

haystack = "Nobody likes maple in their apple flavored Snapple."
needles = ["apple", "maple", "Snapple"]
extra_needles = ["banana", "orange", "apple flavor"]
removed_needles = ["apple", "maple"]

options =
  %BuilderOptions{}
  |> BuilderOptions.validate!()

# Safe API
IO.inspect({:ok, automata} = AhoCorasickNif.new(options, needles))
IO.inspect(AhoCorasickNif.find_all(automata, haystack))
IO.inspect(AhoCorasickNif.find_all_overlapping(automata, haystack))

IO.inspect(:ok = AhoCorasickNif.add_patterns(automata, extra_needles))
IO.inspect(AhoCorasickNif.find_all(automata, haystack))
IO.inspect(AhoCorasickNif.find_all_overlapping(automata, haystack))

IO.inspect(:ok = AhoCorasickNif.remove_patterns(automata, removed_needles))
IO.inspect(AhoCorasickNif.find_all(automata, haystack))
IO.inspect(AhoCorasickNif.find_all_overlapping(automata, haystack))

# Unsafe API
IO.inspect(automata = AhoCorasickNif.new!(options, needles))
IO.inspect(AhoCorasickNif.find_all!(automata, haystack))
IO.inspect(AhoCorasickNif.find_all_overlapping!(automata, haystack))

IO.inspect(:ok = AhoCorasickNif.add_patterns!(automata, extra_needles))
IO.inspect(AhoCorasickNif.find_all!(automata, haystack))
IO.inspect(AhoCorasickNif.find_all_overlapping!(automata, haystack))

IO.inspect(:ok = AhoCorasickNif.remove_patterns!(automata, removed_needles))
IO.inspect(AhoCorasickNif.find_all!(automata, haystack))
IO.inspect(AhoCorasickNif.find_all_overlapping!(automata, haystack))
