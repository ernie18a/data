# Hall Lag Line Oscillator

- url: https://www.tradingview.com/script/XI7uUzcL-Hall-Lag-Line-Oscillator/
- type: indicator
- pine_id: PUB;4f69a91d78ab4b8588d3efcb2d70ff14
- version: 1.0

## Description

█ [b]OVERVIEW[/b]

Hall Lag Line Oscillator plots, in its own pane, the percent distance between price and Alan Hall's lag line, a six-month average of price moved six months forward. Each column is colored by one of four states that combine where price sits relative to the line with the direction the line is moving. Small triangles mark the bars on which price closes beyond the line by more than a set band after being on the other side of it.

Thesis: stock prices register a change in collective mood first and economic and political news follows months later, so the distance between price and a delayed average of price shows how far mood has moved ahead of the news.


█ [b]HISTORY / BACKGROUND[/b]

The lag line comes from Alan Hall, chapter 8 of [i]The Socionomic Theory of Finance[/i] by Robert R. Prechter (2016). Hall defines it as a six-month moving average of a major U.S. stock average, shifted six months into the future. He presents it as an estimate of when lagging expressions of social mood, such as economic and political news, will turn. He reports that at major extremes over the past century it turned roughly nine months after stock prices, and he describes it as the approximate center of a broad band of probability, not an exact timing line.

The conceptual basis is socionomic theory. In that framework social mood is the independent variable. Stock prices register a change in mood first, because a trade can be placed at once. Economic statistics and political events express the same mood later, because the actions behind them take longer to carry out. A.J. Frost and Robert Prechter make a related point in [i]Elliott Wave Principle[/i]: the news tends to trail the market by a wave or two.

Hall does not specify the type of average or the data frequency, and he gives no rules for states or signals. The calendar-month construction, the four states, the hysteresis bands, the cross markers and the scheduled turn readout are original to this script.


█ [b]HOW IT WORKS[/b]

The script uses only the chart's own bars. It makes no higher-timeframe requests.

1. Calendar months. A helper moves any bar time forward or back by whole calendar months in the exchange time zone and keeps the time of day. When the target month is shorter, the day is clamped to that month's last day, so August 31 minus six months is February 28 or 29.
2. Trailing average. For each bar, the script averages every close whose bar time falls after the point [i]Average window[/i] months earlier, up to and including the current bar. A running sum over a queue keeps this efficient. The average is reported only once the loaded history reaches back past the start of the window.
3. Lag line. The lag line at a bar is the trailing average as of the last bar at or before the point [i]Forward shift[/i] months earlier. A second queue returns the same quantity one month further back, which is the line's value one month ago.
4. Gap. Gap = 100 × (close ÷ lag line - 1). The columns plot this value.
5. Line slope. Slope = 100 × (lag line ÷ lag line one month earlier - 1), in percent per month.
6. Position, with hysteresis. Position starts as above or below from the sign of the gap. It switches to below only when the gap falls under minus [i]Price band[/i], and back to above only when the gap rises over plus [i]Price band[/i].
7. Direction, with hysteresis. Direction starts as rising or falling from the sign of the slope. It switches to falling only when the slope falls under minus [i]Slope band[/i], and back to rising only when the slope rises over plus [i]Slope band[/i].
8. State. Above and rising is state 1. Below and rising is state 2. Below and falling is state 3. Above and falling is state 4.
9. Crosses. An up cross is a confirmed bar on which position switches from below to above. A down cross is a confirmed bar on which it switches from above to below. The check uses `barstate.isconfirmed`.
10. Scheduled turn. Every line value is an average of closes at least [i]Forward shift[/i] months old, so the next [i]Forward shift[/i] months of the line are already set by existing bars. On the last bar the script walks those coming values and reports the first date on which the one-month change would pass the slope band in the opposite direction. This feeds the status table.


█ [b]HOW TO USE[/b]

