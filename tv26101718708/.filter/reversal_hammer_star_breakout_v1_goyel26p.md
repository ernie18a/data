# Reversal Hammer, Star Breakout  v1

- url: https://www.tradingview.com/script/gOyEl26p-Reversal-Hammer-Star-Breakout-v1/
- type: indicator
- pine_id: PUB;236044eb1d9a4114a8b85f252507f9a7
- version: 1.0

## Description

Reversal Hammer/Star Breakout is a candlestick-reversal breakout tool with a built-in trade-simulation and statistics engine. It detects exhaustion candles at the end of a move, arms a stop-entry on the breakout of a reference level, manages the resulting position with a fixed stop and a configurable target, and then logs and scores every trade in a self-contained performance dashboard — all from a single indicator, without a separate strategy script.

The goal is not to display a pattern and leave the rest to the eye. Every detected setup is turned into a fully specified order (entry, stop, target), filled or expired according to explicit rules, resolved intrabar for stop/target precision, and recorded with realistic costs. What you see on the dashboard is therefore an internal back-of-the-envelope simulation of how that exact rule set would have behaved on the loaded symbol and timeframe.

The setup

Long (bottom reversal). At the end of a down move the script looks for a bullish reversal candle — a Hammer, a Bullish Spinning Top, or (optionally) a Bullish Engulfing candle. When one prints in a valid context, a buy stop is armed above a reference level. The protective stop is placed at the low of the reversal candle.

Short (top reversal). At the end of an up move it looks for a bearish reversal candle — a Shooting Star / Inverted Hammer, a Bearish Spinning Top, or (optionally) a Bearish Engulfing candle. A sell stop is armed below a reference level, with the protective stop at the high of the reversal candle.

Entry reference. The breakout level is configurable:


Candle before reversal — break of the high (long) / low (short) of the candle that precedes the reversal candle. More confirmation, later entry.
Reversal candle — break of the reversal candle's own high/low. Earlier, tighter entry.


Stop. Opposite extreme of the reversal candle (with an optional tick buffer), or a fixed tick distance from entry.

Target. A configurable R multiple of the entry-to-stop risk (default), or the reversal candle range.

Pattern definition (fully adjustable)

Candle shapes are defined by ratios rather than fixed thresholds, so they adapt to any instrument:


Max body size as a fraction of the candle range.
Minimum dominant wick, expressed both as a multiple of the body and as a fraction of the range (the latter keeps doji-like candles honest).
Maximum opposite wick as a multiple of the body.
Spinning-top minimum wick on each side.


You can independently enable Hammer, Bullish/Bearish Spinning Top, Shooting Star / Inverted Hammer and Bullish/Bearish Engulfing, and optionally require the reversal candle to close in the trade direction. Lowering the dominant-wick multiple below 1.0 lets you accept larger-bodied hammers/stars; engulfing covers strong-bodied reversals that have little or no wick.

Filters

Each filter is optional and independent, so you can isolate exactly what adds value:


Trend context. Confirms the reversal occurs at the end of a trend. EMA trend (price beyond a sloping EMA) or Swing extreme (the reversal candle prints a fresh N-bar low/high), or either, or off.
Higher-timeframe filter. A fast/slow EMA relationship on a higher timeframe. It can require the higher timeframe to agree with the trade direction (confluence) or to still agree with the prior trend (early-reversal). It is read from confirmed higher-timeframe values with a one-bar offset and no look-ahead, so it does not repaint.
Breakout structure. Requires the entry to clear the extreme of the last N bars while excluding the most recent M bars. In a clean trend each bar prints a fresh extreme; taking the reference from the older window prevents the level from being redefined every bar, which curbs cascade entries.
RSI extreme. Longs only when RSI is oversold, shorts only when overbought, with adjustable thresholds and length.
Distance from a moving average. Requires price to be stretched at least k daily-ATR units away from a moving average (SMA/EMA, adjustable length) — below it for longs, above it for shorts — to favour genuine exhaustion. The reference average is plotted on the chart.


Simulation engine and no-repaint design


Bar-close-only processing. Setups, fills and exits can be evaluated only when a bar closes, so the historical and the real-time picture match.
Intrabar resolution cascade. Stop-entry fills and stop/target hits are resolved by walking sub-candles in chronological order, cascading 1-minute → 2-minute → 5-minute and falling back to the bar OHLC when sub-candle data is unavailable. The active source is shown in the diagnostic panel.
Tie handling and dirty bars. When a single bar would touch both the stop and the target, the order is ambiguous; the outcome is resolved by a conservative (stop-first) or optimistic (target-first) rule, and the trade is flagged as a dirty bar and counted separately so you can judge how much of the result is path-dependent.
Realistic costs. Per-side slippage in ticks is applied to every fill, and instrument tick size / tick value / contract size can be read automatically or set manually, so currency results match the traded product.


Trade management


One trade at a time, with an optional cooldown after each close.
Maximum bars in trade (time stop) and an optional force-flat window at the end of the session.
Entry time window and maximum trades per day, with a selectable session timezone.
Optional post-win no-chase cooldown that blocks new same-direction entries priced worse than the last winner's exit for a number of bars, to avoid chasing a move you just profited from.


Statistics dashboard

A compact panel reports, in points, currency and R: number of trades and long/short split, win rate (overall and per side), profit factor, net result, expectancy in R and in currency, average and largest win/loss, maximum drawdown in currency and in R, maximum win/loss streaks, average bars per trade, dirty-trade share, and the live status of any open or pending order (direction, entry, stop, target, risk).

Diagnostic panel

A second panel makes it easy to understand why a setup did or did not trade: counts of reversal candles, qualified long/short patterns, pattern types (hammer, spinning top, engulfing), orders placed, filled and expired, fill rate, the active intrabar source, and the current state of every filter (trend context, structure, RSI value, stretch distance in ATR units). If a candle you expected to trigger does not, these counters localise the cause immediately.

Visuals, logs and alerts


The reversal candle is highlighted, with optional projected entry/stop/target lines and small entry/exit labels.
An open-position banner shows live PnL in currency, points and R.
Every closed trade is printed to Pine Logs as a single CSV line (with a header row), so the full trade list can be exported and analysed externally.
Alerts are available for a detected long/short reversal and for a stop-entry order being placed.


Suggested workflow


Set the instrument tick size, tick value, contract size and slippage to match your product.
Start with the pattern set and entry/stop/target rules only, all filters off, and read the dashboard.
Enable one filter at a time and compare the dashboard before and after, so each filter has to justify its inclusion rather than being added on faith.
Use the diagnostic panel whenever an expected signal is missing.
Treat dirty-bar share and slippage-adjusted expectancy as quality gates before trusting the numbers.


Notes on realism

The dashboard is an internal simulation, not the native Strategy Tester, and it is deliberately built to err toward conservative, realistic results: bar-close processing, intrabar ordering for stop/target, explicit dirty-bar accounting, modelled slippage and instrument-accurate currency. Results still depend on the loaded symbol, timeframe and the availability of sub-minute data for the intrabar cascade. Widening pattern definitions or relaxing filters to capture a specific past setup is a classic route to overfitting; after any such change, re-evaluate the aggregate statistics rather than a single trade.

Disclaimer

