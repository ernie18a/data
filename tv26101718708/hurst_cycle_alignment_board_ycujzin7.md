# Hurst Cycle Alignment Board

- url: https://www.tradingview.com/script/YcUJZin7-Hurst-Cycle-Alignment-Board/
- type: indicator
- pine_id: PUB;b50b128b801c433ebe62cd3bdd4e50d8
- version: 1.0

## Description

[b]█ OVERVIEW[/b]

The Hurst Cycle Alignment Board fits three fixed cycles from J.M. Hurst's nominal model, the 40-week, 20-week and 10-week cycles, to the chart's price series and shows them as three direction-colored waveforms in a separate pane, shading the background when all three move the same way. It is a regime and timing view built on the premise that price contains a small set of harmonically related cycles whose turning points tend to cluster when the cycles align.


[b]█ HISTORY / BACKGROUND[/b]

The cycle lengths come from the nominal model described by J.M. Hurst in "The Profit Magic of Stock Transaction Timing" (1970) and his later cyclic work. Hurst proposed that price action across markets is dominated by a recurring set of cycles related to one another by small integer ratios, most often 2 to 1. The three lengths used here are consecutive harmonics of that ladder: the 40-week cycle (average wavelength about 38.97 weeks) divides into two 20-week cycles (about 19.48 weeks), which divide into two 10-week cycles, the latter also called the 80-day cycle (about 9.74 weeks, near 68.2 calendar days).

Three of Hurst's stated principles motivate viewing them together rather than singly: harmonicity (cycles relate by simple ratios), synchronicity (cycles tend to trough together) and proportionality (longer cycles carry larger amplitude). The fitting method applied to those fixed lengths, a single-frequency least-squares projection, is a standard signal-processing technique. The script does not search for or discover cycle lengths; the three periods are fixed inputs.


[b]█ HOW IT WORKS[/b]

For each of the three cycles the script performs the same steps, all on the chart's own series:

 • [b]Period in bars.[/b] Each length is entered in calendar weeks and converted to a bar count at runtime. On a daily chart the count is weeks multiplied by the [i]Market days per week[/i] setting; on a weekly chart it is the number of weeks; on a monthly chart it is weeks divided by 4.345. Results are rounded and floored at a small minimum.
 • [b]Detrend.[/b] The script takes the natural log of the source and subtracts a simple moving average of that log series. The averaging length is the long-cycle bar count multiplied by the [i]Detrend length[/i] factor, removing slow trend before the fit.
 • [b]Single-frequency fit.[/b] With angular frequency w = 2*pi / period and t = bar_index, the script computes two rolling correlations over a trailing window of length L (the cycle period multiplied by the [i]Fit window[/i] factor): a = 2/L * sum(detrended * cos(w*t)) and b = 2/L * sum(detrended * sin(w*t)). These are the least-squares coefficients of one sinusoid at that frequency, equivalent to a single bin of a discrete Fourier transform (a Goertzel-style evaluation). The fitted cycle value at any bar is a*cos(w*t) + b*sin(w*t), and its amplitude is A = sqrt(a^2 + b^2).
 • [b]Significance.[/b] Each cycle's significance is the share of windowed variance it explains: 0.5*(a^2 + b^2) divided by the variance of the detrended series over the same window, clamped to the range 0 to 1.
 • [b]Normalization and stacking.[/b] Each fitted cycle is divided by its own amplitude to a unit-amplitude waveform and placed in its own horizontal band, separated by the [i]Band spacing[/i] value, so the three appear stacked in one pane.
 • [b]Direction and alignment.[/b] A cycle is treated as rising when its current fitted value is greater than or equal to the previous bar's value. When all three rise the background shades in the rising color; when all three fall it shades in the falling color; otherwise it is unshaded. The first bar of each all-rising or all-falling stretch is marked with a triangle on the main price chart.

A composite waveform, labeled "push", is the significance-weighted (or equal-weighted) average of the three normalized cycles and can optionally be drawn in a fourth band. A forward projection extends each cycle, and the composite, to the right of the last bar by evaluating the same a*cos(w*t) + b*sin(w*t) expression at future bar indices using the last bar's coefficients.


