# QARAR Unified EGX Market Map

- url: https://www.tradingview.com/script/4mVOGPqx-QARAR-Unified-EGX-Market-Map/
- type: indicator
- pine_id: PUB;96655ce10d8c4505bfb4480bc76abced
- version: 1.0

## Description

# QARAR Unified Market Map

Advanced Multi-Layer Market Intelligence System for EGX 🇪🇬

QARAR Unified Market Map is a professional all-in-one market structure indicator designed specifically for the Egyptian Stock Exchange.

The indicator combines multiple analytical layers into one unified system to help traders understand:

✅ Market Leadership
✅ Relative Strength
✅ Trend Structure
✅ Momentum Expansion
✅ Smart Support & Resistance Zones
✅ Market Rotation & Liquidity Flow

━━━━━━━━━━━━━━━━━━

# Core Philosophy

Most indicators analyze:
• Price only
or
• Trend only

QARAR Unified Market Map combines:

📊 Relative Strength Analysis
📈 Rolling Trend Structure
🟦 Dynamic Support & Resistance Zones

inside one integrated framework.

This allows traders to understand:
not only “where price is moving”…
but also:
WHY the move is happening and whether the stock is truly leading the market.

━━━━━━━━━━━━━━━━━━

# Included Layers

## 1. QARAR Relative Wave

Institutional-style relative performance engine comparing the stock against:

• EGX30
• EGX70 EWI
• EGX100 EWI

This layer helps identify:
✅ Market Leaders
✅ Relative Strength Expansion
✅ Weak Stocks Before Breakdown
✅ Momentum Rotation

━━━━━━━━━━━━━━━━━━

## 2. QARAR Rolling Trend

Adaptive rolling trend structure engine designed to:
• Detect directional momentum
• Track market acceleration
• Visualize trend continuation
• Highlight transition between bullish and bearish phases

The rolling structure dynamically adapts using volatility-based movement logic.

━━━━━━━━━━━━━━━━━━

## 3. QARAR S/R Zones

Dynamic smart support & resistance system designed to detect:

✅ Demand Zones
✅ Supply Zones
✅ Liquidity Sweeps
✅ Reclaimed Levels
✅ Strong Reaction Areas
✅ Major Institutional Zones

The system continuously updates zones based on:
• Price structure
• Volatility
• Volume reactions
• Market behavior

━━━━━━━━━━━━━━━━━━

# Layer System

Each layer can be:
✅ Enabled
or
❌ Disabled

independently from settings.

This allows traders to build their own workflow:
• Relative Strength only
• Trend only
• S/R only
• Full institutional map

━━━━━━━━━━━━━━━━━━

# How To Use

## Bullish Conditions

Strong bullish environments usually occur when:

✅ Relative Wave is positive
✅ Stock outperforms EGX30
✅ Rolling Trend turns bullish
✅ Price reacts from Demand Zone
✅ Expansion begins increasing

━━━━━━━━━━━━━━━━━━

## Weakness Conditions

Risk increases when:

❌ Relative Strength weakens
❌ Rolling Trend flattens or reverses
❌ Price enters major Supply Zone
❌ Expansion fades
❌ Stock loses market leadership

━━━━━━━━━━━━━━━━━━

# Best Use Cases

✅ Swing Trading
✅ Market Leadership Detection
✅ Relative Strength Trading
✅ Momentum Trading
✅ Sector Rotation Analysis
✅ Institutional Structure Analysis
✅ EGX Market Mapping

━━━━━━━━━━━━━━━━━━

# Optimized For

🇪🇬 Egyptian Stock Exchange (EGX)

Benchmarks Used:
• EGX30
• EGX70 EWI
• EGX100 EWI

━━━━━━━━━━━━━━━━━━

# Notes

• Designed for educational and analytical purposes only.
• Not financial advice.
• Best used with proper risk management and price action analysis.

━━━━━━━━━━━━━━━━━━

QARAR | قرار
Smart Analysis, Better Decision.

## Source Code

````pine
//@version=6
indicator("QARAR Unified EGX Market Map", "QARAR Market Map", overlay=false, max_bars_back=5000, max_boxes_count=500, max_labels_count=500, max_lines_count=500, dynamic_requests=true)

//====================================================================
// QARAR UNIFIED MARKET MAP
// Layers:
// 1) QARAR Relative Wave
// 2) QARAR Rolling Trend
// 3) QARAR S/R Zones
//====================================================================

