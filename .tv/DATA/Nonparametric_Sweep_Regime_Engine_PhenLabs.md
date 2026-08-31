<!-- tradingview-pine-id: PUB;dd4c0b79bc2644d28f0b9c896f87dae5 -->
<!-- tradingviewscripts-format: 1 -->
# Nonparametric Sweep Regime Engine [PhenLabs]

Source: https://www.tradingview.com/script/LxtxbBY5-Nonparametric-Sweep-Regime-Engine-PhenLabs/

## Description

📊 Nonparametric Sweep Regime Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
The Nonparametric Sweep Regime Engine identifies confirmed raids of buy-side and sell-side liquidity, then asks a more important question: was the event statistically unusual for this market right now?

Instead of relying on fixed volume or wick thresholds, NSRE ranks participation, wick extremity, reclaim quality, and trend expansion against their own rolling distributions. Only sweeps that pass the score, volume, candle, and regime gates produce a signal.

Each confirmed setup includes a compact live dashboard, a buffered invalidation level, and two risk-normalized target projections. This keeps the chart interpretation simple while the underlying thresholds adapt across symbols and timeframes.

🚀 Points of Innovation

[*]Nonparametric percentile ranks replace brittle fixed volume and wick thresholds
[*]Liquidity sweeps are scored by participation, wick extremity, and closing reclaim
[*]A trend-expansion gate avoids fading statistically extreme directional conditions
[*]Confirmed pivots create objective buy-side and sell-side liquidity references
[*]Targets adapt to setup risk and use opposing liquidity when it offers a valid objective
[*]A single 0–100 score compresses multiple confirmation layers into a readable decision aid

🔧 Core Components

[*]Liquidity Pivot Engine: confirms swing highs and lows, extends active liquidity levels, and retires them after a raid
[*]Percentile Rank Engine: ranks volume, directional wick size, and EMA-spread expansion over a rolling sample
[*]Sweep Confirmation Gate: requires a close back through the raided level plus configurable score, volume, candle, and regime conditions
[*]Projection Engine: places an ATR-buffered stop and two risk-multiple targets, substituting opposing liquidity for the extended target when appropriate
[*]NSRE Dashboard: displays the latest direction, score, volume rank, trend rank, regime, stop, and targets

🔥 Key Features

[*]Adaptive thresholds make the same logic portable across futures, crypto, FX, equities, and indices
[*]One-use liquidity states prevent repeated signals from the same pivot
[*]Confirmed pivots avoid lookahead in live signal logic
[*]Dashed liquidity and invalidation levels keep structure distinct from dotted target projections
[*]Independent bullish and bearish alert conditions support automation workflows
[*]All calculations use robust NA and zero-division guards

🎨 Visualization

[*]Teal triangle: confirmed bullish sell-side liquidity sweep
[*]Magenta triangle: confirmed bearish buy-side liquidity sweep
[*]Dashed horizontal levels: active liquidity, swept reference, and invalidation
[*]Dotted horizontal levels: first and second projected objectives
[*]Top-right dashboard: latest signal state, percentile context, regime, and exact projected prices

📖 Usage Guidelines

[*]Pivot strength — Default: 5 — Range: 2–20 — Lower values react faster and create more liquidity references; higher values isolate more significant structure
[*]ATR length — Default: 14 — Range: 5–100 — Controls volatility normalization and the stop buffer baseline
[*]Require directional reclaim candle — Default: true — Requires the sweep bar to close in the intended reversal direction
[*]Percentile lookback — Default: 100 — Range: 30–500 — Shorter samples adapt faster; longer samples produce more stable ranks
[*]Minimum sweep score — Default: 65 — Range: 50–95 — Raise for fewer, more selective signals
[*]Minimum volume percentile — Default: 55 — Range: 0–100 — Sets the minimum relative participation required
[*]Maximum trend-expansion percentile — Default: 85 — Range: 40–100 — Lower values reject more countertrend sweeps during expansion
[*]Fast EMA — Default: 21 — Range: 2–100 — First component of the normalized trend-expansion metric
[*]Slow EMA — Default: 55 — Range: 5–250 — Second component of the normalized trend-expansion metric
[*]Stop ATR buffer — Default: 0.15 — Range: 0–2 — Adds volatility-adjusted space beyond the sweep extreme
[*]Target 1 risk multiple — Default: 1.0 — Range: 0.5–5 — Controls the first objective relative to setup risk
[*]Target 2 risk multiple — Default: 2.0 — Range: 1–10 — Controls the fallback extended objective
[*]Projection length — Default: 40 — Range: 10–200 — Sets how far the latest stop and targets extend

