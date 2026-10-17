# AetherEdge - PULSE Adaptive Signal Intelligence

- url: https://www.tradingview.com/script/D4M8vV79/
- type: indicator
- pine_id: PUB;61e3f5e09e6243c787d2339aef5cd824
- version: 1.0

## Description

🖊️ Overview 

PULSE is an all-in-one signal intelligence that grades trend-continuation (confirmation) and reversal (contrarian) signals through a self-learning AI classifier. Each time a signal fires, online learning predicts the probability the move will continue and sorts it into one of four tiers. Unlike conventional tools that merely light up signals, PULSE learns conviction from experience and enables filtering to keep only high-quality signals. An adaptive Smart Trail and smooth gradient visuals render the very breath of the trend.

🔶 Key Features

Confirmation signals: continuation entries from momentum/trend agreement, graded Normal / Strong (+)
Contrarian signals: reversal entries from oscillator extremes, shown as diamond markers
Exit marks: momentum fade after a signal flagged as take-profit candidates with "✕"
Smart Trail: an ATR-based adaptive trail serving as both dynamic support/resistance and a signal filter
[AI Layer] Multi-tier classification: an online logistic regression learns each signal's continuation probability and grades it ★★/★/◇/◆
Tier filter: set a minimum tier to automatically exclude low-conviction signals
Smooth gradient candles: continuous red↔violet↔green coloring by trend score
Vertical gradient fill on the Smart Trail and layered neon glow for dimensional depth
Refined red/green jewel-tone palettes (three) with a gold-framed integrated HUD
Built-in confirmation/contrarian alerts

🧠 Technical Architecture 

PULSE's foundation is a composite trend-and-momentum core. A trend score — the fast/slow EMA difference normalized by ATR — provides direction and strength, while RSI-derived smoothed momentum supplies turning points. Confirmation signals fire when momentum crosses zero in the trend direction, promoting to Strong (+) when trend strength exceeds a sensitivity-scaled threshold. Contrarian signals capture momentum reversing from an extreme. The Smart Trail, an ATR-based adaptive trail (supertrend-style), reverses direction when price pierces it, simultaneously serving as dynamic support/resistance and a directional signal filter.

Atop this sits the AI classification layer — a genuine online logistic regression. From four standardized features (trend score, momentum, trend strength, Smart Trail agreement), it predicts the probability of continuation in the signal's direction. When a signal fires, its features and direction are buffered; after a set outcome horizon, a supervised label is generated from whether price actually continued in the signal direction, and the weights are updated via stochastic gradient descent. Using the learned continuation probability, each signal is graded into four tiers: ★★ (strong continuation), ★ (continuation), ◇ (reversal-leaning), and ◆ (strong reversal). Setting a minimum-tier filter automatically excludes low-conviction signals, leaving only high-conviction ones on the chart.

In the visual layer, candles are colored by a continuous gradient tied to the trend score, and the space to the Smart Trail is filled with a vertical gradient, intuitively conveying trend strength and distance from the trail. Layered glow gives signals and the trail a smooth emission.

⚙️ Recommended Settings & Tuning Guide 

PULSE is tuned with crypto in mind. On majors like BTC and ETH, Sensitivity near 5 is a starting point. On higher-volatility names such as SOL and XRP, raising Sensitivity to 7–9 suppresses noise signals and stabilizes quality. Use Confirmation mode (trend continuation) as the baseline; in choppy, range-heavy conditions choose Contrarian, or Both to see everything.

Sensitivity is the central frequency parameter — higher is more selective. In the AI layer, the Outcome Horizon controls the evaluation window for "continuation" and the Learning Rate controls adaptation speed. The most practical tuning lever is "Minimum Tier to Show." Start at tier 1 (show all); when signals are too frequent or fakeouts stand out, raise to tier 3 to narrow to high-continuation-probability signals. Combining with the Smart Trail Filter — keeping only signals aligned with the trail — raises conviction further.

