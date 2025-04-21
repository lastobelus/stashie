defmodule Stashie do
  @moduledoc false

  def start do
    IO.puts("Starting Stashie on http://localhost:4000")
    Plug.Cowboy.http(Stashie.Router, [], port: 4000)
  end
end
