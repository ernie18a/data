# SFP Trend & VWAP Liquidity Pro [Zofesu]

- url: https://www.tradingview.com/script/73QBBD1w-SFP-Trend-VWAP-Liquidity-Pro-Zofesu/
- type: indicator
- pine_id: PUB;ae75437ee8e04dde9a05ca964316e393
- version: 1.0

## Description

[b]SFP Trend & VWAP Liquidity Pro [Zofesu][/b] is an overlay indicator that combines three concepts into a unified liquidity sweep detection system: Swing Failure Pattern detection, real-time swing high/low liquidity tracking, and dual independent trend filtering via VWAP or MA.

The three components are interdependent — SFP signals are only valid when the sweep direction aligns with both trend filters. Without the filters, SFP signals are too frequent and unreliable. Without the SFP engine, the filters alone are standard trend tools. The combination produces high-probability reversal entries at institutional liquidity levels.

─────────────────────────────────────
[b]01 — What is STVL Pro?[/b]
─────────────────────────────────────
[b]STVL Pro detects Swing Failure Patterns (SFP)[/b] — moments when price sweeps beyond a prior swing high or low, trapping breakout traders, then closes back inside the range. These are classic institutional liquidity grabs at known stop-loss clusters.

The indicator tracks the most recent swing high and low in real time, draws them as horizontal liquidity lines, and fires a BULL or BEAR SFP label only when:
— A liquidity sweep is detected AND
— Both trend filters confirm the reversal direction

─────────────────────────────────────
[b]02 — Why This Combination?[/b]
─────────────────────────────────────
[b]SFP[/b] patterns occur at all swing highs and lows — most are low quality. The dual VWAP/MA filter solves this by requiring the sweep to occur in a context where institutional bias supports the reversal.

[b]Example:[/b] A bullish SFP (sweep below swing low, close back above) is only labeled if price is also above both Filter A and Filter B. This confirms the sweep happened in a bullish macro context — not against the institutional trend.

This filtering approach significantly reduces false signals compared to raw SFP detection.

─────────────────────────────────────
[b]03 — SFP Engine[/b]
─────────────────────────────────────
The script tracks market structure using a configurable Swing Lookback Period (default 150 bars).

[b]Bullish SFP conditions:[/b]
— Current low < last swing low
— Current close > last swing low
— Previous low > last swing low (first bar to breach)

[b]Bearish SFP conditions:[/b]
— Current high > last swing high
— Current close < last swing high
— Previous high < last swing high (first bar to breach)

This three-condition check ensures only clean, confirmed sweeps trigger — not extended wicks or multi-bar breaches.

─────────────────────────────────────
[b]04 — Dual Trend Filter (Filter A & B)[/b]
─────────────────────────────────────
Two independent filters run simultaneously. Each can be set to:

[b]VWAP[/b] — Anchored to Session, Week, Month, or Year.
[b]HMA[/b] — Hull Moving Average for smooth trend detection.
[b]EMA[/b] — Exponential MA for faster trend response.
[b]SMA[/b] — Simple MA for clean institutional levels.
[b]Off[/b] — Disable filter for raw SFP tracking.

[b]Default:[/b] Both filters set to VWAP (Session anchor).
Filter A length: 2000 | Filter B length: 5000

The two filters use different sensitivities intentionally — Filter A is faster, Filter B is slower. A signal requires both to agree, providing multi-scale trend confirmation.

─────────────────────────────────────
[b]05 — Visuals[/b]
─────────────────────────────────────
[b]BULL SFP label (green)[/b] — bullish sweep confirmed by both filters
[b]BEAR SFP label (red)[/b] — bearish sweep confirmed by both filters

[b]Upper Liquidity Line (red)[/b] — current swing high being monitored
[b]Lower Liquidity Line (green)[/b] — current swing low being monitored

[b]Filter A line[/b] — color changes based on price position relative to filter
[b]Filter B line[/b] — color changes based on price position relative to filter

─────────────────────────────────────
[b]06 — Settings[/b]
─────────────────────────────────────
[b]Filter A / B Type[/b] — VWAP, HMA, EMA, SMA, or Off
[b]Filter A / B Length[/b] — smoothing period when using MA types
[b]VWAP Reset (Anchor)[/b] — Session, Week, Month, Year, None
[b]Swing Lookback Period[/b] — default 150 bars

[b]For scalping:[/b] reduce Lookback to 50–75, use Session VWAP.
[b]For swing trading:[/b] keep 150+ lookback, use Month or Year VWAP anchor.

