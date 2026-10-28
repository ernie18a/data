# UnofficialRocket

- url: https://www.tradingview.com/script/EyrMA6TJ-UnofficialRocket/
- type: indicator
- pine_id: PUB;4625189c373f47d2927916ea999798dd
- version: 1.0

## Description

UnofficialRocket is a custom overlay indicator built from a VARIS-style VWAP zone template.

The indicator plots a session VWAP that resets at 6:00 PM New York time and adds adjustable upper and lower point-based bands around VWAP. These zones are designed to help visualize intraday balance, risk intervals, and price distance from VWAP.

UnofficialRocket also includes manual levels for:

Weekly HP
Monthly HP
DD Band High
DD Band Low

These manual levels can be entered directly in the indicator settings and displayed as horizontal chart levels. The DD Band High and DD Band Low can also be filled as a custom zone.

Important: This indicator does not calculate real dealer gamma or real options positioning. The HP and DD levels are manually entered external reference levels. The script is intended as a visual trading tool for VWAP zones, hedge-pressure reference levels, and discretionary market structure analysis.

## Source Code

````pine
//@version=6
indicator("UnofficialRocket", shorttitle="UR", overlay=true)

// ═══════════════════════════════════════════════════════════════
// DISCLAIMER
// Weekly HP, Monthly HP, DD Band High, and DD Band Low are
// manually entered external levels. This indicator does NOT
// calculate real dealer gamma or real options positioning.
// ═══════════════════════════════════════════════════════════════


// ─────────────────────────────────────────────────────────────
// SECTION 1 — VWAP Settings
// ─────────────────────────────────────────────────────────────
grpVWAP       = "── Session VWAP ──"
showVWAP      = input.bool(true,              "Show VWAP",            group=grpVWAP)
vwapColor     = input.color(color.white,      "VWAP Color",           group=grpVWAP)
vwapWidth     = input.int(2,                  "VWAP Width",           group=grpVWAP, minval=1, maxval=5)

// ─────────────────────────────────────────────────────────────
// SECTION 2 — VWAP Band Settings
// ─────────────────────────────────────────────────────────────
grpBands      = "── VWAP Bands ──"
showBands     = input.bool(true,              "Show Bands",           group=grpBands)
bandDist      = input.float(20.0,             "Band Distance (Points)", group=grpBands, minval=0.25, step=0.25)
upperColor    = input.color(color.new(color.teal, 0),   "Upper Band Color", group=grpBands)
lowerColor    = input.color(color.new(color.red,  0),   "Lower Band Color", group=grpBands)
bandWidth     = input.int(1,                  "Band Width",           group=grpBands, minval=1, maxval=5)
showBandFill  = input.bool(true,              "Fill Between Bands",   group=grpBands)
bandFillColor = input.color(color.new(color.gray, 85),  "Band Fill Color",  group=grpBands)

// ─────────────────────────────────────────────────────────────
// SECTION 3 — Weekly HP (Manually Entered External Level)
// ─────────────────────────────────────────────────────────────
grpWHP        = "── Weekly HP ──"
showWHP       = input.bool(true,              "Show Weekly HP",        group=grpWHP)
whpLevel      = input.float(0.0,              "Weekly HP Level",       group=grpWHP, step=0.25)
whpColor      = input.color(color.yellow,     "Weekly HP Color",       group=grpWHP)
whpWidth      = input.int(2,                  "Weekly HP Width",       group=grpWHP, minval=1, maxval=5)

// ─────────────────────────────────────────────────────────────
// SECTION 4 — Monthly HP (Manually Entered External Level)
// ─────────────────────────────────────────────────────────────
grpMHP        = "── Monthly HP ──"
showMHP       = input.bool(true,              "Show Monthly HP",       group=grpMHP)
mhpLevel      = input.float(0.0,              "Monthly HP Level",      group=grpMHP, step=0.25)
mhpColor      = input.color(color.orange,     "Monthly HP Color",      group=grpMHP)
mhpWidth      = input.int(2,                  "Monthly HP Width",      group=grpMHP, minval=1, maxval=5)

