<!-- tradingview-pine-id: PUB;58b1ca6af1294c428e402034f4e7ef56 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume + RVOL + Directional Delta [Clean]

Source: https://www.tradingview.com/script/2a7uwLSn-Volume-RVOL-Directional-Delta-Clean/

## Description

# Volume + RVOL + Directional Delta [Clean]

## What this is

A volume pane with three layers: raw volume colored by relative volume, a
signed Directional Delta histogram, and a dashboard that reports **how each
number was actually produced**.

The third layer is the point. Relative volume and volume delta both depend on
data that is not always available, and most implementations substitute a
different measurement when the real one is missing — without saying so. This
indicator computes the same things everyone else computes, then tells you when
what you are looking at is not what the label claims.

Every fallback in the script is visible in the dashboard. There are no silent
substitutions.

---

## The problem it addresses

Two silent substitutions happen constantly in volume tooling.

**1. Time-of-day RVOL that isn't.** Comparing a bar to prior bars at the same
clock time is the right way to do intraday RVOL — 9:30 volume and 2:00 volume
are not the same population. But it only works if session bars land on
consistent clock times. On a 65-minute regular-hours chart there are six bars
per session and the opens repeat cleanly. Turn on extended hours and the
session runs about 14.8 bars, the opens drift, and the same-time search returns
almost nothing. Most scripts fall back to a rolling average at that point and
keep displaying the number as though nothing changed.

**2. Volume delta that is really just bar direction.** Estimating delta
requires summing signed intrabar volume from a lower timeframe. TradingView's
intrabar budget is finite — at 65m/1m that is 65 intrabars per chart bar,
covering roughly a year of history before `request.security_lower_tf()` starts
returning empty arrays. The usual fallback is a chart-bar proxy: positive if
the bar closed up, negative if it closed down. That proxy can only ever return
exactly ±volume, i.e. ±100% delta. It is not a noisier version of intrabar
delta. It is a different measurement with a different range, and a single proxy
bar contributes the largest value any bar can contribute.

Both substitutions are reasonable as fallbacks. Neither is acceptable as a
silent one.

---

## Relative volume

**Baseline statistic.** Median by default rather than mean. The mean is dragged
upward by exactly the news-driven spikes RVOL exists to detect, which makes a
fixed threshold like 2.0x mean different things on different tickers and in
different regimes. The median keeps the threshold comparable across names.

**Time-of-day mode** walks backward collecting prior bars whose open lands on
the same hour and minute as the current bar, then takes the median of those.

The setting is a **target sample count, not a search window**. This matters
more than it sounds. A search-window setting produces a completely different
statistical baseline on every timeframe — 120 bars finds about 20 samples on
65m, 12 on 39m, and 4 on 15m. Asking for 20 comparable sessions instead means
20 sessions wherever they are reachable. A separate maximum search distance
bounds how far the scan may walk to find them.

Sizing guidance, on a 390-minute regular-hours session:

    Chart TF   Bars/session   Search distance for 20 samples
    10m        39             ~780
    15m        26             ~520
    39m        10             ~200
    65m         6             ~120
    78m         5             ~100
    130m        3              ~60
    195m        2              ~40

The default 1000-bar ceiling reaches 20 samples down through 10m. Some
combinations are simply unreachable — 20 sessions on a 1-minute chart would
need 7800 bars — and those degrade to the rolling baseline and say so.

**Attainment is a three-state result**, because once the setting means "20
sessions", clearing a bare minimum of 10 is not the same as meeting the
request:

    MODE   TOD     target met — the baseline you configured
    MODE   TOD*    minimum met, target missed — usable, but not what you asked
    MODE   ROLL*   minimum missed — fell back to rolling entirely

The middle state keeps a useful 15-sample baseline rather than discarding it,
while refusing to report it as though 20 sessions had been achieved.

**Coloring.** Gray below the high threshold, green at high RVOL, gold at
extreme. Thresholds are configurable.

---

## Bar completion, and why nothing is projected

RVOL divides a **partial** current bar by a median of **completed** bars. It
therefore reads low at the start of a bar and climbs throughout. A 0.4x forty
minutes into a 65-minute bar is not the same statement as a 0.4x at the close.

This is deliberately not projected to a full-bar estimate. Intraday volume is
U-shaped, so scaling linearly by elapsed time overstates near the open and
understates into the close — and an extrapolated figure displayed to two
decimals invites more trust than it has earned. The honest fix is a baseline
built from the same elapsed *fraction* of prior same-time-of-day bars, which
requires intrabar history for every baseline bar and is a substantially larger
build.

So the indicator reports completion instead and lets you discount. The `BAR%`
cell turns amber below 95%, which is precisely when the RVOL cell beside it is
understated.

One caveat: this is wall-clock elapsed against nominal bar duration. A bar
truncated by a session boundary or a holiday early close reads below 100% even
at its close. In time-of-day mode such bars are compared against other bars at
the same clock time, so RVOL itself stays meaningful — only the completion
figure misreports.

---

## Directional Delta

Each lower-timeframe bar's entire volume is signed by that bar's own candle
direction, with dojis resolved against the prior close, and the signed values
are summed across the chart bar.

**It is called Directional Delta because that is what it is.** It is not
market-buy volume minus market-sell volume. No lower-timeframe reconstruction
can see bid/ask trade classification; it can only sign small bars by their
direction. That is genuinely useful information about intrabar pressure, and it
is not order flow, and the name should not imply otherwise.

**Cumulative Directional Delta uses real intrabar bars only.** Bars that fell
back to the proxy are excluded from the total rather than included and flagged.

This is worth explaining, because it drives the display. Proxy bars are not
scattered randomly through the window — the intrabar budget runs out going
*backward*, so they form the oldest contiguous block. Filtering therefore
produces a **shorter, more recent window**, not a cleaned full-length one. The
column header reports the real bar count for that reason:

    57B DΔ    +8.7M
    57B DΔ%   +12.6%
    VALID     57/60

