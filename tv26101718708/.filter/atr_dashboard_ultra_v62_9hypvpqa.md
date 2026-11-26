# ATR Dashboard Ultra V6.2

- url: https://www.tradingview.com/script/9HYpvpQa-ATR-Dashboard-Ultra-V6-2/
- type: indicator
- pine_id: PUB;5b502bd75ed54e578bb7b0f98c110ce2
- version: 3.0

## Description

This script covers all information I found important when trade a simple strategy based on EMA(20).
Instead having all indicators showing lines and values and for the traders with the basic plan what reduces the number of indicators this suits my needs when doing my analysis. 
It shows straight what I need to know without changing time frames.
Basically we can see on the table is:
 -> Macro Trend: The macro trend is defined by the Monthly, Weekly and Daily trend. I just    decided to look at the Weekly and Daily. It is enough to understand the market direction and based on that it shows which action should be taken;

-> Tools to help our decision:
ADX Momentum (Average Directional Index): it measures the market strength on an scale from 0 to 100. 
   ADX values below 20 means a weak or sideways market so no trade;
   ADX values between 20 and 25 means the market is trying to stabilize so it may worth to wait        for a better value;
   ADX values above 25 means the market is showing a better strength  and above 50 it is very strong giving us a possible good entry.
   ADX Momentum: it measures the market strength on an scale from 0 to 100. 
    ADX values below 20 means a weak or sideways market so no trade;
    ADX values between 20 and 25 means the market is trying to stabilize so it may worth to wait for a better value;
    ADX values above 25 means the market is showing a better strength  and above 50 it is very strong giving us a possible good entry.

Current time frame ATR (Average True Range): The ATR measures the market volatility meaning it shows us how much the market has moved in a period of time(usually 14 days period) and based on that we can have an idea how much "fuel" (pips) it still can move. This help us to have an idea where the market maybe will stall so we can have an informed decision for our TPs.
Also we use the ATR to calculate the "best" place for our Stop Loss. I use a 1.5 * ATR and this keeps my trade "safe" specially during the NY close where the  spread goes very high.

The indicator also shows the trading model sizing for the orders the trade use and based on the pip value for the trade currency it will calculate the size lot.

On the settings for the indicator we can find all options for the ATR  values, Trend directions with the option to define Risk/Reward and entry buffer for pending orders.
On the Risk Manager option we can select our currency, account balance and Risk %.

Note that this is an indicator that should be used with other tools like Moving Averages and Stochastics or any indicator the trade uses during analysis.
It helps me to have a straight view of some values during my analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org
// © cyberFX2019 

//@version=6
indicator("ATR Value + Fuel + True Pip Calc", "ATR Dashboard Ultra V6.2", overlay = true)

//------------------------------------------------------------
// ------ Inputs & Core Calculations
//------------------------------------------------------------
atrLength   = input.int(14, title="ATR Length", group="ATR Settings")
stoplossAtr = input.float(1.5, "S.L. ATR Multiplier", group="ATR Settings")
showtradelevels = input.bool(true, "Show Trade Levels")

//variables for Supp & Resistance
lookback4h = input.int(40, "Lookback Bars (4H TF)", minval=1)
dailyLookback = input.int(40, "Lookback Daily Bars", minval=1)
weeklylookback = input.int(40, "Look back Weekly Bars", minval = 1)
thickness = input.int(2, "Line Thickness", minval=1, maxval=5)
sideOffset = input.int(20, "Side Offset", minval=4, maxval=20)
lblsidemove = input.int(20, "Current TF side offset", maxval=40)

//colors for Supp & Resistance
// Color inputs
dailySupportColor = input.color(color.blue, "Support Color (Daily)")
dailyResistanceColor = input.color(color.rgb(8, 120, 4), "Resistance Color (Daily)")
h4SupportColor  = input.color(color.blue, "Support Color (H4)")
h4ResistanceColor = input.color(color.rgb(8, 120, 4), "Resistance Color (H4)")

