# Heatmap Liquidity Zones [BigBeluga]

- url: https://www.tradingview.com/script/IHYNdWb1-Heatmap-Liquidity-Zones-BigBeluga/
- type: indicator
- pine_id: PUB;3d74d85b0ebc4a2ba0217a9c13c63b2c
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]  
[b]Heatmap Liquidity Zones [BigBeluga][/b] is a higher-timeframe volume heatmap tool designed to reveal where liquidity is concentrated inside institutional ranges.

Instead of plotting a traditional volume profile, this indicator builds a dynamic heatmap across each selected higher-timeframe candle.  
It highlights high-volume price clusters, filters significant liquidity zones, and extends them forward as actionable support/resistance levels.

[image]https://www.tradingview.com/x/V20zw2Mz/[/image]

The result is a clean liquidity map that visualizes where participation is strongest — and where reactions are most likely to occur.

[b]🔵 CORE CONCEPT[/b]  
[list]
[*][b]HTF Range Segmentation[/b] — Each higher-timeframe candle (D/W/M or custom) defines a new accumulation range.
[*][b]ATR-Based Adaptive Binning[/b] — Vertical bin size is derived from ATR to maintain consistent resolution across volatility regimes.
[*][b]Volume Density Mapping[/b] — Volume is distributed into price bins and normalized relative to the highest-volume bin.
[*][b]Liquidity Filtering[/b] — Only bins exceeding a configurable percentage threshold are promoted to active liquidity levels.
[*][b]Self-Cleaning Zones[/b] — Liquidity levels automatically disappear once breached by price.
[/list]


[b]🔵 HOW IT WORKS[/b]

[b]1️⃣ Higher-Timeframe Reset Logic[/b]  
[list]
[*] When a new selected HTF candle begins, the previous range is finalized.
[*] A new accumulation range starts from that bar.
[*] High and Low are tracked dynamically throughout the segment.
[image]https://www.tradingview.com/x/kxROmNAV/[/image]
[/list]

[b]2️⃣ ATR-Based Bin Construction[/b]  
[list]
[*] ATR defines the vertical bin size (ATR × Multiplier).
[*] The total range is divided into up to Max Bins.
[*] This ensures bin resolution adapts automatically to volatility.
[image]https://www.tradingview.com/x/wdOEp3lo/[/image]
[/list]

[b]3️⃣ Volume Distribution[/b]  
[list]
[*] For each completed segment, volume is distributed into bins based on proximity to bin midpoint.
[*] Volume per bin is normalized relative to the maximum bin.
[*] Each bin is assigned a heat color based on relative density:
    [list]
    [*] Low Density → Purple
    [*] Mid Density → Cyan
    [*] High Density → Yellow
    [/list]
[image]https://www.tradingview.com/x/E3zTjhXS/[/image]
[/list]

[b]4️⃣ Liquidity Zone Creation[/b]  
[image]https://www.tradingview.com/x/StFTNi0P/[/image]
[list]
[*] If a bin exceeds the Liquidity Filter %, it becomes a tracked liquidity level.
[image]https://www.tradingview.com/x/oQWWQvz5/[/image]
[*] Liquidity levels extend forward as horizontal lines.
[*] The thickness is controlled by Liquidity Level Width.
[*] Stronger zones display larger markers and percentage labels.
[image]https://www.tradingview.com/x/2GhluVAT/[/image]
[/list]

[b]🔵 HEATMAP VISUAL STRUCTURE[/b]  
[list]
[*] Completed segments display full heatmap boxes across the range.
[*] Active segment updates in real time.
[*] Color intensity reflects liquidity concentration.
[*] High-density zones stand out clearly for institutional reference.
[/list]


[b]🔵 OPTIONAL MOVING AVERAGE[/b]  
[list]
[*] Optional smoothing MA overlay (SMA, EMA, RMA, WMA, VWMA).
[*] Hidden by default.
[*] Can be used for confluence with liquidity zones.
[image]https://www.tradingview.com/x/tZm7RGx1/[/image]
[/list]


[b]🔵 KEY FEATURES[/b]  
[list]
[*] Higher-timeframe segmented liquidity mapping.
[*] ATR-based adaptive resolution.
[*] Three-stage heatmap gradient.
[*] Configurable liquidity filtering.
[*] Auto-expiring support/resistance levels.
[*] Dynamic zone thickness based on volume strength.
[*] Real-time developing heatmap.
[*] Optional MA overlay.
[/list]


