# Volume Profile Levels - POC, Value Area, HVP/LVP

- url: https://www.tradingview.com/script/mm1QOIcC/
- type: indicator
- pine_id: PUB;77e61c3c2b39406f9f76d993dcdbf88d
- version: 1.0

## Description

Volume Profile Levels — POC, Value Area, HVP/LVP

OVERVIEW

This indicator builds a fixed-range volume profile over a user-defined lookback window and extracts its key structural levels as horizontal lines: the Point of Control (POC), the Value Area boundaries (VAH/VAL), and local High/Low Volume Peaks (HVP/LVP). The goal is not the histogram itself but the levels it produces — clean, alertable support/resistance derived from where volume actually traded.

HOW IT WORKS

Volume distribution. For each bar in the lookback window, its volume is distributed evenly across the price bins that the bar's high–low range spans. The full range of the window is divided into a configurable number of rows.

POC and Value Area. The POC is the bin with the highest accumulated volume. The Value Area is expanded outward from the POC, adding the larger neighboring bin at each step, until the target percentage of total volume (70% by default) is covered.

HVP / LVP detection. A bin qualifies as a High Volume Peak when it is a local maximum and exceeds the bin average by a configurable multiplier. A Low Volume Peak is a local minimum below the average by a configurable multiplier. Up to six levels of each type are shown, ranked by volume.

MTF mode. The profile can be calculated on a higher timeframe while displayed on the current chart. In MTF mode the lookback is counted in higher-timeframe bars, and the histogram can be hidden automatically to keep the chart readable while the levels remain.

FEATURES

- Fixed-range volume profile with adjustable lookback, row count, and Value Area percentage
- POC, VAH/VAL, HVP, and LVP levels drawn as lines across the analyzed range
- Optional profile histogram on the right or left side of the chart
- Higher-timeframe profile calculation with automatic histogram hiding
- Three label modes: full text labels, minimal dots, or both
- Diagnostics table showing the profile's range, bin size, total volume, and level counts

ALERTS

All alerts use the generic alert() function: create one alert on the indicator with "Any alert() function call" and enable the events you want in the settings.

- POC / VAH / VAL cross (close crossing the level)
- HVP / LVP level cross (optional; can be noisy)
- SR Flip: after a level is broken, the alert fires if price retests the level with a wick within a configurable bar window while the close holds the breakout direction
- Value Area entry / exit

NOTES

- The profile is an approximation: volume is split evenly across each bar's range, as tick-level data is not available in Pine. Results depend on the chart timeframe and the lookback setting.
- Levels are recalculated on every bar, so they shift as the window rolls forward. This is a rolling analysis tool, not a fixed anchored profile.
- Works on any symbol that provides volume data.

## Source Code

````pine
//@version=6
// ============================================================================
//  Volume Profile Levels — POC, Value Area, HVP/LVP   v0.7
// ----------------------------------------------------------------------------
//  v0.6 -> v0.7 changelog
//    [FIX]  Removed label.style type keyword (CE10149) — switched to
//           automatic type inference without annotation.
//    [FEAT] Small-dot label workaround — style_circle renders a dot as large
//           as a candle even at size.tiny, so a true small dot is drawn using
//           text "●" + fully transparent background + text color only.
//    [LAYOUT] All dots are placed consistently at dotX = bar_index + 5
//           (just before the histogram). Cleans up the scattered v0.6
//           coordinates (rPOC / rVA / leftX).
// ============================================================================

indicator("Volume Profile Levels — POC, Value Area, HVP/LVP", shorttitle="VP Levels", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000)

// ─── Inputs ─────────────────────────────────────────────────────────────────
grpCalc   = "▣ Calculation (Volume Profile)"
lookback  = input.int(250, "Lookback Bars (Scope)", minval=20, maxval=5000, group=grpCalc,
     tooltip="In MTF mode, this is the bar count on the *higher timeframe*.")
numBins   = input.int(60,  "Price Rows (Bins)",     minval=20, maxval=200, group=grpCalc)
vaPercent = input.float(70.0, "Value Area %",       minval=10, maxval=95,  step=5, group=grpCalc)

grpMtf    = "▣ MTF (Switching)"
mtfTf     = input.timeframe("", "Timeframe (blank = current chart)", group=grpMtf)
mtfHistOff= input.bool(true, "Auto-hide histogram in MTF mode", group=grpMtf)

