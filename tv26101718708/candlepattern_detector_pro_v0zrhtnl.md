# Candle-Pattern Detector Pro

- url: https://www.tradingview.com/script/v0ZrHTNl/
- type: indicator
- pine_id: PUB;063ddafb23894e7fbe5a995fc71727f3
- version: 3.0

## Description

Candle-Pattern Detector Pro (CPD-Pro++)

This indicator automatically identifies 48 classic candlestick patterns on the chart, marking each occurrence with a label showing the pattern's abbreviation (e.g., HA = Hammer, LE = Long Engulfing, 3WS = Three White Soldiers, etc.), placed directly above or below the corresponding candle.

How it works
The script analyzes the relationship between body, upper shadow, and lower shadow of each candle (and of previous candles, when a pattern requires multi-bar confirmation) to classify reversal, continuation, and indecision formations — such as Hammer, Engulfing, Morning/Evening Star, Three Methods, Kicking, and others.

How traders can use it

Fast visual identification: instead of memorizing dozens of patterns, the trader sees the abbreviation directly on the candle where the pattern occurred.
Confluence with other tools: the patterns detected here work best as confirmation context — for example, a Hammer (HA) or Bullish Engulfing (LE) near a support/liquidity zone carries far more weight than the same pattern in isolation.
Configurable alerts: each of the 48 patterns has its own individual alertcondition, allowing traders to set up alerts for a specific pattern (e.g., only Morning Star) without having to watch the chart manually.
Per-pattern customization: each pattern can be individually enabled/disabled and given a custom color, letting traders build a lean setup with only the patterns relevant to their strategy (e.g., only top/bottom reversal patterns).

Limitations and recommended use

Candlestick patterns are probabilistic, not deterministic — they should not be used as a standalone entry/exit signal.
It's recommended to combine this indicator's signals with market structure (support/resistance, trend, volume) to filter out false positives.
This script is a technical analysis aid and does not constitute investment advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © Canhoto-Medium

//@version=6

indicator("Candle-Pattern Detector Pro", shorttitle="CPD-Pro++", precision=0, overlay=true, max_labels_count=500)

//-----------------------------------------

// Color inputs (botões para ajustar a cor de cada padrão) — SIGLAS incluídas

//-----------------------------------------

enable_hammer         = input.bool(true,           "Show [HA]",                        group="Label Colors")

col_hammer            = input.color(color.green,  "Hammer color [HA]",                       group="Label Colors")

enable_invHammer      = input.bool(true,           "Show [IHA]",             group="Label Colors")

col_invHammer         = input.color(color.green,  "Inverted Hammer color [IHA]",            group="Label Colors")

enable_shootStar      = input.bool(true,           "Show [SS]",                group="Label Colors")

col_shootStar         = input.color(color.red,    "Shooting Star color [SS]",               group="Label Colors")

enable_doji           = input.bool(true,           "Show [DO]",                         group="Label Colors")

col_doji              = input.color(color.gray,   "Doji color [DO]",                        group="Label Colors")

enable_dragonfly      = input.bool(true,           "Show [DFD]",             group="Label Colors")

col_dragonfly         = input.color(color.gray,   "Dragonfly Doji color [DFD]",             group="Label Colors")

enable_gravestone     = input.bool(true,           "Show [GSD]",            group="Label Colors")

col_gravestone        = input.color(color.gray,   "Gravestone Doji color [GSD]",            group="Label Colors")

enable_bullEng        = input.bool(true,           "Show [LE]",               group="Label Colors")

col_bullEng           = input.color(color.lime,   "Long Engulfing color [LE]",              group="Label Colors")

enable_bearEng        = input.bool(true,           "Show [SE]",              group="Label Colors")

col_bearEng           = input.color(color.maroon, "Short Engulfing color [SE]",             group="Label Colors")

enable_haramiBull     = input.bool(true,           "Show [LH]",                  group="Label Colors")

col_haramiBull        = input.color(color.lime,   "Long Harami color [LH]",                 group="Label Colors")

enable_haramiBear     = input.bool(true,           "Show [SH]",                 group="Label Colors")

col_haramiBear        = input.color(color.maroon, "Short Harami color [SH]",                group="Label Colors")

enable_piercing       = input.bool(true,           "Show [PL]",                group="Label Colors")

col_piercing          = input.color(color.green,  "Piercing Line color [PL]",               group="Label Colors")

enable_darkCloud      = input.bool(true,           "Show [DCC]",            group="Label Colors")

col_darkCloud         = input.color(color.red,    "Dark Cloud Cover color [DCC]",           group="Label Colors")

enable_morningStar    = input.bool(true,           "Show [MS]",                 group="Label Colors")

col_morningStar       = input.color(color.green,  "Morning Star color [MS]",                group="Label Colors")

enable_eveningStar    = input.bool(true,           "Show [ES]",                 group="Label Colors")

col_eveningStar       = input.color(color.red,    "Evening Star color [ES]",                group="Label Colors")

enable_tweezerTop     = input.bool(true,           "Show [TP]",                  group="Label Colors")

col_tweezerTop        = input.color(color.maroon, "Tweezer Top color [TP]",                 group="Label Colors")

enable_tweezerBottom  = input.bool(true,           "Show [TB]",               group="Label Colors")

col_tweezerBottom     = input.color(color.lime,   "Tweezer Bottom color [TB]",              group="Label Colors")

enable_threeWhiteSoldiers = input.bool(true,     "Show [3WS]",        group="Label Colors")

col_threeWhiteSoldiers= input.color(color.lime,   "Three White Soldiers color [3WS]",       group="Label Colors")

enable_threeBlackCrows= input.bool(true,           "Show [3BC]",           group="Label Colors")

col_threeBlackCrows   = input.color(color.maroon, "Three Black Crows color [3BC]",          group="Label Colors")