[b]🔵 HOW TO USE[/b]  
[list]
[*] Focus on yellow (high-density) zones for strongest liquidity pools.
[*] Watch reactions at filtered liquidity levels.
[*] Use HTF segmentation (Weekly/Monthly) to identify institutional positioning.
[*] Combine with breakout tools for liquidity sweep setups.
[*] Lower ATR multiplier → more granular liquidity clusters.
[*] Higher Liquidity Filter % → only strongest zones remain.
[/list]


[b]🔵 INTERPRETING LIQUIDITY[/b]  
[list]
[*] High density near highs → potential distribution.
[*] High density near lows → potential accumulation.
[*] Clustered zones → compression areas before expansion.
[*] Thin zones → low participation, faster price movement potential.
[/list]


[b]🔵 CONCLUSION[/b]  
[b]Heatmap Liquidity Zones [BigBeluga][/b] transforms higher-timeframe volume into a structured liquidity map.

By combining ATR-adaptive binning, density-based heat gradients, and intelligent liquidity filtering, it highlights where institutional participation is concentrated — and where meaningful reactions are most likely.

This makes it especially powerful for identifying liquidity pools, sweep zones, and structural turning points.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Heatmap Liquidity Zones [BigBeluga]", overlay = true
            , max_boxes_count = 500
            , calc_bars_count = 4000
            , max_lines_count = 500
            , max_bars_back = 5000
            , max_labels_count = 500)


// Inputs 
// Inputs 
tf = input.timeframe(
     "W",
     "Higher Timeframe",
     tooltip = "Select the higher timeframe used to build volume heatmap ranges.\nEach new HTF candle resets the accumulation range."
)

atrLen = 100

atrMult = input.float(
     0.25,
     "Bin Size Multiplier",
     step = 0.05,
     minval = 0.0001,
     tooltip = "Multiplier applied to ATR to define vertical bin size.\nLower values create more detailed heatmap resolution.\nHigher values create broader liquidity zones."
)

maxBins = input.int(
     40,
     "Max Bins",
     minval = 10,
     maxval = 100,
     tooltip = "Maximum number of price bins inside each HTF range.\nHigher values increase precision but use more resources."
)

liquidityFilter = input.float(
     0,
     "Liquidity Filter %",
     minval = 0,
     maxval = 100,
     tooltip = "Minimum relative volume (percentage of peak bin volume) required to mark a liquidity level.\nHigher values filter weaker zones."
)
liquidityWidth = input.int(
     5,
     "Liquidity Level Width",
     minval = 1,
     maxval = 10,
     tooltip = "Controls the thickness of drawn liquidity levels.\nHigher values make key zones more visually prominent."
)
liquidityExtend = input.int(
     25,
     "Liquidity Level Extend",
     minval = 0,

     tooltip = "Controls how far the levels are extended into the future from last bar."
)
heatColor2 = input.color(
     color.rgb(64, 17, 151, 90),
     "Low Density (0%–25%)",
     tooltip = "Color used for low volume density areas."
)

heatColor1 = input.color(
     color.rgb(27, 183, 255, 90),
     "Mid Density (25%–75%)",
     tooltip = "Color used for medium volume density areas."
)

heatColor3 = input.color(
     color.rgb(255, 235, 59, 50),
     "High Density (75%–100%)",
     tooltip = "Color used for highest liquidity zones."
)
tfChange  = timeframe.change(tf)

var max = 0.
var min = low
var start = 0


type level 
    int start 
    float lvl
    bool isRes
    float vol
    color color1
var Levels = array.new<level>()


atrValue = ta.atr(atrLen)
binSize  = atrValue * atrMult

if not tfChange
    max := math.max(max, high)
    min := math.min(min, low)

range_ = max - min

// Safe bin count (int) + guards
rawBins    = math.min(maxBins, int(math.floor(range_[1] / binSize)))
binSize1   = range_ / rawBins
volumeBins = array.new<float>(rawBins, 0.)