grpPeak   = "▣ HVP / LVP Detection"
hvpMult   = input.float(1.05, "HVP Threshold (above average x mult)", minval=1.0, maxval=3.0, step=0.05, group=grpPeak)
lvpMult   = input.float(0.50, "LVP Threshold (below average x mult)", minval=0.0, maxval=1.0, step=0.05, group=grpPeak)
maxLevels = input.int(6, "Max HVP/LVP Levels Shown (each)", minval=1, maxval=6, group=grpPeak)

grpView    = "▣ Display"
profSide   = input.string("right", "Profile Position", options=["right", "left"], group=grpView)
showProf   = input.bool(true,  "Profile Histogram", group=grpView)
profWidth  = input.int(80, "Profile Width (bars)", minval=20, maxval=300, group=grpView)
showPOC    = input.bool(true,  "POC", group=grpView)
showVAFill = input.bool(true,  "VA Fill (box)", group=grpView)
showVALine = input.bool(true,  "VA Lines (VAH/VAL dotted)", group=grpView)
showHVP    = input.bool(true,  "HVP Levels", group=grpView)
showLVP    = input.bool(true,  "LVP Levels", group=grpView)
labelStyle = input.string("Full", "Label Style",
     options=["Full", "Minimal (dot)", "Both", "None"], group=grpView,
     tooltip="Full: text + price / Minimal: small dot without text / Both: both at each end / None: nothing.")
showDiag   = input.bool(true,  "Diagnostics Table", group=grpView)

