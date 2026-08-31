<!-- tradingview-pine-id: PUB;b2eae9e7e7de4a6e806478c05008514a -->
<!-- tradingviewscripts-format: 1 -->
# Reversal Trap Probability Bands Pro [JPT]

Source: https://www.tradingview.com/script/L0KXPirT-Reversal-Trap-Probability-Bands-Pro-JPT/

## Description

🔷 OVERVIEW

Reversal Trap Probability Bands Pro [JPT] is an original Pine Script® indicator that combines volatility bands, ATR, RSI, and volume analysis to estimate the probability of bullish and bearish reversal traps. Instead of relying on a single signal, the indicator calculates a probability score based on multiple technical factors and highlights areas where price may be exhausted and preparing for a reversal.

Designed for traders who monitor trend exhaustion and potential turning points, the indicator provides dynamic probability bands, reversal signals, market bias, and a real-time probability dashboard.

🔷 HOW IT WORKS

The indicator evaluates several market conditions simultaneously to estimate the likelihood of a bullish or bearish reversal.

Bullish Reversal Probability

The bullish probability increases when:

• RSI enters the oversold region

• Price closes below the lower ATR probability band

• Trading volume is above its average

• The candle closes bullish

When the combined probability reaches the defined threshold, a Bullish Reversal signal is generated.

Bearish Reversal Probability

The bearish probability increases when:

• RSI enters the overbought region

• Price closes above the upper ATR probability band

• Trading volume is above its average

• The candle closes bearish

When the combined probability reaches the defined threshold, a Bearish Reversal signal is generated.

🔷 PROBABILITY ENGINE

The indicator combines multiple technical factors into a probability score instead of using a single condition.

The probability model evaluates:

• RSI Momentum

• ATR Volatility

• Price Position Relative to Dynamic Bands

• Volume Confirmation

• Candle Direction

The resulting Bullish and Bearish probabilities are displayed in real time to help traders assess potential reversal conditions.

🔷 VISUAL FEATURES

• Dynamic EMA Basis Line

• ATR-Based Probability Bands

• Extreme Upper Probability Band

• Extreme Lower Probability Band

• Bullish Reversal Signals

• Bearish Reversal Signals

• Probability Zone Background Highlighting

• Real-Time Probability Dashboard

• Market Bias Display

• Customizable Inputs

🔷 PROBABILITY BANDS

The indicator automatically plots:

• EMA Basis

• Upper Probability Band

• Lower Probability Band

• Extreme Upper Band

• Extreme Lower Band

These adaptive bands expand and contract with market volatility, helping identify potential overextended price conditions.

🔷 DASHBOARD

The built-in dashboard displays:

• Bullish Probability (%)

• Bearish Probability (%)

• Current Market Bias

This provides a quick overview of market conditions without requiring manual calculations.

🔷 INPUTS

Available settings include:

• Band Length

• ATR Length

• ATR Multiplier

• RSI Length

• Overbought Level

• Oversold Level

• Volume SMA Length

• Show Reversal Signals

• Show Probability Bands

🔷 ALERTS

Built-in alerts are available for:

• Bullish Reversal Signal

• Bearish Reversal Signal

Alerts can be connected directly to TradingView's notification system for real-time monitoring.

🔷 COMMON WORKFLOW

A typical workflow is:

Monitor price as it approaches the upper or lower probability bands.
Observe the Bullish and Bearish Probability values in the dashboard.
Wait for a confirmed BUY or SELL reversal signal.
Use additional confirmation such as price action, support and resistance, or market structure before entering a trade.
Apply sound risk management for every position.
🔷 MARKETS

Reversal Trap Probability Bands Pro [JPT] can be used on:

• Forex

• Gold (XAUUSD)

• Silver (XAGUSD)

• Cryptocurrency

• Stocks

• Indices

• Futures

• Commodities

Compatible with all TradingView-supported timeframes.

🔷 BEST PRACTICES

Many traders combine this indicator with:

• Market Structure (HH, HL, LH, LL)

• Break of Structure (BOS)

• Change of Character (CHoCH)

• Support & Resistance

• Fibonacci Retracement

• Order Blocks

• Fair Value Gaps (FVG)

• EMA Trend Filters

• Higher Timeframe Analysis

Using multiple forms of confirmation can help improve decision-making around potential reversal zones.

