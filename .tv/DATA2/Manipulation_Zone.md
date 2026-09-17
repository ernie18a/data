<!-- tradingview-pine-id: PUB;193ed9daa5824bf39d0bdaef93ecfd6c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Manipulation Zone

Source: https://www.tradingview.com/script/CIR6XKaF-Manipulation-Zone-Achira-Meegasthanne/

## Description

Manipulation Zone

Manipulation Zone is a price-action indicator designed to identify and visualize important Swing Highs, Swing Lows, Liquidity Areas, Price Levels, and Volume-Based Zones directly on the chart.

The indicator tracks confirmed pivot points and creates dynamic areas around swing extremes, allowing traders to monitor how price interacts with previous highs and lows.

🔹 KEY FEATURES

📈 SWING HIGH ZONES

The indicator automatically detects confirmed swing highs using the selected Pivot Lookback period.

When a swing high is identified, the indicator creates a resistance area around the pivot and tracks its interaction with future price.

The swing high zone can be displayed using:

• Wick Extremity
• Full Range

📉 SWING LOW ZONES

The indicator also detects confirmed swing lows and creates corresponding support areas.

These zones help visualize areas where previous price structure may become relevant as the market develops.

💧 MANIPULATION AREAS

The indicator creates dynamic areas around swing highs and swing lows.

These areas can help traders study how price interacts with previous extremes and identify potential manipulation or liquidity behavior around important market levels.

🎯 SWING HIGH LEVELS

Each confirmed swing high can generate a horizontal level that extends forward until price crosses the identified level.

Once the level is crossed, the line can change to a dashed style, providing a clear visual indication that the previous swing level has been violated.

🎯 SWING LOW LEVELS

Swing low levels work in the opposite direction.

The indicator tracks the previous swing low and monitors price until the level is crossed.

This provides a visual reference for potential downside liquidity interaction and market structure changes.

📊 VOLUME ANALYSIS

The indicator can calculate the volume associated with price interaction inside each swing area.

Volume can be used as an optional filtering method when determining whether a zone should become active.

🔢 COUNT FILTER

Zones can also be filtered according to the number of bars interacting with the defined swing area.

This allows users to focus on areas that have received a selected amount of price interaction.

⚡ INTRABAR PRECISION

The indicator includes an optional Intrabar Precision mode.

When enabled, lower-timeframe data can be used to analyze price and volume interaction inside the swing areas.

The lower timeframe used for this analysis can be customized.

⚙️ CUSTOMIZABLE SETTINGS

The indicator provides several configuration options:

• Pivot Lookback
• Swing Area
• Intrabar Precision
• Intrabar Timeframe
• Filter Areas By
• Filter Value
• Swing High Visibility
• Swing Low Visibility
• Swing High Color
• Swing Low Color
• Swing High Area Color
• Swing Low Area Color
• Label Size

📐 SWING AREA MODES

Wick Extremity

Uses the candle body and wick relationship to define the swing area.

Full Range

Uses the complete high-to-low range of the pivot candle to define the area.

This allows traders to choose between a more focused zone and a broader price range.

🏷️ VOLUME LABELS

When the selected filter condition is reached, the indicator can display a label showing the volume associated with the swing area.

Labels can be displayed in:

• Tiny
• Small
• Normal

🟢 SWING LOW VISUALIZATION

Swing lows are displayed using the configured bullish color and can include:

• Swing low level
• Swing low area
• Volume label
• Dynamic zone tracking

🔴 SWING HIGH VISUALIZATION

Swing highs are displayed using the configured bearish color and can include:

• Swing high level
• Swing high area
• Volume label
• Dynamic zone tracking

🧠 HOW IT WORKS

1. Detect Pivot Points

The indicator searches for confirmed swing highs and swing lows using the selected Pivot Lookback.

2. Define the Swing Area

Once a pivot is confirmed, the indicator calculates the corresponding swing area using either Wick Extremity or Full Range.

3. Track Price Interaction

