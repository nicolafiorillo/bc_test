defmodule Checksum.Endpoint do
  use Plug.Router

  alias Checksum.Api

  plug(Plug.Logger)

  plug(Plug.Parsers, parsers: [:urlencoded, :multipart, :json], pass: ["*/*"], json_decoder: Jason)

  plug(:match)
  plug(:dispatch)

  # Eg:
  #   curl "http://localhost:4000/checksum"
  get "/checksum" do
    {http_res, data} = Api.checksum() |> to_http_res()
    send_resp(conn, http_res, data |> Jason.encode!(escape: :javascript_safe))
  end

  # Eg:
  #   curl -X POST "http://localhost:4000/clear"
  post "/clear" do
    {http_res, data} = Api.clear() |> to_http_res()
    send_resp(conn, http_res, data |> Jason.encode!(escape: :javascript_safe))
  end

  # Eg:
  #   curl -X POST "http://localhost:4000/add" -d 'n=123'
  post "/add" do
    {http_res, data} = conn.body_params |> Api.add() |> to_http_res()
    send_resp(conn, http_res, data |> Jason.encode!(escape: :javascript_safe))
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp to_http_res({:ok, data}), do: {200, data}
  defp to_http_res({:error, :invalid_parameters}), do: {400, "invalid parameters"}
end
