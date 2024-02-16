defmodule AhoCorasickNif.MixProject do
  use Mix.Project

  @app_name :aho_corasick_nif
  @version "0.1.0-beta.2"
  @scm_url "https://github.com/morgahl/aho_corasick_nif"

  def project do
    [
      app: @app_name,
      deps: deps(),
      docs: docs(),
      elixir: "~> 1.15",
      package: package(),
      start_permanent: Mix.env() == :prod,
      test_coverage: test_coverage(),
      version: @version
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:rustler, "~> 0.31"}
    ]
  end

  defp docs() do
    [
      name: "AhoCorasickNif",
      extras: ["README.md"],
      main: "readme",
      source_url: @scm_url,
      source_ref: "v#{@version}"
    ]
  end

  defp package() do
    [
      name: @app_name,
      description: "Aho-Corasick string matching algorithm implemented as a NIF wrapper of the Rust crate aho-corasick",
      files: [
        "lib",
        "native/aho_corasick_nif/Cargo.toml",
        "native/aho_corasick_nif/README.md",
        "native/aho_corasick_nif/src",
        ".formatter.exs",
        "README*",
        "LICENSE*",
        "mix.exs"
      ],
      maintainers: ["Marc Hayes"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @scm_url
      }
    ]
  end

  defp test_coverage() do
    [
      ignore_modules: [AhoCorasickNif.NifBridge],
      summary: [threshold: 80]
    ]
  end
end
