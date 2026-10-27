# Strong Gold Signals | ProjectSyndicate

- url: https://www.tradingview.com/script/iZWYmUE6-Strong-Gold-Signals-ProjectSyndicate/
- type: indicator
- pine_id: PUB;38545f59da764a18bd2f67fad8cfcc51
- version: 2.0

## Description

Strong Gold Signals catches the moment a liquidity grab runs out of fuel — price stabs beyond a level, traps the breakout crowd, then rolls over — and fires the reversal the instant the sweep stops extending. Markets hunt the obvious highs and lows: a candle pushes through a prior swing, an HTF extreme, or a session high/low, spikes just far enough to trip the stops resting there, then rejects with a long wick and closes back showing the move had no follow-through. That failed grab is the event. The engine measures how clean and how loaded that sweep is as a 0–10 Reversal Strength and fires AGAINST the grab — with the snap-back, not with the trap. Every setup gets a structural invalidation level behind the sweep extreme, fixed R-based targets, a 0–10 strength with a 1–4 star rank, and is tracked live on a full statistics dashboard — including honest stop-outs — so you can see exactly how the logic behaves on the symbol and timeframe you trade.

🧠 Sweep Core — the core idea, expressed as a lifecycle: LEVEL ▸ GRAB ▸ REJECTION ▸ STALL ▸ REVERSAL. A fresh liquidity level defines where stops are resting. A grab happens when price closes beyond that level with a rejection wick — the raid that runs the stops and then gets sold (or bought) back into range. The sweep is allowed to keep extending as long as it makes new extremes; the reversal fires on the first confirmed bar that fails to push past the sweep's high or low. Swept highs flip to a SHORT, swept lows to a LONG. Pivots come from confirmed swings and every condition is evaluated on the bar's close, so the structure and the signal do not repaint once they confirm.

🔎 Three Liquidity Sources — you choose what counts as the liquidity being swept. Macro Pivots uses confirmed swing highs and lows and is the validated default on intraday gold. HTF Previous Bar uses the prior higher-timeframe bar's high and low, so the engine hunts the levels bigger players watch. Session High/Low tracks the Asian, London, and New York ranges and reacts when a session extreme is raided. One switch changes the entire character of what the engine treats as a stop-hunt, without touching the rest of the logic.

🔋 Strength Anatomy — a sweep is not just true or false; it is scored for how clean the reversal setup is. The Reversal Strength fuses reversal-native ingredients into a single 0–10 read: trend context (how the higher structure frames the fade), rejection wick (how decisively the grab was rejected), volatility regime (calmer conditions favor clean snap-backs over runaway sweeps), mean proximity (how stretched price is from its baseline), and sweep depth (how far past the level the raid reached before stalling). Each ingredient carries its own weight and contributes to the 0–10 total, and you shape what qualifies through those weights and the wick threshold rather than chasing a single number.

🎯 Structural Invalidation + R-Based Targets — the stop is anchored to the sweep, not guessed. Invalidation sits just beyond the sweep extreme — the price that, if reclaimed, means the grab was real and the reversal failed — plus an ATR buffer for cushion. That distance is then clamped between an ATR floor and an ATR ceiling, so a stop never balloons into a wide one and the 1R target never collapses into a tight scalp. TP1, TP2, and TP3 are set at clean R multiples, defaulting to a deliberately wider 1.5R / 3R / 5R so winners are given room to travel, and fully adjustable to your reward profile. Every signal plots its complete Entry / SL / TP1 / TP2 / TP3 line set, labeled level prices, the swept liquidity level itself, and filled TP / SL zone boxes, with a result label on exit — and every zone is drawn at the same fixed width, so short trades and long trades leave an identical, uniform footprint on the chart.

⭐ 0–10 Strength with Star Tiers — every signal is labeled with its numeric strength, a star rank, and a tier ladder running MINIMAL → WEAK → MODERATE → STRONG → ELITE, so the raw quality of a setup reads at a glance without checking the number. Treat the strength as a cleanliness and confluence read for ranking and thinning setups — it describes how textbook a sweep-and-reject is, not a guaranteed outcome. The Minimum Stars gate restricts what is taken and alerted, while the dashboard keeps tracking every tier in the background so you can see, on your own data, whether higher tiers actually convert better.

🎚️ Conviction Controls — a compact set of dials sets how serious a sweep must be before it counts: the Minimum Stars To Take (the tier floor to fire at all), the Alert Minimum Stars threshold, the Min Reversal Wick that defines a genuine rejection, the Pivot Length that decides which swings qualify as liquidity, the Stop Buffer beyond the sweep, and the max-risk cap and min-risk floor that keep the stop sane. Tighten them for fewer, cleaner reversals; loosen them for more activity. This is your main control over conviction versus frequency.

🧭 Single-Ticket Discipline & Honest Accounting — only one ticket is active at a time, and a Signal Cooldown enforces a minimum gap between entries so one violent, choppy session can't stack overlapping trades. Resolution is SL-first pessimistic with honest partial-target accounting — if a stop is hit after TP1 or TP2, that partial result is booked rather than rounded up to a full win. A time-stop closes any trade that neither targets nor stops within a generous window, so nothing sits open forever and the on-chart statistics track how the setups actually run to target.

