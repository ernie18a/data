# Trey's Super Negative RR Strategy

- url: https://www.tradingview.com/script/w8FXpidd-Trey-s-Super-Negative-RR-Strategy/
- type: strategy
- pine_id: PUB;3a2fddc9fc83446392e26ffbe83db7af
- version: 1.0

## Description

The Super Negative R:R Strategy is an unconventional, high-frequency approach for traders who prioritize win rate over reward-to-risk. Instead of aiming for classic 2:1 or 3:1 payouts, it intentionally runs a negative R:R (default 0.3:1 – risking $750 to make $300) and looks to compensate with a very high win rate via precise wick-imbalance detection.

Smaller profit targets are designed to be hit more often, aiming for 70–90%+ win rate, which can create frequent winning streaks suitable for scalping.

Best Suited For
Scalpers and active day traders seeking high win rates
Liquid markets with tight spreads (futures, forex)
5-minute to 1-hour timeframes


Disclaimer
This strategy is for educational purposes only. A negative R:R profile demands consistently high win rates to remain profitable. Always backtest thoroughly, use appropriate position sizing, and remember that past performance does not guarantee future results.
Open-source script

In true TradingView spirit, the creator of this script has made it open-source, so that traders can review and verify its functionality. Kudos to the author! While you can use it for free, remember that republishing the code is subject to our House Rules.


TreyThaTrader

Follow Me on IG: @treythabaddguy

Disclaimer
The information and publications are not meant to be, and do not constitute, financial, investment, trading, or other types of advice or recommendations supplied or endorsed by TreyThaTrader.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradersPostInc
//@contributor: sacredprofit, @ForexIke

//@version=6
strategy("[TradersPost] Super Negative RR Strategy",
     shorttitle="Negative RR",
     overlay=true,
     initial_capital=5000,
     default_qty_type=strategy.fixed,
     default_qty_value=1,
     margin_long=0,
     margin_short=0,
     calc_on_every_tick=true,
     use_bar_magnifier=true,
     commission_type=strategy.commission.cash_per_order,
     commission_value=1,
     slippage=2)

// ============================================================================
// INPUTS
// ============================================================================

riskAmount = input.float(1000, "Stop Loss Amount ($)",
     minval=1,
     step=100,
     tooltip="Close position when loss reaches this dollar amount",
     group="Risk Management")

rewardAmount = input.float(300, "Take Profit Amount ($)",
     minval=1,
     step=50,
     tooltip="Close position when profit reaches this dollar amount",
     group="Risk Management")

atrLength = input.int(14, "ATR Length",
     minval=1,
     tooltip="Period for ATR calculation",
     group="Signal Settings")

wickRatioThreshold = input.float(2.0, "Wick Ratio Threshold",
     minval=1.0,
     step=0.1,
     tooltip="How much bigger one wick must be than the other (2.0 = 2x larger)",
     group="Signal Settings")

minBodyAtr = input.float(0.1, "Min Body Size (ATR)",
     minval=0.0,
     step=0.05,
     tooltip="Minimum candle body size as multiple of ATR. Filters out dojis.",
     group="Signal Settings")

showSignals = input.bool(true, "Show Entry Signals",
     tooltip="Display arrows at entry points",
     group="Visual Settings")

showAtr = input.bool(true, "Show ATR Line",
     tooltip="Display ATR value on chart",
     group="Visual Settings")

showMetricsTable = input.bool(true, "Show Metrics Table",
     tooltip="Display strategy metrics in top-right corner",
     group="Visual Settings")

