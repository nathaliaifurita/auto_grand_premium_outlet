defmodule AutoGrandPremiumOutlet.Release do
    @moduledoc """
    Tasks to be executed in production releases.
    """
  
    def migrate do
      load_app()
  
      for repo <- repos() do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      end
    end
  
    def rollback(repo, version) do
      load_app()
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    end
  
    defp repos do
      Application.fetch_env!(:auto_grand_premium_outlet, :ecto_repos)
    end
  
    defp load_app do
      Application.load(:auto_grand_premium_outlet)
    end
  end
  