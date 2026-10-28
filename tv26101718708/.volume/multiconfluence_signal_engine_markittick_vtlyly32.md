# Multi-Confluence Signal Engine [MarkitTick]

- url: https://www.tradingview.com/script/vTLylY32-Multi-Confluence-Signal-Engine-MarkitTick/
- type: indicator
- pine_id: PUB;4e834f671d354f3d9ad1b7ff0ba95fad
- version: 1.0

## Description

💡 A confluence-weighted signal engine that scores trend, momentum, volume, and market-structure conditions independently, then blends them into two composite 0–100 readings — a Bull Score and a Bear Score — to identify moments where multiple independent forces align in the same direction. Rather than reacting to one indicator crossing one line, this script asks four different questions about price behavior at once and only flags a signal when the weight of evidence clears a threshold you control.

[b]✨ Originality and Utility[/b]

Most confluence or "confirmation" scripts on TradingView work by checking a fixed list of conditions and requiring all of them, or a majority of them, to be true — a rigid AND/OR gate. This script instead builds four independent sub-scores (Trend, Momentum, Volume, Structure), each internally weighted by the relative importance of its own components, and then combines those four legs using user-defined percentage weights into a single continuous score. The practical difference is that a trader can decide, for example, that market structure matters twice as much as volume for their instrument, and the engine will respect that priority mathematically rather than treating every condition as equally binary.

The engine does not stop at "yes/no." Each leg produces a 0–100 magnitude, visible individually on the dashboard, so a trader can see not just that a signal fired but which of the four legs was doing the heavy lifting. A signal driven primarily by Structure (a break of a swing high with rising highs and lows) has a different character than one driven primarily by Volume (a spike on an up-close candle), even if both produce the same final score. This decomposition is what separates the tool from a simple scoring checklist: the score is diagnostic, not just directional.

On top of scoring, the script layers a full trade-management shell: ATR-based stop placement, three R:R-defined take-profit levels, a minimum-bar-gap cooldown to prevent signal clustering, a minimum score-gap requirement between the bull and bear reading to avoid firing on a coin-flip, an optional higher-timeframe trend filter, and an optional ATR-based volatility filter to suppress signals during dead, choppy conditions. This turns a scoring model into a usable end-to-end signal-and-management framework rather than a standalone oscillator.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/ibjGeEoS/[/image]
[b]• Trend Leg[/b]
The trend component is built from three EMAs — Fast, Slow, and Macro — calculated with a manual recursive EMA function rather than the built-in, giving explicit control over the smoothing seed. Four conditions are checked: whether the Fast EMA sits above (or below) the Slow EMA, whether price trades above (or below) the Macro EMA, and whether the Fast and Slow EMA slopes (measured as simple rate-of-change over a lookback window) are rising or falling. Each condition contributes a fixed point value toward either the bullish or bearish trend sub-score, weighted so that the Fast/Slow EMA relationship and the price-vs-Macro relationship carry the most influence, with slope direction acting as a secondary confirmation.

[b]• Momentum Leg[/b]
Momentum blends RSI positioning relative to a configurable midline, MACD line-vs-signal crossover state, and MACD histogram direction (rising or falling versus the prior bar). Each of the three contributes roughly a third of the momentum sub-score, meaning momentum only reads as strongly bullish or bearish when oscillator position, trigger-line relationship, and histogram acceleration all agree.

[b]• Volume Leg[/b]
Volume scoring looks for two things: whether current volume exceeds a multiple of its moving average (a "spike") occurring on a candle that closed in the corresponding direction, and whether volume is simply expanding bar-over-bar in that same direction. A volume spike on a directional candle carries the larger weight, since an expanding-but-unspiked volume reading is a weaker signal of conviction than an outright surge.

[b]• Structure Leg[/b]
This is a swing-based market-structure read. Pivot highs and lows are detected with a symmetric lookback window (a bar must be the extreme point within a window of bars on both sides to qualify), and the script tracks the two most recent pivot highs and two most recent pivot lows. A bullish structure state requires both the pivot highs and pivot lows to be printing progressively higher (higher highs, higher lows); a bearish state requires the mirror condition. Separately, the script tracks a "break of structure" — price closing beyond the last confirmed pivot high or low in a direction that differs from the currently tracked structural bias — as an additional, heavier-weighted structural signal.

[b]• Composite Scoring[/b]
The four leg scores are combined using a weighted average, where the weights (Trend / Momentum / Volume / Structure) are fully configurable and normalized against their own sum, so the four percentages do not need to add to exactly 100 to remain internally consistent. The result is a Bull Score and a Bear Score, each independently ranging from 0–100, which are then bucketed into Strong, Medium, Weak, or None tiers based on two adjustable thresholds.