bullColor = input.color(color.new(#26a69a, 0), "Bullish Color",
     group="Colors")

bearColor = input.color(color.new(#ef5350, 0), "Bearish Color",
     group="Colors")

atrColor = input.color(color.new(#2196F3, 0), "ATR Color",
     group="Colors")

// ============================================================================
// CALCULATIONS
// ============================================================================

atr = ta.atr(atrLength)
prevAtr = atr[1]

prevHigh  = high[1]
prevLow   = low[1]
prevOpen  = open[1]
prevClose = close[1]

prevMaxBody   = math.max(prevOpen, prevClose)
prevMinBody   = math.min(prevOpen, prevClose)
prevBodySize  = prevMaxBody - prevMinBody
prevUpperWick = prevHigh - prevMaxBody
prevLowerWick = prevMinBody - prevLow
prevTotalWick = prevUpperWick + prevLowerWick

currentRR        = rewardAmount / riskAmount
breakEvenWinRate = 100 / (1 + currentRR)

qty       = strategy.default_entry_qty(close)
tickValue = syminfo.pointvalue * syminfo.mintick

slTicks         = qty > 0 and tickValue > 0 ? riskAmount  / (tickValue * qty) : 0
tpTicks         = qty > 0 and tickValue > 0 ? rewardAmount / (tickValue * qty) : 0
slPriceDistance = slTicks * syminfo.mintick

// ============================================================================
// SIGNAL DETECTION
// ============================================================================

wickSizeCondition = prevTotalWick > prevAtr
upperWickDominant = prevUpperWick > prevLowerWick * wickRatioThreshold
lowerWickDominant = prevLowerWick > prevUpperWick * wickRatioThreshold
notDoji           = prevBodySize >= prevAtr * minBodyAtr

longSignal  = wickSizeCondition and upperWickDominant and notDoji and strategy.position_size == 0 and barstate.isconfirmed
shortSignal = wickSizeCondition and lowerWickDominant and notDoji and strategy.position_size == 0 and barstate.isconfirmed

// ============================================================================
// STRATEGY EXECUTION
// — alert_message is embedded directly into each order so TradingView
//   fires the correct TradersPost JSON automatically on every fill,
//   including TP and SL exits. No manual exit detection needed.
// ============================================================================

if longSignal
    strategy.entry("Long", strategy.long,
         alert_message='{"ticker": "' + syminfo.ticker + '", "action": "buy", "sentiment": "long"}')
    strategy.exit("Long Exit", "Long",
         profit=tpTicks,
         loss=slTicks,
         comment_profit="Take Profit",
         comment_loss="Stop Loss",
         alert_profit='{"ticker": "' + syminfo.ticker + '", "action": "sell", "sentiment": "flat"}',
         alert_loss='{"ticker": "' + syminfo.ticker + '", "action": "sell", "sentiment": "flat"}')

if shortSignal
    strategy.entry("Short", strategy.short,
         alert_message='{"ticker": "' + syminfo.ticker + '", "action": "sell", "sentiment": "short"}')
    strategy.exit("Short Exit", "Short",
         profit=tpTicks,
         loss=slTicks,
         comment_profit="Take Profit",
         comment_loss="Stop Loss",
         alert_profit='{"ticker": "' + syminfo.ticker + '", "action": "buy", "sentiment": "flat"}',
         alert_loss='{"ticker": "' + syminfo.ticker + '", "action": "buy", "sentiment": "flat"}')

// ============================================================================
// PLOTS
// ============================================================================

plotshape(showSignals and longSignal,
     "Long Signal",
     shape.triangleup,
     location.belowbar,
     bullColor,
     size=size.small,
     offset=-1)

plotshape(showSignals and shortSignal,
     "Short Signal",
     shape.triangledown,
     location.abovebar,
     bearColor,
     size=size.small,
     offset=-1)

plot(showAtr ? atr : na,
     "ATR",
     color=atrColor,
     linewidth=2,
     style=plot.style_line)

// ============================================================================
// STRATEGY METRICS DISPLAY
// ============================================================================

var table metricsTable = table.new(position.top_right, 2, 10,
     bgcolor=color.new(color.black, 85),
     frame_color=color.new(color.gray, 50),
     frame_width=1)

if barstate.islast and showMetricsTable
    table.cell(metricsTable, 0, 0, "Metric",
         text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(metricsTable, 1, 0, "Value",
         text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)

    rrColor = currentRR < 1 ? color.new(color.red, 0) : color.new(color.green, 0)
    table.cell(metricsTable, 0, 1, "R:R Ratio",       text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 1, str.format("{0,number,#.##}:1", currentRR), text_color=rrColor, text_size=size.small)

    table.cell(metricsTable, 0, 2, "Break-even %",    text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 2, str.format("{0,number,#.#}%", breakEvenWinRate), text_color=color.new(color.orange, 0), text_size=size.small)

    table.cell(metricsTable, 0, 3, "SL Amount",       text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 3, str.format("${0,number,#}", riskAmount), text_color=color.new(color.red, 0), text_size=size.small)

    table.cell(metricsTable, 0, 4, "TP Amount",       text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 4, str.format("${0,number,#}", rewardAmount), text_color=color.new(color.green, 0), text_size=size.small)

    table.cell(metricsTable, 0, 5, "Contracts",       text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 5, str.format("{0,number,#.##}", qty), text_color=color.white, text_size=size.small)

    table.cell(metricsTable, 0, 6, "SL Ticks",        text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 6, str.format("{0,number,#}", slTicks), text_color=color.new(color.red, 0), text_size=size.small)

    table.cell(metricsTable, 0, 7, "TP Ticks",        text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 7, str.format("{0,number,#}", tpTicks), text_color=color.new(color.green, 0), text_size=size.small)

    table.cell(metricsTable, 0, 8, "SL Distance",     text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 8, str.format("{0,number,#.##} pts", slPriceDistance), text_color=color.new(color.red, 0), text_size=size.small)

    table.cell(metricsTable, 0, 9, "Tick Value",      text_color=color.white, text_size=size.small)
    table.cell(metricsTable, 1, 9, str.format("${0,number,#.###}", tickValue), text_color=color.new(color.gray, 0), text_size=size.small)
````
