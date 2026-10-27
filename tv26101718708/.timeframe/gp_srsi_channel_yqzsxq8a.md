# GP - SRSI Channel

- url: https://www.tradingview.com/script/yQzsxq8A/
- type: indicator
- pine_id: PUB;db695e5e197943409566529f669ab2e0
- version: 1.0

## Description

[b]GP - SRSI Channel Indicator[/b]

The GP - SRSI Channel is a channel indicator derived from the Stochastic RSI (SRSI) oscillator. It combines SRSI data from multiple timeframes to analyze minimum, maximum, and closing values, forming a channel based on these calculations. The goal is to identify overbought and oversold zones with color coding and highlight potential trading opportunities by indicating trend reversal points.

[b]How It Works[/b]
[i]SRSI Calculation:[/i] The indicator calculates the Stochastic RSI values using open, high, low, and close prices from the selected timeframes.
[i]Channel Creation: [/i]Minimum and maximum values derived from these calculations are combined across multiple timeframes. The midpoint is calculated as the average of these values.
[i]Color Coding:[/i] Zones within the channel are color-coded with a gradient from red to green based on the ratios. Green zones typically indicate selling opportunities, while red zones suggest buying opportunities.
[i]Visual Elements:[/i]
[list]
[*]The channel boundaries (min/max) are displayed as lines.
[/list]
[list]
[*]Overbought/oversold regions (95-100 and 0-5) are highlighted with shaded areas.
[/list]
[list]
[*]Additional explanatory labels are placed on key levels to guide users.
[/list]

[b]How to Use[/b]
[i]Trading Strategy:[/i] This indicator can be used for both trend following and identifying reversal points. Selling opportunities can be evaluated when the channel reaches the upper green zone, while buying opportunities can be considered in the lower red zone.
[i]Timeframe Selection:[/i] Users can analyze multiple timeframes simultaneously to gain a broader perspective.
[i]Customization:[/i] RSI and Stochastic RSI parameters are adjustable, allowing users to tailor the indicator to their trading strategies.

[b]Important Note[/b]
This indicator is for informational purposes only and should not be used as a sole basis for trading decisions. Please validate the results of the indicator with your own analysis.

## Source Code

````pine

// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gokhanpirnal

//@version=5
indicator("GP - SRSI Channel", shorttitle='GP - SRSI Channel', overlay=false)

smoothK = input.int(3, "K", minval=1)
smoothD = input.int(3, "D", minval=1)
lengthRSI = input.int(14, "RSI Length", minval=1)
lengthS = input.int(14, "S Length", minval=1)

srcopen = input(open, title="RSI Source")
rsi1open = ta.rsi(srcopen, lengthRSI)
kopen = ta.sma(ta.stoch(rsi1open, rsi1open, rsi1open, lengthS), smoothK)
dopen = ta.sma(kopen, smoothD)
dsopen = (kopen + dopen)

srchigh = input(high, title="RSI Source")
rsi1high = ta.rsi(srchigh, lengthRSI)
khigh = ta.sma(ta.stoch(rsi1high, rsi1high, rsi1high, lengthS), smoothK)
dhigh = ta.sma(khigh, smoothD)
dshigh = (khigh + dhigh)

srclow = input(low, title="RSI Source")
rsi1low = ta.rsi(srclow, lengthRSI)
klow = ta.sma(ta.stoch(rsi1low, rsi1low, rsi1low, lengthS), smoothK)
dlow = ta.sma(klow, smoothD)
dslow = (klow + dlow)

srcclose = input(close, title="RSI Source")
rsi1close = ta.rsi(srcclose, lengthRSI)
kclose = ta.sma(ta.stoch(rsi1close, rsi1close, rsi1close, lengthS), smoothK)
dclose = ta.sma(kclose, smoothD)
dsclose = (kclose + dclose)


starray = array.from(dsclose[0], dsopen[0], dslow[0], dshigh[0])
starraymin = array.min(starray, 0)
starraymax = array.max(starray, 0)

time1 = input.timeframe('180', "Time 1")
time2 = input.timeframe('360', "Time 2")
time3 = input.timeframe('720', "Time 3")
time4 = input.timeframe('D', "Time 4")

a1 = request.security(syminfo.tickerid, str.tostring(time1), starraymin)
a2 = request.security(syminfo.tickerid, str.tostring(time2), starraymin)
a3 = request.security(syminfo.tickerid, str.tostring(time3), starraymin)
a4 = request.security(syminfo.tickerid, str.tostring(time4), starraymin)

b1 = request.security(syminfo.tickerid, str.tostring(time1), starraymax)
b2 = request.security(syminfo.tickerid, str.tostring(time2), starraymax)
b3 = request.security(syminfo.tickerid, str.tostring(time3), starraymax)
b4 = request.security(syminfo.tickerid, str.tostring(time4), starraymax)

c1 = request.security(syminfo.tickerid, str.tostring(time1), dsclose)
c2 = request.security(syminfo.tickerid, str.tostring(time2), dsclose)
c3 = request.security(syminfo.tickerid, str.tostring(time3), dsclose)
c4 = request.security(syminfo.tickerid, str.tostring(time4), dsclose)

totalmin = (a1 + a2 + a3 + a4)
oranmin = (100 * totalmin) / 800

colx = color.from_gradient(oranmin, 0, 100, color.rgb(255, 0, 0), color.rgb(0, 255, 0))

totalmax = (b1 + b2 + b3 + b4)
oranmax = (100 * totalmax) / 800

coly = color.from_gradient(oranmax, 0, 100, color.rgb(255, 0, 0), color.rgb(0, 255, 0))

totalcl = (c1 + c2 + c3 + c4)
oranclose = (100 * totalcl) / 800

mi = plot(oranmin, title='Min', color=colx)
ma = plot(oranmax, title='Max', color=coly)
plot(oranclose, title='Close', color=color.white)

colz = color.from_gradient((oranmax + oranmin) / 2, 0, 100, color.rgb(255, 0, 0), color.rgb(0, 255, 0))

fill(mi, ma, title="Channel color", color=colz)

h100 = hline(100, color=color.rgb(255, 255, 153), linestyle=hline.style_dotted)
h95 = hline(95, color=color.rgb(255, 255, 153, 60), linestyle=hline.style_dotted)
h5 = hline(5, color=color.rgb(255, 255, 153, 60), linestyle=hline.style_dotted)
h0 = hline(0, color=color.rgb(255, 255, 153), linestyle=hline.style_dotted)

fill(h100, h95, color=color.rgb(0, 255, 0, 80))
fill(h5, h0, color=color.rgb(255, 0, 0, 80))

var label1 = label.new(bar_index, oranmax, text="Max", style=label.style_label_left, color=color.rgb(0, 255, 0, 0), textcolor=color.black, size=size.small)
label.set_xy(label1, bar_index, oranmax)
var label2 = label.new(bar_index, oranmin, text="Min", style=label.style_label_left, color=color.rgb(255, 0, 0, 0), textcolor=color.white, size=size.small)
label.set_xy(label2, bar_index, oranmin)
var label3 = label.new(bar_index, 99, text="Green area: Sell suitable", style=label.style_label_lower_left, color=color.rgb(255, 255, 255, 0), textcolor=color.black, size=size.small)
label.set_xy(label3, bar_index, 99)
var label4 = label.new(bar_index, 1, text="Red area: Buy suitable", style=label.style_label_upper_left, color=color.rgb(255, 255, 255, 0), textcolor=color.black, size=size.small)
label.set_xy(label4, bar_index, 1)
````
