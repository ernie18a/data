<!-- tradingview-pine-id: PUB;vROeQSQlNsz6xvzeE2beg18o10DaGkZR -->
<!-- tradingviewscripts-format: 1 -->
# Extrapolated Pivot Connector

Source: https://www.tradingview.com/script/CtjX82Hp-Extrapolated-Pivot-Connector-Lets-Make-Support-And-Resistances/

## Description

Introduction

The support and resistance methodology remain the most used one in technical analysis, this is mainly due to its simplicity, and unlike lots of techniques used in technical analysis support and resistances have a certain logic, price can sometimes appear moving into a channel, support and resistances allow the trader to estimate such channel and project it into the future in order to spot points where price might reverse direction. 

In this script a simple linear support and resistance indicator is proposed, the indicator is made by connecting past pivot high's/low's to more recent ones and extrapolating the resulting connection. The indicator is also able to make support and resistances by using other indicators as input.

Indicator Settings 

The indicator include various settings, the first one being the length setting who determine the sensitivity of the pivot high/low detection, low values of length will detect the pivot high/low of noisy variations, while higher values will detect the pivot high/low of longer term variations.

[image]https://www.tradingview.com/x/CQKGTofK/[/image]

The figure above use length = 5.

The A-High parameter determine the position of the pivot high to be used as first point of the resistance line, higher values will use oldest pivot high's as first point. The B-High parameter determine the last pivot high. A-Low and B-Low work the same way but affect the support line, a label is drawn on the chart in order to help you determine the position of A/B-High/Low.

Using Other Indicators Output As Input

The "Use Custom Source" option allow you to apply the indicator to other indicators, for example we can use a moving average of period 50 as input 

[image]https://www.tradingview.com/x/s3JfGBnJ/[/image]

Or the rsi :

[image]https://www.tradingview.com/x/2KooauDD/[/image]

Let me help you set the proposed indicator easily to indicators appearing on a separate window, for example the momentum oscillator, add the momentum oscillator to the chart, to do so click on indicator and search "momentum", click on the first result, once on the chart put your mouse pointer on the indicator title, you'll see appearing the hide, settings and delete option, at the right of delete you should see three dots which represent the "more" option, click on it and select "Add indicator on Mom" and select the extrapolated pivot indicator, you can do that by searching it, altho it might be easier to do it by adding the indicator to favorites first, you then only need to select it from your favorites.

You might see a mess on the indicator window, thats because the extrapolated pivot is still using high and low as input, go to the settings of the extrapolated pivot indicator and check "Use Custom Source", it should appear properly now.

[image]https://www.tradingview.com/x/MdgFzPCv/[/image]

Tips And Tricks When Using Support And Resistances

[image]https://www.tradingview.com/x/yB9K5cuB/[/image]

Linear support and resistances assume an approximately linear trend, if you see non linear growth in the price evolution you can use a logarithmic scale in order to have a more linear evolution. To do so right click on the the chart scale and select "Logarithmic" or use the following key shortcut "alt + l".

When applying the indicator to an oscillator centered around zero make sure to adjust the settings of the oscillator such that the peak magnitude of the oscillator is relatively constant over time.

[image]https://www.tradingview.com/x/Y47wj1Ao/[/image]

Here a roc of period 9 has non constant peak amplitude, you can see that by looking at the position of the pivots (circles), increasing the period of the roc help capture more significant pivots high's/low's

[image]https://www.tradingview.com/x/JUylIdAD/[/image]

Conclusion

In this post an indicator aiming to draw support and resistances is presented, the fact that it can be applied to any other indicator is a relatively nice option, and i hope you might make use of this feature. 

The code make heavy use of the new features that where integrated on the v4 of pine, such features are really focused on making figures and labels, things i don't really work with, but it is nice to step out my short codes habits, and i don't exclude working with figures in pine in the future. 

Thanks for reading !

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alexgrover
//@version=4
study("Extrapolated Pivot Connector",overlay=true,max_bars_back=5000)
//----
length = input(100)
astart = input(1,"A-High Position"),aend = input(0,"B-High Position")
bstart = input(1,"A-Low Position"),bend = input(0,"B-Low Position")
csrc = input(false,"Use Custom Source ?"),src = input(close,"Custom Source")
//----
up = pivothigh(iff(csrc,src,high),length,length)
dn = pivotlow(iff(csrc,src,low),length,length)
//----
n = bar_index
a1 = valuewhen(not na(up),n,astart)
b1 = valuewhen(not na(dn),n,bstart)
a2 = valuewhen(not na(up),n,aend)
b2 = valuewhen(not na(dn),n,bend)
//----
line upper = line.new(n[n - a1 + length],up[n - a1],n[n - a2 + length],up[n - a2],
  extend=extend.right,color=color.blue,width=2)
line lower = line.new(n[n - b1 + length],dn[n - b1],n[n - b2 + length],dn[n - b2],
  extend=extend.right,color=color.orange,width=2)
line.delete(upper[1])
line.delete(lower[1])
//----
label ahigh = label.new(n[n - a1 + length],up[n - a1],"A-High",
  color=color.blue,style=label.style_labeldown,textcolor=color.white,size=size.small)
label bhigh = label.new(n[n - a2 + length],up[n - a2],"B-High",
  color=color.blue,style=label.style_labeldown,textcolor=color.white,size=size.small)
label alow = label.new(n[n - b1 + length],dn[n - b1],"A-Low",
  color=color.orange,style=label.style_labelup,textcolor=color.white,size=size.small)
label blow = label.new(n[n - b2 + length],dn[n - b2],"B-Low",
  color=color.orange,style=label.style_labelup,textcolor=color.white,size=size.small)
label.delete(ahigh[1]),label.delete(bhigh[1]),label.delete(alow[1]),label.delete(blow[1])
//----
plot(up,"Pivot High's",color.blue,4,style=plot.style_circles,transp=0,offset=-length,join=true)
plot(dn,"Pivot Low's",color.orange,4,style=plot.style_circles,transp=0,offset=-length,join=true)
````
