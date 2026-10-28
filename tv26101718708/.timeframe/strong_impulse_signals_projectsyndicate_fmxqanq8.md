# Strong Impulse Signals | ProjectSyndicate

- url: https://www.tradingview.com/script/FmXQanQ8-Strong-Impulse-Signals-ProjectSyndicate/
- type: indicator
- pine_id: PUB;e898bbe55e274a519dd7409e6f3d4f3e
- version: 1.0

## Description

Strong Impulse Signals catches the moment a market stops coiling and commits — then fires WITH the thrust instead of fading it. Markets compress into tight bases, then release: a single displacement candle expands far beyond its recent range, dominates its own body, closes hard at its extreme, and breaks the micro-structure that was capping price. That ignition is the event. The engine measures the energy stored in that thrust as a 0–10 Propulsion Strength and fires in the direction the move is already going — with the breakout, not against it. Every setup gets a structural invalidation level behind the launch, fixed R-based targets, a 0–10 strength with a 1–5 star rank, and is tracked live on a full statistics dashboard — including honest stop-outs — so you can see exactly how the logic behaves on the symbol and timeframe you trade.

🧠 Impulse Core — the core idea, expressed as a lifecycle: COIL ▸ IGNITION ▸ BREAK ▸ THRUST ▸ TARGET. Confirmed swing pivots define the micro-structure the move has to break. A coil forms when the recent range winds tight — a loaded spring. Ignition is a displacement candle: its range must clear your ATR threshold, its body must dominate the bar, it must close in the top (long) or bottom (short) fraction of its own range, and — when enabled — it must break the most recent swing high or low. When that candle fires, the signal fires WITH it, in the direction it expanded. Pivots come from confirmed swings and every condition is evaluated on the bar's close, so the structure and the signal do not repaint.

