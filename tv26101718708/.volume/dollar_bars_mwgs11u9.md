# Dollar Bars

- url: https://www.tradingview.com/script/MWGs11u9-Dollar-Bars/
- type: indicator
- pine_id: PUB;834ef73aee864484927db71e715a9462
- version: 1.0

## Description

Most charts slice the market by the clock. This one slices by money: a new bar closes every time a fixed dollar amount has traded, however long that takes. Bars are narrow when capital is moving fast and wide when it isn't, and every bar carries the same weight in the moving averages regardless of how long it took to form.

[image]https://www.tradingview.com/x/PT5kP1CK/[/image]

[b]Setup[/b] — two steps that matter

[i]1. Put the chart on 1-minute.[/i] Dollar bars can only close on a native bar boundary, so the chart's timeframe is the finest resolution available to them. On a 15-minute chart every dollar bar would be some multiple of 15 minutes, which defeats the purpose. Use the lowest timeframe your plan allows.

[i]2. Hide the native candles.[/i] Chart Settings → Symbol tab → uncheck Body, Borders, and Wick. Skip this and you are looking at two charts stacked on each other: the real 1-minute candles underneath and the dollar bars this script draws on top. This is the step people miss. The dollar bars are drawn objects and remain fully visible.

[i]3. Adjust indicator settings.[/i] Set Market to match what you are charting — US Stocks for equities, Crypto for coins, Custom for futures and anything else. Then set Target Minutes per Bar to the cadence you want the Dollar Bars chart set to and read Median min in the stats panel. Dollar Bars works out the notional per bar needed to bring the median close to that figure. Set it to 15 and a typical bar takes about as long as a 15-minute candle — individual bars still run from seconds to an hour, which is the point.

[b]Why it works this way[/b]

Every chart you have ever looked at slices the market by the clock. A 15-minute bar covers 15 minutes whether $2 million or $2 billion changed hands inside it. That means a dead lunch hour gets exactly as much weight in your moving averages as the opening drive.

This indicator slices by money instead. A new bar closes every time a fixed dollar amount has traded — say $300 million — however long that takes. When capital is moving, bars complete in seconds and appear narrow. When the tape goes quiet, a single bar can stretch across an hour.

Two consequences follow, and they are the whole point.

[i]Every bar carries equal information.[/i] A 30-second flush and a 45-minute drift count the same. Quiet periods can no longer push an average around on thin volume, because quiet periods barely produce bars.

[i]Bar width becomes a signal.[/i] Narrow bars mean money moved fast. Wide bars mean it didn't. That is a read on participation intensity you cannot get from a time chart, where every bar is the same width by construction.

This is not a new idea. Constant-notional sampling is well established in quantitative finance — Marcos López de Prado's Advances in Financial Machine Learning makes the case that dollar bars produce better-behaved return distributions than time bars do. It has simply never been available natively on TradingView.

[b]Why dollars and not ticks[/b]

TradingView offers tick charts, which close a bar every N trades. That sounds similar but measures something different.

[i]Tick charts count transactions, not size.[/i] Execution algorithms shred large orders into hundreds of small prints, so a name being worked quietly by a VWAP algo generates enormous trade counts on modest actual size. Tick bars therefore partly track how fragmented the order flow is — a market-structure artifact — rather than how much capital is moving.

[i]Dollar bars count notional.[/i] A $300 million bar is $300 million whether it arrived in three block trades or three thousand odd lots. It also stays comparable across price levels and through splits, which neither tick counts nor share counts do.

[b]The threshold, and how it is derived[/b]

The dollar amount per bar has to be set per symbol — $300 million is a sensible bar on one name and absurd on another. Rather than make you look that up, the script derives it from the symbol's own volume.

You tell it how long you want a typical bar to take. It converts recent daily dollar volume into a per-minute rate and multiplies by your target.

[i]Rolling trailing[/i] (default) — every bar captures the trailing N-day calibration at its own open and holds it for that bar's life. Never goes stale, self-calibrates per symbol, renders full history. This is the mode for live charts, alerts, and watchlists: one alert configuration works across every symbol because nothing in it is an absolute number.

[i]Frozen at anchor[/i] — derived once from the days before your anchor date, then fixed forever. Every bar on the chart represents the identical dollar amount, which is the property that makes bars comparable across months and regimes. This is the honest mode for research. Its weakness is staleness: a symbol whose volume doubles will have its bars sized by the old regime until you re-anchor.

[i]Manual[/i] — you set the number. Use it when you want an exact, reproducible value. The stats panel shows a Recent figure — what the last N days imply right now — so you have the number to enter, and it turns orange when it has drifted more than 15% from what you are using.

[b]Cadence adjustment[/b] — read this before tuning

Volume is not spread evenly through a session, so the average minute and the typical minute are different quantities. In equities the opening and closing auctions dump enormous notional in seconds, inflating the daily total and therefore the threshold, so ordinary intraday bars run long. Left uncorrected, a 15-minute target produces a median bar closer to 24 minutes.

The Cadence adjustment divides that out. 1.6 is typical for US large caps. Crypto has no auctions and trades around the clock, so its volume is flatter than the daily figure implies and the factor lands below 1 — 0.8 measured on BTC.

Both numbers are estimates and will be wrong for some symbols. 

The field switches automatically with your Market selection, so the equity and crypto values are stored separately.

[b]The stats panel[/b]

Bottom left, compact by default — two rows showing the bar currently forming: elapsed time, pace against the median, notional traded so far, and a fill gauge. Beneath that, the median duration, the efficiency ratio, and the dollar amount per bar.

Uncheck Compact for the full panel: five groups covering how the threshold was derived, what cadence your history actually produced, the live bar, regime and health state, and the last completed bar's OHLC with its fill time.

Hovering any bar shows the dollar bar's own open, high, low, close, start time, and elapsed minutes in the Data Window (Alt+D). The chart's own OHLC legend always shows the native 1-minute bar — the crosshair belongs to the platform and no script can redirect it.

