# VV Control Levels Analyzer

- url: https://www.tradingview.com/script/UPJVQhqJ-VV-Control-Levels-Analyzer/
- type: indicator
- pine_id: PUB;349131b1c4a94b5fa2efa2c5b354fc67
- version: 2.0

## Description

VV Control Levels Analyzer

VV Control Levels Analyzer is a control-level analysis indicator designed to help traders evaluate where price is positioned relative to major volume and VWAP reference levels.

The indicator studies four main control references:

1. Daily POC
2. Weekly POC
3. Monthly POC
4. Anchored VWAP Gate Line

It then summarizes the relationship between price and those levels in a clean technical dashboard.

This script is an indicator, not a strategy. It does not place trades, does not calculate backtest results, and does not provide guaranteed buy or sell signals. Its purpose is to organize important control-level information on the chart so users can make their own analysis.

Overview

The main idea behind VV Control Levels Analyzer is that price location relative to high-volume control levels can provide useful market context.

When price is above most control levels, the chart may be showing stronger acceptance above value.
When price is below most control levels, the chart may be showing weaker acceptance below value.
When price is close to one or more control levels, the market may be testing an important decision area.

The indicator does not predict future price movement. It shows where price is trading relative to selected control references.

Main components

1. Daily, Weekly, and Monthly POC

The script calculates an approximate Point of Control for the previous completed Daily, Weekly, and Monthly periods.

POC means Point of Control. It represents the price area with the highest estimated volume within the selected period.

The indicator calculates POC internally by:

* storing period price and volume data,
* dividing the price range into volume rows,
* distributing volume into those rows,
* selecting the row with the highest accumulated volume.

The POC calculation is an approximation based on available chart data. It is not intended to exactly duplicate exchange-native or broker-native volume profile tools.

The Daily, Weekly, and Monthly POC values are shown in the dashboard. The active POC line can also be plotted on the chart if the user enables it from settings.

By default, the POC line is hidden to keep the chart clean. However, the POC logic remains active even when the line is hidden.

2. Active POC Line

The user can choose which POC period is displayed on the chart:

* Daily
* Weekly
* Monthly

The displayed POC line is optional. It can be enabled or disabled from the settings.

Bar coloring can still use the active POC even when the POC line itself is hidden.

The active POC is used to color candles as:

* above POC,
* below POC,
* crossing POC.

This is visual context only and should not be treated as a standalone entry or exit signal.

3. VWAP Gate Line

The indicator calculates a VWAP Gate from a selected anchor period:

* Daily
* Weekly
* Monthly

The main VWAP Gate Line is shown by default. It represents the central VWAP reference from the selected period.

The script also calculates optional upper and lower VWAP gates using standard deviation around the VWAP.

The optional gates are:

* Upper Gate 1
* Upper Gate 2
* Lower Gate 1
* Lower Gate 2

By default, only the main VWAP line is shown to reduce chart clutter. Users can disable “Show Only Main VWAP Line” to display the additional upper and lower gate levels.

4. VWAP Standard Deviation Gates

The upper and lower VWAP gates are calculated using the selected standard deviation multipliers.

First Gate Multiplier controls the first deviation band.
Second Gate Multiplier controls the second deviation band.

These levels can help users identify areas where price is stretched above or below the selected VWAP period.

These gates are reference levels only. They are not automatic reversal or breakout signals.

5. Smart Control Logic

The indicator evaluates price against four control references:

* Daily POC
* Weekly POC
* Monthly POC
* VWAP Gate Line

It counts how many of these levels price is currently above.

The result is displayed as Control Strength:

0/4 = price is below all four control references
1/4 = price is above one control reference
2/4 = price is above two control references
3/4 = price is above three control references
4/4 = price is above all four control references

This control count is used to create the dashboard status.

Dashboard status explained

Very Bullish
Price is above all four control references and is not too close to a control level.

Bullish
Price is above most control references and is not too close to a control level.

Neutral
Price is around the middle of the control structure or near a control level.

Recovery Watch
Price is near a control level after weakness. This may indicate that price is testing an area where recovery could be studied, but it is not a buy signal.

Breakout Watch
Price is near a control level and trading above or near the VWAP Gate. This may indicate that price is testing control resistance, but it is not a breakout confirmation by itself.

Breakdown Risk
Price is near a control area but below the VWAP Gate or important control references. This may indicate weakness around control levels, but it is not a short signal by itself.

Bearish
Price is below most control references.

Very Bearish
Price is below all four control references and is not too close to a control level.

Trend reading

The script also provides a simple trend reading:

Up
Price is above both Weekly POC and Monthly POC.

Down
Price is below both Weekly POC and Monthly POC.

Sideways
Price is mixed between Weekly and Monthly POC references.

This trend field is a broad context reading only. It should not be treated as a complete trend-following system.

Nearest Control

The dashboard identifies the nearest control level to current price among:

* Daily POC
* Weekly POC
* Monthly POC
* VWAP Gate

It also shows the distance from current price to that nearest control level as a percentage.

