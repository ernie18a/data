# Candle Footprint POC and Fair Value Area @MaxMaserati

- url: https://www.tradingview.com/script/UnRo3pBU-Candle-Footprint-POC-and-Fair-Value-Area-MaxMaserati/
- type: indicator
- pine_id: PUB;b9c44c3fec6142f0bc1703a53a67aad3
- version: 1.0

## Description

Candle Footprint POC and Fair Value Area

Draws each candle's real footprint Point of Control (POC) and Value Area directly from tick-level volume data, sizes the POC box by how much volume it actually carried relative to recent bars, and flags candles where the visible price outcome disagrees with the underlying order flow.

[image]https://www.tradingview.com/x/mqoPFAQe/[/image]

─── WHY THESE COMPONENTS TOGETHER ───
A POC/Value Area box alone shows where volume concentrated but says nothing about whether the candle's close agreed with it. Delta alone shows net aggressive buying or selling but not where in the range it happened. Candle color alone shows only the surface result. Combined, the script flags a specific condition neither part shows alone: a candle whose visible color disagrees with its own volume-weighted center — for example a green candle closing on a net-bearish POC.

─── POC AND DIVERGENCE LOGIC ───
POC midpoint = (POC row upper price + POC row lower price) / 2, taken directly from the real footprint row that carried the most volume. Basic divergence = candle body direction disagrees with delta's sign. Strict divergence additionally requires the close to land on the wrong side of the POC or Value Area for that candle's direction.
[image]https://www.tradingview.com/x/UMCIOiMU/[/image]

─── HOW TO USE ───
1. Read the POC box color and position for the bar's highest-volume price.
2. Check the Delta label — it can disagree with the candle's own color, which is the point.
3. Enable a Basic Divergence filter to isolate candles where price and volume disagree, focus on sweeps. 
4. Enable a Strict Divergence filter for a higher-conviction version requiring the close itself to confirm the disagreement.
5. Use the Extended Current POC line/box to project the most recent bar's high-volume price forward.

─── SETTINGS ───
Global Display Elements — master toggles for boxes, labels, and historical candle limiting.
Bullish/Bearish Settings and Filters — colors and standard close-vs-POC/VA conditions.
Bullish/Bearish Divergence Filters — Basic and Strict disagreement conditions.
Extended Current POC — style, border, and extension length.
Footprint and Scaling Configuration — row height, Value Area percentage, and volume-based box scaling.

─── NOTES ───
Requires a TradingView Premium or Ultimate plan for footprint data. All values reflect confirmed, closed bars only — no repainting. Footprint calculation is limited to the most recent N bars (Performance setting) to prevent slow chart loads. Alerts are available for all standard and divergence conditions.

## Source Code

