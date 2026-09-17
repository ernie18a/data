<!-- tradingview-pine-id: PUB;756221c6df1647ee93b20ef4bdb9b5c4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NASDAQ Pre-Market Range Sweep [josseliani]

Source: https://www.tradingview.com/script/oN62W2RT-NASDAQ-Pre-Market-Range-Sweep-josseliani/

## Description

NASDAQ Pre-Market Range Sweep is an intraday trading assistant built around a familiar pre-market range sweep-and-reclaim setup. It automatically maps the NASDAQ range formed between 08:00 and 09:00 New York time, then monitors price behavior as activity increases ahead of the 09:30 cash-session open. The main idea is simple: after price sweeps liquidity beyond one side of the pre-market range, it may either continue moving away or return inside the range and move toward its midpoint or opposite boundary. Instead of requiring users to draw these levels manually and monitor every candle, the indicator plots the range, qualifies the sweep, waits for one of two entry confirmations, marks Entry and TP1, and collects historical statistics for the same setup.

This is an indicator, not a TradingView strategy. It does not place orders or manage positions.

WHY THIS RANGE

By default, the range is built from M1 candles between 08:00 and 09:00 in the America/New_York time zone.

This hour captures a defined part of the NASDAQ pre-market before the transition into the more active New York morning and the 09:30 cash-session open. Once this period is complete, the indicator fixes: → Range High → Range Low → the 50% midpoint

With the default one-minute delay, sweep monitoring begins at 09:01 New York time.

The range levels can remain visible for a fixed number of minutes or extend until the next daily range begins.

QUALIFIED LIQUIDITY SWEEP

A small wick through Range High or Range Low is not enough to qualify as a sweep.

The entire M1 candle must be outside the range: → for an upper sweep, the candle’s low must be above Range High → for a lower sweep, the candle’s high must be below Range Low

By default, the outside candle must also take the nearest previously confirmed pivot on the same side. This optional structural filter helps distinguish a more substantial liquidity event from a minor extension beyond the range.

A qualified sweep is not an immediate entry. The indicator then waits for one of two confirmations: Range Reclaim or Pivot Entry.

RANGE RECLAIM

Range Reclaim is used when price returns inside the pre-market range after the sweep.

For a BUY after a lower sweep, the indicator waits for a closed M1 candle that: → closes inside the range → has at least 70% of its body inside the range under the default settings

Once that candle has closed, its high becomes the confirmation level. BUY is displayed when price subsequently breaks that high.

For a SELL after an upper sweep, the logic is reversed: the acceptance candle closes inside the range, and SELL is confirmed when price subsequently breaks its low.

For Range Reclaim: → Entry is the high or low whose break confirmed the signal → TP1 · Partial close is placed at the 50% midpoint of the range

The midpoint is used as the first structural objective because price has returned inside the range but is not guaranteed to reach the opposite boundary.

PIVOT ENTRY

Pivot Entry is designed for cases where price continues significantly beyond the swept range boundary.

The search for this entry is activated only after price has moved at least one complete range width beyond that boundary.

The indicator then waits for a new confirmed pivot to form outside the range: → after a lower sweep, it looks for a confirmed pivot high below Range Low and a subsequent break above it → after an upper sweep, it looks for a confirmed pivot low above Range High and a subsequent break below it

For Pivot Entry: → Entry is placed at the broken pivot level → TP1 · Partial close is placed at the nearest boundary of the original range

If Range Reclaim and Pivot Entry are confirmed on the same M1 candle, only one signal is recorded.

SIGNAL CONTROL

The same acceptance candle or confirmed pivot cannot generate repeated signals.

After a BUY, another BUY requires a genuinely new low beyond the extreme of the previous outside movement. After a SELL, another SELL requires a genuinely new high. The number of signals per range is also limited by the Maximum signals per range setting.

Once price reaches the opposite boundary of the range, the current range cycle is considered complete, and no additional signals are generated until the next range.

CHART DISPLAY

The indicator can display: → Range High and Range Low → the 50% midpoint → confirmed BUY and SELL arrows → Entry → TP1 · Partial close → the statistics table

BUY and SELL arrows show that one of the two confirmation models has been completed. Entry marks the level whose break confirmed the setup. TP1 · Partial close marks the first structural reference: → the range midpoint for Range Reclaim → the nearest range boundary for Pivot Entry

The trade markup is an analytical reference. It does not represent an automatically executed order or a guaranteed target.

TIMEFRAMES

All signal calculations are performed using M1 data.

On M1, the indicator displays the original signals together with the Entry and TP1 markup. On M5 and M15, it displays markers cloned from the original M1 events. It does not recalculate the setup using M5 or M15 candles. This allows the same M1 signals to be viewed within a wider market context.

Timeframes above M15 are not supported.

STATISTICS TABLE

The statistics table provides a historical view of how price behaved after a qualified sweep. For each completed range, the table evaluates the first qualified sweep found within the observation window.

Return depth is normalized according to the width of each individual range: → 0% = the swept boundary → 50% = the range midpoint → 100% = the opposite boundary

OVERVIEW

Completed ranges — the number of completed observations. An observation ends when price reaches the opposite boundary or when the statistics look-forward window expires.

Qualified sweeps — the number of completed ranges in which a qualified sweep occurred. The percentage is calculated from all completed ranges.

Returned into range — the number and percentage of qualified sweeps followed by at least some movement back inside the range.

Full opposite edge — the number and percentage of qualified sweeps that eventually reached the opposite range boundary.

RETURN DEPTH

Average return (>0) — the average maximum return depth among sweeps that produced a positive return. A complete return is capped at 100%.

Minimum return (>0) — the smallest positive return recorded in the sample.

0–25%, 25–50%, 50–75%, 75–90%, and 90–99% — the distribution of incomplete returns that did not reach the opposite boundary.

These rows show how far price most often returned. They are useful because waiting for the opposite boundary in every case may not be realistic.

RISK & TIME

Average adverse excursion — the average maximum distance that price continued moving away from the range after the qualified sweep. It is expressed as a percentage of that range’s width.

Maximum adverse excursion — the largest such movement recorded in the available sample.

For example, a maximum adverse excursion of 600% means that, in the most extreme historical case, price continued approximately six range widths farther away before the observation ended.

Average time to 20% — the average number of minutes from the sweep until price completed a 20% return.

Average time to 50% — the average number of minutes from the sweep until price reached the range midpoint.

Average time to full — the average number of minutes from the sweep until price reached the opposite boundary.

These values help estimate how long the historical return process usually took rather than assuming that it should happen immediately.

BREAK-EVEN SIMULATION

BE armed / stopped / later full is a statistical simulation only.

It shows: → how many events reached the selected return depth and activated the hypothetical protection level → how many subsequently returned to that simulated protection level → how many of those stopped cases later reached the opposite boundary anyway

The simulation does not move a real stop, alter the signals, or manage a trade.

EXAMPLE OF READING THE TABLE

[image]https://www.tradingview.com/x/gfL5NXu4/ [/image]

The table shown in this example contains:

→ Completed ranges: 18
→ Qualified sweeps: 18 | 100%
→ Returned into range: 16 | 88.89%
→ Full opposite edge: 5 | 27.78%

Completed ranges: 18

The indicator completed 18 statistical observations on the available chart history.

An observation is considered complete when either:

