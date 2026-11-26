# Candle Engine Educative

- url: https://www.tradingview.com/script/M7eRAA3K-Candle-Engine-Educative/
- type: indicator
- pine_id: PUB;8b0e253610764ef29872f68870fd72b5
- version: 1.0

## Description

candle education engine is an educational visual tool designed to help traders study normal candles, heikin ashi candle behavior, reversal candles, and multi-candle pattern sequences directly on the chart.

this script is for education and market study only. it is not financial advice, not a trading strategy, not a signal service, and not a recommendation to buy or sell any asset. the goal is to help users understand candle structure, candle context, and pattern behavior. every label, panel note, score, and alert should be used as a learning reference only.

what this tool does

this indicator is built around three main study areas:

1. normal candle study

the normal candle engine reads standard chart candles and identifies candle structures such as doji, marubozu, engulfing candles, inside bars, hammers, shooting stars, tweezer tops, tweezer bottoms, rejection candles, sweep candles, displacement candles, imbalance candles, exhaustion candles, wide range candles, and compression candles.

this part is designed to be used on a normal candlestick chart.

2. heikin ashi candle study

the heikin ashi engine studies smoothed heikin ashi candle behavior. it can identify strong ha candles, weak ha candles, ha doji candles, ha continuation, ha pullback, ha acceleration, ha color flip, ha exhaustion, ha weakening, and ha reversal conditions.

for best learning, switch your chart to heikin ashi candles when studying the ha sections. this helps beginners compare the script labels with the actual ha candle shape.

3. pattern sequence study

the pattern engine studies one-candle, two-candle, three-candle, four-candle, and five-candle formations. it includes classic and modern patterns such as morning star, evening star, engulfing patterns, harami patterns, piercing line, dark cloud cover, three inside up, three inside down, three outside up, three outside down, three white soldiers, three black crows, rising three methods, falling three methods, traps, breakouts, kickers, and breakaway patterns.

the purpose is not to predict the future. the purpose is to learn how candles combine into structure.

why candles matter

candles show the battle between buyers and sellers during a specific period.

a candle can teach several things:

* the body shows who controlled the open-to-close move
* the wick shows where price was rejected
* the close shows where control finished
* the range shows how much activity happened
* repeated candles show pressure, hesitation, exhaustion, or continuation
* patterns show how control changes across several candles

a candle is not automatically bullish or bearish in every situation. the same candle can have different meaning depending on where it appears. for example, a hammer after a strong drop can be a bullish rejection clue, but a hammer in the middle of a range can simply be noise. a doji is not a buy or sell signal by itself. it teaches indecision and requires confirmation.

how beginners should use this indicator

start slowly. do not activate everything at once.

recommended learning path:

step 1: study normal candles first

use a regular candlestick chart. enable the normal candle engine and a few simple labels such as doji, hammer, shooting star, engulfing, inside bar, rejection, and sweep.

focus on the candle body, wick, close location, and where the candle appears.

step 2: study reversal candles separately

enable the reversal candle module if you want to focus only on candle structures that may teach rejection, exhaustion, liquidity sweep, or control transfer.

this is useful for beginners because it separates reversal education from general candle noise.

step 3: switch to heikin ashi for ha study

when studying the ha module, switch the chart type to heikin ashi. the script calculates ha behavior internally, but visually switching the chart helps you understand why a candle is classified as strong, weak, reversal, exhaustion, or continuation.

heikin ashi is useful for learning trend rhythm, but it smooths price, so it should not replace normal candle study.

step 4: study ha reversal separately

the reversal ha module is designed to focus on ha color flips, ha weakening, ha exhaustion, and possible smoothed reversal behavior.

use it to learn when trend rhythm begins to slow, not as an automatic entry tool.

step 5: study pattern sequences

after learning single candles, enable the pattern engine. start with one-candle and two-candle patterns before studying complex three, four, or five-candle patterns.

multi-candle patterns are easier to understand when you ask:

* what did the first candle show?
* did the second candle confirm or reject it?
* did the final candle close with buyer or seller control?
* did the pattern happen near a meaningful level?
* did the pattern appear in trend, range, pullback, or exhaustion?

step 6: read the panels

the panels are designed as an educational journal. they show recent candle or pattern events with a short educational note. the notes explain what the candle teaches, not what you must trade.

main settings explained

candle engine

enable candle engine turns the normal candle module on or off.

show candle type on chart displays candle names directly on the chart.

show candle panel displays the candle history panel.

candle panel position selects where the candle history panel appears.

max candle labels visible controls how many normal candle labels or panel rows are kept before cleanup.

scoring mode controls how the candle quality score is calculated. body mode focuses on candle body size. volume mode focuses on relative volume. hybrid mode combines both.

use global trend context adjusts the score using a simple trend context. beginners should treat this as context only, not a decision rule.

candle type filters

these settings enable or disable specific normal candle names. examples include doji, engulfing candles, inside bars, hammers, shooting stars, tweezer tops, tweezer bottoms, sweeps, rejection candles, imbalance candles, displacement candles, and exhaustion candles.

beginners should start with fewer candle types and add more later.

reversal candle

enable reversal candle turns on the reversal candle module.

show reversal candle labels displays reversal candle labels directly on the chart.

show reversal candle panel displays the reversal candle panel.

reversal candle position selects where the reversal candle panel appears.

max candle reversal label controls how many reversal candle labels or rows are kept.

this module is useful when you want to focus only on candle behavior linked to rejection, sweep, exhaustion, liquidity reaction, or possible control transfer.

candle ha

enable candle ha turns on the heikin ashi study module.

show ha candle labels displays ha labels on the chart.

show heikin ashi panel displays the ha history panel.

ha panel position selects where the ha panel appears.

show ha secondary tags controls whether extra ha structure details are shown. when off, the label stays cleaner and shows the main ha idea. when on, it can show additional details such as no wick, long body, continuation, or acceleration.

max ha labels visible controls how many ha labels or panel rows are kept.

use this module on a heikin ashi chart for best visual learning.

reversal ha

enable reversal ha candle turns on the ha reversal module.

show reversal ha labels displays reversal ha labels on the chart.

show reversal ha panel displays the reversal ha panel.

reversal ha position selects where the reversal ha panel appears.

show reversal ha secondary tags controls whether extra ha reversal details are shown.

max ha reversal label controls how many reversal ha labels or panel rows are kept.

reversal ha name lets users choose which ha reversal-related conditions are active, such as ha bull reversal, ha bear reversal, ha color flip, ha exhaustion, ha weakening, and ha doji reversal.

this section is useful for learning when a smoothed trend may be slowing or changing rhythm.

candle sequence engine

enable candle sequence engine turns on the pattern sequence module.

show detected sequence displays detected pattern labels on the chart.

show pattern panel displays the pattern history panel.

pattern panel position selects where the pattern panel appears.

detection sensitivity adjusts how strict the sequence detection is.

max pattern labels visible controls how many pattern labels or panel rows are kept.

pattern length filters allow users to enable or disable one-candle, two-candle, three-candle, four-candle, and five-candle pattern groups.

pattern name filters let users select individual patterns. beginners should start with fewer patterns, such as engulfing, harami, morning star, evening star, hammer, shooting star, inside bar break, and traps.

reversal pattern

enable reversal patterns only mode allows the script to focus only on reversal-related patterns without requiring the full pattern engine to be used in the same way.

show pattern reversal labels displays reversal pattern labels on the chart.

show pattern reversal panel displays the pattern reversal panel.

pattern reversal position selects where the reversal pattern panel appears.

max pattern reversal label controls how many reversal pattern labels or rows are kept.

this section is useful when the user wants to study only patterns that teach failed control, rejection, traps, transition, or possible reversal behavior.

ai context

the ai context section does not predict the future. it provides a visual context score based on internal trend, volume, and volatility calculations.

show ai context bull/bear gauge displays a small visual gauge.

gauge position moves the gauge between top center and bottom center.

gauge basis selects whether the gauge is based on trend, volume, volatility, or combined context.

gauge precision cells controls the visual resolution of the gauge.

bear, neutral, and bull colors control the gradient colors of the gauge.

the gauge should be used as a context tool, not as a trade entry tool.

educational history panels

the history panels show recent detected events. each row includes the candle or pattern name, score, and a short educational note.

the panels are designed to help beginners review what happened recently and learn the meaning of each structure.

panel position settings control where each panel appears.

panel colors and transparency control the visual style.

alerts

alerts can notify when selected candle, ha, or pattern events occur.

alerts are educational reminders only. they are not automatic trade signals.

beginners should create alerts only after understanding what each candle or pattern means.

how to interpret bull, bear, and neutral

bull means the candle or pattern teaches buyer pressure, recovery, demand, or bullish rejection.

bear means the candle or pattern teaches seller pressure, rejection, supply, or bearish control.

neutral means the candle or pattern teaches indecision, compression, balance, or a situation where direction is not yet confirmed.

neutral is not useless. neutral candles are important because they often teach patience.

important beginner lessons

do not read a candle alone.

a candle needs context:

* is price trending or ranging?
* did the candle appear near support or resistance?
* did the wick reject a meaningful level?
* did the close confirm control?
* did the next candle follow through?
* is the pattern forming after expansion, compression, or exhaustion?

a pattern is not a guarantee. it is a lesson about structure.

good candles usually have clear body, wick, and close behavior. weak candles are harder to read and need more confirmation.

reversal patterns need extra care. a reversal clue is not a confirmed reversal until price follows through.

continuation patterns need trend context. without trend, continuation patterns can become noise.

compression patterns teach patience. the direction is usually learned after the range breaks.

best beginner workflow

1. use normal candles first.
2. enable only a few basic candle labels.
3. study the educational notes.
4. add reversal candle only when you understand rejection and wick behavior.
5. switch to heikin ashi before studying ha modules.
6. keep ha secondary tags off at first for cleaner reading.
7. enable ha secondary tags later to study extra structure.
8. study pattern sequences after you understand single candles.
9. use the panels as a learning journal.
10. never use one label alone as a trading decision.

educational disclaimer

this script is provided for educational and informational purposes only. it does not provide financial advice, investment advice, trading advice, or a recommendation to buy or sell any financial instrument.

the indicator does not guarantee results and does not predict future market movement. users are responsible for their own research, risk management, and trading decisions.

the best use of this tool is to learn how candles, heikin ashi candles, and pattern sequences communicate market behavior.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//       █████╗ ██╗     ██████╗ ██╗  ██╗ █████╗
//      ██╔══██╗██║     ██╔══██╗██║  ██║██╔══██╗
//      ███████║██║     ██████╔╝███████║███████║
//      ██╔══██║██║     ██╔═══╝ ██╔══██║██╔══██║
//      ██║  ██║███████╗██║     ██║  ██║██║  ██║
//      ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝
//
//      ██╗    ██╗██╗███████╗ █████╗ ██████╗ ██████╗
//      ██║    ██║██║╚══███╔╝██╔══██╗██╔══██╗██╔══██╗
//      ██║ █╗ ██║██║  ███╔╝ ███████║██████╔╝██║  ██║
//      ██║███╗██║██║ ███╔╝  ██╔══██║██╔══██╗██║  ██║
//      ╚███╔███╔╝██║███████╗██║  ██║██║  ██║██████╔╝
//       ╚══╝╚══╝ ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝
//
//                 A L P H A   W I Z A R D
//
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


//@version=6
indicator("Candle Engine", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 1000)

//=====================================================
// 🕯 Candle Engine Pro+
//=====================================================

//----------------------
// 🔌 Inputs Candle Engine
//----------------------
group_CandleEnginePro = "🕯 Candle Engine Pro+"

