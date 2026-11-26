# SpxSnipper - Filtered Fair Value Gap (ATR Min/Max Filter)

- url: https://www.tradingview.com/script/wH8yoeS2-SpxSnipper-Filtered-Fair-Value-Gap-ATR-Min-Max-Filter/
- type: indicator
- pine_id: PUB;997a9ffa45ce4917bdc6feebfed23f3a
- version: 1.0

## Description

Filtered Fair Value Gap with ATR Size Filter is a visual market-structure study designed to highlight selected 3-candle Fair Value Gap areas directly on the chart.

The script identifies bullish and bearish imbalance zones based on a classic 3-candle Fair Value Gap structure, then applies additional filters to reduce noise and focus only on cleaner setups.

For a bullish Fair Value Gap, the script checks whether the low of the third candle is above the high of the first candle. The area between those two prices is marked as the bullish imbalance zone.

For a bearish Fair Value Gap, the script checks whether the high of the third candle is below the low of the first candle. The area between those two prices is marked as the bearish imbalance zone.

The first candle’s color is intentionally ignored. The logic focuses mainly on the second and third candles of the structure.

Additional filters include:

1. Candle direction filter  
The second and third candles must follow the direction of the Fair Value Gap. For bullish structures, both candles must close above their open. For bearish structures, both candles must close below their open.

2. Second candle close-location filter  
The second candle must close near the directional edge of its range. In bullish structures, it must close near the upper part of its candle range. In bearish structures, it must close near the lower part of its candle range.

3. Third candle close-location filter  
The third candle must also close near the directional edge of its own range. This is intended to avoid structures where the third candle has a large opposite wick.

4. Midpoint confirmation  
For bullish structures, the third candle must close above the midpoint of the second candle. For bearish structures, the third candle must close below the midpoint of the second candle.

5. ATR-based size filter  
The Fair Value Gap size must be within user-defined minimum and maximum thresholds based on ATR. This helps filter out gaps that are too small or unusually large relative to recent volatility.

The script also includes an optional higher-timeframe lock feature. When enabled, the Fair Value Gap calculation can be locked to a selected timeframe, such as 5 minutes, while viewing a lower timeframe chart. This allows users to observe higher-timeframe imbalance zones without changing the active chart timeframe.

Main inputs:

- ATR Length
- Minimum FVG size as a percentage of ATR
- Maximum FVG size as a percentage of ATR
- Second candle close-location percentage
- Third candle close-location percentage
- Optional higher-timeframe lock
- Zone extension length
- Bullish and bearish zone colors
- Optional signal markers

This indicator is intended for visual analysis, market-structure study, and educational use. It does not provide financial advice, trading recommendations, or guaranteed outcomes. Users should combine it with their own analysis and risk-management process.

## Source Code

````pine
//@version=6
indicator("SpxSnipper - Filtered Fair Value Gap (ATR Min/Max Filter)", overlay=true, max_boxes_count=300)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
groupLogic = "Logic"

useLocked5m     = input.bool(false, "Lock FVG to Higher Timeframe", group=groupLogic)
lockedTf        = input.timeframe("5", "Locked FVG Timeframe", group=groupLogic)

atrLen          = input.int(14, "ATR Length", minval=1, group=groupLogic)
minGapAtrPctIn  = input.float(25.0, "Min FVG Size (% of ATR)", minval=0.0, step=1.0, group=groupLogic)
maxGapAtrPctIn  = input.float(100.0, "Max FVG Size (% of ATR)", minval=0.0, step=1.0, group=groupLogic)

c2CloseEdgePct  = input.float(30.0, "2nd Candle Close Distance From Edge (%)", minval=1.0, maxval=50.0, step=1.0, group=groupLogic)
c3CloseEdgePct  = input.float(30.0, "3rd Candle Close Distance From Edge (%)", minval=1.0, maxval=50.0, step=1.0, group=groupLogic)

groupVisual = "Visual"

extendBars      = input.int(20, "Extend Zone Right (bars)", minval=1, group=groupVisual)
bullBorderColor = input.color(color.lime, "Bullish Border", group=groupVisual)
bullFillColor   = input.color(color.new(color.lime, 82), "Bullish Fill", group=groupVisual)
bearBorderColor = input.color(color.red, "Bearish Border", group=groupVisual)
bearFillColor   = input.color(color.new(color.red, 82), "Bearish Fill", group=groupVisual)
showMarkers     = input.bool(true, "Show Signal Markers", group=groupVisual)

