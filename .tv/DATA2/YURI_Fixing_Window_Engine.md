<!-- tradingview-pine-id: PUB;13e8dddce3d04e53ba558491150b5cdf -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# YURI Fixing Window Engine

Source: https://www.tradingview.com/script/a4hnFk6j/

## Description

Two things happen on an FX chart at a fixed hour of the local clock, and neither is a reading taken off price. A benchmark rate is struck, and on certain calendar dates a Japanese settlement convention decides who has to be finished by then. This marks where those windows sit on the chart, says whether today is one of those dates, and keeps a day by day record of what price did across the window on the days that have already finished. It prints that record as medians, as shares, and with the number of days behind each figure, because the number of days is what decides whether any of it means anything.

HOW TO USE IT

Put it on an intraday forex chart of sixty minute bars or finer. The Tokyo window needs a pair with a JPY leg; the London window accepts any forex pair. Anything else is refused by name in the status line. Choose the window with Fixing window.

Scroll back before reading anything. The record is built from the days the chart has loaded, and the count of days printed beside every figure is the first thing to look at. How many days that is depends on the bar length and on how many bars your plan serves: the fifteen minute chart this was checked on loaded about 120 days, and a five minute chart holds fewer.

On price, the shaded bands show where the window sits each day: the interval before the fix, the bar carrying it, and the interval after. Orange is a settlement date, blue is any other date.

In the table, Settlement calendar says whether today is a settlement date and which rule made it one. Today gives the two moves for the current day as they arrive, the run into the fix and the move after it. The four rows under that are the record, split into settlement dates and other dates: the median move, the share of days it went up or went the other way from the run up, the error on that share, and the number of days behind it. Compare a settlement row with the row for other dates, and compare the gap between them with the errors printed beside both.

On a weekend or a holiday the top rows say there is no trading date and the record rows still read.

Minutes before the fix and Minutes after the fix move the two intervals. Changing either one rebuilds the record on the new definition.

WHAT THE CALENDAR IS

The convention is the one usually called gotobi. Japanese settlement clusters on the 5th, the 10th, the 15th, the 20th, the 25th and the last day of the month, and the account usually given of it is that an importer settling on one of those dates has to have bought its currency by the reference rate that morning. That account is what the record below lets a reader check rather than something this script establishes.

Two things follow that this script has to say out loud. First, it holds no holiday table, so it carries the weekend half of the rule only: a settlement date that lands on a Saturday or a Sunday flags the Friday before it, and a date that lands on a Japanese bank holiday is flagged on the holiday itself rather than on the business day the convention would move it to. The table names which rule produced today's flag, and the roll is an input so a reader can see the calendar with and without it. Over 2024 and 2025 the plain dates give 115 flags and the weekend roll adds 39 more.

Second, the flag is evaluated on the calendar date of the fixing window's own city. The Tokyo window reads a Tokyo date, the London window a London date. Both are the same nominal date; they are simply two different instants.

The calendar was checked against an independent implementation written from the calendar rather than from this code, on every date from 2000-01-01 to 2035-12-31, in both timezones, at five different local hours per date, with the roll rule on and off. That is 262980 comparisons and no disagreement. Leap day, the 28th of a short February, month ends that fall on a multiple of five and month ends that do not, year end, and the Friday that absorbs both a Saturday the 30th and a Sunday the 31st are each pinned as their own case. Across those thirty six years the flag lands on 29.5 percent of weekdays, which is about six and a half dates a month.

WHICH BAR CARRIES THE FIX

The fix is an instant and a chart is made of bars, so the script takes the first bar of the day whose close falls at or after the fix minute and within one bar length of it. On a five minute chart of the Tokyo window that bar closes exactly at 09:55 and the offset is zero. On an hourly chart the nearest close is 10:00 and the offset is five minutes, which the table prints. The London fix sits on the hour, so an hourly bar closes on it exactly.

The same rule sets the two ends of the measurement. The near end is the last close at or before the requested number of minutes ahead of the fix; the far end is the first close at or after the requested number of minutes past it. On a chart whose bars do not land on those minutes the interval that gets measured is longer than the one asked for, so the table prints both. At the default 45 and 90 minutes, a five minute chart measures exactly 45 and 90, and an hourly chart measures 60 and 120.

A day whose bars miss the fix minute by more than one bar length, or whose ends fall outside that tolerance, is counted out by name instead of being pooled with the rest, and the table shows how many days that has happened to. The alternative is a record quietly containing days whose windows were a different length from the ones it claims.

