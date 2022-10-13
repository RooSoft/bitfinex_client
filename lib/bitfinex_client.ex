defmodule BitfinexClient do
  require Logger

  alias BitfinexClient.Websocket.Trades

  def btc_usd_ticker_subscription() do
    case Trades.start_link() do
      {:ok, websocket_pid} ->
        Trades.subscribe(websocket_pid)
        :ok

      {:error, message} ->
        {:error, message}
    end
  end
end
