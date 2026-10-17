# Adaptive Trend Pulse Pro [JPT]

- url: https://www.tradingview.com/script/yiBe8gPR-Adaptive-Trend-Pulse-Pro-JPT/
- type: indicator
- pine_id: PUB;cb703affb89a44d396e371e4a0ce0338
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]

[b]Adaptive Trend Pulse Pro [JPT][/b] is a professional trend-following and trade-management indicator designed to help traders identify confirmed market direction, filter weaker setups, and structure potential trades with predefined Entry, Stop Loss, and Take Profit levels.

The system combines an adaptive trend engine, EMA confirmation, RSI momentum, volume analysis, candle momentum, signal scoring, ATR-based risk management, and multi-market monitoring into one streamlined TradingView indicator.

It is designed for traders who want a cleaner way to evaluate trend transitions without relying on a single indicator or isolated signal.

🔷 [b]CORE CONCEPT[/b]

The indicator follows a simple principle:

Detect the trend → Confirm the setup → Score the signal → Define risk → Manage the trade.

Instead of treating every trend change as an immediate trading opportunity, the system applies additional confirmation filters before displaying a potential LONG or SHORT setup.

This helps make the signals more selective and provides a structured framework for discretionary trading.

🔷 [b]SIGNAL ENGINE[/b]

The Adaptive Trend Engine continuously evaluates price movement and volatility to determine the current market direction.

🟢 [b]LONG Environment[/b]

A bullish environment is identified when the adaptive trend structure shifts upward.

Additional confirmation can come from:

Price above the EMA
RSI bullish momentum
Above-average volume
Bullish candle momentum
Confirmed candle close

🔴 [b]SHORT Environment[/b]

A bearish environment is identified when the adaptive trend structure shifts downward.

Additional confirmation can come from:

Price below the EMA
RSI bearish momentum
Above-average volume
Bearish candle momentum
Confirmed candle close

🔷 [b]SIGNAL SCORE[/b]

The indicator includes a Signal Score designed to help distinguish stronger setups from weaker ones.

The score evaluates multiple conditions rather than relying on trend direction alone.

Higher score = stronger confirmation.

Users can adjust the Minimum Signal Score depending on their preferred trading style.

Suggested approach

3/4 — Balanced

More opportunities while still requiring confirmation.

4/4 — Strict

Fewer signals with stronger confirmation requirements.

🔷 [b]ENTRY SYSTEM[/b]

When a confirmed LONG or SHORT setup appears, the indicator automatically establishes an approximate trading entry based on the confirmed signal candle.

LONG

LONG → Entry → Stop Loss → TP1 → TP2 → TP3

SHORT

SHORT → Entry → Stop Loss → TP1 → TP2 → TP3

The levels are dynamically calculated from current market volatility.

🔷 [b]STOP LOSS[/b]

The Stop Loss is calculated using ATR-based volatility.

This allows the distance to adapt to the market rather than using one fixed number of points.

The Stop ATR Multiplier can be adjusted according to the market and timeframe.

A higher multiplier provides a wider volatility allowance.

A lower multiplier creates a tighter risk level.

🔷 TAKE PROFIT SYSTEM

The indicator provides three structured targets:

🎯 TP1 — 1R

First objective.

🎯 TP2 — 2R

Second objective.

🎯 TP3 — 3R

Extended objective.

The R-multiple is based on the distance between Entry and the initial Stop Loss.

Example:

Entry = 100
Stop = 98

Risk = 2 points.

Therefore:

TP1 = 102
TP2 = 104
TP3 = 106

🔷 [b]BREAK-EVEN MANAGEMENT[/b]

After TP1 is reached, the indicator can move the active Stop Loss toward the original Entry level.

This allows traders to protect the position after the first objective has been reached.

TP1 → Break-Even → TP2 → TP3

This feature can be enabled or disabled from the settings.

🔷 [b]ATR TRAILING STOP[/b]

After TP2, an optional ATR trailing mechanism can be activated.

