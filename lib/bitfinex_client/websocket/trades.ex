defmodule BitfinexClient.Websocket.Trades do
  @moduledoc """
  Handling the Bitfinex trades websocket endpoint

  https://docs.bitfinex.com/reference/ws-public-trades
  """

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

  @doc """
  Starts a PubSub process linked to the current process

  ## Examples
      iex> BitfinexClient.Websocket.Trades.start_link()
      ...> |> elem(0)
      :ok
  """
  @spec start_link(list()) :: {:ok, pid} | {:error, integer(), binary()}
  def start_link(opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@start_link_opts_default, opts)

    WebSockex.start_link(
      @stream_endpoint,
      __MODULE__,
      %{pub_sub_name: pub_sub_name}
    )
    |> Connection.manage()
  end

  @doc """
  Connection handling, part of the WebSockex spec
  """
  @spec handle_connect(any(), map()) :: {:ok, map()}
  def handle_connect(_conn, state) do
    {:ok, state}
  end

  @doc """
  Subscribe to a topic, will send messages to the pid

  ## Examples
      iex> BitfinexClient.Websocket.Trades.subscribe(self())
      :ok
  """
  @spec subscribe(pid()) :: :ok
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

  @doc """
  When data is being received by Bitfinex, it is being dispatched to
  BitfinexClient.Websocket.Trades.Handler, or being logged to the console
  if of an unknown format
  """
  @spec handle_frame(any(), any()) :: {:ok, any()}
  def handle_frame({_type, msg}, %{pub_sub_name: pub_sub_name} = state) do
    Jason.decode!(msg)
    |> Handler.manage_frame(pub_sub_name: pub_sub_name)

    {:ok, state}
  end

  def handle_frame(_, state) do
    Logger.warning("unknown frame type")

    {:ok, state}
  end

  @doc """
  Called by Websockex when its process gets terminated, most probably by an error
  """
  def terminate(reason, state) do
    IO.puts("Socket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")

    exit(:normal)
  end
end
