defmodule BitfinexClient.Http.GetBtcusdTrades do
  @moduledoc """
  Handles HTTP requests to the endpoint documented here:

  https://docs.bitfinex.com/reference/rest-public-ticker
  """

  require Logger

  @btcusd_ticker_url "https://api-pub.bitfinex.com/v2/ticker/tBTCUSD"

  @doc """
  Sends the HTTP request to get the current BTCUSD ticker value
  """
  @spec execute() :: {:ok, integer} | {:error, integer()} | {:error, binary()}
  def execute do
    case HTTPoison.get(@btcusd_ticker_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        price = parse_current_btcusd_price!(body)

        {:ok, price}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, 404}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp parse_current_btcusd_price!(ticker_body) do
    [
      _bid,
      _bid_size,
      _ask,
      _ask_size,
      _daily_change,
      _daily_change_relative,
      last_price,
      _volume,
      _high,
      _low
    ] = Jason.decode!(ticker_body)

    last_price
  end
end
