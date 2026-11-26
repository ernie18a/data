# AetherEdge Multi-Feature Neural Divergence Hunter

- url: https://www.tradingview.com/script/T6EZVEr1/
- type: indicator
- pine_id: PUB;4be08254a5d148e89fa42ca514678af5
- version: 1.0

## Description

🖊️ Overview
AetherEdge Multi-Feature Neural Divergence Hunter is a revolutionary divergence engine that simultaneously detects divergences across 6 independent oscillators and self-evolves neural weights based on each feature's empirical accuracy. Every feature (RSI/MACD/Stoch/CCI/MFI/MOM) detects both Regular and Hidden divergences in parallel, and Softmax-normalized dynamic weights evaluate confluence. With its 3D visual encoding (color × size × shape), the type and strength of every signal is identifiable at a glance — a next-generation divergence hunter.

🔶 Key Features

6 Parallel Oscillator Detection: RSI / MACD Hist / Stochastic / CCI / MFI / Momentum
Up to 12 Divergence Variants (2 types × 6 features) tracked simultaneously
Softmax Neural Weight Learning: Auto-redistribution based on empirical accuracy
Reward-Based Weight Updates: Bonus for correct, penalty for wrong
Confluence Counting: Separate Regular/Hidden tracking, combined for trigger
3D Visual Encoding:
Color: REG Bull/Bear, HID Bull/Bear, MIXED — 5-class system
Size: tiny→huge based on confluence count (5 levels)
Shape: Regular=triangle, Hidden=arrow, Mixed=label
Composite Neural Oscillator: Weighted average centered display
Confluence Glow: Background opacity reflects strength
Per-Feature Accuracy Tracking: Individual hit-rate records
Dynamic Divergence Lines: Width and style identify type

🧠 Technical Architecture

This indicator is a neural-weight-learning system processing 6 oscillators in parallel.

Feature Normalization:
RSI/Stoch/MFI: Native 0-100
MACD Hist/CCI/Momentum: Normalized to 0-100 over 100-bar range
Pivot Storage Method (Pine v5 compatible):
Eliminates dynamic history access by storing previous-pivot oscillator values
12 slots managed: prevPL_rsi, prevPL_macd, ...
Divergence Detection (per feature):
Regular Bull: Price LL + Oscillator HL
Hidden Bull: Price HL + Oscillator LL
Regular Bear: Price HH + Oscillator LH
Hidden Bear: Price LH + Oscillator HH
Distance filter: minBarsBet ≤ pivot gap ≤ maxBarsBet
Neural Weight Learning:
Evaluates return after rewardLook bars per signal
Correct (ret > 0): w += learnRate × |ret| × 100
Wrong (ret < 0): w -= learnRate × |ret| × 50 (asymmetric penalty)
Weight constraint: [0.2, 10.0]
Softmax Normalization (temperature τ):
w_i = exp((rawW_i - max) / τ) / Σexp(...)
Low τ → concentrate on best; High τ → uniform
Composite Neural Oscillator:
nnOsc = Σ(value_i × w_i) / Σw_i - 50
3-bar EMA smoothing, 5-zone state detection
3D Visual Encoding:
Color = type, Size = strength, Shape = category — 3-dimensional information transmission

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): pivotLen=5, minConfluence=2, learnRate=0.08 (standard)
ETH (1H): pivotLen=4, minConfluence=2, rewardLook=8
SOL (high-vol): pivotLen=6, minConfluence=3, rewardLook=12
XRP (short-term): pivotLen=3, minConfluence=2, rewardLook=5
Pivot Sensitivity:

pivotLen=3: high-sensitivity, noisy
pivotLen=5: standard
pivotLen=8–10: HTF, certainty-focused
Confluence Threshold:

minConfluence=1: many signals, false positives
minConfluence=2: standard (recommended)
minConfluence=3: curated, fewer
minConfluence=4+: ultra-curated, rare
Learning Parameters:

learnRate=0.05: conservative, stable
learnRate=0.08: standard
learnRate=0.15: fast, unstable risk
softmaxTemp=0.5: elite concentration (focus on best 1-2)
softmaxTemp=1.5: standard (balanced)
softmaxTemp=3.0: uniform (diversity)
Feature Selection Strategy:

Oscillator-focus: RSI + Stoch + MFI (momentum group)
Trend-focus: MACD + CCI + Momentum
Full parallel: All 6 ON (recommended, NN auto-curates)

💡 How to Use in Practice

