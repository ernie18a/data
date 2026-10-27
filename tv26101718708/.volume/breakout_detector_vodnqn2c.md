# Breakout Detector

- url: https://www.tradingview.com/script/vodNqn2C-Breakout-Detector/
- type: indicator
- pine_id: PUB;ec94e82d66744faba30d94443c057d86
- version: 1.0

## Description

breakout detector is a market structure and breakout confirmation tool built to track dynamic price rails, identify compression, evaluate participation, map swing structure, and confirm breakouts only when price action meets a defined set of conditions.

the indicator is designed around a simple principle: crossing a level is not enough to qualify as a confirmed breakout. the breakout engine requires a confirmed close beyond the previous rail together with sufficient candle displacement and relative volume participation.

rail engine

the upper and lower rails form the core structure of the indicator.

rail length
sets the donchian calculation period used to build the base upper and lower boundaries. shorter values make the rails react faster to recent price action, while longer values create slower structural levels.

rail smoothing
applies ema smoothing to the calculated rails. increasing this value produces smoother and less reactive boundaries.

atr envelope padding
adds an atr-based envelope around the donchian structure. this helps prevent minor price movements around the raw highs and lows from being treated as meaningful structural breaks.

adaptive padding
when enabled, the rail padding automatically adjusts using recent volatility in addition to the base atr padding.

draw rails
shows or hides the upper and lower rail system on the chart.

breakout confirmation

the breakout engine works from the previous confirmed rail values rather than allowing the current breakout candle to move its own threshold.

a confirmed breakout requires three main conditions:

close — price must close beyond the previous rail. wick-only penetration is rejected.

body displacement — the breakout candle must have enough body size relative to the previous atr.

relative volume — current volume must meet the configured participation threshold compared with the previous 50-bar average.

detect confirmed breakouts
enables or disables the breakout engine.

min body displacement
controls the minimum candle body size required for confirmation, expressed as a multiple of atr.

higher values demand stronger displacement. lower values make the detector more sensitive.

min relative volume
defines the minimum participation required for a breakout.

for example, a value of 1.15 requires current volume to reach approximately 1.15 times the reference volume.

breakout history
controls how many confirmed breakout events are retained by the indicator, up to 50.

show breakout markers
displays historical confirmed breakout markers directly at the rail price that triggered each event.

the engine records only one event for each breakout episode. another breakout in the same direction cannot be generated continuously while price remains outside the rail. the engine is re-armed after a confirmed close returns inside the previous rail channel.

compression

the compression engine compares bollinger bands with a keltner channel and also calculates a normalized compression score from recent bollinger bandwidth.

bb / kc length
sets the calculation period used by both systems.

bollinger mult
controls bollinger band width.

keltner mult
controls keltner channel width.

compression field
enables the visual field between the rails when compression conditions become significant.

the institutional panel can display three compression states:

armed — bollinger bands are inside the keltner channel.

charging — compression is elevated according to the bandwidth compression score.

open — no strong compression condition is currently detected.

compression does not represent a breakout by itself. it provides information about volatility contraction that may precede expansion.

market structure

the indicator can automatically identify confirmed swing structure.

hh — higher high
lh — lower high
hl — higher low
ll — lower low

hh / lh / hl / ll
enables or disables structure labels.

swing pivot length
controls how much confirmation is required around a pivot. larger values produce fewer, more significant structural points, while smaller values react to shorter-term swings.

these labels can help determine whether a breakout agrees with the surrounding market structure or is occurring against it.

volume delta

delta gradient on bars
colors candles according to an approximation of directional lower-timeframe volume.

the indicator automatically selects a lower timeframe according to the current chart timeframe and aggregates positive or negative volume based on lower-timeframe candle direction.

positive delta indicates greater estimated bullish directional volume, while negative delta indicates greater estimated bearish directional volume.

this is an approximation derived from lower-timeframe price and volume data. it is not exchange bid/ask footprint delta.

chart visuals

three chart themes are available:

institutional
graphite cyan
graphite gold

rail halo
adds a wider transparent layer around the rails for increased visual separation.

current distance to rails
shows the current distance from price to the upper and lower rails in atr units.