// Style inputs
showDaily = input.bool(false, "Show Daily Sup/Res")
show4H = input.bool(true, "Show 4H Sup/Res")
dailyLineStyle = input.string("Dotted", "Daily Line Style", options=["Solid", "Dashed", "Dotted"])

// Convert string line style
getLineStyle(style) =>
    style == "Solid" ? line.style_solid : style == "Dashed" ? line.style_dashed : line.style_dotted

// ─── Support & Resistance ─────────────────────────────────────────────────
h4High = timeframe.period == "240" ? ta.highest(high, lookback4h) : request.security(syminfo.tickerid, "240", ta.highest(high, lookback4h))
h4Low = timeframe.period == "240" ? ta.lowest(low, lookback4h) : request.security(syminfo.tickerid, "240", ta.lowest(low, lookback4h))

if barstate.islastconfirmedhistory and show4H
    lineStyle = getLineStyle(dailyLineStyle)
    line.new(bar_index - lookback4h + 1, h4High, bar_index + 50, h4High,
        color=h4ResistanceColor, width=thickness, style=lineStyle)
    line.new(bar_index - lookback4h + 1, h4Low, bar_index + 50, h4Low,
        color=h4SupportColor, width=thickness, style=lineStyle)
    label.new(bar_index + sideOffset, h4High,
        text=str.format("H4 Resistance: {0}", str.tostring(h4High, format.mintick)),
        color=h4ResistanceColor, textcolor=color.white, style=label.style_label_down, yloc=yloc.price)
    label.new(bar_index + sideOffset, h4Low,
        text=str.format("H4 Support: {0}", str.tostring(h4Low, format.mintick)),
        color=h4SupportColor, textcolor=color.white, style=label.style_label_up, yloc=yloc.price)

dailyHigh = timeframe.period == "D" ? ta.highest(high, dailyLookback) : request.security(syminfo.tickerid, "D", ta.highest(high, dailyLookback))
dailyLow = timeframe.period == "D" ? ta.lowest(low, dailyLookback) : request.security(syminfo.tickerid, "D", ta.lowest(low, dailyLookback))

if barstate.islastconfirmedhistory and showDaily and (timeframe.period != "D")
    lineStyle = getLineStyle(dailyLineStyle)
    line.new(bar_index - dailyLookback + 1, dailyHigh, bar_index + 50, dailyHigh,
        color=dailyResistanceColor, width=thickness, style=lineStyle)
    line.new(bar_index - dailyLookback + 1, dailyLow, bar_index + 50, dailyLow,
        color=dailySupportColor, width=thickness, style=lineStyle)
    label.new(bar_index + sideOffset, dailyHigh,
        text=str.format("Daily Resistance: {0}", str.tostring(dailyHigh, format.mintick)),
        color=dailyResistanceColor, textcolor=color.white, style=label.style_label_down, yloc=yloc.price)
    label.new(bar_index + sideOffset, dailyLow,
        text=str.format("Daily Support: {0}", str.tostring(dailyLow, format.mintick)))



// Target Levels (Risk to Reward) Settings
tp1Multiplier = input.float(1.0, "TP 1 Multiplier (R/R)", minval=0.1, group="Target Matrix Levels")
tp2Multiplier = input.float(2.0, "TP 2 Multiplier (R/R)", minval=0.1, group="Target Matrix Levels")
entryBuffer   = input.float(8.0, "Entry Buffer (Pips)", minval=0.0, group="Target Matrix Levels", tooltip="Offsets the entry line above (for Buys) or below (for Sells) the current price")

// Lot Size Multiplier Toggle
lotType     = input.string("Standard (100k)", "Trading Account Lot Size", options=["Standard (100k)", "Mini (10k)", "Micro (1k)"], group="Risk Manager")

// Account metrics to dynamically update your lot sizes
accountCurr = input.string("AUD", "Account Currency", options=["AUD", "USD", "EUR", "GBP", "JPY", "CAD", "CHF", "NZD"], group="Risk Manager")
acctBalance = input.float(1504.00, "Account Balance", group="Risk Manager")
riskPercent = input.float(1.0, "Risk Percentage (%)", group="Risk Manager", minval=0.1, maxval=5.0)