Daylight saving is handled by naming the timezone rather than by an offset. On real hourly bars from 2023-12 to 2026-09 the London fix bar sits at two different UTC hours across the window and at one single London local time; the Tokyo fix bar sits at one UTC hour throughout, Tokyo having no clock change. The calendar arithmetic is anchored near local noon for the same reason: adding twenty four hours to a bar close lands on the next date at every hour except the one or two either side of a clock change, and a test over thirty six years of every London calendar date at four local hours finds ten date-and-hour combinations where the unanchored form returns the wrong calendar date, every one of them at the March clock change; the October change is inside the tested range and moved no flag there.

WHAT THE RECORD KEEPS

For each finished day the script stores two numbers in basis points. The run up is the move from the near end of the window to the close of the bar carrying the fix. The second number is the move from that bar to the far end. On the Tokyo window it keeps those for the flagged dates and for every other date separately; on the London window every date goes into one record, because a Japanese settlement date is not a claim about who trades a London benchmark.

For each group the readout is the median of both numbers, the share of days the run up was positive, the share of days the second move went the other way from the run up, and the count of days behind them. A day counts as going the other way when one move is up and the other is down; an exact zero on either side is counted as neither, which is why that share and the share of positive run ups are not two views of one count. Every share carries a binomial standard error. The days do not overlap, so the count is a real sample size rather than a bar count, but the days do cluster by month and by regime, and a record of two years is two years of one currency pair.

The reference before the window and the close of the bar carrying the fix are read off price as it stands, so on the bar that is forming they move as it forms and settle when it closes, and once a bar has closed its reading is not rewritten afterwards. Today's row therefore shows a run up while the fix bar is still forming, at a figure that moves until that bar closes. The record is held to a stricter rule: a day joins it on the close of its far-side bar and not while that bar is forming, so the medians, the shares and the counts move only on closed bars. Without that rule the day would join on the far-side bar's first tick, since a forming bar already reports the close time it is scheduled to have.

The cap on the record is shared between the two groups rather than applied to each. When it fills, the oldest day leaves whichever group held it, so the two groups cover the same stretch of chart. Capping each group on its own would let the larger one fill first and start reporting a shorter span than the other, and the two medians printed side by side would then be measurements of different years.

MEASURED

All of the following are from a transcription of this script run over real bars, not from a strategy and not from a chart. USDJPY hourly from 2023-12-04 to 2026-09-18, the Tokyo window at default settings: 665 days produced a window and 60 were counted out, and the 500 day record holds 154 flagged dates and 346 others. That record is what a chart reaches once it has loaded about two years of hourly bars; on a chart that has loaded less, the counts and the medians are smaller and different, which is the record filling rather than the script disagreeing with itself. All three groups quoted here hold an even number of days, so each median is the average of its two middle readings, and a chart that returns one of the two instead can print a different last digit.

On the flagged dates the median run up was minus 1.04 basis points and it was positive on 44.8 percent of them, with a standard error of 4 points. On the other dates the median was plus 1.09 and it was positive on 52.9 percent, standard error 3. The difference between the two, 8.1 points, is 1.67 standard errors of itself. The second move opposed the run up on 53.2 percent of flagged dates and 51.7 percent of the others.

Two controls say what that 8.1 points is worth, and they are the reason this section exists. Run the identical measurement on the identical dates at a fix time six hours earlier and the same split comes out at plus 5.2 points; six hours later, minus 1.4. A split of that size therefore appears at hours where no fix is struck, which is what a difference inside the noise looks like. And the pair drifted 7.0 percent over the window, which puts 51.3 percent of every sixty minute interval in that tape on the positive side and 51.8 percent of every hundred and twenty minute one. Both shares above have to be read against those numbers rather than against fifty.

On the London window over the same bars the pooled record of 500 days has a median run up of plus 1.50 basis points, positive on 54.8 percent with a standard error of 2.2, which the table cell rounds to 55. Against the 51.3 percent drift baseline that is 3.5 points, about one and a half standard errors.

A five minute chart reaches back far less. Over bars from 2026-06-28 to 2026-09-18, the first of which is a Sunday and carries no record, the Tokyo window produced 60 days, 19 of them flagged, with the window measured at exactly 45 and 90 minutes and no day counted out. Nineteen days is not a sample and is quoted here to show what a fine grained chart actually gives you, which is precision on the window and almost nothing on the count.

WHY THIS IS NOT A SHADED BOX WITH A DATE ON IT

Put as what the script computes and keeps. It resolves a settlement convention into a per date flag, including the roll, on the fixing window's own calendar. It resolves an instant on a local clock into a specific bar on whatever chart is loaded, reports how far that bar sits from the instant, and refuses the day when the distance is more than a bar. And it accumulates, day by day and bar by bar as the chart runs, the displacement across that window on each side of the fix, in a record whose two halves are kept on a shared cap so that they describe the same stretch of chart.