//--------------------------------------------------
// FVG calculation function
//--------------------------------------------------
f_fvg() =>
    atrValue = ta.atr(atrLen)

    minGapAtrPct = math.min(minGapAtrPctIn, maxGapAtrPctIn)
    maxGapAtrPct = math.max(minGapAtrPctIn, maxGapAtrPctIn)

    minGap = atrValue * minGapAtrPct / 100.0
    maxGap = atrValue * maxGapAtrPct / 100.0

    // Candle 1 = [2], Candle 2 = [1], Candle 3 = current
    // Candle 1 color is intentionally ignored.
    c2Bull = close[1] > open[1]
    c3Bull = close > open

    c2Bear = close[1] < open[1]
    c3Bear = close < open

    c2Range = high[1] - low[1]
    c2Mid   = (high[1] + low[1]) / 2.0

    c3Range = high - low

    // 2nd candle close location filter
    c2BullStrong = c2Range > 0 and close[1] >= high[1] - c2Range * (c2CloseEdgePct / 100.0)
    c2BearStrong = c2Range > 0 and close[1] <= low[1] + c2Range * (c2CloseEdgePct / 100.0)

    // 3rd candle close location filter
    // Bullish: 3rd candle must close near its upper edge.
    // Bearish: 3rd candle must close near its lower edge.
    c3BullStrong = c3Range > 0 and close >= high - c3Range * (c3CloseEdgePct / 100.0)
    c3BearStrong = c3Range > 0 and close <= low + c3Range * (c3CloseEdgePct / 100.0)

    // 3rd candle confirmation
    // Bullish: close above midpoint of candle 2.
    // Bearish: close below midpoint of candle 2.
    c3BullConfirm = close > c2Mid
    c3BearConfirm = close < c2Mid

    // Classic 3-candle FVG definitions
    bullGapTop    = low
    bullGapBottom = high[2]
    bullGapSize   = bullGapTop - bullGapBottom
    bullFVG       = low > high[2]

    bearGapTop    = low[2]
    bearGapBottom = high
    bearGapSize   = bearGapTop - bearGapBottom
    bearFVG       = high < low[2]

    // ATR min/max filter
    bullGapOk = bullGapSize >= minGap and bullGapSize <= maxGap
    bearGapOk = bearGapSize >= minGap and bearGapSize <= maxGap

    // Final signals
    bullSignal =
         c2Bull
     and c3Bull
     and c2BullStrong
     and c3BullStrong
     and c3BullConfirm
     and bullFVG
     and bullGapOk

    bearSignal =
         c2Bear
     and c3Bear
     and c2BearStrong
     and c3BearStrong
     and c3BearConfirm
     and bearFVG
     and bearGapOk

    [
         bullSignal,
         bearSignal,
         bullGapTop,
         bullGapBottom,
         bearGapTop,
         bearGapBottom,
         time,
         time[2]
     ]

//--------------------------------------------------
// Current timeframe values
//--------------------------------------------------
[
     bullCurrent,
     bearCurrent,
     bullTopCurrent,
     bullBottomCurrent,
     bearTopCurrent,
     bearBottomCurrent,
     signalTimeCurrent,
     leftTimeCurrent
 ] = f_fvg()

//--------------------------------------------------
// Locked higher timeframe values
//--------------------------------------------------
[
     bullLocked,
     bearLocked,
     bullTopLocked,
     bullBottomLocked,
     bearTopLocked,
     bearBottomLocked,
     signalTimeLocked,
     leftTimeLocked
 ] = request.security(
     syminfo.tickerid,
     lockedTf,
     f_fvg(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
 )

//--------------------------------------------------
// Select active mode
//--------------------------------------------------
bullSignal = useLocked5m ? bullLocked : bullCurrent
bearSignal = useLocked5m ? bearLocked : bearCurrent

bullGapTop = useLocked5m ? bullTopLocked : bullTopCurrent
bullGapBottom = useLocked5m ? bullBottomLocked : bullBottomCurrent

bearGapTop = useLocked5m ? bearTopLocked : bearTopCurrent
bearGapBottom = useLocked5m ? bearBottomLocked : bearBottomCurrent

signalTime = useLocked5m ? signalTimeLocked : signalTimeCurrent
leftTime   = useLocked5m ? leftTimeLocked : leftTimeCurrent

//--------------------------------------------------
// Avoid duplicate boxes
//--------------------------------------------------
var int lastBullTime = na
var int lastBearTime = na

validBull = bullSignal and not na(signalTime) and not na(leftTime)
validBear = bearSignal and not na(signalTime) and not na(leftTime)

newBullSignal = validBull and (na(lastBullTime) or signalTime != lastBullTime)
newBearSignal = validBear and (na(lastBearTime) or signalTime != lastBearTime)

//--------------------------------------------------
// Right extension in time
//--------------------------------------------------
activeTfSeconds = timeframe.in_seconds(useLocked5m ? lockedTf : timeframe.period)
rightTime = signalTime + extendBars * activeTfSeconds * 1000

//--------------------------------------------------
// Draw bullish FVG
//--------------------------------------------------
if newBullSignal
    box.new(
         left=leftTime,
         top=bullGapTop,
         right=rightTime,
         bottom=bullGapBottom,
         xloc=xloc.bar_time,
         border_color=bullBorderColor,
         bgcolor=bullFillColor
     )

    lastBullTime := signalTime

//--------------------------------------------------
// Draw bearish FVG
//--------------------------------------------------
if newBearSignal
    box.new(
         left=leftTime,
         top=bearGapTop,
         right=rightTime,
         bottom=bearGapBottom,
         xloc=xloc.bar_time,
         border_color=bearBorderColor,
         bgcolor=bearFillColor
     )

    lastBearTime := signalTime

//--------------------------------------------------
// Markers
//--------------------------------------------------
plotshape(
     showMarkers and newBullSignal,
     title="Bullish FVG",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullBorderColor,
     size=size.tiny,
     text="FVG"
 )

plotshape(
     showMarkers and newBearSignal,
     title="Bearish FVG",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearBorderColor,
     size=size.tiny,
     text="FVG"
 )

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(newBullSignal, title="Bullish Filtered FVG", message="Bullish filtered FVG detected")
alertcondition(newBearSignal, title="Bearish Filtered FVG", message="Bearish filtered FVG detected")
````