// Inputs for ADX
adxLength    = input.int(14, title="ADX Length", minval=1, group="ADX Settings")
adxSmoothing = input.int(14, title="ADX Smoothing", minval=1, group="ADX Settings")

// 1. Calculate raw ATR and convert to Pips
rawAtr    = ta.atr(atrLength)
atrInPips = rawAtr / syminfo.mintick
dailyAtr  = request.security(syminfo.tickerid, "D", ta.atr(atrLength))
datrapips = dailyAtr / syminfo.mintick

formatrpips = math.round(atrInPips)
AtrDPips    = math.round(datrapips)

// Calculate DMI/ADX safely using structural calls
[diPlus, diMinus, adxValue] = ta.dmi(adxLength, adxSmoothing)

string adxlevel = " "
if na(adxValue)
    adxlevel := "LOADING"
else if adxValue < 19 
    adxlevel := "WEAK"
else if adxValue > 25
    adxlevel := "STRONG"
else
    adxlevel := "NEUTRAL"

string adxText = not na(adxValue) ? str.tostring(adxValue, "#.##") + " (" + adxlevel + ")" : "Calculating..."

// Best SL based on ATR
slok = stoplossAtr * atrInPips
formatslok = math.round(slok)
slInTruePips = formatslok / 10 // Translates standard fractional points into actual tradable pips

// Calculate price distance for Stop Loss line placement
float slDistancePrice = rawAtr * stoplossAtr

// ─── Daily/Weekly Trend & Trade Action (Moved UP to calculate before lines) ─
ema200Len    = input.int(200, "Daily EMA(200) Length", minval=1, group="EMA Distance")
dailyClosePrevious = timeframe.period == "D" ? close : request.security(syminfo.tickerid, "D", close)
dailyEma200   = timeframe.period == "D" ? ta.ema(close, ema200Len) : request.security(syminfo.tickerid, "D", ta.ema(close, ema200Len))

distEma200Raw   = dailyClosePrevious - dailyEma200
distEma200Pips  = math.round(distEma200Raw / syminfo.mintick)
distEma200Pct   = (dailyEma200 != 0) ? (distEma200Raw / dailyEma200) * 100 : 0.0

// Weekly trend direction
weeklyColor = color.black
weeklyEMA200 = request.security(syminfo.tickerid, "W", ta.ema(close, 200), lookahead=barmerge.lookahead_off)
weeklyTrendUp   = close > weeklyEMA200
weeklyTrendDown = close < weeklyEMA200

if weeklyTrendUp == true
    weeklyColor := color.green
else if weeklyTrendDown == true
    weeklyColor := color.red
else
    weeklyColor := color.gray

weeklyLabel  = weeklyTrendUp ? "↑ Bullish" : weeklyTrendDown ? "↓ Bearish" : "— Neutral"

// Daily trend direction
dailyClose = timeframe.period == "D" ? close : request.security(syminfo.tickerid, "D", close)
dailyAtrPct = (dailyClose != 0) ? (dailyAtr / dailyClose) * 100 : 0.0

dailyTrend = " "
colorTrend = color.black

if dailyClose > dailyEma200
    dailyTrend := "UP"
    colorTrend := color.green
else if dailyClose < dailyEma200
    dailyTrend := "DOWN"
    colorTrend := color.red    

// Determine Trade Action
string tradeAction = "NO TRADE"
if weeklyTrendUp == true and dailyTrend == "UP"
    tradeAction := "Only BUY"
else if weeklyTrendDown == true and dailyTrend == "DOWN"
    tradeAction := "Only SELL"

// Determine the active side for drawing lines dynamically based on trend
string activeSide = tradeAction == "Only SELL" ? "Sell" : "Buy"

// ─── EMA 21 Bounce & ADX Filter ───────────────────────────────────────────
ema21Len = input.int(21, "EMA 21 Length (Bounce)", group="EMA Distance")
ema21    = ta.ema(close, ema21Len)
plot(ema21, color=color.new(color.yellow, 0), title="EMA 21", linewidth=1)

