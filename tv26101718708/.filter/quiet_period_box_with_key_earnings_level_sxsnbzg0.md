# Quiet Period Box with Key Earnings Level

- url: https://www.tradingview.com/script/SXsNbZG0-Quiet-Period-Box-with-Key-Earnings-Level/
- type: indicator
- pine_id: PUB;0f918ab8c0b549429c8ff338810acf54
- version: 1.0

## Description

The green box is the new programming for the "Quiet Period" to show when a company doesn't comment on anything about the prospects for the company which means that analysts can have an undue influence on the stock price during the quiet period. 

Once the company reports earnings, a "Green Triangle" is created to include the day before and the day after the earnings announcement to then reveal the important price level, or "Key Level" which is the mid-point of this price action around the earnings release.

How to USE the indicator: The interesting part of this analysis is how these reference price levels have an influence in the future trading of shares. If a stock is in a bullish trend, the mid-point of the earnings release is the ideal, low-risk point to enter long with a stop 1, 2 or 3 ranges on the other side of the "Key Level" in case it doesn't work out. The target can be a variety of techniques from using the width of the "quiet period" range added to the "earnings level" to derive a price target. 

The inverse would also be true. If the general trend of a stock was down, the mid-point of the 'earnings level' would provide supply and stop the price advance after a down move on earnings. You can see for yourself looking back over the history of the stock whether or not this method would be a profitable approach or not. 

What I like is having the knowledge of where the important levels are on a stock chart so when the price gets there I can then decide whether or not to take a trade. You can set alerts on the "earnings level" and the highs and lows of the "quiet period" box to alert you to when a stock is worth looking at.

Over a year ago, I made the "Earnings Level" free to all users here at TradingView after keeping it a fee-based private indicator for close to 10 years. I feel a great debt of gratitude for TradingView for creating this wonderful platform for all of us to share ideas and I wanted everyone to have this powerful indicator to help investors and traders alike.

Now with this "Quiet Period" box publication, the patterns in the chaos of market action can be more easily found and you can be more at peace with the volatility in each stock when you can see the stock has been in a pre-defined time-zone for comparison.

Wishing you all the best of good fortune in your investing and trading and I look forward to hearing your questions. 

A huge thank you goes to Ivan Labrie here at TradingView @IvanLabrie for writing the code for this indicator. He is a champion of technical analysis and the many methods of the Time@Mode, Key Earnings, Risk, Reward, Psychology, Trend and options strategies.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © timwest
//@version=6
// ============================================================================
//  KEY EARNINGS SUPPORT - Earnings volatility & support study
//  Concept: Tim West (KnowVera)
// ----------------------------------------------------------------------------
//  Three things, all computed on the DAILY timeframe and anchored by absolute
//  date + price, so they stay STATIC no matter what timeframe the chart is on
//  (multi-timeframe / MTF). Switch from 1H to 4H to Daily - the drawings don't
//  move.
//
//   1) QUIET PERIOD BOX  - a light-green box over the ~2 weeks (blackout window)
//      before each earnings release, so you can see how price behaves into the
//      report. Box height = the daily high/low of that 2-week window.
//
//   2) KEY EARNINGS SUPPORT - for every report, the midpoint of the true range
//      from the day BEFORE to the day AFTER earnings, projected forward as a
//      horizontal support line (1 / 3 / 6 / 9 / 12 months). These stack into a
//      ladder of earnings-anchored support levels.
//
//   3) RANGE TRIANGLE - a filled green triangle (darker than the box): base runs
//      from the high to the low of that day-before->day-after range, apex sits a
//      few (default 7) daily bars to the right, level with the range midpoint.
//
//  Notes / limitations:
//    * Earnings data exists for STOCKS only; other symbols show nothing.
//    * request.earnings() only knows HISTORICAL report dates - the next date is
//      not available to Pine, so the upcoming quiet period is projected from a
//      confirmed date you paste in (or estimated from the last report + gap).
//    * Everything is measured on Daily. Works on Daily and all INTRADAY charts.
//      On charts HIGHER than daily (Weekly/Monthly) some events can be missed -
//      view on Daily or intraday for the full set.
//    * How far back it draws depends on how many bars TradingView loads.
// ============================================================================

indicator("Key Earnings Support", shorttitle = "Key Earn", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100)

// --- Inputs -----------------------------------------------------------------
grpBox    = "Quiet period box (2 weeks)"
showBox   = input.bool(true, "Show quiet-period box", group = grpBox)
qpDays    = input.int(14, "Quiet period length (calendar days)", minval = 1, group = grpBox, tooltip = "Tim West's quiet period = the 2 weeks (14 calendar days) before an earnings release.")
shadeCol  = input.color(color.new(color.green, 70), "Shading", group = grpBox)   // matches the triangle fill (70) so box + triangle read as one "house" / home level
borderCol = input.color(color.new(color.green, 55), "Border",  group = grpBox)
padPct    = input.float(0.5, "Box vertical padding (%)", minval = 0, group = grpBox) / 100.0