💡 How to Use in Practice 

The highest-conviction setups are confluences where multiple elements align at once. A Strong (+) confirmation signal accompanied by a ★★ or ★ AI tier and aligned with the Smart Trail direction is a strong continuation-entry candidate. Conversely, a confirmation signal the AI grades ◆ (strong reversal) suggests the trend may be running out of breath — a cue to stand aside or take profit early.

The HUD's continuation probability and model accuracy gauge how much to trust the AI. If model accuracy stably exceeds 50%, it is a sign the tier classification is meaningful. For multi-timeframe trading, pair a higher-timeframe PULSE to read the macro trend and Smart Trail with a lower timeframe for precise entry timing. Contrarian signals serve counter-trend trades in ranges, and exit marks serve as take-profit timing cues — each used according to conditions.

⚠️ Important Notes 

The AI classifier requires accumulated data to learn, so near the chart's left edge or when signals are few, model accuracy stays at its initial value (50%) and tier classification remains neutral. Static model accuracy in the HUD is a sign that learning data is still insufficient. Whether model accuracy stably exceeds 50% depends on the instrument, timeframe, and period, and cannot overcome the fundamental constraint of market predictability. Because signals are designed for trend-following, note that confirmation signal accuracy degrades in violently ranging markets.

🚨 Disclaimer 

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No signal guarantees future profit, and past performance does not indicate future results. All trading decisions are made at your own risk; please use this tool with sound risk management and your own independent verification.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — PULSE // Adaptive Signal Intelligence
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  PULSE — STAGE 2 of 2  (FINAL)                                             │
// │  CONFIRMATION / CONTRARIAN SIGNALS + SMART TRAIL + AI SIGNAL CLASSIFIER    │
// │                                                                            │
// │  Original AetherEdge interpretation of an all-in-one signals toolkit       │
// │  (source unavailable). The AI layer is a genuinely-learning online         │
// │  logistic regression: when a signal fires it predicts the probability the  │
// │  move CONTINUES (vs. reverses), learns from the realized outcome via       │
// │  delayed-label SGD, and grades each signal into 4 tiers:                   │
// │     ★★ STRONG CONTINUATION · ★ CONTINUATION · ◇ REVERSAL · ◆ STRONG REVERSAL│
// │  Low-tier signals can be filtered out, keeping only high-conviction ones.  │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - PULSE Adaptive Signal Intelligence", "AE-PULSE ASI", overlay = true,
     max_labels_count = 500, max_lines_count = 100)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── SIGNAL ENGINE ───────────────────────────────────────────────────────────
gS = "▓ SIGNAL ENGINE ▓"
sg_modeInput   = input.string("Confirmation", "Signal Mode",
     options = ["Confirmation", "Contrarian", "Both"], group = gS,
     tooltip = "Confirmation = trend-continuation entries. Contrarian = reversal entries. Both = show all.")
sg_sensInput   = input.float(5.0, "Sensitivity", minval = 1.0, maxval = 20.0, step = 0.5, group = gS,
     tooltip = "Lower = more signals (more sensitive). Higher = fewer, higher-quality signals.")
sg_smoothInput = input.int(20, "Trend Smoothing", minval = 2, maxval = 100, group = gS)
sg_showExitInp = input.bool(true, "Show Exit Marks", group = gS,
     tooltip = "Plot 'x' take-profit suggestions when momentum fades after a signal.")

// ─── AI SIGNAL CLASSIFIER ────────────────────────────────────────────────────
gAI = "▓ AI · SIGNAL CLASSIFIER ▓"
ai_enableInput = input.bool(true, "Enable AI Classification", group = gAI,
     tooltip = "Grade each signal by the online-learned probability that the move continues, into 4 tiers.")
ai_horizonInput= input.int(10, "Outcome Horizon (bars)", minval = 2, maxval = 50, group = gAI,
     tooltip = "Bars ahead used to judge whether a signal 'continued' (price moved in the signal direction), for supervised learning.")
