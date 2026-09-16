<!-- tradingview-pine-id: PUB;7309167af42d46f6a52a193e99012992 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# GBPJPY 200EMA Pullback [FibonacciFlux]

Source: https://www.tradingview.com/script/QW7b0QDR-GBPJPY-200EMA-Pullback-FibonacciFlux/

## Description

A with-trend 200EMA filter around a counter-trend RSI entry, built for one pair, published with the arithmetic that says confirming it would take about four years, and with the first month of that data saying no.

WHAT IT DOES

On a 1-minute GBPJPY chart:

    Long  : close above EMA(200) and RSI(14) at or below 30
    Short : close below EMA(200) and RSI(14) at or above 70
    Hold  : 500 bars, then exit. No overlapping positions - while one is open, no new entry is taken.

Triangles mark entries, a cross marks the exit, and two Data Window series report the position (+1 / -1 / 0) and the bars remaining, so another script can read them with input.source. That is the whole indicator. It places no orders and computes no equity curve.

WHERE IT CAME FROM

It is the one configuration that survived a holdout in a search run on 2026-07-27, on GBPJPY 1-minute data from histdata, 2002-2026, scored in basis points against the population of all 500-minute moves:

    dev     2002-2013 : diff +3.566bp   t = +3.56   n = 2,949   MDE 2.805   powered
    holdout 2014-2026 : diff +2.186bp   t = +2.94   n = 3,179   MDE 2.086   powered
    after cost        : 1 pip +1.579bp  /  2 pip +0.972bp

Selection was made on dev only: of 59 cells, 2 had power, and the larger diff of those 2 was taken. The holdout was scored once.

The pair-specific argument is that on 12 untouched pairs, spanning 17.5 to 20.9 years each, the plain RSI counter-trend leg is positive on every one (+0.122 to +1.600bp) and adding the 200EMA filter drags the average down to +0.097bp - so on those pairs the filter is redundant. GBPJPY is the only one that is negative unfiltered (-0.755bp) and only turns positive once the filter is applied.

NONE OF THAT IS RE-VERIFIED HERE, AND THE ORIGINAL AUTHOR'S OWN RESERVATIONS ARE PART OF THE CLAIM

Those figures come from histdata M1 that is not obtainable from TradingView, so this publication does not reproduce them and does not ask you to take them on faith. They are stated as the provenance of the rule, not as evidence for it. The reservations recorded with the research are reproduced in the source header verbatim in substance, and they are unusually damaging:

The holdout was used twice. The first use was invalid, because the selection rule ranked cells by diff without checking power and picked a cell with n = 109 and no power. As trials, that is a multiplicity of 2.

The time split was chosen after looking at the pooled 24-year aggregate, so it is partially contaminated, and the year-by-year distribution has never been looked at.

The 500-minute hold is a time-based exit. Take-profit and stop-loss were never tested; adding either makes this a different system.

By the research's own account, the only fully uncontaminated evidence is forward data from the research date onward.

SO HERE IS THE FIRST 28 DAYS OF EXACTLY THAT

28,378 one-minute GBPJPY bars from Yahoo Finance, 2026-07-29 to 2026-08-26, entirely after the research date, run through this exact rule:

    22 completed round trips
    mean +4.118bp,  t = +0.46,  median -4.17bp,  8 wins of 22

Read no further into that mean than the next paragraph allows, because three of those twenty-two are not what this rule says it does.

THE HOLD IS 500 BARS, NOT 500 MINUTES, AND OVER A WEEKEND THOSE ARE NOT THE SAME THING

The exit fires 500 BARS after entry. On a 1-minute chart that is 500 minutes - except across the weekend close, where the next bar is Monday. In this 28-day window the forward series has four gaps of 49.5 hours, and three positions were opened close enough to Friday's close that their 500-bar hold ran 3,480 minutes of wall clock, or 58 hours, instead of 500 minutes.

Those three trades are the entire positive result. They returned +160.2bp, -12.4bp and -9.5bp, contributing +138.4bp of the +90.6bp total. On the nineteen trades that really are 500-minute holds:

    mean -2.514bp,  t = -0.44,  median -3.96bp,  7 wins of 19

