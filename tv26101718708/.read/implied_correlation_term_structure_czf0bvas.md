# Implied Correlation Term Structure

- url: https://www.tradingview.com/script/CZF0bvAs-Implied-Correlation-Term-Structure/
- type: indicator
- pine_id: PUB;6c8ab2a3fcab42ea8584270941b0e81e
- version: 1.0

## Description

I built this as a macro indicator that may help signal corrections when the spread between 1 month implied correlation and 3 month implied correlation moves between negative and positive levels. I used a rolling percentile rather than absolute levels in the table as implied correlation evolves over time.
While not meant to be used on its own, I think it could be useful as part of a macro regime to help determine the mean reverting nature of certain metrics such as implied correlation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © m_chromatic


//@version=6
indicator("Implied Correlation Term Structure", overlay=false)

//==================================================
// USER INPUTS
//==================================================

// Replace with your actual symbols
COR1M_symbol = input.symbol("CBOE:COR1M", "1M Implied Correlation")
COR3M_symbol = input.symbol("CBOE:COR3M", "3M Implied Correlation")

zLength = input.int(60, "Z-Score Length")

//==================================================
// DATA
//==================================================

COR1M = request.security(COR1M_symbol, timeframe.period, close)
COR3M = request.security(COR3M_symbol, timeframe.period, close)

//==================================================
// CALCULATIONS
//==================================================

spread = COR1M - COR3M
ratio  = COR3M != 0 ? COR1M / COR3M : na

spreadMean = ta.sma(spread, zLength)
spreadStd  = ta.stdev(spread, zLength)

zscore = spreadStd != 0 ?
          (spread - spreadMean) / spreadStd : na
          //==================================================
// PERCENTILE RANK
//==================================================

lookback = input.int(252, "Percentile Lookback")

count = 0.0

for i = 0 to lookback - 1
    count += spread > spread[i] ? 1 : 0

spreadPctRank = 100 * count / lookback

//==================================================
// PLOTS
//==================================================

hline(0, "Zero", color=color.gray)

plot(spread,
     title="1M - 3M Spread",
     color=color.orange,
     linewidth=2)

plot(zscore,
     title="Spread Z-Score",
     color=color.aqua,
     linewidth=2)

plot(ratio,
     title="1M / 3M Ratio",
     color=color.yellow,
     linewidth=2)

//==================================================
// SIGNALS
//==================================================

bullStress =
     spread > 0 and
     ratio > 1.05

bearStress =
     spread < 0 and
     ratio < 0.95

bgcolor(
 bullStress ?
 color.new(color.red, 85) :
 bearStress ?
 color.new(color.green, 85) :
 na)

plotshape(
 bullStress,
 title="Near-Term Correlation Spike",
 location=location.top,
 style=shape.triangledown,
 color=color.red,
 size=size.tiny)

plotshape(
 bearStress,
 title="Long-Term Correlation Premium",
 location=location.bottom,
 style=shape.triangleup,
 color=color.green,
 size=size.tiny)
 //==================================================
// DYNAMIC REGIME
//==================================================

string regime = "Neutral"
color regimeColor = color.gray

if spreadPctRank >= 95
    regime := "CRISIS"
    regimeColor := color.rgb(128,0,0)

else if spreadPctRank >= 90
    regime := "RISK OFF"
    regimeColor := color.red

else if spreadPctRank >= 75
    regime := "EARLY WARNING"
    regimeColor := color.orange

else if spreadPctRank <= 10
    regime := "STRONG RISK ON"
    regimeColor := color.lime

else if spreadPctRank <= 25
    regime := "RISK ON"
    regimeColor := color.green

//==================================================
// DASHBOARD TABLE
//==================================================

var table dashboard =
     table.new(
         position.top_right,
         5,
         8,
         border_width = 2)

if barstate.islast

    // Header Row
    table.cell(
         dashboard, 0, 0,
         "Metric",
         bgcolor=color.blue,
         text_color=color.white)

    table.cell(
         dashboard, 1, 0,
         "Value",
         bgcolor=color.blue,
         text_color=color.white)

    table.cell(
         dashboard, 2, 0,
         "Status",
         bgcolor=color.blue,
         text_color=color.white)

    table.cell(
         dashboard, 3, 0,
         "Level",
         bgcolor=color.blue,
         text_color=color.white)

    table.cell(
         dashboard, 4, 0,
         "Regime",
         bgcolor=color.blue,
         text_color=color.white)

    // Spread
    table.cell(dashboard,0,1,"Spread")
    table.cell(dashboard,1,1,str.tostring(spread,"#.00"))

    table.cell(
         dashboard,2,1,
         spread > 0 ? "Positive" : "Negative",
         bgcolor = spread > 0 ?
                   color.new(color.red,70) :
                   color.new(color.green,70))

    // Ratio
    table.cell(dashboard,0,2,"Ratio")
    table.cell(dashboard,1,2,str.tostring(ratio,"#.00"))

    table.cell(
         dashboard,2,2,
         ratio > 1 ? "Front Loaded" : "Back Loaded",
         bgcolor = ratio > 1 ?
                   color.new(color.orange,70) :
                   color.new(color.green,70))

    // Z Score
    table.cell(dashboard,0,3,"Spread Z")
    table.cell(dashboard,1,3,str.tostring(zscore,"#.00"))

    table.cell(
         dashboard,2,3,
         zscore > 2 ? "Extreme" :
         zscore > 1 ? "Elevated" :
         "Normal",
         bgcolor =
         zscore > 2 ? color.red :
         zscore > 1 ? color.orange :
         color.green)

    // Percentile
    table.cell(dashboard,0,4,"Percentile")
    table.cell(dashboard,1,4,str.tostring(spreadPctRank,"#.0"))

    // Regime Row
    table.cell(
         dashboard,0,6,
         "CURRENT REGIME",
         bgcolor=color.black,
         text_color=color.white)

    table.cell(
         dashboard,1,6,
         regime,
         bgcolor=regimeColor,
         text_color=color.white)

    // Legend
    table.cell(dashboard,3,1,"95-100")
    table.cell(dashboard,4,1,"CRISIS",
               bgcolor=color.rgb(128,0,0))

    table.cell(dashboard,3,2,"90-95")
    table.cell(dashboard,4,2,"RISK OFF",
               bgcolor=color.red)

    table.cell(dashboard,3,3,"75-90")
    table.cell(dashboard,4,3,"WARNING",
               bgcolor=color.orange)

    table.cell(dashboard,3,4,"25-75")
    table.cell(dashboard,4,4,"NEUTRAL",
               bgcolor=color.gray)

    table.cell(dashboard,3,5,"10-25")
    table.cell(dashboard,4,5,"RISK ON",
               bgcolor=color.green)

    table.cell(dashboard,3,6,"0-10")
    table.cell(dashboard,4,6,"STRONG ON",
               bgcolor=color.lime)
````