🔋 Strength Anatomy — an ignition is not just true or false; it is scored for how much thrust it carries. The Propulsion Strength fuses breakout-native ingredients into a single 0–10 read: displacement (how far the candle's range expanded in ATR — the heart of an impulse), body dominance (clean thrust versus wick), close-in-range (did it close at its extreme rather than fade back), momentum run (net directional displacement over the run window plus consecutive same-direction closes), volume thrust (the spike over a rolling baseline), velocity / acceleration (is short-term ROC still expanding), loaded coil release (did it launch from a compressed base), structure-break confirmation, and trend / HTF alignment. Each ingredient contributes to the 0–10 total, and you shape what qualifies through the ignition thresholds and requirement toggles rather than chasing a single number.

🎯 Structural Invalidation + R-Based Targets — the stop is anchored to the launch, not guessed. Choose the Stop Basis: Structural sits behind the leg origin (the launch swing over the run window); Ignition Bar sits behind the trigger candle's own extreme. An ATR buffer adds cushion beyond that anchor, and the distance is then clamped between an ATR floor and an ATR ceiling — so a structural stop never balloons into a wide stop, and the 1R target never collapses into a tight TP. TP1, TP2, and TP3 are set at clean R multiples, defaulting to a balanced 1R / 2R / 3R and fully adjustable to your reward profile. Every signal plots its complete Entry / SL / TP1 / TP2 / TP3 line set, labeled level prices, and filled TP / SL zone boxes, with a result label on exit — and the zones are width-capped so long trades never draw towering boxes.

🚀 Rocket Power Stack — because the whole point of an impulse is the size of the thrust, each signal can stack a column of 🚀 in the direction of the move: from 5 rockets (weak) up to 10 (elite), scaled to the strength score, so the raw power of the thrust reads at a glance without checking the number. A left-offset control keeps the stack clear of the SL / TP zone box. It is a visual conviction read that sits alongside the numeric score and stars.

🎚️ Conviction Controls — a compact set of dials sets how serious an ignition must be before it counts: the Min Strength To Signal (the 0–10 floor to fire at all), a Strong Threshold with an optional Only Show Strong Signals filter, the Ignition Range in ATR (the core displacement test), the Min Body Dominance, the Close-In-Range Strength, the Require Structure Break switch, the Require Coil Release switch, and the Require Volume Thrust switch with its multiplier and baseline. Tighten them for fewer, cleaner impulses; loosen them for more activity. This is your main control over conviction versus frequency.

🧭 Trend Gating & Single-Ticket Discipline — where a fade tool blocks trend, this engine leans into it. HTF Trend Alignment permits only long impulses above the higher-timeframe EMA and only short impulses below it, so counter-trend thrusts are filtered out; alignment here is the edge, not the enemy. A Signal Cooldown enforces a minimum gap between entries so one violent session can't stack overlapping trades, and only one ticket is active at a time. Resolution is SL-first pessimistic with honest partial-TP accounting — if a stop is hit after TP1 or TP2, that partial result is booked rather than rounded up.

⭐ 0–10 Strength with Star Tiers — every signal is labeled with its numeric strength, a 1–5 star rank, and a tier ladder running FORMING → WEAK → MODERATE → STRONG → VERY STRONG → ELITE, with a ⚡COIL tag flagging impulses that launched from a compressed base. Treat the strength as a cleanliness and confluence read for ranking and thinning setups — it describes how textbook an ignition is, not a guaranteed outcome. The Min Strength and Only-Strong gate restrict what is displayed and alerted, while the dashboard keeps tracking every tier in the background.

📊 Live Statistics Dashboard — a non-intrusive panel tracks, in real time on your chart: the current status (waiting → trade active) and the active trade side, the last signal with its star score and ⚡COIL flag, a Live Propulsion read with separate long- and short-impulse strength, component meters for Displacement, Volume Thrust, Momentum Run, and Coil Charge, total signals, win rate, closed trades, profit factor, average R per trade, best-performing direction, long vs short win rate, current and max win/loss streaks, and a TP1 / TP2 / TP3 / SL outcome breakdown. Every filled trade that reaches an outcome is counted — winners and stop-outs alike — so the numbers are computed live from the real signals on your current symbol and timeframe, not a figure printed in a description.

🎨 Clean Themed Visuals — four coherent palettes (Emerald default, plus Ice Blue, Gold Black, and Aqua Violet) shade the ⚡ signal labels, the BUY / SELL arrows, the per-trade SL / TP ladder and zone boxes, the rocket power stack, and the dashboard to one look, so direction and quality read at a glance. Each ignition prints a ⚡ impulse label with its strength, star tier, and direction, plus a crisp BUY or SELL arrow at the bar. The active ticket extends live to the right and then snaps cleanly back to its exit bar on close, so labels never float away — and a max-drawn-trades cap keeps only the most recent tickets on the chart while the statistics stay cumulative over the full history.

🔔 Detailed Alerts — fires on a Strong Long Impulse, a Strong Short Impulse, any impulse, and on TP3 Hit, Partial TP Exit, and SL events, formatted for manual or automated use. The strength gate can restrict alerts to higher-conviction impulses.

🔧 Fully Customizable — every component is exposed: the structure pivot period that defines which swings count; the ignition range, min body dominance, close-in-range strength, momentum run window, and the structure-break requirement; the coil lookback and tightness reference, the coil-release requirement, and the volume-thrust requirement with its multiplier and baseline; the min-strength floor, the strong threshold, and the only-strong filter; the ATR length, stop basis, stop buffer, the max-risk cap and min-risk floor, and the three R targets; the level-shelf length, max zone width, and max historical trades; the HTF alignment, its timeframe and EMA length, and the signal cooldown; all four themes; and every signal label, BUY/SELL arrow, star, rocket, line, box, and dashboard toggle.

🎯 Why this is different — most momentum tools just color a candle or flag a breakout after it has already run. This one treats the ignition itself as the event, scores how much thrust that displacement stored across range, body, close, run, volume, acceleration, coil release, structure break, and trend, and fires WITH the move — riding the thrust the way price actually tends to extend — then anchors invalidation behind the launch, ranks every impulse on an objective 0–10 scale, and layers a live, honest statistics panel that counts stop-outs in full. You tune and judge it on real, current data from your own chart instead of a marketing number.

🚀 Where to use it — the engine is symbol-agnostic and built on universal behavior: displacement and breakouts happen in every liquid market, so it can be applied to FX majors and crosses, metals, indices, and crypto, on intraday timeframes. Pivot length and the ATR-based stop adapt to each instrument's volatility automatically. Because it is a momentum-continuation engine, it shines in trending and expanding-volatility conditions and demands more care in dead, choppy ranges where thrusts stall and reverse — let the dashboard tell you whether the logic suits the pair and timeframe before you commit.

🎯 How to trade it

Apply it to a liquid symbol on an intraday timeframe and let the dashboard populate. Read the live win rate, profit factor, and average R for your symbol and timeframe first — if the logic doesn't suit that market, you'll see it.
Wait for a ⚡ LONG / ⚡ SHORT impulse label and its BUY / SELL arrow — it marks a confirmed close through an ignition candle that broke structure, with the strength, star tier, and full Entry / SL / TP1 / TP2 / TP3 already plotted.
Read the rocket stack and ⚡COIL tag for a fast conviction check — more rockets and a coil launch mean a cleaner, more loaded thrust.
Manage the trade with the plotted levels — the ATR-clamped structural stop defines your risk and TP1/2/3 sit at your chosen R multiples. Bank or trail however suits your style.
Use HTF Trend Alignment, the Signal Cooldown, the Min-Strength floor, and the six ignition requirements to set your tempo — stricter for fewer, cleaner impulses; looser for more activity — and lean on the star tier to focus on the most textbook thrusts.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. Default settings were chosen on historical data and behavior will vary by symbol, timeframe, session, and configuration; the dashboard's statistics are historical and descriptive, not a forecast. The trade model resolves stop-first and books partial-target exits honestly, so some trades close for a fraction of a target rather than a full win or loss — these are counted in full, which is honest but means win rate alone is misleading; always weigh it together with average R and profit factor, and resize the R targets to your own risk profile. Signals confirm on the closed bar, so always wait for the labeled impulse on a closed candle. Because the system trades WITH momentum, a false breakout or a sharp reversal can run straight through a stop — combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6

indicator("Strong Impulse Signals", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

gEng = "01 · Impulse Engine"
pivLen       = input.int(5,    "Structure Pivot Period",  minval = 2,  maxval = 50,  group = gEng, tooltip = "Bars each side for the swing high/low that the ignition candle must break. Larger = fewer, more significant impulses.")
dispAtr      = input.float(1.3, "Ignition Range (× ATR)", minval = 0.3, maxval = 6.0, step = 0.1, group = gEng, tooltip = "The ignition candle's range must be at least this many ATRs. The core displacement test.")
minBody      = input.float(0.55,"Min Body Dominance",     minval = 0.2, maxval = 1.0, step = 0.05, group = gEng, tooltip = "Body / range of the ignition candle. Higher = cleaner thrust, less wick.")
closePos     = input.float(0.60,"Close-In-Range Strength",minval = 0.5, maxval = 1.0, step = 0.05, group = gEng, tooltip = "Ignition close must land in the top (long) / bottom (short) fraction of its own range. Confirms the bar closed strong.")
runLen       = input.int(5,    "Momentum Run Window",     minval = 2,  maxval = 30,  group = gEng, tooltip = "Window used to measure net directional displacement and the consecutive-close run.")
reqStruct    = input.bool(true, "Require Structure Break", group = gEng, tooltip = "Ignition must break the most recent swing high (long) / low (short).")

gCtx = "02 · Propulsion Context"
coilLen      = input.int(10,   "Coil Lookback",           minval = 3,  maxval = 60,  group = gCtx, tooltip = "Bars used to measure pre-impulse compression. A thrust out of a tight coil scores higher (loaded spring).")
coilMaxAtr   = input.float(3.0,"Coil Tightness (× ATR)",  minval = 0.5, maxval = 12.0, step = 0.1, group = gCtx, tooltip = "The coil's range (in ATR) at/below which the base counts as 'compressed'. Smaller = stricter coil.")
reqCoil      = input.bool(false,"Require Coil Release",    group = gCtx, tooltip = "Only fire impulses that launch from a compressed base.")
useVol       = input.bool(true, "Require Volume Thrust",  group = gCtx, tooltip = "Ignition volume must exceed its moving average × multiplier.")
volMult      = input.float(1.3, "Volume Thrust (× SMA)",  minval = 1.0, maxval = 5.0, step = 0.1, group = gCtx)
volLen       = input.int(20,   "Volume SMA Length",       minval = 2,  maxval = 200, group = gCtx)

gStr = "03 · Strength Filter"
minStr       = input.float(4.0, "Min Strength To Signal (0-10)", minval = 0, maxval = 10, step = 0.5, group = gStr, tooltip = "Reject impulses scoring below this on the 0-10 propulsion engine.")
onlyStrong   = input.bool(false,"Only Show Strong Signals", group = gStr)
strongThr    = input.float(7.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)

gTrade = "04 · Trade Levels"
atrLen       = input.int(14,  "ATR Length", minval = 1, group = gTrade)
slMode       = input.string("Structural", "Stop Basis", options = ["Structural", "Ignition Bar"], group = gTrade, tooltip = "Structural = beyond the launch swing. Ignition Bar = beyond the trigger candle's extreme.")
slBufAtr     = input.float(0.30,"Stop Buffer (× ATR)",   minval = 0.0, maxval = 3.0, step = 0.05, group = gTrade, tooltip = "Extra ATR cushion beyond the stop anchor.")
maxRiskAtr   = input.float(4.0, "Max Risk (ATR) — stop cap",  minval = 0.5, maxval = 12.0, step = 0.1, group = gTrade, tooltip = "Hard cap on stop distance so a structural stop never becomes a 'wide stop'.")
minRiskAtr   = input.float(0.5, "Min Risk (ATR) — stop floor", minval = 0.1, maxval = 6.0,  step = 0.1, group = gTrade, tooltip = "Floor on stop distance so the 1R target never becomes a 'tight TP'.")
tp1R         = input.float(1.0, "TP1 (R)", minval = 0.5, maxval = 50, step = 0.1, group = gTrade)
tp2R         = input.float(2.0, "TP2 (R)", minval = 0.5, maxval = 50, step = 0.1, group = gTrade)
tp3R         = input.float(3.0, "TP3 (R)", minval = 0.5, maxval = 50, step = 0.1, group = gTrade)
levelLen     = input.int(12,  "Level Shelf (bars)", minval = 2, maxval = 500, group = gTrade, tooltip = "Forward shelf length for live SL/TP labels. On close the ticket snaps back to the exit bar.")
maxZonePct   = input.float(20.0,"Max Zone Width (% of trade span)", minval = 2, maxval = 100, step = 1, group = gTrade, tooltip = "Caps how far SL/TP/Entry zones extend right, as a % of bars elapsed since entry. Kills super-wide 'tower' zones on long trades.")
showLines    = input.bool(true, "Show SL / TP Lines", group = gTrade)
showBoxes    = input.bool(true, "Show SL / TP Zones", group = gTrade)
showLevelLbl = input.bool(true, "Label Level Prices", group = gTrade)
showExitLbl  = input.bool(true, "Show Trade Result Labels", group = gTrade)
maxHist      = input.int(30,  "Max Historical Trades", minval = 1, maxval = 80, group = gTrade)

gFilt = "05 · Filters"
useHtf       = input.bool(true,  "HTF Trend Alignment (block counter-trend)", group = gFilt, tooltip = "Only LONG impulses above the HTF EMA, only SHORT below it.")
htfTF        = input.timeframe("240", "HTF Timeframe", group = gFilt)
htfEmaLen    = input.int(50, "HTF EMA Length", minval = 5, maxval = 500, group = gFilt)
useCooldown  = input.bool(true, "Use Signal Cooldown", group = gFilt)
cooldownBars = input.int(10, "Cooldown Bars", minval = 1, maxval = 500, group = gFilt, tooltip = "Minimum bars between consecutive entries.")

gVis = "06 · Visuals"
theme        = input.string("Emerald", "Color Theme", options = ["Emerald", "Ice Blue", "Gold Black", "Aqua Violet"], group = gVis)
showSignal   = input.bool(true, "Show Signal Labels", group = gVis)
showArrows   = input.bool(true, "Show BUY / SELL Arrows", group = gVis)
showStars    = input.bool(true, "Show ★ Ranking On Labels", group = gVis)
showRockets  = input.bool(true, "Show Rocket Power Stack", group = gVis, tooltip = "Stacks 5–10 🚀 in the impulse direction, scaled to strength, so the power of the thrust is visible at a glance.")
rocketOffset = input.int(4, "Rocket Stack Left Offset (bars)", minval = 0, maxval = 50, group = gVis, tooltip = "Pushes the 🚀 stack this many bars left of the signal so it clears the SL/TP zone box.")
lblSizeOpt   = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVis)

gDash = "07 · Dashboard"
showDash     = input.bool(true, "Show Dashboard", group = gDash)
dashPosOpt   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSizeOpt  = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)
showMeter    = input.bool(true, "Show Live Propulsion Meters", group = gDash)
showHeatRow  = input.bool(true, "Show Per-Target Breakdown", group = gDash)

