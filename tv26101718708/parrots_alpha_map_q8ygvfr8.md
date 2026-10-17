# Parrots' Alpha Map

- url: https://www.tradingview.com/script/q8YGVfR8-Parrots-Alpha-Map/
- type: indicator
- pine_id: PUB;c9f5380587f24607b68e239aa52ff20e
- version: 1.0

## Description

🦜 Parrots' Alpha Map (PAM) – BTC

Parrots' Alpha Map (PAM) is a Bitcoin-focused market-mapping overlay designed to visualize the key levels, risk zones, liquidity targets, and trade-management areas commonly used in discretionary BTC analysis.

The indicator provides a structured framework for tracking bullish and bearish scenarios by plotting manually configurable levels directly on the chart. Each level includes optional labels and detailed tooltip explanations to help traders understand the reasoning behind the level.

Features

• Bitcoin-focused market map
• Individually configurable support and resistance levels
• CPR, liquidity, reclaim, and invalidation zones
• Golden Pocket and downside liquidity targets
• CME gap tracking levels
• QFL-style signal markers
• Double Bottom and breakout detection
• Smart label stacking to reduce chart clutter
• Compact market-bias dashboard
• Daily and weekly invalidation monitoring
• Hover tooltips explaining the significance of each level

Intended Use

Parrots' Alpha Map is designed for traders who want a clear visual framework for:

Identifying key BTC decision points
Tracking bullish and bearish invalidation levels
Monitoring liquidity targets
Managing QFL-style trade setups
Following multi-timeframe market structure
Planning risk and trade management
Important Notes

This indicator is designed specifically for Bitcoin (BTC) and is intended as a discretionary analysis tool rather than a fully automated trading system.

The default levels reflect a market-analysis framework and should be updated as market conditions evolve.

This script does not predict future price movements and should be used alongside proper risk management and independent analysis.

Short Description

🦜 Parrots' Alpha Map (PAM) is a Bitcoin market-mapping tool that plots key support, resistance, liquidity, invalidation, and trade-management levels on the chart, helping traders visualize the daily BTC playbook through a structured discretionary framework.

## Source Code

