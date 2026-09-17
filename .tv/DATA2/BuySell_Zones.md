<!-- tradingview-pine-id: PUB;ddc39e78dc664e1699422a0e0d02f88b -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Buy/Sell Zones

Source: https://www.tradingview.com/script/lpPlDlAW-Buy-Sell-Zones/

## Description

Buy/Sell Zones 
Overview
Buy/Sell Zones is a market structure indicator designed to identify potential shifts in directional order flow through Change of Character (CHOCH) events.

When a confirmed swing level is broken in the opposite direction of the previous structural break, the indicator creates a new:

BUY ZONE after a bullish CHOCH.
SELL ZONE after a bearish CHOCH.
Each zone includes a structure-break line, a directional range box, an entry level, projected range targets, optional confirmation filters, deviation markers, alerts, and a reference-asset HUD.

The indicator is not designed to predict every market reversal. Its purpose is to provide a structured visual framework for analyzing transitions between bullish and bearish market conditions.

Market Structure Detection
Swing highs and lows are detected using a configurable fractal length.

The default Fractal Length is 12. A higher value produces fewer but more significant structural levels, while a lower value reacts more quickly to short-term price action.

A structure break can be confirmed in two ways:

Close Beyond Level: The candle must close beyond the swing level.
Wick Beyond Level: The candle only needs to trade beyond the swing level.
Requiring a candle close generally produces fewer and more conservative signals.

CHOCH Logic
The indicator tracks the direction of the most recent structural break.

A bullish break following a bearish structural state creates a BUY ZONE.
A bearish break following a bullish structural state creates a SELL ZONE.
Repeated breaks in the same direction update the structural state but do not automatically create another CHOCH zone.

BUY and SELL Zone Boxes
The directional boxes are designed to display the complete price range between the originating structure level and the candle that breaks it.

BUY ZONE Box
For a bullish structure break:

The left edge begins at the pivot-high candle.
The right edge ends after the candle that breaks the pivot high.
The upper boundary is the broken pivot-high level.
The lower boundary is the lowest wick formed between the pivot and the breakout candle.
The box uses the bullish color scheme.
SELL ZONE Box
For a bearish structure break:

The left edge begins at the pivot-low candle.
The right edge ends after the candle that breaks the pivot low.
The lower boundary is the broken pivot-low level.
The upper boundary is the highest wick formed between the pivot and the breakdown candle.
The box uses the bearish color scheme.
The box borders use a dotted style to keep the zones visible without making the chart excessively heavy.

Structure Lines and Zone Labels
Every accepted zone includes a directional line connecting the originating pivot to the structure-breaking candle.

BUY ZONE: Green structure line with the label positioned above it.
SELL ZONE: Red structure line with the label positioned below it.
The label is placed near the time-based midpoint of the structure line.

The Zone Label Distance (ATR) setting controls the vertical distance between the label and the line. Because the distance is normalized with ATR, the label placement adapts to different assets, prices, and volatility conditions.

Entry Level
The midpoint of the CHOCH signal candle’s range is treated as a potential entry reference.

Bullish CHOCH midpoint: LONG ENTRY LEVEL
Bearish CHOCH midpoint: SHORT ENTRY LEVEL
This is a reference level rather than an automatic trade signal. Traders may combine it with retests, lower-timeframe confirmation, volume behavior, candle structure, or their own risk-management model.

Range Projection Levels
The signal candle’s full high-to-low range is used as the projection unit.

The indicator initially displays:

+0.5
+1
+1.5
+2
+3
+4
-0.5
-1
-1.5
-2
-3
-4
These levels can be used as potential reaction areas, expansion targets, profit-management references, or invalidation zones.

Automatic Long-Trend Expansion
To support extended directional moves, additional levels are activated automatically:

When price trades above +4, the indicator reveals +5, +6, +7, and +8.
When price trades below -4, the indicator reveals -5, -6, -7, and -8.
The additional levels remain hidden until the corresponding +4 or -4 boundary is crossed.

Optional Filters
All filters are optional and can be enabled independently.

VWAP Direction Filter

https://www.tradingview.com/x/XJm5oD51/

When enabled:

BUY ZONE creation requires price to close above the session VWAP.
SELL ZONE creation requires price to close below the session VWAP.
The VWAP line can be displayed separately.

EMA Trend Filter
The EMA filter is disabled by default, with a default length of 20.

https://www.tradingview.com/x/uzVauNey/

When enabled:

BUY ZONE creation requires price to be above the EMA.
SELL ZONE creation requires price to be below the EMA.
Relative Volume Filter
This filter compares current volume with average volume.

A zone is rejected when current volume is below the selected multiple of its moving average.

This can help remove structure breaks that occur during relatively weak participation. It may be less useful on instruments that do not provide reliable centralized volume data.

ATR Zone-Size Filter
The signal candle’s range is normalized against ATR.

Zones can be rejected when their signal candles are:

Too small relative to current volatility.
Excessively large relative to current volatility.
This helps prevent unusually narrow or highly extended candles from generating unwanted zones.

Confirmed-Bar Filter
When enabled, a zone is created only after the structure-breaking candle has closed.

This reduces intrabar signal changes and is particularly useful for alerts.

Minimum Bars Between Zones
A configurable cooldown can be applied between accepted CHOCH zones.

This is useful for reducing clustered signals during sideways or highly volatile conditions.

Return-to-Range Detection
The indicator can monitor price movement beyond the outer +4 and -4 boundaries.

If price trades above +4 and later closes back inside the active range, a bearish return-to-range event is detected.
If price trades below -4 and later closes back inside the active range, a bullish return-to-range event is detected.
The visual marker is disabled by default and can be enabled from the Deviation Marker settings.

Return-to-range detection does not automatically imply a reversal. It identifies a possible failed expansion or deviation that may require additional confirmation.