rail grid
adds internal horizontal reference levels between the upper and lower rails.

extend right
controls how far visual rail elements extend beyond the current bar.

institutional panel

the panel provides a compact real-time view of the breakout environment.

engine
shows whether the breakout detector is armed or whether an upper or lower breakout episode is currently active.

regime
classifies the current environment as drift, compression, expansion, breakout up, or breakout down.

upper rail / lower rail
shows each current rail price together with its distance from market price in atr units.

compression
shows the current compression state and normalized compression score.

flow
uses the normalized slope of the rail midpoint to classify directional movement as ascent, descent, or neutral.

participation
shows current relative volume.

ltf delta
shows the approximate lower-timeframe directional volume delta.

last break
displays the direction, age, and rail price of the most recent confirmed breakout.

history
shows how many breakout events are currently stored.

confirmation
reminds the user that breakout confirmation is based on close, body displacement, and relative volume.

the panel can be positioned in any chart corner and displayed in tiny, small, or normal text size.

quick start

start with the default settings and allow the rails to define the current structural price channel.

watch the regime and compression fields. when compression begins to increase, volatility is contracting and the market may be preparing for expansion, although compression alone does not determine direction.

use the upper and lower rails as the active breakout boundaries.

when price approaches a rail, check participation, lower-timeframe delta, flow, and surrounding hh/lh/hl/ll structure for additional context.

a wick through a rail will not produce a confirmed breakout.

for an upper breakout, the candle must close above the previous upper rail, close bullish, meet the minimum body displacement requirement, and satisfy the relative volume threshold.

the opposite conditions apply to a lower breakout.

after confirmation, the breakout is stored in history and marked at the rail level that triggered the event.

the engine remains locked for repeated signals in that direction until price closes back inside the rail channel. this prevents a sequence of candles outside the same boundary from being counted as multiple independent breakouts.

adjusting sensitivity

for stricter breakout confirmation, increase min body displacement and min relative volume. this requires stronger price expansion and participation before an event is accepted.

for more responsive rails, reduce rail length or rail smoothing.

for slower structural rails, increase these values.

increasing atr envelope padding moves the breakout boundaries farther away from the underlying donchian extremes and can filter smaller boundary violations.

reducing the padding creates tighter rails and increases sensitivity.

a larger swing pivot length focuses the structure engine on more significant swings. a smaller value provides more detailed short-term structure.

how it can help

breakout detector is designed to reduce the ambiguity around price moving through support or resistance.

instead of treating every penetration as a breakout, it combines structural boundaries with confirmed closing price, candle displacement, relative volume participation, volatility compression, directional flow, lower-timeframe volume behavior, and swing structure.

it can help with:

identifying dynamic breakout boundaries

filtering wick-only rail penetrations

distinguishing simple boundary tests from confirmed displacement

tracking volatility compression before expansion

measuring participation behind a move

visualizing distance to structural levels in atr terms

reading hh, lh, hl, and ll market structure

observing approximate lower-timeframe directional volume

tracking previous confirmed breakout events

creating alerts for confirmed upper and lower breakouts

the indicator also includes a separate compression-start alert and hidden data outputs for the upper rail, lower rail, mid rail, compression score, normalized slope, approximate lower-timeframe delta, and breakout events.

the tool is intended to provide structured market context and breakout confirmation data. it does not predict whether a breakout will continue and does not replace risk management or independent trade analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("BREAKOUT DETECTOR",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 200)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
const string G1 = "🏛️  RAIL ENGINE"
const string G2 = "💥  BREAKOUT CONFIRMATION"
const string G3 = "⚡  COMPRESSION"
const string G4 = "🧭  STRUCTURE"
const string G5 = "📊  VOLUME DELTA"
const string G6 = "🎨  VISUALS"
const string G7 = "🖥️  INSTITUTIONAL PANEL"

int   railLen    = input.int(20, "Rail Length (Donchian core)", minval = 5, group = G1)
int   railSmooth = input.int(3, "Rail Smoothing", minval = 1, maxval = 8, group = G1)
float atrPad     = input.float(0.25, "ATR Envelope Padding", minval = 0.0, step = 0.05, group = G1)
bool  dynamicPad = input.bool(true, "Adaptive Padding", group = G1)
bool  showRails  = input.bool(true, "Draw Rails", group = G1)

