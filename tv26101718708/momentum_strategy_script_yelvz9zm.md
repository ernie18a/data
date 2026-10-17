# Momentum - Strategy Script

- url: https://www.tradingview.com/script/YeLVz9zM-Momentum-Strategy-Script/
- type: strategy
- pine_id: PUB;dCVnky7RBcbnpK4iPvLCYMjZ3Ulin6wS
- version: 1.0

## Description

Based on the bult-in momentum script, I took the liberty of updating it, adding two features.

First, I would like to see the momentum oscillator showing percentage values, rather than absolute values. Visually facilitating analysis in long-term graphs.

Second, just for fun*.
I don't know how to explain the reason exactly, but for the strategy bult-in script, I didnt like the formula of "mom1" calculation.
So I changed it for a formula that made the most sense to me.

In any case, the original script remains in the code, optionally disabling the "percent" option and selecting the MOM1 option in the "MOM Choice" field, for the purpose of study and comparisons.

The script below is opened for study and any suggestions will be welcome. 

I hope it can help the community. 
It's just the beginning.

Study only purpose.

I tried to follow the code conventions found in the link below.
https://www.pinecoders.com/coding_conventions/

## Source Code

````pine
//@version=4
strategy("Momentum - Strategy", overlay = false, precision = 2, initial_capital = 10000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_type = strategy.commission.percent, commission_value = 0.2 )

i_len           =       input(defval = 12,      title = "Length",       minval = 1)
i_src           =       input(defval = close,   title = "Source")
i_percent       =       input(defval = true,    title = "Percent?")
i_mom           =       input(defval = "MOM2",  title = "MOM Choice",   options = ["MOM1", "MOM2"])

momentum(seria, length, percent) =>
	_mom        =       percent ? ( (seria / seria[length]) - 1) * 100 : seria - seria[length]
	_mom

mom0        =       momentum(i_src, i_len, i_percent)
mom1        =       momentum(mom0, 1, i_percent)
mom2        =       momentum(i_src, 1, i_percent)

momX        =       mom1

if i_mom == "MOM2"
    momX    :=     mom2

if (mom0 > 0 and momX > 0)
    strategy.entry("MomLE", strategy.long, stop = high + syminfo.mintick, comment = "MomLE")
else
	strategy.cancel("MomLE")
if (mom0 < 0 and momX < 0)
	strategy.entry("MomSE", strategy.short, stop = low - syminfo.mintick, comment = "MomSE")
else
	strategy.cancel("MomSE")

plot(mom0, color = #0000FF, title = "MOM")
plot(mom1, color = #00FF00, title = "MOM1", display = display.none)
plot(mom2, color = #00FF00, title = "MOM2")
````
