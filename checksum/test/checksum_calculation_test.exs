defmodule ChecksumCalculationTest do
  use ExUnit.Case
  use PropCheck

  test "add and get checksum" do
    {:ok, pid} = Checksum.Engine.start_link()
    [5, 4, 8, 9, 8, 5, 0, 3, 5, 4] |> Enum.each(fn n -> Checksum.Engine.add(pid, n) end)

    assert Checksum.Engine.checksum(pid) == 7
  end

  @very_big_number 1..100 |> Enum.reduce(1, fn n, acc -> n * acc end)

  test "add big number and get timeout for checksum" do
    {:ok, pid} = Checksum.Engine.start_link()
    1..1000 |> Enum.each(fn _ -> Checksum.Engine.add(pid, @very_big_number) end)

    assert Checksum.Engine.checksum(pid) == {:error, :timeout}
  end

  property "add and get checksum", [:verbose, {:numtests, 10_000}] do
    forall numbers <- list(integer()) do
      {:ok, pid} = Checksum.Engine.start_link()

      :ok = numbers |> Enum.each(fn n -> Checksum.Engine.add(pid, n) end)
      Checksum.Engine.checksum(pid) == calc_checksum(pid, numbers)
    end
  end

  # different (raw and not optimized) algorithm to compare with the production one
  defp calc_checksum(pid, numbers) when is_list(numbers) do
    {odds, evens} =
      Checksum.Engine.get(pid)
      |> Integer.to_string()
      |> String.graphemes()
      |> Enum.map(fn n -> String.to_integer(n) end)
      |> Enum.chunk_every(2)
      |> Enum.reduce({0, 0}, fn
        [o, e], {odds, evens} -> {odds + o, evens + e}
        [o], {odds, evens} -> {odds + o, evens}
      end)

    case (odds * 3 + evens) |> Integer.mod(10) do
      0 -> 0
      n -> 10 - n
    end
  end
end
