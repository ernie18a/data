# Delta Void Profile [BigBeluga]

- url: https://www.tradingview.com/script/hD0LaluR-Delta-Void-Profile-BigBeluga/
- type: indicator
- pine_id: PUB;c0a321ca0d8f4509a880661ee4b5c6c7
- version: 1.0

## Description

[b]Delta Void Profile [BigBeluga][/b] is an advanced order flow and market structure framework engineered to reveal the "negative space" in price action. By contrasting traditional volume accumulation with a unique [b]Inverse Liquidity Void[/b] map, this indicator identifies where the market is most anchored and where it is most fragile.

While standard profiles show where the crowd has transacted, the Delta Void Profile simultaneously highlights where the market *failed* to trade, marking the "liquidity vacuums" that often dictate explosive price movements.

[b]🔵 THE DUAL-ENGINE FRAMEWORK[/b]
[list]
[*] [b]The Normal Profile (Right Side):[/b] This is your primary volume distribution. It visualizes the total relative volume transacted at each price bin within the lookback period, providing a clear view of high-interest zones.
[image]https://www.tradingview.com/x/Eo3TPdj4/[/image]
[*] [b]The Inverse "Void" Profile (Left Side):[/b] This profile measures the "gap" between the maximum volume peak and the current bin. Longer bars on the left signify [b]Volume Voids[/b]—areas where price moved too quickly for significant liquidity to build.
[image]https://www.tradingview.com/x/62mdSDQE/[/image]
[*] [b]Intraday Delta Breakdown:[/b] Within the normal profile, the script calculates a granular [b]Buy/Sell Delta[/b]. Each bin features a central divider and percentage labels, showing exactly which side of the market dominated that specific price node.
[image]https://www.tradingview.com/x/MbkbA63u/[/image]
[/list]

[b]🔵 CORE ARCHITECTURE[/b]
[list]
[*] [b]Liquidity Vacuum Identification:[/b] The indicator automatically highlights the "Deepest Gap"—the price area with the least historical transacted volume relative to the peak. These zones act as magnets or "slip-zones" where price is likely to expand rapidly without resistance.
[image]https://www.tradingview.com/x/PZRPLgMa/[/image]
[*] [b]HVN & Gap Pivot Detection:[/b] Depending on your strategy, the tool automatically plots dashed structural lines at either [b]High Volume Nodes (HVN)[/b]—representing fair value and heavy support/resistance—or at [b]Volume Gaps[/b]—representing liquidity pockets.
[image]https://www.tradingview.com/x/rqdujrt2/[/image]
[image]https://www.tradingview.com/x/tr50B8qy/[/image]
[*] [b]Dynamic Gradient Resolution:[/b] The profile uses a color-gradient system based on volume density. Brighter, more saturated bins represent institutional interest, while faded bins represent retail noise or transitional zones.
[/list]

[b]🔵 FEATURES[/b]
[list]
[*] [b]High-Definition Bins:[/b] Customizable vertical resolution (Bin Count) allows you to transition from a macro structural view to a high-definition "micro-scalping" look at order flow.
[*] [b]Delta Efficiency Labels:[/b] Real-time percentage labels on the right-hand profile give you an immediate breakdown of supply and demand percentages for every price level.
[*] [b]Void Strength Labels:[/b] The inverse profile calculates and prints the "Gap Percentage," explicitly labeling areas where liquidity is significantly missing.
[*] [b]UI Scaling:[/b] Fully adjustable global text and label sizes ensure the profile remains readable on any screen resolution or chart layout.
[/list]

[b]🔵 STRATEGIC APPLICATION[/b]
[list]
[*] [b]Trading the HVN (High Volume Nodes):[/b] Use HVN levels as anchors for your stop-loss or as high-probability entry points. These are prices where the market has historically agreed on "Value".
[*] [b]Exploiting the Voids:[/b] When price enters a high-percentage "Gap" zone on the left profile, expect increased volatility. Because there is no "friction" from historical orders, price often "teleports" through these voids until it reaches the next high-volume cluster.
[*] [b]Delta Confirmation:[/b] Use the Buy/Sell percentage labels to confirm breakouts. If price is breaking an HVN resistance and the delta shows high Buy dominance, the probability of a successful breakout increases significantly.
[*] [b]Mean Reversion Targets:[/b] Voids often act as targets for mean reversion. If price is overextended, look for the nearest "Volume Gap" pivot as a natural magnet for a relief rally or pullback.
[/list]

[b]Delta Void Profile[/b] transforms your chart into a map of institutional activity and structural weakness. By identifying the voids in the market, you can stop trading into the "heavy" areas and start targeting the "light" areas where the real price expansion occurs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Delta Void Profile [BigBeluga]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

