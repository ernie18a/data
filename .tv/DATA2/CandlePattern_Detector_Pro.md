<!-- tradingview-pine-id: PUB;063ddafb23894e7fbe5a995fc71727f3 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Candle-Pattern Detector Pro

Source: https://www.tradingview.com/script/v0ZrHTNl/

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

---

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

//-----------------------------------------
// Candle patterns (48 total)
//-----------------------------------------
isHammer() => body() < totalSize() * 0.3 and lowerShadow() >= body() * 2 and upperShadow() <= body()
isInvertedHammer() => body() < totalSize() * 0.3 and upperShadow() >= body() * 2 and lowerShadow() <= body()
isShootingStar() => body() < totalSize() * 0.3 and upperShadow() > body() * 2 and lowerShadow() <= body()
isDoji() => body() <= totalSize() * 0.1
isDragonflyDoji() => isDoji() and lowerShadow() > totalSize() * 0.6 and upperShadow() < totalSize() * 0.1
isGravestoneDoji() => isDoji() and upperShadow() > totalSize() * 0.6 and lowerShadow() < totalSize() * 0.1
isLongEngulfing() => close > open and close[1] < open[1] and open <= close[1] and close >= open[1]
isShortEngulfing() => close < open and close[1] > open[1] and open >= close[1] and close <= open[1]
// CORRIGIDO: Harami exige que o corpo atual fique CONTIDO no corpo anterior (inverso do Engulfing)
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
isConcealingBabySwallow() => close[4] < open[4] and high[1] > high[2] and high[2] > high[3] and close > open and close > (open[4]+close[4])/2
// CORRIGIDO: Kicking exige que os dois candles sejam Marubozu (sem sombras relevantes) + gap
isKickingBull() => isShortMarubozu()[1] and isLongMarubozu() and open > high[1]
isKickingBear() => isLongMarubozu()[1] and isShortMarubozu() and open < low[1]
// CORRIGIDO: Separating Lines exige ABERTURA praticamente igual entre os dois candles (não engolfamento)
isSeparatingLinesBull() => close[1] < open[1] and close > open and math.abs(open - open[1]) <= totalSize()[1] * 0.05
isSeparatingLinesBear() => close[1] > open[1] and close < open and math.abs(open - open[1]) <= totalSize()[1] * 0.05
// CORRIGIDO: Matching Low/High comparam FECHAMENTOS (não mínimas/máximas)
isMatchingLow() => math.abs(close - close[1]) <= syminfo.mintick * 2 and close < open and close[1] < open[1]
isMatchingHigh() => math.abs(close - close[1]) <= syminfo.mintick * 2 and close > open and close[1] > open[1]
// CORRIGIDO: limiar ancorado em close[1] (o "pescoço"), não em open[1]
isOnNeck() => close[1] < open[1] and close > open and low > low[1] and close >= close[1] and close <= close[1] + (body()[1] * 0.05)
isInNeck() => close[1] < open[1] and close > open and low > low[1] and close > close[1] and close <= close[1] + (body()[1] * 0.25)
isThrusting() => close[1] < open[1] and close > open and close < (open[1] + close[1]) / 2
isStickSandwich() => close[2] < open[2] and close[1] > open[1] and close > open and close > close[2] and close[1] < close[2]
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
// Plotting on chart (using label.new, size.small) — label tracking and deletion when disabled
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

if not enable_hammer and enable_hammer[1]
    for i = 0 to array.size(hammerLabels) - 1
        label.delete(array.get(hammerLabels, i))
    array.clear(hammerLabels)
if not enable_dragonfly and enable_dragonfly[1]
    for i = 0 to array.size(dragonflyLabels) - 1
        label.delete(array.get(dragonflyLabels, i))
    array.clear(dragonflyLabels)
if not enable_bullEng and enable_bullEng[1]
    for i = 0 to array.size(bullEngLabels) - 1
        label.delete(array.get(bullEngLabels, i))
    array.clear(bullEngLabels)
if not enable_haramiBull and enable_haramiBull[1]
    for i = 0 to array.size(haramiBullLabels) - 1
        label.delete(array.get(haramiBullLabels, i))
    array.clear(haramiBullLabels)
