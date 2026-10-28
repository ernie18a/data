# Window Sniper FVG 

- url: https://www.tradingview.com/script/NV9RVaIL/
- type: indicator
- pine_id: PUB;a0cae8f5533e421f89a28fb6ca1a183e
- version: 2.0

## Description

# Window Sniper FVG [MTSY⁺] — TradingView Yayın Açıklaması (Taslak)

---

## OVERVIEW

**Window Sniper FVG** finds the *first* Fair Value Gap that forms inside any number of user-defined intraday time windows — and it does this on a timeframe completely independent from your chart's timeframe.

Most "session + FVG" tools on TradingView either (a) hard-code their sessions to a single well-known killzone setup, or (b) detect every FVG that occurs without anchoring them to a specific time window. This script does neither: it lets you define **up to three independent time windows** (start time, end time, color, and label — all freely editable), and inside each window it isolates the **single first FVG** that forms there — discarding any subsequent gaps in the same window. The result is a script equally useful for ICT-style Silver Bullet trading, for custom 4-hour candle opens, for session-open killzones on indices, or for any other recurring intraday window a trader wants to study.

## WHY THIS IS A MASHUP, AND WHY IT'S JUSTIFIED

This script combines two distinct mechanisms that, on their own, solve only half the problem traders actually face:

1. **Session/window visualization** — drawing a box or strip that marks when a custom time window is active on the chart (so the trader has a visual anchor for "this is the session I'm watching").
2. **First-gap-per-window detection** — a state machine that resets at the start of every new window and locks onto the first FVG formed inside it, running entirely inside `request.security()` so the detection timeframe (e.g., 5min or 15min) is independent of whatever timeframe the chart itself is displaying.

Neither piece is useful in isolation for this specific workflow: a session marker without FVG detection is just a colored box, and an FVG detector without session-awareness cannot tell a trader *which* gap, among dozens per day, is the one that matters for their specific time-of-day model. The combination is what turns this into a single coherent tool: open the chart, see the window, see the one gap that defines it.

## KEY FEATURES (what makes this different from existing FVG scripts)

- **Not limited to Silver Bullet** — the three windows ship with the ICT Silver Bullet defaults (London Open 03:00-04:00, NY AM 10:00-11:00, NY PM 14:00-15:00), but every session is a free-form time input. Use it for 4-hour candle opens, custom killzones, economic-release windows, or any other recurring intraday period — the underlying logic doesn't know or care that the defaults happen to be Silver Bullet hours.
- **First-gap-per-window, not every gap** — inside each active window, the script locks onto the first Fair Value Gap that forms and ignores every subsequent gap until the next window starts. This mirrors how ICT-style traders actually use a killzone: one defining imbalance per session, not a cluttered feed of every 3-candle gap.
- **Independent FVG detection timeframe** — the FVG search runs on a timeframe you choose (default 5 minutes), completely decoupled from your chart's timeframe. Stay on a 15min or 1H chart for your overall read, while the script quietly finds the first 5min (or 1min, or whatever you set) gap inside each window in the background.
- **Configurable time zone** — session times are evaluated against a UTC-offset you select (UTC-5 through UTC+9, including Istanbul/Moscow at UTC+3), so the tool isn't tied to New York sessions and works for traders centered on other markets.
- **Color-coded by window, bordered by direction** — each FVG's fill color matches the window it formed in (so you can tell at a glance which session produced it), while the border color and an optional arrow in the label indicate bullish vs. bearish direction.
- **Two distinct window visualization styles** — display windows as a price-hugging box that grows with the session's range ("Label" style), or as a fixed strip offset from price by a multiple of the daily ATR ("Top"/"Bottom" style) for a cleaner, less chart-intrusive look.

## HOW TO USE IT

1. Pick the time zone matching the market you trade (General settings).
2. Enable or disable each of the three windows and set their start/end time, color, and label text. The defaults are ICT Silver Bullet hours, but you can repurpose them for any recurring session.
3. Set the FVG detection timeframe (default 5min) — this is independent of your chart's timeframe.
4. Watch each active window: the first Fair Value Gap that forms inside it gets boxed, colored by window and bordered by direction, and extends right until either price mitigates it, the trading day ends, or a fixed bar count is reached (your choice).

## CREDITS