bool  detectBreak = input.bool(true, "Detect Confirmed Breakouts", group = G2)
float dispMult    = input.float(0.60, "Min Body Displacement (ATR x)", minval = 0.0, step = 0.1, group = G2,
     tooltip = "Breakout candle body must exceed this multiple of the PRIOR confirmed ATR.")
float volMult     = input.float(1.15, "Min Relative Volume", minval = 0.5, step = 0.05, group = G2,
     tooltip = "Breakout volume is compared with the PRIOR 50-bar average to avoid self-coupling.")
int   historyMax  = input.int(50, "Breakout History", minval = 1, maxval = 50, group = G2,
     tooltip = "Keeps only the most recent confirmed breakout events.")
bool  showBreaks  = input.bool(true, "Show Breakout Markers", group = G2)

int   bbLen      = input.int(20, "BB / KC Length", minval = 5, group = G3)
float bbMult     = input.float(2.0, "Bollinger Mult", minval = 0.5, step = 0.1, group = G3)
float kcMult     = input.float(1.5, "Keltner Mult", minval = 0.5, step = 0.1, group = G3)
bool  showEnergy = input.bool(true, "Compression Field", group = G3)

bool showStruct = input.bool(true, "HH / LH / HL / LL", group = G4)
int  swingLen   = input.int(8, "Swing Pivot Length", minval = 2, group = G4)

bool showDelta = input.bool(true, "Delta Gradient on Bars", group = G5,
     tooltip = "Approximate lower-timeframe directional volume; not exchange bid/ask footprint delta.")

string themeSel = input.string("Institutional", "Chart Theme",
     options = ["Institutional", "Graphite Cyan", "Graphite Gold"], group = G6)
bool laserFx    = input.bool(true, "Rail Halo", group = G6)
bool showPulse  = input.bool(true, "Current Distance to Rails", group = G6)
bool showGrid   = input.bool(false, "Rail Grid", group = G6)
int  extendR    = input.int(6, "Extend Right (bars)", minval = 0, group = G6)

string dashPos  = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G7)
string dashSize = input.string("Small", "Panel Size",
     options = ["Tiny", "Small", "Normal"], group = G7)
bool showHud    = input.bool(true, "Show Institutional Panel", group = G7)

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────
bool isInst = themeSel == "Institutional"
bool isCyan = themeSel == "Graphite Cyan"

color cUp    = isInst ? #43B59E : isCyan ? #36C9C6 : #B8A06A
color cDn    = isInst ? #C96978 : isCyan ? #D36573 : #C66B65
color cAlert = isInst ? #C7A96B : isCyan ? #7BA7C9 : #D0B16F
color cIon   = isInst ? #8293A8 : isCyan ? #6F9EAE : #918A7C
color cGrid  = #26313D

color pBg      = #0B0F14
color pHeader  = #111820
color pCell    = #0E141B
color pBorder  = #293541
color pText    = #D7DEE7
color pMuted   = #7E8A99
color pBull    = #43B59E
color pBear    = #C96978
color pGold    = #C7A96B
color pBlue    = #829DB8

// ─────────────────────────────────────────────────────────────────────────────
// CORE SERIES
// ─────────────────────────────────────────────────────────────────────────────
float atrV     = ta.atr(14)
float atrRef   = atrV[1]
float volSma   = ta.sma(volume, 50)
float volRef   = volSma[1]
float rvol     = not na(volRef) and volRef > 0 ? volume / volRef : na

float donHi = ta.highest(high, railLen)
float donLo = ta.lowest(low, railLen)

float volScale = not na(atrV) and atrV > 0 ? ta.stdev(close, railLen) / (atrV * 10.0) : 0.0
float pad      = atrV * (dynamicPad ? atrPad + volScale : atrPad)
float rawUp    = donHi + pad
float rawDn    = donLo - pad
float upRail   = ta.ema(rawUp, railSmooth)
float dnRail   = ta.ema(rawDn, railSmooth)
float midRail  = (upRail + dnRail) / 2.0