If price is within the selected Neutral Distance %, the dashboard treats price as being near a control area.

Volume Ratio

The script calculates a volume ratio by comparing current volume with a 20-period average volume.

Volume Ratio = Current Volume / 20-period Average Volume

The dashboard highlights volume strength based on the selected Strong Volume Ratio setting.

Strong volume means current volume is above the selected threshold.
Weak or normal volume means current volume has not reached that threshold.

Volume is used as context only. It does not validate a trade by itself.

Technical Analysis Dashboard

The dashboard displays:

Symbol
Shows the current ticker.

Current Price
Shows the latest close price.

Status
Shows the smart control state, such as Very Bullish, Neutral, Breakout Watch, or Breakdown Risk.

Trend
Shows Up, Down, or Sideways based on Weekly and Monthly POC position.

Current Volume
Shows the current chart volume.

Volume Ratio
Compares current volume with its recent 20-period average.

Daily POC
Shows the calculated Daily POC.

Weekly POC
Shows the calculated Weekly POC.

Monthly POC
Shows the calculated Monthly POC.

Upper Zone
Shows the first upper VWAP deviation gate.

VWAP Gate Line
Shows the main VWAP gate value.

Lower Zone
Shows the first lower VWAP deviation gate.

Control Strength
Shows how many of the four control references price is currently above.

Nearest Control
Shows the closest control reference to current price.

Distance
Shows percentage distance from price to the nearest control level.

Settings explained

Volume Profile / POC Settings

Show POC Line
Shows or hides the active POC line. The POC remains active in the dashboard and logic even when hidden.

POC Base Color
Controls the color of the active POC line.

POC Transparency
Controls how visible or soft the POC line appears.

POC Line Width
Controls the thickness of the active POC line.

Above POC Bar
Color used when price closes above the active POC.

Below POC Bar
Color used when price closes below the active POC.

POC Cross Bar
Color used when price crosses the active POC.

Displayed POC Period
Selects which POC period is displayed as the active POC line: Daily, Weekly, or Monthly.

Color Bars by POC
Colors candles according to price position relative to the active POC.

Volume Resolution Rows
Controls how many rows are used in the internal POC approximation. Higher values may provide more detail but can require more processing.

VWAP Gate Settings

Show VWAP Gate
Enables or disables VWAP gate plotting.

Show Only Main VWAP Line
When enabled, only the central VWAP Gate Line is shown. When disabled, upper and lower deviation gates are also shown.

Main VWAP Line
Controls the color of the main VWAP line.

Main VWAP Line Width
Controls the thickness of the main VWAP line.

Optional Gate Lines
Controls the color of the optional upper and lower VWAP gates.

Fill Optional Gate Zones
Fills the space between optional VWAP deviation gates. This is disabled by default for a cleaner chart.

VWAP Gate Period
Selects the anchor period used for the VWAP calculation: Daily, Weekly, or Monthly.

First Gate Multiplier
Controls the first standard deviation level around VWAP.

Second Gate Multiplier
Controls the second standard deviation level around VWAP.

Smart Control Logic

Neutral Distance %
Defines how close price must be to a control level to be treated as a neutral or control-test area.

Strong Volume Ratio
Defines the volume ratio threshold used to classify current volume as strong.

Use Volume in Optional Status Label
Adds volume context to the optional chart label.

Technical Analysis Table

Show Table
Shows or hides the technical dashboard.

Table Position
Controls where the dashboard appears on the chart.

Table Size
Controls the dashboard text size.

Show Optional Status Label
Shows a compact chart label with the current VV Analyzer status.

Optional Label Size
Controls the size of the optional status label.

Optional Label Distance
Controls how far the optional label is placed from the latest candle using ATR.

How to use this indicator

A practical workflow:

1. Check the dashboard Status.
2. Review Control Strength to see how many major control levels price is above.
3. Check the Trend field for broad context.
4. Identify the Nearest Control level and distance.
5. Watch price behavior around the VWAP Gate Line and the nearest POC.
6. Use Volume Ratio as supporting context.
7. Combine this information with your own market structure, risk management, and trading plan.

Example interpretation

If price is above Daily POC, Weekly POC, Monthly POC, and VWAP Gate, the dashboard may show Very Bullish. This means price is accepted above all selected control references. It does not mean price must continue upward.

If price is below most control references, the dashboard may show Bearish or Very Bearish. This means price is trading below important control levels. It does not mean price must continue downward.

If price is close to a POC or VWAP Gate, the dashboard may show Breakout Watch, Recovery Watch, Breakdown Risk, or Neutral. This means price is testing a control area and needs further confirmation from the user’s own analysis.

Alerts

The script includes alerts for:

VV Very Bullish
Price is above all control levels.

VV Bullish
Price is above most control levels.

VV Recovery Watch
Price is near a control level after weakness.

VV Breakout Watch
Price is testing control resistance.

VV Breakdown Risk
Price is below VWAP or a key control area.

VV Very Bearish
Price is below all control levels.

These alerts are classification alerts only. They do not instruct the user to buy or sell.

Important limitations

This indicator does not predict future price movement.

