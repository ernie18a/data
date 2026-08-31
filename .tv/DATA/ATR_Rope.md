<!-- tradingview-pine-id: PUB;00e084d63d2943b5951bb7420b6bfa85 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Rope

Source: https://www.tradingview.com/script/YYrxRhi9-ATR-Rope/

## Description

ATR Rope is inspired by DonovanWall's "Range Filter". It implements a similar concept of filtering out smaller market movements and adjusting only for larger moves. In addition, this indicator goes one step deeper by producing actionable zones to determine market state. (Trend vs. Consolidation)

> Background

When reading up on the Range Filter indicator, it reminded me exactly of a Rope stabilization drawing tool in a program I use frequently. Rope stabilization essentially attaches a fixed length "rope" to your cursor and an anchor point (Brush). As you move your cursor, you are pulling the brush behind it. The cursor (of course) will not pull the brush until the rope is fully extended, this behavior filters out jittery movements and is used to produce smoother drawing curves.

If compared visually side-by-side, you will notice that this indicator bears striking resemblance to its inspiration.

> Goal

Other than simply distinguishing price movements between meaningful and noise, this indicator strives to create a rigid structure to frame market movements and lack-there-of, such as when to anticipate trend, and when to suspect consolidation.

Since the indicator works based on an ATR range, the resulting ATR Channel does well to get reactions from price at its extremes. Naturally, when consolidating, price will remain within the channel, neither pushing the channel significantly up or down. Likewise, when trending, price will continue to push the channel in a single direction.

With the goal of keeping it quick and simple, this indicator does not do any smoothing of data feeds, and is simply based on the deviation of price from the central rope. Adjusting the rope when price extends past the threshold created by +/- ATR from the rope.

> Features & Behaviors

- ATR Rope
ATR Rope is displayed as a 3 color single line.
This can be considered the center line, or the directional line, whichever you'd prefer.
The main point of the Rope display is to indicate direction, however it also is factually the center of the current working range.

- ATR Rope Color
When the rope's value moves up, it changes to green (uptrend), when down, red (downtrend).
When the source crosses the rope, it turns blue (flat).

With these simple rules, we've formed a structure to view market movements.

- Consolidation Zones
Consolidation Zones generate from "Flat" areas, and extend into subsequent trend areas. Consolidation is simply areas where price has crossed the Rope and remains inside the range. Over these periods, the upper and lower values are accumulated and averaged together to form the "Consolidation Zone" values. These zones are draw live, so values are averaged as the flat areas progress and don't repaint, so all values seen historically are as they would appear live. 

- ATR Channel
ATR Channel displays the upper and lower bounds of the working range.
When the source moves beyond this range, the rope is adjusted based on the distance from the source to the channel. This range can be extremely useful to view, but by default it is hidden.

> Application

