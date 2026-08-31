<!-- tradingview-pine-id: PUB;474b9dc9c77142ffb559ea29cfa28dca -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: Trend Phases Ribbon (TPR) v3.1.6

Source: https://www.tradingview.com/script/uQN8oire-TF-Trend-Phases-Ribbon-TPR/

## Description

TradingFlow: Trend Phases Ribbon (TPR)

Most trend indicators put the market into one of two boxes: bullish or bearish. Price rarely moves that neatly. Bullish trends have pullbacks, bearish trends have rallies, and a change of direction usually passes through an uncertain stage first.

Trend Phases Ribbon keeps those stages visible on the chart. It shows the prevailing direction while also telling you whether the current move is supporting that direction, pushing against it, or moving into transition.

How it works

TPR uses two ALMA-smoothed trend paths. The thicker path responds more quickly to price, while the thinner path follows the broader trend. The model reads their direction and separation in the context of recent price movement, then assigns one of five phases. A separate short-term reading allows a pullback or rally to appear without immediately reversing the broader trend.

A crossover is only one part of the picture and does not decide the phase on its own.

Phase changes and event markers are confirmed when the bar closes. On the open bar, the responsive path can still move with price while the last confirmed phase remains in place.

Reading the colors

Green: Bullish
The broader trend and the shorter-term move are both bullish.

Light green: Bullish Pullback
The broader trend is still bullish, but the shorter-term move is pulling back against it.

Blue-gray: Transition
The previous directional phase has weakened, while a new bullish or bearish phase has not yet been confirmed. Price may continue in the new direction, return to the previous one, or spend some time without a clear bias.

Light pink: Bearish Rally
The broader trend is still bearish, but the shorter-term move is rallying against it.

Red: Bearish
The broader trend and the shorter-term move are both bearish.

Reading the ribbon

The thick line is the responsive trend path; the thin line is the broader trend path. When both slope in the same direction and the ribbon opens up, the move is becoming more clearly separated in that direction. When the ribbon narrows or the paths begin to turn toward each other, the trend is losing alignment and may be approaching a different phase.

Ribbon width shows the distance between the two paths. It is best read together with the color and slope rather than as a strength value on its own.

Markers and settings

A green circle with "U" appears when a bearish phase ends and an upward transition begins. A red circle with "D" marks the opposite change: a bullish phase has ended and a downward transition has started. These are early transition points. The next confirmed regime may appear later, or the market may return to its previous direction.

For a more detailed chart, the Display settings can show diamonds at confirmed bullish or bearish regime starts. Smaller pale circles can also mark the beginning of bullish pullbacks and bearish rallies. Both are hidden by default so the main ribbon stays clean. Alerts are available for these phase events and for any change in state.

Balanced is the general-purpose default. Fast follows shorter swings more closely, while Slow gives more weight to persistent trends. Custom mode is available when a symbol or timeframe needs a different response.

Practical use

Start with the ribbon color to identify the current phase, then look at its slope and width for context. Strong colors show that the broader trend and shorter-term move agree. Pale colors show a temporary move against the prevailing trend. Blue-gray tells you that the old phase has faded and the next one is still being decided.

TPR is designed for standard time-based charts and can be used across different symbols and chart timeframes.

---

TradingFlow: Trend Phases Ribbon (TPR)

很多趨勢指標只把行情分成多頭或空頭，但實際走勢通常不會一次翻面。多頭裡會有回調，空頭裡也會有反彈；真正換方向之前，往往還會先走過一段不明朗的過渡期。

Trend Phases Ribbon 想做的事情很直接：先看目前的大方向，再分辨眼前這一段是在順勢推進、逆勢回檔，還是已經進入轉換。

運作方式

TPR 以兩條經過 ALMA 平滑的趨勢線作為基礎。粗線對價格反應較快，細線則用來觀察較長一段的方向。判斷階段時，模型不只看兩條線有沒有交叉，也會參考線條的方向、距離，以及近期價格的變化，再把行情歸入五種狀態。

短線走勢另有一層判讀，所以多頭中的回調、空頭中的反彈，可以先反映在色帶上，不必因為一小段逆向波動就把主趨勢整個翻面。TPR 的判斷方式也因此和一般快線／慢線交叉指標不同。

