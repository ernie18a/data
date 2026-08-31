<!-- tradingview-pine-id: PUB;NqwQ0xLeEEZ4WHX8lqLUMM5M9S47EICy -->
<!-- tradingviewscripts-format: 1 -->
# Support Resistance MTF

Source: https://www.tradingview.com/script/E9l1xAQd-Support-Resistance-MTF/

## Description

Hello Traders,

This is Support Resistance script that uses Multi Time Frame. While getting Close/Open/High/Low values of Higher Time Frames the script does NOT use Security function, instead it calculates them. 

while choosing Higher Time Frame, you can use "Auto" option so it uses predefined Higher Time Frames, or you can choose the Higher Time Frame Manually from the list. options for HTF => 15mins, 30mins, 60mins, 120mins, 180mins, 240mins, 720mins, Day, Week, 2 Weeks, Months, 3 Months, 6 Months, 12 Months.

You have option to use High/Low or Close/Open values while calculating support resistance levels.

"Period for Highest/Lowest Bars" option is used as loopback period to check if it's Highest/lowest bars. smaller numbers = more sensitive result.

You have option for transparency and coloring of support/resistance levels/zone => Red, Lime, Blue, White, Black, Olive, Gray

An example for 15 min chart, 4hours selected as HTF
https://www.tradingview.com/x/M0JMrPJ6/

You can set transparency and colors as you wish:
https://www.tradingview.com/x/uPqLIzOp/

You can choose Close/Open prices while calculating S/R levels instead of High/Low
https://www.tradingview.com/x/9cu86udt/

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue

//@version=4
study("Support Resistance MTF", overlay = true, max_bars_back = 4900)
src = input(defval = 'High/Low', title = "Source", options = ['High/Low', 'Close/Open'])
TimeframeU = input(defval = 'Auto', title ="Higher Time Frame", options = ['Auto', '15', '30', '60', '120', '180', '240', '720', 'D', 'W', '2W', 'M', '3M', '6M', '12M'])
prd = input(defval = 10, title = "Period for Highest/Lowest Bars", minval = 1)
resistancecol = input(defval = color.red, title = "Resistance Color")
supportcol = input(defval = color.lime, title = "Support Color")
Transp = input(defval = 80, title = "Transparency for Zones", minval = 0, maxval = 100)
extendlines = input(defval = false, title = "Extend Lines")

Timeframe = timeframe.period
if TimeframeU == 'Auto'
    Timeframe := timeframe.period == '1' ? '15' : 
           timeframe.period == '3' ? '15' :
           timeframe.period == '5' ? '60' : 
           timeframe.period == '15' ? '60' : 
           timeframe.period == '30' ? '120' : 
           timeframe.period == '45' ? '120' : 
           timeframe.period == '60' ? '240' : 
           timeframe.period == '120' ? 'D' : 
           timeframe.period == '180' ? 'D' : 
           timeframe.period == '240' ? 'D' : 
           timeframe.period == 'D' ? 'W' :
           timeframe.period == 'W' ? 'M' :
           '12M'
else
    Timeframe := TimeframeU
    
var float hc = na
var float lc = na
srch = src == 'High/Low' ? high : max(close, open)
srcl = src == 'High/Low' ? low : min(close, open)
hc := highestbars(srch, prd) == 0 ? srch : hc
lc := lowestbars(srcl, prd) == 0 ? srcl : lc

hcp = plot(hc, color = hc == hc[1] ? resistancecol : na)
lcp = plot(lc, color = lc == lc[1] ? supportcol : na)

bool newbar = change(time(Timeframe)) != 0
var float htfh = na
var float htfl = na
if newbar
    htfh := srch
    htfl := srcl
else
    htfh := max(htfh, srch)
    htfl := min(htfl, srcl)

highestbar(src, len)=>
    ll = 1
    if len > 1
        for x = 0 to 4000
            if na(newbar[x]) or na(close[x + 1])
                break
            if newbar[x]
                if src <= src[x + 1]
                    break
                ll := ll + 1
                if ll >= len
                    break
    ret = ll >= len

lowestbar(src, len)=>
    ll = 1
    if len > 1
        for x = 0 to 4000
            if na(newbar[x]) or na(close[x + 1])
                break
            if newbar[x]
                if src >= src[x + 1]
                    break
                ll := ll + 1
                if ll >= len
                    break
    ret = ll >= len
    
var float hh = 0
var float ll = 0
bool hbar = highestbar(htfh, prd)
bool lbar = lowestbar(htfl, prd)
hh := hbar ? htfh : hh
ll := lbar ? htfl : ll

hhp = plot(hh, color = hh == hh[1] ? resistancecol : na)
llp = plot(ll, color = ll == ll[1] ? supportcol : na)

fill(hhp, hcp, color = hc == hc[1] and hh == hh[1] ? color.new(resistancecol, Transp) : na)
fill(llp, lcp, color = lc == lc[1] and ll == ll[1] ? color.new(supportcol, Transp) : na)
 
// extend lines
if extendlines
    var line s1 = na
    var line s2 = na
    var line r1 = na
    var line r2 = na
    line.delete(s1)
    line.delete(s2)
    line.delete(r1)
    line.delete(r2)
    s1 := line.new(bar_index, lc, bar_index - 1, lc, color = supportcol, extend = extend.left)
    s2 := line.new(bar_index, ll, bar_index - 1, ll, color = supportcol, extend = extend.left)
    r1 := line.new(bar_index, hc, bar_index - 1, hc, color = resistancecol, extend = extend.left)
    r2 := line.new(bar_index, hh, bar_index - 1, hh, color = resistancecol, extend = extend.left)
````
