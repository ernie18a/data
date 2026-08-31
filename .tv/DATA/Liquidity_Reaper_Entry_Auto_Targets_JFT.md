<!-- tradingview-pine-id: PUB;40984f13061340d994ef444bd114ed17 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Reaper Entry + Auto Targets [JFT]

Source: https://www.tradingview.com/script/QigF8M4S-Liquidity-Reaper-Entry-Auto-Targets-JFT/

## Description

Liquidity Reaper Entry + Auto Targets is designed to identify high-quality liquidity sweep opportunities and transform them into structured trading setups with clear entry, stop-loss, and automatic profit targets.

The engine focuses on the interaction between liquidity, price rejection, market direction, and candle confirmation to help traders recognize potential reversals after liquidity has been taken.

Core Features

• Buy-Side & Sell-Side Liquidity Detection
• Liquidity Sweep Recognition
• Bullish & Bearish Reclaim
• Strong Candle Confirmation
• EMA Trend Confirmation
• Smart BUY & SELL Entry Signals
• Automatic Entry Price
• Automatic Stop Loss
• Automatic TP1, TP2 & TP3
• Adjustable Risk/Reward Targets
• ATR-Based Risk Management
• Duplicate Signal Filtering
• TradingView Alerts
• Clean & Chart-Friendly Design

Entry Logic

BUY Setup

Sell-Side Liquidity Sweep
→ Bullish Reclaim
→ Strong Bullish Candle
→ Trend Confirmation
→ REAPER BUY

SELL Setup

Buy-Side Liquidity Sweep
→ Bearish Reclaim
→ Strong Bearish Candle
→ Trend Confirmation
→ REAPER SELL

Automatic Targets

Once a valid setup appears, the indicator automatically calculates:

ENTRY → SL → TP1 → TP2 → TP3

The default target structure is based on risk/reward, with adjustable levels according to your trading style and market conditions.

Best Use

Liquidity Reaper can be used on Forex, Gold, Silver, Crypto and other liquid markets.

For cleaner setups, combine the signals with your own market structure and higher-timeframe analysis rather than treating every signal as a guaranteed trade.

Liquidity Reaper doesn't chase price.
It waits for liquidity to be taken — then looks for confirmation.

Built for traders who want a cleaner and more structured approach to liquidity-based entries.

Liquidity Reaper Entry + Auto Targets [JFT]

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnsonForexTrader

