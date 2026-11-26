# Multi Timeframe Pro

- url: https://www.tradingview.com/script/1DJ1h18g/
- type: indicator
- pine_id: PUB;12007ba3687340aeb43110d1c20e21de
- version: 9.0

## Description

Multi Timeframe Pro — HTF Levels + Anchored VWAP
Two indicators in one clean overlay: previous-candle ranges from up to 3 timeframes, plus a fully customizable anchored VWAP with bands.

▌ Features
• Boxes for the LAST CLOSED candle of up to 3 timeframes (High, Low, dashed Mid)
• Anchored VWAP with 2 standard-deviation bands — no background fills
• Live countdown table — see when the next candle of each TF closes
• Per-TF in-indicator alerts (line crossing / bar closes outside)
• Clean line labels — e.g. "1D High", "4h Low"
• Auto-warning if a non-standard chart (Heikin Ashi, Renko, …) is used

▌ Defaults
TF 1    1D    yellow
TF 2    4H    aqua
TF 3    15m   off
VWAP    Session-anchored
Mid     white, solid
Band 1  white, dashed, ±1 StDev
Band 2  gray,  dashed, ±2 StDev

▌ Quick Start
1. Add to any chart (TF ≤ your highest configured TF)
2. Boxes update automatically when the higher-TF candle closes
3. For alerts: enable toggles in the Alerts section, then add ONE TradingView alert with
   Condition: Multi Timeframe Pro
   Function:  Any alert() function call
   Trigger:   Once Per Bar Close

▌ Notes
• Pine v5
• Use standard candle charts (a red warning appears in the table otherwise)
• VWAP requires a symbol with volume — disable it for FX if needed

## Source Code

