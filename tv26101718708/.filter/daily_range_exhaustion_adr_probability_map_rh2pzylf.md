# Daily Range Exhaustion - ADR Probability Map

- url: https://www.tradingview.com/script/rH2pZylf-Daily-Range-Exhaustion-ADR-Probability-Map/
- type: indicator
- pine_id: PUB;ec62915dba8b4e7b978337abe118a233
- version: 1.0

## Description

An intraday trader spends the whole session asking one question without ever measuring it: is there still room left in this move, or is the day already finished. Daily Range Exhaustion measures it.

The script records the completed range of every past day on the symbol you have open, and uses that sample to answer four things about the day in progress.

HOW MUCH OF THE DAY IS SPENT

Today's range is compared against the average daily range of the last 5, 10 or 20 days. The panel shows the result as a percentage. At 40 percent the day still has room in either direction. At 110 percent the day has already delivered more than an ordinary day and every further extension is, statistically, an outlier rather than the base case. The chart background tints once 100 percent is passed.

WHERE A FULL DAY COULD STILL REACH

Two levels are drawn:

Upside projection, today's low plus the average daily range. This is the highest point a statistically ordinary day could still print without becoming unusual.

Downside projection, today's high minus the average daily range.

Both compress as the session develops. Early in the day they sit far apart. By the afternoon they have squeezed toward price, and the distance left to each one is exactly the room the day has left. The shaded areas between price and each projection are that remaining room, made visible.

THE ODDS OF EXTENDING ANYWAY

Ranges are not a hard ceiling, so the panel reports how often the ceiling actually broke. Three lines show the share of past days whose range exceeded 100, 125 and 150 percent of the current average. On most liquid instruments roughly a quarter to a third of days exceed 100 percent, but far fewer reach 150 percent. Those numbers are the honest context for the exhaustion reading: they tell you whether a stretched day is rare or routine on this particular symbol.

WEEKDAY BREAKDOWN

A single average across all days hides a real effect. Many instruments have a quiet Monday and a violent Thursday, and judging Monday against a blended average will make it look exhausted when it is behaving normally. The panel breaks the sample down by weekday, shows the average range of each one, and expresses it as a percentage of the overall average. Today's weekday is highlighted.

HOW TO USE IT

As a filter on entries. Taking a fresh breakout when the day has already spent 120 percent of its average range is a different trade from taking the same breakout at 45 percent. The setup may be identical, the room available is not.

As target context. If the upside projection is 12 points away and your target is 30 points, the day would have to become a statistical outlier for that target to fill.

As mean reversion context. A day that hits the projection level and stalls has, by definition, reached the edge of its usual distribution.

As session planning. Check the weekday row before the session opens to know whether to expect a wide day or a narrow one.

NOTES ON THE DATA

The sample is built from the chart itself, so it needs history loaded. The panel shows a Building sample message and stays hidden until the minimum day count is reached, rather than showing statistics based on six observations.

Only intraday timeframes are supported. On a daily chart or higher the concept has no meaning, and the panel says so instead of printing misleading numbers.

Older days are dropped once the sample cap is reached, so the statistics follow the current volatility regime instead of averaging in a market from two years ago.

Days are bounded by the exchange session of the symbol. On instruments that trade nearly around the clock the day boundary is a convention, not a natural break, which slightly inflates the ranges of days that straddle a rollover.

WHAT IT IS NOT

There are no entry or exit signals here, and none are planned. This is context. A completed range is not a reversal signal, and an unfinished range is not a reason to expect continuation. Trends routinely spend two or three average ranges in a session, which is precisely why the extension odds are shown rather than hidden.

This is an analysis tool, not financial advice. Past distributions do not guarantee future ones. Use it alongside your own risk management and position sizing.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) AlgoForex Global