//@version=6
indicator("Liquidity Reaper Entry + Auto Targets [JFT]", overlay=true, max_labels_count=200, max_lines_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lrLen = input.int(5, "Liquidity Strength", minval=2, maxval=20)

useTrend = input.bool(true, "Use Trend Filter")
showLiquidity = input.bool(true, "Show Liquidity")
showSignals = input.bool(true, "Show Entries")
showTargets = input.bool(true, "Show Auto Targets")

atrLength = input.int(14, "ATR Length")
atrSL = input.float(1.2, "SL ATR Multiplier", minval=0.1, step=0.1)

rr1 = input.float(1.0, "TP1 Risk/Reward", minval=0.5, step=0.5)
rr2 = input.float(2.0, "TP2 Risk/Reward", minval=1.0, step=0.5)
rr3 = input.float(3.0, "TP3 Risk/Reward", minval=1.5, step=0.5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lrHigh = ta.pivothigh(high, lrLen, lrLen)
lrLow = ta.pivotlow(low, lrLen, lrLen)

var float buyLiquidity = na
var float sellLiquidity = na

if not na(lrHigh)
    buyLiquidity := lrHigh

if not na(lrLow)
    sellLiquidity := lrLow

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY SWEEP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buySideSweep =
     not na(buyLiquidity) and
     high > buyLiquidity and
     close < buyLiquidity

sellSideSweep =
     not na(sellLiquidity) and
     low < sellLiquidity and
     close > sellLiquidity

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RECLAIM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullReclaim =
     sellSideSweep and
     close > open and
     close > sellLiquidity

bearReclaim =
     buySideSweep and
     close < open and
     close < buyLiquidity

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buyEntry =
     bullReclaim and
     (not useTrend or bullTrend)

sellEntry =
     bearReclaim and
     (not useTrend or bearTrend)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLength)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float entryPrice = na
var float stopPrice = na
var float target1 = na
var float target2 = na
var float target3 = na

var int tradeDirection = 0

var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLabel = na
var label stopLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLEAN OLD TRADE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if buyEntry or sellEntry

    if not na(entryLine)
        line.delete(entryLine)

    if not na(stopLine)
        line.delete(stopLine)

    if not na(tp1Line)
        line.delete(tp1Line)

    if not na(tp2Line)
        line.delete(tp2Line)

    if not na(tp3Line)
        line.delete(tp3Line)

    if not na(entryLabel)
        label.delete(entryLabel)

    if not na(stopLabel)
        label.delete(stopLabel)

    if not na(tp1Label)
        label.delete(tp1Label)

    if not na(tp2Label)
        label.delete(tp2Label)

    if not na(tp3Label)
        label.delete(tp3Label)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY TRADE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if buyEntry

    entryPrice := close
    stopPrice := entryPrice - atr * atrSL

    risk = entryPrice - stopPrice

    target1 := entryPrice + risk * rr1
    target2 := entryPrice + risk * rr2
    target3 := entryPrice + risk * rr3

    tradeDirection := 1

    if showTargets

        entryLine := line.new(
             bar_index,
             entryPrice,
             bar_index + 30,
             entryPrice,
             width=2)

        stopLine := line.new(
             bar_index,
             stopPrice,
             bar_index + 30,
             stopPrice,
             style=line.style_dashed)

        tp1Line := line.new(
             bar_index,
             target1,
             bar_index + 30,
             target1,
             style=line.style_dashed)

        tp2Line := line.new(
             bar_index,
             target2,
             bar_index + 30,
             target2,
             style=line.style_dashed)

        tp3Line := line.new(
             bar_index,
             target3,
             bar_index + 30,
             target3,
             style=line.style_dashed)

        entryLabel := label.new(
             bar_index + 30,
             entryPrice,
             "ENTRY\n" + str.tostring(entryPrice, format.mintick),
             style=label.style_label_left)

        stopLabel := label.new(
             bar_index + 30,
             stopPrice,
             "SL\n" + str.tostring(stopPrice, format.mintick),
             style=label.style_label_left)

        tp1Label := label.new(
             bar_index + 30,
             target1,
             "TP1\n" + str.tostring(target1, format.mintick),
             style=label.style_label_left)

        tp2Label := label.new(
             bar_index + 30,
             target2,
             "TP2\n" + str.tostring(target2, format.mintick),
             style=label.style_label_left)

        tp3Label := label.new(
             bar_index + 30,
             target3,
             "TP3\n" + str.tostring(target3, format.mintick),
             style=label.style_label_left)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL TRADE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if sellEntry

    entryPrice := close
    stopPrice := entryPrice + atr * atrSL

    risk = stopPrice - entryPrice

    target1 := entryPrice - risk * rr1
    target2 := entryPrice - risk * rr2
    target3 := entryPrice - risk * rr3

    tradeDirection := -1

    if showTargets

        entryLine := line.new(
             bar_index,
             entryPrice,
             bar_index + 30,
             entryPrice,
             width=2)

        stopLine := line.new(
             bar_index,
             stopPrice,
             bar_index + 30,
             stopPrice,
             style=line.style_dashed)

        tp1Line := line.new(
             bar_index,
             target1,
             bar_index + 30,
             target1,
             style=line.style_dashed)

        tp2Line := line.new(
             bar_index,
             target2,
             bar_index + 30,
             target2,
             style=line.style_dashed)

        tp3Line := line.new(
             bar_index,
             target3,
             bar_index + 30,
             target3,
             style=line.style_dashed)

        entryLabel := label.new(
             bar_index + 30,
             entryPrice,
             "ENTRY\n" + str.tostring(entryPrice, format.mintick),
             style=label.style_label_left)

        stopLabel := label.new(
             bar_index + 30,
             stopPrice,
             "SL\n" + str.tostring(stopPrice, format.mintick),
             style=label.style_label_left)

        tp1Label := label.new(
             bar_index + 30,
             target1,
             "TP1\n" + str.tostring(target1, format.mintick),
             style=label.style_label_left)

        tp2Label := label.new(
             bar_index + 30,
             target2,
             "TP2\n" + str.tostring(target2, format.mintick),
             style=label.style_label_left)

        tp3Label := label.new(
             bar_index + 30,
             target3,
             "TP3\n" + str.tostring(target3, format.mintick),
             style=label.style_label_left)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     showSignals and buyEntry,
     title="Liquidity Reaper BUY",
     style=shape.labelup,
     location=location.belowbar,
     text="REAPER BUY",
     size=size.small)

plotshape(
     showSignals and sellEntry,
     title="Liquidity Reaper SELL",
     style=shape.labeldown,
     location=location.abovebar,
     text="REAPER SELL",
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIQUIDITY LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(
     showLiquidity ? buyLiquidity : na,
     title="Buy-Side Liquidity",
     style=plot.style_stepline,
     linewidth=1)

plot(
     showLiquidity ? sellLiquidity : na,
     title="Sell-Side Liquidity",
     style=plot.style_stepline,
     linewidth=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     buyEntry,
     title="Liquidity Reaper BUY",
     message="Liquidity Reaper BUY Entry + Auto Targets detected.")

alertcondition(
     sellEntry,
     title="Liquidity Reaper SELL",
     message="Liquidity Reaper SELL Entry + Auto Targets detected.")
````