Reference Asset Zone HUD
The indicator includes a configurable HUD that tracks the latest structural zone of another asset on the current chart timeframe.

The HUD displays:

Selected reference asset.
Reference asset’s current BUY or SELL zone.
Mapped signal for the chart.
Current timeframe.
Direct or inverse mapping mode.
The HUD size can be set to:

Tiny
Small
Normal
Large
The default size is Normal.

Why Is USDT Dominance the Default Reference?
The default reference symbol is:

CRYPTOCAP:USDT.D

USDT Dominance represents the percentage of the total cryptocurrency market capitalization held in Tether.

It is commonly monitored as a broad crypto risk-flow reference:

Rising USDT.D can indicate that capital is moving toward stablecoins and away from risk assets.
Falling USDT.D can indicate that capital is rotating from stablecoins into cryptocurrencies.
For this reason, the HUD uses inverse mapping by default:

USDT.D BUY ZONE → Chart SELL ZONE
USDT.D SELL ZONE → Chart BUY ZONE
For example, when analyzing BTC, ETH, or another cryptocurrency, a bullish structural state in USDT.D may represent defensive capital flow and therefore map to a bearish signal for the crypto chart.

This relationship is not constant and can weaken or temporarily reverse. The reference HUD should be used as contextual confirmation rather than as an independent entry system.

Reference Ideas for Other Markets
Any TradingView-supported symbol can be selected as the HUD reference asset.

Gold Traders
Gold traders may consider monitoring:

TVC:DXY — U.S. Dollar Index
TVC:US10Y — U.S. 10-Year Treasury Yield
A directly related gold instrument or futures contract
Gold frequently has an inverse relationship with the U.S. dollar. Therefore, traders using DXY as the reference may prefer inverse mapping:

DXY BUY ZONE → Gold SELL bias
DXY SELL ZONE → Gold BUY bias
Treasury yields can also affect gold, but the relationship may change depending on inflation expectations, real yields, monetary policy, and risk sentiment.

Nasdaq Traders
Nasdaq traders may consider:

CBOE:VIX — Volatility Index
TVC:US10Y — U.S. 10-Year Treasury Yield
TVC:DXY — U.S. Dollar Index
NASDAQ:QQQ or a related Nasdaq futures symbol for direct confirmation
The VIX is generally used with inverse mapping:

VIX BUY ZONE → Nasdaq SELL bias
VIX SELL ZONE → Nasdaq BUY bias
Higher Treasury yields can pressure growth and technology stocks, but this relationship is regime-dependent. DXY may also influence risk assets and multinational technology companies, although it should not be treated as a fixed inverse signal.

When using a positively correlated reference asset, disable Invert Reference Signal to use direct mapping.

Alerts
The indicator provides three optional alert conditions:

BUY Zone Created
Triggered when a new BUY ZONE passes all enabled filters and is created.

SELL Zone Created
Triggered when a new SELL ZONE passes all enabled filters and is created.

Price Returning to Range
Triggered when price trades beyond +4 or -4 and subsequently closes back inside the active range.

Each alert can be enabled or disabled independently from the indicator settings.

After enabling an alert option, create the corresponding alert through TradingView’s alert dialog. Using Once Per Bar Close is recommended when confirmed signals are preferred.

Important Usage Notes
Pivot-based market structure requires future bars to confirm a swing. Signals are therefore intentionally delayed by the selected pivot strength.
Confirmed historical pivots do not change after confirmation.
Break conditions can change during a live candle when the confirmed-bar filter is disabled.
The reference HUD uses the chart timeframe.
Relationships between markets are dynamic and may change across volatility, liquidity, macroeconomic, and monetary-policy regimes.
Enabling multiple strict filters can significantly reduce the number of zones.
The indicator does not calculate position size, stop loss, risk-to-reward, commission, slippage, or portfolio exposure.
Disclaimer
This indicator is provided for informational and educational purposes only. It does not constitute financial, investment, trading, or legal advice and should not be interpreted as a recommendation to buy or sell any asset. Market structure signals, projected levels, reference-asset relationships, and inverse correlations can fail or change without warning. Historical performance and visual examples do not guarantee future results. Always perform your own research, confirm signals independently, use appropriate risk management, and consult a qualified financial professional before making trading or investment decisions. The user assumes full responsibility for all trading decisions, profits, and losses.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("Buy/Sell Zones", shorttitle = "Buy/Sell Zones", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 200)

// --- Core ---
string CORE_GROUP = "Core"
int lengthInput = input.int(12, "Fractal Length", minval = 3, maxval = 501, group = CORE_GROUP, tooltip = "Window length used to derive the symmetric pivot strength. Default is 12.")
int barsToRightInput = input.int(10, "Bars to Right", minval = 1, maxval = 300, group = CORE_GROUP, tooltip = "Number of chart bars used to project the active CHOCH levels to the right.")
bool requireBodyInput = input.bool(true, "Break = Close Beyond Level", group = CORE_GROUP, tooltip = "When enabled, a close must break the pivot. When disabled, a wick can break it.")

