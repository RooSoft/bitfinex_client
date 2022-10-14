defmodule BitfinexClient.PubSub do
  @start_link_opts_default pub_sub_name: PubSub
  @subscribe_opts_default pub_sub_name: PubSub
  @publish_opts_default pub_sub_name: PubSub

  @doc """
  Starts the PubSub manager
  """
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
  def subscribe(topic, opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@subscribe_opts_default, opts)

    Registry.register(pub_sub_name, topic, %{})
  end

  def publish(topic, message, opts \\ []) do
    [pub_sub_name: pub_sub_name] = Keyword.merge(@publish_opts_default, opts)

    Registry.dispatch(pub_sub_name, topic, fn subscribers ->
      for {pid, _} <- subscribers, do: send(pid, message)
    end)
  end
end
