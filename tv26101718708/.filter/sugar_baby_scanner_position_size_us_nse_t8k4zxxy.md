# Sugar Baby Scanner + Position Size [US + NSE]

- url: https://www.tradingview.com/script/t8K4zxXy-Sugar-Baby-Scanner-Position-Size-US-NSE/
- type: indicator
- pine_id: PUB;5b9234bc3c9e473286b854db4b124f85
- version: 5.0

## Description

Sugar Baby Scanner + Position Size Calculator [US + NSE]  This powerful TradingView indicator helps you instantly identify Sugar Baby (high-momentum Episodic Pivot) stocks as per Stockbee methodology.Key Features:Real-time Sugar Baby Detection — Highlights candles in bright pink when a stock meets your custom conditions (Minimum Price, % Move, Volume, and Volume Increase).
Multi-Timeframe Event Counter — Shows how many Sugar Baby events occurred in:3 Years | 1 Year | 6 Months | 3 Months | 1 Month | 1 Week

Dual Market Support — One-click switch between NSE (India) and US markets with automatic default adjustments (Price & Volume).
Built-in Position Size Calculator — Instantly calculates safe position size for both India (₹) and US ($) accounts based on your capital, risk % per trade, and stop-loss %.

Customizable Inputs:Min Price, Min % Move, Min Volume (in millions)
Require Volume > Previous Day
All Lookback periods
Account Capital, Risk %, Stop Loss %

Perfect for momentum traders, swing traders, and Stockbee-style traders looking for explosive high-volume breakouts.Best used on daily timeframe.

## Source Code

````pine
//@version=6
indicator("Sugar Baby Scanner + Position Size [US + NSE]", shorttitle="SB Dual", overlay=true, max_bars_back=2000)

// ==================== MARKET MODE ====================
marketMode = input.string("NSE", "Market Mode", options=["NSE", "US"], group="Market Settings")

// ==================== Sugar Baby Conditions ====================
group_cond = "Sugar Baby Conditions"
minPrice       = input.float(10.0,  "Min Price",               group=group_cond)
minMovePct     = input.float(4.0,   "Min % Move (Up)",        group=group_cond, step=0.1)
minVolume      = input.float(4.5,   "Min Volume (Millions)",  group=group_cond, step=0.1)
useVolIncrease = input.bool(true,   "Require Volume > Prev Day", group=group_cond)

// ==================== Table Settings ====================
group_table = "Table Settings"

infoPos   = input.string("Top Right", "Info Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"], group=group_table)
psPos     = input.string("Bottom Right", "Position Size Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Top Center", "Bottom Center"], group=group_table)
themeMode = input.string("Dark", "Table Theme", options=["Dark", "Light"], group=group_table)

// ── Theme-based Colors ──
textColor   = themeMode == "Dark" ? color.white : color.black
infoBgColor = themeMode == "Dark" ? color.new(color.black, 85) : color.new(color.white, 15)
psBgColor   = themeMode == "Dark" ? color.new(color.navy, 75) : color.new(color.gray, 80)
borderColor = themeMode == "Dark" ? color.new(color.white, 70) : color.new(color.black, 70)