enable_bullMarubozu   = input.bool(true,           "Show [LM]",                group="Label Colors")

col_bullMarubozu      = input.color(color.lime,   "Long Marubozu color [LM]",               group="Label Colors")

enable_bearMarubozu   = input.bool(true,           "Show [SM]",               group="Label Colors")

col_bearMarubozu      = input.color(color.maroon, "Short Marubozu color [SM]",              group="Label Colors")

enable_bullAbandonedBaby = input.bool(true,       "Show [LAB]",         group="Label Colors")

col_bullAbandonedBaby = input.color(color.lime,   "Long Abandoned Baby color [LAB]",         group="Label Colors")

enable_bearAbandonedBaby = input.bool(true,       "Show [SAB]",        group="Label Colors")

col_bearAbandonedBaby = input.color(color.red,    "Short Abandoned Baby color [SAB]",        group="Label Colors")

// --- Novos padrões (com siglas) ---

enable_haramiCross    = input.bool(true,           "Show [HC]",                 group="Label Colors")

col_haramiCross       = input.color(color.orange, "Harami Cross color [HC]",                  group="Label Colors")

enable_morningDojiStar= input.bool(true,           "Show [MDS]",                group="Label Colors")

col_morningDojiStar   = input.color(color.green,  "Morning Doji Star color [MDS]",            group="Label Colors")

enable_eveningDojiStar= input.bool(true,           "Show [EDS]",                group="Label Colors")

col_eveningDojiStar   = input.color(color.red,    "Evening Doji Star color [EDS]",            group="Label Colors")

enable_spinningTop    = input.bool(true,           "Show [ST]",                 group="Label Colors")

col_spinningTop       = input.color(color.silver, "Spinning Top color [ST]",                  group="Label Colors")

enable_beltHoldBull   = input.bool(true,           "Show [BHB]",                group="Label Colors")

col_beltHoldBull      = input.color(color.lime,   "Belt Hold Bull color [BHB]",               group="Label Colors")

enable_beltHoldBear   = input.bool(true,           "Show [BHB2]",               group="Label Colors")

col_beltHoldBear      = input.color(color.maroon, "Belt Hold Bear color [BHB2]",              group="Label Colors")

enable_upsideTasuki   = input.bool(true,           "Show [UTG]",                group="Label Colors")

col_upsideTasuki      = input.color(color.lime,   "Upside Tasuki Gap color [UTG]",            group="Label Colors")

enable_downsideTasuki = input.bool(true,           "Show [DTG]",                group="Label Colors")

col_downsideTasuki    = input.color(color.maroon, "Downside Tasuki Gap color [DTG]",          group="Label Colors")

enable_threeInsideUp  = input.bool(true,           "Show [3IU]",                group="Label Colors")

col_threeInsideUp     = input.color(color.lime,   "Three Inside Up color [3IU]",              group="Label Colors")

enable_threeInsideDown= input.bool(true,           "Show [3ID]",                group="Label Colors")

col_threeInsideDown   = input.color(color.maroon, "Three Inside Down color [3ID]",            group="Label Colors")

enable_threeOutsideUp = input.bool(true,           "Show [3OU]",                group="Label Colors")

col_threeOutsideUp    = input.color(color.lime,   "Three Outside Up color [3OU]",             group="Label Colors")

enable_threeOutsideDown= input.bool(true,          "Show [3OD]",                group="Label Colors")

col_threeOutsideDown  = input.color(color.maroon, "Three Outside Down color [3OD]",           group="Label Colors")

enable_risingThree    = input.bool(true,           "Show [RTM]",                group="Label Colors")

col_risingThree       = input.color(color.lime,   "Rising Three Methods color [RTM]",         group="Label Colors")

enable_fallingThree   = input.bool(true,           "Show [FTM]",                group="Label Colors")

col_fallingThree      = input.color(color.maroon, "Falling Three Methods color [FTM]",        group="Label Colors")

enable_threeLineStrike= input.bool(true,           "Show [3LS]",                group="Label Colors")

col_threeLineStrike   = input.color(color.orange, "Three Line Strike color [3LS]",            group="Label Colors")

enable_concealingBaby = input.bool(true,           "Show [CBS]",                group="Label Colors")

col_concealingBaby    = input.color(color.maroon, "Concealing Baby Swallow color [CBS]",      group="Label Colors")

enable_kickingBull    = input.bool(true,           "Show [KB]",                 group="Label Colors")

col_kickingBull       = input.color(color.lime,   "Kicking Bull color [KB]",                   group="Label Colors")

enable_kickingBear    = input.bool(true,           "Show [KBR]",                group="Label Colors")

col_kickingBear       = input.color(color.maroon, "Kicking Bear color [KBR]",                 group="Label Colors")

enable_separatingBull = input.bool(true,           "Show [SPLB]",               group="Label Colors")

col_separatingBull    = input.color(color.lime,   "Separating Lines Bull color [SPLB]",       group="Label Colors")

enable_separatingBear = input.bool(true,           "Show [SPLS]",               group="Label Colors")

col_separatingBear    = input.color(color.maroon, "Separating Lines Bear color [SPLS]",       group="Label Colors")

enable_matchingLow    = input.bool(true,           "Show [ML]",                 group="Label Colors")

col_matchingLow       = input.color(color.orange, "Matching Low color [ML]",                    group="Label Colors")

enable_matchingHigh   = input.bool(true,           "Show [MH]",                 group="Label Colors")

col_matchingHigh      = input.color(color.orange, "Matching High color [MH]",                   group="Label Colors")

enable_onNeck         = input.bool(true,           "Show [ON]",                 group="Label Colors")

col_onNeck            = input.color(color.orange, "On-Neck Line color [ON]",                    group="Label Colors")

