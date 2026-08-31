<!-- tradingview-pine-id: PUB;83bf8ca226264b6bbf724bbaf1106c02 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Price Depth Chart [LuxAlgo]

Source: https://www.tradingview.com/script/93TdE1fd-Liquidity-Price-Depth-Chart-LuxAlgo/

## Description

The Liquidity Price Depth Chart is a unique indicator inspired by the visual representation of order book depth charts, highlighting sorted prices from bullish and bearish candles located on the chart's visible range, as well as their degree of liquidity.

Note that changing the chart's visible range will recalculate the indicator.

🔶 USAGE

The indicator can be used to visualize sorted bullish/bearish prices (in descending order), with bullish prices being highlighted on the left side of the chart, and bearish prices on the right. Prices are highlighted by dots, and connected by a line.

[image]https://www.tradingview.com/x/B1tgPF1l/[/image]

The displacement of a line relative to the x-axis is an indicator of liquidity, with a higher displacement highlighting prices with more volume.

[image]https://www.tradingview.com/x/ZZP8MyZb/[/image]

These can also be easily identified by only keeping the dots, visible voids can be indicative of a price associated with significant volume or of a large price movement if the displacement is more visible for the price axis. These areas could play a key role in future trends.

[image]https://www.tradingview.com/x/yQT1CW10/[/image]

Additionally, the location of the bullish/bearish prices with the highest volume is highlighted with dotted lines, with the returned horizontal lines being useful as potential support/resistances.

🔹Liquidity Clusters

[image]https://www.tradingview.com/x/9NG7RJ6g/[/image]

Clusters of liquidity can be spotted when the Liquidity Price Depth Chart exhibits more rectangular shapes rather than "V" shapes. 

The steepest segments of the shape represent periods of non-stationarity/high volatility, while zones with clustered prices highlight zones of potential liquidity clusters, that is zones where traders accumulate positions.

🔹Liquidity Sentiment

[image]https://www.tradingview.com/x/SPcJWjUF/[/image]

At the bottom of each area, a percentage can be visible. This percentage aims to indicate if the traded volume is more often associated with bullish or bearish price variations.

In the chart above we can see that bullish price variations make 63.89% of the total volume in the range visible range.

🔶 SETTINGS

🔹Bullish Elements

[*]Bullish Price Highest Volume Location: Shows the location of the bullish price variation with the highest associated volume using one horizontal and one vertical line.
[*]Bullish Volume %: Displays the bullish volume percentage at the bottom of the depth chart.

🔹Bearish Elements

[*]Bearish Price Highest Volume Location: Shows the location of the bearish price variation with the highest associated volume using one horizontal and one vertical line.
[*]Bearish Volume %: Displays the bearish volume percentage at the bottom of the depth chart.

🔹Misc

[*]Volume % Box Padding: Width of the volume % boxes at the bottom of the Liquidity Price Depth Chart as a percentage of the chart visible range

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator("Liquidity Price Depth Chart [LuxAlgo]", "LuxAlgo - Liquidity Price Depth Chart", overlay = true, max_labels_count = 500)
//-----------------------------------------------------------------------------}
//Settings
//-----------------------------------------------------------------------------{
//Bullish Elements
showBullMax = input(true, 'Bullish Price Highest Volume Location', group = 'Bullish Elements')
showBullPer = input(true, 'Bullish Volume %', group = 'Bullish Elements')