→ price reaches the opposite boundary of the range
→ the Statistics look-forward window expires

This number does not represent 18 trades. It represents 18 completed range observations.

Qualified sweeps: 18 | 100%

A qualified sweep was found in all 18 completed observations.

The 100% is calculated as:

→ 18 qualified sweeps ÷ 18 completed ranges

For the statistics, only the first qualified sweep found within each range observation is evaluated.

Returned into range: 16 | 88.89%

After 16 of the 18 qualified sweeps, price made at least some positive movement back inside the range.

The percentage is calculated as:

→ 16 returns ÷ 18 qualified sweeps = 88.89%

This does not mean that all 16 events reached the midpoint or the opposite boundary. It means only that price moved back inside the range by more than 0%.

Full opposite edge: 5 | 27.78%

In 5 of the 18 qualified sweep events, price moved through the entire range and reached its opposite boundary.

The percentage is calculated as:

→ 5 full returns ÷ 18 qualified sweeps = 27.78%

This is an important distinction. In this sample, price returned inside the range in 88.89% of the events, but it completed the full journey to the opposite boundary in only 27.78%.

The table therefore helps avoid the assumption that every successful return should be held all the way to the other side of the range.

RETURN DEPTH

The same example shows:

→ Average return (>0): 66.2%
→ Minimum return (>0): 3.33%

Average return (>0): 66.2%

Among the 16 events that produced a positive return, the average maximum return depth was 66.2% of the corresponding range width.

The calculation includes partial returns and full returns. A return that reaches the opposite boundary is capped at 100%.

This does not mean that every event returned 66.2%. It means that 66.2% was the average maximum depth across the positive-return sample.

Minimum return (>0): 3.33%

The smallest positive return in the sample was only 3.33% of the range width.

Events with no positive return are not included in this minimum calculation. This row shows the weakest recorded return that was still greater than zero.

INCOMPLETE RETURN DISTRIBUTION

The example contains:

→ 0–25%: 4 | 30.77%
→ 25–50%: 2 | 15.38%
→ 50–75%: 5 | 38.46%
→ 75–90%: 2 | 15.38%
→ 90–99%: 0 | 0%

Five events reached the full opposite boundary and are therefore excluded from these incomplete-return groups.

That leaves:

→ 18 qualified sweeps − 5 full returns = 13 incomplete returns

The percentages in this section are calculated from these 13 incomplete events, not from all 18 qualified sweeps.

0–25%: 4 | 30.77%

Four of the 13 incomplete observations returned by less than 25% of the range width.

This group also includes events with a 0% return. Therefore, not every event in the 0–25% group necessarily moved back inside the range.

25–50%: 2 | 15.38%

Two incomplete observations returned through at least 25% of the range but did not reach its midpoint.

50–75%: 5 | 38.46%

Five incomplete observations reached the midpoint and continued beyond it, but did not reach 75% of the range.

This was the largest incomplete-return group in the example.

75–90%: 2 | 15.38%

Two observations returned through at least 75% of the range but stopped before reaching 90%.

90–99%: 0 | 0%

None of the incomplete observations stopped between 90% and 99%.

Events that reached 100% are counted separately under Full opposite edge.

ADVERSE EXCURSION

The example shows:

→ Average adverse excursion: 189.34%
→ Maximum adverse excursion: 665.07%

Adverse excursion measures how far price continued moving away from the swept boundary after the qualified sweep.

It is also normalized according to the width of the corresponding range.

Average adverse excursion: 189.34%

On average, price traveled approximately 1.89 range widths farther away from the swept boundary during the observed events.

This number shows why a liquidity sweep should not automatically be treated as an immediate reversal or as an entry without confirmation.

Maximum adverse excursion: 665.07%

In the most extreme observation, price continued approximately 6.65 range widths beyond the swept boundary.

This does not mean that every setup requires such a large stop. It shows the largest historical extension found in the available sample and demonstrates that price can continue significantly farther after a sweep.

TIME STATISTICS

The example shows:

→ Average time to 20%: 14.86 min
→ Average time to 50%: 23.75 min
→ Average time to full: 30 min

These values are measured from the qualified sweep.

Average time to 20%: 14.86 min

Among the observations that reached a 20% return, the average time required was 14.86 minutes.

Events that never reached 20% are not included in this average.

Average time to 50%: 23.75 min

Among the observations that reached the range midpoint, the average time required was 23.75 minutes.

Events that never reached 50% are not included.

Average time to full: 30 min

Among the five observations that reached the opposite boundary, the average time required to complete the full return was 30 minutes.

This does not mean that a full return should always occur within 30 minutes. It describes only the average of the completed full-return cases in this sample.

BREAK-EVEN SIMULATION

The example shows:

→ BE armed / stopped / later full: 14 / 10 / 4

With the default 20% activation setting, this means:

→ 14 events reached at least a 20% return and activated the hypothetical protection level
→ 10 of those events subsequently returned to the simulated protection level
→ 4 of those 10 events later reached the opposite boundary anyway

This row helps examine whether protecting a position after the first part of the return might remove exposure from some events that would later continue to the full target.

It is a statistical simulation only. It does not place a stop, move a stop, change the signals, or manage a real position.

WHAT THE TABLE TELLS ME

In this particular sample, the table shows that a return inside the range occurred much more frequently than a complete move to the opposite boundary.

It also shows:

→ how deep the average return was
→ how shallow the weakest positive return was
→ where incomplete returns most often stopped
→ how long different stages of the return usually took
→ how far price sometimes continued away from the range before returning or before the observation ended

The purpose of the table is not to prove that the setup will work in the future. It provides a structured statistical view of the price behavior visible on the current chart, symbol, data feed, and settings.

HOW I USE IT

I use the indicator on a NASDAQ M1 chart and first wait for the pre-market range to be completed.

After 09:00 New York time, I watch for a qualified sweep of one of the boundaries. The sweep itself is not my entry.

I then wait for either: → a confirmed return inside the range through Range Reclaim → a confirmed pivot break after a deeper movement outside the range

The arrow shows that one of these confirmation conditions has been completed. Entry marks the confirmation level and the potential trade-entry level. TP1 · Partial close marks the first structural area where a partial exit or closer observation of the price reaction may be considered.

The default settings and presets are built for the NASDAQ sweep-and-reclaim strategy around the New York pre-market open. The same logic can also be used on other instruments, including FX pairs and gold. On gold, you can keep the same New York pre-market range; the market will simply produce its own statistics. On EURUSD, for example, you can build a London session window by adjusting Range start hour / minute and Range length (still entered in New York time).

Use the statistics table to judge how clean the setup looks on that symbol and those settings, and build the variation that fits you: → try different instruments and currency pairs → try different chart timeframes → choose your own pre-market hour and range length → decide from the table whether the setup is worth trading there

MAIN SETTINGS

Range start hour / minute — sets the beginning of the range in New York time.

Range length — sets the duration of the range.

Start watching after range end — sets the delay before sweep monitoring begins. The default value of one minute starts monitoring at 09:01.

Statistics look-forward window — sets how long each sweep is observed for the statistics table.

Signal window mode — limits signal generation to a fixed period or allows it to continue until the next range.

Signal window — sets the duration of the fixed signal-search period.

Maximum signals per range — limits the number of confirmed signals for one range.

