# Aurelian Auction Ledger [JOAT]

- url: https://www.tradingview.com/script/DlNB6kDq-Aurelian-Auction-Ledger-JOAT/
- type: indicator
- pine_id: PUB;1bb270b67d95447895029ae95c3e337f
- version: 1.0

## Description

[b]Aurelian Auction Ledger [JOAT][/b]

[b]Introduction[/b]

Aurelian Auction Ledger is an open-source range and auction analysis overlay designed to identify compressive trade zones, map their internal value structure, and show how price behaves when it tests the edges of that ledger. The script builds a live range shell, calculates a point of control and value area, tracks sweep events, and presents the active auction state in a top-right dashboard.

The problem Aurelian solves is hidden range structure. Consolidation zones are often treated as simple rectangles, but not all ranges are equal. Some are balanced, some lean toward accumulation, some toward rejection, and many fail through one-sided sweeps before resolving. Aurelian turns that internal auction structure into something visible.

[image]https://www.tradingview.com/x/UiHFRPMi/[/image]

[b]Core Concepts[/b]

[b]1. Compression-based ledger build[/b]

The script measures whether recent bars are tight enough in ATR terms, efficient enough in body structure, and balanced enough in directional pressure to qualify as a live auction ledger.

[b]2. Range shell and internal value area[/b]

When a ledger is active, the script draws:

[list]
[*]The outer ledger shell
[*]The internal value area
[*]The point of control
[/list]

This separates broad range boundaries from the price zone where most business is actually being done.

[b]3. Right-side auction profile[/b]

Volume is accumulated across profile rows inside the active ledger so the script can identify the highest-volume row and estimate the value area around it.

[b]4. Sweep tracking[/b]

Upper and lower sweep events are tracked only on confirmed bars. This helps distinguish clean acceptance from failed range probes.

[b]5. Ledger tilt[/b]

The indicator maintains a directional tilt metric so the range shell is not displayed as neutral by default. If the auction begins leaning toward acceptance or rejection, the color balance reflects that change.

[image]https://www.tradingview.com/x/23dDiUGY/[/image]

[b]Features[/b]

[list]
[*][b]Compression-driven range detection:[/b] Searches for structured auction zones rather than generic boxes
[*][b]Live range shell:[/b] Displays the active ledger high, low, and midpoint
[*][b]Point of control and value area:[/b] Maps where the auction is most concentrated
[*][b]Right-side profile:[/b] Extends the auction structure visually beyond the current bar
[*][b]Sweep detection:[/b] Tracks confirmed probes beyond the ledger edges
[*][b]Auction tilt readout:[/b] Shows whether the range is leaning toward acceptance or rejection
[*][b]Top-right dashboard:[/b] Reports mode, compression, width, POC, value area, sweeps, and tilt
[*][b]Non-repainting event logic:[/b] Sweep and breakout conditions are confirmed on bar close
[/list]

[b]Input Parameters[/b]

[b]Ledger Core:[/b]
[list]
[*]ATR Length
[*]Ledger Build Bars
[*]Compression Ceiling
[*]Body Efficiency Ceiling
[*]Directional Balance Ceiling
[*]Breakout Buffer
[/list]

[b]Auction Profile:[/b]
[list]
[*]Profile Rows
[*]Profile Width
[*]Value Area Coverage
[/list]

[b]Visuals:[/b]
[list]
[*]Show Range Shell
[*]Show Right-Side Profile
[*]Show Sweep Marks
[*]Tint Auction Bars
[*]Show Dashboard
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Confirm that a ledger is live[/b]
Check the dashboard mode first. If the ledger is not active, the script is still scanning for a qualified auction structure.

[b]Step 2: Watch the POC and value area[/b]
These levels show where the auction is concentrated and whether price is rotating inside value or challenging the edges.

[b]Step 3: Track sweeps versus acceptance[/b]
Confirmed sweep events can mark failed probes. If price repeatedly sweeps one side and returns, the ledger is revealing where excess is being rejected.

[b]Step 4: Use tilt as context, not prediction[/b]
Ledger tilt helps interpret which side has more pressure, but the actual resolution still depends on whether price ultimately accepts outside the shell.

[b]Indicator Limitations[/b]

[list]
[*]The script is designed for structured ranges and will naturally stand down during broad directional moves
[*]Volume distribution inside a candle is approximated using row allocation rather than true intrabar order flow
[*]A qualified ledger can still break without first producing a sweep event
[/list]