enableCandleEnginePro = input.bool(false, "Enable Candle Engine", group=group_CandleEnginePro, tooltip="Turns this module on or off.")
showCandleLabelsPro   = input.bool(false, "Show Candle Type on Chart", group=group_CandleEnginePro, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelCandle      = input.bool(true, "Show Candle Panel", group=group_CandleEnginePro, tooltip="Shows or hides the candle history panel.")
ce_panelCandlePos = input.string("Bottom Center", "Candle Panel Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=group_CandleEnginePro, tooltip="Selects the default screen location for the candle history panel.")
strengthModePro       = input.string("Hybrid", "Scoring Mode", options=["Body","Volume","Hybrid"], group=group_CandleEnginePro, tooltip="Controls this setting for display, filtering, or educational detection.")
contextFilterPro      = input.bool(true, "Use Global Trend Context (EMA)", group=group_CandleEnginePro, tooltip="Sets the calculation length used internally.")
showCandleDebugPro    = input.bool(false, "Show Debug (Strength / Score)", group=group_CandleEnginePro, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_maxCandleLabels    = input.int(20, "Max Candle Labels Visible", minval=1, maxval=50, group=group_CandleEnginePro, tooltip="Maximum number of labels or panel rows kept before automatic cleanup.")

group_CandleReversal = "↩️ Reversal Candle"
ce_candleRev_enable  = input.bool(true, "Enable Reversal Candle", group=group_CandleReversal, tooltip="Turns this module on or off.")
ce_candleRev_showLabels = input.bool(true, "Show Reversal Candle Labels", group=group_CandleReversal, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelCandleRev    = input.bool(true, "Show Reversal Candle Panel", group=group_CandleReversal, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelCandleRevPos = input.string("Bottom Left", "Reversal Candle Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=group_CandleReversal, tooltip="Selects the default screen location for the reversal candle panel.")
ce_candleRevMaxRows  = input.int(20, "Max Candle Reversal Label", minval=5, maxval=50, group=group_CandleReversal, tooltip="Maximum number of labels or panel rows kept before automatic cleanup.")

//----------------------
// 🧩 Candle Type Filters
//----------------------
group_CandleNames = "🕯 Candle Type Filters"

ce_showBullEngulf    = input.bool(true, "Show Bull Engulf (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearEngulf    = input.bool(true, "Show Bear Engulf (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showHammer        = input.bool(true, "Show Hammer (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showShootingStar  = input.bool(true, "Show Shooting Star (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showTweezerTop    = input.bool(true, "Show Tweezer Top (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showTweezerBottom = input.bool(true, "Show Tweezer Bottom (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullReject    = input.bool(true, "Show Bullish Rejection (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearReject    = input.bool(true, "Show Bearish Rejection (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showDragonflyDoji = input.bool(true, "Show Dragonfly Doji (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showGravestoneDoji= input.bool(true, "Show Gravestone Doji (reversal)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullSweep     = input.bool(true, "Show Bullish Sweep Reclaim (liquidity)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearSweep     = input.bool(true, "Show Bearish Sweep Rejection (liquidity)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullExhaust   = input.bool(true, "Show Bull Exhaustion (exhaustion)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearExhaust   = input.bool(true, "Show Bear Exhaustion (exhaustion)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullMarubozu  = input.bool(true, "Show Bull Marubozu (momentum)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearMarubozu  = input.bool(true, "Show Bear Marubozu (momentum)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullDisplace  = input.bool(true, "Show Bullish Displacement (momentum)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearDisplace  = input.bool(true, "Show Bearish Displacement (momentum)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBeltBull      = input.bool(true, "Show Belt Hold Bull (momentum)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBeltBear      = input.bool(true, "Show Belt Hold Bear (momentum)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullWide      = input.bool(true, "Show Bull Wide Range (expansion)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearWide      = input.bool(true, "Show Bear Wide Range (expansion)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showOutsideBull   = input.bool(true, "Show Outside Bar Bull (expansion)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showOutsideBear   = input.bool(true, "Show Outside Bar Bear (expansion)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showMotherBar     = input.bool(true, "Show Mother Bar / Outside Bar (range)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showInsideBar     = input.bool(true, "Show Inside Bar (compression)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showNR4           = input.bool(true, "Show NR4 (compression)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showNR7           = input.bool(true, "Show NR7 (compression)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullImb       = input.bool(true, "Show Bull Imbalance Candle (imbalance)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearImb       = input.bool(true, "Show Bear Imbalance Candle (imbalance)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showDoji          = input.bool(true, "Show Doji (indecision)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showLongLegDoji   = input.bool(true, "Show Long-Legged Doji (indecision)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBullCandle    = input.bool(false, "Show Basic Bull Candle (basic)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showBearCandle    = input.bool(false, "Show Basic Bear Candle (basic)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_showNeutral       = input.bool(false, "Show Neutral Candle (neutral)", group=group_CandleNames, tooltip="Shows or hides this chart element, label, panel, or filter.")

//-----------------------------------------------------
// 🧱 Candle Modern Defaults
//-----------------------------------------------------
ce_displacementBodyMin = 0.65
ce_displacementAtrMin  = 1.20
ce_wideRangeMult       = 1.60
ce_exhaustVolMult      = 1.50
ce_rejectionWickMin    = 0.55
ce_imbalanceAtrMin     = 0.05

//-----------------------------------------------------
// 🧠 Core Candle Metrics
//-----------------------------------------------------
cBody    = math.abs(close - open)
cRange   = high - low
cSafeRange = math.max(cRange, syminfo.mintick)
cBodyPct = cSafeRange > 0 ? (cBody / cSafeRange) * 100 : 0.0
cBodyRatio = cBody / cSafeRange

cIsBull  = close > open
cIsBear  = close < open

cUpperWick = high - math.max(open, close)
cLowerWick = math.min(open, close) - low
cUpperWickRatio = cUpperWick / cSafeRange
cLowerWickRatio = cLowerWick / cSafeRange

ceAtr = ta.atr(14)
ceAvgRange = ta.sma(cRange, 20)
ceAvgVol = ta.sma(volume, 20)
ceVolSpike = ceAvgVol > 0 ? volume >= ceAvgVol * ce_exhaustVolMult : false

//-----------------------------------------------------
// 📈 Trend Context
//-----------------------------------------------------
ceEmaFast = ta.ema(close, 20)
ceEmaSlow = ta.ema(close, 50)
ceTrendUp = ceEmaFast > ceEmaSlow
ceTrendDn = ceEmaFast < ceEmaSlow

//-----------------------------------------------------
// 🪶 Pattern Detection
//-----------------------------------------------------
isDoji       = cBodyPct < 15
isMarubozu   = cBodyPct > 80
isPinUp      = (high - math.max(close, open)) > (cBody * 2) and (math.min(close, open) - low) < (cBody * 0.5)
isPinDown    = (math.min(close, open) - low) > (cBody * 2) and (high - math.max(close, open)) < (cBody * 0.5)
isEngulfBull = close > open[1] and open < close[1]
isEngulfBear = close < open[1] and open > close[1]
isInsideBar  = high < high[1] and low > low[1]
isTweezerTop = high == high[1] and close < open
isTweezerBot = low == low[1] and close > open

// Modern simple candle/bar detections
ce_outsideBar = high > high[1] and low < low[1]
ce_outsideBull = ce_outsideBar and cIsBull and close > close[1]
ce_outsideBear = ce_outsideBar and cIsBear and close < close[1]
ce_motherBar = ce_outsideBar and not ce_outsideBull and not ce_outsideBear

ce_bullSweepReclaim = low < low[1] and close > low[1] and close > open
ce_bearSweepReject  = high > high[1] and close < high[1] and close < open

ce_bullDisplacement = cIsBull and cBodyRatio >= ce_displacementBodyMin and cRange >= ceAtr * ce_displacementAtrMin and cUpperWickRatio <= 0.25
ce_bearDisplacement = cIsBear and cBodyRatio >= ce_displacementBodyMin and cRange >= ceAtr * ce_displacementAtrMin and cLowerWickRatio <= 0.25

ce_bullRejection = cLowerWickRatio >= ce_rejectionWickMin and close > open
ce_bearRejection = cUpperWickRatio >= ce_rejectionWickMin and close < open

ce_bullExhaustion = ceTrendUp and cUpperWickRatio >= ce_rejectionWickMin and (ceVolSpike or cRange >= ceAtr * ce_displacementAtrMin)
ce_bearExhaustion = ceTrendDn and cLowerWickRatio >= ce_rejectionWickMin and (ceVolSpike or cRange >= ceAtr * ce_displacementAtrMin)

ce_NR4 = cRange <= ta.lowest(cRange, 4)
ce_NR7 = cRange <= ta.lowest(cRange, 7)

ce_bullWide = cIsBull and ceAvgRange > 0 and cRange >= ceAvgRange * ce_wideRangeMult
ce_bearWide = cIsBear and ceAvgRange > 0 and cRange >= ceAvgRange * ce_wideRangeMult

ce_bullImbalance = bar_index > 2 and low > high[2] and (low - high[2]) >= ceAtr * ce_imbalanceAtrMin
ce_bearImbalance = bar_index > 2 and high < low[2] and (low[2] - high) >= ceAtr * ce_imbalanceAtrMin

ce_dragonflyDoji  = isDoji and cLowerWickRatio >= 0.60 and cUpperWickRatio <= 0.15
ce_gravestoneDoji = isDoji and cUpperWickRatio >= 0.60 and cLowerWickRatio <= 0.15
ce_longLegDoji    = isDoji and cUpperWickRatio >= 0.30 and cLowerWickRatio >= 0.30

ce_beltHoldBull = cIsBull and cBodyRatio >= 0.60 and (open - low) / cSafeRange <= 0.10
ce_beltHoldBear = cIsBear and cBodyRatio >= 0.60 and (high - open) / cSafeRange <= 0.10

//-----------------------------------------------------
// 🎯 Pattern Classification
//-----------------------------------------------------
cPattern = ce_bullImbalance   ? "Bull Imbalance Candle" :
           ce_bearImbalance   ? "Bear Imbalance Candle" :
           ce_bullDisplacement? "Bullish Displacement" :
           ce_bearDisplacement? "Bearish Displacement" :
           ce_bullSweepReclaim? "Bullish Sweep Reclaim" :
           ce_bearSweepReject ? "Bearish Sweep Rejection" :
           ce_bullExhaustion  ? "Bull Exhaustion" :
           ce_bearExhaustion  ? "Bear Exhaustion" :
           ce_bullRejection   ? "Bullish Rejection" :
           ce_bearRejection   ? "Bearish Rejection" :
           ce_outsideBull     ? "Outside Bar Bull" :
           ce_outsideBear     ? "Outside Bar Bear" :
           ce_motherBar       ? "Mother Bar" :
           ce_NR7             ? "NR7" :
           ce_NR4             ? "NR4" :
           ce_bullWide        ? "Bull Wide Range" :
           ce_bearWide        ? "Bear Wide Range" :
           ce_dragonflyDoji   ? "Dragonfly Doji" :
           ce_gravestoneDoji  ? "Gravestone Doji" :
           ce_longLegDoji     ? "Long-Legged Doji" :
           ce_beltHoldBull    ? "Belt Hold Bull" :
           ce_beltHoldBear    ? "Belt Hold Bear" :
           isDoji             ? "Doji" :
           isMarubozu         ? (cIsBull ? "Bull Marubozu" : "Bear Marubozu") :
           isEngulfBull       ? "Bull Engulf" :
           isEngulfBear       ? "Bear Engulf" :
           isInsideBar        ? "Inside Bar" :
           isPinDown          ? "Hammer" :
           isPinUp            ? "Shooting Star" :
           isTweezerTop       ? "Tweezer Top" :
           isTweezerBot       ? "Tweezer Bottom" :
           cIsBull            ? "Bull Candle" :
           cIsBear            ? "Bear Candle" : "Neutral"

ce_showCurrentCandle =
     cPattern == "Bull Imbalance Candle" ? ce_showBullImb :
     cPattern == "Bear Imbalance Candle" ? ce_showBearImb :
     cPattern == "Bullish Displacement" ? ce_showBullDisplace :
     cPattern == "Bearish Displacement" ? ce_showBearDisplace :
     cPattern == "Bullish Sweep Reclaim" ? ce_showBullSweep :
     cPattern == "Bearish Sweep Rejection" ? ce_showBearSweep :
     cPattern == "Bull Exhaustion" ? ce_showBullExhaust :
     cPattern == "Bear Exhaustion" ? ce_showBearExhaust :
     cPattern == "Bullish Rejection" ? ce_showBullReject :
     cPattern == "Bearish Rejection" ? ce_showBearReject :
     cPattern == "Outside Bar Bull" ? ce_showOutsideBull :
     cPattern == "Outside Bar Bear" ? ce_showOutsideBear :
     cPattern == "Mother Bar" ? ce_showMotherBar :
     cPattern == "NR7" ? ce_showNR7 :
     cPattern == "NR4" ? ce_showNR4 :
     cPattern == "Bull Wide Range" ? ce_showBullWide :
     cPattern == "Bear Wide Range" ? ce_showBearWide :
     cPattern == "Dragonfly Doji" ? ce_showDragonflyDoji :
     cPattern == "Gravestone Doji" ? ce_showGravestoneDoji :
     cPattern == "Long-Legged Doji" ? ce_showLongLegDoji :
     cPattern == "Belt Hold Bull" ? ce_showBeltBull :
     cPattern == "Belt Hold Bear" ? ce_showBeltBear :
     cPattern == "Doji" ? ce_showDoji :
     cPattern == "Bull Marubozu" ? ce_showBullMarubozu :
     cPattern == "Bear Marubozu" ? ce_showBearMarubozu :
     cPattern == "Bull Engulf" ? ce_showBullEngulf :
     cPattern == "Bear Engulf" ? ce_showBearEngulf :
     cPattern == "Inside Bar" ? ce_showInsideBar :
     cPattern == "Hammer" ? ce_showHammer :
     cPattern == "Shooting Star" ? ce_showShootingStar :
     cPattern == "Tweezer Top" ? ce_showTweezerTop :
     cPattern == "Tweezer Bottom" ? ce_showTweezerBottom :
     cPattern == "Bull Candle" ? ce_showBullCandle :
     cPattern == "Bear Candle" ? ce_showBearCandle :
     ce_showNeutral

//-----------------------------------------------------
// 🧮 Strength Scoring
//-----------------------------------------------------
avgBody     = ta.sma(cBody, 20)
avgVol_CE   = ta.sma(volume, 20)

bodyScore   = avgBody   > 0 ? math.min((cBody   / avgBody)   * 50, 100) : 0
volScore    = avgVol_CE > 0 ? math.min((volume / avgVol_CE) * 50, 100) : 0

cStrengthScore =
     strengthModePro == "Body"   ? bodyScore :
     strengthModePro == "Volume" ? volScore  :
                                   (bodyScore * 0.6 + volScore * 0.4)

if contextFilterPro
    cStrengthScore := ceTrendUp and cIsBull ? cStrengthScore * 1.2 :
                      ceTrendDn and cIsBear ? cStrengthScore * 1.2 :
                                              cStrengthScore * 0.8

//-----------------------------------------------------
// 🌐 globales Candle Engine
//-----------------------------------------------------
var string candlePattern = ""
var float  candleScore   = na

candlePattern := cPattern
candleScore   := cStrengthScore

//-----------------------------------------------------
// 💡 Visuels Candle Engine
//-----------------------------------------------------
var label[] ce_candleLabels = array.new_label()

if enableCandleEnginePro and showCandleLabelsPro and ce_showCurrentCandle
    label ceLb = label.new(
        bar_index,
        high,
        (cIsBull ? "🟢 " : cIsBear ? "🔴 " : "⚪ ") + cPattern,
        style=label.style_label_down,
        textcolor=color.white,
        color=color.new(cIsBull ? color.lime : cIsBear ? color.red : color.gray, 75),
        size=size.tiny
    )
    array.unshift(ce_candleLabels, ceLb)

if enableCandleEnginePro and showCandleDebugPro and ce_showCurrentCandle
    label ceDbg = label.new(
        bar_index,
        low,
        str.tostring(cStrengthScore, "#.##") + "%",
        style=label.style_label_up,
        textcolor=color.new(color.white, 0),
        color=color.new(color.black, 80),
        size=size.tiny
    )
    array.unshift(ce_candleLabels, ceDbg)

while array.size(ce_candleLabels) > ce_maxCandleLabels
    label oldCe = array.pop(ce_candleLabels)
    if not na(oldCe)
        label.delete(oldCe)

if not enableCandleEnginePro
    while array.size(ce_candleLabels) > 0
        label oldCe = array.pop(ce_candleLabels)
        if not na(oldCe)
            label.delete(oldCe)
//=====================================================
// 🕯 CANDLE HA — Heikin Ashi Candle Category
//=====================================================

//----------------------
// 🔌 Inputs — Candle HA Main
//----------------------
group_CandleHA = "🕯 Candle HA"

ceha_enable      = input.bool(false, "Enable Candle HA", group=group_CandleHA, tooltip="Turns this module on or off.")
ceha_showLabels  = input.bool(false, "Show HA Candle Labels", group=group_CandleHA, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelHA          = input.bool(true, "Show Heikin Ashi Panel", group=group_CandleHA, tooltip="Shows or hides the Heikin Ashi history panel.")
ce_panelHAPos = input.string("Bottom Left", "HA Panel Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=group_CandleHA, tooltip="Selects the default screen location for the Heikin Ashi history panel.")
ce_panelHATags = input.bool(false, "Show HA Secondary Tags", group=group_CandleHA, tooltip="Shows secondary HA structure tags in the main HA panel.")
ceha_maxLabels   = input.int(20, "Max HA Labels Visible", minval=1, maxval=50, group=group_CandleHA, tooltip="Maximum number of labels or panel rows kept before automatic cleanup.")

//----------------------
// 🧱 Inputs — HA Structure Params
//----------------------
//----------------------
// 🧱 Candle HA Defaults
//----------------------
ceha_dojiMaxBody      = 0.15
ceha_smallBodyMax     = 0.30
ceha_strongBodyMin    = 0.60
ceha_noWickMax        = 0.05
ceha_longWickMin      = 0.50
ceha_accelBodyMult    = 1.25

//----------------------
// 🎛 Inputs — Candle HA By Name
//----------------------
group_CandleHAName = "🎛 Candle HA — By Name"

ceha_showBullAcceleration = input.bool(true, "HA Bull Acceleration (momentum)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearAcceleration = input.bool(true, "HA Bear Acceleration (momentum)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showStrongBull       = input.bool(true, "HA Strong Bull (strength)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showStrongBear       = input.bool(true, "HA Strong Bear (strength)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showLongBodyBull     = input.bool(true, "HA Long Body Bull (momentum)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showLongBodyBear     = input.bool(true, "HA Long Body Bear (momentum)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showNoLowerWick      = input.bool(true, "HA No Lower Wick (trend strength)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showNoUpperWick      = input.bool(true, "HA No Upper Wick (trend strength)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBullContinuation = input.bool(true, "HA Bull Continuation (continuation)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearContinuation = input.bool(true, "HA Bear Continuation (continuation)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBullPullback     = input.bool(true, "HA Bull Pullback (pullback)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearPullback     = input.bool(true, "HA Bear Pullback (pullback)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showWeakBull         = input.bool(true, "HA Weak Bull (weakness)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showWeakBear         = input.bool(true, "HA Weak Bear (weakness)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showDoji             = input.bool(true, "HA Doji / Indecision (indecision)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showSmallBody        = input.bool(true, "HA Small Body (indecision)", group=group_CandleHAName, tooltip="Sets the calculation length used internally.")
ceha_showBullCandle       = input.bool(true, "HA Bull Candle (basic)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearCandle       = input.bool(true, "HA Bear Candle (basic)", group=group_CandleHAName, tooltip="Enables or filters this candle or pattern type.")

group_ReversalHA = "↩️ Reversal HA"

ceha_rev_enable = input.bool(true, "Enable Reversal HA Candle", group=group_ReversalHA, tooltip="Turns this module on or off.")
ceha_rev_showLabels = input.bool(true, "Show Reversal HA Labels", group=group_ReversalHA, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelReversal = input.bool(true, "Show Reversal HA Panel", group=group_ReversalHA, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelReversalPos = input.string("Bottom Left", "Reversal HA Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=group_ReversalHA, tooltip="Selects the default screen location for the reversal HA panel.")
ce_panelHARevTags = input.bool(false, "Show Reversal HA Secondary Tags", group=group_ReversalHA, tooltip="Shows secondary HA structure tags in the reversal HA panel.")
ce_reversalMaxRows = input.int(20, "Max HA Reversal Label", minval=5, maxval=50, group=group_ReversalHA, tooltip="Maximum number of labels or panel rows kept before automatic cleanup.")

group_ReversalHAName = "↩️ Reversal HA Name"

ceha_showBullReversal   = input.bool(true, "HA Bull Reversal (reversal)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearReversal   = input.bool(true, "HA Bear Reversal (reversal)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showColorFlipBull  = input.bool(true, "HA Color Flip Bull (reversal)", group=group_ReversalHAName, tooltip="Sets the color used by this visual element.")
ceha_showColorFlipBear  = input.bool(true, "HA Color Flip Bear (reversal)", group=group_ReversalHAName, tooltip="Sets the color used by this visual element.")
ceha_showBullDojiRev    = input.bool(true, "HA Bull Doji Reversal (reversal)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearDojiRev    = input.bool(true, "HA Bear Doji Reversal (reversal)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBullExhaustion = input.bool(true, "HA Bull Exhaustion (exhaustion)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearExhaustion = input.bool(true, "HA Bear Exhaustion (exhaustion)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBullWeakening  = input.bool(true, "HA Bull Weakening (weakness)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")
ceha_showBearWeakening  = input.bool(true, "HA Bear Weakening (weakness)", group=group_ReversalHAName, tooltip="Enables or filters this candle or pattern type.")

//----------------------
// 🧮 Heikin Ashi OHLC
//----------------------

ceha_close = (open + high + low + close) / 4.0

var float ceha_open = na
ceha_open := na(ceha_open[1]) ? (open + close) / 2.0 : (ceha_open[1] + ceha_close[1]) / 2.0

ceha_high = math.max(high, math.max(ceha_open, ceha_close))
ceha_low  = math.min(low, math.min(ceha_open, ceha_close))

ceha_body      = math.abs(ceha_close - ceha_open)
ceha_range     = math.max(ceha_high - ceha_low, syminfo.mintick)
ceha_bodyRatio = ceha_body / ceha_range

ceha_isBull = ceha_close > ceha_open
ceha_isBear = ceha_close < ceha_open

ceha_upperWick = ceha_high - math.max(ceha_open, ceha_close)
ceha_lowerWick = math.min(ceha_open, ceha_close) - ceha_low

ceha_upperRatio = ceha_upperWick / ceha_range
ceha_lowerRatio = ceha_lowerWick / ceha_range

ceha_avgBody = ta.sma(ceha_body, 20)

ceha_emaFast = ta.ema(ceha_close, 20)
ceha_emaSlow = ta.ema(ceha_close, 50)

ceha_trendUp = ceha_emaFast > ceha_emaSlow
ceha_trendDn = ceha_emaFast < ceha_emaSlow

//----------------------
// 🕯 HA Candle Conditions
//----------------------
ceha_doji       = ceha_bodyRatio <= ceha_dojiMaxBody
ceha_smallBody  = ceha_bodyRatio <= ceha_smallBodyMax
ceha_longBody   = ceha_bodyRatio >= ceha_strongBodyMin

ceha_noLowerWick = ceha_isBull and ceha_lowerRatio <= ceha_noWickMax
ceha_noUpperWick = ceha_isBear and ceha_upperRatio <= ceha_noWickMax

ceha_strongBull = ceha_isBull and ceha_longBody and ceha_noLowerWick
ceha_strongBear = ceha_isBear and ceha_longBody and ceha_noUpperWick

ceha_weakBull = ceha_isBull and ceha_smallBody
ceha_weakBear = ceha_isBear and ceha_smallBody

ceha_longBodyBull = ceha_isBull and ceha_longBody
ceha_longBodyBear = ceha_isBear and ceha_longBody

ceha_bullContinuation = ceha_isBull and ceha_isBull[1] and ceha_close > ceha_close[1] and ceha_noLowerWick
ceha_bearContinuation = ceha_isBear and ceha_isBear[1] and ceha_close < ceha_close[1] and ceha_noUpperWick

ceha_bullAcceleration = ceha_strongBull and ceha_avgBody > 0 and ceha_body >= ceha_avgBody * ceha_accelBodyMult and ceha_close > ceha_close[1]
ceha_bearAcceleration = ceha_strongBear and ceha_avgBody > 0 and ceha_body >= ceha_avgBody * ceha_accelBodyMult and ceha_close < ceha_close[1]

ceha_bullPullback = ceha_trendUp and ceha_isBear and ceha_smallBody
ceha_bearPullback = ceha_trendDn and ceha_isBull and ceha_smallBody

//----------------------
// ↩️ Reversal HA Conditions
//----------------------
ceha_colorFlipBull = ceha_isBull and ceha_isBear[1]
ceha_colorFlipBear = ceha_isBear and ceha_isBull[1]

ceha_bullReversal = ceha_trendDn and ceha_colorFlipBull and (ceha_lowerRatio >= ceha_longWickMin or ceha_strongBull)
ceha_bearReversal = ceha_trendUp and ceha_colorFlipBear and (ceha_upperRatio >= ceha_longWickMin or ceha_strongBear)

ceha_bullExhaustion = ceha_trendUp and ceha_isBull and ceha_upperRatio >= ceha_longWickMin and ceha_bodyRatio <= ceha_smallBodyMax
ceha_bearExhaustion = ceha_trendDn and ceha_isBear and ceha_lowerRatio >= ceha_longWickMin and ceha_bodyRatio <= ceha_smallBodyMax

ceha_bullWeakening = ceha_trendUp and ceha_isBull and ceha_smallBody and ceha_upperRatio >= 0.25
ceha_bearWeakening = ceha_trendDn and ceha_isBear and ceha_smallBody and ceha_lowerRatio >= 0.25

ceha_bullDojiReversal = ceha_trendDn and ceha_doji and ceha_lowerRatio >= ceha_longWickMin
ceha_bearDojiReversal = ceha_trendUp and ceha_doji and ceha_upperRatio >= ceha_longWickMin

//----------------------
// 🌐 HA Exports
//----------------------
var string ceha_candlePattern = ""
var float  ceha_candleScore   = na

ceha_scoreRaw =
     ceha_strongBull or ceha_strongBear ? 90.0 :
     ceha_bullAcceleration or ceha_bearAcceleration ? 88.0 :
     ceha_bullReversal or ceha_bearReversal ? 85.0 :
     ceha_colorFlipBull or ceha_colorFlipBear ? 78.0 :
     ceha_bullContinuation or ceha_bearContinuation ? 75.0 :
     ceha_bullExhaustion or ceha_bearExhaustion ? 72.0 :
     ceha_bullWeakening or ceha_bearWeakening ? 68.0 :
     ceha_bullDojiReversal or ceha_bearDojiReversal ? 66.0 :
     ceha_longBodyBull or ceha_longBodyBear ? 64.0 :
     ceha_noLowerWick or ceha_noUpperWick ? 62.0 :
     ceha_weakBull or ceha_weakBear ? 55.0 :
     ceha_doji ? 52.0 :
     50.0

ceha_candleScore := ceha_scoreRaw

//----------------------
// 🧾 Build HA Label Text
//----------------------
string ceha_text = ""
int ceha_bias = 0

if ceha_enable
    // Reversal HA first
    if ceha_rev_enable and ceha_showBullReversal and ceha_bullReversal
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bull Reversal"
        ceha_bias += 1

    if ceha_rev_enable and ceha_showBearReversal and ceha_bearReversal
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bear Reversal"
        ceha_bias -= 1

    if ceha_rev_enable and ceha_showColorFlipBull and ceha_colorFlipBull
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Color Flip Bull"
        ceha_bias += 1

    if ceha_rev_enable and ceha_showColorFlipBear and ceha_colorFlipBear
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Color Flip Bear"
        ceha_bias -= 1

    if ceha_rev_enable and ceha_showBullDojiRev and ceha_bullDojiReversal
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bull Doji Reversal"
        ceha_bias += 1

    if ceha_rev_enable and ceha_showBearDojiRev and ceha_bearDojiReversal
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bear Doji Reversal"
        ceha_bias -= 1

    if ceha_rev_enable and ceha_showBullExhaustion and ceha_bullExhaustion
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bull Exhaustion"
        ceha_bias -= 1

    if ceha_rev_enable and ceha_showBearExhaustion and ceha_bearExhaustion
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bear Exhaustion"
        ceha_bias += 1

    if ceha_rev_enable and ceha_showBullWeakening and ceha_bullWeakening
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bull Weakening"
        ceha_bias -= 1

    if ceha_rev_enable and ceha_showBearWeakening and ceha_bearWeakening
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bear Weakening"
        ceha_bias += 1

    // Candle HA standard
    if ceha_showBullAcceleration and ceha_bullAcceleration
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bull Acceleration"
        ceha_bias += 1

    if ceha_showBearAcceleration and ceha_bearAcceleration
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bear Acceleration"
        ceha_bias -= 1

    if ceha_showStrongBull and ceha_strongBull
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Strong Bull"
        ceha_bias += 1

    if ceha_showStrongBear and ceha_strongBear
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Strong Bear"
        ceha_bias -= 1

    if ceha_showBullContinuation and ceha_bullContinuation
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bull Continuation"
        ceha_bias += 1

    if ceha_showBearContinuation and ceha_bearContinuation
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bear Continuation"
        ceha_bias -= 1

    if ceha_showNoLowerWick and ceha_noLowerWick
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA No Lower Wick"
        ceha_bias += 1

    if ceha_showNoUpperWick and ceha_noUpperWick
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA No Upper Wick"
        ceha_bias -= 1

    if ceha_showLongBodyBull and ceha_longBodyBull
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Long Body Bull"
        ceha_bias += 1

    if ceha_showLongBodyBear and ceha_longBodyBear
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Long Body Bear"
        ceha_bias -= 1

    if ceha_showBullPullback and ceha_bullPullback
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bull Pullback"
        ceha_bias -= 1

    if ceha_showBearPullback and ceha_bearPullback
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bear Pullback"
        ceha_bias += 1

    if ceha_showWeakBull and ceha_weakBull
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Weak Bull"
        ceha_bias += 1

    if ceha_showWeakBear and ceha_weakBear
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Weak Bear"
        ceha_bias -= 1

    if ceha_showDoji and ceha_doji
        ceha_text += (ceha_text == "" ? "" : "\n") + "⚪ HA Doji / Indecision"

    if ceha_showSmallBody and ceha_smallBody
        ceha_text += (ceha_text == "" ? "" : "\n") + "⚪ HA Small Body"

    if ceha_showBullCandle and ceha_isBull
        ceha_text += (ceha_text == "" ? "" : "\n") + "🟢 HA Bull Candle"
        ceha_bias += 1

    if ceha_showBearCandle and ceha_isBear
        ceha_text += (ceha_text == "" ? "" : "\n") + "🔴 HA Bear Candle"
        ceha_bias -= 1

ceha_candlePattern := ceha_text == "" ? "None" : ceha_text

ce_firstLine(string x) =>
    array<string> parts = str.split(x, "\n")
    array.size(parts) > 0 ? array.get(parts, 0) : x

//----------------------
// 🏷 HA Visual Labels
//----------------------
var label[] ceha_labels = array.new_label()

if ceha_enable and ceha_showLabels and ceha_text != ""
    float ceha_labelY = ceha_bias >= 0 ? low : high
    color ceha_labelColor = ceha_bias > 0 ? color.new(color.lime, 72) : ceha_bias < 0 ? color.new(color.red, 72) : color.new(color.gray, 72)
    string ceha_labelText = ce_panelHATags ? ceha_text : ce_firstLine(ceha_text)

    label ceha_lb = label.new(
        bar_index,
        ceha_labelY,
        ceha_labelText,
        style = ceha_bias >= 0 ? label.style_label_up : label.style_label_down,
        textcolor = color.white,
        color = ceha_labelColor,
        size = size.tiny
    )

    array.unshift(ceha_labels, ceha_lb)

while array.size(ceha_labels) > ceha_maxLabels
    label ceha_old = array.pop(ceha_labels)
    if not na(ceha_old)
        label.delete(ceha_old)

if not ceha_enable
    while array.size(ceha_labels) > 0
        label ceha_old = array.pop(ceha_labels)
        if not na(ceha_old)
            label.delete(ceha_old)
//=====================================================
// 🕯 Candle Sequence Engine Pro+
//=====================================================

//----------------------
// 🔌 Inputs
//----------------------
seq_groupMain   = "🕯 Candle Sequence Engine Pro++ (Standalone)"

seq_enable      = input.bool(false, "Enable Candle Sequence Engine", group=seq_groupMain, tooltip="Turns this module on or off.")
seq_showLabels  = input.bool(false, "Show Detected Sequence", group=seq_groupMain, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelSeq         = input.bool(true, "Show Pattern Panel", group=seq_groupMain, tooltip="Shows or hides the pattern history panel.")
ce_panelSeqPos = input.string("Bottom Right", "Pattern Panel Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=seq_groupMain, tooltip="Selects the default screen location for the pattern history panel.")
seq_groupReversal = "↩️ Reversal Pattern"
seq_reversalSoloMode = input.bool(false, "Enable Reversal Patterns Only Mode", group=seq_groupReversal, tooltip="Turns this module on or off.")
seq_rev_showLabels = input.bool(true, "Show Pattern Reversal Labels", group=seq_groupReversal, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelPatternRev = input.bool(true, "Show Pattern Reversal Panel", group=seq_groupReversal, tooltip="Shows or hides this chart element, label, panel, or filter.")
ce_panelPatternRevPos = input.string("Bottom Right", "Pattern Reversal Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group=seq_groupReversal, tooltip="Selects the default screen location for the pattern reversal panel.")
ce_patternRevMaxRows = input.int(20, "Max Pattern Reversal Label", minval=5, maxval=50, group=seq_groupReversal, tooltip="Maximum number of labels or panel rows kept before automatic cleanup.")
seq_sensitivity = input.float(0.7, "Detection Sensitivity", minval=0.1, maxval=1.0, step=0.1, group=seq_groupMain, tooltip="Controls how strict the pattern detection is.")
seq_maxPatternLabels = input.int(20, "Max Pattern Labels Visible", minval=1, maxval=50, group=seq_groupMain, tooltip="Maximum number of labels or panel rows kept before automatic cleanup.")

//----------------------
// 🧩 Pattern Length Filters
//----------------------
seq_groupLen = "🧩 Pattern Length Filters (Standalone)"

seq_enable1  = input.bool(true, "Enable 1-candle patterns", group=seq_groupLen, tooltip="Turns this module on or off.")
seq_enable2  = input.bool(true, "Enable 2-candle patterns", group=seq_groupLen, tooltip="Turns this module on or off.")
seq_enable3  = input.bool(true, "Enable 3-candle patterns", group=seq_groupLen, tooltip="Turns this module on or off.")
seq_enable4  = input.bool(true, "Enable 4-candle patterns", group=seq_groupLen, tooltip="Turns this module on or off.")
seq_enable5  = input.bool(true, "Enable 5-candle patterns", group=seq_groupLen, tooltip="Turns this module on or off.")

//----------------------
// 🎛 Pattern Name Filters — Modern
//----------------------
seq_groupModern = "🎛 Pattern Name Filters — Modern"

seq_showKickerBull      = input.bool(true, "Kicker Bull (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showKickerBear      = input.bool(true, "Kicker Bear (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showAbandonedBull   = input.bool(true, "Abandoned Baby Bull (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showAbandonedBear   = input.bool(true, "Abandoned Baby Bear (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showMeetingBull     = input.bool(true, "Meeting Lines Bull (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showMeetingBear     = input.bool(true, "Meeting Lines Bear (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showCounterBull     = input.bool(true, "Counterattack Bull (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showCounterBear     = input.bool(true, "Counterattack Bear (reversal)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showBullTrap        = input.bool(true, "Bull Trap (trap)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showBearTrap        = input.bool(true, "Bear Trap (trap)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showTasukiBull      = input.bool(true, "Tasuki Gap Bull (continuation)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showTasukiBear      = input.bool(true, "Tasuki Gap Bear (continuation)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showInsideBullBreak = input.bool(true, "Inside Bar Bull Break (compression)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showInsideBearBreak = input.bool(true, "Inside Bar Bear Break (compression)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showMatchingLow     = input.bool(true, "Matching Low (support)", group=seq_groupModern, tooltip="Controls this setting for display, filtering, or educational detection.")

//----------------------
// 🎛 Pattern Name Filters — 1 Candle
//----------------------

seq_groupPat1 = "🎛 Pattern Name Filters — 1 Candle"

seq_showPat1Hammer       = input.bool(true, "Hammer (reversal)", group=seq_groupPat1, tooltip="Enables or filters this candle or pattern type.")
seq_showPat1InvHammer    = input.bool(true, "Inverted Hammer (reversal)", group=seq_groupPat1, tooltip="Enables or filters this candle or pattern type.")
seq_showPat1ShootingStar = input.bool(true, "Shooting Star (reversal)", group=seq_groupPat1, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat1HangingMan   = input.bool(true, "Hanging Man (reversal)", group=seq_groupPat1, tooltip="Enables or filters this candle or pattern type.")
seq_showPat1MaruBull     = input.bool(true, "Bull Marubozu (momentum)", group=seq_groupPat1, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat1MaruBear     = input.bool(true, "Bear Marubozu (momentum)", group=seq_groupPat1, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat1Doji         = input.bool(true, "Doji (indecision)", group=seq_groupPat1, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat1SpinningTop  = input.bool(true, "Spinning Top (indecision)", group=seq_groupPat1, tooltip="Controls this setting for display, filtering, or educational detection.")

//----------------------
// 🎛 Pattern Name Filters — 2 Candles
//----------------------

seq_groupPat2 = "🎛 Pattern Name Filters — 2 Candles"

seq_showPat2BullEngulf = input.bool(true, "Bullish Engulfing (reversal)", group=seq_groupPat2, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat2BearEngulf = input.bool(true, "Bearish Engulfing (reversal)", group=seq_groupPat2, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat2Piercing   = input.bool(true, "Piercing Line (reversal)", group=seq_groupPat2, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat2DarkCloud  = input.bool(true, "Dark Cloud Cover (reversal)", group=seq_groupPat2, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat2TweezerBot = input.bool(true, "Tweezer Bottom (reversal)", group=seq_groupPat2, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat2TweezerTop = input.bool(true, "Tweezer Top (reversal)", group=seq_groupPat2, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat2BullHarami = input.bool(true, "Bullish Harami (pause)", group=seq_groupPat2, tooltip="Enables or filters this candle or pattern type.")
seq_showPat2BearHarami = input.bool(true, "Bearish Harami (pause)", group=seq_groupPat2, tooltip="Enables or filters this candle or pattern type.")

//----------------------
// 🎛 Pattern Name Filters — 3 Candles
//----------------------

seq_groupPat3 = "🎛 Pattern Name Filters — 3 Candles"

seq_showPat3MorningStar      = input.bool(true, "Morning Star (reversal)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3EveningStar      = input.bool(true, "Evening Star (reversal)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3Soldiers         = input.bool(true, "Three White Soldiers (momentum)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3Crows            = input.bool(true, "Three Black Crows (momentum)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3ThreeInsideUp    = input.bool(true, "Three Inside Up (confirmation)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3ThreeInsideDown  = input.bool(true, "Three Inside Down (confirmation)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3ThreeOutsideUp   = input.bool(true, "Three Outside Up (confirmation)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat3ThreeOutsideDown = input.bool(true, "Three Outside Down (confirmation)", group=seq_groupPat3, tooltip="Controls this setting for display, filtering, or educational detection.")

//----------------------
// 🎛 Pattern Name Filters — 4 Candles
//----------------------

seq_groupPat4 = "🎛 Pattern Name Filters — 4 Candles"

seq_showPat4LineStrikeBull = input.bool(true, "Bull Three-Line Strike (reversal)", group=seq_groupPat4, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat4LineStrikeBear = input.bool(true, "Bear Three-Line Strike (reversal)", group=seq_groupPat4, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat4BabySwallow    = input.bool(true, "Concealing Baby Swallow (continuation)", group=seq_groupPat4, tooltip="Controls this setting for display, filtering, or educational detection.")

//----------------------
// 🎛 Pattern Name Filters — 5 Candles
//----------------------

seq_groupPat5 = "🎛 Pattern Name Filters — 5 Candles"

seq_showPat5BreakawayBull = input.bool(true, "Breakaway Bull (reversal)", group=seq_groupPat5, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat5BreakawayBear = input.bool(true, "Breakaway Bear (reversal)", group=seq_groupPat5, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat5RisingThree   = input.bool(true, "Rising Three Methods (continuation)", group=seq_groupPat5, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat5FallingThree  = input.bool(true, "Falling Three Methods (continuation)", group=seq_groupPat5, tooltip="Controls this setting for display, filtering, or educational detection.")
seq_showPat5MatHoldBull   = input.bool(true, "Mat Hold Bull (continuation)", group=seq_groupPat5, tooltip="Controls this setting for display, filtering, or educational detection.")

//----------------------
// Paramètres structure chandeliers
//----------------------

//----------------------
// 🧱 Candle Structure Defaults
//----------------------
seq_dojiMaxBodyToRange = 0.12
seq_smallBodyMaxRatio  = 0.30
seq_longBodyMinRatio   = 0.60
seq_marubozuMaxWick    = 0.05
seq_tweezerAtrFrac     = 0.05
seq_trapLookback       = 5
seq_gapAtrFrac         = 0.03

//----------------------
// AI context params
//----------------------
seq_groupAI = "🤖 AI Context Params (Standalone)"

seq_emaFastLen = input.int(20, "EMA Fast", minval=2, maxval=200, group=seq_groupAI, tooltip="Sets the calculation length used internally.")
seq_emaSlowLen = input.int(50, "EMA Slow", minval=2, maxval=400, group=seq_groupAI, tooltip="Sets the calculation length used internally.")
seq_volLen     = input.int(20, "Volume SMA", minval=2, maxval=200, group=seq_groupAI, tooltip="Sets the calculation length used internally.")
seq_atrLen     = input.int(14, "ATR", minval=2, maxval=200, group=seq_groupAI, tooltip="Sets the calculation length used internally.")
seq_atrRefLen  = input.int(50, "ATR Ref SMA", minval=5, maxval=400, group=seq_groupAI, tooltip="Sets the calculation length used internally.")

seq_showAIGauge       = input.bool(true, "Show AI Context Bull/Bear Gauge", group=seq_groupAI, tooltip="Shows or hides this chart element, label, panel, or filter.")
seq_aiGaugePosition  = input.string("Bottom Center", "Gauge Position", options=["Bottom Center", "Top Center"], group=seq_groupAI, tooltip="Selects the default screen location for this panel or gauge.")
seq_aiGaugeBasis      = input.string("Combined Context", "Gauge Basis", options=["EMA Trend", "Volume Bias", "Volatility Bias", "Combined Context"], group=seq_groupAI, tooltip="Controls the bull/bear gauge display or calculation.")
seq_aiGaugeCells      = input.int(24, "Gauge Precision Cells", minval=12, maxval=30, group=seq_groupAI, tooltip="Controls the bull/bear gauge display or calculation.")
seq_aiGaugeBearColor  = input.color(color.rgb(255, 0, 80), "Bear Color", group=seq_groupAI, tooltip="Sets the color used by this visual element.")
seq_aiGaugeMidColor   = input.color(color.rgb(255, 220, 0), "Neutral Color", group=seq_groupAI, tooltip="Sets the color used by this visual element.")
seq_aiGaugeBullColor  = input.color(color.rgb(0, 220, 120), "Bull Color", group=seq_groupAI, tooltip="Sets the color used by this visual element.")
seq_aiGaugeMarkerCol  = input.color(color.white, "Level Marker Color", group=seq_groupAI, tooltip="Sets the color used by this visual element.")
seq_aiGaugeBgColor    = input.color(color.rgb(5, 8, 18), "Background Color", group=seq_groupAI, tooltip="Sets the color used by this visual element.")
seq_aiGaugeTransp     = input.int(15, "Gauge Background Transparency", minval=0, maxval=100, group=seq_groupAI, tooltip="Adjusts opacity; higher values make it more transparent.")

//----------------------
// 🧰 Helpers
//----------------------
seq_clamp(x, lo, hi) => math.min(math.max(x, lo), hi)
seq_abs(x) => math.abs(x)
seq_max(a, b) => math.max(a, b)
seq_min(a, b) => math.min(a, b)

//----------------------
// ✅ Global TA calls
//----------------------
seq_atr      = ta.atr(seq_atrLen)
seq_emaFast  = ta.ema(close, seq_emaFastLen)
seq_emaSlow  = ta.ema(close, seq_emaSlowLen)
seq_avgVol   = ta.sma(volume, seq_volLen)
seq_atrNow   = seq_atr
seq_atrRef   = ta.sma(seq_atrNow, seq_atrRefLen)

//----------------------
// Candle anatomy
//----------------------
seq_body(i)  => seq_abs(close[i] - open[i])
seq_range(i) => high[i] - low[i]
seq_safeRange(i) => math.max(seq_range(i), syminfo.mintick)
seq_upperW(i)=> high[i] - seq_max(open[i], close[i])
seq_lowerW(i)=> seq_min(open[i], close[i]) - low[i]
seq_isBull(i)=> close[i] > open[i]
seq_isBear(i)=> close[i] < open[i]

// Ratio-based classifiers
seq_isDoji(i, maxRatio)      => seq_range(i) > 0 ? (seq_body(i) / seq_range(i)) <= maxRatio : false
seq_isSmallBody(i, maxRatio) => seq_range(i) > 0 ? (seq_body(i) / seq_range(i)) <= maxRatio : false
seq_isLongBody(i, minRatio)  => seq_range(i) > 0 ? (seq_body(i) / seq_range(i)) >= minRatio : false
seq_isMaruBull(i, wickMax)   => seq_isBull(i) and seq_range(i) > 0 ? ((seq_upperW(i)/seq_range(i) <= wickMax) and (seq_lowerW(i)/seq_range(i) <= wickMax)) : false
seq_isMaruBear(i, wickMax)   => seq_isBear(i) and seq_range(i) > 0 ? ((seq_upperW(i)/seq_range(i) <= wickMax) and (seq_lowerW(i)/seq_range(i) <= wickMax)) : false

//----------------------
// 🤖 AI Context
//----------------------
seq_trendBias = seq_emaFast > seq_emaSlow ? 1.0 : seq_emaFast < seq_emaSlow ? -1.0 : 0.0
seq_volBiasRaw = seq_avgVol > 0 ? (volume / seq_avgVol) - 1.0 : 0.0
seq_volBias    = seq_clamp(seq_volBiasRaw, -1.0, 1.0)
seq_volatRaw   = seq_atrRef > 0 ? (seq_atrNow / seq_atrRef) - 1.0 : 0.0
seq_volatBias  = seq_clamp(seq_volatRaw, -1.0, 1.0)

seq_contextFactor = seq_clamp(seq_trendBias * 0.5 + seq_volBias * 0.3 + seq_volatBias * 0.2, -1.0, 1.0)

seq_gaugeRaw =
     seq_aiGaugeBasis == "EMA Trend" ? seq_trendBias :
     seq_aiGaugeBasis == "Volume Bias" ? seq_volBias :
     seq_aiGaugeBasis == "Volatility Bias" ? seq_volatBias :
     seq_contextFactor

seq_gaugeScore = seq_clamp(50.0 + seq_gaugeRaw * 50.0, 0.0, 100.0)

seq_aiScore(baseScore) => seq_clamp(baseScore * (1.0 + seq_contextFactor), 0.0, 100.0)


//----------------------
// 🎚 AI Context Bull/Bear Gauge
//----------------------
var table seq_aiGaugeBottom = table.new(position.bottom_center, 30, 2, bgcolor=color.new(seq_aiGaugeBgColor, 100), frame_color=color.new(seq_aiGaugeMarkerCol, 68), frame_width=1)
var table seq_aiGaugeTop = table.new(position.top_center, 30, 2, bgcolor=color.new(seq_aiGaugeBgColor, 100), frame_color=color.new(seq_aiGaugeMarkerCol, 68), frame_width=1)

seq_gaugeGradient(int idx, int maxIdx) =>
    float mid = maxIdx * 0.5
    idx <= mid ? color.from_gradient(idx, 0, mid, seq_aiGaugeBearColor, seq_aiGaugeMidColor) : color.from_gradient(idx, mid, maxIdx, seq_aiGaugeMidColor, seq_aiGaugeBullColor)

seq_drawGauge(table t, bool enabled) =>
    table.clear(t, 0, 0, 29, 1)
    if enabled
        int maxIdx = seq_aiGaugeCells - 1
        int marker = int(math.round(seq_gaugeScore / 100.0 * maxIdx))
        marker := math.max(0, math.min(maxIdx, marker))

        for g = 0 to seq_aiGaugeCells - 1
            color grad = seq_gaugeGradient(g, maxIdx)
            bool isMarker = g == marker

            table.cell(
                 t,
                 g,
                 0,
                 isMarker ? "▼" : "",
                 text_color = isMarker ? seq_aiGaugeMarkerCol : grad,
                 text_size = size.tiny,
                 bgcolor = grad,
                 width = 2,
                 height = 1
            )

            table.cell(
                 t,
                 g,
                 1,
                 isMarker ? "▲" : "",
                 text_color = isMarker ? seq_aiGaugeMarkerCol : grad,
                 text_size = size.tiny,
                 bgcolor = grad,
                 width = 2,
                 height = 1
            )

if barstate.islast
    seq_drawGauge(seq_aiGaugeBottom, seq_showAIGauge and seq_aiGaugePosition == "Bottom Center")
    seq_drawGauge(seq_aiGaugeTop, seq_showAIGauge and seq_aiGaugePosition == "Top Center")

//----------------------
// ✅ TRUE Japanese patterns — OHLC only
//----------------------
// 1 candle
seq_pat1_doji         = seq_isDoji(0, seq_dojiMaxBodyToRange)
seq_pat1_hammer       = (seq_range(0) > 0) and seq_isSmallBody(0, seq_smallBodyMaxRatio) and (seq_lowerW(0) / seq_range(0) >= 0.55) and (seq_upperW(0) / seq_range(0) <= 0.25)
seq_pat1_invHammer    = (seq_range(0) > 0) and seq_isSmallBody(0, seq_smallBodyMaxRatio) and (seq_upperW(0) / seq_range(0) >= 0.55) and (seq_lowerW(0) / seq_range(0) <= 0.25)
seq_pat1_shootingStar = seq_pat1_invHammer and (seq_trendBias > 0)
seq_pat1_hangingMan   = seq_pat1_hammer and (seq_trendBias > 0)
seq_pat1_spinningTop  = (seq_range(0) > 0) and (seq_body(0)/seq_range(0) <= 0.25) and (seq_upperW(0)/seq_range(0) >= 0.25) and (seq_lowerW(0)/seq_range(0) >= 0.25)
seq_pat1_maruBull     = seq_isMaruBull(0, seq_marubozuMaxWick)
seq_pat1_maruBear     = seq_isMaruBear(0, seq_marubozuMaxWick)

// 2 candles
seq_pat2_bullEngulf = seq_isBear(1) and seq_isBull(0) and open[0] <= close[1] and close[0] >= open[1] and seq_body(0) > seq_body(1)
seq_pat2_bearEngulf = seq_isBull(1) and seq_isBear(0) and open[0] >= close[1] and close[0] <= open[1] and seq_body(0) > seq_body(1)
seq_pat2_bullHarami = seq_isBear(1) and seq_isBull(0) and open[0] > close[1] and close[0] < open[1] and seq_body(0) < seq_body(1)
seq_pat2_bearHarami = seq_isBull(1) and seq_isBear(0) and open[0] < close[1] and close[0] > open[1] and seq_body(0) < seq_body(1)
seq_pat2_piercing   = seq_isBear(1) and seq_isBull(0) and open[0] < low[1] and close[0] > (open[1] + close[1]) / 2.0 and close[0] < open[1]
seq_pat2_darkCloud  = seq_isBull(1) and seq_isBear(0) and open[0] > high[1] and close[0] < (open[1] + close[1]) / 2.0 and close[0] > open[1]
seq_pat2_tweezerBot = seq_isBear(1) and seq_isBull(0) and (math.abs(low[0] - low[1]) <= seq_atr * seq_tweezerAtrFrac)
seq_pat2_tweezerTop = seq_isBull(1) and seq_isBear(0) and (math.abs(high[0] - high[1]) <= seq_atr * seq_tweezerAtrFrac)

// Modern 2/3 candle patterns
seq_gapTol = seq_atr * seq_gapAtrFrac
seq_prevHighTrap = ta.highest(high[1], seq_trapLookback)
seq_prevLowTrap  = ta.lowest(low[1], seq_trapLookback)

seq_pat2_bullTrap = high > seq_prevHighTrap and close < seq_prevHighTrap and close < open
seq_pat2_bearTrap = low < seq_prevLowTrap and close > seq_prevLowTrap and close > open

seq_pat2_kickerBull = seq_isBear(1) and seq_isBull(0) and open[0] > high[1] + seq_gapTol
seq_pat2_kickerBear = seq_isBull(1) and seq_isBear(0) and open[0] < low[1] - seq_gapTol

seq_pat2_matchingLow = seq_isBear(1) and seq_isBear(0) and math.abs(close[0] - close[1]) <= seq_atr * seq_tweezerAtrFrac

seq_pat2_meetingBull = seq_isBear(1) and seq_isBull(0) and math.abs(close[0] - close[1]) <= seq_atr * seq_tweezerAtrFrac
seq_pat2_meetingBear = seq_isBull(1) and seq_isBear(0) and math.abs(close[0] - close[1]) <= seq_atr * seq_tweezerAtrFrac

seq_pat2_counterBull = seq_isBear(1) and seq_isBull(0) and open[0] < close[1] and math.abs(close[0] - close[1]) <= seq_atr * seq_tweezerAtrFrac
seq_pat2_counterBear = seq_isBull(1) and seq_isBear(0) and open[0] > close[1] and math.abs(close[0] - close[1]) <= seq_atr * seq_tweezerAtrFrac

seq_insidePrev = high[1] < high[2] and low[1] > low[2]
seq_pat3_insideBullBreak = seq_insidePrev and close > high[2] and seq_isBull(0)
seq_pat3_insideBearBreak = seq_insidePrev and close < low[2] and seq_isBear(0)

// 3 candles
seq_pat3_morningStar      = seq_isBear(2) and seq_isSmallBody(1, seq_smallBodyMaxRatio) and seq_isBull(0) and close[0] > (open[2] + close[2]) / 2.0
seq_pat3_eveningStar      = seq_isBull(2) and seq_isSmallBody(1, seq_smallBodyMaxRatio) and seq_isBear(0) and close[0] < (open[2] + close[2]) / 2.0
seq_pat3_soldiers         = seq_isBull(2) and seq_isBull(1) and seq_isBull(0) and seq_isLongBody(2, seq_longBodyMinRatio) and seq_isLongBody(1, seq_longBodyMinRatio) and seq_isLongBody(0, seq_longBodyMinRatio) and close[0] > close[1] and close[1] > close[2]
seq_pat3_crows            = seq_isBear(2) and seq_isBear(1) and seq_isBear(0) and seq_isLongBody(2, seq_longBodyMinRatio) and seq_isLongBody(1, seq_longBodyMinRatio) and seq_isLongBody(0, seq_longBodyMinRatio) and close[0] < close[1] and close[1] < close[2]
seq_pat3_threeInsideUp    = seq_isBear(2) and seq_pat2_bullHarami and seq_isBull(0) and close[0] > open[2]
seq_pat3_threeInsideDown  = seq_isBull(2) and seq_pat2_bearHarami and seq_isBear(0) and close[0] < open[2]
seq_pat3_threeOutsideUp   = seq_pat2_bullEngulf and seq_isBull(0) and close[0] > close[1]
seq_pat3_threeOutsideDown = seq_pat2_bearEngulf and seq_isBear(0) and close[0] < close[1]

// More classic/modern 3-candles patterns
seq_pat3_abandonedBull = seq_isBear(2) and seq_isDoji(1, seq_dojiMaxBodyToRange) and seq_isBull(0) and high[1] < low[2] - seq_gapTol and low[0] > high[1] + seq_gapTol
seq_pat3_abandonedBear = seq_isBull(2) and seq_isDoji(1, seq_dojiMaxBodyToRange) and seq_isBear(0) and low[1] > high[2] + seq_gapTol and high[0] < low[1] - seq_gapTol

seq_pat3_tasukiBull = seq_isBull(2) and seq_isBull(1) and low[1] > high[2] and seq_isBear(0) and close[0] > high[2] and close[0] < open[1]
seq_pat3_tasukiBear = seq_isBear(2) and seq_isBear(1) and high[1] < low[2] and seq_isBull(0) and close[0] < low[2] and close[0] > open[1]

// 4 candles
seq_pat4_threeLineStrikeBull     = seq_isBear(3) and seq_isBear(2) and seq_isBear(1) and seq_isBull(0) and close[0] > open[3] and open[0] < close[1]
seq_pat4_threeLineStrikeBear     = seq_isBull(3) and seq_isBull(2) and seq_isBull(1) and seq_isBear(0) and close[0] < open[3] and open[0] > close[1]
seq_pat4_concealingBabySwallow   = seq_isBear(3) and seq_isBear(2) and seq_isBear(1) and seq_isBear(0) and seq_isMaruBear(3, seq_marubozuMaxWick) and seq_isMaruBear(2, seq_marubozuMaxWick) and (high[1] < low[2]) and (high[0] > high[1]) and (low[0] < low[1])

// 5 candles
seq_pat5_risingThree   = seq_isBull(4) and seq_isBear(3) and seq_isBear(2) and seq_isBear(1) and seq_isBull(0) and close[0] > close[4] and high[3] < high[4] and low[3] > low[4] and high[2] < high[4] and low[2] > low[4] and high[1] < high[4] and low[1] > low[4]
seq_pat5_fallingThree  = seq_isBear(4) and seq_isBull(3) and seq_isBull(2) and seq_isBull(1) and seq_isBear(0) and close[0] < close[4] and high[3] < high[4] and low[3] > low[4] and high[2] < high[4] and low[2] > low[4] and high[1] < high[4] and low[1] > low[4]
seq_pat5_matHoldBull   = seq_isBull(4) and seq_isBull(0) and close[0] > close[4] and (seq_isSmallBody(3, seq_smallBodyMaxRatio) or seq_isSmallBody(2, seq_smallBodyMaxRatio) or seq_isSmallBody(1, seq_smallBodyMaxRatio)) and low[3] > low[4] and low[2] > low[4] and low[1] > low[4]
seq_pat5_breakawayBull = seq_isBear(4) and seq_isBear(3) and seq_isBear(2) and seq_isBear(1) and seq_isBull(0) and close[0] > open[4]
seq_pat5_breakawayBear = seq_isBull(4) and seq_isBull(3) and seq_isBull(2) and seq_isBull(1) and seq_isBear(0) and close[0] < open[4]

//----------------------
// 🎯 pattern + score
//----------------------
string seq_type = "None"
float  seq_score = na
bool   seq_isBullish = false
bool   seq_isBearish = false

seq_baseStrong = 85.0
seq_baseMed    = 75.0
seq_baseLite   = 65.0

seq_revOn(bool enabled) =>
    seq_reversalSoloMode ? true : enabled

seq_nonRevOn(bool enabled) =>
    seq_reversalSoloMode ? false : enabled

seq_lenOn(bool enabled) =>
    seq_reversalSoloMode ? true : enabled

if (seq_enable or seq_reversalSoloMode) and bar_index > 10
    // 5
    if seq_lenOn(seq_enable5) and seq_nonRevOn(seq_showPat5RisingThree) and seq_pat5_risingThree
        seq_type := "🟢 Rising Three Methods (5)"
        seq_score := seq_baseStrong
        seq_isBullish := true
    else if seq_lenOn(seq_enable5) and seq_nonRevOn(seq_showPat5FallingThree) and seq_pat5_fallingThree
        seq_type := "🔴 Falling Three Methods (5)"
        seq_score := seq_baseStrong
        seq_isBearish := true
    else if seq_lenOn(seq_enable5) and seq_nonRevOn(seq_showPat5MatHoldBull) and seq_pat5_matHoldBull
        seq_type := "🟢 Mat Hold (5)"
        seq_score := seq_baseStrong
        seq_isBullish := true
    else if seq_lenOn(seq_enable5) and seq_revOn(seq_showPat5BreakawayBull) and seq_pat5_breakawayBull
        seq_type := "🟢 Breakaway (5)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable5) and seq_revOn(seq_showPat5BreakawayBear) and seq_pat5_breakawayBear
        seq_type := "🔴 Breakaway (5)"
        seq_score := seq_baseMed
        seq_isBearish := true

    // 4
    else if seq_lenOn(seq_enable4) and seq_revOn(seq_showPat4LineStrikeBull) and seq_pat4_threeLineStrikeBull
        seq_type := "🟢 Three-Line Strike (4)"
        seq_score := seq_baseStrong
        seq_isBullish := true
    else if seq_lenOn(seq_enable4) and seq_revOn(seq_showPat4LineStrikeBear) and seq_pat4_threeLineStrikeBear
        seq_type := "🔴 Three-Line Strike (4)"
        seq_score := seq_baseStrong
        seq_isBearish := true
    else if seq_lenOn(seq_enable4) and seq_nonRevOn(seq_showPat4BabySwallow) and seq_pat4_concealingBabySwallow
        seq_type := "🔴 Concealing Baby Swallow (4)"
        seq_score := seq_baseStrong
        seq_isBearish := true

    // 3 — modern first
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showAbandonedBull) and seq_pat3_abandonedBull
        seq_type := "🟢 Abandoned Baby Bull (3)"
        seq_score := seq_baseStrong
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showAbandonedBear) and seq_pat3_abandonedBear
        seq_type := "🔴 Abandoned Baby Bear (3)"
        seq_score := seq_baseStrong
        seq_isBearish := true
    else if seq_lenOn(seq_enable3) and seq_nonRevOn(seq_showTasukiBull) and seq_pat3_tasukiBull
        seq_type := "🟢 Tasuki Gap Bull (3)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_nonRevOn(seq_showTasukiBear) and seq_pat3_tasukiBear
        seq_type := "🔴 Tasuki Gap Bear (3)"
        seq_score := seq_baseMed
        seq_isBearish := true
    else if seq_lenOn(seq_enable3) and seq_nonRevOn(seq_showInsideBullBreak) and seq_pat3_insideBullBreak
        seq_type := "🟢 Inside Bar Bull Break (3)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_nonRevOn(seq_showInsideBearBreak) and seq_pat3_insideBearBreak
        seq_type := "🔴 Inside Bar Bear Break (3)"
        seq_score := seq_baseMed
        seq_isBearish := true

    // 3 — existing
    else if seq_lenOn(seq_enable3) and seq_nonRevOn(seq_showPat3Soldiers) and seq_pat3_soldiers
        seq_type := "🟢 Three White Soldiers (3)"
        seq_score := seq_baseStrong
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_nonRevOn(seq_showPat3Crows) and seq_pat3_crows
        seq_type := "🔴 Three Black Crows (3)"
        seq_score := seq_baseStrong
        seq_isBearish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showPat3MorningStar) and seq_pat3_morningStar
        seq_type := "🟢 Morning Star (3)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showPat3EveningStar) and seq_pat3_eveningStar
        seq_type := "🔴 Evening Star (3)"
        seq_score := seq_baseMed
        seq_isBearish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showPat3ThreeInsideUp) and seq_pat3_threeInsideUp
        seq_type := "🟢 Three Inside Up (3)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showPat3ThreeInsideDown) and seq_pat3_threeInsideDown
        seq_type := "🔴 Three Inside Down (3)"
        seq_score := seq_baseMed
        seq_isBearish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showPat3ThreeOutsideUp) and seq_pat3_threeOutsideUp
        seq_type := "🟢 Three Outside Up (3)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable3) and seq_revOn(seq_showPat3ThreeOutsideDown) and seq_pat3_threeOutsideDown
        seq_type := "🔴 Three Outside Down (3)"
        seq_score := seq_baseMed
        seq_isBearish := true

    // 2 — modern first
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showBullTrap) and seq_pat2_bullTrap
        seq_type := "🔴 Bull Trap (2)"
        seq_score := seq_baseMed
        seq_isBearish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showBearTrap) and seq_pat2_bearTrap
        seq_type := "🟢 Bear Trap (2)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showKickerBull) and seq_pat2_kickerBull
        seq_type := "🟢 Kicker Bull (2)"
        seq_score := seq_baseStrong
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showKickerBear) and seq_pat2_kickerBear
        seq_type := "🔴 Kicker Bear (2)"
        seq_score := seq_baseStrong
        seq_isBearish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showMatchingLow) and seq_pat2_matchingLow
        seq_type := "🟢 Matching Low (2)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showMeetingBull) and seq_pat2_meetingBull
        seq_type := "🟢 Meeting Lines Bull (2)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showMeetingBear) and seq_pat2_meetingBear
        seq_type := "🔴 Meeting Lines Bear (2)"
        seq_score := seq_baseLite
        seq_isBearish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showCounterBull) and seq_pat2_counterBull
        seq_type := "🟢 Counterattack Bull (2)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showCounterBear) and seq_pat2_counterBear
        seq_type := "🔴 Counterattack Bear (2)"
        seq_score := seq_baseLite
        seq_isBearish := true

    // 2 — existing
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2BullEngulf) and seq_pat2_bullEngulf
        seq_type := "🟢 Bullish Engulfing (2)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2BearEngulf) and seq_pat2_bearEngulf
        seq_type := "🔴 Bearish Engulfing (2)"
        seq_score := seq_baseMed
        seq_isBearish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2Piercing) and seq_pat2_piercing
        seq_type := "🟢 Piercing Line (2)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2DarkCloud) and seq_pat2_darkCloud
        seq_type := "🔴 Dark Cloud Cover (2)"
        seq_score := seq_baseLite
        seq_isBearish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2BullHarami) and seq_pat2_bullHarami
        seq_type := "🟢 Bullish Harami (2)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2BearHarami) and seq_pat2_bearHarami
        seq_type := "🔴 Bearish Harami (2)"
        seq_score := seq_baseLite
        seq_isBearish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2TweezerBot) and seq_pat2_tweezerBot
        seq_type := "🟢 Tweezer Bottom (2)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable2) and seq_revOn(seq_showPat2TweezerTop) and seq_pat2_tweezerTop
        seq_type := "🔴 Tweezer Top (2)"
        seq_score := seq_baseLite
        seq_isBearish := true

    // 1 — existing
    else if seq_lenOn(seq_enable1) and seq_nonRevOn(seq_showPat1MaruBull) and seq_pat1_maruBull
        seq_type := "🟢 Bull Marubozu (1)"
        seq_score := seq_baseMed
        seq_isBullish := true
    else if seq_lenOn(seq_enable1) and seq_nonRevOn(seq_showPat1MaruBear) and seq_pat1_maruBear
        seq_type := "🔴 Bear Marubozu (1)"
        seq_score := seq_baseMed
        seq_isBearish := true
    else if seq_lenOn(seq_enable1) and seq_revOn(seq_showPat1ShootingStar) and seq_pat1_shootingStar
        seq_type := "🔴 Shooting Star (1)"
        seq_score := seq_baseLite
        seq_isBearish := true
    else if seq_lenOn(seq_enable1) and seq_revOn(seq_showPat1HangingMan) and seq_pat1_hangingMan
        seq_type := "🔴 Hanging Man (1)"
        seq_score := seq_baseLite
        seq_isBearish := true
    else if seq_lenOn(seq_enable1) and seq_revOn(seq_showPat1Hammer) and seq_pat1_hammer
        seq_type := "🟢 Hammer (1)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable1) and seq_revOn(seq_showPat1InvHammer) and seq_pat1_invHammer
        seq_type := "🟢 Inverted Hammer (1)"
        seq_score := seq_baseLite
        seq_isBullish := true
    else if seq_lenOn(seq_enable1) and seq_nonRevOn(seq_showPat1SpinningTop) and seq_pat1_spinningTop
        seq_type := "⚪ Spinning Top (1)"
        seq_score := 55.0
    else if seq_lenOn(seq_enable1) and seq_nonRevOn(seq_showPat1Doji) and seq_pat1_doji
        seq_type := "⚪ Doji (1)"
        seq_score := 52.0

//----------------------
// 🤖 Final AI score
//----------------------
seq_aiScoreFinal = not na(seq_score) ? seq_aiScore(seq_score) : na
seq_threshold    = 50.0 * seq_sensitivity
seq_valid        = (seq_enable or seq_reversalSoloMode) and (seq_type != "None") and not na(seq_aiScoreFinal) and (seq_aiScoreFinal > seq_threshold)
ce_cleanName(string x) =>
    string y = str.replace_all(x, "🟢 ", "")
    y := str.replace_all(y, "🔴 ", "")
    y := str.replace_all(y, "⚪ ", "")
    y := str.replace_all(y, "🟠 ", "")
    y := str.replace_all(y, "⚠️ ", "")
    y := str.replace_all(y, "🚀 ", "")
    y := str.replace_all(y, "↩️ ", "")
    y := str.replace_all(y, "🌅 ", "")
    y := str.replace_all(y, "🌆 ", "")
    y

//----------------------
// 🏷 Label pattern
//----------------------
var label[] seq_patLabels = array.new_label()

if seq_valid and seq_showLabels
    string seq_txt = (seq_isBullish ? "🟢 " : seq_isBearish ? "🔴 " : "⚪ ") + ce_cleanName(seq_type) + " (" + str.tostring(seq_aiScoreFinal, "#.##") + "%)"
    label lp = label.new(
        bar_index,
        high,
        seq_txt,
        style=label.style_label_down,
        textcolor=color.white,
        color=color.new(seq_isBullish ? color.lime : seq_isBearish ? color.red : color.gray, 70),
        size=size.small
    )
    array.unshift(seq_patLabels, lp)

while array.size(seq_patLabels) > seq_maxPatternLabels
    label oldp = array.pop(seq_patLabels)
    if not na(oldp)
        label.delete(oldp)

if not seq_enable
    while array.size(seq_patLabels) > 0
        label oldp = array.pop(seq_patLabels)
        if not na(oldp)
            label.delete(oldp)


//=====================================================
// 📋 EDUCATIONAL HISTORY PANELS
//=====================================================

group_CEHistoryPanels = "📋 Educational History Panels"

ce_panelMaster      = input.bool(true, "Enable History Panels", group=group_CEHistoryPanels, tooltip="Turns this module on or off.")


ce_panelTextSize    = input.string("tiny", "Panel Text Size", options=["tiny","small","normal"], group=group_CEHistoryPanels, tooltip="Controls this setting for display, filtering, or educational detection.")
ce_panelBg          = input.color(color.black, "Panel Background", group=group_CEHistoryPanels, tooltip="Controls this setting for display, filtering, or educational detection.")
ce_panelHeaderBg    = input.color(color.rgb(20, 60, 110), "Header Background", group=group_CEHistoryPanels, tooltip="Sets the color used by this visual element.")
ce_panelBorder      = input.color(color.rgb(80, 140, 220), "Border Color", group=group_CEHistoryPanels, tooltip="Sets the color used by this visual element.")
ce_panelText        = input.color(color.white, "Text Color", group=group_CEHistoryPanels, tooltip="Sets the color used by this visual element.")
ce_panelMuted       = input.color(color.gray, "Muted Text", group=group_CEHistoryPanels, tooltip="Controls this setting for display, filtering, or educational detection.")
ce_panelBgTransp    = input.int(12, "Panel Background Transparency", minval=0, maxval=100, group=group_CEHistoryPanels, tooltip="Adjusts opacity; higher values make it more transparent.")

ce_histPanelSize(string s) =>
    s == "small" ? size.small :
     s == "normal" ? size.normal :
     size.tiny

ce_histPanelPos(string s) =>
    s == "Top Left" ? position.top_left :
     s == "Top Center" ? position.top_center :
     s == "Top Right" ? position.top_right :
     s == "Middle Left" ? position.middle_left :
     s == "Middle Center" ? position.middle_center :
     s == "Middle Right" ? position.middle_right :
     s == "Bottom Left" ? position.bottom_left :
     s == "Bottom Center" ? position.bottom_center :
     position.bottom_right


ce_candleMeaning(string p) =>
    str.contains(p, "Bull Imbalance") ? "bull: gap-like demand area; watch if price respects it." :
     str.contains(p, "Bear Imbalance") ? "bear: supply gap left behind; watch reaction on retest." :
     str.contains(p, "Bullish Displacement") ? "bull: large body shows aggressive upward repricing." :
     str.contains(p, "Bearish Displacement") ? "bear: large body shows aggressive downward repricing." :
     str.contains(p, "Bullish Sweep") ? "bull: low was raided then reclaimed by buyers." :
     str.contains(p, "Bearish Sweep") ? "bear: high was raided then rejected by sellers." :
     str.contains(p, "Bull Exhaustion") ? "bear warning: upper wick shows buyers failed to hold highs." :
     str.contains(p, "Bear Exhaustion") ? "bull warning: lower wick shows sellers failed to hold lows." :
     str.contains(p, "Bullish Rejection") ? "bull: lower wick shows demand defended the dip." :
     str.contains(p, "Bearish Rejection") ? "bear: upper wick shows supply defended the rally." :
     str.contains(p, "Outside Bar Bull") ? "bull: wider range closed upward after expansion." :
     str.contains(p, "Outside Bar Bear") ? "bear: wider range closed downward after expansion." :
     str.contains(p, "Mother Bar") ? "neutral: broad range sets breakout boundaries." :
     str.contains(p, "NR7") ? "neutral: 7-bar compression often precedes expansion." :
     str.contains(p, "NR4") ? "neutral: 4-bar compression shows short-term pause." :
     str.contains(p, "Bull Wide") ? "bull: strong range candle shows active buying." :
     str.contains(p, "Bear Wide") ? "bear: strong range candle shows active selling." :
     str.contains(p, "Dragonfly") ? "bull lean: sellers pushed down but lost control." :
     str.contains(p, "Gravestone") ? "bear lean: buyers pushed up but lost control." :
     str.contains(p, "Long-Legged") ? "neutral: large wicks show two-sided conflict." :
     str.contains(p, "Doji") ? "neutral: open and close are close; wait for direction." :
     str.contains(p, "Bull Marubozu") ? "bull: full body suggests persistent buying pressure." :
     str.contains(p, "Bear Marubozu") ? "bear: full body suggests persistent selling pressure." :
     str.contains(p, "Bull Engulf") ? "bull: current body absorbs prior bearish pressure." :
     str.contains(p, "Bear Engulf") ? "bear: current body absorbs prior bullish pressure." :
     str.contains(p, "Inside Bar") ? "neutral: price is coiling inside the prior candle." :
     str.contains(p, "Hammer") ? "bull lean: lower rejection after a sell push." :
     str.contains(p, "Shooting Star") ? "bear lean: upper rejection after a buy push." :
     str.contains(p, "Tweezer Top") ? "bear lean: equal highs mark possible resistance." :
     str.contains(p, "Tweezer Bottom") ? "bull lean: equal lows mark possible support." :
     str.contains(p, "Bull Candle") ? "bull: close finished above the open." :
     str.contains(p, "Bear Candle") ? "bear: close finished below the open." :
     "neutral: read this candle with trend and level context."

ce_tagAdd(string base, string tag) =>
    base == "" ? tag : base + " + " + tag

ce_haPrimaryName() =>
    ceha_rev_enable and ceha_showBullReversal and ceha_bullReversal ? "HA Bull Reversal (reversal)" :
     ceha_rev_enable and ceha_showBearReversal and ceha_bearReversal ? "HA Bear Reversal (reversal)" :
     ceha_rev_enable and ceha_showBullExhaustion and ceha_bullExhaustion ? "HA Bull Exhaustion (exhaustion)" :
     ceha_rev_enable and ceha_showBearExhaustion and ceha_bearExhaustion ? "HA Bear Exhaustion (exhaustion)" :
     ceha_rev_enable and ceha_showBullWeakening and ceha_bullWeakening ? "HA Bull Weakening (weakness)" :
     ceha_rev_enable and ceha_showBearWeakening and ceha_bearWeakening ? "HA Bear Weakening (weakness)" :
     ceha_showBullAcceleration and ceha_bullAcceleration ? "HA Bull Acceleration (momentum)" :
     ceha_showBearAcceleration and ceha_bearAcceleration ? "HA Bear Acceleration (momentum)" :
     ceha_showStrongBull and ceha_strongBull ? "HA Strong Bull (strength)" :
     ceha_showStrongBear and ceha_strongBear ? "HA Strong Bear (strength)" :
     ceha_showBullContinuation and ceha_bullContinuation ? "HA Bull Continuation (continuation)" :
     ceha_showBearContinuation and ceha_bearContinuation ? "HA Bear Continuation (continuation)" :
     ceha_showBullPullback and ceha_bullPullback ? "HA Bull Pullback (pullback)" :
     ceha_showBearPullback and ceha_bearPullback ? "HA Bear Pullback (pullback)" :
     ceha_showNoLowerWick and ceha_noLowerWick ? "HA No Lower Wick (trend strength)" :
     ceha_showNoUpperWick and ceha_noUpperWick ? "HA No Upper Wick (trend strength)" :
     ceha_showLongBodyBull and ceha_longBodyBull ? "HA Long Body Bull (momentum)" :
     ceha_showLongBodyBear and ceha_longBodyBear ? "HA Long Body Bear (momentum)" :
     ceha_showWeakBull and ceha_weakBull ? "HA Weak Bull (weakness)" :
     ceha_showWeakBear and ceha_weakBear ? "HA Weak Bear (weakness)" :
     ceha_rev_enable and ceha_showBullDojiRev and ceha_bullDojiReversal ? "HA Bull Doji Reversal (reversal)" :
     ceha_rev_enable and ceha_showBearDojiRev and ceha_bearDojiReversal ? "HA Bear Doji Reversal (reversal)" :
     ceha_showDoji and ceha_doji ? "HA Doji / Indecision (indecision)" :
     ceha_showSmallBody and ceha_smallBody ? "HA Small Body (indecision)" :
     ceha_rev_enable and ceha_showColorFlipBull and ceha_colorFlipBull ? "HA Color Flip Bull (reversal)" :
     ceha_rev_enable and ceha_showColorFlipBear and ceha_colorFlipBear ? "HA Color Flip Bear (reversal)" :
     ceha_showBullCandle and ceha_isBull ? "HA Bull Candle (basic)" :
     ceha_showBearCandle and ceha_isBear ? "HA Bear Candle (basic)" :
     "HA Candle"

ce_haTags(string mainName) =>
    string tags = ""
    if ceha_rev_enable and ceha_showColorFlipBull and ceha_colorFlipBull and mainName != "HA Color Flip Bull (reversal)"
        tags := ce_tagAdd(tags, "color flip bull")
    if ceha_rev_enable and ceha_showColorFlipBear and ceha_colorFlipBear and mainName != "HA Color Flip Bear (reversal)"
        tags := ce_tagAdd(tags, "color flip bear")
    if ceha_showNoLowerWick and ceha_noLowerWick and mainName != "HA No Lower Wick (trend strength)"
        tags := ce_tagAdd(tags, "no lower wick")
    if ceha_showNoUpperWick and ceha_noUpperWick and mainName != "HA No Upper Wick (trend strength)"
        tags := ce_tagAdd(tags, "no upper wick")
    if ceha_showLongBodyBull and ceha_longBodyBull and mainName != "HA Long Body Bull (momentum)"
        tags := ce_tagAdd(tags, "long bull body")
    if ceha_showLongBodyBear and ceha_longBodyBear and mainName != "HA Long Body Bear (momentum)"
        tags := ce_tagAdd(tags, "long bear body")
    if ceha_showStrongBull and ceha_strongBull and mainName != "HA Strong Bull (strength)"
        tags := ce_tagAdd(tags, "strong bull")
    if ceha_showStrongBear and ceha_strongBear and mainName != "HA Strong Bear (strength)"
        tags := ce_tagAdd(tags, "strong bear")
    if ceha_showBullContinuation and ceha_bullContinuation and mainName != "HA Bull Continuation (continuation)"
        tags := ce_tagAdd(tags, "bull continuation")
    if ceha_showBearContinuation and ceha_bearContinuation and mainName != "HA Bear Continuation (continuation)"
        tags := ce_tagAdd(tags, "bear continuation")
    if ceha_showBullAcceleration and ceha_bullAcceleration and mainName != "HA Bull Acceleration (momentum)"
        tags := ce_tagAdd(tags, "bull acceleration")
    if ceha_showBearAcceleration and ceha_bearAcceleration and mainName != "HA Bear Acceleration (momentum)"
        tags := ce_tagAdd(tags, "bear acceleration")
    if ceha_showDoji and ceha_doji and mainName != "HA Doji / Indecision (indecision)"
        tags := ce_tagAdd(tags, "doji")
    if ceha_showSmallBody and ceha_smallBody and mainName != "HA Small Body (indecision)"
        tags := ce_tagAdd(tags, "small body")
    tags

ce_haMeaning(string p) =>
    str.contains(p, "Bull Reversal") ? "bull: ha flips after weakness with rejection or strength." :
     str.contains(p, "Bear Reversal") ? "bear: ha flips after strength with rejection or weakness." :
     str.contains(p, "Color Flip Bull") ? "bull: first ha color shift; confirm follow-through." :
     str.contains(p, "Color Flip Bear") ? "bear: first ha color shift; confirm continuation." :
     str.contains(p, "Bull Doji Reversal") ? "bull warning: doji after decline can mark seller fatigue." :
     str.contains(p, "Bear Doji Reversal") ? "bear warning: doji after rally can mark buyer fatigue." :
     str.contains(p, "Bull Exhaustion") ? "bear warning: bullish ha shows an upper failure wick." :
     str.contains(p, "Bear Exhaustion") ? "bull warning: bearish ha shows a lower failure wick." :
     str.contains(p, "Bull Weakening") ? "bull weakens: small body and wick show slower demand." :
     str.contains(p, "Bear Weakening") ? "bear weakens: small body and wick show slower supply." :
     str.contains(p, "Bull Acceleration") ? "bull: ha body expands; trend pressure is increasing." :
     str.contains(p, "Bear Acceleration") ? "bear: ha body expands; downside pressure is increasing." :
     str.contains(p, "Strong Bull") ? "bull: strong ha body with clean downside control." :
     str.contains(p, "Strong Bear") ? "bear: strong ha body with clean upside control." :
     str.contains(p, "Bull Continuation") ? "bull: repeated ha strength supports trend follow-through." :
     str.contains(p, "Bear Continuation") ? "bear: repeated ha weakness supports trend follow-through." :
     str.contains(p, "No Lower Wick") ? "bull: no lower wick shows buyers kept control." :
     str.contains(p, "No Upper Wick") ? "bear: no upper wick shows sellers kept control." :
     str.contains(p, "Long Body Bull") ? "bull: large ha body shows clear directional pressure." :
     str.contains(p, "Long Body Bear") ? "bear: large ha body shows clear directional pressure." :
     str.contains(p, "Bull Pullback") ? "neutral/bull: small ha pullback inside an uptrend." :
     str.contains(p, "Bear Pullback") ? "neutral/bear: small ha pullback inside a downtrend." :
     str.contains(p, "Weak Bull") ? "bull weak: close is bullish but conviction is limited." :
     str.contains(p, "Weak Bear") ? "bear weak: close is bearish but conviction is limited." :
     str.contains(p, "Doji") ? "neutral: ha indecision; wait for the next body." :
     str.contains(p, "Small Body") ? "neutral: momentum is compressed inside the ha candle." :
     str.contains(p, "Bull Candle") ? "bull: basic ha candle points upward." :
     str.contains(p, "Bear Candle") ? "bear: basic ha candle points downward." :
     "neutral: compare ha state with raw candles and trend."

ce_seqMeaning(string p) =>
    str.contains(p, "Rising Three") ? "bull: continuation after controlled pullback candles." :
     str.contains(p, "Falling Three") ? "bear: continuation after controlled counter candles." :
     str.contains(p, "Mat Hold") ? "bull: pullback holds above the impulse base." :
     str.contains(p, "Breakaway Bull") ? "bull: multi-candle shift out of bearish pressure." :
     str.contains(p, "Breakaway Bear") ? "bear: multi-candle shift out of bullish pressure." :
     str.contains(p, "Bull Three-Line Strike") ? "bull reversal: one candle erases a bearish run." :
     str.contains(p, "Bear Three-Line Strike") ? "bear reversal: one candle erases a bullish run." :
     str.contains(p, "Concealing Baby") ? "bear: rare continuation showing trapped buyers." :
     str.contains(p, "Abandoned Baby Bull") ? "bull: gap and doji show a sharp sentiment turn." :
     str.contains(p, "Abandoned Baby Bear") ? "bear: gap and doji show a sharp sentiment turn." :
     str.contains(p, "Tasuki Gap Bull") ? "bull: gap tries to hold during a small pullback." :
     str.contains(p, "Tasuki Gap Bear") ? "bear: downside gap tries to hold on bounce." :
     str.contains(p, "Inside Bar Bull Break") ? "bull: compressed range breaks upward." :
     str.contains(p, "Inside Bar Bear Break") ? "bear: compressed range breaks downward." :
     str.contains(p, "Three White Soldiers") ? "bull: three strong closes show sustained demand." :
     str.contains(p, "Three Black Crows") ? "bear: three weak closes show sustained supply." :
     str.contains(p, "Morning Star") ? "bull: selling slows, then buyers reclaim control." :
     str.contains(p, "Evening Star") ? "bear: buying slows, then sellers reclaim control." :
     str.contains(p, "Three Inside Up") ? "bull: harami pause gets upward confirmation." :
     str.contains(p, "Three Inside Down") ? "bear: harami pause gets downward confirmation." :
     str.contains(p, "Three Outside Up") ? "bull: engulfing receives follow-through confirmation." :
     str.contains(p, "Three Outside Down") ? "bear: engulfing receives follow-through confirmation." :
     str.contains(p, "Bull Trap") ? "bear: upside breakout failed and reversed back inside." :
     str.contains(p, "Bear Trap") ? "bull: downside breakout failed and reclaimed range." :
     str.contains(p, "Kicker Bull") ? "bull: abrupt gap-like shift from sell to buy." :
     str.contains(p, "Kicker Bear") ? "bear: abrupt gap-like shift from buy to sell." :
     str.contains(p, "Matching Low") ? "bull lean: repeated close suggests support defense." :
     str.contains(p, "Meeting Lines Bull") ? "bull: counter candle meets prior close after selling." :
     str.contains(p, "Meeting Lines Bear") ? "bear: counter candle meets prior close after buying." :
     str.contains(p, "Counterattack Bull") ? "bull: sellers are answered by a strong opposing close." :
     str.contains(p, "Counterattack Bear") ? "bear: buyers are answered by a strong opposing close." :
     str.contains(p, "Bullish Engulfing") ? "bull: new body fully overpowers the prior bear body." :
     str.contains(p, "Bearish Engulfing") ? "bear: new body fully overpowers the prior bull body." :
     str.contains(p, "Piercing") ? "bull: recovery closes deep into the prior bear candle." :
     str.contains(p, "Dark Cloud") ? "bear: sell candle closes deep into prior bull body." :
     str.contains(p, "Bullish Harami") ? "neutral/bull: small body pauses inside prior sell body." :
     str.contains(p, "Bearish Harami") ? "neutral/bear: small body pauses inside prior buy body." :
     str.contains(p, "Tweezer Bottom") ? "bull lean: repeated lows show support reaction." :
     str.contains(p, "Tweezer Top") ? "bear lean: repeated highs show resistance reaction." :
     str.contains(p, "Hammer") ? "bull lean: single candle rejects lower prices." :
     str.contains(p, "Shooting Star") ? "bear lean: single candle rejects higher prices." :
     str.contains(p, "Doji") ? "neutral: sequence begins with indecision." :
     str.contains(p, "Marubozu") ? "directional: full body shows one-sided pressure." :
     "neutral: sequence needs trend, level, and follow-through context."

ce_candleFamily(string p) =>
    str.contains(p, "Sweep") ? "liquidity" :
     str.contains(p, "Engulf") or str.contains(p, "Hammer") or str.contains(p, "Shooting Star") or str.contains(p, "Tweezer") or str.contains(p, "Dragonfly") or str.contains(p, "Gravestone") ? "reversal" :
     str.contains(p, "Exhaustion") or str.contains(p, "Weak") ? "exhaustion" :
     str.contains(p, "Displacement") or str.contains(p, "Wide") or str.contains(p, "Marubozu") ? "momentum" :
     str.contains(p, "Imbalance") ? "imbalance" :
     str.contains(p, "Inside") or str.contains(p, "NR4") or str.contains(p, "NR7") or str.contains(p, "Mother") ? "compression" :
     str.contains(p, "Doji") or str.contains(p, "Long-Legged") ? "indecision" :
     str.contains(p, "Outside") ? "range expansion" :
     "basic"

ce_candleBias(string p) =>
    str.contains(p, "Bull") or str.contains(p, "Hammer") or str.contains(p, "Dragonfly") or str.contains(p, "Tweezer Bottom") ? "bull" :
     str.contains(p, "Bear") or str.contains(p, "Shooting Star") or str.contains(p, "Gravestone") or str.contains(p, "Tweezer Top") ? "bear" :
     str.contains(p, "Doji") or str.contains(p, "Inside") or str.contains(p, "NR4") or str.contains(p, "NR7") or str.contains(p, "Mother") ? "neutral" :
     cIsBull ? "bull" : cIsBear ? "bear" : "neutral"

ce_haFamily(string p) =>
    str.contains(p, "Reversal") or str.contains(p, "Color Flip") ? "reversal" :
     str.contains(p, "Exhaustion") or str.contains(p, "Weakening") ? "exhaustion" :
     str.contains(p, "Acceleration") ? "momentum" :
     str.contains(p, "Strong") or str.contains(p, "No Lower Wick") or str.contains(p, "No Upper Wick") or str.contains(p, "Long Body") ? "trend strength" :
     str.contains(p, "Continuation") ? "continuation" :
     str.contains(p, "Pullback") ? "pullback" :
     str.contains(p, "Doji") or str.contains(p, "Small Body") ? "indecision" :
     "basic"

ce_haBiasFromName(string p) =>
    str.contains(p, "Bull") or str.contains(p, "No Lower Wick") ? "bull" :
     str.contains(p, "Bear") or str.contains(p, "No Upper Wick") ? "bear" :
     "neutral"

ce_seqFamily(string p) =>
    str.contains(p, "Trap") ? "trap" :
     str.contains(p, "Morning Star (reversal)") or str.contains(p, "Evening Star (reversal)") or str.contains(p, "Abandoned") or str.contains(p, "Engulf") or str.contains(p, "Piercing") or str.contains(p, "Dark Cloud") or str.contains(p, "Tweezer") or str.contains(p, "Breakaway") or str.contains(p, "Hammer") or str.contains(p, "Shooting Star") or str.contains(p, "Kicker") or str.contains(p, "Meeting") or str.contains(p, "Counterattack") ? "reversal" :
     str.contains(p, "Rising Three") or str.contains(p, "Falling Three") or str.contains(p, "Mat Hold") or str.contains(p, "Tasuki") ? "continuation" :
     str.contains(p, "Inside") or str.contains(p, "Harami") ? "compression" :
     str.contains(p, "Kicker") or str.contains(p, "Marubozu") or str.contains(p, "Soldiers") or str.contains(p, "Crows") ? "momentum" :
     str.contains(p, "Doji") or str.contains(p, "Spinning") ? "indecision" :
     str.contains(p, "Counterattack") or str.contains(p, "Meeting") or str.contains(p, "Matching") ? "reaction" :
     "sequence"

ce_seqBias(string p) =>
    seq_isBullish ? "bull" :
     seq_isBearish ? "bear" :
     str.contains(p, "Bull") or str.contains(p, "Morning") or str.contains(p, "Piercing") or str.contains(p, "Rising") or str.contains(p, "Soldiers") or str.contains(p, "Bear Trap (trap)") or str.contains(p, "Matching Low (support)") ? "bull" :
     str.contains(p, "Bear") or str.contains(p, "Evening") or str.contains(p, "Dark Cloud") or str.contains(p, "Falling") or str.contains(p, "Crows") or str.contains(p, "Bull Trap (trap)") ? "bear" :
     "neutral"

ce_formatName(string base, string family, string bias) =>
    base


ce_noteFull(string bias, string family, string meaning) =>
    bias + " — " + meaning

ce_isSpecialReversal(string family, string name) =>
    family == "reversal" or family == "exhaustion" or family == "trap" or family == "liquidity" or str.contains(name, "Reversal") or str.contains(name, "Sweep") or str.contains(name, "Trap") or str.contains(name, "Exhaustion") or str.contains(name, "Weakening")

ce_isPatternReversal(string family, string name) =>
    family == "reversal" or family == "trap" or str.contains(name, "Morning Star") or str.contains(name, "Evening Star") or str.contains(name, "Engulf") or str.contains(name, "Breakaway") or str.contains(name, "Kicker") or str.contains(name, "Tweezer") or str.contains(name, "Counterattack") or str.contains(name, "Meeting")

ce_reversalNext(string source, string bias, string family, string name) =>
    str.contains(name, "Bull Exhaustion") ? "watch if the next candles fail to make higher closes." :
     str.contains(name, "Bear Exhaustion") ? "watch if the next candles fail to make lower closes." :
     str.contains(name, "Bull Weakening") ? "buyers are slowing; look for hold or failed continuation." :
     str.contains(name, "Bear Weakening") ? "sellers are slowing; look for hold or failed continuation." :
     str.contains(name, "Bull Reversal") ? "bull turn attempt; confirm with a stronger follow-up close." :
     str.contains(name, "Bear Reversal") ? "bear turn attempt; confirm with a weaker follow-up close." :
     str.contains(name, "Color Flip Bull") ? "first ha bull flip; confirm with body expansion." :
     str.contains(name, "Color Flip Bear") ? "first ha bear flip; confirm with body expansion." :
     str.contains(name, "Morning Star") ? "classic bottoming sequence; third candle must hold." :
     str.contains(name, "Evening Star") ? "classic topping sequence; third candle must hold lower." :
     str.contains(name, "Bull Trap") ? "failed high break; bearish follow-through confirms the trap." :
     str.contains(name, "Bear Trap") ? "failed low break; bullish follow-through confirms the trap." :
     str.contains(name, "Engulfing") ? "engulfing shift; next candle tests if control remains." :
     str.contains(name, "Tweezer") ? "equal level reaction; confirmation needs a directional close." :
     str.contains(name, "Kicker") ? "sharp sentiment shift; avoid chasing without location." :
     str.contains(name, "Breakaway") ? "multi-candle turn; validate with structure follow-through." :
     str.contains(name, "Sweep") ? "liquidity taken; wait for reclaim/rejection continuation." :
     bias == "neutral" ? "neutral clue; wait for a clear directional candle." :
     "reversal clue; confirm with level, close, and volume."


//=====================================================
// 🧠 PRO EDUCATIONAL NOTES — RICH VARIATION
//=====================================================

ce_qualityPro(float score) =>
    score >= 90 ? "elite" :
     score >= 80 ? "high" :
     score >= 70 ? "solid" :
     score >= 60 ? "moderate" :
     "low"

ce_qualityTextPro(float score) =>
    score >= 90 ? "very clean structure; the candle is easy to read." :
     score >= 80 ? "clean structure; the candle message is readable." :
     score >= 70 ? "valid structure; confirmation still matters." :
     score >= 60 ? "acceptable structure; avoid overconfidence." :
     "weak structure; use it mainly as a learning clue."

ce_noteFullPro(string bias, string family, string meaning, float score, string education) =>
    bias + " / " + family + " / " + ce_qualityPro(score) + " " + str.tostring(score, "#") + "% — " + meaning + " " + education

ce_candleContextPro(string bias, string family, string name, float score) =>
    string quality = ce_qualityTextPro(score)
    string bodyTxt =
         cBodyRatio >= 0.75 ? "Body dominates the range, so the close carries the message." :
         cBodyRatio <= 0.20 ? "Small body means the wick and close location matter more than direction." :
         "Body is balanced enough to read with the wicks."
    string wickTxt =
         cLowerWickRatio >= 0.55 ? "Lower wick teaches rejection of lower prices." :
         cUpperWickRatio >= 0.55 ? "Upper wick teaches rejection of higher prices." :
         cUpperWickRatio >= 0.30 and cLowerWickRatio >= 0.30 ? "Two-sided wicks teach indecision and failed control." :
         "Wicks are secondary; the body is the main read."
    string candleCase =
         str.contains(name, "Bullish Sweep") ? "Educational read: a bullish sweep is a liquidity event first, reversal only after reclaim." :
         str.contains(name, "Bearish Sweep") ? "Educational read: a bearish sweep is a liquidity event first, reversal only after rejection." :
         str.contains(name, "Bull Exhaustion") ? "Educational read: bullish exhaustion warns that buyers pushed but did not finish cleanly." :
         str.contains(name, "Bear Exhaustion") ? "Educational read: bearish exhaustion warns that sellers pushed but did not finish cleanly." :
         str.contains(name, "Bullish Rejection") ? "Educational read: bullish rejection is about the lower wick, not just the green close." :
         str.contains(name, "Bearish Rejection") ? "Educational read: bearish rejection is about the upper wick, not just the red close." :
         str.contains(name, "Bull Engulf") ? "Educational read: bullish engulfing shows a control transfer from sellers to buyers." :
         str.contains(name, "Bear Engulf") ? "Educational read: bearish engulfing shows a control transfer from buyers to sellers." :
         str.contains(name, "Hammer") ? "Educational read: hammer is bullish only when the lower rejection appears after pressure down." :
         str.contains(name, "Shooting Star") ? "Educational read: shooting star is bearish only when the upper rejection appears after pressure up." :
         str.contains(name, "Tweezer Bottom") ? "Educational read: tweezer bottom teaches repeated defense of the same low." :
         str.contains(name, "Tweezer Top") ? "Educational read: tweezer top teaches repeated defense of the same high." :
         str.contains(name, "Dragonfly") ? "Educational read: dragonfly doji shows a failed downside auction and close near the top." :
         str.contains(name, "Gravestone") ? "Educational read: gravestone doji shows a failed upside auction and close near the low." :
         str.contains(name, "Long-Legged") ? "Educational read: long-legged doji is neutral because both sides failed to keep control." :
         str.contains(name, "Doji") ? "Educational read: doji is balance, not signal; the next candle gives the lesson." :
         str.contains(name, "Inside Bar") ? "Educational read: inside bar is compression; direction is unknown until range breaks." :
         str.contains(name, "Outside Bar Bull") ? "Educational read: outside bull candle sweeps range then closes with buyer control." :
         str.contains(name, "Outside Bar Bear") ? "Educational read: outside bear candle sweeps range then closes with seller control." :
         str.contains(name, "Bull Imbalance") ? "Educational read: bullish imbalance marks a fast demand gap, not a normal candle." :
         str.contains(name, "Bear Imbalance") ? "Educational read: bearish imbalance marks a fast supply gap, not a normal candle." :
         str.contains(name, "Bullish Displacement") ? "Educational read: bullish displacement is momentum; body quality matters more than wick." :
         str.contains(name, "Bearish Displacement") ? "Educational read: bearish displacement is momentum; body quality matters more than wick." :
         str.contains(name, "Bull Marubozu") ? "Educational read: bull marubozu teaches full-session buyer dominance." :
         str.contains(name, "Bear Marubozu") ? "Educational read: bear marubozu teaches full-session seller dominance." :
         str.contains(name, "NR7") ? "Educational read: NR7 is volatility compression; it teaches patience before expansion." :
         str.contains(name, "NR4") ? "Educational read: NR4 is short compression; the lesson is not to force direction." :
         "Educational read: this candle teaches structure first, direction second."
    candleCase + " " + quality + " " + bodyTxt + " " + wickTxt

ce_haContextPro(string bias, string family, string name, float score) =>
    string quality = ce_qualityTextPro(score)
    string bodyTxt =
         ceha_bodyRatio >= ceha_strongBodyMin ? "HA body is strong, so smoothed pressure is clear." :
         ceha_bodyRatio <= ceha_smallBodyMax ? "HA body is small, so the lesson is loss of momentum." :
         "HA body is moderate, so read it with prior HA candles."
    string wickTxt =
         ceha_lowerRatio <= ceha_noWickMax and ceha_isBull ? "No lower wick teaches clean bullish HA control." :
         ceha_upperRatio <= ceha_noWickMax and ceha_isBear ? "No upper wick teaches clean bearish HA control." :
         ceha_lowerRatio >= ceha_longWickMin ? "Lower HA wick teaches downside rejection inside the smoothed candle." :
         ceha_upperRatio >= ceha_longWickMin ? "Upper HA wick teaches upside rejection inside the smoothed candle." :
         "HA wicks are not dominant, so body sequence matters most."
    string haCase =
         str.contains(name, "Bull Reversal") ? "Educational read: HA bull reversal is an early turn attempt, not proof by itself." :
         str.contains(name, "Bear Reversal") ? "Educational read: HA bear reversal is an early turn attempt, not proof by itself." :
         str.contains(name, "Color Flip Bull") ? "Educational read: bull color flip teaches first momentum shift from red to green." :
         str.contains(name, "Color Flip Bear") ? "Educational read: bear color flip teaches first momentum shift from green to red." :
         str.contains(name, "Bull Doji Reversal") ? "Educational read: bull doji reversal teaches seller fatigue before possible recovery." :
         str.contains(name, "Bear Doji Reversal") ? "Educational read: bear doji reversal teaches buyer fatigue before possible drop." :
         str.contains(name, "Bull Exhaustion") ? "Educational read: bull exhaustion teaches that green HA can still be weak." :
         str.contains(name, "Bear Exhaustion") ? "Educational read: bear exhaustion teaches that red HA can still be weak." :
         str.contains(name, "Bull Weakening") ? "Educational read: bull weakening means buyer rhythm is slowing, not automatically bearish." :
         str.contains(name, "Bear Weakening") ? "Educational read: bear weakening means seller rhythm is slowing, not automatically bullish." :
         str.contains(name, "Bull Acceleration") ? "Educational read: bull acceleration teaches increasing smoothed demand." :
         str.contains(name, "Bear Acceleration") ? "Educational read: bear acceleration teaches increasing smoothed supply." :
         str.contains(name, "Strong Bull") ? "Educational read: strong bull HA shows clean green pressure with little opposition." :
         str.contains(name, "Strong Bear") ? "Educational read: strong bear HA shows clean red pressure with little opposition." :
         str.contains(name, "Bull Continuation") ? "Educational read: bull continuation teaches repeated HA agreement upward." :
         str.contains(name, "Bear Continuation") ? "Educational read: bear continuation teaches repeated HA agreement downward." :
         str.contains(name, "Bull Pullback") ? "Educational read: bull pullback is a pause inside bull rhythm, not reversal alone." :
         str.contains(name, "Bear Pullback") ? "Educational read: bear pullback is a pause inside bear rhythm, not reversal alone." :
         str.contains(name, "No Lower Wick") ? "Educational read: no lower wick is a structure tag showing buyer control." :
         str.contains(name, "No Upper Wick") ? "Educational read: no upper wick is a structure tag showing seller control." :
         str.contains(name, "Long Body Bull") ? "Educational read: long bull HA body teaches expansion of green pressure." :
         str.contains(name, "Long Body Bear") ? "Educational read: long bear HA body teaches expansion of red pressure." :
         str.contains(name, "Doji") ? "Educational read: HA doji means smoothed indecision; wait for body expansion." :
         str.contains(name, "Small Body") ? "Educational read: small HA body means pressure is slowing." :
         "Educational read: HA is a smoothed candle, so sequence matters more than one bar."
    haCase + " " + quality + " " + bodyTxt + " " + wickTxt

ce_seqContextPro(string bias, string family, string name, float score) =>
    string quality = ce_qualityTextPro(score)
    string candleCount =
         str.contains(name, "(5)") ? "Five-candle pattern: it teaches a full sequence, so order matters." :
         str.contains(name, "(4)") ? "Four-candle pattern: it teaches transition over several bars." :
         str.contains(name, "(3)") ? "Three-candle pattern: it teaches setup, pause, and confirmation." :
         str.contains(name, "(2)") ? "Two-candle pattern: it teaches direct transfer of control." :
         "One-candle pattern: it teaches anatomy more than confirmation."
    string seqCase =
         str.contains(name, "Morning Star") ? "Educational read: morning star is bull because selling weakens, pauses, then buyers reclaim." :
         str.contains(name, "Evening Star") ? "Educational read: evening star is bear because buying weakens, pauses, then sellers reclaim." :
         str.contains(name, "Bullish Engulfing") ? "Educational read: bullish engulfing is bull when the buyer body absorbs the prior seller body." :
         str.contains(name, "Bearish Engulfing") ? "Educational read: bearish engulfing is bear when the seller body absorbs the prior buyer body." :
         str.contains(name, "Bullish Harami") ? "Educational read: bullish harami is a pause after selling, not a full reversal until breakout." :
         str.contains(name, "Bearish Harami") ? "Educational read: bearish harami is a pause after buying, not a full reversal until breakdown." :
         str.contains(name, "Piercing") ? "Educational read: piercing is bull recovery because close enters deep into the prior red body." :
         str.contains(name, "Dark Cloud") ? "Educational read: dark cloud is bear pressure because close cuts into the prior green body." :
         str.contains(name, "Tweezer Bottom") ? "Educational read: tweezer bottom is bull defense because lows repeat at the same area." :
         str.contains(name, "Tweezer Top") ? "Educational read: tweezer top is bear defense because highs repeat at the same area." :
         str.contains(name, "Bull Trap") ? "Educational read: bull trap is bearish because buyers fail after breaking higher." :
         str.contains(name, "Bear Trap") ? "Educational read: bear trap is bullish because sellers fail after breaking lower." :
         str.contains(name, "Kicker Bull") ? "Educational read: bull kicker is a sharp sentiment shift from selling to buying." :
         str.contains(name, "Kicker Bear") ? "Educational read: bear kicker is a sharp sentiment shift from buying to selling." :
         str.contains(name, "Abandoned Baby Bull") ? "Educational read: abandoned baby bull teaches emotional disconnect after a decline." :
         str.contains(name, "Abandoned Baby Bear") ? "Educational read: abandoned baby bear teaches emotional disconnect after a rally." :
         str.contains(name, "Three Inside Up") ? "Educational read: three inside up confirms a harami by closing upward." :
         str.contains(name, "Three Inside Down") ? "Educational read: three inside down confirms a harami by closing downward." :
         str.contains(name, "Three Outside Up") ? "Educational read: three outside up confirms bullish engulfing with follow-through." :
         str.contains(name, "Three Outside Down") ? "Educational read: three outside down confirms bearish engulfing with follow-through." :
         str.contains(name, "Three White Soldiers") ? "Educational read: three soldiers is bull momentum through repeated strong closes." :
         str.contains(name, "Three Black Crows") ? "Educational read: three crows is bear momentum through repeated weak closes." :
         str.contains(name, "Rising Three") ? "Educational read: rising three is bullish continuation through controlled pullback." :
         str.contains(name, "Falling Three") ? "Educational read: falling three is bearish continuation through controlled bounce." :
         str.contains(name, "Breakaway Bull") ? "Educational read: breakaway bull teaches multi-candle transition from selling to buying." :
         str.contains(name, "Breakaway Bear") ? "Educational read: breakaway bear teaches multi-candle transition from buying to selling." :
         str.contains(name, "Inside Bar Bull Break") ? "Educational read: inside bull break teaches compression resolving upward." :
         str.contains(name, "Inside Bar Bear Break") ? "Educational read: inside bear break teaches compression resolving downward." :
         str.contains(name, "Doji") ? "Educational read: doji pattern is neutral; the next candle teaches direction." :
         str.contains(name, "Hammer") ? "Educational read: hammer teaches lower rejection; bull only after proper location and follow-through." :
         str.contains(name, "Shooting Star") ? "Educational read: shooting star teaches upper rejection; bear only after proper location and follow-through." :
         "Educational read: this sequence teaches candle order, not just one isolated shape."
    string confirm =
         family == "reversal" ? "For reversal education, focus on failed control and next close." :
         family == "continuation" ? "For continuation education, focus on controlled pullback and trend resumption." :
         family == "compression" ? "For compression education, focus on range break direction." :
         family == "trap" ? "For trap education, focus on failed breakout and return inside range." :
         "For neutral education, do not force direction before confirmation."
    seqCase + " " + quality + " " + candleCount + " " + confirm
ce_candleMeaningPro(string p) =>
    str.contains(p, "Bull Imbalance") ? "unfilled demand pocket; price may react if it retests this zone." :
     str.contains(p, "Bear Imbalance") ? "unfilled supply pocket; a retest can reveal seller defense." :
     str.contains(p, "Bullish Displacement") ? "fast bullish repricing; buyers moved price with urgency." :
     str.contains(p, "Bearish Displacement") ? "fast bearish repricing; sellers moved price with urgency." :
     str.contains(p, "Bullish Sweep") ? "sell-side liquidity was taken, then price reclaimed the level." :
     str.contains(p, "Bearish Sweep") ? "buy-side liquidity was taken, then price rejected the level." :
     str.contains(p, "Bull Exhaustion") ? "buyers printed strength, but the wick warns of fading demand." :
     str.contains(p, "Bear Exhaustion") ? "sellers printed weakness, but the wick warns of fading supply." :
     str.contains(p, "Bullish Rejection") ? "downside probe failed; demand reacted before the close." :
     str.contains(p, "Bearish Rejection") ? "upside probe failed; supply reacted before the close." :
     str.contains(p, "Outside Bar Bull") ? "both sides were swept, but the final close favored buyers." :
     str.contains(p, "Outside Bar Bear") ? "both sides were swept, but the final close favored sellers." :
     str.contains(p, "Mother Bar") ? "large control candle; its high and low become decision levels." :
     str.contains(p, "NR7") ? "seven-bar volatility squeeze; expansion risk is building." :
     str.contains(p, "NR4") ? "short compression phase; market is pausing before selection." :
     str.contains(p, "Bull Wide") ? "wide bullish range; demand is stronger than recent candles." :
     str.contains(p, "Bear Wide") ? "wide bearish range; supply is stronger than recent candles." :
     str.contains(p, "Dragonfly") ? "lower prices were rejected; buyers recovered most of the candle." :
     str.contains(p, "Gravestone") ? "higher prices were rejected; sellers erased the upward probe." :
     str.contains(p, "Long-Legged") ? "wide two-sided auction; neither side kept clean control." :
     str.contains(p, "Doji") ? "open and close nearly match; confirmation matters more than the candle." :
     str.contains(p, "Bull Marubozu") ? "buyers controlled the candle from open toward close." :
     str.contains(p, "Bear Marubozu") ? "sellers controlled the candle from open toward close." :
     str.contains(p, "Bull Engulf") ? "buyers absorbed the prior body and flipped short-term control." :
     str.contains(p, "Bear Engulf") ? "sellers absorbed the prior body and flipped short-term control." :
     str.contains(p, "Inside Bar") ? "range contracts inside the prior candle; breakout decides direction." :
     str.contains(p, "Hammer") ? "sellers pushed down but could not hold lows into the close." :
     str.contains(p, "Shooting Star") ? "buyers pushed up but could not hold highs into the close." :
     str.contains(p, "Tweezer Top") ? "same-zone highs show repeated supply defense." :
     str.contains(p, "Tweezer Bottom") ? "same-zone lows show repeated demand defense." :
     str.contains(p, "Bull Candle") ? "simple bullish close; useful only with trend and location." :
     str.contains(p, "Bear Candle") ? "simple bearish close; useful only with trend and location." :
     "mixed candle; read the wick, body, volume, and location together."

ce_haMeaningPro(string p) =>
    str.contains(p, "Bull Exhaustion") and str.contains(p, "color flip bull") ? "bull flip appears, but exhaustion warns demand may be late." :
     str.contains(p, "Bear Exhaustion") and str.contains(p, "color flip bear") ? "bear flip appears, but exhaustion warns supply may be late." :
     str.contains(p, "Bull Exhaustion") and str.contains(p, "doji") ? "bullish HA slows into doji; buyers are losing clean rhythm." :
     str.contains(p, "Bear Exhaustion") and str.contains(p, "doji") ? "bearish HA slows into doji; sellers are losing clean rhythm." :
     str.contains(p, "Bull Exhaustion") and str.contains(p, "small body") ? "buyers remain present, but expansion is clearly reduced." :
     str.contains(p, "Bear Exhaustion") and str.contains(p, "small body") ? "sellers remain present, but expansion is clearly reduced." :
     str.contains(p, "Bull Weakening") and str.contains(p, "doji") ? "bull trend is pausing; indecision replaces clean continuation." :
     str.contains(p, "Bear Weakening") and str.contains(p, "doji") ? "bear trend is pausing; indecision replaces clean continuation." :
     str.contains(p, "Bull Weakening") and str.contains(p, "small body") ? "bull pressure is still positive, but momentum is shrinking." :
     str.contains(p, "Bear Weakening") and str.contains(p, "small body") ? "bear pressure is still negative, but momentum is shrinking." :
     str.contains(p, "Bull Reversal") ? "HA attempts a bullish turn; confirmation needs a stronger follow-up body." :
     str.contains(p, "Bear Reversal") ? "HA attempts a bearish turn; confirmation needs a weaker follow-up body." :
     str.contains(p, "Color Flip Bull") ? "first HA green shift after red pressure; early, not confirmed alone." :
     str.contains(p, "Color Flip Bear") ? "first HA red shift after green pressure; early, not confirmed alone." :
     str.contains(p, "Bull Doji Reversal") ? "doji after a decline can mark seller fatigue before a turn." :
     str.contains(p, "Bear Doji Reversal") ? "doji after a rally can mark buyer fatigue before a turn." :
     str.contains(p, "Bull Exhaustion") ? "bullish HA is losing extension; watch for failed continuation." :
     str.contains(p, "Bear Exhaustion") ? "bearish HA is losing extension; watch for failed continuation." :
     str.contains(p, "Bull Weakening") ? "green HA remains, but the body no longer shows clean pressure." :
     str.contains(p, "Bear Weakening") ? "red HA remains, but the body no longer shows clean pressure." :
     str.contains(p, "Bull Acceleration") ? "HA body expands upward; trend pressure is increasing." :
     str.contains(p, "Bear Acceleration") ? "HA body expands downward; downside pressure is increasing." :
     str.contains(p, "Strong Bull") ? "clean bullish HA structure; buyers control the smoothed candle." :
     str.contains(p, "Strong Bear") ? "clean bearish HA structure; sellers control the smoothed candle." :
     str.contains(p, "Bull Continuation") ? "successive HA strength supports ongoing bullish follow-through." :
     str.contains(p, "Bear Continuation") ? "successive HA weakness supports ongoing bearish follow-through." :
     str.contains(p, "No Lower Wick") ? "HA did not meaningfully reject lower; buyers dominated the bar." :
     str.contains(p, "No Upper Wick") ? "HA did not meaningfully reject higher; sellers dominated the bar." :
     str.contains(p, "Long Body Bull") ? "large bullish HA body; directional conviction is visible." :
     str.contains(p, "Long Body Bear") ? "large bearish HA body; directional conviction is visible." :
     str.contains(p, "Bull Pullback") ? "controlled bearish pause inside a bullish HA environment." :
     str.contains(p, "Bear Pullback") ? "controlled bullish pause inside a bearish HA environment." :
     str.contains(p, "Weak Bull") ? "green HA close with limited conviction; avoid reading it as strength." :
     str.contains(p, "Weak Bear") ? "red HA close with limited conviction; avoid reading it as strength." :
     str.contains(p, "Doji") ? "smoothed indecision; wait for body expansion or color follow-through." :
     str.contains(p, "Small Body") ? "reduced HA pressure; momentum is quieter than usual." :
     str.contains(p, "Bull Candle") ? "basic green HA state; context decides if it matters." :
     str.contains(p, "Bear Candle") ? "basic red HA state; context decides if it matters." :
     "HA condition is mixed; compare it with trend, wick quality, and sequence."

ce_seqMeaningPro(string p) =>
    str.contains(p, "Rising Three") ? "bull continuation: pullback candles stay contained before demand resumes." :
     str.contains(p, "Falling Three") ? "bear continuation: bounce candles stay contained before supply resumes." :
     str.contains(p, "Mat Hold") ? "bull continuation: trend holds high while weak counter candles fail." :
     str.contains(p, "Breakaway Bull") ? "bull reversal: a multi-candle transition breaks bearish control." :
     str.contains(p, "Breakaway Bear") ? "bear reversal: a multi-candle transition breaks bullish control." :
     str.contains(p, "Bull Three-Line Strike") ? "bull reversal: one strong candle negates a bearish sequence." :
     str.contains(p, "Bear Three-Line Strike") ? "bear reversal: one strong candle negates a bullish sequence." :
     str.contains(p, "Concealing Baby") ? "bear continuation: buyers are absorbed under persistent supply." :
     str.contains(p, "Abandoned Baby Bull") ? "bull reversal: isolation doji signals sellers lost continuity." :
     str.contains(p, "Abandoned Baby Bear") ? "bear reversal: isolation doji signals buyers lost continuity." :
     str.contains(p, "Tasuki Gap Bull") ? "bull continuation: gap support holds through a partial pullback." :
     str.contains(p, "Tasuki Gap Bear") ? "bear continuation: gap resistance holds through a partial bounce." :
     str.contains(p, "Inside Bar Bull Break") ? "bull breakout: compression resolves above the mother-bar range." :
     str.contains(p, "Inside Bar Bear Break") ? "bear breakout: compression resolves below the mother-bar range." :
     str.contains(p, "Three White Soldiers") ? "bull momentum: three firm closes show persistent demand." :
     str.contains(p, "Three Black Crows") ? "bear momentum: three firm sell candles show persistent supply." :
     str.contains(p, "Morning Star") ? "bull reversal: decline, pause, then buyer reclaim structure." :
     str.contains(p, "Evening Star") ? "bear reversal: rally, pause, then seller reclaim structure." :
     str.contains(p, "Three Inside Up") ? "bull confirmation: harami pause resolves with upward follow-through." :
     str.contains(p, "Three Inside Down") ? "bear confirmation: harami pause resolves with downward follow-through." :
     str.contains(p, "Three Outside Up") ? "bull confirmation: engulfing receives immediate continuation." :
     str.contains(p, "Three Outside Down") ? "bear confirmation: engulfing receives immediate continuation." :
     str.contains(p, "Bull Trap") ? "bear reversal: failed upside breakout leaves buyers trapped." :
     str.contains(p, "Bear Trap") ? "bull reversal: failed downside breakout leaves sellers trapped." :
     str.contains(p, "Kicker Bull") ? "bull reversal: abrupt sentiment gap from sell pressure to buy pressure." :
     str.contains(p, "Kicker Bear") ? "bear reversal: abrupt sentiment gap from buy pressure to sell pressure." :
     str.contains(p, "Matching Low") ? "bull support clue: sellers fail to push beyond the prior low close." :
     str.contains(p, "Meeting Lines Bull") ? "bull reversal: bearish advance meets an equal-opposite bullish close." :
     str.contains(p, "Meeting Lines Bear") ? "bear reversal: bullish advance meets an equal-opposite bearish close." :
     str.contains(p, "Counterattack Bull") ? "bull reversal: buyers answer the prior sell candle at the same zone." :
     str.contains(p, "Counterattack Bear") ? "bear reversal: sellers answer the prior buy candle at the same zone." :
     str.contains(p, "Bullish Engulfing") ? "bull reversal: buyer body absorbs and overpowers prior selling." :
     str.contains(p, "Bearish Engulfing") ? "bear reversal: seller body absorbs and overpowers prior buying." :
     str.contains(p, "Piercing") ? "bull reversal: close recovers deep into the prior bearish body." :
     str.contains(p, "Dark Cloud") ? "bear reversal: close cuts deep into the prior bullish body." :
     str.contains(p, "Bullish Harami") ? "bull pause: smaller body forms inside prior sell pressure." :
     str.contains(p, "Bearish Harami") ? "bear pause: smaller body forms inside prior buy pressure." :
     str.contains(p, "Tweezer Bottom") ? "bull reversal: repeated low shows demand defending a level." :
     str.contains(p, "Tweezer Top") ? "bear reversal: repeated high shows supply defending a level." :
     str.contains(p, "Hammer") ? "bull reversal: lower rejection shows sellers lost control of lows." :
     str.contains(p, "Inverted Hammer") ? "bull watch: upside probe must get follow-through to confirm." :
     str.contains(p, "Shooting Star") ? "bear reversal: upper rejection shows buyers lost control of highs." :
     str.contains(p, "Hanging Man") ? "bear warning: lower wick after a rise shows demand instability." :
     str.contains(p, "Bull Marubozu") ? "bull momentum: single candle closes with strong buyer control." :
     str.contains(p, "Bear Marubozu") ? "bear momentum: single candle closes with strong seller control." :
     str.contains(p, "Spinning Top") ? "neutral: both sides traded, but neither kept control." :
     str.contains(p, "Doji") ? "neutral: balance candle; next close gives the useful information." :
     "neutral: pattern needs location, trend, volume, and confirmation."

ce_isCandleReversalPro(string family, string name) =>
    family == "reversal" or family == "exhaustion" or family == "liquidity" or str.contains(name, "Sweep") or str.contains(name, "Rejection") or str.contains(name, "Exhaustion") or str.contains(name, "Engulf") or str.contains(name, "Hammer") or str.contains(name, "Shooting Star") or str.contains(name, "Tweezer") or str.contains(name, "Dragonfly") or str.contains(name, "Gravestone")

ce_isPatternReversalPro(string family, string name) =>
    family == "reversal" or family == "trap" or family == "pause" or family == "support" or str.contains(name, "Morning Star") or str.contains(name, "Evening Star") or str.contains(name, "Engulf") or str.contains(name, "Breakaway") or str.contains(name, "Kicker") or str.contains(name, "Tweezer") or str.contains(name, "Counterattack") or str.contains(name, "Meeting") or str.contains(name, "Three Inside") or str.contains(name, "Three Outside") or str.contains(name, "Hammer") or str.contains(name, "Shooting Star") or str.contains(name, "Hanging Man") or str.contains(name, "Piercing") or str.contains(name, "Dark Cloud") or str.contains(name, "Harami") or str.contains(name, "Trap")

ce_reversalNextPro(string source, string bias, string family, string name) =>
    str.contains(name, "Bull Exhaustion") and str.contains(name, "color flip") ? "bear warning — flip is early, but exhaustion says demand stalled." :
     str.contains(name, "Bull Exhaustion") and str.contains(name, "doji") ? "bear warning — doji after bullish HA shows hesitation at highs." :
     str.contains(name, "Bull Exhaustion") and str.contains(name, "small body") ? "bear warning — small body shows buyers losing expansion." :
     str.contains(name, "Bear Exhaustion") and str.contains(name, "color flip") ? "bull warning — flip is early, but exhaustion says supply stalled." :
     str.contains(name, "Bear Exhaustion") and str.contains(name, "doji") ? "bull warning — doji after bearish HA shows hesitation at lows." :
     str.contains(name, "Bear Exhaustion") and str.contains(name, "small body") ? "bull warning — small body shows sellers losing expansion." :
     str.contains(name, "Bull Weakening") and str.contains(name, "doji") ? "neutral/bear — uptrend pauses into indecision; watch lower close." :
     str.contains(name, "Bear Weakening") and str.contains(name, "doji") ? "neutral/bull — downtrend pauses into indecision; watch higher close." :
     str.contains(name, "Bull Weakening") ? "neutral/bear — buyers are slowing; continuation must prove itself." :
     str.contains(name, "Bear Weakening") ? "neutral/bull — sellers are slowing; breakdown must prove itself." :
     str.contains(name, "Bull Reversal") ? "bull — reversal attempt; next HA body should expand upward." :
     str.contains(name, "Bear Reversal") ? "bear — reversal attempt; next HA body should expand downward." :
     str.contains(name, "Color Flip Bull") ? "bull early — first HA flip; stronger body confirms control." :
     str.contains(name, "Color Flip Bear") ? "bear early — first HA flip; stronger body confirms control." :
     str.contains(name, "Morning Star") ? "bull reversal — base forms after selling; hold above star midpoint." :
     str.contains(name, "Evening Star") ? "bear reversal — top forms after buying; hold below star midpoint." :
     str.contains(name, "Bull Trap") ? "bear reversal — failed high break; downside close confirms trap." :
     str.contains(name, "Bear Trap") ? "bull reversal — failed low break; upside close confirms trap." :
     str.contains(name, "Bullish Engulfing") ? "bull reversal — buyers took the prior body; watch follow-through." :
     str.contains(name, "Bearish Engulfing") ? "bear reversal — sellers took the prior body; watch follow-through." :
     str.contains(name, "Piercing") ? "bull reversal — recovery into prior body; confirmation above midpoint." :
     str.contains(name, "Dark Cloud") ? "bear reversal — close cuts prior body; confirmation below midpoint." :
     str.contains(name, "Tweezer Bottom") ? "bull reversal — equal lows show defense; needs higher close." :
     str.contains(name, "Tweezer Top") ? "bear reversal — equal highs show defense; needs lower close." :
     str.contains(name, "Kicker Bull") ? "bull reversal — abrupt sentiment shift; best near support." :
     str.contains(name, "Kicker Bear") ? "bear reversal — abrupt sentiment shift; best near resistance." :
     str.contains(name, "Breakaway Bull") ? "bull reversal — multi-candle transition; structure must turn up." :
     str.contains(name, "Breakaway Bear") ? "bear reversal — multi-candle transition; structure must turn down." :
     str.contains(name, "Three Inside Up") ? "bull confirmation — harami resolves upward; avoid weak close." :
     str.contains(name, "Three Inside Down") ? "bear confirmation — harami resolves downward; avoid weak close." :
     str.contains(name, "Three Outside Up") ? "bull confirmation — engulfing follow-through strengthens shift." :
     str.contains(name, "Three Outside Down") ? "bear confirmation — engulfing follow-through strengthens shift." :
     str.contains(name, "Hammer") ? "bull reversal — lower rejection must hold on next test." :
     str.contains(name, "Inverted Hammer") ? "bull watch — upper probe needs breakout confirmation." :
     str.contains(name, "Shooting Star") ? "bear reversal — upper rejection must hold on next test." :
     str.contains(name, "Hanging Man") ? "bear warning — demand cracked after rally; wait lower close." :
     str.contains(name, "Bullish Rejection") ? "bull reversal — downside probe failed; next close should hold above wick midpoint." :
     str.contains(name, "Bearish Rejection") ? "bear reversal — upside probe failed; next close should hold below wick midpoint." :
     str.contains(name, "Bull Exhaustion") ? "bear warning — buyers failed to hold extension; look for weaker follow-through." :
     str.contains(name, "Bear Exhaustion") ? "bull warning — sellers failed to hold extension; look for stronger recovery." :
     str.contains(name, "Dragonfly") ? "bull reversal — lower rejection dominates; support reaction needs continuation." :
     str.contains(name, "Gravestone") ? "bear reversal — upper rejection dominates; resistance reaction needs continuation." :
     str.contains(name, "Bull Engulf") ? "bull reversal — buyer body absorbed prior sell pressure; watch next close." :
     str.contains(name, "Bear Engulf") ? "bear reversal — seller body absorbed prior buy pressure; watch next close." :
     str.contains(name, "Bullish Sweep") ? "bull / liquidity — sell-side was raided; best quality if price holds above the swept low." :
     str.contains(name, "Bearish Sweep") ? "bear / liquidity — buy-side was raided; best quality if price holds below the swept high." :
     str.contains(name, "Bullish Rejection") ? "bull / reversal — lower wick is the invalidation zone; stronger if next close expands upward." :
     str.contains(name, "Bearish Rejection") ? "bear / reversal — upper wick is the invalidation zone; stronger if next close expands downward." :
     str.contains(name, "Dragonfly") ? "bull / reversal — rejection is clear, but quality improves only with a higher follow-up close." :
     str.contains(name, "Gravestone") ? "bear / reversal — rejection is clear, but quality improves only with a lower follow-up close." :
     str.contains(name, "Sweep") ? bias + " — liquidity was taken; confirm with reclaim or rejection." :
     bias == "neutral" ? "neutral — clue is incomplete; wait for directional confirmation." :
     bias + " — reversal clue; confirm with level, close, and volume."

ce_histPush(array<string> names, array<string> notes, array<string> scores, string n, string d, string sc, int limit) =>
    array.unshift(names, n)
    array.unshift(notes, d)
    array.unshift(scores, sc)
    while array.size(names) > limit
        array.pop(names)
        array.pop(notes)
        array.pop(scores)

var string[] ce_histCNames = array.new_string()
var string[] ce_histCNotes = array.new_string()
var string[] ce_histCScores = array.new_string()

var string[] ce_histCRevNames = array.new_string()
var string[] ce_histCRevNotes = array.new_string()
var string[] ce_histCRevScores = array.new_string()

var label[] ce_candleRevChartLabels = array.new_label()
var label[] ceha_revChartLabels = array.new_label()
var label[] seq_revChartLabels = array.new_label()

var string[] ce_histHANames = array.new_string()
var string[] ce_histHANotes = array.new_string()
var string[] ce_histHAScores = array.new_string()

var string[] ce_histSeqNames = array.new_string()
var string[] ce_histSeqNotes = array.new_string()
var string[] ce_histSeqScores = array.new_string()

var string[] ce_histRevNames = array.new_string()
var string[] ce_histRevNotes = array.new_string()
var string[] ce_histRevScores = array.new_string()

var string[] ce_histPatRevNames = array.new_string()
var string[] ce_histPatRevNotes = array.new_string()
var string[] ce_histPatRevScores = array.new_string()

ce_candleRevEvent = ce_candleRev_enable and ce_isCandleReversalPro(ce_candleFamily(cPattern), cPattern)
ce_histCEvent = (enableCandleEnginePro and ce_showCurrentCandle) or ce_candleRevEvent
ceha_rev_any =
     ceha_rev_enable and (
         (ceha_showBullReversal and ceha_bullReversal) or
         (ceha_showBearReversal and ceha_bearReversal) or
         (ceha_showColorFlipBull and ceha_colorFlipBull) or
         (ceha_showColorFlipBear and ceha_colorFlipBear) or
         (ceha_showBullDojiRev and ceha_bullDojiReversal) or
         (ceha_showBearDojiRev and ceha_bearDojiReversal) or
         (ceha_showBullExhaustion and ceha_bullExhaustion) or
         (ceha_showBearExhaustion and ceha_bearExhaustion) or
         (ceha_showBullWeakening and ceha_bullWeakening) or
         (ceha_showBearWeakening and ceha_bearWeakening)
     )
ce_histHAEvent = (ceha_enable and ceha_text != "") or ceha_rev_any
ce_histSeqEvent = seq_valid

if ce_histCEvent
    string cBase = ce_cleanName(cPattern)
    string cFam = ce_candleFamily(cPattern)
    string cBias = ce_candleBias(cPattern)
    string cName = ce_formatName(cBase, cFam, cBias)
    string cNote = ce_noteFullPro(cBias, cFam, ce_candleMeaningPro(cBase), cStrengthScore, ce_candleContextPro(cBias, cFam, cBase, cStrengthScore))
    string cScore = str.tostring(cStrengthScore, "#") + "%"

    if enableCandleEnginePro and ce_showCurrentCandle
        ce_histPush(ce_histCNames, ce_histCNotes, ce_histCScores, cName, cNote, cScore, ce_maxCandleLabels)

    if ce_candleRevEvent
        ce_histPush(ce_histCRevNames, ce_histCRevNotes, ce_histCRevScores, "candle: " + cName, ce_reversalNextPro("candle", cBias, cFam, cBase), cScore, ce_candleRevMaxRows)
        if ce_candleRev_showLabels
            label ceRevLb = label.new(
                bar_index,
                cBias == "bull" ? low : high,
                "REV " + (cBias == "bull" ? "🟢 " : cBias == "bear" ? "🔴 " : "⚪ ") + cBase,
                style=cBias == "bull" ? label.style_label_up : label.style_label_down,
                textcolor=color.white,
                color=color.new(cBias == "bull" ? color.lime : cBias == "bear" ? color.red : color.gray, 65),
                size=size.tiny
            )
            array.unshift(ce_candleRevChartLabels, ceRevLb)

while array.size(ce_candleRevChartLabels) > ce_candleRevMaxRows
    label oldCeRevChart = array.pop(ce_candleRevChartLabels)
    if not na(oldCeRevChart)
        label.delete(oldCeRevChart)

if not ce_candleRev_enable or not ce_candleRev_showLabels
    while array.size(ce_candleRevChartLabels) > 0
        label oldCeRevChart = array.pop(ce_candleRevChartLabels)
        if not na(oldCeRevChart)
            label.delete(oldCeRevChart)

if ce_histHAEvent
    string haMain = ce_haPrimaryName()
    string haFam = ce_haFamily(haMain)
    string haBias = ce_haBiasFromName(haMain)
    bool haIsReversal = ceha_rev_any and ce_isSpecialReversal(haFam, haMain)
    bool haShowTags = haIsReversal ? ce_panelHARevTags : ce_panelHATags
    string haTags = haShowTags ? ce_haTags(haMain) : ""
    string haBaseDisplay = haTags == "" ? haMain : haMain + " | " + haTags
    string haName = ce_formatName(haBaseDisplay, haFam, haBias)
    string haNote = ce_noteFullPro(haBias, haFam, ce_haMeaningPro(haBaseDisplay), ceha_candleScore, ce_haContextPro(haBias, haFam, haBaseDisplay, ceha_candleScore))
    string haScore = str.tostring(ceha_candleScore, "#") + "%"
    if ceha_enable and not haIsReversal
        ce_histPush(ce_histHANames, ce_histHANotes, ce_histHAScores, haName, haNote, haScore, ceha_maxLabels)
    if haIsReversal
        ce_histPush(ce_histRevNames, ce_histRevNotes, ce_histRevScores, "ha: " + haName, ce_reversalNextPro("ha", haBias, haFam, haBaseDisplay), haScore, ce_reversalMaxRows)
        if ceha_rev_showLabels
            label haRevLb = label.new(
                bar_index,
                haBias == "bull" ? low : high,
                "REV " + (haBias == "bull" ? "🟢 " : haBias == "bear" ? "🔴 " : "⚪ ") + haBaseDisplay,
                style=haBias == "bull" ? label.style_label_up : label.style_label_down,
                textcolor=color.white,
                color=color.new(haBias == "bull" ? color.lime : haBias == "bear" ? color.red : color.gray, 65),
                size=size.tiny
            )
            array.unshift(ceha_revChartLabels, haRevLb)

while array.size(ceha_revChartLabels) > ce_reversalMaxRows
    label oldHaRevChart = array.pop(ceha_revChartLabels)
    if not na(oldHaRevChart)
        label.delete(oldHaRevChart)

if not ceha_rev_enable or not ceha_rev_showLabels
    while array.size(ceha_revChartLabels) > 0
        label oldHaRevChart = array.pop(ceha_revChartLabels)
        if not na(oldHaRevChart)
            label.delete(oldHaRevChart)

if ce_histSeqEvent
    string sBase = ce_cleanName(seq_type)
    string sFam = ce_seqFamily(seq_type)
    string sBias = ce_seqBias(seq_type)
    string sName = ce_formatName(sBase, sFam, sBias)
    string sNote = ce_noteFullPro(sBias, sFam, ce_seqMeaningPro(sBase), seq_aiScoreFinal, ce_seqContextPro(sBias, sFam, sBase, seq_aiScoreFinal))
    string sScore = str.tostring(seq_aiScoreFinal, "#") + "%"
    ce_histPush(ce_histSeqNames, ce_histSeqNotes, ce_histSeqScores, sName, sNote, sScore, seq_maxPatternLabels)
    if ce_isPatternReversalPro(sFam, sBase)
        ce_histPush(ce_histPatRevNames, ce_histPatRevNotes, ce_histPatRevScores, "pattern: " + sName, ce_reversalNextPro("pattern", sBias, sFam, sBase), sScore, ce_patternRevMaxRows)
        if seq_rev_showLabels
            label seqRevLb = label.new(
                bar_index,
                sBias == "bull" ? low : high,
                "REV " + (sBias == "bull" ? "🟢 " : sBias == "bear" ? "🔴 " : "⚪ ") + sBase,
                style=sBias == "bull" ? label.style_label_up : label.style_label_down,
                textcolor=color.white,
                color=color.new(sBias == "bull" ? color.lime : sBias == "bear" ? color.red : color.gray, 65),
                size=size.tiny
            )
            array.unshift(seq_revChartLabels, seqRevLb)

while array.size(seq_revChartLabels) > ce_patternRevMaxRows
    label oldSeqRevChart = array.pop(seq_revChartLabels)
    if not na(oldSeqRevChart)
        label.delete(oldSeqRevChart)

if not seq_rev_showLabels
    while array.size(seq_revChartLabels) > 0
        label oldSeqRevChart = array.pop(seq_revChartLabels)
        if not na(oldSeqRevChart)
            label.delete(oldSeqRevChart)

ce_drawHistoryTable(table t, string title, array<string> names, array<string> notes, array<string> scores, int maxRows, bool enabled) =>
    table.clear(t, 0, 0, 3, 50)
    if enabled
        sz = ce_histPanelSize(ce_panelTextSize)
        table.cell(t, 0, 0, title, text_color=ce_panelText, text_size=sz, bgcolor=color.new(ce_panelHeaderBg, 0))
        table.cell(t, 1, 0, "last " + str.tostring(maxRows), text_color=ce_panelText, text_size=sz, bgcolor=color.new(ce_panelHeaderBg, 0))
        table.cell(t, 2, 0, "score", text_color=ce_panelText, text_size=sz, bgcolor=color.new(ce_panelHeaderBg, 0))
        table.cell(t, 3, 0, "quick meaning", text_color=ce_panelText, text_size=sz, bgcolor=color.new(ce_panelHeaderBg, 0))

        table.cell(t, 0, 1, "#", text_color=ce_panelMuted, text_size=sz)
        table.cell(t, 1, 1, "name", text_color=ce_panelMuted, text_size=sz)
        table.cell(t, 2, 1, "%", text_color=ce_panelMuted, text_size=sz)
        table.cell(t, 3, 1, "education note", text_color=ce_panelMuted, text_size=sz)

        rows = math.min(maxRows, array.size(names))
        if rows > 0
            for i = 0 to rows - 1
                row = i + 2
                table.cell(t, 0, row, str.tostring(i + 1), text_color=ce_panelMuted, text_size=sz)
                table.cell(t, 1, row, array.get(names, i), text_color=ce_panelText, text_size=sz)
                table.cell(t, 2, row, array.get(scores, i), text_color=ce_panelText, text_size=sz)
                table.cell(t, 3, row, array.get(notes, i), text_color=ce_panelText, text_size=sz)

var table ce_panelTableCandle = table.new(position.top_left, 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
var table ce_panelTableCandleRev = table.new(position.middle_right, 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
var table ce_panelTableHA = table.new(position.middle_left, 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
var table ce_panelTableSeq = table.new(position.bottom_left, 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
var table ce_panelTableRev = table.new(position.top_right, 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
var table ce_panelTablePatRev = table.new(position.bottom_right, 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)

if barstate.islast
    table.delete(ce_panelTableCandle)
    table.delete(ce_panelTableCandleRev)
    table.delete(ce_panelTableHA)
    table.delete(ce_panelTableSeq)
    table.delete(ce_panelTableRev)
    table.delete(ce_panelTablePatRev)

    ce_panelTableCandle := table.new(ce_histPanelPos(ce_panelCandlePos), 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
    ce_panelTableCandleRev := table.new(ce_histPanelPos(ce_panelCandleRevPos), 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
    ce_panelTableHA := table.new(ce_histPanelPos(ce_panelHAPos), 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
    ce_panelTableSeq := table.new(ce_histPanelPos(ce_panelSeqPos), 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
    ce_panelTableRev := table.new(ce_histPanelPos(ce_panelReversalPos), 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)
    ce_panelTablePatRev := table.new(ce_histPanelPos(ce_panelPatternRevPos), 4, 51, bgcolor=color.new(ce_panelBg, ce_panelBgTransp), frame_color=color.new(ce_panelBorder, 25), frame_width=1)

    ce_drawHistoryTable(ce_panelTableCandle, "candle history", ce_histCNames, ce_histCNotes, ce_histCScores, ce_maxCandleLabels, ce_panelMaster and ce_panelCandle)
    ce_drawHistoryTable(ce_panelTableCandleRev, "reversal candle", ce_histCRevNames, ce_histCRevNotes, ce_histCRevScores, ce_candleRevMaxRows, ce_panelMaster and ce_panelCandleRev)
    ce_drawHistoryTable(ce_panelTableHA, "heikin ashi history", ce_histHANames, ce_histHANotes, ce_histHAScores, ceha_maxLabels, ce_panelMaster and ce_panelHA)
    ce_drawHistoryTable(ce_panelTableSeq, "pattern history", ce_histSeqNames, ce_histSeqNotes, ce_histSeqScores, seq_maxPatternLabels, ce_panelMaster and ce_panelSeq)
    ce_drawHistoryTable(ce_panelTableRev, "reversal ha", ce_histRevNames, ce_histRevNotes, ce_histRevScores, ce_reversalMaxRows, ce_panelMaster and ce_panelReversal)
    ce_drawHistoryTable(ce_panelTablePatRev, "pattern reversal", ce_histPatRevNames, ce_histPatRevNotes, ce_histPatRevScores, ce_patternRevMaxRows, ce_panelMaster and ce_panelPatternRev)

//=====================================================
// 🔔 ALERTS — Signal Bus
//=====================================================

group_CEAlerts = "🔔 Alerts"

ce_alertEnable        = input.bool(true, "Enable Alerts", group=group_CEAlerts, tooltip="Turns this module on or off.")
ce_alertConfirmedOnly = input.bool(true, "Confirmed Close Only", group=group_CEAlerts, tooltip="Controls this setting for display, filtering, or educational detection.")
ce_runtimeAlerts      = input.bool(false, "Use alert() Dynamic Messages", group=group_CEAlerts, tooltip="Controls alert activation and alert behavior.")

ce_alertEngine        = input.bool(true, "Candle Engine Alerts", group=group_CEAlerts, tooltip="Controls alert activation and alert behavior.")
ce_alertEngineAny     = input.bool(true, "Candle Engine Any Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertEngineBull    = input.bool(true, "Candle Engine Bull Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertEngineBear    = input.bool(true, "Candle Engine Bear Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertEngineMin     = input.float(0.0, "Candle Engine Min Score", minval=0.0, maxval=100.0, step=1.0, group=group_CEAlerts, tooltip="Sets the minimum quality score required for validation.")

ce_alertHA            = input.bool(true, "Heikin Ashi Alerts", group=group_CEAlerts, tooltip="Controls alert activation and alert behavior.")
ce_alertHAAny         = input.bool(true, "HA Any Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertHABull        = input.bool(true, "HA Bull Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertHABear        = input.bool(true, "HA Bear Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertHAMin         = input.float(0.0, "HA Min Score", minval=0.0, maxval=100.0, step=1.0, group=group_CEAlerts, tooltip="Sets the minimum quality score required for validation.")

ce_alertSeq           = input.bool(true, "Sequence Alerts", group=group_CEAlerts, tooltip="Controls alert activation and alert behavior.")
ce_alertSeqAny        = input.bool(true, "Sequence Any Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertSeqBull       = input.bool(true, "Sequence Bull Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertSeqBear       = input.bool(true, "Sequence Bear Pattern", group=group_CEAlerts, tooltip="Enables or filters this candle or pattern type.")
ce_alertSeqMin        = input.float(0.0, "Sequence Min Score", minval=0.0, maxval=100.0, step=1.0, group=group_CEAlerts, tooltip="Sets the minimum quality score required for validation.")

ce_alertGlobal        = input.bool(true, "Global Alerts", group=group_CEAlerts, tooltip="Controls alert activation and alert behavior.")

ce_alertBarOk = not ce_alertConfirmedOnly or barstate.isconfirmed

// Candle Engine alert state.
ce_alertEngineEvent = ce_alertEnable and ce_alertEngine and enableCandleEnginePro and ce_showCurrentCandle and cStrengthScore >= ce_alertEngineMin and ce_alertBarOk
ce_alertEngineBullState = ce_alertEngineEvent and cIsBull
ce_alertEngineBearState = ce_alertEngineEvent and cIsBear

// Heikin Ashi alert state.
ce_alertHAEvent = ce_alertEnable and ce_alertHA and ceha_enable and ceha_text != "" and ceha_candleScore >= ce_alertHAMin and ce_alertBarOk
ce_alertHABullState = ce_alertHAEvent and ceha_bias > 0
ce_alertHABearState = ce_alertHAEvent and ceha_bias < 0

// Sequence Engine alert state.
ce_alertSeqEvent = ce_alertEnable and ce_alertSeq and seq_valid and seq_aiScoreFinal >= ce_alertSeqMin and ce_alertBarOk
ce_alertSeqBullState = ce_alertSeqEvent and seq_isBullish
ce_alertSeqBearState = ce_alertSeqEvent and seq_isBearish

ce_alertAnyBull = (ce_alertEngineBull and ce_alertEngineBullState) or (ce_alertHABull and ce_alertHABullState) or (ce_alertSeqBull and ce_alertSeqBullState)
ce_alertAnyBear = (ce_alertEngineBear and ce_alertEngineBearState) or (ce_alertHABear and ce_alertHABearState) or (ce_alertSeqBear and ce_alertSeqBearState)
ce_alertAny = (ce_alertEngineAny and ce_alertEngineEvent) or (ce_alertHAAny and ce_alertHAEvent) or (ce_alertSeqAny and ce_alertSeqEvent)

// Static TradingView alerts.
alertcondition(ce_alertEnable and ce_alertGlobal and ce_alertAny, "Any Signal", "Signal detected.")
alertcondition(ce_alertEnable and ce_alertGlobal and ce_alertAnyBull, "Bull Signal", "Bullish signal detected.")
alertcondition(ce_alertEnable and ce_alertGlobal and ce_alertAnyBear, "Bear Signal", "Bearish signal detected.")

alertcondition(ce_alertEngineAny and ce_alertEngineEvent, "Candle Engine — Any Pattern", "Candle Engine: pattern detected.")
alertcondition(ce_alertEngineBull and ce_alertEngineBullState, "Candle Engine — Bull Pattern", "Candle Engine: bullish pattern detected.")
alertcondition(ce_alertEngineBear and ce_alertEngineBearState, "Candle Engine — Bear Pattern", "Candle Engine: bearish pattern detected.")

alertcondition(ce_alertHAAny and ce_alertHAEvent, "HA Candle — Any Pattern", "Heikin Ashi Candle: pattern detected.")
alertcondition(ce_alertHABull and ce_alertHABullState, "HA Candle — Bull Pattern", "Heikin Ashi Candle: bullish pattern detected.")
alertcondition(ce_alertHABear and ce_alertHABearState, "HA Candle — Bear Pattern", "Heikin Ashi Candle: bearish pattern detected.")

alertcondition(ce_alertSeqAny and ce_alertSeqEvent, "Sequence Engine — Any Pattern", "Candle Sequence Engine: pattern detected.")
alertcondition(ce_alertSeqBull and ce_alertSeqBullState, "Sequence Engine — Bull Pattern", "Candle Sequence Engine: bullish pattern detected.")
alertcondition(ce_alertSeqBear and ce_alertSeqBearState, "Sequence Engine — Bear Pattern", "Candle Sequence Engine: bearish pattern detected.")

// Optional dynamic runtime alerts.
// Use TradingView alert type: "Any alert() function call".
if ce_runtimeAlerts and ce_alertEngineEvent
    alert("CANDLE ENGINE // " + cPattern + " // Score " + str.tostring(cStrengthScore, "#.##") + "% // " + syminfo.ticker + " // " + timeframe.period, alert.freq_once_per_bar_close)

if ce_runtimeAlerts and ce_alertHAEvent
    alert("HA CANDLE // " + ceha_candlePattern + " // Score " + str.tostring(ceha_candleScore, "#.##") + "% // " + syminfo.ticker + " // " + timeframe.period, alert.freq_once_per_bar_close)

if ce_runtimeAlerts and ce_alertSeqEvent
    alert("SEQUENCE ENGINE // " + seq_type + " // Score " + str.tostring(seq_aiScoreFinal, "#.##") + "% // " + syminfo.ticker + " // " + timeframe.period, alert.freq_once_per_bar_close)
````
