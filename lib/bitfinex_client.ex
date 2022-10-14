defmodule BitfinexClient do
  require Logger

  alias BitfinexClient.Websocket.Trades

  def start_btc_usd_ticker() do
    case Trades.start_link() do
      {:ok, websocket_pid} ->
        Trades.subscribe(websocket_pid)
        :ok

      {:error, message, _} ->
        {:error, message}
    end
  end
end
