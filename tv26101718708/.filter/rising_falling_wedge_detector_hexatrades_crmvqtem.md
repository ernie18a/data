# Rising & Falling Wedge Detector [HexaTrades]

- url: https://www.tradingview.com/script/cRmVqteM-Rising-Falling-Wedge-Detector-HexaTrades/
- type: indicator
- pine_id: PUB;7d3437113a654ff9969fe75b91367d23
- version: 1.0

## Description

[b]Overview[/b]

Wedge Detector automatically identifies and draws the two most actionable wedge patterns: the Rising Wedge (bearish) and the Falling Wedge (bullish). It marks each as a converging cone, validates the geometry, waits for a bar-close breakout, then plots a measured-move target and a structure-based stop without repainting the pattern structure.

It is built around quality over quantity: a strict, perfect-shape gate ensures only genuinely converging, textbook wedges appear. Every part of the logic is transparent and tunable. Ideal for swing and intraday traders who trade chart patterns and want an objective, rules-based way to spot wedges and define risk.


[b]What it detects[/b]

Rising Wedge( bearish)
Higher highs and higher lows, but the lows rise faster than the highs (the lines converge upward). Signals a likely breakdown confirmed on a close below the lower trendline.

Falling Wedge ( bullish)
Lower highs and lower lows, but the highs fall faster than the lows (the lines converge downward). Signals a likely breakout confirmed on a close above the upper trendline.


[b]How the Indicator Works[/b]

- Pivots: confirmed swing highs/lows (locked pivotLen bars after they occur).
- Boundaries: upper line from the two most recent swing highs; lower line from the two most recent swing lows, projected as straight lines.
- Slope & convergence: rising = both up, lows rising faster; falling = both down, highs falling faster (set by Convergence strictness).
- Perfect-shape gate: no crossing inside, real narrowing, minimum contraction, apex ahead, sensible duration, minimum ATR height.
- Forming preview: dashed shaded cone while developing.
- Breakout: bar-close below lower line (rising → bearish) / above upper line (falling → bullish).
- Filters: optional EMA trend, volume, breakout-candle ATR size.
- Targets/stops: measured-move target + opposite-boundary stop, drawn as persistent right-extending lines.


 [b]Features[/b]

- Automatic detection of rising & falling wedges from confirmed pivots.
- Perfect-shape validation rejects crossing, barely-narrowing, diverging, past-apex, too-small or too-long shapes.
- Forming preview dashed shaded cone before breakout.
- Bar-close breakout confirmation, no intrabar fakes.
- Measured-move target + structure stop (opposite boundary).
- EMA trend filter, volume filter, breakout-candle ATR filter (all optional).
- Theme-aware dashboard + shaded wedge zone + 3 alerts.


[b]Dashboard[/b]

Status: Forming while developing → Confirmed on breakout
Last wedge: Rising Wedge / Falling Wedge
Bias: Bearish / Bullish
Target: Projected take-profit level
Stop: Structure-based invalidation level
Filters: EMA / Volume / ATR shown as On / Off


[b]Settings[/b]

Detection:
Pivot length: swing sensitivity. Lower = more (and smaller) wedges.
Min wedge height (ATR): rejects wedges smaller than this many ATR.
Convergence strictness: how strongly the lines must converge (higher = stricter).
Min width contraction: minimum narrowing from start to breakout.
Max wedge duration: rejects over-stretched patterns.
Show forming wedge: preview wedges before breakout.

Filters:
EMA trend filter: only confirm breakouts aligned with the EMA (falling wedge above EMA, rising wedge below).
Volume confirmation: requires above-average volume on the breakout candle.
Min breakout candle size: require a breakout candle of at least N×ATR.
Visuals
Toggle target/stop lines, colors for bullish/bearish / forming, and the dashboard.

Alerts:
Rising Wedge breakdown:bearish confirmation.
Falling Wedge breakout: bullish confirmation.
Any wedge confirmed - either of the above.
[i]Create alerts with “Once per bar close” for non-repainting behaviour.[/i]


[b]Trading Guide[/b]

- Identify: dashboard Status = Forming + clean dashed cone.
- Enter: on the bar-close breakout (▲/▼) in the wedge's direction.
- Avoid: when filters reject the breakout, or in choppy ranges.
- Stop: the drawn SL (opposite boundary). Target: the drawn TP (measured move).
- Risk: size so breakout→stop is an acceptable risk; R:R = (TP−entry) ÷ (entry−SL).


[b]Bullish Example (Falling Wedge)[/b]
Down-trend forms a dashed falling cone → a candle closes above the upper line → ▲ prints, wedge turns solid green, Status = Confirmed → enter, SL = lower line, TP = breakout + wedge height.
https://www.tradingview.com/x/7mlVtmor/


