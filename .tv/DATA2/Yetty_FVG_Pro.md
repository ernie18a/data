<!-- tradingview-pine-id: PUB;ca803c9350cb420b9fd95341cd66c774 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Yetty FVG Pro

Source: https://www.tradingview.com/script/MvADPVhJ-Yetty-FVG-Pro/

## Description

YETTY FVG PRO

Yetty FVG Pro is a clean fair value gap and inversion fair value gap indicator designed to display the most recent imbalance zones without filling the chart with old or irrelevant boxes.

The indicator identifies confirmed three-candle fair value gaps on the chart’s current timeframe and monitors those zones for a potential inversion. Traders can independently control how many FVG and IFVG zones remain visible.

The default display shows:

• One recent active FVG
• Three recent IFVG zones
• Bullish FVGs in green
• Bearish FVGs in red
• Bullish IFVGs in aqua
• Bearish IFVGs in fuchsia

WHAT IS A FAIR VALUE GAP?

A fair value gap, or FVG, is a three-candle price imbalance created when the first and third candles do not overlap completely.

This can occur when price moves rapidly through an area without balanced two-sided trading.

The untraded area between the first and third candles becomes the fair value gap.

These zones may later act as areas of interest when price returns.

BULLISH FAIR VALUE GAP

A bullish FVG forms when:

1. Price moves sharply upward.
2. The low of the third candle is above the high of the first candle.
3. A visible gap remains between those two prices.
4. The completed zone meets the selected minimum-size requirement.

Bullish FVGs are displayed in green by default.

A bullish FVG can represent an area where price moved upward with strong displacement. Traders may monitor the zone for a reaction, support, continuation or failure.

BEARISH FAIR VALUE GAP

A bearish FVG forms when:

1. Price moves sharply downward.
2. The high of the third candle is below the low of the first candle.
3. A visible gap remains between those two prices.
4. The completed zone meets the selected minimum-size requirement.

Bearish FVGs are displayed in red by default.

A bearish FVG can represent an area where price moved downward with strong displacement. Traders may monitor the zone for a reaction, resistance, continuation or failure.

WHAT IS AN INVERSION FAIR VALUE GAP?

An inversion fair value gap, or IFVG, forms when price completely invalidates an existing FVG by closing through the opposite side of the entire zone.

Instead of deleting that failed FVG, Yetty FVG Pro converts it into an IFVG.

This allows traders to see where a previous imbalance failed and may have changed its directional role.

BULLISH IFVG

A bullish IFVG begins as a bearish FVG.

It becomes a bullish IFVG when a confirmed candle closes above the top of the entire bearish FVG zone.

The original bearish zone is then converted into an aqua bullish IFVG.

This indicates that price has broken completely through a previous bearish imbalance. Traders may watch the converted zone for potential support if price returns.

BEARISH IFVG

A bearish IFVG begins as a bullish FVG.

It becomes a bearish IFVG when a confirmed candle closes below the bottom of the entire bullish FVG zone.

The original bullish zone is then converted into a fuchsia bearish IFVG.

This indicates that price has broken completely through a previous bullish imbalance. Traders may watch the converted zone for potential resistance if price returns.

HOW TO USE IT

Yetty FVG Pro is designed to provide areas of interest rather than automatic trade-entry signals.

Start by identifying the broader direction and structure of the market.

In an upward-trending market, traders may give more attention to bullish FVGs and bullish IFVGs below or near current price.

In a downward-trending market, traders may give more attention to bearish FVGs and bearish IFVGs above or near current price.

When price returns to a displayed zone, observe how it reacts.

Possible reactions may include:

• Immediate rejection from the zone
• Partial entry followed by continuation
• Full traversal of the zone
• Consolidation inside the zone
• A complete close through the zone
• Conversion from an FVG into an IFVG

A zone should not automatically be treated as an entry. Evaluate the reaction alongside market structure, trend, liquidity, volume and risk.

POSSIBLE BULLISH WORKFLOW

