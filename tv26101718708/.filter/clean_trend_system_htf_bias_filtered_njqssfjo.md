# Clean Trend System - HTF Bias Filtered

- url: https://www.tradingview.com/script/njQsSFjo-Clean-Trend-System-HTF-Bias-Filtered/
- type: strategy
- pine_id: PUB;32f892e6259346418652902d2ec4f97d
- version: 1.0

## Description

Clean Trend System - HTF Bias Filtered

Overview

Clean Trend System is a trend-following strategy designed to identify high-probability market moves by combining lower timeframe price action with higher timeframe trend confirmation.

The system filters trades using EMA structure, VWAP, RSI momentum, breakout detection, and an automatic Higher Timeframe (HTF) bias filter to avoid trading against the bigger trend.

Key Features

✅ Automatic HTF Trend Bias

- Automatically selects a higher timeframe based on the chart timeframe.
- Confirms bullish/bearish market direction using HTF EMA alignment.

✅ Multi EMA Trend Structure

- Fast EMA, Slow EMA, and Trend EMA identify market structure.
- Trades are only considered when the trend is aligned.

✅ VWAP & EMA Pullback Entries

- Detects pullbacks into EMA/VWAP zones.
- Looks for continuation entries with confirmation candles.

✅ Breakout Detection

- Includes recent high/low breakout logic.
- Captures momentum continuation moves.

✅ Momentum Filter

- Uses ROC momentum and Z-score logic to identify stronger moves.
- Background shading helps visualize momentum conditions.

✅ RSI Confirmation

- Filters weak signals and helps avoid overextended entries.

✅ Signal Control

- Prevents repeated signals in the same direction.
- Resets when trend conditions change.

Buy Conditions (Simplified)

A BUY signal appears when:

- Lower timeframe trend is bullish
- Higher timeframe bias is not bearish
- Momentum and RSI conditions confirm
- Pullback or breakout setup is detected

Sell Conditions (Simplified)

A SELL signal appears when:

- Lower timeframe trend is bearish
- Higher timeframe bias is not bullish
- Momentum and RSI conditions confirm
- Pullback or breakdown setup is detected

Recommended Usage

- Works best in trending markets.
- Can be used on intraday and swing timeframes.
- Always combine with proper risk management.

Disclaimer

This script is for educational and research purposes only. It is not financial advice. Past performance does not guarantee future results. Always test and adjust settings for your market.

## Source Code

````pine
//@version=6
strategy("Clean Trend System - HTF Bias Filtered", overlay=true)

// === INPUTS ===
emaFast        = input.int(9, "Fast EMA")
emaSlow        = input.int(21, "Slow EMA")  
emaTrend       = input.int(50, "Trend EMA")
rsiLen         = input.int(5, "RSI Length")
atrLen         = input.int(10, "ATR Length")
breakoutPeriod = input.int(20, "Breakout Lookback Period")

// === AUTO HTF RESOLUTION ===
string currentTF = timeframe.period
string htf = switch currentTF
    "1"      => "15"
    "2"      => "15"
    "3"      => "15"
    "5"      => "15"
    "10"     => "60"
    "15"     => "240"
    "20"     => "240"
    "30"     => "240"
    "45"     => "240"
    "60"     => "D"
    "120"    => "D"
    "180"    => "D"
    "240"    => "W"
    "D"      => "W"
    "1D"     => "W"
    => "W"

// === HTF TREND BIAS ===
[htfEmaTrend, htfEmaFast, htfEmaSlow, htfClose] = request.security(syminfo.tickerid, htf, [ta.ema(close, emaTrend), ta.ema(close, emaFast), ta.ema(close, emaSlow), close], lookahead=barmerge.lookahead_on)

htfBullish = htfClose > htfEmaTrend and htfEmaFast > htfEmaSlow and htfEmaSlow > htfEmaTrend
htfBearish = htfClose < htfEmaTrend and htfEmaFast < htfEmaSlow and htfEmaSlow < htfEmaTrend

// === LTF INDICATORS ===
emaF = ta.ema(close, emaFast)
emaS = ta.ema(close, emaSlow)
emaT = ta.ema(close, emaTrend)
vwapLine = ta.vwap(hlc3)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)

