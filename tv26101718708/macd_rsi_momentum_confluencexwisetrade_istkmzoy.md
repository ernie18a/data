# MACD RSI Momentum Confluence[XWiseTrade]

- url: https://www.tradingview.com/script/ISTKmZoY-MACD-RSI-Momentum-Confluence-XWiseTrade/
- type: indicator
- pine_id: PUB;60d4ec2bc77a44c2b031a2bbd3900c6d
- version: 1.0

## Description

MACD RSI Momentum Confluence

This indicator generates Bull/Bear signals only when a MACD signal-line cross is confirmed by two independent momentum conditions, rather than firing on the cross alone. The goal is to reduce the false crosses that a plain MACD+RSI combination produces in ranging markets.
Why these components are combined

A MACD cross marks a potential shift in momentum, but on its own it triggers frequently during choppy, directionless price action. RSI relative to its midline is a common trend filter, but a value sitting just above or below 50 says little about whether momentum is actually building. Used separately, each gives signals the other would reject. This script requires them to agree and to be accelerating in the same direction.
How the components work together

A signal requires three conditions to align on the same bar:

[list=1]
[*]Trigger — MACD line crosses its signal line (up for Bull, down for Bear).
[*]Momentum confirmation — the MACD histogram is expanding in the cross direction, so flat or contracting crosses (typical of chop) are filtered out.
[*]Direction confirmation — RSI is on the correct side of its midline and moving toward the signal direction over a configurable lookback, not merely resting there.
[/list]

A cooldown prevents clustered repeat signals after a trigger.
How to use it

Add it to any chart and timeframe. "Bull Cross" / "Bear Cross" labels mark confirmed signals; alerts are available for both. The histogram-expansion filter and RSI slope lookback are adjustable, letting you tighten the filter on lower timeframes or loosen it on higher ones. These are descriptive signals for discretionary use, not buy/sell recommendations.

Inputs: RSI length & midline, RSI slope lookback, MACD fast/slow/signal, histogram-expansion toggle, signal cooldown.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © xwisetrade

//@version=6
indicator("MACD RSI Momentum Confluence[XWiseTrade]", overlay=true, max_labels_count=500)

// ===== Inputs =====
rsiLen   = input.int(12, "RSI length", group="RSI")
rsiMid   = input.int(50, "RSI midline (trend filter)", group="RSI")
fastLen  = input.int(12, "MACD fast", group="MACD")
slowLen  = input.int(26, "MACD slow", group="MACD")
sigLen   = input.int(12,  "MACD signal", group="MACD")
cooldown = input.int(3,  "Signal cooldown (bars)", minval=0, group="Display")

// ===== MACD 交叉(触发)=====
[macdLine, signalLine, _] = ta.macd(close, fastLen, slowLen, sigLen)
crossUp   = ta.crossover(macdLine, signalLine)
crossDown = ta.crossunder(macdLine, signalLine)

// ===== RSI 过滤(方向,不要求极值)=====
rsi = ta.rsi(close, rsiLen)
rsiBull = rsi > rsiMid   // RSI 在中线上方 = 偏多
rsiBear = rsi < rsiMid   // RSI 在中线下方 = 偏空

// ===== 信号:MACD 交叉 + RSI 方向一致 =====
buySig  = crossUp   and rsiBull
sellSig = crossDown and rsiBear

// ===== 冷却 =====
var int lastBuy  = -1000
var int lastSell = -1000
fireBuy  = buySig  and (bar_index - lastBuy  > cooldown)
fireSell = sellSig and (bar_index - lastSell > cooldown)
if fireBuy
    lastBuy := bar_index
if fireSell
    lastSell := bar_index

// ===== 贴蜡烛标记 =====
if fireBuy
    label.new(bar_index, low, "Bull Cross", yloc=yloc.belowbar,
         color=color.new(color.teal,0), textcolor=color.white,
         style=label.style_label_up, size=size.small)
if fireSell
    label.new(bar_index, high, "Bear Cross", yloc=yloc.abovebar,
         color=color.new(color.red,0), textcolor=color.white,
         style=label.style_label_down, size=size.small)

// ===== Alerts =====
alertcondition(fireBuy,  "MACD RSI Bull",  "MACD bullish cross with RSI above midline")
alertcondition(fireSell, "MACD RSI Bear", "MACD bearish cross with RSI below midline")
````