🔷 UPCOMING FEATURES

Future updates may include:

• Multi-Timeframe Probability Analysis

• Trend Strength Filter

• Smart Money Confirmation

• Liquidity Sweep Detection

• ATR-Based Stop Loss Suggestions

• TP1, TP2, TP3 Auto Targets

• Risk/Reward Visualization

• Advanced Dashboard

• Custom Probability Weighting

• Session-Based Probability Filters

🔷 DISCLAIMER

This indicator is provided for educational and informational purposes only. It estimates reversal probability using technical indicators and historical price action. It does not predict future market movements or guarantee trading results. Always perform your own analysis, use appropriate risk management, and consider additional market factors before making trading decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Reversal Trap Probability Bands Pro [JPT]", overlay=true, max_labels_count=500)

//========================= Inputs =========================//
length      = input.int(20, "Band Length", minval=5)
atrLength   = input.int(14, "ATR Length")
atrMult     = input.float(2.0, "ATR Multiplier", step=0.1)
rsiLength   = input.int(14, "RSI Length")
overBought  = input.int(70, "Overbought")
overSold    = input.int(30, "Oversold")
volLength   = input.int(20, "Volume SMA")
showSignals = input.bool(true, "Show Reversal Signals")
showBands   = input.bool(true, "Show Probability Bands")

//========================= Core =========================//
basis = ta.ema(close, length)
atr   = ta.atr(atrLength)

upper1 = basis + atr * atrMult
lower1 = basis - atr * atrMult

upper2 = basis + atr * atrMult * 1.5
lower2 = basis - atr * atrMult * 1.5

rsi = ta.rsi(close, rsiLength)
volAvg = ta.sma(volume, volLength)

highVolume = volume > volAvg

//========================= Probability =========================//
bullProb =
     (rsi < overSold ? 40 : 0) +
     (close < lower1 ? 30 : 0) +
     (highVolume ? 20 : 0) +
     (close > open ? 10 : 0)

bearProb =
     (rsi > overBought ? 40 : 0) +
     (close > upper1 ? 30 : 0) +
     (highVolume ? 20 : 0) +
     (close < open ? 10 : 0)

//========================= Signals =========================//
bullSignal = bullProb >= 70
bearSignal = bearProb >= 70

//========================= Plots =========================//
plot(showBands ? basis : na, "Basis", color=color.yellow, linewidth=2)

u1 = plot(showBands ? upper1 : na, "Upper Band", color=color.red)
l1 = plot(showBands ? lower1 : na, "Lower Band", color=color.lime)

u2 = plot(showBands ? upper2 : na, "Extreme Upper", color=color.new(color.red,60))
l2 = plot(showBands ? lower2 : na, "Extreme Lower", color=color.new(color.green,60))

fill(u1,l1,color.new(color.blue,92))
fill(u2,u1,color.new(color.red,90))
fill(l2,l1,color.new(color.green,90))

//========================= Signals =========================//
plotshape(showSignals and bullSignal,
     title="Bull Trap Reversal",
     location=location.belowbar,
     color=color.lime,
     style=shape.triangleup,
     size=size.small,
     text="BUY")

plotshape(showSignals and bearSignal,
     title="Bear Trap Reversal",
     location=location.abovebar,
     color=color.red,
     style=shape.triangledown,
     size=size.small,
     text="SELL")

//========================= Background =========================//
bgcolor(bullProb >= 80 ? color.new(color.green,90) : na)
bgcolor(bearProb >= 80 ? color.new(color.red,90) : na)

//========================= Probability Table =========================//
var table stats = table.new(position.top_right,2,3)

if barstate.islast
    table.cell(stats,0,0,"Bull %",bgcolor=color.new(color.green,85))
    table.cell(stats,1,0,str.tostring(bullProb)+"%")

    table.cell(stats,0,1,"Bear %",bgcolor=color.new(color.red,85))
    table.cell(stats,1,1,str.tostring(bearProb)+"%")

    table.cell(stats,0,2,"Bias")
    table.cell(stats,1,2,bullProb>bearProb?"Bullish":"Bearish")

//========================= Alerts =========================//
alertcondition(bullSignal,title="Bullish Reversal",message="Bullish reversal detected.")
alertcondition(bearSignal,title="Bearish Reversal",message="Bearish reversal detected.")
````