Minimum reclaim body inside range — sets how much of the closed acceptance candle’s body must be inside the range.

Require nearest confirmed pivot sweep — requires the outside candle to take the nearest confirmed pivot.

Pivot strength — controls the size and confirmation delay of local pivots.

Level extension — extends the range levels for a fixed period or until the next range.

Trade markup length — controls the length of the Entry and TP1 lines.

ORIGINALITY

Pre-market ranges, liquidity sweeps, and confirmed pivots are established market concepts. The originality of this implementation lies in how these elements are combined and managed as one complete process.

The script: → requires the entire M1 candle to move outside the range → can require the nearest confirmed pivot to be swept → separates the liquidity event from the entry confirmation → provides two distinct confirmation models: Range Reclaim and Pivot Entry → activates Pivot Entry only after a one-range-width excursion → prevents the same candle or pivot from producing repeated signals → requires a new external extreme before another same-direction signal can occur → terminates the cycle after price reaches the opposite boundary → includes a normalized statistics table designed specifically to evaluate this range-sweep setup

The table is not intended to present a strategy win rate. It provides a statistical view of the underlying idea: how often qualified sweeps occurred, how often price returned inside the range, how frequently it reached the opposite boundary, the average and minimum return depth, the time required for different stages of the return, and the adverse distance price sometimes traveled before returning or before the observation ended.

This helps users evaluate the historical behavior of the setup instead of assuming that every sweep must produce a complete return or that every return should take the same amount of time.

The indicator is published free and open-source so that users can inspect the calculations and verify how the signals and statistics are produced.

LIMITATIONS

Results can differ between NASDAQ symbols, exchanges, and data feeds because the calculations depend on M1 OHLC data.

Confirmed pivots require bars on their right side and therefore become available only after a structural confirmation delay.

M5 and M15 display cloned M1 events, not independently calculated higher-timeframe signals.

The statistics describe only the available historical sample under the current settings. They are not a strategy report and do not guarantee future results.

The indicator does not account for commissions, slippage, position size, or individual stop-loss placement. Entry, TP1, and the break-even simulation are analytical references, not automated trade-management instructions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © josseliani
//@version=6
indicator("NASDAQ Pre-Market Range Sweep [josseliani]", shorttitle="NASDAQ PM Range Sweep", overlay=true, max_lines_count=500, max_labels_count=500)
//=============================================================================
// Core settings
//=============================================================================
const string TZ = "America/New_York"
const string ENGINE_TF = "1"
int chartTimeframeSeconds = timeframe.in_seconds()
bool chartIsM1 = chartTimeframeSeconds == 60
bool chartIsM5 = chartTimeframeSeconds == 300
bool chartIsM15 = chartTimeframeSeconds == 900
if barstate.isfirst and not (timeframe.isintraday and (chartIsM1 or chartIsM5 or chartIsM15))
    runtime.error("Use an M1, M5 or M15 chart. Signal logic is calculated on M1; M5/M15 show cloned M1 markers only.")
