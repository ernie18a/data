# VWAP SAR Magnitude Filter [Gabremoku]

- url: https://www.tradingview.com/script/RHcC68tc-VWAP-SAR-Magnitude-Filter-Gabremoku/
- type: indicator
- pine_id: PUB;3a23f612ba154aa68a33861f9c1b7d2c
- version: 1.0

## Description

VWAP SAR Magnitude Filter [Gabremoku]

Short description
A state-based long-only trend filter that combines VWAP context with Parabolic SAR structure. It uses VWAP as the main trend and invalidation line, while SAR confirms directional pressure and helps visualize momentum expansion or compression.

Descrizione completa
VWAP SAR Magnitude Filter is a long-only overlay designed to turn two familiar tools, VWAP and Parabolic SAR, into a cleaner operational framework rather than a simple indicator mashup.

The script uses VWAP as the primary market context and invalidation line. When price is above VWAP, the market is treated as having bullish intraday or swing context. When price falls back below VWAP, that context weakens and the script can trigger an exit.

Parabolic SAR is not used here as the primary exit engine. Instead, it acts as a structural confirmation tool. A valid long setup requires price to be above VWAP while SAR remains below the candle, which helps align directional bias and price structure. This reduces the number of signals that would appear if VWAP or SAR were used independently.

The script also includes an Auto mode engine. In Auto mode, lower intraday timeframes are handled with faster behavior, while higher timeframes are treated as swing conditions with additional filters. This makes the indicator adapt its sensitivity without requiring constant manual switching.

In Swing mode, the script becomes more selective by requiring:

persistence of the long condition for a minimum number of bars,

a minimum distance between price and SAR,

confirmed exit behavior below VWAP,

a longer cooldown after exits.

This approach is intended to reduce noise and avoid frequent re-entries during unstable or sideways phases. The indicator is therefore more focused on readable continuation structure than on generating many raw signals.

How it works
Long context: Price above VWAP.

Long confirmation: Parabolic SAR below the candle.

Long entry: The bullish context and structural confirmation align.

Exit logic: Main exit occurs on VWAP fallback; in Swing mode the fallback can require confirmation across multiple bars.

Mode engine: Auto selects Intraday or Swing behavior depending on the chart timeframe.

Visual features
VWAP line as the main reference level.

SAR line and glow for directional structure.

Magnitude fill between price and SAR to visualize pressure expansion and compression.

Optional bar coloring.

Dashboard with State, Mode, Regime, Flow, Distance %, SAR Side, and Exit Logic.

How to use it
This indicator works best when price is developing directional structure away from VWAP. In strong trends, it can help frame cleaner long continuation behavior. In choppy or sideways markets around VWAP, noise is naturally higher because the market lacks clear directional context.

A practical way to use it is:

monitor whether price is holding above VWAP,

wait until SAR is also positioned below price,

use the dashboard to confirm the current regime and state,

treat VWAP fallback as the main warning that the active long structure may be weakening.

Limitations
This indicator is not meant to eliminate all noise, especially in lateral environments where price oscillates around VWAP. In those conditions, repeated context shifts are part of market behavior, so no VWAP-based trend tool can remove all false transitions. The script is designed to reduce that noise, not to make it disappear completely.

It is also a context and structure tool, not a complete trading system. Users should still evaluate market conditions, liquidity, session behavior, and personal risk management before making decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator("VWAP SAR Magnitude Filter [Gabremoku]", overlay=true, max_labels_count=500)

// ── ABOUT ──────────────────────────────────────────────────────
// This indicator combines VWAP and Parabolic SAR into a state-based long-only trend filter.
// VWAP acts as the main context and invalidation line.
// Parabolic SAR acts as a directional structure confirmation.
// Auto mode switches between Intraday and Swing behavior based on chart timeframe.
// Exit logic is centered on VWAP fallback to reduce premature exits in noisy conditions.

// ── INPUTS ─────────────────────────────────────────────────────
grpMode = "🧭 Mode"
modeOverride = input.string("Auto", "Mode", options=["Auto", "Intraday", "Swing"], group=grpMode)

grp0 = "⚙️ Core Logic"
src       = input.source(close, "Price Source", group=grp0)
sarStart  = input.float(0.02, "SAR Start", minval=0.001, step=0.001, group=grp0)
sarInc    = input.float(0.02, "SAR Increment", minval=0.001, step=0.001, group=grp0)
sarMax    = input.float(0.20, "SAR Max", minval=0.01, step=0.01, group=grp0)