階段切換和事件標記都在收 K 後確認。即時 K 線尚未收盤時，反應較快的粗線仍會跟著價格移動，但色帶會保留上一個已確認的階段。

顏色怎麼看

綠色：Bullish
主趨勢向上，短線走勢也在配合多頭方向。

淺綠色：Bullish Pullback
主趨勢仍然向上，但短線正在回調。這時看到的是多頭趨勢裡的逆向段落。

藍灰色：Transition
原本的方向已經轉弱，新的多頭或空頭階段則還沒確認。行情可能繼續換方向，也可能回到原來的趨勢，或者先橫行一段時間。

淺粉紅色：Bearish Rally
主趨勢仍然向下，但短線正在反彈。這是空頭趨勢裡的逆向段落。

紅色：Bearish
主趨勢向下，短線走勢也在配合空頭方向。

色帶怎麼看

粗線是反應較快的趨勢線，細線代表較長一段的方向。兩條線同時往上或往下，而且距離逐漸拉開，通常表示行情正朝該方向展開。色帶開始收窄，或兩條線轉向彼此靠近時，代表原本的配合正在減弱，接下來可能切換到另一個階段。

色帶寬度只是兩條趨勢線之間的距離。閱讀時要連同顏色和斜率一起看，不需要把寬度單獨當成強弱分數。兩線交叉也不會直接決定多空，最後仍以收 K 後確認的色帶階段為準。

標記與設定

綠色圓點和「U」表示空頭階段告一段落，行情開始進入向上的轉換；紅色圓點和「D」則表示多頭階段結束，向下的轉換剛開始。它們是階段交接的早期提示。之後可能確認新的趨勢，也可能繞一圈回到原來的方向。

想看得更細，可以在 Display 裡開啟菱形標記。它會標出多頭或空頭趨勢正式確認的位置。另一組淺色小圓點則用來標示多頭回調和空頭反彈的起點。這兩組標記預設關閉，畫面會比較乾淨；各種階段事件與狀態切換也都可以設定提示。

Balanced 是一般情況下的預設選擇。Fast 比較貼近短線擺動，Slow 偏向保留較持久的趨勢。若個別商品或週期需要不同反應，也可以使用 Custom 自行調整。

實際看盤

先看顏色，知道行情目前在哪一個階段，再看色帶的方向和寬窄。深色代表主趨勢與短線走勢同向；淺色代表價格正在逆著主趨勢走一段；變成藍灰色，則表示上一個階段已經淡出，下一個方向還在形成。

TPR 為標準時間型圖表而設，可套用在不同商品和圖表週期。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// ------------------------------------------------------------------------------
//  Trend Phases Ribbon
//  Identifies structural trends, tactical pullbacks, counter-trend rallies,
//  and transitions using volatility-normalized ALMA filter dynamics.
//  Designed for standard, time-based charts.
// ------------------------------------------------------------------------------
indicator("TradingFlow: Trend Phases Ribbon (TPR) v3.1.6", shorttitle = "TF: TPR", overlay = true, precision = 2)

// Constants

const int BULLISH_REGIME = 1
const int NEUTRAL_REGIME = 0
const int BEARISH_REGIME = -1

const int BULLISH_STATE = 2
const int BULLISH_PULLBACK_STATE = 1
const int TRANSITION_STATE = 0
const int BEARISH_RALLY_STATE = -1
const int BEARISH_STATE = -2

const string TREND_MODEL_GROUP = "Trend Model"
const string STATE_LOGIC_GROUP = "State Logic"
const string DISPLAY_GROUP = "Display"

// Inputs

showTransitionMarkersInput = input.bool(true, "Show Transition Markers", group = DISPLAY_GROUP)
showDirectionLabelsInput = input.bool(true, "Show Direction Labels", group = DISPLAY_GROUP)
showRegimeMarkersInput = input.bool(false, "Show Regime Markers", group = DISPLAY_GROUP)
showTacticalMarkersInput = input.bool(false, "Show Pullback / Rally Markers", group = DISPLAY_GROUP)
bullishColorInput = input.color(color.rgb(80, 198, 107), "Bullish", group = DISPLAY_GROUP)
bullishPullbackColorInput = input.color(color.rgb(193, 223, 194), "Bullish Pullback", group = DISPLAY_GROUP)
transitionColorInput = input.color(color.rgb(144, 164, 174), "Transition", group = DISPLAY_GROUP)
bearishRallyColorInput = input.color(color.rgb(241, 171, 200), "Bearish Rally", group = DISPLAY_GROUP)
bearishColorInput = input.color(color.rgb(255, 79, 112), "Bearish", group = DISPLAY_GROUP)

