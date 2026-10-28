# CME Price Limit Monitor

- url: https://www.tradingview.com/script/TjuEUMBV-CME-Price-Limit-Monitor/
- type: indicator
- pine_id: PUB;d71ba43506a54391914b93e9e853362b
- version: 1.0

## Description

CME Price Limit Monitor is a TradingView indicator for monitoring CME equity index futures price-limit risk directly on the chart.

It displays estimated CME limit-up and limit-down levels, custom prop-firm warning levels, current distance to each level, and a compact dashboard for quick risk awareness.

[b]Key Features[/b]

[list]
[*]  Monitors both CME limit-up and limit-down levels
[*]  Supports Auto Mode and Manual Mode
[*]  Maps micro contracts to their mini counterparts for calculation
[*]    - [symbol="CME_MINI:MES1!"]CME_MINI:MES1![/symbol] MES → [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] ES
[*]    - [symbol="CME_MINI:MNQ1!"]CME_MINI:MNQ1![/symbol] MNQ → [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] NQ
[*]    - [symbol="CBOT_MINI:MYM1!"]CBOT_MINI:MYM1![/symbol] MYM → [symbol="CBOT_MINI:YM1!"]CBOT_MINI:YM1![/symbol] YM
[*]    - [symbol="CME_MINI:M2K1!"]CME_MINI:M2K1![/symbol] M2K → [symbol="CME_MINI:RTY1!"]CME_MINI:RTY1![/symbol] RTY
[*]  Displays prop-firm warning levels before official CME limits are reached
[*]  Provides a dashboard with current status, distances, reference price, and calculated levels
[*]  Supports TradingView manual alert creation through built-in alert conditions
[/list]

[b]Auto Mode[/b]

Auto Mode estimates the CME reference price from a continuous futures symbol, such as [symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] CME_MINI:NQ1!.

The indicator attempts to reconstruct the CME fixing window using TradingView data:

[list]
[*]  Accurate Mode: volume-weighted 1-second data
[*]  Fast Mode: 30-second estimate
[/list]

You can also override the calculation symbol manually using TradingView’s symbol selector.

[b]Manual Mode[/b]

Manual Mode lets you enter verified CME values yourself:

[list]
[*]  Reference Price
[*]  CME Official Limit-Up Price
[*]  CME Official Limit-Down Price
[/list]

Manual Mode is recommended when exact official values are required.

[b]Prop-Firm Warning Levels[/b]

The prop-firm buffer is measured in percentage points.

Example: if the CME limit is 7% and the prop-firm buffer is 2%, the warning level is calculated at 5% from the reference price.

[b]Alerts[/b]

Alerts are created manually through TradingView’s official alert workflow.

Available alert conditions:

[list]
[*]  Entered Prop-Firm Warning Zone
[*]  Reached/Breached Official CME Limit
[/list]

[b]Official CME Price Limits[/b]

Always verify calculated or manually entered values against CME’s official price limit page:

[url=https://www.cmegroup.com/trading/price-limits.html]https://www.cmegroup.com/trading/price-limits.html[/url]

[b]Important Disclaimer[/b]

This indicator is for visual risk monitoring only. It does not guarantee official CME accuracy, broker accuracy, or prop-firm rule compliance. Auto Mode is an estimate based on TradingView-accessible data and may differ from CME-published official values.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NixYoung

//@version=6
indicator("CME Price Limit Monitor", overlay = true, max_labels_count = 4)

// IMPORTANT LIMITATION:
// This indicator does not automatically verify official CME price limits. Traders must input or verify
// the correct CME official price-limit levels from CME Group or their broker/data provider. This tool
// is for visual risk monitoring only and does not guarantee prop-firm rule compliance.
//
// AUTO-MODE LIMITATION:
// CME U.S. equity-index limits use the prior session's futures fixing: the VWAP from 2:59:30 p.m.
// through 3:00:00 p.m. America/Chicago time. Auto mode reconstructs this value from a continuous
// futures ticker, using the mini contract for micro products. Because Pine cannot access CME's
// official fixing feed or individual trades, the result is an estimate and must be checked against
// CME's published fixing price and limits. Accurate mode uses volume-weighted one-second bars; Fast
// mode reduces computation by using a single 30-second bar and may produce less accurate levels.

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------

string mode = input.string(
     "Auto",
     "Mode",
     options = ["Manual", "Auto"],
     group = "Calculation")

float referencePriceInput = input.float(
     0.0,
     "Reference Price",
     minval = 0.0,
     tooltip = "Required in manual mode to derive the prop-firm warning levels from manually entered CME limits.",
     group = "Manual Mode")
float manualLimitUp = input.float(0.0, "CME Official Limit-Up Price", minval = 0.0, group = "Manual Mode")
float manualLimitDown = input.float(0.0, "CME Official Limit-Down Price", minval = 0.0, group = "Manual Mode")

float limitPercent = input.float(7.0, "CME Limit Percentage", minval = 0.0, step = 0.1, group = "Calculation")
float propBufferPercent = input.float(2.0, "Prop-Firm Buffer Percentage Points", minval = 0.0, step = 0.1, group = "Calculation")
string calculationFuturesSymbolOverride = input.symbol(
     "",
     "Calculation Override",
     tooltip = "Optional TradingView symbol for calculation such as CME_MINI:NQ1!. Leave blank to map the current contract automatically. Micro contracts are mapped to their mini counterparts.",
     group = "Auto Mode")
string autoCalculationQuality = input.string(
     "Accurate",
     "Auto Calculation Quality",
     options = ["Accurate", "Fast"],
     tooltip = "Accurate: reconstructs CME's 30-second futures fixing from volume-weighted 1-second bars. This is slower but should be used when price accuracy is the priority.\n\nFast: uses one 30-second bar's typical price. This materially reduces computation but may shift the reference price and resulting limit levels. Always verify calculated levels against CME.",
     group = "Auto Mode")

string dashboardPositionInput = input.string(
     "Top Right",
     "Dashboard Position",
     options = [
          "Top Left",
          "Top Center",
          "Top Right",
          "Middle Left",
          "Middle Right",
          "Bottom Left",
          "Bottom Center",
          "Bottom Right"],
     group = "Plotting Options")
string dashboardSize = input.string(
     "Small",
     "Dashboard Size",
     options = ["Normal", "Small", "Extra Small"],
     group = "Plotting Options")

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------

roundToTick(float value) =>
    float tick = syminfo.mintick
    na(value) or tick <= 0.0 ? value : math.round(value / tick) * tick

formatPrice(float value) =>
    na(value) ? "N/A" : str.tostring(value, format.mintick)

formatDistance(float points, float percent) =>
    na(points) or na(percent) ? "N/A" :
     str.tostring(points, format.mintick) + " pts / " +
     str.tostring(percent, "#.##") + "%"

// Accurate mode: reconstruct CME's fixing from volume-weighted one-second
// bars inside the official 2:59:30-3:00:00 p.m. CT fixing window.
cmeEquityFixingAccurate() =>
    string cmeTimezone = "America/Chicago"
    int chicagoHour = hour(time, cmeTimezone)
    int chicagoMinute = minute(time, cmeTimezone)
    int chicagoSecond = second(time, cmeTimezone)
    bool inFixingWindow = chicagoHour == 14 and chicagoMinute == 59 and chicagoSecond >= 30
    bool fixingWindowStarted = inFixingWindow and not inFixingWindow[1]
    bool fixingWindowEnded = not inFixingWindow and inFixingWindow[1]
    var float fixingPriceVolume = 0.0
    var float fixingVolume = 0.0
    var float lastCompletedFixing = na

    if fixingWindowStarted
        fixingPriceVolume := 0.0
        fixingVolume := 0.0

    if inFixingWindow and volume > 0
        fixingPriceVolume += hlc3 * volume
        fixingVolume += volume

    if fixingWindowEnded and fixingVolume > 0
        lastCompletedFixing := fixingPriceVolume / fixingVolume

    lastCompletedFixing

// Fast mode: estimate the fixing from one aggregated 30-second bar. This is
// substantially cheaper but HLC3 is not equivalent to CME's trade-level VWAP.
cmeEquityFixingFast() =>
    string cmeTimezone = "America/Chicago"
    bool isFixingBar = hour(time, cmeTimezone) == 14 and
         minute(time, cmeTimezone) == 59 and second(time, cmeTimezone) == 30
    var float lastCompletedFixing = na

    if isFixingBar and barstate.isconfirmed
        lastCompletedFixing := hlc3

    lastCompletedFixing

//------------------------------------------------------------------------------
// Input validation
//------------------------------------------------------------------------------

bool useManualMode = mode == "Manual"

// Auto mode calculates from continuous futures. Micro roots are mapped to the
// mini contracts because CME equity-index limits are shared across the product
// family and mini futures generally provide the deeper fixing data.
string calculationRoot = syminfo.root == "MES" ? "ES" :
     syminfo.root == "MNQ" ? "NQ" :
     syminfo.root == "MYM" ? "YM" :
     syminfo.root == "M2K" ? "RTY" : syminfo.root

string mappedCalculationSymbol = syminfo.prefix != "" and calculationRoot != "" ?
     syminfo.prefix + ":" + calculationRoot + "1!" :
     calculationRoot != "" ? calculationRoot + "1!" : ""

string autoCalculationSymbol = calculationFuturesSymbolOverride != "" ?
     calculationFuturesSymbolOverride : mappedCalculationSymbol
bool hasAutoCalculationSymbol = autoCalculationSymbol != ""

float autoReferencePrice = na
bool usingFastAutoCalculation = false
bool accurateCalculationUnavailable = false

// Only the selected fixing method is requested. Accurate mode uses bounded
// one-second history to control execution time. It never silently falls back
// to Fast mode because doing so would both add work and reduce accuracy.
if not useManualMode
    if hasAutoCalculationSymbol and autoCalculationQuality == "Accurate"
        autoReferencePrice := request.security(
             autoCalculationSymbol,
             "1S",
             cmeEquityFixingAccurate(),
             gaps = barmerge.gaps_off,
             lookahead = barmerge.lookahead_off,
             ignore_invalid_symbol = true,
             calc_bars_count = 100000)

        accurateCalculationUnavailable := na(autoReferencePrice)

    if hasAutoCalculationSymbol and autoCalculationQuality == "Fast"
        autoReferencePrice := request.security(
             autoCalculationSymbol,
             "30S",
             cmeEquityFixingFast(),
             gaps = barmerge.gaps_off,
             lookahead = barmerge.lookahead_off,
             ignore_invalid_symbol = true,
             calc_bars_count = 5000)
        usingFastAutoCalculation := true

float referencePrice = roundToTick(useManualMode ? referencePriceInput : autoReferencePrice)
bool validReference = not na(referencePrice) and referencePrice > 0.0
bool validManualUp = manualLimitUp > 0.0
bool validManualDown = manualLimitDown > 0.0
bool validManualUpForProp = validManualUp and validReference and manualLimitUp >= referencePrice
bool validManualDownForProp = validManualDown and validReference and manualLimitDown <= referencePrice

//------------------------------------------------------------------------------
// Official CME limits
//------------------------------------------------------------------------------

float officialLimitUp = na
float officialLimitDown = na

if useManualMode
    officialLimitUp := validManualUp ? roundToTick(manualLimitUp) : na
else
    officialLimitUp := validReference ?
         roundToTick(referencePrice * (1.0 + limitPercent / 100.0)) : na

if useManualMode
    officialLimitDown := validManualDown ? roundToTick(manualLimitDown) : na
else
    officialLimitDown := validReference ?
         roundToTick(referencePrice * (1.0 - limitPercent / 100.0)) : na

//------------------------------------------------------------------------------
// Prop-firm warning limits
//
// The buffer is measured in percentage points. In Auto mode, a 7% exchange width
// with a 2-point buffer creates a warning width equal to 5% of the continuous
// futures fixing. In Manual mode, the existing implied-percentage method is
// retained. math.max() prevents a negative adjusted percentage.
//------------------------------------------------------------------------------

float impliedUpPercent = na
float impliedDownPercent = na

if validReference and not na(officialLimitUp) and (not useManualMode or validManualUpForProp)
    impliedUpPercent := ((officialLimitUp / referencePrice) - 1.0) * 100.0

if validReference and not na(officialLimitDown) and (not useManualMode or validManualDownForProp)
    impliedDownPercent := (1.0 - officialLimitDown / referencePrice) * 100.0

float adjustedUpPercent = useManualMode ?
     (na(impliedUpPercent) ? na : math.max(impliedUpPercent - propBufferPercent, 0.0)) :
     math.max(limitPercent - propBufferPercent, 0.0)

float adjustedDownPercent = useManualMode ?
     (na(impliedDownPercent) ? na : math.max(impliedDownPercent - propBufferPercent, 0.0)) :
     math.max(limitPercent - propBufferPercent, 0.0)

float propWarningUp = na
float propWarningDown = na

if validReference and not na(adjustedUpPercent)
    propWarningUp := roundToTick(referencePrice * (1.0 + adjustedUpPercent / 100.0))

if validReference and not na(adjustedDownPercent)
    propWarningDown := roundToTick(referencePrice * (1.0 - adjustedDownPercent / 100.0))

//------------------------------------------------------------------------------
// Palette
//------------------------------------------------------------------------------

color cmeColor = color.rgb(220, 76, 70)
color propColor = color.rgb(229, 168, 75)
color safeColor = color.rgb(60, 166, 120)
color neutralColor = color.rgb(117, 128, 143)
color panelHeaderColor = color.rgb(30, 41, 59)
color panelNameColor = color.rgb(51, 65, 85)
color panelValueColor = color.rgb(15, 23, 42)
color panelBorderColor = color.new(color.rgb(148, 163, 184), 55)
color panelTextColor = color.rgb(241, 245, 249)

//------------------------------------------------------------------------------
// Price scale values
//------------------------------------------------------------------------------

// Plot only the latest value and enable TradingView's price line by default.
// This keeps plotting controls in the Style tab without drawing prior-session
// limit paths or transition segments.
plot(barstate.islast ? officialLimitUp : na,
     title = "CME Limit Up",
     color = cmeColor,
     linewidth = 2,
     trackprice = true,
     show_last = 1)

plot(barstate.islast ? officialLimitDown : na,
     title = "CME Limit Down",
     color = cmeColor,
     linewidth = 2,
     trackprice = true,
     show_last = 1)

plot(barstate.islast ? propWarningUp : na,
     title = "Prop Warning Up",
     color = propColor,
     linewidth = 1,
     trackprice = true,
     show_last = 1)

plot(barstate.islast ? propWarningDown : na,
     title = "Prop Warning Down",
     color = propColor,
     linewidth = 1,
     trackprice = true,
     show_last = 1)

//------------------------------------------------------------------------------
// Distance calculations
//------------------------------------------------------------------------------

float distanceOfficialUpPoints = not na(officialLimitUp) ? officialLimitUp - close : na
float distanceOfficialUpPercent = not na(officialLimitUp) and close != 0.0 ?
     distanceOfficialUpPoints / close * 100.0 : na

float distanceOfficialDownPoints = not na(officialLimitDown) ? close - officialLimitDown : na
float distanceOfficialDownPercent = not na(officialLimitDown) and close != 0.0 ?
     distanceOfficialDownPoints / close * 100.0 : na

float distancePropUpPoints = not na(propWarningUp) ? propWarningUp - close : na
float distancePropUpPercent = not na(propWarningUp) and close != 0.0 ?
     distancePropUpPoints / close * 100.0 : na

float distancePropDownPoints = not na(propWarningDown) ? close - propWarningDown : na
float distancePropDownPercent = not na(propWarningDown) and close != 0.0 ?
     distancePropDownPoints / close * 100.0 : na

//------------------------------------------------------------------------------
// Status
//------------------------------------------------------------------------------

bool atOfficialUp = not na(officialLimitUp) and close >= officialLimitUp
bool atOfficialDown = not na(officialLimitDown) and close <= officialLimitDown

bool nearLimitUp = not na(propWarningUp) and
     not na(officialLimitUp) and close >= propWarningUp and close < officialLimitUp

bool nearLimitDown = not na(propWarningDown) and
     not na(officialLimitDown) and close <= propWarningDown and close > officialLimitDown

bool missingSelectedOfficialLimit = na(officialLimitUp) or na(officialLimitDown)

string currentStatus = atOfficialUp ? "At/Beyond CME Limit Up" :
     atOfficialDown ? "At/Beyond CME Limit Down" :
     missingSelectedOfficialLimit ?
     (useManualMode ? "Enter Manual CME Limits" :
     not hasAutoCalculationSymbol ? "Set Futures Symbol" : "Auto Fixing Unavailable") :
     not validReference ? "Reference Needed for Prop Levels" :
     nearLimitUp ? "Near Limit Up" :
     nearLimitDown ? "Near Limit Down" : "Safe"

color statusColor = atOfficialUp or atOfficialDown ? cmeColor :
     missingSelectedOfficialLimit or not validReference ? neutralColor :
     nearLimitUp or nearLimitDown ? propColor : safeColor

//------------------------------------------------------------------------------
// Price labels
//------------------------------------------------------------------------------

var label officialUpLabel = na
var label officialDownLabel = na
var label propUpLabel = na
var label propDownLabel = na

if barstate.islast
    if not na(officialLimitUp)
        string officialUpText = "CME Limit Up: " + formatPrice(officialLimitUp)
        if na(officialUpLabel)
            officialUpLabel := label.new(
                 bar_index, officialLimitUp, officialUpText,
                 xloc = xloc.bar_index, style = label.style_label_right,
                 color = cmeColor, textcolor = panelTextColor, size = size.small)
        else
            label.set_xy(officialUpLabel, bar_index, officialLimitUp)
            label.set_text(officialUpLabel, officialUpText)
    else if not na(officialUpLabel)
        label.delete(officialUpLabel)
        officialUpLabel := na

    if not na(officialLimitDown)
        string officialDownText = "CME Limit Down: " + formatPrice(officialLimitDown)
        if na(officialDownLabel)
            officialDownLabel := label.new(
                 bar_index, officialLimitDown, officialDownText,
                 xloc = xloc.bar_index, style = label.style_label_right,
                 color = cmeColor, textcolor = panelTextColor, size = size.small)
        else
            label.set_xy(officialDownLabel, bar_index, officialLimitDown)
            label.set_text(officialDownLabel, officialDownText)
    else if not na(officialDownLabel)
        label.delete(officialDownLabel)
        officialDownLabel := na

    if not na(propWarningUp)
        string propUpText = "Prop Warning Up: " + formatPrice(propWarningUp)
        if na(propUpLabel)
            propUpLabel := label.new(
                 bar_index, propWarningUp, propUpText,
                 xloc = xloc.bar_index, style = label.style_label_right,
                 color = propColor, textcolor = panelValueColor, size = size.small)
        else
            label.set_xy(propUpLabel, bar_index, propWarningUp)
            label.set_text(propUpLabel, propUpText)
    else if not na(propUpLabel)
        label.delete(propUpLabel)
        propUpLabel := na

    if not na(propWarningDown)
        string propDownText = "Prop Warning Down: " + formatPrice(propWarningDown)
        if na(propDownLabel)
            propDownLabel := label.new(
                 bar_index, propWarningDown, propDownText,
                 xloc = xloc.bar_index, style = label.style_label_right,
                 color = propColor, textcolor = panelValueColor, size = size.small)
        else
            label.set_xy(propDownLabel, bar_index, propWarningDown)
            label.set_text(propDownLabel, propDownText)
    else if not na(propDownLabel)
        label.delete(propDownLabel)
        propDownLabel := na

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------

string dashboardPosition = dashboardPositionInput == "Top Left" ? position.top_left :
     dashboardPositionInput == "Top Center" ? position.top_center :
     dashboardPositionInput == "Top Right" ? position.top_right :
     dashboardPositionInput == "Middle Left" ? position.middle_left :
     dashboardPositionInput == "Middle Right" ? position.middle_right :
     dashboardPositionInput == "Bottom Left" ? position.bottom_left :
     dashboardPositionInput == "Bottom Center" ? position.bottom_center :
     position.bottom_right

var table dashboard = table.new(
     dashboardPosition,
     2,
     13,
     border_width = 1,
     border_color = panelBorderColor)

if barstate.islast
    string dashboardTextSize = dashboardSize == "Normal" ? size.normal :
         dashboardSize == "Small" ? size.small : size.tiny

    table.cell(dashboard, 0, 0, "CME / Prop Monitor", bgcolor = panelHeaderColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 0, syminfo.ticker, bgcolor = panelHeaderColor, text_color = panelTextColor, text_size = dashboardTextSize)

    string autoModeText = not hasAutoCalculationSymbol ? "Auto (set futures)" :
         usingFastAutoCalculation ?
         "Auto Fast · " + autoCalculationSymbol :
         accurateCalculationUnavailable ? "Auto Accurate unavailable" :
         "Auto Accurate · " + autoCalculationSymbol

    table.cell(dashboard, 0, 1, "Mode", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 1, useManualMode ? "Manual" : autoModeText, bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 2, "Reference Price", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 2, formatPrice(validReference ? referencePrice : na), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 3, "Current Price", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 3, formatPrice(close), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 4, "CME Limit Up", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 4, formatPrice(officialLimitUp), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 5, "CME Limit Down", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 5, formatPrice(officialLimitDown), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 6, "Prop Warning Up", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 6, formatPrice(propWarningUp), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 7, "Prop Warning Down", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 7, formatPrice(propWarningDown), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 8, "Distance to CME Up", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 8, formatDistance(distanceOfficialUpPoints, distanceOfficialUpPercent), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 9, "Distance to CME Down", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 9, formatDistance(distanceOfficialDownPoints, distanceOfficialDownPercent), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 10, "Distance to Prop Up", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 10, formatDistance(distancePropUpPoints, distancePropUpPercent), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 11, "Distance to Prop Down", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 11, formatDistance(distancePropDownPoints, distancePropDownPercent), bgcolor = panelValueColor, text_color = panelTextColor, text_size = dashboardTextSize)

    table.cell(dashboard, 0, 12, "Status", bgcolor = panelNameColor, text_color = panelTextColor, text_size = dashboardTextSize)
    table.cell(dashboard, 1, 12, currentStatus, bgcolor = statusColor, text_color = panelTextColor, text_size = dashboardTextSize)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------

// Alerts are exposed only through TradingView's official manual alert workflow:
// create an alert from the chart and select one of this indicator's conditions.
// No script setting is used to enable or disable alert availability.
//
// Use the current bar's traded range so an intrabar touch or gap into a zone
// is detected even when the bar closes back outside it. Requiring the previous
// close to be outside the level prevents alerts on every bar that remains in
// the same zone. On realtime bars these conditions become true as soon as the
// live high/low reaches the relevant level.
bool enteredPropUpZone = not na(propWarningUp) and
     not na(close[1]) and (close[1] < propWarningUp or open < propWarningUp) and high >= propWarningUp

bool enteredPropDownZone = not na(propWarningDown) and
     not na(close[1]) and (close[1] > propWarningDown or open > propWarningDown) and low <= propWarningDown

bool reachedOfficialUp = not na(officialLimitUp) and
     not na(close[1]) and (close[1] < officialLimitUp or open < officialLimitUp) and high >= officialLimitUp

bool reachedOfficialDown = not na(officialLimitDown) and
     not na(close[1]) and (close[1] > officialLimitDown or open > officialLimitDown) and low <= officialLimitDown

bool enteredPropZone = enteredPropUpZone or enteredPropDownZone
bool reachedOfficialLimit = reachedOfficialUp or reachedOfficialDown

alertcondition(
     enteredPropZone,
     title = "Entered Prop-Firm Warning Zone",
     message = "{{ticker}} price has entered a prop-firm customised warning zone. Current price: {{close}}.")

alertcondition(
     reachedOfficialLimit,
     title = "Reached/Breached Official CME Limit",
     message = "{{ticker}} price has reached or breached an official CME limit. Current price: {{close}}.")
````
