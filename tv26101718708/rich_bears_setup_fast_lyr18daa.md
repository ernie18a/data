# Rich Bears Setup Fast

- url: https://www.tradingview.com/script/Lyr18dAA-rich-bears-setup-fast/
- type: indicator
- pine_id: PUB;5ad88705bd554781a9a9c6c701d5ecd7
- version: 1.0

## Description

Rich Bears Setup Fast is a manual trade-plan overlay. It draws a user-specified entry zone, stop and two or three targets with compact labels and muted risk/reward areas. It does not generate signals, execute orders, evaluate confirmation conditions or track fills.

Input format:
SYMBOL|long/short|entryLow|entryHigh|stop|target1|target2|target3|startMs|endMs

Use the exact chart ticker, for example ETHUSDT.P. Prices use a dot as decimal separator. Set target3 to 0 to disable it. Times are Unix timestamps in milliseconds. Example parameters are illustrative, not trade recommendations.

The overlay appears only when the packet has ten fields, the ticker matches and the basic directional price ordering is valid. For long plans the stop is below the entry zone and targets are above; short plans use the reverse. The third target, when used, must be set beyond target2 by the user.

Open indicator settings, paste your reviewed packet into Пакет сетапа and apply. Adjust the price scale to keep all levels visible. Labels follow the visible chart window. Plans and market data must be reviewed independently; this drawing tool does not determine whether a trade is suitable or profitable.

## Source Code

````pine
//@version=6
indicator("Rich Bears · Setup Fast", overlay=true, max_lines_count=20, max_labels_count=20, max_boxes_count=5)
packet = input.string("", "Пакет сетапа")
f = str.split(packet, "|")
get(int n) =>
    array.size(f) > n ? str.trim(array.get(f, n)) : ""
num(int n) =>
    str.tonumber(get(n))
lo = num(2)
hi = num(3)
sl = num(4)
t1 = num(5)
t2 = num(6)
t3 = num(7)
a = int(num(8))
b = int(num(9))
longSide = get(1) == "long"
valid = array.size(f) == 10 and get(0) == syminfo.ticker and lo > 0 and hi >= lo and b > a and (longSide ? sl < lo and sl > 0 and t1 > hi and t2 > t1 : get(1) == "short" and sl > hi and t1 < lo and t2 < t1 and t2 > 0)
ec = color.rgb(151,163,197)
sc = color.rgb(192,115,129)
tc = color.rgb(103,171,158)
x = math.max(a, math.min(b, chart.right_visible_bar_time - int(timeframe.in_seconds()*2000)))
var line[] ls = array.new_line()
var label[] lbs = array.new_label()
var box[] bs = array.new_box()
var table brand = table.new(position.bottom_right,1,1)
level(float p, string title, color c) =>
    array.push(ls,line.new(a,p,b,p,xloc=xloc.bar_time,color=color.new(c,25)))
    array.push(lbs,label.new(x,p,title+" · "+str.tostring(p,format.mintick),xloc=xloc.bar_time,style=label.style_label_right,color=color.rgb(19,23,34),textcolor=c,size=size.small))
if barstate.islast
    for l in ls
        line.delete(l)
    array.clear(ls)
    for l in lbs
        label.delete(l)
    array.clear(lbs)
    for z in bs
        box.delete(z)
    array.clear(bs)
    table.cell(brand,0,0,"RICH BEARS",text_color=ec,text_size=size.normal)
    if valid
        mid = (lo+hi)/2
        last = t3 > 0 ? t3 : t2
        array.push(bs,box.new(a,hi,b,lo,xloc=xloc.bar_time,border_color=color.new(ec,45),bgcolor=color.new(ec,88)))
        array.push(bs,box.new(a,math.max(sl,mid),b,math.min(sl,mid),xloc=xloc.bar_time,border_color=na,bgcolor=color.new(sc,94)))
        array.push(bs,box.new(a,math.max(last,mid),b,math.min(last,mid),xloc=xloc.bar_time,border_color=na,bgcolor=color.new(tc,95)))
        level(mid,"ТВХ "+str.tostring(lo,format.mintick)+"–"+str.tostring(hi,format.mintick),ec)
        level(sl,"СТОП",sc)
        level(t1,"ЦЕЛЬ 1",tc)
        level(t2,"ЦЕЛЬ 2",tc)
        if t3 > 0
            level(t3,"ЦЕЛЬ 3",tc)
````