5+ Confluence + REG MIXED: Strongest reversal signal (huge size emphasis)
3 REG Bull + NN 80%: High-probability reversal-buy candidate
3 HID Bull: Trend-continuation pullback buy
MIXED (REG+HID): Transition zone / unstable market
Neural Oscillator Usage:
EXTREME OB (>35): Overheated, watch for reversal
EXTREME OS (<-35): Bottom zone, watch for bounce
OS zero-cross + divergence: Direction confirmation
Learning Maturity Check:
Per-feature Acc% > 60%: feature is reliable
Acc% < 45%: feature is failing, ignore
Many Pending: still learning, wait
AetherEdge Synergy:
SMC AI Confidence Engine: A+ zone + 5× confluence = ultimate alignment
NeuraNet Predictor: Direction match + REG MIXED = double confirmation
RL Signal Optimizer: CONFIDENT + divergence = strong entry
All-in-One Dashboard: HIGH-CONVICTION + huge label = supreme reversal signal

⚠️ Important Notes

Pivot Lag: Divergence confirms pivotLen bars later (no real-time detection)
Weight Reset: Chart reload resets weight learning
Learning Maturity: Per-feature Acc% reliable only after Signals ≥ 20
Overfitting Risk: High learnRate + long runtime may over-skew weights
Hidden Divergence Nature: Continuation signal — avoid counter-trend misuse
MIXED Interpretation: Simultaneous REG+HID = transitional confusion, be cautious
Feature Disabling: Turning off unused features improves weight allocation

🚨 Disclaimer

This indicator is an advanced divergence-analysis tool for educational and research purposes only and does not constitute financial advice. Neural weight learning is a stochastic optimization method and does not guarantee future profits. Divergences suggest reversal or continuation possibilities but do not guarantee outcomes. Use with thorough validation and proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Multi-Feature Neural Divergence Hunter", "AE-NDH",
     overlay=false, max_labels_count=500, max_lines_count=500, max_boxes_count=500,
     max_bars_back=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpD = "🎯 Divergence Detection"
pivotLen      = input.int(5, "Pivot Lookback", minval=2, maxval=20, group=grpD,
     tooltip="Bars left/right for pivot detection. Lower = more sensitive.")
minBarsBet    = input.int(5, "Min Bars Between Pivots", minval=1, maxval=50, group=grpD)
maxBarsBet    = input.int(80, "Max Bars Between Pivots", minval=10, maxval=300, group=grpD)
detectRegular = input.bool(true, "Detect Regular Divergence", group=grpD)
detectHidden  = input.bool(true, "Detect Hidden Divergence", group=grpD)

grpF = "🧬 Feature Oscillators"
useRSI    = input.bool(true, "RSI", group=grpF, inline="1")
rsiLen    = input.int(14, "Len", minval=2, group=grpF, inline="1")
useMACD   = input.bool(true, "MACD Hist", group=grpF, inline="2")
macdFast  = input.int(12, "F", minval=2, group=grpF, inline="2")
macdSlow  = input.int(26, "S", minval=2, group=grpF, inline="2")
macdSig   = input.int(9, "Sig", minval=2, group=grpF, inline="2")
useStoch  = input.bool(true, "Stochastic", group=grpF, inline="3")
stochK    = input.int(14, "K", minval=2, group=grpF, inline="3")
stochD    = input.int(3, "D", minval=1, group=grpF, inline="3")
useCCI    = input.bool(true, "CCI", group=grpF, inline="4")
cciLen    = input.int(20, "Len", minval=2, group=grpF, inline="4")
useMFI    = input.bool(true, "MFI", group=grpF, inline="5")
mfiLen    = input.int(14, "Len", minval=2, group=grpF, inline="5")
useMOM    = input.bool(true, "Momentum", group=grpF, inline="6")
momLen    = input.int(10, "Len", minval=2, group=grpF, inline="6")

grpN = "🧠 Neural Weight Learning"
adaptWeights = input.bool(true, "Adaptive Weights", group=grpN)
learnRate    = input.float(0.08, "Learning Rate", minval=0.01, maxval=0.5, step=0.01, group=grpN)
rewardLook   = input.int(10, "Reward Horizon (bars)", minval=3, maxval=50, group=grpN)
softmaxTemp  = input.float(1.5, "Softmax Temperature", minval=0.1, maxval=5.0, step=0.1, group=grpN,
     tooltip="Lower = sharper weight concentration on best features.")
minConfluence = input.int(2, "Min Confluence to Signal", minval=1, maxval=6, group=grpN)

grpV = "🎨 Visualization"
darkMode       = input.bool(true, "Dark Mode", group=grpV)
showLines      = input.bool(true, "Divergence Lines on Price", group=grpV)
showLabels     = input.bool(true, "3D Labels on Price", group=grpV)
showOscFill    = input.bool(true, "Oscillator Gradient Fill", group=grpV)
showBgGlow     = input.bool(true, "Confluence Background Glow", group=grpV)
showDash       = input.bool(true, "Dashboard", group=grpV)
showWeightPane = input.bool(true, "Weight Bars in Dashboard", group=grpV)
dashPos        = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpV)