📊 Live Statistics Dashboard — a non-intrusive panel tracks, in real time on your chart: the current status (scanning → trade active) and the active trade side, the last signal with its star score, win rate, total closed trades, profit factor, average R per trade, best-performing direction, long vs short win rate, current and max win/loss streaks, and a TP1 / TP2 / TP3 / SL outcome breakdown. A multi-timeframe trend strip shows the current and two higher-timeframe biases at a glance, a Win Rate By Strength table breaks results out by star tier, and a Last Trades ledger lists the most recent outcomes. Every filled trade that reaches an outcome is counted — winners and stop-outs alike — so the numbers are computed live from the real signals on your current symbol and timeframe, not a figure printed in a description.

🎨 Clean Themed Visuals — six coherent palettes, all tuned for a black chart background — Aurora (the clean mint-and-rose default), Gold Noir, Ice Blue, Aqua Violet, Neon Magenta, and Institutional — shade the signal labels, the per-trade SL / TP ladder and zone boxes, the swept-level and pivot-liquidity markers, and the dashboard to one consistent look, so direction and quality read at a glance. Each reversal prints a labeled GOLD LONG or GOLD SHORT signal with its strength, star tier, and direction. A max-drawn-trades cap keeps only the most recent tickets on the chart while the statistics stay cumulative over the full history.

🔔 Detailed Alerts — fires on a Strong Long Reversal, a Strong Short Reversal, any reversal, and on TP3 Hit, Partial TP Exit, and SL events, formatted for manual or automated use. The strength gate can restrict alerts to higher-conviction setups only.
🔧 Fully Customizable — every component is exposed: the liquidity source and its pivot length, HTF resolution, session times and timezone, and the reversal-wick threshold; the ATR length, stop buffer, max-risk cap and min-risk floor, and the three R targets; the cooldown, the time-stop window, the uniform zone width, and the max historical trades drawn; the minimum-stars gate, the alert threshold, and each of the five strength weights; the dashboard position, size, and every section toggle including the MTF strip and its two timeframes; all six themes; and every signal label, star, line, box, level tag, and dashboard element.

🎯 Why this is different — most reversal tools flag a wick or a divergence after the fact. This one treats the liquidity grab and its exhaustion as the event, scores how clean that sweep-and-reject is across trend context, rejection, volatility, stretch, and sweep depth, and fires only when the raid stops extending — catching the snap-back at its origin — then anchors invalidation behind the sweep, ranks every setup on an objective 0–10 scale, and layers a live, honest statistics panel that counts stop-outs in full. You tune and judge it on real, current data from your own chart instead of a marketing number.

🚀 Where to use it — the engine was built and tuned on XAUUSD (gold) on intraday timeframes, where liquidity hunts, session raids, and stop-runs are a constant feature — but the mechanics are symbol-agnostic and rest on universal behavior: every liquid market sweeps its obvious highs and lows. It can be applied to FX majors and crosses, metals, indices, and crypto on intraday timeframes, with the pivot length and ATR-based stop adapting to each instrument's volatility. Because it fades exhaustion, it shines around session extremes and range edges and demands more care in violent one-way trends, where a sweep can keep extending rather than reject — let the dashboard tell you whether the logic suits the pair and timeframe before you commit.

🎯 How to trade it
Apply it to a liquid symbol on an intraday timeframe and let the dashboard populate. Read the live win rate, profit factor, and average R for your symbol and timeframe first — if the logic doesn't suit that market, you'll see it.
Wait for a labeled GOLD LONG / GOLD SHORT reversal — it marks a confirmed close where liquidity was swept and rejected and the sweep has stopped extending, with the strength, star tier, and full Entry / SL / TP1 / TP2 / TP3 already plotted.

Read the star tier and the swept level for a fast conviction check — a decisive rejection at a clean level and a higher tier mean a more textbook fade.
Manage the trade with the plotted levels — the ATR-clamped structural stop sits beyond the sweep and defines your risk, and the wider TP1/2/3 sit at your chosen R multiples. Bank or trail however suits your style.

Use the Minimum-Stars floor, the reversal-wick threshold, the pivot length, the cooldown, and the liquidity source to set your tempo — stricter for fewer, cleaner reversals; looser for more activity — and lean on the star tier to focus on the most textbook grabs.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. Default settings were chosen on historical gold data and behavior will vary by symbol, timeframe, session, and configuration; the dashboard's statistics are historical and descriptive, not a forecast. The trade model resolves stop-first and books partial-target exits honestly, so some trades close for a fraction of a target rather than a full win — these are counted in full, which is honest but means win rate alone is misleading; because the targets are intentionally wide, expect a lower headline win rate and always weigh it together with average R and profit factor, and resize the R targets to your own risk profile. Signals confirm on the closed bar, and the pivot-based liquidity source confirms a few bars after a swing forms — so always wait for the labeled reversal on a closed candle. Because the system fades a move, a real breakout or a sweep that keeps extending can run straight through a stop — combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6

