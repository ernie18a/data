# Apex Edge - Trend Breakout V1.1

- url: https://www.tradingview.com/script/jKA0UqKA-Apex-Edge-Trend-Breakout-V1-1/
- type: indicator
- pine_id: PUB;57f6f4b7bc4c4426b741e8d114da7d73
- version: 1.0

## Description

Apex Edge — Trend Breakout
A with-trend channel breakout system with a 30-symbol radar and a dual-window, cost adjusted backtest.

Indicator Guide · Apex Edge
This guide explains exactly what the indicator does, how every number is calculated, why the backtest is built the way it is, and how to trade it. Nothing here is hidden behind a black box — the whole point of the tool is that you can see the workings and judge the edge for yourself.

1. What it is
Apex Edge — Trend Breakout is a single overlay indicator that does four jobs at once:
• Signals trades when price breaks the recent range in the direction of the dominant trend.
• Manages the trade with a chandelier trailing stop, so winners are allowed to run and losers are cut quickly.
• Scans a 30-symbol watchlist (the Radar), ranking what is trending and flagging what is about to break.
• Tests the rules on the chart symbol across two separate date windows and reports the result as average R and sample size — then auto-grades it Red, Amber or Green.
The thesis. Most price action is noise. Occasionally a market trends, and when it does, a break of the recent range tends to continue. The edge of such a system does not come from being right often — it comes from a fat right tail: many small losses when breaks fail, paid for by the occasional large runner that the trailing stop rides for multiples of the initial risk. The tool is built end-to-end to find that behaviour and to stop you fooling yourself about whether it is really there.

2. What appears on your chart
• Green and red rails — the upper and lower edges of the breakout channel. A close beyond a
rail is a potential trigger.
• Up / down triangles — confirmed entries (a close-break that agrees with the trend).
• Orange line — the live trailing stop for the most recent signal. This is where your protective
order goes.
• HUD (top-right by default) — the chart symbol's trend, distance to its rail, current setup state, last signal and a running long/short signal count.
• Radar (top-left) — the 30-symbol scanner with score, direction, state and a Red/Amber/Green
“Go” column.
• Backtest panel (bottom-right) — two date windows side by side, each showing average R and
trade count per side, plus an automatic verdict.

3. The entry signal — how it is calculated

3.1 The breakout channel
The rails are the highest high and lowest low of the last N bars (default 20), measured up to the
previous bar so they never repaint:

upBreak = highest(high, 20) of the prior bar
dnBreak = lowest(low, 20) of the prior bar

A long trigger is a close crossing above the upper rail; a short trigger is a close crossing below the lower rail. Because the test is on the close, an intrabar wick through a rail that closes back inside does not trigger — only a genuine close beyond the range counts.

3.2 The dominant-trend filter
A breakout alone is not enough; it must agree with the trend. Trend is defined by a long EMA (default 200) and that EMA's slope, so a flat market counts as no trend:

Uptrend = close > EMA(200) AND EMA(200) rising over the last 5 bars
Downtrend = close < EMA(200) AND EMA(200) falling over the last 5 bars

Requiring both price position and EMA slope filters out the chop that ruins most breakout systems: if the EMA is flat, neither condition is true and no trades are taken.

3.3 Optional higher-timeframe agreement
You can additionally require the higher timeframe (default daily) to agree, using its last closed bar's EMA so it cannot repaint. With it on, a 4H long also needs the daily to be pointing up. Off by default.

3.4 The final rule

Long = close-break of the upper rail AND dominant uptrend
Short = close-break of the lower rail AND dominant downtrend

With “with-trend only” enabled (the default), counter-trend and flat-market breaks are blocked entirely.
The triangle only prints when both halves line up.

4. The exit — chandelier trailing stop, and what “R” means
Risk is defined the moment you enter. The initial stop sits a multiple of Average True Range away from entry (default 1.5 × ATR(14)). That distance — entry to initial stop — is one R. 
Every outcome the tool reports is measured in multiples of that initial risk.
Once in the trade, the stop trails using a chandelier: it hangs a multiple of ATR (default 3 × ATR)
below the highest high reached since entry (mirrored for shorts). It only ever moves in your favour - it ratchets, never loosens. You exit when price touches the line.

• A loss is roughly −1R: the break fails and price falls back to the initial stop.
• A win is whatever the trail captures — often small, occasionally very large when a real trend
develops. There is no fixed profit target; capping the winners would throw away the exact tail
the system exists to harvest.

Note Live, you place a resting stop on the orange line and step it along as the line moves. The
backtest exits on the same intrabar touch, so what you test is what you trade.

5. The Market Radar — how the scan is built
The Radar pulls 30 symbols on the scan timeframe (default 4H) and ranks them so you watch the right markets. Four numbers drive it.

5.1 Trend-strength score
The score blends how cleanly a market is moving with how strongly:
• Efficiency Ratio (ER) — net distance travelled divided by the total path taken, over a lookback
(default 20). A straight move scores high; a market that thrashes back and forth to end up in the same place scores low.

ER = |close − close[20]| / sum of |bar-to-bar moves over 20| (as a %)

• ADX — the standard directional-strength index (default 14).
The two are scaled and blended 55% ER / 45% ADX, calibrated so a market in a genuine trend reads roughly 60–70. Only symbols above the score threshold (default 50) are shown, strongest first.

5.2 Direction, NEAR and the Go grade
• Direction comes from the same dominant-EMA logic as the chart (up, down, or flat).
• NEAR flags a symbol that is trending and within a set distance of its breakout rail in the trend
direction (default 0.5 × ATR) — i.e. about to trigger.
• Go (Red / Amber / Green) is read from your own curated lists. You tell the indicator which
symbols you trade long and short at Green (confirmed) and Amber (testing) confidence; the Go
column then lights up only for those symbols in that direction.

Note The Radar does not grade edges for you — you populate the Green/Amber lists from your own backtest sweep (Section 6). The Go column simply surfaces your decisions on the live scan.

6. The backtest engine and the Auto verdict
This is where you decide whether a symbol earns a place on your lists. For the chart symbol, the engine replays every historical signal forward (up to 60 bars), simulates the exact chandelier trail with intrabar touch exits, deducts your cost per trade, and records each result in R.
It does this across two independent date windows and reports, for each window and each side
(long / short / all):

• Avg R — the average result per trade, net of cost. This is the system's expectancy.
• N — the number of trades in that window. This tells you whether to believe the Avg R.

The Auto column then turns that into a verdict using two thresholds (defaults shown), applied to both windows:

