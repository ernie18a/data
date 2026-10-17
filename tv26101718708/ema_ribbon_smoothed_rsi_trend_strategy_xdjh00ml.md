# EMA Ribbon + Smoothed RSI Trend Strategy

- url: https://www.tradingview.com/script/xDJH00mL-EMA-Ribbon-Smoothed-RSI-Trend-Strategy/
- type: strategy
- pine_id: PUB;e36d9dada0a3478fb542099a8530e8b7
- version: 1.0

## Description

EMA Ribbon Trend Filter + Smoothed RSI Entry Strategy

BEST IS 1/1RR

Overview
This strategy combines a moving-average trend filter with a smoothed RSI trigger to time entries in the direction of an established trend, with stop-loss levels placed at real market structure rather than a fixed distance.
How it works
1. Trend Filter (Ribbon)
An EMA(10) and EMA(20) are plotted on the chart. The strategy only considers trades when EMA(10) is above EMA(20) — treated here as confirmation of underlying bullish structure. Two additional SMAs (20/50) are plotted alongside for visual context but aren't part of the trade logic.
2. Entry Trigger — Smoothed RSI
Rather than using raw RSI, this script smooths RSI(21) with a 50-period SMA. That smoothed line is the actual decision value:
Crosses above 51 → long signal
Crosses below 49 → short signal
Smoothing the RSI this way filters out a lot of the noise a raw RSI produces, at the cost of some lag.
3. Structure-Based Stop Loss
Instead of a fixed pip/point stop, SL is placed at the nearest swing low (for longs) or swing high (for shorts) over a configurable lookback window, plus a small buffer. Take-profit is set as a configurable risk:reward multiple of that stop distance.
4. Trade Visualization
Every trade taken draws two boxes on the chart: a green "profit zone" from entry to TP, and a red "risk zone" from entry to SL. These extend in real time while the trade is open, so you can see the live risk/reward geometry of each position at a glance.
5. Non-Repainting
Signals only evaluate on confirmed, closed bars (barstate.isconfirmed), so what you see in the backtest is what would have fired in real time — no mid-bar flip-flopping.
Inputs
EMA/SMA ribbon lengths (default 10/20/20/50)
RSI length and smoothing length (default 21 / 50)
Buy/sell trigger levels (default 51 / 49)
Cross-only trigger toggle
Swing lookback, SL buffer, minimum SL distance
Risk:reward ratio 1/1 IS BEST
Box colors and visibility toggle
Optional date range filter for backtesting
Alerts
Built-in alertcondition() calls for both long and short signals, ready to connect to a webhook or notification service if you want to act on signals outside of TradingView.
⚠️ Disclaimer: This script is provided for educational and informational purposes only. Past performance shown in backtests does not guarantee future results. Backtest results can be affected by commission/slippage assumptions and do not account for real-world execution factors such as liquidity and order rejection. This is not financial advice — use proper risk management and test thoroughly before trading with real capital.

## Source Code

````pine
//@version=6
strategy("EMA Ribbon + Smoothed RSI Trend Strategy", overlay=true,
     initial_capital=10000, default_qty_type=strategy.percent_of_equity,
     default_qty_value=100, commission_type=strategy.commission.percent,
     commission_value=0.02, process_orders_on_close=true)

// ============================== INPUTS ==============================
grpTrend = "Trend Filter (Ribbon)"
emaFastLen = input.int(10, "EMA Fast (white)", group=grpTrend)
emaSlowLen = input.int(20, "EMA Slow (yellow)", group=grpTrend)
smaFastLen = input.int(20, "SMA Fast (ribbon, cosmetic only)", group=grpTrend)
smaSlowLen = input.int(50, "SMA Slow (ribbon, cosmetic only)", group=grpTrend)

grpRsi = "RSI Trigger"
rsiLen        = input.int(21, "RSI Length", group=grpRsi)
rsiSmoothLen  = input.int(50, "RSI Smoothing SMA Length (the deciding yellow line)", group=grpRsi)
buyLevel      = input.float(51.0, "Buy Level", group=grpRsi)
sellLevel     = input.float(49.0, "Sell Level", group=grpRsi)
requireCross  = input.bool(true, "Only trigger on cross of the level (vs. staying above/below)", group=grpRsi)

grpRisk = "Stop Loss / Take Profit"
swingLookback = input.int(20, "Swing Lookback (bars)", group=grpRisk)
slBufferTicks = input.float(5, "SL Buffer (ticks)", group=grpRisk)
minSlTicks    = input.float(20, "Minimum SL Distance (ticks)", group=grpRisk)
rr            = input.float(2.0, "Risk : Reward Ratio", group=grpRisk)

grpBox = "Trade Boxes"
showBoxes   = input.bool(true, "Draw entry/SL/TP boxes", group=grpBox)
profitColor = input.color(color.new(color.green, 75), "Profit zone color", group=grpBox)
riskColor   = input.color(color.new(color.red, 75), "Risk zone color", group=grpBox)

