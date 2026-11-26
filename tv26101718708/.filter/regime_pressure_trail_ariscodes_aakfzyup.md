# Regime Pressure Trail [ArisCodes]

- url: https://www.tradingview.com/script/AakfZyUp-Regime-Pressure-Trail-ArisCodes/
- type: indicator
- pine_id: PUB;2d0fdca6350e44788b96b3ed2dc84d62
- version: 1.0

## Description

REGIME PRESSURE TRAIL

This script is a regime-arbitrated trading framework, not a stack of two indicators. The core idea is that no single signal logic performs well across all market conditions — trend-following systems whipsaw in low volatility chop, while pressure-reading systems lag in clean directional trends. They have opposite failure modes, which means they have opposite ideal conditions. This script formalizes that observation by using a volatility regime classifier as a meta-controller that decides which of two child engines has authority to fire on any given bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHY ONE ENGINE IS NOT ENOUGH

Volatility is non-stationary. Markets cycle through quiet accumulation phases, expansive trending phases, and chaotic news-driven phases. A signal logic that performs well in one phase often produces its worst trades in another. Most retail attempts to solve this stack two indicators and let them fire independently — which is what this script explicitly avoids. Stacking creates conflicting signals and double-counts confluence. Arbitration solves it by making the regime itself the gatekeeper.

The trail-following child uses an ATR-based Chandelier exit with a self-adjusting multiplier (tight in quiet markets, wide in volatile markets) gated by a composite trend-strength score combining RSI slope acceleration, volume surge ratio, and ATR expansion. This logic targets clean directional moves with structural follow-through.

The pressure child uses cumulative delta volume crossing a moving average of itself, gated by a composite pressure score combining delta dominance, volume relative to its moving average, and candle body conviction. This logic targets institutional accumulation and distribution events that are often invisible to price-only signals.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW THE COMPONENTS INTEGRATE

The volatility regime classifier computes the ratio of current ATR to its 50-bar simple moving average. This ratio places the market into one of three bins: LOW (ratio below 0.8 default), MEDIUM (between 0.8 and 1.4), or HIGH (above 1.4). The thresholds are user-tunable.

The arming logic translates regime to engine authority through three mutually exclusive modes. In Regime Arms mode, the LOW regime arms only the pressure engine because trend signals in contracting volatility are typically false flips. The HIGH regime arms only the trail engine because pressure crossovers in expanding volatility are typically lagging noise. The MEDIUM regime arms both, which lets either engine fire on the merits of its own scoring gate. In Confluence Required mode, both engines must produce the same direction signal on the same bar — a high-conviction filter that produces fewer trades. In Either Fires mode, the regime gating is disabled and the two engines compete on a first-come-first-served basis, which serves as a baseline for comparison.

When a signal fires, the entry routing is also engine-aware. Trail-engine entries use ATR-multiplier targets and inherit the trail line as a dynamic stop, with a force-exit if the trail flips against the position. Pressure-engine entries use fixed percentage targets and tighter stops because the edge they capture is shorter-duration. Confluence entries take whichever engine has the higher score at fire-time. This per-engine trade management is a deliberate design choice — it prevents the tighter-stop pressure logic from degrading trail-engine wins, and prevents the wider trail logic from giving back pressure-engine quick scalps.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT IS ORIGINAL HERE

The novel contribution is the arbitration layer, not the underlying engines. Both engines individually use components that are public knowledge — ATR Chandelier exits and cumulative volume delta have decades of literature behind them. What this script adds is the explicit codification of a meta-decision: which logic is allowed to operate in which regime, and why.

Specifically, the lines that prove this is arbitration rather than a stack are visible in source: a single boolean evaluates whether each engine's regime is currently armed, and signal logic is gated by those booleans before any other condition is checked. Two engines cannot fire on the same bar in Regime Arms mode by design. The script also tags each fired trade with its source engine, which allows post-hoc attribution analysis to verify the arbitration logic empirically.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO USE

Begin with the default HYBRID mode and Regime Arms hybrid logic. Watch the dashboard for several sessions before changing inputs. The ARMED cell shows which engine has authority right now. The REGIME cell shows why. The TREND SCORE and PRESSURE SCORE cells show whether the armed engine has met its scoring gate.

When a signal fires, the entry label identifies which engine fired it (TRAIL, PRESSURE, or CONFLUENCE). This is critical for understanding the script. Over time, traders should observe that trail entries cluster in higher volatility regimes and pressure entries cluster in lower volatility regimes — that pattern confirms the arbitration is working as designed.

Adjust regime thresholds first if you find the script is firing too many trail signals (raise lowThresh to push more bars into LOW regime where trail is disarmed) or too few (lower lowThresh). Adjust score minimums second to filter quality. Adjust target percentages last and only after you have a clear picture of which engine is doing most of the work on your instrument and timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INPUTS OVERVIEW

ENGINE SELECTION
Master mode (TRAIL ONLY, PRESSURE ONLY, HYBRID) and the hybrid arming logic (Regime Arms, Confluence Required, Either Fires).

TRAIL ENGINE
ATR length and source, regime classifier lookback, three vol-regime multipliers (LOW, MED, HIGH), two regime thresholds, minimum trend-strength score, RSI slope length, volume MA length.

PRESSURE ENGINE
Delta MA length, volume MA length, minimum pressure score, RSI length, RSI overbought and oversold filters.

