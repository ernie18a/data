<!-- tradingview-pine-id: PUB;ae672dd6d12d418a86b7ba2b8a374901 -->
<!-- tradingviewscripts-format: 1 -->
# Micha.Stocks Custom Watermark

Source: https://www.tradingview.com/script/IUJTwqxj-Momentum-watermark/

## Description

Special watermark from momentum traders shows the company the field she's working the float, the depth in the cash below daily all-time high splits and earning

---

## Source Code

````pine
//@version=6
indicator("Micha.Stocks Custom Watermark", shorttitle = 'SPLT_ATH', overlay = true)

// --- User Inputs ---
// Group 1: Position
yPos        = input.string("Top", "Watermark Vertical Location", options = ["Top", "Middle", "Bottom"], inline = '1')
xPos        = input.string("Left", "Watermark Horizontal Location", options = ["Left", "Center", "Right"], inline = '1')
offsetY     = input.int(0, "Vertical Offset (%)", minval=0, maxval=100, tooltip = "Adjusts the empty space above the text") 

// Group 2: Style
txtCol      = input.color(color.rgb(164, 167, 180, 30), 'Text Color', inline = '2')
txtSize     = input.string('Huge', 'Text Size', options = ['Huge', 'Large', 'Normal', 'Small'], inline = '2')

// Group 3: Data Toggles
symTime     = input.bool(true, 'Symbol & Time Frame')
compName    = input.bool(true, 'Company Name')
indSec      = input.bool(true, 'Industry & Sector')
mCap        = input.bool(true, 'Show Market Cap')
showATR     = input.bool(false, "Show ATR (14-Day) & %") 
showMA150   = input.bool(true, "Show Daily Moving Average Position")
maPeriod    = input.int(150, "Moving Average Period (Daily)", minval=1, maxval=500)

// Group 4: Earnings & Thresholds
showRemainingDaysInput = input.bool(true, "Show Days Until Earnings")
showEarningsRow     = input.bool(true, "Show Earnings Info")
atrRedThreshold     = input.float(6.0, "ATR Red Threshold (%)", minval=0)
atrYellowThreshold  = input.float(3.0, "ATR Yellow Threshold (%)", minval=0)

// Group 5: New Features
showSplits      = input.bool(true, "Show Number of Splits")
showATH         = input.bool(true, "Show All-Time High")
athAlertLevel   = input.float(100, "ATH Alert Threshold", tooltip = "If ATH is higher than this number → text turns red 🔴")
showFloat       = input.bool(true, "Show Float & Free Float %")
floatRedLevel   = input.float(20.0, "Free Float Red Threshold (%)", tooltip = "If Free Float % is below this → show 🔴")
showDebtCash    = input.bool(true, "Show Debt vs Cash")

// --- Logic & Calculations ---

// Font size mapping
sizer = txtSize == 'Huge' ? size.huge : txtSize == 'Large' ? size.large : txtSize == 'Normal' ? size.normal : size.small

// Market Cap / Shares Formatter
rounder(float val) =>
    if na(val)
        "N/A"
    else if val >= 1000000000000
        str.tostring(math.round(val / 1000000000000, 2)) + 'T'
    else if val >= 1000000000
        str.tostring(math.round(val / 1000000000, 2)) + 'B'
    else if val >= 1000000
        str.tostring(math.round(val / 1000000, 2)) + 'M'
    else if val >= 1000
        str.tostring(math.round(val / 1000, 1)) + 'K'
    else
        str.tostring(math.round(val))

// Ticker and Market Data
sector      = syminfo.sector
ind         = syminfo.industry
tick        = syminfo.ticker
name        = syminfo.description
marketcap   = syminfo.shares_outstanding_total * close 
mCapStr     = na(marketcap) ? "N/A" : rounder(marketcap)

// Float & Free Float
floatShares     = syminfo.shares_outstanding_float
totalShares     = syminfo.shares_outstanding_total
freeFloatPct    = na(floatShares) or na(totalShares) or totalShares == 0 ? na : (floatShares / totalShares) * 100

floatIsLow      = not na(freeFloatPct) and freeFloatPct < floatRedLevel
floatText       = "Float: " + rounder(floatShares) + " | Free Float: " + (na(freeFloatPct) ? "N/A" : str.tostring(freeFloatPct, "#.#") + "%") + (floatIsLow ? " 🔴" : "")
floatColor      = floatIsLow ? color.red : txtCol

// Debt vs Cash
totalDebt   = request.financial(syminfo.tickerid, "TOTAL_DEBT", "FQ")
cash        = request.financial(syminfo.tickerid, "CASH_N_EQUIVALENTS", "FQ")

debtCashText = "Debt: " + rounder(totalDebt) + " | Cash: " + rounder(cash)