//====================================================================
// MASTER LAYER CONTROLS
//====================================================================
masterGroup = "0) Layer Controls"
showRelativeWave = input.bool(true, "Show Relative Wave", group=masterGroup)
showRollingTrend = input.bool(true, "Show Rolling Trend", group=masterGroup)
showSRZones      = input.bool(true, "Show S/R Zones", group=masterGroup)
showWaveDash     = input.bool(true, "Show Relative Wave Dashboard", group=masterGroup)
showSRDash       = input.bool(false, "Show S/R Dashboard", group=masterGroup)

//====================================================================
// 1) QARAR RELATIVE WAVE
//====================================================================
waveGroup = "1) QARAR Relative Wave"
baseLen = input.int(120, "Wave Base Lookback", minval=20, maxval=500, group=waveGroup)
smoothLen = input.int(5, "Wave Smoothing", minval=1, maxval=50, group=waveGroup)
lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group=waveGroup)

egx30 = request.security("EGX:EGX30", timeframe.period, close, ignore_invalid_symbol=true)
egx70 = request.security("EGX:EGX70EWI", timeframe.period, close, ignore_invalid_symbol=true)
egx100 = request.security("EGX:EGX100EWI", timeframe.period, close, ignore_invalid_symbol=true)

baseStock = close[baseLen]
base30 = egx30[baseLen]
base70 = egx70[baseLen]
base100 = egx100[baseLen]

ready30 = not na(baseStock) and not na(base30) and baseStock != 0 and base30 != 0
ready70 = not na(baseStock) and not na(base70) and baseStock != 0 and base70 != 0
ready100 = not na(baseStock) and not na(base100) and baseStock != 0 and base100 != 0

stockPerf = not na(baseStock) and baseStock != 0 ? (close / baseStock - 1.0) * 100.0 : na
egx30Perf = ready30 ? (egx30 / base30 - 1.0) * 100.0 : na
egx70Perf = ready70 ? (egx70 / base70 - 1.0) * 100.0 : na
egx100Perf = ready100 ? (egx100 / base100 - 1.0) * 100.0 : na

stockWave = ta.ema(stockPerf, smoothLen)
egx30Wave = ta.ema(egx30Perf, smoothLen)
egx70Wave = ta.ema(egx70Perf, smoothLen)
egx100Wave = ta.ema(egx100Perf, smoothLen)

rs30 = stockWave - egx30Wave
rs70 = stockWave - egx70Wave
rs100 = stockWave - egx100Wave
avgRS = (nz(rs30) + nz(rs70) + nz(rs100)) / 3.0

leaderAll = rs30 > 0 and rs70 > 0 and rs100 > 0
weakAll = rs30 < 0 and rs70 < 0 and rs100 < 0

waveState = leaderAll ? "MARKET LEADER" : weakAll ? "MARKET LAGGARD" : avgRS > 0 ? "RELATIVE STRONG" : "RELATIVE WEAK"
waveStateColor = waveState == "MARKET LEADER" ? color.green : waveState == "RELATIVE STRONG" ? color.teal : waveState == "MARKET LAGGARD" ? color.red : color.orange

hline(0, "Zero", color=showRelativeWave ? color.gray : color.new(color.gray, 100))
hline(10, "Plus 10%", color=showRelativeWave ? color.new(color.green, 70) : color.new(color.green, 100), linestyle=hline.style_dotted)
hline(-10, "Minus 10%", color=showRelativeWave ? color.new(color.red, 70) : color.new(color.red, 100), linestyle=hline.style_dotted)

stockPlot = plot(showRelativeWave ? stockWave : na, "Stock Performance", color=color.aqua, linewidth=3)
egx30Plot = plot(showRelativeWave ? egx30Wave : na, "EGX30 Performance", color=color.yellow, linewidth=2)
egx70Plot = plot(showRelativeWave ? egx70Wave : na, "EGX70 Performance", color=color.new(color.orange, 75), linewidth=1)
egx100Plot = plot(showRelativeWave ? egx100Wave : na, "EGX100 Performance", color=color.new(color.purple, 80), linewidth=1)

plot(showRelativeWave ? rs30 : na, "Stock vs EGX30", style=plot.style_area, color=rs30 >= 0 ? color.new(color.green, 82) : color.new(color.red, 82))
plot(showRelativeWave ? rs70 : na, "Stock vs EGX70", style=plot.style_columns, color=rs70 >= 0 ? color.new(color.teal, 35) : color.new(color.red, 35))
plot(showRelativeWave ? rs100 : na, "Stock vs EGX100", style=plot.style_area, color=rs100 >= 0 ? color.new(color.blue, 88) : color.new(color.orange, 88))