You asked for 60 bars and you are looking at a clean measurement over 57. With
zero valid bars both cells read `n/a` rather than a confident `+0`.

Cumulative delta % is total delta divided by total volume across those same
valid bars — not the average of per-bar percentages.

The lookback is left in bars rather than normalized to sessions, deliberately.
It means different amounts of market time on different charts — 60 bars is ten
sessions on 65m but 2.3 sessions on 15m — and the tooltip says so. Which span
you want is a judgment, not something the script should make for you.

---

## Dashboard reference

    RVOL     current bar volume / active baseline
    BAR%     bar completion; amber below 95%, when RVOL is understated
    MODE     TOD / TOD* / ROLL / ROLL*, plus "med" or "avg"
    SAMP     20+ (target met with margin) / 20 (met exactly) / 15/20 (short)
    BAR DΔ   current bar Directional Delta
    BAR DΔ%  as a share of bar volume
    nB DΔ    cumulative over valid bars; header states how many
    nB DΔ%   cumulative delta / cumulative volume, same bars
    VALID    valid bars / requested bars
    Δ TF     intrabar timeframe in use, or why there isn't one

The `Δ TF` cell distinguishes four outcomes, because "no intrabar data" has
causes that call for different responses:

    1 / 15S     intrabar data genuinely in use
    Chart*      a valid lower timeframe was requested, no data came back
    INVALID     manual timeframe is not lower than the chart — fix the setting
    Chart       no lower timeframe exists at all (1-second chart)

`INVALID` exists because entering 65m as the delta timeframe on a 65m chart
used to display a calm white "Chart", identical to the legitimate case. Both
fall through to the proxy; only one is a mistake.

**Color convention.** Amber means one thing throughout: *the number is usable
but is not the measurement you asked for.* Red appears in exactly one place and
means *this setting cannot work as entered*. Keeping those separate is what
makes the pane readable at a glance.

---

## Settings guidance

- **65m regular hours:** defaults work as-is. About 120 bars of search finds
  the 20-sample target.
- **15m and 10m:** also fine at the 1000-bar default, but the scan runs much
  further. If the script becomes slow, turn off *Compute Time-of-Day Baseline
  on History* — historical bar coloring then uses the rolling baseline while
  the dashboard uses time-of-day, which is a real inconsistency and is why it
  is a visible toggle rather than a silent optimization.
- **Extended-hours charts:** time-of-day will degrade to `ROLL*`. Session bar
  opens do not repeat. Either switch to regular hours or accept the rolling
  baseline knowingly.
- **Daily and above:** time-of-day is inapplicable and is bypassed.
- **Delta timeframe:** leave on automatic. It steps down correctly including on
  1-minute charts. Sub-minute intrabar data requires a higher TradingView plan
  tier; on a lower tier the request returns empty and `Δ TF` reports `Chart*`.
- **Below ~15 samples**, the median becomes sensitive to holiday early-close
  sessions, whose truncated final bars carry structurally low volume.

---

## Alerts

Six conditions. High RVOL and Extreme RVOL are straightforward.

The two combined alerts — extreme volume with positive or negative Directional
Delta — **require real intrabar data**. On a proxy bar the delta sign is
nothing more than the candle body's direction, so an ungated version would fire
on "heavy volume, bar closed up" while appearing to describe something more.

Two ungated variants are provided separately and named for what they actually
test: *Extreme Volume + Up Bar* and *Extreme Volume + Down Bar*, each stating in
its own message that it does not test Directional Delta.

---

## What this is not

- It does not project or estimate finished bar volume.
- Directional Delta is not bid/ask trade classification and does not claim to be.
- It makes no directional claim, generates no entries, and has no backtest.
- The proxy fallback is not "close enough." It is excluded from cumulative
  figures and labeled where it appears, so you can decide whether a number is
  usable for what you are doing.

---

## Implementation notes

Both rolling statistics (`ta.sma` and `ta.median`) are evaluated
unconditionally and then selected, rather than being called inside a
conditional branch, which would produce an inconsistent series.

The sample scan probes for one more than the target, then discards it. That is
what makes `20+` truthful: it means a 21st match genuinely existed, not merely
that the loop stopped. A bare `20` means the target was met with no margin left
in the window, which is worth distinguishing.

The scan exits as soon as the target is met, so the search ceiling costs
nothing on timeframes that reach it — 65m stops near bar 126 regardless of the
setting. It is not free where the target is unreachable: the loop then runs the
full distance on every bar, which is what the history toggle is for.

`todActive` reflects what the code actually used, never what was requested. The
dashboard reads that flag rather than the input, which is what prevents MODE
from displaying `TOD` while a rolling baseline is in use.

The compact number formatter uses `"#0"` rather than `"#"` for sub-thousand
values — a bare `"#"` drops the digit on sub-1 values and renders a lone minus
sign.

Open source.

---

## Source Code

````pine
//@version=6
indicator(
     "Volume + RVOL + Directional Delta [Clean]",
     shorttitle = "VOL RVOL DΔ",
     overlay = false,
     format = format.volume,
     max_bars_back = 1300
)