// Breakout thresholds are frozen to the PRIOR confirmed rail.
float pUp = upRail[1]
float pDn = dnRail[1]

// Bollinger / Keltner compression
float basis = ta.sma(close, bbLen)
float dev   = bbMult * ta.stdev(close, bbLen)
float bbUp  = basis + dev
float bbDn  = basis - dev
float kcAtr = ta.atr(bbLen)
float kcUp  = basis + kcMult * kcAtr
float kcDn  = basis - kcMult * kcAtr
bool squeeze = bbUp < kcUp and bbDn > kcDn

float bbw    = basis != 0 ? (bbUp - bbDn) / basis : na
float bbwMin = ta.lowest(bbw, 100)
float bbwMax = ta.highest(bbw, 100)
float compScore = not na(bbw) and bbwMax > bbwMin ? math.max(0.0, math.min(1.0, 1.0 - (bbw - bbwMin) / (bbwMax - bbwMin))) : 0.0

float slopeAtr = not na(atrV) and atrV > 0 ? (midRail - midRail[5]) / 5.0 / atrV : 0.0

// Structure pivots are calculated every bar, then consumed only on confirmed bars.
float structPH = ta.pivothigh(swingLen, swingLen)
float structPL = ta.pivotlow(swingLen, swingLen)

// ─────────────────────────────────────────────────────────────────────────────
// LOWER-TF DIRECTIONAL VOLUME DELTA APPROXIMATION
// ─────────────────────────────────────────────────────────────────────────────
int tfSec = timeframe.in_seconds(timeframe.period)
string autoLtf = tfSec <= 300 ? "1" : tfSec <= 3600 ? "5" : tfSec <= 14400 ? "15" : "60"
array<float> ltfD = request.security_lower_tf(
     syminfo.tickerid,
     autoLtf,
     close > open ? volume : close < open ? -volume : 0.0)

float barDelta = 0.0
int dsz = array.size(ltfD)
if dsz > 0
    for i = 0 to dsz - 1
        barDelta += array.get(ltfD, i)
else
    barDelta := close > open ? volume : close < open ? -volume : 0.0

float deltaNorm = not na(volRef) and volRef > 0 ? math.max(-1.0, math.min(1.0, barDelta / (volRef * 1.5))) : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// breakoutState: 0 = armed/inside, +1 = active upper breakout, -1 = active lower.
// A new same-direction event is impossible until price has closed back inside.
// An opposite confirmed breakout is treated as a new breakout.
// ─────────────────────────────────────────────────────────────────────────────
var int breakoutState = 0
var int brkBar = na
var int brkDir = 0
var float brkPx = na
var float brkClose = na

var array<int> evtBar = array.new_int()
var array<int> evtDir = array.new_int()
var array<float> evtPx = array.new_float()
var array<float> evtClose = array.new_float()

var array<int> swBar = array.new_int()
var array<float> swPx = array.new_float()
var array<int> swKind = array.new_int()
var array<string> swTag = array.new_string()

var array<line> drawLn = array.new_line()
var array<label> drawLb = array.new_label()

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_txtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_dashPos(string s) =>
    s == "Top Right" ? position.top_right :
     s == "Top Left" ? position.top_left :
     s == "Bottom Right" ? position.bottom_right : position.bottom_left

f_wipe() =>
    while array.size(drawLn) > 0
        line.delete(array.pop(drawLn))
    while array.size(drawLb) > 0
        label.delete(array.pop(drawLb))

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMED EVENT ENGINE
// ─────────────────────────────────────────────────────────────────────────────
bool breakUp = false
bool breakDn = false