The indicator monitors future candles that interact with the defined swing area.

4. Calculate Activity

Bar count and volume are tracked inside the swing area.

5. Apply the Selected Filter

The area can be filtered using either Count or Volume.

6. Extend the Level

The swing level continues forward while the corresponding price level remains unbroken.

7. Detect the Cross

When price crosses the swing level, the level is marked as crossed and the visual line changes accordingly.

📌 CORE CONCEPT

Swing High / Swing Low → Area Formation → Price Interaction → Count / Volume Analysis → Level Tracking → Level Cross

⚠️ IMPORTANT DISCLAIMER

This indicator is designed for market analysis and educational purposes.

Swing areas, volume measurements, price levels, and manipulation zones are analytical references and should not be considered guaranteed buy or sell signals.

Market behavior can change quickly, and previous swing levels do not guarantee future reactions.

Always perform your own analysis, use proper risk management, and thoroughly test the indicator before using it with real capital.

Track the extremes. Watch the liquidity. Understand the reaction.

---

## Source Code

````pine

//@version=6
indicator('Manipulation Zone', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)
//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
length = input(14, 'Pivot Lookback')

area = input.string('Wick Extremity', 'Swing Area', options = ['Wick Extremity', 'Full Range'])

intraPrecision = input(false, 'Intrabar Precision', inline = 'intrabar')
intrabarTf = input.timeframe('1', '', inline = 'intrabar')

filterOptions = input.string('Count', 'Filter Areas By', options = ['Count', 'Volume'], inline = 'filter')
filterValue = input.float(0, '', inline = 'filter')

