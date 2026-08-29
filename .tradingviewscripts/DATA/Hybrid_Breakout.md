<!-- tradingview-pine-id: PUB;beed47f76cb34f9b8c25a5feb6fcc3f7 -->
<!-- tradingviewscripts-format: 1 -->
# Hybrid Breakout

Source: https://www.tradingview.com/script/hezSShJr-Hybrid-Breakout-VCP-Inspired-Trend/

## Description

Trend Squeeze Breakout

Trend Squeeze Breakout is a trend-following momentum strategy designed to identify stocks in strong established uptrends that are consolidating into relatively tight trading ranges before attempting a breakout.

The strategy combines a simplified Minervini-style trend template, volatility contraction, volume confirmation, and stop-entry breakout execution. It is designed primarily for swing trading and is intended to participate in strong upward price expansions while filtering out many breakouts occurring in weak or declining trends.

Strategy Explanation
The strategy follows a simple sequence:
Identify a strong uptrend
A long setup requires:

[*]Price above the 50-period SMA
[*]50 SMA above the 150 SMA
[*]150 SMA above the 200 SMA
[*]200 SMA rising
[*]200 SMA continuing to rise over the selected lookback period
[*]50 SMA not declining

This establishes that the stock is already in a structurally bullish environment before considering an entry.

Identify a volatility contraction
The strategy looks for periods where recent price movement has become unusually tight.
It evaluates both:

[*]Recent high-low range
[*]Recent closing-price range

The high-low range is also compared with its historical percentile over the selected lookback period. This allows the strategy to identify relatively quiet consolidation periods rather than relying on a fixed volatility threshold alone.

Confirm volume
When the volume filter is enabled, breakout volume must exceed the moving-average volume baseline by the selected multiplier.
The default requirement is:

[*]Volume > 20-period average volume × 1.2

This is intended to provide additional confirmation that the breakout is supported by meaningful participation.

Enter on a breakout
When the trend, contraction, and volume conditions are satisfied, the strategy places a stop-entry order above the recent high.

The default breakout lookback is 3 bars, allowing the strategy to attempt to enter as price moves through the recent consolidation high rather than simply buying while the stock remains inside the range.

Manage the position
Positions use tiered profit-taking:

[*]25% closed at +10%
[*]50% closed at +20%
[*]Remaining position closed at +30%
[*]Default stop loss at -8%

This allows the strategy to realize some profits during the initial move while maintaining exposure to larger momentum extensions.

Features

[*]Trend Filter — 50/150/200 SMA bullish alignment
[*]Long-Term Trend Confirmation — Requires the 200 SMA to be rising
[*]Volatility Squeeze Detection — Identifies unusually tight recent ranges
[*]Range Percentile Filter — Compares current volatility with historical volatility
[*]Close-Range Filter — Detects tight price consolidation
[*]Volume Confirmation — Optional volume expansion requirement
[*]Stop-Entry Breakout — Enters only when price breaks the recent high
[*]Tiered Profit Taking — Three configurable profit targets
[*]Percentage-Based Stop Loss — Adjustable downside protection
[*]Date Filter — Allows users to restrict backtests to a specific period
[*]Configurable Parameters — Trend, volatility, volume, breakout, and risk settings can all be adjusted

Tips for Use

Use on liquid stocks
The strategy is generally better suited to liquid stocks and ETFs with sufficient trading volume. Extremely illiquid securities can produce unrealistic backtest results because of spreads and execution differences.

Start with daily charts
The strategy is particularly suited to identifying multi-day or multi-week momentum breakouts. Daily charts are a good starting point when evaluating the strategy.

Avoid optimizing every parameter
The many adjustable parameters make it possible to overfit the strategy to a particular stock or historical period. Test parameter changes across multiple securities and different market environments rather than optimizing exclusively for one chart.

Treat the volume filter as confirmation, not a guarantee
High volume can strengthen a breakout signal, but it does not guarantee that the breakout will succeed.

Test across different market conditions
Trend-following breakout systems typically perform differently during strong bull markets, corrections, sideways markets, and high-volatility periods. Evaluate results across multiple market regimes before relying on the strategy.

Pay attention to execution
The strategy uses stop-entry orders above recent highs. In live trading, gaps, slippage, spreads, and intrabar price movement can cause actual execution prices to differ from backtested results.

Important Note
This strategy is inspired by trend-template and volatility-contraction concepts, but it is not a complete implementation of a textbook VCP. It uses a simplified statistical contraction model rather than explicitly identifying multiple successive contractions, contraction depths, and their associated volume characteristics.

Backtest results are hypothetical and do not guarantee future performance. Always consider commissions, slippage, liquidity, position sizing, and market conditions when evaluating a strategy.

Recommended starting configuration: Daily timeframe, liquid stocks, default trend filter, volume confirmation enabled, and the default tiered risk-management settings.

---

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at
// https://mozilla.org/MPL/2.0/.
// Derived from prior work by stockone1231 and perrycc007 (MPL-2.0).
// Modifications: Simplified Trend + Volatility-Squeeze Breakout Strategy

