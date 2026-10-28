# YURI Session Regime Engine

- url: https://www.tradingview.com/script/3oAc54JI/
- type: indicator
- pine_id: PUB;59c6ceb3c1a74989ba6b08852b58738a
- version: 1.0

## Description

# Publication description: YURI Session Regime Engine

Paste into the TradingView publish dialog, page 1. Keep the bold headers, drop the
markdown hashes if the editor does not render them.

Categories used: Trend Analysis, Volume, Chart Patterns
Suggested keywords: day type, regime, opening range, session, intraday, VWAP

---

Most intraday losses I have looked at come down to running the wrong playbook for
the day. Buying pullbacks on a session that never trends. Fading the edges on one
that never comes back. By the time the character of a session is obvious on the
chart, the move it was going to give you has usually already happened.

This labels the session while it is still forming.

**How it decides**

Five checks vote on direction, and each one covers a blind spot in the others.

1. Which side of session VWAP price is trading
2. Whether VWAP itself is rising or falling, measured across the last 75 minutes
3. Whether the opening range has broken
4. Where the higher timeframe trend points, hourly close against its 20 period SMA by default
5. Whether price has cleared the prior day's high or low

Four votes out of five makes it a trend day. A gap larger than 2 percent that
trades back through the session open gets labelled a gap fill. Price still sitting
inside the opening range well after the open, with a quarter of the range width
allowed either side, is a range day.

Each of those five is weak on its own. VWAP position whipsaws in chop, the
opening range fails on gap mornings, and a higher timeframe read is always late by
construction. Prior day levels tell you nothing at all about today. What makes the
combination worth more than its parts is that they fail in different places, so
requiring agreement across all five stops any single one of them from driving the
label.

**The part that actually matters**

A new label has to hold for 25 minutes before it replaces the current one.

Drop that layer and this becomes every other conditional colouring script. Price
wicks back through VWAP, the label flips, it flips back ten minutes later, and
within a week you have learned to ignore it. The hold period is what makes the
output stable enough to be worth reading. Set it to 10 minutes if you want it
reactive, an hour if you want it stubborn.

**Reading it**

TREND UP / TREND DOWN: four or more of the five checks agree on direction.

RANGE: price is still inside the opening range plus a quarter of its width either
side, well after the open.

GAP FILL UP / GAP FILL DOWN: the session gapped hard and has since traded back
through its own open.

MIXED: the opening range has formed but nothing has agreed strongly enough to name
the day. Days that stay here are the ones worth trading small.

OPENING: the opening range has not finished forming and there is not enough
information yet.

The table carries the live vote count on both sides. Three votes up and rising
tells you more than the label does, because it shows a regime change building
before the hold period lets it commit. What you do with any of this is your
method, not mine. The label is an input to that decision.

**What it will not do**

It describes what has already happened. It is a classification of the session so
far, and it will not tell you where to enter or where to get out.

The first 15 minutes are always OPENING, by construction. Once the session ends
the day keeps whatever label it closed with until the next one starts, because
judging a finished day against a frozen VWAP would be meaningless.

If you set the context timeframe below your chart timeframe, that vote gets
dropped instead of being computed on partial bars. The table tells you when this
happens.

It assumes an instrument with a defined regular session. On 24 hour markets the
session logic loses most of its meaning.

Time thresholds are set in minutes and converted to bars internally, so the same
defaults behave the same way on a 1, 5 or 15 minute chart. It was built for US
equity index sessions. Every threshold is exposed in the inputs, including the
vote count needed for a trend day, so you can tighten or loosen it for whatever
you trade.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evawpd141

//@version=6
indicator("YURI Session Regime Engine", "YURI SRE", overlay = true)

