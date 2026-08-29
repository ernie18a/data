<!-- tradingview-pine-id: PUB;Zd1PZqZcepxG59SeRXxr7UDdnzV1Qd0H -->
<!-- tradingviewscripts-format: 1 -->
# Dot Dynamics

Source: https://www.tradingview.com/script/kjj8hdDK-Dynamic-Dots-Dashboard-a-Cloud-ZLEMA-Composite/

## Description

The purpose of this indicator is to provide an easy-to-read binary dashboard of where the current price is relative to key dynamic supports and resistances.  The concept is simple, if a dynamic s/r is currently acting as a resistance, the indicator plots a dot above the histogram in the red box.  If a dynamic s/r is acting as support, a dot is plotted in the green box below.

There are some additional features, but the dot graphs are king. 

_______________________________________________________________________________________________________________
KEY:
_______________________________________________________________________________________________________________

Currently the dynamic s/r's being used in the dot plots are:

Ichimoku Cloud:
Tenkan (blue)
Kijun (pink)
Senkou A (red)
Senkou B (green)

ZLEMA (Zero Lag Exponential Moving Average)
99 ZLEMA (lavender)
200 ZLEMA (salmon)

You'll see a dashed line through the middle of the resistances section (red) and supports section (green).  Cloud indicators are plotted above the dashed line, and ZLEMA's are below.

_______________________________________________________________________________________________________________
How it Works - Visual
_______________________________________________________________________________________________________________

As stated in the intro - if a dynamic s/r is currently above the current price and acting as a resistance, the indicator plots a dot above the histogram in the red box.  If a dynamic s/r is acting as support, a dot is plotted in the green box below.  Additionally, there is an optional histogram (default is on) that will further visualize this relationship.  The histogram is a simple summation of the resistances above and the supports below.

Here's a visual to assist with what that means.  This chart includes all of those dynamic s/r's in the dynamic dot dashboard (the on-chart parts are individually added, not part of this tool).

[image]https://www.tradingview.com/x/TYQ6jknh/[/image]

You can see that as a dynamic support is lost, the corresponding dot is moved from the supports section at the bottom (green), to the resistances section at the top (red).  The opposite being true as resistances are being overtaken (broken resistances are moved to the support section (red)).  You can see that the raw chart is just... a mess.  Which kinda of accentuates one of the key goals of this indicator:  to get all that dynamic support info without a mess of a chart like that.

_______________________________________________________________________________________________________________
 How To Use It
_______________________________________________________________________________________________________________

There are a lot of ways to use this information, but the most notable of which is to detect shifts in the market cycle.

[image]https://www.tradingview.com/x/LjQVHsvB/[/image]

For this example, take a look at the dynamic s/r dots in the resistances category (red background).  You can see clearly that there are distinctive blocks of high density dots that have clear beginnings and ends.  When we transition from a high density of dots to none in resistances, that means we are flipping them as support and entering a bull cycle.  On the other hand, when we go from low density of dots as resistances to high density, we're pivoting to a bear cycle.  Easy as that, you can quickly detect when market cycles are beginning or ending. 

Alternatively, you can add your preferred linear SR's, fibs, etc. to the chart and quickly glance at the dashboard to gauge how dynamic SR's may be contributing to the risk of your trade.

_______________________________________________________________________________________________________________
Who It's For
_______________________________________________________________________________________________________________

New traders:  by looking at dot density alone, you can use Dot Dynamics to spot transitionary phases in market cycles.
Experienced traders:  keep your charts clean and the information easy to digest.
Developers:  I created this originally as a starting point for more complex algos I'm working on.  One algo is reading this dot dashboard and taking a position size relative to the s/r's above and below.  Another cloud algo is using the results as inputs to spot good setups.

Colored Bars

There is an option (off by default, shown in the headline image above) to fill the bar colors based on how many dynamic s/r's are above or below the current price.  This can make things easier for some users, confusing for others.  I defaulted them to off as I don't want colors to confuse the primary value proposition of the indicators, which is the dot heat map.  You can turn on colored bars in the settings.

One thing to note with the colored bars:  they plot the color purely by the dot densities.  Random spikes in the gradient colors (i.e. red to lime or green) can be a useful thing to notice, as they commonly occur at places where the price is bouncing between dynamic s/r's and can indicate a paradigm shift in the market cycle.

_______________________________________________________________________________________________________________
Timeframes and Assets
_______________________________________________________________________________________________________________

This can be used effectively on all assets (stocks, crypto, forex, etc) and all time frames.  As always with any indicator, the higher TF's are generally respected more than lower TF's.

Thanks for checking it out!  I've been trading crypto for years and am just now beginning to publish my ideas, secret-sauce scripts and handy tools (like this one). If you enjoyed this indicator and would like to see more, a like and a follow is greatly appreciated 😁.

---

## Source Code

````pine
//@version=4

