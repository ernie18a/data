<!-- tradingview-pine-id: PUB;kD5LHkYsW8D6GAcsP1ZaZyeZIUghGrHc -->
<!-- tradingviewscripts-format: 1 -->
# Volume per Point

Source: https://www.tradingview.com/script/10XmHfge-Volume-per-Point/

## Description

Hello everyone <3

I present to you guys my new indicator Volume per Point (VP)

As suggested by the title, this script gives you the volume for every point. 
Here's a run down on specific features:

SUBCHART COLUMNS:
The columns can be the following four colors:
Green - There was an increase in VP
Red - There was a decrease in VP
Yellow - There was divergence between volume and candle range
Purple - There are signs of exhaustion compared to the previous candlestick

SUBCHART HISTOGRAM:
The histogram can be the following two colors:
Lime - Buying volume
Red - Selling volume

I left you guys the ability to change the multiplier on the volume in settings just incase it's too small or too big compared to the VP. Decimals are allowed!

CANDLESTICK CHART:
The candlesticks can the following two colors:
Yellow - There was a divergence between volume and candle range
Purple - There are signs of exhaustion compared to the previous candlestick

FILTERS
In the settings, you're able to add the following two filters:
RSI Filters - RSI must be below or above the specified value for the divergence or exhaustion to trigger
Percent Filters - The candlestick range or volume must be higher or lower than the specified value depending whether it's divergence or exhaustion.

This is a very helpful tool if you're interesting in reading volume. It also facilitates finding market maker activity depending on the size of the VP. Sudden abnormal spikes in VP usually do signal something and that's up for you to figure out :)

Thank you for your time to read this
~July <3

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JulyVibes

//@version=4
study("Volume per Point")

bsvol = input(title="Display Volume?", type=input.bool, defval=false, group="Multipliers")
vmul = input(title="Volume Multiplier", type=input.float, defval=1, group="Multipliers")
avp = input(title="Abnormal VP Multiplier", type=input.float, defval=2, group="Multipliers")

rf = input(title="Use RSI Filters?", type=input.bool, defval=false, group="Filters")
r1 = input(title="RSI Above", type=input.integer, defval=60, group="Filters")
r2 = input(title="RSI Below", type=input.integer, defval=40, group="Filters")

if rf
    r1 := r1
    r2 := r2
else
    r1 := 0
    r2 := 150

vf = input(title="Use Percent Filters?", type=input.bool, defval=true, group="Filters")
vper = input(title="Volume Percent Difference", type=input.integer, defval=5, group="Filters")
lper = input(title="Length Percent Difference", type=input.integer, defval=5, group="Filters")

hl = high-low
hl1 = high[1]-low[1]

nvol = volume/(hl)

rlen = input(title="RSI Length", type=input.integer, defval=14, group="Input Settings")
rsrc = input(title="RSI Source", type=input.source, defval= hl2, group="Input Settings")
vpma = input(title="MA", type=input.integer, defval=15, group="Input Settings")
ma = sma(nvol, vpma)

bvol = iff( (high==low), na, volume*(close-low)/(high-low))*vmul
svol = volume*vmul

if bsvol
    bvol := iff( (high==low), na, volume*(close-low)/(high-low))*vmul
    svol := volume*vmul
else
    bvol := na
    svol := na

dpaint = (hl < hl1) and (volume > volume[1])
epaint = (hl > hl1) and (volume < volume[1])
nvd = (nvol > nvol[1]) and (hl < hl[1])
nve = (nvol < nvol[1]) and (hl > hl[1])

adot = nvol
var color adotc = na

if ((nvol[1]*avp) < nvol) and (nvol > ma*avp)
    adot := nvol
    adotc := color(#ff0000)
else
    adot := na
    adotc := na

RSI = rsi(rsrc,rlen)

if vf
    dpaint := (hl*(lper/100+1) < hl1) and (volume > volume[1]*((vper/100)+1))
    epaint := (hl > hl1*(lper/100+1)) and (volume*((vper/100)+1) < volume[1])
else
    dpaint := dpaint
    epaint := epaint

var color a = na
var color b = na
var color c = na

if nvol > nvol[1]
    a := color.green
else
    a := color.red
    
if ((RSI > r1) or (RSI < r2)) and dpaint
    b := color.yellow
else
    b := na
    
if ((RSI > r1) or (RSI < r2)) and epaint
    c := color.purple
else
    c := na

plot(nvol, title="Net Change",color=a, linewidth=2, style=plot.style_columns)
plot(nvol, title="Volume Divergence",color=b, linewidth=2, style=plot.style_columns)
plot(nvol, title="Volume Exhaustion",color=c, linewidth=2, style=plot.style_columns)
plot(adot, title="Abnormal VP", color=adotc, linewidth=3, style=plot.style_circles)

plot(svol, title="Sell Volume", color=#e91e63, linewidth=10, style=plot.style_histogram)
plot(bvol, title="Buy Volume", color=color.lime, linewidth=10, style=plot.style_histogram)

barcolor(dpaint ? color(b) : na, title="Volume Divergence (candle)")
barcolor(epaint ? color(c) : na, title="Volume Exhaustion (candle)")

plot(ma, title="Moving Average")
````