[b]Bearish Example (Rising Wedge)[/b]
Up-grind forms a dashed rising cone → a candle closes below the lower line → ▼ prints, wedge turns solid red → enter short, SL = upper line, TP = breakout − wedge height.
https://www.tradingview.com/x/AdpyH1Rg/


[b]Best Markets & Timeframes[/b]
Markets: works on crypto, forex, stocks, indices, futures, commodities. Best on liquid instruments with clean swings (the volume filter is most meaningful on stocks/indices).
Timeframes: 5m/15m = more signals, more noise (use stricter filters); 1H/4H = the sweet spot; Daily/Weekly = highest quality, fewer & slower.


[i]We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.[/i]


[i]Wedge pattern detector indicator is for educational and analytical purposes only. It is not financial advice. Trading involves risk. Always use proper risk management and combine this indicator with your own analysis before taking any trade.
[/i]

## Source Code

````pine
//@version=6
indicator("Rising & Falling Wedge Detector [HexaTrades]", "HexaTrades Rising & Falling Wedge Detector", overlay = true,
     max_lines_count = 200, max_labels_count = 100)

// =============================================================================
// 1. INPUTS
// =============================================================================
g1          = "Detection"
pivotLen    = input.int(5, "Pivot length", minval = 2, maxval = 50, group = g1,
     tooltip = "Bars left/right to confirm a swing. Lower = more swings = MORE wedges.")
minSizeATR  = input.float(0.5, "Min wedge height (ATR)", minval = 0.0, step = 0.25, group = g1,
     tooltip = "Reject wedges whose widest part is smaller than this many ATR. Lower = more wedges.")
convStrict  = input.float(1.05, "Convergence strictness", minval = 1.0, maxval = 3.0, step = 0.05, group = g1,
     tooltip = "How much faster the converging line must move (1.0 = any convergence, higher = stricter).")
minContract = input.float(0.10, "Min width contraction", minval = 0.0, maxval = 0.9, step = 0.05, group = g1,
     tooltip = "Wedge must narrow by at least this fraction. Lower = more wedges.")
maxBars     = input.int(250, "Max wedge duration (bars)", minval = 20, group = g1,
     tooltip = "Reject over-stretched wedges spanning more than this many bars.")
showForming = input.bool(true, "Show forming wedge (preview)", group = g1)

g2          = "Filters"
useEma      = input.bool(false, "EMA trend filter", group = g2,
     tooltip = "Only confirm breakouts aligned with the EMA: falling wedge (bullish) needs price ABOVE the EMA, rising wedge (bearish) needs price BELOW it.")
emaLen      = input.int(200, "EMA length", minval = 1, group = g2)
useVol      = input.bool(false, "Volume confirmation on breakout", group = g2)
volMult     = input.float(1.3, "Volume > x avg", minval = 1.0, step = 0.1, group = g2)
useBrkSize  = input.bool(true, "Min breakout candle size", group = g2)
brkSizeATR  = input.float(0.2, "Breakout candle >= (ATR)", minval = 0.0, step = 0.05, group = g2)

