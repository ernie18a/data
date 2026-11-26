# Cumulative Volume Delta Flow [AGPro Series]

- url: https://www.tradingview.com/script/mCrRBwvd-Cumulative-Volume-Delta-Flow-AGPro-Series/
- type: indicator
- pine_id: PUB;cf5d4f62ffb44736a8cb55a297662768
- version: 4.0

## Description

Cumulative Volume Delta Flow [AGPro Series]

🔹 **Overview**

Cumulative Volume Delta Flow is a hybrid CVD engine designed to expose order-flow imbalances without requiring footprint charts or exchange-native buy/sell data. It reconstructs cumulative delta using lower-timeframe breakdown when available, with intrabar polarity as a universal fallback — making it work on every symbol and every timeframe. On top of this engine, a triple-layer divergence detector identifies Regular, Hidden, and statistical Exhaustion signals, and every signal is scored by its own statistical strength with a ★/★★/★★★ rating system printed directly on the label.

The indicator is built for traders who want smart-money context at a glance: when buyers are absorbing, when a rally is losing real participation, and when a climactic flush is likely to reverse — with an immediate visual cue of how strong each signal is relative to the recent flow regime.

[image]https://www.tradingview.com/x/lXX7gxiF/[/image]

🔹 **Unique Edge**

Most CVD indicators are single-mode: either they plot cumulative delta, or they call a Regular divergence. This script combines four layers that rarely appear together in one tool:

- Hybrid engine with transparent fallback (no silent failure on high TFs)
- Exhaustion detection based on standard-deviation of CVD change, not price — catches reversals that price-only divergence misses
- Per-signal ★/★★/★★★ strength rating using type-specific statistical metrics (pivot-gap σ for Regular/Hidden, change σ for Exhaustion), so traders instantly know which signals deserve attention
- Optional reaction zones anchored at flow-driven pivots, behaving as dynamic support/resistance born from real participation events rather than pure price structure

🔹 **Methodology**

- The engine computes two parallel delta streams every bar: an intrabar polarity stream (weighted by wick balance for neutral/doji candles) and a lower-timeframe stream that iterates sub-bars and signs each by its close-vs-open direction
- In Hybrid mode, the LTF stream is preferred when it yields a non-zero value; the intrabar stream is used as fallback so the indicator never goes blank on exotic tickers or high timeframes
- A session/daily/weekly reset prevents long-run drift and keeps the cumulative counter meaningful across regime changes
- Pivots are detected on both price and CVD with a shared lookback window; the last two price pivots and their paired CVD values are tested for all four classical divergence relationships
- Exhaustion is a separate statistical trigger: the single-bar CVD change is compared against a 50-bar standard deviation; a σ breach in the direction opposite to the candle body is flagged as climactic absorption
- Each divergence label is rated with stars based on its type: Regular and Hidden use the CVD-pivot gap normalized by 50-bar CVD level stdev (how far apart the two flow pivots are), while Exhaustion uses the σ multiple of the current CVD change (how extreme the climactic event is)
- A cooldown window suppresses signal clustering in chop, and labels are offset by ATR-scaled distance with a leader line so they never collide with candles

🔹 **Signals & Alerts**

On-chart labels with star rating:

- Reg Bull / Reg Bear ★-★★★ — classical reversal divergence (price exhausts, flow refuses)
- Hid Bull / Hid Bear ★-★★★ — continuation divergence (pullback inside an active trend)
- Exh Bull / Exh Bear ★-★★★ — statistical flow climax above the σ threshold

Star thresholds for Regular/Hidden: ★★★ ≥ 2.0σ gap, ★★ ≥ 1.0σ gap, ★ < 1.0σ.
Star thresholds for Exhaustion: ★★★ ≥ 3.0σ, ★★ ≥ 2.0σ, ★ < 2.0σ (minimum trigger is 1.75σ).

Each signal carries its own color code and a leader line connecting the label back to the source candle for fast visual reading. Six discrete alertcondition slots are exposed plus three proactive alert() calls grouped by divergence family, so traders can route regular, hidden, and exhaustion signals to different channels.

🔹 **Key Inputs**

- Calculation Method: Hybrid, LTF Only, or Intrabar Only
- LTF Resolution: Auto (adaptive by chart TF) or fixed 1 / 3 / 5 / 15m
- CVD Reset: Session, Daily, Weekly, or None
- Pivot Length: 2–15 bars
- Toggles for Regular / Hidden / Exhaustion layers independently
- Exhaustion Threshold (σ): 1.0–4.0, default 1.75
- Min Bars Between Signals: anti-clustering cooldown (default 15)
- Reaction Zones: optional, with ATR width, extend length, and max active cap
- Label Size + Label Offset (ATR) for visual tuning
- Info Panel: 5 positions, 4 text sizes, full hide toggle

🔹 **How to Use**

