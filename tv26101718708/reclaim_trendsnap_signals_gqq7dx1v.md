# Reclaim TrendSnap Signals

- url: https://www.tradingview.com/script/GqQ7DX1V-Reclaim-TrendSnap-Signals/
- type: indicator
- pine_id: PUB;a19c4383c91641cea7c03d662e6f009f
- version: 1.0

## Description

Reclaim TrendSnap Signals

What it does

This indicator tracks trend direction using a smoothed EMA and generates BUY/SELL signals whenever price makes a sharp "reclaim" move back through that EMA after briefly testing the opposite side — a classic pullback-and-continuation pattern.


How it works

1.Trend Detection — The indicator establishes a trend state (up or down) only after two consecutive closes confirm price has settled on one side of the EMA. This filters out single-bar noise and whipsaws.

2.The Reclaim Setup — Once a trend is confirmed:
BUY fires when, during an uptrend, a candle's low dips below the EMA but the candle still opens and closes above it — showing buyers stepped in and reclaimed the level.
SELL fires when, during a downtrend, a candle's high pokes above the EMA but the candle opens and closes below it — showing sellers defended the level.

3.Cooldown Filter — A minimum bar count (Min Bars Between Signals) must pass since the trend last flipped before a new signal can print, avoiding signals that are too close to a fresh trend change.

4.Candle Color Filter (optional) — Tighten signal quality by requiring the reclaim candle to be green (for BUY) or red (for SELL), ensuring the close isn't just barely above/below open.

5.One Signal Per Cycle (optional) — Limits output to a single BUY or SELL per trend cycle, so you get one clean entry signal instead of repeated alerts while the trend persists.

[b]The Visual — TrendSnap Histogram[/b]

Instead of a plain EMA line, the trend EMA is displayed as a colored histogram band (lime = EMA rising above its own smoothed trail, red = EMA falling below it), making the underlying trend momentum easier to read at a glance. This is purely visual — the signal logic always uses the raw, unsmoothed EMA underneath.
[i][b]
Best used for[/b][/i]

Spotting trend-continuation entries after a shakeout — i.e., catching the moment a pullback fails and price snaps back in the direction of the prevailing trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartTrader-X

//@version=6
indicator("Reclaim TrendSnap Signals", overlay=true, max_labels_count=500)

// ─── Inputs ───────────────────────────────────────────────
trendSnapLength       = input.int(65, "Trend Length")
minBarsBetweenSignals = input.int(20, "Min Bars Between Signals")

enableSnapBuy  = input.bool(true, "Enable BUY (Long)")
enableSnapSell = input.bool(true, "Enable SELL (Short)")

// New options
strictBuyCandle  = input.bool(false, "BUY: only GREEN candle legal in uptrend",  group="Candle Color Filter")
strictSellCandle = input.bool(false, "SELL: only RED candle legal in downtrend", group="Candle Color Filter")
oneSnapPerCycle  = input.bool(true,  "Show only 1 signal per cycle",             group="Signal Frequency")

// ─── EMA Plot Look Inputs (Histogram style) ────────────────
pulseSmoothLen = input.int(20, "EMA Smoothing Length (for histogram look)", group="EMA Plot Look")

// ─── Trend EMA (drives the signal logic, unchanged) ────────
trendEma = ta.ema(close, trendSnapLength)

// ---- Second-stage smoothing of the SAME ema, just for the visual ----
trendPulse = ta.ema(trendEma, pulseSmoothLen)

pulseColor = trendEma > trendPulse ? color.lime : color.red

// ---- Histogram-style body (fill between ema and its smoothed self) ----
pTrendEma   = plot(trendEma,   color=color.new(pulseColor, 100), title="Trend EMA")
pTrendPulse = plot(trendPulse, color=color.new(pulseColor, 100), title="Trend Pulse (Smoothed)")
fill(pTrendEma, pTrendPulse, color=pulseColor, title="TrendSnap Histogram")

isGreenCandle = close > open
isRedCandle   = close < open

// ─── Trend State (Reclaim Cycle Tracking) ──────────────────
var trendState   = ""
var cycleStartBar = 0

// one-signal-per-cycle guards
var bool buySnapped  = false
var bool sellSnapped = false

if trendState == "" or trendState == "up"
    if close < trendEma and close[1] < trendEma[1]
        trendState    := "down"
        cycleStartBar := bar_index[1]

if trendState == "" or trendState == "down"
    if close > trendEma and close[1] > trendEma[1]
        trendState    := "up"
        cycleStartBar := bar_index[1]

// reset per-cycle flags when a new cycle starts
if trendState == "up" and trendState[1] != "up"
    buySnapped := false
if trendState == "down" and trendState[1] != "down"
    sellSnapped := false

// ─── BUY Signal (Reclaim Long) ──────────────────────────────
greenCandleOK  = strictBuyCandle ? isGreenCandle : true
buySnapSignal  = low < trendEma and close > trendEma and greenCandleOK and trendState == "up" and (bar_index - cycleStartBar > minBarsBetweenSignals) and open > trendEma and close > trendEma
buySnapAllowed = not oneSnapPerCycle or not buySnapped

if buySnapSignal and buySnapAllowed and enableSnapBuy
    buySnapped := true
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.green, textcolor=color.white)

// ─── SELL Signal (Reclaim Short) ────────────────────────────
redCandleOK     = strictSellCandle ? isRedCandle : true
sellSnapSignal  = high > trendEma and close < trendEma and redCandleOK and trendState == "down" and (bar_index - cycleStartBar > minBarsBetweenSignals) and open < trendEma and close < trendEma
sellSnapAllowed = not oneSnapPerCycle or not sellSnapped

if sellSnapSignal and sellSnapAllowed and enableSnapSell
    sellSnapped := true
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red, textcolor=color.white)

// ─── Alerts ───────────────────────────────────────────────
alertcondition(buySnapSignal and buySnapAllowed and enableSnapBuy,   title="Buy Signal",  message="BUY signal")
alertcondition(sellSnapSignal and sellSnapAllowed and enableSnapSell, title="Sell Signal", message="SELL signal")
````
