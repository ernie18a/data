# ARBF v1.4

- url: https://www.tradingview.com/script/gnYUS0Ey-ARBF-v1-4/
- type: indicator
- pine_id: PUB;3bbb3dfa8d754eb58c695ab63141f24f
- version: 3.0

## Description

ARBF (Asia Range, Bias, Fair Value Gaps) is an intraday tool built around a single daily decision: which way price commits after the Asian session, and where it is likely to react on the way there.

It combines three ideas that normally live in separate indicators into one workflow.

[b]ASIA RANGE AND DAILY BIAS
[/b]The script marks the high and low of the Asian session (default 19:00 to 02:59 New York time, fully configurable) and draws the range as a box with optional extended levels into London and New York. During a configurable signal window (default London open onward) it watches for the first candle that closes beyond the Asia high or low. A close above the high sets a bullish bias for the day, a close below the low sets a bearish bias. Only the first break is taken, so the bias is fixed once and not repainted afterward.

[b]FAIR VALUE GAPS WITH BODY VS WICK CLASSIFICATION
[/b]Three-candle imbalances are detected and drawn as zones. Each gap is classified: if a candle body closes fully beyond the gap it is treated as strong (solid border), if only a wick pierces it the gap is treated as weak and more likely to be retested (dashed border). Gaps are removed once price mitigates them, and there is an age limit so the chart stays clean. An alert can fire when price re-enters an unmitigated gap that aligns with the active daily bias.

[b]BALANCED PRICE RANGE (BPR)
[/b]When a bullish and a bearish gap overlap in the same price area, that overlap is a Balanced Price Range, often a strong reaction zone. This version keeps a short-term memory of recently swept gaps, so a BPR is still recognised when one gap is filled and an opposite gap forms in the same area shortly after. The memory window and size are adjustable.

[b]HOW TO USE IT
[/b]1. Let the Asian range complete.
2. Wait for the bias signal during your chosen window.
3. Trade only in the direction of that bias, using unmitigated FVGs and BPR zones in that direction as your areas of interest for entries and reactions.
4. Use the alerts to be notified when price reaches a relevant gap or BPR.

[b]NOTES
[/b]
Credits: Farouk Seascalper
All session logic is forced to New York time and is daylight-saving aware. Times in the inputs are New York hours. The included alert text references XAUUSD as an example only; the indicator works on any symbol and timeframe, though it is designed for intraday charts. This is an analysis tool, not financial advice, and signals should be confirmed with your own process.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Hunters Trades

