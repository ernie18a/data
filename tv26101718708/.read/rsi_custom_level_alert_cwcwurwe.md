# RSI Custom Level Alert

- url: https://www.tradingview.com/script/cwcWUrwE/
- type: indicator
- pine_id: PUB;775fc92e9a534bf18eba069afde8b43d
- version: 1.0

## Description

█ OVERVIEW

An RSI indicator that lets you set custom overbought and oversold alert levels — because the default 70/30 doesn't work for every pair or timeframe.

The alert fires only once when RSI crosses your threshold, not repeatedly while it stays in the zone. Set it and walk away.

█ THE PROBLEM THIS SOLVES

The default RSI alert at 70/30 is too rigid. Gold tends to hover in the 60s during strong uptrends. Volatile pairs hit 70 and 30 constantly, flooding you with noise. This script lets you dial in the exact level that fits your pair and timeframe, so every alert actually means something.

█ FEATURES

● Fully adjustable overbought and oversold alert levels (default 70/30)
● Alerts fire only on the crossing bar — no zone spam
● MA overlay on RSI (SMA, EMA, SMMA/RMA, WMA, VWMA)
● MA crossover alerts included
● Color-coded overbought, oversold, and middle zones
● All colors fully customizable

█ ALERTS (4 types)

- RSI Overbought Alert — RSI crosses above your custom overbought level
- RSI Oversold Alert — RSI crosses below your custom oversold level
- RSI Crossed Above MA — RSI crosses above its moving average
- RSI Crossed Below MA — RSI crosses below its moving average

█ RECOMMENDED ALERT SETTING

When creating an alert, set the frequency to "Once Per Bar Close."
This ensures the alert fires once per confirmed bar only.

█ INPUTS

RSI Settings
- RSI Length: Lookback period for RSI calculation (default 14)
- Source: Price source (default close)

Moving Average Settings
- MA Type: SMA / EMA / SMMA(RMA) / WMA / VWMA
- MA Length: Lookback period for the MA (default 9)

Alert Levels (Custom)
- Overbought Alert Level: RSI level that triggers the overbought alert (default 70, freely adjustable)
- Oversold Alert Level: RSI level that triggers the oversold alert (default 30, freely adjustable)

Color Settings
- All zone and line colors are individually customizable

## Source Code

````pine
//@version=6
indicator(title="RSI Custom Level Alert", shorttitle="RSI CL Alert", format=format.price, precision=2)

// ================================================================
// Moving Average Function
// ================================================================
ma(source, length, type) =>
    switch type
        "SMA"       => ta.sma(source, length)
        "EMA"       => ta.ema(source, length)
        "SMMA(RMA)" => ta.rma(source, length)
        "WMA"       => ta.wma(source, length)
        "VWMA"      => ta.vwma(source, length)

// ================================================================
// Inputs
// ================================================================
grp_rsi   = "RSI Settings"
grp_ma    = "Moving Average Settings"
grp_alert = "Alert Levels (Custom)"
grp_color = "Color Settings"

rsiLength  = input.int(14,    minval=1,             title="RSI Length",              group=grp_rsi)
rsiSource  = input.source(close,                    title="Source",                  group=grp_rsi)

maType     = input.string("SMA", title="MA Type",
             options=["SMA","EMA","SMMA(RMA)","WMA","VWMA"],                         group=grp_ma)
maLength   = input.int(9,     minval=1,             title="MA Length",               group=grp_ma)

obLevel    = input.int(70,    minval=0, maxval=100, title="Overbought Alert Level",  group=grp_alert,
             tooltip="Alert fires when RSI crosses above this level")
osLevel    = input.int(30,    minval=0, maxval=100, title="Oversold Alert Level",    group=grp_alert,
             tooltip="Alert fires when RSI crosses below this level")

rsiColor   = input.color(color.new(#00ACC1, 0),  title="RSI Line Color",            group=grp_color)
maColor    = input.color(color.new(#FFA726, 0),  title="MA Line Color",             group=grp_color)
obColor    = input.color(color.new(#EF5350, 92), title="Overbought Zone Color",      group=grp_color)
osColor    = input.color(color.new(#66BB6A, 92), title="Oversold Zone Color",        group=grp_color)
midColor   = input.color(color.new(#9C27B0, 80), title="Middle Zone Color",          group=grp_color)

// ================================================================
// RSI Calculation
// ================================================================
rsi   = ta.rsi(rsiSource, rsiLength)
rsiMA = ma(rsi, maLength, maType)

// ================================================================
// Plots
// ================================================================
plot(rsi,   "RSI",    color=rsiColor, linewidth=2)
plot(rsiMA, "RSI MA", color=maColor,  linewidth=2)

obLine  = hline(obLevel, "Overbought", color=color.new(#EF5350, 0),  linestyle=hline.style_dashed, linewidth=1)
midLine = hline(50,      "Middle",     color=color.new(#9C27B0, 50), linestyle=hline.style_dotted, linewidth=1)
osLine  = hline(osLevel, "Oversold",   color=color.new(#66BB6A, 0),  linestyle=hline.style_dashed, linewidth=1)

fill(obLine, hline(100), color=obColor,  title="Overbought Zone")
fill(osLine, hline(0),   color=osColor,  title="Oversold Zone")
fill(obLine, osLine,     color=midColor, title="Middle Zone")

// ================================================================
// Alerts
// Uses ta.crossover / ta.crossunder — fires only once per crossing,
// not repeatedly while RSI stays in the zone.
// Recommended alert setting: "Once Per Bar Close"
// ================================================================
rsiOverbought = ta.crossover(rsi, obLevel)
rsiOversold   = ta.crossunder(rsi, osLevel)
maCrossUp     = ta.crossover(rsi, rsiMA)
maCrossDown   = ta.crossunder(rsi, rsiMA)

alertcondition(rsiOverbought, title="RSI Overbought Alert", message="{{ticker}} {{interval}}: RSI crossed above overbought level ({{plot_0}})")
alertcondition(rsiOversold,   title="RSI Oversold Alert",   message="{{ticker}} {{interval}}: RSI crossed below oversold level ({{plot_0}})")
alertcondition(maCrossUp,     title="RSI Crossed Above MA", message="{{ticker}} {{interval}}: RSI crossed above MA")
alertcondition(maCrossDown,   title="RSI Crossed Below MA", message="{{ticker}} {{interval}}: RSI crossed below MA")
````
