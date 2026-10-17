# Trend Momentum

- url: https://www.tradingview.com/script/qnxk4YQ0-Trend-Momentum/
- type: indicator
- pine_id: PUB;7e40e8e2980b4853a64de099b7d7b183
- version: 2.0

## Description

Trend Calculation: The script automatically checks if the current price meets the triple condition of momentum and structure for Bullish, if it is only above the SMA 200 for Hold, or if it has broken below all levels for Bearish.

Visual Dashboard: In the upper right corner of the chart, you will see a dynamic colored table that instantly tells you the status of the stock you are looking at.

Customization: You can change the colors or the position of the table (e.g. from position.top_right to position.bottom_left) directly from the source code.

EMA/SMA Alignment: The script also includes a plot function, so you will also see the moving average lines on the chart to visualize exactly where the "breaks" or "crossovers" occurred.

## Source Code

````pine
//@version=5
indicator("Trend Momentum", overlay=true)

// 1. Calcul Indicatori Tehnici
ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

// 2. Logică pentru Trend (Conform regulilor tale)
var string trend = "Neutral"
var color color_bg = color.gray

is_bullish = (ema9 > ema21) and (close > sma50) and (close > sma200)
is_bearish = (close < ema21) and (close < sma50) and (close < sma200)
is_hold    = (close > sma200) and not is_bullish

if is_bullish
    trend := "BULLISH"
    color_bg := color.new(color.green, 20)
else if is_bearish
    trend := "BEARISH"
    color_bg := color.new(color.red, 20)
else if is_hold
    trend := "HOLD"
    color_bg := color.new(color.orange, 20)
else
    trend := "NEUTRAL"
    color_bg := color.gray

// 3. Creare Tabel Dashboard
var table main_table = table.new(position.top_right, 2, 6, border_width = 1)

if barstate.islast
    // Cap de tabel
    table.cell(main_table, 0, 0, "Indicator", bgcolor=color.new(color.blue, 80), text_color=color.white)
    table.cell(main_table, 1, 0, "Status", bgcolor=color.new(color.blue, 80), text_color=color.white)
    
    // Rânduri Date
    
    table.cell(main_table, 0, 2, "TREND", bgcolor=color_bg, text_size=size.normal)
    table.cell(main_table, 1, 2, trend, bgcolor=color_bg, text_size=size.normal, text_color=color.white)
    
    table.cell(main_table, 0, 3, "Momentum", bgcolor=color.new(color.gray, 90))
    table.cell(main_table, 1, 3, ema9 > ema21? "Pozitiv" : "Negativ", text_color = ema9 > ema21? color.green : color.red)
    
    table.cell(main_table, 0, 4, "SMA 50", bgcolor=color.new(color.gray, 90))
    table.cell(main_table, 1, 4, close > sma50? "Peste" : "Sub", text_color = close > sma50? color.green : color.red)
    
    table.cell(main_table, 0, 5, "SMA 200", bgcolor=color.new(color.gray, 90))
    table.cell(main_table, 1, 5, close > sma200? "Peste" : "Sub", text_color = close > sma200? color.green : color.red)

// 4. Afișare linii pe grafic (Opțional, pot fi ascunse din setări)
plot(ema9, color=color.yellow, title="EMA 9")
plot(ema21, color=color.orange, title="EMA 21")
plot(sma50, color=color.aqua, title="SMA 50", linewidth=2)
plot(sma200, color=color.navy, title="SMA 200", linewidth=3)
````
