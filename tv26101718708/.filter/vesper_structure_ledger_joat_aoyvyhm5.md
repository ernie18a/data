# Vesper Structure Ledger [JOAT]

- url: https://www.tradingview.com/script/AoyVyHM5-Vesper-Structure-Ledger-JOAT/
- type: indicator
- pine_id: PUB;00f8e1cee16f4ceda3508b1c8ad570a4
- version: 1.0

## Description

[b]Vesper Structure Ledger [JOAT][/b]

[b]Introduction[/b]

Vesper Structure Ledger is an open-source market structure indicator built around KAMA trend context, pivot-based BOS and CHoCH events, liquidity sweeps, equal high/low probes, premium/discount zones, demand/supply boxes, right-side structural rails, managed signal boxes, and a top-right dashboard.

The script is intended to make structure easier to read without relying on arrows or cluttered labels. It distinguishes continuation structure from potential character shifts, then adds trend, impulse, volume, and higher-timeframe context before qualifying stronger events.

[image]https://www.tradingview.com/x/ixPhsd97/[/image]

[b]Core Concepts[/b]

[b]1. KAMA Trend Core[/b]

The KAMA engine uses an efficiency ratio to adapt smoothing. When price moves efficiently, the trend line responds faster. In noisy conditions, it slows down and reduces whipsaw sensitivity.

[b]2. Pivot Structure Memory[/b]

Confirmed pivot highs and lows are stored as structural references. These levels become the next possible break points for BOS or CHoCH events.

[pine]
// Conceptual summary
// pivot high and pivot low become current structure rails
// confirmed closes through those rails create BOS or CHoCH events
[/pine]

[b]3. BOS vs CHoCH[/b]

A Break of Structure confirms continuation in the current structural direction. A Change of Character marks a break against that direction and can signal a potential shift. Vesper also tracks BOS counts before allowing some character changes to carry more weight.

[b]4. Sweeps and Equal Levels[/b]

Liquidity sweeps occur when price probes beyond a swing level and closes back through it. Equal high and equal low probes mark nearby repeated liquidity levels.

[b]5. Demand/Supply and Managed Structure Map[/b]

Confirmed qualified signals can create demand or supply zones and a managed visual box with entry, invalidation, and target levels. These levels are for context and planning only.

[b]Features[/b]

[list]
[*][b]Adaptive KAMA trend line:[/b] Efficiency-ratio smoothing for trend context
[*][b]BOS and CHoCH logic:[/b] Separates continuation breaks from possible character shifts
[*][b]BOS-count gating:[/b] Adds context before stronger reversal interpretation
[*][b]Liquidity sweeps:[/b] Detects confirmed wick-and-reclaim events around swing levels
[*][b]Equal high/low probes:[/b] Marks repeated nearby liquidity levels
[*][b]Premium/discount fill:[/b] Shows position inside the recent structure range
[*][b]Demand and supply boxes:[/b] Projects reaction zones from qualified structure
[*][b]Right-side rails:[/b] Labels KAMA, swing high, swing low, and equilibrium
[*][b]Managed signal box:[/b] Displays entry, invalidation, and target levels
[*][b]Top-right dashboard:[/b] Shows trend, KAMA, slope, structure, BOS count, sweep, equal level, context, impulse, targets, and state
[/list]

[b]Input Parameters[/b]

[b]Trend Core:[/b]
[list]
[*]KAMA Length
[*]Fast Period
[*]Slow Period
[*]Source
[/list]

[b]Structure Core:[/b]
[list]
[*]Pivot Left and Pivot Right
[*]Structure Objects
[*]Show BOS
[*]Show CHoCH
[*]Show Target Lines
[/list]

[b]Liquidity Core:[/b]
[list]
[*]Show Liquidity Sweeps
[*]Sweep Lookback
[*]Sweep Buffer ATR
[*]Show Equal Levels
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read trend context[/b]
Use KAMA and the dashboard trend row to understand whether price is above or below the adaptive trend.

[b]Step 2: Watch BOS and CHoCH[/b]
BOS events suggest continuation. CHoCH events warn that character may be changing.

[b]Step 3: Mark liquidity[/b]
Sweeps and equal-level probes identify areas where price has tested or reclaimed liquidity.

[b]Step 4: Use zones as references[/b]
Demand/supply boxes and right-side rails help frame current structure. They are not automatic entries.

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based structure confirms after the right-side pivot window completes
[*]CHoCH events can fail in strong continuation markets
[*]Sweeps require confirmed closes and may appear after the wick forms
[*]Zone boxes are contextual references, not assurances of support or resistance
[/list]

[b]Originality Statement[/b]

Vesper Structure Ledger combines adaptive KAMA trend state, pivot structure, BOS/CHoCH classification, BOS-count context, sweep logic, equal-level probes, premium/discount mapping, projected demand/supply boxes, and managed structure rails in one open-source Pine v6 tool. The purpose is to create a cohesive structure ledger, not a collection of unrelated labels.

[b]Disclaimer[/b]

