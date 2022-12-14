defmodule BitfinexClient.Websocket.Trades.HandlerTest do
  use ExUnit.Case, async: true

  doctest BitfinexClient.Websocket.Trades.Handler

  alias BitfinexClient.PubSub
  alias BitfinexClient.Websocket.Trades.Handler

  test "a trade execution" do
    pub_sub_name = :trade_execution
    PubSub.start_link(pub_sub_name: pub_sub_name)
    PubSub.subscribe(:btc_usd_ticker, pub_sub_name: pub_sub_name)

    result =
      [473_431, "te", "1227389557-tBTCUSD", 1_665_749_864, 19630, -0.00204594]
      |> Handler.manage_frame(pub_sub_name: pub_sub_name)

    ticker =
      receive do
        frame -> frame
      end

    assert :trade_execution == result
    assert {:bitfinex, :btc_usd_ticker, 19630} == ticker
  end

  test "a trade update" do
    pub_sub_name = :trade_update
    PubSub.start_link(pub_sub_name: pub_sub_name)
    PubSub.subscribe(:btc_usd_ticker, pub_sub_name: pub_sub_name)

    result =
      [473_431, "tu", "1227389557-tBTCUSD", 1_227_389_557, 1_665_749_864, 19630, -0.00204594]
      |> Handler.manage_frame(pub_sub_name: pub_sub_name)

    ticker =
      receive do
        frame -> frame
      end

    assert :trade_update = result
    assert {:bitfinex, :btc_usd_ticker, 19630} == ticker
  end

  test "a trade batch" do
    pub_sub_name = :trade_batch

    PubSub.start_link(pub_sub_name: pub_sub_name)
    PubSub.subscribe(:btc_usd_ticker, pub_sub_name: pub_sub_name)

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
      |> Handler.manage_frame(pub_sub_name: pub_sub_name)

    ticker =
      receive do
        batch -> batch
      end

    assert :trade_batch == result
    assert {:bitfinex, :btc_usd_ticker, 19646} == ticker
  end

  test "a heartbeat" do
    result =
      [292_447, "hb"]
      |> Handler.manage_frame()

    assert :heartbeat == result
  end

  test "an info event" do
    result =
      %{
        "event" => "info",
        "platform" => %{"status" => 1},
        "serverId" => "ec9d43cd-9235-42cd-aa53-3ad432214b64",
        "version" => 1.1
      }
      |> Handler.manage_frame()

    assert {
             :ok,
             %{
               status: 1,
               server_id: "ec9d43cd-9235-42cd-aa53-3ad432214b64",
               version: 1.1
             }
           } == result
  end

  test "a subscription" do
    result =
      %{
        "chanId" => 585_878,
        "channel" => "trades",
        "event" => "subscribed",
        "pair" => "BTCUSD"
      }
      |> Handler.manage_frame()

    assert {
             :ok,
             %{
               channel: "trades",
               event: "subscribed",
               pair: "BTCUSD"
             }
           } == result
  end
end