````pine
//@version=6
indicator("🦜 Parrots' Alpha Map", overlay=true, max_lines_count=200, max_labels_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GENERAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupGeneral = "General"

showLevels = input.bool(true, "Show alpha-map levels", group=groupGeneral)
lineBarsBack = input.int(300, "Line starts X bars back", minval=20, group=groupGeneral)
lineBarsForward = input.int(8, "Line/label offset X bars forward", minval=1, maxval=100, group=groupGeneral)
labelStackSpacing = input.float(180, "Minimum label spacing in price points", minval=1, group=groupGeneral)
compactLabels = input.bool(true, "Stack labels when too close", group=groupGeneral)
showConnectors = input.bool(true, "Show dotted connector to stacked labels", group=groupGeneral)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LEVEL TOGGLES + VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupLevels = "🦜 Parrots' Alpha Map Levels"

showCPRReject = input.bool(true, "Show $73,800 CPR rejection", group=groupLevels)
lvlCPRReject = input.float(73800, "$73,800 CPR / Distribution rejection", group=groupLevels)

showHSInvalid = input.bool(true, "Show $75,000 H&S invalidation", group=groupLevels)
lvlHSInvalid = input.float(75000, "$75,000 H&S invalidation", group=groupLevels)

showBearMax = input.bool(true, "Show $75,100 Bear maximum", group=groupLevels)
lvlBearMax = input.float(75100, "$75,100 CPR last line", group=groupLevels)

showWeeklyBand = input.bool(true, "Show $75,300 Weekly band", group=groupLevels)
lvlWeeklyBand = input.float(75300, "$75,300 Weekly bull support band", group=groupLevels)

showQFLTarget = input.bool(true, "Show $75,400 QFL target", group=groupLevels)
lvlQFLTarget = input.float(75400, "$75,400 QFL scalp target", group=groupLevels)

showGreyArea = input.bool(true, "Show $75,900 Grey area", group=groupLevels)
lvlGreyArea = input.float(75900, "$75,900 Grey area", group=groupLevels)

showWeeklyReclaim = input.bool(true, "Show $78,000 Bull reclaim", group=groupLevels)
lvlWeeklyReclaim = input.float(78000, "$78,000 Weekly reclaim confirmation", group=groupLevels)

showCMEGap = input.bool(true, "Show $79,000 CME / daily resistance", group=groupLevels)
lvlCMEGap = input.float(79000, "$79,000 CME gap / Daily resistance", group=groupLevels)

showExtension = input.bool(true, "Show $86,000 Momentum extension", group=groupLevels)
lvlExtension = input.float(86000, "$86,000 Momentum extension", group=groupLevels)

showBounceGPTop = input.bool(true, "Show $72,400 Shifted GP top", group=groupLevels)
lvlBounceGPTop = input.float(72400, "$72,400 Bounce-shifted GP upper", group=groupLevels)

showBounceGPLow = input.bool(true, "Show $71,700 Shifted GP low", group=groupLevels)
lvlBounceGPLow = input.float(71700, "$71,700 Bounce-shifted GP lower", group=groupLevels)

showMonthlyDamage = input.bool(true, "Show $71,000 Monthly damage level", group=groupLevels)
lvlMonthlyDamage = input.float(71000, "$71,000 Monthly damage / GP upper", group=groupLevels)

showGPLow = input.bool(true, "Show $70,400 Golden pocket low", group=groupLevels)
lvlGPLow = input.float(70400, "$70,400 Golden pocket lower", group=groupLevels)

showLiquidity = input.bool(true, "Show $69,500 Downside liquidity", group=groupLevels)
lvlLiquidity = input.float(69500, "$69,500 Downside liquidity", group=groupLevels)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MANUAL ALPHA DATA CHECKLIST
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupAlpha = "Manual Alpha Data Checklist"

showAlphaTable = input.bool(true, "Show alpha checklist table", group=groupAlpha)
mtf1hBreakout = input.bool(true, "1H breakout confirmed", group=groupAlpha)
mtf4hFollow = input.bool(true, "4H follow-through confirmed", group=groupAlpha)
manualFundingHigh = input.bool(true, "Funding high / crowded longs", group=groupAlpha)
manualWhalesAbsent = input.bool(true, "Purple whales absent on long side", group=groupAlpha)
manualRetailLong = input.bool(true, "Retail heavily long", group=groupAlpha)
manualFearBounce = input.bool(true, "Extreme fear bounce active", group=groupAlpha)
manualOptionsReleased = input.bool(true, "Options pin released", group=groupAlpha)
manualFractalAligned = input.bool(true, "Fractal downside still aligned", group=groupAlpha)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSignals = "QFL / Double Bottom / Breakout Signals"

showQFL = input.bool(true, "Show simple QFL-style base signals", group=groupSignals)
showDoubleBottom = input.bool(true, "Show double bottom + neckline breakout", group=groupSignals)
showAcceleration = input.bool(true, "Show downside acceleration warning", group=groupSignals)

pivotLen = input.int(5, "Pivot length", minval=2, group=groupSignals)
dbTolerancePct = input.float(1.0, "Double bottom tolerance %", minval=0.1, step=0.1, group=groupSignals)
minBarsBetween = input.int(10, "Min bars between bottoms", minval=3, group=groupSignals)
maxBarsBetween = input.int(120, "Max bars between bottoms", minval=10, group=groupSignals)

qflLookback = input.int(80, "QFL base lookback", minval=20, group=groupSignals)
qflDropPct = input.float(3.0, "QFL panic drop %", minval=0.5, step=0.1, group=groupSignals)
qflReclaimPct = input.float(0.8, "QFL reclaim from low %", minval=0.1, step=0.1, group=groupSignals)

accelLookback = input.int(20, "Acceleration leg lookback", minval=5, group=groupSignals)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
colResistance = color.new(color.red, 0)
colWarning = color.new(color.orange, 0)
colTarget = color.new(color.blue, 0)
colDownside = color.new(color.purple, 0)
colGrey = color.new(color.gray, 0)
colBull = color.new(color.green, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line[] lines = array.new_line()
var label[] labels = array.new_label()
var float[] usedLabelY = array.new_float()

f_clear() =>
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
    array.clear(lines)
    array.clear(labels)
    array.clear(usedLabelY)

f_stack_y(_price) =>
    float y = _price
    if compactLabels
        if array.size(usedLabelY) > 0
            for i = 0 to array.size(usedLabelY) - 1
                existingY = array.get(usedLabelY, i)
                if math.abs(y - existingY) < labelStackSpacing
                    y := existingY + labelStackSpacing
    array.push(usedLabelY, y)
    y

f_add_level(_price, _txt, _tooltip, _color, _style) =>
    x1 = bar_index - lineBarsBack
    x2 = bar_index + lineBarsForward
    labelY = f_stack_y(_price)

    ln = line.new(x1, _price, x2, _price, xloc=xloc.bar_index, extend=extend.none, color=_color, width=2, style=_style)
    array.push(lines, ln)

    if showConnectors and labelY != _price
        connector = line.new(x2 - 1, _price, x2, labelY, xloc=xloc.bar_index, extend=extend.none, color=color.new(_color, 45), width=1, style=line.style_dotted)
        array.push(lines, connector)

    lb = label.new(x2, labelY, _txt, xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=_color, size=size.small, tooltip=_tooltip + "\n\nTrue level: " + str.tostring(_price) + "\nLabel may be vertically stacked to avoid overlap.")
    array.push(labels, lb)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW DAILY ALPHA MAP LEVELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    f_clear()

    if showLevels
        if showCPRReject
            f_add_level(lvlCPRReject, "73.8K\nCPR reject", "Critical confluence / distribution zone. The bearish alpha wants rejection here. Acceptance above weakens the bearish thesis.", colResistance, line.style_solid)

        if showHSInvalid
            f_add_level(lvlHSInvalid, "75K\nH&S invalid", "Daily close above this area risks invalidating the head-and-shoulders breakdown and can turn it into a bullish liquidity hunt.", colResistance, line.style_solid)

        if showBearMax
            f_add_level(lvlBearMax, "75.1K\nBear max", "CPR last line in the sand. Bears should not allow price to conquer and hold this level as support.", colResistance, line.style_solid)

        if showWeeklyBand
            f_add_level(lvlWeeklyBand, "75.3K\nWeekly band", "Weekly bull market support band area. Bears want rejection from below. Reclaiming it increases bullish continuation risk.", colWarning, line.style_dashed)

        if showQFLTarget
            f_add_level(lvlQFLTarget, "75.4K\nQFL route", "First QFL scalp decision target. Longs from QFL lows can trail support into this area. Rejection here favors scalp take-profit; acceptance opens 78K-79K.", colTarget, line.style_dotted)

        if showGreyArea
            f_add_level(lvlGreyArea, "75.9K\nGrey area", "Grey area warning. Above this zone the bearish thesis becomes less clean because the market starts reclaiming failed-breakdown territory.", colGrey, line.style_dashed)

        if showWeeklyReclaim
            f_add_level(lvlWeeklyReclaim, "78K\nHTF reclaim", "A close above this level would re-establish higher-timeframe bull support and strengthen the bullish continuation narrative.", colTarget, line.style_solid)

        if showCMEGap
            f_add_level(lvlCMEGap, "79K\nCME/daily", "Daily resistance and CME-gap / inefficiency zone. This is a dangerous upside magnet if 75K is not rejected.", colTarget, line.style_dotted)

        if showExtension
            f_add_level(lvlExtension, "86K\nExtension", "Momentum extension target only if bulls reclaim and hold the major resistance cluster.", colTarget, line.style_dotted)

        if showBounceGPTop
            f_add_level(lvlBounceGPTop, "72.4K\nShifted GP", "If price first bounces toward 75K, the golden-pocket downside zone shifts higher.", colDownside, line.style_dashed)

        if showBounceGPLow
            f_add_level(lvlBounceGPLow, "71.7K\nShifted GP", "Lower edge of the bounce-shifted golden pocket.", colDownside, line.style_dashed)

        if showMonthlyDamage
            f_add_level(lvlMonthlyDamage, "71K\nMonthly damage", "Important downside level. Losing this area would create stronger monthly damage and improve the bearish continuation case.", colDownside, line.style_solid)

        if showGPLow
            f_add_level(lvlGPLow, "70.4K\nGP low", "Golden-pocket lower target. Losing this area opens deeper liquidity.", colDownside, line.style_solid)

        if showLiquidity
            f_add_level(lvlLiquidity, "69.5K\nLiquidity", "Downside liquidity pool. If golden-pocket support fails, this becomes the next obvious magnet.", colDownside, line.style_dotted)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIMPLE QFL-STYLE SIGNAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lowestPrev = ta.lowest(low[1], qflLookback)
panicDrop = lowestPrev > 0 ? ((lowestPrev - low) / lowestPrev) * 100 : 0
reclaimFromLow = low > 0 ? ((close - low) / low) * 100 : 0

qflSignal = showQFL and low < lowestPrev and panicDrop >= qflDropPct and reclaimFromLow >= qflReclaimPct

plotshape(qflSignal, title="QFL Base Signal", style=shape.labelup, text="QFL", location=location.belowbar, color=colBull, textcolor=color.white, size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DOUBLE BOTTOM + BREAKOUT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float firstBottom = na
var int firstBottomBar = na
var float neckline = na
var bool waitingBreakout = false
var bool breakoutPulse = false
breakoutPulse := false

if showDoubleBottom and not na(pl)
    pivotBar = bar_index - pivotLen

    if na(firstBottom)
        firstBottom := pl
        firstBottomBar := pivotBar
        neckline := high[pivotLen]
    else
        barsBetween = pivotBar - firstBottomBar
        tolerance = math.abs(pl - firstBottom) / firstBottom * 100

        validSpacing = barsBetween >= minBarsBetween and barsBetween <= maxBarsBetween
        validTolerance = tolerance <= dbTolerancePct

        if validSpacing and validTolerance
            neckline := ta.highest(high, barsBetween)
            waitingBreakout := true
            label.new(pivotBar, pl, "DB", xloc=xloc.bar_index, style=label.style_label_up, color=colBull, textcolor=color.white, size=size.small, tooltip="Double bottom detected. Second low is within tolerance of the first low. Watch neckline breakout confirmation.")
        else
            firstBottom := pl
            firstBottomBar := pivotBar
            neckline := high[pivotLen]
            waitingBreakout := false

breakout = showDoubleBottom and waitingBreakout and not na(neckline) and close > neckline

if breakout
    breakoutPulse := true
    label.new(bar_index, high, "DB\nBreakout", style=label.style_label_down, color=colTarget, textcolor=color.white, size=size.small, tooltip="Double bottom neckline breakout confirmed. Sequence: QFL low → double bottom → 1H breakout → 4H follow-through → daily test.")
    waitingBreakout := false
    firstBottom := na
    firstBottomBar := na
    neckline := na

plot(waitingBreakout ? neckline : na, "Double Bottom Neckline", color=colTarget, linewidth=2, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DOWNSIDE ACCELERATION MODEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
recentHigh = ta.highest(high, accelLookback)
recentLow = ta.lowest(low, accelLookback)
prevHigh = ta.highest(high[accelLookback], accelLookback)
prevLow = ta.lowest(low[accelLookback], accelLookback)

lowerHigh = recentHigh < prevHigh
lowerLow = recentLow < prevLow
redPressure = close < open and close < close[1]
accelerationActive = showAcceleration and lowerHigh and lowerLow and redPressure

plotshape(accelerationActive, title="Downside Acceleration", style=shape.labeldown, text="ACCEL", location=location.abovebar, color=colDownside, textcolor=color.white, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLAYBOOK / ALPHA TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table t = table.new(position.top_right, 2, 12, border_width=1)

above75 = close > lvlHSInvalid
aboveBearMax = close > lvlBearMax
aboveWeeklyBand = close > lvlWeeklyBand
above78 = close > lvlWeeklyReclaim
belowGP = close < lvlGPLow
inGreyArea = close >= lvlGreyArea
belowMonthlyDamage = close < lvlMonthlyDamage

bearScore = 0
bearScore += above75 ? 0 : 1
bearScore += aboveBearMax ? 0 : 1
bearScore += aboveWeeklyBand ? 0 : 1
bearScore += above78 ? 0 : 1
bearScore += belowGP ? 1 : 0
bearScore += manualFundingHigh ? 1 : 0
bearScore += manualWhalesAbsent ? 1 : 0
bearScore += manualRetailLong ? 1 : 0
bearScore += manualFractalAligned ? 1 : 0
bearScore += accelerationActive ? 1 : 0

biasTxt = bearScore >= 7 ? "Bearish alpha" : bearScore >= 4 ? "Mixed / cautious" : "Bull risk"
biasColor = bearScore >= 7 ? color.red : bearScore >= 4 ? color.orange : color.green

if barstate.islast and showAlphaTable
    table.cell(t, 0, 0, "🦜 PAM", text_color=color.white, bgcolor=color.black)
    table.cell(t, 1, 0, biasTxt, text_color=color.white, bgcolor=biasColor)

    table.cell(t, 0, 1, "1H → 4H ladder")
    table.cell(t, 1, 1, mtf1hBreakout and mtf4hFollow ? "Rally active" : mtf1hBreakout ? "1H only" : "Not confirmed", text_color=color.white, bgcolor=mtf1hBreakout and mtf4hFollow ? color.blue : color.gray)

    table.cell(t, 0, 2, "75K H&S line")
    table.cell(t, 1, 2, above75 ? "Invalidation risk" : "Bearish OK", text_color=color.white, bgcolor=above75 ? color.red : color.green)

    table.cell(t, 0, 3, "75.1K bear max")
    table.cell(t, 1, 3, aboveBearMax ? "Bears losing" : "Bears defend", text_color=color.white, bgcolor=aboveBearMax ? color.red : color.green)

    table.cell(t, 0, 4, "75.3K weekly band")
    table.cell(t, 1, 4, aboveWeeklyBand ? "Reclaim risk" : "Rejected below", text_color=color.white, bgcolor=aboveWeeklyBand ? color.orange : color.green)

    table.cell(t, 0, 5, "75.9K grey area")
    table.cell(t, 1, 5, inGreyArea ? "Grey / bull risk" : "Below grey", text_color=color.white, bgcolor=inGreyArea ? color.orange : color.gray)

    table.cell(t, 0, 6, "78K HTF reclaim")
    table.cell(t, 1, 6, above78 ? "Bull HTF flip" : "Not reclaimed", text_color=color.white, bgcolor=above78 ? color.green : color.gray)

    table.cell(t, 0, 7, "71K monthly damage")
    table.cell(t, 1, 7, belowMonthlyDamage ? "Damage active" : "Not damaged", text_color=color.white, bgcolor=belowMonthlyDamage ? color.red : color.gray)

    table.cell(t, 0, 8, "Funding / retail")
    table.cell(t, 1, 8, manualFundingHigh and manualRetailLong ? "Crowded longs" : "Neutral", text_color=color.white, bgcolor=manualFundingHigh and manualRetailLong ? color.red : color.gray)

    table.cell(t, 0, 9, "Whales")
    table.cell(t, 1, 9, manualWhalesAbsent ? "No whale support" : "Whale support", text_color=color.white, bgcolor=manualWhalesAbsent ? color.red : color.green)

    table.cell(t, 0, 10, "Fear bounce")
    table.cell(t, 1, 10, manualFearBounce ? "Bounce ≠ base" : "Inactive", text_color=color.white, bgcolor=manualFearBounce ? color.orange : color.gray)

    table.cell(t, 0, 11, "Acceleration")
    table.cell(t, 1, 11, accelerationActive ? "Downside active" : "Not active", text_color=color.white, bgcolor=accelerationActive ? color.red : color.gray)
````