entryCooldownIntraday = input.int(0, "Intraday Cooldown Bars", minval=0, maxval=100, group=grp0)
entryCooldownSwing    = input.int(8, "Swing Cooldown Bars", minval=0, maxval=200, group=grp0)

grpSwing = "🐢 Swing Filters"
swingConfirmBars = input.int(3, "Swing: Min Bars in Long Condition", minval=1, maxval=10, group=grpSwing)
swingExitBars    = input.int(2, "Swing: Min Bars Below VWAP To Exit", minval=1, maxval=10, group=grpSwing)
swingMinDistPct  = input.float(1.00, "Swing: Min Dist Price–SAR (%)", minval=0.0, maxval=20.0, step=0.1, group=grpSwing)

grpVol = "📊 Volatility Filter"
useAtrFilter = input.bool(false, "Use ATR Volatility Gate", group=grpVol)
atrLen       = input.int(14, "ATR Length", minval=1, group=grpVol)
minAtrPct    = input.float(0.20, "Min ATR as % of Price", minval=0.01, maxval=10.0, step=0.01, group=grpVol)

grp1 = "🎨 Themes"
themeInput       = input.string("Gabremoku", "Theme", options=["Standard", "Gabremoku", "Custom"], group=grp1)
customBullColor  = input.color(color.rgb(33, 150, 243), "Custom Bullish Color", group=grp1)
customBearColor  = input.color(color.rgb(241, 255, 48), "Custom Bearish Color", group=grp1)
customVwapColor  = input.color(color.rgb(46, 49, 146), "Custom VWAP Color", group=grp1)
customNeutral    = input.color(color.gray, "Custom Neutral Color", group=grp1)

grp2 = "📐 Style & Signals"
showVWAP       = input.bool(true, "Show VWAP", group=grp2)
showSARLine    = input.bool(true, "Show SAR Line", group=grp2)
showGlowLine   = input.bool(true, "Show SAR Glow", group=grp2)
showMagnitude  = input.bool(true, "Show Magnitude Fill", group=grp2)
showBarColors  = input.bool(true, "Color Bars", group=grp2)
showSignals    = input.bool(true, "Show Signals", group=grp2)
signalStyle    = input.string("Triangle", "Signal Style", options=["Label", "Triangle"], group=grp2)
showLabels     = input.bool(true, "Show Last Value Labels", group=grp2)
highlightBg    = input.bool(false, "Highlight Active Background", group=grp2)
vwapWidth      = input.int(2, "VWAP Width", minval=1, maxval=5, group=grp2)
sarWidth       = input.int(2, "SAR Line Width", minval=1, maxval=5, group=grp2)
glowWidth      = input.int(5, "SAR Glow Width", minval=1, maxval=10, group=grp2)

grp3 = "🌈 Magnitude Fill Logic"
neutralZonePct = input.float(0.08, "Neutral Zone (normalized)", minval=0.0, maxval=1.0, step=0.01, group=grp3)
fillAggressive = input.float(1.40, "Fill Aggressiveness", minval=0.5, maxval=4.0, step=0.1, group=grp3)
maxOpacityNear = input.int(78, "Fill Opacity Near SAR", minval=0, maxval=100, group=grp3)
minOpacityFar  = input.int(10, "Fill Opacity Far From SAR", minval=0, maxval=100, group=grp3)
normLookback   = input.int(120, "Magnitude Normalization Lookback", minval=20, group=grp3)

grp5 = "🪧 Dashboard"
showDashboard     = input.bool(true, "Show Dashboard", group=grp5)
dashPosInput      = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp5)
dashTextSizeInput = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal"], group=grp5)

// ── THEME COLORS ───────────────────────────────────────────────
bullColor =
     themeInput == "Standard"  ? color.rgb(0, 184, 120) :
     themeInput == "Gabremoku" ? color.rgb(33, 150, 243) :
     customBullColor

bearColor =
     themeInput == "Standard"  ? color.rgb(232, 71, 71) :
     themeInput == "Gabremoku" ? color.rgb(241, 255, 48) :
     customBearColor

