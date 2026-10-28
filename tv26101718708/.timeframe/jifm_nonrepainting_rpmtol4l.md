# jifm [Non-Repainting]

- url: https://www.tradingview.com/script/RpMToL4L-jifm-Non-Repainting/
- type: indicator
- pine_id: PUB;57cc5339c79b4d9fafe5363a58725f1a
- version: 2.0

## Description

# Professional Next Day CPR & Pivot Levels Indicator

A powerful and professional TradingView indicator designed for Intraday Traders, Scalpers, Swing Traders, Futures & Options Traders.

This indicator automatically calculates and plots NEXT DAY CPR (Central Pivot Range) and Traditional Pivot Levels immediately after the market closes using the previous day's OHLC data.

The levels are projected in advance for the upcoming trading session, helping traders prepare high-probability trading plans before market open.

━━━━━━━━━━━━━━━━━━
FEATURES INCLUDED
━━━━━━━━━━━━━━━━━━

✅ Automatic Next Day CPR Calculation

• Pivot (P)
• TC (Top Central)
• BC (Bottom Central)

✅ Traditional Pivot Levels

• R1, R2, R3
• S1, S2, S3

✅ Previous Day Levels

• Previous Day High
• Previous Day Low

✅ Professional Trading Features

• Narrow CPR Detection
• Wide CPR Detection
• Bullish/Bearish Bias
• Non-Repainting Logic
• Intraday Optimized
• Session Level Extension
• Professional Labels & Colors

✅ Alert Conditions

• Price crossing CPR
• Price crossing Pivot
• Breakout above R1/R2
• Breakdown below S1/S2

━━━━━━━━━━━━━━━━━━
CPR FORMULA
━━━━━━━━━━━━━━━━━━

Pivot (P) = (High + Low + Close) / 3

BC = (High + Low) / 2

TC = (Pivot - BC) + Pivot

━━━━━━━━━━━━━━━━━━
TRADITIONAL PIVOT FORMULA
━━━━━━━━━━━━━━━━━━

R1 = (2 × Pivot) − Low

S1 = (2 × Pivot) − High

R2 = Pivot + (High − Low)

S2 = Pivot − (High − Low)

R3 = High + 2 × (Pivot − Low)

S3 = Low − 2 × (High − Pivot)

━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━

🔹 Narrow CPR

A Narrow CPR indicates potential expansion in volatility and trending moves.

Best for:
• Breakout Trading
• Momentum Trading
• Option Buying
• Scalping

🔹 Wide CPR

A Wide CPR indicates potential sideways or range-bound movement.

Best for:
• Range Trading
• Mean Reversion
• Option Selling

━━━━━━━━━━━━━━━━━━
BEST TIMEFRAMES
━━━━━━━━━━━━━━━━━━

• 1 Min → Scalping
• 5 Min → Intraday
• 15 Min → Safer Entries
• 30 Min → Swing Intraday
• 1 Hour → Positional Intraday

━━━━━━━━━━━━━━━━━━
WHO CAN USE THIS INDICATOR
━━━━━━━━━━━━━━━━━━

✔ Intraday Traders
✔ Option Traders
✔ Futures Traders
✔ Scalpers
✔ Swing Traders
✔ Professional Traders

━━━━━━━━━━━━━━━━━━
KEY BENEFITS
━━━━━━━━━━━━━━━━━━

• Plan trades before market opens
• Identify support & resistance zones
• Spot breakout opportunities
• Improve risk-reward setups
• Enhance intraday decision making
• Professional-grade CPR analysis

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This indicator is created for educational and analytical purposes only. Please use proper risk management before taking any trades. Trading in financial markets involves risk.

## Source Code

````pine
//@version=5
indicator("Jifm [Non-Repainting]", overlay=true, max_lines_count=500, max_labels_count=500)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
groupDisplay = "Confirmed Levels"
showCPR      = input.bool(true, "Show Confirmed CPR Levels", group=groupDisplay)
showTC       = input.bool(true, "Show TC", group=groupDisplay)
showPivot    = input.bool(true, "Show Pivot", group=groupDisplay)
showBC       = input.bool(true, "Show BC", group=groupDisplay)

showR1       = input.bool(true, "Show R1", group=groupDisplay)
showR2       = input.bool(true, "Show R2", group=groupDisplay)
showR3       = input.bool(true, "Show R3", group=groupDisplay)
showS1       = input.bool(true, "Show S1", group=groupDisplay)
showS2       = input.bool(true, "Show S2", group=groupDisplay)
showS3       = input.bool(true, "Show S3", group=groupDisplay)

