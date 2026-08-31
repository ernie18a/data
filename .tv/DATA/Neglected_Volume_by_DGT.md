<!-- tradingview-pine-id: PUB;FvJqumctetdFjTc3kvAdgJXrU6fkzHPt -->
<!-- tradingviewscripts-format: 1 -->
# Neglected Volume by DGT

Source: https://www.tradingview.com/script/PpjPs450-Neglected-Volume-by-DGT/

## Description

Volume is one piece of information that is often neglected, however, learning to interpret volume brings many advantages and could be of tremendous help when it comes to analyzing the markets. In addition to technicians, fundamental investors also take notice of the numbers of shares traded for a given security.

What is Volume?
The volume represents all the recorded trades for a security that occurs in a given time interval. It is a measurement of the participation, enthusiasm, and interest in a given security. Think of volume as the force that drives the market. Volume substantiates, energizes, and empowers price. When volume increases, it confirms price direction; when volume decreases, it contradicts price direction. 
In theory, increases in volume generally precede significant price movements. However, If the price is rising in an uptrend but the volume is reducing or unchanged, it may show that there’s little interest in the security, and the price may reverse. 
A high volume usually indicates more interest in the security and the presence of institutional traders. However, a rapidly rising price in an uptrend accompanied by a huge volume may be a sign of exhaustion.
Traders usually look for breaks of support and resistance to enter positions. When security break critical levels without volume, you should consider the breakout suspect and prime for a reversal off the highs/lows
Volume spikes are often the result of news-driven events. Volume spike will often lead to sharp reversals since the moves are unsustainable due to the imbalance of supply and demand

note: there’s no centralized exchange where trades are recorded, so the volume data represents what happens at a particular exchange only

In most charting platforms, the volume indicator is presented as color-coded bars, green if the security closes up and red if the security closed lower, where the height of the bars show the amount of the recorded trades

Within this study, Relative Volume, Volume Weighted Bars and Volume Moving Average are presented, where Relative Volume relates current trading volume to past trading volume over long period, Volume Weighted Bars presents price bars colored based on short period past trading volume average, and Volume Moving Average is average of volume over shot period 

Relative Volume is presented as color-coded bars similar to regular Volume indicator but uses four color codes instead two. Notable increases of volume are presented in green and red while average values with back and gray, hence adding ability to emphasis notable increases in the volume. It is kind of a like a radar for how "in-play" a security is. Users are allowed to change the threshold, default value is set to Fibonacci golden ration standard deviation away from its moving average.

Volume Weighted Bars, a study of Kıvanç Özbilgiç, aims to present if price movements are supported by Volume. Volume Weighted Bars are calculated based on shot period volume moving average which will reflect more recent changes in volume. Price actions with high volume will be displayed with darker colors, average volume values will remain as they are and low volume values will be indicated with lighter colors.

Volume Moving Average, Is short period volume moving average, aims to display visually the volume changes. Please not that Relative Volume bars are calculated based on standard deviation of long volume moving average.  

https://www.tradingview.com/x/gEu4mK8G/

What Else?

Apart from the volume itself, your ability to assess what volume is telling you in conjunction with price action can be a key factor in your ability to turn a profit in the market. It makes little sense to analyze the volume alone. To correctly interpret the volume data, it shall be seen in the light of what the price is doing. there are a lot of other indicators that are based on the volume data as well as price action. Analysing those volume indicators has always helped traders and investors to better understand what is happening in the market. 

Here are the ones adapted with this study. Some of them used as a source for our aim, some adapted as they are with slight changes to fit visually to this study and please note that the numerical presentation may differ from their regular use

•	On Balance Volume
•	Divergence Indicator
•	Correlation Coefficient 
•	Chaikin Money Flow 

Shortly; 
On Balance Volume
The On Balance Volume indicator,  is a technical analysis indicator that relates volume flow to changes in a security’s price. It uses a cumulative total of positive and negative trading volume to predict the direction of price. The OBV is a volume-based momentum oscillator, so it is a leading indicator — it changes direction before the price

Granville, creator of OBV, proposed the theory that changes in volume precede price movements in a measurable way. He believed that volume was the main force behind major market moves and thought of OBV’s prediction of price changes as a compressed spring that expands rapidly when released.

It is believed that the OBV shows the interactions between the institutional and retail traders in the market

If the price makes a new high, the OBV should also make a new high. If the OBV makes a lower high when the price makes a higher high, there’s a classical bearish divergence — indicating that only the retail traders are buying. Another type of bearish divergence occurs when the price remains relatively quiet and fails to make a higher high but the OBV soars higher than the previous high — indicating that the institutional traders are accumulating short positions. On the other hand, if the price makes a lower low and the OBV makes a higher low, there is a classical bullish divergence, showing that the institutional traders don’t believe in that move