fill(stockPlot, egx30Plot, color=showRelativeWave ? (stockWave >= egx30Wave ? color.new(color.teal, 82) : color.new(color.red, 85)) : na)
fill(stockPlot, egx70Plot, color=showRelativeWave ? (stockWave >= egx70Wave ? color.new(color.green, 96) : color.new(color.orange, 96)) : na)
fill(stockPlot, egx100Plot, color=showRelativeWave ? (stockWave >= egx100Wave ? color.new(color.blue, 97) : color.new(color.purple, 97)) : na)

//====================================================================
// 2) QARAR ROLLING TREND
//====================================================================
rollGroup = "2) QARAR Rolling Trend"
color BULL_COLOR = #089981
color BEAR_COLOR = #f23645

fastLengthInput = input.int(5, "Fast Slope Length", minval=1, group=rollGroup)
slowLengthInput = input.int(10, "Slow Slope Length", minval=1, group=rollGroup)
atrLengthInput = input.int(200, "ATR Length", minval=1, group=rollGroup)
fastThresholdInput = input.float(1.0, "Fast Slope Threshold ATR", minval=0, step=0.1, group=rollGroup)
reverseThresholdInput = input.float(2.0, "Reverse Threshold ATR", minval=0, step=0.1, group=rollGroup)

rollAtr = ta.atr(atrLengthInput)
var float rollSeg = close
var int rollTrend = 1
var float activeSlope = 0.0
var bool isFastMode = false

bool bullReversal = false
bool bearReversal = false

if not na(rollAtr)
    float distFromSeg = close - rollSeg
    bullReversal := rollTrend == -1 and distFromSeg > reverseThresholdInput * rollAtr
    bearReversal := rollTrend == 1 and -distFromSeg > reverseThresholdInput * rollAtr
    if bullReversal
        rollTrend := 1
    else if bearReversal
        rollTrend := -1
    bool newIsFastMode = math.abs(distFromSeg) > fastThresholdInput * rollAtr
    bool speedChanged = newIsFastMode != isFastMode
    if bullReversal or bearReversal or speedChanged or activeSlope == 0.0
        isFastMode := newIsFastMode
        activeSlope := isFastMode ? rollAtr / fastLengthInput : rollAtr / slowLengthInput
    rollSeg := rollSeg + (rollTrend * activeSlope)
else
    rollSeg := close

rollColor = rollTrend == 1 ? BULL_COLOR : BEAR_COLOR
rollPlot = plot(showRollingTrend ? rollSeg : na, "QARAR Rolling Trend", color=rollColor, linewidth=2, force_overlay=true)
pricePlot = plot(showRollingTrend ? close : na, "Price Reference", display=display.none, force_overlay=true)
fill(pricePlot, rollPlot, top_value=rollTrend == 1 ? close : rollSeg, bottom_value=rollTrend == 1 ? rollSeg : close, top_color=rollTrend == 1 ? color.new(BULL_COLOR, 50) : color.new(BEAR_COLOR, 90), bottom_color=rollTrend == 1 ? color.new(BULL_COLOR, 90) : color.new(BEAR_COLOR, 50), title="Rolling Trend Fill")

//====================================================================
// 3) QARAR S/R ZONES
//====================================================================
qDemand        = color.rgb(20, 184, 166)
qSupply        = color.rgb(220, 95, 121)
qReclaimed     = color.rgb(16, 185, 129)
qBroken        = color.rgb(100, 116, 139)
qLiquidity     = color.rgb(245, 158, 11)
qBlue          = color.rgb(37, 99, 235)
qGold          = color.rgb(214, 167, 86)
qPanelHead     = color.rgb(17, 24, 39)
qPanelSoft     = color.rgb(31, 41, 55)
qTextMuted     = color.rgb(190, 190, 190)

srMainGroup = "3) QARAR S/R Engine"
useSRZoneEngine = input.bool(true, "Enable S/R Engine", group=srMainGroup)
pivotLen = input.int(5, "Pivot Strength", minval=2, maxval=30, group=srMainGroup)
srAtrLen = input.int(200, "S/R ATR Length", minval=20, maxval=500, group=srMainGroup)
srZoneDepthMult = input.float(0.55, "Zone Depth ATR", minval=0.10, maxval=2.00, step=0.05, group=srMainGroup)
srBreakBufferMult = input.float(0.15, "Break / Acceptance Buffer ATR", minval=0.00, maxval=1.00, step=0.05, group=srMainGroup)
srRetestToleranceATR = input.float(0.45, "Retest / Reclaim Tolerance ATR", minval=0.05, maxval=2.00, step=0.05, group=srMainGroup)