// Bounce Definition: Candle wick touches/crosses EMA 21, but closes back on trend side
bool isBuyBounce  = low <= ema21 and close > ema21
bool isSellBounce = high >= ema21 and close < ema21

bool adxValid = not na(adxValue) and adxValue > 25

// Combine all conditions for a valid setup
bool validSetup = false
if tradeAction == "Only BUY" and adxValid and isBuyBounce
    validSetup := true
else if tradeAction == "Only SELL" and adxValid and isSellBounce
    validSetup := true

// Update Dashboard Action Text
string actionText = tradeAction
if tradeAction != "NO TRADE" and not validSetup
    if not adxValid
        actionText := tradeAction + " (Wait: ADX < 25)"
    else if tradeAction == "Only BUY" and not isBuyBounce
        actionText := tradeAction + " (Wait: EMA21 Bounce)"
    else if tradeAction == "Only SELL" and not isSellBounce
        actionText := tradeAction + " (Wait: EMA21 Bounce)"

// ─── LOCKED Trade Levels (fixed once alignment appears) ───────────────────
var float lockedEntry = na
var float lockedSL    = na
var float lockedTP1   = na
var float lockedTP2   = na
var int    lockedBar  = na
var string lockedSide = na

// Did price reach SL or TP2 since we locked?
bool slHit  = false
bool tp2Hit = false
if not na(lockedEntry)
    if lockedSide == "Buy"
        slHit  := low  <= lockedSL
        tp2Hit := high >= lockedTP2
    else
        slHit  := high >= lockedSL
        tp2Hit := low  <= lockedTP2

// Invalidate the locked setup if any of these occur:
//  (1) trend alignment broke, (2) SL hit, (3) TP2 hit, (4) side flipped
if not na(lockedEntry) and (tradeAction == "NO TRADE" or slHit or tp2Hit or lockedSide != activeSide)
    lockedEntry := na
    lockedSL    := na
    lockedTP1   := na
    lockedTP2   := na
    lockedBar   := na
    lockedSide  := na

// Lock new levels ONLY on bar close of the first aligned bar
if na(lockedEntry) and validSetup and barstate.isconfirmed
    float bufPrice  = entryBuffer * 10 * syminfo.mintick
    float basePrice = close
    lockedEntry := activeSide == "Buy" ? basePrice + bufPrice : basePrice - bufPrice
    lockedSL    := activeSide == "Buy" ? lockedEntry - slDistancePrice : lockedEntry + slDistancePrice
    lockedTP1   := activeSide == "Buy" ? lockedEntry + (slDistancePrice * tp1Multiplier) : lockedEntry - (slDistancePrice * tp1Multiplier)
    lockedTP2   := activeSide == "Buy" ? lockedEntry + (slDistancePrice * tp2Multiplier) : lockedEntry - (slDistancePrice * tp2Multiplier)
    lockedBar   := bar_index
    lockedSide  := activeSide

// ─── Drawing Straight Lines for Last 5 Bars Only ───────────────────────────
var line entry_ln = na
var line sl_ln    = na
var line tp1_ln   = na
var line tp2_ln   = na
var label entry_lbl = na
var label sl_lbl    = na
var label tp1_lbl   = na
var label tp2_lbl   = na