//@version=6
indicator("ARBF v3.0", shorttitle="ARBF v3.0", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════════════
//  ARBF v3.0 ... Asia Range, Bias, FVG + ABLC signal layer
//  v3.0: HTF alignment capture moved to its own top-level block (was
//        fragile nesting inside the trigger scan), ABLC trade lines now
//        deleted at session reset and terminated at signal + max window,
//        neutral tooltip wording, header/version cleanup
//  v2.5: FVG mitigation modes (Touch / 50% / Full Fill, default Full),
//        BPR pairing back to live + recently-swept FVGs only,
//        min sizes optionally as % of price for BTC
//  v2.3: mitigated boxes now clearly visible (were 90% transparent)
//  v2.2: defaults ... FVG min $2, mitigated FVGs/BPRs shown greyed
//  v2.1: BPR spam fix ... swept-FVG memory consumed on match, BPR dedupe,
//        minimum BPR zone size input
//  New in v2.0:
//  ... London Opening Range box (03:00-03:15 ET)
//  ... HTF filter: 4H and 1D close vs EMA20 must align with bias
//  ... ABLC entry signal: 5m close beyond London OR in bias direction
//      with HTF aligned ... label, SL/TP lines, alert
//  ... Asia range size gate (greys out bias when range abnormal)
// ══════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════

// ── Session Times (forced New York / ET) ──
grpSession = "Session Settings (New York Time)"
asiaStartHour   = input.int(21, "Asia Start Hour", minval=0, maxval=23, group=grpSession, display=display.none, tooltip="Asia session start in ET. Default 21:00 ET = 08:00 Bangkok")
asiaStartMin    = input.int(0,  "Asia Start Minute", minval=0, maxval=59, group=grpSession, display=display.none)
asiaEndHour     = input.int(1,  "Asia End Hour", minval=0, maxval=23, group=grpSession, display=display.none, tooltip="Asia session end in ET. Default 01:00 ET = 12:00 Bangkok")
asiaEndMin      = input.int(0,  "Asia End Minute", minval=0, maxval=59, group=grpSession, display=display.none)
biasFollowAsia  = input.bool(true, "Bias Scan Starts At Asia End", group=grpSession, display=display.none, tooltip="ON: the bias scan begins the moment the Asia session ends. OFF: scan begins at the manual Signal Window Start hour below.")
signalStartHour = input.int(3,  "Signal Window Start", minval=0, maxval=23, group=grpSession, display=display.none, tooltip="Manual bias scan start hour. Only used when 'Bias Scan Starts At Asia End' is OFF.")
signalEndHour   = input.int(12, "Signal Window End", minval=0, maxval=23, group=grpSession, display=display.none, tooltip="Stop looking for bias signals")

// ── Asia Range Display ──
grpAsia = "Asia Range"
showAsiaRange   = input.bool(true, "Show Asia Range Box", group=grpAsia, display=display.none)
asiaBoxColor    = input.color(color.new(color.purple, 85), "Asia Box Color", group=grpAsia, display=display.none)
asiaBorderColor = input.color(color.new(color.purple, 40), "Asia Border Color", group=grpAsia, display=display.none)
extendAsiaRange = input.bool(true, "Extend Asia Levels Into London/NY", group=grpAsia, display=display.none)
asiaLineStyle   = input.string("Dashed", "Extended Line Style", options=["Solid", "Dashed", "Dotted"], group=grpAsia, display=display.none)
useRangeGate    = input.bool(true, "Apply Asia Range Size Gate", group=grpAsia, display=display.none, tooltip="Skip days with abnormal Asia range")
rangeGateMin    = input.float(3.0, "Min Asia Range ($)", step=0.5, group=grpAsia, display=display.none, tooltip="For gold use ~3. For BTC use a value near 0.1% of price")
rangeGateMax    = input.float(40.0, "Max Asia Range ($)", step=0.5, group=grpAsia, display=display.none, tooltip="For gold use ~40. For BTC use a value near 3% of price")

// ── Bias Detection ──
grpBias = "Bias Detection"
showBiasLabel   = input.bool(true, "Show Bias Label", group=grpBias, display=display.none)
showBiasArrow   = input.bool(true, "Show Bias Arrow on Signal Bar", group=grpBias, display=display.none)
colorBarsOnBias = input.bool(false, "Color Bars After Bias Signal", group=grpBias, display=display.none)
biasLongColor   = input.color(color.new(color.green, 0), "Bullish Bias Color", group=grpBias, display=display.none)
biasShortColor  = input.color(color.new(color.red, 0), "Bearish Bias Color", group=grpBias, display=display.none)

// ── ABLC Signal (London OR + HTF Filter) ──
grpABLC = "ABLC Signal (London Continuation)"
showABLC        = input.bool(true, "Enable ABLC Signal Layer", group=grpABLC, display=display.none, tooltip="Asia Bias London Continuation ... requires bias + London OR break + HTF alignment")
showLondonOR    = input.bool(true, "Show London Opening Range Box", group=grpABLC, display=display.none)
orBoxColor      = input.color(color.new(color.aqua, 85), "London OR Box Color", group=grpABLC, display=display.none)
orBorderColor   = input.color(color.new(color.aqua, 30), "London OR Border Color", group=grpABLC, display=display.none)
useHTF4H        = input.bool(true, "Require 4H EMA20 Alignment", group=grpABLC, display=display.none, tooltip="4H close vs 4H EMA20 must match bias direction")
useHTF1D        = input.bool(true, "Require 1D EMA20 Alignment", group=grpABLC, display=display.none, tooltip="1D close vs 1D EMA20 must match bias direction")
htfEmaLen       = input.int(20, "HTF EMA Length", minval=5, maxval=100, group=grpABLC, display=display.none)
slBuffer        = input.float(1.0, "SL Buffer Beyond OR Edge ($)", step=0.5, group=grpABLC, display=display.none, tooltip="For gold ~1. For BTC ~20.")
tpRR            = input.float(2.0, "TP Risk:Reward", minval=0.5, maxval=5.0, step=0.5, group=grpABLC, display=display.none, tooltip="Take profit distance as a multiple of risk. Default 2.0")
entryMaxBars    = input.int(120, "Max Bars To Wait For OR Break", minval=10, maxval=300, group=grpABLC, display=display.none, tooltip="After OR completes, stop waiting for entry after this many bars")
showTradeLines  = input.bool(true, "Show Entry/SL/TP Lines", group=grpABLC, display=display.none)

// ── FVG Detection ──
grpFVG = "Fair Value Gaps"
showFVGs        = input.bool(true, "Show FVGs", group=grpFVG, display=display.none)
fvgMinSize      = input.float(2.0, "Min FVG Size", step=0.1, group=grpFVG, display=display.none, tooltip="In $ by default, or % of price if percent mode is on. Gold: 2 ... BTC: ~50 (or 0.05 in percent mode)")
fvgMitMode      = input.string("Full Fill", "FVG Mitigation Mode", options=["Touch", "50% Fill", "Full Fill"], group=grpFVG, display=display.none, tooltip="Touch: any wick into the gap mitigates it. 50% Fill: price must reach the gap midpoint. Full Fill: price must trade through the entire gap (default ... wicks do not kill gaps)")
showBodyWick    = input.bool(true, "Classify Body vs Wick FVGs", group=grpFVG, display=display.none)
maxFVGAge       = input.int(200, "Max FVG Age (bars)", minval=10, maxval=1000, group=grpFVG, display=display.none)
hideMitigated   = input.bool(false, "Hide Mitigated FVGs", group=grpFVG, display=display.none)
bullFVGColor    = input.color(color.new(color.green, 80), "Bullish FVG", group=grpFVG, display=display.none)
bearFVGColor    = input.color(color.new(color.red, 80), "Bearish FVG", group=grpFVG, display=display.none)
strongBorder    = input.color(color.new(color.lime, 30), "Strong FVG Border (Body Close)", group=grpFVG, display=display.none)
weakBorder      = input.color(color.new(color.orange, 30), "Weak FVG Border (Wick Only)", group=grpFVG, display=display.none)

// ── BPR ──
grpBPR = "Balanced Price Range (BPR)"
showBPR         = input.bool(true, "Show BPR Zones", group=grpBPR, display=display.none)
bprColor        = input.color(color.new(color.yellow, 70), "BPR Zone Color", group=grpBPR, display=display.none)
bprBorderColor  = input.color(color.new(color.yellow, 20), "BPR Border Color", group=grpBPR, display=display.none)
bprLabelSize    = input.string("Small", "BPR Label Size", options=["Tiny", "Small", "Normal"], group=grpBPR, display=display.none)
hideBPRMitigated = input.bool(false, "Hide Mitigated BPRs", group=grpBPR, display=display.none)
maxBPRAge       = input.int(300, "Max BPR Age (bars)", minval=10, maxval=2000, group=grpBPR, display=display.none)
bprMemoryBars   = input.int(50, "BPR ... Swept FVG Memory (bars)", minval=5, maxval=300, group=grpBPR, display=display.none)
bprMemoryMax    = input.int(30, "BPR ... Swept FVG Memory (max count)", minval=5, maxval=100, group=grpBPR, display=display.none)
minBPRSize      = input.float(0.5, "Min BPR Zone Size", step=0.1, group=grpBPR, display=display.none, tooltip="In $ by default, or % of price if percent mode is on. Gold: 0.5 ... BTC: ~20 (or 0.02 in percent mode)")
minSizesArePct  = input.bool(false, "Min Sizes As % Of Price", group=grpBPR, display=display.none, tooltip="ON: Min FVG Size and Min BPR Zone Size are read as percent of current price ... use this for BTC and other large-priced assets")

// ── Alerts ──
grpAlert = "Alerts"
alertOnBias     = input.bool(true, "Alert on Bias Signal", group=grpAlert, display=display.none)
alertOnABLC     = input.bool(true, "Alert on ABLC Entry Signal", group=grpAlert, display=display.none)
alertOnFVGTest  = input.bool(true, "Alert When Price Enters Unmitigated FVG", group=grpAlert, display=display.none)
alertOnBPR      = input.bool(true, "Alert When Price Enters BPR Zone", group=grpAlert, display=display.none)


// ══════════════════════════════════════════════════════════════════
//  SESSION DETECTION (forced America/New_York timezone)
// ══════════════════════════════════════════════════════════════════

etHour = hour(time, "America/New_York")
etMin  = minute(time, "America/New_York")
currentMin = etHour * 60 + etMin

etHourPrev = hour(time[1], "America/New_York")
etMinPrev  = minute(time[1], "America/New_York")
prevMin = etHourPrev * 60 + etMinPrev

asiaStartM = asiaStartHour * 60 + asiaStartMin
asiaEndM   = asiaEndHour * 60 + asiaEndMin
sigStartM  = signalStartHour * 60
sigEndM    = signalEndHour * 60

isAsia = asiaStartM > asiaEndM ? (currentMin >= asiaStartM or currentMin <= asiaEndM) : (currentMin >= asiaStartM and currentMin <= asiaEndM)
wasAsia = asiaStartM > asiaEndM ? (prevMin >= asiaStartM or prevMin <= asiaEndM) : (prevMin >= asiaStartM and prevMin <= asiaEndM)
newAsiaSession = isAsia and not wasAsia

// London OR window: 03:00-03:15 ET
lonORStartM = 3 * 60
lonOREndM   = 3 * 60 + 15
isLondonOR  = currentMin >= lonORStartM and currentMin < lonOREndM
wasLondonOR = prevMin >= lonORStartM and prevMin < lonOREndM
newLondonOR = isLondonOR and not wasLondonOR
londonORDone = (not isLondonOR) and wasLondonOR


// ══════════════════════════════════════════════════════════════════
//  HTF FILTER (4H and 1D close vs EMA20, confirmed bars only)
// ══════════════════════════════════════════════════════════════════

// Confirmed-bar values only ... matches the backtest which used the last
// COMPLETED HTF bar at trigger time. [1] index avoids repaint.
htf4hClose = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_off)
htf4hEma   = request.security(syminfo.tickerid, "240", ta.ema(close, htfEmaLen)[1], lookahead=barmerge.lookahead_off)
htf1dClose = request.security(syminfo.tickerid, "D",   close[1], lookahead=barmerge.lookahead_off)
htf1dEma   = request.security(syminfo.tickerid, "D",   ta.ema(close, htfEmaLen)[1], lookahead=barmerge.lookahead_off)