//=============================================================================
// WHAT CHANGED IN THIS REVISION
//
// 1. TIME-OF-DAY RVOL IS NOW SPECIFIED AS A TARGET SAMPLE COUNT.
//    Previously the setting was a SEARCH WINDOW, so the same number produced a
//    different statistical baseline on every timeframe: 120 bars found ~20
//    samples on 65m, ~12 on 39m, and ~4 on 15m — the last of which fell below
//    the minimum and degraded to rolling. Now you ask for N comparable
//    sessions and the scan walks back until it has them, bounded by a separate
//    maximum search distance. Twenty sessions means twenty sessions on any
//    timeframe that can reach them.
//
// 2. CUMULATIVE DELTA IS COMPUTED FROM REAL INTRABAR BARS ONLY.
//    The previous revision summed intrabar bars and proxy bars together and
//    marked the total with an asterisk. That was transparent but still mixed
//    two different measurements into one number. Proxy bars are not scattered
//    randomly through the window — the intrabar budget runs out going
//    backward, so they are systematically the OLDEST contiguous block. The
//    cumulative figure is therefore built only from valid bars, and the column
//    header reports how many bars that actually is. A shorter honest window
//    beats a longer contaminated one.
//
// 3. RENAMED TO DIRECTIONAL DELTA.
//    Each lower-timeframe bar's entire volume is signed by its own candle
//    direction. That is a useful estimate. It is not market-buy volume minus
//    market-sell volume, and the old label implied bid/ask order flow that
//    this method cannot see. Dashboard cells now read DΔ and the alerts say
//    so in their titles.
//
// 4. CAP SEMANTICS FIXED.
//    The sample scan previously stopped on finding sample N and displayed
//    "N+", which claimed knowledge it did not have — there might have been
//    exactly N available. It now scans for N+1, uses N, and only shows "+"
//    when the extra one was genuinely found.
//
// 5. The rolling baseline has its own lookback input, since it is no longer
//    sharing a number with the time-of-day search.
//
// 6. PARTIAL TARGET ATTAINMENT IS NOW A VISIBLE STATE.
//    Once the setting means "20 comparable sessions", clearing the bare
//    minimum of 10 is not the same as meeting the request. Finding 15 samples
//    previously displayed as plain TOD, which claimed an attainment that had
//    not happened. There is now a middle state — TOD* with SAMP reading 15/20
//    — that keeps the usable baseline while reporting the shortfall.
//
// 7. Default search distance raised to 1000 bars so a 20-sample target is
//    reachable down through 10m (~780 bars). Note this ceiling is free only
//    where the target IS reached: the loop exits on success, so 65m still
//    stops near bar 126, but a timeframe that can never reach the target now
//    scans the full 1000 every bar. See the input tooltip.
//
// 8. Automatic delta timeframe steps down correctly on 1-minute and
//    sub-minute charts, which previously requested a timeframe that was not
//    lower than the chart and so used the proxy on every bar.
//
// 9. THE Δ TF CELL NOW DISTINGUISHES MISCONFIGURATION FROM LIMITATION.
//    Previously, a manual delta timeframe that was not lower than the chart
//    displayed a calm white "Chart" — identical to the legitimate case where
//    no lower timeframe exists. Both fell through to the ±100% proxy, but only
//    one of them was a mistake. There are now four states: the timeframe in
//    use, "Chart*" for data that was requested and did not arrive, "INVALID"
//    in red for a setting that cannot work, and "Chart" for a genuine limit.
//    Red is introduced here and used nowhere else: amber continues to mean
//    "usable but not what you asked for", which INVALID is not.
//=============================================================================


//=============================================================================
// INPUTS
//=============================================================================

//-----------------------------------------------------------------------------
// VOLUME + RVOL
//-----------------------------------------------------------------------------
groupVol = "Volume + RVOL"

useTimeAdjustedRvol = input.bool(
     true,
     "Intraday Time-of-Day RVOL",
     tooltip = "Compares the current bar with prior bars opening at the same clock time. Requires session bar opens to land on consistent clock times. True for any interval that divides the session evenly (15m, 26m, 30m, 39m, 65m, 78m, 130m, 195m on a 390-minute RTH session) and also true for intervals that merely repeat, such as 60m with a stub bar. Not true for extended-hours charts, where the opens drift. Read the SAMP cell rather than reasoning about it — it reports what was actually found.",
     group = groupVol
)

todTargetSamples = input.int(
     20,
     "Time-of-Day Target Samples",
     minval = 2,
     maxval = 100,
     tooltip = "How many prior same-clock-time bars to build the baseline from. This is the number that actually determines the statistic, and it now means the same thing on every timeframe. Twenty is roughly a month of sessions. Samples are collected newest-first, so the baseline stays anchored on recent sessions rather than reaching back into a different volume regime.",
     group = groupVol
)

todSearchBars = input.int(
     1000,
     "Time-of-Day Maximum Search Bars",
     minval = 10,
     maxval = 1200,
     tooltip = "How far back the scan is allowed to walk while collecting samples. Size it as target samples x bars per session: 20 samples needs ~120 bars on 65m, ~200 on 39m, ~520 on 15m, ~780 on 10m.\n\nThe scan exits as soon as the target is met, so on higher timeframes this ceiling costs nothing — a 65m chart stops around bar 126 regardless of what is set here. It is NOT free on low timeframes where the target is never reached: the loop then runs the full distance on every bar. On 10m and below, turn off 'Compute Time-of-Day Baseline on History' if the script becomes slow.\n\nSome combinations are unreachable — 20 sessions on a 1-minute chart would need 7800 bars — and those correctly degrade to the rolling baseline.",
     group = groupVol
)

minTodSamples = input.int(
     10,
     "Minimum Acceptable Samples",
     minval = 1,
     maxval = 100,
     tooltip = "If the scan finishes with fewer samples than this, the baseline falls back to the rolling method and the MODE cell shows ROLL* in amber. Note that below about 15 samples the median becomes sensitive to holiday early-close sessions, whose truncated final bars carry structurally low volume.",
     group = groupVol
)

todOnHistory = input.bool(
     true,
     "Compute Time-of-Day Baseline on History",
     tooltip = "When on, the same-clock-time scan runs on every bar, so historical volume coloring reflects the same baseline as the current bar. When off, the scan runs only on the last and realtime bars and all history is colored by the rolling baseline instead — faster, but the colors on old bars then answer a different question than the dashboard does. Turn this off if the script becomes slow, which happens on low timeframes where the search distance is large.",
     group = groupVol
)

rvolLen = input.int(
     120,
     "Rolling Baseline Lookback",
     minval = 2,
     maxval = 1000,
     tooltip = "Bars used for the rolling baseline. This is the baseline in use whenever time-of-day mode is off, unavailable, or degraded.",
     group = groupVol
)

