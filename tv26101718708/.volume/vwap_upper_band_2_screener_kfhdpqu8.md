# VWAP Upper Band 2 Screener

- url: https://www.tradingview.com/script/KFHdPQu8-VWAP-Upper-Band-2-Screener/
- type: indicator
- pine_id: PUB;6b2fc722f07d4d3eaf66ecd3be2025e3
- version: 1.0

## Description

VWAP Upper Band 2 Screener, determine length of time a stock has been rising. an increasing volatility will indicate VWAP in upper band 2

## Source Code

````pine
//@version=5
indicator("VWAP Upper Band 2 Screener", shorttitle="Above VWAP UB2", overlay=false)

// ─── VWAP Settings ───────────────────────────────────────────────────────────
var anchor = input.string("Session", "Anchor Period", options=["Session","Week","Month","Quarter","Year"])
mult1      = input.float(1.0, "Band 1 Multiplier", minval=0.1, step=0.1)
mult2      = input.float(2.0, "Band 2 Multiplier", minval=0.1, step=0.1)

// ─── Anchor Reset Logic ──────────────────────────────────────────────────────
isNewPeriod() =>
    switch anchor
        "Session"  => timeframe.change("D")
        "Week"     => timeframe.change("W")
        "Month"    => timeframe.change("M")
        "Quarter"  => timeframe.change("3M")
        "Year"     => timeframe.change("12M")
        => timeframe.change("D")

// ─── VWAP Calculation ────────────────────────────────────────────────────────
var float cumTPV  = na
var float cumVol  = na
var float cumTPV2 = na

if isNewPeriod()
    cumTPV  := 0.0
    cumVol  := 0.0
    cumTPV2 := 0.0

typicalPrice = (high + low + close) / 3
cumTPV  := nz(cumTPV)  + typicalPrice * volume
cumVol  := nz(cumVol)  + volume
cumTPV2 := nz(cumTPV2) + typicalPrice * typicalPrice * volume

vwap     = cumTPV / cumVol
variance = math.max(cumTPV2 / cumVol - vwap * vwap, 0)
stDev    = math.sqrt(variance)

upperBand1 = vwap + mult1 * stDev
upperBand2 = vwap + mult2 * stDev

// ─── Signal ──────────────────────────────────────────────────────────────────
aboveUB2 = close > upperBand2

// ─── Screener Column Output ──────────────────────────────────────────────────
plot(aboveUB2 ? 1 : 0, title="Above VWAP UB2", color=aboveUB2 ? color.new(color.green, 0) : color.new(color.red, 0), style=plot.style_histogram, linewidth=4, display=display.pane + display.status_line)

// ─── Optional: visual labels ─────────────────────────────────────────────────
bgcolor(aboveUB2 ? color.new(color.green, 85) : na, title="Above UB2 Highlight")

// ─── Debug info (remove if not needed) ───────────────────────────────────────
plot(vwap, "VWAP", color.blue, display=display.status_line)
plot(upperBand2, "Upper Band 2", color.orange, display=display.status_line)
````