enable_inNeck         = input.bool(true,           "Show [IN]",                 group="Label Colors")

col_inNeck            = input.color(color.orange, "In-Neck Line color [IN]",                    group="Label Colors")

enable_thrusting      = input.bool(true,           "Show [TH]",                 group="Label Colors")

col_thrusting         = input.color(color.orange, "Thrusting Line color [TH]",                  group="Label Colors")

enable_stickSandwich  = input.bool(true,           "Show [SSW]",                group="Label Colors")

col_stickSandwich     = input.color(color.orange, "Stick Sandwich color [SSW]",                 group="Label Colors")

enable_homingPigeon   = input.bool(true,           "Show [HP]",                 group="Label Colors")

col_homingPigeon      = input.color(color.silver, "Homing Pigeon color [HP]",                   group="Label Colors")

enable_triStar        = input.bool(true,           "Show [TS]",                 group="Label Colors")

col_triStar           = input.color(color.yellow, "Tri Star color [TS]",                        group="Label Colors")

//-----------------------------------------

// Helper functions

//-----------------------------------------

body() => math.abs(close - open)

upperShadow() => high - math.max(open, close)

lowerShadow() => math.min(open, close) - low

totalSize() => high - low

isBull() => close > open

isBear() => close < open

isWhite(i) => close[i] > open[i]

isBlack(i) => close[i] < open[i]

// CORREÇÃO: filtro de tendência prévia para diferenciar Inverted Hammer (fundo)

// de Shooting Star (topo) — sem isso os dois disparavam juntos no mesmo candle.

trendSMA = ta.sma(close, 10)

downtrendPrior = close[1] < trendSMA[1]

uptrendPrior   = close[1] > trendSMA[1]

//-----------------------------------------

// Candle patterns (48 total)

//-----------------------------------------

isHammer() => body() < totalSize() * 0.3 and lowerShadow() >= body() * 2 and upperShadow() <= body()

// CORRIGIDO: exige contexto de baixa anterior (senão colide com Shooting Star)

isInvertedHammer() => body() < totalSize() * 0.3 and upperShadow() >= body() * 2 and lowerShadow() <= body() and downtrendPrior

// CORRIGIDO: exige contexto de alta anterior (senão colide com Inverted Hammer)

isShootingStar() => body() < totalSize() * 0.3 and upperShadow() > body() * 2 and lowerShadow() <= body() and uptrendPrior

isDoji() => body() <= totalSize() * 0.1

isDragonflyDoji() => isDoji() and lowerShadow() > totalSize() * 0.6 and upperShadow() < totalSize() * 0.1

isGravestoneDoji() => isDoji() and upperShadow() > totalSize() * 0.6 and lowerShadow() < totalSize() * 0.1

isLongEngulfing() => close > open and close[1] < open[1] and open <= close[1] and close >= open[1]

isShortEngulfing() => close < open and close[1] > open[1] and open >= close[1] and close <= open[1]

isHaramiLong() => close[1] < open[1] and close > open and open >= close[1] and close <= open[1]

isHaramiShort() => close[1] > open[1] and close < open and open <= close[1] and close >= open[1]

isHaramiCross() => isDoji() and ((close[1] < open[1] and close > open and open <= close[1]) or (close[1] > open[1] and close < open and open >= close[1]))

isPiercingLine() => close[1] < open[1] and open < low[1] and close > (open[1] + close[1]) / 2 and close < open[1]

isDarkCloudCover() => close[1] > open[1] and open > high[1] and close < (open[1] + close[1]) / 2 and close > open[1]

isMorningStar() => close[2] < open[2] and (isDoji()[1] or body()[1] <= totalSize()[1]*0.25) and close > (open[2] + close[2]) / 2

isEveningStar() => close[2] > open[2] and (isDoji()[1] or body()[1] <= totalSize()[1]*0.25) and close < (open[2] + close[2]) / 2

isMorningDojiStar() => close[2] < open[2] and isDoji()[1] and close > (open[2] + close[2]) / 2

isEveningDojiStar() => close[2] > open[2] and isDoji()[1] and close < (open[2] + close[2]) / 2

isTweezerTop() => high == high[1] and close[1] > open[1] and close < open

isTweezerBottom() => low == low[1] and close[1] < open[1] and close > open

isThreeWhiteSoldiers() => close > open and close[1] > open[1] and close[2] > open[2] and close > close[1] and close[1] > close[2] and upperShadow() < body() * 0.5 and lowerShadow() < body() * 0.5 and upperShadow()[1] < body()[1] * 0.5 and lowerShadow()[1] < body()[1] * 0.5 and upperShadow()[2] < body()[2] * 0.5 and lowerShadow()[2] < body()[2] * 0.5

isThreeBlackCrows() => close < open and close[1] < open[1] and close[2] < open[2] and close < close[1] and close[1] < close[2] and upperShadow() < body() * 0.5 and lowerShadow() < body() * 0.5 and upperShadow()[1] < body()[1] * 0.5 and lowerShadow()[1] < body()[1] * 0.5 and upperShadow()[2] < body()[2] * 0.5 and lowerShadow()[2] < body()[2] * 0.5

isLongMarubozu() => close > open and lowerShadow() <= body() * 0.1 and upperShadow() <= body() * 0.1

isShortMarubozu() => close < open and lowerShadow() <= body() * 0.1 and upperShadow() <= body() * 0.1

isLongAbandonedBaby() => close[2] < open[2] and isDoji()[1] and low[1] > high[2] and close > (open[2] + close[2]) / 2

isShortAbandonedBaby() => close[2] > open[2] and isDoji()[1] and high[1] < low[2] and close < (open[2] + close[2]) / 2

isSpinningTop() => body() <= totalSize() * 0.3 and upperShadow() > body()*0.5 and lowerShadow() > body()*0.5