With this study, Momentum and Acceleration (optional) of OBV is calculated  and presented, where momentum is most commonly referred to as a rate and measures the acceleration of the price and/or volume of a security. It is also referred to as a technical analysis indicator and oscillator that is able to determine market trends. 
Additionally, smoothing functionality with Least Squares Method is added 
https://www.tradingview.com/x/ALZFFrOT/
https://www.tradingview.com/x/fRXXpmZe/

Divergences especially, should always be noted as a possible reversal in the current trend, so the divergence indicator is adapted with this study where the Momentum of OBV is assumed as Oscillator with similar usages as to RSI. Divergence is most often used to track and analyze the momentum in an asset’s price and the odds of a price reversal within the current trend. The divergence indicator warns traders and technical analysts of changes in a price/volume trend, oftentimes that it is weakening or changing direction.
https://www.tradingview.com/x/BSxcBSQy/

Correlation Coefficient
The correlation coefficient is a statistical measure of the strength of the relationship between the relative movements of two variables.  A correlation of -1.0 shows a perfect negative correlation, while a correlation of 1.0 shows a perfect positive correlation. A correlation of 0.0 shows no linear relationship between the movement of the two variables. In other words, the closer the Correlation Coefficient is to 1.0, indicates the instruments will move up and down together as it is mostly expected with volume and price. So the Correlation Coefficient Indicator aims to display when the price and volume (on balance volume) is in correlation and when not. With this study blue represent positive correlation while orange negative correlation. The strength of the correlation is determined by the width of the bands, to emphasis the effect horizontal lines are drawn with values set to 0.5 and -0.5. the values above 0.5 (or below -0.5) shows stronger correlation.  

https://www.tradingview.com/x/CgtLve9u/

Chaikin Money Flow, provide optionally as a companion indicator 
The Chaikin money flow indicator (CMF) is a volume indicator that measures the money flow volume over a chosen period. The money flow volume is a measure of the volume and where the price closed relative to the trading session’s range. It comes from the idea that buying pressure is indicated by a rising volume and recurrent closes in the upper part of the session’s price range while selling pressure is demonstrated by an increasing volume and repeated closes in the lower part of the price range.
Both buying and selling pressures are accompanied by an increase in volume, but the location of the closing prices are in accordance with the direction of price

https://www.tradingview.com/x/2M9OyZRp/

Special thanks to @InvestCHK and @hjsjshs, who have enormously contributed while preparing this study 

related studies:
https://www.tradingview.com/script/oKzb0fyY-Stoch-X-an-Indicator-of-Indicators-by-DGT/
https://www.tradingview.com/script/Gq9I627Q-MACD-X-More-Than-MACD-by-DGT/
https://www.tradingview.com/script/JQrHr1XY-Relative-Strength-of-Volume-Indicators-by-DGT/
https://www.tradingview.com/script/2P1YnsF5-Earthquake-Effect-by-DGT/
https://www.tradingview.com/script/BmXmwmnE-Momentum-Acceleration-by-DGT/

Disclaimer:
Trading success is all about following your trading strategy and the indicators should fit within your trading strategy, and not to be traded upon solely

The script is for informational and educational purposes only. Use of the script does not constitute professional and/or financial advice. You alone have the sole responsibility of evaluating the script output and risks associated with the use of the script. In exchange for using the script, you agree not to hold dgtrd TradingView user liable for any possible claim for damages arising from any decision you make based on use of the script

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
//# *
//# * Study       : Neglected Volume
//# *                - Relative Volume
//# *                - On Balance Volume Momentum, Correlation with Price and Divergence
//# *
//# * Author      : © dgtrd
//# *
//# * Revision History
//# *  Release    : Sep 14, 2020 : Initial Release
//# *  Update     : Sep 22, 2020 : Alert for Consecutive Notable Volume Changes
//# *  Update     : Jul 26, 2022 : Updated to Pine Script v5
//# *
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

indicator('Neglected Volume by DGT', shorttitle = 'ʀVOL∿ ☼☾')

display = display.all - display.status_line

length = input(13, 'Volume Analysis Length', display = display, tooltip = 'Core lookback period used to evaluate relative volume strength and OBV momentum behavior.')
thresh = input.int(11, 'Relative Volume Threshold', minval = 0, display = display, tooltip = 'Defines the minimum relative volume strength required for a bar to be considered significant.')

count = input.int(3, 'Alert: Consecutive High-Volume Bars', minval = 1, display = display, tooltip = 'Number of consecutive bars exceeding the Relative Volume threshold required to trigger a trading opportunity alert.')