It does not provide buy or sell signals.

It does not place strategy orders.

It does not provide backtesting results.

POC values are internally approximated from available chart price and volume data.

VWAP gates are calculated from the selected period and may differ from other VWAP tools depending on method and data source.

Daily, Weekly, and Monthly values are based on completed periods and update when a new period begins.

Volume quality can differ between markets, symbols, and data providers.

The dashboard status is a contextual classification, not a trade recommendation.

Recommended use

VV Control Levels Analyzer is best used as a decision-support tool for traders who study:

* Point of Control
* VWAP
* volume-based control levels
* price acceptance above or below value
* distance from key control levels
* volume confirmation
* multi-timeframe control context

It is designed for visual market context, not automated trading, not guaranteed signal generation, and not financial advice.

Originality and purpose

VV Control Levels Analyzer combines multi-timeframe POC, anchored VWAP gates, volume ratio, nearest control distance, bar coloring, and a smart technical dashboard into one clean control-level framework.

The purpose of combining these components is to help traders quickly understand whether price is above, below, or testing important volume and VWAP reference levels.

The script is intended to reduce chart clutter by showing the main VWAP gate by default, hiding the POC line by default, and placing the detailed control information inside the dashboard.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
// ============================================================================
//  VV Control Levels Analyzer
//  POC + Auto VWAP Gate + Smart Control Dashboard
//
//  Analytical indicator, not a backtesting strategy.
//
//  Main improvements:
//    - VWAP Gate Period can work in Auto Mode.
//    - Displayed POC Period can now work in Auto Mode.
//    - Auto Mode logic for VWAP and POC:
//          Intraday charts  -> Daily VWAP / Daily POC
//          Daily charts     -> Weekly VWAP / Weekly POC
//          Weekly charts    -> Monthly VWAP / Monthly POC
//          Monthly charts   -> Monthly VWAP / Monthly POC
//
//    - Added Action Bias to make the reading easier:
//          No Buy Below VWAP
//          Watch VWAP Reclaim
//          Bounce - Need VWAP
//          VWAP Reclaim
//          Bullish Control
//          Breakdown Below Lower
//
//    - Added VWAP Reclaim, VWAP Lost, Lower Bounce, and Breakdown logic.
//    - Improved Recovery Watch logic so it does not appear too early.
//    - Cleaner dashboard with direct decision guidance.
// ============================================================================

indicator("VV Control Levels Analyzer", "VV Analyzer", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 50)


// ============================================================================
//  Inputs
// ============================================================================

// --- Volume Profile / POC group ---
grpVP = "Volume Profile / POC Settings"

showPOCLine = input.bool(false, "Show POC Line", group = grpVP,
     tooltip = "Show or hide the active POC line on the chart. Disabled by default for a cleaner chart. The POC is still used in the table and smart logic even when hidden.")

pocBaseCol = input.color(#ff9800, "POC Base Color", group = grpVP,
     tooltip = "Base color of the active POC line.")

pocTransparency = input.int(25, "POC Transparency", minval = 0, maxval = 90, group = grpVP,
     tooltip = "Transparency of the POC line. Higher values make the line softer and less visually aggressive.")

pocWidth = input.int(2, "POC Line Width", minval = 1, maxval = 5, group = grpVP,
     tooltip = "Thickness of the active POC line.")

vpUp = input.color(color.new(color.lime, 0), "Above POC Bar", group = grpVP,
     tooltip = "Bar color when price closes above the active POC.")

vpDn = input.color(color.new(color.red, 0), "Below POC Bar", group = grpVP,
     tooltip = "Bar color when price closes below the active POC.")

vpAt = input.color(color.new(color.yellow, 0), "POC Cross Bar", group = grpVP,
     tooltip = "Bar color when price crosses the active POC.")

pocTFMode = input.string("Auto", "Displayed POC Period Mode",
     options = ["Auto", "Daily", "Weekly", "Monthly"], group = grpVP,
     tooltip = "Auto mode selects the displayed POC period based on the chart timeframe: intraday charts use Daily POC, Daily charts use Weekly POC, Weekly and Monthly charts use Monthly POC.")

recolorBars = input.bool(true, "Color Bars by POC", group = grpVP,
     tooltip = "Color candles based on price position relative to the active POC. This works even when the POC line is hidden.")

vpRes = input.int(60, "Volume Resolution Rows", minval = 10, maxval = 300, group = grpVP,
     tooltip = "Number of price rows used to approximate the POC. Higher values are more precise but may be slower.")


// --- Gates / VWAP group ---
grpG = "VWAP Gate Settings"

showG = input.bool(true, "Show VWAP Gate", group = grpG,
     tooltip = "Enable or disable VWAP gate levels.")

showMainVWAPOnly = input.bool(true, "Show Only Main VWAP Line", group = grpG,
     tooltip = "When enabled, only the main VWAP gate line is shown. Disable it to show upper/lower gate levels.")

gColMid = input.color(color.new(color.blue, 0), "Main VWAP Line", group = grpG,
     tooltip = "Color of the central VWAP gate line.")