Verdict Condition
GREEN Avg R ≥ 0.10 AND N ≥ 50 in BOTH windows — a real, repeatable edge
AMBER Qualifies in one window, or only marginally — promising, not proven
no Fails the bar — no demonstrated edge this way

A Green therefore is not a single good run; it is an edge that survived two separate market periods with a large enough sample in each. That is the bar a symbol must clear before it goes on your Green list.

Note Cost is entered in price units and applies to the chart symbol, so set it to that instrument's
realistic round-trip spread before trusting a marginal (Amber) result. A couple of pips is what flips a thin edge from positive to negative — which is exactly the truth you want before risking money.

7. Why those default backtest dates?
The two windows default to 2019–2021 and 2022–present, and the split is deliberate. These are not two halves of one stretch — they are two genuinely different market regimes:

• 2019–2021 spans the late-cycle calm, the COVID crash and the violent recovery — a high volatility, strong-trend era.
• 2022–present is the rate-hiking regime: broad USD strength, a real equity bear in 2022, and a
different volatility character.

A set of rules that prints a profit in one regime might simply be tuned, by luck or by hand, to that regime. The only honest test is whether the same untouched rules also work in a different one.

Requiring an edge to clear the bar in both windows is the out-of-sample check built directly into the panel. The dates are adjustable — what matters is that the two windows cover different conditions, not the exact years.

8. Why we judge by R and N, not win rate
Win rate is the most quoted and least useful statistic in trading. On its own it tells you almost nothing, and for a system like this it actively misleads.

8.1 Win rate hides the size of wins and losses
Two systems can have wildly different win rates and the opposite profitability. Expectancy — average R per trade — is what actually ties to your account:

System                              Win rate        Expectancy            Reality
“High win rate” (avg win      90%                +0.5R             Loses Money
+0.5R, avg loss −5R)

Trend breakout (avg win       40%                +0.60R           Strong edge
+3R, avg loss −1R)

The 90%-winner loses on the rare 5R disaster; the 40%-winner thrives because its winners dwarf its losers. Judge either by win rate and you draw the wrong conclusion. Expectancy = (win% × avg win) − (loss% × avg loss), expressed in R, is the number that matters.

8.2 This system is meant to be a low win-rate system
A trend-breakout-with-trail design is designed to win less than half the time. Most breakouts fail and cost ~1R; a minority become trends and the trail rides them for many R. The profit lives entirely in those few big winners — the fat right tail. Win rate cannot see that tail; only average R can.

Optimising for win rate would push you to cap winners and widen stops, destroying the very edge the tool is built to capture.

8.3 N is what makes the average believable
An average R is only as trustworthy as the number of trades behind it. A +0.8R average on 8 trades is a coin landing heads a few times in a row — it tells you nothing. The same average on 120 trades is a genuine signal. That is why the Auto grade refuses to certify anything below N ≥ 50 per window, no matter how attractive the Avg R looks. Small samples are where traders fool themselves most, so the tool simply will not show Green there.

8.4 How to read an Avg R figure
Avg R (net of cost) Read it as
≤ 0 (negative) A losing side — shown red and correctly left off your lists
+0.05 to +0.15 Marginal — cost and slippage can erase it
+0.15 to +0.35 A solid, tradeable edge
+0.35 to +0.80 Strong — and normal for this let-run design when a market trends cleanly
+0.80 and up Exceptional — sanity-check it before you believe it (see below)

Two cautions. First, R is signed. A side can be negative, meaning that direction lost money over the test — it is shown in red, and the Auto verdict only turns green for positive R that clears the bar in both windows. A red number is not a high score you should chase; it is a losing side the tool is keeping you out of.

Second, because this design lets winners run, a healthy average is usually carried by a minority of large trades rather than spread evenly across all of them. That is expected behaviour for trend following, not a flaw — but it means a very high figure deserves a look at the trade distribution, and a check for look-ahead, before you treat it as durable. High positive R here is the system working; it is only suspect when it is extreme or rests on a handful of trades.

9. How to trade it
The workflow separates the slow, careful job (deciding what to trade) from the fast one (executing when it triggers).

1. Weekly — curate. Flick through your watchlist. On each symbol read the Auto panel and note
the verdict per side. Add Green symbols to the matching Green list (long or short) in settings,
and Amber symbols to the Amber lists. Skip the reds.

2. Set once — the blanket alert. On a 4H chart create the “Watchlist near breakout” alert, set to Once Per Bar Close. It pings only for your Green/Amber symbols when one is trending and
nearing its rail.

3. On the ping — find the trade. Open the Radar. Confirm the symbol shows Green/Amber Go +
NEAR + the right direction.

4. Arm the entry. On that symbol's chart set the “Breakout Long/Short” alert, also Once Per Bar
Close, so only a close beyond the rail can fire it (no wicks).

5. Enter. When the triangle prints, take the trade and place your stop on the orange trailing line.
6. Manage. Step the stop along with the line as it moves your way — never against you. Exit on the touch. No fixed target; let the trail decide.

10. Trading rules and risk discipline
• Trade Green in the validated direction. Amber is watch-and-small-size. Red is no trade.
• A break against the trend is not your trade. Skip it, however tempting.
• Judge over a batch of trades, never one. A single loss says nothing about a positive expectancy system; variance is the cost of admission.
• One settings set for all symbols. Never tune the inputs per symbol to flatter the past — that is
curve-fitting. If you change a strategy setting, re-test both windows before trusting it again.
• Size correlated instruments as one position. A basket of yen crosses, or a basket of equity
indices, is one bet wearing several names. Three 1% longs that all rise and fall together is a 3%
bet on one theme, not three diversified trades.

11. Settings reference
Setting Defaults and What they mean:

Breakout channel 20 Bars - used for the high/low rails
Near-break heads-up 0.5 ATR - How close to the rail counts as NEAR
Dominant EMA 200 - The trend reference line
EMA slope lookback 5 Bars - used to judge the EMA's slope
With-trend only On - Blocks counter-trend and flat-market breaks
Higher timeframe Off / 1D - Optionally require the daily to agree
Initial stop 1.5 ATR - Defines one R (entry to stop)
Chandelier trail 3.0 ATR - Trailing distance below the running extreme
Trade window 60 bars - How far the backtest follows each signal
Cost per trade 0 - Round-trip cost in price units (set per instrument)
Test windows A / B 2019–21 / 22–now - The two regimes the Auto grade checks
Qualify Avg R / N 0.10 / 50 - Thresholds for a Green verdict, per window
Scan timeframe 4H - Timeframe the Radar evaluates
Score threshold 50 - Minimum trend score to appear on the Radar