[b]Originality Statement[/b]

Aurelian Auction Ledger is original in how it combines a compression-qualified range state, an internal profile-derived value area, sweep tracking, and directional tilt into a single clean overlay. It is published because:

[list]
[*]The script distinguishes a structured auction ledger from a generic consolidation rectangle
[*]It combines shell, POC, value area, and sweep tracking in one coherent range workflow
[*]The tilt metric provides additional auction context without cluttering the chart with heavy labels
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice and does not guarantee future market behavior. Range structures can fail abruptly, and volume-based value estimates are still interpretations of historical trading activity. Always use independent judgment and proper risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aurelian Auction Ledger [JOAT]", "AAL [JOAT]", overlay = true, max_bars_back = 500, max_boxes_count = 20, max_lines_count = 200, max_labels_count = 20)

//--------------------------------------------------------------------------------------------------}
// Colors and theme
//--------------------------------------------------------------------------------------------------{
color BULL_TONE   = #21c8a5
color BEAR_TONE   = #ff6b6b
color NEUTRAL_TONE = #8b93a3
color SHADOW_TONE = #11161d
color PANEL_TONE  = #161d25
color BORDER_TONE = #26313d
color TEXT_TONE   = #d9e1ea
color SUB_TONE    = #92a0b3

//--------------------------------------------------------------------------------------------------}
// Inputs
//--------------------------------------------------------------------------------------------------{
string G_CORE = "Ledger Core"
int    atrLenInput           = input.int(14, "ATR Length", minval = 1, group = G_CORE)
int    setupBarsInput        = input.int(24, "Ledger Build Bars", minval = 5, maxval = 100, group = G_CORE)
float  compressionCapInput   = input.float(3.0, "Compression Ceiling (xATR)", minval = 0.5, step = 0.1, group = G_CORE)
float  bodyCapInput          = input.float(0.45, "Body Efficiency Ceiling", minval = 0.05, maxval = 0.95, step = 0.01, group = G_CORE)
float  imbalanceCapInput     = input.float(0.30, "Directional Balance Ceiling", minval = 0.05, maxval = 0.95, step = 0.01, group = G_CORE)
float  breakoutBufferInput   = input.float(0.35, "Breakout Buffer (xATR)", minval = 0.0, step = 0.05, group = G_CORE)

string G_PROFILE = "Auction Profile"
int    profileRowsInput      = input.int(18, "Profile Rows", minval = 8, maxval = 48, group = G_PROFILE)
int    profileWidthInput     = input.int(20, "Profile Width (Bars)", minval = 5, maxval = 60, group = G_PROFILE)
float  valueAreaInput        = input.float(0.70, "Value Area Coverage", minval = 0.50, maxval = 0.90, step = 0.05, group = G_PROFILE)

string G_VIS = "Visuals"
bool   showRangeShellInput   = input.bool(true, "Show Range Shell", group = G_VIS)
bool   showProfileInput      = input.bool(true, "Show Right-Side Profile", group = G_VIS)
bool   showSweepMarksInput   = input.bool(true, "Show Sweep Marks", group = G_VIS)
bool   showBuildShellInput   = input.bool(true, "Show Build Shell", group = G_VIS)
bool   showBreakMarksInput   = input.bool(true, "Show Break Markers", group = G_VIS)
bool   showDevelopingMapInput = input.bool(true, "Show Developing Map", group = G_VIS)
bool   tintBarsInput         = input.bool(true, "Tint Auction Bars", group = G_VIS)
bool   showDashboardInput    = input.bool(true, "Show Dashboard", group = G_VIS)
color  bullColorInput        = input.color(BULL_TONE, "Acceptance Tone", group = G_VIS, inline = "tone")
color  bearColorInput        = input.color(BEAR_TONE, "Rejection Tone", group = G_VIS, inline = "tone")
color  neutralColorInput     = input.color(NEUTRAL_TONE, "Neutral Tone", group = G_VIS)

//--------------------------------------------------------------------------------------------------}
// Persistent state
//--------------------------------------------------------------------------------------------------{
var bool  ledgerLive        = false
var int   ledgerArmedBars   = 0
var int   ledgerStartIndex  = na
var int   ledgerAgeBars     = 0
var int   sweepHighCount    = 0
var int   sweepLowCount     = 0