That record is the part that could not be read off a static drawing. The medians and shares exist only because something has been keeping a day by day ledger while the chart ran, and the count printed beside them is what turns the folk version of this calendar into something a reader can check rather than repeat.

The claim itself is not original and is not presented as such. The gotobi effect has been discussed for a long time and the version this script measures is that discussion's own quantity. What is here is the measurement and its sample size.

READING IT

Shading on price: a light band over the interval before the fix, a stronger one on the bar that carries it, and a fainter one after it. Orange on a settlement date, blue on any other date, so the calendar is visible without reading the table. Both outer edges are the requested interval widened by one bar, which is what makes the shading reach the two bars the measurement was actually taken from on a chart whose bars do not land on those minutes. The coarser the chart the fewer bars each band covers: at the default 45 minutes the band before the fix is nine bars on a five minute chart, three or four on a fifteen depending on which window is selected, two on a thirty and a single bar on an hourly one. The Tokyo window gives four on a fifteen minute chart and the London window three, because 09:55 and 16:00 sit differently against a fifteen minute grid.

The table carries the window and its clock, the date on that clock, whether the date is a settlement date and whether the roll rule is what made it one, how far the fix bar closed from the fix, the intervals asked for against the intervals measured, today's two numbers as they arrive, then four rows of the record, then the split setting with the count of days counted out, then a status line.

The data window carries the day's run up and second move in basis points, the two measured intervals, the flag as a one or a zero, the size of each group and the number of days counted out.

The status line names every reason there is no reading rather than printing a plausible number in its place. There are seven messages besides ok, in the order they are tested. That the chart is not a standard one, which is tested first and is explained below. That the chart is not intraday. That it is measured in seconds or in ticks. That its bars are longer than sixty minutes. That the symbol is not forex. That the Tokyo window has been put on a pair with no JPY leg. And that no window has finished yet on this chart. The six chart and symbol messages are tested ahead of the warmup one on purpose, because a chart that can produce no reading at all should say so on the first bar.

On a refused chart nothing else speaks. All eight data window rows are empty, all eleven value cells read as a dash, no band is drawn and nothing is recorded. That was checked by enumerating every one of them on each of the seven refusals rather than by looking at two of them.

SETTINGS THAT MATTER

The minutes before and after the fix decide what is being measured, and the interval that gets measured is the one the table reports rather than the one requested. The first of the two also decides which days survive, which is easy to miss on a calendar study. The FX week opens on a Monday morning in Tokyo, so a Monday can lack a close far enough ahead of the fix: on the hourly tape measured above the record holds 84 Mondays at the default 45 minutes against about 145 of every other weekday, and at 60 minutes and beyond it holds none, leaving a Tuesday to Friday record. Nothing disappears, since the days that leave go to the counted out tally and the two add to 725 at every setting, but the mix of weekdays changes and the table does not show it. On a coarse chart there are also narrow values that leave no day at all: on the same hourly tape any setting from 56 to 59 minutes puts the reference on a bar 120 minutes out while the tolerance allows 119, so every day fails the span test and the record stays empty. The status line then reads that no window has finished yet, which looks like warmup rather than an incompatible setting, so the counted out tally is the number to read when a record refuses to fill. Both are capped at 240 so that neither end of the widest window can cross local midnight on either clock, which would put the two ends of a measurement on different calendar dates.

The weekend roll changes which dates are flagged and therefore both groups at once. Turning it off is the way to see how much of the flagged set is the rule rather than the raw dates.

The record size decides how far back the medians reach, which matters more than how many days they hold. Five hundred weekdays is about two years.

WHAT IT WILL NOT DO

It generates no entries, no exits and no alerts. There is no direction in it, no threshold that turns any of these numbers into a condition, and no filter, because a filter bolted onto a readout makes the readout look like it answered a question it cannot answer.

It is not evidence that the calendar does anything. The measurements above are one pair over one window, and the split at the real fix hour is the size of the split at an hour where nothing is fixed. The two controls answer different questions and neither substitutes for the other: the placebo hour is what the difference between the two groups has to be read against, and the drift is what each group's own level has to be read against. A reader who loads a different pair or a different stretch should expect different numbers and should read them against both.

The shares are frequencies, not probabilities. At a hundred days a share carries a standard error of five points, at four hundred two and a half, and a share sitting ten points from a coin toss at a hundred days is two of those. The table prints the count next to every share so that division is available without doing arithmetic off the chart.

The record is right censored at both ends. Today's window is not in it until the far end has closed, and the count of days counted out runs over all the history the chart has loaded while the record itself stops at its cap, so the two are not a ratio.

