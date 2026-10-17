# Market Pivot Levels

- url: https://www.tradingview.com/script/Yg9vxE8r-Market-Pivot-Levels/
- type: indicator
- pine_id: PUB;d491d74257224e839f10e7d0b379bc1e
- version: 3.0

## Description

Tired of automated support and resistance indicators that clutter your chart with dozens of overlapping, noisy lines?

The Market Pivot Levels indicator is designed to map core market structure exactly like a professional technician would—cleanly, precisely, and without the noise. Instead of drawing a line at every single minor fluctuation, this script uses advanced filtering logic to identify true structural zones and spaces them out beautifully across your chart.
[b]Key Features:[/b]
[list]
[*]ATR Proximity Filter (No Clutter): Standard pivot scripts often stack lines on top of each other during consolidation. This script uses an Average True Range (ATR) proximity filter. If a new pivot forms too close to an existing major level, it ignores it, ensuring your chart only displays distinct, well-spaced tradeable zones.
[*]Psychological Price Snapping: Human traders don't draw lines at random decimals like $196.19—they look for clean, psychological numbers. This script automatically takes the exact wick of a structural swing and snaps it to the nearest whole dollar (e.g., $196.00), mimicking a human hand.
[*]Flush Right-Aligned Labels: Forget hovering over lines to see their value. Custom price tags are dynamically magnetized to the far right of your screen, sitting perfectly flush with your standard price axis for immediate readability.
[*]Stealth UI: We believe in clean charts and clean interfaces. All underlying parameters (lookbacks, ATR multipliers, line thickness) are hardcoded and hidden from the settings menu to keep your TradingView UI completely minimalist. It is strictly plug-and-play.
[/list]
[b]How it Works Under the Hood:[/b]
By default, the script looks for highly granular micro-swings (1-bar lookback), but relies on the 1.0 ATR distance multiplier to filter out the noise. The result is a highly responsive, custom price grid that adapts to the specific volatility of whatever ticker you are trading. It keeps a maximum of 20 active levels on the screen, automatically cleaning up old, irrelevant zones as new price action develops.

[b]How to Use It:[/b]
Simply drop it onto any chart timeframe. Use the automatically generated yellow zones for breakout entries, strict stop-loss placements, or profit targets during extended trends.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © iMetaX
//@version=6

indicator("Market Pivot Levels", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
int leftBars     = input.int(1, "Pivot Left Bars", minval=0, tooltip="Bars to the left needed to confirm a swing. Lower = more granular levels.", display=display.none)
int rightBars    = input.int(1, "Pivot Right Bars", minval=0, tooltip="Bars to the right needed to confirm a swing. Lower = more granular levels.", display=display.none)

float atrMult    = input.float(1.0, "Minimum Distance (ATR)", minval=0.0, tooltip="Filters out noisy lines. Forces new levels to be at least this many ATR multiples away from existing ones.", display=display.none)

color lineColor  = input.color(color.new(color.yellow, 0), "Line/Label Color", tooltip="Color of the horizontal support/resistance lines and their price labels.", display=display.none)
string styleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], tooltip="Visual style of the horizontal lines.", display=display.none)

int lineWidth    = input.int(1, "Line Thickness", minval=1, tooltip="Thickness of the horizontal lines.", display=display.none)

int maxLevels    = input.int(20, "Max Levels Displayed", minval=1, maxval=500, tooltip="Maximum number of lines kept on the chart. Deletes oldest lines first to prevent infinite clutter.", display=display.none)
int labelOffset  = input.int(30, "Label Distance to Axis", minval=0, tooltip="Adjusts how far to the right the price labels sit. Increase to push them closer to the price axis.", display=display.none)

// --- Hardcoded Variables ---
// Completely removed from the GUI. Hardcoded to 1.0 (snaps to nearest dollar). 
// Change to 0.01 if you want exact decimal wicks.
float snapTick   = 1.0

// --- Calculations ---
float atr = ta.atr(14)
float minDistance = atr * atrMult

float phRaw = ta.pivothigh(high, leftBars, rightBars)
float plRaw = ta.pivotlow(low, leftBars, rightBars)

// --- Human Rounding Logic ---
snapPrice(price, tick) =>
    math.round(price / tick) * tick

float ph = not na(phRaw) ? snapPrice(phRaw, snapTick) : na
float pl = not na(plRaw) ? snapPrice(plRaw, snapTick) : na

// --- Helper Function to Convert String to Line Style ---
getLineStyle(str) =>
    switch str
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// Set the chosen style into a variable
string myStyle = getLineStyle(styleInput)

// --- State Management ---
var array<line> levels = array.new<line>()
var array<label> labels = array.new<label>() 

// --- Custom Proximity Function ---
isTooClose(float val, array<line> arr, float dist) =>
    bool tooClose = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            float existingVal = line.get_y1(arr.get(i))
            if math.abs(val - existingVal) < dist
                tooClose := true
                break
    tooClose

// --- Drawing Logic ---
if not na(ph)
    if not isTooClose(ph, levels, minDistance)
        // Draw Line
        line newLine = line.new(bar_index, ph, bar_index + 1, ph, color=lineColor, width=lineWidth, style=myStyle, extend=extend.both)
        levels.push(newLine)
        
        // Draw Label 
        label newLbl = label.new(bar_index, ph, text=str.tostring(ph, format.mintick), color=lineColor, textcolor=color.black, style=label.style_label_left, size=size.small)
        labels.push(newLbl)
        
        // Clean up old lines and labels
        if levels.size() > maxLevels
            line.delete(levels.shift())
            label.delete(labels.shift())

if not na(pl)
    if not isTooClose(pl, levels, minDistance)
        // Draw Line 
        line newLine = line.new(bar_index, pl, bar_index + 1, pl, color=lineColor, width=lineWidth, style=myStyle, extend=extend.both)
        levels.push(newLine)
        
        // Draw Label 
        label newLbl = label.new(bar_index, pl, text=str.tostring(pl, format.mintick), color=lineColor, textcolor=color.black, style=label.style_label_left, size=size.small)
        labels.push(newLbl)
        
        // Clean up old lines and labels
        if levels.size() > maxLevels
            line.delete(levels.shift())
            label.delete(labels.shift())

// --- Force Labels to the Right Edge ---
if labels.size() > 0
    for i = 0 to labels.size() - 1
        label.set_x(labels.get(i), bar_index + labelOffset)
````