var float ledgerHigh        = na
var float ledgerLow         = na
var float ledgerMid         = na
var float ledgerPocPrice    = na
var float ledgerVaHigh      = na
var float ledgerVaLow       = na
var float ledgerTotalVol    = 0.0
var float ledgerDeltaNet    = 0.0
var float ledgerTilt        = 0.0
var float ledgerCompression = 0.0
var float ledgerBodyEff     = 0.0
var float ledgerImbalance   = 0.0
var float ledgerWidthAtr    = 0.0
var string ledgerReadout    = "Scanning"

var float[] ledgerVolBins   = array.new_float()
var float[] ledgerDeltaBins = array.new_float()
var line[]  ledgerRays      = array.new_line()
var box     ledgerBuildBox  = na
var box     ledgerShellBox  = na
var box     ledgerValueBox  = na
var line    ledgerHighLine  = na
var line    ledgerLowLine   = na
var line    ledgerPocLine   = na

//--------------------------------------------------------------------------------------------------}
// Utility helpers
//--------------------------------------------------------------------------------------------------{
clampFloat(float value, float minVal, float maxVal) =>
    math.max(minVal, math.min(maxVal, value))

priceText(float value) =>
    str.tostring(value, format.mintick)

ratioText(float value) =>
    str.tostring(value, "#.00")

pctText(float value) =>
    str.tostring(value, "#.0") + "%"

deleteLineArray(line[] bag) =>
    if array.size(bag) > 0
        for i = 0 to array.size(bag) - 1
            line.delete(array.get(bag, i))
    array.clear(bag)

deleteLineRef(line levelLine) =>
    if not na(levelLine)
        line.delete(levelLine)

resetBins(float[] volBag, float[] deltaBag, int rows) =>
    array.clear(volBag)
    array.clear(deltaBag)
    for i = 0 to rows - 1
        array.push(volBag, 0.0)
        array.push(deltaBag, 0.0)

profileStep(float lowBand, float highBand, int rows) =>
    math.max((highBand - lowBand) / rows, syminfo.mintick)

accumulateOffset(int offset, float lowBand, float highBand, int rows, float[] volBag, float[] deltaBag) =>
    float clippedLow = math.max(low[offset], lowBand)
    float clippedHigh = math.min(high[offset], highBand)
    if clippedHigh > clippedLow and rows > 0
        float step = profileStep(lowBand, highBand, rows)
        int leftIdx = int(math.floor((clippedLow - lowBand) / step))
        int rightIdx = int(math.floor((clippedHigh - lowBand) / step))
        leftIdx := int(clampFloat(leftIdx, 0, rows - 1))
        rightIdx := int(clampFloat(rightIdx, 0, rows - 1))
        int touched = math.max(1, rightIdx - leftIdx + 1)
        float share = nz(volume[offset]) / touched
        float direction = close[offset] > open[offset] ? 1.0 : close[offset] < open[offset] ? -1.0 : 0.0
        for j = leftIdx to rightIdx
            array.set(volBag, j, array.get(volBag, j) + share)
            array.set(deltaBag, j, array.get(deltaBag, j) + share * direction)

refreshProfile(float lowBand, float highBand, int rows, float[] volBag, float[] deltaBag) =>
    float maxVol = 0.0
    int pocIdx = 0
    float totalVol = 0.0
    float totalDelta = 0.0

    for i = 0 to rows - 1
        float rowVol = array.get(volBag, i)
        totalVol += rowVol
        totalDelta += array.get(deltaBag, i)
        if rowVol > maxVol
            maxVol := rowVol
            pocIdx := i

    float step = profileStep(lowBand, highBand, rows)
    float pocPrice = lowBand + ((pocIdx + 0.5) * step)

    int vaLeft = pocIdx
    int vaRight = pocIdx
    float covered = array.get(volBag, pocIdx)
    float targetVol = totalVol * valueAreaInput

    if totalVol > 0
        for s = 0 to rows - 1
            if covered >= targetVol
                break
            float leftVol = vaLeft > 0 ? array.get(volBag, vaLeft - 1) : -1.0
            float rightVol = vaRight < rows - 1 ? array.get(volBag, vaRight + 1) : -1.0

            if rightVol > leftVol and vaRight < rows - 1
                vaRight += 1
                covered += rightVol
            else if vaLeft > 0
                vaLeft -= 1
                covered += leftVol
            else if vaRight < rows - 1
                vaRight += 1
                covered += rightVol
            else
                break

    float vaLowPrice = lowBand + (vaLeft * step)
    float vaHighPrice = lowBand + ((vaRight + 1) * step)

    [pocPrice, vaLowPrice, vaHighPrice, totalVol, totalDelta, maxVol]