[b]• Signal Confirmation Logic[/b]
A raw long or short condition requires the relevant score to clear the Medium threshold, the gap between the bull and bear scores to exceed a minimum separation (preventing signals when both sides are nearly tied), an optional higher-timeframe trend agreement check, an optional minimum-volatility check using ATR as a percentage of price, and a minimum bar-count since the last signal in that direction. Signals are only confirmed on a closed bar (barstate.isconfirmed), so the plotted signal state does not repaint on the current, still-forming bar.

[b]• Higher-Timeframe Filter[/b]
When enabled, the script requests the prior, fully closed value of price and a slow EMA from a higher timeframe using an offset lookback, which is the standard non-repainting method for pulling higher-timeframe context — it deliberately reads the last confirmed HTF bar rather than the in-progress one, so this filter does not introduce forward-looking bias.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/1YjhjeQX/[/image]
[b]• Heatmap Candles[/b]
When enabled, candle bodies, wicks, and borders are recolored using the Bull/Bear/Neutral color inputs based on which composite score currently leads and whether it clears the Medium tier — teal-family for a leading bull score at or above Medium, red-family for a leading bear score at or above Medium, and gray for anything below that threshold on both sides.

[b]• EMA Lines[/b]
Three plotted lines track the Fast EMA (blue by default), Slow EMA (orange by default), and Macro EMA (purple by default). Their relative position and slope are the visual counterpart of the Trend Leg's underlying math.

[b]• Score Labels[/b]
When a long signal fires, a label appears below that bar showing the rounded Bull Score. When a short signal fires, a label appears above that bar showing the rounded Bear Score. These give an at-a-glance read of how strong the triggering signal was without opening the dashboard.

[b]• Trade Levels[/b]
On a confirmed signal, the script draws a full set of horizontal levels: a Stop-Loss line (red, with an "✕ SL" label), an Entry line (blue dashed, "▶ Entry" label), and three Take-Profit lines at increasing R:R multiples (teal dashed, "◆ TP1", "✦ TP2", "◆ TP3" labels, with opacity increasing from TP1 to TP3). Shaded fills connect Entry-to-Stop (risk zone) and Entry-to-TP3 (reward zone) so the risk/reward geometry is visible at a glance. These levels extend forward automatically as new bars form and are replaced whenever a fresh signal fires, unless the Lock Signal input is enabled, in which case the current level set is frozen and new signals are suppressed from redrawing them.

[b]• Dashboard[/b]
An optional on-chart table (position configurable to any corner) summarizes, per bar: the current lock state, the Bull Score and Bear Score as filled progress bars with a percentage, the Bull Tier and Bear Tier classification, each of the four leg scores as its own progress bar, the current volume ratio versus its moving average, and the current ATR as a percentage of price. The progress bars use a three-color scale (teal / amber / red) based on how far the underlying reading sits from its maximum, giving a quick visual read of leg strength without needing to interpret raw numbers.

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/PfZJ8v2w/[/image]
A long condition is flagged only when the Bull Score clears the Medium threshold, leads the Bear Score by at least the configured minimum gap, and passes whichever optional filters (HTF trend, volatility) are enabled — the mirror logic applies to short conditions. The dashboard's per-leg bars are useful for judging signal quality beyond the headline score: a Strong-tier signal backed by all four legs reading high is generally a more complete confluence than one where the composite score is inflated mostly by a single leg such as Volume.

The Lock Signal input is intended for reviewing a specific historical signal's levels without them being overwritten as price continues to move — enable it to freeze the current Entry/SL/TP level set in place, and disable it to resume normal level updates on the next fresh signal.

Because trade levels are geometric projections from ATR and R:R inputs at the moment of signal, not a guarantee of price reaching those levels, they should be read as a structured reference for planning position size and exits rather than a forecast.

[b]⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/arsf4d2K/[/image]
[b]• Core Settings[/b]
Strong and Medium thresholds define the score tiers; the Minimum Bars Gap enforces a cooldown between signals in the same direction; the Minimum Score Gap requires clear separation between Bull and Bear scores before either can fire; the four Leg Weight inputs control how much each of Trend, Momentum, Volume, and Structure contributes to the composite score.

[b]• Trend Leg[/b]
Fast, Slow, and Macro EMA lengths, plus the lookback window used to measure EMA slope direction.

[b]• Momentum Leg[/b]
RSI length and midline, plus MACD fast/slow/signal lengths.

[b]• Volume Leg[/b]
The moving-average length volume is compared against, and the multiplier that defines a "spike."

[b]• Structure Leg[/b]
The symmetric lookback window used to confirm a swing pivot high or low.

