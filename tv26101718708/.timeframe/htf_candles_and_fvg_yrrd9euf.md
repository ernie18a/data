# HTF Candles and FVG

- url: https://www.tradingview.com/script/YRrd9eUf-HTF-Candles-and-FVG/
- type: indicator
- pine_id: PUB;965f0f18307140059a4d45e86d8f55bd
- version: 1.0

## Description

█ OVERVIEW
HTF Candles and FVG is a highly adaptive indicator that displays candles from a higher timeframe (HTF) directly on a lower-timeframe chart, together with automatically detected Fair Value Gap (FVG) zones.
Instead of switching between timeframes, the user can observe the higher-timeframe candle structure within the current chart layout. The indicator fetches data from the selected HTF and reconstructs its candles while preserving their real position in time.

One of the most important features of the indicator is its high visual flexibility. HTF candles can be displayed directly on the current price candles according to the real time axis, or as a separate candle strip placed beside the chart. This allows the indicator to serve both as a contextual tool and as a more classic HTF overlay.

In Manual layout, candle width can be set automatically from the relationship between the chart timeframe and the selected HTF, so it adapts without manual adjustment whenever the chart timeframe changes. For instruments with non-standard session hours, such as stocks or indices, the Auto-Align mode preserves correct candle boundaries by positioning each HTF candle at its real open and close time rather than a calculated width.

The second analytical layer consists of Fair Value Gaps detected on the higher-timeframe candles. FVGs are identified from a three-candle HTF pattern and are then visualized as zones that extend until they are mitigated.

The indicator also lets the user control how FVG mitigation is recognized — by wick or by close. This allows the definition of "gap fill" to be adjusted to the user's own analysis style.

High visual configurability also makes it possible to create a very minimalist layout. By adjusting the transparency of individual elements, the HTF candles, their bodies and wicks can be practically hidden, leaving mainly the higher-timeframe FVG zones on the price chart.

As a result, HTF Candles and FVG can be used both as a full visual higher-timeframe context and as a discreet tool for placing key FVG zones on the current chart.
https://www.tradingview.com/x/rJgoRwSb/

█ CONCEPTS
Higher Timeframe Candles
The core element of the indicator is the candles fetched from the selected higher timeframe.
The user can choose a timeframe ranging from short intraday intervals up to D, W and M. The indicator stores the HTF candle history and allows the number of most recent candles to be displayed to be specified.

Candles can be presented in two ways:

- Auto-Align — candles are placed according to their real position on the time axis.
- Manual Mode — candles are arranged as a separate sequence beside the chart, with adjustable width, gap and offset.

This solution allows the presentation style to be adapted to different analysis approaches.

Automatic Width
In Manual layout, the width of each HTF candle can be calculated automatically from the relationship between the chart timeframe and the HTF.
This means the user does not have to manually adjust candle width every time the chart timeframe is changed. In Auto-Align mode this setting does not apply, since candle width is instead derived directly from each candle's real open and close time.

Fair Value Gaps
FVGs are detected from three consecutive HTF candles.
A bullish FVG forms when the low of the third candle is above the high of the first candle. A bearish FVG forms when the high of the third candle is below the low of the first candle.
The FVG zone starts at the corresponding position of the middle candle and remains active until it is mitigated. If the gap has not been mitigated, the zone is kept up to the most recent position available within the displayed range.

FVG Mitigation
FVG mitigation can be defined in two ways:

- Wick — the zone is considered mitigated when the wick of a subsequent HTF candle enters the FVG range.
- Close — the zone is considered mitigated only when the close of an HTF candle enters the FVG range.

This gives the user a choice between a more reactive wick-based approach and a more restrictive close-based approach.

Forming HTF Candle
The indicator can also display the currently forming, still unclosed HTF candle.
This makes it possible to observe in real time how the current higher-timeframe candle develops together with successive lower-timeframe candles.

█ FEATURES
Higher Timeframe
- Higher Timeframe (HTF) – selection of the timeframe from which candles and FVG zones are fetched.
- Number of HTF Candles to Display – specifies how many of the most recent HTF candles are shown on the chart.

