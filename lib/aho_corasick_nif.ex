defmodule AhoCorasickNif do
  @moduledoc """
  A NIF wrapper for the Rust crate aho-corasick-nif.

  This module provides a NIF wrapper for the Rust crate aho-corasick-nif. The NIFs are implemented
  in Rust and exposed to Elixir via the Rustler library.
  """

  alias AhoCorasickNif.Native.BuilderOptions
  alias AhoCorasickNif.Native.Match
  alias AhoCorasickNif.NifBridge

  @type t :: Types.automata()

  @spec new(BuilderOptions.t(), binary | [binary]) :: {:ok, t()} | {:error, Types.errors()}
  def new(options, patterns) when is_list(patterns), do: NifBridge.new(options, patterns)
  def new(options, binary) when is_binary(binary), do: NifBridge.new(options, [binary])

  @spec new!(BuilderOptions.t(), binary | [binary]) :: t()
  def new!(options, patterns) when is_list(patterns) do
    case NifBridge.new(options, patterns) do
      {:ok, ac} -> ac
      {:error, reason} -> raise reason
    end
  end

  @spec add_patterns(t(), binary | [binary]) :: :ok | {:error, Types.errors()}
  def add_patterns(ac, patterns) when is_list(patterns) do
    case NifBridge.add_patterns(ac, patterns) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def add_patterns(ac, binary) when is_binary(binary) do
    case NifBridge.add_patterns(ac, [binary]) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @spec add_patterns!(t(), binary | [binary]) :: :ok
  def add_patterns!(ac, patterns) when is_list(patterns) do
    case NifBridge.add_patterns(ac, patterns) do
      {:ok, :ok} -> :ok
      {:error, reason} -> raise reason
    end
  end

  @spec remove_patterns(t(), binary | [binary]) :: :ok | {:error, Types.errors()}
  def remove_patterns(ac, patterns) when is_list(patterns) do
    case NifBridge.remove_patterns(ac, patterns) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def remove_patterns(ac, binary) when is_binary(binary) do
    case NifBridge.remove_patterns(ac, [binary]) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @spec remove_patterns!(t(), binary | [binary]) :: :ok
  def remove_patterns!(ac, patterns) when is_list(patterns) do
    case NifBridge.remove_patterns(ac, patterns) do
      {:ok, :ok} -> :ok
      {:error, reason} -> raise reason
    end
  end

  @spec find_first(t(), binary) :: {:ok, Match.t() | nil} | {:error, Types.errors()}
  def find_first(ac, haystack) when is_binary(haystack), do: NifBridge.find_first(ac, haystack)

  @spec find_all(t(), binary) :: {:ok, [Match.t()]} | {:error, Types.errors()}
  def find_all(ac, haystack) when is_binary(haystack), do: NifBridge.find_all(ac, haystack)

  @spec find_all!(t(), binary) :: [Match.t()]
  def find_all!(ac, haystack) when is_binary(haystack) do
    case NifBridge.find_all(ac, haystack) do
      {:ok, matches} -> matches
      {:error, reason} -> raise reason
    end
  end

  @spec find_all_overlapping(t(), binary) :: {:ok, [Match.t()]} | {:error, Types.errors()}
  def find_all_overlapping(ac, haystack) when is_binary(haystack), do: NifBridge.find_all_overlapping(ac, haystack)

  @spec find_all_overlapping!(t(), binary) :: [Match.t()]
  def find_all_overlapping!(ac, haystack) when is_binary(haystack) do
    case NifBridge.find_all_overlapping(ac, haystack) do
      {:ok, matches} -> matches
      {:error, reason} -> raise reason
    end
  end

  @spec is_match(t(), binary) :: {:ok, boolean()} | {:error, Types.errors()}
  def is_match(ac, haystack) when is_binary(haystack), do: NifBridge.is_match(ac, haystack)

  @spec is_match!(t(), binary) :: boolean()
  def is_match!(ac, haystack) when is_binary(haystack) do
    case NifBridge.is_match(ac, haystack) do
      {:ok, is_match} -> is_match
      {:error, reason} -> raise reason
    end
  end

  @spec replace_all(t(), binary, replacements :: [binary]) :: {:ok, binary} | {:error, Types.errors()}
  def replace_all(ac, haystack, replacements) when is_binary(haystack) and is_list(replacements) do
    NifBridge.replace_all(ac, haystack, replacements)
  end

  @spec replace_all!(t(), binary, replacements :: [binary]) :: binary
  def replace_all!(ac, haystack, replacements) when is_binary(haystack) and is_list(replacements) do
    case NifBridge.replace_all(ac, haystack, replacements) do
      {:ok, replaced} -> replaced
      {:error, reason} -> raise reason
    end
  end
end