longCol  = theme == "Ice Blue" ? color.rgb(0, 190, 255)  : theme == "Gold Black" ? color.rgb(255, 196, 48) : theme == "Aqua Violet" ? color.rgb(0, 230, 200) : color.rgb(0, 200, 120)
shortCol = theme == "Ice Blue" ? color.rgb(255, 120, 70) : theme == "Gold Black" ? color.rgb(255, 78, 60)  : theme == "Aqua Violet" ? color.rgb(180, 110, 255) : color.rgb(235, 64, 64)
tpFill   = theme == "Ice Blue" ? color.rgb(0, 90, 130)   : theme == "Gold Black" ? color.rgb(96, 74, 0)    : theme == "Aqua Violet" ? color.rgb(0, 95, 90)     : color.rgb(0, 96, 60)
slFill   = theme == "Ice Blue" ? color.rgb(150, 30, 70)  : theme == "Gold Black" ? color.rgb(150, 40, 18)  : theme == "Aqua Violet" ? color.rgb(110, 30, 120)  : color.rgb(150, 22, 30)

color panelBg     = #0a0c12
color panelBgAlt  = #0f131c
color panelHdr    = #161b27
color panelBorder = #2c3342
color txtHi       = #ebeef5
color txtLo       = #8791a2
color neutralCol  = #69748a
color goodCol     = #21c87a
color badCol      = #e6435a

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

