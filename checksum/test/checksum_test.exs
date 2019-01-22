defmodule ChecksumTest do
  use ExUnit.Case
  use PropCheck

  test "add and get" do
    {:ok, pid} = Checksum.Engine.start_link()
    assert Checksum.Engine.get(pid) == 0

    Checksum.Engine.add(pid, 10)
    assert Checksum.Engine.get(pid) == 10
  end

  test "add and apply more get" do
    {:ok, pid} = Checksum.Engine.start_link()
    Checksum.Engine.add(pid, 10)
    Checksum.Engine.add(pid, 1)

    assert Checksum.Engine.get(pid) == 101
  end

  test "add negative number" do
    {:ok, pid} = Checksum.Engine.start_link()
    Checksum.Engine.add(pid, -2)

    assert Checksum.Engine.get(pid) == 0
  end

  test "add zero series" do
    {:ok, pid} = Checksum.Engine.start_link()
    [2, 1, -2, 3, 10, 0] |> Enum.each(fn n -> Checksum.Engine.add(pid, n) end)

    assert Checksum.Engine.get(pid) == 213100
  end

  test "add and clear" do
    {:ok, pid} = Checksum.Engine.start_link()

    [6, 7, 8, 9, 10] |> Enum.each(fn n -> Checksum.Engine.add(pid, n) end)
    assert Checksum.Engine.get(pid) == 678910

    Checksum.Engine.clear(pid)

    [1, 2, 3, 4, 5] |> Enum.each(fn n -> Checksum.Engine.add(pid, n) end)
    assert Checksum.Engine.get(pid) == 12345
  end

  property "add and get", [:verbose, {:numtests, 10_000}] do

    forall numbers <- list(integer())  do
      {:ok, pid} = Checksum.Engine.start_link()

      :ok = numbers |> Enum.each(fn n -> Checksum.Engine.add(pid, n) end)

      joined =
        numbers
        |> Enum.filter(fn n -> n >= 0 end)
        |> Enum.map(fn n -> Integer.to_string(n) end)
        |> Enum.join()

      verify(Checksum.Engine.get(pid), joined)
    end
  end

  defp verify(0, ""), do: true
  defp verify(_, ""), do: false
  defp verify(computed, expected), do: computed == String.to_integer(expected)
end
