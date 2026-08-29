<!-- tradingview-pine-id: PUB;a2e87fa64f2e4292bd9129776e04ca59 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Levels [LuxAlgo]

Source: https://www.tradingview.com/script/qAkfJgFu-Liquidity-Levels-LuxAlgo/

## Description

The Peak Activity Levels indicator displays support and resistance levels from prices accompanied by significant volume. The indicator includes a histogram returning the frequency of closing prices falling between two parallel levels, each bin shows the number of bullish candles within the levels.

1. Settings

[*]Length: Lookback for the detection of volume peaks.
[*]Number Of Levels: Determines the number of levels to display.
[*]Levels Color Mode: Determines how the levels should be colored. "Relative" will color the levels based on their location relative to the current price. "Random" will apply a random color to each level. "Fixed" will use a single color for each level. 
[*]Levels Style: Style of the displayed levels. Styles include solid, dashed, and dotted.

1.1 Histogram

[*]Show Histogram: Determines whether to display the histogram or not.
[*]Histogram Window: Lookback period of the histogram calculation.
[*]Bins Colors: Control the color of the histogram bins.

2. Usage

The indicator can be used to display ready-to-use support and resistance. These are constructed from peaks in volume. When a peak occurs, we take the price where this peak occurred and use it as the value for our level.

[image]https://www.tradingview.com/x/tA8F4rMb/[/image]

If one of the levels was previously tested, we can hypothesize that the level might be used as support/resistance in the future. Additional analysis using volume can be done in order to confirm a potential bounce.

The histogram can return various information to the user. It can show if the price stayed within two levels for a long time and if the price within two levels was mostly made of bullish or bearish candles.

[image]https://www.tradingview.com/x/O4oT4Rcg/[/image]

In the chart above, we can see that over the most recent 200 bars (determined by Histogram Window) 68 closing prices fall between levels A and B, with 27 bars being bullish.

Additionally, the width of a bin and its length can sometimes give information about the volatility of a specific price variation. If a bin is very wide but short (a low number of closing prices fallen within the levels) then we can conclude a most of the movement was done on a short amount of time.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator("Liquidity Levels [LuxAlgo]", "LuxAlgo - Liquidity Levels",overlay = true, max_bars_back = 2000, max_lines_count = 500, max_labels_count = 500)
//-----------------------------------------------------------------------------}
//Settings
//-----------------------------------------------------------------------------{
length = input.int(20, minval = 1)
show   = input.int(5,'Number Of Levels', minval = 1)

lineCol  = input.string('Fixed','Levels Color Mode', options = ['Relative','Random','Fixed'])
lvlStyle = input.string('──','Levels Style', options = ['──','- - -','· · ·'])

//Levels color
relativeColUp = input(#2157f3,'', inline = 'lvlcol')
relativeColDn = input(#ff5d00,'', inline = 'lvlcol')
fixed_col       = input(#2157f3,'Fixed Color', inline = 'lvlcol')

//Style
show_hist = input(true, 'Show Histogram', group = 'Histogram')
distwin   = input.int(200, 'Histogram Window', maxval = 500, group = 'Histogram')
upCol     = input(color.new(#2157f3,50), 'Bins Colors', group = 'Histogram', inline = 'col')
dnCol     = input(color.new(#ff5d00,50), '', group = 'Histogram', inline = 'col')

//-----------------------------------------------------------------------------}
//Type
//-----------------------------------------------------------------------------{
type histbar
    box bull
    box bear

//-----------------------------------------------------------------------------}
//Populate arrays
//-----------------------------------------------------------------------------{
var color css = na
var lines   = array.new_line(0)
var hist_bars = array.new<histbar>(0)

if barstate.isfirst
    color rand_css = na

    //Populate levels
    for i = 0 to show-1
        //Levels color
        if lineCol == 'Random'
            rand_css := color.rgb(math.random(0,255), math.random(0,255), math.random(0,255))
        else
            rand_css := fixed_col

        //Line style
        style = switch lvlStyle
            '- - -' => line.style_dashed
            '· · ·' => line.style_dotted
            => line.style_solid
            
        lines.push(line.new(na,na,na,na
          , color = rand_css
          , extend = extend.left
          , style = style))
        
        //Populate histogram bars
        if i < show-1 and show_hist
            hist_bars.push(histbar.new(box.new(na,na,na,na,na, bgcolor = upCol), box.new(na,na,na,na,na, bgcolor = dnCol)))

//-----------------------------------------------------------------------------}
//Get liquidity levels values
//-----------------------------------------------------------------------------{
var pals = array.new<float>(0)

phv = ta.pivothigh(volume,length,length)

//On volume peak
if phv
    pals.unshift(close[length])

    if pals.size() > show
        pals.pop()

//-----------------------------------------------------------------------------}
//Display levels/histogram
//-----------------------------------------------------------------------------{
n = bar_index

if barstate.islast
    //Sort liquidity levels values (required for binary search)
    pals.sort()

    //Set levels
    for [index, element] in pals
        get = lines.get(index)
        get.set_xy1(n-1, element)
        get.set_xy2(n, element)

        if lineCol == 'Relative'
            get.set_color(close > element ? relativeColUp : relativeColDn)

    //Compute histogram
    bull  = array.new<int>(show-1, 0)
    bear = array.new<int>(show-1, 0)
    if show_hist
        //Iterate trough calculation window
        for i = 0 to distwin-1
            //Look where current close lies within liquidity levels and return index
            idx = pals.binary_search_rightmost(close[i])

            //Test if price lies within valid liquidity levels range and update count
            if idx >= 1 and idx < show
                if close[i] > open[i]
                    get = bull.get(idx-1)
                    bull.set(idx-1, get + 1)
                else
                    get = bear.get(idx-1)
                    bear.set(idx-1, get + 1)
        
        //Set histogram
        for [index, element] in hist_bars
            element.bull.set_rightbottom(n+bull.get(index), pals.get(index+1))
            element.bull.set_lefttop(n, pals.get(index))
            
            element.bear.set_rightbottom(n+bull.get(index)+bear.get(index), pals.get(index+1))
            element.bear.set_lefttop(n+bull.get(index), pals.get(index))

//-----------------------------------------------------------------------------}
````
