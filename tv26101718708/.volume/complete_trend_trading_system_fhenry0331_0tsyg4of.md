# Complete Trend Trading System [Fhenry0331]

- url: https://www.tradingview.com/script/0tSyg4OF-Complete-Trend-Trading-System-Fhenry0331/
- type: indicator
- pine_id: PUB;pmwxMRmxDlzZWZzbv0rMKoB6LCAzuX7S
- version: 1.0

## Description

This system was designed for the beginner trader to make money swing trading. Your losses will be small and your gains will be mostly large. You will show consistent profit. Period.

The system works on any security you like to trade. I used GBPUSD as an example because of the up swing and down swing it had recently. I tried to put as much information of how the system works in the chart. Hope it helps and is not to cluttered.

I will reiterate how the system works here: Everything is based off of closed price.

[b]Legend[/b]

[b]Uptrend: Buy[/b][i][/i]

Green bar: initial start of an uptrend or uptrend continuing. Place order above that bar. If the initial bar does not stray too far from the MVWAP , I will place orders above subsequent bars if no filled occurred.

If initial start of the trend is missed, I will wait for the pullback. A pullback is a close below the MVWAP, and a close above the EMA (Low), RSI is above 50. Orders are placed above the pullback bars with plotted char "B" and also plotted green triangle up. Again orders are placed above those bars. the bars do not notate automatic buys. Don't chase anything. You will miss the initial bar on something because of news or earnings and it rocket up. Just wait, it will pullback. If it doesn't, to hell with it, on to the next.

Take profits: In the indicator you will see "T." That notates to take some profits. It is a suggestion. I was always told to take profits into spikes, as well as you can never lose money if you take profits. Up to you if you want to scale out and take the suggested profits or not.

Exit Completely: In an uptrend, close your entire position on bars colored yellow or red. (Again, closed bars)

In uptrend bars colored orange and black, do nothing, they are just pullback bars. Look for the buy pullback signal, then follow pullback buy rules for an uptrend. 


[b]Downtrend: Short[/b][i][/i]

Red bar: initial start of a downtrend or downtrend continuing. Place order below the bar. If the initial bar does not stray too far fro the MVWAP, place orders below subsequent bars.

If initial start on the downtrend is missed, wait for the pullback. A pullback is a close above the MVWAP, and close below the EMA(Low). RSI is below 50. Orders are placed below the pullback bars with the plotted char "S" and also plotted red triangle. Again those bars are not automatic shorts, orders are placed below them. Don't chase anything. Wait for price to come into your plan. The idea FOMO is the stupidest thing ever, how can you miss out on something when it is always there. The market is always there and something will come into your zone. Chill. 

"T": same as in uptrend, suggestion to take some profits.

Exit Completely: In a downtrend, close your entire position on bars colored orange or green.

In downtrend you will see bars colored yellow and black, do nothing, they are pullback bars. Look for the pullback short signal and follow pullback short rules. 

If you have any questions get at me. Take a look at it on what you trade. Flip it through different securities. 


Best of luck in all you do. 

P.S. You should not take a trade right before earnings. You should also exit a trade right before earnings.

## Source Code

````pine
//@version=3
study(shorttitle = "TTS", title="Complete Trend Trading System [Fhenry0331]", overlay=false)

myemalength = input(26) 
myema = ema(low, 26)

mvwaplength = input(13) 
mvwap= ema(vwap, mvwaplength)



price=close

src = close, len = input(14, minval=1, title="Length")
up = rma(max(change(src), 0), len)
down = rma(-min(change(src), 0), len)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

plot(rsi, color=white)

change1 = rsi > 60 ? green :na
change2= rsi < 40 ? red: na

p1 = plot(rsi, style=linebr, linewidth=4, color=change1)
p2 = plot(rsi, style=linebr, linewidth=4, color=change2)


band1 = hline(70)
band2 = hline(30)
band3 = hline(55)
band4 = hline (45)
midline = hline (50)

fill(band1, band3, color=green, transp=90)
fill(band2, band4, color=red, transp=90)
fill(band3, band4, color=black, transp=90)

cond1 = rsi > 55 and close > myema ? 1 : 0
barcolor(cond1 ? green : na) 

cond2 = rsi < 45 and close < myema ? 1 : 0
barcolor(cond2 ? red : na) 

cond3 = rsi < 50 and close < myema ? 1 : 0
barcolor(cond3 ? yellow : na)

cond4 = rsi > 50 and close > myema ? 1 : 0
barcolor(cond4 ? orange : na)

cond5 = rsi < 50 and close > myema ? 1 : 0
barcolor(cond5 ? black : na)

cond6 = rsi > 50 and close < myema ? 1 : 0
barcolor(cond6 ? black : na)


cond7 = rsi > 50 and close < mvwap ? 1 : 0
plotchar(cond7, title="Buy pullback", offset=0, char='BuyPB',color=lime, transp=0)

cond8 = rsi < 50 and close > mvwap ? 1 : 0
plotchar(cond8, title="Sell pullback", offset=0, char='SellPB', color=red, transp=0)

cond9 = rsi > 50 and close < mvwap ? 1 : 0
plotshape(cond9, style=shape.triangleup, location=location.bottom, color=lime, transp=0, offset=0)

cond10 = rsi < 50 and close > mvwap ? 1 : 0
plotshape(cond10, style=shape.triangledown, location=location.bottom, color=red, transp=0, offset=0)

cond11 = rsi > 75 and close > myema ? 1 : 0
plotchar(cond11, title="take some profits", offset=0, char='TP', color=blue, transp=0)

cond12 = rsi < 25 and close < myema ? 1 : 0
plotchar(cond12, title="take some profits", offset=0, char='TP', color=purple, transp=0)
````