group_obv = 'OBV Momentum Analysis'
obvMom = input(true, 'OBV Momentum Oscillator', group = group_obv, tooltip = 'Displays the momentum of On Balance Volume.\n\nThis reveals acceleration or weakening of buying and selling pressure behind price movement.')
aBand = input(true, 'Momentum Acceleration Band', group = group_obv, tooltip = 'Adds a dynamic envelope around OBV Momentum to visualize acceleration or deceleration in volume momentum.\n\nExpanding bands indicate increasing momentum.')
smooth = input.int(5, '  Smoothing', minval = 2, group = group_obv, display = display, inline = 'in', tooltip = 'Applies Least Squares Moving Average smoothing to the OBV Momentum oscillator.\n\nHigher values reduce noise but may delay signals.')

hPVCB = input(true, 'Price & OBV Correlation', group = 'Price vs OBV Correlation', tooltip = 'Displays the rolling correlation between price and OBV.')

group_other = 'Additional Tools'
compIn = input(false, 'Chaikin Money Flow', group = group_other, tooltip = 'Overlays Chaikin Money Flow to measure cumulative buying and selling pressure using both price location and volume.')
dVWCB = input(true, 'Volume-Weighted Candle Coloring', group = group_other, tooltip = 'Colors candles based on relative volume intensity.')

group_div = 'OBV Momentum Divergence'
lbR = input(5, 'Pivot Lookback Right', group = group_div, display = display)
lbL = input(5, 'Pivot Lookback Left', group = group_div, display = display)
rUpper = input(60, 'Max of Lookback Range', group = group_div, display = display)
rLower = input(5, 'Min of Lookback Range', group = group_div, display = display)
pBull = input(false, 'Plot Bullish', group = group_div)
pHBull = input(false, 'Plot Hidden Bullish', group = group_div)
pBear = input(false, 'Plot Bearish', group = group_div)
pHBear = input(false, 'Plot Hidden Bearish', group = group_div)

//------------------------------------------------------------------------------
// Calculations 
nzVolume = nz(volume)
source = barstate.isconfirmed ? close : close[1]
vsource = bool(nzVolume) ? barstate.isconfirmed ? ta.obv : ta.obv[1] : na
corr = ta.correlation(source, vsource, length)
volAvgS = ta.sma(nzVolume, length)
volAvgL = ta.sma(nzVolume, length * 5)
phi = 1.618034
volDev = (volAvgL + phi * ta.stdev(volAvgL, length * 5)) / volAvgL * thresh / 100
volRel = nzVolume / volAvgL
momentum = ta.change(vsource, length) / length
momOsc = ta.linreg(momentum / volAvgS * phi, smooth, 0)

accel = if aBand
    ta.change(momentum, length) / length / volAvgS * phi

// Chaikin Money Flow, build-in 
cmf = if compIn and bool(nzVolume)
    ad = close == high and close == low or high == low ? 0 : (2 * close - low - high) / (high - low) * nzVolume
    math.sum(ad, length) / math.sum(nzVolume, length) * phi

// Volume Based Colored Bars by [KıvançÖZBİLGİÇ], slightly modified
vbcbColor = if close < open
    if nzVolume > volAvgS * phi
        #910000
    else if nzVolume >= volAvgS * .618034 and nzVolume <= volAvgS * phi
        color.red
    else
        color.orange
else
    if nzVolume > volAvgS * phi
        #006400
    else if nzVolume >= volAvgS * .618034 and nzVolume <= volAvgS * phi
        color.green
    else
        #7FFFD4

bColor = color.new(color.black, 25)
gColor = color.new(color.gray, 50)

// Alerts
consecutiveUp = 0
consecutiveDn = 0
for i = 0 to count - 1 by 1
    if close[i] > open[i]
        consecutiveUp := consecutiveUp + (volRel[i] * .145898 > volDev[i] ? 1 : 0)
        consecutiveUp
    else if close[i] < open[i]
        consecutiveDn := consecutiveDn + (volRel[i] * .145898 > volDev[i] ? 1 : 0)
        consecutiveDn

//------------------------------------------------------------------------------
// Plotting

hline(hPVCB ? 1 : na,  'Strong Positive Correlation')
hline(hPVCB ? .5 : na, 'Moderate Positive Correlation')
hline(hPVCB ? -.5 : na,'Moderate Negative Correlation')
hline(hPVCB ? -1 : na, 'Strong Negative Correlation')