useMedianBaseline = input.bool(
     true,
     "Median Baseline",
     tooltip = "Median instead of mean. The mean is dragged upward by the same news-driven spikes RVOL is meant to detect, which makes a fixed multiple mean different things on different tickers. Median keeps the threshold comparable across names.",
     group = groupVol
)

highRvol = input.float(
     1.50,
     "High RVOL",
     minval = 1.00,
     step = 0.05,
     group = groupVol
)

extremeRvol = input.float(
     2.00,
     "Extreme RVOL",
     minval = 1.00,
     step = 0.05,
     group = groupVol
)

showVolMA = input.bool(
     true,
     "Show RVOL Baseline",
     group = groupVol
)


//-----------------------------------------------------------------------------
// DIRECTIONAL DELTA
//-----------------------------------------------------------------------------
groupDelta = "Directional Delta"

showDelta = input.bool(
     true,
     "Show Delta Histogram",
     group = groupDelta
)

deltaLookbackLen = input.int(
     60,
     "Delta Lookback Bars",
     minval = 2,
     maxval = 1000,
     tooltip = "Requested window for cumulative Directional Delta. Bars without real intrabar data are EXCLUDED from the total, so the effective window can be shorter than requested — the column header and the VALID cell both report the real number. Scale this with timeframe if you want a consistent span: 60 bars is ten sessions on 65m but only 2.3 sessions on 15m, where ~156 is the equivalent.",
     group = groupDelta
)

autoDeltaTf = input.bool(
     true,
     "Automatic Delta Timeframe",
     tooltip = "Automatically chooses a lower timeframe for estimating intrabar volume Delta.",
     group = groupDelta
)

customDeltaTf = input.timeframe(
     "1",
     "Manual Delta Timeframe",
     tooltip = "Used only when Automatic Delta Timeframe is turned off. Must be genuinely lower than the chart interval — entering 65m on a 65m chart forces the ±100% direction proxy on every bar and makes cumulative Delta unavailable entirely. The Δ TF cell reads INVALID in red when this happens.",
     group = groupDelta
)


//-----------------------------------------------------------------------------
// DASHBOARD
//-----------------------------------------------------------------------------
groupDash = "Dashboard"

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = groupDash
)

dashHeaderSize = input.string(
     size.small,
     "Header Font Size",
     options = [
         size.tiny,
         size.small,
         size.normal,
         size.large,
         size.huge
     ],
     group = groupDash
)

dashValueSize = input.string(
     size.normal,
     "Value Font Size",
     options = [
         size.tiny,
         size.small,
         size.normal,
         size.large,
         size.huge
     ],
     group = groupDash
)


//-----------------------------------------------------------------------------
// COLORS
//-----------------------------------------------------------------------------
groupColors = "Colors"

normalColor = input.color(
     color.rgb(105, 105, 105),
     "Normal Volume — Gray",
     group = groupColors
)

highColor = input.color(
     color.rgb(0, 170, 110),
     "High Volume — Green",
     group = groupColors
)

extremeColor = input.color(
     color.rgb(212, 175, 55),
     "Extreme Volume — Gold",
     group = groupColors
)

positiveDeltaColor = input.color(
     color.rgb(40, 150, 255),
     "Positive Delta",
     group = groupColors
)

negativeDeltaColor = input.color(
     color.rgb(220, 70, 70),
     "Negative Delta",
     group = groupColors
)

degradedColor = input.color(
     color.rgb(235, 160, 40),
     "Degraded / Fallback — Amber",
     tooltip = "Used in the dashboard when a requested method silently fell back to a substitute, or when a window is narrower than requested. Amber always means the number is still usable but is not the measurement that was asked for.",
     group = groupColors
)

invalidColor = input.color(
     color.rgb(235, 70, 70),
     "Invalid Configuration — Red",
     tooltip = "Used only when a setting cannot work as entered and needs to be changed. Kept distinct from amber because amber marks a qualified-but-usable number, whereas this marks a configuration error.",
     group = groupColors
)


//=============================================================================
// FUNCTIONS
//=============================================================================

//-----------------------------------------------------------------------------
// AUTOMATIC LOWER TIMEFRAME FOR DELTA
//-----------------------------------------------------------------------------
// A 1-minute chart previously requested "1" as its lower timeframe, which is
// not lower, so validLowerTf failed and every bar used the direction proxy.
// Sub-minute charts had the same problem at 1S. Both now step down properly.
//
// Sub-minute intrabar data requires a higher TradingView plan tier. On a lower
// tier the request returns empty, ltfDataOk goes false, and the Δ TF cell reads
// Chart* in amber — the existing degradation path already reports this
// correctly, so no extra handling is needed.
//
// On a 1-second chart there is nothing lower to request. The proxy is then
// genuinely the only option, and Δ TF says so.
f_autoDeltaTf() =>
    float chartSecs = timeframe.in_seconds()

    string tf = "60"

    if timeframe.isseconds
        // On a 1S chart this is not lower, validLowerTf fails, and the proxy
        // takes over — which is the correct and only outcome.
        tf := "1S"
    else if timeframe.isintraday
        tf := chartSecs > 60 ? "1" : "15S"
    else if timeframe.isdaily
        tf := "5"

    tf


//-----------------------------------------------------------------------------
// SIGNED VOLUME
//
// Bullish = positive, bearish = negative.
// Doji resolves against the previous close.
//
// Used in two contexts:
//   1. Inside request.security_lower_tf() — signs each intrabar.
//   2. At chart scope — the fallback proxy when no intrabar data exists.
//
// NOTE: these are NOT the same measurement. The intrabar version sums many
// signed pieces and lands anywhere in [-volume, +volume]. The chart-scope
// version can only ever return exactly ±volume, i.e. ±100% delta.
//
// Neither version is order flow. Both sign a whole bar's volume by that bar's
// candle direction; the intrabar version simply does it on much smaller bars.
// Hence "Directional Delta" rather than "Delta".
//-----------------------------------------------------------------------------
f_signedVolume() =>
    float direction = 0.0

    if close > open
        direction := 1.0
    else if close < open
        direction := -1.0
    else if close > close[1]
        direction := 1.0
    else if close < close[1]
        direction := -1.0

    volume * direction