srVisGroup = "4) QARAR S/R Visual Map"
showSRVisualMap = input.bool(true, "Show Full Historical S/R Visual Map", group=srVisGroup)
srVisualMaxZones = input.int(55, "Max Historical Zones", minval=5, maxval=120, group=srVisGroup)
srVisualExtendRight = input.bool(true, "Extend Zones Right", group=srVisGroup)
srVisualFadeOld = input.bool(true, "Fade Old Zones", group=srVisGroup)
srVisualShowLabels = input.bool(true, "Show Major Zone Labels", group=srVisGroup)
srVisualMinGapATR = input.float(0.55, "Minimum Gap Between Zones ATR", minval=0.10, maxval=5.00, step=0.05, group=srVisGroup)
srVisualMinStrength = input.float(42.0, "Minimum Zone Strength", minval=20.0, maxval=90.0, step=1.0, group=srVisGroup)
srVisualMajorStrength = input.float(62.0, "Major Zone Strength", minval=30.0, maxval=95.0, step=1.0, group=srVisGroup)
srVisualShowBroken = input.bool(true, "Show Broken Zones", group=srVisGroup)
srVisualMaxBroken = input.int(14, "Max Visible Broken Zones", minval=0, maxval=50, group=srVisGroup)
srVisualAgeLimit = input.int(650, "Fade / Hide Weak Zones After Bars", minval=50, maxval=2500, group=srVisGroup)
srVisualMinEntriesMajor = input.int(2, "Major Zone Min Touches", minval=1, maxval=8, group=srVisGroup)
srVisualSweepBoost = input.float(10.0, "Sweep / Rejection Strength Boost", minval=0.0, maxval=30.0, step=0.5, group=srVisGroup)
srVisualVolumeBoost = input.float(8.0, "Volume Reaction Strength Boost", minval=0.0, maxval=25.0, step=0.5, group=srVisGroup)
useResistanceHeatMap = input.bool(false, "Heatmap Strength Coloring", group=srVisGroup)

srFilterGroup = "5) QARAR S/R Smart Visibility"
visibilityMode = input.string("Genesis", "Visibility Mode", options=["Clean", "Genesis", "Full"], group=srFilterGroup)
showOnlyMajorLabels = input.bool(true, "Labels Only For Major Zones", group=srFilterGroup)

srVolGroup = "6) QARAR S/R Volume / Reaction"
volLen = input.int(20, "Volume MA", minval=5, group=srVolGroup)
volReactionMult = input.float(1.15, "High Volume Reaction Mult", minval=0.5, maxval=5.0, step=0.05, group=srVolGroup)

srDashGroup = "7) QARAR S/R Dashboard"
dashPosInput = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"], group=srDashGroup)

atr = ta.atr(14)
srAtr = ta.atr(srAtrLen)
volMA = ta.sma(volume, volLen)
body = math.abs(close - open)
barRange = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

profileZoneMajorStrength = visibilityMode == "Clean" ? srVisualMajorStrength + 8 : visibilityMode == "Full" ? srVisualMajorStrength - 8 : srVisualMajorStrength
profileMinStrength = visibilityMode == "Clean" ? srVisualMinStrength + 10 : visibilityMode == "Full" ? srVisualMinStrength - 8 : srVisualMinStrength
profileMaxZones = visibilityMode == "Clean" ? math.min(srVisualMaxZones, 18) : visibilityMode == "Full" ? srVisualMaxZones : math.min(srVisualMaxZones, 55)
profileMaxBroken = visibilityMode == "Clean" ? math.min(srVisualMaxBroken, 5) : srVisualMaxBroken
profileZoneDepthMult = srZoneDepthMult
profileBreakBufferMult = srBreakBufferMult

var box[] qZoneBoxes = array.new_box()
var label[] qZoneLabels = array.new_label()
var float[] qZoneTops = array.new_float()
var float[] qZoneBottoms = array.new_float()
var float[] qZoneStrengths = array.new_float()
var bool[] qZoneSupports = array.new_bool()
var bool[] qZoneBroken = array.new_bool()
var int[] qZoneBirth = array.new_int()
var int[] qZoneEntries = array.new_int()
var int[] qZoneSweeps = array.new_int()
var float[] qZoneVolumes = array.new_float()

f_zone_mid(float _top, float _bottom) =>
    (_top + _bottom) / 2.0

f_zone_overlaps(float _top, float _bottom, bool _isSupport) =>
    int _idx = na
    if array.size(qZoneBoxes) > 0
        float _mid = f_zone_mid(_top, _bottom)
        for zi = 0 to array.size(qZoneBoxes) - 1
            bool sameType = array.get(qZoneSupports, zi) == _isSupport
            float zTop = array.get(qZoneTops, zi)
            float zBot = array.get(qZoneBottoms, zi)
            float zMid = f_zone_mid(zTop, zBot)
            bool priceOverlap = math.max(_bottom, zBot) <= math.min(_top, zTop)
            bool nearGap = math.abs(_mid - zMid) <= srAtr * srVisualMinGapATR
            if sameType and (priceOverlap or nearGap)
                _idx := zi
                break
    _idx

