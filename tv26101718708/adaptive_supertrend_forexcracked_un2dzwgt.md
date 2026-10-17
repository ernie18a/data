# Adaptive Supertrend [ForexCracked]

- url: https://www.tradingview.com/script/uN2Dzwgt-Adaptive-Supertrend-ForexCracked/
- type: indicator
- pine_id: PUB;406599f859534e33a41f4b3802f2bc14
- version: 2.0

## Description

🔷 OVERVIEW

Adaptive Supertrend is a trend-following tool that automatically adjusts its sensitivity to current market volatility. A classic Supertrend uses one fixed factor, which whipsaws in choppy conditions and lags in calm ones. This version measures the live volatility regime and scales the ATR factor between a low and a high setting, so the trail tightens when volatility is low and widens when volatility is high.

🔷 CONCEPTS

Supertrend trails price using an ATR band whose width is set by a "factor." Instead of one fixed factor, this script ranks the current ATR against its own recent range (a 0–100 volatility percentile) and maps that rank onto a factor between your Min and Max settings:

• Low volatility → smaller factor → tighter trail, earlier signals. • High volatility → larger factor → wider trail, fewer false flips.

🔷 HOW TO USE

• Stay with the trend while the line sits below price (up) or above price (down). • A flip of the line marks a potential trend change, shown with a Buy or Sell label. • Read the Info panel for the live trend and the current volatility regime (Low / Medium / High). • Combine it with structure or support and resistance for confirmation, and always use a stop. No single indicator is a complete system.

🔷 SETTINGS

• ATR Length — lookback for the ATR band. • Min Factor / Max Factor — the range the factor adapts between. • Volatility Lookback — bars used to rank the current volatility. • Style — Buy/Sell labels, gradient fill, info panel, bar coloring, and colors.

🔷 ALERTS

• Buy (flip up) and Sell (flip down).

Free and open-source. Educational tool, not financial advice.

## Source Code

````pine
//@version=6
// © ForexCracked  —  free & open-source  —  Licensed under CC BY-NC-SA 4.0
// https://creativecommons.org/licenses/by-nc-sa/4.0/

indicator("Adaptive Supertrend [ForexCracked]", "Adaptive ST [FXC]", overlay = true, max_labels_count = 500)

//=====================================================================================================================
// INPUTS
//=====================================================================================================================
gST = "Supertrend"
atrLen  = input.int(10,    "ATR Length",            minval = 1,               group = gST)
minMult = input.float(1.5, "Min Factor (low vol)",  minval = 0.5, step = 0.1, group = gST, tooltip = "Factor used when volatility is LOW: tighter trail, earlier signals.")
maxMult = input.float(5.0, "Max Factor (high vol)", minval = 0.5, step = 0.1, group = gST, tooltip = "Factor used when volatility is HIGH: wider trail, fewer whipsaws.")
volLook = input.int(100,   "Volatility Lookback",   minval = 10,              group = gST, tooltip = "Bars used to rank the current volatility (0-100 percentile of ATR).")

gSt = "Style"
showSig  = input.bool(true,  "Buy / Sell labels", group = gSt)
showFill = input.bool(true,  "Gradient fill",     group = gSt)
showTbl  = input.bool(true,  "Info panel",        group = gSt)
showBars = input.bool(false, "Color bars",        group = gSt)
upCol    = input.color(#2dd4bf, "Up",   inline = "c", group = gSt)
dnCol    = input.color(#e84e89, "Down", inline = "c", group = gSt)
tblPosIn = input.string("Top Right", "Panel position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gSt)
tblPos = tblPosIn == "Top Left" ? position.top_left : tblPosIn == "Bottom Right" ? position.bottom_right : tblPosIn == "Bottom Left" ? position.bottom_left : position.top_right

//=====================================================================================================================
// ADAPTIVE FACTOR
//   Rank current ATR against its own recent range, then map that 0-100 rank onto a factor between Min and Max.
//   Low volatility  -> small factor -> tighter trail, earlier signals.
//   High volatility -> large factor -> wider trail, fewer false flips.
//=====================================================================================================================
atr     = ta.atr(atrLen)
volRank = ta.percentrank(atr, volLook)
factor  = minMult + (maxMult - minMult) * nz(volRank, 50) / 100.0

//=====================================================================================================================
// SUPERTREND  (manual, so the adaptive factor drives the trail on every bar)
//=====================================================================================================================
src = hl2
upBand = src - factor * atr
upBand := close[1] > nz(upBand[1], upBand) ? math.max(upBand, nz(upBand[1], upBand)) : upBand
dnBand = src + factor * atr
dnBand := close[1] < nz(dnBand[1], dnBand) ? math.min(dnBand, nz(dnBand[1], dnBand)) : dnBand

var int trend = 1
trend := trend == -1 and close > nz(dnBand[1], dnBand) ? 1 : trend == 1 and close < nz(upBand[1], upBand) ? -1 : trend
st = trend == 1 ? upBand : dnBand
up = trend == 1

buy  = up and not up[1]
sell = not up and up[1]

//=====================================================================================================================
// PLOTS
//=====================================================================================================================
stCol  = up ? upCol : dnCol
stLine = plot(st, "Adaptive Supertrend", color = stCol, linewidth = 2)
priceP = plot(showFill ? close : na, "src", display = display.none)
fill(stLine, priceP, color = showFill ? color.new(stCol, 88) : na, title = "Fill")

if showSig and buy
    label.new(bar_index, st, "Buy",  style = label.style_label_up,   color = upCol, textcolor = color.white, size = size.small)
if showSig and sell
    label.new(bar_index, st, "Sell", style = label.style_label_down, color = dnCol, textcolor = color.white, size = size.small)

barcolor(showBars ? (up ? color.new(upCol, 30) : color.new(dnCol, 30)) : na)

//=====================================================================================================================
// INFO PANEL
//=====================================================================================================================
bg  = #1a2c4c
hd  = #1f3a63
lbl = #9fb0c4
regime = na(volRank) ? "n/a" : volRank >= 66 ? "High" : volRank >= 33 ? "Medium" : "Low"
regCol = na(volRank) ? lbl : volRank >= 66 ? dnCol : volRank >= 33 ? #cbb26b : upCol
volTxt = na(volRank) ? "n/a" : regime + "  " + str.tostring(math.round(volRank))
if showTbl and barstate.islast
    var table t = table.new(tblPos, 2, 4, bgcolor = bg, frame_color = color.new(color.gray, 55), frame_width = 1, border_color = color.new(#2a3d63, 25), border_width = 1)
    table.cell(t, 0, 0, " Adaptive Supertrend ", text_color = color.white, bgcolor = hd, text_size = size.small)
    table.cell(t, 1, 0, "", bgcolor = hd)
    table.cell(t, 0, 1, "Trend", text_color = lbl, text_size = size.small)
    table.cell(t, 1, 1, up ? "Up" : "Down", text_color = up ? upCol : dnCol, text_size = size.normal)
    table.cell(t, 0, 2, "Volatility", text_color = lbl, text_size = size.small)
    table.cell(t, 1, 2, volTxt, text_color = regCol, text_size = size.small)
    table.cell(t, 0, 3, "Factor", text_color = lbl, text_size = size.small)
    table.cell(t, 1, 3, str.tostring(math.round(factor * 100) / 100), text_color = color.white, text_size = size.small)

//=====================================================================================================================
// ALERTS
//=====================================================================================================================
alertcondition(buy,  "Buy (flip up)",    "Adaptive Supertrend [ForexCracked] flipped UP")
alertcondition(sell, "Sell (flip down)", "Adaptive Supertrend [ForexCracked] flipped DOWN")
````