1. Establish that the larger market context is bullish.
2. Identify a recent bullish FVG or bullish IFVG.
3. Wait for price to return to the zone.
4. Look for buyers to defend the area.
5. Wait for bullish confirmation.
6. Establish an entry, stop and target using your own trading plan.

Bullish confirmation might include:

• A rejection wick
• A bullish engulfing candle
• A liquidity sweep beneath the zone
• A short-term bullish structure break
• Increased buying volume
• Reclaiming VWAP or an important EMA

POSSIBLE BEARISH WORKFLOW

1. Establish that the larger market context is bearish.
2. Identify a recent bearish FVG or bearish IFVG.
3. Wait for price to return to the zone.
4. Look for sellers to defend the area.
5. Wait for bearish confirmation.
6. Establish an entry, stop and target using your own trading plan.

Bearish confirmation might include:

• A rejection wick
• A bearish engulfing candle
• A liquidity sweep above the zone
• A short-term bearish structure break
• Increased selling volume
• Rejection from VWAP or an important EMA

USING FVGs WITH IFVGs

An active FVG shows an imbalance that has not yet closed completely through its opposite boundary.

An IFVG shows that the original FVG failed and inverted.

This distinction can help traders separate an active imbalance from a zone where price has already demonstrated a directional change.

For example:

A bullish FVG may initially act as support.

If price later closes below the entire bullish FVG, the zone becomes a bearish IFVG.

If price returns to that converted zone from below, traders may monitor it as potential resistance.

The reverse logic applies when a bearish FVG becomes a bullish IFVG.

USING YETTY FVG PRO WITH OTHER TOOLS

FVG and IFVG zones can become more meaningful when they align with other areas of interest, including:

• Yetty ORB Pro boundaries
• Yetty Liquidity Sweep Pro levels
• Previous session highs or lows
• Higher-timeframe support and resistance
• VWAP
• The 9, 21 or 200 EMA
• Opening-range breakouts
• Swing highs and swing lows
• Supply and demand zones
• Strong displacement candles

Confluence does not guarantee that a zone will hold, but it can provide additional context for evaluating a reaction.

CHART TIMEFRAME

Yetty FVG Pro uses the chart’s current timeframe only.

If the indicator is applied to a one-minute chart, it identifies one-minute FVGs and IFVGs.

If it is applied to a five-minute chart, it identifies five-minute FVGs and IFVGs.

If it is applied to a 15-minute chart, it identifies 15-minute FVGs and IFVGs.

Changing the chart timeframe causes the indicator to calculate zones from the candles on the newly selected timeframe.

Lower timeframes will generally create more zones.

Higher timeframes will generally create fewer but broader zones.

DISPLAY SETTINGS

Show FVGs

Turns the active FVG boxes on or off.

Show IFVGs

Turns inversion fair value gap boxes on or off.

Number of FVG Zones to Show

Controls how many recent active FVG zones remain visible.

The available range is one through five.

The default is one FVG.

Number of IFVG Zones to Show

Controls how many recent inversion zones remain visible.

The available range is one through five.

The default is three IFVGs.

FVG and IFVG counts are controlled separately. For example, a trader can display one FVG while keeping three IFVGs visible.

Show Box Labels

Displays the directional classification inside each zone:

• BULL FVG
• BEAR FVG
• BULL IFVG
• BEAR IFVG

Extend Boxes Past Pattern

Controls how many additional candles each box extends beyond the completed three-candle pattern.

The default extension is five bars.

Box Fill Transparency

Controls the transparency of all displayed zones.

A higher number creates a more transparent box.

The default transparency is 85.

MINIMUM FVG SIZE

The Minimum FVG Size setting controls the smallest imbalance that can qualify as an FVG.

This value is measured in ticks and automatically uses the instrument’s minimum tick size.

Increasing the minimum size filters out smaller gaps and reduces the number of displayed zones.

Decreasing it makes the indicator more sensitive and allows smaller gaps to qualify.

