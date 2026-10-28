# Liquidity Vacuum & Imbalance @MaxMaserati 3.0

- url: https://www.tradingview.com/script/3TweYcPb-Liquidity-Vacuum-Imbalance-MaxMaserati-3-0/
- type: indicator
- pine_id: PUB;671651bcbd72423fb49dc3b5519d727e
- version: 1.0

## Description

Description:
Liquidity Vacuum & Imbalance 3.0, is an advanced order flow and smart money tool designed to detect, classify, and track inefficient price delivery in the markets.

Unlike standard Fair Value Gap (FVG), Unfair Pricing Gap indicators that solely look at three-bar price action, this script analyzes the underlying volume and order flow delta to distinguish between two completely different types of market inefficiencies: Liquidity Vacuums and Imbalances.

Understanding the difference between these two market phenomena is critical for finding high-probability Points of Interest (POIs) and determining the draw on liquidity.

🔍 Core Concepts
1. Liquidity Vacuums (Low Volume / Thin Book)

What it is: A rapid, violent price movement that occurs on below-average volume.

Why it happens: The order book is exceptionally thin. Because there is little resting liquidity (limit orders) to absorb market orders, price simply "slides" through the book, creating a vacuum.

How it behaves: Vacuums act as a magnet for future price action. Because these zones lack historical volume, price often returns to "rebalance" them.

Smart Mitigation Logic: In this indicator, Vacuums shrink dynamically. As price wicks into a Vacuum, the zone physically contracts on your chart, showing you exactly how much of the void remains to be filled.

2. Imbalance Flows (High Volume / Aggressive Flow)

What it is: A rapid price movement accompanied by high volume and a heavy Delta skew.

Why it happens: Institutional/aggressive participants are slamming the market with large orders, overwhelming the opposing side.

How it behaves: These act as strong structural support/resistance zones. The heavy volume transacted here implies participants will likely defend these levels upon a retest.

Smart Mitigation Logic: Unlike Vacuums, Imbalances are treated as static institutional zones. They do not shrink; they remain intact until they are fully breached/invalidated by price.

🌟 Key Features
Auto-Detect Premium Footprint: If you have access to TradingView's premium footprint data, the indicator utilizes request.footprint() to pull exact order flow Delta. If you do not, it utilizes a highly optimized internal algorithm to approximate LTF (Lower Timeframe) buy/sell volume pressure based on price action.

Custom Volume & Delta Thresholds: Total control over what defines "low volume" for vacuums and "high delta skew" for imbalances.

Multi-Layered Visuals: Zones are plotted using advanced layered polylines to give a beautiful, semi-transparent depth effect on your charts without cluttering your candles.

Delta Labels: Displays the exact accumulated Delta (Δ) at the center of the zone, showing you the exact net buying/selling pressure that caused the void.

Historical Tracking: Option to keep "Filled/Rebalanced" zones on the chart, turning them dark/grey so you can backtest how price reacts to these levels after they are mitigated.

⚙️ How to Use the Settings
Detection Settings: Choose to plot "Both", "True Vacuums Only", or "Imbalance Flows Only". Adjust the Lookback Period, Low Vol Threshold, and Price Movement Sensitivity to tune the indicator to your specific asset's volatility.

OrderFlow Settings: Toggle the native footprint data and set your minimum Delta Imbalance Threshold (e.g., 0.5 means Delta must be at least 50% of the total volume to qualify as an aggressive imbalance).

Visual Settings: Fully customize the colors for Bullish/Bearish Vacuums and Imbalances. Adjust how far the zones extend to the right and how many max active voids to keep on the chart to maintain performance.

💡 Trading Application
Targets (Take Profit): Unmitigated Liquidity Vacuums are excellent high-probability targets. The market abhors a vacuum and will generally gravitate toward them to rebalance the order book.

Entries (POIs): Imbalance Zones represent areas where aggressive institutional money stepped in. Look for LTF confirmation (change of character, breaks of structure) when price returns to retest an Imbalance Zone for high R:R entries.

Disclaimer: This script is for educational and analytical purposes only. Past performance is not indicative of future results. Always pair order flow concepts with broader market structure and strict risk management.

