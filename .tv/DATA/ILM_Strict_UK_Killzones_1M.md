<!-- tradingview-pine-id: PUB;6ce3641d5c5343cc8c42e21d251fa9a8 -->
<!-- tradingviewscripts-format: 1 -->
# ILM Strict UK Killzones [1M]

Source: https://www.tradingview.com/script/Lv7eeGtd-ILM-Strict-UK-Killzones-1M/

## Description

ILM Strict UK Killzones [1M]

Use on 1m in London or NY killzone

---

## Source Code

````pine
//@version=6
indicator(
     "ILM Strict UK Killzones [1M]",
     shorttitle = "ILM UK KZ 1M",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500
)

//────────────────────────────────────────────────────────────
// MODEL SETTINGS
//────────────────────────────────────────────────────────────
groupModel = "ILM Model"

swingLength = input.int(
     5,
     "Liquidity swing length",
     minval = 2,
     maxval = 30,
     group = groupModel
)

minimumSweepTicks = input.int(
     1,
     "Minimum sweep distance in ticks",
     minval = 0,
     maxval = 100,
     group = groupModel
)

requireSweepCloseBack = input.bool(
     true,
     "Sweep candle must close back through liquidity",
     group = groupModel
)

maximumSetupBars = input.int(
     120,
     "Maximum bars from sweep to signal",
     minval = 5,
     maxval = 300,
     group = groupModel
)

oneSignalPerSweep = input.bool(
     true,
     "One signal per liquidity sweep",
     group = groupModel
)

//────────────────────────────────────────────────────────────
// FVG SETTINGS
//────────────────────────────────────────────────────────────
groupFVG = "FVG Confirmation"

minimumFVGTicks = input.int(
     1,
     "Minimum FVG size in ticks",
     minval = 0,
     maxval = 100,
     group = groupFVG
)

requireDirectionalMiddleCandle = input.bool(
     true,
     "Require directional middle candle",
     group = groupFVG
)

useDisplacementFilter = input.bool(
     false,
     "Require displacement candle",
     group = groupFVG
)

atrLength = input.int(
     14,
     "ATR length",
     minval = 1,
     group = groupFVG
)

minimumBodyATR = input.float(
     0.5,
     "Minimum middle-candle body as ATR",
     minval = 0.1,
     step = 0.1,
     group = groupFVG
)

limitEntryMethod = input.string(
     "Nearest edge",
     "Limit-entry level",
     options = [
          "Nearest edge",
          "50% of FVG",
          "Far edge"
     ],
     group = groupFVG
)

//────────────────────────────────────────────────────────────
// OPTIONAL FILTERS
//────────────────────────────────────────────────────────────
groupFilters = "Optional Filters"

useStructureFilter = input.bool(
     false,
     "Require market structure shift",
     group = groupFilters
)

useEMAFilter = input.bool(
     false,
     "Use EMA direction filter",
     group = groupFilters
)

emaLength = input.int(
     100,
     "EMA length",
     minval = 1,
     group = groupFilters
)

//────────────────────────────────────────────────────────────
// STRICT UK KILLZONES
//────────────────────────────────────────────────────────────
groupSessions = "UK Killzones"

useLondonKillzone = input.bool(
     true,
     "Enable London killzone",
     group = groupSessions
)

useNewYorkKillzone = input.bool(
     true,
     "Enable New York killzone",
     group = groupSessions
)

// These are fixed UK local times.
// :23456 means Monday to Friday.
londonSession = input.session(
     "0700-1000:23456",
     "London: 07:00–10:00 UK",
     group = groupSessions
)

newYorkSession = input.session(
     "1430-1700:23456",
     "New York: 14:30–17:00 UK",
     group = groupSessions
)

onlyOneMinuteChart = input.bool(
     true,
     "Only allow signals on 1-minute chart",
     group = groupSessions
)

