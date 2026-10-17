# Order Aggression Heatmap (Asymmetrical Volume Visualizer)

- url: https://www.tradingview.com/script/4w56y2kt-Order-Aggression-Heatmap-Asymmetrical-Volume-Visualizer/
- type: indicator
- pine_id: PUB;9e7af3b027b74cf78f4d31c9baa0905c
- version: 3.0

## Description

[b]Order Aggression Heatmap[/b] is a footprint-based visualization tool designed to highlight high-volume aggressive and/or asymmetrical buy/sell activity at individual price rows.

User-defined filters allow you to eliminate noise and only show the highest volume heat blocks. 

Using TradingView’s footprint data, the indicator analyzes volume at individual price rows and identifies areas where one side demonstrates a meaningful advantage over the other. Qualifying rows are displayed as heatmap blocks, with or without text, allowing traders to quickly spot volume concentrations, directional pressure, and potential areas of market response.

The indicator is intended as a supplemental order-flow visualization and can be used alongside price action, support/resistance levels, supply-demand zones, volume profiles, or other market structure tools.

[image]https://www.tradingview.com/x/dY7bmoaF/[/image]


[b]How It Works[/b]
For each footprint price row, the script evaluates:
[list]Total traded volume
Buy volume
Sell volume
Delta (buy volume minus sell volume)
Relative dominance between buyers and sellers[/list]
Rows are displayed only when user-defined thresholds are met.
The filtering process allows traders to focus on meaningful participation while reducing visual noise from lower-volume activity.

[b]Available Filters[/b]

[*][b]Minimum Row Volume[/b] Requires a footprint row to contain at least the specified amount of traded volume before it can be displayed.
Increasing this value reduces noise and emphasizes higher-activity areas.

[*][b]Minimum Absolute Delta[/b] Requires a minimum difference between buy and sell volume.
Higher values focus on stronger directional pressure.

[*][b]Aggression Ratio[/b] Measures how dominant one side is relative to the other.

[quote]Example:
Ratio = 2.0
Buy Volume = 100
Sell Volume = 50
The row qualifies because buyers traded at least twice the volume of sellers. 
[/quote]
[*][u][b]Aggressive Rows Only[/b][/u]
When enabled, only rows meeting the aggression ratio requirement are displayed.
When disabled, rows may still qualify through volume and delta thresholds alone.



[b]Visual Features[/b]
[list]•Heatmap-style overlays
•Custom buy and sell colors
•Optional footprint Point of Control (POC) highlighting
•Adjustable historical display window
•Adjustable heatmap persistence
•Optional row volume and delta labels
•Heat intensity can be customized through the selected color and opacity settings.[/list]

[b]Suggested Applications[/b]
This indicator may be useful for:
[list]•Identifying areas of concentrated participation
•Monitoring directional pressure within a move
•Comparing buyer and seller dominance at specific price levels
•Studying footprint behavior around support and resistance
•Evaluating activity near supply and demand zones
•Visualizing market response after large directional candles[/list]

[b]Notes[/b]
[*]This indicator uses TradingView footprint data.
[*]It does not use Level 2, DOM, or market-by-order data.
[*]It does not identify individual trades or individual order sizes.
[*]Results may vary depending on symbol, exchange data, [*]and footprint resolution settings.
[*]The snapshots above show the heatblocks hidden by the candles, but in use they appear in front of the candles.

## Source Code

````pine
//@version=6
indicator("Order Aggression Heatmap", overlay=true, max_boxes_count=500, max_labels_count=500)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
groupFp = "Footprint Settings"

ticksPerRow = input.int(
     4,
     "Ticks Per Row",
     minval=1,
     group=groupFp,
     tooltip="Controls the vertical size of each footprint row. Lower values show more price detail but can create more boxes. For NQ/MNQ, 4 is a good starting point."
)

valueAreaPct = input.int(
     70,
     "Value Area %",
     minval=1,
     maxval=100,
     group=groupFp,
     tooltip="Used by TradingView's footprint engine for value area calculations. This script mostly uses row volume and delta, so 70 is usually fine."
)

groupFilter = "Heatmap Filters"

minRowVol = input.float(
     300,
     "Minimum Row Volume",
     minval=0,
     group=groupFilter,
     tooltip="Minimum total volume required at a footprint price row before it can be displayed. Raise this to reduce noise; lower it to see more activity."
)

minAbsDelta = input.float(
     200,
     "Minimum Abs Delta",
     minval=0,
     group=groupFilter,
     tooltip="Minimum absolute delta required. Delta is buy volume minus sell volume at that row. Higher values focus on stronger directional pressure."
)

deltaRatioMin = input.float(
     2.5,
     "Aggression Ratio",
     minval=1.0,
     step=0.1,
     group=groupFilter,
     tooltip="How dominant one side must be versus the other. Example: 2.0 means buy volume must be at least 2x sell volume for buy aggression, or sell volume must be at least 2x buy volume for sell aggression."
)

showOnlyAggress = input.bool(
     true,
     "Only Show Aggressive Rows",
     group=groupFilter,
     tooltip="When enabled, only rows where one side clearly dominates are shown. When disabled, high-volume/high-delta rows can still appear even if the aggression ratio is not met."
)

groupVisual = "Visuals"

barsBack = input.int(
     150,
     "Show Last X Bars",
     minval=1,
     maxval=500,
     group=groupVisual,
     tooltip="Limits how many of the most recent bars can display heatmap data. Set to 1 to display only the current bar."
)

extendBars = input.int(
     1,
     "Box Width In Bars",
     minval=1,
     maxval=10,
     group=groupVisual,
     tooltip="Controls how many bars each heat box extends to the right. Use 1 for candle-specific signals. Higher values create a more persistent heatmap look."
)

