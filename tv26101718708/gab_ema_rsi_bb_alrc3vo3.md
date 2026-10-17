# Gab EMA + rsi + bb

- url: https://www.tradingview.com/script/aLrC3VO3-Gab-EMA-rsi-bb/
- type: strategy
- pine_id: PUB;a7036149e09a49879a7084195d11e766
- version: 6.0

## Description

scrypt I made for a friend
you are welcome bro ;)

simple strategy
BB Default
RSI 3
200 ema


200 EMA gives the trend direction. 
if RSI is over bought and candle touch BB upper band then there will be buy entry. (Price must be above 200 ema)

If RSI is over sold and price touch bb lower band then there will be sell entry. (Price must be below the 200 ema)


SL will be 1 ATR of the entry candle. Tp will 2:1.

***Missing TP and SL values

## Source Code

````pine
//@version=5
strategy("Gab EMA + rsi + bb", overlay=true)
// Custom RSI
RSIlength = input.int(3, minval=1 , title="lookback length of RSI")
RSIOverBought = input.float(70, title="RSI OB")
RSIOverSold = input(30, title="RSI OS")
RSIprice = close
rsi = ta.rsi(RSIprice, RSIlength)

//ATR
atr = ta.atr(14)

//Bollinger Bands
BBlength = input.int(20, minval=1,title="Bollinger Period Length")
BBmult = input.float(2.0, minval=0.001, maxval=50, title="Bollinger Bands Standard Deviation")
BBbasis = ta.sma(close, BBlength)
BBdev = BBmult * ta.stdev(close, BBlength)
BBupper = BBbasis + BBdev
BBlower = BBbasis - BBdev
source = close

//EMA
emaLength=input(200)
ema = ta.ema(close,emaLength)

//Set TP and SL values
sl_shortprice = close + atr
tp_shortprice = close - (2*atr)
sl_longprice = close - atr
tp_longprice = close + (2*atr)

// Save stops & targets for the current trade
var tp_long = 0.0
var sl_long = 0.0
var tp_short = 0.0
var sl_short = 0.0
var entry = 0.0

//Condition for Sl and TP
if (strategy.position_size[1] != strategy.position_size) and barstate.isconfirmed
    entry := strategy.opentrades.entry_price(0)
    tp_short := entry - (2*atr)
    sl_short := entry + atr
    tp_long := entry + (2*atr)
    sl_long := entry - atr
    

//Strategy Entry and Exit
strategy.entry("sell", strategy.short, when = close < ema and rsi < RSIOverSold and close < BBlower and barstate.isconfirmed)
strategy.exit("closeshort", from_entry="sell", limit=tp_short, stop=sl_short, when=strategy.position_size != 0 and barstate.isconfirmed)

strategy.entry("buy", strategy.long, when = close > ema and rsi > RSIOverBought and close > BBupper)
strategy.exit("closelong", from_entry="buy", limit=tp_long, stop=sl_long, when=strategy.position_size != 0)

//Plot
upper = plot(BBupper, "Upper", color.blue)
lower = plot(BBlower, "Lower", color.blue)
EMA = plot(ema, "EMA", color.orange)
plot(strategy.position_size < 0 ? tp_short : na, color=color.red, style=plot.style_linebr, title="SL Short")
plot(strategy.position_size < 0 ? sl_short : na, color=color.green, style=plot.style_linebr, title="TP Short")
plot(strategy.position_size > 0 ? tp_long : na, color=color.red, style=plot.style_linebr, title="SL Long")
plot(strategy.position_size > 0 ? sl_long : na, color=color.green, style=plot.style_linebr, title="TP Long")
````
