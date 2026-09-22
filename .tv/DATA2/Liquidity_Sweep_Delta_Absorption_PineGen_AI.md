<!-- tradingview-pine-id: PUB;94365a2d53d14b3cb25b0143d321562e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep + Delta Absorption [PineGen AI]

Source: https://www.tradingview.com/script/OvE4qQgh-Liquidity-Sweep-Delta-Absorption-PineGen-AI/

## Description

Overview
This strategy looks for one specific institutional footprint: a liquidity sweep of a confirmed swing high or low that gets absorbed rather than continuing. Price wicks through a recent swing point, but instead of running with the breakout, the same bar shows elevated volume and a volume-delta signature that leans against the sweep — a sign the aggressive orders that took out the level got absorbed by resting liquidity on the other side.

[image]https://www.tradingview.com/x/x3GrBsw4/[/image]

How It Works
1. Liquidity levels — the script tracks the most recently confirmed swing high and swing low (ta.pivothigh/ta.pivotlow), not session or daily levels, so setups can occur on any market and any session.
2. Sweep — a bar's wick pierces one of those levels and its close comes back inside it.
3. Absorption confirmation — the sweep bar must also show volume above its own average, a close back toward the opposite end of its range, and a volume-delta proxy that leans against the sweep direction. The delta is built from lower-timeframe up/down volume, since Pine Script has no access to real exchange bid/ask tape on standard data feeds — that's disclosed here, not glossed over.
4. Optional one-bar confirmation candle, optional EMA trend filter, and an adjustable session window (defaults to the 09:30–12:00 ET US session).
5. Risk: ATR-buffered stop beyond the sweep wick, a configurable reward:risk target, and a daily trade cap to prevent overtrading.

[image]https://www.tradingview.com/x/0IATP57a/[/image]

Key Features
- Non-repainting: signals only evaluate on a confirmed bar; swing levels only update once a pivot is fully confirmed.
- Long and short, independently toggleable.
- Adjustable liquidity-level lookback, volume filter, delta filter, trend filter, session window, and risk settings.
- Built-in alerts for both bullish and bearish setups.

Backtest Disclosure (as shown)
Tested on BTCUSDT, 2h chart, Jan 1 2022 – Sep 19 2026, default settings, $10,000 initial capital, 10% of equity per trade, 0.02% commission, 2-tick slippage:
- Net profit: +$568.41 (+5.68%)
- Max drawdown: $211.64 (2.02%)
- Win rate: 47.83% (11/23 trades)
- Profit factor: 2.23

Important Notes
- This is a backtesting and research tool. Past performance does not guarantee future results.
- The default session window (09:30–12:00 ET) is tuned for US index/futures and FX/gold day trading — adjust or disable it for other markets.
- The "Order Flow Lower Timeframe" input must be smaller than your chart's timeframe (e.g. "1" on a 5–15 min chart), or TradingView will throw a lower-timeframe error.

How to Use
Add the strategy to your chart, open the Strategy Tester tab to review the full report, then use the Settings panel to tune the swing lookback, volume/delta thresholds, session window, and risk inputs to your market.

Disclaimer
This script is for educational and informational purposes only and is not financial advice. Trading involves substantial risk of loss. Backtested results do not guarantee future performance.**Overview**
This strategy looks for one specific institutional footprint: a liquidity sweep of a confirmed swing high or low that gets absorbed rather than continuing. Price wicks through a recent swing point, but instead of running with the breakout, the same bar shows elevated volume and a volume-delta signature that leans against the sweep — a sign the aggressive orders that took out the level got absorbed by resting liquidity on the other side.

How It Works
1. Liquidity levels — the script tracks the most recently confirmed swing high and swing low (ta.pivothigh/ta.pivotlow), not session or daily levels, so setups can occur on any market and any session.
2. Sweep — a bar's wick pierces one of those levels and its close comes back inside it.
3. Absorption confirmation — the sweep bar must also show volume above its own average, a close back toward the opposite end of its range, and a volume-delta proxy that leans against the sweep direction. The delta is built from lower-timeframe up/down volume, since Pine Script has no access to real exchange bid/ask tape on standard data feeds — that's disclosed here, not glossed over.
4. Optional one-bar confirmation candle, optional EMA trend filter, and an adjustable session window (defaults to the 09:30–12:00 ET US session).
5. Risk: ATR-buffered stop beyond the sweep wick, a configurable reward:risk target, and a daily trade cap to prevent overtrading.