showPDH      = input.bool(true, "Show Previous Day High", group=groupDisplay)
showPDL      = input.bool(true, "Show Previous Day Low", group=groupDisplay)
showHistory  = input.bool(false, "Keep Previous Sessions On Chart", group=groupDisplay)
showLabels   = input.bool(true, "Show Labels", group=groupDisplay)
labelOffset  = input.int(8, "Label Offset", minval=1, maxval=50, group=groupDisplay)

groupNext = "Next-Day Preview From Today's Data"
showNextPreview = input.bool(true, "Show Next-Day Preview Based On Today's Data", group=groupNext)
showNextCPR     = input.bool(true, "Show Next-Day CPR Preview", group=groupNext)
showNextPivots  = input.bool(false, "Show Next-Day Pivot Level Preview", group=groupNext)
showNextLabels  = input.bool(true, "Show Next-Day Preview Labels", group=groupNext)

groupStyle = "Style Settings"
cprColor     = input.color(color.rgb(255, 193, 7), "CPR Color", group=groupStyle)
pivotColor   = input.color(color.rgb(33, 150, 243), "Pivot Color", group=groupStyle)
resColor     = input.color(color.rgb(0, 180, 90), "Resistance Color", group=groupStyle)
supColor     = input.color(color.rgb(230, 57, 70), "Support Color", group=groupStyle)
pdhColor     = input.color(color.rgb(156, 39, 176), "PDH / PDL Color", group=groupStyle)
nextColor    = input.color(color.rgb(255, 152, 0), "Next-Day Preview Color", group=groupStyle)
lineWidth    = input.int(2, "Main Line Width", minval=1, maxval=4, group=groupStyle)
showCPRFill  = input.bool(true, "Highlight Confirmed CPR Zone", group=groupStyle)
showBiasBg   = input.bool(true, "Show Bias Background", group=groupStyle)

groupCPR = "CPR Width And Bias"
showInfoPanel = input.bool(true, "Show CPR Info Panel", group=groupCPR)
narrowPct     = input.float(0.25, "Narrow CPR Below %", step=0.05, group=groupCPR)
widePct       = input.float(0.75, "Wide CPR Above %", step=0.05, group=groupCPR)

