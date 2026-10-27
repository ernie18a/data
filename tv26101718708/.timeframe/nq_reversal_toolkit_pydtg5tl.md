# NQ Reversal Toolkit

- url: https://www.tradingview.com/script/PyDTg5tL-NQ-Reversal-Toolkit/
- type: indicator
- pine_id: PUB;715a5602d5de47169937708a047703ab
- version: 1.0

## Description

This toolkit operates via three specialized internal modules, culminating in a real-time HUD (Heads-Up Display) overlay.

1. Session-Based Fib Pivots (MotiveWave-Style)
Unlike standard daily pivot calculations, this script isolates explicit trading sessions (Asia, London, New York) and computes Fibonacci ranges derived strictly from the prior completed sequence of that exact session.
Execution Value: Rather than relying on generic daily targets, this charts key institutional intraday micro-structures. You can track when NY is breaking or rejecting lines calculated from yesterday's NY session.Hourly Flex: Includes a secondary toggle to project dynamic 1-Hour rolling Fib Pivots directly across your chart workspace.2. High-Timeframe (HTF) Rejection BlocksThis module actively monitors higher timeframes (defaults to the 60-minute chart) to scan for institutional order flow rejections. It identifies candles displaying massive wick-to-body expansion ratios coupled with an ATR threshold validation.Bullish Rejection Block: Drawn when a massive lower wick indicates aggressive buy-side absorption at key support.Bearish Rejection Block: Drawn when a massive upper wick reveals institutional selling pressure at structural resistance.Auto-Mitigation: To keep charts clean and relevant, zones automatically delete the exact millisecond price breaks through the invalidation floor/ceiling of the block.3. Session Volume Profile (VP)Volume profiles calculate the volume distribution across price ranges over distinct chronological sessions (NY session, Overnight, or Weekly).POC (Point of Control): The brightest horizontal axis representing the absolute heaviest volume node where major commercial interest accumulated.VAH / VAL (Value Area High / Low): Boundaries containing the specified percentage (default 70%) of all transacted session volume.Execution Value: Markets trend from Value Area to Value Area, and reverse or accept at the Point of Control.4. Dynamic Workspace HUDThe Heads-Up Display anchored in the top-right corner aggregates data from all modules simultaneously. It calculates the midpoints of active ranges to output an instant institutional bias framework:LONG: Market price is structural over the global network midpoint.SHORT: Market price is tracking below the global network midpoint.UP / DN Metaphorical Distances: Live ticker measuring exactly how many index points remain until NQ hits the next immediate overhead resistance level or floor support.🛠️ Key Inputs & CustomizationOpen the indicator settings window ($⚙$) to fine-tune your parameters:Timezone Matching: Set your exact location input (Defaults to America/New_York) to line up your structural session pivots accurately.Wick / Body Ratio: Located under Rejection Blocks. Increase this value if you want the algorithm to filter for only ultra-aggressive, high-conviction institutional wicks.Volume Profile Rows: Adjust rows (up to 300) to change the resolution density of your volume profiles. Higher values create finer grain structures.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chrissdev_io

// © Built for NQ reversal workflow
// MotiveWave-style session fib pivots, HTF rejection blocks, session volume profile
//
// HOW TO USE
//   1. Copy this whole file
//   2. TradingView → Pine Editor (bottom panel) → paste → Save → "Add to chart"
//   3. Chart timeframe should be intraday (1m to 15m work best for the fib pivots and VP)
//   4. Session times default to ET; adjust in the inputs if you trade a different timezone
//
// FIB PIVOT FORMULA (matches MotiveWave)
//   PP = (H + L + C) / 3
//   Range = H - L
//   ±0.382 = PP ± 0.382 * Range
//   ±0.618 = PP ± 0.618 * Range
//   ±1.000 = PP ± 1.000 * Range
//   ±1.272 = PP ± 1.272 * Range  (extension)
//   ±1.618 = PP ± 1.618 * Range  (extension)
//   H, L, C are from the prior completed session of the same type

//@version=6
indicator("NQ Reversal Toolkit", "NQ RT", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)


// =====================================================================
// INPUTS
// =====================================================================