// The calculation engine always runs on 1-minute data.
// M1 displays the complete trade markup. M5/M15 display cloned M1 markers only.
//=============================================================================
// Inputs
//=============================================================================
string grpR = "Range"
int rangeStartHour = input.int(8, "Range start hour (New York)", minval=0, maxval=23, group=grpR)
int rangeStartMinute = input.int(0, "Range start minute", minval=0, maxval=59, group=grpR)
int rangeLenMinutes = input.int(60, "Range length (minutes)", minval=1, maxval=360, group=grpR)
string grpE = "Evaluation"
int startDelayMin = input.int(1, "Start watching after range end (minutes)", minval=0, maxval=60, group=grpE)
int lookForwardMin = input.int(120, "Statistics look-forward window (minutes)", minval=1, maxval=720, group=grpE)
string grpSig = "Signals"
string signalWindowMode = input.string("Fixed minutes", "Signal window mode", options=["Fixed minutes", "Until next range"], group=grpSig)
int signalWindowMinutes = input.int(120, "Signal window (minutes)", minval=1, maxval=1440, group=grpSig)
int maxSignalsPerRange = input.int(3, "Maximum signals per range", minval=1, maxval=10, group=grpSig)
float minBodyInsidePct = input.float(70.0, "Minimum reclaim body inside range (%)", minval=1.0, maxval=100.0, step=5.0, group=grpSig)
const float minPivotExcursionRanges = 1.0
string grpS = "Sweep qualification"
bool requirePivotSweep = input.bool(true, "Require nearest confirmed pivot sweep", group=grpS, tooltip="When enabled, the full M1 candle outside the range must also take the nearest confirmed pivot on the corresponding side. This filters weaker range extensions and normally produces fewer, more selective sweep events.")
int pivotLen = input.int(5, "Pivot strength (left/right bars)", minval=1, maxval=10, group=grpS, tooltip="Number of bars required on each side to confirm a pivot. Lower values detect smaller local pivots and produce more setups. Higher values require more significant structure and produce fewer setups with later pivot confirmation. This setting affects both sweep qualification and the optional post-sweep Pivot Entry route.")
string grpBE = "Break-even statistics simulation"
float beTriggerPct = input.float(0.20, "Arm BE after return >= X (0.20 = 20%)", minval=0.01, maxval=0.99, step=0.01, group=grpBE, tooltip="Statistics only. Arms a hypothetical break-even stop after price has returned this fraction of the range toward the opposite edge. For example, 0.20 means 20% of the range. This setting does not change signals, draw a live stop or manage a trade.")
int beBufferTicks = input.int(0, "BE buffer (ticks)", minval=0, maxval=50, group=grpBE, tooltip="Statistics only. Adds this number of minimum-price ticks to the simulated break-even level. Zero uses the original sweep boundary. This setting does not place or move an actual stop order.")
string grpV = "Visuals"
bool showLines = input.bool(true, "Show range levels (High / Low / 50%)", group=grpV)
string levelExtension = input.string("Until next range", "Level extension", options=["Until next range", "Fixed minutes"], group=grpV)
int extensionMinutes = input.int(240, "Fixed extension (minutes)", minval=1, maxval=10000, group=grpV)
bool showSignals = input.bool(true, "Show confirmed sweep signals", group=grpV)
bool showTradeMarkup = input.bool(true, "Show Entry / TP1 markup", group=grpV)
int tradeMarkupMinutes = input.int(60, "Trade markup length (minutes)", minval=1, maxval=1440, group=grpV)
bool showStats = input.bool(true, "Show statistics table", group=grpV)
//=============================================================================
// 1-minute calculation engine
//=============================================================================
f_engine(int _rangeStartHour, int _rangeStartMinute, int _rangeLenMinutes, int _startDelayMin, int _lookForwardMin, bool _signalUntilNextRange, int _signalWindowMinutes, int _maxSignalsPerRange, float _minBodyInsidePct, float _minPivotExcursionRanges, bool _requirePivotSweep, int _pivotLen, float _beTriggerPct, int _beBufferTicks) =>
    // Range state
    var float rHi = na
    var float rLo = na
    // Event state
    var bool active = false
    var bool finished = false
    var int watchStartTime = na
    var float evHi = na
    var float evLo = na
    var float evMid = na
    var float evRng = na
    // 0 = none, 1 = upper sweep, -1 = lower sweep, 2 = both sides on one M1 bar
    var int firstSide = 0
    var int sweepTime = na
    var int sweepBarIndex = na
    var float sweepPrice = na
    // Nearest confirmed pivots available to the left.
    var float lastPivotHigh = na
    var float lastPivotLow = na
    // Independent signal engine.
    // It keeps scanning after the statistics event has finished.
    var int signalWindowStartTime = na
    var int signalsThisRange = 0
    // Terminal state for the current range.
    // Once price reaches the OPPOSITE range boundary after a qualified sweep,
    // the objective is considered complete and NO more signals are allowed
    // until the next range is created.
    var bool signalObjectiveDone = false
    // Structural signal-cycle gate.
    // After a BUY below Range Low, no more BUY signals are allowed while
    // price simply travels upward toward Range Low. Another BUY is allowed
    // only after price makes a NEW LOW below the low of the previous BUY signal.
    // Touching Range Low completes that outside excursion and resets the gate.
    // SELL is mirrored around Range High.
    var bool buyCycleLocked = false
    var bool sellCycleLocked = false
    // Invalidation anchors are NOT the low/high of the signal candle.
    // They are the extreme of the ENTIRE outside excursion that produced
    // the previous signal. A new same-side setup cannot start until that
    // whole excursion extreme is actually broken.
    var float buyInvalidationLow = na
    var float sellInvalidationHigh = na
    // Signal sweep context: 1 = upper sweep -> SELL, -1 = lower sweep -> BUY.
    var int sigSide = 0
    var int sigSweepBarIndex = na
    // Maximum excursion away from the swept range boundary.
    // Pivot-entry signals are allowed only after price has travelled
    // at least X complete range widths away from that boundary.
    var float sigLowestAfterSweep = na
    var float sigHighestAfterSweep = na
    // One reclaim attempt per actual range-entry episode.
    // It resets only after price closes back outside the swept boundary.
    var bool sigReclaimEpisodeActive = false
    // Reclaim candidate: confirmed acceptance back inside the range.
    var bool sigReclaimReady = false
    var int sigReclaimBarIndex = na
    var float sigReclaimHigh = na
    var float sigReclaimLow = na
    // Latest confirmed structural pivot formed after the signal sweep
    // and still outside the range. Each pivot can trigger only once.
    var float sigPostPivotHigh = na
    var float sigPostPivotLow = na
    var int sigPostPivotHighConfirmBar = na
    var int sigPostPivotLowConfirmBar = na
    var int signalCount = 0
    var int lastSignalSide = 0
    var int lastSignalTime = na
    // 1 = Range Reclaim, 2 = Pivot Entry.
    var int lastSignalType = 0
    var float lastSignalEntry = na
    var float lastSignalTP1 = na
    // Return depth
    var float bestProg = 0.0
    var float minLowSeen = na
    var float maxHighSeen = na
    // MAE
    var float maxHighAfterSweep = na
    var float minLowAfterSweep = na
    // Time-to-level
    var int tHit20 = na
    var int tHit50 = na
    var int tHitFull = na
    // BE simulation
    var bool beArmed = false
    var bool beStopped = false
    var bool fullAfterBEStop = false
    var int beArmBarIndex = na
    // Statistics
    var int totalRanges = 0
    var int sweptRanges = 0
    var int returnedAny = 0
    var int fullOpp = 0
    var int b0_25 = 0
    var int b25_50 = 0
    var int b50_75 = 0
    var int b75_90 = 0
    var int b90_99 = 0
    var float sumProg = 0.0
    var int cntProg = 0
    var float minProg = na
    var float sumMAE = 0.0
    var int cntMAE = 0
    var float maxMAE = na
    var float sumT20 = 0.0
    var int cntT20 = 0
    var float sumT50 = 0.0
    var int cntT50 = 0
    var float sumTF = 0.0
    var int cntTF = 0
    var int beArmedCnt = 0
    var int beStopCnt = 0
    var int beStopThenFullCnt = 0
    // Range version lets the chart context detect each newly completed range.
    var int rangeCount = 0
    var int lastRangeEndTime = na
    var float lastRangeHigh = na
    var float lastRangeLow = na
    var float lastRangeMid = na
    // New York minute-of-day.
    int mday = hour(time, TZ) * 60 + minute(time, TZ)
    int startM = _rangeStartHour * 60 + _rangeStartMinute
    int rawEndM = startM + _rangeLenMinutes
    int endM = rawEndM % 1440
    bool crossesMidnight = rawEndM >= 1440
    bool inRange = crossesMidnight ? (mday >= startM or mday < endM) : (mday >= startM and mday < endM)
    bool rangeStart = inRange and not inRange[1]
    bool rangeEnd = not inRange and inRange[1]
    // Confirmed pivots only: no future-looking pivot filter.
    float confirmedPivotHigh = ta.pivothigh(high, _pivotLen, _pivotLen)
    float confirmedPivotLow = ta.pivotlow(low, _pivotLen, _pivotLen)
    if not na(confirmedPivotHigh)
        lastPivotHigh := confirmedPivotHigh
    if not na(confirmedPivotLow)
        lastPivotLow := confirmedPivotLow
    // Build the current range from M1 bars.
    if rangeStart
        rHi := high
        rLo := low
    else if inRange
        rHi := math.max(rHi, high)
        rLo := math.min(rLo, low)
    int msLook = _lookForwardMin * 60 * 1000
    bool expired = active and not finished and not na(watchStartTime) and time >= watchStartTime + msLook
    bool canWatch = active and not finished and not na(watchStartTime) and time >= watchStartTime and not expired
    if canWatch
        // Qualified sweep:
        // the entire M1 candle must be outside the range.
        bool fullOutsideUp = low > evHi
        bool fullOutsideDn = high < evLo
        // Optional pivot-quality filter.
        bool pivotUpOk = not _requirePivotSweep or (not na(lastPivotHigh) and high > lastPivotHigh)
        bool pivotDnOk = not _requirePivotSweep or (not na(lastPivotLow) and low < lastPivotLow)
        bool validUpperSweep = fullOutsideUp and pivotUpOk
        bool validLowerSweep = fullOutsideDn and pivotDnOk
        // Lock the first qualified sweep side.
        if firstSide == 0
            if validUpperSweep
                firstSide := 1
                sweepTime := time
                sweepBarIndex := bar_index
                sweepPrice := evHi
                minLowSeen := low
                maxHighAfterSweep := high
                minLowAfterSweep := low
            else if validLowerSweep
                firstSide := -1
                sweepTime := time
                sweepBarIndex := bar_index
                sweepPrice := evLo
                maxHighSeen := high
                maxHighAfterSweep := high
                minLowAfterSweep := low


        // Track movement after the qualified sweep.
        if firstSide == 1
            maxHighAfterSweep := na(maxHighAfterSweep) ? high : math.max(maxHighAfterSweep, high)
            minLowSeen := na(minLowSeen) ? low : math.min(minLowSeen, low)
        else if firstSide == -1
            minLowAfterSweep := na(minLowAfterSweep) ? low : math.min(minLowAfterSweep, low)
            maxHighSeen := na(maxHighSeen) ? high : math.max(maxHighSeen, high)
        // Return progress toward the opposite edge.
        if firstSide == 1 and not na(minLowSeen)
            float lowClamped = math.max(minLowSeen, evLo)
            float prog = (evHi - lowClamped) / evRng
            prog := math.min(math.max(prog, 0.0), 1.0)
            bestProg := math.max(bestProg, prog)
        else if firstSide == -1 and not na(maxHighSeen)
            float highClamped = math.min(maxHighSeen, evHi)
            float prog = (highClamped - evLo) / evRng
            prog := math.min(math.max(prog, 0.0), 1.0)
            bestProg := math.max(bestProg, prog)
        // Time-to-level from the first sweep.
        if not na(sweepTime)
            int tFromSweepMin = int(math.floor((time - sweepTime) / 60000))
            if na(tHit20) and bestProg >= 0.20
                tHit20 := tFromSweepMin
            if na(tHit50) and bestProg >= 0.50
                tHit50 := tFromSweepMin
            if na(tHitFull) and bestProg >= 1.0
                tHitFull := tFromSweepMin
        // Break-even simulation.
        // BE is checked only from the M1 bar AFTER it becomes armed.
        if firstSide == 1 or firstSide == -1
            if not beArmed and bestProg >= _beTriggerPct
                beArmed := true
                beArmBarIndex := bar_index
                beArmedCnt += 1
            float buf = _beBufferTicks * syminfo.mintick
            if beArmed and not beStopped and not na(beArmBarIndex) and bar_index > beArmBarIndex
                if firstSide == 1 and high >= sweepPrice + buf
                    beStopped := true
                    beStopCnt += 1
                else if firstSide == -1 and low <= sweepPrice - buf
                    beStopped := true
                    beStopCnt += 1
            if beStopped and not fullAfterBEStop and bestProg >= 1.0
                fullAfterBEStop := true
                beStopThenFullCnt += 1
    //=========================================================================
    // Independent signal window
    //=========================================================================
    int signalWindowMs = _signalWindowMinutes * 60 * 1000
    bool signalTimeStarted = not na(signalWindowStartTime) and time >= signalWindowStartTime
    bool fixedSignalExpired = not _signalUntilNextRange and signalTimeStarted and time >= signalWindowStartTime + signalWindowMs
    bool canSignal = signalTimeStarted and not fixedSignalExpired and not signalObjectiveDone and signalsThisRange < _maxSignalsPerRange and not na(evHi) and not na(evLo)
    if canSignal
        // A qualified liquidity sweep is strict:
        // the entire M1 candle must be outside the range.
        bool sigFullOutsideUp = low > evHi
        bool sigFullOutsideDn = high < evLo
        // Optional nearest-left confirmed pivot filter.
        bool sigPivotUpOk = not _requirePivotSweep or (not na(lastPivotHigh) and high > lastPivotHigh)
        bool sigPivotDnOk = not _requirePivotSweep or (not na(lastPivotLow) and low < lastPivotLow)
        bool sigValidUpperSweep = sigFullOutsideUp and sigPivotUpOk
        bool sigValidLowerSweep = sigFullOutsideDn and sigPivotDnOk
        // Start the first signal context. If price later fully sweeps the
        // opposite side, switch the context and begin looking the other way.
        bool startSellContext = sigValidUpperSweep and sigSide != 1 and (sigSide == 0 or sigSide == -1)
        bool startBuyContext = sigValidLowerSweep and sigSide != -1 and (sigSide == 0 or sigSide == 1)
        if startSellContext
            sigSide := 1
            sigSweepBarIndex := bar_index
            sigLowestAfterSweep := na
            sigHighestAfterSweep := high
            sigReclaimEpisodeActive := false
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
            sigPostPivotHigh := na
            sigPostPivotLow := na
            sigPostPivotHighConfirmBar := na
            sigPostPivotLowConfirmBar := na
        else if startBuyContext
            sigSide := -1
            sigSweepBarIndex := bar_index
            sigLowestAfterSweep := low
            sigHighestAfterSweep := na
            sigReclaimEpisodeActive := false
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
            sigPostPivotHigh := na
            sigPostPivotLow := na
            sigPostPivotHighConfirmBar := na
            sigPostPivotLowConfirmBar := na
        // Reclaim quality is calculated directly from the PREVIOUS, fully
        // closed M1 bar. This avoids barstate.isconfirmed in request.*() calls.
        float sigPreviousBodyLow = math.min(open[1], close[1])
        float sigPreviousBodyHigh = math.max(open[1], close[1])
        float sigPreviousBodySize = math.max(sigPreviousBodyHigh - sigPreviousBodyLow, syminfo.mintick)
        float sigPreviousBodyOverlap = math.max(math.min(sigPreviousBodyHigh, evHi) - math.max(sigPreviousBodyLow, evLo), 0.0)
        float sigPreviousBodyInsidePct = 100.0 * sigPreviousBodyOverlap / sigPreviousBodySize
        bool sigPreviousCloseInsideRange = close[1] < evHi and close[1] > evLo
        bool sigPreviousQualifiedReclaim = sigPreviousCloseInsideRange and sigPreviousBodyInsidePct >= _minBodyInsidePct
        // A range-entry episode ends only after a CLOSED M1 bar returns outside
        // the same boundary from which the sweep came.
        bool sigEpisodeResetBuy = sigSide == -1 and close[1] < evLo
        bool sigEpisodeResetSell = sigSide == 1 and close[1] > evHi
        if sigEpisodeResetBuy or sigEpisodeResetSell
            sigReclaimEpisodeActive := false
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
        // Arm ONE reclaim setup from the previous closed acceptance candle.
        // It is ready before the current M1 bar is checked for a high/low break.
        if signalsThisRange < _maxSignalsPerRange and not sigReclaimEpisodeActive and not sigReclaimReady and sigPreviousQualifiedReclaim and not na(sigSweepBarIndex) and bar_index - 1 > sigSweepBarIndex
            sigReclaimEpisodeActive := true
            sigReclaimReady := true
            sigReclaimBarIndex := bar_index - 1
            sigReclaimHigh := high[1]
            sigReclaimLow := low[1]
        // Confirm post-sweep structural pivots outside the range.
        int sigPivotBarIndex = bar_index - _pivotLen
        if sigSide == -1 and not na(confirmedPivotHigh) and not na(sigSweepBarIndex) and sigPivotBarIndex > sigSweepBarIndex and confirmedPivotHigh < evLo
            sigPostPivotHigh := confirmedPivotHigh
            sigPostPivotHighConfirmBar := bar_index
        if sigSide == 1 and not na(confirmedPivotLow) and not na(sigSweepBarIndex) and sigPivotBarIndex > sigSweepBarIndex and confirmedPivotLow > evHi
            sigPostPivotLow := confirmedPivotLow
            sigPostPivotLowConfirmBar := bar_index
        // Track maximum excursion away from the swept range boundary.
        if sigSide == -1
            sigLowestAfterSweep := na(sigLowestAfterSweep) ? low : math.min(sigLowestAfterSweep, low)
        else if sigSide == 1
            sigHighestAfterSweep := na(sigHighestAfterSweep) ? high : math.max(sigHighestAfterSweep, high)
        float sigRequiredExcursion = evRng * _minPivotExcursionRanges
        bool sigPivotExcursionBuyReady = sigSide == -1 and not na(sigLowestAfterSweep) and (evLo - sigLowestAfterSweep) >= sigRequiredExcursion
        bool sigPivotExcursionSellReady = sigSide == 1 and not na(sigHighestAfterSweep) and (sigHighestAfterSweep - evHi) >= sigRequiredExcursion
        // One stored pivot can trigger only once.
        // IMPORTANT: the minimum-excursion filter applies ONLY to Pivot Entry.
        bool sigPivotBreakBuy = sigPivotExcursionBuyReady and not na(sigPostPivotHigh) and not na(sigPostPivotHighConfirmBar) and bar_index > sigPostPivotHighConfirmBar and high > sigPostPivotHigh
        bool sigPivotBreakSell = sigPivotExcursionSellReady and not na(sigPostPivotLow) and not na(sigPostPivotLowConfirmBar) and bar_index > sigPostPivotLowConfirmBar and low < sigPostPivotLow
        // The acceptance candle must be CLOSED before it can become a candidate.
        // After that, its trigger remains live during the same range-entry episode.
        // The actual high/low break is detected immediately, without waiting for
        // the trigger candle to close.
        bool sigReclaimBreakBuy = sigSide == -1 and sigReclaimReady and bar_index > sigReclaimBarIndex and high > sigReclaimHigh
        bool sigReclaimBreakSell = sigSide == 1 and sigReclaimReady and bar_index > sigReclaimBarIndex and low < sigReclaimLow
        // Structural re-entry gate.
        // A same-side signal is locked until the ENTIRE excursion that created
        // the previous signal is invalidated by a true new extreme.
        bool buyCycleInvalidated = buyCycleLocked and not na(buyInvalidationLow) and low < buyInvalidationLow
        bool sellCycleInvalidated = sellCycleLocked and not na(sellInvalidationHigh) and high > sellInvalidationHigh
        // If the previous BUY structure is invalidated by a real lower low,
        // erase every stale BUY trigger and begin a fresh setup from THIS bar.
        if buyCycleInvalidated
            buyCycleLocked := false
            buyInvalidationLow := na
            sigSide := -1
            sigSweepBarIndex := bar_index
            sigLowestAfterSweep := low
            sigHighestAfterSweep := na
            sigReclaimEpisodeActive := false
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
            sigPostPivotHigh := na
            sigPostPivotHighConfirmBar := na
            sigPostPivotLow := na
            sigPostPivotLowConfirmBar := na
        // Mirrored invalidation for SELL.
        if sellCycleInvalidated
            sellCycleLocked := false
            sellInvalidationHigh := na
            sigSide := 1
            sigSweepBarIndex := bar_index
            sigHighestAfterSweep := high
            sigLowestAfterSweep := na
            sigReclaimEpisodeActive := false
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
            sigPostPivotLow := na
            sigPostPivotLowConfirmBar := na
            sigPostPivotHigh := na
            sigPostPivotHighConfirmBar := na
        // FINAL RANGE OBJECTIVE:
        // BUY context starts after a qualified lower sweep. If price later
        // reaches the OPPOSITE edge (Range High), the whole range is complete.
        // SELL context is mirrored: reaching Range Low completes the range.
        bool fullRangeTargetBuy = sigSide == -1 and high >= evHi
        bool fullRangeTargetSell = sigSide == 1 and low <= evLo
        if fullRangeTargetBuy or fullRangeTargetSell
            signalObjectiveDone := true
            // Clear every active setup so nothing stale can print later.
            buyCycleLocked := false
            sellCycleLocked := false
            buyInvalidationLow := na
            sellInvalidationHigh := na
            sigSide := 0
            sigSweepBarIndex := na
            sigLowestAfterSweep := na
            sigHighestAfterSweep := na
            sigReclaimEpisodeActive := false
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
            sigPostPivotHigh := na
            sigPostPivotLow := na
            sigPostPivotHighConfirmBar := na
            sigPostPivotLowConfirmBar := na
        bool buyStructureReady = not signalObjectiveDone and not buyCycleLocked
        bool sellStructureReady = not signalObjectiveDone and not sellCycleLocked
        bool sigRawBuyTrigger = sigPivotBreakBuy or sigReclaimBreakBuy
        bool sigRawSellTrigger = sigPivotBreakSell or sigReclaimBreakSell
        bool sigBuyTrigger = sigRawBuyTrigger and buyStructureReady and not signalObjectiveDone
        bool sigSellTrigger = sigRawSellTrigger and sellStructureReady and not signalObjectiveDone
        // If pivot and reclaim trigger on the same M1 candle, count ONE entry.
        if sigBuyTrigger and signalsThisRange < _maxSignalsPerRange
            bool buyByReclaim = sigReclaimBreakBuy
            signalCount += 1
            signalsThisRange += 1
            lastSignalSide := 1
            lastSignalTime := time
            lastSignalType := buyByReclaim ? 1 : 2
            lastSignalEntry := buyByReclaim ? sigReclaimHigh : sigPostPivotHigh
            lastSignalTP1 := buyByReclaim ? evMid : evLo
            buyCycleLocked := true
            buyInvalidationLow := na(sigLowestAfterSweep) ? low : math.min(sigLowestAfterSweep, low)
        else if sigSellTrigger and signalsThisRange < _maxSignalsPerRange
            bool sellByReclaim = sigReclaimBreakSell
            signalCount += 1
            signalsThisRange += 1
            lastSignalSide := -1
            lastSignalTime := time
            lastSignalType := sellByReclaim ? 1 : 2
            lastSignalEntry := sellByReclaim ? sigReclaimLow : sigPostPivotLow
            lastSignalTP1 := sellByReclaim ? evMid : evHi
            sellCycleLocked := true
            sellInvalidationHigh := na(sigHighestAfterSweep) ? high : math.max(sigHighestAfterSweep, high)
        // IMPORTANT: a pivot is consumed on its first break.
        // This prevents repeated signals from the same already-broken pivot.
        // Consumption happens after the entry price has been stored.
        if sigPivotBreakBuy
            sigPostPivotHigh := na
            sigPostPivotHighConfirmBar := na
        if sigPivotBreakSell
            sigPostPivotLow := na
            sigPostPivotLowConfirmBar := na
        // A reclaim trigger is consumed once. If it has not triggered, it stays
        // live until price closes back outside the swept boundary, the signal
        // window ends, the objective completes, or a new range is created.
        if sigReclaimBreakBuy or sigReclaimBreakSell
            sigReclaimReady := false
            sigReclaimBarIndex := na
            sigReclaimHigh := na
            sigReclaimLow := na
    // Finalize on full return or time expiration.
    bool doFinalize = active and not finished and (bestProg >= 1.0 or expired)
    if doFinalize
        finished := true
        totalRanges += 1
        if firstSide != 0
            sweptRanges += 1
            if bestProg > 0
                returnedAny += 1
                sumProg += bestProg
                cntProg += 1
                minProg := na(minProg) ? bestProg : math.min(minProg, bestProg)
            if bestProg >= 1.0
                fullOpp += 1
            else if bestProg < 0.25
                b0_25 += 1
            else if bestProg < 0.50
                b25_50 += 1
            else if bestProg < 0.75
                b50_75 += 1
            else if bestProg < 0.90
                b75_90 += 1
            else
                b90_99 += 1
            if not na(sweepPrice)
                float mae = 0.0
                if firstSide == 1
                    mae := math.max(maxHighAfterSweep - sweepPrice, 0.0) / evRng
                else if firstSide == -1
                    mae := math.max(sweepPrice - minLowAfterSweep, 0.0) / evRng
                float maePct = mae * 100.0
                sumMAE += maePct
                cntMAE += 1
                maxMAE := na(maxMAE) ? maePct : math.max(maxMAE, maePct)
            if not na(tHit20)
                sumT20 += tHit20
                cntT20 += 1
            if not na(tHit50)
                sumT50 += tHit50
                cntT50 += 1
            if not na(tHitFull)
                sumTF += tHitFull
                cntTF += 1
    // Start a new event when the range closes.
    if rangeEnd and not na(rHi) and not na(rLo)
        active := true
        finished := false
        watchStartTime := time + _startDelayMin * 60 * 1000
        evHi := rHi
        evLo := rLo
        evRng := math.max(evHi - evLo, syminfo.mintick)
        evMid := (evHi + evLo) / 2.0
        firstSide := 0
        sweepTime := na
        sweepBarIndex := na
        sweepPrice := na
        // New signal window for this range.
        signalWindowStartTime := time + _startDelayMin * 60 * 1000
        signalsThisRange := 0
        signalObjectiveDone := false
        buyCycleLocked := false
        sellCycleLocked := false
        buyInvalidationLow := na
        sellInvalidationHigh := na
        sigSide := 0
        sigSweepBarIndex := na
        sigLowestAfterSweep := na
        sigHighestAfterSweep := na
        sigReclaimEpisodeActive := false
        sigReclaimReady := false
        sigReclaimBarIndex := na
        sigReclaimHigh := na
        sigReclaimLow := na
        sigPostPivotHigh := na
        sigPostPivotLow := na
        sigPostPivotHighConfirmBar := na
        sigPostPivotLowConfirmBar := na
        bestProg := 0.0
        minLowSeen := na
        maxHighSeen := na
        maxHighAfterSweep := na
        minLowAfterSweep := na
        tHit20 := na
        tHit50 := na
        tHitFull := na
        beArmed := false
        beStopped := false
        fullAfterBEStop := false
        beArmBarIndex := na
        rangeCount += 1
        lastRangeEndTime := time
        lastRangeHigh := evHi
        lastRangeLow := evLo
        lastRangeMid := evMid
    [rangeCount, lastRangeEndTime, lastRangeHigh, lastRangeLow, lastRangeMid, signalCount, lastSignalSide, lastSignalTime, lastSignalType, lastSignalEntry, lastSignalTP1, totalRanges, sweptRanges, returnedAny, fullOpp, b0_25, b25_50, b50_75, b75_90, b90_99, sumProg, cntProg, minProg, sumMAE, cntMAE, maxMAE, sumT20, cntT20, sumT50, cntT50, sumTF, cntTF, beArmedCnt, beStopCnt, beStopThenFullCnt]