TRADE MANAGEMENT
Independent TP and SL percentages per engine, ATR multiplier for trail-engine targets, max bars in trade, cooldown bars, trail-flip force-exit toggle.

VISUALS
Trail line plot, regime background tint, pressure-based candle coloring, gradient fill between price and VWAP, trade boxes, dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DASHBOARD

The dashboard is the diagnostic display for the entire arbitration system. It sits at the bottom-center of the chart and updates only on the last bar to keep the chart clean. Reading it correctly is essential to understanding how the script makes decisions in real time.

The dashboard is organized as a 5-row table with 9 columns. Each row tells a different part of the story.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROW 1 — PRIMARY STATE

MODE — Shows your selected master engine mode: TRAIL ONLY, PRESSURE ONLY, or HYBRID. Color-coded — purple for HYBRID, teal for trail-only, gold for pressure-only.

ARMED — The most important cell on the dashboard. Tells you which engine is currently allowed to fire signals. Shows TRAIL, PRESSURE, BOTH, or NONE. In HYBRID mode this changes as volatility regime shifts.

REGIME — Current volatility regime: LOW ▼ (ratio under 0.8), MED ● (0.8 to 1.4), or HIGH ▲ (above 1.4). Includes the current ATR multiplier in use (1.5x, 2.5x, or 3.5x by default).

TREND SCORE — Composite score for the trail engine, displayed as an 8-segment gauge plus the numeric value 0-100. Combines RSI slope acceleration (40%), volume surge ratio (35%), and ATR expansion (25%). Below the minimum threshold the trail engine cannot fire.

PRESSURE — Composite score for the pressure engine, also 8-segment gauge plus 0-100 number. Combines delta dominance (40%), volume relative to MA (35%), and candle body conviction (25%). Below the minimum threshold the pressure engine cannot fire.

TRAIL — Current trail direction: BULL ▲ or BEAR ▼. This is the underlying ATR Chandelier state, independent of whether the trail engine is armed.

DELTA — Current bar's delta volume direction and percentage. BUY +X% means buyers dominated this bar, SELL -X% means sellers did.

POSITION — Current trade state: FLAT, LONG ●, or SHORT ●. When in a trade, also shows which engine fired it: TRAIL, PRESS, or BOTH.

STATUS — Cooldown / readiness state. READY means ready to fire, IN TRADE means active position, CD #b means waiting cooldown bars.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROW 2 — DETAIL VALUES

Mirrors row 1 with current values: actual mode name, armed engine name, regime label with multiplier, score gauges with numbers, trail direction with current trail price, delta percentage, position with engine tag, status text.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROW 3 — CONTEXT

HYBRID MODE — Which arming logic is active: Regime Arms / Confluence Required / Either Fires.

ARMING DETAIL — Shows current armed status of both engines as ON/OFF (Trail ON Press OFF means only trail engine has authority right now).

ATR RATIO — Numeric ratio of current ATR to its 50-bar moving average. The number that drives regime classification.

SCORE RATING — Trend score quality bucket: WEAK ░ / MEDIUM ◉ / STRONG ✦. With the current minimum threshold for reference.

PRESSURE RATING — Pressure state bucket: STRONG BULL ✦ / BULL ▲ / NEUTRAL ◉ / BEAR ▼ / STRONG BEAR ✦.

TRAIL PRICE — Current numeric trail level (the actual chart price).

RSI — Pressure engine's RSI value. Color-coded: bear if overbought, bull if oversold, neutral otherwise.

ENGINE USED — When in a trade, confirms which engine fired it. Useful for post-trade attribution.

COOLDOWN STATUS — Shows cooldown bars and max bars in trade for reference.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROW 4 — TRADE MANAGEMENT

POSITION — Repeats current direction for clarity in the trade row.

ENTRY — Exact entry price when in a trade.

TP — Take profit price (matches the chart line).

SL — Stop loss price (matches the chart line).

BARS — Bars elapsed since entry, plus max bars allowed.

ATR — Current ATR value in price units.

VWAP — Current session VWAP price (the gradient fill anchor).

REGIME — Active regime + current ATR multiplier (redundant for at-a-glance trade context).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LEGEND OF SYMBOLS USED IN DASHBOARD

▲ ▼ — direction indicators (up/down, bull/bear)
● — active trade or filled state
◉ — medium/armed state
✦ — strong/active state
░ — weak state or empty gauge segment
█ — filled gauge segment
◈ — section divider in cell labels

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO READ THE DASHBOARD AT A GLANCE

1. Look at ARMED first — this tells you which engine has authority right now.
2. Look at REGIME — this tells you why the armed engine has authority.
3. Look at TREND SCORE and PRESSURE SCORE — these tell you whether the armed engine has met its scoring gate to fire.
4. Look at POSITION and STATUS — these tell you whether you are in a trade and which engine fired it.

If these four cells all line up cleanly, you understand the script's current state in under three seconds.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[image]https://www.tradingview.com/x/1jDUYozj/[/image]

ENTRY LABELS — READING A FIRED SIGNAL

When a signal fires, an information-dense label appears at the entry bar showing every parameter of the trade in two lines. Reading the label is how you know what just happened without checking the dashboard.

LINE 1 — THE HEADER

▼ SELL PRESSURE  1:0.4 RR

▼ or ▲ — direction arrow (down for short, up for long)
SELL/BUY — trade direction in plain text
PRESSURE — the engine that fired this signal (TRAIL, PRESSURE, or CONFLUENCE)
1:X.X RR — risk-to-reward ratio at entry, calculated as |TP - entry| / |SL - entry|

