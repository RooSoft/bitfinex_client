defmodule BitfinexClient.Connection do
  @moduledoc """
  Handle messages received when a new connection is established to Bitfinex
  """
  require Logger

  @doc """
  Converts a Websockex start_link result into something more in line with this lib's context
  """
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
