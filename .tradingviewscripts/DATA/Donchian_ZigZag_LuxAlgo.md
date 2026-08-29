<!-- tradingview-pine-id: PUB;2oaho9jA3rLsBLqfsenn6XL6oQAcv2S2 -->
<!-- tradingviewscripts-format: 1 -->
# Donchian Zig-Zag [LuxAlgo]

Source: https://www.tradingview.com/script/Nj6CMJkP-Donchian-Zig-Zag-LuxAlgo/

## Description

The following indicator returns a line bouncing of the extremities of a Donchian channel, with the aim of replicating a "zig-zag" indicator. The indicator can both be lagging or lagging depending on the settings user uses.

Various extended lines are displayed in order to see if the peaks and troughs made by the Donchian zig-zag can act as potential support/resistance lines.

User Settings

[*]Length : Period of the Donchian channel indicator, higher values will return fewer changes of directions from the zig-zag line 
[*] Bounce Speed : Determine the speed of bounces made by the zig-zag line, with higher values making the zig-zag line converge faster toward the extremities of the Donchian channel.
[*]Gradient : Determine whether to use a gradient to color the area between each Donchian channel extremities, "On" by default.
[*]Transparency : Transparency of the area between each Donchian channel extremities.

Usage

It is clear that this is not a very common indicator to see, as such usages can be limited and very hypothetical. Nonetheless, when a bounce speed value of 1 is used, the zig-zag line will have the tendency to lag behind the price, and as such can provides crosses with the prices which can provide potential entries. 

The advantage of this approach against most indicators relying on crosses with the price is that the linear nature of the indicator allows avoiding retracements, thus potentially holding a position for the entirety of the trend.

[image]https://www.tradingview.com/x/RHBuqD8e/[/image]

Altho this indicator would not necessarily be the most adapted to this kind of usage.

When using a bounce speed superior to 1, we can see the predictive aspects of the indicator:

[image]https://www.tradingview.com/x/KPkCeh92/[/image]

We can link the peaks/troughs made by the zig-zag with the precedent ones made to get potential support and resistance lines, while such a method is not necessarily accurate it still allows for an additional to interpret the indicator.

[image]https://www.tradingview.com/x/heJoD4QK/[/image]

Conclusions

We presented an indicator aiming to replicate the behaviour of a zig-zag indicator. While somehow experimental, it has the benefits of being innovative and might inspire users in one way or another.

