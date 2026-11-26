# Advanced Support & Resistance - Volume Zones

- url: https://www.tradingview.com/script/OzMrttLu-Advanced-Support-Resistance-Volume-Zones/
- type: indicator
- pine_id: PUB;7e8db053d7b24662884f6c69871f6777
- version: 1.0

## Description

**Advanced Support & Resistance - Volume Zones**

This indicator identifies potential support and resistance areas by detecting high-volume pivot points and converting them into visual price zones. Zones are created when unusual volume appears near local highs or lows, helping highlight areas where buying or selling pressure may have previously been significant.

The script includes automatic zone tuning that adjusts volume sensitivity, merge range, zone age, and visual zone thickness based on current market conditions and chart timeframe. This helps keep the zones proportional across very small timeframes, such as 1-second charts, as well as larger timeframes, including daily charts.

Key features include:

* High-volume support and resistance zone detection
* Automatic zone-setting adjustment based on market activity
* Automatic zone-appearance scaling by chart timeframe
* Optional volume-based zone widths
* Zone role reversal when price breaks through support or resistance
* Optional price-action swing lines for important pivot highs and lows that do not already have nearby volume zones
* Current bar volume status table showing volume, average volume, relative volume, and volume condition
* Customizable zone colors, opacity, borders, label size, and swing-line appearance

This script is designed to provide a cleaner view of meaningful support and resistance areas by combining volume activity with price structure. It can be useful for identifying possible reaction zones, breakout areas, retest levels, and areas of market interest.

As always, this indicator is intended as a visual analysis tool and should be used alongside your own trading plan, risk management, and confirmation methods.

Refinement assistance: Blue Finch

## Source Code