g3          = "Visuals"
showTarget  = input.bool(true, "Show target line", group = g3)
showStop    = input.bool(true, "Show stop line", group = g3)
colBull     = input.color(#089981, "Bullish (falling wedge)", group = g3)
colBear     = input.color(#f23645, "Bearish (rising wedge)", group = g3)
colForm     = input.color(color.new(color.gray, 20), "Forming", group = g3)
showDash    = input.bool(true, "Show dashboard", group = g3)

// =============================================================================
// 2. CORE MEASURES
// =============================================================================
atr    = ta.atr(14)
volAvg = ta.sma(volume, 20)
emaVal = ta.ema(close, emaLen)

f_at(base, slope, baseBar, x) => base + slope * (x - baseBar)   // trendline price at bar x
f_emaOk(bullish) => not useEma ? true : (bullish ? close > emaVal : close < emaVal)
f_volOk()     => not useVol or na(volume) ? true : volume > volAvg * volMult
f_brkSizeOk() => not useBrkSize ? true : math.abs(close - open) >= atr * brkSizeATR

plot(useEma ? emaVal : na, "EMA trend filter", color = color.new(color.orange, 0), linewidth = 1)

// =============================================================================
// 3. PIVOTS (confirmed only → non-repainting)
// =============================================================================
ph = ta.pivothigh(pivotLen, pivotLen)
pl = ta.pivotlow(pivotLen, pivotLen)

var float[] phP = array.new<float>()
var int[]   phB = array.new<int>()
var float[] plP = array.new<float>()
var int[]   plB = array.new<int>()
MAXPIV = 6

f_trim(arr, n) =>
    if array.size(arr) > n
        array.shift(arr)

if not na(ph)
    array.push(phP, ph)
    array.push(phB, bar_index - pivotLen)
    f_trim(phP, MAXPIV)
    f_trim(phB, MAXPIV)
if not na(pl)
    array.push(plP, pl)
    array.push(plB, bar_index - pivotLen)
    f_trim(plP, MAXPIV)
    f_trim(plB, MAXPIV)

f_phP(i) => array.size(phP) >= i ? array.get(phP, array.size(phP) - i) : na
f_phB(i) => array.size(phB) >= i ? array.get(phB, array.size(phB) - i) : na
f_plP(i) => array.size(plP) >= i ? array.get(plP, array.size(plP) - i) : na
f_plB(i) => array.size(plB) >= i ? array.get(plB, array.size(plB) - i) : na

// =============================================================================
// 4. OBJECT MANAGEMENT (cap + auto-delete oldest)
// =============================================================================
var line[]  lines  = array.new<line>()
var label[] labels = array.new<label>()

f_line(int x1, float y1, int x2, float y2, color c, string st, int w) =>
    ln = line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = c, style = st, width = w)
    array.push(lines, ln)
    if array.size(lines) > 40
        line.delete(array.shift(lines))
    ln

f_label(int x, float y, string txt, color c, string style, color tc) =>
    lb = label.new(x, y, txt, xloc = xloc.bar_index, style = style, color = c, textcolor = tc, size = size.small)
    array.push(labels, lb)
    if array.size(labels) > 20
        label.delete(array.shift(labels))
    lb

var linefill[] fills = array.new<linefill>()
f_fill(line a, line b, color c) =>
    lf = linefill.new(a, b, c)
    array.push(fills, lf)
    if array.size(fills) > 20
        linefill.delete(array.shift(fills))
    lf

// =============================================================================
// 5. DASHBOARD STATE (single-element arrays so functions can mutate)
// =============================================================================
var string[] gName  = array.new<string>(1, "—")
var string[] gDir   = array.new<string>(1, "—")
var float[]  gTgt   = array.new<float>(1, na)
var float[]  gStop  = array.new<float>(1, na)
var string   lastStatus = "—"          // last confirmed status for the dashboard

// latest-signal levels (persist across bars so TP/SL stay on screen)
var float sigTp  = na
var float sigSl  = na
var int   sigBar = na
var int   sigDir = 0

// alert flags + live forming indicator (reset each bar)
var bool aRising  = false
var bool aFalling = false
var int  formDir  = 0
aRising  := false
aFalling := false
formDir  := 0

// =============================================================================
// 6. WEDGE DETECTION
// =============================================================================
go = barstate.isconfirmed and array.size(phP) >= 2 and array.size(plP) >= 2

var line     fU = na   // forming-wedge preview lines (reused)
var line     fL = na
var linefill fF = na   // forming-wedge preview shade (reused)

if go
    h1 = f_phP(2)
    h2 = f_phP(1)
    hb1 = f_phB(2)
    hb2 = f_phB(1)
    l1 = f_plP(2)
    l2 = f_plP(1)
    lb1 = f_plB(2)
    lb2 = f_plB(1)

    if not na(h1) and not na(l1) and hb2 > hb1 and lb2 > lb1
        upSlope = (h2 - h1) / math.max(hb2 - hb1, 1)
        dnSlope = (l2 - l1) / math.max(lb2 - lb1, 1)

        // project each trendline to any bar x (single straight lines)
        curUpper  = f_at(h1, upSlope, hb1, bar_index)
        curLower  = f_at(l1, dnSlope, lb1, bar_index)
        prevUpper = f_at(h1, upSlope, hb1, bar_index - 1)
        prevLower = f_at(l1, dnSlope, lb1, bar_index - 1)

        startBar   = math.min(hb1, lb1)
        span       = bar_index - startBar
        upperStart = f_at(h1, upSlope, hb1, startBar)
        lowerStart = f_at(l1, dnSlope, lb1, startBar)
        height     = upperStart - lowerStart           // widest part (left side)
        sizeOk     = height >= atr * minSizeATR

        // ---- WEDGE GEOMETRY ----
        w0 = upperStart - lowerStart                  // width at start (widest)
        w4 = curUpper - curLower                       // width now (narrowest)
        notCrossed = w0 > 0 and w4 > 0
        netNarrow  = w4 < w0
        contractOk = w0 > 0 and (w0 - w4) / w0 >= minContract
        apexX      = (upSlope - dnSlope) != 0 ? (l1 - h1 - dnSlope * lb1 + upSlope * hb1) / (upSlope - dnSlope) : na
        apexAhead  = na(apexX) or apexX > bar_index
        spanOk     = span >= pivotLen and span <= maxBars
        geomOk     = notCrossed and netNarrow and contractOk and apexAhead and spanOk

        // ---- shapes ----
        risingShape = h2 > h1 and l2 > l1 and upSlope > 0 and dnSlope > 0 and dnSlope > upSlope * convStrict and sizeOk and geomOk
        fallingShape = h2 < h1 and l2 < l1 and upSlope < 0 and dnSlope < 0 and upSlope < dnSlope * convStrict and sizeOk and geomOk

        brkDown = close < curLower and close[1] >= prevLower    // rising wedge breakdown
        brkUp   = close > curUpper and close[1] <= prevUpper    // falling wedge breakout

        filtersOk = f_volOk() and f_brkSizeOk()

        // ----- CONFIRMED RISING WEDGE -----
        if risingShape and brkDown and filtersOk and f_emaOk(false)
            ru = f_line(startBar, upperStart, bar_index, curUpper, colBear, line.style_solid, 2)
            rl = f_line(startBar, lowerStart, bar_index, curLower, colBear, line.style_solid, 2)
            f_fill(ru, rl, color.new(colBear, 86))
            tgt  = curLower - height
            stp  = curUpper
            f_label(hb2, h2, "Rising Wedge ▼", color.new(colBear, 80), label.style_label_down, colBear)
            f_label(bar_index, high + atr * 0.4, "▼", color.new(colBear, 100), label.style_label_down, colBear)
            sigTp  := tgt
            sigSl  := stp
            sigBar := bar_index
            sigDir := -1
            lastStatus := "Confirmed"
            array.set(gName, 0, "Rising Wedge")
            array.set(gDir, 0, "Bearish")
            array.set(gTgt, 0, tgt)
            array.set(gStop, 0, stp)
            aRising := true

        // ----- CONFIRMED FALLING WEDGE -----
        if fallingShape and brkUp and filtersOk and f_emaOk(true)
            fu = f_line(startBar, upperStart, bar_index, curUpper, colBull, line.style_solid, 2)
            fl = f_line(startBar, lowerStart, bar_index, curLower, colBull, line.style_solid, 2)
            f_fill(fu, fl, color.new(colBull, 86))
            tgt  = curUpper + height
            stp  = curLower
            f_label(lb2, l2, "Falling Wedge ▲", color.new(colBull, 80), label.style_label_up, colBull)
            f_label(bar_index, low - atr * 0.4, "▲", color.new(colBull, 100), label.style_label_up, colBull)
            sigTp  := tgt
            sigSl  := stp
            sigBar := bar_index
            sigDir := 1
            lastStatus := "Confirmed"
            array.set(gName, 0, "Falling Wedge")
            array.set(gDir, 0, "Bullish")
            array.set(gTgt, 0, tgt)
            array.set(gStop, 0, stp)
            aFalling := true

        // ----- FORMING PREVIEW (perfect shape, not yet broken) -----
        formingNow = showForming and ((risingShape and not brkDown) or (fallingShape and not brkUp))
        if formingNow
            fc = risingShape ? colBear : colBull
            formDir := risingShape ? -1 : 1
            if na(fU)
                fU := line.new(startBar, upperStart, bar_index, curUpper, xloc = xloc.bar_index, color = colForm, style = line.style_dashed, width = 1)
                fL := line.new(startBar, lowerStart, bar_index, curLower, xloc = xloc.bar_index, color = colForm, style = line.style_dashed, width = 1)
                fF := linefill.new(fU, fL, color.new(fc, 90))
            else
                line.set_xy1(fU, startBar, upperStart)
                line.set_xy2(fU, bar_index, curUpper)
                line.set_xy1(fL, startBar, lowerStart)
                line.set_xy2(fL, bar_index, curLower)
            line.set_color(fU, color.new(fc, 40))
            line.set_color(fL, color.new(fc, 40))
            if not na(fF)
                linefill.set_color(fF, color.new(fc, 90))
        else if not na(fU)
            line.delete(fU)
            line.delete(fL)
            fU := na
            fL := na
            fF := na

// =============================================================================
// 7. PERSISTENT TP / SL FOR LATEST SIGNAL (extends right; bounded left anchor)
// =============================================================================
var line  tpLn = na
var label tpLb = na
var line  slLn = na
var label slLb = na
rightX = bar_index + 15
leftX  = math.max(na(sigBar) ? bar_index : sigBar, bar_index - 480)   // never exceed Pine's x range

if not na(sigTp) and showTarget
    dcol = sigDir > 0 ? colBull : colBear
    if na(tpLn)
        tpLn := line.new(leftX, sigTp, rightX, sigTp, xloc = xloc.bar_index, color = dcol, style = line.style_dashed, width = 1)
        tpLb := label.new(rightX, sigTp, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dcol, 100), textcolor = dcol, size = size.small)
    line.set_xy1(tpLn, leftX, sigTp)
    line.set_xy2(tpLn, rightX, sigTp)
    line.set_color(tpLn, dcol)
    label.set_xy(tpLb, rightX, sigTp)
    label.set_text(tpLb, "TP  " + str.tostring(math.round_to_mintick(sigTp)))
    label.set_textcolor(tpLb, dcol)

