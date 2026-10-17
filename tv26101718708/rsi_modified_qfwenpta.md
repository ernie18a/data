# RSI Modified

- url: https://www.tradingview.com/script/QfweNPTa-RSI-Modified/
- type: indicator
- pine_id: PUB;6bb48d621f174b25930ad70b76ed3ddf
- version: 3.0

## Description

Relative Strength Index (RSI) Modified
Indicator Type: Standalone

Chart Type: Interactive Charts only

The RSI is another J. Welles Wilder, Jr. trading tool. The main purpose of the study is to measure the market's strength and weakness. A high RSI, above 70, suggests an overbought or weakening bull market. Conversely, a low RSI, below 30, implies an oversold market or dying bear market.

While you can use the RSI as an overbought and oversold indicator, it works best when a failure swing occurs between the RSI and market prices. For example, the market makes new highs after a bull market setback, but the RSI fails to exceed its previous highs.

Another use of the RSI is divergence. Market prices continue to move higher/lower while the RSI fails to move higher/lower during the same time period. Divergence may occur in a few trading intervals, but true divergence usually requires a lengthy time frame, perhaps as much as 20 to 60 trading intervals.

Selling when the RSI is above 70 or buying when the RSI is below 30 can be an expensive trading system. A move to those levels is a signal that market conditions are ripe for a market top or bottom. It does not indicate a top or a bottom. A failure swing or divergence accompanies your best trading signals.

The RSI exhibits chart formations as well. Common bar chart formations readily appear on the RSI study. They are trendlines, pennants, flags, head and shoulders, double tops and bottoms, and triangles. In addition, the study can highlight support and resistance zones.

Parameters:

Period (14) - the number of bars, or period, used to calculate the study.
Range (100) - the distance between the upper and lower threshold lines.
Computation


The RSI computations are not difficult, but they are tedious. You first calculate the difference between the current closing price and the previous closing price. The general formula is:

DIFt = Closet - Closet-1

If that difference is a positive value, it is an up period - the current close is higher than previous close. If the difference is negative, it is a down period - the current close is below the previous close. The indicator maintains the DIF value for a series of UP and DOWN days. The DOWN value is always a positive number for all computations. It is the absolute value of a negative DIF.

The worksheet below shows the calculations needed to create a 9 period RSI.

Day	Current Close	Previous Close	Dif	Up	Down
1	7450	7430	+20	20	0
2	7460	7450	+10	10	0
3	7470	7460	+10	10	0
4	7480	7470	+10	10	0
5	7485	7480	+5	5	0
6	7490	7485	+5	5	0
7	7480	7490	-10	0	10
8	7470	7480	-10	0	10
9	7455	7470	-15	0	15
 	 	 	Totals	60	35
You now compute the up and down averages, which are calculated as follows:

Ut = (UP1 +... + UPi) / n
Dt = (DOWN1 +... + DOWNn) / n

Ut is the up average for the current period.
Dt is the down average for the current period.
UPn is the UP value for the nth period.
DOWNn is the DOWN value for the nth period.
n is the number of periods for the RSI.
Now, use the values from the worksheet. The up average is:

U = 60 / 9
= 6.67
and the down average is:
D = 35 / 9
= 3.89
The general formula for the RSI is:
RSIt = ( UT / (UT + DT) ) * 100
If you use the above values and place them in the formula, it appears as follows:
RSI = ( 6.67 / ( 6.67 + 3.89 )) * 100
= 63.16
Assume the market continues the downward trend. The next DIF value is -15, which sets the UP value to 0, zero, and the DOWN value to 15. Calculate the next up and down average by using Wilder's accumulative moving average technique. The formulae are:
UT = ( (UT-1 * (n-1) ) + UPt) / n
= ( (6.67 * (9 -1) ) + 0) / 9
= 5.93

DT = ( ( DT-1 * (n-1) ) + DOWNt) / n
= ( ( 3.89 * (9 - 1) ) + 15) / 9
= 5.12
The value for the new RSI equals the following:
RSI = ( (5.93) / (5.93 + 5.12)) * 100
= 53.67
The software continues these calculations for the entire data series.

## Source Code

````pine
//@version=6
indicator("Barchart RSI Modified", shorttitle = "RSI Mod", overlay = false, precision = 2, format=format.price, timeframe="", timeframe_gaps=false)



period = input.int(14, "Period", minval = 1)
rsiRange = input.float(100.0, "Range", minval = 1.0, maxval = 100.0)
maPeriod = input.int(9, "RSI MA Period", minval = 1)
overboughtLevel = input.float(70.0, "Overbought", minval = 0.0, maxval = 100.0)
oversoldLevel = input.float(30.0, "Oversold", minval = 0.0, maxval = 100.0)

diff = close - close[1]
up = math.max(diff, 0.0)
down = math.max(-diff, 0.0)

avgUp = ta.sma(up, period)
avgDown = ta.sma(down, period)
avgTotal = avgUp + avgDown
rsi = avgTotal == 0.0 ? 50.0 : avgUp / avgTotal * 100.0
rsiMa = ta.sma(rsi, maPeriod)

upperRangeValue = 50.0 + rsiRange / 2.0
lowerRangeValue = 50.0 - rsiRange / 2.0
rsiColor = rsi >= overboughtLevel ? color.rgb(38, 86, 255) : rsi <= oversoldLevel ? color.rgb(255, 65, 54) : color.rgb(0, 176, 91)

hline(upperRangeValue, "Upper Range", color = color.new(color.gray, 70))
hline(overboughtLevel, "Overbought", color = color.new(color.gray, 25))
hline(50, "Midpoint", color = color.new(color.gray, 45), linestyle = hline.style_dotted)
hline(oversoldLevel, "Oversold", color = color.new(color.gray, 25))
hline(lowerRangeValue, "Lower Range", color = color.new(color.gray, 70))

overboughtFillPlot = plot(rsi > overboughtLevel ? rsi : na, "Overbought Fill Source", color = na, editable = false, display = display.none)
oversoldFillPlot = plot(rsi < oversoldLevel ? rsi : na, "Oversold Fill Source", color = na, editable = false, display = display.none)
overboughtLevelPlot = plot(overboughtLevel, "Overbought Fill Level", color = na, editable = false, display = display.none)
oversoldLevelPlot = plot(oversoldLevel, "Oversold Fill Level", color = na, editable = false, display = display.none)

fill(overboughtFillPlot, overboughtLevelPlot, color = color.new(color.rgb(38, 86, 255), 70), title = "Overbought Solid Fill")
fill(oversoldFillPlot, oversoldLevelPlot, color = color.new(color.rgb(255, 65, 54), 70), title = "Oversold Solid Fill")

rsiPlot = plot(rsi, "RSI", color = rsiColor, linewidth = 2)
plot(rsiMa, "RSI MA", color = color.rgb(255, 137, 75), linewidth = 1)
````