The trailing stop dynamically follows price based on current volatility.

This is intended to help protect open profit while allowing the trend enough room to continue.

🔷 [b]RISK / REWARD ZONES[/b]

The chart can display visual risk/reward areas around an active setup.

The zones help traders immediately see:

🟢 Potential reward area
🔴 Risk area
⚪ Entry level

This makes it easier to visually evaluate the trade structure before taking action.

🔷 [b]MULTI-ASSET SCANNER[/b]

The dashboard can monitor multiple markets simultaneously.

Example:

BTCUSDT — LONG
ETHUSDT — LONG
SOLUSDT — NEUTRAL
EURUSD — SHORT
XAUUSD — LONG

This allows traders to quickly compare market conditions without opening multiple charts.

🔷 [b]PERFORMANCE DASHBOARD[/b]

The indicator includes a compact dashboard showing information such as:

Signal Score
Win Rate
Wins
Losses
Break-Even trades
Closed Trades
Current Trade Status

The dashboard is intended as a reference tool rather than a guarantee of future performance.

🔷 [b]ALERT SYSTEM[/b]

Alerts are available for important events including:

🔔 LONG confirmation
🔔 SHORT confirmation
🔔 TP1 reached
🔔 TP2 reached
🔔 TP3 reached
🔔 Stop level reached

This allows traders to monitor setups without constantly watching the chart.

🔷 [b]CONFIRMED SIGNAL LOGIC[/b]

The indicator uses confirmed-bar logic for its primary LONG and SHORT signals.

Signals are therefore intended to be confirmed at candle close rather than triggering from an unfinished candle.

However, this does not eliminate normal market risk or guarantee that every historical signal will behave the same way in live trading.

🔷 [b]RECOMMENDED MARKETS[/b]

The system can be tested on a variety of liquid markets, including:

🥇 XAUUSD / Gold
₿ BTCUSDT
♦️ ETHUSDT
🟣 SOLUSDT
💵 EURUSD
📈 Major indices

The optimal settings can vary significantly between instruments and timeframes.

🔷 [b]RECOMMENDED SETUP[/b]
Balanced Configuration

Amplitude: 12
ATR Length: 100
Channel Multiplier: 2.0
EMA: 200
RSI: 14
Minimum Score: 3/4
Cooldown: 5 bars
Stop ATR: 1.5
TP1: 1R
TP2: 2R
TP3: 3R
Break-Even: ON
ATR Trailing: ON

These are starting settings, not guaranteed optimal settings. Backtesting and forward testing should be performed for each market/timeframe.

🔷 [b]HOW TO USE[/b]

🟢 [b]LONG[/b]
Wait for the adaptive trend to turn bullish.
Wait for the confirmation score to meet your minimum requirement.
Wait for the confirmed LONG signal.
Review Entry and Stop Loss.
Evaluate the risk/reward structure.
Monitor TP1, TP2 and TP3.
Use Break-Even and trailing management if desired.

🔴 [b]SHORT[/b]
Wait for the adaptive trend to turn bearish.
Wait for the confirmation score.
Wait for the confirmed SHORT signal.
Review Entry and Stop Loss.
Evaluate risk/reward.
Monitor TP1, TP2 and TP3.
Manage the position according to your risk plan.

🔷[b] IMPORTANT[/b]

Adaptive Trend Pulse Pro [JPT] is a technical analysis tool, not a guaranteed-profit system.

No indicator can guarantee a specific win rate or eliminate losing trades. Market conditions, volatility, spreads, liquidity and timeframe can all affect results.

Always test the indicator on your preferred market and timeframe and use appropriate risk management.