f_stars(float sc) => sc >= 8.5 ? "★★★★★" : sc >= 7 ? "★★★★" : sc >= 5.5 ? "★★★" : sc >= 4 ? "★★" : sc >= 2.5 ? "★" : "·"
f_tier(float sc)  => sc >= 8.5 ? "ELITE" : sc >= 7 ? "VERY STRONG" : sc >= 5.5 ? "STRONG" : sc >= 4 ? "MODERATE" : sc >= 2.5 ? "WEAK" : "FORMING"
f_signedR(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

f_rockets(float sc) =>
    int n = math.min(10, math.max(5, 5 + int(math.round(sc / 2.0))))
    string s = ""
    for i = 1 to n
        s += i < n ? "🚀\n" : "🚀"
    s
f_zone_base(bool isBull) => isBull ? longCol : shortCol

f_meter(float score) =>
    int n = math.min(math.max(int(math.round(score)), 0), 10)
    string s = ""
    for i = 1 to 10
        s += i <= n ? "█" : "░"
    s

f_meterCol(float sc) =>
    sc >= 7.0 ? goodCol : sc >= 4.0 ? color.rgb(120, 210, 90) : sc >= 2.0 ? color.rgb(225, 195, 70) : neutralCol

atr      = ta.atr(atrLen)
safeAtr  = math.max(nz(atr, high - low), syminfo.mintick)
rsi      = ta.rsi(close, 14)
volSma   = ta.sma(volume, volLen)
volRatio = volSma > 0 ? volume / volSma : 1.0

candleRng = high - low
body      = math.abs(close - open)
bodyRatio = candleRng > 0 ? body / candleRng : 0.0
rngAtr    = candleRng / safeAtr
closeInRng = candleRng > 0 ? (close - low) / candleRng : 0.5

netMove   = close - close[runLen]
netMoveA  = netMove / safeAtr
upClose   = close > close[1]
dnClose   = close < close[1]
var int runUp = 0
var int runDn = 0
runUp := upClose ? runUp + 1 : 0
runDn := dnClose ? runDn + 1 : 0

roc3      = close - close[3]
roc3Prev  = close[1] - close[4]
accelUp   = roc3 > 0 and roc3 > roc3Prev
accelDn   = roc3 < 0 and roc3 < roc3Prev

coilHi   = ta.highest(high, coilLen)[1]
coilLo   = ta.lowest(low,  coilLen)[1]
coilAtr  = (coilHi - coilLo) / safeAtr
coilTight = coilAtr <= coilMaxAtr

emaFast  = ta.ema(close, 21)
emaUp    = emaFast > emaFast[2]
emaDn    = emaFast < emaFast[2]

htfEma   = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaLen)[1], lookahead = barmerge.lookahead_off)
htfBull  = not useHtf or na(htfEma) or close > htfEma
htfBear  = not useHtf or na(htfEma) or close < htfEma

ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)

var float lastSH    = na
var int   lastSHbar = na
var float lastSL    = na
var int   lastSLbar = na

if not na(ph)
    lastSH    := ph
    lastSHbar := bar_index - pivLen
if not na(pl)
    lastSL    := pl
    lastSLbar := bar_index - pivLen

f_impulse_strength(bool isBull, float rngA, float bdy, float cInR, float netA, int run, float volR, bool accel, bool coil, bool structBreak, bool emaAlign, bool htfAlign) =>
    s = 0.0
    s += rngA >= 2.5 ? 2.5 : rngA >= 1.8 ? 1.9 : rngA >= 1.3 ? 1.3 : rngA >= 1.0 ? 0.8 : 0.3
    s += bdy >= 0.85 ? 1.5 : bdy >= 0.70 ? 1.1 : bdy >= 0.55 ? 0.7 : 0.3
    float ce = isBull ? cInR : 1.0 - cInR
    s += ce >= 0.85 ? 1.0 : ce >= 0.70 ? 0.7 : ce >= 0.60 ? 0.4 : 0.0
    float na2 = math.abs(netA)
    s += na2 >= 3.0 ? 1.0 : na2 >= 2.0 ? 0.7 : na2 >= 1.2 ? 0.4 : 0.0
    s += run >= 4 ? 0.5 : run >= 3 ? 0.3 : 0.0
    s += volR >= 2.5 ? 1.5 : volR >= 2.0 ? 1.1 : volR >= 1.5 ? 0.7 : volR >= 1.3 ? 0.4 : 0.0
    s += accel ? 0.5 : 0.0
    s += coil ? 0.8 : 0.0
    s += structBreak ? 0.7 : 0.0
    s += emaAlign and htfAlign ? 0.5 : emaAlign or htfAlign ? 0.25 : 0.0
    math.max(0.0, math.min(10.0, math.round(s * 10) / 10))

