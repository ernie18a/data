# Killzone Sweep [UgurTash]

- url: https://www.tradingview.com/script/tpynOafT-Killzone-Sweep-UgurTash/
- type: indicator
- pine_id: PUB;d86f9dec8f55444cb3e2e77adfcc3ea8
- version: 1.0

## Description

Killzone Sweep: Sessions, Liquidity Raids and Depth Statistics [UgurTash]

## What this is

Three things in one script, and they are built to be read in this order.

A **session framework**: four blocks (Asia, London, New York AM, New York PM), each with an inner kill zone, each read on the clock of the market that produces it.

A **liquidity sweep engine** that detects every raid on a tracked level and measures it, rather than assuming it reverses.

A **statistics panel** that reports what those raids actually did on your symbol, bucketed by depth, net of the round trip cost you set.

The point of the third part is to tell you whether the first two are worth trading on this instrument. On many symbols the answer will be no, and that is a result, not a failure of the tool.

## The premise, stated plainly

This is not "a level was swept, therefore price reverses". Order flow research (Osler, Journal of Finance) separates two kinds of resting order: triggering stop orders propagates a move, triggering take profit orders reverses it. Both leave the same footprint on a chart. A mechanical sweep then reverse rule, measured honestly, comes out negative.

What distinguishes the two outcomes empirically is **depth**, and every sweep here is measured on two independent axes:

**Extension**, from the reference open (session open by default) to the swept extreme, in ATR. How far price had already travelled before it took the level.

**Penetration**, from the swept level to the swept extreme, in ATR. How hard it went through once it got there.

A level tagged by half an ATR of extension and two ticks of penetration is not the same event as one reached after three ATR and pushed half an ATR beyond. The panel keeps them apart and reports each bucket separately.

## Why this is not another kill zone script

Three parts of it are not cosmetic variations on the genre.

**Each session is read on its own market clock.** Asia on Tokyo time, London on London time, both New York blocks on New York time. Tokyo does not observe daylight saving, London and New York do, and they change on different dates. A script that writes all four windows in one timezone is correct for roughly half the year and an hour out for the rest. This removes that instead of documenting it.

**A sweep is defined over a reclaim window in minutes, not as a single bar wick.** A bar based definition is a property of the bar, not of the market: on 15m one wick qualifies, while on 5m the same excursion is three bars and the middle one closes beyond the level, which retires it as a break and produces no event at all. Same price action, opposite answer. The resolution horizon is in minutes for the same reason.

**The statistics are conditional and they charge a cost.** Not one headline win rate, but a per bucket breakdown with a t statistic beside every number and a round trip toll subtracted from every resolved trade.

## How a sweep becomes a measured outcome

The pool is built from the previous day's high and low and from completed session highs and lows, up to 24 live levels. A level that is closed through is retired, because a pool that has been broken is not liquidity any more.

A raid is registered when price breaches a level and closes back inside it within the **reclaim window** (30 minutes by default).

From there the **entry trigger** decides what counts as the trade:

**None** enters at the close of the reclaiming bar. Earliest entry, widest stop, and the rule the raw statistics are built on.

**Displacement close** (the default) waits for a close beyond the reclaim bar's opposite extreme. The cheap version of a structure shift, separating a raid the market rejected from one it merely paused at.

**Displacement plus FVG retracement** then waits for price to return into the imbalance that displacement left. Better price and a tighter stop, at the cost of every setup price never comes back to.

The stop sits beyond the extreme reached during the raid, plus 0.25 ATR. The target is either a fixed R (2.0 by default) or the nearest unraided pool on the opposite side, in which case each trade carries its own R and the panel reports the real number. An event still open after the horizon (1440 minutes) is booked as unresolved and excluded. A bar that touches both stop and target is booked as a loss, because a chart carries no intrabar ordering.

## The cost column is the part most panels leave out

Commission, spread and slippage are a fixed toll in percent of price, while risk is whatever the stop width happens to be. So the toll in R is cost divided by stop width, and it does not shrink when you tighten your stop. At the default 0.095 percent (one round trip at Binance USDT-M taker rates plus a tick), a 1 percent wide stop gives up about 0.10R and a 0.10 percent wide stop gives up about 0.95R.

This matters more than it sounds, because it reverses a conclusion. Any setting that produces tighter stops raises the win rate, since a fixed R target sits closer in absolute price. Gross, it looks better. Net, it can be the worst cell in the panel. Set this field to your own venue's number before reading anything else, and set it to 0 only if you want to see the flattering version.

## Reading the panel

Seven columns per row:

**n**, the sample. Under 30 it turns amber, because that row is a story rather than a measurement.

**win%**, the hit rate of the fixed R trade. Not the answer column: a win rate can always be bought by shrinking the target.

**R/trade**, net of cost. This is the answer column, and it is only coloured when the t beside it clears 2.

**t**, mean R divided by its own standard error. Below 2 the row cannot be told apart from a coin whatever R says, so both numbers go grey. Read it with the number of rows in mind: keeping the best of ten cells is not the same test as looking at one, and under pure noise the best of ten sits at t = 1.5 half the time. A lone row at 1.4 in a panel of ten is what noise looks like.

**unres%**, never reached stop or target inside the horizon. A large share means the stop and target do not fit this timeframe, and every other number in the row comes from the minority that resolved.

**rev%**, the published 50 percent retrace statistic. It is not a trade you could take and it flatters shallow events by construction. Kept so the familiar number is visible next to one that is harder to game.

Sections can be switched on independently: every sweep, extension buckets, penetration buckets, session, day of week, higher timeframe bias, premium and discount, SMT, and position within the session. Bucket edges are fitted automatically to the first 150 sweeps on the symbol (40th, 70th and 90th percentile), and nothing is counted until that calibration finishes so every counted event shares the same edges.

## Signals

A sweep draws a dot. A sweep that also passes every enabled gate draws an arrow and a setup zone. The dot is a measurement mark, the arrow says the setup exists, and only R/trade says whether it pays.

What gates an arrow: which extension and penetration buckets you allow, direction, day of week, inside an enabled session or anywhere, and optionally a cap on repeated same side raids within one session (a session that keeps raiding one side is trending through those levels, not reverting off them).

**One trade at a time** gates the arrows, the alerts and the drawn setups, but deliberately not the statistics. A panel that only counts the events that happened to arrive while the engine was idle is sampling its own history non randomly, and its buckets stop meaning anything.

**The adaptive gate** is the one filter here that is not fitted. It reads only events that had already resolved before the current bar, so on any given bar it knows exactly what a trader standing there would have known. A bucket is allowed to signal while its own walk forward record clears the bar you set (100 resolved events, t of 2 by default), and it switches off again when it stops clearing it. Early history produces nothing at all. Choosing a session or a depth bucket by reading the finished panel is the dishonest version of the same idea, because the panel already knows how every one of those trades ended.

## Filters, all off by default

Higher timeframe bias (EMA, HTF candle or midnight open), premium and discount halves, an SMT check against a correlated symbol, and position within the session.

They are off because a filter can only ever remove setups, so with all of them off the engine behaves as if they did not exist and each one can be switched on alone and read off the panel. Each also has its own panel section, counted whether the filter is on or off, which shows what it would have done before you commit to it.

That comparison is in sample on this symbol's history, so treat a clean split over 200 events as a candidate rather than a finding, and prefer filters that also have a reason behind them. Turn one on at a time. Switch on five and you will never know which one did it, and you will have fitted all five to the same history.

## Trade management, also off by default

Breakeven at a chosen R, a partial at the first target with the runner protected at entry and sent to a second target, and a percentage trailing stop that activates after a chosen R. With all three off, a trade ends at its target, its stop, or the horizon.

## On the chart

Session boxes are drawn out to the scheduled close the moment the session opens, so you can see how much of the block is left instead of watching it grow candle by candle. The part after the kill zone carries a fainter share of the same colour (two non overlapping areas, so it is genuinely lighter rather than a second layer stacked on top). Session high and low lines are dotted, run to the same scheduled close, and are drawn from the same extremes the engine turns into liquidity pools, so what you see is what it trades.

Also available: session mid line, range projections from a chosen session, FVG boxes with an automatic height threshold, previous day high, low and equilibrium, higher timeframe candles on the right with a close countdown, and the midnight open. The session layer hides itself above a timeframe you choose (60 minutes by default), since a three hour block means nothing on a daily chart.

## Alerts

Nine named conditions (buyside and sellside raided, long and short setup armed, long and short entry, partial banked, take profit, stop loss), and every stage also fires through `alert()`, so a single "Any alert() function call" alert covers the whole engine and its message carries the measured depths. Signals evaluate on closed bars, so set the trigger to Once Per Bar Close. Note that TradingView captures your settings when the alert is created and keeps using them, so configure the script first and create the alert afterwards.

## How to use it, in order

1. Set the round trip cost to your venue's number.
2. Leave every filter off and let the bucket calibration finish, then read the "every sweep" row. That is your baseline.
3. Read R/trade together with t. Ignore win% as a decision input.
4. Turn on one filter or one gate, compare its two rows, then decide.
5. If nothing clears t = 2 anywhere, the honest conclusion is that this symbol does not pay this idea. The panel is doing its job when it tells you that.

## Honest limitations

The panel is not a backtest. No order is placed. The round trip cost is charged, which was the largest omission, but queue position, partial fills, funding and the intrabar path are still missing and all of them run in the same optimistic direction.

An FVG limit is assumed to fill exactly at its level with no queue and no rejection, which flatters FVG mode specifically.

The SMT test compares N bar extremes, not matched swing pivots. It is a screen, and it needs the peer to share trading hours.

Bias reads the last closed higher timeframe bar, so it does not repaint, but it is one bar stale by construction.

Auto bucket edges are fitted to the first 150 sweeps of whatever history your chart loaded, so rows are only comparable within one calibration.

The reclaim window makes timeframes agree far better than a single bar definition, but not perfectly, since closes are quantised by bar size.

A bucket with n under roughly 30 is a story, not a measurement.

*Nothing here is financial advice.*

## Source Code

````pine
//@version=6
// =============================================================================
//  Killzone Sweep [UgurTash]
//  Session framework + liquidity-sweep engine + conditional statistics panel
//  + depth-gated signals + four optional confluence filters.
//
//  WHY THIS EXISTS
//  ---------------
//  The premise is NOT "a level was swept, therefore price reverses". Published
//  order-flow research (Osler, Journal of Finance) shows that triggering resting
//  STOP orders PROPAGATES a trend while triggering resting TAKE-PROFIT orders
//  REVERSES it. A raid on its own is ambiguous, and a mechanical
//  sweep-then-reverse rule measures out negative.
//
//  What separates the two outcomes empirically is DEPTH. Every sweep is measured
//  on two independent axes:
//
//    EXTENSION    reference open -> swept extreme, in ATR
//    PENETRATION  swept level    -> swept extreme, in ATR
//
//  Each event is bucketed on both, tracked to resolution, and the panel reports
//  what actually happened ON YOUR SYMBOL.
//
//  EVERY FILTER IS OFF BY DEFAULT, AND THAT IS THE POINT
//  ----------------------------------------------------
//  A filter can only ever REMOVE setups. With all of them off the engine behaves
//  exactly as it did before they existed, so each one can be switched on alone
//  and read off the panel. Each filter also has its own panel section splitting
//  events by whether they satisfied it, which is the only way to find out
//  whether the filter earns its keep on this instrument instead of assuming it.
//
//  Turn on one. Read the panel. Then decide.
//
//  SESSIONS ARE ANCHORED TO THEIR OWN MARKETS
//  ------------------------------------------
//  Four sessions, each with an inner kill zone, and each read on the clock of
//  the market that produces it: Asia on Tokyo time, London on London time, both
//  New York blocks on New York time. That is the part most session scripts get
//  wrong. A script that writes every window in one timezone, or in UTC, is
//  correct for roughly half the year and an hour out for the other half,
//  because Tokyo does not observe daylight saving, London and New York do, and
//  they switch on different dates. Anchoring each window to its own market
//  removes the problem instead of documenting it.
//
//  TIMEFRAME CONSISTENCY
//  ---------------------
//  A sweep is defined over a RECLAIM WINDOW measured in minutes, not as a
//  single-bar wick. A bar-based definition is a property of the BAR, not of the
//  market: on 15m one wick qualifies, while on 5m the same excursion is three
//  bars and the middle one closes beyond the level - which retired the level as
//  a break and produced no event at all. Same price action, opposite answer.
//  The resolution horizon is in minutes for the same reason.
//
//  Read HONEST LIMITATIONS at the bottom before trusting a number in the panel.
// =============================================================================