sourceInput = input.source(hlcc4, "Price Source", group = TREND_MODEL_GROUP)
modelSpeedInput = input.string("Balanced", "Model Speed", options = ["Fast", "Balanced", "Slow", "Custom"], group = TREND_MODEL_GROUP, tooltip = "Fast reacts to shorter chart-relative trends; Balanced is the general-purpose default; Slow emphasizes persistent trends. Select Custom to edit the lengths below.")
useCustomModel = modelSpeedInput == "Custom"
customResponsiveLengthInput = input.int(21, "Custom Responsive Length", minval = 2, group = TREND_MODEL_GROUP, active = useCustomModel, tooltip = "Length of the faster Arnaud Legoux moving average used to track tactical price direction.")
customRegimeLengthInput = input.int(80, "Custom Regime Length", minval = 3, group = TREND_MODEL_GROUP, active = useCustomModel, tooltip = "Length of the slower Arnaud Legoux moving average used to describe structural trend direction.")
almaOffsetInput = input.float(0.85, "ALMA Responsiveness", minval = 0.0, maxval = 1.0, step = 0.05, group = TREND_MODEL_GROUP, tooltip = "Higher values place more weight on recent observations. The standard ALMA offset is 0.85.")
almaSigmaInput = input.float(6.0, "ALMA Smoothness", minval = 0.5, step = 0.5, group = TREND_MODEL_GROUP)
customNormalizationLengthInput = input.int(30, "Custom Normalization Length", minval = 2, group = TREND_MODEL_GROUP, active = useCustomModel, tooltip = "Length used to estimate typical one-bar price movement for score normalization.")
customSlopeLookbackInput = input.int(5, "Custom Slope Lookback", minval = 1, group = TREND_MODEL_GROUP, active = useCustomModel)

entryThresholdInput = input.float(0.40, "Regime Entry Threshold", minval = 0.05, step = 0.05, group = STATE_LOGIC_GROUP, tooltip = "Composite trend score required to confirm a new bullish or bearish regime.")
exitThresholdInput = input.float(0.15, "Regime Exit Threshold", minval = 0.0, step = 0.05, group = STATE_LOGIC_GROUP, tooltip = "A weaker threshold that returns a deteriorating regime to transition instead of leaving a stale opposite indication.")
tacticalThresholdInput = input.float(0.08, "Tactical Move Threshold", minval = 0.0, step = 0.01, group = STATE_LOGIC_GROUP, tooltip = "Sensitivity for identifying short pullbacks and counter-trend rallies inside a structural regime.")
confirmationBarsInput = input.int(2, "Regime Confirmation Bars", minval = 1, group = STATE_LOGIC_GROUP, tooltip = "Consecutive closed bars required beyond the entry threshold before a new structural regime is confirmed.")

// Calculations

responsiveLength = switch modelSpeedInput
    "Fast" => 13
    "Slow" => 34
    "Custom" => customResponsiveLengthInput
    => 21

regimeLength = switch modelSpeedInput
    "Fast" => 48
    "Slow" => 144
    "Custom" => customRegimeLengthInput
    => 80

normalizationLength = switch modelSpeedInput
    "Fast" => 20
    "Slow" => 50
    "Custom" => customNormalizationLengthInput
    => 30

slopeLookback = switch modelSpeedInput
    "Fast" => 3
    "Slow" => 8
    "Custom" => customSlopeLookbackInput
    => 5

if barstate.isfirst and responsiveLength >= regimeLength
    runtime.error("The responsive filter length must be shorter than the regime filter length.")

responsiveFilter = ta.alma(
     sourceInput, responsiveLength, almaOffsetInput, almaSigmaInput)
regimeFilter = ta.alma(
     sourceInput, regimeLength, almaOffsetInput, almaSigmaInput)

