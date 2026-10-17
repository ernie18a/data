# RSI Average Swing Bot

- url: https://www.tradingview.com/script/uhXx6pUI-RSI-Average-Swing-Bot/
- type: strategy
- pine_id: PUB;60ad616ee68b4b25b8906f380cadec37
- version: 1.0

## Description

This is a modified RSI version using as a source a big length(50 candles) and an average of all types of sources for candle calculations such as ohlc4, close, high, open, hlc3 and hl2.

In this case we are going to use a 0-1 scale for an easier calculation, where 0.5 is going to be our middle point.

Above 0.5 we consider a bullish possibility.
Below 0.5 we consider a bearish possibility.


I made a small example bot using that initial logic, together with 2 exit points for long or short positions.


If there are any questions, let me know !

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © exlux99

//@version=5
strategy("RSI Average Swing Bot")

long_only=input.bool(true, title="Allow Long entries", group="Entries Type")
short_only=input.bool(true, title="Allow Short entries", group="Entries Type")
rsiohlc4= ta.rsi(ohlc4,50)/100
rsiclose= ta.rsi(close,50)/100
rsiopen= ta.rsi(open,50)/100
rsihigh= ta.rsi(high,50)/100
rsihlc3= ta.rsi(hlc3,50)/100
rsihl2= ta.rsi(hl2,50)/100

hline(0.3, color=color.white, linestyle=hline.style_dashed, linewidth=2)
hline(0.5, color=color.white, linestyle=hline.style_dotted, linewidth=2)
hline(0.7, color=color.white, linestyle=hline.style_dashed, linewidth=2)
rsi_avg = (rsiohlc4+rsiclose+rsiopen+rsihigh+rsihl2+rsihlc3)/6

culoare = rsi_avg > 0.50? color.green : rsi_avg<0.50 ? color.red : color.yellow
plot(rsi_avg,color=culoare )


long = rsi_avg > 0.5 and rsi_avg[1]< 0.5
longexit = rsi_avg >= input.float(0.65, step=0.05)
short = rsi_avg < 0.5 and rsi_avg[1] >0.5
shortexit=rsi_avg<=input.float(0.35, step=0.05)

if(long_only)
    strategy.entry("long",strategy.long,when=long)
    strategy.close("long",when=longexit or short)

if(short_only)
    strategy.entry("short",strategy.short,when=short)
    strategy.close("short",when=shortexit or long)
````
