defmodule BitfinexClient.Websocket.Trades.Handler do
  require Logger

  alias BitfinexClient.PubSub

  ## trade execution
  @doc """
  Dispatches trade frames received by the Bitfinex websocket

  ## Examples
    iex> BitfinexClient.PubSub.start_link()
    ...> BitfinexClient.PubSub.subscribe(:btc_usd_ticker)
    ...> [473431, "te", "1227389557-tBTCUSD", 1665749864, 19630, -0.00204594]
    ...> |> BitfinexClient.Websocket.Trades.Handler.manage_frame
    ...> receive do
    ...>   frame -> frame
    ...> end
    19630
  """
  def manage_frame([_, "te", _, _amount, price, _rate]) do
    PubSub.publish(:btc_usd_ticker, price)

    :trade_execution
  end

  # a trade update, example:
  # [473431, "tu", "1227389557-tBTCUSD", 1227389557, 1665749864, 19630, -0.00204594]
  def manage_frame([_, "tu", _, _amount, _trade_id, price, _rate]) do
    PubSub.publish(:btc_usd_ticker, price)

    :trade_update
  end

  # a trade batch
  # see tests for examples
  def manage_frame([_id, batch]) when is_list(batch) do
    [_, _, price, _value] = List.first(batch)

    PubSub.publish(:btc_usd_ticker, price)

    :trade_batch
  end

  def manage_frame([_id, "hb"]) do
    # nothing to do, this is a heartbeat
    :heartbeat
  end

  def manage_frame(%{
        "event" => "info",
        "platform" => %{"status" => _status},
        "serverId" => _server_id,
        "version" => _version
      }) do
    # info, nothing to do
    :ok
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