[b]Efficiency ratio[/b]

Net price movement divided by total distance traveled, computed on the dollar bar series.

On a time chart this measure conflates two situations: a quiet hour and an efficient hour both score high, because neither has much path. Here that ambiguity disappears. Since every bar holds dollars constant, the ratio reads as price progress per dollar of capital deployed. High means money is moving price directionally. Low means a great deal of money changed hands and price went nowhere — churn, absorption, someone being filled against resistance.

Optional background tint when it falls below your threshold. Off by default.

[b]EMAs and alerts[/b]

Three EMAs computed on completed dollar bars only — blue, gray, and orange, lengths configurable. They advance when a bar closes, never on the 1-minute bars underneath.

Seven alert conditions, all evaluated on dollar-bar completion: price crossing your selected EMA in either direction, blue crossing gray in either direction, the efficiency ratio entering or leaving its choppy regime, and a plain new-bar notification.

Use Once Per Bar Close. Once Per Bar fires intrabar on a provisional value that can reverse before the minute ends.

For watchlist alerts: use Rolling with Daily average calibration. The alert stores your input values, not the derived threshold, so every symbol calibrates itself from its own volume. Avoid Manual for watchlists — it stores one literal dollar figure and applies it to every symbol in the list.

[b]Limitations[/b] — stated plainly

This cannot be made into a strategy honestly. Pine resolves order fills on native bar boundaries, but dollar bars close inside a native bar. A backtest built on this would attribute entries and exits to the wrong price and time and produce a clean-looking report that lies to you. Use a proper research environment for that work. This is a visual and alerting instrument.

Only the most recent 500 bars are drawn. Pine caps boxes at 500. Scroll far enough back and you will find EMA lines over empty space. This affects the drawing only — the EMAs, the efficiency ratio, and every figure in the panel are computed from running state across the full history. The panel's Drawn row tells you the real count.

Alerts carry up to one native bar of latency. The condition becomes true when the dollar bar completes; delivery happens at the native bar close.

Intraday median calibration needs deep history — roughly lookback days × 390 native bars. Alert servers often load less, in which case it produces nothing. Daily average needs about 20 daily bars and works everywhere, which is why it is the default.

Nothing renders before the anchor date in Frozen mode. Pine runs strictly forward and cannot apply a threshold it has not yet computed.

[b]Notes[/b]

Open source. Use it, fork it, improve it.

Bar durations are right-skewed — a floor near zero, no ceiling — so a handful of very wide bars pull the mean well above the median. Tune to the median, not the average, especially when comparing several symbols. Matching medians gives you charts whose typical bar is the same length; matching means does not, because the tails differ by symbol.

Feedback and bug reports welcome in the comments.

