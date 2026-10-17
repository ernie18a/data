# TF to R Chart Overlay

- url: https://www.tradingview.com/script/g5QvaHdI-TF-to-R-Chart-Overlay/
- type: indicator
- pine_id: PUB;9fb160dbfb904bda9436b02c4a6a3ab7
- version: 1.0

## Description

This is a clean, professional-grade script designed specifically for traders who use Range, Tick, or Renko charts but still need to track higher timeframe (HTF) market structure.

Most standard timeframe overlays fail on Range charts because they rely on server-side data fetching that often returns errors or empty values. This script solves that by using Manual Aggregation—calculating the higher timeframe candles in real-time based on the price action currently on your screen.

🔑 Key Features
Manual Period Aggregation: Seamlessly overlays time-based candles (1H, 4H, Daily, etc.) on any non-time-based chart without the usual data-loading issues.
Auto-Centering Wicks: As a time period progresses and more range bars form, the wicks automatically re-calculate their position to stay perfectly centered within the horizontal span of the candle body.
Clean Interior Logic: Wick lines are strictly confined to the area between the High/Low and the candle body. No lines run through the middle of the candle, ensuring a crisp, modern aesthetic.
Granular Visual Control:
Body: Independent bullish/bearish colors and transparency.
Wicks: Independent color and transparency (separate from borders).
Borders: Optional candle borders with their own transparency settings to minimize visual clutter.
🛠️ How to Use
Select Your Timeframe: In the settings, choose the timeframe you want to overlay (e.g., set to "60" to see 1-hour candles on your 50R chart).
Adjust Style: Use the transparency sliders to find the right balance between the overlay and your primary range bars. Many traders prefer a body transparency of 70-80% and a wick transparency of 20-30% for a "phantom" look.
💡 Pro Tip
On Range charts, ensure your Overlay Timeframe is significantly larger than the average time it takes for a single range bar to form. This ensures the candles have enough "width" to display clearly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Timeframe Candle Overlay (Manual)", "TF Candles", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// --- Inputs ---
string tfInput      = input.timeframe("60", "Overlay Timeframe", tooltip = "The timeframe to aggregate. e.g., 60 for 1H.")

// Body Settings
color  bullColor    = input.color(#089981, "Bullish Body", group = "Body")
color  bearColor    = input.color(#f23645, "Bearish Body", group = "Body")
int    bodyTrans    = input.int(70, "Body Transparency", minval = 0, maxval = 100, group = "Body")

// Wick Settings
color  wickColor    = input.color(#787b86, "Wick Color", group = "Wicks")
int    wickTrans     = input.int(30, "Wick Transparency", minval = 0, maxval = 100, group = "Wicks")

// Border Settings
color  borderColor = input.color(#787b86, "Border Color", group = "Borders")
int    borderTrans = input.int(80, "Border Transparency", minval = 0, maxval = 100, group = "Borders")

// --- Types ---
type Candle
    box  body
    line highWick
    line lowWick
    int  startIdx
    float openPrice

// --- Logic ---
int   t     = time(tfInput)
bool  isNew = ta.change(t) != 0

var Candle current = na
var float  o = na
var float  h = na
var float  l = na

// Pre-calculate colors
color bodyBull = color.new(bullColor, bodyTrans)
color bodyBear = color.new(bearColor, bodyTrans)
color wCol     = color.new(wickColor, wickTrans)
color bCol     = color.new(borderColor, borderTrans)

if isNew
    o := open
    h := high
    l := low
    
    float c = close
    color col = c >= o ? bodyBull : bodyBear
    
    // Create box
    box  b = box.new(bar_index, math.max(o, c), bar_index, math.min(o, c), border_color = bCol, bgcolor = col)
    
    // Create wicks: ensuring they start/end exactly at the body edges
    line hW = line.new(bar_index, h, bar_index, math.max(o, c), color = wCol)
    line lW = line.new(bar_index, l, bar_index, math.min(o, c), color = wCol)
    
    current := Candle.new(b, hW, lW, bar_index, o)
else if not na(current)
    h := math.max(h, high)
    l := math.min(l, low)
    
    float c = close
    color col = c >= current.openPrice ? bodyBull : bodyBear
    
    // Calculate the exact center between the start bar and current bar
    int midX = int(math.round((current.startIdx + bar_index) / 2))
    
    // Update body
    current.body.set_right(bar_index)
    current.body.set_top(math.max(current.openPrice, c))
    current.body.set_bottom(math.min(current.openPrice, c))
    current.body.set_bgcolor(col)
    
    // Update Wicks: 
    // 1. Move them to the new horizontal center (midX)
    // 2. Ensure they connect precisely to the top/bottom of the body
    float bodyTop = math.max(current.openPrice, c)
    float bodyBot = math.min(current.openPrice, c)
    
    // High Wick update
    current.highWick.set_xy1(midX, h)
    current.highWick.set_xy2(midX, bodyTop)
    
    // Low Wick update
    current.lowWick.set_xy1(midX, l)
    current.lowWick.set_xy2(midX, bodyBot)
````