The default minimum is one tick.

COLORS

The default colors are:

• Bullish FVG: lime green
• Bearish FVG: red
• Bullish IFVG: aqua
• Bearish IFVG: fuchsia

Every color can be customized from the indicator settings.

ALERTS

Yetty FVG Pro includes alert conditions for:

• New bullish FVG
• New bearish FVG
• New bullish IFVG
• New bearish IFVG

To create an alert:

1. Add Yetty FVG Pro to the chart.
2. Open TradingView’s alert menu.
3. Select Yetty FVG Pro under Conditions.
4. Choose the desired FVG or IFVG event.
5. Configure the notification method and expiration.
6. Create the alert.

Alerts are triggered from confirmed candle conditions.

IMPORTANT NOTES

Yetty FVG Pro displays price imbalances and inversion zones. It does not automatically place trades or determine entries, stop-losses, profit targets or position sizes.

A fair value gap is not guaranteed to be filled.

A zone is not guaranteed to produce a reversal or continuation.

Price can partially enter a zone, trade completely through it or move away without returning.

An IFVG appears only after a candle closes completely through the opposite side of an existing FVG. A wick through the zone without the required close does not create an inversion.

Because the indicator limits how many zones remain visible, an older box may be removed when a newer qualifying zone forms. Removing the box from the chart does not mean the historical price area has ceased to exist; it means the selected display limit has been reached.

The indicator evaluates patterns using completed candles.

For the clearest price information, use standard candlestick charts. Non-standard chart types such as Heikin Ashi, Renko, Kagi, Line Break, Point & Figure or Range charts may calculate prices differently and can produce misleading zones.

No indicator can predict future market movement or eliminate trading risk. Yetty FVG Pro should be used as an informational charting tool within a complete trading and risk-management plan.

Suggested starting point: NQ or MNQ on a five-minute standard candlestick chart using the default display of one FVG and three IFVGs.

---

## Source Code

````pine
//@version=6
indicator("Yetty FVG Pro", shorttitle="Yetty FVG Pro", overlay=true, max_boxes_count=100)

// ============================================================================
// DISPLAY — ORIGINAL YETTY DEFAULTS
// ============================================================================
showFVG  = input.bool(true, "Show FVGs", group="Display")
showIFVG = input.bool(true, "Show IFVGs", group="Display")
showBullFVG = input.bool(true, "Show bullish FVGs", group="Display")
showBearFVG = input.bool(true, "Show bearish FVGs", group="Display")
showBullIFVG = input.bool(true, "Show bullish IFVGs", group="Display")
showBearIFVG = input.bool(true, "Show bearish IFVGs", group="Display")
fvgZonesToShow = input.int(1, "Number of FVG zones to show", minval=1, maxval=5, group="Display")
ifvgZonesToShow = input.int(3, "Number of IFVG zones to show", minval=1, maxval=5, group="Display")
showText = input.bool(true, "Show box labels", group="Display")
extraBars = input.int(5, "Extend boxes past pattern (bars)", minval=0, maxval=100, group="Display")
extensionMode = input.string("Fixed bars", "Box extension mode", options=["Fixed bars", "Until resolved", "Extend right"], group="Display")

// ============================================================================
// FVG SETTINGS
// ============================================================================
gapSizeMode = input.string("Ticks", "Minimum gap measured in", options=["Ticks", "Points"], group="FVG")
minGapTicks = input.int(1, "Minimum FVG size (ticks)", minval=1, group="FVG")
minGapPoints = input.float(1.0, "Minimum FVG size (points)", minval=0.0, step=0.25, group="FVG")
bullColor = input.color(color.lime, "Bullish FVG color", group="FVG")
bearColor = input.color(color.red, "Bearish FVG color", group="FVG")
fvgBorderTransparency = input.int(0, "FVG border transparency", minval=0, maxval=100, group="FVG")
fvgFillTransparency = input.int(85, "FVG fill transparency", minval=0, maxval=100, group="FVG")

