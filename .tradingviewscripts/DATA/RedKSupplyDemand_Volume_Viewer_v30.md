<!-- tradingview-pine-id: PUB;RwKzgMjrt0B7MSZW3rECelRlxG2urtuM -->
<!-- tradingviewscripts-format: 1 -->
# RedK_Supply/Demand Volume Viewer v3.0

Source: https://www.tradingview.com/script/kfUHOMlX-RedK-Supply-Demand-Volume-Viewer-v1/

## Description

Background
============
VolumeViewer is a volume indicator, that offers a simple way to estimate the movement and balance (or lack of) of supply & demand volume based on the shape of the price bar. i put this together few years ago and i have a version of this published for another platform under different names (Directional Volume, BetterVolume) in case you come across them

what is V.Viewer
=====================
The idea here is to find a "simple proxy" for estimating the demand or supply portions of a volume bar - these 2 forces have the potential to affect the current price trend so we want an easy way to track them - or to understand if a stock is in accumulation or distribution - we want to do this without having access to Level II or bid/ask data, and without having to get into the complexity of exploring the lower timeframe price & volume data 
- to achieve that, we depend on a simple assumption, that the volume associated with an up move is "demand" and the volume associated with a down move is "Supply".  so we basically extrapolate these supply and demand values based on how the bar looks like - a full "green" price bar / candle will be considered 100% demand, and a full "red" price bar will be considered 100% supply - a bar that opens and closes at the same level will be 50/50 split between supply & demand. 
- you may say this is a "too simple" of an assumption to make, but believe me, it works :) at least at the basic scenario we need here: i'm just exploring the volume movement and finding key levels - and it provides a good improvement compared to the classic way we see volume on a chart - which is still available here in VolumeViewer.

in all cases, i consider this to be work in progress, so i'd welcome any ideas to improve (without getting too complicated) - there's already a host of great volume-based indicators that will do the multi timeframe drill down, but that's not my scope here.

Technical Jargon & calculation
===========================
1. first we calculate a score % for the volume portion that is considered demand based on the bar shape 
skip this part if it sounds too technical =>  if you're into coding indicators, you would probably know there are couple of different concepts for that algorithm - for example, the one used in Balance Of Power formula - which i'm a big fan of - but the one i use here is different. (how?) this is my own, ant it simply applies double weight for the "wick" parts of a price bar compared to the "body of the bar" -- i did some side-by-side comparison in past and decided this one works better. you can change it in the code if you like

2. after calculating the Bull vs Bears portion of volume, we take a moving average of both for the length you set, to come up with what we consider to be the Demand vs Supply - as usual, i use a weighted moving average (WMA) here.
3. the balance or net volume between these 2 lines is calculated, then we apply a final smoothing and that's the main plot we will get
4. being a very visual person, i did my best to build up the visuals in the correct order - then also to ensure the "study title" bar is properly organized and is simple and useful (Full Volume, Supply, Demand, Net Volume). 
- i wish there was a way in Pine to hide a value that i still need to visually plot but don't want it showing its value on the study title bar, but couldn't find it. so the last plot value is repeated twice.

How to use
===========
- V.Viewer is set up to show the simplified view by default for simplicity. so when you first add it to a chart, you will get only the supply vs demand view you can see in the middle pane in the above chart
- Optional / detailed mode: go into the settings, and expose all other plots, you will be able to add the classic volume histogram, and the Supply / Demand lines - note these 2 lines will be overlay-ed on top of each other - this provides an easy way to see who is in control - especially if you change the display of these 2 lines into "area" style. This is what is showing in the lower pane in the above chart.

** Exploring Key Price Levels
- the premise is, at spots where there's big lack of balance, that's where to expect to find key price levels (support / resistance) and these price levels will come into play in future so can be used to set entry / exit targets for our trades - see the example in the AAPL chart where you can easily locate these "balance or reversal levels" using the tops/bottoms/zero-crossings from the Net Volume line