It needs a standard intraday forex chart of sixty minutes or less, and the Tokyo window needs a pair with a JPY leg. Charts measured in seconds or in ticks, daily and higher charts, non forex symbols and JPY free pairs on the Tokyo window are each refused by name and produce no numbers at all.

The chart type is tested first and is the refusal worth explaining. On a Heikin Ashi, Renko, Kagi, Line break, Point and figure or Range chart the price series is constructed by the chart rather than dealt in the market, so every other test here still passes while every basis point would be measured off a price nobody traded. Those chart types are refused by name for that reason, and the readout stays blank on them.

The forex test reads how the data source classifies the symbol rather than what the symbol is, and sources differ. A feed that files the same pair under another class is refused by name, so if a major pair reads as not forex, the thing to try is the same pair from another source before concluding the script is broken. The gotobi calendar is a Japanese settlement convention, so the symbol it has anything to say about is USDJPY first and other JPY crosses after that; on EURUSD the London window still measures a real benchmark, and the settlement flag is a date rather than a claim.

Bars are what the feed supplies. A pair with holes around the fix hour loses those days to the counted out tally, and different brokers' FX feeds do not carry identical bars, so two charts of the same pair can produce slightly different medians.

This is context for a decision, not the decision.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © evawpd141

//@version=6
indicator("YURI Fixing Window Engine", "YURI FWE", overlay = true)

// Two things happen on an FX chart at a fixed hour of the local clock, and both
// are calendar facts rather than readings taken off price: a benchmark rate is
// struck, and on certain dates a settlement convention concentrates who has to
// be done by then. This marks where those windows sit, says whether today is one
// of the dates, and keeps a record of what price did across the window on the
// days that have already finished.
//
// Two windows are offered and one is drawn at a time:
//
//   Tokyo      the 09:55 Asia/Tokyo mid rate, the reference at which Japanese
//              banks quote the day's customer rate for JPY.
//   London     the 16:00 Europe/London benchmark fix.
//
// The dates are the Japanese settlement convention usually called gotobi: the
// 5th, 10th, 15th, 20th, 25th and the last day of the month. This script holds
// no holiday table. It carries the weekend part of the rule only, moving a
// settlement date that lands on a Saturday or a Sunday back to the Friday
// before it, and a date that lands on a Japanese bank holiday is flagged on the
// holiday itself rather than on the business day the convention would move it
// to. Every such date is named in the table so a reader can see which rule
// produced today's flag.
//
// The reference before the window and the close of the bar carrying the fix are
// read off close, so on the bar that is forming they move as it forms and settle
// when it closes, and a bar that has closed is not rewritten afterwards. The
// record itself is gated on the bar being confirmed, so a day joins it on the
// close of its far-side bar rather than while that bar is still forming. Without
// that gate the day would join on the far-side bar's first tick, because a
// forming bar already reports its scheduled close time.
//
// The record is the part worth having. For each finished day the script stores
// two numbers in basis points: the move from the last close before the window
// opened up to the close of the bar that carries the fix, and the move from
// that bar to the close of the bar a chosen interval later. On the Tokyo window
// it holds those for the flagged dates and for every other date separately; on
// the London window every date goes into one record, because a Japanese
// settlement date is not a claim about who trades a London benchmark. For each
// record it prints the median of both numbers, the share of days the first was
// positive, the share of days the second went the other way, and the number of
// days behind each figure.
//
// That last row is the point. The folk version of this calendar says the pre
// fix move on a settlement date runs one way and hands part of itself back
// afterwards. The two shares above are that claim's own quantities, printed on
// whatever history the chart has loaded, with the sample size beside them. A
// settlement calendar produces six or seven dates a month, so a year of history
// is on the order of eighty days: at eighty days a share has a standard error
// of 5.6 points, and a share that sits ten points from a coin toss is under two
// of those. The table prints the count so the reader does that division rather
// than reading the share alone.
//
// Nothing here is an entry, an exit, a direction or a filter. The script takes
// no view on which way a settlement date goes and offers no threshold that
// would turn one of these numbers into a condition.

// Window ---------------------------------------------------------------------
winSel = input.string("Tokyo mid rate, 09:55", "Fixing window", options = ["Tokyo mid rate, 09:55", "London benchmark fix, 16:00"], group = "Window", tooltip = "Each is read on its own city's clock and its own calendar date, so daylight saving is handled by the timezone rather than by an offset. Tokyo does not observe daylight saving; London does, twice a year.")
preMin = input.int(45, "Minutes before the fix", minval = 5, maxval = 240, group = "Window", tooltip = "The reference close is the last bar closing at or before this many minutes ahead of the fix. On a chart whose bars do not land on that minute the realised interval is longer, and the table prints both the interval asked for and the one measured.")
postMin = input.int(90, "Minutes after the fix", minval = 5, maxval = 240, group = "Window", tooltip = "Same rule on the other side: the first bar closing at or after this many minutes past the fix. Capped at 240 so that neither edge of the widest window can cross local midnight on either clock, which would put the two ends on different calendar dates.")

