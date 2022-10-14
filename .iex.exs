alias BitfinexClient.PubSub
alias BitfinexClient.Http.GetBtcUsdTrades

GetBtcUsdTrades.execute() |> IO.inspect

PubSub.start_link()
PubSub.subscribe(:btc_usd_ticker)

defmodule Printer do
  def get_price() do
    receive do
      x -> IO.inspect x
    end

    get_price()
  end
end

case BitfinexClient.start_btc_usd_ticker() do
  :ok -> Printer.get_price()
  {:error, message} -> IO.puts message
end
