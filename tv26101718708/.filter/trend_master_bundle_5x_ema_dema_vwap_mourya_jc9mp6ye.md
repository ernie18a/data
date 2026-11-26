# Trend Master Bundle (5x EMA, DEMA & VWAP) | Mourya

- url: https://www.tradingview.com/script/jC9Mp6yE-Trend-Master-Bundle-5x-EMA-DEMA-VWAP-Mourya/
- type: indicator
- pine_id: PUB;e60db2b548ef40ae99915ff1b107252f
- version: 1.0

## Description

The Trend Master Bundle is a comprehensive, trend-following utility designed to visualize perfect moving average alignment and volume-weighted momentum. By integrating multiple exponential moving averages, a double exponential moving average, and standard deviation VWAP bands, this tool provides a clear, quantitative view of both macro trend direction and intraday mean-reversion zones.

The "Perfect Alignment" Strategy
The core algorithmic logic of this indicator detects strict momentum states where the moving averages fan out in a specific sequence:

Extremely Bullish: Identified when the current price sits above the moving averages, and the MAs are stacked in strict ascending order: 5 EMA > 10 EMA > 20 EMA > 50 EMA > 100 DEMA > 200 EMA. This structural alignment indicates a dominant uptrend.

Extremely Bearish: Identified when the price remains below the moving averages, and they are stacked in descending order: 5 EMA < 10 EMA < 20 EMA < 50 EMA < 100 DEMA < 200 EMA.

Core Indicator Components

5x Exponential Moving Averages: Standard institutional lengths (5, 10, 20, 50, 200) serve as dynamic support and resistance layers.

100-Period DEMA: The Double Exponential Moving Average is utilized to reduce the lag inherent in standard EMAs. It reacts faster to price changes, serving as a highly responsive lead indicator for mid-to-long-term trend transitions.

VWAP with Standard Deviation Bands: The anchored Volume Weighted Average Price calculates the asset's true fair value based on volume and price. The surrounding standard deviation bands help measure market volatility and extension.

Upgraded Visual Features

End-of-Line Tracking Labels: Dynamic text labels automatically track the most recent candle, floating the name of each specific moving average (e.g., "EMA 50", "VWAP") directly at the end of its respective line for instant visual identification.

Dynamic Premium Dashboard: A sleek, non-intrusive dark-mode widget provides a real-time readout of the current trend state (Extremely Bullish, Extremely Bearish, or Neutral) and lists the exact current price values for all active moving averages.

Full Customisation: Every MA length, colour, VWAP anchor, and UI element can be toggled or adjusted via the indicator settings menu to suit individual charting preferences.

Practical Application

Trend Confirmation: Traders can use the dashboard to ensure they are trading in the direction of the dominant momentum.

Pullback Entries: During a confirmed "Extremely Bullish" or "Extremely Bearish" state, the 20 EMA and VWAP baseline often act as areas of interest for trend-continuation setups.

