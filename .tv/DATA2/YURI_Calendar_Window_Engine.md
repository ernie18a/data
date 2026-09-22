<!-- tradingview-pine-id: PUB;4c28fd1f540f4f71973f57a47bc3f895 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# YURI Calendar Window Engine

Source: https://www.tradingview.com/script/uUEaeEP6/

## Description

Three date rules and one measurement. The rules mark the week the monthly listed-option expiry falls in, the turn of the month, and the last session before a US market holiday. The measurement is what this symbol's own daily returns have done on the days each rule marks, set against the days none of the three rules mark, with an error band built from one figure per run of the window rather than one per day. On the funds measured below, none of the three differences reaches that band. That is the result, and it is why nothing here is an entry.

HOW TO USE IT

Put it on a daily chart of a symbol that keeps a US exchange calendar, and load as much history as the chart will give. Each window needs 20 completed runs before its row reads, which is around two years of bars, and the error band goes on narrowing for a long time after that. A symbol that trades seven days a week is refused by name.

Read the status line first. It counts up to the minimum and then reads ok.

Then read the table. Today says which of the three windows the current bar falls in, if any. Each window row gives the mean daily return on the days that window marks, less the mean on ordinary days, in basis points a day, with its error band, its day count and its run count beside it. The comparison that matters is the difference against its own band. A difference smaller than its band is one the history on this chart does not separate from zero, and on the funds measured below that is how all three rows read.

The pane draws one window at a time. Pick it with Window drawn in the pane. The orange line is the running difference, the grey band is its error, and the tint marks the bars the rule selects, so the rule itself can be checked by eye against a calendar.

If the symbol pays dividends, set the chart's dividend adjustment on purpose before comparing any figure with the ones quoted here. THE CHART SETTING THAT MOVES ONE OF THEM says which row it moves and by how much.

WHY THE THREE RULES ARE IN ONE SCRIPT

An ordinary day can only be defined by naming every calendar rule it is not. The baseline each window is measured against is therefore not defined until all three calendars have been computed on the same bar, which is the thing a single-window marker cannot do for itself.

Compare a window against its own complement instead and the comparison is contaminated in a way that is easy to miss. The turn of the month then sits inside the expiry week's baseline, the expiry week sits inside the turn of the month's, and each rule is measured against a mixture containing the others. At the default edges the three rules between them label three days in five of a US equity fund's history, so the contamination would not be small: expiry weeks are 23 percent of days and the turn of the month window is 37 percent, against 38 percent left over.

The three windows are not versions of each other. On SPY's history the expiry week and the turn of the month share no day at all, by construction, since the expiry Friday is dated 15 to 21 and the turn window opens on the 26th. A session before a holiday lands inside an expiry week on 48 days and inside a turn of month on 136. The rank correlations between the three daily flags are small, the largest being minus 0.42, but that pair is the mutually exclusive one and its correlation is driven by the exclusivity rather than by anything in the returns. The count of shared days is the number that carries the point.

WHAT THE THREE WINDOWS ARE

Expiry week is the Monday to Friday week whose Friday is dated 15 to 21 of the month, which is the third Friday and the monthly expiry of US listed options. The rule is written as the nth Friday, so the setting can be moved to the second or fourth Friday's week to see what an ordinary week of the month reads by comparison. The whole week is marked, not the Friday alone.

The setting starts at the second Friday rather than the first, and the reason is worth stating because it is a limit of the arithmetic. A bar is tested by projecting it forward to the Friday of its own week and asking whether that day of month falls in the right range. A week containing a Friday dated 8 or later begins on a Monday dated 4 or later and so begins in the same month, which makes the projection exact; that was checked against a direct computation over every weekday from 1993 to 2026 at the second, third and fourth Friday, with no disagreement. The week of a month's first Friday can begin in the month before, where the projection runs past the end of the range and the early part of the week goes unmarked. At that setting 582 of the 2040 weekdays in those weeks would be missed, so the setting is out of range rather than approximately right.

Turn of the month opens on the first session dated on or after the 26th and closes after the fourth session of the new month. That is around four sessions either side of the boundary. The month's sessions are counted as they arrive rather than backwards from the month's end, which is what lets the far edge be placed without needing to know in advance which days the market will be open.

Session before a holiday is the last session before a day the US market is shut. Holidays are computed rather than listed. Most are a weekday-of-month rule plus the observed-day shift for the fixed dates, with two start years in them: Juneteenth from 2022, and the third Monday of January from 1998. That second one came out of checking the rules against a large index fund's own trading days, which show the exchange open on that Monday in 1994, 1995, 1996 and 1997 and shut on it from 1998 on. Good Friday follows Easter rather than the day of the month, so it is computed too, by the anonymous Gregorian computus in the Meeus, Jones and Butcher form, taking Easter Sunday and stepping back two days.

HOW THE HOLIDAY RULES WERE CHECKED

Against the market's own record rather than against a published list. Every weekday from 1993 to 2026 was compared with whether a large index fund printed a bar on it. Over 8467 sessions, no day the rules call a holiday is a day the market traded, and every one of the 34 Good Fridays in that window is a day it did not. Eleven closed weekdays are not caught: one in April 1994, four in September 2001, two in October 2012, and one each in June 2004, January 2007, December 2018 and January 2025. All eleven are one-off closures the market announced at the time, which is outside what any calendar rule can compute. The session before each of them is not marked, which is a miss on eleven days in 8467.

The Easter computation is why there is no date table in this script and no year it runs out in. An earlier version of this file carried a list of eleven Good Fridays and set aside two months of every year the list did not reach, which on a permanently published script would have meant a permanent degradation from 2027. The computation was checked against that list year for year, and against an independent implementation on every year from 1900 to 2099, with no disagreement in either; in all 200 of those years the result is a Friday, and it falls between March 21 and April 23.

Because of that, the session before Good Friday is marked in every year a chart carries. On the index fund's history that is 34 of 34, where a list covering eleven years could have reached eleven.