Key Features
- Non-repainting: signals only evaluate on a confirmed bar; swing levels only update once a pivot is fully confirmed.
- Long and short, independently toggleable.
- Adjustable liquidity-level lookback, volume filter, delta filter, trend filter, session window, and risk settings.
- Built-in alerts for both bullish and bearish setups.

Backtest Disclosure (as shown)
Tested on BTCUSDT, 2h chart, Jan 1 2022 – Sep 19 2026, default settings, $10,000 initial capital, 10% of equity per trade, 0.02% commission, 2-tick slippage:
- Net profit: +$568.41 (+5.68%)
- Max drawdown: $211.64 (2.02%)
- Win rate: 47.83% (11/23 trades)
- Profit factor: 2.23

23 trades over roughly 4.7 years is a small sample — enough to show the logic behaves as designed, not enough on its own to draw strong conclusions about edge. Test it on your own instrument, timeframe, and date range before sizing it.

Important Notes
- This is a backtesting and research tool. Past performance does not guarantee future results.
- The default session window (09:30–12:00 ET) is tuned for US index/futures and FX/gold day trading — adjust or disable it for other markets.
- The "Order Flow Lower Timeframe" input must be smaller than your chart's timeframe (e.g. "1" on a 5–15 min chart), or TradingView will throw a lower-timeframe error.

How to Use
Add the strategy to your chart, open the Strategy Tester tab to review the full report, then use the Settings panel to tune the swing lookback, volume/delta thresholds, session window, and risk inputs to your market before using it live or basing alerts on it.

Disclaimer
This script is for educational and informational purposes only and is not financial advice. Trading involves substantial risk of loss. Backtested results do not guarantee future performance.

---

## Source Code

````pine
// Liquidity Sweep + Delta Absorption [PineGen AI]
// ---------------------------------------------------------------------------
// WHAT THIS DOES
// Detects a liquidity sweep of a recent swing high/low (a wick that pierces
// the level and closes back inside it), then requires that sweep to show
// volume-delta ABSORPTION before taking a trade: elevated participation on
// the sweep bar, but the bar closes back in the opposite direction instead
// of continuing through the level. That combination is meant to filter out
// the single biggest complaint on plain liquidity-sweep and plain
// volume-delta scripts: too many false signals from a wick alone.
//
// HONEST LIMITS (read before you trade this)
// - "Delta" here is a LOWER-TIMEFRAME VOLUME PROXY, not real exchange bid/ask
//   tape data. It sums lower-timeframe candles inside each chart bar and
//   buckets their volume as "up" (close >= open) or "down" (close < open).
//   That is a widely-used approximation, not true order-flow data. Pine
//   Script has no access to real bid/ask tape on standard data feeds.
// - This is a backtesting/educational tool. The Strategy Tester report shows
//   how these exact rules would have performed on historical data with the
//   commission/slippage assumptions set below — it is not a promise of
//   future profit, and no set of inputs "guarantees" a win rate.
// - Entries are evaluated only on confirmed bars (barstate.isconfirmed) and
//   swing levels only update once a pivot is confirmed (swingRight bars
//   later), so this strategy does not repaint its signals after the fact.
// - The "Order Flow Lower Timeframe" input MUST be smaller than your chart's
//   timeframe (e.g. "1" on a 5-15min chart). If TradingView throws a lower-
//   timeframe error, raise your chart timeframe or lower this input.
// - Built and tested with US index/futures and FX/gold day trading in mind
//   (NQ1!, ES1!, XAUUSD, EURUSD, GBPUSD) on intraday timeframes. Test any
//   other market/timeframe combination on its own merits before using it.
// ---------------------------------------------------------------------------

//@version=6
strategy(title="Liquidity Sweep + Delta Absorption [PineGen AI]",
     shorttitle="LSDA [PineGen AI]",
     overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=10,
     commission_type=strategy.commission.percent,
     commission_value=0.02,
     slippage=2,
     pyramiding=0,
     calc_on_every_tick=false)

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------

// -- Liquidity Levels --
swingLeft  = input.int(5, "Swing Left Bars", minval=1, group="Liquidity Levels",
     tooltip="Bars to the left required to confirm a swing high/low.")