[b]█ HOW TO USE[/b]

Recommended timeframe: daily, weekly or monthly. The cycle lengths are multi-week, so they are meaningful only on these resolutions; on intraday the output is suppressed and an on-chart note is shown. The daily chart is the primary design target, because the periods, expressed in trading days through the [i]Market days per week[/i] setting, map to one bar per day.

Reading the output:

 • The three waveforms, top to bottom, are the 40-week, 20-week and 10-week cycles, each colored by direction.
 • Background shading marks stretches where all three cycles move the same way. Unshaded stretches are mixed.
 • Triangles on the price chart mark the bar where a fully aligned stretch begins, up-triangles for all rising and down-triangles for all falling.
 • The table at the top right lists each cycle's period in bars and weeks, its significance value and its current direction, plus a [i]today[/i] row showing the overall state: ALL UP, ALL DOWN or MIXED.
 • The forward projection to the right of the last bar is the deterministic continuation of each fitted cycle. It is a model output, not a price target.

Set [i]Market days per week[/i] to match the instrument: 5 for stocks, indices, futures and forex; 7 for markets that trade every day, such as crypto, so a given calendar cycle maps to the correct number of daily bars.


[b]█ SETTINGS[/b]

[b]Cycles (calendar weeks)[/b]
 • [i]Long cycle (40-week)[/i]. Long cycle length in calendar weeks. Default 38.97.
 • [i]Mid cycle (20-week)[/i]. Mid cycle length in calendar weeks. Default 19.48.
 • [i]Short cycle (10-week)[/i]. Short cycle length in calendar weeks. Default 9.74.

[b]Instrument / timeframe[/b]
 • [i]Market days per week[/i]. Trading days per week, used to convert weeks to bars on daily charts. Default 5.

[b]Fit[/b]
 • [i]Source[/i]. The series the cycles are fitted to. Default close.
 • [i]Fit window (x period)[/i]. Length of the trailing least-squares window, as a multiple of each cycle's period. Default 3.0.
 • [i]Detrend length (x long period)[/i]. Length of the trend-removal moving average, as a multiple of the long-cycle bar count. Must exceed 1. Default 1.5.

[b]Display[/b]
 • [i]Rising[/i]. Color for a rising cycle. Default teal.
 • [i]Falling[/i]. Color for a falling cycle. Default red.
 • [i]Band spacing[/i]. Vertical distance between the stacked cycle bands. Default 2.4.
 • [i]Project cycles forward[/i]. Draws the forward projection. Default on.
 • [i]Projection length (bars)[/i]. Number of bars projected forward, limited to 400. Default 250.
 • [i]Projection step[/i]. Draws one projected segment every N bars to limit object count. Default 3.
 • [i]Show composite (push) band[/i]. Draws the composite waveform in a fourth band. Default off.
 • [i]Weight composite by fit significance[/i]. When on, the composite weights each cycle by its significance; when off, the three are equally weighted. Default on.


[b]█ WHAT MAKES IT ORIGINAL[/b]

The script is a self-contained implementation that combines three elements in one tool. First, it fixes the three cycle lengths to Hurst's nominal harmonics rather than searching for dominant periods. Second, it determines each cycle's phase and amplitude automatically by a single-frequency least-squares fit (a one-bin DFT) to detrended log price, recomputed every bar, instead of anchoring cycles to a manually chosen pivot or to a future line of demarcation. Third, it reduces the three cycles to a single regime read by shading only when all three agree in direction and by marking the onset of each aligned stretch on the price chart.

Because the chosen lengths are true 2-to-1 harmonics, the all-aligned condition corresponds to the synchronized turning that Hurst's model expects, rather than a coincidental phase overlap of unrelated periods. The lengths are entered in calendar weeks and converted to bars from the chart timeframe and a trading-days-per-week setting, so the same nominal cycles apply consistently across instruments and across daily, weekly and monthly resolutions.


