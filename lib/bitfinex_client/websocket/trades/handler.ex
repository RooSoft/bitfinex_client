defmodule BitfinexClient.Websocket.Trades.Handler do
  require Logger

  ## trade execution
  def manage_frame([_, "te", _, _amount, price, _rate]) do
    Logger.debug("[execution] #{price}")
  end

  ## trade update
  def manage_frame([_, "tu", _, _amount, _trade_id, price, _rate]) do
    Logger.debug("[update] #{price}")
  end

  ## trade batch
  def manage_frame([_id, batch]) when is_list(batch) do
    Logger.debug("received a price batch")

    [_, _, price, _value] = List.last(batch)

    Logger.debug("[last] #{price}")
  end

  def manage_frame([_id, "hb"]) do
    Logger.debug("received a hb frame")
  end

  def manage_frame(unknown_frame) do
    Logger.debug("Received an unknown frame")
    IO.inspect(unknown_frame)
  end
end
