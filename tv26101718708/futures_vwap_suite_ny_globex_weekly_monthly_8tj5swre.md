# Futures VWAP Suite - NY / Globex / Weekly / Monthly

- url: https://www.tradingview.com/script/8tJ5SwRe-Futures-VWAP-Suite-NY-Globex-Weekly-Monthly/
- type: indicator
- pine_id: PUB;e02eb47b06984393818ef9fa70ec20d0
- version: 1.0

## Description

Futures VWAP Suite

Four anchored VWAPs in one indicator, built for CME-style futures (ES, NQ, CL, GC, etc.). Each VWAP has an optional volume-weighted standard deviation band so you can see value and extension for the cash session, the full Globex session, the week and the month on one chart.

WHAT IT PLOTS

• NY VWAP — anchored to the 09:30 ET cash open. Runs until the next day's 09:30 open, so overnight trade is measured against the prior RTH value.
• Globex VWAP — anchored to the 18:00 ET session open and runs through 17:00 ET. It is blank during the daily maintenance break.
• Weekly VWAP — resets on the first bar of each trading week.
• Monthly VWAP — resets on the first bar of each month.

Each VWAP can show one band above and below it. The bands are the VWAP ± (multiplier × volume-weighted standard deviation of the source since the anchor). The multiplier is shared by all four VWAPs.

HOW THE ANCHORS WORK

Session times are fixed to New York time, including daylight saving time changes. They land on the same bars whatever time zone your chart is set to.
• The NY and Globex VWAPs work on intraday timeframes only. The Weekly and Monthly VWAPs also work on daily charts.
• RTH-only charts are supported. When the 18:00 ET open is not on the chart, the Globex VWAP resets on the first bar of the new trading day.
• If a bar does not start exactly at 09:30 (for example, 1-hour bars starting on the hour), the NY VWAP resets on the first bar that opens at or after 09:30.
• Each VWAP waits for its first full anchor before it draws, so you never see a misleading partial period at the start of the chart's history.

SETTINGS

General
• Source — price used in the calculation (default hlc3).
• Band Multiplier — how many standard deviations the bands sit from the VWAP (default 1.0).
• Label Size — size of the optional line labels.

Per VWAP (NY, Globex, Weekly, Monthly)
• Show — turns the VWAP on or off.
• Bands — turns its upper and lower bands (and band fill) on or off.
• Labels — adds a text label for the VWAP and bands at the right edge of the chart, in the color you choose.

Line colors, widths, styles and fill opacity are all set in the Style tab, just like the built-in VWAP. To hide a band fill but keep the band lines, set that fill's opacity to 0.

NOTES

• Requires volume data. The script stops with an error on symbols with no volume.
• The Weekly and Monthly resets follow the exchange's trading calendar. For CME futures, the week starts at the Sunday evening open.
• This indicator is for information only and is not a trading signal.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tylerjborg
//@version=6
indicator("Futures VWAP Suite - NY / Globex / Weekly / Monthly", shorttitle="VWAP Suite", overlay=true)

// Four anchored VWAPs for CME-style futures, each with one volume-weighted
// standard deviation band:
//   NY      - resets at the 09:30 ET cash open
//   Globex  - resets at the 18:00 ET session open, blank during the 17:00-18:00 break
//   Weekly  - resets on the first bar of each week
//   Monthly - resets on the first bar of each month
// Session anchors are fixed to New York time, so they land on the same bars
// whatever time zone the chart displays.

//=============================================================================
// CONSTANTS
//=============================================================================

const string TZ           = "America/New_York"
const int    NY_OPEN_MIN  = 9 * 60 + 30   // 09:30 ET
const int    GX_START_MIN = 18 * 60       // 18:00 ET
const int    GX_END_MIN   = 17 * 60       // 17:00 ET

// Default colors (all editable in the Style tab / label color inputs)
const color  C_NY = #00E5FF   // electric cyan
const color  C_GX = #FF9100   // bright orange
const color  C_W  = #FF2BD6   // hot magenta
const color  C_M  = #76FF03   // neon lime