// ─────────────────────────────────────────────────────────────
// SECTION 5 — DD Band (Manually Entered External Levels)
// ─────────────────────────────────────────────────────────────
grpDD         = "── DD Band ──"
showDDHigh    = input.bool(true,              "Show DD Band High",     group=grpDD)
ddHighLevel   = input.float(0.0,              "DD Band High Level",    group=grpDD, step=0.25)
ddHighColor   = input.color(color.lime,       "DD Band High Color",    group=grpDD)
ddHighWidth   = input.int(1,                  "DD Band High Width",    group=grpDD, minval=1, maxval=5)

showDDLow     = input.bool(true,              "Show DD Band Low",      group=grpDD)
ddLowLevel    = input.float(0.0,              "DD Band Low Level",     group=grpDD, step=0.25)
ddLowColor    = input.color(color.red,        "DD Band Low Color",     group=grpDD)
ddLowWidth    = input.int(1,                  "DD Band Low Width",     group=grpDD, minval=1, maxval=5)

showDDFill    = input.bool(true,              "Fill DD Band",          group=grpDD)
ddFillColor   = input.color(color.new(color.purple, 80), "DD Band Fill Color", group=grpDD)


// ─────────────────────────────────────────────────────────────
// SECTION 6 — Session VWAP Calculation
//             Resets at 18:00 New York time (CME Globex open)
// ─────────────────────────────────────────────────────────────
nyHour = hour(time, "America/New_York")

// Fire a reset on the first bar ever, or when NY time crosses 18:00
isSessionReset = barstate.isfirst or (nyHour >= 18 and nyHour[1] < 18)

var float cumVP  = 0.0
var float cumVol = 0.0

tp = (high + low + close) / 3.0

if isSessionReset
    cumVP  := tp * volume
    cumVol := volume
else
    cumVP  += tp * volume
    cumVol += volume

sessionVWAP = cumVol > 0 ? cumVP / cumVol : tp
upperBand   = sessionVWAP + bandDist
lowerBand   = sessionVWAP - bandDist


// ─────────────────────────────────────────────────────────────
// SECTION 7 — Plot: Session VWAP and Bands
// ─────────────────────────────────────────────────────────────
pVWAP  = plot(showVWAP  ? sessionVWAP : na, title="Session VWAP", color=vwapColor, linewidth=vwapWidth)
pUpper = plot(showBands ? upperBand   : na, title="Upper Band",   color=upperColor, linewidth=bandWidth)
pLower = plot(showBands ? lowerBand   : na, title="Lower Band",   color=lowerColor, linewidth=bandWidth)

fill(pUpper, pLower, color=showBandFill ? bandFillColor : na, title="VWAP Band Fill")


// ─────────────────────────────────────────────────────────────
// SECTION 8 — Plot: Manual Hedge Pressure Levels
// ─────────────────────────────────────────────────────────────

// Weekly HP — hidden when level is 0
plot(showWHP and whpLevel != 0 ? whpLevel : na,
     title     = "Weekly HP",
     color     = whpColor,
     linewidth = whpWidth,
     style     = plot.style_line)

// Monthly HP — hidden when level is 0
plot(showMHP and mhpLevel != 0 ? mhpLevel : na,
     title     = "Monthly HP",
     color     = mhpColor,
     linewidth = mhpWidth,
     style     = plot.style_line)

// DD Band High — hidden when level is 0
pDDHigh = plot(showDDHigh and ddHighLevel != 0 ? ddHighLevel : na,
               title     = "DD Band High",
               color     = ddHighColor,
               linewidth = ddHighWidth,
               style     = plot.style_line)

// DD Band Low — hidden when level is 0
pDDLow = plot(showDDLow and ddLowLevel != 0 ? ddLowLevel : na,
              title     = "DD Band Low",
              color     = ddLowColor,
              linewidth = ddLowWidth,
              style     = plot.style_line)

// DD Band Fill — only renders when both levels are set and fill is enabled
bool canFillDD = showDDFill and ddHighLevel != 0 and ddLowLevel != 0
fill(pDDHigh, pDDLow, color=canFillDD ? ddFillColor : na, title="DD Band Fill")
````