//@version=6
indicator("Daily Range Exhaustion - ADR Probability Map", "Range Exhaustion", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ============================================================================
//  DAILY RANGE EXHAUSTION
//  The Hourly Liquidity Clock answers WHEN the day moves.
//  This one answers HOW MUCH IS LEFT.
//
//  It measures the completed daily range of every past day on this symbol and
//  turns that sample into:
//     - how much of the average daily range today has already spent
//     - the two price levels a full-range day would still reach from here
//     - the historical odds of the day extending past 100 / 125 / 150 percent
//       of its own average range
//     - the average range of each weekday, so Monday is not judged by Friday
//
//  It is a CONTEXT tool. It produces no buy or sell signals.
// ============================================================================

// -------------------------------- PALETTE ----------------------------------
color C_UP   = #00c896
color C_DN   = #ff4b5c
color C_GOLD = #d4af37
color C_BG   = #0b0f18
color C_TXT  = #e6eaf2
color C_DIM  = #737d8c
color C_ROW  = #151a25

// -------------------------------- INPUTS -----------------------------------
G1 = "RANGE ENGINE"
G2 = "PROJECTIONS"
G3 = "PANEL"

adrPeriod = input.string("20 days", "Average Daily Range", options = ["5 days", "10 days", "20 days"], group = G1, tooltip = "Which average drives the projections and the exhaustion percentage. 5 reacts fast to a volatility change, 20 is the stable reference most desks use.")
maxDays   = input.int(250, "Days Kept In Sample", minval = 30, maxval = 1000, group = G1, tooltip = "Older days are dropped so the statistics describe the current regime.")
minDays   = input.int(20, "Minimum Days Before Showing Stats", minval = 10, maxval = 200, group = G1)

showProj  = input.bool(true, "Show Full-Range Projections", group = G2, tooltip = "Upside projection = today low plus the average range. Downside projection = today high minus the average range. They mark where a statistically ordinary day would still be able to reach.")
showOpen  = input.bool(true, "Show Day Open", group = G2)
showFill  = input.bool(true, "Shade Remaining Range", group = G2)
tintDone  = input.bool(true, "Tint Background Past 100 Percent", group = G2)

showPanel = input.bool(true, "Show Statistics Panel", group = G3)
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G3)
showWd    = input.bool(true, "Show Weekday Breakdown", group = G3)

// ============================================================================
//  1. DAILY RANGE COLLECTION
// ============================================================================
bool tooHigh = timeframe.in_seconds() >= 86400

bool newDay = ta.change(time("D")) != 0

var float dHigh = na
var float dLow  = na
var float dOpen = na
var int   dWd   = na

var float prevRange = na
var float prevWd    = na

var array<float> rngArr = array.new<float>()
var array<float> wdArr  = array.new<float>()

if newDay
    prevRange := na(dHigh) or na(dLow) ? na : dHigh - dLow
    prevWd    := na(dWd) ? na : float(dWd)
    dHigh := high
    dLow  := low
    dOpen := open
    dWd   := dayofweek
else
    dHigh := na(dHigh) ? high : math.max(dHigh, high)
    dLow  := na(dLow)  ? low  : math.min(dLow, low)
    dOpen := na(dOpen) ? open : dOpen
    dWd   := na(dWd)   ? dayofweek : dWd

// var arrays are NOT rolled back on realtime ticks, so the push is gated on a
// confirmed bar. Without this the same day would be counted many times.
if newDay and barstate.isconfirmed and not na(prevRange) and not tooHigh
    array.push(rngArr, prevRange)
    array.push(wdArr, prevWd)
    if array.size(rngArr) > maxDays
        array.shift(rngArr)
        array.shift(wdArr)

int  nDays   = array.size(rngArr)
bool hasData = nDays >= minDays and not tooHigh

// ============================================================================
//  2. STATISTICS
// ============================================================================
f_adr(int n) =>
    int sz = array.size(rngArr)
    int cnt = math.min(n, sz)
    float s = 0.0
    if cnt > 0
        for i = sz - cnt to sz - 1
            s += array.get(rngArr, i)
    cnt > 0 ? s / cnt : na

float adr5  = f_adr(5)
float adr10 = f_adr(10)
float adr20 = f_adr(20)
float adr   = adrPeriod == "5 days" ? adr5 : adrPeriod == "10 days" ? adr10 : adr20

float todayRange = na(dHigh) or na(dLow) ? na : dHigh - dLow
float usage      = hasData and adr > 0 ? 100.0 * todayRange / adr : na

// ============================================================================
//  3. PROJECTIONS
// ============================================================================
float projUp = hasData and not na(dLow)  and adr > 0 ? dLow + adr  : na
float projDn = hasData and not na(dHigh) and adr > 0 ? dHigh - adr : na

float toUp = na(projUp) ? na : projUp - close
float toDn = na(projDn) ? na : close - projDn