//=============================================================================
// INPUTS
// Line and fill colors, widths and opacity are set in the Style tab.
// Labels are drawings, so their text color is set here.
//=============================================================================

const string G_GEN = "General"
const string G_NY  = "NY VWAP (09:30 ET)"
const string G_GX  = "Globex VWAP (18:00 ET)"
const string G_W   = "Weekly VWAP"
const string G_M   = "Monthly VWAP"

src         = input.source(hlc3, "Source", group=G_GEN)
bandMult    = input.float(1.0, "Band Multiplier", minval=0.1, step=0.1, group=G_GEN,
     tooltip="Distance of the bands from each VWAP, in volume-weighted standard deviations.")
labelSizeIn = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=G_GEN)

showNY      = input.bool(true,  "Show",   group=G_NY, inline="a")
nyBands     = input.bool(true,  "Bands",  group=G_NY, inline="a", active=showNY)
nyLbl       = input.bool(false, "Labels", group=G_NY, inline="a", active=showNY)
nyLblCol    = input.color(C_NY, "", group=G_NY, inline="a", active=showNY and nyLbl)

showGX      = input.bool(true,  "Show",   group=G_GX, inline="a")
gxBands     = input.bool(true,  "Bands",  group=G_GX, inline="a", active=showGX)
gxLbl       = input.bool(false, "Labels", group=G_GX, inline="a", active=showGX)
gxLblCol    = input.color(C_GX, "", group=G_GX, inline="a", active=showGX and gxLbl)

showW       = input.bool(false, "Show",   group=G_W, inline="a")
wBands      = input.bool(true,  "Bands",  group=G_W, inline="a", active=showW)
wLbl        = input.bool(false, "Labels", group=G_W, inline="a", active=showW)
wLblCol     = input.color(C_W, "", group=G_W, inline="a", active=showW and wLbl)

showM       = input.bool(false, "Show",   group=G_M, inline="a")
mBands      = input.bool(true,  "Bands",  group=G_M, inline="a", active=showM)
mLbl        = input.bool(false, "Labels", group=G_M, inline="a", active=showM)
mLblCol     = input.color(C_M, "", group=G_M, inline="a", active=showM and mLbl)

lblSize = switch labelSizeIn
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

//=============================================================================
// VOLUME CHECK (same approach as the built-in VWAP)
//=============================================================================

var float cumVol = 0.0
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

//=============================================================================
// ANCHORS
// Everything with history or internal state is evaluated on every bar, before
// it is combined with "and" (Pine v6 skips the right side of "and"/"or" when
// the left side already decides the result).
//=============================================================================

isIntraday   = timeframe.isintraday
notFirst     = bar_index > 0
minutesOfDay = hour(time, TZ) * 60 + minute(time, TZ)
prevMinutes  = minutesOfDay[1]
newDay       = dayofmonth(time, TZ) != dayofmonth(time[1], TZ)

// NY: first bar at/after 09:30 ET. The second clause handles RTH-only charts and
// bars too wide to straddle 09:30; it stops at 18:00 so the Sunday open can't trigger it.
nyReset = isIntraday and notFirst and (
     (minutesOfDay >= NY_OPEN_MIN and prevMinutes < NY_OPEN_MIN) or
     (newDay and minutesOfDay >= NY_OPEN_MIN and minutesOfDay < GX_START_MIN))

// Globex: first bar at/after 18:00 ET. The second clause handles RTH-only charts,
// where the 18:00 open never prints.
gxReset = isIntraday and notFirst and (
     (minutesOfDay >= GX_START_MIN and prevMinutes < GX_START_MIN) or
     (newDay and prevMinutes < GX_START_MIN))

gxInSession = minutesOfDay >= GX_START_MIN or minutesOfDay < GX_END_MIN

// Latches true at the first real anchor so the partial first period isn't drawn.
f_armed(bool reset) =>
    var bool armed = false
    if reset
        armed := true
    armed

nyArmed = f_armed(nyReset)
gxArmed = f_armed(gxReset)

//=============================================================================
// CALCULATIONS
//=============================================================================