// Historical 
if tfChange
    for i = 0 to rawBins - 1
        ll = min[1] + binSize1[1] * i 
        mid = ll + binSize1[1]/2

        hh = ll + binSize1[1]

        for k = 0 to bar_index - start
            if math.abs(close[k]-mid) <= binSize1[1]
                volumeBins.set(i, volumeBins.get(i) + volume[k])

    for i = 0 to rawBins - 1
        ll = min[1] + binSize1[1] * i 
       
        hh  = ll + binSize1[1]
        vol = volumeBins.get(i) / volumeBins.max()
        
        col = vol <= 0.5 ? color.from_gradient(vol, 0, 0.5, heatColor2, heatColor1)
             : color.from_gradient(vol, 0.5, 1, heatColor1, heatColor3)

        col1 = vol <= 0.5 ? color.from_gradient(vol, 0, 0.5, color.new(heatColor2, 95), color.new(heatColor1, 95))
             : color.from_gradient(vol, 0.5, 1, color.new(heatColor1, 95), color.new(heatColor3, 95))

        box.new(start, hh, bar_index, ll
             , bgcolor = col
             , border_color = col1)

        if vol >= liquidityFilter/100
            mid = math.avg(hh, ll)
            Levels.push(level.new(bar_index, mid, low < mid, vol, col))



for s in Levels 

    if s.isRes
        if high > s.lvl 
            Levels.remove(Levels.indexof(s))
    else 
        if low < s.lvl 
            Levels.remove(Levels.indexof(s))


if not tfChange and barstate.islast

    var boxes = array.new<box>()
    var lines = array.new<line>()
    var labels = array.new<label>()

    for b in boxes 
        b.delete()
    boxes.clear()

    for b in lines 
        b.delete()
    lines.clear()

    for b in labels 
        b.delete()
    labels.clear()

    for i = 0 to volumeBins.size() - 1
        ll  = min[1] + binSize1[1] * i 
        mid = ll + binSize1[1]/2
        hh  = ll + binSize1[1]

        for k = 0 to bar_index - start
            if math.abs(close[k]-mid) <= binSize1[1]
                volumeBins.set(i, volumeBins.get(i) + volume[k])

    for i = 0 to volumeBins.size() - 1
        ll  = min[1] + binSize1[1] * i 
        hh  = ll + binSize1[1]
        vol = volumeBins.get(i) / volumeBins.max()

        col = vol <= 0.5 ? color.from_gradient(vol, 0, 0.5, heatColor2, heatColor1)
             : color.from_gradient(vol, 0.5, 1, heatColor1, heatColor3)

        col1 = vol <= 0.5 ? color.from_gradient(vol, 0, 0.5, color.new(heatColor2, 95), color.new(heatColor1, 95))
             : color.from_gradient(vol, 0.5, 1, color.new(heatColor1, 95), color.new(heatColor3, 95))

        b = box.new(start, hh, bar_index, ll
             , bgcolor = col
             , border_color = col1)

        boxes.push(b)



    for s in Levels 

        labelSize =
             s.vol < 0.30 ? size.tiny  :
             s.vol < 0.55 ? size.small :
             s.vol < 0.80 ? size.normal :
                             size.large

        if s.start >= bar_index-2000
            lines.push(
                line.new(s.start, s.lvl, bar_index+liquidityExtend, s.lvl, color = s.color1, width = liquidityWidth)
            )

            labels.push(label.new(bar_index+liquidityExtend, s.lvl, "", style = label.style_circle, size = labelSize, color = s.color1))


            if s.vol >= 0.5
                labels.push(label.new(bar_index+liquidityExtend, s.lvl, str.tostring(s.vol*100, format.percent), style = label.style_label_left, size = labelSize, color = color.new(chart.bg_color, 100), textcolor = s.color1))


var length = 2

length += 1


if tfChange
    max := high
    min := low
    start := bar_index
    length := 2




// Smoothing MA inputs
GRP = "Moving Average"
maTypeInput = input.string("None", "Type", options = ["None", "SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.none)
maLengthInput = input.int(25, "Length", group = GRP, display = display.none, inline = "len")
autoLength = input.bool(false, "Auto", group = GRP, display = display.none, inline = "len")
src = input(close, title="Source", group = GRP)

pine_ema(src, length) =>
    alpha = 2 / (length + 1)
    sum = 0.0
    sum := na(sum[1]) ? src : alpha * src + (1 - alpha) * nz(sum[1])

pine_rma(src, length) =>
    alpha = 1/length
    sum = 0.0
    sum := na(sum[1]) ? ta.sma(src, length) : alpha * src + (1 - alpha) * nz(sum[1])

// Smoothing MA Calculation
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "EMA"                   => pine_ema(source, length)
        "SMMA (RMA)"            => pine_rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

plot(tfChange ? float(na) : ma(src, autoLength ? length : maLengthInput, maTypeInput), color=color.yellow, title="MA", show_last = 5000, style = plot.style_linebr)
````