if barstate.isconfirmed
    bool railsReady = not na(pUp) and not na(pDn)
    bool bodyReady  = not na(atrRef) and atrRef > 0
    bool volumeReady = not na(rvol)

    // Re-arm only after a confirmed close returns inside the PRIOR rail channel.
    bool backInside = railsReady and close <= pUp and close >= pDn
    if breakoutState != 0 and backInside
        breakoutState := 0

    float body = math.abs(close - open)
    bool dispOK = bodyReady and body >= dispMult * atrRef
    bool volOK  = volumeReady and rvol >= volMult

    // Close beyond the prior rail is mandatory. Wick-only pierces are rejected.
    bool rawBreakUp = detectBreak and railsReady and close > pUp and close > open and dispOK and volOK
    bool rawBreakDn = detectBreak and railsReady and close < pDn and close < open and dispOK and volOK

    // One event per breakout episode.
    if rawBreakUp and breakoutState != 1
        breakUp := true
        breakoutState := 1
        brkBar := bar_index
        brkDir := 1
        brkPx := pUp
        brkClose := close
        array.push(evtBar, bar_index)
        array.push(evtDir, 1)
        array.push(evtPx, pUp)
        array.push(evtClose, close)

    else if rawBreakDn and breakoutState != -1
        breakDn := true
        breakoutState := -1
        brkBar := bar_index
        brkDir := -1
        brkPx := pDn
        brkClose := close
        array.push(evtBar, bar_index)
        array.push(evtDir, -1)
        array.push(evtPx, pDn)
        array.push(evtClose, close)

    while array.size(evtBar) > historyMax
        array.shift(evtBar)
        array.shift(evtDir)
        array.shift(evtPx)
        array.shift(evtClose)

    // Confirmed HH/LH/HL/LL history.
    if showStruct
        if not na(structPH)
            float prevH = na
            int szH = array.size(swPx)
            if szH > 0
                for i = 0 to szH - 1
                    int idx = szH - 1 - i
                    if array.get(swKind, idx) == 1 and na(prevH)
                        prevH := array.get(swPx, idx)
            string tagH = na(prevH) ? "H" : structPH > prevH ? "HH" : "LH"
            array.push(swBar, bar_index - swingLen)
            array.push(swPx, structPH)
            array.push(swKind, 1)
            array.push(swTag, tagH)

        if not na(structPL)
            float prevL = na
            int szL = array.size(swPx)
            if szL > 0
                for i = 0 to szL - 1
                    int idx = szL - 1 - i
                    if array.get(swKind, idx) == -1 and na(prevL)
                        prevL := array.get(swPx, idx)
            string tagL = na(prevL) ? "L" : structPL > prevL ? "HL" : "LL"
            array.push(swBar, bar_index - swingLen)
            array.push(swPx, structPL)
            array.push(swKind, -1)
            array.push(swTag, tagL)

        while array.size(swBar) > 40
            array.shift(swBar)
            array.shift(swPx)
            array.shift(swKind)
            array.shift(swTag)

// ─────────────────────────────────────────────────────────────────────────────
// REGIME
// ─────────────────────────────────────────────────────────────────────────────
string regime = "⚪ DRIFT"
color regC = pMuted

if squeeze or compScore >= 0.70
    regime := "⚡ COMPRESSION"
    regC := pGold
else if math.abs(slopeAtr) >= 0.20
    regime := slopeAtr > 0 ? "📈 EXPANSION" : "📉 EXPANSION"
    regC := slopeAtr > 0 ? pBull : pBear

if breakoutState == 1
    regime := "🟢 BREAKOUT UP"
    regC := pBull
else if breakoutState == -1
    regime := "🔴 BREAKOUT DOWN"
    regC := pBear

// ─────────────────────────────────────────────────────────────────────────────
// BAR COLORING
// ─────────────────────────────────────────────────────────────────────────────
color barCol = na
if showDelta
    color base = deltaNorm >= 0 ? cUp : cDn
    int tr = int(65.0 - math.abs(deltaNorm) * 40.0)
    barCol := color.new(base, tr)
barcolor(barCol)

// ─────────────────────────────────────────────────────────────────────────────
// PRICE-ATTACHED RAILS
// ─────────────────────────────────────────────────────────────────────────────
pUpCore = plot(showRails ? upRail : na, "Upper Rail", color = color.new(cUp, 8), linewidth = 2)
pDnCore = plot(showRails ? dnRail : na, "Lower Rail", color = color.new(cDn, 8), linewidth = 2)
plot(showRails and laserFx ? upRail : na, "Upper Rail Halo", color = color.new(cUp, 84), linewidth = 6)
plot(showRails and laserFx ? dnRail : na, "Lower Rail Halo", color = color.new(cDn, 84), linewidth = 6)
plot(showRails ? midRail : na, "Mid Rail", color = color.new(cIon, 62), linewidth = 1)
fill(pUpCore, pDnCore,
     color = showEnergy and (squeeze or compScore >= 0.60) ? color.new(cAlert, 93) : na,
     title = "Compression Field")