//────────────────────────────────────────────────────────────
// DISPLAY SETTINGS
//────────────────────────────────────────────────────────────
groupDisplay = "Display"

buyColour = input.color(
     color.rgb(0, 190, 200),
     "BUY colour",
     group = groupDisplay
)

sellColour = input.color(
     color.rgb(235, 35, 95),
     "SELL colour",
     group = groupDisplay
)

showLimitPrice = input.bool(
     false,
     "Show limit price",
     group = groupDisplay
)

showLimitLine = input.bool(
     false,
     "Show short limit line",
     group = groupDisplay
)

limitLineLength = input.int(
     10,
     "Limit line length",
     minval = 1,
     maxval = 100,
     group = groupDisplay
)

//────────────────────────────────────────────────────────────
// TIMEFRAME FILTER
//────────────────────────────────────────────────────────────
isOneMinute =
     timeframe.isminutes and
     timeframe.multiplier == 1

validTimeframe =
     not onlyOneMinuteChart or
     isOneMinute

//────────────────────────────────────────────────────────────
// EXACT UK-TIME SESSION FILTERS
//────────────────────────────────────────────────────────────
insideLondon =
     useLondonKillzone and
     not na(
          time(
               timeframe.period,
               londonSession,
               "Europe/London"
          )
     )

insideNewYork =
     useNewYorkKillzone and
     not na(
          time(
               timeframe.period,
               newYorkSession,
               "Europe/London"
          )
     )

// 0 = outside a killzone
// 1 = London killzone
// 2 = New York killzone
currentKillzone =
     insideLondon ? 1 :
     insideNewYork ? 2 :
     0

insideKillzone =
     currentKillzone != 0

validSignalEnvironment =
     validTimeframe and
     insideKillzone

// Requires the current candle and previous two candles
// to be inside the exact same killzone.
threeBarsInsideSameKillzone =
     currentKillzone != 0 and
     currentKillzone[1] == currentKillzone and
     currentKillzone[2] == currentKillzone

//────────────────────────────────────────────────────────────
// HIDDEN CALCULATIONS
//────────────────────────────────────────────────────────────
emaValue = ta.ema(close, emaLength)
atrValue = ta.atr(atrLength)

bullishEMAFilterPassed =
     not useEMAFilter or
     close > emaValue

bearishEMAFilterPassed =
     not useEMAFilter or
     close < emaValue

//────────────────────────────────────────────────────────────
// CONFIRMED LIQUIDITY LEVELS
//────────────────────────────────────────────────────────────
confirmedSwingHigh = ta.pivothigh(
     high,
     swingLength,
     swingLength
)

confirmedSwingLow = ta.pivotlow(
     low,
     swingLength,
     swingLength
)

var float buySideLiquidity = na
var float sellSideLiquidity = na

if not na(confirmedSwingHigh)
    buySideLiquidity := confirmedSwingHigh

if not na(confirmedSwingLow)
    sellSideLiquidity := confirmedSwingLow

//────────────────────────────────────────────────────────────
// LIQUIDITY SWEEPS
//────────────────────────────────────────────────────────────
minimumSweepDistance =
     minimumSweepTicks * syminfo.mintick

rawSellSideSweep =
     not na(sellSideLiquidity) and
     low < sellSideLiquidity - minimumSweepDistance

rawBuySideSweep =
     not na(buySideLiquidity) and
     high > buySideLiquidity + minimumSweepDistance

bullishLiquiditySweep =
     rawSellSideSweep and
     (
          not requireSweepCloseBack or
          close > sellSideLiquidity
     )

bearishLiquiditySweep =
     rawBuySideSweep and
     (
          not requireSweepCloseBack or
          close < buySideLiquidity
     )

var float lastSweptSellSide = na
var float lastSweptBuySide = na

newBullishSweep =
     validSignalEnvironment and
     bullishLiquiditySweep and
     not bearishLiquiditySweep and
     (
          na(lastSweptSellSide) or
          sellSideLiquidity != lastSweptSellSide
     )

