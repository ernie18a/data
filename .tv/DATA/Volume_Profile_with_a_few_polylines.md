<!-- tradingview-pine-id: PUB;ffe72e128b8c470494c3fbda3cc10312 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Profile with a few polylines

Source: https://www.tradingview.com/script/HBMP20tn-Volume-Profile-with-a-few-polylines/

## Description

The base of "Volume Profile with a few polylines" is another script of mine, [Volume Profile (Maps) [LuxAlgo]](https://www.tradingview.com/script/Z8loUcRj-Volume-Profile-Maps-LuxAlgo/).

The structure of [maps](https://www.tradingview.com/pine-script-reference/v5/#fun_map.new%3Ctype%2Ctype%3E) is used to gather the data. However, the drawings is done with polylines.
This enables coders to draw an entire volume profile with just a few polylines, while the range is broader. 
This results in the benefit to draw more "lines" than with [line.new()](https://www.tradingview.com/pine-script-reference/v5/#fun_line.new) / [box.new()](https://www.tradingview.com/pine-script-reference/v5/#fun_box.new) alone.
[image]https://www.tradingview.com/x/JWIp8XlD/[/image]

🔶 CONCEPTS

🔹 Polylines

[polyline.new](https://www.tradingview.com/pine-script-reference/v5/#fun_polyline.new) creates a new [polyline](https://www.tradingview.com/pine-script-reference/v5/#type_polyline) instance and displays it on the chart, sequentially connecting all of the points in the `points` array with line segments. 
The segments in the drawing can be straight or curved depending on the `curved` parameter.

In this script, points are connected, starting from the bottom. The created line moves up until there is a price level where a volume value needs to be displayed, 
at which the line goes to the left to the concerning volume value, coming back at the same price level until the line returns to its initial x-axis, 
after which the line will continue to rise until all values are displayed.
[image]https://www.tradingview.com/x/TBXyTbvn/[/image]

A polyline can contain maximum 10000 points (10K). 
Since the line has to go back and forth, each price/volume line takes 3 points.
In the case that 20K bars all have a different price, we would need 60K points, or just 6 polylines. A maximum of 100 polylines can be displayed.

The 3 highest volume values are displayed with line.new(), each with their own colour.

🔹 Maps

A map object is a collection that consists of key-value pairs

Each key is unique and can only appear once. When adding a new value with a key that the map already contains, that value replaces the old value associated with the key. 
You can change the value of a particular key though, for example adding volume (value) at the same price (key), the latter technique is used in this script.

[*]Volume is added to the map, associated with a particular price (default close, can be set at high, low, open,...)
[*]When the map already contains the same price (key), the value (volume) is added to the existing volume at the associated price.

A map can contain maximum 50K values, which is more than enough to hold 20K bars (Basic 5K - Premium plan 20K), so the whole history can be put into a map.

🔹 Rounding function

This publication contains 2 round functions, which can be used to widen the Volume Profile

[*]Round

• "Round" set     at    zero -> nothing changes to the source number
• "Round" set below zero -> x digit(s)   after the decimal point, starting from the right side, and rounded.
• "Round" set above zero -> x digit(s) before the decimal point, starting from the right side, and rounded.

Example: 123456.789 

  0->123456.789
  1->123456.79
  2->123456.8
  3->123457
-1->123460
-2->123500

[image]https://www.tradingview.com/x/p3IZBcSR/[/image]

[*]Step

Another option is custom steps.
After setting "Round" to "Step", choose the desired steps in price,

Examples 
•     2  -> 1234.00, 1236.00, 1238.00, 1240.00
•     5  -> 1230.00, 1235.00, 1240.00, 1245.00
• 100  -> 1200.00, 1300.00, 1400.00, 1500.00
• 0.05 -> 1234.00, 1234.05, 1234.10, 1234.15
•••

🔶 FEATURES

🔹 Volume * currency

Let's take as example BTCUSD, relative to USD, 10 volume at a price of 100 BTCUSD will be very different than 10 volume at a price of 30000 (1K vs. 300K)
If you want volume to be associated with USD, enable Volume * currency. Volume will then be multiplied by the price:
• 10 volume, 1 BTC = 100 -> 1000
• 10 volume, 1 BTC = 30K -> 300K
 
Polylines has the attributes curved & closed.
When "curved" is enabled the drawing will connect all points from the `points` array using curved line segments. 
When "closed" is enabled the drawing will also connect the first point to the last point from the `points` array, resulting in a closed polyline. 
They are default disabled, but can be enabled:

[image]https://www.tradingview.com/x/54wQLQOb/[/image]

🔶 DETAILS

🔹 Put

When the map doesn't contain a price, it will be added, using [map.put(id, key, value) ](https://www.tradingview.com/pine-script-reference/v5/#fun_map.put)
In our code:
[pine]map.put(originalMap, price,  volume)
or
originalMap.put(price,  volume)[/pine]

A key (price) is now associated with a value (volume) -> key : value

Since all keys are unique, we don't have to know its position to extract the value, we just need to know the key -> [map.get(id, key) ](https://www.tradingview.com/pine-script-reference/v5/#fun_map.get)
We use map.get() when a certain key already exists in the map, and we want to add volume with that value.
[pine]if  originalMap.contains(price)
    originalMap.put(price, originalMap.get(price) + volume)[/pine]

-> At the last bar, all prices (source) are now associated with volume.

🔶 SETTINGS

[*]Source: Set source of choice; default close, can be set as high, low, open, ...
[*]Volume & currency: Enable to multiply volume with price (see Features)
[*]Amount of bars: Set amount of bars which you want to include in the Volume Profile

🔹 Round -> 'Round/Step'

[*]Round -> see Concepts
[*]Step    -> see Concepts

🔹 Display Volume Profile

[*]Offset: shifts the Volume Profile (max. 500 bars to the right of last bar, see Features)
[*]Max width Volume Profile: largest volume will be x bars wide, the rest is displayed as a ratio against largest volume (see Features)
[*]Colours
[*]Curved: make lines curved
[*]Closed: connect last with first point

🔶 LIMITATIONS

• Lines won't go further than first bar (coded).
• The Volume Profile can be placed maximum 500 bar to the right of last price.

---

## Source Code

````pine
fi(ki)=>'ra' 
// © fikira This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/ 
// @version=5 

indicator('Volume Profile with a few polylines', max_lines_count = 500, max_boxes_count = 500, max_bars_back=2000, max_polylines_count=100, overlay=true)

_                                                                                                                                                                                                                                                                                                                                                                = '
                                                                       Settings
                                                                     ------------                                                                                                                                                                                                                                                                                     '
                                                                 
sp1         ='                                          '              , sp2 =                         '                                     '
src         = input.source(          close              ,              'source'                                                              )
mtV         = input.bool  (          true      , sp2    +         'Volume * currency'                                                        
 ,tooltip   =                                             'Example BTCUSD -> volume in USD'                                                  )
barsBack    = input.int   (          20000              ,          'Amount of bars'                            , maxval=50000                )
iStep       = input.string(         'Round'             ,                 ''                   , group ='Round', options=['Round', 'Step'])
mlt         = input.int   (            0                ,              'Round'                 , group ='Round', minval=  -8    , maxval=  4  
 ,tooltip   =                'Example: 123456.789 \n  0->123456.789\n  1->123456.79\n  2->123456.8\n  3->123457\n-1->123460\n-2->123500'     ) 
step        = input.float (            1                                                       , group ='Round'                              )
offset      = input.int   (           200               ,              'Offset'                , group ='display Volume Profile', maxval=500 ) 
width       = input.int   (           205               ,       'Max width Volume Profile'     , group ='display Volume Profile'             ) 
cReg        = input.color(color.rgb(178, 181, 190, 45),                sp1                   , group ='display Volume Profile', inline='c' ) 
cH_1        = input.color(color.rgb(255,   0,   0, 25),                 ''                   , group ='display Volume Profile', inline='c' ) 
cH_2        = input.color(color.rgb(255, 153,   0, 25),                 ''                   , group ='display Volume Profile', inline='c' ) 
cH_3        = input.color(color.rgb(255, 251,   0, 25),                 ''                   , group ='display Volume Profile', inline='c' ) 
s           = '                            ',s2='                          '
fillcolor   = input.color(#e6510088,   'fill color'+s , inline='l')
curvedInput = input.bool (   false   ,     'curved'  +s2, inline='c')
closedInput = input.bool (   false   ,     'closed'     , inline='c')

m           =                                mlt > 0 ? math.pow(10, mlt) : 1
src        := iStep == 'Step' 
           ? math.round(src / step) * step : mlt > 0 
           ? math.round(src /   m ) *   m  : math.round(src, math.round(math.abs(math.log10(syminfo.mintick)) +mlt)) 
_                                                                                                                                                                                                                                                                                                                                                                = "
                                                                         UDT's
                                                                      ----------                                                                                                                                                                                                                                                                                     "
 
type aCh 
    chart.point[] ch

type pv 
    float p 
    float v 
_                                                                                                                                                                                                                                                                                                                                                                = "
                                                                      Variables
                                                                     -----------                                                                                                                                                                                                                                                                                      "
 
var originalMap = map  .new <float, float>()                                    
var line l1 = line.new(na, na, na, na, color=cH_1, width=2)
var line l2 = line.new(na, na, na, na, color=cH_2, width=2)
var line l3 = line.new(na, na, na, na, color=cH_3, width=1)
_                                                                                                                                                                                                                                                                                                                                                                = '
                                                                      Execution
                                                                     ------------                                                                                                                                                                                                                                                                                     '
 
n               =                            bar_index 
barsBack       := math.min  (barsBack , last_bar_index)                        

if last_bar_index - n <= barsBack
    originalMap.put(src, nz(originalMap.get(src)) + (volume * (mtV ? src : 1))) 

count = 0

if barstate.islast 
    for poly in polyline.all 
        poly.delete()
        
    aPoints = array.from(aCh.new(array.new<chart.point>()))
    points  = array.new<chart.point>()
    point2  = array.new<chart.point>()
    point3  = array.new<chart.point>()

    maxV    = array.from(pv.new(0., 0.), pv.new(0., 0.), pv.new(0., 0.)) 
    maxVol  = 0., maxVpr = 0.
    maxVl2  = 0., maxVp2 = 0.
    maxVl3  = 0., maxVp3 = 0.

    if originalMap.size() > 1

        keys = originalMap.keys()
        kSz  = keys.size()
        for key in keys
            value = originalMap.get(key)
            get0v = maxV.get(0).v 
            get1v = maxV.get(1).v 
            get2v = maxV.get(2).v 
            get0p = maxV.get(0).p 
            get1p = maxV.get(1).p 
            get2p = maxV.get(2).p 
            // fetching 3 highest volume values
            switch 
                value > get0v =>
                    maxV.set(0, pv.new(key, value))
                    if get0v > get1v
                        maxV.set(1, pv.new(get0p, get0v))
                        if get1v > get2v
                            maxV.set(2, pv.new(get1p, get1v))
                    else if get0v > get2v
                        maxV.set(2, pv.new(get0p, get0v))
                value > get1v =>
                    maxV.set(1, pv.new(key, value))
                    if get1v > get2v
                        maxV.set(2, pv.new(get1p, get1v))
                value > get2v =>
                    maxV.set(2, pv.new(key, value))

        w = width / maxV.get(0).v  // max width                                                                               
        keys.sort() // sort keys -> 'price' is sorted
        for j     = 0 to kSz -1
            key   = keys.get(j)
            value = originalMap.get(key)
            c     = 0
            get   = aPoints.get(c)
            if  get.ch.size() < 9999 // max limit is 10K points per polyline -> check every time the array.size()
                get.ch.push(chart.point.from_index(n + offset, key)) 
                get.ch.push(chart.point.from_index(n + offset - math.round(value * w), key)) 
                get.ch.push(chart.point.from_index(n + offset, key)) 
                count += 3
            else 
                aPoints.unshift(aCh.new(array.new<chart.point>())) // when full, add another array.new<chart.point>()
                c += 1
        // display 3 largest volume values with 3x line.new()
        l1.set_xy1(math.max(0, n + offset                                ), maxV.get(0).p)
        l1.set_xy2(math.max(0, n + offset - math.round(maxV.get(0).v * w)), maxV.get(0).p)
        l2.set_xy1(math.max(0, n + offset                                ), maxV.get(1).p)
        l2.set_xy2(math.max(0, n + offset - math.round(maxV.get(1).v * w)), maxV.get(1).p)
        l3.set_xy1(math.max(0, n + offset                                ), maxV.get(2).p)
        l3.set_xy2(math.max(0, n + offset - math.round(maxV.get(2).v * w)), maxV.get(2).p)  

        // draw a polyline from the point of each array.new<chart.point>()
        for l = 0 to aPoints.size() -1
            polyline.new(aPoints.get(l).ch, curved = curvedInput, closed = closedInput, line_color = cReg, fill_color = fillcolor)

//plot(count) // uncomment to see the amount of values
_                                                                                                                                                                                                                                                                                                                                                                = '
                                                                     ------------                                                                                                                                                                                                                                                                                     '
````