grpRange  = "Earnings range (day-before -> day-after)"
earnBars  = input.int(1, "Bars before/after the report", minval = 0, maxval = 10, group = grpRange, tooltip = "1 = day-before + report-day + day-after (Daily). Shared by the support level and the triangle.")

grpSup     = "Key earnings support"
showSup    = input.bool(true, "Show support levels", group = grpSup)
supMonths  = input.int(3, "Project forward (months)", options = [1, 3, 6, 9, 12], group = grpSup)
supCol     = input.color(color.rgb(0, 100, 0), "Support line color", group = grpSup)   // dark green
supWidth   = input.int(2, "Support line width", minval = 1, group = grpSup)
showSupLbl = input.bool(true, "Label support price", group = grpSup)

grpTri  = "Range triangle"
showTri = input.bool(true, "Show range triangle", group = grpTri)
triBars = input.int(7, "Apex - daily bars right of report", minval = 1, group = grpTri)
triFill = input.color(color.new(color.green, 70), "Triangle fill", group = grpTri)   // darker than the box
triLine = input.color(color.new(color.green, 20), "Triangle edge", group = grpTri)

grpNext    = "Upcoming quiet period"
projNext   = input.bool(true, "Project the next (upcoming) quiet period", group = grpNext)
manualNext = input.time(timestamp("01 Jan 1970 00:00 +0000"), "Confirmed next earnings date (optional)", group = grpNext, tooltip = "Paste the confirmed next earnings date from TradingView / your broker. Leave at 1970 to auto-estimate from the last report + the gap below.")
gapDays    = input.int(91, "Estimated days between earnings", minval = 1, group = grpNext, tooltip = "Used only when no confirmed date is set. ~91 days ~ quarterly.")
projCol    = input.color(color.new(color.orange, 82), "Projected shading", group = grpNext)

grpLbl    = "Labels & stats"
showDrift = input.bool(false, "Label each box with its drift %", group = grpLbl)
showQpRng = input.bool(true, "Label each box with avg range (% of midpoint)", group = grpLbl)
showTable = input.bool(false, "Show stats table", group = grpLbl)

// --- Constants / derived ----------------------------------------------------
msPerDay   = 86400000
qpMs       = qpDays * msPerDay
qpBars     = math.max(1, int(math.round(qpDays * 252.0 / 365.25)))   // 2 weeks ~ 10 daily bars
CAL_PER_TD = 365.25 / 252.0                                          // calendar days per trading day
MS_PER_MO  = 30.4375 * msPerDay                                      // avg calendar month

// --- Daily computation (runs in Daily context -> static across chart TF) -----
// Detected on the "day after" the report (offset = earnBars) so the full
// day-before->day-after range exists. Returns na except on those event bars.
computeDaily() =>
    e      = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, ignore_invalid_symbol = true)
    isEvt  = not na(e[earnBars])                       // report landed earnBars daily bars ago
    winN   = 2 * earnBars + 1
    rHiR   = ta.highest(high, winN)                    // day-before->day-after high  (ends on current = day-after)
    rLoR   = ta.lowest(low, winN)                      // day-before->day-after low
    qHiR   = ta.highest(high, qpBars)                  // 2-week window high  (index back to the day BEFORE the report)
    qLoR   = ta.lowest(low, qpBars)
    qRngR  = ta.sma((high - low) / close * 100.0, qpBars)
    qRngAbsR = ta.sma(high - low, qpBars)              // avg daily range (absolute); shown as % of the box midpoint
    rt     = time[earnBars]                            // report day's timestamp
    qEnd   = time[earnBars + 1]                        // quiet period ends the day BEFORE the report (earnings vol excluded)
    rC     = close[earnBars + 1]                       // close at the end of the quiet period (day before report)
    sC     = close[earnBars + qpBars]                  // close at the start of the 2-week window
    drift  = sC != 0 ? (rC / sC - 1.0) * 100.0 : na
    [isEvt ? rt : na, isEvt ? qEnd : na, isEvt ? rHiR : na, isEvt ? rLoR : na, isEvt ? qHiR[earnBars + 1] : na, isEvt ? qLoR[earnBars + 1] : na, isEvt ? drift : na, isEvt ? qRngR[earnBars + 1] : na, isEvt ? qRngAbsR[earnBars + 1] : na]

[rt, qEnd, rHi, rLo, qHi, qLo, qDrift, qRange, qRngAbs] = request.security(syminfo.tickerid, "D", computeDaily(), gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off)

