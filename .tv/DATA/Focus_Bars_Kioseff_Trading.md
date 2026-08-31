<!-- tradingview-pine-id: PUB;476d976353d84805a9b87cd085c9c864 -->
<!-- tradingviewscripts-format: 1 -->
# Focus Bars [Kioseff Trading]

Source: https://www.tradingview.com/script/I0MhUmSK-Focus-Bars-Kioseff-Trading/

## Description

Hello Traders!

🔹Focus Bars

Focus Bars is a lower-timeframe reconstruction tool designed to break each candle into a price-based internal structure.

Instead of viewing a bar as a single OHLC print, this tool redistributes intrabar participation across price levels, showing where activity, delta, and directional pressure concentrated inside the bar itself.

Think of it as a way to look inside the candle.

 [*]intrabar participation distributed by price level
 [*]buy vs sell pressure mapped inside each bar
 [*]delta-driven visualization of internal structure
 [*]volume-based or delta-based profile sizing
 [*]stacked recent bars for direct comparison
 [*]lower timeframe reconstruction of candle internals (up to 1 tick)
 

🔹What the tool shows

🔸Focus Bar Structure

Each visible bar is reconstructed using lower timeframe data and divided into configurable price rows.

This allows the script to build an internal map of activity inside the candle, showing how participation distributed throughout its range.
This helps reveal:

 [*]where activity concentrated inside the bar
 [*]which price regions attracted the most interaction
 [*]how the bar built from low to high
 

[image]https://www.tradingview.com/x/o8fMee3b/[/image] 

🔸Directional participation

The script estimates directional pressure using lower timeframe price movement and distributes that pressure across the bar’s traded range.

This allows you to observe:

 [*]where buying pressure was strongest
 [*]where selling pressure dominated
 [*]how directional activity distributed through the candle
 

Instead of treating the candle as one net result, Focus Bars breaks it into a layered participation structure.

🔸Volume mode

In its default form, the profile width reflects total intrabar participation at each price level.

This helps identify:

 [*]high activity zones inside the bar
 [*]areas where the market spent more effort
 [*]internal high-interest regions
 

This mode focuses on where the bar traded most actively, regardless of which side was dominant.

[image]https://www.tradingview.com/x/4ChwYw6x/[/image] 

🔸Delta Bars mode

When Delta Bars mode is enabled, the visualization shifts from general activity to directional imbalance.

Positive delta levels extend one way, while negative delta levels extend the other, helping expose where directional pressure accumulated inside the bar.

This makes it easier to see:

 [*]which prices were dominated by buyers
 [*]which prices were dominated by sellers
 [*]where internal imbalance became most extreme
 

This mode is about pressure and imbalance, not just participation.

[image]https://www.tradingview.com/x/5SvHJH4C/[/image] 

🔸Recent bar stacking

The script displays multiple recent reconstructed bars side by side, allowing you to compare internal structure across the most recent candles.

This helps reveal:

 [*]whether participation is shifting higher or lower
 [*]whether recent bars are building similarly or differently
 [**]how internal pressure changes from one bar to the next
 

Rather than looking at candles in isolation, you get a stacked structural view of recent bar development.

🔸Price-row resolution

Each bar is divided into a configurable number of rows.
Higher row counts provide finer structural detail, while lower row counts simplify the visualization.

This lets you control the balance between:

 [*]detail
 [*]clarity
 [*]performance
 

🔸Lower timeframe reconstruction

The script uses lower timeframe data to estimate how participation distributed through each candle.

Granularity can be selected between:

 [*]1-minute
 [*]1-second
 [*]1-tick
 
This allows the internal structure to become more detailed as lower granularity data becomes available.

🔸Buy / sell volume labels

Each price row includes separate displayed values for:

 [*]sell-side participation
 [*]buy-side participation
 

This gives a direct read on how activity distributed at each level, rather than relying only on color or profile width.

🔸Gradient-based intensity

Color gradients help represent the magnitude of participation and directional pressure at each price level.

This makes it easier to spot:

 [*]high-intensity zones
 [*]low-interest areas
 [*]strong directional concentrations
 

Stronger color intensity reflects stronger internal participation or imbalance.

🔹How to read it

