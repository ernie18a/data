# Triple Confluence Meter - Trend, Momentum and Volume Agreement

- url: https://www.tradingview.com/script/hNgonvI8-Triple-Confluence-Meter-Trend-Momentum-and-Volume-Agreement/
- type: indicator
- pine_id: PUB;ab1429f426d24fb69f2fe2387a72de72
- version: 1.0

## Description

Three indicators agreeing feels like three reasons. Usually it is one reason counted three times — trend, momentum and volume all read the same price series, so of course they tend to point the same way.

This builds the ordinary confluence indicator and then does the thing confluence indicators never do: it grades itself.

THE THREE VOTES

    Trend      close above or below an EMA
    Momentum   RSI above or below 50
    Volume     the bar's direction, but only on bars where volume beats its average

Sum them for a score from −3 to +3. At the extremes all three agree, the bar is coloured, and a small triangle marks the first bar of each new alignment. On symbols with no volume feed the third vote abstains and the scale becomes −2 to +2 rather than quietly voting zero forever.

THE PART THAT MATTERS

Over the lookback, the script finds every alignment that happened at least one full horizon ago — so its outcome is already settled — and counts how often price actually went the signalled way. Then it does the subtraction almost nobody does:

    Edge = hit rate after alignment − base rate over all bars

The base rate is the catch. A bullish signal firing during an uptrend will show a glorious 60% hit rate while price rose 60% of the time regardless, and an edge near zero tells you the signal contributed nothing. Only the difference is information.

READING THE SCORECARD

Trend / Momentum / Volume — each vote's current direction, with the RSI value shown so you can see how close the momentum vote is to flipping.

Score — the sum and whether it counts as aligned.

Base rate up — how often price rose over the horizon on all bars in the window. This is the number to beat.

After bull align / After bear align — the hit rate following each kind of alignment, with n= the number of events behind it. Read the n before the percentage. Alignment is rare by construction and thirty events is an anecdote.

Edge — the two subtractions, in percentage points. Positive means the alignment knew something the drift did not.

Sample — bar count and the roughly independent sample size. Overlapping horizons mean 500 bars at a 10-bar horizon is nearer 50 independent observations.

WHAT IT SHOWS RIGHT NOW

On BTCUSD 1h at the time of writing, with a 50% base rate: after bullish alignment price rose just 31.0% of the time across 58 events, an edge of −19.0 pp. Bearish alignment fared better but still negative at −7.9 pp.

Read that again, because it is the whole argument. Buying when trend, momentum and volume all agreed was substantially worse than a coin flip over this window. In a mean-reverting market that is exactly what a momentum confluence should do — it arrives late, at the point where the move it is confirming is closest to exhaustion. The indicator is not broken. The premise is.

Run it on your own symbol and timeframe before drawing any conclusion from mine. The answer changes, and being able to see it change is the point of shipping this rather than another confluence indicator that just glows green.

HONEST LIMITS

A hit rate is not a P&L. It ignores position size, cost, slippage, and the size of the moves it counts. Being right on small moves and wrong on large ones loses money at any hit rate.

Overlapping horizons correlate the observations, so the effective sample is much smaller than the event count implies. Treat differences of a few percentage points as noise.

Three votes drawn from one price series are not three independent opinions. That is a feature of the design being examined here, not a bug in the measurement.

Changing the EMA, RSI or volume lengths changes the answer. If you tune them until the edge looks good, you have fitted the window rather than found something.

NO REPAINT

There is no request.security call anywhere in this script, so the higher-timeframe lookahead problem does not arise. Every graded alignment sat at least one full horizon in the past and its outcome is already history. The current bar is scored but never graded.

Open source under MPL 2.0. Read it, fork it, tell me where I am wrong.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © harrell.jordon

//@version=6

// =============================================================================
//  TRIPLE CONFLUENCE METER - Trend, Momentum and Volume Agreement
// -----------------------------------------------------------------------------
//  Three indicators agreeing feels like three reasons. Usually it is one reason
//  counted three times, because trend, momentum and volume all read the same
//  price series and tend to move together.
//
//  So this does the ordinary thing and then the unusual one. The ordinary part
//  is a three-way vote:
//
//      Trend      close above or below an EMA
//      Momentum   RSI above or below 50
//      Volume     the bar's direction, but only when volume beats its average
//
//  Sum them and you get a score from -3 to +3. At +3 or -3 all three agree, and
//  the bars are coloured.
//
//  The unusual part is that the script then grades itself. Over the lookback it
//  counts what actually happened after every past alignment, and compares that
//  to how often price rose over the same horizon on all bars, aligned or not:
//
//      Edge = hit rate after alignment  -  base rate
//
//  That subtraction is the whole point. A signal firing in an uptrend will look
//  brilliant at 60% while the market rose 60% of the time anyway, and an edge of
//  zero says so. Positive edge means the alignment told you something the drift
//  did not already tell you.
//
//  Read the n= counts next to each rate before believing either. Alignment is
//  rare by construction, and thirty events is a story rather than a statistic.
//
//  NO REPAINT
//  There is no request.security call anywhere in this script, so the
//  higher-timeframe lookahead problem does not arise. Every graded alignment sat
//  at least one full horizon in the past and its outcome is already history; the
//  current bar is scored but never graded.
// =============================================================================

