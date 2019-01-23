defmodule Checksum.Engine do
  @moduledoc """
  A GenServer template.
  """

  use GenServer
  require Integer

  # Initialization

  @spec start_link(list()) :: {:error, any()} | {:ok, pid()}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, 0, opts)
  end

  @spec init(number()) :: {:ok, number()}
  def init(state), do: {:ok, state}

  # API

  def add(_pid, value) when not is_integer(value), do: {:error, :only_integers}
  def add(_pid, value) when value < 0, do: {:error, :no_negative_values}
  def add(pid, value), do: GenServer.call(pid, {:add, value})

  def clear(pid), do: GenServer.call(pid, :clear)
  def get(pid), do: GenServer.call(pid, :get)
  def checksum(pid), do: GenServer.call(pid, :checksum)

  # Callbacks

  def handle_call({:add, value}, _from, state) do
    digits = :math.log10(value + 1) |> Float.ceil() |> Kernel.trunc()

    state = state * power_of_ten(digits) + value
    {:reply, :ok, state}
  end

  def handle_call(:clear, _from, _state), do: {:reply, :ok, 0}

  def handle_call(:get, _from, state), do: {:reply, state, state}

  # timeout if < 15ms
  @timeout 15
  def handle_call(:checksum, _from, state) do
    task = Task.async(fn -> calc_checksum(state) end)

    result =
      case Task.yield(task, @timeout) || Task.shutdown(task, :brutal_kill) do
        {:ok, res} -> res
        nil -> {:error, :timeout}
      end

    {:reply, result, state}
  end

  defp calc_checksum(number) do
    {odds, evens} = split(true, number, {0, 0, 0}) |> odds_and_evens()

    (odds * 3 + evens)
      |> Integer.mod(10)
      |> calc_final()
  end

  # Helpers

  defp calc_final(0), do: 0
  defp calc_final(n) when n < 10, do: 10 - n
  defp calc_final(_), do: raise("invalid algorithm state")

  defp split(_, 0, acc), do: acc

  defp split(odd, n, {odds, evens, steps}) do
    reminder = Integer.mod(n, 10)
    {odds, evens} = accumulate(odd, reminder, {odds, evens})
    next_number = Kernel.div(n - reminder, 10)
    split(not odd, next_number, {odds, evens, steps + 1})
  end

  defp accumulate(true, n, {odds, evens}), do: {odds + n, evens}
  defp accumulate(false, n, {odds, evens}), do: {odds, evens + n}

  defp odds_and_evens({odds, evens, steps}) when Integer.is_odd(steps), do: {odds, evens}
  defp odds_and_evens({odds, evens, _steps}), do: {evens, odds}

  # create power_of_ten functions in compile time for calculus optimization
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