if not enable_piercing and enable_piercing[1]
    for i = 0 to array.size(piercingLabels) - 1
        label.delete(array.get(piercingLabels, i))
    array.clear(piercingLabels)
if not enable_morningStar and enable_morningStar[1]
    for i = 0 to array.size(morningStarLabels) - 1
        label.delete(array.get(morningStarLabels, i))
    array.clear(morningStarLabels)
if not enable_tweezerBottom and enable_tweezerBottom[1]
    for i = 0 to array.size(tweezerBottomLabels) - 1
        label.delete(array.get(tweezerBottomLabels, i))
    array.clear(tweezerBottomLabels)
if not enable_threeWhiteSoldiers and enable_threeWhiteSoldiers[1]
    for i = 0 to array.size(threeWhiteSoldiersLabels) - 1
        label.delete(array.get(threeWhiteSoldiersLabels, i))
    array.clear(threeWhiteSoldiersLabels)
if not enable_bullMarubozu and enable_bullMarubozu[1]
    for i = 0 to array.size(bullMarubozuLabels) - 1
        label.delete(array.get(bullMarubozuLabels, i))
    array.clear(bullMarubozuLabels)
if not enable_bullAbandonedBaby and enable_bullAbandonedBaby[1]
    for i = 0 to array.size(bullAbandonedBabyLabels) - 1
        label.delete(array.get(bullAbandonedBabyLabels, i))
    array.clear(bullAbandonedBabyLabels)
if not enable_doji and enable_doji[1]
    for i = 0 to array.size(dojiLabels) - 1
        label.delete(array.get(dojiLabels, i))
    array.clear(dojiLabels)
if not enable_gravestone and enable_gravestone[1]
    for i = 0 to array.size(gravestoneLabels) - 1
        label.delete(array.get(gravestoneLabels, i))
    array.clear(gravestoneLabels)
if not enable_invHammer and enable_invHammer[1]
    for i = 0 to array.size(invHammerLabels) - 1
        label.delete(array.get(invHammerLabels, i))
    array.clear(invHammerLabels)
if not enable_shootStar and enable_shootStar[1]
    for i = 0 to array.size(shootStarLabels) - 1
        label.delete(array.get(shootStarLabels, i))
    array.clear(shootStarLabels)
if not enable_bearEng and enable_bearEng[1]
    for i = 0 to array.size(bearEngLabels) - 1
        label.delete(array.get(bearEngLabels, i))
    array.clear(bearEngLabels)
if not enable_haramiBear and enable_haramiBear[1]
    for i = 0 to array.size(haramiBearLabels) - 1
        label.delete(array.get(haramiBearLabels, i))
    array.clear(haramiBearLabels)
if not enable_darkCloud and enable_darkCloud[1]
    for i = 0 to array.size(darkCloudLabels) - 1
        label.delete(array.get(darkCloudLabels, i))
    array.clear(darkCloudLabels)
if not enable_eveningStar and enable_eveningStar[1]
    for i = 0 to array.size(eveningStarLabels) - 1
        label.delete(array.get(eveningStarLabels, i))
    array.clear(eveningStarLabels)
if not enable_tweezerTop and enable_tweezerTop[1]
    for i = 0 to array.size(tweezerTopLabels) - 1
        label.delete(array.get(tweezerTopLabels, i))
    array.clear(tweezerTopLabels)
if not enable_threeBlackCrows and enable_threeBlackCrows[1]
    for i = 0 to array.size(threeBlackCrowsLabels) - 1
        label.delete(array.get(threeBlackCrowsLabels, i))
    array.clear(threeBlackCrowsLabels)
if not enable_bearMarubozu and enable_bearMarubozu[1]
    for i = 0 to array.size(bearMarubozuLabels) - 1
        label.delete(array.get(bearMarubozuLabels, i))
    array.clear(bearMarubozuLabels)
if not enable_bearAbandonedBaby and enable_bearAbandonedBaby[1]
    for i = 0 to array.size(bearAbandonedBabyLabels) - 1
        label.delete(array.get(bearAbandonedBabyLabels, i))
    array.clear(bearAbandonedBabyLabels)