A bar that falls on a rules holiday while the chart still prints one, which is what a contract for difference on an index does, is set aside: it ends no run, enters no average of its own, and is counted in its own table row. Its close is still the price the next session's return is measured from, so that session is measured from the set-aside bar rather than from the last real session before it. On a US-listed fund the row reads zero and none of that arises, which is the check that says the calendar and the symbol agree.

WHAT THE NUMBER BESIDE EACH WINDOW IS

The mean daily log return of the days that window marks, in basis points, less the same mean over the days none of the three rules mark. A bar carries the label of its own date, and its return is the close to close move ending on it. No cost is deducted anywhere.

The band is two standard errors of that difference, and it is built from one figure per completed run of the window rather than one per day. A run is a maximal stretch of consecutive marked days: an expiry week is one run of four or five sessions, a turn of month is one run of five to nine, a session before a holiday is a run of one. Counting days would be the wrong denominator if the days inside one run moved together. Measured, they do not: on the twelve comparisons where a run is longer than a day, the run band comes out between 0.940 and 0.969 of the per day band, so the two ways of counting land within six percent of each other. Both figures are in the data window.

Six of the eighteen band comparisons are the pre-holiday bucket, whose runs are one day long by construction, so for those the two bands are arithmetically almost the same whatever the returns do and they are not evidence of anything. The claim above rests on the other twelve, which is why it is quoted as twelve.

Two point estimates are also kept apart and both are printed, and the relationship between them and the band is worth being exact about. Pooling days weights a long run more heavily than a short one; averaging run averages weights them alike. Those are not the same number when run lengths differ: across the eighteen combinations they differ by up to 39 percent of the printed band, and on SPY alone by up to 32. The pane draws the pooled one, while the band is the standard error of the run-weighted one, so the line and the band belong to two different estimators. The direction of that is one-sided and is stated here rather than left to be worked out: the run-weighted estimate is the smaller of the two in every one of the eighteen, with no exception in the other direction, so the pane shows the bigger estimate against the band of the smaller. Both sit inside the band throughout, and since nothing here is claimed to separate from zero, the pairing errs toward showing an effect that then fails to appear. A reader who wants the matched pair should read the run-weighted difference from the data window against the same band.

The run that is open when the chart's history begins is dropped, because its length is whatever the chart happens to start at, and the run still open on the last bar is not counted as a run either. Their days are still in the daily average. That last point is a right censoring and it moves the run count, not the mean.

MEASURED

SPY daily bars, 1993-01-29 to 2026-09-18, chart dividend adjustment on, 8466 classified daily returns. Ordinary days average +1.4 basis points. Expiry week averages +3.8, a difference of +2.4 against a band of 6.5, over 1983 days in 403 runs. Turn of the month averages +6.6, a difference of +5.2 against a band of 5.6, over 3124 days in 403 runs. The session before a holiday averages +9.9, a difference of +8.5 against a band of 11.6, over 298 days in 298 runs.

QQQ from 1999-03-10: minus 0.2 against 10.2, +4.0 against 8.9, +10.9 against 19.7. IWM from 2000-05-26: minus 0.6 against 9.2, +5.0 against 8.2, +14.4 against 16.4. Eighteen window and symbol and adjustment combinations were computed and none reaches two of its own standard errors. The closest is the turn of the month on SPY with the adjustment off, at +5.2 against 5.6, which is 94 percent of its own band.

Two sensitivity checks, because a number that only survives one setting is not a number. Moving the turn of month edges over a grid of three opening days by three closing days moves the SPY difference between +5.2 and +7.2, a span of 2.0 against a band of 5.6. Moving the marked week to a different Friday of the month gives minus 1.9 for the second Friday's week, +2.4 for the third and +1.2 for the fourth, each with a band near 7. Adjacent weeks of the same month come out on opposite sides of zero and all three sit inside their own bands. That is the shape a set of numbers inside their own error takes, and it is the most useful single fact in this description.

THE CHART SETTING THAT MOVES ONE OF THEM

The chart's adjust-for-dividends setting moves the expiry week figure by more than moving the window edges does, and it does so for a structural reason. All 135 of the ex-dividend dates in SPY's loaded history fall inside an expiry week, with a median size of 44 basis points. Turning the adjustment off takes SPY's expiry week reading from +2.4 basis points a day to minus 0.7, a swing of 3.03 on a band of 6.5, and it changes the sign.

The three funds are not alike in this. QQQ has 55 percent of its ex dates inside an expiry week and moves by 0.43. IWM has 17 percent and moves by 0.35. So the size of the effect is a property of the fund's distribution calendar, not of the market.

This script does not read the chart's adjustment setting. Whichever way it is set, both the window average and the ordinary day average are computed on the same series, so the comparison is internally consistent; it is the level of the expiry week figure that changes. The figures quoted above are with it on. Which way a fresh chart arrives set is a platform default rather than a property of the data, so read it off the chart rather than assuming it, and note which way it was when one of these numbers is quoted.

WHAT SEPARATES, AND IT IS NOT A RETURN

The one reading that comes apart cleanly is the spread, which is in the data window as the ratio of the window's daily standard deviation to an ordinary day's. The session before a holiday carries about four fifths of an ordinary session's daily spread: 0.79 on SPY, 0.86 on QQQ, 0.77 on IWM, and under one in 25 of SPY's 34 single years, 25 of QQQ's 28 and 25 of IWM's 27, so it is not one stretch of history doing the work. Part of it is the two shortened sessions, July 3 and December 24, which come in at 0.61, but the 261 full length pre-holiday sessions are still at 0.82. Expiry week and turn of month sit at 0.98 to 1.00 and separate on nothing.

The spread ratio carries no error band in this script and should be read as description rather than as a test. It was kept because it is measurably not the mean difference in other clothes: Spearman is asked second here, because rank correlation is blind to a fold: two readings related by something of the shape y = |2x - 100| can rank near zero against each other and still be one number. So the first question is whether either reading can be computed from the other. Reconstructing the spread ratio from the mean difference over a basis that contains the fold shapes leaves a largest residual of a third of the spread ratio's own range, and the same in reverse leaves a quarter, so neither is a formula of the other. Only then the rank tests: minus 0.73 straight, minus 0.66 against the absolute value of the difference and minus 0.46 against its fold about the median, and minus 0.29 as running series on SPY. All inside the 0.8 bar set beforehand.

