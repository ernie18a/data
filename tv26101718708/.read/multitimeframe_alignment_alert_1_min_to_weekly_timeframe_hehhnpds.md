# Multi-Timeframe Alignment Alert - 1 Min to Weekly Timeframe

- url: https://www.tradingview.com/script/HEhHNPds-Multi-Timeframe-Alignment-Alert-1-Min-to-Weekly-Timeframe/
- type: indicator
- pine_id: PUB;cb25aec4e99144508dfcc3472e8022d9
- version: 1.0

## Description

## Multi-Timeframe Alignment Alert — Strength Version

This indicator helps you quickly see whether the market is leaning bullish, bearish, or mixed across multiple timeframes.

Instead of only looking at the chart you are currently trading, this tool checks the trend on several timeframes at the same time:

**Weekly, Daily, 4 Hour, 30 Minute, 5 Minute, and 1 Minute**

The purpose of this indicator is to help you understand the bigger picture before taking a trade. When multiple timeframes are pointing in the same direction, the market may have stronger momentum. When the timeframes are mixed, price may be choppy, unclear, or harder to trade.

The indicator uses a moving average to judge trend direction. By default, it uses the **21 EMA**, but you can switch it to an SMA in the settings. Each timeframe is graded as **Strong Bull, Weak Bull, Weak Bear, or Strong Bear** based on where price is compared to the moving average and whether the moving average is rising or falling. 

### How to Read the Table

The table shows each timeframe and its current trend condition.

**Strong Bull** means price is above the moving average and the moving average is rising. This shows stronger upside momentum.

**Weak Bull** means price is above the moving average, but the moving average is not clearly rising yet. The market is bullish, but the strength is not fully confirmed.

**Weak Bear** means price is below the moving average, but the moving average is not clearly falling yet. The market is bearish, but the weakness is not fully confirmed.

**Strong Bear** means price is below the moving average and the moving average is falling. This shows stronger downside momentum.

At the bottom of the table, the indicator gives an overall status:

**Strong Bullish Aligned** means all selected timeframes are strongly bullish.

**Bullish Bias** means all selected timeframes are bullish, but they are not all strongly bullish.

**Strong Bearish Aligned** means all selected timeframes are strongly bearish.

**Bearish Bias** means all selected timeframes are bearish, but they are not all strongly bearish.

**Mixed** means the timeframes do not agree. This can be a warning that price may be less predictable.

### How to Use This Indicator

This indicator is best used as a **directional bias tool**. It is not meant to be used by itself as a buy or sell signal.

For a bullish trade, you would want to see the table showing bullish alignment before looking for a call setup, breakout, pullback entry, VWAP reclaim, or continuation move higher.

For a bearish trade, you would want to see the table showing bearish alignment before looking for a put setup, breakdown, rejection, or continuation move lower.

When the table shows **Mixed**, it may be better to slow down and wait for the market to become clearer.

### Chart Signals

The indicator can also place markers directly on the chart.

A green triangle appears when all timeframes become **Strong Bullish Aligned**.

A red triangle appears when all timeframes become **Strong Bearish Aligned**.

Smaller green or red circles appear when the market has bullish or bearish bias, but the alignment is not fully strong.

The chart background can also lightly change color to show when the market is aligned bullish or bearish.

### Alerts

This indicator includes alert options for:

**Strong Bullish Alignment**
**Strong Bearish Alignment**
**Bullish Bias**
**Bearish Bias**

The strongest alerts are usually the **Strong Bullish Alignment** and **Strong Bearish Alignment** alerts because they mean every selected timeframe is pointing in the same direction with strength.

### Important Reminder

This indicator should be used with a full trading plan. Before entering a trade, you should still look for important levels, liquidity areas, support and resistance, VWAP, opening range levels, fair value gaps, candle confirmation, and proper risk management.

The main goal of this indicator is simple:

**It helps you see when the larger and smaller timeframes are working together before you take a trade.**

## Source Code

````pine
//@version=5
indicator("Multi-Timeframe Alignment Alert - Strength Version", overlay=true, max_labels_count=500)

//====================================================
// INPUTS
//====================================================
groupTrend = "Trend Settings"
maLength      = input.int(21, "EMA Length", minval=1, group=groupTrend)
useEMA        = input.bool(true, "Use EMA (unchecked = SMA)", group=groupTrend)

groupAlerts = "Alerts"
alertStrongBullAlignment = input.bool(true, "Alert on Strong Bullish Alignment", group=groupAlerts)
alertStrongBearAlignment = input.bool(true, "Alert on Strong Bearish Alignment", group=groupAlerts)
alertBullBias           = input.bool(false, "Alert on Bullish Bias", group=groupAlerts)
alertBearBias           = input.bool(false, "Alert on Bearish Bias", group=groupAlerts)

