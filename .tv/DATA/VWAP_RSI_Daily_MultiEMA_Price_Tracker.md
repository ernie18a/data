<!-- tradingview-pine-id: PUB;bc57c79cbdd44ae8bcacb9d95fc7e150 -->
<!-- tradingviewscripts-format: 1 -->
# VWAP & RSI & Daily Multi-EMA Price Tracker

Source: https://www.tradingview.com/script/qb4sWL0g-Intraday-VWAP-Multi-EMA-RSI-Price-Tracker/

## Description

Overview:
The Intraday VWAP, Multi-EMA & RSI Price Tracker is a clean, non-repainting indicator designed specifically for intraday traders. It combines essential session value, momentum tracking, and higher-timeframe context to give you key dynamic support/resistance levels at a glance—without cluttering your chart with extra windows or table overlays.

 Key Features:
Intraday Session VWAP: Plots the session VWAP exclusively on intraday timeframes (1m to 240m) and automatically hides on Daily or higher charts to keep long-term charts clean.

Non-Repainting Daily EMAs: Calculates and overlays key daily Exponential Moving Averages (20, 50, 100, and 200 EMA) directly onto your intraday chart using historical daily closures ([1]). This guarantees zero real-time repainting or shifting lines.

Intraday 200 EMA: Includes a dynamic 200 EMA based on your current chart timeframe to quickly identify short-term trend bias.

Dynamic RSI Tracking: Displays a clean Relative Strength Index (RSI 14) label that dynamically updates its background color to highlight Overbought (>70) and Oversold (<30) conditions.

Clean Right-Margin Labels: Displays color-coded price labels for all active EMAs, VWAP, and RSI in the right-hand margin. Labels update in real-time and automatically delete old instances to eliminate trailing chart clutter.

Fully Customizable: Easily toggle individual EMAs, VWAP, or the RSI label on/off directly from the indicator settings menu.

📊 Indicators & Labels Included
Session VWAP (Intraday Only) – Cyan Line & Label

Intraday 200 EMA – White Line & Label

Daily 20 EMA – Yellow Line & Label

Daily 50 EMA – Orange Line & Label

Daily 100 EMA – Pink Line & Label

Daily 200 EMA – Purple Line & Label

RSI (14) – Dynamic Right-Margin Label (Green / Red / Gray)

💡 How to Use
Trend & Confluence: Check if price is holding above/below key Daily EMAs (e.g., Daily 20 or 50 EMA acting as strong dynamic support/resistance during intraday pullbacks).

Session Value: Use VWAP as your institutional benchmark for value during the trading session.

Momentum Checks: Keep an eye on the RSI margin label for quick momentum context without taking up vertical panel space at the bottom of your chart.

At-a-Glance Levels: Look at the right margin to see exact numerical price levels instantly without having to trace lines back to the Y-axis.

Disclaimer:
For Educational and Informational Purposes Only.

This script is an open-source technical analysis tool designed for charting convenience and display optimization. It does not constitute financial, investment, or trading advice. Past performance of any indicator or strategy is not indicative of future results.

Trading stocks, futures, forex, and cryptocurrencies involves substantial risk of loss and is not suitable for every investor. Always perform your own due diligence, implement strict risk management, and consult a qualified financial advisor before making any live trading decisions.

---

## Source Code

````pine
//@version=6
indicator("VWAP & RSI & Daily Multi-EMA Price Tracker", overlay = true, max_bars_back = 500, precision = 2)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
// Dynamic Intraday EMA Inputs
showIntradayEMA200  = input.bool(true, title = "Show Intraday EMA", group = "Intraday EMA Settings", inline = "iema")
ema200IntradayLen   = input.int(200, title = "Length", group = "Intraday EMA Settings", inline = "iema")

// Daily EMA Inputs
showEMAs            = input.bool(true, title = "Show Daily EMAs (Intraday Only)?", group = "Daily EMA Settings")
ema20Len            = input.int(20, title = "EMA 1 Length", group = "Daily EMA Settings")
ema50Len            = input.int(50, title = "EMA 2 Length", group = "Daily EMA Settings")
ema100Len           = input.int(100, title = "EMA 3 Length", group = "Daily EMA Settings")
ema200Len           = input.int(200, title = "EMA 4 Length", group = "Daily EMA Settings")

// RSI Inputs
showRSI             = input.bool(true, title = "Show RSI Label", group = "RSI Settings", inline = "rsi")
rsiLength           = input.int(14, title = "Length", group = "RSI Settings", inline = "rsi")

// Display Options
showVWAP            = input.bool(true, title = "Show VWAP?", group = "Display Settings")
showLabels          = input.bool(true, title = "Show Right-Margin Labels?", group = "Display Settings")

// ==========================================
// 2. INDICATOR CALCULATIONS
// ==========================================
// Dynamic Intraday EMA (Current Timeframe)
iEMA200 = ta.ema(close, ema200IntradayLen)

// Session VWAP Calculation
vwapVal = ta.vwap(close)

// RSI Calculation
rsiVal = ta.rsi(close, rsiLength)