A third candidate reading was computed and dropped. The share of up days in a window, less the same share on ordinary days, tracks the mean difference at a Spearman of +0.92 across the same eighteen combinations. That is past the bar, so it says nothing the mean difference has not already said and it is not in the file.

WHERE THE METHODS COME FROM

The turn of the month effect is Lakonishok and Smidt, 1988. The pre-holiday effect is Ariel, 1990. Neither is this script's idea and neither is claimed as one. For expiry week only the calendar definition is used, the third Friday being the monthly expiry of US listed options; no account of why a week around it might differ is offered here, because this script measures and does not explain.

What is added is the shared baseline, the run-based error band, the two point estimates side by side, the set-aside accounting, and the measurement above showing that on these funds the three differences sit inside their own error.

READING IT

A pane on a basis points a day scale. One orange line, the running difference for whichever window is selected, against a grey band at plus and minus two standard errors and a dotted line at zero. Both are running figures, so the band narrows as history accumulates and the line settles. What the pane mostly shows is an estimate wandering inside its own error, which is the honest picture.

The pane tints when the current bar falls inside the drawn window. All three windows are in the table whichever one is drawn.

The table carries which windows today falls in, one row per window with its difference, its band, its day count and its run count, the ordinary day average with its own counts, the days that fall in two windows at once, the days set aside and how many of those were days the market was shut, the total number of daily returns measured, a standing note that the basis is close to close log returns with no costs, and a status line.

The data window carries the two standard errors separately, the difference over its standard error, the spread ratio, the run-weighted difference, the shortest, longest and mean run length of the drawn window, and the classified and set-aside counts.

Wherever a reading is withheld the status line says which of the tests withheld it, instead of a number appearing with a caveat somewhere else. Eight sentences besides ok can appear there, and they are evaluated top to bottom: the bars are synthetic; the bar length is not one day; the symbol keeps a seven day week; weekend bars have shown up in the history; no month has turned over yet; this particular bar was not a session; the ordinary day ledger is short of runs; the drawn window's ledger is short of runs. The last pair are worded alike and kept apart because the two ledgers fill at different rates, so the one that is short is the one named. Synthetic bars are tested before anything else because that is the single case in which all the remaining tests would pass and a wrong reading would look right.

The default minimum is twenty completed runs per bucket. On a chart of 400 daily bars the expiry week ledger holds 18 of them and the pre-holiday ledger 15, so all three rows come in somewhere around two years of loaded history, and the status line counts up to it.

SETTINGS THAT MATTER

The turn of month opening day is the one judgement among the defaults. Twenty six is a round choice and nothing in this script argues it is the right one. The sensitivity above is what it is worth, and the setting is exposed with a range so that moving it is a keystroke.

Which Friday of the month the expiry falls on is three for US listed options. Two and four are there as a control rather than as settings to optimise, and one is out of range for the reason given above.

Completed runs before a window reads applies to the window and to the ordinary day baseline separately. Raising it delays every row and narrows nothing.

The error band in standard errors is two by default. Two standard errors is the usual convention and it is not an exact 95 percent interval here, since it assumes returns that are independent across runs and symmetric, and daily equity returns are neither exactly.

WHAT IT WILL NOT DO

There is no order in it, no alert in it, and nothing it prints is a signal. No filter, no trend condition and no position appear anywhere, deliberately: a readout with a condition bolted to it starts to look like it has answered a question it has not.

It does not say that any of these windows is worth trading. On the three funds measured, every one of the eighteen differences computed sits inside its own two standard error band, which is the opposite of that claim. What it is, is a marker for where in the calendar today falls, carrying how large the effect has been on the symbol in front of you and how large the error on that is.

No cost is deducted anywhere. These are gross close to close moves. A number of a few basis points a day is inside the cost of acting on it for most people, and that comparison is left to the reader because this script does not know what anyone pays.

The averages describe the history loaded on the chart. Scroll back further and they change. A reader on a longer history will see different counts from the ones quoted above, and the table prints the number of daily returns behind every figure for that reason.

The holiday rules are a US exchange calendar. On a symbol that keeps a different holiday calendar the rules will mark the last session before a US holiday, which may be an ordinary session for that symbol. On a symbol that trades at weekends, or whose type is crypto, the script refuses by name rather than reading anything, because the trading day counter behind the turn of month window would be counting days the rules do not recognise.

The bars have to be real prices. Chart types that synthesise a bar out of other bars, Heikin Ashi and Renko and Kagi and Line Break and Point and Figure and Range among them, produce a close that no trade happened at, and an average of those is an average of the chart's own construction. This is the one condition checked before all the others, because it is the one where nothing else would object and the readout would look ordinary.

The bar length has to be one day. Anything shorter, anything weekly or monthly, and the two, three and five day variants are each turned away with the reason on the status line. The multi-day variants deserve their own mention: they answer to most tests the way a daily chart does, so a script that only asked whether the chart was daily would read them and be wrong by a factor of two, three or five. When a chart is turned away, all twenty drawn elements go empty and all nine value cells show a dash, so there is nothing on screen to misread. The ten labels down the table's left column are fixed text and stay where they are.

Every figure looks backwards only. Nothing printed on a bar was computed from a later one, which means the bar still forming will move while it forms and stop moving at its close, and a bar already closed keeps the reading it had. The way that was established: the entire series was recomputed on histories cut short at three different points, one of them three thousand bars back, and each cut's final bar came out bit for bit equal to the same bar of the uncut run.

This is context for a decision, not the decision.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evawpd141

//@version=6
indicator("YURI Calendar Window Engine", "YURI CWE", overlay = false, precision = 2)