indicator("Killzone Sweep: Sessions, Liquidity Raids and Depth Statistics [UgurTash]", "Killzone Sweep [UgurTash]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 300)

// =============================================================================
//  GROUPS
// =============================================================================
G_MKT  = "1 · Market preset"
G_SESS = "2 · Sessions and kill zones"
G_ENG  = "3 · Sweep engine"
G_OUT  = "4 · Outcome measurement"
G_SIG  = "5 · Signals"
G_FLT  = "6 · Optional filters — all off by default"
G_MGT  = "6b · Trade management — all off by default"
G_FVG  = "6c · Fair Value Gaps"
G_TAB  = "7 · Statistics panel"
G_VIS  = "8 · Session visuals"
G_CTX  = "9 · Context — HTF candles, PDH/PDL, midnight"

// =============================================================================
//  1 · MARKET PRESET
// =============================================================================
i_preset = input.string("Custom (my windows below)", "Preset", group = G_MKT,
     options = ["Custom (my windows below)", "Exchange sessions", "ICT kill zones"],
     tooltip = "Custom is the default and it is the only setting that reads the windows in group 2. The other two REPLACE all eight of them, and editing group 2 then changes nothing on the chart.\n\nExchange sessions: the real opening hours of the four blocks that make up a trading day, each written on its own market clock. Asia 0800-1455 Tokyo, London 0700-1425 London, New York AM 0930-1425 and PM 1430-1755 New York.\n\nICT kill zones: the classic set, all four written in NEW YORK time. Asia 2000-0000, London 0200-0500, New York AM 0700-1000, New York PM 1000-1200. Choosing this also switches the per-market clock OFF, because these windows are defined in New York time by construction and reading the Asia one on a Tokyo clock would put it in the wrong place.")

i_tz = input.string("America/New_York", "Fallback timezone", group = G_MKT,
     options = ["America/New_York", "Europe/London", "UTC", "Asia/Tokyo", "Europe/Istanbul"],
     tooltip = "Used for the midnight line, the previous-day levels, the day boundary and the day-of-week split, always. It is ALSO what every session window is read in when the per-market clock in group 2 is switched off.\n\nIt is NOT UTC unless you set it to UTC here, and it is not the exchange timezone of the chart.")

// =============================================================================
//  2 · SESSIONS AND KILL ZONES
//  Four blocks, each a session with an inner kill zone. The windows below are
//  written on each market's OWN clock, which is what keeps them correct through
//  a daylight-saving change instead of only in winter.
// =============================================================================
i_marketTz = input.bool(true, "Read each session on its own market clock", group = G_SESS,
     tooltip = "ON, and the default. Asia is read on Asia/Tokyo, London on Europe/London, both New York blocks on America/New_York. Tokyo has no daylight saving while London and New York do and switch on different dates, so a single clock for all four is an hour out somewhere for several weeks a year. This removes that.\n\nOFF, and all four windows are read on the fallback timezone from group 1 instead, which is what you want if you prefer to think in one clock.\n\nForced OFF while the preset is set to ICT kill zones, because that set is defined in New York time for every window including the Asian one.")

// --- Asia --------------------------------------------------------------------
i_s1e  = input.bool(true, "Asia", group = G_SESS, inline = "s1")
i_s1c  = input.session("0800-1455", "", group = G_SESS, inline = "s1",
     tooltip = "Tokyo cash plus the Sydney overlap that precedes it. Written on Tokyo time, which does not observe daylight saving, so this window never moves.")
i_s1k  = input.color(color.new(#fa7b05, 95), "", group = G_SESS, inline = "s1")
i_s1z  = input.session("0800-1255", "Asia kill zone", group = G_SESS, inline = "z1")
i_s1ze = input.bool(true, "", group = G_SESS, inline = "z1")

// --- London ------------------------------------------------------------------
i_s2e  = input.bool(true, "London", group = G_SESS, inline = "s2")
i_s2c  = input.session("0700-1425", "", group = G_SESS, inline = "s2",
     tooltip = "Opens with Frankfurt at 08:00 Central European time, which is 07:00 in London, and runs to the New York handover.")
i_s2k  = input.color(color.new(#118502, 95), "", group = G_SESS, inline = "s2")
i_s2z  = input.session("0700-0955", "London kill zone", group = G_SESS, inline = "z2")
i_s2ze = input.bool(true, "", group = G_SESS, inline = "z2")

// --- New York AM -------------------------------------------------------------
i_s3e  = input.bool(true, "New York AM", group = G_SESS, inline = "s3")
i_s3c  = input.session("0930-1425", "", group = G_SESS, inline = "s3",
     tooltip = "From the New York cash open. On an index future this is the window where most of the day's information arrives, which is why it starts at 09:30 and not at 07:00.")
i_s3k  = input.color(color.new(#b40f0f, 95), "", group = G_SESS, inline = "s3")
i_s3z  = input.session("0930-1155", "New York AM kill zone", group = G_SESS, inline = "z3")
i_s3ze = input.bool(true, "", group = G_SESS, inline = "z3")

// --- New York PM -------------------------------------------------------------
i_s4e  = input.bool(true, "New York PM", group = G_SESS, inline = "s4")
i_s4c  = input.session("1430-1755", "", group = G_SESS, inline = "s4",
     tooltip = "The afternoon block, through the cash close and the settle that follows it.")
i_s4k  = input.color(color.new(#0c6dff, 95), "", group = G_SESS, inline = "s4")
i_s4z  = input.session("1430-1555", "New York PM kill zone", group = G_SESS, inline = "z4")
i_s4ze = input.bool(true, "", group = G_SESS, inline = "z4")

i_restFill = input.float(0.45, "Fill after the kill zone, relative to the kill zone", 0.0, 1.0, step = 0.05, group = G_SESS,
     tooltip = "The session is drawn as TWO areas that do not overlap, which is what makes a genuinely fainter tone possible rather than a darker one stacked on top.\n\nThe first runs from the session open to the end of the kill zone and carries the full colour from the picker. The second runs from there to the session close and carries this fraction of it. 0 leaves the rest of the session bare, which is what the reference indicator does. 1 makes both halves identical, so the session reads as one block.")

// =============================================================================
//  3 · SWEEP ENGINE
// =============================================================================
i_reclaimMin = input.int(30, "Reclaim window (minutes)", 1, 1440, group = G_ENG,
     tooltip = "After price breaches a level it has this long to close back inside. Measured in MINUTES, not bars, so a 5m and a 15m chart see the same event. Set it below one bar's duration for the old single-bar-wick behaviour.")

i_refMode = input.string("Active session open", "Extension reference", group = G_ENG,
     options = ["Active session open", "Midnight open", "Daily open"])

i_atrLen = input.int(14, "ATR length", 2, 200, group = G_ENG)
i_atrSrc = input.string("Chart timeframe", "Depth normaliser", options = ["Chart timeframe", "Daily", "Weekly"], group = G_ENG,
     tooltip = "Both depths are divided by this ATR. Keep it on the chart timeframe for intraday work: a three-hour session's move is a small fraction of a DAILY ATR, so normalising intraday sweeps by the daily range crushes every event into the smallest bucket.")

i_usePDHL   = input.bool(true, "Track previous day high / low", group = G_ENG)
i_useSessHL = input.bool(true, "Track completed session highs / lows", group = G_ENG)
i_maxPools  = input.int(24, "Max live levels", 4, 60, group = G_ENG)

i_bktMode = input.string("Auto (quantiles)", "Bucket edges", options = ["Auto (quantiles)", "Manual"], group = G_ENG,
     tooltip = "Auto watches the first N sweeps on this symbol and sets the edges at the 40th / 70th / 90th percentile of what it finds. Nothing is counted until calibration finishes, so every counted event uses the same edges.")
i_calibN  = input.int(150, "Auto: sweeps to calibrate on", 40, 1000, group = G_ENG)

i_eb1 = input.float(0.25, "Manual extension edges (ATR)", 0.01, 50, step = 0.05, group = G_ENG, inline = "eb")
i_eb2 = input.float(0.50, "", 0.01, 50, step = 0.05, group = G_ENG, inline = "eb")
i_eb3 = input.float(1.00, "", 0.01, 50, step = 0.05, group = G_ENG, inline = "eb")

i_pb1 = input.float(0.10, "Manual penetration edges (ATR)", 0.005, 50, step = 0.01, group = G_ENG, inline = "pb")
i_pb2 = input.float(0.30, "", 0.005, 50, step = 0.01, group = G_ENG, inline = "pb")

// =============================================================================
//  4 · OUTCOME MEASUREMENT
// =============================================================================
i_confirmMode = input.string("Displacement close", "Entry trigger", group = G_OUT,
     options = ["None", "Displacement close", "Displacement + FVG retracement"],
     tooltip = "None enters at the close of the bar that reclaimed the level - earliest entry, widest stop, and the rule the raw statistics are built on. Displacement waits for a close beyond the reclaim bar's opposite extreme: the cheap version of a structure shift, separating a raid the market rejected from one it merely paused at. FVG retracement then waits for price to come back into the gap that displacement left - better price and a tighter stop, at the cost of every setup price never returns to.")
i_dispMin  = input.int(60, "Displacement: window (minutes)", 1, 1440, group = G_OUT)
i_fvgDepth = input.float(0.5, "FVG: entry depth (0 near edge · 1 far edge)", 0, 1, step = 0.05, group = G_OUT)
i_fvgMin   = input.int(120, "FVG: fill window (minutes)", 1, 2880, group = G_OUT)
i_fvgFall  = input.bool(false, "FVG: fall back to the displacement close if no gap forms", group = G_OUT,
     tooltip = "Off means a displacement that leaves no imbalance produces no trade at all. Leaving it off is the purer test of whether the gap matters.")

i_tgtMode = input.string("Fixed R", "Target", options = ["Fixed R", "Opposite liquidity"], group = G_OUT,
     tooltip = "Fixed R is blind to what stands in front of the trade. Opposite liquidity aims at the nearest still-unraided pool on the far side, because that is where price is being drawn - each trade then carries its own R and the panel reports the real number.")
i_tgtR    = input.float(2.0, "Fixed R: target", 0.1, 20, step = 0.1, group = G_OUT)
i_minR    = input.float(1.0, "Opposite liquidity: minimum R", 0.2, 10, step = 0.1, group = G_OUT)

i_stopAtr    = input.float(0.25, "Stop beyond extreme (ATR)", 0.01, 10, step = 0.05, group = G_OUT)
i_horizonMin = input.int(1440, "Resolution horizon (minutes)", 5, 20160, group = G_OUT,
     tooltip = "In minutes so the measurement window is identical on every timeframe. An event still open past this is booked as unresolved and excluded from net R.")
i_revPctIn   = input.float(50, "Reversion threshold (% of extension)", 5, 100, step = 5, group = G_OUT)

// COSTS
// -----
// Until this existed the panel reported gross R and nothing else, which is the
// single most flattering thing a measurement tool can do. Commission, spread and
// slippage are a FIXED toll in percent of price, while risk is whatever the stop
// width happens to be, so the toll in R is cost / stop width. A 0.25% stop on
// Binance USDT-M taker fees gives away about 0.38R before the trade has done
// anything. That is not a rounding error against an edge measured in hundredths.
//
// Default is one round trip at Binance USDT-M taker rates plus a tick: two sides
// at 0.045% and 0.005% of slippage. Set it to your own venue's number. Set it to
// 0 only if you want to see the old, flattering figure again.
float i_costPct = input.float(0.095, "Round-trip cost (% of price)", 0, 5, step = 0.005, group = G_OUT,
     tooltip = "Subtracted from every resolved trade's R, converted at that trade's own stop width: cost in R = cost%% of entry / stop distance.\n\nThis is why a tight stop is expensive. The toll does not shrink with your risk, so the narrower the stop the larger the share of it the venue takes. At 0.095%% a 1%%-wide stop costs about 0.10R and a 0.10%%-wide stop costs about 0.95R.")

float i_minRiskAtr = input.float(0.0, "Min stop width (x ATR), 0 = off", 0, 10, step = 0.05, group = G_OUT,
     tooltip = "Reject a setup whose stop is TIGHTER than this. The mirror of the Max Risk filter in group 6, and it exists because of the line above: a stop narrow enough that the round-trip cost rivals the risk produces a trade whose R reads fine and whose money is gone.\n\nLeave it at 0 until the panel shows you what the cost column does to each bucket.")
i_ambigLoss  = input.bool(true, "A bar touching both stop and target counts as a loss", group = G_OUT,
     tooltip = "A chart carries no intrabar ordering information. Conservative, and still a guess.")

revPct    = i_revPctIn / 100.0
reclaimMs = i_reclaimMin * 60000
horizonMs = i_horizonMin * 60000
dispMs    = i_dispMin * 60000
fvgMs     = i_fvgMin * 60000

// =============================================================================
//  5 · SIGNALS
// =============================================================================
i_sigOn     = input.bool(true, "Enable signals", group = G_SIG)
i_sigKZonly = input.bool(true, "Only inside enabled sessions", group = G_SIG)

i_eb0Sig = input.bool(false, "ext < b1", group = G_SIG, inline = "es")
i_eb1Sig = input.bool(true,  "b1-b2",    group = G_SIG, inline = "es")
i_eb2Sig = input.bool(true,  "b2-b3",    group = G_SIG, inline = "es")
i_eb3Sig = input.bool(false, "> b3",     group = G_SIG, inline = "es")

i_pb0Sig = input.bool(true,  "pen tag", group = G_SIG, inline = "ps")
i_pb1Sig = input.bool(true,  "normal",  group = G_SIG, inline = "ps")
i_pb2Sig = input.bool(false, "break",   group = G_SIG, inline = "ps")

i_sideAllow = input.string("Both", "Allowed direction", options = ["Both", "Long only", "Short only"], group = G_SIG,
     tooltip = "Published index data shows lows revert 5-6 percentage points more often than highs. Worth measuring on your own symbol before assuming symmetry.")

i_dowMon  = input.bool(true, "Mon", group = G_SIG, inline = "dw")
i_dowTue  = input.bool(true, "Tue", group = G_SIG, inline = "dw")
i_dowWed  = input.bool(true, "Wed", group = G_SIG, inline = "dw")
i_dowThu  = input.bool(true, "Thu", group = G_SIG, inline = "dw")
i_dowFri  = input.bool(true, "Fri", group = G_SIG, inline = "dw")
i_dowWknd = input.bool(true, "Sat/Sun", group = G_SIG, inline = "dw")

i_maxRaids = input.int(0, "Skip after N same-side raids in a session", 0, 10, group = G_SIG,
     tooltip = "0 disables it. A session that keeps raiding one side is trending through those levels, not reverting off them.")

// THE ONLY FILTER HERE THAT IS NOT FITTED
// ---------------------------------------
// Every other switch in this group is a decision you make by looking at the
// panel, which means looking at this symbol's whole history and keeping what
// worked on it. That is fitting, and it is why the panel flags anything under
// t = 2 as indistinguishable from a coin.
//
// This gate is different. It reads only events that had already RESOLVED before
// the current bar, so it is walk-forward: on any given bar it knows exactly what
// a trader standing there would have known. A bucket switches on when its own
// record clears the bar below, and switches off again if it stops clearing it.
i_adaptive  = input.bool(false, "Adaptive gate: only signal in buckets whose record clears the bar below", group = G_SIG,
     tooltip = "Walk-forward, not fitted: it reads only events resolved BEFORE the current bar, so it never uses information the trader would not have had. Early history produces nothing at all until a sample accumulates, and a bucket can switch on and off over time.\n\nThis is the honest way to filter. Choosing a session or a depth bucket by reading the finished panel is the dishonest way, because the panel already knows how every one of those trades ended.")
i_minSample = input.int(100, "Minimum sample for the adaptive gate", 5, 2000, group = G_SIG,
     tooltip = "How many resolved events a bucket needs before it is allowed to signal at all. Raised from 20 because 20 is nowhere near enough to tell a 2R rule apart from a coin: at a 30%% hit rate the standard error over 20 trades is about 0.33R, which is larger than any edge this engine has produced.")
float i_minT = input.float(2.0, "Minimum t for the adaptive gate", 0.5, 6.0, step = 0.1, group = G_SIG,
     tooltip = "A bucket has to be positive by at least this many standard errors, not merely positive. Requiring only a positive sign lets a bucket through on a coin flip, which is how an adaptive gate ends up chasing noise instead of filtering it.\n\n2 is the conventional bar. Raise it if you are watching many buckets at once, because keeping the best of ten cells is a different test from looking at one: under pure noise the best of ten sits at t = 1.5 half the time.")

i_oneAtATime = input.bool(false, "One trade at a time", group = G_SIG,
     tooltip = "No new SIGNAL fires while another signalled setup is armed or open. Read this carefully, because it does not work the way RaidShift's version does and the difference matters: every sweep is still MEASURED, because a panel that only counts the events that happened to arrive while the engine was idle is sampling its own history non-randomly and its buckets stop meaning anything. So this gates the arrows, the alerts and the drawn setups, not the statistics.")

// =============================================================================
//  6b · TRADE MANAGEMENT
//  Ported from RaidShift [UgurTash]. All off by default: with everything off a
//  trade ends at its target, its stop, or the horizon, exactly as before.
// =============================================================================
beOn       = input.bool(false, 'Move Stop To Breakeven', group = G_MGT, tooltip = 'Once the trade is this many R in profit, the stop moves to the entry. It raises the WIN RATE mechanically by converting some losses into scratches, but it usually LOWERS expectancy, because winners that would have run get stopped out on the pullback. Scratch exits are counted separately so the setting cannot flatter itself.')
beTrigR    = input.float(1.0, 'Breakeven Trigger (R)', minval = 0.1, step = 0.1, group = G_MGT)
partialOn  = input.bool(false, 'Partial Take Profit', group = G_MGT, tooltip = 'Bank part of the position at the first target, run the rest to a second one. When on, the stop moves to breakeven the moment the first target fills, so the runner can only end at +R or flat. Every trade then reports a WEIGHTED R, and the totals stay comparable with single-target trades.')
partialPct = input.float(50.0, 'Partial Size (%)', minval = 10, maxval = 90, step = 5, group = G_MGT)
rrTarget2  = input.float(3.0, 'Second Target (R)', minval = 0.2, step = 0.1, group = G_MGT, tooltip = 'The runner target in Fixed R mode, and the fallback in Opposite Liquidity mode when no second pool qualifies.')
trailOn    = input.bool(false, 'Trailing Stop', group = G_MGT, tooltip = 'Once the trade is far enough in profit the stop follows the best price reached, staying a fixed percentage behind it. It only ever moves toward profit. This exists for the case a fixed runner target creates: price runs to the opposite liquidity, raids it and turns, and the trade sits through the entire reversal waiting for a target it will now never see.')
trailTrigR = input.float(2.0, 'Trail Activation (R)', minval = 0.1, step = 0.1, group = G_MGT)
trailPct   = input.float(0.5, 'Trail Distance (%)', minval = 0.05, maxval = 20, step = 0.05, group = G_MGT, tooltip = 'How far behind the best price the stop follows, as a percentage of price. Tight values react fast to a reversal and are stopped out by ordinary noise; wide values survive noise and give back more at the turn. A trail that is too tight converts winners into small winners, which flatters win rate while lowering net R, so judge it on net R alone.')

// =============================================================================
//  6 · OPTIONAL FILTERS
//  Every one is off by default. Switch on ONE, read its panel section, decide.
// =============================================================================
// --- Higher-timeframe bias ---------------------------------------------------
i_biasMode   = input.string("Off", "Bias source", options = ["Off", "HTF EMA", "HTF candle", "Midnight open"], group = G_FLT,
     tooltip = "Taking longs into a higher-timeframe downtrend is structurally worse than taking them with it. HTF EMA reads the trend on a higher timeframe, HTF candle reads that candle's own direction, Midnight open is the classic ICT daily proxy. The HTF readings use the last CLOSED higher-timeframe bar, so nothing repaints.")
i_biasTF     = input.timeframe("240", "Bias timeframe", group = G_FLT)
i_biasLen    = input.int(50, "Bias EMA length", 2, 500, group = G_FLT)
i_biasFilter = input.bool(false, "Only signal with the bias", group = G_FLT)

// --- Premium / discount ------------------------------------------------------
i_zoneSrc    = input.string("Previous day", "Premium/discount range", options = ["Previous day", "Current day", "Active session"], group = G_FLT,
     tooltip = "Where price sits inside a reference range. Buying in the lower half and selling in the upper half is the discipline this encodes; the panel tells you whether it pays here.")
i_zoneFilter = input.bool(false, "Longs in discount only, shorts in premium only", group = G_FLT)
i_discMax    = input.float(0.5, "Long allowed below", 0.05, 1, step = 0.05, group = G_FLT, inline = "z1")
i_premMin    = input.float(0.5, "Short allowed above", 0, 0.95, step = 0.05, group = G_FLT, inline = "z1")

// --- SMT divergence ----------------------------------------------------------
i_smtOn      = input.bool(false, "Ask a correlated symbol", group = G_FLT, inline = "sm")
i_smtSym     = input.symbol("", "", group = G_FLT, inline = "sm",
     tooltip = "Leave empty to auto-pair BTC↔ETH and ES↔NQ. If our chart took its extreme and the peer did not, participation was one-sided - that is an SMT divergence. This is the SIMPLIFIED version: it compares N-bar extremes rather than matched swing pivots, so it is a useful screen and not the same measurement a dedicated SMT tool makes.")
i_smtLb      = input.int(20, "SMT lookback (bars)", 3, 200, group = G_FLT)
i_smtRequire = input.bool(false, "Only signal when the peer diverged", group = G_FLT)
i_smtLabels  = input.bool(true, "Mark divergent raids on the chart", group = G_FLT,
     tooltip = "Needs the peer switched on above. A divergence is only marked on a bar that actually produced a sweep, so a symbol with no pairing and no manual peer will show nothing at all.")
i_smtBullCol = input.color(#1d4ed8, "Bullish", inline = "smc", group = G_FLT)
i_smtBearCol = input.color(#f23645, "Bearish", inline = "smc", group = G_FLT)

// --- Position inside the session --------------------------------------------
i_spFilter = input.bool(false, "Only signal in the first part of a session", group = G_FLT,
     tooltip = "Published index data: early-session extremes fade more often, late ones less - not because late is cursed but because there is no runway left. This is that finding, made switchable.")
i_spMax    = input.float(0.6, "Session fraction elapsed, max", 0.05, 1, step = 0.05, group = G_FLT)

// =============================================================================
//  6c · FAIR VALUE GAPS
//  A standalone layer, ported from RaidShift. It draws whether or not the FVG
//  entry mode is selected, and the entry mode picks its gap out of this same
//  registry so the box you see is the box the trade waits on.
// =============================================================================
showFvg    = input.bool(true,  'Draw FVG boxes', group = G_FVG)
fvgAutoThr = input.bool(true,  'Auto threshold', group = G_FVG,
     tooltip = 'Cumulative mean body-change threshold that filters out insignificant gaps. Without it every one-tick imbalance counts and the chart fills up.')
fvgMinAtr  = input.float(0.0, 'Min gap height (x ATR)', minval = 0.0, step = 0.05, group = G_FVG,
     tooltip = '0 disables it.')
showFvgCe  = input.bool(false, 'Draw the entry level inside the gap', group = G_FVG)
maxFvgKeep = input.int(20, 'FVGs kept in memory', minval = 3, maxval = 40, group = G_FVG)
fvgFilled  = input.string('Dim it', 'When a gap is filled', options = ['Dim it', 'Remove it'], group = G_FVG,
     tooltip = 'A gap is filled the moment price trades back through its far edge, and on an intraday crypto chart most of them fill within hours. That is why only a handful are ever visible at once, and why a falling market leaves only bearish gaps standing: the bullish ones below price get filled immediately. Dim it keeps the filled gap on the chart at 94 transparency, which is nearly invisible. Remove it deletes the box outright.')
fvgBullCol = input.color(color.new(#089981, 50), 'Bullish', inline = 'fv', group = G_FVG)
fvgBearCol = input.color(color.new(#f23645, 50), 'Bearish', inline = 'fv', group = G_FVG)
fvgFillCol = input.color(color.new(#787b86, 80), 'Filled',  inline = 'fv', group = G_FVG,
     tooltip = 'The colour a gap takes once price has traded back through it, used only when the option above is set to Dim it. Its own picker, its own opacity, no calculation on top.')

// =============================================================================
//  7 · STATISTICS PANEL
// =============================================================================
i_showTab = input.bool(true, "Show panel", group = G_TAB)
i_tabPos  = input.string("Top right", "Position", options = ["Top right", "Middle right", "Bottom right", "Bottom left", "Top left"], group = G_TAB)
i_tabSide = input.string("All", "Count which side", options = ["All", "Long only", "Short only"], group = G_TAB)
i_secExt  = input.bool(true,  "Extension",   group = G_TAB, inline = "sec")
i_secPen  = input.bool(false, "Penetration", group = G_TAB, inline = "sec")
i_secKZ   = input.bool(true,  "Session",     group = G_TAB, inline = "sec")
i_secDow  = input.bool(false, "Day",         group = G_TAB, inline = "sec2")
i_secBias = input.bool(false, "Bias",        group = G_TAB, inline = "sec2")
i_secZone = input.bool(false, "Prem/disc",   group = G_TAB, inline = "sec2")
i_secSmt  = input.bool(false, "SMT",         group = G_TAB, inline = "sec3")
i_secSPos = input.bool(false, "Session pos", group = G_TAB, inline = "sec3")
i_secLeg  = input.bool(true,  "Legend",      group = G_TAB, inline = "sec3")
i_tabTxt  = input.color(#D8DCE4, "Text", group = G_TAB, inline = "tc")
i_tabBg   = input.color(color.new(#14171E, 12), "Back", group = G_TAB, inline = "tc")

// =============================================================================
//  8 · SESSION VISUALS
// =============================================================================
i_maxTF = input.int(60, "Hide above this timeframe (minutes)", 1, 1440, group = G_VIS)

i_drawBoxes = input.bool(true, "Session boxes", group = G_VIS, inline = "v1")
i_boxFull   = input.bool(true, "Draw full width at session open", group = G_VIS, inline = "v1",
     tooltip = "The box is drawn out to the session's scheduled end the moment it opens, so you can see how much of it is left. Top and bottom still track the running high and low.\n\nThis is the part kept from the old version deliberately: a session framework that only draws what has already happened tells you where you have been. Knowing where the block ENDS is what lets you judge how much runway a setup still has.\n\nThe session high and low lines follow the same rule: with this on they are drawn out to the scheduled close too, so they end where the colour ends instead of being dragged along one candle at a time. With it off, box and lines both grow bar by bar.")
// i_drawKZ is retired. The split is governed by "Fill after the kill zone" in
// group 2: set it to 0 and the session is filled only across its kill zone,
// which is exactly what the reference indicator does.

// SESSION HIGH AND LOW
// --------------------
// Two horizontal lines per session, at the extreme the session actually made.
// They are what turns a shaded box into a usable level: the session high and
// low are where the resting orders sit, and the engine already treats them as
// liquidity pools. Drawing them makes the thing the engine trades visible.
i_drawHL   = input.bool(true, "Session high / low lines", group = G_VIS, inline = "hl")
i_hlLive   = input.bool(true, "while it is still running", group = G_VIS, inline = "hl",
     tooltip = "ON and the two lines follow the running extreme through the session, which is what makes them useful live. OFF and nothing is drawn until the session closes and the levels are final.")
i_hlExtend = input.int(0, "Extend past the close (bars)", 0, 300, group = G_VIS,
     tooltip = "How far to the right the two lines keep running past the session's scheduled close. 0 ends them exactly where the block ends, which is the reference behaviour and the default. Raise it if you want the levels carried into the hours where the engine actually trades them, which is the premise of the sweep side.")
i_hlWidth  = input.int(1, "Line width", 1, 4, group = G_VIS, inline = "hlw")
i_hlStyle  = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = G_VIS, inline = "hlw")
i_hlLabel  = input.bool(false, "Label the lines", group = G_VIS)

i_drawMid  = input.bool(false, "Session mid line", group = G_VIS)
i_txtFollow = input.bool(true, "Label and lines take the session colour", group = G_VIS,
     tooltip = "ON, and the default. The session name, the mid line and the high / low lines are drawn in that session's own colour at full strength, so the block reads as one object and you can tell Asia from London without reading the label. One picker per session in group 2 drives all of it.\n\nOFF, and all of them fall back to the single neutral colour below, which is the older behaviour: readable against any background, and identical for every session.")
i_sessTxt  = input.color(#787b86, "Neutral label and line colour", group = G_VIS,
     tooltip = "Only read when the switch above is off.")
i_keepDraw = input.int(15, "Session boxes kept", 5, 120, group = G_VIS)

i_drawDev  = input.bool(false, "Range projections from", group = G_VIS, inline = "v3")
i_devSrc   = input.string("New York PM", "", options = ["Asia", "London", "New York AM", "New York PM"], group = G_VIS, inline = "v3")
i_devCount = input.int(2, "×", 1, 5, group = G_VIS, inline = "v3",
     tooltip = "Only the most recent day's set is drawn. Keeping every past day's projections turns a chart into a ruled notebook.")

// "Every sweep" is the measurement view and it is deliberately not the default:
// a symbol with a thousand detected sweeps gets a thousand dots, which is honest
// and unreadable. "Gate-eligible only" shows the ones that passed the depth and
// penetration buckets but were stopped by something else, which is the useful
// middle ground between a wall of dots and only the arrows.
i_dotMode    = input.string("Gate-eligible only", "Sweep dots", options = ["Off", "Gate-eligible only", "Every sweep"], group = G_VIS)
i_drawSweeps = input.bool(false, "Depth label on every sweep", group = G_VIS)

i_drawSetup  = input.bool(true, "Setup zones on signals", group = G_VIS)
i_riskCol    = input.color(color.new(#C0392B, 50), "Setup risk zone",   group = G_VIS)
i_rewardCol  = input.color(color.new(#1B9E6F, 50), "Setup reward zone", group = G_VIS)
// Same rule as the session boxes: the colour picker's own opacity slider drives
// fill and outline together.
i_keepTrades = input.int(20, "Finished setups kept on chart", 1, 80, group = G_VIS)
i_colLong    = input.color(#1B9E6F, "Long",  group = G_VIS, inline = "v6")
i_colShort   = input.color(#C0392B, "Short", group = G_VIS, inline = "v6")

// =============================================================================
//  9 · CONTEXT
//  The previous-day levels and the projected higher-timeframe block are ported
//  from RaidShift [UgurTash], so the two scripts draw the same context the same
//  way and a level looks identical on either chart.
// =============================================================================
// ── Previous Day (PDH / PDL) ─────────────────────────────────────────────────
bool   showPD      = input.bool(true, 'Show PDH / PDL', group = G_CTX)
bool   showPdEq    = input.bool(true, 'Show previous day equilibrium', group = G_CTX)
color  pdCol       = input.color(#787b86, 'Color', inline = 'pd', group = G_CTX)
int    pdWidth     = input.int(1, 'Width', minval = 1, maxval = 4, inline = 'pd', group = G_CTX)
int    pdExtend    = input.int(15, 'Extend Right (bars)', minval = 0, maxval = 100, group = G_CTX)
bool   showPdLbl   = input.bool(true, 'Labels', group = G_CTX)
string pdLabelMode = input.string('Day + Date', 'PDH Label Shows', options = ['Day', 'Date', 'Day + Date', 'Neither'], group = G_CTX, tooltip = 'The stamp carried by the PDH label only. PDL stays clean, since one stamp per session is enough to read the chart. After a weekend or a holiday the previous daily bar can be several calendar days back, which is exactly what the stamp is there to show.')

// ── Higher Timeframe Candle Block ────────────────────────────────────────────
bool   showHtfBlock = input.bool(true, 'Show HTF Candles On The Right', group = G_CTX)
bool   htfAuto      = input.bool(true, 'Auto-Select Timeframe', group = G_CTX, tooltip = 'Picks one step up automatically: 1H on a 15m chart, 4H on a 1H chart, and so on. Turn this off to use the manual timeframe below.')
string htfManual    = input.timeframe('60', 'Manual Timeframe', group = G_CTX)
int    htfCount     = input.int(8, 'Candles Shown', minval = 1, maxval = 12, group = G_CTX)
int    htfOffset    = input.int(20, 'Offset From Price (bars)', minval = 1, group = G_CTX)
string htfSize      = input.string('Small', 'Candle Width', options = ['Small', 'Medium', 'Large'], group = G_CTX)
int    htfGap       = input.int(1, 'Candle Spacing', minval = 1, maxval = 4, group = G_CTX)
bool   htfShowEq    = input.bool(false, 'Candle EQ (50%) Line', group = G_CTX)
bool   htfShowTimer = input.bool(true, 'Close Countdown', group = G_CTX)
// Three parts of a candle, three rows, each split into bull and bear. Nothing
// is derived from anything else any more: the border used to be hard-wired to
// the body colour and the wick was a single colour shared by both directions,
// so an up candle and a down candle could never have different wicks.
// Setting a body to full transparency and leaving its border opaque gives the
// hollow style, which was not reachable before either.
color  htfBullBody  = input.color(color.new(#089981, 0), 'Body   bull', inline = 'hb1', group = G_CTX)
color  htfBearBody  = input.color(color.new(#f23645, 0), 'bear',        inline = 'hb1', group = G_CTX)
color  htfBullBrd   = input.color(color.new(#089981, 0), 'Border bull', inline = 'hb2', group = G_CTX)
color  htfBearBrd   = input.color(color.new(#f23645, 0), 'bear',        inline = 'hb2', group = G_CTX)
color  htfBullWick  = input.color(color.new(#089981, 0), 'Wick   bull', inline = 'hb3', group = G_CTX)
color  htfBearWick  = input.color(color.new(#f23645, 0), 'bear',        inline = 'hb3', group = G_CTX)
int    htfBrdWidth  = input.int(1, 'Border width', minval = 1, maxval = 4, group = G_CTX, inline = 'hb4')
int    htfWickWidth = input.int(1, 'Wick width',   minval = 1, maxval = 4, group = G_CTX, inline = 'hb4')
color  htfTxtCol    = input.color(#787b86, 'Timeframe and countdown text', group = G_CTX)

// ── Midnight open ────────────────────────────────────────────────────────────
// Bounded to the same right edge as PDH and PDL. It used to carry extend.right,
// which is why it ran to the end of the chart and never stopped.
i_drawMidnight = input.bool(true, "Show midnight open", group = G_CTX, inline = "m1")
i_mnCol        = input.color(#2D62B6, "", group = G_CTX, inline = "m1")
i_mnStyle      = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], group = G_CTX, inline = "m1")
i_mnWidth      = input.int(1, "Width", minval = 1, maxval = 4, group = G_CTX, inline = "m2")
i_mnLabel      = input.bool(true, "Label", group = G_CTX, inline = "m2")

// =============================================================================
//  PRESET RESOLUTION
//  Ternaries, not if-blocks: session strings must stay simple-qualified.
// =============================================================================
// A preset is active only when the user picked one. The default is Custom, so
// out of the box the inputs in group 2 are what the engine reads: change a time
// there and the chart changes with it.
presetOn  = i_preset != "Custom (my windows below)"
presetICT = i_preset == "ICT kill zones"

// The ICT set is written in New York time for every window, the Asian one
// included, so the per-market clock has to come off with it. Anything else puts
// a 2000-0000 Asia window on a Tokyo clock, eight hours away from where it
// belongs.
marketTz = i_marketTz and not presetICT

sess1 = not presetOn ? i_s1c : presetICT ? "2000-0000" : "0800-1455"
sess2 = not presetOn ? i_s2c : presetICT ? "0200-0500" : "0700-1425"
sess3 = not presetOn ? i_s3c : presetICT ? "0700-1000" : "0930-1425"
sess4 = not presetOn ? i_s4c : presetICT ? "1000-1200" : "1430-1755"

kz1 = not presetOn ? i_s1z : presetICT ? "2000-2200" : "0800-1255"
kz2 = not presetOn ? i_s2z : presetICT ? "0200-0400" : "0700-0955"
kz3 = not presetOn ? i_s3z : presetICT ? "0830-1000" : "0930-1155"
kz4 = not presetOn ? i_s4z : presetICT ? "1000-1100" : "1430-1555"

// Each session's own clock. With the per-market switch off they all collapse to
// the fallback timezone, which is the old single-clock behaviour.
tz1 = marketTz ? "Asia/Tokyo"       : i_tz
tz2 = marketTz ? "Europe/London"    : i_tz
tz3 = marketTz ? "America/New_York" : i_tz
tz4 = marketTz ? "America/New_York" : i_tz

// Short timezone name for the panel, so the active clock is visible on the
// chart instead of only inside the settings dialog.
tzShort = i_tz == "America/New_York" ? "New York" : i_tz == "Europe/London" ? "London" : i_tz == "Asia/Tokyo" ? "Tokyo" : i_tz == "Europe/Istanbul" ? "Istanbul" : "UTC"
clockTxt = marketTz ? "each session on its own market clock" : "all sessions in " + tzShort + " time"

NAME_ASIA = "Asia"
NAME_LDN  = "London"
NAME_NYAM = "New York AM"
NAME_NYPM = "New York PM"

sessName(i) =>
    switch i
        0 => NAME_ASIA
        1 => NAME_LDN
        2 => NAME_NYAM
        3 => NAME_NYPM
        4 => "Prev day"
        => "Outside"

// --- Ported from RaidShift [UgurTash], unchanged ------------------------------
// @function  Short label for a timeframe ('15m', '1H', '1D' …).
f_tfLabel(simple string tf) =>
    int s = timeframe.in_seconds(tf)
    s < 60 ? str.tostring(s) + 's' : s < 86400 ? (s % 3600 == 0 ? str.tostring(s / 3600) + 'H' : str.tostring(math.round(s / 60.0)) + 'm') : s % 604800 == 0 ? str.tostring(s / 604800) + 'W' : s % 86400 == 0 ? str.tostring(s / 86400) + 'D' : tf

// @function  Three-letter weekday name for a timestamp, in the exchange timezone.
f_dayName(int t) =>
    string res = ''
    if not na(t)
        res := switch dayofweek(t, syminfo.timezone)
            dayofweek.monday    => 'Mon'
            dayofweek.tuesday   => 'Tue'
            dayofweek.wednesday => 'Wed'
            dayofweek.thursday  => 'Thu'
            dayofweek.friday    => 'Fri'
            dayofweek.saturday  => 'Sat'
            =>                     'Sun'
    res

// @function  Pairs the SMT peer from the chart symbol, so the same divergence
//            reads identically from either side of a pair. Returns na where no
//            sensible pairing exists. Built from syminfo.prefix rather than
//            syminfo.tickerid, because tickerid can carry more than
//            "prefix:ticker" (settlement, adjustment and session flags).
f_smtAutoPeer() =>
    string t   = syminfo.ticker
    string res = na
    string m = str.match(t, '^M?(ES|NQ)[1\\w][!\\d]+$')
    if m != ''
        int    off    = str.startswith(m, 'M') ? 1 : 0
        string prefix = str.substring(m, off, 2 + off)
        string suffix = str.substring(m, 2 + off)
        res := 'CME_MINI:' + (off == 1 ? 'M' : '') + (prefix == 'NQ' ? 'ES' : 'NQ') + suffix
    else if str.contains(t, 'MYM') or str.contains(t, 'M2K')
        res := 'CME_MINI:MES1!'
    else if str.contains(t, 'YM') or str.contains(t, 'RTY')
        res := 'CME_MINI:ES1!'
    else if str.contains(t, 'MGC')
        res := 'COMEX:SIL1!'
    else if str.contains(t, 'GC')
        res := 'COMEX:SI1!'
    else if str.contains(t, 'SIL')
        res := 'COMEX:MGC1!'
    else if str.contains(t, 'SI')
        res := 'COMEX:GC1!'
    else if str.contains(t, 'MBT')
        res := 'CME:MET1!'
    else if str.contains(t, 'MET')
        res := 'CME:MBT1!'
    else if str.startswith(t, 'BTC')
        res := syminfo.prefix + ':' + str.replace(t, 'BTC', 'ETH', 0)
    else if str.startswith(t, 'ETH')
        res := syminfo.prefix + ':' + str.replace(t, 'ETH', 'BTC', 0)
    res

// @function  Time left until the forming HTF candle closes.
f_htfCountdown(int openTime, simple string tf) =>
    string result = '--:--'
    if barstate.isrealtime and not na(openTime)
        int remainingSec = math.round((openTime + timeframe.in_seconds(tf) * 1000 - timenow) / 1000)
        if remainingSec > 0
            int hrs  = math.floor(remainingSec / 3600)
            int mins = math.floor((remainingSec % 3600) / 60)
            int secs = remainingSec % 60
            result := (hrs > 0 ? str.tostring(hrs, '00') + ':' : '') + str.tostring(mins, '00') + ':' + str.tostring(secs, '00')
    result

// SESSION STRING PARSING
// ----------------------
// Everything about a session is derived from its own "HHMM-HHMM" string here,
// as minutes since local midnight. The whole session layer used to ask
// time(timeframe.period, sess, tz) whether a bar was inside the window, and
// that call does something the settings dialog never mentions: it INTERSECTS
// the window with the symbol's own trading session. On a chart whose data does
// not cover the window - a futures contract set to regular hours, a stock
// without extended hours - a 0700-1000 window silently becomes "from whenever
// this exchange happens to open until 1000", which is how a three hour setting
// ends up drawn as an hour and a half. Reading the wall clock instead makes a
// window mean exactly what it says on every symbol.
sessCore(s) =>
    p = str.pos(s, ":")
    na(p) ? s : str.substring(s, 0, p)

// Minutes since midnight for the opening time of the window, na if unparseable.
sessStartMin(s) =>
    core = sessCore(s)
    int out = na
    if str.length(core) >= 9
        out := int(str.tonumber(str.substring(core, 0, 2))) * 60 + int(str.tonumber(str.substring(core, 2, 4)))
    out

// Minutes since midnight for the closing time. 0000 means midnight, which is
// why the span below wraps instead of going negative.
sessEndMin(s) =>
    core = sessCore(s)
    int out = na
    if str.length(core) >= 9
        out := int(str.tonumber(str.substring(core, 5, 7))) * 60 + int(str.tonumber(str.substring(core, 7, 9)))
    out

// Milliseconds from a SESSION's scheduled open to its KILL ZONE's scheduled
// close. This is what lets the first area box be drawn to its full width the
// moment the session opens, instead of being grown bar by bar.
kzEndOffMs(sess, kz) =>
    a = sessStartMin(sess)
    b = sessEndMin(kz)
    na(a) or na(b) ? 0 : int((b > a ? b - a : 1440 - a + b) * 60000)

// How long a session runs, so the box can be drawn to its scheduled end the
// moment it opens.
sessSpanMs(s) =>
    a = sessStartMin(s)
    b = sessEndMin(s)
    na(a) or na(b) ? 0 : int((b > a ? b - a : 1440 - a + b) * 60000)

// Optional day mask, the ":23456" tail TradingView allows on a session string.
// 1 is Sunday, 7 is Saturday, matching dayofweek().
sessDayOk(s, tz) =>
    p = str.pos(s, ":")
    bool ok = true
    if not na(p)
        mask = str.substring(s, p + 1)
        if str.length(mask) > 0
            ok := str.contains(mask, str.tostring(dayofweek(time, tz)))
    ok

// AREA DENSITY
// ------------
// Liquidity Swings [LuxAlgo] declares its area colour at transparency 50 and
// then draws the box at 80:
//     topAreaCss = input(color.new(color.red, 50), 'Area')
//     box.new(..., bgcolor = color.new(topAreaCss, 80), border_color = na)
// So its settings read 50 while the screen gets 80. In opacity terms: the
// picker says 50, the box renders at 20. The screen shows exactly 0.4 of
// whatever the picker holds.
//
// That single ratio is taken straight from those two numbers, nothing invented,
// and applied to every area fill here. The consequence is the part LuxAlgo
// cannot do: because the ratio is applied to whatever the picker currently
// holds rather than to a fixed 80, the slider stays live. Drag it down and the
// box fades out; drag it to the top and the fill lands at 60 rather than solid,
// so it never swallows the candles.
f_area(col) =>
    color.new(col, 100.0 - (100.0 - color.t(col)) * 0.4)

// The stretch of the session that follows the kill zone. It is a SEPARATE box
// that starts where the first one stops, so the two never overlap and this can
// actually be fainter. Painting it over the first one could only ever make it
// darker, because stacked translucent fills composite additively.
f_restArea(col) =>
    color.new(col, 100.0 - (100.0 - color.t(col)) * i_restFill)

// A session's picker carries the transparency meant for its AREA fill. Text and
// lines must not inherit it, or a faint box leaves an unreadable label and an
// invisible level. This strips it, so one picker drives both without the fill
// setting dragging the ink down with it.
f_ink(col) =>
    i_txtFollow ? color.new(col, 0) : i_sessTxt

lineStyleOf(s) => s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

// =============================================================================
//  NORMALISER
// =============================================================================
atrLoc  = ta.atr(i_atrLen)
atrDay  = request.security(syminfo.tickerid, "D", ta.atr(i_atrLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
atrWk   = request.security(syminfo.tickerid, "W", ta.atr(i_atrLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
atrPick = i_atrSrc == "Daily" ? atrDay : i_atrSrc == "Weekly" ? atrWk : atrLoc
ATR     = na(atrPick) or atrPick <= 0 ? atrLoc : atrPick
atrOk   = not na(ATR) and ATR > 0

visible = timeframe.isintraday and timeframe.multiplier <= i_maxTF

// =============================================================================
//  SESSION TRACKER — one call site per window, independent state each
// =============================================================================
sessionState(sess, tz) =>
    var bool  wasIn  = false
    var float sHi    = na
    var float sLo    = na
    var float sOp    = na
    var int   sStart = na
    var int   sBarT  = na
    var int   sLag   = 0
    var float pHi    = na
    var float pLo    = na

    sMin  = sessStartMin(sess)
    eMin  = sessEndMin(sess)
    nowM  = hour(time, tz) * 60 + minute(time, tz)
    // Wall clock only. A window whose end is not after its start wraps past
    // midnight, which is what 2000-0000 means.
    inClk = na(sMin) or na(eMin) ? false : eMin > sMin ? (nowM >= sMin and nowM < eMin) : (nowM >= sMin or nowM < eMin)
    inNow = inClk and sessDayOk(sess, tz)

    started = inNow and not wasIn
    ended   = not inNow and wasIn
    if ended
        pHi := sHi
        pLo := sLo
    if started
        sHi := high
        sLo := low
        sOp := open
        // The window opens where the CLOCK says it opens, not where this
        // symbol's first bar of the window happens to sit, so the box and the
        // setting agree. The wrap term covers a window that began before
        // midnight.
        elapsedMin = nowM >= sMin ? nowM - sMin : nowM + 1440 - sMin
        sStart := time - elapsedMin * 60000
        // Where the drawing actually begins. It is the first bar of the window,
        // not the scheduled open, because a box drawn back into a data gap
        // would be painted over the previous session's bars. The two are the
        // same number on any symbol that trades through the window.
        sBarT  := time
        // How late this symbol's data arrives relative to the scheduled open.
        // Zero on a 24 hour symbol. Large on a chart whose trading hours do not
        // cover the window, which is the one case where the drawn box cannot be
        // as wide as the setting.
        sLag := elapsedMin
    else if inNow
        sHi := math.max(nz(sHi, high), high)
        sLo := math.min(nz(sLo, low), low)
    wasIn := inNow
    [inNow, started, ended, sHi, sLo, sOp, sStart, pHi, pLo, sLag, sBarT]

[in0, st0, ed0, hi0, lo0, op0, sb0, ph0, pl0, lg0, bt0] = sessionState(sess1, tz1)
[in1, st1, ed1, hi1, lo1, op1, sb1, ph1, pl1, lg1, bt1] = sessionState(sess2, tz2)
[in2, st2, ed2, hi2, lo2, op2, sb2, ph2, pl2, lg2, bt2] = sessionState(sess3, tz3)
[in3, st3, ed3, hi3, lo3, op3, sb3, ph3, pl3, lg3, bt3] = sessionState(sess4, tz4)

// The kill zones run through the same tracker, so a kill zone box tracks its own
// high and low exactly the way its session does rather than inheriting the
// session's extremes.
[kin0, kst0, ked0, khi0, klo0, kop0, ksb0, kph0, kpl0, klg0, kbt0] = sessionState(kz1, tz1)
[kin1, kst1, ked1, khi1, klo1, kop1, ksb1, kph1, kpl1, klg1, kbt1] = sessionState(kz2, tz2)
[kin2, kst2, ked2, khi2, klo2, kop2, ksb2, kph2, kpl2, klg2, kbt2] = sessionState(kz3, tz3)
[kin3, kst3, ked3, khi3, klo3, kop3, ksb3, kph3, kpl3, klg3, kbt3] = sessionState(kz4, tz4)

// A chart whose trading hours start inside a configured window cannot draw that
// window at full width, and silence about it is exactly what made the box look
// wrong. One bar of slack, because a window that opens between two bars is not
// a coverage problem.
barMin     = math.max(timeframe.in_seconds(timeframe.period) / 60, 1)
covLagMin  = math.max(math.max(i_s1e ? nz(lg0) : 0, i_s2e ? nz(lg1) : 0), math.max(i_s3e ? nz(lg2) : 0, i_s4e ? nz(lg3) : 0))
covShort   = covLagMin > barMin + 1

span0 = sessSpanMs(sess1)
span1 = sessSpanMs(sess2)
span2 = sessSpanMs(sess3)
span3 = sessSpanMs(sess4)

kspan0 = sessSpanMs(kz1)
kspan1 = sessSpanMs(kz2)
kspan2 = sessSpanMs(kz3)
kspan3 = sessSpanMs(kz4)

// Offset from each session's open to its own kill zone's close.
kzOff0 = kzEndOffMs(sess1, kz1)
kzOff1 = kzEndOffMs(sess2, kz2)
kzOff2 = kzEndOffMs(sess3, kz3)
kzOff3 = kzEndOffMs(sess4, kz4)

activeSess = in0 and i_s1e ? 0 : in1 and i_s2e ? 1 : in2 and i_s3e ? 2 : in3 and i_s4e ? 3 : -1

activeOpen = switch activeSess
    0 => op0
    1 => op1
    2 => op2
    3 => op3
    => na
activeHi = switch activeSess
    0 => hi0
    1 => hi1
    2 => hi2
    3 => hi3
    => na
activeLo = switch activeSess
    0 => lo0
    1 => lo1
    2 => lo2
    3 => lo3
    => na
activeStart = switch activeSess
    0 => sb0
    1 => sb1
    2 => sb2
    3 => sb3
    => na
activeSpan = switch activeSess
    0 => span0
    1 => span1
    2 => span2
    3 => span3
    => 0

// The enable flags belong here too: a session the user switched off must not
// reset the per-session raid counter behind their back.
sessionJustStarted = (st0 and i_s1e) or (st1 and i_s2e) or (st2 and i_s3e) or (st3 and i_s4e)

// =============================================================================
//  DAILY REFERENCES
// =============================================================================
isNewDay = timeframe.change("D")

// The first bar of a new calendar day in the chosen timezone. Asking for a
// bar inside a 0000-0001 window fails on any chart whose data does not cover
// midnight, and then the midnight open, the midnight line and the midnight
// bias source all stay empty with no explanation.
mnDay = dayofmonth(time, i_tz)
newMidnight = bar_index > 0 and mnDay != mnDay[1]

var float midnightOpen = na
var int   midnightBar  = na
if newMidnight
    midnightOpen := open
    midnightBar  := time

var float dayOpen = na
var float dHi     = na
var float dLo     = na
if isNewDay
    dayOpen := open
    dHi     := high
    dLo     := low
else
    dHi := math.max(nz(dHi, high), high)
    dLo := math.min(nz(dLo, low), low)

// Previous-day levels come from the symbol's own daily bar, exactly as in
// RaidShift, so the same level sits at the same price on both charts. These
// feed the liquidity pool, the premium/discount range and the drawing below.
[pdH, pdL, pdT] = request.security(syminfo.tickerid, 'D', [high[1], low[1], time_close[1]], lookahead = barmerge.lookahead_on)
float pdEq = not na(pdH) and not na(pdL) ? math.avg(pdH, pdL) : na

refOpen = switch i_refMode
    "Active session open" => na(activeOpen) ? nz(midnightOpen, dayOpen) : activeOpen
    "Midnight open"       => nz(midnightOpen, dayOpen)
    => dayOpen

// =============================================================================
//  OPTIONAL FILTER INPUTS — computed once, applied only where asked
// =============================================================================
// --- Higher-timeframe bias. Reads the last CLOSED HTF bar, so no repaint. -----
[bClose, bOpen, bEma] = request.security(syminfo.tickerid, i_biasTF,
     [close[1], open[1], ta.ema(close, i_biasLen)[1]], barmerge.gaps_off, barmerge.lookahead_off)

biasDir = i_biasMode == "HTF EMA"       ? (na(bClose) or na(bEma) ? 0 : bClose > bEma ? 1 : bClose < bEma ? -1 : 0) :
          i_biasMode == "HTF candle"    ? (na(bClose) or na(bOpen) ? 0 : bClose > bOpen ? 1 : bClose < bOpen ? -1 : 0) :
          i_biasMode == "Midnight open" ? (na(midnightOpen) ? 0 : close > midnightOpen ? 1 : close < midnightOpen ? -1 : 0) : 0

// --- Premium / discount ------------------------------------------------------
zoneHi = i_zoneSrc == "Previous day" ? pdH : i_zoneSrc == "Current day" ? dHi : activeHi
zoneLo = i_zoneSrc == "Previous day" ? pdL : i_zoneSrc == "Current day" ? dLo : activeLo
zoneOk = not na(zoneHi) and not na(zoneLo) and zoneHi > zoneLo
zonePos = zoneOk ? (close - zoneLo) / (zoneHi - zoneLo) : na

// --- SMT peer ----------------------------------------------------------------
// A request.security call cannot be skipped: it runs whether its result is read
// or not, so with SMT off the peer is pointed at the chart's own symbol. That
// series is already loaded, so switching SMT off actually stops the second
// instrument being fetched instead of merely ignoring it.
var string smtAuto   = f_smtAutoPeer()
// ticker.standard strips the settlement, adjustment and session flags that
// syminfo.tickerid can carry, leaving a plain prefix:ticker. Used here because
// this value is compared against, and passed as, ANOTHER instrument's symbol.
var string selfStd   = ticker.standard(syminfo.tickerid)
var string peerSym   = not i_smtOn ? selfStd : (i_smtSym != '' ? i_smtSym : (na(smtAuto) ? selfStd : smtAuto))
var array<string> smtParts = str.split(peerSym, ':')
string smtName = smtParts.size() > 0 ? smtParts.get(smtParts.size() - 1) : peerSym

[peerH, peerL] = request.security(peerSym, timeframe.period, [high, low],
     barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol = true)

// Every ta.* call sits in unconditional global scope. Inside a short-circuiting
// expression they can be skipped on a bar, and a function that depends on its
// own history then returns something different from what it would have.
ourHiN  = ta.highest(high, i_smtLb)
ourLoN  = ta.lowest(low,   i_smtLb)
peerHiN = ta.highest(peerH, i_smtLb)
peerLoN = ta.lowest(peerL,  i_smtLb)

smtValid = i_smtOn and peerSym != selfStd and not na(peerH) and not na(peerL)
ourHiExt = high >= ourHiN
ourLoExt = low  <= ourLoN
peerHiEx = smtValid and not na(peerHiN) and peerH >= peerHiN
peerLoEx = smtValid and not na(peerLoN) and peerL <= peerLoN
smtDivLong  = ourLoExt and not peerLoEx     // we made the low, the peer held
smtDivShort = ourHiExt and not peerHiEx     // we made the high, the peer held

// --- Position inside the active session --------------------------------------
sessProg = activeSess >= 0 and activeSpan > 0 and not na(activeStart) ? (time - activeStart) / activeSpan : na

// =============================================================================
//  LIQUIDITY POOLS
//  state 0 live · 1 breached, waiting for a reclaim · 2 spent
// =============================================================================
type Pool
    float price
    int   dir
    int   src
    int   state
    int   breachAt
    float extreme

var array<Pool> pools = array.new<Pool>()

pushPool(p, d, s) =>
    if not na(p)
        pools.push(Pool.new(p, d, s, 0, na, na))
        while pools.size() > i_maxPools
            pools.shift()
    0

if i_useSessHL
    if ed0 and i_s1e
        pushPool(ph0, 1, 0)
        pushPool(pl0, -1, 0)
    if ed1 and i_s2e
        pushPool(ph1, 1, 1)
        pushPool(pl1, -1, 1)
    if ed2 and i_s3e
        pushPool(ph2, 1, 2)
        pushPool(pl2, -1, 2)
    if ed3 and i_s4e
        pushPool(ph3, 1, 3)
        pushPool(pl3, -1, 3)

if i_usePDHL and isNewDay
    pushPool(pdH, 1, 4)
    pushPool(pdL, -1, 4)

// =============================================================================
//  FAIR VALUE GAPS
//  Ported from RaidShift. One registry, drawn on its own toggle, and the FVG
//  entry mode picks its gap out of this same list, so the box you see is the box
//  the trade is waiting on.
//      bullish : low > high[2]  and close[1] > high[2]
//      bearish : high < low[2]  and close[1] < low[2]
// =============================================================================
type fvgZone
    float top
    float bot
    int   dir
    int   bIdx
    bool  mitigated
    box   bx
    line  ceLine

// Entry price at a depth into the gap, measured from the edge price enters from.
// A bullish gap is entered from its TOP, a bearish gap from its BOTTOM.
f_fvgEntry(top, bot, isBull, frac) =>
    isBull ? top - frac * (top - bot) : bot + frac * (top - bot)

barDelta  = (close[1] - open[1]) / (open[1] * 100)
thrAccum  = ta.cum(math.abs(nz(barDelta)))
fvgThr    = fvgAutoThr and bar_index > 0 ? thrAccum / bar_index * 2 : 0.0
minGapAbs = fvgMinAtr > 0 and not na(atrLoc) ? atrLoc * fvgMinAtr : 0.0

rawBullFvg = low > high[2] and close[1] > high[2] and barDelta > fvgThr and (low - high[2]) >= minGapAbs
rawBearFvg = high < low[2] and close[1] < low[2] and -barDelta > fvgThr and (low[2] - high) >= minGapAbs

var array<fvgZone> fvgs = array.new<fvgZone>()

// Unshifted, so index 0 is always the newest.
if rawBullFvg or rawBearFvg
    float zTop = rawBullFvg ? low : low[2]
    float zBot = rawBullFvg ? high[2] : high
    box   zBx  = na
    line  zCe  = na
    if showFvg and visible
        zBx := box.new(bar_index - 2, zTop, bar_index + 1, zBot, xloc = xloc.bar_index,
             border_color = na,
             bgcolor = f_area(rawBullFvg ? fvgBullCol : fvgBearCol))
        if showFvgCe
            float entryLvl = f_fvgEntry(zTop, zBot, rawBullFvg, i_fvgDepth)
            zCe := line.new(bar_index - 2, entryLvl, bar_index + 1, entryLvl, xloc = xloc.bar_index,
                 color = color.new(rawBullFvg ? fvgBullCol : fvgBearCol, 30), style = line.style_dotted)
    fvgs.unshift(fvgZone.new(zTop, zBot, rawBullFvg ? 1 : -1, bar_index, false, zBx, zCe))

// Lifecycle: a filled gap is closed off, live ones keep extending right.
if fvgs.size() > 0
    for gi = 0 to fvgs.size() - 1
        fvgZone z = fvgs.get(gi)
        if not z.mitigated
            bool filled = z.dir == 1 ? low < z.bot : high > z.top
            if filled
                z.mitigated := true
                if fvgFilled == 'Remove it'
                    if not na(z.bx)
                        z.bx.delete()
                        z.bx := na
                    if not na(z.ceLine)
                        z.ceLine.delete()
                        z.ceLine := na
                else
                    if not na(z.bx)
                        z.bx.set_right(bar_index)
                        z.bx.set_bgcolor(f_area(fvgFillCol))
                    if not na(z.ceLine)
                        z.ceLine.set_x2(bar_index)
                        z.ceLine.set_color(color.new(color.gray, 80))
            else
                if not na(z.bx)
                    z.bx.set_right(bar_index + 1)
                if not na(z.ceLine)
                    z.ceLine.set_x2(bar_index + 1)

while fvgs.size() > maxFvgKeep
    fvgZone oldZ = fvgs.pop()
    if not na(oldZ.bx)
        oldZ.bx.delete()
    if not na(oldZ.ceLine)
        oldZ.ceLine.delete()

// =============================================================================
//  STATISTICS STORE
//  Index = (category * 2 + side) * SLOTS + slot.
//  side 0 long (a low was swept) · side 1 short (a high was swept)
//  slots 0 n | 1 revEligible | 2 revHit | 3 wins | 4 losses | 5 netR
//        6 unresolved | 7 sumExtension | 8 sumPenetration | 9 scratch exits
//        10 sum of R squared, which is what makes a standard error possible
// =============================================================================
SLOTS = 11

var array<float> stExt  = array.new<float>(4 * 2 * SLOTS, 0.0)
var array<float> stPen  = array.new<float>(3 * 2 * SLOTS, 0.0)
var array<float> stKZ   = array.new<float>(5 * 2 * SLOTS, 0.0)
var array<float> stDow  = array.new<float>(7 * 2 * SLOTS, 0.0)
var array<float> stBias = array.new<float>(2 * 2 * SLOTS, 0.0)
var array<float> stZone = array.new<float>(2 * 2 * SLOTS, 0.0)
var array<float> stSmt  = array.new<float>(2 * 2 * SLOTS, 0.0)
var array<float> stSPos = array.new<float>(3 * 2 * SLOTS, 0.0)
var array<float> stAll  = array.new<float>(1 * 2 * SLOTS, 0.0)

stBump(a, cat, side, slot, v) =>
    idx = (cat * 2 + side) * SLOTS + slot
    if idx >= 0 and idx < a.size()
        a.set(idx, a.get(idx) + v)
    0

stRead(a, cat, side, slot) =>
    idx = (cat * 2 + side) * SLOTS + slot
    idx >= 0 and idx < a.size() ? a.get(idx) : 0.0

stView(a, cat, slot) =>
    switch i_tabSide
        "Long only"  => stRead(a, cat, 0, slot)
        "Short only" => stRead(a, cat, 1, slot)
        => stRead(a, cat, 0, slot) + stRead(a, cat, 1, slot)

// =============================================================================
//  BUCKET EDGES
// =============================================================================
var array<float> extSamp = array.new<float>()
var array<float> penSamp = array.new<float>()
var bool  calibDone = false
var float EB1 = na
var float EB2 = na
var float EB3 = na
var float PB1 = na
var float PB2 = na

if not calibDone and i_bktMode == "Manual"
    EB1 := i_eb1
    EB2 := i_eb2
    EB3 := i_eb3
    PB1 := i_pb1
    PB2 := i_pb2
    calibDone := true

bucketExt(v) => v < EB1 ? 0 : v < EB2 ? 1 : v < EB3 ? 2 : 3
bucketPen(v) => v < PB1 ? 0 : v < PB2 ? 1 : 2

dowIdx = dayofweek(time, i_tz) - 1

// =============================================================================
//  SWEEP DETECTION — reclaim window in minutes
// =============================================================================
newSweep  = false
nsDir     = 0
nsExtreme = 0.0
nsExt     = 0.0
nsPen     = 0.0
nsSrc     = -1

if atrOk and pools.size() > 0 and not na(refOpen)
    for i = pools.size() - 1 to 0
        Pool p = pools.get(i)
        if p.state == 0
            breached = p.dir == 1 ? high > p.price : low < p.price
            if breached
                p.state    := 1
                p.breachAt := time
                p.extreme  := p.dir == 1 ? high : low
        else if p.state == 1
            p.extreme := p.dir == 1 ? math.max(p.extreme, high) : math.min(p.extreme, low)

        if p.state == 1
            reclaimed = p.dir == 1 ? close < p.price : close > p.price
            if reclaimed
                p.state := 2
                if not newSweep
                    d = p.dir == 1 ? -1 : 1
                    newSweep  := true
                    nsDir     := d
                    nsExtreme := p.extreme
                    nsPen     := math.abs(p.extreme - p.price) / ATR
                    // extension toward the reversal direction:
                    //   long  (d +1): open above the swept low  -> positive
                    //   short (d -1): open below the swept high -> positive
                    nsExt     := math.max(0.0, (refOpen - p.extreme) * d) / ATR
                    nsSrc     := p.src
            else if time - p.breachAt > reclaimMs
                // never came back inside the window: a break, not a sweep. The
                // level stops being liquidity either way.
                p.state := 2

// --- Same-side raid counter, reset each session ------------------------------
var int raidLongCnt  = 0
var int raidShortCnt = 0
if sessionJustStarted
    raidLongCnt  := 0
    raidShortCnt := 0
if newSweep
    if nsDir == 1
        raidLongCnt += 1
    else
        raidShortCnt += 1
raidOrdinal = nsDir == 1 ? raidLongCnt : raidShortCnt

// =============================================================================
//  TARGETS
// =============================================================================
// Resolves both targets for one setup, adapted from RaidShift's f_resolveTp to
// read this script's pool array.
// @returns [target 1, its R, true when a pool was used, target 2, its R]
f_resolveTp(dir, entry, sl) =>
    risk = dir == 1 ? entry - sl : sl - entry
    float tp  = entry + dir * i_tgtR * risk
    float tp2 = entry + dir * rrTarget2 * risk
    float r1  = i_tgtR
    float r2  = rrTarget2
    bool  used = false
    if i_tgtMode == "Opposite liquidity" and risk > 0
        array<float> cands = array.new<float>()
        if pools.size() > 0
            for i = 0 to pools.size() - 1
                Pool p = pools.get(i)
                if p.state == 0 and ((dir == 1 and p.dir == 1 and p.price > entry) or (dir == -1 and p.dir == -1 and p.price < entry))
                    if math.abs(p.price - entry) / risk >= i_minR
                        cands.push(p.price)
        if cands.size() > 0
            // Ascending, so the nearest qualifying pool is the FIRST element for
            // a long and the LAST for a short.
            array.sort(cands, order.ascending)
            float pick = dir == 1 ? cands.get(0) : cands.get(cands.size() - 1)
            tp   := pick
            r1   := math.abs(pick - entry) / risk
            used := true
            if cands.size() > 1
                float pick2 = dir == 1 ? cands.get(1) : cands.get(cands.size() - 2)
                tp2 := pick2
                r2  := math.abs(pick2 - entry) / risk
    // The runner must always sit BEYOND the first target, whatever the inputs say.
    if risk > 0
        bool bad2 = dir == 1 ? tp2 <= tp : tp2 >= tp
        if bad2
            tp2 := tp + dir * risk
            r2  := math.abs(tp2 - entry) / risk
    [tp, r1, used, tp2, r2]

// =============================================================================
//  EVENTS
// =============================================================================
type Evt
    int   bar
    int   dir
    float extreme
    float entry
    float stop
    float target
    float revTarget
    bool  revValid
    bool  revHit
    float extAtr
    float penAtr
    int   eb
    int   pb
    int   kz
    int   dow
    int   src
    int   bias
    int   zone
    int   smt
    int   spos
    int   deadline
    bool  signalled
    box   bxRisk
    box   bxRew
    label tag
    // --- trade management state ---
    float sl0          // original stop, kept for R maths after the stop moves
    float tp2          // runner target
    float r1           // R multiple of target 1
    float r2           // R multiple of target 2
    bool  be           // stop has been moved to breakeven
    bool  p1           // first target already banked
    float banked       // R already banked from the partial
    bool  trailArmed   // the trail has activated and now governs the stop
    float peak         // best price since entry, what the trail follows

// A raid that has fired and is waiting for its confirmation.
//   stage 0 = waiting for the displacement close
//   stage 1 = waiting for price to come back into the FVG that displacement left
type Armed
    int   bar
    int   dir
    float extreme
    float trigger
    float extAtr
    float penAtr
    int   eb
    int   pb
    int   kz
    int   dow
    int   src
    int   bias
    int   zone
    int   smt
    int   spos
    int   deadline
    bool  eligible
    int   stage
    float fvgEntry
    box   fvgBox

var array<Evt>   pend  = array.new<Evt>()
var array<Armed> armed = array.new<Armed>()

// @function  Mean R of one cell divided by its own standard error. na until the
//            cell has enough resolved events to have a spread at all.
f_tStat(a, cat, side) =>
    n  = stRead(a, cat, side, 0)
    sr = stRead(a, cat, side, 5)
    s2 = stRead(a, cat, side, 10)
    float m  = n > 0 ? sr / n : na
    float v  = n > 1 ? math.max(s2 / n - m * m, 0.0) : na
    float se = n > 1 and v > 0 ? math.sqrt(v / n) : na
    not na(se) and se > 0 ? m / se : na

// Positive is not the test. A bucket has to be positive by enough standard
// errors that a coin would not have produced it, on both axes at once.
bucketPositive(eb, pb, side) =>
    nE = stRead(stExt, eb, side, 0)
    nP = stRead(stPen, pb, side, 0)
    tE = f_tStat(stExt, eb, side)
    tP = f_tStat(stPen, pb, side)
    nE >= i_minSample and nP >= i_minSample and not na(tE) and not na(tP) and tE >= i_minT and tP >= i_minT

// =============================================================================
//  SETUP DRAWING HOUSEKEEPING
// =============================================================================
var array<box>   doneBoxes = array.new<box>()
var array<label> doneTags  = array.new<label>()

// Parameters are explicitly typed: the FVG branch calls this with na for the
// arguments it has nothing to hand over, and Pine cannot infer a type from na.
retireSetup(box b1, box b2, label t) =>
    if not na(b1)
        doneBoxes.push(b1)
    if not na(b2)
        doneBoxes.push(b2)
    if not na(t)
        doneTags.push(t)
    while doneBoxes.size() > i_keepTrades * 3
        box.delete(doneBoxes.shift())
    while doneTags.size() > i_keepTrades
        label.delete(doneTags.shift())
    0

// =============================================================================
//  REGISTRATION
// =============================================================================
rawLong  = false
rawShort = false

// Per-bar alert flags, mirroring RaidShift's set.
bool alArmLong  = false
bool alArmShort = false
bool alTpHit    = false
bool alSlHit    = false
bool alPartial  = false

// Depths of the setup that last fired, kept so the alert text can quote them.
// The signal can arrive several bars after the sweep in the displacement and
// FVG modes, by which point nsExt and nsPen have already been reset. Assigned
// at the call sites, not inside registerEvent: Pine does not allow a function
// to modify a global scalar.
var float sigExt = na
var float sigPen = na

// Set in the registration block, read by the drawing layer further down.
bool gateEligible = false   // cleared the extension and penetration buckets
bool smtOnSweep   = newSweep and smtValid and (nsDir == 1 ? smtDivLong : smtDivShort)

registerEvent(dir, extreme, entryP, extA, penA, eb, pb, kz, dw, src, bias, zone, smt, spos, fires) =>
    stopP = extreme - dir * i_stopAtr * ATR
    risk  = math.abs(entryP - stopP)
    // Geometry only: the entry has to sit on the correct side of the stop, plus
    // the optional floor that keeps out stops too tight to survive the toll.
    bool geom = dir == 1 ? entryP > stopP : entryP < stopP
    bool wide = i_minRiskAtr <= 0 or na(ATR) or risk >= ATR * i_minRiskAtr
    bool ok = false
    if risk > 0 and geom and wide
        [tgtP, rr1, usedLiq, tgt2P, rr2] = f_resolveTp(dir, entryP, stopP)
        revT = extreme + dir * revPct * extA * ATR

        box   b1 = na
        box   b2 = na
        label lb = na
        if fires and i_drawSetup and visible
            b1 := box.new(bar_index, math.max(entryP, stopP), bar_index + 3, math.min(entryP, stopP), xloc = xloc.bar_index,
                 bgcolor = f_area(i_riskCol), border_color = na)
            b2 := box.new(bar_index, math.max(entryP, tgtP), bar_index + 3, math.min(entryP, tgtP), xloc = xloc.bar_index,
                 bgcolor = f_area(i_rewardCol), border_color = na)
            lb := label.new(bar_index, dir == 1 ? stopP : tgtP,
                 (dir == 1 ? "LONG" : "SHORT") + "  " + (usedLiq ? "LIQ " : "") + str.tostring(rr1, "0.00") + "R\next " + str.tostring(extA, "0.00") + ", pen " + str.tostring(penA, "0.00"),
                 style = label.style_label_up, size = size.tiny,
                 color = #00000000,
                 textcolor = dir == 1 ? i_colLong : i_colShort)

        pend.push(Evt.new(bar_index, dir, extreme, entryP, stopP, tgtP, revT, extA > 0, false,
                 extA, penA, eb, pb, kz, dw, src, bias, zone, smt, spos,
                 time + horizonMs, fires, b1, b2, lb,
                 stopP, tgt2P, rr1, rr2, false, false, 0.0, false, entryP))
        ok := true
    ok

if newSweep and atrOk and not na(refOpen) and not calibDone
    extSamp.push(nsExt)
    penSamp.push(nsPen)
    if extSamp.size() >= i_calibN
        EB1 := array.percentile_linear_interpolation(extSamp, 40)
        EB2 := array.percentile_linear_interpolation(extSamp, 70)
        EB3 := array.percentile_linear_interpolation(extSamp, 90)
        PB1 := array.percentile_linear_interpolation(penSamp, 50)
        PB2 := array.percentile_linear_interpolation(penSamp, 80)
        EB1 := math.max(EB1, 0.0000001)
        EB2 := math.max(EB2, EB1 * 1.05)
        EB3 := math.max(EB3, EB2 * 1.05)
        PB1 := math.max(PB1, 0.0000001)
        PB2 := math.max(PB2, PB1 * 1.05)
        calibDone := true

if newSweep and atrOk and not na(refOpen) and calibDone
    eb   = bucketExt(nsExt)
    pb   = bucketPen(nsPen)
    side = nsDir == 1 ? 0 : 1
    kz   = activeSess < 0 ? 4 : activeSess

    // Filter categories: recorded for every event whether the filter is on or
    // not, so the panel can answer "would this filter have helped?"
    biasCat = biasDir == 0 ? -1 : nsDir == biasDir ? 0 : 1
    zoneCat = na(zonePos) ? -1 : (nsDir == 1 ? (zonePos <= 0.5 ? 0 : 1) : (zonePos >= 0.5 ? 0 : 1))
    smtCat  = not smtValid ? -1 : ((nsDir == 1 ? smtDivLong : smtDivShort) ? 0 : 1)
    sposCat = na(sessProg) ? -1 : sessProg < 0.33 ? 0 : sessProg < 0.66 ? 1 : 2

    sideOk = i_sideAllow == "Both" or (i_sideAllow == "Long only" and nsDir == 1) or (i_sideAllow == "Short only" and nsDir == -1)
    ebOk   = (eb == 0 and i_eb0Sig) or (eb == 1 and i_eb1Sig) or (eb == 2 and i_eb2Sig) or (eb == 3 and i_eb3Sig)
    pbOk   = (pb == 0 and i_pb0Sig) or (pb == 1 and i_pb1Sig) or (pb == 2 and i_pb2Sig)
    kzOk   = not i_sigKZonly or activeSess >= 0
    dowOk  = dowIdx == 1 ? i_dowMon : dowIdx == 2 ? i_dowTue : dowIdx == 3 ? i_dowWed : dowIdx == 4 ? i_dowThu : dowIdx == 5 ? i_dowFri : i_dowWknd
    raidOk = i_maxRaids == 0 or raidOrdinal <= i_maxRaids
    adOk   = not i_adaptive or bucketPositive(eb, pb, side)

    biasOk = not i_biasFilter or biasDir == 0 or nsDir == biasDir
    zoneFOk = not i_zoneFilter or na(zonePos) or (nsDir == 1 ? zonePos <= i_discMax : zonePos >= i_premMin)
    smtOk  = not i_smtRequire or not smtValid or (nsDir == 1 ? smtDivLong : smtDivShort)
    spOk   = not i_spFilter or na(sessProg) or sessProg <= i_spMax

    // One trade at a time. Gates the SIGNAL only: every sweep is still measured,
    // because a panel that counts only the events arriving while the engine
    // happened to be idle is sampling its own history non-randomly.
    bool oneBlocked = false
    if i_oneAtATime
        if pend.size() > 0
            for k = 0 to pend.size() - 1
                Evt pe = pend.get(k)
                if pe.signalled
                    oneBlocked := true
        if armed.size() > 0
            for k = 0 to armed.size() - 1
                Armed ae = armed.get(k)
                if ae.eligible
                    oneBlocked := true

    gateEligible := ebOk and pbOk
    fires  = i_sigOn and not oneBlocked and sideOk and ebOk and pbOk and kzOk and dowOk and raidOk and adOk and biasOk and zoneFOk and smtOk and spOk

    if i_confirmMode == "None"
        if registerEvent(nsDir, nsExtreme, close, nsExt, nsPen, eb, pb, kz, dowIdx, nsSrc, biasCat, zoneCat, smtCat, sposCat, fires)
            if fires
                sigExt := nsExt
                sigPen := nsPen
            rawLong  := fires and nsDir == 1
            rawShort := fires and nsDir == -1
    else
        armed.push(Armed.new(bar_index, nsDir, nsExtreme, nsDir == 1 ? high : low,
                 nsExt, nsPen, eb, pb, kz, dowIdx, nsSrc, biasCat, zoneCat, smtCat, sposCat,
                 time + dispMs, fires, 0, na, na))
        alArmLong  := fires and nsDir == 1
        alArmShort := fires and nsDir == -1

// =============================================================================
//  CONFIRMATION STATE MACHINE
// =============================================================================
if armed.size() > 0
    for i = armed.size() - 1 to 0
        Armed a = armed.get(i)
        if bar_index > a.bar
            invalid = a.dir == 1 ? low < a.extreme : high > a.extreme

            if a.stage == 0
                fired = a.dir == 1 ? close > a.trigger : close < a.trigger
                if fired
                    if i_confirmMode == "Displacement close"
                        if registerEvent(a.dir, a.extreme, close, a.extAtr, a.penAtr, a.eb, a.pb, a.kz, a.dow, a.src, a.bias, a.zone, a.smt, a.spos, a.eligible)
                            if a.eligible
                                sigExt := a.extAtr
                                sigPen := a.penAtr
                            rawLong  := rawLong  or (a.eligible and a.dir == 1)
                            rawShort := rawShort or (a.eligible and a.dir == -1)
                        armed.remove(i)
                    else
                        // Displacement leaves an imbalance. Find it, and wait
                        // for price to come back into it. The published data
                        // says an FVG is not a signal - it is a better PRICE,
                        // and that is all it is used for here.
                        // Taken from the shared FVG registry, so the trade waits
                        // on exactly the gap that is drawn on the chart.
                        float gapTop = na
                        float gapBot = na
                        if fvgs.size() > 0
                            for gj = 0 to fvgs.size() - 1
                                fvgZone z = fvgs.get(gj)
                                if z.dir == a.dir and z.bIdx >= a.bar and not z.mitigated
                                    gapTop := z.top
                                    gapBot := z.bot
                                    break
                        if not na(gapTop) and gapTop > gapBot
                            ent = f_fvgEntry(gapTop, gapBot, a.dir == 1, i_fvgDepth)
                            a.stage    := 1
                            a.fvgEntry := ent
                            a.fvgBox   := na
                            a.deadline := time + fvgMs
                            alArmLong  := alArmLong  or (a.eligible and a.dir == 1)
                            alArmShort := alArmShort or (a.eligible and a.dir == -1)
                        else if i_fvgFall
                            if registerEvent(a.dir, a.extreme, close, a.extAtr, a.penAtr, a.eb, a.pb, a.kz, a.dow, a.src, a.bias, a.zone, a.smt, a.spos, a.eligible)
                                if a.eligible
                                    sigExt := a.extAtr
                                    sigPen := a.penAtr
                                rawLong  := rawLong  or (a.eligible and a.dir == 1)
                                rawShort := rawShort or (a.eligible and a.dir == -1)
                            armed.remove(i)
                        else
                            armed.remove(i)
                else if invalid or time > a.deadline
                    armed.remove(i)

            else if a.stage == 1
                if not na(a.fvgBox)
                    box.set_right(a.fvgBox, bar_index)
                filled = a.dir == 1 ? low <= a.fvgEntry : high >= a.fvgEntry
                if filled
                    if registerEvent(a.dir, a.extreme, a.fvgEntry, a.extAtr, a.penAtr, a.eb, a.pb, a.kz, a.dow, a.src, a.bias, a.zone, a.smt, a.spos, a.eligible)
                        if a.eligible
                            sigExt := a.extAtr
                            sigPen := a.penAtr
                        rawLong  := rawLong  or (a.eligible and a.dir == 1)
                        rawShort := rawShort or (a.eligible and a.dir == -1)
                    if not na(a.fvgBox)
                        retireSetup(a.fvgBox, na, na)
                    armed.remove(i)
                else if invalid or time > a.deadline
                    if not na(a.fvgBox)
                        box.delete(a.fvgBox)
                    armed.remove(i)

sigLong  = rawLong
sigShort = rawShort

// =============================================================================
//  RESOLUTION ENGINE
// =============================================================================
bumpOne(a, cat, side, win, loss, scratch, unres, rmul, revValid, revHit, extA, penA) =>
    if cat >= 0
        stBump(a, cat, side, 0, 1.0)
        stBump(a, cat, side, 3, win ? 1.0 : 0.0)
        stBump(a, cat, side, 4, loss ? 1.0 : 0.0)
        stBump(a, cat, side, 5, rmul)
        stBump(a, cat, side, 6, unres ? 1.0 : 0.0)
        stBump(a, cat, side, 7, extA)
        stBump(a, cat, side, 8, penA)
        stBump(a, cat, side, 9, scratch ? 1.0 : 0.0)
        // Needed for the standard error. Unresolved events contribute 0 to both
        // this and the R sum, which deflates the spread very slightly; with
        // unresolved typically a couple of percent that is not worth correcting.
        stBump(a, cat, side, 10, rmul * rmul)
        if revValid
            stBump(a, cat, side, 1, 1.0)
            stBump(a, cat, side, 2, revHit ? 1.0 : 0.0)
    0

// rOut is the R the trade ACTUALLY ended at, which is what makes a trailed exit
// countable. The old form could only ever report the target, -1R or 0R, so a
// runner stopped out at +1.4R was booked as a scratch.
commitEvt(e, rOutGross, unres) =>
    side    = e.dir == 1 ? 0 : 1
    // The toll, converted to R at THIS trade's own stop width. A fixed cost in
    // percent of price is a large cost in R behind a tight stop and a small one
    // behind a wide stop, which is exactly why it has to be charged per trade
    // rather than subtracted from the total at the end.
    risk0c  = math.max(math.abs(e.entry - e.sl0), syminfo.mintick)
    costR   = i_costPct > 0 ? (i_costPct / 100.0 * e.entry) / risk0c : 0.0
    rOut    = unres ? rOutGross : rOutGross - costR
    win     = not unres and rOut > 0
    loss    = not unres and rOut < 0
    scratch = not unres and rOut == 0
    rmul    = unres ? 0.0 : rOut
    bumpOne(stExt,  e.eb,   side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stPen,  e.pb,   side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stKZ,   e.kz,   side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stDow,  e.dow,  side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stBias, e.bias, side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stZone, e.zone, side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stSmt,  e.smt,  side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stSPos, e.spos, side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    bumpOne(stAll,  0,      side, win, loss, scratch, unres, rmul, e.revValid, e.revHit, e.extAtr, e.penAtr)
    if e.signalled and not na(e.bxRisk)
        col = win ? i_colLong : loss ? i_colShort : #8C93A2
        box.set_right(e.bxRisk, bar_index)
        box.set_right(e.bxRew,  bar_index)
        // No recolouring. The zone keeps exactly the colour its picker defines,
        // from the moment it is drawn to the moment the trade ends. The outcome
        // is carried by the label instead.
        if not na(e.tag)
            reason = unres ? "expired" : e.trailArmed and e.stop != e.sl0 ? "trail" : e.be and rOut <= 0 ? "BE" : rOut > 0 ? "TP" : "SL"
            label.set_x(e.tag, bar_index)
            label.set_text(e.tag, (e.dir == 1 ? "LONG  " : "SHORT  ") + reason + "  " + (rOut >= 0 ? "+" : "") + str.tostring(rOut, "0.00") + "R")
            label.set_textcolor(e.tag, col)
        retireSetup(e.bxRisk, e.bxRew, e.tag)
    0

if pend.size() > 0
    for i = pend.size() - 1 to 0
        Evt e = pend.get(i)
        if e.signalled and not na(e.bxRisk)
            box.set_right(e.bxRisk, bar_index)
            box.set_right(e.bxRew,  bar_index)
        if bar_index > e.bar
            if e.revValid and not e.revHit
                if (e.dir == 1 and high >= e.revTarget) or (e.dir == -1 and low <= e.revTarget)
                    e.revHit := true

            risk0   = math.max(math.abs(e.entry - e.sl0), syminfo.mintick)
            hitStop = e.dir == 1 ? low  <= e.stop   : high >= e.stop
            hitTgt  = e.dir == 1 ? high >= e.target : low  <= e.target
            expired = time > e.deadline

            // The stop is tested against its CURRENT level before anything moves
            // it, so a bar that both reaches the breakeven trigger and trades
            // back to the old stop resolves as a stop.
            if hitStop and (i_ambigLoss or not hitTgt)
                // Priced from where the stop actually sits, not from a table of
                // special cases. An untouched stop gives exactly -1R, a stop at
                // the entry exactly 0R, and a trailed stop whatever it earned.
                rStop = (e.dir == 1 ? e.stop - e.entry : e.entry - e.stop) / risk0
                rOut  = e.p1 ? e.banked + rStop * (1.0 - partialPct / 100.0) : rStop
                commitEvt(e, rOut, false)
                alSlHit := true
                pend.remove(i)
            else if hitTgt
                if partialOn and not e.p1
                    // Bank the first slice, protect the rest at entry, re-aim at
                    // the runner. math.max so a trail already above the entry is
                    // not dragged back down.
                    e.p1     := true
                    e.banked := e.r1 * partialPct / 100.0
                    e.be     := true
                    e.stop   := e.dir == 1 ? math.max(e.stop, e.entry) : math.min(e.stop, e.entry)
                    e.target := e.tp2
                    alPartial := true
                    if e.signalled and not na(e.bxRew)
                        box.set_top(e.bxRew, math.max(e.entry, e.tp2))
                        box.set_bottom(e.bxRew, math.min(e.entry, e.tp2))
                        box.set_bgcolor(e.bxRew, f_area(i_rewardCol))
                else
                    rOut = e.p1 ? e.banked + e.r2 * (1.0 - partialPct / 100.0) : e.r1
                    commitEvt(e, rOut, false)
                    alTpHit := true
                    pend.remove(i)
            else if expired
                commitEvt(e, 0.0, true)
                pend.remove(i)
            else
                // The trade survived the bar. Move the stop if anything earned
                // the right to move it. Breakeven first, then the trail, and the
                // trail only ever moves toward profit.
                if beOn and not e.be and (e.dir == 1 ? high >= e.entry + beTrigR * risk0 : low <= e.entry - beTrigR * risk0)
                    e.be   := true
                    e.stop := e.dir == 1 ? math.max(e.stop, e.entry) : math.min(e.stop, e.entry)
                if trailOn
                    if not e.trailArmed and (e.dir == 1 ? high >= e.entry + trailTrigR * risk0 : low <= e.entry - trailTrigR * risk0)
                        e.trailArmed := true
                    if e.trailArmed
                        trailSL = e.dir == 1 ? e.peak * (1.0 - trailPct / 100.0) : e.peak * (1.0 + trailPct / 100.0)
                        e.stop := e.dir == 1 ? math.max(e.stop, trailSL) : math.min(e.stop, trailSL)
                // The risk box shows the risk STILL on the table, clamped at the
                // entry. Without the clamp a stop trailed into profit inverts the
                // box and draws red where no risk is left.
                if e.signalled and not na(e.bxRisk)
                    if e.dir == 1
                        box.set_bottom(e.bxRisk, math.min(e.stop, e.entry))
                    else
                        box.set_top(e.bxRisk, math.max(e.stop, e.entry))

            // Best price seen since entry, updated AFTER this bar's own
            // resolution so the stop tested on a bar is the one that was
            // standing when it opened.
            e.peak := e.dir == 1 ? math.max(nz(e.peak, high), high) : math.min(nz(e.peak, low), low)

// =============================================================================
//  SESSION BOXES, KILL ZONES AND SESSION HIGH / LOW LINES
// =============================================================================
var array<box>   drawBoxes = array.new<box>()
var array<color> boxCols   = array.new<color>()
// Which half of a session each box is. Pine has no box.get_bgcolor(), so the
// last-bar re-colour pass below cannot read a box's current density back off
// the drawing and has to be told.
var array<bool>  boxIsRest = array.new<bool>()
var array<line>  drawLines = array.new<line>()
// The session name is its own label sitting above the box. It used to be set as
// the box's own text, which TradingView renders INSIDE the rectangle, over the
// candles the box is meant to frame.
var array<label> sessLabels = array.new<label>()
var array<line>  hlLines   = array.new<line>()
var array<label> hlLabels  = array.new<label>()

keepBox(b, c, isRest) =>
    drawBoxes.push(b)
    boxCols.push(c)
    boxIsRest.push(isRest)
    while drawBoxes.size() > i_keepDraw * 2
        box.delete(drawBoxes.shift())
        boxCols.shift()
        boxIsRest.shift()
    0


keepLine(l) =>
    drawLines.push(l)
    while drawLines.size() > i_keepDraw
        line.delete(drawLines.shift())
    0

keepSessLabel(l) =>
    sessLabels.push(l)
    while sessLabels.size() > i_keepDraw
        label.delete(sessLabels.shift())
    0

// The high and low lines live in their own pool, two lines and two labels per
// session, so trimming them never evicts a session box and the other way round.
keepHL(line a, line b, label la, label lb) =>
    if not na(a)
        hlLines.push(a)
    if not na(b)
        hlLines.push(b)
    if not na(la)
        hlLabels.push(la)
    if not na(lb)
        hlLabels.push(lb)
    while hlLines.size() > i_keepDraw * 2
        line.delete(hlLines.shift())
    while hlLabels.size() > i_keepDraw * 2
        label.delete(hlLabels.shift())
    0

// st is the window's scheduled open, bt the first bar inside it. They differ
// only on a chart whose trading hours start after the window does, and there
// the box has to follow the bars that exist while the right edge still lands on
// the scheduled close.
// SESSION AREA, REBUILT AGAINST THE REFERENCE LIBRARY'S OWN SOURCE
// -----------------------------------------------------------------
// TFlab's SessionDetector was read directly rather than inferred from a
// screenshot, and three things in it were not what this script was doing:
//
//   1. Its area box runs from the SESSION OPEN to the END OF THE KILL ZONE,
//      not across the whole session, and not across the kill zone alone.
//      FillTime = KillZone_Show ? KillTime : SessTime, and the box right edge
//      only advances while FillTime is 1.
//   2. Its top and bottom are the SESSION high and low throughout, so the box
//      keeps growing vertically long after it has stopped growing sideways.
//      AreaUpdate is 'Session' in the wrapper, which is what selects that.
//   3. Its name label is re-anchored every bar to the MIDPOINT between the
//      session open and the current bar, at the session high:
//      Name.set_xy(math.round(math.avg(Bar, bar_index)), High).
//
// All three are reproduced here. The one thing kept from this script instead is
// the projection to the scheduled close, because knowing where the block ends
// while it is still running is worth more than matching a reference exactly.
drawSession(enabled, inNow, started, ended, kzIn, h, l, st, bt, span, kzOff, c, name) =>
    var box   bKz  = na          // session open  ->  kill zone close
    var box   bRst = na          // kill zone close -> session close
    var line  ml   = na
    var label nm   = na
    var int   bar0 = na          // bar_index at the session open, for the midpoint
    if enabled and visible and not na(h) and not na(l)
        int kzEndT  = st + kzOff
        int sessEnd = st + span
        if started
            bar0 := bar_index
            // PROJECTED AT THE OPEN. The scheduled close of both halves is known
            // the moment the session starts, so both boxes are drawn to their
            // full width immediately rather than being grown candle by candle.
            // That is the whole point of knowing the window in advance, and it
            // is the one place this deliberately does not copy the reference,
            // which has no concept of a scheduled end and simply follows price.
            bool proj = i_boxFull and span > 0
            bKz := box.new(bt, h, proj and kzEndT > bt ? kzEndT : time, l,
                 xloc = xloc.bar_time, border_color = na, bgcolor = c)
            keepBox(bKz, c, false)
            bRst := na
            if proj and i_restFill > 0 and sessEnd > kzEndT
                // Starts exactly where the first box ends. Sharing the boundary
                // is what removes the gap that opened up when the second box was
                // created a bar later than the first one was closed.
                bRst := box.new(kzEndT, h, sessEnd, l,
                     xloc = xloc.bar_time, border_color = na, bgcolor = f_restArea(c))
                keepBox(bRst, c, true)
            nm := label.new(bar_index, h, name, xloc = xloc.bar_index,
                 style = label.style_label_down, color = #00000000,
                 textcolor = f_ink(c), size = size.small)
            keepSessLabel(nm)
            if i_drawMid
                ml := line.new(bt, math.avg(h, l), proj ? sessEnd : time, math.avg(h, l),
                     xloc = xloc.bar_time, color = f_ink(c), style = line.style_dashed, width = 1)
                keepLine(ml)
        else if inNow
            // Vertical extent follows the SESSION high and low for both halves,
            // for the whole session, which is what the reference does.
            if not na(bKz)
                box.set_top(bKz, h)
                box.set_bottom(bKz, l)
                box.set_bgcolor(bKz, c)
                if not i_boxFull and kzIn
                    box.set_right(bKz, time)
            // Unprojected mode only: open the second box at the same instant the
            // first one is closed, so the two share a boundary and leave no gap.
            if not i_boxFull and not kzIn and na(bRst) and i_restFill > 0
                if not na(bKz)
                    box.set_right(bKz, time)
                bRst := box.new(time, h, time, l, xloc = xloc.bar_time,
                     border_color = na, bgcolor = f_restArea(c))
                keepBox(bRst, c, true)
            if not na(bRst)
                box.set_top(bRst, h)
                box.set_bottom(bRst, l)
                box.set_bgcolor(bRst, f_restArea(c))
                if not i_boxFull
                    box.set_right(bRst, time)
            if not na(nm)
                label.set_xy(nm, math.round(math.avg(nz(bar0, bar_index), bar_index)), h)
                label.set_textcolor(nm, f_ink(c))
            if i_drawMid and not na(ml)
                line.set_y1(ml, math.avg(h, l))
                line.set_y2(ml, math.avg(h, l))
                if not i_boxFull
                    line.set_x2(ml, time)
        else if ended and not i_boxFull
            // Trim the unprojected boxes back to the last real bar.
            if not na(bRst)
                box.set_right(bRst, time)
            else if not na(bKz)
                box.set_right(bKz, time)
            if i_drawMid and not na(ml)
                line.set_x2(ml, time)
    0

// SESSION HIGH AND LOW
// --------------------
// Reference behaviour: two DOTTED lines at width 1 in the session colour,
// opened at the session high and low and extended bar by bar until the session
// closes. They are not projected past it there. This script keeps an extension
// input because the sweep engine trades those levels AFTER the block that made
// them, but its default is 0, which is the reference.
//
// RIGHT EDGE. When the area box is projected to the scheduled close, these two
// levels are projected to the same instant instead of being dragged along one
// candle at a time. The close of the window is known the moment it opens, so
// there is no reason for the lines to lag behind the colour they belong to, and
// a pair that already reaches the end of the block reads as part of it. With
// projection off they grow bar by bar, which is the reference behaviour.
drawSessionHL(enabled, inNow, started, ended, h, l, st, bt, span, c, name) =>
    var line  lnH = na
    var line  lnL = na
    var label lbH = na
    var label lbL = na
    if enabled and i_drawHL and visible and not na(h) and not na(l)
        int  extMs   = i_hlExtend * timeframe.in_seconds(timeframe.period) * 1000
        int  sessEnd = st + span
        bool proj    = i_boxFull and span > 0 and not na(st) and not na(bt) and sessEnd > bt
        // Written as a branch rather than a ternary so that an na on either side
        // of the comparison can only fall back to the bar clock, never leak an
        // na coordinate into set_x2 and erase the line.
        int  rightT  = time + extMs
        if proj
            rightT := sessEnd + extMs
        if started
            lnH := line.new(bt, h, rightT, h, xloc = xloc.bar_time, color = f_ink(c), width = i_hlWidth, style = lineStyleOf(i_hlStyle))
            lnL := line.new(bt, l, rightT, l, xloc = xloc.bar_time, color = f_ink(c), width = i_hlWidth, style = lineStyleOf(i_hlStyle))
            if i_hlLabel
                lbH := label.new(rightT, h, name + " H", xloc = xloc.bar_time, style = label.style_label_left, color = #00000000, textcolor = f_ink(c), size = size.tiny)
                lbL := label.new(rightT, l, name + " L", xloc = xloc.bar_time, style = label.style_label_left, color = #00000000, textcolor = f_ink(c), size = size.tiny)
            else
                lbH := na
                lbL := na
            keepHL(lnH, lnL, lbH, lbL)
        else if inNow and not na(lnH)
            if i_hlLive
                line.set_y1(lnH, h)
                line.set_y2(lnH, h)
                line.set_y1(lnL, l)
                line.set_y2(lnL, l)
                if not na(lbH)
                    label.set_y(lbH, h)
                    label.set_y(lbL, l)
            line.set_x2(lnH, rightT)
            line.set_x2(lnL, rightT)
            if not na(lbH)
                label.set_x(lbH, rightT)
                label.set_x(lbL, rightT)
        else if ended and not na(lnH)
            // Freeze both levels here. Without this branch they kept being
            // stretched on every later bar and every past session's pair ran all
            // the way to the present.
            if i_hlLive
                line.set_y1(lnH, h)
                line.set_y2(lnH, h)
                line.set_y1(lnL, l)
                line.set_y2(lnL, l)
                if not na(lbH)
                    label.set_y(lbH, h)
                    label.set_y(lbL, l)
            line.set_x2(lnH, rightT)
            line.set_x2(lnL, rightT)
            if not na(lbH)
                label.set_x(lbH, rightT)
                label.set_x(lbL, rightT)
    0

drawSession(i_drawBoxes and i_s1e, in0, st0, ed0, kin0 and i_s1ze, hi0, lo0, sb0, bt0, span0, i_s1ze ? kzOff0 : span0, i_s1k, NAME_ASIA)
drawSession(i_drawBoxes and i_s2e, in1, st1, ed1, kin1 and i_s2ze, hi1, lo1, sb1, bt1, span1, i_s2ze ? kzOff1 : span1, i_s2k, NAME_LDN)
drawSession(i_drawBoxes and i_s3e, in2, st2, ed2, kin2 and i_s3ze, hi2, lo2, sb2, bt2, span2, i_s3ze ? kzOff2 : span2, i_s3k, NAME_NYAM)
drawSession(i_drawBoxes and i_s4e, in3, st3, ed3, kin3 and i_s4ze, hi3, lo3, sb3, bt3, span3, i_s4ze ? kzOff3 : span3, i_s4k, NAME_NYPM)

drawSessionHL(i_s1e, in0, st0, ed0, hi0, lo0, sb0, bt0, span0, i_s1k, NAME_ASIA)
drawSessionHL(i_s2e, in1, st1, ed1, hi1, lo1, sb1, bt1, span1, i_s2k, NAME_LDN)
drawSessionHL(i_s3e, in2, st2, ed2, hi2, lo2, sb2, bt2, span2, i_s3k, NAME_NYAM)
drawSessionHL(i_s4e, in3, st3, ed3, hi3, lo3, sb3, bt3, span3, i_s4k, NAME_NYPM)

// Transparency is re-applied to EVERY session box still on the chart, not only
// to the one currently forming. A finished box keeps the colour it was born
// with otherwise, which is what made the slider look dead.
// Finished boxes keep the colour they were born with, so moving a slider would
// otherwise look dead on everything except the session currently forming. The
// kill zone half and the remainder half live in the same pool, so each is
// matched back to its own density by reading what it already carries.
if barstate.islast and drawBoxes.size() > 0 and drawBoxes.size() == boxCols.size() and drawBoxes.size() == boxIsRest.size()
    for bi = 0 to drawBoxes.size() - 1
        box   bb = drawBoxes.get(bi)
        color bc = boxCols.get(bi)
        box.set_bgcolor(bb, boxIsRest.get(bi) ? f_restArea(bc) : bc)

// --- Range projections: only the newest set survives -------------------------
devEnded = i_devSrc == "Asia" ? ed0 : i_devSrc == "London" ? ed1 : i_devSrc == "New York AM" ? ed2 : ed3
devHi    = i_devSrc == "Asia" ? ph0 : i_devSrc == "London" ? ph1 : i_devSrc == "New York AM" ? ph2 : ph3
devLo    = i_devSrc == "Asia" ? pl0 : i_devSrc == "London" ? pl1 : i_devSrc == "New York AM" ? pl2 : pl3
devCol   = i_devSrc == "Asia" ? i_s1k : i_devSrc == "London" ? i_s2k : i_devSrc == "New York AM" ? i_s3k : i_s4k

var array<line> devLines = array.new<line>()
if i_drawDev and visible and devEnded and not na(devHi) and not na(devLo) and devHi > devLo
    while devLines.size() > 0
        line.delete(devLines.shift())
    rng = devHi - devLo
    for s = 1 to i_devCount
        devLines.push(line.new(time, devHi + rng * s, time + 1, devHi + rng * s, xloc = xloc.bar_time,
             extend = extend.right, color = f_ink(devCol), style = line.style_dotted, width = 1))
        devLines.push(line.new(time, devLo - rng * s, time + 1, devLo - rng * s, xloc = xloc.bar_time,
             extend = extend.right, color = f_ink(devCol), style = line.style_dotted, width = 1))

// =============================================================================
//  CONTEXT — midnight open, previous day levels
// =============================================================================
// One persistent line, redrawn on the last bar and stopped at the same right
// edge as PDH and PDL rather than running to the end of the chart.
var line  mnLn = line.new(na, na, na, na, xloc = xloc.bar_time)
var label mnLb = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100))

if barstate.islast
    bool mnOk = i_drawMidnight and not na(midnightOpen) and not na(midnightBar)
    int  mnR  = time + pdExtend * timeframe.in_seconds(timeframe.period) * 1000
    color mnC = mnOk ? i_mnCol : color.new(color.white, 100)
    mnLn.set_xy1(midnightBar, mnOk ? midnightOpen : na)
    mnLn.set_xy2(mnR,         mnOk ? midnightOpen : na)
    mnLn.set_color(mnC)
    mnLn.set_width(i_mnWidth)
    mnLn.set_style(lineStyleOf(i_mnStyle))
    mnLb.set_xy(mnR, mnOk ? midnightOpen : na)
    mnLb.set_text(mnOk and i_mnLabel ? 'Midnight' : '')
    mnLb.set_textcolor(mnC)

// ── PREVIOUS-DAY LEVELS · ported from RaidShift [UgurTash], unchanged ────────
//     Solid while unswept; dotted and dimmed the moment price trades through one
//     today. Only PDH carries the day/date stamp, since one stamp per session is
//     enough to read.
var bool pdHSwept = false
var bool pdLSwept = false
var int  pdStartT = time

bool pdRolled = timeframe.change('D') or (not na(pdH) and not na(pdH[1]) and pdH != pdH[1]) or (not na(pdL) and not na(pdL[1]) and pdL != pdL[1])
if pdRolled
    pdHSwept := false
    pdLSwept := false
    pdStartT := time
if not na(pdH) and high >= pdH
    pdHSwept := true
if not na(pdL) and low <= pdL
    pdLSwept := true

var line  pdHLn = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  pdLLn = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  pdELn = line.new(na, na, na, na, xloc = xloc.bar_time)
var label pdHLb = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100))
var label pdLLb = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100))
var label pdELb = label.new(na, na, '', xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.white, 100))

if barstate.islast
    bool pdOk = showPD and not na(pdH) and not na(pdL)
    int  rghT = time + pdExtend * timeframe.in_seconds(timeframe.period) * 1000
    color cH  = pdOk ? (pdHSwept ? color.new(pdCol, 60) : pdCol) : color.new(color.white, 100)
    color cL  = pdOk ? (pdLSwept ? color.new(pdCol, 60) : pdCol) : color.new(color.white, 100)
    color cE  = pdOk and showPdEq ? color.new(pdCol, 35) : color.new(color.white, 100)

    // time_close lands exactly ON the day boundary. On a 24h market that is the
    // NEXT day's 00:00, which would stamp the level with the wrong day and date.
    // One millisecond back puts the stamp inside the bar it belongs to, and
    // still reads 16:59:59.999 on a futures session that closes at 17:00, so
    // both instrument families come out right.
    int    pdStampT = na(pdT) ? na : pdT - 1
    string pdDay    = f_dayName(pdStampT)
    string pdDate   = na(pdStampT) ? '' : str.format_time(pdStampT, 'dd/MM', syminfo.timezone)
    string pdStamp  = switch pdLabelMode
        'Day'        => pdDay == '' ? '' : ' ' + pdDay
        'Date'       => pdDate == '' ? '' : ' ' + pdDate
        'Day + Date' => pdDay == '' and pdDate == '' ? '' : ' ' + pdDay + ' ' + pdDate
        =>              ''

    pdHLn.set_xy1(pdStartT, pdOk ? pdH : na)
    pdHLn.set_xy2(rghT,     pdOk ? pdH : na)
    pdHLn.set_color(cH)
    pdHLn.set_width(pdWidth)
    pdHLn.set_style(pdHSwept ? line.style_dotted : line.style_solid)

    pdLLn.set_xy1(pdStartT, pdOk ? pdL : na)
    pdLLn.set_xy2(rghT,     pdOk ? pdL : na)
    pdLLn.set_color(cL)
    pdLLn.set_width(pdWidth)
    pdLLn.set_style(pdLSwept ? line.style_dotted : line.style_solid)

    pdELn.set_xy1(pdStartT, pdOk and showPdEq ? pdEq : na)
    pdELn.set_xy2(rghT,     pdOk and showPdEq ? pdEq : na)
    pdELn.set_color(cE)
    pdELn.set_width(pdWidth)
    pdELn.set_style(line.style_dotted)

    // PDH carries the stamp; PDL is deliberately left bare.
    pdHLb.set_xy(rghT, pdOk ? pdH : na)
    pdHLb.set_text(showPdLbl ? 'PDH' + pdStamp + (pdHSwept ? ' ✓' : '') : '')
    pdHLb.set_textcolor(cH)
    pdLLb.set_xy(rghT, pdOk ? pdL : na)
    pdLLb.set_text(showPdLbl ? 'PDL' + (pdLSwept ? ' ✓' : '') : '')
    pdLLb.set_textcolor(cL)
    pdELb.set_xy(rghT, pdOk and showPdEq ? pdEq : na)
    pdELb.set_text(showPdLbl and showPdEq ? 'PD EQ' : '')
    pdELb.set_textcolor(cE)

// =============================================================================
//  PROJECTED HIGHER-TIMEFRAME CANDLES
// =============================================================================
// Ported from RaidShift [UgurTash].
//     Index 0 = the forming candle, accumulated from chart bars so it does not
//     repaint. Indices 1-11 = confirmed closed candles, pinned with lookahead_on.
string autoHtf = timeframe.in_seconds(timeframe.period) <= 60 ? '15' : timeframe.in_seconds(timeframe.period) <= 300 ? '60' : timeframe.in_seconds(timeframe.period) <= 900 ? '60' : timeframe.in_seconds(timeframe.period) <= 1800 ? '240' : timeframe.in_seconds(timeframe.period) <= 3600 ? '240' : timeframe.in_seconds(timeframe.period) <= 14400 ? 'D' : timeframe.in_seconds(timeframe.period) <= 86400 ? 'W' : 'M'
string htfTf   = htfAuto ? autoHtf : htfManual
bool   htfOk   = timeframe.in_seconds(htfTf) > timeframe.in_seconds(timeframe.period)

bool newHtfBar = timeframe.change(htfTf)
var float ho0 = na
var float hh0 = na
var float hlw0 = na
var float hc0 = na
var int   ht0 = na
if newHtfBar or na(ho0)
    ho0 := open
    hh0 := high
    hlw0 := low
    hc0 := close
    ht0 := time(htfTf)
else
    hh0 := math.max(hh0, high)
    hlw0 := math.min(hlw0, low)
    hc0 := close

[ho1,hh1,hlw1,hc1, ho2,hh2,hlw2,hc2, ho3,hh3,hlw3,hc3, ho4,hh4,hlw4,hc4, ho5,hh5,hlw5,hc5, ho6,hh6,hlw6,hc6,
 ho7,hh7,hlw7,hc7, ho8,hh8,hlw8,hc8, ho9,hh9,hlw9,hc9, ho10,hh10,hlw10,hc10, ho11,hh11,hlw11,hc11] =
     request.security(syminfo.tickerid, htfTf,
     [open[1],high[1],low[1],close[1], open[2],high[2],low[2],close[2], open[3],high[3],low[3],close[3],
      open[4],high[4],low[4],close[4], open[5],high[5],low[5],close[5], open[6],high[6],low[6],close[6],
      open[7],high[7],low[7],close[7], open[8],high[8],low[8],close[8], open[9],high[9],low[9],close[9],
      open[10],high[10],low[10],close[10], open[11],high[11],low[11],close[11]],
      lookahead = barmerge.lookahead_on)

var array<box>  hbBoxes = array.new<box>()
var array<line> hbWicks = array.new<line>()
var array<line> hbEqs   = array.new<line>()
var label       hbTimer = na
var label       hbWarn  = na

if barstate.islast
    for b in hbBoxes
        b.delete()
    hbBoxes.clear()
    for w in hbWicks
        w.delete()
    hbWicks.clear()
    for e in hbEqs
        e.delete()
    hbEqs.clear()
    if not na(hbTimer)
        hbTimer.delete()
        hbTimer := na
    if not na(hbWarn)
        hbWarn.delete()
        hbWarn := na

    if showHtfBlock
        if not htfOk
            hbWarn := label.new(bar_index, high, 'HTF block: the higher timeframe must be above the chart timeframe', xloc = xloc.bar_index, style = label.style_label_down, color = color.new(#f23645, 20), textcolor = color.white, size = size.small)
        else
            array<float> aO = array.from(ho0,ho1,ho2,ho3,ho4,ho5,ho6,ho7,ho8,ho9,ho10,ho11)
            array<float> aH = array.from(hh0,hh1,hh2,hh3,hh4,hh5,hh6,hh7,hh8,hh9,hh10,hh11)
            array<float> aL = array.from(hlw0,hlw1,hlw2,hlw3,hlw4,hlw5,hlw6,hlw7,hlw8,hlw9,hlw10,hlw11)
            array<float> aC = array.from(hc0,hc1,hc2,hc3,hc4,hc5,hc6,hc7,hc8,hc9,hc10,hc11)

            int num     = math.min(htfCount, 12)
            int candleW = htfSize == 'Large' ? 5 : htfSize == 'Medium' ? 3 : 1
            int step    = candleW + htfGap
            int baseX   = bar_index + htfOffset
            int half    = math.max(1, math.round(candleW / 2.0))

            float blockTop = na
            for i = 0 to num - 1
                float o = aO.get(i)
                float h = aH.get(i)
                float l = aL.get(i)
                float c = aC.get(i)
                if na(o) or na(h) or na(l) or na(c)
                    continue
                bool  bull = c >= o
                int   x    = baseX + (num - 1 - i) * step
                int   xl   = x - half
                int   xr   = x + half
                float bt   = math.max(o, c)
                float bb   = math.min(o, c)
                if bt == bb
                    bt := bt + syminfo.mintick
                color cBody = bull ? htfBullBody : htfBearBody
                color cBrd  = bull ? htfBullBrd  : htfBearBrd
                color cWick = bull ? htfBullWick : htfBearWick
                hbBoxes.push(box.new(xl, bt, xr, bb, xloc = xloc.bar_index,
                     bgcolor = cBody, border_color = cBrd, border_width = htfBrdWidth))
                hbWicks.push(line.new(x, h, x, bt, xloc = xloc.bar_index, color = cWick, width = htfWickWidth))
                hbWicks.push(line.new(x, bb, x, l, xloc = xloc.bar_index, color = cWick, width = htfWickWidth))
                if htfShowEq and i >= 1
                    float eqp = math.avg(h, l)
                    hbEqs.push(line.new(xl, eqp, xr, eqp, xloc = xloc.bar_index, color = color.new(htfTxtCol, 30), style = line.style_dotted))
                if na(blockTop) or h > blockTop
                    blockTop := h

            if htfShowTimer and not na(blockTop)
                int xC = baseX + math.round((num - 1) * step / 2.0)
                hbTimer := label.new(xC, blockTop, f_tfLabel(htfTf) + '\n' + f_htfCountdown(ht0, htfTf), xloc = xloc.bar_index, style = label.style_label_down, color = color.new(color.white, 100), textcolor = htfTxtCol, size = size.small)

// =============================================================================
//  SWEEP MARKERS
//  A dot marks EVERY detected sweep. It is a measurement mark, not a trade.
//  An arrow marks a sweep that also passed every enabled gate.
// =============================================================================
if i_drawSweeps and visible and newSweep and atrOk
    label.new(bar_index, nsDir == 1 ? low : high,
         "ext " + str.tostring(nsExt, "#.00") + "  ·  pen " + str.tostring(nsPen, "#.00") + "\n" + sessName(nsSrc),
         style     = nsDir == 1 ? label.style_label_up : label.style_label_down,
         color     = #00000000,
         textcolor = nsDir == 1 ? i_colLong : i_colShort,
         size = size.tiny, yloc = yloc.price)

// A dot is drawn for every sweep, or only for the ones that cleared the depth
// and penetration buckets, or not at all.
dotOk = i_dotMode == "Every sweep" ? newSweep : i_dotMode == "Gate-eligible only" ? gateEligible : false
plotshape(dotOk and visible and nsDir ==  1, "Sweep, sellside", shape.circle, location.belowbar, color = i_colLong,  size = size.tiny)
plotshape(dotOk and visible and nsDir == -1, "Sweep, buyside",  shape.circle, location.abovebar, color = i_colShort, size = size.tiny)

// SMT: the raid happened here and the correlated market refused to follow it.
if i_smtLabels and visible and smtOnSweep
    label.new(bar_index, nsDir == 1 ? low : high,
         nsDir == 1 ? '\nSMT vs ' + smtName : 'SMT vs ' + smtName + '\n',
         xloc = xloc.bar_index,
         style = nsDir == 1 ? label.style_label_up : label.style_label_down,
         color = color.new(color.white, 100),
         textcolor = nsDir == 1 ? i_smtBullCol : i_smtBearCol, size = size.tiny)
plotshape(sigLong,  "Signal · long",  shape.triangleup,   location.belowbar, color = i_colLong,  size = size.small)
plotshape(sigShort, "Signal · short", shape.triangledown, location.abovebar, color = i_colShort, size = size.small)

// =============================================================================
//  PANEL
// =============================================================================
tabPos = switch i_tabPos
    "Top right"    => position.top_right
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_left

fmtPct(hit, n)  => n <= 0 ? "—" : str.tostring(hit / n * 100, "#.0") + "%"
fmtR(v)         => (v >= 0 ? "+" : "") + str.tostring(v, "#.00")
rColor(netR, n) => n <= 0 ? color.new(i_tabTxt, 55) : netR > 0 ? #4BBF92 : netR < 0 ? #E4736A : i_tabTxt

colHdr(t, r) =>
    table.cell(t, 0, r, "",        text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, r, "n",       text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 2, r, "win%",    text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 3, r, "R/trade", text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 4, r, "t",       text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 5, r, "unres%",  text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 6, r, "rev%",    text_color = color.new(i_tabTxt, 60), text_size = size.tiny, text_halign = text.align_right)
    r + 1

hdrRow(t, r, title) =>
    table.cell(t, 0, r, title, text_color = color.new(i_tabTxt, 45), text_size = size.tiny, text_halign = text.align_left)
    r + 1

noteRow(t, r, txt, col) =>
    table.cell(t, 0, r, txt, text_color = col, text_size = size.tiny, text_halign = text.align_left)
    r + 1

// t is the row's mean R divided by its own standard error. It is the column that
// decides whether the R beside it means anything. Below 2 in absolute value the
// row is indistinguishable from a coin, and R/trade is printed grey to say so
// rather than green or red, because a coloured number invites a decision.
//
// Read it with the number of rows in mind. Looking at ten cells and keeping the
// best one is not the same test as looking at one: under pure noise the best of
// ten lands at t = 1.5 half the time. A single row at t = 1.4 in a panel of ten
// is what noise looks like, not what an edge looks like.
dataRow(t, r, a, cat, lbl) =>
    n    = stView(a, cat, 0)
    revE = stView(a, cat, 1)
    revH = stView(a, cat, 2)
    wins = stView(a, cat, 3)
    netR = stView(a, cat, 5)
    unre = stView(a, cat, 6)
    sqR  = stView(a, cat, 10)
    thin = n > 0 and n < 30
    float mean = n > 0 ? netR / n : na
    float vari = n > 1 ? math.max(sqR / n - mean * mean, 0.0) : na
    float se   = n > 1 and vari > 0 ? math.sqrt(vari / n) : na
    float tval = not na(se) and se > 0 ? mean / se : na
    bool  real = not na(tval) and math.abs(tval) >= 2.0
    table.cell(t, 0, r, lbl, text_color = thin ? color.new(i_tabTxt, 45) : i_tabTxt, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, r, n <= 0 ? "—" : str.tostring(n, "#"),
         text_color = thin ? #D8A33C : color.new(i_tabTxt, 25), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 2, r, fmtPct(wins, n), text_color = color.new(i_tabTxt, 25), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 3, r, n <= 0 ? "—" : fmtR(mean),
         text_color = real ? rColor(netR, n) : color.new(i_tabTxt, 45), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 4, r, na(tval) ? "—" : str.tostring(tval, "#.0"),
         text_color = real ? rColor(netR, n) : color.new(i_tabTxt, 55), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 5, r, fmtPct(unre, n),
         text_color = n > 0 and unre / n > 0.3 ? #D8A33C : color.new(i_tabTxt, 45), text_size = size.tiny, text_halign = text.align_right)
    table.cell(t, 6, r, fmtPct(revH, revE), text_color = color.new(i_tabTxt, 45), text_size = size.tiny, text_halign = text.align_right)
    r + 1

var table panel = table.new(tabPos, 7, 60, bgcolor = i_tabBg,
     border_color = color.new(#333B49, 40), border_width = 1,
     frame_color  = color.new(#333B49, 30), frame_width = 1)

if barstate.islast
    table.clear(panel, 0, 0, 6, 59)
    if i_showTab
        allN   = stView(stAll, 0, 0)
        allUnr = stView(stAll, 0, 6)

        // The long explanation rides on the title cell's tooltip. Printed into
        // the table it set the width of column 0 for every row, which is what
        // made the panel span a third of the chart.
        string panelNote = "HOW TO READ THIS\n\n" +
             "R/trade is the answer column, NET of the round-trip cost set in group 4. It is only coloured when the t beside it clears 2.\n\n" +
             "t is mean R divided by its own standard error. Under 2 the row cannot be told apart from a coin, whatever R says, and both numbers go grey.\n\n" +
             "Read t with the number of rows in mind. Keeping the best of ten cells is not the same test as looking at one: under pure noise the best of ten sits at t = 1.5 half the time. A lone row at 1.4 in a panel of ten is what noise looks like.\n\n" +
             "n is the sample. Under 30 it turns amber: that row is a story, not a measurement.\n\n" +
             "win% is the hit rate of the fixed-R trade.\n\n" +
             "unres% never reached stop or target inside the horizon. A large share means the stop and target do not fit this timeframe, and every other number in the row is computed from the minority that resolved.\n\n" +
             "rev% is the published 50%-retrace statistic. It is NOT a trade you could take, and it flatters shallow events by construction.\n\n" +
             "ON THE CHART\n\n" +
             "A dot marks a detected sweep. It is a measurement mark, not a trade.\n\n" +
             "An arrow marks a sweep that also passed every enabled gate. It says the setup exists, not that it pays. R/trade says that.\n\n" +
             "SESSIONS\n\n" +
             "Four blocks, each read on its own market clock by default: Asia on Tokyo time, London on London time, both New York blocks on New York time. That is what keeps them in the right place through a daylight-saving change, since Tokyo does not observe it and London and New York switch on different dates.\n\n" +
             "FILTER ROWS\n\n" +
             "Bias, premium/discount, SMT and session position are counted whether the filter is switched on or off, so you can see what a filter would have done before turning it on. That is an in-sample comparison on this symbol's history: a clean split over 200 events can be noise.\n\n" +
             "THE PANEL IS NOT A BACKTEST. No order is placed and no fill is guaranteed. The round-trip cost is charged, which is the largest of the old omissions, but queue position, partial fills, funding and the intrabar path are still missing and all of them run in the same optimistic direction."

        r = 0
        table.cell(panel, 0, r, "Killzone Sweep", text_color = i_tabTxt, text_size = size.small, text_halign = text.align_left, tooltip = panelNote)
        table.cell(panel, 6, r, i_tabSide == "All" ? "both" : i_tabSide == "Long only" ? "long" : "short", text_color = color.new(i_tabTxt, 45), text_size = size.tiny, text_halign = text.align_right, tooltip = panelNote)
        r += 1

        if not calibDone
            r := noteRow(panel, r, "calibrating buckets · " + str.tostring(extSamp.size()) + " / " + str.tostring(i_calibN) + " sweeps seen", #D8A33C)
            r := noteRow(panel, r, "nothing is counted until this finishes", color.new(i_tabTxt, 45))
        else
            allScr = stView(stAll, 0, 9)
            mgmtTxt = (beOn ? "BE " : "") + (partialOn ? "partial " : "") + (trailOn ? "trail " : "") + (i_oneAtATime ? "1-at-a-time" : "")
            r := noteRow(panel, r, "counted " + str.tostring(allN, "#") + ", open " + str.tostring(pend.size()) +
                 ", armed " + str.tostring(armed.size()) + (allScr > 0 ? ", scratch " + str.tostring(allScr, "#") : ""), color.new(i_tabTxt, 45))
            r := noteRow(panel, r, i_confirmMode + (mgmtTxt != "" ? ", " + mgmtTxt : ""), color.new(i_tabTxt, 55))
            r := noteRow(panel, r, clockTxt + (presetOn ? ", preset " + i_preset : ", custom windows"), color.new(i_tabTxt, 55))
            if covShort
                r := noteRow(panel, r, "chart data starts " + str.tostring(covLagMin, "#") + " min into a window", #D8A33C)
                r := noteRow(panel, r, "set the chart to electronic / extended hours", color.new(i_tabTxt, 45))
            r := colHdr(panel, r)
            r := dataRow(panel, r, stAll, 0, "every sweep")

            if i_secExt
                r := hdrRow(panel, r, "EXTENSION (ATR)")
                r := dataRow(panel, r, stExt, 0, "shallow <" + str.tostring(EB1, "#.00"))
                r := dataRow(panel, r, stExt, 1, str.tostring(EB1, "#.00") + " – " + str.tostring(EB2, "#.00"))
                r := dataRow(panel, r, stExt, 2, str.tostring(EB2, "#.00") + " – " + str.tostring(EB3, "#.00"))
                r := dataRow(panel, r, stExt, 3, "deep >=" + str.tostring(EB3, "#.00"))

            if i_secPen
                r := hdrRow(panel, r, "PENETRATION (ATR)")
                r := dataRow(panel, r, stPen, 0, "tag <" + str.tostring(PB1, "#.00"))
                r := dataRow(panel, r, stPen, 1, "normal")
                r := dataRow(panel, r, stPen, 2, "break >=" + str.tostring(PB2, "#.00"))

            if i_secKZ
                r := hdrRow(panel, r, "SESSION")
                r := dataRow(panel, r, stKZ, 0, NAME_ASIA)
                r := dataRow(panel, r, stKZ, 1, NAME_LDN)
                r := dataRow(panel, r, stKZ, 2, NAME_NYAM)
                r := dataRow(panel, r, stKZ, 3, NAME_NYPM)
                r := dataRow(panel, r, stKZ, 4, "outside")

            if i_secDow
                r := hdrRow(panel, r, "DAY OF WEEK")
                r := dataRow(panel, r, stDow, 1, "Monday")
                r := dataRow(panel, r, stDow, 2, "Tuesday")
                r := dataRow(panel, r, stDow, 3, "Wednesday")
                r := dataRow(panel, r, stDow, 4, "Thursday")
                r := dataRow(panel, r, stDow, 5, "Friday")
                r := dataRow(panel, r, stDow, 6, "Saturday")
                r := dataRow(panel, r, stDow, 0, "Sunday")

            if i_secBias
                r := hdrRow(panel, r, "HTF BIAS")
                r := dataRow(panel, r, stBias, 0, "with bias")
                r := dataRow(panel, r, stBias, 1, "against bias")

            if i_secZone
                r := hdrRow(panel, r, "PREM / DISC")
                r := dataRow(panel, r, stZone, 0, "correct half")
                r := dataRow(panel, r, stZone, 1, "wrong half")

            if i_secSmt
                r := hdrRow(panel, r, smtValid ? "SMT vs " + smtName : "SMT (no peer)")
                r := dataRow(panel, r, stSmt, 0, "peer diverged")
                r := dataRow(panel, r, stSmt, 1, "peer confirmed")

            if i_secSPos
                r := hdrRow(panel, r, "SESSION POSITION")
                r := dataRow(panel, r, stSPos, 0, "first 1/3")
                r := dataRow(panel, r, stSPos, 1, "middle 1/3")
                r := dataRow(panel, r, stSPos, 2, "last 1/3")

            if i_secLeg
                r := hdrRow(panel, r, "")
                r := noteRow(panel, r, "hover the title for how to read this", color.new(i_tabTxt, 50))

            if allN > 0 and allUnr / allN > 0.3
                r := noteRow(panel, r, "unresolved " + str.tostring(allUnr / allN * 100, "#") + "%, raise the horizon", #D8A33C)

// =============================================================================
//  ALERTS
// =============================================================================
// The same set RaidShift exposes, mapped onto this engine's stages. Set alerts
// to "Once Per Bar Close" for confirmed results.
sweepSell = newSweep and nsDir == 1     // sellside liquidity raided, bullish read
sweepBuy  = newSweep and nsDir == -1    // buyside liquidity raided, bearish read

alertcondition(sweepSell,  'Sellside Liquidity Raided', 'Sellside liquidity raided')
alertcondition(sweepBuy,   'Buyside Liquidity Raided',  'Buyside liquidity raided')
alertcondition(alArmLong,  'LONG Setup Armed',          'LONG setup armed, waiting for the entry trigger')
alertcondition(alArmShort, 'SHORT Setup Armed',         'SHORT setup armed, waiting for the entry trigger')
alertcondition(sigLong,    'LONG Entry Triggered',      'LONG entry triggered')
alertcondition(sigShort,   'SHORT Entry Triggered',     'SHORT entry triggered')
alertcondition(alPartial,  'Partial Banked',            'First target filled, partial banked and the runner protected at entry')
alertcondition(alTpHit,    'Take Profit Hit',           'Take Profit hit')
alertcondition(alSlHit,    'Stop Loss Hit',             'Stop Loss hit')

// Every stage also fires through alert(), so a single "Any alert() function
// call" alert covers the whole engine instead of needing one alert per
// condition. Set it to "Once Per Bar Close".
tick = syminfo.ticker + " " + timeframe.period + ": "

if sweepSell
    alert(tick + "sellside liquidity raided", alert.freq_once_per_bar_close)
if sweepBuy
    alert(tick + "buyside liquidity raided", alert.freq_once_per_bar_close)
if alArmLong
    alert(tick + "LONG setup armed, waiting for the entry trigger", alert.freq_once_per_bar_close)
if alArmShort
    alert(tick + "SHORT setup armed, waiting for the entry trigger", alert.freq_once_per_bar_close)
if sigLong
    alert(tick + "LONG entry triggered, ext " + str.tostring(sigExt, "0.00") + " pen " + str.tostring(sigPen, "0.00"), alert.freq_once_per_bar_close)
if sigShort
    alert(tick + "SHORT entry triggered, ext " + str.tostring(sigExt, "0.00") + " pen " + str.tostring(sigPen, "0.00"), alert.freq_once_per_bar_close)
if alPartial
    alert(tick + "first target filled, partial banked, runner protected at entry", alert.freq_once_per_bar_close)
if alTpHit
    alert(tick + "take profit hit", alert.freq_once_per_bar_close)
if alSlHit
    alert(tick + "stop loss hit", alert.freq_once_per_bar_close)

// =============================================================================
//  HONEST LIMITATIONS
//  ---------------------------------------------------------------------------
//  · The panel is NOT a backtest. No order is placed. Spread, commission,
//    slippage and partial fills are ignored, and every one of those errors runs
//    in the same optimistic direction. Use it to COMPARE buckets against each
//    other on your own instrument, never to estimate what the rules would earn.
//  · Session windows are read on each market's own clock by default, which is
//    what keeps them correct through a daylight-saving change. Switch that off
//    and all four are read on one clock, which is simpler to think in and an
//    hour wrong somewhere for several weeks a year. The ICT preset forces it
//    off, because that set is defined in New York time for every window.
//  · The session high and low lines are drawn from the SAME extremes the engine
//    turns into liquidity pools, so what you see is what it trades. They are
//    live by default, which means a line can still move until its session ends.
//  · An FVG limit is assumed to fill exactly at its level, with no queue and no
//    rejection. That assumption flatters FVG mode specifically, so do not read a
//    small edge over displacement mode as real.
//  · A bar touching both stop and target is booked as a loss. Conservative, and
//    still a guess - a chart carries no intrabar ordering information.
//  · rev% and win% measure different things. rev% is the published
//    session-extreme statistic and it flatters shallow events by construction.
//    R/trade is the column that cannot be bought by shrinking a target.
//  · A bucket with n under roughly 30 is a story, not a measurement.
//  · Filter sections are recorded for every event regardless of whether the
//    filter is switched on, so they show what a filter WOULD have done. That is
//    an in-sample comparison on this symbol's history: a split that looks clean
//    over 200 events can be noise, and choosing the filter because of it is
//    fitting. Prefer filters that also have a reason behind them.
//  · The SMT test compares N-bar extremes, not matched swing pivots. It is a
//    screen, not the same measurement a dedicated SMT tool makes, and it needs
//    the peer to share trading hours.
//  · Bias reads the last CLOSED higher-timeframe bar, so it does not repaint -
//    but it is also one bar stale by construction.
//  · Auto bucket edges are fitted to the first i_calibN sweeps of whatever
//    history the chart loaded. Rows are only comparable within one calibration.
//  · unres% is a validity check, not a result. A large share means the stop and
//    target do not fit this timeframe.
//  · The reclaim window makes timeframes agree far better than a single-bar
//    definition did, but not perfectly: closes are quantised by bar size.
//  · Turn ONE filter on at a time. Switch on five and you will never know which
//    one did it, and you will have fitted all five to the same history.
//  · Signals evaluate on closed bars. Set alerts to "Once Per Bar Close".
//  · Nothing here is financial advice.
// =============================================================================
````