✅ Best Use Cases

[*]Intraday reversal setups around established swing liquidity
[*]Filtering ICT and SMC sweep concepts with adaptive statistical context
[*]Comparing signal quality across instruments with different volume and volatility scales
[*]Locating risk-defined entries after stop runs in futures, indices, crypto, and FX

⚠️ Limitations

[*]Pivot levels require right-side confirmation and therefore appear after the structural turning point
[*]Percentile ranks need the selected lookback to warm up before signals can qualify
[*]Volume quality depends on the data supplied for the selected market
[*]Projected targets are analytical references and do not model slippage, commissions, or order execution

💡 What Makes This Unique

[*]Distribution-aware confirmation: every sweep is judged relative to recent market behavior rather than universal constants
[*]Regime-sensitive rejection: extreme trend expansion can invalidate an otherwise attractive countertrend sweep
[*]Liquidity-aware targeting: the extended objective can snap to opposing confirmed liquidity when that level is structurally valid

🔬 How It Works

[*]Confirmed swing highs and lows become active buy-side and sell-side liquidity references
[*]Price must raid an active level and close back through it to form a raw sweep
[*]The engine percentile-ranks volume, directional wick size, and trend expansion over the rolling sample
[*]Volume, wick, and reclaim inputs produce a composite 0–100 sweep score
[*]The score, participation, directional candle, and regime gates must all pass on the sweep bar
[*]A valid signal projects an ATR-buffered invalidation level and two risk-normalized objectives

💡 Note:
Start with the default settings, then adjust the percentile lookback and minimum score to the instrument’s tempo. Higher-timeframe liquidity can improve context when using NSRE on lower execution timeframes. This tool is an analytical aid, not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Nonparametric Sweep Regime Engine [PhenLabs]", shorttitle="NSRE", overlay=true, max_lines_count=100, max_labels_count=50)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_DETECTION = "Detection"
string GROUP_RANKING = "Nonparametric Ranking"
string GROUP_RISK = "Projection & Risk"
string GROUP_VISUALS = "Visuals"

int swingLength = input.int(5, "Pivot strength", minval=2, maxval=20, group=GROUP_DETECTION, tooltip="Bars required on each side of a confirmed liquidity pivot.")
int atrLength = input.int(14, "ATR length", minval=5, maxval=100, group=GROUP_DETECTION, tooltip="Volatility baseline used for regime normalization and projected levels.")
bool requireCandleFlip = input.bool(true, "Require directional reclaim candle", group=GROUP_DETECTION, tooltip="Bullish sweeps must close above the open; bearish sweeps must close below the open.")

int rankLength = input.int(100, "Percentile lookback", minval=30, maxval=500, group=GROUP_RANKING, tooltip="Rolling sample used to rank volume, wick extremity, and trend expansion.")
float minimumScore = input.float(65.0, "Minimum sweep score", minval=50.0, maxval=95.0, step=1.0, group=GROUP_RANKING, tooltip="Minimum composite percentile score required to confirm a signal.")
float minimumVolumeRank = input.float(55.0, "Minimum volume percentile", minval=0.0, maxval=100.0, step=1.0, group=GROUP_RANKING, tooltip="Rejects sweeps with weak relative participation.")
float maximumTrendRank = input.float(85.0, "Maximum trend-expansion percentile", minval=40.0, maxval=100.0, step=1.0, group=GROUP_RANKING, tooltip="Avoids fading sweeps during statistically extreme trend expansion.")
int fastEmaLength = input.int(21, "Fast EMA", minval=2, maxval=100, group=GROUP_RANKING)
int slowEmaLength = input.int(55, "Slow EMA", minval=5, maxval=250, group=GROUP_RANKING)