if not enable_haramiCross and enable_haramiCross[1]
    for i = 0 to array.size(haramiCrossLabels) - 1
        label.delete(array.get(haramiCrossLabels, i))
    array.clear(haramiCrossLabels)
if not enable_morningDojiStar and enable_morningDojiStar[1]
    for i = 0 to array.size(morningDojiStarLabels) - 1
        label.delete(array.get(morningDojiStarLabels, i))
    array.clear(morningDojiStarLabels)
if not enable_eveningDojiStar and enable_eveningDojiStar[1]
    for i = 0 to array.size(eveningDojiStarLabels) - 1
        label.delete(array.get(eveningDojiStarLabels, i))
    array.clear(eveningDojiStarLabels)
if not enable_spinningTop and enable_spinningTop[1]
    for i = 0 to array.size(spinningTopLabels) - 1
        label.delete(array.get(spinningTopLabels, i))
    array.clear(spinningTopLabels)
if not enable_beltHoldBull and enable_beltHoldBull[1]
    for i = 0 to array.size(beltHoldBullLabels) - 1
        label.delete(array.get(beltHoldBullLabels, i))
    array.clear(beltHoldBullLabels)
if not enable_beltHoldBear and enable_beltHoldBear[1]
    for i = 0 to array.size(beltHoldBearLabels) - 1
        label.delete(array.get(beltHoldBearLabels, i))
    array.clear(beltHoldBearLabels)
if not enable_upsideTasuki and enable_upsideTasuki[1]
    for i = 0 to array.size(upsideTasukiLabels) - 1
        label.delete(array.get(upsideTasukiLabels, i))
    array.clear(upsideTasukiLabels)
if not enable_downsideTasuki and enable_downsideTasuki[1]
    for i = 0 to array.size(downsideTasukiLabels) - 1
        label.delete(array.get(downsideTasukiLabels, i))
    array.clear(downsideTasukiLabels)
if not enable_threeInsideUp and enable_threeInsideUp[1]
    for i = 0 to array.size(threeInsideUpLabels) - 1
        label.delete(array.get(threeInsideUpLabels, i))
    array.clear(threeInsideUpLabels)
if not enable_threeInsideDown and enable_threeInsideDown[1]
    for i = 0 to array.size(threeInsideDownLabels) - 1
        label.delete(array.get(threeInsideDownLabels, i))
    array.clear(threeInsideDownLabels)
if not enable_threeOutsideUp and enable_threeOutsideUp[1]
    for i = 0 to array.size(threeOutsideUpLabels) - 1
        label.delete(array.get(threeOutsideUpLabels, i))
    array.clear(threeOutsideUpLabels)
if not enable_threeOutsideDown and enable_threeOutsideDown[1]
    for i = 0 to array.size(threeOutsideDownLabels) - 1
        label.delete(array.get(threeOutsideDownLabels, i))
    array.clear(threeOutsideDownLabels)
if not enable_risingThree and enable_risingThree[1]
    for i = 0 to array.size(risingThreeLabels) - 1
        label.delete(array.get(risingThreeLabels, i))
    array.clear(risingThreeLabels)
if not enable_fallingThree and enable_fallingThree[1]
    for i = 0 to array.size(fallingThreeLabels) - 1
        label.delete(array.get(fallingThreeLabels, i))
    array.clear(fallingThreeLabels)
if not enable_threeLineStrike and enable_threeLineStrike[1]
    for i = 0 to array.size(threeLineStrikeLabels) - 1
        label.delete(array.get(threeLineStrikeLabels, i))
    array.clear(threeLineStrikeLabels)
if not enable_concealingBaby and enable_concealingBaby[1]
    for i = 0 to array.size(concealingBabyLabels) - 1
        label.delete(array.get(concealingBabyLabels, i))
    array.clear(concealingBabyLabels)
if not enable_kickingBull and enable_kickingBull[1]
    for i = 0 to array.size(kickingBullLabels) - 1
        label.delete(array.get(kickingBullLabels, i))
    array.clear(kickingBullLabels)