Negative. So the sentence that would have been written here - "the sign agrees with the research" - is false on the trades the rule actually describes. It agrees only if three weekend-spanning holds are counted as if they were 500-minute ones, and one of those is a +160bp outlier.

This is a property of the script and not only of my data. The hold is implemented as a bar counter, so anyone running it live will get 58-hour holds across weekends too, with no marker or setting to tell them apart. It is worth knowing before the exit cross is read as a 500-minute result.

Against a null that circularly shifts the forward-return series while keeping the entry times where they are, over 2,000 draws, the all-22 mean sits at upper-tail p = 0.261 - unremarkable. The two statistics that come closest to significance both point against the rule: the win rate of 36.4% against a null median of 50.0% at lower-tail p = 0.114, and the median trade of -4.17bp against a null median of +0.50bp at lower-tail p = 0.079.

One thing does line up. The rule fires 0.786 times a day here, against 0.725 in the research's holdout and 0.673 in its dev period - so the event definition being tested is the same one, which is the least this check could establish and it did establish it.

One more sizing note. The 22 trades occupy 11,000 of the 28,378 bars, and the 105 raw signals are only 46 contiguous episodes averaging 2.3 bars each. The count of independent observations here is 22 - not 105, and certainly not 28,378.

Two numbers in this write-up are worth labelling before they get quoted back as evidence. The entry count of 22, and the 79% of raw signals the no-overlap gate suppresses, are both EXACTLY invariant when the forward returns are circularly shifted - p = 1.000 and p = 0.926. They describe how often the rule fires and how clustered its signals are, which is a property of the rule and of the autocorrelation of price. Neither can ever be evidence that it predicts anything. They are here for sizing expectations, and for nothing else.

THE NUMBER THAT MATTERS MOST

On the nineteen clean trades, with a 24.9bp spread, the smallest effect this window could resolve at 80% power is 16bp. That is seven times the effect being claimed. (Counting all twenty-two, the spread is 41.9bp and the floor is 25bp, eleven times.)

Detecting +2.186bp at 80% power needs roughly 1,000 trades. At 0.68 clean trades a day, that is about four years of forward data - and that is the optimistic figure, taken on the tighter of the two spreads.

That is not a criticism of the research; it is the size of the thing being looked for. A 2bp edge over a 500-minute hold is small against 42bp of noise per trade, and no amount of care in the backtest changes how long the clean test takes. Until then the claim is neither confirmed nor refuted, and this indicator is a way to watch it rather than evidence for it.

THE PUBLISHED SETTINGS ARE THE WEAKEST OF THEIR OWN NEIGHBOURHOOD

Running the same shift null on nearby parameter cells, upper-tail p for the mean: 0.282 at the published 30/70 with EMA200 and a 500-bar hold, against 0.020 at RSI 40/60, 0.036 at 25/75, 0.055 at a 100-bar hold, 0.060 at EMA150 and 0.075 at a 250-bar hold. Five of the seven neighbours tried beat the published cell.

That is not an argument for moving the settings, and it should not be read as one. Eight cells were looked at; one below 0.05 is what chance produces. A wider 100-cell sweep scored with a family-wise max-t null clears nothing at all - the best cell reaches t = 2.43 against a null whose own maximum averages 2.18, at p = 0.374. What it is an argument for is distrusting the precision of any single cell, including the one shipped here, which was itself chosen as the best of 59 on dev data.

THE CROSS-PAIR CLAIM DOES NOT SHOW UP IN ONE MONTH EITHER

Over the identical 28-day window, restricted to clean 500-minute holds, the same rule returns -3.45bp on EURJPY (n=14), +12.16bp on USDJPY (n=15), +20.11bp on AUDJPY (n=13), -2.30bp on GBPUSD (n=20) and -1.32bp on EURUSD (n=28), against -2.51bp on GBPJPY (n=19). None is significant, and GBPJPY is fourth of six.