12. Non-repainting, and honest limitations
Non-repainting by design. Signals use closed-bar prices and the prior-bar channel, the higher timeframe pull uses the last closed bar, and the backtest only ever replays bars that were already in the past relative to each signal. What you see on history is what you would have seen live.

What a backtest can and cannot tell you. The replay is a simulation. It assumes fills at the touched price and a fixed cost; live trading adds variable spread, slippage, gaps and partial fills. Treat the Avg R as an estimate of edge and direction, not a promise of returns. Forward-test before you scale.

• The Green/Amber lists are your inputs — the tool surfaces your decisions, it does not validate
them for you.
• Correlated symbols inflate the apparent number of edges; the count is not the same as
diversification.
• A strong directional drift in an asset class (equities up, for example) can make a one-sided
system look better than the rule itself is.

This indicator is a decision-support and research tool. It is not financial advice and does not place trades.
Markets carry risk; past performance does not guarantee future results. You are responsible for your own decisions and risk.

Apex Edge - Trend Breakout - Radar finds the trend - Auto/Go says if it pays - Arrow times entry - Orange line manages - exit

## Source Code

````pine
//@version=6
// =============================================================================
//  APEX EDGE — TREND BREAKOUT  (indicator)
//  -----------------------------------------------------------------------------
//  Execution companion to the Apex Edge Market Radar. Trades a close-break of the
//  recent range, but ONLY in the direction of the dominant trend.
//
//  Signal: close crosses the N-bar high (long) / low (short) AND the dominant
//  trend agrees (price vs a long EMA + that EMA's slope, optional HTF confirm).
//  No squeeze / volatility gate — testing showed it removed the edge rather than
//  adding to it, so the system is a clean with-trend channel breakout.
//
//  Shared DNA with the Radar (so the two tools agree):
//    * Score  = Efficiency Ratio + ADX blend (how cleanly / strongly trending)
//    * Dir    = dominant EMA direction
//    * NEAR   = trending AND within nearAtr ATRs of the breakout rail
//
//  The edge of a breakout system lives in the FAT RIGHT TAIL (small frequent
//  losses, occasional big runners), so it rides with a CHANDELIER TRAILING exit
//  and the TEST panel reports average R, not just win rate.
//
//  Non-repainting (closed-bar O/H/L/C, prior-bar channel, no offsets). The TEST
//  replays only bars already in the past relative to each signal.
// =============================================================================

indicator("Apex Edge — Trend Breakout", overlay = true)

// ----- Palette (matches the Market Radar) -----
C_GOLD = #FFD700
C_UP   = #089981
C_DOWN = #f23645

// ----- Inputs: Breakout -----
g_brk = "Breakout"
breakoutLen = input.int(20,   "Breakout channel (bars)",  group = g_brk)
nearAtr     = input.float(0.5, "Near-break heads-up (x ATR)", step = 0.1, group = g_brk)

// ----- Inputs: Trend filter (dominant) -----
g_tr = "Trend Filter (dominant)"
useTrend      = input.bool(true,  "Trend filter on",                        group = g_tr)
withTrendOnly = input.bool(true,  "With-trend only (block counter + flat)", group = g_tr)
trendLen      = input.int(200,    "Dominant EMA length",                    group = g_tr)
trendSlope    = input.int(5,      "EMA slope lookback",                     group = g_tr)
useHTF        = input.bool(false, "Also require higher timeframe",          group = g_tr)
htfTf         = input.timeframe("1D", "Higher timeframe",                   group = g_tr)

// ----- Inputs: Risk / Exit (drives the outcome test) -----
g_rk = "Risk / Exit (test)"
stopATR   = input.float(1.5, "Initial stop (x ATR)",     step = 0.1, group = g_rk)
chandMult = input.float(3.0, "Chandelier trail (x ATR)", step = 0.1, group = g_rk)
evalBars  = input.int(60, "Trade window (bars)", minval = 5, group = g_rk)
costPrice = input.float(0.0, "Cost per trade (price, round-trip)", step = 0.00001, minval = 0, group = g_rk)

// ----- Inputs: Test Date Range (for out-of-sample checks) -----
g_dt = "Test Date Range"
aStart = input.time(timestamp("01 Jan 2019 00:00 +0000"), "Window A start", group = g_dt)
aEnd   = input.time(timestamp("31 Dec 2021 23:59 +0000"), "Window A end",   group = g_dt)
bStart = input.time(timestamp("01 Jan 2022 00:00 +0000"), "Window B start", group = g_dt)
bEnd   = input.time(timestamp("01 Jan 2037 00:00 +0000"), "Window B end",   group = g_dt)
aLabel = input.string("19-21",  "Window A label", group = g_dt)
bLabel = input.string("22-now", "Window B label", group = g_dt)
tstPos = input.string("Bottom Right", "Backtest panel position", options = ["Top Right","Top Left","Right Middle","Left Middle","Bottom Right","Bottom Left"], group = g_dt)
rMin   = input.float(0.10, "Qualify: min avgR per window", step = 0.01, group = g_dt)
nMin   = input.int(50,     "Qualify: min trades per window", minval = 1, group = g_dt)

// ----- Inputs: Display -----
g_d = "Display"
showChan = input.bool(true, "Show breakout channel", group = g_d)
showHUD  = input.bool(true, "Show HUD",              group = g_d)
hudPos   = input.string("Top Right", "HUD position", options = ["Top Right","Top Left","Right Middle","Left Middle","Bottom Right","Bottom Left"], group = g_d)

