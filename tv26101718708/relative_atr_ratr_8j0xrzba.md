# Relative ATR (rATR)

- url: https://www.tradingview.com/script/8J0XRzba-Relative-ATR-rATR/
- type: indicator
- pine_id: PUB;bcf6f8f3f54f42cc821bd3cb352c7115
- version: 1.0

## Description

This indicator calculates relative volatility (rATR) based on the famous ATR indicator , so it can be compared in any market. It can be customized with multiple settings.

## Source Code

````pine
//@version=6
indicator("Relative ATR (rATR)", shorttitle="rATR", overlay=false)

// Eingabeparameter
length = input.int(3, title="Period rATR", minval=1)
smoothing = input.string("EMA", title="Smoothing rATR", options=["RMA", "SMA", "EMA", "WMA"])
length2 = input.int(200, title="Period Moving Average", minval=1)
smoothing2 = input.string("EMA", title="Smoothing Moving Average", options=["RMA", "SMA", "EMA", "WMA"])

// Berechnung der relativen True Range (in Prozent)
// True Range relativ zum vorherigen Schlusskurs
relTR = 100 * (math.max(high - low, math.abs(high - close[1]), math.abs(low - close[1]))) / close[1]

// Glättungsfunktion auswählen
ma_function(source, len, type) =>
    switch type
        "RMA" => ta.rma(source, len)
        "SMA" => ta.sma(source, len)
        "EMA" => ta.ema(source, len)
        "WMA" => ta.wma(source, len)

// Relativer ATR berechnen
rATR = ma_function(relTR, length, smoothing)
rATRMa = ma_function(rATR, length2, smoothing2)

// Plot
plot(rATR, title="Relative ATR (%)", color=color.new(color.blue, 0), linewidth=2, style = plot.style_stepline)
plot(rATRMa, title="RATR Moving Average", color=color.new(color.navy, 0), linewidth=2)

// Hintergrundfarbe bei hoher Volatilität
bgcolor(rATR > rATRMa ? color.new(#d900ff, rATRMa * 100 / rATR ) : na, title="High Vola")
````
