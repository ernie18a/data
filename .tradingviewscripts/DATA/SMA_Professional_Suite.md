<!-- tradingview-pine-id: PUB;0020b1eb91154b4f942f429c9e3ff180 -->
<!-- tradingviewscripts-format: 1 -->
# SMA Professional Suite

Source: https://www.tradingview.com/script/7nOn1shi-SMA-Professional-Suite/

## Description

Trend Following System.
its about entry on pullback while on uptrend or downtrend. with ADX and ATR trend identification becomes very accurate.

---

## Source Code

````pine
//@version=6
indicator("SMA Professional Suite", shorttitle="SMA Pro", overlay=true)

//========================================================
// SMA Professional Suite
// Developed by : Jatin Patel
// Version : 1.0
//========================================================

//=========================
// INPUTS
//=========================

smaLength      = input.int(50, "SMA Length", minval=1)
showSMA        = input.bool(true, "Show 50 SMA")
showDashboard  = input.bool(true, "Show Dashboard")
showBackground = input.bool(true, "Show Background")

//=========================
// CALCULATIONS
//=========================

sma50 = ta.sma(close, smaLength)

plot(showSMA ? sma50 : na, title="50 SMA", color=color.orange, linewidth=2)

// Trend

slope = sma50 - sma50[10]

isUpTrend   = close > sma50 and slope > 0
isDownTrend = close < sma50 and slope < 0
isSideways  = not isUpTrend and not isDownTrend

//=========================
// BACKGROUND
//=========================

bgcolor(
 showBackground ?
 isUpTrend ? color.new(color.green,90) :
 isDownTrend ? color.new(color.red,90) :
 color.new(color.yellow,90)
 : na)
//=========================
// VERSION 2 - TREND ENGINE
//=========================

// ADX
adxLength = input.int(14, "ADX Length")
// ADX Calculation

upMove = high - high[1]
downMove = low[1] - low

plusDM = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

trur = ta.rma(ta.tr, adxLength)

plusDI = 100 * ta.rma(plusDM, adxLength) / trur
minusDI = 100 * ta.rma(minusDM, adxLength) / trur

dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)

adx = ta.rma(dx, adxLength)

// ATR
atrLength = input.int(14, "ATR Length")
atr = ta.atr(atrLength)

// Volume
volLength = input.int(20, "Volume SMA Length")
volMA = ta.sma(volume, volLength)

highVolume = volume > volMA

//=========================
// TREND SCORE
//=========================

trendScore = 0

trendScore += isUpTrend or isDownTrend ? 40 : 0
trendScore += adx > 25 ? 30 : adx > 20 ? 20 : 0
trendScore += highVolume ? 20 : 0
trendScore += atr > ta.sma(atr,20) ? 10 : 0

trendStatus =
     trendScore >= 80 ? "STRONG" :
     trendScore >= 60 ? "GOOD" :
     trendScore >= 40 ? "AVERAGE" :
     "WEAK"

trendColor =
     trendScore >= 80 ? color.green :
     trendScore >= 60 ? color.lime :
     trendScore >= 40 ? color.orange :
     color.red
//=========================
// DASHBOARD
//=========================

var table dash = table.new(position.top_right,2,8,border_width=1)

if barstate.islast and showDashboard

    table.cell(dash,0,0,"SMA Professional",bgcolor=color.blue,text_color=color.white)
    table.cell(dash,1,0,"v1.0",bgcolor=color.blue,text_color=color.white)

    trendText =
         isUpTrend ? "UPTREND" :
         isDownTrend ? "DOWNTREND" :
         "SIDEWAYS"

    trendColor =
         isUpTrend ? color.green :
         isDownTrend ? color.red :
         color.orange

    table.cell(dash,0,1,"Trend")
    table.cell(dash,1,1,trendText,bgcolor=trendColor,text_color=color.white)

    table.cell(dash,0,2,"Close")
    table.cell(dash,1,2,str.tostring(close, format.mintick))

    table.cell(dash,0,3,"50 SMA")
    table.cell(dash,1,3,str.tostring(sma50, format.mintick))
    table.cell(dash,0,4,"ADX")
table.cell(dash,1,4,str.tostring(adx,"#.0"))

table.cell(dash,0,5,"ATR")
table.cell(dash,1,5,str.tostring(atr, format.mintick))

table.cell(dash,0,6,"Volume")
table.cell(dash,1,6,highVolume ? "HIGH" : "LOW")

table.cell(dash,0,7,"Trend Score")
table.cell(dash,1,7,str.tostring(trendScore)+" /100",
     bgcolor=trendColor,
     text_color=color.white)
````