// ----- Inputs: Scanner (trend-strength radar across a watchlist) -----
g_sc = "Scanner (watchlist)"
scanEnable  = input.bool(true,        "Scanner on",                         group = g_sc)
scanTf      = input.timeframe("240",  "Scanner timeframe",                  group = g_sc)
erLen       = input.int(20,           "Efficiency Ratio length",            group = g_sc)
diLen       = input.int(14,           "DI length",                          group = g_sc)
adxLen      = input.int(14,           "ADX smoothing",                      group = g_sc)
watchThresh = input.float(50,         "Trending score threshold",           group = g_sc)
radarRows   = input.int(8,            "Max rows shown", minval = 1, maxval = 30, group = g_sc)
greenLong   = input.string("AUDJPY", "GREEN long — confirmed edge",  group = g_sc)
greenShort  = input.string("AUDCHF", "GREEN short — confirmed edge", group = g_sc)
amberLong   = input.string("NZDJPY", "AMBER long — testing",         group = g_sc)
amberShort  = input.string("",       "AMBER short — testing",        group = g_sc)
scanPos     = input.string("Top Left","Scanner position", options = ["Top Right","Top Left","Right Middle","Left Middle","Bottom Right","Bottom Left"], group = g_sc)
// Set each to YOUR broker's exact ticker in settings.
sym1  = input.symbol("EURUSD", "Asset 1",  group = g_sc)
sym2  = input.symbol("GBPUSD", "Asset 2",  group = g_sc)
sym3  = input.symbol("AUDUSD", "Asset 3",  group = g_sc)
sym4  = input.symbol("NZDUSD", "Asset 4",  group = g_sc)
sym5  = input.symbol("USDJPY", "Asset 5",  group = g_sc)
sym6  = input.symbol("USDCHF", "Asset 6",  group = g_sc)
sym7  = input.symbol("USDCAD", "Asset 7",  group = g_sc)
sym8  = input.symbol("EURGBP", "Asset 8",  group = g_sc)
sym9  = input.symbol("EURJPY", "Asset 9",  group = g_sc)
sym10 = input.symbol("EURCHF", "Asset 10", group = g_sc)
sym11 = input.symbol("EURAUD", "Asset 11", group = g_sc)
sym12 = input.symbol("EURCAD", "Asset 12", group = g_sc)
sym13 = input.symbol("EURNZD", "Asset 13", group = g_sc)
sym14 = input.symbol("GBPJPY", "Asset 14", group = g_sc)
sym15 = input.symbol("GBPCHF", "Asset 15", group = g_sc)
sym16 = input.symbol("GBPAUD", "Asset 16", group = g_sc)
sym17 = input.symbol("GBPCAD", "Asset 17", group = g_sc)
sym18 = input.symbol("GBPNZD", "Asset 18", group = g_sc)
sym19 = input.symbol("AUDJPY", "Asset 19", group = g_sc)
sym20 = input.symbol("AUDCHF", "Asset 20", group = g_sc)
sym21 = input.symbol("AUDCAD", "Asset 21", group = g_sc)
sym22 = input.symbol("AUDNZD", "Asset 22", group = g_sc)
sym23 = input.symbol("NZDJPY", "Asset 23", group = g_sc)
sym24 = input.symbol("NZDCHF", "Asset 24", group = g_sc)
sym25 = input.symbol("NZDCAD", "Asset 25", group = g_sc)
sym26 = input.symbol("CADJPY", "Asset 26", group = g_sc)
sym27 = input.symbol("CADCHF", "Asset 27", group = g_sc)
sym28 = input.symbol("CHFJPY", "Asset 28", group = g_sc)
sym29 = input.symbol("XAUUSD", "Asset 29", group = g_sc)
sym30 = input.symbol("XAGUSD", "Asset 30", group = g_sc)

// ----- Core calcs -----
atr = ta.atr(14)

// Breakout channel (prior-bar extreme -> non-repainting)
upBreak = ta.highest(high, breakoutLen)[1]
dnBreak = ta.lowest(low,  breakoutLen)[1]
brkUp = ta.crossover(close, upBreak)
brkDn = ta.crossunder(close, dnBreak)

// Dominant trend: price vs a long EMA AND that EMA's slope (flat = neither)
te = ta.ema(close, trendLen)
ctUp = close > te and te > te[trendSlope]
ctDn = close < te and te < te[trendSlope]

// Optional higher-timeframe agreement (non-repainting: last CLOSED HTF bar)
htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, trendLen)[1], lookahead = barmerge.lookahead_off)
htfUp = not useHTF or (not na(htfEma) and close > htfEma)
htfDn = not useHTF or (not na(htfEma) and close < htfEma)

domUp = ctUp and htfUp
domDn = ctDn and htfDn

// Gating: with-trend-only blocks counter-trend AND flat regimes
allowLong  = not useTrend ? true : withTrendOnly ? domUp : not domDn
allowShort = not useTrend ? true : withTrendOnly ? domDn : not domUp

// Entry = a close-break of the channel IN the dominant trend direction
longSig  = brkUp and allowLong
shortSig = brkDn and allowShort

// Distance to the trend-direction rail, in ATRs (for the "near break" heads-up)
distUp = (upBreak - close) / math.max(atr, 1e-9)
distDn = (close - dnBreak) / math.max(atr, 1e-9)
distBreak = domUp ? distUp : domDn ? distDn : na
nearBreak = not na(distBreak) and distBreak <= nearAtr

sinceLong  = ta.barssince(longSig)
sinceShort = ta.barssince(shortSig)
longCount  = ta.cum(longSig  ? 1 : 0)
shortCount = ta.cum(shortSig ? 1 : 0)

// ----- Live trailing stop (same logic the backtest exits on, run forward) -----
// Initial stop = entry +/- stopATR*ATR, then ratchets at chandMult*ATR off the
// best price reached. Tracks the most recent signal; clears when stopped out.
showStop = input.bool(true, "Show trailing stop line", group = g_rk)
var bool  posLong  = false
var bool  posShort = false
var float liveStop = na
var float liveExt  = na
if longSig and not posLong and not posShort
    posLong  := true
    liveExt  := high
    liveStop := close - stopATR * atr
else if shortSig and not posShort and not posLong
    posShort := true
    liveExt  := low
    liveStop := close + stopATR * atr
else if posLong
    if low <= liveStop
        posLong  := false
        liveStop := na
    else
        liveExt  := math.max(liveExt, high)
        liveStop := math.max(liveStop, liveExt - chandMult * atr)
else if posShort
    if high >= liveStop
        posShort := false
        liveStop := na
    else
        liveExt  := math.min(liveExt, low)
        liveStop := math.min(liveStop, liveExt + chandMult * atr)

// ----- Outcome tracker: CHANDELIER TRAILING exit, no look-ahead -----
evalTrail(_isLong) =>
    entry = close[evalBars]
    a0    = atr[evalBars]
    risk  = stopATR * a0
    stopLine = _isLong ? entry - risk : entry + risk
    ext = _isLong ? high[evalBars] : low[evalBars]
    exited = false
    exitPrice = close[0]
    for i = evalBars - 1 to 0
        if not exited
            hit = _isLong ? low[i] <= stopLine : high[i] >= stopLine
            if hit
                exitPrice := stopLine
                exited := true
            else
                ext := _isLong ? math.max(ext, high[i]) : math.min(ext, low[i])
                trail = _isLong ? ext - chandMult * atr[i] : ext + chandMult * atr[i]
                stopLine := _isLong ? math.max(stopLine, trail) : math.min(stopLine, trail)
    rawR = risk > 0 ? (_isLong ? (exitPrice - entry) / risk : (entry - exitPrice) / risk) : na
    na(rawR) ? na : rawR - (risk > 0 ? costPrice / risk : 0.0)

