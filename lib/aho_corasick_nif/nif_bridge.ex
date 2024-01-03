defmodule AhoCorasickNif.NifBridge do
  use Rustler,
    otp_app: :aho_corasick_nif,
    crate: :aho_corasick_nif

  alias AhoCorasickNif.Native.BuilderOptions
  alias AhoCorasickNif.Native.Match

  @spec new(BuilderOptions.t(), [binary]) :: {:ok, AhoCorasickNif.t()} | {:error, AhoCorasickNif.errors()}
  def new(_options, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec add_patterns(AhoCorasickNif.t(), [binary]) :: {:ok, :ok} | {:error, AhoCorasickNif.errors()}
  def add_patterns(_automata, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec remove_patterns(AhoCorasickNif.t(), [binary]) :: {:ok, :ok} | {:error, AhoCorasickNif.errors()}
  def remove_patterns(_automata, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_all(AhoCorasickNif.t(), binary) :: {:ok, [Match.t()]} | {:error, AhoCorasickNif.errors()}
  def find_all(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_all_overlapping(AhoCorasickNif.t(), binary) :: {:ok, [Match.t()]} | {:error, AhoCorasickNif.errors()}
  def find_all_overlapping(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)
end