// ============================================================================
// IFVG SETTINGS
// ============================================================================
bullInverseColor = input.color(color.aqua, "Bullish IFVG color", group="IFVG")
bearInverseColor = input.color(color.fuchsia, "Bearish IFVG color", group="IFVG")
ifvgBorderTransparency = input.int(0, "IFVG border transparency", minval=0, maxval=100, group="IFVG")
ifvgFillTransparency = input.int(85, "IFVG fill transparency", minval=0, maxval=100, group="IFVG")
inversionConfirmation = input.string("Full-zone close", "FVG inversion confirmation", options=["Wick through", "Close inside", "Midpoint close", "Full-zone close"], group="IFVG")
removeMitigatedIFVG = input.bool(false, "Remove mitigated IFVGs", group="IFVG")
markMitigatedIFVG = input.bool(false, "Mark mitigated IFVGs", group="IFVG")
ifvgMitigationConfirmation = input.string("Full-zone close", "IFVG mitigation confirmation", options=["Wick through", "Close inside", "Midpoint close", "Full-zone close"], group="IFVG")

// ============================================================================
// OPTIONAL FILTERS — OFF BY DEFAULT
// ============================================================================
useDisplacementFilter = input.bool(false, "Require displacement candle", group="Optional Filters")
minBodyPercent = input.float(60.0, "Minimum displacement body %", minval=0.0, maxval=100.0, step=1.0, group="Optional Filters")
useVolumeFilter = input.bool(false, "Require above-average volume", group="Optional Filters")
volumeLength = input.int(20, "Volume average length", minval=1, group="Optional Filters")
volumeMultiplier = input.float(1.0, "Volume multiplier", minval=0.1, step=0.1, group="Optional Filters")
useSessionFilter = input.bool(false, "Limit new FVGs to session", group="Optional Filters")
filterSession = input.session("0930-1600", "Detection session", group="Optional Filters")

// ============================================================================
// OPTIONAL ALERT CONTROLS — OFF BY DEFAULT
// ============================================================================
alertFirstTouch = input.bool(false, "Enable first-touch alerts", group="Optional Alerts")
alertMidpointTouch = input.bool(false, "Enable midpoint-touch alerts", group="Optional Alerts")
alertMitigation = input.bool(false, "Enable IFVG mitigation alerts", group="Optional Alerts")

// ============================================================================
// OPTIONAL STATUS PANEL — OFF BY DEFAULT
// ============================================================================
showStatusPanel = input.bool(false, "Show status panel", group="Status Panel")
panelPosition = input.string("Top Right", "Panel position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Status Panel")

// ============================================================================
// HELPERS
// ============================================================================
f_boxRight() =>
    extensionMode == "Fixed bars" ? bar_index + 1 + extraBars : bar_index + 1

f_boxExtend() =>
    extensionMode == "Extend right" ? extend.right : extend.none

f_isVisibleFVG(int direction) =>
    showFVG and ((direction == 1 and showBullFVG) or (direction == -1 and showBearFVG))

f_isVisibleIFVG(int direction) =>
    showIFVG and ((direction == 1 and showBullIFVG) or (direction == -1 and showBearIFVG))

f_bearBreak(string mode, float top, float bottom) =>
    float midpoint = (top + bottom) / 2.0
    mode == "Wick through" ? low < bottom : mode == "Close inside" ? close < top : mode == "Midpoint close" ? close < midpoint : close < bottom

f_bullBreak(string mode, float top, float bottom) =>
    float midpoint = (top + bottom) / 2.0
    mode == "Wick through" ? high > top : mode == "Close inside" ? close > bottom : mode == "Midpoint close" ? close > midpoint : close > top

f_panelPosition(string selected) =>
    selected == "Top Left" ? position.top_left : selected == "Bottom Right" ? position.bottom_right : selected == "Bottom Left" ? position.bottom_left : position.top_right

