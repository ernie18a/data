# Gemini Quant OS - VCP Structure

- url: https://www.tradingview.com/script/GpWElyux/
- type: indicator
- pine_id: PUB;2fcb65ac17984f279a721bfd2b343061
- version: 1.0

## Description

Overview

Gemini Quant OS — VCP Structure is a volatility contraction analysis framework inspired by modern momentum trading methodologies.

This script is part of the broader Gemini Quant OS ecosystem.


---

Core Concepts

The framework attempts to identify contraction structures where volatility gradually decreases before a potential directional expansion move.

The model analyzes:

volatility contraction behavior

price structure tightening

breakout pressure

trend alignment

relative momentum

contraction sequence development


The framework is designed to help traders visually identify structured consolidation phases.


---

Features

VCP structure visualization

Volatility contraction detection

Trend-aware filtering

Breakout structure analysis

Multi-market support

Momentum context analysis



---

Best Use Cases

Best suited for:

momentum trading

breakout preparation

contraction phase analysis

swing trading

H1–D1 environments



---

Notes

This script is intended for educational and analytical purposes only.

Not financial advice.


---

## Source Code

````pine
//@version=6
indicator("Gemini VCP Setup Detector", overlay=true, max_labels_count=500)

//========================
// Inputs
//========================
groupVcp = "VCP Definition"
pivotLen = input.int(5, "Pivot Length", minval=2, group=groupVcp)
needSwings = input.int(3, "Swings Needed (Highs/Lows)", minval=2, maxval=5, group=groupVcp)

rangeShort = input.int(20, "Recent Range Window", minval=10, group=groupVcp)
rangeLong = input.int(60, "Prior Range Window", minval=20, group=groupVcp)
rangeRatio = input.float(0.65, "Range Contraction Ratio (Recent/Prior <=)", step=0.05, group=groupVcp)

atrLen = input.int(14, "ATR Length", minval=5, group=groupVcp)
atrRatio = input.float(0.80, "ATR Contraction Ratio (Recent/Prior <=)", step=0.05, group=groupVcp)

groupVol = "Volume Filters"
volLen = input.int(20, "Volume SMA Length", minval=5, group=groupVol)
volQuiet = input.float(0.80, "Quiet Volume Factor (Vol <= SMA * )", step=0.05, group=groupVol)
volBreak = input.float(1.50, "Breakout Volume Factor (Vol >= SMA * )", step=0.05, group=groupVol)

groupRisk = "Breakout Logic"
useCloseBreak = input.bool(true, "Breakout by Close > Pivot High (else High > Pivot High)", group=groupRisk)
bufferPct = input.float(0.10, "Breakout Buffer % (e.g. 0.10 = 0.10%)", step=0.05, group=groupRisk)

//========================
// Helpers
//========================
float volSma = ta.sma(volume, volLen)
bool volIsQuiet = volume <= volSma * volQuiet
bool volIsBreak = volume >= volSma * volBreak

float atr = ta.atr(atrLen)
float atrS = ta.sma(atr, rangeShort)
float atrL = ta.sma(atr, rangeLong)
bool atrContract = (atrS / atrL) <= atrRatio

float rHighS = ta.highest(high, rangeShort)
float rLowS = ta.lowest(low, rangeShort)
float rHighL = ta.highest(high, rangeLong)
float rLowL = ta.lowest(low, rangeLong)
float rangeS = rHighS - rLowS
float rangeL = rHighL - rLowL
bool rangeContract = (rangeS / rangeL) <= rangeRatio

//========================
// Pivot tracking (store last N pivot highs/lows)
//========================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float[] pivH = array.new_float()
var float[] pivL = array.new_float()

if not na(ph)
    array.unshift(pivH, ph)
    if array.size(pivH) > needSwings
        array.pop(pivH)

if not na(pl)
    array.unshift(pivL, pl)
    if array.size(pivL) > needSwings
        array.pop(pivL)

// Enough swings?
bool haveSwings = array.size(pivH) >= needSwings and array.size(pivL) >= needSwings

//========================
// VCP structure: lower highs + higher lows (tightening)
//========================
bool lowerHighs = false
bool higherLows = false

if haveSwings
    // newest is [0]
    lowerHighs := true
    for i = 0 to needSwings - 2
        lowerHighs := lowerHighs and (array.get(pivH, i) < array.get(pivH, i + 1))

    higherLows := true
    for i = 0 to needSwings - 2
        higherLows := higherLows and (array.get(pivL, i) > array.get(pivL, i + 1))

bool vcpStructure = haveSwings and lowerHighs and higherLows

//========================
// Define "VCP Setup"
// - tightening structure
// - range contraction + ATR contraction
// - quiet volume (current bar)
//========================
bool vcpSetup = vcpStructure and rangeContract and atrContract and volIsQuiet

//========================
// Breakout level = most recent pivot high (newest in array)
//========================
float lastPivotHigh = haveSwings ? array.get(pivH, 0) : na
float breakBuffer = not na(lastPivotHigh) ? lastPivotHigh * (bufferPct / 100.0) : na
float breakLevel = not na(lastPivotHigh) ? (lastPivotHigh + breakBuffer) : na

bool breakTrig =
     haveSwings and
     vcpSetup and
     volIsBreak and
     (
       useCloseBreak ? (close > breakLevel) : (high > breakLevel)
     )

//========================
// Plots / Marks
//========================
plot(breakLevel, "Break Level", color=color.new(color.orange, 0), linewidth=1, style=plot.style_linebr)

plotshape(vcpSetup, title="VCP Setup", style=shape.circle, size=size.tiny, color=color.new(color.aqua, 0), text="VCP", location=location.belowbar)
plotshape(breakTrig, title="VCP Breakout", style=shape.triangleup, size=size.small, color=color.new(color.lime, 0), text="BO", location=location.belowbar)

//========================
// Alerts
//========================
alertcondition(vcpSetup, title="VCP Setup Alert", message="VCP SETUP detected on {{ticker}} ({{interval}}). Tightening + contraction + quiet volume.")
alertcondition(breakTrig, title="VCP Breakout Alert", message="VCP BREAKOUT on {{ticker}} ({{interval}}). Break above pivot high with volume confirmation.")

// Optional: show a label on breakout
if breakTrig
    label.new(bar_index, low, "VCP BO\n" + str.tostring(breakLevel, format.mintick), style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 0))
````