https://www.tradingview.com/x/8fIKBubo/

** Use for longer-term Price Analysis 
- we can also use this simple indicator to gain more insights (at a high level) of the price in terms of accumulation vs distribution and if the sellers or buyers are in control - for example, in the above AAPL chart, V.Viewer tells us that buyers have been in control since October 19 - even during the recent drop, demand continued to be in play - compare that to DIS chart below for the same period, where it shows that the market was dumping DIS thru the weakness. DIS was bleeding red most of the time

https://www.tradingview.com/x/lgv4k6va/

Final thoughts
=============
- V.Viewer is an attempt to enhance the way we see and use Volume by leveraging the shape of the price bar to estimate volume supply & demand - and the Net between the 2
- it will work for stocks and other instruments as long as there's volume data
- note that V.Viewer does not track trend. each bar is taken in isolation of prior bars - the price may be going down and V.Viewer is showing supply going up (absorption scenario?) - so i suggest you do not use it to make decisions without consulting other trend / momentum indicators - of course this is a possible improvement idea, or can be implemented in another indicator, add in trend somehow, or maybe think of making this a +100 / -100 Oscillator .. feel free to play with these thoughts 

- all thoughts welcome - if this is useful to you in your trading, please share with other trades here to learn from each other
- the code is commented - please feel free to use it as you like, or build things on top of it - but please continue to credit the author of this code :)

good luck!
-

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RedKTrader - May 14 2021

//@version=5
indicator(title='RedK_Supply/Demand Volume Viewer v3.0', shorttitle='V.Viewer_v3.0', format=format.volume, timeframe='', timeframe_gaps=false)

// Supply & Demand Volume Viewer calculates and plots a "price-bar-weighted" view of volume - it basically uses the shape of a price bar to estimate
// the supply vs demand shares of the traded volume, plots a moving average of both, and an estimated "net volume" 
// This provides an insightful way to look at the traded volume compared to the classic volume histogram view

// ============================================================================================================================================
// inputs
// ============================================================================================================================================
l = input.int(title='Volume Length',    defval=10,  minval=1)
s = input.int(title='Smoothing',        defval=3,   minval=1)

// ============================================================================================================================================
// variables
// ============================================================================================================================================

col_red     = color.new(#ff0000, 50)
col_green   = color.new(#00ff00, 50)
col_gold    = color.new(#ffeb3b, 50)
upday       = close > open
v           = volume

// ============================================================================================================================================
// Calc supply & Demand per Bar  .. beware of the odd case of 0 price movement during bar.. assigne equal weights to bulls & bears
// ============================================================================================================================================

Body        = math.abs(close - open)
BarRange    = high - low
Wick        = BarRange - Body
RealRange   = BarRange + Wick

BScore      = BarRange > 0 ? close >= open ? BarRange / RealRange : Wick / RealRange : 0.5
BullScore   = BScore * v
demand      = ta.wma(ta.wma(BullScore, l), s)
BearScore   = v - BullScore
supply      = ta.wma(ta.wma(BearScore, l), s)
NetVol      = demand - supply

// ============================================================================================================================================
// Plots  -- classic volume bars are hidden by default
// ============================================================================================================================================
hline(0,        title='zero line', linestyle=hline.style_dotted,    color=col_gold)  //, editable = false)
plot(v,         title='Volume',         style=plot.style_columns,   color=upday ? col_green : col_red, display=display.none)

// Net Volume Plot
plot(NetVol,    title='Volume Viewer',  style=plot.style_area,      color=NetVol >= 0 ? col_green : col_red, linewidth=4)

plot(supply,    title='Supply',         style=plot.style_circles,   color=color.new(color.orange, 0),       linewidth=2, join=true)
plot(demand,    title='Demand',         style=plot.style_cross,     color=color.new(color.aqua, 0),         linewidth=2, join=true)
````
