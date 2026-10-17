# Momentum Terrain 3D [LuxAlgo]

- url: https://www.tradingview.com/script/WgcQ7iYB-Momentum-Terrain-3D-LuxAlgo/
- type: indicator
- pine_id: PUB;f7eb2c2d64a24ce1a043a979da1aa3fe
- version: 1.0

## Description

The Momentum Terrain 3D tool visualizes multi-dimensional RSI momentum by mapping various lookback lengths across time into a single 3D topographical landscape.

🔶 [b]USAGE[/b]

The script provides a comprehensive view of momentum by calculating multiple RSI lengths simultaneously. This allows users to see how short-term momentum (foreground) interacts with long-term structural momentum (background) in a single visual pane, offering a unique perspective on trend strength and exhaustion.

🔹 [b]Understanding the Dimensions[/b]

To navigate the 3D map, it is essential to understand the three axes:

[list]
[*] [b]X-Axis (Width):[/b] Represents Time. The rightmost edge of the terrain represents the current bar, while moving left traverses historical data.
[*] [b]Y-Axis (Depth):[/b] Represents the RSI Lookback Length. The front of the terrain shows fast, reactive momentum (short lookbacks), while the back shows slow, structural momentum (long lookbacks).
[*] [b]Z-Axis (Height):[/b] Represents the RSI Value. A semi-transparent "Neutral Plane" is fixed at the 50 level. Peaks above this plane represent bullish momentum, while valleys below represent bearish momentum.
[/list]

🔹 [b]Interpreting the Topography[/b]

[list]
[*] [b]Trend Alignment:[/b] When the entire landscape from back to front rises together, it indicates a "unified" momentum where all timeframes are in bullish agreement.
[*] [b]Spotting Pullbacks:[/b] If the background (long-term) remains a high mountain but the foreground (short-term) drops into a valley, it identifies a pullback within a macro uptrend.
[*] [b]Trend Compression:[/b] If the terrain appears flat and stays near the 50 neutral plane, the market is ranging or in a period of indecision.
[/list]

🔹 [b]OB/OS Pillars[/b]

The script identifies extreme momentum through vertical color pillars. Red pillars indicate overbought conditions (RSI > 70), while cyan pillars indicate oversold conditions (RSI < 30). These help traders quickly spot exhaustion points across the entire momentum spectrum without checking multiple individual indicators.

🔶 [b]DETAILS[/b]

The indicator utilizes an optimized 3D rendering engine built with Pine Script's polyline and matrix systems. By calculating a range of RSI lengths (e.g., from a minimum of 5 to a maximum of 60) for every historical bar within the defined window, it creates a "momentum matrix."

This matrix is then projected into 3D space using trigonometric transformations (Yaw and Pitch). The "Terrain Smoothing" feature uses an exponential smoothing calculation on the raw RSI data to transform jagged spikes into readable topographical features, making it easier to identify the flow of capital and the weight of momentum shifts.

🔶 [b]SETTINGS[/b]

🔹 [b]Terrain & Matrix[/b]

[list]
[*] [b]Time History (Width):[/b] Determines how many historical bars are rendered on the X-axis.
[*] [b]Lookback Layers (Depth):[/b] The number of different RSI lengths calculated. Increasing this creates a denser, more detailed surface.
[*] [b]Terrain Smoothing:[/b] Applies smoothing to the RSI values to create a more natural, less noisy landscape.
[*] [b]Minimum/Maximum Lookback:[/b] Defines the range of RSI lengths used for the front (fast) and back (slow) edges.
[/list]

🔹 [b]Camera Projection[/b]

[list]
[*] [b]Yaw/Pitch:[/b] Rotates the landscape horizontally or tilts it vertically to change the visual perspective.
[*] [b]Scale X/Y/Z:[/b] Adjusts the width, depth, and height intensity of the 3D model.
[*] [b]Offset X/Y:[/b] Moves the entire 3D object on the chart pane horizontally or vertically for better positioning.
[/list]

🔹 [b]Style & Colors[/b]