// Daily baseline volatility + recent range for the projected box (latest value)
dBase = request.security(syminfo.tickerid, "D", ta.cum((high - low) / close * 100.0) / (bar_index + 1), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[dHi20, dLo20] = request.security(syminfo.tickerid, "D", [ta.highest(high, 20), ta.lowest(low, 20)], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// --- Per-event drawing (fires once per earnings, regardless of chart TF) -----
var float sumDrift = 0.0
var float sumRange = 0.0
var int   nEvents  = 0
var int   lastRt   = na

newEvt = not na(rt)

if newEvt
    rangeMid = (rHi + rLo) / 2.0

    // 1) quiet-period box (2-week window high/low)
    if showBox
        box.new(qEnd - qpMs, qHi * (1 + padPct), qEnd, qLo * (1 - padPct), xloc = xloc.bar_time, border_color = borderCol, bgcolor = shadeCol)
        if showDrift and not na(qDrift)
            sgn = qDrift >= 0 ? "+" : ""
            label.new(qEnd - int(qpMs / 2), qHi * (1 + padPct), "drift " + sgn + str.tostring(qDrift, "0.0") + "%", xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.green, 30), textcolor = color.white, size = size.small)
        if showQpRng and not na(qRngAbs)
            qpMid = (qHi + qLo) / 2.0
            avgRngMidPct = qpMid != 0 ? qRngAbs / qpMid * 100.0 : na
            label.new(qEnd - int(qpMs / 2), qLo * (1 - padPct), "avg rng " + str.tostring(avgRngMidPct, "0.0") + "%", xloc = xloc.bar_time, style = label.style_label_up, color = color.new(color.green, 60), textcolor = color.white, size = size.small)

    // 2) key earnings support (midpoint of the day-before->day-after range)
    if showSup
        tEnd = rt + int(supMonths * MS_PER_MO)
        line.new(rt, rangeMid, tEnd, rangeMid, xloc = xloc.bar_time, color = supCol, width = supWidth)
        if showSupLbl
            label.new(tEnd, rangeMid, "Earnings Level " + str.tostring(rangeMid, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(supCol, 80), textcolor = supCol, size = size.small)

    // 3) range triangle (base = range high->low, apex = triBars daily bars right, at midpoint)
    if showTri
        apexTime = rt + int(triBars * CAL_PER_TD * msPerDay)
        pts = array.new<chart.point>()
        array.push(pts, chart.point.from_time(rt,       rHi))
        array.push(pts, chart.point.from_time(rt,       rLo))
        array.push(pts, chart.point.from_time(apexTime, rangeMid))
        polyline.new(pts, closed = true, xloc = xloc.bar_time, line_color = triLine, fill_color = triFill, line_width = 1)

    // stats
    sumDrift += nz(qDrift)
    sumRange += nz(qRange)
    nEvents  += 1
    lastRt   := rt

// --- Project the upcoming quiet period --------------------------------------
useManual = manualNext > timestamp("01 Jan 2000 00:00 +0000")
nextEarn  = useManual ? manualNext : (na(lastRt) ? na : lastRt + gapDays * msPerDay)

if projNext and barstate.islast and not na(nextEarn)
    qpEnd  = nextEarn - msPerDay                        // upcoming quiet period also ends the day before earnings
    tStart = qpEnd - qpMs
    box.new(tStart, dHi20 * (1 + padPct), qpEnd, dLo20 * (1 - padPct), xloc = xloc.bar_time, border_color = color.new(color.orange, 30), border_style = line.style_dashed, bgcolor = projCol)
    label.new(nextEarn, dHi20 * (1 + padPct), "Next earnings\n(" + (useManual ? "confirmed" : "est.") + ")", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.orange, 30), textcolor = color.white, size = size.small)

// --- Stats table ------------------------------------------------------------
var table t = table.new(position.top_right, 2, 6, border_width = 1, frame_color = color.gray, frame_width = 1)

if showTable and barstate.islast
    baseRange = dBase
    avgDrift  = nEvents > 0 ? sumDrift / nEvents : na
    avgRng    = nEvents > 0 ? sumRange / nEvents : na
    haveStats = nEvents > 0 and not na(avgRng) and not na(baseRange)
    calmer    = haveStats and avgRng < baseRange

    table.cell(t, 0, 0, "Quiet Period Study", text_color = color.white, bgcolor = color.new(color.green, 20), text_size = size.small)
    table.cell(t, 1, 0, "", bgcolor = color.new(color.green, 20))
    table.cell(t, 0, 1, "Earnings shown", text_size = size.small)
    table.cell(t, 1, 1, str.tostring(nEvents), text_size = size.small)
    table.cell(t, 0, 2, "Avg drift in QP", text_size = size.small)
    table.cell(t, 1, 2, nEvents > 0 ? (avgDrift >= 0 ? "+" : "") + str.tostring(avgDrift, "0.0") + "%" : "n/a", text_size = size.small)
    table.cell(t, 0, 3, "Avg daily range - QP", text_size = size.small)
    table.cell(t, 1, 3, nEvents > 0 ? str.tostring(avgRng, "0.00") + "%" : "n/a", text_size = size.small)
    table.cell(t, 0, 4, "Avg daily range - all", text_size = size.small)
    table.cell(t, 1, 4, str.tostring(baseRange, "0.00") + "%", text_size = size.small)
    table.cell(t, 0, 5, "QP vs all (range)", text_size = size.small)
    table.cell(t, 1, 5, haveStats ? str.tostring(avgRng / baseRange, "0.00") + "x" : "n/a", text_size = size.small, text_color = calmer ? color.green : color.red)
````