grpColor  = "▣ Colors"
cHVP      = input.color(color.new(#ef5350, 0),  "HVP",       group=grpColor)
cLVP      = input.color(color.new(#42a5f5, 0),  "LVP",       group=grpColor)
cPOC      = input.color(color.new(#ffca28, 0),  "POC",       group=grpColor)
cVAFill   = input.color(color.new(#9c27b0, 80), "VA Fill",   group=grpColor)
cVALine   = input.color(color.new(#9c27b0, 0),  "VA Line",   group=grpColor)
cProfHVP  = input.color(color.new(#ef5350, 55), "Profile (HVP side)", group=grpColor)
cProfLVP  = input.color(color.new(#42a5f5, 55), "Profile (LVP side)", group=grpColor)

grpAlert    = "▣ Alerts"
alertPOC_VA = input.bool(true,  "POC / VAH / VAL Touch",           group=grpAlert)
alertHVP    = input.bool(false, "HVP Level Touch (can be noisy)",  group=grpAlert)
alertLVP    = input.bool(false, "LVP Level Touch (can be noisy)",  group=grpAlert)
alertFlip   = input.bool(false, "SR Flip (POC/VAH/VAL retest)",    group=grpAlert)
alertVAZone = input.bool(false, "VA Entry / Exit",                 group=grpAlert)
flipWindow  = input.int(10, "SR Flip Retest Window (bars)", minval=1, maxval=50, group=grpAlert,
     tooltip="Flip succeeds if the level is wick-retested within this many bars after a breakout while the close holds the breakout direction.")

// ─── Helpers ────────────────────────────────────────────────────────────────
f_argmax(float[] arr) =>
    int idx = -1
    float mx = -1e308
    int n = array.size(arr)
    for i = 0 to n - 1
        float v = array.get(arr, i)
        if not na(v) and v > mx
            mx  := v
            idx := i
    idx

f_argmin(float[] arr) =>
    int idx = -1
    float mn = 1e308
    int n = array.size(arr)
    for i = 0 to n - 1
        float v = array.get(arr, i)
        if not na(v) and v < mn
            mn  := v
            idx := i
    idx

// ─── Profile Calculation ────────────────────────────────────────────────────
calc_profile(int lb, int nb, float vap, float hvm, float lvm) =>
    float top = high
    float bot = low
    for b = 1 to lb - 1
        float hi = high[b]
        float lo = low[b]
        if not na(hi)
            top := math.max(top, hi)
        if not na(lo)
            bot := math.min(bot, lo)

    float rng     = top - bot
    float binSize = rng > 0 ? rng / nb : na

    float maxV   = 0.0
    float totalV = 0.0
    float poc    = na
    float vah    = na
    float val_   = na
    float[] bins    = array.new<float>(nb, 0.0)
    float[] hvpRes  = array.new<float>(maxLevels, na)
    float[] lvpRes  = array.new<float>(maxLevels, na)

    if not na(binSize) and binSize > 0
        for b = 0 to lb - 1
            float h = high[b]
            float l = low[b]
            float v = volume[b]
            if not na(h) and not na(l) and not na(v) and v > 0
                int loB = math.max(0, math.min(nb - 1, int(math.floor((l - bot) / binSize))))
                int hiB = math.max(0, math.min(nb - 1, int(math.floor((h - bot) / binSize))))
                int span = hiB - loB + 1
                float vPer = v / span
                for k = loB to hiB
                    array.set(bins, k, array.get(bins, k) + vPer)

        totalV := array.sum(bins)
        float avgV = totalV / nb

        int pocIdx = f_argmax(bins)
        if pocIdx >= 0
            maxV := array.get(bins, pocIdx)
            poc  := bot + (pocIdx + 0.5) * binSize

            float targetV = totalV * vap / 100.0
            float accV = array.get(bins, pocIdx)
            int up = pocIdx
            int dn = pocIdx
            while accV < targetV and (up < nb - 1 or dn > 0)
                float upV = up < nb - 1 ? array.get(bins, up + 1) : -1.0
                float dnV = dn > 0       ? array.get(bins, dn - 1) : -1.0
                if upV >= dnV
                    up   += 1
                    accV += upV
                else
                    dn   -= 1
                    accV += dnV
            vah  := bot + (up + 1) * binSize
            val_ := bot + dn * binSize

            float[] hvpP = array.new<float>()
            float[] hvpV = array.new<float>()
            float[] lvpP = array.new<float>()
            float[] lvpV = array.new<float>()
            for i = 1 to nb - 2
                float pv = array.get(bins, i - 1)
                float cv = array.get(bins, i)
                float nv = array.get(bins, i + 1)
                float price = bot + (i + 0.5) * binSize
                if cv > pv and cv >= nv and cv > avgV * hvm
                    array.push(hvpP, price)
                    array.push(hvpV, cv)
                if cv < pv and cv <= nv and cv < avgV * lvm
                    array.push(lvpP, price)
                    array.push(lvpV, cv)

            float[] tmpHV = array.copy(hvpV)
            for shown = 0 to maxLevels - 1
                if array.size(tmpHV) > 0
                    int mIdx = f_argmax(tmpHV)
                    if mIdx >= 0 and array.get(tmpHV, mIdx) > 0
                        array.set(hvpRes, shown, array.get(hvpP, mIdx))
                        array.set(tmpHV, mIdx, -1.0)

            float[] tmpLV = array.copy(lvpV)
            for shown = 0 to maxLevels - 1
                if array.size(tmpLV) > 0
                    int mIdx = f_argmin(tmpLV)
                    if mIdx >= 0 and array.get(tmpLV, mIdx) < 1e19
                        array.set(lvpRes, shown, array.get(lvpP, mIdx))
                        array.set(tmpLV, mIdx, 1e20)

    [top, bot, binSize, maxV, totalV, poc, vah, val_, hvpRes, lvpRes, bins]

// ─── MTF Application ────────────────────────────────────────────────────────
string actualTf = mtfTf == "" ? timeframe.period : mtfTf
bool   isMtf    = mtfTf != "" and mtfTf != timeframe.period
string tfTag    = isMtf ? mtfTf : timeframe.period

[top, bot, binSize, maxV, totalV, poc, vah, val_, hvpRes, lvpRes, bins] =
     request.security(syminfo.tickerid, actualTf,
          calc_profile(lookback, numBins, vaPercent, hvpMult, lvpMult),
          barmerge.gaps_off, barmerge.lookahead_off)

bool effShowProf = showProf and not (isMtf and mtfHistOff)

// ─── Label Mode ─────────────────────────────────────────────────────────────
bool labelFull = labelStyle == "Full"     or labelStyle == "Both"
bool labelDot  = labelStyle == "Minimal (dot)" or labelStyle == "Both"

// ─── State (drawings + alerts) ──────────────────────────────────────────────
var box[]   drawBox = array.new<box>()
var line[]  drawLn  = array.new<line>()
var label[] drawLb  = array.new<label>()
var table   diagT   = table.new(position.top_left, 2, 11, bgcolor=color.new(color.black, 70), border_width=1)

// SR Flip state (for POC / VAH / VAL individually)
var int pocFlipBar = na, var int pocFlipDir = 0
var int vahFlipBar = na, var int vahFlipDir = 0
var int valFlipBar = na, var int valFlipDir = 0

f_clear() =>
    for b in drawBox
        box.delete(b)
    for l in drawLn
        line.delete(l)
    for lb_ in drawLb
        label.delete(lb_)
    array.clear(drawBox)
    array.clear(drawLn)
    array.clear(drawLb)

// ─── Label Drawing Helpers ──────────────────────────────────────────────────
f_drawLabel(int x, float y, string txt, color bgcol, color txtcol, bool isLeftSide) =>
    if labelFull
        style_ = isLeftSide ? label.style_label_right : label.style_label_left
        lb = label.new(x, y, txt, xloc=xloc.bar_index, style=style_, color=bgcol, textcolor=txtcol, size=size.tiny)
        array.push(drawLb, lb)

f_drawDot(int x, float y, color bgcol) =>
    if labelDot
        // Workaround: style_circle renders a dot as large as a candle even at
        // size.tiny, so a truly small dot is drawn using text "●" with a fully
        // transparent background and only textcolor enabled. style_label_left
        // draws to the left of its anchor, placing the dot ~1px inside the
        // right edge of the candles (just before the histogram).
        dot = label.new(x, y, "●", xloc=xloc.bar_index, style=label.style_label_left,
             color=color.new(bgcol, 100), textcolor=bgcol, size=size.tiny)
        array.push(drawLb, dot)

// ─── Drawing (one-shot on last bar) ─────────────────────────────────────────
int hvpCount = 0
int lvpCount = 0

if barstate.islast
    f_clear()

    if not na(binSize) and binSize > 0
        int leftX     = bar_index - lookback + 1
        int profStart = profSide == "right" ? bar_index + 5 : leftX
        int profEnd   = profStart + profWidth
        int linesEnd  = bar_index + 5
        int levelsEnd = profSide == "right" ? profStart : linesEnd
        int dotX      = bar_index + 5   // common anchor for all dots — just before the histogram

        float avgV = totalV / numBins

        // 1) Profile histogram
        if effShowProf and maxV > 0
            for i = 0 to numBins - 1
                float cv = array.get(bins, i)
                if cv > 0
                    int w = math.max(1, int(math.round(cv / maxV * profWidth)))
                    float yTop = bot + (i + 1) * binSize
                    float yBot = bot + i * binSize
                    color bc = cv > avgV * hvpMult ? cProfHVP : cProfLVP
                    b1 = box.new(profStart, yTop, profStart + w, yBot, border_color=na, bgcolor=bc, xloc=xloc.bar_index)
                    array.push(drawBox, b1)

        // 2) POC
        if showPOC and not na(poc)
            int rPOC = profSide == "right" ? profEnd : linesEnd
            ln = line.new(leftX, poc, rPOC, poc, xloc=xloc.bar_index, color=cPOC, width=2)
            array.push(drawLn, ln)
            // Full label (left side), dot (right side)
            f_drawLabel(leftX, poc, "POC " + str.tostring(poc, format.mintick), cPOC, color.black, true)
            f_drawDot(dotX,    poc, cPOC)

        // 3) Value Area
        if not na(vah) and not na(val_)
            int rVA = profSide == "right" ? profEnd : linesEnd
            if showVAFill
                vaBox = box.new(leftX, vah, rVA, val_, xloc=xloc.bar_index, border_color=na, bgcolor=cVAFill)
                array.push(drawBox, vaBox)
            if showVALine
                lnH = line.new(leftX, vah,  rVA, vah,  xloc=xloc.bar_index, color=cVALine, style=line.style_dotted)
                lnL = line.new(leftX, val_, rVA, val_, xloc=xloc.bar_index, color=cVALine, style=line.style_dotted)
                array.push(drawLn, lnH)
                array.push(drawLn, lnL)
                f_drawLabel(leftX, vah,  "VAH " + str.tostring(vah,  format.mintick), cVALine, color.white, true)
                f_drawLabel(leftX, val_, "VAL " + str.tostring(val_, format.mintick), cVALine, color.white, true)
                f_drawDot(dotX, vah,  cVALine)
                f_drawDot(dotX, val_, cVALine)

        // 4) HVP
        if showHVP
            for i = 0 to array.size(hvpRes) - 1
                float pr = array.get(hvpRes, i)
                if not na(pr)
                    hvpCount += 1
                    ln = line.new(leftX, pr, levelsEnd, pr, xloc=xloc.bar_index, color=color.new(cHVP, 20), width=1)
                    array.push(drawLn, ln)
                    // Full label (right side = levelsEnd), dot at dotX
                    f_drawLabel(levelsEnd, pr, "HVP " + str.tostring(pr, format.mintick), color.new(cHVP, 0), color.white, false)
                    f_drawDot(dotX, pr, color.new(cHVP, 0))

        // 5) LVP
        if showLVP
            for i = 0 to array.size(lvpRes) - 1
                float pr = array.get(lvpRes, i)
                if not na(pr)
                    lvpCount += 1
                    ln = line.new(leftX, pr, levelsEnd, pr, xloc=xloc.bar_index, color=color.new(cLVP, 20), width=1, style=line.style_dashed)
                    array.push(drawLn, ln)
                    f_drawLabel(levelsEnd, pr, "LVP " + str.tostring(pr, format.mintick), color.new(cLVP, 0), color.white, false)
                    f_drawDot(dotX, pr, color.new(cLVP, 0))

        // 6) Diagnostics table
        if showDiag
            table.clear(diagT, 0, 0, 1, 10)
            string tfLabel = isMtf ? "MTF " + mtfTf + " → " + timeframe.period : "Chart " + timeframe.period
            table.cell(diagT, 0, 0, "VP Levels v0.7", bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=size.small)
            table.cell(diagT, 1, 0, tfLabel,        bgcolor=color.new(isMtf ? color.purple : color.gray, 30), text_color=color.white, text_size=size.small)
            table.cell(diagT, 0, 1, "top",     text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 1, 1, str.tostring(top, format.mintick), text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 0, 2, "bot",     text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 1, 2, str.tostring(bot, format.mintick), text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 0, 3, "binSize", text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 1, 3, str.tostring(binSize, "#.##"), text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 0, 4, "totalV",  text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 1, 4, str.tostring(totalV, format.volume), text_color=color.gray, text_size=size.tiny)
            table.cell(diagT, 0, 5, "POC",     text_color=color.white, text_size=size.tiny)
            table.cell(diagT, 1, 5, na(poc)  ? "—" : str.tostring(poc,  format.mintick), text_color=cPOC, text_size=size.tiny)
            table.cell(diagT, 0, 6, "VAH",     text_color=color.white, text_size=size.tiny)
            table.cell(diagT, 1, 6, na(vah)  ? "—" : str.tostring(vah,  format.mintick), text_color=cVALine, text_size=size.tiny)
            table.cell(diagT, 0, 7, "VAL",     text_color=color.white, text_size=size.tiny)
            table.cell(diagT, 1, 7, na(val_) ? "—" : str.tostring(val_, format.mintick), text_color=cVALine, text_size=size.tiny)
            table.cell(diagT, 0, 8, "HVP Count", text_color=color.white, text_size=size.tiny)
            table.cell(diagT, 1, 8, str.tostring(hvpCount), text_color=cHVP, text_size=size.tiny)
            table.cell(diagT, 0, 9, "LVP Count", text_color=color.white, text_size=size.tiny)
            table.cell(diagT, 1, 9, str.tostring(lvpCount), text_color=cLVP, text_size=size.tiny)

// ─── Alerts (evaluated per bar, fired on last bar only) ─────────────────────
if barstate.islast and not na(binSize) and binSize > 0

    // (1) POC / VAH / VAL touch
    if alertPOC_VA
        if not na(poc)
            if close > poc and close[1] <= poc
                alert("[" + tfTag + "] POC Break UP — " + str.tostring(poc, format.mintick), alert.freq_once_per_bar_close)
            if close < poc and close[1] >= poc
                alert("[" + tfTag + "] POC Break DOWN — " + str.tostring(poc, format.mintick), alert.freq_once_per_bar_close)
        if not na(vah)
            if close > vah and close[1] <= vah
                alert("[" + tfTag + "] VAH Break UP — " + str.tostring(vah, format.mintick), alert.freq_once_per_bar_close)
            if close < vah and close[1] >= vah
                alert("[" + tfTag + "] VAH Break DOWN — " + str.tostring(vah, format.mintick), alert.freq_once_per_bar_close)
        if not na(val_)
            if close > val_ and close[1] <= val_
                alert("[" + tfTag + "] VAL Break UP — " + str.tostring(val_, format.mintick), alert.freq_once_per_bar_close)
            if close < val_ and close[1] >= val_
                alert("[" + tfTag + "] VAL Break DOWN — " + str.tostring(val_, format.mintick), alert.freq_once_per_bar_close)

    // (2) HVP level touch
    if alertHVP
        for i = 0 to array.size(hvpRes) - 1
            float lvl = array.get(hvpRes, i)
            if not na(lvl)
                if close > lvl and close[1] <= lvl
                    alert("[" + tfTag + "] HVP Break UP — " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar_close)
                if close < lvl and close[1] >= lvl
                    alert("[" + tfTag + "] HVP Break DOWN — " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar_close)

    // (3) LVP level touch
    if alertLVP
        for i = 0 to array.size(lvpRes) - 1
            float lvl = array.get(lvpRes, i)
            if not na(lvl)
                if close > lvl and close[1] <= lvl
                    alert("[" + tfTag + "] LVP Break UP — " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar_close)
                if close < lvl and close[1] >= lvl
                    alert("[" + tfTag + "] LVP Break DOWN — " + str.tostring(lvl, format.mintick), alert.freq_once_per_bar_close)

    // (4) SR Flip (POC / VAH / VAL)
    if alertFlip
        // POC
        if not na(poc)
            if close > poc and close[1] <= poc
                pocFlipBar := bar_index
                pocFlipDir := 1
            else if close < poc and close[1] >= poc
                pocFlipBar := bar_index
                pocFlipDir := -1
            if not na(pocFlipBar)
                int barsSince = bar_index - pocFlipBar
                if barsSince > 0 and barsSince <= flipWindow
                    bool wickTouch = low <= poc and poc <= high
                    bool flipUp = pocFlipDir == 1  and wickTouch and close > poc
                    bool flipDn = pocFlipDir == -1 and wickTouch and close < poc
                    if flipUp
                        alert("[" + tfTag + "] POC SR Flip (now support) — " + str.tostring(poc, format.mintick), alert.freq_once_per_bar_close)
                        pocFlipBar := na
                        pocFlipDir := 0
                    if flipDn
                        alert("[" + tfTag + "] POC SR Flip (now resistance) — " + str.tostring(poc, format.mintick), alert.freq_once_per_bar_close)
                        pocFlipBar := na
                        pocFlipDir := 0
                else if barsSince > flipWindow
                    pocFlipBar := na
                    pocFlipDir := 0
        // VAH
        if not na(vah)
            if close > vah and close[1] <= vah
                vahFlipBar := bar_index
                vahFlipDir := 1
            else if close < vah and close[1] >= vah
                vahFlipBar := bar_index
                vahFlipDir := -1
            if not na(vahFlipBar)
                int barsSince = bar_index - vahFlipBar
                if barsSince > 0 and barsSince <= flipWindow
                    bool wickTouch = low <= vah and vah <= high
                    bool flipUp = vahFlipDir == 1  and wickTouch and close > vah
                    bool flipDn = vahFlipDir == -1 and wickTouch and close < vah
                    if flipUp
                        alert("[" + tfTag + "] VAH SR Flip (now support) — " + str.tostring(vah, format.mintick), alert.freq_once_per_bar_close)
                        vahFlipBar := na
                        vahFlipDir := 0
                    if flipDn
                        alert("[" + tfTag + "] VAH SR Flip (now resistance) — " + str.tostring(vah, format.mintick), alert.freq_once_per_bar_close)
                        vahFlipBar := na
                        vahFlipDir := 0
                else if barsSince > flipWindow
                    vahFlipBar := na
                    vahFlipDir := 0
        // VAL
        if not na(val_)
            if close > val_ and close[1] <= val_
                valFlipBar := bar_index
                valFlipDir := 1
            else if close < val_ and close[1] >= val_
                valFlipBar := bar_index
                valFlipDir := -1
            if not na(valFlipBar)
                int barsSince = bar_index - valFlipBar
                if barsSince > 0 and barsSince <= flipWindow
                    bool wickTouch = low <= val_ and val_ <= high
                    bool flipUp = valFlipDir == 1  and wickTouch and close > val_
                    bool flipDn = valFlipDir == -1 and wickTouch and close < val_
                    if flipUp
                        alert("[" + tfTag + "] VAL SR Flip (now support) — " + str.tostring(val_, format.mintick), alert.freq_once_per_bar_close)
                        valFlipBar := na
                        valFlipDir := 0
                    if flipDn
                        alert("[" + tfTag + "] VAL SR Flip (now resistance) — " + str.tostring(val_, format.mintick), alert.freq_once_per_bar_close)
                        valFlipBar := na
                        valFlipDir := 0
                else if barsSince > flipWindow
                    valFlipBar := na
                    valFlipDir := 0

    // (5) VA zone entry / exit
    if alertVAZone and not na(vah) and not na(val_)
        bool inNow  = close   >= val_ and close   <= vah
        bool inPrev = close[1] >= val_ and close[1] <= vah
        if inNow and not inPrev
            alert("[" + tfTag + "] VA Entered — " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        if not inNow and inPrev
            alert("[" + tfTag + "] VA Exited — " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
````