// Three date rules and one measurement.
//
// The rules mark the week the monthly listed-option expiry falls in, the turn
// of the month, and the last session before a US market holiday. The
// measurement is what this symbol's own daily returns did on the days each rule
// marks, set against the days none of the three rules mark.
//
// That third bucket is the reason the three rules are in one script rather than
// three. An ordinary day can only be defined by naming every calendar rule it is
// not, so the baseline each window is measured against is not defined until all
// three calendars have been computed on the same bar. Compare a window against
// its own complement instead and the turn of the month sits inside the expiry
// week's baseline and the expiry week sits inside the turn of the month's, and
// each rule is then measured against a mixture containing the others. At the
// default edges the three rules between them label three days in five, so that
// mixing would not be a small effect.
//
// The numbers are means of daily log returns in basis points, kept as running
// sums as the chart moves, with an error band beside them. The band is built
// from one figure per completed run of the window rather than one per day,
// because a count of days would be the wrong denominator if the days inside one
// run moved together. Measured on the three funds below they do not: over the
// twelve comparisons where a run is longer than a day the run band comes out
// between 0.940 and 0.969 of the per day band. The other six are the pre-holiday
// bucket, whose runs are one day long by construction, so those two bands are
// near-identical whatever the returns do and are not evidence either way.
//
// The pane draws the day-pooled difference while the band is the standard error
// of the run-weighted one, so the line and the band belong to two different
// estimators. The run-weighted figure is the smaller of the two in all eighteen
// combinations, with no exception in the other direction, so the pane shows the
// bigger estimate against the band of the smaller. Both are in the data window
// and both sit inside the
// band throughout. What the pane mostly shows is an estimate wandering inside
// its own error.
//
// Measured on SPY daily bars from 1993-01-29 to 2026-09-18 with the chart's
// dividend adjustment on, 8466 classified daily returns, no window's difference
// reaches two of its own standard errors. Expiry week +2.4 bp a day against a
// band of 6.5, turn of the month +5.2 against 5.6, the session before a holiday
// +8.5 against 11.6. The same holds for all three windows on QQQ and on IWM over
// their own histories and on both settings of that adjustment. Moving the marked
// week to the second Friday's reads -1.9 and to the fourth Friday's +1.2, against
// bands near 7 either way, so adjacent weeks of the same month change sign while
// all three sit inside their own bands. That is the shape a set of numbers inside
// their own error takes.
//
// One thing does separate, and it is not a return. The session before a holiday
// carries a daily spread of about four fifths of an ordinary session's: 0.79
// on SPY, 0.86 on QQQ, 0.77 on IWM, and under one in 25 of SPY's 34 single
// years. Part of that is the two shortened sessions, July 3 and December 24,
// which come in at 0.61, but the full length ones are still at 0.82. That ratio
// is in the data window.
//
// The chart's dividend adjustment setting moves the expiry week figure by more
// than moving the window edges does. All 135 of the ex-dividend dates in SPY's
// loaded history fall inside an expiry week, median size 44 bp, so turning that
// adjustment off takes SPY's expiry week reading from +2.4 bp a day to -0.7, a
// swing of 3.03 on a band of 6.5. QQQ moves by 0.43 and IWM by 0.35, their
// distribution dates not sitting on the same day of the month. This script does
// not read the chart's adjustment setting; the description says what to check.
//
// The holiday calendar is computed rather than listed, Good Friday included, so
// there is no table in here with an expiry date on it. The rules were checked
// against an index fund's own trading days over 1993 to 2026: they call no day a
// holiday that the market traded, they catch all 34 Good Fridays in that window,
// and the 11 closed weekdays they miss are one-off closures that no weekday rule
// reaches. The computus itself agrees with an independent implementation on every
// year from 1900 to 2099.
//
// This needs a chart of real prices as well as a chart of one day a bar. On a
// Heikin Ashi, Renko, Kagi, Line Break, Point and Figure or Range chart the close
// is a value the chart builds rather than a price anything traded at, while every
// other test in here would pass, so that case is refused first and by name.
//
// Nothing here generates an entry, an exit or an alert, and no cost is deducted
// anywhere, so none of these figures is a result. They describe the return
// series of the symbol on the chart, conditioned on a date.

string tzNY = "America/New_York"

// Windows ---------------------------------------------------------------------
opexNth  = input.int(3, "Monthly expiry falls on which Friday of the month", minval = 2, maxval = 4, group = "Windows", tooltip = "US listed monthly options expire on the third Friday, which is the Friday whose day of month is 15 to 21. The whole Monday to Friday week around it is marked. Set it to 2 or 4 to see what an ordinary week of the month does by comparison. It starts at 2 because the week of a month's first Friday can begin in the previous month, which this arithmetic does not reach.")
domOpen  = input.int(26, "Turn of month opens on day of month", minval = 20, maxval = 29, group = "Windows", tooltip = "A round choice rather than a derived one. Nothing in this script argues it is the right number and the pane will show you what moving it does.")
tdClose  = input.int(4, "Turn of month closes after this many trading days of the new month", minval = 1, maxval = 8, group = "Windows")

// Reading ---------------------------------------------------------------------
selSel   = input.string("Turn of month", "Window drawn in the pane", options = ["Expiry week", "Turn of month", "Session before a holiday"], group = "Reading", tooltip = "All three appear in the table either way. This picks which one the lines draw.")
minRuns  = input.int(20, "Completed runs before a window reads", minval = 5, maxval = 200, group = "Reading", tooltip = "Applies to the window and to the ordinary day baseline separately, because the two fill up at different speeds.")
bandSE   = input.float(2.0, "Error band, standard errors", minval = 1.0, maxval = 4.0, step = 0.5, group = "Reading")

// Display ---------------------------------------------------------------------
showTable = input.bool(true, "Show readout", group = "Display")
showBand  = input.bool(true, "Shade the error band", group = "Display")
showTint  = input.bool(true, "Tint the pane inside the drawn window", group = "Display")