f_zone_bg(bool _isSupport, bool _broken, int _age, float _strength, bool _isMajor) =>
    int ageFade = srVisualFadeOld ? int(math.floor(_age / 60)) : 0
    int tr = 90
    if useResistanceHeatMap
        tr := _strength >= 88 ? 30 : _strength >= 78 ? 42 : _strength >= 68 ? 54 : _strength >= 58 ? 66 : _strength >= 48 ? 78 : 90
    else
        int baseTransp = _isMajor ? 76 : 88
        int strengthAdj = _strength >= 82 ? -16 : _strength >= 70 ? -10 : _strength >= 58 ? -5 : 2
        tr := baseTransp + strengthAdj
    tr := math.max(_isMajor ? 28 : 64, math.min(96, tr + ageFade))
    _broken ? color.new(qBroken, math.min(96, tr + 8)) : _isSupport ? color.new(qDemand, tr) : color.new(qSupply, tr)

f_zone_border(bool _isSupport, bool _broken, float _strength, bool _isMajor) =>
    int tr = useResistanceHeatMap ? (_strength >= 88 ? 0 : _strength >= 78 ? 8 : _strength >= 68 ? 18 : _strength >= 58 ? 34 : 62) : (_isMajor ? (_strength >= 82 ? 8 : _strength >= 70 ? 18 : 28) : 66)
    _broken ? color.new(qBroken, 58) : _isSupport ? color.new(qDemand, tr) : color.new(qSupply, tr)

f_restyle_zone(int _idx, bool _reclaimed=false) =>
    box bx = array.get(qZoneBoxes, _idx)
    bool zSup = array.get(qZoneSupports, _idx)
    bool zBroken = array.get(qZoneBroken, _idx)
    int zAge = bar_index - array.get(qZoneBirth, _idx)
    float zStrength = array.get(qZoneStrengths, _idx)
    int zEntries = array.get(qZoneEntries, _idx)
    int zSweeps = array.get(qZoneSweeps, _idx)
    bool zMajor = zStrength >= profileZoneMajorStrength or zEntries >= srVisualMinEntriesMajor
    color bg = _reclaimed ? color.new(qReclaimed, 76) : f_zone_bg(zSup, zBroken, zAge, zStrength, zMajor)
    color br = _reclaimed ? color.new(qReclaimed, 24) : f_zone_border(zSup, zBroken, zStrength, zMajor)
    box.set_bgcolor(bx, bg)
    box.set_border_color(bx, br)
    box.set_border_width(bx, zMajor and not zBroken ? 2 : 1)
    if not srVisualExtendRight
        box.set_right(bx, bar_index + 25)
    label lb = array.get(qZoneLabels, _idx)
    if not na(lb)
        float zTop = array.get(qZoneTops, _idx)
        float zBot = array.get(qZoneBottoms, _idx)
        label.set_x(lb, bar_index + 4)
        label.set_y(lb, f_zone_mid(zTop, zBot))
        string zoneTxt = _reclaimed ? "RECLAIMED SUPPORT" : zBroken ? (zSup ? "BROKEN SUPPORT" : "BROKEN RESISTANCE") : zSup ? (zStrength >= 70 ? "MAJOR DEMAND" : "DEMAND / SUPPORT") : (zStrength >= 70 ? "MAJOR SUPPLY" : "SUPPLY / RESISTANCE")
        if srVisualShowLabels and (not showOnlyMajorLabels or zMajor or _reclaimed)
            label.set_text(lb, zoneTxt + "  S:" + str.tostring(zStrength, "#.0") + "  T:" + str.tostring(zEntries) + "  W:" + str.tostring(zSweeps))
            label.set_textcolor(lb, _reclaimed ? qReclaimed : br)
        else
            label.set_text(lb, "")

f_delete_zone(int _idx) =>
    box bx = array.remove(qZoneBoxes, _idx)
    box.delete(bx)
    label lb = array.remove(qZoneLabels, _idx)
    if not na(lb)
        label.delete(lb)
    array.remove(qZoneTops, _idx)
    array.remove(qZoneBottoms, _idx)
    array.remove(qZoneStrengths, _idx)
    array.remove(qZoneSupports, _idx)
    array.remove(qZoneBroken, _idx)
    array.remove(qZoneBirth, _idx)
    array.remove(qZoneEntries, _idx)
    array.remove(qZoneSweeps, _idx)
    array.remove(qZoneVolumes, _idx)

