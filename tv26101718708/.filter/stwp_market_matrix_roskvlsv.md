# STWP Market Matrix

- url: https://www.tradingview.com/script/roskVLsv-STWP-Market-Matrix/
- type: indicator
- pine_id: PUB;beccc93655c948edba6d0f5e848f478b
- version: 2.0

## Description

Overview
STWP Market Matrix is a multi-factor market dashboard designed to consolidate several commonly used technical concepts into a single visual framework.
Most technical indicators focus on one aspect of market analysis, such as trend, volume, volatility, or support and resistance. STWP Market Matrix combines these factors into a structured dashboard so traders can evaluate market conditions from multiple perspectives without switching between several indicators.
The objective is not to generate buy or sell signals, but to provide a quick and organized view of trend direction, participation, relative strength, volatility conditions, and key market reference levels.
________________________________________
Why This Indicator?
Market decisions are often influenced by multiple factors rather than a single indicator. A stock may show a bullish trend but weak participation, strong volume but poor relative strength, or favorable structure while trading below key reference levels.
STWP Market Matrix brings together:
• Trend Analysis (EMA Structure)
• VWAP Positioning
• Buyer vs Seller Participation
• Volume Assessment
• Market Structure Analysis
• Multi-Timeframe Confirmation
• Relative Strength vs NIFTY
• Daily Volume Context
• Pivot Reference Levels
• Volatility Assessment
into one dashboard to help users evaluate these conditions simultaneously.
________________________________________
Dashboard Components
Trend
Trend is determined using Fast and Slow Exponential Moving Averages (EMA).
Bullish: Fast EMA above Slow EMA
Bearish: Fast EMA below Slow EMA
This provides a simple directional bias.
________________________________________
VWAP
Displays whether price is trading above or below the Volume Weighted Average Price (VWAP).
VWAP is commonly used by traders to assess intraday strength and market positioning.
________________________________________
Buyers & Sellers
These metrics evaluate the balance between bullish and bearish candle pressure.
The goal is to provide a simple visual indication of whether buyers or sellers currently have greater influence on price movement.
________________________________________
Volume
Current volume is compared against average volume to identify participation levels.
Higher-than-average volume may indicate stronger market participation, while lower volume may suggest reduced activity.
________________________________________
Market State
The indicator classifies market conditions into:
Breakout
Breakdown
Range
based on recent price structure and historical highs/lows.
________________________________________
Price Structure
Price structure evaluates whether the market is producing:
Higher Highs and Higher Lows
Lower Highs and Lower Lows
Sideways Conditions
This provides additional context beyond simple trend analysis.
________________________________________
Multi-Timeframe Alignment
The dashboard evaluates whether higher timeframe EMA conditions support the current chart timeframe.
This helps identify whether trends are aligned across multiple timeframes.
________________________________________
Relative Strength (RS)
Relative Strength compares the selected symbol against the NIFTY Index.
Possible interpretations:
Outperforming
Underperforming
This helps identify whether a symbol is displaying relative leadership or weakness compared to the broader market.
________________________________________
Daily Volume
Daily volume is compared against its historical average to provide additional participation context.
________________________________________
Pivot Reference Framework
The dashboard includes classic pivot calculations based on the previous trading session's:
High
Low
Close
Displayed levels include:
Pivot
R1 to R5
S1 to S5
These levels are intended as objective reference zones that may help identify potential areas of support, resistance, reaction, or expansion.
The levels are not intended as price targets or predictions.
________________________________________
STWP Matrix Panel
Grade
A composite score derived from:
Trend Alignment
VWAP Position
Volume Participation
Relative Strength
Multi-Timeframe Confirmation
Grades range from D to A+.
Higher grades indicate stronger alignment among the evaluated factors.
________________________________________
Flow
Flow evaluates participation bias using candle position and volume behavior.
Possible states:
Accumulation
Distribution
Balanced
________________________________________
Energy
Energy evaluates volatility conditions using:
Bollinger Band Width
Average True Range (ATR)
Possible states:
Building
Normal
Exploding
This can help identify periods of contraction and expansion.
________________________________________
Risk
Risk provides a simplified assessment of current market conditions using momentum and volatility characteristics.
Possible states:
Low
Medium
High
________________________________________
Opportunity
Opportunity summarizes overall market conditions based on the dashboard's underlying factors.
Possible states:
Excellent
Good
Average
Avoid
This metric is intended to provide context and should not be interpreted as a trading recommendation.
________________________________________
Suggested Workflow
A possible workflow for using the dashboard:
Review Trend and VWAP alignment.
Evaluate Market State and Price Structure.
Check Relative Strength versus NIFTY.
Assess volume participation.
Review Pivot and Support/Resistance levels.
Evaluate Grade, Flow, Energy, Risk, and Opportunity readings.
Combine observations with personal analysis, trade planning, and risk management.
________________________________________
Limitations
The indicator relies entirely on historical price and volume data.
Pivot levels are reference zones and not guarantees of future market reactions.
Relative Strength readings may vary across instruments and timeframes.
Market conditions can change rapidly during periods of elevated volatility.
No technical indicator can predict future price movement with certainty.
The dashboard should be used as an analytical aid rather than a standalone decision-making system.
________________________________________
Disclaimer
This script is provided strictly for educational and informational purposes.
The indicator does not provide investment advice, research reports, trading recommendations, portfolio management services, or buy/sell calls.
All calculations are derived from historical price and volume data and are intended solely to assist technical analysis.
Users should conduct their own independent research, analysis, and risk assessment before making any trading or investment decisions.
Past performance does not guarantee future results. Financial markets involve risk, and losses may occur.
For users subject to SEBI regulations, this indicator should not be interpreted as a recommendation, solicitation, stock tip, investment advisory service, or research report.
Any trading or investment decision remains solely the responsibility of the user.
© Simple Trade With Patience (STWP)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © simpletradewithpatience