newBearishSweep =
     validSignalEnvironment and
     bearishLiquiditySweep and
     not bullishLiquiditySweep and
     (
          na(lastSweptBuySide) or
          buySideLiquidity != lastSweptBuySide
     )

//────────────────────────────────────────────────────────────
// SETUP STATE
//────────────────────────────────────────────────────────────
var int setupDirection = 0
var int setupKillzone = 0
var int sweepBar = na

var float structureBreakLevel = na
var bool structureConfirmed = false
var bool signalIssued = false

var float inverseZoneTop = na
var float inverseZoneBottom = na

var int inverseDirection = 0
var int inverseCreationBar = na
var int inversionBar = na

var bool inverseFound = false
var bool inversionConfirmed = false

//────────────────────────────────────────────────────────────
// RESET FUNCTION CONDITIONS
//────────────────────────────────────────────────────────────
setupOutsideOriginalKillzone =
     setupDirection != 0 and
     (
          currentKillzone == 0 or
          currentKillzone != setupKillzone
     )

setupExpired =
     setupDirection != 0 and
     not na(sweepBar) and
     bar_index - sweepBar > maximumSetupBars

// Cancel the setup immediately outside its original killzone.
if setupOutsideOriginalKillzone or setupExpired
    setupDirection := 0
    setupKillzone := 0
    sweepBar := na

    structureBreakLevel := na
    structureConfirmed := false
    signalIssued := false

    inverseZoneTop := na
    inverseZoneBottom := na
    inverseDirection := 0
    inverseCreationBar := na
    inversionBar := na

    inverseFound := false
    inversionConfirmed := false

//────────────────────────────────────────────────────────────
// START BULLISH SETUP
//────────────────────────────────────────────────────────────
if newBullishSweep
    setupDirection := 1
    setupKillzone := currentKillzone
    sweepBar := bar_index

    structureBreakLevel := buySideLiquidity
    structureConfirmed := false
    signalIssued := false

    inverseZoneTop := na
    inverseZoneBottom := na
    inverseDirection := 0
    inverseCreationBar := na
    inversionBar := na

    inverseFound := false
    inversionConfirmed := false

    lastSweptSellSide := sellSideLiquidity

//────────────────────────────────────────────────────────────
// START BEARISH SETUP
//────────────────────────────────────────────────────────────
if newBearishSweep
    setupDirection := -1
    setupKillzone := currentKillzone
    sweepBar := bar_index

    structureBreakLevel := sellSideLiquidity
    structureConfirmed := false
    signalIssued := false

    inverseZoneTop := na
    inverseZoneBottom := na
    inverseDirection := 0
    inverseCreationBar := na
    inversionBar := na

    inverseFound := false
    inversionConfirmed := false

    lastSweptBuySide := buySideLiquidity

setupInsideSameKillzone =
     setupDirection != 0 and
     currentKillzone != 0 and
     currentKillzone == setupKillzone

//────────────────────────────────────────────────────────────
// OPTIONAL STRUCTURE SHIFT
//────────────────────────────────────────────────────────────
bullishStructureShift =
     setupInsideSameKillzone and
     setupDirection == 1 and
     not structureConfirmed and
     not na(structureBreakLevel) and
     close > structureBreakLevel

bearishStructureShift =
     setupInsideSameKillzone and
     setupDirection == -1 and
     not structureConfirmed and
     not na(structureBreakLevel) and
     close < structureBreakLevel

if bullishStructureShift or bearishStructureShift
    structureConfirmed := true

structureFilterPassed =
     not useStructureFilter or
     structureConfirmed

//────────────────────────────────────────────────────────────
// FAIR VALUE GAP DEFINITIONS
//────────────────────────────────────────────────────────────
minimumFVGDistance =
     minimumFVGTicks * syminfo.mintick

rawBullishFVG =
     threeBarsInsideSameKillzone and
     low > high[2]

