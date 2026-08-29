<!-- tradingview-pine-id: PUB;C1onfnPS83Q5TrTc5g1Z2Ji2uVeIOjn8 -->
<!-- tradingviewscripts-format: 1 -->
# Pre-Market Volume Profile

Source: https://www.tradingview.com/script/fclmmkpH/

## Description

This indicator displays the pre-market volume (note: without the post-market of the previous day).
Unusual pre-market volume often indicates that institutional market makers are moving the market, which is a good sign for unusual high price movement.
The indicator helps me to spot stocks, if a pre-market gap is confirmed with enough (unusual) volume.

You can define, what "unusual" means by you, by adjusting the SMA length and the SMA multiplier.
The default is a length of 21 bars and a 2.5 multiplier, meaning I'm interested in a stock, if the pre-market volume exceeds the average pre-market volume by 2.5 times.

---

## Source Code

````pine
//@version=4
// This indicator displays the pre-market volume (note: without the post-market of the previous day).
// Unusual pre-market volume often indicates that institutional market makers are moving the market,
// which is a good sign for unusual high price movement.
// The indicator helps me to spot, if a pre-market gap is confirmed with enough (unusual) volume.
//
// You can define, what "unusual" means by you, by adjusting the SMA length and the SMA multiplier.
// The default is a length of 21 bars and a 2.5 multiplier, meaning I'm interested in a stock, if
// the pre-market volume exeeds the average pre-market volume by 2.5 times.
study("Pre-Market Volume Profile", format=format.volume)
averageLength = input(title="SMA Length", type=input.integer, defval=21, minval=-1)
averageMultiplier = input(title="SMA Multiplier", type=input.float, defval=2.5, minval=-1, step=.25)

tickerExtended = tickerid(syminfo.prefix, syminfo.ticker, session.extended, adjustment.splits)
tickerRegular = tickerid(syminfo.prefix, syminfo.ticker, session.regular, adjustment.splits)

timeExtended = security(tickerExtended, resolution="1440", expression=time, lookahead=true)
timeRegular = security(tickerRegular, resolution="1440", expression=time, lookahead=true)

volumePreMarket= 0.0
volumePreMarket := nz(volumePreMarket[1])

if timeExtended != timeRegular
    volumePreMarket := na
    
if timeExtended > timeRegular
    volumePreMarket := volume

averagePreMaarketVolume = ema(volumePreMarket * averageMultiplier, averageLength)

plot(volumePreMarket, style=plot.style_histogram, linewidth=4, title="Pre-Market Volume")
plot(averagePreMaarketVolume, color=color.orange, linewidth=2, title="Multiplied Avg.", trackprice=true)
````