Worse for the pair-specific argument, USDJPY reproduces its exact signature and does it harder. The argument is that GBPJPY alone is negative on the raw RSI leg and only turns positive once the EMA filter is applied. On this window USDJPY goes from -3.89bp unfiltered to +8.66bp filtered, a swing of +12.54bp, against GBPJPY's -7.13bp to +4.12bp, a swing of +11.25bp. Neither swing is resolvable - Welch gives p = 0.304 and p = 0.430, and all six pairs' intervals straddle zero - but the thing the argument is named after shows up on a second pair, larger.

The more specific version of the claim fares slightly better. Stripping the EMA200 filter and taking the RSI leg alone, GBPJPY is the most negative of the six at -7.13bp over 50 trades - which is the direction the research predicts - but USDJPY at -3.89bp and EURUSD at -3.64bp are negative too, so "GBPJPY is the only negative one" is not what this month shows. At about 50 trades per pair and a 40bp spread, the standard error is around 6bp, so none of this column separates from zero.

THE FILTER ITSELF DOES NOT CLEAR ON FORWARD DATA, AND THE NULL DECIDES IT

The EMA200 filter is the whole argument for this being a GBPJPY rule. Isolating it - shifting only the close-above-EMA200 condition, which preserves that state's very high persistence - it reaches p = 0.094 and does not clear. Against a null that instead selects bars by an independent coin flip it reaches p = 0.025 and appears to clear. The difference is entirely the null: a per-bar coin flip destroys the clustering that makes the filter's state meaningful, so it is the easier and the wrong comparison. On this month of data the filter is not established.

The filter also behaves like a switch rather than a knob. Between EMA lengths of 9 and 70 it emits zero entries at all, because over that band a close above a fast EMA and RSI at or below 30 almost never coincide. That dead zone reproduces identically on EURJPY, USDJPY and AUDJPY, so it is pair-independent mechanics rather than anything about GBPJPY - which is worth knowing, because the pair-specific story is the reason the filter is there.

WHAT CHANGED IN THIS VERSION

The exit marker was drawn with location.absolute against a boolean, which plots it at price 0. On any instrument that does not trade near zero that both hides the marker and drags the price axis down to zero: loaded on BTCUSDT it compressed every candle into a hairline at the top of the pane and filled the bottom with a grey smear. It now takes the close, so the cross appears where the exit actually happens. It was also a size.tiny grey cross sitting exactly on the close, which is close to invisible against a candle; it is now small and silver. This is the one change that alters what you see.

The entire file was in Japanese - header, input labels, plot titles and alert names - and is now in English. The title was "GBPJPY Pullback", which named a pair and a concept but not a mechanism; it now names the mechanism too. An MPL header was added.

The source noted that it had never been compiled, because it was written without a Pine environment. It compiles.

The measurements above are now in the header and in three input tooltips. No computation changed.

HOW THE NUMBERS WERE CHECKED

The logic was reimplemented outside Pine and cross-checked against this chart's Data Window on BINANCE:BTCUSDT 1-minute - not GBPJPY, deliberately, because Binance klines can be fetched bit-identical to what TradingView charts while a forex feed cannot. Eleven quantities on ten bars: the EMA, the RSI, both raw conditions, both entry flags, the exit flag, the position and the bars remaining. All 110 values round to the decimals TradingView prints, worst raw difference 4.6e-3. The state machine matched exactly on every bar, including one carrying an exit and one where a raw signal was correctly suppressed because a position was already open - so the no-overlap gate and the exit path were exercised rather than assumed.

That gate is not decoration. Over the forward window it suppresses 83 of 105 raw signals, 79% of them. The research notes that a run without it collapsed an apparent n of 1.35 million to an effective 2 and produced a fake t of +66.84.

WHAT THE MEASUREMENTS COVER

The forward test is 28 days, one pair, one data vendor, in a window where GBPJPY fell 81bp. The cross-pair table is the same 28 days. The implementation check is on a crypto pair on a different exchange. Nothing here covers the 2002-2026 research period, transaction costs beyond the figures quoted from the research, or any exit other than the 500-bar timer.

WHAT YOU NEED ON THE CHART BEFORE ANY OF THIS APPEARS