[b]• Filters[/b]
Optional higher-timeframe trend agreement filter (with selectable timeframe) and an optional ATR-based minimum-volatility filter, each of which can independently suppress signals that would otherwise fire.

[b]• Trade Tools[/b]
ATR multiplier for stop distance, R:R multiples for the three take-profit levels, a toggle to show or hide the drawn levels, and the Lock Signal toggle to freeze the current level set.

[b]• Visuals[/b]
Toggles for heatmap candle coloring, EMA line visibility, and score labels on signals.

[b]• Dashboard[/b]
Toggle to show or hide the on-chart summary table and a dropdown to choose which corner it docks to.

[b]• Alerts[/b]
Custom text strings for the long, short, close-long, and close-short alert JSON payloads, letting the alert output be adapted to match the syntax expected by an external webhook or automation endpoint.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]• Trend-Following Theory[/b]
The EMA-based trend leg draws on the long-standing empirical observation, formalized in academic momentum and trend-following literature, that asset prices exhibit serial correlation over intermediate horizons — trends, once established, have historically had a higher-than-random probability of persisting over the following period. Dual and triple moving-average crossover systems are among the earliest systematized expressions of this idea, and the slope-of-the-average component reflects the concept of trend "velocity" used in later technical and quantitative trend-strength research.

[b]• Oscillator and Convergence-Divergence Theory[/b]
RSI, developed by J. Welles Wilder, is grounded in the idea that the ratio of average gains to average losses over a lookback window reflects the relative strength of buying versus selling pressure, oscillating within bounds that can indicate overbought/oversold conditions or, as used here, simple directional bias relative to a midline. MACD, developed by Gerald Appel, formalizes convergence and divergence between two exponential averages of differing sensitivity; the histogram (the difference between the MACD line and its own signal line) captures acceleration or deceleration in that relationship, which is the specific behavior this script isolates when checking histogram direction.

[b]• Volume-Price Confirmation Theory[/b]
The volume leg reflects classical Dow Theory and later volume-price-analysis principles holding that price moves accompanied by above-average volume carry more conviction than moves on thin volume, since volume is treated as a proxy for the degree of market participation and consensus behind a price change.

[b]• Market Structure and Price-Action Theory[/b]
The structure leg operationalizes the concept of market structure as used in classical Dow Theory (a sequence of higher highs and higher lows defining an uptrend, and the reverse for a downtrend) and its more recent "break of structure" formalization in price-action and smart-money-concept methodologies, where a close beyond a prior swing point is treated as evidence of a shift in the controlling side of the market.

[b]• Weighted Multi-Factor Aggregation[/b]
Combining independently normalized sub-scores via user-adjustable weights mirrors the logic of multi-factor models in quantitative finance, where distinct signal families (trend, momentum, volume, structure/mean-reversion) are each scored on a common scale and then blended, rather than relying on any single factor in isolation — the underlying premise being that signal families with low correlation to one another produce more robust composite readings than any single family alone.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Multi-Confluence Signal Engine [MarkitTick]", overlay=true, max_lines_count=500, max_labels_count=500)

// ── INPUTS ──────────────────────────────────────────────────────
GRP_CORE  = "⚙️ Core Settings"
GRP_TREND = "📈 Trend Leg"
GRP_MOM   = "🌊 Momentum Leg"
GRP_VOL   = "📦 Volume Leg"
GRP_STR   = "🏗️ Structure Leg"
GRP_FILT  = "🕯️ Filters"
GRP_TRD   = "📐 Trade Tools"
GRP_VIS   = "🎨 Visuals"
_mt741a  = "📊 Dashboard"
GRP_WH    = "🔔 Alerts"
GRP_COL   = "🌈 Colors"

i_scoreStrong   = input.int(70, "Strong Threshold", minval=50, maxval=100, group=GRP_CORE)
i_scoreMedium   = input.int(45, "Medium Threshold", minval=20, maxval=90, group=GRP_CORE)
i_minBarsGap    = input.int(15, "Min Bars Between Signals", minval=0, group=GRP_CORE)
i_minScoreGap   = input.float(10, "Min Score Gap Bull/Bear", minval=0, maxval=50, step=1, group=GRP_CORE)

i_wTrend        = input.float(30, "Trend Weight %", minval=0, maxval=100, step=5, group=GRP_CORE)
i_wMom          = input.float(25, "Momentum Weight %", minval=0, maxval=100, step=5, group=GRP_CORE)
i_wVol          = input.float(15, "Volume Weight %", minval=0, maxval=100, step=5, group=GRP_CORE)
i_wStruct       = input.float(30, "Structure Weight %", minval=0, maxval=100, step=5, group=GRP_CORE)

