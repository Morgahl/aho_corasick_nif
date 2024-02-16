defmodule AhoCorasickNifTest do
  use ExUnit.Case, async: true

  alias AhoCorasickNif.Native.BuilderOptions

  doctest AhoCorasickNif

  setup do
    haystack = "Nobody likes maple in their apple flavored Snapple."
    needles = ["apple", "maple", "Snapple"]
    [apple | maple_snapple] = needles
    missing_needles = ["banana", "orange", "grape"]
    options = %BuilderOptions{}

    all_matches = [
      {"maple", "maple", 13, 18},
      {"apple", "apple", 28, 33},
      {"Snapple", "Snapple", 43, 50}
    ]

    all_matches_overlapping = [
      {"maple", "maple", 13, 18},
      {"apple", "apple", 28, 33},
      {"Snapple", "Snapple", 43, 50},
      {"apple", "apple", 45, 50}
    ]

    apple_only_matches = [
      {"apple", "apple", 28, 33},
      {"apple", "apple", 45, 50}
    ]

    maple_only_match = {"maple", "maple", 13, 18}

    maple_snapple_only_matches = [
      {"maple", "maple", 13, 18},
      {"Snapple", "Snapple", 43, 50}
    ]

    replacements = ["REDACTED_apple_REDACTED", "REDACTED_maple_REDACTED", "REDACTED_Snapple_REDACTED"]

    redacted_haystack =
      "Nobody likes REDACTED_maple_REDACTED in their REDACTED_apple_REDACTED flavored REDACTED_Snapple_REDACTED."

    {:ok,
     all_matches_overlapping: all_matches_overlapping,
     all_matches: all_matches,
     apple_only_matches: apple_only_matches,
     apple: apple,
     haystack: haystack,
     maple_only_match: maple_only_match,
     maple_snapple_only_matches: maple_snapple_only_matches,
     maple_snapple: maple_snapple,
     missing_needles: missing_needles,
     needles: needles,
     options: options,
     redacted_haystack: redacted_haystack,
     replacements: replacements}
  end

  describe "new/2" do
    test "returns an automata when given multiple needles", %{needles: needles, options: options} do
      assert {:ok, _} = AhoCorasickNif.new(options, needles)
    end

    test "returns an automata when given a single needle", %{apple: apple, options: options} do
      assert {:ok, _} = AhoCorasickNif.new(options, apple)
    end

    test "returns an error tuple if the patterns are invalid", %{options: options} do
      assert {:error, :argument_error} = AhoCorasickNif.new(options, nil)
    end

    test "returns an error tuple if the options are invalid", %{needles: needles} do
      assert {:error, :argument_error} = AhoCorasickNif.new(nil, needles)
    end
  end

  describe "new!/2" do
    test "returns an automata when given multiple needles", %{needles: needles, options: options} do
      assert AhoCorasickNif.new!(options, needles)
    end

    test "returns an automata when given a single needle", %{apple: apple, options: options} do
      assert AhoCorasickNif.new!(options, apple)
    end

    test "raises an error if the patterns are invalid", %{options: options} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.new!(options, nil)
      end
    end

    test "raises an error if the options are invalid", %{needles: needles} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.new!(nil, needles)
      end
    end
  end

  describe "add_patterns/2" do
    test "adds multiple patterns to the automata", %{
      all_matches: all_matches,
      apple_only_matches: apple_only_matches,
      apple: apple,
      haystack: haystack,
      maple_snapple: maple_snapple,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, apple)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, apple_only_matches}
      assert AhoCorasickNif.add_patterns(automata, maple_snapple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
    end

    test "adds single pattern to the automata", %{
      all_matches: all_matches,
      apple: apple,
      haystack: haystack,
      maple_snapple_only_matches: maple_snapple_only_matches,
      maple_snapple: maple_snapple,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, maple_snapple)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, maple_snapple_only_matches}
      assert AhoCorasickNif.add_patterns(automata, apple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
    end

    test "returns an error tuple if the patterns are invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.add_patterns(automata, nil)
    end

    test "returns an error tuple if the automata is invalid", %{needles: needles} do
      assert {:error, :argument_error} = AhoCorasickNif.add_patterns(nil, needles)
    end
  end

  describe "add_patterns!/2" do
    test "adds multiple patterns to the automata", %{
      all_matches: all_matches,
      apple_only_matches: apple_only_matches,
      apple: apple,
      haystack: haystack,
      maple_snapple: maple_snapple,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, apple)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, apple_only_matches}
      assert AhoCorasickNif.add_patterns!(automata, maple_snapple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
    end

    test "adds single pattern to the automata", %{
      all_matches: all_matches,
      apple: apple,
      haystack: haystack,
      maple_snapple_only_matches: maple_snapple_only_matches,
      maple_snapple: maple_snapple,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, maple_snapple)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, maple_snapple_only_matches}
      assert AhoCorasickNif.add_patterns!(automata, apple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
    end

    test "raises an error if the patterns are invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.add_patterns!(automata, nil)
      end
    end

    test "raises an error if the automata is invalid", %{needles: needles} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.add_patterns!(nil, needles)
      end
    end
  end

  describe "remove_patterns/2" do
    test "removes multiple patterns from the automata", %{
      all_matches: all_matches,
      apple_only_matches: apple_only_matches,
      haystack: haystack,
      maple_snapple: maple_snapple,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
      assert AhoCorasickNif.remove_patterns(automata, maple_snapple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, apple_only_matches}
    end

    test "removes single pattern from the automata", %{
      apple: apple,
      all_matches: all_matches,
      haystack: haystack,
      maple_snapple_only_matches: maple_snapple_only_matches,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
      assert AhoCorasickNif.remove_patterns(automata, apple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, maple_snapple_only_matches}
    end

    test "returns an error tuple if the patterns are invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.remove_patterns(automata, nil)
    end

    test "returns an error tuple if the automata is invalid", %{needles: needles} do
      assert {:error, :argument_error} = AhoCorasickNif.remove_patterns(nil, needles)
    end
  end

  describe "remove_patterns!/2" do
    test "removes multiple patterns from the automata", %{
      all_matches: all_matches,
      apple_only_matches: apple_only_matches,
      haystack: haystack,
      maple_snapple: maple_snapple,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
      assert AhoCorasickNif.remove_patterns!(automata, maple_snapple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, apple_only_matches}
    end

    test "removes single pattern from the automata", %{
      all_matches: all_matches,
      apple: apple,
      haystack: haystack,
      maple_snapple_only_matches: maple_snapple_only_matches,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
      assert AhoCorasickNif.remove_patterns!(automata, apple) == :ok
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, maple_snapple_only_matches}
    end

    test "raises an error if the patterns are invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.remove_patterns!(automata, nil)
      end
    end

    test "raises an error if the automata is invalid", %{needles: needles} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.remove_patterns!(nil, needles)
      end
    end
  end

  describe "find_first/2" do
    test "returns the apple occurrence of a needle in haystack", %{
      haystack: haystack,
      maple_only_match: maple_only_match,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_first(automata, haystack) == {:ok, maple_only_match}
    end

    test "returns nil if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert {:ok, nil} = AhoCorasickNif.find_first(automata, haystack)
    end

    test "returns an error tuple if the automata is invalid", %{needles: needles} do
      assert {:error, :argument_error} = AhoCorasickNif.find_first(nil, needles)
    end

    test "returns an error tuple if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.find_first(automata, nil)
    end
  end

  describe "find_first!/2" do
    test "returns the apple occurrence of a needle in haystack", %{
      haystack: haystack,
      maple_only_match: maple_only_match,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_first!(automata, haystack) == maple_only_match
    end

    test "returns nil if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.find_first!(automata, haystack) == nil
    end

    test "raises an error if the automata is invalid", %{needles: needles} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.find_first!(nil, needles)
      end
    end

    test "raises an error if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.find_first!(automata, nil)
      end
    end
  end

  describe "find_all/2" do
    test "returns all non-overlapping occurrences of needles in haystack", %{
      all_matches: all_matches,
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all(automata, haystack) == {:ok, all_matches}
    end

    test "returns an empty list if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert {:ok, []} = AhoCorasickNif.find_all(automata, haystack)
    end

    test "returns an error tuple if the automata is invalid", %{haystack: haystack} do
      assert {:error, :argument_error} = AhoCorasickNif.find_all(nil, haystack)
    end

    test "returns an error tuple if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.find_all(automata, nil)
    end
  end

  describe "find_all!/2" do
    test "returns all non-overlapping occurrences of needles in haystack", %{
      all_matches: all_matches,
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all!(automata, haystack) == all_matches
    end

    test "returns an empty list if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.find_all!(automata, haystack) == []
    end

    test "raises an error if the automata is invalid", %{haystack: haystack} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.find_all!(nil, haystack)
      end
    end

    test "raises an error if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.find_all!(automata, nil)
      end
    end
  end

  describe "find_all_overlapping/2" do
    test "returns all overlapping occurrences of needles in haystack", %{
      all_matches_overlapping: all_matches_overlapping,
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all_overlapping(automata, haystack) == {:ok, all_matches_overlapping}
    end

    test "returns an empty list if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert {:ok, []} = AhoCorasickNif.find_all_overlapping(automata, haystack)
    end

    test "returns an error tuple if the automata is invalid", %{haystack: haystack} do
      assert {:error, :argument_error} = AhoCorasickNif.find_all_overlapping(nil, haystack)
    end

    test "returns an error tuple if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.find_all_overlapping(automata, nil)
    end
  end

  describe "find_all_overlapping!/2" do
    test "returns all overlapping occurrences of needles in haystack", %{
      all_matches_overlapping: all_matches_overlapping,
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.find_all_overlapping!(automata, haystack) == all_matches_overlapping
    end

    test "returns an empty list if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.find_all_overlapping!(automata, haystack) == []
    end

    test "raises an error if the automata is invalid", %{haystack: haystack} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.find_all_overlapping!(nil, haystack)
      end
    end

    test "raises an error if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.find_all_overlapping!(automata, nil)
      end
    end
  end

  describe "is_match/2" do
    test "is_match returns true if the haystack contains a needle", %{
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.is_match(automata, haystack) == {:ok, true}
    end

    test "is_match returns false if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.is_match(automata, haystack) == {:ok, false}
    end

    test "returns an error tuple if the automata is invalid", %{haystack: haystack} do
      assert {:error, :argument_error} = AhoCorasickNif.is_match(nil, haystack)
    end

    test "returns an error tuple if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.is_match(automata, nil)
    end
  end

  describe "is_match!/2" do
    test "is_match returns true if the haystack contains a needle", %{
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.is_match!(automata, haystack) == true
    end

    test "is_match returns false if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.is_match!(automata, haystack) == false
    end

    test "raises an error if the automata is invalid", %{haystack: haystack} do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.is_match!(nil, haystack)
      end
    end

    test "raises an error if the haystack is invalid", %{needles: needles, options: options} do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.is_match!(automata, nil)
      end
    end
  end

  describe "replace_all/3" do
    test "replace_all replaces all occurrences of needles in haystack", %{
      haystack: haystack,
      needles: needles,
      options: options,
      redacted_haystack: redacted_haystack,
      replacements: replacements
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.replace_all(automata, haystack, replacements) == {:ok, redacted_haystack}
    end

    test "replace_all replaces nothing if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options,
      replacements: replacements
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.replace_all(automata, haystack, replacements) == {:ok, haystack}
    end

    test "returns an error tuple if the automata is invalid", %{
      haystack: haystack,
      replacements: replacements
    } do
      assert {:error, :argument_error} = AhoCorasickNif.replace_all(nil, haystack, replacements)
    end

    test "returns an error tuple if the haystack is invalid", %{
      needles: needles,
      options: options,
      replacements: replacements
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.replace_all(automata, nil, replacements)
    end

    test "returns an error tuple if the replacements are invalid", %{
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert {:error, :argument_error} = AhoCorasickNif.replace_all(automata, haystack, nil)
    end
  end

  describe "replace_all!/3" do
    test "replace_all replaces all occurrences of needles in haystack", %{
      haystack: haystack,
      needles: needles,
      options: options,
      redacted_haystack: redacted_haystack,
      replacements: replacements
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)
      assert AhoCorasickNif.replace_all!(automata, haystack, replacements) == redacted_haystack
    end

    test "replace_all replaces nothing if the haystack does not contain a needle", %{
      haystack: haystack,
      missing_needles: missing_needles,
      options: options,
      replacements: replacements
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, missing_needles)
      assert AhoCorasickNif.replace_all!(automata, haystack, replacements) == haystack
    end

    test "raises an error if the automata is invalid", %{
      haystack: haystack,
      replacements: replacements
    } do
      assert_raise ArgumentError, fn ->
        AhoCorasickNif.replace_all!(nil, haystack, replacements)
      end
    end

    test "raises an error if the haystack is invalid", %{
      needles: needles,
      options: options,
      replacements: replacements
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.replace_all!(automata, nil, replacements)
      end
    end

    test "raises an error if the replacements are invalid", %{
      haystack: haystack,
      needles: needles,
      options: options
    } do
      assert {:ok, automata} = AhoCorasickNif.new(options, needles)

      assert_raise ArgumentError, fn ->
        AhoCorasickNif.replace_all!(automata, haystack, nil)
      end
    end
  end
end
