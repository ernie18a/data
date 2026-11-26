# YURI VWAP Sigma Engine

- url: https://www.tradingview.com/script/kUeWhWsF/
- type: indicator
- pine_id: PUB;abad50a9e93149959cd291da5032365d
- version: 1.0

## Description

Session VWAP with volume weighted deviation bands, and a read on whether today's bands are wide or narrow for this point in the session. The bands are the ordinary part. The comparison against the clock is the part that is not available anywhere else, and it is the reason this exists.

WHAT THE BANDS ARE

VWAP is the average price every share traded at today, weighted by size. It is the benchmark institutional execution is measured against, which is most of why price keeps coming back to it. The bands are the volume weighted standard deviation of that same distribution, so they widen as the session builds disagreement and stay tight when it does not.

The deviation readout is the first number. "1.8 sigma above VWAP" says you are paying more than almost anyone else did today. Whether that is a breakout or a bad fill is a separate question this does not answer.

THE PROBLEM WITH BAND WIDTH

Band width on its own cannot be read, and the reason is structural rather than a matter of tuning. Width is a function of how far into the session you are. Sigma at 09:45 is small on every day that has ever been recorded, and sigma at 15:30 is large on every day that has ever been recorded, because the distribution simply has more in it by then. An absolute width therefore tells you the time of day and almost nothing about the day.

Comparing today's width at 10:15 against the width at 10:15 on each of the last twenty sessions removes the part that belongs to the clock. What is left belongs to today: this session is running wider than it normally is by now, or tighter.

Two details make that comparison mean anything. Width is measured relative to VWAP rather than in points, because the same instrument at 400 and at 700 does not produce comparable point spreads. And the comparison window is short on purpose, twenty sessions by default, so the reference is the volatility regime you are actually trading in rather than an average across several of them. A quiet day inside a violent month should not read as wide.

THE DISCLAIMER THAT TURNS INTO A FEATURE

Every VWAP band implementation carries the same warning: the bands are unreliable in the first fifteen to thirty minutes, because there is not enough volume in the distribution yet and they come out far too narrow.

Half of that stops mattering here. The under sampling applies equally to today and to every session today is being compared against, because they are being compared at the same point on the same clock with the same amount of data behind them. The absolute number early in the session is still meaningless. The comparison is not.

The half that does not go away is that a percentile built from six bars moves around far more than one built from sixty, and comparing like for like removes the bias without removing that. Measured across sixty sessions the percentile moves roughly eleven points a bar in the first half hour against roughly one point a bar after midday. So the early read is tagged rather than hidden. The first half hour is when a read on the session is actually worth having, and a noisy number that says it is noisy beats waiting until lunchtime for a number the session has already made obvious.

WHY NOT THE BUILT IN

The built in VWAP will draw the same bands, and if bands are all you want then use it. What it cannot do is tell you what today's width means, because that requires holding the width from previous sessions slot by slot and comparing like for like. The bands here are the input to that. The output is the state, the percentile, the multiple of a typical day, and the dotted envelope showing where the outer band sat at this exact point of the session on a median day.

THE PART THAT ACTUALLY MATTERS

A state has to hold for several bars before it gets named.

Drop that and this becomes a threshold that flips every time the percentile wobbles across the line, and within a week you have learned to ignore it. The hold period is the difference between a session read and a flicker. It is exposed in the inputs, it resets at every session open because the state describes today rather than yesterday, and there is no correct setting, only the one that matches how often you are willing to change your mind.

READING IT

Blue line is VWAP. Solid grey lines are the inner and outer bands, at one and two sigma by default.

Dotted line is the typical day. It is where the outer band sat at this point of the session across the comparison window. Today's band outside the dotted line is an expansion, inside it is a quiet day, and the distance between them is the whole read made visible without looking at a number.

The band shading carries the state. Orange is wide, blue is narrow, teal is normal, grey means there is no read yet.

The table gives the multiple of a typical day, the state with its percentile in brackets, how many sessions the comparison is actually running against, the current deviation in sigma, the distance from VWAP in percent, and how many times price has touched each outer band today.

The bracketed percentile is worth watching on its own because it moves before the label does. A percentile climbing through the middle seventies tells you the state is about to be named while the hold period is still counting.

Two words appear in the state that are not states. Forming means the session has just opened and the label has reset but not yet held long enough to be named, so the percentile is live and the label is not. Early means you are still inside the window where the percentile is built on very few bars, and it is a tag on the number rather than a different number.

SETTINGS THAT MATTER