// Calendar -------------------------------------------------------------------
rollWeekend = input.bool(true, "Move a weekend settlement date back to the Friday", group = "Calendar", tooltip = "On, a settlement date falling on a Saturday or a Sunday flags the Friday before it. Off, the calendar is read literally and those dates simply produce no flag, since there is no trading on them. Turning it off is the way to see how much of the flagged set is the roll rule rather than the raw dates.")
splitOnCal = input.bool(true, "Keep the record split by settlement date", group = "Calendar", tooltip = "The split is applied on the Tokyo window only. The calendar is a Japanese settlement convention, and holding a London benchmark's days apart by it would assert something about who trades that benchmark which this script does not measure. With the London window the flag is still printed for the date and every date goes into one pooled record.")

// Record ---------------------------------------------------------------------
maxDays = input.int(500, "Days kept in the record, both groups together", minval = 40, maxval = 2000, group = "Record", tooltip = "The oldest day drops out when this fills, whichever group it was in, so the two groups cover the same stretch of the chart. Capping each group on its own instead would let the larger one fill first and start reporting a shorter span than the other, and the two medians would then be describing different years. Five hundred weekdays is about two years, which a settlement calendar fills with around a hundred and fifty flagged dates.")

// Display --------------------------------------------------------------------
showBands = input.bool(true, "Shade the window", group = "Display")
showTable = input.bool(true, "Show readout", group = "Display")

// What the chart has to be, and the chart type test comes first because it is
// the one every other gate lets through. On a Heikin Ashi, Renko, Kagi, Line
// break, Point and figure or Range chart the price series is built by the chart
// rather than dealt in the market, so the timeframe, the symbol type and the
// currency all still look right while every basis point below would be measured
// off a price nobody traded. Renko and Range charts also carry no clock close on
// their forming bars, and the same gate covers that.
//
// The rest: the method is a clock time measured against bar closes, so a chart
// whose bars are longer than an hour cannot place the fix within an hour of
// itself, and a chart measured in seconds or in ticks has no stable minute to
// test. Both halves of the intraday test are needed, because
// timeframe.isintraday is true for a seconds chart as well.
bool stdOk = chart.is_standard
bool tfOk  = timeframe.isintraday and not timeframe.isseconds and not timeframe.isticks and timeframe.in_seconds() <= 3600
bool fxOk  = syminfo.type == "forex"
bool tokyo = winSel == "Tokyo mid rate, 09:55"
bool jpyOk = not tokyo or syminfo.currency == "JPY" or syminfo.basecurrency == "JPY"
bool engineOk = stdOk and tfOk and fxOk and jpyOk

string tz       = tokyo ? "Asia/Tokyo" : "Europe/London"
int    fixCm    = tokyo ? 595 : 960
string fixLabel = tokyo ? "09:55 Asia/Tokyo" : "16:00 Europe/London"

// One bar length in whole minutes, used as the tolerance on both edges. A bar
// closing more than one bar length away from the minute asked for is a gap
// rather than an alignment, and the day is counted out instead of pooled.
int tolMin = int(math.max(1.0, math.round(timeframe.in_seconds() / 60.0)))

// Local clock and local calendar date, both read off the bar's close in the
// window's own timezone. Bar opens are the wrong end here: a bar that opens on
// one calendar date can close on the next, and the fix is an instant inside the
// bar rather than at its start.
int tRef = time_close
int cm   = hour(tRef, tz) * 60 + minute(tRef, tz)
int d0   = dayofmonth(tRef, tz)
int dow  = dayofweek(tRef, tz)

// Day arithmetic anchored near local noon rather than on the bar itself. Adding
// twenty four hours to a timestamp lands on the next calendar date at every
// hour except the one or two near midnight on a clock change day, where the
// hour that is added or removed can leave the date where it was. Noon has
// twelve hours of margin on both sides, so the three dates below are the next
// three calendar dates on any clock. Tokyo does not need this and gets it
// anyway, so there is one code path.
int dayMs  = 86400000
int noonMs = tRef - cm * 60000 + 43200000
int n1 = dayofmonth(noonMs + dayMs, tz)
int n2 = dayofmonth(noonMs + 2 * dayMs, tz)
int n3 = dayofmonth(noonMs + 3 * dayMs, tz)

// A date is the last of its month when the next date is smaller, which is the
// one test that needs no month length table and no leap year rule.
bool me0 = n1 < d0
bool me1 = n2 < n1
bool me2 = n3 < n2