[b]Where to use it.[/b] Use it on major stock indexes and sector ETFs. The method reads price as a gauge of crowd mood. An index or a sector fund averages many companies, so company-specific events cancel out. On a single stock the script still runs, but the line then trails company news such as earnings, and the four states lose the meaning described here.

[b]Which timeframe.[/b] Use the daily chart. The script is built for daily, weekly and monthly charts and refuses intraday charts, because its windows are measured in months. The windows are calendar months, not bar counts, so the line is nearly the same on all three timeframes. The daily chart is recommended because a daily close is the first to confirm a cross. Weekly is the fallback if daily crosses flip back and forth near the band.

[b]Reading the columns.[/b] The solid zero line is the lag line. A column above zero means price is above the line, and its height is the distance in percent. A column below zero means price is under the line. The dotted lines mark the price band on each side.

[b]Reading the colors.[/b]
 • Blue, state 1. Price is above the line and the line is rising. Mood and the lagging news agree on the upside.
 • Orange, state 2. Price is below the line and the line is still rising. Price has turned down while the news gauge is still rising, so good news in this phase is the lagging echo of the earlier advance.
 • Green, state 3. Price is below the line and the line is falling. Mood and the lagging news agree on the downside.
 • Gold, state 4. Price is above the line and the line is still falling. Price has turned up while the news gauge is still falling, so bad news in this phase is the lagging echo of the earlier decline.
 • Gray. Not enough history yet.

The states usually run in the order 1, 2, 3, 4 and back to 1. When orange goes straight back to blue, the decline was too short to turn the line.

[b]Reading the triangles.[/b] An up triangle at the bottom of the pane marks a close more than the price band above the line after a spell below it. A down triangle at the top marks a close more than the price band below the line after a spell above it. Both print only when the bar closes.

[b]Bottoms and tops.[/b] The indicator is more useful at the end of declines than at the end of advances. Both kinds of cross arrive some months after the turn in price, by construction. Declines are usually shorter and faster than advances, so the same delay uses up a larger share of a decline than of the advance that follows it. Read an up triangle as the indicator's confirmation that a decline has ended. Read a down triangle as late confirmation that a decline is under way, not as a top signal.

[b]Status table.[/b] The table is off by default. When it is on, it shows the current state, the date that state began, the current gap, the line's direction, and the next scheduled change in the line's direction within the next [i]Forward shift[/i] months.

[b]Alerts.[/b] Six alert conditions are available: Up cross, Down cross, State 1, State 2, State 3 and State 4.


█ [b]SETTINGS[/b]
 • [i]Average window (months)[/i]. Default 6, range 1 to 24. Sets the length of the trailing calendar window that is averaged.
 • [i]Forward shift (months)[/i]. Default 6, range 1 to 24. Sets how far forward the average is moved. It also sets how far ahead the status table looks for a line turn.
 • [i]Price band (%)[/i]. Default 2.0. Sets how far beyond the line price must close to switch position and print a triangle. It also places the two dotted lines.
 • [i]Slope band (% per month)[/i]. Default 0.25. Sets how much the line must change over one month to switch direction.
 • [i]Show status table[/i]. Default off.
 • [i]Show cross markers[/i]. Default on.


█ [b]WHAT MAKES IT ORIGINAL[/b]

Hall published the lag line as a chart overlay and a reading aid. He gave no oscillator, no states and no rules. This script differs in five ways.
 • It measures both the averaging window and the forward shift in calendar months in the exchange time zone, not in bar counts. The line is therefore close to identical on daily, weekly and monthly charts, and holidays or changes in the number of trading days do not shorten the window.
 • It turns the line into an oscillator of percent distance, so the gap between mood and lagging news reads as a number.
 • It classifies every bar into one of four states from two separate tests, price position and line direction, each with its own hysteresis band. The two divergent states put Hall's idea that news lags mood into explicit terms that can be checked against events.
 • It uses the fact that the line is built from past closes. The next [i]Forward shift[/i] months of the line are already set, and the script reports the next scheduled change in the line's direction.
 • It marks band crosses on confirmed bars only.