f_trim_zones() =>
    while array.size(qZoneBoxes) > profileMaxZones
        f_delete_zone(array.size(qZoneBoxes) - 1)
    int brokenCount = 0
    if array.size(qZoneBoxes) > 0
        for zi = array.size(qZoneBoxes) - 1 to 0
            bool zBroken = array.get(qZoneBroken, zi)
            int zAge = bar_index - array.get(qZoneBirth, zi)
            float zStrength = array.get(qZoneStrengths, zi)
            if zBroken
                brokenCount += 1
                if not srVisualShowBroken or brokenCount > profileMaxBroken
                    f_delete_zone(zi)
            else if zAge > srVisualAgeLimit and zStrength < profileZoneMajorStrength
                f_delete_zone(zi)

f_add_zone(float _top, float _bottom, bool _isSupport, float _strength, string _tag) =>
    int _status = 0
    bool _validZone = showSRZones and showSRVisualMap and useSRZoneEngine and not na(_top) and not na(_bottom) and _top > _bottom and _strength >= profileMinStrength
    if _validZone
        int overlapIdx = f_zone_overlaps(_top, _bottom, _isSupport)
        if not na(overlapIdx)
            float oldStrength = array.get(qZoneStrengths, overlapIdx)
            int oldEntries = array.get(qZoneEntries, overlapIdx)
            float oldVol = array.get(qZoneVolumes, overlapIdx)
            float newStrength = math.min(100.0, math.max(oldStrength, _strength) + 6.0 + math.min(10.0, oldEntries * 1.5))
            float oldTop = array.get(qZoneTops, overlapIdx)
            float oldBot = array.get(qZoneBottoms, overlapIdx)
            float mergedTop = math.max(oldTop, _top)
            float mergedBot = math.min(oldBot, _bottom)
            array.set(qZoneTops, overlapIdx, mergedTop)
            array.set(qZoneBottoms, overlapIdx, mergedBot)
            array.set(qZoneStrengths, overlapIdx, newStrength)
            array.set(qZoneEntries, overlapIdx, oldEntries + 1)
            array.set(qZoneVolumes, overlapIdx, oldVol + nz(volume[pivotLen], volume))
            box bx = array.get(qZoneBoxes, overlapIdx)
            box.set_top(bx, mergedTop)
            box.set_bottom(bx, mergedBot)
            array.set(qZoneBroken, overlapIdx, false)
            f_restyle_zone(overlapIdx)
            _status := 1
        else
            int leftX = math.max(0, bar_index - pivotLen)
            int rightX = bar_index + 25
            bool isMajor = _strength >= profileZoneMajorStrength
            color bg = f_zone_bg(_isSupport, false, 0, _strength, isMajor)
            color br = f_zone_border(_isSupport, false, _strength, isMajor)
            box bx = box.new(left=leftX, top=_top, right=rightX, bottom=_bottom, xloc=xloc.bar_index, extend=srVisualExtendRight ? extend.right : extend.none, bgcolor=bg, border_color=br, border_width=isMajor ? 2 : 1, force_overlay=true)
            label lb = na
            if srVisualShowLabels
                string zoneName = _isSupport ? "QARAR SUPPORT" : "QARAR RESISTANCE"
                lb := label.new(leftX, f_zone_mid(_top, _bottom), (not showOnlyMajorLabels or isMajor) ? zoneName + "  " + str.tostring(_strength, "#.0") : "", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(chart.bg_color, 25), textcolor=br, size=size.tiny, force_overlay=true)
            array.unshift(qZoneBoxes, bx)
            array.unshift(qZoneLabels, lb)
            array.unshift(qZoneTops, _top)
            array.unshift(qZoneBottoms, _bottom)
            array.unshift(qZoneStrengths, _strength)
            array.unshift(qZoneSupports, _isSupport)
            array.unshift(qZoneBroken, false)
            array.unshift(qZoneBirth, bar_index)
            array.unshift(qZoneEntries, 1)
            array.unshift(qZoneSweeps, 0)
            array.unshift(qZoneVolumes, nz(volume[pivotLen], volume))
            f_trim_zones()
            _status := 2
    _status