indicator("Strong Gold Signals", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

gEntry = "01 · Entry Engine (RSI + EMA)"
rsiLen         = input.int(14, "RSI Length", minval = 2, maxval = 100, group = gEntry)
rsiTrigger     = input.string("Cross Midline", "RSI Trigger", options = ["Cross Midline", "Exit OB/OS"], group = gEntry, tooltip = "Cross Midline = momentum (RSI crosses the 50 line). Exit OB/OS = mean-reversion (RSI leaves oversold/overbought).")
rsiMid         = input.float(50, "RSI Midline", minval = 1, maxval = 99, group = gEntry)
rsiOS          = input.float(30, "RSI Oversold (long trigger)", minval = 1, maxval = 49, group = gEntry, tooltip = "In 'Exit OB/OS' mode a LONG fires when RSI crosses back ABOVE this level.")
rsiOB          = input.float(70, "RSI Overbought (short trigger)", minval = 51, maxval = 99, group = gEntry, tooltip = "In 'Exit OB/OS' mode a SHORT fires when RSI crosses back BELOW this level.")
emaFastLen     = input.int(50,  "Fast EMA", minval = 2, maxval = 400, group = gEntry)
emaSlowLen     = input.int(200, "Slow EMA", minval = 3, maxval = 800, group = gEntry)
useTrendFilter = input.bool(true, "Require EMA Trend Alignment", group = gEntry, tooltip = "Longs only when Fast EMA > Slow EMA; shorts only when Fast EMA < Slow EMA. Turn off for pure RSI signals.")

gTrade = "02 · Trade Levels (R-based)"
atrLen   = input.int(14, "ATR Length", minval = 1, group = gTrade)
stopMode = input.string("Swing Extreme", "Stop Basis", options = ["Swing Extreme", "ATR Multiple"], group = gTrade, tooltip = "Swing Extreme = stop beyond the recent swing low/high. ATR Multiple = fixed ATR distance from entry.")
swingLook= input.int(10, "Swing Lookback (bars)", minval = 2, maxval = 200, group = gTrade, tooltip = "Bars used to find the swing low/high that anchors the stop in Swing Extreme mode.")
stopAtr  = input.float(1.2, "Stop Distance (ATR)", minval = 0.1, maxval = 10, step = 0.1, group = gTrade, tooltip = "Stop distance in ATRs when Stop Basis = ATR Multiple.")
slBuf    = input.float(0.30, "Stop Buffer Beyond Swing (ATR)", minval = 0.0, maxval = 3, step = 0.05, group = gTrade, tooltip = "Extra ATR cushion added beyond the swing extreme.")
maxRisk  = input.float(3.0, "Max Risk (ATR) — stop cap",  minval = 0.3, maxval = 10, step = 0.1, group = gTrade)
minRisk  = input.float(0.5, "Min Risk (ATR) — stop floor", minval = 0.1, maxval = 5, step = 0.1, group = gTrade)
tp1R     = input.float(1.5, "TP1 (R)", minval = 0.25, maxval = 50, step = 0.25, group = gTrade, tooltip = "R-multiple ladder. Validated 1.5 / 3 / 5 R.")
tp2R     = input.float(3.0, "TP2 (R)", minval = 0.25, maxval = 50, step = 0.25, group = gTrade)
tp3R     = input.float(5.0, "TP3 (R)", minval = 0.25, maxval = 50, step = 0.25, group = gTrade)
cooldown = input.int(0,  "Cooldown Bars Between Trades", minval = 0, maxval = 500, group = gTrade)
maxHunt  = input.int(240, "Max Bars In Trade (time-stop)", minval = 5, maxval = 5000, group = gTrade, tooltip = "Force-close at market if no target/stop hits within this many bars.")
levelLen = input.int(24, "Zone Width (bars) — uniform", minval = 2, maxval = 500, group = gTrade, tooltip = "Fixed width of every SL/TP shaded zone, level line and price tag.")
showLines   = input.bool(true, "Show SL / TP Lines", group = gTrade)
showBoxes   = input.bool(true, "Show SL / TP Zones", group = gTrade)
showLevelLbl= input.bool(true, "Label Level Prices", group = gTrade)
showExitLbl = input.bool(true, "Show Trade Result Labels", group = gTrade)
showLiqLvl  = input.bool(true, "Show Fast EMA Marker", group = gTrade)
maxHist     = input.int(30, "Max Historical Trades Drawn", minval = 1, maxval = 80, group = gTrade)

gScore = "03 · Strength Ranking"
minStars = input.int(0, "Minimum Stars To Take", minval = 0, maxval = 4, group = gScore, tooltip = "0 = take every signal. Raise to filter to stronger setups; dashboard still tracks all tiers.")
strongThr= input.float(0.0, "Alert Minimum Stars (0-4)", minval = 0, maxval = 4, step = 1, group = gScore)
wTrend = input.float(0.30, "Weight · Trend Context",     minval = 0, maxval = 1, step = 0.05, group = gScore)
wRsi   = input.float(0.25, "Weight · RSI Conviction",    minval = 0, maxval = 1, step = 0.05, group = gScore)
wCalm  = input.float(0.15, "Weight · Volatility Regime", minval = 0, maxval = 1, step = 0.05, group = gScore)
wNear  = input.float(0.15, "Weight · EMA Proximity",     minval = 0, maxval = 1, step = 0.05, group = gScore)
wMom   = input.float(0.15, "Weight · Momentum",          minval = 0, maxval = 1, step = 0.05, group = gScore)

gDash = "04 · Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = gDash)
dashPosOpt  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSizeOpt = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)
showHeatRow = input.bool(true, "Show TP1/2/3 · SL Breakdown", group = gDash)
showTiers   = input.bool(true, "Show Win-Rate By Strength", group = gDash)
showRecent  = input.bool(true, "Show Last Trades", group = gDash)
showMtf     = input.bool(true, "Show MTF Trend Strip", group = gDash)
mtfTf2      = input.timeframe("15", "MTF · TF 2", group = gDash)
mtfTf3      = input.timeframe("60", "MTF · TF 3", group = gDash)

