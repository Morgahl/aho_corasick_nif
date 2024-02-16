defmodule AhoCorasickNif.Native.BuilderOptions do
  @moduledoc """
  Struct to represent the options passed to the builder.

  The options are:

  - `:aho_corasick_kind` - the kind of Aho-Corasick algorithm to use
    - `nil` - use the default algorithm (it makes the chose based ont pattern counts)
    - `:noncontiguous_nfa` - use the noncontiguous NFA algorithm
    - `:contiguous_nfa` - use the contiguous NFA algorithm
    - `:dfa` - use the DFA algorithm
  - `:ascii_case_insensitive` - whether to ignore case for ASCII characters
  - `:byte_classes` - whether to use byte classes
  - `:dense_depth` - the depth at which to switch to the dense representation
    - `nil` - use the default depth (it uses defaults for each automata type)
    - `non_neg_integer()` - use the given depth
  - `:match_kind` - the kind of match to return
    - `:standard` - return all matches
    - `:leftmost_longest` - return the leftmost longest match
    - `:leftmost_first` - return the leftmost first match
  - `:prefilter` - whether to use the prefilter
  - `:start_kind` - the kind of start to use
    - `:both` - match both anchored and unanchored patterns
    - `:unanchored` - match only unanchored patterns
    - `:anchored` - match only anchored patterns
  """

  @typedoc """
  The kind of Aho-Corasick algorithm to use.

  - `nil` - use the default algorithm (it makes the chose based ont pattern counts)
  - `:noncontiguous_nfa` - use the noncontiguous NFA algorithm
  - `:contiguous_nfa` - use the contiguous NFA algorithm
  - `:dfa` - use the DFA algorithm
  """
  @type aho_corasick_kind :: nil | :noncontiguous_nfa | :contiguous_nfa | :dfa

  @aho_corasick_kinds [nil, :noncontiguous_nfa, :contiguous_nfa, :dfa]

  @typedoc """
  The match kind to return.

  - `:standard` - return all matches
  - `:leftmost_longest` - return the leftmost longest match
  - `:leftmost_first` - return the leftmost first match
  """
  @type match_kind :: :standard | :leftmost_longest | :leftmost_first

  @match_kinds [:standard, :leftmost_longest, :leftmost_first]

  @typedoc """
  The start kind to use.

  - `:both` - match both anchored and unanchored patterns
  - `:unanchored` - match only unanchored patterns
  - `:anchored` - match only anchored patterns
  """
  @type start_kind :: :both | :unanchored | :anchored

  @start_kinds [:both, :unanchored, :anchored]

  @typedoc """
  The options passed to the builder.

  See module documentation for details.
  """
  @type t :: %__MODULE__{
          aho_corasick_kind: nil | aho_corasick_kind(),
          ascii_case_insensitive: boolean(),
          byte_classes: boolean(),
          dense_depth: nil | non_neg_integer(),
          match_kind: match_kind(),
          prefilter: boolean(),
          start_kind: start_kind()
        }

  defstruct aho_corasick_kind: nil,
            ascii_case_insensitive: false,
            byte_classes: true,
            dense_depth: nil,
            match_kind: :standard,
            prefilter: true,
            start_kind: :unanchored

  @doc "Validate the options passed to the builder."
  @spec validate(t()) :: {:ok, t()} | {:error, [String.t()]}
  def validate(%__MODULE__{} = options) do
    {options, []}
    |> validate_aho_corasick_kind()
    |> validate_ascii_case_insensitive()
    |> validate_byte_classes()
    |> validate_dense_depth()
    |> validate_match_kind()
    |> validate_prefilter()
    |> validate_start_kind()
    |> case do
      {options, []} -> {:ok, options}
      {_options, errors} -> {:error, errors |> Enum.reverse()}
    end
  end

  @doc "Validate the options passed to the builder and raise an error if invalid."
  @spec validate!(t()) :: t()
  def validate!(options) do
    case validate(options) do
      {:ok, options} -> options
      {:error, errors} -> raise ArgumentError, "Invalid options: #{inspect(errors)}"
    end
  end

  defp validate_aho_corasick_kind({%__MODULE__{aho_corasick_kind: arg} = options, acc}) do
    if arg in @aho_corasick_kinds do
      {options, acc}
    else
      {options, ["aho_corasick_kind is #{inspect(arg)} must be one of #{inspect(@aho_corasick_kinds)}" | acc]}
    end
  end

  defp validate_ascii_case_insensitive({%__MODULE__{ascii_case_insensitive: arg} = options, acc}) do
    if is_boolean(arg) do
      {options, acc}
    else
      {options, ["ascii_case_insensitive is #{inspect(arg)} must be true or false" | acc]}
    end
  end

  defp validate_byte_classes({%__MODULE__{byte_classes: arg} = options, acc}) do
    if is_boolean(arg) do
      {options, acc}
    else
      {options, ["byte_classes is #{inspect(arg)} must be true or false" | acc]}
    end
  end

  defp validate_dense_depth({%__MODULE__{dense_depth: arg} = options, acc}) do
    if is_nil(arg) or (is_integer(arg) and arg >= 0) do
      {options, acc}
    else
      {options, ["dense_depth is #{inspect(arg)} must be a non-negative integer or nil" | acc]}
    end
  end

  defp validate_match_kind({%__MODULE__{match_kind: arg} = options, acc}) do
    if arg in @match_kinds do
      {options, acc}
    else
      {options, ["match_kind is #{inspect(arg)} must be one of #{inspect(@match_kinds)}" | acc]}
    end
  end

  defp validate_prefilter({%__MODULE__{prefilter: arg} = options, acc}) do
    if is_boolean(arg) do
      {options, acc}
    else
      {options, ["prefilter is #{inspect(arg)} must be true or false" | acc]}
    end
  end

  defp validate_start_kind({%__MODULE__{start_kind: arg} = options, acc}) do
    if arg in @start_kinds do
      {options, acc}
    else
      {options, ["start_kind is #{inspect(arg)} must be one of #{inspect(@start_kinds)}" | acc]}
    end
  end
end