This script is published for educational and research purposes only. It is not financial advice and not a recommendation to buy or sell any instrument. Backtested and simulated results do not guarantee future performance. Trading futures and leveraged products involves substantial risk of loss. Always test on your own data and trade only with capital you can afford to lose.

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// © Reversal Hammer/Star Breakout — v1 (Pine Script v6)
//
// Same toolkit as Inside Bar Breakout: manual trade simulation engine, intrabar
// resolution (1m -> 2m -> 5m cascade), bar-close-only processing (no repaint),
// instrument (tick size / tick value) controls, sessions and limits, full statistics
// dashboard, diagnostic panel and CSV Pine Logs export. Only the PATTERN and the
// entry/stop/target rules are different.
//
// SETUP (reversal):
//   LONG : end of a DOWNTREND -> reversal candle = Hammer OR Bullish Spinning Top.
//   SHORT: end of an UPTREND  -> reversal candle = Shooting Star / Inverted Hammer.
//   The reversal candle is the CURRENT bar; the order is armed at its close so the
//   very next bar can fill it.
// ENTRY : STOP order at the chosen reference:
//          "Candle before reversal" (default) = break of high[1] (long) / low[1] (short)
//          "Reversal candle"                  = break of the reversal candle high/low.
// STOP  : opposite extreme of the REVERSAL candle (its low for longs, its high for shorts).
// TARGET: R multiple of risk (default) or the reversal candle range.
// + optional non-repainting HTF filter and trend context.

