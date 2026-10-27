# BitcoinOnChain

- url: https://www.tradingview.com/script/EcqAyirl-BitcoinOnChain/
- type: indicator
- pine_id: PUB;7fa5ee38556f4703ad0b9b53abbb448a
- version: 5.0

## Description

WHAT IT IS

BitcoinOnChain reads the Bitcoin network rather than the price chart. It pulls six on-chain metrics from the Glassnode feeds on TradingView, scores each against its own recent history, and blends them into one line called ChainPulse, shown in MACD form with a composite line, a signal line, a histogram and an information table.

The purpose is context. Price shows what the market did; these metrics describe what the network did underneath it - who transacted, whether coins moved at a profit or a loss, whether miners stayed committed, whether new users arrived. When the two stories disagree, that disagreement is the thing worth seeing.

THE METHOD

Raw on-chain numbers are hard to read directly. Whether 654,000 active addresses is a lot depends entirely on the last few months, so nothing here is compared to a fixed level. Each metric is percentile ranked over its own trailing window, 90 periods by default, and mapped onto a scale from -100 to +100. Zero means the metric sits at its own median; positive is healthier than its recent norm, negative is weaker. That is what lets one setting work across different price regimes.

The six scores are blended using adjustable weights, defaulting to SOPR 25, Active Addresses 20, New Addresses 15, Transaction Fees 15, Hash Rate 15 and Sending Addresses 10. The blend is smoothed into ChainPulse; smoothing that again gives the signal line, and the gap between them is the histogram.

Two metrics are handled specially. SOPR is ranked on its distance from 1.0 rather than its level, because 1.0 is its natural breakeven. Sending Addresses is inverted before blending, since heavy spending is treated as distribution rather than health.

THE SIX METRICS

SOPR, the Spent Output Profit Ratio, shows whether coins moving on the network are spent at a profit or a loss. Above 1.0 the average coin sold for more than it was acquired for; below 1.0, for less. Sustained readings under 1.0 describe holders realising losses. It carries the heaviest default weight.

Active Addresses counts unique addresses transacting, a direct read on participation. Participation holding up while price falls is a different situation from participation falling with it.

New Addresses counts first-time addresses, standing in for the rate of fresh adoption.

Transaction Fees, in dollars, measures demand for limited block space. Fees rise when people will pay to transact and fall when the network is quiet.

Hash Rate measures the computing power securing the network, standing in for miner commitment.

Sending Addresses counts addresses spending Bitcoin, and is the one metric scored in reverse: heavy movement out is treated as distribution, so a high reading pushes the composite down.

READING THE CHART

The histogram is the gap between ChainPulse and its signal, drawn in four states: gold above zero, blue below, bright while the gap widens and faded while it narrows. The fade softens before the histogram crosses zero.

ChainPulse is the thick white line, the lime green line is its signal, and the gold line across the middle is zero. The shading between ChainPulse and zero grows more solid the further the composite sits from normal.

Circular dots mark crosses between ChainPulse and its signal and are deliberately restrictive: a dot prints only when both lines are still on the same side of zero and the histogram is expanding, so a cross up marks a recovery beginning from weak territory and a cross down marks deterioration beginning from strong territory. They describe turns in on-chain flow, not trade instructions.

Green and red triangles mark divergence between price and ChainPulse: green where price made a lower low while the composite made a higher low, red for the mirror. Pivots define those highs and lows, defaulting to five bars left, three right, with a maximum reach of twenty four bars between compared pivots.

THE INFORMATION TABLE

Five columns, ten rows, placeable in any of nine positions.

The top row summarises: the labels BTC and ONCHAIN, then a regime word, the composite value, and a feed count. The regime word comes from the composite, reading STRONG at 50 or above, HEALTHY from 20 to 50, NEUTRAL between -20 and +20, WEAK down to -50 and STRESSED below that. The last cell shows how many of the six metrics are reporting; anything under six out of six means a feed has stopped and the composite is running on the rest.

The second row holds the headline numbers. Comp is ChainPulse, Signal is its signal line, and the last cell is the histogram, Comp minus Signal.

The third row holds the column headings for the six metric rows beneath: Metric, Raw, Score, Rank and Contrib.

Each metric row shows Raw, the measurement in its own units, with SOPR to four decimals, address counts and fees abbreviated in thousands and hash rate in exahashes per second; Score, the normalised -100 to +100 reading; Rank, the underlying percentile, so 70 percent means it sits above 70 percent of its own readings in the window; and Contrib, how many points that metric contributes to the composite given its weight. Score and Rank describe the same thing two ways, with one exception: Sending Addresses is inverted, so a rank above 50 percent beside a negative score is expected. The six Contrib values add up to the composite before smoothing, so the column shows directly which metrics are moving the number. A metric whose feed has stopped shows DEAD there and is excluded from the blend.

The bottom row covers timing. Div reports a recent divergence as BULL, BEAR or a dash. Last X reports how many bars since the most recent cross dot, and whether it was a buy or sell type.

SETTINGS AND DATA

The lookback, on-chain resolution, all six weights, divergence and pivot settings, smoothing lengths, colours and table position are adjustable, and any weight can be set to zero to drop that metric. A dead feed guard, on by default, removes a non-reporting metric from the blend and rescales the rest, because a missing value read as zero would rank at the bottom of its history and look like an extreme bearish reading when nothing had happened. Eleven alert conditions cover the cross dots, zero line crosses, strong and stressed readings, SOPR extremes, both divergences and a feed failure warning.

Data comes from the Glassnode feeds carried on TradingView, and availability depends on your account. On-chain data updates far less often than price: at the default daily resolution these values change once a day, so an intraday chart holds the same reading all session. Requests use a one bar shift with lookahead disabled, so history does not repaint. Divergence markers are the exception by design, since a pivot cannot be confirmed until the required bars have printed after it. The triangle is placed on the pivot it describes but appears only once those bars complete, while the exported divergence values are stamped on the confirmation bar, showing when the divergence could actually have been known.

LIMITATIONS

