# Directional Volume Matrix | julzALGO

- url: https://www.tradingview.com/script/kGLaOdut-Directional-Volume-Matrix-julzALGO/
- type: indicator
- pine_id: PUB;21412d321d04432bb86faf7bea615e1e
- version: 1.0

## Description

📊Directional Volume Matrix  | julzALGO

This script is designed as a structured market participation and directional volume analysis dashboard, combining candle anatomy, estimated buy/sell pressure, normalized volume distribution, and directional imbalance into a single visual workflow.

Rather than treating volume as neutral, this model estimates how much of each candle’s volume likely came from bullish participation versus bearish participation by analyzing:
• Close position within candle range
• Upper and lower shadow structure
• Body size and direction
• Relative candle positioning

The result is a fixed 30-bar dashboard that helps traders visualize directional participation, pressure dominance, and imbalance more objectively.

🔷 Core Concept

Traditional candles show price movement.
Traditional volume shows total activity.

This script expands both by estimating:
• Buy Volume
• Sell Volume
• Delta (Buy − Sell)
• Imbalance %

using candle anatomy as a directional participation model.

🔷 Bullish Candle Structure (Close > Open)

https://www.tradingview.com/x/CsDfAncr/
                      
Bullish Interpretation:
• Close near high → stronger buyer control
• Lower shadow → buyer defense
• Bull body → bullish participation

🔷 Bearish Candle Structure (Close < Open)

 https://www.tradingview.com/x/G3S5nX5R/

Bearish Interpretation:
• Close near low → stronger seller control
• Upper shadow → seller rejection
• Bear body → bearish participation

🔷 Important Structural Rule

For both bullish and bearish candles:
• Upper Shadow = seller response / rejection from highs
• Lower Shadow = buyer defense / response from lows

Only the body direction changes:
• Bull = Close above Open
• Bear = Close below Open

🔷 How the Script Works

1. Price Range
priceRange = high - low

Measures total candle range.

2. closePos
closePos = (close - low) / priceRange

Interpretation:
• Close near HIGH → closePos near 1 → stronger buy influence
• Close near LOW → closePos near 0 → stronger sell influence

3. bodyRatio
bodyRatio = (close - open) / priceRange

Interpretation:
• bodyRatio > 0 → bullish body
• bodyRatio < 0 → bearish body

4. Wick Logic
upperWick = high - max(open, close)
lowerWick = min(open, close) - low

Interpretation:
• Upper shadow = seller rejection
• Lower shadow = buyer defense

🔷 Estimated Buy / Sell Volume Model

The script builds directional participation through these weighted components:

Buy Strength
buyStrength =
(closePos * 0.60) +
(wickBuy * 0.25) +
(bodyRatio > 0 ? bodyRatio * 0.35 : 0)

Sell Strength
sellStrength =
((1 - closePos) * 0.60) +
(wickSell * 0.25) +
(bodyRatio < 0 ? -bodyRatio * 0.35 : 0)

Then total candle volume is split proportionally into:
estBuyVol  = volume * buyStrength
estSellVol = volume * sellStrength

And normalized so:
Estimated Buy Volume + Estimated Sell Volume = Total Candle Volume

🔷 Dashboard Structure — Volume Distribution Table

This dashboard analyzes the last 30 candles and displays a structured volume participation table.

https://www.tradingview.com/x/IndDppGJ/

🔷 Table Settings
• Show Table → Enable / Disable dashboard
• Table Position → Top Left / Top Right / Bottom Left / Bottom Right
• Color Bars By Candle Direction → Bullish = Aqua / Bearish = Red
• Show Volume Numbers → Show / Hide numerical values

🔷 Lower Timeframe Settings
• Use Lower Timeframe Volume → Optional lower timeframe sourcing
• Lower Timeframe → Custom timeframe input

Purpose:
• More granular participation estimates
• Intraday precision
• Session detail on higher timeframe charts

🔷 Dashboard Components

1. Relative Volume Histogram
Displays each candle’s relative volume intensity.

2. Candle Direction Color
• Aqua = Bull candle
• Red = Bear candle

3. Volume Numbers
Exact volume values per bar

4. Time Row
Bar timestamp reference

5. Aggregate Metrics
• B = Estimated total Buy Volume
• S = Estimated total Sell Volume
• Delta = Buy − Sell
• Imbalance = |Delta| ÷ Total Volume × 100

🔷 How to Use — Execution Workflow

Bullish Workflow

STEP 1:
• Bull candles closing near highs
• Lower shadows showing defense