if not enable_kickingBear and enable_kickingBear[1]
    for i = 0 to array.size(kickingBearLabels) - 1
        label.delete(array.get(kickingBearLabels, i))
    array.clear(kickingBearLabels)
if not enable_separatingBull and enable_separatingBull[1]
    for i = 0 to array.size(separatingBullLabels) - 1
        label.delete(array.get(separatingBullLabels, i))
    array.clear(separatingBullLabels)
if not enable_separatingBear and enable_separatingBear[1]
    for i = 0 to array.size(separatingBearLabels) - 1
        label.delete(array.get(separatingBearLabels, i))
    array.clear(separatingBearLabels)
if not enable_matchingLow and enable_matchingLow[1]
    for i = 0 to array.size(matchingLowLabels) - 1
        label.delete(array.get(matchingLowLabels, i))
    array.clear(matchingLowLabels)
if not enable_matchingHigh and enable_matchingHigh[1]
    for i = 0 to array.size(matchingHighLabels) - 1
        label.delete(array.get(matchingHighLabels, i))
    array.clear(matchingHighLabels)
if not enable_onNeck and enable_onNeck[1]
    for i = 0 to array.size(onNeckLabels) - 1
        label.delete(array.get(onNeckLabels, i))
    array.clear(onNeckLabels)
if not enable_inNeck and enable_inNeck[1]
    for i = 0 to array.size(inNeckLabels) - 1
        label.delete(array.get(inNeckLabels, i))
    array.clear(inNeckLabels)
if not enable_thrusting and enable_thrusting[1]
    for i = 0 to array.size(thrustingLabels) - 1
        label.delete(array.get(thrustingLabels, i))
    array.clear(thrustingLabels)
if not enable_stickSandwich and enable_stickSandwich[1]
    for i = 0 to array.size(stickSandwichLabels) - 1
        label.delete(array.get(stickSandwichLabels, i))
    array.clear(stickSandwichLabels)
if not enable_homingPigeon and enable_homingPigeon[1]
    for i = 0 to array.size(homingPigeonLabels) - 1
        label.delete(array.get(homingPigeonLabels, i))
    array.clear(homingPigeonLabels)
if not enable_triStar and enable_triStar[1]
    for i = 0 to array.size(triStarLabels) - 1
        label.delete(array.get(triStarLabels, i))
    array.clear(triStarLabels)

if hammer and enable_hammer
    l = label.new(bar_index, low, "HA", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_hammer, textcolor=color.white, size=size.small)
    array.push(hammerLabels, l)
if dragonfly and enable_dragonfly
    l = label.new(bar_index, low, "DFD", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_dragonfly, textcolor=color.white, size=size.small)
    array.push(dragonflyLabels, l)
if bullEng and enable_bullEng
    l = label.new(bar_index, low, "LE", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_bullEng, textcolor=color.black, size=size.small)
    array.push(bullEngLabels, l)
if haramiBull and enable_haramiBull
    l = label.new(bar_index, low, "LH", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_haramiBull, textcolor=color.black, size=size.small)
    array.push(haramiBullLabels, l)
if piercing and enable_piercing
    l = label.new(bar_index, low, "PL", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_piercing, textcolor=color.white, size=size.small)
    array.push(piercingLabels, l)
if morningStar and enable_morningStar
    l = label.new(bar_index, low, "MS", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_morningStar, textcolor=color.white, size=size.small)
    array.push(morningStarLabels, l)
if tweezerBottom and enable_tweezerBottom
    l = label.new(bar_index, low, "TB", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_tweezerBottom, textcolor=color.black, size=size.small)
    array.push(tweezerBottomLabels, l)
if threeWhiteSoldiers and enable_threeWhiteSoldiers
    l = label.new(bar_index, low, "3WS", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_threeWhiteSoldiers, textcolor=color.black, size=size.small)
    array.push(threeWhiteSoldiersLabels, l)
if bullMarubozu and enable_bullMarubozu
    l = label.new(bar_index, low, "LM", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_bullMarubozu, textcolor=color.black, size=size.small)
    array.push(bullMarubozuLabels, l)