renderProfile(float lowBand, float highBand, int rows, float[] volBag, float[] deltaBag) =>
    deleteLineArray(ledgerRays)

    if showProfileInput and rows > 0 and ledgerLive
        float maxVol = 0.0
        for i = 0 to rows - 1
            maxVol := math.max(maxVol, array.get(volBag, i))
        maxVol := math.max(maxVol, 1.0)

        float step = profileStep(lowBand, highBand, rows)
        int anchorX = bar_index + 1

        for i = 0 to rows - 1
            float rowVol = array.get(volBag, i)
            if rowVol > 0
                float rowDelta = array.get(deltaBag, i)
                float deltaBias = rowDelta / rowVol
                int rayWidth = math.max(1, int(math.round((rowVol / maxVol) * profileWidthInput)))
                float rowPrice = lowBand + ((i + 0.5) * step)
                color rayColor = color.new(color.from_gradient(deltaBias, -1, 1, bearColorInput, bullColorInput), 18)
                line ray = line.new(anchorX, rowPrice, anchorX + rayWidth, rowPrice, xloc = xloc.bar_index, extend = extend.none, color = rayColor, width = 4)
                array.push(ledgerRays, ray)

//--------------------------------------------------------------------------------------------------}
// Compression scan
//--------------------------------------------------------------------------------------------------{
float atrValue = ta.atr(atrLenInput)
float scanHigh = ta.highest(high, setupBarsInput)
float scanLow = ta.lowest(low, setupBarsInput)
float scanSpan = scanHigh - scanLow
float scanSpanAtr = scanSpan / math.max(atrValue, syminfo.mintick)
float scanBodyEff = ta.sma(math.abs(close - open) / math.max(high - low, syminfo.mintick), setupBarsInput)
float scanBias = math.sum(close > open ? 1.0 : close < open ? -1.0 : 0.0, setupBarsInput) / setupBarsInput
float scanCompression = 100.0 - clampFloat((scanSpanAtr / compressionCapInput) * 100.0, 0.0, 100.0)
float scanBalance = 100.0 - math.abs(scanBias) * 100.0
float buildReadiness = clampFloat(scanCompression * 0.55 + scanBalance * 0.30 + (100.0 - ledgerBodyEff * 100.0) * 0.15, 0.0, 100.0)
ledgerCompression := scanCompression
ledgerBodyEff := nz(scanBodyEff)
ledgerImbalance := math.abs(scanBias)
ledgerWidthAtr := scanSpanAtr

bool scanReady = not na(scanHigh) and not na(scanLow) and not na(atrValue)
bool scanTight = scanReady and scanSpanAtr <= compressionCapInput and ledgerBodyEff <= bodyCapInput and ledgerImbalance <= imbalanceCapInput
int activationBarsNeeded = math.max(4, int(math.ceil(setupBarsInput * 0.35)))

// Count confirmed compression bars while the ledger is idle.
if barstate.isconfirmed and not ledgerLive
    ledgerArmedBars := scanTight ? ledgerArmedBars + 1 : 0

bool activateLedger = barstate.isconfirmed and not ledgerLive and ledgerArmedBars >= activationBarsNeeded
bool breakUpNow = false
bool breakDnNow = false
bool sweepUpNow = false
bool sweepDnNow = false
bool freshActivation = false
bool breakEvent = false

