defmodule PhoenixGuardianAuth.Mixfile do
  use Mix.Project

  def project do
    [app: :phoenix_guardian_auth,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:phoenix, "~> 1.1"},
     {:phoenix_ecto, "~> 2.0"},
     {:guardian, "~> 0.9.0"},
     {:guardian_db, "~> 0.4.0"},
     {:poison, "~> 1.5", override: true},
     {:mailgun, "~> 0.1.1"},
     {:scrivener, "~> 1.0.0"},
     {:ja_serializer, "~> 0.6.0"},
     {:mock, "~> 0.1.0", only: :test},
     {:secure_random, "~> 0.2"},
     {:joken, "~> 1.0.0"},
     {:comeonin, "~> 2.0.0"}
    ]
  end
end