█ [b]NOTES / LIMITATIONS[/b]
 • Timeframes. Daily, weekly and monthly only. On an intraday chart the script stops with an error message.
 • History. The gap needs [i]Average window[/i] plus [i]Forward shift[/i] months of loaded history, 12 months by default, and the states need one month more. Until then the columns are gray or absent. A symbol with less history shows no states.
 • Built-in delay. Every value of the line is an average of closes at least [i]Forward shift[/i] months old. With the defaults the line typically turns six to ten months after a price extreme, mostly because of the averaging and the shift, and both kinds of cross occur after the turn in price.
 • Open bar. The script makes no higher-timeframe requests and uses no lookahead. Lag line values come from closed bars and do not change. On the open bar, the column height, its color and the state follow the live price and can change before the close. The scheduled turn date in the table can also change, because its newest value includes the live close. Triangles and the Up cross and Down cross alerts wait for the bar to close. The State alerts can fire during the bar, so set them to trigger once per bar close.
 • Forward window. The status table looks only [i]Forward shift[/i] months ahead. "None before" a date means no turn inside that window, not that none follows.
 • Symbol type. The code does not check symbol type. The interpretation in this description assumes a broad index or a sector ETF. A single stock can also gap through the band on one company report.
 • Calendar rules. Month shifts use the exchange time zone and clamp to the last day of shorter months.

## Source Code

````pine
//@version=6
// Hall lag oscillator
//
// Built on the Hall lag line: Alan Hall, chapter 8 in Robert Prechter (2016), The Socionomic
// Theory of Finance. Hall defines the line as a six-month moving average of the DJIA moved six
// months forward, an estimate of when lagging news (economic, political) turns. Hall gives no
// rules. The four states below are this script's construction, not Hall's.
//
// Gap: percent distance of price from the lag line. Price stands for current mood, the line for
// the tone of lagging news.
// Line direction: the lag line's change over one calendar month, in percent.
//
// States
//   1  price above line, line rising    mood up, news up            (aligned)
//   2  price below line, line rising    mood turned down, news up   (news lags)
//   3  price below line, line falling   mood down, news down        (aligned)
//   4  price above line, line falling   mood turned up, news down   (news lags)
// Normal order is 1, 2, 3, 4, 1. Hysteresis: price must cross the line by the price band, and the
// line's monthly change must pass the slope band, before a state changes.
//
// Crosses: a down triangle at the top of the pane when price closes more than the price band below
// the line, an up triangle at the bottom when it closes more than the band back above. Line
// direction plays no part. Markers and alerts fire on confirmed bars.
//
// The lag line is fixed six months ahead, so a coming change in line direction is known now.
// The table reports it as the scheduled line turn.
//
// Daily, weekly or monthly charts only. Use on TVC:DJI, SP:SPX, NASDAQ:IXIC or any symbol.
indicator("Hall lag oscillator", overlay = false)

int   avgMonths   = input.int(6, "Average window (months)", minval = 1, maxval = 24)
int   shiftMonths = input.int(6, "Forward shift (months)", minval = 1, maxval = 24)
float priceBand   = input.float(2.0, "Price band (%)", minval = 0.0, step = 0.5)
float slopeBand   = input.float(0.25, "Slope band (% per month)", minval = 0.0, step = 0.05)
bool  showTable   = input.bool(false, "Show status table")
bool  showSignals = input.bool(true, "Show cross markers")

// Categorical colors in fixed order, validated for colorblind separation and 3:1 contrast on
// TradingView's dark background. Each state also carries a text label, so color is not the only cue.
color c1 = #3987e5
color c2 = #d95926
color c3 = #199e70
color c4 = #c98500
color c0 = color.gray

if timeframe.isintraday
    runtime.error("Hall lag oscillator: use a daily, weekly or monthly chart.")