LINE 2 — THE PRICE LEVELS

TP 27328.50  IN 27383.25  SL 27520.25

TP — the take profit price (matches the chart's TP line)
IN — the entry fill price (bar's close at signal fire)
SL — the stop loss price (matches the chart's SL line)

The label is color-coded by direction. Bear red background with bright bear text for SHORT entries. Bull green background with bright bull text for LONG entries. The same label format is used by every signal regardless of which engine fired it — only the engine tag in the header changes. That consistency means you can read any entry on the chart and immediately understand who fired, why, and at what risk.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHAT ELSE IS VISIBLE IN THE FRAME

The cyan stair-step line with node markers is the ATR trail line (Engine 1). Even when a trade is fired by the Pressure engine, the trail line remains plotted at all times so traders can see what the OTHER engine is doing in parallel. This is intentional — it lets you visually verify whether the two engines agree or disagree at any moment, and it shows the trail's chandelier behavior independently of whether it's currently armed.

The teal gradient fill between price and VWAP shows the cumulative pressure bias on the chart. A thicker fill above price means bull pressure is dominant. A thicker fill below price means bear pressure is dominant. The fill's intensity fades as conviction weakens.

Candles are tinted by their per-bar pressure score, with five intensity states ranging from STRONG BULL (bright teal) through BULL, NEUTRAL, BEAR, to STRONG BEAR (saturated red). This per-candle coloring lets you see institutional pressure at the bar level even when no signal has fired.

The bear or bull vertical line at the entry bar marks exactly when the signal fired. Combined with the small SELL or BUY pin under or above the candle, it creates a visual anchor point for the trade that's visible at any zoom level.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NON-REPAINTING

All signals confirm on bar close. Volatility regime classification, both scoring engines, arming decisions, and entry/exit logic evaluate on confirmed bars only. Trade labels and state changes only fire after the bar has fully closed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISCLAIMER

This script is for educational and informational purposes only. It is not financial advice. Past performance does not guarantee future results. Always use proper risk management and do your own research before making any trading decisions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Regime Pressure Trail [ArisCodes]", shorttitle="RPT", overlay=true,
     max_lines_count  = 200,
     max_labels_count = 200,
     max_boxes_count  = 200)

grp_eng = "Engine Selection"
engineMode = input.string("HYBRID", "Engine Mode", options=["TRAIL ONLY", "PRESSURE ONLY", "HYBRID"], group=grp_eng, tooltip="TRAIL = ATR trail trend engine. PRESSURE = delta volume reversal engine. HYBRID = regime-aware arming, both fight for the trade.")
hybridMode = input.string("Regime Arms", "Hybrid Arming Logic", options=["Regime Arms", "Confluence Required", "Either Fires"], group=grp_eng, tooltip="Regime Arms: vol regime decides which engine is allowed to fire. Confluence: BOTH must agree. Either: first-come-first-serve.")

grp_atr  = "Trail Engine (ATR)"
atrLen      = input.int(14,    "ATR Length",                group=grp_atr, minval=1,   maxval=100)
atrSrc      = input.source(close,"Trail Source",            group=grp_atr)
regLookback = input.int(50,    "Regime Lookback (bars)",    group=grp_atr, minval=10,  maxval=200)
lowMult     = input.float(1.5, "LOW Vol Multiplier",        group=grp_atr, minval=0.5, maxval=5.0, step=0.1)
medMult     = input.float(2.5, "MED Vol Multiplier",        group=grp_atr, minval=0.5, maxval=5.0, step=0.1)
highMult    = input.float(3.5, "HIGH Vol Multiplier",       group=grp_atr, minval=0.5, maxval=5.0, step=0.1)
lowThresh   = input.float(0.8, "LOW Vol Threshold",         group=grp_atr, minval=0.1, maxval=1.0, step=0.05)
highThresh  = input.float(1.4, "HIGH Vol Threshold",        group=grp_atr, minval=1.0, maxval=3.0, step=0.05)
tssMinScore = input.int(40,    "Min Trend Score (0-100)",   group=grp_atr, minval=0,   maxval=100)
rsiSlopeLen = input.int(5,     "RSI Slope Bars",            group=grp_atr, minval=2,   maxval=20)
volSurgeLen = input.int(20,    "Volume MA Length",          group=grp_atr, minval=5,   maxval=100)

grp_dvp  = "Pressure Engine (Delta Volume)"
deltaMALen   = input.int(20,   "Delta MA Length",           group=grp_dvp, minval=2,  maxval=200)
volMALen     = input.int(20,   "DVP Volume MA Length",      group=grp_dvp, minval=5,  maxval=100)
minPressScore= input.int(40,   "Min Pressure Score (0-100)",group=grp_dvp, minval=0,  maxval=100)
rsiLen       = input.int(14,   "DVP RSI Length",            group=grp_dvp, minval=2,  maxval=50)
rsiOB        = input.int(70,   "RSI OB (block BUY)",        group=grp_dvp, minval=50, maxval=100)
rsiOS        = input.int(30,   "RSI OS (block SELL)",       group=grp_dvp, minval=0,  maxval=50)

grp_tm = "Trade Management"
tpPctTrail  = input.float(1.0, "Trail Engine TP %",         group=grp_tm, minval=0.05, maxval=20.0, step=0.05)
slPctTrail  = input.float(0.5, "Trail Engine SL %",         group=grp_tm, minval=0.05, maxval=20.0, step=0.05)
tpPctPress  = input.float(0.5, "Pressure Engine TP %",      group=grp_tm, minval=0.05, maxval=20.0, step=0.05)
slPctPress  = input.float(0.3, "Pressure Engine SL %",      group=grp_tm, minval=0.05, maxval=20.0, step=0.05)
tpMultATR   = input.float(3.0, "Trail TP ATR Multiplier",   group=grp_tm, minval=0.5, maxval=20.0, step=0.5)
maxBars     = input.int(50,    "Max Bars in Trade",         group=grp_tm, minval=5,   maxval=500)
cooldown    = input.int(3,     "Cooldown Bars",             group=grp_tm, minval=1,   maxval=100)
useTrailExit= input.bool(true, "Trail Flip Force Exit",     group=grp_tm)

grp_vis = "Visuals"
showTrail   = input.bool(true,  "Show Trail Line",          group=grp_vis)
showRegime  = input.bool(true,  "Show Regime Background",   group=grp_vis)
showCandles = input.bool(true,  "Pressure Candle Coloring", group=grp_vis)
showFill    = input.bool(true,  "Gradient Fill",            group=grp_vis)
showSig     = input.bool(true,  "Show Entry Labels",        group=grp_vis)
showTPSL    = input.bool(true,  "Show TP/SL Lines",         group=grp_vis)
showTradeBox= input.bool(true,  "Show Trade Boxes",         group=grp_vis)
showDash    = input.bool(true,  "Show Dashboard",           group=grp_vis)
showGhost   = input.bool(false, "Ghost Candles",            group=grp_vis)

color C_TEAL    = #00F5D4
color C_GOLD    = #FFD700
color C_BULL    = #00FF88
color C_BEAR    = #FF4466
color C_PURPLE  = #6C63FF
color C_MUTED   = color.new(#AAAAAA, 40)
color C_HDR_BG  = color.new(#0d1f1e,  0)
color C_COL_BG  = color.new(#0a0a14, 10)
color C_COL_ALT = color.new(#0d1117, 30)
color C_STRIPE  = color.new(#00F5D4, 20)

float atrRaw   = ta.atr(atrLen)
float atrSMA   = ta.sma(atrRaw, regLookback)
float atrRatio = not na(atrSMA) and atrSMA > 0 ? atrRaw / atrSMA : 1.0
bool  regLow   = atrRatio < lowThresh
bool  regHigh  = atrRatio > highThresh
bool  regMed   = not regLow and not regHigh
float activeMult = regLow ? lowMult : regHigh ? highMult : medMult
string regimeName = regLow ? "LOW ▼" : regHigh ? "HIGH ▲" : "MED  ●"
color  regimeCol  = regLow ? C_TEAL  : regHigh ? C_BEAR   : C_GOLD
color  regimeBG   = regLow ? color.new(#00F5D4, 97) : regHigh ? color.new(#FF4466, 97) : color.new(#FFD700, 97)
bgcolor(showRegime ? regimeBG : na, title="Volatility Regime")

float rsi14      = ta.rsi(atrSrc, 14)
float rsiNow     = rsi14
float rsiPrev    = rsi14[rsiSlopeLen]
float rsiSlope   = not na(rsiPrev) ? rsiNow - rsiPrev : 0.0
float rsiComp    = math.min(math.abs(rsiSlope) / 20.0, 1.0)
float volMA      = ta.sma(volume, volSurgeLen)
float volRatio   = not na(volMA) and volMA > 0 ? volume / volMA : 1.0
float volComp    = math.min(math.max(volRatio - 1.0, 0.0) / 1.5, 1.0)
float atrShort   = ta.sma(atrRaw, 5)
float atrExpand  = not na(atrShort) and atrShort > 0 ? atrRaw / atrShort : 1.0
float atrComp    = math.min(math.max(atrExpand - 1.0, 0.0) / 0.5, 1.0)
float tssScore   = (rsiComp * 0.40 + volComp * 0.35 + atrComp * 0.25) * 100
bool  tssWeak    = tssScore < 40
bool  tssMed     = tssScore >= 40 and tssScore < 70
bool  tssStrong  = tssScore >= 70
string scoreName = tssStrong ? "STRONG ✦" : tssMed ? "MEDIUM ◉" : "WEAK   ░"
color  scoreCol  = tssStrong ? C_BULL : tssMed ? C_GOLD : C_MUTED
float scoreTPBoost = tssStrong ? 1.2 : 1.0

var float trail    = na
var bool  trailUp  = true
var float prevTrail= na
var bool  prevUp   = true
float atrBand     = atrRaw * activeMult
float trailUpVal  = atrSrc - atrBand
float trailDnVal  = atrSrc + atrBand
float newTrailUp  = na
float newTrailDn  = na
if not na(trail)
    newTrailUp := math.max(trailUpVal, prevUp ? trail : trailUpVal)
    newTrailDn := math.min(trailDnVal, not prevUp ? trail : trailDnVal)
else
    newTrailUp := trailUpVal
    newTrailDn := trailDnVal
bool flipToBull = not na(trail) and not prevUp and close > trail
bool flipToBear = not na(trail) and prevUp     and close < trail
if flipToBull
    trailUp := true
    trail   := newTrailUp
else if flipToBear
    trailUp := false
    trail   := newTrailDn
else if trailUp
    trail   := newTrailUp
else
    trail   := newTrailDn
prevTrail := trail
prevUp    := trailUp
color trailColor = trailUp ? (regLow ? C_TEAL : regHigh ? C_BULL : C_BULL) : (regLow ? color.new(#00F5D4,40) : C_BEAR)
plot(showTrail ? trail : na, "ATR Trail", color=trailColor, linewidth=2, style=plot.style_linebr)

float rawDelta   = close >= open ? volume : -volume
var float cumDelta = 0.0
cumDelta += rawDelta
float deltaMA    = ta.sma(cumDelta, deltaMALen)
float volMAdvp   = ta.sma(volume, volMALen)
float volRatioDVP = not na(volMAdvp) and volMAdvp > 0 ? volume / volMAdvp : 1.0
float deltaRatio = volume > 0 ? rawDelta / volume : 0.0
float deltaComp  = math.abs(deltaRatio)
float volCompDVP = math.min(math.max(volRatioDVP - 1.0, 0.0) / 1.5, 1.0)
float totalRange = high - low
float bodySize   = math.abs(close - open)
float bodyComp   = totalRange > 0 ? math.min(bodySize / totalRange, 1.0) : 0.0
float pressScore = (deltaComp * 0.40 + volCompDVP * 0.35 + bodyComp * 0.25) * 100.0
bool  bullPressure = close >= open
bool  bearPressure = close < open

bool stStrongBull = bullPressure and pressScore >= 75
bool stBull       = bullPressure and pressScore >= 45 and pressScore < 75
bool stNeutral    = pressScore < 45
bool stBear       = bearPressure and pressScore >= 45 and pressScore < 75
bool stStrongBear = bearPressure and pressScore >= 75
string pressTxt = stStrongBull ? "STRONG BULL ✦" : stBull ? "BULL ▲" : stNeutral ? "NEUTRAL ◉" : stBear ? "BEAR ▼" : "STRONG BEAR ✦"
color  pressCol = stStrongBull ? color.new(#00F5D4, 0) : stBull ? color.new(#00FF88, 10) : stNeutral ? color.new(#AAAAAA, 40) : stBear ? color.new(#FF4466, 10) : color.new(#FF0044, 0)
barcolor(showCandles ? pressCol : na, title="Pressure Candle Color")

float fillAnchor = ta.vwap(hlc3)
bool  bullFill   = close > fillAnchor
p_close  = plot(showFill ? close     : na, "Close Ref",  display=display.none)
p_anchor = plot(showFill ? fillAnchor: na, "Anchor Ref", display=display.none)
fill(p_close, p_anchor,
     top_value    = bullFill ? close      : fillAnchor,
     bottom_value = bullFill ? fillAnchor : close,
     top_color    = bullFill ? color.new(C_TEAL, 55) : color.new(C_BEAR, 90),
     bottom_color = bullFill ? color.new(C_TEAL, 90) : color.new(C_BEAR, 55),
     title        = "Pressure Gradient Fill")

float rsi14dvp = ta.rsi(close, rsiLen)

var bool  g_inTrade   = false
var bool  g_isLong    = false
var int   g_engineUsed= 0
var int   entryBar    = 0
var float entryPrice  = na
var float g_tp        = na
var float g_sl        = na
var line  g_tpLine    = na
var line  g_slLine    = na
var box   tradeTpBox  = na
var box   tradeSlBox  = na
var label tradeLbl    = na
var int   lastSigBar  = 0

bool cdOK  = bar_index - lastSigBar >= cooldown
bool ready = not g_inTrade and cdOK and barstate.isconfirmed

bool trailEnabled    = engineMode == "TRAIL ONLY" or engineMode == "HYBRID"
bool pressEnabled    = engineMode == "PRESSURE ONLY" or engineMode == "HYBRID"
bool isHybrid        = engineMode == "HYBRID"

bool trailArmedRegime = isHybrid and hybridMode == "Regime Arms" ? (regHigh or regMed) : true
bool pressArmedRegime = isHybrid and hybridMode == "Regime Arms" ? (regLow  or regMed) : true

bool trailScoreOK = tssScore >= tssMinScore
bool trailRawBuy  = ready and trailEnabled and trailArmedRegime and not na(trail) and flipToBull and trailScoreOK
bool trailRawSell = ready and trailEnabled and trailArmedRegime and not na(trail) and flipToBear and trailScoreOK

bool pressScoreOK = pressScore >= minPressScore
bool deltaXup     = ta.crossover(cumDelta,  deltaMA)
bool deltaXdown   = ta.crossunder(cumDelta, deltaMA)
bool pressRawBuy  = ready and pressEnabled and pressArmedRegime and deltaXup   and pressScoreOK and rsi14dvp < rsiOB and bullPressure
bool pressRawSell = ready and pressEnabled and pressArmedRegime and deltaXdown and pressScoreOK and rsi14dvp > rsiOS and bearPressure

bool needConfluence = isHybrid and hybridMode == "Confluence Required"
bool buyConfluence  = needConfluence and trailRawBuy  and pressRawBuy
bool sellConfluence = needConfluence and trailRawSell and pressRawSell

bool buySignal  = false
bool sellSignal = false
int  engineId   = 0

if needConfluence
    if buyConfluence
        buySignal := true
        engineId  := 3
    if sellConfluence
        sellSignal := true
        engineId   := 3
else
    if trailRawBuy
        buySignal := true
        engineId  := 1
    else if pressRawBuy
        buySignal := true
        engineId  := 2
    if not buySignal
        if trailRawSell
            sellSignal := true
            engineId   := 1
        else if pressRawSell
            sellSignal := true
            engineId   := 2

if g_inTrade and barstate.isconfirmed
    bool tpHit    = g_isLong ? high >= g_tp : low  <= g_tp
    bool slHit    = g_isLong ? low  <= g_sl : high >= g_sl
    bool timeExit = (bar_index - entryBar) >= maxBars
    bool trailExit = useTrailExit and ((g_isLong and flipToBear) or (not g_isLong and flipToBull))

    if tpHit or slHit or timeExit or trailExit
        g_inTrade := false
        if not na(g_tpLine)
            line.delete(g_tpLine)
            g_tpLine := na
        if not na(g_slLine)
            line.delete(g_slLine)
            g_slLine := na
        if not na(tradeTpBox)
            box.delete(tradeTpBox)
            tradeTpBox := na
        if not na(tradeSlBox)
            box.delete(tradeSlBox)
            tradeSlBox := na

        float pnlPct = g_isLong ? (close - entryPrice) / entryPrice * 100 : (entryPrice - close) / entryPrice * 100
        string exitTxt = ""
        color  exitCol = C_MUTED
        if tpHit
            exitTxt := " ✦ TP +" + str.tostring(pnlPct, "#.##") + "% "
            exitCol := C_TEAL
        else if slHit
            exitTxt := " SL " + str.tostring(pnlPct, "#.##") + "% "
            exitCol := C_BEAR
        else if trailExit
            exitTxt := " ◈ TRAIL " + str.tostring(pnlPct, "#.##") + "% "
            exitCol := C_GOLD
        else
            exitTxt := " TIME " + str.tostring(pnlPct, "#.##") + "% "
            exitCol := C_GOLD

        label.new(bar_index, na, exitTxt,
             yloc=g_isLong ? yloc.abovebar : yloc.belowbar,
             style=g_isLong ? label.style_label_down : label.style_label_up,
             color=color.new(exitCol, 75), textcolor=exitCol, size=size.small,
             text_font_family=font.family_monospace)

bool useTrailLogic = (engineId == 1) or (engineId == 3 and tssScore >= pressScore)

if buySignal and not g_inTrade
    g_inTrade   := true
    g_isLong    := true
    g_engineUsed:= engineId
    entryBar    := bar_index
    entryPrice  := close
    lastSigBar  := bar_index

    if useTrailLogic
        float atrTP = close + atrRaw * tpMultATR * scoreTPBoost
        float atrSL = not na(trail) ? trail : close * (1 - slPctTrail / 100)
        g_tp := atrTP
        g_sl := atrSL
    else
        g_tp := close * (1 + tpPctPress / 100)
        g_sl := close * (1 - slPctPress / 100)

    if not na(g_tpLine)
        line.delete(g_tpLine)
    if not na(g_slLine)
        line.delete(g_slLine)
    if not na(tradeTpBox)
        box.delete(tradeTpBox)
    if not na(tradeSlBox)
        box.delete(tradeSlBox)
    if not na(tradeLbl)
        label.delete(tradeLbl)

    if showTPSL
        g_tpLine := line.new(bar_index, g_tp, bar_index + maxBars, g_tp, color=color.new(C_TEAL, 25), style=line.style_dashed, width=2)
        g_slLine := line.new(bar_index, g_sl, bar_index + maxBars, g_sl, color=color.new(C_BEAR, 40), style=line.style_dashed, width=1)

    if showTradeBox
        int x1 = bar_index, int x2 = bar_index + maxBars
        tradeTpBox := box.new(x1, g_tp,  x2, close, border_color=color.new(C_TEAL, 22), bgcolor=color.new(#00F5D4, 87), border_width=2)
        tradeSlBox := box.new(x1, close, x2, g_sl,  border_color=color.new(C_BEAR, 22), bgcolor=color.new(#FF4466, 87), border_width=2)

    if showSig
        float slDistL = math.max(math.abs(close - g_sl), syminfo.mintick)
        float rrL = math.abs(g_tp - close) / slDistL
        string engineTag = engineId == 1 ? "TRAIL" : engineId == 2 ? "PRESSURE" : "CONFLUENCE"
        tradeLbl := label.new(bar_index, low - atrRaw * 1.8,
             "▲ BUY " + engineTag + "  1:" + str.tostring(rrL, "#.##") + " RR\nTP " + str.tostring(g_tp, format.mintick) + "  IN " + str.tostring(close, format.mintick) + "  SL " + str.tostring(g_sl, format.mintick),
             yloc=yloc.price, style=label.style_label_up,
             color=color.new(#003322, 20), textcolor=C_BULL, size=size.normal, text_font_family=font.family_monospace)

if sellSignal and not g_inTrade
    g_inTrade   := true
    g_isLong    := false
    g_engineUsed:= engineId
    entryBar    := bar_index
    entryPrice  := close
    lastSigBar  := bar_index

    if useTrailLogic
        float atrTP = close - atrRaw * tpMultATR * scoreTPBoost
        float atrSL = not na(trail) ? trail : close * (1 + slPctTrail / 100)
        g_tp := atrTP
        g_sl := atrSL
    else
        g_tp := close * (1 - tpPctPress / 100)
        g_sl := close * (1 + slPctPress / 100)

    if not na(g_tpLine)
        line.delete(g_tpLine)
    if not na(g_slLine)
        line.delete(g_slLine)
    if not na(tradeTpBox)
        box.delete(tradeTpBox)
    if not na(tradeSlBox)
        box.delete(tradeSlBox)
    if not na(tradeLbl)
        label.delete(tradeLbl)

    if showTPSL
        g_tpLine := line.new(bar_index, g_tp, bar_index + maxBars, g_tp, color=color.new(C_TEAL, 25), style=line.style_dashed, width=2)
        g_slLine := line.new(bar_index, g_sl, bar_index + maxBars, g_sl, color=color.new(C_BEAR, 40), style=line.style_dashed, width=1)

    if showTradeBox
        int x1 = bar_index, int x2 = bar_index + maxBars
        tradeTpBox := box.new(x1, close, x2, g_tp, border_color=color.new(C_TEAL, 22), bgcolor=color.new(#00F5D4, 87), border_width=2)
        tradeSlBox := box.new(x1, g_sl,  x2, close, border_color=color.new(C_BEAR, 22), bgcolor=color.new(#FF4466, 87), border_width=2)

    if showSig
        float slDistS = math.max(math.abs(g_sl - close), syminfo.mintick)
        float rrS = math.abs(close - g_tp) / slDistS
        string engineTag = engineId == 1 ? "TRAIL" : engineId == 2 ? "PRESSURE" : "CONFLUENCE"
        tradeLbl := label.new(bar_index, high + atrRaw * 1.8,
             "▼ SELL " + engineTag + "  1:" + str.tostring(rrS, "#.##") + " RR\nTP " + str.tostring(g_tp, format.mintick) + "  IN " + str.tostring(close, format.mintick) + "  SL " + str.tostring(g_sl, format.mintick),
             yloc=yloc.price, style=label.style_label_down,
             color=color.new(#330000, 20), textcolor=C_BEAR, size=size.normal, text_font_family=font.family_monospace)

barcolor(showGhost ? color.new(color.gray, 80) : na)

plotshape(buySignal,  title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(#003322, 15), textcolor=C_BULL, size=size.small, text="BUY")
plotshape(sellSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(#330000, 15), textcolor=C_BEAR, size=size.small, text="SELL")

if showDash and barstate.islast
    string modeTxt   = engineMode
    color  modeCol   = engineMode == "HYBRID" ? C_PURPLE : engineMode == "TRAIL ONLY" ? C_TEAL : C_GOLD
    string armedTxt  = isHybrid ? (trailArmedRegime and pressArmedRegime ? "BOTH" : trailArmedRegime ? "TRAIL" : pressArmedRegime ? "PRESSURE" : "NONE") : engineMode == "TRAIL ONLY" ? "TRAIL" : "PRESSURE"
    color  armedCol  = armedTxt == "BOTH" ? C_PURPLE : armedTxt == "TRAIL" ? C_TEAL : armedTxt == "PRESSURE" ? C_GOLD : C_BEAR

    int    tssInt    = math.round(tssScore)
    int    tssFill   = math.round(tssScore / 100 * 8)
    string tssBar    = str.repeat("█", tssFill) + str.repeat("░", 8 - tssFill)

    int    pressInt  = math.round(pressScore)
    int    pressFill = math.round(pressScore / 100 * 8)
    string pressBar  = str.repeat("█", pressFill) + str.repeat("░", 8 - pressFill)

    string trailDir  = trailUp ? "BULL ▲" : "BEAR ▼"
    color  trailDCol = trailUp ? C_BULL : C_BEAR

    string deltaDir  = rawDelta >= 0 ? "BUY  +" : "SELL "
    color  deltaCol  = rawDelta >= 0 ? C_BULL : C_BEAR
    float  deltaPct  = deltaRatio * 100
    string deltaTxt  = deltaDir + str.tostring(math.abs(deltaPct), "#.#") + "%"

    string posTxt    = not g_inTrade ? "  FLAT  --" : g_isLong ? "LONG   ●" : "SHORT  ●"
    color  posCol    = not g_inTrade ? C_MUTED : g_isLong ? C_BULL : C_BEAR
    string engineLbl = not g_inTrade ? "—" : g_engineUsed == 1 ? "TRAIL" : g_engineUsed == 2 ? "PRESS" : "BOTH"
    color  engineLblCol = not g_inTrade ? C_MUTED : g_engineUsed == 1 ? C_TEAL : g_engineUsed == 2 ? C_GOLD : C_PURPLE

    string tpTxt   = not g_inTrade or na(g_tp) ? "--" : str.tostring(g_tp, format.mintick)
    string slTxt   = not g_inTrade or na(g_sl) ? "--" : str.tostring(g_sl, format.mintick)
    string cdTxt   = g_inTrade ? "IN TRADE" : bar_index - lastSigBar < cooldown ? "CD " + str.tostring(cooldown - (bar_index - lastSigBar)) + "b" : "READY ✅"
    color  cdCol   = g_inTrade ? C_GOLD : bar_index - lastSigBar < cooldown ? C_GOLD : C_BULL

    var table dash = table.new(position.bottom_center, 9, 5,
         bgcolor=C_COL_BG, border_width=1, border_color=color.new(C_TEAL, 55), frame_color=color.new(C_TEAL, 40), frame_width=2)

    for _c = 0 to 8
        table.cell(dash, _c, 0, "", bgcolor=C_STRIPE, text_size=size.tiny)
    table.cell(dash, 0, 0, " ◈ REGIME PRESSURE TRAIL ◈ ", text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 8, 0, " v1 ◈ ",                       text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)

    table.cell(dash, 0, 1, " ◈ MODE ",       text_color=modeCol,    text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 1, " ◈ ARMED ",      text_color=armedCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#0d1117, 30))
    table.cell(dash, 2, 1, " ◈ REGIME ",     text_color=regimeCol,  text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#0a0a20, 30))
    table.cell(dash, 3, 1, " ◈ TREND SCORE ",text_color=scoreCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 4, 1, " ◈ PRESSURE ",   text_color=pressCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#001a14, 30))
    table.cell(dash, 5, 1, " ◈ TRAIL ",      text_color=trailDCol,  text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 1, " ◈ DELTA ",      text_color=deltaCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 7, 1, " ◈ POSITION ",   text_color=posCol,     text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 1, " ◈ STATUS ",     text_color=cdCol,      text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

    table.cell(dash, 0, 2, " " + modeTxt,                                              text_color=modeCol,   text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 2, " " + armedTxt,                                             text_color=armedCol,  text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#0d1117, 40))
    table.cell(dash, 2, 2, " " + regimeName + " " + str.tostring(activeMult, "#.#") + "x", text_color=regimeCol, text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#0a0a20, 40))
    table.cell(dash, 3, 2, " " + tssBar + " " + str.tostring(tssInt),                  text_color=scoreCol,  text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 4, 2, " " + pressBar + " " + str.tostring(pressInt),              text_color=pressCol,  text_size=size.small, text_font_family=font.family_monospace, bgcolor=color.new(#001a14, 40))
    table.cell(dash, 5, 2, " " + trailDir,                                             text_color=trailDCol, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 2, " " + deltaTxt,                                             text_color=deltaCol,  text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_ALT)
    table.cell(dash, 7, 2, " " + posTxt + " " + engineLbl,                             text_color=posCol,    text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 2, " " + cdTxt,                                                text_color=cdCol,     text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

    table.cell(dash, 0, 3, " " + hybridMode,                                       text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 3, " Trail " + (trailArmedRegime ? "ON" : "OFF") + " Press " + (pressArmedRegime ? "ON" : "OFF"), text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 2, 3, " ATR " + str.tostring(atrRatio, "#.##") + "x avg",     text_color=color.new(regimeCol, 40), text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 3, 3, " " + scoreName + " min " + str.tostring(tssMinScore),  text_color=scoreCol, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 4, 3, " " + pressTxt + " min " + str.tostring(minPressScore), text_color=pressCol, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 5, 3, " " + (not na(trail) ? str.tostring(trail, format.mintick) : "—"), text_color=color.new(trailDCol, 40), text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 3, " RSI " + str.tostring(rsi14dvp, "#.#"),                text_color=rsi14dvp > rsiOB ? C_BEAR : rsi14dvp < rsiOS ? C_BULL : C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 7, 3, " Used " + engineLbl,                                   text_color=engineLblCol, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 3, " CD " + str.tostring(cooldown) + "b MAX " + str.tostring(maxBars) + "b", text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

    table.cell(dash, 0, 4, " TRADE MGT",         text_color=C_TEAL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_HDR_BG)
    table.cell(dash, 1, 4, " " + posTxt,         text_color=posCol, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 2, 4, " E " + (g_inTrade and not na(entryPrice) ? str.tostring(entryPrice, format.mintick) : "--"), text_color=C_TEAL, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 3, 4, " TP " + tpTxt,       text_color=C_BULL, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 4, 4, " SL " + slTxt,       text_color=C_BEAR, text_size=size.small, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 5, 4, " Bars " + (g_inTrade ? str.tostring(bar_index - entryBar) : "--") + "/" + str.tostring(maxBars), text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 6, 4, " ATR " + str.tostring(atrRaw, format.mintick),         text_color=C_MUTED, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 7, 4, " VWAP " + str.tostring(fillAnchor, format.mintick),    text_color=C_GOLD, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)
    table.cell(dash, 8, 4, " ATR " + str.tostring(activeMult, "#.#") + "x " + regimeName, text_color=regimeCol, text_size=size.tiny, text_font_family=font.family_monospace, bgcolor=C_COL_BG)

alertcondition(buySignal,                            "RPT BUY",            "Regime Pressure Trail BUY")
alertcondition(sellSignal,                           "RPT SELL",           "Regime Pressure Trail SELL")
alertcondition(buySignal  and engineId == 1,         "RPT BUY (Trail)",    "Regime Pressure Trail BUY — Trail engine")
alertcondition(sellSignal and engineId == 1,         "RPT SELL (Trail)",   "Regime Pressure Trail SELL — Trail engine")
alertcondition(buySignal  and engineId == 2,         "RPT BUY (Pressure)", "Regime Pressure Trail BUY — Pressure engine")
alertcondition(sellSignal and engineId == 2,         "RPT SELL (Pressure)","Regime Pressure Trail SELL — Pressure engine")
alertcondition(buySignal  and engineId == 3,         "RPT BUY (Confluence)",  "Regime Pressure Trail BUY — Both engines agree")
alertcondition(sellSignal and engineId == 3,         "RPT SELL (Confluence)", "Regime Pressure Trail SELL — Both engines agree")
alertcondition(regLow  and not regLow[1],            "Regime → LOW",       "Volatility regime dropped to LOW")
alertcondition(regHigh and not regHigh[1],           "Regime → HIGH",      "Volatility regime spiked to HIGH")
````