htf4hBull = htf4hClose > htf4hEma
htf1dBull = htf1dClose > htf1dEma


// ══════════════════════════════════════════════════════════════════
//  ASIA RANGE TRACKING
// ══════════════════════════════════════════════════════════════════

var float asiaHigh = na
var float asiaLow  = na
var bool  asiaComplete = false
var int   asiaStartBar = na
var int   asiaEndBar = na

if newAsiaSession
    asiaHigh := high
    asiaLow  := low
    asiaComplete := false
    asiaStartBar := bar_index

if isAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow  := math.min(nz(asiaLow, low), low)

wasInAsia = isAsia[1] and not isAsia
if wasInAsia
    asiaComplete := true
    asiaEndBar := bar_index

// Range size gate
asiaRangeSize = not na(asiaHigh) and not na(asiaLow) ? asiaHigh - asiaLow : na
rangeGateOK = not useRangeGate or (not na(asiaRangeSize) and asiaRangeSize >= rangeGateMin and asiaRangeSize <= rangeGateMax)


// ══════════════════════════════════════════════════════════════════
//  ASIA RANGE DRAWING
// ══════════════════════════════════════════════════════════════════

var box asiaBox = na
var line asiaHighLine = na
var line asiaLowLine  = na

lineStyleVal = asiaLineStyle == "Solid" ? line.style_solid : asiaLineStyle == "Dashed" ? line.style_dashed : line.style_dotted

if showAsiaRange and wasInAsia and not na(asiaHigh) and not na(asiaLow)
    gateCol = rangeGateOK ? asiaBorderColor : color.new(color.gray, 60)
    gateBg  = rangeGateOK ? asiaBoxColor : color.new(color.gray, 92)
    asiaBox := box.new(asiaStartBar, asiaHigh, bar_index, asiaLow, border_color=gateCol, bgcolor=gateBg, border_width=1)
    if extendAsiaRange
        asiaHighLine := line.new(bar_index, asiaHigh, bar_index + 1, asiaHigh, color=gateCol, style=lineStyleVal, width=1, extend=extend.right)
        asiaLowLine  := line.new(bar_index, asiaLow, bar_index + 1, asiaLow, color=gateCol, style=lineStyleVal, width=1, extend=extend.right)

