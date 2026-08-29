<!-- tradingview-pine-id: PUB;pns1wkQHTUwE9cWozWnENs9DraazTkKB -->
<!-- tradingviewscripts-format: 1 -->
# Sigma Spike Filtered Binned OPR

Source: https://www.tradingview.com/script/TcwiJYgr-Sigma-Spike-Filtered-Binned-OPR-Adam-H-Grimes/

## Description

As originally described by Adam H. Grimes.

For analyzing the location of Open within the day's range (OPR). The OPR histogram displays the binned distribution of OPR values for the chart history. Fat tails at the extremes indicates that Open occurred more often close to the day's high or low.

The OPR results are filtered according to volatility using Grime's Sigma Spike. So that OPR values are only recorded when volatility exceeds a threshold (relative high range days).

This may (strong emphasis on may) indicate the opportunity for trades early in the day on days that begin with a high amount of relative volatility and trading with the direction that price is moving away from the open.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rumpypumpydumpy

//@version=4
study("Sigma Spike Filtered Binned OPR", overlay=false, max_lines_count = 99)

len = input(20, title="Sigma Spike stdev length")
filtered = input(true, title="Filter by Sigma Spike Threshold?")
ss_thresh = input(2.00, title="Sigma Spike Threshold")
disp_OPR = input(true, title="display OPR distribution?")
disp_SS = input(true, title="display Sigma Spike Histogram?")
lw = input(3, title="OPR line width")
mark_thresh = input(10, title="upper / lower OPR threshold")

ret = close / close[1] -1
sdret = stdev(ret, len)
ss = ret / sdret[1]

opr = round((open - low) / (high - low) * 100)

var int[] opr_binned = array.new_int(101, 0)
var int[] xtime = array.new_int(101, 0)

for i = 0 to 100
    array.set(xtime, i, time[i])

if barstate.isconfirmed
    if filtered and abs(ss) >= ss_thresh
        array.set(opr_binned, opr, array.get(opr_binned, opr) + 1)
    else if not filtered
        array.set(opr_binned, opr, array.get(opr_binned, opr) + 1)
        
if disp_OPR
    for i = 0 to 100
        opr_line = line.new(x1 = array.get(xtime, i),
                         y1 = array.get(opr_binned, 100 - i) / array.sum(opr_binned) * 100,
                         x2 = array.get(xtime, i),
                         y2 = 0,
                         xloc = xloc.bar_time,
                         color = i <= 0 + mark_thresh ? color.red : i >= 100 - mark_thresh ? color.lime : color.white,
                         width = lw)
        line.delete(opr_line[1])

    l0 = label.new(x = array.get(xtime, 100), y = 0, text = "0", xloc=xloc.bar_time, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.tiny)
    label.delete(l0[1])
    l25 = label.new(x = array.get(xtime, 75), y = 0, text = "25", xloc=xloc.bar_time, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.tiny)
    label.delete(l25[1])
    l50 = label.new(x = array.get(xtime, 50), y = 0, text = "50", xloc=xloc.bar_time, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.tiny)
    label.delete(l50[1])
    l75 = label.new(x = array.get(xtime, 25), y = 0, text = "75", xloc=xloc.bar_time, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.tiny)
    label.delete(l75[1])
    l100 = label.new(x = array.get(xtime, 0), y = 0, text = "100", xloc=xloc.bar_time, style=label.style_label_up, color=color.white, textcolor=color.black, size=size.tiny)
    label.delete(l100[1])
    
    hl = line.new(x1 = array.get(xtime, 0),
                  y1 = 0,
                  x2 = array.get(xtime,100),
                  y2 = 0,
                  xloc = xloc.bar_time,
                  color = color.white,
                  width = 2,
                  style = line.style_dashed)
    line.delete(hl[1])


plot(disp_SS ? ss : na, style=plot.style_histogram, color=ss>= ss_thresh ? color.orange : ss <= -ss_thresh ? color.orange : color.gray)
plot(disp_SS ? -ss_thresh : na, color=color.gray)
plot(disp_SS ? ss_thresh : na , color=color.gray)
plot(disp_SS ? 0 : na, color=color.gray)
````