var int   nLA = 0
var float sRLA = 0.0
var int   nSA = 0
var float sRSA = 0.0
var int   nLB = 0
var float sRLB = 0.0
var int   nSB = 0
var float sRSB = 0.0
sigTime = time[evalBars]
inA = sigTime >= aStart and sigTime <= aEnd
inB = sigTime >= bStart and sigTime <= bEnd
if longSig[evalBars]
    r = evalTrail(true)
    if not na(r)
        if inA
            nLA  := nLA + 1
            sRLA := sRLA + r
        if inB
            nLB  := nLB + 1
            sRLB := sRLB + r
if shortSig[evalBars]
    r = evalTrail(false)
    if not na(r)
        if inA
            nSA  := nSA + 1
            sRSA := sRSA + r
        if inB
            nSB  := nSB + 1
            sRSB := sRSB + r

fmtAB(_r, _n) =>
    na(_r) or _n == 0 ? "–" : (_r >= 0 ? "+" : "") + str.tostring(_r, "0.00") + "  n" + str.tostring(_n)
colR(_r) => na(_r) ? color.gray : _r > 0 ? C_UP : C_DOWN

// Auto-verdict: does a side qualify on the A/B windows? 2=green (both windows
// pass), 1=amber (one window passes), 0=no.
autoGrade(_na, _nb, _ra, _rb) =>
    (_na >= nMin and _nb >= nMin and _ra >= rMin and _rb >= rMin) ? 2 : ((_na >= nMin and _ra >= rMin) or (_nb >= nMin and _rb >= rMin)) ? 1 : 0
