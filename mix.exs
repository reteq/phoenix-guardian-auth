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
    [#mod: {mod(Mix.env), []},
     applications: applications(Mix.env)]
  end

  defp applications(:test), do: applications(:all) ++ [:ex_machina]
  defp applications(_all),  do: [:logger, :phoenix, :cowboy, :gettext,
                                 :phoenix_ecto, :postgrex, :comeonin]

  # defp mod(:test), do: PhoenixGuardianAuthTest
  # defp mod(_other), do: PhoenixGuardianAuth

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
     {:ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:cowboy, "~> 1.0"},
     {:gettext, "~> 0.9"},
     {:guardian, "~> 0.9.0"},
     {:guardian_db, "~> 0.4.0"},
     {:poison, "~> 1.5", override: true},
     {:mailgun, "~> 0.1.1"},
     {:sms, github: "reteq/sms-elixir"},
     {:scrivener, "~> 1.0.0"},
     {:ja_serializer, "~> 0.8.1"},
     {:mock, "~> 0.1.0", only: :test},
     {:ex_machina, "~> 0.6.1", only: :test},
     {:secure_random, "~> 0.2"},
     {:joken, "~> 1.0.0"},
     {:apex, "~> 0.3.2"},
     {:comeonin, "~> 2.0.0"}
    ]
  end
end
