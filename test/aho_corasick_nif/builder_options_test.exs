defmodule AhoCorasickNif.Native.BuilderOptionsTest do
  use ExUnit.Case, async: true

  alias AhoCorasickNif.Native.BuilderOptions

  doctest BuilderOptions

  setup do
    default_opts = %BuilderOptions{}

    invalid_opts = %BuilderOptions{
      aho_corasick_kind: :invalid,
      ascii_case_insensitive: :invalid,
      byte_classes: :invalid,
      dense_depth: :invalid,
      match_kind: :invalid,
      prefilter: :invalid,
      start_kind: :invalid
    }

    failures = [
      "aho_corasick_kind is :invalid must be one of [nil, :noncontiguous_nfa, :contiguous_nfa, :dfa]",
      "ascii_case_insensitive is :invalid must be true or false",
      "byte_classes is :invalid must be true or false",
      "dense_depth is :invalid must be a non-negative integer or nil",
      "match_kind is :invalid must be one of [:standard, :leftmost_longest, :leftmost_first]",
      "prefilter is :invalid must be true or false",
      "start_kind is :invalid must be one of [:both, :unanchored, :anchored]"
    ]

    {:ok, default_opts: default_opts, failures: failures, invalid_opts: invalid_opts}
  end

  describe "validate/1" do
    test "the default builder options are valid", %{default_opts: default_opts} do
      assert BuilderOptions.validate(default_opts) == {:ok, default_opts}
    end

    test "the builder options with invalid values fails to validate", %{
      failures: failures,
      invalid_opts: invalid_opts
    } do
      assert BuilderOptions.validate(invalid_opts) == {:error, failures}
    end
  end

  describe "validate!/1" do
    test "the default builder options are valid", %{default_opts: default_opts} do
      assert BuilderOptions.validate!(default_opts) == default_opts
    end

    test "the builder options with invalid values fails to validate", %{failures: failures, invalid_opts: invalid_opts} do
      assert_raise ArgumentError, "Invalid options: #{inspect(failures)}", fn ->
        BuilderOptions.validate!(invalid_opts)
      end
    end
  end
end
