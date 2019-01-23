defmodule Checksum.Api do
  def checksum() do
    {:ok, Checksum.Engine.checksum(:single_engine)}
  end

  def clear() do
    {:ok, Checksum.Engine.clear(:single_engine)}
  end

  def add(%{"n" => n}) do
    case Integer.parse(n) do
      {num, _} -> {:ok, Checksum.Engine.add(:single_engine, num)}
      _ -> {:error, :invalid_paremeters}
    end
  end
end