isBeltHoldBull() => isBull() and lowerShadow() <= body()*0.1 and open <= low and close > open

isBeltHoldBear() => isBear() and upperShadow() <= body()*0.1 and open >= high and close < open

isUpsideTasukiGap() => close[2] < open[2] and close[1] > open[1] and low > high[2] and close > open[1] and close[1] > close[2]

isDownsideTasukiGap() => close[2] > open[2] and close[1] < open[1] and high < low[2] and close < open[1] and close[1] < close[2]

isThreeInsideUp() => close[2] < open[2] and close > open and close > close[1] and open > close[1]

isThreeInsideDown() => close[2] > open[2] and close < open and close < close[1] and open < close[1]

isThreeOutsideUp() => close[1] < open[1] and close > open and close > open[1] and close >= close[1]

isThreeOutsideDown() => close[1] > open[1] and close < open and close < open[1] and close <= close[1]

isRisingThreeMethods() => close[4] < open[4] and close[3] > open[3] and close[2] > open[2] and close[1] > open[1] and close > close[1] and lowerShadow() < body()*0.5

isFallingThreeMethods() => close[4] > open[4] and close[3] < open[3] and close[2] < open[2] and close[1] < open[1] and close < close[1] and upperShadow() < body()*0.5

isThreeLineStrike() => close[3] > open[3] and close[2] > open[2] and close[1] > open[1] and close < open[3] and close < open[2] and close < open[1]

// CORRIGIDO: padrão é integralmente baixista — candle atual precisa ser de baixa, não de alta

isConcealingBabySwallow() => close[4] < open[4] and high[1] > high[2] and high[2] > high[3] and close < open and close < (open[4]+close[4])/2

isKickingBull() => isShortMarubozu()[1] and isLongMarubozu() and open > high[1]

isKickingBear() => isLongMarubozu()[1] and isShortMarubozu() and open < low[1]

isSeparatingLinesBull() => close[1] < open[1] and close > open and math.abs(open - open[1]) <= totalSize()[1] * 0.05

isSeparatingLinesBear() => close[1] > open[1] and close < open and math.abs(open - open[1]) <= totalSize()[1] * 0.05

isMatchingLow() => math.abs(close - close[1]) <= syminfo.mintick * 2 and close < open and close[1] < open[1]

isMatchingHigh() => math.abs(close - close[1]) <= syminfo.mintick * 2 and close > open and close[1] > open[1]

// CORRIGIDO: On-Neck / In-Neck / Thrusting agora têm faixas mutuamente exclusivas

// (0–5% do corpo anterior = On-Neck; 5–25% = In-Neck; 25–50% = Thrusting)

isOnNeck() => close[1] < open[1] and close > open and low > low[1] and close >= close[1] and close <= close[1] + (body()[1] * 0.05)

isInNeck() => close[1] < open[1] and close > open and low > low[1] and close > close[1] + (body()[1] * 0.05) and close <= close[1] + (body()[1] * 0.25)

isThrusting() => close[1] < open[1] and close > open and close > close[1] + (body()[1] * 0.25) and close < (open[1] + close[1]) / 2

// CORRIGIDO: candle atual (3º) precisa ser de baixa como o 1º, e o fechamento do meio (2º)

// precisa ficar acima do fechamento do 1º/3º — não o contrário

isStickSandwich() => close[2] < open[2] and close[1] > open[1] and close < open and math.abs(close - close[2]) <= syminfo.mintick * 2 and close[1] > close[2] and close[1] > close

isHomingPigeon() => close[1] < open[1] and close > open and open > open[1] and close < close[1]

isTriStar() => isDoji() and isDoji()[1] and isDoji()[2] and math.abs(high - high[1]) < totalSize()*0.1 and math.abs(high[1] - high[2]) < totalSize()*0.1

//-----------------------------------------

// Check patterns

//-----------------------------------------

hammer = isHammer()

invHammer = isInvertedHammer()

shootStar = isShootingStar()

doji = isDoji()

dragonfly = isDragonflyDoji()

gravestone = isGravestoneDoji()

bullEng = isLongEngulfing()

bearEng = isShortEngulfing()

haramiBull = isHaramiLong()

haramiBear = isHaramiShort()

haramiCross = isHaramiCross()

piercing = isPiercingLine()

darkCloud = isDarkCloudCover()

morningStar = isMorningStar()

eveningStar = isEveningStar()

morningDojiStar = isMorningDojiStar()

eveningDojiStar = isEveningDojiStar()

tweezerTop = isTweezerTop()

tweezerBottom = isTweezerBottom()

threeWhiteSoldiers = isThreeWhiteSoldiers()

threeBlackCrows = isThreeBlackCrows()

bullMarubozu = isLongMarubozu()

bearMarubozu = isShortMarubozu()

bullAbandonedBaby = isLongAbandonedBaby()

bearAbandonedBaby = isShortAbandonedBaby()

spinningTop = isSpinningTop()

beltHoldBull = isBeltHoldBull()

beltHoldBear = isBeltHoldBear()

upsideTasuki = isUpsideTasukiGap()

downsideTasuki = isDownsideTasukiGap()

threeInsideUp = isThreeInsideUp()

threeInsideDown = isThreeInsideDown()

threeOutsideUp = isThreeOutsideUp()

threeOutsideDown = isThreeOutsideDown()

risingThree = isRisingThreeMethods()

fallingThree = isFallingThreeMethods()

threeLineStrike = isThreeLineStrike()

concealingBaby = isConcealingBabySwallow()

kickingBull = isKickingBull()

kickingBear = isKickingBear()

separatingBull = isSeparatingLinesBull()

separatingBear = isSeparatingLinesBear()

matchingLow = isMatchingLow()

matchingHigh = isMatchingHigh()

onNeck = isOnNeck()

inNeck = isInNeck()