vTxt(_g) => _g == 2 ? "GREEN" : _g == 1 ? "AMBER" : "no"
vBg(_g)  => _g == 2 ? color.new(C_UP, 20) : _g == 1 ? color.new(#FFB300, 15) : color.new(C_DOWN, 25)
vFg(_g)  => _g == 1 ? color.black : color.white

// ----- Scanner: per-symbol trend-strength, pulled across the watchlist -----
// Score blends Efficiency Ratio (how cleanly it's trending) with ADX (how
// strongly). Direction from the dominant EMA. f_comp flags NEAR-breakout now.
// Each metric is its own scalar function; request.security pulls them as an
// inline tuple — the most reliable cross-symbol pattern in Pine.
f_er() =>
    _chg = math.abs(close - close[erLen])
    _sum = math.sum(math.abs(close - close[1]), erLen)
    100.0 * (_sum != 0 ? _chg / _sum : 0.0)      // 0-100

f_adx() =>
    [_p, _m, _a] = ta.dmi(diLen, adxLen)
    _a

f_score() =>
    _erS  = math.min(100.0, f_er() * 2.0)                          // ER ~30 -> 60, ~50 -> 100
    _adxS = math.min(100.0, math.max(0.0, (f_adx() - 10.0) * 2.5)) // ADX 30 -> 50, 50 -> 100
    _erS * 0.55 + _adxS * 0.45

f_dir() =>
    _e = ta.ema(close, trendLen)
    close > _e and _e > _e[trendSlope] ? 1 : close < _e and _e < _e[trendSlope] ? -1 : 0

// f_comp now flags NEAR-BREAKOUT: trending and within nearAtr of the rail.
f_comp() =>
    _up  = ta.highest(high, breakoutLen)[1]
    _dn  = ta.lowest(low,  breakoutLen)[1]
    _e   = ta.ema(close, trendLen)
    _dir = close > _e and _e > _e[trendSlope] ? 1 : close < _e and _e < _e[trendSlope] ? -1 : 0
    _a   = ta.atr(14)
    _d   = _dir == 1 ? (_up - close) / math.max(_a, 1e-9) : _dir == -1 ? (close - _dn) / math.max(_a, 1e-9) : na
    (not na(_d) and _d <= nearAtr) ? 1 : 0

[sc1,dr1,cp1,er1]    = request.security(sym1,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc2,dr2,cp2,er2]    = request.security(sym2,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc3,dr3,cp3,er3]    = request.security(sym3,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc4,dr4,cp4,er4]    = request.security(sym4,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc5,dr5,cp5,er5]    = request.security(sym5,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc6,dr6,cp6,er6]    = request.security(sym6,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc7,dr7,cp7,er7]    = request.security(sym7,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc8,dr8,cp8,er8]    = request.security(sym8,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc9,dr9,cp9,er9]    = request.security(sym9,  scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc10,dr10,cp10,er10] = request.security(sym10, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc11,dr11,cp11,er11] = request.security(sym11, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc12,dr12,cp12,er12] = request.security(sym12, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc13,dr13,cp13,er13] = request.security(sym13, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc14,dr14,cp14,er14] = request.security(sym14, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc15,dr15,cp15,er15] = request.security(sym15, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc16,dr16,cp16,er16] = request.security(sym16, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc17,dr17,cp17,er17] = request.security(sym17, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc18,dr18,cp18,er18] = request.security(sym18, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc19,dr19,cp19,er19] = request.security(sym19, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc20,dr20,cp20,er20] = request.security(sym20, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc21,dr21,cp21,er21] = request.security(sym21, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc22,dr22,cp22,er22] = request.security(sym22, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc23,dr23,cp23,er23] = request.security(sym23, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc24,dr24,cp24,er24] = request.security(sym24, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc25,dr25,cp25,er25] = request.security(sym25, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc26,dr26,cp26,er26] = request.security(sym26, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc27,dr27,cp27,er27] = request.security(sym27, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc28,dr28,cp28,er28] = request.security(sym28, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc29,dr29,cp29,er29] = request.security(sym29, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)
[sc30,dr30,cp30,er30] = request.security(sym30, scanTf, [f_score(), f_dir(), f_comp(), f_er()], lookahead = barmerge.lookahead_off)

// (Watchlist near-breakout alert is defined below, after gradeOf.)

// ----- Plots -----
plot(showChan ? upBreak : na, "Up break", color.new(C_UP,   0), style = plot.style_stepline)
plot(showChan ? dnBreak : na, "Dn break", color.new(C_DOWN, 0), style = plot.style_stepline)

plotshape(longSig,  "Long break",  shape.triangleup,   location.belowbar, C_UP,   size = size.small)
plotshape(shortSig, "Short break", shape.triangledown, location.abovebar, C_DOWN, size = size.small)
plot(showStop and (posLong or posShort) ? liveStop : na, "Trailing stop", color = #ff9800, linewidth = 2, style = plot.style_linebr)

alertcondition(longSig,  "Breakout Long",  "With-trend channel breakout — long")
alertcondition(shortSig, "Breakout Short", "With-trend channel breakout — short")

// ----- HUD -----
posMap(_s) =>
    _s == "Top Right" ? position.top_right : _s == "Top Left" ? position.top_left : _s == "Bottom Right" ? position.bottom_right : _s == "Right Middle" ? position.middle_right : _s == "Left Middle" ? position.middle_left : position.bottom_left

var table hud = na
if barstate.isfirst and showHUD
    hud := table.new(posMap(hudPos), 2, 7, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if showHUD and barstate.islast
    bg   = color.new(color.black, 12)
    tx   = color.white
    ast  = color.new(color.teal, 20)
    hdr  = color.new(color.blue, 35)
    hdr2 = color.new(color.purple, 35)

    trendTxt = not useTrend ? "off" : (domUp ? "UP" : domDn ? "DOWN" : "FLAT") + (useHTF ? " +HTF" : "")
    trendCol = not useTrend ? color.gray : domUp ? C_UP : domDn ? C_DOWN : color.gray
    distTxt  = na(distBreak) ? "—" : str.tostring(distBreak, "#.0") + " ATR"
    setupTxt = (longSig or shortSig) ? "FIRING" : nearBreak ? "near break" : (domUp or domDn) ? "watching" : "-"
    setupCol = (longSig or shortSig) ? C_UP : nearBreak ? C_GOLD : tx

    hasL = not na(sinceLong)
    hasS = not na(sinceShort)
    lLast = hasL and (not hasS or sinceLong <= sinceShort)
    sLast = hasS and (not hasL or sinceShort <  sinceLong)
    lastTxt = lLast ? "LONG, " + str.tostring(sinceLong) + " bars ago" : sLast ? "SHORT, " + str.tostring(sinceShort) + " bars ago" : "none yet"
    lastCol = lLast ? C_UP : sLast ? C_DOWN : color.gray

    table.cell(hud, 0, 0, syminfo.prefix + ":" + syminfo.ticker, text_color = color.white, bgcolor = ast, text_size = size.normal)
    table.cell(hud, 1, 0, timeframe.period, text_color = color.white, bgcolor = ast, text_size = size.normal)
    table.cell(hud, 0, 1, "APEX TREND", text_color = C_GOLD, bgcolor = hdr, text_size = size.small)
    table.cell(hud, 1, 1, "Breakout",   text_color = C_GOLD, bgcolor = hdr, text_size = size.small)

    table.cell(hud, 0, 2, "Trend", text_color = tx, bgcolor = bg, text_size = size.small)
    table.cell(hud, 1, 2, trendTxt, text_color = trendCol, bgcolor = bg, text_size = size.small)
    table.cell(hud, 0, 3, "To break", text_color = tx, bgcolor = bg, text_size = size.small)
    table.cell(hud, 1, 3, distTxt, text_color = tx, bgcolor = bg, text_size = size.small)
    table.cell(hud, 0, 4, "Setup", text_color = tx, bgcolor = bg, text_size = size.small)
    table.cell(hud, 1, 4, setupTxt, text_color = setupCol, bgcolor = bg, text_size = size.small)
    table.cell(hud, 0, 5, "Last signal", text_color = tx, bgcolor = bg, text_size = size.small)
    table.cell(hud, 1, 5, lastTxt, text_color = lastCol, bgcolor = bg, text_size = size.small)
    table.cell(hud, 0, 6, "Signals L/S", text_color = tx, bgcolor = bg, text_size = size.small)
    table.cell(hud, 1, 6, str.tostring(longCount, "#") + " / " + str.tostring(shortCount, "#"), text_color = tx, bgcolor = bg, text_size = size.small)

// ----- Backtest panel: both windows side by side, avgR + n -----
var table tst = na
if barstate.isfirst and showHUD
    tst := table.new(posMap(tstPos), 4, 4, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if showHUD and barstate.islast
    bbg = color.new(color.black, 12)
    bhd = color.new(color.purple, 35)
    avgLA = nLA > 0 ? sRLA / nLA : na
    avgSA = nSA > 0 ? sRSA / nSA : na
    totA2 = nLA + nSA
    avgAA = totA2 > 0 ? (sRLA + sRSA) / totA2 : na
    avgLB = nLB > 0 ? sRLB / nLB : na
    avgSB = nSB > 0 ? sRSB / nSB : na
    totB2 = nLB + nSB
    avgAB = totB2 > 0 ? (sRLB + sRSB) / totB2 : na
    table.cell(tst, 0, 0, costPrice > 0 ? "NET R" : "BACKTEST", text_color = C_GOLD, bgcolor = bhd, text_size = size.small)
    table.cell(tst, 1, 0, "A " + aLabel, text_color = color.white, bgcolor = bhd, text_size = size.small)
    table.cell(tst, 2, 0, "B " + bLabel, text_color = color.white, bgcolor = bhd, text_size = size.small)
    table.cell(tst, 3, 0, "Auto", text_color = color.white, bgcolor = bhd, text_size = size.small)
    table.cell(tst, 0, 1, "Long",  text_color = color.white, bgcolor = bbg, text_size = size.small)
    table.cell(tst, 1, 1, fmtAB(avgLA, nLA), text_color = colR(avgLA), bgcolor = bbg, text_size = size.small)
    table.cell(tst, 2, 1, fmtAB(avgLB, nLB), text_color = colR(avgLB), bgcolor = bbg, text_size = size.small)
    gL = autoGrade(nLA, nLB, avgLA, avgLB)
    table.cell(tst, 3, 1, vTxt(gL), text_color = vFg(gL), bgcolor = vBg(gL), text_size = size.small)
    table.cell(tst, 0, 2, "Short", text_color = color.white, bgcolor = bbg, text_size = size.small)
    table.cell(tst, 1, 2, fmtAB(avgSA, nSA), text_color = colR(avgSA), bgcolor = bbg, text_size = size.small)
    table.cell(tst, 2, 2, fmtAB(avgSB, nSB), text_color = colR(avgSB), bgcolor = bbg, text_size = size.small)
    gS = autoGrade(nSA, nSB, avgSA, avgSB)
    table.cell(tst, 3, 2, vTxt(gS), text_color = vFg(gS), bgcolor = vBg(gS), text_size = size.small)
    table.cell(tst, 0, 3, "All",   text_color = color.white, bgcolor = bbg, text_size = size.small)
    table.cell(tst, 1, 3, fmtAB(avgAA, totA2), text_color = colR(avgAA), bgcolor = bbg, text_size = size.small)
    table.cell(tst, 2, 3, fmtAB(avgAB, totB2), text_color = colR(avgAB), bgcolor = bbg, text_size = size.small)
    table.cell(tst, 3, 3, "", bgcolor = bbg, text_size = size.small)

// ----- Scanner table (the radar) -----
shortSym(_s) =>
    _i = str.pos(_s, ":")
    na(_i) ? _s : str.substring(_s, _i + 1)

stTxt(_dir, _comp, _score) =>
    _arrow = _dir == 1 ? " ▲" : _dir == -1 ? " ▼" : ""
    _score < watchThresh ? "chop" : (_comp == 1 ? "NEAR" : "trend") + _arrow

stCol(_dir, _score) =>
    _score < watchThresh ? color.new(color.gray, 20) : _dir == 1 ? C_UP : _dir == -1 ? C_DOWN : color.new(color.gray, 20)

// Red/Amber/Green edge grade from the user's curated lists (whole-token match).
gradeOf(_name, _dir) =>
    _n  = "," + str.upper(_name) + ","
    _gl = "," + str.replace_all(str.upper(greenLong),  " ", "") + ","
    _gs = "," + str.replace_all(str.upper(greenShort), " ", "") + ","
    _al = "," + str.replace_all(str.upper(amberLong),  " ", "") + ","
    _as = "," + str.replace_all(str.upper(amberShort), " ", "") + ","
    _dir == 1 ? (str.contains(_gl, _n) ? 2 : str.contains(_al, _n) ? 1 : 0) : _dir == -1 ? (str.contains(_gs, _n) ? 2 : str.contains(_as, _n) ? 1 : 0) : 0
ragBg(_grade)  => _grade == 2 ? color.new(C_UP, 20) : _grade == 1 ? color.new(#FFB300, 15) : color.new(C_DOWN, 20)
ragTxt(_grade) => _grade == 2 ? "GO" : _grade == 1 ? "~" : "NO"
ragFg(_grade)  => _grade == 1 ? color.black : color.white

// Watchlist heads-up: only GREEN/AMBER pairs (in their trend direction) that
// are trending AND within nearAtr of the rail. Sits after gradeOf so it can
// read your curated lists. This is the blanket 'go look' alert.
nearGo(_name,_sc,_cp,_dr) => _sc >= watchThresh and _cp == 1 and _dr != 0 and gradeOf(_name, _dr) >= 1
anyWatch = scanEnable and (nearGo(shortSym(sym1),sc1,cp1,dr1) or nearGo(shortSym(sym2),sc2,cp2,dr2) or nearGo(shortSym(sym3),sc3,cp3,dr3) or nearGo(shortSym(sym4),sc4,cp4,dr4) or nearGo(shortSym(sym5),sc5,cp5,dr5) or nearGo(shortSym(sym6),sc6,cp6,dr6) or nearGo(shortSym(sym7),sc7,cp7,dr7) or nearGo(shortSym(sym8),sc8,cp8,dr8) or nearGo(shortSym(sym9),sc9,cp9,dr9) or nearGo(shortSym(sym10),sc10,cp10,dr10) or nearGo(shortSym(sym11),sc11,cp11,dr11) or nearGo(shortSym(sym12),sc12,cp12,dr12) or nearGo(shortSym(sym13),sc13,cp13,dr13) or nearGo(shortSym(sym14),sc14,cp14,dr14) or nearGo(shortSym(sym15),sc15,cp15,dr15) or nearGo(shortSym(sym16),sc16,cp16,dr16) or nearGo(shortSym(sym17),sc17,cp17,dr17) or nearGo(shortSym(sym18),sc18,cp18,dr18) or nearGo(shortSym(sym19),sc19,cp19,dr19) or nearGo(shortSym(sym20),sc20,cp20,dr20) or nearGo(shortSym(sym21),sc21,cp21,dr21) or nearGo(shortSym(sym22),sc22,cp22,dr22) or nearGo(shortSym(sym23),sc23,cp23,dr23) or nearGo(shortSym(sym24),sc24,cp24,dr24) or nearGo(shortSym(sym25),sc25,cp25,dr25) or nearGo(shortSym(sym26),sc26,cp26,dr26) or nearGo(shortSym(sym27),sc27,cp27,dr27) or nearGo(shortSym(sym28),sc28,cp28,dr28) or nearGo(shortSym(sym29),sc29,cp29,dr29) or nearGo(shortSym(sym30),sc30,cp30,dr30))
alertcondition(anyWatch, "Watchlist near breakout", "A graded (green/amber) watchlist pair is trending and approaching its breakout rail")

var table scan = na
if barstate.isfirst and scanEnable
    scan := table.new(posMap(scanPos), 5, 3 + radarRows, frame_color = color.new(color.gray, 40), frame_width = 1, border_color = color.new(color.gray, 60), border_width = 1)

if scanEnable and barstate.islast
    sbg = color.new(color.black, 12)
    stx = color.white
    syms = array.from(shortSym(sym1), shortSym(sym2), shortSym(sym3), shortSym(sym4), shortSym(sym5), shortSym(sym6), shortSym(sym7), shortSym(sym8), shortSym(sym9), shortSym(sym10), shortSym(sym11), shortSym(sym12), shortSym(sym13), shortSym(sym14), shortSym(sym15), shortSym(sym16), shortSym(sym17), shortSym(sym18), shortSym(sym19), shortSym(sym20), shortSym(sym21), shortSym(sym22), shortSym(sym23), shortSym(sym24), shortSym(sym25), shortSym(sym26), shortSym(sym27), shortSym(sym28), shortSym(sym29), shortSym(sym30))
    scs  = array.from(sc1, sc2, sc3, sc4, sc5, sc6, sc7, sc8, sc9, sc10, sc11, sc12, sc13, sc14, sc15, sc16, sc17, sc18, sc19, sc20, sc21, sc22, sc23, sc24, sc25, sc26, sc27, sc28, sc29, sc30)
    drs  = array.from(dr1, dr2, dr3, dr4, dr5, dr6, dr7, dr8, dr9, dr10, dr11, dr12, dr13, dr14, dr15, dr16, dr17, dr18, dr19, dr20, dr21, dr22, dr23, dr24, dr25, dr26, dr27, dr28, dr29, dr30)
    cps  = array.from(cp1, cp2, cp3, cp4, cp5, cp6, cp7, cp8, cp9, cp10, cp11, cp12, cp13, cp14, cp15, cp16, cp17, cp18, cp19, cp20, cp21, cp22, cp23, cp24, cp25, cp26, cp27, cp28, cp29, cp30)
    ers  = array.from(er1, er2, er3, er4, er5, er6, er7, er8, er9, er10, er11, er12, er13, er14, er15, er16, er17, er18, er19, er20, er21, er22, er23, er24, er25, er26, er27, er28, er29, er30)

    grds = array.new<int>()
    for i = 0 to array.size(syms) - 1
        array.push(grds, gradeOf(array.get(syms, i), array.get(drs, i)))

    // WATCH pick: prefer a GREEN/AMBER pair that's trending AND coiling, then any
    // coiling trender, then a graded trender, then any trender. Keeps red out of
    // the headline unless nothing better is on offer.
    bestIdx = -1
    bestScore = -1.0
    for i = 0 to array.size(scs) - 1
        if array.get(grds, i) >= 1 and array.get(scs, i) >= watchThresh and array.get(cps, i) == 1 and array.get(drs, i) != 0 and array.get(scs, i) > bestScore
            bestScore := array.get(scs, i)
            bestIdx := i
    if bestIdx == -1
        for i = 0 to array.size(scs) - 1
            if array.get(scs, i) >= watchThresh and array.get(cps, i) == 1 and array.get(drs, i) != 0 and array.get(scs, i) > bestScore
                bestScore := array.get(scs, i)
                bestIdx := i
    if bestIdx == -1
        for i = 0 to array.size(scs) - 1
            if array.get(grds, i) >= 1 and array.get(scs, i) >= watchThresh and array.get(drs, i) != 0 and array.get(scs, i) > bestScore
                bestScore := array.get(scs, i)
                bestIdx := i
    if bestIdx == -1
        for i = 0 to array.size(scs) - 1
            if array.get(scs, i) >= watchThresh and array.get(drs, i) != 0 and array.get(scs, i) > bestScore
                bestScore := array.get(scs, i)
                bestIdx := i

    nTrend = 0
    for i = 0 to array.size(scs) - 1
        if array.get(scs, i) >= watchThresh and array.get(drs, i) != 0
            nTrend := nTrend + 1
    hb = color.new(color.blue, 35)
    table.cell(scan, 0, 0, "APEX RADAR", text_color = C_GOLD, bgcolor = hb, text_size = size.small)
    table.cell(scan, 1, 0, "trends", text_color = C_GOLD, bgcolor = hb, text_size = size.small)
    table.cell(scan, 2, 0, str.tostring(nTrend), text_color = C_GOLD, bgcolor = hb, text_size = size.small)
    table.cell(scan, 3, 0, scanTf, text_color = C_GOLD, bgcolor = hb, text_size = size.small)
    table.cell(scan, 4, 0, "Go", text_color = C_GOLD, bgcolor = hb, text_size = size.small)

    watchSym = bestIdx == -1 ? "none trending" : array.get(syms, bestIdx)
    watchEr  = bestIdx == -1 ? "—" : str.tostring(array.get(ers, bestIdx), "#")
    watchSt  = bestIdx == -1 ? "—" : stTxt(array.get(drs, bestIdx), array.get(cps, bestIdx), array.get(scs, bestIdx))
    table.cell(scan, 0, 1, "WATCH", text_color = color.black, bgcolor = C_GOLD, text_size = size.small)
    table.cell(scan, 1, 1, watchSym, text_color = color.black, bgcolor = C_GOLD, text_size = size.small)
    table.cell(scan, 2, 1, watchEr, text_color = color.black, bgcolor = C_GOLD, text_size = size.small)
    table.cell(scan, 3, 1, watchSt, text_color = color.black, bgcolor = C_GOLD, text_size = size.small)
    wGrade = bestIdx == -1 ? -1 : array.get(grds, bestIdx)
    table.cell(scan, 4, 1, wGrade == -1 ? "—" : ragTxt(wGrade), text_color = wGrade == -1 ? color.black : ragFg(wGrade), bgcolor = wGrade == -1 ? C_GOLD : ragBg(wGrade), text_size = size.small)

    table.cell(scan, 0, 2, "Asset", text_color = stx, bgcolor = color.new(color.purple, 35), text_size = size.small)
    table.cell(scan, 1, 2, "Score", text_color = stx, bgcolor = color.new(color.purple, 35), text_size = size.small)
    table.cell(scan, 2, 2, "ER",    text_color = stx, bgcolor = color.new(color.purple, 35), text_size = size.small)
    table.cell(scan, 3, 2, "State", text_color = stx, bgcolor = color.new(color.purple, 35), text_size = size.small)
    table.cell(scan, 4, 2, "Go",    text_color = stx, bgcolor = color.new(color.purple, 35), text_size = size.small)

    // Rank by score, strongest first, capped at radarRows. Always fill the rows
    // you asked for (top-N leaderboard); pairs below the trending threshold show
    // as "chop" via stTxt/stCol. Rows only blank if a slot returns no data.
    work = array.copy(scs)
    for k = 0 to radarRows - 1
        mx = -1.0
        mi = -1
        for j = 0 to array.size(work) - 1
            v = array.get(work, j)
            if v > mx
                mx := v
                mi := j
        rr = k + 3
        if mi >= 0
            sc = array.get(scs, mi)
            dr = array.get(drs, mi)
            cp = array.get(cps, mi)
            er = array.get(ers, mi)
            rowBg = mi == bestIdx ? color.new(C_GOLD, 75) : sbg
            table.cell(scan, 0, rr, array.get(syms, mi), text_color = stx, bgcolor = rowBg, text_size = size.small)
            table.cell(scan, 1, rr, str.tostring(sc, "#"), text_color = color.white, bgcolor = rowBg, text_size = size.small)
            table.cell(scan, 2, rr, str.tostring(er, "#"), text_color = color.new(color.gray, 0), bgcolor = rowBg, text_size = size.small)
            table.cell(scan, 3, rr, stTxt(dr, cp, sc), text_color = stCol(dr, sc), bgcolor = rowBg, text_size = size.small)
            gr = array.get(grds, mi)
            table.cell(scan, 4, rr, ragTxt(gr), text_color = ragFg(gr), bgcolor = ragBg(gr), text_size = size.small)
            array.set(work, mi, -2.0)
        else
            table.cell(scan, 0, rr, "", bgcolor = sbg, text_size = size.small)
            table.cell(scan, 1, rr, "", bgcolor = sbg, text_size = size.small)
            table.cell(scan, 2, rr, "", bgcolor = sbg, text_size = size.small)
            table.cell(scan, 3, rr, "", bgcolor = sbg, text_size = size.small)
            table.cell(scan, 4, rr, "", bgcolor = sbg, text_size = size.small)
````