//@version=6
indicator("STWP Market Matrix", overlay=true, max_labels_count=200)

//================ INPUTS ================
fastEMA = input.int(9, "Fast EMA")
slowEMA = input.int(21, "Slow EMA")
volLen  = input.int(20, "Volume Length")
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD POSITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tablePosition = input.string(
     "Bottom Center",
     "Dashboard Position",
     options = [
          "Top Right",
          "Top Left",
          "Top Center",
          "Middle Right",
          "Middle Left",
          "Middle Center",
          "Bottom Right",
          "Bottom Left",
          "Bottom Center"
     ])

dashboardPosition =
     tablePosition == "Top Right" ? position.top_right :

     tablePosition == "Top Left" ? position.top_left :

     tablePosition == "Top Center" ? position.top_center :

     tablePosition == "Middle Right" ? position.middle_right :

     tablePosition == "Middle Left" ? position.middle_left :

     tablePosition == "Middle Center" ? position.middle_center :

     tablePosition == "Bottom Right" ? position.bottom_right :

     tablePosition == "Bottom Center" ? position.bottom_center :

     position.bottom_left

dashboardTextSize = input.string(
     "Normal",
     "Dashboard Text Size",
     options = ["Tiny", "Small", "Normal"])

tableTextSize =
     dashboardTextSize == "Tiny"  ? size.tiny  :
     dashboardTextSize == "Small" ? size.small :
     size.normal


//================ CORE ================
emaFast = ta.ema(close, fastEMA)
emaSlow = ta.ema(close, slowEMA)
vwapValue = ta.vwap(hlc3)
rsiValue = ta.rsi(close,14)
atrValue = ta.atr(14)
atrAvg   = ta.sma(atrValue,20)
volAvg   = ta.sma(volume,volLen)

//================ DAILY EMA LEVELS ================
ema9   = request.security(syminfo.tickerid, "D", ta.ema(close, 9))
ema21 = request.security(syminfo.tickerid, "D", ta.ema(close, 21))
ema50  = request.security(syminfo.tickerid, "D", ta.ema(close, 50))
ema100 = request.security(syminfo.tickerid, "D", ta.ema(close, 100))
ema200 = request.security(syminfo.tickerid, "D", ta.ema(close, 200))

//================ EMA STRUCTURE ================

fullBullStack =
     ema9 > ema21 and
     ema21 > ema50 and
     ema50 > ema100 and
     ema100 > ema200

fullBearStack =
     ema9 < ema21 and
     ema21 < ema50 and
     ema50 < ema100 and
     ema100 < ema200

goldenCross = ema50 > ema200
deathCross  = ema50 < ema200

emaSignal =
     fullBullStack ? "FULL BULL STACK" :
     fullBearStack ? "FULL BEAR STACK" :
     goldenCross ? "GOLDEN CROSS" :
     deathCross ? "DEATH CROSS" :
     "MIXED"

emaSignalColor =
     fullBullStack ? color.lime :
     fullBearStack ? color.red :
     goldenCross ? color.green :
     deathCross ? color.maroon :
     color.orange
     
//================ TREND ================
trendBull = emaFast > emaSlow
trendText = trendBull ? "BULLISH" : "BEARISH"
trendColor = trendBull ? color.lime : color.red