// The holiday that moves with Easter ------------------------------------------------------
// Good Friday follows Easter rather than the day of the month, so it is computed
// rather than listed. This is the anonymous Gregorian computus in the Meeus,
// Jones and Butcher form, which gives Easter Sunday; Good Friday is two days
// before it. Every division is written as int(math.floor(a / b)) rather than
// leaning on what an integer division operator would do, and the harness uses
// the same form. Every numerator here is non-negative over any year a chart can
// hold, so the floor and a truncation agree, and writing the floor out is the
// cheaper of the two ways to be sure.
//
// A list of dates was the first version of this and it was replaced: a list ends
// where the published calendar ends, and a permanently published script whose
// holiday table runs out would quietly stop classifying two months of every year
// after that. The computus was checked against the eleven dates that list held
// and against an independent implementation on every year from 1900 to 2099,
// with no disagreement, and the result is a Friday between March 21 and April 23
// in all 200 of them.
//
// Returns month * 100 + day.
f_goodFriMMDD(int _y) =>
    int _a  = _y % 19
    int _b  = int(math.floor(_y / 100.0))
    int _c  = _y % 100
    int _dd = int(math.floor(_b / 4.0))
    int _e  = _b % 4
    int _f  = int(math.floor((_b + 8) / 25.0))
    int _g  = int(math.floor((_b - _f + 1) / 3.0))
    int _h  = (19 * _a + _b - _dd - _g + 15) % 30
    int _i  = int(math.floor(_c / 4.0))
    int _k  = _c % 4
    int _l  = (32 + 2 * _e + 2 * _i - _h - _k) % 7
    int _mm = int(math.floor((_a + 11 * _h + 22 * _l) / 451.0))
    int _n  = _h + _l - 7 * _mm + 114
    int _em = int(math.floor(_n / 31.0))
    int _ed = _n % 31 + 1
    int _gm = _em
    int _gd = _ed - 2
    if _gd < 1
        _gm := 3
        _gd := _gd + 31
    _gm * 100 + _gd

// Is a given calendar date a US market holiday. Everything except Good Friday is
// a weekday-of-month rule plus the observed-day shifts for the fixed dates. Two
// of them carry a start year: Juneteenth from 2022, and the third Monday of
// January from 1998. The second of those was put in after the rules were checked
// against thirty three years of an index fund's own trading days, which showed
// the exchange open on that Monday in 1994, 1995, 1996 and 1997 and shut on it
// from 1998 on. March and April hand off to the computus above.
f_isHol(int _y, int _m, int _d) =>
    int  _dow = dayofweek(timestamp(tzNY, _y, _m, _d, 12, 0), tzNY)
    bool _mon = _dow == dayofweek.monday
    bool _fri = _dow == dayofweek.friday
    bool _thu = _dow == dayofweek.thursday
    bool _wd  = _dow >= dayofweek.monday and _dow <= dayofweek.friday
    bool _hol = false
    if _m == 1
        _hol := (_d == 1 and _wd) or (_d == 2 and _mon) or (_y >= 1998 and _d >= 15 and _d <= 21 and _mon)
    else if _m == 2
        _hol := _d >= 15 and _d <= 21 and _mon
    else if _m == 3 or _m == 4
        _hol := f_goodFriMMDD(_y) == _m * 100 + _d
    else if _m == 5
        _hol := _d >= 25 and _d <= 31 and _mon
    else if _m == 6
        _hol := _y >= 2022 and ((_d == 19 and _wd) or (_d == 18 and _fri) or (_d == 20 and _mon))
    else if _m == 7
        _hol := (_d == 4 and _wd) or (_d == 3 and _fri) or (_d == 5 and _mon)
    else if _m == 9
        _hol := _d >= 1 and _d <= 7 and _mon
    else if _m == 11
        _hol := _d >= 22 and _d <= 28 and _thu
    else if _m == 12
        _hol := (_d == 25 and _wd) or (_d == 24 and _fri) or (_d == 26 and _mon)
    _hol

// Look forward from this bar's close to the first day that is not a weekend. If
// that day is a holiday, this bar is the session before one. The scan runs on
// calendar dates rather than on the presence or absence of a bar, because a
// contract for difference on an index often prints a short bar on a day the
// underlying market is shut, and absence of a bar is then not evidence of
// anything.
f_preScan() =>
    bool _pre     = false
    bool _decided = false
    for _k = 1 to 4
        if not _decided
            int _ts = time_close + _k * 86400000
            int _dw = dayofweek(_ts, tzNY)
            if _dw != dayofweek.saturday and _dw != dayofweek.sunday
                _pre     := f_isHol(year(_ts, tzNY), month(_ts, tzNY), dayofmonth(_ts, tzNY))
                _decided := true
    _pre

// Calendar position of this bar ------------------------------------------------
// Every date here is read off time_close in exchange time. A daily bar's opening
// timestamp can sit on the previous calendar day depending on how the feed
// stamps it, which turns a Friday rule into one that matches far fewer bars than
// it should and does so with no error of any kind. So this reads the close rather
// than the open, which is the timestamp that sits inside the session on the feeds
// this was built against, and it survives the hour a daylight saving change moves
// an afternoon or evening close by.
//
// That is an assumption, not a checked fact, and it is the one the whole file
// rests on. A feed that stamped a daily bar's close at midnight of the following
// day would shift all three rules by a day and print entirely plausible numbers
// while doing it. The way to check it on a chart is to open a known monthly
// expiry Friday and confirm the readout marks that bar and the four before it,
// which is first on the manual list in the notes that accompany this file.
int  dwCur  = dayofweek(time_close, tzNY)
int  domCur = dayofmonth(time_close, tzNY)
int  monCur = month(time_close, tzNY)
int  yrCur  = year(time_close, tzNY)

bool curWd  = dwCur >= dayofweek.monday and dwCur <= dayofweek.friday
bool curHol = f_isHol(yrCur, monCur, domCur)
bool curTrad = curWd and not curHol

bool preRaw = f_preScan()

// Expiry week. The nth Friday of a month is the Friday whose day of month lies
// in 7n-6 to 7n, so the third is 15 to 21. Projecting this bar forward to the
// Friday of its own week turns that into a test for the whole week: a Monday
// four days before a Friday dated 15 to 21 is in the same week as it.
//
// The projection adds days to a day of month and does not roll into the previous
// month, which is why the input starts at 2. A week containing a Friday dated 8
// or later begins on a Monday dated 4 or later and so begins in the same month,
// and the arithmetic is then exact; it was checked that way against a direct nth
// Friday computation over every weekday from 1993 to 2026, at n of 2, 3 and 4,
// with no disagreement. At n of 1 the week's Monday can sit in the month before,
// where a projected day of month of 32 to 35 falls outside 1 to 7 and the early
// part of the week goes unmarked. That case is out of range rather than
// half-right: 582 of the 2040 weekdays in those weeks would be missed.
int  opexLo  = 7 * opexNth - 6
int  opexHi  = 7 * opexNth
int  friDom  = domCur + (dayofweek.friday - dwCur)
bool inExpiry = curWd and friDom >= opexLo and friDom <= opexHi

