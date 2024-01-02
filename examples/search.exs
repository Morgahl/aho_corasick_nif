needles = ["apple", "maple", "snapple"]
haystack = "Nobody likes maple in their apple flavored Snapple." |> String.duplicate(3)

# Safe API
IO.inspect {:ok, automata} = AhoCorasick.new(needles)
IO.inspect AhoCorasick.find_all(automata, haystack)
IO.inspect AhoCorasick.find_all_overlapping(automata, haystack)

IO.inspect :ok = AhoCorasick.add_patterns(automata, ["banana", "orange", "apple flavor"])
IO.inspect AhoCorasick.find_all(automata, haystack)
IO.inspect AhoCorasick.find_all_overlapping(automata, haystack)

IO.inspect :ok = AhoCorasick.remove_patterns(automata, ["apple", "maple"])
IO.inspect AhoCorasick.find_all(automata, haystack)
IO.inspect AhoCorasick.find_all_overlapping(automata, haystack)

# Unsafe API
IO.inspect automata = AhoCorasick.new!(needles)
IO.inspect AhoCorasick.find_all!(automata, haystack)
IO.inspect AhoCorasick.find_all_overlapping!(automata, haystack)

IO.inspect :ok = AhoCorasick.add_patterns!(automata, ["banana", "orange", "apple flavor"])
IO.inspect AhoCorasick.find_all!(automata, haystack)
IO.inspect AhoCorasick.find_all_overlapping!(automata, haystack)

IO.inspect :ok = AhoCorasick.remove_patterns!(automata, ["apple", "maple"])
IO.inspect AhoCorasick.find_all!(automata, haystack)
IO.inspect AhoCorasick.find_all_overlapping!(automata, haystack)