bool nom0 = d0 % 5 == 0 or me0
bool nom1 = n1 % 5 == 0 or me1
bool nom2 = n2 % 5 == 0 or me2

bool isWeekday = dow != dayofweek.saturday and dow != dayofweek.sunday
bool isFriday  = dow == dayofweek.friday

// A Friday absorbs a Saturday date, a Sunday date, or both at once, which
// happens when the 30th is a Saturday and the 31st is the last of the month.
bool rolled  = rollWeekend and isFriday and (nom1 or nom2) and not nom0
bool calFlag = isWeekday and (nom0 or (rollWeekend and isFriday and (nom1 or nom2)))

bool newLocalDay = na(d0[1]) or d0 != d0[1]

// Per day state. Everything resets on the first bar of a new local date, so a
// day that produces no fix bar leaves nothing behind for the next one.
var float preRef  = na
var int   preCm   = na
var float fixRef  = na
var int   fixCm2  = na
var bool  fixCal  = false
var float postRef = na
var int   postCm  = na
var bool  skipMarked = false
var int   skipDays   = 0

if newLocalDay
    preRef  := na
    preCm   := na
    fixRef  := na
    fixCm2  := na
    fixCal  := false
    postRef := na
    postCm  := na
    skipMarked := false

// The reference before the window. Every bar closing at or before the cutoff
// overwrites it, so what survives is the last one, which is the closest to the
// minute asked for that the chart can offer.
if engineOk and na(fixRef) and cm <= fixCm - preMin
    preRef := close
    preCm  := cm

// The fix bar: the first bar of the day closing at or after the fix minute and
// within one bar length of it. The second half of that test is what stops a
// Sunday evening bar, which opens the local week well past the fix minute, from
// being read as that day's fix.
bool fixBarNow = false
if engineOk and na(fixRef) and cm >= fixCm and cm < fixCm + tolMin
    fixRef := close
    fixCm2 := cm
    fixCal := calFlag
    fixBarNow := true

// A day whose bars ran past the fix without one landing inside the tolerance is
// counted out by name rather than pooled. Requiring a pre window reference is
// what keeps the weekend edges out of the count: a Saturday in Tokyo has bars
// before the fix minute and none after it, and it is not a missing fix.
if engineOk and barstate.isconfirmed and not skipMarked and na(fixRef) and not na(preRef) and cm >= fixCm + tolMin
    skipDays += 1
    skipMarked := true

// The record, oldest first. Two groups: dates the calendar flagged, and every
// other date. The four arrays are written in one place and only when a day has
// both ends of its window.
// ordA holds which group each day went to, in the order they arrived, and it is
// what makes the cap a shared one: when the record is full the oldest day is
// dropped from whichever group held it, so the two groups cover the same
// stretch of chart. A cap applied to each group separately would let the
// larger group fill first and begin reporting a shorter span than the smaller
// one, and the two medians printed side by side would then be measurements of
// different years.
var array<float> upCal = array.new_float()
var array<float> gbCal = array.new_float()
var array<float> upOth = array.new_float()
var array<float> gbOth = array.new_float()
var array<int>   ordA  = array.new_int()

// The split is a Tokyo window feature, so the second group carries every date
// when it is off and the table renames both rows to say so.
bool splitActive = splitOnCal and tokyo

float dayUp   = na
float dayGb   = na
float dayPre  = na
float dayPost = na

if engineOk and barstate.isconfirmed and not na(fixRef) and na(postRef) and cm >= fixCm + postMin and cm < fixCm + postMin + tolMin
    postRef := close
    postCm  := cm
    int rPre  = fixCm2 - preCm
    int rPost = postCm - fixCm2
    bool spanOk = not na(preRef) and preRef > 0.0 and fixRef > 0.0 and rPre <= preMin + tolMin and rPost <= postMin + tolMin
    if spanOk
        dayUp   := (fixRef - preRef) / preRef * 10000.0
        dayGb   := (postRef - fixRef) / fixRef * 10000.0
        dayPre  := rPre * 1.0
        dayPost := rPost * 1.0
        bool toCal = splitActive and fixCal
        if toCal
            array.push(upCal, dayUp)
            array.push(gbCal, dayGb)
        else
            array.push(upOth, dayUp)
            array.push(gbOth, dayGb)
        array.push(ordA, toCal ? 0 : 1)
        if array.size(ordA) > maxDays
            int dropped = array.shift(ordA)
            if dropped == 0
                array.shift(upCal)
                array.shift(gbCal)
            else
                array.shift(upOth)
                array.shift(gbOth)
    else
        if not skipMarked
            skipDays += 1
            skipMarked := true