[list]
[*] [b]Show Wireframe/Surface:[/b] Toggles the visibility of the grid lines and the solid surface fill.
[*] [b]Show OB/OS Volume Fills:[/b] Enables the vertical pillars that highlight extreme RSI levels.
[*] [b]Show Current Price Marker:[/b] Highlights the most recent momentum profile and displays the current price label on the 3D grid.
[*] [b]Neutral Plane Color:[/b] Adjusts the color and transparency of the RSI 50 reference floor.
[/list]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("Momentum Terrain 3D [LuxAlgo]", "LuxAlgo - Momentum Terrain 3D", overlay = false, max_polylines_count = 100, max_lines_count = 500, max_labels_count = 500, calc_bars_count = 1000)

//---------------------------------------------------------------------------------------------------------------------}
// Groups & Inputs
//---------------------------------------------------------------------------------------------------------------------{
const string GRP_TERRAIN = "Terrain & Matrix"
const string GRP_CAMERA  = "Camera Projection"
const string GRP_STYLE   = "Style & Colors"

// Terrain Settings
int timeWidth = input.int(45, "Time History (Width)", group = GRP_TERRAIN, minval = 10, maxval = 70, tooltip = "Number of historical bars to render on the X-axis.")
int rsiSteps  = input.int(24, "Lookback Layers (Depth)", group = GRP_TERRAIN, minval = 5, maxval = 28, tooltip = "Number of different RSI lengths to calculate (Y-axis).")
int smoothLen = input.int(4,  "Terrain Smoothing", group = GRP_TERRAIN, minval = 1, tooltip = "Smooths the RSI values to make the 3D surface look more like natural terrain.")
int minRsiLen = input.int(5,  "Minimum Lookback (Front)", group = GRP_TERRAIN, minval = 2)
int maxRsiLen = input.int(60, "Maximum Lookback (Back)", group = GRP_TERRAIN, minval = 10)

// Camera Settings
float yawDeg   = input.float(35, "Yaw (°)", group = GRP_CAMERA, minval = -89, maxval = 89, tooltip = "Rotates the landscape left or right.")
float pitchDeg = input.float(40, "Pitch (°)", group = GRP_CAMERA, minval = 0, maxval = 89, tooltip = "Tilts the landscape up or down.")
float scaleX   = input.float(4.0, "Scale X (Width)", group = GRP_CAMERA, step = 0.1)
float scaleY   = input.float(5.0, "Scale Y (Depth)", group = GRP_CAMERA, step = 0.1)
float scaleZ   = input.float(3.5, "Scale Z (Height)", group = GRP_CAMERA, step = 0.1)
int   offsetX  = input.int(0, "Offset X (Bars Left/Right)", group = GRP_CAMERA, tooltip = "Moves the entire landscape horizontally.")
float offsetY  = input.float(0, "Offset Y (Price Up/Down)", group = GRP_CAMERA, tooltip = "Moves the entire landscape vertically.")