// Turn of the month. The month's trading days are counted as they arrive, which
// is how the far edge is placed without needing to know in advance which days
// the market will be open. Holiday bars on a contract for difference
// chart do not advance the counter, so the far edge lands on the same session on
// such a chart as it does on an equity one.
bool newMonth = bar_index > 0 and (monCur != month(time_close[1], tzNY) or yrCur != year(time_close[1], tzNY))
var bool monthSeen = false
var int  tdCount   = 0
if newMonth
    tdCount   := 0
    monthSeen := true
if curTrad
    tdCount += 1
bool inTurn = curTrad and (domCur >= domOpen or (tdCount >= 1 and tdCount <= tdClose))

// Session before a holiday.
bool inPreHol = curTrad and preRaw

// A bar is classified when every one of the three rules can be settled on it.
// That needs a chart whose bars are real prices, one day a bar, an exchange that
// keeps a Monday to Friday week, a month boundary already seen so the trading
// day counter is not counting from the middle of a month, and a session the
// market was open for. A bar that fails the last two is set aside: it ends no
// run, it enters no average of its own, and it is counted and reported. Its close
// is still the previous close the next bar's return is measured from, so the
// session after a set-aside bar is measured from that bar rather than from the
// last session before it. On a chart that prints no such bar this is moot; on one
// that does, it is the reason the set-aside count is worth reading.
//
// The first of those is the quiet one. On a Heikin Ashi, Renko, Kagi, Line
// Break, Point and Figure or Range chart, close is a value the chart constructs
// rather than a price anything traded at, while every other test here passes and
// the status would read ok. Every average in the file would then be an average
// of constructed values rather than of traded prices.
bool stdOk    = chart.is_standard
bool tfOk     = timeframe.isdaily and timeframe.multiplier == 1 and not timeframe.isseconds and not timeframe.isticks
bool isCrypto = syminfo.type == "crypto"
bool wkndBar  = dwCur == dayofweek.saturday or dwCur == dayofweek.sunday
var bool wkndSeen = false
if wkndBar
    wkndSeen := true
bool dataOk = not isCrypto and not wkndSeen
bool dispOk = stdOk and tfOk and dataOk

bool classOk = dispOk and monthSeen and curTrad

// The return attached to a bar is the close to close move ending on it, in basis
// points of log return. A log return is used so that the average of a window's
// days and the average of the days around it are on one additive scale.
bool  hasRet = bar_index > 0 and not na(close[1]) and close > 0.0 and close[1] > 0.0
float retBp  = hasRet ? math.log(close / close[1]) * 10000.0 : na
bool  useBar = classOk and hasRet

// Ledgers ----------------------------------------------------------------------
// Four buckets in one set of arrays, indexed 0 expiry week, 1 turn of month,
// 2 session before a holiday, 3 ordinary day. The fourth is the complement of
// the other three taken together and is what every difference is measured
// against.
//
// Two ledgers per bucket. The day ledger is a running count, sum and sum of
// squares of the returns, which gives the mean and the spread of the days
// themselves. The run ledger holds one figure per completed run of consecutive
// days in the bucket, which is what the error band is built from, because the
// days inside a run are one episode of the calendar and not five independent
// draws from it.
var array<float> nDay  = array.new_float(4, 0.0)
var array<float> sumR  = array.new_float(4, 0.0)
var array<float> sumR2 = array.new_float(4, 0.0)

var array<bool>  runOn    = array.new_bool(4, false)
var array<bool>  runKeep  = array.new_bool(4, false)
var array<bool>  runReady = array.new_bool(4, false)
var array<float> runN     = array.new_float(4, 0.0)
var array<float> runSum   = array.new_float(4, 0.0)

var array<float> epCnt  = array.new_float(4, 0.0)
var array<float> epMSum = array.new_float(4, 0.0)
var array<float> epMSq  = array.new_float(4, 0.0)
var array<float> epLSum = array.new_float(4, 0.0)
var array<float> epLMax = array.new_float(4, 0.0)
var array<float> epLMin = array.new_float(4, 0.0)

var float nClass   = 0.0
var float nAside   = 0.0
var float nAsideNs = 0.0
var float ovlExPre = 0.0
var float ovlTuPre = 0.0
var float ovlExTu  = 0.0

bool inNone = not inExpiry and not inTurn and not inPreHol

if useBar
    nClass += 1.0
    if inExpiry and inPreHol
        ovlExPre += 1.0
    if inTurn and inPreHol
        ovlTuPre += 1.0
    if inExpiry and inTurn
        ovlExTu += 1.0
    for i = 0 to 3
        bool fl = i == 0 ? inExpiry : i == 1 ? inTurn : i == 2 ? inPreHol : inNone
        if fl
            array.set(nDay,  i, array.get(nDay,  i) + 1.0)
            array.set(sumR,  i, array.get(sumR,  i) + retBp)
            array.set(sumR2, i, array.get(sumR2, i) + retBp * retBp)
            if array.get(runOn, i)
                array.set(runN,   i, array.get(runN,   i) + 1.0)
                array.set(runSum, i, array.get(runSum, i) + retBp)
            else
                array.set(runOn,   i, true)
                array.set(runKeep, i, array.get(runReady, i))
                array.set(runN,    i, 1.0)
                array.set(runSum,  i, retBp)
        else
            // The run that is already open on the chart's first classified bar
            // started before the history did, so its length is whatever the
            // chart happens to begin at. It is dropped rather than ledgered, and
            // runKeep is what remembers that. The run still open on the last bar
            // is not ledgered either; its days are in the day ledger and its
            // length is not yet a number.
            if array.get(runOn, i)
                if array.get(runKeep, i)
                    float ln = array.get(runN, i)
                    float mn = array.get(runSum, i) / ln
                    array.set(epCnt,  i, array.get(epCnt,  i) + 1.0)
                    array.set(epMSum, i, array.get(epMSum, i) + mn)
                    array.set(epMSq,  i, array.get(epMSq,  i) + mn * mn)
                    array.set(epLSum, i, array.get(epLSum, i) + ln)
                    array.set(epLMax, i, math.max(array.get(epLMax, i), ln))
                    float mnl = array.get(epLMin, i)
                    array.set(epLMin, i, mnl == 0.0 ? ln : math.min(mnl, ln))
                array.set(runOn, i, false)
            array.set(runReady, i, true)

