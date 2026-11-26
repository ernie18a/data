# Liquidity Propulsion Signals | ProjectSyndicate

- url: https://www.tradingview.com/script/4A3P3vwV-Liquidity-Propulsion-Signals-ProjectSyndicate/
- type: indicator
- pine_id: PUB;f129ec137f334e19ae19f07b11bda727
- version: 1.0

## Description

Liquidity Propulsion Signals catches the moment a liquidity grab fails — and instead of chasing the breakout, it fades it. Markets coil, then hunt the resting liquidity parked above swing highs and below swing lows. When price spears one of those pools and then snaps back inside the range, it traps the breakout crowd and loads a "spring." The engine measures the energy stored in that failed grab as a 0–100 Propulsion Charge, and fires contrarian — in the direction the trapped crowd is now forced to unwind. Every setup gets a structural invalidation level beyond the failed grab, fixed R-based targets, a 0–100 charge with a 1–5 star rank, and is tracked live on a full statistics dashboard — including honest stop-outs — so you can see exactly how the logic behaves on the symbol and timeframe you trade.

🧠 Liquidity-Spring Core — the core idea, expressed as a lifecycle: COIL ▸ GRAB ▸ LOAD ▸ IGNITE ▸ TARGET. Resting-liquidity pools are mapped from confirmed swing pivots — the highs and lows where stops cluster. A grab begins when price pierces one of those pools: a low driven below sell-side liquidity, or a high pushed above buy-side liquidity. If price then reclaims the pool — closes back inside the range within the reclaim window — the grab has failed, and that failure loads a spring on the opposite side. The spring later ignites into a signal when price pushes through the bar that armed it. Pools come from confirmed pivots and every transition is evaluated on the bar's close, so the pools and the signal do not repaint.

🔋 Charge Anatomy — a failed grab is not just true or false; it is scored for how much energy it carries. The Propulsion Charge fuses six breakout-native ingredients into a single 0–100 read: grab depth (how far price penetrated the pool, in ATR), reclaim velocity (how fast it snapped back within the window), rejection wick (the share of the bar spent rejecting the level), volume surge (the spike over a rolling baseline), coil compression (how tightly the market was wound before the grab — a loaded spring versus a loose one), and reclaim displacement (how decisively close pushed back past the level). Each component is independently weighted, so you can dial the engine toward depth, speed, volume, or compression as your edge demands.

🎯 Structural Invalidation + R-Based Targets — a loaded spring is invalidated before it fires if price falls back beyond the grab extreme, so weak grabs quietly disarm instead of trading. Once a discharge fires, the trade model builds a universal ATR-based zone height: the stop sits a fixed ATR distance from entry, so every signal draws the same SL/TP geometry — no super-wide or super-narrow zones to distort your risk. TP1, TP2, and TP3 are set at clean R multiples, defaulting to a balanced 1R / 2R / 3R and fully adjustable to your reward profile. Every signal plots its complete Entry / SL / TP1 / TP2 / TP3 line set, labeled level prices, and filled TP / SL zone boxes, with a result label on exit.

🧲 Opposing-Liquidity Magnet — because a discharge is fundamentally drawn toward the next pool of unswept liquidity, the engine can project the nearest opposing pool as a dotted magnet line: the obvious, structural target the move is being pulled toward. It is a context read for where the propulsion wants to go, sitting alongside your fixed R targets rather than replacing them.

🎚️ Conviction Controls — a compact set of dials sets how serious a failed grab must be before it counts: the Arm Threshold (the minimum charge that loads a spring at all), a Strong Tier cutoff, an optional Only Fire Strong-Tier Springs filter, the minimum grab depth, the reclaim window, and the ignition window that keeps an armed spring from waiting forever. Tighten them for fewer, cleaner discharges; loosen them for more activity. Combined with the six component weights, this is your main control over conviction versus frequency.

🧭 Ignition Gating & Single-Ticket Discipline — an armed spring is not a trade until it ignites: price must close through the ignition level set at load time. If the grab extreme is broken back the other way, the spring disarms; if the ignition window elapses with no trigger, it discharges unused and resets. Only one ticket is active at a time, so a single chaotic session can't stack overlapping trades, and resolution is SL-first pessimistic with honest partial-TP accounting — if a stop is hit after TP1 or TP2, that partial result is booked rather than rounded up.

⭐ 0–100 Charge with Star Tiers — every discharge is labeled with its numeric charge, a 1–5 star rank, and a tier ladder running FLAT → WEAK → PRIMED → STRONG → ELITE. Treat the charge as a cleanliness and confluence read for ranking and thinning setups — it describes how textbook a failed grab is, not a guaranteed outcome. The Arm Threshold and Only-Strong gate restrict what is displayed and alerted, while the dashboard keeps tracking every tier in the background.

📊 Live Statistics Dashboard — a non-intrusive panel tracks, in real time on your chart: the current bias (long spring / short spring / active / idle) and status (waiting → grab forming → spring loaded → discharging), a live charge meter with separate long- and short-spring readings, the magnet distance up and down in ATR, the last discharge with its star score, total signals, win rate, closed trades, profit factor, average R per trade, best-performing direction, long vs short win rate, current and max win/loss streaks, and a TP1 / TP2 / TP3 / SL outcome breakdown. Every filled trade that reaches an outcome is counted — winners and stop-outs alike — so the numbers are computed live from the real signals on your current symbol and timeframe, not a figure printed in a description.

