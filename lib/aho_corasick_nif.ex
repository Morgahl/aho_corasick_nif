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
  def new(%BuilderOptions{} = options, binary) when is_binary(binary), do: NifBridge.new(options, [binary])
  def new(%BuilderOptions{} = options, patterns) when is_list(patterns), do: NifBridge.new(options, patterns)
  def new(_, _), do: {:error, :argument_error}

  @spec new!(BuilderOptions.t(), binary | [binary]) :: t()
  def new!(options, patterns) do
    case new(options, patterns) do
      {:ok, automata} -> automata
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec add_patterns(t(), binary | [binary]) :: :ok | {:error, Types.errors()}
  def add_patterns(automata, binary) when is_reference(automata) and is_binary(binary) do
    case NifBridge.add_patterns(automata, [binary]) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def add_patterns(automata, patterns) when is_reference(automata) and is_list(patterns) do
    case NifBridge.add_patterns(automata, patterns) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def add_patterns(_, _), do: {:error, :argument_error}

  @spec add_patterns!(t(), binary | [binary]) :: :ok
  def add_patterns!(automata, patterns) do
    case add_patterns(automata, patterns) do
      :ok -> :ok
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec remove_patterns(t(), binary | [binary]) :: :ok | {:error, Types.errors()}
  def remove_patterns(automata, binary) when is_reference(automata) and is_binary(binary) do
    case NifBridge.remove_patterns(automata, [binary]) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def remove_patterns(automata, patterns) when is_reference(automata) and is_list(patterns) do
    case NifBridge.remove_patterns(automata, patterns) do
      {:ok, :ok} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def remove_patterns(_, _), do: {:error, :argument_error}

  @spec remove_patterns!(t(), binary | [binary]) :: :ok
  def remove_patterns!(automata, patterns) do
    case remove_patterns(automata, patterns) do
      :ok -> :ok
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec find_first(t(), binary) :: {:ok, Match.t() | nil} | {:error, Types.errors()}
  def find_first(automata, haystack) when is_reference(automata) and is_binary(haystack) do
    NifBridge.find_first(automata, haystack)
  end

  def find_first(_, _), do: {:error, :argument_error}

  @spec find_first!(t(), binary) :: Match.t() | nil
  def find_first!(automata, haystack) do
    case find_first(automata, haystack) do
      {:ok, match} -> match
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec find_all(t(), binary) :: {:ok, [Match.t()]} | {:error, Types.errors()}
  def find_all(automata, haystack) when is_reference(automata) and is_binary(haystack) do
    NifBridge.find_all(automata, haystack)
  end

  def find_all(_, _), do: {:error, :argument_error}

  @spec find_all!(t(), binary) :: [Match.t()]
  def find_all!(automata, haystack) do
    case find_all(automata, haystack) do
      {:ok, matches} -> matches
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec find_all_overlapping(t(), binary) :: {:ok, [Match.t()]} | {:error, Types.errors()}
  def find_all_overlapping(automata, haystack) when is_reference(automata) and is_binary(haystack) do
    NifBridge.find_all_overlapping(automata, haystack)
  end

  def find_all_overlapping(_, _), do: {:error, :argument_error}

  @spec find_all_overlapping!(t(), binary) :: [Match.t()]
  def find_all_overlapping!(automata, haystack) do
    case find_all_overlapping(automata, haystack) do
      {:ok, matches} -> matches
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec is_match(t(), binary) :: {:ok, boolean()} | {:error, Types.errors()}
  def is_match(automata, haystack) when is_reference(automata) and is_binary(haystack) do
    NifBridge.is_match(automata, haystack)
  end

  def is_match(_, _), do: {:error, :argument_error}

  @spec is_match!(t(), binary) :: boolean()
  def is_match!(automata, haystack) do
    case is_match(automata, haystack) do
      {:ok, is_match} -> is_match
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end

  @spec replace_all(t(), binary, replacements :: [binary]) :: {:ok, binary} | {:error, Types.errors()}
  def replace_all(automata, haystack, replacements)
      when is_reference(automata) and is_binary(haystack) and is_list(replacements) do
    NifBridge.replace_all(automata, haystack, replacements)
  end

  def replace_all(_, _, _), do: {:error, :argument_error}

  @spec replace_all!(t(), binary, replacements :: [binary]) :: binary
  def replace_all!(automata, haystack, replacements) do
    case replace_all(automata, haystack, replacements) do
      {:ok, replaced} -> replaced
      {:error, :argument_error} -> raise ArgumentError
      {:error, reason} -> raise reason
    end
  end
end