if bullAbandonedBaby and enable_bullAbandonedBaby
    l = label.new(bar_index, low, "LAB", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_bullAbandonedBaby, textcolor=color.black, size=size.small)
    array.push(bullAbandonedBabyLabels, l)
if doji and enable_doji
    l = label.new(bar_index, high, "DO", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_doji, textcolor=color.white, size=size.small)
    array.push(dojiLabels, l)
if gravestone and enable_gravestone
    l = label.new(bar_index, high, "GSD", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_gravestone, textcolor=color.white, size=size.small)
    array.push(gravestoneLabels, l)
if invHammer and enable_invHammer
    l = label.new(bar_index, high, "IHA", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_invHammer, textcolor=color.white, size=size.small)
    array.push(invHammerLabels, l)
if shootStar and enable_shootStar
    l = label.new(bar_index, high, "SS", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_shootStar, textcolor=color.white, size=size.small)
    array.push(shootStarLabels, l)
if bearEng and enable_bearEng
    l = label.new(bar_index, high, "SE", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_bearEng, textcolor=color.white, size=size.small)
    array.push(bearEngLabels, l)
if haramiBear and enable_haramiBear
    l = label.new(bar_index, high, "SH", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_haramiBear, textcolor=color.white, size=size.small)
    array.push(haramiBearLabels, l)
if darkCloud and enable_darkCloud
    l = label.new(bar_index, high, "DCC", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_darkCloud, textcolor=color.white, size=size.small)
    array.push(darkCloudLabels, l)
if eveningStar and enable_eveningStar
    l = label.new(bar_index, high, "ES", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_eveningStar, textcolor=color.white, size=size.small)
    array.push(eveningStarLabels, l)
if tweezerTop and enable_tweezerTop
    l = label.new(bar_index, high, "TP", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_tweezerTop, textcolor=color.white, size=size.small)
    array.push(tweezerTopLabels, l)
if threeBlackCrows and enable_threeBlackCrows
    l = label.new(bar_index, high, "3BC", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_threeBlackCrows, textcolor=color.white, size=size.small)
    array.push(threeBlackCrowsLabels, l)
if bearMarubozu and enable_bearMarubozu
    l = label.new(bar_index, high, "SM", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_bearMarubozu, textcolor=color.white, size=size.small)
    array.push(bearMarubozuLabels, l)
if bearAbandonedBaby and enable_bearAbandonedBaby
    l = label.new(bar_index, high, "SAB", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_bearAbandonedBaby, textcolor=color.white, size=size.small)
    array.push(bearAbandonedBabyLabels, l)

if haramiCross and enable_haramiCross
    l = label.new(bar_index, high, "HC", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_haramiCross, textcolor=color.white, size=size.small)
    array.push(haramiCrossLabels, l)
if morningDojiStar and enable_morningDojiStar
    l = label.new(bar_index, low, "MDS", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_morningDojiStar, textcolor=color.white, size=size.small)
    array.push(morningDojiStarLabels, l)
if eveningDojiStar and enable_eveningDojiStar
    l = label.new(bar_index, high, "EDS", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_eveningDojiStar, textcolor=color.white, size=size.small)
    array.push(eveningDojiStarLabels, l)
if spinningTop and enable_spinningTop
    l = label.new(bar_index, close, "ST", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_spinningTop, textcolor=color.black, size=size.small)
    array.push(spinningTopLabels, l)
if beltHoldBull and enable_beltHoldBull
    l = label.new(bar_index, low, "BHB", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_beltHoldBull, textcolor=color.black, size=size.small)
    array.push(beltHoldBullLabels, l)
if beltHoldBear and enable_beltHoldBear
    l = label.new(bar_index, high, "BHB2", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_beltHoldBear, textcolor=color.white, size=size.small)
    array.push(beltHoldBearLabels, l)
if upsideTasuki and enable_upsideTasuki
    l = label.new(bar_index, low, "UTG", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_upsideTasuki, textcolor=color.white, size=size.small)
    array.push(upsideTasukiLabels, l)