f_posHelp(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg       = darkMode ? color.new(#0a0f1c, 5)  : color.new(#f7f9fc, 5)
cBgAlt    = darkMode ? color.new(#111a2e, 0)  : color.new(#ffffff, 0)
cBgRow    = darkMode ? color.new(#0f172a, 0)  : color.new(#f8fafc, 0)
cBgHi     = darkMode ? color.new(#1a2744, 0)  : color.new(#eff6ff, 0)
cBorder   = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText     = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute     = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent   = color.new(#00d4ff, 0)
cBull     = color.new(#00d4a0, 0)
cBear     = color.new(#ff5577, 0)
cHidBull  = color.new(#60a5fa, 0)
cHidBear  = color.new(#f59e0b, 0)
cMixBull  = color.new(#c084fc, 0)
cMixBear  = color.new(#fb7185, 0)
cWarn     = color.new(#ffa500, 0)
cGold     = color.new(#fde047, 0)

// ═══════════════════════════════════════════════════════════════
//  FEATURE OSCILLATORS (normalized to 0..100)
// ═══════════════════════════════════════════════════════════════
rsiV   = ta.rsi(close, rsiLen)
[mL, sL, mHist] = ta.macd(close, macdFast, macdSlow, macdSig)
stochV = ta.sma(ta.stoch(close, high, low, stochK), stochD)
cciV   = ta.cci(close, cciLen)
mfiV   = ta.mfi(hlc3, mfiLen)
momV   = ta.mom(close, momLen)

f_norm(src, len) =>
    hi = ta.highest(src, len)
    lo = ta.lowest(src, len)
    rng = hi - lo
    rng == 0 ? 50.0 : (src - lo) / rng * 100.0

normLen = 100
rsiN   = rsiV
macdN  = f_norm(mHist, normLen)
stochN = stochV
cciN   = f_norm(cciV, normLen)
mfiN   = mfiV
momN   = f_norm(momV, normLen)

// ═══════════════════════════════════════════════════════════════
//  PIVOT TRACKING
// ═══════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,  pivotLen, pivotLen)

// ─ FIX: Oscillator values at current pivot (the pivot bar is pivotLen bars ago).
// By sampling at fixed offset [pivotLen], we stay safely within the history buffer. ─
rsiN_at   = rsiN[pivotLen]
macdN_at  = macdN[pivotLen]
stochN_at = stochN[pivotLen]
cciN_at   = cciN[pivotLen]
mfiN_at   = mfiN[pivotLen]
momN_at   = momN[pivotLen]

// ─ FIX: Store previous pivot OSC VALUES so we never need dynamic history lookback ─
// Previous pivot low storage
var float prevPL         = na
var int   prevPLBar      = na
var float prevPL_rsi     = na
var float prevPL_macd    = na
var float prevPL_stoch   = na
var float prevPL_cci     = na
var float prevPL_mfi     = na
var float prevPL_mom     = na

// Previous pivot high storage
var float prevPH         = na
var int   prevPHBar      = na
var float prevPH_rsi     = na
var float prevPH_macd    = na
var float prevPH_stoch   = na
var float prevPH_cci     = na
var float prevPH_mfi     = na
var float prevPH_mom     = na

// ═══════════════════════════════════════════════════════════════
//  DIVERGENCE DETECTION PER FEATURE
//  (uses stored previous pivot values — no dynamic history access)
// ═══════════════════════════════════════════════════════════════
f_divLow(oscCur, oscPrev, useIt) =>
    rb = false
    hb = false
    if useIt and not na(pl) and not na(prevPL) and not na(oscCur) and not na(oscPrev)
        curBar   = bar_index - pivotLen
        barsBetw = curBar - prevPLBar
        if barsBetw >= minBarsBet and barsBetw <= maxBarsBet
            if detectRegular and pl < prevPL and oscCur > oscPrev
                rb := true
            if detectHidden and pl > prevPL and oscCur < oscPrev
                hb := true
    [rb, hb]

f_divHigh(oscCur, oscPrev, useIt) =>
    rb = false
    hb = false
    if useIt and not na(ph) and not na(prevPH) and not na(oscCur) and not na(oscPrev)
        curBar   = bar_index - pivotLen
        barsBetw = curBar - prevPHBar
        if barsBetw >= minBarsBet and barsBetw <= maxBarsBet
            if detectRegular and ph > prevPH and oscCur < oscPrev
                rb := true
            if detectHidden and ph < prevPH and oscCur > oscPrev
                hb := true
    [rb, hb]

[rsiRB,  rsiHB]  = f_divLow(rsiN_at,   prevPL_rsi,   useRSI)
[macdRB, macdHB] = f_divLow(macdN_at,  prevPL_macd,  useMACD)
[stoRB,  stoHB]  = f_divLow(stochN_at, prevPL_stoch, useStoch)
[cciRB,  cciHB]  = f_divLow(cciN_at,   prevPL_cci,   useCCI)
[mfiRB,  mfiHB]  = f_divLow(mfiN_at,   prevPL_mfi,   useMFI)
[momRB,  momHB]  = f_divLow(momN_at,   prevPL_mom,   useMOM)

[rsiRBr,  rsiHBr]  = f_divHigh(rsiN_at,   prevPH_rsi,   useRSI)
[macdRBr, macdHBr] = f_divHigh(macdN_at,  prevPH_macd,  useMACD)
[stoRBr,  stoHBr]  = f_divHigh(stochN_at, prevPH_stoch, useStoch)
[cciRBr,  cciHBr]  = f_divHigh(cciN_at,   prevPH_cci,   useCCI)
[mfiRBr,  mfiHBr]  = f_divHigh(mfiN_at,   prevPH_mfi,   useMFI)
[momRBr,  momHBr]  = f_divHigh(momN_at,   prevPH_mom,   useMOM)

// Update previous pivot AFTER detection (saves current pivot as the new "previous")
if not na(pl)
    prevPL       := pl
    prevPLBar    := bar_index - pivotLen
    prevPL_rsi   := rsiN_at
    prevPL_macd  := macdN_at
    prevPL_stoch := stochN_at
    prevPL_cci   := cciN_at
    prevPL_mfi   := mfiN_at
    prevPL_mom   := momN_at

if not na(ph)
    prevPH       := ph
    prevPHBar    := bar_index - pivotLen
    prevPH_rsi   := rsiN_at
    prevPH_macd  := macdN_at
    prevPH_stoch := stochN_at
    prevPH_cci   := cciN_at
    prevPH_mfi   := mfiN_at
    prevPH_mom   := momN_at

// ═══════════════════════════════════════════════════════════════
//  FEATURE ARRAYS
// ═══════════════════════════════════════════════════════════════
NF = 6
var array<string> featNames = array.from("RSI", "MACD", "STOCH", "CCI", "MFI", "MOM")
actives  = array.from(useRSI, useMACD, useStoch, useCCI, useMFI, useMOM)
bullFeats = array.from(rsiRB or rsiHB, macdRB or macdHB, stoRB or stoHB,
                       cciRB or cciHB, mfiRB or mfiHB, momRB or momHB)
bearFeats = array.from(rsiRBr or rsiHBr, macdRBr or macdHBr, stoRBr or stoHBr,
                       cciRBr or cciHBr, mfiRBr or mfiHBr, momRBr or momHBr)
regBullArr = array.from(rsiRB, macdRB, stoRB, cciRB, mfiRB, momRB)
hidBullArr = array.from(rsiHB, macdHB, stoHB, cciHB, mfiHB, momHB)
regBearArr = array.from(rsiRBr, macdRBr, stoRBr, cciRBr, mfiRBr, momRBr)
hidBearArr = array.from(rsiHBr, macdHBr, stoHBr, cciHBr, mfiHBr, momHBr)

featVals = array.from(rsiN, macdN, stochN, cciN, mfiN, momN)

// Counts
regBullCount = 0
hidBullCount = 0
regBearCount = 0
hidBearCount = 0
for i = 0 to NF - 1
    if array.get(actives, i)
        if array.get(regBullArr, i)
            regBullCount += 1
        if array.get(hidBullArr, i)
            hidBullCount += 1
        if array.get(regBearArr, i)
            regBearCount += 1
        if array.get(hidBearArr, i)
            hidBearCount += 1
totalBull = regBullCount + hidBullCount
totalBear = regBearCount + hidBearCount

// ═══════════════════════════════════════════════════════════════
//  NEURAL WEIGHT LEARNING
// ═══════════════════════════════════════════════════════════════
var array<float> rawW       = array.new<float>(NF, 1.0)
var array<int>   divCount   = array.new<int>(NF, 0)
var array<int>   divCorrect = array.new<int>(NF, 0)

// Pending evaluations
var array<int>   pFeat  = array.new<int>(0)
var array<int>   pDir   = array.new<int>(0)
var array<float> pPrice = array.new<float>(0)
var array<int>   pBar   = array.new<int>(0)

f_record(feat, dir) =>
    array.push(pFeat, feat)
    array.push(pDir, dir)
    array.push(pPrice, close)
    array.push(pBar, bar_index)
    array.set(divCount, feat, array.get(divCount, feat) + 1)

if barstate.isconfirmed
    for i = 0 to NF - 1
        if array.get(actives, i)
            if array.get(bullFeats, i)
                f_record(i, 1)
            if array.get(bearFeats, i)
                f_record(i, -1)

    // Evaluate expired pending
    if array.size(pFeat) > 0
        i = 0
        while i < array.size(pFeat)
            eBar = array.get(pBar, i)
            if bar_index - eBar >= rewardLook
                fIdx = array.get(pFeat, i)
                dir  = array.get(pDir, i)
                eP   = array.get(pPrice, i)
                ret  = (close - eP) / eP * dir
                ok   = ret > 0
                if ok
                    array.set(divCorrect, fIdx, array.get(divCorrect, fIdx) + 1)
                if adaptWeights
                    w = array.get(rawW, fIdx)
                    delta = learnRate * (ok ? math.abs(ret) * 100 : -math.abs(ret) * 50)
                    array.set(rawW, fIdx, math.max(0.2, math.min(10.0, w + delta)))
                array.remove(pFeat, i)
                array.remove(pDir, i)
                array.remove(pPrice, i)
                array.remove(pBar, i)
            else
                i += 1

// Softmax over rawW (only over active features)
var array<float> nnW = array.new<float>(NF, 1.0 / NF)
if barstate.isconfirmed
    maxW = -1e20
    for i = 0 to NF - 1
        if array.get(actives, i)
            w = array.get(rawW, i)
            if w > maxW
                maxW := w
    sumExp = 0.0
    for i = 0 to NF - 1
        if array.get(actives, i)
            sumExp += math.exp((array.get(rawW, i) - maxW) / softmaxTemp)
    for i = 0 to NF - 1
        if array.get(actives, i) and sumExp > 0
            array.set(nnW, i, math.exp((array.get(rawW, i) - maxW) / softmaxTemp) / sumExp)
        else
            array.set(nnW, i, 0.0)

// Weighted strength of current divergence
bullStr = 0.0
bearStr = 0.0
for i = 0 to NF - 1
    w = array.get(nnW, i)
    if array.get(bullFeats, i)
        bullStr += w
    if array.get(bearFeats, i)
        bearStr += w

// ═══════════════════════════════════════════════════════════════
//  COMPOSITE NEURAL OSCILLATOR (weighted average, centered at 0)
// ═══════════════════════════════════════════════════════════════
compSum = 0.0
wSum    = 0.0
for i = 0 to NF - 1
    if array.get(actives, i)
        v = array.get(featVals, i)
        w = array.get(nnW, i)
        if not na(v)
            compSum += v * w
            wSum    += w
nnOsc    = wSum > 0 ? compSum / wSum : 50.0
nnOscC   = nnOsc - 50
nnOscSm  = ta.ema(nnOscC, 3)

// ═══════════════════════════════════════════════════════════════
//  OSCILLATOR PLOTS (pane)
// ═══════════════════════════════════════════════════════════════
oscCol = nnOscC > 0 ? color.from_gradient(nnOscC, 0, 40, color.new(cBull, 80), cBull) : color.from_gradient(nnOscC, -40, 0, cBear, color.new(cBear, 80))

plot(nnOscC, "Neural Oscillator", color=oscCol, style=plot.style_columns, linewidth=1)
p_line = plot(nnOscSm, "Smoothed Line", color=cAccent, linewidth=2)
p_zero = plot(0, "", color=na, display=display.none)

fill(p_line, p_zero, color=showOscFill ? color.new(oscCol, 75) : na)

hline(0,   "Zero",       color=color.new(cMute, 30), linestyle=hline.style_dashed)
hline(20,  "Overbought", color=color.new(cBear, 60), linestyle=hline.style_dotted)
hline(-20, "Oversold",   color=color.new(cBull, 60), linestyle=hline.style_dotted)
hline(35,  "Extreme OB", color=color.new(cBear, 30), linestyle=hline.style_dotted)
hline(-35, "Extreme OS", color=color.new(cBull, 30), linestyle=hline.style_dotted)

// Markers in oscillator pane at pivots
plotshape(totalBull >= minConfluence ? -45 : na, "Bull Osc Marker",
     shape.triangleup, location.absolute, color=cBull, size=size.small)
plotshape(totalBear >= minConfluence ? 45 : na, "Bear Osc Marker",
     shape.triangledown, location.absolute, color=cBear, size=size.small)

// Confluence background glow in pane
bgInt = math.max(totalBull, totalBear)
bgCol = bgInt == 0 ? na : totalBull > totalBear ? color.new(cBull, math.max(70, 95 - bgInt * 5)) : color.new(cBear, math.max(70, 95 - bgInt * 5))
bgcolor(showBgGlow ? bgCol : na, title="Confluence Glow")

// ═══════════════════════════════════════════════════════════════
//  3D-LIKE VISUAL ENCODING ON PRICE CHART
// ═══════════════════════════════════════════════════════════════
f_sizeByCount(c) =>
    c >= 5 ? size.huge : c >= 4 ? size.large : c >= 3 ? size.normal : c >= 2 ? size.small : size.tiny

// BULLISH DIVERGENCE (at low pivot)
if showLabels and totalBull >= minConfluence and not na(pl)
    isReg = regBullCount > 0
    isHid = hidBullCount > 0
    isMix = isReg and isHid

    col = isMix ? cMixBull : isReg ? cBull : cHidBull
    shp = isMix ? label.style_label_up : isReg ? label.style_triangleup : label.style_arrowup
    sz  = f_sizeByCount(totalBull)

    typeTag = isMix ? "MIX" : isReg ? "REG" : "HID"
    txt = "⬆ " + str.tostring(totalBull) + "× " + typeTag + "\n" +
          str.tostring(bullStr * 100, "#.#") + "% NN"

    label.new(bar_index - pivotLen, pl, txt,
         xloc=xloc.bar_index, yloc=yloc.belowbar,
         color=col, textcolor=color.white,
         style=shp, size=sz, force_overlay=true)

// BEARISH DIVERGENCE (at high pivot)
if showLabels and totalBear >= minConfluence and not na(ph)
    isReg = regBearCount > 0
    isHid = hidBearCount > 0
    isMix = isReg and isHid

    col = isMix ? cMixBear : isReg ? cBear : cHidBear
    shp = isMix ? label.style_label_down : isReg ? label.style_triangledown : label.style_arrowdown
    sz  = f_sizeByCount(totalBear)

    typeTag = isMix ? "MIX" : isReg ? "REG" : "HID"
    txt = "⬇ " + str.tostring(totalBear) + "× " + typeTag + "\n" +
          str.tostring(bearStr * 100, "#.#") + "% NN"

    label.new(bar_index - pivotLen, ph, txt,
         xloc=xloc.bar_index, yloc=yloc.abovebar,
         color=col, textcolor=color.white,
         style=shp, size=sz, force_overlay=true)

// DIVERGENCE LINES
if showLines and totalBull >= minConfluence and not na(pl) and not na(prevPLBar)
    lCol = regBullCount >= hidBullCount ? cBull : cHidBull
    lSty = regBullCount > 0 ? line.style_solid : line.style_dashed
    lWid = totalBull >= 4 ? 3 : totalBull >= 3 ? 2 : 1
    line.new(prevPLBar, prevPL, bar_index - pivotLen, pl,
         xloc=xloc.bar_index, color=lCol, width=lWid, style=lSty, force_overlay=true)

if showLines and totalBear >= minConfluence and not na(ph) and not na(prevPHBar)
    lCol = regBearCount >= hidBearCount ? cBear : cHidBear
    lSty = regBearCount > 0 ? line.style_solid : line.style_dashed
    lWid = totalBear >= 4 ? 3 : totalBear >= 3 ? 2 : 1
    line.new(prevPHBar, prevPH, bar_index - pivotLen, ph,
         xloc=xloc.bar_index, color=lCol, width=lWid, style=lSty, force_overlay=true)

// ═══════════════════════════════════════════════════════════════
//  STATISTICS
// ═══════════════════════════════════════════════════════════════
f_accuracy(i) =>
    n = array.get(divCount, i)
    c = array.get(divCorrect, i)
    n > 0 ? float(c) / float(n) * 100.0 : 0.0

totalAllCount = 0
totalAllCorrect = 0
for i = 0 to NF - 1
    totalAllCount   += array.get(divCount, i)
    totalAllCorrect += array.get(divCorrect, i)
overallAcc = totalAllCount > 0 ? float(totalAllCorrect) / float(totalAllCount) * 100.0 : 0.0

pendN = array.size(pFeat)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_bar(frac) =>
    n = math.min(10, math.round(frac * 10))
    s = ""
    for b = 0 to 9
        s := s + (b < n ? "▰" : "▱")
    s

var table dash = na
if barstate.islast and showDash
    dash := table.new(f_posHelp(dashPos), 6, 28,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=2)

    // Header
    table.cell(dash, 0, 0, "◆  AETHEREDGE · NEURAL DIVERGENCE HUNTER  ◆",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 5, 0)

    table.cell(dash, 0, 1,
         syminfo.ticker + "  ·  " + timeframe.period + "  ·  "
         + str.tostring(NF) + " features × 2 div types",
         text_color=cMute, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 1, 5, 1)

    curSignal = totalBull >= minConfluence ? "BULLISH" : totalBear >= minConfluence ? "BEARISH" : "—"
    curCol    = totalBull >= minConfluence ? cBull : totalBear >= minConfluence ? cBear : cMute
    curCount  = math.max(totalBull, totalBear)

    table.cell(dash, 0, 2, "◢  CURRENT DIVERGENCE SIGNAL  ◣",
         text_color=color.white, bgcolor=color.new(cAccent, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 2, 5, 2)

    table.cell(dash, 0, 3, "Signal", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 3, curSignal,
         text_color=color.white, bgcolor=color.new(curCol, 20),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 3, "Confluence", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 3, str.tostring(curCount) + " / " + str.tostring(NF),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 4, 3, "NN Strength", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    strength = math.max(bullStr, bearStr)
    table.cell(dash, 5, 3, str.tostring(strength * 100, "#.#") + "%",
         text_color=strength > 0.5 ? cBull : cText,
         bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)

    table.cell(dash, 0, 4, "Regular Bull", text_color=cBull, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 4, str.tostring(regBullCount),
         text_color=color.white, bgcolor=color.new(cBull, regBullCount > 0 ? 30 : 80),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 4, "Hidden Bull", text_color=cHidBull, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, 4, str.tostring(hidBullCount),
         text_color=color.white, bgcolor=color.new(cHidBull, hidBullCount > 0 ? 30 : 80),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 4, "BULL Σ",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, 4, str.tostring(totalBull),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, 5, "Regular Bear", text_color=cBear, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 5, str.tostring(regBearCount),
         text_color=color.white, bgcolor=color.new(cBear, regBearCount > 0 ? 30 : 80),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 5, "Hidden Bear", text_color=cHidBear, bgcolor=cBgRow,
         text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, 5, str.tostring(hidBearCount),
         text_color=color.white, bgcolor=color.new(cHidBear, hidBearCount > 0 ? 30 : 80),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 5, "BEAR Σ",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, 5, str.tostring(totalBear),
         text_color=cBear, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    // Neural Oscillator state
    table.cell(dash, 0, 6, "◢  NEURAL OSCILLATOR  ◣",
         text_color=color.white, bgcolor=color.new(cGold, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 6, 5, 6)

    oscState = nnOscC > 35 ? "◆ EXTREME OB" : nnOscC > 20 ? "▲ OVERBOUGHT" : nnOscC > -20 ? "◎ NEUTRAL" : nnOscC > -35 ? "▼ OVERSOLD" : "◆ EXTREME OS"
    oscCol2 = nnOscC > 20 ? cBear : nnOscC < -20 ? cBull : cMute
    table.cell(dash, 0, 7, "Value", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 7, str.tostring(nnOscC, "+0.00;-0.00"),
         text_color=color.white, bgcolor=color.new(oscCol2, 20),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 7, "State", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 7, oscState,
         text_color=color.white, bgcolor=color.new(oscCol2, 30),
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 7, "Smoothed", text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 7, str.tostring(nnOscSm, "+0.00;-0.00"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    // Feature weights (Neural NN)
    table.cell(dash, 0, 8, "◢  NEURAL WEIGHTS · " + (adaptWeights ? "ADAPTIVE" : "FIXED") + "  ◣",
         text_color=color.white, bgcolor=color.new(#c084fc, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 8, 5, 8)

    table.cell(dash, 0, 9, "Feature",  text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 1, 9, "Weight %", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 9, "Weight Bar", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 9, "Signals", text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 9, "Acc %",  text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 5, 9, "Active",  text_color=cMute, bgcolor=cBgAlt,
         text_halign=text.align_center, text_size=size.normal)

    for i = 0 to NF - 1
        row = 10 + i
        rBg = i % 2 == 0 ? cBgRow : cBgAlt
        w    = array.get(nnW, i)
        cnt  = array.get(divCount, i)
        cor  = array.get(divCorrect, i)
        acc  = f_accuracy(i)
        act  = array.get(actives, i)
        bull = array.get(bullFeats, i)
        bear = array.get(bearFeats, i)

        nameTxt = array.get(featNames, i)
        if bull
            nameTxt := nameTxt + " ⬆"
        if bear
            nameTxt := nameTxt + " ⬇"

        nameCol = not act ? cMute : bull ? cBull : bear ? cBear : cText

        table.cell(dash, 0, row, nameTxt,
             text_color=nameCol, bgcolor=rBg,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 1, row, act ? str.tostring(w * 100, "#.#") + "%" : "—",
             text_color=act ? cAccent : cMute, bgcolor=rBg,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 2, row, act and showWeightPane ? f_bar(w) : "—",
             text_color=act ? cAccent : cMute, bgcolor=rBg,
             text_halign=text.align_left, text_size=size.normal)
        table.cell(dash, 3, row, str.tostring(cnt),
             text_color=cText, bgcolor=rBg,
             text_halign=text.align_center, text_size=size.normal)
        accCol = cnt < 5 ? cMute : acc >= 60 ? cBull : acc >= 45 ? cWarn : cBear
        table.cell(dash, 4, row, cnt > 0 ? str.tostring(acc, "#.#") + "%" : "—",
             text_color=accCol, bgcolor=rBg,
             text_halign=text.align_center, text_size=size.normal)
        table.cell(dash, 5, row, act ? "✓" : "—",
             text_color=act ? cBull : cMute, bgcolor=rBg,
             text_halign=text.align_center, text_size=size.normal)

    // Performance summary
    table.cell(dash, 0, 16, "◢  LEARNING STATS  ◣",
         text_color=color.white, bgcolor=color.new(cBull, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 16, 5, 16)

    table.cell(dash, 0, 17, "Total Signals",
         text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 1, 17, str.tostring(totalAllCount),
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 17, "Correct",
         text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 3, 17, str.tostring(totalAllCorrect),
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 4, 17, "Pending",
         text_color=cMute, bgcolor=cBgRow, text_size=size.normal)
    table.cell(dash, 5, 17, str.tostring(pendN),
         text_color=cWarn, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)

    accOverallCol = totalAllCount < 10 ? cMute : overallAcc >= 60 ? cBull : overallAcc >= 45 ? cWarn : cBear
    table.cell(dash, 0, 18, "Overall Accuracy",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 18, totalAllCount > 0 ? str.tostring(overallAcc, "#.#") + "%" : "—",
         text_color=color.white, bgcolor=color.new(accOverallCol, 20),
         text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 2, 18, "Reward Horizon",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 3, 18, str.tostring(rewardLook) + " bars",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 18, "Softmax τ",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 5, 18, str.tostring(softmaxTemp, "#.##"),
         text_color=cAccent, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)

    // Legend for 3D encoding
    table.cell(dash, 0, 19, "◢  3D VISUAL ENCODING  ◣",
         text_color=color.white, bgcolor=color.new(#fb7185, 30),
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 19, 5, 19)

    table.cell(dash, 0, 20, "Color",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 20, "REG Bull",
         text_color=color.white, bgcolor=color.new(cBull, 20), text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 20, "HID Bull",
         text_color=color.white, bgcolor=color.new(cHidBull, 20), text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 20, "REG Bear",
         text_color=color.white, bgcolor=color.new(cBear, 20), text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 20, "HID Bear",
         text_color=color.white, bgcolor=color.new(cHidBear, 20), text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 5, 20, "MIXED",
         text_color=color.white, bgcolor=color.new(cMixBull, 20), text_halign=text.align_center, text_size=size.normal)

    table.cell(dash, 0, 21, "Size",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 21, "1 osc",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.tiny)
    table.cell(dash, 2, 21, "2 osc",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 3, 21, "3 osc",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 4, 21, "4 osc",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.large)
    table.cell(dash, 5, 21, "5+ osc",
         text_color=cText, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.huge)

    table.cell(dash, 0, 22, "Shape",
         text_color=cMute, bgcolor=cBgRow, text_halign=text.align_right, text_size=size.normal)
    table.cell(dash, 1, 22, "▲▼ Regular",
         text_color=cBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 2, 22, "→← Hidden",
         text_color=cHidBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.cell(dash, 3, 22, "⬆⬇ Mixed",
         text_color=cMixBull, bgcolor=cBgRow, text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 3, 22, 5, 22)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(totalBull >= minConfluence, "Bullish Divergence Confluence",
     "AE-NDH: Bullish divergence on {{ticker}} — confluence detected")
alertcondition(totalBear >= minConfluence, "Bearish Divergence Confluence",
     "AE-NDH: Bearish divergence on {{ticker}} — confluence detected")
alertcondition(regBullCount >= 3, "Strong Regular Bullish", "AE-NDH: 3+ regular bullish divergences")
alertcondition(regBearCount >= 3, "Strong Regular Bearish", "AE-NDH: 3+ regular bearish divergences")
alertcondition(hidBullCount >= 3, "Strong Hidden Bullish", "AE-NDH: 3+ hidden bullish divergences")
alertcondition(hidBearCount >= 3, "Strong Hidden Bearish", "AE-NDH: 3+ hidden bearish divergences")

// Hidden plots for payload
plot(bullStr, "Bull NN Strength", display=display.none)
plot(bearStr, "Bear NN Strength", display=display.none)
plot(totalBull, "Bull Confluence", display=display.none)
plot(totalBear, "Bear Confluence", display=display.none)
````
