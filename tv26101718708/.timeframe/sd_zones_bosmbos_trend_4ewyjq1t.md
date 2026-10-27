# S&D Zones + BOS/mBOS + Trend

- url: https://www.tradingview.com/script/4EWyJq1t-S-D-Zones-BOS-mBOS-Trend/
- type: indicator
- pine_id: PUB;14f228c1452c4cce8f76187feb63183a
- version: 2.0

## Description

What it does
Supply & Demand Zones

Demand zones (green) form at the base candle of a bullish BOS — where price launched from before breaking a swing high
Supply zones (red) form at the origin candle of a bearish BOS — where price came from before breaking a swing low
Zones auto-extend to the right and are automatically deleted (mitigated) when price closes through them

Break of Structure (BOS)

Solid orange horizontal line + "BOS ▲/▼" label when price closes beyond a prior swing high or low
Represents a confirmed structural shift

Minor Break of Structure (mBOS)

Dashed yellow line + "mBOS ▲/▼" when price wicks through a level but doesn't close beyond it
Signals a liquidity grab / potential reversal without full confirmation

Trend Detection

Uses a 20/50/200 EMA system — bullish when price is above the 200 EMA and the 20 crosses above the 50, bearish when the inverse is true
A "▲ BULLISH / ▼ BEARISH / ◆ NEUTRAL" label updates live in the top-right corner
Subtle green/red background shading reflects the current trend

15-Minute Structure on the 5m Chart

Pulls 15m swing highs/lows and plots them as reference dots
Labels "15m BOS ▲/▼" when the current bar breaks a 15m structural level — great for confluence


Tips for best use

Run it on the 5m chart — it natively pulls 15m data via request.security
Adjust Swing Lookback Length (default 5) — higher = fewer, more significant levels
Use the 15m BOS labels as high-probability entry signals when they align with a visible demand/supply zone
Set alerts via the Alerts menu using the pre-built conditions

## Source Code

````pine
//@version=5
indicator("S&D Zones + BOS/mBOS + Trend", shorttitle="SD+BOS", overlay=true, max_boxes_count=10, max_lines_count=200, max_labels_count=200)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

swingLen      = input.int(5,   "Swing Lookback Length",  group="Structure Settings", minval=2, maxval=20)
bosLookback   = input.int(50,  "BOS Line Length (bars)", group="Structure Settings", minval=10, maxval=200)
zoneExtend    = input.int(50,  "Zone Extension (bars)",  group="Zone Settings",      minval=10, maxval=500)
zoneLineWidth = input.int(1,   "Zone Border Width",      group="Zone Settings",      minval=1,  maxval=3)

supplyColor   = input.color(color.new(color.red,   75), "Supply Zone Color", group="Colors")
demandColor   = input.color(color.new(color.green, 75), "Demand Zone Color", group="Colors")
bosColor      = input.color(color.new(color.orange, 0), "BOS Line Color",    group="Colors")
mbosColor     = input.color(color.new(color.yellow, 0), "mBOS Line Color",   group="Colors")

trendEmaFast  = input.int(20,  "Fast EMA",           group="Trend Settings", minval=5)
trendEmaSlow  = input.int(50,  "Slow EMA",           group="Trend Settings", minval=10)
trendEma200   = input.int(200, "200 EMA",            group="Trend Settings", minval=50)
showEMAs      = input.bool(true, "Show EMAs",        group="Trend Settings")
showLabel     = input.bool(true, "Show Trend Label", group="Trend Settings")
show15mBOS    = input.bool(true, "Show 15m BOS",     group="Timeframe Filters")

// ─────────────────────────────────────────────
// EMAs + TREND
// ─────────────────────────────────────────────

emaFast = ta.ema(close, trendEmaFast)
emaSlow = ta.ema(close, trendEmaSlow)
ema200  = ta.ema(close, trendEma200)

plot(showEMAs ? emaFast : na, "EMA Fast", color=color.new(color.aqua,   0), linewidth=1)
plot(showEMAs ? emaSlow : na, "EMA Slow", color=color.new(color.orange, 0), linewidth=1)
plot(showEMAs ? ema200  : na, "EMA 200",  color=color.new(color.white,  0), linewidth=2)

isBullish = close > ema200 and emaFast > emaSlow
isBearish = close < ema200 and emaFast < emaSlow

trendText = isBullish ? "▲ BULLISH" : isBearish ? "▼ BEARISH" : "◆ NEUTRAL"
trendCol  = isBullish ? color.green  : isBearish ? color.red   : color.gray

if showLabel and barstate.islast
    label.new(bar_index, high * 1.002, trendText, style=label.style_label_left, color=color.new(trendCol, 20), textcolor=color.white, size=size.normal)

bgcolor(isBullish ? color.new(color.green, 95) : isBearish ? color.new(color.red, 95) : na, title="Trend Background")

// ─────────────────────────────────────────────
// SWING HIGHS & LOWS
// ─────────────────────────────────────────────

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow( low,  swingLen, swingLen)

var float lastSwingHigh    = na
var int   lastSwingHighBar = na
var float lastSwingLow     = na
var int   lastSwingLowBar  = na

if not na(swingHigh)
    lastSwingHigh    := swingHigh
    lastSwingHighBar := bar_index - swingLen

if not na(swingLow)
    lastSwingLow    := swingLow
    lastSwingLowBar := bar_index - swingLen

// ─────────────────────────────────────────────
// BOS & mBOS
// ─────────────────────────────────────────────

bosBull  = not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bosBear  = not na(lastSwingLow)  and close < lastSwingLow  and close[1] >= lastSwingLow
mbosBull = not na(lastSwingHigh) and high  > lastSwingHigh and close    <= lastSwingHigh
mbosBear = not na(lastSwingLow)  and low   < lastSwingLow  and close    >= lastSwingLow