Sessions to compare against sets the reference. Shorter reacts to the current regime and will call a wide day normal once wide days become the regime. Longer is a more stable reference and slower to accept that the regime has changed.

The wide and narrow percentiles are separate inputs. There is no reason a wide day and a quiet day have to be equally rare in your reading of the market, and if you want one side more sensitive, move that one and leave the other alone.

Sessions needed before it reads is a floor on the sample. Below it the table says warming up rather than computing a percentile out of four numbers.

Minutes before the read is trusted moves the early tag and nothing else. It changes no number and hides no reading. Set it to zero if you would rather judge the sample size yourself.

The anchor controls the VWAP reset only. The clock comparison needs a daily anchor, since a weekly or monthly anchor has no session clock to normalise against, and the table says so rather than printing a number that does not mean anything.

WHAT IT WILL NOT DO

It does not generate entries or exits, and it is not a forecast. A wide session is not a short and a narrow one is not a breakout setup. Width describes how much disagreement the session has built, not which side wins it, and the same reading precedes both a reversal and a trend continuation often enough that treating it directionally is a mistake the indicator cannot stop you making.

It needs real volume. On instruments where the feed reports tick counts instead, VWAP and everything built on it are approximations, and spot FX in particular has no consolidated volume at all.

It needs a clock, though not necessarily a closing bell. On a symbol that never closes the exchange day still rolls over, so the comparison runs against that boundary and produces a read rather than refusing one. Whether the roll of a twenty four hour day marks anything real for the instrument in front of you is your judgement to make, not the script's.

The comparison history is built as the script runs across the chart, so the read needs the comparison window plus the minimum sample to have gone past before it says anything. On a fresh chart that is the first few weeks of visible history, not the first bar.

This is context for a decision, not the decision.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evawpd141

//@version=6
indicator("YURI VWAP Sigma Engine", "YURI VSE", overlay = true)

// Session VWAP with volume-weighted deviation bands, and a read on whether today's
// bands are wide or narrow for this point in the session.
//
// VWAP is the average price every share traded at today, weighted by size. It is
// the benchmark institutional desks are measured against, which is most of why
// price keeps coming back to it. The bands are the volume-weighted standard
// deviation of that same distribution, so they widen as the session builds
// disagreement and stay tight when it does not.
//
// The first number is the deviation readout. "1.8 sigma above VWAP" says you are
// paying more than almost anyone else did today. Whether that is a breakout or a
// bad fill is a separate question this does not answer.
//
// The second number is the one worth having. Band width on its own cannot be read
// at all, because it is a function of how far into the session you are. Sigma at
// 09:45 is small on every day ever recorded, and sigma at 15:30 is large on every
// day ever recorded, so an absolute width tells you the time of day and nothing
// else. Comparing today's width at 10:15 against the width at 10:15 on each of the
// last twenty sessions removes that, and what is left is the part that belongs to
// today: this session is running wider, or tighter, than this session normally
// does by now.
//
// Width is measured relative to VWAP rather than in points, because the same
// instrument at 400 and at 700 does not produce comparable point spreads, and the
// comparison window is deliberately short so that the reference is the current
// volatility regime rather than an average across regimes.
//
// The useful consequence is that the standard VWAP band disclaimer stops being a
// disclaimer. Bands are unreliable early because there is not enough volume in the
// distribution yet, but that under-sampling applies equally to today and to every
// session it is being compared against, so the comparison stays honest while the
// absolute number is still meaningless. The read is available from the first few
// bars, which is when a session read is worth anything.
//
// A state has to hold for several bars before it gets named, for the same reason
// every regime read needs hysteresis: without it the label flips on noise and you
// learn to ignore it.
//
// The clock comparison needs an intraday chart and a daily anchor. On a weekly or
// monthly anchor there is no session clock to normalise against, and the table
// says so rather than printing a number that does not mean anything.

band1 = input.float(1.0, "Inner band (sigma)", minval = 0.25, step = 0.25, group = "Bands")
band2 = input.float(2.0, "Outer band (sigma)", minval = 0.5, step = 0.25, group = "Bands")

anchorRes = input.timeframe("D", "Reset on", options = ["D", "W", "M"], group = "Bands")
rthOnly   = input.bool(true, "Regular hours only", group = "Bands", tooltip = "Off includes pre and post market volume in the average.")