if not na(sigSl) and showStop
    if na(slLn)
        slLn := line.new(leftX, sigSl, rightX, sigSl, xloc = xloc.bar_index, color = color.gray, style = line.style_dotted, width = 1)
        slLb := label.new(rightX, sigSl, "", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, 100), textcolor = color.gray, size = size.small)
    line.set_xy1(slLn, leftX, sigSl)
    line.set_xy2(slLn, rightX, sigSl)
    label.set_xy(slLb, rightX, sigSl)
    label.set_text(slLb, "SL  " + str.tostring(math.round_to_mintick(sigSl)))

// =============================================================================
// 8. DASHBOARD (premium)
// =============================================================================
// theme-agnostic panel: solid body matches the chart bg, headers a gray bar,
// so the dashboard is readable on ANY background (dark or light).
panelBg  = chart.bg_color                       // opaque -> candles never bleed through
headerBg = color.new(color.gray, 25)            // semi-solid bar, visible on both themes
keyCol   = color.new(chart.fg_color, 20)
var table dash = table.new(position.top_right, 2, 10, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)
f_cell(r, k, v, vcol) =>
    table.cell(dash, 0, r, k, text_color = keyCol, text_size = size.tiny, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, r, v, text_color = vcol, text_size = size.tiny, text_halign = text.align_right, bgcolor = panelBg)