//--------------------------------------------------------------------------------------------------}
// Ledger activation and live auction maintenance
//--------------------------------------------------------------------------------------------------{
if activateLedger
    ledgerLive := true
    freshActivation := true
    ledgerStartIndex := bar_index - setupBarsInput + 1
    ledgerHigh := scanHigh
    ledgerLow := scanLow
    ledgerMid := (ledgerHigh + ledgerLow) / 2.0
    ledgerAgeBars := 0
    sweepHighCount := 0
    sweepLowCount := 0
    ledgerReadout := "Ledger Open"

    if not na(ledgerBuildBox)
        box.delete(ledgerBuildBox)
        ledgerBuildBox := na

    resetBins(ledgerVolBins, ledgerDeltaBins, profileRowsInput)
    for off = setupBarsInput - 1 to 0
        accumulateOffset(off, ledgerLow, ledgerHigh, profileRowsInput, ledgerVolBins, ledgerDeltaBins)

    [ledgerPocPrice, ledgerVaLow, ledgerVaHigh, ledgerTotalVol, ledgerDeltaNet, _] = refreshProfile(ledgerLow, ledgerHigh, profileRowsInput, ledgerVolBins, ledgerDeltaBins)
    ledgerTilt := ledgerTotalVol > 0 ? ledgerDeltaNet / ledgerTotalVol : 0.0
    ledgerWidthAtr := (ledgerHigh - ledgerLow) / math.max(atrValue, syminfo.mintick)
    ledgerCompression := 100.0 - clampFloat((ledgerWidthAtr / compressionCapInput) * 100.0, 0.0, 100.0)
    renderProfile(ledgerLow, ledgerHigh, profileRowsInput, ledgerVolBins, ledgerDeltaBins)

    if showRangeShellInput
        if not na(ledgerShellBox)
            box.delete(ledgerShellBox)
        if not na(ledgerValueBox)
            box.delete(ledgerValueBox)
        ledgerShellBox := box.new(ledgerStartIndex, ledgerHigh, bar_index, ledgerLow, bgcolor = color.new(color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput), 92), border_color = color.new(BORDER_TONE, 15))
        ledgerValueBox := box.new(ledgerStartIndex, ledgerVaHigh, bar_index, ledgerVaLow, bgcolor = color.new(neutralColorInput, 84), border_color = color.new(neutralColorInput, 55))

if ledgerLive and barstate.isconfirmed and not freshActivation
    ledgerAgeBars += 1

    float breakoutBand = atrValue * breakoutBufferInput
    breakUpNow := close > ledgerHigh + breakoutBand
    breakDnNow := close < ledgerLow - breakoutBand
    sweepUpNow := high > ledgerHigh and close < ledgerHigh
    sweepDnNow := low < ledgerLow and close > ledgerLow

    if breakUpNow or breakDnNow
        breakEvent := true
        ledgerReadout := breakUpNow ? "Up Break" : "Down Break"
        ledgerLive := false
        ledgerArmedBars := 0
        deleteLineArray(ledgerRays)
        if not na(ledgerShellBox)
            box.delete(ledgerShellBox)
            ledgerShellBox := na
        if not na(ledgerValueBox)
            box.delete(ledgerValueBox)
            ledgerValueBox := na
    else
        if sweepUpNow
            sweepHighCount += 1
        if sweepDnNow
            sweepLowCount += 1

        // New bar is only added after the range is confirmed active.
        accumulateOffset(0, ledgerLow, ledgerHigh, profileRowsInput, ledgerVolBins, ledgerDeltaBins)
        [ledgerPocPrice, ledgerVaLow, ledgerVaHigh, ledgerTotalVol, ledgerDeltaNet, _] = refreshProfile(ledgerLow, ledgerHigh, profileRowsInput, ledgerVolBins, ledgerDeltaBins)
        ledgerTilt := ledgerTotalVol > 0 ? ledgerDeltaNet / ledgerTotalVol : 0.0
        ledgerWidthAtr := (ledgerHigh - ledgerLow) / math.max(atrValue, syminfo.mintick)
        ledgerCompression := 100.0 - clampFloat((ledgerWidthAtr / compressionCapInput) * 100.0, 0.0, 100.0)
        ledgerReadout := "Auction Live"
        renderProfile(ledgerLow, ledgerHigh, profileRowsInput, ledgerVolBins, ledgerDeltaBins)

        if showRangeShellInput
            if not na(ledgerShellBox)
                box.delete(ledgerShellBox)
            if not na(ledgerValueBox)
                box.delete(ledgerValueBox)
            ledgerShellBox := box.new(ledgerStartIndex, ledgerHigh, bar_index, ledgerLow, bgcolor = color.new(color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput), 92), border_color = color.new(BORDER_TONE, 15))
            ledgerValueBox := box.new(ledgerStartIndex, ledgerVaHigh, bar_index, ledgerVaLow, bgcolor = color.new(neutralColorInput, 84), border_color = color.new(neutralColorInput, 55))