// Number of days in month m (1 to 12) of year y.
daysInMonth(int y, int m) =>
    int nextIdx = y * 12 + m
    int ny      = math.floor(nextIdx / 12.0)
    int nm      = nextIdx - ny * 12 + 1
    dayofmonth(timestamp("UTC", ny, nm, 1, 0, 0) - 86400000, "UTC")

// Moves timestamp t by n calendar months in the exchange time zone and keeps the time of day.
// The day is clamped to the target month's length, so Aug 31 minus six months is Feb 28 or 29.
addMonths(int t, int n) =>
    string tz  = syminfo.timezone
    int    idx = year(t, tz) * 12 + month(t, tz) - 1 + n
    int    ty  = math.floor(idx / 12.0)
    int    tm  = idx - ty * 12 + 1
    int    td  = math.min(dayofmonth(t, tz), daysInMonth(ty, tm))
    timestamp(tz, ty, tm, td, hour(t, tz), minute(t, tz), second(t, tz))

// Value of series v as of the last bar at or before (time minus n months). Each call site keeps
// its own queue, so call it once per bar at global scope.
shiftBy(float v, int n) =>
    var array<int>   qt  = array.new<int>()
    var array<float> qv  = array.new<float>()
    var float        out = na
    qt.push(time)
    qv.push(v)
    int lb = addMonths(time, -n)
    while qt.size() > 0 and qt.first() <= lb
        qt.shift()
        out := qv.shift()
    out

// Simple average of all closes in the trailing window (windowStart, time].
var array<int>   winTime   = array.new<int>()
var array<float> winClose  = array.new<float>()
var float        winSum    = 0.0
var int          firstTime = time

winTime.push(time)
winClose.push(close)
winSum += close
int windowStart = addMonths(time, -avgMonths)
while winTime.size() > 0 and winTime.first() <= windowStart
    winTime.shift()
    winSum -= winClose.shift()
float avg = firstTime <= windowStart ? winSum / winClose.size() : na

float lag     = shiftBy(avg, shiftMonths)
float lagPrev = shiftBy(avg, shiftMonths + 1)
float gap     = 100 * (close / lag - 1)
float slope   = 100 * (lag / lagPrev - 1)

// Position of price against the line (1 above, -1 below) and line direction (1 rising,
// -1 falling), each with hysteresis. 0 means not enough history yet.
var int pos = 0
var int dir = 0
if not na(gap)
    if pos == 0
        pos := gap > 0 ? 1 : -1
    else if pos == 1 and gap < -priceBand
        pos := -1
    else if pos == -1 and gap > priceBand
        pos := 1
if not na(slope)
    if dir == 0
        dir := slope > 0 ? 1 : -1
    else if dir == 1 and slope < -slopeBand
        dir := -1
    else if dir == -1 and slope > slopeBand
        dir := 1

int state = pos == 0 or dir == 0 ? 0 : pos == 1 ? (dir == 1 ? 1 : 4) : (dir == 1 ? 2 : 3)
color stateColor = switch state
    1 => c1
    2 => c2
    3 => c3
    4 => c4
    => c0

var int stateSince = na
bool changed = state != nz(state[1])
if changed
    stateSince := time

plot(gap, "Gap from lag line (%)", stateColor, style = plot.style_columns)
hline(0, "Lag line", color.new(color.gray, 30), hline.style_solid)
hline(priceBand, "Upper band", color.new(color.gray, 60), hline.style_dotted)
hline(-priceBand, "Lower band", color.new(color.gray, 60), hline.style_dotted)

// Crosses: price crosses the line by more than the price band, judged at the bar close.
bool upCross   = barstate.isconfirmed and pos == 1 and nz(pos[1]) == -1
bool downCross = barstate.isconfirmed and pos == -1 and nz(pos[1]) == 1
color markColor = color.new(chart.fg_color, 30)
plotshape(showSignals and upCross, "Up cross", shape.triangleup, location.bottom, markColor, size = size.tiny)
plotshape(showSignals and downCross, "Down cross", shape.triangledown, location.top, markColor, size = size.tiny)
alertcondition(upCross, "Up cross", "Hall lag oscillator: price closed more than the band above the lag line")
alertcondition(downCross, "Down cross", "Hall lag oscillator: price closed more than the band below the lag line")