- On the 4H timeframe, run the defaults on liquid instruments: BTCUSDT, ETHUSDT, SPX, ES, major FX pairs
- Treat ★★★ signals as the highest-priority reads of the chart — these are statistical outliers
- Treat ★★ signals as the normal tradeable population — the bulk of decision-making happens here
- Treat ★ signals as background context — use them for bias confirmation, not as primary entries
- Regular divergences are reversal warnings at structural highs/lows; they are most reliable when aligned with a key horizontal level or trendline
- Hidden divergences are trend-continuation entries during pullbacks inside a confirmed trend
- Exhaustion signals mark participation climaxes and often coincide with short-term reversals even when no classical pivot has formed yet
- Check the Info Panel's Last Signal row for the most recent event type and its star rating without scanning the chart
- Enable Reaction Zones when you want persistent S/R context from flow events; keep them off for minimal, label-only use
- Consider combining with a structure tool from the AGPro Series (SFP, Breaker, Unicorn) for confluence

🔹 **Info Panel**

The compact info panel on the chart surfaces seven live metrics: the current cumulative CVD value, the CVD trend classification (Up/Down/Flat based on price relative to its own EMA 21), the last signal's full name and star rating in color, the rolling divergence count over the last 200 bars (Bull / Bear), and the bar-age of the most recent bullish and bearish events. This gives a full situational snapshot without scrolling.

🔹 **Limitations & Transparency**

- CVD from intrabar polarity is an approximation, not true tick-level order flow. Exchange-native buy/sell volume is only available through footprint data
- On very high timeframes (Daily+), LTF breakdown may return partial data; Hybrid mode is recommended
- Divergence signals appear only after both pivot legs are confirmed; the second pivot needs `pivotLen` bars of right-side confirmation, so signals print with that lag
- Exhaustion requires at least 50 bars of CVD history for the standard-deviation baseline
- Star ratings are statistical descriptors of signal strength relative to recent flow, not trade-quality guarantees
- Past performance of any divergence pattern does not guarantee future results; this tool surfaces probabilistic context, not guaranteed reversals

🔹 **Risk Disclosure**