i_emaFastLen    = input.int(21, "EMA Fast", minval=1, group=GRP_TREND)
i_emaSlowLen    = input.int(50, "EMA Slow", minval=1, group=GRP_TREND)
i_emaTrendLen   = input.int(200, "EMA Macro", minval=1, group=GRP_TREND)
i_slopeLen      = input.int(5, "Slope Lookback", minval=1, group=GRP_TREND)

i_rsiLen        = input.int(14, "RSI Length", minval=1, group=GRP_MOM)
i_rsiMid        = input.int(50, "RSI Midline", minval=1, maxval=99, group=GRP_MOM)
i_macdFast      = input.int(12, "MACD Fast", minval=1, group=GRP_MOM)
i_macdSlow      = input.int(26, "MACD Slow", minval=1, group=GRP_MOM)
i_macdSig       = input.int(9, "MACD Signal", minval=1, group=GRP_MOM)

i_volMaLen      = input.int(20, "Volume MA Length", minval=1, group=GRP_VOL)
i_volSpike      = input.float(1.5, "Volume Spike Mult", minval=1.0, step=0.1, group=GRP_VOL)

i_pivotLen      = input.int(5, "Pivot Lookback", minval=2, group=GRP_STR)

i_useHtfFilter  = input.bool(false, "Enable HTF Trend Filter", group=GRP_FILT)
i_htfRes        = input.timeframe("60", "HTF Timeframe", group=GRP_FILT)
i_useVolatFilt  = input.bool(true, "Enable Volatility Filter", group=GRP_FILT)
i_atrLen        = input.int(14, "ATR Length", minval=1, group=GRP_FILT)
i_atrMinPct     = input.float(0.05, "Min ATR % of Price", minval=0.0, step=0.01, group=GRP_FILT)

i_slAtrMult     = input.float(1.5, "SL ATR Multiplier", minval=0.1, step=0.1, group=GRP_TRD)
i_tp1RR         = input.float(1.0, "TP1 R:R", minval=0.1, step=0.1, group=GRP_TRD)
i_tp2RR         = input.float(2.0, "TP2 R:R", minval=0.1, step=0.1, group=GRP_TRD)
i_tp3RR         = input.float(3.0, "TP3 R:R", minval=0.1, step=0.1, group=GRP_TRD)
i_showLevels    = input.bool(true, "Show Trade Levels", group=GRP_TRD)
i_lockSignal    = input.bool(false, "🔒 Lock Signal", group=GRP_TRD, tooltip="Freeze current signal · block new ones")

i_showCandles   = input.bool(true, "Heatmap Candles", group=GRP_VIS)
i_showEmas      = input.bool(true, "Show EMA Lines", group=GRP_VIS)
i_showScoreLbl  = input.bool(true, "Show Score Labels", group=GRP_VIS)

i_showDash      = input.bool(true, "Show Dashboard", group=_mt741a)
i_dashPos       = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=_mt741a)

i_actionLong        = input.string("long", "↑ Long Action", group=GRP_WH)
i_actionShort       = input.string("short", "↓ Short Action", group=GRP_WH)
i_actionCloseLong   = input.string("closelong", "✕ Close Long Action", group=GRP_WH)
i_actionCloseShort  = input.string("closeshort", "✕ Close Short Action", group=GRP_WH)