strategy("Hybrid Breakout", overlay=true, initial_capital=100000,
     default_qty_type=strategy.percent_of_equity, default_qty_value=100,
     commission_type=strategy.commission.percent, commission_value=0.05,
     process_orders_on_close=true)

// ============================================================
// INPUTS
// ============================================================
grpTrend = "Trend Filter"
src    = input.source(close, "MA Source", group=grpTrend)
len50  = input.int(50,  "Fast MA Length",  group=grpTrend)
len150 = input.int(150, "Mid MA Length",   group=grpTrend)
len200 = input.int(200, "Slow MA Length",  group=grpTrend)
maUpLookback = input.int(20, "Bars Slow MA Must Be Rising Over", group=grpTrend)

grpVola = "Volatility / Pivot Filter"
atrLen        = input.int(3,   "Range Length", group=grpVola)
lookback      = input.int(150, "Percentile Lookback", group=grpVola)
percentileMax = input.int(40,  "Max Range Percentile (Squeeze)", minval=1, maxval=100, group=grpVola)
closeRangeMax = input.float(4, "Max Close-Range % (Tight Squeeze)", group=grpVola)

grpVol = "Volume Filter"
useVolFilter = input.bool(true, "Require Volume Expansion on Breakout", group=grpVol)
volMaLen     = input.int(20, "Volume MA Length", group=grpVol)
volMult      = input.float(1.2, "Volume Must Exceed MA x", minval=1.0, step=0.1, group=grpVol)

grpEntry = "Entry"
breakoutLookback = input.int(3, "Stop-Entry High Lookback", minval=1, group=grpEntry)

grpRisk = "Risk Management"
stopLossPct = input.float(8.0,  "Stop Loss %",     minval=0.1, group=grpRisk) / 100
take1Pct    = input.float(10.0, "Take Profit 1 %", minval=0.1, group=grpRisk) / 100
take2Pct    = input.float(20.0, "Take Profit 2 %", minval=0.1, group=grpRisk) / 100
take3Pct    = input.float(30.0, "Take Profit 3 %", minval=0.1, group=grpRisk) / 100

grpDate = "Date Range"
startDate = input.time(timestamp("2018-01-01"), "Start", group=grpDate)
endDate   = input.time(timestamp("2099-01-01"), "End",   group=grpDate)
inDateRange = time >= startDate and time <= endDate

// ============================================================
// TREND TEMPLATE (simplified Minervini-style MA alignment)
// ============================================================
ma50  = ta.sma(src, len50)
ma150 = ta.sma(src, len150)
ma200 = ta.sma(src, len200)

bullishTrend = close > ma50 and ma50 > ma150 and ma150 > ma200 and
     ma200 > ma200[1] and ma200 > ma200[maUpLookback] and ma50 >= ma50[1]

// ============================================================
// VOLATILITY SQUEEZE / PIVOT DETECTION
// ============================================================
hRange = ta.highest(high, atrLen)
lRange = ta.lowest(low, atrLen)
rangePct = (hRange - lRange) / hRange * 100

hClose = ta.highest(close, atrLen)
lClose = ta.lowest(close, atrLen)
closeRangePct = (hClose - lClose) / hClose * 100

rangePercentile = ta.percentrank(rangePct, lookback)

rangeSqueeze = rangePercentile <= percentileMax
closeSqueeze = closeRangePct <= closeRangeMax
pivot = rangeSqueeze or closeSqueeze

// ============================================================
// VOLUME CONFIRMATION
// ============================================================
volMa = ta.sma(volume, volMaLen)
volumeOK = not useVolFilter or volume > volMa * volMult

// ============================================================
// ENTRY
// ============================================================
recentHigh = ta.highest(high, breakoutLookback)

longSignal = bullishTrend and pivot and volumeOK and inDateRange

if longSignal and strategy.position_size == 0
    strategy.entry("Long", strategy.long, stop=recentHigh[1])

// ============================================================
// EXIT MANAGEMENT (tiered stop / take-profit)
// ============================================================
avgPrice = strategy.position_avg_price
stopLevel = avgPrice * (1 - stopLossPct)
target1   = avgPrice * (1 + take1Pct)
target2   = avgPrice * (1 + take2Pct)
target3   = avgPrice * (1 + take3Pct)

if strategy.position_size > 0
    strategy.exit("TP1", "Long", qty_percent=25,  stop=stopLevel, limit=target1)
    strategy.exit("TP2", "Long", qty_percent=50,  stop=stopLevel, limit=target2)
    strategy.exit("TP3", "Long", qty_percent=100, stop=stopLevel, limit=target3)

// ============================================================
// VISUALS
// ============================================================
plot(ma50,  "MA 50",  color=color.blue)
plot(ma150, "MA 150", color=color.green)
plot(ma200, "MA 200", color=color.red)

bgcolor(pivot and bullishTrend ? color.new(color.yellow, 80) : na, title="Setup Zone")

plotshape(longSignal and strategy.position_size == 0, title="Setup",
     style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.tiny)
````