// --- Optional Filters ---
string FILTERS_GROUP = "Optional Filters"
bool useVwapFilterInput = input.bool(false, "Use VWAP Direction Filter", group = FILTERS_GROUP, tooltip = "Bullish CHOCH zones require a close above session VWAP; bearish zones require a close below it. Disabled by default.")
bool showVwapInput = input.bool(false, "Show VWAP", group = FILTERS_GROUP, tooltip = "Displays the session VWAP used by the optional direction filter.")
bool useEmaFilterInput = input.bool(false, "Use EMA Trend Filter", group = FILTERS_GROUP, tooltip = "Bullish CHOCH zones require a close above the EMA; bearish zones require a close below it.")
int emaLengthInput = input.int(200, "EMA Length", minval = 1, group = FILTERS_GROUP, tooltip = "Length of the EMA used by the optional trend filter.")
bool showEmaInput = input.bool(false, "Show EMA", group = FILTERS_GROUP, tooltip = "Displays the EMA used by the optional trend filter.")
bool useVolumeFilterInput = input.bool(false, "Use Relative Volume Filter", group = FILTERS_GROUP, tooltip = "Skips a CHOCH zone if current volume is below average volume multiplied by the selected factor.")
int volumeLengthInput = input.int(20, "Volume Average Length", minval = 1, group = FILTERS_GROUP, tooltip = "Lookback used to calculate average volume.")
float volumeMultiplierInput = input.float(1.0, "Minimum Relative Volume", minval = 0.0, step = 0.1, group = FILTERS_GROUP, tooltip = "Current volume must be at least average volume multiplied by this value.")
bool useAtrRangeFilterInput = input.bool(false, "Use ATR Zone-Size Filter", group = FILTERS_GROUP, tooltip = "Skips CHOCH zones whose signal-candle range is too small or too large relative to ATR.")
int atrLengthInput = input.int(14, "ATR Length", minval = 1, group = FILTERS_GROUP, tooltip = "Length of the ATR used to normalize the signal-candle range.")
float minAtrRangeInput = input.float(0.5, "Minimum Range in ATR", minval = 0.0, step = 0.1, group = FILTERS_GROUP, tooltip = "Minimum accepted signal-candle range expressed as an ATR multiple.")
float maxAtrRangeInput = input.float(3.0, "Maximum Range in ATR", minval = 0.1, step = 0.1, group = FILTERS_GROUP, tooltip = "Maximum accepted signal-candle range expressed as an ATR multiple.")
bool requireConfirmedInput = input.bool(false, "Require Confirmed Bar", group = FILTERS_GROUP, tooltip = "Creates a CHOCH zone only after the signal bar closes. Useful for preventing intrabar signals.")
int minimumBarsInput = input.int(0, "Minimum Bars Between CHOCH Zones", minval = 0, maxval = 5000, group = FILTERS_GROUP, tooltip = "Skips new CHOCH zones until this many bars have elapsed since the last accepted zone. Zero disables the filter.")

// --- Asset Zone HUD ---
string HUD_GROUP = "Asset Zone HUD"
bool showHudInput = input.bool(true, "Show Asset Zone HUD", group = HUD_GROUP, tooltip = "Displays the latest structural zone of the selected asset and its mapped signal for the chart.")
string hudAssetInput = input.symbol("CRYPTOCAP:USDT.D", "Reference Asset", group = HUD_GROUP, tooltip = "Asset whose latest BUY/SELL zone will be monitored on the chart timeframe.")
string hudSizeInput = input.string("normal", "HUD Size", options = ["tiny", "small", "normal", "large"], group = HUD_GROUP, tooltip = "Controls the text size of the Asset Zone HUD. Default is normal.")

// --- Performance ---
string PERFORMANCE_GROUP = "Performance"
int MAX_SAFE_ZONE_SETS = 19
int calcLastBarsInput = input.int(20000, "Calc Only Last N Bars (0=all)", minval = 0, maxval = 50000, group = PERFORMANCE_GROUP, tooltip = "Restricts object-creation logic to the latest N bars. Zero processes all loaded bars.")
int chochShowLastInput = input.int(1, "CHOCH Show Last N Zones (0=safe max)", minval = 0, maxval = MAX_SAFE_ZONE_SETS, group = PERFORMANCE_GROUP, tooltip = "Limits retained CHOCH sets to prevent TradingView drawing-limit failures. Zero uses the safe maximum of 19 zones.")

