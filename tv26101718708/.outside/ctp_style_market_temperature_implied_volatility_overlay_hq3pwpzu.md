# CTP Style Market Temperature + Implied Volatility Overlay

- url: https://www.tradingview.com/script/hQ3pwpzU-CTP-Style-Market-Temperature-Implied-Volatility-Overlay/
- type: indicator
- pine_id: PUB;84f7cbe65c0748aea8d244413bf6e794
- version: 1.0

## Description

Absolutely. Here’s a stronger **TradingView publish description** written for novice option traders, including how to read the **color transitions**.

---

# CTP Style Market Temperature + IV Overlay

This indicator is designed to help traders quickly understand the current **market temperature**, trend strength, and volatility risk.

It is especially useful for **option traders** because buying calls, puts, or LEAPs is not just about direction. Option prices are also affected by **implied volatility**, time decay, and market conditions.

This indicator tries to answer three simple questions:

1. Is the stock or ETF technically healthy?
2. Is the market environment improving or weakening?
3. Is volatility making options more expensive or risky?

## How the Market Temperature Score Works

The indicator creates a simple score from **0 to 4** using four conditions:

* Price above the 50-day moving average
* Price above the 200-day moving average
* MACD is bullish
* Price is above Parabolic SAR

The higher the score, the stronger the technical environment.

## Bar Colors

The main bars show the market temperature:

* **Green** = strong / bullish environment
* **Yellow** = mixed / neutral environment
* **Red** = weak / defensive environment

This is not meant to be a blind buy or sell signal. It is a **risk filter**.

## How to Read Color Changes

The most important part of this indicator is not just the current color, but how the color is changing.

### Red moving to Yellow

Red moving to yellow means conditions may be starting to improve.

For option traders, this usually means:

> The market may be stabilizing, but it is not fully healthy yet.

This can be a good time to build a watchlist, look for stocks reclaiming key moving averages, and prepare for possible setups. It does **not** mean aggressively buy calls yet.

### Yellow moving to Green

Yellow moving to green means conditions are strengthening.

For option traders, this is usually the best environment to look for higher-quality bullish setups.

This may mean:

* Trend is improving
* Momentum is returning
* Risk conditions are more supportive
* Long calls or LEAPs may have a better probability backdrop

This is the “market wind at your back” zone.

### Green moving to Yellow

Green moving to yellow is an early caution signal.

It does not automatically mean sell, but it means the strong bullish environment is weakening.

For option traders, this may be a time to:

* Stop chasing new call entries
* Tighten risk
* Consider taking partial profits
* Watch for breaks of support
* Be more selective

This is especially important because options can lose value quickly if momentum fades.

### Yellow moving to Red

Yellow moving to red means the environment is becoming defensive.

For option traders, this is usually a warning to be careful with long calls or aggressive bullish trades.

This may mean:

* Trend is breaking down
* Momentum is weakening
* Risk is increasing
* Capital preservation becomes more important

## Implied Volatility / Volatility Overlay

The indicator also includes a volatility line plotted over the bars.

The volatility source can be either:

* An external volatility symbol, such as VIX
* A historical volatility proxy calculated from price movement

The volatility line uses a separate color system:

* **White** = volatility is OK
* **Teal** = caution
* **Blue** = elevated volatility risk

For novice option traders, this matters because higher volatility usually means options are more expensive.

A stock can look bullish, but if volatility is elevated, calls and LEAPs may already be expensive. That creates a headwind.

## Negative Volatility Bias

The red bars below the zero line show the volatility penalty or negative bias.

Simple read:

* **No red bar below zero** = low volatility pressure
* **Small red bar** = caution
* **Deeper red bar** = higher volatility risk

For option traders:

> The deeper the red bar below zero, the more careful you should be about buying expensive option premium.

## Simple Option Trader Guide

### Best environment for bullish option trades

* Bars are green
* Volatility line is white or improving
* Red negative-bias bars are small or absent
* Price is above key moving averages

### Caution environment

* Bars are yellow
* Volatility line is teal
* Red negative-bias bars are present
* Price action is mixed

### Defensive environment

* Bars are red
* Volatility line is blue
* Red negative-bias bars are deep
* Price is below key moving averages

## Important Reminder

This indicator is not a complete trading system. It is designed to help traders understand the environment before making a trade.

Use it with price action, volume, support and resistance, earnings dates, risk management, and your own trading plan.

For educational purposes only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Solana_Sphyr

//@version=6
indicator("CTP Style Market Temperature + IV Overlay", shorttitle="CTP Temp + IV", overlay=false, explicit_plot_zorder=true)

// =====================
// Inputs
// =====================
fastSmaLen = input.int(50, "Fast SMA", minval=1)
slowSmaLen = input.int(200, "Slow SMA", minval=1)

psarStart = input.float(0.02, "PSAR Start", step=0.01)
psarInc   = input.float(0.02, "PSAR Increment", step=0.01)
psarMax   = input.float(0.20, "PSAR Max", step=0.01)

macdFast   = input.int(12, "MACD Fast")
macdSlow   = input.int(26, "MACD Slow")
macdSignal = input.int(9, "MACD Signal")

volMode = input.string("External IV Symbol", "Volatility Source", options=["External IV Symbol", "HV Proxy"])
ivSymbol = input.symbol("CBOE:VIX", "External IV Symbol")
externalScale = input.string("Percent", "External IV Scale", options=["Percent", "Decimal"])

hvLen   = input.int(20, "Historical Volatility Length", minval=2)
rankLen = input.int(252, "Volatility Rank Lookback", minval=20)