This script is for educational and informational use only. It is not financial advice and does not predict future market behavior. Always use independent analysis and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Vesper Structure Ledger [JOAT]", shorttitle="VSL [JOAT]", overlay=true, max_bars_back=2500, max_lines_count=450, max_labels_count=350, max_boxes_count=100)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string G_TREND = "Trend Core"
int kamaLen = input.int(10, "KAMA Length", minval=3, maxval=50, group=G_TREND, tooltip="Efficiency-ratio lookback used by the adaptive trend line.")
int fastPeriod = input.int(2, "Fast Period", minval=2, maxval=10, group=G_TREND)
int slowPeriod = input.int(30, "Slow Period", minval=5, maxval=80, group=G_TREND)
sourceInput = input.source(close, "Source", group=G_TREND)
string contextTimeframe = input.timeframe("60", "Context Timeframe", group=G_TREND)
bool showKama = input.bool(true, "Show KAMA", group=G_TREND)
bool showTrendCloud = input.bool(true, "Show Trend Cloud", group=G_TREND)
bool showBarColor = input.bool(true, "Color Candles", group=G_TREND)

string G_STRUCT = "Structure Core"
int pivotLeft = input.int(6, "Pivot Left", minval=1, maxval=25, group=G_STRUCT)
int pivotRight = input.int(6, "Pivot Right", minval=1, maxval=25, group=G_STRUCT)
int structureLimit = input.int(12, "Structure Objects", minval=6, maxval=80, group=G_STRUCT, tooltip="Maximum stored structure lines and labels.")
bool showBOS = input.bool(true, "Show BOS", group=G_STRUCT)
bool showCHoCH = input.bool(true, "Show CHoCH", group=G_STRUCT)
bool showSwingLabels = input.bool(false, "Show Swing Labels", group=G_STRUCT)
bool showTargets = input.bool(false, "Show Target Lines", group=G_STRUCT)
int bosRequiredBeforeFlip = input.int(1, "BOS Required Before CHoCH", minval=0, maxval=5, group=G_STRUCT, tooltip="Requires continuation structure before a confirmed CHoCH can flip the ledger.")
bool showPremiumDiscount = input.bool(true, "Show Premium Discount Range", group=G_STRUCT)
bool showEqualLevels = input.bool(false, "Show Equal High/Low Dots", group=G_STRUCT)
float equalLevelAtrBuffer = input.float(0.12, "Equal Level ATR Buffer", minval=0.02, maxval=0.80, step=0.02, group=G_STRUCT)

string G_LIQ = "Liquidity Core"
bool showSweeps = input.bool(true, "Detect Liquidity Sweeps", group=G_LIQ)
int sweepLookback = input.int(40, "Sweep Lookback", minval=10, maxval=120, group=G_LIQ, tooltip="How far back to validate the reclaim after a stop hunt.")
float sweepAtrBuffer = input.float(0.10, "Sweep Buffer (ATR)", minval=0.00, maxval=0.75, step=0.05, group=G_LIQ, tooltip="Minimum wick excursion beyond the swing level to count as a sweep.")
float displacementAtrMult = input.float(0.85, "Displacement ATR Mult", minval=0.20, maxval=3.00, step=0.05, group=G_LIQ)
float volumeSpikeMult = input.float(1.35, "Volume Spike Mult", minval=0.50, maxval=5.00, step=0.05, group=G_LIQ)

string G_ZONES = "Zones And Rails"
bool showStructureZones = input.bool(true, "Show Demand/Supply Zones", group=G_ZONES)
bool showRightRails = input.bool(true, "Show Right-Side Structure Rails", group=G_ZONES)
bool showSignalBoxes = input.bool(true, "Show Managed Signal Boxes", group=G_ZONES)
bool showEventMarkers = input.bool(false, "Show Event Markers", group=G_ZONES)
bool showSweepMarkers = input.bool(false, "Show Sweep Markers", group=G_ZONES)
int zoneExtendBars = input.int(18, "Zone Extension Bars", minval=8, maxval=120, group=G_ZONES)
int railProjection = input.int(16, "Rail Projection Bars", minval=5, maxval=80, group=G_ZONES)
float zoneAtrPadding = input.float(0.08, "Zone ATR Padding", minval=0.00, maxval=1.00, step=0.02, group=G_ZONES)