// Summaries. None of these touches price history, so they are read once on the
// last bar rather than on every bar. An empty group is guarded with an if block
// rather than a ternary, because array.median on an empty array is an error and
// a ternary evaluates both of its branches.
f_med(array<float> a) =>
    float m = na
    if array.size(a) > 0
        m := array.median(a)
    m

f_sharePos(array<float> a) =>
    float s = na
    int n = array.size(a)
    if n > 0
        float c = 0.0
        for i = 0 to n - 1
            c += array.get(a, i) > 0.0 ? 1.0 : 0.0
        s := c / n
    s

// Two days disagree when one move is up and the other is down. An exact zero on
// either side is neither an agreement nor a disagreement and is counted as
// neither, which is why this share and the share of positive run ups are not
// two views of the same count.
f_shareOpp(array<float> u, array<float> g) =>
    float s = na
    int n = math.min(array.size(u), array.size(g))
    if n > 0
        float c = 0.0
        for i = 0 to n - 1
            float a = array.get(u, i)
            float b = array.get(g, i)
            c += ((a > 0.0 and b < 0.0) or (a < 0.0 and b > 0.0)) ? 1.0 : 0.0
        s := c / n
    s

f_se(float p, int n) => na(p) or n < 1 ? na : math.sqrt(p * (1.0 - p) / n)

f_pct(float p, int n) => na(p) ? "-" : str.tostring(p * 100.0, "0") + "% +/- " + str.tostring(f_se(p, n) * 100.0, "0") + " on " + str.tostring(n)

f_bp(float v) => na(v) ? "-" : str.tostring(v, "0.0") + " bp"

int nCal = array.size(upCal)
int nOth = array.size(upOth)

// Warmup is a count of finished days rather than a count of bars, since a day
// contributes at most one. The refusals sit ahead of it: a chart or a symbol
// that will produce no reading at all should say so on the first bar rather than
// after a hundred days of waiting.
bool haveAny = nCal + nOth > 0
string statusText = not stdOk ? "needs a standard chart, this one is built from synthetic prices" : not timeframe.isintraday ? "needs an intraday chart" : timeframe.isseconds or timeframe.isticks ? "needs a chart of one minute or more" : timeframe.in_seconds() > 3600 ? "needs a chart of sixty minutes or less" : not fxOk ? "needs a forex symbol" : not jpyOk ? "the Tokyo mid rate is quoted for JPY, this symbol has no JPY leg" : not haveAny ? "no finished window yet on this chart" : "ok"

// Display bands. Both outer edges are the requested window widened by one bar
// length, which is what makes the shading contain the bars that were actually
// measured on any chart. The reference close is the last one at or before
// fixCm - preMin, so its minute lies in (fixCm - preMin - tolMin, fixCm - preMin]
// and the widened near edge reaches it on any chart; the far-side close is the
// first at or after fixCm + postMin and within tolMin of it, so the far edge
// reaches that too. Written off the clock rather than off the latches,
// because a band has to be decidable on the bar it is drawn on: preCm keeps
// moving forward through the morning, so a band anchored on it would shade every
// bar it had ever pointed at.
//
// Without the widening the pre band is empty on an hourly chart, where no bar
// closes strictly inside a 45 minute interval, and the post band stops one bar
// short of the bar the far end was read from.
bool inPre  = engineOk and cm > fixCm - preMin - tolMin and cm < fixCm
bool inPost = engineOk and not na(fixRef) and not fixBarNow and cm > fixCm2 and cm <= fixCm + postMin + tolMin

color calCol = color.orange
color othCol = color.blue

color bandCol = not engineOk or not showBands ? na : fixBarNow ? color.new(calFlag ? calCol : othCol, 60) : inPre ? color.new(calFlag ? calCol : othCol, 88) : inPost ? color.new(calFlag ? calCol : othCol, 94) : na
bgcolor(bandCol, title = "Fixing window")

// Data window rows. Each carries its own refusal, because none of them passes
// through the arrays: they are arithmetic on the day's own three closes and on
// the clock, and a refused chart must print nothing anywhere.
plot(engineOk ? dayUp : na, "Run up into the fix, bp", display = display.data_window)
plot(engineOk ? dayGb : na, "Move after the fix, bp", display = display.data_window)
plot(engineOk ? dayPre : na, "Measured minutes before", display = display.data_window)
plot(engineOk ? dayPost : na, "Measured minutes after", display = display.data_window)
plot(engineOk ? (calFlag ? 1.0 : 0.0) : na, "Settlement date flag", display = display.data_window)
plot(engineOk ? nCal * 1.0 : na, "Days in the flagged record", display = display.data_window)
plot(engineOk ? nOth * 1.0 : na, "Days in the other record", display = display.data_window)
plot(engineOk ? skipDays * 1.0 : na, "Days counted out", display = display.data_window)