// ---------- FIB PIVOTS ----------
gFib = "Fib Pivots (Session-Based)"
fibOn = input.bool(true, "Enable", group = gFib)

tz = input.string("America/New_York", "Timezone", options = ["America/New_York", "Europe/London", "UTC"], group = gFib)

asiaSess   = input.session("1800-0300", "Asia session",       group = gFib)
londonSess = input.session("0300-0930", "London session",     group = gFib)
nySess     = input.session("0930-1600", "New York session",   group = gFib)

asiaOn   = input.bool(true,  "Asia",   group = gFib, inline = "sess")
londonOn = input.bool(true,  "London", group = gFib, inline = "sess")
nyOn     = input.bool(true,  "NY",     group = gFib, inline = "sess")

ppOn      = input.bool(true,  "PP",    group = gFib, inline = "lvl1")
lvl382On  = input.bool(true,  "0.382", group = gFib, inline = "lvl1")
lvl618On  = input.bool(true,  "0.618", group = gFib, inline = "lvl1")
lvl1000On = input.bool(true,  "1.000", group = gFib, inline = "lvl2")
lvl1272On = input.bool(false, "1.272", group = gFib, inline = "lvl2")
lvl1618On = input.bool(false, "1.618", group = gFib, inline = "lvl2")

asiaCol   = input.color(#8A6BFA, "Asia",   group = gFib, inline = "col")
londonCol = input.color(#F0A040, "London", group = gFib, inline = "col")
nyCol     = input.color(#3FB6E8, "NY",     group = gFib, inline = "col")

lineStyleInput  = input.string("solid", "Line style", options = ["solid", "dashed", "dotted"], group = gFib)
lineWidthInput  = input.int(1, "Line width", minval = 1, maxval = 3, group = gFib)
labelsOn        = input.bool(true, "Show labels", group = gFib)
labelOffsetBars = input.int(5, "Label offset (bars right)", minval = 0, maxval = 50, group = gFib)

// 1H Fib Pivots
fib1hOn = input.bool(false, "Enable 1H Fib Pivots", group = gFib)
fib1hCol = input.color(color.new(#a78bfa, 60), "1H Fib color", group = gFib)


// ---------- REJECTION BLOCKS ----------
gRB = "Rejection Blocks (HTF)"
rbOn          = input.bool(true, "Enable", group = gRB)
rbTF          = input.timeframe("60", "Timeframe", group = gRB)
rbRatio       = input.float(1.5, "Wick / body ratio (min)", minval = 1.0, step = 0.1, group = gRB)
rbMinATR      = input.float(0.4, "Min wick size (ATR multiple)", minval = 0.0, step = 0.1, group = gRB)
rbExtendBars  = input.int(35, "Extend right (bars)", minval = 10, maxval = 500, group = gRB)
rbMaxKeep     = input.int(12, "Max blocks visible", minval = 1, maxval = 50, group = gRB)
rbMitigate    = input.bool(true, "Remove when mitigated", group = gRB)
rbBullCol     = input.color(color.new(#22c55e, 82), "Bullish RB fill", group = gRB)
rbBearCol     = input.color(color.new(#ef4444, 82), "Bearish RB fill", group = gRB)
rbBorder      = input.color(color.new(#aaaaaa, 50), "RB border", group = gRB)
rbLabelsOn    = input.bool(true, "Show RB labels", group = gRB)


// ---------- VOLUME PROFILE ----------
gVP = "Volume Profile (Session)"
vpOn            = input.bool(true, "Enable", group = gVP)
vpSession       = input.string("NY", "Session", options = ["NY", "Overnight", "Weekly"], group = gVP)
vpOvernightStr  = input.session("1800-0930", "Overnight session", group = gVP)
vpNYStr         = input.session("0930-1700", "NY session", group = gVP)
vpRows          = input.int(250, "Rows", minval = 15, maxval = 300, group = gVP)
vpWidthBars     = input.int(18, "Profile width (bars)", minval = 10, maxval = 200, group = gVP)
vaPct           = input.float(70, "Value area %", minval = 50, maxval = 90, group = gVP)
vpKeep          = input.int(1, "Profiles to keep", minval = 1, maxval = 5, group = gVP)
vpFillCol       = input.color(color.new(#4a4a55, 60), "Profile fill (outside VA)", group = gVP)
vpVACol         = input.color(color.new(#ffffff, 50), "Value area fill", group = gVP)
vpPocCol        = input.color(#f59e0b, "POC color", group = gVP)
vpVahValCol     = input.color(color.new(#ffffff, 30), "VAH / VAL color", group = gVP)
vpLabelsOn      = input.bool(true, "Show VP labels", group = gVP)


// ---------- HUD ----------
gHUD = "HUD"
hudOn = input.bool(true, "Enable HUD", group = gHUD)
hudBiasCol = input.color(#ffffff, "Text color", group = gHUD)


// =====================================================================
// TYPES
// =====================================================================

type SessionFib
    string name
    string sessStr
    color col
    bool enabled
    array<line> lines
    array<label> labels
    float curH
    float curL
    float curC
    float priorH
    float priorL
    float priorC
    bool active

type RB
    box bx
    label lb
    float top
    float bot
    bool isBull

type VPDrawing
    array<line> bins
    line pocL
    line vahL
    line valL
    label pocLbl
    label vahLbl
    label valLbl


// =====================================================================
// HELPERS
// =====================================================================

getLineStyle(string s) =>
    s == "dashed" ? line.style_dashed : s == "dotted" ? line.style_dotted : line.style_solid


// Add one fib line and its label
addLevel(SessionFib s, float price, string lvlName, int startBar) =>
    line ln = line.new(startBar, price, startBar, price, color = s.col, style = getLineStyle(lineStyleInput), width = lineWidthInput, extend = extend.none)
    array.push(s.lines, ln)
    if labelsOn
        label lb = label.new(startBar + labelOffsetBars, price, s.name + " " + lvlName, style = label.style_label_left, color = color.new(s.col, 80), textcolor = color.white, size = size.tiny)
        array.push(s.labels, lb)


// Calculate and draw fib pivots from a session's prior H/L/C
drawSessionPivots(SessionFib s, int startBar) =>
    if not na(s.priorH) and not na(s.priorL) and not na(s.priorC)
        float pp = (s.priorH + s.priorL + s.priorC) / 3
        float rng = s.priorH - s.priorL
        if ppOn
            addLevel(s, pp, "PP", startBar)
        if lvl382On
            addLevel(s, pp + 0.382 * rng, "0.382",  startBar)
            addLevel(s, pp - 0.382 * rng, "-0.382", startBar)
        if lvl618On
            addLevel(s, pp + 0.618 * rng, "0.618",  startBar)
            addLevel(s, pp - 0.618 * rng, "-0.618", startBar)
        if lvl1000On
            addLevel(s, pp + 1.000 * rng, "1.000",  startBar)
            addLevel(s, pp - 1.000 * rng, "-1.000", startBar)
        if lvl1272On
            addLevel(s, pp + 1.272 * rng, "1.272",  startBar)
            addLevel(s, pp - 1.272 * rng, "-1.272", startBar)
        if lvl1618On
            addLevel(s, pp + 1.618 * rng, "1.618",  startBar)
            addLevel(s, pp - 1.618 * rng, "-1.618", startBar)


// Wipe a session's drawings
clearSession(SessionFib s) =>
    if array.size(s.lines) > 0
        for ln in s.lines
            line.delete(ln)
        array.clear(s.lines)
    if array.size(s.labels) > 0
        for lb in s.labels
            label.delete(lb)
        array.clear(s.labels)


// Update a session each bar
updateSession(SessionFib s) =>
    if s.enabled
        bool inSess  = not na(time(timeframe.period, s.sessStr, tz))
        bool started = inSess and not s.active
        if started
            if not na(s.curH)
                s.priorH := s.curH
                s.priorL := s.curL
                s.priorC := s.curC
            s.curH := high
            s.curL := low
            s.curC := close
            clearSession(s)
            drawSessionPivots(s, bar_index)
        else if inSess
            s.curH := math.max(s.curH, high)
            s.curL := math.min(s.curL, low)
            s.curC := close
            // Extend lines and slide labels along
            if array.size(s.lines) > 0
                for ln in s.lines
                    line.set_x2(ln, bar_index)
            if array.size(s.labels) > 0
                for lb in s.labels
                    label.set_x(lb, bar_index + labelOffsetBars)
        s.active := inSess


// =====================================================================
// SESSION INSTANCES (Fib Pivots)
// =====================================================================

var SessionFib asia   = SessionFib.new("ASIA", asiaSess,   asiaCol,   asiaOn,   array.new<line>(), array.new<label>(), na, na, na, na, na, na, false)
var SessionFib london = SessionFib.new("LON",  londonSess, londonCol, londonOn, array.new<line>(), array.new<label>(), na, na, na, na, na, na, false)
var SessionFib ny     = SessionFib.new("NY",   nySess,     nyCol,     nyOn,     array.new<line>(), array.new<label>(), na, na, na, na, na, na, false)

// Refresh dynamic fields on every bar (so toggles and colors update live)
asia.col       := asiaCol
asia.enabled   := asiaOn
asia.sessStr   := asiaSess
london.col     := londonCol
london.enabled := londonOn
london.sessStr := londonSess
ny.col         := nyCol
ny.enabled     := nyOn
ny.sessStr     := nySess

if fibOn
    updateSession(asia)
    updateSession(london)
    updateSession(ny)

// 1H Fib Pivots on chart
var array<line> h1Lines = array.new<line>()
var array<label> h1Labels = array.new<label>()

if fib1hOn
    // Get 1H data
    float h1O = request.security(syminfo.tickerid, "60", open[1],  lookahead = barmerge.lookahead_off)
    float h1H = request.security(syminfo.tickerid, "60", high[1],  lookahead = barmerge.lookahead_off)
    float h1L = request.security(syminfo.tickerid, "60", low[1],   lookahead = barmerge.lookahead_off)
    float h1C = request.security(syminfo.tickerid, "60", close[1], lookahead = barmerge.lookahead_off)
    
    // Check if 1H candle has changed
    if not na(h1O) and not na(h1H) and not na(h1L) and not na(h1C) and ta.change(time("60")) != 0
        // Clear old lines
        for ln in h1Lines
            line.delete(ln)
        for lb in h1Labels
            label.delete(lb)
        array.clear(h1Lines)
        array.clear(h1Labels)
        
        // Calculate 1H fib levels
        float h1pp = (h1H + h1L + h1C) / 3
        float h1range = h1H - h1L
        if h1range > 0
            // Draw PP
            line pp_line = line.new(bar_index, h1pp, bar_index, h1pp, color = fib1hCol, style = line.style_solid, width = 1, extend = extend.right)
            array.push(h1Lines, pp_line)
            if labelsOn
                label pp_lbl = label.new(bar_index + labelOffsetBars, h1pp, "H1 PP " + str.tostring(h1pp, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                array.push(h1Labels, pp_lbl)
            
            // Draw 0.382
            if lvl382On
                float l382u_price = h1pp + 0.382 * h1range
                float l382d_price = h1pp - 0.382 * h1range
                line l382u = line.new(bar_index, l382u_price, bar_index, l382u_price, color = color.new(fib1hCol, 50), style = line.style_dotted, width = 1, extend = extend.right)
                array.push(h1Lines, l382u)
                if labelsOn
                    label l382u_lbl = label.new(bar_index + labelOffsetBars, l382u_price, "H1 +0.382 " + str.tostring(l382u_price, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                    array.push(h1Labels, l382u_lbl)
                line l382d = line.new(bar_index, l382d_price, bar_index, l382d_price, color = color.new(fib1hCol, 50), style = line.style_dotted, width = 1, extend = extend.right)
                array.push(h1Lines, l382d)
                if labelsOn
                    label l382d_lbl = label.new(bar_index + labelOffsetBars, l382d_price, "H1 -0.382 " + str.tostring(l382d_price, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                    array.push(h1Labels, l382d_lbl)
            
            // Draw 0.618
            if lvl618On
                float l618u_price = h1pp + 0.618 * h1range
                float l618d_price = h1pp - 0.618 * h1range
                line l618u = line.new(bar_index, l618u_price, bar_index, l618u_price, color = color.new(fib1hCol, 50), style = line.style_dotted, width = 1, extend = extend.right)
                array.push(h1Lines, l618u)
                if labelsOn
                    label l618u_lbl = label.new(bar_index + labelOffsetBars, l618u_price, "H1 +0.618 " + str.tostring(l618u_price, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                    array.push(h1Labels, l618u_lbl)
                line l618d = line.new(bar_index, l618d_price, bar_index, l618d_price, color = color.new(fib1hCol, 50), style = line.style_dotted, width = 1, extend = extend.right)
                array.push(h1Lines, l618d)
                if labelsOn
                    label l618d_lbl = label.new(bar_index + labelOffsetBars, l618d_price, "H1 -0.618 " + str.tostring(l618d_price, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                    array.push(h1Labels, l618d_lbl)
            
            // Draw 1.000
            if lvl1000On
                float l1000u_price = h1pp + 1.000 * h1range
                float l1000d_price = h1pp - 1.000 * h1range
                line l1000u = line.new(bar_index, l1000u_price, bar_index, l1000u_price, color = color.new(fib1hCol, 50), style = line.style_dotted, width = 1, extend = extend.right)
                array.push(h1Lines, l1000u)
                if labelsOn
                    label l1000u_lbl = label.new(bar_index + labelOffsetBars, l1000u_price, "H1 +1.000 " + str.tostring(l1000u_price, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                    array.push(h1Labels, l1000u_lbl)
                line l1000d = line.new(bar_index, l1000d_price, bar_index, l1000d_price, color = color.new(fib1hCol, 50), style = line.style_dotted, width = 1, extend = extend.right)
                array.push(h1Lines, l1000d)
                if labelsOn
                    label l1000d_lbl = label.new(bar_index + labelOffsetBars, l1000d_price, "H1 -1.000 " + str.tostring(l1000d_price, format.mintick), style = label.style_label_left, color = color.new(fib1hCol, 80), textcolor = color.white, size = size.tiny)
                    array.push(h1Labels, l1000d_lbl)
    else if fib1hOn
        // Update existing lines to current bar
        for ln in h1Lines
            line.set_x2(ln, bar_index)
        for lb in h1Labels
            label.set_x(lb, bar_index + labelOffsetBars)


// =====================================================================
// REJECTION BLOCKS (HTF)
// =====================================================================

// Validate that the rejection block timeframe is >= chart timeframe
chartSec = timeframe.in_seconds(timeframe.period)
rbSec    = timeframe.in_seconds(rbTF)
rbValid  = rbSec >= chartSec

// Pull just-closed HTF candle data and its ATR
htfO   = request.security(syminfo.tickerid, rbTF, open[1],       lookahead = barmerge.lookahead_off)
htfH   = request.security(syminfo.tickerid, rbTF, high[1],       lookahead = barmerge.lookahead_off)
htfL   = request.security(syminfo.tickerid, rbTF, low[1],        lookahead = barmerge.lookahead_off)
htfC   = request.security(syminfo.tickerid, rbTF, close[1],      lookahead = barmerge.lookahead_off)
htfATR = request.security(syminfo.tickerid, rbTF, ta.atr(14)[1], lookahead = barmerge.lookahead_off)

// Detect when the HTF bar just closed (new HTF bar started)
htfClosed = ta.change(time(rbTF)) != 0

var array<RB> rbList = array.new<RB>()

if rbOn and rbValid and htfClosed and barstate.isconfirmed and not na(htfO) and not na(htfH) and not na(htfL) and not na(htfC)
    float body       = math.abs(htfC - htfO)
    float upperWick  = htfH - math.max(htfO, htfC)
    float lowerWick  = math.min(htfO, htfC) - htfL

    bool bearRB = body > 0 and upperWick > rbRatio * body and (na(htfATR) or upperWick > rbMinATR * htfATR)
    bool bullRB = body > 0 and lowerWick > rbRatio * body and (na(htfATR) or lowerWick > rbMinATR * htfATR)

    if bearRB or bullRB
        float top    = bearRB ? htfH                       : math.min(htfO, htfC)
        float bot    = bearRB ? math.max(htfO, htfC)       : htfL
        color fillC  = bearRB ? rbBearCol                  : rbBullCol
        string lblTx = rbTF + " RB"
        
        // Check if this RB overlaps with existing ones (within 5 points)
        bool overlaps = false
        for existing in rbList
            if math.abs(existing.top - top) < 5 or math.abs(existing.bot - bot) < 5
                overlaps := true
                break
        
        if not overlaps
            box bx = box.new(bar_index[1], top, bar_index + rbExtendBars, bot, border_color = rbBorder, border_width = 1, bgcolor = fillC)
            label lb = na
            if rbLabelsOn
                lb := label.new(bar_index + rbExtendBars, (top + bot) / 2, lblTx, style = label.style_label_left, color = color.new(fillC, 40), textcolor = color.white, size = size.tiny)

            RB r = RB.new(bx, lb, top, bot, bullRB)
            array.push(rbList, r)

            // Trim to max
            while array.size(rbList) > rbMaxKeep
                RB old = array.shift(rbList)
                box.delete(old.bx)
                if not na(old.lb)
                    label.delete(old.lb)

// Mitigation pass on every bar
if rbOn and rbMitigate and array.size(rbList) > 0
    int i = array.size(rbList) - 1
    while i >= 0
        RB r = array.get(rbList, i)
        bool mit = r.isBull ? low < r.bot : high > r.top
        if mit
            box.delete(r.bx)
            if not na(r.lb)
                label.delete(r.lb)
            array.remove(rbList, i)
        i -= 1


// =====================================================================
// VOLUME PROFILE (Session)
// =====================================================================

// Bar-level data accumulators for the current session
var array<float> vpHighs  = array.new<float>()
var array<float> vpLows   = array.new<float>()
var array<float> vpVols   = array.new<float>()
var int          vpStart  = na
var bool         vpReady  = false

// Drawings for completed profiles
var array<VPDrawing> vpDrawings = array.new<VPDrawing>()


// Detect session boundary based on selected mode
bool sessEndNow = false

if vpSession == "NY"
    bool inNY = not na(time(timeframe.period, vpNYStr, tz))
    bool wasNY = inNY[1]
    sessEndNow := wasNY and not inNY  // exited NY session
else if vpSession == "Weekly"
    sessEndNow := ta.change(time("W")) != 0
else  // Overnight
    bool inON = not na(time(timeframe.period, vpOvernightStr, tz))
    bool wasON = inON[1]
    sessEndNow := wasON and not inON  // exited overnight session


// Render a completed session's profile
renderProfile() =>
    if array.size(vpHighs) > 5 and not na(vpStart)
        float sHi = array.max(vpHighs)
        float sLo = array.min(vpLows)
        if sHi > sLo
            float binSize = (sHi - sLo) / vpRows
            array<float> bins = array.new<float>(vpRows, 0.0)

            for k = 0 to array.size(vpHighs) - 1
                float h = array.get(vpHighs, k)
                float l = array.get(vpLows,  k)
                float v = array.get(vpVols,  k)
                int   bStart = math.max(0, math.floor((l - sLo) / binSize))
                int   bEnd   = math.min(vpRows - 1, math.floor((h - sLo) / binSize))
                int   n      = bEnd - bStart + 1
                float vPer   = n > 0 ? v / n : 0.0
                for j = bStart to bEnd
                    array.set(bins, j, array.get(bins, j) + vPer)

            float maxVol = array.max(bins)
            int   pocIdx = array.indexof(bins, maxVol)
            float pocPx  = sLo + (pocIdx + 0.5) * binSize

            float totalVol = array.sum(bins)
            float vaTarget = totalVol * vaPct / 100
            float vaSum    = maxVol
            int   vahIdx   = pocIdx
            int   valIdx   = pocIdx

            while vaSum < vaTarget
                float up   = vahIdx < vpRows - 1 ? array.get(bins, vahIdx + 1) : 0.0
                float down = valIdx > 0          ? array.get(bins, valIdx - 1) : 0.0
                if up == 0 and down == 0
                    break
                if up >= down and vahIdx < vpRows - 1
                    vahIdx += 1
                    vaSum  += up
                else if valIdx > 0
                    valIdx -= 1
                    vaSum  += down
                else
                    break

            float vah = sLo + (vahIdx + 1) * binSize
            float val = sLo + valIdx * binSize

            array<line> binLines = array.new<line>()
            int profStart = bar_index - 1
            for i = 0 to vpRows - 1
                float v = array.get(bins, i)
                if v > 0
                    int lineLen = math.max(2, math.round((v / maxVol) * vpWidthBars * 1.5))
                    lineLen := math.min(lineLen, vpWidthBars * 2)
                    float levelPrice = sLo + (i + 0.5) * binSize
                    bool inVA = i >= valIdx and i <= vahIdx
                    color c = inVA ? vpVACol : vpFillCol
                    line ln = line.new(profStart, levelPrice, profStart + lineLen, levelPrice, color = c, width = 1)
                    array.push(binLines, ln)

            int rightEnd = bar_index
            string sessLabel = vpSession == "Overnight" ? " ON" : vpSession == "Weekly" ? " W" : " NY"
            
            line pocL = line.new(profStart, pocPx, rightEnd, pocPx, color = vpPocCol, width = 2, extend = extend.right)
            line vahL = line.new(profStart, vah,   rightEnd, vah,   color = color.new(#22c55e, 60), style = line.style_dashed, width = 1, extend = extend.right)
            line valL = line.new(profStart, val,   rightEnd, val,   color = color.new(#ef4444, 60), style = line.style_dashed, width = 1, extend = extend.right)

            label pocLbl = na
            label vahLbl = na
            label valLbl = na
            if vpLabelsOn
                pocLbl := label.new(rightEnd + 5, pocPx, "POC" + sessLabel + " " + str.tostring(pocPx, format.mintick), style = label.style_label_left, color = color.new(vpPocCol, 75), textcolor = color.white, size = size.tiny)
                vahLbl := label.new(rightEnd + 5, vah,   "VAH" + sessLabel + " " + str.tostring(vah,   format.mintick), style = label.style_label_left, color = color.new(#22c55e, 75), textcolor = color.white, size = size.tiny)
                valLbl := label.new(rightEnd + 5, val,   "VAL" + sessLabel + " " + str.tostring(val,   format.mintick), style = label.style_label_left, color = color.new(#ef4444, 75), textcolor = color.white, size = size.tiny)

            VPDrawing d = VPDrawing.new(binLines, pocL, vahL, valL, pocLbl, vahLbl, valLbl)
            array.push(vpDrawings, d)

            // Trim to vpKeep
            while array.size(vpDrawings) > vpKeep
                VPDrawing old = array.shift(vpDrawings)
                for ln in old.bins
                    line.delete(ln)
                line.delete(old.pocL)
                line.delete(old.vahL)
                line.delete(old.valL)
                if not na(old.pocLbl)
                    label.delete(old.pocLbl)
                if not na(old.vahLbl)
                    label.delete(old.vahLbl)
                if not na(old.valLbl)
                    label.delete(old.valLbl)


// Bar-by-bar VP accumulation
if vpOn
    // First bar setup
    if not vpReady
        vpStart := bar_index
        vpReady := true

    // Session boundary: render the just-completed session and reset
    if sessEndNow and array.size(vpHighs) > 0
        renderProfile()
        array.clear(vpHighs)
        array.clear(vpLows)
        array.clear(vpVols)
        vpStart := bar_index

    // Only accumulate while in the selected session window
    bool accumulate = true
    if vpSession == "NY"
        accumulate := not na(time(timeframe.period, vpNYStr, tz))
        if accumulate and array.size(vpHighs) == 0
            vpStart := bar_index
    else if vpSession == "Overnight"
        accumulate := not na(time(timeframe.period, vpOvernightStr, tz))
        if accumulate and array.size(vpHighs) == 0
            vpStart := bar_index

    if accumulate
        array.push(vpHighs, high)
        array.push(vpLows,  low)
        array.push(vpVols,  volume)


// =====================================================================
// HUD (Heads-Up Display)
// =====================================================================

var table hudTable = na

if hudOn
    if barstate.islast and hudOn
        // Collect all active fib levels from NY session
        array<float> levels = array.new<float>()
        
        if nyOn and ny.active
            float pp = (ny.curH + ny.curL + ny.curC) / 3
            float dayRange = ny.curH - ny.curL
            if dayRange > 0
                if ppOn
                    array.push(levels, pp)
                if lvl382On
                    array.push(levels, pp + 0.382 * dayRange)
                if lvl382On
                    array.push(levels, pp - 0.382 * dayRange)
                if lvl618On
                    array.push(levels, pp + 0.618 * dayRange)
                if lvl618On
                    array.push(levels, pp - 0.618 * dayRange)
                if lvl1000On
                    array.push(levels, pp + 1.000 * dayRange)
                if lvl1000On
                    array.push(levels, pp - 1.000 * dayRange)
        
        // Add 1H fib pivots if enabled
        if fib1hOn
            float h1O = request.security(syminfo.tickerid, "60", open[1],  lookahead = barmerge.lookahead_off)
            float h1H = request.security(syminfo.tickerid, "60", high[1],  lookahead = barmerge.lookahead_off)
            float h1L = request.security(syminfo.tickerid, "60", low[1],   lookahead = barmerge.lookahead_off)
            float h1C = request.security(syminfo.tickerid, "60", close[1], lookahead = barmerge.lookahead_off)
            if not na(h1O) and not na(h1H) and not na(h1L) and not na(h1C)
                float h1pp = (h1H + h1L + h1C) / 3
                float h1range = h1H - h1L
                if h1range > 0
                    array.push(levels, h1pp)
                    if lvl382On
                        array.push(levels, h1pp + 0.382 * h1range)
                        array.push(levels, h1pp - 0.382 * h1range)
                    if lvl618On
                        array.push(levels, h1pp + 0.618 * h1range)
                        array.push(levels, h1pp - 0.618 * h1range)
                    if lvl1000On
                        array.push(levels, h1pp + 1.000 * h1range)
                        array.push(levels, h1pp - 1.000 * h1range)
        
        // Add VP levels if available
        if vpOn and array.size(vpDrawings) > 0
            VPDrawing latest = array.get(vpDrawings, array.size(vpDrawings) - 1)
            if not na(latest.pocL)
                array.push(levels, (latest.pocL).get_y1())
            if not na(latest.vahL)
                array.push(levels, (latest.vahL).get_y1())
            if not na(latest.valL)
                array.push(levels, (latest.valL).get_y1())
        
        // Find next levels and bias
        array.sort(levels)
        float nextUp = na
        float nextDown = na
        string bias = "NEUTRAL"
        
        for lv in levels
            if lv > close and na(nextUp)
                nextUp := lv
            if lv < close
                nextDown := lv
        
        // Determine bias: price above/below midpoint of levels
        if array.size(levels) > 0
            float mid = array.get(levels, math.floor(array.size(levels) / 2))
            bias := close > mid ? "LONG" : "SHORT"
        
        // Format distances
        string distUp = na(nextUp) ? "N/A" : str.tostring(math.round((nextUp - close) * 4) / 4)
        string distDown = na(nextDown) ? "N/A" : str.tostring(math.round((close - nextDown) * 4) / 4)
        
        // Build HUD
        string hudText = bias + " | UP: " + distUp + " | DN: " + distDown
        
        // Create/update HUD table
        if na(hudTable)
            hudTable := table.new(position.top_right, 1, 1, bgcolor = color.new(color.black, 85), border_color = color.new(hudBiasCol, 60), border_width = 1)
        table.cell(hudTable, 0, 0, hudText, text_size = size.small, text_color = hudBiasCol)


// =====================================================================
// VALIDATION WARNINGS
// =====================================================================

if barstate.islast
    if rbOn and not rbValid
        label.new(bar_index, high, "RB timeframe must be ≥ chart timeframe", style = label.style_label_down, color = color.new(color.red, 30), textcolor = color.white, size = size.normal)
````
