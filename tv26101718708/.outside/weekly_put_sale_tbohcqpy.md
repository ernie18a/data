# Weekly Put Sale

- url: https://www.tradingview.com/script/tbohcQpY-Weekly-Put-Sale/
- type: indicator
- pine_id: PUB;090d8b8a53914cfebb84e3dc568dac8d
- version: 2.0

## Description

[b]Weekly Put Sale[/b]

This study is a tool I use for selling weekly puts at the suggested strike prices. 

1. The suggested strike prices are based on the weekly high minus an ATR multiple which can be adjusted in the settings
2. You can also adjust the settings to Monthly strike prices if you prefer selling options further out
3. I suggest looking for Put sale premium that is between 0.25% to 0.75% of the strike price for weekly Puts and 1% to 3% of the strike price for monthly Puts

Disclaimers: Selling Puts is an advanced strategy that is risky if you are not prepared to acquire the stock at the strike price you sell at on the expiration date. You must make your own decisions as you will bear the risks associated with any trades you place. To sum it up, trading is risky, and do so at your own risk.

## Source Code

````pine
//This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=4
//Author = https://www.tradingview.com/u/Dustin_D_RLT/
//Weekly Put Sale
study(title="Weekly Put Sale", shorttitle="WPS", overlay=true, resolution="")
//Set for 1 Week for weekly options or 1 Month for monthly
higherTF = input(title="Higher Timeframe Resolution",defval="W", type=input.resolution)
atrLength = input(title="ATR length", defval=14, minval=1)
smoothing = input(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"])
//Multiple of ATR for the distance from high of week
strikeMultiplier1 = input(title="ATR Strike Multiplier1", defval=1.5, minval=1, step=.25)
strikeMultiplier2 = input(title="ATR Strike Multiplier2", defval=2, minval=1, step=.25)
strikeMultiplier3 = input(title="ATR Strike Multiplier3", defval=2.5, minval=1, step=.25)
//Used in signal for XX% of Weekly ATR From Weekly High
largeBearCandle = input(title="Large Bear Candle Percent", defval=75, minval=1)
// Set the market session to use (0000-0000 is all time from monday through friday)
sessSpec = input(title="To use Market time session",defval="0000-0000", type=input.session)
// A function to check if the current bar is the first bar on the higher timeframe
is_newbar(res, sess) =>
    t = time(res, sess)
    na(t[1]) and not na(t) or t[1] < t
newbar = is_newbar(higherTF, sessSpec)
// Weekly ATR
ma_function(source, length) =>
	if smoothing == "RMA"
		rma(source, length)
	else
		if smoothing == "SMA"
			sma(source, length)
		else
			if smoothing == "EMA"
				ema(source, length)
			else
				wma(source, length)
				
// determine the high of the week or month
fullWeekHigh = security(syminfo.tickerid, higherTF, high, barmerge.gaps_off, barmerge.lookahead_off)
// Only check the high if the high is not the first candle starting a higher time frame candle
var float newHigh = na
if newbar
    newHigh := high
else
    newHigh := max(high, newHigh, high[1])
// For testing plot newHigh
// plot(newHigh, title = "High of the Full week", style=plot.style_stepline, color=color.blue)
// Calculate the ATR of the fullWeekHigh (make sure barmerge.lookahead_) has the same value as fullWeekHigh
atrValue = security(syminfo.tickerid, higherTF, ma_function(tr(true), atrLength), barmerge.gaps_off, barmerge.lookahead_off)
// Calculate the strike levels
strike1 = newHigh - (strikeMultiplier1 * atrValue)
strike2 = newHigh - (strikeMultiplier2 * atrValue)
strike3 = newHigh - (strikeMultiplier3 * atrValue)
// Plot the different strike price levels
plot(strike1, title = "Strike Level 1", style=plot.style_stepline, color=color.orange)
plot(strike2, title = "Strike Level 2", style=plot.style_stepline, color=color.blue)
plot(strike3, title = "Strike Level 3", style=plot.style_stepline, color=color.navy)
//Signal for XX% of Weekly ATR From Weekly High
putSaleSignal = (close < open and (newHigh - close) > (atrValue * largeBearCandle * .01))
plotchar(putSaleSignal, char='$', location=location.abovebar, color=color.green, size=size.tiny)
//Alerts
alertcondition(putSaleSignal, title="WPS Alert", message="Weekly Put Sale Alert Signal")
````