// Non-Repainting Daily EMAs (Requested from Daily Timeframe)
dEMA20  = request.security(syminfo.tickerid, "D", ta.ema(close, ema20Len)[1], lookahead = barmerge.lookahead_on)
dEMA50  = request.security(syminfo.tickerid, "D", ta.ema(close, ema50Len)[1], lookahead = barmerge.lookahead_on)
dEMA100 = request.security(syminfo.tickerid, "D", ta.ema(close, ema100Len)[1], lookahead = barmerge.lookahead_on)
dEMA200 = request.security(syminfo.tickerid, "D", ta.ema(close, ema200Len)[1], lookahead = barmerge.lookahead_on)

// Intraday Filter
bool isIntraday = timeframe.isintraday

// ==========================================
// 3. PLOTS & STYLES
// ==========================================
color vwapColor        = #00BCD4  // Cyan
color intradayEMAColor = #FFFFFF  // White for Intraday 200 EMA
color ema20Color       = #FFEB3B  // Yellow
color ema50Color       = #FF9800  // Orange
color ema100Color      = #E91E63  // Pink
color ema200Color      = #9C27B0  // Purple

// VWAP Plot (Only shows on Intraday Timeframes)
plot(showVWAP and isIntraday ? vwapVal : na, title = "VWAP", color = vwapColor, linewidth = 2)

// Dynamic Intraday 200 EMA Plot
plot(showIntradayEMA200 and isIntraday ? iEMA200 : na, title = "Intraday 200 EMA", color = intradayEMAColor, linewidth = 2)

// Daily EMA Plots
plot(showEMAs and isIntraday ? dEMA20  : na, title = "Day 20 EMA",  color = ema20Color,  linewidth = 1)
plot(showEMAs and isIntraday ? dEMA50  : na, title = "Day 50 EMA",  color = ema50Color,  linewidth = 1)
plot(showEMAs and isIntraday ? dEMA100 : na, title = "Day 100 EMA", color = ema100Color, linewidth = 2)
plot(showEMAs and isIntraday ? dEMA200 : na, title = "Day 200 EMA", color = ema200Color, linewidth = 2)

// ==========================================
// 4. REAL-TIME RIGHT-MARGIN PRICE LABELS
// ==========================================
var label labelVWAP        = na
var label labelIntradayEMA = na
var label labelRSI         = na
var label labelEMA20       = na
var label labelEMA50       = na
var label labelEMA100      = na
var label labelEMA200      = na

if showLabels and barstate.islast and isIntraday
    // Delete existing labels to avoid trailing duplication on real-time updates
    label.delete(labelVWAP)
    label.delete(labelIntradayEMA)
    label.delete(labelRSI)
    label.delete(labelEMA20)
    label.delete(labelEMA50)
    label.delete(labelEMA100)
    label.delete(labelEMA200)

    if showVWAP
        labelVWAP := label.new(
             x = bar_index + 2, 
             y = vwapVal, 
             text = "VWAP: " + str.tostring(vwapVal, "#.##"), 
             color = vwapColor, 
             textcolor = color.black, 
             style = label.style_label_left
             )

    if showIntradayEMA200
        labelIntradayEMA := label.new(
             x = bar_index + 2, 
             y = iEMA200, 
             text = "Intraday " + str.tostring(ema200IntradayLen) + " EMA: " + str.tostring(iEMA200, "#.##"), 
             color = intradayEMAColor, 
             textcolor = color.black, 
             style = label.style_label_left
             )

    if showRSI
        color rsiBg = rsiVal > 70 ? color.red : rsiVal < 30 ? color.green : color.gray
        labelRSI := label.new(
             x = bar_index + 2, 
             y = close, 
             text = "RSI (" + str.tostring(rsiLength) + "): " + str.tostring(rsiVal, "#.##"), 
             color = rsiBg, 
             textcolor = color.white, 
             style = label.style_label_left
             )

    if showEMAs
        labelEMA20 := label.new(
             x = bar_index + 2, 
             y = dEMA20, 
             text = "Day 20 EMA: " + str.tostring(dEMA20, "#.##"), 
             color = ema20Color, 
             textcolor = color.black, 
             style = label.style_label_left
             )

        labelEMA50 := label.new(
             x = bar_index + 2, 
             y = dEMA50, 
             text = "Day 50 EMA: " + str.tostring(dEMA50, "#.##"), 
             color = ema50Color, 
             textcolor = color.white, 
             style = label.style_label_left
             )

        labelEMA100 := label.new(
             x = bar_index + 2, 
             y = dEMA100, 
             text = "Day 100 EMA: " + str.tostring(dEMA100, "#.##"), 
             color = ema100Color, 
             textcolor = color.white, 
             style = label.style_label_left
             )

        labelEMA200 := label.new(
             x = bar_index + 2, 
             y = dEMA200, 
             text = "Day 200 EMA: " + str.tostring(dEMA200, "#.##"), 
             color = ema200Color, 
             textcolor = color.white, 
             style = label.style_label_left
             )
````