f_onoff(b) => b ? "On" : "Off"

if showDash and barstate.islast
    nm = array.get(gName, 0)
    dr = array.get(gDir, 0)
    tg = array.get(gTgt, 0)
    sp = array.get(gStop, 0)
    dc = dr == "Bullish" ? colBull : dr == "Bearish" ? colBear : color.gray
    statusTxt = formDir != 0 ? "Forming" : lastStatus
    statusCol = formDir != 0 ? color.new(color.orange, 0) : lastStatus == "Confirmed" ? colBull : color.gray
    table.cell(dash, 0, 0, "WEDGE DETECTOR", text_color = chart.fg_color, text_size = size.small, bgcolor = headerBg, text_halign = text.align_left)
    table.cell(dash, 1, 0, "[YB]", text_color = color.new(chart.fg_color, 40), text_size = size.tiny, bgcolor = headerBg, text_halign = text.align_right)
    f_cell(1, "Status",    statusTxt, statusCol)
    f_cell(2, "Last wedge", nm, dc)
    f_cell(3, "Bias",       dr, dc)
    f_cell(4, "Target",     na(tg) ? "—" : str.tostring(math.round_to_mintick(tg)), colBull)
    f_cell(5, "Stop",       na(sp) ? "—" : str.tostring(math.round_to_mintick(sp)), colBear)
    table.cell(dash, 0, 6, "FILTERS", text_color = chart.fg_color, text_size = size.tiny, bgcolor = headerBg, text_halign = text.align_left)
    table.cell(dash, 1, 6, "", bgcolor = headerBg)
    f_cell(7, "EMA filter",    f_onoff(useEma),     useEma ? colBull : color.gray)
    f_cell(8, "Volume filter", f_onoff(useVol),     useVol ? colBull : color.gray)
    f_cell(9, "ATR filter",    f_onoff(useBrkSize), useBrkSize ? colBull : color.gray)

// =============================================================================
// 9. ALERTS
// =============================================================================
alertcondition(aRising,  "Rising Wedge breakdown",  "Wedge: Rising Wedge confirmed (bearish breakdown)")
alertcondition(aFalling, "Falling Wedge breakout",  "Wedge: Falling Wedge confirmed (bullish breakout)")
alertcondition(aRising or aFalling, "Any wedge confirmed", "Wedge: wedge pattern confirmed")
````
