<!-- tradingview-pine-id: PUB;2c659ee0a8244e9db2a7fb7f98e98d5d -->
<!-- tradingviewscripts-format: 1 -->
# Range Sentiment Profile [LuxAlgo]

Source: https://www.tradingview.com/script/5UuBjDYO-Range-Sentiment-Profile-LuxAlgo/

## Description

The Range Sentiment Profile indicator is inspired from the volume profile and aims to indicate the degree of bullish/bearish variations within equidistant price areas inside the most recent price range.

The most bullish/bearish price areas are highlighted through lines extending over the entire range.

🔶 SETTINGS

[*]Length: Most recent bars used for the calculation of the indicator.
[*]Rows: Number of price areas the price range is divided into.
[*]Use Intrabar: Use intrabar data to compute the range sentiment profile.
[*]Timeframe: Intrabar data timeframe.

🔶 USAGE

[image]https://www.tradingview.com/x/G3L5vP5l/[/image]

This tool can be used to easily determine if a certain price area contain more significant bullish or bearish price variations. This is done by obtaining an estimate of the accumulation of all the close to open variations occurring within a specific profile area.

A blue range background indicates a majority of bullish variations within each area while an orange background indicates a majority of bearish variations within each area.

[image]https://www.tradingview.com/x/zrcRdMMq/[/image]

Users can easily identify the areas with the most bullish/bearish price variations by looking at the bullish/bearish maximums.

[image]https://www.tradingview.com/x/DqSgGEav/[/image]

It can be of interest to see where profile bins might have no length, these can indicate price areas with price variations with alternating signs (bullish variations are followed by a bearish sign) and similar body. They can also indicate a majority of either bullish or bearish variations alongside a minority of more significant opposite variations.

These areas can also provide support/resistance, as such price entering these areas could reverse.

[image]https://www.tradingview.com/x/Z0qJqZEP/[/image]

Users can obtain more precise results by allowing the profile to use intrabar data. This will change the calculation of the profile, see the details section for more information.

🔶 DETAILS

The Range Sentiment Profile's design is similar to the way a volume profile is constructed.

First the maximum/minimum values over the most recent Length bars are obtained, these define the calculation range of the profile.

The range is divided into Rows equidistant areas. We then see if price lied within a specific area, if it's the case we accumulate the difference between the closing and opening price for that specific area.

Let d = close - open. The length of the bin associated to a specific area is determined as follows:

[pine]length = Width / 100 * Area / Max[/pine]

Where Area is the accumulated d within the area, and Max the maximum value between the absolute value of each accumulated d of all areas.

The percentage visible on each bin is determined as 100 multiplied by the accumulated d within the area divided by the total absolute value of d over the entire range.

🔹 Intrabar Calculation

When using intrabar data the range sentiment profile is calculated differently. 

For a specific area and candle within the interval, the accumulated close to open difference is accumulated only if the intrabar candle of the user selected timeframe lies within the area.

This can return more precise results compared to the standard method, at the cost of a higher computation time.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=5
indicator("Range Sentiment Profile [LuxAlgo]", overlay = true, max_boxes_count = 500)
//------------------------------------------------------------------------------
//Tooltips
//-----------------------------------------------------------------------------{
widthTooltip  = "Bin width percentage. Determine the length of the returned profile bin as a percentage of the Length setting"
offsetTooltip = "Determine the amount of bars each graphical elements are shifted by"

//-----------------------------------------------------------------------------}
//Settings
//-----------------------------------------------------------------------------{
length = input.int(80, minval = 2)
rows   = input.int(20, minval = 2)
useIb  = input(false, 'Use Intrabar', inline = 'intrabar') 
tf     = input.timeframe('1', ''    , inline = 'intrabar')

//Style
width     = input.float(20, 'Width %', minval = 0, maxval = 100, group = 'Style', tooltip = widthTooltip)

showRange = input(true, 'Show Range Levels', inline = 'range', group = 'Style')
rangeCss  = input(color.gray, ''         , inline = 'range', group = 'Style')