if showSRZones and showSRVisualMap and useSRZoneEngine and not na(pivotHigh)
    float phTop = pivotHigh + srAtr * profileBreakBufferMult
    float phBot = pivotHigh - srAtr * profileZoneDepthMult
    float phVolBoost = volume[pivotLen] > volMA[pivotLen] * volReactionMult ? 14.0 : volume[pivotLen] > volMA[pivotLen] ? srVisualVolumeBoost : 0.0
    float phWickBoost = upperWick[pivotLen] > body[pivotLen] * 1.20 ? 12.0 : upperWick[pivotLen] > body[pivotLen] ? 6.0 : 0.0
    float phTrendBoost = high[pivotLen] >= ta.highest(high, 40)[pivotLen] ? 10.0 : 0.0
    float phStrength = 44.0 + phVolBoost + phWickBoost + phTrendBoost
    f_add_zone(phTop, phBot, false, math.min(100.0, phStrength), "Supply")

if showSRZones and showSRVisualMap and useSRZoneEngine and not na(pivotLow)
    float plTop = pivotLow + srAtr * profileZoneDepthMult
    float plBot = pivotLow - srAtr * profileBreakBufferMult
    float plVolBoost = volume[pivotLen] > volMA[pivotLen] * volReactionMult ? 14.0 : volume[pivotLen] > volMA[pivotLen] ? srVisualVolumeBoost : 0.0
    float plWickBoost = lowerWick[pivotLen] > body[pivotLen] * 1.20 ? 12.0 : lowerWick[pivotLen] > body[pivotLen] ? 6.0 : 0.0
    float plTrendBoost = low[pivotLen] <= ta.lowest(low, 40)[pivotLen] ? 10.0 : 0.0
    float plStrength = 44.0 + plVolBoost + plWickBoost + plTrendBoost
    f_add_zone(plTop, plBot, true, math.min(100.0, plStrength), "Demand")

if showSRZones and showSRVisualMap and useSRZoneEngine and array.size(qZoneBoxes) > 0
    for zi = array.size(qZoneBoxes) - 1 to 0
        float zTop = array.get(qZoneTops, zi)
        float zBot = array.get(qZoneBottoms, zi)
        bool zSup = array.get(qZoneSupports, zi)
        bool zBroken = array.get(qZoneBroken, zi)
        bool crossedUp = not zSup and close > zTop and close[1] <= zTop
        bool crossedDn = zSup and close < zBot and close[1] >= zBot
        bool reclaimedSupport = not zSup and close > zTop and low <= zTop + atr * srRetestToleranceATR and close > open
        bool rejectedFromZone = zSup ? (low <= zTop and close > zTop and close > open) : (high >= zBot and close < zBot and close < open)
        bool sweepReaction = zSup ? (low < zBot and close > zBot) : (high > zTop and close < zTop)
        if crossedUp or crossedDn
            array.set(qZoneBroken, zi, true)
        if rejectedFromZone and not zBroken
            array.set(qZoneStrengths, zi, math.min(100.0, array.get(qZoneStrengths, zi) + 1.5))
        if sweepReaction and not zBroken
            array.set(qZoneStrengths, zi, math.min(100.0, array.get(qZoneStrengths, zi) + srVisualSweepBoost))
            array.set(qZoneSweeps, zi, array.get(qZoneSweeps, zi) + 1)
        f_restyle_zone(zi, reclaimedSupport)
    f_trim_zones()

//====================================================================
// DASHBOARDS
//====================================================================
var table waveDash = table.new(position.top_right, 2, 8, border_width=1)

if showWaveDash and barstate.islast
    table.cell(waveDash, 0, 0, "Current State", bgcolor=color.black, text_color=color.white)
    table.cell(waveDash, 1, 0, waveState, bgcolor=waveStateColor, text_color=color.white)
    table.cell(waveDash, 0, 1, "Stock", text_color=color.white)
    table.cell(waveDash, 1, 1, syminfo.ticker, text_color=color.white)
    table.cell(waveDash, 0, 2, "Stock Change", text_color=color.white)
    table.cell(waveDash, 1, 2, str.tostring(stockWave, "#.##") + "%", text_color=stockWave >= 0 ? color.lime : color.red)
    table.cell(waveDash, 0, 3, "Vs EGX30", text_color=color.white)
    table.cell(waveDash, 1, 3, str.tostring(rs30, "#.##") + "%", text_color=rs30 >= 0 ? color.lime : color.red)
    table.cell(waveDash, 0, 4, "Vs EGX70", text_color=color.white)
    table.cell(waveDash, 1, 4, str.tostring(rs70, "#.##") + "%", text_color=rs70 >= 0 ? color.lime : color.red)
    table.cell(waveDash, 0, 5, "Vs EGX100", text_color=color.white)
    table.cell(waveDash, 1, 5, str.tostring(rs100, "#.##") + "%", text_color=rs100 >= 0 ? color.lime : color.red)
    table.cell(waveDash, 0, 6, "Average RS", text_color=color.white)
    table.cell(waveDash, 1, 6, str.tostring(avgRS, "#.##") + "%", text_color=avgRS >= 0 ? color.lime : color.red)
    table.cell(waveDash, 0, 7, "Benchmarks", text_color=color.white)
    table.cell(waveDash, 1, 7, "30 / 70 / 100", text_color=color.white)