STEP 2:
• B > S
• Positive Delta
• Rising Imbalance %

STEP 3:
• Buyer participation dominant

RESULT:
• Bullish directional bias

Bearish Workflow

STEP 1:
• Bear candles closing near lows
• Upper shadows showing rejection

STEP 2:
• S > B
• Negative Delta
• Rising Imbalance %

STEP 3:
• Seller participation dominant

RESULT:
• Bearish directional bias

🔷 Purpose & Value

This script is designed to help traders answer:

“Was price movement supported by directional participation?”

instead of simply:

“Did price move?”

It supports:
• Volume structure reading
• Directional bias analysis
• Participation imbalance detection
• Bull vs Bear pressure comparison
• Dashboard-based workflow

🔷 Important Notes
• This is a candle-structure-based participation model
• It does NOT use exchange bid/ask, footprint, or true order-flow data
• Buy/Sell values are estimated from candle anatomy and volume weighting
• Best used alongside:
• Market Structure
• Order Blocks
• FVG
• POC / Volume Profile
• Session context

🔷 Disclaimer

This script is for educational and informational purposes only.
It does not constitute financial advice or guaranteed performance.
Always perform your own analysis and use proper risk management before trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

//@version=6
indicator("Directional Volume Matrix | julzALGO", overlay = true)

//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
groupTable = "Table Settings"
groupLtf   = "Lower Timeframe"

