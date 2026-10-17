# EMA Envelope

- url: https://www.tradingview.com/script/nWpTN12k-EMA-Envelope/
- type: strategy
- pine_id: PUB;gEaYaI11FdTg2SiRbpwKRAwcWRL5Rakg
- version: 1.0

## Description

This is an attempt to convert gunbot's SG strategy into a proper TradingView strategy. The problem is that SG Sell Level relies on % above purchase price, which we don't actually know in TradingView. So we could try to get the average of the next bar or something, which maybe this is what the Slippage setting is? I'm not sure. 

Anyways, using % above EMA does actually work as a strategy a bit. It's nothing like Turtle Rules by tmr0 though!

Will keep working on this gradually; feedback greatly appreciated!

## Source Code

````pine
strategy(title="EMA Envelope", shorttitle="EE", overlay=true, precision=8, pyramiding=0, default_qty_type=strategy.percent_of_equity, max_bars_back=1000, default_qty_value=1, currency="USD", commission_type="percent", commission_value=0.6)

buy_percent_under_envelope = input(2.0, title="% Under EMA Envelope to Buy")
sell_percent_over_envelope = input(1.0, title="% Over EMA Envelope to Sell")

// EMA envelope plot
ema8  = ema(ohlc4,  8 / (interval / 15))
ema16 = ema(ohlc4, 16 / (interval / 15))
upper_bound = ((ema8 > ema16) ? ema8 : ema16) * (1 + (sell_percent_over_envelope / 100))
lower_bound = ((ema8 < ema16) ? ema8 : ema16) * (1 - (buy_percent_under_envelope / 100))

pretty_orange = #e69138
pretty_red = #e06666
pretty_green = #93c47d
pretty_yellow = #f1c232

p1 = plot(upper_bound, title="% Over Envelope", color=#cccccc, linewidth=1)
p2 = plot(lower_bound, title="% Under Envelope", color=#cccccc, linewidth=1)
p3 = plot(ema8, title="EMA(2h)", color=pretty_yellow, linewidth=2)
p4 = plot(ema16, title="EMA(4h)", color=pretty_orange, linewidth=2)

upper_fill_color = (hl2 > upper_bound and falling(hl2, 2)) ? blue : white
bgcolor(color=upper_fill_color, transp=80)

lower_fill_color = (hl2 < lower_bound and rising(hl2, 2)) ? orange : white
bgcolor(color=lower_fill_color, transp=80)

strategy.entry("L", strategy.long, when=(hl2 < lower_bound and rising(hl2, 2)))
strategy.close("L", when=(hl2 > upper_bound and falling(hl2, 2)))

// // BB plot
// length = 4 / (interval / 15)
// basis = sma(ohlc4, length)
// dev = 2.0 * stdev(ohlc4, length)
// upper = basis + dev
// lower = basis - dev
// plot(basis, color=red, title="Basis Line")
// bbp1 = plot(upper, color=blue, title="BB Upper Bound")
// bbp2 = plot(lower, color=blue, title="BB Lower Bound")
// fill(bbp1, bbp2)
````