gVis = "05 · Visuals"
theme      = input.string("Aurora", "Color Theme", options = ["Aurora", "Gold Noir", "Ice Blue", "Aqua Violet", "Neon Magenta", "Institutional"], group = gVis, tooltip = "All themes are tuned for a black chart background. Aurora (mint / rose) is the clean default.")
showSignal = input.bool(true, "Show Signal Labels", group = gVis)
showStars  = input.bool(true, "Show ★ Ranking On Labels", group = gVis)
lblSizeOpt = input.string("Small", "Signal Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVis)
plotLevels = input.bool(true, "Plot Fast / Slow EMAs", group = gVis)

longCol  = theme == "Gold Noir" ? color.rgb(230, 184, 75) : theme == "Ice Blue" ? color.rgb(38, 198, 255) : theme == "Aqua Violet" ? color.rgb(0, 225, 200) : theme == "Neon Magenta" ? color.rgb(0, 230, 200) : theme == "Institutional" ? color.rgb(31, 176, 118) : color.rgb(20, 214, 122)
shortCol = theme == "Gold Noir" ? color.rgb(203, 68, 56) : theme == "Ice Blue" ? color.rgb(255, 112, 92) : theme == "Aqua Violet" ? color.rgb(184, 122, 255) : theme == "Neon Magenta" ? color.rgb(255, 62, 190) : theme == "Institutional" ? color.rgb(176, 62, 74) : color.rgb(243, 62, 110)
tpFill   = theme == "Gold Noir" ? color.rgb(120, 92, 20) : theme == "Ice Blue" ? color.rgb(0, 92, 132) : theme == "Aqua Violet" ? color.rgb(0, 96, 88) : theme == "Neon Magenta" ? color.rgb(0, 98, 86) : theme == "Institutional" ? color.rgb(18, 96, 66) : color.rgb(12, 104, 64)
slFill   = theme == "Gold Noir" ? color.rgb(120, 40, 30) : theme == "Ice Blue" ? color.rgb(140, 44, 66) : theme == "Aqua Violet" ? color.rgb(96, 40, 120) : theme == "Neon Magenta" ? color.rgb(128, 26, 90) : theme == "Institutional" ? color.rgb(110, 34, 42) : color.rgb(140, 30, 62)

color panelBg     = #0a0c12
color panelBgAlt  = #0f131c
color panelHdr    = #161b27
color panelBorder = #2c3342
color txtHi       = #ebeef5
color txtLo       = #8791a2
color neutralCol  = #69748a
color goodCol     = #21c87a
color badCol      = #e6435a
color warnCol     = color.rgb(214, 176, 74)

f_clamp(float v) => math.min(math.max(v, 0.0), 1.0)

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

f_stars(float sc) => sc >= 7.5 ? "★★★★" : sc >= 6.5 ? "★★★" : sc >= 5.5 ? "★★" : sc >= 4.5 ? "★" : "·"
f_tier(float sc)  => sc >= 7.5 ? 4 : sc >= 6.5 ? 3 : sc >= 5.5 ? 2 : sc >= 4.5 ? 1 : 0
f_tname(float sc) => sc >= 7.5 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5.5 ? "MODERATE" : sc >= 4.5 ? "WEAK" : "MINIMAL"
f_signedR(float v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

// ── Core series ─────────────────────────────────────────────────────────────
atr      = ta.atr(atrLen)
rsi      = ta.rsi(close, rsiLen)
emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
atrPct   = ta.percentrank(atr, 100)
emaSlope = ta.change(emaFast, 3)
swingLo  = ta.lowest(low,  swingLook)
swingHi  = ta.highest(high, swingLook)

// ── Confluence score (RSI + EMA context) ────────────────────────────────────
f_score(int dir, float entry, float rsiVal) =>
    float a      = atr <= 0 ? syminfo.mintick : atr
    float sep    = (dir == 1 ? (emaFast - emaSlow) : (emaSlow - emaFast)) / a
    float trendN = f_clamp((sep + 1.0) / 2.0)
    float rsiN   = f_clamp(math.abs(rsiVal - 50.0) / 50.0 * 1.6)
    float calmN  = f_clamp(1.0 - atrPct / 100.0)
    float distE  = math.abs(entry - emaFast) / a
    float nearN  = f_clamp(1.0 - distE / 2.0)
    float slope  = (dir == 1 ? emaSlope : -emaSlope) / a
    float momN   = f_clamp((slope + 1.0) / 2.0)
    float wsum   = wTrend + wRsi + wCalm + wNear + wMom
    float raw    = wsum > 0 ? (trendN * wTrend + rsiN * wRsi + calmN * wCalm + nearN * wNear + momN * wMom) / wsum : 0.0
    math.min(math.max(raw * 10.0, 0.0), 10.0)

f_tooltip(int dir, float sc, float rsiVal) =>
    string d = dir == 1 ? "LONG (RSI + EMA)" : "SHORT (RSI + EMA)"
    string tt = "Setup quality: " + str.tostring(math.round(sc * 10) / 10) + "/10  " + f_stars(sc) + "  " + f_tname(sc)
    tt += "\nDirection: " + d
    tt += "\nRSI: " + str.tostring(rsiVal, "#.#")
    tt += "\nTrend: " + (emaFast > emaSlow ? "Fast EMA above Slow (up)" : "Fast EMA below Slow (down)")
    tt += "\nVolatility pctile: " + str.tostring(atrPct, "#") + "  (calmer = better)"
    tt += "\nNote: score is a confluence read, not a win-rate guarantee."
    tt

// ── RSI + EMA entry trigger ─────────────────────────────────────────────────
bool trendUp = emaFast > emaSlow
bool trendDn = emaFast < emaSlow

bool longRsi  = rsiTrigger == "Cross Midline" ? ta.crossover(rsi, rsiMid)  : ta.crossover(rsi, rsiOS)
bool shortRsi = rsiTrigger == "Cross Midline" ? ta.crossunder(rsi, rsiMid) : ta.crossunder(rsi, rsiOB)

bool longOk  = longRsi  and (not useTrendFilter or trendUp)
bool shortOk = shortRsi and (not useTrendFilter or trendDn)

int fireDir = 0
if barstate.isconfirmed
    fireDir := longOk ? 1 : shortOk ? -1 : 0

var int lastSigBar  = na
var int lastSigSide = 0
cooldownOk = na(lastSigBar) or (bar_index - lastSigBar >= cooldown)

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
var int   tradeTier   = 0

var line  aEntry = na
var line  aSl    = na
var line  aT1    = na
var line  aT2    = na
var line  aT3    = na
var box   aTpBox = na
var box   aSlBox = na
var label aSig   = na
var label aLEntry= na
var label aLSl   = na
var label aLT1   = na
var label aLT2   = na
var label aLT3   = na
var label aExit  = na
var line  aLiq   = na

type tradeViz
    line  e  = na
    line  s  = na
    line  t1 = na
    line  t2 = na
    line  t3 = na
    box   tb = na
    box   sb = na
    label sg = na
    label le = na
    label ls = na
    label l1 = na
    label l2 = na
    label l3 = na
    label ex = na
    line  lq = na

var array<tradeViz> history = array.new<tradeViz>()

var int   sClosed   = 0
var int   sTp1      = 0
var int   sTp2      = 0
var int   sTp3      = 0
var int   sSl       = 0
var int   sExp      = 0
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
var array<int> tierWin  = array.new_int(5, 0)
var array<int> tierLoss = array.new_int(5, 0)
var array<string> recent = array.new<string>()

f_logRecent(string s) =>
    array.unshift(recent, s)
    if array.size(recent) > 10
        array.pop(recent)

closedTp3 = false
closedSl  = false
closedTp  = false
closedExp = false

if tradeActive
    bool tp1Hit = tradeSide == 1 ? high >= tTp1 : low <= tTp1
    bool tp2Hit = tradeSide == 1 ? high >= tTp2 : low <= tTp2
    bool tp3Hit = tradeSide == 1 ? high >= tTp3 : low <= tTp3
    bool slHit  = tradeSide == 1 ? low  <= tStop : high >= tStop

    int stage = tp3Hit ? 3 : tp2Hit ? 2 : tp1Hit ? 1 : 0
    bool sameBarSl = slHit and stage > 0
    if stage > bestStage and not sameBarSl
        bestStage := stage

    int barsIn = not na(tradeBar) ? bar_index - tradeBar : 0
    bool finalTp3 = not sameBarSl and bestStage == 3
    bool finalSl  = slHit and (bestStage == 0 or sameBarSl)
    bool finalTp  = slHit and not sameBarSl and bestStage > 0 and bestStage < 3
    bool expireNow= not finalTp3 and not finalSl and not finalTp and barsIn >= maxHunt

    if finalTp3 or finalSl or finalTp or expireNow
        float mtmR = math.abs(tEntry - tStop) > 0 ? (tradeSide == 1 ? (close - tEntry) : (tEntry - close)) / math.abs(tEntry - tStop) : 0.0
        float resR = finalTp3 ? tp3R : (finalTp and bestStage == 2) ? tp2R : (finalTp and bestStage == 1) ? tp1R : expireNow ? mtmR : -1.0

        closedTp3 := finalTp3
        closedSl  := finalSl
        closedTp  := finalTp
        closedExp := expireNow

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
            array.set(tierWin, tradeTier, array.get(tierWin, tradeTier) + 1)
        else
            sGrossLos += math.abs(resR)
            sCurLos += 1
            sCurWin := 0
            sMaxLos := math.max(sMaxLos, sCurLos)
            sStreak := -sCurLos
            array.set(tierLoss, tradeTier, array.get(tierLoss, tradeTier) + 1)
        if tradeSide == 1
            sLong += 1
            sLongWin += isWin ? 1 : 0
        else
            sShort += 1
            sShortWin += isWin ? 1 : 0
        if finalTp3
            sTp3 += 1
            f_logRecent("TP3")
        else if finalTp and bestStage == 2
            sTp2 += 1
            f_logRecent("TP2")
        else if finalTp and bestStage == 1
            sTp1 += 1
            f_logRecent("TP1")
        else if expireNow
            sExp += 1
            f_logRecent(isWin ? "EXIT+" : "EXIT-")
        else
            sSl += 1
            f_logRecent("SL")

        float resPrice = finalTp3 ? tTp3 : (finalTp and bestStage == 2) ? tTp2 : (finalTp and bestStage == 1) ? tTp1 : expireNow ? close : tStop
        string resTxt  = finalTp3 ? "TP3 ✔ " + f_signedR(resR) : finalTp ? "TP" + str.tostring(bestStage) + " ✔ " + f_signedR(resR) : expireNow ? (isWin ? "EXIT ✔ " : "EXIT ✘ ") + f_signedR(resR) : "SL ✘ -1R"
        color  resCol  = resR >= 0 ? longCol : shortCol
        string resStyle = tradeSide == 1 ? (resR >= 0 ? label.style_label_down : label.style_label_up) : (resR >= 0 ? label.style_label_up : label.style_label_down)

        if showExitLbl
            aExit := label.new(bar_index, resPrice, resTxt, style = resStyle, color = color.new(resCol, 0), textcolor = color.white, size = size.small)

        tradeViz tv = tradeViz.new(aEntry, aSl, aT1, aT2, aT3, aTpBox, aSlBox, aSig, aLEntry, aLSl, aLT1, aLT2, aLT3, aExit, aLiq)
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
            label.delete(old.sg)
            label.delete(old.le)
            label.delete(old.ls)
            label.delete(old.l1)
            label.delete(old.l2)
            label.delete(old.l3)
            label.delete(old.ex)
            line.delete(old.lq)

        aEntry := na
        aSl := na
        aT1 := na
        aT2 := na
        aT3 := na
        aTpBox := na
        aSlBox := na
        aSig := na
        aLEntry := na
        aLSl := na
        aLT1 := na
        aLT2 := na
        aLT3 := na
        aExit := na
        aLiq := na

        tradeActive := false
        tradeSide   := 0
        tradeBar    := na
        tEntry := na
        tStop := na
        tTp1 := na
        tTp2 := na
        tTp3 := na
        bestStage := 0

canOpen = not tradeActive and not closedTp3 and not closedSl and not closedTp and not closedExp and not na(atr) and cooldownOk
rawSig  = fireDir != 0 and canOpen
sigScore = rawSig ? f_score(fireDir, close, rsi) : na
takeSig  = rawSig and (na(sigScore) ? false : f_tier(sigScore) >= minStars)

strongLong  = takeSig and fireDir == 1
strongShort = takeSig and fireDir == -1

if takeSig
    lastSigBar  := bar_index
    lastSigSide := fireDir

if takeSig
    bool  isLong = strongLong
    int   side   = isLong ? 1 : -1
    float sc     = sigScore
    float entv   = close
    float rawStop= isLong ? (stopMode == "ATR Multiple" ? entv - atr * stopAtr : swingLo - atr * slBuf) : (stopMode == "ATR Multiple" ? entv + atr * stopAtr : swingHi + atr * slBuf)
    float risk0  = math.abs(entv - rawStop)
    float maxR   = atr * maxRisk
    float minR   = atr * minRisk
    float risk   = math.min(math.max(risk0, minR), maxR)
    float stopv  = isLong ? entv - risk : entv + risk
    float t1     = isLong ? entv + risk * tp1R : entv - risk * tp1R
    float t2     = isLong ? entv + risk * tp2R : entv - risk * tp2R
    float t3     = isLong ? entv + risk * tp3R : entv - risk * tp3R

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
    tradeTier   := f_tier(sc)

    color c  = isLong ? longCol : shortCol
    int   xr = bar_index + levelLen

    if showSignal
        string head = isLong ? "GOLD LONG" : "GOLD SHORT"
        string txt  = showStars ? head + "\n" + f_stars(sc) + "  " + str.tostring(math.round(sc * 10) / 10) + "/10  " + f_tname(sc) : head
        aSig := label.new(bar_index, isLong ? low : high, txt, style = isLong ? label.style_label_up : label.style_label_down, color = color.new(c, 6), textcolor = color.white, size = f_size(lblSizeOpt), tooltip = f_tooltip(side, sc, rsi))

    if showLiqLvl
        aLiq := line.new(bar_index - 1, emaFast, xr, emaFast, xloc = xloc.bar_index, color = color.new(neutralCol, 20), width = 1, style = line.style_dotted)

    if showBoxes
        float tpTop = isLong ? t3 : entv
        float tpBot = isLong ? entv : t3
        float slTop = isLong ? entv : stopv
        float slBot = isLong ? stopv : entv
        aTpBox := box.new(bar_index, tpTop, xr, tpBot, xloc = xloc.bar_index, bgcolor = color.new(tpFill, 82), border_color = color.new(c, 35), border_width = 1)
        aSlBox := box.new(bar_index, slTop, xr, slBot, xloc = xloc.bar_index, bgcolor = color.new(slFill, 82), border_color = color.new(shortCol, 45), border_width = 1)

    if showLines
        aEntry := line.new(bar_index, entv,  xr, entv,  xloc = xloc.bar_index, color = color.new(c, 0),  width = 2, style = line.style_solid)
        aSl    := line.new(bar_index, stopv, xr, stopv, xloc = xloc.bar_index, color = color.new(shortCol, 10), width = 1, style = line.style_dashed)
        aT1    := line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(c, 12), width = 1, style = line.style_solid)
        aT2    := line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(c, 30), width = 1, style = line.style_solid)
        aT3    := line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(c, 48), width = 1, style = line.style_solid)
        if showLevelLbl
            string dw = isLong ? "LONG" : "SHORT"
            aLEntry := label.new(xr, entv,  dw + " @ " + str.tostring(entv, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 0),  textcolor = color.white, size = f_size(lblSizeOpt))
            aLSl    := label.new(xr, stopv, "SL @ " + str.tostring(stopv, format.mintick),   xloc = xloc.bar_index, style = label.style_label_left, color = color.new(shortCol, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT1    := label.new(xr, t1, "TP1 " + str.tostring(tp1R, "#.#") + "R @ " + str.tostring(t1, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 10), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT2    := label.new(xr, t2, "TP2 " + str.tostring(tp2R, "#.#") + "R @ " + str.tostring(t2, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 26), textcolor = color.white, size = f_size(lblSizeOpt))
            aLT3    := label.new(xr, t3, "TP3 " + str.tostring(tp3R, "#.#") + "R @ " + str.tostring(t3, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 42), textcolor = color.white, size = f_size(lblSizeOpt))

plot(plotLevels ? emaFast : na, "Fast EMA", color = color.new(longCol, 40),  linewidth = 1)
plot(plotLevels ? emaSlow : na, "Slow EMA", color = color.new(shortCol, 40), linewidth = 1)

htfDir2 = request.security(syminfo.tickerid, mtfTf2, (close > ta.ema(close, emaFastLen) ? 1 : -1), lookahead = barmerge.lookahead_off)[1]
htfDir3 = request.security(syminfo.tickerid, mtfTf3, (close > ta.ema(close, emaFastLen) ? 1 : -1), lookahead = barmerge.lookahead_off)[1]
curDir  = close > emaFast ? 1 : -1

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

statusTxt = tradeActive ? "TRADE ACTIVE" : "SCANNING"
activeTxt = tradeActive ? (tradeSide == 1 ? "LONG" : "SHORT") : "—"
lastTxt   = lastSigSide == 1 ? "LONG" : lastSigSide == -1 ? "SHORT" : "—"
lastScoreTxt = na(tradeScore) ? "—" : f_stars(tradeScore) + " " + str.tostring(math.round(tradeScore * 10) / 10)

color statusC = tradeActive ? longCol : neutralCol
color pfC     = pf >= 1.5 ? goodCol : pf >= 1.0 ? warnCol : badCol

f_dirTxt(int d) => d == 1 ? "▲ UP" : d == -1 ? "▼ DN" : "—"
f_dirCol(int d) => d == 1 ? longCol : d == -1 ? shortCol : neutralCol

f_tierWR(int k) =>
    int w = array.get(tierWin, k)
    int l = array.get(tierLoss, k)
    int nn = w + l
    [nn > 0 ? w / nn * 100.0 : 0.0, nn]

var int dashRows = 26
var table dash = table.new(f_pos(dashPosOpt), 3, dashRows, frame_color = color.new(panelBorder, 0), frame_width = 1, border_width = 1, border_color = color.new(panelBorder, 30))

if barstate.islast and showDash
    ps = f_size(dashSizeOpt)
    table.clear(dash, 0, 0, 2, dashRows - 1)

    table.cell(dash, 0, 0, "STRONG GOLD", text_color = txtHi, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
    table.cell(dash, 1, 0, "RSI", text_color = longCol, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
    table.cell(dash, 2, 0, "EMA", text_color = longCol, text_size = ps, text_halign = text.align_right, bgcolor = panelHdr)

    table.cell(dash, 0, 1, "Status", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 1, statusTxt, text_color = statusC, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 2, 1, activeTxt, text_color = tradeSide == 1 ? longCol : tradeSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_right, bgcolor = panelBg)

    table.cell(dash, 0, 2, "Last Signal", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 2, lastTxt, text_color = lastSigSide == 1 ? longCol : lastSigSide == -1 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 2, 2, lastScoreTxt, text_color = txtHi, text_size = ps, text_halign = text.align_right, bgcolor = panelBgAlt)

    table.cell(dash, 0, 3, "Win Rate", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 3, str.tostring(winRate, "#.#") + "%", text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 2, 3, str.tostring(sClosed) + " trd", text_color = txtHi, text_size = ps, text_halign = text.align_right, bgcolor = panelBg)

    table.cell(dash, 0, 4, "PROFIT FACTOR", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 4, pfTxt, text_color = pfC, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 2, 4, f_signedR(avgR) + "/t", text_color = avgR >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_right, bgcolor = panelBgAlt)

    table.cell(dash, 0, 5, "Best Dir", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
    table.cell(dash, 1, 5, bestDir, text_color = bestDir == "LONG" ? longCol : bestDir == "SHORT" ? shortCol : neutralCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(dash, 2, 5, str.tostring(longWR, "#") + "/" + str.tostring(shortWR, "#") + "%", text_color = txtHi, text_size = ps, text_halign = text.align_right, bgcolor = panelBg)

    table.cell(dash, 0, 6, "Streak", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBgAlt)
    table.cell(dash, 1, 6, streakTxt, text_color = sStreak >= 0 ? goodCol : badCol, text_size = ps, text_halign = text.align_center, bgcolor = panelBgAlt)
    table.cell(dash, 2, 6, "W" + str.tostring(sMaxWin) + "/L" + str.tostring(sMaxLos), text_color = txtHi, text_size = ps, text_halign = text.align_right, bgcolor = panelBgAlt)

    int r = 7
    if showHeatRow
        table.cell(dash, 0, r, "TP1/2/3·SL", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelBg)
        table.cell(dash, 1, r, str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#"), text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelBg)
        table.cell(dash, 2, r, str.tostring(slRate, "#") + "%", text_color = badCol, text_size = ps, text_halign = text.align_right, bgcolor = panelBg)
        r += 1

    if showMtf
        table.cell(dash, 0, r, "MTF Trend", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, r, timeframe.period + " " + f_dirTxt(curDir), text_color = f_dirCol(curDir), text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
        table.cell(dash, 2, r, f_dirTxt(htfDir2) + " " + f_dirTxt(htfDir3), text_color = htfDir2 + htfDir3 > 0 ? longCol : htfDir2 + htfDir3 < 0 ? shortCol : neutralCol, text_size = ps, text_halign = text.align_right, bgcolor = panelHdr)
        r += 1

    if showTiers
        table.cell(dash, 0, r, "WIN RATE BY STRENGTH", text_color = txtHi, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, r, "WR", text_color = txtLo, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)
        table.cell(dash, 2, r, "n", text_color = txtLo, text_size = ps, text_halign = text.align_right, bgcolor = panelHdr)
        r += 1
        for k = 4 to 1
            [twr, tn] = f_tierWR(k)
            string star = k == 4 ? "★★★★" : k == 3 ? "★★★" : k == 2 ? "★★" : "★"
            color tc = tn == 0 ? txtLo : twr >= 45 ? goodCol : twr >= 33 ? warnCol : badCol
            table.cell(dash, 0, r, star, text_color = warnCol, text_size = ps, text_halign = text.align_left, bgcolor = k % 2 == 0 ? panelBg : panelBgAlt)
            table.cell(dash, 1, r, tn > 0 ? str.tostring(twr, "#.#") + "%" : "—", text_color = tc, text_size = ps, text_halign = text.align_center, bgcolor = k % 2 == 0 ? panelBg : panelBgAlt)
            table.cell(dash, 2, r, str.tostring(tn), text_color = txtHi, text_size = ps, text_halign = text.align_right, bgcolor = k % 2 == 0 ? panelBg : panelBgAlt)
            r += 1

    if showRecent
        table.cell(dash, 0, r, "LAST TRADES", text_color = txtHi, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, r, "", bgcolor = panelHdr)
        table.cell(dash, 2, r, "", bgcolor = panelHdr)
        r += 1
        int hn = array.size(recent)
        if hn > 0
            int shown = math.min(hn, 6)
            for i = 0 to shown - 1
                string o = array.get(recent, i)
                bool wl = o == "SL" or o == "EXIT-"
                color oc = wl ? badCol : goodCol
                table.cell(dash, 0, r, "#" + str.tostring(i + 1), text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = i % 2 == 0 ? panelBg : panelBgAlt)
                table.cell(dash, 1, r, o, text_color = oc, text_size = ps, text_halign = text.align_center, bgcolor = i % 2 == 0 ? panelBg : panelBgAlt)
                table.cell(dash, 2, r, wl ? "✘" : "✔", text_color = oc, text_size = ps, text_halign = text.align_right, bgcolor = i % 2 == 0 ? panelBg : panelBgAlt)
                r += 1

alertStrongOk = na(sigScore) ? false : f_tier(sigScore) >= int(strongThr)
alertcondition(strongLong  and alertStrongOk, "Gold Long (RSI+EMA)",  "Strong Gold Signals: LONG RSI+EMA entry on {{ticker}} {{interval}} @ {{close}}.")
alertcondition(strongShort and alertStrongOk, "Gold Short (RSI+EMA)", "Strong Gold Signals: SHORT RSI+EMA entry on {{ticker}} {{interval}} @ {{close}}.")
alertcondition(takeSig, "Any Gold Signal", "Strong Gold Signals: new RSI+EMA entry on {{ticker}} {{interval}} @ {{close}}.")
alertcondition(closedTp3, "TP3 Hit", "Strong Gold Signals: TP3 hit on {{ticker}} {{interval}}.")
alertcondition(closedTp,  "Partial TP Exit", "Strong Gold Signals: protected TP exit on {{ticker}} {{interval}}.")
alertcondition(closedSl,  "SL Hit", "Strong Gold Signals: SL hit on {{ticker}} {{interval}}.")
````