f_signal_stream(int _rangeStartHour, int _rangeStartMinute, int _rangeLenMinutes, int _startDelayMin, int _lookForwardMin, bool _signalUntilNextRange, int _signalWindowMinutes, int _maxSignalsPerRange, float _minBodyInsidePct, float _minPivotExcursionRanges, bool _requirePivotSweep, int _pivotLen, float _beTriggerPct, int _beBufferTicks) =>
    [_, _, _, _, _, streamSignalCount, streamSignalSide, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _] = f_engine(_rangeStartHour, _rangeStartMinute, _rangeLenMinutes, _startDelayMin, _lookForwardMin, _signalUntilNextRange, _signalWindowMinutes, _maxSignalsPerRange, _minBodyInsidePct, _minPivotExcursionRanges, _requirePivotSweep, _pivotLen, _beTriggerPct, _beBufferTicks)
    [streamSignalCount, streamSignalSide]
//=============================================================================
// Request the latest complete M1 engine state for levels and statistics.
//=============================================================================
[rangeCount, rangeEndTime, rangeHigh, rangeLow, rangeMid, signalCount, signalSide, signalTime, signalType, signalEntry, signalTP1, totalRanges, sweptRanges, returnedAny, fullOpp, b0_25, b25_50, b50_75, b75_90, b90_99, sumProg, cntProg, minProg, sumMAE, cntMAE, maxMAE, sumT20, cntT20, sumT50, cntT50, sumTF, cntTF, beArmedCnt, beStopCnt, beStopThenFullCnt] = request.security(syminfo.tickerid, ENGINE_TF, f_engine(rangeStartHour, rangeStartMinute, rangeLenMinutes, startDelayMin, lookForwardMin, signalWindowMode == "Until next range", signalWindowMinutes, maxSignalsPerRange, minBodyInsidePct, minPivotExcursionRanges, requirePivotSweep, pivotLen, beTriggerPct, beBufferTicks), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[streamSignalCounts, streamSignalSides] = request.security_lower_tf(syminfo.tickerid, ENGINE_TF, f_signal_stream(rangeStartHour, rangeStartMinute, rangeLenMinutes, startDelayMin, lookForwardMin, signalWindowMode == "Until next range", signalWindowMinutes, maxSignalsPerRange, minBodyInsidePct, minPivotExcursionRanges, requirePivotSweep, pivotLen, beTriggerPct, beBufferTicks))
//=============================================================================
// Range level drawings
//=============================================================================
var line currentHighLine = na
var line currentLowLine = na
var line currentMidLine = na
bool newRange = nz(ta.change(rangeCount)) > 0
if newRange and not na(rangeEndTime)
    // Stop the previous day's levels when the next range becomes available.
    if showLines and levelExtension == "Until next range"
        if not na(currentHighLine)
            line.set_extend(currentHighLine, extend.none)
            line.set_x2(currentHighLine, rangeEndTime)
        if not na(currentLowLine)
            line.set_extend(currentLowLine, extend.none)
            line.set_x2(currentLowLine, rangeEndTime)
        if not na(currentMidLine)
            line.set_extend(currentMidLine, extend.none)
            line.set_x2(currentMidLine, rangeEndTime)
    if showLines
        bool untilNext = levelExtension == "Until next range"
        int x2Time = untilNext ? rangeEndTime + 60 * 1000 : rangeEndTime + extensionMinutes * 60 * 1000
        currentHighLine := line.new(x1=rangeEndTime, y1=rangeHigh, x2=x2Time, y2=rangeHigh, xloc=xloc.bar_time, extend=untilNext ? extend.right : extend.none, color=color.red, width=1)
        currentLowLine := line.new(x1=rangeEndTime, y1=rangeLow, x2=x2Time, y2=rangeLow, xloc=xloc.bar_time, extend=untilNext ? extend.right : extend.none, color=color.lime, width=1)
        currentMidLine := line.new(x1=rangeEndTime, y1=rangeMid, x2=x2Time, y2=rangeMid, xloc=xloc.bar_time, extend=untilNext ? extend.right : extend.none, color=color.gray, width=1, style=line.style_dashed)
//=============================================================================
// M1 signal events. M5/M15 clone the M1 markers without recalculating logic.
//=============================================================================
f_draw_trade_markup(int eventSide, int eventTime, int eventType, float eventEntry, float eventTP1) =>
    if showTradeMarkup and not na(eventTime) and not na(eventEntry) and not na(eventTP1)
        int markupEndTime = eventTime + tradeMarkupMinutes * 60 * 1000
        color targetColor = eventSide == 1 ? color.lime : color.red
        string routeText = eventType == 1 ? "Range Reclaim" : "Pivot Entry"
        string targetLocation = eventType == 1 ? "Target: Range 50%" : eventSide == 1 ? "Target: Range Low" : "Target: Range High"
        line.new(x1=eventTime, y1=eventEntry, x2=markupEndTime, y2=eventEntry, xloc=xloc.bar_time, extend=extend.none, color=color.new(color.gray, 20), width=1, style=line.style_dotted)
        line.new(x1=eventTime, y1=eventTP1, x2=markupEndTime, y2=eventTP1, xloc=xloc.bar_time, extend=extend.none, color=targetColor, width=2)
        label.new(x=markupEndTime, y=eventEntry, xloc=xloc.bar_time, text="Entry", style=label.style_label_left, size=size.tiny, textcolor=color.white, color=color.new(color.gray, 65), tooltip=routeText)
        label.new(x=markupEndTime, y=eventTP1, xloc=xloc.bar_time, text="TP1 · Partial close", style=label.style_label_left, size=size.tiny, textcolor=color.white, color=color.new(targetColor, 55), tooltip=targetLocation)
bool buyAlertPulse = false
bool sellAlertPulse = false
if chartIsM1
    // On M1, keep the breakout marker responsive on the current minute.
    bool directSignalPulse = signalCount > nz(signalCount[1])
    if directSignalPulse
        buyAlertPulse := signalSide == 1
        sellAlertPulse := signalSide == -1
        f_draw_trade_markup(signalSide, signalTime, signalType, signalEntry, signalTP1)
else
    // On M5/M15, scan every CLOSED M1 intrabar so no minute signal is lost.
    int previousStreamCount = nz(signalCount[1])
    int streamSize = array.size(streamSignalCounts)
    if streamSize > 0
        for streamIndex = 0 to streamSize - 1
            int currentStreamCount = array.get(streamSignalCounts, streamIndex)
            if not na(currentStreamCount) and currentStreamCount > previousStreamCount
                int currentStreamSide = array.get(streamSignalSides, streamIndex)
                buyAlertPulse := buyAlertPulse or currentStreamSide == 1
                sellAlertPulse := sellAlertPulse or currentStreamSide == -1
            previousStreamCount := na(currentStreamCount) ? previousStreamCount : math.max(previousStreamCount, currentStreamCount)
plotshape(showSignals and buyAlertPulse, title="M1 Buy confirmation", style=shape.arrowup, location=location.belowbar, color=color.lime, text="BUY", textcolor=color.lime, size=size.small)
plotshape(showSignals and sellAlertPulse, title="M1 Sell confirmation", style=shape.arrowdown, location=location.abovebar, color=color.red, text="SELL", textcolor=color.red, size=size.small)
alertcondition(buyAlertPulse, title="M1 Buy confirmation", message="M1 BUY: qualified lower sweep. The marker on M5/M15 is a clone of the original M1 signal; no M5/M15 signal logic is calculated.")
alertcondition(sellAlertPulse, title="M1 Sell confirmation", message="M1 SELL: qualified upper sweep. The marker on M5/M15 is a clone of the original M1 signal; no M5/M15 signal logic is calculated.")
//=============================================================================
// Statistics
//=============================================================================
f_pct(int value, int base) =>
    base <= 0 ? "-" : str.tostring(100.0 * value / base, "#.##") + "%"
int base = sweptRanges
int notFull = base - fullOpp
float avgProg = cntProg > 0 ? sumProg / cntProg : na
float avgMAE = cntMAE > 0 ? sumMAE / cntMAE : na
float avgT20 = cntT20 > 0 ? sumT20 / cntT20 : na
float avgT50 = cntT50 > 0 ? sumT50 / cntT50 : na
float avgTF = cntTF > 0 ? sumTF / cntTF : na
var table tb = table.new(position.top_right, 2, 21, border_width=0, frame_width=1, frame_color=color.new(color.gray, 55))
color titleBg = color.new(color.black, 0)
color sectionBg = color.new(color.gray, 78)
color rowBg = color.new(color.black, 18)
color valueBg = color.new(color.black, 8)
color mutedText = color.new(color.white, 25)
f_row(int row, string labelText, string valueText) =>
    table.cell(tb, 0, row, labelText, text_color=mutedText, bgcolor=rowBg, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, row, valueText, text_color=color.white, bgcolor=valueBg, text_size=size.small, text_halign=text.align_right)
f_section(int row, string txt) =>
    table.cell(tb, 0, row, txt, text_color=color.white, bgcolor=sectionBg, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tb, 1, row, "", bgcolor=sectionBg)
if barstate.islast
    if showStats
        table.cell(tb, 0, 0, "NASDAQ PRE-MARKET SWEEP", text_color=color.white, bgcolor=titleBg, text_size=size.small, text_halign=text.align_left)
        table.cell(tb, 1, 0, "M1 ENGINE", text_color=color.new(color.white, 20), bgcolor=titleBg, text_size=size.tiny, text_halign=text.align_right)
        f_section(1, "OVERVIEW")
        f_row(2, "Completed ranges", str.tostring(totalRanges))
        f_row(3, "Qualified sweeps", str.tostring(sweptRanges) + "  |  " + f_pct(sweptRanges, totalRanges))
        f_row(4, "Returned into range", str.tostring(returnedAny) + "  |  " + f_pct(returnedAny, base))
        f_row(5, "Full opposite edge", str.tostring(fullOpp) + "  |  " + f_pct(fullOpp, base))
        f_section(6, "RETURN DEPTH")
        f_row(7, "Average return (>0)", na(avgProg) ? "-" : str.tostring(avgProg * 100.0, "#.##") + "%")
        f_row(8, "Minimum return (>0)", na(minProg) ? "-" : str.tostring(minProg * 100.0, "#.##") + "%")
        f_row(9, "0-25%", str.tostring(b0_25) + "  |  " + f_pct(b0_25, notFull))
        f_row(10, "25-50%", str.tostring(b25_50) + "  |  " + f_pct(b25_50, notFull))
        f_row(11, "50-75%", str.tostring(b50_75) + "  |  " + f_pct(b50_75, notFull))
        f_row(12, "75-90%", str.tostring(b75_90) + "  |  " + f_pct(b75_90, notFull))
        f_row(13, "90-99%", str.tostring(b90_99) + "  |  " + f_pct(b90_99, notFull))
        f_section(14, "RISK & TIME")
        f_row(15, "Average adverse excursion", na(avgMAE) ? "-" : str.tostring(avgMAE, "#.##") + "%")
        f_row(16, "Maximum adverse excursion", na(maxMAE) ? "-" : str.tostring(maxMAE, "#.##") + "%")
        f_row(17, "Average time to 20%", na(avgT20) ? "-" : str.tostring(avgT20, "#.##") + " min")
        f_row(18, "Average time to 50%", na(avgT50) ? "-" : str.tostring(avgT50, "#.##") + " min")
        f_row(19, "Average time to full", na(avgTF) ? "-" : str.tostring(avgTF, "#.##") + " min")
        f_row(20, "BE armed / stopped / later full", str.tostring(beArmedCnt) + " / " + str.tostring(beStopCnt) + " / " + str.tostring(beStopThenFullCnt))
    else
        table.clear(tb, 0, 0, 1, 20)
````