priceChange = ta.change(sourceInput)
changeVolatility = ta.stdev(priceChange, normalizationLength)
averageAbsoluteChange = ta.rma(math.abs(priceChange), normalizationLength)
normalizationScale = not na(changeVolatility) and not na(averageAbsoluteChange)
     ? math.max(changeVolatility, averageAbsoluteChange, syminfo.mintick)
     : na

separationHorizon = math.max(regimeLength - responsiveLength, 1)
separationScale = normalizationScale * math.sqrt(separationHorizon)
slopeScale = normalizationScale * math.sqrt(slopeLookback)
impulseScale = normalizationScale * math.sqrt(responsiveLength)

filterSeparationScore = (responsiveFilter - regimeFilter) / separationScale
responsiveSlopeScore = (responsiveFilter - responsiveFilter[slopeLookback]) / slopeScale
regimeSlopeScore = (regimeFilter - regimeFilter[slopeLookback]) / slopeScale
priceImpulseScore = (sourceInput - responsiveFilter) / impulseScale

structuralScore =
     0.55 * filterSeparationScore +
     0.30 * responsiveSlopeScore +
     0.15 * regimeSlopeScore
tacticalScore = 0.60 * responsiveSlopeScore + 0.40 * priceImpulseScore

entryThreshold = math.abs(entryThresholdInput)
exitThreshold = math.min(math.abs(exitThresholdInput), entryThreshold)
tacticalThreshold = math.abs(tacticalThresholdInput)

bullishRegimeCandidate = structuralScore > entryThreshold
bearishRegimeCandidate = structuralScore < -entryThreshold
bullishConfirmationRatio = ta.sma(
     bullishRegimeCandidate ? 1.0 : 0.0, confirmationBarsInput)
bearishConfirmationRatio = ta.sma(
     bearishRegimeCandidate ? 1.0 : 0.0, confirmationBarsInput)
bullishRegimeConfirmed = bullishConfirmationRatio == 1.0
bearishRegimeConfirmed = bearishConfirmationRatio == 1.0

var int regimeState = NEUTRAL_REGIME
var int tacticalState = NEUTRAL_REGIME

if barstate.isconfirmed
    if bullishRegimeConfirmed
        regimeState := BULLISH_REGIME
    else if bearishRegimeConfirmed
        regimeState := BEARISH_REGIME
    else if regimeState == BULLISH_REGIME and structuralScore < exitThreshold
        regimeState := NEUTRAL_REGIME
    else if regimeState == BEARISH_REGIME and structuralScore > -exitThreshold
        regimeState := NEUTRAL_REGIME

    tacticalState := tacticalScore > tacticalThreshold
         ? BULLISH_REGIME
         : tacticalScore < -tacticalThreshold ? BEARISH_REGIME : NEUTRAL_REGIME

int trendState = switch
    regimeState == BULLISH_REGIME and tacticalState == BEARISH_REGIME => BULLISH_PULLBACK_STATE
    regimeState == BULLISH_REGIME => BULLISH_STATE
    regimeState == BEARISH_REGIME and tacticalState == BULLISH_REGIME => BEARISH_RALLY_STATE
    regimeState == BEARISH_REGIME => BEARISH_STATE
    => TRANSITION_STATE

trendStateChanged = trendState != trendState[1]
bullishRegimeStarted = regimeState == BULLISH_REGIME and regimeState[1] != BULLISH_REGIME
bearishRegimeStarted = regimeState == BEARISH_REGIME and regimeState[1] != BEARISH_REGIME
bullishPullbackStarted = trendState == BULLISH_PULLBACK_STATE and trendState[1] != BULLISH_PULLBACK_STATE
bearishRallyStarted = trendState == BEARISH_RALLY_STATE and trendState[1] != BEARISH_RALLY_STATE
bullishTransitionStarted = trendState == TRANSITION_STATE and regimeState[1] == BEARISH_REGIME
bearishTransitionStarted = trendState == TRANSITION_STATE and regimeState[1] == BULLISH_REGIME

modelReady = not na(structuralScore)