This indicator is not created to provide signals, or serve as a "complete" system. 
(People who didn't read this far will still comment for signals. :) )

This is created to be used alongside manual interpretation and intuition. This indicator is not meant to constrain any users into a box, and I would actually encourage an open mind and idea generation, as the application of this indicator can take various forms.

> Examples

As you would probably already know, price movement can be fast impulses, and movement can be slow bleeds. In the screenshot below, we are using movements from and to consolidation zones to classify weak trend and strong trend. As you can see, there are also areas of consolidation which get broken out of and confirmed for the larger moves.

Author's Note: In each of these examples, I have outlined the start and end of each session. These examples come from 1 Min Future charts, and have specifically been framed with day trading in mind.

[image]https://www.tradingview.com/x/nOgUnOFr/[/image]

"Breakout Retest" or "Support/Resistance Flips" or "Structure Retests" are all generally the same thing, with different traders referring to them by different names, all of which can be seen throughout these examples.

In the next example, we have a day which started with an early reversal leading into long, slow,  trend. Notice how each area throughout the trend essentially moves slightly higher, then consolidates while holding support of the previous zone. This day had a few sharp movements, however there was a large amount of neutrality throughout this day with continuous higher lows.

[image]https://www.tradingview.com/x/ZJ3Ga4qM/[/image]

In contrast to the previous example, next up, we have a very choppy day. Throughout which we see a significant amount of retests before fast directional movements. We also see a few examples of places where previous zones remained relevant into the future. While the zones only display into the resulting trend area, they do not become immediately meaningless once they stop drawing.

[image]https://www.tradingview.com/x/ruNDQNGA/[/image]

> Abstract

In the screenshot below, I have stacked 2 of these indicators, using the high as the source for one and the low as the source for the other. I've hidden lines of the high and low channels to create a 4 lined channel based on the wicks of price.

[image]https://www.tradingview.com/x/AgySjcGZ/[/image]

This is not necessary to use the indicator, but should help provide an idea of creative ways the simple indicator could be used to produce more complicated analysis.

If you've made it this far, I would hope it's clear to you how this indicator could provide value to your trading. 

Thank you to DonovonWall for the inspiration.

Enjoy!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SamRecio

//@version=6
indicator("ATR Rope", overlay = true)

///_____________________________________________________________________________________________________________________
///Inputs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

var params = "Parameters"
src = nz(input.source(close, title = "Source", group = params))
len = input.int(14, title = "ATR Len", group = params)
multi = input.float(1.5, title = "Multi", step = 0.25, minval = 0, group = params)

var disp = "Display"
rng_tog = input.bool(true, title = "Consolidation Ranges", group = disp)
atr_tog = input.bool(false, title = "ATR Channel", group = disp)

var cols = "Colors"
up_col = input.color(#3daa45, title = "Up Color", group = cols)
down_col = input.color(#ff033e, title = "Down Color", group = cols)
flat_col = input.color(#004d92, title = "Flat Color", inline = "3", group = cols)
rng_col = input.color(#004d9233, title = "", inline = "3", group = cols)

///_____________________________________________________________________________________________________________________
///Function
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//Smooths a Source similar to Rope Stabilization in a Drawing Application. OR a "Range Filter" as some might say ;)
rope_smoother(float _src, float _threshold) =>

    var float _rope = _src

    _move = _src - _rope //Movement from Rope

    _rope += math.max(math.abs(_move) - nz(_threshold), 0) * math.sign(_move) //Directional Movement beyond the Threshold
    
    [_rope,_rope+_threshold,_rope-_threshold] //[Rope, Upper, Lower]

///_____________________________________________________________________________________________________________________
///Rope Calcs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//Calculating Rope
atr = ta.atr(len)*multi

[rope,upper,lower] = rope_smoother(src,atr)

//Directional Detection
var dir = 0

dir := rope > rope[1] ? 1 : rope < rope[1] ? -1 : dir

if ta.cross(src,rope)
    dir := 0

//Directional Color Assignment    
col = dir > 0 ? up_col : dir < 0 ? down_col : flat_col

///_____________________________________________________________________________________________________________________
///Consolidation Ranges
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//High and Low Output Lines
var float c_hi = na
var float c_lo = na

//Counters for Accumulating Averages
var float h_sum = 0
var float l_sum = 0
var int c_count = 0

//Flip-Flop
var ff = true

//Flip Flop, Pip Slip Top,
//Bear Drop, Bull Pop, Lunch Time Chop,
//Tight Stop, Desktop Prop.
if dir == 0

    if dir[1] != 0
        h_sum := 0
        l_sum := 0
        c_count := 0
        ff := not ff

    h_sum += upper
    l_sum += lower
    c_count += 1
    c_hi := h_sum/c_count
    c_lo := l_sum/c_count

///_____________________________________________________________________________________________________________________
///Display
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//Rope
plot(rope, linewidth = 3, color = col, title = "Rope", force_overlay = true)

//Channel
plot(upper, display = atr_tog?display.all:display.none, color = col, title = "Upper", force_overlay = true)
plot(lower, display = atr_tog?display.all:display.none, color = col,  title = "Lower", force_overlay = true)

//Consolidation Ranges

h1 = plot(ff?na:c_hi, style = plot.style_linebr, color = color.new(rng_col,0), display = rng_tog?display.all:display.none, title = "Range High 1")
l1 = plot(ff?na:c_lo, style = plot.style_linebr, color = color.new(rng_col,0), display = rng_tog?display.all:display.none, title = "Range Low 1")

h2 = plot(ff?c_hi:na, style = plot.style_linebr, color = color.new(rng_col,0), display = rng_tog?display.all:display.none, title = "Range High 2")
l2 = plot(ff?c_lo:na, style = plot.style_linebr, color = color.new(rng_col,0), display = rng_tog?display.all:display.none, title = "Range Low 2")

fill(h1,l1,rng_col, display = rng_tog?display.all:display.none, title = "Range 1 Fill")
fill(h2,l2,rng_col, display = rng_tog?display.all:display.none, title = "Range 2 Fill")
````