🎨 Clean Themed Visuals — five coherent palettes (Midnight default, plus Emerald, Ice Blue, Gold Black, and Aqua Violet) shade the liquidity-pool lines, the ⚡ charge labels, the per-trade SL / TP ladder and zone boxes, and the dashboard to one look, so direction and quality read at a glance. Liquidity pools are drawn as color-keyed dotted levels; each discharge prints a ⚡ label with its charge, star tier, and direction arrow. The active ticket extends live to the right and then snaps cleanly back to its exit bar on close, so labels never float away — and a max-drawn-trades cap keeps only the most recent tickets on the chart while the statistics stay cumulative over the full history.

🔔 Detailed Alerts — fires on a long or short spring loaded (a qualifying failed grab), on long / short discharge (ignition), on any discharge, and on TP3 and SL events, formatted for manual or automated use. The strength gate can restrict alerts to higher-conviction springs.

🔧 Fully Customizable — every component is exposed: the pivot length that defines which pools count, the ATR length, the coil window and its looseness reference; the reclaim window, minimum grab depth, depth and volume energy references, volume baseline, and ignition window; the arm and strong thresholds, the only-strong filter, and all six charge weights; the universal risk distance and the three R targets; the opposing-liquidity magnet, level-shelf length, and max historical trades; the dashboard position, size, meter, and per-target breakdown; all five themes; and every pool, label, line, box, and star toggle.

🎯 Why this is different — most "liquidity" tools simply draw lines at old highs and lows and tell you a sweep happened. This one treats the failed sweep as the event, scores how much spring energy that failure stored across depth, velocity, wick, volume, compression, and displacement, and fires contrarian — fading the trapped breakout the way price actually tends to unwind — then anchors invalidation to the grab itself, projects the opposing pool the move is drawn toward, and layers an objective 0–100 ranking and a live, honest statistics panel that counts stop-outs in full. You tune and judge it on real, current data from your own chart instead of a marketing number.

🚀 Where to use it — the engine is symbol-agnostic and built on universal behavior: stop-runs and failed breakouts happen in every liquid market, so it can be applied to FX majors and crosses, metals, indices, and crypto, on intraday timeframes. Pivot length and the ATR-based stop adapt to each instrument's volatility automatically. Because it is a contrarian, mean-reversion engine, it shines in ranging and liquidity-hunting conditions and demands more care in strong one-way trends — let the dashboard tell you whether the logic suits the pair and timeframe before you commit.

🎯 How to trade it

Apply it to a liquid symbol on an intraday timeframe and let the dashboard populate. Read the live win rate, profit factor, and average R for your symbol and timeframe first — if the logic doesn't suit that market, you'll see it.
Wait for a ⚡ LONG / ⚡ SHORT discharge label — it marks a confirmed close through the ignition level after a failed grab, with the charge, star tier, and full Entry / SL / TP1 / TP2 / TP3 already plotted.
Use the opposing-liquidity magnet as a logical target read: it shows the unswept pool the discharge is being pulled toward.
Manage the trade with the plotted levels — the universal ATR stop defines your risk and TP1/2/3 sit at your chosen R multiples. Bank or trail however suits your style.
Use the Arm Threshold, Only-Strong gate, and the six charge weights to set your tempo — stricter for fewer, cleaner discharges; looser for more activity — and lean on the star tier to focus on the most textbook failed grabs.

⚠️ Important — this is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. Default settings were chosen on historical data and behavior will vary by symbol, timeframe, session, and configuration; the dashboard's statistics are historical and descriptive, not a forecast. The trade model resolves stop-first and books partial-target exits honestly, so some trades close for a fraction of a target rather than a full win or loss — these are counted in full, which is honest but means win rate alone is misleading; always weigh it together with average R and profit factor, and resize the R targets to your own risk profile. Signals confirm on the closed bar, so always wait for the labeled discharge on a closed candle. Because the system is contrarian by design, a sufficiently strong trend can run straight through a stop — combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6

indicator("Liquidity Propulsion Signals", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 1500)

var string gLiq = "01 · Liquidity & Coil"
pivotLen    = input.int(6,   "Liquidity Pivot Length", minval = 2, maxval = 50, group = gLiq, tooltip = "Bars each side to confirm a swing pivot. Larger = only major resting-liquidity pools.")
atrLen      = input.int(14,  "ATR Length", minval = 2, maxval = 100, group = gLiq)
coilLen     = input.int(10,  "Coil Window", minval = 3, maxval = 60, group = gLiq, tooltip = "Bars before the grab used to measure pre-grab compression (the wound spring).")
coilLoose   = input.float(5.0, "Coil Looseness Ref (ATR)", minval = 1.0, maxval = 20.0, step = 0.5, group = gLiq, tooltip = "Coil-window range (ATR) considered fully 'loose'. Tighter than this stores compression energy.")