## Source Code

````pine
//@version=6
indicator('Liquidity Vacuum & Imbalance @MaxMaserati 3.0', overlay = true, max_polylines_count = 100, max_boxes_count = 500, max_labels_count = 500)

// Input Parameters
i_detectMode = input.string("Both", title="What to Detect", options=["Both", "True Vacuums Only", "Imbalance Flows Only"], group="Detection Settings", tooltip="Vacuums = Low Vol/Thin Book. Imbalance = High Vol/Aggressive Flow.")
i_lookbackPeriod = input.int(5, 'Lookback Period', minval = 1, maxval = 100, group = 'Detection Settings')
i_volumeThreshold = input.float(0.5, 'Low Vol Threshold (Vacuums)', minval = 0.1, maxval = 5.0, step = 0.1, group = 'Detection Settings')
i_priceMovementSensitivity = input.float(0.5, 'Price Movement Sensitivity', minval = 0.5, maxval = 5.0, step = 0.1, group = 'Detection Settings')
i_minVoidBars = input.int(1, 'Minimum Void Bars', minval = 1, maxval = 10, group = 'Detection Settings')

i_useFootprint = input.bool(true, "Auto-Detect Premium Footprint", group = "OrderFlow Settings")
i_imbalanceThresh = input.float(0.5, "Delta Imbalance Threshold", minval=0.1, maxval=1.0, step=0.1, group="OrderFlow Settings")

