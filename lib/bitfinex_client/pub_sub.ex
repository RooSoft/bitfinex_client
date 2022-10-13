defmodule BitfinexClient.PubSub do
  def start_link() do
    Registry.start_link(keys: :unique, name: PubSub)
  end

  def subscribe(topic) do
    Registry.register(PubSub, topic, %{})
  end

  def publish(topic, message) do
    Registry.dispatch(PubSub, topic, fn subscribers ->
      for {pid, _} <- subscribers, do: send(pid, message)
    end)
  end
end