//================ VWAP ================
vwapText = close > vwapValue ? "ABOVE VWAP" : "BELOW VWAP"
vwapColor = close > vwapValue ? color.lime : color.red

//================ BUYERS / SELLERS ================
bullPower = ta.sma(close-low,10)
bearPower = ta.sma(high-close,10)

buyerText = bullPower > bearPower ? "BUYERS ACTIVE" : "BUYERS WEAK"
sellerText = bearPower > bullPower ? "SELLERS ACTIVE" : "SELLERS WEAK"

buyerColor = bullPower > bearPower ? color.lime : color.gray
sellerColor = bearPower > bullPower ? color.red : color.gray

//================ VOLUME ================
volumeText = volume > volAvg*1.5 ? "HIGH VOLUME" : volume > volAvg ? "ABOVE AVG" : "LOW VOLUME"
volumeColor = volume > volAvg*1.5 ? color.lime : volume > volAvg ? color.orange : color.red

//================ MARKET STATE ================
rangeHigh = ta.highest(high,40)
rangeLow  = ta.lowest(low,40)

marketState =
 close > rangeHigh[1] ? "BREAKOUT" :
 close < rangeLow[1] ? "BREAKDOWN" :
 "RANGING"

marketColor =
 marketState == "BREAKOUT" ? color.lime :
 marketState == "BREAKDOWN" ? color.red :
 color.yellow

//================ PRICE ACTION ================
priceAction =
 high > high[1] and low > low[1] ? "BULLISH STRUCTURE" :
 high < high[1] and low < low[1] ? "BEARISH STRUCTURE" :
 "RANGE"

priceColor =
 high > high[1] and low > low[1] ? color.lime :
 high < high[1] and low < low[1] ? color.red :
 color.orange

//================ MTF ================
ema15 = request.security(syminfo.tickerid,"15",ta.ema(close,50))
ema60 = request.security(syminfo.tickerid,"60",ta.ema(close,50))

mtfBull = close > ema15 and close > ema60
mtfText = mtfBull ? "MULTI TF BULLISH" : "MIXED"
mtfColor = mtfBull ? color.lime : color.orange

//================ RS ================
nifty = request.security("NSE:NIFTY", timeframe.period, close)
rs = close/nifty
rsma = ta.sma(rs,20)

rsText = rs > rsma ? "OUTPERFORMING" : "UNDERPERFORMING"
rsColor = rs > rsma ? color.lime : color.red

//================ DAILY VOL ================
dVol = request.security(syminfo.tickerid,"D",volume)
dAvg = request.security(syminfo.tickerid,"D",ta.sma(volume,20))

dailyText = dVol > dAvg*1.5 ? "HIGH VOLUME" : "LOW VOLUME"
dailyColor = dVol > dAvg*1.5 ? color.lime : color.orange

//================ STWP GRADE ================
gradeScore = 0
gradeScore += trendBull ? 1 : 0
gradeScore += close > vwapValue ? 1 : 0
gradeScore += volume > volAvg ? 1 : 0
gradeScore += mtfBull ? 1 : 0
gradeScore += rs > rsma ? 1 : 0

gradeText =
 gradeScore == 5 ? "A+" :
 gradeScore == 4 ? "A" :
 gradeScore == 3 ? "B" :
 gradeScore == 2 ? "C" : "D"

gradeColor = gradeScore >= 4 ? color.lime : gradeScore == 3 ? color.orange : color.red

//================ SMART FLOW ================
closePos = (close-low)/math.max(high-low, syminfo.mintick)

flowText =
 volume > volAvg*1.5 and closePos > 0.7 ? "ACCUMULATION" :
 volume > volAvg*1.5 and closePos < 0.3 ? "DISTRIBUTION" :
 "BALANCED"

flowColor =
 flowText == "ACCUMULATION" ? color.lime :
 flowText == "DISTRIBUTION" ? color.red :
 color.orange

//================ ENERGY ================
basis = ta.sma(close,20)
dev = ta.stdev(close,20)
bbw = ((basis+2*dev)-(basis-2*dev))/basis
bbwAvg = ta.sma(bbw,20)

energyText =
 bbw < bbwAvg and atrValue < atrAvg ? "BUILDING" :
 bbw > bbwAvg and atrValue > atrAvg ? "EXPLODING" :
 "NORMAL"

energyColor =
 energyText == "BUILDING" ? color.yellow :
 energyText == "EXPLODING" ? color.lime :
 color.orange

//================ RISK ================
risk = 0
risk += atrValue > atrAvg*1.5 ? 1 : 0
risk += math.abs(rsiValue-50) > 20 ? 1 : 0

