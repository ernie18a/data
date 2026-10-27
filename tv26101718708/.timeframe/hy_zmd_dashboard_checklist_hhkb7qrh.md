# Hy ZMD Dashboard Checklist

- url: https://www.tradingview.com/script/hhKB7QrH-Hy-ZMD-Dashboard-Checklist/
- type: indicator
- pine_id: PUB;2a32b7bb532e4139962860d1e233b06e
- version: 1.0

## Description

If you've ever used Sonic R to analyze trends, this indicator will save you time. The indicator doesn't help you trade better; it only helps you hold your money longer.

## Source Code

````pine
//@version=6
indicator("Hy ZMD Dashboard Checklist", overlay=true)

//====================================================
// COLORS
//====================================================

dashboardText = color.new(color.white, 45)
titleText     = color.new(color.white, 15)

bullColor     = color.new(color.lime, 25)
bearColor     = color.new(color.red, 25)
neutralColor  = color.new(color.orange, 25)

//====================================================
// EMA
//====================================================

ema34 = ta.ema(close, 34)
ema89 = ta.ema(close, 89)

d1_ema34 = request.security(syminfo.tickerid, "D", ta.ema(close, 34))
d1_ema89 = request.security(syminfo.tickerid, "D", ta.ema(close, 89))

h4_ema34 = request.security(syminfo.tickerid, "240", ta.ema(close, 34))
h4_ema89 = request.security(syminfo.tickerid, "240", ta.ema(close, 89))

h1_ema34 = request.security(syminfo.tickerid, "60", ta.ema(close, 34))
h1_ema89 = request.security(syminfo.tickerid, "60", ta.ema(close, 89))

//====================================================
// TREND
//====================================================

d1Bull = d1_ema34 > d1_ema89
h4Bull = h4_ema34 > h4_ema89
h1Bull = h1_ema34 > h1_ema89

trendScore = 0
trendScore += d1Bull ? 1 : 0
trendScore += h4Bull ? 1 : 0
trendScore += h1Bull ? 1 : 0

string bias = "NEUTRAL"

if trendScore == 3
    bias := "LONG"
else if trendScore == 0
    bias := "SHORT"

biasColor = bias == "LONG" ? bullColor : bias == "SHORT" ? bearColor : neutralColor

//====================================================
// SMC
//====================================================

highest20 = ta.highest(high,20)
lowest20  = ta.lowest(low,20)

liquidityHigh = high > highest20[1]
liquidityLow  = low < lowest20[1]

bosBull = close > ta.highest(high,10)[1]
bosBear = close < ta.lowest(low,10)[1]

smcScore = 0
smcScore += liquidityHigh or liquidityLow ? 2 : 0
smcScore += bosBull or bosBear ? 1 : 0

string smcGrade = "C"

if smcScore >= 5
    smcGrade := "A"
else if smcScore >= 3
    smcGrade := "B"

//====================================================
// SONIC R
//====================================================

dragonBull = ema34 > ema89

retestDragon = low <= ema34 and close > ema34

bullEngulf = close > open and close[1] < open[1] and close > open[1]

volumeSpike = volume > ta.sma(volume,20) * 1.5

entryScore = 0
entryScore += dragonBull ? 1 : 0
entryScore += retestDragon ? 1 : 0
entryScore += bullEngulf ? 1 : 0
entryScore += volumeSpike ? 1 : 0

//====================================================
// MAIN DASHBOARD
//====================================================

var table dash = table.new(position.top_right, 2, 25, frame_width = 0, border_width = 0, bgcolor = na)

if barstate.islast

    //====================================================
    // BIAS
    //====================================================

    table.cell(dash,0,0,"TREND",text_color=titleText)
    table.cell(dash,1,0,"STATUS",text_color=titleText)

    table.cell(dash,0,1,"D1",text_color=dashboardText)
    table.cell(dash,1,1,d1Bull ? "BULL" : "BEAR",text_color=biasColor)

    table.cell(dash,0,2,"H4",text_color=dashboardText)
    table.cell(dash,1,2,h4Bull ? "BULL" : "BEAR",text_color=biasColor)

    table.cell(dash,0,3,"H1",text_color=dashboardText)
    table.cell(dash,1,3,h1Bull ? "BULL" : "BEAR",text_color=biasColor)

    table.cell(dash,0,4,"BIAS",text_color=dashboardText)
    table.cell(dash,1,4,bias,text_color=biasColor)


    table.cell(dash,0,6,"STATUS",text_color=dashboardText)

    table.cell(
         dash,
         1,
         6,
         bias == "LONG" ? "BUY ONLY" :
         bias == "SHORT" ? "SELL ONLY" :
         "NO TRADE",
         text_color=biasColor)

    // Spacer

    table.cell(dash,0,7," ")
    table.cell(dash,1,7," ")

    //====================================================
    // SONIC R
    //====================================================

    table.cell(dash,0,8,"SONIC R",text_color=titleText)
    table.cell(dash,1,8,"")

    table.cell(dash,0,9,"Dragon",text_color=dashboardText)
    table.cell(dash,1,9,dragonBull ? "YES" : "NO",text_color=dashboardText)

    table.cell(dash,0,10,"Retest",text_color=dashboardText)
    table.cell(dash,1,10,retestDragon ? "YES" : "NO",text_color=dashboardText)

    table.cell(dash,0,11,"Engulf",text_color=dashboardText)
    table.cell(dash,1,11,bullEngulf ? "YES" : "NO",text_color=dashboardText)

    table.cell(dash,0,12,"Volume",text_color=dashboardText)
    table.cell(dash,1,12,volumeSpike ? "YES" : "NO",text_color=dashboardText)

    table.cell(dash,0,13,"Score",text_color=dashboardText)
    table.cell(dash,1,13,str.tostring(entryScore),text_color=dashboardText)

    // Spacer

    table.cell(dash,0,14," ")
    table.cell(dash,1,14," ")

    //====================================================
    // SMC SCORE
    //====================================================

    table.cell(dash,0,15,"SMC SCORE",text_color=titleText)
    table.cell(dash,1,15,"")

    table.cell(dash,0,16,"Liquidity",text_color=dashboardText)
    table.cell(
         dash,
         1,
         16,
         (liquidityHigh or liquidityLow) ? "YES" : "NO",
         text_color=dashboardText)

    table.cell(dash,0,17,"BOS",text_color=dashboardText)
    table.cell(
         dash,
         1,
         17,
         (bosBull or bosBear) ? "YES" : "NO",
         text_color=dashboardText)

    table.cell(dash,0,18,"Score",text_color=dashboardText)
    table.cell(dash,1,18,str.tostring(smcScore),text_color=dashboardText)

    table.cell(dash,0,19,"Grade",text_color=dashboardText)
    table.cell(dash,1,19,smcGrade,text_color=dashboardText)
````
