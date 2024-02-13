defmodule Potatoes.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PotatoesWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:potatoes, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Potatoes.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Potatoes.Finch},
      # Start a worker by calling: Potatoes.Worker.start_link(arg)
      # {Potatoes.Worker, arg},
      # Start to serve requests, typically the last entry
      PotatoesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Potatoes.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PotatoesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
