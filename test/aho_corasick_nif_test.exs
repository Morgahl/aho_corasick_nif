defmodule AhoCorasickNifTest do
  use ExUnit.Case

  alias AhoCorasickNif.Native.BuilderOptions
  alias AhoCorasickNif.Native.Match

  doctest AhoCorasickNif

  test "new returns an automata" do
    options = %BuilderOptions{}
    patterns = ["apple", "maple", "Snapple"]

    assert {:ok, _} = AhoCorasickNif.new(options, patterns)
  end

  test "add_patterns adds patterns to the automata" do
    options = %BuilderOptions{}
    patterns = ["maple", "Snapple"]
    haystack = "Nobody likes maple in their apple flavored Snapple."

    assert {:ok, automata} = AhoCorasickNif.new(options, ["apple"])

    expected = [
      %Match{pattern: "apple", match_: "apple", start: 28, end: 33},
      %Match{pattern: "apple", match_: "apple", start: 45, end: 50}
    ]

    assert AhoCorasickNif.find_all(automata, haystack) == {:ok, expected}

    assert AhoCorasickNif.add_patterns(automata, patterns) == :ok

    expected = [
      %Match{pattern: "maple", match_: "maple", start: 13, end: 18},
      %Match{pattern: "apple", match_: "apple", start: 28, end: 33},
      %Match{pattern: "Snapple", match_: "Snapple", start: 43, end: 50}
    ]

    assert AhoCorasickNif.find_all(automata, haystack) == {:ok, expected}
  end

  test "remove_patterns removes patterns from the automata" do
    options = %BuilderOptions{}
    patterns = ["maple", "Snapple"]
    haystack = "Nobody likes maple in their apple flavored Snapple."
    {:ok, automata} = AhoCorasickNif.new(options, ["apple", "maple", "Snapple"])

    expected = [
      %Match{pattern: "maple", match_: "maple", start: 13, end: 18},
      %Match{pattern: "apple", match_: "apple", start: 28, end: 33},
      %Match{pattern: "Snapple", match_: "Snapple", start: 43, end: 50}
    ]

    assert AhoCorasickNif.find_all(automata, haystack) == {:ok, expected}

    assert AhoCorasickNif.remove_patterns(automata, patterns) == :ok

    expected = [
      %Match{pattern: "apple", match_: "apple", start: 28, end: 33},
      %Match{pattern: "apple", match_: "apple", start: 45, end: 50}
    ]

    assert AhoCorasickNif.find_all(automata, haystack) == {:ok, expected}
  end

  test "find_first returns the first occurrence of a needle in haystack" do
    options = %BuilderOptions{}
    needles = ["apple", "maple", "Snapple"]
    haystack = "Nobody likes maple in their apple flavored Snapple."

    assert {:ok, automata} = AhoCorasickNif.new(options, needles)

    expected = %Match{pattern: "maple", match_: "maple", start: 13, end: 18}

    assert AhoCorasickNif.find_first(automata, haystack) == {:ok, expected}
  end

  test "find_all returns all non-overlapping occurrences of needles in haystack" do
    options = %BuilderOptions{}
    needles = ["apple", "maple", "Snapple"]
    haystack = "Nobody likes maple in their apple flavored Snapple."

    assert {:ok, automata} = AhoCorasickNif.new(options, needles)

    expected = [
      %Match{pattern: "maple", match_: "maple", start: 13, end: 18},
      %Match{pattern: "apple", match_: "apple", start: 28, end: 33},
      %Match{pattern: "Snapple", match_: "Snapple", start: 43, end: 50}
    ]

    assert AhoCorasickNif.find_all(automata, haystack) == {:ok, expected}
  end

  test "find_all_overlapping returns all overlapping occurrences of needles in haystack" do
    options = %BuilderOptions{}
    needles = ["apple", "maple", "Snapple"]
    haystack = "Nobody likes maple in their apple flavored Snapple."

    assert {:ok, automata} = AhoCorasickNif.new(options, needles)

    expected = [
      %Match{pattern: "maple", match_: "maple", start: 13, end: 18},
      %Match{pattern: "apple", match_: "apple", start: 28, end: 33},
      %Match{pattern: "Snapple", match_: "Snapple", start: 43, end: 50},
      %Match{pattern: "apple", match_: "apple", start: 45, end: 50}
    ]

    assert AhoCorasickNif.find_all_overlapping(automata, haystack) == {:ok, expected}
  end

  test "is_match returns true if the haystack contains a needle" do
    options = %BuilderOptions{}
    needles = ["apple", "maple", "Snapple"]
    haystack = "Nobody likes maple in their apple flavored Snapple."

    assert {:ok, automata} = AhoCorasickNif.new(options, needles)

    assert AhoCorasickNif.is_match(automata, haystack) == {:ok, true}
  end

  test "is_match returns false if the haystack does not contain a needle" do
    options = %BuilderOptions{}
    needles = ["apple", "maple", "Snapple"]
    haystack = "Nobody likes oranges."

    assert {:ok, automata} = AhoCorasickNif.new(options, needles)

    assert AhoCorasickNif.is_match(automata, haystack) == {:ok, false}
  end

  test "replace_all replaces all occurrences of needles in haystack" do
    options = %BuilderOptions{}
    needles = ["apple", "maple", "Snapple"]
    replacements = ["REDACTED_apple_REDACTED", "REDACTED_maple_REDACTED", "REDACTED_Snapple_REDACTED"]
    haystack = "Nobody likes maple in their apple flavored Snapple."

    assert {:ok, automata} = AhoCorasickNif.new(options, needles)

    expected =
      "Nobody likes REDACTED_maple_REDACTED in their REDACTED_apple_REDACTED flavored REDACTED_Snapple_REDACTED."

    assert AhoCorasickNif.replace_all(automata, haystack, replacements) == {:ok, expected}
  end
end