````pine
//@version=6
// Script refinement assistance: Blue Finch
indicator('Advanced Support & Resistance - Volume Zones', shorttitle = 'Sup & Res', overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

zone_settings = '------------------------------- Zone Settings ----------------------------'
// --- Inputs ---
bool autoTuneZones = input.bool(true, 'Auto Tune Zone Settings', group = zone_settings, tooltip = 'When checked, Volume Lookback Length, Volume Spike Multiplier, Max Zone Age, and Volume Zone Merge Range % are calculated automatically. Manual values are ignored until Auto Tune is unchecked.')
int lookback = input.int(50, 'Volume Lookback Length', minval = 50, step = 10, group = zone_settings, tooltip = 'Number of previous bars used to calculate average volume. A higher value smooths the average and requires more sustained volume to create new zones.')
float volMultiplier = input.float(1.5, 'Volume Spike Multiplier', minval = 0.01, step = 0.10, group = zone_settings, tooltip = 'Multiplier applied to average volume to determine whether a bar has enough volume to create a support or resistance zone.')
int maxAgeBars = input.int(1500, 'Max Zone Age (Bars)', minval = 100, step = 100, group = zone_settings, tooltip = 'Maximum number of bars a zone can remain active before it is removed. Higher-volume and retested zones may remain active longer when Auto Tune Zone Settings is checked.')
float testThreshold = input.float(0.05, 'Volume Zone Merge Range %', minval = 0.01, step = 0.01, group = zone_settings, tooltip = 'Maximum price distance allowed between a new level and an existing level. When the new level is within this range, its volume is merged into the existing level instead of creating a new zone.')

// Auto Tune baselines. These are intentionally hardcoded so changing the manual boxes
// does not redraw or alter the graphics while Auto Tune Zone Settings is checked.
int autoBaseLookback = 20
float autoBaseVolMultiplier = 1.5
int autoBaseMaxAgeBars = 1500
float autoBaseTestThreshold = 0.05

zone_app = '------------------------------ Zone Appearance -----------------------------'
// Zone display inputs
bool autoTuneZoneAppearance = input.bool(true, 'Auto Tune Zone Appearance', group = zone_app, tooltip = 'When checked, zone thickness is calculated automatically based on the chart timeframe. Minimum/Maximum Zone Thickness %, Zone Thickness Multiplier, and Zone Widths are Based Upon Volume are ignored until Auto Tune Zone Appearance is unchecked.')
bool baseZoneWidthsUponVolume = input.bool(false, 'Zone Widths are Based Upon Volume', group = zone_app, tooltip = 'When checked, zone thickness expands or contracts based on the relative volume of each active zone. When unchecked, all zones use a fixed thickness. This setting is ignored while Auto Tune Zone Appearance is checked.')
float minZoneThicknessPct = input.float(0.01, 'Minimum Zone Thickness %', minval = 0.01, step = 0.01, group = zone_app, tooltip = 'Smallest zone thickness allowed when volume-based zone widths are enabled. Lower values create thinner zones. This setting is ignored while Auto Tune Zone Appearance is checked.')
float maxZoneThicknessPct = input.float(0.05, 'Maximum Zone Thickness %', minval = 0.01, step = 0.01, group = zone_app, tooltip = 'Largest zone thickness allowed when volume-based zone widths are enabled. Higher values create wider zones for the strongest-volume levels. This setting is ignored while Auto Tune Zone Appearance is checked.')
float zoneThicknessMultiplier = input.float(1.0, 'Zone Thickness Multiplier', step = 0.10, group = zone_app, tooltip = 'Adjusts how strongly volume affects zone thickness when volume-based widths are enabled. Higher values make high-volume zones wider, up to the maximum thickness. This setting is ignored while Auto Tune Zone Appearance is checked.')
bool showZoneBorder = input.bool(false, 'Show Zone Border', group = zone_app, tooltip = 'When checked, each support and resistance zone is drawn with an outline. When unchecked, only the zone fill is shown.')
int zoneBorderWidth = input.int(1, 'Zone Border Width', minval = 1, maxval = 5, group = zone_app, tooltip = 'Controls the thickness of the zone border line when Show Zone Border is checked.')
color supportZoneFillColor = input.color(color.new(color.green, 70), 'Support Zone Fill Color / Opacity', group = zone_app, tooltip = 'Sets the fill color and opacity for support zones. The opacity controls how transparent the zone appears on the chart.')
color resistanceZoneFillColor = input.color(color.new(color.red, 70), 'Resistance Zone Fill Color / Opacity', group = zone_app, tooltip = 'Sets the fill color and opacity for resistance zones. The opacity controls how transparent the zone appears on the chart.')

// Auto Tune Appearance baselines. These are the 1-minute appearance defaults.
// When Auto Tune Zone Appearance is checked, changing the manual thickness boxes
// does not alter the auto-scaled output until Auto Tune Zone Appearance is unchecked.
float autoBaseMinZoneThicknessPct = 0.01
float autoBaseMaxZoneThicknessPct = 0.05
float autoBaseFixedZoneThicknessPct = 0.01
float autoBaseZoneThicknessMultiplier = 1.0

price_action = '------------------------- Price Action Swing Lines ---------------------'
// Price-action swing line inputs. These are separate from the volume zones.
bool showSwingLines = input.bool(false, 'Show Price-Action Swing Lines', group = price_action, tooltip = 'When checked, single price-action swing support and resistance lines are drawn from pivot highs and lows that do not already have a nearby volume zone.')
int swingPivotLeftBars = input.int(3, 'Swing Pivot Left Bars', minval = 1, maxval = 50, group = price_action, tooltip = 'Number of bars to the left of a pivot used to confirm a swing high or swing low. Higher values require a stronger pivot before a swing line is drawn.')
int swingPivotRightBars = input.int(3, 'Swing Pivot Right Bars', minval = 1, maxval = 50, group = price_action, tooltip = 'Number of bars to the right of a pivot used to confirm a swing high or swing low. Higher values delay confirmation but reduce weaker swing lines.')
int swingLineWidth = input.int(1, 'Swing Line Width', minval = 1, maxval = 5, group = price_action, tooltip = 'Controls the thickness of the optional price-action swing support and resistance lines.')
color swingSupportLineColor = input.color(color.new(#ff13f0, 50), 'Swing Support Line Color', group = price_action, tooltip = 'Sets the color and opacity for price-action swing support lines.')
color swingResistanceLineColor = input.color(color.new(#ff13f0, 50), 'Swing Resistance Line Color', group = price_action, tooltip = 'Sets the color and opacity for price-action swing resistance lines.')

graphics = '------------------------- Graphics -----------------------------------'
// Text Size Input
bool showVolumeText = input.bool(true, 'Show Volume Text', group = graphics, tooltip = 'When checked, each active volume zone displays a volume label showing the accumulated volume used to create or retest that zone.')
string textSizeInput = input.string('Normal', 'Volume Label Text Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = graphics, tooltip = 'Controls the text size of the volume labels drawn next to the support and resistance zones.')
bool showCurrentVolumeStatus = input.bool(true, 'Show Current Volume Status', group = graphics, tooltip = 'Shows a small table with the current bar volume, average volume, relative volume, and whether the current bar is below average, above average, or a volume spike.')

color supportVolTextColor = color.new(color.green, 0)
color resistanceVolTextColor = color.new(color.red, 0)

// Convert the text input into a system size value
string txtSize = size.normal
if textSizeInput == 'Tiny'
    txtSize := size.tiny
    txtSize
else if textSizeInput == 'Small'
    txtSize := size.small
    txtSize
else if textSizeInput == 'Normal'
    txtSize := size.normal
    txtSize
else if textSizeInput == 'Large'
    txtSize := size.large
    txtSize
else if textSizeInput == 'Huge'
    txtSize := size.huge
    txtSize

// Helper clamp function
f_clamp_float(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

// Auto-tune zone appearance by chart timeframe.
// 1-minute is the baseline. The square-root scale keeps changes gradual:
// 1-second zones become much thinner, while daily zones become much wider.
int chartTimeframeSecondsRaw = timeframe.in_seconds(timeframe.period)
float chartTimeframeSeconds = na(chartTimeframeSecondsRaw) ? 60.0 : math.max(1.0, chartTimeframeSecondsRaw * 1.0)
float zoneAppearanceScaleRaw = math.sqrt(chartTimeframeSeconds / 60.0)
float zoneAppearanceScale = autoTuneZoneAppearance ? f_clamp_float(zoneAppearanceScaleRaw, 0.12, 40.0) : 1.0
float effectiveMinZoneThicknessPct = autoTuneZoneAppearance ? f_clamp_float(autoBaseMinZoneThicknessPct * zoneAppearanceScale, 0.001, 10.0) : minZoneThicknessPct
float effectiveMaxZoneThicknessPct = autoTuneZoneAppearance ? f_clamp_float(autoBaseMaxZoneThicknessPct * zoneAppearanceScale, effectiveMinZoneThicknessPct, 10.0) : maxZoneThicknessPct
float effectiveFixedZoneThicknessPct = autoTuneZoneAppearance ? f_clamp_float(autoBaseFixedZoneThicknessPct * zoneAppearanceScale, 0.001, 10.0) : 0.01
float effectiveZoneThicknessMultiplier = autoTuneZoneAppearance ? autoBaseZoneThicknessMultiplier : zoneThicknessMultiplier

// When Auto Tune Zone Appearance is checked, sizing is fully controlled by the
// timeframe-scaled fixed width above. The manual Min/Max thickness boxes,
// Zone Thickness Multiplier, and volume-based width checkbox are ignored.
bool effectiveBaseZoneWidthsUponVolume = autoTuneZoneAppearance ? false : baseZoneWidthsUponVolume

// --- Calculations ---
float manualAvgVol = ta.sma(volume, lookback)

// Auto-tune price-action regime. These calculations do not change the input boxes.
// When Auto Tune Zone Settings is enabled, the manual boxes above are ignored
// for graphics and the hardcoded auto baselines are used instead.
float atrValue = ta.atr(14)
float atrPct = close > 0 ? atrValue / close * 100.0 : 0.0
float atrPctAvg = nz(ta.sma(atrPct, 100), atrPct)
float atrRatio = atrPctAvg > 0 ? atrPct / atrPctAvg : 1.0
float directionalMove = math.abs(close - nz(close[20], close))
float totalMove = ta.sma(math.abs(nz(ta.change(close))), 20) * 20.0
float efficiencyRatio = totalMove > 0 ? directionalMove / totalMove : 0.0

bool explosivePriceAction = atrRatio > 1.75 or efficiencyRatio > 0.60
bool activePriceAction = not explosivePriceAction and (atrRatio > 1.25 or efficiencyRatio > 0.45)
bool quietPriceAction = not explosivePriceAction and not activePriceAction and atrRatio < 0.75 and efficiencyRatio < 0.30

int quietLookback = math.max(autoBaseLookback * 2, autoBaseLookback + 1)
int normalLookback = autoBaseLookback
int activeLookback = math.max(5, int(math.round(autoBaseLookback * 0.75)))
int explosiveLookback = math.max(5, int(math.round(autoBaseLookback * 0.50)))

float quietAvgVol = ta.sma(volume, quietLookback)
float normalAvgVol = ta.sma(volume, normalLookback)
float activeAvgVol = ta.sma(volume, activeLookback)
float explosiveAvgVol = ta.sma(volume, explosiveLookback)

float autoAvgVol = explosivePriceAction ? explosiveAvgVol : activePriceAction ? activeAvgVol : quietPriceAction ? quietAvgVol : normalAvgVol
float avgVol = autoTuneZones ? nz(autoAvgVol, manualAvgVol) : manualAvgVol

float quietVolMultiplier = f_clamp_float(autoBaseVolMultiplier * 0.85, 1.05, 5.0)
float normalVolMultiplier = autoBaseVolMultiplier
float activeVolMultiplier = f_clamp_float(autoBaseVolMultiplier * 1.15, 1.05, 5.0)
float explosiveVolMultiplier = f_clamp_float(autoBaseVolMultiplier * 1.35, 1.05, 5.0)
float effectiveVolMultiplier = autoTuneZones ? explosivePriceAction ? explosiveVolMultiplier : activePriceAction ? activeVolMultiplier : quietPriceAction ? quietVolMultiplier : normalVolMultiplier : volMultiplier

float minAutoTestThreshold = math.max(autoBaseTestThreshold * 0.50, 0.01)
float maxAutoTestThreshold = math.max(autoBaseTestThreshold * 3.00, 0.03)
float atrBasedTestThreshold = atrPct * 0.75
float effectiveTestThreshold = autoTuneZones ? f_clamp_float(atrBasedTestThreshold, minAutoTestThreshold, maxAutoTestThreshold) : testThreshold

int effectiveMaxAgeBase = maxAgeBars
if autoTuneZones
    effectiveMaxAgeBase := explosivePriceAction ? math.max(10, int(math.round(autoBaseMaxAgeBars * 0.65))) : activePriceAction ? math.max(10, int(math.round(autoBaseMaxAgeBars * 0.85))) : quietPriceAction ? math.max(10, int(math.round(autoBaseMaxAgeBars * 1.25))) : autoBaseMaxAgeBars
    effectiveMaxAgeBase

bool isVolSpike = volume > avgVol * effectiveVolMultiplier

// Arrays to manage levels
var array<float> levelPrices = array.new_float(0)
var array<int> levelTypes = array.new_int(0) // 1 = Support, -1 = Resistance
var array<int> levelAges = array.new_int(0)
var array<float> levelVols = array.new_float(0)
var array<int> levelTests = array.new_int(0)
var array<box> levelBoxes = array.new_box(0)
var array<label> levelLabels = array.new_label(0)

// Arrays to manage optional price-action swing lines.
var array<float> swingPrices = array.new_float(0)
var array<int> swingTypes = array.new_int(0) // 1 = Support, -1 = Resistance
var array<int> swingAges = array.new_int(0)
var array<line> swingLines = array.new_line(0)

bool isHighVolLow = ta.lowest(low, 4) == low and isVolSpike
bool isHighVolHigh = ta.highest(high, 4) == high and isVolSpike

float swingPivotHigh = ta.pivothigh(high, swingPivotLeftBars, swingPivotRightBars)
float swingPivotLow = ta.pivotlow(low, swingPivotLeftBars, swingPivotRightBars)

// Function to format volume numbers
f_format_vol(float vol) =>
    vol >= 1000000 ? str.tostring(math.round(vol / 1000000, 1)) + 'M' : vol >= 1000 ? str.tostring(math.round(vol / 1000, 1)) + 'K' : str.tostring(math.round(vol))

// Current-volume table formatter.
// For high-priced assets, such as BTC or very high-priced stocks, fractional volume matters more.
// The $1,000 close-price cutoff keeps normal-priced stocks clean while showing one decimal where useful.
f_format_current_vol(float vol, bool useOneDecimal) =>
    useOneDecimal ? vol >= 1000000 ? str.tostring(vol / 1000000.0, '0.0') + 'M' : vol >= 1000 ? str.tostring(vol / 1000.0, '0.0') + 'K' : str.tostring(vol, '0.0') : f_format_vol(vol)

// Converts volume into a zone thickness. When manual volume-based widths are enabled,
// the highest-volume active zone receives the maximum manual thickness.
// When Auto Tune Zone Appearance is checked, this volume-based manual path is bypassed,
// so the timeframe-scaled auto width is used regardless of the manual appearance inputs.
f_get_zone_bounds(float price, float levelVol, float maxVol) =>
    float zonePct = effectiveFixedZoneThicknessPct
    if effectiveBaseZoneWidthsUponVolume
        float safeMinPct = math.min(effectiveMinZoneThicknessPct, effectiveMaxZoneThicknessPct)
        float safeMaxPct = math.max(effectiveMinZoneThicknessPct, effectiveMaxZoneThicknessPct)
        float volRatio = maxVol > 0 ? levelVol / maxVol : 1.0
        zonePct := safeMinPct + (safeMaxPct - safeMinPct) * volRatio * effectiveZoneThicknessMultiplier
        zonePct := math.min(safeMaxPct, math.max(safeMinPct, zonePct))
        zonePct
    float halfRange = price * zonePct / 100.0 / 2.0
    [price + halfRange, price - halfRange]

f_zone_bg(color zoneColor) =>
    zoneColor

f_zone_border(color zoneColor) =>
    float fillTransparency = color.t(zoneColor)
    float borderTransparency = math.max(0.0, fillTransparency - 15.0)
    showZoneBorder ? color.new(zoneColor, borderTransparency) : color.new(zoneColor, 100)

f_vol_text(int levelType, float levelVol) =>
    showVolumeText ? 'Vol: ' + f_format_vol(levelVol) : ''

f_vol_text_color(int levelType) =>
    showVolumeText ? levelType == 1 ? supportVolTextColor : resistanceVolTextColor : color.new(color.white, 100)

// --- Current Bar Volume Status Table ---
// Uses the same average-volume and spike logic that drives the support/resistance zones.
var table currentVolumeTable = table.new(position.top_right, 1, 4, border_width = 1)

float currentVolumeDecimalPriceCutoff = 1000.0
bool useCurrentVolumeDecimal = close >= currentVolumeDecimalPriceCutoff
bool currentVolAvgReady = not na(avgVol) and avgVol > 0
bool currentVolAboveAvg = currentVolAvgReady and volume >= avgVol
bool currentVolSpike = currentVolAvgReady and volume > avgVol * effectiveVolMultiplier
float currentRelVol = currentVolAvgReady ? volume / avgVol : na
string currentVolStatus = not currentVolAvgReady ? 'AVG WAIT' : currentVolSpike ? 'VOLUME SPIKE' : currentVolAboveAvg ? 'ABOVE AVG' : 'BELOW AVG'
color currentVolStatusColor = not currentVolAvgReady ? color.gray : currentVolSpike ? color.orange : currentVolAboveAvg ? color.green : color.gray

if barstate.islast
    if showCurrentVolumeStatus
        table.cell(currentVolumeTable, 0, 0, 'Current Volume', text_color = color.white, bgcolor = color.black)
        table.cell(currentVolumeTable, 0, 1, 'Vol: ' + f_format_current_vol(volume, useCurrentVolumeDecimal), text_color = currentVolStatusColor, bgcolor = color.new(color.black, 20))
        table.cell(currentVolumeTable, 0, 2, 'Avg: ' + (currentVolAvgReady ? f_format_current_vol(avgVol, useCurrentVolumeDecimal) : 'n/a'), text_color = color.white, bgcolor = color.new(color.black, 20))
        table.cell(currentVolumeTable, 0, 3, 'Rel: ' + (na(currentRelVol) ? 'n/a' : str.tostring(math.round(currentRelVol, 2)) + 'x') + '  ' + currentVolStatus, text_color = currentVolStatusColor, bgcolor = color.new(color.black, 20))
    else
        table.clear(currentVolumeTable, 0, 0, 0, 3)

f_has_near_volume_level(float price, float threshold) =>
    bool found = false
    if array.size(levelPrices) > 0
        for k = 0 to array.size(levelPrices) - 1 by 1
            float existingPrice = array.get(levelPrices, k)
            float diffPercent = existingPrice != 0.0 ? math.abs(price - existingPrice) / existingPrice * 100.0 : 999999.0
            if diffPercent <= threshold
                found := true
                break
    found

f_has_near_swing_line(float price, int lineType, float threshold) =>
    bool found = false
    if array.size(swingPrices) > 0
        for k = 0 to array.size(swingPrices) - 1 by 1
            float existingPrice = array.get(swingPrices, k)
            int existingType = array.get(swingTypes, k)
            float diffPercent = existingPrice != 0.0 ? math.abs(price - existingPrice) / existingPrice * 100.0 : 999999.0
            if existingType == lineType and diffPercent <= threshold
                found := true
                break
    found

if isHighVolLow or isHighVolHigh
    float basePrice = isHighVolLow ? low : high
    int currentType = isHighVolLow ? 1 : -1

    // Check if this new level is testing an EXISTING level
    bool isTest = false
    if array.size(levelPrices) > 0
        for i = 0 to array.size(levelPrices) - 1 by 1
            float existingPrice = array.get(levelPrices, i)
            float diffPercent = math.abs(basePrice - existingPrice) / existingPrice * 100

            if diffPercent <= effectiveTestThreshold
                // Add new volume to old volume
                float updatedVol = array.get(levelVols, i) + volume
                array.set(levelVols, i, updatedVol)
                array.set(levelTests, i, array.get(levelTests, i) + 1)

                // Update the text label with the combined volume
                label currentLabel = array.get(levelLabels, i)
                label.set_text(currentLabel, f_vol_text(array.get(levelTypes, i), updatedVol))
                label.set_textcolor(currentLabel, f_vol_text_color(array.get(levelTypes, i)))

                isTest := true
                break

    // Create completely new zone
    if not isTest
        color currentColor = currentType == 1 ? supportZoneFillColor : resistanceZoneFillColor
        float initialMaxVol = volume
        if array.size(levelVols) > 0
            for j = 0 to array.size(levelVols) - 1 by 1
                initialMaxVol := math.max(initialMaxVol, array.get(levelVols, j))
                initialMaxVol
        [zoneTop, zoneBottom] = f_get_zone_bounds(basePrice, volume, initialMaxVol)

        array.push(levelPrices, basePrice)
        array.push(levelTypes, currentType)
        array.push(levelAges, 0)
        array.push(levelVols, volume)
        array.push(levelTests, 1)

        box newBox = box.new(left = bar_index, top = zoneTop, right = bar_index, bottom = zoneBottom, bgcolor = f_zone_bg(currentColor), border_color = f_zone_border(currentColor), border_width = zoneBorderWidth)
        label newLabel = label.new(x = bar_index, y = basePrice, text = f_vol_text(currentType, volume), color = color.new(color.black, 100), textcolor = f_vol_text_color(currentType), style = label.style_label_left, size = txtSize)

        array.push(levelBoxes, newBox)
        array.push(levelLabels, newLabel)

// --- Price-Action Swing Line Creation ---
// These single lines catch important pivot highs/lows that do not already have a nearby volume zone.
if showSwingLines and not na(swingPivotHigh)
    float swingPrice = swingPivotHigh
    int swingType = -1
    int swingStartBar = bar_index - swingPivotRightBars
    bool nearVolumeZone = f_has_near_volume_level(swingPrice, effectiveTestThreshold)
    bool nearSwingLine = f_has_near_swing_line(swingPrice, swingType, effectiveTestThreshold)
    if not nearVolumeZone and not nearSwingLine
        line newSwingLine = line.new(x1 = swingStartBar, y1 = swingPrice, x2 = bar_index, y2 = swingPrice, color = swingResistanceLineColor, width = swingLineWidth)
        array.push(swingPrices, swingPrice)
        array.push(swingTypes, swingType)
        array.push(swingAges, swingPivotRightBars)
        array.push(swingLines, newSwingLine)

if showSwingLines and not na(swingPivotLow)
    float swingPrice = swingPivotLow
    int swingType = 1
    int swingStartBar = bar_index - swingPivotRightBars
    bool nearVolumeZone = f_has_near_volume_level(swingPrice, effectiveTestThreshold)
    bool nearSwingLine = f_has_near_swing_line(swingPrice, swingType, effectiveTestThreshold)
    if not nearVolumeZone and not nearSwingLine
        line newSwingLine = line.new(x1 = swingStartBar, y1 = swingPrice, x2 = bar_index, y2 = swingPrice, color = swingSupportLineColor, width = swingLineWidth)
        array.push(swingPrices, swingPrice)
        array.push(swingTypes, swingType)
        array.push(swingAges, swingPivotRightBars)
        array.push(swingLines, newSwingLine)

// --- Active Zone Management ---
if array.size(levelPrices) > 0
    float maxActiveVol = 0.0
    for j = 0 to array.size(levelVols) - 1 by 1
        maxActiveVol := math.max(maxActiveVol, array.get(levelVols, j))
        maxActiveVol

    for i = array.size(levelPrices) - 1 to 0 by 1
        float price = array.get(levelPrices, i)
        int type = array.get(levelTypes, i)
        int age = array.get(levelAges, i) + 1
        float levelVol = array.get(levelVols, i)
        int levelTestCount = array.get(levelTests, i)
        box currentBox = array.get(levelBoxes, i)
        label currentLabel = array.get(levelLabels, i)
        color currentColor = type == 1 ? supportZoneFillColor : resistanceZoneFillColor
        [zoneTop, zoneBottom] = f_get_zone_bounds(price, levelVol, maxActiveVol)
        float levelVolRatio = maxActiveVol > 0 ? levelVol / maxActiveVol : 1.0
        float volumeAgeMultiplier = 0.75 + 0.75 * levelVolRatio
        float retestAgeMultiplier = 1.0 + math.min(levelTestCount - 1, 5) * 0.10
        int effectiveMaxAgeForLevel = autoTuneZones ? math.max(10, int(math.round(effectiveMaxAgeBase * volumeAgeMultiplier * retestAgeMultiplier))) : maxAgeBars

        array.set(levelAges, i, age)

        // Delete if the zone gets too old. In auto mode, higher-volume and re-tested zones stay active longer.
        if age > effectiveMaxAgeForLevel
            box.delete(currentBox)
            label.delete(currentLabel)
            array.remove(levelPrices, i)
            array.remove(levelTypes, i)
            array.remove(levelAges, i)
            array.remove(levelVols, i)
            array.remove(levelTests, i)
            array.remove(levelBoxes, i)
            array.remove(levelLabels, i)
            continue

        // Update active zone segment and redraw thickness based on volume
        box.set_right(currentBox, bar_index)
        box.set_top(currentBox, zoneTop)
        box.set_bottom(currentBox, zoneBottom)
        box.set_bgcolor(currentBox, f_zone_bg(currentColor))
        box.set_border_color(currentBox, f_zone_border(currentColor))
        box.set_border_width(currentBox, zoneBorderWidth)

        label.set_x(currentLabel, bar_index)
        label.set_y(currentLabel, price)
        label.set_text(currentLabel, f_vol_text(type, levelVol))
        label.set_textcolor(currentLabel, f_vol_text_color(type))

        // Handle Role Reversals. A zone is broken only after the close is outside the zone.
        bool isBroken = type == 1 and close < zoneBottom or type == -1 and close > zoneTop

        if isBroken
            box.set_right(currentBox, bar_index)

            int newType = type * -1
            color newColor = newType == 1 ? supportZoneFillColor : resistanceZoneFillColor

            box newBox = box.new(left = bar_index, top = zoneTop, right = bar_index, bottom = zoneBottom, bgcolor = f_zone_bg(newColor), border_color = f_zone_border(newColor), border_width = zoneBorderWidth)

            label.set_text(currentLabel, f_vol_text(newType, levelVol))
            label.set_textcolor(currentLabel, f_vol_text_color(newType))
            label.set_x(currentLabel, bar_index)
            label.set_y(currentLabel, price)

            array.set(levelTypes, i, newType)
            array.set(levelBoxes, i, newBox)

// --- Active Price-Action Swing Line Management ---
if array.size(swingPrices) > 0
    for i = array.size(swingPrices) - 1 to 0 by 1
        float price = array.get(swingPrices, i)
        int type = array.get(swingTypes, i)
        int age = array.get(swingAges, i) + 1
        line currentSwingLine = array.get(swingLines, i)
        color currentSwingColor = type == 1 ? swingSupportLineColor : swingResistanceLineColor
        int effectiveSwingMaxAge = autoTuneZones ? effectiveMaxAgeBase : maxAgeBars

        array.set(swingAges, i, age)

        if not showSwingLines or age > effectiveSwingMaxAge
            line.delete(currentSwingLine)
            array.remove(swingPrices, i)
            array.remove(swingTypes, i)
            array.remove(swingAges, i)
            array.remove(swingLines, i)
            continue

        line.set_x2(currentSwingLine, bar_index)
        line.set_y1(currentSwingLine, price)
        line.set_y2(currentSwingLine, price)
        line.set_color(currentSwingLine, currentSwingColor)
        line.set_width(currentSwingLine, swingLineWidth)

        // Handle role reversals for the structural line.
        bool isSwingBroken = type == 1 and close < price or type == -1 and close > price
        if isSwingBroken
            line.set_x2(currentSwingLine, bar_index)
            int newType = type * -1
            color newSwingColor = newType == 1 ? swingSupportLineColor : swingResistanceLineColor
            line newSwingLine = line.new(x1 = bar_index, y1 = price, x2 = bar_index, y2 = price, color = newSwingColor, width = swingLineWidth)
            array.set(swingTypes, i, newType)
            array.set(swingLines, i, newSwingLine)
````
