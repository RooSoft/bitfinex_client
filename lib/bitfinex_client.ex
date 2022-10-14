defmodule BitfinexClient do
  @moduledoc """
  Useful to get up to date or realtime BTCUSD prices from Bitfinex

  Based on their V2 API: https://docs.bitfinex.com/docs
  """

  require Logger

  alias BitfinexClient.Websocket.Trades

  @doc """
  Connects to Bitfinex's ticker websocket and sends realtime prices in the form
  of messages to the current process
  """
  @spec start_btc_usd_ticker() :: :ok | {:error, binary()}
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
