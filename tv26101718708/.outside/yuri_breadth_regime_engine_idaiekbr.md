# YURI Breadth Regime Engine

- url: https://www.tradingview.com/script/IDAiekbr/
- type: indicator
- pine_id: PUB;afbec4282485439abf28dca0c451fd08
- version: 1.0

## Description

An index is capitalisation weighted. A handful of large members can hold the whole thing up while most of the list quietly breaks down underneath, and the price chart will not show you that, because the price chart is the weighted number. The count is a different number. This reads the count and tells you when the two have stopped agreeing.

THE TWO THINGS IT MEASURES

The level is how much of the list is participating right now. The default series is the percentage of S&P 500 members trading above their own 200 day moving average. Four bands: washout below 20, weak below 40, neutral below 60, strong above it. Below 20 has historically been forced selling rather than opinion, because most of the list is under its own annual average at the same time. Those readings cluster near the end of declines rather than the start. That is an observation about where they have occurred, not an instruction to buy them.

The participation read is a different question: is the index outrunning its own members. That is a question about speed rather than position, so each series measures how far it has moved over the same window and that move gets ranked against its own history. Percent for the index, because a 50 point move meant something different at 2000 than it does at 7000. Points for breadth, which is already bounded at 0 and 100. The gap between the two ranks is what gets read, and ranking is what makes a price and a percentage comparable at all.

Index in the top of its own distribution of moves while breadth is in the bottom of hers is thinning. Fewer names are carrying it. Breadth moving up harder than the index is broadening, and it is what the back end of a washout looks like.

Ranking positions instead of moves is the obvious way to build this and it does not work, which is worth saying because the failure is instructive. An index drifts upward, so its position rank pins at the top of its range for months at a time. That builds a permanent bias into the gap, and it quietly collapses the whole read into "breadth is low", which is something the level already tells you. A move measured over a fixed window is centred on its own history by construction, so it has neither problem.

WHY BOTH, AND NOT JUST THE LEVEL

The level tells you where participation is. It does not tell you which way it is going relative to price, so a level read is equally happy at 55 on the way up and 55 on the way down. The participation read tells you the direction of the disagreement but has no sense of absolute position, so it will call thinning at 75 and at 35 without distinguishing between them, and those are very different markets. Neither one is sufficient. Read together, the level says how much of the list is in, and the rank gap says whether that number is keeping up.

THE PART THAT ACTUALLY MATTERS

A new participation state has to hold for several bars before it replaces the current one.

Drop that and this becomes a threshold that flips every time the rank gap wobbles across the line, and within a month you have learned to ignore it. The hold period is the difference between a regime read and a flicker. It is exposed in the inputs. One bar makes it reactive and noisy, ten makes it stubborn and late, and there is no correct answer, only the one that matches how often you are willing to change your mind.

READING IT

The line is the breadth percentage, coloured by band. Red zone is washout, teal zone is strong.

Orange triangle near the top of the pane: participation just turned thinning.

Teal triangle near the bottom: participation just turned broadening.

The table carries the live reading, the current band, how many bars breadth has been sitting under the washout line, and the participation state with the raw rank gap in brackets. That bracketed number is worth watching on its own, because it moves before the label does. A gap climbing through the high twenties tells you the state is about to be named while the hold period is still counting.

SETTINGS THAT MATTER

The breadth series and the index have to be the same index or the comparison is noise. The default pairing is INDEX:S5TH against SP:SPX. If you switch to a Nasdaq or Russell breadth series, switch the index with it.

The move window sets what counts as "has moved". Shorter makes the participation read sensitive to swings inside a trend, longer makes it a read on the trend itself. The ranking window sets how much history each move is judged against, and nothing reads at all until both windows have filled.

The thinning and broadening gaps are separate inputs because there is no reason the two sides have to share a number. Left equal at 30 they fire about as often as each other, so if you want one side more sensitive, move that one and leave the other alone.

WHAT IT WILL NOT DO

It does not generate entries or exits, and it is not a forecast. It describes the state of participation as of the current bar, and what you do with that is your method, not mine.

The breadth series prints once a day and has no intraday history. On an intraday chart the daily value is pulled instead, so the line steps rather than curves and the current day's value keeps moving until the close. It settles when the day does. Daily or higher is where this is meant to run.

If the external series is unavailable on your plan or your symbol, the pane turns orange and the table reads NA rather than plotting a flat line that could be mistaken for a real value.