// When the ledger is idle, clear the drawings so the chart stays clean.
if not ledgerLive and not freshActivation
    ledgerReadout := breakEvent ? ledgerReadout : (ledgerArmedBars > 0 ? "Building" : "Scanning")
    ledgerAgeBars := 0
    ledgerTilt := 0.0
    ledgerTotalVol := 0.0
    ledgerDeltaNet := 0.0
    ledgerPocPrice := na
    ledgerVaHigh := na
    ledgerVaLow := na
    if not na(ledgerShellBox)
        box.delete(ledgerShellBox)
        ledgerShellBox := na
    if not na(ledgerValueBox)
        box.delete(ledgerValueBox)
        ledgerValueBox := na
    if scanReady and showBuildShellInput and (ledgerArmedBars > 0 or scanTight)
        if not na(ledgerBuildBox)
            box.delete(ledgerBuildBox)
        color buildTone = color.new(color.from_gradient(scanBias, -1, 1, bearColorInput, bullColorInput), 90)
        ledgerBuildBox := box.new(bar_index - setupBarsInput + 1, scanHigh, bar_index, scanLow, bgcolor = buildTone, border_color = color.new(color.from_gradient(scanCompression, 0, 100, bearColorInput, bullColorInput), 10))
    else if not na(ledgerBuildBox)
        box.delete(ledgerBuildBox)
        ledgerBuildBox := na
    deleteLineArray(ledgerRays)

if barstate.islast
    deleteLineRef(ledgerHighLine)
    deleteLineRef(ledgerLowLine)
    deleteLineRef(ledgerPocLine)

    if ledgerLive
        color activeTone = color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput)
        ledgerHighLine := line.new(ledgerStartIndex, ledgerHigh, bar_index + 6, ledgerHigh, xloc = xloc.bar_index, extend = extend.none, color = color.new(bullColorInput, 0), style = line.style_solid, width = 2)
        ledgerLowLine := line.new(ledgerStartIndex, ledgerLow, bar_index + 6, ledgerLow, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColorInput, 0), style = line.style_solid, width = 2)
        ledgerPocLine := line.new(ledgerStartIndex, ledgerPocPrice, bar_index + 6, ledgerPocPrice, xloc = xloc.bar_index, extend = extend.none, color = color.new(activeTone, 0), style = line.style_dotted, width = 3)
    else if scanReady and (ledgerArmedBars > 0 or scanTight)
        ledgerHighLine := line.new(bar_index - setupBarsInput + 1, scanHigh, bar_index + 4, scanHigh, xloc = xloc.bar_index, extend = extend.none, color = color.new(bullColorInput, 25), style = line.style_dashed, width = 2)
        ledgerLowLine := line.new(bar_index - setupBarsInput + 1, scanLow, bar_index + 4, scanLow, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColorInput, 25), style = line.style_dashed, width = 2)

//--------------------------------------------------------------------------------------------------}
// Visual plots
//--------------------------------------------------------------------------------------------------{
float displayHigh = ledgerLive ? ledgerHigh : na
float displayLow = ledgerLive ? ledgerLow : na
float displayMid = ledgerLive ? ledgerMid : na
float displayPoc = ledgerLive ? ledgerPocPrice : na
float displayVaHigh = ledgerLive ? ledgerVaHigh : na
float displayVaLow = ledgerLive ? ledgerVaLow : na
bool developingVisible = not ledgerLive and scanReady and showDevelopingMapInput and buildReadiness >= 18.0
float displayBuildHigh = developingVisible ? scanHigh : na
float displayBuildLow = developingVisible ? scanLow : na
float displayBuildMid = developingVisible ? (scanHigh + scanLow) / 2.0 : na
float displayBuildUpper = developingVisible ? scanLow + (scanHigh - scanLow) * 0.75 : na
float displayBuildLower = developingVisible ? scanLow + (scanHigh - scanLow) * 0.25 : na