[b]█ NOTES / LIMITATIONS[/b]

 • [b]Repainting.[/b] The fit is recomputed on every bar over a trailing window, so both the historical cycle estimates and the forward projection update as new bars arrive, and a cycle's direction can change on the developing bar. Treat the most recent bars and the projection as provisional until the bar closes. The script uses no request.security calls and no lookahead.
 • [b]Timeframe.[/b] Only daily, weekly and monthly are supported. On intraday resolutions all output is suppressed and an on-chart note is shown.
 • [b]History required.[/b] Each cycle needs roughly the detrend length plus the fit window of prior bars before it returns a value. At default settings on a daily chart this is on the order of 900 bars for the long cycle, so on symbols with little history the long cycle may not render until enough bars exist.
 • [b]Forward projection bounds.[/b] The projection extends a fixed number of bars (default 250, capped at 400). Pine does not draw beyond about 500 bars into the future, so the projection cannot be extended arbitrarily far.
 • [b]Object and compute limits.[/b] The projection is drawn with line objects, capped at 500 and internally held under 490; the [i]Projection step[/i] setting reduces the count by drawing one segment every N bars. The maximum historical reference is set to 1800 bars.
 • [b]Instrument setting.[/b] There is no symbol-class restriction, but [i]Market days per week[/i] must match the instrument (5 for conventional markets, 7 for markets trading every day); otherwise the calendar-to-bar conversion on daily charts will be off.
 • [b]Amplitude display.[/b] Each cycle is normalized to unit amplitude for the stacked display, so band height does not convey relative cycle strength; the significance column in the table carries that information.

## Source Code

````pine
//@version=6
// =============================================================================
// Hurst Cycle Alignment Board
// -----------------------------------------------------------------------------
// Plots three fixed Hurst nominal-model cycles (40-week, 20-week, 10-week) as
// directional sinusoids, each fitted to detrended log price by a single
// -frequency least-squares (one-bin Goertzel) projection, and shades the pane
// when all three cycles agree in direction.
//
// Cycle lengths are specified in CALENDAR WEEKS (Hurst's native unit) and are
// converted to a bar count at runtime from the chart timeframe and a market
// -days-per-week setting, so the tool scales to any instrument:
//   daily   : bars = weeks * marketDaysPerWeek   (5 for equities/FX/futures,
//                                                  7 for 24/7 markets e.g. crypto)
//   weekly  : bars = weeks
//   monthly : bars = weeks / 4.345
// Intraday is not supported for these multi-week cycles (output is suppressed).
//
// Method per cycle:
//   1. Detrend: x = log(source) - SMA(log(source), detrendBars)
//   2. Fit x ~ a*cos(w*t) + b*sin(w*t) over a trailing window, w = 2*pi/period,
//      t = bar_index. The coefficients are rolling correlations:
//          a = 2/L * sum(x*cos(w*t)) , b = 2/L * sum(x*sin(w*t))
//   3. Cycle value at any bar (incl. future) = a*cos(w*t) + b*sin(w*t)
//      Amplitude A = sqrt(a^2 + b^2). Significance = explained / total variance.
//
// Repaint note: the fit is recomputed every bar over the trailing window, so the
// historical cycle estimate and the forward projection both update as new bars
// arrive. This is inherent to a rolling cycle estimate, not a coding artifact.
// =============================================================================

indicator("Hurst Cycle Alignment Board", "Hurst CAB", overlay = false, max_lines_count = 500, max_labels_count = 20, max_bars_back = 1800)

// ---------- Inputs: cycles (calendar weeks) ----------
gCyc = "Cycles (Hurst nominal model, calendar weeks)"
wk1 = input.float(38.97, "Long cycle  (40-week)",  minval = 2.0, maxval = 60.0, step = 0.01, group = gCyc, tooltip = "Hurst 40-week nominal cycle. Average wavelength 38.97 weeks, about 272.8 calendar days.")
wk2 = input.float(19.48, "Mid cycle   (20-week)",  minval = 1.5, maxval = 30.0, step = 0.01, group = gCyc, tooltip = "Hurst 20-week nominal cycle. Average wavelength 19.48 weeks, about 136.4 calendar days.")
wk3 = input.float(9.74,  "Short cycle (10-week)",  minval = 1.0, maxval = 20.0, step = 0.01, group = gCyc, tooltip = "Hurst 10-week / 80-day nominal cycle. Average wavelength about 9.74 weeks, about 68.2 calendar days.")

