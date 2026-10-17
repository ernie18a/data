# Grid Bot Demonstrator

- url: https://www.tradingview.com/script/NDl287ix/
- type: indicator
- pine_id: PUB;8c24ce6ebe3c4adf9bb1612395eb2cec
- version: 19.0

## Description

🚀 Grid Bot Demonstrator
[b]Overview[/b]

The [b]Grid Bot Demonstrator[/b] is a high-performance visualization tool designed for traders utilizing Grid Trading strategies (similar to Pionex, Binance, or KuCoin).

It allows you to simulate and visualize a grid bot's structure directly on your chart, enabling precise planning of ranges and grid density before deploying capital.

[b]🛠 Key Features[/b]

[*] [b]Dynamic Auto-Range:[/b] When limits are set to 0, the indicator automatically calculates an optimal range (±10% from current price) rounded to the nearest $10,000—ideal for Bitcoin’s psychological levels.

[*] [b]Dual Mode Support:[/b] Seamlessly toggle between [b]Long[/b] and [b]Short[/b] strategies via a simple dropdown menu.

[*] [b]Intelligent Grid Coloring:[/b]
[b]Long Mode:[/b] Green lines above price (Take Profit), Red lines below (Buy/Support).
[b]Short Mode:[/b] Red lines above price (Entry/Stop), Green lines below (Take Profit).

[*] [b]Performance Optimized (Smart Window):[/b] Even with up to [b]500 grids[/b], the chart remains fluid. The script renders only the 100 lines closest to the current price while maintaining perfect mathematical accuracy of the total grid count.

[*] [b]Boundary Protection:[/b] Features bold, distinct safety lines for the Upper and Lower limits so you know exactly when your bot leaves the active trading zone.

[b]📖 How to Use[/b]
[b]1. Grid Settings[/b] Enter your Upper and Lower price limits. Use "0" for the automated 10k-rounding logic.
[b]2. Grid Count[/b] Set the number of grids (up to 500) to match your bot's specific configuration.
[b]3. Strategy Mode[/b] Select "Long" or "Short" to instantly adapt the color coding to your trade direction.
[b]4. Scalability[/b] Works across all timeframes, from 1-minute scalping to daily charts.

[b]🔬 Technical Specifications[/b]
[*] [b]Grid Type:[/b] Arithmetic (Equal USD distance between levels).
[*] [b]Engine:[/b] Pine Script V5 with [i]max_lines_count[/i] optimization.
[*] [b]Clarity:[/b] Focuses on visual price levels to provide a clean, distraction-free trading environment.

## Source Code

````pine
//@version=6
// @description Grid Bot Visualizer. Parity with Pionex logic.
// v6.8 - Dynamic Colors (Short/Long), Custom Colors & Opacity
indicator("Grid Bot Demonstrator", overlay=true, max_lines_count=500)

// --- Grid Config ---
inputStart  = input.float(0.0, "Start Price (Entry)", group="Grid Config")
inputUpper  = input.float(0.0, "Upper Limit", group="Grid Config")
inputLower  = input.float(0.0, "Lower Limit", group="Grid Config")
gridCount   = input.int(80, "Grids", minval=2, group="Grid Config")
gridType    = input.string("Arithmetic", "Type", options=["Arithmetic", "Geometric"], group="Grid Config")
stratMode   = input.string("Short", "Strategy Mode", options=["Long", "Short"], group="Grid Config")

