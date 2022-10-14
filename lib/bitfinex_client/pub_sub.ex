defmodule BitfinexClient.PubSub do
  @moduledoc """
  A way to dispatch messages to multiple recipients, based on topics
  """

  @start_link_opts_default pub_sub_name: PubSub
  @subscribe_opts_default pub_sub_name: PubSub
  @publish_opts_default pub_sub_name: PubSub

  @doc """
  Starts the PubSub manager
  """
  @spec start_link(list()) :: {:ok, pid} | {:error, term}
  def start_link(opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@start_link_opts_default, opts)

    Registry.start_link(keys: :unique, name: pub_sub_name)
  end

  @doc """
  Subscribe the current process to a topic

  ## Examples
      iex> BitfinexClient.PubSub.start_link()
      ...> BitfinexClient.PubSub.subscribe(:btc_usd_ticker)
      ...> |> elem(0)
      :ok
  """
  @spec subscribe(atom(), list()) :: {:ok, pid} | {:error, {:already_registered, pid}}
  def subscribe(topic, opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@subscribe_opts_default, opts)

    Registry.register(pub_sub_name, topic, %{})
  end

  @doc """
  Publishes a message in a specific topic

  ## Examples
      iex> pub_sub_name = :pub_sub_publish_doctest
      ...> BitfinexClient.PubSub.start_link(pub_sub_name: pub_sub_name)
      ...> BitfinexClient.PubSub.subscribe(:btc_usd_ticker, pub_sub_name: pub_sub_name)
      ...> BitfinexClient.PubSub.publish(:btc_usd_ticker, 19565, pub_sub_name: pub_sub_name)
      ...> receive do
      ...>   price -> price
      ...> end
      {:bitfinex, :btc_usd_ticker, 19565}
  """
  @spec publish(atom(), term(), list()) :: :ok
  def publish(topic, message, opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@publish_opts_default, opts)

    encapsulated_message = {
      :bitfinex,
      topic,
      message
    }

    Registry.dispatch(pub_sub_name, topic, fn subscribers ->
      for {pid, _} <- subscribers, do: send(pid, encapsulated_message)
    end)
  end
end