// ─────────────────────────────────────────────────────────────────────────────
// RENDER — last bar redraw, persistent event history in arrays
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    f_wipe()
    int rt = bar_index + extendR

    if showGrid and showRails
        for k = 1 to 4
            float y = dnRail + (upRail - dnRail) * k / 5.0
            array.push(drawLn, line.new(bar_index - 100, y, rt, y,
                 color = color.new(cGrid, 82), width = 1, style = line.style_dotted))

    // Exactly one marker per stored breakout, at the rail price that triggered it.
    if showBreaks
        int esz = array.size(evtBar)
        if esz > 0
            for i = 0 to esz - 1
                int b = array.get(evtBar, i)
                int d = array.get(evtDir, i)
                float px = array.get(evtPx, i)
                float cpx = array.get(evtClose, i)
                color ec = d == 1 ? pBull : pBear

                array.push(drawLn, line.new(
                     b, px, b + 2, px,
                     color = color.new(ec, 15),
                     width = 2))

                string sigTxt = d == 1 ? "▲ BREAKOUT" : "▼ BREAKOUT"
                string pxTxt = "\n@" + str.tostring(px, format.mintick)
                array.push(drawLb, label.new(
                     b,
                     px,
                     sigTxt + pxTxt,
                     style = d == 1 ? label.style_label_up : label.style_label_down,
                     color = color.new(pBg, 8),
                     textcolor = ec,
                     size = size.tiny))

    if showStruct
        int ssz = array.size(swBar)
        if ssz > 0
            for i = 0 to ssz - 1
                int b = array.get(swBar, i)
                if bar_index - b <= 250
                    float px = array.get(swPx, i)
                    int k = array.get(swKind, i)
                    string tag = array.get(swTag, i)
                    color tc = tag == "HH" or tag == "HL" ? pBull : tag == "LH" or tag == "LL" ? pBear : pBlue
                    array.push(drawLb, label.new(
                         b, px, tag,
                         style = k == 1 ? label.style_label_down : label.style_label_up,
                         color = color.new(pBg, 100),
                         textcolor = color.new(tc, 15),
                         size = size.tiny))

    if showPulse and showRails
        float dU = not na(atrV) and atrV > 0 ? (upRail - close) / atrV : na
        float dL = not na(atrV) and atrV > 0 ? (close - dnRail) / atrV : na
        array.push(drawLb, label.new(
             bar_index + 1, upRail,
             "↑ " + (na(dU) ? "—" : str.tostring(dU, "#.##")) + " ATR",
             style = label.style_label_left,
             color = color.new(pBg, 20),
             textcolor = color.new(pBull, 10),
             size = size.tiny))
        array.push(drawLb, label.new(
             bar_index + 1, dnRail,
             "↓ " + (na(dL) ? "—" : str.tostring(dL, "#.##")) + " ATR",
             style = label.style_label_left,
             color = color.new(pBg, 20),
             textcolor = color.new(pBear, 10),
             size = size.tiny))

// ─────────────────────────────────────────────────────────────────────────────
// INSTITUTIONAL PANEL
// ─────────────────────────────────────────────────────────────────────────────
var table tb = table.new(
     f_dashPos(dashPos), 2, 12,
     bgcolor = pBg,
     frame_width = 1,
     frame_color = pBorder,
     border_width = 1,
     border_color = color.new(pBorder, 25))

