# Inside Outside Pin Bar Colors

- url: https://www.tradingview.com/script/gbP4c5kC-Inside-Outside-Pin-Bar-Colors/
- type: indicator
- pine_id: PUB;75edab58ec21472a811794f083a88320
- version: 1.0

## Description

Inside Outside Pin Bar Colors — Indicator Description
Inside Outside Pin Bar Colors is a clean, practical price‑action tool designed to highlight three of the most widely used bar‑based patterns: Inside Bars, Outside Bars, and Pin Bars.
If you trade structure, volatility compression, breakout behavior, or wick‑driven rejection signals, this script gives you a fast, visual way to spot them without cluttering your chart.

What It Detects
• Inside Bars  
A bar fully contained within the previous bar’s high–low range. Useful for identifying contraction, balance, and breakout setups.

• Outside Bars  
A bar that takes out both the prior high and low. The script lets you choose the lookback window (classic = 1 bar) and colors bullish vs bearish outside bars differently.

• Pin Bars  
A bar that pokes beyond recent extremes and snaps back inside the prior bar’s range, with strict wick‑to‑body and wick‑to‑wick ratios.
You can customize:

Lookback window for the “poke”

Wick‑to‑body multiplier

Opposite‑wick multiplier

Optional volume filter (volume must exceed previous bar)

Smart Coloring Logic
Each bar can only have one color. You choose whether Pin Bar colors override Outside Bar colors or vice‑versa. Inside Bars are lowest priority and only color when no higher‑priority pattern is present.

Customization Options
Toggle each pattern type on/off

Independent color selection for all pattern categories

Adjustable pin‑bar rules

Adjustable outside‑bar lookback

Optional tiny triangle markers for pin bars

Full alert support for all pattern types

Alerts Included
Inside Bar

Outside Bar (bullish / bearish)

Bullish Pin Bar

Bearish Pin Bar

Why Traders Use These Patterns
Inside Bars highlight compression before expansion

Outside Bars reveal volatility spikes and failed breakouts

Pin Bars show rejection, absorption, and short‑term sentiment shifts

This indicator brings all three together in a single, lightweight, easy‑to‑read visual tool. Whether you trade breakouts, reversals, or simply want clearer structure recognition, it helps you see the story of each bar at a glance.

## Source Code

````pine
//@version=6
indicator("Inside Outside Pin Bar Colors", shorttitle="Inside Outside Pin Bar Colors", overlay=true)
// by WaveWalker
// ───────────────────────────── INPUTS ─────────────────────────────
gShow = "Patterns"
showIB     = input.bool(true, "Inside Bar",         group=gShow)
showOB     = input.bool(true, "Outside Bar",        group=gShow)
showBullPB = input.bool(true, "Bullish Pin Bar",    group=gShow)
showBearPB = input.bool(true, "Bearish Pin Bar",    group=gShow)

gCol = "Colors"
colIB     = input.color(#FFD600, "Inside Bar",        group=gCol)
colBullOB = input.color(#2962FF, "Outside Bar (up)",  group=gCol, tooltip="Outside bar that closes at or above its open")
colBearOB = input.color(#AB47BC, "Outside Bar (down)", group=gCol, tooltip="Outside bar that closes below its open. Set equal to the 'up' color if you want one color for all outside bars.")
colBullPB = input.color(#00E676, "Bullish Pin Bar",   group=gCol)
colBearPB = input.color(#FF1744, "Bearish Pin Bar",   group=gCol)

gPB = "Pin Bar Rules"
pbLookback = input.int(3, "Lookback (bars)", minval=1, maxval=999, group=gPB, tooltip="Pin bar must poke beyond the highest high / lowest low of this many prior bars")
wickMult   = input.float(3.0, "Wick must be > X × body", minval=0.1, step=0.1, group=gPB)
oppMult    = input.float(2.0, "Wick must be > X × opposite wick", minval=0.1, step=0.1, group=gPB)
useVol     = input.bool(true, "Volume filter (volume > prior bar)", group=gPB)

gOB = "Outside Bar Rules"
obLookback = input.int(1, "Lookback (bars)", minval=1, maxval=999, group=gOB, tooltip="Outside bar must take out the highest high AND lowest low of this many prior bars. 1 = classic outside bar.")

gMisc = "Display"
pinPriority = input.bool(true, "Pin bar color wins over outside bar color", group=gMisc, tooltip="A single bar can only have one color. If a bar is both a pin bar and an outside bar, this decides which color shows.")
showMarkers = input.bool(false, "Also show small pin bar markers", group=gMisc)

// ───────────────────────────── LOGIC ─────────────────────────────
body      = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

hhPB = ta.highest(high, pbLookback)[1]
llPB = ta.lowest(low,  pbLookback)[1]
hhOB = ta.highest(high, obLookback)[1]
llOB = ta.lowest(low,  obLookback)[1]

volOK = useVol ? volume > volume[1] : true

// Pin bars: poke past recent extreme, close back inside prior bar's range, long rejection wick
bullPB = low  < llPB and close > low[1]  and volOK and lowerWick > wickMult * body and lowerWick > oppMult * upperWick
bearPB = high > hhPB and close < high[1] and volOK and upperWick > wickMult * body and upperWick > oppMult * lowerWick

// Outside bar: takes out both the high and the low of the lookback window
outside = high > hhOB and low < llOB
bullOB  = outside and close >= open
bearOB  = outside and close <  open

// Inside bar: strictly inside prior bar's range
inside = high < high[1] and low > low[1]

// Apply on/off toggles
ibOn     = showIB and inside
bullOBon = showOB and bullOB
bearOBon = showOB and bearOB
bullPBon = showBullPB and bullPB
bearPBon = showBearPB and bearPB

// ───────────────────────────── BAR COLORING ─────────────────────────────
// Lowest priority is applied first; later assignments override earlier ones.
color barCol = na

if ibOn
    barCol := colIB

if pinPriority
    if bullOBon
        barCol := colBullOB
    if bearOBon
        barCol := colBearOB
    if bullPBon
        barCol := colBullPB
    if bearPBon
        barCol := colBearPB
else
    if bullPBon
        barCol := colBullPB
    if bearPBon
        barCol := colBearPB
    if bullOBon
        barCol := colBullOB
    if bearOBon
        barCol := colBearOB

barcolor(barCol, title="Pattern Bar Color")

// Optional markers
plotshape(showMarkers and bullPBon, "Bullish Pin Bar Marker", shape.triangleup,   location.belowbar, colBullPB, size=size.tiny)
plotshape(showMarkers and bearPBon, "Bearish Pin Bar Marker", shape.triangledown, location.abovebar, colBearPB, size=size.tiny)

// ───────────────────────────── ALERTS ─────────────────────────────
alertcondition(ibOn,                    "Inside Bar",       "Inside Bar")
alertcondition(bullOBon or bearOBon,    "Outside Bar",      "Outside Bar")
alertcondition(bullOBon,                "Outside Bar (up)", "Bullish Outside Bar")
alertcondition(bearOBon,                "Outside Bar (down)", "Bearish Outside Bar")
alertcondition(bullPBon,                "Bullish Pin Bar",  "Bullish Pin Bar")
alertcondition(bearPBon,                "Bearish Pin Bar",  "Bearish Pin Bar")
````