─────────────────────────────────────
[b]07 — How To Use[/b]
─────────────────────────────────────
[b]Step 1[/b] — Monitor the red and green liquidity lines
These represent the current swing high and low being watched.

[b]Step 2[/b] — Watch for a sweep
Price moves beyond the line — this is the potential SFP forming.

[b]Step 3[/b] — Wait for the label
BULL or BEAR SFP label appears only on confirmed close back inside the range with both filters aligned. Do not anticipate — wait for the closed candle.

[b]Step 4[/b] — Enter on the next candle
The label appears on the sweep candle after close. Entry is on the opening of the next candle with SL beyond the sweep wick.

[b]Works on all asset classes:[/b] Indices, Forex, Gold, Oil, Crypto.
Best timeframes: H1, H4, D1.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu

//@version=6
indicator("SFP Trend & VWAP Liquidity Pro [Zofesu]", shorttitle="Zofesu - STVL Pro", overlay=true, max_labels_count=500)

// --- AUXILIARY FUNCTION ---
getFilter(type, len, anchor_period) =>
    float res = na
    if type == "HMA"
        res := ta.hma(close, len)
    else if type == "EMA"
        res := ta.ema(close, len)
    else if type == "SMA"
        res := ta.sma(close, len)
    else if type == "VWAP"
        if anchor_period == "Session"
            res := ta.vwap(hlc3, timeframe.change("D"))
        else if anchor_period == "Week"
            res := ta.vwap(hlc3, timeframe.change("W"))
        else if anchor_period == "Month"
            res := ta.vwap(hlc3, timeframe.change("M"))
        else if anchor_period == "Year"
            res := ta.vwap(hlc3, timeframe.change("12M"))
        else
            res := ta.vwap 
    res

// --- INPUTS ---
groupA       = "Filter A "
typeA        = input.string("VWAP", "Type", options=["HMA", "EMA", "SMA", "VWAP", "Off"], group=groupA, inline="A")
lenA         = input.int(2000, "Length", group=groupA, inline="A")
colUpA       = input.color(color.new(#00ffbb, 50), "↑", group=groupA, inline="A")
colDnA       = input.color(color.new(#ff0055, 50), "↓", group=groupA, inline="A")

groupB       = "Filter B "
typeB        = input.string("VWAP", "Type", options=["HMA", "EMA", "SMA", "VWAP", "Off"], group=groupB, inline="B")
lenB         = input.int(5000, "Length", group=groupB, inline="B")
colUpB       = input.color(color.new(#21f33d, 50), "↑", group=groupB, inline="B")
colDnB       = input.color(color.new(#ff0000, 50), "↓", group=groupB, inline="B")

vwapAnchor   = input.string("Session", "VWAP Reset (Anchor)", options=["Session", "Week", "Month", "Year", "None"], group="VWAP Settings")
lookback     = input.int(150, "Swing Lookback Period", minval=5, group="SFP Settings")

// --- CALCULATIONS ---
valA = getFilter(typeA, lenA, vwapAnchor)
valB = getFilter(typeB, lenB, vwapAnchor)

trendUpA = typeA == "Off" or close > valA
trendUpB = typeB == "Off" or close > valB
trendDnA = typeA == "Off" or close < valA
trendDnB = typeB == "Off" or close < valB

swh = ta.pivothigh(high, lookback, lookback)
swl = ta.pivotlow(low, lookback, lookback)
var float last_swh = na
var float last_swl = na
if not na(swh)
    last_swh := swh
if not na(swl)
    last_swl := swl

sfp_bullish = low < last_swl and close > last_swl and low[1] > last_swl
sfp_bearish = high > last_swh and close < last_swh and high[1] < last_swh

// --- VISUALIZATION ---
plot(valA, "Filter A", color = trendUpA ? colUpA : colDnA, linewidth=2)
plot(valB, "Filter B", color = trendUpB ? colUpB : colDnB, linewidth=2)

plot(last_swh, "Upper Liquidity (Swing High)", color=color.new(#ff0000, 60), style=plot.style_linebr)
plot(last_swl, "Lower Liquidity (Swing Low)", color=color.new(#00ff08, 60), style=plot.style_linebr)

longCondition  = sfp_bullish and trendUpA and trendUpB
shortCondition = sfp_bearish and trendDnA and trendDnB

if longCondition
    label.new(bar_index, low, "BULL SFP", color=#2e7d32, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar, force_overlay=true)

if shortCondition
    label.new(bar_index, high, "BEAR SFP", color=#c62828, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar, force_overlay=true)
````
