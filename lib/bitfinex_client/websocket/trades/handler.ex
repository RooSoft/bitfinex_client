defmodule BitfinexClient.Websocket.Trades.Handler do
  require Logger

  alias BitfinexClient.PubSub

  ## trade execution
  @doc """
  Dispatches trade frames received by the Bitfinex websocket

  ## Examples
    iex> pub_sub_name = :manage_frame_doctest
    ...> BitfinexClient.PubSub.start_link(name: pub_sub_name)
    ...> BitfinexClient.PubSub.subscribe(:btc_usd_ticker, name: pub_sub_name)
    ...> [473431, "te", "1227389557-tBTCUSD", 1665749864, 19630, -0.00204594]
    ...> |> BitfinexClient.Websocket.Trades.Handler.manage_frame(pub_sub_name)
    ...> receive do
    ...>   frame -> frame
    ...> end
    19630
  """
  def manage_frame([_, "te", _, _amount, price, _rate], pubs_sub_name) do
    PubSub.publish(pubs_sub_name, :btc_usd_ticker, price)

    :trade_execution
  end

  # a trade update, example:
  # [473431, "tu", "1227389557-tBTCUSD", 1227389557, 1665749864, 19630, -0.00204594]
  def manage_frame([_, "tu", _, _amount, _trade_id, price, _rate], pubs_sub_name) do
    PubSub.publish(pubs_sub_name, :btc_usd_ticker, price)

    :trade_update
  end

  # a trade batch
  # see tests for examples
  def manage_frame([_id, batch], pubs_sub_name) when is_list(batch) do
    [_, _, price, _value] = List.first(batch)

    PubSub.publish(pubs_sub_name, :btc_usd_ticker, price)

    :trade_batch
  end

  def manage_frame([_id, "hb"], _pub_sub_name) do
    # nothing to do, this is a heartbeat
    :heartbeat
  end

  def manage_frame(
        %{
          "event" => "info",
          "platform" => %{"status" => status},
          "serverId" => server_id,
          "version" => version
        },
        _pub_sub_name
      ) do
    # info, nothing to do
    {
      :ok,
      %{
        status: status,
        server_id: server_id,
        version: version
      }
    }
  end

  def manage_frame(
        %{
          "chanId" => _,
          "channel" => "trades" = channel,
          "event" => "subscribed" = event,
          "pair" => "BTCUSD" = pair
        },
        _pub_sub_name
      ) do
    # BTCUSD subscription confirmed, nothing to do
    {
      :ok,
      %{
        channel: channel,
        event: event,
        pair: pair
      }
    }
  end

  def manage_frame(unknown_frame, _pub_sub_name) do
    Logger.debug("Received an unknown frame")
    IO.inspect(unknown_frame)
  end
end
