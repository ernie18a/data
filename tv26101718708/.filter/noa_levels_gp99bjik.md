# NOA Levels

- url: https://www.tradingview.com/script/gP99bjik-NOA-Levels/
- type: indicator
- pine_id: PUB;a56e55429f354c06bb32fe34999e8ffc
- version: 1.0

## Description

https://www.tradingview.com/x/q3ODOCWB/

NOA Levels — Structural Levels, Volume Profiles & Gap Analytics

OVERVIEW
NOA Levels combines three institutional reference frameworks into a single
overlay: prior-period structural levels, volume-derived value zones, and a
statistical session-gap engine. It is built for traders who anchor decisions to
where price has previously transacted and how the current session opens relative
to that history.

Everything plots on intraday timeframes and reads off higher-timeframe data, so
the levels stay consistent regardless of the chart resolution you trade on.

WHAT IT PLOTS

1. Prior-Period Levels (Day / Week / Month)
   Previous high, low, and midpoint for each period, drawn as horizontal
   references that extend across the active period. High/low use dashed lines;
   midpoints use dotted lines to keep them visually subordinate. Compact labels
   (pdH/pdM/pdL, pwH/pwM/pwL, pmH/pmM/pmL) keep the chart readable.

2. Volume Profiles (Daily & Weekly)
   Point of Control (POC) plus Value Area High/Low for the prior day and prior
   week, computed from an intrabar volume distribution. Value Area % is
   adjustable (40% for a tight zone around the POC, ~70% for the standard Market
   Profile convention). Resolution controls the number of price rows used to
   build each profile.

3. Session Gap Engine
   On each new session, the open is measured against the prior close. Every gap
   is boxed and classified into one of six behavioural profiles based purely on
   where the session ultimately closes relative to the gap zone:
     • GapUp & Go / Hold / Reverse
     • GapDn & Go / Hold / Reverse
   The on-chart label shows the gap size and the developing profile in real time;
   the tooltip carries the full statistical breakdown.