// Style
bool  showWire      = input.bool(true, "Show Wireframe", group = GRP_STYLE)
bool  showFill      = input.bool(true, "Show Surface Fill", group = GRP_STYLE)
bool  showObOsFills   = input.bool(true, "Show OB/OS Volume Fills", group = GRP_STYLE, tooltip = "Draws vertical lines down to the base for RSI values > 70 or < 30")
bool  showPriceMarker = input.bool(true, "Show Current Price Marker", group = GRP_STYLE, tooltip = "Highlights the rightmost edge and displays the current price.")
color neutralPlane    = input.color(color.new(color.white, 85), "Neutral Plane Color", group = GRP_STYLE)
color obColor       = input.color(color.new(#FF1744, 40), "Overbought Fill", group = GRP_STYLE)
color osColor       = input.color(color.new(#00E5FF, 40), "Oversold Fill", group = GRP_STYLE)

//---------------------------------------------------------------------------------------------------------------------}
// Types & Math Base
//---------------------------------------------------------------------------------------------------------------------{
type Camera
    int anchorX
    float anchorY
    float cYaw
    float sYaw
    float sPit
    float cPit
    float sx
    float sy
    float sz

method project(Camera this, float x, float y, float z) =>
    float xr = x * this.cYaw - y * this.sYaw
    float yr = x * this.sYaw + y * this.cYaw
    float sxp = xr * this.sx
    float syp = yr * this.sPit * this.sy - z * this.cPit * this.sz
    chart.point.from_index(this.anchorX + int(sxp), this.anchorY - syp)

var array<color> heatmap = array.from(#F9C80E, #F86624, #EA3546, #662E9B, #43BCCD)

f_colorAt(float t) =>
    float u = math.max(0, math.min(1, t))
    float s = u * (heatmap.size() - 1)
    int i1 = int(math.floor(s))
    int i2 = int(math.ceil(s))
    color.from_gradient(s - i1, 0, 1, heatmap.get(i1), heatmap.get(i2))

//---------------------------------------------------------------------------------------------------------------------}
// State Initialization
//---------------------------------------------------------------------------------------------------------------------{
var int[] rsiLengths = array.new_int(rsiSteps)
if barstate.isfirst
    for i = 0 to rsiSteps - 1
        float fraction = rsiSteps > 1 ? i / (rsiSteps - 1.0) : 0
        // We put maxRsiLen at i=0 (Back) and minRsiLen at i=rsiSteps-1 (Front)
        int l = maxRsiLen - int(math.round(fraction * (maxRsiLen - minRsiLen)))
        rsiLengths.set(i, l)

var float[] avgGains = array.new_float(rsiSteps, na)
var float[] avgLosses = array.new_float(rsiSteps, na)
var float[] smoothedRsi = array.new_float(rsiSteps, na)

// We use a matrix to store the Z-heights (RSI values)
// Rows = RSI Lengths (Depth)
// Cols = Time History (Width)
var matrix<float> terrainMap = matrix.new<float>(rsiSteps, timeWidth, 50.0)

//---------------------------------------------------------------------------------------------------------------------}
// Core Calculations (Per Bar)
//---------------------------------------------------------------------------------------------------------------------{
float chg = ta.change(close)
float g = math.max(chg, 0)
float l = math.max(-chg, 0)

int colIndex = bar_index % timeWidth

for i = 0 to rsiSteps - 1
    int len = rsiLengths.get(i)
    float alpha = 1.0 / len
    
    float prevG = avgGains.get(i)
    float prevL = avgLosses.get(i)
    
    // Manual RMA initialization and update
    float newG = na(prevG) ? g : prevG + alpha * (g - prevG)
    float newL = na(prevL) ? l : prevL + alpha * (l - prevL)
    
    avgGains.set(i, newG)
    avgLosses.set(i, newL)
    
    float rs = newG / math.max(newL, 1e-10)
    float rsiVal = newL == 0 ? 100.0 : 100.0 - (100.0 / (1.0 + rs))
    
    float currSmooth = smoothedRsi.get(i)
    float finalVal = rsiVal
    if smoothLen > 1
        float alphaSmooth = 2.0 / (smoothLen + 1)
        finalVal := na(currSmooth) ? rsiVal : currSmooth + alphaSmooth * (rsiVal - currSmooth)
        smoothedRsi.set(i, finalVal)
    
    terrainMap.set(i, colIndex, finalVal)

//---------------------------------------------------------------------------------------------------------------------}
// 3D Rendering Engine (On Last Bar)
//---------------------------------------------------------------------------------------------------------------------{
if barstate.islast
    // Clear previous drawings
    for p in polyline.all
        p.delete()
    for ln in line.all
        ln.delete()
    for lbl in label.all
        lbl.delete()
        
    int head = bar_index % timeWidth
    
    // Set up camera in the center-left of the pane
    Camera cam = Camera.new(
         anchorX = bar_index - int(timeWidth * scaleX * 0.55) + offsetX, 
         anchorY = 50.0 - offsetY, 
         cYaw    = math.cos(yawDeg * math.pi / 180),
         sYaw    = math.sin(yawDeg * math.pi / 180), 
         sPit    = math.sin(pitchDeg * math.pi / 180), 
         cPit    = math.cos(pitchDeg * math.pi / 180), 
         sx      = scaleX, 
         sy      = scaleY, 
         sz      = scaleZ
     )
     
    // 1. Draw Neutral Water Level (RSI 50 Plane)
    array<chart.point> plane = array.new<chart.point>()
    plane.push(cam.project(0, 0, 0))
    plane.push(cam.project(timeWidth - 1, 0, 0))
    plane.push(cam.project(timeWidth - 1, rsiSteps - 1, 0))
    plane.push(cam.project(0, rsiSteps - 1, 0))
    polyline.new(plane, closed = true, fill_color = neutralPlane, line_color = color.new(color.gray, 60))

    // 2. Build Terrain Strips
    // Depth sorting requires drawing from BACK (y = 0) to FRONT (y = rsiSteps - 2)
    array<chart.point> stripBuf = array.new<chart.point>()
    
    for y = 0 to rsiSteps - 2
        stripBuf.clear()
        
        // Forward path (bottom edge of the strip)
        for x = 0 to timeWidth - 1
            int hx = (head + 1 + x) % timeWidth
            float z = terrainMap.get(y, hx) - 50
            stripBuf.push(cam.project(x, y, z))
            
        // Return path (top edge of the strip)
        for x = timeWidth - 1 to 0
            int hx = (head + 1 + x) % timeWidth
            float z = terrainMap.get(y + 1, hx) - 50
            stripBuf.push(cam.project(x, y + 1, z))
            
        // Gradient color based on depth
        color c = f_colorAt((y + 0.5) / (rsiSteps - 1))
        color fColor = showFill ? color.new(c, 25) : #00000000
        color lColor = showWire ? color.new(c, 60) : #00000000
        
        polyline.new(stripBuf, closed = true, fill_color = fColor, line_color = lColor)
        
    // 3. Draw Column Wireframes to complete the crosshatch
    if showWire
        array<chart.point> colBuf = array.new<chart.point>()
        for x = 0 to timeWidth - 1
            colBuf.clear()
            int hx = (head + 1 + x) % timeWidth
            for y = 0 to rsiSteps - 1
                float z = terrainMap.get(y, hx) - 50
                colBuf.push(cam.project(x, y, z))
            
            polyline.new(colBuf, closed = false, line_color = color.new(color.gray, 60))

    // 4. Overbought / Oversold Volume Fills
    if showObOsFills
        for y = 0 to rsiSteps - 1 by 2
            for x = 0 to timeWidth - 1 by 2
                int hx = (head + 1 + x) % timeWidth
                float rsiVal = terrainMap.get(y, hx)
                if rsiVal > 70 or rsiVal < 30
                    float z = rsiVal - 50
                    color fCol = rsiVal > 70 ? obColor : osColor
                    line.new(cam.project(x, y, 0), cam.project(x, y, z), color = fCol, width = 1)

    // 5. Highlight Current Profile (Right Edge) & Price
    if showPriceMarker
        array<chart.point> currentEdge = array.new<chart.point>()
        for y = 0 to rsiSteps - 1
            float z = terrainMap.get(y, head) - 50
            currentEdge.push(cam.project(timeWidth - 1, y, z))
        polyline.new(currentEdge, closed = false, line_color = color.new(color.white, 20), line_width = 3)

        float currentZ = terrainMap.get(rsiSteps - 1, head) - 50
        chart.point markerPos = cam.project(timeWidth - 1, rsiSteps - 1, currentZ)
        chart.point markerBase = cam.project(timeWidth - 1, rsiSteps - 1, 0)
        
        line.new(markerBase, markerPos, color = color.new(color.white, 20), width = 1, style = line.style_dashed)
        label.new(markerPos.index, markerPos.price, "❖ " + str.tostring(close, format.mintick), color = #00000000, textcolor = color.white, style = label.style_label_left, size = size.normal)

//---------------------------------------------------------------------------------------------------------------------}
````