var string gGrab = "02 · Grab & Spring"
reclaimBars = input.int(5,   "Max Reclaim Window", minval = 1, maxval = 30, group = gGrab, tooltip = "A pierced pool must be reclaimed within this many bars to count as a failed grab. Otherwise it is treated as genuine acceptance and ignored.")
minDepthAtr = input.float(0.10, "Min Grab Depth (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = gGrab, tooltip = "Minimum penetration beyond the pool to qualify as a grab.")
depthRef    = input.float(1.0, "Depth Energy Ref (ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = gGrab, tooltip = "Penetration depth (ATR) that scores full depth-energy.")
volLen      = input.int(20,  "Volume Baseline", minval = 2, maxval = 100, group = gGrab)
volRef      = input.float(2.2, "Volume Surge Ref (x)", minval = 1.1, maxval = 8.0, step = 0.1, group = gGrab, tooltip = "Volume multiple over baseline that scores full volume-energy.")
igniteWin   = input.int(8,   "Ignition Window", minval = 1, maxval = 40, group = gGrab, tooltip = "Bars a loaded spring stays armed waiting for ignition before discharging unused.")

var string gChg = "03 · Propulsion Charge"
armThresh   = input.int(55,  "Arm Threshold (Charge)", minval = 0, maxval = 100, group = gChg, tooltip = "Minimum Propulsion Charge for a failed grab to LOAD the spring and become tradable.")
strongThr   = input.int(78,  "Strong Tier (Charge)", minval = 0, maxval = 100, group = gChg)
onlyStrong  = input.bool(false, "Only Fire Strong-Tier Springs", group = gChg)
wDepth      = input.float(1.0, "Weight · Depth",        minval = 0, maxval = 3, step = 0.1, group = gChg)
wVel        = input.float(1.0, "Weight · Reclaim Speed", minval = 0, maxval = 3, step = 0.1, group = gChg)
wWick       = input.float(1.0, "Weight · Rejection Wick", minval = 0, maxval = 3, step = 0.1, group = gChg)
wVol        = input.float(1.0, "Weight · Volume Surge",  minval = 0, maxval = 3, step = 0.1, group = gChg)
wCoil       = input.float(1.0, "Weight · Coil Compression", minval = 0, maxval = 3, step = 0.1, group = gChg)
wDisp       = input.float(1.0, "Weight · Reclaim Displacement", minval = 0, maxval = 3, step = 0.1, group = gChg)

var string gTrade = "04 · Discharge Trade Model"
showTrades  = input.bool(true, "Simulate Discharge Trades", group = gTrade)
riskAtr     = input.float(1.0, "Risk Distance (ATR) — universal zone height", minval = 0.2, maxval = 6.0, step = 0.1, group = gTrade, tooltip = "Fixed stop distance in ATR. Every SL/TP zone is built from this, so all signals draw the SAME height — no super-wide or super-narrow zones.")
tp1R        = input.float(1.0, "TP1 (R)", minval = 0.3, maxval = 20, step = 0.1, group = gTrade)
tp2R        = input.float(2.0, "TP2 (R)", minval = 0.5, maxval = 30, step = 0.1, group = gTrade)
tp3R        = input.float(3.0, "TP3 (R)", minval = 0.5, maxval = 50, step = 0.1, group = gTrade)
useMagnet   = input.bool(true, "Show Opposing-Liquidity Magnet", group = gTrade, tooltip = "Project the nearest opposing unswept liquidity pool — the obvious target the discharge is drawn toward.")
levelLen    = input.int(12, "Level Shelf (bars)", minval = 2, maxval = 500, group = gTrade, tooltip = "Forward shelf length for live SL/TP labels. On close the whole ticket snaps back to the exit bar so labels never float away.")
showLines   = input.bool(true, "Show SL / TP Lines", group = gTrade)
showBoxes   = input.bool(true, "Show SL / TP Zones", group = gTrade)
showLevelLbl= input.bool(true, "Label Level Prices", group = gTrade)
showExitLbl = input.bool(true, "Show Trade Result Labels", group = gTrade)
maxHist     = input.int(25, "Max Historical Trades", minval = 1, maxval = 80, group = gTrade, tooltip = "Visual cap only. Statistics always count every closed trade.")

var string gDash = "05 · Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = gDash)
dashPosOpt  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gDash)
dashSizeOpt = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = gDash)
showMeter   = input.bool(true, "Show Charge Meter Rows", group = gDash)
showHeatRow = input.bool(true, "Show Per-Target Breakdown", group = gDash)

var string gVis = "06 · Visuals"
theme       = input.string("Midnight", "Color Theme", options = ["Midnight", "Emerald", "Ice Blue", "Gold Black", "Aqua Violet"], group = gVis)
showPools   = input.bool(true, "Show Liquidity Pools", group = gVis)
showSignal  = input.bool(true, "Show ⚡ Charge Labels", group = gVis)
showStars   = input.bool(true, "Show ★ Tier On Labels", group = gVis)
lblSizeOpt  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gVis)

longCol = theme == "Ice Blue" ? color.rgb(0, 190, 255) : theme == "Gold Black" ? color.rgb(255, 196, 48) : theme == "Aqua Violet" ? color.rgb(0, 230, 200) : theme == "Emerald" ? color.rgb(0, 200, 120) : color.rgb(33, 211, 168)
shortCol= theme == "Ice Blue" ? color.rgb(255, 120, 70) : theme == "Gold Black" ? color.rgb(255, 78, 60) : theme == "Aqua Violet" ? color.rgb(180, 110, 255) : theme == "Emerald" ? color.rgb(235, 64, 64) : color.rgb(255, 77, 109)
tpFill  = theme == "Ice Blue" ? color.rgb(0, 90, 130) : theme == "Gold Black" ? color.rgb(96, 74, 0) : theme == "Aqua Violet" ? color.rgb(0, 95, 90) : theme == "Emerald" ? color.rgb(0, 96, 60) : color.rgb(0, 96, 76)
slFill  = theme == "Ice Blue" ? color.rgb(150, 30, 70) : theme == "Gold Black" ? color.rgb(150, 40, 18) : theme == "Aqua Violet" ? color.rgb(110, 30, 120) : theme == "Emerald" ? color.rgb(150, 22, 30) : color.rgb(128, 24, 48)
chargeHi= theme == "Ice Blue" ? color.rgb(127, 233, 255) : theme == "Gold Black" ? color.rgb(255, 226, 122) : theme == "Aqua Violet" ? color.rgb(179, 136, 255) : color.rgb(255, 210, 63)

