<!-- tradingview-pine-id: PUB;7207e61f8e9e4861880f47d041e311f3 -->
<!-- tradingviewscripts-format: 1 -->
# RTH + Overnight VWAP Deviation Bands v1

Source: https://www.tradingview.com/script/qWPaCtlP-RTH-Overnight-VWAP-with-Deviation-Bands/

## Description

Includes:

RTH VWAP: 9:30 AM–4:00 PM ET
Overnight VWAP: 6:00 PM–9:30 AM ET
Independently toggleable sessions
Toggleable ±1 and ±2 deviation bands
Optional band fills
Optional session background shading
Custom session times, days, timezone, colors, and line width

---

## Source Code

````pine
//@version=6
indicator("RTH + Overnight VWAP Deviation Bands v1", shorttitle = "RTH/ON VWAP Bands", overlay = true)

//=============================================================================
// INPUTS
//=============================================================================

const string GROUP_GENERAL   = "1. General"
const string GROUP_RTH       = "2. RTH Session"
const string GROUP_OVERNIGHT = "3. Overnight Session"
const string GROUP_BANDS     = "4. Deviation Bands"
const string GROUP_STYLE     = "5. Style"

string sessionTimezone = input.string(
     "America/New_York", "Session timezone",
     options = ["America/New_York", "America/Chicago", "Etc/UTC"],
     group = GROUP_GENERAL
 )
float source = input.source(hlc3, "VWAP source", group = GROUP_GENERAL)

bool showRth = input.bool(true, "Show RTH VWAP", group = GROUP_RTH)
string rthHours = input.session("0930-1600", "RTH hours", group = GROUP_RTH)
string rthDays = input.string("23456", "RTH days", group = GROUP_RTH, tooltip = "Monday-Friday = 23456")
bool shadeRthSession = input.bool(false, "Shade RTH session", group = GROUP_RTH)

bool showOvernight = input.bool(true, "Show overnight VWAP", group = GROUP_OVERNIGHT)
string overnightHours = input.session("1800-0930", "Overnight hours", group = GROUP_OVERNIGHT)
string overnightDays = input.string("1234567", "Overnight days", group = GROUP_OVERNIGHT, tooltip = "Includes Sunday evening futures trading.")
bool shadeOvernightSession = input.bool(false, "Shade overnight session", group = GROUP_OVERNIGHT)

bool showBand1 = input.bool(true, "Show Band 1", inline = "b1", group = GROUP_BANDS)
float band1Multiplier = input.float(1.0, "Multiplier", minval = 0.1, step = 0.1, inline = "b1", group = GROUP_BANDS)
bool fillBand1 = input.bool(true, "Fill Band 1", group = GROUP_BANDS)
bool showBand2 = input.bool(false, "Show Band 2", inline = "b2", group = GROUP_BANDS)
float band2Multiplier = input.float(2.0, "Multiplier", minval = 0.1, step = 0.1, inline = "b2", group = GROUP_BANDS)

color rthVwapColor = input.color(color.rgb(255, 193, 7), "RTH VWAP", inline = "rth", group = GROUP_STYLE)
color rthBandColor = input.color(color.rgb(0, 188, 212), "Bands", inline = "rth", group = GROUP_STYLE)
color overnightVwapColor = input.color(color.rgb(171, 71, 188), "Overnight VWAP", inline = "on", group = GROUP_STYLE)
color overnightBandColor = input.color(color.rgb(126, 87, 194), "Bands", inline = "on", group = GROUP_STYLE)
int vwapWidth = input.int(2, "VWAP line width", minval = 1, maxval = 5, group = GROUP_STYLE)

//=============================================================================
// SESSION FLAGS
//=============================================================================

string rthSession = rthHours + ":" + rthDays
string overnightSession = overnightHours + ":" + overnightDays

bool inRth = not na(time(timeframe.period, rthSession, sessionTimezone))
bool inOvernight = not na(time(timeframe.period, overnightSession, sessionTimezone))
bool newRth = inRth and not inRth[1]
bool newOvernight = inOvernight and not inOvernight[1]

//=============================================================================
// RTH VWAP + VOLUME-WEIGHTED STANDARD DEVIATION
// Replaces the current bar's contribution on realtime updates so volume is not
// counted more than once while a candle is still forming.
//=============================================================================

var float rthVolumeSum = 0.0
var float rthPriceVolumeSum = 0.0
var float rthPriceSquaredVolumeSum = 0.0
var int rthLastBar = na
var float rthLastVolume = 0.0
var float rthLastPriceVolume = 0.0
var float rthLastPriceSquaredVolume = 0.0

if newRth
    rthVolumeSum := 0.0
    rthPriceVolumeSum := 0.0
    rthPriceSquaredVolumeSum := 0.0
    rthLastBar := na
    rthLastVolume := 0.0
    rthLastPriceVolume := 0.0
    rthLastPriceSquaredVolume := 0.0

if inRth
    bool firstRthUpdateThisBar = na(rthLastBar) or bar_index != rthLastBar
    if not firstRthUpdateThisBar
        rthVolumeSum -= rthLastVolume
        rthPriceVolumeSum -= rthLastPriceVolume
        rthPriceSquaredVolumeSum -= rthLastPriceSquaredVolume

    float currentVolume = nz(volume, 0.0)
    float currentPriceVolume = source * currentVolume
    float currentPriceSquaredVolume = source * source * currentVolume

    rthVolumeSum += currentVolume
    rthPriceVolumeSum += currentPriceVolume
    rthPriceSquaredVolumeSum += currentPriceSquaredVolume
    rthLastBar := bar_index
    rthLastVolume := currentVolume
    rthLastPriceVolume := currentPriceVolume
    rthLastPriceSquaredVolume := currentPriceSquaredVolume