deadZoneStartM = 17 * 60
deadZoneEndM   = 21 * 60
isDeadZone = currentMin >= deadZoneStartM and currentMin < deadZoneEndM
wasDeadZone = prevMin >= deadZoneStartM and prevMin < deadZoneEndM
if isDeadZone and not wasDeadZone
    if not na(asiaHighLine)
        line.set_extend(asiaHighLine, extend.none)
        line.set_x2(asiaHighLine, bar_index)
    if not na(asiaLowLine)
        line.set_extend(asiaLowLine, extend.none)
        line.set_x2(asiaLowLine, bar_index)


// ══════════════════════════════════════════════════════════════════
//  BIAS DETECTION
// ══════════════════════════════════════════════════════════════════

var int   dailyBias = 0
var bool  biasTriggered = false
var float biasPrice = na
var int   biasBar = na
var bool  htfAlignedAtBias = false

if newAsiaSession
    dailyBias := 0
    biasTriggered := false
    biasPrice := na
    biasBar := na
    htfAlignedAtBias := false

biasScanActive = asiaComplete and currentMin <= sigEndM and (biasFollowAsia or currentMin >= sigStartM)

if biasScanActive and not biasTriggered and not na(asiaHigh) and not na(asiaLow) and rangeGateOK and barstate.isconfirmed
    if close > asiaHigh
        dailyBias := 1
        biasTriggered := true
        biasPrice := close
        biasBar := bar_index
    else if close < asiaLow
        dailyBias := -1
        biasTriggered := true
        biasPrice := close
        biasBar := bar_index

// Capture HTF alignment at the trigger moment ... own top-level block so it
// cannot be skipped by future edits to the scan gate above
if biasTriggered and biasBar == bar_index
    align4h = not useHTF4H or (dailyBias == 1 ? htf4hBull : not htf4hBull)
    align1d = not useHTF1D or (dailyBias == 1 ? htf1dBull : not htf1dBull)
    htfAlignedAtBias := align4h and align1d

if showBiasLabel and biasTriggered and biasBar == bar_index
    biasText = dailyBias == 1 ? "BULLISH BIAS" : "BEARISH BIAS"
    biasText := htfAlignedAtBias ? biasText + " ✓HTF" : biasText + " ✗HTF"
    biasCol  = dailyBias == 1 ? biasLongColor : biasShortColor
    biasCol  := htfAlignedAtBias ? biasCol : color.new(color.gray, 30)
    asiaRangeStr = str.tostring(asiaHigh - asiaLow, "#.##")
    tipText = "Asia H: " + str.tostring(asiaHigh, "#.##") + "\nAsia L: " + str.tostring(asiaLow, "#.##") + "\nRange: $" + asiaRangeStr + "\nClose: " + str.tostring(close, "#.##") + "\nHTF aligned: " + (htfAlignedAtBias ? "YES ... ABLC armed" : "NO ... stand down")
    label.new(bar_index, dailyBias == 1 ? low - (asiaHigh - asiaLow) * 0.3 : high + (asiaHigh - asiaLow) * 0.3, biasText, color=biasCol, textcolor=color.white, style=dailyBias == 1 ? label.style_label_up : label.style_label_down, size=size.small, tooltip=tipText)

if showBiasArrow and biasTriggered and biasBar == bar_index
    if dailyBias == 1
        label.new(bar_index, low, "▲", color=color.new(color.green, 100), textcolor=biasLongColor, style=label.style_label_up, size=size.large)
    else
        label.new(bar_index, high, "▼", color=color.new(color.red, 100), textcolor=biasShortColor, style=label.style_label_down, size=size.large)

barcolor(colorBarsOnBias and biasTriggered ? (dailyBias == 1 ? color.new(biasLongColor, 60) : color.new(biasShortColor, 60)) : na)


// ══════════════════════════════════════════════════════════════════
//  LONDON OR TRACKING + ABLC ENTRY SIGNAL
// ══════════════════════════════════════════════════════════════════

var float lonORHigh = na
var float lonORLow  = na
var bool  lonORComplete = false
var int   lonORStartBar = na
var int   lonOREndBar = na
var box   lonORBox = na

var bool  ablcFired = false
var int   ablcDir = 0
var float ablcEntry = na
var float ablcSL = na
var float ablcTP = na
var line  ablcEntryLine = na
var line  ablcSLLine = na
var line  ablcTPLine = na

if newAsiaSession
    lonORHigh := na
    lonORLow := na
    lonORComplete := false
    ablcFired := false
    ablcDir := 0
    ablcEntry := na
    ablcSL := na
    ablcTP := na
    if not na(ablcEntryLine)
        line.delete(ablcEntryLine)
        ablcEntryLine := na
    if not na(ablcSLLine)
        line.delete(ablcSLLine)
        ablcSLLine := na
    if not na(ablcTPLine)
        line.delete(ablcTPLine)
        ablcTPLine := na

if newLondonOR
    lonORHigh := high
    lonORLow := low
    lonORStartBar := bar_index

if isLondonOR
    lonORHigh := math.max(nz(lonORHigh, high), high)
    lonORLow := math.min(nz(lonORLow, low), low)

if londonORDone and not na(lonORHigh)
    lonORComplete := true
    lonOREndBar := bar_index
    if showABLC and showLondonOR
        lonORBox := box.new(lonORStartBar, lonORHigh, bar_index, lonORLow, border_color=orBorderColor, bgcolor=orBoxColor, border_width=1)

// ABLC entry: bias triggered + HTF aligned + OR complete + first close beyond OR in bias direction
ablcWindowOpen = lonORComplete and not ablcFired and (bar_index - lonOREndBar) <= entryMaxBars and currentMin < 16 * 60