thrusting = isThrusting()

stickSandwich = isStickSandwich()

homingPigeon = isHomingPigeon()

triStar = isTriStar()

//-----------------------------------------

//-----------------------------------------
// Plotting on chart — realtime label tracking
// Current-bar labels follow the live candle; confirmed labels remain fixed.
// Historical labels remain stored for per-pattern deletion.
//-----------------------------------------

var label[] hammerLabels = array.new<label>()
var label[] dragonflyLabels = array.new<label>()
var label[] bullEngLabels = array.new<label>()
var label[] haramiBullLabels = array.new<label>()
var label[] piercingLabels = array.new<label>()
var label[] morningStarLabels = array.new<label>()
var label[] tweezerBottomLabels = array.new<label>()
var label[] threeWhiteSoldiersLabels = array.new<label>()
var label[] bullMarubozuLabels = array.new<label>()
var label[] bullAbandonedBabyLabels = array.new<label>()
var label[] dojiLabels = array.new<label>()
var label[] gravestoneLabels = array.new<label>()
var label[] invHammerLabels = array.new<label>()
var label[] shootStarLabels = array.new<label>()
var label[] bearEngLabels = array.new<label>()
var label[] haramiBearLabels = array.new<label>()
var label[] darkCloudLabels = array.new<label>()
var label[] eveningStarLabels = array.new<label>()
var label[] tweezerTopLabels = array.new<label>()
var label[] threeBlackCrowsLabels = array.new<label>()
var label[] bearMarubozuLabels = array.new<label>()
var label[] bearAbandonedBabyLabels = array.new<label>()
var label[] haramiCrossLabels = array.new<label>()
var label[] morningDojiStarLabels = array.new<label>()
var label[] eveningDojiStarLabels = array.new<label>()
var label[] spinningTopLabels = array.new<label>()
var label[] beltHoldBullLabels = array.new<label>()
var label[] beltHoldBearLabels = array.new<label>()
var label[] upsideTasukiLabels = array.new<label>()
var label[] downsideTasukiLabels = array.new<label>()
var label[] threeInsideUpLabels = array.new<label>()
var label[] threeInsideDownLabels = array.new<label>()
var label[] threeOutsideUpLabels = array.new<label>()
var label[] threeOutsideDownLabels = array.new<label>()
var label[] risingThreeLabels = array.new<label>()
var label[] fallingThreeLabels = array.new<label>()
var label[] threeLineStrikeLabels = array.new<label>()
var label[] concealingBabyLabels = array.new<label>()
var label[] kickingBullLabels = array.new<label>()
var label[] kickingBearLabels = array.new<label>()
var label[] separatingBullLabels = array.new<label>()
var label[] separatingBearLabels = array.new<label>()
var label[] matchingLowLabels = array.new<label>()
var label[] matchingHighLabels = array.new<label>()
var label[] onNeckLabels = array.new<label>()
var label[] inNeckLabels = array.new<label>()
var label[] thrustingLabels = array.new<label>()
var label[] stickSandwichLabels = array.new<label>()
var label[] homingPigeonLabels = array.new<label>()
var label[] triStarLabels = array.new<label>()

var label live_hammer = na
var label live_dragonfly = na
var label live_bullEng = na
var label live_haramiBull = na
var label live_piercing = na
var label live_morningStar = na
var label live_tweezerBottom = na
var label live_threeWhiteSoldiers = na
var label live_bullMarubozu = na
var label live_bullAbandonedBaby = na
var label live_doji = na
var label live_gravestone = na
var label live_invHammer = na
var label live_shootStar = na
var label live_bearEng = na
var label live_haramiBear = na
var label live_darkCloud = na
var label live_eveningStar = na
var label live_tweezerTop = na
var label live_threeBlackCrows = na
var label live_bearMarubozu = na
var label live_bearAbandonedBaby = na
var label live_haramiCross = na
var label live_morningDojiStar = na
var label live_eveningDojiStar = na
var label live_spinningTop = na
var label live_beltHoldBull = na
var label live_beltHoldBear = na
var label live_upsideTasuki = na
var label live_downsideTasuki = na
var label live_threeInsideUp = na
var label live_threeInsideDown = na
var label live_threeOutsideUp = na
var label live_threeOutsideDown = na
var label live_risingThree = na
var label live_fallingThree = na
var label live_threeLineStrike = na
var label live_concealingBaby = na
var label live_kickingBull = na
var label live_kickingBear = na
var label live_separatingBull = na
var label live_separatingBear = na
var label live_matchingLow = na
var label live_matchingHigh = na
var label live_onNeck = na
var label live_inNeck = na
var label live_thrusting = na
var label live_stickSandwich = na
var label live_homingPigeon = na
var label live_triStar = na

f_manageLabel(live, history, condition, enabled, enabledPrev, txt, y, ylocValue, styleValue, bg, tc) =>
    label result = live

    if not enabled and enabledPrev
        if array.size(history) > 0
            for i = 0 to array.size(history) - 1
                label.delete(array.get(history, i))
            array.clear(history)
        if not na(result)
            label.delete(result)
            result := na

    if enabled
        if barstate.isrealtime
            if condition
                if na(result)
                    result := label.new(bar_index, y, txt, xloc=xloc.bar_index, yloc=ylocValue, style=styleValue, color=bg, textcolor=tc, size=size.small)
                else
                    label.set_xy(result, bar_index, y)
                    label.set_yloc(result, ylocValue)
                    label.set_style(result, styleValue)
                    label.set_color(result, bg)
                    label.set_textcolor(result, tc)
                    label.set_text(result, txt)
            else if not na(result)
                label.delete(result)
                result := na

            if barstate.isconfirmed and not na(result)
                array.push(history, result)
                result := na
        else if condition
            fixedLabel = label.new(bar_index, y, txt, xloc=xloc.bar_index, yloc=ylocValue, style=styleValue, color=bg, textcolor=tc, size=size.small)
            array.push(history, fixedLabel)

    result