rawBearishFVG =
     threeBarsInsideSameKillzone and
     high < low[2]

bullishFVGSize =
     rawBullishFVG ?
     low - high[2] :
     0.0

bearishFVGSize =
     rawBearishFVG ?
     low[2] - high :
     0.0

bullishMiddleCandle =
     close[1] > open[1]

bearishMiddleCandle =
     close[1] < open[1]

middleCandleBody =
     math.abs(close[1] - open[1])

middleCandleATR =
     atrValue[1]

bullishDisplacement =
     bullishMiddleCandle and
     not na(middleCandleATR) and
     middleCandleBody >= middleCandleATR * minimumBodyATR

bearishDisplacement =
     bearishMiddleCandle and
     not na(middleCandleATR) and
     middleCandleBody >= middleCandleATR * minimumBodyATR

bullishDisplacementPassed =
     not useDisplacementFilter or
     bullishDisplacement

bearishDisplacementPassed =
     not useDisplacementFilter or
     bearishDisplacement

bullishFVG =
     rawBullishFVG and
     bullishFVGSize >= minimumFVGDistance and
     (
          not requireDirectionalMiddleCandle or
          bullishMiddleCandle
     )

bearishFVG =
     rawBearishFVG and
     bearishFVGSize >= minimumFVGDistance and
     (
          not requireDirectionalMiddleCandle or
          bearishMiddleCandle
     )

bullishFVGTop = low
bullishFVGBottom = high[2]

bearishFVGTop = low[2]
bearishFVGBottom = high

//────────────────────────────────────────────────────────────
// FIND OPPOSING FVG AFTER SWEEP
//────────────────────────────────────────────────────────────
if setupInsideSameKillzone and
   setupDirection == 1 and
   not inversionConfirmed and
   bearishFVG and
   not na(sweepBar) and
   bar_index > sweepBar

    inverseZoneTop := bearishFVGTop
    inverseZoneBottom := bearishFVGBottom
    inverseDirection := -1
    inverseCreationBar := bar_index
    inverseFound := true

if setupInsideSameKillzone and
   setupDirection == -1 and
   not inversionConfirmed and
   bullishFVG and
   not na(sweepBar) and
   bar_index > sweepBar

    inverseZoneTop := bullishFVGTop
    inverseZoneBottom := bullishFVGBottom
    inverseDirection := 1
    inverseCreationBar := bar_index
    inverseFound := true

//────────────────────────────────────────────────────────────
// CLOSE THROUGH THE INVERSE FVG
//────────────────────────────────────────────────────────────
bullishInversion =
     setupInsideSameKillzone and
     setupDirection == 1 and
     inverseFound and
     not inversionConfirmed and
     inverseDirection == -1 and
     not na(inverseZoneTop) and
     not na(inverseCreationBar) and
     bar_index > inverseCreationBar and
     close > inverseZoneTop

bearishInversion =
     setupInsideSameKillzone and
     setupDirection == -1 and
     inverseFound and
     not inversionConfirmed and
     inverseDirection == 1 and
     not na(inverseZoneBottom) and
     not na(inverseCreationBar) and
     bar_index > inverseCreationBar and
     close < inverseZoneBottom

if bullishInversion
    inversionConfirmed := true
    inversionBar := bar_index

if bearishInversion
    inversionConfirmed := true
    inversionBar := bar_index

//────────────────────────────────────────────────────────────
// NEW FVG REQUIRED AFTER INVERSION
//────────────────────────────────────────────────────────────
confirmingBullishFVG =
     setupInsideSameKillzone and
     setupDirection == 1 and
     inversionConfirmed and
     not na(inversionBar) and
     bar_index > inversionBar and
     bullishFVG and
     bullishDisplacementPassed

confirmingBearishFVG =
     setupInsideSameKillzone and
     setupDirection == -1 and
     inversionConfirmed and
     not na(inversionBar) and
     bar_index > inversionBar and
     bearishFVG and
     bearishDisplacementPassed