showTable     = input.bool(true, "Show Table", group = groupTable)
tablePos      = input.string("Bottom Left", "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = groupTable)
colorByCandle = input.bool(true, "Color Bars By Candle Direction", group = groupTable)
showNumbers   = input.bool(true, "Show Volume Numbers", group = groupTable)

useLowerTf    = input.bool(false, "Use Lower Timeframe Volume", group = groupLtf)
lowerTf       = input.timeframe("1", "Lower Timeframe", group = groupLtf)

//──────────────────────────────────────────────────────────────────────────────
// CONSTANTS
//──────────────────────────────────────────────────────────────────────────────
int lookbackBars = 30
float buyCloseWeight = 0.60
float buyWickWeight  = 0.25
float buyBodyWeight  = 0.35

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
fmtVol(v) =>
    float av = math.abs(v)
    av >= 1e12 ? str.tostring(av / 1e12, "#.##") + "T" :
     av >= 1e9 ? str.tostring(av / 1e9, "#.##") + "B" :
     av >= 1e6 ? str.tostring(av / 1e6, "#.##") + "M" :
     av >= 1e3 ? str.tostring(av / 1e3, "#.##") + "K" :
     str.tostring(av, "#.#")

fmtPct(v) =>
    str.tostring(v, "#.0") + "%"

getPos(pos) =>
    pos == "Top Left" ? position.top_left :
     pos == "Top Right" ? position.top_right :
     pos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

fmtTime(ts) =>
    str.format_time(ts, "HH:mm")

//──────────────────────────────────────────────────────────────────────────────
// DATA SOURCE
//──────────────────────────────────────────────────────────────────────────────
float srcOpen   = useLowerTf ? request.security(syminfo.tickerid, lowerTf, open) : open
float srcHigh   = useLowerTf ? request.security(syminfo.tickerid, lowerTf, high) : high
float srcLow    = useLowerTf ? request.security(syminfo.tickerid, lowerTf, low) : low
float srcClose  = useLowerTf ? request.security(syminfo.tickerid, lowerTf, close) : close
float srcVolume = useLowerTf ? request.security(syminfo.tickerid, lowerTf, volume) : volume
int   srcTime   = useLowerTf ? int(request.security(syminfo.tickerid, lowerTf, time)) : time

//──────────────────────────────────────────────────────────────────────────────
// ESTIMATED BUY/SELL VOLUME PER BAR
//──────────────────────────────────────────────────────────────────────────────
float tr = math.max(srcHigh - srcLow, syminfo.mintick)
float priceRange = math.max(tr, syminfo.mintick)

float body = srcClose - srcOpen
float bodySize = math.abs(body)
float upperWick = srcHigh - math.max(srcOpen, srcClose)
float lowerWick = math.min(srcOpen, srcClose) - srcLow

float totalCandle = bodySize + upperWick + lowerWick
totalCandle := totalCandle == 0 ? syminfo.mintick : totalCandle

float bodyRatio = body / priceRange
float wickBuy = lowerWick / totalCandle
float wickSell = upperWick / totalCandle
float closePos = (srcClose - srcLow) / priceRange

float buyStrength =
     (closePos * buyCloseWeight) +
     (wickBuy * buyWickWeight) +
     (bodyRatio > 0 ? bodyRatio * buyBodyWeight : 0)

float sellStrength =
     ((1 - closePos) * buyCloseWeight) +
     (wickSell * buyWickWeight) +
     (bodyRatio < 0 ? -bodyRatio * buyBodyWeight : 0)

float estBuyVol = srcVolume * buyStrength
float estSellVol = srcVolume * sellStrength

float normTotal = estBuyVol + estSellVol
estBuyVol := normTotal > 0 ? srcVolume * (estBuyVol / normTotal) : 0
estSellVol := normTotal > 0 ? srcVolume * (estSellVol / normTotal) : 0

//──────────────────────────────────────────────────────────────────────────────
// LOOKBACK TOTALS
//──────────────────────────────────────────────────────────────────────────────
float totalBuy = 0.0
float totalSell = 0.0

for i = 0 to lookbackBars - 1
    totalBuy += nz(estBuyVol[i], 0)
    totalSell += nz(estSellVol[i], 0)

float delta = totalBuy - totalSell
float imbalancePct = (totalBuy + totalSell) > 0 ? math.abs(delta) / (totalBuy + totalSell) * 100 : 0

//──────────────────────────────────────────────────────────────────────────────
// TABLE
//──────────────────────────────────────────────────────────────────────────────
var table volTable = na
var string lastPos = na

bool mustRecreate = na(volTable) or lastPos != tablePos

if mustRecreate
    if not na(volTable)
        table.delete(volTable)
    volTable := table.new(getPos(tablePos), lookbackBars, 6, bgcolor = color.new(color.black, 10), border_width = 1, border_color = color.new(color.gray, 60))
    lastPos := tablePos

if barstate.islast and showTable
    table.clear(volTable, 0, 0, lookbackBars - 1, 5)

    volHist = array.new_float()
    dirHist = array.new_int()
    timeHist = array.new_int()

    for i = 0 to lookbackBars - 1
        array.push(volHist, srcVolume[i])
        array.push(dirHist, srcClose[i] >= srcOpen[i] ? 1 : -1)
        array.push(timeHist, srcTime[i])

    float maxVol = array.max(volHist)

    string titleText = "Volume Distribution (30 Bars)"
    titleText := useLowerTf ? titleText + " | LTF " + lowerTf : titleText

    table.cell(volTable, 0, 0, titleText, text_color = color.white, text_size = size.small, bgcolor = color.new(color.blue, 75), text_halign = text.align_center)
    table.merge_cells(volTable, 0, 0, lookbackBars - 1, 0)

    for col = 0 to lookbackBars - 1
        int idx = lookbackBars - 1 - col
        float v = array.get(volHist, idx)
        int d = array.get(dirHist, idx)
        int t = array.get(timeHist, idx)

        float ratio = maxVol > 0 ? v / maxVol : 0
        int bars = math.max(1, int(math.round(ratio * 8)))

        string histTxt = str.repeat("█", bars)
        color histColor = colorByCandle ? (d > 0 ? color.aqua : color.rgb(255, 65, 65, 33)) : color.silver

        table.cell(volTable, col, 1, histTxt, text_color = histColor, text_size = size.tiny, bgcolor = color.new(color.black, 0), text_halign = text.align_center)
        table.cell(volTable, col, 2, showNumbers ? fmtVol(v) : "", text_color = color.white, text_size = size.tiny, bgcolor = color.new(color.black, 0), text_halign = text.align_center)
        table.cell(volTable, col, 3, fmtTime(t), text_color = color.silver, text_size = size.tiny, bgcolor = color.new(color.black, 0), text_halign = text.align_center)

    table.cell(volTable, 0, 4, "B: " + fmtVol(totalBuy) + " | S: " + fmtVol(totalSell), text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 85), text_halign = text.align_center)
    table.merge_cells(volTable, 0, 4, lookbackBars - 1, 4)

    string stats2 = "Delta: " + (delta >= 0 ? "+" : "-") + fmtVol(delta) + " | Imbalance: " + fmtPct(imbalancePct)
    table.cell(volTable, 0, 5, stats2, text_color = delta >= 0 ? color.aqua : color.red, text_size = size.small, bgcolor = color.new(color.gray, 90), text_halign = text.align_center)
    table.merge_cells(volTable, 0, 5, lookbackBars - 1, 5)
````
