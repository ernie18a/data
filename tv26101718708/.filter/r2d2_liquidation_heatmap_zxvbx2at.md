# R2D2 Liquidation Heatmap

- url: https://www.tradingview.com/script/Zxvbx2AT-R2D2-Liquidation-Heatmap/
- type: indicator
- pine_id: PUB;32e06951333b4b5b9935e8cfe6f85417
- version: 1.0

## Description

[b]R2D2 Liquidation Heatmap: The Professional’s Guide to Trapped Liquidity[/b]

Liquidity is the lifeblood of the crypto markets, and more often than not, someone’s forced exit is your ideal entry. In high-leverage environments, price doesn't just move linearly; it moves from one pocket of trapped traders to the next. The R2D2 Liquidation Heatmap is designed to pull back the curtain on these "invisible" price levels, mapping exactly where stop-losses cluster and where market stress is most likely to break.
________________________________________
[b]The Core Philosophy: Trading the "Pain"[/b]
Most indicators look at where the price has been. This indicator looks at where the price wants to go to find fuel.

A liquidation cascade occurs when the market hits a dense cluster of stop-orders or liquidation prices. This triggers a self-reinforcing loop: forced sells lead to more price drops, which trigger more sells. By identifying these zones before they are hit, you shift from being a reactive trader to a predictive one.

[b]Heatmap Components[/b]
•	Current Liquidation Levels: These are "active" zones. They extend to the right of the current price because they represent future targets.
•	Historical Liquidation Levels: These are "spent" zones. When a line stops and freezes at a specific bar, it shows you exactly where a flush occurred, giving you a map of how the market responded to that specific injection of volatility.
________________________________________
[b]The Color Spectrum: Decoding Intensity[/b]

The heatmap uses a multi-stop gradient to show you the "mass" of the positions at any given level.
[b]Color	                    Meaning	        Expected Reaction[/b]
Dark Purple	            Low Liquidity	Minor speed bump; price may slice through with little effort.
Blue / Indigo	            Medium Liquidity	Potential area for a "pause" or a minor retracement.
Cyan / Light Blue	    High Liquidity	Strong magnet for price; likely to see a spike in volume.
Bright Mint Green	    Extreme Liquidity	High probability of a violent cascade or a major trend reversal.
________________________________________
[b]Professional Trading Strategies[/b]
[b]1. The "Liquidity Sweep" Entry[/b]
Professional traders rarely buy a support line the first time it’s touched. Instead, they look for the Bright Green cluster sitting just below that support. When price "sweeps" into that green zone and immediately bounces, it indicates that the trapped longs have been flushed out, leaving the path clear for an upside move.

[b]2. Target-Based Exits[/b]
If you are in a long position and see a massive Cyan/Green cluster above the current price, that is your exit magnet. These zones act as "liquidity draws." Price is statistically drawn to these areas to facilitate large orders. Setting your Take Profit just inside these clusters ensures you get filled during the peak of the volatility.
[b]
3. Avoiding the "Gap"[/b]
If you see a large price gap between the current price and the next major liquidation cluster, expect a "slippage zone." Price tends to move very quickly through these low-liquidity areas (Dark Purple) because there are no orders to slow it down.
________________________________________
S[b]caling for Professionals: Timeframe Optimization[/b]
The biggest mistake traders make is using the same sensitivity on a 30m chart as they do on a Daily chart. To get a clean, professional-grade heatmap, you must adjust your Cluster Tolerance and Intensity Threshold.

[b]Recommended Settings Table[/b]
[i]Timeframe	Pivot Length	Cluster Tolerance	Intensity Threshold[/i]
30m - 1HR                  3               0.05% - 0.1%                3.0
4HR                         3 - 5             0.3% - 0.5%                 4.5
Daily	                         3                1.0% - 2.0%                 6.0+

[b]Why the change?[/b]
•	Cluster Tolerance: On a Daily chart, a "level" is a wide zone. If you keep the tolerance at 0.05%, you will see hundreds of tiny, weak lines. Setting it to 1.5% on the Daily allows the script to aggregate all the stops within a $1,200 range (on BTC), showing you the true macro "wall" of liquidity.
•	Intensity Threshold: Daily volume is massive compared to the average. Pushing the intensity to 6.0 or higher ensures that only the most extreme, market-shifting events light up in green, keeping your chart clean and actionable.
________________________________________
[b]Final Tips for Success[/b]
•	Trust the "Untouched": Significant liquidation levels that haven't been hit for months are often the ultimate "Magnets" for a macro trend.
•	Watch the Clusters: If you see three or four lines merging into one thick, bright green bar, pay attention. That is a high-conviction zone where thousands of traders have their "line in the sand."
•	Scaling Matters: Always ensure your indicator is pinned to the Right Scale. If the lines don't move when you drag the chart, right-click the indicator name and select "Pin to Scale."

