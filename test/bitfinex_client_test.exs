defmodule BitfinexClientTest do
  use ExUnit.Case
  doctest BitfinexClient

  test "greets the world" do
    assert BitfinexClient.hello() == :world
  end
end
