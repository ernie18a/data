<!-- tradingview-pine-id: PUB;cadbb4cd9a934f43bb6ce05010ec2b96 -->
<!-- tradingviewscripts-format: 1 -->
# DeltaFlow Volume Profile [BigBeluga]

Source: https://www.tradingview.com/script/JUWuAXdx-DeltaFlow-Volume-Profile-BigBeluga/

## Description

🔵 OVERVIEW
The DeltaFlow Volume Profile [BigBeluga] builds a compact volume profile next to price and enriches every bin with flow context: bullish vs. bearish participation (%), a per-bin Delta %, an optional Delta Heat Map, and a PoC band with the bin’s absolute volume. This lets you see not just where volume clustered, but who (buyers or sellers) dominated inside each price slice.

🔵 CONCEPTS

[*] Binned Volume Profile: Price range over a user-defined LookBack is split into Bins; each bin aggregates traded volume.
[image]https://www.tradingview.com/x/Sy4pxBY9/[/image]
[*] Bull/Bear Split: Within every bin, volume is separated by candle direction into Bull Volume and Bear Volume, then normalized to % of the bin’s displayed size.
[image]https://www.tradingview.com/x/Sy4pxBY9/[/image]
[*] Delta %: The difference between Bull % and Bear % for the bin. Positive = buyer dominance; negative = seller dominance.
[image]https://www.tradingview.com/x/AXbmjVoD/[/image]
[*] Delta Heat Map: Bin background shading that scales with both total volume strength and delta bias.
[image]https://www.tradingview.com/x/L2MRee0i/[/image]
[*] PoC (Point of Control): The most significant bin gets a PoC band and a label with its absolute volume.
[image]https://www.tradingview.com/x/QhcMBeDO/[/image]

🔵 FEATURES

[*] Profile with Flow: A clean horizontal volume bar per bin plus stacked Bull % and Bear %.
[*] Per-Bin Delta Label: A readable “Δ xx%” tag at the start of each bin shows dominance at a glance.
[*] Delta Heat Map: Optional gradient that intensifies with higher volume and stronger delta.
[*] PoC Highlight: Optional PoC band colored separately, labeled with absolute volume (e.g., “1.23M”).
[*] Configurable Inputs: LookBack, number of Bins (10–100), toggles for Delta, Heat Map, Volume Bars, and PoC color.
[*] Readable Colors: Separate inputs for bullish (volume +) and bearish (volume –) hues.

🔵 HOW TO USE

[*] Set the window: Choose LookBack and Bins to balance detail vs. performance (more bins = finer resolution).
[*]Enable “Volume Bars” to display the bull/bear split as two stacked percent bars inside each bin.

[*] High Bull % near support → constructive demand.
[*] High Bear % near resistance → active supply.

[*] Use Δ labels (toggle “Delta”) to quickly spot bins with clear buyer/seller control; combine with price position for confluence.
[*] Turn on Delta Heat Map to prioritize areas with both large volume and strong imbalance.
[*] Watch the PoC: The PoC band marks the most traded (and often magnet) level; its label shows absolute size for context.

Trade ideas:
[*] Breakout continuation when Δ stays positive across consecutive upper bins.
[*] Reversion risk when price enters a large bearish-Δ cluster below.
[*] Manage risk around the PoC; reactions there can be sharp.

🔵 CONCLUSION
DeltaFlow Volume Profile [BigBeluga] upgrades a classic profile with flow intelligence. The bull/bear split, explicit Δ %, heat-weighted backdrop, and PoC volume label make dominant participation and key price shelves obvious. Use it to filter levels, time entries with imbalance, and validate breakouts or fades with objective volume-flow evidence.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("DeltaFlow Volume Profile [BigBeluga]", overlay = true, max_boxes_count = 500)
plot(na)


// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
lookBack     = input.int(200, "LookBack")
binsAmount   = input.int(30, "Bins", maxval = 100, minval = 10)
offset       = input.int(5)

deltaHeatMap = input.bool(true, "Delta Heat Map", group = "Features")
deltaDisplay = input.bool(true, "Delta", group = "Features")
volumeBars   = input.bool(true, "Volume Bars", group = "Features")
pocDisplay   = input.bool(true, "", inline = "poc", group = "Features")
pocColor     = input.color(color.rgb(0, 183, 255), "PoC Color", inline = "poc", group = "Features")