live_hammer := f_manageLabel(live_hammer, hammerLabels, hammer, enable_hammer, enable_hammer[1], "HA", low, yloc.belowbar, label.style_label_up, col_hammer, color.white)
live_dragonfly := f_manageLabel(live_dragonfly, dragonflyLabels, dragonfly, enable_dragonfly, enable_dragonfly[1], "DFD", low, yloc.belowbar, label.style_label_up, col_dragonfly, color.white)
live_bullEng := f_manageLabel(live_bullEng, bullEngLabels, bullEng, enable_bullEng, enable_bullEng[1], "LE", low, yloc.belowbar, label.style_label_up, col_bullEng, color.black)
live_haramiBull := f_manageLabel(live_haramiBull, haramiBullLabels, haramiBull, enable_haramiBull, enable_haramiBull[1], "LH", low, yloc.belowbar, label.style_label_up, col_haramiBull, color.black)
live_piercing := f_manageLabel(live_piercing, piercingLabels, piercing, enable_piercing, enable_piercing[1], "PL", low, yloc.belowbar, label.style_label_up, col_piercing, color.white)
live_morningStar := f_manageLabel(live_morningStar, morningStarLabels, morningStar, enable_morningStar, enable_morningStar[1], "MS", low, yloc.belowbar, label.style_label_up, col_morningStar, color.white)
live_tweezerBottom := f_manageLabel(live_tweezerBottom, tweezerBottomLabels, tweezerBottom, enable_tweezerBottom, enable_tweezerBottom[1], "TB", low, yloc.belowbar, label.style_label_up, col_tweezerBottom, color.black)
live_threeWhiteSoldiers := f_manageLabel(live_threeWhiteSoldiers, threeWhiteSoldiersLabels, threeWhiteSoldiers, enable_threeWhiteSoldiers, enable_threeWhiteSoldiers[1], "3WS", low, yloc.belowbar, label.style_label_up, col_threeWhiteSoldiers, color.black)
live_bullMarubozu := f_manageLabel(live_bullMarubozu, bullMarubozuLabels, bullMarubozu, enable_bullMarubozu, enable_bullMarubozu[1], "LM", low, yloc.belowbar, label.style_label_up, col_bullMarubozu, color.black)
live_bullAbandonedBaby := f_manageLabel(live_bullAbandonedBaby, bullAbandonedBabyLabels, bullAbandonedBaby, enable_bullAbandonedBaby, enable_bullAbandonedBaby[1], "LAB", low, yloc.belowbar, label.style_label_up, col_bullAbandonedBaby, color.black)
live_doji := f_manageLabel(live_doji, dojiLabels, doji, enable_doji, enable_doji[1], "DO", high, yloc.abovebar, label.style_label_left, col_doji, color.white)
live_gravestone := f_manageLabel(live_gravestone, gravestoneLabels, gravestone, enable_gravestone, enable_gravestone[1], "GSD", high, yloc.abovebar, label.style_label_left, col_gravestone, color.white)
live_invHammer := f_manageLabel(live_invHammer, invHammerLabels, invHammer, enable_invHammer, enable_invHammer[1], "IHA", high, yloc.abovebar, label.style_label_down, col_invHammer, color.white)
live_shootStar := f_manageLabel(live_shootStar, shootStarLabels, shootStar, enable_shootStar, enable_shootStar[1], "SS", high, yloc.abovebar, label.style_label_down, col_shootStar, color.white)
live_bearEng := f_manageLabel(live_bearEng, bearEngLabels, bearEng, enable_bearEng, enable_bearEng[1], "SE", high, yloc.abovebar, label.style_label_down, col_bearEng, color.white)
live_haramiBear := f_manageLabel(live_haramiBear, haramiBearLabels, haramiBear, enable_haramiBear, enable_haramiBear[1], "SH", high, yloc.abovebar, label.style_label_down, col_haramiBear, color.white)
live_darkCloud := f_manageLabel(live_darkCloud, darkCloudLabels, darkCloud, enable_darkCloud, enable_darkCloud[1], "DCC", high, yloc.abovebar, label.style_label_down, col_darkCloud, color.white)
live_eveningStar := f_manageLabel(live_eveningStar, eveningStarLabels, eveningStar, enable_eveningStar, enable_eveningStar[1], "ES", high, yloc.abovebar, label.style_label_down, col_eveningStar, color.white)
live_tweezerTop := f_manageLabel(live_tweezerTop, tweezerTopLabels, tweezerTop, enable_tweezerTop, enable_tweezerTop[1], "TP", high, yloc.abovebar, label.style_label_down, col_tweezerTop, color.white)
live_threeBlackCrows := f_manageLabel(live_threeBlackCrows, threeBlackCrowsLabels, threeBlackCrows, enable_threeBlackCrows, enable_threeBlackCrows[1], "3BC", high, yloc.abovebar, label.style_label_down, col_threeBlackCrows, color.white)
live_bearMarubozu := f_manageLabel(live_bearMarubozu, bearMarubozuLabels, bearMarubozu, enable_bearMarubozu, enable_bearMarubozu[1], "SM", high, yloc.abovebar, label.style_label_down, col_bearMarubozu, color.white)
live_bearAbandonedBaby := f_manageLabel(live_bearAbandonedBaby, bearAbandonedBabyLabels, bearAbandonedBaby, enable_bearAbandonedBaby, enable_bearAbandonedBaby[1], "SAB", high, yloc.abovebar, label.style_label_down, col_bearAbandonedBaby, color.white)
live_haramiCross := f_manageLabel(live_haramiCross, haramiCrossLabels, haramiCross, enable_haramiCross, enable_haramiCross[1], "HC", high, yloc.abovebar, label.style_label_left, col_haramiCross, color.white)
live_morningDojiStar := f_manageLabel(live_morningDojiStar, morningDojiStarLabels, morningDojiStar, enable_morningDojiStar, enable_morningDojiStar[1], "MDS", low, yloc.belowbar, label.style_label_up, col_morningDojiStar, color.white)
live_eveningDojiStar := f_manageLabel(live_eveningDojiStar, eveningDojiStarLabels, eveningDojiStar, enable_eveningDojiStar, enable_eveningDojiStar[1], "EDS", high, yloc.abovebar, label.style_label_down, col_eveningDojiStar, color.white)
live_spinningTop := f_manageLabel(live_spinningTop, spinningTopLabels, spinningTop, enable_spinningTop, enable_spinningTop[1], "ST", close, yloc.abovebar, label.style_label_left, col_spinningTop, color.black)
live_beltHoldBull := f_manageLabel(live_beltHoldBull, beltHoldBullLabels, beltHoldBull, enable_beltHoldBull, enable_beltHoldBull[1], "BHB", low, yloc.belowbar, label.style_label_up, col_beltHoldBull, color.black)
live_beltHoldBear := f_manageLabel(live_beltHoldBear, beltHoldBearLabels, beltHoldBear, enable_beltHoldBear, enable_beltHoldBear[1], "BHB2", high, yloc.abovebar, label.style_label_down, col_beltHoldBear, color.white)
live_upsideTasuki := f_manageLabel(live_upsideTasuki, upsideTasukiLabels, upsideTasuki, enable_upsideTasuki, enable_upsideTasuki[1], "UTG", low, yloc.belowbar, label.style_label_up, col_upsideTasuki, color.white)
live_downsideTasuki := f_manageLabel(live_downsideTasuki, downsideTasukiLabels, downsideTasuki, enable_downsideTasuki, enable_downsideTasuki[1], "DTG", high, yloc.abovebar, label.style_label_down, col_downsideTasuki, color.white)
live_threeInsideUp := f_manageLabel(live_threeInsideUp, threeInsideUpLabels, threeInsideUp, enable_threeInsideUp, enable_threeInsideUp[1], "3IU", low, yloc.belowbar, label.style_label_up, col_threeInsideUp, color.black)
live_threeInsideDown := f_manageLabel(live_threeInsideDown, threeInsideDownLabels, threeInsideDown, enable_threeInsideDown, enable_threeInsideDown[1], "3ID", high, yloc.abovebar, label.style_label_down, col_threeInsideDown, color.white)
live_threeOutsideUp := f_manageLabel(live_threeOutsideUp, threeOutsideUpLabels, threeOutsideUp, enable_threeOutsideUp, enable_threeOutsideUp[1], "3OU", low, yloc.belowbar, label.style_label_up, col_threeOutsideUp, color.white)
live_threeOutsideDown := f_manageLabel(live_threeOutsideDown, threeOutsideDownLabels, threeOutsideDown, enable_threeOutsideDown, enable_threeOutsideDown[1], "3OD", high, yloc.abovebar, label.style_label_down, col_threeOutsideDown, color.white)
live_risingThree := f_manageLabel(live_risingThree, risingThreeLabels, risingThree, enable_risingThree, enable_risingThree[1], "RTM", low, yloc.belowbar, label.style_label_up, col_risingThree, color.white)
live_fallingThree := f_manageLabel(live_fallingThree, fallingThreeLabels, fallingThree, enable_fallingThree, enable_fallingThree[1], "FTM", high, yloc.abovebar, label.style_label_down, col_fallingThree, color.white)
live_threeLineStrike := f_manageLabel(live_threeLineStrike, threeLineStrikeLabels, threeLineStrike, enable_threeLineStrike, enable_threeLineStrike[1], "3LS", high, yloc.abovebar, label.style_label_left, col_threeLineStrike, color.white)
live_concealingBaby := f_manageLabel(live_concealingBaby, concealingBabyLabels, concealingBaby, enable_concealingBaby, enable_concealingBaby[1], "CBS", high, yloc.abovebar, label.style_label_left, col_concealingBaby, color.white)
live_kickingBull := f_manageLabel(live_kickingBull, kickingBullLabels, kickingBull, enable_kickingBull, enable_kickingBull[1], "KB", low, yloc.belowbar, label.style_label_up, col_kickingBull, color.white)
live_kickingBear := f_manageLabel(live_kickingBear, kickingBearLabels, kickingBear, enable_kickingBear, enable_kickingBear[1], "KBR", high, yloc.abovebar, label.style_label_down, col_kickingBear, color.white)
live_separatingBull := f_manageLabel(live_separatingBull, separatingBullLabels, separatingBull, enable_separatingBull, enable_separatingBull[1], "SPLB", low, yloc.belowbar, label.style_label_up, col_separatingBull, color.white)
live_separatingBear := f_manageLabel(live_separatingBear, separatingBearLabels, separatingBear, enable_separatingBear, enable_separatingBear[1], "SPLS", high, yloc.abovebar, label.style_label_down, col_separatingBear, color.white)
live_matchingLow := f_manageLabel(live_matchingLow, matchingLowLabels, matchingLow, enable_matchingLow, enable_matchingLow[1], "ML", low, yloc.belowbar, label.style_label_up, col_matchingLow, color.white)
live_matchingHigh := f_manageLabel(live_matchingHigh, matchingHighLabels, matchingHigh, enable_matchingHigh, enable_matchingHigh[1], "MH", high, yloc.abovebar, label.style_label_down, col_matchingHigh, color.white)
live_onNeck := f_manageLabel(live_onNeck, onNeckLabels, onNeck, enable_onNeck, enable_onNeck[1], "ON", low, yloc.belowbar, label.style_label_up, col_onNeck, color.white)
live_inNeck := f_manageLabel(live_inNeck, inNeckLabels, inNeck, enable_inNeck, enable_inNeck[1], "IN", low, yloc.belowbar, label.style_label_up, col_inNeck, color.white)
live_thrusting := f_manageLabel(live_thrusting, thrustingLabels, thrusting, enable_thrusting, enable_thrusting[1], "TH", low, yloc.belowbar, label.style_label_up, col_thrusting, color.white)
live_stickSandwich := f_manageLabel(live_stickSandwich, stickSandwichLabels, stickSandwich, enable_stickSandwich, enable_stickSandwich[1], "SSW", low, yloc.belowbar, label.style_label_up, col_stickSandwich, color.white)
live_homingPigeon := f_manageLabel(live_homingPigeon, homingPigeonLabels, homingPigeon, enable_homingPigeon, enable_homingPigeon[1], "HP", low, yloc.belowbar, label.style_label_up, col_homingPigeon, color.black)
live_triStar := f_manageLabel(live_triStar, triStarLabels, triStar, enable_triStar, enable_triStar[1], "TS", high, yloc.abovebar, label.style_label_left, col_triStar, color.black)