if downsideTasuki and enable_downsideTasuki
    l = label.new(bar_index, high, "DTG", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_downsideTasuki, textcolor=color.white, size=size.small)
    array.push(downsideTasukiLabels, l)
if threeInsideUp and enable_threeInsideUp
    l = label.new(bar_index, low, "3IU", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_threeInsideUp, textcolor=color.black, size=size.small)
    array.push(threeInsideUpLabels, l)
if threeInsideDown and enable_threeInsideDown
    l = label.new(bar_index, high, "3ID", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_threeInsideDown, textcolor=color.white, size=size.small)
    array.push(threeInsideDownLabels, l)
if threeOutsideUp and enable_threeOutsideUp
    l = label.new(bar_index, low, "3OU", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_threeOutsideUp, textcolor=color.white, size=size.small)
    array.push(threeOutsideUpLabels, l)
if threeOutsideDown and enable_threeOutsideDown
    l = label.new(bar_index, high, "3OD", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_threeOutsideDown, textcolor=color.white, size=size.small)
    array.push(threeOutsideDownLabels, l)
if risingThree and enable_risingThree
    l = label.new(bar_index, low, "RTM", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_risingThree, textcolor=color.white, size=size.small)
    array.push(risingThreeLabels, l)
if fallingThree and enable_fallingThree
    l = label.new(bar_index, high, "FTM", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_fallingThree, textcolor=color.white, size=size.small)
    array.push(fallingThreeLabels, l)
if threeLineStrike and enable_threeLineStrike
    l = label.new(bar_index, high, "3LS", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_threeLineStrike, textcolor=color.white, size=size.small)
    array.push(threeLineStrikeLabels, l)
if concealingBaby and enable_concealingBaby
    l = label.new(bar_index, high, "CBS", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_concealingBaby, textcolor=color.white, size=size.small)
    array.push(concealingBabyLabels, l)
if kickingBull and enable_kickingBull
    l = label.new(bar_index, low, "KB", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_kickingBull, textcolor=color.white, size=size.small)
    array.push(kickingBullLabels, l)
if kickingBear and enable_kickingBear
    l = label.new(bar_index, high, "KBR", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_kickingBear, textcolor=color.white, size=size.small)
    array.push(kickingBearLabels, l)
if separatingBull and enable_separatingBull
    l = label.new(bar_index, low, "SPLB", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_separatingBull, textcolor=color.white, size=size.small)
    array.push(separatingBullLabels, l)
if separatingBear and enable_separatingBear
    l = label.new(bar_index, high, "SPLS", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_separatingBear, textcolor=color.white, size=size.small)
    array.push(separatingBearLabels, l)
if matchingLow and enable_matchingLow
    l = label.new(bar_index, low, "ML", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_matchingLow, textcolor=color.white, size=size.small)
    array.push(matchingLowLabels, l)
if matchingHigh and enable_matchingHigh
    l = label.new(bar_index, high, "MH", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=col_matchingHigh, textcolor=color.white, size=size.small)
    array.push(matchingHighLabels, l)
if onNeck and enable_onNeck
    l = label.new(bar_index, low, "ON", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_onNeck, textcolor=color.white, size=size.small)
    array.push(onNeckLabels, l)
if inNeck and enable_inNeck
    l = label.new(bar_index, low, "IN", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_inNeck, textcolor=color.white, size=size.small)
    array.push(inNeckLabels, l)
if thrusting and enable_thrusting
    l = label.new(bar_index, low, "TH", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_thrusting, textcolor=color.white, size=size.small)
    array.push(thrustingLabels, l)
if stickSandwich and enable_stickSandwich
    l = label.new(bar_index, low, "SSW", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_stickSandwich, textcolor=color.white, size=size.small)
    array.push(stickSandwichLabels, l)
if homingPigeon and enable_homingPigeon
    l = label.new(bar_index, low, "HP", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=col_homingPigeon, textcolor=color.black, size=size.small)
    array.push(homingPigeonLabels, l)
if triStar and enable_triStar
    l = label.new(bar_index, high, "TS", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_left, color=col_triStar, textcolor=color.black, size=size.small)
    array.push(triStarLabels, l)

//-----------------------------------------
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
