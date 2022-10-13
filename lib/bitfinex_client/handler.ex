defmodule BitfinexClient.Handler do
  require Logger

  def manage_frame(%{
        "event" => "info",
        "platform" => %{"status" => status},
        "serverId" => _server_id,
        "version" => version
      }) do
    Logger.debug("Received an info frame with status #{status}, version: #{version}")
  end

  def manage_frame(%{
        "chanId" => _,
        "channel" => "trades",
        "event" => "subscribed",
        "pair" => "BTCUSD"
      }) do
    Logger.debug("BTCUSD subscription confirmed")
  end

  def manage_frame(frame) do
    Logger.warning("Received an unknown frame - #{inspect(frame)}")
  end
end