// Alerts (cada padrão)

//-----------------------------------------

alertcondition(hammer,      "Hammer", "Hammer pattern detected")

alertcondition(invHammer,   "Inverted Hammer", "Inverted Hammer pattern detected")

alertcondition(shootStar,   "Shooting Star", "Shooting Star pattern detected")

alertcondition(doji,        "Doji", "Doji pattern detected")

alertcondition(dragonfly,   "Dragonfly Doji", "Dragonfly Doji pattern detected")

alertcondition(gravestone,  "Gravestone Doji", "Gravestone Doji pattern detected")

alertcondition(bullEng,     "Long Engulfing", "Long Engulfing pattern detected")

alertcondition(bearEng,     "Short Engulfing", "Short Engulfing pattern detected")

alertcondition(haramiBull,  "Long Harami", "Long Harami pattern detected")

alertcondition(haramiBear,  "Short Harami", "Short Harami pattern detected")

alertcondition(haramiCross, "Harami Cross", "Harami Cross pattern detected")

alertcondition(piercing,    "Piercing Line", "Piercing Line pattern detected")

alertcondition(darkCloud,   "Dark Cloud Cover", "Dark Cloud Cover pattern detected")

alertcondition(morningStar, "Morning Star", "Morning Star pattern detected")

alertcondition(eveningStar, "Evening Star", "Evening Star pattern detected")

