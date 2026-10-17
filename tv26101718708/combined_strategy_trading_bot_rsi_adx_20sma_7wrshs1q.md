# Combined Strategy Trading Bot (RSI ADX 20SMA)

- url: https://www.tradingview.com/script/7wrshs1q-Combined-Strategy-Trading-Bot-RSI-ADX-20SMA/
- type: strategy
- pine_id: PUB;93664a76806f4f188830c63fa3e3d9e9
- version: 1.0

## Description

Trading Bot V1, This code implements a combined trading strategy that uses several indicators and strategies to make buy and sell decisions in the market. The code is written in Pine Script™, which is a programming language used in the TradingView platform. By BraelonWhitfield.Eth

The strategy uses the Average Directional Movement Index (ADX) and the Pine SuperTrend indicator to identify trends and price movements in the market. The SuperTrend indicator is a popular technical analysis tool that helps to identify the direction of the current trend and provides entry and exit points for trades.

The strategy also uses the Relative Strength Index (RSI) to identify overbought and oversold conditions in the market. The RSI is a momentum indicator that measures the speed and change of price movements in the market.

The first part of the code defines the inputs for the ADX and DI Length, which are used to calculate the ADX and DI values. The dirmov() function is used to calculate the positive and negative directional indicators (plusDM and minusDM) based on the high and low prices. The truerange variable is then calculated using the True Range (TR) formula. Finally, the plus and minus variables are calculated using the smoothed moving average of the plusDM and minusDM values.

The adx() function is then used to calculate the ADX values based on the plus and minus variables. The Pine SuperTrend indicator is defined using the pine_supertrend() function. This function uses the high-low average (hl2) and the Average True Range (ATR) to calculate the upper and lower bands for the indicator. The direction of the current trend is then determined based on whether the current price is above or below the upper or lower bands.

The RSI values are then calculated using the ta.rsi() function, with the inputs for the close price and the RSI period. The overbought and oversold conditions are defined using the OB and OS inputs, which specify the threshold values for the RSI. The upTrend and downTrend variables are defined based on the direction of the Pine SuperTrend indicator.

The next part of the code defines the 20-period Simple Moving Average (SMA) using the ta.sma() function. The os and ob variables are then calculated based on the RSI values and the OB and OS inputs. The strategy.entry() function is used to define the buy and sell orders based on the upTrend and downTrend variables, as well as the Pine SuperTrend indicator, the 20-period SMA, and the os variable.

The final part of the code defines the Channel Breakout Strategy using the ta.highest() and ta.lowest() functions to calculate the upper and lower bounds of the channel. The strategy.entry() function is then used to define the buy and sell orders based on whether the current price is above or below the upper or lower bounds.

In summary, this code implements a combined trading strategy that uses several indicators and strategies to make buy and sell decisions in the market. The strategy is designed to identify trends and price movements in the market, as well as overbought and oversold conditions, to provide entry and exit points for trades. The strategy uses the Pine SuperTrend indicator, the ADX and DI indicators, the RSI, and the 20-period SMA, as well as the Channel Breakout Strategy to make informed trading decisions.

## Source Code

````pine
//@version=5
strategy("Combined Strategy", overlay=true, default_qty_value=100, initial_capital=1000, margin_long=0.1)

adxlen = input(7, title="ADX Smoothing")
dilen = input(7, title="DI Length")
dirmov(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    truerange = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
    minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
    [plus, minus]

adx(dilen, adxlen) =>
    [plus, minus] = dirmov(dilen)
    sum = plus + minus
    adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)
sig = adx(dilen, adxlen)

// The same on Pine Script™
pine_supertrend(factor, atrPeriod) =>
    src = hl2
    atr = ta.atr(atrPeriod)
    upperBand = src + factor * atr
    lowerBand = src - factor * atr
    prevLowerBand = nz(lowerBand[1])
    prevUpperBand = nz(upperBand[1])

    lowerBand := lowerBand > prevLowerBand or close[1] < prevLowerBand ? lowerBand : prevLowerBand
    upperBand := upperBand < prevUpperBand or close[1] > prevUpperBand ? upperBand : prevUpperBand
    int direction = na
    float superTrend = na
    prevSuperTrend = superTrend[1]
    if na(atr[1]) and ta.rsi(close, 21) < 66 and ta.rsi(close,3) > 80 and ta.rsi(close, 28) > 49 and sig > 20
        direction := 1
    else if prevSuperTrend == prevUpperBand
        direction := close > upperBand ? -1 : 1
    else
        direction := close < lowerBand ? 1 : -1
    superTrend := direction == -1 ? lowerBand : upperBand
    [superTrend, direction]

[pineSupertrend, pineDirection] = pine_supertrend(3, 10)
upTrend = pineDirection < 0
downTrend = pineDirection > 0

// Define the 20-period SMA
sma20 = ta.sma(close, 20)

a = ta.rsi(close,14)
OB = input(70)
OS = input(30)
os = a > OB
ob = a < OS

if upTrend and close > pineSupertrend and close > sma20 and os
    strategy.entry("Buy", strategy.long)

if ta.crossunder(close, sma20) or ob
    strategy.close_all()

//define when to breakout of channel 
//("ChannelBreakOutStrategy", overlay=true)
length = input.int(title="Length", minval=1, maxval=1000, defval=5)
upBound = ta.highest(high, length)
downBound = ta.lowest(low, length)
if (not na(close[length]))
	strategy.entry("ChBrkLE", strategy.long, stop=upBound + syminfo.mintick, comment="ChBrkLE")
strategy.entry("ChBrkSE", strategy.short, stop=downBound - syminfo.mintick, comment="ChBrkSE")
````