// Created by Stanley Bostich



study("Dot Dynamics", overlay=false)

// **************** USER INPUTS ****************

visualComment = input(false, title='----------------- Visual Settings -----------------')
showHistogram = input(true, title="Show Histogram?")
showColoredBars = input(false, title="Show Colored Bars?")
showDots = input(true, title="Show Dots?")

useDarkMode = input(true, title="Use Dark Mode? (bright colors)")
histogramLineWidth = input(2, title="Histogram Line Width")

cloudComment = input(false, title='----------------- Cloud Settings -----------------')
useCloud = input(true, title="use Ichimoku Cloud?")
conversionPeriods = input(9, minval=1, title="Conversion Line Periods")
basePeriods = input(26, minval=1, title="Base Line Periods")
laggingSpan2Periods = input(52, minval=1, title="Lagging Span 2 Periods")
displacement = input(26, minval=1, title="Displacement")

EMAComment = input(false, title='----------------- EMA Settings -----------------')
EMAchoice = input(title="Moving Average Type", defval="ZLEMA", options=["ZLEMA", "EMA", "SMA", "HULL"])

ma1 = input(99, title="MA 1 length (lavender)")
ma2 = input(200, title="MA 2 length (salmon)")


// *********** CLOUD ****************



donchian(len) =>
    avg(lowest(len), highest(len))

t = donchian(conversionPeriods)
k = donchian(basePeriods)
l1 = avg(t, k)
l2 = donchian(laggingSpan2Periods)


aboveT = close > t ? 1 : 0
aboveK = close > k  ? 1 : 0
aboveL1 = close >= l1[displacement - 1]  ? 1 : 0
aboveL2 = open >= l2[displacement - 1]  ? 1 : 0


tCol = useDarkMode ? color.aqua : #2600ff
kCol = useDarkMode ? #ff96f8 : #ff00e1
plotshape(useCloud and showDots ? aboveT == 1 ? -22 : 30 : na, style=shape.circle, location=location.absolute, color=tCol)
plotshape(useCloud and showDots ? aboveK == 1 ? -23 : 29 : na, style=shape.circle, location=location.absolute, color=kCol)


plotshape(useCloud and showDots ? aboveL1 == 1 ? -24 : 28 : na, style=shape.circle, location=location.absolute, offset=displacement-1, color=color.red)
plotshape(useCloud and showDots ? aboveL2 == 1 ? -25 : 27 : na, style=shape.circle, location=location.absolute, color=color.green)



// ************** ZLEMA 1 **************
// Credit:  ZLEMA function by LazyBear


ema1_1=ema(close, ma1)
ema2_1=ema(ema1_1, ma1)
d_1=ema1_1-ema2_1
zlema_1=ema1_1+d_1

aboveZLEMA1 = close > zlema_1  ? 1 : 0

ma1Col = useDarkMode ? #969bff : #8700bd // lavendar/purple
plotshape(EMAchoice == "ZLEMA" and showDots ? aboveZLEMA1 == 1 ? -29 : 23 : na, style=shape.circle, location=location.absolute, color=ma1Col) 



// ************** ZLEMA 2 **************

ema1_2=ema(close, ma2)
ema2_2=ema(ema1_2, ma2)
d2=ema1_2-ema2_2
zlema_2=ema1_2+d2

aboveZLEMA2 = close > zlema_2 ? 1 : 0
belowZLEMA2 = close < zlema_2 ? 1 : 0

ma2Col = useDarkMode ? #ff9696 : #ff00f2 // salmon/pink

plotshape(EMAchoice == "ZLEMA" and showDots ? aboveZLEMA2 ? -30 : 22 : na, style=shape.circle, location=location.absolute, color=ma2Col) 


// ************** EMA 1 and 2**************

EMAout1 = ema(close, ma1)
EMAout2 = ema(close, ma2)

aboveEMA1 = close > EMAout1  ? 1 : 0
aboveEMA2 = close > EMAout2  ? 1 : 0


plotshape(EMAchoice == "EMA" and showDots ? aboveEMA1 == 1 ? -29 : 23 : na, style=shape.circle, location=location.absolute, color=ma1Col) 
plotshape(EMAchoice == "EMA" and showDots ? aboveEMA2 ? -30 : 22 : na, style=shape.circle, location=location.absolute, color=ma2Col)


// ************** MA 1 and 2**************

SMAout1 = sma(close, ma1)
SMAout2 = sma(close, ma2)
aboveSMA1 = close > SMAout1  ? 1 : 0
aboveSMA2 = close > SMAout2  ? 1 : 0

plotshape(EMAchoice == "SMA" and showDots ? aboveSMA1 == 1 ? -29 : 23 : na, style=shape.circle, location=location.absolute, color=ma1Col)
plotshape(EMAchoice == "SMA" and showDots ? aboveSMA2 ? -30 : 22 : na, style=shape.circle, location=location.absolute, color=ma2Col)