Content

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  DOLLAR BARS + EMAs + EFFICIENCY RATIO  —  v3
//
//  Builds synthetic dollar bars (fixed notional traded per bar) from the
//  chart's native bars. Every bar represents the same dollar amount changing
//  hands, so bars are narrow when capital is moving fast and wide when it
//  isn't. EMAs and the Efficiency Ratio advance only on COMPLETED dollar
//  bars, never on the underlying time bars.
//
//  THRESHOLD DERIVATION
//   With Auto-derive on, the script reads N-day average daily dollar volume
//   as of the Anchor Date, converts it to dollars-per-minute, multiplies by
//   your Target Minutes per Bar, then FREEZES that value for the rest of the
//   chart. It never updates again until you change the anchor date, so bars
//   never rebuild retroactively.
//
//   To re-derive: change the Anchor Date. That date is also your record of
//   which threshold was live in which period.
//
//  CALIBRATION
//   "Calibrate from" decides how the threshold is estimated.
//
//   Intraday median (default) measures the dollar volume of every rolling
//   window of Target Minutes across the lookback and takes the median. By
//   construction half those windows clear the threshold, so MEDIAN bar
//   duration lands on your target with no hand tuning.
//
//   Daily average divides average daily dollar volume by session minutes,
//   then divides by the Cadence adjustment factor. Daily volume is not spread
//   evenly across a session, so the mean minute and the median minute differ;
//   this factor makes Target Minutes land on the MEDIAN. Equities need >1
//   because auctions inflate the daily total (1.6 typical for US large caps).
//   Crypto measured below 1 — no auctions, flatter round-the-clock volume
//   (0.8 from a BTC sample). Both are ESTIMATES that vary by symbol; tune by
//   multiplying the factor by (Median min / target). The field shown changes
//   with the Market setting.
//
//   Use Daily average for alerts and watchlists: it needs only ~20 daily
//   bars, while the intraday median needs lookbackDays x 390 native bars,
//   which an alert server often does not load.
//
//  SESSIONS
//   Daily bars always follow the main exchange session, even when the chart
//   is set to Extended or 24h. So the derived threshold is always calibrated
//   to REGULAR-hours intensity. That is intentional: switch the chart to ETH
//   or 24h and overnight volume accumulates against the same threshold,
//   producing very wide bars overnight. A bar still means the same dollars
//   whenever it forms. Override Session Minutes only for futures or crypto.
//
//  CAUSALITY
//   Pine runs forward only. The threshold cannot be applied to bars that
//   precede the anchor date, so nothing renders before it. Set the anchor to
//   the START of the window you want to study.
//
//   To apply TODAY'S average across ALL history: read the "Recent" figure in
//   the THRESHOLD group — that is the threshold the last 20 days imply right
//   now — type it into Manual Threshold, and set mode to Manual. Every bar on
//   the chart then uses that one constant, calibrated to current liquidity.
//   This needs a human step because Pine runs strictly forward and cannot
//   make a right-edge value available at a left-edge bar.
//
//   "Recent" turns orange when it has drifted more than 15% from the
//   threshold actually in use — that is your signal to recalibrate.
//
//  ══ CHART SETUP — REQUIRED ══════════════════════════════════════════════════
//
//   1. TIMEFRAME: set the chart to 1-minute, or the lowest you have access to.
//      Dollar bars can only close on a native bar boundary, so the chart's
//      timeframe is your granularity floor. On a 15-min chart every dollar bar
//      would be a multiple of 15 minutes, which defeats the purpose.
//
//   2. HIDE THE NATIVE CANDLES — this is the step people miss.
//      Chart Settings > Symbol tab > uncheck Body, Borders, and Wick.
//      Without it you are looking at two charts stacked on each other: the
//      real 1-min candles underneath and the dollar bars this script draws.
//      The dollar bars are drawn objects and stay visible.
//
//   3. THRESHOLD: leave Auto-derive on and set Target Minutes per Bar to the
//      cadence you want. Then read "Avg minutes/bar" in the table. If it is
//      far off your target, turnover has drifted since the anchor date —
//      either move the anchor or adjust the target to compensate.
//
//   4. WARMUP: a 200-length EMA needs roughly 600 completed dollar bars before
//      it means anything. The table says WARMING UP until then. Load more
//      history or raise Target Minutes if it will not clear.
//
//  ══ READING A BAR'S OHLC AND TIME ═══════════════════════════════════════════
//
//   The crosshair and magnet snap to the NATIVE 1-min bars underneath — that
//   is platform behavior no script can change — and the main OHLC legend at
//   top-left always shows the native bar, not the dollar bar.
//
//   The dollar bar's values are published instead through this indicator's
//   own readout. Hover any native bar and you get, in the status line and in
//   the Data Window (right sidebar, or Alt+D):
//
//     $Bar Open / High / Low / Close  — the state of the dollar bar that
//        owned that moment. Mid-bar these are running values; on a bar's
//        LAST native slot they are its final OHLC.
//     $Bar Start (HHMM)               — when the bar began. 932 = 9:32.
//     $Bar Elapsed (min)              — how long it had been forming.
//
//   To declutter the top-left readout, uncheck "Values in status line" in
//   the Style tab; the Data Window keeps everything.
//
//  ══ THE "DRAWN" ROW ═════════════════════════════════════════════════════════
//
//   Pine allows a maximum of 500 boxes and 500 lines on a chart. Dollar bars
//   are drawn with boxes, so only the most recent 500 are VISIBLE. When the
//   table reads "500 of 2800", there are 2800 bars in the calculation and the
//   oldest 2300 have been dropped from the display.
//
//   This affects the DRAWING ONLY. The EMAs, the Efficiency Ratio, and every
//   figure in the table are computed from running state variables that span
//   the full history — they never touch the drawing layer. An EMA at bar 2800
//   carries all 2800 bars behind it whether or not those bars are on screen.
//
//   So if you scroll left and find EMA lines floating over empty space, that
//   is the cap, not a failure. To see more history at once, raise Target
//   Minutes per Bar: fewer, wider bars cover the same span. The cost is
//   coarser sampling.
//
//  ══ LIMITS (Pine, not this script) ══════════════════════════════════════════
//
//   - This is an indicator and cannot be made into a strategy honestly.
//     Pine resolves order fills on NATIVE bar boundaries, but dollar bars
//     close INSIDE a native bar. Any backtest built on this would attribute
//     entries and exits to the wrong price and time. Use Python for that.
//   - Alerts fire on dollar-bar completion but are delivered on the native
//     bar close, so expect up to one native bar of latency.
//   - With "Close bar at session end" on (the default), the final bar of each
//     session is force-completed and may hold far less than the threshold.
//     These stub bars count as full bars in the EMAs and the ER.
//   - Duration labels and fast-bar dots share one 500-label pool. Turning
//     both on shortens how far back the decorations stay visible.
//   - Auto-derive adds a daily request.security call. On long intraday
//     histories this is a real load increase.
//   - Nothing renders before the Anchor Date. Pine runs forward only and
//     cannot apply a threshold it has not yet computed.
// ─────────────────────────────────────────────────────────────────────────────

