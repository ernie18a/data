# Price oscillator [Session Adjusted]

- url: https://www.tradingview.com/script/FNTrSEMR/
- type: indicator
- pine_id: PUB;8a68726941f04411918361e57051193e
- version: 3.0

## Description

[b]Price Oscillator [/b]
This indicator combines directional momentum bias with dynamic volatility analysis, helping traders identify both trend direction and potential exhaustion zones.

[b]Core Concept[/b]
The oscillator calculates the percentage deviation of price from a session-adjusted moving average (close / MA - 1). 
The histogram is plotted as always-positive columns (green when price is above the MA, red when below). This design enables a clear visual comparison between momentum strength and the Bollinger Band Width (BBW).
When the colored columns cross above the BBW line, it signals an over-extended condition, often indicating a high probability of imminent correction or mean reversion.

[b]Volatility Analysis[/b]
The blue BBW line is a key element of the indicator:
- Rising BBW (positive slope) indicates volatility expansion — typically associated with strong trending moves or breakout phases.
- Falling BBW (negative slope) indicates volatility contraction — often signaling consolidation periods or impending explosive moves.

[b]Main Features[/b]
[i]Adaptive Lookback Period: [/i]
Automatically adjusts based on the selected session duration (default 24 hours), providing timeframe consistency.

[i]Flexible Smoothing: [/i]
Choose between SMA, EMA, RMA, or WMA for the reference moving average.

[i]Dual Signal System:[/i]
Colored columns show momentum direction and strength.
BBW line reveals both the level and the direction (slope) of volatility.

[i]Exhaustion Zones: [/i]
Crosses between momentum columns and BBW act as dynamic overbought/oversold signals.

[b]How to Use[/b]
Directional Bias Filter: Green columns = bullish bias | Red columns = bearish bias.
Volatility Regime: Use the slope of the BBW line to distinguish between trending (expanding volatility) and consolidating (contracting volatility) environments.
Correction Signals: Watch for strong momentum columns crossing above the BBW line — this frequently precedes pullbacks or reversals.

Particularly effective on Forex pairs and European indices (DAX, CAC40, FTSEMIB, etc.) on 1H to 4H, and Daily timeframes.

## Source Code

````pine
//@version=6
indicator('Price Momentum', shorttitle='Price OSC', timeframe='', overlay=false)

// ─────────────────────────────────────────────────────────────
// Input - Session length 
// ─────────────────────────────────────────────────────────────
sezione       = input.float(8.5, "Durata sessione di riferimento (ore)", minval=0.1, step=0.1, group="Session & Time")

// ─────────────────────────────────────────────────────────────
// Input data
// ─────────────────────────────────────────────────────────────
lookbackLen = input.int(20, minval=1, title='Lookback Period for indicator (in days)', group="Input data")
smoothingMA  = input.string(title="Smoothing Method MA", defval="SMA", options=["RMA", "SMA", "EMA", "WMA"], group="Input data")
bandmultiplier = input.float(2.0, title="Multiplier for definition of bollinger bands", step=0.1, group="Input data", tooltip="Defval=2.0 (bands range between [+2*st.dev;-2*st.dev])")

volatilityLen  = input.int(65, title="Volatility lookback (days)", minval=1, group="Dynamic Levels (volatility)", display=display.data_window)

// Calculate approximate number of candles per session
tf_seconds         = timeframe.in_seconds()
session_seconds    = sezione * 3600
candles_per_session = math.ceil(session_seconds / tf_seconds)

// Custom Moving Average function (supports multiple smoothing types)
ma_function(source, length, smoothing) =>
    switch smoothing
        "RMA" => ta.rma(source, length)
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        => ta.wma(source, length)

MA = ma_function(close, lookbackLen * candles_per_session, smoothingMA)

osc = close / MA - 1
dev = ta.stdev(osc, lookbackLen * candles_per_session)

clrtoogle = close > MA ? color.green : color.red
bbw = bandmultiplier * dev

plot(close > MA ? osc : -osc, color=color.new(clrtoogle, 50), style=plot.style_columns)
plot(bbw, "BBW", color=#2962FF)

plot(ta.highest(bbw, volatilityLen * candles_per_session),
     title="Highest Expansion (dynamic)", color=color.new(#F23645, 75), linewidth=1, style=plot.style_circles)
plot(ta.lowest(bbw, volatilityLen * candles_per_session),
     title="Lowest Contraction (dynamic)", color=color.new(#089981, 75), linewidth=1, style=plot.style_circles)

bgcolor(bool(ta.change(time("W"))) ? color.new(color.purple, 90) : na, title="New Week")
````