int lookback      = input.int(400, "Lookback Period", minval=50, tooltip="The number of historical bars used to calculate the volume and void data. Larger values provide a more macro view of market structure.")
int binCount      = input.int(30, "Number of Bins", minval=10, tooltip="Sets the vertical resolution of the profile. More bins create a detailed 'high-definition' view, while fewer bins simplify the structure.")
int profileWidth  = input.int(50, "Max Profile Width (Bars)", minval=5, tooltip="The maximum horizontal length of the volume bars, measured in chart bars.")
string levelMode  = input.string("Highest Volume", "Level Display", options=["None", "Highest Volume", "Volume Gaps"], tooltip="Choose which key structural levels to highlight: High Volume Nodes (HVN) for support/resistance or Volume Gaps for liquidity vacuums.")
color invColor    = input.color(#39c596, "Inverse Peak (Left)", tooltip="Color for the 'Void' profile on the left, representing areas where liquidity is missing.")
color normColor   = input.color(#3981c5, "Normal Bin Base", tooltip="Color for the standard volume profile on the right side.")
color levelColor  = input.color(color.new(color.white, 30), "Level Color", tooltip="The color used for the dashed horizontal pivot lines and their price labels.")

// UI Scaling
string labelSize  = input.string(size.small, "Global Text Size", options=[size.tiny, size.small, size.normal, size.large], tooltip="Adjusts the size of all text labels, including percentages and structural price levels.")
string boxTxtSize = labelSize

// }



// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

float hi = ta.highest(high, lookback)
float lo = ta.lowest(low, lookback)
float binStep = (hi - lo) / binCount

var float[] binTotalVol = array.new_float(binCount, 0.0)
var float[] binBuyVol   = array.new_float(binCount, 0.0)
array.fill(binTotalVol, 0.0)
array.fill(binBuyVol, 0.0)

for i = 0 to lookback - 1
    float bHi  = high[i], bLo = low[i], bCl = close[i], vol = volume[i]
    float buyPercent = (bHi == bLo) ? 0.5 : (bCl - bLo) / (bHi - bLo)
    int binIdx = math.floor((bCl - lo) / binStep)
    if binIdx >= 0 and binIdx < binCount
        binTotalVol.set(binIdx, binTotalVol.get(binIdx) + vol)
        binBuyVol.set(binIdx, binBuyVol.get(binIdx) + (vol * buyPercent))

float maxVol = binTotalVol.max()

// Cleanup Cache 
var box[] b_cache = array.new_box()
var line[] l_cache = array.new_line()
var label[] lbl_cache = array.new_label()

for b in b_cache 
    box.delete(b)
for l in l_cache 
    line.delete(l)
for lb in lbl_cache 
    label.delete(lb)
array.clear(b_cache), array.clear(l_cache), array.clear(lbl_cache)

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

if barstate.islast
    // Find deepest vacuum for highlighting
    float maxGap = 0.0
    for i = 0 to binCount - 1
        maxGap := math.max(maxGap, maxVol - binTotalVol.get(i))

    for i = 0 to binCount - 1
        float tVol = binTotalVol.get(i), bVol = binBuyVol.get(i), sVol = tVol - bVol
        float binTop = lo + ((i + 1) * binStep), binBot = lo + (i * binStep), midY = (binTop + binBot) / 2

        // 1. Inverse Profile (LEFT)
        float gapStr = maxVol - tVol
        int invW = math.round((gapStr / maxVol) * profileWidth)
        color currentInvColor = color.from_gradient(invW, 0, profileWidth, chart.bg_color, invColor)
        color borderC = gapStr == maxGap ? invColor : chart.bg_color
        float gapPct = (gapStr / maxVol) * 100 

        b_cache.push(box.new(bar_index - lookback + invW, binTop, bar_index - lookback, binBot, 
                     bgcolor=currentInvColor, border_color=borderC, 
                     text = invW > profileWidth * 0.7 ? str.format("{0,number,#}% Gap", gapPct) : "", 
                     text_halign = text.align_right, text_size = boxTxtSize))

        // 2. Normal Profile (RIGHT)
        int normW = math.round((tVol / maxVol) * profileWidth)
        int startX = bar_index + profileWidth, endX = startX - normW
        b_cache.push(box.new(startX, binTop, endX, binBot, 
                     bgcolor=color.from_gradient(normW, 0, profileWidth, chart.bg_color, normColor), border_color=chart.bg_color))

        if tVol > 0
            float bPct = bVol / tVol, sPct = sVol / tVol
            int deltaX = math.round(startX - (normW * bPct))
            l_cache.push(line.new(deltaX, binTop, deltaX, binBot, color=chart.fg_color, width=1, force_overlay=true))

            if normW > 18 
                lbl_cache.push(label.new(deltaX + 1, midY, str.format("{0,number,#}%", bPct * 100), 
                               textcolor=color.rgb(36, 240, 196), style=label.style_label_left, color=#00000000, size=labelSize, tooltip = "BUY Percent"))
                lbl_cache.push(label.new(deltaX - 1, midY, str.format("{0,number,#}%", sPct * 100), 
                               textcolor=color.rgb(255, 140, 87), style=label.style_label_right, color=#00000000, size=labelSize, tooltip = "SELL Percent"))

    // Structural Level Pivot Detection
    if levelMode != "None"
        for i = 1 to binCount - 2
            float prev = levelMode == "Highest Volume" ? binTotalVol.get(i-1) : (maxVol - binTotalVol.get(i-1))
            float curr = levelMode == "Highest Volume" ? binTotalVol.get(i)   : (maxVol - binTotalVol.get(i))
            float next = levelMode == "Highest Volume" ? binTotalVol.get(i+1) : (maxVol - binTotalVol.get(i+1))

            if curr > prev and curr > next
                float pivotP = lo + (i * binStep) + (binStep / 2)
                string prefix = levelMode == "Highest Volume" ? "HVN | " : "GAP | "
                
                l_cache.push(line.new(bar_index - lookback, pivotP, bar_index + profileWidth, pivotP, color=levelColor, style=line.style_dashed))
                lbl_cache.push(label.new(bar_index + profileWidth, pivotP, prefix + str.tostring(pivotP, "###,####"), 
                               textcolor=levelColor, style=label.style_label_left, color=#00000000, size=labelSize))

// }
````
