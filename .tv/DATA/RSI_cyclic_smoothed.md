<!-- tradingview-pine-id: PUB;ckgSq3I4CYTbgGF4qcBx8hRXOWpX8LuB -->
<!-- tradingviewscripts-format: 1 -->
# RSI cyclic smoothed

Source: https://www.tradingview.com/script/TmqiR1jp-RSI-cyclic-smoothed-v2/

## Description

Cyclic Smoothed Relative Strength Indicator

The cyclic smoothed RSI indicator is an enhancement of the classic RSI , adding

[*]  additional smoothing according to the market vibration,
[*]  adaptive upper and lower bands according to the cyclic memory and
[*]  using the current dominant cycle length as input for the indicator.

The cRSI is used like a standard indicator. The chart highlights trading signals where the signal line crosses above or below the adaptive lower/upper bands. It is much more responsive to market moves than the basic RSI.

You can also review this short idea where BTC went down from 4300 USD (3 Sept 17) to 3700 USD (15 Sept 17) after the idea was posted and showed the clear short exit with the next low:
[chart]https://www.tradingview.com/chart/BTCUSD/H32ifxxo-Usage-of-an-enhanced-RSI-indicator-to-spot-turns/[/chart]

The indicator uses the dominant cycle as input to optimize signal, smoothing and cyclic memory. To get more in-depth information on the cyclic-smoothed RSI indicator, please read Chapter 4 "Fine tuning technical indicators" of the book "Decoding the Hidden Market Rhythm, Part 1" available at your favorite book store.

This is the open-source code version of the requested script already published as protected indicator back in 2017 "RSI cyclic smoothed". Now made public as v2. Would love to receive feedback and see your ideas.

---

## Source Code

````pine
//@version=4
// 
// Copyright (C) 2017 CC BY, whentotrade / Lars von Thienen
// Source:
// Book: Decoding The Hidden Market Rhythm - Part 1: Dynamic Cycles (2017)
// Chapter 4: "Fine-tuning technical indicators for more details on the cRSI Indicator
// 
// Usage: 
// You need to derive the dominant cycle as input parameter for the cycle length as described in chapter 4.
//
// License: 
// This work is licensed under a Creative Commons Attribution 4.0 International License.
// You are free to share the material in any medium or format and remix, transform, and build upon the material for any purpose, 
// even commercially. You must give appropriate credit to the authors book and website, provide a link to the license, and indicate 
// if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use. 
//
study(title="RSI cyclic smoothed", shorttitle="cRSI")
src = close
domcycle = input(20, minval=10, title="Dominant Cycle Length")
crsi = 0.0
cyclelen = domcycle / 2
vibration = 10
leveling = 10.0
cyclicmemory = domcycle * 2
//set min/max ranges?

h1 = hline(30, color=color.silver, linestyle=hline.style_dashed)
h2 = hline(70, color=color.silver, linestyle=hline.style_dashed)

torque = 2.0 / (vibration + 1)
phasingLag = (vibration - 1) / 2.0

up = rma(max(change(src), 0), cyclelen)
down = rma(-min(change(src), 0), cyclelen)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down)
crsi := torque * (2 * rsi - rsi[phasingLag]) + (1 - torque) * nz(crsi[1])

lmax = -999999.0
lmin = 999999.0
for i = 0 to cyclicmemory - 1 by 1
    if nz(crsi[i], -999999.0) > lmax
        lmax := nz(crsi[i])
        lmax
    else
        if nz(crsi[i], 999999.0) < lmin
            lmin := nz(crsi[i])
            lmin

mstep = (lmax - lmin) / 100
aperc = leveling / 100

db = 0.0
for steps = 0 to 100 by 1
    testvalue = lmin + mstep * steps
    above = 0
    below = 0
    for m = 0 to cyclicmemory - 1 by 1
        below := below + iff(crsi[m] < testvalue, 1, 0)
        below

    ratio = below / cyclicmemory
    if ratio >= aperc
        db := testvalue
        break
    else
        continue

ub = 0.0
for steps = 0 to 100 by 1
    testvalue = lmax - mstep * steps
    above = 0
    for m = 0 to cyclicmemory - 1 by 1
        above := above + iff(crsi[m] >= testvalue, 1, 0)
        above

    ratio = above / cyclicmemory
    if ratio >= aperc
        ub := testvalue
        break
    else
        continue


lowband = plot(db, "LowBand", color.aqua)
highband = plot(ub, "HighBand", color.aqua)
fill(h1, h2, color=color.silver, transp=90)
fill(lowband, highband, color=color.gray, transp=90)
plot(crsi, "CRSI", color.fuchsia)
````
