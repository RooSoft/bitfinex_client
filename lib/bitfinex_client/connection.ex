defmodule BitfinexClient.Connection do
  require Logger

  def manage({:ok, pid}) do
    Logger.debug("OK Connection")

    {:ok, pid}
  end

  def manage({:error, %WebSockex.RequestError{code: 503}}) do
    Logger.debug("KO Connection: Bitfinex is down")

    {:error, 1, "Bitfinex is down"}
  end

  def manage({:error, %WebSockex.ConnError{original: :timeout}}) do
    Logger.debug("KO Connection: Bitfinex timeout")

    {:error, 2, "Bitfinex timeout"}
  end

  def manage({:error, error}) do
    Logger.debug("KO Connection: Bitfinex unknown error \n#{inspect(error)}")

    {:error, 255, "Bitfinex unknown error \n#{inspect(error)}"}
  end
end
