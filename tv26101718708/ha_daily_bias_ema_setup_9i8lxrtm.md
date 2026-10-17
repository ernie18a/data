# HA Daily Bias & EMA Setup

- url: https://www.tradingview.com/script/9i8LxrTM-HA-Daily-Bias-EMA-Setup/
- type: indicator
- pine_id: PUB;2a81270d760e464aa52d19ff62191e22
- version: 1.0

## Description

Disclaimer

This indicator is inspired by the trading concepts discussed by Animesh K in "Learn Dual Edge Trading and Mindset."

This indicator is an independent implementation of selected concepts and should not be considered an official version of his strategy.

Trading involves risk. This indicator is intended as a decision-support tool and does not guarantee profitable trades.

Indicator Objective

The purpose of this indicator is to combine:

Daily Heikin Ashi Trend Bias
34 EMA Dynamic Trend Levels
Entry Confirmation
Exit Confirmation
Trend Filtering

to provide a clean trend-following trading system.

The indicator attempts to keep traders aligned with the higher timeframe trend while using the current timeframe for entries.

Core Trading Logic

The strategy is built around two ideas:

Determine the higher timeframe market bias.
Only take trades in the direction of that bias.

Instead of predicting reversals, the indicator follows momentum.

Daily Heikin Ashi Bias

The indicator first checks the previous day's Heikin Ashi candle.

Bullish Bias

Previous HA Close > Previous HA Open

Market Bias = Bullish

Only LONG trades are allowed.

Bearish Bias

Previous HA Close < Previous HA Open

Market Bias = Bearish

Only SHORT trades are allowed.

Neutral

If neither condition exists,

No directional bias exists.

Daily Support and Resistance

The indicator plots:

Previous Daily HA High

Previous Daily HA Low

These become important reference levels for:

Support
Resistance
Trend continuation
Risk management

Green Dots

= Previous HA Low

Red Dots

= Previous HA High

EMA Setup

The indicator uses two separate EMAs.

EMA 1

Length: 34

Default Source:

High

Purpose:

Bullish confirmation.

EMA 2

Length: 34

Default Source:

Low

Purpose:

Bearish confirmation.

Long Entry Rules

A LONG signal appears only when all conditions are true.

Condition 1

Daily Bias = Bullish

AND

Condition 2

Previous candle crosses above EMA High

AND

Condition 3

Current candle closes above EMA High

If all three conditions are satisfied,

A LONG label is printed.

Long Exit

The position exits when

Previous candle crosses below EMA Low

AND

Current candle closes below EMA Low

EXIT label appears.

Short Entry Rules

A SHORT signal appears only when:

Daily Bias = Bearish

AND

Previous candle crosses below EMA Low

AND

Current candle closes below EMA Low

SHORT label appears.

Short Exit

Exit occurs when

Previous candle crosses above EMA High

AND

Current candle closes above EMA High

EXIT label appears.

Signal Filtering

The indicator contains a built-in state management system.

Possible states:

Flat

Long

Short

This prevents duplicate entries.

Example:

LONG

LONG

LONG

LONG

Instead, only the first LONG signal is displayed until an EXIT occurs.

Likewise,

SHORT

SHORT

SHORT

SHORT

Only one SHORT signal is displayed.

Historical Signals

Option:

Show Historical Signals

ON

Displays every historical signal.

OFF

Displays only the latest signal.

Useful for clean charts.

Dashboard

The dashboard displays:

Previous Day HA Bias

Bullish

Bearish

Neutral

and

Previous HA Support Level

User Inputs
EMA Settings
Setting	Default
EMA Length	34
EMA High Source	High
EMA Low Source	Low
Style Settings
Option	Description
Show Daily HA Levels	Display previous HA High and Low
Show Historical Signals	Display all signals
Filter Consecutive Signals	Prevent repeated LONG or SHORT signals
Recommended Timeframes

The indicator works best on:

5 Minute
15 Minute
30 Minute
1 Hour
4 Hour

The Daily Heikin Ashi bias remains constant throughout the trading day while entries are generated from the selected chart timeframe.

Suggested Workflow
Step 1

Determine Daily Bias.

If Bullish

Only look for LONG trades.

If Bearish

Only look for SHORT trades.

Step 2

Wait for EMA confirmation.

Do not anticipate the signal.

Step 3

Enter only after the label appears.

Step 4

Allow the trend to continue.

Step 5

Exit only when the opposite EMA confirmation occurs.

Risk Management Suggestions

Although this indicator generates entry and exit signals, every trade should include predefined risk controls.

Common approaches include:

Risk a fixed percentage of account equity per trade (e.g., 1–2%).
Place a protective stop below the recent swing low for long trades or above the recent swing high for short trades.
Consider taking partial profits at predetermined risk-reward levels while allowing the remainder to follow the exit signal.
Avoid forcing trades when the market is range-bound or during unusually low liquidity.
Best Market Conditions

This indicator generally performs best in:

Trending markets
Strong directional momentum
Stocks, ETFs, Index Futures, and Forex pairs with sustained trends