// --- Visual Styles & Colors ---
gridOpacity = input.int(50, "Grid Opacity", minval=0, maxval=100, group="Style")
customCols  = input.bool(false, "Use Custom Colors", group="Style")
upColor     = input.color(#26a69a, "Above Price Color", group="Style")
downColor   = input.color(#ef5350, "Below Price Color", group="Style")

// --- Investment & Fees ---
botCurrency = input.string("Sats", "Currency", group="Investment")
totalAmount = input.float(0.0, "Total Investment", group="Investment")
marketType  = input.string("Futures", "Market Type", options=["Spot", "Futures"], group="Fees")
manualMaker = input.float(0.0, "Manual Maker Fee % (0=Auto)", step=0.01, group="Fees")

// --- Exits ---
inputBE = input.float(0.0, "B-Even", group="Exits")
inputTP = input.float(0.0, "TP", group="Exits")
inputSL = input.float(0.0, "SL", group="Exits")
inputLiq = input.float(0.0, "LIQ", group="Exits")

// --- Calculation Engine ---
float effMaker = (manualMaker == 0 ? (marketType == "Futures" ? 0.02 : 0.05) : manualMaker) / 100
int actualGrids = math.max(gridCount - 1, 1)
float stepSize = (inputUpper - inputLower) / actualGrids
float geoRatio = math.pow(inputUpper / inputLower, 1.0 / actualGrids)

// --- HISTORY / MEMORY LOGIC ---
var float lastTriggeredLine = na
if barstate.isfirst
    lastTriggeredLine := inputStart

for i = 0 to gridCount - 1
    float pLvl = gridType == "Geometric" ? inputLower * math.pow(geoRatio, i) : inputLower + (i * stepSize)
    pLvl := math.round(pLvl / syminfo.mintick) * syminfo.mintick
    if (low <= pLvl and high >= pLvl)
        lastTriggeredLine := pLvl

// --- Drawing Engine ---
var line[] gLines = array.new<line>()
var label[] gLabels = array.new<label>()
if array.size(gLines) > 0
    for l in gLines
        line.delete(l)
    array.clear(gLines)
if array.size(gLabels) > 0
    for lb in gLabels
        label.delete(lb)
    array.clear(gLabels)

f_draw_special(p, txt, col, style) =>
    if p > 0
        array.push(gLines, line.new(bar_index - 15, p, bar_index, p, color=color.new(col, 20), width=2, style=style, extend=extend.both))
        array.push(gLabels, label.new(bar_index + 15, p, txt + ": " + str.tostring(p, "#.##"), style=label.style_label_left, color=color.new(col, 20), textcolor=color.white))

f_draw_special(inputBE, "BE", #ab47bc, line.style_solid)
f_draw_special(inputTP, "TP", #26a69a, line.style_dashed)
f_draw_special(inputSL, "SL", #ffa726, line.style_dashed)
f_draw_special(inputLiq, "LIQ", #ef5350, line.style_dashed)
f_draw_special(inputStart, "ENTRY", #42a5f5, line.style_solid)

// Grid Loop
for i = 0 to gridCount - 1
    float pLvl = gridType == "Geometric" ? inputLower * math.pow(geoRatio, i) : inputLower + (i * stepSize)
    pLvl := math.round(pLvl / syminfo.mintick) * syminfo.mintick
    
    if pLvl == lastTriggeredLine
        continue
    
    // Default Color Logic:
    // Short: Above = Red (Sell), Below = Green (Buy)
    // Long:  Above = Green (Sell), Below = Red (Buy)
    color defaultCol = na
    if stratMode == "Short"
        defaultCol := close < pLvl ? #ef5350 : #26a69a
    else
        defaultCol := close < pLvl ? #26a69a : #ef5350
    
    // Choose between custom or dynamic default
    color finalCol = customCols ? (close < pLvl ? upColor : downColor) : defaultCol
    
    bool isB = (math.abs(pLvl - inputUpper) < (pLvl * 0.0001) or math.abs(pLvl - inputLower) < (pLvl * 0.0001))
    array.push(gLines, line.new(bar_index - 10, pLvl, bar_index, pLvl, extend=extend.both, color=color.new(isB ? color.gray : finalCol, 100 - gridOpacity), width=isB ? 2 : 1))

// --- Info Panel ---
float rawProfitPct = (gridType == "Geometric" ? (geoRatio - 1) : (stepSize / inputLower)) * 100
float netProfitPct = rawProfitPct - (effMaker * 2 * 100)
float profitVal = (totalAmount / gridCount) * (netProfitPct / 100)
string cFmt = str.upper(botCurrency) == "BTC" ? "#.########" : str.upper(botCurrency) == "SATS" ? "#" : "#.##"

var table stats = table.new(position.bottom_right, 2, 3, bgcolor=color.new(color.black, 40), border_width=1, border_color=color.gray)
if barstate.islast and inputUpper > 0
    table.cell(stats, 0, 0, "Grid Profit (Net):  ", text_color=color.white, text_size=size.small, text_halign=text.align_right)
    table.cell(stats, 1, 0, "  " + str.tostring(netProfitPct, "#.##") + "%", text_color=color.lime, text_size=size.small, text_halign=text.align_left)
    if totalAmount > 0
        table.cell(stats, 0, 1, "Per Grid:  ", text_color=color.yellow, text_size=size.small, text_halign=text.align_right)
        table.cell(stats, 1, 1, "  " + str.tostring(profitVal, cFmt) + " " + botCurrency, text_color=color.yellow, text_size=size.small, text_halign=text.align_left)
    table.cell(stats, 0, 2, "Fee used:  ", text_color=color.gray, text_size=size.tiny, text_halign=text.align_right)
    table.cell(stats, 1, 2, "  " + str.tostring(effMaker * 100, "0.000") + "%", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left)
````
