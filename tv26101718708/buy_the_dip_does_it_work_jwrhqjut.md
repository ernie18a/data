# Buy The Dip - Does It Work?

- url: https://www.tradingview.com/script/JwRhQjuT-Buy-The-Dip-Does-It-Work/
- type: strategy
- pine_id: PUB;2gvv0RF7QW9JKCgMeILZNolrMkk1ez02
- version: 2.0

## Description

[b]Buying the dip has become a meme in crypto, but does it actually work?[/b]

Using this script you can find out.
The dip is defined here as the average true range multiplied by a [b]number of your choosing[/b] (dipness input) and subtracted from the low.
When price crosses under the dip level, a long is initiated. The long is then closed using a timestop (default value 20 bars), no fancy exits here.

A general rule for buying the dip should be to be more passive in a bull market and aggressive in a bear market.
Same goes for all counter trend trading.

Heres a few other examples of dip buying statistics using the H4 timeframe:

[b]50% profitable, 1.692 Profit Factor[/b]
[symbol="BINANCE:PIVXBTC"]BINANCE:PIVXBTC[/symbol] 
[image]https://www.tradingview.com/x/n2hjWCzD/[/image]

[b]56.52% profitable, 1.254 Profit Factor[/b] 
[symbol="BINANCE:KMDBTC"]BINANCE:KMDBTC[/symbol]
[image]https://www.tradingview.com/x/grqzgq5r/[/image]

[b]27.27% Profitable, 0.257 Profit Factor... yikes![/b]
[symbol="BINANCE:BTSBTC"]BINANCE:BTSBTC[/symbol]
[image]https://www.tradingview.com/x/0qhXJR9F/[/image]

[b]73.33% Profitable, 13.627 Profit Factor... o.O[/b]
[symbol="BINANCE:MANABTC"]BINANCE:MANABTC[/symbol]
[image]https://www.tradingview.com/x/iHeccE71/[/image]

## Source Code

````pine
//@version=3
strategy(title="Buy The Dip", shorttitle="BTFD", overlay=true)
dipness = input(title="Dipness",defval=2)
smoothness = input(title="Smoothing",defval=10,minval=0)
lookforward = input(title="Exit After This Many Bars", defval=20)

thedip = low - (atr(20) * dipness)
thedipsma = sma(thedip,smoothness)

buyCondition = crossunder(low,thedipsma)

if (buyCondition)
    strategy.entry("long", strategy.long)
    
strategy.close("long",when=buyCondition[lookforward]) 

plot(thedipsma)
````