// --- CHOCH Levels ---
string CHOCH_GROUP = "CHOCH Levels"
color chochLineUpInput = input.color(#089981, "CHOCH Lines UP Color", group = CHOCH_GROUP, tooltip = "Color of bullish CHOCH levels.")
color chochLineDownInput = input.color(#f23645, "CHOCH Lines DN Color", group = CHOCH_GROUP, tooltip = "Color of bearish CHOCH levels.")
int chochHighLowWidthInput = input.int(2, "CHOCH H/L Width", minval = 1, maxval = 5, group = CHOCH_GROUP, tooltip = "Width of the signal candle's high and low levels.")
int chochStepWidthInput = input.int(1, "CHOCH Step Width (+/- levels)", minval = 1, maxval = 5, group = CHOCH_GROUP, tooltip = "Width of the projected range-multiple levels.")
string chochStyleInput = input.string("Dotted", "CHOCH Level Style", options = ["Solid", "Dashed", "Dotted"], group = CHOCH_GROUP, tooltip = "Line style used by the projected range-multiple levels.")
color boxFillUpInput = input.color(color.new(#089981, 88), "CHOCH Box Fill UP", group = CHOCH_GROUP, tooltip = "Fill color of bullish CHOCH signal-candle zones.")
color boxFillDownInput = input.color(color.new(#f23645, 88), "CHOCH Box Fill DN", group = CHOCH_GROUP, tooltip = "Fill color of bearish CHOCH signal-candle zones.")
color boxBorderUpInput = input.color(#089981, "CHOCH Box Border UP", group = CHOCH_GROUP, tooltip = "Border color of bullish CHOCH zones.")
color boxBorderDownInput = input.color(#f23645, "CHOCH Box Border DN", group = CHOCH_GROUP, tooltip = "Border color of bearish CHOCH zones.")
bool showLevelLabelsInput = input.bool(true, "Show Level Labels (right side)", group = CHOCH_GROUP, tooltip = "Displays H, L, EQ, and range-multiple labels at the right edge.")
color levelLabelTextInput = input.color(#d1d4dc, "Level Label Text Color", group = CHOCH_GROUP, tooltip = "Text color used by the right-side level labels.")
string labelSizeInput = input.string("normal", "Label Size", options = ["tiny", "small", "normal"], group = CHOCH_GROUP, tooltip = "Size of CHOCH zone and level labels.")
float zoneLabelAtrGapInput = input.float(0.35, "Zone Label Distance (ATR)", minval = 0.05, maxval = 5.0, step = 0.05, group = CHOCH_GROUP, tooltip = "Direct ATR multiplier used for the vertical distance between the broken structure line and the BUY/SELL ZONE label. Every change now directly moves the label.")

// --- Deviation Marker ---
string DEVIATION_GROUP = "Deviation Marker"
bool showDeviationInput = input.bool(false, "Mark Candle Returning into Range", group = DEVIATION_GROUP, tooltip = "Marks the first close returning inside the -4 to +4 range after price traded beyond it. Disabled by default.")
color deviationUpInput = input.color(#089981, "Deviation UP Color", group = DEVIATION_GROUP, tooltip = "Color of bullish return-to-range markers.")
color deviationDownInput = input.color(#f23645, "Deviation DN Color", group = DEVIATION_GROUP, tooltip = "Color of bearish return-to-range markers.")

// --- Alerts ---
string ALERTS_GROUP = "Alerts"
bool buyZoneAlertInput = input.bool(false, "Include BUY in Combined Alert", group = ALERTS_GROUP, tooltip = "Optional: includes BUY ZONE events when using TradingView's Any alert() function call condition. The separate named BUY Zone Created condition works without this toggle.")
bool sellZoneAlertInput = input.bool(false, "Include SELL in Combined Alert", group = ALERTS_GROUP, tooltip = "Optional: includes SELL ZONE events when using TradingView's Any alert() function call condition. The separate named SELL Zone Created condition works without this toggle.")
bool returnToRangeAlertInput = input.bool(false, "Include Return-to-Range in Combined Alert", group = ALERTS_GROUP, tooltip = "Optional: includes return-to-range events when using TradingView's Any alert() function call condition. The separate named Price Returning to Range condition works without this toggle.")

// --- Helpers ---
f_lineStyle(string styleText) =>
    styleText == "Solid" ? line.style_solid : styleText == "Dashed" ? line.style_dashed : line.style_dotted

f_labelSize(string sizeText) =>
    sizeText == "tiny" ? size.tiny : sizeText == "small" ? size.small : sizeText == "large" ? size.large : size.normal

f_levelLabel(int x, float y, string labelText, labelSize, bool prominent) =>
    label.new(x, y, labelText, xloc = xloc.bar_time, style = label.style_label_left, textcolor = color.new(levelLabelTextInput, prominent ? 0 : 50), color = #00000000, size = labelSize)

var line[] activeLines = array.new_line()
var label[] activeLabels = array.new_label()
var line[] storedLines = array.new_line()
var label[] storedLabels = array.new_label()
var box[] storedBoxes = array.new_box()
var int[] storedLineCounts = array.new_int()
var int[] storedLabelCounts = array.new_int()
var float pendingBrokenLevel = na
var int pendingStructureStartTime = na
var float pendingZoneLabelGap = na
var float pendingRangeBoxTop = na
var float pendingRangeBoxBottom = na

f_addLevel(line[] linesArray, label[] labelsArray, int leftTime, int rightTime, float level, string labelText, color lineColor, string lineStyle, int lineWidth, labelSize, bool prominent) =>
    line levelLine = line.new(leftTime, level, rightTime, level, xloc = xloc.bar_time, color = lineColor, style = lineStyle, width = lineWidth)
    array.push(linesArray, levelLine)
    label levelLabel = na
    if showLevelLabelsInput
        levelLabel := f_levelLabel(rightTime, level, labelText, labelSize, prominent)
    array.push(labelsArray, levelLabel)

f_trimStoredSets() =>
    int effectiveZoneLimit = chochShowLastInput == 0 ? MAX_SAFE_ZONE_SETS : math.min(chochShowLastInput, MAX_SAFE_ZONE_SETS)
    while array.size(storedBoxes) > effectiveZoneLimit
        box oldBox = array.shift(storedBoxes)
        if not na(oldBox)
            box.delete(oldBox)
        int lineCount = array.shift(storedLineCounts)
        if lineCount > 0
            for index = 0 to lineCount - 1
                line oldLine = array.shift(storedLines)
                if not na(oldLine)
                    line.delete(oldLine)
        int labelCount = array.shift(storedLabelCounts)
        if labelCount > 0
            for index = 0 to labelCount - 1
                label oldLabel = array.shift(storedLabels)
                if not na(oldLabel)
                    label.delete(oldLabel)

f_storeActiveSet(box zoneBox) =>
    int lineCount = array.size(activeLines)
    int labelCount = array.size(activeLabels)
    if lineCount > 0
        for index = 0 to lineCount - 1
            array.push(storedLines, array.get(activeLines, index))
    if labelCount > 0
        for index = 0 to labelCount - 1
            array.push(storedLabels, array.get(activeLabels, index))
    array.push(storedBoxes, zoneBox)
    array.push(storedLineCounts, lineCount)
    array.push(storedLabelCounts, labelCount)
    f_trimStoredSets()

f_freezeActive(int freezeTime) =>
    int lineCount = math.min(23, array.size(activeLines))
    if lineCount > 0
        for index = 0 to lineCount - 1
            line activeLine = array.get(activeLines, index)
            if not na(activeLine)
                line.set_x2(activeLine, freezeTime)
    int levelLabelCount = math.min(23, array.size(activeLabels))
    if levelLabelCount > 0
        for index = 0 to levelLabelCount - 1
            label activeLabel = array.get(activeLabels, index)
            if not na(activeLabel)
                label.set_x(activeLabel, freezeTime)

f_hideActiveLevel(int index) =>
    if array.size(activeLines) > index
        line levelLine = array.get(activeLines, index)
        if not na(levelLine)
            line.set_color(levelLine, na)
    if array.size(activeLabels) > index
        label levelLabel = array.get(activeLabels, index)
        if not na(levelLabel)
            label.set_textcolor(levelLabel, na)

f_showExtendedLevels(int firstIndex, int lastIndex, color directionColor) =>
    for index = firstIndex to lastIndex
        if array.size(activeLines) > index
            line extendedLine = array.get(activeLines, index)
            if not na(extendedLine)
                line.set_color(extendedLine, color.new(directionColor, 50))
        if array.size(activeLabels) > index
            label extendedLabel = array.get(activeLabels, index)
            if not na(extendedLabel)
                label.set_textcolor(extendedLabel, color.new(levelLabelTextInput, 50))

f_createChochSet(int direction, float zoneHigh, float zoneLow, int extensionMilliseconds, int oneBarMilliseconds) =>
    array.clear(activeLines)
    array.clear(activeLabels)

    float zoneRange = math.max(syminfo.mintick, zoneHigh - zoneLow)
    float equilibrium = zoneHigh - zoneRange * 0.5
    int leftTime = time
    int rightTime = time + extensionMilliseconds
    color directionColor = direction == 1 ? chochLineUpInput : chochLineDownInput
    color stepColor = color.new(directionColor, 50)
    lineStyle = f_lineStyle(chochStyleInput)
    labelSize = f_labelSize(labelSizeInput)

    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh, "H", directionColor, line.style_solid, chochHighLowWidthInput, labelSize, true)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow, "L", directionColor, line.style_solid, chochHighLowWidthInput, labelSize, true)
    string entryText = direction == 1 ? "LONG ENTRY LEVEL" : "SHORT ENTRY LEVEL"
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, equilibrium, entryText, directionColor, line.style_dashed, 2, labelSize, true)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 0.5, "+0.5", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange, "+1", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 1.5, "+1.5", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 2.0, "+2", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 3.0, "+3", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 4.0, "+4", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 0.5, "-0.5", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange, "-1", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 1.5, "-1.5", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 2.0, "-2", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 3.0, "-3", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 4.0, "-4", stepColor, lineStyle, chochStepWidthInput, labelSize, false)

    // Extended trend levels are created hidden and revealed only after price crosses +/-4.
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 5.0, "+5", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 6.0, "+6", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 7.0, "+7", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneHigh + zoneRange * 8.0, "+8", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 5.0, "-5", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 6.0, "-6", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 7.0, "-7", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    f_addLevel(activeLines, activeLabels, leftTime, rightTime, zoneLow - zoneRange * 8.0, "-8", stepColor, lineStyle, chochStepWidthInput, labelSize, false)
    for hiddenIndex = 15 to 22
        f_hideActiveLevel(hiddenIndex)

    int safeStructureStart = na(pendingStructureStartTime) ? leftTime : pendingStructureStartTime
    float safeBrokenLevel = na(pendingBrokenLevel) ? equilibrium : pendingBrokenLevel
    int structureMiddleTime = safeStructureStart + int((leftTime - safeStructureStart) / 2)
    line structureLine = line.new(safeStructureStart, safeBrokenLevel, leftTime, safeBrokenLevel, xloc = xloc.bar_time, color = directionColor, style = line.style_solid, width = 2)
    array.push(activeLines, structureLine)

    float labelGap = math.max(nz(pendingZoneLabelGap, zoneRange * 0.50), syminfo.mintick * 20.0)
    float zoneLabelY = direction == 1 ? safeBrokenLevel + labelGap : safeBrokenLevel - labelGap
    string zoneText = direction == 1 ? "BUY ZONE" : "SELL ZONE"
    zoneLabelStyle = direction == 1 ? label.style_label_down : label.style_label_up
    label zoneLabel = label.new(structureMiddleTime, zoneLabelY, zoneText, xloc = xloc.bar_time, style = zoneLabelStyle, textcolor = directionColor, color = color.new(chart.bg_color, 5), size = labelSize, textalign = text.align_center)
    array.push(activeLabels, zoneLabel)

    color borderColor = direction == 1 ? boxBorderUpInput : boxBorderDownInput
    color fillColor = direction == 1 ? boxFillUpInput : boxFillDownInput
    float rawRangeTop = nz(pendingRangeBoxTop, zoneHigh)
    float rawRangeBottom = nz(pendingRangeBoxBottom, zoneLow)
    float rangeBoxTop = math.max(rawRangeTop, rawRangeBottom)
    float rangeBoxBottom = math.min(rawRangeTop, rawRangeBottom)
    box zoneBox = box.new(safeStructureStart, rangeBoxTop, leftTime + oneBarMilliseconds, rangeBoxBottom, xloc = xloc.bar_time, border_color = borderColor, bgcolor = fillColor, border_width = 1, border_style = line.style_dotted)
    f_storeActiveSet(zoneBox)

f_referenceZoneState(int strength) =>
    float referencePivotHigh = ta.pivothigh(high, strength, strength)
    float referencePivotLow = ta.pivotlow(low, strength, strength)
    float referenceVwap = ta.vwap(hlc3)
    float referenceEma = ta.ema(close, emaLengthInput)
    float referenceAverageVolume = ta.sma(volume, volumeLengthInput)
    float referenceAtr = ta.atr(atrLengthInput)

    var float referenceUpLevel = na
    var float referenceDownLevel = na
    var bool referenceUpBroken = false
    var bool referenceDownBroken = false
    var int referenceBreakDirection = 0
    var int referenceZoneDirection = 0
    var int referenceLastZoneBar = na

    if not na(referencePivotHigh)
        referenceUpLevel := referencePivotHigh
        referenceUpBroken := false
    if not na(referencePivotLow)
        referenceDownLevel := referencePivotLow
        referenceDownBroken := false

    bool referenceBreakUp = not na(referenceUpLevel) and not referenceUpBroken and (requireBodyInput ? close > referenceUpLevel : high > referenceUpLevel)
    bool referenceBreakDown = not na(referenceDownLevel) and not referenceDownBroken and (requireBodyInput ? close < referenceDownLevel : low < referenceDownLevel)
    bool referenceVolumePass = not useVolumeFilterInput or not na(volume) and not na(referenceAverageVolume) and volume >= referenceAverageVolume * volumeMultiplierInput
    float referenceMinAtr = math.min(minAtrRangeInput, maxAtrRangeInput)
    float referenceMaxAtr = math.max(minAtrRangeInput, maxAtrRangeInput)
    bool referenceAtrPass = not useAtrRangeFilterInput or not na(referenceAtr) and high - low >= referenceAtr * referenceMinAtr and high - low <= referenceAtr * referenceMaxAtr
    bool referenceConfirmedPass = not requireConfirmedInput or barstate.isconfirmed
    bool referenceBullPass = (not useVwapFilterInput or not na(referenceVwap) and close > referenceVwap) and (not useEmaFilterInput or not na(referenceEma) and close > referenceEma)
    bool referenceBearPass = (not useVwapFilterInput or not na(referenceVwap) and close < referenceVwap) and (not useEmaFilterInput or not na(referenceEma) and close < referenceEma)

    if referenceBreakUp
        bool referenceCooldownPass = minimumBarsInput == 0 or na(referenceLastZoneBar) or bar_index - referenceLastZoneBar >= minimumBarsInput
        bool referenceIsBullishChoch = referenceBreakDirection == -1
        referenceUpBroken := true
        if referenceIsBullishChoch and referenceVolumePass and referenceAtrPass and referenceConfirmedPass and referenceBullPass and referenceCooldownPass
            referenceZoneDirection := 1
            referenceLastZoneBar := bar_index
        referenceBreakDirection := 1

    if referenceBreakDown
        bool referenceCooldownPass = minimumBarsInput == 0 or na(referenceLastZoneBar) or bar_index - referenceLastZoneBar >= minimumBarsInput
        bool referenceIsBearishChoch = referenceBreakDirection == 1
        referenceDownBroken := true
        if referenceIsBearishChoch and referenceVolumePass and referenceAtrPass and referenceConfirmedPass and referenceBearPass and referenceCooldownPass
            referenceZoneDirection := -1
            referenceLastZoneBar := bar_index
        referenceBreakDirection := -1

    referenceZoneDirection

// --- Core Calculations ---
bool inCalculationWindow = calcLastBarsInput == 0 or bar_index >= last_bar_index - calcLastBarsInput
int oddLength = lengthInput % 2 == 0 ? lengthInput + 1 : lengthInput
int pivotStrength = int(oddLength / 2)
int timeframeSeconds = timeframe.in_seconds(timeframe.period)
int extensionMilliseconds = timeframeSeconds * 1000 * barsToRightInput
int oneBarMilliseconds = timeframeSeconds * 1000

float pivotHighValue = ta.pivothigh(high, pivotStrength, pivotStrength)
float pivotLowValue = ta.pivotlow(low, pivotStrength, pivotStrength)
float pivotWindowLow = ta.lowest(low, pivotStrength + 1)
float pivotWindowHigh = ta.highest(high, pivotStrength + 1)
float vwapValue = ta.vwap(hlc3)
float emaValue = ta.ema(close, emaLengthInput)
float averageVolume = ta.sma(volume, volumeLengthInput)
float atrValue = ta.atr(atrLengthInput)
int referenceZoneState = request.security(hudAssetInput, timeframe.period, f_referenceZoneState(pivotStrength), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

bool volumeFilterPass = not useVolumeFilterInput or not na(volume) and not na(averageVolume) and volume >= averageVolume * volumeMultiplierInput
float lowerAtrMultiple = math.min(minAtrRangeInput, maxAtrRangeInput)
float upperAtrMultiple = math.max(minAtrRangeInput, maxAtrRangeInput)
float signalRange = high - low
bool atrRangeFilterPass = not useAtrRangeFilterInput or not na(atrValue) and signalRange >= atrValue * lowerAtrMultiple and signalRange <= atrValue * upperAtrMultiple
bool confirmedFilterPass = not requireConfirmedInput or barstate.isconfirmed
bool commonFilterPass = volumeFilterPass and atrRangeFilterPass and confirmedFilterPass
bool bullishDirectionPass = not useVwapFilterInput or not na(vwapValue) and close > vwapValue
bullishDirectionPass := bullishDirectionPass and (not useEmaFilterInput or not na(emaValue) and close > emaValue)
bool bearishDirectionPass = not useVwapFilterInput or not na(vwapValue) and close < vwapValue
bearishDirectionPass := bearishDirectionPass and (not useEmaFilterInput or not na(emaValue) and close < emaValue)

// --- Candidate State ---
var float bullishBreakLevel = na
var int bullishLevelStartTime = na
var float bullishRangeLow = na
var bool bullishLevelBroken = false
var float bearishBreakLevel = na
var int bearishLevelStartTime = na
var float bearishRangeHigh = na
var bool bearishLevelBroken = false
var int lastBreakDirection = 0
var bool chochActive = false
var int activeChochDirection = 0
var float currentChochHigh = na
var float currentChochLow = na
var float currentChochRange = na
var int lastAcceptedChochBar = na
var bool outOfRangeUp = false
var bool outOfRangeDown = false
var bool upperExtensionShown = false
var bool lowerExtensionShown = false

// --- Candidate Updates and Level Pruning ---
if inCalculationWindow
    if not na(pivotHighValue)
        bullishBreakLevel := pivotHighValue
        bullishLevelStartTime := time[pivotStrength]
        bullishRangeLow := pivotWindowLow
        bullishLevelBroken := false
        if chochActive and activeChochDirection == -1
            if bullishBreakLevel <= currentChochHigh + currentChochRange * 4.0
                f_hideActiveLevel(8)
            if bullishBreakLevel <= currentChochHigh + currentChochRange * 3.0
                f_hideActiveLevel(7)
            if bullishBreakLevel <= currentChochHigh + currentChochRange * 2.0
                f_hideActiveLevel(6)
            if bullishBreakLevel <= currentChochHigh + currentChochRange * 1.5
                f_hideActiveLevel(5)
            if bullishBreakLevel <= currentChochHigh + currentChochRange
                f_hideActiveLevel(4)
            if bullishBreakLevel <= currentChochHigh + currentChochRange * 0.5
                f_hideActiveLevel(3)

    if not na(pivotLowValue)
        bearishBreakLevel := pivotLowValue
        bearishLevelStartTime := time[pivotStrength]
        bearishRangeHigh := pivotWindowHigh
        bearishLevelBroken := false
        if chochActive and activeChochDirection == 1
            if bearishBreakLevel >= currentChochLow - currentChochRange * 4.0
                f_hideActiveLevel(14)
            if bearishBreakLevel >= currentChochLow - currentChochRange * 3.0
                f_hideActiveLevel(13)
            if bearishBreakLevel >= currentChochLow - currentChochRange * 2.0
                f_hideActiveLevel(12)
            if bearishBreakLevel >= currentChochLow - currentChochRange * 1.5
                f_hideActiveLevel(11)
            if bearishBreakLevel >= currentChochLow - currentChochRange
                f_hideActiveLevel(10)
            if bearishBreakLevel >= currentChochLow - currentChochRange * 0.5
                f_hideActiveLevel(9)

// Keep the full pivot-to-break range updated for directional zone boxes.
if inCalculationWindow
    if not na(bullishBreakLevel) and not bullishLevelBroken
        bullishRangeLow := math.min(nz(bullishRangeLow, low), low)
    if not na(bearishBreakLevel) and not bearishLevelBroken
        bearishRangeHigh := math.max(nz(bearishRangeHigh, high), high)

// --- Break Detection ---
bool bullishBreak = inCalculationWindow and not na(bullishBreakLevel) and not bullishLevelBroken and (requireBodyInput ? close > bullishBreakLevel : high > bullishBreakLevel)
bool bearishBreak = inCalculationWindow and not na(bearishBreakLevel) and not bearishLevelBroken and (requireBodyInput ? close < bearishBreakLevel : low < bearishBreakLevel)

// --- Apply Breaks ---
bool buyZoneCreatedSignal = false
bool sellZoneCreatedSignal = false

if bullishBreak
    bool isBullishChoch = lastBreakDirection == -1
    bullishLevelBroken := true
    bool cooldownPass = minimumBarsInput == 0 or na(lastAcceptedChochBar) or bar_index - lastAcceptedChochBar >= minimumBarsInput
    if isBullishChoch and commonFilterPass and bullishDirectionPass and cooldownPass
        if chochActive
            f_freezeActive(time)
        currentChochHigh := high
        currentChochLow := low
        currentChochRange := math.max(syminfo.mintick, high - low)
        pendingBrokenLevel := bullishBreakLevel
        pendingStructureStartTime := bullishLevelStartTime
        pendingZoneLabelGap := math.max(syminfo.mintick * 20.0, nz(atrValue, currentChochRange) * zoneLabelAtrGapInput)
        pendingRangeBoxTop := bullishBreakLevel
        pendingRangeBoxBottom := math.min(nz(bullishRangeLow, low), low)
        f_createChochSet(1, currentChochHigh, currentChochLow, extensionMilliseconds, oneBarMilliseconds)
        buyZoneCreatedSignal := true
        chochActive := true
        activeChochDirection := 1
        lastAcceptedChochBar := bar_index
        outOfRangeUp := false
        outOfRangeDown := false
        upperExtensionShown := false
        lowerExtensionShown := false
    lastBreakDirection := 1

if bearishBreak
    bool isBearishChoch = lastBreakDirection == 1
    bearishLevelBroken := true
    bool cooldownPass = minimumBarsInput == 0 or na(lastAcceptedChochBar) or bar_index - lastAcceptedChochBar >= minimumBarsInput
    if isBearishChoch and commonFilterPass and bearishDirectionPass and cooldownPass
        if chochActive
            f_freezeActive(time)
        currentChochHigh := high
        currentChochLow := low
        currentChochRange := math.max(syminfo.mintick, high - low)
        pendingBrokenLevel := bearishBreakLevel
        pendingStructureStartTime := bearishLevelStartTime
        pendingZoneLabelGap := math.max(syminfo.mintick * 20.0, nz(atrValue, currentChochRange) * zoneLabelAtrGapInput)
        pendingRangeBoxTop := math.max(nz(bearishRangeHigh, high), high)
        pendingRangeBoxBottom := bearishBreakLevel
        f_createChochSet(-1, currentChochHigh, currentChochLow, extensionMilliseconds, oneBarMilliseconds)
        sellZoneCreatedSignal := true
        chochActive := true
        activeChochDirection := -1
        lastAcceptedChochBar := bar_index
        outOfRangeUp := false
        outOfRangeDown := false
        upperExtensionShown := false
        lowerExtensionShown := false
    lastBreakDirection := -1

// --- Update Active CHOCH Set ---
if inCalculationWindow and chochActive
    int rightTime = time + extensionMilliseconds
    int activeLineCount = math.min(23, array.size(activeLines))
    if activeLineCount > 0
        for index = 0 to activeLineCount - 1
            line activeLine = array.get(activeLines, index)
            if not na(activeLine)
                line.set_x2(activeLine, rightTime)
    if showLevelLabelsInput
        int levelLabelCount = math.min(23, array.size(activeLabels))
        if levelLabelCount > 0
            for index = 0 to levelLabelCount - 1
                label activeLabel = array.get(activeLabels, index)
                if not na(activeLabel)
                    label.set_x(activeLabel, rightTime)

// --- Automatic Long-Trend Level Expansion ---
if inCalculationWindow and chochActive
    float upperFourTrigger = currentChochHigh + currentChochRange * 4.0
    float lowerFourTrigger = currentChochLow - currentChochRange * 4.0
    color activeDirectionColor = activeChochDirection == 1 ? chochLineUpInput : chochLineDownInput
    if not upperExtensionShown and high > upperFourTrigger
        f_showExtendedLevels(15, 18, activeDirectionColor)
        upperExtensionShown := true
    if not lowerExtensionShown and low < lowerFourTrigger
        f_showExtendedLevels(19, 22, activeDirectionColor)
        lowerExtensionShown := true

// --- Deviation Marker ---
bool deviationUpSignal = false
bool deviationDownSignal = false
if inCalculationWindow and chochActive
    float upperFourLevel = currentChochHigh + currentChochRange * 4.0
    float lowerFourLevel = currentChochLow - currentChochRange * 4.0
    if high > upperFourLevel
        outOfRangeUp := true
    if outOfRangeUp and close < upperFourLevel and close > lowerFourLevel
        deviationDownSignal := true
        outOfRangeUp := false
    if low < lowerFourLevel
        outOfRangeDown := true
    if outOfRangeDown and close > lowerFourLevel and close < upperFourLevel
        deviationUpSignal := true
        outOfRangeDown := false

// --- Visuals ---
plot(showVwapInput ? vwapValue : na, "Session VWAP", color = #5b9cf6, linewidth = 2)
plot(showEmaInput ? emaValue : na, "Trend EMA", color = #f59e0b, linewidth = 2)
plotshape(showDeviationInput and deviationDownSignal, "Dev Down", style = shape.triangledown, location = location.abovebar, color = deviationDownInput, size = size.small)
plotshape(showDeviationInput and deviationUpSignal, "Dev Up", style = shape.triangleup, location = location.belowbar, color = deviationUpInput, size = size.small)

// --- Alert Conditions ---
// Named alert conditions are always active. Users select the desired event directly in TradingView's alert dialog.
alertcondition(buyZoneCreatedSignal, "BUY Zone Created", "BUY ZONE created on {{ticker}} ({{interval}}). Price: {{close}}")
alertcondition(sellZoneCreatedSignal, "SELL Zone Created", "SELL ZONE created on {{ticker}} ({{interval}}). Price: {{close}}")
alertcondition(deviationUpSignal or deviationDownSignal, "Price Returning to Range", "Price returned inside the active -4 to +4 range on {{ticker}} ({{interval}}). Price: {{close}}")

// Optional combined stream for users selecting "Any alert() function call" in the alert dialog.
if buyZoneAlertInput and buyZoneCreatedSignal
    alert("BUY ZONE created | " + syminfo.ticker + " | " + timeframe.period + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if sellZoneAlertInput and sellZoneCreatedSignal
    alert("SELL ZONE created | " + syminfo.ticker + " | " + timeframe.period + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if returnToRangeAlertInput and (deviationUpSignal or deviationDownSignal)
    alert("Price returned inside the active -4 to +4 range | " + syminfo.ticker + " | " + timeframe.period + " | Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// --- Asset Zone HUD and Watermark ---
hudTextSize = f_labelSize(hudSizeInput)
var table zoneHudTable = table.new(position.top_right, 2, 4, frame_color = color.new(chart.fg_color, 70), frame_width = 1, border_color = color.new(chart.fg_color, 85), border_width = 1)
var table watermarkTable = table.new(position.bottom_right, 1, 1)

if barstate.islast
    string referenceZoneText = na(referenceZoneState) ? "NO DATA" : referenceZoneState == 1 ? "BUY ZONE" : referenceZoneState == -1 ? "SELL ZONE" : "NEUTRAL"
    color referenceZoneColor = na(referenceZoneState) ? color.new(chart.fg_color, 35) : referenceZoneState == 1 ? #089981 : referenceZoneState == -1 ? #f23645 : #5b9cf6
    color hudBackground = color.new(chart.bg_color, 15)

    if showHudInput
        table.cell(zoneHudTable, 0, 0, "REFERENCE ZONE HUD", text_color = chart.fg_color, bgcolor = color.new(#5b9cf6, 75), text_size = hudTextSize)
        table.cell(zoneHudTable, 1, 0, "STATUS", text_color = chart.fg_color, bgcolor = color.new(#5b9cf6, 75), text_size = hudTextSize)
        table.cell(zoneHudTable, 0, 1, "Asset", text_color = color.new(chart.fg_color, 25), bgcolor = hudBackground, text_size = hudTextSize)
        table.cell(zoneHudTable, 1, 1, hudAssetInput, text_color = chart.fg_color, bgcolor = hudBackground, text_size = hudTextSize)
        table.cell(zoneHudTable, 0, 2, "Asset Zone", text_color = color.new(chart.fg_color, 25), bgcolor = hudBackground, text_size = hudTextSize)
        table.cell(zoneHudTable, 1, 2, referenceZoneText, text_color = referenceZoneColor, bgcolor = hudBackground, text_size = hudTextSize)
        table.cell(zoneHudTable, 0, 3, "Timeframe", text_color = color.new(chart.fg_color, 25), bgcolor = hudBackground, text_size = hudTextSize)
        table.cell(zoneHudTable, 1, 3, timeframe.period, text_color = chart.fg_color, bgcolor = hudBackground, text_size = hudTextSize)
    else
        table.clear(zoneHudTable, 0, 0, 1, 3)

    table.cell(watermarkTable, 0, 0, "erdensedat", text_color = color.new(chart.fg_color, 70), bgcolor = #00000000, text_size = size.small)
````