pHigh = plot(displayHigh, "Ledger High", color = na, display = display.none)
pMid  = plot(displayMid, "Ledger Mid", color = na, display = display.none)
pLow  = plot(displayLow, "Ledger Low", color = na, display = display.none)
pBuildHi = plot(displayBuildHigh, "Build High", color = color.new(bullColorInput, 20), linewidth = 2, style = plot.style_linebr)
pBuildUpper = plot(displayBuildUpper, "Build Upper Quartile", color = color.new(bullColorInput, 75), linewidth = 1, style = plot.style_linebr)
pBuildMid = plot(displayBuildMid, "Build Mid", color = color.new(neutralColorInput, 40), linewidth = 1, style = plot.style_linebr)
pBuildLower = plot(displayBuildLower, "Build Lower Quartile", color = color.new(bearColorInput, 75), linewidth = 1, style = plot.style_linebr)
pBuildLo = plot(displayBuildLow, "Build Low", color = color.new(bearColorInput, 20), linewidth = 2, style = plot.style_linebr)
pPoc  = plot(displayPoc, "POC", color = color.new(color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput), 0), linewidth = 2, style = plot.style_linebr)
pVaHi = plot(displayVaHigh, "Value Area High", color = color.new(neutralColorInput, 0), linewidth = 1, style = plot.style_linebr)
pVaLo = plot(displayVaLow, "Value Area Low", color = color.new(neutralColorInput, 0), linewidth = 1, style = plot.style_linebr)

fill(pHigh, pMid, color.new(color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput), 88), title = "Upper Ledger Wash")
fill(pMid, pLow, color.new(color.from_gradient(ledgerTilt, -1, 1, bullColorInput, bearColorInput), 90), title = "Lower Ledger Wash")
fill(pVaHi, pVaLo, color.new(neutralColorInput, 84), title = "Value Area Core")
fill(pBuildHi, pBuildUpper, color.new(bullColorInput, 90), title = "Build Upper Shell")
fill(pBuildUpper, pBuildMid, color.new(color.from_gradient(buildReadiness, 0, 100, neutralColorInput, bullColorInput), 92), title = "Build Upper Core")
fill(pBuildMid, pBuildLower, color.new(color.from_gradient(buildReadiness, 0, 100, neutralColorInput, bearColorInput), 92), title = "Build Lower Core")
fill(pBuildLower, pBuildLo, color.new(bearColorInput, 90), title = "Build Lower Shell")

plotshape(showSweepMarksInput and ledgerLive and barstate.isconfirmed and sweepUpNow, title = "Upper Sweep", style = shape.circle, location = location.abovebar, size = size.tiny, color = color.new(bearColorInput, 0))
plotshape(showSweepMarksInput and ledgerLive and barstate.isconfirmed and sweepDnNow, title = "Lower Sweep", style = shape.circle, location = location.belowbar, size = size.tiny, color = color.new(bullColorInput, 0))
plotshape(showBreakMarksInput and barstate.isconfirmed and breakUpNow ? ledgerHigh : na, title = "Up Break Marker", style = shape.circle, location = location.absolute, size = size.small, color = color.new(bullColorInput, 0))
plotshape(showBreakMarksInput and barstate.isconfirmed and breakDnNow ? ledgerLow : na, title = "Down Break Marker", style = shape.circle, location = location.absolute, size = size.small, color = color.new(bearColorInput, 0))
plotshape(showBreakMarksInput and barstate.isconfirmed and breakUpNow, title = "Up Acceptance", style = shape.triangleup, location = location.belowbar, size = size.tiny, color = color.new(bullColorInput, 0))
plotshape(showBreakMarksInput and barstate.isconfirmed and breakDnNow, title = "Down Acceptance", style = shape.triangledown, location = location.abovebar, size = size.tiny, color = color.new(bearColorInput, 0))
plotshape(showBreakMarksInput and barstate.isconfirmed and developingVisible and ta.crossover(close, displayBuildUpper), title = "Build Lift", style = shape.diamond, location = location.abovebar, size = size.tiny, color = color.new(bullColorInput, 0))
plotshape(showBreakMarksInput and barstate.isconfirmed and developingVisible and ta.crossunder(close, displayBuildLower), title = "Build Slip", style = shape.diamond, location = location.belowbar, size = size.tiny, color = color.new(bearColorInput, 0))

// A subtle bar tint helps the user see whether auction pressure is leaning up or down.
color tintTone = na
if tintBarsInput
    if ledgerLive
        if sweepUpNow
            tintTone := color.new(bearColorInput, 40)
        else if sweepDnNow
            tintTone := color.new(bullColorInput, 40)
        else
            tintTone := color.new(color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput), 62)
    else if scanReady and (ledgerArmedBars > 0 or scanTight)
        tintTone := color.new(color.from_gradient(scanBias + (buildReadiness - 50.0) / 120.0, -1, 1, bearColorInput, bullColorInput), 54)
barcolor(tintTone)