structBull = not na(lastSH) and close > lastSH
structBear = not na(lastSL) and close < lastSL

igniteBull = close > open and rngAtr >= dispAtr and bodyRatio >= minBody and closeInRng >= closePos and (not reqStruct or structBull) and (not reqCoil or coilTight) and (not useVol or volRatio >= volMult)
igniteBear = close < open and rngAtr >= dispAtr and bodyRatio >= minBody and (1.0 - closeInRng) >= closePos and (not reqStruct or structBear) and (not reqCoil or coilTight) and (not useVol or volRatio >= volMult)

legLowA  = ta.lowest(low,  runLen)
legHighA = ta.highest(high, runLen)

bullStr = igniteBull ? f_impulse_strength(true,  rngAtr, bodyRatio, closeInRng, netMoveA, runUp, volRatio, accelUp, coilTight, structBull, emaUp, htfBull) : 0.0
bearStr = igniteBear ? f_impulse_strength(false, rngAtr, bodyRatio, closeInRng, netMoveA, runDn, volRatio, accelDn, coilTight, structBear, emaDn, htfBear) : 0.0

var bool  tradeActive = false
var int   tradeSide   = 0
var int   tradeBar    = na
var float tEntry      = na
var float tStop       = na
var float tTp1        = na
var float tTp2        = na
var float tTp3        = na
var int   bestStage   = 0
var float tradeScore  = na
var int   lastSigBar  = na
var int   lastSigSide = 0
var bool  lastCoil    = false

cooldownOk = not useCooldown or na(lastSigBar) or (bar_index - lastSigBar >= cooldownBars)

okBull = igniteBull and bullStr >= minStr and (not onlyStrong or bullStr >= strongThr) and htfBull and cooldownOk and not tradeActive
okBear = igniteBear and bearStr >= minStr and (not onlyStrong or bearStr >= strongThr) and htfBear and cooldownOk and not tradeActive

sigLong  = okBull and (not okBear or bullStr >= bearStr)
sigShort = okBear and (not okBull or bearStr >  bullStr)

var line  aEntry = na
var line  aSl    = na
var line  aT1    = na
var line  aT2    = na
var line  aT3    = na
var box   aTpBox = na
var box   aSlBox = na
var label aRkt   = na
var label aSig   = na
var label aLEntry= na
var label aLSl   = na
var label aLT1   = na
var label aLT2   = na
var label aLT3   = na
var label aExit  = na

type tradeViz
    line  e   = na
    line  s   = na
    line  t1  = na
    line  t2  = na
    line  t3  = na
    box   tb  = na
    box   sb  = na
    label rk  = na
    label sg  = na
    label le  = na
    label ls  = na
    label l1  = na
    label l2  = na
    label l3  = na
    label ex  = na

var array<tradeViz> history = array.new<tradeViz>()

var int   sClosed   = 0
var int   sTp1      = 0
var int   sTp2      = 0
var int   sTp3      = 0
var int   sSl       = 0
var int   sWins     = 0
var float sR        = 0.0
var float sGrossWin = 0.0
var float sGrossLos = 0.0
var int   sMaxWin   = 0
var int   sMaxLos   = 0
var int   sCurWin   = 0
var int   sCurLos   = 0
var int   sStreak   = 0
var int   sLong     = 0
var int   sLongWin  = 0
var int   sShort    = 0
var int   sShortWin = 0
var int   sTotalSig = 0

int   _liveSpan = tradeActive and not na(tradeBar) ? bar_index - tradeBar : 0
int   _liveCap  = int(math.round(_liveSpan * maxZonePct / 100))
aRight = tradeActive and not na(tradeBar) ? tradeBar + math.max(levelLen, _liveCap) : na
if tradeActive
    if showLines
        if not na(aEntry)
            line.set_x2(aEntry, aRight)
        if not na(aSl)
            line.set_x2(aSl, aRight)
        if not na(aT1)
            line.set_x2(aT1, aRight)
        if not na(aT2)
            line.set_x2(aT2, aRight)
        if not na(aT3)
            line.set_x2(aT3, aRight)
        if showLevelLbl
            if not na(aLEntry)
                label.set_x(aLEntry, aRight)
            if not na(aLSl)
                label.set_x(aLSl, aRight)
            if not na(aLT1)
                label.set_x(aLT1, aRight)
            if not na(aLT2)
                label.set_x(aLT2, aRight)
            if not na(aLT3)
                label.set_x(aLT3, aRight)
    if showBoxes
        if not na(aTpBox)
            box.set_right(aTpBox, aRight)
        if not na(aSlBox)
            box.set_right(aSlBox, aRight)

closedTp3 = false
closedSl  = false
closedTp  = false