// Labels the current session as trending, rangebound, or a gap fill.
//
// Five checks vote on direction: which side of VWAP price sits, whether VWAP is
// rising or falling, whether the opening range broke, where the higher timeframe
// trend points, and whether price cleared yesterday's extremes. Four out of five
// makes it a trend day.
//
// A new label has to hold for several bars before it replaces the current one.
// Without that the read flips every time price wicks back through VWAP.
//
// Trend days reward buying pullbacks. Range days reward fading the edges. Using
// the wrong playbook for the day is what most intraday losses actually are.
// The label describes what has already happened. It is not a forecast.

orMinutes    = input.int(15, "Opening range (minutes)", minval = 5, maxval = 120, group = "Classification")
voteFloor    = input.int(4, "Votes needed for a trend day", minval = 3, maxval = 5, group = "Classification")
holdMinutes  = input.int(25, "Minutes a new type must hold", minval = 5, maxval = 120, group = "Classification")
rangeMinutes = input.int(120, "Minutes before a range day can be called", minval = 30, group = "Classification")
slopeMinutes = input.int(75, "VWAP slope lookback (minutes)", minval = 15, group = "Classification")
bigGapPct    = input.float(2.0, "Gap size that counts as large (%)", minval = 0.5, step = 0.25, group = "Classification")

htfRes = input.timeframe("60", "Higher timeframe", group = "Context", tooltip = "Has to be above your chart timeframe or the vote gets dropped.")
htfLen = input.int(20, "Higher timeframe SMA length", minval = 5, group = "Context")

showBg    = input.bool(true, "Colour the background", group = "Display")
showTable = input.bool(true, "Show status table", group = "Display")

// Everything above is set in minutes so the same defaults behave the same way on
// a 1, 5 or 15 minute chart. Converting here is what keeps it timeframe agnostic.
barMinutes = math.max(1.0, timeframe.in_seconds() / 60.0)
orBars     = int(math.max(1.0, math.round(orMinutes / barMinutes)))
rangeBars  = int(math.max(1.0, math.round(rangeMinutes / barMinutes)))
slopeBars  = int(math.max(1.0, math.round(slopeMinutes / barMinutes)))
holdBars   = int(math.max(1.0, math.round(holdMinutes / barMinutes)))

intraday = timeframe.isintraday

newDay = ta.change(time("D")) != 0

var int   barsIn = 0
var float cumVol = 0.0
var float cumPV  = 0.0

if newDay
    barsIn := 0
    cumVol := 0.0
    cumPV  := 0.0

if session.ismarket
    barsIn += 1
    cumVol += volume
    cumPV  += volume * hlc3

vwap = cumVol > 0.0 ? cumPV / cumVol : na

// Opening range and the session open, rebuilt each day.
var float orHigh  = na
var float orLow   = na
var float dayOpen = na

if newDay
    orHigh  := na
    orLow   := na
    dayOpen := na

if session.ismarket
    if barsIn == 1
        dayOpen := open
    if barsIn <= orBars
        orHigh := na(orHigh) ? high : math.max(orHigh, high)
        orLow  := na(orLow)  ? low  : math.min(orLow,  low)

// Once the range is built it stays built. Demanding a live session here made the
// label drop back to OPENING the moment the bell rang, which is backwards: the
// day's classification is most useful after the day is over.
orSet = barsIn > orBars and not na(orHigh) and not na(orLow)

// lookahead_on is safe here: [1] already refers to a closed daily bar.
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

// Asking for a timeframe below the chart returns partial bars, and that vote
// would be worse than no vote at all. Drop it and flag it in the table.
htfValid = timeframe.in_seconds(htfRes) > timeframe.in_seconds(timeframe.period)

htfClose = request.security(syminfo.tickerid, htfRes, close)
htfSma   = request.security(syminfo.tickerid, htfRes, ta.sma(close, htfLen))

htfUp = htfValid and not na(htfClose) and not na(htfSma) and htfClose > htfSma
htfDn = htfValid and not na(htfClose) and not na(htfSma) and htfClose < htfSma