swingRight = input.int(5, "Swing Right Bars", minval=1, group="Liquidity Levels",
     tooltip="Bars to the right required to confirm a swing high/low. Higher = more reliable levels, but confirmed later.")

// -- Order Flow / Absorption --
useVolFilter    = input.bool(true, "Require Volume Spike", group="Order Flow / Absorption")
volLookback     = input.int(20, "Volume Average Lookback", minval=5, group="Order Flow / Absorption")
volMultiplier   = input.float(1.5, "Volume Spike Multiplier", minval=1.0, step=0.1, group="Order Flow / Absorption")
closePosThresh  = input.float(0.65, "Absorption Close Position (0.5-0.95)", minval=0.5, maxval=0.95, step=0.05, group="Order Flow / Absorption",
     tooltip="How close to the opposite end of the bar's range the close must be to count as absorption.")
useDeltaFilter  = input.bool(true, "Require Volume-Delta Confirmation", group="Order Flow / Absorption")
deltaTF         = input.timeframe("1", "Order Flow Lower Timeframe", group="Order Flow / Absorption",
     tooltip="Must be smaller than the chart timeframe. Example: '1' on a 5-15min chart.")
minAbsDelta     = input.float(0, "Minimum Net Delta at Sweep", minval=0, group="Order Flow / Absorption",
     tooltip="0 = delta just has to lean the right way. Raise this to demand a stronger absorption signature.")

// -- Entry Filters --
requireConfirmClose = input.bool(true, "Wait for Confirmation Candle", group="Entry Filters",
     tooltip="If on, waits one extra bar and requires it to close in the reversal direction before entering. Off = enter on the absorption bar itself (more trades, less filtering).")
useTrendFilter  = input.bool(false, "Use EMA Trend Filter", group="Entry Filters")
trendLen        = input.int(200, "Trend EMA Length", minval=10, group="Entry Filters")
allowLong       = input.bool(true, "Allow Long Trades", group="Entry Filters")
allowShort      = input.bool(true, "Allow Short Trades", group="Entry Filters")

// -- Session Filter --
useSession   = input.bool(true, "Restrict Entries to Session Window", group="Session Filter")
sessionWindow = input.session("0930-1200", "Session Window", group="Session Filter")
sessionTZ    = input.string("America/New_York", "Session Timezone", group="Session Filter")

// -- Risk Management --
atrLen          = input.int(14, "ATR Length", minval=1, group="Risk Management")
atrMult         = input.float(1.5, "Stop Buffer (x ATR beyond wick)", minval=0, step=0.1, group="Risk Management")
rr              = input.float(2.0, "Reward:Risk Ratio", minval=0.5, step=0.1, group="Risk Management")
maxTradesPerDay = input.int(2, "Max Trades Per Day (0 = unlimited)", minval=0, group="Risk Management")

// ---------------------------------------------------------------------------
// LIQUIDITY LEVELS (confirmed swing points)
// ---------------------------------------------------------------------------
ph = ta.pivothigh(high, swingLeft, swingRight)
pl = ta.pivotlow(low, swingLeft, swingRight)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(ph)
    lastSwingHigh := ph
if not na(pl)
    lastSwingLow := pl

// ---------------------------------------------------------------------------
// VOLUME-DELTA PROXY (lower-timeframe up/down volume aggregation)
// ---------------------------------------------------------------------------
[ltOpen, ltClose, ltVolume] = request.security_lower_tf(syminfo.tickerid, deltaTF, [open, close, volume])

float upVol = 0.0
float dnVol = 0.0
n = array.size(ltClose)
if n > 0
    for i = 0 to n - 1
        c = array.get(ltClose, i)
        o = array.get(ltOpen, i)
        v = array.get(ltVolume, i)
        if c >= o
            upVol += v
        else
            dnVol += v

netDelta = upVol - dnVol

// ---------------------------------------------------------------------------
// SWEEP + ABSORPTION DETECTION
// ---------------------------------------------------------------------------
bullishSweep = not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow
bearishSweep = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh

rangeSize = high - low
closePos  = rangeSize > 0 ? (close - low) / rangeSize : 0.5

bullishAbsorptionCandle = closePos >= closePosThresh
bearishAbsorptionCandle = closePos <= (1 - closePosThresh)

volAvg   = ta.sma(volume, volLookback)
volSpike = volume > volAvg * volMultiplier

volumeOkBull = not useVolFilter or volSpike
volumeOkBear = not useVolFilter or volSpike

