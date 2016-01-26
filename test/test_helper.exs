ExUnit.start

Mix.Task.run "ecto.create", ~w(-r LumPatternsWeb.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r LumPatternsWeb.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(LumPatternsWeb.Repo)