ablcSignal = false
if showABLC and ablcWindowOpen and biasTriggered and htfAlignedAtBias and barstate.isconfirmed
    if dailyBias == 1 and close > lonORHigh
        ablcFired := true
        ablcDir := 1
        ablcEntry := close
        ablcSL := lonORLow - slBuffer
        ablcTP := ablcEntry + (ablcEntry - ablcSL) * tpRR
        ablcSignal := true
    else if dailyBias == -1 and close < lonORLow
        ablcFired := true
        ablcDir := -1
        ablcEntry := close
        ablcSL := lonORHigh + slBuffer
        ablcTP := ablcEntry - (ablcSL - ablcEntry) * tpRR
        ablcSignal := true

if ablcSignal
    sigText = ablcDir == 1 ? "ABLC LONG" : "ABLC SHORT"
    sigCol  = ablcDir == 1 ? biasLongColor : biasShortColor
    riskStr = str.tostring(math.abs(ablcEntry - ablcSL), "#.##")
    tipText = "Entry: " + str.tostring(ablcEntry, "#.##") + "\nSL: " + str.tostring(ablcSL, "#.##") + "\nTP (" + str.tostring(tpRR, "#.#") + "R): " + str.tostring(ablcTP, "#.##") + "\nRisk: $" + riskStr + "\nTime exit: 16:00 ET"
    label.new(bar_index, ablcDir == 1 ? low : high, sigText, color=sigCol, textcolor=color.white, style=ablcDir == 1 ? label.style_label_up : label.style_label_down, size=size.normal, tooltip=tipText)
    if showTradeLines
        ablcEntryLine := line.new(bar_index, ablcEntry, bar_index + entryMaxBars, ablcEntry, color=color.new(color.white, 20), style=line.style_solid, width=1)
        ablcSLLine := line.new(bar_index, ablcSL, bar_index + entryMaxBars, ablcSL, color=color.new(color.red, 20), style=line.style_dashed, width=1)
        ablcTPLine := line.new(bar_index, ablcTP, bar_index + entryMaxBars, ablcTP, color=color.new(color.green, 20), style=line.style_dashed, width=1)


// ══════════════════════════════════════════════════════════════════
//  FVG DETECTION + BODY vs WICK CLASSIFICATION
// ══════════════════════════════════════════════════════════════════

var array<box>   fvgBoxes     = array.new<box>()
var array<float> fvgTops      = array.new<float>()
var array<float> fvgBottoms   = array.new<float>()
var array<int>   fvgDirs      = array.new<int>()
var array<bool>  fvgStrong    = array.new<bool>()
var array<int>   fvgBirthBar  = array.new<int>()
var array<bool>  fvgMitigated = array.new<bool>()

var array<float> mitFvgTops    = array.new<float>()
var array<float> mitFvgBottoms = array.new<float>()
var array<int>   mitFvgDirs    = array.new<int>()
var array<int>   mitFvgMitBar  = array.new<int>()

var bool newBullFVG = false
var bool newBearFVG = false
var float newBullTop = na
var float newBullBot = na
var float newBearTop = na
var float newBearBot = na

newBullFVG := false
newBearFVG := false

effFvgMin = minSizesArePct ? close * fvgMinSize / 100 : fvgMinSize
effBprMin = minSizesArePct ? close * minBPRSize / 100 : minBPRSize

if showFVGs and barstate.isconfirmed
    bullGap = low - high[2]
    if bullGap > effFvgMin
        fvgTop = low
        fvgBot = high[2]
        bodyLow = math.min(open, close)
        isStrong = bodyLow > fvgTop
        borderCol = showBodyWick ? (isStrong ? strongBorder : weakBorder) : color.new(color.green, 40)
        fvgStyle  = isStrong ? line.style_solid : line.style_dashed
        newBox = box.new(bar_index - 2, fvgTop, bar_index + 10, fvgBot, border_color=borderCol, bgcolor=bullFVGColor, border_width=isStrong ? 2 : 1, border_style=fvgStyle)
        array.push(fvgBoxes, newBox)
        array.push(fvgTops, fvgTop)
        array.push(fvgBottoms, fvgBot)
        array.push(fvgDirs, 1)
        array.push(fvgStrong, isStrong)
        array.push(fvgBirthBar, bar_index)
        array.push(fvgMitigated, false)
        newBullFVG := true
        newBullTop := fvgTop
        newBullBot := fvgBot

    bearGap = low[2] - high
    if bearGap > effFvgMin
        fvgTop = low[2]
        fvgBot = high
        bodyHigh = math.max(open, close)
        isStrong = bodyHigh < fvgBot
        borderCol = showBodyWick ? (isStrong ? strongBorder : weakBorder) : color.new(color.red, 40)
        fvgStyle  = isStrong ? line.style_solid : line.style_dashed
        newBox = box.new(bar_index - 2, fvgTop, bar_index + 10, fvgBot, border_color=borderCol, bgcolor=bearFVGColor, border_width=isStrong ? 2 : 1, border_style=fvgStyle)
        array.push(fvgBoxes, newBox)
        array.push(fvgTops, fvgTop)
        array.push(fvgBottoms, fvgBot)
        array.push(fvgDirs, -1)
        array.push(fvgStrong, isStrong)
        array.push(fvgBirthBar, bar_index)
        array.push(fvgMitigated, false)
        newBearFVG := true
        newBearTop := fvgTop
        newBearBot := fvgBot


// ══════════════════════════════════════════════════════════════════
//  FVG MITIGATION + CLEANUP (runs before BPR detection)
// ══════════════════════════════════════════════════════════════════

var bool fvgTestAlert = false
fvgTestAlert := false