vwapColor =
     themeInput == "Standard"  ? color.rgb(46, 49, 146) :
     themeInput == "Gabremoku" ? color.rgb(46, 49, 146) :
     customVwapColor

neutralColor =
     themeInput == "Standard"  ? color.gray :
     themeInput == "Gabremoku" ? color.gray :
     customNeutral

bullTextColor = color.white
bearTextColor = themeInput == "Gabremoku" ? color.black : color.white

// ── DASHBOARD SETTINGS ─────────────────────────────────────────
dashTextSize = size.small
if dashTextSizeInput == "Tiny"
    dashTextSize := size.tiny
else if dashTextSizeInput == "Normal"
    dashTextSize := size.normal

dashPos = position.bottom_right
if dashPosInput == "Top Right"
    dashPos := position.top_right
else if dashPosInput == "Top Left"
    dashPos := position.top_left
else if dashPosInput == "Bottom Left"
    dashPos := position.bottom_left

// ── MODE ENGINE ────────────────────────────────────────────────
var string modeResolved = "Intraday"

if barstate.isfirst
    modeResolved := switch modeOverride
        "Intraday" => "Intraday"
        "Swing"    => "Swing"
        => timeframe.isintraday and timeframe.multiplier <= 60 ? "Intraday" : "Swing"

isSwing    = modeResolved == "Swing"
isIntraday = modeResolved == "Intraday"

confirmBars  = isSwing ? swingConfirmBars : 1
exitBars     = isSwing ? swingExitBars    : 1
cooldownBars = isSwing ? entryCooldownSwing : entryCooldownIntraday

// ── CORE CALCULATIONS ──────────────────────────────────────────
vwapValue = ta.vwap(hlc3)
sarValue  = ta.sar(sarStart, sarInc, sarMax)

priceAboveVWAP = src > vwapValue
priceBelowVWAP = src < vwapValue

sarBelowCandle = sarValue < low
sarAboveCandle = sarValue > high

atr    = ta.atr(atrLen)
atrPct = atr / close * 100.0
atrOK  = not useAtrFilter or atrPct >= minAtrPct

distRaw = math.abs(src - sarValue)
distPct = distRaw / close * 100.0
distMax = ta.highest(distRaw, normLookback)
distNormBase = distMax != 0 ? distRaw / distMax : 0.0
distNorm     = math.pow(math.min(distNormBase, 1.0), fillAggressive)

distOK = not isSwing or distPct >= swingMinDistPct

// ── ENTRY / EXIT ENGINE ────────────────────────────────────────
baseLongCond = priceAboveVWAP and sarBelowCandle and atrOK and distOK
baseExitCond = priceBelowVWAP

var int longCnt = 0
var int exitCnt = 0

longCnt := baseLongCond ? longCnt + 1 : 0
exitCnt := baseExitCond ? exitCnt + 1 : 0

longCond = isSwing ? longCnt >= confirmBars : baseLongCond
exitCond = isSwing ? exitCnt >= exitBars    : baseExitCond

// ── STATE MACHINE ──────────────────────────────────────────────
var bool inLong      = false
var int  lastExitBar = na

cooldownPassed = na(lastExitBar) or (bar_index - lastExitBar > cooldownBars)

longEntry = longCond and not inLong and cooldownPassed and barstate.isconfirmed
longExit  = exitCond and inLong and barstate.isconfirmed

if longEntry
    inLong := true

if longExit
    inLong := false
    lastExitBar := bar_index

// ── VISUAL STATE ───────────────────────────────────────────────
inNeutralZone = distNorm <= neutralZonePct

fillOpacity = maxOpacityNear - (maxOpacityNear - minOpacityFar) * distNorm
fillOpacityClamped = math.max(0, math.min(100, int(fillOpacity)))

trendBull = sarValue < src
trendBear = sarValue > src

state =
     inLong   ? "Long Active" :
     longCond ? "Ready Long" :
     "Flat / Exit"

stateColor =
     inLong   ? bullColor :
     longCond ? bullColor :
     bearColor

regime =
     priceAboveVWAP ? "Above VWAP" :
     priceBelowVWAP ? "Below VWAP" :
     "On VWAP"

regimeColor =
     priceAboveVWAP ? bullColor :
     priceBelowVWAP ? bearColor :
     neutralColor

flow =
     distNormBase == 0.0 ? "Calm" :
     inNeutralZone       ? "Compressed" :
     trendBull           ? "Bull Pressure" :
     trendBear           ? "Bear Pressure" :
     "Neutral"