alertcondition(changed and state == 1, "State 1", "Hall lag oscillator: state 1, price above line, line rising")
alertcondition(changed and state == 2, "State 2", "Hall lag oscillator: state 2, price below line, line rising")
alertcondition(changed and state == 3, "State 3", "Hall lag oscillator: state 3, price below line, line falling")
alertcondition(changed and state == 4, "State 4", "Hall lag oscillator: state 4, price above line, line falling")

// History of averages back to (shiftMonths + 2) months, used to read the fixed future line.
var array<int>   hT = array.new<int>()
var array<float> hA = array.new<float>()
hT.push(time)
hA.push(avg)
int keepFrom = addMonths(time, -(shiftMonths + 2))
while hT.size() > 1 and hT.get(1) <= keepFrom
    hT.shift()
    hA.shift()

fmtDate(int t) =>
    str.format_time(t, "yyyy-MM-dd", syminfo.timezone)

var table tbl = table.new(position.top_right, 3, 5, border_width = 1)
if barstate.islast and showTable
    // Walk the not-yet-plotted part of the line and find the first direction change that would
    // pass the slope band.
    int nowLb    = addMonths(time, -shiftMonths)
    int turnTime = na
    int j        = -1
    for [i, t] in hT
        if t > nowLb and na(turnTime)
            int fT         = addMonths(t, shiftMonths)
            int prevTarget = addMonths(fT, -(shiftMonths + 1))
            while j + 1 < hT.size() and hT.get(j + 1) <= prevTarget
                j += 1
            float fl = hA.get(i)
            float fp = j >= 0 ? hA.get(j) : na
            if not na(fl) and not na(fp)
                float s = 100 * (fl / fp - 1)
                if (dir == 1 and s < -slopeBand) or (dir == -1 and s > slopeBand)
                    turnTime := fT

    string stateText = switch state
        1 => "1  Price above, line rising"
        2 => "2  Price below, line rising"
        3 => "3  Price below, line falling"
        4 => "4  Price above, line falling"
        => "Not enough history"
    string gapText  = na(gap) ? "n/a" : (gap >= 0 ? "+" : "") + str.tostring(gap, "0.0") + "%"
    string dirText  = dir == 1 ? "Rising" : dir == -1 ? "Falling" : "n/a"
    string turnText = na(turnTime) ? "None before " + fmtDate(addMonths(time, shiftMonths)) : (dir == 1 ? "Turns down " : "Turns up ") + fmtDate(turnTime)

    color ink   = chart.fg_color
    color muted = color.new(chart.fg_color, 40)
    table.cell(tbl, 0, 0, "", bgcolor = stateColor, width = 1)
    table.cell(tbl, 1, 0, "State", text_color = muted, text_halign = text.align_left)
    table.cell(tbl, 2, 0, stateText, text_color = ink, text_halign = text.align_left)
    table.cell(tbl, 1, 1, "Since", text_color = muted, text_halign = text.align_left)
    table.cell(tbl, 2, 1, na(stateSince) ? "n/a" : fmtDate(stateSince), text_color = ink, text_halign = text.align_left)
    table.cell(tbl, 1, 2, "Gap", text_color = muted, text_halign = text.align_left)
    table.cell(tbl, 2, 2, gapText, text_color = ink, text_halign = text.align_left)
    table.cell(tbl, 1, 3, "Line", text_color = muted, text_halign = text.align_left)
    table.cell(tbl, 2, 3, dirText, text_color = ink, text_halign = text.align_left)
    table.cell(tbl, 1, 4, "Line turn", text_color = muted, text_halign = text.align_left)
    table.cell(tbl, 2, 4, turnText, text_color = ink, text_halign = text.align_left)
````