float stopAtrBuffer = input.float(0.15, "Stop ATR buffer", minval=0.0, maxval=2.0, step=0.05, group=GROUP_RISK, tooltip="ATR buffer placed beyond the sweep extreme.")
float targetOneR = input.float(1.0, "Target 1 risk multiple", minval=0.5, maxval=5.0, step=0.25, group=GROUP_RISK)
float targetTwoR = input.float(2.0, "Target 2 risk multiple", minval=1.0, maxval=10.0, step=0.25, group=GROUP_RISK)
int projectionBars = input.int(40, "Projection length", minval=10, maxval=200, group=GROUP_RISK, tooltip="Horizontal length of stop and target projections.")

bool showLiquidity = input.bool(true, "Show active liquidity", group=GROUP_VISUALS)
bool showProjections = input.bool(true, "Show latest projections", group=GROUP_VISUALS)
bool showDashboard = input.bool(true, "Show dashboard", group=GROUP_VISUALS)
color bullColor = input.color(#00D9A3, "Bullish color", group=GROUP_VISUALS)
color bearColor = input.color(#FF3B81, "Bearish color", group=GROUP_VISUALS)
color neutralColor = input.color(#8A93A6, "Neutral color", group=GROUP_VISUALS)

// ─────────────────────────────────────────────────────────────────────────────
// Confirmed liquidity pivots
// ─────────────────────────────────────────────────────────────────────────────
float pivotHigh = ta.pivothigh(high, swingLength, swingLength)
float pivotLow = ta.pivotlow(low, swingLength, swingLength)

var float buySideLiquidity = na
var float sellSideLiquidity = na
var int buySideBar = na
var int sellSideBar = na
var bool buySideActive = false
var bool sellSideActive = false
var line buySideLine = na
var line sellSideLine = na

if not na(pivotHigh)
    buySideLiquidity := pivotHigh
    buySideBar := bar_index - swingLength
    buySideActive := true
    if not na(buySideLine)
        line.delete(buySideLine)
    if showLiquidity
        buySideLine := line.new(buySideBar, buySideLiquidity, bar_index, buySideLiquidity, extend=extend.right, color=color.new(bearColor, 35), style=line.style_dashed, width=1)

if not na(pivotLow)
    sellSideLiquidity := pivotLow
    sellSideBar := bar_index - swingLength
    sellSideActive := true
    if not na(sellSideLine)
        line.delete(sellSideLine)
    if showLiquidity
        sellSideLine := line.new(sellSideBar, sellSideLiquidity, bar_index, sellSideLiquidity, extend=extend.right, color=color.new(bullColor, 35), style=line.style_dashed, width=1)

// ─────────────────────────────────────────────────────────────────────────────
// Detection → confirmation gate → signal
// ─────────────────────────────────────────────────────────────────────────────
float atrValue = ta.atr(atrLength)
float fastEma = ta.ema(close, fastEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
float barSpan = math.max(high - low, syminfo.mintick)
float lowerWickRatio = math.max(math.min(open, close) - low, 0.0) / barSpan
float upperWickRatio = math.max(high - math.max(open, close), 0.0) / barSpan
float bullishReclaim = math.max((close - low) / barSpan, 0.0) * 100.0
float bearishReclaim = math.max((high - close) / barSpan, 0.0) * 100.0
float trendMetric = not na(atrValue) and atrValue > 0.0 ? math.abs(fastEma - slowEma) / atrValue : na

float volumeRank = ta.percentrank(volume, rankLength)
float lowerWickRank = ta.percentrank(lowerWickRatio, rankLength)
float upperWickRank = ta.percentrank(upperWickRatio, rankLength)
float trendRank = ta.percentrank(trendMetric, rankLength)

float bullishScoreRaw = volumeRank * 0.35 + lowerWickRank * 0.35 + bullishReclaim * 0.30
float bearishScoreRaw = volumeRank * 0.35 + upperWickRank * 0.35 + bearishReclaim * 0.30
float bullishScore = math.min(100.0, math.max(0.0, bullishScoreRaw))
float bearishScore = math.min(100.0, math.max(0.0, bearishScoreRaw))

bool bullishSweep = sellSideActive and not na(sellSideLiquidity) and low < sellSideLiquidity and close > sellSideLiquidity
bool bearishSweep = buySideActive and not na(buySideLiquidity) and high > buySideLiquidity and close < buySideLiquidity
bool ranksReady = not na(volumeRank) and not na(lowerWickRank) and not na(upperWickRank) and not na(trendRank) and not na(atrValue)
bool bullishCandleGate = not requireCandleFlip or close > open
bool bearishCandleGate = not requireCandleFlip or close < open
bool regimeGate = ranksReady and trendRank <= maximumTrendRank
bool bullishSignal = bullishSweep and regimeGate and bullishCandleGate and volumeRank >= minimumVolumeRank and bullishScore >= minimumScore
bool bearishSignal = bearishSweep and regimeGate and bearishCandleGate and volumeRank >= minimumVolumeRank and bearishScore >= minimumScore

if bullishSweep
    sellSideActive := false
    if not na(sellSideLine)
        line.set_extend(sellSideLine, extend.none)
        line.set_x2(sellSideLine, bar_index)

if bearishSweep
    buySideActive := false
    if not na(buySideLine)
        line.set_extend(buySideLine, extend.none)
        line.set_x2(buySideLine, bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// Signal projections
// ─────────────────────────────────────────────────────────────────────────────
var line sweepLine = na
var line stopLine = na
var line targetOneLine = na
var line targetTwoLine = na
var string latestState = "Waiting"
var float latestScore = na
var float latestStop = na
var float latestTargetOne = na
var float latestTargetTwo = na

if bullishSignal
    float bullishStop = low - atrValue * stopAtrBuffer
    float bullishRisk = math.max(close - bullishStop, syminfo.mintick)
    float bullishTargetOne = close + bullishRisk * targetOneR
    float bullishTargetTwoFallback = close + bullishRisk * targetTwoR
    float bullishTargetTwo = not na(buySideLiquidity) and buySideLiquidity > bullishTargetOne ? buySideLiquidity : bullishTargetTwoFallback
    latestState := "Bullish sweep"
    latestScore := bullishScore
    latestStop := bullishStop
    latestTargetOne := bullishTargetOne
    latestTargetTwo := bullishTargetTwo
    if not na(sweepLine)
        line.delete(sweepLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(targetOneLine)
        line.delete(targetOneLine)
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
    if showProjections
        sweepLine := line.new(bar_index, sellSideLiquidity, bar_index + projectionBars, sellSideLiquidity, color=color.new(bullColor, 15), style=line.style_dashed, width=2)
        stopLine := line.new(bar_index, bullishStop, bar_index + projectionBars, bullishStop, color=color.new(bearColor, 15), style=line.style_dashed, width=1)
        targetOneLine := line.new(bar_index, bullishTargetOne, bar_index + projectionBars, bullishTargetOne, color=color.new(bullColor, 20), style=line.style_dotted, width=2)
        targetTwoLine := line.new(bar_index, bullishTargetTwo, bar_index + projectionBars, bullishTargetTwo, color=color.new(bullColor, 0), style=line.style_dotted, width=2)

if bearishSignal
    float bearishStop = high + atrValue * stopAtrBuffer
    float bearishRisk = math.max(bearishStop - close, syminfo.mintick)
    float bearishTargetOne = close - bearishRisk * targetOneR
    float bearishTargetTwoFallback = close - bearishRisk * targetTwoR
    float bearishTargetTwo = not na(sellSideLiquidity) and sellSideLiquidity < bearishTargetOne ? sellSideLiquidity : bearishTargetTwoFallback
    latestState := "Bearish sweep"
    latestScore := bearishScore
    latestStop := bearishStop
    latestTargetOne := bearishTargetOne
    latestTargetTwo := bearishTargetTwo
    if not na(sweepLine)
        line.delete(sweepLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(targetOneLine)
        line.delete(targetOneLine)
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
    if showProjections
        sweepLine := line.new(bar_index, buySideLiquidity, bar_index + projectionBars, buySideLiquidity, color=color.new(bearColor, 15), style=line.style_dashed, width=2)
        stopLine := line.new(bar_index, bearishStop, bar_index + projectionBars, bearishStop, color=color.new(bearColor, 15), style=line.style_dashed, width=1)
        targetOneLine := line.new(bar_index, bearishTargetOne, bar_index + projectionBars, bearishTargetOne, color=color.new(bearColor, 20), style=line.style_dotted, width=2)
        targetTwoLine := line.new(bar_index, bearishTargetTwo, bar_index + projectionBars, bearishTargetTwo, color=color.new(bearColor, 0), style=line.style_dotted, width=2)

plotshape(bullishSignal, title="Bullish sweep signal", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small, text="NSRE", textcolor=color.white)
plotshape(bearishSignal, title="Bearish sweep signal", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="NSRE", textcolor=color.white)

// ─────────────────────────────────────────────────────────────────────────────
// Live dashboard
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 8, border_width=1, frame_color=color.new(neutralColor, 55), border_color=color.new(neutralColor, 70))

if barstate.islast and showDashboard
    color stateColor = latestState == "Bullish sweep" ? bullColor : latestState == "Bearish sweep" ? bearColor : neutralColor
    string regimeText = na(trendRank) ? "Warming up" : trendRank > maximumTrendRank ? "Expansion" : trendRank >= 50.0 ? "Directional" : "Balanced"
    string scoreText = na(latestScore) ? "—" : str.tostring(latestScore, "#.0")
    string volumeText = na(volumeRank) ? "—" : str.tostring(volumeRank, "#.0") + "%"
    string trendText = na(trendRank) ? "—" : str.tostring(trendRank, "#.0") + "%"
    string stopText = na(latestStop) ? "—" : str.tostring(latestStop, format.mintick)
    string targetOneText = na(latestTargetOne) ? "—" : str.tostring(latestTargetOne, format.mintick)
    string targetTwoText = na(latestTargetTwo) ? "—" : str.tostring(latestTargetTwo, format.mintick)
    table.cell(dashboard, 0, 0, "NSRE", bgcolor=color.new(stateColor, 15), text_color=color.white)
    table.cell(dashboard, 1, 0, latestState, bgcolor=color.new(stateColor, 15), text_color=color.white)
    table.cell(dashboard, 0, 1, "Score", text_color=neutralColor)
    table.cell(dashboard, 1, 1, scoreText, text_color=stateColor)
    table.cell(dashboard, 0, 2, "Volume rank", text_color=neutralColor)
    table.cell(dashboard, 1, 2, volumeText, text_color=color.white)
    table.cell(dashboard, 0, 3, "Trend rank", text_color=neutralColor)
    table.cell(dashboard, 1, 3, trendText, text_color=color.white)
    table.cell(dashboard, 0, 4, "Regime", text_color=neutralColor)
    table.cell(dashboard, 1, 4, regimeText, text_color=regimeText == "Expansion" ? bearColor : bullColor)
    table.cell(dashboard, 0, 5, "Stop", text_color=neutralColor)
    table.cell(dashboard, 1, 5, stopText, text_color=bearColor)
    table.cell(dashboard, 0, 6, "Target 1", text_color=neutralColor)
    table.cell(dashboard, 1, 6, targetOneText, text_color=stateColor)
    table.cell(dashboard, 0, 7, "Target 2", text_color=neutralColor)
    table.cell(dashboard, 1, 7, targetTwoText, text_color=stateColor)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 7)

alertcondition(bullishSignal, title="NSRE Bullish Sweep", message="Nonparametric Sweep Regime Engine confirmed a bullish liquidity sweep on {{ticker}} {{interval}}.")
alertcondition(bearishSignal, title="NSRE Bearish Sweep", message="Nonparametric Sweep Regime Engine confirmed a bearish liquidity sweep on {{ticker}} {{interval}}.")
````