if bosBull
    line.new(bar_index - bosLookback, lastSwingHigh, bar_index, lastSwingHigh, color=bosColor, width=2, style=line.style_solid)
    label.new(bar_index, lastSwingHigh, "BOS ▲", style=label.style_label_down, color=color.new(color.orange, 10), textcolor=color.white, size=size.small)

if bosBear
    line.new(bar_index - bosLookback, lastSwingLow, bar_index, lastSwingLow, color=bosColor, width=2, style=line.style_solid)
    label.new(bar_index, lastSwingLow, "BOS ▼", style=label.style_label_up, color=color.new(color.orange, 10), textcolor=color.white, size=size.small)

if mbosBull
    line.new(bar_index - 10, lastSwingHigh, bar_index, lastSwingHigh, color=mbosColor, width=1, style=line.style_dashed)
    label.new(bar_index, lastSwingHigh, "mBOS ▲", style=label.style_label_down, color=color.new(color.yellow, 20), textcolor=color.black, size=size.tiny)

if mbosBear
    line.new(bar_index - 10, lastSwingLow, bar_index, lastSwingLow, color=mbosColor, width=1, style=line.style_dashed)
    label.new(bar_index, lastSwingLow, "mBOS ▼", style=label.style_label_up, color=color.new(color.yellow, 20), textcolor=color.black, size=size.tiny)

// ─────────────────────────────────────────────
// SINGLE ACTIVE ZONE BASED ON TREND
// Bullish trend  → show most recent Demand Zone (at last swing low)
// Bearish trend  → show most recent Supply Zone (at last swing high)
// ─────────────────────────────────────────────

var box activeZone = na

// When trend or structure updates, delete old zone and draw new one
bool drawDemand = isBullish and bosBull and not na(lastSwingLowBar)
bool drawSupply = isBearish and bosBear and not na(lastSwingHighBar)

if drawDemand or drawSupply
    if not na(activeZone)
        box.delete(activeZone)

    if drawDemand
        // Demand zone: body of the swing low candle
        offset   = bar_index - lastSwingLowBar
        zoneTop  = math.max(open[offset], close[offset])
        zoneBot  = low[offset]
        activeZone := box.new(lastSwingLowBar, zoneTop, bar_index + zoneExtend, zoneBot, border_color=color.new(color.green, 30), bgcolor=demandColor, border_width=zoneLineWidth)

    if drawSupply
        // Supply zone: body of the swing high candle
        offset   = bar_index - lastSwingHighBar
        zoneTop  = high[offset]
        zoneBot  = math.min(open[offset], close[offset])
        activeZone := box.new(lastSwingHighBar, zoneTop, bar_index + zoneExtend, zoneBot, border_color=color.new(color.red, 30), bgcolor=supplyColor, border_width=zoneLineWidth)

// Extend active zone to the right each bar
if not na(activeZone)
    box.set_right(activeZone, bar_index + zoneExtend)

// Delete zone if price closes through it (mitigated)
if not na(activeZone)
    if isBullish and close < box.get_bottom(activeZone)
        box.delete(activeZone)
        activeZone := na
    if isBearish and close > box.get_top(activeZone)
        box.delete(activeZone)
        activeZone := na

// ─────────────────────────────────────────────
// 15m HIGHER TIMEFRAME BOS
// ─────────────────────────────────────────────

htfHigh = request.security(syminfo.tickerid, "15", ta.pivothigh(high, swingLen, swingLen), lookahead=barmerge.lookahead_off)
htfLow  = request.security(syminfo.tickerid, "15", ta.pivotlow(low,   swingLen, swingLen), lookahead=barmerge.lookahead_off)

var float htfLastHigh = na
var float htfLastLow  = na

if not na(htfHigh)
    htfLastHigh := htfHigh
if not na(htfLow)
    htfLastLow := htfLow

plot(show15mBOS and not na(htfLastHigh) ? htfLastHigh : na, "15m Swing High", color=color.new(color.red,   40), linewidth=1, style=plot.style_circles)
plot(show15mBOS and not na(htfLastLow)  ? htfLastLow  : na, "15m Swing Low",  color=color.new(color.green, 40), linewidth=1, style=plot.style_circles)

htfBosBull = show15mBOS and not na(htfLastHigh) and close > htfLastHigh and close[1] <= htfLastHigh
htfBosBear = show15mBOS and not na(htfLastLow)  and close < htfLastLow  and close[1] >= htfLastLow

if htfBosBull
    label.new(bar_index, low,  "15m BOS ▲", style=label.style_label_up,   color=color.new(color.teal,   10), textcolor=color.white, size=size.small)
if htfBosBear
    label.new(bar_index, high, "15m BOS ▼", style=label.style_label_down, color=color.new(color.maroon, 10), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(bosBull,    "BOS Bullish",     "Bullish Break of Structure detected!")
alertcondition(bosBear,    "BOS Bearish",     "Bearish Break of Structure detected!")
alertcondition(mbosBull,   "mBOS Bullish",    "Minor Bullish Break of Structure (mBOS)!")
alertcondition(mbosBear,   "mBOS Bearish",    "Minor Bearish Break of Structure (mBOS)!")
alertcondition(htfBosBull, "15m BOS Bullish", "15-Minute Bullish BOS!")
alertcondition(htfBosBear, "15m BOS Bearish", "15-Minute Bearish BOS!")
alertcondition(isBullish,  "Trend: Bullish",  "Market trend is Bullish")
alertcondition(isBearish,  "Trend: Bearish",  "Market trend is Bearish")
````