alertcondition(morningDojiStar, "Morning Doji Star", "Morning Doji Star detected")

alertcondition(eveningDojiStar, "Evening Doji Star", "Evening Doji Star detected")

alertcondition(tweezerTop,  "Tweezer Top", "Tweezer Top pattern detected")

alertcondition(tweezerBottom,"Tweezer Bottom", "Tweezer Bottom pattern detected")

alertcondition(threeWhiteSoldiers, "Three White Soldiers", "Three White Soldiers pattern detected")

alertcondition(threeBlackCrows, "Three Black Crows", "Three Black Crows pattern detected")

alertcondition(bullMarubozu, "Long Marubozu", "Long Marubozu pattern detected")

alertcondition(bearMarubozu, "Short Marubozu", "Short Marubozu pattern detected")

alertcondition(bullAbandonedBaby, "Long Abandoned Baby", "Long Abandoned Baby pattern detected")

alertcondition(bearAbandonedBaby, "Short Abandoned Baby", "Short Abandoned Baby pattern detected")

alertcondition(spinningTop, "Spinning Top", "Spinning Top detected")

alertcondition(beltHoldBull, "Belt Hold Bull", "Belt Hold Bull detected")

alertcondition(beltHoldBear, "Belt Hold Bear", "Belt Hold Bear detected")

alertcondition(upsideTasuki, "Upside Tasuki Gap", "Upside Tasuki Gap detected")

alertcondition(downsideTasuki, "Downside Tasuki Gap", "Downside Tasuki Gap detected")

alertcondition(threeInsideUp, "Three Inside Up", "Three Inside Up detected")

alertcondition(threeInsideDown, "Three Inside Down", "Three Inside Down detected")

alertcondition(threeOutsideUp, "Three Outside Up", "Three Outside Up detected")

alertcondition(threeOutsideDown, "Three Outside Down", "Three Outside Down detected")

alertcondition(risingThree, "Rising Three Methods", "Rising Three Methods detected")

alertcondition(fallingThree, "Falling Three Methods", "Falling Three Methods detected")

alertcondition(threeLineStrike, "Three Line Strike", "Three Line Strike detected")

alertcondition(concealingBaby, "Concealing Baby Swallow", "Concealing Baby Swallow detected")

alertcondition(kickingBull, "Kicking Bull", "Kicking Bull detected")

alertcondition(kickingBear, "Kicking Bear", "Kicking Bear detected")

alertcondition(separatingBull, "Separating Lines Bull", "Separating Lines Bull detected")

alertcondition(separatingBear, "Separating Lines Bear", "Separating Lines Bear detected")

alertcondition(matchingLow, "Matching Low", "Matching Low detected")

alertcondition(matchingHigh, "Matching High", "Matching High detected")

alertcondition(onNeck, "On-Neck Line", "On-Neck Line detected")

alertcondition(inNeck, "In-Neck Line", "In-Neck Line detected")

alertcondition(thrusting, "Thrusting Line", "Thrusting Line detected")

alertcondition(stickSandwich, "Stick Sandwich", "Stick Sandwich detected")

alertcondition(homingPigeon, "Homing Pigeon", "Homing Pigeon detected")

alertcondition(triStar, "Tri Star", "Tri Star (three dojis) detected")
````
