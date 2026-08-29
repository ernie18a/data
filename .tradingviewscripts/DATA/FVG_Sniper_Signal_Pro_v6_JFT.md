<!-- tradingview-pine-id: PUB;e57d5e08dac745a1973f3937e1a041b6 -->
<!-- tradingviewscripts-format: 1 -->
# FVG Sniper Signal Pro v6 [JFT] 

Source: https://www.tradingview.com/script/DVc4rZJY-FVG-Sniper-Signal-Pro-v6-JFT/

## Description

[symbol="BINANCE:ETHUSDT"]BINANCE:ETHUSDT[/symbol] A powerful next-generation trading tool designed to identify high-probability opportunities using Fair Value Gap (FVG) concepts, market structure, and price action confirmation.

FVG Sniper Signal Pro v6 combines institutional trading concepts with smart filtering technology to help traders identify potential entries, trend continuation zones, and market imbalance areas with greater precision.

Key Features
Advanced Fair Value Gap Detection
Bullish & Bearish FVG Zones
Smart Entry Confirmation
Market Trend Filter
Momentum-Based Signal Validation
Breakout & Reversal Identification
Dynamic Support & Resistance Areas
Clean Buy & Sell Signals
Professional Chart Visualization
Custom Alerts for Trading Opportunities
How It Works

The indicator analyzes price imbalance, market structure, and momentum conditions to highlight potential trading zones where institutional activity may occur.

Instead of relying on simple signals, FVG Sniper Signal Pro v6 focuses on confluence between:

Market Structure
Fair Value Gaps
Trend Direction
Price Momentum
Liquidity Areas
Suitable For
Forex
Gold (XAUUSD)
Silver (XAGUSD)
Cryptocurrency
Indices
Stocks
Trading Approach

Use the signals as a confirmation tool alongside your own analysis. Combine FVG zones with proper risk management and market context for better decision-making

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnsonForexTrader

//@version=6
indicator("FVG Sniper Signal Pro v6 [JFT] ", overlay=true, max_boxes_count=500, max_labels_count=500)

//================ INPUTS ================
showFVG = input.bool(true, "Show FVG Zones")
showSignals = input.bool(true, "Show Buy/Sell Signals")

useEMA = input.bool(true, "Use EMA Trend Filter")
emaLength = input.int(200, "EMA Length")

bullColor = input.color(color.new(color.green, 80), "Bullish FVG")
bearColor = input.color(color.new(color.red, 80), "Bearish FVG")

//================ TREND FILTER ================
emaValue = ta.ema(close, emaLength)

bullTrend = close > emaValue
bearTrend = close < emaValue

plot(useEMA ? emaValue : na, "EMA", color=color.yellow)


//================ FVG LOGIC ================

// Bullish FVG
bullFVG = low > high[2]

// Bearish FVG
bearFVG = high < low[2]


//================ FVG BOXES ================
var box[] bullBoxes = array.new_box()
var box[] bearBoxes = array.new_box()


if showFVG and bullFVG
    b = box.new(
         left=bar_index[2],
         top=low,
         right=bar_index+20,
         bottom=high[2],
         bgcolor=bullColor,
         border_color=color.green)
    array.push(bullBoxes,b)


if showFVG and bearFVG
    b = box.new(
         left=bar_index[2],
         top=low[2],
         right=bar_index+20,
         bottom=high,
         bgcolor=bearColor,
         border_color=color.red)
    array.push(bearBoxes,b)


//================ SIGNAL ENGINE ================

// Previous candle confirmation
bullConfirm = close > open and close > close[1]
bearConfirm = close < open and close < close[1]


// FVG Retest Logic
bullRetest = bullFVG[1] and low <= low[1]
bearRetest = bearFVG[1] and high >= high[1]


BUY = bullRetest and bullConfirm and (not useEMA or bullTrend)

SELL = bearRetest and bearConfirm and (not useEMA or bearTrend)


//================ SIGNAL DISPLAY ================

plotshape(
 BUY and showSignals,
 title="BUY",
 style=shape.labelup,
 text="BUY",
 color=color.green,
 textcolor=color.white,
 location=location.belowbar,
 size=size.small)


plotshape(
 SELL and showSignals,
 title="SELL",
 style=shape.labeldown,
 text="SELL",
 color=color.red,
 textcolor=color.white,
 location=location.abovebar,
 size=size.small)


//================ ALERTS ================

alertcondition(BUY, title="FVG BUY Signal", message="FVG Sniper BUY Signal")
alertcondition(SELL, title="FVG SELL Signal", message="FVG Sniper SELL Signal")
//================ PART 2 : AUTO TP SL ENGINE =================

// Settings
showTPSL = input.bool(true, "Show Auto TP/SL", group="Target Engine")
rrRatio = input.float(2.0, "Risk Reward Ratio", minval=0.5, step=0.5, group="Target Engine")
atrSL = input.float(1.5, "ATR Stop Loss Multiplier", minval=0.5, step=0.1, group="Target Engine")

atr = ta.atr(14)


// Storage
var line buyEntryLine = na
var line buySLLine = na
var line buyTPLine = na

var line sellEntryLine = na
var line sellSLLine = na
var line sellTPLine = na