deltaOkBull = not useDeltaFilter or netDelta >= minAbsDelta
deltaOkBear = not useDeltaFilter or netDelta <= -minAbsDelta

bullishAbsorption = bullishSweep and bullishAbsorptionCandle and volumeOkBull and deltaOkBull and barstate.isconfirmed
bearishAbsorption = bearishSweep and bearishAbsorptionCandle and volumeOkBear and deltaOkBear and barstate.isconfirmed

// ---------------------------------------------------------------------------
// TREND / SESSION / DIRECTION FILTERS
// ---------------------------------------------------------------------------
trendEma   = ta.ema(close, trendLen)
trendOkBull = not useTrendFilter or close > trendEma
trendOkBear = not useTrendFilter or close < trendEma

inSession = not useSession or not na(time(timeframe.period, sessionWindow, sessionTZ))

rawLongSignal  = bullishAbsorption and trendOkBull and inSession and allowLong
rawShortSignal = bearishAbsorption and trendOkBear and inSession and allowShort

// ---------------------------------------------------------------------------
// OPTIONAL ONE-BAR CONFIRMATION
// ---------------------------------------------------------------------------
var bool  pendingLong     = false
var bool  pendingShort    = false
var float pendingLongLow  = na
var float pendingShortHigh = na

if rawLongSignal
    pendingLong := true
    pendingLongLow := low
if rawShortSignal
    pendingShort := true
    pendingShortHigh := high

confirmedLong  = pendingLong[1]  and close > open  and barstate.isconfirmed
confirmedShort = pendingShort[1] and close < open  and barstate.isconfirmed

if pendingLong[1]
    pendingLong := false
if pendingShort[1]
    pendingShort := false

finalLong  = requireConfirmClose ? confirmedLong  : rawLongSignal
finalShort = requireConfirmClose ? confirmedShort : rawShortSignal

sweepLowForStop  = pendingLongLow
sweepHighForStop = pendingShortHigh

// ---------------------------------------------------------------------------
// DAILY TRADE CAP
// ---------------------------------------------------------------------------
var int tradesToday = 0
if ta.change(time("D")) != 0
    tradesToday := 0
dailyLimitOk = maxTradesPerDay == 0 or tradesToday < maxTradesPerDay

// ---------------------------------------------------------------------------
// RISK MANAGEMENT + ENTRIES
// ---------------------------------------------------------------------------
atrVal = ta.atr(atrLen)

if finalLong and strategy.position_size == 0 and dailyLimitOk and not na(sweepLowForStop)
    longStop   = sweepLowForStop - atrVal * atrMult
    riskDist   = close - longStop
    longTarget = close + riskDist * rr
    if riskDist > 0
        strategy.entry("Long", strategy.long)
        strategy.exit("Long Exit", from_entry="Long", stop=longStop, limit=longTarget)
        tradesToday += 1

if finalShort and strategy.position_size == 0 and dailyLimitOk and not na(sweepHighForStop)
    shortStop   = sweepHighForStop + atrVal * atrMult
    riskDist2   = shortStop - close
    shortTarget = close - riskDist2 * rr
    if riskDist2 > 0
        strategy.entry("Short", strategy.short)
        strategy.exit("Short Exit", from_entry="Short", stop=shortStop, limit=shortTarget)
        tradesToday += 1

// ---------------------------------------------------------------------------
// PLOTTING
// ---------------------------------------------------------------------------
plot(lastSwingHigh, title="Last Swing High (Sell-Side Liquidity)", color=color.new(color.red, 40), style=plot.style_linebr, linewidth=1)
plot(lastSwingLow,  title="Last Swing Low (Buy-Side Liquidity)",  color=color.new(color.green, 40), style=plot.style_linebr, linewidth=1)

plotshape(bullishAbsorption, title="Bullish Absorption", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), size=size.small)
plotshape(bearishAbsorption, title="Bearish Absorption", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small)

bgcolor(useSession and inSession ? color.new(color.blue, 92) : na, title="Session Window")

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
alertcondition(rawLongSignal,  title="Bullish Liquidity Sweep + Absorption", message="Bullish liquidity sweep with delta absorption on {{ticker}} {{interval}}")
alertcondition(rawShortSignal, title="Bearish Liquidity Sweep + Absorption", message="Bearish liquidity sweep with delta absorption on {{ticker}} {{interval}}")
````