if barstate.islast
    // Delete previous instances to clean the chart real-time
    line.delete(entry_ln)
    line.delete(sl_ln)
    line.delete(tp1_ln)
    line.delete(tp2_ln)

    label.delete(entry_lbl)
    label.delete(sl_lbl)
    label.delete(tp1_lbl)
    label.delete(tp2_lbl)

    // Only draw if we have a valid locked setup
    if showtradelevels and not na(lockedEntry)
        // Extend the line back to where the setup was originally locked
        int startBar = math.max(bar_index - 20, lockedBar)
        int endBar   = bar_index

        entry_ln := line.new(x1=startBar, y1=lockedEntry, x2=endBar, y2=lockedEntry, xloc=xloc.bar_index, extend=extend.right, color=color.blue,  style=line.style_solid, width=2)
        sl_ln    := line.new(x1=startBar, y1=lockedSL,    x2=endBar, y2=lockedSL,    xloc=xloc.bar_index, extend=extend.right, color=color.red,   style=line.style_solid, width=2)
        tp1_ln   := line.new(x1=startBar, y1=lockedTP1,   x2=endBar, y2=lockedTP1,   xloc=xloc.bar_index, extend=extend.right, color=color.green, style=line.style_solid, width=2)
        tp2_ln   := line.new(x1=startBar, y1=lockedTP2,   x2=endBar, y2=lockedTP2,   xloc=xloc.bar_index, extend=extend.right, color=color.lime,  style=line.style_solid, width=2)

        // Labels now show FIXED prices (not chasing live price)
        string txtEntry = "Entry: " + str.tostring(lockedEntry, "#.###")
        string txtSL    = "S.L.: "   + str.tostring(lockedSL,    "#.###")
        string txtTP1   = "TP1: "   + str.tostring(lockedTP1,   "#.###")
        string txtTP2   = "TP2: "   + str.tostring(lockedTP2,   "#.###")

        entry_lbl := label.new(x=endBar, y=lockedEntry, text=txtEntry, xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=color.blue,  style=label.style_label_lower_left)
        sl_lbl    := label.new(x=endBar, y=lockedSL,    text=txtSL,    xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=color.red,   style=label.style_label_lower_left)
        tp1_lbl   := label.new(x=endBar, y=lockedTP1,   text=txtTP1,   xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=color.green, style=label.style_label_lower_left)
        tp2_lbl   := label.new(x=endBar, y=lockedTP2,   text=txtTP2,   xloc=xloc.bar_index, color=color.new(color.black, 100), textcolor=color.lime,  style=label.style_label_lower_left)

// Determine the base unit multiplier based on user input selection
float lotMultiplier = 1.00
if lotType == "Mini (10k)"
    lotMultiplier := 0.10
else if lotType == "Micro (1k)"
    lotMultiplier := 0.01

// ─── Automated Fluid Multi-Currency Cross Calculator ────────────────────────
// The quote currency of the current pair is syminfo.currency.
// Standard pip value for 1 standard lot (100k) is 10 units of the quote currency, 
// EXCEPT for JPY pairs where it's 1000 units.
float basePipValuePerLot = syminfo.currency == "JPY" ? 1000.0 : 10.0

// Safely build tickers: if currencies match, use the current chart's ticker 
// to prevent "invalid symbol AUDAUD" errors from the request.security engine.
string qCurr = str.tostring(syminfo.currency)
bool isSame  = (qCurr == accountCurr)

string ticker    = isSame ? syminfo.tickerid : (qCurr + accountCurr)
string invTicker = isSame ? syminfo.tickerid : (accountCurr + qCurr)

// Always request valid symbols to prevent runtime crashes
float fetchedRate = request.security(ticker, "D", close)
float invRate     = request.security(invTicker, "D", close)

// Calculate the final dynamic pip value (1 pip movement per 1 standard lot -> Account Currency)
float convRate = 1.0 // Default if currencies match

if not isSame
    if not na(fetchedRate) and fetchedRate > 0
        convRate := fetchedRate
    else if not na(invRate) and invRate > 0
        convRate := 1.0 / invRate

float dynamicPipValue = basePipValuePerLot * convRate * lotMultiplier

// ─── Automated Position Size Calculations ────────────────────────────────────
cashRisk   = acctBalance * (riskPercent / 100.0)

// Calculate final precise lot size using our fixed cross calculation value
rawLotSize   = (slInTruePips > 0) ? cashRisk / (slInTruePips * dynamicPipValue) : 0.0
finalLotSize = math.max(0.01, math.round(rawLotSize, 2)) // Rounds perfectly to standard 2-decimal trading lots

// ─── Visual Bar 1: Daily ATR Percentage ─────────────────────────────────────
int barSegmentsAtr = na(dailyAtrPct) ? 0 : math.max(0, math.min(10, math.round((dailyAtrPct / 1.5) * 10)))
string visualBarAtr = ""
if barSegmentsAtr > 0
    for i = 1 to barSegmentsAtr
        visualBarAtr := visualBarAtr + "█"