float nearestDemandMid = na
float nearestDemandStrength = na
float nearestSupplyMid = na
float nearestSupplyStrength = na
float nearestDemandDist = na
float nearestSupplyDist = na
int visibleZones = array.size(qZoneBoxes)

if array.size(qZoneBoxes) > 0
    for zi = 0 to array.size(qZoneBoxes) - 1
        bool zSup = array.get(qZoneSupports, zi)
        bool zBroken = array.get(qZoneBroken, zi)
        float zTop = array.get(qZoneTops, zi)
        float zBot = array.get(qZoneBottoms, zi)
        float zMid = f_zone_mid(zTop, zBot)
        float zStrength = array.get(qZoneStrengths, zi)
        if zSup and not zBroken and close >= zBot
            float d = math.abs(close - zTop)
            if na(nearestDemandDist) or d < nearestDemandDist
                nearestDemandDist := d
                nearestDemandMid := zMid
                nearestDemandStrength := zStrength
        if not zSup and not zBroken and close <= zTop
            float d = math.abs(zBot - close)
            if na(nearestSupplyDist) or d < nearestSupplyDist
                nearestSupplyDist := d
                nearestSupplyMid := zMid
                nearestSupplyStrength := zStrength

string location = "Neutral"
if not na(nearestDemandMid) and close <= nearestDemandMid
    location := "At / Below Demand"
else if not na(nearestSupplyMid) and close >= nearestSupplyMid
    location := "At / Above Supply"
else if not na(nearestDemandMid) and not na(nearestSupplyMid)
    location := "Between Zones"
else if not na(nearestDemandMid)
    location := "Above Demand"
else if not na(nearestSupplyMid)
    location := "Below Supply"

string lastEvent = "None"
if array.size(qZoneBoxes) > 0
    for zi = 0 to array.size(qZoneBoxes) - 1
        bool zSup = array.get(qZoneSupports, zi)
        float zTop = array.get(qZoneTops, zi)
        float zBot = array.get(qZoneBottoms, zi)
        if zSup and low < zBot and close > zBot
            lastEvent := "Demand Sweep"
            break
        if not zSup and high > zTop and close < zTop
            lastEvent := "Supply Sweep"
            break

var table srDash = na
if showSRDash and barstate.islast
    dashPos = dashPosInput == "Bottom Right" ? position.bottom_right : dashPosInput == "Bottom Left" ? position.bottom_left : dashPosInput == "Top Left" ? position.top_left : position.top_right
    if na(srDash)
        srDash := table.new(dashPos, 2, 7, bgcolor=color.new(qPanelHead, 8), border_width=1, border_color=color.new(color.white, 86))
    table.clear(srDash, 0, 0, 1, 6)
    table.cell(srDash, 0, 0, "QARAR S/R Zones", text_color=color.white, bgcolor=color.new(qPanelHead, 0))
    table.cell(srDash, 1, 0, "V5", text_color=color.white, bgcolor=color.new(qPanelHead, 0))
    table.cell(srDash, 0, 1, "Profile", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 1, 1, "Unified", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 0, 2, "Visible Zones", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 1, 2, str.tostring(visibleZones), text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 0, 3, "Nearest Demand", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 1, 3, na(nearestDemandMid) ? "-" : str.tostring(nearestDemandMid, format.mintick) + " | " + str.tostring(nearestDemandStrength, "#.0"), text_color=qDemand, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 0, 4, "Nearest Supply", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 1, 4, na(nearestSupplyMid) ? "-" : str.tostring(nearestSupplyMid, format.mintick) + " | " + str.tostring(nearestSupplyStrength, "#.0"), text_color=qSupply, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 0, 5, "Location", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 1, 5, location, text_color=qGold, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 0, 6, "Last Event", text_color=color.white, bgcolor=color.new(qPanelSoft, 0))
    table.cell(srDash, 1, 6, lastEvent, text_color=qBlue, bgcolor=color.new(qPanelSoft, 0))

alertcondition(lastEvent == "Demand Sweep", "QARAR Demand Sweep", "QARAR S/R: Demand Sweep detected")
alertcondition(lastEvent == "Supply Sweep", "QARAR Supply Sweep", "QARAR S/R: Supply Sweep detected")
````