ai_rateInput   = input.float(0.05, "Learning Rate", minval = 0.001, maxval = 0.5, step = 0.001, group = gAI)
ai_minTierInput= input.int(1, "Minimum Tier to Show", minval = 1, maxval = 4, group = gAI,
     tooltip = "Filter: only display signals at or above this tier. 1 = show all, 4 = only strongest continuations.")
ai_showProbInp = input.bool(true, "Show Probability on Labels", group = gAI)

// ─── SMART TRAIL ─────────────────────────────────────────────────────────────
gT = "▓ SMART TRAIL ▓"
tr_showInput   = input.bool(true, "Show Smart Trail", group = gT)
tr_lenInput    = input.int(14, "Trail Length", minval = 2, maxval = 100, group = gT)
tr_multInput   = input.float(2.0, "Trail ATR Multiplier", minval = 0.5, maxval = 10.0, step = 0.1, group = gT)
tr_filterInput = input.bool(false, "Use Trail as Signal Filter", group = gT,
     tooltip = "Only allow confirmation signals aligned with the Smart Trail direction.")

// ─── CANDLE COLORING ─────────────────────────────────────────────────────────
gC = "▓ CANDLES ▓"
cc_showInput   = input.bool(true, "Color Candles by Trend Strength", group = gC)

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_themeInput  = input.string("Emerald / Ruby", "Palette",
     options = ["Emerald / Ruby", "Mint / Coral", "Forest / Crimson"], group = gV)
vi_glowInput   = input.bool(true, "Neon Glow on Signals & Trail", group = gV)
vi_gradTrailInp= input.bool(true, "Gradient Trail Fill", group = gV,
     tooltip = "Fill between price and the Smart Trail with a strength-modulated gradient for depth.")
vi_gradCandInp = input.bool(true, "Smooth Gradient Candles", group = gV,
     tooltip = "Color candles with a continuous bull↔bear gradient by trend score instead of 5 discrete tiers.")

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput  = input.bool(true, "Show HUD", group = gH)
hud_posInput   = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput  = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ PALETTE (refined red/green) ░░
// ============================================================================
var color cBull  = na
var color cBear  = na
var color cBullD = na
var color cBearD = na
var color cWeak  = na   // indecision / weak trend
var color cGold  = na
var color cTxt   = #eef2f0
var color cTxtD  = #6b7d76
var color cPanel = #080b0a
var color cPanelHd = #0f1614