// ============================================================================
// FVG DETECTION — CHART TIMEFRAME ONLY
// ============================================================================
minimumGap = gapSizeMode == "Ticks" ? minGapTicks * syminfo.mintick : minGapPoints
middleRange = high[1] - low[1]
middleBodyPercent = middleRange > 0 ? math.abs(close[1] - open[1]) / middleRange * 100.0 : 0.0
displacementPass = not useDisplacementFilter or middleBodyPercent >= minBodyPercent
volumeAverage = ta.sma(volume, volumeLength)
volumePass = not useVolumeFilter or (not na(volumeAverage[1]) and volume[1] > volumeAverage[1] * volumeMultiplier)
sessionPass = not useSessionFilter or not na(time(timeframe.period, filterSession))

bullFVG = bar_index >= 2 and low > high[2] and low - high[2] >= minimumGap and displacementPass and volumePass and sessionPass
bearFVG = bar_index >= 2 and high < low[2] and low[2] - high >= minimumGap and displacementPass and volumePass and sessionPass

// ============================================================================
// ACTIVE FVG STORAGE
// Direction: 1 = bullish FVG, -1 = bearish FVG
// ============================================================================
var array<box> fvgBoxes = array.new<box>()
var array<float> fvgTops = array.new<float>()
var array<float> fvgBottoms = array.new<float>()
var array<int> fvgDirections = array.new<int>()
var array<int> fvgCreatedBars = array.new<int>()
var array<bool> fvgTouched = array.new<bool>()
var array<bool> fvgMidTouched = array.new<bool>()

// ============================================================================
// ACTIVE IFVG STORAGE
// Direction: 1 = bullish IFVG, -1 = bearish IFVG
// ============================================================================
var array<box> ifvgBoxes = array.new<box>()
var array<float> ifvgTops = array.new<float>()
var array<float> ifvgBottoms = array.new<float>()
var array<int> ifvgDirections = array.new<int>()
var array<int> ifvgCreatedBars = array.new<int>()
var array<bool> ifvgTouched = array.new<bool>()
var array<bool> ifvgMidTouched = array.new<bool>()
var array<bool> ifvgMitigated = array.new<bool>()

// ============================================================================
// PER-BAR ALERT FLAGS
// ============================================================================
bool newBullIFVG = false
bool newBearIFVG = false
bool newFVGFirstTouch = false
bool newIFVGFirstTouch = false
bool newFVGMidpointTouch = false
bool newIFVGMidpointTouch = false
bool newBullIFVGMitigation = false
bool newBearIFVGMitigation = false