Nothing is discarded manually; Pine's na-propagation does it, so the first entry cannot occur before bar 200. Two consequences on a short chart. The EMA200 seed stays visible well past its first plotted value - recomputing from a start 6,000 bars later, the series disagrees with the settled one for another 432 bars. And with a 500-bar hold, a position opened in the last 500 bars can never show its exit cross. On a 1,500-bar chart that is 13% lost to the seed and 33% to the unclosable tail, leaving about half the chart able to host a complete round trip.

REPAINTING

None by construction. Every value is a confirmed same-bar value and there is no request.security anywhere, so there is no higher-timeframe path by which a value could change after its bar closed. On the still-forming bar the entry flag can appear and disappear as price moves, which is ordinary intrabar behaviour and settles when the bar closes.

Open source under MPL 2.0. Nothing here is a forecast, a signal service, or a claim of profitability.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FibonacciFlux

//@version=6
// =============================================================================
// GBPJPY 200EMA Pullback - with-trend 200EMA x counter-trend RSI
// =============================================================================
// The one configuration that survived a holdout in a search run on 2026-07-27.
//
//   Long : close > EMA200  and RSI(14) <= 30
//   Short: close < EMA200  and RSI(14) >= 70
//   Hold : 500 minutes (500 bars on a 1-minute chart). No overlapping positions
//          - while one is open no new entry is taken.
//
// THE ORIGINAL RESEARCH (GBPJPY M1, histdata, DEF-1 excluded, 500-minute hold,
// stated as basis points against the population of all 500-minute moves)
//   dev     2002-2013 : diff +3.566bp  t=+3.56  n=2,949  MDE 2.805  powered
//   holdout 2014-2026 : diff +2.186bp  t=+2.94  n=3,179  MDE 2.086  powered
//   after cost        : 1 pip +1.579bp / 2 pip +0.972bp
//   Selection was made on dev only: of 59 cells, 2 had power, and the larger
//   diff of those 2 was taken. The holdout was scored once.
//
// WHY THIS IS SAID TO BE GBPJPY-SPECIFIC
//   Measured on 12 untouched pairs (17.5-20.9 years each), the plain RSI
//   counter-trend leg is POSITIVE on every one of them (+0.122 to +1.600bp),
//   and adding the 200EMA filter drops the average to +0.097bp. On those pairs
//   the filter is redundant. GBPJPY is the only one that is negative unfiltered
//   (-0.755bp) and only turns positive once the filter is applied. That is the
//   whole argument for the filter, and the reason not to move this to other pairs.
//
// RESERVATIONS - none of these are rhetorical
//   * The holdout was used TWICE. The first use was invalid: the selection rule
//     ranked cells by diff without checking power and picked a cell with n=109
//     and no power. As trials, that is a multiplicity of 2.
//   * The time split was chosen after looking at the pooled 24-year aggregate,
//     so it is partially contaminated. The year-by-year distribution has never
//     been looked at.
//   * The only fully uncontaminated evidence is forward data from the date of
//     the research onward. See the next block for the first 28 days of it.
//   * The 500-minute hold is a time-based exit. Take-profit and stop-loss were
//     never tested. Adding either makes this a different system.
//
// WHAT THIS PUBLICATION ADDS - the first slice of that forward data
//   28,378 one-minute GBPJPY bars, 2026-07-29 to 2026-08-26 (Yahoo Finance),
//   which is entirely after the research date, run through this exact rule:
//     22 completed round trips. Mean +4.118bp, t = +0.46, median -4.17bp, 8 wins of 22.
//   THREE OF THOSE 22 ARE NOT 500-MINUTE HOLDS. The exit fires 500 BARS after entry, and
//   across the weekend close the next bar is Monday: the forward window has four gaps of
//   49.5 hours, and three positions ran 3480 minutes of wall clock instead of 500. Those
//   three returned +160.2, -12.4 and -9.5bp, contributing +138.4bp of the +90.6bp total.
//   On the NINETEEN trades that really are 500-minute holds: mean -2.514bp, t = -0.44,
//   median -3.96bp, 7 wins of 19. Negative. The sign does NOT agree with the research on
//   the trades this rule describes; it agrees only if weekend-spanning holds are counted
//   as if they were 500-minute ones.
//   This is a property of the script, not just of that data set - the hold is a bar
//   counter, so a live chart produces 58-hour weekend holds too, with nothing marking them.
//   Against a null that circularly shifts the forward returns while keeping the entry
//   times, 2000 draws: the all-22 mean sits at upper-tail p = 0.261, while the WIN RATE
//   of 36.4% sits at lower-tail p = 0.114 and the median at lower-tail p = 0.079. The only
//   results that come close to significance point AGAINST the rule, not for it.
//   On the 19 clean trades, with a 24.9bp spread, the smallest effect this window could
//   resolve at 80% power is 16bp - seven times the +2.186bp being claimed.
//
//   That is the number worth keeping: detecting +2.186bp at 80% power needs about
//   1,000 trades, and this rule fires 0.68 clean trades a day. The forward test the
//   reservations above call for therefore takes ABOUT FOUR YEARS, and that is the
//   optimistic reading, taken on the tighter of the two spreads. Until then the claim
//   is neither confirmed nor refuted, and this indicator is a way to watch it, not
//   evidence for it.
//
//   The published parameter cell is also the weakest of its own neighbourhood on this
//   data. Upper-tail shift-null p for the mean: 0.282 at the published 30/70 with
//   EMA200 and a 500-bar hold, against 0.020 at RSI 40/60, 0.036 at 25/75, 0.055 at a
//   100-bar hold, 0.060 at EMA150 and 0.075 at a 250-bar hold. Five of the seven
//   neighbours tried beat it. That is not a reason to move the settings - with eight
//   cells looked at, one below 0.05 is what chance produces, and a 100-cell sweep with
//   a family-wise max-t null clears nothing at all. It is a reason to distrust the
//   precision of any one cell, including this one.
//
//   For contrast, over the same 28 days on clean 500-minute holds only, the identical
//   rule returns -3.45bp on EURJPY, +12.16bp on USDJPY, +20.11bp on AUDJPY, -2.30bp on
//   GBPUSD and -1.32bp on EURUSD, against -2.51bp on GBPJPY - which is fourth of six.
//   And USDJPY reproduces the GBPJPY signature harder: -3.89bp unfiltered to +8.66bp
//   filtered, a swing of +12.54bp, against GBPJPY's -7.13 to +4.12, a swing of +11.25.
//   Neither swing is resolvable (Welch p = 0.304 and 0.430), but the thing the
//   pair-specific argument is named after shows up on a second pair, larger.
//
// TWO NUMBERS IN HERE THAT ARE NOT EVIDENCE. The entry count (22 in 28,378 bars) and the
//   share of raw signals the no-overlap gate suppresses (79%) are EXACTLY invariant when
//   the forward returns are circularly shifted - p = 1.000 and p = 0.926. They describe how
//   often the rule fires and how clustered its signals are, which is a property of the
//   rule and of the autocorrelation of price, not of whether it predicts anything. They
//   are quoted below because they are useful for sizing expectations, and for no other reason.
//
// REPAINTING: none by construction. Every value is a confirmed same-bar value
//   and there is no request.security anywhere, so there is no higher-timeframe
//   path through which a value could change after its bar closed.
//
// The original file noted that it had never been compiled. It compiles.
// =============================================================================