color panelBg     = #0a0c12
color panelBgAlt  = #0f131c
color panelHdr    = #161b27
color panelBorder = #2c3342
color txtHi       = #ebeef5
color txtLo       = #8791a2
color neutralCol  = #69748a
color goodCol     = #21c87a
color warnCol     = #e6be46
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

clamp(v, lo, hi) => math.min(math.max(v, lo), hi)
clamp01(v)       => math.min(math.max(v, 0.0), 1.0)

f_charge(depthAtr, barsToReclaim, wickFrac, volSurge, coilNormAtr, dispAtr) =>
    sDepth = clamp01(depthAtr / depthRef)
    sVel   = clamp01(1.0 - barsToReclaim / math.max(reclaimBars, 1))
    sWick  = clamp01(wickFrac)
    sVol   = clamp01((volSurge - 1.0) / math.max(volRef - 1.0, 0.1))
    sCoil  = clamp01((coilLoose - coilNormAtr) / math.max(coilLoose - 1.0, 0.1))
    sDisp  = clamp01(dispAtr / 0.6)
    wSum   = math.max(wDepth + wVel + wWick + wVol + wCoil + wDisp, 0.0001)
    raw    = (wDepth * sDepth + wVel * sVel + wWick * sWick + wVol * sVol + wCoil * sCoil + wDisp * sDisp) / wSum
    clamp(raw * 100.0, 0.0, 100.0)

f_gauge(v) =>
    fill = int(math.round(clamp(v, 0, 100) / 10.0))
    str.repeat("█", fill) + str.repeat("░", 10 - fill)