Candle Layout
- Automatic Width (Proportional to TF) – in Manual layout, automatically adjusts candle width according to the relationship between the chart timeframe and the selected HTF. Not used in Auto-Align mode, where candle width is derived from each candle's real open and close time.
- Manual Candle Width (bars) – sets the width of an HTF candle in manual mode.
- Auto-Align to Time Axis – places HTF candles at their real position on the time axis, using each candle's actual open and close time, instead of arranging them beside the chart. This keeps candle boundaries accurate even on instruments with non-standard session hours, such as stocks or indices.
- Gap Between Candles (manual mode only) – sets the gap between consecutive HTF candles in manual mode.
- Offset from Last Bar (manual mode only) – shifts the entire HTF candle strip relative to the last chart bar. Negative values allow the strip to be moved to the left.

Current Candle
- Show Forming (Unclosed) Candle – enables or disables the display of the currently forming, unfinished HTF candle.

Candle Appearance
- Bullish Color – colour of HTF candles that close above their open.
- Bearish Color – colour of HTF candles that close below their open.
- Candle Body Fill Transparency (%) – sets the transparency of the HTF candle body fill and of the candle wick.
- Candle Body Border Transparency (%) – sets the transparency of the HTF candle body border.

Wick Appearance
- Wick Line Width – sets the width of the HTF candle wick. Applies in both Manual and Auto-Align mode.

FVG — Fair Value Gap
- Show FVG on HTF Candles – enables or disables the display of Fair Value Gap zones detected on the selected HTF.
- Mitigation Source – defines how FVG mitigation is detected: Wick or Close.
- Bullish Gap Color (gap up) – colour of bullish FVGs.
- Bearish Gap Color (gap down) – colour of bearish FVGs.
- FVG Fill Transparency (%) – sets the transparency of the FVG box fill.
- FVG Border Transparency (%) – sets the transparency of the FVG box border.

Alerts
- Bullish FVG Formed – fires when a new bullish Fair Value Gap is detected on the HTF.
- Bearish FVG Formed – fires when a new bearish Fair Value Gap is detected on the HTF.
- Bullish FVG Mitigated – fires when an active bullish FVG is mitigated.
- Bearish FVG Mitigated – fires when an active bearish FVG is mitigated.

█ APPLICATIONS
Higher-Timeframe Context Analysis
HTF Candles and FVG allows the higher-timeframe structure to be observed without the need to switch the main chart to a different timeframe.
This makes it possible to analyse HTF behaviour while remaining on the lower timeframe used for more precise price observation.

HTF FVG Analysis
Higher-timeframe FVG zones can be used as additional context when analysing the current price movement.
Because each zone is kept until the mitigation condition is met, the user can observe both active and historical imbalance areas.

Minimalist FVG Chart
Independent control of the transparency of individual elements allows the indicator to be adjusted to a very minimalist style.
With appropriate transparency settings for the candle body fill (which also controls the wick), the body border, and the FVG zones, it is possible to leave essentially only the higher-timeframe FVG zones on the price chart.
This enables the indicator to be used as a discreet HTF analysis layer without obscuring the current price action.

Observing the Forming HTF Candle
Enabling the current, unfinished candle makes it possible to watch its development in real time and to assess how its range and direction change with the movement of the lower timeframe.