if showFVGs and array.size(fvgBoxes) > 0
    int sz = array.size(fvgBoxes)
    for i = sz - 1 to 0
        if i >= array.size(fvgBoxes)
            continue
        fTop   = array.get(fvgTops, i)
        fBot   = array.get(fvgBottoms, i)
        fDir   = array.get(fvgDirs, i)
        fBirth = array.get(fvgBirthBar, i)
        fMit   = array.get(fvgMitigated, i)
        bx     = array.get(fvgBoxes, i)
        age    = bar_index - fBirth
        bool mitHit = false
        if fvgMitMode == "Touch"
            mitHit := low <= fTop and high >= fBot
        else if fvgMitMode == "50% Fill"
            fvgMid = (fTop + fBot) / 2
            mitHit := fDir == 1 ? low <= fvgMid : high >= fvgMid
        else
            mitHit := fDir == 1 ? low <= fBot : high >= fTop
        if mitHit and not fMit and age > 1
            array.set(fvgMitigated, i, true)
            if showBPR
                array.push(mitFvgTops, fTop)
                array.push(mitFvgBottoms, fBot)
                array.push(mitFvgDirs, fDir)
                array.push(mitFvgMitBar, bar_index)
            if hideMitigated
                box.delete(bx)
                array.remove(fvgBoxes, i)
                array.remove(fvgTops, i)
                array.remove(fvgBottoms, i)
                array.remove(fvgDirs, i)
                array.remove(fvgStrong, i)
                array.remove(fvgBirthBar, i)
                array.remove(fvgMitigated, i)
                continue
            else
                box.set_bgcolor(bx, color.new(color.gray, 78))
                box.set_border_color(bx, color.new(color.gray, 40))
        if not fMit and age > 1 and biasTriggered
            approaching = false
            if fDir == 1 and dailyBias == 1
                approaching := low <= fTop * 1.001 and low >= fBot
            if fDir == -1 and dailyBias == -1
                approaching := high >= fBot * 0.999 and high <= fTop
            if approaching
                fvgTestAlert := true
        if not fMit and age <= maxFVGAge
            box.set_right(bx, bar_index + 5)
        if age > maxFVGAge
            box.delete(bx)
            array.remove(fvgBoxes, i)
            array.remove(fvgTops, i)
            array.remove(fvgBottoms, i)
            array.remove(fvgDirs, i)
            array.remove(fvgStrong, i)
            array.remove(fvgBirthBar, i)
            array.remove(fvgMitigated, i)


// ══════════════════════════════════════════════════════════════════
//  BPR DETECTION (live FVGs + swept-FVG memory)
// ══════════════════════════════════════════════════════════════════

var array<box>   bprBoxes     = array.new<box>()
var array<float> bprTops      = array.new<float>()
var array<float> bprBottoms   = array.new<float>()
var array<int>   bprBirthBar  = array.new<int>()
var array<bool>  bprMitigated = array.new<bool>()
var array<int>   bprLastDir   = array.new<int>()

var bool bprTestAlert = false
bprTestAlert := false

if showBPR and barstate.isconfirmed and array.size(mitFvgMitBar) > 0
    for i = array.size(mitFvgMitBar) - 1 to 0
        if i < array.size(mitFvgMitBar) and bar_index - array.get(mitFvgMitBar, i) > bprMemoryBars
            array.remove(mitFvgTops, i)
            array.remove(mitFvgBottoms, i)
            array.remove(mitFvgDirs, i)
            array.remove(mitFvgMitBar, i)
    while array.size(mitFvgMitBar) > bprMemoryMax
        array.remove(mitFvgTops, 0)
        array.remove(mitFvgBottoms, 0)
        array.remove(mitFvgDirs, 0)
        array.remove(mitFvgMitBar, 0)