// A soft background wash keeps the overlay readable on dark charts.
bgcolor(ledgerLive ? color.new(color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput), 92) : ((scanReady and (ledgerArmedBars > 0 or scanTight)) ? color.new(color.from_gradient(scanBias, -1, 1, bearColorInput, bullColorInput), 95) : na))

//--------------------------------------------------------------------------------------------------}
// Alerts
//--------------------------------------------------------------------------------------------------{
alertcondition(barstate.isconfirmed and sweepUpNow, "Upper Sweep", "Aurelian Auction Ledger [JOAT] detected an upper sweep on a confirmed bar.")
alertcondition(barstate.isconfirmed and sweepDnNow, "Lower Sweep", "Aurelian Auction Ledger [JOAT] detected a lower sweep on a confirmed bar.")
alertcondition(barstate.isconfirmed and breakUpNow, "Up Break", "Aurelian Auction Ledger [JOAT] accepted an upside breakout on a confirmed bar.")
alertcondition(barstate.isconfirmed and breakDnNow, "Down Break", "Aurelian Auction Ledger [JOAT] accepted a downside breakout on a confirmed bar.")

//--------------------------------------------------------------------------------------------------}
// Dashboard
//--------------------------------------------------------------------------------------------------{
var table ledgerDash = table.new(position.top_right, 2, 8, bgcolor = SHADOW_TONE, frame_color = BORDER_TONE, frame_width = 1, border_width = 0)

if showDashboardInput and barstate.islast
    color panelGlow = color.new(color.from_gradient(ledgerLive ? ledgerTilt : scanBias, -1, 1, bearColorInput, bullColorInput), 82)
    table.cell(ledgerDash, 0, 0, "Aurelian Auction Ledger", text_color = TEXT_TONE, bgcolor = panelGlow, text_halign = text.align_center, text_size = size.normal)
    table.merge_cells(ledgerDash, 0, 0, 1, 0)

    table.cell(ledgerDash, 0, 1, "Mode", text_color = SUB_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 1, ledgerReadout, text_color = ledgerLive ? color.from_gradient(ledgerTilt, -1, 1, bearColorInput, bullColorInput) : neutralColorInput, bgcolor = color.new(panelGlow, 92), text_halign = text.align_right, text_size = size.normal)

    table.cell(ledgerDash, 0, 2, "Compression", text_color = SUB_TONE, bgcolor = color.new(panelGlow, 95), text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 2, pctText(ledgerCompression), text_color = ledgerCompression > 50 ? bullColorInput : bearColorInput, bgcolor = color.new(panelGlow, 95), text_halign = text.align_right, text_size = size.normal)

    table.cell(ledgerDash, 0, 3, "Width", text_color = SUB_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 3, ratioText(ledgerWidthAtr) + " xATR", text_color = TEXT_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_right, text_size = size.normal)

    table.cell(ledgerDash, 0, 4, "POC", text_color = SUB_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 4, ledgerLive and not na(ledgerPocPrice) ? priceText(ledgerPocPrice) : "-", text_color = bullColorInput, bgcolor = color.new(panelGlow, 95), text_halign = text.align_right, text_size = size.normal)

    table.cell(ledgerDash, 0, 5, "Value Area", text_color = SUB_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 5, ledgerLive and not na(ledgerVaLow) and not na(ledgerVaHigh) ? priceText(ledgerVaLow) + " / " + priceText(ledgerVaHigh) : "-", text_color = TEXT_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_right, text_size = size.normal)

    table.cell(ledgerDash, 0, 6, "Sweeps", text_color = SUB_TONE, bgcolor = color.new(panelGlow, 95), text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 6, str.tostring(sweepHighCount) + " / " + str.tostring(sweepLowCount), text_color = TEXT_TONE, bgcolor = color.new(panelGlow, 95), text_halign = text.align_right, text_size = size.normal)

    table.cell(ledgerDash, 0, 7, "Tilt / Build", text_color = SUB_TONE, bgcolor = SHADOW_TONE, text_halign = text.align_left, text_size = size.normal)
    table.cell(ledgerDash, 1, 7, pctText(ledgerTilt * 100.0) + " / " + pctText(buildReadiness), text_color = color.from_gradient(ledgerLive ? ledgerTilt : scanBias, -1, 1, bearColorInput, bullColorInput), bgcolor = color.new(panelGlow, 92), text_halign = text.align_right, text_size = size.normal)
````