// === LTF TREND ===
bullishTrend = close > emaT and emaF > emaS and emaS > emaT
bearishTrend = close < emaT and emaF < emaS and emaS < emaT

// === MOMENTUM FILTER ===
rocValue = ta.roc(close, 9)
rocEma   = ta.ema(rocValue, 5)
rocSD    = ta.stdev(rocValue, 14)
momentumZScore = rocSD != 0 ? (rocEma / rocSD) : 0

color bgColor = na
if momentumZScore > 1.0 and close > emaF
    bgColor := color.new(#00e676, 92)
if momentumZScore < -1.0 or close < emaT
    bgColor := color.new(#ff1744, 92)

// === SETUPS ===
pullbackToEmaLong   = low <= emaS and close > emaS
pullbackToVwapLong  = low <= vwapLine and close > vwapLine
pullbackToEmaShort  = high >= emaS and close < emaS  
pullbackToVwapShort = high >= vwapLine and close < vwapLine

highestHigh = ta.highest(high, breakoutPeriod)[1]
lowestLow   = ta.lowest(low, breakoutPeriod)[1]
breakoutLong  = ta.crossover(close, highestHigh)
breakoutShort = ta.crossunder(close, lowestLow)

bullishCandle = close > open and close > high[1]
bearishCandle = close < open and close < low[1]

rsiLong  = rsi > 45 and rsi > rsi[1] and rsi < 75
rsiShort = rsi < 55 and rsi < rsi[1] and rsi > 25

// === RAW SIGNALS ===
longTrigger  = bullishTrend and ((pullbackToEmaLong or pullbackToVwapLong) and bullishCandle or breakoutLong) and rsiLong
shortTrigger = bearishTrend and ((pullbackToEmaShort or pullbackToVwapShort) and bearishCandle or breakoutShort) and rsiShort

// === STATE CONTROLLER ===
var string trendState = "NONE"

if trendState == "LONG_FIRED" and close < emaT
    trendState := "NONE"
if trendState == "SHORT_FIRED" and close > emaT
    trendState := "NONE"

// === HTF BIAS FILTER ===
bool longSignal  = longTrigger and trendState != "LONG_FIRED" and strategy.position_size <= 0 and not htfBearish
bool shortSignal = shortTrigger and trendState != "SHORT_FIRED" and strategy.position_size >= 0 and not htfBullish

// === EXECUTION ===
if longSignal
    strategy.entry("Long", strategy.long)
    trendState := "LONG_FIRED"

if shortSignal
    strategy.entry("Short", strategy.short)
    trendState := "SHORT_FIRED"

// === VISUALS ===
plot(emaF, "Fast EMA", color=color.new(#00bcd4, 0), linewidth=2)
plot(emaS, "Slow EMA", color=color.new(#ff9800, 0), linewidth=2)
plot(emaT, "Trend EMA", color=color.new(#9c27b0, 0), linewidth=3)
plot(vwapLine, "VWAP", color=color.new(#757575, 50), linewidth=1)
bgcolor(bgColor, title="Momentum Background")

plotshape(longSignal, "BUY", shape.triangleup, location.belowbar, color=#00e676, size=size.normal, text="BUY")
plotshape(shortSignal, "SELL", shape.triangledown, location.abovebar, color=#ff1744, size=size.normal, text="SELL")

// === HTF LABEL ===
var label htfLabel = na
if barstate.islast
    label.delete(htfLabel)
    string htfText = "HTF: " + htf + "\n" + (htfBullish ? "BULLISH" : htfBearish ? "BEARISH" : "NEUTRAL")
    color htfColor = htfBullish ? color.new(color.green, 80) : htfBearish ? color.new(color.red, 80) : color.new(color.gray, 80)
    color htfTextColor = htfBullish ? color.green : htfBearish ? color.red : color.gray
    htfLabel := label.new(bar_index, high, htfText, color=htfColor, textcolor=htfTextColor, style=label.style_label_lower_right, size=size.small)

// === ALERTS ===
alertcondition(longSignal, "BUY Signal", "Clean BUY - HTF Aligned")
alertcondition(shortSignal, "SELL Signal", "Clean SELL - HTF Aligned")
````
