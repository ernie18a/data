<!-- tradingview-pine-id: PUB;VGfFXQmzz3VGB4cWrC3tH5ULoVekuvYB -->
<!-- tradingviewscripts-format: 1 -->
# Hull Candles [BigBitsIO]

Source: https://www.tradingview.com/script/dyb13iDa-Hull-Candles-BigBitsIO/

## Description

This script is for custom candles based on an HMA calculation with a default period of 10 as well as an SMA of the close price, defaulted to 1 period to only show the current price. The purpose of the custom candles is to try and reduce noise from candles and help identify trends.  These custom candles somewhat resemble Heikin-Ashi candles in their appearance.

Explained:
- Open, High, Low and Close (o, h, l, and c) are all calculated using an HMA calculation based on a user input length/period, defaulted at 10.
- Candle colors are determined by using the same HMA calculation on the ohcl4 and comparing it to the previous candle.  Green candles have an ohlc4 greater than the previous candle, all other candles are red.
- The current price is plotted with the default blue line with an SMA calculation with 1 period to allow customization of smoothing if necessary to identify trends.

DISCLAIMER: For educational and entertainment purposes only. Nothing in this content should be interpreted as financial advice or a recommendation to buy or sell any sort of security or investment including all types of crypto. DYOR, TYOB.

---

## Source Code

````pine
//@version=4

//
// Pine Script v4
// @author BigBitsIO
// Script Library: https://www.tradingview.com/u/BigBitsIO/#published-scripts
//

study("Hull Candles [BigBitsIO]", overlay=true)
len = input(10, minval=1, title="Length")
lenBodyColor = input(10, minval=1, title="Body Color HMA Length")
lenClose = input(1, minval=1, title="Close length")

// I have consolidated some of this code from a prior example
o = hma(open, len)
c = hma(close, len)
h = hma(high, len)
l = hma(low, len)

ohlcFour = hma(ohlc4, lenBodyColor)

colorBody = ohlcFour > ohlcFour[1] ? color.lime : color.red
plotcandle(o, h, l, c, color=colorBody, title="Hull Candles")
plot(sma(close, lenClose), title="Close SMA")
````
