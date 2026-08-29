<!-- tradingview-pine-id: PUB;0iQhmJ87BrPf8BshqK3wXBPkhIZIE3FG -->
<!-- tradingviewscripts-format: 1 -->
# SMA Directional Matrix [LuxAlgo]

Source: https://www.tradingview.com/script/hefeKydL-SMA-Directional-Matrix-LuxAlgo/

## Description

This script was created in collaboration with alexgrover and displays a simple & elegant panel showing the direction of simple moving averages with periods in a user-selected range (Min, Max). The displayed number in the panel is the period of a simple moving average and the symbol situated at the right of it is associated with the direction this moving average is taking.

Settings

[*]Min: Minimum period of the moving average
[*]Max: Maximum period of the moving average
[*]Src: Source input of the moving averages
[*]Number Of Columns: Number of columns to be displayed in the panel, handy when using a large range of periods.

Usage

Looking at the direction of moving averages with different periods is extremely useful when it comes to having information about the short/mid/long term overall market sentiment, and can also tell us if the market is trending or ranging.

[image]https://www.tradingview.com/x/1TYlgpyT/[/image]

Here we use periods ranging from 25 to 50, we can see that shorter moving averages react to the recent upward price variation, longer-term moving averages however are still affected by the overall downward variation you can see on the image. We can as such get information about the presence of potentials divergences, with shorter-term moving averages reacting to the divergence while the longer-term moving averages will still display the direction of the main trend.

As such the indicator can give information about how clean a trend is, with a clean trend being defined as a variation containing no retracements. When our trend contains no retracement, the mid/long term moving averages will all have the same direction, however, when a retracement is present, the midterm moving averages might be affected by it, thus displaying a direction contrary to the main trend.

[image]https://www.tradingview.com/x/DMkH8mmW/[/image]

When the market is ranging we can expect the panel to display an equal number of decreasing/increasing moving averages.

Possible Issues

When using a large range of periods, you might have an error message showing: "String is too long", try lowering the range of periods by increasing Min or decreasing Max. 

If the script displays the error message "Loop is too long to execute", try resetting the settings and change them back to the one you wanted to use.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo
 
//@version=4
study("SMA Directional Matrix [LuxAlgo]",overlay=true,scale=scale.none)
min = input(15)
max = input(28)
src = input(close)
col = input(4,"Number Of Columns")
transp = input(true,"Transparent Panel")
//------------------------------------------------------------------------------
a(x)=> min(x,100) >= 10 and x < 100 ? 2 : x >= 100 ? 3 : 1
b(x,y)=> a(y) - a(x)
//------------------------------------------------------------------------------
up = "📈"
dn = "📉"
string txt = na
for i = min to max
    sym = src - src[i] > 0 ? up : dn 
    p = tostring(i)
    r = b(i,max)
    per = r == 1 ? "0"+p : r == 2 ? "00"+p : p
    space = (i - min)%col == (col-1) ? "\n" + "\n" : ""
    txt := txt + "｜" + per + " : " + sym + space
//------------------------------------------------------------------------------
n = bar_index
css = transp ? #00000000 : color.black
tss = transp ? color.gray : color.white
print(txt) => 
    var lbl = label.new(n, 1, txt, xloc.bar_index, yloc.price, css, 
      label.style_label_left, tss, size.normal, text.align_left)
    label.set_xy(lbl, n, 1), label.set_text(lbl, txt)
print(txt)
````
