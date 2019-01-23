defmodule Checksum.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @test Application.get_env(:checksum, :test) || false
  @api_port Application.get_env(:checksum, :api_port)

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Checksum.Supervisor]
    children(@test) |> Supervisor.start_link(opts)
  end

  def children(true), do: []

  def children(_) do
    [
      {Checksum.Engine, [name: :single_engine]},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Checksum.Endpoint,
        options: [port: @api_port]
      )
    ]
  end
end