// A bar the chart can show but the rules cannot settle, split by which rule gave
// up. The first count is the one that rises on a contract for difference chart,
// where the feed prints a bar on a day the underlying market was shut.
if dispOk and hasRet and not classOk
    nAside += 1.0
    if monthSeen and not curTrad
        nAsideNs += 1.0

// Statistics -------------------------------------------------------------------
// Sample variances from running sums. The subtraction can land a hair below zero
// on a bucket whose returns are all but identical, so it is floored rather than
// left to produce a negative variance and a na square root.
f_mean(int _i) =>
    float _n = array.get(nDay, _i)
    float _m = na
    if _n > 0.0
        _m := array.get(sumR, _i) / _n
    _m

f_var(int _i) =>
    float _n = array.get(nDay, _i)
    float _v = na
    if _n > 1.0
        float _s = array.get(sumR, _i)
        _v := math.max((array.get(sumR2, _i) - _s * _s / _n) / (_n - 1.0), 0.0)
    _v

f_epMean(int _i) =>
    float _c = array.get(epCnt, _i)
    float _m = na
    if _c > 0.0
        _m := array.get(epMSum, _i) / _c
    _m

f_epVar(int _i) =>
    float _c = array.get(epCnt, _i)
    float _v = na
    if _c > 1.0
        float _s = array.get(epMSum, _i)
        _v := math.max((array.get(epMSq, _i) - _s * _s / _c) / (_c - 1.0), 0.0)
    _v

int selIdx = selSel == "Expiry week" ? 0 : selSel == "Turn of month" ? 1 : 2
string selName = selSel == "Expiry week" ? "expiry week" : selSel == "Turn of month" ? "turn of month" : "pre-holiday"

float baseMean = f_mean(3)
float baseVar  = f_var(3)
float baseN    = array.get(nDay, 3)
float baseEpV  = f_epVar(3)
float baseEpC  = array.get(epCnt, 3)

// The difference and its two error bars. The naive one treats every day as its
// own observation. The clustered one treats a run of consecutive days in the
// window as one observation carrying that run's average day, which is the
// figure the band is drawn from. The two point estimates are also kept apart:
// pooling days weights a long run more than a short one, averaging run averages
// weights them alike, and on unequal run lengths those are not the same number.
f_diff(int _i) =>
    float _mi = f_mean(_i)
    float _d  = na
    if not na(_mi) and not na(baseMean)
        _d := _mi - baseMean
    _d

f_seNaive(int _i) =>
    float _vi = f_var(_i)
    float _ni = array.get(nDay, _i)
    float _se = na
    if not na(_vi) and not na(baseVar) and _ni > 0.0 and baseN > 0.0
        _se := math.sqrt(_vi / _ni + baseVar / baseN)
    _se

f_seClust(int _i) =>
    float _vi = f_epVar(_i)
    float _ci = array.get(epCnt, _i)
    float _se = na
    if not na(_vi) and not na(baseEpV) and _ci > 0.0 and baseEpC > 0.0
        _se := math.sqrt(_vi / _ci + baseEpV / baseEpC)
    _se

f_epDiff(int _i) =>
    float _mi = f_epMean(_i)
    float _bm = f_epMean(3)
    float _d  = na
    if not na(_mi) and not na(_bm)
        _d := _mi - _bm
    _d

f_volRatio(int _i) =>
    float _vi = f_var(_i)
    float _r  = na
    if not na(_vi) and not na(baseVar) and baseVar > 0.0
        _r := math.sqrt(_vi) / math.sqrt(baseVar)
    _r

f_ready(int _i) =>
    array.get(epCnt, _i) >= minRuns and baseEpC >= minRuns

bool  selReady  = f_ready(selIdx)
bool  baseReady = baseEpC >= minRuns
float selDiff   = f_diff(selIdx)
float selSE     = f_seClust(selIdx)

float pDiff = dispOk and selReady and not na(selDiff) ? selDiff : na
float pHi   = dispOk and selReady and not na(selSE) ? bandSE * selSE : na
float pLo   = dispOk and selReady and not na(selSE) ? -bandSE * selSE : na

bool selIn = selIdx == 0 ? inExpiry : selIdx == 1 ? inTurn : inPreHol

// Status ------------------------------------------------------------------------
// Every reason there is no reading gets said out loud, and the two that are
// properties of the chart rather than of the warmup are tested first, because
// waiting out a warmup to be told the chart was the wrong kind the whole time is
// not a status line.
string statusText = not stdOk ? "needs a standard chart, this one is built from synthetic prices" : not tfOk ? "needs a one day chart" : isCrypto ? "this symbol trades every day, these calendar rules are for a Monday to Friday exchange" : wkndSeen ? "this chart has bars at weekends, these calendar rules are for a Monday to Friday exchange" : not monthSeen ? "warming up, waiting for the first month boundary" : not curTrad ? "not a session under these calendar rules, this bar is set aside" : not baseReady ? "warming up, the ordinary day ledger holds " + str.tostring(baseEpC, "0") + " of " + str.tostring(minRuns) + " completed runs" : not selReady ? "warming up, the " + selName + " ledger holds " + str.tostring(array.get(epCnt, selIdx), "0") + " of " + str.tostring(minRuns) + " completed runs" : "ok"

