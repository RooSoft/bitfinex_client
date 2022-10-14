defmodule BitfinexClient.Websocket.Trades.Handler do
  require Logger

  alias BitfinexClient.PubSub

  ## trade execution
  def manage_frame([_, "te", _, _amount, price, _rate]) do
    PubSub.publish(:btc_usd_ticker, price)
  end

  ## trade update
  def manage_frame([_, "tu", _, _amount, _trade_id, price, _rate]) do
    PubSub.publish(:btc_usd_ticker, price)
  end

  ## trade batch
  def manage_frame([_id, batch]) when is_list(batch) do
    [_, _, price, _value] = List.last(batch)

    PubSub.publish(:btc_usd_ticker, price)
  end

  def manage_frame([_id, "hb"]) do
    # nothing to do, this is a heartbeat
  end

  def manage_frame(%{
        "event" => "info",
        "platform" => %{"status" => _status},
        "serverId" => _server_id,
        "version" => _version
      }) do
    # info, nothing to do
  end

  def manage_frame(%{
        "chanId" => _,
        "channel" => "trades",
        "event" => "subscribed",
        "pair" => "BTCUSD"
      }) do
    # BTCUSD subscription confirmed, nothing to do
  end

  def manage_frame(unknown_frame) do
    Logger.debug("Received an unknown frame")
    IO.inspect(unknown_frame)
  end
end
