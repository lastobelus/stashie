defmodule Stashie.Router do
  use Plug.Router
  require Logger

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded, :multipart]
  plug :dispatch

  get "/" do
    handle_save(conn, conn.params)
  end

  post "/save" do
    handle_save(conn, conn.params)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp handle_save(conn, %{"p" => path, "c" => content} = params) do
    desc = Map.get(params, "d", "(no description)")

    target = Path.expand("snippets/\#{path}")
    File.mkdir_p!(Path.dirname(target))

    case File.write(target, content) do
      :ok ->
        Logger.info("Saved: \#{path} — \#{desc}")
        send_resp(conn, 200, "Saved \#{path}\n\n\#{desc}\n")

      {:error, reason} ->
        Logger.error("Failed to save \#{path}: \#{inspect(reason)}")
        send_resp(conn, 500, "Error saving file: \#{inspect(reason)}")
    end
  end

  defp handle_save(conn, _params) do
    send_resp(conn, 400, "Missing required parameters: p and c")
  end
end