---

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=4
study("Donchian Zig-Zag [LuxAlgo]",overlay=true)
h1       = input(true ,"───────── Indicator Settings ─────────")
length = input(50)
src    = input(close)
bsp    = input(1.,"Bounce Speed",minval=1)
h2       = input(true ,"────────── Plot Settings ───────────")
gradient = input("On" ,"  Gradient",options=["On","Off"])
transp   = input(80 ,"  Transparency",minval=0,maxval=100)
//──────────────────────────────────────────────────────────────────────────────
zigzag = 0.,osc = 0
var css = array.new_color(na)
if barstate.isfirst
    array.push(css,#FF1100), array.push(css,#FF1200), array.push(css,#FF1400), array.push(css,#FF1500), array.push(css,#FF1700), array.push(css,#FF1800), array.push(css,#FF1A00), array.push(css,#FF1B00), array.push(css,#FF1D00), array.push(css,#FF1F00), array.push(css,#FF2000), array.push(css,#FF2200), array.push(css,#FF2300), array.push(css,#FF2500), array.push(css,#FF2600), array.push(css,#FF2800), array.push(css,#FF2900), array.push(css,#FF2B00), array.push(css,#FF2D00), array.push(css,#FF2E00), array.push(css,#FF3000), array.push(css,#FF3100), array.push(css,#FF3300), array.push(css,#FF3400), array.push(css,#FF3600), array.push(css,#FF3700), array.push(css,#FF3900), array.push(css,#FF3B00), array.push(css,#FF3C00), array.push(css,#FF3E00), array.push(css,#FF3F00), array.push(css,#FF4100), array.push(css,#FF4200), array.push(css,#FF4400), array.push(css,#FF4500), array.push(css,#FF4700), array.push(css,#FF4900), array.push(css,#FF4A00), array.push(css,#FF4C00), array.push(css,#FF4D00), array.push(css,#FF4F00), array.push(css,#FF5000), array.push(css,#FF5200), array.push(css,#FF5300), array.push(css,#FF5500), array.push(css,#FF5700), array.push(css,#FF5800), array.push(css,#FF5A00), array.push(css,#FF5B00), array.push(css,#FF5D00), array.push(css,#FF5E00), array.push(css,#FF6000), array.push(css,#FF6200), array.push(css,#FF6300), array.push(css,#FF6500), array.push(css,#FF6600), array.push(css,#FF6800), array.push(css,#FF6900), array.push(css,#FF6B00), array.push(css,#FF6C00), array.push(css,#FF6E00), array.push(css,#FF7000), array.push(css,#FF7100), array.push(css,#FF7300), array.push(css,#FF7400), array.push(css,#FF7600), array.push(css,#FF7700), array.push(css,#FF7900), array.push(css,#FF7A00), array.push(css,#FF7C00), array.push(css,#FF7E00), array.push(css,#FF7F00), array.push(css,#FF8100), array.push(css,#FF8200), array.push(css,#FF8400), array.push(css,#FF8500), array.push(css,#FF8700), array.push(css,#FF8800), array.push(css,#FF8A00), array.push(css,#FF8C00), array.push(css,#FF8D00), array.push(css,#FF8F00), array.push(css,#FF9000), array.push(css,#FF9200), array.push(css,#FF9300), array.push(css,#FF9500), array.push(css,#FF9600), array.push(css,#FF9800), array.push(css,#FF9A00), array.push(css,#FF9B00), array.push(css,#FF9D00), array.push(css,#FF9E00), array.push(css,#FFA000), array.push(css,#FFA100), array.push(css,#FFA300), array.push(css,#FFA400), array.push(css,#FFA600), array.push(css,#FFA800), array.push(css,#FFA900), array.push(css,#FFAB00), array.push(css,#FDAC00), array.push(css,#FBAD02), array.push(css,#F9AE03), array.push(css,#F7AE04), array.push(css,#F5AF06), array.push(css,#F3B007), array.push(css,#F1B108), array.push(css,#EFB20A), array.push(css,#EDB30B), array.push(css,#EBB30C), array.push(css,#E9B40E), array.push(css,#E7B50F), array.push(css,#E4B610), array.push(css,#E2B712), array.push(css,#E0B813), array.push(css,#DEB814), array.push(css,#DCB916), array.push(css,#DABA17), array.push(css,#D8BB18), array.push(css,#D6BC1A), array.push(css,#D4BD1B), array.push(css,#D2BD1C), array.push(css,#D0BE1E), array.push(css,#CEBF1F), array.push(css,#CCC020), array.push(css,#C9C122), array.push(css,#C7C223), array.push(css,#C5C224), array.push(css,#C3C326), array.push(css,#C1C427), array.push(css,#BFC528), array.push(css,#BDC62A), array.push(css,#BBC72B), array.push(css,#B9C72C), array.push(css,#B7C82E), array.push(css,#B5C92F), array.push(css,#B3CA30), array.push(css,#B0CB32), array.push(css,#AECC33), array.push(css,#ACCC34), array.push(css,#AACD36), array.push(css,#A8CE37), array.push(css,#A6CF38), array.push(css,#A4D03A), array.push(css,#A2D13B), array.push(css,#A0D13C), array.push(css,#9ED23E), array.push(css,#9CD33F), array.push(css,#9AD440), array.push(css,#98D542), array.push(css,#95D643), array.push(css,#93D644), array.push(css,#91D746), array.push(css,#8FD847), array.push(css,#8DD948), array.push(css,#8BDA4A), array.push(css,#89DB4B), array.push(css,#87DB4C), array.push(css,#85DC4E), array.push(css,#83DD4F), array.push(css,#81DE50), array.push(css,#7FDF52), array.push(css,#7CE053), array.push(css,#7AE054), array.push(css,#78E156), array.push(css,#76E257), array.push(css,#74E358), array.push(css,#72E45A), array.push(css,#70E55B), array.push(css,#6EE55C), array.push(css,#6CE65E), array.push(css,#6AE75F), array.push(css,#68E860), array.push(css,#66E962), array.push(css,#64EA63), array.push(css,#61EA64), array.push(css,#5FEB66), array.push(css,#5DEC67), array.push(css,#5BED68), array.push(css,#59EE6A), array.push(css,#57EF6B), array.push(css,#55EF6C), array.push(css,#53F06E), array.push(css,#51F16F), array.push(css,#4FF270), array.push(css,#4DF372), array.push(css,#4BF473), array.push(css,#48F474), array.push(css,#46F576), array.push(css,#44F677), array.push(css,#42F778), array.push(css,#40F87A), array.push(css,#3EF97B), array.push(css,#3CF97C), array.push(css,#3AFA7E), array.push(css,#38FB7F), array.push(css,#36FC80), array.push(css,#34FD82), array.push(css,#32FE83), array.push(css,#30FF85),
//──────────────────────────────────────────────────────────────────────────────
upper = highest(src,length),lower = lowest(src,length)
crossupper = cross(nz(zigzag[1],src),upper)
crosslower = cross(nz(zigzag[1],src),lower)
osc := crossupper ? -1 : crosslower ? 1 : osc[1]
val = valuewhen(change(osc),upper - lower,0)
zigzag := nz(zigzag[1],src) + osc*val/length*bsp
//──────────────────────────────────────────────────────────────────────────────
n = bar_index
var line extention = na
if change(osc)
    extention := line.new(n[1],zigzag[1],n,zigzag,
      extend=extend.right,color=#2157f3,style=line.style_dashed)
//──────────────────────────────────────────────────────────────────────────────
norm_css = sma(max(min((src-lower)/(upper - lower),1),0),length)
plot(zigzag,"Plot",#2157f3,2)
up = plot(upper,"Upper",na,1,editable=false)
dn = plot(lower,"Lower",na,1,editable=false)
fill(up,dn,gradient == "On" ? array.get(css,round(norm_css*199)) : 
  color.gray,transp,editable=false)
````