█ NOTES
- The indicator does not generate BUY/SELL signals. Its main purpose is to provide higher-timeframe context and to visualise HTF FVGs.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("HTF Candles and FVG", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// SETTINGS

htfRes       = input.timeframe("D", "Higher Timeframe (HTF)", options = ["1", "3", "5", "15", "30", "45", "60", "120", "180", "240","480","720", "D", "W", "M"],
     tooltip = "The timeframe from which candles (and FVGs) shown on the chart are fetched.")
candleCount  = input.int(50, "Number of HTF Candles to Display", minval = 1, maxval = 200,
     tooltip = "How many of the most recent higher-timeframe candles to draw on the chart.")

autoWidth    = input.bool(true, "Automatic Width (Proportional to TF)", tooltip = "In auto-align mode, each box's width is derived directly from the actual number of session bars, so this parameter is ignored.")
manualWidth  = input.int(2, "Manual Candle Width (bars)", minval = 1,
     tooltip = "Width of a single HTF candle expressed in bars of the current chart. Used in manual mode, when 'Automatic Width' is disabled.")

autoAlign    = input.bool(false, "Auto-Align to Time Axis", tooltip = "Draws HTF candles at their true position on the time axis instead of stacking them beside the chart. Candle width is derived from the actual session duration, which avoids overlap on instruments with sessions shorter than 24 hours (stocks, indices, etc.).")

gapBars      = input.int(1, "Gap Between Candles (manual mode only)", minval = 0,
     tooltip = "Gap in bars between consecutive HTF candles. Applied only in manual mode.")
rightOffset  = input.int(10, "Offset from Last Bar (manual mode only)", tooltip = "Can be negative to shift the entire HTF candle strip to the left (e.g., so it overlaps the most recent visible price bars).")

showCurrent  = input.bool(true, "Show Forming (Unclosed) Candle",
     tooltip = "If enabled, the currently forming HTF candle that has not yet closed is also displayed on the chart.")

upColor            = input.color(#26a69a, "Bullish Color",
     tooltip = "Color of the body and wick of a bullish candle (close above open).")
downColor          = input.color(#ef5350, "Bearish Color",
     tooltip = "Color of the body and wick of a bearish candle (close below open).")
candleTransparency = input.int(60, "Candle Body Fill Transparency (%)", minval = 0, maxval = 100,
     tooltip = "Transparency of the HTF candle body fill and of the wick line, in percent (0 = fully opaque, 100 = fully transparent).")
candleBorderTransparency = input.int(60, "Candle Body Border Transparency (%)", minval = 0, maxval = 100,
     tooltip = "Transparency of the HTF candle body border, in percent (0 = fully opaque, 100 = fully transparent).")

// WICK APPEARANCE

wickWidth = input.int(2, "Wick Line Width", minval = 1, maxval = 5,
     tooltip = "Line thickness of the HTF candle wick, in pixels. Applies in both manual and auto-align mode.")

// FVG (FAIR VALUE GAP) ON HTF CANDLES

showFVG              = input.bool(true, "Show FVG on HTF Candles", group = "FVG (Fair Value Gap)",
     tooltip = "Enables drawing of Fair Value Gaps detected between three consecutive HTF candles.")
fvgMitigationSource  = input.string("Close", "Mitigation Source", options = ["Wick", "Close"], group = "FVG (Fair Value Gap)",
     tooltip = "Wick: the gap is considered mitigated once the wick of a subsequent HTF candle enters its range. Close: the gap is mitigated only once the close of an HTF candle enters its range.")
fvgBullColor         = input.color(color.rgb(6, 162, 47), "Bullish Gap Color (gap up)", group = "FVG (Fair Value Gap)",
     tooltip = "Border and fill color of a bullish gap (gap up).")
fvgBearColor         = input.color(color.rgb(207, 23, 23), "Bearish Gap Color (gap down)", group = "FVG (Fair Value Gap)",
     tooltip = "Border and fill color of a bearish gap (gap down).")
fvgTransparency      = input.int(85, "FVG Fill Transparency (%)", minval = 0, maxval = 100, group = "FVG (Fair Value Gap)",
     tooltip = "Transparency of the FVG box fill, in percent.")
fvgBorderTransparency = input.int(85, "FVG Border Transparency (%)", minval = 0, maxval = 100, group = "FVG (Fair Value Gap)",
     tooltip = "Transparency of the FVG box border, in percent (0 = fully opaque, 100 = fully transparent).")

// TIME RATIO / WIDTH (manual mode only)

secPerChartBar = timeframe.in_seconds()
secPerHtfBar   = timeframe.in_seconds(htfRes)

tfRatio  = secPerChartBar > 0 ? secPerHtfBar / secPerChartBar : 1
barWidth = autoWidth ? math.max(1, math.round(tfRatio)) : manualWidth

// In auto-align mode candles are positioned by real time (xloc.bar_time), which removes the limit on how
// far bar_index can be from the current bar. In manual mode candles are positioned relative to the
// current bar's bar_index.
candleXloc = autoAlign ? xloc.bar_time : xloc.bar_index


// FETCHING DATA FROM THE HIGHER TIMEFRAME
//
// Only plain scalar series (float/int) are requested here; the rolling candle history is built and
// maintained separately in the main context using persistent `var` arrays below.

[htfO, htfH, htfL, htfC, htfT, htfTC] = request.security(syminfo.tickerid, htfRes, [open, high, low, close, time, time_close], lookahead = barmerge.lookahead_off)

maxKeep = 200 // matches the maxval of the "Number of HTF Candles to Display" parameter

var float[] htfOpen       = array.new_float()
var float[] htfHigh       = array.new_float()
var float[] htfLow        = array.new_float()
var float[] htfClose      = array.new_float()
var int[]   htfStamp      = array.new_int()
var int[]   htfCloseStamp = array.new_int()

// request.security() can momentarily return na for open/high/low/close/time/time_close (illiquid symbols,
// session gaps, newly listed instruments, etc.). Skip the bar entirely whenever any fetched value is na,
// so an incomplete read never gets pushed into the rolling arrays.
bool htfDataValid = not na(htfO) and not na(htfH) and not na(htfL) and not na(htfC) and not na(htfT) and not na(htfTC)

bool isNewBar = htfDataValid and (htfStamp.size() == 0 or htfStamp.get(htfStamp.size() - 1) != htfT)

if isNewBar
    htfOpen.push(htfO)
    htfHigh.push(htfH)
    htfLow.push(htfL)
    htfClose.push(htfC)
    htfStamp.push(htfT)
    htfCloseStamp.push(htfTC)
    if htfStamp.size() > maxKeep
        htfOpen.shift()
        htfHigh.shift()
        htfLow.shift()
        htfClose.shift()
        htfStamp.shift()
        htfCloseStamp.shift()
else if htfDataValid and htfStamp.size() > 0
    htfOpen.set(htfOpen.size() - 1, htfO)
    htfHigh.set(htfHigh.size() - 1, htfH)
    htfLow.set(htfLow.size() - 1, htfL)
    htfClose.set(htfClose.size() - 1, htfC)
    htfCloseStamp.set(htfCloseStamp.size() - 1, htfTC)


// ALERTS
//
// Active (not yet mitigated) FVGs are tracked independently from the visual rendering below, so alerts
// fire in real time on every bar rather than only when the display is redrawn at barstate.islast.

var float[] activeFvgTop    = array.new_float()
var float[] activeFvgBottom = array.new_float()
var bool[]  activeFvgIsBull = array.new_bool()

var int lastClosedHtfTime = na

bool fvgFormedBull    = false
bool fvgFormedBear    = false
bool fvgMitigatedBull = false
bool fvgMitigatedBear = false

htfCount = htfStamp.size()

// A new HTF bar has just closed when the timestamp of the last fully closed bar (the one before the
// currently forming bar) changes.
bool newHtfBarClosed = false
if htfCount >= 2
    int closedTime = htfStamp.get(htfCount - 2)
    if na(lastClosedHtfTime) or closedTime != lastClosedHtfTime
        newHtfBarClosed := true
        lastClosedHtfTime := closedTime

if newHtfBarClosed and htfCount >= 4
    cIdx = htfCount - 2
    aIdx = htfCount - 4

    cHigh  = htfHigh.get(cIdx)
    cLow   = htfLow.get(cIdx)
    cClose = htfClose.get(cIdx)
    aHigh  = htfHigh.get(aIdx)
    aLow   = htfLow.get(aIdx)

    // 1) Mitigation check: does the newly closed candle mitigate any currently active FVG?
    if activeFvgTop.size() > 0
        for k = activeFvgTop.size() - 1 to 0
            fvgTop    = array.get(activeFvgTop, k)
            fvgBottom = array.get(activeFvgBottom, k)
            fvgIsBull = array.get(activeFvgIsBull, k)
            bool mitigated = fvgIsBull ?
                 (fvgMitigationSource == "Wick" ? cLow <= fvgBottom : cClose <= fvgBottom) :
                 (fvgMitigationSource == "Wick" ? cHigh >= fvgTop : cClose >= fvgTop)
            if mitigated
                if fvgIsBull
                    fvgMitigatedBull := true
                else
                    fvgMitigatedBear := true
                array.remove(activeFvgTop, k)
                array.remove(activeFvgBottom, k)
                array.remove(activeFvgIsBull, k)

    // 2) New FVG check: does the newly closed candle complete a 3-candle gap pattern?
    bool bullGapNow = cLow > aHigh
    bool bearGapNow = cHigh < aLow

    if bullGapNow
        array.push(activeFvgTop, cLow)
        array.push(activeFvgBottom, aHigh)
        array.push(activeFvgIsBull, true)
        fvgFormedBull := true
    else if bearGapNow
        array.push(activeFvgTop, aLow)
        array.push(activeFvgBottom, cHigh)
        array.push(activeFvgIsBull, false)
        fvgFormedBear := true

// RENDERING

var candleBodies    = array.new<box>()
var candleWickLines = array.new<line>()
var fvgBoxes        = array.new<box>()

var bool scaleDown   = false
var int  effBarWidth = 0

f_clearDrawings() =>
    if candleBodies.size() > 0
        for bx in candleBodies
            bx.delete()
        candleBodies.clear()
    if candleWickLines.size() > 0
        for ln in candleWickLines
            ln.delete()
        candleWickLines.clear()
    if fvgBoxes.size() > 0
        for bx in fvgBoxes
            bx.delete()
        fvgBoxes.clear()

if barstate.islast
    f_clearDrawings()

    totalStored = htfOpen.size()
    usableTotal = showCurrent ? totalStored : math.max(0, totalStored - 1)
    n = math.min(candleCount, usableTotal)
    firstIdx = usableTotal - n

    xLeftArr  = array.new_int(n)
    xRightArr = array.new_int(n)

    maxFutureOffset = 490
    availableSpan   = math.max(1, maxFutureOffset - rightOffset)
    neededSpan      = n * barWidth + math.max(0, n - 1) * gapBars
    scaleDown       := not autoAlign and n > 0 and neededSpan > availableSpan
    effBarWidth     := scaleDown ? math.max(1, math.floor(barWidth * availableSpan / neededSpan)) : barWidth
    effGapBars      = scaleDown ? math.max(0, math.floor(gapBars  * availableSpan / neededSpan)) : gapBars

    // Pass 1: X coordinates for each HTF candle to be drawn.
    // Auto-align mode: the left edge is the real open time of the HTF candle and the right edge is its own
    // real close time (fetched directly from the HTF context), not the open time of the following candle.
    // This distinction matters for instruments with limited session hours (stocks, indices, etc.): the gap
    // between one session's close and the next session's open must stay outside the candle's box, otherwise
    // the box would stretch across the closed hours and a centered wick would land outside the visible
    // session, appearing pinned to one edge instead of sitting in the middle.
    // Manual mode: candles are laid out linearly in bars to the right of the chart's last bar, according to
    // the configured width and gap.
    if n > 0
        for i = 0 to n - 1
            idx = firstIdx + i
            t   = htfStamp.get(idx)

            int xLeft  = na
            int xRight = na

            if autoAlign
                xLeft := t
                xRight := htfCloseStamp.get(idx)
                xRight := math.max(xLeft, xRight)
            else
                xLeft := bar_index + rightOffset + i * (effBarWidth + effGapBars)
                xRight := xLeft + effBarWidth
                // Guard against drawing too far into the future (beyond the range Pine allows for bar_index).
                xLeft := math.min(xLeft, bar_index + maxFutureOffset)
                xRight := math.min(xRight, bar_index + maxFutureOffset)

            array.set(xLeftArr, i, xLeft)
            array.set(xRightArr, i, xRight)

    rightMostX = n > 0 ? array.get(xRightArr, n - 1) : (autoAlign ? time_close : bar_index)

    // Pass 2: FVGs (Fair Value Gaps) — drawn before the candles, so the candles render on top.
    // A 3-candle gap: candle A (idx-1), middle candle (idx), candle C (idx+1).
    // Bullish (gap up):  low(C) > high(A)  → box from high(A) to low(C).
    // Bearish (gap down): high(C) < low(A) → box from high(C) to low(A).
    // The box starts at the left edge of the middle candle and extends right until it is closed
    // (mitigated) by a later HTF candle, or to the right edge of the most recent candle if the gap is
    // still unmitigated.
    if showFVG and n > 0
        for i = 0 to n - 1
            idx = firstIdx + i
            if idx >= 1 and idx + 1 <= usableTotal - 1
                aHigh = htfHigh.get(idx - 1)
                aLow  = htfLow.get(idx - 1)
                cHigh = htfHigh.get(idx + 1)
                cLow  = htfLow.get(idx + 1)

                bullGap = cLow > aHigh
                bearGap = cHigh < aLow

                if bullGap or bearGap
                    boxTop    = bullGap ? cLow : aLow
                    boxBottom = bullGap ? aHigh : cHigh
                    boxColor  = bullGap ? fvgBullColor : fvgBearColor

                    int mitigatedAtCoord = na
                    if idx + 2 <= usableTotal - 1
                        for j = idx + 2 to usableTotal - 1
                            if na(mitigatedAtCoord)
                                jHigh  = htfHigh.get(j)
                                jLow   = htfLow.get(j)
                                jClose = htfClose.get(j)
                                mit = bullGap ?
                                     (fvgMitigationSource == "Wick" ? jLow <= boxBottom : jClose <= boxBottom) :
                                     (fvgMitigationSource == "Wick" ? jHigh >= boxTop : jClose >= boxTop)
                                if mit
                                    mitigatedAtCoord := array.get(xLeftArr, j - firstIdx)
                                    break

                    boxLeft  = array.get(xLeftArr, i)
                    boxRight = na(mitigatedAtCoord) ? rightMostX : mitigatedAtCoord

                    fvgBox = box.new(
                         left   = boxLeft,
                         top    = boxTop,
                         bottom = boxBottom,
                         right  = math.max(boxLeft, boxRight),
                         border_color = color.new(boxColor, fvgBorderTransparency),
                         border_width = 1,
                         bgcolor      = color.new(boxColor, fvgTransparency),
                         xloc   = candleXloc,
                         extend = extend.none)
                    array.push(fvgBoxes, fvgBox)

    // Pass 3: HTF candles (drawn on top of the FVG boxes).
    if n > 0
        for i = 0 to n - 1
            idx = firstIdx + i

            o = htfOpen.get(idx)
            h = htfHigh.get(idx)
            l = htfLow.get(idx)
            c = htfClose.get(idx)

            baseCol   = c >= o ? upColor : downColor
            fillCol   = color.new(baseCol, candleTransparency)
            borderCol = color.new(baseCol, candleBorderTransparency)

            xLeft  = array.get(xLeftArr, i)
            xRight = array.get(xRightArr, i)

            // The wick is a single centered line running from the high to the low, exactly like a
            // regular candlestick. This works identically in both manual and auto-align mode, since
            // line.new supports both xloc.bar_index and xloc.bar_time coordinates.
            xMid = int(math.round((xLeft + xRight) / 2))
            wickLine = line.new(xMid, h, xMid, l, color = fillCol, width = wickWidth, xloc = candleXloc)
            candleWickLines.push(wickLine)

            bodyTop    = math.max(o, c)
            bodyBottom = math.min(o, c)
            bodyBottom := bodyTop == bodyBottom ? bodyBottom - (h - l) * 0.01 : bodyBottom

            bodyBox = box.new(xLeft, bodyTop, xRight, bodyBottom, border_color = borderCol, bgcolor = fillCol, xloc = candleXloc)
            candleBodies.push(bodyBox)


// ALERT CONDITIONS

alertcondition(fvgFormedBull, title = "Bullish FVG Formed", message = "Bullish Fair Value Gap formed on {{ticker}} (Higher Timeframe).")
alertcondition(fvgFormedBear, title = "Bearish FVG Formed", message = "Bearish Fair Value Gap formed on {{ticker}} (Higher Timeframe).")
alertcondition(fvgMitigatedBull, title = "Bullish FVG Mitigated", message = "Bullish Fair Value Gap mitigated on {{ticker}} (Higher Timeframe).")
alertcondition(fvgMitigatedBear, title = "Bearish FVG Mitigated", message = "Bearish Fair Value Gap mitigated on {{ticker}} (Higher Timeframe).")
````
