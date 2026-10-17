# 4 EMAs in One (Multi-Timeframe)

- url: https://www.tradingview.com/script/sluCuqwr-4-EMAs-in-One-Multi-Timeframe/
- type: indicator
- pine_id: PUB;c157ef3e75624a4fb17502d413518d34
- version: 1.0

## Description

our fully customizable EMAs on a single indicator, each with its own length, timeframe, color, and visibility toggle. Plot a fast scalping EMA alongside a higher-timeframe trend EMA without stacking multiple indicators on your chart.
Features
• 4 independent EMAs — change length, source, and timeframe per line
• Multi-timeframe support — view a 1H or Daily EMA while trading on a lower timeframe
• Optional "wait for HTF bar close" mode to prevent repainting
• Show/hide each EMA individually
• Custom colors and line width
• Built-in crossover alerts between every adjacent pair (1↔2, 2↔3, 3↔4)
Default lengths: 9 / 21 / 50 / 200 — the classic short-, mid-, and long-term trend stack. Change any length anytime from the settings panel.
How to use
Open Settings (⚙️) and configure each EMA's length, timeframe, and color. Leave the timeframe blank to follow the chart, or set it to 15, 60, 240, D, W, etc. for higher-timeframe context. Use crossovers as trend-shift signals and the EMA stack order (e.g. 9 > 21 > 50 > 200) as a trend-strength filter.
Open-source — feel free to fork and adapt.

## Source Code

````pine
//@version=5
indicator("4 EMAs in One (Multi-Timeframe)", shorttitle="4 EMA MTF", overlay=true)

src = input.source(close, title="Source")

// EMA 1 — length, timeframe, color, show, all on one row
show1     = input.bool(true,           title="EMA 1", inline="1", group="EMA 1")
ema1_len  = input.int(9,               title="Len",   inline="1", group="EMA 1", minval=1)
ema1_tf   = input.timeframe("",        title="TF",    inline="1", group="EMA 1")
col1      = input.color(color.yellow,  title="",      inline="1", group="EMA 1")

show2     = input.bool(true,           title="EMA 2", inline="2", group="EMA 2")
ema2_len  = input.int(21,              title="Len",   inline="2", group="EMA 2", minval=1)
ema2_tf   = input.timeframe("",        title="TF",    inline="2", group="EMA 2")
col2      = input.color(color.orange,  title="",      inline="2", group="EMA 2")

show3     = input.bool(true,           title="EMA 3", inline="3", group="EMA 3")
ema3_len  = input.int(50,              title="Len",   inline="3", group="EMA 3", minval=1)
ema3_tf   = input.timeframe("",        title="TF",    inline="3", group="EMA 3")
col3      = input.color(color.red,     title="",      inline="3", group="EMA 3")

show4     = input.bool(true,           title="EMA 4", inline="4", group="EMA 4")
ema4_len  = input.int(200,             title="Len",   inline="4", group="EMA 4", minval=1)
ema4_tf   = input.timeframe("",        title="TF",    inline="4", group="EMA 4")
col4      = input.color(color.blue,    title="",      inline="4", group="EMA 4")

lw         = input.int(2, title="Line Width", minval=1, maxval=5, group="Style")
no_repaint = input.bool(true, title="Wait for HTF bar close (no repaint)", group="Style")

// Calculations
f_ema(_src, _len, _tf) =>
    request.security(syminfo.tickerid, _tf, ta.ema(_src, _len),
         lookahead = no_repaint ? barmerge.lookahead_off : barmerge.lookahead_on)

ema1 = f_ema(src, ema1_len, ema1_tf)
ema2 = f_ema(src, ema2_len, ema2_tf)
ema3 = f_ema(src, ema3_len, ema3_tf)
ema4 = f_ema(src, ema4_len, ema4_tf)

// Plots
plot(show1 ? ema1 : na, title="EMA 1", color=col1, linewidth=lw)
plot(show2 ? ema2 : na, title="EMA 2", color=col2, linewidth=lw)
plot(show3 ? ema3 : na, title="EMA 3", color=col3, linewidth=lw)
plot(show4 ? ema4 : na, title="EMA 4", color=col4, linewidth=lw)

// Alerts
alertcondition(ta.crossover(ema1, ema2),  title="EMA1 > EMA2", message="EMA1 crossed above EMA2")
alertcondition(ta.crossunder(ema1, ema2), title="EMA1 < EMA2", message="EMA1 crossed below EMA2")
alertcondition(ta.crossover(ema2, ema3),  title="EMA2 > EMA3", message="EMA2 crossed above EMA3")
alertcondition(ta.crossunder(ema2, ema3), title="EMA2 < EMA3", message="EMA2 crossed below EMA3")
alertcondition(ta.crossover(ema3, ema4),  title="EMA3 > EMA4", message="EMA3 crossed above EMA4")
alertcondition(ta.crossunder(ema3, ema4), title="EMA3 < EMA4", message="EMA3 crossed below EMA4")
````
