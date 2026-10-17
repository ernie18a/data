# Variable Moving Average Strategy

- url: https://www.tradingview.com/script/j8hsADAF-variable-moving-average-strategy/
- type: strategy
- pine_id: PUB;bIABFGgzUmKQI4ypmzaR1srJjPginuHv
- version: 3.0

## Description

Strategy based on Variable Moving Average

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © laptevmaxim92

//@version=4
strategy("Variable Moving Average Strategy", overlay=true)

src=close
l =input(5, title="VMA Length") 
std=input(true, title="Show Trend Direction Colors")

utp = input(false, "Use take profit?")
pr = input(100, "Take profit pips")
usl = input(false, "Use stop loss?")
sl = input(100, "Stop loss pips")
fromday = input(01, defval=01, minval=01, maxval=31, title="From Day")
frommonth = input(01, defval=01, minval= 01, maxval=12, title="From Month")
fromyear = input(2000, minval=1900, maxval=2100, title="From Year")
today = input(31, defval=01, minval=01, maxval=31, title="To Day")
tomonth = input(12, defval=12, minval=01, maxval=12, title="To Month")
toyear = input(2019, minval=1900, maxval=2100, title="To Year")

use_date = (time > timestamp(fromyear, frommonth, fromday, 00, 00) and time < timestamp(toyear, tomonth, today, 00, 00))

k = 1.0/l
pdm = 0.0
pdm := max((src - src[1]), 0)
mdm = 0.0
mdm := max((src[1] - src), 0)
pdmS = 0.0
pdmS := ((1 - k)*nz(pdmS[1]) + k*pdm)
mdmS = 0.0
mdmS := ((1 - k)*nz(mdmS[1]) + k*mdm)
s = pdmS + mdmS
pdi = pdmS/s
mdi = mdmS/s
pdiS = 0.0
pdiS := ((1 - k)*nz(pdiS[1]) + k*pdi)
mdiS = 0.0
mdiS := ((1 - k)*nz(mdiS[1]) + k*mdi)
d = abs(pdiS - mdiS)
s1 = pdiS + mdiS
iS = 0.0
iS := ((1 - k)*nz(iS[1]) + k*d/s1)
hhv = highest(iS, l) 
llv = lowest(iS, l) 
d1 = hhv - llv
vI = (iS - llv)/d1
vma = 0.0
vma := (1 - k*vI)*nz(vma[1]) + k*vI*src
vmaC=(vma > vma[1]) ? color.lime : (vma<vma[1]) ? color.red : (vma==vma[1]) ? color.yellow : na 
plot(vma, color=std?vmaC:color.white, linewidth=3, title="VMA")

longCondition = vma > vma[1]
if (longCondition and use_date)
    strategy.entry("BUY", strategy.long)

shortCondition = vma < vma[1]
if (shortCondition and use_date)
    strategy.entry("SELL", strategy.short)

if (utp and not usl and use_date)
    strategy.exit("TP", "BUY", profit = pr)
    strategy.exit("TP", "SELL", profit = pr)
    
if (usl and not utp and use_date)
    strategy.exit("SL", "BUY", loss = sl)
    strategy.exit("SL", "SELL", loss = sl)
    
if (usl and utp and use_date)
    strategy.exit("TP/SL", "BUY", loss = sl, profit = pr)
    strategy.exit("TP/SL", "SELL", loss = sl, profit = pr)
````