lookbackDays = input.int(20, "Sessions to compare against", minval = 5, maxval = 40, group = "Session spread", tooltip = "Short on purpose. The reference should be the volatility regime you are trading in, not an average across several of them.")
minSample    = input.int(10, "Sessions needed before it reads", minval = 3, maxval = 40, group = "Session spread")
widePct      = input.int(80, "Percentile that counts as wide", minval = 55, maxval = 99, group = "Session spread")
narrowPct    = input.int(20, "Percentile that counts as narrow", minval = 1, maxval = 45, group = "Session spread")
spreadHold   = input.int(3, "Bars the read must hold", minval = 1, maxval = 20, group = "Session spread")
earlyMins    = input.int(60, "Minutes before the read is trusted", minval = 0, maxval = 240, group = "Session spread", tooltip = "The comparison is unbiased from the first bar. It is not stable from the first bar. Inside this window the read is tagged early rather than hidden. Set to zero to drop the tag.")

showFill    = input.bool(true, "Shade the bands", group = "Display")
showTypical = input.bool(true, "Show the typical day envelope", group = "Display", tooltip = "Dotted line: where the outer band sat at this point of the session on a median day.")
showStats   = input.bool(true, "Show readout", group = "Display")

// Slots are bars into the session. A regular 390 minute session fits in 480, but
// two ordinary cases do not: a 16 hour extended session with pre and post market
// volume counted, and a symbol that never closes at all. Both run to 960 and 1440
// one minute slots, and at 480 the clock read went dark halfway through the day
// rather than at a boundary anyone would recognise. Past the end it still turns
// itself off rather than wrapping around and comparing the open against the close.
int MAXSLOTS = 1440

// The chart has to be finer than the anchor, otherwise every bar starts a new
// period and VWAP collapses onto hlc3.
anchorOk = timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(anchorRes)
clockOk  = timeframe.isintraday and anchorRes == "D"
tfMin    = math.max(1.0, timeframe.in_seconds(timeframe.period) / 60.0)

newPeriod = ta.change(time(anchorRes)) != 0
counting  = rthOnly ? session.ismarket : true

var float cumVol = 0.0
var float cumPV  = 0.0
var float cumPV2 = 0.0

// Bars in the current distribution, which is what decides whether there is any
// dispersion to measure at all. Testing the deviation for zero is not the same
// test and does not survive contact with floating point: see the note on bandsOk.
var int periodBars = 0

if newPeriod
    cumVol := 0.0
    cumPV  := 0.0
    cumPV2 := 0.0
    periodBars := 0

if counting
    cumVol += volume
    cumPV  += volume * hlc3
    cumPV2 += volume * math.pow(hlc3, 2)
    periodBars += 1

vwap = cumVol > 0.0 ? cumPV / cumVol : na

// Variance can land a hair below zero on floating point alone, so clamp it.
variance = cumVol > 0.0 ? (cumPV2 / cumVol) - math.pow(vwap, 2) : na
sd       = not na(variance) and variance >= 0.0 ? math.sqrt(variance) : na

// A single bar has zero variance, so on the first bar of a session all four bands
// sit exactly on VWAP. Plotting that point draws a line from the previous
// session's full band width down to a single value, which is a vertical wall
// across the pane at every session boundary, and it makes the outer band equal to
// hlc3, which every bar's high and low are on both sides of at once. Leaving the
// bands undefined until there is a second bar breaks the line cleanly and keeps
// the excursion counter from booking one phantom touch each way per session.
//
// The gate is the bar count and not sd > 0, because that zero is not reliable.
// The variance is E[x^2] - E[x]^2, a subtraction of two numbers of the same
// magnitude, so on one bar it returns a rounding residue of order 1e-10 whose
// sign is arbitrary rather than a clean zero. Measured over sixty sessions of SPY
// 5 minute bars it came out positive once, which is a sigma of 1e-5, wide enough
// to draw the wall and to write a width of 0.0001 bps into the comparison buffer.
bandsOk = periodBars > 1 and not na(sd) and sd > 0.0

upper1 = bandsOk ? vwap + sd * band1 : na
lower1 = bandsOk ? vwap - sd * band1 : na
upper2 = bandsOk ? vwap + sd * band2 : na
lower2 = bandsOk ? vwap - sd * band2 : na

devSigma = bandsOk ? (close - vwap) / sd : na
devPct   = not na(vwap) and vwap > 0.0 ? (close - vwap) / vwap * 100.0 : na

// Excursions past the outer band say something about whether the session is
// respecting its edges. Counted as entries rather than bars: one push that stays
// outside for twenty bars is one excursion, not twenty, and counting bars instead
// turns a fine timeframe into a meaninglessly large number.
outUp = counting and not na(upper2) and high >= upper2
outDn = counting and not na(lower2) and low <= lower2

var int touchUp = 0
var int touchDn = 0
if newPeriod
    touchUp := 0
    touchDn := 0