Breadth is a coincident measure of participation, not a leading one. Washouts are identifiable in hindsight far more cleanly than they are while you are standing in one, and a thinning read can persist for months in a market that keeps going up. This is context for a decision, not the decision.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evawpd141

//@version=6
indicator("YURI Breadth Regime Engine", "YURI BRE", overlay = false, precision = 1)

// What percentage of an index's members are actually above their 200 day moving
// average, and whether that number is keeping up with the index itself.
//
// An index is capitalisation weighted, so a handful of large members can hold it
// up while most of the list quietly breaks down. Breadth is the count, and it
// does not care about weight.
//
// The level answers one question: how much of the list is participating right
// now. Below 20 has historically been forced selling rather than opinion, most of
// the list under its own annual average at the same time. Those readings cluster
// near the end of declines, not the start. That is an observation about where
// they have occurred, not a signal to buy them.
//
// The participation read answers a different one: is the index outrunning its own
// members. That is a question about speed, not position, so it compares how far
// each series has moved over the same window rather than where each one sits.
// Both moves get ranked against their own history, and the gap between those ranks
// is the read. Index in the top of its own distribution of moves while breadth is
// in the bottom of hers means fewer names are carrying it. The reverse, breadth
// moving up harder than the index, is what the back end of a washout looks like.
//
// Ranking positions rather than moves does not work here, and the reason is worth
// stating. An index drifts upward, so its position rank pins at 100 for months at
// a time and stops carrying information, which both builds a permanent bias into
// the gap and quietly reduces the whole read to "breadth is low", something the
// level above already says. Ranking moves has neither problem, because a move over
// a fixed window is centred on its own history by construction.
//
// A gap has to hold for several bars before it gets named, for the same reason
// every regime read needs hysteresis: without it the label flips on noise and you
// learn to ignore it.
//
// Default pairing is S&P 500 members above their 200 day average against the S&P
// 500 itself. Swap both together if you want another index, or the 50 day version.
//
// The underlying series prints once a day. On an intraday chart the line steps
// rather than curves, and the current day's value keeps moving until the close.

source    = input.symbol("INDEX:S5TH", "Breadth series", group = "Data")
smoothLen = input.int(1, "Smoothing", minval = 1, maxval = 20, group = "Data", tooltip = "1 leaves the series raw.")

washLine   = input.float(20.0, "Washout level", minval = 0.0, maxval = 100.0, group = "Levels")
weakLine   = input.float(40.0, "Weak level", minval = 0.0, maxval = 100.0, group = "Levels")
strongLine = input.float(60.0, "Strong level", minval = 0.0, maxval = 100.0, group = "Levels")

indexSym = input.symbol("SP:SPX", "Index to compare against", group = "Participation", tooltip = "Has to be the same index the breadth series is built from, or the comparison means nothing.")
divLen   = input.int(60, "Move window (bars)", minval = 5, group = "Participation", tooltip = "How far back each series measures its own move from.")
normLen  = input.int(252, "Ranking window (bars)", minval = 50, group = "Participation", tooltip = "How much history each move is ranked against. Nothing reads until move window plus ranking window of history exists.")
thinGap  = input.int(30, "Gap that counts as thinning", minval = 5, maxval = 90, group = "Participation")
broadGap = input.int(30, "Gap that counts as broadening", minval = 5, maxval = 90, group = "Participation", tooltip = "Kept separate from the thinning gap on purpose. Indices narrow slowly and break together, so the two sides do not occur equally often.")
divHold  = input.int(5, "Bars the gap must hold", minval = 1, group = "Participation")

showDiv = input.bool(true, "Mark participation shifts", group = "Display")

// Breadth series are published daily and have no intraday history, so asking one
// for a 5 minute bar just fails. Intraday charts pull the daily value instead.
res = timeframe.isintraday ? "D" : timeframe.period

raw     = request.security(source, res, close)
hasData = not na(raw)

// ta.sma stays outside the ternary so it evaluates on every bar.
smoothed = ta.sma(raw, smoothLen)
breadth  = smoothLen > 1 ? smoothed : raw

// How long the market has been sitting under the washout line.
var int daysBelow = 0
if hasData and breadth < washLine
    daysBelow += 1
else if hasData
    daysBelow := 0

string state = "no data"
if hasData
    if breadth < washLine
        state := "washout"
    else if breadth < weakLine
        state := "weak"
    else if breadth < strongLine
        state := "neutral"
    else
        state := "strong"