riskText = risk == 0 ? "LOW" : risk == 1 ? "MEDIUM" : "HIGH"
riskColor = risk == 0 ? color.lime : risk == 1 ? color.orange : color.red

//================ OPPORTUNITY ================
oppText =
 gradeScore >= 5 ? "EXCELLENT" :
 gradeScore >= 4 ? "GOOD" :
 gradeScore >= 3 ? "AVERAGE" :
 "AVOID"

oppColor =
 gradeScore >= 5 ? color.lime :
 gradeScore >= 4 ? color.green :
 gradeScore >= 3 ? color.orange :
 color.red

//================ PIVOTS ================
ph = request.security(syminfo.tickerid,"D",high[1])
pl = request.security(syminfo.tickerid,"D",low[1])
pc = request.security(syminfo.tickerid,"D",close[1])

pivot=(ph+pl+pc)/3

r1=2*pivot-pl
r2=pivot+(ph-pl)
r3=ph+2*(pivot-pl)
r4=r3+(r3-r2)
r5=r4+(r4-r3)

s1=2*pivot-ph
s2=pivot-(ph-pl)
s3=pl-2*(ph-pivot)
s4=s3-(s2-s3)
s5=s4-(s3-s4)

rsiText =
     rsiValue >= 80 ? "EXTREME OB" :
     rsiValue >= 70 ? "OVERBOUGHT" :
     rsiValue >= 60 ? "STRONG" :
     rsiValue > 40 ? "NEUTRAL" :
     rsiValue > 30 ? "WEAK" :
     rsiValue > 20 ? "OVERSOLD" :
     "EXTREME OS"

rsiColor =
     rsiValue >= 80 ? color.fuchsia :
     rsiValue >= 70 ? color.red :
     rsiValue >= 60 ? color.lime :
     rsiValue > 40 ? color.orange :
     rsiValue > 30 ? color.red :
     rsiValue > 20 ? color.aqua :
     color.blue

//================ DASHBOARD ================

var table t = table.new(
     dashboardPosition,
     6,
     16,
     bgcolor=color.rgb(35,40,52),
     border_width=1,
     border_color=color.gray)

