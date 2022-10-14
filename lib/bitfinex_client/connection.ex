defmodule BitfinexClient.Connection do
  require Logger

  def manage({:ok, pid}) do
    {:ok, pid}
  end

  def manage({:error, %WebSockex.RequestError{code: 503}}) do
    {:error, 1, "Bitfinex is down"}
  end

  def manage({:error, %WebSockex.ConnError{original: :timeout}}) do
    {:error, 2, "Bitfinex timeout"}
  end

  def manage({:error, error}) do
    {:error, 255, "Bitfinex unknown error \n#{inspect(error)}"}
  end
end