// BUY TARGETS
if BUY and showTPSL

    entryPrice = close
    slPrice = close - (atr * atrSL)
    tpPrice = entryPrice + ((entryPrice - slPrice) * rrRatio)

    line.delete(buyEntryLine)
    line.delete(buySLLine)
    line.delete(buyTPLine)

    buyEntryLine := line.new(
         bar_index,
         entryPrice,
         bar_index + 25,
         entryPrice,
         color=color.blue,
         width=2)

    buySLLine := line.new(
         bar_index,
         slPrice,
         bar_index + 25,
         slPrice,
         color=color.red,
         width=2)

    buyTPLine := line.new(
         bar_index,
         tpPrice,
         bar_index + 25,
         tpPrice,
         color=color.green,
         width=2)

    label.new(
         bar_index,
         tpPrice,
         "BUY TARGET\nRR "+str.tostring(rrRatio),
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white)


// SELL TARGETS
if SELL and showTPSL

    entryPrice = close
    slPrice = close + (atr * atrSL)
    tpPrice = entryPrice - ((slPrice - entryPrice) * rrRatio)

    line.delete(sellEntryLine)
    line.delete(sellSLLine)
    line.delete(sellTPLine)

    sellEntryLine := line.new(
         bar_index,
         entryPrice,
         bar_index + 25,
         entryPrice,
         color=color.blue,
         width=2)

    sellSLLine := line.new(
         bar_index,
         slPrice,
         bar_index + 25,
         slPrice,
         color=color.red,
         width=2)

    sellTPLine := line.new(
         bar_index,
         tpPrice,
         bar_index + 25,
         tpPrice,
         color=color.green,
         width=2)

    label.new(
         bar_index,
         tpPrice,
         "SELL TARGET\nRR "+str.tostring(rrRatio),
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white)
         //================ PART 3 : SMART DASHBOARD + BOS ENGINE =================

// Dashboard Settings
showDashboard = input.bool(true, "Show Smart Dashboard", group="Dashboard")


//================ BOS LOGIC =================

swingHigh = ta.highest(high, 10)
swingLow  = ta.lowest(low, 10)

bullBOS = close > swingHigh[1]
bearBOS = close < swingLow[1]


//================ SIGNAL SCORE =================

score = 0

if close > ta.ema(close,200)
    score += 1

if bullFVG
    score += 1

if bullBOS
    score += 1


if close < ta.ema(close,200)
    score -= 1

if bearFVG
    score -= 1

if bearBOS
    score -= 1


signalStrength = 
     score >= 2 ? "STRONG BUY" :
     score <= -2 ? "STRONG SELL" :
     "NEUTRAL"


//================ MARKET BIAS =================

marketBias =
     score > 0 ? "BULLISH" :
     score < 0 ? "BEARISH" :
     "SIDEWAYS"


//================ DASHBOARD =================

var table dash = table.new(
     position.top_right,
     2,
     5,
     border_width=1)


if barstate.islast and showDashboard

    table.cell(
         dash,
         0,
         0,
         "FVG SNIPER PRO",
         text_color=color.white,
         bgcolor=color.blue)

    table.cell(
         dash,
         0,
         1,
         "Market Bias")

    table.cell(
         dash,
         1,
         1,
         marketBias)


    table.cell(
         dash,
         0,
         2,
         "Signal")

    table.cell(
         dash,
         1,
         2,
         signalStrength)


    table.cell(
         dash,
         0,
         3,
         "BOS")

    table.cell(
         dash,
         1,
         3,
         bullBOS ? "Bull BOS" :
         bearBOS ? "Bear BOS" :
         "No BOS")


    table.cell(
         dash,
         0,
         4,
         "FVG")

    table.cell(
         dash,
         1,
         4,
         bullFVG ? "Bull FVG" :
         bearFVG ? "Bear FVG" :
         "Waiting")
         //================ PART 4 : LIQUIDITY + MTF CONFIRMATION =================

// Inputs
useLiquidity = input.bool(true, "Use Liquidity Sweep Filter", group="Advanced Filter")
useMTF = input.bool(true, "Use Higher Timeframe Trend", group="Advanced Filter")

htf = input.timeframe("60", "Higher Timeframe", group="Advanced Filter")


//================ HIGHER TIMEFRAME TREND =================

htfEMA = request.security(
     syminfo.tickerid,
     htf,
     ta.ema(close,200))

htfBull = close > htfEMA
htfBear = close < htfEMA


//================ LIQUIDITY SWEEP =================

// Previous swing levels
prevHigh = ta.highest(high,20)[1]
prevLow  = ta.lowest(low,20)[1]


bullSweep = low < prevLow and close > prevLow
bearSweep = high > prevHigh and close < prevHigh


//================ SMART CONFIRMATION =================

smartBuy =
     BUY and
     (not useLiquidity or bullSweep) and
     (not useMTF or htfBull)


smartSell =
     SELL and
     (not useLiquidity or bearSweep) and
     (not useMTF or htfBear)


//================ PREMIUM SIGNAL LABEL =================

plotshape(
     smartBuy,
     title="Premium BUY",
     style=shape.labelup,
     text="SMART\nBUY",
     color=color.lime,
     textcolor=color.black,
     location=location.belowbar,
     size=size.normal)


plotshape(
     smartSell,
     title="Premium SELL",
     style=shape.labeldown,
     text="SMART\nSELL",
     color=color.red,
     textcolor=color.white,
     location=location.abovebar,
     size=size.normal)


//================ ALERTS =================

alertcondition(
     smartBuy,
     title="Smart FVG BUY",
     message="FVG Sniper Smart BUY Signal")


alertcondition(
     smartSell,
     title="Smart FVG SELL",
     message="FVG Sniper Smart SELL Signal")
````
