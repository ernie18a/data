# UCS_S_Steve Primo - Strategy 1

- url: https://www.tradingview.com/script/oAbuyZv1-UCS-S-Steve-Primo-Strategy-1/
- type: indicator
- pine_id: PUB;1515
- version: -1.0

## Description

Here is the code for Steve Primo Strategy #1 Long and Short Setups. 

- Post your views and share the knowledge. 

Watch his free videos on youtube for trigger and trade management

## Source Code

````pine
study(shorttitle="SP-S#1", title = "Steve Primo - Strategy #1", overlay = true, precision = 2)

//Indicator 1
lowerpc = lowest(low, 21)
upperpc = highest(high, 21)
midpc = avg(upperpc, lowerpc)

//Indicator 2
ma = sma(close, 50)
petd = ema(close,13)
rangema = ema(tr, 50)
upperkc = ma + rangema * 0.25
lowerkc = ma - rangema * 0.25

//Indicator 3
up = rma(max(change(close), 0), 5)
down = rma(-min(change(close), 0), 5)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// PET-D
petdcolor = close > petd ? green : red
barcolor (petdcolor)


// ALL PLOT
plot (midpc, linewidth = 1, color = orange, title = "Mid Price Channel")
plot (upperpc, linewidth = 2, color = purple, title = "Upper Price Channel")
plot (lowerpc, linewidth = 2, color = purple, title = "Lower Price Channel")
plot (ma, linewidth = 3, color = black, title = "Trend - Long Term")
plot (petd, linewidth = 1, color = blue, title = "Trend - Short Term")

//Slope
SlopeL = midpc > midpc[5]
SlopeS = midpc < midpc[5]

//Condition
CL = SlopeL == 1 and close > lowerkc and close < midpc and rsi < 35 
CS = SlopeS == 1 and close < upperkc and close > midpc and rsi > 65 

//Setup
SL = CL == 1 and CL[1] != 1
SS = CS == 1 and CS[1] != 1

plotshape(SL, title="Long Setup Bar", style=shape.labelup, location=location.belowbar, color=lime, transp=25, text="SP #1 Long", textcolor = black)
plotshape(SS, title="Short Setup Bar", style=shape.labeldown, location=location.abovebar, color=orange, transp=25, text="SP #1 Short", textcolor = black)
````
