defmodule AhoCorasickNif.NifBridge do
  @moduledoc false

  use Rustler,
    otp_app: :aho_corasick_nif,
    crate: :aho_corasick_nif

  alias AhoCorasickNif.Native.BuilderOptions
  alias AhoCorasickNif.Native.Match
  alias AhoCorasickNif.Types

  @spec new(BuilderOptions.t(), [binary]) :: {:ok, AhoCorasickNif.t()} | {:error, Types.errors()}
  def new(_options, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec add_patterns(AhoCorasickNif.t(), [binary]) :: {:ok, :ok} | {:error, Types.errors()}
  def add_patterns(_automata, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec remove_patterns(AhoCorasickNif.t(), [binary]) :: {:ok, :ok} | {:error, Types.errors()}
  def remove_patterns(_automata, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_first(AhoCorasickNif.t(), binary) :: {:ok, Match.t() | nil} | {:error, Types.errors()}
  def find_first(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_all(AhoCorasickNif.t(), binary) :: {:ok, [Match.t()]} | {:error, Types.errors()}
  def find_all(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_all_overlapping(AhoCorasickNif.t(), binary) :: {:ok, [Match.t()]} | {:error, Types.errors()}
  def find_all_overlapping(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)

  @spec is_match(AhoCorasickNif.t(), binary) :: {:ok, boolean()} | {:error, Types.errors()}
  def is_match(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)

  @spec replace_all(AhoCorasickNif.t(), binary, replacements :: [binary]) :: {:ok, binary} | {:error, Types.errors()}
  def replace_all(_automata, _haystack, _replacements), do: :erlang.nif_error(:nif_not_loaded)
end
