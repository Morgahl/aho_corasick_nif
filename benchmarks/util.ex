defmodule AhoCorasickNif.Benchmark.Util do
  @moduledoc false

  @headers [
    :Season,
    :Episode,
    :Character,
    :Line
  ]

  def load_csv(file_path) do
    file_path
    |> File.stream!()
    |> CSV.decode(headers: @headers, escape_max_lines: 100)
    |> Stream.map(fn {:ok, row} -> row end)
  end

  def generate_haystacks(data) do
    data
    |> Stream.map(& &1[:Line])
    |> Enum.join("\n")
  end

  def generate_unique_strings(data, count) do
    data
    |> String.split(~r/[\.\!\?\-\(\),\'\"\n_:]*\s+[\.\!\?\-\(\),\'\"\n_:]*/)
    |> Stream.filter(&String.match?(&1, ~r/\S{3,}/))
    |> Enum.uniq()
    |> Enum.take_random(count)
  end

  def build_corasearch_needles(needles) do
    needles |> Enum.with_index(fn needle, index -> {needle, index} end)
  end
end
