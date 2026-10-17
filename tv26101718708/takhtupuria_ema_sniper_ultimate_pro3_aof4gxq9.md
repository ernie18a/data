# Takhtupuria EMA Sniper Ultimate Pro..3

- url: https://www.tradingview.com/script/aoF4gxQ9-Takhtupuria-EMA-Sniper-Ultimate-Pro-3/
- type: indicator
- pine_id: PUB;bdf851f134054df5b7f974f361876965
- version: 1.0

## Description

EMA Sniper Ultimate Pro
This is a specialized, high-precision EMA Sniper tool designed for traders who rely on clean EMA crossovers and automated visual signal confirmation. It filters out market noise to highlight the most reliable entry and exit points.
Key Features:
 EMA Trend Engine: Utilizes the 21 EMA and 200 EMA to establish the primary market trend, ensuring you always trade in the direction of the institutional flow.
 Automated Sniper Signals: Features clear, integrated Buy and Sell signals (plotted as shapes) based on EMA crossover logic. This helps in identifying trend reversals instantly.
 Clean Visuals: Optimized for a clutter-free chart, providing just the essential data needed for high-accuracy decision-making.
Customization & Control:
 Signal Customization: Easily toggle the Buy and Sell signal shapes or change their colors from the Style tab to match your specific chart setup.
 Precision: Users have full control over the EMA inputs and label settings, allowing this tool to adapt to any time frame, from scalping to swing trading.
Designed by Takhtupuria to provide traders with a powerful, automated signal system that simplifies technical analysis.

## Source Code

````pine
//@version=5
indicator("EMA Sniper Ultimate Pro", overlay=true)

// ਇਨਪੁਟਸ
emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 200)

// 1. ਕੈਂਡਲ ਦੀ 21 EMA ਤੋਂ ਦੂਰੀ (High/Low ਦੇ ਹਿਸਾਬ ਨਾਲ)
candleDeviation = (close > emaFast) ? ((high - emaFast) / emaFast) * 100 : ((low - emaFast) / emaFast) * 100
// 2. 21 EMA ਦੀ 200 EMA ਤੋਂ ਦੂਰੀ (Spread)
emaSpread = ((emaFast - emaSlow) / emaSlow) * 100

// ਸਿਗਨਲ ਵੇਰੀਏਬਲ
var bool inTrade = false
buySignal = (emaFast > emaSlow) and (close > emaFast) and not inTrade
sellSignal = (emaFast < emaSlow) and (close < emaFast) and not inTrade
// ਟੱਚ ਕੰਡੀਸ਼ਨ: ਜੇ ਹਰੀ ਕੈਂਡਲ ਦਾ ਲੋ 21 EMA ਨੂੰ ਟੱਚ ਕਰੇ ਜਾਂ ਰੈੱਡ ਦਾ ਹਾਈ 
touchEma = (close <= emaFast and emaFast > emaSlow) or (close >= emaFast and emaFast < emaSlow)

// ਸਿਗਨਲ ਅਤੇ ਅਲਰਟ ਲਾਜਿਕ
if buySignal
    inTrade := true
    alert("BUY SIGNAL Triggered", alert.freq_once_per_bar_close)

if sellSignal
    inTrade := true
    alert("SELL SIGNAL Triggered", alert.freq_once_per_bar_close)

if touchEma
    inTrade := false

// ਚਾਰਟ ਤੇ ਲੇਬਲ
// ਕੈਂਡਲ ਦੀ deviation
label.new(bar_index, (close > emaFast ? high : low), text=str.tostring(math.round(candleDeviation, 2)) + "%", 
     color=candleDeviation > 0 ? color.green : color.red, textcolor=color.white, style=label.style_label_down, size=size.tiny)

// 21 EMA ਦੇ ਮੂਹਰੇ EMA Spread ਲਿਖਣਾ
var label spreadLabel = label.new(bar_index, emaFast, text="", color=color.blue, textcolor=color.white, style=label.style_label_left, size=size.normal)
label.set_xy(spreadLabel, bar_index, emaFast)
label.set_text(spreadLabel, "Spread: " + str.tostring(math.round(emaSpread, 2)) + "%")

// ਪਲੌਟਿੰਗ
plot(emaFast, color=color.blue, linewidth=2, title="21 EMA")
plot(emaSlow, color=color.white, linewidth=2, title="200 EMA")
plotshape(buySignal, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Buy Signal")
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Sell Signal")
````