if barSegmentsAtr < 10
    for i = barSegmentsAtr + 1 to 10
        visualBarAtr := visualBarAtr + "░"
string dailyAtrPctText = visualBarAtr + " " + str.tostring(dailyAtrPct, "#.##") + "%"
color barColorAtr = dailyAtrPct < 0.4 ? color.gray : (dailyAtrPct < 1.0 ? color.orange : color.aqua)

// ─── Visual Bar 2: Daily Fuel Used Tracker ──────────────────────────────────
// Use 'todayHigh' and 'todayLow' so we don't conflict with the 40-day S&R 'dailyHigh' variables
todayHigh = timeframe.period == "D" ? high : request.security(syminfo.tickerid, "D", high)
todayLow  = timeframe.period == "D" ? low  : request.security(syminfo.tickerid, "D", low)
dailyRangePips = (todayHigh - todayLow) / syminfo.mintick

dailyFuelUsedPct = (datrapips != 0) ? (dailyRangePips / datrapips) * 100 : 0.0

int barSegmentsFuel = na(dailyFuelUsedPct) ? 0 : math.max(0, math.min(10, math.round((dailyFuelUsedPct / 100) * 10)))
string visualBarFuel = ""
if barSegmentsFuel > 0
    for i = 1 to barSegmentsFuel
        visualBarFuel := visualBarFuel + "█"
if barSegmentsFuel < 10
    for i = barSegmentsFuel + 1 to 10
        visualBarFuel := visualBarFuel + "░"
string dailyFuelText = visualBarFuel + " " + str.tostring(dailyFuelUsedPct, "#") + "%"
color barColorFuel = dailyFuelUsedPct < 40 ? color.green : (dailyFuelUsedPct < 80 ? color.orange : color.red)

// ─── Pips Remaining (ATR Fuel Left) ─────────────────────────────────────────
dailyPipsRemaining = math.max(0.0, datrapips - dailyRangePips)
dailyPipsRemainingTrue = dailyPipsRemaining / 10
color pipsRemainColor = dailyFuelUsedPct < 40 ? color.green : (dailyFuelUsedPct < 80 ? color.orange : color.red)

// ─── Render Information Table ───────────────────────────────────────────────
var table info = table.new(position.bottom_right, 1, 15, color.new(color.black, 100), color.blue, 2, color.green)
table.cell(info, 0, 0, "Macro Trend (W & D)", text_color = color.lime)
table.cell(info, 0, 1, "Weekly Trend → " + weeklyLabel, text_color = weeklyColor)
table.cell(info, 0, 2, "Daily Trend → " + dailyTrend, text_color = colorTrend)
table.cell(info, 0, 3, "ACTION → " + actionText, text_color = color.orange)
table.cell(info, 0, 4, "========================", text_color = color.fuchsia)
table.cell(info, 0, 5, "ADX Momentum → " + adxText, text_color = color.white)
table.cell(info, 0, 6, " TF ATR (14 Pips) → " + str.tostring(formatrpips), text_color = color.white)
table.cell(info, 0, 7, "Daily ATR → " + str.tostring(AtrDPips), text_color = barColorAtr)
table.cell(info, 0, 8, "Fuel Left → " + str.tostring(dailyPipsRemainingTrue, "#.#") + " pips", text_color = pipsRemainColor)
table.cell(info, 0, 9, "Best ATR S.L. → " + str.tostring(slInTruePips, "#.#") + " pips", text_color = color.yellow)
table.cell(info, 0, 10, "========================", text_color = color.fuchsia)
table.cell(info, 0, 11, "Trading Model Sizing: " + lotType, text_color = color.white)
table.cell(info, 0, 12, "Pip Value (" + accountCurr + "): " + str.tostring(dynamicPipValue, "#.##"), text_color = color.yellow)
table.cell(info, 0, 13, "Recommended Size: " + str.tostring(finalLotSize, "#.##") + " Lots", text_color = color.aqua)
````