lowThresh  = input.float(15.0, "Caution Threshold %")
midThresh  = input.float(19.0, "Risk Threshold %")
highThresh = input.float(23.0, "Danger Threshold %")

lineMetric = input.string("Vol %", "Overlay Line Metric", options=["Vol %", "IV Rank", "IV Percentile"])
ivLineWidth = input.int(4, "IV Line Width", minval=1, maxval=6)

showTable = input.bool(true, "Show Dashboard")

// =====================
// Trend calculations
// =====================
smaFast = ta.sma(close, fastSmaLen)
smaSlow = ta.sma(close, slowSmaLen)

psar = ta.sar(psarStart, psarInc, psarMax)

[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)

// =====================
// Positive CTP score
// =====================
scoreFastSma = close > smaFast ? 1.0 : 0.0
scoreSlowSma = close > smaSlow ? 1.0 : 0.0
scoreMacd    = macdLine > signalLine ? 1.0 : 0.0
scorePsar    = close > psar ? 1.0 : 0.0

tempScore = scoreFastSma + scoreSlowSma + scoreMacd + scorePsar

tempColor = tempScore >= 4 ? color.lime : tempScore >= 2 ? color.yellow : color.red
tempTextColor = tempScore >= 2 ? color.black : color.white

// =====================
// Volatility calculations
// =====================

// Historical volatility proxy
logReturn = math.log(close / close[1])
hvDecimal = ta.stdev(logReturn, hvLen) * math.sqrt(252)

// External IV / VIX source
extRaw = request.security(ivSymbol, timeframe.period, close, ignore_invalid_symbol=true)
extDecimal = externalScale == "Percent" ? extRaw / 100.0 : extRaw

volDecimal = volMode == "External IV Symbol" ? extDecimal : hvDecimal
volPercent = volDecimal * 100.0

// =====================
// Volatility Rank
// =====================
volLow = ta.lowest(volDecimal, rankLen)
volHigh = ta.highest(volDecimal, rankLen)

volRank = volHigh != volLow ? 100.0 * (volDecimal - volLow) / (volHigh - volLow) : na

// =====================
// Volatility Percentile
// =====================
float belowCount = 0.0

for i = 1 to rankLen
    if not na(volDecimal[i]) and volDecimal > volDecimal[i]
        belowCount := belowCount + 1.0

volPercentile = 100.0 * belowCount / rankLen

// =====================
// Negative volatility bias
// =====================
volPenalty = volPercent >= highThresh ? -3 : volPercent >= midThresh ? -2 : volPercent >= lowThresh ? -1 : 0

// =====================
// IV line color logic
// White = OK
// Teal = Caution
// Blue = Risk / Danger
// =====================
ivLineColor = volPenalty == 0 ? color.white : volPenalty == -1 ? color.teal : color.blue
ivTextColor = volPenalty == 0 ? color.black : color.white

// =====================
// Build overlay line metric
// =====================
rawLineMetric = lineMetric == "Vol %" ? volPercent : lineMetric == "IV Rank" ? volRank : volPercentile

metricLow = ta.lowest(rawLineMetric, rankLen)
metricHigh = ta.highest(rawLineMetric, rankLen)

// Scale IV line into same visual range as the CTP bars
panelMin = -2.5
panelMax = 4.5

lineScaled = metricHigh != metricLow ? panelMin + (rawLineMetric - metricLow) * (panelMax - panelMin) / (metricHigh - metricLow) : na

// =====================
// Reference lines
// =====================
hline(4, "Strong Green", color=color.new(color.lime, 65))
hline(2, "Yellow Threshold", color=color.new(color.yellow, 65))
hline(0, "Zero Line", color=color.new(color.gray, 70))
hline(-1, "Caution Penalty", color=color.new(color.red, 80))
hline(-2, "Risk Penalty", color=color.new(color.red, 80))
hline(-3, "Danger Penalty", color=color.new(color.red, 80))

// =====================
// Plots
// Bars first, IV line last so it appears on top
// =====================

// Positive CTP market temperature bars
plot(tempScore, "CTP Market Temperature", style=plot.style_columns, color=tempColor, linewidth=4, histbase=0)

// Negative volatility dampener bars
plot(volPenalty, "Negative Volatility Bias", style=plot.style_columns, color=color.red, linewidth=4, histbase=0)

// IV / volatility line plotted last
plot(lineScaled, "Overlay Volatility Line", color=ivLineColor, linewidth=ivLineWidth)

// Hidden values for Data Window
plot(volPercent, "Vol %", display=display.data_window)
plot(volRank, "Vol Rank", display=display.data_window)
plot(volPercentile, "Vol Percentile", display=display.data_window)

// =====================
// Dashboard
// Top 3 only
// =====================
var table dash = table.new(position.top_right, 2, 3)

if barstate.islast and showTable
    biasText = volPenalty == 0 ? "OK" : volPenalty == -1 ? "Caution" : volPenalty == -2 ? "Risk" : "Danger"
    regimeText = tempScore >= 4 ? "GREEN" : tempScore >= 2 ? "YELLOW" : "RED"

    table.cell(dash, 0, 0, "Temp", text_color=color.white)
    table.cell(dash, 1, 0, str.tostring(tempScore, "#"), text_color=tempTextColor, bgcolor=tempColor)

    table.cell(dash, 0, 1, "Regime", text_color=color.white)
    table.cell(dash, 1, 1, regimeText, text_color=tempTextColor, bgcolor=tempColor)

    table.cell(dash, 0, 2, "IV Bias", text_color=color.white)
    table.cell(dash, 1, 2, biasText, text_color=ivTextColor, bgcolor=ivLineColor)
````