indicator("GBPJPY 200EMA Pullback [FibonacciFlux]", shorttitle = "GJ-PB", overlay = true)

emaLen   = input.int(200, "EMA length", minval = 2,
     tooltip = "The with-trend filter, and the research's whole argument for why this rule is GBPJPY-specific. Two cautions from the forward data. First, it behaves like a switch rather than a knob: between 9 and 70 it emits ZERO entries, because over that band a close above a fast EMA and RSI at or below 30 almost never coincide. That dead zone reproduces identically on EURJPY, USDJPY and AUDJPY, so it is pair-independent mechanics rather than anything about GBPJPY. Second, isolating the filter against a null that circularly shifts only the close-above-EMA state - which preserves that state's very high persistence - it reaches p = 0.094 and does not clear. Against a per-bar coin-flip selector it reaches p = 0.025 and appears to clear. The null choice decides the answer, which means the forward data does not settle it.")
rsiLen   = input.int(14,  "RSI length", minval = 2)
rsiLo    = input.float(30, "RSI long threshold",
     tooltip = "Long requires close above the EMA and RSI at or below this. Over the 28-day forward window this and its short mirror were true on 105 bars of 28,378, and 22 of those became entries after the no-overlap gate.")
rsiHi    = input.float(70, "RSI short threshold")
holdBars = input.int(500, "Hold length in bars (500 = 500 minutes on a 1-minute chart)", minval = 1,
     tooltip = "A time-based exit, and the only exit that was ever tested. Take-profit and stop-loss were not tested at all; adding either makes this a different system whose numbers are unknown.")