[b]Adaptive Trend Pulse Pro [JPT]
Detect the trend • Confirm the setup • Define the risk • Manage the move[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator('Liquidity Sweep Engine Auto Targets [JPT]', overlay = true, max_labels_count = 500)

//==================== INPUTS ====================//
pivotLen = input.int(5, 'Swing Length', minval = 2)
useCloseConfirmation = input.bool(true, 'Require Close Back Inside')

//==================== PIVOTS ====================//
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(ph)
    lastSwingHigh := high[pivotLen]
    lastSwingHigh

if not na(pl)
    lastSwingLow := low[pivotLen]
    lastSwingLow

//==================== LIQUIDITY SWEEP ====================//

buySideSweep = not na(lastSwingHigh) and high > lastSwingHigh and (useCloseConfirmation ? close < lastSwingHigh : true)

sellSideSweep = not na(lastSwingLow) and low < lastSwingLow and (useCloseConfirmation ? close > lastSwingLow : true)

//==================== AUTO TARGETS ====================//

rr1 = input.float(1.0, 'TP1 RR', step = 0.5)
rr2 = input.float(2.0, 'TP2 RR', step = 0.5)
rr3 = input.float(3.0, 'TP3 RR', step = 0.5)

extendBars = input.int(30, 'Line Length')

var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

//==================== BUY ====================//

if sellSideSweep

    entry = close
    stop = low
    risk = entry - stop

    tp1 = entry + risk * rr1
    tp2 = entry + risk * rr2
    tp3 = entry + risk * rr3

    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)

    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, color = color.rgb(33, 150, 243), width = 2)
    slLine := line.new(bar_index, stop, bar_index + extendBars, stop, color = color.red, width = 2)

    tp1Line := line.new(bar_index, tp1, bar_index + extendBars, tp1, color = color.green)
    tp2Line := line.new(bar_index, tp2, bar_index + extendBars, tp2, color = color.green)
    tp3Line := line.new(bar_index, tp3, bar_index + extendBars, tp3, color = color.green)

    entryLabel := label.new(bar_index + extendBars, entry, 'BUY\nEntry')
    slLabel := label.new(bar_index + extendBars, stop, 'SL')
    tp1Label := label.new(bar_index + extendBars, tp1, 'TP1')
    tp2Label := label.new(bar_index + extendBars, tp2, 'TP2')
    tp3Label := label.new(bar_index + extendBars, tp3, 'TP3')
    tp3Label

//==================== SELL ====================//

if buySideSweep

    entry = close
    stop = high
    risk = stop - entry

    tp1 = entry - risk * rr1
    tp2 = entry - risk * rr2
    tp3 = entry - risk * rr3

    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)

    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, color = color.blue, width = 2)
    slLine := line.new(bar_index, stop, bar_index + extendBars, stop, color = color.red, width = 2)

    tp1Line := line.new(bar_index, tp1, bar_index + extendBars, tp1, color = color.green)
    tp2Line := line.new(bar_index, tp2, bar_index + extendBars, tp2, color = color.green)
    tp3Line := line.new(bar_index, tp3, bar_index + extendBars, tp3, color = color.green)

    entryLabel := label.new(bar_index + extendBars, entry, 'SELL\nEntry')
    slLabel := label.new(bar_index + extendBars, stop, 'SL')
    tp1Label := label.new(bar_index + extendBars, tp1, 'TP1')
    tp2Label := label.new(bar_index + extendBars, tp2, 'TP2')
    tp3Label := label.new(bar_index + extendBars, tp3, 'TP3')
    tp3Label

//==================== LABELS ====================//

plotshape(buySideSweep, title = 'Buy Side Sweep', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, text = 'BSL')

plotshape(sellSideSweep, title = 'Sell Side Sweep', style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.small, text = 'SSL')

//==================== BACKGROUND ====================//

bgcolor(buySideSweep ? color.new(color.red, 90) : na)
bgcolor(sellSideSweep ? color.new(color.green, 90) : na)

//==================== ALERTS ====================//

alertcondition(buySideSweep, title = 'Buy Side Liquidity Sweep', message = 'Buy-side liquidity sweep detected')

alertcondition(sellSideSweep, title = 'Sell Side Liquidity Sweep', message = 'Sell-side liquidity sweep detected')
````