//-----------------------------------------------------------------------------
// COMPACT NUMBER FORMATTER
//-----------------------------------------------------------------------------
f_compact(float value) =>
    string result = "n/a"

    if not na(value)

        float absValue = math.abs(value)
        string signText = ""

        if value > 0
            signText := "+"
        else if value < 0
            signText := "-"

        if absValue >= 1000000000
            result :=
                 signText +
                 str.tostring(absValue / 1000000000, "#.##") +
                 "B"

        else if absValue >= 1000000
            result :=
                 signText +
                 str.tostring(absValue / 1000000, "#.##") +
                 "M"

        else if absValue >= 1000
            result :=
                 signText +
                 str.tostring(absValue / 1000, "#.##") +
                 "K"

        else
            // "#0" not "#" — a bare "#" drops the digit for sub-1 values
            // and renders a lone minus sign.
            result :=
                 signText +
                 str.tostring(absValue, "#0")

    result


//-----------------------------------------------------------------------------
// FORMAT PERCENTAGE
//-----------------------------------------------------------------------------
f_percent(float value) =>
    string result = "n/a"

    if not na(value)

        string signText = ""

        if value > 0
            signText := "+"

        result :=
             signText +
             str.tostring(value, "#.0") +
             "%"

    result


//=============================================================================
// RVOL BASELINE
//=============================================================================

//-----------------------------------------------------------------------------
// ROLLING BASELINE
//
// Both statistics are evaluated unconditionally, then selected. Calling a
// ta.* function inside a conditional branch produces an inconsistent series.
// Current bar is excluded via [1].
//-----------------------------------------------------------------------------

float rollingMean = ta.sma(volume, rvolLen)[1]
float rollingMed = ta.median(volume, rvolLen)[1]

float rollingBaseline =
     useMedianBaseline ? rollingMed : rollingMean


//-----------------------------------------------------------------------------
// TIME-OF-DAY BASELINE
//
// Collects prior bars whose open lands on the same clock time as the current
// bar, walking backward until the TARGET SAMPLE COUNT is met or the maximum
// search distance is exhausted.
//
// The scan deliberately looks for one MORE than the target. If that extra
// sample is found it is discarded from the statistic and used only to justify
// the "+" suffix on the dashboard, which now genuinely means "more were
// available" rather than "the loop stopped here".
//
// Cost: the loop exits as soon as the target is met, so typical cost is
// (bars per session x target samples), not the full search window. It is the
// full window only when samples are unreachable — which is exactly the case
// that then degrades to rolling anyway.
//-----------------------------------------------------------------------------

bool wantTod =
     timeframe.isintraday and
     useTimeAdjustedRvol

// Scanning every bar keeps historical coloring consistent with the dashboard,
// but on low timeframes the search distance is large. This lets the user trade
// history accuracy for speed, with the consequence stated in the tooltip.
bool runTodScan =
     wantTod and
     (todOnHistory or barstate.islast or barstate.isrealtime)

var array<float> todVols = array.new_float()
array.clear(todVols)

if runTodScan

    int currentHour = hour
    int currentMinute = minute
    int scanLimit = todTargetSamples + 1

    for i = 1 to todSearchBars

        bool sameTime =
             not na(volume[i]) and
             hour[i] == currentHour and
             minute[i] == currentMinute

        if sameTime
            array.push(todVols, volume[i])

            if array.size(todVols) >= scanLimit
                break

// True only when a sample BEYOND the target was actually located.
bool todOverflow =
     array.size(todVols) > todTargetSamples

// Discard the probe sample so the statistic uses exactly the requested count.
if todOverflow
    array.pop(todVols)

int todSamples = array.size(todVols)

float timeAdjustedBaseline = na

if todSamples > 0
    timeAdjustedBaseline :=
         useMedianBaseline ?
             array.median(todVols) :
             array.avg(todVols)


//-----------------------------------------------------------------------------
// CHOOSE RVOL METHOD
//
// todActive reflects what the code ACTUALLY used, not what was requested.
//
// Three outcomes rather than two, because once the setting is specified as a
// TARGET SAMPLE COUNT, meeting the bare minimum is no longer the same thing as
// meeting the request:
//
//   samples >= target   -> TOD    full baseline, as configured
//   minimum..target-1   -> TOD*   usable baseline, short of the target (amber)
//   below minimum       -> ROLL*  fell back to rolling entirely (amber)
//
// The middle state is the one this adds. A 15-sample baseline is worth using
// and should not be discarded, but reporting it as plain TOD would claim the
// requested 20 sessions were achieved when they were not. This is the same
// distinction the VALID cell draws for cumulative Delta: a genuine measurement
// over a smaller sample, labelled as such.
//-----------------------------------------------------------------------------

bool todActive =
     wantTod and
     not na(timeAdjustedBaseline) and
     todSamples >= minTodSamples

// Baseline in use, but built from fewer samples than requested.
bool todPartial =
     todActive and
     todSamples < todTargetSamples

// Requested time-of-day but fell back to rolling entirely.
bool todDegraded =
     wantTod and
     not todActive

float volBaseline =
     todActive ? timeAdjustedBaseline : rollingBaseline


//=============================================================================
// RELATIVE VOLUME
//=============================================================================

float rvol = na

if not na(volBaseline) and volBaseline > 0
    rvol :=
         volume / volBaseline


