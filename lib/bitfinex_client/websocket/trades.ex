defmodule BitfinexClient.Websocket.Trades do
  use WebSockex

  require Logger

  alias BitfinexClient.Websocket.Trades.Handler
  alias BitfinexClient.Connection

  @stream_endpoint "wss://api.bitfinex.com/ws/1"

  @start_link_opts_default pub_sub_name: PubSub

  @query %{
    event: "subscribe",
    channel: "trades",
    symbol: "tBTCUSD"
  }

  def start_link(opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@start_link_opts_default, opts)

    WebSockex.start_link(
      @stream_endpoint,
      __MODULE__,
      %{pub_sub_name: pub_sub_name}
    )
    |> Connection.manage()
  end

  def handle_connect(_conn, state) do
    {:ok, state}
  end

  def subscribe(pid) do
    query_json = Jason.encode!(@query)

    WebSockex.cast(pid, {:send_message, query_json})
  end

  def handle_cast({:send_message, subscription_json}, state) do
    {:reply, {:text, subscription_json}, state}
  end

  def handle_cast(_, state) do
    Logger.warning("Unknown cast...")

    {:noreply, state}
  end

  def handle_frame({_type, msg}, %{pub_sub_name: pub_sub_name} = state) do
    Jason.decode!(msg)
    |> Handler.manage_frame(pub_sub_name)

    {:ok, state}
  end

  def handle_frame(_, state) do
    Logger.warning("unknown frame type")

    {:ok, state}
  end

  def terminate(reason, state) do
    IO.puts("Socket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")

    exit(:normal)
  end

  def manage_frame(frame, state) do
    Handler.manage_frame(frame, nil)

    {:ok, state}
  end
end