gMidWidth = input.int(2, "Main VWAP Line Width", minval = 1, maxval = 5, group = grpG,
     tooltip = "Thickness of the main VWAP line.")

gColZone = input.color(color.new(color.blue, 55), "Optional Gate Lines", group = grpG,
     tooltip = "Color of optional upper and lower VWAP gate lines.")

showZoneFill = input.bool(false, "Fill Optional Gate Zones", group = grpG,
     tooltip = "Fill the area between optional VWAP deviation gates. Disabled by default for chart clarity.")

gateTFMode = input.string("Auto", "VWAP Gate Period Mode",
     options = ["Auto", "Daily", "Weekly", "Monthly"], group = grpG,
     tooltip = "Auto mode selects the VWAP gate period based on the chart timeframe: intraday charts use Daily VWAP, Daily charts use Weekly VWAP, Weekly and Monthly charts use Monthly VWAP.")

gMult1 = input.float(1.0, "First Gate Multiplier", minval = 0.1, step = 0.1, group = grpG,
     tooltip = "First standard deviation multiplier around VWAP.")

gMult2 = input.float(2.0, "Second Gate Multiplier", minval = 0.1, step = 0.1, group = grpG,
     tooltip = "Second standard deviation multiplier around VWAP.")


// --- Smart logic group ---
grpS = "Smart Control Logic"

neutralPct = input.float(0.75, "Neutral Distance %", minval = 0.1, maxval = 5.0, step = 0.05, group = grpS,
     tooltip = "If price is within this percentage from a control level, the indicator treats it as a neutral/control test area instead of strong bullish or bearish.")

strongVolRatio = input.float(1.50, "Strong Volume Ratio", minval = 0.5, step = 0.1, group = grpS,
     tooltip = "Volume ratio threshold used to classify volume as strong.")

useVolumeInSignal = input.bool(true, "Use Volume in Optional Status Label", group = grpS,
     tooltip = "Include volume confirmation or weak-volume warning in the optional status label.")

requireVolumeForReclaim = input.bool(false, "Require Strong Volume for VWAP Reclaim", group = grpS,
     tooltip = "When enabled, VWAP Reclaim signals require volume ratio to be equal to or above the Strong Volume Ratio setting.")


// --- Technical analysis table group ---
grpT = "Technical Analysis Table"

showTbl = input.bool(true, "Show Table", group = grpT,
     tooltip = "Show or hide the technical analysis dashboard.")

tblPos = input.string("Top Right", "Table Position",
     options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = grpT,
     tooltip = "Position of the technical analysis table on the chart.")

tblSize = input.string("Normal", "Table Size",
     options = ["Small", "Normal", "Large"], group = grpT,
     tooltip = "Font size of the technical analysis table.")

showSignal = input.bool(false, "Show Optional Status Label", group = grpT,
     tooltip = "Show or hide the optional status label on the chart. Disabled by default to keep the chart clean.")

signalBoxSize = input.string("Small", "Optional Label Size",
     options = ["Tiny", "Small", "Normal"], group = grpT,
     tooltip = "Size of the optional status label text.")

signalOffsetAtr = input.float(0.80, "Optional Label Distance", minval = 0.1, step = 0.1, group = grpT,
     tooltip = "Vertical distance of the optional status label from the latest candle, based on ATR.")


// ============================================================================
//  Helper Functions
// ============================================================================

f_tfLabel(string tf) =>
    tf == "D" ? "Daily" :
     tf == "W" ? "Weekly" :
     tf == "M" ? "Monthly" :
     tf

f_pos(string p) =>
    p == "Top Right" ? position.top_right :
     p == "Bottom Right" ? position.bottom_right :
     p == "Top Left" ? position.top_left :
     position.bottom_left

f_txtSize(string s) =>
    s == "Small" ? size.small :
     s == "Large" ? size.large :
     size.normal