bullCss     = input(#089981, 'Bullish Prices', inline = 'bull', group = 'Bullish Elements')
bullFillCss = input(color.new(#089981, 90), 'Area', inline = 'bull', group = 'Bullish Elements')

//Bearish Elements
showBearMax = input(true, 'Bearish Price Highest Volume Location', group = 'Bearish Elements')
showBearPer = input(true, 'Bearish Volume %', group = 'Bearish Elements')

bearCss     = input(#f23645, 'Bearish Prices', inline = 'bear', group = 'Bearish Elements')
bearFillCss = input(color.new(#f23645, 90), 'Area', inline = 'bear', group = 'Bearish Elements')

//Misc
padding = input.float(5, 'Volume % Box Padding', minval = 0, maxval = 100, group = 'Misc') / 100

//-----------------------------------------------------------------------------}
//Populate maps
//-----------------------------------------------------------------------------{
var int x1 = na

var float max = na, var float max_bull_vol = na
var float min = na, var float max_bear_vol = na

var max_bull_vlvl = line.new(na,na,na,na, color = bullCss, extend = extend.both, style = line.style_dotted)
var max_bear_vlvl = line.new(na,na,na,na, color = bearCss, extend = extend.both, style = line.style_dotted)

var bull_map = map.new<float, float>()
var bear_map = map.new<float, float>()

n = bar_index

if time == chart.left_visible_bar_time
    x1 := n
    max := high, max_bull_vol := close > open ? volume : 0.
    min := low , max_bear_vol := close < open ? volume : 0.

//Populate price/volume map
if time <= chart.right_visible_bar_time and time >= chart.left_visible_bar_time
    if close > open 
        bull_map.put(close, volume)
        max_bull_vol := math.max(volume, max_bull_vol)

        if max_bull_vol == volume and showBullMax
            max_bull_vlvl.set_xy1(n, close + syminfo.mintick)
            max_bull_vlvl.set_xy2(n, close - syminfo.mintick)

    else if close < open 
        bear_map.put(close, volume)
        max_bear_vol := math.max(volume, max_bear_vol)

        if max_bear_vol == volume and showBearMax
            max_bear_vlvl.set_xy1(n, close + syminfo.mintick)
            max_bear_vlvl.set_xy2(n, close - syminfo.mintick)

    //Get maximum/minimum wicks in visible range
    max := math.max(high, max)
    min := math.min(low, min)

//-----------------------------------------------------------------------------}
//Set cumulative areas
//-----------------------------------------------------------------------------{
if time == chart.right_visible_bar_time
    //Sort bull map keys
    bull_sorted = bull_map.keys()
    bull_sorted.sort(order.descending)
    
    //Sort bear map keys
    bear_sorted = bear_map.keys()
    bear_sorted.sort(order.descending)

    //Get bullish/bearish volume sums
    bull_sumv = bull_map.values().sum()
    bear_sumv = bear_map.values().sum()

    bull_idx = 0.
    bear_idx = 0.
    bull_coordinates = array.new<chart.point>(0)
    bear_coordinates = array.new<chart.point>(0)

    bull_coordinates.push(chart.point.from_index(x1, max))
    bear_coordinates.push(chart.point.from_index(n, max))
    
    //Cumulated bullish volume
    for element in bull_sorted
        bull_idx += bull_map.get(element) / bull_sumv
        chart_point = chart.point.from_index(x1 + int(bull_idx * (n - x1) / 2), element)

        if bull_map.get(element) == max_bull_vol and showBullMax
            line.new(x1, element, n, element, color = bullCss, style = line.style_dotted)

        bull_coordinates.push(chart_point)

        //Point label
        label.new(chart_point
          , color = color(na)
          , style = label.style_label_center
          , text = '•'
          , textcolor = bullCss)

    //Cumulated bearish volume
    for [index, element] in bear_sorted
        bear_idx += bear_map.get(element) / bear_sumv
        chart_point = chart.point.from_index(n - int(bear_idx * (n - x1) / 2), element)

        if bear_map.get(element) == max_bear_vol and showBearMax
            line.new(x1, element, n, element, color = bearCss, style = line.style_dotted)

        bear_coordinates.push(chart_point)

        //Point label
        label.new(chart_point
          , color = color(na)
          , style = label.style_label_center
          , text = '•'
          , textcolor = bearCss)

    //Set horizontal min line for valid fill
    bull_coordinates.push(chart.point.from_index(x1 + (n - x1) / 2, min))
    bull_coordinates.push(chart.point.from_index(x1, min))

    bear_coordinates.push(chart.point.from_index(n - (n - x1) / 2, min))
    bear_coordinates.push(chart.point.from_index(n, min))

    //Create polylines
    polyline.new(bull_coordinates, line_color = bullCss, fill_color = bullFillCss)
    polyline.new(bear_coordinates, line_color = bearCss, fill_color = bearFillCss)

    //Bull % Boxes
    if showBullPer
        bull_vper = bull_sumv / (bull_sumv + bear_sumv)

        box.new(x1, min, x1 + (n - x1) / 2, min - padding * (max - min)
          , bullCss
          , bgcolor = na)
        
        box.new(x1, min, x1 + int((n - x1) / 2 * bull_vper), min - padding * (max - min)
          , na
          , bgcolor = bullCss
          , text_color = color.white
          , text = str.tostring(bull_vper * 100, format.percent)
          , text_size = size.small)
    
    //Bear % Boxes
    if showBearPer
        bear_vper = bear_sumv / (bull_sumv + bear_sumv)

        box.new(n - (n - x1) / 2, min, n, min - padding * (max - min)
          , bearCss
          , bgcolor = na)

        box.new(n - int((n - x1) / 2 * bear_vper), min, n, min - padding * (max - min)
          , na
          , bgcolor = bearCss
          , text_color = color.white
          , text = str.tostring(bear_vper * 100, format.percent)
          , text_size = size.small)

//-----------------------------------------------------------------------------}
````