// אימוג'ים לפי יחס חוב/מזומן
debtCashEmojis = ""
if not na(totalDebt) and not na(cash)
    if cash > totalDebt * 1.5
        debtCashEmojis := "🟢🟢🟢🟢"
    else if cash > totalDebt
        debtCashEmojis := "🟢🟢🟢"
    else if cash > totalDebt * 0.7
        debtCashEmojis := "🟢🟢"
    else if cash > totalDebt * 0.4
        debtCashEmojis := "🟡🟡"
    else if cash > totalDebt * 0.2
        debtCashEmojis := "🔴🔴"
    else
        debtCashEmojis := "🔴🔴🔴🔴"

debtCashFull = debtCashText + " " + debtCashEmojis

// Timeframe Display
tfDisplay   = timeframe.period == 'D' ? '1D' : 
              timeframe.period == 'W' ? '1W' : 
              timeframe.period == 'M' ? '1M' : 
              timeframe.isintraday ? (math.floor(timeframe.multiplier / 60) > 0 ? str.tostring(math.floor(timeframe.multiplier / 60)) + 'H' : str.tostring(timeframe.multiplier) + 'm') : 
              timeframe.period

// --- Daily Data ---
dClose = request.security(syminfo.tickerid, "D", close)

// ATR Daily
atrValue    = request.security(syminfo.tickerid, "D", ta.atr(14))
atrPercent  = (atrValue / dClose) * 100
atrEmoji    = atrPercent >= atrRedThreshold ? "🔴" : atrPercent >= atrYellowThreshold ? "🟡" : "🟢"

// Daily MA
dailyMA     = request.security(syminfo.tickerid, "D", ta.sma(close, maPeriod))
aboveMA     = close > dailyMA 
maStatus    = aboveMA ? "Above Daily " + str.tostring(maPeriod) + " MA 🟢" : "Below Daily " + str.tostring(maPeriod) + " MA 🔴"

// --- All-Time High ---
var float athValue = high
athValue := math.max(athValue, high)

athPct   = ((close / athValue) - 1) * 100
athIsHigh = athValue > athAlertLevel
athText   = "ATH: " + str.tostring(athValue, "#.####") + " (" + str.tostring(athPct, "#.##") + "%)" + (athIsHigh ? " 🔴" : "")
athColor  = athIsHigh ? color.red : txtCol

// --- Number of Splits ---
splitDen = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on)
var int splitCount = 0
if not na(splitDen)
    splitCount += 1

splitsEmojis = ""
if splitCount > 0
    for i = 1 to math.min(splitCount, 20)
        splitsEmojis += "🔴"
splitsText = "Splits: " + (splitCount == 0 ? "0" : splitsEmojis)

// Earnings Calculation
earningsTime = earnings.future_time
earningsText = ""

if not na(earningsTime) and showEarningsRow
    msPerDay = 86400000
    timeDiff = math.max(0, math.round((earningsTime - timenow) / msPerDay))
    earningsText := "Earnings: " 
    if showRemainingDaysInput
        earningsText := earningsText + str.tostring(timeDiff) + " days remaining"

// --- Table Rendering ---
posTable = str.lower(yPos) + '_' + str.lower(xPos)
var table sec = table.new(posTable, 1, 16, border_width = 0)

if barstate.islast
    rowIndex = 0
    
    // 1. Spacer
    table.cell(sec, 0, rowIndex, "", height = offsetY, text_color = color.new(color.white, 100)) 
    rowIndex += 1
    
    // 2. Company Name
    if compName
        txt = mCap ? name + ' (' + mCapStr + ')' : name
        table.cell(sec, 0, rowIndex, txt, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    // 3. Symbol
    if symTime
        table.cell(sec, 0, rowIndex, tick + ', ' + tfDisplay, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    // 4. Industry
    if indSec
        txt = not na(sector) ? sector + ', ' + ind : ''
        table.cell(sec, 0, rowIndex, txt, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1

    // 5. Float & Free Float
    if showFloat
        table.cell(sec, 0, rowIndex, floatText, text_color = floatColor, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1

    // 6. Debt vs Cash
    if showDebtCash
        table.cell(sec, 0, rowIndex, debtCashFull, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    // 7. ATR (Daily)
    if showATR
        txt = "ATR (Daily): " + str.tostring(atrValue, "#.##") + " (" + str.tostring(atrPercent, "#.##") + "%) " + atrEmoji
        table.cell(sec, 0, rowIndex, txt, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    // 8. Moving Average (Daily)
    if showMA150
        table.cell(sec, 0, rowIndex, maStatus, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1

    // 9. All-Time High
    if showATH
        table.cell(sec, 0, rowIndex, athText, text_color = athColor, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1

    // 10. Number of Splits
    if showSplits
        table.cell(sec, 0, rowIndex, splitsText, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
    
    // 11. Earnings
    if showEarningsRow and earningsText != ""
        table.cell(sec, 0, rowIndex, earningsText, text_color = txtCol, text_size = sizer, text_halign = text.align_left)
        rowIndex += 1
````
