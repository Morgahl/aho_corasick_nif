needles = ["apple", "maple", "snapple"]
haystack = "Nobody likes maple in their apple flavored Snapple." |> String.duplicate(3)

# Safe API
IO.inspect {:ok, automata} = AhoCorasickNif.new(needles)
IO.inspect AhoCorasickNif.find_all(automata, haystack)
IO.inspect AhoCorasickNif.find_all_overlapping(automata, haystack)

IO.inspect :ok = AhoCorasickNif.add_patterns(automata, ["banana", "orange", "apple flavor"])
IO.inspect AhoCorasickNif.find_all(automata, haystack)
IO.inspect AhoCorasickNif.find_all_overlapping(automata, haystack)

IO.inspect :ok = AhoCorasickNif.remove_patterns(automata, ["apple", "maple"])
IO.inspect AhoCorasickNif.find_all(automata, haystack)
IO.inspect AhoCorasickNif.find_all_overlapping(automata, haystack)

# Unsafe API
IO.inspect automata = AhoCorasickNif.new!(needles)
IO.inspect AhoCorasickNif.find_all!(automata, haystack)
IO.inspect AhoCorasickNif.find_all_overlapping!(automata, haystack)

IO.inspect :ok = AhoCorasickNif.add_patterns!(automata, ["banana", "orange", "apple flavor"])
IO.inspect AhoCorasickNif.find_all!(automata, haystack)
IO.inspect AhoCorasickNif.find_all_overlapping!(automata, haystack)

IO.inspect :ok = AhoCorasickNif.remove_patterns!(automata, ["apple", "maple"])
IO.inspect AhoCorasickNif.find_all!(automata, haystack)
IO.inspect AhoCorasickNif.find_all_overlapping!(automata, haystack)
