# RSI Overbought Oversold Alert

- url: https://www.tradingview.com/script/wwCZpons/
- type: indicator
- pine_id: PUB;58641f1aff4f4aebbe71ac247d8703e7
- version: 1.0

## Description

█ OVERVIEW

A clean RSI indicator with overbought/oversold alerts that fire only once per crossing — not repeatedly while price stays in the zone.

Built to fix a common frustration: TradingView's default RSI alert keeps firing every bar while RSI stays above or below the threshold. This script uses crossover/crossunder detection so you get notified at the moment RSI crosses the level, and nothing more until it crosses again.

█ FEATURES

● Customizable overbought and oversold levels (default 70/30)
● Alerts trigger only on the crossing bar, not throughout the zone
● MA overlay on RSI (SMA, EMA, SMMA/RMA, WMA, VWMA)
● MA crossover alerts included
● Color-coded overbought, oversold, and middle zones
● All colors fully customizable

█ ALERTS (4 types)

- RSI Overbought Alert — RSI crosses above the overbought level
- RSI Oversold Alert — RSI crosses below the oversold level
- RSI Crossed Above MA — RSI crosses above its moving average
- RSI Crossed Below MA — RSI crosses below its moving average

█ RECOMMENDED ALERT SETTING

When creating an alert, set the frequency to "Once Per Bar Close."
This ensures the alert fires once per confirmed bar, not on every tick.

█ INPUTS

RSI Settings
- RSI Length: Lookback period for RSI calculation (default 14)
- Source: Price source (default close)

Moving Average Settings
- MA Type: SMA / EMA / SMMA(RMA) / WMA / VWMA
- MA Length: Lookback period for the MA (default 14)

Alert Levels
- Overbought Level: RSI threshold for overbought alert (default 70)
- Oversold Level: RSI threshold for oversold alert (default 30)

Color Settings
- All zone and line colors are individually customizable

## Source Code

````pine
//@version=6
indicator(title="RSI Overbought Oversold Alert", shorttitle="RSI OB/OS Alert", format=format.price, precision=2)

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
grp_alert = "Alert Levels"
grp_color = "Color Settings"

rsiLength  = input.int(14,    minval=1,             title="RSI Length",        group=grp_rsi)
rsiSource  = input.source(close,                    title="Source",            group=grp_rsi)

maType     = input.string("SMA", title="MA Type",
             options=["SMA","EMA","SMMA(RMA)","WMA","VWMA"],                   group=grp_ma)
maLength   = input.int(14,    minval=1,             title="MA Length",         group=grp_ma)

obLevel    = input.int(70,    minval=50, maxval=100, title="Overbought Level", group=grp_alert)
osLevel    = input.int(30,    minval=0,  maxval=50,  title="Oversold Level",   group=grp_alert)

rsiColor   = input.color(color.new(#00ACC1, 0),  title="RSI Line Color",         group=grp_color)
maColor    = input.color(color.new(#FFA726, 0),  title="MA Line Color",          group=grp_color)
obColor    = input.color(color.new(#EF5350, 92), title="Overbought Zone Color",   group=grp_color)
osColor    = input.color(color.new(#66BB6A, 92), title="Oversold Zone Color",     group=grp_color)
midColor   = input.color(color.new(#9C27B0, 80), title="Middle Zone Color",       group=grp_color)

// ================================================================
// RSI Calculation
// ================================================================
up    = ta.rma(math.max(ta.change(rsiSource), 0), rsiLength)
down  = ta.rma(-math.min(ta.change(rsiSource), 0), rsiLength)
rsi   = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
rsiMA = ma(rsi, maLength, maType)

// ================================================================
// Plots
// ================================================================
plot(rsi,   "RSI",    color=rsiColor, linewidth=2)
plot(rsiMA, "RSI MA", color=maColor,  linewidth=2)

obLine  = hline(obLevel, "Overbought", color=color.new(#E91E63, 0),  linestyle=hline.style_dashed, linewidth=1)
midLine = hline(50,      "Middle",     color=color.new(#9C27B0, 50), linestyle=hline.style_dotted, linewidth=1)
osLine  = hline(osLevel, "Oversold",   color=color.new(#00BCD4, 0),  linestyle=hline.style_dashed, linewidth=1)

fill(obLine, hline(100), color=obColor,  title="Overbought Zone")
fill(osLine, hline(0),   color=osColor,  title="Oversold Zone")
fill(obLine, osLine,     color=midColor, title="Middle Zone")

// ================================================================
// Alerts
// Uses ta.crossover / ta.crossunder so alerts fire only once
// at the moment RSI crosses the threshold — not repeatedly
// while price stays in the zone.
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