c_bull          = input.color(color.new(#26a69a, 0), "Bull Color", group=GRP_COL)
c_bear          = input.color(color.new(#ef5350, 0), "Bear Color", group=GRP_COL)
c_neutral       = input.color(color.new(#787b86, 0), "Neutral Color", group=GRP_COL)
c_emaFast       = input.color(color.new(#2196f3, 0), "EMA Fast Color", group=GRP_COL)
c_emaSlow       = input.color(color.new(#ff9800, 0), "EMA Slow Color", group=GRP_COL)
_mt741b      = input.color(color.new(#9c27b0, 0), "EMA Macro Color", group=GRP_COL)
c_sl            = input.color(#ef5350, "SL Color", group=GRP_COL)
c_entry         = input.color(#2196f3, "Entry Color", group=GRP_COL)
c_tp            = input.color(#26a69a, "TP Color", group=GRP_COL)
c_lblTxt        = input.color(color.white, "Label Text Color", group=GRP_COL)
C_DASH_HDR      = input.color(color.new(#3a2a6d, 55), "Dashboard Header", group=GRP_COL)
_mt741c       = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group=GRP_COL)
C_DASH_TXT      = input.color(color.new(#ffffff, 0), "Dashboard Text", group=GRP_COL)

// ── CORE LOGIC ─────────────────────────────────────────────
f_ema(series float src, simple int length) =>
    float alpha = 2.0 / (length + 1)
    var float result = na
    result := na(result[1]) ? src : alpha * src + (1 - alpha) * result[1]
    result

emaFast = f_ema(close, i_emaFastLen)
emaSlow = f_ema(close, i_emaSlowLen)
emaMacro = f_ema(close, i_emaTrendLen)
emaFastSlope = (emaFast - emaFast[i_slopeLen]) / i_slopeLen
emaSlowSlope = (emaSlow - emaSlow[i_slopeLen]) / i_slopeLen

trendUpScore = 0.0
trendUpScore += emaFast > emaSlow ? 40.0 : 0.0
trendUpScore += close > emaMacro ? 30.0 : 0.0
trendUpScore += emaFastSlope > 0 ? 20.0 : 0.0
trendUpScore += emaSlowSlope > 0 ? 10.0 : 0.0

trendDnScore = 0.0
trendDnScore += emaFast < emaSlow ? 40.0 : 0.0
trendDnScore += close < emaMacro ? 30.0 : 0.0
trendDnScore += emaFastSlope < 0 ? 20.0 : 0.0
trendDnScore += emaSlowSlope < 0 ? 10.0 : 0.0

rsiVal = ta.rsi(close, i_rsiLen)
[macdLine, macdSig, macdHist] = ta.macd(close, i_macdFast, i_macdSlow, i_macdSig)

momUpScore = 0.0
momUpScore += rsiVal > i_rsiMid ? 35.0 : 0.0
momUpScore += macdLine > macdSig ? 35.0 : 0.0
momUpScore += macdHist > macdHist[1] ? 30.0 : 0.0

momDnScore = 0.0
momDnScore += rsiVal < i_rsiMid ? 35.0 : 0.0
momDnScore += macdLine < macdSig ? 35.0 : 0.0
momDnScore += macdHist < macdHist[1] ? 30.0 : 0.0

volMa = ta.sma(volume, i_volMaLen)
volRatio = volMa > 0 ? volume / volMa : 1.0
isVolSpike = volRatio >= i_volSpike
bullCandle = close > open
bearCandle = close < open

volUpScore = 0.0
volUpScore += isVolSpike and bullCandle ? 60.0 : 0.0
volUpScore += volume > volume[1] and bullCandle ? 40.0 : 0.0

volDnScore = 0.0
volDnScore += isVolSpike and bearCandle ? 60.0 : 0.0
volDnScore += volume > volume[1] and bearCandle ? 40.0 : 0.0

f_pivotHigh(series float src, simple int len) =>
    float candidate = src[len]
    bool isValid = true
    for i = 0 to len * 2
        if i != len and src[i] >= candidate
            isValid := false
    isValid ? candidate : na
f_pivotLow(series float src, simple int len) =>
    float candidate = src[len]
    bool isValid = true
    for i = 0 to len * 2
        if i != len and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

ph = f_pivotHigh(high[1], i_pivotLen)
pl = f_pivotLow(low[1], i_pivotLen)

var float lastPH = na
var float lastPH2 = na
var float lastPL = na
var float lastPL2 = na

if not na(ph)
    lastPH2 := lastPH
    lastPH := ph
if not na(pl)
    lastPL2 := lastPL
    lastPL := pl

structUp = not na(lastPH) and not na(lastPH2) and not na(lastPL) and not na(lastPL2) and lastPH > lastPH2 and lastPL > lastPL2
structDn = not na(lastPH) and not na(lastPH2) and not na(lastPL) and not na(lastPL2) and lastPH < lastPH2 and lastPL < lastPL2

var int lastBosDir = 0
bosUp = not na(lastPH) and close[1] > lastPH and lastBosDir <= 0
bosDn = not na(lastPL) and close[1] < lastPL and lastBosDir >= 0
if bosUp
    lastBosDir := 1
if bosDn
    lastBosDir := -1

structUpScore = 0.0
structUpScore += structUp ? 60.0 : 0.0
structUpScore += bosUp ? 40.0 : 0.0

structDnScore = 0.0
structDnScore += structDn ? 60.0 : 0.0
structDnScore += bosDn ? 40.0 : 0.0

wSum = i_wTrend + i_wMom + i_wVol + i_wStruct
wSumSafe = wSum == 0 ? 1.0 : wSum

bullScore = (trendUpScore * i_wTrend + momUpScore * i_wMom + volUpScore * i_wVol + structUpScore * i_wStruct) / wSumSafe
bearScore = (trendDnScore * i_wTrend + momDnScore * i_wMom + volDnScore * i_wVol + structDnScore * i_wStruct) / wSumSafe

f_tier(float s) =>
    string t = s >= i_scoreStrong ? "Strong" : s >= i_scoreMedium ? "Medium" : s > 0 ? "Weak" : "None"
    t

bullTier = f_tier(bullScore)
bearTier = f_tier(bearScore)

htfResSafe = timeframe.in_seconds(i_htfRes) >= timeframe.in_seconds(timeframe.period) ? i_htfRes : timeframe.period
htfEmaRaw = ta.ema(close, i_emaSlowLen)
[htfClose, htfEma] = request.security(syminfo.tickerid, htfResSafe, [close[1], htfEmaRaw[1]], lookahead=barmerge.lookahead_on)
htfBullOk = not i_useHtfFilter or (not na(htfClose) and not na(htfEma) and htfClose > htfEma)
htfBearOk = not i_useHtfFilter or (not na(htfClose) and not na(htfEma) and htfClose < htfEma)

atrVal = ta.atr(i_atrLen)
atrPct = close > 0 ? atrVal / close * 100 : 0.0
volatOk = not i_useVolatFilt or atrPct >= i_atrMinPct

var int lastLongBarIdx = na
var int lastShortBarIdx = na
gapOkLong = na(lastLongBarIdx) or (bar_index - lastLongBarIdx) >= i_minBarsGap
gapOkShort = na(lastShortBarIdx) or (bar_index - lastShortBarIdx) >= i_minBarsGap

rawLongSignal = bullScore >= i_scoreMedium and (bullScore - bearScore) >= i_minScoreGap and htfBullOk and volatOk and gapOkLong
rawShortSignal = bearScore >= i_scoreMedium and (bearScore - bullScore) >= i_minScoreGap and htfBearOk and volatOk and gapOkShort

longSignal = rawLongSignal and barstate.isconfirmed
shortSignal = rawShortSignal and barstate.isconfirmed

if longSignal
    lastLongBarIdx := bar_index
if shortSignal
    lastShortBarIdx := bar_index

var float entryPrice = na
var float slPrice = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var int lastSignalBar = na
var int lastDir = 0

if longSignal
    entryPrice := close
    slPrice := close - atrVal * i_slAtrMult
    riskDist = entryPrice - slPrice
    tp1Price := entryPrice + riskDist * i_tp1RR
    tp2Price := entryPrice + riskDist * i_tp2RR
    tp3Price := entryPrice + riskDist * i_tp3RR
    lastSignalBar := bar_index
    lastDir := 1

if shortSignal
    entryPrice := close
    slPrice := close + atrVal * i_slAtrMult
    riskDist = slPrice - entryPrice
    tp1Price := entryPrice - riskDist * i_tp1RR
    tp2Price := entryPrice - riskDist * i_tp2RR
    tp3Price := entryPrice - riskDist * i_tp3RR
    lastSignalBar := bar_index
    lastDir := -1

tp1Hit = not na(tp1Price) and lastDir == 1 and high >= tp1Price
tp2Hit = not na(tp2Price) and lastDir == 1 and high >= tp2Price
tp3Hit = not na(tp3Price) and lastDir == 1 and high >= tp3Price
tp1HitS = not na(tp1Price) and lastDir == -1 and low <= tp1Price
tp2HitS = not na(tp2Price) and lastDir == -1 and low <= tp2Price
tp3HitS = not na(tp3Price) and lastDir == -1 and low <= tp3Price

var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var linefill riskFill = na
var linefill rewardFill = na

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    linefill.delete(riskFill)
    linefill.delete(rewardFill)

bool _locked = i_lockSignal and barstate.islast

if i_showLevels and (longSignal or shortSignal) and not _locked
    f_deleteLevels()
    tpColLong1 = color.new(c_tp, 40)
    tpColLong2 = color.new(c_tp, 20)
    tpColLong3 = color.new(c_tp, 0)
    slLine := line.new(bar_index, slPrice, bar_index, slPrice, color=c_sl, width=2)
    entryLine := line.new(bar_index, entryPrice, bar_index, entryPrice, color=c_entry, width=1, style=line.style_dashed)
    tp1Line := line.new(bar_index, tp1Price, bar_index, tp1Price, color=tpColLong1, width=1, style=line.style_dashed)
    tp2Line := line.new(bar_index, tp2Price, bar_index, tp2Price, color=tpColLong2, width=1, style=line.style_dashed)
    tp3Line := line.new(bar_index, tp3Price, bar_index, tp3Price, color=tpColLong3, width=1, style=line.style_dashed)
    slLbl := label.new(bar_index, slPrice, "✕ SL " + str.tostring(slPrice, format.mintick), style=label.style_label_left, color=c_sl, textcolor=c_lblTxt, size=size.small)
    entryLbl := label.new(bar_index, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style=label.style_label_left, color=c_entry, textcolor=c_lblTxt, size=size.small)
    tp1Lbl := label.new(bar_index, tp1Price, "◆ TP1 " + str.tostring(tp1Price, format.mintick), style=label.style_label_left, color=c_tp, textcolor=c_lblTxt, size=size.small)
    tp2Lbl := label.new(bar_index, tp2Price, "✦ TP2 " + str.tostring(tp2Price, format.mintick), style=label.style_label_left, color=c_tp, textcolor=c_lblTxt, size=size.small)
    tp3Lbl := label.new(bar_index, tp3Price, "◆ TP3 " + str.tostring(tp3Price, format.mintick), style=label.style_label_left, color=c_tp, textcolor=c_lblTxt, size=size.small)
    riskFill := linefill.new(slLine, entryLine, color.new(c_sl, 80))
    rewardFill := linefill.new(entryLine, tp3Line, color.new(c_tp, 85))

if i_showLevels and not na(slLine) and not na(lastSignalBar) and (i_lockSignal or bar_index <= lastSignalBar + 50)
    int _extX = i_lockSignal ? bar_index + 50 : lastSignalBar + 50
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    label.set_x(tp2Lbl, _extX)
    label.set_x(tp3Lbl, _extX)

// ── VISUALS ───────────────────────────────────────────────
bodyColor = bullScore > bearScore and bullScore >= i_scoreMedium ? c_bull : bearScore > bullScore and bearScore >= i_scoreMedium ? c_bear : c_neutral
borderColor = bodyColor

plotcandle(open, high, low, close, title="Heatmap Candles", color=i_showCandles ? bodyColor : na, wickcolor=i_showCandles ? borderColor : na, bordercolor=i_showCandles ? borderColor : na)

plot(i_showEmas ? emaFast : na, "EMA Fast", color=c_emaFast, linewidth=1)
plot(i_showEmas ? emaSlow : na, "EMA Slow", color=c_emaSlow, linewidth=1)
plot(i_showEmas ? emaMacro : na, "EMA Macro", color=_mt741b, linewidth=2)

if i_showScoreLbl and longSignal
    label.new(bar_index, low, str.tostring(math.round(bullScore)), style=label.style_label_up, color=c_bull, textcolor=c_lblTxt, size=size.small)
if i_showScoreLbl and shortSignal
    label.new(bar_index, high, str.tostring(math.round(bearScore)), style=label.style_label_down, color=c_bear, textcolor=c_lblTxt, size=size.small)

f_barColor(float pct) =>
    color result = pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)
    result

f_bar(float val, float maxVal) =>
    float safeMax = maxVal == 0 ? 1.0 : maxVal
    int filled = math.round(math.min(val / safeMax, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / safeMax * 100)) + "%"

// ── DASHBOARD ─────────────────────────────────────────
var table dash = na

f_dashPos(string p) =>
    string result = p == "Top Right" ? position.top_right : p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : position.bottom_left
    result

if i_showDash
    if na(dash)
        dash := table.new(f_dashPos(i_dashPos), 2, 12, border_width=1, border_color=color.new(#2a3040, 40), frame_width=1, frame_color=color.new(#3a2a6d, 40))
    row_a = _mt741c
    row_b = color.new(_mt741c, 40)
    lbl_col = color.new(C_DASH_TXT, 25)
    table.cell(dash, 0, 0, "MCSE", text_color=C_DASH_TXT, text_size=size.small, bgcolor=C_DASH_HDR, text_halign=text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color=C_DASH_TXT, text_size=size.small, bgcolor=C_DASH_HDR, text_halign=text.align_right)
    table.cell(dash, 0, 1, "  Lock", text_color=lbl_col, text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 1, i_lockSignal ? "ACTIVE  " : "OFF  ", text_color=i_lockSignal ? c_bear : C_DASH_TXT, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
    table.cell(dash, 0, 2, "  Bull Score", text_color=lbl_col, text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_bar(bullScore, 100), text_color=f_barColor(bullScore / 100), text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
    table.cell(dash, 0, 3, "  Bear Score", text_color=lbl_col, text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_bar(bearScore, 100), text_color=f_barColor(bearScore / 100), text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
    table.cell(dash, 0, 4, "  Bull Tier", text_color=lbl_col, text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
    table.cell(dash, 1, 4, bullTier + "  ", text_color=bullTier == "None" ? C_DASH_TXT : c_bull, text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
    table.cell(dash, 0, 5, "  Bear Tier", text_color=lbl_col, text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 5, bearTier + "  ", text_color=bearTier == "None" ? C_DASH_TXT : c_bear, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
    table.cell(dash, 0, 6, "  Trend Leg", text_color=lbl_col, text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
    table.cell(dash, 1, 6, f_bar(math.max(trendUpScore, trendDnScore), 100), text_color=f_barColor(math.max(trendUpScore, trendDnScore) / 100), text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
    table.cell(dash, 0, 7, "  Momentum Leg", text_color=lbl_col, text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 7, f_bar(math.max(momUpScore, momDnScore), 100), text_color=f_barColor(math.max(momUpScore, momDnScore) / 100), text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
    table.cell(dash, 0, 8, "  Volume Leg", text_color=lbl_col, text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
    table.cell(dash, 1, 8, f_bar(math.max(volUpScore, volDnScore), 100), text_color=f_barColor(math.max(volUpScore, volDnScore) / 100), text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
    table.cell(dash, 0, 9, "  Structure Leg", text_color=lbl_col, text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 9, f_bar(math.max(structUpScore, structDnScore), 100), text_color=f_barColor(math.max(structUpScore, structDnScore) / 100), text_size=size.small, bgcolor=row_a, text_halign=text.align_right)
    table.cell(dash, 0, 10, "  Volume Ratio", text_color=lbl_col, text_size=size.small, bgcolor=row_b, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(volRatio, "#.##") + "x  ", text_color=isVolSpike ? c_bull : C_DASH_TXT, text_size=size.small, bgcolor=row_b, text_halign=text.align_right)
    table.cell(dash, 0, 11, "  ATR %", text_color=lbl_col, text_size=size.small, bgcolor=row_a, text_halign=text.align_left)
    table.cell(dash, 1, 11, str.tostring(atrPct, "#.##") + "%  ", text_color=volatOk ? C_DASH_TXT : c_bear, text_size=size.small, bgcolor=row_a, text_halign=text.align_right)

// ── ALERTS ──────────────────────────────────────────────
string _longInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","score":"{3}","tier":"{4}","entry":"{5}","sl":"{6}","tp1":"{7}","tp2":"{8}","tp3":"{9}"', i_actionLong, syminfo.tickerid, timeframe.period, str.tostring(math.round(bullScore)), bullTier, str.tostring(close, format.mintick), str.tostring(nz(slPrice), format.mintick), str.tostring(nz(tp1Price), format.mintick), str.tostring(nz(tp2Price), format.mintick), str.tostring(nz(tp3Price), format.mintick))
string longPayload = "{" + _longInner + "}"

string _shortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","score":"{3}","tier":"{4}","entry":"{5}","sl":"{6}","tp1":"{7}","tp2":"{8}","tp3":"{9}"', i_actionShort, syminfo.tickerid, timeframe.period, str.tostring(math.round(bearScore)), bearTier, str.tostring(close, format.mintick), str.tostring(nz(slPrice), format.mintick), str.tostring(nz(tp1Price), format.mintick), str.tostring(nz(tp2Price), format.mintick), str.tostring(nz(tp3Price), format.mintick))
string shortPayload = "{" + _shortInner + "}"

string _closeLongInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closelong"', i_actionCloseLong, syminfo.tickerid, timeframe.period)
string closeLongPayload = "{" + _closeLongInner + "}"

string _closeShortInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"closeshort"', i_actionCloseShort, syminfo.tickerid, timeframe.period)
string closeShortPayload = "{" + _closeShortInner + "}"

string _tp1Inner = str.format('"action":"tp1hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(nz(tp1Price), format.mintick))
string tp1Payload = "{" + _tp1Inner + "}"
string _tp2Inner = str.format('"action":"tp2hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(nz(tp2Price), format.mintick))
string tp2Payload = "{" + _tp2Inner + "}"
string _tp3Inner = str.format('"action":"tp3hit","ticker":"{0}","tf":"{1}","price":"{2}"', syminfo.tickerid, timeframe.period, str.tostring(nz(tp3Price), format.mintick))
string tp3Payload = "{" + _tp3Inner + "}"

if longSignal
    alert(longPayload, alert.freq_once_per_bar_close)
    alert(closeShortPayload, alert.freq_once_per_bar_close)
if shortSignal
    alert(shortPayload, alert.freq_once_per_bar_close)
    alert(closeLongPayload, alert.freq_once_per_bar_close)

if tp1Hit or tp1HitS
    alert(tp1Payload, alert.freq_once_per_bar)
if tp2Hit or tp2HitS
    alert(tp2Payload, alert.freq_once_per_bar)
if tp3Hit or tp3HitS
    alert(tp3Payload, alert.freq_once_per_bar)

alertcondition(longSignal, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(shortSignal, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(shortSignal, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(longSignal, "Close Short Signal", "MarkitTick — Close Short")
````