//────────────────────────────────────────────────────────────
// LIMIT ENTRY LEVELS
//────────────────────────────────────────────────────────────
bullishLimitEntry =
     limitEntryMethod == "Nearest edge" ?
     bullishFVGTop :
     limitEntryMethod == "50% of FVG" ?
     (bullishFVGTop + bullishFVGBottom) / 2.0 :
     bullishFVGBottom

bearishLimitEntry =
     limitEntryMethod == "Nearest edge" ?
     bearishFVGBottom :
     limitEntryMethod == "50% of FVG" ?
     (bearishFVGTop + bearishFVGBottom) / 2.0 :
     bearishFVGTop

//────────────────────────────────────────────────────────────
// FINAL SIGNALS
//────────────────────────────────────────────────────────────
signalAvailable =
     not oneSignalPerSweep or
     not signalIssued

buySignal =
     barstate.isconfirmed and
     isOneMinute and
     insideKillzone and
     setupInsideSameKillzone and
     signalAvailable and
     setupDirection == 1 and
     confirmingBullishFVG and
     structureFilterPassed and
     bullishEMAFilterPassed

sellSignal =
     barstate.isconfirmed and
     isOneMinute and
     insideKillzone and
     setupInsideSameKillzone and
     signalAvailable and
     setupDirection == -1 and
     confirmingBearishFVG and
     structureFilterPassed and
     bearishEMAFilterPassed

//────────────────────────────────────────────────────────────
// BUY LABEL
//────────────────────────────────────────────────────────────
if buySignal
    signalIssued := true

    label.new(
         x = bar_index,
         y = bullishLimitEntry,
         text = showLimitPrice ?
              "BUY\n" +
              str.tostring(
                   bullishLimitEntry,
                   format.mintick
              ) :
              "BUY",
         style = label.style_label_up,
         color = buyColour,
         textcolor = color.white,
         size = size.small
    )

    if showLimitLine
        line.new(
             x1 = bar_index,
             y1 = bullishLimitEntry,
             x2 = bar_index + limitLineLength,
             y2 = bullishLimitEntry,
             color = buyColour,
             width = 2
        )

//────────────────────────────────────────────────────────────
// SELL LABEL
//────────────────────────────────────────────────────────────
if sellSignal
    signalIssued := true

    label.new(
         x = bar_index,
         y = bearishLimitEntry,
         text = showLimitPrice ?
              "SELL\n" +
              str.tostring(
                   bearishLimitEntry,
                   format.mintick
              ) :
              "SELL",
         style = label.style_label_down,
         color = sellColour,
         textcolor = color.white,
         size = size.small
    )

    if showLimitLine
        line.new(
             x1 = bar_index,
             y1 = bearishLimitEntry,
             x2 = bar_index + limitLineLength,
             y2 = bearishLimitEntry,
             color = sellColour,
             width = 2
        )

//────────────────────────────────────────────────────────────
// RESET AFTER SIGNAL
//────────────────────────────────────────────────────────────
if (buySignal or sellSignal) and oneSignalPerSweep
    setupDirection := 0
    setupKillzone := 0
    sweepBar := na

    structureBreakLevel := na
    structureConfirmed := false

    inverseZoneTop := na
    inverseZoneBottom := na
    inverseDirection := 0
    inverseCreationBar := na
    inversionBar := na

    inverseFound := false
    inversionConfirmed := false

//────────────────────────────────────────────────────────────
// ALERTS
//────────────────────────────────────────────────────────────
alertcondition(
     buySignal,
     title = "ILM UK Killzone 1M BUY",
     message = "ILM BUY limit setup confirmed inside the UK-time killzone on {{ticker}}."
)

alertcondition(
     sellSignal,
     title = "ILM UK Killzone 1M SELL",
     message = "ILM SELL limit setup confirmed inside the UK-time killzone on {{ticker}}."
)
````