// ************** HULL 1 and 2**************

hullma1 = wma(2*wma(open, ma1/2)-wma(open, ma1), round(sqrt(ma1)))
hullma2 = wma(2*wma(open, ma2/2)-wma(open, ma2), round(sqrt(ma2)))


aboveHMA1 = close > hullma1  ? 1 : 0
aboveHMA2 = close > hullma2  ? 1 : 0

plotshape(EMAchoice == "HULL" and showDots ? aboveHMA1 == 1 ? -29 : 23 : na, style=shape.circle, location=location.absolute, color=ma1Col)
plotshape(EMAchoice == "HULL" and showDots ? aboveHMA2 ? -30 : 22 : na, style=shape.circle, location=location.absolute, color=ma2Col)



// ************** PLOTS **************

// default colors
green1 = #02bf02
green2 = #009100
green3 = #006300
green4 = #013b01

red1 = #de0000
red2 = #B20000
red3 = #8C0000
red4 = #630000
red5 = #3b0000

yellow1 = #fffb00
yellow2 = #c9c602
yellowToGreen1 = #d0ff00
yellowToGreen2 = #aeff00
yellowToGreen3 = #8ee600
yellowToRed1 = #ffd500
yellowToRed2 = #ffa200
yellowToRed3 = #f76700

// dark mode colors
teal1 = #00ffdd
teal2 = #00ffb3
teal3 = #00ff84
teal4 = #00ff37
darkTeal = #009682

tealToOrange1 = #00ff3c
tealToOrange2 = #15ff00
tealToOrange3 = #91ff00
tealToOrange4 = #ffea00
tealToOrange5 = #ffd500


orange1 = #ffea00
orange2 = #ffd000
orange3 = #ffaa00
orange4 = #ff6505
darkOrange = #b56700

// support/resistance regions

hColResistances = useDarkMode ? orange2 : red1
hColSupports = useDarkMode ? teal2 : green1

h1 = hline(showDots ? -20 : na, color=hColSupports, linestyle=hline.style_solid)
h2 = hline(showDots ? -32 : na, color=hColSupports, linestyle=hline.style_solid)
h3 = hline(showDots ? -27 : na, color=hColSupports, linestyle=hline.style_dashed)

h4 = hline(showDots ? 32 : na, color=hColResistances, linestyle=hline.style_solid) 
h5 = hline(showDots ? 20 : na, color=hColResistances, linestyle=hline.style_solid)
h6 = hline(showDots ? 25 : na, color=hColResistances, linestyle=hline.style_dashed)

fillColResistances = useDarkMode ? darkOrange : color.red
fillColSupports = useDarkMode ? darkTeal : color.green
fill(h1, h2, color=fillColSupports)
fill(h4, h5, color=fillColResistances)

// histogram
activeIndicators = (useCloud ? 0 : 4)

aboveCount = (useCloud ? aboveT + aboveK + aboveL1 + aboveL2 : 0)  +  aboveZLEMA1 + aboveZLEMA2
belowCount = (useCloud ? 6 : 2) - aboveCount


aCol = belowCount >= 6 ? green4: belowCount >= 4 ? green3 : belowCount >= 2 ? green2 : green1
bCol = belowCount >= 6 ? red1: belowCount >= 4 ? red2 : belowCount >= 2 ? red3 : red4

aColDM = belowCount >= 6 ? teal4: belowCount >= 4 ? teal3 : belowCount >= 2 ? teal2 : teal1
bColDM = belowCount >= 6 ? orange1: belowCount >= 4 ? orange2 : belowCount >= 2 ? orange3 : orange4

aColFinal = useDarkMode ? aColDM : aCol
bColFinal = useDarkMode ? bColDM : bCol
plot( showHistogram ? aboveCount * 2 : na, color=aColFinal, style=plot.style_histogram, linewidth=histogramLineWidth)
plot( showHistogram ? -belowCount * 2 : na, color=bColFinal, style=plot.style_histogram, linewidth=histogramLineWidth)

// colored bars
barCol = aboveCount >= 6 ? green1 : aboveCount == 5 ? green3 : aboveCount == 4 ? yellowToGreen2 : aboveCount == 4 ? yellow1 : aboveCount == 3 ? yellowToRed2 : aboveCount == 2 ? yellowToRed3 : aboveCount == 1 ? red1 : red3
barColDM = aboveCount >= 6 ? teal1 : aboveCount == 5 ? teal3 : aboveCount == 4 ? tealToOrange1 : aboveCount == 4 ? tealToOrange3 : aboveCount == 3 ? tealToOrange4 : aboveCount == 2 ? tealToOrange5 : aboveCount == 1 ? orange3 : orange4

barColFinal = useDarkMode ? barColDM : barCol
barcolor(color=showColoredBars ? barColFinal : na)
````