if showBPR and barstate.isconfirmed
    int sz = array.size(fvgDirs)
    lblSize = bprLabelSize == "Tiny" ? size.tiny : bprLabelSize == "Small" ? size.small : size.normal

    // ── New BULLISH FVG: look for bearish overlap (live first, then memory) ──
    if newBullFVG
        bool bprMade = false
        if sz > 0
            for i = sz - 2 to 0
                if i < 0 or i >= array.size(fvgDirs)
                    continue
                if array.get(fvgMitigated, i)
                    continue
                if array.get(fvgDirs, i) != -1
                    continue
                existTop = array.get(fvgTops, i)
                existBot = array.get(fvgBottoms, i)
                overlapTop = math.min(existTop, newBullTop)
                overlapBot = math.max(existBot, newBullBot)
                if overlapTop - overlapBot >= effBprMin
                    // dedupe: skip if an unmitigated BPR already overlaps this zone
                    bool dupA = false
                    if array.size(bprTops) > 0
                        for q = 0 to array.size(bprTops) - 1
                            if not array.get(bprMitigated, q) and math.min(array.get(bprTops, q), overlapTop) > math.max(array.get(bprBottoms, q), overlapBot)
                                dupA := true
                                break
                    if not dupA
                        bprBox = box.new(bar_index - 2, overlapTop, bar_index + 20, overlapBot, border_color=bprBorderColor, bgcolor=bprColor, border_width=2, border_style=line.style_solid)
                        label.new(bar_index - 1, overlapTop, "BPR", color=color.new(color.yellow, 80), textcolor=color.yellow, style=label.style_label_down, size=lblSize, tooltip="Balanced Price Range\nBullish + Bearish FVG overlap\nStrong S/R zone\nLast FVG: Bullish (watch for continuation up)")
                        array.push(bprBoxes, bprBox)
                        array.push(bprTops, overlapTop)
                        array.push(bprBottoms, overlapBot)
                        array.push(bprBirthBar, bar_index)
                        array.push(bprMitigated, false)
                        array.push(bprLastDir, 1)
                        bprMade := true
                        break
        if not bprMade and array.size(mitFvgDirs) > 0
            for i = array.size(mitFvgDirs) - 1 to 0
                if i < 0 or i >= array.size(mitFvgDirs)
                    continue
                if array.get(mitFvgDirs, i) != -1
                    continue
                existTop = array.get(mitFvgTops, i)
                existBot = array.get(mitFvgBottoms, i)
                overlapTop = math.min(existTop, newBullTop)
                overlapBot = math.max(existBot, newBullBot)
                if overlapTop - overlapBot >= effBprMin
                    bool dupB = false
                    if array.size(bprTops) > 0
                        for q = 0 to array.size(bprTops) - 1
                            if not array.get(bprMitigated, q) and math.min(array.get(bprTops, q), overlapTop) > math.max(array.get(bprBottoms, q), overlapBot)
                                dupB := true
                                break
                    if not dupB
                        bprBox = box.new(bar_index - 2, overlapTop, bar_index + 20, overlapBot, border_color=bprBorderColor, bgcolor=bprColor, border_width=2, border_style=line.style_solid)
                        label.new(bar_index - 1, overlapTop, "BPR", color=color.new(color.yellow, 80), textcolor=color.yellow, style=label.style_label_down, size=lblSize, tooltip="Balanced Price Range (swept)\nNew bullish FVG over a recently swept bearish FVG\nStrong S/R zone\nLast FVG: Bullish (watch for continuation up)")
                        array.push(bprBoxes, bprBox)
                        array.push(bprTops, overlapTop)
                        array.push(bprBottoms, overlapBot)
                        array.push(bprBirthBar, bar_index)
                        array.push(bprMitigated, false)
                        array.push(bprLastDir, 1)
                        // consume the matched memory entry so it cannot spawn more BPRs
                        array.remove(mitFvgTops, i)
                        array.remove(mitFvgBottoms, i)
                        array.remove(mitFvgDirs, i)
                        array.remove(mitFvgMitBar, i)
                        break

    // ── New BEARISH FVG: look for bullish overlap (live first, then memory) ──
    if newBearFVG
        bool bprMade = false
        if sz > 0
            for i = sz - 2 to 0
                if i < 0 or i >= array.size(fvgDirs)
                    continue
                if array.get(fvgMitigated, i)
                    continue
                if array.get(fvgDirs, i) != 1
                    continue
                if array.get(fvgBirthBar, i) == bar_index
                    continue
                existTop = array.get(fvgTops, i)
                existBot = array.get(fvgBottoms, i)
                overlapTop = math.min(existTop, newBearTop)
                overlapBot = math.max(existBot, newBearBot)
                if overlapTop - overlapBot >= effBprMin
                    bool dupC = false
                    if array.size(bprTops) > 0
                        for q = 0 to array.size(bprTops) - 1
                            if not array.get(bprMitigated, q) and math.min(array.get(bprTops, q), overlapTop) > math.max(array.get(bprBottoms, q), overlapBot)
                                dupC := true
                                break
                    if not dupC
                        bprBox = box.new(bar_index - 2, overlapTop, bar_index + 20, overlapBot, border_color=bprBorderColor, bgcolor=bprColor, border_width=2, border_style=line.style_solid)
                        label.new(bar_index - 1, overlapTop, "BPR", color=color.new(color.yellow, 80), textcolor=color.yellow, style=label.style_label_down, size=lblSize, tooltip="Balanced Price Range\nBullish + Bearish FVG overlap\nStrong S/R zone\nLast FVG: Bearish (watch for reversal down)")
                        array.push(bprBoxes, bprBox)
                        array.push(bprTops, overlapTop)
                        array.push(bprBottoms, overlapBot)
                        array.push(bprBirthBar, bar_index)
                        array.push(bprMitigated, false)
                        array.push(bprLastDir, -1)
                        bprMade := true
                        break
        if not bprMade and array.size(mitFvgDirs) > 0
            for i = array.size(mitFvgDirs) - 1 to 0
                if i < 0 or i >= array.size(mitFvgDirs)
                    continue
                if array.get(mitFvgDirs, i) != 1
                    continue
                existTop = array.get(mitFvgTops, i)
                existBot = array.get(mitFvgBottoms, i)
                overlapTop = math.min(existTop, newBearTop)
                overlapBot = math.max(existBot, newBearBot)
                if overlapTop - overlapBot >= effBprMin
                    bool dupD = false
                    if array.size(bprTops) > 0
                        for q = 0 to array.size(bprTops) - 1
                            if not array.get(bprMitigated, q) and math.min(array.get(bprTops, q), overlapTop) > math.max(array.get(bprBottoms, q), overlapBot)
                                dupD := true
                                break
                    if not dupD
                        bprBox = box.new(bar_index - 2, overlapTop, bar_index + 20, overlapBot, border_color=bprBorderColor, bgcolor=bprColor, border_width=2, border_style=line.style_solid)
                        label.new(bar_index - 1, overlapTop, "BPR", color=color.new(color.yellow, 80), textcolor=color.yellow, style=label.style_label_down, size=lblSize, tooltip="Balanced Price Range (swept)\nNew bearish FVG over a recently swept bullish FVG\nStrong S/R zone\nLast FVG: Bearish (watch for reversal down)")
                        array.push(bprBoxes, bprBox)
                        array.push(bprTops, overlapTop)
                        array.push(bprBottoms, overlapBot)
                        array.push(bprBirthBar, bar_index)
                        array.push(bprMitigated, false)
                        array.push(bprLastDir, -1)
                        array.remove(mitFvgTops, i)
                        array.remove(mitFvgBottoms, i)
                        array.remove(mitFvgDirs, i)
                        array.remove(mitFvgMitBar, i)
                        break


// ══════════════════════════════════════════════════════════════════
//  BPR MANAGEMENT
// ══════════════════════════════════════════════════════════════════