string G_VIS = "Visual Core"
color bullColor = input.color(#00ff00, "Bull Color", group=G_VIS)
color bearColor = input.color(#ff0000, "Bear Color", group=G_VIS)
color neutralColor = input.color(#8b949e, "Neutral Color", group=G_VIS)
color accentColor = input.color(#388bfd, "Accent Color", group=G_VIS)
color sweepBullColor = input.color(#00e5ff, "Bull Sweep Color", group=G_VIS)
color sweepBearColor = input.color(#ff6b6b, "Bear Sweep Color", group=G_VIS)
color demandColor = input.color(#00e676, "Demand Zone Color", group=G_VIS)
color supplyColor = input.color(#ff1744, "Supply Zone Color", group=G_VIS)
color equilibriumColor = input.color(#ffd93d, "Equilibrium Color", group=G_VIS)
color railColor = input.color(#42a5f5, "Rail Cyan", group=G_VIS)
int lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group=G_VIS)
int glowAlpha = input.int(92, "Glow Alpha", minval=0, maxval=100, group=G_VIS)
bool showDashboard = input.bool(true, "Show Dashboard", group="Dashboard")

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.min(math.max(x, lo), hi)

f_safe_div(float num, float den) =>
    den != 0.0 and not na(den) ? num / den : 0.0

f_row_bg(int row) =>
    row % 2 == 0 ? color.new(#161b22, 0) : color.new(#0d1117, 0)

f_push_line(line[] bucket, line ln, int cap) =>
    array.push(bucket, ln)
    if array.size(bucket) > cap
        line old = array.shift(bucket)
        line.delete(old)

f_push_label(label[] bucket, label lb, int cap) =>
    array.push(bucket, lb)
    if array.size(bucket) > cap
        label old = array.shift(bucket)
        label.delete(old)

f_push_box(box[] bucket, box bx, int cap) =>
    array.push(bucket, bx)
    if array.size(bucket) > cap
        box old = array.shift(bucket)
        box.delete(old)

f_round_price(float x) =>
    str.tostring(x, format.mintick)

f_maybe_price(float x) =>
    na(x) ? "NA" : str.tostring(x, format.mintick)

f_percent(float x) =>
    na(x) ? "NA" : str.tostring(math.round(x * 100.0)) + "%"

f_set_line(line ln, int x1, float y1, int x2, float y2, color col, styleId, int width) =>
    if not na(ln)
        line.set_xy1(ln, x1, y1)
        line.set_xy2(ln, x2, y2)
        line.set_color(ln, col)
        line.set_style(ln, styleId)
        line.set_width(ln, width)

f_set_label(label lb, int x, float y, string txt, color bg, color fg) =>
    if not na(lb)
        label.set_xy(lb, x, y)
        label.set_text(lb, txt)
        label.set_color(lb, bg)
        label.set_textcolor(lb, fg)

// -----------------------------------------------------------------------------
// KAMA trend core
// -----------------------------------------------------------------------------
float kamaFast = 2.0 / (fastPeriod + 1.0)
float kamaSlow = 2.0 / (slowPeriod + 1.0)
float kamaDirection = not na(sourceInput[kamaLen]) ? math.abs(sourceInput - sourceInput[kamaLen]) : 0.0
float kamaVolatility = math.sum(math.abs(sourceInput - nz(sourceInput[1], sourceInput)), kamaLen)
float kamaEfficiency = kamaVolatility > 0 ? kamaDirection / kamaVolatility : 0.0
float kamaSmooth = math.pow(kamaEfficiency * (kamaFast - kamaSlow) + kamaSlow, 2)
var float vesperKama = na
vesperKama := na(vesperKama[1]) ? sourceInput : vesperKama[1] + kamaSmooth * (sourceInput - vesperKama[1])

float kamaSlope = vesperKama - vesperKama[1]
float atrValue = ta.atr(14)
float kamaDistance = atrValue > 0 ? math.abs(close - vesperKama) / atrValue : 0.0

bool bullTrend = close > vesperKama and kamaSlope >= 0
bool bearTrend = close < vesperKama and kamaSlope <= 0
int trendState = bullTrend ? 1 : bearTrend ? -1 : 0
float trendPower = f_clamp(kamaDistance / 2.0, 0.0, 1.5)
color trendColor = color.from_gradient(trendPower, 0.0, 1.5, color.new(neutralColor, 15), trendState >= 0 ? bullColor : bearColor)

float htfFast = request.security(syminfo.tickerid, contextTimeframe, ta.ema(close, 21), lookahead=barmerge.lookahead_off)
float htfSlow = request.security(syminfo.tickerid, contextTimeframe, ta.ema(close, 55), lookahead=barmerge.lookahead_off)
int contextBias = htfFast > htfSlow ? 1 : htfFast < htfSlow ? -1 : 0
float avgVolume = ta.sma(volume, 34)
bool volumeExpansion = volume > avgVolume * volumeSpikeMult
bool displacementBar = math.abs(close - open) > atrValue * displacementAtrMult
float closeLocation = f_safe_div(close - low, math.max(high - low, syminfo.mintick))
float impulseQuality = f_clamp((volumeExpansion ? 0.35 : 0.0) + (displacementBar ? 0.35 : 0.0) + (trendState == contextBias and trendState != 0 ? 0.30 : 0.0), 0.0, 1.0)

// -----------------------------------------------------------------------------
// Pivots and structural memory
// -----------------------------------------------------------------------------
float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var bool highBroken = false
var bool lowBroken = false

var line targetHighLine = na
var line targetLowLine = na

var line[] eventLines = array.new_line()
var label[] eventLabels = array.new_label()

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotRight
    highBroken := false
    if showTargets
        if not na(targetHighLine)
            line.delete(targetHighLine)
        targetHighLine := line.new(lastSwingHighBar, pivotHigh, bar_index + railProjection, pivotHigh, xloc=xloc.bar_index, extend=extend.none, color=color.new(neutralColor, 55), width=1, style=line.style_dotted)
    if showSwingLabels
        label swingHighLabel = label.new(lastSwingHighBar, pivotHigh, "SH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(#161b22, 75), textcolor=color.new(neutralColor, 0), size=size.tiny)
        f_push_label(eventLabels, swingHighLabel, structureLimit)

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotRight
    lowBroken := false
    if showTargets
        if not na(targetLowLine)
            line.delete(targetLowLine)
        targetLowLine := line.new(lastSwingLowBar, pivotLow, bar_index + railProjection, pivotLow, xloc=xloc.bar_index, extend=extend.none, color=color.new(neutralColor, 55), width=1, style=line.style_dotted)
    if showSwingLabels
        label swingLowLabel = label.new(lastSwingLowBar, pivotLow, "SL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(#161b22, 75), textcolor=color.new(neutralColor, 0), size=size.tiny)
        f_push_label(eventLabels, swingLowLabel, structureLimit)

if showTargets
    if not na(targetHighLine) and not highBroken and not na(lastSwingHigh) and close > lastSwingHigh
        line.set_x2(targetHighLine, bar_index)
        line.set_extend(targetHighLine, extend.none)
        line.set_color(targetHighLine, bullColor)
        highBroken := true
    if not na(targetLowLine) and not lowBroken and not na(lastSwingLow) and close < lastSwingLow
        line.set_x2(targetLowLine, bar_index)
        line.set_extend(targetLowLine, extend.none)
        line.set_color(targetLowLine, bearColor)
        lowBroken := true

// -----------------------------------------------------------------------------
// BOS / CHoCH / sweep events
// -----------------------------------------------------------------------------
bool bullBreak = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh
bool bearBreak = barstate.isconfirmed and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow

var int structureDirection = 0
var int bullBosCount = 0
var int bearBosCount = 0

bool chochBull = bullBreak and structureDirection == -1 and bearBosCount >= bosRequiredBeforeFlip
bool chochBear = bearBreak and structureDirection == 1 and bullBosCount >= bosRequiredBeforeFlip
bool bosBull = bullBreak and not chochBull
bool bosBear = bearBreak and not chochBear

if bosBull
    structureDirection := 1
    bullBosCount += 1
    bearBosCount := 0
if bosBear
    structureDirection := -1
    bearBosCount += 1
    bullBosCount := 0
if chochBull
    structureDirection := 1
    bullBosCount := 0
    bearBosCount := 0
if chochBear
    structureDirection := -1
    bullBosCount := 0
    bearBosCount := 0

float bullSweepDepth = not na(lastSwingLow) ? (lastSwingLow - low) / math.max(atrValue, syminfo.mintick) : 0.0
float bearSweepDepth = not na(lastSwingHigh) ? (high - lastSwingHigh) / math.max(atrValue, syminfo.mintick) : 0.0
bool bullSweep = barstate.isconfirmed and showSweeps and not na(lastSwingLow) and not na(lastSwingLowBar) and bar_index - lastSwingLowBar <= sweepLookback and low < lastSwingLow and close > lastSwingLow and bullSweepDepth >= sweepAtrBuffer
bool bearSweep = barstate.isconfirmed and showSweeps and not na(lastSwingHigh) and not na(lastSwingHighBar) and bar_index - lastSwingHighBar <= sweepLookback and high > lastSwingHigh and close < lastSwingHigh and bearSweepDepth >= sweepAtrBuffer

float rangeHigh = not na(lastSwingHigh) and not na(lastSwingLow) ? math.max(lastSwingHigh, lastSwingLow) : na
float rangeLow = not na(lastSwingHigh) and not na(lastSwingLow) ? math.min(lastSwingHigh, lastSwingLow) : na
float rangeMid = not na(rangeHigh) and not na(rangeLow) ? (rangeHigh + rangeLow) * 0.5 : na
float premiumLine = not na(rangeHigh) and not na(rangeLow) ? rangeLow + (rangeHigh - rangeLow) * 0.705 : na
float discountLine = not na(rangeHigh) and not na(rangeLow) ? rangeLow + (rangeHigh - rangeLow) * 0.295 : na
float rangePosition = not na(rangeHigh) and not na(rangeLow) ? f_safe_div(close - rangeLow, math.max(rangeHigh - rangeLow, syminfo.mintick)) : na
bool equalHighProbe = barstate.isconfirmed and showEqualLevels and not na(lastSwingHigh) and not bullBreak and math.abs(high - lastSwingHigh) <= atrValue * equalLevelAtrBuffer
bool equalLowProbe = barstate.isconfirmed and showEqualLevels and not na(lastSwingLow) and not bearBreak and math.abs(low - lastSwingLow) <= atrValue * equalLevelAtrBuffer

color bullEventColor = trendState == 1 ? bullColor : accentColor
color bearEventColor = trendState == -1 ? bearColor : accentColor

if bosBull and showBOS
    line bosLine = line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, xloc=xloc.bar_index, extend=extend.none, color=color.new(bullEventColor, 25), width=lineWidth, style=line.style_dashed)
    label bosLabel = label.new(math.max(lastSwingHighBar, bar_index - 2), lastSwingHigh, "BOS", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(#161b22, 42), textcolor=color.new(bullEventColor, 0), size=size.tiny)
    f_push_line(eventLines, bosLine, structureLimit)
    f_push_label(eventLabels, bosLabel, structureLimit)

if bosBear and showBOS
    line bosLine = line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, xloc=xloc.bar_index, extend=extend.none, color=color.new(bearEventColor, 25), width=lineWidth, style=line.style_dashed)
    label bosLabel = label.new(math.max(lastSwingLowBar, bar_index - 2), lastSwingLow, "BOS", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(#161b22, 42), textcolor=color.new(bearEventColor, 0), size=size.tiny)
    f_push_line(eventLines, bosLine, structureLimit)
    f_push_label(eventLabels, bosLabel, structureLimit)

if chochBull and showCHoCH
    line chochLine = line.new(lastSwingHighBar, lastSwingHigh, bar_index, lastSwingHigh, xloc=xloc.bar_index, extend=extend.none, color=color.new(accentColor, 5), width=lineWidth + 1, style=line.style_solid)
    label chochLabel = label.new(math.max(lastSwingHighBar, bar_index - 2), lastSwingHigh, "CHoCH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(#161b22, 28), textcolor=color.new(accentColor, 0), size=size.tiny)
    f_push_line(eventLines, chochLine, structureLimit)
    f_push_label(eventLabels, chochLabel, structureLimit)

if chochBear and showCHoCH
    line chochLine = line.new(lastSwingLowBar, lastSwingLow, bar_index, lastSwingLow, xloc=xloc.bar_index, extend=extend.none, color=color.new(accentColor, 5), width=lineWidth + 1, style=line.style_solid)
    label chochLabel = label.new(math.max(lastSwingLowBar, bar_index - 2), lastSwingLow, "CHoCH", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(#161b22, 28), textcolor=color.new(accentColor, 0), size=size.tiny)
    f_push_line(eventLines, chochLine, structureLimit)
    f_push_label(eventLabels, chochLabel, structureLimit)

bool sweepUp = bullSweep
bool sweepDown = bearSweep
bool structureLongEvent = bosBull or chochBull or sweepUp
bool structureShortEvent = bosBear or chochBear or sweepDown
bool qualifiedLongEvent = structureLongEvent and (contextBias >= 0 or impulseQuality >= 0.65) and closeLocation >= 0.45
bool qualifiedShortEvent = structureShortEvent and (contextBias <= 0 or impulseQuality >= 0.65) and closeLocation <= 0.55

var box[] demandBoxes = array.new_box()
var box[] supplyBoxes = array.new_box()
var label[] zoneLabels = array.new_label()
int zoneCap = math.max(2, int(math.round(structureLimit / 4.0)))

if showStructureZones and qualifiedLongEvent
    float zonePad = atrValue * zoneAtrPadding
    float demandTop = math.max(open, close) + zonePad
    float demandBottom = low - zonePad
    int zoneRight = bar_index + zoneExtendBars
    box demandBox = box.new(bar_index, demandTop, zoneRight, demandBottom, xloc=xloc.bar_index, bgcolor=color.new(demandColor, 92), border_color=color.new(demandColor, 38), border_width=1, border_style=line.style_dashed)
    label demandLabel = label.new(bar_index + 1, (demandTop + demandBottom) * 0.5, "Demand", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(#06140f, 18), textcolor=color.new(demandColor, 0), size=size.tiny)
    f_push_box(demandBoxes, demandBox, zoneCap)
    f_push_label(zoneLabels, demandLabel, structureLimit)

if showStructureZones and qualifiedShortEvent
    float zonePad = atrValue * zoneAtrPadding
    float supplyTop = high + zonePad
    float supplyBottom = math.min(open, close) - zonePad
    int zoneRight = bar_index + zoneExtendBars
    box supplyBox = box.new(bar_index, supplyTop, zoneRight, supplyBottom, xloc=xloc.bar_index, bgcolor=color.new(supplyColor, 92), border_color=color.new(supplyColor, 38), border_width=1, border_style=line.style_dashed)
    label supplyLabel = label.new(bar_index + 1, (supplyTop + supplyBottom) * 0.5, "Supply", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, color=color.new(#18080c, 18), textcolor=color.new(supplyColor, 0), size=size.tiny)
    f_push_box(supplyBoxes, supplyBox, zoneCap)
    f_push_label(zoneLabels, supplyLabel, structureLimit)

plotshape(showSweepMarkers and sweepUp, title="Bull Sweep Core", style=shape.circle, location=location.belowbar, color=color.new(sweepBullColor, 0), size=size.tiny, text="SW", textcolor=color.white)
plotshape(showSweepMarkers and sweepDown, title="Bear Sweep Core", style=shape.circle, location=location.abovebar, color=color.new(sweepBearColor, 0), size=size.tiny, text="SW", textcolor=color.white)

// -----------------------------------------------------------------------------
// Trend visuals
// -----------------------------------------------------------------------------
plotKamaGlow = plot(showKama ? vesperKama : na, "KAMA Glow", color=color.new(trendColor, 78), linewidth=7, style=plot.style_linebr)
plotKamaCore = plot(showKama ? vesperKama : na, "KAMA Core", color=color.new(trendColor, 0), linewidth=2, style=plot.style_linebr)
plotCloseRef = plot(showTrendCloud ? close : na, "Close Ref", color=color.new(color.white, 100), display=display.none)

fill(plotKamaGlow, plotCloseRef, showTrendCloud ? color.new(trendColor, 90) : na, title="Vesper Cloud")

plotRangeHigh = plot(showPremiumDiscount ? rangeHigh : na, "Range High", color=color.new(supplyColor, 65), linewidth=1, style=plot.style_linebr)
plotPremium = plot(showPremiumDiscount ? premiumLine : na, "Premium Rail", color=color.new(supplyColor, 82), linewidth=1, style=plot.style_linebr)
plotEquilibrium = plot(showPremiumDiscount ? rangeMid : na, "Equilibrium", color=color.new(equilibriumColor, 38), linewidth=1, style=plot.style_linebr)
plotDiscount = plot(showPremiumDiscount ? discountLine : na, "Discount Rail", color=color.new(demandColor, 82), linewidth=1, style=plot.style_linebr)
plotRangeLow = plot(showPremiumDiscount ? rangeLow : na, "Range Low", color=color.new(demandColor, 65), linewidth=1, style=plot.style_linebr)

fill(plotRangeHigh, plotPremium, showPremiumDiscount ? color.new(supplyColor, 94) : na, title="Premium Glow")
fill(plotDiscount, plotRangeLow, showPremiumDiscount ? color.new(demandColor, 94) : na, title="Discount Glow")
fill(plotPremium, plotDiscount, showPremiumDiscount ? color.new(neutralColor, 96) : na, title="Balanced Range Core")

color candleTone = trendState > 0 ? color.from_gradient(trendPower, 0.0, 1.5, color.new(bullColor, 70), bullColor) : trendState < 0 ? color.from_gradient(trendPower, 0.0, 1.5, color.new(bearColor, 70), bearColor) : neutralColor
color impulseTone = impulseQuality >= 0.65 ? (trendState >= 0 ? demandColor : supplyColor) : candleTone
barcolor(showBarColor ? impulseTone : na, title="Vesper Candle Tone")

// -----------------------------------------------------------------------------
// Signals and alerts
// -----------------------------------------------------------------------------
bool bullSignal = barstate.isconfirmed and (bosBull or chochBull or sweepUp)
bool bearSignal = barstate.isconfirmed and (bosBear or chochBear or sweepDown)
bool bullQualifiedSignal = bullSignal and qualifiedLongEvent
bool bearQualifiedSignal = bearSignal and qualifiedShortEvent

plotshape(showEventMarkers and equalHighProbe, title="Equal High Dot", style=shape.circle, location=location.abovebar, color=color.new(equilibriumColor, 0), size=size.tiny, text="EQ", textcolor=color.new(#0d1117, 0))
plotshape(showEventMarkers and equalLowProbe, title="Equal Low Dot", style=shape.circle, location=location.belowbar, color=color.new(equilibriumColor, 0), size=size.tiny, text="EQ", textcolor=color.new(#0d1117, 0))
plotshape(showEventMarkers and bullQualifiedSignal, title="Qualified Bull Core", style=shape.square, location=location.belowbar, color=color.new(demandColor, 0), size=size.tiny, text="Q", textcolor=color.white)
plotshape(showEventMarkers and bearQualifiedSignal, title="Qualified Bear Core", style=shape.square, location=location.abovebar, color=color.new(supplyColor, 0), size=size.tiny, text="Q", textcolor=color.white)

alertcondition(bullSignal, title="Vesper Bull Signal", message="Vesper Structure Ledger [JOAT]: bullish structure event on confirmed bar.")
alertcondition(bearSignal, title="Vesper Bear Signal", message="Vesper Structure Ledger [JOAT]: bearish structure event on confirmed bar.")
alertcondition(bosBull, title="Vesper Bull BOS", message="Vesper Structure Ledger [JOAT]: bullish BOS on confirmed bar.")
alertcondition(bosBear, title="Vesper Bear BOS", message="Vesper Structure Ledger [JOAT]: bearish BOS on confirmed bar.")
alertcondition(chochBull, title="Vesper Bull CHoCH", message="Vesper Structure Ledger [JOAT]: bullish CHoCH on confirmed bar.")
alertcondition(chochBear, title="Vesper Bear CHoCH", message="Vesper Structure Ledger [JOAT]: bearish CHoCH on confirmed bar.")
alertcondition(sweepUp, title="Vesper Bull Sweep", message="Vesper Structure Ledger [JOAT]: bullish liquidity sweep on confirmed bar.")
alertcondition(sweepDown, title="Vesper Bear Sweep", message="Vesper Structure Ledger [JOAT]: bearish liquidity sweep on confirmed bar.")
alertcondition(bullQualifiedSignal, title="Vesper Qualified Bull", message="Vesper Structure Ledger [JOAT]: qualified bullish structure signal.")
alertcondition(bearQualifiedSignal, title="Vesper Qualified Bear", message="Vesper Structure Ledger [JOAT]: qualified bearish structure signal.")

// -----------------------------------------------------------------------------
// Right-side rails and managed signal boxes
// -----------------------------------------------------------------------------
var line railKama = na
var line railSwingHigh = na
var line railSwingLow = na
var line railEquilibrium = na
var label railKamaLabel = na
var label railSwingHighLabel = na
var label railSwingLowLabel = na
var label railEquilibriumLabel = na

if barstate.isfirst
    railKama := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(railColor, 0), width=2, style=line.style_solid)
    railSwingHigh := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(supplyColor, 0), width=1, style=line.style_dashed)
    railSwingLow := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(demandColor, 0), width=1, style=line.style_dashed)
    railEquilibrium := line.new(bar_index, close, bar_index + 1, close, xloc=xloc.bar_index, extend=extend.none, color=color.new(equilibriumColor, 0), width=1, style=line.style_dotted)
    railKamaLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 30), textcolor=color.white, size=size.small)
    railSwingHighLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 40), textcolor=color.white, size=size.tiny)
    railSwingLowLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 40), textcolor=color.white, size=size.tiny)
    railEquilibriumLabel := label.new(bar_index, close, "", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#161b22, 45), textcolor=color.white, size=size.tiny)

int vesperRailX1 = bar_index
int vesperRailX2 = bar_index + railProjection
color hiddenRailColor = color.new(color.white, 100)
if barstate.islast
    f_set_line(railKama, vesperRailX1, vesperKama, vesperRailX2, vesperKama, showRightRails ? color.new(trendColor, 0) : hiddenRailColor, line.style_solid, 2)
    f_set_line(railSwingHigh, vesperRailX1, lastSwingHigh, vesperRailX2, lastSwingHigh, showRightRails and not na(lastSwingHigh) ? color.new(supplyColor, 10) : hiddenRailColor, line.style_dashed, 1)
    f_set_line(railSwingLow, vesperRailX1, lastSwingLow, vesperRailX2, lastSwingLow, showRightRails and not na(lastSwingLow) ? color.new(demandColor, 10) : hiddenRailColor, line.style_dashed, 1)
    f_set_line(railEquilibrium, vesperRailX1, rangeMid, vesperRailX2, rangeMid, showRightRails and showPremiumDiscount ? color.new(equilibriumColor, 0) : hiddenRailColor, line.style_dotted, 1)
    f_set_label(railKamaLabel, vesperRailX2, vesperKama, showRightRails ? "KAMA " + f_maybe_price(vesperKama) : "", color.new(#161b22, showRightRails ? 30 : 100), color.new(trendColor, showRightRails ? 0 : 100))
    f_set_label(railSwingHighLabel, vesperRailX2, lastSwingHigh, showRightRails and not na(lastSwingHigh) ? "SH " + f_maybe_price(lastSwingHigh) : "", color.new(#161b22, showRightRails ? 40 : 100), color.new(supplyColor, showRightRails ? 0 : 100))
    f_set_label(railSwingLowLabel, vesperRailX2, lastSwingLow, showRightRails and not na(lastSwingLow) ? "SL " + f_maybe_price(lastSwingLow) : "", color.new(#161b22, showRightRails ? 40 : 100), color.new(demandColor, showRightRails ? 0 : 100))
    f_set_label(railEquilibriumLabel, vesperRailX2, rangeMid, showRightRails and showPremiumDiscount ? "EQ " + f_maybe_price(rangeMid) : "", color.new(#161b22, showRightRails ? 45 : 100), color.new(equilibriumColor, showRightRails ? 0 : 100))

var box managedBox = na
var line managedEntryLine = na
var line managedInvalidationLine = na
var line managedTargetLine = na
var label managedEntryLabel = na
var label managedInvalidationLabel = na
var label managedTargetLabel = na

if showSignalBoxes and (bullQualifiedSignal or bearQualifiedSignal)
    if not na(managedBox)
        box.delete(managedBox)
    if not na(managedEntryLine)
        line.delete(managedEntryLine)
    if not na(managedInvalidationLine)
        line.delete(managedInvalidationLine)
    if not na(managedTargetLine)
        line.delete(managedTargetLine)
    if not na(managedEntryLabel)
        label.delete(managedEntryLabel)
    if not na(managedInvalidationLabel)
        label.delete(managedInvalidationLabel)
    if not na(managedTargetLabel)
        label.delete(managedTargetLabel)

    bool longManaged = bullQualifiedSignal
    color managedTone = longManaged ? demandColor : supplyColor
    float managedEntry = close
    float managedInvalidation = longManaged ? math.min(lastSwingLow, low) - atrValue * 0.25 : math.max(lastSwingHigh, high) + atrValue * 0.25
    managedInvalidation := na(managedInvalidation) ? (longManaged ? close - atrValue : close + atrValue) : managedInvalidation
    float managedRisk = math.max(math.abs(managedEntry - managedInvalidation), syminfo.mintick)
    float managedTarget = longManaged ? managedEntry + managedRisk * 2.0 : managedEntry - managedRisk * 2.0
    float managedTop = math.max(managedEntry, managedTarget)
    float managedBottom = math.min(managedEntry, managedTarget)
    int managedRight = bar_index + zoneExtendBars
    managedBox := box.new(bar_index, managedTop, managedRight, managedBottom, xloc=xloc.bar_index, bgcolor=color.new(managedTone, 92), border_color=color.new(managedTone, 18), border_width=1, border_style=line.style_dashed)
    managedEntryLine := line.new(bar_index, managedEntry, managedRight, managedEntry, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.white, 15), width=2, style=line.style_solid)
    managedInvalidationLine := line.new(bar_index, managedInvalidation, managedRight, managedInvalidation, xloc=xloc.bar_index, extend=extend.none, color=color.new(supplyColor, 0), width=1, style=line.style_dashed)
    managedTargetLine := line.new(bar_index, managedTarget, managedRight, managedTarget, xloc=xloc.bar_index, extend=extend.none, color=color.new(managedTone, 0), width=2, style=line.style_dotted)
    managedEntryLabel := label.new(managedRight, managedEntry, "Entry " + f_maybe_price(managedEntry), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(#30363d, 12), textcolor=color.white, size=size.tiny)
    managedInvalidationLabel := label.new(managedRight, managedInvalidation, "Invalid " + f_maybe_price(managedInvalidation), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(supplyColor, 18), textcolor=color.white, size=size.tiny)
    managedTargetLabel := label.new(managedRight, managedTarget, "Target " + f_maybe_price(managedTarget), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.new(managedTone, 18), textcolor=color.white, size=size.tiny)

// -----------------------------------------------------------------------------
// Dashboard
// -----------------------------------------------------------------------------
var table dash = table.new(position.top_right, 2, 13, bgcolor=color.new(#0d1117, 10), border_color=color.new(#30363d, 20), border_width=1, frame_color=color.new(#388bfd, 30), frame_width=1)

string trendLabel = trendState > 0 ? "BULL" : trendState < 0 ? "BEAR" : "NEUTRAL"
string structureLabel = bosBull ? "BOS UP" : bosBear ? "BOS DN" : chochBull ? "CHOCH UP" : chochBear ? "CHOCH DN" : "BALANCED"
string sweepLabel = sweepUp ? "SWEEP LOW" : sweepDown ? "SWEEP HIGH" : "NONE"
string kamaLabel = f_round_price(vesperKama)
string slopeLabel = str.tostring(math.round(kamaSlope / math.max(atrValue, syminfo.mintick) * 100.0) / 100.0)
string targetHighLabel = na(lastSwingHigh) ? "NA" : f_round_price(lastSwingHigh)
string targetLowLabel = na(lastSwingLow) ? "NA" : f_round_price(lastSwingLow)
string contextLabel = contextBias > 0 ? "HTF BULL" : contextBias < 0 ? "HTF BEAR" : "HTF FLAT"
string rangeLabel = na(rangePosition) ? "NA" : rangePosition >= 0.70 ? "PREMIUM" : rangePosition <= 0.30 ? "DISCOUNT" : "BALANCED"
string impulseLabel = impulseQuality >= 0.70 ? "HIGH" : impulseQuality >= 0.35 ? "MED" : "LOW"
string bosCountLabel = str.tostring(bullBosCount) + " / " + str.tostring(bearBosCount)
string eqLabel = equalHighProbe ? "EQ HIGH" : equalLowProbe ? "EQ LOW" : "NONE"
color contextColor = contextBias > 0 ? demandColor : contextBias < 0 ? supplyColor : neutralColor
color rangeColor = rangePosition >= 0.70 ? supplyColor : rangePosition <= 0.30 ? demandColor : equilibriumColor
color impulseColor = impulseQuality >= 0.70 ? (trendState >= 0 ? demandColor : supplyColor) : impulseQuality >= 0.35 ? equilibriumColor : neutralColor

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "VESPER", text_color=color.white, bgcolor=color.new(#161b22, 0), text_halign=text.align_left)
    table.cell(dash, 1, 0, "VSL [JOAT]", text_color=color.new(accentColor, 0), bgcolor=color.new(#161b22, 0), text_halign=text.align_right)
    table.cell(dash, 0, 1, "Trend", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(1), text_halign=text.align_left)
    table.cell(dash, 1, 1, trendLabel, text_color=color.new(trendColor, 0), bgcolor=f_row_bg(1), text_halign=text.align_right)
    table.cell(dash, 0, 2, "KAMA", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(2), text_halign=text.align_left)
    table.cell(dash, 1, 2, kamaLabel, text_color=color.new(trendColor, 0), bgcolor=f_row_bg(2), text_halign=text.align_right)
    table.cell(dash, 0, 3, "Slope", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(3), text_halign=text.align_left)
    table.cell(dash, 1, 3, slopeLabel, text_color=color.new(neutralColor, 0), bgcolor=f_row_bg(3), text_halign=text.align_right)
    table.cell(dash, 0, 4, "Structure", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(4), text_halign=text.align_left)
    table.cell(dash, 1, 4, structureLabel, text_color=color.new(bullSignal ? bullColor : bearSignal ? bearColor : accentColor, 0), bgcolor=f_row_bg(4), text_halign=text.align_right)
    table.cell(dash, 0, 5, "BOS Count", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(5), text_halign=text.align_left)
    table.cell(dash, 1, 5, bosCountLabel, text_color=color.new(equilibriumColor, 0), bgcolor=f_row_bg(5), text_halign=text.align_right)
    table.cell(dash, 0, 6, "Sweep", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(6), text_halign=text.align_left)
    table.cell(dash, 1, 6, sweepLabel, text_color=color.new(sweepUp ? sweepBullColor : sweepDown ? sweepBearColor : neutralColor, 0), bgcolor=f_row_bg(6), text_halign=text.align_right)
    table.cell(dash, 0, 7, "Equal Lvl", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(7), text_halign=text.align_left)
    table.cell(dash, 1, 7, eqLabel, text_color=color.new(equalHighProbe or equalLowProbe ? equilibriumColor : neutralColor, 0), bgcolor=f_row_bg(7), text_halign=text.align_right)
    table.cell(dash, 0, 8, "Range", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(8), text_halign=text.align_left)
    table.cell(dash, 1, 8, rangeLabel, text_color=color.new(rangeColor, 0), bgcolor=f_row_bg(8), text_halign=text.align_right)
    table.cell(dash, 0, 9, "Context", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(9), text_halign=text.align_left)
    table.cell(dash, 1, 9, contextLabel, text_color=color.new(contextColor, 0), bgcolor=f_row_bg(9), text_halign=text.align_right)
    table.cell(dash, 0, 10, "Impulse", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(10), text_halign=text.align_left)
    table.cell(dash, 1, 10, impulseLabel, text_color=color.new(impulseColor, 0), bgcolor=f_row_bg(10), text_halign=text.align_right)
    table.cell(dash, 0, 11, "Targets", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(11), text_halign=text.align_left)
    table.cell(dash, 1, 11, targetHighLabel + " / " + targetLowLabel, text_color=color.new(neutralColor, 0), bgcolor=f_row_bg(11), text_halign=text.align_right)
    table.cell(dash, 0, 12, "State", text_color=color.new(#8b949e, 0), bgcolor=f_row_bg(12), text_halign=text.align_left)
    table.cell(dash, 1, 12, bullQualifiedSignal ? "LONG +" : bearQualifiedSignal ? "SHORT +" : bullSignal ? "LONG" : bearSignal ? "SHORT" : "WAIT", text_color=color.new(bullSignal ? bullColor : bearSignal ? bearColor : neutralColor, 0), bgcolor=f_row_bg(12), text_halign=text.align_right)
````
