# Metis Pullback Confluence v1

- url: https://www.tradingview.com/script/CNX7Z489-Metis-Pullback-Confluence-v1/
- type: indicator
- pine_id: PUB;8331ad91b7f9454bae768c53cb407b03
- version: 3.0

## Description

A rules-based technical indicator designed to identify high-probability pullback entries within established uptrends. This screener combines multiple conditions for confluence: RSI cooling into the 35–45 range, price retracing toward the 50-day moving average, and trend confirmation above the 200-day moving average, with volume normalization as an additional filter.

The goal is to avoid chasing momentum or buying weakness blindly, and instead highlight moments where trend, momentum, and price action align. When all conditions are met, the script signals a “SETUP READY” state, helping traders focus only on disciplined, high-quality entry zones.

Built as part of the broader Métis framework, this tool emphasizes patience, structure, and repeatable decision-making over reactive trading.

## Source Code

````pine
//@version=6
indicator("Métis Pullback Confluence v1", overlay=true)

// Inputs
rsiLen = input.int(14, "RSI Length")
rsiMin = input.float(35, "RSI Min")
rsiMax = input.float(45, "RSI Max")

ma50Len = input.int(50, "Fast MA")
ma200Len = input.int(200, "Trend MA")

near50Below = input.float(5.0, "Max % Below 50MA")
near50Above = input.float(2.0, "Max % Above 50MA")

relVolLen = input.int(20, "Relative Volume Length")
relVolMin = input.float(0.8, "Min Relative Volume")

// Calculations
r = ta.rsi(close, rsiLen)
ma50 = ta.sma(close, ma50Len)
ma200 = ta.sma(close, ma200Len)

avgVol = ta.sma(volume, relVolLen)
relVol = avgVol != 0 ? volume / avgVol : na

pctFrom50 = ((close / ma50) - 1.0) * 100.0

trendOk = close > ma200 and ma50 > ma200 and ma200 > ma200[10] and ma50 > ma50[5]
rsiOk = r >= rsiMin and r <= rsiMax
priceOk = pctFrom50 >= -near50Below and pctFrom50 <= near50Above
volOk = relVol >= relVolMin

setup = trendOk and rsiOk and priceOk and volOk
newSetup = setup and not setup[1]

// Plots
plot(ma50, "SMA 50", color=color.orange, linewidth=2)
plot(ma200, "SMA 200", color=color.blue, linewidth=2)

// Background highlight
bgcolor(setup ? color.new(color.green, 85) : na)

// Triangle marker
plotshape(newSetup, title="Buy Setup", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)

// Label only on first setup bar
if newSetup
    label.new(bar_index, low, "SETUP READY",
        style=label.style_label_up,
        color=color.green,
        textcolor=color.white)

// Alerts
alertcondition(newSetup, title="Pullback Confluence Alert", message="SETUP READY: RSI 35-45 + 50MA pullback + uptrend")
````