bullcolor    = input.color(color.teal, "Volume +/-", inline = "vol")
bearcolor    = input.color(color.rgb(230, 150, 30), "", inline = "vol")


type vp_ 
    array<float> volumeArry
    array<float> bearVolume
    array<float> bullVolume
    

vp = vp_.new(array.new<float>(binsAmount, 0.), array.new<float>(binsAmount, 0.), array.new<float>(binsAmount, 0.))

MaxMin     = array.new<float>()
var boxes  = array.new<box>()
// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if barstate.islast

    if boxes.size() > 0 
        for b in boxes 
            b.delete()


    for i = 0 to lookBack 
        MaxMin.push(high[i])
        MaxMin.push(low[i])


    top = MaxMin.max()
    bot = MaxMin.min()
    step = (top-bot)/binsAmount

    for i = 0 to lookBack

        price = close[i]
        isBear = close[i] < open[i]
        voll = volume[i]


        for k = 0 to binsAmount - 1
            lower = bot + step * k
            mid   = lower + step/2

            if math.abs(mid - price) <= step 
                vp.volumeArry.set(k, vp.volumeArry.get(k) + voll)

                if isBear 
                    vp.bearVolume.set(k, vp.bearVolume.get(k) + voll)
                else 
                    vp.bullVolume.set(k, vp.bullVolume.get(k) + voll)



// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
    for i = 0 to binsAmount - 1

        start = bar_index + 100+offset

        volumeArryvalue = vp.volumeArry.get(i)

        lower = bot + step * i 
        upper = lower + step 
        mid   = lower + step /2
        vol   = int(vp.volumeArry.get(i) / vp.volumeArry.max() * 100)

        bullV = math.floor(vp.bullVolume.get(i) / vp.volumeArry.max() * 100)
        bearV = math.floor(vp.bearVolume.get(i) / vp.volumeArry.max() * 100)

        size  = (start - start-vol) 

        bullsPercent = math.abs(bullV/size*100)
        bearsPercent = math.abs(bearV/size*100)

        bullsPercent := bullsPercent > 100 ? 100 : bullsPercent

        delta       = bullsPercent - bearsPercent
        deltaColor  = color.from_gradient(delta, -30, 30, bearcolor, bullcolor)

        box poc      = na 
        box labelBox = na
        box MapBody  = na
        box bulls    = na
        box bears    = na 

        if deltaHeatMap  
            MapBody  := box.new(start-lookBack-50-vol, upper, start, lower, border_color = chart.bg_color, border_width = 0, bgcolor = color.from_gradient(vol, 0, 100, color.new(deltaColor, 100), color.new(deltaColor, 70)))
        if vol == 100 and pocDisplay
            poc := box.new(start-lookBack-50-vol, upper, start, lower, border_color = pocColor, border_width = 1, bgcolor = na, text = str.tostring(volumeArryvalue, format.volume), text_color = chart.fg_color)
        if deltaDisplay
            labelBox := box.new(start+15, upper, start, lower, border_color = chart.bg_color, border_width = 1, bgcolor = color.new(deltaColor, 80), text = "Δ " + str.tostring(delta, format.percent), text_color = deltaColor)  

        body        = box.new(start-vol, upper, start, lower, border_color = chart.bg_color, border_width = 1, bgcolor = color.new(deltaColor, 50))

        if volumeBars
            bulls  := box.new(start-bullV, mid, start, lower, bgcolor = bullcolor, border_color = chart.bg_color, border_width = 1, text = str.tostring(bullsPercent, format = format.percent), text_halign = text.align_right)
            bears  := box.new(start-bearV, upper, start, mid, bgcolor = bearcolor, border_color = chart.bg_color, border_width = 1, text = str.tostring(bearsPercent, format = format.percent), text_halign = text.align_right)

 
        boxes.push(poc)
        boxes.push(labelBox)
        boxes.push(MapBody)
        boxes.push(body)
        boxes.push(bulls)
        boxes.push(bears)
// }
````