GAP STATISTICS (the core differentiator)
Rather than judging gaps with arbitrary thresholds, NOA Levels builds a running
distribution from your own chart's history (lookback is adjustable). For each new
gap it reports:
   • Magnitude in % and price, normalized as a z-score (σ) and percentile rank
     against prior gaps — so a "big" gap is defined by this symbol's own behaviour
   • A Common vs. Breakaway tag (whether the open clears the prior day's range)
   • Historical Go / Hold / Reverse percentages, split by gap direction
   • Live fill tracking (whether the prior close has been retested)

Magnitude is normalized by absolute gap %, which is always available — so gaps
plot and compute statistics even on freshly listed symbols where ATR has not yet
warmed up. The ATR multiple is shown as an optional reference field once enough
daily history exists.


REPAINTING
Higher-timeframe levels use confirmed prior-period values (lookahead with a
one-bar offset), so historical levels do not repaint. The developing gap profile
and fill status update intrabar by design, as they describe the session in
progress; the profile is finalized and recorded into the distribution once the
session closes.


HOW TO USE
- Treat prior highs/lows and POC/Value Area as decision zones — areas where
  reaction is more likely, not automatic buy/sell signals.
- Use the gap percentile and σ to gauge whether an open is routine or unusual
  for this instrument before sizing or fading it.
- Read the Go/Hold/Reverse distribution as context for the current gap's most
  common historical resolution — it is descriptive, not predictive.
- Midpoints often act as intraday pivots; the gap mid frequently marks the
  fill objective.


SETTINGS
Inputs are grouped by period (Day / Week / Month) and function (Levels / Volume /
Gaps), with colors, line widths, label toggles, Value Area %, profile resolution,
gap lookback, and ATR length all configurable. Session and week separators are
optional.

ALERTS
New Session, New Week, New Month, and Session Gap Detected.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nord-ouestadvisors

//@version=6
// ============================================================================
// Title:       NOA Levels
// Description: Structural levels, volume profiles, and gap analytics
// Author:      Nord-Ouest Advisors
// Version:     3.5
// Created:     2026-05-28
// Updated:     2026-06-18
// ----------------------------------------------------------------------------
// v3.5 — Gap engine now plots from the first valid session and runs statistics
//        on a running lookback regardless of available history. Magnitude is
//        normalized by absolute gap % (always available); ATR multiple is shown
//        as an optional field once the daily ATR has warmed up. Fixes missing
//        gaps on freshly listed symbols (recent IPOs, e.g. SPCX).
// ============================================================================
indicator("NOA Levels", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ============================================================================
// Inputs
// ============================================================================

// --- Separators ---
string GRP_SEP = "Separators"
bool   showSessBreaks = input.bool(true, "Session Breaks", group = GRP_SEP, inline = "sb", tooltip = "Vertical line at each new trading day")
color  sessBreakCol   = input.color(color.new(color.gray, 50), "", group = GRP_SEP, inline = "sb")
int    sessBreakWidth = input.int(1, "", minval = 1, maxval = 4, group = GRP_SEP, inline = "sb")
bool   showWeekBreaks = input.bool(true, "Week Breaks", group = GRP_SEP, inline = "wb", tooltip = "Vertical line at each new trading week")
color  weekBreakCol   = input.color(color.orange, "", group = GRP_SEP, inline = "wb")
int    weekBreakWidth = input.int(2, "", minval = 1, maxval = 4, group = GRP_SEP, inline = "wb")

// --- Previous Day — Levels ---
string GRP_PDL = "Previous Day — Levels"
bool   showPDHL     = input.bool(true, "Show H/L", group = GRP_PDL, inline = "pdhl")
color  pdhColor     = input.color(#2196F3, "H", group = GRP_PDL, inline = "pdhl")
color  pdlColor     = input.color(#1565C0, "L", group = GRP_PDL, inline = "pdhl")
bool   showPDMid    = input.bool(true, "Show Mid", group = GRP_PDL, inline = "pdm", tooltip = "Midpoint between prior day's high and low")
color  pdmColor     = input.color(color.new(#2196F3, 20), "", group = GRP_PDL, inline = "pdm")
int    pdLineWidth  = input.int(1, "Width", minval = 1, maxval = 4, group = GRP_PDL, inline = "pdw")
bool   showPDLabels = input.bool(true, "Labels", group = GRP_PDL, inline = "pdw")

// --- Previous Day — Volume Profile ---
string GRP_PDV = "Previous Day — Volume"
bool   showPDVP  = input.bool(true, "Show PD Volume Profile", group = GRP_PDV, tooltip = "POC and Value Area from prior day's volume distribution")
color  pdPocCol  = input.color(#8e0038, "POC", group = GRP_PDV, inline = "pdvc")
color  pdVahCol  = input.color(color.new(#26a69a, 40), "VAH", group = GRP_PDV, inline = "pdvc")
color  pdValCol  = input.color(color.new(#26a69a, 40), "VAL", group = GRP_PDV, inline = "pdvc")

// --- Previous Week — Levels ---
string GRP_PWL = "Previous Week — Levels"
bool   showPWHL     = input.bool(true, "Show H/L", group = GRP_PWL, inline = "pwhl")
color  pwhColor     = input.color(#AB47BC, "H", group = GRP_PWL, inline = "pwhl")
color  pwlColor     = input.color(#7B1FA2, "L", group = GRP_PWL, inline = "pwhl")
bool   showPWMid    = input.bool(true, "Show Mid", group = GRP_PWL, inline = "pwm", tooltip = "Midpoint between prior week's high and low")
color  pwmColor     = input.color(color.new(#AB47BC, 20), "", group = GRP_PWL, inline = "pwm")
int    pwLineWidth  = input.int(1, "Width", minval = 1, maxval = 4, group = GRP_PWL, inline = "pww")
bool   showPWLabels = input.bool(true, "Labels", group = GRP_PWL, inline = "pww")

// --- Previous Week — Volume Profile ---
string GRP_PWV = "Previous Week — Volume"
bool   showPWVP  = input.bool(true, "Show PW Volume Profile", group = GRP_PWV, tooltip = "POC and Value Area from prior week's volume distribution")
color  pwPocCol  = input.color(#6A1B9A, "POC", group = GRP_PWV, inline = "pwvc")
color  pwVahCol  = input.color(color.new(#AB47BC, 40), "VAH", group = GRP_PWV, inline = "pwvc")
color  pwValCol  = input.color(color.new(#AB47BC, 40), "VAL", group = GRP_PWV, inline = "pwvc")

// --- Volume Profile Settings (shared) ---
string GRP_VP = "Volume Profile Settings"
float  vaPercent    = input.float(40.0, "Value Area %", minval = 10.0, maxval = 90.0, step = 5.0, group = GRP_VP, tooltip = "% of total volume defining the value area.\n40% = tight zone around POC\n70% = standard Market Profile convention")
int    profileRows  = input.int(50, "Resolution", minval = 20, maxval = 200, group = GRP_VP, tooltip = "Price rows per ATR. Higher = finer POC, slower computation")
int    vpLineWidth  = input.int(1, "Width", minval = 1, maxval = 4, group = GRP_VP, inline = "vpw")
bool   showVPLabels = input.bool(true, "Labels", group = GRP_VP, inline = "vpw")

// --- Previous Month — Levels ---
string GRP_PML = "Previous Month — Levels"
bool   showPMHL     = input.bool(true, "Show H/L", group = GRP_PML, inline = "pmhl")
color  pmhColor     = input.color(#26A69A, "H", group = GRP_PML, inline = "pmhl")
color  pmlColor     = input.color(#00796B, "L", group = GRP_PML, inline = "pmhl")
bool   showPMMid    = input.bool(true, "Show Mid", group = GRP_PML, inline = "pmm", tooltip = "Midpoint between prior month's high and low")
color  pmmColor     = input.color(color.new(#26A69A, 20), "", group = GRP_PML, inline = "pmm")
int    pmLineWidth  = input.int(2, "Width", minval = 1, maxval = 4, group = GRP_PML, inline = "pmw")
bool   showPMLabels = input.bool(true, "Labels", group = GRP_PML, inline = "pmw")

// --- Session Gaps ---
string GRP_GAP = "Session Gaps"
bool   showGaps     = input.bool(true, "Show Gaps", group = GRP_GAP, inline = "gp", tooltip = "Box between prior close and current open")
bool   showGapMid   = input.bool(true, "Mid Level", group = GRP_GAP, inline = "gp")
color  gapUpFill    = input.color(color.new(color.green, 85), "Up Fill", group = GRP_GAP, inline = "gu")
color  gapUpBord    = input.color(color.green, "Border", group = GRP_GAP, inline = "gu")
color  gapDnFill    = input.color(color.new(color.red, 85), "Down Fill", group = GRP_GAP, inline = "gd")
color  gapDnBord    = input.color(color.red, "Border", group = GRP_GAP, inline = "gd")
color  gapMidCol    = input.color(color.new(color.gray, 30), "Mid Color", group = GRP_GAP)
bool   showGapStats = input.bool(true, "Show Statistics", group = GRP_GAP, tooltip = "Label on each gap — hover for profile distribution")
int    statLookback = input.int(50, "Lookback (gaps)", minval = 5, maxval = 200, group = GRP_GAP, tooltip = "Max gaps retained for the running distribution. Stats adapt to whatever history exists — fewer gaps simply mean a smaller sample.")
int    atrLength    = input.int(14, "ATR Length", minval = 1, maxval = 50, group = GRP_GAP, tooltip = "Daily ATR period. Used only for the optional '× ATR' magnitude field; gaps plot and compute stats without it.")

// ============================================================================
// Session / Week / Month Detection
// ============================================================================
int  _dailyChange   = ta.change(time("D"))
int  _weeklyChange  = ta.change(time("W"))
int  _monthlyChange = ta.change(time("M"))
bool isNewSession   = timeframe.isintraday and _dailyChange   != 0
bool isNewWeek      = timeframe.isintraday and _weeklyChange  != 0
bool isNewMonth     = timeframe.isintraday and _monthlyChange != 0

// Warmup counters: skip the first detection of each period to avoid
// drawing artifacts from incomplete data at chart load
var int sessCount  = 0
var int weekCount  = 0
var int monthCount = 0
if isNewSession
    sessCount += 1
if isNewWeek
    weekCount += 1
if isNewMonth
    monthCount += 1

// ============================================================================
// Higher-Timeframe Data
// ============================================================================
[pdHigh, pdLow, dailyAtr] = request.security(syminfo.tickerid, "D", [high[1], low[1], ta.atr(atrLength)[1]], lookahead = barmerge.lookahead_on)
[pwHigh, pwLow]           = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmHigh, pmLow]           = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

float pdMid = not na(pdHigh) and not na(pdLow) ? math.avg(pdHigh, pdLow) : na
float pwMid = not na(pwHigh) and not na(pwLow) ? math.avg(pwHigh, pwLow) : na
float pmMid = not na(pmHigh) and not na(pmLow) ? math.avg(pmHigh, pmLow) : na

// ============================================================================
// Helper Functions
// ============================================================================

computeVP(map<int, float> m, float rs, float vaPct, int maxIter) =>
    float _poc = na, float _vah = na, float _val = na
    if m.size() > 0
        array<int> keys = m.keys()
        int   nK = array.size(keys)
        float maxV = 0.0, int pocR = 0, float totV = 0.0
        for i = 0 to nK - 1
            int   k = array.get(keys, i)
            float v = m.get(k)
            totV += v
            if v > maxV
                maxV := v
                pocR := k
        float tgtV = totV * vaPct / 100.0
        float cumV = maxV
        int vaH = pocR, int vaL = pocR
        int minR = array.min(keys), int maxR = array.max(keys)
        for _it = 0 to maxIter
            if cumV >= tgtV or (vaH >= maxR and vaL <= minR)
                break
            float uV = vaH < maxR ? nz(m.get(vaH + 1), 0.0) : 0.0
            float dV = vaL > minR ? nz(m.get(vaL - 1), 0.0) : 0.0
            if uV >= dV and vaH < maxR
                vaH += 1
                cumV += uV
            else if vaL > minR
                vaL -= 1
                cumV += dV
            else
                vaH += 1
                cumV += uV
        _poc := (pocR + 0.5) * rs
        _vah := (vaH + 1.0) * rs
        _val := vaL * rs
    [_poc, _vah, _val]

accumVP(map<int, float> m, float rs, int maxRows) =>
    if not na(rs) and rs > 0 and not na(volume) and volume > 0
        int lo = math.floor(low / rs)
        int hi = math.min(math.floor(high / rs), lo + maxRows - 1)
        int n  = math.max(hi - lo + 1, 1)
        float vpr = volume / n
        for row = lo to hi
            float ex = m.contains(row) ? m.get(row) : 0.0
            m.put(row, ex + vpr)

getProfile(int dir, float sCl, float gOp, float pCl) =>
    if dir == 1
        sCl >= gOp ? 1 : sCl >= pCl ? 2 : 3
    else
        sCl <= gOp ? 4 : sCl <= pCl ? 5 : 6

profShort(int p) =>
    switch p
        1 => "Go"
        2 => "Hold"
        3 => "Rev"
        4 => "Go"
        5 => "Hold"
        6 => "Rev"
        => "—"

profFull(int p) =>
    switch p
        1 => "GapUp & Go"
        2 => "GapUp & Hold"
        3 => "GapUp & Reverse"
        4 => "GapDn & Go"
        5 => "GapDn & Hold"
        6 => "GapDn & Reverse"
        => "N/A"

calcPercentile(array<float> arr, float val) =>
    float absVal = math.abs(val)
    int n = array.size(arr), int below = 0
    if n > 0
        for i = 0 to n - 1
            if array.get(arr, i) <= absVal
                below += 1
    n > 0 ? below / n * 100.0 : 50.0

ordSuffix(int v) =>
    int a = math.abs(v)
    a % 10 == 1 and a != 11 ? "st" : a % 10 == 2 and a != 12 ? "nd" : a % 10 == 3 and a != 13 ? "rd" : "th"

pctColor(float pct) =>
    pct >= 90 ? #FF1744 : pct >= 75 ? #FF6D00 : pct >= 50 ? color.yellow : color.new(color.gray, 20)

// ============================================================================
// Drawing State
// ============================================================================
var line  pdhLine = na, var line  pdlLine = na, var line  pdmLine = na
var label pdhLbl  = na, var label pdlLbl  = na, var label pdmLbl  = na
var line  pdPocLn = na, var line  pdVahLn = na, var line  pdValLn = na
var label pdPocLb = na, var label pdVahLb = na, var label pdValLb = na
var line  pwhLine = na, var line  pwlLine = na, var line  pwmLine = na
var label pwhLbl  = na, var label pwlLbl  = na, var label pwmLbl  = na
var line  pwPocLn = na, var line  pwVahLn = na, var line  pwValLn = na
var label pwPocLb = na, var label pwVahLb = na, var label pwValLb = na
var line  pmhLine = na, var line  pmlLine = na, var line  pmmLine = na
var label pmhLbl  = na, var label pmlLbl  = na, var label pmmLbl  = na
var box   gapBox     = na
var line  gapMidLine = na, var label gapMidLbl = na
var label gapStatLbl = na

// ============================================================================
// Volume Profile Engine
// ============================================================================
var map<int, float> vpMapD     = map.new<int, float>()
var float           vpRowSizeD = na
var map<int, float> vpMapW     = map.new<int, float>()
var float           vpRowSizeW = na

// ============================================================================
// Gap Statistics Engine
// ----------------------------------------------------------------------------
// Magnitude is normalized by ABSOLUTE GAP % (always available, even on a
// brand-new listing). The daily ATR multiple is an optional display field that
// appears only once ta.atr() has warmed up. The running lookback adapts to
// whatever history exists — a 3-day-old IPO simply has a smaller sample.
// ============================================================================
var array<float> histAbsPct = array.new<float>()   // running |gap %| history
var array<int>   histProf   = array.new<int>()
var bool  hasPending  = false
var float pendAbsPct  = na
var float pendSignPct = na
var int   pendDir     = 0
var float pendGapOpen = na
var float pendPriorCl = na
var float sessHi      = na
var float sessLo      = na
var int   curDir      = 0
var float curGapOpen  = na
var float curPriorCl  = na
var float curGapPct   = na
var float curAbsPct   = na
var float curAtrMult  = na
var float curPctRank  = 50.0
var bool  fillTracked = false
var int   prevDevProf = 0
var string cachedBaseTip = ""
var int cUpGo    = 0
var int cUpHold  = 0
var int cUpRev   = 0
var int cUpTotal = 0
var int cDnGo    = 0
var int cDnHold  = 0
var int cDnRev   = 0
var int cDnTotal = 0

// ============================================================================
// 1. Separators
// ============================================================================
if showSessBreaks and isNewSession and sessCount > 1
    line.new(bar_index, close, bar_index, close + syminfo.mintick, color = sessBreakCol, style = line.style_dotted, width = sessBreakWidth, extend = extend.both)
if showWeekBreaks and isNewWeek and weekCount > 1
    line.new(bar_index, close, bar_index, close + syminfo.mintick, color = weekBreakCol, style = line.style_dashed, width = weekBreakWidth, extend = extend.both)

// ============================================================================
// 2. Previous Day — Levels (pdH / pdM / pdL)
// ============================================================================
if showPDHL and isNewSession and sessCount > 1 and not na(pdHigh)
    pdhLine := line.new(bar_index, pdHigh, bar_index, pdHigh, color = pdhColor, style = line.style_dashed, width = pdLineWidth)
    pdlLine := line.new(bar_index, pdLow,  bar_index, pdLow,  color = pdlColor, style = line.style_dashed, width = pdLineWidth)
    if showPDMid and not na(pdMid)
        pdmLine := line.new(bar_index, pdMid, bar_index, pdMid, color = pdmColor, style = line.style_dotted, width = pdLineWidth)
    if showPDLabels
        pdhLbl := label.new(bar_index, pdHigh, "pdH", style = label.style_none, textcolor = pdhColor, size = size.small)
        pdlLbl := label.new(bar_index, pdLow,  "pdL", style = label.style_none, textcolor = pdlColor, size = size.small)
        if showPDMid and not na(pdMid)
            pdmLbl := label.new(bar_index, pdMid, "pdM", style = label.style_none, textcolor = pdmColor, size = size.small)
if showPDHL and not na(pdhLine)
    line.set_x2(pdhLine, bar_index)
    line.set_x2(pdlLine, bar_index)
    if showPDMid and not na(pdmLine)
        line.set_x2(pdmLine, bar_index)
    if showPDLabels and not na(pdhLbl)
        label.set_x(pdhLbl, bar_index)
        label.set_x(pdlLbl, bar_index)
        if showPDMid and not na(pdmLbl)
            label.set_x(pdmLbl, bar_index)

// ============================================================================
// 3. Previous Day — Volume Profile (pdPOC / pdVAH / pdVAL)
// ============================================================================
if isNewSession and showPDVP and sessCount > 1
    if vpMapD.size() > 0
        [dPoc, dVah, dVal] = computeVP(vpMapD, nz(vpRowSizeD, syminfo.mintick), vaPercent, profileRows)
        if not na(dPoc)
            pdPocLn := line.new(bar_index, dPoc, bar_index, dPoc, color = pdPocCol, style = line.style_solid, width = vpLineWidth)
            pdVahLn := line.new(bar_index, dVah, bar_index, dVah, color = pdVahCol, style = line.style_dotted, width = vpLineWidth)
            pdValLn := line.new(bar_index, dVal, bar_index, dVal, color = pdValCol, style = line.style_dotted, width = vpLineWidth)
            if showVPLabels
                pdPocLb := label.new(bar_index, dPoc, "pdPOC", style = label.style_none, textcolor = pdPocCol, size = size.small)
                pdVahLb := label.new(bar_index, dVah, "pdVAH", style = label.style_none, textcolor = pdVahCol, size = size.small)
                pdValLb := label.new(bar_index, dVal, "pdVAL", style = label.style_none, textcolor = pdValCol, size = size.small)
    vpMapD.clear()
    vpRowSizeD := not na(dailyAtr) and dailyAtr > 0 ? math.max(dailyAtr / profileRows, syminfo.mintick) : syminfo.mintick * 10

if showPDVP and not na(pdPocLn)
    line.set_x2(pdPocLn, bar_index)
    line.set_x2(pdVahLn, bar_index)
    line.set_x2(pdValLn, bar_index)
    if showVPLabels and not na(pdPocLb)
        label.set_x(pdPocLb, bar_index)
        label.set_x(pdVahLb, bar_index)
        label.set_x(pdValLb, bar_index)

// ============================================================================
// 4. Previous Week — Levels (pwH / pwM / pwL)
// ============================================================================
if showPWHL and isNewWeek and weekCount > 1 and not na(pwHigh)
    pwhLine := line.new(bar_index, pwHigh, bar_index, pwHigh, color = pwhColor, style = line.style_dashed, width = pwLineWidth)
    pwlLine := line.new(bar_index, pwLow,  bar_index, pwLow,  color = pwlColor, style = line.style_dashed, width = pwLineWidth)
    if showPWMid and not na(pwMid)
        pwmLine := line.new(bar_index, pwMid, bar_index, pwMid, color = pwmColor, style = line.style_dotted, width = pwLineWidth)
    if showPWLabels
        pwhLbl := label.new(bar_index, pwHigh, "pwH", style = label.style_none, textcolor = pwhColor, size = size.small)
        pwlLbl := label.new(bar_index, pwLow,  "pwL", style = label.style_none, textcolor = pwlColor, size = size.small)
        if showPWMid and not na(pwMid)
            pwmLbl := label.new(bar_index, pwMid, "pwM", style = label.style_none, textcolor = pwmColor, size = size.small)
if showPWHL and not na(pwhLine)
    line.set_x2(pwhLine, bar_index)
    line.set_x2(pwlLine, bar_index)
    if showPWMid and not na(pwmLine)
        line.set_x2(pwmLine, bar_index)
    if showPWLabels and not na(pwhLbl)
        label.set_x(pwhLbl, bar_index)
        label.set_x(pwlLbl, bar_index)
        if showPWMid and not na(pwmLbl)
            label.set_x(pwmLbl, bar_index)

// ============================================================================
// 5. Previous Week — Volume Profile (pwPOC / pwVAH / pwVAL)
// ============================================================================
if isNewWeek and showPWVP and weekCount > 1
    if vpMapW.size() > 0
        [wPoc, wVah, wVal] = computeVP(vpMapW, nz(vpRowSizeW, syminfo.mintick), vaPercent, profileRows)
        if not na(wPoc)
            pwPocLn := line.new(bar_index, wPoc, bar_index, wPoc, color = pwPocCol, style = line.style_solid, width = vpLineWidth)
            pwVahLn := line.new(bar_index, wVah, bar_index, wVah, color = pwVahCol, style = line.style_dotted, width = vpLineWidth)
            pwValLn := line.new(bar_index, wVal, bar_index, wVal, color = pwValCol, style = line.style_dotted, width = vpLineWidth)
            if showVPLabels
                pwPocLb := label.new(bar_index, wPoc, "pwPOC", style = label.style_none, textcolor = pwPocCol, size = size.small)
                pwVahLb := label.new(bar_index, wVah, "pwVAH", style = label.style_none, textcolor = pwVahCol, size = size.small)
                pwValLb := label.new(bar_index, wVal, "pwVAL", style = label.style_none, textcolor = pwValCol, size = size.small)
    vpMapW.clear()
    vpRowSizeW := not na(dailyAtr) and dailyAtr > 0 ? math.max(dailyAtr / profileRows, syminfo.mintick) : syminfo.mintick * 10

if showPWVP and not na(pwPocLn)
    line.set_x2(pwPocLn, bar_index)
    line.set_x2(pwVahLn, bar_index)
    line.set_x2(pwValLn, bar_index)
    if showVPLabels and not na(pwPocLb)
        label.set_x(pwPocLb, bar_index)
        label.set_x(pwVahLb, bar_index)
        label.set_x(pwValLb, bar_index)

// ============================================================================
// 6. Volume Accumulation (every bar — feeds daily and weekly maps)
// ============================================================================
if showPDVP
    accumVP(vpMapD, vpRowSizeD, profileRows)
if showPWVP
    accumVP(vpMapW, vpRowSizeW, profileRows)

// ============================================================================
// 7. Previous Month — Levels (pmH / pmM / pmL)
// ============================================================================
if showPMHL and isNewMonth and monthCount > 1 and not na(pmHigh)
    pmhLine := line.new(bar_index, pmHigh, bar_index, pmHigh, color = pmhColor, style = line.style_dashed, width = pmLineWidth)
    pmlLine := line.new(bar_index, pmLow,  bar_index, pmLow,  color = pmlColor, style = line.style_dashed, width = pmLineWidth)
    if showPMMid and not na(pmMid)
        pmmLine := line.new(bar_index, pmMid, bar_index, pmMid, color = pmmColor, style = line.style_dotted, width = pmLineWidth)
    if showPMLabels
        pmhLbl := label.new(bar_index, pmHigh, "pmH", style = label.style_none, textcolor = pmhColor, size = size.small)
        pmlLbl := label.new(bar_index, pmLow,  "pmL", style = label.style_none, textcolor = pmlColor, size = size.small)
        if showPMMid and not na(pmMid)
            pmmLbl := label.new(bar_index, pmMid, "pmM", style = label.style_none, textcolor = pmmColor, size = size.small)
if showPMHL and not na(pmhLine)
    line.set_x2(pmhLine, bar_index)
    line.set_x2(pmlLine, bar_index)
    if showPMMid and not na(pmmLine)
        line.set_x2(pmmLine, bar_index)
    if showPMLabels and not na(pmhLbl)
        label.set_x(pmhLbl, bar_index)
        label.set_x(pmlLbl, bar_index)
        if showPMMid and not na(pmmLbl)
            label.set_x(pmmLbl, bar_index)

// ============================================================================
// 8. Session Gaps + Profiles + Statistics
// ============================================================================

// Fill tracking
if not isNewSession and curDir != 0 and not fillTracked
    if curDir == 1 and low <= curPriorCl
        fillTracked := true
    if curDir == -1 and high >= curPriorCl
        fillTracked := true

if isNewSession
    if hasPending
        float prevCl = close[1]
        int   prof   = getProfile(pendDir, prevCl, pendGapOpen, pendPriorCl)
        array.push(histAbsPct, pendAbsPct)
        array.push(histProf, prof)
        if array.size(histAbsPct) > statLookback
            array.shift(histAbsPct)
            array.shift(histProf)
        if showGapStats and not na(gapStatLbl)
            string fSign = pendSignPct >= 0 ? "+" : ""
            string fTip  = cachedBaseTip
            fTip += "\n\n✦ Final: " + profFull(prof)
            fTip += "\nSession:  " + (fillTracked ? "✅ Filled" : "⬜ Not filled")
            fTip += "\n═══════════════════════════"
            label.set_tooltip(gapStatLbl, fTip)
            label.set_text(gapStatLbl, fSign + str.tostring(pendSignPct, "#.##") + "% · " + profShort(prof))
        hasPending := false

    sessHi      := high
    sessLo      := low
    fillTracked := false
    prevDevProf := 0
    gapStatLbl  := na

    int   histN   = array.size(histAbsPct)
    float meanPct = histN >= 2 ? array.avg(histAbsPct)   : 0.0
    float stdPct  = histN >= 2 ? array.stdev(histAbsPct) : 0.0

    int _uG = 0
    int _uH = 0
    int _uR = 0
    int _uT = 0
    int _dG = 0
    int _dH = 0
    int _dR = 0
    int _dT = 0
    int profN = array.size(histProf)
    if profN > 0
        for i = 0 to profN - 1
            switch array.get(histProf, i)
                1 => _uG += 1
                2 => _uH += 1
                3 => _uR += 1
                4 => _dG += 1
                5 => _dH += 1
                6 => _dR += 1
        _uT := _uG + _uH + _uR
        _dT := _dG + _dH + _dR
    cUpGo    := _uG
    cUpHold  := _uH
    cUpRev   := _uR
    cUpTotal := _uT
    cDnGo    := _dG
    cDnHold  := _dH
    cDnRev   := _dR
    cDnTotal := _dT

    curDir     := 0
    curGapOpen := na
    curPriorCl := na
    curGapPct  := na
    curAbsPct  := na
    curAtrMult := na
    curPctRank := 50.0
    gapBox     := na
    gapMidLine := na
    gapMidLbl  := na

    // Plot from the FIRST valid session (sessCount >= 1). ATR is NOT required —
    // the gap box, mid and % label depend only on prior close and current open.
    if showGaps and sessCount >= 1 and not na(close[1])
        float priorClose = close[1]
        float currentOpen = open
        bool  isUpGap = currentOpen > priorClose
        bool  isDnGap = currentOpen < priorClose

        if isUpGap or isDnGap
            float gapPrice = currentOpen - priorClose
            float gapPct   = gapPrice / priorClose * 100.0
            float absPct   = math.abs(gapPct)
            float atrMult  = not na(dailyAtr) and dailyAtr > 0 ? math.abs(gapPrice) / dailyAtr : na
            float gapMid   = math.avg(currentOpen, priorClose)
            float gapTop   = math.max(currentOpen, priorClose)
            float gapBot   = math.min(currentOpen, priorClose)
            int   dir      = isUpGap ? 1 : -1
            bool  isBrk    = (dir == 1 and not na(pdHigh) and currentOpen > pdHigh) or (dir == -1 and not na(pdLow) and currentOpen < pdLow)
            float zScore   = histN >= 2 and stdPct > 0 ? (absPct - meanPct) / stdPct : 0.0
            float pctRank  = calcPercentile(histAbsPct, absPct)

            curDir     := dir
            curGapOpen := currentOpen
            curPriorCl := priorClose
            curGapPct  := gapPct
            curAbsPct  := absPct
            curAtrMult := atrMult
            curPctRank := pctRank

            hasPending  := true
            pendAbsPct  := absPct
            pendSignPct := gapPct
            pendDir     := dir
            pendGapOpen := currentOpen
            pendPriorCl := priorClose

            color boxFill = isUpGap ? gapUpFill : gapDnFill
            color boxBord = isUpGap ? gapUpBord : gapDnBord
            gapBox := box.new(bar_index - 1, gapTop, bar_index, gapBot, border_color = boxBord, bgcolor = boxFill)
            if showGapMid
                gapMidLine := line.new(bar_index - 1, gapMid, bar_index, gapMid, color = gapMidCol, style = line.style_dotted)
                gapMidLbl  := label.new(bar_index, gapMid, "mid", style = label.style_none, textcolor = gapMidCol, size = size.tiny)

            if showGapStats
                int    pctI  = math.round(pctRank)
                string tier  = math.abs(zScore) >= 2.0 ? "▸ Significant" : math.abs(zScore) >= 1.0 ? "▸ Notable" : "▸ Normal"
                string typeS = isBrk ? "Breakaway" : "Common"
                string signS = gapPct >= 0 ? "+" : ""
                string atrS  = not na(atrMult) ? str.tostring(atrMult, "#.##") + "× ATR | " : ""

                string t = "══ Gap Stats (" + str.tostring(histN) + " gaps) ══\n\n"
                t += signS + str.tostring(gapPrice, format.mintick) + " (" + signS + str.tostring(gapPct, "#.##") + "%)  " + typeS + "\n"
                if histN >= 2
                    t += atrS + str.tostring(math.abs(zScore), "#.##") + "σ " + tier + " | " + str.tostring(pctI) + ordSuffix(pctI) + " pctl"
                else
                    t += atrS + "baseline building (" + str.tostring(histN) + " prior gap" + (histN == 1 ? "" : "s") + ")"

                if profN >= 2
                    t += "\n\nUp (" + str.tostring(_uT) + "):  "
                    t += "Go " + str.tostring(_uT > 0 ? math.round(_uG / _uT * 100.0) : 0) + "%"
                    t += " · Hold " + str.tostring(_uT > 0 ? math.round(_uH / _uT * 100.0) : 0) + "%"
                    t += " · Rev " + str.tostring(_uT > 0 ? math.round(_uR / _uT * 100.0) : 0) + "%"
                    t += "\nDn (" + str.tostring(_dT) + "):  "
                    t += "Go " + str.tostring(_dT > 0 ? math.round(_dG / _dT * 100.0) : 0) + "%"
                    t += " · Hold " + str.tostring(_dT > 0 ? math.round(_dH / _dT * 100.0) : 0) + "%"
                    t += " · Rev " + str.tostring(_dT > 0 ? math.round(_dR / _dT * 100.0) : 0) + "%"
                else
                    t += "\n\nProfiles: collecting data..."

                cachedBaseTip := t
                gapStatLbl := label.new(bar_index, gapTop, signS + str.tostring(gapPct, "#.##") + "%",
                  style = label.style_none, textcolor = pctColor(pctRank), size = size.small, tooltip = t)

// Session tracking
if not isNewSession
    sessHi := math.max(nz(sessHi, high), high)
    sessLo := math.min(nz(sessLo, low),  low)

// Extend gap drawings
if showGaps and not isNewSession and not na(gapBox)
    box.set_right(gapBox, bar_index)
    if showGapMid and not na(gapMidLine)
        line.set_x2(gapMidLine, bar_index)
    if showGapMid and not na(gapMidLbl)
        label.set_x(gapMidLbl, bar_index)

// Developing profile + live label
if showGapStats and curDir != 0 and not na(gapStatLbl)
    int devProf  = getProfile(curDir, close, curGapOpen, curPriorCl)
    string signS = curGapPct >= 0 ? "+" : ""
    label.set_text(gapStatLbl, signS + str.tostring(curGapPct, "#.##") + "% · " + profShort(devProf))
    label.set_textcolor(gapStatLbl, pctColor(curPctRank))
    label.set_x(gapStatLbl, bar_index)

    bool profChanged = devProf != prevDevProf
    bool fillNow     = fillTracked and (not fillTracked[1] or profChanged)
    if profChanged or fillNow or barstate.islast
        prevDevProf := devProf
        int   dirTotal = curDir == 1 ? cUpTotal : cDnTotal
        int   goCount  = curDir == 1 ? cUpGo : cDnGo
        int   hdCount  = curDir == 1 ? cUpHold : cDnHold
        int   rvCount  = curDir == 1 ? cUpRev : cDnRev
        string dirWord = curDir == 1 ? "up" : "down"

        string dev = "\n\n⮕ " + profFull(devProf)
        if dirTotal >= 2
            int devCount = devProf <= 3 ? (devProf == 1 ? goCount : devProf == 2 ? hdCount : rvCount) : (devProf == 4 ? goCount : devProf == 5 ? hdCount : rvCount)
            float devPct = dirTotal > 0 ? devCount / dirTotal * 100.0 : 0.0
            dev += "\n  ↳ " + str.tostring(math.round(devPct)) + "% of " + dirWord + " gaps historically"

        string fillS   = "\n\nSession:  " + (fillTracked ? "✅ Filled" : "⬜ Not yet filled")
        label.set_tooltip(gapStatLbl, cachedBaseTip + dev + fillS + "\n═══════════════════════════")

// ============================================================================
// Alerts
// ============================================================================
bool gapDetected = isNewSession and not na(close[1]) and open != close[1]
alertcondition(isNewSession,  "New Session",          "{{ticker}} — New session on {{interval}}")
alertcondition(isNewWeek,     "New Week",             "{{ticker}} — New week on {{interval}}")
alertcondition(isNewMonth,    "New Month",            "{{ticker}} — New month on {{interval}}")
alertcondition(gapDetected,   "Session Gap Detected", "{{ticker}} — Session gap on {{interval}}: Open={{open}}")
````