[nyV, nyU, nyL] = ta.vwap(src, nyReset,  bandMult)
[gxV, gxU, gxL] = ta.vwap(src, gxReset,  bandMult)

nyOk = isIntraday and nyArmed
gxOk = isIntraday and gxArmed and gxInSession

//=============================================================================
// WEEKLY / MONTHLY (seeded from a higher timeframe)
// Low-timeframe charts often don't load back to the start of the week or month.
// So the running totals up to the last completed seed bar come from a 30-minute
// feed, which reaches much further back, and the chart's own bars since then are
// added on top. Charts of 30 minutes and up (or ones that don't divide evenly
// into 30 minutes) use the chart itself as the seed.
//=============================================================================

tfSec   = timeframe.in_seconds()
SEED_TF = tfSec < 1800 and 1800 % tfSec == 0 ? "30" : timeframe.period

// Runs on the seed timeframe. Returns the week/month totals of price*volume,
// volume and price^2*volume through the PREVIOUS seed bar (0 at a new period,
// na until the first period start is seen), so nothing looks ahead.
f_seedTotals() =>
    var float wPV  = 0.0
    var float wV   = 0.0
    var float wP2V = 0.0
    var float mPV  = 0.0
    var float mV   = 0.0
    var float mP2V = 0.0
    var bool  wSeen = false
    var bool  mSeen = false
    bool newW = timeframe.change("W")
    bool newM = timeframe.change("M")
    if newW
        wPV  := 0.0
        wV   := 0.0
        wP2V := 0.0
        wSeen := true
    if newM
        mPV  := 0.0
        mV   := 0.0
        mP2V := 0.0
        mSeen := true
    float v = nz(volume)
    wPV  += src * v
    wV   += v
    wP2V += src * src * v
    mPV  += src * v
    mV   += v
    mP2V += src * src * v
    [wSeen ? (newW ? 0.0 : wPV[1])  : na,
     wSeen ? (newW ? 0.0 : wV[1])   : na,
     wSeen ? (newW ? 0.0 : wP2V[1]) : na,
     mSeen ? (newM ? 0.0 : mPV[1])  : na,
     mSeen ? (newM ? 0.0 : mV[1])   : na,
     mSeen ? (newM ? 0.0 : mP2V[1]) : na]

[sWPV, sWV, sWP2V, sMPV, sMV, sMP2V] = request.security(syminfo.tickerid, SEED_TF, f_seedTotals(), lookahead=barmerge.lookahead_on)

// Chart bars inside the current seed bar.
seedNew = timeframe.change(SEED_TF)
var float iPV  = 0.0
var float iV   = 0.0
var float iP2V = 0.0
if seedNew
    iPV  := 0.0
    iV   := 0.0
    iP2V := 0.0
iPV  += src * nz(volume)
iV   += nz(volume)
iP2V += src * src * nz(volume)

f_vwapFromTotals(float pv, float v, float p2v) =>
    float vw = v > 0 ? pv / v : na
    float sd = v > 0 ? math.sqrt(math.max(p2v / v - vw * vw, 0.0)) : na
    [vw, vw + bandMult * sd, vw - bandMult * sd]

[wV, wU, wL] = f_vwapFromTotals(sWPV + iPV, sWV + iV, sWP2V + iP2V)
[mV, mU, mL] = f_vwapFromTotals(sMPV + iPV, sMV + iV, sMP2V + iP2V)

// Wait for the first full seed bar on the chart so a partial one isn't counted.
seedArmed = f_armed(notFirst and seedNew)
wOk = seedArmed and not na(sWV)
mOk = seedArmed and not na(sMV)

//=============================================================================
// PLOTS
//=============================================================================

dNY     = showNY ? display.all : display.none
dNYBand = showNY and nyBands ? display.all : display.none
dGX     = showGX ? display.all : display.none
dGXBand = showGX and gxBands ? display.all : display.none
dW      = showW ? display.all : display.none
dWBand  = showW and wBands ? display.all : display.none
dM      = showM ? display.all : display.none
dMBand  = showM and mBands ? display.all : display.none