//----------------------------------------------------
// Confirmed Daily Data
//----------------------------------------------------
prevHigh  = request.security(syminfo.tickerid, "D", high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prevLow   = request.security(syminfo.tickerid, "D", low[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prevClose = request.security(syminfo.tickerid, "D", close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

prev2High  = request.security(syminfo.tickerid, "D", high[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev2Low   = request.security(syminfo.tickerid, "D", low[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prev2Close = request.security(syminfo.tickerid, "D", close[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//----------------------------------------------------
// Today's Developing Data For Next-Day Preview
//----------------------------------------------------
todayHigh  = request.security(syminfo.tickerid, "D", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
todayLow   = request.security(syminfo.tickerid, "D", low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
todayClose = request.security(syminfo.tickerid, "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//----------------------------------------------------
// Confirmed CPR Calculation
//----------------------------------------------------
pivot = (prevHigh + prevLow + prevClose) / 3.0
bc    = (prevHigh + prevLow) / 2.0
tc    = (pivot - bc) + pivot

cprWidth    = math.abs(tc - bc)
cprWidthPct = pivot != 0.0 ? (cprWidth / pivot) * 100.0 : na

//----------------------------------------------------
// Confirmed Traditional Pivot Levels
//----------------------------------------------------
r1 = (2.0 * pivot) - prevLow
s1 = (2.0 * pivot) - prevHigh
r2 = pivot + (prevHigh - prevLow)
s2 = pivot - (prevHigh - prevLow)
r3 = prevHigh + 2.0 * (pivot - prevLow)
s3 = prevLow - 2.0 * (prevHigh - pivot)

//----------------------------------------------------
// Next-Day Preview Levels From Today's Data
//----------------------------------------------------
nextPivot = (todayHigh + todayLow + todayClose) / 3.0
nextBC    = (todayHigh + todayLow) / 2.0
nextTC    = (nextPivot - nextBC) + nextPivot

nextR1 = (2.0 * nextPivot) - todayLow
nextS1 = (2.0 * nextPivot) - todayHigh
nextR2 = nextPivot + (todayHigh - todayLow)
nextS2 = nextPivot - (todayHigh - todayLow)
nextR3 = todayHigh + 2.0 * (nextPivot - todayLow)
nextS3 = todayLow - 2.0 * (todayHigh - nextPivot)

//----------------------------------------------------
// Bias Comparison
//----------------------------------------------------
prevPivot = (prev2High + prev2Low + prev2Close) / 3.0
prevBC    = (prev2High + prev2Low) / 2.0
prevTC    = (prevPivot - prevBC) + prevPivot

prevCPRTop    = math.max(prevTC, prevBC)
prevCPRBottom = math.min(prevTC, prevBC)
cprTop        = math.max(tc, bc)
cprBottom     = math.min(tc, bc)

bullishBias = cprBottom > prevCPRTop
bearishBias = cprTop < prevCPRBottom
biasText    = bullishBias ? "Bullish" : bearishBias ? "Bearish" : "Neutral"
widthText   = cprWidthPct <= narrowPct ? "Narrow CPR" : cprWidthPct >= widePct ? "Wide CPR" : "Normal CPR"

//----------------------------------------------------
// Object Management
//----------------------------------------------------
var line[] activeLines = array.new_line()
var label[] activeLabels = array.new_label()
var linefill activeFill = na

var line[] previewLines = array.new_line()
var label[] previewLabels = array.new_label()

f_clear_array_objects(_lines, _labels) =>
    lineCount = array.size(_lines)
    labelCount = array.size(_labels)

    if lineCount > 0
        for i = 0 to lineCount - 1
            line.delete(array.get(_lines, i))

    if labelCount > 0
        for i = 0 to labelCount - 1
            label.delete(array.get(_labels, i))

    array.clear(_lines)
    array.clear(_labels)

f_finalize_active() =>
    lineCount = array.size(activeLines)
    labelCount = array.size(activeLabels)

    if lineCount > 0
        for i = 0 to lineCount - 1
            oldLine = array.get(activeLines, i)
            line.set_x2(oldLine, bar_index)
            line.set_extend(oldLine, extend.none)

    if labelCount > 0
        for i = 0 to labelCount - 1
            oldLabel = array.get(activeLabels, i)
            label.set_x(oldLabel, bar_index)

    array.clear(activeLines)
    array.clear(activeLabels)

f_make_level(_show, _name, _price, _color, _width, _style) =>
    line newLine = na
    label newLabel = na

    if _show and not na(_price)
        newLine := line.new(x1=bar_index, y1=_price, x2=bar_index + 1, y2=_price, xloc=xloc.bar_index, extend=extend.right, color=_color, width=_width, style=_style)
        array.push(activeLines, newLine)

        if showLabels
            labelText = _name + "  " + str.tostring(_price, format.mintick)
            newLabel := label.new(x=bar_index + labelOffset, y=_price, xloc=xloc.bar_index, text=labelText, style=label.style_label_left, textcolor=color.white, color=color.new(_color, 0), size=size.small)
            array.push(activeLabels, newLabel)

    [newLine, newLabel]

f_make_preview(_show, _name, _price, _color) =>
    if _show and not na(_price)
        pLine = line.new(x1=bar_index, y1=_price, x2=bar_index + 1, y2=_price, xloc=xloc.bar_index, extend=extend.right, color=color.new(_color, 0), width=1, style=line.style_dashed)
        array.push(previewLines, pLine)

        if showNextLabels
            pLabel = label.new(x=bar_index + labelOffset + 10, y=_price, xloc=xloc.bar_index, text=_name + "  " + str.tostring(_price, format.mintick), style=label.style_label_left, textcolor=color.white, color=color.new(_color, 20), size=size.small)
            array.push(previewLabels, pLabel)

//----------------------------------------------------
// Build Confirmed Levels At Start Of Each Trading Day
//----------------------------------------------------
newDay = ta.change(time("D")) != 0
shouldBuild = timeframe.isintraday and not na(prevHigh) and (newDay or barstate.isfirst)

if shouldBuild
    if showHistory
        f_finalize_active()
    else
        f_clear_array_objects(activeLines, activeLabels)
        if not na(activeFill)
            linefill.delete(activeFill)
            activeFill := na

    [tcLine, tcLabel] = f_make_level(showCPR and showTC, "TC", tc, cprColor, lineWidth, line.style_solid)
    [pLine, pLabel]   = f_make_level(showCPR and showPivot, "P", pivot, pivotColor, lineWidth + 1, line.style_solid)
    [bcLine, bcLabel] = f_make_level(showCPR and showBC, "BC", bc, cprColor, lineWidth, line.style_solid)

    [r1Line, r1Label] = f_make_level(showR1, "R1", r1, resColor, lineWidth, line.style_solid)
    [r2Line, r2Label] = f_make_level(showR2, "R2", r2, resColor, lineWidth, line.style_dashed)
    [r3Line, r3Label] = f_make_level(showR3, "R3", r3, resColor, lineWidth, line.style_dotted)

    [s1Line, s1Label] = f_make_level(showS1, "S1", s1, supColor, lineWidth, line.style_solid)
    [s2Line, s2Label] = f_make_level(showS2, "S2", s2, supColor, lineWidth, line.style_dashed)
    [s3Line, s3Label] = f_make_level(showS3, "S3", s3, supColor, lineWidth, line.style_dotted)

    [pdhLine, pdhLabel] = f_make_level(showPDH, "PDH", prevHigh, pdhColor, 1, line.style_dashed)
    [pdlLine, pdlLabel] = f_make_level(showPDL, "PDL", prevLow, pdhColor, 1, line.style_dashed)

    if showCPRFill and showCPR and showTC and showBC and not na(tcLine) and not na(bcLine)
        activeFill := linefill.new(tcLine, bcLine, color.new(cprColor, 88))

//----------------------------------------------------
// Build Developing Next-Day Preview On Last Bar
//----------------------------------------------------
if barstate.islast
    f_clear_array_objects(previewLines, previewLabels)

    if timeframe.isintraday and showNextPreview and not na(todayHigh)
        f_make_preview(showNextCPR and showTC, "NEXT TC", nextTC, nextColor)
        f_make_preview(showNextCPR and showPivot, "NEXT P", nextPivot, nextColor)
        f_make_preview(showNextCPR and showBC, "NEXT BC", nextBC, nextColor)

        f_make_preview(showNextPivots and showR1, "NEXT R1", nextR1, resColor)
        f_make_preview(showNextPivots and showR2, "NEXT R2", nextR2, resColor)
        f_make_preview(showNextPivots and showR3, "NEXT R3", nextR3, resColor)
        f_make_preview(showNextPivots and showS1, "NEXT S1", nextS1, supColor)
        f_make_preview(showNextPivots and showS2, "NEXT S2", nextS2, supColor)
        f_make_preview(showNextPivots and showS3, "NEXT S3", nextS3, supColor)

// Keep confirmed labels near latest candle.
if showLabels and array.size(activeLabels) > 0
    for i = 0 to array.size(activeLabels) - 1
        label.set_x(array.get(activeLabels, i), bar_index + labelOffset)

//----------------------------------------------------
// Background Bias Highlight
//----------------------------------------------------
bgColor = bullishBias ? color.new(color.green, 92) : bearishBias ? color.new(color.red, 92) : color.new(color.gray, 96)
bgcolor(showBiasBg and timeframe.isintraday ? bgColor : na)

//----------------------------------------------------
// CPR Info Panel
//----------------------------------------------------
var table infoTable = table.new(position.top_right, 2, 4, border_width=1)

if barstate.islast and showInfoPanel
    table.cell(infoTable, 0, 0, "CPR Width", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(infoTable, 1, 0, widthText, text_color=color.white, bgcolor=color.new(cprColor, 10))

    table.cell(infoTable, 0, 1, "Width %", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(infoTable, 1, 1, str.tostring(cprWidthPct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 35))

    table.cell(infoTable, 0, 2, "CPR Bias", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(infoTable, 1, 2, biasText, text_color=color.white, bgcolor=bullishBias ? color.new(color.green, 10) : bearishBias ? color.new(color.red, 10) : color.new(color.gray, 20))

    table.cell(infoTable, 0, 3, "Next Preview", text_color=color.white, bgcolor=color.new(color.black, 15))
    table.cell(infoTable, 1, 3, showNextPreview ? "Today's OHLC" : "Off", text_color=color.white, bgcolor=color.new(nextColor, 20))

if barstate.islast and not showInfoPanel
    table.clear(infoTable, 0, 0, 1, 3)

//----------------------------------------------------
// Alerts - Confirmed Current Session Levels
//----------------------------------------------------
crossCPR = ta.cross(close, tc) or ta.cross(close, pivot) or ta.cross(close, bc)
crossPivotLevels = ta.cross(close, r1) or ta.cross(close, r2) or ta.cross(close, r3) or ta.cross(close, s1) or ta.cross(close, s2) or ta.cross(close, s3)

breakoutR1 = ta.crossover(close, r1)
breakoutR2 = ta.crossover(close, r2)
breakdownS1 = ta.crossunder(close, s1)
breakdownS2 = ta.crossunder(close, s2)

alertcondition(crossCPR, "Price Crossing CPR", "Price crossed TC, Pivot, or BC.")
alertcondition(crossPivotLevels, "Price Crossing Pivot Levels", "Price crossed a traditional pivot level.")
alertcondition(breakoutR1, "Breakout Above R1", "Price broke out above R1.")
alertcondition(breakoutR2, "Breakout Above R2", "Price broke out above R2.")
alertcondition(breakdownS1, "Breakdown Below S1", "Price broke down below S1.")
alertcondition(breakdownS2, "Breakdown Below S2", "Price broke down below S2.")
````
