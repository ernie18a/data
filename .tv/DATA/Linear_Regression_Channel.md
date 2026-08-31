<!-- tradingview-pine-id: PUB;jiDgL4o6Qxmpn0uOAMy46uK3NBhGDNhx -->
<!-- tradingviewscripts-format: 1 -->
# Linear Regression Channel

Source: https://www.tradingview.com/script/efXI515C-Linear-Regression-Channel/

## Description

Hello Traders,

There are several nice Linear Regression Channel scripts in the Public Library. and I tried to make one with some extra features too. This one can check if the Price breaks the channel and it shows where is was broken. Also it checks the momentum of the channel and shows it's increasing/decreasing/equal in a label, shape of the label also changes. The line colors change according to direction.

using the options, you can;
- Set the Source (Close, HL2 etc)
- Set the Channel length
- Set Deviation
- Change Up/Down Line colors
- Show/hide broken channels
- Change line width

meaning of arrows:
⇑ : Uptrend and moment incresing
⇗ : Uptrend  and moment decreasing
⇓ : Downtrend and moment incresing
⇘ : Downtrend and moment decreasing
⇒ : No trend

An example for how color of lines, arrow direction and shape of label change.
https://www.tradingview.com/x/SdoijsaM/

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue

//@version=4
study("Linear Regression Channel", overlay = true, max_bars_back = 1000, max_lines_count = 300)
src = input(defval = close, title = "Source")
len = input(defval = 100, title = "Length", minval = 10)
devlen = input(defval = 2., title = "Deviation", minval = 0.1, step = 0.1)
extendit = input(defval = true, title = "Extend Lines")
showfibo = input(defval = false, title = "Show Fibonacci Levels")
showbroken = input(defval = true, title = "Show Broken Channel", inline = "brk")
brokencol = input(defval = color.blue, title = "", inline = "brk")
upcol = input(defval = color.lime, title = "Up/Down Trend Colors", inline = "trcols")
dncol = input(defval = color.red, title = "", inline = "trcols")
widt = input(defval = 2, title = "Line Width")

var fibo_ratios = array.new_float(0)
var colors = array.new_color(2)
if barstate.isfirst
    array.unshift(colors, upcol)
    array.unshift(colors, dncol)
    array.push(fibo_ratios, 0.236)
    array.push(fibo_ratios, 0.382)
    array.push(fibo_ratios, 0.618)
    array.push(fibo_ratios, 0.786)


get_channel(src, len)=>
    mid = sum(src, len) / len
    slope = linreg(src, len, 0) - linreg(src, len, 1)
    intercept  = mid - slope * floor(len / 2) + ((1 - (len % 2)) / 2) * slope
    endy = intercept  + slope * (len - 1) 
    dev = 0.0
    for x = 0 to len - 1
        dev := dev + pow(src[x] - (slope * (len - x) + intercept), 2)
    dev := sqrt(dev/len)
    [intercept, endy, dev, slope]

[y1_, y2_, dev, slope] = get_channel(src, len)

outofchannel = (slope > 0 and close < y2_ - dev * devlen) ? 0 : (slope < 0 and close > y2_ + dev * devlen) ? 2 : -1

var reglines = array.new_line(3)
var fibolines = array.new_line(4)
for x = 0 to 2
    if not showbroken or outofchannel != x or nz(outofchannel[1], -1) != -1
        line.delete(array.get(reglines, x))
    else
        line.set_color(array.get(reglines, x), color = brokencol)
        line.set_width(array.get(reglines, x), width = 2)
        line.set_style(array.get(reglines, x), style = line.style_dotted)
        line.set_extend(array.get(reglines, x), extend = extend.none)
    
    array.set(reglines, x, 
              line.new(x1 = bar_index - (len - 1), 
                       y1 = y1_ + dev * devlen * (x - 1), 
                       x2 = bar_index, 
                       y2 = y2_ + dev * devlen * (x - 1),
                       color = array.get(colors, round(max(sign(slope), 0))),
                       style =  x % 2 == 1 ? line.style_solid : line.style_dashed,
                       width = widt,
                       extend = extendit ? extend.right : extend.none))
if showfibo
    for x = 0 to 3
        line.delete(array.get(fibolines, x))
        array.set(fibolines, x, 
                  line.new(x1 = bar_index - (len - 1), 
                           y1 = y1_ - dev * devlen + dev * devlen * 2 * array.get(fibo_ratios, x), 
                           x2 = bar_index, 
                           y2 = y2_ - dev * devlen + dev * devlen * 2 * array.get(fibo_ratios, x),
                           color = array.get(colors, round(max(sign(slope), 0))),
                           style =  line.style_dotted,
                           width = widt,
                           extend = extendit ? extend.right : extend.none))
    
var label sidelab = label.new(x = bar_index - (len - 1), y = y1_, text = "S",  size = size.large)
txt = slope > 0 ? slope > slope[1] ? "⇑" : "⇗" : slope < 0 ? slope < slope[1] ? "⇓" : "⇘" : "⇒"
stl = slope > 0 ? slope > slope[1] ? label.style_label_up : label.style_label_upper_right : slope < 0 ? slope < slope[1] ? label.style_label_down :  label.style_label_lower_right : label.style_label_right
label.set_style(sidelab, stl)
label.set_text(sidelab, txt)
label.set_x(sidelab, bar_index - (len - 1))
label.set_y(sidelab, slope > 0 ? y1_ - dev * devlen : slope < 0 ? y1_ + dev * devlen : y1_)
label.set_color(sidelab, slope > 0 ? upcol : slope < 0 ? dncol : color.blue)

alertcondition(outofchannel, title='Channel Broken', message='Channel Broken')

// direction
trendisup = sign(slope) != sign(slope[1]) and slope > 0
trendisdown = sign(slope) != sign(slope[1]) and slope < 0
alertcondition(trendisup, title='Up trend', message='Up trend')
alertcondition(trendisdown, title='Down trend', message='Down trend')
````