indicator("Dollar Bars", "$Bars", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ── Inputs: threshold derivation ─────────────────────────────────────────────
gT = "Threshold"
derivMode = input.string("Rolling trailing", "Threshold mode",
     options = ["Rolling trailing", "Frozen at anchor", "Manual"], group = gT,
     tooltip = "Rolling (default): each bar captures the trailing N-day calibration at its own " +
               "open and holds it. Never stale, self-calibrates per symbol, renders full " +
               "history — the right mode for live alerts and watchlists. Cost: notional per " +
               "bar drifts, so an EMA spanning a sharp liquidity shift covers inconsistent " +
               "units until the lookback refills.\n\n" +
               "Frozen: derive once from the N days before the anchor date, then never change. " +
               "Every bar is the same notional forever — the property that makes dollar bars " +
               "comparable across time, and the honest mode for research. Goes stale as " +
               "liquidity drifts.\n\n" +
               "Manual: fixed value you set below. To calibrate to current liquidity, read the " +
               "Recent figure in the stats table and enter it here.",
     display = display.none)
isFrozen  = derivMode == "Frozen at anchor"
isRolling = derivMode == "Rolling trailing"
useAuto   = isFrozen or isRolling

anchorTime = input.time(timestamp("01 Jan 2026 00:00 +0000"), "Anchor Date", group = gT,
     tooltip = "Threshold is derived from the N days immediately BEFORE this date, then frozen. " +
               "Bars before this date are not built. If your intraday history starts later, " +
               "the freeze happens at the left edge instead.", display = display.none,
     active = isFrozen)
lookbackDays = input.int(10, "Lookback (days)", minval = 1, maxval = 250, group = gT,
     tooltip = "Days of history the threshold is calibrated from. Shorter reacts faster to a " +
               "ticker whose volume has changed regime; longer is steadier against a single " +
               "earnings or rebalance day. 10 tracks recent activity, 20 is more stable.",
     display = display.none, active = useAuto)
targetMins = input.float(15.0, "Target Minutes per Bar", minval = 0.1, step = 1.0, group = gT,
     tooltip = "The cadence you want, in regular-hours minutes. Individual bar durations still " +
               "float with activity, by design — this sets the center of the distribution.",
     active = useAuto)
calibMethod = input.string("Daily average", "Calibrate from",
     options = ["Daily average", "Intraday median"], group = gT,
     tooltip = "Daily average (default): daily dollar volume / session minutes x target, " +
               "divided by the auction adjustment. Needs only ~20 daily bars, so it works on " +
               "alert servers and watchlists.\n\n" +
               "Intraday median: measures every rolling window of Target Minutes across the " +
               "lookback and takes the median dollar volume of those windows. Half of them clear " +
               "the threshold, so MEDIAN bar duration lands on your target directly. Robust to " +
               "opening and closing auctions. Needs intraday history to warm up.\n\n" +
               "Daily average: daily dollar volume / session minutes x target. Simpler, but " +
               "auction volume inflates the daily total, so median duration typically runs " +
               "1.4x to 1.8x your target before the auction adjustment below corrects it. " +
               "Use if intraday history is short, or for alerts.",
     display = display.none, active = useAuto)
marketType = input.string("US Stocks", "Market", options = ["US Stocks", "Crypto", "Custom"],
     group = gT,
     tooltip = "Sets the session minutes used to convert daily dollar volume into a per-minute " +
               "rate. US Stocks = 390 (regular hours — correct even on Extended or 24h charts, " +
               "because daily volume is always RTH). Crypto = 1440. Custom: futures and " +
               "anything else — enter the minutes your contract's daily volume covers.",
     active = useAuto)
customMins = input.int(390, "Custom Session Minutes", minval = 1, maxval = 1440, group = gT,
     tooltip = "Only used when Market is set to Custom.", display = display.none,
     active = useAuto and marketType == "Custom")
sessionMins = marketType == "US Stocks" ? 390 : marketType == "Crypto" ? 1440 : customMins

// Cadence correction: daily volume is not spread evenly across the session, so the
// mean minute and the median minute differ. Dividing by this factor makes Target
// Minutes land on the MEDIAN. Equities need >1 (auctions inflate the daily total);
// BTC measured below 1, so its volume is flatter than the daily figure implies.
adjEquity = input.float(1.6, "Cadence adjustment", minval = 0.3, maxval = 4.0, step = 0.05,
     group = gT,
     tooltip = "ESTIMATE, not a constant — tune it per symbol. Opening and closing auctions " +
               "dump large notional in seconds, inflating daily dollar volume and therefore " +
               "the threshold, so uncorrected bars run long. 1.6 is typical for US large caps.\n\n" +
               "To tune: compare Median min in the stats table against Target Minutes and " +
               "multiply this factor by (median / target). Linear, so one pass converges. " +
               "Only applies to Daily average calibration.",
     display = display.none,
     active = useAuto and calibMethod == "Daily average" and marketType != "Crypto")
adjCrypto = input.float(0.8, "Cadence adjustment", minval = 0.3, maxval = 4.0, step = 0.05,
     group = gT,
     tooltip = "ESTIMATE, not a constant — tune it per symbol. Crypto has no auctions and " +
               "trades around the clock, so volume is spread more evenly than in equities and " +
               "the factor lands below 1. 0.8 is derived from a BTC measurement, not a " +
               "published constant; thinner alts will differ.\n\n" +
               "To tune: compare Median min in the stats table against Target Minutes and " +
               "multiply this factor by (median / target). Linear, so one pass converges. " +
               "Only applies to Daily average calibration.",
     display = display.none,
     active = useAuto and calibMethod == "Daily average" and marketType == "Crypto")
auctionAdj = marketType == "Crypto" ? adjCrypto : adjEquity
manualThreshold = input.float(500.0, "Manual Threshold ($M)", minval = 0.001,
     step = 10.0, group = gT,
     tooltip = "Entered in millions. 300 = $300,000,000 per bar.", display = display.none,
     active = not useAuto)

// ── Inputs: construction ─────────────────────────────────────────────────────
gB = "Construction"
basis = input.string("hlc3", "Notional Basis", options = ["close", "hl2", "hlc3"], group = gB,
     tooltip = "Price used to convert share volume to dollars within each native bar.", display = display.none)
forceClose = input.bool(true, "Close bar at session end", group = gB,
     tooltip = "On: the forming bar is force-completed on the session's last native bar, so no " +
               "bar ever spans the overnight gap. The final bar of a session may hold far less " +
               "than the threshold — stub bars count as full bars in the EMAs and ER. " +
               "Off: pure constant-notional construction; bars can span gaps.", display = display.none)

// ── Inputs: EMAs ─────────────────────────────────────────────────────────────
gE = "EMAs"
len1  = input.int(55,  "EMA Blue Length", minval = 1, maxval = 5000, group = gE, inline = "e1")
show1 = input.bool(true,  "Show",      group = gE, inline = "e1", display = display.none)
len2  = input.int(200, "EMA Gray Length", minval = 1, maxval = 5000, group = gE, inline = "e2")
show2 = input.bool(true,  "Show",      group = gE, inline = "e2", display = display.none)
len3  = input.int(21,  "EMA Orange Length", minval = 1, maxval = 5000, group = gE, inline = "e3")
show3 = input.bool(true,  "Show",      group = gE, inline = "e3", display = display.none)
emaSrc = input.string("close", "EMA Source", options = ["close", "hl2", "hlc3", "ohlc4"], group = gE, display = display.none)

// ── Inputs: efficiency ratio ─────────────────────────────────────────────────
gR = "Efficiency Ratio"
erLen = input.int(20, "ER Lookback (dollar bars)", minval = 2, maxval = 500, group = gR,
     tooltip = "Net price change over this many dollar bars, divided by total path travelled. " +
               "Because every bar holds dollars constant, this reads as price progress per " +
               "dollar of capital deployed — not just volatility.", display = display.none)
erChop = input.float(0.30, "Choppy below", minval = 0.01, maxval = 0.99, step = 0.05, group = gR,
     tooltip = "ER at or below this value tints the background. Near 1.0 = money is moving " +
               "price directionally. Near 0 = money is churning and price is going nowhere.", display = display.none)
showTint = input.bool(false, "Tint background when choppy", group = gR, display = display.none)
chopCol = input.color(color.red, "Tint color", group = gR, active = showTint)
tintOpacity = input.int(80, "Tint opacity", minval = 50, maxval = 99, group = gR, active = showTint, display = display.none)

// ── Inputs: alerts ───────────────────────────────────────────────────────────
gA = "Alerts"
alertEmaSel = input.string("EMA Blue", "Price cross alerts use",
     options = ["EMA Blue", "EMA Gray", "EMA Orange"],
     group = gA, tooltip = "Which EMA the dollar-bar close is tested against.", display = display.none)

// ── Inputs: style ────────────────────────────────────────────────────────────
gS = "Style"
upCol = input.color(#26a69a, "Up",   group = gS, inline = "bc")
dnCol = input.color(#ef5350, "Down", group = gS, inline = "bc")
showTbl = input.bool(true, "Show stats table", group = gS, display = display.none)
tblCompact = input.bool(true, "Compact (live bar only)", group = gS, active = showTbl,
     tooltip = "Collapses the panel to two rows: elapsed, pace, traded, and fill on top; " +
               "median duration, efficiency ratio, and threshold beneath. Hides the cadence, " +
               "last-bar, and health groups.",
     display = display.none)
tblNudge = input.int(0, "Table offset from left (%)", minval = 0, maxval = 60, group = gS, active = showTbl,
     tooltip = "Shifts the stats table right from the bottom-left corner by this percent of " +
               "chart width. 0 = flush left.",
     display = display.none)
tblOpacity = input.int(50, "Table background opacity", minval = 0, maxval = 100, group = gS, active = showTbl,
     tooltip = "Transparency of the stats panel background. 100 = fully transparent, " +
               "0 = solid black. Headers render slightly less transparent than data cells.",
     display = display.none)
showDur = input.bool(true, "Label bar duration (minutes)", group = gS,
     tooltip = "Prints each completed bar's fill time above it. Shares the 500-label pool " +
               "with fast-bar dots, so labeled history is shorter when both are on.", display = display.none)
showFastMark = input.bool(false, "Mark fast bars", group = gS,
     tooltip = "Dot under bars that completed in the bottom 20% of historical durations — " +
               "the threshold was consumed unusually fast, meaning urgent participation. " +
               "Needs 30 completed bars before it starts marking.", display = display.none)
showCross = input.bool(true, "Mark EMA crosses", group = gS,
     tooltip = "Triangles where the dollar-bar close crossed the selected alert EMA.", display = display.none)

// ── Derive and freeze the threshold ──────────────────────────────────────────
// [1] on the daily series excludes the still-forming session.
dailyAvgDV = request.security(syminfo.tickerid, "D",
     ta.sma(hlc3 * nz(volume), lookbackDays)[1],
     lookahead = barmerge.lookahead_off)

// round to two significant figures so the derived threshold is stable to quote
f_sig2(float x) =>
    if x <= 0
        x
    else
        m = math.pow(10, math.floor(math.log10(x)) - 1)
        math.round(x / m) * m

// ── Intraday median calibration ──────────────────────────────────────────────
// Sum dollar volume over every rolling window of targetMins, then take the
// median of those sums across the lookback. Half the windows clear it, so the
// MEDIAN bar duration lands on target. Auctions are outliers a median ignores.
tfM      = timeframe.in_seconds(timeframe.period) / 60.0
winBars  = math.max(1, int(targetMins / tfM))
lookBars = math.min(int(lookbackDays * sessionMins / tfM), 5000)
rollWin  = math.sum(hlc3 * nz(volume), winBars)
medianThr = bar_index >= lookBars ?
     ta.percentile_nearest_rank(rollWin, lookBars, 50) : na

useMedian = calibMethod == "Intraday median"
estimate = useMedian ? medianThr :
     (not na(dailyAvgDV) and dailyAvgDV > 0 ?
      dailyAvgDV / sessionMins * targetMins / auctionAdj : na)

var float frozenThr  = na
var int   frozenTime = na

if isFrozen and na(frozenThr) and not na(estimate) and estimate > 0 and time >= anchorTime
    frozenThr  := f_sig2(estimate)
    frozenTime := time

// live right-edge calibration, shown as "Recent" for copying into Manual
recentThr = not na(estimate) and estimate > 0 ? f_sig2(estimate) : na

threshold = isFrozen ? frozenThr : isRolling ? recentThr : manualThreshold * 1000000.0
active    = not na(threshold) and threshold > 0

// ── State ────────────────────────────────────────────────────────────────────
var float accum   = 0.0
var float dO      = na
var float dH      = na
var float dL      = na
var float dC      = na
var int   dStart  = na
var int   dStartT = na
var int   nBars   = 0
var float barThr  = na   // threshold captured at this bar's open; holds for its life

var float e1  = na
var float e2  = na
var float e3  = na
var float pC  = na
var float pE  = na

var int nDone   = 0
var int nNative = 0

// last completed bar, for the stats table
var float lO = na
var float lH = na
var float lL = na
var float lC = na
var float lDur = na
var int   lCloseT = na

var float er = na
var array<float> dbC = array.new_float()
var array<float> durArr = array.new_float()   // completed-bar durations, minutes

tfMins = timeframe.in_seconds(timeframe.period) / 60.0

// forming-bar drawing handles (reused, never accumulated)
var box  fBox  = na
var line fWick = na

bPrice  = basis == "close" ? close : basis == "hl2" ? hl2 : hlc3
thisDol = bPrice * nz(volume)

// ── Accumulate ───────────────────────────────────────────────────────────────
if active
    if na(dO)
        dO      := open
        dH      := high
        dL      := low
        dStart  := bar_index
        dStartT := time
        barThr  := threshold
        accum   := 0.0
        nBars   := 0
    dH      := math.max(dH, high)
    dL      := math.min(dL, low)
    dC      := close
    accum   += thisDol
    nBars   += 1
    nNative += 1

done = active and (accum >= barThr or (forceClose and session.islastbar and nBars > 0))

// captured before the completion block resets dO, so the readout stays valid
// on the native bar where a dollar bar completes
shownO = dO

// ── Complete: advance EMAs and ER, draw, reset ───────────────────────────────
a1 = 2.0 / (len1 + 1)
a2 = 2.0 / (len2 + 1)
a3 = 2.0 / (len3 + 1)

if done
    nDone += 1
    curDur = nBars * tfMins
    isFast = array.size(durArr) >= 30 and
         curDur <= array.percentile_linear_interpolation(durArr, 20)
    array.push(durArr, curDur)
    lO := dO
    lH := dH
    lL := dL
    lC := dC
    lDur := curDur
    lCloseT := time_close

    src = emaSrc == "close" ? dC :
          emaSrc == "hl2"   ? (dH + dL) / 2.0 :
          emaSrc == "hlc3"  ? (dH + dL + dC) / 3.0 :
                              (dO + dH + dL + dC) / 4.0

    // capture prior state for cross detection before overwriting
    aE = alertEmaSel == "EMA Blue" ? e1 : alertEmaSel == "EMA Gray" ? e2 : e3
    pC := na(aE) ? na : dC
    pE := aE

    e1 := na(e1) ? src : a1 * src + (1.0 - a1) * e1
    e2 := na(e2) ? src : a2 * src + (1.0 - a2) * e2
    e3 := na(e3) ? src : a3 * src + (1.0 - a3) * e3

    // ── Efficiency Ratio on the dollar-bar series ────────────────────────────
    array.push(dbC, dC)
    if array.size(dbC) > erLen + 1
        array.shift(dbC)
    if array.size(dbC) == erLen + 1
        netMove = math.abs(array.get(dbC, erLen) - array.get(dbC, 0))
        path = 0.0
        for i = 1 to erLen
            path += math.abs(array.get(dbC, i) - array.get(dbC, i - 1))
        er := path > 0 ? netMove / path : 0.0

    // ── Draw the completed bar ───────────────────────────────────────────────
    col = dC >= dO ? upCol : dnCol
    mid = math.round((dStart + bar_index) / 2.0)

    if math.abs(dC - dO) < syminfo.mintick
        line.new(dStart, dC, bar_index, dC, xloc = xloc.bar_index, color = col, width = 2)
    else
        box.new(dStart, math.max(dO, dC), bar_index, math.min(dO, dC),
             xloc = xloc.bar_index, border_color = col, border_width = 1,
             bgcolor = color.new(col, 25))

    line.new(mid, dH, mid, dL, xloc = xloc.bar_index, color = col, width = 1)

    if showFastMark and isFast
        label.new(mid, dL - math.max((dH - dL) * 0.15, syminfo.mintick * 8), "",
             xloc = xloc.bar_index, style = label.style_circle,
             color = color.new(color.yellow, 20), size = size.tiny)

    if showDur
        dTxt = curDur >= 10 ? str.tostring(math.round(curDur)) + "m" :
             str.tostring(curDur, "#.#") + "m"
        label.new(mid, dH + math.max((dH - dL) * 0.30, syminfo.mintick * 25), dTxt,
             xloc = xloc.bar_index, style = label.style_none,
             textcolor = color.new(#e0e3eb, 0), size = size.tiny)

    if not na(fBox)
        box.delete(fBox)
        line.delete(fWick)
        fBox  := na
        fWick := na

    dO := na

// ── Forming bar: one reusable box + wick, updated every native bar ───────────
if active and not done
    fCol = dC >= dO ? upCol : dnCol
    fTop = math.max(dO, dC)
    fBot = math.min(dO, dC)
    fMid = math.round((dStart + bar_index) / 2.0)
    if na(fBox)
        fBox  := box.new(dStart, fTop, bar_index, fBot, xloc = xloc.bar_index,
             border_color = fCol, border_width = 1, bgcolor = color.new(fCol, 25))
        fWick := line.new(fMid, dH, fMid, dL, xloc = xloc.bar_index, color = fCol, width = 1)
    else
        box.set_lefttop(fBox, dStart, fTop)
        box.set_rightbottom(fBox, bar_index, fBot)
        box.set_border_color(fBox, fCol)
        box.set_bgcolor(fBox, color.new(fCol, 25))
        line.set_xy1(fWick, fMid, dH)
        line.set_xy2(fWick, fMid, dL)
        line.set_color(fWick, fCol)

// ── Plots ────────────────────────────────────────────────────────────────────
plot(show1 ? e1 : na, "EMA Blue", color = #2962ff, linewidth = 2)
plot(show2 ? e2 : na, "EMA Gray", color = #868993, linewidth = 2)
plot(show3 ? e3 : na, "EMA Orange", color = color.orange, linewidth = 2)

isChop = showTint and not na(er) and er <= erChop
bgcolor(isChop ? color.new(chopCol, tintOpacity) : na, title = "Choppy tint", editable = false)

// crosshair-readable values; invisible on the chart and hidden from Style
plot(er, "Efficiency Ratio", display = display.data_window, editable = false)
plot(accum / 1000000.0, "Bar notional ($M)", display = display.data_window, editable = false)
plot(threshold / 1000000.0, "Threshold ($M)", display = display.data_window, editable = false)

// dollar-bar state as of each native bar; a bar's final slot shows its true OHLC
plot(shownO, "$Bar Open",  display = display.data_window, color = #e0e3eb, editable = false)
plot(dH,     "$Bar High",  display = display.data_window, color = #26a69a, editable = false)
plot(dL,     "$Bar Low",   display = display.data_window, color = #ef5350, editable = false)
plot(dC,     "$Bar Close", display = display.data_window, color = #e0e3eb, editable = false)
plot(na(dStartT) ? na : hour(dStartT) * 100 + minute(dStartT), "$Bar Start (HHMM)",
     display = display.data_window, editable = false)
plot(nBars * tfMins, "$Bar Elapsed (min)", display = display.data_window, editable = false)

// ── Alerts (all evaluated on dollar-bar completion) ──────────────────────────
alertcondition(done, "New dollar bar", "A dollar bar completed")
aEma = alertEmaSel == "EMA Blue" ? e1 : alertEmaSel == "EMA Gray" ? e2 : e3

pxUp = done and not na(pC) and not na(pE) and dC > aEma and pC <= pE
pxDn = done and not na(pC) and not na(pE) and dC < aEma and pC >= pE
alertcondition(pxUp, "Price crossed ABOVE selected EMA",
     "Dollar bar closed above the selected EMA")
alertcondition(pxDn, "Price crossed BELOW selected EMA",
     "Dollar bar closed below the selected EMA")

// cross markers: up-triangle below the bar on a bullish cross, down-triangle above on bearish
crossUpY = showCross and pxUp ? dL - math.max((dH - dL) * 0.35, syminfo.mintick * 12) : na
crossDnY = showCross and pxDn ? dH + math.max((dH - dL) * 0.35, syminfo.mintick * 12) : na
plotshape(crossUpY, "Cross above EMA", style = shape.triangleup,
     location = location.absolute, color = upCol, size = size.tiny, editable = false)
plotshape(crossDnY, "Cross below EMA", style = shape.triangledown,
     location = location.absolute, color = dnCol, size = size.tiny, editable = false)

emaUp = done and not na(e1) and not na(e2) and e1 > e2 and e1[1] <= e2[1]
emaDn = done and not na(e1) and not na(e2) and e1 < e2 and e1[1] >= e2[1]
alertcondition(emaUp, "EMA Blue crossed ABOVE EMA Gray", "Blue EMA crossed above gray EMA")
alertcondition(emaDn, "EMA Blue crossed BELOW EMA Gray", "Blue EMA crossed below gray EMA")

erIn  = done and not na(er) and er > erChop and er[1] <= erChop
erOut = done and not na(er) and er <= erChop and er[1] > erChop
alertcondition(erIn,  "Regime turned TRENDING", "Efficiency Ratio rose above the choppy threshold")
alertcondition(erOut, "Regime turned CHOPPY",   "Efficiency Ratio fell below the choppy threshold")

// ── Stats table: four column groups, bottom left ─────────────────────────────
//  THRESHOLD (how bars are defined) | CADENCE (history) | LIVE BAR | STATE | LAST BAR
//  Column 0 is an invisible spacer that offsets the panel right from the left
//  edge; frame and grid are off so the spacer leaves no outline.
var table t = table.new(position.bottom_left, 11, 5, border_width = 0, frame_width = 0)
var bool tMerged = false

f_hdr(int g, string title) =>
    table.cell(t, 1 + g * 2, 0, title, text_size = size.tiny, text_halign = text.align_center,
         text_color = color.new(color.gray, 20),
         bgcolor = color.new(color.black, math.max(tblOpacity - 10, 0)))

f_kv(int g, int r, string k, string v, color vc) =>
    table.cell(t, 1 + g * 2, r + 1, k, text_size = size.small, text_halign = text.align_left,
         text_color = color.gray, bgcolor = color.new(color.black, tblOpacity))
    table.cell(t, 2 + g * 2, r + 1, v, text_size = size.small, text_halign = text.align_right,
         text_color = vc, bgcolor = color.new(color.black, tblOpacity))

// compact mode: label/value pairs side by side, two rows
f_kvc(int g, int r, string k, string v, color vc) =>
    table.cell(t, 1 + g * 2, r, k, text_size = size.small, text_halign = text.align_right,
         text_color = color.gray, bgcolor = color.new(color.black, tblOpacity))
    table.cell(t, 2 + g * 2, r, v, text_size = size.small, text_halign = text.align_left,
         text_color = vc, bgcolor = color.new(color.black, tblOpacity))

if showTbl and barstate.islast
    if not tMerged and not tblCompact
        table.merge_cells(t, 0, 0, 0, 4)
        table.merge_cells(t, 1, 0, 2, 0)
        table.merge_cells(t, 3, 0, 4, 0)
        table.merge_cells(t, 5, 0, 6, 0)
        table.merge_cells(t, 7, 0, 8, 0)
        table.merge_cells(t, 9, 0, 10, 0)
        tMerged := true
    table.cell(t, 0, 0, "", width = tblNudge, bgcolor = color.new(color.black, 100))
    if not active
        f_kv(0, 0, "Status", "WAITING", color.orange)
        f_kv(0, 1, "Reason", isFrozen ? "before anchor / calib warmup" :
             isRolling ? "calibration warming up" : "bad manual value", color.orange)
    else
        avgNat  = nDone > 0 ? nNative / nDone : 0.0
        avgMins = avgNat * timeframe.in_seconds(timeframe.period) / 60.0
        pctFull = math.min(accum / nz(barThr, threshold) * 100.0, 100.0)
        warm2   = nDone < len2 * 3
        medMins = array.size(durArr) > 0 ? array.median(durArr) : 0.0

        nowMs   = barstate.isrealtime ? timenow : time + timeframe.in_seconds(timeframe.period) * 1000
        elapsed = na(dStartT) ? 0 : math.max(0, math.round((nowMs - dStartT) / 1000.0))
        eMin    = math.floor(elapsed / 60)
        eSec    = elapsed % 60
        eStr    = str.tostring(eMin) + ":" + (eSec < 10 ? "0" : "") + str.tostring(eSec)

        elapsedMin = elapsed / 60.0
        expectMin  = medMins * pctFull / 100.0
        paceX = elapsedMin > 0.25 and expectMin > 0 ? expectMin / elapsedMin : na
        nFill = math.round(pctFull / 100.0 * 7.0)
        glyph = str.repeat("▓", nFill) + str.repeat("░", 7 - nFill)

        paceCol = na(paceX) ? color.gray : paceX >= 1.25 ? color.lime :
             paceX <= 0.8 ? color.orange : color.yellow

        if tblCompact
            f_kvc(0, 0, "Forming", eStr, color.yellow)
            f_kvc(1, 0, "Pace", na(paceX) ? "—" : str.tostring(paceX, "#.0") + "×", paceCol)
            f_kvc(2, 0, "Traded", "$" + str.tostring(accum / 1000000.0, "#.##") + "M", color.yellow)
            f_kvc(3, 0, "Fill", glyph + " " + str.tostring(pctFull, "#") + "%", color.yellow)
            f_kvc(0, 1, "Med min", medMins > 0 ? str.tostring(medMins, "#.#") : "—", color.white)
            f_kvc(1, 1, "ER", na(er) ? "—" :
                 str.tostring(er, "#.00") + (er <= erChop ? " chop" : " trend"),
                 na(er) ? color.gray : er <= erChop ? color.orange : color.lime)
            f_kvc(2, 1, "$/Bar", "$" + str.tostring(threshold / 1000000.0, "#.#") + "M",
                 useAuto ? color.aqua : color.white)
        else
            // group 0: THRESHOLD — how bars are defined
            f_hdr(0, "THRESHOLD")
            f_kv(0, 0, "$/Bar", "$" + str.tostring(threshold / 1000000.0, "#.#") + "M",
                 useAuto ? color.aqua : color.white)
            calTxt = (useMedian ? "med " : "avg/" + str.tostring(auctionAdj, "#.##") + " ") +
                 str.tostring(lookbackDays) + "d / " + str.tostring(targetMins, "#.#") + "m"
            f_kv(0, 1, "Source", isFrozen ? calTxt :
                 isRolling ? "roll " + calTxt : "manual", color.white)
            f_kv(0, 2, "Derived", isFrozen and not na(frozenTime) ?
                 str.format_time(frozenTime, "yyyy-MM-dd", syminfo.timezone) :
                 isRolling ? "live" : "—", color.white)
            f_kv(0, 3, "Recent", na(recentThr) ? "—" :
                 "$" + str.tostring(recentThr / 1000000.0, "#.#") + "M",
                 not isRolling and math.abs(nz(recentThr) - threshold) / threshold > 0.15 ?
                 color.orange : color.gray)

            // group 1: CADENCE — what history has produced
            f_hdr(1, "CADENCE")
            f_kv(1, 0, "Bars", str.tostring(nDone), color.white)
            f_kv(1, 1, "Avg min", str.tostring(avgMins, "#.#"), color.white)
            f_kv(1, 2, "Med min", medMins > 0 ? str.tostring(medMins, "#.#") : "—", color.white)
            f_kv(1, 3, "Bars/day", avgMins > 0 ?
                 str.tostring(sessionMins / avgMins, "#.#") : "—", color.white)

            // group 2: LIVE BAR — the one forming now
            f_hdr(2, "LIVE BAR")
            f_kv(2, 0, "Forming", eStr, color.yellow)
            f_kv(2, 1, "Pace", na(paceX) ? "—" : str.tostring(paceX, "#.0") + "×", paceCol)
            f_kv(2, 2, "Traded", "$" + str.tostring(accum / 1000000.0, "#.##") + "M", color.yellow)
            f_kv(2, 3, "Fill", glyph + " " + str.tostring(pctFull, "#") + "%", color.yellow)

            // group 3: STATE — regime and health
            f_hdr(3, "STATE")
            f_kv(3, 0, "ER (" + str.tostring(erLen) + ")", na(er) ? "—" :
                 str.tostring(er, "#.00") + (er <= erChop ? " chop" : " trend"),
                 na(er) ? color.gray : er <= erChop ? color.orange : color.lime)
            f_kv(3, 1, avgMins < 2.0 and nDone > 20 ? "⚠ Thresh" : "Gray " + str.tostring(len2),
                 avgMins < 2.0 and nDone > 20 ? "TOO SMALL" :
                 warm2 ? "WARMING UP" : "ready",
                 avgMins < 2.0 and nDone > 20 ? color.red : warm2 ? color.orange : color.lime)
            f_kv(3, 2, "Drawn", nDone > 500 ?
                 "500 of " + str.tostring(nDone) : str.tostring(nDone) + " of " + str.tostring(nDone),
                 nDone > 500 ? color.orange : color.white)

            // group 4: LAST BAR — the most recently completed dollar bar
            f_hdr(4, "LAST BAR")
            f_kv(4, 0, "O / C", na(lO) ? "—" :
                 str.tostring(lO, format.mintick) + " / " + str.tostring(lC, format.mintick), color.white)
            f_kv(4, 1, "H / L", na(lH) ? "—" :
                 str.tostring(lH, format.mintick) + " / " + str.tostring(lL, format.mintick), color.white)
            f_kv(4, 2, "Took", na(lDur) ? "—" :
                 (lDur >= 10 ? str.tostring(math.round(lDur)) + "m" : str.tostring(lDur, "#.#") + "m"),
                 color.white)
            f_kv(4, 3, "Closed", na(lCloseT) ? "—" :
                 str.format_time(lCloseT, "HH:mm", syminfo.timezone), color.white)
````
