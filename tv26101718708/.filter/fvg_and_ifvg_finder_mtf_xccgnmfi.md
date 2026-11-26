# FVG and iFVG Finder (MTF)

- url: https://www.tradingview.com/script/xccGnMfi-FVG-and-iFVG-Finder-MTF/
- type: indicator
- pine_id: PUB;8967cea7774b432d9b5b6b3924376634
- version: 1.0

## Description

FVG + iFVG — Multi-Timeframe
Plots Fair Value Gaps (FVGs) and their inverse counterparts (iFVGs) across up to 5 independently configurable timeframes at once. When price closes through the far side of an active FVG, the zone's polarity flips — the old FVG becomes an iFVG in the opposite direction, acting as resistance if it was support and vice versa. A second close through the iFVG removes it.
How it detects an FVG
Standard 3-bar imbalance: a bullish FVG forms when low[1] > high[3] (the gap between bar 1's low and bar 3's high), bearish when high[1] < low[3]. The gap is drawn as a box from the formation bar forward.
How the inversion works
Each tracked zone carries both its original direction and an "inverted?" flag. The effective direction a zone acts as is original XOR inverted:

Active bull FVG → bullish zone; filled when price closes below the bottom
Bull FVG inverted to iFVG → bearish zone; filled when price closes above the top
Active bear FVG → bearish zone; filled when price closes above the top
Bear FVG inverted to iFVG → bullish zone; filled when price closes below the bottom

Features

5 independent timeframe slots (Chart, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, D, W, M)
Automatic FVG → iFVG conversion with polarity flip on close-through
Per-timeframe labels and colors
Two fill modes: Close (inversion semantic) or H/L (wick touch)
Wait-for-close option to prevent realtime flickering
Option to hide lower-than-chart timeframes (on by default)
Borderless boxes by default, full border/style/width control available
Extend-right option to keep active FVGs visible until filled
Age-out: FVGs older than N bars (up to 5000) are pruned automatically
Labels can be renamed per timeframe to match your workflow (e.g. "15m FVG", "4h iFVG")

Settings

Timeframes — enable/disable each of the 5 slots and pick the period
FVG Settings — show/hide FVGs and iFVGs independently, fill mode, wait-for-close toggle, max-bars-back
Label Settings — custom text per timeframe for FVG and iFVG labels
Box Settings — fixed length vs extend-right, per-type background colors, delete-on-fill behavior
Border Settings — style (solid/dotted/dashed), width (default 0 = borderless), per-type border colors

Notes

Timeframes lower than the chart are skipped by default since they'd be pixel-dense and mostly noise
HTF gaps are mapped back to the chart bar that aligns with the HTF formation bar open
The box for an iFVG spans from the original FVG formation bar to the bar where inversion occurred — it visually captures the full lifecycle

Credits
Concept inspired by Nephew_Sam_'s FVG/iFVG indicator. Code is an original implementation — the iFVG polarity-flip logic, HTF alignment, and state tracking are written from scratch.

## Source Code

````pine
//@version=5
// =============================================================================
// FVG + iFVG — Multi-Timeframe
// =============================================================================
// Plots Fair Value Gaps and their inverse counterparts (iFVGs) across up to 5
// user-selectable timeframes, with live fill/inversion tracking.
//
// FVG detection (3-bar imbalance, detected on bar X at bars X-3, X-2, X-1):
//   Bullish:  low[1] > high[3]   zone = [high[3], low[1]]
//   Bearish:  high[1] < low[3]   zone = [high[1], low[3]]
//
// iFVG logic:
//   When price closes through an active FVG's far boundary, the FVG is
//   consumed and its role FLIPS polarity:
//     Bull FVG closed below its bot  -> becomes bearish iFVG (resistance)
//     Bear FVG closed above its top  -> becomes bullish iFVG (support)
//   The iFVG keeps the same zone but the opposite direction for invalidation.
//   A second close through the iFVG removes it from the chart.
//
// Inspired by Nephew_Sam_'s FVG/iFVG indicator. Original implementation.
// =============================================================================
indicator("FVG and iFVG Finder (MTF)",
     shorttitle        = "FVG and iFVG Finder",
     overlay           = true,
     max_boxes_count   = 500,
     max_labels_count  = 500,
     max_lines_count   = 500,
     max_bars_back     = 5000)