This is built for Bitcoin. The feeds are Bitcoin network metrics, so applying it to another symbol shows Bitcoin data beside an unrelated price series. On-chain metrics describe network conditions; they do not measure or forecast price, and there are long stretches where the network reads healthy while price falls, or the reverse. Every score is relative to the chosen lookback, so a metric can rank high simply because the recent past was quiet, which is why the Rank column is always shown.

This script is a research and analysis tool. It is not financial advice, not a recommendation to buy or sell, and not a signal service. The dots and triangles describe what the data has already done. No indicator predicts future price. Do your own research and manage your own risk.

## Source Code

````pine
//@version=6
indicator("BitcoinOnChain", shorttitle="BTCOnChn", overlay=false, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════════════════════
// BITCOINONCHAIN (BTCOnChn) — On-Chain Structural Dashboard
// ═══════════════════════════════════════════════════════════════════════════════
//
// BUILD LOG (newest first)
//
//   1.8  Aug 15 2026 — divergence markers pinned to the pane edges. Display
//        only. No score, window, blend, dot or exported value changes.
//        - Bearish triangles now sit along the TOP of the pane and bullish
//          along the BOTTOM, instead of riding on the composite line where
//          they were lost against the line, the fill and the histogram.
//          Bear at the top and bull at the bottom also matches where the
//          event happens: a bearish divergence forms at a price high, a
//          bullish one at a low.
//        - location.top and location.bottom pin to the pane edges and take no
//          part in scaling, so the markers stay visible at any zoom and can
//          never stretch the pane. The series is still a conditional float
//          that goes to na, never a bare bool.
//        - offset=-i_divPivR is unchanged, so a marker still sits on the
//          pivot bar it describes. Only the height moved.
//        - Size bumped one notch, tiny to small, since visibility was the
//          complaint.
//
//   1.7  Aug 15 2026 — the lookback now means DAYS, not chart bars. THIS
//        CHANGES EVERY SCORE ON EVERY CHART EXCEPT THE DAILY.
//        - THE BUG: each metric was percentile ranked over i_normLen CHART
//          bars. The metrics arrive on the on-chain timeframe (daily), so the
//          amount of history a reading was graded against depended entirely
//          on which chart happened to be open: 90 days on a daily chart, 30
//          on an 8 hour, 15 on a 4 hour, 630 on a weekly. Same network data,
//          same day, different verdict per chart.
//          Measured Aug 15 2026 with identical raw values on both panels
//          (SOPR 0.9935, Active 654K, New 298K, Fees $322K, Hash 890EH,
//          Sends 448K): SOPR scored -33 on the daily and -73 on the 8 hour.
//          Hash scored -27 and -2. New scored 56 and 40.
//        - THE FIX: the lookback is multiplied by however many chart bars
//          make up one on-chain period, so 90 means 90 days everywhere.
//          4 hour uses 540 bars, 8 hour 270, 12 hour 180, daily 90, weekly
//          13 - each covering the same 90 days.
//        - LIMITS, stated plainly. The effective window is capped at 1000
//          bars so a fast chart cannot ask for more history than it can hold,
//          which means 2 hour covers 83 days and 1 hour covers 42 rather than
//          90; 4 hour and slower are exact. And on charts SLOWER than the
//          data (weekly), the window spans the right 90 days but only samples
//          the daily series once per bar, so a weekly reading is a coarse
//          estimate of the daily one rather than an exact match. It is still
//          far closer than the 630 day window it replaces.
//        - The effective window is exported as BOC Window so any shot can be
//          verified from its own file rather than assumed.
//        - Charts now need more history before the line starts: 540 bars on
//          a 4 hour instead of 90. That is the correct cost of the fix.
//
//   1.6  Aug 15 2026 — cross dot rule fixed. THIS CHANGES WHICH DOTS APPEAR,
//        including historically. No metric, score, weight or blend touched.
//        - THE BUG: the dot required the composite to be on the correct side
//          of zero ON the crossing bar. On a fast move the composite clears
//          the signal line and the zero line in the same bar, so the filter
//          threw the event away exactly when the turn was sharpest. Measured
//          on the daily chart: Aug 10 2026 crossed down at -0.02 with the
//          signal at 12.81, after peaking at 27.49 two bars earlier. The
//          steepest roll-over on the chart, and it missed the dot by two
//          hundredths of a point.
//        - THE FIX: test the side of zero on the bar BEFORE the cross, which
//          is the bar that says what territory the move is coming FROM.
//          Aug 10 now qualifies, because the composite sat at 17.03 the day
//          before - unambiguously strong territory rolling over. Jul 29 is
//          still correctly rejected, because it sat at -6.04 the day before
//          and was already weak.
//        - Two dead conditions removed while I was in here. The old rule also
//          demanded the signal line be on the same side of zero and the
//          histogram be expanding. A crossover puts the composite above the
//          signal by definition, so the signal test could never fail once the
//          composite test passed; and a crossover moves the histogram from
//          at-or-below zero to above it, so the expansion test could never
//          fail either. Proven algebraically and confirmed over 100,000
//          simulated crossings: neither ever filtered a single case. They
//          implied filtering the code was not doing.
//        - To restore the old behaviour, drop the [1] from both lines.
//
//   1.5  Aug 15 2026 — display only. Column header row (Metric / Raw /
//        Score / Rank / Contrib) moved from dim grey to yellow, so the
//        header reads as a divider between the headline block above and the
//        six metric rows below instead of blending into them. Exposed as its
//        own input. Nothing else touched.
//
//   1.4  Aug 15 2026 — table colour language. Display only. No change to
//        any score, weight, blend, trigger or exported value.
//        - The table now speaks one colour language: lime green bullish,
//          red bearish, white neutral. It had been gold/blue, borrowed from
//          the histogram, while the Div cell alone used green/red - two
//          languages in one table.
//        - Colour threshold dropped from 30 to 15, and exposed as an input.
//          At 30 the table read grey almost everywhere: hash at the 37th
//          percentile and sends at the 60th both showed as neutral when
//          neither was.
//        - Contribution cells now take their colour from the metric's own
//          score instead of the contribution times three. The old form was
//          broken for low-weight metrics: a contribution is capped by its
//          weight, so Sends at weight 10 tops out at 10 points, times three
//          is exactly 30, and it could only ever colour at a perfect score.
//          Sends was effectively always grey. NOTE, worth knowing: scaling a
//          contribution against its own maximum turns out to equal the score
//          exactly, since contribution = score x weight / total and the
//          maximum is 100 x weight / total. So the correct normalisation IS
//          the score. The two columns now share a colour and differ in
//          number, which is the honest result.
//        - Rank cells coloured on the same rule, so the three derived
//          columns agree and only the Raw measurement stays neutral.
//        - The composite and regime cells key off the regime bands at 20
//          rather than the 15 used for metrics, so a green composite can
//          never sit beside the word NEUTRAL.
//        - CHART UNCHANGED. The histogram, fill and cross dots keep gold and
//          blue. The table is a data readout and now reads on its own.
//
//   1.3  Aug 14 2026 — display only. No change to any score, weight, blend
//        or trigger. Every number this build produces is identical to 1.2.
//        - Divergence triangles now carry offset=-i_divPivR, so a marker
//          lands ON the pivot bar it describes instead of three bars to the
//          right of it. The height already came from the pivot, so bar and
//          height now agree. The dedicated BOC BullDiv / BOC BearDiv export
//          columns are deliberately NOT offset - those still stamp the bar
//          the divergence was confirmed on, which is the honest record of
//          when it could have been known.
//        - Divergence triangles moved off the gold/blue pair to their own
//          colours: green up, red down, fleet #00FF88 and #FF4444. They read
//          as a separate class of event from the cross dots now, and the
//          table's Div cell follows the same two colours.
//        - Signal line is lime green and one level thicker (1 -> 2).
//
//   1.2  Aug 14 2026 — the five additions. Adds a dead-feed guard, a
//        price-vs-ChainPulse divergence read, a contribution column, cross
//        age, and per-metric exports.
//        - DEAD FEED GUARD (default ON, changes the composite). A missing
//          Glassnode value used to become 0 through nz(), and 0 ranks at the
//          bottom of its own history, so a feed outage read as maximum
//          bearish. A stale hash or SOPR feed printed a fake capitulation.
//          Now: each metric forward-fills its last good reading so an outage
//          cannot poison the ranking window, and a dead metric is dropped
//          from BOTH the blend and the weight total so the remaining metrics
//          renormalise to the whole. ACCEPTANCE PROPERTY: with all six feeds
//          live and never missing, the composite is bit-identical to 1.1.
//          Verified by hand on the weights: 1.1 and 1.2 both return 8.40 on
//          the Aug 14 scores. Guard OFF reproduces 1.1 behaviour exactly.
//        - DIVERGENCE. Price pivots against the ChainPulse line, fleet
//          standard 5 left / 3 right, 24 bar reach. Price lower low with
//          ChainPulse higher low is the accumulation tell; the mirror is
//          distribution. Fires 3 bars after the pivot, which is inherent to
//          pivots, not a lag bug.
//        - CONTRIBUTION COLUMN. score x effective weight / weight total.
//          The six contributions sum to the composite exactly, so the table
//          now shows which metric is actually moving the number.
//        - CROSS AGE. Bars since the last buy or sell cross, plus which way
//          it went, in the table and exported. Kills the offline
//          reconstruction the tracker needed.
//        - PER-METRIC EXPORTS. All six scores and ranks to the data window,
//          plus live count, divergence flags and cross age. Appended after
//          every 1.1 plot so no existing column moves.
//
//   1.1  Aug 14 2026 — fix + display pass. No change to how the six metrics
//        are scored or blended.
//        - Hash rate readout divided by 1e18, not 1e9. Hash rate arrives in
//          hashes per second and an exahash is 1e18, so the cell had been
//          printing 889520277518EH instead of 890EH. DISPLAY ONLY: score and
//          rank always came off the raw value and were never affected.
//        - request.security switched to barmerge.lookahead_off on all six
//          feeds, fleet standard. NOTE: this is the one change that moves
//          numbers. Paired with the [1] shift it holds each metric one extra
//          daily bar before use, so readings run one bar later than 1.0 did.
//          Both forms are repaint-safe; this one is the more conservative.
//          One word per line to revert.
//        - Table font one level up (tiny -> small).
//        - Table dim text and neutral score colour moved to the fleet
//          #d0d0d0 standard (was #80D4E6).
//        - Table placement opened to the fleet nine positions, Bottom Right
//          still the default.
//        - BOC BUILD stamp added, appended after every existing plot so no
//          exported column changes position.
//
//   1.0  original build — six Glassnode metrics, percentile scored, weighted
//        into ChainPulse with a signal line and histogram.
//
// ═══════════════════════════════════════════════════════════════════════════════
//
// Pulls Glassnode on-chain metrics via request.security() and normalizes
// them into a composite structural health score for Bitcoin. Designed for
// daily and weekly timeframes as a companion to SwingFlow and the BTC
// Structure Tracker.
//
// METRICS TRACKED:
//
//   SOPR (Spent Output Profit Ratio) — Are holders selling at profit or
//   loss? Below 1.0 = capitulation (selling at loss). Above 1.0 = profit
//   taking. Resets to 1.0 mark the inflection between bear and bull.
//
//   Active Addresses — Network participation. Rising addresses during
//   price decline = accumulation. Falling addresses = disengagement.
//
//   New Addresses — Fresh adoption. Growth signals expanding user base.
//   Decline during price drops = lack of new interest.
//
//   Transaction Fees (USD) — Demand for block space. High fees = heavy
//   network usage. Low fees = quiet network. Spikes often precede
//   volatility.
//
//   Hash Rate — Network security and miner commitment. Rising hash rate
//   during price decline = miners are confident. Declining = capitulation.
//
//   Sending Addresses — How many unique addresses are spending BTC.
//   Elevated sending during price decline = distribution/panic.
//   Low sending = holders sitting tight.
//
// COMPOSITE SCORE:
//
//   Each metric is percentile-ranked over a configurable lookback and
//   mapped to a -100 to +100 scale where positive = structurally healthy
//   (bullish on-chain) and negative = structurally weak (bearish on-chain).
//   The composite blends all six into a single structural health reading.
//
// COMPANION TO: SwingFlow, BTC Structure Tracker, SeismicScore, GravityWell
//
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

string G_CORE = "══ CORE ══"
i_normLen      = input.int(90, "Lookback (on-chain periods)", minval=20, maxval=365, group=G_CORE,
     tooltip="How much history each metric is graded against, counted in ON-CHAIN PERIODS - so at the default daily resolution, 90 means 90 days on every chart timeframe. The indicator converts that into chart bars for you. Longer = steadier baseline.")
i_smoothLen    = input.int(5, "Composite Smoothing", minval=1, maxval=20, group=G_CORE,
     tooltip="EMA applied to the final composite score.")
i_onchainTF    = input.timeframe("D", "On-Chain Timeframe", group=G_CORE,
     tooltip="Resolution for Glassnode data. D = daily, W = weekly. Use daily for standard analysis, weekly for macro context.")

string G_WEIGHT = "══ WEIGHTS ══"
i_wSopr        = input.float(25, "SOPR Weight", minval=0, maxval=100, step=5, group=G_WEIGHT,
     tooltip="Spent Output Profit Ratio — the single most powerful on-chain signal for market bottoms/tops.")
i_wActive      = input.float(20, "Active Addr Weight", minval=0, maxval=100, step=5, group=G_WEIGHT,
     tooltip="Network participation health.")
i_wNew         = input.float(15, "New Addr Weight", minval=0, maxval=100, step=5, group=G_WEIGHT,
     tooltip="Fresh adoption rate.")
i_wFees        = input.float(15, "Tx Fees Weight", minval=0, maxval=100, step=5, group=G_WEIGHT,
     tooltip="Demand for block space.")
i_wHash        = input.float(15, "Hash Rate Weight", minval=0, maxval=100, step=5, group=G_WEIGHT,
     tooltip="Miner commitment and network security.")
i_wSending     = input.float(10, "Sending Addr Weight", minval=0, maxval=100, step=5, group=G_WEIGHT,
     tooltip="Distribution vs holding behavior.")

string G_VIS = "══ DISPLAY ══"
i_showHist     = input.bool(true, "Show Histogram", group=G_VIS)
i_showSignal   = input.bool(true, "Show Signal Line", group=G_VIS)
i_signalLen    = input.int(9, "Signal Line EMA", minval=3, maxval=30, group=G_VIS)
i_showTable    = input.bool(true, "Show Table", group=G_VIS)
i_tblPos       = input.string("Bottom Right", "Table Position",
     options=["Top Left", "Top Center", "Top Right",
              "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"], group=G_VIS)
i_showDots     = input.bool(true, "Show Cross Dots", group=G_VIS,
     tooltip="Buy dot when composite crosses above signal below zero. Sell dot when composite crosses below signal above zero.")

string G_GUARD = "══ DATA HEALTH ══"
i_deadGuard    = input.bool(true, "Dead Feed Guard", group=G_GUARD,
     tooltip="ON: a metric with no data is dropped from the blend and from the weight total, and each metric holds its last good reading so an outage cannot poison the ranking window. OFF reproduces build 1.1 exactly, where a missing feed scored as maximum bearish.")

string G_DIV = "══ DIVERGENCE ══"
i_showDiv      = input.bool(true, "Price vs ChainPulse Divergence", group=G_DIV,
     tooltip="Price makes a lower low while the chain makes a higher low = accumulation. Mirror for distribution.")
i_divPivL      = input.int(5, "Pivot Left", minval=2, maxval=20, group=G_DIV)
i_divPivR      = input.int(3, "Pivot Right", minval=1, maxval=10, group=G_DIV,
     tooltip="A divergence can only be confirmed this many bars after the pivot prints. Inherent to pivots.")
i_divMaxBars   = input.int(24, "Max Bars Between Pivots", minval=5, maxval=100, group=G_DIV,
     tooltip="Two pivots further apart than this are not compared.")

string G_CLR = "══ COLORS ══"
i_bullClr      = input.color(#FFD700, "Bullish Color", group=G_CLR)
i_bearClr      = input.color(#1E90FF, "Bearish Color", group=G_CLR)
i_compLineClr  = input.color(#FFFFFF, "Composite Line", group=G_CLR)
i_signalClr    = input.color(#32CD32, "Signal Line", group=G_CLR)
i_eqClr        = input.color(#FFD700, "Zero Line", group=G_CLR)
i_divBullClr   = input.color(#00FF88, "Bull Divergence", group=G_CLR,
     tooltip="Deliberately not the histogram gold. A divergence is a different class of event from a cross and should not read as one.")
i_divBearClr   = input.color(#FF4444, "Bear Divergence", group=G_CLR)

string G_TBL = "══ TABLE COLOURS ══"
i_tblBullClr   = input.color(#32CD32, "Table Bullish", group=G_TBL)
i_tblBearClr   = input.color(#FF4444, "Table Bearish", group=G_TBL)
i_tblNeutClr   = input.color(#FFFFFF, "Table Neutral", group=G_TBL)
i_tblHdrClr    = input.color(#FFD700, "Table Header Row", group=G_TBL,
     tooltip="The Metric / Raw / Score / Rank / Contrib row. Deliberately off the bull-bear-neutral palette so a heading is never mistaken for a reading.")
i_tblDead      = input.int(15, "Table Colour Threshold", minval=0, maxval=100, group=G_TBL,
     tooltip="A score inside plus or minus this reads neutral white. Lower it to see more colour, raise it to only flag extremes. The composite and regime cells ignore this and use the regime band at 20 instead, so a coloured composite can never contradict the regime word.")

// ═══════════════════════════════════════════════════════════════════════════════
// ON-CHAIN DATA — Glassnode via request.security()
// ═══════════════════════════════════════════════════════════════════════════════
// Each metric is fetched from the GLASSNODE:XTVCBTC_ prefix.
// [1] shift + barmerge.gaps_off for anchoring fix on daily data.

float soprRaw     = request.security("GLASSNODE:XTVCBTC_SOPR", i_onchainTF,
     close[1], barmerge.gaps_off, barmerge.lookahead_off)
float activeAddr  = request.security("GLASSNODE:XTVCBTC_ACTIVEADDRESSES", i_onchainTF,
     close[1], barmerge.gaps_off, barmerge.lookahead_off)
float newAddr     = request.security("GLASSNODE:XTVCBTC_NEWADDRESSES", i_onchainTF,
     close[1], barmerge.gaps_off, barmerge.lookahead_off)
float txFeesUsd   = request.security("GLASSNODE:XTVCBTC_TOTALTXFEESUSD", i_onchainTF,
     close[1], barmerge.gaps_off, barmerge.lookahead_off)
float hashRate    = request.security("GLASSNODE:XTVCBTC_HASHRATE", i_onchainTF,
     close[1], barmerge.gaps_off, barmerge.lookahead_off)
float sendAddr    = request.security("GLASSNODE:XTVCBTC_SENDINGADDRESSES", i_onchainTF,
     close[1], barmerge.gaps_off, barmerge.lookahead_off)

// ═══════════════════════════════════════════════════════════════════════════════
// DATA HEALTH — hold the last good reading, and know which feeds are alive
// ═══════════════════════════════════════════════════════════════════════════════
// Every one of these metrics is strictly positive in real life: an address
// count, a dollar figure, a hash rate, and SOPR which sits near 1.0. So a
// value that is na or not above zero is a dead feed, never a real reading.

f_alive(float v) => not na(v) and v > 0

// Forward fill. Each call site keeps its own memory, so a feed that goes
// quiet holds its last good number instead of collapsing to zero and
// dragging its own percentile window down with it.
f_hold(float v) =>
    var float held = na
    if f_alive(v)
        held := v
    held

bool soprLive   = f_alive(soprRaw)
bool activeLive = f_alive(activeAddr)
bool newLive    = f_alive(newAddr)
bool feesLive   = f_alive(txFeesUsd)
bool hashLive   = f_alive(hashRate)
bool sendLive   = f_alive(sendAddr)

int liveCount = (soprLive ? 1 : 0) + (activeLive ? 1 : 0) + (newLive ? 1 : 0) +
     (feesLive ? 1 : 0) + (hashLive ? 1 : 0) + (sendLive ? 1 : 0)

// Guard OFF falls back to the 1.1 inputs exactly.
float soprUse   = i_deadGuard ? f_hold(soprRaw)   : nz(soprRaw, 1.0)
float activeUse = i_deadGuard ? f_hold(activeAddr): nz(activeAddr)
float newUse    = i_deadGuard ? f_hold(newAddr)   : nz(newAddr)
float feesUse   = i_deadGuard ? f_hold(txFeesUsd) : nz(txFeesUsd)
float hashUse   = i_deadGuard ? f_hold(hashRate)  : nz(hashRate)
float sendUse   = i_deadGuard ? f_hold(sendAddr)  : nz(sendAddr)

// ═══════════════════════════════════════════════════════════════════════════════
// NORMALIZATION — Percentile rank each metric
// ═══════════════════════════════════════════════════════════════════════════════

// ── THE WINDOW, IN DAYS RATHER THAN BARS ──────────────────────────────────
// The metrics arrive on the on-chain timeframe, so ranking them over chart
// bars made the window cover a different span of history on every chart.
// Multiplying by the bars-per-period ratio makes i_normLen mean the same
// thing everywhere. Every term here is simple, not series, so this stays a
// valid length argument for ta.percentrank.
float barsPerPeriod = timeframe.in_seconds(i_onchainTF) / math.max(timeframe.in_seconds(), 1)
// Capped so a fast chart cannot ask for more history than it can hold.
int normBars = math.max(2, math.min(1000, int(math.round(i_normLen * barsPerPeriod))))

// Helper: percentile rank → -100 to +100 score
f_score(float src, int len) => (ta.percentrank(nz(src), len) - 50) * 2
f_inv_score(float src, int len) => -((ta.percentrank(nz(src), len) - 50) * 2)

// SOPR: centered on 1.0 — rank the deviation from breakeven
float soprDev     = nz(soprUse, 1.0) - 1.0
float soprScore   = f_score(soprDev, normBars)

// Active addresses: higher = healthier network
float activeScore = f_score(activeUse, normBars)

// New addresses: higher = more adoption
float newScore    = f_score(newUse, normBars)

// Transaction fees: higher = more demand for block space
float feesScore   = f_score(feesUse, normBars)

// Hash rate: higher = stronger network
float hashScore   = f_score(hashUse, normBars)

// Sending addresses: INVERTED — high sending = distribution (bearish)
float sendScore   = f_inv_score(sendUse, normBars)

// Preserve ranks for table display
float soprRank    = ta.percentrank(soprDev, normBars)
float activeRank  = ta.percentrank(nz(activeUse), normBars)
float newRank     = ta.percentrank(nz(newUse), normBars)
float feesRank    = ta.percentrank(nz(feesUse), normBars)
float hashRank    = ta.percentrank(nz(hashUse), normBars)
float sendRank    = ta.percentrank(nz(sendUse), normBars)

// ═══════════════════════════════════════════════════════════════════════════════
// COMPOSITE — Weighted blend
// ═══════════════════════════════════════════════════════════════════════════════

// A dead metric carries no weight, so the survivors renormalise to the whole
// instead of the composite being dragged by a feed that simply stopped
// reporting. Guard OFF restores the flat 1.1 weights.
float wSoprEff   = (not i_deadGuard or soprLive)   ? i_wSopr    : 0.0
float wActiveEff = (not i_deadGuard or activeLive) ? i_wActive  : 0.0
float wNewEff    = (not i_deadGuard or newLive)    ? i_wNew     : 0.0
float wFeesEff   = (not i_deadGuard or feesLive)   ? i_wFees    : 0.0
float wHashEff   = (not i_deadGuard or hashLive)   ? i_wHash    : 0.0
float wSendEff   = (not i_deadGuard or sendLive)   ? i_wSending : 0.0

float wTotal = math.max(wSoprEff + wActiveEff + wNewEff + wFeesEff + wHashEff + wSendEff, 0.001)

// Per-metric contribution. These six sum to compRaw exactly, which is what
// makes the table's Contrib column readable as "who moved the number".
float soprCon   = soprScore   * wSoprEff   / wTotal
float activeCon = activeScore * wActiveEff / wTotal
float newCon    = newScore    * wNewEff    / wTotal
float feesCon   = feesScore   * wFeesEff   / wTotal
float hashCon   = hashScore   * wHashEff   / wTotal
float sendCon   = sendScore   * wSendEff   / wTotal

float compRaw = soprCon + activeCon + newCon + feesCon + hashCon + sendCon

float compLine   = ta.ema(compRaw, i_smoothLen)
float signalLine = ta.ema(compLine, i_signalLen)
float hist       = compLine - signalLine

// Clamp
float compVal    = math.max(-100, math.min(100, compLine))

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS — MACD format
// ═══════════════════════════════════════════════════════════════════════════════

// Histogram 4-state coloring
color histColor = hist >= 0 ?
     (hist > hist[1] ? color.new(i_bullClr, 0) : color.new(i_bullClr, 50)) :
     (hist < hist[1] ? color.new(i_bearClr, 0) : color.new(i_bearClr, 50))

plot(i_showHist ? hist : na, "Histogram", style=plot.style_columns, color=histColor, linewidth=2)

// Composite and signal lines
plot(compLine, "ChainPulse", color=color.new(i_compLineClr, 0), linewidth=2)
plot(i_showSignal ? signalLine : na, "Signal", color=color.new(i_signalClr, 0), linewidth=2)

// Zero line
float _s = close / close
plot(0 * _s, "Zero", color=color.new(i_eqClr, 40), linewidth=1, style=plot.style_line)

// Fill between composite and zero
p_comp = plot(compLine, "Comp Fill", color=na, display=display.none)
p_zero = plot(0 * _s, "Zero Fill", color=na, display=display.none)
float absComp  = math.abs(compLine)
int   fillOpac = math.round(math.max(0, 85 - absComp * 0.7))
color fillClr  = compLine >= 0 ? color.new(i_bullClr, fillOpac) : color.new(i_bearClr, fillOpac)
fill(p_comp, p_zero, color=fillClr, title="Health Gradient")

// ═══════════════════════════════════════════════════════════════════════════════
// CROSSOVER DOTS
// ═══════════════════════════════════════════════════════════════════════════════

bool compCrossAbove = ta.crossover(compLine, signalLine)
bool compCrossBelow = ta.crossunder(compLine, signalLine)

// The side-of-zero test reads the bar BEFORE the cross. That bar is the one
// that says where the move is coming FROM, and it survives a composite that
// jumps the signal line and zero together in a single bar.
bool buyDot  = compCrossAbove and compLine[1] < 0
bool sellDot = compCrossBelow and compLine[1] > 0

plot(i_showDots and buyDot  ? compLine : na, "Buy Cross",  color=color.new(i_bullClr, 0), style=plot.style_circles, linewidth=4)
plot(i_showDots and sellDot ? compLine : na, "Sell Cross", color=color.new(i_bearClr, 0), style=plot.style_circles, linewidth=4)

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE — price pivots against the ChainPulse line
// ═══════════════════════════════════════════════════════════════════════════════
// The whole premise of this indicator is that the network turns before price.
// This is the block that actually measures the gap. A pivot is only known
// i_divPivR bars after it happens, so a divergence confirms that many bars
// late by construction.

float pvLow  = ta.pivotlow(low, i_divPivL, i_divPivR)
float pvHigh = ta.pivothigh(high, i_divPivL, i_divPivR)

var float prevLoPx   = na
var float prevLoComp = na
var int   prevLoBar  = na
var float prevHiPx   = na
var float prevHiComp = na
var int   prevHiBar  = na

bool bullDiv = false
bool bearDiv = false

if not na(pvLow)
    float loPx   = low[i_divPivR]
    float loComp = compLine[i_divPivR]
    int   loBar  = bar_index - i_divPivR
    if not na(prevLoBar) and (loBar - prevLoBar) <= i_divMaxBars
        bullDiv := loPx < prevLoPx and loComp > prevLoComp
    prevLoPx   := loPx
    prevLoComp := loComp
    prevLoBar  := loBar

if not na(pvHigh)
    float hiPx   = high[i_divPivR]
    float hiComp = compLine[i_divPivR]
    int   hiBar  = bar_index - i_divPivR
    if not na(prevHiBar) and (hiBar - prevHiBar) <= i_divMaxBars
        bearDiv := hiPx > prevHiPx and hiComp < prevHiComp
    prevHiPx   := hiPx
    prevHiComp := hiComp
    prevHiBar  := hiBar

var int lastDivBar = na
var int lastDivDir = 0
if bullDiv
    lastDivBar := bar_index
    lastDivDir := 1
if bearDiv
    lastDivBar := bar_index
    lastDivDir := -1
bool  divFresh = not na(lastDivBar) and (bar_index - lastDivBar) <= i_divMaxBars
string divLabel = not divFresh ? "-" : lastDivDir == 1 ? "BULL" : "BEAR"

// ═══════════════════════════════════════════════════════════════════════════════
// CROSS AGE — how long since the last buy or sell cross, and which way
// ═══════════════════════════════════════════════════════════════════════════════

var int lastXbar = na
var int lastXdir = 0
if buyDot
    lastXbar := bar_index
    lastXdir := 1
if sellDot
    lastXbar := bar_index
    lastXdir := -1
int    barsSinceX = na(lastXbar) ? na : bar_index - lastXbar
string lastXLabel = lastXdir == 1 ? "BUY" : lastXdir == -1 ? "SELL" : "-"

// ═══════════════════════════════════════════════════════════════════════════════
// STATUS TABLE
// ═══════════════════════════════════════════════════════════════════════════════

// Helper function for score color (must be global scope)
// Table colour rule. Applied to anything on the -100..100 score scale.
f_sClr(float s) => s >= i_tblDead ? i_tblBullClr : s <= -i_tblDead ? i_tblBearClr : i_tblNeutClr

tablePos = switch i_tblPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

if i_showTable and barstate.islast
    var table tbl = table.new(tablePos, 5, 10, border_width=1, border_color=#333355)

    color hBg = #1a1a2e
    color rBg = #0d0d1a
    color dim = #d0d0d0

    // Regime
    string regime = compVal >= 50 ? "STRONG" :
         compVal >= 20 ? "HEALTHY" :
         compVal >= -20 ? "NEUTRAL" :
         compVal >= -50 ? "WEAK" : "STRESSED"
    // Backgrounds stay dark enough for white text to read on every state.
    color regimeClr = compVal >= 50 ? color.new(i_tblBullClr, 25) :
         compVal >= 20 ? color.new(i_tblBullClr, 50) :
         compVal >= -20 ? #2a2a4a :
         compVal >= -50 ? color.new(i_tblBearClr, 50) : color.new(i_tblBearClr, 25)

    // Composite cells key off the regime band, not the metric threshold, so
    // the number and the regime word can never disagree.
    color compClr = compVal >= 20 ? i_tblBullClr : compVal <= -20 ? i_tblBearClr : i_tblNeutClr

    // Row 0: Header
    table.cell(tbl, 0, 0, "BTC", text_color=color.white, bgcolor=#2a2a4a, text_size=size.small)
    table.cell(tbl, 1, 0, "ONCHAIN", text_color=color.white, bgcolor=#2a2a4a, text_size=size.small)
    table.cell(tbl, 2, 0, regime, text_color=color.white, bgcolor=color.new(regimeClr, 30), text_size=size.small)
    table.cell(tbl, 3, 0, str.tostring(math.round(compVal, 1)), text_color=compClr, bgcolor=#2a2a4a, text_size=size.small)
    table.cell(tbl, 4, 0, str.tostring(liveCount) + "/6", text_color=liveCount == 6 ? i_tblNeutClr : i_tblBearClr, bgcolor=#2a2a4a, text_size=size.small)

    // Row 1: Composite / Signal / Hist
    table.cell(tbl, 0, 1, "Comp", text_color=dim, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(math.round(compLine, 1)), text_color=compClr, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 2, 1, "Signal", text_color=dim, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 3, 1, str.tostring(math.round(signalLine, 1)), text_color=f_sClr(signalLine), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 4, 1, str.tostring(math.round(hist, 1)), text_color=f_sClr(hist), bgcolor=hBg, text_size=size.small)

    // Row 2: Separator
    table.cell(tbl, 0, 2, "Metric", text_color=i_tblHdrClr, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, 2, "Raw", text_color=i_tblHdrClr, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 2, 2, "Score", text_color=i_tblHdrClr, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 3, 2, "Rank", text_color=i_tblHdrClr, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 4, 2, "Contrib", text_color=i_tblHdrClr, bgcolor=rBg, text_size=size.small)

    // Row 3: SOPR
    table.cell(tbl, 0, 3, "SOPR", text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(nz(soprRaw, 1), 4)), text_color=nz(soprRaw, 1) >= 1 ? i_tblBullClr : i_tblBearClr, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 2, 3, str.tostring(math.round(soprScore, 0)), text_color=f_sClr(soprScore), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 3, 3, str.tostring(math.round(soprRank, 0)) + "%", text_color=f_sClr(soprScore), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 4, 3, soprLive ? str.tostring(math.round(soprCon, 1)) : "DEAD", text_color=soprLive ? f_sClr(soprScore) : i_tblBearClr, bgcolor=hBg, text_size=size.small)

    // Row 4: Active Addresses
    table.cell(tbl, 0, 4, "Active", text_color=color.white, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(math.round(nz(activeAddr) / 1000, 0)) + "K", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 2, 4, str.tostring(math.round(activeScore, 0)), text_color=f_sClr(activeScore), bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 3, 4, str.tostring(math.round(activeRank, 0)) + "%", text_color=f_sClr(activeScore), bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 4, 4, activeLive ? str.tostring(math.round(activeCon, 1)) : "DEAD", text_color=activeLive ? f_sClr(activeScore) : i_tblBearClr, bgcolor=rBg, text_size=size.small)

    // Row 5: New Addresses
    table.cell(tbl, 0, 5, "New", text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(math.round(nz(newAddr) / 1000, 0)) + "K", text_color=dim, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 2, 5, str.tostring(math.round(newScore, 0)), text_color=f_sClr(newScore), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 3, 5, str.tostring(math.round(newRank, 0)) + "%", text_color=f_sClr(newScore), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 4, 5, newLive ? str.tostring(math.round(newCon, 1)) : "DEAD", text_color=newLive ? f_sClr(newScore) : i_tblBearClr, bgcolor=hBg, text_size=size.small)

    // Row 6: Tx Fees
    table.cell(tbl, 0, 6, "Fees$", text_color=color.white, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, 6, "$" + str.tostring(math.round(nz(txFeesUsd) / 1000, 0)) + "K", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 2, 6, str.tostring(math.round(feesScore, 0)), text_color=f_sClr(feesScore), bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 3, 6, str.tostring(math.round(feesRank, 0)) + "%", text_color=f_sClr(feesScore), bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 4, 6, feesLive ? str.tostring(math.round(feesCon, 1)) : "DEAD", text_color=feesLive ? f_sClr(feesScore) : i_tblBearClr, bgcolor=rBg, text_size=size.small)

    // Row 7: Hash Rate
    table.cell(tbl, 0, 7, "Hash", text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 1, 7, str.tostring(math.round(nz(hashRate) / 1e18, 0)) + "EH", text_color=dim, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 2, 7, str.tostring(math.round(hashScore, 0)), text_color=f_sClr(hashScore), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 3, 7, str.tostring(math.round(hashRank, 0)) + "%", text_color=f_sClr(hashScore), bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 4, 7, hashLive ? str.tostring(math.round(hashCon, 1)) : "DEAD", text_color=hashLive ? f_sClr(hashScore) : i_tblBearClr, bgcolor=hBg, text_size=size.small)

    // Row 8: Sending Addresses
    table.cell(tbl, 0, 8, "Sends", text_color=color.white, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 1, 8, str.tostring(math.round(nz(sendAddr) / 1000, 0)) + "K", text_color=dim, bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 2, 8, str.tostring(math.round(sendScore, 0)), text_color=f_sClr(sendScore), bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 3, 8, str.tostring(math.round(sendRank, 0)) + "%", text_color=f_sClr(sendScore), bgcolor=rBg, text_size=size.small)
    table.cell(tbl, 4, 8, sendLive ? str.tostring(math.round(sendCon, 1)) : "DEAD", text_color=sendLive ? f_sClr(sendScore) : i_tblBearClr, bgcolor=rBg, text_size=size.small)

    // Row 9: divergence and cross age
    table.cell(tbl, 0, 9, "Div", text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 1, 9, divLabel, text_color=divLabel == "BULL" ? i_tblBullClr : divLabel == "BEAR" ? i_tblBearClr : i_tblNeutClr, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 2, 9, "Last X", text_color=dim, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 3, 9, na(barsSinceX) ? "-" : str.tostring(barsSinceX) + "b", text_color=dim, bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 4, 9, lastXLabel, text_color=lastXdir == 1 ? i_tblBullClr : lastXdir == -1 ? i_tblBearClr : i_tblNeutClr, bgcolor=hBg, text_size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// BUILD STAMP - appended last, so no existing export column moves
// ═══════════════════════════════════════════════════════════════════════════════
// Prefixed "BOC BUILD" rather than plain "BUILD": this indicator shares charts
// with SwingFlow and the engines, and two BUILD columns collide in one CSV
// (the Opus48MAX lesson). Version is the VALUE, not the title (the XDEV 6 lesson).

plot(1.8, "BOC BUILD", color=color.new(color.white, 100), display=display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE MARKERS AND EXPORT SURFACE
// ═══════════════════════════════════════════════════════════════════════════════
// Everything below is appended AFTER every plot that existed in 1.1, so no
// exported column changes position.
//
// The markers are pinned to the pane edges: bull along the bottom, bear along
// the top, which is also where each one forms - a bearish divergence at a
// price high, a bullish one at a low. location.top and location.bottom take
// no part in pane scaling, so the triangles stay visible at any zoom and can
// never stretch the pane.
//
// The series stays a conditional float that goes to na when there is no
// divergence - never a bare bool. offset=-i_divPivR walks the marker back
// onto the pivot bar it describes; only the height has moved.
plotshape(i_showDiv and bullDiv ? compLine[i_divPivR] : na, "Bull Div",
     style=shape.triangleup, location=location.bottom, color=i_divBullClr,
     size=size.small, offset=-i_divPivR)
plotshape(i_showDiv and bearDiv ? compLine[i_divPivR] : na, "Bear Div",
     style=shape.triangledown, location=location.top, color=i_divBearClr,
     size=size.small, offset=-i_divPivR)

plot(liveCount,   "BOC Live",    color=color.new(color.white, 100), display=display.data_window)
plot(bullDiv ? 1 : 0, "BOC BullDiv", color=color.new(color.white, 100), display=display.data_window)
plot(bearDiv ? 1 : 0, "BOC BearDiv", color=color.new(color.white, 100), display=display.data_window)
plot(barsSinceX,  "BOC BarsX",   color=color.new(color.white, 100), display=display.data_window)
plot(lastXdir,    "BOC LastX",   color=color.new(color.white, 100), display=display.data_window)

plot(soprScore,   "BOC SoprScore",   color=color.new(color.white, 100), display=display.data_window)
plot(soprRank,    "BOC SoprRank",    color=color.new(color.white, 100), display=display.data_window)
plot(activeScore, "BOC ActiveScore", color=color.new(color.white, 100), display=display.data_window)
plot(activeRank,  "BOC ActiveRank",  color=color.new(color.white, 100), display=display.data_window)
plot(newScore,    "BOC NewScore",    color=color.new(color.white, 100), display=display.data_window)
plot(newRank,     "BOC NewRank",     color=color.new(color.white, 100), display=display.data_window)
plot(feesScore,   "BOC FeesScore",   color=color.new(color.white, 100), display=display.data_window)
plot(feesRank,    "BOC FeesRank",    color=color.new(color.white, 100), display=display.data_window)
plot(hashScore,   "BOC HashScore",   color=color.new(color.white, 100), display=display.data_window)
plot(hashRank,    "BOC HashRank",    color=color.new(color.white, 100), display=display.data_window)
plot(sendScore,   "BOC SendScore",   color=color.new(color.white, 100), display=display.data_window)
plot(sendRank,    "BOC SendRank",    color=color.new(color.white, 100), display=display.data_window)
plot(normBars,    "BOC Window",      color=color.new(color.white, 100), display=display.data_window)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(buyDot, title="Buy Cross", message="{{ticker}} BitcoinOnChain: Composite crossed above signal in weak territory — on-chain recovery initiating")
alertcondition(sellDot, title="Sell Cross", message="{{ticker}} BitcoinOnChain: Composite crossed below signal in strong territory — on-chain weakening")
alertcondition(ta.crossover(compLine, 0 * _s), title="Zero Cross Up", message="{{ticker}} BitcoinOnChain: Composite crossed above zero — on-chain health turning positive")
alertcondition(ta.crossunder(compLine, 0 * _s), title="Zero Cross Down", message="{{ticker}} BitcoinOnChain: Composite crossed below zero — on-chain health turning negative")
alertcondition(compVal >= 50, title="Strong Chain", message="{{ticker}} BitcoinOnChain: On-chain health STRONG — structural support for price")
alertcondition(compVal <= -50, title="Stressed Chain", message="{{ticker}} BitcoinOnChain: On-chain health STRESSED — structural headwind")
alertcondition(nz(soprRaw, 1) < 0.98, title="SOPR Capitulation", message="{{ticker}} BitcoinOnChain: SOPR below 0.98 — holders selling at significant loss, capitulation zone")
alertcondition(bullDiv, title="Bull Divergence", message="{{ticker}} BitcoinOnChain: price made a lower low while the chain made a higher low - accumulation divergence")
alertcondition(bearDiv, title="Bear Divergence", message="{{ticker}} BitcoinOnChain: price made a higher high while the chain made a lower high - distribution divergence")
alertcondition(liveCount < 6, title="Feed Dead", message="{{ticker}} BitcoinOnChain: an on-chain feed stopped reporting - the composite is running on fewer than six metrics")
alertcondition(nz(soprRaw, 1) > 1.05, title="SOPR Euphoria", message="{{ticker}} BitcoinOnChain: SOPR above 1.05 — holders taking significant profit, euphoria zone")
````