Mean Reversion: Price interaction with the outer VWAP standard deviation bands (Bands #2 and #3) can signal statistically overextended market conditions, helping identify potential exhaustion points or mean-reversion opportunities.

## Source Code

````pine
//@version=6
indicator(title="Trend Master Bundle (5x EMA, DEMA & VWAP) | Mourya", shorttitle="Trend Master Bundle | Mourya", overlay=true)

// --- INPUTS ---
srcGlobal = input.source(close, title="MA Source")

showEma1   = input.bool(true, "", inline="ema1")
ema1Len    = input.int(5, "EMA 1", minval=1, inline="ema1")
ema1Color  = input.color(color.new(#00bcd4, 0), "", inline="ema1")

showEma2   = input.bool(true, "", inline="ema2")
ema2Len    = input.int(10, "EMA 2", minval=1, inline="ema2")
ema2Color  = input.color(color.new(#2196f3, 0), "", inline="ema2")

showEma3   = input.bool(true, "", inline="ema3")
ema3Len    = input.int(20, "EMA 3", minval=1, inline="ema3")
ema3Color  = input.color(color.new(#4caf50, 0), "", inline="ema3")

showEma4   = input.bool(true, "", inline="ema4")
ema4Len    = input.int(50, "EMA 4", minval=1, inline="ema4")
ema4Color  = input.color(color.new(#ffeb3b, 0), "", inline="ema4")

showEma5   = input.bool(true, "", inline="ema5")
ema5Len    = input.int(200, "EMA 5", minval=1, inline="ema5")
ema5Color  = input.color(color.new(#f44336, 0), "", inline="ema5")

showDema   = input.bool(true, "", inline="dema")
demaLen    = input.int(100, "DEMA", minval=1, inline="dema")
demaColor  = input.color(color.new(#e91e63, 0), "", inline="dema")

// --- VWAP SETTINGS ---
GRP_VWAP   = "VWAP Settings"
hideonDWM  = input.bool(false, "Hide VWAP on 1D or Above", group=GRP_VWAP)
vwapAnchor = input.string("Session", "Anchor Period", options=["Session", "Week", "Month", "Year"], group=GRP_VWAP)
vwapSrc    = input.source(hlc3, "VWAP Source", group=GRP_VWAP)
calcMode   = input.string("Standard Deviation", "Bands Mode", options=["Standard Deviation", "Percentage"], group=GRP_VWAP)

showBand_1 = input.bool(true, "Bands Multiplier #1", inline="band1", group=GRP_VWAP)
bandMult_1 = input.float(1.0, "", step=0.5, inline="band1", group=GRP_VWAP)

showBand_2 = input.bool(false, "Bands Multiplier #2", inline="band2", group=GRP_VWAP)
bandMult_2 = input.float(2.0, "", step=0.5, inline="band2", group=GRP_VWAP)

showBand_3 = input.bool(false, "Bands Multiplier #3", inline="band3", group=GRP_VWAP)
bandMult_3 = input.float(3.0, "", step=0.5, inline="band3", group=GRP_VWAP)

// --- LABEL & UI SETTINGS ---
GRP_LABELS     = "UI & Label Settings"
showLabels     = input.bool(true, "Show Trend Status Dashboard", group=GRP_LABELS)
showValues     = input.bool(true, "Show MA Values in Dashboard", group=GRP_LABELS)
showLineLabels = input.bool(true, "Show Names at End of Lines", group=GRP_LABELS)

// --- CALCULATIONS ---
ema1 = ta.ema(srcGlobal, ema1Len)
ema2 = ta.ema(srcGlobal, ema2Len)
ema3 = ta.ema(srcGlobal, ema3Len)
ema4 = ta.ema(srcGlobal, ema4Len)
ema5 = ta.ema(srcGlobal, ema5Len)

e1 = ta.ema(srcGlobal, demaLen)
e2 = ta.ema(e1, demaLen)
demaVal = 2 * e1 - e2

isNewPeriod = timeframe.change(vwapAnchor == "Session" ? "D" : vwapAnchor == "Week" ? "W" : vwapAnchor == "Month" ? "M" : "12M")
float vwapValue = na
float up1 = na, float lo1 = na
float up2 = na, float lo2 = na
float up3 = na, float lo3 = na

if not (hideonDWM and timeframe.isdwm)
    [v, _up, _] = ta.vwap(vwapSrc, isNewPeriod, 1)
    vwapValue := v
    stdevAbs = _up - v
    bandBasis = calcMode == "Standard Deviation" ? stdevAbs : v * 0.01
    up1 := v + bandBasis * bandMult_1
    lo1 := v - bandBasis * bandMult_1
    up2 := v + bandBasis * bandMult_2
    lo2 := v - bandBasis * bandMult_2
    up3 := v + bandBasis * bandMult_3
    lo3 := v - bandBasis * bandMult_3

// --- TREND & ALERTS ---
isBullish = close > ema1 and ema1 > ema2 and ema2 > ema3 and ema3 > ema4 and ema4 > demaVal and demaVal > ema5
isBearish = close < ema1 and ema1 < ema2 and ema2 < ema3 and ema3 < ema4 and ema4 < demaVal and demaVal < ema5

alertcondition(isBullish and not isBullish[1], "Bullish Start", "Extreme Bullish Trend Started")
alertcondition(isBearish and not isBearish[1], "Bearish Start", "Extreme Bearish Trend Started")

// --- PLOTTING ---
plot(showEma1 ? ema1 : na, "EMA 1", color=ema1Color)
plot(showEma2 ? ema2 : na, "EMA 2", color=ema2Color)
plot(showEma3 ? ema3 : na, "EMA 3", color=ema3Color)
plot(showEma4 ? ema4 : na, "EMA 4", color=ema4Color, linewidth=2)
plot(showEma5 ? ema5 : na, "EMA 5", color=ema5Color, linewidth=2)
plot(showDema ? demaVal : na, "DEMA", color=demaColor, linewidth=2)

p_vwap = plot(vwapValue, "VWAP", color=#2962FF, linewidth=2)
p_up1 = plot(showBand_1 ? up1 : na, "Upper Band #1", color=color.new(#26a69a, 0))
p_lo1 = plot(showBand_1 ? lo1 : na, "Lower Band #1", color=color.new(#26a69a, 0))
fill(p_up1, p_lo1, color.new(#26a69a, 90), title="Bands Fill #1")

p_up2 = plot(showBand_2 ? up2 : na, "Upper Band #2", color=color.new(#787b86, 0))
p_lo2 = plot(showBand_2 ? lo2 : na, "Lower Band #2", color=color.new(#787b86, 0))
fill(p_up2, p_lo2, color.new(#787b86, 90), title="Bands Fill #2")

p_up3 = plot(showBand_3 ? up3 : na, "Upper Band #3", color=color.new(#ef5350, 0))
p_lo3 = plot(showBand_3 ? lo3 : na, "Lower Band #3", color=color.new(#ef5350, 0))
fill(p_up3, p_lo3, color.new(#ef5350, 90), title="Bands Fill #3")


// --- END-OF-LINE LABELS ---
// Using color.new(color.white, 100) makes the background completely transparent, leaving only the text.
var label l_ema1 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ema1Color, size=size.small)
var label l_ema2 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ema2Color, size=size.small)
var label l_ema3 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ema3Color, size=size.small)
var label l_ema4 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ema4Color, size=size.small)
var label l_ema5 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=ema5Color, size=size.small)
var label l_dema = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=demaColor, size=size.small)
var label l_vwap = label.new(na, na, "", style=label.style_label_left, color=color.new(color.white, 100), textcolor=#2962FF, size=size.small)

if barstate.islast and showLineLabels
    if showEma1
        label.set_xy(l_ema1, bar_index + 2, ema1)
        label.set_text(l_ema1, "EMA " + str.tostring(ema1Len))
    if showEma2
        label.set_xy(l_ema2, bar_index + 2, ema2)
        label.set_text(l_ema2, "EMA " + str.tostring(ema2Len))
    if showEma3
        label.set_xy(l_ema3, bar_index + 2, ema3)
        label.set_text(l_ema3, "EMA " + str.tostring(ema3Len))
    if showEma4
        label.set_xy(l_ema4, bar_index + 2, ema4)
        label.set_text(l_ema4, "EMA " + str.tostring(ema4Len))
    if showEma5
        label.set_xy(l_ema5, bar_index + 2, ema5)
        label.set_text(l_ema5, "EMA " + str.tostring(ema5Len))
    if showDema
        label.set_xy(l_dema, bar_index + 2, demaVal)
        label.set_text(l_dema, "DEMA " + str.tostring(demaLen))
    if not na(vwapValue)
        label.set_xy(l_vwap, bar_index + 2, vwapValue)
        label.set_text(l_vwap, "VWAP")


// --- DYNAMIC PREMIUM DASHBOARD ---
// Creating a sleek, dark-themed frosted glass look
var color widgetBg = color.rgb(19, 23, 34, 15) // Deep TradingView Dark with slight transparency
var table trendTable = table.new(position.top_right, 2, 8, bgcolor=widgetBg, border_width=0, frame_color=color.rgb(42, 46, 57, 30), frame_width=1)

if showLabels
    txt = isBullish ? "EXTREMELY BULLISH" : isBearish ? "EXTREMELY BEARISH" : "NEUTRAL"
    bgC = isBullish ? color.new(#089981, 70) : isBearish ? color.new(#f23645, 70) : color.new(#787b86, 70)
    
    // Dashboard Title
    table.cell(trendTable, 0, 0, "TREND MASTER", text_color=color.new(color.white, 30), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(trendTable, 0, 0, 1, 0)

    // Main Trend Indicator
    table.cell(trendTable, 0, 1, txt, bgcolor=bgC, text_color=color.white, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(trendTable, 0, 1, 1, 1) 
    
    // Moving Average Values (Clean format without borders)
    if showValues
        table.cell(trendTable, 0, 2, "EMA " + str.tostring(ema1Len), text_color=ema1Color, text_size=size.small, text_halign=text.align_left)
        table.cell(trendTable, 1, 2, str.tostring(ema1, format.mintick), text_color=color.new(color.white, 10), text_size=size.small, text_halign=text.align_right)
        
        table.cell(trendTable, 0, 3, "EMA " + str.tostring(ema2Len), text_color=ema2Color, text_size=size.small, text_halign=text.align_left)
        table.cell(trendTable, 1, 3, str.tostring(ema2, format.mintick), text_color=color.new(color.white, 10), text_size=size.small, text_halign=text.align_right)
        
        table.cell(trendTable, 0, 4, "EMA " + str.tostring(ema3Len), text_color=ema3Color, text_size=size.small, text_halign=text.align_left)
        table.cell(trendTable, 1, 4, str.tostring(ema3, format.mintick), text_color=color.new(color.white, 10), text_size=size.small, text_halign=text.align_right)
        
        table.cell(trendTable, 0, 5, "EMA " + str.tostring(ema4Len), text_color=ema4Color, text_size=size.small, text_halign=text.align_left)
        table.cell(trendTable, 1, 5, str.tostring(ema4, format.mintick), text_color=color.new(color.white, 10), text_size=size.small, text_halign=text.align_right)
        
        table.cell(trendTable, 0, 6, "EMA " + str.tostring(ema5Len), text_color=ema5Color, text_size=size.small, text_halign=text.align_left)
        table.cell(trendTable, 1, 6, str.tostring(ema5, format.mintick), text_color=color.new(color.white, 10), text_size=size.small, text_halign=text.align_right)
        
        table.cell(trendTable, 0, 7, "DEMA " + str.tostring(demaLen), text_color=demaColor, text_size=size.small, text_halign=text.align_left)
        table.cell(trendTable, 1, 7, str.tostring(demaVal, format.mintick), text_color=color.new(color.white, 10), text_size=size.small, text_halign=text.align_right)
````