stateColor = switch
    not modelReady => transitionColorInput
    trendState == BULLISH_STATE => bullishColorInput
    trendState == BULLISH_PULLBACK_STATE => bullishPullbackColorInput
    trendState == BEARISH_RALLY_STATE => bearishRallyColorInput
    trendState == BEARISH_STATE => bearishColorInput
    => transitionColorInput

structuralScoreRatio = not na(structuralScore)
     ? math.abs(structuralScore) / entryThreshold
     : na
transitionLabelOffset = normalizationScale * 0.75

// Trend Ribbon

responsivePlotID = plot(responsiveFilter, "Responsive Trend", color = stateColor, linewidth = 2)
regimePlotID = plot(regimeFilter, "Regime Trend", color = color.new(stateColor, 35), linewidth = 1)
fill(responsivePlotID, regimePlotID, color = color.new(stateColor, 82), title = "Trend State Ribbon", fillgaps = false)

// State-Change Markers

plotshape(
     showRegimeMarkersInput and bullishRegimeStarted ? responsiveFilter : na,
     title = "Bullish Regime Start", style = shape.diamond, location = location.absolute,
     color = bullishColorInput, size = size.small, display = display.pane)
plotshape(
     showRegimeMarkersInput and bearishRegimeStarted ? responsiveFilter : na,
     title = "Bearish Regime Start", style = shape.diamond, location = location.absolute,
     color = bearishColorInput, size = size.small, display = display.pane)
plotshape(
     showTacticalMarkersInput and bullishPullbackStarted ? responsiveFilter : na,
     title = "Bullish Pullback Start", style = shape.circle, location = location.absolute,
     color = bullishPullbackColorInput, size = size.tiny, display = display.pane)
plotshape(
     showTacticalMarkersInput and bearishRallyStarted ? responsiveFilter : na,
     title = "Bearish Rally Start", style = shape.circle, location = location.absolute,
     color = bearishRallyColorInput, size = size.tiny, display = display.pane)
plotshape(
     showTransitionMarkersInput and bullishTransitionStarted ? responsiveFilter : na,
     title = "Bullish Transition Start", style = shape.circle, location = location.absolute,
     color = bullishColorInput, size = size.tiny, display = display.pane)
plotshape(
     showTransitionMarkersInput and bearishTransitionStarted ? responsiveFilter : na,
     title = "Bearish Transition Start", style = shape.circle, location = location.absolute,
     color = bearishColorInput, size = size.tiny, display = display.pane)
plotshape(
     showTransitionMarkersInput and showDirectionLabelsInput and bullishTransitionStarted
         ? responsiveFilter - transitionLabelOffset
         : na,
     title = "Bullish Transition Direction", style = shape.labelup, location = location.absolute,
     color = bullishColorInput, text = "U", textcolor = color.white, size = size.tiny,
     display = display.pane)
plotshape(
     showTransitionMarkersInput and showDirectionLabelsInput and bearishTransitionStarted
         ? responsiveFilter + transitionLabelOffset
         : na,
     title = "Bearish Transition Direction", style = shape.labeldown, location = location.absolute,
     color = bearishColorInput, text = "D", textcolor = color.white, size = size.tiny,
     display = display.pane)

// Data Window

plot(structuralScore, "Structural Trend Score", display = display.data_window, editable = false)
plot(tacticalScore, "Tactical Trend Score", display = display.data_window, editable = false)
plot(structuralScoreRatio, "Structural Score / Entry Threshold", display = display.data_window, editable = false)

// Alerts

alertcondition(
     bullishRegimeStarted, "Bullish Regime Start",
     "Confirmed a bullish structural regime.")
alertcondition(
     bearishRegimeStarted, "Bearish Regime Start",
     "Confirmed a bearish structural regime.")
alertcondition(
     bullishPullbackStarted, "Bullish Pullback Start",
     "Detected a tactical pullback inside a bullish regime.")
alertcondition(
     bearishRallyStarted, "Bearish Rally Start",
     "Detected a tactical rally inside a bearish regime.")
alertcondition(
     bullishTransitionStarted, "Bullish Transition Start",
     "Left a bearish regime and entered a bullish transition.")
alertcondition(
     bearishTransitionStarted, "Bearish Transition Start",
     "Left a bullish regime and entered a bearish transition.")
alertcondition(
     trendStateChanged, "Trend State Change",
     "Changed trend state.")
````
