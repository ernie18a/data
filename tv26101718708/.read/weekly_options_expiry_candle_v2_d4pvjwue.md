# Weekly Options Expiry Candle V.2

- url: https://www.tradingview.com/script/D4PvJWUe-Weekly-Options-Expiry-Candle-V-2/
- type: indicator
- pine_id: PUB;622f169c20314cc793b5b526e894fd45
- version: 4.0

## Description

In India Weekly options expire on Thursday and that creates a different price action candle than the week timeframe.
My previous script [url=https://www.tradingview.com/script/QI1B1KDn-Weekly-Options-Expiry-Candle/]Weekly Options Expiry Candle[/url]  has some limitations. This script overcame those limitations and added some features.

You can use this in any intraday time frame candle.
It will show:
[list]
[*]All expiry candle in box format
[*]Expiry OHLC label
[*]Pivot (Floor or Fibonacci) based on expiry OHLC data
[*]Developing Expiry candle and Pivot
[*]A table showing expiry range(high-low) and Expiry body abs(open-close) stats.
[/list]

You can turn on or off any feature.

Please let me know if you found this script useful or have any questions or suggestions.

[symbol="NSE:BANKNIFTY"]NSE:BANKNIFTY[/symbol]
[symbol="NSE:NIFTY"]NSE:NIFTY[/symbol]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tanayroy

//@version=5
indicator("Weekly Options Expiry Candle V.2", shorttitle = 'Expiry Candale V.2',overlay = true,max_boxes_count = 500,
 max_labels_count = 500)
var string GP1 = 'Option Expiry Candle'
sess = input.session("0915-0920", title="Session Time",group = GP1,tooltip = 'Opening Session Time') 
t = time(timeframe.period, sess + ":23456")
expiary_day=input.string("Thursday",title = "Weekly Expiary Day",options = ['Monday', 'Tuesday', 'Wednesday', 'Thursday'
 , 'Friday'],group = GP1)
show_expiry_candle = input(title='Show Candle', defval=true,group = GP1)
show_expiry_OHLC = input(title='Show Expiry OHLC', defval=true,group = GP1)
var string GP2 = 'Option Expiry Pivot'
display_pivot = input(title='Display Pivot', defval=true,group = GP2,tooltip = 'Pivot Calculated on Expiry OHLC')
type_of_pivot = input.string('Fibonacci','Pivot Type',options = ['Fibonacci','Floor'],group = GP2)
show_pivot = input(title='Show Pivot', defval=true,group = GP2)
show_tc = input(title='Show TC', defval=true,group = GP2)
show_bc = input(title='Show BC', defval=true,group = GP2)
show_r1 = input(title='Show R1', defval=true,group = GP2)
show_r2 = input(title='Show R2', defval=false,group = GP2)
show_r3 = input(title='Show R3', defval=false,group = GP2)
show_r4 = input(title='Show R4', defval=false,group = GP2)

show_s1 = input(title='Show S1', defval=true,group = GP2)
show_s2 = input(title='Show S2', defval=false,group = GP2)
show_s3 = input(title='Show S3', defval=false,group = GP2)
show_s4 = input(title='Show S4', defval=false,group = GP2)


var string GP3 = "Display Range Table"
show_table = input.bool(true,title = 'Show Range Table', group = GP3)
tableYpos = input.string("top", "Panel position", inline = "31", options = ["top", "middle", "bottom"], group = GP3)
tableXpos = input.string("right", "", inline = "31", options = ["left", "center", "right"], group = GP3)

in_session = not na(t)
is_first = in_session and not in_session[1]
var int dayofweek_d=na
var int barpos=na
var int expiry_bar_start=na
var int pre_expiry_bar_end=na
if is_first
    dayofweek_d:=dayofweek(time )
    barpos:=bar_index 
var float expiry_open=0
var float expiry_high=0
var float expiry_low=0
var float pre_expiry_close=0
var position_array=array.from(0,0,0)
var range_array=array.new_float(100)
var body_array=array.new_float(100)
var float pivot=na
var float tc=na
var float bc=na
var float r1=na
var float r2=na
var float r3=na
var float r4=na
var float s1=na
var float s2=na
var float s3=na
var float s4=na
var float ar1=na
var float ar2=na
var float ar3=na
var float ar4=na
var float as1=na
var float as2=na
var float as3=na
var float as4=na
var float last_week_range=na
var float three_weeks_range=na
var float five_weeks_range=na
var float seven_weeks_range=na
var float ten_weeks_range=na
var float fifteen_weeks_range=na
var float twenty_weeks_range=na
var float last_week_body=na
var float three_weeks_body=na
var float five_weeks_body=na
var float seven_weeks_body=na
var float ten_weeks_body=na
var float fifteen_weeks_body=na
var float twenty_weeks_body=na

var day_array = switch expiary_day
    "Monday" => array.from(3,4,5)
    "Tuesday" => array.from(4,5,6)
    "Wednesday" => array.from(5,6,2)
    "Thursday" => array.from(6,2,3)
    "Friday" => array.from(2,3,4)
    // Default used when the three first cases do not match.
    => array.from(6,2,3)

if dayofweek_d==array.get(day_array,0) //Friday, so we can take open
    if is_first and timeframe.isintraday
        expiry_open:=open
        pre_expiry_close:=close[1]
        expiry_high:=high
        expiry_low:=low
        array.set(position_array,0,array.get(position_array,1))
        array.set(position_array,1,bar_index)
        array.set(position_array,2,bar_index[1])
        mid_val=int((array.get(position_array,2)-array.get(position_array,0))/2)
        if show_expiry_candle
            box.new(array.get(position_array,0),expiry_open[1],array.get(position_array,2),pre_expiry_close,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=expiry_open[1]>pre_expiry_close?color.new(color.red,70):color.new(color.green,70))
            box.new(array.get(position_array,0)+mid_val-1, expiry_high[1], array.get(position_array,0)+mid_val+1, 
             expiry_open[1]>pre_expiry_close?expiry_open[1]:pre_expiry_close, xloc=xloc.bar_index,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=color.new(color.red,100))
            box.new(array.get(position_array,0)+mid_val-1, expiry_open[1]>pre_expiry_close?pre_expiry_close:
             expiry_open[1], array.get(position_array,0)+mid_val+1, expiry_low[1], xloc=xloc.bar_index,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=color.new(color.red,100))
        if show_expiry_OHLC    
            label.new(array.get(position_array,2),expiry_high[1],text = 'O: '+str.tostring(expiry_open[1])+'\nH: '+
             str.tostring(expiry_high[1])+'\nL: '+str.tostring(expiry_low[1])+'\nC: '+str.tostring(pre_expiry_close),
             color = color.rgb(0,0,0,50),textcolor = color.white)

        pivot := (expiry_high[1] + expiry_low[1] + pre_expiry_close) / 3
        abc = (expiry_high[1] + expiry_low[1]) / 2
        atc = pivot - abc + pivot
        tc := abc >= atc ? abc : atc
        bc := abc >= atc ? atc : abc
        if type_of_pivot=='Floor'
            r1 := 2 * pivot - expiry_low[1]
            r2 := pivot + expiry_high[1] - expiry_low[1]
            r3 := r1 + expiry_high[1] - expiry_low[1]
            r4 := r3 + r2 - r1
            s1 := 2 * pivot - expiry_high[1]
            s2 := pivot - (expiry_high[1] - expiry_low[1])
            s3 := s1 - (expiry_high[1] - expiry_low[1])
            s4 := s3 - (s1 - s2)
        else
            r1 := pivot + ((expiry_high[1] - expiry_low[1]) * 0.382)
            r2 := pivot + ((expiry_high[1] - expiry_low[1]) * 0.618)
            r3 := pivot + ((expiry_high[1] - expiry_low[1]) * 1.0)
            r4 := pivot + ((expiry_high[1] - expiry_low[1]) * 1.382)

            s1 := pivot - ((expiry_high[1] - expiry_low[1]) * 0.382)
            s2 := pivot - ((expiry_high[1] - expiry_low[1]) * 0.618)
            s3 := pivot - ((expiry_high[1] - expiry_low[1]) * 1.0)
            s4 := pivot - ((expiry_high[1] - expiry_low[1]) * 1.382)
        expiry_range=expiry_high[1]-expiry_low[1]
        expiry_body=math.abs(pre_expiry_close-expiry_open[1])
        if array.size(range_array)>100
            array.pop(range_array)
            array.pop(body_array)
            array.unshift(range_array,expiry_range)
            array.unshift(body_array,expiry_body)
        else
            array.unshift(range_array,expiry_range)
            array.unshift(body_array,expiry_body)

//Friday is holiday and expiry open is not available, take Monday open
if dayofweek_d == array.get(day_array,1)  and  dayofweek_d[(bar_index-barpos)+1]!=array.get(day_array,0)   
    if is_first and timeframe.isintraday
        expiry_open:=open
        pre_expiry_close:=close[1]
        expiry_high:=high
        expiry_low:=low
        array.set(position_array,0,array.get(position_array,1))
        array.set(position_array,1,bar_index)
        array.set(position_array,2,bar_index[1])
        mid_val=int((array.get(position_array,2)-array.get(position_array,0))/2)
        if show_expiry_candle
            box.new(array.get(position_array,0),expiry_open[1],array.get(position_array,2),pre_expiry_close,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=expiry_open[1]>pre_expiry_close?color.new(color.red,70):color.new(color.green,70))
            box.new(array.get(position_array,0)+mid_val-1, expiry_high[1], array.get(position_array,0)+mid_val+1, 
             expiry_open[1]>pre_expiry_close?expiry_open[1]:pre_expiry_close, xloc=xloc.bar_index,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=color.new(color.red,100))
            box.new(array.get(position_array,0)+mid_val-1, expiry_open[1]>pre_expiry_close?pre_expiry_close:
             expiry_open[1], array.get(position_array,0)+mid_val+1, expiry_low[1], xloc=xloc.bar_index,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=color.new(color.red,100))
        if show_expiry_OHLC    
            label.new(array.get(position_array,2),expiry_high[1],text = 'O: '+str.tostring(expiry_open[1])+'\nH: '+
             str.tostring(expiry_high[1])+'\nL: '+str.tostring(expiry_low[1])+'\nC: '+str.tostring(pre_expiry_close),
             color = color.rgb(0,0,0,50),textcolor = color.white)

        pivot := (expiry_high[1] + expiry_low[1] + pre_expiry_close) / 3
        abc = (expiry_high[1] + expiry_low[1]) / 2
        atc = pivot - abc + pivot
        tc := abc >= atc ? abc : atc
        bc := abc >= atc ? atc : abc
        if type_of_pivot=='Floor'
            r1 := 2 * pivot - expiry_low[1]
            r2 := pivot + expiry_high[1] - expiry_low[1]
            r3 := r1 + expiry_high[1] - expiry_low[1]
            r4 := r3 + r2 - r1
            s1 := 2 * pivot - expiry_high[1]
            s2 := pivot - (expiry_high[1] - expiry_low[1])
            s3 := s1 - (expiry_high[1] - expiry_low[1])
            s4 := s3 - (s1 - s2)
        else
            r1 := pivot + ((expiry_high[1] - expiry_low[1]) * 0.382)
            r2 := pivot + ((expiry_high[1] - expiry_low[1]) * 0.618)
            r3 := pivot + ((expiry_high[1] - expiry_low[1]) * 1.0)
            r4 := pivot + ((expiry_high[1] - expiry_low[1]) * 1.382)

            s1 := pivot - ((expiry_high[1] - expiry_low[1]) * 0.382)
            s2 := pivot - ((expiry_high[1] - expiry_low[1]) * 0.618)
            s3 := pivot - ((expiry_high[1] - expiry_low[1]) * 1.0)
            s4 := pivot - ((expiry_high[1] - expiry_low[1]) * 1.382)
        expiry_range=expiry_high[1]-expiry_low[1]
        expiry_body=math.abs(pre_expiry_close-expiry_open[1])
        if array.size(range_array)>100
            array.pop(range_array)
            array.pop(body_array)
            array.unshift(range_array,expiry_range)
            array.unshift(body_array,expiry_body)
        else
            array.unshift(range_array,expiry_range)
            array.unshift(body_array,expiry_body)
    

//Friday and Monday is holiday and expiry open is not available, take Tuesday open
if dayofweek_d==array.get(day_array,2)  and  dayofweek_d[(bar_index-barpos)+1]!=array.get(day_array,1) and  
     dayofweek_d[(bar_index-barpos[(bar_index-barpos)+1])]!=array.get(day_array,0) 
    if is_first and timeframe.isintraday
        expiry_open:=open
        pre_expiry_close:=close[1]
        expiry_high:=high
        expiry_low:=low
        array.set(position_array,0,array.get(position_array,1))
        array.set(position_array,1,bar_index)
        array.set(position_array,2,bar_index[1])
        mid_val=int((array.get(position_array,2)-array.get(position_array,0))/2)
        if show_expiry_candle
            box.new(array.get(position_array,0),expiry_open[1],array.get(position_array,2),pre_expiry_close,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=expiry_open[1]>pre_expiry_close?color.new(color.red,70):color.new(color.green,70))
            box.new(array.get(position_array,0)+mid_val-1, expiry_high[1], array.get(position_array,0)+mid_val+1, 
             expiry_open[1]>pre_expiry_close?expiry_open[1]:pre_expiry_close, xloc=xloc.bar_index,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=color.new(color.red,100))
            box.new(array.get(position_array,0)+mid_val-1, expiry_open[1]>pre_expiry_close?pre_expiry_close:
             expiry_open[1], array.get(position_array,0)+mid_val+1, expiry_low[1], xloc=xloc.bar_index,
             border_color=expiry_open[1]>pre_expiry_close?color.red:color.green, border_style=line.style_solid,
             bgcolor=color.new(color.red,100))
        if show_expiry_OHLC    
            label.new(array.get(position_array,2),expiry_high[1],text = 'O: '+str.tostring(expiry_open[1])+'\nH: '+
             str.tostring(expiry_high[1])+'\nL: '+str.tostring(expiry_low[1])+'\nC: '+str.tostring(pre_expiry_close),
             color = color.rgb(0,0,0,50),textcolor = color.white)

        pivot := (expiry_high[1] + expiry_low[1] + pre_expiry_close) / 3
        abc = (expiry_high[1] + expiry_low[1]) / 2
        atc = pivot - abc + pivot
        tc := abc >= atc ? abc : atc
        bc := abc >= atc ? atc : abc
        if type_of_pivot=='Floor'
            r1 := 2 * pivot - expiry_low[1]
            r2 := pivot + expiry_high[1] - expiry_low[1]
            r3 := r1 + expiry_high[1] - expiry_low[1]
            r4 := r3 + r2 - r1
            s1 := 2 * pivot - expiry_high[1]
            s2 := pivot - (expiry_high[1] - expiry_low[1])
            s3 := s1 - (expiry_high[1] - expiry_low[1])
            s4 := s3 - (s1 - s2)
        else
            r1 := pivot + ((expiry_high[1] - expiry_low[1]) * 0.382)
            r2 := pivot + ((expiry_high[1] - expiry_low[1]) * 0.618)
            r3 := pivot + ((expiry_high[1] - expiry_low[1]) * 1.0)
            r4 := pivot + ((expiry_high[1] - expiry_low[1]) * 1.382)

            s1 := pivot - ((expiry_high[1] - expiry_low[1]) * 0.382)
            s2 := pivot - ((expiry_high[1] - expiry_low[1]) * 0.618)
            s3 := pivot - ((expiry_high[1] - expiry_low[1]) * 1.0)
            s4 := pivot - ((expiry_high[1] - expiry_low[1]) * 1.382)
        expiry_range=expiry_high[1]-expiry_low[1]
        expiry_body=math.abs(pre_expiry_close-expiry_open[1])
        if array.size(range_array)>100
            array.pop(range_array)
            array.pop(body_array)
            array.unshift(range_array,expiry_range)
            array.unshift(body_array,expiry_body)
        else
            array.unshift(range_array,expiry_range)
            array.unshift(body_array,expiry_body)


if high>expiry_high
    expiry_high:=high
if low<expiry_low
    expiry_low:=low

if timeframe.isintraday
    if show_expiry_candle
        dev_box=box.new(array.get(position_array,1),expiry_open,bar_index,close,border_color=expiry_open>
         close?color.red:color.green, border_style=line.style_solid,bgcolor=expiry_open>close?
         color.new(color.red,70):color.new(color.green,70))
        high_box=box.new(array.get(position_array,1)+1, expiry_high, bar_index-1, expiry_open>close?
         expiry_open:close, xloc=xloc.bar_index,border_color=expiry_open>close?color.red:color.green, 
         border_style=line.style_solid,bgcolor=color.new(color.red,100))
        low_box=box.new(array.get(position_array,1)+1, expiry_open>close?close:expiry_open, bar_index-1, 
         expiry_low, xloc=xloc.bar_index,border_color=expiry_open>close?color.red:color.green, 
         border_style=line.style_solid,bgcolor=color.new(color.red,100))
        box.delete(dev_box[1])
        box.delete(high_box[1])
        box.delete(low_box[1])
    if show_expiry_OHLC 
        dev_label=label.new(bar_index,expiry_high,text = 'O: '+str.tostring(expiry_open)+'\nH: '+
         str.tostring(expiry_high)+'\nL: '+str.tostring(expiry_low)+'\nC: '+str.tostring(close),
         color = color.rgb(0,0,0,50),textcolor = color.white)
        label.delete(dev_label[1])


plot(show_pivot and display_pivot ? pivot : na, title='Pivot', style=plot.style_cross, 
 color=color.new(color.blue, 0), linewidth=1)
plot(show_tc and display_pivot? tc : na, style=plot.style_cross, title='TC', color=color.new(color.blue, 0), 
 linewidth=1)
plot(show_bc and display_pivot? bc : na, style=plot.style_cross, title='BC', color=color.new(color.blue, 0), 
 linewidth=1)

plot(show_r1 and display_pivot? r1 : na, style=plot.style_cross, title='R1', color=color.new(#a81b41, 0), linewidth=1)
plot(show_r2 and display_pivot? r2 : na, style=plot.style_cross, title='R2', color=color.new(#a81b41, 0), linewidth=1)
plot(show_r3 and display_pivot? r3 : na, style=plot.style_cross, title='R3', color=color.new(#a81b41, 0), linewidth=1)
plot(show_r4 and display_pivot? r4 : na, style=plot.style_cross, title='R4', color=color.new(#a81b41, 0), linewidth=1)


plot(show_s1 and display_pivot? s1 : na, style=plot.style_cross, title='S1', color=color.new(#02796f, 0), linewidth=1)
plot(show_s2 and display_pivot? s2 : na, style=plot.style_cross, title='S2', color=color.new(#02796f, 0), linewidth=1)
plot(show_s3 and display_pivot? s3 : na, style=plot.style_cross, title='S3', color=color.new(#02796f, 0), linewidth=1)
plot(show_s4 and display_pivot? s4 : na, style=plot.style_cross, title='S4', color=color.new(#02796f, 0), linewidth=1)

apivot = (expiry_high + expiry_low + close) / 3
aabc = (expiry_high + expiry_low) / 2
aatc = apivot - aabc + apivot
atc = aabc >= aatc ? aabc : aatc
abc = aabc >= aatc ? aatc : aabc

if type_of_pivot=='Floor'
    ar1 := 2 * apivot - expiry_low
    ar2 := apivot + expiry_high - expiry_low
    ar3 := ar1 + expiry_high - expiry_low
    ar4 := ar3 + ar2 - ar1
    as1 := 2 * apivot - expiry_high
    as2 := apivot - (expiry_high - expiry_low)
    as3 := as1 - (expiry_high - expiry_low)
    as4 := as3 - (as1 - as2)
else
    ar1 := apivot + ((expiry_high[1] - expiry_low[1]) * 0.382)
    ar2 := apivot + ((expiry_high[1] - expiry_low[1]) * 0.618)
    ar3 := apivot + ((expiry_high[1] - expiry_low[1]) * 1.0)
    ar4 := apivot + ((expiry_high[1] - expiry_low[1]) * 1.382)

    as1 := apivot - ((expiry_high[1] - expiry_low[1]) * 0.382)
    as2 := apivot - ((expiry_high[1] - expiry_low[1]) * 0.618)
    as3 := apivot - ((expiry_high[1] - expiry_low[1]) * 1.0)
    as4 := apivot - ((expiry_high[1] - expiry_low[1]) * 1.382)
var line pl = na
var line tcl = na
var line bcl = na
var line r1l = na
var line r2l = na
var line r3l = na
var line r4l = na

var line s1l = na
var line s2l = na
var line s3l = na
var line s4l = na

if not na(pl[1])
    line.delete(pl[1])
if not na(tcl[1])
    line.delete(tcl[1])
if not na(bcl[1])
    line.delete(bcl[1])

if not na(r1l[1])
    line.delete(r1l[1])
if not na(r2l[1])
    line.delete(r2l[1])
if not na(r3l[1])
    line.delete(r3l[1])
if not na(r4l[1])
    line.delete(r4l[1])

if not na(s1l[1])
    line.delete(s1l[1])
if not na(s2l[1])
    line.delete(s2l[1])
if not na(s3l[1])
    line.delete(s3l[1])
if not na(s4l[1])
    line.delete(s4l[1])



this_week_range=expiry_high-expiry_low
this_week_body=math.abs(expiry_open-close)
var float average_range=na
var float average_body=na
if array.size(range_array)>20
    last_week_range:=array.get(range_array,0)
    three_weeks_range:=(array.get(range_array,0)+array.get(range_array,1)+array.get(range_array,2))/3
    five_weeks_range:=(array.get(range_array,0)+array.get(range_array,1)+array.get(range_array,2)+array.get(range_array,3)+
     array.get(range_array,4))/5
    seven_weeks_range:=(array.get(range_array,0)+array.get(range_array,1)+array.get(range_array,2)+array.get(range_array,3)+
     array.get(range_array,4)+array.get(range_array,5)+array.get(range_array,6))/7
    ten_weeks_range:=(array.get(range_array,0)+array.get(range_array,1)+array.get(range_array,2)+array.get(range_array,3)+
     array.get(range_array,4)+array.get(range_array,5)+array.get(range_array,6)+array.get(range_array,7)+
     array.get(range_array,8)+array.get(range_array,9))/10
    fifteen_weeks_range:=(array.get(range_array,0)+array.get(range_array,1)+array.get(range_array,2)+array.get(range_array,3)+
     array.get(range_array,4)+array.get(range_array,5)+array.get(range_array,6)+array.get(range_array,7)+
     array.get(range_array,8)+array.get(range_array,9)+array.get(range_array,11)+array.get(range_array,12)+array.get(range_array,13)
     +array.get(range_array,14))/15
    twenty_weeks_range:=(array.get(range_array,0)+array.get(range_array,1)+array.get(range_array,2)+array.get(range_array,3)+
     array.get(range_array,4)+array.get(range_array,5)+array.get(range_array,6)+array.get(range_array,7)+
     array.get(range_array,8)+array.get(range_array,9)+array.get(range_array,11)+array.get(range_array,12)+array.get(range_array,13)
     +array.get(range_array,14)+array.get(range_array,15)+array.get(range_array,16)+array.get(range_array,17)
     +array.get(range_array,18)+array.get(range_array,19))/20
    average_range:=((last_week_range*6)+(three_weeks_range*5)+(seven_weeks_range*4)+(ten_weeks_range*3)+
     (fifteen_weeks_range*2)+(twenty_weeks_range*1))/21

    last_week_body:=array.get(body_array,0)
    three_weeks_body:=(array.get(body_array,0)+array.get(body_array,1)+array.get(body_array,2))/3
    five_weeks_body:=(array.get(body_array,0)+array.get(body_array,1)+array.get(body_array,2)+array.get(body_array,3)+
     array.get(body_array,4))/5
    seven_weeks_body:=(array.get(body_array,0)+array.get(body_array,1)+array.get(body_array,2)+array.get(body_array,3)+
     array.get(body_array,4)+array.get(body_array,5)+array.get(body_array,6))/7
    ten_weeks_body:=(array.get(body_array,0)+array.get(body_array,1)+array.get(body_array,2)+array.get(body_array,3)+
     array.get(body_array,4)+array.get(body_array,5)+array.get(body_array,6)+array.get(body_array,7)+
     array.get(body_array,8)+array.get(body_array,9))/10
    fifteen_weeks_body:=(array.get(body_array,0)+array.get(body_array,1)+array.get(body_array,2)+array.get(body_array,3)+
     array.get(body_array,4)+array.get(body_array,5)+array.get(body_array,6)+array.get(body_array,7)+
     array.get(body_array,8)+array.get(body_array,9)+array.get(body_array,11)+array.get(body_array,12)+array.get(body_array,13)
     +array.get(body_array,14))/15
    twenty_weeks_body:=(array.get(body_array,0)+array.get(body_array,1)+array.get(body_array,2)+array.get(body_array,3)+
     array.get(body_array,4)+array.get(body_array,5)+array.get(body_array,6)+array.get(body_array,7)+
     array.get(body_array,8)+array.get(body_array,9)+array.get(body_array,11)+array.get(body_array,12)+array.get(body_array,13)
     +array.get(body_array,14)+array.get(body_array,15)+array.get(body_array,16)+array.get(body_array,17)
     +array.get(body_array,18)+array.get(body_array,19))/20
    average_body:=((last_week_body*6)+(three_weeks_body*5)+(seven_weeks_body*4)+(ten_weeks_body*3)+
     (fifteen_weeks_body*2)+(twenty_weeks_body*1))/21

var table range_table = table.new(tableYpos + "_" + tableXpos, columns=3, rows=21,bgcolor=color.yellow,border_width=1,
 border_color=color.white) 

if barstate.islast and show_table and timeframe.isintraday
    table.cell(range_table,0,0,"Head")
    table.cell(range_table,1,0,"Average")
    table.cell(range_table,2,0,"Percent")

    table.cell(range_table,0,1,'Option Expiry Range')
    table.merge_cells(range_table,0,1,2,1)

    table.cell(range_table,0,2,'Last Week Range')
    table.cell(range_table,1,2,str.tostring(last_week_range,format.mintick))
    table.cell(range_table,2,2,str.tostring((this_week_range/last_week_range)*100,format.mintick))

    table.cell(range_table,0,3,'Three Weeks Range')
    table.cell(range_table,1,3,str.tostring(three_weeks_range,format.mintick))
    table.cell(range_table,2,3,str.tostring((this_week_range/three_weeks_range)*100,format.mintick))

    table.cell(range_table,0,4,'Five Weeks Range')
    table.cell(range_table,1,4,str.tostring(five_weeks_range,format.mintick))
    table.cell(range_table,2,4,str.tostring((this_week_range/five_weeks_range)*100,format.mintick))

    table.cell(range_table,0,5,'Seven Weeks Range')
    table.cell(range_table,1,5,str.tostring(seven_weeks_range,format.mintick))
    table.cell(range_table,2,5,str.tostring((this_week_range/seven_weeks_range)*100,format.mintick))

    table.cell(range_table,0,6,'Ten Weeks Range')
    table.cell(range_table,1,6,str.tostring(ten_weeks_range,format.mintick))
    table.cell(range_table,2,6,str.tostring((this_week_range/ten_weeks_range)*100,format.mintick))

    table.cell(range_table,0,7,'Fifteen Weeks Range')
    table.cell(range_table,1,7,str.tostring(fifteen_weeks_range,format.mintick))
    table.cell(range_table,2,7,str.tostring((this_week_range/fifteen_weeks_range)*100,format.mintick))

    table.cell(range_table,0,8,'Twenty Weeks Range')
    table.cell(range_table,1,8,str.tostring(twenty_weeks_range,format.mintick))
    table.cell(range_table,2,8,str.tostring((this_week_range/twenty_weeks_range)*100,format.mintick))

    table.cell(range_table,0,9,'This Weeks Range')
    table.cell(range_table,1,9,str.tostring(this_week_range,format.mintick))
    table.cell(range_table,2,9,str.tostring((this_week_range/this_week_range)*100,format.mintick))

    table.cell(range_table,0,10,'Average Week Range')
    table.cell(range_table,1,10,str.tostring(average_range,format.mintick))
    table.cell(range_table,2,10,str.tostring((this_week_range/average_range)*100,format.mintick))

    table.cell(range_table,0,11,'Option Expiry Body')
    table.merge_cells(range_table,0,11,2,11)

    table.cell(range_table,0,12,'Last Week Body')
    table.cell(range_table,1,12,str.tostring(last_week_body,format.mintick))
    table.cell(range_table,2,12,str.tostring((this_week_body/last_week_body)*100,format.mintick))

    table.cell(range_table,0,13,'Three Weeks Body')
    table.cell(range_table,1,13,str.tostring(three_weeks_body,format.mintick))
    table.cell(range_table,2,13,str.tostring((this_week_body/three_weeks_body)*100,format.mintick))

    table.cell(range_table,0,14,'Five Weeks Body')
    table.cell(range_table,1,14,str.tostring(five_weeks_body,format.mintick))
    table.cell(range_table,2,14,str.tostring((this_week_body/five_weeks_body)*100,format.mintick))

    table.cell(range_table,0,15,'Seven Weeks Body')
    table.cell(range_table,1,15,str.tostring(seven_weeks_body,format.mintick))
    table.cell(range_table,2,15,str.tostring((this_week_body/seven_weeks_body)*100,format.mintick))

    table.cell(range_table,0,16,'Ten Weeks Body')
    table.cell(range_table,1,16,str.tostring(ten_weeks_body,format.mintick))
    table.cell(range_table,2,16,str.tostring((this_week_body/ten_weeks_body)*100,format.mintick))

    table.cell(range_table,0,17,'Fifteen Weeks Body')
    table.cell(range_table,1,17,str.tostring(fifteen_weeks_body,format.mintick))
    table.cell(range_table,2,17,str.tostring((this_week_body/fifteen_weeks_body)*100,format.mintick))

    table.cell(range_table,0,18,'Twenty Weeks Body')
    table.cell(range_table,1,18,str.tostring(twenty_weeks_body,format.mintick))
    table.cell(range_table,2,18,str.tostring((this_week_body/twenty_weeks_body)*100,format.mintick))

    table.cell(range_table,0,19,'This Weeks Body')
    table.cell(range_table,1,19,str.tostring(this_week_body,format.mintick))
    table.cell(range_table,2,19,str.tostring((this_week_body/this_week_body)*100,format.mintick))

    table.cell(range_table,0,20,'Average Week Body')
    table.cell(range_table,1,20,str.tostring(average_body,format.mintick))
    table.cell(range_table,2,20,str.tostring((this_week_body/average_body)*100,format.mintick))
if barstate.islast and timeframe.isintraday
    if show_pivot and display_pivot
        pl := line.new(bar_index, apivot, bar_index + 20 , apivot, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=color.lime, width=2)


    if show_tc and display_pivot
        tcl := line.new(bar_index, atc, bar_index + 20 , atc, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=color.blue, width=2)

    if show_bc and display_pivot
        bcl := line.new(bar_index, abc, bar_index + 20 , abc, xloc=xloc.bar_index,  extend=extend.right, 
         style=line.style_dotted, color=color.blue, width=2)


    if show_r1 and display_pivot 
        r1l := line.new(bar_index, ar1, bar_index + 20 , ar1, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#a81b41, width=1)

    if show_r2 and display_pivot
        r2l := line.new(bar_index, ar2, bar_index + 20 , ar2, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#a81b41, width=1)

    if show_r3 and display_pivot
        r3l := line.new(bar_index, ar3, bar_index + 20 , ar3, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#a81b41, width=1)

    if show_r4 and display_pivot
        r4l := line.new(bar_index, ar4, bar_index + 20 , ar4, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#a81b41, width=1)

    if show_s1 and display_pivot
        s1l := line.new(bar_index, as1, bar_index + 20 , as1, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#02796f, width=1)

    if show_s2 and display_pivot
        s2l := line.new(bar_index, as2, bar_index + 20 , as2, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#02796f, width=1)

    if show_s3 and display_pivot
        s3l := line.new(bar_index, as3, bar_index + 20 , as3, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#02796f, width=1)

    if show_s4 and display_pivot
        s4l := line.new(bar_index, as4, bar_index + 20 , as4, xloc=xloc.bar_index, extend=extend.right, 
         style=line.style_dotted, color=#02796f, width=1)
````