This script's window-marking visualization is built on an open-source killzone-box concept originally shared by **@joshuuu**, and its multi-timeframe "first gap per interval" detection architecture is adapted from the open-source **"Cozy 1st FVG [MMT]"** script. Both components were substantially rewritten and extended: the fixed automatic interval logic was replaced with fully user-configurable, independently toggleable time windows; a configurable time zone selector was added; the visual system (window-colored fills, direction-colored borders, auto-contrast label text, two distinct window display styles) is original work; and the two previously separate mechanisms were integrated into a single coherent first-gap-per-window pipeline. Thank you to both original authors for the groundwork.

## DISCLAIMER

This script is provided for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Fair Value Gaps and time-window analysis are descriptive tools for studying price behavior, not predictive signals or a guaranteed edge. Past behavior of price around these zones does not guarantee future results. Trade at your own risk.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Matisay
//@version=6
indicator("Window Sniper FVG", shorttitle="Window Sniper FVG [MTSY⁺]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

tzChoiceInput = input.string("UTC-4 (New York / EDT)", "Session Time Zone", options = ["UTC-5 (New York / EST)", "UTC-4 (New York / EDT)", "UTC-3 (Sao Paulo)", "UTC+0 (London / GMT)", "UTC+1 (Europe Winter)", "UTC+2 (Europe Summer)", "UTC+3 (Istanbul / Moscow)", "UTC+4 (Dubai)", "UTC+8 (Shanghai / Singapore)", "UTC+9 (Tokyo)"], group = "General", tooltip = "All window sessions (London/AM/PM) and the FVG detection below are evaluated using this time zone. Pick the offset that matches the market hours you trade. Note: fixed UTC offsets do not auto-adjust for DST - switch this manually if the underlying market changes clock.")

simple string sessionTz = switch tzChoiceInput
    "UTC-5 (New York / EST)"        => "UTC-5"
    "UTC-4 (New York / EDT)"        => "UTC-4"
    "UTC-3 (Sao Paulo)"             => "UTC-3"
    "UTC+0 (London / GMT)"          => "UTC+0"
    "UTC+1 (Europe Winter)"         => "UTC+1"
    "UTC+2 (Europe Summer)"         => "UTC+2"
    "UTC+3 (Istanbul / Moscow)"     => "UTC+3"
    "UTC+4 (Dubai)"                 => "UTC+4"
    "UTC+8 (Shanghai / Singapore)"  => "UTC+8"
    "UTC+9 (Tokyo)"                 => "UTC+9"
    => "UTC-4"

winFilter       = input.bool(true, "Show Windows", group = 'Window Settings')
winStyle        = input.string("Label", "Window Style", options = ["Label", "Top", "Bottom"], group = 'Window Settings')
vertLineStyle = input.string(defval = line.style_solid, title = 'Vertical Line Style', options = [line.style_solid, line.style_dotted, line.style_dashed], group = 'Window Settings')
tbHeightInput    = input.float(0.1, "Strip Height (x Daily ATR)", minval = 0.05, step = 0.05, group = "Window Settings", tooltip = "Height of the window strip/box as a fraction/multiple of the daily ATR. Applies to all three Window Styles (Label/Top/Bottom).")
tbOffsetInput    = input.float(0.06, "Offset from price (x Daily ATR)", minval = 0.0, step = 0.01, group = "Window Settings", tooltip = "Distance between price and the strip, as a multiple of the daily ATR. Applies to all three Window Styles (Label/Top/Bottom).")
tbLabelSizeInput = input.string("Tiny", "Label Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Window Settings", tooltip = "Applies to all three Window Styles (Label/Top/Bottom).")
tbAtrLenInput    = input.int(14, "Daily ATR Length", minval = 1, group = "Window Settings")
labelColorModeInput = input.string("Auto (B/W)", "Label Text Color", options = ["Auto (B/W)", "Manual"], group = "Window Settings", tooltip = "Applies to both the window labels above and the FVG labels below.")
labelColorManualInput = input.color(color.white, "Manual Color", group = "Window Settings")

// --- London Window ---
loSession = input.session("0300-0400", "Session", group = "London Window")
loColor = input.color(color.new(#ea7e7e, 80), "Color", group = "London Window")
loText  = input.string("London", "Label Text", group = "London Window")

// --- AM Window ---
amSession = input.session("1000-1100", "Session", group = "AM Window")
amColor = input.color(color.new(#6c66db, 80), "Color", group = "AM Window")
amText  = input.string("AM", "Label Text", group = "AM Window")

// --- PM Window ---
pmSession = input.session("1400-1500", "Session", group = "PM Window")
pmColor = input.color(color.new(#57b070, 80), "Color", group = "PM Window")
pmText  = input.string("PM", "Label Text", group = "PM Window")

getLabelSize(simple string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.tiny

getBrightness(color c) =>
    r = color.r(c)
    g = color.g(c)
    b = color.b(c)
    math.sqrt(r * r * 0.241 + g * g * 0.691 + b * b * 0.068)

blackOrWhite(color c) =>
    getBrightness(c) > 130 ? color.black : color.white

tbLabelSize = getLabelSize(tbLabelSizeInput)
dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(tbAtrLenInput))

var color winColor = color(na)
var bool inWin      = false
var string winText  = string(na)

if timeframe.in_seconds() < timeframe.in_seconds("60")
    if winFilter
        if not na(time(timeframe.period, loSession, timezone = sessionTz))
            inWin := true
            winColor := loColor
            winText := loText
        else if not na(time(timeframe.period, amSession, timezone = sessionTz))
            inWin := true
            winColor := amColor
            winText := amText
        else if not na(time(timeframe.period, pmSession, timezone = sessionTz))
            inWin := true
            winColor := pmColor
            winText := pmText
        else
            inWin := false
    else
        inWin := true

    // ===== Label mode (box hugging price, fixed ATR-based height) =====
    var box winBox = box(na)
    var line winStartLine = line(na)
    var line winEndLine = line(na)

    winLabelTextColor = labelColorModeInput == "Auto (B/W)" ? blackOrWhite(winColor) : labelColorManualInput

    if winStyle == "Label"
        if inWin and not inWin[1]
            labelNear = high + tbOffsetInput * dailyAtr
            labelFar  = labelNear + tbHeightInput * dailyAtr
            winBox := box.new(bar_index, labelFar, bar_index, labelNear, border_color = color.new(color.red, 100), bgcolor = winColor, text = winText, text_size = tbLabelSize, text_color = winLabelTextColor)
            winStartLine := line.new(bar_index, low, bar_index, box.get_top(winBox), color = winColor, style = vertLineStyle)
        if inWin[1]
            box.set_right(winBox, bar_index)
            labelNear2 = high + tbOffsetInput * dailyAtr
            labelFar2  = labelNear2 + tbHeightInput * dailyAtr
            if labelNear2 > box.get_bottom(winBox)
                box.set_bottom(winBox, labelNear2)
                box.set_top(winBox, labelFar2)
                line.set_y2(winStartLine, box.get_top(winBox))
        if inWin[1] and not inWin
            winEndLine := line.new(bar_index, box.get_bottom(winBox), bar_index, box.get_top(winBox), color = winColor, style = vertLineStyle)

    // ===== Top/Bottom mode (strip offset from price by a multiple of daily ATR) =====
    var box tbBox = box(na)
    var line tbStartLine = line(na)
    var line tbEndLine = line(na)

    if winStyle == "Top" or winStyle == "Bottom"
        isTop = winStyle == "Top"
        if inWin and not inWin[1]
            refPrice = isTop ? high : low
            stripNear = isTop ? refPrice + tbOffsetInput * dailyAtr : refPrice - tbOffsetInput * dailyAtr
            stripFar  = isTop ? stripNear + tbHeightInput * dailyAtr : stripNear - tbHeightInput * dailyAtr
            tbBox       := box.new(bar_index, stripFar, bar_index, stripNear, border_color = color.new(color.red, 100), bgcolor = winColor, text = winText, text_size = tbLabelSize, text_color = winLabelTextColor)
            tbStartLine := line.new(bar_index, refPrice, bar_index, stripFar, color = winColor, style = vertLineStyle)
        if inWin[1]
            box.set_right(tbBox, bar_index)
            refPrice2 = isTop ? high : low
            stripNear2 = isTop ? refPrice2 + tbOffsetInput * dailyAtr : refPrice2 - tbOffsetInput * dailyAtr
            stripFar2  = isTop ? stripNear2 + tbHeightInput * dailyAtr : stripNear2 - tbHeightInput * dailyAtr
            if (isTop and stripNear2 > box.get_bottom(tbBox)) or (not isTop and stripNear2 < box.get_top(tbBox))
                box.set_bottom(tbBox, isTop ? stripNear2 : stripFar2)
                box.set_top(tbBox, isTop ? stripFar2 : stripNear2)
        if inWin[1] and not inWin
            tbEndLine := line.new(bar_index, box.get_top(tbBox), bar_index, box.get_bottom(tbBox), color = winColor, style = vertLineStyle)

// ============================================================================
// FIRST FVG PER WINDOW - the detection state machine runs INSIDE
// request.security(), using native [2] history on the requested timeframe.
// Each of the three user-defined windows (London/AM/PM) is tracked
// independently; only the first FVG formed within each window is kept.
// ============================================================================

fvgTfInput   = input.timeframe("5", "FVG Timeframe", group = "First FVG", tooltip = "The timeframe to search for Fair Value Gaps.")
widthInput   = input.int(0, "Box Width (Bars)", minval = 0, group = "First FVG", tooltip = "Set to 0 for full extension (infinite right). Bars refer to the timeframe the FVG is detected on.")
maxFvgsInput = input.int(10, "Show Past X FVGs", minval = 1, group = "First FVG", tooltip = "Only the most recent X FVGs will be shown on the chart.")

fvgBullBorder = input.color(#089981, "Bullish Border (up FVG)", group = "First FVG")
fvgBearBorder = input.color(#f23645, "Bearish Border (down FVG)", group = "First FVG")
fvgFillOpacity = input.int(80, "Window Color Fill Opacity", minval = 0, maxval = 100, group = "First FVG", tooltip = "The box fill uses the same color as the window it formed in (London/AM/PM), at this opacity.")

fvgShowLabelInput = input.bool(true, "Show FVG Label", group = "First FVG Label")
fvgShowWinInLabel = input.bool(true, "Include Window Name in Label", group = "First FVG Label")
fvgShowArrowInLabel = input.bool(true, "Include Direction Arrow in Label", group = "First FVG Label")
fvgLabelPlacement = input.string("Inside Center", "Label Placement", options = ["Inside Left", "Inside Center", "Inside Right", "Right Outside"], group = "First FVG Label")
fvgLabelVAlignStr = input.string("Center", "Vertical Position", options = ["Top", "Center", "Bottom"], group = "First FVG Label")
fvgLabelSizeStr   = input.string("Small", "Text Size", options = ["Auto", "Tiny", "Small", "Normal", "Large"], group = "First FVG Label")
fvgLabelRightBars = input.int(50, "Right Offset (Bars)", minval = 0, group = "First FVG Label", tooltip = "Distance from the right edge when Label Placement = Right Outside")

fvgInsideTextHAlign = fvgLabelPlacement == "Inside Left" ? text.align_left : fvgLabelPlacement == "Inside Right" ? text.align_right : text.align_center
fvgInsideTextVAlign = fvgLabelVAlignStr == "Top"  ? text.align_top  : fvgLabelVAlignStr == "Bottom" ? text.align_bottom : text.align_center
fvgLabelSize         = fvgLabelSizeStr == "Auto"   ? size.auto : fvgLabelSizeStr == "Tiny" ? size.tiny : fvgLabelSizeStr == "Small" ? size.small : fvgLabelSizeStr == "Normal" ? size.normal : size.large

// --- Core MTF "first FVG per window" calculation, runs inside request.security ---
fvg_calc(simple string tz) =>
    loTime = time(timeframe.period, loSession, timezone = tz)
    amTime = time(timeframe.period, amSession, timezone = tz)
    pmTime = time(timeframe.period, pmSession, timezone = tz)

    inLoWin = winFilter and not na(loTime)
    inAmWin = winFilter and not na(amTime)
    inPmWin = winFilter and not na(pmTime)

    inAnyWindow = inLoWin or inAmWin or inPmWin
    winName     = inLoWin ? loText : inAmWin ? amText : inPmWin ? pmText : ""
    winId       = inLoWin ? 1 : inAmWin ? 2 : inPmWin ? 3 : 0

    newWindow = winId != winId[1]

    var bool   foundInWindow = false
    var int    currentFvgType = 0
    var float  currentTop     = 0.0
    var float  currentBottom  = 0.0
    var int    currentFvgT2   = 0
    var int    currentFvgT0   = 0
    var string currentWinName = ""
    var int    currentWinId   = 0

    if newWindow
        foundInWindow  := false
        currentFvgType := 0
        currentTop     := 0.0
        currentBottom  := 0.0
        currentFvgT2   := 0
        currentFvgT0   := 0
        currentWinName := ""
        currentWinId   := 0

    isWithinWindow = inAnyWindow and not na(time[2]) and winId == winId[2]
    isBullishFVG   = isWithinWindow and low > high[2]
    isBearishFVG   = isWithinWindow and high < low[2]

    if not foundInWindow and (isBullishFVG or isBearishFVG)
        foundInWindow  := true
        currentFvgType := isBullishFVG ? 1 : -1
        currentTop     := isBullishFVG ? low : low[2]
        currentBottom  := isBullishFVG ? high[2] : high
        currentFvgT2   := time[2]
        currentFvgT0   := time
        currentWinName := winName
        currentWinId   := winId

    [currentFvgType, currentTop, currentBottom, currentFvgT2, currentFvgT0, currentWinName, currentWinId]

// Fetch the persistent FVG state from the target timeframe
[fvgType, fvgTop, fvgBottom, fvgT2, fvgT0, fvgWinName, fvgWinId] = request.security(syminfo.tickerid, fvgTfInput, fvg_calc(sessionTz), lookahead = barmerge.lookahead_off)

// --- Drawing Logic ---
var box[]   fvgArray       = array.new_box()
var label[] fvgLabelArray  = array.new_label()
var int     lastDrawnFvgT2 = 0

// Calculate chart's current bar duration in milliseconds to properly offset right-side labels
int chartBarMs = nz(time - time[1], 60000)

if fvgType != 0 and fvgT2 != lastDrawnFvgT2
    lastDrawnFvgT2 := fvgT2

    // Fill color = the window the FVG formed in (matches the window strip color above).
    // Border color = bull/bear direction.
    color fvgFillBase = fvgWinId == 1 ? loColor : fvgWinId == 2 ? amColor : fvgWinId == 3 ? pmColor : color.gray
    color fvgCol       = color.new(fvgFillBase, fvgFillOpacity)
    color fvgBorder    = fvgType == 1 ? fvgBullBorder : fvgBearBorder
    color fvgTextColor = labelColorModeInput == "Auto (B/W)" ? blackOrWhite(fvgCol) : labelColorManualInput

    // Format the text: window name + "FVG" + direction arrow
    string fvgText = ""
    if fvgShowLabelInput
        string winStr   = fvgShowWinInLabel ? fvgWinName + " " : ""
        string arrowStr = fvgShowArrowInLabel ? (fvgType == 1 ? " ↑" : " ↓") : ""
        fvgText := winStr + "FVG" + arrowStr

    // Calculate box width in time
    int srcBarMs  = math.max(1, math.round((fvgT0 - fvgT2) / 2))
    int rightTime = widthInput > 0 ? fvgT2 + (widthInput * srcBarMs) : fvgT0

    // Create the box
    box fvgBox = box.new(
         left          = fvgT2,
         top           = fvgTop,
         right         = rightTime,
         bottom        = fvgBottom,
         bgcolor       = fvgCol,
         border_color  = fvgBorder,
         xloc          = xloc.bar_time,
         extend        = widthInput == 0 ? extend.right : extend.none,
         text          = fvgShowLabelInput and fvgLabelPlacement != "Right Outside" ? fvgText : "",
         text_color    = fvgTextColor,
         text_halign   = fvgInsideTextHAlign,
         text_valign   = fvgInsideTextVAlign,
         text_size     = fvgLabelSize
         )

    // Create the label if "Right Outside" is selected
    label fvgLbl = na
    if fvgShowLabelInput and fvgLabelPlacement == "Right Outside"
        float labelY = fvgLabelVAlignStr == "Top" ? fvgTop : fvgLabelVAlignStr == "Bottom" ? fvgBottom : (fvgTop + fvgBottom) / 2.0
        int   labelX = rightTime + (fvgLabelRightBars * chartBarMs)

        fvgLbl := label.new(
             x         = labelX,
             y         = labelY,
             xloc      = xloc.bar_time,
             yloc      = yloc.price,
             text      = fvgText,
             style     = label.style_none,
             color     = color.new(color.white, 100),
             textcolor = fvgTextColor,
             size      = fvgLabelSize
             )

    // Manage arrays to delete oldest drawings
    array.push(fvgArray, fvgBox)
    array.push(fvgLabelArray, fvgLbl)

    if array.size(fvgArray) > maxFvgsInput
        box.delete(array.shift(fvgArray))
        label oldLbl = array.shift(fvgLabelArray)
        if not na(oldLbl)
            label.delete(oldLbl)

// Keep "Right Outside" labels pinned to the live edge of the chart
if array.size(fvgLabelArray) > 0
    for i = 0 to array.size(fvgLabelArray) - 1
        label lbl = array.get(fvgLabelArray, i)
        if not na(lbl)
            label.set_x(lbl, time + (fvgLabelRightBars * chartBarMs))
````