grpDate = "Backtest Window"
useDateFilter = input.bool(false, "Limit backtest to date range", group=grpDate)
startDate     = input.time(timestamp("2024-01-01"), "Start", group=grpDate)
endDate       = input.time(timestamp("2026-12-31"), "End", group=grpDate)
inDateRange   = not useDateFilter or (time >= startDate and time <= endDate)

// ============================== INDICATORS ==============================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
smaFast = ta.sma(close, smaFastLen)
smaSlow = ta.sma(close, smaSlowLen)

plot(emaFast, "EMA Fast", color=color.white, linewidth=2)
plot(emaSlow, "EMA Slow", color=color.yellow, linewidth=2)
plot(smaFast, "SMA Fast", color=color.new(color.orange, 40))
plot(smaSlow, "SMA Slow", color=color.new(color.orange, 70))

rsiRaw    = ta.rsi(close, rsiLen)
rsiSmooth = ta.sma(rsiRaw, rsiSmoothLen)   // this is the deciding value, not raw RSI

trendUp = emaFast > emaSlow   // required for BOTH long and short, per spec

crossedUpBuy    = ta.crossover(rsiSmooth, buyLevel)
crossedDownSell = ta.crossunder(rsiSmooth, sellLevel)

longSignal  = trendUp and inDateRange and barstate.isconfirmed and (requireCross ? crossedUpBuy    : rsiSmooth > buyLevel)
shortSignal = trendUp and inDateRange and barstate.isconfirmed and (requireCross ? crossedDownSell : rsiSmooth < sellLevel)

// ============================== SWING STRUCTURE ==============================
swingLow  = ta.lowest(low, swingLookback)
swingHigh = ta.highest(high, swingLookback)

tick = syminfo.mintick

// ============================== TRADE STATE / BOXES ==============================
var box profitBoxLong  = na
var box riskBoxLong    = na
var box profitBoxShort = na
var box riskBoxShort   = na
var float activeSL = na
var float activeTP = na

// ---- LONG ENTRY ----
if (longSignal and strategy.position_size == 0)
    slRaw = swingLow - slBufferTicks * tick
    distRaw = close - slRaw
    dist = math.max(distRaw, minSlTicks * tick)
    sl = close - dist
    tp = close + dist * rr

    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", "Long", stop=sl, limit=tp)

    activeSL := sl
    activeTP := tp

    if showBoxes
        profitBoxLong := box.new(bar_index, tp, bar_index, close,
             border_color=color.green, bgcolor=profitColor, extend=extend.none)
        riskBoxLong := box.new(bar_index, close, bar_index, sl,
             border_color=color.red, bgcolor=riskColor, extend=extend.none)

// ---- SHORT ENTRY ----
if (shortSignal and strategy.position_size == 0)
    slRaw = swingHigh + slBufferTicks * tick
    distRaw = slRaw - close
    dist = math.max(distRaw, minSlTicks * tick)
    sl = close + dist
    tp = close - dist * rr

    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", "Short", stop=sl, limit=tp)

    activeSL := sl
    activeTP := tp

    if showBoxes
        profitBoxShort := box.new(bar_index, close, bar_index, tp,
             border_color=color.green, bgcolor=profitColor, extend=extend.none)
        riskBoxShort := box.new(bar_index, sl, bar_index, close,
             border_color=color.red, bgcolor=riskColor, extend=extend.none)

// ---- EXTEND BOXES WHILE THE TRADE IS STILL OPEN ----
if strategy.position_size > 0 and not na(profitBoxLong)
    box.set_right(profitBoxLong, bar_index)
    box.set_right(riskBoxLong, bar_index)

if strategy.position_size < 0 and not na(profitBoxShort)
    box.set_right(profitBoxShort, bar_index)
    box.set_right(riskBoxShort, bar_index)

// ============================== ALERTS (for later webhook automation) ==============================
alertcondition(longSignal, title="Long Entry", message="LONG {{ticker}} @ {{close}}")
alertcondition(shortSignal, title="Short Entry", message="SHORT {{ticker}} @ {{close}}")

// ============================== INFO PANEL ==============================
var table info = table.new(position.top_right, 1, 3, bgcolor=color.new(color.black, 20))
if barstate.islast
    table.cell(info, 0, 0, "Trend: " + (trendUp ? "UP (tradeable)" : "flat/down (no trades)"),
         text_color=trendUp ? color.lime : color.gray)
    table.cell(info, 0, 1, "RSI Smoothed: " + str.tostring(rsiSmooth, "#.##"),
         text_color=rsiSmooth > buyLevel ? color.lime : rsiSmooth < sellLevel ? color.red : color.gray)
    table.cell(info, 0, 2, "Open P/L: " + str.tostring(strategy.openprofit, "#.##"))
````