//-----------------------------------------------------------------------------
// BAR COMPLETION
//
// RVOL divides a PARTIAL bar's volume by a median of COMPLETED bars. Early in
// a bar it therefore reads low and climbs, and a 0.4x forty minutes into a 65m
// bar is not the same statement as a 0.4x at the close.
//
// This is deliberately NOT projected to a full-bar estimate. Intraday volume is
// U-shaped, so scaling linearly by elapsed time overstates near the open and
// understates into the close, and an extrapolated number displayed with two
// decimals invites more trust than it has earned. The honest fix — a baseline
// built from the same elapsed FRACTION of prior same-time-of-day bars — needs
// intrabar history per baseline bar, which is a much larger build.
//
// So: report completion, let the reader discount.
//
// Caveat: this is wall-clock elapsed against nominal bar duration. A bar that
// is truncated by a session boundary (or by a holiday early close) will read
// below 100% even at its close. In time-of-day mode such bars are compared
// against other bars at the same clock time, so RVOL itself stays meaningful.
//-----------------------------------------------------------------------------

float barElapsedPct = na

if barstate.isrealtime
    float barSeconds = timeframe.in_seconds()

    if not na(barSeconds) and barSeconds > 0
        float elapsedSeconds = (timenow - time) / 1000.0

        barElapsedPct :=
             math.min(100.0, math.max(0.0, elapsedSeconds * 100.0 / barSeconds))

bool barIncomplete =
     not na(barElapsedPct) and barElapsedPct < 95.0


//-----------------------------------------------------------------------------
// RVOL STATES
//-----------------------------------------------------------------------------

bool extremeVolume = false
bool highVolume = false

if not na(rvol)

    extremeVolume :=
         rvol >= extremeRvol

    highVolume :=
         rvol >= highRvol and
         rvol < extremeRvol


//-----------------------------------------------------------------------------
// MAIN VOLUME COLOR
//-----------------------------------------------------------------------------

color volumeColor = normalColor

if extremeVolume
    volumeColor := extremeColor

else if highVolume
    volumeColor := highColor


//=============================================================================
// DIRECTIONAL DELTA
//=============================================================================

//-----------------------------------------------------------------------------
// DELTA TIMEFRAME
//-----------------------------------------------------------------------------

string deltaTf = customDeltaTf

if autoDeltaTf
    deltaTf := f_autoDeltaTf()


//-----------------------------------------------------------------------------
// VALIDATE LOWER TIMEFRAME
//
// This only checks that the requested timeframe is genuinely lower. It says
// nothing about whether data came back — see ltfDataOk below.
//-----------------------------------------------------------------------------

float chartSeconds =
     timeframe.in_seconds()

float deltaSeconds =
     timeframe.in_seconds(deltaTf)

bool validLowerTf = false

if not na(chartSeconds) and not na(deltaSeconds)
    validLowerTf :=
         deltaSeconds < chartSeconds


//-----------------------------------------------------------------------------
// WHY THE LOWER TIMEFRAME IS UNUSABLE
//
// "Not lower than the chart" has two very different causes and they must not
// share a display state:
//
//   Manual setting that isn't lower  -> a configuration error the user can fix
//   Automatic mode with nothing below -> a genuine limit of the chart
//
// The second is only reachable on a 1-second chart, where the automatic
// function has nothing smaller to request. Everything else that automatic mode
// returns is genuinely lower than its chart.
//
// Without this split, entering 65m as the manual delta timeframe on a 65m
// chart displays a calm white "Chart", which reads as deliberate when in fact
// every bar has silently fallen through to the ±100% direction proxy.
//-----------------------------------------------------------------------------

bool deltaTfInvalid =
     not validLowerTf and
     not autoDeltaTf

bool deltaTfUnavailable =
     not validLowerTf and
     autoDeltaTf


//-----------------------------------------------------------------------------
// CURRENT BAR DELTA
//-----------------------------------------------------------------------------

float volDelta = na
bool ltfDataOk = false


//-----------------------------------------------------------------------------
// LOWER-TIMEFRAME INTRABAR DELTA
//
// The intrabar budget is finite. At 65m/1m that is 65 intrabars per chart bar,
// covering roughly a year of history before the array comes back empty on
// older bars. Lower chart timeframes need fewer intrabars per bar and so reach
// proportionally further back in sessions.
//
// ltfDataOk records whether THIS bar got real data.
//-----------------------------------------------------------------------------

if validLowerTf

    array<float> intrabarVolumes =
         request.security_lower_tf(
             syminfo.tickerid,
             deltaTf,
             f_signedVolume()
         )

    if array.size(intrabarVolumes) > 0
        volDelta :=
             array.sum(intrabarVolumes)

        ltfDataOk := true


//-----------------------------------------------------------------------------
// FALLBACK
//
// Chart-bar direction proxy. Always resolves to exactly ±volume, so any bar
// using this reads as ±100% delta. Different measurement, not a noisier one.
// It is still plotted for the current bar — a ±100% reading is legible as a
// fallback once the Δ TF cell says Chart* — but it is excluded from every
// cumulative figure below.
//-----------------------------------------------------------------------------

if not ltfDataOk
    volDelta :=
         f_signedVolume()

// Requested intrabar delta but silently fell back.
bool deltaDegraded =
     validLowerTf and
     not ltfDataOk


//=============================================================================
// CURRENT BAR DELTA %
//=============================================================================

float deltaPct = na

if volume > 0 and not na(volDelta)
    deltaPct :=
         volDelta /
         volume *
         100.0


//=============================================================================
// CUMULATIVE DELTA — REAL INTRABAR BARS ONLY
//
// Proxy bars are excluded rather than included-and-flagged. They are not
// randomly distributed: the intrabar budget runs out going backward, so proxy
// bars form the oldest contiguous block of the window. Filtering therefore
// yields a SHORTER, MORE RECENT window rather than a cleaned full-length one,
// which is why the column header reports the real bar count instead of the
// requested one.
//=============================================================================

// Number of bars currently available.
// Prevents early-history NA values.
int deltaBarsRequested =
     math.min(
         deltaLookbackLen,
         bar_index + 1
     )

float realDelta =
     math.sum(
         ltfDataOk ? nz(volDelta) : 0.0,
         deltaBarsRequested
     )

float realVolume =
     math.sum(
         ltfDataOk ? volume : 0.0,
         deltaBarsRequested
     )

