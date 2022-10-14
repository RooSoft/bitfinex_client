defmodule BitfinexClient.Websocket.Trades.HandlerTest do
  use ExUnit.Case

  doctest BitfinexClient.Websocket.Trades.Handler

  alias BitfinexClient.PubSub
  alias BitfinexClient.Websocket.Trades.Handler

  test "a trade execution" do
    PubSub.start_link()
    PubSub.subscribe(:btc_usd_ticker)

    result =
      [473_431, "te", "1227389557-tBTCUSD", 1_665_749_864, 19630, -0.00204594]
      |> Handler.manage_frame()

    price =
      receive do
        frame -> frame
      end

    assert :trade_execution == result
    assert 19630 == price
  end

  test "a trade update" do
    PubSub.start_link()
    PubSub.subscribe(:btc_usd_ticker)

    result =
      [473_431, "tu", "1227389557-tBTCUSD", 1_227_389_557, 1_665_749_864, 19630, -0.00204594]
      |> Handler.manage_frame()

    price =
      receive do
        frame -> frame
      end

    assert :trade_update = result
    assert 19630 == price
  end

  test "a trade batch" do
    PubSub.start_link()
    PubSub.subscribe(:btc_usd_ticker)

    result =
      [
        473_431,
        [
          ["1227389446-tBTCUSD", 1_665_749_498, 19646, -6.557e-5],
          ["1227389444-tBTCUSD", 1_665_749_466, 19643, 1.9871e-4],
          ["1227389440-tBTCUSD", 1_665_749_455, 19648, -0.005],
          ["1227389439-tBTCUSD", 1_665_749_450, 19647, -0.00374],
          ["1227389438-tBTCUSD", 1_665_749_450, 19647, -0.00126],
          ["1227389422-tBTCUSD", 1_665_749_444, 19653, 0.005],
          ["1227389420-tBTCUSD", 1_665_749_435, 19654, 0.005],
          ["1227389419-tBTCUSD", 1_665_749_430, 19651, -8.721e-5],
          ["1227389415-tBTCUSD", 1_665_749_409, 19659, 0.30621391],
          ["1227389414-tBTCUSD", 1_665_749_409, 19659, 1.3959],
          ["1227389413-tBTCUSD", 1_665_749_409, 19658, 0.079],
          ["1227389412-tBTCUSD", 1_665_749_409, 19658, 0.08420804],
          ["1227389411-tBTCUSD", 1_665_749_409, 19657, 0.25],
          ["1227389410-tBTCUSD", 1_665_749_409, 19657, 0.35],
          ["1227389409-tBTCUSD", 1_665_749_409, 19656, 0.9],
          ["1227389408-tBTCUSD", 1_665_749_409, 19656, 0.08433404],
          ["1227389407-tBTCUSD", 1_665_749_409, 19655, 0.0774],
          ["1227389406-tBTCUSD", 1_665_749_409, 19655, 0.52147159],
          ["1227389405-tBTCUSD", 1_665_749_409, 19655, 0.33180581],
          ["1227389404-tBTCUSD", 1_665_749_409, 19655, 0.51027461],
          ["1227389403-tBTCUSD", 1_665_749_409, 19654, 0.00126],
          ["1227389402-tBTCUSD", 1_665_749_409, 19653, 0.108132],
          ["1227389401-tBTCUSD", 1_665_749_408, 19655, -0.1],
          ["1227389400-tBTCUSD", 1_665_749_408, 19656, -0.00126],
          ["1227389399-tBTCUSD", 1_665_749_405, 19660, 0.0029],
          ["1227389398-tBTCUSD", 1_665_749_405, 19660, 0.002],
          ["1227389397-tBTCUSD", 1_665_749_405, 19660, 0.0001],
          ["1227389395-tBTCUSD", 1_665_749_399, 19659, 0.01756],
          ["1227389394-tBTCUSD", 1_665_749_399, 19658, 0.002],
          ["1227389393-tBTCUSD", 1_665_749_399, 19657, 0.001]
        ]
      ]
      |> Handler.manage_frame()

    price =
      receive do
        batch -> batch
      end

    assert :trade_batch == result
    assert 19646 == price
  end

  test "a heartbeat" do
    PubSub.start_link()
    PubSub.subscribe(:btc_usd_ticker)

    result =
      [292_447, "hb"]
      |> Handler.manage_frame()

    assert :heartbeat == result
  end
end