// ============================================================================
// MAIN LOGIC
// ============================================================================
if barstate.isconfirmed
    newBullIFVG := false
    newBearIFVG := false
    newFVGFirstTouch := false
    newIFVGFirstTouch := false
    newFVGMidpointTouch := false
    newIFVGMidpointTouch := false
    newBullIFVGMitigation := false
    newBearIFVGMitigation := false

    // Keep unresolved boxes visually current only when that optional mode is used.
    if extensionMode == "Until resolved"
        if array.size(fvgBoxes) > 0
            for updateIndex = 0 to array.size(fvgBoxes) - 1
                box.set_right(array.get(fvgBoxes, updateIndex), bar_index + 1)

        if array.size(ifvgBoxes) > 0
            for updateIndex = 0 to array.size(ifvgBoxes) - 1
                if not array.get(ifvgMitigated, updateIndex)
                    box.set_right(array.get(ifvgBoxes, updateIndex), bar_index + 1)

    // ------------------------------------------------------------------------
    // CHECK ACTIVE IFVGs FOR TOUCHES AND MITIGATION
    // ------------------------------------------------------------------------
    int inverseIndex = array.size(ifvgBoxes) - 1

    while inverseIndex >= 0
        box inverseBox = array.get(ifvgBoxes, inverseIndex)
        float inverseTop = array.get(ifvgTops, inverseIndex)
        float inverseBottom = array.get(ifvgBottoms, inverseIndex)
        int inverseDirection = array.get(ifvgDirections, inverseIndex)
        int inverseCreatedBar = array.get(ifvgCreatedBars, inverseIndex)
        bool inverseWasTouched = array.get(ifvgTouched, inverseIndex)
        bool inverseMidWasTouched = array.get(ifvgMidTouched, inverseIndex)
        bool inverseWasMitigated = array.get(ifvgMitigated, inverseIndex)
        float inverseMid = (inverseTop + inverseBottom) / 2.0
        bool afterCreation = bar_index > inverseCreatedBar
        bool inverseOverlap = afterCreation and high >= inverseBottom and low <= inverseTop
        bool inverseMidOverlap = afterCreation and low <= inverseMid and high >= inverseMid

        if inverseOverlap and not inverseWasTouched
            array.set(ifvgTouched, inverseIndex, true)
            newIFVGFirstTouch := true

        if inverseMidOverlap and not inverseMidWasTouched
            array.set(ifvgMidTouched, inverseIndex, true)
            newIFVGMidpointTouch := true

        bool inverseIsMitigated = not inverseWasMitigated and ((inverseDirection == 1 and f_bearBreak(ifvgMitigationConfirmation, inverseTop, inverseBottom)) or (inverseDirection == -1 and f_bullBreak(ifvgMitigationConfirmation, inverseTop, inverseBottom)))

        if inverseIsMitigated
            if inverseDirection == 1
                newBullIFVGMitigation := true
            else
                newBearIFVGMitigation := true

            if removeMitigatedIFVG
                box.delete(inverseBox)
                array.remove(ifvgBoxes, inverseIndex)
                array.remove(ifvgTops, inverseIndex)
                array.remove(ifvgBottoms, inverseIndex)
                array.remove(ifvgDirections, inverseIndex)
                array.remove(ifvgCreatedBars, inverseIndex)
                array.remove(ifvgTouched, inverseIndex)
                array.remove(ifvgMidTouched, inverseIndex)
                array.remove(ifvgMitigated, inverseIndex)
            else
                array.set(ifvgMitigated, inverseIndex, true)

                if markMitigatedIFVG
                    color mitigatedColor = inverseDirection == 1 ? bullInverseColor : bearInverseColor
                    box.set_border_color(inverseBox, color.new(mitigatedColor, 65))
                    box.set_bgcolor(inverseBox, color.new(mitigatedColor, 94))
                    box.set_text(inverseBox, showText ? (inverseDirection == 1 ? "BULL IFVG — MITIGATED" : "BEAR IFVG — MITIGATED") : "")

        inverseIndex -= 1

    // ------------------------------------------------------------------------
    // CHECK ACTIVE FVGs FOR TOUCHES, MIDPOINTS, AND INVERSION
    // ------------------------------------------------------------------------
    int fvgIndex = array.size(fvgBoxes) - 1

    while fvgIndex >= 0
        box currentBox = array.get(fvgBoxes, fvgIndex)
        float currentTop = array.get(fvgTops, fvgIndex)
        float currentBottom = array.get(fvgBottoms, fvgIndex)
        int currentDirection = array.get(fvgDirections, fvgIndex)
        int currentCreatedBar = array.get(fvgCreatedBars, fvgIndex)
        bool currentWasTouched = array.get(fvgTouched, fvgIndex)
        bool currentMidWasTouched = array.get(fvgMidTouched, fvgIndex)
        float currentMid = (currentTop + currentBottom) / 2.0
        bool afterCreation = bar_index > currentCreatedBar
        bool currentOverlap = afterCreation and high >= currentBottom and low <= currentTop
        bool currentMidOverlap = afterCreation and low <= currentMid and high >= currentMid

        if currentOverlap and not currentWasTouched
            array.set(fvgTouched, fvgIndex, true)
            newFVGFirstTouch := true

        if currentMidOverlap and not currentMidWasTouched
            array.set(fvgMidTouched, fvgIndex, true)
            newFVGMidpointTouch := true

        bool bearishInversion = currentDirection == 1 and f_bearBreak(inversionConfirmation, currentTop, currentBottom)
        bool bullishInversion = currentDirection == -1 and f_bullBreak(inversionConfirmation, currentTop, currentBottom)

        if bearishInversion or bullishInversion
            int newInverseDirection = bullishInversion ? 1 : -1

            if bullishInversion
                newBullIFVG := true

            if bearishInversion
                newBearIFVG := true

            color inverseColor = bullishInversion ? bullInverseColor : bearInverseColor
            string inverseText = showText ? (bullishInversion ? "BULL IFVG" : "BEAR IFVG") : ""
            bool inverseVisible = f_isVisibleIFVG(newInverseDirection)

            if showIFVG
                box.set_right(currentBox, f_boxRight())
                box.set_extend(currentBox, f_boxExtend())
                box.set_border_color(currentBox, inverseVisible ? color.new(inverseColor, ifvgBorderTransparency) : na)
                box.set_bgcolor(currentBox, inverseVisible ? color.new(inverseColor, ifvgFillTransparency) : na)
                box.set_text(currentBox, inverseVisible ? inverseText : "")
                box.set_text_color(currentBox, inverseColor)

                array.push(ifvgBoxes, currentBox)
                array.push(ifvgTops, currentTop)
                array.push(ifvgBottoms, currentBottom)
                array.push(ifvgDirections, newInverseDirection)
                array.push(ifvgCreatedBars, bar_index)
                array.push(ifvgTouched, false)
                array.push(ifvgMidTouched, false)
                array.push(ifvgMitigated, false)
            else
                box.delete(currentBox)

            array.remove(fvgBoxes, fvgIndex)
            array.remove(fvgTops, fvgIndex)
            array.remove(fvgBottoms, fvgIndex)
            array.remove(fvgDirections, fvgIndex)
            array.remove(fvgCreatedBars, fvgIndex)
            array.remove(fvgTouched, fvgIndex)
            array.remove(fvgMidTouched, fvgIndex)

        fvgIndex -= 1

    // ------------------------------------------------------------------------
    // LIMIT IFVG COUNT
    // ------------------------------------------------------------------------
    while array.size(ifvgBoxes) > ifvgZonesToShow
        box oldIFVG = array.shift(ifvgBoxes)

        if not na(oldIFVG)
            box.delete(oldIFVG)

        array.shift(ifvgTops)
        array.shift(ifvgBottoms)
        array.shift(ifvgDirections)
        array.shift(ifvgCreatedBars)
        array.shift(ifvgTouched)
        array.shift(ifvgMidTouched)
        array.shift(ifvgMitigated)

    // ------------------------------------------------------------------------
    // CREATE NEW FVG
    // ------------------------------------------------------------------------
    if bullFVG or bearFVG
        float gapTop = bullFVG ? low : low[2]
        float gapBottom = bullFVG ? high[2] : high
        int gapDirection = bullFVG ? 1 : -1
        color gapColor = bullFVG ? bullColor : bearColor
        string gapText = showText ? (bullFVG ? "BULL FVG" : "BEAR FVG") : ""
        bool gapVisible = f_isVisibleFVG(gapDirection)

        box newFVG = box.new(
             left=bar_index - 2,
             top=gapTop,
             right=f_boxRight(),
             bottom=gapBottom,
             xloc=xloc.bar_index,
             extend=f_boxExtend(),
             border_color=gapVisible ? color.new(gapColor, fvgBorderTransparency) : na,
             bgcolor=gapVisible ? color.new(gapColor, fvgFillTransparency) : na,
             text=gapVisible ? gapText : "",
             text_color=gapColor,
             text_size=size.tiny
         )

        array.push(fvgBoxes, newFVG)
        array.push(fvgTops, gapTop)
        array.push(fvgBottoms, gapBottom)
        array.push(fvgDirections, gapDirection)
        array.push(fvgCreatedBars, bar_index)
        array.push(fvgTouched, false)
        array.push(fvgMidTouched, false)

    // ------------------------------------------------------------------------
    // LIMIT FVG COUNT
    // ------------------------------------------------------------------------
    while array.size(fvgBoxes) > fvgZonesToShow
        box oldFVG = array.shift(fvgBoxes)

        if not na(oldFVG)
            box.delete(oldFVG)

        array.shift(fvgTops)
        array.shift(fvgBottoms)
        array.shift(fvgDirections)
        array.shift(fvgCreatedBars)
        array.shift(fvgTouched)
        array.shift(fvgMidTouched)