color stateColor = state == "washout" ? color.red : state == "weak" ? color.orange : state == "neutral" ? color.gray : state == "strong" ? color.teal : color.silver

// Participation. Each series measures its own move over the same window, then that
// move gets ranked against its own history. Ranking makes the two comparable at
// all, since one is a price and the other a percentage, and using moves rather
// than levels is what keeps the comparison honest on an index that drifts upward.
idxClose = request.security(indexSym, res, close)

idxPrev = idxClose[divLen]
brPrev  = breadth[divLen]

// Percent for the index, because a 50 point move meant something different at 2000
// than it does at 7000. Points for breadth, which is already bounded at 0 and 100.
idxMove = not na(idxPrev) and idxPrev > 0.0 ? idxClose / idxPrev - 1.0 : na
brMove  = not na(brPrev) ? breadth - brPrev : na

idxRank = ta.percentrank(idxMove, normLen)
brRank  = ta.percentrank(brMove, normLen)

hasDiv  = hasData and not na(idxRank) and not na(brRank)
gapRank = hasDiv ? idxRank - brRank : na

string rawDiv = not hasDiv ? "aligned" : gapRank >= thinGap ? "thinning" : gapRank <= -broadGap ? "broadening" : "aligned"

// Same hysteresis idea as any other regime read. A new participation state has to
// survive divHold bars before it replaces the current one, otherwise a single bar
// poking past the threshold renames the regime.
var string participation = "aligned"
var int    divHeld       = 0

if rawDiv == participation
    divHeld := 0
else if rawDiv == rawDiv[1]
    divHeld += 1
else
    divHeld := 1

if divHeld >= divHold
    participation := rawDiv
    divHeld := 0

thinStart  = participation == "thinning"   and participation[1] != "thinning"
broadStart = participation == "broadening" and participation[1] != "broadening"

color divColor = participation == "thinning" ? color.orange : participation == "broadening" ? color.teal : color.gray

plot(breadth, "Breadth", stateColor, 2)

// The rank gap does not belong on a 0 to 100 pane, but it is the number the
// participation state is made of, so it goes in the data window where it can be
// read bar by bar without cluttering the chart.
plot(gapRank, "Rank gap", display = display.data_window)

wash   = hline(washLine, "Washout", color.new(color.red, 50), hline.style_dotted)
weak   = hline(weakLine, "Weak", color.new(color.gray, 70), hline.style_dotted)
strong = hline(strongLine, "Strong", color.new(color.teal, 50), hline.style_dotted)
top    = hline(100, "Top", color.new(color.gray, 90))
bottom = hline(0, "Bottom", color.new(color.gray, 90))

fill(bottom, wash, color.new(color.red, 90))
fill(strong, top, color.new(color.teal, 92))

// Pinned to fixed levels rather than location.top and location.bottom. Those sit
// the marks outside the 0 to 100 range, and the pane then pads itself out to fit
// them, which squashes the line the pane exists to show.
plotshape(showDiv and thinStart ? 97 : na, "Thinning", shape.triangledown, location.absolute, color.new(color.orange, 20), size = size.tiny)
plotshape(showDiv and broadStart ? 3 : na, "Broadening", shape.triangleup, location.absolute, color.new(color.teal, 20), size = size.tiny)

// Orange pane means the external series went missing. Better than plotting a
// flat line and letting someone read it as a real value.
bgcolor(hasData ? na : color.new(color.orange, 80))

if barstate.islast
    var table t = table.new(position.top_right, 2, 4, border_width = 1)
    table.cell(t, 0, 0, "Breadth", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, hasData ? str.tostring(breadth, "#.#") + "%" : "NA", text_color = color.white, bgcolor = color.new(stateColor, 25), text_size = size.small)
    table.cell(t, 0, 1, "State", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, state, text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 2, "Bars below washout", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(daysBelow), text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 3, "Participation", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, hasDiv ? participation + " (" + str.tostring(gapRank, "#") + ")" : "NA", text_color = divColor, text_size = size.small)

alertcondition(ta.crossunder(breadth, washLine), "Entered washout", "Breadth dropped below the washout level")
alertcondition(ta.crossover(breadth, washLine), "Left washout", "Breadth recovered above the washout level")
alertcondition(ta.crossover(breadth, strongLine), "Breadth strong", "Breadth crossed above the strong level")
alertcondition(thinStart, "Participation thinning", "The index is outrunning its own members")
alertcondition(broadStart, "Participation broadening", "Members are leading the index")
````