Each component gives a different layer of information:
Candle body / wick → the outer structure of the bar
 Profile width → where participation concentrated
 Delta mode → where directional imbalance built
 Buy / sell labels → how each side contributed at a level
 Stacking → how internal structure changes bar to bar

🔹Why this tool is useful

It gives you:

 [*]a way to look inside candles instead of only at candle outcomes
 [*]price-based intrabar participation mapping
 [*]clear visualization of internal volume and delta structure
 [*]context for where buying or selling pressure concentrated
 [**]a deeper structural view of recent bar development
 
🔹Best use cases

 [*]analyzing internal candle structure
 [*]comparing recent bars side by side
 [*]spotting hidden participation concentrations
 [*]finding where directional pressure built inside a move
 [**]adding lower-timeframe context to bar-by-bar analysis
 
🔹Important note

This tool uses lower timeframe data to reconstruct intrabar structure.
This means:

 [*]it is an approximation of internal order flow
 [*]accuracy depends on available lower timeframe data
 [*]selected granularity impacts precision
 [*]different symbols and data feeds may produce different levels of detail
 
🔹Inputs you can customize

The script includes flexible controls such as:

 [*]granularity selection
 [*]bar count to display
 [*]row resolution
 [*]volume mode vs Delta Bars mode
 [*]color customization
 [*]display offset
 
Closing Notes

Focus Bars is built to shift the focus from how a candle finished to how it developed internally.

It helps reveal not just what the bar looked like from the outside, but where participation and pressure were concentrated inside it.
Thank you for checking it out!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=6
indicator("Focus Bars [Kioseff Trading]", overlay = false, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100, max_bars_back = 5000)

enum granularity

    m5 = "5-Minute"
    m1 = "1-Minute"  
    s1 = "1-Second"  
    t1 = "1-Tick"  