// =============================================================================
// INPUTS
// =============================================================================

// --- Timeframes -------------------------------------------------------------
gTf = "Timeframes"
tfOptions = "Chart,1,3,5,15,30,60,120,240,D,W,M"

tf1_on = input.bool(true,  "TF1", inline = "tf1", group = gTf)
tf1    = input.string("Chart", "", inline = "tf1", group = gTf,
     options = ["Chart","1","3","5","15","30","60","120","240","D","W","M"])

tf2_on = input.bool(false, "TF2", inline = "tf2", group = gTf)
tf2    = input.string("15", "", inline = "tf2", group = gTf,
     options = ["Chart","1","3","5","15","30","60","120","240","D","W","M"])

tf3_on = input.bool(false, "TF3", inline = "tf3", group = gTf)
tf3    = input.string("60", "", inline = "tf3", group = gTf,
     options = ["Chart","1","3","5","15","30","60","120","240","D","W","M"])

tf4_on = input.bool(false, "TF4", inline = "tf4", group = gTf)
tf4    = input.string("240", "", inline = "tf4", group = gTf,
     options = ["Chart","1","3","5","15","30","60","120","240","D","W","M"])

tf5_on = input.bool(false, "TF5", inline = "tf5", group = gTf)
tf5    = input.string("D", "", inline = "tf5", group = gTf,
     options = ["Chart","1","3","5","15","30","60","120","240","D","W","M"])

// --- FVG Settings -----------------------------------------------------------
gFvg = "FVG Settings"
waitForClose = input.bool(false, "Wait for candle close to identify FVGs?",
     tooltip = "If on, only detect FVGs on confirmed (closed) bars. Prevents flickering on the realtime bar.",
     group = gFvg)
hideLowerTfs = input.bool(true, "Hide FVGs lower than current chart TF?",
     tooltip = "Skip drawing FVGs from timeframes smaller than the current chart. They'd be cluttered/pointless at this resolution.",
     group = gFvg)
showFvg   = input.bool(true,  "Show FVG",  group = gFvg)
showIfvg  = input.bool(true,  "Show iFVG", group = gFvg)
filledType = input.string("Close", "Filled FVG Type",
     options = ["Close", "H/L"],
     tooltip = "Close = FVG is filled only when close crosses the far boundary (inversion semantic). H/L = filled when wick touches.",
     group = gFvg)
maxBarsBack = input.int(3000, "Max bars back to find FVGs",
     minval = 10, maxval = 5000,
     tooltip = "Hard limit is 5000 (Pine Script's max_bars_back ceiling). FVGs older than this are aged out; HTF bar alignment also scans up to this many bars. Higher values cost more performance.",
     group = gFvg)

// --- Label Settings ---------------------------------------------------------
gLbl = "Label Settings"
showLabels    = input.bool(true, "Show Labels?", group = gLbl)
labelDistance = input.int(10, "Label Distance (Extend option only)",
     minval = 0, group = gLbl)
tf1_fvg_l  = input.string("FVG",      "TF1", inline = "tf1l", group = gLbl)
tf1_ifvg_l = input.string("iFVG",     "",    inline = "tf1l", group = gLbl)
tf2_fvg_l  = input.string("15m FVG",  "TF2", inline = "tf2l", group = gLbl)
tf2_ifvg_l = input.string("15m iFVG", "",    inline = "tf2l", group = gLbl)
tf3_fvg_l  = input.string("1h FVG",   "TF3", inline = "tf3l", group = gLbl)
tf3_ifvg_l = input.string("1h iFVG",  "",    inline = "tf3l", group = gLbl)
tf4_fvg_l  = input.string("4h FVG",   "TF4", inline = "tf4l", group = gLbl)
tf4_ifvg_l = input.string("4h iFVG",  "",    inline = "tf4l", group = gLbl)
tf5_fvg_l  = input.string("D FVG",    "TF5", inline = "tf5l", group = gLbl)
tf5_ifvg_l = input.string("D iFVG",   "",    inline = "tf5l", group = gLbl)