if outUp and not outUp[1]
    touchUp += 1
if outDn and not outDn[1]
    touchDn += 1

// Session spread. One row per session in a rolling buffer, one column per slot,
// holding band width relative to VWAP so that widths from different price levels
// are comparable at all.
var matrix<float> hist = matrix.new<float>(lookbackDays, MAXSLOTS, na)

// A session boundary cannot be found by watching session.ismarket turn on. A feed
// that carries no out-of-session bars at all is in-session on every bar it has, so
// that transition never happens and the clock never starts. Cash indices are
// exactly this case. The trading day rolling over is the boundary that always
// exists, and the clock then starts on the first bar that actually feeds the
// average, which is what the slot is supposed to be measured from.
tradingDayChange = ta.change(time_tradingday) != 0

var int  sessionStart = na
var int  rowPtr       = -1
var bool sessionOpen  = false

if tradingDayChange
    sessionOpen := false

newSession = counting and not sessionOpen

if newSession
    sessionOpen  := true
    sessionStart := time
    rowPtr := (rowPtr + 1) % lookbackDays
    for c = 0 to MAXSLOTS - 1
        matrix.set(hist, rowPtr, c, na)

int slot = na
if not na(sessionStart)
    slot := int(math.floor((time - sessionStart) / 60000.0 / tfMin))

sigmaBps = bandsOk and vwap > 0.0 ? sd / vwap * 10000.0 : na

// The first slot of a session carries no dispersion, on today and on every session
// being compared against, so it is skipped rather than recorded as a zero that
// would drag the whole column. Tying this to bandsOk rather than repeating the
// test keeps the buffer and the plotted bands agreeing about what exists. Outside
// the window that feeds the average there is nothing new to measure, so nothing
// is recorded.
slotOk = clockOk and anchorOk and counting and rowPtr >= 0 and not na(slot) and slot >= 0 and slot < MAXSLOTS and not na(sigmaBps) and sigmaBps > 0.0

float typBps = na
float pctile = na
int   sample = 0

if slotOk
    array<float> colv = matrix.col(hist, slot)
    array<float> vals = array.new<float>()
    for i = 0 to array.size(colv) - 1
        // Today's own row is excluded, otherwise the session is partly measuring
        // itself once the buffer wraps onto it.
        if i != rowPtr
            float v = array.get(colv, i)
            if not na(v)
                array.push(vals, v)
    sample := array.size(vals)
    if sample >= minSample
        typBps := array.median(vals)
        int below = 0
        for i = 0 to sample - 1
            if array.get(vals, i) < sigmaBps
                below += 1
        pctile := below * 100.0 / sample

// Arrays and matrices are not rolled back between ticks of a forming bar the way
// scalars are, so the write waits for the bar to close. Nothing downstream needs
// it earlier, since today's row is excluded from its own comparison anyway.
if slotOk and barstate.isconfirmed
    matrix.set(hist, rowPtr, slot, sigmaBps)

ratio = not na(pctile) and not na(typBps) and typBps > 0.0 ? sigmaBps / typBps : na

string rawSpread = na(pctile) ? "no read" : pctile >= widePct ? "wide" : pctile <= narrowPct ? "narrow" : "normal"

// Same hysteresis as any other regime read: a new state has to survive spreadHold
// bars before it replaces the current one. The state resets at the session open
// because it describes today, not yesterday.
var string spreadState = "no read"
var int    spreadHeld  = 0

if newSession
    spreadState := "no read"
    spreadHeld  := 0

if rawSpread == "no read"
    spreadState := "no read"
    spreadHeld  := 0
else if rawSpread == spreadState
    spreadHeld := 0
else if rawSpread == rawSpread[1]
    spreadHeld += 1
else
    spreadHeld := 1

if spreadHeld >= spreadHold
    spreadState := rawSpread
    spreadHeld  := 0

wideStart   = spreadState == "wide"   and spreadState[1] != "wide"
narrowStart = spreadState == "narrow" and spreadState[1] != "narrow"

color spreadColor = spreadState == "wide" ? color.orange : spreadState == "narrow" ? color.blue : spreadState == "normal" ? color.teal : color.gray

// Where the outer band sat at this slot on a median session. Today's band outside
// the dotted line is an expansion, inside it is a quiet day, and the gap between
// them is the read made visible.
typSd    = not na(typBps) and not na(vwap) ? typBps / 10000.0 * vwap : na
typUpper = showTypical and not na(typSd) ? vwap + typSd * band2 : na
typLower = showTypical and not na(typSd) ? vwap - typSd * band2 : na