maxRowsPerBar = input.int(
     8,
     "Max Heat Rows Per Bar",
     minval=1,
     maxval=30,
     group=groupVisual,
     tooltip="Maximum number of qualifying footprint rows displayed per candle. Lower values are cleaner. For confirmation, try 3–8."
)

showText = input.bool(
     true,
     "Show Volume Text",
     group=groupVisual,
     tooltip="Shows total row volume and delta inside each marker. Useful while testing, but usually too noisy for live trading."
)

showPOC = input.bool(
     false,
     "Highlight Footprint POC",
     group=groupVisual,
     tooltip="Highlights the footprint Point of Control for each candle. The POC is the row with the most volume. It can help show where volume concentrated, but can add clutter."
)

heatmapTransparency = input.int(
     70,
     "Heatmap Transparency",
     minval=0,
     maxval=100,
     group=groupVisual,
     tooltip="Controls transparency of the main heatmap boxes. 0 is fully solid, 100 is invisible."
)

labelTextColor = input.color(
     #000000,
     "Label Text Color",
     group=groupVisual,
     tooltip="Text color used for volume and delta labels."
)

labelBgTransparency = input.int(
     70,
     "Label Background Transparency",
     minval=0,
     maxval=100,
     group=groupVisual,
     tooltip="Controls transparency of the volume/delta label background. Higher values make labels more transparent."
)

pocTransparency = input.int(
     70,
     "POC Transparency",
     minval=0,
     maxval=100,
     group=groupVisual,
     tooltip="Controls transparency of the footprint POC highlight boxes."
)

buyColor = input.color(
     #00ff0a,
     "Aggressive Buy Color",
     group=groupVisual,
     tooltip="Color used when buy volume dominates the footprint row."
)

sellColor = input.color(
     #ff00d7,
     "Aggressive Sell Color",
     group=groupVisual,
     tooltip="Color used when sell volume dominates the footprint row."
)

pocColor = input.color(
     color.yellow,
     "POC Color",
     group=groupVisual,
     tooltip="Color used for footprint POC highlights."
)


//----------------------------------------------------
// Footprint Request
//----------------------------------------------------
footprint fp = request.footprint(ticksPerRow, valueAreaPct)


//----------------------------------------------------
// Helpers
//----------------------------------------------------
f_text(float rowVol, float delta) =>
    showText
         ? str.tostring(rowVol, format.volume) + "\nΔ " + str.tostring(delta, format.volume)
         : ""

    
//----------------------------------------------------
// Lookback
//----------------------------------------------------

// +1 makes "Show Last X Bars" literal.
// 1 = current bar only
// 2 = current bar + previous bar
// etc.
int firstBarToShow = last_bar_index - barsBack + 1

bool inLookback = bar_index >= firstBarToShow


//----------------------------------------------------
// Remove Objects That Have Fallen Outside Lookback
//----------------------------------------------------

// Objects created on a bar remain on the chart unless explicitly
// deleted. This cleanup prevents heatmap boxes/labels from
// accumulating as new bars form.
if barstate.islast
    int firstBarToKeep = last_bar_index - barsBack + 1

    for bx in box.all
        if box.get_left(bx) < firstBarToKeep
            box.delete(bx)

    for lbl in label.all
        if label.get_x(lbl) < firstBarToKeep
            label.delete(lbl)


//----------------------------------------------------
// Main Heatmap Logic
//----------------------------------------------------
if inLookback and not na(fp)

    array<volume_row> rows = fp.rows()
    volume_row pocRow = fp.poc()

    int plotted = 0

    for row in rows

        if plotted < maxRowsPerBar

            float buyVol   = row.buy_volume()
            float sellVol  = row.sell_volume()
            float rowVol   = row.total_volume()
            float delta    = row.delta()
            float absDelta = math.abs(delta)

            float rowHigh = row.up_price()
            float rowLow  = row.down_price()
            float rowMid  = math.avg(rowHigh, rowLow)

            bool buyAggressive =
                 buyVol > sellVol and
                 buyVol / math.max(sellVol, 1) >= deltaRatioMin

            bool sellAggressive =
                 sellVol > buyVol and
                 sellVol / math.max(buyVol, 1) >= deltaRatioMin

            bool passesVolume = rowVol >= minRowVol
            bool passesDelta  = absDelta >= minAbsDelta
            bool passesAgg    = buyAggressive or sellAggressive

            bool shouldShow =
                 passesVolume and
                 passesDelta and
                 (showOnlyAggress ? passesAgg : true)

            if shouldShow

                color baseColor =
                     buyAggressive
                          ? buyColor
                          : sellAggressive
                          ? sellColor
                          : color.gray

                box.new(
                     left=bar_index,
                     right=bar_index + extendBars,
                     top=rowHigh,
                     bottom=rowLow,
                     bgcolor=color.new(baseColor, heatmapTransparency),
                     border_color=color.new(baseColor, 85)
                )

                if showText
                    label.new(
                         x=bar_index,
                         y=rowMid,
                         text=f_text(rowVol, delta),
                         style=label.style_label_center,
                         textcolor=labelTextColor,
                         color=color.new(baseColor, labelBgTransparency),
                         size=size.tiny
                    )

                plotted += 1


    //------------------------------------------------
    // Footprint POC
    //------------------------------------------------
    if showPOC and not na(pocRow)

        float pocHigh = pocRow.up_price()
        float pocLow  = pocRow.down_price()

        box.new(
             left=bar_index,
             right=bar_index + extendBars,
             top=pocHigh,
             bottom=pocLow,
             bgcolor=color.new(pocColor, pocTransparency),
             border_color=color.new(pocColor, 30)
        )
````
