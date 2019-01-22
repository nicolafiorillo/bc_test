defmodule Checksum.Engine do
  @moduledoc """
  A GenServer template.
  """

  use GenServer

  # Initialization

  @spec start_link(list()) :: {:error, any()} | {:ok, pid()}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, 0, opts)
  end

  @spec init(number()) :: {:ok, number()}
  def init(state), do: {:ok, state}

  # API

  def add(_pid, value) when not is_integer(value), do: IO.inspect {:error, :only_integers}
  def add(_pid, value) when value < 0, do: {:error, :no_negative_values}
  def add(pid, value), do: GenServer.call(pid, {:add, value})

  def clear(pid), do: GenServer.call(pid, :clear)
  def get(pid), do: GenServer.call(pid, :get)

  # Callbacks

  def handle_call({:add, value}, _from, state) do
    digits = :math.log10(value + 1) |> Float.ceil() |> Kernel.trunc()

    state = state * power_of_ten(digits) + value
    {:reply, :ok, state}
  end

  def handle_call(:clear, _from, _state), do: {:reply, :ok, 0}

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  # Helpers

  # create power_of_ten functions in compile time for calcolus optimization
  @spec power_of_ten(number()) :: number()
  defp power_of_ten(0), do: 10
  1..1000
    |> Enum.each(fn n ->
      quote do
        defp power_of_ten(unquote(n)) do
          unquote do
            String.pad_trailing("1", n + 1, "0") |> String.to_integer()
          end
        end
      end
    end)
  defp power_of_ten(digits), do: String.pad_trailing("1", digits + 1, "0") |> String.to_integer()
end