plot(vwap, "VWAP", color.new(color.blue, 0), 2)
u1 = plot(upper1, "Upper 1", color.new(color.gray, 55), 1)
l1 = plot(lower1, "Lower 1", color.new(color.gray, 55), 1)
u2 = plot(upper2, "Upper 2", color.new(color.gray, 25), 1)
l2 = plot(lower2, "Lower 2", color.new(color.gray, 25), 1)

plot(typUpper, "Typical upper", color.new(color.gray, 40), 1, plot.style_circles)
plot(typLower, "Typical lower", color.new(color.gray, 40), 1, plot.style_circles)

// The shading carries the spread state, because the bands are the thing being
// measured and colouring them is more direct than another line.
fill(u1, l1, showFill ? color.new(spreadColor, 93) : na)
fill(u2, u1, showFill ? color.new(spreadColor, 96) : na)
fill(l1, l2, showFill ? color.new(spreadColor, 96) : na)

// The raw numbers behind the state, bar by bar, without cluttering the chart.
plot(sigmaBps, "Width (bps of VWAP)", display = display.data_window)
plot(typBps, "Typical width (bps)", display = display.data_window)
plot(pctile, "Width percentile", display = display.data_window)
plot(ratio, "Width vs typical", display = display.data_window)

color devColor = na(devSigma) ? color.gray : math.abs(devSigma) >= band2 ? color.orange : math.abs(devSigma) >= band1 ? color.blue : color.teal

// The comparison is honest from the first bar, because the same under-sampling
// applies to every session being compared against, but honest is not the same as
// stable. Across sixty sessions of SPY 5 minute bars the percentile moved about
// 11 points a bar over the first half hour against about 1 point a bar after
// midday, on the same data and the same settings. That is a sample size problem
// and hysteresis does not touch it, since a reading can hold for four bars and
// still be built on six. So the early read is tagged rather than withheld: a
// noisy number that says it is noisy is still worth having, and hiding it would
// throw away the one window where a session read actually changes a decision.
bool earlyRead = not na(slot) and slot * tfMin < earlyMins

// The state resets at every session open and hysteresis will not name a new one
// for spreadHold bars, so for those first few bars there is a percentile but no
// state yet. Printing the internal "no read" beside a live number reads as a
// contradiction; what is true is that the state has not settled.
string spreadLabel = spreadState == "no read" ? "forming" : spreadState

// Every reason the spread read can be unavailable gets named, because "warming up"
// on a chart that will never produce a read is worse than no message at all. A
// symbol that never closes still has a clock, since the exchange day rolls over
// whether or not anyone stops trading, so it gets a read rather than a refusal.
// The refusal is for a slot count that has run past the end of the buffer.
string stateText = not anchorOk ? "chart too coarse" : not clockOk ? "needs intraday + daily anchor" : na(slot) or slot >= MAXSLOTS ? "no session clock" : na(pctile) ? "warming up" : spreadLabel + " (p" + str.tostring(pctile, "#") + ")" + (earlyRead ? " early" : "")

if showStats and barstate.islast
    var table t = table.new(position.top_right, 2, 6, border_width = 1)
    table.cell(t, 0, 0, "Session spread", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, na(ratio) ? "-" : str.tostring(ratio, "#.##") + "x typical", text_color = color.white, bgcolor = color.new(spreadColor, 25), text_size = size.small)
    table.cell(t, 0, 1, "State", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, stateText, text_color = na(pctile) ? color.orange : spreadColor, text_size = size.small)
    table.cell(t, 0, 2, "Compared against", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(sample) + " sessions", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 3, "From VWAP", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, na(devSigma) ? "-" : str.tostring(devSigma, "#.##") + " sd", text_color = color.white, bgcolor = color.new(devColor, 25), text_size = size.small)
    table.cell(t, 0, 4, "Distance", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 4, na(devPct) ? "-" : str.tostring(devPct, "#.##") + "%", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 5, "Outer touches", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 5, str.tostring(touchUp) + " up / " + str.tostring(touchDn) + " down", text_color = anchorOk ? color.gray : color.orange, text_size = size.small)

alertcondition(ta.crossover(close, upper2), "Crossed above outer band", "Price crossed above the outer VWAP band")
alertcondition(ta.crossunder(close, lower2), "Crossed below outer band", "Price crossed below the outer VWAP band")
alertcondition(ta.cross(close, vwap), "Crossed VWAP", "Price crossed session VWAP")
alertcondition(wideStart, "Session running wide", "Band width is high for this point in the session")
alertcondition(narrowStart, "Session running narrow", "Band width is low for this point in the session")
````
