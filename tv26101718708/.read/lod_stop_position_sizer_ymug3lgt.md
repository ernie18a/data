# LoD Stop & Position Sizer

- url: https://www.tradingview.com/script/YmUg3LGt-LoD-Stop-Position-Sizer/
- type: indicator
- pine_id: PUB;0d0a40a8043941e09499440120f2293c
- version: 1.0

## Description

This is based on the teaching of Jeff Sun (@jfsrev) using LoD and ATR "If you're precise and efficient with your entries—ensuring entries are always below 50/60% from the LoD stop based on ATR nature of the securities volatility"  

You can enter you account value, risk to equity and it will calculate the # of shares you can buy based on the LoD and ATR%

## Source Code

````pine
//@version=6
indicator("LoD Stop & Position Sizer", overlay=true)

// ---------- Inputs ----------
atrLen       = input.int(14, "ATR Length")
adrLen       = input.int(20, "ADR% Length")
acctValue    = input.float(50000, "Account Value ($)", step=1000)
riskPct      = input.float(0.15, "Risk % to Equity", step=0.01)
lodThreshold = input.float(60, "LoD Dist% Threshold", step=1)
maxPosPct    = input.float(100, "Max Position % of Account", step=5)
tablePosStr  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left","Middle Center"])
textSizeStr  = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large","Huge"])
bgTransp     = input.int(20, "Background Transparency", minval=0, maxval=100)

// ---------- Pull live DAILY values (works on any timeframe) ----------
dLow   = request.security(syminfo.tickerid, "D", low)
dClose = request.security(syminfo.tickerid, "D", close)
dATR   = request.security(syminfo.tickerid, "D", ta.atr(atrLen))
adrPct = request.security(syminfo.tickerid, "D", 100 * (ta.sma(high / low, adrLen) - 1))

// ---------- Calculations ----------
lodDist = (dClose - dLow) / dATR * 100

entryPrice = dClose            // assumes entry at current price
stopPrice  = dLow              // stop sits at Low of Day
stopDist   = entryPrice - stopPrice

riskDollars = acctValue * riskPct / 100
sharesRaw   = stopDist > 0 ? riskDollars / stopDist : na
shares      = na(sharesRaw) ? na : math.floor(sharesRaw)
posDollars  = na(shares) ? na : shares * entryPrice
posPct      = na(posDollars) ? na : posDollars / acctValue * 100

// ---------- Position / size mapping ----------
tablePos = switch tablePosStr
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    "Middle Left"  => position.middle_left
    =>               position.middle_center

textSize = switch textSizeStr
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge"  => size.huge
    =>        size.normal

// ---------- Background colour ----------
bgCol = color.new(color.black, bgTransp)

// ---------- Table ----------
var table t = na
if barstate.isfirst
    t := table.new(tablePos, 2, 10, bgcolor=bgCol, border_color=color.gray, border_width=1)

lodColor = lodDist <= lodThreshold ? color.green : color.red
posColor = not na(posPct) and posPct > maxPosPct ? color.red : color.white

f_cell(col, row, txt, col_text) =>
    table.cell(t, col, row, txt, text_color=col_text, bgcolor=bgCol, text_size=textSize)

if barstate.islast
    f_cell(0, 0, "ADR%", color.white)
    f_cell(1, 0, str.tostring(adrPct, "#.##") + "%", color.white)
    f_cell(0, 1, "ATR", color.white)
    f_cell(1, 1, str.tostring(dATR, "#.##"), color.white)
    f_cell(0, 2, "LoD Dist%", color.white)
    f_cell(1, 2, str.tostring(lodDist, "#.##") + "%", lodColor)
    f_cell(0, 3, "Entry", color.white)
    f_cell(1, 3, str.tostring(entryPrice, "#.##"), color.white)
    f_cell(0, 4, "Stop (LoD)", color.white)
    f_cell(1, 4, str.tostring(stopPrice, "#.##"), color.white)
    f_cell(0, 5, "Stop Dist $", color.white)
    f_cell(1, 5, str.tostring(stopDist, "#.##"), color.white)
    f_cell(0, 6, "Risk $", color.white)
    f_cell(1, 6, str.tostring(riskDollars, "#.##"), color.white)
    f_cell(0, 7, "Shares", color.white)
    f_cell(1, 7, na(shares) ? "-" : str.tostring(shares, "#"), color.white)
    f_cell(0, 8, "Position $", color.white)
    f_cell(1, 8, na(posDollars) ? "-" : str.tostring(posDollars, "#"), color.white)
    f_cell(0, 9, "Position %", color.white)
    f_cell(1, 9, na(posPct) ? "-" : str.tostring(posPct, "#.##") + "%", posColor)
````