May the trades be with you.

## Source Code

````pine
//(c)R2D2_4Life

//@version=6
// Added scale=scale.right to force TradingView to attach the lines to the price axis
indicator("R2D2 Liquidation Heatmap", overlay=true, scale=scale.right, max_lines_count=500)

// --- Settings ---
grp_main = "Liquidation Settings"
pivotLen = input.int(3, "Liquidity Pivot Length", group=grp_main, tooltip="Lower number = Denser heatmap. Higher number = Sparse, major levels only.")
showUntouched = input.bool(true, "Show All Untouched Levels", group=grp_main)
clusterTolerance = input.float(0.05, "Cluster Tolerance (%)", group=grp_main, step=0.01, tooltip="Defines the % distance to merge nearby levels. If a new liquidation zone forms within this % of an existing one, they combine volume to form a brighter zone.\n\nRECOMMENDED:\n30m: 0.05% - 0.1%\n4HR: 0.2% - 0.5%\nDaily: 1.0% - 2.0%")

grp_visuals = "Visuals & Colors"
colorLow = input.color(#800080, "Low Liquidation (Weak)", group=grp_visuals) // Dark Purple
colorHigh = input.color(#00FF00, "High Liquidation (Strong)", group=grp_visuals) // Bright Green
volMultiplier = input.float(3.0, "Color Intensity Threshold", group=grp_visuals, step=0.5, tooltip="Lower = More green lines. Higher = More purple lines.")

// --- Exact Multi-Stop Color Gradient Function ---
f_get_heatmap_color(val, max_val) =>
    float pct = max_val == 0 ? 0 : math.max(0, math.min(1, val / max_val))
    color c = na
    if pct <= 0.33
        c := color.from_gradient(pct, 0.0, 0.33, color.rgb(43, 11, 63), color.rgb(65, 33, 213)) 
    else if pct <= 0.66
        c := color.from_gradient(pct, 0.33, 0.66, color.rgb(65, 33, 213), color.rgb(14, 178, 228)) 
    else
        c := color.from_gradient(pct, 0.66, 1.0, color.rgb(14, 178, 228), color.rgb(105, 240, 174)) 
    c

// --- Types & Arrays ---
type LiqLevel
    float price
    float strength
    bool isShort 
    bool isActive
    line lvlLine

var levels = array.new<LiqLevel>()

// --- Calculate Pivots & Dynamic Volume Threshold ---
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

float avgVol = ta.sma(volume, 500)
float dynamicThreshold = na(avgVol) ? 1.0 : (avgVol * volMultiplier)

// Method to check for and merge into existing clusters
method isClustered(array<LiqLevel> arr, float p, bool short, float pivotVol) =>
    bool clustered = false
    float rangeDiff = p * (clusterTolerance / 100)
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            lvl = arr.get(i)
            if lvl.isShort == short and lvl.isActive and math.abs(lvl.price - p) <= rangeDiff
                lvl.strength += pivotVol 
                clustered := true
                break
    clustered

// Add new Short Liquidation Levels (Above Price)
if not na(ph)
    strength = nz(volume[pivotLen])
    if not levels.isClustered(ph, true, strength)
        levels.push(LiqLevel.new(ph, strength, true, true, na))

// Add new Long Liquidation Levels (Below Price)
if not na(pl)
    strength = nz(volume[pivotLen])
    if not levels.isClustered(pl, false, strength)
        levels.push(LiqLevel.new(pl, strength, false, true, na))

// --- Process & Draw Levels ---
if levels.size() > 0
    for i = levels.size() - 1 to 0
        lvl = levels.get(i)
        
        lvlColor = f_get_heatmap_color(lvl.strength, dynamicThreshold)
        
        if lvl.isActive
            hitShort = lvl.isShort and high >= lvl.price
            hitLong = not lvl.isShort and low <= lvl.price
            
            if hitShort or hitLong
                lvl.isActive := false
                if not na(lvl.lvlLine)
                    lvl.lvlLine.set_extend(extend.none)
                    lvl.lvlLine.set_x2(bar_index)
            else
                if na(lvl.lvlLine)
                    lvl.lvlLine := line.new(bar_index[pivotLen], lvl.price, bar_index, lvl.price, color=lvlColor, width=2, extend=extend.right)
                else
                    lvl.lvlLine.set_color(lvlColor) 
        else
            if not showUntouched and bar_index - lvl.lvlLine.get_x2() > 1000
                lvl.lvlLine.delete()
                levels.remove(i)

// May the trades be with you.
````