if barstate.islast
    if showHud
        string ts = dashSize
        float dU = not na(atrV) and atrV > 0 ? (upRail - close) / atrV : na
        float dL = not na(atrV) and atrV > 0 ? (close - dnRail) / atrV : na

        string armTxt = breakoutState == 0 ? "🟢 ARMED" : breakoutState == 1 ? "🔒 UP ACTIVE" : "🔒 DOWN ACTIVE"
        color armC = breakoutState == 0 ? pBull : breakoutState == 1 ? pBull : pBear

        string compTxt = squeeze ? "⚡ ARMED" : compScore >= 0.70 ? "🟡 CHARGING" : "⚪ OPEN"
        color compC = squeeze ? pGold : compScore >= 0.70 ? pGold : pMuted

        string flowTxt = slopeAtr > 0.20 ? "📈 ASCENT" : slopeAtr < -0.20 ? "📉 DESCENT" : "➖ NEUTRAL"
        color flowC = slopeAtr > 0.20 ? pBull : slopeAtr < -0.20 ? pBear : pMuted

        string partTxt = na(rvol) ? "—" : "×" + str.tostring(rvol, "#.##")
        color partC = not na(rvol) and rvol >= volMult ? pBull : pMuted

        string lastTxt = na(brkBar) ? "—" :
             (brkDir == 1 ? "▲ " : "▼ ") +
             str.tostring(bar_index - brkBar) + "b · " +
             str.tostring(brkPx, format.mintick)
        color lastC = na(brkBar) ? pMuted : brkDir == 1 ? pBull : pBear

        table.cell(tb, 0, 0, "🏛️ BREAKOUT DESK", text_color = pText, text_size = f_txtSize(ts), bgcolor = pHeader)
        table.cell(tb, 1, 0, "CONFIRMED", text_color = pGold, text_size = size.tiny, bgcolor = pHeader)

        table.cell(tb, 0, 1, "🔐 ENGINE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 1, armTxt, text_color = armC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 2, "🧭 REGIME", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 2, regime, text_color = regC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 3, "⬆ UPPER RAIL", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 3, str.tostring(upRail, format.mintick) + " · " + (na(dU) ? "—" : str.tostring(dU, "#.##") + " ATR"),
             text_color = pBull, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 4, "⬇ LOWER RAIL", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 4, str.tostring(dnRail, format.mintick) + " · " + (na(dL) ? "—" : str.tostring(dL, "#.##") + " ATR"),
             text_color = pBear, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 5, "⚡ COMPRESSION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 5, compTxt + " · " + str.tostring(compScore * 100.0, "#") + "%",
             text_color = compC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 6, "📐 FLOW", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 6, flowTxt + " · " + str.tostring(slopeAtr, "#.##"),
             text_color = flowC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 7, "📊 PARTICIPATION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 7, partTxt, text_color = partC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 8, "⚖️ LTF DELTA", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 8, (barDelta >= 0 ? "+" : "") + str.tostring(barDelta, "#.#"),
             text_color = barDelta >= 0 ? pBull : pBear, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 9, "💥 LAST BREAK", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 9, lastTxt, text_color = lastC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 10, "🗂 HISTORY", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 10, str.tostring(array.size(evtBar)) + " / " + str.tostring(historyMax),
             text_color = pBlue, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 11, "✅ CONFIRMATION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)
        table.cell(tb, 1, 11, "CLOSE + BODY + RVOL", text_color = pGold, text_size = size.tiny, bgcolor = pCell)
    else
        table.clear(tb, 0, 0, 1, 11)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS — event-only, confirmed, one per breakout episode
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(breakUp, "Confirmed Upper Breakout ▲",
     "BREAKOUT INSTITUTIONAL: confirmed upper breakout. Close beyond prior rail + displacement + participation.")
alertcondition(breakDn, "Confirmed Lower Breakout ▼",
     "BREAKOUT INSTITUTIONAL: confirmed lower breakout. Close beyond prior rail + displacement + participation.")

// Optional compression event, not a breakout signal.
bool compressionStart = barstate.isconfirmed and squeeze and not squeeze[1]
alertcondition(compressionStart, "Compression Started",
     "BREAKOUT INSTITUTIONAL: Bollinger Bands entered Keltner compression.")

// Hidden outputs
plot(upRail, "UpperRail Data", display = display.none)
plot(dnRail, "LowerRail Data", display = display.none)
plot(midRail, "MidRail Data", display = display.none)
plot(compScore, "Compression Score", display = display.none)
plot(slopeAtr, "Slope ATR", display = display.none)
plot(barDelta, "Approx LTF Delta", display = display.none)
plot(breakUp ? 1 : breakDn ? -1 : 0, "Breakout Event", display = display.none)
````