````pine
//@version=5
indicator("Multi Timeframe Pro", shorttitle = "Multi Timeframe Pro", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// Version — bei jedem Update hochzählen (siehe memory: tf-box-versioning)
VERSION = "v1.67"

// Forces "NQAlphaSignals.com" as a visible entry in the status line,
// in case TradingView truncates the shorttitle after "TF Box".
plotchar(na, title = "│ NQAlphaSignals.com", char = "", location = location.top, display = display.status_line, editable = false)

// ============================================================
// GENERAL
// ============================================================
grpGen      = "General"
showMid     = input.bool(true, "Show midline (dashed)", group = grpGen, display = display.none)
extendBars  = input.int(15,    "Label offset (bars to the right)", minval = 0, maxval = 200, group = grpGen, display = display.none, tooltip = "How many chart bars the H/L/Mid LINES and their LABELS extend to the right of the latest bar. The TF-Box background also extends to at least this position on chart TFs ≥ HTF-TF so the fill stays visible.")
showBoxes   = input.bool(true, "Show TF background fills", group = grpGen, display = display.none, tooltip = "Show the colored background fill of each TF box. Disable to keep only the High/Low/Mid lines and labels.")

grpLbl     = "Line labels"
// Name labels (e.g. "1D High", "4h Low") — default ON
showNameHL = input.bool(true,  "Name on High and Low line  (e.g. 1D High / 1D Low)", group = grpLbl, display = display.none)
showNameM  = input.bool(true,  "Name on midline            (e.g. 1D Mid)",            group = grpLbl, display = display.none)
// Price labels — default OFF
showPrcHL  = input.bool(false, "Price on High and Low line", group = grpLbl, display = display.none)
showPrcM   = input.bool(false, "Price on midline",           group = grpLbl, display = display.none)
lblSize    = input.string("normal", "Text size",
   options = ["tiny","small","normal","large","huge"], group = grpLbl, display = display.none)

// ============================================================
// TF 1 — default: 4H (active)
// ============================================================
g1        = "TF 1 (default: 4H)"
e1        = input.bool(true,         "Active",          group = g1, display = display.none)
tf1       = input.timeframe("240",   "Timeframe",       options = ["1","3","5","15","30","45","60","120","180","240","360","480","720","D","W","M"], group = g1, display = display.none)
fill1     = input.color(color.new(color.aqua, 90), "Fill",   group = g1, display = display.none)
brd1      = input.color(color.new(color.aqua,  0), "Border", group = g1, display = display.none)
w1        = input.int(1,             "Line width", minval = 1, maxval = 5, group = g1, display = display.none)

// ============================================================
// TF 2 — default: 1D (active)
// ============================================================
g2        = "TF 2 (default: 1D)"
e2        = input.bool(true,         "Active",          group = g2, display = display.none)
tf2       = input.timeframe("D",     "Timeframe",       options = ["1","3","5","15","30","45","60","120","180","240","360","480","720","D","W","M"], group = g2, display = display.none)
fill2     = input.color(color.new(color.yellow, 90), "Fill",   group = g2, display = display.none)
brd2      = input.color(color.new(color.yellow,  0), "Border", group = g2, display = display.none)
w2        = input.int(1,             "Line width", minval = 1, maxval = 5, group = g2, display = display.none)

// ============================================================
// TF 3 — default: 15m (INACTIVE)
// ============================================================
g3        = "TF 3 (default: 15m, inactive)"
e3        = input.bool(false,        "Active",          group = g3, display = display.none)
tf3       = input.timeframe("15",    "Timeframe",       options = ["1","3","5","15","30","45","60","120","180","240","360","480","720","D","W","M"], group = g3, display = display.none)
fill3     = input.color(color.new(color.fuchsia, 90), "Fill",  group = g3, display = display.none)
brd3      = input.color(color.new(color.fuchsia,  0), "Border", group = g3, display = display.none)
w3        = input.int(1,             "Line width", minval = 1, maxval = 5, group = g3, display = display.none)

// ============================================================
// VWAP
// ============================================================
grpV       = "VWAP"
showVwap   = input.bool(true,    "Show VWAP",                       group = grpV, display = display.none)
vwapAnchor = input.string("Session", "Anchor period",
   options = ["Session","Week","Month","Quarter","Year","Decade","Century","Earnings","Dividends","Splits"], group = grpV, display = display.none)
vwapSrc    = input.source(hlc3,  "Source", group = grpV, display = display.none)
// Mid line (VWAP itself)
vwapColor  = input.color(color.white, "Mid line color",  group = grpV, display = display.none)
vwapWidth  = input.int(1,        "Mid line width", minval = 1, maxval = 5, group = grpV, display = display.none)
vwapStyle  = input.string("Solid", "Mid line style",
   options = ["Solid","Dashed","Dotted"], group = grpV, display = display.none)
// Outer lines (bands) — shared width & style
bandWidth  = input.int(1,        "Outer lines width", minval = 1, maxval = 5, group = grpV, display = display.none)
bandStyle  = input.string("Dashed", "Outer lines style",
   options = ["Solid","Dashed","Dotted"], group = grpV, display = display.none)
bandMode   = input.string("Standard Deviation", "Bands calculation",
   options = ["Standard Deviation","Percentage"], group = grpV, display = display.none)
// Band 1
showBand1  = input.bool(true,    "Show Band 1", group = grpV, display = display.none)
bandMult1  = input.float(1.0,    "Band 1 multiplier", step = 0.5, minval = 0, group = grpV, display = display.none)
band1Color = input.color(color.white, "Band 1 color", group = grpV, display = display.none)
// Band 2
showBand2  = input.bool(true,    "Show Band 2", group = grpV, display = display.none)
bandMult2  = input.float(2.0,    "Band 2 multiplier", step = 0.5, minval = 0, group = grpV, display = display.none)
band2Color = input.color(color.gray,  "Band 2 color", group = grpV, display = display.none)

// ============================================================
// COUNTDOWN TABLE
// ============================================================
grpT       = "Countdown table"
showTimer  = input.bool(true,        "Show",      group = grpT, display = display.none)
timerPos   = input.string("top_right", "Position",
   options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = grpT, display = display.none)
timerSize  = input.string("normal",  "Text size",
   options = ["tiny","small","normal","large","huge"], group = grpT, display = display.none)
colTimerBg = input.color(color.new(color.black, 30), "Background", group = grpT, display = display.none)
colTimerTx = input.color(color.white,                "Text color", group = grpT, display = display.none)

// ============================================================
// ALERTS (toggle directly — fire automatically via alert())
// In TradingView create 1 master alert: "Condition: Multi Timeframe Pro" →
// "Any alert() function call" → "Once Per Bar Close"
// ============================================================
grpA      = "Alerts"
a1Cross   = input.bool(false, "TF 1: Line crossing",         group = grpA, display = display.none)
a1Out     = input.bool(false, "TF 1: Bar closes outside",    group = grpA, display = display.none)
a1In      = input.bool(false, "TF 1: Bar closes inside",     group = grpA, display = display.none)
a2Cross   = input.bool(false, "TF 2: Line crossing",         group = grpA, display = display.none)
a2Out     = input.bool(false, "TF 2: Bar closes outside",    group = grpA, display = display.none)
a2In      = input.bool(false, "TF 2: Bar closes inside",     group = grpA, display = display.none)
a3Cross   = input.bool(false, "TF 3: Line crossing",         group = grpA, display = display.none)
a3Out     = input.bool(false, "TF 3: Bar closes outside",    group = grpA, display = display.none)
a3In      = input.bool(false, "TF 3: Bar closes inside",     group = grpA, display = display.none)

// ============================================================
// HELPERS
// ============================================================
getSize(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

getPos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"    ? position.top_center    :
     s == "top_right"     ? position.top_right     :
     s == "middle_left"   ? position.middle_left   :
     s == "middle_center" ? position.middle_center :
     s == "middle_right"  ? position.middle_right  :
     s == "bottom_left"   ? position.bottom_left   :
     s == "bottom_center" ? position.bottom_center :
     position.bottom_right

fmtHMS(totalSec) =>
    h = math.floor(totalSec / 3600)
    m = math.floor((totalSec % 3600) / 60)
    s = totalSec % 60
    (h < 10 ? "0" : "") + str.tostring(h) + ":" +
     (m < 10 ? "0" : "") + str.tostring(m) + ":" +
     (s < 10 ? "0" : "") + str.tostring(s)

// Kollisions-Erkennung: zählt, wie viele bereits platzierte Y-Werte innerhalb der
// Schwelle zum eigenen Y liegen → daraus ergibt sich der horizontale X-Versatz
countCol(myY, ys, threshold) =>
    cnt = 0
    if array.size(ys) > 0
        for i = 0 to array.size(ys) - 1
            if math.abs(myY - array.get(ys, i)) < threshold
                cnt := cnt + 1
    cnt

// Wandelt ein TF-String (z.B. "D", "240", "15") in ein lesbares Label um (z.B. "1D", "4h", "15m")
tfToLabel(tf) =>
    secs = timeframe.in_seconds(tf)
    string lbl = ""
    if secs >= 2592000     // ≥ 30 Tage → Monat
        lbl := str.tostring(math.round(secs / 2592000.0)) + "M"
    else if secs >= 604800 // ≥ 7 Tage → Woche
        lbl := str.tostring(math.round(secs / 604800.0)) + "W"
    else if secs >= 86400  // ≥ 1 Tag
        lbl := str.tostring(math.round(secs / 86400.0)) + "D"
    else if secs >= 3600   // ≥ 1 Stunde
        lbl := str.tostring(math.round(secs / 3600.0)) + "h"
    else                   // Minuten
        lbl := str.tostring(math.round(secs / 60.0)) + "m"
    lbl

// ============================================================
// FETCH DATA — last CLOSED candle + open time of the running one
// ============================================================
[H1, L1, OT1, R1] = request.security(syminfo.tickerid, tf1, [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)
[H2, L2, OT2, R2] = request.security(syminfo.tickerid, tf2, [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)
[H3, L3, OT3, R3] = request.security(syminfo.tickerid, tf3, [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)

end1 = R1 + timeframe.in_seconds(tf1) * 1000
end2 = R2 + timeframe.in_seconds(tf2) * 1000
end3 = R3 + timeframe.in_seconds(tf3) * 1000

// ============================================================
// DRAW BOXES & LABELS
// ============================================================
drawTF(enabled, hi, lo, lineLeft, boxLeft, boxRight, xH, xL, xM, fillCol, brdCol, brdW, prefix) =>
    var box   b    = na
    var line  ltop = na
    var line  lbot = na
    var line  lmid = na
    var label lh   = na
    var label ll   = na
    var label lm   = na
    box.delete(b)
    line.delete(ltop)
    line.delete(lbot)
    line.delete(lmid)
    label.delete(lh)
    label.delete(ll)
    label.delete(lm)
    if enabled
        mid = (hi + lo) / 2
        // Box (background fill): placed in the CURRENT forming TF period (= where the levels
        // are NOW active as reference). Optional via showBoxes.
        if showBoxes
            b := box.new(left = boxLeft, top = hi, right = boxRight, bottom = lo,
               xloc = xloc.bar_time, border_color = color.new(brdCol, 100), border_width = 0,
               bgcolor = fillCol)
        // Lines extend from where the H/L was formed (lineLeft) to each label's X position
        ltop := line.new(x1 = lineLeft, y1 = hi,  x2 = xH, y2 = hi,
           xloc = xloc.bar_time, color = brdCol, width = brdW, style = line.style_solid)
        lbot := line.new(x1 = lineLeft, y1 = lo,  x2 = xL, y2 = lo,
           xloc = xloc.bar_time, color = brdCol, width = brdW, style = line.style_solid)
        if showMid
            lmid := line.new(x1 = lineLeft, y1 = mid, x2 = xM, y2 = mid,
               xloc = xloc.bar_time, color = brdCol, width = brdW, style = line.style_dashed)
        // High label
        if showNameHL or showPrcHL
            hTxt = (showNameHL ? "Last " + prefix + " High" : "") +
               (showNameHL and showPrcHL ? "  " : "") +
               (showPrcHL ? str.tostring(hi, format.mintick) : "")
            lh := label.new(xH, hi, hTxt,
               xloc = xloc.bar_time, style = label.style_label_left,
               color = color.new(brdCol, 75), textcolor = brdCol, size = getSize(lblSize))
        // Low label
        if showNameHL or showPrcHL
            lTxt = (showNameHL ? "Last " + prefix + " Low" : "") +
               (showNameHL and showPrcHL ? "  " : "") +
               (showPrcHL ? str.tostring(lo, format.mintick) : "")
            ll := label.new(xL, lo, lTxt,
               xloc = xloc.bar_time, style = label.style_label_left,
               color = color.new(brdCol, 75), textcolor = brdCol, size = getSize(lblSize))
        // Midline label
        if showNameM or showPrcM
            mTxt = (showNameM ? "Last " + prefix + " Mid" : "") +
               (showNameM and showPrcM ? "  " : "") +
               (showPrcM ? str.tostring(mid, format.mintick) : "")
            lm := label.new(xM, mid, mTxt,
               xloc = xloc.bar_time, style = label.style_label_left,
               color = color.new(brdCol, 75), textcolor = brdCol, size = getSize(lblSize))
    0

if barstate.islast
    barMs  = timeframe.in_seconds() * 1000
    rT     = time + barMs * extendBars
    // Box spans the CURRENT forming TF candle (= 2nd half of the 8h visual area).
    // OT1 = open of previous closed TF candle (where lines start).
    // boxLeft = OT1 + TF-Dauer = open of current forming TF candle.
    // boxRight = OT1 + 2 × TF-Dauer = close of current forming TF candle.
    msTf1 = timeframe.in_seconds(tf1) * 1000
    msTf2 = timeframe.in_seconds(tf2) * 1000
    msTf3 = timeframe.in_seconds(tf3) * 1000
    // Box right edge: end of current forming TF period, but extended to at least rT
    // so the fill stays visible on chart TFs >= TF-Box TF (otherwise the box would be
    // exactly 1 chart bar wide and sit hidden behind the current candle).
    boxL1 = OT1 + msTf1
    boxR1 = math.max(OT1 + 2 * msTf1, rT)
    boxL2 = OT2 + msTf2
    boxR2 = math.max(OT2 + 2 * msTf2, rT)
    boxL3 = OT3 + msTf3
    boxR3 = math.max(OT3 + 2 * msTf3, rT)
    drawTF(e1, H1, L1, OT1, boxL1, boxR1, rT, rT, rT, fill1, brd1, w1, tfToLabel(tf1))
    drawTF(e2, H2, L2, OT2, boxL2, boxR2, rT, rT, rT, fill2, brd2, w2, tfToLabel(tf2))
    drawTF(e3, H3, L3, OT3, boxL3, boxR3, rT, rT, rT, fill3, brd3, w3, tfToLabel(tf3))

// ============================================================
// COUNTDOWN TABLE
// ============================================================
activeCount = (e1 ? 1 : 0) + (e2 ? 1 : 0) + (e3 ? 1 : 0)
totalRows   = 3 + activeCount  // Title + Subtitle + Header + N active TFs

var table tbl = na
if showTimer and na(tbl) and activeCount > 0
    tbl := table.new(getPos(timerPos), 2, totalRows,
       bgcolor      = colTimerBg,
       frame_color  = color.new(color.gray, 50),
       frame_width  = 1,
       border_color = color.new(color.gray, 70),
       border_width = 1)

if barstate.islast and showTimer and activeCount > 0
    color hdrBg      = color.new(#2a2a2a, 0)
    color subtitleBg = hdrBg
    color subtitleCl = color.new(color.white, 25)

    // Chart-Typ prüfen → Warnmeldung statt Brand-Name bei Non-Standard-Charts
    string subtitleText = "NQAlphaSignals.com"
    bool   isStdChart   = chart.is_standard
    if not isStdChart
        string chartTypeName = chart.is_heikinashi ? "Heikin Ashi" :
                               chart.is_renko      ? "Renko"       :
                               chart.is_kagi       ? "Kagi"        :
                               chart.is_pnf        ? "Point & Figure" :
                               chart.is_linebreak  ? "Line Break"  :
                               chart.is_range      ? "Range Bars"  :
                                                     "Non-Standard"
        subtitleText := "⛔ Needs Candles (now: " + chartTypeName + ")"
        subtitleCl   := color.white
        subtitleBg   := color.new(color.red, 30)

    // Row 0: Title "Multi Timeframe Pro vX.X" — centered across both columns
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 0, "Multi Timeframe Pro " + VERSION, text_color = color.white, text_size = getSize(timerSize), bgcolor = hdrBg, text_halign = text.align_center)

    // Row 1: Subtitle / Brand OR Warnung bei Non-Standard-Chart
    table.merge_cells(tbl, 0, 1, 1, 1)
    table.cell(tbl, 0, 1, subtitleText, text_color = subtitleCl, text_size = getSize(timerSize), bgcolor = subtitleBg, text_halign = text.align_center)

    // Row 2: Column header
    table.cell(tbl, 0, 2, "Last TF",     text_color = colTimerTx, text_size = getSize(timerSize), bgcolor = color.new(color.gray, 60))
    table.cell(tbl, 1, 2, "Next update", text_color = colTimerTx, text_size = getSize(timerSize), bgcolor = color.new(color.gray, 60))

    // From row 3: only active TFs
    int row = 3
    if e1
        table.cell(tbl, 0, row, tfToLabel(tf1), text_color = brd1, text_size = getSize(timerSize))
        table.cell(tbl, 1, row, fmtHMS(math.max(0, math.floor((end1 - timenow) / 1000))), text_color = colTimerTx, text_size = getSize(timerSize))
        row := row + 1
    if e2
        table.cell(tbl, 0, row, tfToLabel(tf2), text_color = brd2, text_size = getSize(timerSize))
        table.cell(tbl, 1, row, fmtHMS(math.max(0, math.floor((end2 - timenow) / 1000))), text_color = colTimerTx, text_size = getSize(timerSize))
        row := row + 1
    if e3
        table.cell(tbl, 0, row, tfToLabel(tf3), text_color = brd3, text_size = getSize(timerSize))
        table.cell(tbl, 1, row, fmtHMS(math.max(0, math.floor((end3 - timenow) / 1000))), text_color = colTimerTx, text_size = getSize(timerSize))
        row := row + 1

// ============================================================
// ALERTS — fire automatically when enabled in the indicator
// ============================================================
// Conditions per TF
// Line crossing  = close crosses H or L in either direction
// Bar OUTSIDE    = close moves from inside [L,H] to outside (above H or below L)
// Bar INSIDE     = close moves from outside back inside [L,H]
cross1   = e1 and (ta.cross(close, H1) or ta.cross(close, L1))
outNew1  = e1 and ((close > H1 and close[1] <= H1) or (close < L1 and close[1] >= L1))
inNew1   = e1 and ((close <= H1 and close[1] > H1) or (close >= L1 and close[1] < L1))

cross2   = e2 and (ta.cross(close, H2) or ta.cross(close, L2))
outNew2  = e2 and ((close > H2 and close[1] <= H2) or (close < L2 and close[1] >= L2))
inNew2   = e2 and ((close <= H2 and close[1] > H2) or (close >= L2 and close[1] < L2))

cross3   = e3 and (ta.cross(close, H3) or ta.cross(close, L3))
outNew3  = e3 and ((close > H3 and close[1] <= H3) or (close < L3 and close[1] >= L3))
inNew3   = e3 and ((close <= H3 and close[1] > H3) or (close >= L3 and close[1] < L3))

// Triggers (only when toggled on in the indicator)
if a1Cross and cross1
    alert(tfToLabel(tf1) + ": Line crossing", alert.freq_once_per_bar_close)
if a1Out and outNew1
    alert(tfToLabel(tf1) + ": Bar closes outside the box (close " + str.tostring(close, format.mintick) + ")", alert.freq_once_per_bar_close)
if a1In and inNew1
    alert(tfToLabel(tf1) + ": Bar closes inside the box (close " + str.tostring(close, format.mintick) + ")", alert.freq_once_per_bar_close)

if a2Cross and cross2
    alert(tfToLabel(tf2) + ": Line crossing", alert.freq_once_per_bar_close)
if a2Out and outNew2
    alert(tfToLabel(tf2) + ": Bar closes outside the box (close " + str.tostring(close, format.mintick) + ")", alert.freq_once_per_bar_close)
if a2In and inNew2
    alert(tfToLabel(tf2) + ": Bar closes inside the box (close " + str.tostring(close, format.mintick) + ")", alert.freq_once_per_bar_close)

if a3Cross and cross3
    alert(tfToLabel(tf3) + ": Line crossing", alert.freq_once_per_bar_close)
if a3Out and outNew3
    alert(tfToLabel(tf3) + ": Bar closes outside the box (close " + str.tostring(close, format.mintick) + ")", alert.freq_once_per_bar_close)
if a3In and inNew3
    alert(tfToLabel(tf3) + ": Bar closes inside the box (close " + str.tostring(close, format.mintick) + ")", alert.freq_once_per_bar_close)

// ============================================================
// VWAP — anchored, with mid line and configurable bands
// ============================================================
cumVol = ta.cum(volume)
if showVwap and barstate.islast and cumVol == 0
    runtime.error("No volume data available for VWAP on this symbol.")

// request.*-Aufrufe MÜSSEN außerhalb von switch/if stehen (Pine v5 Einschränkung)
ne_act = request.earnings(syminfo.tickerid, earnings.actual,       barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
ne_std = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
nd_val = request.dividends(syminfo.tickerid, dividends.gross,      barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)
ns_val = request.splits(syminfo.tickerid,    splits.denominator,   barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol = true)

isNewVwapPeriod = switch vwapAnchor
    "Earnings"  => not na(ne_act) or not na(ne_std)
    "Dividends" => not na(nd_val)
    "Splits"    => not na(ns_val)
    "Session"   => timeframe.change("D")
    "Week"      => timeframe.change("W")
    "Month"     => timeframe.change("M")
    "Quarter"   => timeframe.change("3M")
    "Year"      => timeframe.change("12M")
    "Decade"    => timeframe.change("12M") and year % 10 == 0
    "Century"   => timeframe.change("12M") and year % 100 == 0
    => false

isEsdAnchor = vwapAnchor == "Earnings" or vwapAnchor == "Dividends" or vwapAnchor == "Splits"
if na(vwapSrc[1]) and not isEsdAnchor
    isNewVwapPeriod := true

float vwapVal = na
float upB1 = na, float lwB1 = na
float upB2 = na, float lwB2 = na

if showVwap
    [v_, stdevUp_, _] = ta.vwap(vwapSrc, isNewVwapPeriod, 1)
    vwapVal := v_
    stdevAbs = stdevUp_ - v_
    basis    = bandMode == "Standard Deviation" ? stdevAbs : v_ * 0.01
    upB1 := v_ + basis * bandMult1
    lwB1 := v_ - basis * bandMult1
    upB2 := v_ + basis * bandMult2
    lwB2 := v_ - basis * bandMult2

// Style-Helfer (Pine kennt für plot() kein natives "dashed" → bar_index-Trick)
// Muster: 2 von 3 Bars zeichnen → 2-Bar-Strich, 1-Bar-Lücke (= enger Dashed-Look)
applyDash(val, styleStr) =>
    styleStr == "Dashed" ? (bar_index % 3 < 2 ? val : na) : val

plotKind(styleStr) =>
    styleStr == "Dotted" ? plot.style_circles :
     styleStr == "Dashed" ? plot.style_linebr :
     plot.style_line

displayVw = showVwap ? display.all : display.none
displayB1 = (showVwap and showBand1) ? display.all : display.none
displayB2 = (showVwap and showBand2) ? display.all : display.none

// Mid line (VWAP)
plot(applyDash(vwapVal, vwapStyle), title = "VWAP",            color = vwapColor, linewidth = vwapWidth, style = plotKind(vwapStyle), display = displayVw)

// Outer lines (bands) — kein Hintergrund-Fill
plot(applyDash(upB1, bandStyle), title = "VWAP Upper Band 1", color = band1Color, linewidth = bandWidth, style = plotKind(bandStyle), display = displayB1)
plot(applyDash(lwB1, bandStyle), title = "VWAP Lower Band 1", color = band1Color, linewidth = bandWidth, style = plotKind(bandStyle), display = displayB1)
plot(applyDash(upB2, bandStyle), title = "VWAP Upper Band 2", color = band2Color, linewidth = bandWidth, style = plotKind(bandStyle), display = displayB2)
plot(applyDash(lwB2, bandStyle), title = "VWAP Lower Band 2", color = band2Color, linewidth = bandWidth, style = plotKind(bandStyle), display = displayB2)
````