//@version=6
indicator("Reversal Hammer/Star Breakout — v1", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
// INPUTS
// =============================================================================

// --- 1. Pattern (reversal candle) ---
allowBoth   = input.bool(true, "Allow both directions", group = "1. Pattern", tooltip = "OFF = restrict to a single side via the dropdown below.")
sideOnly    = input.string("Both", "Side filter (used when 'Allow both' is OFF)", options = ["Both", "Long only", "Short only"], group = "1. Pattern")
bodyMaxRange = input.float(0.40, "Max body size (× candle range)", minval = 0.05, maxval = 0.90, step = 0.05, group = "1. Pattern", tooltip = "Body must be smaller than this fraction of the full candle range. Lower = stricter.")
domWickRatio = input.float(2.0, "Min dominant wick (× body)", minval = 0.1, step = 0.1, group = "1. Pattern", tooltip = "Hammer lower wick / Star upper wick must be at least this multiple of the body. Lower it below 1.0 to allow bigger-bodied hammers/stars.")
oppWickMax   = input.float(1.0, "Max opposite wick (× body)", minval = 0.0, step = 0.1, group = "1. Pattern", tooltip = "Hammer upper wick / Star lower wick maximum size.")
domWickRange = input.float(0.45, "Min dominant wick (× range)", minval = 0.0, maxval = 0.9, step = 0.05, group = "1. Pattern", tooltip = "Robustness vs doji: the dominant wick must also be at least this fraction of the full range.")
spinWickMin  = input.float(0.8, "Spinning Top: min each wick (× body)", minval = 0.1, step = 0.1, group = "1. Pattern")
useHammer    = input.bool(true,  "LONG: accept Hammer", group = "1. Pattern")
useSpinning  = input.bool(true,  "LONG: accept Bullish Spinning Top", group = "1. Pattern")
useBullEngulf = input.bool(false, "LONG: accept Bullish Engulfing", group = "1. Pattern", tooltip = "Big-body reversal: a bullish candle whose body engulfs the prior bearish candle's body.")
useStar      = input.bool(true,  "SHORT: accept Shooting Star / Inverted Hammer", group = "1. Pattern")
useBearSpin  = input.bool(false, "SHORT: accept Bearish Spinning Top", group = "1. Pattern")
useBearEngulf = input.bool(false, "SHORT: accept Bearish Engulfing", group = "1. Pattern", tooltip = "Big-body reversal: a bearish candle whose body engulfs the prior bullish candle's body.")
reqBullClose = input.bool(true,  "Require bullish close for LONG candle", group = "1. Pattern")
reqBearClose = input.bool(false, "Require bearish close for SHORT candle", group = "1. Pattern")

// --- 1b. Trend context ---
trendMode    = input.string("EMA trend", "Reversal context", options = ["EMA trend", "Swing extreme", "Either", "Off"], group = "1b. Trend context", tooltip = "Confirms the reversal happens at the end of a trend. EMA trend = price beyond a falling/rising EMA. Swing extreme = reversal candle prints a fresh low/high.")
emaLen       = input.int(50, "Trend EMA length",       minval = 2, group = "1b. Trend context")
emaSlopeBars = input.int(3,  "EMA slope lookback",     minval = 1, group = "1b. Trend context")
swingLen     = input.int(5,  "Swing extreme lookback", minval = 1, group = "1b. Trend context")

// --- 1c. Breakout structure filter ---
useStructFilter = input.bool(true, "Require breakout of an N-bar extreme", group = "1c. Breakout structure", tooltip = "The entry level must clear the extreme of the last N bars (HIGH for longs, LOW for shorts), EXCLUDING the most recent M bars. Prevents cascade entries when a trending phase prints a fresh extreme on every bar.")
structN = input.int(20, "Lookback length (N bars)", minval = 2, maxval = 1000, group = "1c. Breakout structure")
structM = input.int(3,  "Exclude most recent (M bars)", minval = 1, maxval = 500, group = "1c. Breakout structure", tooltip = "The reference extreme is taken over the N bars ending M bars ago, so the last M bars (including the reversal candle) do not define the level they must break.")

// --- 1d. Momentum & stretch filters ---
useRsiFilter = input.bool(true, "Require RSI extreme", group = "1d. Momentum & stretch", tooltip = "LONG only if RSI is oversold (<= OS); SHORT only if RSI is overbought (>= OB). Evaluated on the reversal candle.")
rsiLen = input.int(14, "RSI length", minval = 1, group = "1d. Momentum & stretch")
rsiOS  = input.float(30.0, "RSI oversold (LONG)",   minval = 1.0, maxval = 99.0, step = 1.0, group = "1d. Momentum & stretch")
rsiOB  = input.float(70.0, "RSI overbought (SHORT)", minval = 1.0, maxval = 99.0, step = 1.0, group = "1d. Momentum & stretch")
useStretchFilter = input.bool(true, "Require min distance from MA (× daily ATR)", group = "1d. Momentum & stretch", tooltip = "Price must be stretched away from the moving average by at least 'k' daily ATRs. LONG = price BELOW the MA (stretched down); SHORT = price ABOVE the MA (stretched up).")
maStretchType = input.string("SMA", "MA type", options = ["SMA", "EMA"], group = "1d. Momentum & stretch")
maStretchLen  = input.int(50, "MA length", minval = 2, group = "1d. Momentum & stretch", tooltip = "The 'MA 50' you referred to. Distance is measured from this average.")
minStretchAtr = input.float(1.0, "Min distance (× daily ATR)", minval = 0.0, step = 0.1, group = "1d. Momentum & stretch")
atrDailyLen   = input.int(14, "Daily ATR length", minval = 1, group = "1d. Momentum & stretch")

// --- 2. Trade ---
entryRef       = input.string("Candle before reversal", "Entry trigger reference", options = ["Candle before reversal", "Reversal candle"], group = "2. Trade", tooltip = "Candle before reversal = break of the high (long) / low (short) of the candle PRECEDING the hammer/star. Reversal candle = break of the hammer/star's own high/low (classic).")
breakoutWindow = input.int(3, "Breakout validity (bars)", minval = 1, maxval = 50, group = "2. Trade", tooltip = "How many bars after the reversal candle the stop entry remains armed.")
slBuffer       = input.float(0.0, "SL buffer (ticks)", minval = 0.0, maxval = 100.0, step = 1.0, group = "2. Trade")
slBasis = input.string("Reversal candle opposite end", "SL basis", options = ["Reversal candle opposite end", "Fixed ticks from entry"], group = "2. Trade", tooltip = "Where the stop sits. 'Reversal candle opposite end' (your spec) = reversal candle LOW for longs, HIGH for shorts. 'Fixed ticks from entry' = a constant distance set below.")
slFixedTicks = input.float(20.0, "SL distance (ticks) — only if 'Fixed ticks' basis", minval = 1.0, step = 1.0, group = "2. Trade")
tpBasis = input.string("R multiple of risk", "TP basis", options = ["R multiple of risk", "Reversal candle range"], group = "2. Trade", tooltip = "How the target is computed. 'R multiple of risk' (default — no target was specified) = entry +/- R x (entry-to-stop distance). 'Reversal candle range' = entry +/- (reversal high - reversal low).")
rrRatio  = input.float(2.0, "R multiple (used only if TP basis is 'R multiple')", minval = 0.5, maxval = 10.0, step = 0.5, group = "2. Trade")
maxBarsHold    = input.int(60, "Max bars in trade", minval = 5, maxval = 500, group = "2. Trade")
blockInTrade   = input.bool(true, "One trade at a time (ignore signals until close)", group = "2. Trade")
cooldownBars   = input.int(0, "Cooldown after a close (bars)", minval = 0, maxval = 500, group = "2. Trade", tooltip = "Bars to wait after any trade closes before a new entry is allowed. 0 = off.")

// --- 2c. Post-win no-chase cooldown ---
useWinChase    = input.bool(false, "No-chase cooldown after a winning trade", group = "2c. Post-win cooldown", tooltip = "After a WINNING trade, block new SAME-DIRECTION entries that would fill at a WORSE price than the winner's exit (TP), for a number of bars. The opposite direction is never blocked.")
winChaseBars   = input.int(10, "No-chase window (bars)", minval = 1, maxval = 500, group = "2c. Post-win cooldown")
confirmedBarsOnly = input.bool(true, "Process on bar close only (no repaint)", group = "2. Trade", tooltip = "ON (recommended) = setups, fills and exits are evaluated ONLY when a bar closes. OFF = evaluate intrabar in real time (provisional).")

// --- 3. Intrabar (SL/TP precision) ---
useIntrabar = input.bool(true, "Intrabar resolution (1m->2m->5m cascade)", group = "3. Intrabar", tooltip = "ON = SL/TP and stop-entry fills resolved by walking sub-candles in order. OFF = use the current bar OHLC.")
tieMode     = input.string("Conservative (SL first)", "SL/TP tie within same sub-candle", options = ["Conservative (SL first)", "Optimistic (TP first)"], group = "3. Intrabar")

// --- 4. HTF filter (optional) ---
useHtfFilter = input.bool(false, "Enable HTF filter", group = "4. HTF Filter")
htfTf        = input.timeframe("60", "HTF timeframe", group = "4. HTF Filter")
htfFastLen   = input.int(21, "HTF EMA fast", minval = 1, group = "4. HTF Filter")
htfSlowLen   = input.int(50, "HTF EMA slow", minval = 2, group = "4. HTF Filter")
htfMode      = input.string("Agree with trade", "HTF condition", options = ["Agree with trade", "Agree with reversal"], group = "4. HTF Filter", tooltip = "Agree with trade: LONG needs HTF bullish, SHORT needs HTF bearish (confluence). Agree with reversal: LONG allowed while HTF still bearish, SHORT while HTF still bullish (early-reversal).")

// --- 5. Instrument ---
tickMode     = input.string("Auto", "Tick value/size source", options = ["Auto", "Manual"], group = "5. Instrument")
manTickSize  = input.float(0.25, "Tick size (min price move)", minval = 0.000001, step = 0.01, group = "5. Instrument")
manTickValue = input.float(0.50, "Tick value (currency per tick)", minval = 0.0001, step = 0.01, group = "5. Instrument")
qty          = input.float(1.0, "Contracts", minval = 0.01, step = 1.0, group = "5. Instrument")
slippageTicks = input.float(1.0, "Slippage per side (ticks)", minval = 0.0, step = 0.5, group = "5. Instrument")

// --- 6. Sessions & limits ---
maxTradesPerDay = input.int(0, "Max trades per day (0 = unlimited)", minval = 0, maxval = 50, group = "6. Sessions & limits")
sessionTz       = input.string("Europe/Rome", "Session timezone", options = ["America/New_York", "Europe/Rome", "Europe/London", "UTC"], group = "6. Sessions & limits")
useEntryWindow  = input.bool(true, "Restrict entries to a time window", group = "6. Sessions & limits")
entrySession    = input.session("0800-1500", "Entry window (start–end)", group = "6. Sessions & limits", tooltip = "New orders are only placed inside this window. End = last-entry cutoff.")
useForceFlat    = input.bool(true, "Force flat at end of day", group = "6. Sessions & limits")
flatSession     = input.session("1500-1505", "Force-flat window", group = "6. Sessions & limits", tooltip = "Any open position is closed at market when price enters this window.")

// --- 7. Display ---
showDashboard  = input.bool(true,  "Statistics dashboard", group = "7. Display")
showDiagnostic = input.bool(true,  "Diagnostic panel",     group = "7. Display")
showTradeLines = input.bool(true,  "Trade lines (entry/SL/TP)", group = "7. Display")
showTradeMarks = input.bool(true,  "Entry/exit labels (small)", group = "7. Display")
labelOffsetAtr = input.float(0.6, "Label offset from candle (x ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = "7. Display", tooltip = "How far above/below the candle the entry/exit labels sit, expressed as a multiple of ATR(14).")
colorRevBar    = input.bool(true,  "Color the reversal candle", group = "7. Display")
revBarCol      = input.color(color.yellow, "Reversal candle color", group = "7. Display")
showOpenPnl    = input.bool(true,  "Open-position PnL banner (top center)", group = "7. Display", tooltip = "Large banner that appears at the top center while a position is OPEN, showing direction, entry price and live PnL.")
showSessionBg  = input.bool(false, "Tint background during entry window", group = "7. Display")
dashPosition   = input.string("top_right", "Dashboard position", options = ["top_right", "top_left", "bottom_right", "bottom_left"], group = "7. Display")

// --- 8. Logs ---
enableLogs = input.bool(true,  "Print trade logs (Pine Logs)", group = "8. Logs", tooltip = "One CSV line per closed trade to the Pine Logs pane.")
logOrders  = input.bool(false, "Also log order events (placed/filled/expired)", group = "8. Logs")

// =============================================================================
// DERIVED INPUTS (must be defined before any use, including barcolor)
// =============================================================================

sideAllowsLong  = allowBoth or sideOnly == "Long only"  or sideOnly == "Both"
sideAllowsShort = allowBoth or sideOnly == "Short only" or sideOnly == "Both"

// =============================================================================
// INSTRUMENT RESOLUTION
// =============================================================================

effTickSize   = tickMode == "Manual" ? manTickSize  : syminfo.mintick
effTickValue  = tickMode == "Manual" ? manTickValue : (syminfo.pointvalue * syminfo.mintick)
effPointValue = effTickValue / effTickSize
curStr        = syminfo.currency
slipPts       = slippageTicks * effTickSize * 2.0

// =============================================================================
// SESSION
// =============================================================================

inEntryWindow = not useEntryWindow or not na(time(timeframe.period, entrySession, sessionTz))
inFlatWindow  = useForceFlat and not na(time(timeframe.period, flatSession, sessionTz))

bgcolor(showSessionBg and inEntryWindow ? color.new(color.blue, 95) : na, title = "Session", display = showSessionBg ? display.all : display.none)

// =============================================================================
// HTF FILTER (non-repainting)
// =============================================================================

htfDir = nz(request.security(syminfo.tickerid, htfTf, (ta.ema(close, htfFastLen) > ta.ema(close, htfSlowLen) ? 1 : -1)[1], lookahead = barmerge.lookahead_off), 0)
htfBull = htfDir == 1
htfBear = htfDir == -1
htfOkLong  = not useHtfFilter ? true : (htfMode == "Agree with trade" ? htfBull : htfBear)
htfOkShort = not useHtfFilter ? true : (htfMode == "Agree with trade" ? htfBear : htfBull)

// =============================================================================
// PATTERN: the reversal candle is the CURRENT bar so the order is armed at its
// close and the very next bar can fill it. The "candle before the reversal" is bar[1].
// =============================================================================

rngC  = high - low
bodyC = math.abs(close - open)
bC    = math.max(bodyC, effTickSize)                 // body floor (avoids doji div issues)
uwC   = high - math.max(open, close)                 // upper wick
lwC   = math.min(open, close) - low                  // lower wick
smallBodyC = rngC > 0 and bodyC <= bodyMaxRange * rngC

isHammer = smallBodyC and lwC >= domWickRatio * bC and lwC >= domWickRange * rngC and uwC <= oppWickMax * bC
isStar   = smallBodyC and uwC >= domWickRatio * bC and uwC >= domWickRange * rngC and lwC <= oppWickMax * bC
isSpin   = smallBodyC and uwC >= spinWickMin * bC and lwC >= spinWickMin * bC

// Engulfing: current body engulfs the previous candle's body (big-body reversal)
prevBull = close[1] > open[1]
prevBear = close[1] < open[1]
isBullEngulf = close > open and prevBear and close >= open[1] and open <= close[1]
isBearEngulf = close < open and prevBull and close <= open[1] and open >= close[1]

bullClose = not reqBullClose or close >= open
bearClose = not reqBearClose or close <= open

longShape  = ((useHammer and isHammer) or (useSpinning and isSpin) or (useBullEngulf and isBullEngulf)) and bullClose
shortShape = ((useStar and isStar)   or (useBearSpin and isSpin) or (useBearEngulf and isBearEngulf)) and bearClose

// Trend context
emaT       = ta.ema(close, emaLen)
downCtxEma = close < emaT and emaT < emaT[emaSlopeBars]
upCtxEma   = close > emaT and emaT > emaT[emaSlopeBars]
downCtxSw  = low  <= ta.lowest(low,  swingLen)       // fresh low → exhaustion
upCtxSw    = high >= ta.highest(high, swingLen)

downCtx = switch trendMode
    "EMA trend"     => downCtxEma
    "Swing extreme" => downCtxSw
    "Either"        => downCtxEma or downCtxSw
    => true
upCtx = switch trendMode
    "EMA trend"     => upCtxEma
    "Swing extreme" => upCtxSw
    "Either"        => upCtxEma or upCtxSw
    => true

c3_high  = high
c3_low   = low
prevHigh = high[1]
prevLow  = low[1]
revRange = c3_high - c3_low

longReversal  = longShape  and downCtx and not shortShape
shortReversal = shortShape and upCtx   and not longShape

// Entry reference levels (also used by the no-chase gate)
longEntryLvl  = entryRef == "Reversal candle" ? c3_high : prevHigh
shortEntryLvl = entryRef == "Reversal candle" ? c3_low  : prevLow

// Breakout structure filter: the entry must clear the extreme of the last structN
// bars EXCLUDING the most recent structM bars. In a clean trend each bar prints a
// fresh extreme, so without the exclusion the level would be re-defined every bar
// and fire entries in cascade; taking the extreme of the older window blocks that.
structHi = ta.highest(high, structN)[structM]
structLo = ta.lowest(low,  structN)[structM]
longStructOk  = not useStructFilter or (not na(structHi) and longEntryLvl  > structHi)
shortStructOk = not useStructFilter or (not na(structLo) and shortEntryLvl < structLo)

// RSI extreme filter (evaluated on the reversal candle)
rsiV = ta.rsi(close, rsiLen)
longRsiOk  = not useRsiFilter or rsiV <= rsiOS
shortRsiOk = not useRsiFilter or rsiV >= rsiOB

// Stretch filter: price must be at least minStretchAtr daily-ATRs away from the MA.
maStretch = maStretchType == "EMA" ? ta.ema(close, maStretchLen) : ta.sma(close, maStretchLen)
dailyATR  = request.security(syminfo.tickerid, "D", ta.atr(atrDailyLen)[1], lookahead = barmerge.lookahead_off)
stretchAbs   = not na(dailyATR) ? minStretchAtr * dailyATR : na
stretchAtrNow = (not na(dailyATR) and dailyATR != 0) ? (close - maStretch) / dailyATR : na   // signed, in daily-ATR units
longStretchOk  = not useStretchFilter or (not na(stretchAbs) and close <= maStretch - stretchAbs)
shortStretchOk = not useStretchFilter or (not na(stretchAbs) and close >= maStretch + stretchAbs)

// ATR for label offset (fallback to a tick-based minimum on illiquid instruments)
atrV     = ta.atr(14)
labelDy  = math.max(nz(atrV, 0) * labelOffsetAtr, 10 * effTickSize)

// Reversal-candle coloring: paint ONLY candles that produce an operational setup.
sideOkCur = (sideAllowsLong and longReversal) or (sideAllowsShort and shortReversal)
barcolor(colorRevBar and sideOkCur ? revBarCol : na, title = "Reversal candle (setup)")

patternLong  = longReversal  and sideAllowsLong  and htfOkLong  and longStructOk  and longRsiOk  and longStretchOk
patternShort = shortReversal and sideAllowsShort and htfOkShort and shortStructOk and shortRsiOk and shortStretchOk

plot(useStretchFilter ? maStretch : na, "Stretch MA", color = color.new(color.orange, 0), linewidth = 1)

// =============================================================================
// INTRABAR CASCADE
// =============================================================================

h1 = request.security_lower_tf(syminfo.tickerid, "1", high, ignore_invalid_timeframe = true)
l1 = request.security_lower_tf(syminfo.tickerid, "1", low,  ignore_invalid_timeframe = true)
h2 = request.security_lower_tf(syminfo.tickerid, "2", high, ignore_invalid_timeframe = true)
l2 = request.security_lower_tf(syminfo.tickerid, "2", low,  ignore_invalid_timeframe = true)
h5 = request.security_lower_tf(syminfo.tickerid, "5", high, ignore_invalid_timeframe = true)
l5 = request.security_lower_tf(syminfo.tickerid, "5", low,  ignore_invalid_timeframe = true)

useIB = useIntrabar
hiArr = not useIB ? na : array.size(h1) > 0 ? h1 : array.size(h2) > 0 ? h2 : array.size(h5) > 0 ? h5 : na
loArr = not useIB ? na : array.size(h1) > 0 ? l1 : array.size(h2) > 0 ? l2 : array.size(h5) > 0 ? l5 : na

var string ibSrc = "OHLC"
ibSrc := not useIB ? "OFF" : array.size(h1) > 0 ? "1m" : array.size(h2) > 0 ? "2m" : array.size(h5) > 0 ? "5m" : "OHLC"

iH = array.new<float>()
iL = array.new<float>()
nIntra = na(hiArr) ? 0 : array.size(hiArr)
if nIntra > 0
    for i = 0 to nIntra - 1
        array.push(iH, array.get(hiArr, i))
        array.push(iL, array.get(loArr, i))
else
    array.push(iH, high)
    array.push(iL, low)

// =============================================================================
// STATE MACHINE: pending (stop order) -> active -> exit
// =============================================================================

var int   state      = 0    // 0 flat, 1 pending stop, 2 active
var int   tdir       = 0    // 1 long, -1 short
var float tEntry     = na
var float tSL        = na
var float tTP        = na
var float tRisk      = na
var int   tSetupBar  = na
var int   tEntryBar  = na
var int   tSetupTime = na
var int   tEntryTime = na
var int   tPatType   = 0    // 1 hammer, 2 bull spin, 3 star, 4 bear spin

var line  lnE = na
var line  lnS = na
var line  lnT = na

f_delLines() =>
    if not na(lnE)
        line.delete(lnE)
    if not na(lnS)
        line.delete(lnS)
    if not na(lnT)
        line.delete(lnT)

// daily counter
var int tradesToday = 0
newDay = ta.change(time("D")) != 0
if newDay
    tradesToday := 0

var int  lastExitBar = na

// no-chase-after-win state
var int   winDir     = 0
var float winExitPx  = na
var int   winExitBar = na

// diagnostic counters
var int cntReversal      = 0
var int cntPatternLong   = 0
var int cntPatternShort  = 0
var int cntHammer        = 0
var int cntSpinL         = 0
var int cntStar          = 0
var int cntSpinS         = 0
var int cntEngL          = 0
var int cntEngS          = 0
var int cntPendingReg    = 0
var int cntFilled        = 0
var int cntExpired       = 0

if longShape or shortShape
    cntReversal += 1
if patternLong
    cntPatternLong += 1
    if useHammer and isHammer
        cntHammer += 1
    else if useSpinning and isSpin
        cntSpinL += 1
    else
        cntEngL += 1
if patternShort
    cntPatternShort += 1
    if useStar and isStar
        cntStar += 1
    else if useBearSpin and isSpin
        cntSpinS += 1
    else
        cntEngS += 1

// stats accumulators
var int   nTrades    = 0
var int   nWins      = 0
var int   nLosses    = 0
var int   nLongs     = 0
var int   nShorts    = 0
var int   nLongWins  = 0
var int   nShortWins = 0

var float sumWinR    = 0.0
var float sumLossR   = 0.0
var float runningR   = 0.0
var float peakR      = 0.0
var float maxDDR     = 0.0

var float sumGrossPts = 0.0
var float sumNetPts   = 0.0
var float sumSlipCur  = 0.0

var float grossProfitCur = 0.0
var float grossLossCur   = 0.0
var float equityCur      = 0.0
var float peakEquityCur  = 0.0
var float maxDDcur       = 0.0
var float largestWinCur  = 0.0
var float largestLossCur = 0.0

var int   curWin  = 0
var int   curLoss = 0
var int   maxWin  = 0
var int   maxLoss = 0
var int   sumBarsInTrade = 0

tieSLfirst = tieMode == "Conservative (SL first)"

var int nDirty = 0
bool exitTieDirty = false

if enableLogs and barstate.isfirst
    log.info("CSV_HEADER,trade,dir,setupTime,entryTime,exitTime,entry,sl,tp,exit,exitType,grossPts,netPts,R,netCur,barsHeld,ibSrc,dirty,result")

string exitType   = ""
float  exitPx     = na
bool   justFilled = false

// Latch: once a trade is recorded as closed on this bar, intrabar re-evaluation
// cannot undo it (guards against forming sub-candle data retracting before close).
var bool exitLatched = false
if barstate.isnew
    exitLatched := false

processBar = not confirmedBarsOnly or barstate.isconfirmed

// --- walk sub-candles in chronological order ---
nC = array.size(iH)
for i = 0 to nC - 1
    ch = array.get(iH, i)
    cl = array.get(iL, i)

    // STOP-ORDER fill (after the setup bar)
    if state == 1 and bar_index > tSetupBar and processBar
        filled = tdir == 1 ? ch >= tEntry : cl <= tEntry
        if filled
            state := 2
            tEntryBar := bar_index
            tEntryTime := time
            justFilled := true
            cntFilled += 1
            tradesToday += 1

    // SL/TP within the bar.
    if state == 2 and exitType == "" and processBar
        hitSL = tdir == 1 ? cl <= tSL : ch >= tSL
        hitTP = tdir == 1 ? ch >= tTP : cl <= tTP
        if hitSL and hitTP
            exitTieDirty := true
            exitType := tieSLfirst ? "SL" : "TP"
            exitPx   := tieSLfirst ? tSL : tTP
            state    := 0
            exitLatched := true
        else if hitSL
            exitType := "SL"
            exitPx   := tSL
            state    := 0
            exitLatched := true
        else if hitTP
            exitType := "TP"
            exitPx   := tTP
            state    := 0
            exitLatched := true

// Force flat
if state == 2 and exitType == "" and inFlatWindow and processBar
    exitType := "EOD"
    exitPx   := close
    state    := 0

// Timeout
if state == 2 and exitType == "" and not na(tEntryBar) and (bar_index - tEntryBar) >= maxBarsHold and processBar
    exitType := "TO"
    exitPx   := close
    state    := 0

// Cancel pending: expired, new day, or force-flat window.
if state == 1 and processBar and ((bar_index - tSetupBar) > breakoutWindow or newDay or inFlatWindow)
    cntExpired += 1
    if logOrders
        log.info("ORDER,expired (unfilled)")
    if showTradeMarks
        xCol = color.new(color.gray, 20)
        label.new(bar_index, tdir == 1 ? high + labelDy : low - labelDy, "✕ no fill", style = tdir == 1 ? label.style_label_down : label.style_label_up, color = xCol, textcolor = color.white, size = size.tiny)
    f_delLines()
    state      := 0
    tdir       := 0
    tEntry     := na
    tSL        := na
    tTP        := na
    tRisk      := na
    tSetupBar  := na
    tSetupTime := na
    tPatType   := 0

// Graphics on fill
if justFilled and showTradeLines and not na(lnE)
    line.set_style(lnE, line.style_solid)
if justFilled and showTradeMarks
    yPos = tdir == 1 ? high + labelDy : low - labelDy
    lblStyle = tdir == 1 ? label.style_label_down : label.style_label_up
    label.new(bar_index, yPos, (tdir == 1 ? "▲ REV L" : "▼ REV S") + "\n" + str.tostring(tEntry, format.mintick), style = lblStyle, color = color.new(tdir == 1 ? color.green : color.red, 0), textcolor = color.white, size = size.small)
if justFilled and logOrders
    log.info("ORDER,filled," + (tdir == 1 ? "LONG" : "SHORT") + "," + str.tostring(tEntry, format.mintick))

// =============================================================================
// RECORD STATS ON EXIT
// =============================================================================

if exitType != ""
    lastExitBar := bar_index
    dirAtExit = tdir
    grossPts  = dirAtExit == 1 ? (exitPx - tEntry) : (tEntry - exitPx)
    netPts    = grossPts - slipPts
    netCur    = netPts   * effPointValue * qty
    slipCur   = slipPts  * effPointValue * qty
    rNet      = tRisk != 0 ? netPts / tRisk : 0.0
    barsHeld  = na(tEntryBar) ? 0 : (bar_index - tEntryBar)
    won       = netCur > 0

    if won
        winDir     := dirAtExit
        winExitPx  := exitPx
        winExitBar := bar_index

    nTrades += 1
    if dirAtExit == 1
        nLongs += 1
    else
        nShorts += 1

    sumGrossPts += grossPts
    sumNetPts   += netPts
    sumSlipCur  += slipCur
    sumBarsInTrade += barsHeld

    if won
        nWins   += 1
        sumWinR += rNet
        grossProfitCur += netCur
        if dirAtExit == 1
            nLongWins += 1
        else
            nShortWins += 1
        curWin  += 1
        curLoss := 0
        maxWin  := math.max(maxWin, curWin)
        if netCur > largestWinCur
            largestWinCur := netCur
    else
        nLosses  += 1
        sumLossR += math.abs(rNet)
        grossLossCur += math.abs(netCur)
        curLoss += 1
        curWin  := 0
        maxLoss := math.max(maxLoss, curLoss)
        if netCur < largestLossCur
            largestLossCur := netCur

    runningR += rNet
    if runningR > peakR
        peakR := runningR
    ddR = peakR - runningR
    if ddR > maxDDR
        maxDDR := ddR

    equityCur += netCur
    if equityCur > peakEquityCur
        peakEquityCur := equityCur
    ddC = peakEquityCur - equityCur
    if ddC > maxDDcur
        maxDDcur := ddC

    if exitTieDirty
        nDirty += 1

    if showTradeMarks and barstate.isconfirmed
        exitColor = exitTieDirty ? color.new(color.orange, 0) : won ? color.new(color.green, 0) : color.new(color.red, 0)
        exitStyle = dirAtExit == 1 ? label.style_label_up : label.style_label_down
        exitY     = dirAtExit == 1 ? low - labelDy : high + labelDy
        wlTxt = (exitTieDirty ? "DIRTY " : (won ? "WIN " : "LOSS ")) + str.tostring(rNet, "#.##") + "R · " + exitType
        label.new(bar_index, exitY, text = wlTxt, style = exitStyle, color = exitColor, textcolor = color.white, size = size.small)

    if showTradeLines and not na(tEntryBar)
        leftBar  = na(tEntryBar) ? bar_index : tEntryBar
        rightBar = bar_index
        if leftBar == rightBar
            leftBar := bar_index - 1
        entCol = won ? color.new(color.green, 0) : color.new(color.red, 0)
        line.new(leftBar, tEntry, rightBar, tEntry, color = entCol,                     width = 2)
        line.new(leftBar, tSL,    rightBar, tSL,    color = color.new(color.red, 20),   width = 1, style = line.style_dashed)
        line.new(leftBar, tTP,    rightBar, tTP,    color = color.new(color.green, 20), width = 1, style = line.style_dashed)

    if enableLogs
        et = na(tEntryTime) ? time : tEntryTime
        st = na(tSetupTime) ? et : tSetupTime
        msg = "TRADE," + str.tostring(nTrades) + "," + (dirAtExit == 1 ? "LONG" : "SHORT")
        msg := msg + "," + str.format_time(st,   "yyyy-MM-dd HH:mm", sessionTz)
        msg := msg + "," + str.format_time(et,   "yyyy-MM-dd HH:mm", sessionTz)
        msg := msg + "," + str.format_time(time, "yyyy-MM-dd HH:mm", sessionTz)
        msg := msg + "," + str.tostring(tEntry, format.mintick)
        msg := msg + "," + str.tostring(tSL,    format.mintick)
        msg := msg + "," + str.tostring(tTP,    format.mintick)
        msg := msg + "," + str.tostring(exitPx, format.mintick)
        msg := msg + "," + exitType
        msg := msg + "," + str.tostring(grossPts, "#.####")
        msg := msg + "," + str.tostring(netPts,   "#.####")
        msg := msg + "," + str.tostring(rNet,     "#.###")
        msg := msg + "," + str.tostring(netCur,   "#.##")
        msg := msg + "," + str.tostring(barsHeld)
        msg := msg + "," + ibSrc
        msg := msg + "," + (exitTieDirty ? "DIRTY" : "CLEAN")
        msg := msg + "," + (won ? "WIN" : "LOSS")
        log.info(msg)

    f_delLines()
    tdir       := 0
    tEntry     := na
    tSL        := na
    tTP        := na
    tRisk      := na
    tSetupBar  := na
    tEntryBar  := na
    tSetupTime := na
    tEntryTime := na
    tPatType   := 0

// =============================================================================
// REGISTER NEW ORDER (stop-entry on reversal breakout)
// =============================================================================

occupied = state != 0
capOk    = maxTradesPerDay == 0 or tradesToday < maxTradesPerDay
coolOk   = cooldownBars == 0 or na(lastExitBar) or (bar_index - lastExitBar) >= cooldownBars
canEnter = (not blockInTrade or not occupied) and state == 0 and capOk and coolOk and inEntryWindow and not inFlatWindow and processBar and not exitLatched

// No-chase-after-win gate (per direction).
winActive    = useWinChase and not na(winExitBar) and (bar_index - winExitBar) < winChaseBars
noChaseLong  = winActive and winDir == 1  and not na(winExitPx) and longEntryLvl  >= winExitPx
noChaseShort = winActive and winDir == -1 and not na(winExitPx) and shortEntryLvl <= winExitPx

if canEnter and patternLong and not noChaseLong
    entryPx = longEntryLvl
    slPx    = slBasis == "Fixed ticks from entry" ? (entryPx - slFixedTicks * effTickSize) : (c3_low - slBuffer * effTickSize)
    riskPx  = entryPx - slPx
    if riskPx > 0
        tpPx = tpBasis == "Reversal candle range" ? (entryPx + revRange) : (entryPx + rrRatio * riskPx)
        tdir       := 1
        tEntry     := entryPx
        tSL        := slPx
        tTP        := tpPx
        tRisk      := riskPx
        tSetupBar  := bar_index
        tSetupTime := time
        tPatType   := (useHammer and isHammer) ? 1 : (useSpinning and isSpin) ? 2 : 5
        state      := 1
        cntPendingReg += 1
        if showTradeLines
            f_delLines()
            lnE := line.new(bar_index, entryPx, bar_index + 1, entryPx, color = color.blue,  width = 2, style = line.style_dotted, extend = extend.right)
            lnS := line.new(bar_index, slPx,    bar_index + 1, slPx,    color = color.red,   width = 1, style = line.style_dashed, extend = extend.right)
            lnT := line.new(bar_index, tpPx,    bar_index + 1, tpPx,    color = color.green, width = 1, style = line.style_dashed, extend = extend.right)
        if logOrders
            log.info("ORDER,placed,LONG," + str.tostring(entryPx, format.mintick) + ",SL=" + str.tostring(slPx, format.mintick) + ",TP=" + str.tostring(tpPx, format.mintick))
else if canEnter and patternShort and not noChaseShort
    entryPx = shortEntryLvl
    slPx    = slBasis == "Fixed ticks from entry" ? (entryPx + slFixedTicks * effTickSize) : (c3_high + slBuffer * effTickSize)
    riskPx  = slPx - entryPx
    if riskPx > 0
        tpPx = tpBasis == "Reversal candle range" ? (entryPx - revRange) : (entryPx - rrRatio * riskPx)
        tdir       := -1
        tEntry     := entryPx
        tSL        := slPx
        tTP        := tpPx
        tRisk      := riskPx
        tSetupBar  := bar_index
        tSetupTime := time
        tPatType   := (useStar and isStar) ? 3 : (useBearSpin and isSpin) ? 4 : 6
        state      := 1
        cntPendingReg += 1
        if showTradeLines
            f_delLines()
            lnE := line.new(bar_index, entryPx, bar_index + 1, entryPx, color = color.blue,  width = 2, style = line.style_dotted, extend = extend.right)
            lnS := line.new(bar_index, slPx,    bar_index + 1, slPx,    color = color.red,   width = 1, style = line.style_dashed, extend = extend.right)
            lnT := line.new(bar_index, tpPx,    bar_index + 1, tpPx,    color = color.green, width = 1, style = line.style_dashed, extend = extend.right)
        if logOrders
            log.info("ORDER,placed,SHORT," + str.tostring(entryPx, format.mintick) + ",SL=" + str.tostring(slPx, format.mintick) + ",TP=" + str.tostring(tpPx, format.mintick))

// =============================================================================
// OPEN POSITION PNL BANNER (top center, large)
// =============================================================================

var table openPnlTbl = table.new(position.top_center, 1, 2, bgcolor = color.new(color.black, 30), border_width = 2, border_color = color.new(color.gray, 30))

if showOpenPnl and barstate.islast and state == 2 and not na(tEntry)
    openPts   = tdir == 1 ? (close - tEntry) : (tEntry - close)
    openCur   = openPts * effPointValue * qty
    openR     = not na(tRisk) and tRisk != 0 ? openPts / tRisk : 0.0
    headTxt   = "OPEN " + (tdir == 1 ? "LONG ▲" : "SHORT ▼") + "  @ " + str.tostring(tEntry, format.mintick)
    headCol   = tdir == 1 ? color.new(color.green, 20) : color.new(color.red, 20)
    pnlCol    = openCur >= 0 ? color.new(color.lime, 0) : color.new(color.red, 0)
    pnlTxt    = (openCur >= 0 ? "+" : "") + str.tostring(openCur, "#.##") + " " + curStr + "   ·   " + (openPts >= 0 ? "+" : "") + str.tostring(openPts, format.mintick) + " pts   ·   " + (openR >= 0 ? "+" : "") + str.tostring(openR, "#.##") + " R"
    table.cell(openPnlTbl, 0, 0, headTxt, text_color = color.white, text_size = size.normal, bgcolor = headCol)
    table.cell(openPnlTbl, 0, 1, pnlTxt,  text_color = color.white, text_size = size.large,  bgcolor = pnlCol)
else
    table.cell(openPnlTbl, 0, 0, "", bgcolor = color.new(color.black, 100))
    table.cell(openPnlTbl, 0, 1, "", bgcolor = color.new(color.black, 100))

// =============================================================================
// DASHBOARD
// =============================================================================

dashPos = dashPosition == "top_right" ? position.top_right : dashPosition == "top_left" ? position.top_left : dashPosition == "bottom_right" ? position.bottom_right : dashPosition == "bottom_left" ? position.bottom_left : position.top_right

var table dash = table.new(dashPos, 2, 27, bgcolor = color.new(color.black, 75), border_width = 1, border_color = color.new(color.gray, 60))

f_row(table _t, int _r, string _lbl, string _val, color _vc) =>
    table.cell(_t, 0, _r, _lbl, text_color = color.white, text_size = size.tiny, bgcolor = color.new(color.gray, 60))
    table.cell(_t, 1, _r, _val, text_color = _vc, text_size = size.tiny)

if showDashboard and barstate.islast
    winRate    = nTrades > 0 ? nWins / nTrades * 100.0 : 0.0
    longWR     = nLongs  > 0 ? nLongWins / nLongs * 100.0 : 0.0
    shortWR    = nShorts > 0 ? nShortWins / nShorts * 100.0 : 0.0
    profitFact = grossLossCur > 0 ? grossProfitCur / grossLossCur : grossProfitCur > 0 ? 999.0 : 0.0
    avgWinCur  = nWins   > 0 ? grossProfitCur / nWins : 0.0
    avgLossCur = nLosses > 0 ? grossLossCur / nLosses : 0.0
    expR       = nTrades > 0 ? runningR / nTrades : 0.0
    expCur     = nTrades > 0 ? equityCur / nTrades : 0.0
    grossExpPts = nTrades > 0 ? sumGrossPts / nTrades : 0.0
    avgBars    = nTrades > 0 ? sumBarsInTrade / nTrades : 0

    table.cell(dash, 0, 0, "📊 REVERSAL H/S", text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 30))
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = color.white, text_size = size.tiny, bgcolor = color.new(color.blue, 30))

    sessTxt = useEntryWindow ? (inEntryWindow ? "🟢 IN window" : "🔴 OUT") : "OFF"
    sessCol = useEntryWindow ? (inEntryWindow ? color.lime : color.red) : color.gray
    f_row(dash, 1, "Entry window", sessTxt, sessCol)

    htfTxt = not useHtfFilter ? "OFF" : (htfTf + " · " + (htfBull ? "BULL" : htfBear ? "BEAR" : "—"))
    htfCol = not useHtfFilter ? color.gray : htfBull ? color.lime : color.red
    f_row(dash, 2, "HTF filter", htfTxt, htfCol)

    capTxt = str.tostring(tradesToday) + " / " + (maxTradesPerDay == 0 ? "∞" : str.tostring(maxTradesPerDay))
    f_row(dash, 3, "Trades today", capTxt, tradesToday > 0 ? color.aqua : color.gray)

    f_row(dash, 4, "Trades", str.tostring(nTrades) + "  L:" + str.tostring(nLongs) + " S:" + str.tostring(nShorts), color.white)

    wrColor = winRate >= 50 ? color.lime : winRate >= 40 ? color.orange : color.red
    f_row(dash, 5, "Win rate", str.tostring(winRate, "#.#") + "% (" + str.tostring(nWins) + "W/" + str.tostring(nLosses) + "L)", nTrades > 0 ? wrColor : color.gray)
    f_row(dash, 6, "Win rate L/S", str.tostring(longWR, "#.#") + "% / " + str.tostring(shortWR, "#.#") + "%", color.white)

    pfColor = profitFact >= 2.0 ? color.lime : profitFact >= 1.3 ? color.orange : color.red
    f_row(dash, 7, "Profit Factor", profitFact >= 999 ? "∞" : str.tostring(profitFact, "#.##"), nTrades > 0 ? pfColor : color.gray)

    pnlColor = equityCur >= 0 ? color.lime : color.red
    f_row(dash, 8, "Net PnL (" + curStr + ")", str.tostring(equityCur, "#.##"), nTrades > 0 ? pnlColor : color.gray)
    f_row(dash, 9, "Net PnL (points)", str.tostring(sumNetPts, format.mintick), nTrades > 0 ? pnlColor : color.gray)

    rColor = runningR >= 0 ? color.lime : color.red
    f_row(dash, 10, "Total R (net)", str.tostring(runningR, "#.##") + " R", nTrades > 0 ? rColor : color.gray)
    f_row(dash, 11, "Expectancy R", str.tostring(expR, "#.##") + " R", nTrades > 0 ? (expR >= 0 ? color.lime : color.red) : color.gray)
    f_row(dash, 12, "Expectancy (" + curStr + ")", str.tostring(expCur, "#.##"), nTrades > 0 ? (expCur >= 0 ? color.lime : color.red) : color.gray)
    f_row(dash, 13, "Gross exp (pts)", str.tostring(grossExpPts, format.mintick) + "  | slip " + str.tostring(slipPts, format.mintick), color.white)
    f_row(dash, 14, "Avg W / L (" + curStr + ")", "+" + str.tostring(avgWinCur, "#.#") + " / -" + str.tostring(avgLossCur, "#.#"), color.white)
    f_row(dash, 15, "Max W / L (" + curStr + ")", "+" + str.tostring(largestWinCur, "#.#") + " / " + str.tostring(largestLossCur, "#.#"), color.white)

    ddColor = maxDDcur == 0 ? color.gray : color.orange
    f_row(dash, 16, "Max DD (" + curStr + ")", "-" + str.tostring(maxDDcur, "#.##"), nTrades > 0 ? ddColor : color.gray)
    f_row(dash, 17, "Max DD (R)", "-" + str.tostring(maxDDR, "#.##") + " R", nTrades > 0 ? (maxDDR <= 3 ? color.lime : maxDDR <= 6 ? color.orange : color.red) : color.gray)
    f_row(dash, 18, "Max streak W/L", str.tostring(maxWin) + " / " + str.tostring(maxLoss), color.white)
    dirtyTxt = nTrades > 0 ? str.tostring(nDirty) + " (" + str.tostring(nDirty / nTrades * 100.0, "#.#") + "%)" : "0"
    dirtyCol = nDirty == 0 ? color.gray : color.orange
    f_row(dash, 19, "Avg bars/trade", str.tostring(avgBars), color.white)
    f_row(dash, 20, "Dirty trades (SL+TP tie)", dirtyTxt, dirtyCol)

    statusTxt = state == 0 ? "FLAT" : state == 1 ? "PENDING " + (tdir == 1 ? "LONG ▲" : "SHORT ▼") : "ACTIVE " + (tdir == 1 ? "LONG ▲" : "SHORT ▼")
    statusCol = state == 0 ? color.gray : state == 1 ? color.yellow : tdir == 1 ? color.lime : color.red
    f_row(dash, 21, "Status", statusTxt, statusCol)

    entryTxt = state == 0 ? "—" : str.tostring(tEntry, format.mintick)
    slTxt    = state == 0 ? "—" : str.tostring(tSL,    format.mintick)
    tpTxt    = state == 0 ? "—" : str.tostring(tTP,    format.mintick)
    riskTxt  = state == 0 or na(tRisk) ? "—" : str.tostring(tRisk, format.mintick) + " pts ($" + str.tostring(tRisk * effPointValue * qty, "#.##") + ")"
    f_row(dash, 22, "Entry @",   entryTxt, state == 0 ? color.gray : color.aqua)
    f_row(dash, 23, "Stop loss", slTxt,    state == 0 ? color.gray : color.new(color.red, 0))
    f_row(dash, 24, "Take profit", tpTxt,  state == 0 ? color.gray : color.new(color.green, 0))
    f_row(dash, 25, "Risk", riskTxt, state == 0 ? color.gray : color.white)
    ncTxt = not useWinChase ? "OFF" : not winActive ? "—" : (winDir == 1 ? "blocks longs ≥ " : "blocks shorts ≤ ") + str.tostring(winExitPx, format.mintick) + " (" + str.tostring(winChaseBars - (bar_index - winExitBar)) + "b left)"
    ncCol = not useWinChase ? color.gray : not winActive ? color.gray : color.orange
    f_row(dash, 26, "No-chase", ncTxt, ncCol)