pUp   = plot(showProj ? projUp : na, "Upside Projection", color = C_UP, style = plot.style_linebr, linewidth = 2)
pDn   = plot(showProj ? projDn : na, "Downside Projection", color = C_DN, style = plot.style_linebr, linewidth = 2)
pOpen = plot(showOpen ? dOpen : na, "Day Open", color = C_DIM, style = plot.style_linebr, linewidth = 1)
pClose = plot(close, "Price Reference", color = color.new(color.white, 100))

fill(pUp, pClose, color = showFill and showProj and toUp > 0 ? color.new(C_UP, 93) : na, title = "Room Above")
fill(pDn, pClose, color = showFill and showProj and toDn > 0 ? color.new(C_DN, 93) : na, title = "Room Below")

bgcolor(tintDone and usage >= 100 ? color.new(C_GOLD, 92) : na, title = "Range Complete")

// ============================================================================
//  4. PANEL
// ============================================================================
f_pctAbove(float thresh) =>
    int sz = array.size(rngArr)
    int c = 0
    if sz > 0 and thresh > 0
        for i = 0 to sz - 1
            if array.get(rngArr, i) > thresh
                c += 1
    sz > 0 ? 100.0 * c / sz : na

f_wdAvg(int wd) =>
    int sz = array.size(wdArr)
    float s = 0.0
    int c = 0
    if sz > 0
        for i = 0 to sz - 1
            if int(array.get(wdArr, i)) == wd
                s += array.get(rngArr, i)
                c += 1
    c > 0 ? s / c : na

f_pos(string s) => s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : position.middle_right

f_wdName(int wd) => wd == 2 ? "Monday" : wd == 3 ? "Tuesday" : wd == 4 ? "Wednesday" : wd == 5 ? "Thursday" : wd == 6 ? "Friday" : wd == 7 ? "Saturday" : "Sunday"

cell(table t, int c, int r, string txt, color txtCol, color bg) =>
    table.cell(t, c, r, txt, text_color = txtCol, text_halign = text.align_center, bgcolor = bg, text_size = size.small)

