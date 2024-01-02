defmodule AhoCorasick.NifBridge do
  use Rustler,
    otp_app: :aho_corasick,
    crate: :aho_corasick_nif

  @spec new([binary]) :: {:ok, AhoCorasick.t()} | {:error, AhoCorasick.errors()}
  def new(_patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec add_patterns(AhoCorasick.t(), [binary]) :: {:ok, :ok} | {:error, AhoCorasick.errors()}
  def add_patterns(_automata, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec remove_patterns(AhoCorasick.t(), [binary]) :: {:ok, :ok} | {:error, AhoCorasick.errors()}
  def remove_patterns(_automata, _patterns), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_all(AhoCorasick.t(), binary) :: {:ok, [AhoCorasick.match()]} | {:error, AhoCorasick.errors()}
  def find_all(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)

  @spec find_all_overlapping(AhoCorasick.t(), binary) :: {:ok, [AhoCorasick.match()]} | {:error, AhoCorasick.errors()}
  def find_all_overlapping(_automata, _haystack), do: :erlang.nif_error(:nif_not_loaded)
end
