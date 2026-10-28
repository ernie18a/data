# Institutional SMC & Liquidity Engine PRO

- url: https://www.tradingview.com/script/LiCqSVT1-Institutional-SMC-Liquidity-Engine-PRO/
- type: indicator
- pine_id: PUB;c4ca46d521e44bfeac0084ca4876b015
- version: 1.0

## Description

# Institutional SMC & Liquidity Engine PRO

Institutional SMC & Liquidity Engine PRO is an advanced Smart Money Concepts (SMC) trading indicator designed for professional-level market structure analysis on TradingView. This tool combines institutional trading logic, liquidity detection, order flow concepts, and volatility-based risk management into one clean and powerful system.

The indicator identifies high-probability trading opportunities using:

• Market Structure Breaks (BOS)
• Smart Money Trend Confirmation
• Fair Value Gaps (FVG)
• Institutional Order Blocks (OB)
• Liquidity Sweeps & Stop Hunts
• EMA Trend Alignment
• Volume Strength Confirmation
• ATR-Based Take Profit & Stop Loss Levels
• Sideways Market Noise Filter

Key Features:

✔ Smart Money Concepts (SMC) Engine
Detects bullish and bearish Break of Structure (BOS) to identify trend continuation and market direction.

✔ Fair Value Gap Detection
Automatically highlights institutional imbalance zones where price is likely to react.

✔ Institutional Order Blocks
Marks high-volume expansion candles that often act as strong supply and demand zones.

✔ Liquidity Sweep Detection
Identifies stop hunts above equal highs and below equal lows to catch reversals used by institutions.

✔ Advanced Trend Filtering
Uses dual EMA confirmation (50 EMA & 200 EMA) to filter low-quality trades and align with the higher timeframe trend.

✔ Volume Confirmation
Signals are only generated when volume strength exceeds the market average, reducing fake entries.

✔ ATR Dynamic Risk Management
Automatically calculates Stop Loss and Take Profit levels using market volatility for smarter risk control.

✔ Sideways Market Filter
Avoids choppy and low-momentum conditions to improve signal quality.

✔ Clean Professional Dashboard
Displays:

* Market Bias
* Trend Direction
* Volume Strength
* Active Buy/Sell Conditions
* ATR Volatility Data

Best Used For:
• Scalping
• Intraday Trading
• Swing Trading
• Smart Money Trading Strategies
• Liquidity & Institutional Trading Analysis

Recommended Timeframes:
• 5M
• 15M
• 1H
• 4H

Recommended Markets:
• Forex
• Crypto
• Indices
• Commodities
• Stocks

This indicator is designed for traders who want cleaner charts, fewer false signals, and institutional-level confluence for high-quality trade execution.

## Source Code

````pine
//@version=5
indicator("Institutional SMC & Liquidity Engine PRO", overlay=true, max_labels_count=500, max_boxes_count=500)

//====================================================
// INPUTS
//====================================================
showFVG        = input.bool(true, "Show Fair Value Gaps")
showOB         = input.bool(true, "Show Order Blocks")
showLiquidity  = input.bool(true, "Show Liquidity Sweeps")
showTrend      = input.bool(true, "Show EMA Trend")
showSignals    = input.bool(true, "Show Entry Signals")
showTP_SL      = input.bool(true, "Show TP / SL")

lookback       = input.int(20, "Structure Lookback")
atrPeriod      = input.int(14, "ATR Period")
emaFastLen     = input.int(50, "Fast EMA")
emaSlowLen     = input.int(200, "Slow EMA")
volMultiplier  = input.float(1.5, "Volume Strength")
rr             = input.float(2.0, "Risk Reward Ratio")

//====================================================
// EMA TREND FILTER
//====================================================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

plot(showTrend ? emaFast : na, color=color.green, linewidth=2)
plot(showTrend ? emaSlow : na, color=color.red, linewidth=2)

//====================================================
// ATR
//====================================================
atr = ta.atr(atrPeriod)

//====================================================
// MARKET STRUCTURE
//====================================================
high_signal = ta.highest(high, lookback)
low_signal  = ta.lowest(low, lookback)

var bool marketBull = na

bullBos = ta.crossover(close, high_signal[1])
bearBos = ta.crossunder(close, low_signal[1])

if bullBos
    marketBull := true
    label.new(bar_index, high, "BOS ↑",
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white,
         size=size.small)

if bearBos
    marketBull := false
    label.new(bar_index, low, "BOS ↓",
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.small)

//====================================================
// FAIR VALUE GAPS
//====================================================
bullish_fvg = low > high[2] and close[1] > high[2]
bearish_fvg = high < low[2] and close[1] < low[2]

if showFVG and bullish_fvg
    box.new(
         left=bar_index[2],
         top=low,
         right=bar_index + 5,
         bottom=high[2],
         bgcolor=color.new(color.green, 85),
         border_color=color.new(color.green, 50))