if showBPR and array.size(bprBoxes) > 0
    for i = array.size(bprBoxes) - 1 to 0
        if i >= array.size(bprBoxes)
            continue
        bTop   = array.get(bprTops, i)
        bBot   = array.get(bprBottoms, i)
        bBirth = array.get(bprBirthBar, i)
        bMit   = array.get(bprMitigated, i)
        bx     = array.get(bprBoxes, i)
        age    = bar_index - bBirth
        closedThrough = false
        lastDir = array.get(bprLastDir, i)
        if lastDir == -1
            closedThrough := close > bTop
        else
            closedThrough := close < bBot
        if closedThrough and not bMit and age > 2
            array.set(bprMitigated, i, true)
            if hideBPRMitigated
                box.delete(bx)
                array.remove(bprBoxes, i)
                array.remove(bprTops, i)
                array.remove(bprBottoms, i)
                array.remove(bprBirthBar, i)
                array.remove(bprMitigated, i)
                array.remove(bprLastDir, i)
                continue
            else
                box.set_bgcolor(bx, color.new(color.gray, 78))
                box.set_border_color(bx, color.new(color.gray, 40))
        if not bMit and age > 1
            priceInBPR = low <= bTop and high >= bBot
            if priceInBPR
                bprTestAlert := true
        if not bMit and age <= maxBPRAge
            box.set_right(bx, bar_index + 10)
        if age > maxBPRAge
            box.delete(bx)
            array.remove(bprBoxes, i)
            array.remove(bprTops, i)
            array.remove(bprBottoms, i)
            array.remove(bprBirthBar, i)
            array.remove(bprMitigated, i)
            array.remove(bprLastDir, i)


// ══════════════════════════════════════════════════════════════════
//  INFO TABLE (expanded for v2.0)
// ══════════════════════════════════════════════════════════════════

var table infoTable = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    asiaRangeVal = not na(asiaHigh) and not na(asiaLow) ? asiaHigh - asiaLow : 0.0
    biasStr = dailyBias == 1 ? "BULLISH ▲" : dailyBias == -1 ? "BEARISH ▼" : "NO SIGNAL"
    biasColor = dailyBias == 1 ? biasLongColor : dailyBias == -1 ? biasShortColor : color.gray

    htf4hStr = htf4hBull ? "BULL" : "BEAR"
    htf1dStr = htf1dBull ? "BULL" : "BEAR"
    htfStatusStr = "..."
    htfStatusCol = color.gray
    if biasTriggered
        htfStatusStr := htfAlignedAtBias ? "ALIGNED ✓" : "OPPOSED ✗"
        htfStatusCol := htfAlignedAtBias ? color.lime : color.red

    ablcStr = "WAITING"
    ablcCol = color.gray
    if not rangeGateOK and asiaComplete
        ablcStr := "RANGE GATE"
        ablcCol := color.orange
    else if biasTriggered and not htfAlignedAtBias
        ablcStr := "STAND DOWN"
        ablcCol := color.red
    else if ablcFired
        ablcStr := ablcDir == 1 ? "LONG FIRED" : "SHORT FIRED"
        ablcCol := ablcDir == 1 ? color.lime : color.red
    else if biasTriggered and htfAlignedAtBias and lonORComplete
        ablcStr := "ARMED"
        ablcCol := color.yellow

    unmitFVG = 0
    if array.size(fvgMitigated) > 0
        for i = 0 to array.size(fvgMitigated) - 1
            if not array.get(fvgMitigated, i)
                unmitFVG += 1
    unmitBPR = 0
    if array.size(bprMitigated) > 0
        for i = 0 to array.size(bprMitigated) - 1
            if not array.get(bprMitigated, i)
                unmitBPR += 1

    etTimeStr = str.tostring(etHour, "00") + ":" + str.tostring(etMin, "00") + " ET"

    table.cell(infoTable, 0, 0, "Asia High", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, not na(asiaHigh) ? str.tostring(asiaHigh, "#.##") : "...", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 1, "Asia Low", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, not na(asiaLow) ? str.tostring(asiaLow, "#.##") : "...", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 2, "Range", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, "$" + str.tostring(asiaRangeVal, "#.##") + (rangeGateOK ? "" : " ✗"), text_color=rangeGateOK ? color.white : color.orange, text_size=size.small)
    table.cell(infoTable, 0, 3, "Bias", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, biasStr, text_color=biasColor, text_size=size.small)
    table.cell(infoTable, 0, 4, "4H / 1D", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, htf4hStr + " / " + htf1dStr, text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 5, "HTF Filter", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 5, htfStatusStr, text_color=htfStatusCol, text_size=size.small)
    table.cell(infoTable, 0, 6, "ABLC", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 6, ablcStr, text_color=ablcCol, text_size=size.small)
    table.cell(infoTable, 0, 7, "ET Time", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 7, etTimeStr, text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 8, "Open FVGs", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 8, str.tostring(unmitFVG), text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 9, "Open BPRs", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 9, str.tostring(unmitBPR), text_color=unmitBPR > 0 ? color.yellow : color.white, text_size=size.small)


// ══════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════

alertcondition(alertOnBias and biasTriggered and biasBar == bar_index and dailyBias == 1, "Bullish Bias Triggered", "Candle close ABOVE Asia High ... BULLISH BIAS")
alertcondition(alertOnBias and biasTriggered and biasBar == bar_index and dailyBias == -1, "Bearish Bias Triggered", "Candle close BELOW Asia Low ... BEARISH BIAS")
alertcondition(alertOnABLC and ablcSignal and ablcDir == 1, "ABLC Long Entry", "ABLC LONG ... bias + London OR break + HTF aligned. Check dashboard for entry/SL/TP.")
alertcondition(alertOnABLC and ablcSignal and ablcDir == -1, "ABLC Short Entry", "ABLC SHORT ... bias + London OR break + HTF aligned. Check dashboard for entry/SL/TP.")
alertcondition(alertOnFVGTest and fvgTestAlert, "Price at Unmitigated FVG", "Price entering unmitigated FVG in bias direction")
alertcondition(alertOnBPR and bprTestAlert, "Price at BPR Zone", "Price entering Balanced Price Range ... strong S/R zone")


// ══════════════════════════════════════════════════════════════════
//  PLOT
// ══════════════════════════════════════════════════════════════════

plot(na, title="Hidden", display=display.none)
````
