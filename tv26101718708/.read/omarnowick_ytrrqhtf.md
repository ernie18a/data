# omarnowick

- url: https://www.tradingview.com/script/yTrRQHtf-omarnowick/
- type: indicator
- pine_id: PUB;b6cc3566f7f54b58bd61749b39ee954d
- version: 2.0

## Description

Description:

This indicator combines several price action tools designed to help traders analyze market structure, momentum candles, and trading sessions directly on the chart.

The script highlights structural shifts in price, identifies strong momentum candles, and provides additional tools for session awareness and risk management.

Features:

1) No Wick Momentum Candles

The script detects candles where the open equals the high or low.
These candles often indicate strong directional pressure because price moves immediately in one direction without initial rejection.

Triangles are plotted on these candles to highlight potential momentum moves.

2) Market Structure (HH / HL / LH / LL)

Swing highs and lows are detected using pivot logic.
Based on these pivots, the indicator labels the current market structure:

Higher High (HH) (made the color more customizable)

Higher Low (HL) (made the color more customizable)

Lower High (LH) (made the color more customizable)

Lower Low (LL) (made the color more customizable)

This helps traders visually follow trend direction.

3) Break of Structure (BOS) & Change of Character (CHOCH)

When price breaks previously identified structural levels, the script marks the event as either:

Break of Structure (BOS) – continuation of the current trend

Change of Character (CHOCH) – potential early shift in market direction

Lines are drawn to show where the structural break occurred.

4) Trading Sessions

The indicator can highlight major trading sessions:

Asia

London

New York

Session backgrounds help visualize periods of higher market activity.

5) Session Break Zone

A customizable time range can be displayed as a No Trading Zone to highlight periods where a trader may prefer to avoid trading.

The script can also project the next upcoming zone into the future.

6) Risk Dashboard

A built-in risk calculator displays:

Account balance

Risk percentage

Stop loss size

Calculated lot size

This allows traders to quickly estimate position size based on their risk parameters.

7) Manual Backtest Dashboard

A simple dashboard allows traders to manually track wins and losses when reviewing historical trades, automatically calculating total trades and win rate.

Notes:

This indicator is designed as a chart analysis tool and should be used alongside a trader’s own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("omarnowick", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
getPipSize(goldMode, silverMode) =>
    bool isGold = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
    bool isSilver = str.contains(syminfo.ticker, "XAG") or str.contains(syminfo.ticker, "SILVER")
    float goldVal = goldMode == "Standard ($0.10)" ? 0.1 : 0.01
    float silverVal = silverMode == "Standard ($0.01)" ? 0.01 : 0.001
    isGold ? goldVal : isSilver ? silverVal : (syminfo.mintick * (syminfo.type == "forex" or syminfo.type == "cfd" ? 10 : 1))

getTextSize(sizeStr) =>
    sizeStr == "Tiny" ? size.tiny : sizeStr == "Small" ? size.small : sizeStr == "Large" ? size.large : sizeStr == "Huge" ? size.huge : size.normal

// Calculates exact millisecond duration of a session for perfect center anchoring
getZoneDuration(sessStr) =>
    string zt = str.substring(sessStr, 0, 9)
    int sH = int(str.tonumber(str.substring(zt, 0, 2)))
    int sM = int(str.tonumber(str.substring(zt, 2, 4)))
    int eH = int(str.tonumber(str.substring(zt, 5, 7)))
    int eM = int(str.tonumber(str.substring(zt, 7, 9)))
    int startMinutes = sH * 60 + sM
    int endMinutes = eH * 60 + eM
    if endMinutes < startMinutes
        endMinutes += 24 * 60
    (endMinutes - startMinutes) * 60000

// ============================================================================
// INPUTS
// ============================================================================

// --- RISK CALCULATOR SETTINGS ---
grpRiskMain  = "Risk Dashboard: Main Settings"
showRiskDash = input.bool(true, title="Risk Dashboard", group=grpRiskMain)
accountCurr  = input.string("USD", title="Account Currency", options=["USD", "EUR", "GBP", "AUD", "CAD", "CHF", "JPY", "NZD"], tooltip="Select your account currency to auto-calculate exact real-time lot sizes.", group=grpRiskMain)
slPips       = input.float(30.6, title="Stop Loss (Pips)", group=grpRiskMain)

grpRiskPct   = "Risk Dashboard: Account Balance & Risk"
accountBal   = input.float(100000, title="Account Balance", group=grpRiskPct)
riskPercent  = input.float(2.0, title="Percentage Risk (%)", step=0.01, group=grpRiskPct)

grpRiskMetals = "Risk Dashboard: Gold & Silver Settings"
goldPipMode  = input.string("Standard ($0.10)", title="Gold Pip Size", options=["Standard ($0.10)", "Micro ($0.01)"], tooltip="Adjust this if your broker calculates Gold pips differently.", group=grpRiskMetals)
silverPipMode = input.string("Standard ($0.01)", title="Silver Pip Size", options=["Standard ($0.01)", "Micro ($0.001)"], tooltip="Adjust this if your broker calculates Silver pips differently.", group=grpRiskMetals)

// --- QUICK BACKTEST SETTINGS ---
grpBacktest  = "Win Rate Dashboard"
showBacktest = input.bool(false, title="Win Rate Dashboard", group=grpBacktest)
btWins       = input.int(0, title="Total Wins", minval=0, group=grpBacktest)
btLosses     = input.int(0, title="Total Losses", minval=0, group=grpBacktest)

// --- Universal Session Settings ---
grpSessText = "Global Session Label Settings"
sessTextColor   = input.color(color.new(#912424, 57), title="Session Text Color", group=grpSessText)
sessTextSizeStr = input.string("Normal", title="Session Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grpSessText)
zoneTz          = input.string("America/New_York", title="Timezone", tooltip="Master clock for all sessions. Leave as America/New_York to ensure zone times draw accurately regardless of your local timezone.", group=grpSessText)

// --- Session Break Zone (No Trading Zone) ---
grpZone = "Session Break Zone"
showZone        = input.bool(true, title="Enable Session Break Background", group=grpZone)
showZoneText    = input.bool(true, title="Show 'No Trading Zone' Text", group=grpZone)
zoneTime        = input.session("1500-1900", title="Zone Hours (HHMM-HHMM)", group=grpZone)
zoneColor       = input.color(color.new(#912424, 82), title="Zone Background Color", group=grpZone) 

// --- Asia Session ---
grpAsia = "Asia Session"
showAsia      = input.bool(false, title="Enable Asia Background", group=grpAsia)
showAsiaText  = input.bool(false, title="Show 'ASIA' Text", group=grpAsia)
asiaTime      = input.session("1800-0200", title="Asia Hours", group=grpAsia)
asiaColor     = input.color(color.new(color.blue, 85), title="Asia Color", group=grpAsia)

// --- London Session ---
grpLon = "London Session"
showLon       = input.bool(false, title="Enable London Background", group=grpLon)
showLonText   = input.bool(false, title="Show 'LONDON' Text", group=grpLon)
lonTime       = input.session("0300-0900", title="London Hours", group=grpLon)
lonColor      = input.color(color.new(color.gray, 85), title="London Color", group=grpLon)

// --- New York Session ---
grpNY = "New York Session"
showNY        = input.bool(false, title="Enable New York Background", group=grpNY)
showNYText    = input.bool(false, title="Show 'NEW YORK' Text", group=grpNY)
nyTime        = input.session("0800-1700", title="New York Hours", group=grpNY)
nyColor       = input.color(color.new(color.green, 85), title="New York Color", group=grpNY)

// --- Arrow Settings ---
grpArr = "No-Wick Open Triangles"
showNoWick      = input.bool(true, title="Show No-Wick Triangles", group=grpArr)
arrowSizeStr    = input.string("Small", title="Triangle Size", options=["Small", "Normal"], group=grpArr)
bullArrowColor  = input.color(color.green, title="Bullish Color", group=grpArr)
bearArrowColor  = input.color(color.red, title="Bearish Color", group=grpArr)


// ============================================================================
// DYNAMIC INTELLIGENCE LOGIC (Auto-detects Gold/Silver properties)
// ============================================================================
bool isGoldChart   = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
bool isSilverChart = str.contains(syminfo.ticker, "XAG") or str.contains(syminfo.ticker, "SILVER")
int pipOffset      = isGoldChart ? 1000 : isSilverChart ? 400 : 50

// If chart is a Metal and user hasn't touched the default zone time, push the end time forward 
// exactly 1 hour (20:00) to account for the 17:00-18:00 daily close, restoring perfect centering!
string activeZoneTime = (isGoldChart or isSilverChart) and zoneTime == "1500-1900" ? "1500-2000" : zoneTime


// ============================================================================
// SESSION LOGIC (Historical Backgrounds with Absolute Centering)
// ============================================================================
inZone = time(timeframe.period, activeZoneTime, zoneTz)
bgcolor(showZone and not na(inZone) ? zoneColor : na)
var float zHigh = 0.0, var int zMid = na, var label zLbl = na
if not na(inZone) and na(inZone[1])
    zHigh := high, zMid := time + math.round(getZoneDuration(activeZoneTime) / 2)
    if showZoneText
        zLbl := label.new(zMid, high, "NO TRADING ZONE", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=sessTextColor, style=label.style_none, size=getTextSize(sessTextSizeStr), textalign=text.align_center)
if not na(inZone)
    zHigh := math.max(zHigh, high)
    if showZoneText and not na(zLbl)
        label.set_xy(zLbl, zMid, zHigh + (getPipSize(goldPipMode, silverPipMode) * pipOffset))

inAsia = time(timeframe.period, asiaTime, zoneTz)
bgcolor(showAsia and not na(inAsia) ? asiaColor : na)
var float aHigh = 0.0, var int aMid = na, var label aLbl = na
if not na(inAsia) and na(inAsia[1])
    aHigh := high, aMid := time + math.round(getZoneDuration(asiaTime) / 2)
    if showAsiaText
        aLbl := label.new(aMid, high, "ASIA", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=sessTextColor, style=label.style_none, size=getTextSize(sessTextSizeStr), textalign=text.align_center)
if not na(inAsia)
    aHigh := math.max(aHigh, high)
    if showAsiaText and not na(aLbl)
        label.set_xy(aLbl, aMid, aHigh + (getPipSize(goldPipMode, silverPipMode) * pipOffset))

inLon = time(timeframe.period, lonTime, zoneTz)
bgcolor(showLon and not na(inLon) ? lonColor : na)
var float lHigh = 0.0, var int lMid = na, var label lLbl = na
if not na(inLon) and na(inLon[1])
    lHigh := high, lMid := time + math.round(getZoneDuration(lonTime) / 2)
    if showLonText
        lLbl := label.new(lMid, high, "LONDON", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=sessTextColor, style=label.style_none, size=getTextSize(sessTextSizeStr), textalign=text.align_center)
if not na(inLon)
    lHigh := math.max(lHigh, high)
    if showLonText and not na(lLbl)
        label.set_xy(lLbl, lMid, lHigh + (getPipSize(goldPipMode, silverPipMode) * pipOffset))

inNY = time(timeframe.period, nyTime, zoneTz)
bgcolor(showNY and not na(inNY) ? nyColor : na)
var float nHigh = 0.0, var int nMid = na, var label nLbl = na
if not na(inNY) and na(inNY[1])
    nHigh := high, nMid := time + math.round(getZoneDuration(nyTime) / 2)
    if showNYText
        nLbl := label.new(nMid, high, "NEW YORK", xloc=xloc.bar_time, color=color.new(color.white, 100), textcolor=sessTextColor, style=label.style_none, size=getTextSize(sessTextSizeStr), textalign=text.align_center)
if not na(inNY)
    nHigh := math.max(nHigh, high)
    if showNYText and not na(nLbl)
        label.set_xy(nLbl, nMid, nHigh + (getPipSize(goldPipMode, silverPipMode) * pipOffset))

// ============================================================================
// FUTURE SESSION PROJECTION LOGIC (Goalposts)
// ============================================================================
var line fStartLine = line.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.both, width=2)
var line fEndLine   = line.new(na, na, na, na, xloc=xloc.bar_time, extend=extend.both, width=2)
var label fZoneLbl  = label.new(na, na, "NO TRADING ZONE", xloc=xloc.bar_time, textcolor=sessTextColor, style=label.style_none, size=getTextSize(sessTextSizeStr), textalign=text.align_center)

if barstate.islast and showZone
    color solidZoneColor = color.rgb(color.r(zoneColor), color.g(zoneColor), color.b(zoneColor), 15)

    string zt = str.substring(activeZoneTime, 0, 9) 
    int sH = int(str.tonumber(str.substring(zt, 0, 2)))
    int sM = int(str.tonumber(str.substring(zt, 2, 4)))
    int eH = int(str.tonumber(str.substring(zt, 5, 7)))
    int eM = int(str.tonumber(str.substring(zt, 7, 9)))
    
    int tYear = year(time, zoneTz)
    int tMonth = month(time, zoneTz)
    int tDay = dayofmonth(time, zoneTz)
    
    int nextStart = timestamp(zoneTz, tYear, tMonth, tDay, sH, sM, 0)
    int nextEnd   = timestamp(zoneTz, tYear, tMonth, tDay, eH, eM, 0)
    if eH < sH 
        nextEnd += 86400000
        
    // Once the CURRENT zone finishes, project lines to tomorrow
    if time >= nextEnd
        nextStart += 86400000
        nextEnd   += 86400000
        
    // Weekend Safety Net (Friday -> Sunday Fix)
    if dayofweek(nextStart, zoneTz) == 7 // Saturday
        nextStart += 86400000
        nextEnd += 86400000
        
    // Draw the Goalposts (Anchored to close price to prevent chart squishing!)
    line.set_xy1(fStartLine, nextStart, close)
    line.set_xy2(fStartLine, nextStart, close + syminfo.mintick)
    line.set_color(fStartLine, solidZoneColor)
    
    line.set_xy1(fEndLine, nextEnd, close)
    line.set_xy2(fEndLine, nextEnd, close + syminfo.mintick)
    line.set_color(fEndLine, solidZoneColor)
    
    // Position the Text Label
    if showZoneText and na(inZone)
        int midTime = nextStart + math.round((nextEnd - nextStart) / 2)
        float recentHigh = ta.highest(high, 20)
        label.set_xy(fZoneLbl, midTime, recentHigh + (getPipSize(goldPipMode, silverPipMode) * pipOffset))
        label.set_text(fZoneLbl, "NO TRADING ZONE")
    else
        label.set_text(fZoneLbl, "")
else if not showZone
    line.set_xy1(fStartLine, na, na)
    line.set_xy1(fEndLine, na, na)
    label.set_xy(fZoneLbl, na, na)

// ============================================================================
// NO-WICK OPEN ARROWS & ALERTS
// ============================================================================
bullishNoWick = (close > open) and (open == low)
bearishNoWick = (close < open) and (open == high)

plotshape(showNoWick and bullishNoWick and arrowSizeStr == "Small", style=shape.triangleup, location=location.belowbar, color=bullArrowColor, size=size.small)
plotshape(showNoWick and bearishNoWick and arrowSizeStr == "Small", style=shape.triangledown, location=location.abovebar, color=bearArrowColor, size=size.small)
plotshape(showNoWick and bullishNoWick and arrowSizeStr == "Normal", style=shape.triangleup, location=location.belowbar, color=bullArrowColor, size=size.normal)
plotshape(showNoWick and bearishNoWick and arrowSizeStr == "Normal", style=shape.triangledown, location=location.abovebar, color=bearArrowColor, size=size.normal)

alertcondition(bullishNoWick, title="Bullish No-Wick Arrow", message="Bullish No-Wick Open detected")
alertcondition(bearishNoWick, title="Bearish No-Wick Arrow", message="Bearish No-Wick Open detected")

// ============================================================================
// RISK DASHBOARD LOGIC (Hardcoded to Medium)
// ============================================================================
var table riskTable = table.new(position.top_right, 2, 3, bgcolor=color.new(#1e222d, 0), border_color=color.new(#787b86, 0), border_width=1, frame_color=color.new(#787b86, 0), frame_width=1)

if showRiskDash and barstate.islast
    string lblSize = size.small
    string valSize = size.normal

    float actualRiskAmount = (accountBal * riskPercent / 100)
    
    float contractSize = 1 
    if syminfo.type == "forex"
        contractSize := 100000
    else if str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
        contractSize := 100
    else if str.contains(syminfo.ticker, "XAG") or str.contains(syminfo.ticker, "SILVER")
        contractSize := 5000
        
    float pipValueInQuote = contractSize * getPipSize(goldPipMode, silverPipMode)
    
    float exchangeRate = 1.0
    if accountCurr != syminfo.currency
        string crossTicker = "FX_IDC:" + accountCurr + syminfo.currency
        float crossRate = request.security(crossTicker, timeframe.period, close, ignore_invalid_symbol=true)
        if not na(crossRate)
            exchangeRate := crossRate
        else
            float fallbackRate = request.security(accountCurr + syminfo.currency, timeframe.period, close, ignore_invalid_symbol=true)
            if not na(fallbackRate)
                exchangeRate := fallbackRate
            else if str.startswith(syminfo.ticker, accountCurr) and str.endswith(syminfo.ticker, syminfo.currency)
                exchangeRate := close 
                
    float currentPipValue = pipValueInQuote / exchangeRate
    lotSize = actualRiskAmount / (slPips * currentPipValue)
    
    string riskLabel = "Risk (%)"
    string riskDisplayStr = str.tostring(riskPercent) + "% (" + str.tostring(actualRiskAmount, "#.##") + " " + accountCurr + ")"
    
    table.cell(riskTable, 0, 0, riskLabel, text_color=color.white, text_size=lblSize, bgcolor=color.new(#1e222d, 0))
    table.cell(riskTable, 1, 0, riskDisplayStr, text_color=color.white, text_size=lblSize, bgcolor=color.new(#1e222d, 0))
    table.cell(riskTable, 0, 1, "Stop Loss (Pips)", text_color=color.white, text_size=lblSize, bgcolor=color.new(#1e222d, 0))
    table.cell(riskTable, 1, 1, str.tostring(slPips), text_color=color.white, text_size=lblSize, bgcolor=color.new(#1e222d, 0))
    table.cell(riskTable, 0, 2, "Lot Size", text_color=color.yellow, text_size=valSize, text_halign=text.align_center, bgcolor=color.new(#1e222d, 0))
    table.cell(riskTable, 1, 2, str.tostring(lotSize, "#.##"), text_color=color.yellow, text_size=valSize, text_halign=text.align_center, bgcolor=color.new(#1e222d, 0))
else if not showRiskDash and barstate.islast
    table.clear(riskTable, 0, 0, 1, 2)

// ============================================================================
// MANUAL BACKTEST DASHBOARD LOGIC (Hardcoded to Large)
// ============================================================================
string btPos = showRiskDash ? position.bottom_right : position.top_right
var table btTable = table.new(btPos, 2, 5, border_width = 1, border_color = color.new(#787b86, 50), frame_color=color.new(#787b86, 50), frame_width=1)

if showBacktest and barstate.islast
    string btTextSize = size.normal

    int totalTrades = btWins + btLosses
    float winRate = totalTrades > 0 ? (btWins / totalTrades) * 100 : 0

    color bgColor   = color.new(#1e222d, 0)
    color textColor = color.white

    table.cell(btTable, 0, 0, "Metric", bgcolor=color.new(#2962ff, 40), text_color=textColor, text_halign=text.align_left, text_size=btTextSize)
    table.cell(btTable, 1, 0, "Value",  bgcolor=color.new(#2962ff, 40), text_color=textColor, text_halign=text.align_center, text_size=btTextSize)
    table.cell(btTable, 0, 1, "Total Trades", bgcolor=bgColor, text_color=textColor, text_halign=text.align_left, text_size=btTextSize)
    table.cell(btTable, 1, 1, str.tostring(totalTrades), bgcolor=bgColor, text_color=textColor, text_halign=text.align_center, text_size=btTextSize)
    table.cell(btTable, 0, 2, "Wins", bgcolor=bgColor, text_color=textColor, text_halign=text.align_left, text_size=btTextSize)
    table.cell(btTable, 1, 2, str.tostring(btWins), bgcolor=bgColor, text_color=color.green, text_halign=text.align_center, text_size=btTextSize)
    table.cell(btTable, 0, 3, "Losses", bgcolor=bgColor, text_color=textColor, text_halign=text.align_left, text_size=btTextSize)
    table.cell(btTable, 1, 3, str.tostring(btLosses), bgcolor=bgColor, text_color=color.red, text_halign=text.align_center, text_size=btTextSize)
    
    color wrColor = winRate >= 50 ? color.green : color.red
    table.cell(btTable, 0, 4, "Win Rate", bgcolor=bgColor, text_color=textColor, text_halign=text.align_left, text_size=btTextSize)
    table.cell(btTable, 1, 4, str.tostring(winRate, "#.##") + "%", bgcolor=bgColor, text_color=wrColor, text_halign=text.align_center, text_size=btTextSize)

else if not showBacktest and barstate.islast
    table.clear(btTable, 0, 0, 1, 4)
````