````pine
//@version=6
indicator("Candle Footprint POC and Fair Value Area @MaxMaserati", "Candle POC FVA @MaxMaserati", overlay=true, max_bars_back=100, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ─── Note: request.footprint() requires a TradingView Premium or Ultimate plan.
// On lower plans it compiles but returns na on every bar. ───

// ─── Synchronized Tracking Arrays ───
var array<box> bullishPOCBoxes  = array.new<box>()
var array<box> bearishPOCBoxes  = array.new<box>()
var array<box> bullishVABoxes   = array.new<box>()
var array<box> bearishVABoxes   = array.new<box>()
var array<label> bullishDeltaLabels = array.new<label>()
var array<label> bearishDeltaLabels = array.new<label>()
var array<label> bullishPOCVolLabels = array.new<label>()
var array<label> bearishPOCVolLabels = array.new<label>()
var array<float> pocVolHistory = array.new<float>()

// ─── Global Display Elements ───
globalGroup = "Global Display Elements"
showPOCBox         = input.bool(true, "Show POC Boxes", group=globalGroup)
showValueArea      = input.bool(true, "Show Value Area Boxes", group=globalGroup)
showDeltaLabels    = input.bool(true, "Show Delta Labels", group=globalGroup)

showPOCVolLabels   = input.bool(true, "Show POC Volume Labels", inline="pocVolInline", group=globalGroup)
pocVolumeLabelColor = input.color(color.black, "", inline="pocVolInline", group=globalGroup)

pocBoxBorderColor  = input.color(color.white, "POC Box Border Color", group=globalGroup)

limitCandlesToggle = input.bool(true, "Limit Historical Candles Shown", group=globalGroup)
candlesToShowCount = input.int(5, "Candles to Show (per direction)", minval=1, maxval=100, group=globalGroup)

// ─── Bullish Settings and Filters ───
bullGroup = "Bullish Settings and Filters"
showBullish         = input.bool(true, "Show Bullish Candle POC/VAH", group=bullGroup)
bullishPOCColor     = input.color(#00FF00, "POC and VA Color", inline="bull1", group=bullGroup)
filterCloseAbovePOC = input.bool(false, "+ Close Above POC", group=bullGroup)
filterCloseAboveVA  = input.bool(false, "+ Close Above VAH", group=bullGroup)

// ─── Bearish Settings and Filters ───
bearGroup = "Bearish Settings and Filters"
showBearish         = input.bool(true, "Show Bearish Candle POC/VAL", group=bearGroup)
bearishPOCColor     = input.color(#FF0000, "POC and VA Color", inline="bear1", group=bearGroup)
filterCloseBelowPOC = input.bool(false, "+ Close Below POC", group=bearGroup)
filterCloseBelowVA  = input.bool(false, "+ Close Below VAL", group=bearGroup)

// ─── Bullish Divergence Filters ───
bullDivGroup = "Bullish Divergence Filters"
filterBullCandleBearPOC    = input.bool(false, "Basic: Green Candle and Bearish POC", group=bullDivGroup)
filterBullDivCloseBelowPOC = input.bool(false, "Strict: + Close Below POC", group=bullDivGroup)
filterBullDivCloseBelowVA  = input.bool(false, "Strict: + Close Below VAL", group=bullDivGroup)

// ─── Bearish Divergence Filters ───
bearDivGroup = "Bearish Divergence Filters"
filterBearCandleBullPOC    = input.bool(false, "Basic: Red Candle and Bullish POC", group=bearDivGroup)
filterBearDivCloseAbovePOC = input.bool(false, "Strict: + Close Above POC", group=bearDivGroup)
filterBearDivCloseAboveVA  = input.bool(false, "Strict: + Close Above VAH", group=bearDivGroup)

// ─── Extended Current POC ───
extLineGroup = "Extended Current POC"
showExtPOC       = input.bool(true, "Show Extended POC", group=extLineGroup)
extPOCStyle      = input.string("Box", "Extended POC Style", options=["Box", "Line"], group=extLineGroup)
showExtPOCBorder = input.bool(false, "Show Border on Extended Box", group=extLineGroup)
pocExtendLength  = input.int(10, "Extension Length (bars)", minval=1, maxval=500, group=extLineGroup)

// ─── Footprint and Scaling Configuration ───
fpGroup = "Footprint and Scaling Configuration"
ticksPerRowInput    = input.int(4, "Ticks Per Footprint Row", minval=1, group=fpGroup)
vaPercentInput      = input.int(70, "Value Area %", minval=1, maxval=100, group=fpGroup)
minPOCBoxHeightFrac = input.float(0.15, "Min POC Box Thickness (fraction of row)", minval=0.05, maxval=1.0, step=0.05, group=fpGroup)
pocScalingLookback  = input.int(30, "POC Volume Scaling Lookback (bars)", minval=5, maxval=200, group=fpGroup)

// ─── Performance ───
perfGroup = "Performance"
maxBarsBackInput = input.int(300, "Max Bars to Calculate Footprint On", minval=50, maxval=2000, group=perfGroup,
     tooltip="Footprint aggregates tick-level volume per bar and is expensive to compute. Limiting calculation to the most recent N bars prevents slow chart loads.")

// ─── Trimming Function ───
trimObjects(pocBoxes, vaBoxes, deltaLabels, pocVolLabels, keepCount) =>
    while array.size(pocBoxes) > keepCount
        oldPOC = array.shift(pocBoxes)
        if not na(oldPOC)
            box.delete(oldPOC)
    while array.size(vaBoxes) > keepCount
        oldVA = array.shift(vaBoxes)
        if not na(oldVA)
            box.delete(oldVA)
    while array.size(deltaLabels) > keepCount
        oldLabel = array.shift(deltaLabels)
        if not na(oldLabel)
            label.delete(oldLabel)
    while array.size(pocVolLabels) > keepCount
        oldPOCLabel = array.shift(pocVolLabels)
        if not na(oldPOCLabel)
            label.delete(oldPOCLabel)

// ─── Main Execution ───
var line currentPOCLine = na
var box  currentPOCBox  = na

float plotDeltaValue = na
float plotPOCRowWidth = na

// Alert-trigger variables — hoisted to script scope so alertcondition() can read them
// every bar, and reset each bar so alerts only fire on the bar the condition is true.
bool alertBullBasicDiv     = false
bool alertBullStrictPOCDiv = false
bool alertBullStrictVADiv  = false
bool alertBearBasicDiv     = false
bool alertBearStrictPOCDiv = false
bool alertBearStrictVADiv  = false
bool alertCloseAbovePOC    = false
bool alertCloseAboveVA     = false
bool alertCloseBelowPOC    = false
bool alertCloseBelowVA     = false

if barstate.isconfirmed and (bar_index >= last_bar_index - maxBarsBackInput)
    footprint fp = request.footprint(ticksPerRowInput, vaPercentInput)

    if not na(fp)
        float buyVolume  = fp.buy_volume()
        float sellVolume = fp.sell_volume()
        float deltaValue = fp.delta()

        volume_row pocRow = fp.poc()
        volume_row vahRow = fp.vah()
        volume_row valRow = fp.val()

        float pocUpperRaw = pocRow.up_price()
        float pocLowerRaw = pocRow.down_price()
        float vahUpperRaw = vahRow.up_price()
        float valLowerRaw = valRow.down_price()

        float pocUpper = math.min(pocUpperRaw, high)
        float pocLower = math.max(pocLowerRaw, low)
        float vahUpper = math.min(vahUpperRaw, high)
        float valLower = math.max(valLowerRaw, low)

        float pocRowVolume = pocRow.total_volume()
        float pocRowDelta  = pocRow.delta()

        int currentBar = bar_index
        isBullish = deltaValue >= 0

        pocColor = isBullish ? bullishPOCColor : bearishPOCColor
        bullishDeltaColor = color.new(bullishPOCColor, 0)
        bearishDeltaColor = color.new(bearishPOCColor, 0)
        bullishVAColor = color.new(bullishPOCColor, 95)
        bearishVAColor = color.new(bearishPOCColor, 95)

        if not na(pocRowVolume)
            array.push(pocVolHistory, pocRowVolume)
            if array.size(pocVolHistory) > pocScalingLookback
                array.shift(pocVolHistory)

        float rollingMaxPocVol = array.size(pocVolHistory) > 0 ? array.max(pocVolHistory) : na
        float volRatio = (not na(pocRowVolume) and not na(rollingMaxPocVol) and rollingMaxPocVol > 0) ?
             math.min(1.0, pocRowVolume / rollingMaxPocVol) : 0.5

        float pocMidPrice   = (pocUpper + pocLower) / 2.0
        float fullHalfHeight = (pocUpper - pocLower) / 2.0
        float heightFrac    = minPOCBoxHeightFrac + (1.0 - minPOCBoxHeightFrac) * volRatio
        float scaledTop     = pocMidPrice + fullHalfHeight * heightFrac
        float scaledBottom  = pocMidPrice - fullHalfHeight * heightFrac
        int   pocBorderWidth = math.round(2 + volRatio * 4)
        int   pocFillTransparency = math.round(70 - volRatio * 65)

        bool candleBullishBody = close > open
        bool candleBearishBody = close < open

        // ─── Alert condition evaluation — independent of display filter toggles ───
        alertBullBasicDiv     := candleBullishBody and not isBullish
        alertBullStrictPOCDiv := candleBullishBody and not isBullish and close < pocMidPrice
        alertBullStrictVADiv  := candleBullishBody and not isBullish and close < valLower
        alertBearBasicDiv     := candleBearishBody and isBullish
        alertBearStrictPOCDiv := candleBearishBody and isBullish and close > pocMidPrice
        alertBearStrictVADiv  := candleBearishBody and isBullish and close > vahUpper
        alertCloseAbovePOC    := candleBullishBody and close > pocMidPrice
        alertCloseAboveVA     := candleBullishBody and close > vahUpper
        alertCloseBelowPOC    := candleBearishBody and close < pocMidPrice
        alertCloseBelowVA     := candleBearishBody and close < valLower

        bool anyFilterActive = filterCloseAbovePOC or filterCloseAboveVA or filterBullCandleBearPOC or filterBullDivCloseBelowPOC or filterBullDivCloseBelowVA or filterCloseBelowPOC or filterCloseBelowVA or filterBearCandleBullPOC or filterBearDivCloseAbovePOC or filterBearDivCloseAboveVA
        bool passesFilter = not anyFilterActive

        if anyFilterActive
            if filterCloseAbovePOC and candleBullishBody and close > pocMidPrice
                passesFilter := true
            if filterCloseAboveVA and candleBullishBody and close > vahUpper
                passesFilter := true

            if filterCloseBelowPOC and candleBearishBody and close < pocMidPrice
                passesFilter := true
            if filterCloseBelowVA and candleBearishBody and close < valLower
                passesFilter := true

            if filterBullCandleBearPOC and candleBullishBody and not isBullish
                passesFilter := true
            if filterBullDivCloseBelowPOC and candleBullishBody and not isBullish and close < pocMidPrice
                passesFilter := true
            if filterBullDivCloseBelowVA and candleBullishBody and not isBullish and close < valLower
                passesFilter := true

            if filterBearCandleBullPOC and candleBearishBody and isBullish
                passesFilter := true
            if filterBearDivCloseAbovePOC and candleBearishBody and isBullish and close > pocMidPrice
                passesFilter := true
            if filterBearDivCloseAboveVA and candleBearishBody and isBullish and close > vahUpper
                passesFilter := true

        box newVaBox = na
        if showValueArea and passesFilter
            if isBullish and showBullish and not na(vahUpper) and not na(valLower)
                newVaBox := box.new(left=currentBar, top=vahUpper, right=currentBar + 1, bottom=valLower,
                     bgcolor=bullishVAColor, border_color=color.new(bullishVAColor, 40), border_width=1)
                array.push(bullishVABoxes, newVaBox)
            else if not isBullish and showBearish and not na(vahUpper) and not na(valLower)
                newVaBox := box.new(left=currentBar, top=vahUpper, right=currentBar + 1, bottom=valLower,
                     bgcolor=bearishVAColor, border_color=color.new(bearishVAColor, 40), border_width=1)
                array.push(bearishVABoxes, newVaBox)

        box newPocBox = na
        if showPOCBox and passesFilter
            if isBullish and showBullish and not na(pocUpper) and not na(pocLower)
                newPocBox := box.new(left=currentBar, top=scaledTop, right=currentBar + 1, bottom=scaledBottom,
                     bgcolor=color.new(bullishPOCColor, pocFillTransparency), border_color=pocBoxBorderColor, border_width=pocBorderWidth)
                array.push(bullishPOCBoxes, newPocBox)
            else if not isBullish and showBearish and not na(pocUpper) and not na(pocLower)
                newPocBox := box.new(left=currentBar, top=scaledTop, right=currentBar + 1, bottom=scaledBottom,
                     bgcolor=color.new(bearishPOCColor, pocFillTransparency), border_color=pocBoxBorderColor, border_width=pocBorderWidth)
                array.push(bearishPOCBoxes, newPocBox)

        label newPocVolumeLabel = na
        if showPOCVolLabels and not na(pocRowVolume) and passesFilter
            pocVolK = pocRowVolume / 1000
            pocDeltaK = na(pocRowDelta) ? na : pocRowDelta / 1000
            pocLabelText = str.tostring(math.round(pocVolK * 10) / 10) + "K" +
                 (na(pocDeltaK) ? "" : "  Δ" + (pocRowDelta >= 0 ? "+" : "") + str.tostring(math.round(pocDeltaK * 10) / 10) + "K")

            if isBullish and showBullish
                newPocVolumeLabel := label.new(x=currentBar, y=pocMidPrice, text=pocLabelText,
                     style=label.style_none, color=pocVolumeLabelColor, textcolor=pocVolumeLabelColor, size=size.tiny)
                array.push(bullishPOCVolLabels, newPocVolumeLabel)
            else if not isBullish and showBearish
                newPocVolumeLabel := label.new(x=currentBar, y=pocMidPrice, text=pocLabelText,
                     style=label.style_none, color=pocVolumeLabelColor, textcolor=pocVolumeLabelColor, size=size.tiny)
                array.push(bearishPOCVolLabels, newPocVolumeLabel)

        label newDeltaLabel = na
        if showDeltaLabels and deltaValue != 0 and passesFilter
            deltaK = deltaValue / 1000
            deltaText = (deltaValue >= 0 ? "+" : "") + str.tostring(math.round(deltaK * 10) / 10) + "K"

            if isBullish and showBullish
                labelY = low - (high - low) * 0.08
                newDeltaLabel := label.new(x=currentBar, y=labelY, text=deltaText, style=label.style_none,
                     color=bullishDeltaColor, textcolor=bullishDeltaColor, size=size.normal)
                array.push(bullishDeltaLabels, newDeltaLabel)
            else if not isBullish and showBearish
                labelY = high + (high - low) * 0.08
                newDeltaLabel := label.new(x=currentBar, y=labelY, text=deltaText, style=label.style_none,
                     color=bearishDeltaColor, textcolor=bearishDeltaColor, size=size.normal)
                array.push(bearishDeltaLabels, newDeltaLabel)

        if limitCandlesToggle
            trimObjects(bullishPOCBoxes, bullishVABoxes, bullishDeltaLabels, bullishPOCVolLabels, candlesToShowCount)
            trimObjects(bearishPOCBoxes, bearishVABoxes, bearishDeltaLabels, bearishPOCVolLabels, candlesToShowCount)

        if showExtPOC
            if not na(currentPOCLine)
                line.delete(currentPOCLine)
            if not na(currentPOCBox)
                box.delete(currentPOCBox)

            if (isBullish and showBullish) or (not isBullish and showBearish)
                if extPOCStyle == "Box"
                    extHalfHeight = ((pocUpper - pocLower) / 2.0) * 1.5
                    extTop = pocMidPrice + extHalfHeight
                    extBottom = pocMidPrice - extHalfHeight

                    currentPOCBox := box.new(left=currentBar, top=extTop, right=currentBar + pocExtendLength, bottom=extBottom,
                         bgcolor=color.new(pocColor, 80), border_color=showExtPOCBorder ? pocColor : na, border_width=1)
                else
                    currentPOCLine := line.new(x1=currentBar, y1=pocMidPrice, x2=currentBar + pocExtendLength, y2=pocMidPrice,
                         color=pocColor, width=2, style=line.style_solid)

        plotDeltaValue := deltaValue
        plotPOCRowWidth := pocUpper - pocLower
    else
        label.new(bar_index, high, text="✕", style=label.style_none,
             color=color.gray, textcolor=color.gray, size=size.tiny)

// ─── Data Window Plots ───
plot(plotDeltaValue, title="Volume Delta", color=plotDeltaValue >= 0 ? color.new(bullishPOCColor, 0) : color.new(bearishPOCColor, 0), display=display.data_window)
plot(plotPOCRowWidth, title="POC Row Width", display=display.data_window)

// ─── Alert Conditions ───
alertcondition(alertBullBasicDiv, title="Bullish Basic Divergence", message="Green candle closed with a bearish POC (net sell volume dominated the high-volume price).")
alertcondition(alertBullStrictPOCDiv, title="Bullish Strict Divergence: Close Below POC", message="Green candle closed below its own POC despite a bearish POC read.")
alertcondition(alertBullStrictVADiv, title="Bullish Strict Divergence: Close Below VAL", message="Green candle closed below the Value Area Low despite a bearish POC read.")
alertcondition(alertBearBasicDiv, title="Bearish Basic Divergence", message="Red candle closed with a bullish POC (net buy volume dominated the high-volume price).")
alertcondition(alertBearStrictPOCDiv, title="Bearish Strict Divergence: Close Above POC", message="Red candle closed above its own POC despite a bullish POC read.")
alertcondition(alertBearStrictVADiv, title="Bearish Strict Divergence: Close Above VAH", message="Red candle closed above the Value Area High despite a bullish POC read.")
alertcondition(alertCloseAbovePOC, title="Close Above POC", message="Bullish candle closed above its own POC.")
alertcondition(alertCloseAboveVA, title="Close Above VAH", message="Bullish candle closed above the Value Area High.")
alertcondition(alertCloseBelowPOC, title="Close Below POC", message="Bearish candle closed below its own POC.")
alertcondition(alertCloseBelowVA, title="Close Below VAL", message="Bearish candle closed below the Value Area Low.")
````
