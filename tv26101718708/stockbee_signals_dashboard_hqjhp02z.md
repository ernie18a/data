# Stockbee Signals Dashboard

- url: https://www.tradingview.com/script/hQjhP02z-Stockbee-Signals-Dashboard/
- type: indicator
- pine_id: PUB;62d1d15cde06449691cb72fff1c95ff4
- version: 1.0

## Description

[b]Stockbee Signals[/b]

Stockbee Signals combines three key Stockbee-style indicators into a single visual dashboard:

[list]
[*]TI65 – Trend strength based on short-term vs. long-term moving averages.
[*]MDT – Price position relative to the 126-day moving average.
[*]M20 – Momentum breakout/breakdown signal based on 30-day price action.
[/list]
The indicator displays each signal as a color-coded bar and provides an alert when all three signals are bullish.

Signal Colors
[list]
[*]🟢 Green = Bullish
[*]⚪ Gray = Neutral
[*]🔴 Red = Bearish
[/list]
[b]Indicator Components[/b]
[b]TI65[/b]
Measures the ratio of the 7-day moving average to the 65-day moving average.

Interpretation:
[list]
[*]Green: TI65 > 1.05
[*]Gray: TI65 between 0.95 and 1.05
[*]Red: TI65 < 0.95
[/list]
A green TI65 indicates a strong uptrend.

[b]MDT[/b]
Measures the stock price relative to its 126-day moving average.

Interpretation:
[list]
[*]Green: MDT > 1.10
[*]Gray: MDT between 0.90 and 1.10
[*]Red: MDT < 0.90
[/list]
A green MDT indicates the stock is trading significantly above its longer-term trend.

[b]M20[/b]
Identifies significant momentum moves over the previous 30 trading days.

Bullish M20 (Green):
[list]
[*]Price is at least 20% above the 30-day low, or
[*]Price has risen at least $20 from the 30-day low
[*]Minimum volume requirement is met
[/list]
Bearish M20 (Red):
[list]
[*]Price is at least 20% below the 30-day high, or
[*]Price has fallen at least $20 from the 30-day high
[*]Minimum volume requirement is met
[/list]
Neutral (Gray):
[list]
[*]Neither bullish nor bearish conditions are met
[/list]

[b]Triple Green Signal[/b]
A Triple Green Signal occurs when:
[list]
[*]TI65 is Green
[*]MDT is Green
[*]M20 is Green
[/list]
[b][i]When all three conditions are met, the indicator triggers the alert: “Stockbee Signal => GREEN”[/i][/b]

This represents alignment across trend, relative strength, and momentum. These values can be used in TradingView Pine Screener (Add as favorite to use that way). This combination identifies stocks showing strong trend, relative strength, and momentum characteristics. 
[list]
[*]I personally use it as an overlay indicator in the lower pane behind another indicator which shows only when I bring mouse-over. 
[*]When all three continues to be green helps me make decision on holding the stocks longer as the overall trend is intact and maximize returns.
[/list]
Disclaimer: This script is not validated or endrosed by Stockbee and solely based on interpretation of different videos I watched. If anyone sees the logic being inaccurate, please suggest. This tool is intended for scanning, watchlist building, and identifying stocks that may deserve further research. This indicator is for educational and research purposes only. It is not financial advice. Always perform your own analysis and risk management before making trading decisions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org
// © TXInvestor

//@version=6
indicator("Stockbee Signals", overlay = false)

// --- Colors ---
positiveColor = color.green
neutralColor  = color.gray
negativeColor = color.red
labelColor    = color.blue

// ==========================================
// 1. Calculations
// ==========================================
// TI65
TI65 = ta.sma(close, 7) / ta.sma(close, 65)
TI65_Value = math.round(TI65, 3)
TI65_Green = TI65 > 1.05
TI65Color = TI65_Green ? positiveColor : (TI65 >= 0.95 and TI65 <= 1.05 ? neutralColor : negativeColor)

// MDT
MDT = close / ta.sma(close, 126) 
MDT_Value = math.round(MDT, 3)
snes = 5  
MDT_Green = math.round(MDT, 2) > (1 + snes / 100)
MDTColor  = MDT > 1.10 ? positiveColor : (MDT >= 0.90 and MDT <= 1.10 ? neutralColor : negativeColor)

// M20
price = close
min_close_30 = ta.lowest(close, 30)
max_close_30 = ta.highest(close, 30)
min_volume_3_prev = math.min(volume[1], math.min(volume[2], volume[3]))
bullish_M20 = (price / min_close_30 >= 1.20 or price - min_close_30 >= 20) and price >= 3 and min_volume_3_prev >= 100000
bearish_M20 = (price / max_close_30 <= 0.80 or max_close_30 - price >= 20) and price >= 5 and min_volume_3_prev >= 100000
M20Color = bullish_M20 ? positiveColor : bearish_M20 ? negativeColor : neutralColor
M20_Scanner_Value = bullish_M20 ? 1.0 : bearish_M20 ? -1.0 : 0.0

// ==========================================
// VISUAL PLOTTING (Bars)
// ==========================================
// display.all - display.data_window hides these from scanner columns
hideFromScanner = display.all - display.data_window - display.status_line

plot(30, "TI65 Bar", color=color.new(TI65Color, 0), style=plot.style_columns, histbase=20, display=hideFromScanner, editable=false)
plot(20, "MDT Bar",  color=color.new(MDTColor, 0),  style=plot.style_columns, histbase=10, display=hideFromScanner, editable=false)
plot(10, "M20 Bar",  color=color.new(M20Color, 0),  style=plot.style_columns, histbase=0,  display=hideFromScanner, editable=false)

// --- Stable Dividers (Using plot.style_line as requested) ---
plot(20, "TI65 Divider", color=color.white, linewidth=1, style=plot.style_line, display=hideFromScanner)
plot(10, "MDT Divider",  color=color.white, linewidth=1, style=plot.style_line, display=hideFromScanner)

// ==========================================
// SCANNER DATA (Numeric Values Only)
// ==========================================
plot(TI65_Value,        "TI65", color=na, display=display.data_window)
plot(MDT_Value,         "MDT",  color=na, display=display.data_window)
plot(M20_Scanner_Value, "M20",  color=na, display=display.data_window)

// Labels on Last Bar
if barstate.islast
    label.new(bar_index + 1, 25, "TI65", textcolor=color.white, style=label.style_label_left, color=labelColor)
    label.new(bar_index + 1, 15, "MDT", textcolor=color.white, style=label.style_label_left, color=labelColor)
    label.new(bar_index + 1, 5,  "M20", textcolor=color.white, style=label.style_label_left, color=labelColor)

// Combined Triple Green Alert
triple_green = TI65_Green and MDT_Green and bullish_M20
alertcondition(triple_green, title="Stockbee Signal => GREEN", message="TI65, MDT, and M20 are ALL Green!")
````
