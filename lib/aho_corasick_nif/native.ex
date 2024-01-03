defmodule AhoCorasickNif.Native.Match do
  @moduledoc """
  Struct to represent a match found by the Aho-Corasick algorithm.
  """

  @typedoc """
  A match found by the Aho-Corasick algorithm.

  - `:pattern` - the pattern that was matched
  - `:match_` - the substring of the haystack that was matched
  - `:start` - the start index of the match in the haystack (inclusive)
  - `:end` - the end index of the match in the haystack (exclusive)
  """
  @type t :: %__MODULE__{
          pattern: binary(),
          match_: binary(),
          start: non_neg_integer(),
          end: non_neg_integer()
        }
  defstruct [:pattern, :match_, :start, :end]
end

defmodule AhoCorasickNif.Native.BuilderOptions do
  @moduledoc false
  @type aho_corasick_kind :: nil | :noncontiguous_nfa | :contiguous_nfa | :dfa

  @aho_corasick_kinds [nil, :noncontiguous_nfa, :contiguous_nfa, :dfa]

  @type match_kind :: :standard | :leftmost_longest | :leftmost_first

  @match_kinds [:standard, :leftmost_longest, :leftmost_first]

  @type start_kind :: :both | :unanchored | :anchored

  @start_kinds [:both, :unanchored, :anchored]

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
    if arg in [true, false] do
      {options, acc}
    else
      {options, ["ascii_case_insensitive is #{inspect(arg)} must be true or false" | acc]}
    end
  end

  defp validate_byte_classes({%__MODULE__{byte_classes: arg} = options, acc}) do
    if arg in [true, false] do
      {options, acc}
    else
      {options, ["byte_classes is #{inspect(arg)} must be true or false" | acc]}
    end
  end

  defp validate_dense_depth({%__MODULE__{dense_depth: arg} = options, acc}) do
    if is_nil(arg) or arg >= 0 do
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
    if arg in [true, false] do
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