groupDisplay = "Display"
showStatusTable    = input.bool(true, "Show Status Table", group=groupDisplay)
tablePositionInput = input.string("top_right", "Table Position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=groupDisplay)
showChartSignals   = input.bool(true, "Show Bull/Bear Alignment Markers", group=groupDisplay)
showBackground     = input.bool(true, "Show Background Color", group=groupDisplay)

groupTimeframes = "Timeframes"
tfWeekly = input.timeframe("W", "Weekly TF", group=groupTimeframes)
tfDaily  = input.timeframe("D", "Daily TF", group=groupTimeframes)
tf4H     = input.timeframe("240", "4 Hour TF", group=groupTimeframes)
tf30M    = input.timeframe("30", "30 Min TF", group=groupTimeframes)
tf5M     = input.timeframe("5", "5 Min TF", group=groupTimeframes)
tf1M     = input.timeframe("1", "1 Min TF", group=groupTimeframes)

//====================================================
// TABLE POSITION
//====================================================
tablePos = switch tablePositionInput
    "top_left" => position.top_left
    "bottom_right" => position.bottom_right
    "bottom_left" => position.bottom_left
    => position.top_right

//====================================================
// FUNCTIONS
//====================================================
f_ma(_src, _len) =>
    useEMA ? ta.ema(_src, _len) : ta.sma(_src, _len)

// Trend states:
//  2 = strong bull
//  1 = weak bull
// -1 = weak bear
// -2 = strong bear
f_tf_state(_tf) =>
    tfClose  = request.security(syminfo.tickerid, _tf, close)
    tfMA     = request.security(syminfo.tickerid, _tf, f_ma(close, maLength))
    tfMAprev = request.security(syminfo.tickerid, _tf, f_ma(close, maLength)[1])

    isAbove = tfClose > tfMA
    isBelow = tfClose < tfMA
    isRising = tfMA > tfMAprev
    isFalling = tfMA < tfMAprev

    isAbove and isRising ? 2 :
     isAbove and not isRising ? 1 :
     isBelow and isFalling ? -2 :
     isBelow and not isFalling ? -1 : 0

f_stateText(_state) =>
    _state == 2 ? "▲ STRONG BULL" :
     _state == 1 ? "▲ WEAK BULL" :
     _state == -1 ? "▼ WEAK BEAR" :
     _state == -2 ? "▼ STRONG BEAR" :
     "• NEUTRAL"

f_stateBg(_state) =>
    _state == 2 ? color.rgb(46, 125, 50) :
     _state == 1 ? color.rgb(102, 187, 106) :
     _state == -1 ? color.rgb(239, 83, 80) :
     _state == -2 ? color.rgb(183, 28, 28) :
     color.rgb(158, 158, 158)

f_isBull(_state) =>
    _state == 1 or _state == 2

f_isBear(_state) =>
    _state == -1 or _state == -2

f_isStrongBull(_state) =>
    _state == 2

f_isStrongBear(_state) =>
    _state == -2

//====================================================
// TIMEFRAME STATES
//====================================================
weeklyState = f_tf_state(tfWeekly)
dailyState  = f_tf_state(tfDaily)
h4State     = f_tf_state(tf4H)
m30State    = f_tf_state(tf30M)
m5State     = f_tf_state(tf5M)
m1State     = f_tf_state(tf1M)

//====================================================
// ALIGNMENT LOGIC
//====================================================
allBull = f_isBull(weeklyState) and f_isBull(dailyState) and f_isBull(h4State) and f_isBull(m30State) and f_isBull(m5State) and f_isBull(m1State)
allBear = f_isBear(weeklyState) and f_isBear(dailyState) and f_isBear(h4State) and f_isBear(m30State) and f_isBear(m5State) and f_isBear(m1State)

allStrongBull = f_isStrongBull(weeklyState) and f_isStrongBull(dailyState) and f_isStrongBull(h4State) and f_isStrongBull(m30State) and f_isStrongBull(m5State) and f_isStrongBull(m1State)
allStrongBear = f_isStrongBear(weeklyState) and f_isStrongBear(dailyState) and f_isStrongBear(h4State) and f_isStrongBear(m30State) and f_isStrongBear(m5State) and f_isStrongBear(m1State)

bullCount = (f_isBull(weeklyState) ? 1 : 0) + (f_isBull(dailyState) ? 1 : 0) + (f_isBull(h4State) ? 1 : 0) + (f_isBull(m30State) ? 1 : 0) + (f_isBull(m5State) ? 1 : 0) + (f_isBull(m1State) ? 1 : 0)
bearCount = (f_isBear(weeklyState) ? 1 : 0) + (f_isBear(dailyState) ? 1 : 0) + (f_isBear(h4State) ? 1 : 0) + (f_isBear(m30State) ? 1 : 0) + (f_isBear(m5State) ? 1 : 0) + (f_isBear(m1State) ? 1 : 0)

strongBullCount = (f_isStrongBull(weeklyState) ? 1 : 0) + (f_isStrongBull(dailyState) ? 1 : 0) + (f_isStrongBull(h4State) ? 1 : 0) + (f_isStrongBull(m30State) ? 1 : 0) + (f_isStrongBull(m5State) ? 1 : 0) + (f_isStrongBull(m1State) ? 1 : 0)
strongBearCount = (f_isStrongBear(weeklyState) ? 1 : 0) + (f_isStrongBear(dailyState) ? 1 : 0) + (f_isStrongBear(h4State) ? 1 : 0) + (f_isStrongBear(m30State) ? 1 : 0) + (f_isStrongBear(m5State) ? 1 : 0) + (f_isStrongBear(m1State) ? 1 : 0)

statusText =
     allStrongBull ? "✓ STRONG BULLISH ALIGNED" :
     allBull ? "✓ BULLISH BIAS" :
     allStrongBear ? "✓ STRONG BEARISH ALIGNED" :
     allBear ? "✓ BEARISH BIAS" :
     "• MIXED"

statusBg =
     allStrongBull ? color.rgb(27, 94, 32) :
     allBull ? color.rgb(76, 175, 80) :
     allStrongBear ? color.rgb(127, 0, 0) :
     allBear ? color.rgb(198, 40, 40) :
     color.rgb(158, 120, 51)

//====================================================
// TABLE COLORS
//====================================================
headerBg   = color.rgb(70, 70, 70)
leftColBg  = color.rgb(55, 55, 55)
textColor  = color.white

//====================================================
// TABLE
//====================================================
var table statusTable = table.new(tablePos, 2, 8, border_width=1)

if barstate.islast
    if showStatusTable
        table.cell(statusTable, 0, 0, "Timeframe", text_color=textColor, bgcolor=headerBg)
        table.cell(statusTable, 1, 0, "Trend",     text_color=textColor, bgcolor=headerBg)

        table.cell(statusTable, 0, 1, "Weekly", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 1, f_stateText(weeklyState), text_color=textColor, bgcolor=f_stateBg(weeklyState))

        table.cell(statusTable, 0, 2, "Daily", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 2, f_stateText(dailyState), text_color=textColor, bgcolor=f_stateBg(dailyState))

        table.cell(statusTable, 0, 3, "4 Hour", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 3, f_stateText(h4State), text_color=textColor, bgcolor=f_stateBg(h4State))

        table.cell(statusTable, 0, 4, "30 Min", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 4, f_stateText(m30State), text_color=textColor, bgcolor=f_stateBg(m30State))

        table.cell(statusTable, 0, 5, "5 Min", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 5, f_stateText(m5State), text_color=textColor, bgcolor=f_stateBg(m5State))

        table.cell(statusTable, 0, 6, "1 Min", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 6, f_stateText(m1State), text_color=textColor, bgcolor=f_stateBg(m1State))

        table.cell(statusTable, 0, 7, "Status", text_color=textColor, bgcolor=leftColBg)
        table.cell(statusTable, 1, 7, statusText, text_color=textColor, bgcolor=statusBg)
    else
        table.clear(statusTable, 0, 0, 1, 7)

//====================================================
// CHART MARKERS / BACKGROUND
//====================================================
plotshape(showChartSignals and allStrongBull, title="Strong Bullish Alignment", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, text="STR BULL")
plotshape(showChartSignals and allStrongBear, title="Strong Bearish Alignment", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, text="STR BEAR")

plotshape(showChartSignals and not allStrongBull and allBull, title="Bullish Bias", style=shape.circle, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny, text="BULL")
plotshape(showChartSignals and not allStrongBear and allBear, title="Bearish Bias", style=shape.circle, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny, text="BEAR")

bgcolor(showBackground ? (allStrongBull ? color.new(color.green, 88) : allStrongBear ? color.new(color.red, 88) : allBull ? color.new(color.green, 93) : allBear ? color.new(color.red, 93) : na) : na)

//====================================================
// ALERTS
//====================================================
strongBullSignal = allStrongBull and not allStrongBull[1]
strongBearSignal = allStrongBear and not allStrongBear[1]
bullBiasSignal   = allBull and not allStrongBull and not allBull[1]
bearBiasSignal   = allBear and not allStrongBear and not allBear[1]

alertcondition(alertStrongBullAlignment and strongBullSignal, title="Strong Bullish Alignment", message="All timeframes are STRONG BULL: Weekly, Daily, 4 Hour, 30 Min, 5 Min, and 1 Min.")
alertcondition(alertStrongBearAlignment and strongBearSignal, title="Strong Bearish Alignment", message="All timeframes are STRONG BEAR: Weekly, Daily, 4 Hour, 30 Min, 5 Min, and 1 Min.")
alertcondition(alertBullBias and bullBiasSignal, title="Bullish Bias", message="All timeframes are bullish, but not all are strong bullish.")
alertcondition(alertBearBias and bearBiasSignal, title="Bearish Bias", message="All timeframes are bearish, but not all are strong bearish.")
````
