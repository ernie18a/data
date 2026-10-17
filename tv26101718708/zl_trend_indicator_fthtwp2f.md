# ZL Trend Indicator

- url: https://www.tradingview.com/script/fThtWp2f/
- type: indicator
- pine_id: PUB;53a6c9989e314c8eb9836a7b5081a1d6
- version: 1.0

## Description

█ OVERVIEW

ZL Trend Indicator (ZLT) is an original indicator inspired by the concept of Zero Lag moving averages and order block retest entries.

The core idea: when the Zero Lag MA crosses the base EMA, an ATR-based support/resistance zone is drawn. A triangle signal fires when price retests that zone and bounces back — confirming the move rather than chasing the initial cross.

This script is a fully independent implementation built from scratch.

█ HOW IT WORKS

• Zero Lag MA (ZLMA): Reduces EMA lag by adding the difference between close and EMA to the source, then applying a second EMA. Result is a smoother, faster-responding MA.
• Base EMA: Standard EMA used as the trend reference.
• Trend Zone: When ZLMA crosses EMA, an ATR-based zone (two horizontal lines) is fixed at the cross level. Upper/lower boundaries update only on new crosses.
• Retest Signal: Once price enters the zone, ZLT watches for a bounce. The triangle fires on the first bar where price closes back outside the zone — confirming rejection.

█ SIGNALS

◆ Diamond — ZLMA crosses EMA (trend shift)
▲ Triangle Up — Bullish retest confirmed: price touched zone, bounced above it
▼ Triangle Down — Bearish retest confirmed: price touched zone, dropped below it

█ SETTINGS

Zero Lag MA
• ZLMA Length (default 15) — period for both EMAs in the ZLMA calculation

Trend Zone
• Zone ATR Period (default 200) — ATR period used to set zone width at each cross

Colors
• + / − — customize bullish and bearish colors

█ ALERTS

• Triangle Signal ▲▼ — BUY and SELL combined (saves alert slots)
• Diamond Signal ◆ — ZLMA cross only
• BUY Signal ▲ — bullish retest bounce only
• SELL Signal ▼ — bearish retest bounce only

Set alerts to "Once Per Bar Close" for best accuracy.

█ NOTES

• Works best combined with a trend filter such as a 200 EMA — for example, only taking BUY triangles when price is above the 200 EMA.
• Higher timeframes tend to produce cleaner signals with less noise.
• Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
// ZL Trend Indicator [ZLT]
// Original implementation
// (1) Zero Lag MA (ZLMA): EMA with lag reduced by close-EMA correction
// (2) Trend Zone: ATR-based upper/lower lines set at each cross
// (3) Retest Signal: Triangle fires after price retests zone and bounces
indicator("ZL Trend Indicator", shorttitle="ZLT", overlay=true, max_lines_count=500)

// --- Parameters ---
var g_ma = "Zero Lag MA"
var g_lv = "Trend Zone"

length   = input.int(15,  title="ZLMA Length",     minval=2,  group=g_ma)
atrLevel = input.int(200, title="Zone ATR Period", minval=10, group=g_lv)

colUp = input.color(color.rgb(48, 212, 83), "+", group="Colors", inline="c")
colDn = input.color(color.rgb(64, 67, 241), "-", group="Colors", inline="c")

// --- Zero Lag MA ---
// Reduce EMA lag by adding the difference between close and EMA
ema1 = ta.ema(close, length)
corr = close + (close - ema1)
zlma = ta.ema(corr, length)

// --- Cross Detection ---
crossUp   = ta.crossover (zlma, ema1)
crossDown = ta.crossunder(zlma, ema1)
isBull    = zlma > ema1
isBear    = zlma < ema1

// --- Trend Zone (ATR-based lines fixed at each cross) ---
atrL = ta.atr(atrLevel)

var float zoneTop     = na
var float zoneBot     = na
var bool  touchedZone = false
var bool  inBull      = false

if crossUp
    zoneTop     := zlma
    zoneBot     := zlma - atrL
    touchedZone := false
    inBull      := true

if crossDown
    zoneTop     := zlma + atrL
    zoneBot     := zlma
    touchedZone := false
    inBull      := false

// --- Retest Detection ---
if not na(zoneTop) and not touchedZone
    if inBull     and low  <= zoneTop and low  >= zoneBot
        touchedZone := true
    if not inBull and high >= zoneBot and high <= zoneTop
        touchedZone := true

// --- Entry Signals (first bar after retest bounce) ---
buySignal_raw  = inBull      and touchedZone and close > zoneTop
sellSignal_raw = not inBull  and touchedZone and close < zoneBot

buySignal  = buySignal_raw  and not buySignal_raw[1]
sellSignal = sellSignal_raw and not sellSignal_raw[1]

// --- Visuals ---
zlmaCol = zlma > zlma[3] ? colUp : zlma < zlma[3] ? colDn : color.gray
emaCol  = ema1 < zlma ? colUp : colDn

p1 = plot(zlma, title="ZLMA", color=zlmaCol, linewidth=2)
p2 = plot(ema1, title="EMA",  color=emaCol,  linewidth=1)
fill(p1, p2, color=color.new(color.gray, 85))

// Zone upper / lower lines
zoneCol = inBull ? colUp : colDn
plot(zoneTop, title="Zone Top", color=color.new(zoneCol, 40), linewidth=1, style=plot.style_line)
plot(zoneBot, title="Zone Bot", color=color.new(zoneCol, 40), linewidth=1, style=plot.style_line)

// Diamond markers (cross signal)
plotshape(crossUp   ? zlma : na, "", shape.diamond, location.absolute, color=colUp, size=size.tiny)
plotshape(crossDown ? zlma : na, "", shape.diamond, location.absolute, color=colDn, size=size.tiny)

// Triangle markers (retest bounce signal)
plotshape(buySignal,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=colUp, size=size.small)
plotshape(sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=colDn, size=size.small)

// --- Alerts ---
alertcondition((buySignal  or sellSignal) and barstate.isconfirmed, title="Triangle Signal", message="{{ticker}}, {{interval}}: Triangle Signal")
alertcondition((crossUp    or crossDown)  and barstate.isconfirmed, title="Diamond Signal",  message="{{ticker}}, {{interval}}: ZLMA Cross")
alertcondition(buySignal   and barstate.isconfirmed,                title="BUY Signal",      message="{{ticker}}, {{interval}}: BUY")
alertcondition(sellSignal  and barstate.isconfirmed,                title="SELL Signal",     message="{{ticker}}, {{interval}}: SELL")
````