if showFVG and bearish_fvg
    box.new(
         left=bar_index[2],
         top=high,
         right=bar_index + 5,
         bottom=low[2],
         bgcolor=color.new(color.red, 85),
         border_color=color.new(color.red, 50))

//====================================================
// ORDER BLOCKS
//====================================================
bullOB = close > open and close > high[1] and volume > ta.sma(volume, 20) * volMultiplier
bearOB = close < open and close < low[1] and volume > ta.sma(volume, 20) * volMultiplier

if showOB and bullOB
    box.new(
         left=bar_index,
         top=high,
         right=bar_index + 8,
         bottom=low,
         bgcolor=color.new(color.blue, 85),
         border_color=color.blue)

if showOB and bearOB
    box.new(
         left=bar_index,
         top=high,
         right=bar_index + 8,
         bottom=low,
         bgcolor=color.new(color.purple, 85),
         border_color=color.purple)

//====================================================
// LIQUIDITY SWEEPS
//====================================================
eqHigh = ta.highest(high, 10)
eqLow  = ta.lowest(low, 10)

liqSell = high > eqHigh[1] and close < eqHigh[1]
liqBuy  = low < eqLow[1] and close > eqLow[1]

if showLiquidity and liqSell
    label.new(
         bar_index,
         high,
         "LIQUIDITY SWEEP",
         style=label.style_label_down,
         color=color.orange,
         textcolor=color.white,
         size=size.tiny)

if showLiquidity and liqBuy
    label.new(
         bar_index,
         low,
         "LIQUIDITY SWEEP",
         style=label.style_label_up,
         color=color.orange,
         textcolor=color.white,
         size=size.tiny)

//====================================================
// VOLUME FILTER
//====================================================
highVolume = volume > ta.sma(volume, 20) * volMultiplier

//====================================================
// SIDEWAYS FILTER
//====================================================
trendStrength = math.abs(emaFast - emaSlow)
avoidChop = trendStrength > atr * 0.2

//====================================================
// ENTRY CONDITIONS
//====================================================
buySignal =
     bullTrend and
     marketBull and
     highVolume and
     avoidChop and
     liqBuy

sellSignal =
     bearTrend and
     not marketBull and
     highVolume and
     avoidChop and
     liqSell

//====================================================
// TP / SL
//====================================================
buySL = close - atr
buyTP = close + (atr * rr)

sellSL = close + atr
sellTP = close - (atr * rr)

//====================================================
// SIGNALS
//====================================================
if showSignals and buySignal
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.normal)

    if showTP_SL
        line.new(bar_index, buySL, bar_index + 10, buySL,
             color=color.red,
             width=2)

        line.new(bar_index, buyTP, bar_index + 10, buyTP,
             color=color.green,
             width=2)

        label.new(bar_index + 1, buyTP, "TP",
             color=color.green,
             textcolor=color.white,
             style=label.style_label_left)

        label.new(bar_index + 1, buySL, "SL",
             color=color.red,
             textcolor=color.white,
             style=label.style_label_left)

if showSignals and sellSignal
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal)

    if showTP_SL
        line.new(bar_index, sellSL, bar_index + 10, sellSL,
             color=color.red,
             width=2)

        line.new(bar_index, sellTP, bar_index + 10, sellTP,
             color=color.green,
             width=2)

        label.new(bar_index + 1, sellTP, "TP",
             color=color.green,
             textcolor=color.white,
             style=label.style_label_left)

        label.new(bar_index + 1, sellSL, "SL",
             color=color.red,
             textcolor=color.white,
             style=label.style_label_left)

//====================================================
// DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 2, 6,
     bgcolor=color.new(color.black, 0),
     border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "TREND", text_color=color.white)
    table.cell(dash, 1, 0,
         bullTrend ? "BULLISH" : "BEARISH",
         bgcolor=bullTrend ? color.green : color.red,
         text_color=color.white)

    table.cell(dash, 0, 1, "VOLUME", text_color=color.white)
    table.cell(dash, 1, 1,
         highVolume ? "HIGH" : "LOW",
         bgcolor=highVolume ? color.green : color.gray,
         text_color=color.white)

    table.cell(dash, 0, 2, "MARKET", text_color=color.white)
    table.cell(dash, 1, 2,
         marketBull ? "BULLISH" : "BEARISH",
         bgcolor=marketBull ? color.green : color.red,
         text_color=color.white)

    table.cell(dash, 0, 3, "ATR", text_color=color.white)
    table.cell(dash, 1, 3,
         str.tostring(atr, "#.##"),
         text_color=color.white)

    table.cell(dash, 0, 4, "BUY SIGNAL", text_color=color.white)
    table.cell(dash, 1, 4,
         buySignal ? "ACTIVE" : "WAIT",
         bgcolor=buySignal ? color.green : color.gray,
         text_color=color.white)

    table.cell(dash, 0, 5, "SELL SIGNAL", text_color=color.white)
    table.cell(dash, 1, 5,
         sellSignal ? "ACTIVE" : "WAIT",
         bgcolor=sellSignal ? color.red : color.gray,
         text_color=color.white)
````