if showTable and barstate.islast
    float mUpCal = f_med(upCal)
    float mGbCal = f_med(gbCal)
    float mUpOth = f_med(upOth)
    float mGbOth = f_med(gbOth)
    float pUpCal = f_sharePos(upCal)
    float pUpOth = f_sharePos(upOth)
    float pOpCal = f_shareOpp(upCal, gbCal)
    float pOpOth = f_shareOpp(upOth, gbOth)

    string dateTxt = engineOk ? str.format_time(tRef, "yyyy-MM-dd", tz) : "-"
    string flagTxt = not engineOk ? "-" : calFlag and rolled ? "settlement date, moved back from the weekend" : calFlag ? "settlement date" : isWeekday ? "not a settlement date" : "no trading date"
    string alignTxt = not engineOk or na(fixCm2) ? "-" : "fix at " + fixLabel + ", bar closes " + str.tostring(math.floor(fixCm2 / 60.0), "00") + ":" + str.tostring(fixCm2 % 60, "00") + ", " + str.tostring(fixCm2 - fixCm) + " min later"
    string spanTxt = not engineOk ? "-" : na(dayPre) ? "asked for " + str.tostring(preMin) + " and " + str.tostring(postMin) + " min, none measured yet today" : "asked for " + str.tostring(preMin) + " and " + str.tostring(postMin) + " min, measured " + str.tostring(dayPre, "0") + " and " + str.tostring(dayPost, "0")
    string todayTxt = not engineOk ? "-" : na(fixRef) ? "window has not opened" : na(preRef) ? "no close before the window on this date" : na(postRef) ? "run up " + f_bp((fixRef - preRef) / preRef * 10000.0) + ", the far side is still open" : "run up " + f_bp((fixRef - preRef) / preRef * 10000.0) + ", after " + f_bp((postRef - fixRef) / fixRef * 10000.0)
    string calUpTxt = not engineOk or nCal < 1 ? "-" : "median " + f_bp(mUpCal) + ", up on " + f_pct(pUpCal, nCal) + " days"
    string calGbTxt = not engineOk or nCal < 1 ? "-" : "median " + f_bp(mGbCal) + ", opposed the run up on " + f_pct(pOpCal, nCal)
    string othUpTxt = not engineOk or nOth < 1 ? "-" : "median " + f_bp(mUpOth) + ", up on " + f_pct(pUpOth, nOth) + " days"
    string othGbTxt = not engineOk or nOth < 1 ? "-" : "median " + f_bp(mGbOth) + ", opposed the run up on " + f_pct(pOpOth, nOth)
    string skipTxt = engineOk ? str.tostring(skipDays) : "-"
    string splitTxt = not engineOk ? "-" : splitActive ? "on, settlement dates kept apart" : tokyo ? "off, every date pooled below" : "not applied on this window, every date pooled below"
    string lblCal = splitActive ? "Settlement dates" : "Settlement dates, not split"
    string lblOth = splitActive ? "Other dates" : "All dates"

    var table t = table.new(position.top_right, 2, 12, border_width = 1)
    table.cell(t, 0, 0, "Window", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 0, engineOk ? fixLabel : "-", text_color = color.white, text_size = size.small)
    table.cell(t, 0, 1, "Date on that clock", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1, dateTxt, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 2, "Settlement calendar", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2, flagTxt, text_color = color.white, bgcolor = color.new(engineOk and calFlag ? calCol : color.gray, 80), text_size = size.small)
    table.cell(t, 0, 3, "Fix alignment", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 3, alignTxt, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 4, "Measured window", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 4, spanTxt, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 5, "Today", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 5, todayTxt, text_color = color.white, text_size = size.small)
    table.cell(t, 0, 6, lblCal + ", into the fix", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 6, calUpTxt, text_color = color.white, bgcolor = color.new(calCol, 85), text_size = size.small)
    table.cell(t, 0, 7, lblCal + ", after it", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 7, calGbTxt, text_color = color.white, bgcolor = color.new(calCol, 85), text_size = size.small)
    table.cell(t, 0, 8, lblOth + ", into the fix", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 8, othUpTxt, text_color = color.white, bgcolor = color.new(othCol, 85), text_size = size.small)
    table.cell(t, 0, 9, lblOth + ", after it", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 9, othGbTxt, text_color = color.white, bgcolor = color.new(othCol, 85), text_size = size.small)
    table.cell(t, 0, 10, "Split and days counted out", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 10, engineOk ? splitTxt + ", " + skipTxt + " counted out" : "-", text_color = color.gray, text_size = size.small)
    table.cell(t, 0, 11, "Status", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 11, statusText, text_color = statusText == "ok" ? color.gray : color.orange, text_size = size.small)
````
