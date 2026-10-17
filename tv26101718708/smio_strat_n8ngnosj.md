# SMIO strat 

- url: https://www.tradingview.com/script/N8nGnOsj-SMIO-strat/
- type: strategy
- pine_id: PUB;xVDpqXo9X8nrxrWPcgVQiRolEmgOVSyz
- version: 1.0

## Description

SMIO strat with longer input which rounds off the trends. The strat is based on when SMIO hits over 0 it sends a buy signal and when it goes under it sends a short signal.  The SMIO input was changed from 20, 5, 5 to 35, 15, 15.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Nico_TM

//@version=4
strategy(shorttitle= "MFM", title= "SMIO", overlay=true)
longlen = input(35, minval=1, title="Long Length")
shortlen = input(15, minval=1, title="Short Length")
siglen = input(15, minval=1, title="Signal Line Length")
erg = tsi(close, shortlen, longlen)
sig = ema(erg, siglen)
osc = erg - sig
plot(osc, color=#FF8080, style=plot.style_histogram, title="SMI Ergodic Oscillator")

long = crossover(osc, 0)
short = crossunder(osc, 0)

strategy.entry("long", true, when = long)
strategy.entry("short", false, when = short)

strategy.close("long", when = short)
strategy.close("short", when = long)

start = timestamp(2020, 6, 1, 0, 0)
end = timestamp(2021, 6, 1 ,0, 0)
````
