defmodule AhoCorasick do
  alias AhoCorasick.NifBridge

  @type t :: Types.automata()

  @spec new(binary | [binary]) :: {:ok, t()} | {:error, Types.errors()}
  def new(patterns) when is_list(patterns), do: NifBridge.new(patterns)
  def new(binary) when is_binary(binary), do: NifBridge.new([binary])
  def new(term), do: NifBridge.new(term)

  @spec new!(binary | [binary]) :: t()
  def new!(patterns) when is_list(patterns) do
    case NifBridge.new(patterns) do
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

  def add_patterns(ac, term) do
    case NifBridge.add_patterns(ac, term) do
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

  def remove_patterns(ac, term) do
    case NifBridge.remove_patterns(ac, term) do
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

  @spec find_all(t(), binary) :: {:ok, [Types.match()]} | {:error, Types.errors()}
  def find_all(ac, haystack) when is_binary(haystack), do: NifBridge.find_all(ac, haystack)
  def find_all(ac, term), do: NifBridge.find_all(ac, term)

  @spec find_all!(t(), binary) :: [Types.match()]
  def find_all!(ac, haystack) when is_binary(haystack) do
    case NifBridge.find_all(ac, haystack) do
      {:ok, matches} -> matches
      {:error, reason} -> raise reason
    end
  end

  @spec find_all_overlapping(t(), binary) :: {:ok, [Types.match()]} | {:error, Types.errors()}
  def find_all_overlapping(ac, haystack) when is_binary(haystack), do: NifBridge.find_all_overlapping(ac, haystack)
  def find_all_overlapping(ac, term), do: NifBridge.find_all_overlapping(ac, term)

  @spec find_all_overlapping!(t(), binary) :: [Types.match()]
  def find_all_overlapping!(ac, haystack) when is_binary(haystack) do
    case NifBridge.find_all_overlapping(ac, haystack) do
      {:ok, matches} -> matches
      {:error, reason} -> raise reason
    end
  end
end