i_vacBullColor = input.color(color.new(#00c853, 85), 'Bullish Vacuum (Green)', group = 'Visual Settings: Vacuums')
i_vacBearColor = input.color(color.new(#ff1100, 85), 'Bearish Vacuum (Red)', group = 'Visual Settings: Vacuums')

i_imbBullColor = input.color(color.new(#2962ff, 85), 'Bullish Imbalance (Blue)', group = 'Visual Settings: Imbalance')
i_imbBearColor = input.color(color.new(#ff6d00, 85), 'Bearish Imbalance (Orange)', group = 'Visual Settings: Imbalance')

i_extendLength = input.int(15, 'Extension Length (Bars)', minval = 1, group = 'Visual Settings')
i_showLabels = input.bool(true, 'Show Void Delta Labels', group = 'Visual Settings')
i_maxVoids = input.int(25, 'Max Active Zones', minval = 5, maxval = 30, group = 'Visual Settings')

i_showFilled = input.bool(false, 'Show Rebalanced/Filled Zones', group = 'Filled Voids')
i_filledColor = input.color(color.new(#000000, 85), 'Rebalanced Color', group = 'Filled Voids')

// Constants & Types
type ActiveVoid
    box b
    label lbl
    polyline p1
    polyline p2
    polyline p3
    float origTop
    float origBot
    float currentTop
    float currentBot
    bool isBullish
    bool isVacuum 

var array<ActiveVoid> g_activeVoids = array.new<ActiveVoid>()

var int g_voidStartBar = na
var float g_voidTopPrice = na
var float g_voidBottomPrice = na
var int g_consecutiveVoidBars = 0
var float g_totalVoidStrength = 0.0
var float g_totalDelta = 0.0
var int g_voidType = 0 

float pixelSpacing = ta.atr(14) * 0.001

// Footprint & Delta
footprint chartFootprint = i_useFootprint ? request.footprint(5, 70) : na
bool hasPremium = not na(chartFootprint)

float barDelta = 0.0
float barVol = volume

if hasPremium
    barDelta := chartFootprint.delta()
    barVol := chartFootprint.total_volume()
else
    float pChange = close - open
    float ltf_buy = pChange > 0 ? volume * 0.7 : pChange < 0 ? volume * 0.3 : volume * 0.5
    float ltf_sell = volume - ltf_buy
    barDelta := ltf_buy - ltf_sell

// Detection & Calculations
f_calculateAverageVolume(int length) => ta.sma(barVol, length)

f_calculatePriceMovementIntensity() =>
    float priceRange = high - low
    float avgRange = ta.atr(i_lookbackPeriod)
    avgRange > 0 ? priceRange / avgRange : 0.0

f_detectVoid() =>
    float avgVol = f_calculateAverageVolume(i_lookbackPeriod)
    bool isLowVol = avgVol > 0 ? barVol < avgVol * i_volumeThreshold : false
    bool isImbalance = barVol > 0 ? math.abs(barDelta) / barVol > i_imbalanceThresh : false
    
    float intensity = f_calculatePriceMovementIntensity()
    bool isRapid = intensity > i_priceMovementSensitivity
    
    bool isTrueVacuum = isRapid and isLowVol and not isImbalance
    bool isFlowVoid = isRapid and isImbalance and not isLowVol
    
    bool isVoidOut = false
    int typeOut = 0 
    
    if (i_detectMode == "Both" or i_detectMode == "True Vacuums Only") and isTrueVacuum
        isVoidOut := true
        typeOut := 1
    else if (i_detectMode == "Both" or i_detectMode == "Imbalance Flows Only") and isFlowVoid
        isVoidOut := true
        typeOut := 2
        
    [isVoidOut, typeOut]

f_calculateVoidStrength(int vType) =>
    float avgVol = f_calculateAverageVolume(i_lookbackPeriod)
    float volRatio = avgVol > 0 ? barVol / avgVol : 1.0
    float deltaRatio = barVol > 0 ? math.abs(barDelta) / barVol : 0.0
    float movementComponent = f_calculatePriceMovementIntensity() * 20

    if vType == 1 
        float volumeComponent = math.max(0, 100 * (1 - volRatio))
        math.min(100, volumeComponent + movementComponent)
    else 
        float volumeComponent = math.min(40, volRatio * 20)
        float orderFlowComponent = deltaRatio * 40
        math.min(100, volumeComponent + movementComponent + orderFlowComponent)

// Visualization
f_getTimeForBar(int barIdx) =>
    int timeDiff = bar_index - barIdx
    time[timeDiff]

f_createPolylineLayer(int startBar, int endBar, float topPrice, float bottomPrice, color baseColor, int transparency, float verticalOffset) =>
    float offsetTop = topPrice + verticalOffset
    float offsetBottom = bottomPrice + verticalOffset
    int startTime = f_getTimeForBar(startBar)
    int endTime = f_getTimeForBar(endBar)

    var array<chart.point> points = array.new<chart.point>()
    array.clear(points)
    array.push(points, chart.point.new(time = startTime, index = startBar, price = offsetTop))
    array.push(points, chart.point.new(time = endTime, index = endBar, price = offsetTop))
    array.push(points, chart.point.new(time = endTime, index = endBar, price = offsetBottom))
    array.push(points, chart.point.new(time = startTime, index = startBar, price = offsetBottom))
    array.push(points, chart.point.new(time = startTime, index = startBar, price = offsetTop))

    color layerColor = color.new(baseColor, transparency)
    polyline.new(points, closed = true, line_color = layerColor, fill_color = layerColor, line_width = 1)

f_createVoidVisuals(int startBar, int endBar, float topPrice, float bottomPrice, float voidStrength, float finalDelta, int vType) =>
    bool isBullish = finalDelta >= 0
    bool isVac = vType == 1
    
    color baseColor = isVac ? (isBullish ? i_vacBullColor : i_vacBearColor) : (isBullish ? i_imbBullColor : i_imbBearColor)

    box vBox = box.new(left=startBar, top=topPrice, right=bar_index + i_extendLength, bottom=bottomPrice, border_color=color(na), bgcolor=baseColor)

    polyline layer1 = f_createPolylineLayer(startBar, endBar, topPrice, bottomPrice, baseColor, 85, pixelSpacing * 2)
    polyline layer2 = f_createPolylineLayer(startBar, endBar, topPrice, bottomPrice, baseColor, 78, pixelSpacing)
    polyline layer3 = f_createPolylineLayer(startBar, endBar, topPrice, bottomPrice, baseColor, 70, 0)

    label lbl = na
    if i_showLabels
        string prefix = isVac ? "VAC Δ " : "IMB Δ "
        string labelText = prefix + (finalDelta > 0 ? "+" : "") + str.tostring(finalDelta, "#.##")
        int midBar = math.round((startBar + endBar) / 2)
        float midPrice = (topPrice + bottomPrice) / 2
        lbl := label.new(midBar, midPrice, labelText, style = label.style_none, textcolor = color.new(baseColor, 0), size = size.tiny)

    array.push(g_activeVoids, ActiveVoid.new(vBox, lbl, layer1, layer2, layer3, topPrice, bottomPrice, topPrice, bottomPrice, isBullish, isVac))

// Main Execution
[isVoid, currentVoidType] = f_detectVoid()
float currentStrength = isVoid ? f_calculateVoidStrength(currentVoidType) : 0.0

if isVoid
    if na(g_voidStartBar)
        g_voidStartBar := bar_index
        g_voidTopPrice := high
        g_voidBottomPrice := low
        g_consecutiveVoidBars := 1
        g_totalVoidStrength := currentStrength
        g_totalDelta := barDelta
        g_voidType := currentVoidType
    else if g_voidType == currentVoidType
        g_voidTopPrice := math.max(g_voidTopPrice, high)
        g_voidBottomPrice := math.min(g_voidBottomPrice, low)
        g_consecutiveVoidBars += 1
        g_totalVoidStrength += currentStrength
        g_totalDelta += barDelta
    else
        if g_consecutiveVoidBars >= i_minVoidBars
            float avgStrength = g_totalVoidStrength / g_consecutiveVoidBars
            f_createVoidVisuals(g_voidStartBar, bar_index - 1, g_voidTopPrice, g_voidBottomPrice, avgStrength, g_totalDelta, g_voidType)
            
        g_voidStartBar := bar_index
        g_voidTopPrice := high
        g_voidBottomPrice := low
        g_consecutiveVoidBars := 1
        g_totalVoidStrength := currentStrength
        g_totalDelta := barDelta
        g_voidType := currentVoidType
else 
    if not na(g_voidStartBar) and g_consecutiveVoidBars >= i_minVoidBars
        float avgStrength = g_totalVoidStrength / g_consecutiveVoidBars
        f_createVoidVisuals(g_voidStartBar, bar_index - 1, g_voidTopPrice, g_voidBottomPrice, avgStrength, g_totalDelta, g_voidType)

    g_voidStartBar := na
    g_voidTopPrice := na
    g_voidBottomPrice := na
    g_consecutiveVoidBars := 0
    g_totalVoidStrength := 0.0
    g_totalDelta := 0.0
    g_voidType := 0

// Mitigation & Memory Management
if array.size(g_activeVoids) > 0
    for i = array.size(g_activeVoids) - 1 to 0
        v = array.get(g_activeVoids, i)
        bool newlyFilled = false
        
        if v.isBullish
            if low <= v.origBot
                newlyFilled := true
            else if v.isVacuum and low < v.currentTop
                v.currentTop := low
                box.set_top(v.b, v.currentTop)
        else
            if high >= v.origTop
                newlyFilled := true
            else if v.isVacuum and high > v.currentBot
                v.currentBot := high
                box.set_bottom(v.b, v.currentBot)

        if newlyFilled
            if not i_showFilled
                box.delete(v.b)
                if not na(v.lbl)
                    label.delete(v.lbl)
            else
                box.set_top(v.b, v.origTop)
                box.set_bottom(v.b, v.origBot)
                box.set_bgcolor(v.b, i_filledColor)
                box.set_right(v.b, bar_index)
                if not na(v.lbl)
                    label.set_textcolor(v.lbl, color.new(i_filledColor, 0))
                
            polyline.delete(v.p1)
            polyline.delete(v.p2)
            polyline.delete(v.p3)
            array.remove(g_activeVoids, i)
        else
            box.set_right(v.b, bar_index + i_extendLength)

while array.size(g_activeVoids) > i_maxVoids
    v = array.shift(g_activeVoids)
    box.delete(v.b)
    if not na(v.lbl)
        label.delete(v.lbl)
    polyline.delete(v.p1)
    polyline.delete(v.p2)
    polyline.delete(v.p3)
````