// --- Box Settings -----------------------------------------------------------
gBox = "Box Settings"
deleteFilled = input.bool(true,  "Delete Boxes after fill?",
     tooltip = "Only applies when 'Show iFVG' is OFF. On = delete the box immediately on fill. Off = keep the filled box visible but stop checking it. When 'Show iFVG' is ON, the box is always converted to iFVG regardless of this setting.",
     group = gBox)
extendBoxes  = input.bool(false, "Extend Boxes?",
     tooltip = "On = boxes extend right until filled. Off = fixed length.",
     group = gBox)
boxLen       = input.int(20, "Length of Boxes", minval = 1, group = gBox)
fvgBullBg    = input.color(color.new(#22c55e, 75), "FVG:  Bullish", inline = "fvgbg", group = gBox)
fvgBearBg    = input.color(color.new(#ef4444, 75), "| Bearish",     inline = "fvgbg", group = gBox)
ifvgBullBg   = input.color(color.new(#3b82f6, 75), "iFVG: Bullish", inline = "ifvgbg", group = gBox)
ifvgBearBg   = input.color(color.new(#f59e0b, 75), "| Bearish",     inline = "ifvgbg", group = gBox)

// --- Border Settings --------------------------------------------------------
gBr = "Border Settings"
borderStyleStr = input.string("Solid", "Border style",
     options = ["Solid", "Dotted", "Dashed"], group = gBr)
borderWidth    = input.int(0, "Border Width", minval = 0, maxval = 5,
     tooltip = "Default is 0 (borderless). Increase to show borders using the colors below.",
     group = gBr)
fvgBullBr      = input.color(color.new(#22c55e, 30), "FVG:  Bullish", inline = "fvgbr",  group = gBr)
fvgBearBr      = input.color(color.new(#ef4444, 30), "| Bearish",     inline = "fvgbr",  group = gBr)
ifvgBullBr     = input.color(color.new(#3b82f6, 30), "iFVG: Bullish", inline = "ifvgbr", group = gBr)
ifvgBearBr     = input.color(color.new(#f59e0b, 30), "| Bearish",     inline = "ifvgbr", group = gBr)

borderStyleVal = borderStyleStr == "Solid"  ? line.style_solid :
                 borderStyleStr == "Dotted" ? line.style_dotted : line.style_dashed

// =============================================================================
// HELPERS
// =============================================================================

f_tfActual(tfStr) => tfStr == "Chart" ? timeframe.period : tfStr
f_tfSec(tfStr)    => timeframe.in_seconds(f_tfActual(tfStr))

chartSec   = timeframe.in_seconds(timeframe.period)
tf1_actual = f_tfActual(tf1), tf1_sec = f_tfSec(tf1)
tf2_actual = f_tfActual(tf2), tf2_sec = f_tfSec(tf2)
tf3_actual = f_tfActual(tf3), tf3_sec = f_tfSec(tf3)
tf4_actual = f_tfActual(tf4), tf4_sec = f_tfSec(tf4)
tf5_actual = f_tfActual(tf5), tf5_sec = f_tfSec(tf5)

// Hide FVGs from TFs smaller than chart TF
f_okToShow(tfSec) => not hideLowerTfs or tfSec >= chartSec

f_getLabel(tfIdx, isIfvg) =>
    switch tfIdx
        1 => isIfvg ? tf1_ifvg_l : tf1_fvg_l
        2 => isIfvg ? tf2_ifvg_l : tf2_fvg_l
        3 => isIfvg ? tf3_ifvg_l : tf3_fvg_l
        4 => isIfvg ? tf4_ifvg_l : tf4_fvg_l
        5 => isIfvg ? tf5_ifvg_l : tf5_fvg_l
        => "FVG"

// An iFVG is the opposite-polarity version of its original FVG.
//   Bull FVG (green) -> inverted -> Bearish iFVG (orange) — resistance
//   Bear FVG (red)   -> inverted -> Bullish iFVG (blue)   — support
f_getBg(isBull, isIfvg) =>
    isIfvg ? (isBull ? ifvgBearBg  : ifvgBullBg)
           : (isBull ? fvgBullBg   : fvgBearBg)

f_getBorder(isBull, isIfvg) =>
    isIfvg ? (isBull ? ifvgBearBr  : ifvgBullBr)
           : (isBull ? fvgBullBr   : fvgBearBr)

f_getLabelColor(isBull, isIfvg) =>
    effBull = isBull != isIfvg
    effBull ? color.new(#22c55e, 10) : color.new(#ef4444, 10)

// =============================================================================
// STATE — parallel arrays covering all tracked FVGs (active + iFVG) from all TFs
// =============================================================================
var array<box>   g_boxes    = array.new_box()
var array<label> g_labels   = array.new_label()
var array<int>   g_startBar = array.new_int()
var array<float> g_top      = array.new_float()
var array<float> g_bot      = array.new_float()
var array<bool>  g_isBull   = array.new_bool()   // original direction at formation
var array<bool>  g_isIfvg   = array.new_bool()   // has been inverted?
var array<int>   g_tfIdx    = array.new_int()    // which TF (1..5)

// =============================================================================
// DRAW / CONVERT / DELETE
// =============================================================================

f_drawNewFvg(startBar, top, bot, isBull, tfIdx) =>
    rightBar  = extendBoxes ? bar_index : startBar + boxLen
    extendVal = extendBoxes ? extend.right : extend.none

    box b = na
    if showFvg
        b := box.new(startBar, top, rightBar, bot,
             border_color = f_getBorder(isBull, false),
             bgcolor      = f_getBg(isBull, false),
             border_style = borderStyleVal,
             border_width = borderWidth,
             extend       = extendVal)

    label lbl = na
    if showFvg and showLabels
        mid  = (top + bot) / 2
        lblX = extendBoxes ? bar_index + labelDistance : startBar + boxLen - 1
        lbl := label.new(x = lblX, y = mid,
             text      = f_getLabel(tfIdx, false),
             style     = label.style_none,
             textcolor = f_getLabelColor(isBull, false),
             size      = size.small)

    array.push(g_boxes,    b)
    array.push(g_labels,   lbl)
    array.push(g_startBar, startBar)
    array.push(g_top,      top)
    array.push(g_bot,      bot)
    array.push(g_isBull,   isBull)
    array.push(g_isIfvg,   false)
    array.push(g_tfIdx,    tfIdx)

f_deleteAt(i) =>
    b   = array.get(g_boxes,  i)
    lbl = array.get(g_labels, i)
    if not na(b)
        box.delete(b)
    if not na(lbl)
        label.delete(lbl)
    array.remove(g_boxes,    i)
    array.remove(g_labels,   i)
    array.remove(g_startBar, i)
    array.remove(g_top,      i)
    array.remove(g_bot,      i)
    array.remove(g_isBull,   i)
    array.remove(g_isIfvg,   i)
    array.remove(g_tfIdx,    i)

f_convertToIfvg(i) =>
    isBull   = array.get(g_isBull,   i)
    tfIdx    = array.get(g_tfIdx,    i)
    b        = array.get(g_boxes,    i)
    lbl      = array.get(g_labels,   i)
    startBar = array.get(g_startBar, i)
    top      = array.get(g_top,      i)
    bot      = array.get(g_bot,      i)

    // --- Handle the box -----------------------------------------------------
    // On conversion, the box is stretched from its formation bar to the
    // current bar (the inversion bar). This captures the full FVG lifespan
    // in the iFVG rectangle.
    if showIfvg
        if na(b)
            // No existing box: create fresh, already spanning formation -> now.
            // iFVG boxes never use extend.right — they're frozen at inversion.
            b := box.new(startBar, top, bar_index, bot,
                 border_color = f_getBorder(isBull, true),
                 bgcolor      = f_getBg(isBull, true),
                 border_style = borderStyleVal,
                 border_width = borderWidth,
                 extend       = extend.none)
        else
            // Existing FVG box: re-style, freeze right edge, clear any extend.right.
            box.set_bgcolor(b,      f_getBg(isBull, true))
            box.set_border_color(b, f_getBorder(isBull, true))
            box.set_extend(b, extend.none)
            box.set_right(b, bar_index)
    else
        if not na(b)
            box.delete(b)
            b := na

    // --- Handle the label ---------------------------------------------------
    // Label rides along with the box's new right edge.
    if showIfvg and showLabels
        mid  = (top + bot) / 2
        lblX = extendBoxes ? bar_index + labelDistance : bar_index - 1
        if na(lbl)
            lbl := label.new(x = lblX, y = mid,
                 text      = f_getLabel(tfIdx, true),
                 style     = label.style_none,
                 textcolor = f_getLabelColor(isBull, true),
                 size      = size.small)
        else
            label.set_text(lbl,      f_getLabel(tfIdx, true))
            label.set_textcolor(lbl, f_getLabelColor(isBull, true))
            label.set_x(lbl, lblX)
    else
        if not na(lbl)
            label.delete(lbl)
            lbl := na

    array.set(g_boxes,  i, b)
    array.set(g_labels, i, lbl)
    array.set(g_isIfvg, i, true)

// =============================================================================
// DETECTION
// =============================================================================

canDetectNow = waitForClose ? barstate.isconfirmed : true

// --- Direct chart-TF detection (used when a TF equals the chart TF) ---------
// Detected on bar X, pattern at X-3, X-2, X-1
//   Bullish:  low[1] > high[3]   zone = [high[3], low[1]]
//   Bearish:  high[1] < low[3]   zone = [high[1], low[3]]

f_detectOnChart(tfIdx, enabled, tfSec, tfActual) =>
    if enabled and canDetectNow and tfActual == timeframe.period and f_okToShow(tfSec)
        if low[1] > high[3]
            f_drawNewFvg(bar_index[3], low[1], high[3], true, tfIdx)
        if high[1] < low[3]
            f_drawNewFvg(bar_index[3], low[3], high[1], false, tfIdx)

f_detectOnChart(1, tf1_on, tf1_sec, tf1_actual)
f_detectOnChart(2, tf2_on, tf2_sec, tf2_actual)
f_detectOnChart(3, tf3_on, tf3_sec, tf3_actual)
f_detectOnChart(4, tf4_on, tf4_sec, tf4_actual)
f_detectOnChart(5, tf5_on, tf5_sec, tf5_actual)

// --- HTF detection via request.security -------------------------------------
// Returns time-of-first-bar for the detected FVG (or na). Detecting "new FVG"
// on the LTF is done by watching for this time to change.
f_requestHtf(tf) =>
    request.security(syminfo.tickerid, tf,
         [
           low[1]  > high[3] and (not waitForClose or barstate.isconfirmed) ? time[3] : na,
           high[1] < low[3]  and (not waitForClose or barstate.isconfirmed) ? time[3] : na,
           high[3], low[1],  // bull zone: bot = high[3], top = low[1]
           low[3],  high[1]  // bear zone: top = low[3], bot = high[1]
         ],
         lookahead = barmerge.lookahead_off,
         gaps      = barmerge.gaps_off)

// Map an HTF bar time back to the LTF bar_index (linear scan up to maxBarsBack).
// Returns -1 if the target time is older than the scan window or not found.
f_findBarIdxAtTime(targetTime) =>
    result = -1
    if not na(targetTime)
        for i = 0 to maxBarsBack
            t_i = time[i]
            if na(t_i)
                break
            if t_i <= targetTime
                result := bar_index[i]
                break
    result

f_detectHtf(tfIdx, enabled, tfSec, tfActual) =>
    if enabled and tfSec > chartSec and f_okToShow(tfSec) and tfActual != timeframe.period
        [bT, brT, bBot, bTop, brTop, brBot] = f_requestHtf(tfActual)

        isNewBull = not na(bT)  and (na(bT[1])  or bT  != bT[1])
        isNewBear = not na(brT) and (na(brT[1]) or brT != brT[1])

        if isNewBull
            startIdx = f_findBarIdxAtTime(bT)
            if startIdx >= 0
                f_drawNewFvg(startIdx, bTop, bBot, true, tfIdx)
        if isNewBear
            startIdx = f_findBarIdxAtTime(brT)
            if startIdx >= 0
                f_drawNewFvg(startIdx, brTop, brBot, false, tfIdx)

f_detectHtf(1, tf1_on, tf1_sec, tf1_actual)
f_detectHtf(2, tf2_on, tf2_sec, tf2_actual)
f_detectHtf(3, tf3_on, tf3_sec, tf3_actual)
f_detectHtf(4, tf4_on, tf4_sec, tf4_actual)
f_detectHtf(5, tf5_on, tf5_sec, tf5_actual)

// =============================================================================
// FILL CHECK / CLEANUP / EXTEND MAINTENANCE
// =============================================================================
// For each active FVG or iFVG:
//   - Check age-out (older than maxBarsBack)
//   - Check fill (Close mode: close crosses boundary; H/L mode: wick touches)
//   - On fill: delete (if deleteFilled or if already iFVG) or convert to iFVG
//   - If extendBoxes is on, keep the label riding near the current bar
// =============================================================================
if array.size(g_boxes) > 0
    i = array.size(g_boxes) - 1
    while i >= 0
        startBar = array.get(g_startBar, i)
        top      = array.get(g_top,      i)
        bot      = array.get(g_bot,      i)
        isBull   = array.get(g_isBull,   i)
        isIfvg   = array.get(g_isIfvg,   i)

        removed = false

        // Age out
        if bar_index - startBar > maxBarsBack
            f_deleteAt(i)
            removed := true

        // Fill check
        // effectiveBull = the direction this zone currently acts as:
        //   active bull FVG              -> bullish zone, filled when price goes below bot
        //   bull FVG inverted to iFVG    -> bearish zone, filled when price goes above top
        //   active bear FVG              -> bearish zone, filled when price goes above top
        //   bear FVG inverted to iFVG    -> bullish zone, filled when price goes below bot
        if not removed
            effectiveBull = isBull != isIfvg
            isFilled = false
            if effectiveBull
                isFilled := filledType == "Close" ? close <= bot : low <= bot
            else
                isFilled := filledType == "Close" ? close >= top : high >= top

            if isFilled
                // Decision tree:
                //   showIfvg = true & still an FVG  -> convert to iFVG in place
                //   already an iFVG (re-invalidated) -> delete
                //   FVG filled but no iFVG tracking  -> respect deleteFilled
                if not isIfvg and showIfvg
                    f_convertToIfvg(i)
                else if isIfvg or deleteFilled
                    f_deleteAt(i)
                    removed := true
                else
                    // showIfvg=false and deleteFilled=false: keep visible,
                    // mark "consumed" so the fill check doesn't re-fire.
                    array.set(g_isIfvg, i, true)

        // When Extend Boxes is ON, keep the label riding near the current bar.
        // Boxes themselves use extend.right (set at creation) so TradingView
        // handles the visual extension automatically.
        // When Extend Boxes is OFF, boxes stay at their initial boxLen width
        // forever — nothing to update here.
        // iFVG boxes are frozen at the inversion bar in f_convertToIfvg.
        if not removed and not isIfvg and extendBoxes
            lbl = array.get(g_labels, i)
            if not na(lbl)
                label.set_x(lbl, bar_index + labelDistance)

        i := i - 1
````