showLine = input.bool(true, "Draw the EMA",
     tooltip = "On by default. It is the only purely cosmetic input here - a parameter sweep confirms it changes none of the conditions, entries, exits, position or bars-left, and moves the median trade by exactly 0.000 - but the EMA200 is the filter that does all the work in this rule, and leaving it invisible made the indicator two triangles on a bare chart.")

ema = ta.ema(close, emaLen)
rsi = ta.rsi(close, rsiLen)

rawLong  = close > ema and rsi <= rsiLo
rawShort = close < ema and rsi >= rsiHi

// No overlapping positions: while one is open, no new entry is taken. Without this the same
// move gets counted many times over - in the research a run without it collapsed an apparent
// n of 1.35 million to an effective 2 and produced a fake t of +66.84.
// Measured on the 28-day forward window, this gate suppresses 83 of 105 raw signals (79%).
var int barsLeft = 0
var int posDir   = 0

entryLong  = rawLong  and barsLeft <= 0
entryShort = rawShort and barsLeft <= 0

if entryLong
    barsLeft := holdBars
    posDir   := 1
else if entryShort
    barsLeft := holdBars
    posDir   := -1
else if barsLeft > 0
    barsLeft := barsLeft - 1
    if barsLeft == 0
        posDir := 0

exitNow = barsLeft == 0 and barsLeft[1] == 1

plot(showLine ? ema : na, "EMA", color = color.new(color.orange, 0))

plotshape(entryLong,  "Long entry",  shape.triangleup,   location.belowbar, color.new(color.teal, 0), size = size.tiny)
plotshape(entryShort, "Short entry", shape.triangledown, location.abovebar, color.new(color.red,  0), size = size.tiny)

// The exit marker was previously plotted with location.absolute against a BOOLEAN, which puts
// it at price 0 or 1. On any instrument that does not trade near zero this both hides the marker
// and drags the price axis down to 0 - on BTCUSDT it compressed every candle into a hairline at
// the top of the pane. Passing the close instead puts the cross where the exit actually happens.
plotshape(exitNow ? close : na, "Exit", shape.xcross, location.absolute, color.new(color.silver, 0), size = size.small)

// Data Window only, so another script can pick these up with input.source. The
// display.data_window on the second line is load-bearing and easy to delete by accident:
// "Bars left" runs 0 to 500, so on the pane it would stretch the price axis to [0, 500]
// and squash GBPJPY candles into under 2% of the pane height. "Position" runs -1 to +1
// and would do the same thing by pinning the axis floor to -1.
plot(posDir,   "Position (+1 long / -1 short / 0 flat)", display = display.data_window)
plot(barsLeft, "Bars left in the hold",                  display = display.data_window)

alertcondition(entryLong,  "Long entry",  "GBPJPY 200EMA Pullback: LONG. Descriptive, not a forecast - the effect this is built on has never been confirmed on uncontaminated forward data, and doing so would take about four years. On the first 28 days of it, restricted to the trades that really are 500-minute holds, the mean is negative.")
alertcondition(entryShort, "Short entry", "GBPJPY 200EMA Pullback: SHORT. Descriptive, not a forecast - the effect this is built on has never been confirmed on uncontaminated forward data, and doing so would take about four years. On the first 28 days of it, restricted to the trades that really are 500-minute holds, the mean is negative.")
alertcondition(exitNow,    "Exit",        "GBPJPY 200EMA Pullback: EXIT after the 500-bar hold.")
````
