ExUnit.start()

defmodule TestHelper do
  def join_as_number(numbers) when is_list(numbers) do
    numbers
    |> Enum.filter(fn n -> n >= 0 end)
    |> Enum.map(fn n -> Integer.to_string(n) end)
    |> Enum.join()
  end
end