int deltaBarsValid =
     int(
         math.sum(
             ltfDataOk ? 1.0 : 0.0,
             deltaBarsRequested
         )
     )

bool deltaWindowShort =
     deltaBarsValid < deltaBarsRequested

// With zero valid bars there is no measurement to report, so both cumulative
// cells go to n/a rather than displaying a confident +0.
bool deltaWindowEmpty =
     deltaBarsValid == 0

float lookbackDelta =
     deltaWindowEmpty ? na : realDelta


//-----------------------------------------------------------------------------
// CUMULATIVE DELTA %
//
// TOTAL DELTA divided by TOTAL VOLUME, across the same valid bars only.
// Not the average of each bar's Delta %.
//-----------------------------------------------------------------------------

float lookbackDeltaPct = na

if realVolume > 0
    lookbackDeltaPct :=
         realDelta /
         realVolume *
         100.0


//=============================================================================
// DELTA COLORS
//=============================================================================

color deltaColor = color.gray

if volDelta > 0
    deltaColor :=
         positiveDeltaColor

else if volDelta < 0
    deltaColor :=
         negativeDeltaColor


color lookbackDeltaColor = color.gray

if lookbackDelta > 0
    lookbackDeltaColor :=
         positiveDeltaColor

else if lookbackDelta < 0
    lookbackDeltaColor :=
         negativeDeltaColor


//=============================================================================
// PLOTS
//=============================================================================

//-----------------------------------------------------------------------------
// MAIN VOLUME
//
// GRAY:  RVOL below High threshold
// GREEN: High RVOL
// GOLD:  Extreme RVOL
//-----------------------------------------------------------------------------

plot(
     volume,
     title = "Volume",
     style = plot.style_columns,
     color = volumeColor,
     histbase = 0
)


//-----------------------------------------------------------------------------
// ACTIVE RVOL BASELINE
//-----------------------------------------------------------------------------

plot(
     showVolMA ? volBaseline : na,
     title = "RVOL Baseline",
     color = color.new(color.white, 50),
     linewidth = 1
)


//-----------------------------------------------------------------------------
// CURRENT BAR DIRECTIONAL DELTA
//-----------------------------------------------------------------------------

plot(
     showDelta ? volDelta : na,
     title = "Directional Delta",
     style = plot.style_histogram,
     color = deltaColor,
     linewidth = 2,
     histbase = 0
)


//-----------------------------------------------------------------------------
// ZERO LINE
//-----------------------------------------------------------------------------

hline(
     0,
     "Delta Zero",
     color = color.new(color.gray, 80),
     linestyle = hline.style_dotted
)


//=============================================================================
// DASHBOARD
//
// RVOL | BAR% | MODE | SAMP | BAR DΔ | BAR DΔ% | nB DΔ | nB DΔ% | VALID | Δ TF
//=============================================================================

var table dash = table.new(
     position.top_right,
     10,
     2,
     bgcolor = color.new(color.black, 20),
     frame_color = color.new(color.gray, 70),
     frame_width = 1
)