f_chTier(c)  => c >= 88 ? "ELITE" : c >= strongThr ? "STRONG" : c >= armThresh ? "PRIMED" : c >= 40 ? "WEAK" : "FLAT"
f_chStars(c) => c >= 88 ? "★★★★★" : c >= 78 ? "★★★★" : c >= 66 ? "★★★" : c >= 54 ? "★★" : c >= 40 ? "★" : "·"
f_signedR(v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

atr     = ta.atr(atrLen)
safeAtr = math.max(nz(atr, high - low), syminfo.mintick)
volAvg  = ta.sma(volume, volLen)

coilRangeN  = ta.highest(high, coilLen)[1] - ta.lowest(low, coilLen)[1]
coilNormNow = nz(coilRangeN, safeAtr) / safeAtr

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float sslLevel = na
var bool  sslDone  = false
var float bslLevel = na
var bool  bslDone  = false

var array<float> poolLowVal   = array.new<float>(0)
var array<bool>  poolLowSwept = array.new<bool>(0)
var array<float> poolHighVal  = array.new<float>(0)
var array<bool>  poolHighSwept= array.new<bool>(0)
var array<line>  poolLines    = array.new<line>(0)

if not na(pl)
    sslLevel := pl
    sslDone  := false
    array.push(poolLowVal, pl), array.push(poolLowSwept, false)
    if showPools
        array.push(poolLines, line.new(bar_index - pivotLen, pl, bar_index, pl, color = color.new(longCol, 60), style = line.style_dotted, width = 1))

if not na(ph)
    bslLevel := ph
    bslDone  := false
    array.push(poolHighVal, ph), array.push(poolHighSwept, false)
    if showPools
        array.push(poolLines, line.new(bar_index - pivotLen, ph, bar_index, ph, color = color.new(shortCol, 60), style = line.style_dotted, width = 1))

if array.size(poolLowVal) > 120
    array.shift(poolLowVal), array.shift(poolLowSwept)
if array.size(poolHighVal) > 120
    array.shift(poolHighVal), array.shift(poolHighSwept)
if array.size(poolLines) > 80
    line.delete(array.shift(poolLines))

var bool  Lpend = false
var int   LpBar = na
var float LpLow = na
var float LpCoil= na
var bool  Lload = false
var float Lcharge = na
var float LigniteLvl = na
var float LstopRef = na
var int   LloadBar = na
var bool  Upend = false
var int   UpBar = na
var float UpHigh= na
var float UpCoil= na
var bool  Uload = false
var float Ucharge = na
var float UigniteLvl = na
var float UstopRef = na
var int   UloadBar = na

bool fireLong = false
bool fireShort= false
float sigCharge = na

if not na(sslLevel) and not sslDone and not Lload
    if not Lpend
        if low < sslLevel
            Lpend := true
            LpBar := bar_index
            LpLow := low
            LpCoil:= coilNormNow
    else
        LpLow := math.min(LpLow, low)
    if Lpend and close > sslLevel
        depthAtr = (sslLevel - LpLow) / safeAtr
        if depthAtr >= minDepthAtr
            bToR     = bar_index - LpBar
            wickFrac = (math.min(open, close) - low) / math.max(high - low, syminfo.mintick)
            vSurge   = volume / math.max(nz(volAvg, volume), 1)
            ch       = f_charge(depthAtr, bToR, wickFrac, vSurge, nz(LpCoil, coilNormNow), (close - sslLevel) / safeAtr)
            if ch >= armThresh and (not onlyStrong or ch >= strongThr)
                Lload     := true
                Lcharge   := ch
                LigniteLvl:= high
                LstopRef  := LpLow
                LloadBar  := bar_index
        sslDone := true
        Lpend   := false
    if Lpend and (bar_index - LpBar) >= reclaimBars
        Lpend   := false
        sslDone := true

if Lload
    if close < LstopRef
        Lload := false
    else if close > LigniteLvl
        fireLong  := true
        sigCharge := Lcharge
        Lload     := false
    else if (bar_index - LloadBar) >= igniteWin
        Lload := false

if not na(bslLevel) and not bslDone and not Uload
    if not Upend
        if high > bslLevel
            Upend := true
            UpBar := bar_index
            UpHigh:= high
            UpCoil:= coilNormNow
    else
        UpHigh := math.max(UpHigh, high)
    if Upend and close < bslLevel
        depthAtr = (UpHigh - bslLevel) / safeAtr
        if depthAtr >= minDepthAtr
            bToR     = bar_index - UpBar
            wickFrac = (high - math.max(open, close)) / math.max(high - low, syminfo.mintick)
            vSurge   = volume / math.max(nz(volAvg, volume), 1)
            ch       = f_charge(depthAtr, bToR, wickFrac, vSurge, nz(UpCoil, coilNormNow), (bslLevel - close) / safeAtr)
            if ch >= armThresh and (not onlyStrong or ch >= strongThr)
                Uload     := true
                Ucharge   := ch
                UigniteLvl:= low
                UstopRef  := UpHigh
                UloadBar  := bar_index
        bslDone := true
        Upend   := false
    if Upend and (bar_index - UpBar) >= reclaimBars
        Upend   := false
        bslDone := true

if Uload
    if close > UstopRef
        Uload := false
    else if close < UigniteLvl
        fireShort := true
        sigCharge := Ucharge
        Uload     := false
    else if (bar_index - UloadBar) >= igniteWin
        Uload := false

if array.size(poolHighVal) > 0
    for i = 0 to array.size(poolHighVal) - 1
        if not array.get(poolHighSwept, i) and high > array.get(poolHighVal, i)
            array.set(poolHighSwept, i, true)
if array.size(poolLowVal) > 0
    for i = 0 to array.size(poolLowVal) - 1
        if not array.get(poolLowSwept, i) and low < array.get(poolLowVal, i)
            array.set(poolLowSwept, i, true)

f_magnetUp() =>
    float best = na
    if array.size(poolHighVal) > 0
        for i = array.size(poolHighVal) - 1 to 0
            if not array.get(poolHighSwept, i) and array.get(poolHighVal, i) > close
                best := array.get(poolHighVal, i)
                break
    best
f_magnetDn() =>
    float best = na
    if array.size(poolLowVal) > 0
        for i = array.size(poolLowVal) - 1 to 0
            if not array.get(poolLowSwept, i) and array.get(poolLowVal, i) < close
                best := array.get(poolLowVal, i)
                break
    best

var array<label> sigLbls = array.new<label>(0)

if showSignal and (fireLong or fireShort)
    isL = fireLong
    col = isL ? longCol : shortCol
    txt = "⚡ " + str.tostring(math.round(sigCharge)) + (showStars ? "  " + f_chStars(sigCharge) : "") + (isL ? "  ▲" : "  ▼")
    cl  = label.new(bar_index, isL ? low : high, txt, style = isL ? label.style_label_up : label.style_label_down, color = color.new(col, 8), textcolor = color.new(#0b0e16, 0), size = f_size(lblSizeOpt))
    array.push(sigLbls, cl)
    while array.size(sigLbls) > maxHist + 6
        label.delete(array.shift(sigLbls))

type ticket
    line  e  = na
    line  s  = na
    line  t1 = na
    line  t2 = na
    line  t3 = na
    line  mg = na
    box   tb = na
    box   sb = na
    label le = na
    label ls = na
    label l1 = na
    label l2 = na
    label l3 = na
    label ex = na

var array<ticket> history = array.new<ticket>()

var bool  tActive = false
var int   tSide   = 0
var int   tBar    = na
var float tEntry  = na
var float tStop   = na
var float tT1     = na
var float tT2     = na
var float tT3     = na
var int   bestStage = 0
var float tCharge = na
var line  aE = na
var line  aS = na
var line  a1 = na
var line  a2 = na
var line  a3 = na
var line  aM = na
var box   aTB= na
var box   aSB= na
var label lE = na
var label lS = na
var label l1 = na
var label l2 = na
var label l3 = na

var int   sClosed = 0
var int   sWins   = 0
var int   sTp1    = 0
var int   sTp2    = 0
var int   sTp3    = 0
var int   sSl     = 0
var float sR      = 0.0
var float sGrossW = 0.0
var float sGrossL = 0.0
var int   sLong     = 0
var int   sLongWin  = 0
var int   sShort    = 0
var int   sShortWin = 0
var int   sCurWin = 0
var int   sCurLos = 0
var int   sMaxWin = 0
var int   sMaxLos = 0
var int   sStreak = 0
var float lastChg = na
var int   lastSide = 0

aRight = tActive and not na(tBar) ? math.max(bar_index, tBar + levelLen) : na
if tActive
    if not na(aE)
        line.set_x2(aE, aRight)
    if not na(aS)
        line.set_x2(aS, aRight)
    if not na(a1)
        line.set_x2(a1, aRight)
    if not na(a2)
        line.set_x2(a2, aRight)
    if not na(a3)
        line.set_x2(a3, aRight)
    if not na(aM)
        line.set_x2(aM, aRight)
    if not na(aTB)
        box.set_right(aTB, aRight)
    if not na(aSB)
        box.set_right(aSB, aRight)
    if not na(lE)
        label.set_x(lE, aRight)
    if not na(lS)
        label.set_x(lS, aRight)
    if not na(l1)
        label.set_x(l1, aRight)
    if not na(l2)
        label.set_x(l2, aRight)
    if not na(l3)
        label.set_x(l3, aRight)

closedTp3 = false
closedSl  = false
closedTp  = false

if tActive
    isL = tSide == 1
    bool tp1Hit = isL ? high >= tT1 : low <= tT1
    bool tp2Hit = isL ? high >= tT2 : low <= tT2
    bool tp3Hit = isL ? high >= tT3 : low <= tT3
    bool slHit  = isL ? low  <= tStop : high >= tStop
    int  stage  = tp3Hit ? 3 : tp2Hit ? 2 : tp1Hit ? 1 : 0
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
        sR += resR
        if isWin
            sWins += 1
            sGrossW += resR
            sCurWin += 1
            sCurLos := 0
            sMaxWin := math.max(sMaxWin, sCurWin)
            sStreak := sCurWin
        else
            sGrossL += 1.0
            sCurLos += 1
            sCurWin := 0
            sMaxLos := math.max(sMaxLos, sCurLos)
            sStreak := -sCurLos
        if isL
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
        else
            sSl += 1
        int closeEdge = math.max(bar_index, tBar + 3)
        if not na(aE)
            line.set_x2(aE, closeEdge)
        if not na(aS)
            line.set_x2(aS, closeEdge)
        if not na(a1)
            line.set_x2(a1, closeEdge)
        if not na(a2)
            line.set_x2(a2, closeEdge)
        if not na(a3)
            line.set_x2(a3, closeEdge)
        if not na(aM)
            line.set_x2(aM, closeEdge)
        if not na(aTB)
            box.set_right(aTB, closeEdge)
        if not na(aSB)
            box.set_right(aSB, closeEdge)
        if not na(lE)
            label.set_x(lE, closeEdge)
        if not na(lS)
            label.set_x(lS, closeEdge)
        if not na(l1)
            label.set_x(l1, closeEdge)
        if not na(l2)
            label.set_x(l2, closeEdge)
        if not na(l3)
            label.set_x(l3, closeEdge)
        int rStage = finalTp3 ? 3 : finalTp ? bestStage : 0
        float resPx = finalTp3 ? tT3 : finalTp and rStage == 2 ? tT2 : finalTp and rStage == 1 ? tT1 : tStop
        string exTxt = finalTp3 ? "TP3 ✔ " + f_signedR(resR) : finalTp ? "TP" + str.tostring(rStage) + " ✔ " + f_signedR(resR) : "SL ✘ −1R"
        color exCol  = isWin ? goodCol : badCol
        label exLbl = na
        if showExitLbl
            exLbl := label.new(bar_index, resPx, exTxt, style = (isL == isWin) ? label.style_label_down : label.style_label_up, color = color.new(exCol, 6), textcolor = color.white, size = f_size(lblSizeOpt))
        array.push(history, ticket.new(aE, aS, a1, a2, a3, aM, aTB, aSB, lE, lS, l1, l2, l3, exLbl))
        while array.size(history) > maxHist
            ticket old = array.shift(history)
            line.delete(old.e), line.delete(old.s), line.delete(old.t1), line.delete(old.t2), line.delete(old.t3), line.delete(old.mg)
            box.delete(old.tb), box.delete(old.sb)
            label.delete(old.le), label.delete(old.ls), label.delete(old.l1), label.delete(old.l2), label.delete(old.l3), label.delete(old.ex)
        aE := na, aS := na, a1 := na, a2 := na, a3 := na, aM := na, aTB := na, aSB := na, lE := na, lS := na, l1 := na, l2 := na, l3 := na
        tActive := false
        tSide := 0
        tBar := na
        bestStage := 0

if showTrades and not tActive and (fireLong or fireShort) and not na(atr) and not closedTp3 and not closedSl and not closedTp
    isL  = fireLong
    ent  = close
    risk = safeAtr * riskAtr
    if risk > 0
        stp = isL ? ent - risk : ent + risk
        t1  = isL ? ent + risk * tp1R : ent - risk * tp1R
        t2  = isL ? ent + risk * tp2R : ent - risk * tp2R
        t3  = isL ? ent + risk * tp3R : ent - risk * tp3R
        tActive := true
        tSide := isL ? 1 : -1
        tBar := bar_index
        tEntry := ent
        tStop := stp
        tT1 := t1
        tT2 := t2
        tT3 := t3
        bestStage := 0
        tCharge := sigCharge
        lastChg := sigCharge
        lastSide := tSide
        col = isL ? longCol : shortCol
        xr  = bar_index + levelLen
        if showBoxes
            aTB := box.new(bar_index, isL ? t3 : ent, xr, isL ? ent : t3, xloc = xloc.bar_index, bgcolor = color.new(tpFill, 80), border_color = color.new(col, 40), border_width = 1)
            aSB := box.new(bar_index, isL ? ent : stp, xr, isL ? stp : ent, xloc = xloc.bar_index, bgcolor = color.new(slFill, 80), border_color = color.new(shortCol, 50), border_width = 1)
        if showLines
            aE := line.new(bar_index, ent, xr, ent, xloc = xloc.bar_index, color = color.new(col, 0), width = 2)
            aS := line.new(bar_index, stp, xr, stp, xloc = xloc.bar_index, color = color.new(badCol, 5), width = 1, style = line.style_dashed)
            a1 := line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(col, 15), width = 1)
            a2 := line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(col, 32), width = 1)
            a3 := line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(col, 48), width = 1)
            if useMagnet
                mg = isL ? f_magnetUp() : f_magnetDn()
                if not na(mg)
                    aM := line.new(bar_index, mg, xr, mg, xloc = xloc.bar_index, color = color.new(chargeHi, 25), width = 1, style = line.style_dotted)
        if showLevelLbl
            dw = isL ? "LONG ⚡" + str.tostring(math.round(sigCharge)) : "SHORT ⚡" + str.tostring(math.round(sigCharge))
            lE := label.new(xr, ent, dw + " @ " + str.tostring(ent, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 0), textcolor = color.white, size = f_size(lblSizeOpt))
            lS := label.new(xr, stp, "SL @ " + str.tostring(stp, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(badCol, 5), textcolor = color.white, size = f_size(lblSizeOpt))
            l1 := label.new(xr, t1, "TP1 " + str.tostring(tp1R, "#.#") + "R @ " + str.tostring(t1, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 12), textcolor = color.white, size = f_size(lblSizeOpt))
            l2 := label.new(xr, t2, "TP2 " + str.tostring(tp2R, "#.#") + "R @ " + str.tostring(t2, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 28), textcolor = color.white, size = f_size(lblSizeOpt))
            l3 := label.new(xr, t3, "TP3 " + str.tostring(tp3R, "#.#") + "R @ " + str.tostring(t3, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 44), textcolor = color.white, size = f_size(lblSizeOpt))

winRate = sClosed > 0 ? sWins / sClosed * 100.0 : 0.0
avgR    = sClosed > 0 ? sR / sClosed : 0.0
pf      = sGrossL > 0 ? sGrossW / sGrossL : sGrossW > 0 ? 999.0 : 0.0
longWR  = sLong  > 0 ? sLongWin  / sLong  * 100.0 : 0.0
shortWR = sShort > 0 ? sShortWin / sShort * 100.0 : 0.0
tp1Rate = sClosed > 0 ? sTp1 / sClosed * 100.0 : 0.0
tp2Rate = sClosed > 0 ? sTp2 / sClosed * 100.0 : 0.0
tp3Rate = sClosed > 0 ? sTp3 / sClosed * 100.0 : 0.0
slRate  = sClosed > 0 ? sSl  / sClosed * 100.0 : 0.0

liveL = Lload ? Lcharge : 0.0
liveU = Uload ? Ucharge : 0.0
domLong = Lload and (not Uload or liveL >= liveU)
domBias = domLong ? "LONG SPRING" : Uload ? "SHORT SPRING" : tActive ? (tSide == 1 ? "LONG ACTIVE" : "SHORT ACTIVE") : "— IDLE —"
domCol  = domLong ? longCol : Uload ? shortCol : tActive ? (tSide == 1 ? longCol : shortCol) : neutralCol
domChg  = math.max(liveL, liveU)

magUp = f_magnetUp()
magDn = f_magnetDn()
distTxt = not na(magUp) or not na(magDn) ? (not na(magUp) ? str.tostring(math.round((magUp - close) / safeAtr * 10) / 10, "#.#") : "—") + "↑ / " + (not na(magDn) ? str.tostring(math.round((close - magDn) / safeAtr * 10) / 10, "#.#") : "—") + "↓" : "—"

statusTxt = tActive ? "DISCHARGING" : (Lload or Uload) ? "SPRING LOADED" : (Lpend or Upend) ? "GRAB FORMING" : "WAITING"
statusC   = tActive ? domCol : (Lload or Uload) ? chargeHi : (Lpend or Upend) ? warnCol : neutralCol
lastTxt   = lastSide == 1 ? "LONG" : lastSide == -1 ? "SHORT" : "—"
lastChgTxt= na(lastChg) ? "—" : f_chStars(lastChg) + " " + str.tostring(math.round(lastChg))
bestDir = sLong == 0 and sShort == 0 ? "—" : sLong > 0 and sShort == 0 ? "LONG" : sShort > 0 and sLong == 0 ? "SHORT" : longWR > shortWR ? "LONG" : shortWR > longWR ? "SHORT" : "EVEN"
streakTxt = sStreak > 0 ? "W" + str.tostring(sStreak) : sStreak < 0 ? "L" + str.tostring(math.abs(sStreak)) : "—"
pfTxt = pf >= 999.0 ? "INF" : str.tostring(pf, "#.##")
wrC = winRate >= 55 ? goodCol : winRate >= 45 ? warnCol : badCol
pfC = pf >= 1.5 ? goodCol : pf >= 1.0 ? warnCol : badCol

var int meterRows = showMeter ? 5 : 0
var int baseRows  = 10
var int dashRows  = baseRows + meterRows + (showHeatRow ? 1 : 0)
var table dash = table.new(f_pos(dashPosOpt), 2, dashRows, frame_color = color.new(panelBorder, 0), frame_width = 1, border_color = color.new(panelBorder, 30), border_width = 1)

f_row(int r, string k, string v, color vc, color bg) =>
    ps = f_size(dashSizeOpt)
    table.cell(dash, 0, r, k, text_color = txtLo, text_size = ps, text_halign = text.align_left,   bgcolor = bg)
    table.cell(dash, 1, r, v, text_color = vc,    text_size = ps, text_halign = text.align_center, bgcolor = bg)

if barstate.islast and showDash
    ps = f_size(dashSizeOpt)
    table.clear(dash, 0, 0, 1, dashRows - 1)
    table.cell(dash, 0, 0, "⚡ LIQUIDITY PROPULSION", text_color = txtHi, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
    table.cell(dash, 1, 0, "SYSTEM", text_color = chargeHi, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)

    int r = 1
    f_row(r, "Bias", domBias, domCol, panelBg), r += 1
    f_row(r, "Status", statusTxt, statusC, panelBgAlt), r += 1
    if showMeter
        f_row(r, "Charge", f_gauge(domChg) + " " + str.tostring(math.round(domChg)), domChg >= strongThr ? chargeHi : domChg >= armThresh ? warnCol : txtLo, panelBg), r += 1
        f_row(r, "Long Spring",  Lload ? f_gauge(liveL) + " " + str.tostring(math.round(liveL)) : "—", Lload ? longCol  : txtLo, panelBgAlt), r += 1
        f_row(r, "Short Spring", Uload ? f_gauge(liveU) + " " + str.tostring(math.round(liveU)) : "—", Uload ? shortCol : txtLo, panelBg), r += 1
        f_row(r, "Magnet Dist (ATR)", distTxt, txtHi, panelBgAlt), r += 1
        f_row(r, "Last Discharge", lastTxt + "  " + lastChgTxt, lastSide == 1 ? longCol : lastSide == -1 ? shortCol : neutralCol, panelBg), r += 1
    f_row(r, "Active Trade", tActive ? (tSide == 1 ? "LONG OPEN" : "SHORT OPEN") : "FLAT", tActive ? domCol : neutralCol, panelBgAlt), r += 1
    f_row(r, "Win Rate", sClosed > 0 ? str.tostring(winRate, "#.#") + "%  (" + str.tostring(sWins) + "/" + str.tostring(sClosed) + ")" : "—", sClosed > 0 ? wrC : neutralCol, panelBg), r += 1
    f_row(r, "Profit Factor", sClosed > 0 ? pfTxt : "—", sClosed > 0 ? pfC : neutralCol, panelBgAlt), r += 1
    f_row(r, "Avg R / Trade", sClosed > 0 ? f_signedR(avgR) : "—", sClosed > 0 ? (avgR >= 0 ? goodCol : badCol) : neutralCol, panelBg), r += 1
    f_row(r, "Best Direction", bestDir, bestDir == "LONG" ? longCol : bestDir == "SHORT" ? shortCol : neutralCol, panelBgAlt), r += 1
    f_row(r, "L / S Win%", sClosed > 0 ? str.tostring(longWR, "#") + " / " + str.tostring(shortWR, "#") : "—", txtHi, panelBg), r += 1
    f_row(r, "Streak", streakTxt + "  (max W" + str.tostring(sMaxWin) + "/L" + str.tostring(sMaxLos) + ")", sStreak >= 0 ? goodCol : badCol, panelBgAlt), r += 1
    if showHeatRow
        table.cell(dash, 0, r, "TP1/2/3 · SL", text_color = txtLo, text_size = ps, text_halign = text.align_left, bgcolor = panelHdr)
        table.cell(dash, 1, r, str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#") + " · " + str.tostring(slRate, "#") + "%", text_color = txtHi, text_size = ps, text_halign = text.align_center, bgcolor = panelHdr)

springLoadedL = Lload and not Lload[1]
springLoadedU = Uload and not Uload[1]
alertcondition(springLoadedL, "Long Spring Loaded",  "Liquidity Propulsion: failed sell-side grab loaded a LONG spring.")
alertcondition(springLoadedU, "Short Spring Loaded", "Liquidity Propulsion: failed buy-side grab loaded a SHORT spring.")
alertcondition(fireLong,  "Discharge LONG",  "Liquidity Propulsion: LONG discharge (contrarian fade of failed breakdown).")
alertcondition(fireShort, "Discharge SHORT", "Liquidity Propulsion: SHORT discharge (contrarian fade of failed breakout).")
alertcondition(fireLong or fireShort, "Any Discharge", "Liquidity Propulsion discharge fired.")
alertcondition(closedTp3, "TP3 Hit", "Liquidity Propulsion: TP3 reached.")
alertcondition(closedSl,  "SL Hit",  "Liquidity Propulsion: stop hit.")
````