Green = color.new(#0df1c6, 20)
Red   = #871ee9
//Style
showTop = input(true, 'Swing High', inline = 'top', group = 'Style')
topCss = input(Red, '', inline = 'top', group = 'Style')
topAreaCss = input(color.new(Red, 50), 'Area', inline = 'top', group = 'Style')

showBtm = input(true, 'Swing Low', inline = 'btm', group = 'Style')
btmCss = input(Green, '', inline = 'btm', group = 'Style')
btmAreaCss = input(color.new(Green, 50), 'Area', inline = 'btm', group = 'Style')

labelSize = input.string('Tiny', 'Labels Size', options = ['Tiny', 'Small', 'Normal'], group = 'Style')

//-----------------------------------------------------------------------------}
//Functions
//-----------------------------------------------------------------------------{
n = bar_index

get_data() =>
    [high, low, volume]

[h, l, v] = request.security_lower_tf(syminfo.tickerid, intrabarTf, get_data())

get_counts(bool condition, float top, float btm) =>
    var count = 0
    var vol = 0.

    if condition
        count := 0
        vol := 0.
        vol
    else
        if intraPrecision
            if n > length
                if array.size(v[length]) > 0
                    for [index, element] in v[length]
                        vol := vol + (array.get(l[length], index) < top and array.get(h[length], index) > btm ? element : 0)
                        vol
        else
            vol := vol + (low[length] < top and high[length] > btm ? volume[length] : 0)
            vol

        count := count + (low[length] < top and high[length] > btm ? 1 : 0)
        count

    [count, vol]

set_label(count, vol, x, y, css, lbl_style) =>
    var label lbl = na
    var label_size = switch labelSize
        'Tiny' => size.tiny
        'Small' => size.small
        'Normal' => size.normal

    target = switch filterOptions
        'Count' => count
        'Volume' => vol

    if ta.crossover(target, filterValue)
        lbl := label.new(x, y, str.tostring(vol, format.volume), style = lbl_style, size = label_size, color = #00000000, textcolor = css)
        lbl

    if target > filterValue
        label.set_text(lbl, str.tostring(vol, format.volume))

set_level(condition, crossed, value, count, vol, css) =>
    var line lvl = na

    target = switch filterOptions
        'Count' => count
        'Volume' => vol

    if condition
        if target[1] < filterValue[1]
            line.delete(lvl[1])
        else if not crossed[1]
            line.set_x2(lvl, n - length)

        lvl := line.new(n - length, value, n, value, color = na)
        lvl

    if not crossed[1]
        line.set_x2(lvl, n + 3)

    if crossed and not crossed[1]
        line.set_x2(lvl, n)
        line.set_style(lvl, line.style_dashed)

    if target > filterValue
        line.set_color(lvl, css)

set_zone(condition, x, top, btm, count, vol, css) =>
    var box bx = na

    target = switch filterOptions
        'Count' => count
        'Volume' => vol

    if ta.crossover(target, filterValue)
        bx := box.new(x, top, x + count, btm, border_color = na, bgcolor = css)
        bx

    if target > filterValue
        box.set_right(bx, x + count)

//-----------------------------------------------------------------------------}
//Global variables
//-----------------------------------------------------------------------------{
//Pivot high
var float ph_top = na
var float ph_btm = na
var bool ph_crossed = false
var ph_x1 = 0
var box ph_bx = box.new(na, na, na, na, bgcolor = color.new(topAreaCss, 80), border_color = na)

//Pivot low
var float pl_top = na
var float pl_btm = na
var bool pl_crossed = false
var pl_x1 = 0
var box pl_bx = box.new(na, na, na, na, bgcolor = color.new(btmAreaCss, 80), border_color = na)

//-----------------------------------------------------------------------------}
//Display pivot high levels/blocks
//-----------------------------------------------------------------------------{
ph = ta.pivothigh(length, length)

//Get ph counts
[ph_count, ph_vol] = get_counts(not na(ph), ph_top, ph_btm)

//Set ph area and level
if bool(ph) and showTop
    ph_top := high[length]
    ph_btm := switch area
        'Wick Extremity' => math.max(close[length], open[length])
        'Full Range' => low[length]

    ph_x1 := n - length
    ph_crossed := false

    box.set_lefttop(ph_bx, ph_x1, ph_top)
    box.set_rightbottom(ph_bx, ph_x1, ph_btm)
else
    ph_crossed := close > ph_top ? true : ph_crossed

    if ph_crossed
        box.set_right(ph_bx, ph_x1)
    else
        box.set_right(ph_bx, n + 3)

if showTop
    //Set ph zone
    set_zone(ph, ph_x1, ph_top, ph_btm, ph_count, ph_vol, topAreaCss)

    //Set ph level
    set_level(not na(ph), ph_crossed, ph_top, ph_count, ph_vol, topCss)

    //Set ph label
    set_label(ph_count, ph_vol, ph_x1, ph_top, topCss, label.style_label_down)

//-----------------------------------------------------------------------------}
//Display pivot low levels/blocks
//-----------------------------------------------------------------------------{
pl = ta.pivotlow(length, length)

//Get pl counts
[pl_count, pl_vol] = get_counts(not na(pl), pl_top, pl_btm)

//Set pl area and level
if bool(pl) and showBtm
    pl_top := switch area
        'Wick Extremity' => math.min(close[length], open[length])
        'Full Range' => high[length]
    pl_btm := low[length]

    pl_x1 := n - length
    pl_crossed := false

    box.set_lefttop(pl_bx, pl_x1, pl_top)
    box.set_rightbottom(pl_bx, pl_x1, pl_btm)
else
    pl_crossed := close < pl_btm ? true : pl_crossed

    if pl_crossed
        box.set_right(pl_bx, pl_x1)
    else
        box.set_right(pl_bx, n + 3)

if showBtm
    //Set pl zone
    set_zone(pl, pl_x1, pl_top, pl_btm, pl_count, pl_vol, btmAreaCss)

    //Set pl level
    set_level(not na(pl), pl_crossed, pl_btm, pl_count, pl_vol, btmCss)

    //Set pl labels
    set_label(pl_count, pl_vol, pl_x1, pl_btm, btmCss, label.style_label_up)

//-----------------------------------------------------------------------------}
````