// ============================================================================
// STATUS PANEL
// ============================================================================
var table statusTable = table.new(f_panelPosition(panelPosition), 2, 4, border_width=1)

if barstate.islast
    if showStatusPanel
        table.cell(statusTable, 0, 0, "YETTY FVG PRO", text_color=color.white, bgcolor=color.new(color.purple, 35))
        table.cell(statusTable, 1, 0, timeframe.period, text_color=color.white, bgcolor=color.new(color.purple, 35))
        table.cell(statusTable, 0, 1, "Active FVGs", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(statusTable, 1, 1, str.tostring(array.size(fvgBoxes)), text_color=color.lime, bgcolor=color.new(color.black, 20))
        table.cell(statusTable, 0, 2, "Active IFVGs", text_color=color.white, bgcolor=color.new(color.black, 20))
        table.cell(statusTable, 1, 2, str.tostring(array.size(ifvgBoxes)), text_color=color.aqua, bgcolor=color.new(color.black, 20))
        table.cell(statusTable, 0, 3, "Filters", text_color=color.white, bgcolor=color.new(color.black, 20))

        string filterState = useDisplacementFilter or useVolumeFilter or useSessionFilter ? "ON" : "OFF"

        table.cell(
             statusTable,
             1,
             3,
             filterState,
             text_color=filterState == "ON" ? color.lime : color.gray,
             bgcolor=color.new(color.black, 20)
         )
    else
        table.clear(statusTable, 0, 0, 1, 3)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(
     showFVG and barstate.isconfirmed and bullFVG,
     "New Bullish FVG",
     "New confirmed bullish FVG on {{ticker}} / {{interval}}."
 )

alertcondition(
     showFVG and barstate.isconfirmed and bearFVG,
     "New Bearish FVG",
     "New confirmed bearish FVG on {{ticker}} / {{interval}}."
 )

alertcondition(
     showIFVG and newBullIFVG,
     "New Bullish IFVG",
     "New confirmed bullish IFVG on {{ticker}} / {{interval}}."
 )

alertcondition(
     showIFVG and newBearIFVG,
     "New Bearish IFVG",
     "New confirmed bearish IFVG on {{ticker}} / {{interval}}."
 )

alertcondition(
     alertFirstTouch and newFVGFirstTouch,
     "FVG First Touch",
     "Price touched an active FVG for the first time on {{ticker}} / {{interval}}."
 )

alertcondition(
     alertFirstTouch and newIFVGFirstTouch,
     "IFVG First Touch",
     "Price touched an active IFVG for the first time on {{ticker}} / {{interval}}."
 )

alertcondition(
     alertMidpointTouch and newFVGMidpointTouch,
     "FVG Midpoint Touch",
     "Price touched the midpoint of an active FVG on {{ticker}} / {{interval}}."
 )

alertcondition(
     alertMidpointTouch and newIFVGMidpointTouch,
     "IFVG Midpoint Touch",
     "Price touched the midpoint of an active IFVG on {{ticker}} / {{interval}}."
 )

alertcondition(
     alertMitigation and newBullIFVGMitigation,
     "Bullish IFVG Mitigated",
     "A bullish IFVG was mitigated on {{ticker}} / {{interval}}."
 )

alertcondition(
     alertMitigation and newBearIFVGMitigation,
     "Bearish IFVG Mitigated",
     "A bearish IFVG was mitigated on {{ticker}} / {{interval}}."
 )
````