// Pane ---------------------------------------------------------------------------
color diffCol = color.orange
color bandCol = color.gray

hline(0.0, "No difference", color = color.new(color.gray, 60), linestyle = hline.style_dotted)

plot(pDiff, "Difference against ordinary days, bp a day", color.new(diffCol, 0), 2)
bHi = plot(showBand ? pHi : na, "Error band, upper", color.new(bandCol, 40), 1)
bLo = plot(showBand ? pLo : na, "Error band, lower", color.new(bandCol, 40), 1)
fill(bHi, bLo, showBand ? color.new(bandCol, 88) : na)

bgcolor(showTint and dispOk and selIn and classOk ? color.new(diffCol, 90) : na, title = "Inside the drawn window")

plot(dispOk ? (selIn and classOk ? 1.0 : 0.0) : na, "Inside the drawn window and counted", display = display.data_window)
plot(dispOk ? array.get(nDay, selIdx) : na, "Days in the drawn window", display = display.data_window)
plot(dispOk ? array.get(epCnt, selIdx) : na, "Completed runs, drawn window", display = display.data_window)
plot(dispOk ? f_mean(selIdx) : na, "Mean in the drawn window, bp", display = display.data_window)
plot(dispOk ? baseMean : na, "Mean on ordinary days, bp", display = display.data_window)
plot(dispOk ? f_seNaive(selIdx) : na, "Standard error per day, bp", display = display.data_window)
plot(dispOk ? f_seClust(selIdx) : na, "Standard error per run, bp", display = display.data_window)
plot(dispOk and selReady and not na(selSE) and selSE > 0.0 ? selDiff / selSE : na, "Difference over its standard error", display = display.data_window)
plot(dispOk ? f_volRatio(selIdx) : na, "Spread ratio, window over ordinary", display = display.data_window)
plot(dispOk ? f_epDiff(selIdx) : na, "Difference weighting runs alike, bp", display = display.data_window)
plot(dispOk and array.get(epCnt, selIdx) > 0.0 ? array.get(epLSum, selIdx) / array.get(epCnt, selIdx) : na, "Mean run length, drawn window", display = display.data_window)
plot(dispOk and array.get(epCnt, selIdx) > 0.0 ? array.get(epLMin, selIdx) : na, "Shortest completed run, drawn window", display = display.data_window)
plot(dispOk and array.get(epCnt, selIdx) > 0.0 ? array.get(epLMax, selIdx) : na, "Longest completed run, drawn window", display = display.data_window)
plot(dispOk ? nClass : na, "Days classified", display = display.data_window)
plot(dispOk ? nAside : na, "Days set aside", display = display.data_window)

// Table ---------------------------------------------------------------------------
// The left column is eight fixed labels plus a status label and they stay put on
// a refused chart. Every cell in the right column goes to a dash there, which is
// what refusing looks like: no number, not a plausible one.
f_rowTxt(int _i) =>
    string _t = "-"
    if not f_ready(_i)
        _t := "warming up, " + str.tostring(array.get(epCnt, _i), "0") + " of " + str.tostring(minRuns) + " runs"
    else
        float _d = f_diff(_i)
        float _s = f_seClust(_i)
        _t := (_d >= 0.0 ? "+" : "") + str.tostring(_d, "0.0") + " bp a day, band " + str.tostring(bandSE * _s, "0.0") + ", " + str.tostring(array.get(nDay, _i), "0") + " days in " + str.tostring(array.get(epCnt, _i), "0") + " runs"
    _t

string todayTxt = ""
if not classOk
    todayTxt := "set aside"
else if inNone
    todayTxt := "ordinary day"
else
    todayTxt := (inExpiry ? "expiry week" : "") + (inExpiry and (inTurn or inPreHol) ? ", " : "") + (inTurn ? "turn of month" : "") + (inTurn and inPreHol ? ", " : "") + (inPreHol ? "before a holiday" : "")

string baseTxt = "-"
if array.get(epCnt, 3) > 0.0 and not na(baseMean)
    baseTxt := (baseMean >= 0.0 ? "+" : "") + str.tostring(baseMean, "0.0") + " bp a day, " + str.tostring(baseN, "0") + " days in " + str.tostring(baseEpC, "0") + " runs"

string ovlTxt = "expiry and holiday " + str.tostring(ovlExPre, "0") + ", turn and holiday " + str.tostring(ovlTuPre, "0") + ", expiry and turn " + str.tostring(ovlExTu, "0")
string asideTxt = str.tostring(nAside, "0") + " days, " + str.tostring(nAsideNs, "0") + " of them on a day the market was shut"
string overTxt = str.tostring(nClass, "0") + " daily returns"
string basisTxt = "close to close log returns, no costs deducted"

if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 10, border_width = 1)
    table.cell(t, 0, 0, "Today", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, dispOk ? todayTxt : "-", text_color = color.white, text_size = size.small)
    table.cell(t, 0, 1, "Expiry week", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, dispOk ? f_rowTxt(0) : "-", text_color = color.white, bgcolor = selIdx == 0 ? color.new(diffCol, 80) : na, text_size = size.small)
    table.cell(t, 0, 2, "Turn of month", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, dispOk ? f_rowTxt(1) : "-", text_color = color.white, bgcolor = selIdx == 1 ? color.new(diffCol, 80) : na, text_size = size.small)
    table.cell(t, 0, 3, "Before a holiday", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, dispOk ? f_rowTxt(2) : "-", text_color = color.white, bgcolor = selIdx == 2 ? color.new(diffCol, 80) : na, text_size = size.small)
    table.cell(t, 0, 4, "Ordinary days", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 4, dispOk ? baseTxt : "-", text_color = color.white, text_size = size.small)
    table.cell(t, 0, 5, "Days in two windows", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 5, dispOk ? ovlTxt : "-", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 6, "Set aside", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 6, dispOk ? asideTxt : "-", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 7, "Measured over", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 7, dispOk ? overTxt : "-", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 8, "Basis", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 8, dispOk ? basisTxt : "-", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 9, "Status", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 9, statusText, text_color = statusText == "ok" ? color.gray : color.orange, text_size = size.small)
````