if barstate.islast

    // HEADER

    table.cell(t,0,0,"STWP ELITE",
         text_color=color.yellow, text_size = tableTextSize)

    table.cell(t,1,0,syminfo.ticker,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,0,"PIVOTS",
         text_color=color.yellow, text_size = tableTextSize)

    table.cell(t,3,0,timeframe.period,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,4,0,"STWP AI",
         text_color=color.yellow, text_size = tableTextSize)

    table.cell(t,5,0,      fullBullStack ? "BULL" :     fullBearStack ? "BEAR" :     goldenCross ? "GC" :     "MIXED",     text_color =           fullBullStack ? color.lime :          fullBearStack ? color.red :          goldenCross ? color.green :          color.orange, text_size = tableTextSize)

    // LEFT PANEL

    table.cell(t,0,1,"TREND",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,1,trendText,bgcolor=trendColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,2,"VWAP",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,2,vwapText+ " " + str.tostring(vwapValue,"#.##"), bgcolor=vwapColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,3,"BUYERS",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,3,buyerText,bgcolor=buyerColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,4,"SELLERS",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,4,sellerText,bgcolor=sellerColor,text_color=color.white, text_size = tableTextSize)

    table.cell(t,0,5,"VOLUME",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,5,volumeText,bgcolor=volumeColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,6,"MARKET",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,6,marketState,bgcolor=marketColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,7,"PRICE",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,7,priceAction,bgcolor=priceColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,8,"MULTI TF",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,8,mtfText,bgcolor=mtfColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,9,"RS",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,9,rsText,bgcolor=rsColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,10,"DAILY VOL",text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,10,dailyText,bgcolor=dailyColor,text_color=color.black, text_size = tableTextSize)

    table.cell(t,0,11,"RSI", text_color=color.white, text_size = tableTextSize)
    table.cell(t,1,11,      rsiText + " (" + str.tostring(math.round(rsiValue)) + ")",     bgcolor=rsiColor,     text_color=color.black, text_size = tableTextSize)

    // PIVOT PANEL

    table.cell(t,2,1,"PIVOT",
         text_color=color.yellow, text_size = tableTextSize)

    table.cell(t,3,1,str.tostring(pivot,"#.##"),
         bgcolor=color.yellow,
         text_color=color.black, text_size = tableTextSize)

    table.cell(t,2,2,"R5",
         text_color=color.red, text_size = tableTextSize)

    table.cell(t,3,2,str.tostring(r5,"#.##"),
         bgcolor=color.red,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,3,"R4",
         text_color=color.red, text_size = tableTextSize)

    table.cell(t,3,3,str.tostring(r4,"#.##"),
         bgcolor=color.red,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,4,"R3",
         text_color=color.red, text_size = tableTextSize)

    table.cell(t,3,4,str.tostring(r3,"#.##"),
         bgcolor=color.red,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,5,"R2",
         text_color=color.red, text_size = tableTextSize)

    table.cell(t,3,5,str.tostring(r2,"#.##"),
         bgcolor=color.red,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,6,"R1",
         text_color=color.red, text_size = tableTextSize)

    table.cell(t,3,6,str.tostring(r1,"#.##"),
         bgcolor=color.red,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,7,"S1",
         text_color=color.teal, text_size = tableTextSize)

    table.cell(t,3,7,str.tostring(s1,"#.##"),
         bgcolor=color.teal,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,8,"S2",
         text_color=color.teal, text_size = tableTextSize)

    table.cell(t,3,8,str.tostring(s2,"#.##"),
         bgcolor=color.teal,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,9,"S3",
         text_color=color.teal, text_size = tableTextSize)

    table.cell(t,3,9,str.tostring(s3,"#.##"),
         bgcolor=color.teal,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,10,"S4",
         text_color=color.teal, text_size = tableTextSize)

    table.cell(t,3,10,str.tostring(s4,"#.##"),
         bgcolor=color.teal,
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,2,11,"S5",
         text_color=color.teal, text_size = tableTextSize)

    table.cell(t,3,11,str.tostring(s5,"#.##"),
         bgcolor=color.teal,
         text_color=color.white, text_size = tableTextSize)

    // STWP AI PANEL

    table.cell(t,4,1,"GRADE",
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,5,1,gradeText,
         bgcolor=gradeColor,
         text_color=color.black, text_size = tableTextSize)

    table.cell(t,4,2,"FLOW",
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,5,2,flowText,
         bgcolor=flowColor,
         text_color=color.black, text_size = tableTextSize)

    table.cell(t,4,3,"ENERGY",
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,5,3,energyText,
         bgcolor=energyColor,
         text_color=color.black, text_size = tableTextSize)

    table.cell(t,4,4,"RISK",
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,5,4,riskText,
         bgcolor=riskColor,
         text_color=color.black, text_size = tableTextSize)

    table.cell(t,4,5,"OPPORTUNITY",
         text_color=color.white, text_size = tableTextSize)

    table.cell(t,5,5,oppText,
         bgcolor=oppColor,
         text_color=color.black, text_size = tableTextSize)

     //================ EMA PANEL ================

    table.cell(t,4,6,"EMA 9",      text_color=color.white, text_size = tableTextSize)
    table.cell(t,5,6,      str.tostring(ema9,"#.##"),     bgcolor=color.blue,     text_color=color.white, text_size = tableTextSize)

    table.cell(t,4,7,"EMA 21",     text_color=color.white, text_size = tableTextSize)
    table.cell(t,5,7,     str.tostring(ema21,"#.##"),     bgcolor=color.blue,     text_color=color.white, text_size = tableTextSize)

    table.cell(t,4,8,"EMA 50",     text_color=color.white, text_size = tableTextSize)
    table.cell(t,5,8,    str.tostring(ema50,"#.##"),     bgcolor=color.blue,     text_color=color.white, text_size = tableTextSize)

    table.cell(t,4,9,"EMA 100",     text_color=color.white, text_size = tableTextSize)
    table.cell(t,5,9,    str.tostring(ema100,"#.##"),     bgcolor=color.blue,     text_color=color.white, text_size = tableTextSize)

    table.cell(t,4,10,"EMA 200",     text_color=color.white, text_size = tableTextSize)
    table.cell(t,5,10,     str.tostring(ema200,"#.##"),    bgcolor=color.blue,
     text_color=color.white, text_size = tableTextSize)

    table.cell(t,4,11,"EMA XOVER",     text_color=color.white, text_size = tableTextSize)
    table.cell(t,5,11,emaSignal,    bgcolor=emaSignalColor,     text_color=color.black, text_size = tableTextSize)

    // FOOTER

    table.cell(t,0,15,
         "EDUCATIONAL ONLY",
         text_color=color.yellow, text_size = tableTextSize)

    table.cell(t,5,15,
         "STWP",
         text_color=color.lime, text_size = tableTextSize)
````
