defmodule AhoCorasickNif.Native.BuilderOptionsTest do
  use ExUnit.Case, async: true

  alias AhoCorasickNif.Native.BuilderOptions

  doctest BuilderOptions

  setup do
    default_builder_options = %BuilderOptions{}

    invalid_builder_options = %BuilderOptions{
      aho_corasick_kind: :invalid,
      ascii_case_insensitive: :invalid,
      byte_classes: :invalid,
      dense_depth: :invalid,
      match_kind: :invalid,
      prefilter: :invalid,
      start_kind: :invalid
    }

    all_failures = [
      "aho_corasick_kind is :invalid must be one of [nil, :noncontiguous_nfa, :contiguous_nfa, :dfa]",
      "ascii_case_insensitive is :invalid must be true or false",
      "byte_classes is :invalid must be true or false",
      "dense_depth is :invalid must be a non-negative integer or nil",
      "match_kind is :invalid must be one of [:standard, :leftmost_longest, :leftmost_first]",
      "prefilter is :invalid must be true or false",
      "start_kind is :invalid must be one of [:both, :unanchored, :anchored]"
    ]

    {:ok,
     all_failures: all_failures,
     default_builder_options: default_builder_options,
     invalid_builder_options: invalid_builder_options}
  end

  describe "validate/1" do
    test "the default builder options are valid", %{default_builder_options: default_builder_options} do
      assert BuilderOptions.validate(default_builder_options) == {:ok, default_builder_options}
    end

    test "the builder options with invalid values fails to validate", %{
      all_failures: all_failures,
      invalid_builder_options: invalid_builder_options
    } do
      assert BuilderOptions.validate(invalid_builder_options) == {:error, all_failures}
    end
  end

  describe "validate!/1" do
    test "the default builder options are valid", %{default_builder_options: default_builder_options} do
      assert BuilderOptions.validate!(default_builder_options) == default_builder_options
    end

    test "the builder options with invalid values fails to validate", %{
      all_failures: all_failures,
      invalid_builder_options: invalid_builder_options
    } do
      assert_raise ArgumentError, "Invalid options: #{inspect(all_failures)}", fn ->
        BuilderOptions.validate!(invalid_builder_options)
      end
    end
  end
end