if barstate.islast and showPanel
    var table p = table.new(f_pos(panelPos), 3, 18, bgcolor = color.new(C_BG, 5), border_width = 1, border_color = color.new(#2a2e39, 0), frame_width = 1, frame_color = color.new(#2a2e39, 0))

    cell(p, 0, 0, "RANGE EXHAUSTION", C_BG, C_GOLD)
    cell(p, 1, 0, syminfo.ticker, C_BG, C_GOLD)
    cell(p, 2, 0, timeframe.period, C_BG, C_GOLD)

    if tooHigh
        cell(p, 0, 1, "STATUS", C_TXT, color.new(C_ROW, 0))
        cell(p, 1, 1, "Use an intraday timeframe", C_DN, color.new(C_ROW, 0))
        cell(p, 2, 1, "4H or lower", C_DIM, color.new(C_ROW, 0))
    else if not hasData
        cell(p, 0, 1, "STATUS", C_TXT, color.new(C_ROW, 0))
        cell(p, 1, 1, "Building sample", C_GOLD, color.new(C_ROW, 0))
        cell(p, 2, 1, str.tostring(nDays) + " / " + str.tostring(minDays) + " days", C_DIM, color.new(C_ROW, 0))
    else
        cell(p, 0, 1, "Days sampled", C_DIM, color.new(C_ROW, 0))
        cell(p, 1, 1, str.tostring(nDays), C_TXT, color.new(C_ROW, 0))
        cell(p, 2, 1, adrPeriod + " ADR", C_DIM, color.new(C_ROW, 0))

        cell(p, 0, 2, "TODAY", C_TXT, color.new(C_ROW, 0))
        cell(p, 1, 2, "", C_TXT, color.new(C_ROW, 0))
        cell(p, 2, 2, f_wdName(dWd), C_DIM, color.new(C_ROW, 0))

        color useCol = usage >= 100 ? C_GOLD : usage >= 75 ? C_UP : C_TXT
        cell(p, 0, 3, "Range used", C_DIM, na)
        cell(p, 1, 3, str.tostring(todayRange, format.mintick), C_TXT, na)
        cell(p, 2, 3, str.tostring(usage, "#") + " %", useCol, na)

        cell(p, 0, 4, "Average range", C_DIM, na)
        cell(p, 1, 4, str.tostring(adr, format.mintick), C_TXT, na)
        cell(p, 2, 4, "5/10/20: " + str.tostring(adr5, "#.#") + " " + str.tostring(adr10, "#.#") + " " + str.tostring(adr20, "#.#"), C_DIM, na)

        cell(p, 0, 5, "Upside projection", C_DIM, na)
        cell(p, 1, 5, str.tostring(projUp, format.mintick), C_UP, na)
        cell(p, 2, 5, toUp > 0 ? str.tostring(toUp, format.mintick) + " away" : "reached", toUp > 0 ? C_TXT : C_UP, na)

        cell(p, 0, 6, "Downside projection", C_DIM, na)
        cell(p, 1, 6, str.tostring(projDn, format.mintick), C_DN, na)
        cell(p, 2, 6, toDn > 0 ? str.tostring(toDn, format.mintick) + " away" : "reached", toDn > 0 ? C_TXT : C_DN, na)

        cell(p, 0, 7, "EXTENSION ODDS", C_TXT, color.new(C_ROW, 0))
        cell(p, 1, 7, "", C_TXT, color.new(C_ROW, 0))
        cell(p, 2, 7, "share of past days", C_DIM, color.new(C_ROW, 0))

        float o100 = f_pctAbove(adr * 1.00)
        float o125 = f_pctAbove(adr * 1.25)
        float o150 = f_pctAbove(adr * 1.50)

        cell(p, 0, 8, "Exceeded 100 pct", C_DIM, na)
        cell(p, 1, 8, str.tostring(o100, "#.#") + " %", C_TXT, na)
        cell(p, 2, 8, str.tostring(adr * 1.00, format.mintick), C_DIM, na)

        cell(p, 0, 9, "Exceeded 125 pct", C_DIM, na)
        cell(p, 1, 9, str.tostring(o125, "#.#") + " %", C_TXT, na)
        cell(p, 2, 9, str.tostring(adr * 1.25, format.mintick), C_DIM, na)

        cell(p, 0, 10, "Exceeded 150 pct", C_DIM, na)
        cell(p, 1, 10, str.tostring(o150, "#.#") + " %", C_TXT, na)
        cell(p, 2, 10, str.tostring(adr * 1.50, format.mintick), C_DIM, na)

        if showWd
            cell(p, 0, 11, "AVERAGE BY WEEKDAY", C_TXT, color.new(C_ROW, 0))
            cell(p, 1, 11, "", C_TXT, color.new(C_ROW, 0))
            cell(p, 2, 11, "vs " + adrPeriod + " ADR", C_DIM, color.new(C_ROW, 0))

            for w = 2 to 6
                float wa = f_wdAvg(w)
                int   rw = 10 + w
                bool  isToday = dWd == w
                color rowBg = isToday ? color.new(C_GOLD, 85) : na
                float relPct = na(wa) or adr <= 0 ? na : 100.0 * wa / adr
                cell(p, 0, rw, f_wdName(w), isToday ? C_GOLD : C_DIM, rowBg)
                cell(p, 1, rw, na(wa) ? "-" : str.tostring(wa, format.mintick), C_TXT, rowBg)
                cell(p, 2, rw, na(relPct) ? "-" : str.tostring(relPct, "#") + " %", relPct >= 100 ? C_UP : C_DIM, rowBg)

// ============================================================================
//  5. ALERTS
// ============================================================================
bool hit80  = hasData and usage >= 80 and usage[1] < 80
bool hit100 = hasData and usage >= 100 and usage[1] < 100
bool tapUp  = hasData and not na(projUp) and high >= projUp and high[1] < projUp
bool tapDn  = hasData and not na(projDn) and low <= projDn and low[1] > projDn

alertcondition(hit80, title = "Range 80 Percent Used", message = "Range Exhaustion: {{ticker}} has used 80 percent of its average daily range")
alertcondition(hit100, title = "Range 100 Percent Used", message = "Range Exhaustion: {{ticker}} has completed its average daily range")
alertcondition(tapUp, title = "Upside Projection Reached", message = "Range Exhaustion: {{ticker}} reached the full-range upside projection")
alertcondition(tapDn, title = "Downside Projection Reached", message = "Range Exhaustion: {{ticker}} reached the full-range downside projection")

if hit100
    alert("Range Exhaustion - " + syminfo.ticker + " completed its average daily range", alert.freq_once_per_bar_close)
if tapUp
    alert("Range Exhaustion - " + syminfo.ticker + " reached the upside projection", alert.freq_once_per_bar_close)
if tapDn
    alert("Range Exhaustion - " + syminfo.ticker + " reached the downside projection", alert.freq_once_per_bar_close)
````