// ==================== getPosition Function ====================
getPosition(pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        => position.bottom_right

// ==================== Force Bar Color Priority ====================
forceColor = input.bool(true, "🔴 Force Pink Color Priority (overrides other indicators)", group="Bar Color Settings")

// ==================== Lookback Counts ====================
group_lb = "Lookback Counts"
lookback_3y = input.int(750, "3 Year Lookback (days)",  group=group_lb)
lookback_1y = input.int(250, "1 Year Lookback (days)",  group=group_lb)
lookback_6m = input.int(125, "6 Month Lookback (days)", group=group_lb)
lookback_3m = input.int(63,  "3 Month Lookback (days)", group=group_lb)
lookback_1m = input.int(22,  "1 Month Lookback (days)", group=group_lb)
lookback_1w = input.int(5,   "1 Week Lookback (days)",  group=group_lb)

// ==================== Position Size Calculator ====================
group_ps = "Position Size Calculator"
indCapital  = input.float(4000000, "India Capital (₹)", group=group_ps)
usCapital   = input.float(43000,   "US Capital ($)",    group=group_ps)
riskPct     = input.float(0.25,    "Risk per Trade (%)", group=group_ps, step=0.05)
stopLossPct = input.float(1.75,    "Stop Loss (%)",      group=group_ps, step=0.05)

// ==================== Sugar Baby Logic ====================
pctChange = ta.change(close) / close[1] * 100
isSB = (close > minPrice) and (pctChange >= minMovePct) and 
       (volume >= minVolume * 1000000) and (not useVolIncrease or volume > volume[1])

// ==================== Counts ====================
countSB(lb) => math.round(math.sum(isSB ? 1 : 0, lb))
sb_3y = countSB(lookback_3y)
sb_1y = countSB(lookback_1y)
sb_6m = countSB(lookback_6m)
sb_3m = countSB(lookback_3m)
sb_1m = countSB(lookback_1m)
sb_1w = countSB(lookback_1w)

// ==================== INFO TABLE ====================
var table info = table.new(getPosition(infoPos), 2, 8, bgcolor=infoBgColor, border_color=borderColor, border_width=1)

if barstate.islast
    string[] labels = array.from("Lookback", "SB Events", "3 Years", "1 Year", "6 Months", "3 Months", "1 Month", "1 Week")
    int[]    values = array.from(0, 0, int(sb_3y), int(sb_1y), int(sb_6m), int(sb_3m), int(sb_1m), int(sb_1w))
    
    for i = 0 to 7
        table.cell(info, 0, i, array.get(labels, i), 
             text_color=textColor, 
             text_size= i<=1 ? size.small : size.normal)
        table.cell(info, 1, i, i<=1 ? "" : str.tostring(array.get(values, i)), 
             text_color=textColor,
             text_size= i<=1 ? size.small : size.normal)

// ==================== POSITION SIZE TABLE ====================
var table psTable = table.new(getPosition(psPos), 3, 4, bgcolor=psBgColor, border_color=borderColor, border_width=1)

riskIND  = indCapital * (riskPct / 100)
riskUS   = usCapital  * (riskPct / 100)
stopDist = close * (stopLossPct / 100)
qtyIND   = riskIND / stopDist
qtyUS    = riskUS  / stopDist

// 1.5x Stop Loss Calculations
stopLossPct_1_5x = stopLossPct * 1.5
stopDist_1_5x    = close * (stopLossPct_1_5x / 100)
qtyIND_1_5x      = riskIND / stopDist_1_5x
qtyUS_1_5x       = riskUS / stopDist_1_5x

if barstate.islast
    // Row 0: Headers
    table.cell(psTable, 0, 0, "Position Size", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 1, 0, "1x SL (" + marketMode + ")", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 2, 0, "1.5x SL", text_color=textColor, text_size=size.normal)
    
    // Row 1: India
    table.cell(psTable, 0, 1, "India", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 1, 1, str.tostring(math.round(qtyIND)) + " sh", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 2, 1, str.tostring(math.round(qtyIND_1_5x)) + " sh", text_color=textColor, text_size=size.normal)
    
    // Row 2: US
    table.cell(psTable, 0, 2, "US", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 1, 2, str.tostring(math.round(qtyUS)) + " sh", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 2, 2, str.tostring(math.round(qtyUS_1_5x)) + " sh", text_color=textColor, text_size=size.normal)
    
    // Row 3: Risk / SL
    table.cell(psTable, 0, 3, "Risk / SL", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 1, 3, str.tostring(riskPct) + "% / " + str.tostring(stopLossPct) + "%", text_color=textColor, text_size=size.normal)
    table.cell(psTable, 2, 3, str.tostring(riskPct) + "% / " + str.tostring(stopLossPct_1_5x) + "%", text_color=textColor, text_size=size.normal)

// ==================== BAR COLOR ====================
barcolor(forceColor and isSB ? color.new(color.fuchsia, 0) : na, title="SB Pink Candle (Forced)")

// ==================== ALERTS ====================
if isSB and barstate.isconfirmed
    alert("🚀 Sugar Baby! " + syminfo.ticker + " +" + str.tostring(pctChange, "#.##") + "% on " + str.tostring(volume, "#,###") + " vol | Mode: " + marketMode, alert.freq_once_per_bar_close)

alertcondition(isSB, title="Sugar Baby Trigger", message="Sugar Baby detected on {{ticker}}")
````