// =============================================================================
// DIAGNOSTIC PANEL
// =============================================================================

var table diag = table.new(position.bottom_right, 2, 18, bgcolor = color.new(color.navy, 75), border_width = 1, border_color = color.new(color.gray, 60))

if showDiagnostic and barstate.islast
    table.cell(diag, 0, 0, "🔍 DIAGNOSTIC", text_color = color.white, text_size = size.small, bgcolor = color.new(color.purple, 30))
    table.cell(diag, 1, 0, "count", text_color = color.white, text_size = size.tiny, bgcolor = color.new(color.purple, 30))

    f_row(diag, 1, "Reversal candles",   str.tostring(cntReversal),     cntReversal > 0 ? color.aqua : color.red)
    f_row(diag, 2, "Pattern LONG",       str.tostring(cntPatternLong),  cntPatternLong > 0 ? color.lime : color.red)
    f_row(diag, 3, "Pattern SHORT",      str.tostring(cntPatternShort), cntPatternShort > 0 ? color.red : color.gray)
    f_row(diag, 4, "Hammer / B.Spin L",  str.tostring(cntHammer) + " / " + str.tostring(cntSpinL), color.white)
    f_row(diag, 5, "Star / B.Spin S",    str.tostring(cntStar) + " / " + str.tostring(cntSpinS), color.white)
    f_row(diag, 6, "Orders placed",      str.tostring(cntPendingReg),   cntPendingReg > 0 ? color.lime : color.gray)
    f_row(diag, 7, "Filled",             str.tostring(cntFilled),       cntFilled > 0 ? color.lime : color.red)
    f_row(diag, 8, "Expired",            str.tostring(cntExpired),      cntExpired > 0 ? color.orange : color.gray)
    fillRate = cntPendingReg > 0 ? cntFilled / cntPendingReg * 100.0 : 0.0
    f_row(diag, 9, "Fill rate",          str.tostring(fillRate, "#.#") + "%", cntPendingReg > 0 ? (fillRate >= 50 ? color.lime : color.orange) : color.gray)
    f_row(diag, 10, "Intrabar source",   ibSrc, ibSrc == "1m" ? color.lime : ibSrc == "OHLC" or ibSrc == "OFF" ? color.orange : color.aqua)
    f_row(diag, 11, "Trend context",     trendMode, color.white)
    f_row(diag, 12, "Entry ref",         entryRef == "Reversal candle" ? "rev candle" : "prev candle", color.white)
    f_row(diag, 13, "SL · TP basis",     (slBasis == "Fixed ticks from entry" ? "fixed" : "rev end") + " · " + (tpBasis == "Reversal candle range" ? "rev range" : str.tostring(rrRatio, "#.#") + "R"), color.white)
    structTxt = not useStructFilter ? "OFF" : str.tostring(structN) + " bars, skip " + str.tostring(structM)
    f_row(diag, 14, "Struct filter (N/M)", structTxt, useStructFilter ? color.aqua : color.gray)
    rsiTxt = not useRsiFilter ? "OFF" : str.tostring(rsiV, "#.#") + "  (OS " + str.tostring(rsiOS, "#") + " / OB " + str.tostring(rsiOB, "#") + ")"
    rsiCol = not useRsiFilter ? color.gray : (rsiV <= rsiOS ? color.lime : rsiV >= rsiOB ? color.red : color.white)
    f_row(diag, 15, "RSI", rsiTxt, rsiCol)
    strTxt = not useStretchFilter ? "OFF" : (na(stretchAtrNow) ? "—" : str.tostring(stretchAtrNow, "#.##") + " ATR (min " + str.tostring(minStretchAtr, "#.#") + ")")
    f_row(diag, 16, "Stretch vs MA" + str.tostring(maStretchLen), strTxt, useStretchFilter ? color.aqua : color.gray)
    f_row(diag, 17, "Engulf L / S", str.tostring(cntEngL) + " / " + str.tostring(cntEngS), (cntEngL + cntEngS) > 0 ? color.aqua : color.gray)

// =============================================================================
// ALERTS
// =============================================================================
occupiedNow = state != 0
patLongAlert  = patternLong  and (not blockInTrade or not occupiedNow) and canEnter
patShortAlert = patternShort and (not blockInTrade or not occupiedNow) and canEnter
alertcondition(patLongAlert,  title = "Reversal LONG",  message = "Reversal Hammer/Spinning Top LONG on {{ticker}} · {{interval}}")
alertcondition(patShortAlert, title = "Reversal SHORT", message = "Reversal Shooting Star/Inverted Hammer SHORT on {{ticker}} · {{interval}}")
alertcondition(state == 1 and nz(state[1], 0) == 0, title = "Stop order placed", message = "Reversal Breakout: stop-entry order placed on {{ticker}}")
````