This indicator is an analytical framework, not a trading system or financial advice. Signals are technical observations intended to support decision-making; they do not account for fundamentals, news, liquidity, or your risk tolerance. Always use proper position sizing, stop-loss placement, and risk management. Test the tool on historical data and in a simulated environment before deploying it on live capital. Trading carries risk of substantial loss.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Cumulative Volume Delta Flow [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Hybrid Cumulative Volume Delta (CVD) engine with triple-layer divergence
// detection — Regular, Hidden, and Exhaustion — built for order-flow analysis
// without footprint charts. Uses lower-timeframe buy/sell breakdown when
// available, with intrabar polarity fallback for universal TF coverage.
// Designed to surface smart-money absorption, trend continuation, and
// climactic reversals by comparing price structure against cumulative flow. A
// confirmation-anchored Signal Hit Rate logs how often a divergence is followed
// by a balanced move in its own direction on the current chart history.
// ─────────────────────────────────────────────────

//@version=6
indicator("Cumulative Volume Delta Flow [AGPro Series]",
     shorttitle = "AG Pro CVD",
     overlay    = false,
     max_labels_count = 200,
     max_lines_count  = 200,
     max_boxes_count  = 100)

// ═════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════
grpEngine = "CVD Engine"
engineMode = input.string("Hybrid (LTF + Fallback)", "Calculation Method",
     options=["Hybrid (LTF + Fallback)", "Lower Timeframe Only", "Intrabar Polarity Only"],
     tooltip="Hybrid: Uses 1m/5m LTF for true buy/sell split when available, falls back to bar polarity otherwise. LTF Only: strictest order-flow accuracy (may fail on high TFs). Intrabar: universal, slightly less precise.",
     group=grpEngine)
ltfRes = input.string("Auto", "LTF Resolution",
     options=["Auto", "1", "3", "5", "15"],
     tooltip="Lower timeframe for buy/sell volume breakdown. Auto selects based on chart TF to balance speed and precision.",
     group=grpEngine)
cvdReset = input.string("Session", "CVD Reset",
     options=["Session", "Daily", "Weekly", "None"],
     tooltip="Resets the cumulative counter to prevent long-term drift. Session resets at each new trading session.",
     group=grpEngine)

grpDiv = "Divergence Detection"
pivotLen = input.int(5, "Pivot Length", minval=2, maxval=15,
     tooltip="Bars left/right required to confirm a pivot. Higher = fewer but stronger signals.",
     group=grpDiv)
showRegular = input.bool(true, "Regular Divergence",
     tooltip="Classic reversal signal: price makes HH/LL but CVD fails to confirm. Suggests exhausted momentum.",
     group=grpDiv)
showHidden = input.bool(true, "Hidden Divergence",
     tooltip="Trend continuation signal: price makes HL/LH while CVD makes LL/HH. Suggests pullback within trend.",
     group=grpDiv)
showExhaust = input.bool(true, "Exhaustion Divergence",
     tooltip="CVD reaches statistical extreme while price fails to follow. Captures climactic reversals invisible to price-only analysis.",
     group=grpDiv)
exhaustSigma = input.float(1.75, "Exhaustion Threshold (σ)", minval=1.0, maxval=4.0, step=0.1,
     tooltip="Standard deviations of CVD change required to flag exhaustion. 1.75 = top/bottom ~8% of flow events. Lower = more signals.",
     group=grpDiv)
minBarsBetween = input.int(15, "Min Bars Between Signals", minval=3, maxval=50,
     tooltip="Cooldown to prevent signal clustering in choppy price action.",
     group=grpDiv)
proofTargetAtr = input.float(1.0, "Proof Target (ATR)", minval=0.2, maxval=5.0, step=0.1,
     tooltip="Balanced symmetric distance, in ATR, used by the Signal Hit Rate. A win is a move one target in the signal direction before the same distance against it.",
     group=grpDiv)
proofWindowBars = input.int(20, "Proof Window Bars", minval=5, maxval=200,
     tooltip="Bars allowed for a signal to reach its favorable or adverse target before the sample is left unresolved (uncounted) in the Signal Hit Rate.",
     group=grpDiv)

grpZone = "Reaction Zones"
showZones = input.bool(false, "Show Reaction Zones",
     tooltip="Draws horizontal zones at divergence pivots. Acts as dynamic support/resistance from flow events. Disabled by default for minimal visual load.",
     group=grpZone)
zoneWidthATR = input.float(0.35, "Zone Width (ATR)", minval=0.1, maxval=2.0, step=0.05,
     tooltip="Half-height of each zone in ATR units. 0.35 balances visibility with precision.",
     group=grpZone)
zoneExtend = input.int(60, "Zone Extend (bars)", minval=10, maxval=500,
     tooltip="How far each zone extends to the right after birth.",
     group=grpZone)
maxZones = input.int(6, "Max Active Zones", minval=2, maxval=15,
     tooltip="Caps on-chart zones. Oldest gets evicted when limit is reached.",
     group=grpZone)

grpVis = "Visuals"
showCVDPlot = input.bool(true, "Plot CVD Area", group=grpVis)
showCVDMA = input.bool(true, "CVD Signal Line (EMA 21)", group=grpVis)
showTrendBadge = input.bool(false, "CVD Trend Badge (on price)",
     tooltip="Shows a colored dot at the top of the CVD sub-panel whenever CVD trend changes (Up → Down or vice versa). Off by default for minimal visuals.",
     group=grpVis)
labelSize = input.string("Normal", "Label Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=grpVis)
labelOffsetATR = input.float(1.5, "Label Offset (ATR)", minval=0.3, maxval=5.0, step=0.1,
     tooltip="Pushes labels away from candles to prevent overlap. Leader line connects back to the bar.",
     group=grpVis)
maxVisibleSignals = input.int(8, "Maximum Visible Divergences", minval=4, maxval=40,
     tooltip="Caps retained divergence badges and leader lines. Older events are removed first to preserve a balanced publication view.",
     group=grpVis)
showFlowContextBadge = input.bool(true, "Show Flow Context Badge",
     tooltip="Shows one live filled badge in the CVD pane summarizing the confirmed flow regime and whether a fresh divergence is active.",
     group=grpVis)
flowBadgeOffset = input.int(4, "Flow Badge Offset Bars", minval=1, maxval=30,
     tooltip="Places the live flow-context badge to the right of the latest CVD bar.",
     group=grpVis)

grpPanel = "Info Panel"
showPanel = input.bool(true, "Show Panel", group=grpPanel)
panelLoc = input.string("Top Right", "Location",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group=grpPanel)
panelTheme = input.string("Dark", "Theme", options=["Dark","Light","Slate"], group=grpPanel,
     tooltip="Selects the panel surface theme while preserving the merged AG Pro blue header row.")
panelTextSize = input.string("Normal", "Panel Text Size",
     options=["Tiny","Small","Normal","Large"],
     group=grpPanel)

grpAlerts = "Alerts"
alertOnRegular = input.bool(true, "Alert on Regular Divergence", group=grpAlerts)
alertOnHidden = input.bool(false, "Alert on Hidden Divergence", group=grpAlerts)
alertOnExhaust = input.bool(true, "Alert on Exhaustion", group=grpAlerts)

// ═════════════════════════════════════════════════
// COLOR PALETTE — AGPro Standard
// ═════════════════════════════════════════════════
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelBgLight  = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
panelBgSlate  = color.rgb(30, 41, 59)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
darkText      = color.rgb(17, 24, 39)

// ═════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════
f_sizeFrom(s) =>
    s == "Tiny"   ? size.tiny :
     s == "Small"  ? size.small :
     s == "Normal" ? size.normal :
     size.large

f_panelPos(p) =>
    p == "Top Left"      ? position.top_left :
     p == "Top Center"    ? position.top_center :
     p == "Top Right"     ? position.top_right :
     p == "Middle Left"   ? position.middle_left :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right"  ? position.middle_right :
     p == "Bottom Left"   ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center :
     position.bottom_right

f_text_on(col) =>
    bright = (color.r(col) * 299 + color.g(col) * 587 + color.b(col) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_autoLTF() =>
    tfMin = timeframe.in_seconds() / 60
    tfMin <= 15  ? "1" :
     tfMin <= 60  ? "3" :
     tfMin <= 240 ? "5" :
     "15"

f_resolveLTF() =>
    ltfRes == "Auto" ? f_autoLTF() : ltfRes

// ═════════════════════════════════════════════════
// CVD CALCULATION — HYBRID
// ═════════════════════════════════════════════════
// Intrabar polarity fallback (always computed — cheap)
polarity = close > open ? 1.0 : close < open ? -1.0 : 0.0
// refine by wick balance for doji/neutral bars
wickUp = high - math.max(open, close)
wickDn = math.min(open, close) - low
refinedPol = polarity != 0 ? polarity : (wickDn > wickUp ? 0.5 : wickUp > wickDn ? -0.5 : 0.0)
barDeltaIntra = refinedPol * nz(volume)

// LTF breakdown via request.security_lower_tf
// Must be called at global scope (Pine v6 requirement)
ltfStr = f_resolveLTF()
[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfStr, [open, close, volume])

f_calcLTFDelta() =>
    float d = 0.0
    if array.size(ltfO) > 0
        for i = 0 to array.size(ltfO) - 1
            lo = array.get(ltfO, i)
            lc = array.get(ltfC, i)
            lv = array.get(ltfV, i)
            pol = lc > lo ? 1.0 : lc < lo ? -1.0 : 0.0
            d += pol * nz(lv)
    d

// Only use LTF result when engine mode needs it
float ltfDelta = engineMode == "Intrabar Polarity Only" ? 0.0 : f_calcLTFDelta()
bool ltfUsable = engineMode != "Intrabar Polarity Only" and ltfDelta != 0

float barDelta = 0.0
if engineMode == "Lower Timeframe Only"
    barDelta := ltfDelta
else if engineMode == "Intrabar Polarity Only"
    barDelta := barDeltaIntra
else
    barDelta := ltfUsable ? ltfDelta : barDeltaIntra

// Reset logic
bool isReset = false
if cvdReset == "Session"
    isReset := session.isfirstbar_regular
else if cvdReset == "Daily"
    isReset := ta.change(dayofmonth) != 0
else if cvdReset == "Weekly"
    isReset := ta.change(weekofyear) != 0

var float cvd = 0.0
cvd := isReset ? barDelta : cvd + barDelta

cvdMA = ta.ema(cvd, 21)
cvdChange = cvd - nz(cvd[1])
cvdChangeStd = ta.stdev(cvdChange, 50)
cvdLevelStd = ta.stdev(cvd, 50)  // For divergence strength normalization

// Trend classification
cvdTrend = cvd > cvdMA and cvd > nz(cvd[3]) ? 1 :
           cvd < cvdMA and cvd < nz(cvd[3]) ? -1 : 0

// ═════════════════════════════════════════════════
// ATR FOR LABELS / ZONES
// ═════════════════════════════════════════════════
atr14 = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)

// ═════════════════════════════════════════════════
// PIVOT DETECTION
// ═════════════════════════════════════════════════
pivHighPrice = ta.pivothigh(high, pivotLen, pivotLen)
pivLowPrice  = ta.pivotlow(low,  pivotLen, pivotLen)

// Store last two price pivots + corresponding CVD values
var float lastPH1 = na, var float lastPH2 = na
var float cvdPH1 = na, var float cvdPH2 = na

var float lastPL1 = na, var float lastPL2 = na
var float cvdPL1 = na, var float cvdPL2 = na

if not na(pivHighPrice)
    lastPH2 := lastPH1
    cvdPH2  := cvdPH1
    lastPH1 := pivHighPrice
    cvdPH1  := cvd[pivotLen]

if not na(pivLowPrice)
    lastPL2 := lastPL1
    cvdPL2  := cvdPL1
    lastPL1 := pivLowPrice
    cvdPL1  := cvd[pivotLen]

// ═════════════════════════════════════════════════
// DIVERGENCE LOGIC
// ═════════════════════════════════════════════════
var int lastSignalBar = -1000
cooldownOK = bar_index - lastSignalBar >= minBarsBetween

// Regular Bearish: price HH, CVD LH → exhausted rally
regBear = barstate.isconfirmed and showRegular and not na(pivHighPrice) and not na(lastPH2) and
          lastPH1 > lastPH2 and cvdPH1 < cvdPH2 and cooldownOK

// Regular Bullish: price LL, CVD HL → exhausted selloff
regBull = barstate.isconfirmed and showRegular and not na(pivLowPrice) and not na(lastPL2) and
          lastPL1 < lastPL2 and cvdPL1 > cvdPL2 and cooldownOK

// Hidden Bearish: price LH, CVD HH → trend continuation (down)
hidBear = barstate.isconfirmed and showHidden and not na(pivHighPrice) and not na(lastPH2) and
          lastPH1 < lastPH2 and cvdPH1 > cvdPH2 and cooldownOK

// Hidden Bullish: price HL, CVD LL → trend continuation (up)
hidBull = barstate.isconfirmed and showHidden and not na(pivLowPrice) and not na(lastPL2) and
          lastPL1 > lastPL2 and cvdPL1 < cvdPL2 and cooldownOK

// Exhaustion: CVD change exceeds σ threshold against price direction
exhStd = nz(cvdChangeStd, 0.0)
exhThreshold = exhStd * exhaustSigma
exhBear = barstate.isconfirmed and showExhaust and cvdChange > exhThreshold and close < open and exhStd > 0 and cooldownOK
exhBull = barstate.isconfirmed and showExhaust and cvdChange < -exhThreshold and close > open and exhStd > 0 and cooldownOK

anyBull = regBull or hidBull or exhBull
anyBear = regBear or hidBear or exhBear

if anyBull or anyBear
    lastSignalBar := bar_index

// ═════════════════════════════════════════════════
// SIGNAL-HIT-RATE PROOF
// On a divergence, a win is recorded when price moves one balanced target
// (proofTargetAtr in ATR) in the signal direction before the same distance
// against it. Same-bar ambiguity resolves conservatively as a loss, and
// samples that resolve neither inside the window are left unresolved and
// uncounted. Updated only on confirmed bars so the statistic does not repaint.
// ═════════════════════════════════════════════════
var int   sigWins    = 0
var int   sigTotal   = 0
var bool  sigPending = false
var int   sigDir     = 0
var float sigFav     = na
var float sigAdv     = na
var int   sigStart   = na

if barstate.isconfirmed
    if sigPending
        favHit = sigDir == 1 ? high >= sigFav : low <= sigFav
        advHit = sigDir == 1 ? low <= sigAdv : high >= sigAdv
        expired = bar_index - sigStart >= proofWindowBars
        if favHit and advHit
            sigTotal += 1
            sigPending := false
        else if favHit
            sigWins += 1
            sigTotal += 1
            sigPending := false
        else if advHit
            sigTotal += 1
            sigPending := false
        else if expired
            sigPending := false
    if anyBull or anyBear
        dir = anyBull ? 1 : -1
        k = math.max(proofTargetAtr * atr14, syminfo.mintick)
        sigDir := dir
        sigFav := close + dir * k
        sigAdv := close - dir * k
        sigStart := bar_index
        sigPending := true

float sigRate = sigTotal > 0 ? sigWins / sigTotal * 100.0 : na

// ═════════════════════════════════════════════════
// LABELS
// ═════════════════════════════════════════════════
// Star rating — each divergence type uses its own strength metric:
//
// Regular/Hidden:  |Δ CVD| / CVD level stdev  (how far apart the two CVD pivots are)
//                  → measures flow separation magnitude
//                  ★★★ ≥ 2.0σ  |  ★★ ≥ 1.0σ  |  ★ < 1.0σ
//
// Exhaustion:      |CVD change| / CVD change stdev  (σ multiple of the flow spike)
//                  → measures climactic intensity
//                  ★★★ ≥ 3.0σ  |  ★★ ≥ 2.0σ  |  ★ < 2.0σ  (min trigger is 1.75σ)
f_starsFromSigma(sigmaVal, isExhaustion) =>
    hi = isExhaustion ? 3.0 : 2.0
    mid = isExhaustion ? 2.0 : 1.0
    sigmaVal >= hi ? "★★★" : sigmaVal >= mid ? "★★" : "★"

var array<label> signalLabels = array.new<label>()
var array<line> signalLeaders = array.new<line>()

f_drawSignal(isBull, baseTxt, col, starsTxt) =>
    yBase = isBull ? low : high
    yOff  = isBull ? -labelOffsetATR * atr14 : labelOffsetATR * atr14
    yPos  = yBase + yOff
    style = isBull ? label.style_label_up : label.style_label_down
    txt   = baseTxt + " " + starsTxt
    sigLabel = label.new(bar_index, yPos, txt,
         xloc=xloc.bar_index, yloc=yloc.price,
         color=col, textcolor=f_text_on(col),
         style=style, size=f_sizeFrom(labelSize),
         force_overlay=true)
    sigLeader = line.new(bar_index, yBase, bar_index, yPos,
         color=color.new(col, 40), width=1,
         force_overlay=true)
    array.push(signalLabels, sigLabel)
    array.push(signalLeaders, sigLeader)
    if array.size(signalLabels) > maxVisibleSignals
        label.delete(array.shift(signalLabels))
        line.delete(array.shift(signalLeaders))

// Strength metrics per divergence type
cvdLvlStd = nz(cvdLevelStd, 0.0)
// Regular/Hidden — CVD gap between pivots, normalized by CVD level stdev
divHighGap = not na(cvdPH1) and not na(cvdPH2) and cvdLvlStd > 0 ?
             math.abs(cvdPH1 - cvdPH2) / cvdLvlStd : 0.0
divLowGap  = not na(cvdPL1) and not na(cvdPL2) and cvdLvlStd > 0 ?
             math.abs(cvdPL1 - cvdPL2) / cvdLvlStd : 0.0
// Exhaustion — sigma multiple of current CVD change
exhSigmaNow = exhStd > 0 ? math.abs(cvdChange) / exhStd : 0.0

if regBull
    f_drawSignal(true,  "Reg Bull", bullColor,              f_starsFromSigma(divLowGap, false))
if regBear
    f_drawSignal(false, "Reg Bear", bearColor,              f_starsFromSigma(divHighGap, false))
if hidBull
    f_drawSignal(true,  "Hid Bull", color.new(bullColor, 25), f_starsFromSigma(divLowGap, false))
if hidBear
    f_drawSignal(false, "Hid Bear", color.new(bearColor, 25), f_starsFromSigma(divHighGap, false))
if exhBull
    f_drawSignal(true,  "Exh Bull", accentColor,            f_starsFromSigma(exhSigmaNow, true))
if exhBear
    f_drawSignal(false, "Exh Bear", neutralColor,           f_starsFromSigma(exhSigmaNow, true))

// ═════════════════════════════════════════════════
// REACTION ZONES (optional)
// ═════════════════════════════════════════════════
var array<box> zonesArr = array.new<box>()
var array<label> zoneLabelsArr = array.new<label>()

f_newZone(priceAnchor, col, zoneText) =>
    half = zoneWidthATR * atr14
    b = box.new(bar_index, priceAnchor + half, bar_index + zoneExtend, priceAnchor - half,
         border_color=color.new(col, 50),
         bgcolor=color.new(col, 85),
         force_overlay=true)
    zoneCenterX = bar_index + int(math.round(zoneExtend * 0.5))
    zoneBadge = label.new(zoneCenterX, priceAnchor, zoneText,
         xloc=xloc.bar_index, yloc=yloc.price,
         style=label.style_label_center,
         color=color.new(col, 0), textcolor=f_text_on(col),
         size=f_sizeFrom(labelSize), textalign=text.align_center,
         force_overlay=true)
    array.push(zonesArr, b)
    array.push(zoneLabelsArr, zoneBadge)
    if array.size(zonesArr) > maxZones
        oldest = array.shift(zonesArr)
        oldestBadge = array.shift(zoneLabelsArr)
        box.delete(oldest)
        label.delete(oldestBadge)

if showZones
    if regBull or hidBull or exhBull
        anchorLow = regBull ? lastPL1 : hidBull ? lastPL1 : low
        colZ = regBull ? bullColor : hidBull ? color.new(bullColor, 25) : accentColor
        f_newZone(anchorLow, colZ, "BULL FLOW ZONE")
    if regBear or hidBear or exhBear
        anchorHigh = regBear ? lastPH1 : hidBear ? lastPH1 : high
        colZ = regBear ? bearColor : hidBear ? color.new(bearColor, 25) : neutralColor
        f_newZone(anchorHigh, colZ, "BEAR FLOW ZONE")
else
    while array.size(zonesArr) > 0
        box.delete(array.pop(zonesArr))
        label.delete(array.pop(zoneLabelsArr))

// ═════════════════════════════════════════════════
// PLOTS (CVD sub-panel)
// ═════════════════════════════════════════════════
cvdCol = cvdTrend == 1 ? bullColor : cvdTrend == -1 ? bearColor : neutralColor
plot(showCVDPlot ? cvd : na, "CVD", color=cvdCol, style=plot.style_area, linewidth=1)
plot(showCVDMA ? cvdMA : na, "CVD EMA 21", color=accentColor, linewidth=1)
hline(0, "Zero", color=panelBorder, linestyle=hline.style_dashed)

// Trend badge on sub-panel — only on trend change (not every bar)
trendChanged = barstate.isconfirmed and cvdTrend != 0 and cvdTrend != nz(cvdTrend[1])
trendDotCol = cvdTrend == 1 ? bullColor : cvdTrend == -1 ? bearColor : neutralColor
plotshape(showTrendBadge and trendChanged,
     title="CVD Trend Dot", style=shape.circle, location=location.top,
     color=trendDotCol, size=size.tiny)

// ═════════════════════════════════════════════════
// INFO PANEL
// ═════════════════════════════════════════════════
// Rolling divergence count (last 200 bars) — avoids meaningless cumulative inflation
divWindow = 200
bullFlag = anyBull ? 1.0 : 0.0
bearFlag = anyBear ? 1.0 : 0.0
divBullCount = int(math.sum(bullFlag, divWindow))
divBearCount = int(math.sum(bearFlag, divWindow))

// Bars since last signal (for timing context)
var int lastBullBar = na
var int lastBearBar = na
if anyBull
    lastBullBar := bar_index
if anyBear
    lastBearBar := bar_index
barsSinceBull = na(lastBullBar) ? na : bar_index - lastBullBar
barsSinceBear = na(lastBearBar) ? na : bar_index - lastBearBar

// Track last signal's star rating for panel display
var string lastSignalStars = "—"
var string lastSignalType = "—"
var color  lastSignalCol = panelLabelCol
if regBull
    lastSignalStars := f_starsFromSigma(divLowGap, false)
    lastSignalType  := "Reg Bull"
    lastSignalCol   := bullColor
if regBear
    lastSignalStars := f_starsFromSigma(divHighGap, false)
    lastSignalType  := "Reg Bear"
    lastSignalCol   := bearColor
if hidBull
    lastSignalStars := f_starsFromSigma(divLowGap, false)
    lastSignalType  := "Hid Bull"
    lastSignalCol   := bullColor
if hidBear
    lastSignalStars := f_starsFromSigma(divHighGap, false)
    lastSignalType  := "Hid Bear"
    lastSignalCol   := bearColor
if exhBull
    lastSignalStars := f_starsFromSigma(exhSigmaNow, true)
    lastSignalType  := "Exh Bull"
    lastSignalCol   := accentColor
if exhBear
    lastSignalStars := f_starsFromSigma(exhSigmaNow, true)
    lastSignalType  := "Exh Bear"
    lastSignalCol   := neutralColor

confirmedCvdTrend = barstate.isconfirmed ? cvdTrend : nz(cvdTrend[1], 0)
confirmedCvdValue = barstate.isconfirmed ? cvd : nz(cvd[1], cvd)
cvdTrendTxt = confirmedCvdTrend == 1 ? "Up" : confirmedCvdTrend == -1 ? "Down" : "Flat"
cvdTrendCol = confirmedCvdTrend == 1 ? bullColor : confirmedCvdTrend == -1 ? bearColor : neutralColor

cvdValTxt = str.tostring(cvd, format.volume)

// Next-action stance from the freshest divergence and CVD trend
bool recentBull = not na(barsSinceBull) and barsSinceBull <= minBarsBetween
bool recentBear = not na(barsSinceBear) and barsSinceBear <= minBarsBetween
bool bullFresher = recentBull and (na(barsSinceBear) or barsSinceBull <= barsSinceBear)
bool bearFresher = recentBear and (na(barsSinceBull) or barsSinceBear < barsSinceBull)
string actionTxt = bullFresher ? "Bullish flow signal - watch up" :
     bearFresher ? "Bearish flow signal - watch down" :
     confirmedCvdTrend == 1 ? "Flow rising - no fresh divergence" :
     confirmedCvdTrend == -1 ? "Flow falling - no fresh divergence" : "Flow flat - wait for divergence"
color actionCol = bullFresher ? bullColor : bearFresher ? bearColor : confirmedCvdTrend == 1 ? bullColor : confirmedCvdTrend == -1 ? bearColor : neutralColor

string proofTxt = sigTotal > 0 ? str.tostring(math.round(nz(sigRate, 0.0))) + "% (" + str.tostring(sigTotal) + ")" : "Building"
color proofCol = na(sigRate) ? panelLabelCol : sigRate >= 55 ? bullColor : sigRate >= 45 ? neutralColor : bearColor

string timingTxt = (na(barsSinceBull) ? "—" : str.tostring(barsSinceBull) + "b") + " / " + (na(barsSinceBear) ? "—" : str.tostring(barsSinceBear) + "b")

string flowBadgeTitle = bullFresher ? "BULL FLOW SIGNAL" : bearFresher ? "BEAR FLOW SIGNAL" : confirmedCvdTrend == 1 ? "FLOW UP" : confirmedCvdTrend == -1 ? "FLOW DOWN" : "FLOW FLAT"
string flowBadgeDetail = bullFresher or bearFresher ? lastSignalType + " " + lastSignalStars : "No fresh divergence"
var label flowContextBadge = na
if barstate.islast
    if showFlowContextBadge
        badgeX = bar_index + flowBadgeOffset
        badgeText = flowBadgeTitle + "\n" + flowBadgeDetail
        if na(flowContextBadge)
            flowContextBadge := label.new(badgeX, confirmedCvdValue, badgeText,
                 xloc=xloc.bar_index, yloc=yloc.price,
                 style=label.style_label_left,
                 color=color.new(actionCol, 0), textcolor=f_text_on(actionCol),
                 size=f_sizeFrom(labelSize), textalign=text.align_center)
        else
            label.set_x(flowContextBadge, badgeX)
            label.set_y(flowContextBadge, confirmedCvdValue)
            label.set_text(flowContextBadge, badgeText)
            label.set_color(flowContextBadge, color.new(actionCol, 0))
            label.set_textcolor(flowContextBadge, f_text_on(actionCol))
            label.set_size(flowContextBadge, f_sizeFrom(labelSize))
    else if not na(flowContextBadge)
        label.delete(flowContextBadge)
        flowContextBadge := na

bool lightPanel = panelTheme == "Light"
bool slatePanel = panelTheme == "Slate"
color panelBgUse = lightPanel ? panelBgLight : slatePanel ? panelBgSlate : panelBg
color panelBgAltUse = lightPanel ? color.rgb(241, 245, 249) : slatePanel ? color.rgb(36, 50, 70) : color.rgb(19, 29, 48)
color panelBorderUse = lightPanel ? panelBorderL : panelBorder
color panelLabelUse = lightPanel ? panelLabelL : panelLabelCol
color panelValueUse = lightPanel ? panelValueL : panelValueCol
color proofColUse = na(sigRate) ? panelLabelUse : proofCol

var table panel = na
var string lastPanelLoc = ""
var string lastPanelTheme = ""
var string lastPanelSize = ""
var bool lastPanelVisible = false

bool panelNeedsBuild = showPanel and (na(panel) or panelLoc != lastPanelLoc or panelTheme != lastPanelTheme or panelTextSize != lastPanelSize or not lastPanelVisible)
if panelNeedsBuild
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_panelPos(panelLoc), 2, 8,
         bgcolor=panelBgUse, border_color=panelBorderUse, border_width=1, frame_color=panelBorderUse, frame_width=1)
    table.cell(panel, 0, 0, "AG Pro CVD Flow",
         bgcolor=headerBg, text_color=headerText,
         text_size=f_sizeFrom(panelTextSize), text_halign=text.align_center)
    table.cell(panel, 1, 0, "", bgcolor=headerBg, text_color=headerText, text_size=f_sizeFrom(panelTextSize))
    table.merge_cells(panel, 0, 0, 1, 0)
    lastPanelLoc := panelLoc
    lastPanelTheme := panelTheme
    lastPanelSize := panelTextSize
    lastPanelVisible := true

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    lastPanelVisible := false

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_panelPos(panelLoc))
    table.cell(panel, 0, 0, "AG Pro CVD Flow", bgcolor=headerBg, text_color=headerText, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_center)
    table.cell(panel, 0, 1, "CVD",        bgcolor=panelBgUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 1, cvdValTxt,    bgcolor=panelBgUse, text_color=panelValueUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

    table.cell(panel, 0, 2, "Trend",      bgcolor=panelBgAltUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 2, cvdTrendTxt,  bgcolor=panelBgAltUse, text_color=cvdTrendCol, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

    table.cell(panel, 0, 3, "Last Signal",bgcolor=panelBgUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 3, lastSignalType + " " + lastSignalStars,
         bgcolor=panelBgUse, text_color=lastSignalCol, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

    table.cell(panel, 0, 4, "Divs (200b)",bgcolor=panelBgAltUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 4, str.tostring(divBullCount) + " / " + str.tostring(divBearCount),
         bgcolor=panelBgAltUse, text_color=panelValueUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

    table.cell(panel, 0, 5, "Last Bull / Bear", bgcolor=panelBgUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 5, timingTxt,    bgcolor=panelBgUse, text_color=panelValueUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

    table.cell(panel, 0, 6, "Signal Hit Rate", bgcolor=panelBgAltUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 6, proofTxt,     bgcolor=panelBgAltUse, text_color=proofColUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

    table.cell(panel, 0, 7, "Action",     bgcolor=panelBgUse, text_color=panelLabelUse, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_left)
    table.cell(panel, 1, 7, actionTxt,    bgcolor=color.new(actionCol, 84), text_color=actionCol, text_size=f_sizeFrom(panelTextSize), text_halign=text.align_right)

// ═════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════
if alertOnRegular and (regBull or regBear)
    alert("CVD Regular Divergence: " + (regBull ? "Bullish" : "Bearish") + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertOnHidden and (hidBull or hidBear)
    alert("CVD Hidden Divergence: " + (hidBull ? "Bullish" : "Bearish") + " on " + syminfo.ticker, alert.freq_once_per_bar_close)
if alertOnExhaust and (exhBull or exhBear)
    alert("CVD Exhaustion: " + (exhBull ? "Bullish" : "Bearish") + " on " + syminfo.ticker, alert.freq_once_per_bar_close)

alertcondition(regBull, "Reg Bull Divergence", "CVD Regular Bullish Divergence")
alertcondition(regBear, "Reg Bear Divergence", "CVD Regular Bearish Divergence")
alertcondition(hidBull, "Hid Bull Divergence", "CVD Hidden Bullish Divergence")
alertcondition(hidBear, "Hid Bear Divergence", "CVD Hidden Bearish Divergence")
alertcondition(exhBull, "Exh Bull",            "CVD Exhaustion Bullish")
alertcondition(exhBear, "Exh Bear",            "CVD Exhaustion Bearish")
````
