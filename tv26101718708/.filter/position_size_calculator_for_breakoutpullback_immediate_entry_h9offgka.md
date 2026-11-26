# Position Size Calculator (For Breakout/Pullback Immediate Entry)

- url: https://www.tradingview.com/script/h9OFFGKA-Position-Size-Calculator-For-Breakout-Pullback-Immediate-Entry/
- type: indicator
- pine_id: PUB;7201f5b957244040ab961b73655defd5
- version: 2.0

## Description

This is a trading script designed specifically for swing traders who use the Low of the Day (LOD) as their stop loss — a strategy employed by legendary traders such as Oliver Kell, Maggie, and many other professional market operators.

The core purpose of this script is to deliver instant and accurate share quantity calculations at the exact moment of a breakout or pullback entry. It eliminates time-consuming manual calculations, allowing you to execute your orders quickly and avoid missing the optimal entry price as the stock price often surges within minutes.

The script is self-explanatory. Shares to buy = Risk per Trade / Difference to LOD. If it shows "BAD", it means either Difference to LOD > half of ATR or 5%

## Source Code

````pine
//@version=6
indicator("Position Calculator - Mid Right Panel", overlay = true, max_bars_back = 1000)

// === User Manual Inputs ===
accountSize     = input.float(10000,  title = "Account Size (USD)",                 minval = 10,   step = 100)
riskPerTrade    = input.float(200,    title = "Risk Per Trade (USD)",              minval = 10,    step = 10)
maxPercent      = input.float(35,     title = "Max Position % of Account",        minval = 1,     maxval = 100, step = 1) / 100
atrLength       = input.int(14,       title = "Daily ATR Length",                 minval = 1,     maxval = 100)

// === Show/Hide Options ===
showAccount      = input.bool(true,  title = "Show Account Size")
showRisk         = input.bool(true,  title = "Show Risk Per Trade")
showMaxPct       = input.bool(true,  title = "Show Max Position %")
showLOD          = input.bool(true,  title = "Show Low of Day Price")
showDiff         = input.bool(true,  title = "Show Low of Day Difference")
showATR          = input.bool(true,  title = "Show Daily ATR Value")
showATRPct       = input.bool(true,  title = "Show ATR %")
showStrike       = input.bool(true,  title = "Show Strike Price x1")
showStrike2      = input.bool(true,  title = "Show Strike Price x2")
show52W          = input.bool(true,  title = "Show 52W High/Low Data")
showShares       = input.bool(true,  title = "Show Shares to Buy")

// === Daily Low Calculation ===
var float dayLow = na
isNewDay = timeframe.change("D")   // 修正：改成 bool

if isNewDay
    dayLow := low
else
    dayLow := math.min(dayLow, low)

// === Price Difference (Always >= 0) ===
priceDiff = math.max(0, close - dayLow)

// === Daily ATR & 52-Week Calculation ===
dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLength))
high52w  = request.security(syminfo.tickerid, "D", ta.highest(high, 252))
low52w   = request.security(syminfo.tickerid, "D", ta.lowest(low, 252))

// === Percentage Calculations ===
atrPct         = (dailyATR / close) * 100
off52wHighPct  = ((close - high52w) / high52w) * 100
above52wLowPct = ((close - low52w) / low52w) * 100

// === Strike Prices (rounded to integer) ===
strikePriceX1  = math.round(close + dailyATR)
strikePriceX2  = math.round(close + dailyATR * 2)

// === Bad Entry Condition (based on Daily ATR) ===
isBadEntry = (priceDiff >= dailyATR * 0.5) or (priceDiff / close >= 0.05)

// === Shares Calculation ===
float sharesByRisk = priceDiff > 0 ? riskPerTrade / priceDiff : 0
maxPositionValue = accountSize * maxPercent
maxSharesByValue = maxPositionValue / close
sharesToBuy = math.min(sharesByRisk, maxSharesByValue)

// === Display Table in Middle Right ===
var table posTable = table.new(position.top_right, 2, 15, border_width = 1)

if barstate.islast
    int row = 0
    
    table.cell(posTable, 0, row, "Item",  text_color = color.white, text_size = size.normal)
    table.cell(posTable, 1, row, "Value", text_color = color.white, text_size = size.normal)
    row += 1
    
    if showAccount
        table.cell(posTable, 0, row, "Account Size", text_color = color.white)
        table.cell(posTable, 1, row, "$ " + str.tostring(accountSize, "#,###"), text_color = color.white)
        row += 1
    
    if showRisk
        table.cell(posTable, 0, row, "Risk Per Trade", text_color = color.white)
        table.cell(posTable, 1, row, "$ " + str.tostring(riskPerTrade, "#,###"), text_color = color.white)
        row += 1
    
    if showMaxPct
        table.cell(posTable, 0, row, "Max Position %", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(maxPercent * 100, "#") + "%", text_color = color.white)
        row += 1
    
    if showLOD
        table.cell(posTable, 0, row, "LOD", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(dayLow, "#.####"), text_color = color.white)
        row += 1
    
    if showDiff
        table.cell(posTable, 0, row, "Off LOD", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(priceDiff, "#.####"), text_color = color.white)
        row += 1
    
    if showATR
        table.cell(posTable, 0, row, "ATR", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(dailyATR, "#.####"), text_color = color.white)
        row += 1

    if showATRPct
        table.cell(posTable, 0, row, "ATR%", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(atrPct, "#.##") + "%", text_color = color.white)
        row += 1

    if showStrike
        table.cell(posTable, 0, row, "Strike x1", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(strikePriceX1, "#,###"), text_color = color.white)
        row += 1

    if showStrike2
        table.cell(posTable, 0, row, "Strike x2", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(strikePriceX2, "#,###"), text_color = color.white)
        row += 1

    if show52W
        table.cell(posTable, 0, row, "Off 52W High", text_color = color.white)
        table.cell(posTable, 1, row, str.tostring(off52wHighPct, "#.##") + "%", text_color = color.rgb(255, 255, 255))
        row += 1
        
        table.cell(posTable, 0, row, "Above 52W Low", text_color = color.white)
        table.cell(posTable, 1, row, "+" + str.tostring(above52wLowPct, "#.##") + "%", text_color = color.rgb(255, 255, 255))
        row += 1
    
    if showShares
        table.cell(posTable, 0, row, "Shares to Buy", text_color = color.white)
        if isBadEntry
            table.cell(posTable, 1, row, "BAD", text_color = color.red)
        else
            table.cell(posTable, 1, row, str.tostring(math.round(sharesToBuy), "#,###"), text_color = color.lime)
````