indicator(
     title      = "Triple Confluence Meter - Trend, Momentum and Volume Agreement",
     shorttitle = "Confluence",
     overlay    = true)

// -------------------------------------------------------------------- inputs
gS = "Signals"
emaLen  = input.int(50, "EMA length",           minval = 2,  maxval = 400, group = gS)
rsiLen  = input.int(14, "RSI length",           minval = 2,  maxval = 100, group = gS)
volLen  = input.int(20, "Volume average",       minval = 2,  maxval = 200, group = gS, tooltip = "Volume only votes when it beats this average, and it votes in the direction of the bar. On symbols with no volume feed it abstains and the score runs -2 to +2.")

gM = "Measurement"
horizon  = input.int(10,  "Forward horizon (bars)", minval = 1, maxval = 50, group = gM, tooltip = "How far ahead an alignment is graded.")
lookback = input.int(500, "Lookback (bars)",        minval = 100, maxval = 2000, step = 100, group = gM, tooltip = "How far back to gather graded alignments. Longer gives more events but blends regimes.")

gD = "Display"
showTable = input.bool(true,  "Scorecard",     group = gD)
colorBars = input.bool(true,  "Colour aligned bars", group = gD)
showMarks = input.bool(true,  "Mark new alignments", group = gD)
showEma   = input.bool(true,  "Plot the EMA",  group = gD)
tblPos    = input.string("Top right", "Scorecard position", options = ["Top right", "Middle right", "Bottom right", "Bottom left"], group = gD)
txtSize   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gD)
upCol     = input.color(#26a69a, "Bullish", group = gD, inline = "c")
dnCol     = input.color(#ef5350, "Bearish", group = gD, inline = "c")
hotCol    = input.color(#f7931a, "Accent",  group = gD, inline = "c")

// ------------------------------------------------------------------ helpers
posOf(s) =>
    switch s
        "Top right"    => position.top_right
        "Middle right" => position.middle_right
        "Bottom right" => position.bottom_right
        "Bottom left"  => position.bottom_left
        =>                position.top_right

sizeOf(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

// Rolling window sum that is valid from the first bar, unlike math.sum which
// stays na until the window fills.
roll(src, len) =>
    c = ta.cum(src)
    c - nz(c[len])

// --------------------------------------------------------------- the 3 votes
ema    = ta.ema(close, emaLen)
rsi    = ta.rsi(close, rsiLen)
volAvg = ta.sma(nz(volume), volLen)

hasVol    = not na(volume) and volume > 0 and volAvg > 0
trendVote = close > ema ? 1 : -1
momVote   = rsi  > 50   ? 1 : -1
volVote   = hasVol and volume > volAvg ? (close > open ? 1 : -1) : 0

score   = trendVote + momVote + volVote
maxVote = hasVol ? 3 : 2
aligned = math.abs(score) == maxVote
bull    = aligned and score > 0
bear    = aligned and score < 0

newBull = bull and not bull[1]
newBear = bear and not bear[1]

// ------------------------------------------------------- grading the history
// An alignment that happened `horizon` bars ago has a known outcome now, so
// every term here is fixed-offset history rather than a peek forward.
fwd      = close - close[horizon]
wasBull  = nz(bull[horizon]  ? 1.0 : 0.0)
wasBear  = nz(bear[horizon]  ? 1.0 : 0.0)
gradable = bar_index > horizon

bullN   = roll(gradable ? wasBull : 0.0, lookback)
bearN   = roll(gradable ? wasBear : 0.0, lookback)
bullHit = roll(gradable and wasBull == 1.0 and fwd > 0 ? 1.0 : 0.0, lookback)
bearHit = roll(gradable and wasBear == 1.0 and fwd < 0 ? 1.0 : 0.0, lookback)
allN    = roll(gradable ? 1.0 : 0.0, lookback)
allUp   = roll(gradable and fwd > 0 ? 1.0 : 0.0, lookback)

bullRate = bullN > 0 ? bullHit / bullN : na
bearRate = bearN > 0 ? bearHit / bearN : na
baseUp   = allN  > 0 ? allUp  / allN  : na
baseDn   = na(baseUp) ? na : 1.0 - baseUp

bullEdge = na(bullRate) or na(baseUp) ? na : (bullRate - baseUp) * 100
bearEdge = na(bearRate) or na(baseDn) ? na : (bearRate - baseDn) * 100

nBars  = math.min(lookback, bar_index + 1)
indepN = math.round(nBars / math.max(1, horizon))

// ------------------------------------------------------------------ drawing
plot(showEma ? ema : na, "EMA", color = color.new(hotCol, 20), linewidth = 2)
barcolor(colorBars and aligned ? (bull ? upCol : dnCol) : na)
plotshape(showMarks and newBull, "New bullish alignment", shape.triangleup,   location.belowbar, color.new(upCol, 0), size = size.tiny)
plotshape(showMarks and newBear, "New bearish alignment", shape.triangledown, location.abovebar, color.new(dnCol, 0), size = size.tiny)

// ---------------------------------------------------------------- scorecard
var table tb = table.new(posOf(tblPos), 2, 11, border_width = 0, frame_width = 0)

arrow(v) => v > 0 ? "▲" : v < 0 ? "▼" : "–"
vcol(v)  => v > 0 ? upCol : v < 0 ? dnCol : color.new(chart.fg_color, 55)

if barstate.islast
    table.clear(tb, 0, 0, 1, 10)

    if showTable
        ts     = sizeOf(txtSize)
        dim    = color.new(chart.fg_color, 45)
        txt    = chart.fg_color
        bg     = color.new(chart.bg_color, 12)
        sCol   = aligned ? (bull ? upCol : dnCol) : dim

        // Row 0 is a deliberate blank. TradingView's symbol legend covers the top
        // row of a table in the price pane whatever it holds, so it gets this one.
        table.cell(tb, 0, 0, " ", text_size = ts)
        table.cell(tb, 1, 0, " ", text_size = ts)

        table.cell(tb, 0, 1, "TRIPLE CONFLUENCE", text_color = hotCol, bgcolor = color.new(hotCol, 88), text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 1, "", bgcolor = color.new(hotCol, 88), text_size = ts)

        table.cell(tb, 0, 2, "Trend  EMA " + str.tostring(emaLen), text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 2, arrow(trendVote), text_color = vcol(trendVote), bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 3, "Momentum  RSI " + str.tostring(rsiLen), text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 3, arrow(momVote) + "  " + str.tostring(rsi, "0.0"), text_color = vcol(momVote), bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 4, "Volume  vs " + str.tostring(volLen), text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 4, hasVol ? arrow(volVote) : "no feed", text_color = vcol(volVote), bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 5, "Score", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 5, (score > 0 ? "+" : "") + str.tostring(score) + " / " + str.tostring(maxVote) + (aligned ? "   ALIGNED" : ""), text_color = sCol, bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 6, "Base rate up", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 6, na(baseUp) ? "—" : str.tostring(baseUp * 100, "0.0") + "%", text_color = txt, bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 7, "After bull align", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 7, na(bullRate) ? "—" : str.tostring(bullRate * 100, "0.0") + "%   n=" + str.tostring(bullN, "0"), text_color = txt, bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 8, "After bear align", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 8, na(bearRate) ? "—" : str.tostring(bearRate * 100, "0.0") + "%   n=" + str.tostring(bearN, "0"), text_color = txt, bgcolor = bg, text_size = ts, text_halign = text.align_right)

        eTxt = na(bullEdge) or na(bearEdge) ? "—" :
             (bullEdge >= 0 ? "+" : "") + str.tostring(bullEdge, "0.0") + " / " + (bearEdge >= 0 ? "+" : "") + str.tostring(bearEdge, "0.0") + " pp"
        eCol = na(bullEdge) or na(bearEdge) ? dim : (bullEdge + bearEdge) / 2 >= 2 ? upCol : (bullEdge + bearEdge) / 2 <= -2 ? dnCol : dim

        table.cell(tb, 0, 9, "Edge  bull / bear", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 9, eTxt, text_color = eCol, bgcolor = bg, text_size = ts, text_halign = text.align_right)

        table.cell(tb, 0, 10, "Sample", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_left)
        table.cell(tb, 1, 10, str.tostring(nBars) + " bars   ~" + str.tostring(indepN) + " independent", text_color = dim, bgcolor = bg, text_size = ts, text_halign = text.align_right)

// ------------------------------------------------------------------- alerts
alertcondition(newBull, "New bullish alignment", "All three agree bullish")
alertcondition(newBear, "New bearish alignment", "All three agree bearish")

// -------------------------------------------------- data window diagnostics
plot(score,    "Score",         display = display.data_window)
plot(bullN,    "Bull events",   display = display.data_window)
plot(bearN,    "Bear events",   display = display.data_window)
plot(baseUp  * 100, "Base up %",  display = display.data_window)
plot(bullRate * 100, "Bull hit %", display = display.data_window)
plot(bearRate * 100, "Bear hit %", display = display.data_window)
plot(bullEdge, "Bull edge pp",  display = display.data_window)
plot(bearEdge, "Bear edge pp",  display = display.data_window)
````