setPalette() =>
    [b, s, bd, sd] = switch vi_themeInput
        "Emerald / Ruby" => [#10e0a0, #ff3860, #0a6b54, #8c2238]
        "Mint / Coral"   => [#4ef0c0, #ff6b6b, #1f7d68, #9c3d3d]
        => [#2ecc71, #e23c4e, #176638, #842029]
    [b, s, bd, sd]
[pb, ps, pbd, psd] = setPalette()
cBull  := pb
cBear  := ps
cBullD := pbd
cBearD := psd
cWeak  := #9b8cff   // soft violet for indecision
cGold  := #d4af37


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))


// ============================================================================
//  ░░ TREND & MOMENTUM CORE ░░
//  A composite trend score from a fast/slow EMA relationship normalized by
//  ATR, plus a smoothed momentum oscillator. These drive both signal types.
// ============================================================================
atr = ta.atr(14)
fastLen = math.max(2, math.round(sg_smoothInput / 2))
slowLen = sg_smoothInput

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
trendScore = sdiv(emaFast - emaSlow, atr)          // >0 bullish, <0 bearish

// Momentum oscillator (RSI-like, centered at 0).
mom = ta.rsi(close, sg_smoothInput) - 50.0
momSmooth = ta.ema(mom, 3)

// Trend strength magnitude (0..1) used for candle coloring & HUD.
trendStrength = clamp(math.abs(trendScore), 0.0, 1.0)

// Sensitivity scales the thresholds: higher sensitivity input = harder to fire.
thr = sg_sensInput / 100.0 * 5.0   // map roughly into trendScore units


// ============================================================================
//  ░░ SMART TRAIL ░░
//  Adaptive trailing stop a la ATR supertrend: flips when price crosses it,
//  and provides dynamic S/R + a directional filter.
// ============================================================================
trAtr = ta.atr(tr_lenInput) * tr_multInput
var float smartTrail = na
var int   trailDir    = 1

upBand = close - trAtr
dnBand = close + trAtr

if na(smartTrail)
    smartTrail := close
    trailDir := 1
else
    if trailDir == 1
        smartTrail := math.max(smartTrail, upBand)
        if close < smartTrail
            trailDir := -1
            smartTrail := dnBand
    else
        smartTrail := math.min(smartTrail, dnBand)
        if close > smartTrail
            trailDir := 1
            smartTrail := upBand

trailBull = trailDir == 1


// ============================================================================
//  ░░ SIGNAL GENERATION ░░
//  Confirmation: momentum crosses zero in the trend direction.
//  Contrarian:   momentum reaches an extreme and turns back.
// ============================================================================
showConf = sg_modeInput == "Confirmation" or sg_modeInput == "Both"
showCont = sg_modeInput == "Contrarian"  or sg_modeInput == "Both"

// Confirmation signals (continuation).
confBuyRaw  = ta.crossover(momSmooth, 0)  and trendScore > 0
confSellRaw = ta.crossunder(momSmooth, 0) and trendScore < 0

// Trail filter.
confBuy  = showConf and confBuyRaw  and (not tr_filterInput or trailBull)
confSell = showConf and confSellRaw and (not tr_filterInput or not trailBull)

// "Strong" grading: trend strength above a sensitivity-scaled threshold.
strongThr = clamp(thr, 0.05, 0.6)
confBuyStrong  = confBuy  and trendStrength > strongThr
confSellStrong = confSell and trendStrength > strongThr

// Contrarian signals (reversal) from oscillator extremes.
obLevel = 50.0 - sg_sensInput          // higher sensitivity => deeper extreme needed
contBuyRaw  = ta.crossover(momSmooth, -obLevel)  and momSmooth[1] < -obLevel
contSellRaw = ta.crossunder(momSmooth,  obLevel) and momSmooth[1] >  obLevel
contBuy  = showCont and contBuyRaw
contSell = showCont and contSellRaw

anyBuy  = confBuy or contBuy
anySell = confSell or contSell

// Exit marks: momentum fades back toward zero after a signal.
var int lastSigDir = 0
if anyBuy
    lastSigDir := 1
if anySell
    lastSigDir := -1
exitLong  = sg_showExitInp and lastSigDir == 1 and ta.crossunder(momSmooth, 0)
exitShort = sg_showExitInp and lastSigDir == -1 and ta.crossover(momSmooth, 0)


// ============================================================================
//  ░░ AI SIGNAL CLASSIFIER ░░
//  Online logistic regression predicts P(move continues) for each signal.
//  Features (standardized): trend score, momentum, trend strength, trail
//  agreement. On a signal, classify into 4 tiers by probability. After the
//  outcome horizon, label as continued(1)/failed(0) and SGD-update.
// ============================================================================
NF = 5   // bias + 4 features
var float[] aiW = array.new<float>(NF, 0.0)

sigmoid(z) =>
    z > 0 ? 1.0 / (1.0 + math.exp(-z)) : math.exp(z) / (1.0 + math.exp(z))

// Standardized features (reuse trend/momentum core).
fWin = 50
zf0 = 1.0
zf1 = clamp(sdiv(trendScore - ta.sma(trendScore, fWin), ta.stdev(trendScore, fWin)), -4, 4)
zf2 = clamp(sdiv(momSmooth - ta.sma(momSmooth, fWin), ta.stdev(momSmooth, fWin)), -4, 4)
zf3 = clamp(trendStrength * 2.0 - 1.0, -1, 1)
zf4 = trailBull ? 1.0 : -1.0

// Forward probability that the CURRENT context favors continuation.
aiDot = array.get(aiW,0)*zf0 + array.get(aiW,1)*zf1 + array.get(aiW,2)*zf2 + array.get(aiW,3)*zf3 + array.get(aiW,4)*zf4
pContinue = sigmoid(aiDot)

// For a signal, "continuation probability" is oriented by the signal direction.
// Buy continues if price rises; sell continues if price falls. The model
// predicts P(up-continuation); for sells we use 1 - p.
sigDir = anyBuy ? 1 : anySell ? -1 : 0
pSignalCont = sigDir > 0 ? pContinue : sigDir < 0 ? (1.0 - pContinue) : 0.5

// 4-tier classification by continuation probability.
//   tier 4 = ★★ strong continuation (p ≥ .70)
//   tier 3 = ★  continuation        (.55 ≤ p < .70)
//   tier 2 = ◇  reversal-leaning    (.40 ≤ p < .55)
//   tier 1 = ◆  strong reversal      (p < .40)
aiTier = pSignalCont >= 0.70 ? 4 : pSignalCont >= 0.55 ? 3 : pSignalCont >= 0.40 ? 2 : 1

// --- Delayed-label training over the outcome horizon ---
var float[] tFeat = array.new<float>(0)   // flattened NF per row
var int[]   tDir  = array.new<int>(0)
var float[] tPx   = array.new<float>(0)
var int[]   tAge  = array.new<int>(0)
var float[] tHit  = array.new<float>(0)

if (anyBuy or anySell) and ai_enableInput
    array.push(tFeat, zf0), array.push(tFeat, zf1), array.push(tFeat, zf2), array.push(tFeat, zf3), array.push(tFeat, zf4)
    array.push(tDir, sigDir)
    array.push(tPx, close)
    array.push(tAge, 0)

if array.size(tDir) > 0
    i = array.size(tDir) - 1
    while i >= 0
        age = array.get(tAge, i) + 1
        array.set(tAge, i, age)
        if age >= ai_horizonInput
            dir = array.get(tDir, i)
            px0 = array.get(tPx, i)
            // Did it continue? price moved in the signal direction.
            cont = (dir > 0 and close > px0) or (dir < 0 and close < px0) ? 1.0 : 0.0
            base = i * NF
            g0 = array.get(tFeat, base), g1 = array.get(tFeat, base+1), g2 = array.get(tFeat, base+2), g3 = array.get(tFeat, base+3), g4 = array.get(tFeat, base+4)
            // Train P(up-continuation): label is cont if buy, (1-... handled by orienting).
            // We learn P(up); convert: for a buy, target=cont; for a sell, target=1-cont.
            target = dir > 0 ? cont : 1.0 - cont
            pOld = sigmoid(array.get(aiW,0)*g0 + array.get(aiW,1)*g1 + array.get(aiW,2)*g2 + array.get(aiW,3)*g3 + array.get(aiW,4)*g4)
            err = pOld - target
            array.set(aiW, 0, array.get(aiW,0) - ai_rateInput * err * g0)
            array.set(aiW, 1, array.get(aiW,1) - ai_rateInput * err * g1)
            array.set(aiW, 2, array.get(aiW,2) - ai_rateInput * err * g2)
            array.set(aiW, 3, array.get(aiW,3) - ai_rateInput * err * g3)
            array.set(aiW, 4, array.get(aiW,4) - ai_rateInput * err * g4)
            predCont = pOld > 0.5 ? 1.0 : 0.0
            array.push(tHit, predCont == target ? 1.0 : 0.0)
            if array.size(tHit) > 100
                array.shift(tHit)
            array.remove(tFeat, base+4), array.remove(tFeat, base+3), array.remove(tFeat, base+2), array.remove(tFeat, base+1), array.remove(tFeat, base)
            array.remove(tDir, i), array.remove(tPx, i), array.remove(tAge, i)
        i -= 1

aiAcc = array.size(tHit) > 0 ? array.avg(tHit) * 100.0 : 50.0

// Tier filter: should this signal be shown?
tierOk = not ai_enableInput or aiTier >= ai_minTierInput


// ============================================================================
//  ░░ CANDLE COLORING by trend strength ░░
//  Smooth mode: a continuous bull↔bear gradient driven by trend score, passing
//  through the indecision violet at zero. Discrete mode: 5 strength tiers.
// ============================================================================
tScoreClamped = clamp(trendScore, -1.0, 1.0)
// Continuous gradient: bear → violet (0) → bull.
gradCandle = tScoreClamped >= 0 ? color.from_gradient(tScoreClamped, 0.0, 1.0, cWeak, cBull) : color.from_gradient(tScoreClamped, -1.0, 0.0, cBear, cWeak)

discreteCandle = trendScore > 0 and trendStrength > strongThr ? cBull :
     trendScore > 0 ? cBullD :
     trendScore < 0 and trendStrength > strongThr ? cBear :
     trendScore < 0 ? cBearD : cWeak

barCol = not cc_showInput ? na : (vi_gradCandInp ? gradCandle : discreteCandle)
barcolor(barCol, editable = false)


// ============================================================================
//  ░░ VISUALS — SMART TRAIL with gradient fill & layered glow ░░
// ============================================================================
trailCol = trailBull ? cBull : cBear
// Layered glow (wider, fainter → narrower, brighter) for a smooth emission.
plot(tr_showInput and vi_glowInput ? smartTrail : na, "Trail glow3", color = color.new(trailCol, 88), linewidth = 6, editable = false)
plot(tr_showInput and vi_glowInput ? smartTrail : na, "Trail glow2", color = color.new(trailCol, 78), linewidth = 4, editable = false)
trailPlot = plot(tr_showInput ? smartTrail : na, "Smart Trail", color = trailCol, linewidth = 2, editable = false)

// Gradient fill between price and trail using v6 vertical-gradient fill:
// fades from vivid near the trail to faint toward price, for real depth.
pricePlot = plot(tr_showInput and vi_gradTrailInp ? close : na, "px ref", color = na, editable = false, display = display.none)
fillInt = math.round(94 - trendStrength * 24)   // stronger trend = more opaque
fill(trailPlot, pricePlot, top_value = math.max(close, smartTrail), bottom_value = math.min(close, smartTrail),
     top_color = vi_gradTrailInp ? color.new(trailCol, 72) : na,
     bottom_color = vi_gradTrailInp ? color.new(trailCol, fillInt) : na,
     title = "Trail Gradient Fill")


// ============================================================================
//  ░░ VISUALS — SIGNAL MARKERS (AI-graded) ░░
//  Tier stars annotate conviction; tier filter hides low-grade signals.
// ============================================================================
tierStars = aiTier == 4 ? "★★" : aiTier == 3 ? "★" : aiTier == 2 ? "◇" : "◆"
probTxt = ai_enableInput and ai_showProbInp ? " " + str.tostring(math.round(pSignalCont * 100)) + "%" : ""

// Confirmation buy.
if confBuy and tierOk
    yOff = low - atr * 1.0
    txt = (confBuyStrong ? "BUY+" : "BUY") + (ai_enableInput ? " " + tierStars : "") + probTxt
    if vi_glowInput
        label.new(bar_index, yOff, "▲", yloc = yloc.price, color = color.new(cBull, 80), textcolor = color.new(cBull, 25), style = label.style_label_up, size = size.large)
    label.new(bar_index, yOff, txt, yloc = yloc.price, color = cBull, textcolor = #04140f, style = label.style_label_up, size = size.normal,
         tooltip = "Continuation prob: " + str.tostring(math.round(pSignalCont*100)) + "%  ·  tier " + str.tostring(aiTier))
if confSell and tierOk
    yOff = high + atr * 1.0
    txt = (confSellStrong ? "SELL+" : "SELL") + (ai_enableInput ? " " + tierStars : "") + probTxt
    if vi_glowInput
        label.new(bar_index, yOff, "▼", yloc = yloc.price, color = color.new(cBear, 80), textcolor = color.new(cBear, 25), style = label.style_label_down, size = size.large)
    label.new(bar_index, yOff, txt, yloc = yloc.price, color = cBear, textcolor = #1a0509, style = label.style_label_down, size = size.normal,
         tooltip = "Continuation prob: " + str.tostring(math.round(pSignalCont*100)) + "%  ·  tier " + str.tostring(aiTier))

// Contrarian (diamond style) — tier filter applies too.
if contBuy and tierOk
    label.new(bar_index, low - atr * 1.0, "R▲" + probTxt, yloc = yloc.price, color = color.new(cBull, 30), textcolor = #04140f, style = label.style_diamond, size = size.small)
if contSell and tierOk
    label.new(bar_index, high + atr * 1.0, "R▼" + probTxt, yloc = yloc.price, color = color.new(cBear, 30), textcolor = #1a0509, style = label.style_diamond, size = size.small)

// Exit marks.
plotchar(exitLong,  "Exit Long",  "✕", location.abovebar, color.new(cGold, 20), size = size.tiny)
plotchar(exitShort, "Exit Short", "✕", location.belowbar, color.new(cGold, 20), size = size.tiny)


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right
hudSize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 10, bgcolor = cPanel,
         border_color = color.new(cGold, 60), border_width = 1, frame_color = color.new(cGold, 40), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    trTxt = trendScore > 0 ? "▲ BULLISH" : trendScore < 0 ? "▼ BEARISH" : "· FLAT"
    trCol = trendScore > 0 ? cBull : trendScore < 0 ? cBear : cWeak

    table.cell(hud, 0, 0, "PULSE", text_color = cGold, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "AI engine", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "trend", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, trTxt, text_color = trCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "strength", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, bar10(trendStrength), text_color = trCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "smart trail", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, trailBull ? "▲ support" : "▼ resist", text_color = trailBull ? cBull : cBear, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "momentum", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, str.tostring(momSmooth, "#.0"), text_color = momSmooth > 0 ? cBull : cBear, text_size = sz, text_halign = text.align_right)

    // AI block.
    table.cell(hud, 0, 5, "▔ AI CLASSIFIER ▔", text_color = cGold, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 5, "", bgcolor = cPanelHd)

    tierLbl = aiTier == 4 ? "★★ STRONG CONT" : aiTier == 3 ? "★ CONTINUATION" : aiTier == 2 ? "◇ REVERSAL" : "◆ STRONG REV"
    tierCol = aiTier >= 3 ? cBull : aiTier == 2 ? cWeak : cBear
    table.cell(hud, 0, 6, "current tier", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, ai_enableInput ? tierLbl : "off", text_color = tierCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "continue prob", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, ai_enableInput ? str.tostring(math.round(pContinue*100)) + "%" : "—", text_color = pContinue >= 0.5 ? cBull : cBear, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 8, "model acc", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(aiAcc, "#") + "%", text_color = aiAcc > 55 ? cBull : aiAcc < 45 ? cBear : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 9, "min tier filter", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 9, str.tostring(ai_minTierInput), text_color = cTxt, text_size = sz, text_halign = text.align_right)


// ============================================================================
//  ░░ ALERTS ░░
// ============================================================================
alertcondition(confBuy,  "Confirmation Buy",  "PULSE: Confirmation BUY")
alertcondition(confSell, "Confirmation Sell", "PULSE: Confirmation SELL")
alertcondition(contBuy,  "Contrarian Buy",    "PULSE: Contrarian BUY (reversal)")
alertcondition(contSell, "Contrarian Sell",   "PULSE: Contrarian SELL (reversal)")
````