//
// 
// 
gran                = input.enum(defval = granularity.m1, title = "Granularity", options = [granularity.m5, granularity.m1, granularity.s1, granularity.t1])
deltaBars           = input.bool(defval = true, title = "Delta Bars", group = "Focus Mode")
bars                = input.int(defval = 5, title = "Bars To Show", group = "Focus Mode", minval = 1, maxval = 8)
rows                = input.int(defval = 20, minval = 5, maxval = 150, title = "Rows", group = "Focus Mode")
upColAdv2           = input.color(defval = #96d3c8, title = "Buy-Side Color", inline = "ADV UP", group = "Focus Mode"), upColAdv = input.color(defval = #00ffff, title = "", inline = "ADV UP", group = "Focus Mode")
dnColAdv2           = input.color(defval = #d39696, title = "Sell-Side Color", inline = "ADV DN", group = "Focus Mode"), dnColAdv = input.color(defval = #8f1b1b, title = "", inline = "ADV DN", group = "Focus Mode")
advCol              = input.color(defval = color.white, title = "Text Color", group = "Focus Mode")
masterOffset        = input.int(defval = -30, title = "Bars Offset", group = "Focus Mode")

var tf = switch gran

    granularity.m1  => "1"
    granularity.s1  => "1S"
    granularity.t1  => "1T"


type deepBar 

    box candleBox 
    line wickUpper 
    line wickLower
    array<box> vpBoxes 


direction() => 

    if gran == granularity.t1

        switch 

            close == bid => -1 
            close == ask =>  1
            =>               math.sign(close - close[1]) 
        
    else 

        math.sign(close - close[1])

advancedView() => 

    if last_bar_index - bar_index <= bars - 1

        [adV, adH, adL] = request.security_lower_tf("", tf, [volume * direction(), high, low], ignore_invalid_timeframe = true)

        Range = (high - low) / rows 

        levels   = array.new<float>(rows, 0)
        delta    = array.new<float>(rows, 0)
        buyVol   = array.new<float>(rows, 0)
        sellVol  = array.new<float>(rows, 0)
        totalVol = array.new<float>(rows, 0)

        var deepBars = array.new<deepBar>()

        var offset = switch deltaBars 

            false => 45
            =>       60

        if adV.size() > 0
            
            for i = 0 to rows - 1
                levels.set(i, low + Range * i)

            for [i, data] in adV 

                top = levels.binary_search_leftmost (adH.get(i))
                bot = levels.binary_search_leftmost (adL.get(i))

                div = data / (math.abs(top - bot) + 1)

                for x = bot to top 

                    absDiv = math.abs(div)

                    delta.set(x, delta.get(x) + div)
                    totalVol.set(x, totalVol.get(x) + absDiv)

                    switch math.sign(div)

                        1  => buyVol.set(x, buyVol.get(x) + div)
                        -1 => sellVol.set(x, sellVol.get(x) + absDiv)        

        

            col = switch close >= open 

                true => upColAdv
                =>      dnColAdv


            absDelta = delta.abs()

            minDelta = absDelta.min(), maxDelta = absDelta.max()

            maxVol = totalVol.max()
            minVol = totalVol.min()

            slot  = last_bar_index - bar_index
            xBase = last_bar_index + 5 - slot * offset

            deepBars.push(deepBar.new(
                box.new(xBase, math.max(open, close), xBase + 10, math.min(open, close), bgcolor = col, border_color = chart.bg_color),
                line.new(xBase + 5, math.max(open, close), xBase + 5, high, color = col),
                line.new(xBase + 5, math.min(open, close), xBase + 5, low, color = col),
                array.new<box>()
            ))

            last = deepBars.last()


            highestDelta = delta.max(), lowestDelta = delta.min()

            for i = 0 to rows - 1

                level = levels.get(i)

                deltaAdv    = delta.get(i)
                absDeltaAdv = math.abs(deltaAdv) 
                totalVolAdv = totalVol.get(i)

                norm = switch deltaBars 

                    false => math.round(1 + (((totalVolAdv - minVol) / (maxVol - minVol)) * 15))
                    =>       math.round(1 + (((absDeltaAdv - minDelta) / (maxDelta - minDelta)) * 15))

                bgcol = switch math.sign(deltaAdv)

                    1 => color.from_gradient(absDeltaAdv, minDelta, maxDelta, upColAdv2, upColAdv)
                    =>   color.from_gradient(absDeltaAdv, minDelta, maxDelta, dnColAdv2, dnColAdv)

                left = xBase + 12, right = xBase + 12 + norm

                if deltaBars and math.sign(deltaAdv) == -1 

                    right  := xBase - 2 
                    left := xBase - 2 - norm

                textColBuy = switch 

                    deltaAdv == highestDelta => upColAdv
                    =>                          advCol  

                textColSell = switch 

                    deltaAdv == lowestDelta => dnColAdv
                    =>                         advCol

                last.vpBoxes.push(box.new(left, level + Range, right, level, border_color = chart.bg_color, bgcolor = color.new(bgcol, 0)))
                last.vpBoxes.push(box.new(xBase + 29, level + Range, xBase + 34, level, border_color = #00000000, bgcolor = #00000000, text_color = textColSell, text = str.tostring(sellVol.get(i), format.volume)))
                last.vpBoxes.push(box.new(xBase + 34, level + Range, xBase + 39, level, border_color = #00000000, bgcolor = #00000000, text_color = textColBuy, text = str.tostring(buyVol.get(i), format.volume)))
    

        if barstate.islast 

            size = deepBars.size() 

            if size > bars

                first = deepBars.first()

                first.candleBox.delete()
                first.wickUpper.delete()
                first.wickLower.delete()
                
                for boxes in first.vpBoxes

                    boxes.delete()

                deepBars.shift()

                size := deepBars.size()

            if size > 0

                for i = 0 to size - 1

                    ind = deepBars.get(i)

                    xBase = bar_index + 5 - ((size - 1 - i) * offset)

                    currLeft  = ind.candleBox.get_left()
                    currRight = ind.candleBox.get_right()
                    shift     = xBase - currLeft + masterOffset

                    ind.candleBox.set_left(currLeft + shift)
                    ind.candleBox.set_right(currRight + shift)

                    ind.wickUpper.set_x1(ind.wickUpper.get_x1() + shift)
                    ind.wickUpper.set_x2(ind.wickUpper.get_x2() + shift)

                    ind.wickLower.set_x1(ind.wickLower.get_x1() + shift)
                    ind.wickLower.set_x2(ind.wickLower.get_x2() + shift)

                    for boxes in ind.vpBoxes
                        
                        boxes.set_left(boxes.get_left() + shift)
                        boxes.set_right(boxes.get_right() + shift)

      
advancedView()
````
