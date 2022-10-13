defmodule BitfinexClient.Websocket.Trades do
  use WebSockex

  require Logger

  alias BitfinexClient.Websocket.Trades.Handler
  alias BitfinexClient.Connection

  @stream_endpoint "wss://api.bitfinex.com/ws/1"

  @query %{
    event: "subscribe",
    channel: "trades",
    symbol: "tBTCUSD"
  }

  def start_link() do
    WebSockex.start_link(
      @stream_endpoint,
      __MODULE__,
      %{}
    )
    |> Connection.manage()
  end

  def handle_connect(_conn, state) do
    Logger.info("Ready")

    {:ok, state}
  end

  def subscribe(pid) do
    query_json = Jason.encode!(@query)

    WebSockex.cast(pid, {:send_message, query_json})

    Logger.debug("BTCUSD subscription attempt")
  end

  def handle_cast({:send_message, subscription_json}, state) do
    Logger.debug("Bitfinex subscribing... to \n#{subscription_json}")

    {:reply, {:text, subscription_json}, state}
  end

  def handle_cast(_, state) do
    Logger.debug("Unknown cast...")

    {:noreply, state}
  end

  def handle_frame({
        :text,
        %{
          "event" => "info",
          "platform" => %{"status" => status},
          "serverId" => _server_id,
          "version" => version
        }
      }) do
    Logger.debug("Received an info frame with status #{status}, version: #{version}")
  end

  def handle_frame({_type, msg}, state) do
    Jason.decode!(msg)
    |> Handler.manage_frame()

    {:ok, state}
  end

  def handle_frame(_, state) do
    Logger.debug("unknown frame type")

    {:ok, state}
  end

  def terminate(reason, state) do
    IO.puts("Socket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")

    exit(:normal)
  end

  def manage_frame(frame, state) do
    Handler.manage_frame(frame)

    {:ok, state}
  end
end