vwapSlope = nz(ta.change(vwap, slopeBars))

upVotes = (not na(vwap) and close > vwap ? 1 : 0) + (vwapSlope > 0 ? 1 : 0) + (orSet and close > orHigh ? 1 : 0) + (htfUp ? 1 : 0) + (not na(prevHigh) and close > prevHigh ? 1 : 0)
dnVotes = (not na(vwap) and close < vwap ? 1 : 0) + (vwapSlope < 0 ? 1 : 0) + (orSet and close < orLow ? 1 : 0) + (htfDn ? 1 : 0) + (not na(prevLow) and close < prevLow ? 1 : 0)

gapPct  = not na(dayOpen) and not na(prevClose) and prevClose > 0.0 ? (dayOpen - prevClose) / prevClose * 100.0 : na
gapUp   = not na(gapPct) and gapPct >= bigGapPct
gapDn   = not na(gapPct) and gapPct <= -bigGapPct

// A quarter of the range either side still counts as inside it.
orWidth = orSet ? orHigh - orLow : na
nearOR  = orSet and close <= orHigh + orWidth * 0.25 and close >= orLow - orWidth * 0.25

var string dayType = "OPENING"
if newDay
    dayType := "OPENING"

string candidate = dayType
if not orSet
    candidate := "OPENING"
else if upVotes >= voteFloor
    candidate := "TREND UP"
else if dnVotes >= voteFloor
    candidate := "TREND DOWN"
else if gapUp and close < dayOpen
    candidate := "GAP FILL DOWN"
else if gapDn and close > dayOpen
    candidate := "GAP FILL UP"
else if barsIn >= rangeBars and nearOR
    candidate := "RANGE"
else if dayType == "OPENING"
    // The range has formed, so OPENING is no longer true. Nothing has agreed
    // strongly enough to name the day, and saying so is better than implying the
    // session has not started. Once a real label lands this branch stops firing
    // and the previous read is what carries.
    candidate := "MIXED"

// Only market bars move the state machine. After the close VWAP is frozen while
// price keeps drifting, and letting the votes run against that would relabel a
// finished day at three in the morning. Whatever the day closed as, it keeps.
var int held = 0
if session.ismarket
    if candidate == dayType
        held := 0
    else if candidate == candidate[1]
        held += 1
    else
        held := 1
    if held >= holdBars
        dayType := candidate
        held := 0

color typeColor = dayType == "TREND UP" ? color.teal : dayType == "TREND DOWN" ? color.maroon : dayType == "RANGE" ? color.olive : dayType == "OPENING" ? color.gray : dayType == "MIXED" ? color.silver : color.purple

plot(intraday ? vwap : na, "VWAP", color.new(color.blue, 20), 2)
p1 = plot(orSet ? orHigh : na, "OR high", color.new(color.gray, 40), 1, plot.style_linebr)
p2 = plot(orSet ? orLow : na, "OR low", color.new(color.gray, 40), 1, plot.style_linebr)
fill(p1, p2, color.new(color.gray, 92))

bgcolor(showBg and intraday ? color.new(typeColor, 90) : na)

if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 4, border_width = 1)
    table.cell(t, 0, 0, "Day type", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, intraday ? dayType : "needs intraday chart", text_color = color.white, bgcolor = color.new(intraday ? typeColor : color.orange, 20), text_size = size.small)
    table.cell(t, 0, 1, "Votes", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, str.tostring(upVotes) + " up / " + str.tostring(dnVotes) + " down", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 2, "Gap", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, na(gapPct) ? "-" : str.tostring(gapPct, "#.##") + "%", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 3, "Context", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, htfValid ? htfRes : "off, below chart", text_color = htfValid ? color.gray : color.orange, text_size = size.small)

// The overnight reset back to OPENING is not news. Real transitions are.
alertcondition(dayType != dayType[1] and dayType != "OPENING", "Day type changed", "Session day type changed")
````