bullBin   = input(#2157f3, 'Bullish Bin', inline = 'bull', group = 'Style')
bullMax   = input(true, 'Maximum'         , inline = 'bull', group = 'Style') 
bearBin   = input(#ff5d00, 'Bearish Bin', inline = 'bear', group = 'Style')
bearMax   = input(true, 'Minimum'         , inline = 'bear', group = 'Style')

showFill = input(true, 'Show Fill'             , inline = 'fill', group = 'Style')
bullFill = input(color.new(#2157f3, 90), ''  , inline = 'fill', group = 'Style')
bearFill = input(color.new(#ff5d00, 90), ''  , inline = 'fill', group = 'Style')

offset = input.int(8, group = 'Style', tooltip = offsetTooltip)

//-----------------------------------------------------------------------------}
//Function
//-----------------------------------------------------------------------------{
get_data() => [close, open]

//-----------------------------------------------------------------------------}
//Main variables
//-----------------------------------------------------------------------------{
var boxes = array.new<box>(0)

//Populate bins array
if barstate.isfirst
    for i = 0 to rows-1
        boxes.push(box.new(na,na,na,na,na
          , text_valign = text.align_center
          , text_color = color.white))

n = bar_index
upper = ta.highest(length)
lower = ta.lowest(length)
sumad = math.sum(math.abs(close - open), length)

//Get intrabar data
[get_close, get_open] = request.security_lower_tf(syminfo.tickerid, tf, get_data())

//-----------------------------------------------------------------------------}
//Set profile
//-----------------------------------------------------------------------------{
//Range levels
var ltop = line.new(na,na,na,na, color = rangeCss)
var l75  = line.new(na,na,na,na, color = rangeCss, style = line.style_dashed)
var l50  = line.new(na,na,na,na, color = rangeCss)
var l25  = line.new(na,na,na,na, color = rangeCss, style = line.style_dashed)
var lbtm = line.new(na,na,na,na, color = rangeCss)
var fill = linefill.new(ltop, lbtm, na)

//Max / Min levels
var bull_max = line.new(na,na,na,na, color = bullBin)
var bear_min = line.new(na,na,na,na, color = bearBin)

//Set profile
if barstate.islast
    avg = math.avg(upper, lower)
    avg75 = math.avg(upper, avg)
    avg25 = math.avg(lower, avg)

    //Set lines coordinates
    ltop.set_xy1(n - length, upper), ltop.set_xy2(n + offset, upper)
    lbtm.set_xy1(n - length, lower), lbtm.set_xy2(n + offset, lower)
    
    //Display range levels
    if showRange
        l75.set_xy1(n - length, avg75) , l75.set_xy2(n + offset, avg75)
        l50.set_xy1(n - length, avg)   , l50.set_xy2(n + offset, avg)
        l25.set_xy1(n - length, avg25) , l25.set_xy2(n + offset, avg25)
    else
        ltop.set_color(na)
        lbtm.set_color(na)

    //Get bullish/absolute delta sums for each row
    up = upper
    dn = upper
    sums     = array.new_float(0)
    sums_abs = array.new_float(0)

    //Loop trough each rows
    for i = 0 to rows-1
        dn -= (upper - lower) / rows
        sum = 0.
        den = 0.
        
        //Loop trough most recent bars
        for j = 0 to length-1
            if useIb //Loop trough intrabar prices
                for k = 0 to (get_close[j]).size()-1
                    c = (get_close[j]).get(k)
                    o = (get_open[j]).get(k)
                    sum += math.max(c, o) <= up and math.min(c, o) >= dn ? c - o : 0
            else
                sum += high[j] > dn and low[j] < up ? close[j] - open[j] : 0
        
        sums.push(sum)
        sums_abs.push(math.abs(sum))

        up := dn

    //Set profile bins
    max = sums_abs.max()
    up := upper
    dn := upper
    
    for [index, element] in sums
        dn -= (upper - lower) / rows
        x2 = n + int(element / max * length * (width / 100))
        
        css = element > 0 ? color.new(bullBin, 50) : color.new(bearBin, 50)

        //Set box coordinates
        get_bx = boxes.get(index)
        get_bx.set_lefttop(n + offset, .9 * up + .1 * dn)
        get_bx.set_rightbottom(x2 + offset, .9 * dn + .1 * up)
        get_bx.set_bgcolor(css)
        get_bx.set_text(str.tostring(element / sumad * 100, format.percent))
        
        //Set area MAX/MIN levels
        if element == sums.max() and bullMax
            bull_max_val = math.avg(up, dn)
            bull_max.set_xy1(n + offset, bull_max_val)
            bull_max.set_xy2(n - length, bull_max_val)

        if element == sums.min() and bearMax
            bear_min_val = math.avg(up, dn)
            bear_min.set_xy1(x2 + offset, bear_min_val)
            bear_min.set_xy2(n - length, bear_min_val)
            
        up := dn
    
    //Fill Area
    if showFill
        fill.set_color(sums.sum() > 0 ? color.new(bullBin, 90) : color.new(bearBin, 90))

//-----------------------------------------------------------------------------}
````