a1 = plot(hPVCB ? corr : na, display = display.none, title = 'Price–OBV Correlation', editable = false)
a2 = plot(hPVCB ? -corr : na, display = display.none, title = 'Correlation Mirror', editable = false)
fill(a1, a2, color = corr > 0 ? color.new(color.aqua, 89) : color.new(color.orange, 89), title = 'Correlation Strength Zone')

plot(volRel * .145898, color = open > close ? volRel * .145898 > volDev ? #910000 : bColor : volRel * .145898 > volDev ? #006400 : gColor, style = plot.style_columns, title = 'Relative Volume Activity', display = display)
plot(ta.sma(volRel, length) * .145898, color = color.new(color.teal, 0), title = 'Relative Volume Average', display = display)
plot(aBand ? na : obvMom ? momOsc : na, color = color.new(color.orange, 0), title = 'OBV Momentum Oscillator', linewidth = 2, display = display)

p1 = plot(aBand ? obvMom ? momOsc - accel : na : na, color = momOsc > 0 ? #006400 : #910000, title = 'Momentum Lower Acceleration', display = display)
p2 = plot(aBand ? obvMom ? momOsc + accel : na : na, color = momOsc > 0 ? #006400 : #910000, title = 'Momentum Upper Acceleration', display = display)
fill(p1, p2, color = color.new(color.orange, 25), title = 'Momentum Acceleration Band')

plot(cmf, color = color.new(#459915, 0), title = 'Chaikin Money Flow', display = display)
barcolor(dVWCB and bool(nzVolume) ? vbcbColor : na, title = 'Volume-Weighted Candle Coloring')

alertcondition(consecutiveUp > count - 1 or consecutiveDn > count - 1, title = 'Relative Volume Expansion', message = 'Relative Volume Expansion Detected\n{{exchange}}:{{ticker}}->\nPrice = {{close}},\nTime = {{time}}')

//------------------------------------------------------------------------------
// Divergence Indicator - source build-in scripts

bearColor = color.red
bullColor = color.teal
hBullColor = color.new(color.teal, 80)
hBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

//osc = rsi(src, len)
// default RSI replaced with Momentum of OBV
osc = momOsc

plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rLower <= bars and bars <= rUpper

//------------------------------------------------------------------------------
// Regular Bullish

// Osc: Higher Low
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])

// Price: Lower Low
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)

bullCond = pBull and priceLL and oscHL and plFound

plot(plFound ? osc[lbR] : na, offset = -lbR, title = 'Regular Bullish', linewidth = 2, color = bullCond ? bullColor : noneColor, display = display)
plotshape(bullCond ? osc[lbR] : na, offset = -lbR, title = 'Regular Bullish Label', text = ' Bull ', style = shape.labelup, location = location.absolute, color = color.new(bullColor, 0), textcolor = color.new(textColor, 0), display = display)

//------------------------------------------------------------------------------
// Hidden Bullish

// Osc: Lower Low
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])

// Price: Higher Low
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)

hiddenBullCond = pHBull and priceHL and oscLL and plFound

plot(plFound ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bullish', linewidth = 2, color = hiddenBullCond ? hBullColor : noneColor, display = display)
plotshape(hiddenBullCond ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bullish Label', text = ' H Bull ', style = shape.labelup, location = location.absolute, color = color.new(bullColor, 0), textcolor = color.new(textColor, 0), display = display)

//------------------------------------------------------------------------------
// Regular Bearish

// Osc: Lower High
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])

// Price: Higher High
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)

bearCond = pBear and priceHH and oscLH and phFound

plot(phFound ? osc[lbR] : na, offset = -lbR, title = 'Regular Bearish', linewidth = 2, color = bearCond ? bearColor : noneColor, display = display)
plotshape(bearCond ? osc[lbR] : na, offset = -lbR, title = 'Regular Bearish Label', text = ' Bear ', style = shape.labeldown, location = location.absolute, color = color.new(bearColor, 0), textcolor = color.new(textColor, 0), display = display)

//------------------------------------------------------------------------------
// Hidden Bearish

// Osc: Higher High
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])

// Price: Lower High
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)

hiddenBearCond = pHBear and priceLH and oscHH and phFound

plot(phFound ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bearish', linewidth = 2, color = hiddenBearCond ? hBearColor : noneColor, display = display)
plotshape(hiddenBearCond ? osc[lbR] : na, offset = -lbR, title = 'Hidden Bearish Label', text = ' H Bear ', style = shape.labeldown, location = location.absolute, color = color.new(bearColor, 0), textcolor = color.new(textColor, 0), display = display)

//------------------------------------------------------------------------------

var table logo = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(logo, 0, 0, '☼☾  ', text_size = size.normal, text_color = color.teal, tooltip = 'SoleMare Analytics')
````