if tradeActive
    bool tp1Hit = tradeSide == 1 ? high >= tTp1 : low <= tTp1
    bool tp2Hit = tradeSide == 1 ? high >= tTp2 : low <= tTp2
    bool tp3Hit = tradeSide == 1 ? high >= tTp3 : low <= tTp3
    bool slHit  = tradeSide == 1 ? low  <= tStop : high >= tStop

    int stage = tp3Hit ? 3 : tp2Hit ? 2 : tp1Hit ? 1 : 0
    bool sameBarSl = slHit and stage > 0
    if stage > bestStage and not sameBarSl
        bestStage := stage

    bool finalTp3 = not sameBarSl and bestStage == 3
    bool finalSl  = slHit and (bestStage == 0 or sameBarSl)
    bool finalTp  = slHit and not sameBarSl and bestStage > 0 and bestStage < 3

    if finalTp3 or finalSl or finalTp
        closedTp3 := finalTp3
        closedSl  := finalSl
        closedTp  := finalTp
        float resR = finalTp3 ? tp3R : finalTp and bestStage == 2 ? tp2R : finalTp and bestStage == 1 ? tp1R : -1.0

        bool isWin = resR > 0
        sClosed += 1
        sR      += resR
        if isWin
            sWins   += 1
            sGrossWin += resR
            sCurWin += 1
            sCurLos := 0
            sMaxWin := math.max(sMaxWin, sCurWin)
            sStreak := sCurWin
        else
            sGrossLos += 1.0
            sCurLos += 1
            sCurWin := 0
            sMaxLos := math.max(sMaxLos, sCurLos)
            sStreak := -sCurLos
        if tradeSide == 1
            sLong += 1
            sLongWin += isWin ? 1 : 0
        else
            sShort += 1
            sShortWin += isWin ? 1 : 0
        if finalTp3
            sTp3 += 1
        else if finalTp and bestStage == 2
            sTp2 += 1
        else if finalTp and bestStage == 1
            sTp1 += 1
        else if finalSl
            sSl += 1

        int _clSpan   = not na(tradeBar) ? bar_index - tradeBar : 0
        int _clCap    = int(math.round(_clSpan * maxZonePct / 100))
        int closeEdge = tradeBar + math.max(3, _clCap)
        if showLines
            if not na(aEntry)
                line.set_x2(aEntry, closeEdge)
            if not na(aSl)
                line.set_x2(aSl, closeEdge)
            if not na(aT1)
                line.set_x2(aT1, closeEdge)
            if not na(aT2)
                line.set_x2(aT2, closeEdge)
            if not na(aT3)
                line.set_x2(aT3, closeEdge)
        if showBoxes
            if not na(aTpBox)
                box.set_right(aTpBox, closeEdge)
            if not na(aSlBox)
                box.set_right(aSlBox, closeEdge)
        if showLevelLbl
            if not na(aLEntry)
                label.set_x(aLEntry, closeEdge)
            if not na(aLSl)
                label.set_x(aLSl, closeEdge)
            if not na(aLT1)
                label.set_x(aLT1, closeEdge)
            if not na(aLT2)
                label.set_x(aLT2, closeEdge)
            if not na(aLT3)
                label.set_x(aLT3, closeEdge)

        int    rStage   = finalTp3 ? 3 : finalTp ? bestStage : 0
        float  resPrice = finalTp3 ? tTp3 : finalTp and rStage == 2 ? tTp2 : finalTp and rStage == 1 ? tTp1 : tStop
        string resTxt   = finalTp3 ? "TP3 ✔ WIN " + f_signedR(resR) : finalTp ? "TP" + str.tostring(rStage) + " ✔ WIN " + f_signedR(resR) : "SL ✘ LOSS -1R"
        color  resCol   = resR >= 0 ? longCol : shortCol
        string resStyle = tradeSide == 1 ? (resR >= 0 ? label.style_label_down : label.style_label_up) : (resR >= 0 ? label.style_label_up : label.style_label_down)

        if showExitLbl
            aExit := label.new(closeEdge, resPrice, resTxt, style = resStyle, color = color.new(resCol, 0), textcolor = color.white, size = size.small)

        tradeViz tv = tradeViz.new(aEntry, aSl, aT1, aT2, aT3, aTpBox, aSlBox, aRkt, aSig, aLEntry, aLSl, aLT1, aLT2, aLT3, aExit)
        array.push(history, tv)
        while array.size(history) > maxHist
            tradeViz old = array.shift(history)
            line.delete(old.e)
            line.delete(old.s)
            line.delete(old.t1)
            line.delete(old.t2)
            line.delete(old.t3)
            box.delete(old.tb)
            box.delete(old.sb)
            label.delete(old.rk)
            label.delete(old.sg)
            label.delete(old.le)
            label.delete(old.ls)
            label.delete(old.l1)
            label.delete(old.l2)
            label.delete(old.l3)
            label.delete(old.ex)

        aEntry := na
        aSl := na
        aT1 := na
        aT2 := na
        aT3 := na
        aTpBox := na
        aSlBox := na
        aRkt := na
        aSig := na
        aLEntry := na
        aLSl := na
        aLT1 := na
        aLT2 := na
        aLT3 := na
        aExit := na

        tradeActive := false
        tradeSide   := 0
        tradeBar    := na
        tEntry := na
        tStop := na
        tTp1 := na
        tTp2 := na
        tTp3 := na
        bestStage := 0

takeSig = (sigLong or sigShort) and not tradeActive and not closedTp3 and not closedSl and not closedTp and not na(atr)