flowColor =
     distNormBase == 0.0 ? neutralColor :
     inNeutralZone       ? neutralColor :
     trendBull           ? bullColor :
     bearColor

sarLineColor = inNeutralZone ? neutralColor : trendBull ? bullColor : bearColor
sarGlowColor = color.new(sarLineColor, 78)
fillColor    = color.new(sarLineColor, fillOpacityClamped)

barCol =
     inLong   ? color.new(bullColor, 0) :
     longCond ? color.new(bullColor, 45) :
     color.new(bearColor, 70)

// ── PLOTS ──────────────────────────────────────────────────────
plot(showVWAP ? vwapValue : na, "VWAP", color=vwapColor, linewidth=vwapWidth)

plot(showSARLine and showGlowLine ? sarValue : na, "SAR Glow", color=sarGlowColor, linewidth=glowWidth)
plot(showSARLine ? sarValue : na, "SAR Line", color=sarLineColor, linewidth=sarWidth)

pTop = plot(showMagnitude ? math.max(src, sarValue) : na, "Magnitude Top", display=display.none)
pBot = plot(showMagnitude ? math.min(src, sarValue) : na, "Magnitude Bottom", display=display.none)
fill(pTop, pBot, color=fillColor, title="SAR Magnitude Fill")

barcolor(showBarColors ? barCol : na)
bgcolor(highlightBg and inLong ? color.new(bullColor, 94) : na)

// ── SIGNALS ────────────────────────────────────────────────────
showLabelSignals    = showSignals and signalStyle == "Label"
showTriangleSignals = showSignals and signalStyle == "Triangle"

plotshape(showLabelSignals and longEntry, title="Long Entry Label", text="LONG",
     style=shape.labelup, location=location.belowbar, color=bullColor, textcolor=bullTextColor, size=size.small)

plotshape(showLabelSignals and longExit, title="Long Exit Label", text="EXIT",
     style=shape.labeldown, location=location.abovebar, color=bearColor, textcolor=bearTextColor, size=size.small)

plotshape(showTriangleSignals and longEntry, title="Long Entry Triangle",
     style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small)

plotshape(showTriangleSignals and longExit, title="Long Exit Triangle",
     style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small)

// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(longEntry, "Long Entry", "VWAP SAR Magnitude Filter: Long entry")
alertcondition(longExit,  "Long Exit",  "VWAP SAR Magnitude Filter: Long exit")

// ── DASHBOARD ──────────────────────────────────────────────────
var table dash = table.new(dashPos, 2, 7, border_width=1)

if barstate.isfirst
    dash := table.new(dashPos, 2, 7, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "State", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, state, text_color=stateColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 1, "Mode", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 1, modeResolved, text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 2, "Regime", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 2, regime, text_color=regimeColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 3, "Flow", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 3, flow, text_color=flowColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 4, "Dist %", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 4, str.tostring(distPct, "#.##") + "%", text_color=flowColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 5, "SAR Side", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 5, trendBull ? "Below Price" : trendBear ? "Above Price" : "Neutral", text_color=sarLineColor, text_halign=text.align_center, text_size=dashTextSize)

    table.cell(dash, 0, 6, "Exit Logic", text_color=chart.fg_color, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 6, isSwing ? "VWAP Confirmed" : "VWAP Fallback", text_color=bearColor, text_halign=text.align_center, text_size=dashTextSize)

if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 6)

// ── LAST VALUE LABELS ──────────────────────────────────────────
var label vwapLbl = na
var label sarLbl  = na

if barstate.islast
    if not na(vwapLbl)
        label.delete(vwapLbl)
    if not na(sarLbl)
        label.delete(sarLbl)

    if showLabels
        vwapLbl := label.new(
             bar_index, vwapValue,
             "◀ VWAP: " + str.tostring(vwapValue, format.mintick),
             color=color.new(color.black, 100),
             textcolor=vwapColor,
             force_overlay=true,
             style=label.style_label_left)

        sarLbl := label.new(
             bar_index, sarValue,
             "◀ SAR: " + str.tostring(sarValue, format.mintick),
             color=color.new(color.black, 100),
             textcolor=sarLineColor,
             force_overlay=true,
             style=label.style_label_left)
````
