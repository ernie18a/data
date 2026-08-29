<!-- tradingview-pine-id: PUB;qMD118DlIWzZI5roMqyrP5BYrCK6d04N -->
<!-- tradingviewscripts-format: 1 -->
# SMU STDEV Candles

Source: https://www.tradingview.com/script/ULnIvZeA-SMU-STDEV-Candles/

## Description

This script creates a STDEV in a candle format so you can see the Change in a candle format and compare it with the actual price candle.

Is very similar to SMU RSI and SMU ROC. The interesting part is to see the full effect of traditional indicators in a candle format rather than a simple plot format. Very interesting view in SPX. There is a very big clue in the chart as STDEV changed since 2008. Can you figure it out? 

Also, try this in lower time frame and you will be amazed how Algo kills volatility after each upside or downside. Fascinating

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © stockmarketupdate
//@version=4
//This script creates a STDEV in a candle format so you can see the STDEV Change in a candle format and compare it with the actual price candle.
study("SMU STDEV Candles")
// Length or RSI
// I set it to 6 as it shows better fit for S&P500. Chnage this value to fit the index or stock
_length=input(defval=14,title=" STDEV Length")
//Scale set to 1 but you can chnage it to 10, 100 for better magnification
_var=input(defval=1.0,title="Scale")

//Calculate STDEV and assign to candles series
// Mutiply by scale
    
_open_roc=stdev(open,_length) * _var
_high_roc=stdev(high,_length) * _var
_low_roc=stdev(low,_length) * _var
_close_roc=stdev(close,_length) * _var


//Plot the ROC candles
plotcandle(_open_roc,_high_roc,_low_roc,_close_roc,color= close > close[1] ? color.green:color.red)
````