float rthVwap = inRth and rthVolumeSum > 0.0 ? rthPriceVolumeSum / rthVolumeSum : na
float rthVariance = inRth and rthVolumeSum > 0.0 ? math.max(rthPriceSquaredVolumeSum / rthVolumeSum - rthVwap * rthVwap, 0.0) : na
float rthStdDev = not na(rthVariance) ? math.sqrt(rthVariance) : na

//=============================================================================
// OVERNIGHT VWAP + VOLUME-WEIGHTED STANDARD DEVIATION
//=============================================================================

var float overnightVolumeSum = 0.0
var float overnightPriceVolumeSum = 0.0
var float overnightPriceSquaredVolumeSum = 0.0
var int overnightLastBar = na
var float overnightLastVolume = 0.0
var float overnightLastPriceVolume = 0.0
var float overnightLastPriceSquaredVolume = 0.0

if newOvernight
    overnightVolumeSum := 0.0
    overnightPriceVolumeSum := 0.0
    overnightPriceSquaredVolumeSum := 0.0
    overnightLastBar := na
    overnightLastVolume := 0.0
    overnightLastPriceVolume := 0.0
    overnightLastPriceSquaredVolume := 0.0

if inOvernight
    bool firstOvernightUpdateThisBar = na(overnightLastBar) or bar_index != overnightLastBar
    if not firstOvernightUpdateThisBar
        overnightVolumeSum -= overnightLastVolume
        overnightPriceVolumeSum -= overnightLastPriceVolume
        overnightPriceSquaredVolumeSum -= overnightLastPriceSquaredVolume

    float currentVolume = nz(volume, 0.0)
    float currentPriceVolume = source * currentVolume
    float currentPriceSquaredVolume = source * source * currentVolume

    overnightVolumeSum += currentVolume
    overnightPriceVolumeSum += currentPriceVolume
    overnightPriceSquaredVolumeSum += currentPriceSquaredVolume
    overnightLastBar := bar_index
    overnightLastVolume := currentVolume
    overnightLastPriceVolume := currentPriceVolume
    overnightLastPriceSquaredVolume := currentPriceSquaredVolume

float overnightVwap = inOvernight and overnightVolumeSum > 0.0 ? overnightPriceVolumeSum / overnightVolumeSum : na
float overnightVariance = inOvernight and overnightVolumeSum > 0.0 ? math.max(overnightPriceSquaredVolumeSum / overnightVolumeSum - overnightVwap * overnightVwap, 0.0) : na
float overnightStdDev = not na(overnightVariance) ? math.sqrt(overnightVariance) : na

//=============================================================================
// LEVELS
//=============================================================================

float rthUpper1 = rthVwap + rthStdDev * band1Multiplier
float rthLower1 = rthVwap - rthStdDev * band1Multiplier
float rthUpper2 = rthVwap + rthStdDev * band2Multiplier
float rthLower2 = rthVwap - rthStdDev * band2Multiplier

float overnightUpper1 = overnightVwap + overnightStdDev * band1Multiplier
float overnightLower1 = overnightVwap - overnightStdDev * band1Multiplier
float overnightUpper2 = overnightVwap + overnightStdDev * band2Multiplier
float overnightLower2 = overnightVwap - overnightStdDev * band2Multiplier

//=============================================================================
// PLOTS
//=============================================================================

plot(showRth ? rthVwap : na, "RTH VWAP", color = rthVwapColor, linewidth = vwapWidth)
rthUpper1Plot = plot(showRth and showBand1 ? rthUpper1 : na, "RTH Upper Band 1", color = rthBandColor)
rthLower1Plot = plot(showRth and showBand1 ? rthLower1 : na, "RTH Lower Band 1", color = rthBandColor)
plot(showRth and showBand2 ? rthUpper2 : na, "RTH Upper Band 2", color = color.new(rthBandColor, 30))
plot(showRth and showBand2 ? rthLower2 : na, "RTH Lower Band 2", color = color.new(rthBandColor, 30))
fill(rthUpper1Plot, rthLower1Plot, color = showRth and showBand1 and fillBand1 ? color.new(rthBandColor, 91) : na, title = "RTH Band 1 Fill")

plot(showOvernight ? overnightVwap : na, "Overnight VWAP", color = overnightVwapColor, linewidth = vwapWidth)
overnightUpper1Plot = plot(showOvernight and showBand1 ? overnightUpper1 : na, "Overnight Upper Band 1", color = overnightBandColor)
overnightLower1Plot = plot(showOvernight and showBand1 ? overnightLower1 : na, "Overnight Lower Band 1", color = overnightBandColor)
plot(showOvernight and showBand2 ? overnightUpper2 : na, "Overnight Upper Band 2", color = color.new(overnightBandColor, 30))
plot(showOvernight and showBand2 ? overnightLower2 : na, "Overnight Lower Band 2", color = color.new(overnightBandColor, 30))
fill(overnightUpper1Plot, overnightLower1Plot, color = showOvernight and showBand1 and fillBand1 ? color.new(overnightBandColor, 92) : na, title = "Overnight Band 1 Fill")

color sessionShade = shadeRthSession and inRth ? color.new(rthBandColor, 95) : shadeOvernightSession and inOvernight ? color.new(overnightBandColor, 95) : na
bgcolor(sessionShade, title = "Session shading")
````