f_labelSize(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Normal" ? size.normal :
     size.small

f_fmt(float x) =>
    na(x) ? "-" : str.tostring(x, format.mintick)

f_pctDistance(float price, float level) =>
    na(level) or level == 0.0 ? na : math.abs(price - level) / level * 100.0

f_near(float price, float level, float pct) =>
    d = f_pctDistance(price, level)
    not na(d) and d <= pct


// Approximate POC from stored price/volume arrays
f_poc(float[] prices, float[] vols, int res) =>
    n = array.size(prices)
    float poc = na

    if n > 0
        lo = array.min(prices)
        hi = array.max(prices)

        if hi == lo
            poc := array.get(prices, 0)
        else
            binW = (hi - lo) / res
            hist = array.new_float(res, 0.0)

            for i = 0 to n - 1
                p = array.get(prices, i)
                v = array.get(vols, i)
                idx = math.min(res - 1, math.max(0, int(math.floor((p - lo) / binW))))
                array.set(hist, idx, array.get(hist, idx) + v)

            mx = -1.0
            mi = 0

            for b = 0 to res - 1
                cur = array.get(hist, b)
                if cur > mx
                    mx := cur
                    mi := b

            poc := lo + (mi + 0.5) * binW

    poc


// Stable period POC from last completed period
f_periodPOC(string tf, int res) =>
    var float[] _p = array.new_float()
    var float[] _v = array.new_float()
    var float _active = na

    bool _isNew = ta.change(time(tf)) != 0

    if _isNew and array.size(_p) > 0
        _active := f_poc(_p, _v, res)
        array.clear(_p)
        array.clear(_v)

    array.push(_p, hlc3)
    array.push(_v, math.max(volume, 0))

    _active


// Stable VWAP and standard deviation from last completed period
f_periodVWAP(string tf) =>
    var float _sumPV = 0.0
    var float _sumV = 0.0
    var float _sumP2V = 0.0
    var float _vw = na
    var float _sd = na

    bool _isNew = ta.change(time(tf)) != 0

    if _isNew and _sumV > 0
        _vw := _sumPV / _sumV
        variance = _sumP2V / _sumV - _vw * _vw
        _sd := variance > 0 ? math.sqrt(variance) : 0.0

        _sumPV := 0.0
        _sumV := 0.0
        _sumP2V := 0.0

    v = math.max(volume, 0)
    _sumPV += hlc3 * v
    _sumV += v
    _sumP2V += hlc3 * hlc3 * v

    [_vw, _sd]


// ============================================================================
//  Auto Timeframe Selection
// ============================================================================

autoControlTF =
     timeframe.isintraday ? "D" :
     timeframe.isdaily ? "W" :
     timeframe.isweekly ? "M" :
     "M"

manualGateTF =
     gateTFMode == "Daily" ? "D" :
     gateTFMode == "Weekly" ? "W" :
     gateTFMode == "Monthly" ? "M" :
     autoControlTF

selectedGateTF = gateTFMode == "Auto" ? autoControlTF : manualGateTF

selectedGateLabel =
     gateTFMode == "Auto" ? "Auto → " + f_tfLabel(selectedGateTF) :
     f_tfLabel(selectedGateTF)


manualPOCTF =
     pocTFMode == "Daily" ? "D" :
     pocTFMode == "Weekly" ? "W" :
     pocTFMode == "Monthly" ? "M" :
     autoControlTF

selectedPOCTF = pocTFMode == "Auto" ? autoControlTF : manualPOCTF

selectedPOCLabel =
     pocTFMode == "Auto" ? "Auto → " + f_tfLabel(selectedPOCTF) :
     f_tfLabel(selectedPOCTF)


// ============================================================================
//  Calculations
// ============================================================================

// POC levels
pocD = f_periodPOC("D", vpRes)
pocW = f_periodPOC("W", vpRes)
pocM = f_periodPOC("M", vpRes)

activePOC =
     selectedPOCTF == "D" ? pocD :
     selectedPOCTF == "W" ? pocW :
     pocM


// VWAP gates
[gvw, gsd] = f_periodVWAP(selectedGateTF)

gUp2 = gvw + gMult2 * gsd
gUp1 = gvw + gMult1 * gsd
gMid = gvw
gDn1 = gvw - gMult1 * gsd
gDn2 = gvw - gMult2 * gsd


// Volume ratio
volAvg = ta.sma(volume, 20)
volRatio = na(volAvg) or volAvg == 0.0 ? na : volume / volAvg
strongVol = not na(volRatio) and volRatio >= strongVolRatio
validReclaimVolume = not requireVolumeForReclaim or strongVol


// Price position
aboveD = not na(pocD) and close > pocD
aboveW = not na(pocW) and close > pocW
aboveM = not na(pocM) and close > pocM
aboveVWAP = not na(gMid) and close > gMid

belowD = not na(pocD) and close < pocD
belowW = not na(pocW) and close < pocW
belowM = not na(pocM) and close < pocM
belowVWAP = not na(gMid) and close < gMid

aboveCount = (aboveD ? 1 : 0) + (aboveW ? 1 : 0) + (aboveM ? 1 : 0) + (aboveVWAP ? 1 : 0)


// Near-control logic
nearD = f_near(close, pocD, neutralPct)
nearW = f_near(close, pocW, neutralPct)
nearM = f_near(close, pocM, neutralPct)
nearVWAP = f_near(close, gMid, neutralPct)
nearLowerZone = f_near(close, gDn1, neutralPct)
nearUpperZone = f_near(close, gUp1, neutralPct)

nearAnyControl = nearD or nearW or nearM or nearVWAP or nearLowerZone or nearUpperZone


// Nearest control level
distD = f_pctDistance(close, pocD)
distW = f_pctDistance(close, pocW)
distM = f_pctDistance(close, pocM)
distV = f_pctDistance(close, gMid)
distU = f_pctDistance(close, gUp1)
distL = f_pctDistance(close, gDn1)

float nearestDist = na
string nearestName = "-"

if not na(distD)
    nearestDist := distD
    nearestName := "Daily POC"

if not na(distW) and (na(nearestDist) or distW < nearestDist)
    nearestDist := distW
    nearestName := "Weekly POC"

if not na(distM) and (na(nearestDist) or distM < nearestDist)
    nearestDist := distM
    nearestName := "Monthly POC"

if not na(distV) and (na(nearestDist) or distV < nearestDist)
    nearestDist := distV
    nearestName := "VWAP Gate"

if not na(distU) and (na(nearestDist) or distU < nearestDist)
    nearestDist := distU
    nearestName := "Upper Zone"

if not na(distL) and (na(nearestDist) or distL < nearestDist)
    nearestDist := distL
    nearestName := "Lower Zone"


// Trend status
trendUp = aboveW and aboveM
trendDown = belowW and belowM
trendText = trendUp ? "Up" : trendDown ? "Down" : "Sideways"


// ============================================================================
//  Improved Signal Logic
// ============================================================================

vwapReclaim = not na(gMid) and ta.crossover(close, gMid)
vwapLost = not na(gMid) and ta.crossunder(close, gMid)

vwapReclaimConfirmed = vwapReclaim and validReclaimVolume
vwapLostConfirmed = vwapLost

lowerZoneBounce = not na(gDn1) and low <= gDn1 and close > gDn1 and close > open
upperZoneReject = not na(gUp1) and high >= gUp1 and close < gUp1 and close < open

breakdownBelowLower = not na(gDn1) and close < gDn1 and close[1] >= gDn1
breakoutAboveUpper = not na(gUp1) and close > gUp1 and close[1] <= gUp1

dailyPOCReclaim = not na(pocD) and ta.crossover(close, pocD)
dailyPOCLost = not na(pocD) and ta.crossunder(close, pocD)

activePOCReclaim = not na(activePOC) and ta.crossover(close, activePOC)
activePOCLost = not na(activePOC) and ta.crossunder(close, activePOC)


// Smart state
veryBullish = aboveCount == 4 and not nearAnyControl
bullish = aboveCount == 3 and not nearAnyControl
neutral = aboveCount == 2 or nearAnyControl
bearish = aboveCount == 1 and not nearAnyControl
veryBearish = aboveCount == 0 and not nearAnyControl

recoveryWatch = lowerZoneBounce and belowVWAP
breakoutWatch = aboveVWAP and (vwapReclaimConfirmed or activePOCReclaim or breakoutAboveUpper)
breakdownRisk = belowVWAP and (breakdownBelowLower or vwapLostConfirmed or activePOCLost)


// Dashboard status
statusText =
     veryBullish ? "Very Bullish" :
     bullish ? "Bullish" :
     breakoutWatch ? "Breakout Watch" :
     recoveryWatch ? "Recovery Watch" :
     breakdownRisk ? "Breakdown Risk" :
     neutral ? "Neutral" :
     bearish ? "Bearish" :
     veryBearish ? "Very Bearish" :
     "Neutral"

statusColor =
     veryBullish or bullish or breakoutWatch ? color.new(color.green, 0) :
     veryBearish or bearish or breakdownRisk ? color.new(color.red, 0) :
     recoveryWatch ? color.new(color.orange, 0) :
     color.new(color.gray, 0)

controlText = str.tostring(aboveCount) + "/4"


// Action Bias
actionText =
     breakdownBelowLower ? "Breakdown Below Lower" :
     belowVWAP and lowerZoneBounce ? "Bounce - Need VWAP" :
     belowVWAP and nearVWAP ? "Watch VWAP Reclaim" :
     belowVWAP ? "No Buy Below VWAP" :
     vwapReclaimConfirmed ? "VWAP Reclaim" :
     aboveVWAP and activePOCLost ? "Watch Active POC" :
     aboveVWAP and close < activePOC ? "Watch Active POC" :
     aboveVWAP and close > activePOC and aboveCount >= 3 ? "Bullish Control" :
     aboveVWAP ? "Hold Above VWAP" :
     "Neutral"

actionColor =
     actionText == "Bullish Control" or actionText == "VWAP Reclaim" or actionText == "Hold Above VWAP" ? color.new(color.green, 0) :
     actionText == "Breakdown Below Lower" or actionText == "No Buy Below VWAP" ? color.new(color.red, 0) :
     color.new(color.orange, 0)


// Signal Now
signalNow =
     vwapReclaimConfirmed ? "VWAP Reclaim" :
     vwapLostConfirmed ? "VWAP Lost" :
     lowerZoneBounce ? "Lower Bounce" :
     upperZoneReject ? "Upper Reject" :
     breakdownBelowLower ? "Lower Breakdown" :
     breakoutAboveUpper ? "Upper Breakout" :
     activePOCReclaim ? "Active POC Reclaim" :
     activePOCLost ? "Active POC Lost" :
     "-"

signalNowColor =
     signalNow == "VWAP Reclaim" or signalNow == "Lower Bounce" or signalNow == "Upper Breakout" or signalNow == "Active POC Reclaim" ? color.new(color.green, 0) :
     signalNow == "VWAP Lost" or signalNow == "Upper Reject" or signalNow == "Lower Breakdown" or signalNow == "Active POC Lost" ? color.new(color.red, 0) :
     color.new(color.gray, 0)


// Bar coloring
barCross = not na(activePOC) and not na(activePOC[1]) and ((close - activePOC) * (close[1] - activePOC[1]) < 0)
barAbove = not na(activePOC) and close > activePOC
barColor = barCross ? vpAt : barAbove ? vpUp : vpDn


// ============================================================================
//  Plotting
// ============================================================================

pocCol = color.new(pocBaseCol, pocTransparency)

// Bar coloring is independent from POC line visibility.
barcolor(recolorBars ? barColor : na, title = "POC Bar Coloring")

// Optional gate visibility logic
showOptionalGates = showG and not showMainVWAPOnly

// Optional VWAP gate levels
u2 = plot(showOptionalGates ? gUp2 : na, "Upper Gate 2", color = gColZone, style = plot.style_stepline, linewidth = 1)
u1 = plot(showOptionalGates ? gUp1 : na, "Upper Gate 1", color = gColZone, style = plot.style_stepline, linewidth = 1)

plot(showG ? gMid : na, "Main VWAP Gate Line", color = gColMid, style = plot.style_stepline, linewidth = gMidWidth)

d1 = plot(showOptionalGates ? gDn1 : na, "Lower Gate 1", color = gColZone, style = plot.style_stepline, linewidth = 1)
d2 = plot(showOptionalGates ? gDn2 : na, "Lower Gate 2", color = gColZone, style = plot.style_stepline, linewidth = 1)

fill(u1, u2, color = showOptionalGates and showZoneFill ? color.new(gColMid, 92) : na, title = "Upper Gate Fill")
fill(d1, d2, color = showOptionalGates and showZoneFill ? color.new(gColMid, 92) : na, title = "Lower Gate Fill")

// POC line is hidden by default but can be enabled from settings.
plot(showPOCLine ? activePOC : na, "Active POC", color = na(activePOC) ? na : pocCol,
     style = plot.style_stepline, linewidth = pocWidth)


// ============================================================================
//  Table
// ============================================================================

var table tbl = na

if barstate.islast and showTbl
    table.delete(tbl)

    tbl := table.new(f_pos(tblPos), 2, 20, border_width = 1, frame_color = color.gray, frame_width = 1)

    ts = f_txtSize(tblSize)

    hdrClr = color.new(color.blue, 0)
    rowClr = color.new(color.black, 8)
    softRowClr = color.new(color.black, 18)
    goodClr = color.new(color.green, 0)
    badClr = color.new(color.red, 0)
    neutralClr = color.new(color.gray, 0)
    warnClr = color.new(color.orange, 0)

    controlBg =
         aboveCount >= 3 ? goodClr :
         aboveCount <= 1 ? badClr :
         warnClr

    volBg =
         strongVol ? goodClr :
         na(volRatio) ? neutralClr :
         volRatio >= 1.0 ? warnClr :
         badClr

    table.cell(tbl, 0, 0, "Technical Analysis", text_color = color.white, bgcolor = hdrClr, text_size = ts)
    table.cell(tbl, 1, 0, "VV Analyzer", text_color = color.white, bgcolor = hdrClr, text_size = ts)

    table.cell(tbl, 0, 1, "Symbol", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 1, syminfo.ticker, text_color = color.white, bgcolor = rowClr, text_size = ts)

    table.cell(tbl, 0, 2, "VWAP Mode", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 2, selectedGateLabel, text_color = color.white, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 3, "POC Mode", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 3, selectedPOCLabel, text_color = color.white, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 4, "Current Price", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 4, str.tostring(close, format.mintick), text_color = color.white, bgcolor = rowClr, text_size = ts)

    table.cell(tbl, 0, 5, "Status", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 5, statusText, text_color = color.white, bgcolor = statusColor, text_size = ts)

    table.cell(tbl, 0, 6, "Action Bias", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 6, actionText, text_color = color.white, bgcolor = actionColor, text_size = ts)

    table.cell(tbl, 0, 7, "Trend", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 7, trendText, text_color = color.white,
         bgcolor = trendUp ? goodClr : trendDown ? badClr : warnClr, text_size = ts)

    table.cell(tbl, 0, 8, "Current Volume", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 8, str.tostring(volume, format.volume), text_color = color.white, bgcolor = rowClr, text_size = ts)

    table.cell(tbl, 0, 9, "Volume Ratio", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 9, na(volRatio) ? "-" : str.tostring(volRatio, "#.00"), text_color = color.white, bgcolor = volBg, text_size = ts)

    table.cell(tbl, 0, 10, "Daily POC", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 10, f_fmt(pocD), text_color = aboveD ? color.lime : color.red, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 11, "Weekly POC", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 11, f_fmt(pocW), text_color = aboveW ? color.lime : color.red, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 12, "Monthly POC", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 12, f_fmt(pocM), text_color = aboveM ? color.lime : color.red, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 13, "Upper Zone ▲", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 13, f_fmt(gUp1), text_color = color.lime, bgcolor = rowClr, text_size = ts)

    table.cell(tbl, 0, 14, "VWAP Gate Line", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 14, f_fmt(gMid), text_color = aboveVWAP ? color.lime : color.red, bgcolor = rowClr, text_size = ts)

    table.cell(tbl, 0, 15, "Lower Zone ▼", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 15, f_fmt(gDn1), text_color = color.red, bgcolor = rowClr, text_size = ts)

    table.cell(tbl, 0, 16, "Control Strength", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 16, controlText, text_color = color.white, bgcolor = controlBg, text_size = ts)

    table.cell(tbl, 0, 17, "Nearest Control", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 17, nearestName, text_color = color.white, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 18, "Distance", text_color = color.white, bgcolor = softRowClr, text_size = ts)
    table.cell(tbl, 1, 18, na(nearestDist) ? "-" : str.tostring(nearestDist, "#.00") + "%", text_color = nearAnyControl ? color.orange : color.white, bgcolor = softRowClr, text_size = ts)

    table.cell(tbl, 0, 19, "Signal Now", text_color = color.white, bgcolor = rowClr, text_size = ts)
    table.cell(tbl, 1, 19, signalNow, text_color = color.white, bgcolor = signalNowColor, text_size = ts)


// ============================================================================
//  Optional Status Label
// ============================================================================

volText =
     not useVolumeInSignal ? "" :
     na(volRatio) ? " | Volume N/A" :
     strongVol ? " | Strong volume" :
     " | Weak/normal volume"

sigTxt =
     veryBullish ? "VV Analyzer | Very Bullish | Above all controls" + volText :
     bullish ? "VV Analyzer | Bullish | Above most controls" + volText :
     breakoutWatch ? "VV Analyzer | Breakout Watch | " + actionText + volText :
     recoveryWatch ? "VV Analyzer | Recovery Watch | " + actionText + volText :
     breakdownRisk ? "VV Analyzer | Breakdown Risk | " + actionText + volText :
     neutral ? "VV Analyzer | Neutral | " + actionText + volText :
     bearish ? "VV Analyzer | Bearish | " + actionText + volText :
     veryBearish ? "VV Analyzer | Very Bearish | Below all controls" + volText :
     "VV Analyzer | Neutral" + volText

sigClr =
     veryBullish or bullish or breakoutWatch ? color.new(color.green, 12) :
     veryBearish or bearish or breakdownRisk ? color.new(color.red, 12) :
     recoveryWatch ? color.new(color.orange, 12) :
     color.new(color.gray, 12)

sigStyle =
     veryBullish or bullish or breakoutWatch ? label.style_label_up :
     veryBearish or bearish or breakdownRisk ? label.style_label_down :
     label.style_label_left

atr = ta.atr(14)

sigY =
     veryBullish or bullish or breakoutWatch ? low - atr * signalOffsetAtr :
     veryBearish or bearish or breakdownRisk ? high + atr * signalOffsetAtr :
     close

var label sigLbl = na

if barstate.islast
    label.delete(sigLbl)
    if showSignal
        sigLbl := label.new(
             bar_index,
             sigY,
             sigTxt,
             style = sigStyle,
             color = sigClr,
             textcolor = color.white,
             size = f_labelSize(signalBoxSize),
             yloc = yloc.price)


// ============================================================================
//  Alerts
// ============================================================================

alertcondition(veryBullish, "VV Very Bullish", "VV Analyzer: Price is above all control levels.")
alertcondition(bullish, "VV Bullish", "VV Analyzer: Price is above most control levels.")
alertcondition(recoveryWatch, "VV Recovery Watch", "VV Analyzer: Price bounced from the lower zone but still needs VWAP confirmation.")
alertcondition(breakoutWatch, "VV Breakout Watch", "VV Analyzer: Price is reclaiming or breaking above a control level.")
alertcondition(breakdownRisk, "VV Breakdown Risk", "VV Analyzer: Price is losing VWAP or breaking below a key lower control area.")
alertcondition(veryBearish, "VV Very Bearish", "VV Analyzer: Price is below all control levels.")

alertcondition(vwapReclaimConfirmed, "VWAP Reclaim", "VV Analyzer: Price reclaimed the VWAP Gate Line.")
alertcondition(vwapLostConfirmed, "VWAP Lost", "VV Analyzer: Price lost the VWAP Gate Line.")
alertcondition(lowerZoneBounce, "Lower Zone Bounce", "VV Analyzer: Price bounced from the lower VWAP zone.")
alertcondition(upperZoneReject, "Upper Zone Reject", "VV Analyzer: Price rejected from the upper VWAP zone.")
alertcondition(breakdownBelowLower, "Lower Zone Breakdown", "VV Analyzer: Price broke below the lower VWAP zone.")
alertcondition(breakoutAboveUpper, "Upper Zone Breakout", "VV Analyzer: Price broke above the upper VWAP zone.")
alertcondition(activePOCReclaim, "Active POC Reclaim", "VV Analyzer: Price reclaimed the active POC.")
alertcondition(activePOCLost, "Active POC Lost", "VV Analyzer: Price lost the active POC.")
````