if takeSig
    bool  isLong  = sigLong
    int   side    = isLong ? 1 : -1
    float sc      = isLong ? bullStr : bearStr

    float entv    = close
    float structAnchor = isLong ? legLowA : legHighA
    float ignAnchor    = isLong ? low : high
    float anchor  = slMode == "Structural" ? structAnchor : ignAnchor
    float rawStop = isLong ? anchor - safeAtr * slBufAtr : anchor + safeAtr * slBufAtr
    float risk0   = math.abs(entv - rawStop)
    float maxR    = safeAtr * maxRiskAtr
    float minR    = safeAtr * minRiskAtr
    float risk    = math.min(math.max(risk0, minR), maxR)
    float stopv   = isLong ? entv - risk : entv + risk
    float t1      = isLong ? entv + risk * tp1R : entv - risk * tp1R
    float t2      = isLong ? entv + risk * tp2R : entv - risk * tp2R
    float t3      = isLong ? entv + risk * tp3R : entv - risk * tp3R

    tradeActive := true
    tradeSide   := side
    tradeBar    := bar_index
    tEntry      := entv
    tStop       := stopv
    tTp1        := t1
    tTp2        := t2
    tTp3        := t3
    bestStage   := 0
    tradeScore  := sc
    lastSigBar  := bar_index
    lastSigSide := side
    lastCoil    := coilTight
    sTotalSig   += 1

    color c   = isLong ? longCol : shortCol
    int   xr  = bar_index + levelLen

    if showRockets
        float ry = isLong ? high : low
        aRkt := label.new(bar_index - rocketOffset, ry, f_rockets(sc), xloc = xloc.bar_index, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(c, 100), textcolor = c, size = size.normal)

    if showSignal
        string tagC = coilTight ? " ⚡COIL" : ""
        string head = (isLong ? "STRONG LONG IMPULSE" : "STRONG SHORT IMPULSE") + tagC
        string txt  = showStars ? head + "\n" + f_stars(sc) + "  " + str.tostring(math.round(sc * 10) / 10) + "/10  " + f_tier(sc) : head
        aSig := label.new(bar_index, isLong ? low : high, txt, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(c, 6), textcolor = color.white, size = f_size(lblSizeOpt))

    if showBoxes
        float tpTop = isLong ? t3 : entv
        float tpBot = isLong ? entv : t3
        float slTop = isLong ? entv : stopv
        float slBot = isLong ? stopv : entv
        aTpBox := box.new(bar_index, tpTop, xr, tpBot, xloc = xloc.bar_index, bgcolor = color.new(tpFill, 80), border_color = color.new(c, 35), border_width = 1)
        aSlBox := box.new(bar_index, slTop, xr, slBot, xloc = xloc.bar_index, bgcolor = color.new(slFill, 80), border_color = color.new(shortCol, 45), border_width = 1)

    if showLines
        aEntry := line.new(bar_index, entv,  xr, entv,  xloc = xloc.bar_index, color = color.new(c, 0),  width = 2, style = line.style_solid)
        aSl    := line.new(bar_index, stopv, xr, stopv, xloc = xloc.bar_index, color = color.new(shortCol, 10), width = 1, style = line.style_dashed)
        aT1    := line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(c, 12), width = 1, style = line.style_solid)
        aT2    := line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(c, 30), width = 1, style = line.style_solid)
        aT3    := line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(c, 48), width = 1, style = line.style_solid)
        if showLevelLbl
            string dw = isLong ? "LONG" : "SHORT"
            aLEntry := label.new(xr, entv,  dw + " @ " + str.tostring(entv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 0), textcolor = color.white, size = f_size(lblSizeOpt))
            aLSl    := label.new(xr, stopv, "SL @ " + str.tostring(stopv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT1    := label.new(xr, t1, "TP1 " + str.tostring(tp1R, "#.#") + "R @ " + str.tostring(t1, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT2    := label.new(xr, t2, "TP2 " + str.tostring(tp2R, "#.#") + "R @ " + str.tostring(t2, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 26), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT3    := label.new(xr, t3, "TP3 " + str.tostring(tp3R, "#.#") + "R @ " + str.tostring(t3, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 42), textcolor = color.white, size = f_size(lblSizeOpt))

plotshape(showArrows and sigLong,  title = "BUY",  style = shape.triangleup,   location = location.belowbar, color = longCol,  size = size.small, text = "BUY",  textcolor = longCol)
plotshape(showArrows and sigShort, title = "SELL", style = shape.triangledown, location = location.abovebar, color = shortCol, size = size.small, text = "SELL", textcolor = shortCol)

winRate = sClosed > 0 ? sWins / sClosed * 100.0 : 0.0
avgR    = sClosed > 0 ? sR / sClosed : 0.0
pf      = sGrossLos > 0 ? sGrossWin / sGrossLos : sGrossWin > 0 ? 999.0 : 0.0
longWR  = sLong  > 0 ? sLongWin  / sLong  * 100.0 : 0.0
shortWR = sShort > 0 ? sShortWin / sShort * 100.0 : 0.0
tp1Rate = sClosed > 0 ? sTp1 / sClosed * 100.0 : 0.0
tp2Rate = sClosed > 0 ? sTp2 / sClosed * 100.0 : 0.0
tp3Rate = sClosed > 0 ? sTp3 / sClosed * 100.0 : 0.0
slRate  = sClosed > 0 ? sSl  / sClosed * 100.0 : 0.0

bestDir = sLong == 0 and sShort == 0 ? "—" : sLong > 0 and sShort == 0 ? "LONG" : sShort > 0 and sLong == 0 ? "SHORT" : longWR > shortWR ? "LONG" : shortWR > longWR ? "SHORT" : "EVEN"
streakTxt = sStreak > 0 ? "W" + str.tostring(sStreak) : sStreak < 0 ? "L" + str.tostring(math.abs(sStreak)) : "—"
pfTxt = pf >= 999.0 ? "INF" : str.tostring(pf, "#.##")

statusTxt = tradeActive ? "TRADE ACTIVE" : "WAITING"
activeTxt = tradeActive ? (tradeSide == 1 ? "LONG" : "SHORT") : "—"
lastTxt   = lastSigSide == 1 ? "LONG" : lastSigSide == -1 ? "SHORT" : "—"
lastScoreTxt = na(tradeScore) ? "—" : (lastCoil ? "⚡ " : "") + f_stars(tradeScore) + " " + str.tostring(math.round(tradeScore * 10) / 10) + "/10"

float liveBias = bullStr - bearStr
float liveScore = math.max(bullStr, bearStr)
bool  liveLong  = bullStr >= bearStr and bullStr > 0
string liveDirTxt = liveScore <= 0 ? "—" : liveLong ? "▲ LONG" : "▼ SHORT"
color  liveDirCol = liveScore <= 0 ? neutralCol : liveLong ? longCol : shortCol

float mDisp = math.min(10.0, rngAtr / dispAtr * 5.0)
float mVol  = math.min(10.0, (volRatio - 1.0) * 5.0)
float mRun  = math.min(10.0, math.max(runUp, runDn) * 1.6)
float mCoil = coilTight ? math.min(10.0, (coilMaxAtr - coilAtr) / coilMaxAtr * 10.0 + 4.0) : math.min(4.0, (coilMaxAtr / math.max(coilAtr, 0.01)) * 2.0)

color statusC = tradeActive ? longCol : neutralCol
color wrC     = winRate >= 55 ? goodCol : winRate >= 45 ? color.rgb(230, 190, 70) : badCol
color pfC     = pf >= 1.5 ? goodCol : pf >= 1.0 ? color.rgb(230, 190, 70) : badCol

int baseRows = 13
int meterRows = showMeter ? 5 : 0
int dashRows = baseRows + meterRows
var table dash = table.new(f_pos(dashPosOpt), 2, 18, frame_color = color.new(panelBorder, 0), frame_width = 1, border_width = 1, border_color = color.new(panelBorder, 30))

if barstate.islast and showDash
    ps = f_size(dashSizeOpt)
    table.clear(dash, 0, 0, 1, 17)
    int r = 0

    table.cell(dash, 0, r, "STRONG IMPULSE", text_color = txtHi, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
    table.cell(dash, 1, r, "SIGNALS", text_color = longCol, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
    r += 1

    table.cell(dash, 0, r, "Status", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, r, statusTxt, text_color = statusC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    r += 1

    table.cell(dash, 0, r, "Active Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, r, activeTxt, text_color = tradeSide == 1 ? longCol : tradeSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    r += 1

    table.cell(dash, 0, r, "Last Signal", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, r, lastTxt + "  " + lastScoreTxt, text_color = lastSigSide == 1 ? longCol : lastSigSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    r += 1

    if showMeter
        table.cell(dash, 0, r, "── Live Propulsion ──", text_color = color.new(longCol, 30), text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, r, liveDirTxt + "  " + str.tostring(math.round(liveScore * 10) / 10) + "/10", text_color = liveDirCol, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
        r += 1

        table.cell(dash, 0, r, "Displacement", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
        table.cell(dash, 1, r, f_meter(mDisp), text_color = f_meterCol(mDisp), text_size = ps, text_halign = text.align_right, bgcolor = panelBg)
        r += 1

        table.cell(dash, 0, r, "Volume Thrust", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
        table.cell(dash, 1, r, f_meter(mVol), text_color = f_meterCol(mVol), text_size = ps, text_halign = text.align_right, bgcolor = panelBgAlt)
        r += 1

        table.cell(dash, 0, r, "Momentum Run", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
        table.cell(dash, 1, r, f_meter(mRun), text_color = f_meterCol(mRun), text_size = ps, text_halign = text.align_right, bgcolor = panelBg)
        r += 1

        table.cell(dash, 0, r, "Coil Charge", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
        table.cell(dash, 1, r, f_meter(mCoil), text_color = f_meterCol(mCoil), text_size = ps, text_halign = text.align_right, bgcolor = panelBgAlt)
        r += 1

    table.cell(dash, 0, r, "── Performance ──", text_color = color.new(txtHi, 20), text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
    table.cell(dash, 1, r, str.tostring(sTotalSig) + " sig", text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
    r += 1

    table.cell(dash, 0, r, "Win Rate", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, r, str.tostring(winRate, "#.#") + "%  (" + str.tostring(sClosed) + ")", text_color = wrC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    r += 1

    table.cell(dash, 0, r, "Profit Factor", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, r, pfTxt, text_color = pfC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    r += 1

    table.cell(dash, 0, r, "Avg R / Trade", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, r, f_signedR(avgR), text_color = avgR >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    r += 1

    table.cell(dash, 0, r, "Best Direction", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, r, bestDir, text_color = bestDir == "LONG" ? longCol : bestDir == "SHORT" ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    r += 1

    table.cell(dash, 0, r, "L / S Win%", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, r, str.tostring(longWR, "#.#") + " / " + str.tostring(shortWR, "#.#"), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    r += 1

    table.cell(dash, 0, r, "Streak", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, r, streakTxt + "  (max W" + str.tostring(sMaxWin) + "/L" + str.tostring(sMaxLos) + ")", text_color = sStreak >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    r += 1

    if showHeatRow
        table.cell(dash, 0, r, "TP1/2/3 · SL", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, r, str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#") + " · " + str.tostring(slRate, "#") + "%", text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
    else
        table.cell(dash, 0, r, "", bgcolor = panelHdr)
        table.cell(dash, 1, r, "", bgcolor = panelHdr)

alertcondition(sigLong,   "Strong Long Impulse",  "Strong Impulse Signals: STRONG LONG impulse on {{ticker}} {{interval}}.")
alertcondition(sigShort,  "Strong Short Impulse", "Strong Impulse Signals: STRONG SHORT impulse on {{ticker}} {{interval}}.")
alertcondition(sigLong or sigShort, "Any Impulse", "Strong Impulse Signals: impulse fired on {{ticker}} {{interval}}.")
alertcondition(closedTp3, "TP3 Hit",  "Strong Impulse Signals: TP3 hit on {{ticker}} {{interval}}.")
alertcondition(closedTp,  "Partial TP Exit", "Strong Impulse Signals: protected TP exit on {{ticker}} {{interval}}.")
alertcondition(closedSl,  "SL Hit",   "Strong Impulse Signals: SL hit on {{ticker}} {{interval}}.")
````
