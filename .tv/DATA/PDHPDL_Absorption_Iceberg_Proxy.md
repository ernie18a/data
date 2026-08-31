<!-- tradingview-pine-id: PUB;5657dbd428a04d848c25b2336aeb9b75 -->
<!-- tradingviewscripts-format: 1 -->
# PDH/PDL + Absorption (Iceberg Proxy)

Source: https://www.tradingview.com/script/BsD6HEtt-PDH-PDL-Absorption-Iceberg-Proxy/

## Description

Plots prior-day high/low and flags potential absorption (iceberg-style) activity at those levels: bars with abnormally high volume but abnormally tight range, occurring near a key level. High volume with little price movement suggests large resting orders are absorbing aggression without letting the level break — a classic footprint ahead of either a rejection or an eventual breakout once the absorbed side gives up.

What it plots
- Prior Day High (red line) / Prior Day Low (green line)
- Optional Premarket High/Low (orange/blue circles, 4:00–9:30 ET, off by default)
- Fuchsia triangle + "ABS" label with volume printed, on any bar flagged as absorption

Signal logic
A bar is flagged when all conditions are met:
1. Volume > user-defined multiple of its N-bar average (default 1.8x over 20 bars)
2. Range (high−low) < user-defined multiple of its N-bar average (default 0.6x over 20 bars)
3. (Optional, on by default) Close is within a user-defined tolerance of PDH or PDL

Inputs
- Show Prior Day High/Low — toggle
- Show Premarket High/Low — toggle
- Level Proximity Tolerance (points) — how close price must be to PDH/PDL to qualify; scale this to your instrument's typical range (tighter for MES/M2K, wider for ES/RTY)
- Volume Lookback / Range Lookback (bars) — averaging windows
- Volume Threshold (x average) — higher = rarer, stronger signals
- Range Threshold (x average) — lower = requires tighter compression
- Only Flag Near PDH/PDL — restrict signal to key levels vs. anywhere on chart

How to use it
This is a confirmation tool, not an entry trigger. An ABS flag at PDH/PDL means volume is being absorbed at that level without a clean break — treat it as "this level is being defended right now." Wait for the next bar(s) to resolve:
- Close pushes through the level on continued volume → likely real break, absorption failed
- Price rejects back away from the level → absorption held, fade back into range

An alert condition ("Absorption/Iceberg Detected") is included — right-click the indicator on the chart → Add Alert to get notified instead of watching manually.

Notes
- PDH/PDL are computed via request.security on the daily timeframe with lookahead_off, so they won't repaint.
- Defaults are a reasonable starting point, not calibrated to any specific instrument — backtest/observe before trusting the thresholds on a new symbol.
- Not a "true" iceberg indicator because it infers absorption from OHLCV (high volume + tight range) rather than reading the actual order book, so it can't confirm a hidden order exists — but it's a useful free proxy for spotting "high effort, low result" zones worth watching, especially layered with PDH/PDL, VWAP, or GEX levels.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MaHaRaJa81

//@version=6
indicator("PDH/PDL + Absorption (Iceberg Proxy)", overlay=true)

// ============================================================
// SECTION 1: Previous Day High/Low (+ optional Premarket H/L)
// ============================================================

showPDHL      = input.bool(true, "Show Prior Day High/Low", group="PDH/PDL")
showPMHL      = input.bool(false, "Show Premarket High/Low", group="PDH/PDL")
levelTolPts   = input.float(2.0, "Level Proximity Tolerance (points)", minval=0.0, group="PDH/PDL",
                 tooltip="How close (in price points) absorption must be to PDH/PDL to count as 'at a level'. Adjust for ES vs MES vs other symbols.")

[prevDayHigh, prevDayLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_off)

plot(showPDHL ? prevDayHigh : na, color=color.new(color.red, 0),   style=plot.style_line, linewidth=1, title="PDH")
plot(showPDHL ? prevDayLow  : na, color=color.new(color.green, 0), style=plot.style_line, linewidth=1, title="PDL")

// Premarket high/low (US session example: 4:00-9:30 ET). Adjust session string to your market.
pmSession = "0400-0930"
inPM = not na(time(timeframe.period, pmSession + ":1234567", "America/New_York"))
var float pmHigh = na
var float pmLow  = na
newDay = ta.change(time("D")) != 0
if newDay
    pmHigh := na
    pmLow  := na
if inPM
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow, low)

plot(showPMHL ? pmHigh : na, color=color.new(color.orange, 0), style=plot.style_circles, title="PM High")
plot(showPMHL ? pmLow  : na, color=color.new(color.blue, 0),   style=plot.style_circles, title="PM Low")

// ============================================================
// SECTION 2: Absorption / Iceberg Proxy Detection
// ============================================================

volLen      = input.int(20, "Volume Lookback (bars)", minval=5, group="Absorption")
rangeLen    = input.int(20, "Range Lookback (bars)", minval=5, group="Absorption")
volMult     = input.float(1.8, "Volume Threshold (x average)", minval=1.0, step=0.1, group="Absorption")
rangeMult   = input.float(0.6, "Range Threshold (x average, lower = tighter)", minval=0.1, step=0.1, group="Absorption")
onlyAtLevel = input.bool(true, "Only Flag Near PDH/PDL", group="Absorption")

avgVol   = ta.sma(volume, volLen)
avgRange = ta.sma(high - low, rangeLen)
barRange = high - low

highVol    = volume > avgVol * volMult
tightRange = barRange < avgRange * rangeMult

nearPDH = math.abs(close - prevDayHigh) <= levelTolPts
nearPDL = math.abs(close - prevDayLow)  <= levelTolPts
nearLevel = nearPDH or nearPDL

rawAbsorption = highVol and tightRange
absorptionSignal = onlyAtLevel ? (rawAbsorption and nearLevel) : rawAbsorption

plotshape(absorptionSignal, title="Absorption/Iceberg Flag", location=location.abovebar,
     style=shape.triangledown, size=size.small, color=color.new(color.fuchsia, 0),
     text="ABS")

// ============================================================
// SECTION 3: Alerts
// ============================================================

alertcondition(absorptionSignal, title="Absorption/Iceberg Detected",
     message="Possible absorption/iceberg: high volume, tight range")

if absorptionSignal
    label.new(bar_index, high, "ABS\nV:" + str.tostring(volume, "#"),
         style=label.style_label_down, color=color.new(color.fuchsia, 70),
         textcolor=color.white, size=size.tiny)
````