// ---------- Inputs: instrument / timeframe ----------
gMkt = "Instrument / timeframe"
mdpw = input.int(5, "Market days per week", minval = 1, maxval = 7, group = gMkt, tooltip = "Trading days per week for this instrument. Use 5 for stocks, indices, futures and forex; use 7 for 24/7 markets such as crypto. Only affects daily charts.")

// ---------- Inputs: fit ----------
gFit        = "Fit"
srcIn       = input.source(close, "Source", group = gFit)
winMult     = input.float(3.0, "Fit window (x period)", minval = 1.0, maxval = 4.0, step = 0.5, group = gFit, tooltip = "Length of the trailing least-squares window for each cycle, in multiples of that cycle's period. Longer is more stable but slower to adapt.")
detrendMult = input.float(1.5, "Detrend length (x long period)", minval = 1.05, maxval = 3.0, step = 0.05, group = gFit, tooltip = "Trailing SMA length subtracted from log price to remove trend, as a multiple of the long-cycle bar count. Must exceed 1 so the long cycle is not attenuated.")

// ---------- Inputs: display ----------
gDisp    = "Display"
upCol    = input.color(color.new(#26a69a, 0), "Rising",  group = gDisp)
dnCol    = input.color(color.new(#ef5350, 0), "Falling", group = gDisp)
bandGap  = input.float(2.4, "Band spacing", minval = 1.0, step = 0.1, group = gDisp)
showProj = input.bool(true, "Project cycles forward", group = gDisp)
projBars = input.int(120, "Projection length (bars)", minval = 10, maxval = 250, group = gDisp)
projStep = input.int(3, "Projection step", minval = 1, maxval = 10, group = gDisp, tooltip = "Draw one projected segment every N bars to limit drawing-object count.")
showPush = input.bool(false, "Show composite (push) band", group = gDisp)
useSig   = input.bool(true, "Weight composite by fit significance", group = gDisp)

const float normAmp = 0.9

// ---------- Timeframe to bars conversion ----------
supported   = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
barsPerWeek = timeframe.isweekly ? 1.0 : timeframe.ismonthly ? (1.0 / 4.345) : float(mdpw)

p1 = math.max(8, int(math.round(wk1 * barsPerWeek)))
p2 = math.max(6, int(math.round(wk2 * barsPerWeek)))
p3 = math.max(4, int(math.round(wk3 * barsPerWeek)))

detrendBars = math.max(p1 + 2, int(math.round(p1 * detrendMult)))

win1 = math.max(8, int(p1 * winMult))
win2 = math.max(6, int(p2 * winMult))
win3 = math.max(4, int(p3 * winMult))

// ---------- Detrended log source ----------
lsrc = math.log(srcIn)
dsrc = lsrc - ta.sma(lsrc, detrendBars)

// ---------- Single-frequency least-squares fit (global scope) ----------
om1 = 2.0 * math.pi / p1
om2 = 2.0 * math.pi / p2
om3 = 2.0 * math.pi / p3

cos1 = math.cos(om1 * bar_index)
sin1 = math.sin(om1 * bar_index)
cos2 = math.cos(om2 * bar_index)
sin2 = math.sin(om2 * bar_index)
cos3 = math.cos(om3 * bar_index)
sin3 = math.sin(om3 * bar_index)

a1 = 2.0 * math.sum(dsrc * cos1, win1) / win1
b1 = 2.0 * math.sum(dsrc * sin1, win1) / win1
a2 = 2.0 * math.sum(dsrc * cos2, win2) / win2
b2 = 2.0 * math.sum(dsrc * sin2, win2) / win2
a3 = 2.0 * math.sum(dsrc * cos3, win3) / win3
b3 = 2.0 * math.sum(dsrc * sin3, win3) / win3

c1 = a1 * cos1 + b1 * sin1
c2 = a2 * cos2 + b2 * sin2
c3 = a3 * cos3 + b3 * sin3

A1 = math.sqrt(a1 * a1 + b1 * b1)
A2 = math.sqrt(a2 * a2 + b2 * b2)
A3 = math.sqrt(a3 * a3 + b3 * b3)

var1 = math.pow(ta.stdev(dsrc, win1), 2)
var2 = math.pow(ta.stdev(dsrc, win2), 2)
var3 = math.pow(ta.stdev(dsrc, win3), 2)

sig1 = var1 > 0 ? math.min(1.0, (0.5 * (a1 * a1 + b1 * b1)) / var1) : 0.0
sig2 = var2 > 0 ? math.min(1.0, (0.5 * (a2 * a2 + b2 * b2)) / var2) : 0.0
sig3 = var3 > 0 ? math.min(1.0, (0.5 * (a3 * a3 + b3 * b3)) / var3) : 0.0

// ---------- Normalize to unit-amplitude band ----------
n1 = A1 > 0 ? c1 / A1 : 0.0
n2 = A2 > 0 ? c2 / A2 : 0.0
n3 = A3 > 0 ? c3 / A3 : 0.0

off1 =  bandGap
off2 =  0.0
off3 = -bandGap
offP = -2.0 * bandGap

y1 = off1 + n1 * normAmp
y2 = off2 + n2 * normAmp
y3 = off3 + n3 * normAmp

up1 = c1 >= c1[1]
up2 = c2 >= c2[1]
up3 = c3 >= c3[1]

col1 = up1 ? upCol : dnCol
col2 = up2 ? upCol : dnCol
col3 = up3 ? upCol : dnCol

plot(supported ? y1 : na, "40-week", color = col1, linewidth = 2)
plot(supported ? y2 : na, "20-week", color = col2, linewidth = 2)
plot(supported ? y3 : na, "10-week", color = col3, linewidth = 2)

// ---------- Composite "push" ----------
wgt1 = useSig ? sig1 : 1.0
wgt2 = useSig ? sig2 : 1.0
wgt3 = useSig ? sig3 : 1.0
wsum = wgt1 + wgt2 + wgt3
push = wsum > 0 ? (wgt1 * n1 + wgt2 * n2 + wgt3 * n3) / wsum : 0.0
yP   = offP + push * normAmp
colP = push >= push[1] ? upCol : dnCol
plot(supported and showPush ? yP : na, "Push", color = colP, linewidth = 2)

// ---------- Alignment regime ----------
allUp = up1 and up2 and up3
allDn = (not up1) and (not up2) and (not up3)
bgcolor(supported and allUp ? color.new(upCol, 88) : supported and allDn ? color.new(dnCol, 88) : na, title = "All-aligned")

// On the main chart: mark the bar where alignment first turns all-up or all-down
plotshape(supported and allUp and not allUp[1], title = "Align Up",   style = shape.triangleup,   location = location.bottom, color = upCol, size = size.tiny, force_overlay = true)
plotshape(supported and allDn and not allDn[1], title = "Align Down", style = shape.triangledown, location = location.top,    color = dnCol, size = size.tiny, force_overlay = true)

alertcondition(allUp and not allUp[1], "All cycles up",   "Hurst CAB: all three cycles aligned UP")
alertcondition(allDn and not allDn[1], "All cycles down", "Hurst CAB: all three cycles aligned DOWN")

// ---------- Forward projection ----------
drawProj(line[] arr, float a, float b, float A, float off, float wfreq, int t0, int nSeg, int stepN, color cu, color cd) =>
    if A > 0
        float py = na
        int   px = na
        for k = 0 to nSeg
            t  = t0 + k * stepN
            v  = (a * math.cos(wfreq * t) + b * math.sin(wfreq * t)) / A
            yy = off + v * normAmp
            if not na(py) and array.size(arr) < 490
                col = yy >= py ? cu : cd
                array.push(arr, line.new(px, py, t, yy, xloc = xloc.bar_index, color = color.new(col, 25), width = 2))
            py := yy
            px := t

var line[] projLines = array.new<line>()

if barstate.islast
    for ln in projLines
        line.delete(ln)
    array.clear(projLines)
    if showProj and supported
        nSeg = int(projBars / projStep)
        t0   = bar_index
        drawProj(projLines, a1, b1, A1, off1, om1, t0, nSeg, projStep, upCol, dnCol)
        drawProj(projLines, a2, b2, A2, off2, om2, t0, nSeg, projStep, upCol, dnCol)
        drawProj(projLines, a3, b3, A3, off3, om3, t0, nSeg, projStep, upCol, dnCol)
        float pyP = na
        int   pxP = na
        for k = 0 to nSeg
            if not showPush
                break
            t  = t0 + k * projStep
            v1 = A1 > 0 ? (a1 * math.cos(om1 * t) + b1 * math.sin(om1 * t)) / A1 : 0.0
            v2 = A2 > 0 ? (a2 * math.cos(om2 * t) + b2 * math.sin(om2 * t)) / A2 : 0.0
            v3 = A3 > 0 ? (a3 * math.cos(om3 * t) + b3 * math.sin(om3 * t)) / A3 : 0.0
            vp = wsum > 0 ? (wgt1 * v1 + wgt2 * v2 + wgt3 * v3) / wsum : 0.0
            yy = offP + vp * normAmp
            if not na(pyP) and array.size(projLines) < 490
                col = yy >= pyP ? upCol : dnCol
                array.push(projLines, line.new(pxP, pyP, t, yy, xloc = xloc.bar_index, color = color.new(col, 25), width = 2))
            pyP := yy
            pxP := t

// ---------- Info table ----------
var table tbl = table.new(position.top_right, 4, 5, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 50))

f_dir(b) => b ? "up" : "down"
f_dcol(b) => b ? upCol : dnCol

if barstate.islast
    hdrBg = color.new(color.black, 0)
    table.cell(tbl, 0, 0, "Hurst cycle", text_color = color.white, bgcolor = hdrBg, text_size = size.small)
    table.cell(tbl, 1, 0, "bars / wk",   text_color = color.white, bgcolor = hdrBg, text_size = size.small)
    table.cell(tbl, 2, 0, "sig",         text_color = color.white, bgcolor = hdrBg, text_size = size.small)
    table.cell(tbl, 3, 0, "dir",         text_color = color.white, bgcolor = hdrBg, text_size = size.small)

    table.cell(tbl, 0, 1, "40-week", text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(p1) + " / " + str.tostring(wk1, "0.0"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 1, str.tostring(sig1, "0.00"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 3, 1, supported ? f_dir(up1) : "-", text_color = f_dcol(up1), text_size = size.small)

    table.cell(tbl, 0, 2, "20-week", text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(p2) + " / " + str.tostring(wk2, "0.0"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 2, str.tostring(sig2, "0.00"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 3, 2, supported ? f_dir(up2) : "-", text_color = f_dcol(up2), text_size = size.small)

    table.cell(tbl, 0, 3, "10-week", text_color = color.white, text_size = size.small)
    table.cell(tbl, 1, 3, str.tostring(p3) + " / " + str.tostring(wk3, "0.0"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 2, 3, str.tostring(sig3, "0.00"), text_color = color.white, text_size = size.small)
    table.cell(tbl, 3, 3, supported ? f_dir(up3) : "-", text_color = f_dcol(up3), text_size = size.small)

    regime = not supported ? "use D/W/M" : allUp ? "ALL UP" : allDn ? "ALL DOWN" : "MIXED"
    regCol = not supported ? color.gray : allUp ? upCol : allDn ? dnCol : color.gray
    table.cell(tbl, 0, 4, "today", text_color = color.white, bgcolor = color.new(color.black, 0), text_size = size.small)
    table.cell(tbl, 1, 4, "", bgcolor = color.new(color.black, 0))
    table.cell(tbl, 2, 4, "", bgcolor = color.new(color.black, 0))
    table.cell(tbl, 3, 4, regime, text_color = regCol, bgcolor = color.new(color.black, 0), text_size = size.small)

// ---------- Timeframe guard ----------
var label tfWarn = na
if barstate.islast
    label.delete(tfWarn)
    if not supported
        tfWarn := label.new(bar_index, offP - normAmp - 0.8, "These are multi-week cycles. Use a daily, weekly, or monthly timeframe.", color = color.new(color.orange, 15), textcolor = color.black, style = label.style_label_up, size = size.small)
````