if barstate.islast

    if showDashboard

        //---------------------------------------------------------------------
        // DYNAMIC LOOKBACK HEADERS
        //
        // The header reports the number of bars actually used, not the number
        // requested. "57B DΔ" alongside "VALID 57/60" states both the scope of
        // the measurement and the shortfall against what was asked for.
        //---------------------------------------------------------------------

        string lookbackDeltaHeader =
             str.tostring(deltaBarsValid) +
             "B DΔ"

        string lookbackPctHeader =
             str.tostring(deltaBarsValid) +
             "B DΔ%"


        //---------------------------------------------------------------------
        // HEADERS
        //---------------------------------------------------------------------

        table.cell(
             dash,
             0,
             0,
             "RVOL",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             1,
             0,
             "BAR%",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             2,
             0,
             "MODE",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             3,
             0,
             "SAMP",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             4,
             0,
             "BAR DΔ",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             5,
             0,
             "BAR DΔ%",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             6,
             0,
             lookbackDeltaHeader,
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             7,
             0,
             lookbackPctHeader,
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             8,
             0,
             "VALID",
             text_color = color.silver,
             text_size = dashHeaderSize
        )

        table.cell(
             dash,
             9,
             0,
             "Δ TF",
             text_color = color.silver,
             text_size = dashHeaderSize
        )


        //---------------------------------------------------------------------
        // RVOL VALUE
        //---------------------------------------------------------------------

        color rvolTextColor = color.silver

        if extremeVolume
            rvolTextColor := extremeColor

        else if highVolume
            rvolTextColor := highColor

        string rvolText = "n/a"

        if not na(rvol)
            rvolText :=
                 str.tostring(rvol, "#.00") +
                 "x"

        table.cell(
             dash,
             0,
             1,
             rvolText,
             text_color = rvolTextColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // BAR COMPLETION
        //
        // Amber while the bar is materially unfinished, because that is exactly
        // when the RVOL cell to its left is understated. Not a fault state —
        // just a qualifier on the number beside it.
        //---------------------------------------------------------------------

        string barPctText = "—"
        color barPctColor = color.white

        if not na(barElapsedPct)
            barPctText :=
                 str.tostring(barElapsedPct, "#0") +
                 "%"

            if barIncomplete
                barPctColor := degradedColor

        table.cell(
             dash,
             1,
             1,
             barPctText,
             text_color = barPctColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // RVOL MODE
        //
        // TOD    = time-of-day baseline in use, target sample count met
        // TOD*   = time-of-day baseline in use, but short of target (amber)
        // ROLL*  = time-of-day requested, rolling used instead (amber)
        // ROLL   = rolling requested and used
        //---------------------------------------------------------------------

        string modeText = "ROLL"
        color modeColor = color.white

        if todActive
            modeText := todPartial ? "TOD*" : "TOD"

            if todPartial
                modeColor := degradedColor

        else if todDegraded
            modeText := "ROLL*"
            modeColor := degradedColor

        // Suffix marks which statistic is behind the number.
        modeText :=
             modeText +
             (useMedianBaseline ? " med" : " avg")

        table.cell(
             dash,
             2,
             1,
             modeText,
             text_color = modeColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // SAMPLE COUNT
        //
        // In time-of-day mode this is the count actually used, read against the
        // target:
        //
        //   "20+"   target met with margin — a further match existed beyond it
        //   "20"    target met exactly, with no margin left in the window
        //   "15/20" short of target; the shortfall is the number, not a suffix
        //
        // The three forms cannot collide: the scan only breaks on finding
        // target+1, so a count below target never carries a "+".
        //
        // Amber whenever the target was missed, matching the MODE cell beside
        // it — deeper amber logic is not needed because MODE already separates
        // "short of target" from "fell back entirely".
        //---------------------------------------------------------------------

        string sampleText =
             str.tostring(rvolLen)

        color sampleColor = color.white

        if wantTod

            if todSamples >= todTargetSamples
                sampleText :=
                     str.tostring(todSamples) +
                     (todOverflow ? "+" : "")

            else
                sampleText :=
                     str.tostring(todSamples) +
                     "/" +
                     str.tostring(todTargetSamples)

                sampleColor := degradedColor

        table.cell(
             dash,
             3,
             1,
             sampleText,
             text_color = sampleColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // CURRENT BAR DELTA
        //---------------------------------------------------------------------

        table.cell(
             dash,
             4,
             1,
             f_compact(volDelta),
             text_color = deltaColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // CURRENT BAR DELTA %
        //---------------------------------------------------------------------

        table.cell(
             dash,
             5,
             1,
             f_percent(deltaPct),
             text_color = deltaColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // CUMULATIVE DELTA
        //
        // Built from valid bars only, so no asterisk is needed — the number is
        // the measurement it claims to be. The header states its scope.
        //---------------------------------------------------------------------

        table.cell(
             dash,
             6,
             1,
             f_compact(lookbackDelta),
             text_color = deltaWindowEmpty ? degradedColor : lookbackDeltaColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // CUMULATIVE DELTA %
        //---------------------------------------------------------------------

        table.cell(
             dash,
             7,
             1,
             f_percent(lookbackDeltaPct),
             text_color = deltaWindowEmpty ? degradedColor : lookbackDeltaColor,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // VALID BARS IN WINDOW
        //
        // "60/60" means the full requested window had real intrabar data.
        // "57/60" means the cumulative figures are built from 57 bars — a
        // genuine measurement over a shorter span, not a contaminated one.
        // "0/60" means there is nothing to report and the cells read n/a.
        //---------------------------------------------------------------------

        table.cell(
             dash,
             8,
             1,
             str.tostring(deltaBarsValid) +
                 "/" +
                 str.tostring(deltaBarsRequested),
             text_color = deltaWindowShort ? degradedColor : color.white,
             text_size = dashValueSize
        )


        //---------------------------------------------------------------------
        // DELTA TIMEFRAME
        //
        // Reports the source actually used on this bar, across four states:
        //
        //   "1" / "15S"  intrabar data genuinely in use
        //   "Chart*"     a legitimate lower timeframe was requested but no
        //                data came back — usually the intrabar budget running
        //                out on older history (amber)
        //   "INVALID"    the manual timeframe is not lower than the chart, so
        //                intrabar delta was never possible; a setting to fix
        //                rather than a limit to accept (red)
        //   "Chart"      no lower timeframe exists at all, i.e. a 1-second
        //                chart. The proxy is the only option and this is the
        //                correct outcome (white)
        //---------------------------------------------------------------------

        string displayedDeltaTf = deltaTf
        color deltaTfColor = color.white

        if not ltfDataOk

            if deltaTfInvalid
                displayedDeltaTf := "INVALID"
                deltaTfColor := invalidColor

            else if deltaTfUnavailable
                displayedDeltaTf := "Chart"
                deltaTfColor := color.white

            else if deltaDegraded
                displayedDeltaTf := "Chart*"
                deltaTfColor := degradedColor

        table.cell(
             dash,
             9,
             1,
             displayedDeltaTf,
             text_color = deltaTfColor,
             text_size = dashValueSize
        )


    else

        table.clear(
             dash,
             0,
             0,
             9,
             1
        )


//=============================================================================
// ALERTS
//
// The two combined alerts require ltfDataOk. On a proxy bar the delta sign is
// just the bar's close-vs-open direction, so an ungated "extreme volume +
// positive delta" would fire on nothing more than an up bar on heavy volume —
// a claim about flow backed by a candle body. Ungated equivalents are provided
// below under names that say what they actually test.
//
// All titles say "Directional Delta". This is signed volume by candle
// direction on a lower timeframe, not bid/ask trade classification.
//=============================================================================

alertcondition(
     highVolume,
     title = "High RVOL",
     message = "High relative volume detected."
)

alertcondition(
     extremeVolume,
     title = "Extreme RVOL",
     message = "Extreme relative volume detected."
)

alertcondition(
     extremeVolume and ltfDataOk and volDelta > 0,
     title = "Extreme Volume + Positive Directional Delta (intrabar)",
     message = "Extreme relative volume with positive intrabar Directional Delta. Directional Delta signs each lower-timeframe bar by its candle direction and is not order flow."
)

alertcondition(
     extremeVolume and ltfDataOk and volDelta < 0,
     title = "Extreme Volume + Negative Directional Delta (intrabar)",
     message = "Extreme relative volume with negative intrabar Directional Delta. Directional Delta signs each lower-timeframe bar by its candle direction and is not order flow."
)

alertcondition(
     extremeVolume and close > open,
     title = "Extreme Volume + Up Bar (no intrabar required)",
     message = "Extreme relative volume on an up bar. Bar direction only — this does not test intrabar Directional Delta."
)

alertcondition(
     extremeVolume and close < open,
     title = "Extreme Volume + Down Bar (no intrabar required)",
     message = "Extreme relative volume on a down bar. Bar direction only — this does not test intrabar Directional Delta."
)
````