// NY
plot(nyOk ? nyV : na, "NY VWAP", C_NY, 2, display=dNY)
pNYU = plot(nyOk ? nyU : na, "NY Upper Band", C_NY, 1, linestyle=plot.linestyle_dashed, display=dNYBand)
pNYL = plot(nyOk ? nyL : na, "NY Lower Band", C_NY, 1, linestyle=plot.linestyle_dashed, display=dNYBand)
fill(pNYU, pNYL, color.new(C_NY, 90), "NY Band Fill", display=dNYBand)

// Globex
plot(gxOk ? gxV : na, "Globex VWAP", C_GX, 2, display=dGX)
pGXU = plot(gxOk ? gxU : na, "Globex Upper Band", C_GX, 1, linestyle=plot.linestyle_dashed, display=dGXBand)
pGXL = plot(gxOk ? gxL : na, "Globex Lower Band", C_GX, 1, linestyle=plot.linestyle_dashed, display=dGXBand)
fill(pGXU, pGXL, color.new(C_GX, 90), "Globex Band Fill", display=dGXBand)

// Weekly
plot(wOk ? wV : na, "Weekly VWAP", C_W, 2, display=dW)
pWU = plot(wOk ? wU : na, "Weekly Upper Band", C_W, 1, linestyle=plot.linestyle_dashed, display=dWBand)
pWL = plot(wOk ? wL : na, "Weekly Lower Band", C_W, 1, linestyle=plot.linestyle_dashed, display=dWBand)
fill(pWU, pWL, color.new(C_W, 90), "Weekly Band Fill", display=dWBand)

// Monthly
plot(mOk ? mV : na, "Monthly VWAP", C_M, 2, display=dM)
pMU = plot(mOk ? mU : na, "Monthly Upper Band", C_M, 1, linestyle=plot.linestyle_dashed, display=dMBand)
pML = plot(mOk ? mL : na, "Monthly Lower Band", C_M, 1, linestyle=plot.linestyle_dashed, display=dMBand)
fill(pMU, pML, color.new(C_M, 90), "Monthly Band Fill", display=dMBand)

//=============================================================================
// LABELS
// One label per line, drawn just right of the last bar. Each call site keeps
// its own label, so this must run on every bar.
//=============================================================================

f_label(bool on, float y, string txt, color textCol) =>
    var label lbl = na
    if barstate.islast
        label.delete(lbl)
        lbl := on and not na(y) ? label.new(bar_index + 1, y, txt, style=label.style_label_left,
             color=color(na), textcolor=textCol, size=lblSize) : na
    lbl

multTxt = str.tostring(bandMult, "#.##") + "σ"

f_label(showNY and nyLbl,                 nyOk ? nyV : na, "NY VWAP",            nyLblCol)
f_label(showNY and nyLbl and nyBands,     nyOk ? nyU : na, "NY +" + multTxt,     nyLblCol)
f_label(showNY and nyLbl and nyBands,     nyOk ? nyL : na, "NY -" + multTxt,     nyLblCol)

f_label(showGX and gxLbl,                 gxOk ? gxV : na, "Globex VWAP",        gxLblCol)
f_label(showGX and gxLbl and gxBands,     gxOk ? gxU : na, "Globex +" + multTxt, gxLblCol)
f_label(showGX and gxLbl and gxBands,     gxOk ? gxL : na, "Globex -" + multTxt, gxLblCol)

f_label(showW and wLbl,                   wOk ? wV : na,   "Weekly VWAP",        wLblCol)
f_label(showW and wLbl and wBands,        wOk ? wU : na,   "Weekly +" + multTxt, wLblCol)
f_label(showW and wLbl and wBands,        wOk ? wL : na,   "Weekly -" + multTxt, wLblCol)

f_label(showM and mLbl,                   mOk ? mV : na,   "Monthly VWAP",        mLblCol)
f_label(showM and mLbl and mBands,        mOk ? mU : na,   "Monthly +" + multTxt, mLblCol)
f_label(showM and mLbl and mBands,        mOk ? mL : na,   "Monthly -" + multTxt, mLblCol)
````
