defmodule BitfinexClient.PubSub do
  @start_link_opts_default name: PubSub
  @subscribe_opts_default name: PubSub

  @doc """
  Starts the PubSub manager
  """
  def start_link(opts \\ []) do
    [name: name] = Keyword.merge(@start_link_opts_default, opts)

    Registry.start_link(keys: :unique, name: name)
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
    [name: name] = Keyword.merge(@subscribe_opts_default, opts)

    Registry.register(name, topic, %{})
  end

  def publish(name, topic, message) do
    Registry.dispatch(name, topic, fn subscribers ->
      for {pid, _} <- subscribers, do: send(pid, message)
    end)
  end
end
