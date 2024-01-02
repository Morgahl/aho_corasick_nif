defmodule AhoCorasick do
  alias AhoCorasick.NifBridge

  @type t :: reference()

  @spec new(binary | [binary]) :: {:ok, t()} | {:error, reason :: term()}
  def new(patterns) when is_list(patterns), do: {:ok, NifBridge.new(patterns)}
  def new(binary) when is_binary(binary), do: {:ok, NifBridge.new([binary])}
  def new(term), do: {:error, {:invalid_type, term}}

  @spec add_patterns(t(), binary | [binary]) :: :ok | {:error, reason :: term()}
  def add_patterns(ac, patterns) when is_list(patterns), do: NifBridge.add_patterns(ac, patterns)
  def add_patterns(ac, binary) when is_binary(binary), do: NifBridge.add_patterns(ac, [binary])
  def add_patterns(_ac, term), do: {:error, {:invalid_type, term}}

  @spec remove_patterns(t(), binary | [binary]) :: :ok | {:error, reason :: term()}
  def remove_patterns(ac, patterns) when is_list(patterns), do: NifBridge.remove_patterns(ac, patterns)
  def remove_patterns(ac, binary) when is_binary(binary), do: NifBridge.remove_patterns(ac, [binary])
  def remove_patterns(_ac, term), do: {:error, {:invalid_type, term}}

  @spec find_all(t(), binary) :: {:ok, [binary]} | {:error, reason :: term()}
  def find_all(ac, haystack) when is_binary(haystack), do: NifBridge.find_all(ac, haystack)
  def find_all(_ac, term), do: {:error, {:invalid_type, term}}

  @spec find_all_overlapping(t(), binary) :: {:ok, [binary]} | {:error, reason :: term()}
  def find_all_overlapping(ac, haystack) when is_binary(haystack), do: NifBridge.find_all_overlapping(ac, haystack)
  def find_all_overlapping(_ac, term), do: {:error, {:invalid_type, term}}
end