It may generate more false signals during sideways or choppy markets.

Indicator Summary
Feature	Description
Higher Timeframe Filter	Previous Day Heikin Ashi Bias
Trend Filter	34 EMA (High) & 34 EMA (Low)
Long Entries	Bullish bias + EMA breakout confirmation
Short Entries	Bearish bias + EMA breakdown confirmation
Exits	Opposite EMA confirmation
Daily Levels	Previous HA High & Low
Dashboard	Current Daily Bias and HA Support
Signal Filter	Prevents duplicate consecutive signals

## Source Code

````pine
//@version=6
indicator("HA Daily Bias & EMA Setup", overlay=true, max_labels_count=500)

// --- Inputs ---
// EMA Settings
ema1_len = input.int(34, "EMA 1 Length", group="EMA Settings")
ema1_src = input.source(high, "EMA 1 Source", group="EMA Settings", tooltip="Originally Open, now High by default")
ema2_len = input.int(34, "EMA 2 Length", group="EMA Settings")
ema2_src = input.source(low, "EMA 2 Source", group="EMA Settings", tooltip="Originally Close, now Low by default")

// Style Settings
show_levels = input.bool(true, "Show Daily HA Support/Resistance", group="Style")
show_history = input.bool(false, "Show Historical Signals", group="Style", tooltip="If turned off, only the single most recent signal on the chart will be displayed. Turn on to see all past signals.")
filter_consecutive = input.bool(true, "Filter Consecutive Signals", group="Style", tooltip="Prevents multiple 'Short' or 'Exit' signals in a row. Forces signals to alternate.")

// --- Daily Heikin Ashi Bias ---
// Fetch previous day's Heikin Ashi data
ha_ticker = ticker.heikinashi(syminfo.tickerid)
[d_ha_open, d_ha_close, d_ha_high, d_ha_low] = request.security(ha_ticker, "D", [open[1], close[1], high[1], low[1]], lookahead=barmerge.lookahead_on)

// Determine Bias
isBullishDay = d_ha_close > d_ha_open
isBearishDay = d_ha_close < d_ha_open

// --- Daily Support & Resistance Levels ---
plot(show_levels ? d_ha_low : na, "Daily HA Support", color=color.new(color.green, 50), style=plot.style_circles, linewidth=2)
plot(show_levels ? d_ha_high : na, "Daily HA Resistance", color=color.new(color.red, 50), style=plot.style_circles, linewidth=2)

// --- EMAs ---
ema1 = ta.ema(ema1_src, ema1_len)
ema2 = ta.ema(ema2_src, ema2_len)

plot(ema1, "EMA 1", color=color.new(color.blue, 0), linewidth=2)
plot(ema2, "EMA 2", color=color.new(color.orange, 0), linewidth=2)

// --- Triggers ---
crossAboveEMA1 = ta.crossover(close[1], ema1[1])
crossBelowEMA2 = ta.crossunder(close[1], ema2[1])

longTrigger = isBullishDay and crossAboveEMA1 and close > ema1
longExit = crossBelowEMA2 and close < ema2

shortTrigger = isBearishDay and crossBelowEMA2 and close < ema2
shortExit = crossAboveEMA1 and close > ema1

// --- State Tracking (Filtering Consecutive Signals) ---
var int state = 0 // 0 = Flat, 1 = Long, -1 = Short

if filter_consecutive
    if state == 1
        longTrigger := false
    if state == -1
        shortTrigger := false
    if state == 0
        longExit := false
        shortExit := false

if longTrigger
    state := 1
else if shortTrigger
    state := -1
else if longExit or shortExit
    state := 0

// --- Drawing Labels ---
var label last_lbl = na

if longTrigger
    lbl = label.new(bar_index, low, text="LONG", color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_up, size=size.small)
    if not show_history
        label.delete(last_lbl)
    last_lbl := lbl

if longExit
    lbl = label.new(bar_index, high, text="EXIT", color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
    if not show_history
        label.delete(last_lbl)
    last_lbl := lbl

if shortTrigger
    lbl = label.new(bar_index, high, text="SHORT", color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_down, size=size.small)
    if not show_history
        label.delete(last_lbl)
    last_lbl := lbl

if shortExit
    lbl = label.new(bar_index, low, text="EXIT", color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_up, size=size.small)
    if not show_history
        label.delete(last_lbl)
    last_lbl := lbl

// --- Dashboard ---
var table dash = table.new(position.top_right, 2, 2, border_width=2, border_color=color.new(color.gray, 50))
if barstate.islast
    table.cell(dash, 0, 0, "Prev Day HA Bias", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dash, 1, 0, isBullishDay ? "BULLISH" : isBearishDay ? "BEARISH" : "NEUTRAL", text_color=color.white, bgcolor=isBullishDay ? color.green : color.red)
    
    table.cell(dash, 0, 1, "Support (HA Low)", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dash, 1, 1, str.tostring(d_ha_low, format.mintick), text_color=color.white, bgcolor=color.green)
````
