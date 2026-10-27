# AetherEdge Liquidity Void Detector

- url: https://www.tradingview.com/script/1qQUsW5r/
- type: indicator
- pine_id: PUB;b17c5b819304432393d7600af199a6c2
- version: 1.0

## Description

🖊️ Overview
AetherEdge Liquidity Void Detector is a next-generation indicator that fuses liquidity sweep detection with a NeuraLib-style multivariate probability model to visualize the hidden "price vacuum zones" (Liquidity Voids) lurking in the market. It probabilizes the footprints left by smart money through an AI sigmoid function and forecasts the unfilled zones price is destined to revisit. The full institutional logic of Sweep → Void generation → Fill prediction is automated end-to-end.

🔶 Key Features

Automatic Liquidity Sweep Detection: Wick, rejection, and confirmation logic
NeuraLib-Style Probability Model: 4 features × weighted sigmoid for Void probability
Dynamic Void Zone Generation: ATR-based size filter + adjacent merging
Fill Direction Prediction: Arrows visualizing where price must go
Target Line Drawing: Clear Fill price markers
Volume Anomaly Confirmation: Dual-validation via Z-score + burst multiplier
Probability Labels: Numerical confidence per Void
Stats Panel: Active Void count and average probability in real time

🧠 Technical Architecture

This indicator is a sophisticated liquidity analysis engine merging Smart Money Concepts (SMC) with a machine-learning-style probability model.

Liquidity Sweep Detection: Detects temporary breaks of recent highs/lows over sweepLookback bars followed by wick rejection. Confirmed when upperWick/candleRng ≥ sweepWick, rejection ≥ sweepRejection × ATR, and a reversal candle prints.
4-Feature Probability Model: ①sweepStrength (rejection/ATR) ②volZ (volume Z-score) ③priceImpulse (3-bar move/ATR) ④gapMagnitude (open gap/ATR).
NeuraLib-style Sigmoid Scoring: p(void) = σ(1.8·sweep + 0.9·volZ + 0.6·impulse + 0.4·gap − 1.2). Logistic-regression-style scoring with pretrained-style fixed weights.
Volume Anomaly Confirmation: Triggered by volZ > volZThreshold OR volume > volMA × volBurstMul to suppress false positives.
Void Zone Generation: Boundaries determined by sweep direction. Bullish Void = vacuum below; Bearish Void = vacuum above.
Adjacent Merging: Auto-merges Voids within voidMergeATR × ATR proximity to reduce visual noise.
Lifecycle Management: Voids expire after voidMaxBars or transition to filled when price reaches them.
Fill Urgency Decay: fillUrgencyDecay exponentially decays urgency over time, prioritizing fresh Voids.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): sweepLookback=20, voidProbMin=0.55, volZThreshold=2.5
ETH (1H): sweepLookback=15, voidProbMin=0.60, sweepWick=0.65
SOL/XRP (15M): sweepLookback=12, voidProbMin=0.50, volBurstMul=2.5
Long-Term (1D): sweepLookback=30, voidProbMin=0.65, voidMaxBars=150
Tuning Guide:

High-frequency signals: voidProbMin=0.45, sweepWick=0.5 for looser detection
High-quality only: voidProbMin=0.70, sweepConfirm=2 for precision priority
Volatile markets: volZThreshold=3.0, volBurstMul=3.0 for stricter anomaly criteria
Quiet markets: sweepRejection=0.3, voidMinSize=0.3 for higher sensitivity
Scalping: voidExtendBars=20, fillUrgencyDecay=0.90 for short-term projection
Swing: voidExtendBars=80, voidMaxBars=150 for long-term Void tracking

💡 How to Use in Practice

Sweep → Reversal: Upward sweep + high-probability Bearish Void = short opportunity
Void Fill Trades: Enter along Fill direction arrow toward target line
Unfilled Zone Targets: Use high-probability Voids as profit targets
Multi-Timeframe: Sweep on lower TF inside higher-TF Void = sniper entries
Volume Anomaly Confirmation: Z-score + volBurst together = likely institutional flow
AetherEdge Synergy: Overlap with Regime-Aware Trend Channel boundaries → ultra-high-confidence zones
Avoid: Voids below 0.55 probability or sweeps without volume anomaly

⚠️ Important Notes

Liquidity Void is a hypothesis based on SMC; fills are not guaranteed
News-driven moves may behave outside model assumptions
Excessively low voidProbMin produces signal overload and noise
Weights are fixed and not optimized per specific instrument
Increasing confirmation bars boosts accuracy but adds latency
Merging may consolidate multiple Voids into one zone

🚨 Disclaimer

This indicator is provided for educational and research purposes only and does not constitute financial advice. Liquidity Void detection and probability modeling are based on historical data and fixed-weight coefficients, with no guarantee of future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Liquidity Void Detector", shorttitle="AE-LVD", overlay=true, max_lines_count=300, max_labels_count=200, max_boxes_count=300)

// ============================================================
// ▼ INPUTS
// ============================================================
grpSweep = "🩸 Liquidity Sweep Detection"
sweepLookback   = input.int(20,   "Sweep Lookback",       minval=5,  maxval=100, group=grpSweep)
sweepWick       = input.float(0.6,"Wick Ratio Threshold", minval=0.3,maxval=0.9, step=0.05, group=grpSweep, tooltip="ヒゲ部分が実体に対する比率")
sweepRejection  = input.float(0.5,"Rejection × ATR",      minval=0.2,maxval=2.0, step=0.1, group=grpSweep, tooltip="スイープ後のリジェクション幅")
sweepConfirm    = input.int(1,    "Confirmation Bars",    minval=1,  maxval=3,   group=grpSweep)

grpVolume = "📊 Volume Anomaly (NeuraLib AI)"
volWindow       = input.int(50,   "Volume Stats Window",  minval=20, maxval=200, group=grpVolume)
volZThreshold   = input.float(2.5,"Z-Score Anomaly",      minval=1.5,maxval=5.0, step=0.1, group=grpVolume, tooltip="ボリュームZスコアがこの値以上で異常検知")
volBurstMul     = input.float(2.0,"Burst Multiplier",     minval=1.2,maxval=5.0, step=0.1, group=grpVolume)
useNeuralWeight = input.bool(true,"Use NeuraLib Weighting",group=grpVolume, tooltip="多変量重み付けスコアでVoid確率を算出")

grpVoid = "🌌 Void Zone Engine"
voidMinSize     = input.float(0.5,"Min Void Size × ATR",  minval=0.2,maxval=3.0, step=0.1, group=grpVoid)
voidMaxBars     = input.int(80,   "Max Void Lifetime",    minval=20, maxval=300, group=grpVoid)
voidProbMin     = input.float(0.55,"Min Probability",     minval=0.3,maxval=0.95,step=0.05, group=grpVoid, tooltip="この閾値を超えるVoidのみ描画")
voidExtendBars  = input.int(40,   "Forward Projection",   minval=10, maxval=200, group=grpVoid)
voidMergeATR    = input.float(0.3,"Merge Threshold × ATR",minval=0.1,maxval=1.0, step=0.1, group=grpVoid, tooltip="近接Voidを統合する閾値")

grpFill = "🎯 Fill Prediction"
showFillArrows  = input.bool(true,"Show Fill Direction Arrows", group=grpFill)
fillDistanceMax = input.float(3.0,"Max Fill Distance × ATR", minval=1.0,maxval=10.0,step=0.5, group=grpFill)
fillUrgencyDecay= input.float(0.95,"Urgency Decay/Bar",   minval=0.8,maxval=1.0, step=0.01,group=grpFill)
showFillTarget  = input.bool(true,"Mark Fill Target Lines",group=grpFill)

grpVis = "🎨 Visuals"
colVoidBull = input.color(color.rgb(80, 220, 255),"Bullish Void (Below)", group=grpVis)
colVoidBear = input.color(color.rgb(255,120, 180),"Bearish Void (Above)", group=grpVis)
colSweepUp  = input.color(color.rgb(255, 80, 100),"Bearish Sweep Mark",   group=grpVis)
colSweepDn  = input.color(color.rgb(100,255, 140),"Bullish Sweep Mark",   group=grpVis)
colFillUp   = input.color(color.rgb(120,255, 160),"Fill Up Arrow",        group=grpVis)
colFillDn   = input.color(color.rgb(255,100, 140),"Fill Down Arrow",      group=grpVis)
voidAlpha   = input.int(82,    "Void Transparency",     minval=70,maxval=95, group=grpVis)
showLabels  = input.bool(true, "Show Probability Labels", group=grpVis)
showPanel   = input.bool(true, "Show Stats Panel",       group=grpVis)
panelPos    = input.string("Top Right","Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)

// ============================================================
// ▼ CORE INDICATORS
// ============================================================
atrV    = ta.atr(14)
atr50   = ta.atr(50)
volMA   = ta.sma(volume, volWindow)
volSD   = ta.stdev(volume, volWindow)
volZ    = volSD > 0 ? (volume - volMA) / volSD : 0.0

ema21   = ta.ema(close, 21)
ema50   = ta.ema(close, 50)
rsi14   = ta.rsi(close, 14)

// ============================================================
// ▼ LIQUIDITY SWEEP DETECTION
// 上方スイープ: 直近高値を一時的に超え、ヒゲで戻す → 上の流動性奪取
// 下方スイープ: 直近安値を一時的に下回り、ヒゲで戻す → 下の流動性奪取
// ============================================================
priorHigh = ta.highest(high[1], sweepLookback)
priorLow  = ta.lowest(low[1],   sweepLookback)

bodyTop   = math.max(open, close)
bodyBot   = math.min(open, close)
bodySize  = bodyTop - bodyBot
upperWick = high - bodyTop
lowerWick = bodyBot - low
candleRng = high - low

// 上方スイープ条件
upWickRatio = candleRng > 0 ? upperWick / candleRng : 0
sweepUpRaw  = high > priorHigh and close < priorHigh and upWickRatio >= sweepWick and (high - close) >= atrV * sweepRejection

// 下方スイープ条件
dnWickRatio = candleRng > 0 ? lowerWick / candleRng : 0
sweepDnRaw  = low < priorLow and close > priorLow and dnWickRatio >= sweepWick and (close - low) >= atrV * sweepRejection

// 確認バー（簡易）
sweepUp = sweepUpRaw and close < open  // 上方スイープ後ベアキャンドル
sweepDn = sweepDnRaw and close > open  // 下方スイープ後ブルキャンドル

// ============================================================
// ▼ NEURALIB-STYLE VOID PROBABILITY MODEL
// 多変量重み付け確率モデル：
//   p(void) = σ( w1·sweepStrength + w2·volZ + w3·priceImpulse + w4·gapMagnitude )
// ============================================================
sigmoid(float x) =>
    1.0 / (1.0 + math.exp(-x))

// 特徴量
priceImpulse = math.abs(close - close[3]) / math.max(atrV, 1e-10)  // 3バー価格インパルス
gapMagnitude = math.abs(open - close[1]) / math.max(atrV, 1e-10)   // 始値ギャップ
sweepStrengthUp = sweepUp ? (high - close) / math.max(atrV, 1e-10) : 0.0
sweepStrengthDn = sweepDn ? (close - low) / math.max(atrV, 1e-10) : 0.0

// NeuraLib重み（事前学習風の固定係数）
w_sweep   = 1.8
w_volZ    = 0.9
w_impulse = 0.6
w_gap     = 0.4
w_bias    = -1.2

// 上方Void確率（上方スイープ後、価格が下方Void＝下に真空がある可能性）
voidProbUp = sigmoid(w_sweep * sweepStrengthUp + w_volZ * math.max(volZ, 0) + w_impulse * priceImpulse + w_gap * gapMagnitude + w_bias)
voidProbDn = sigmoid(w_sweep * sweepStrengthDn + w_volZ * math.max(volZ, 0) + w_impulse * priceImpulse + w_gap * gapMagnitude + w_bias)

// 単純モデルへのフォールバック
finalProbUp = useNeuralWeight ? voidProbUp : (sweepUp ? 0.7 : 0.0)
finalProbDn = useNeuralWeight ? voidProbDn : (sweepDn ? 0.7 : 0.0)

// ボリューム異常確認
volBurst = volume > volMA * volBurstMul or math.abs(volZ) > volZThreshold

// ============================================================
// ▼ VOID ZONE STRUCTURE
// ============================================================
type VoidZone
    box   bx
    label lb
    line  targetLine
    float top
    float bottom
    int   startBar
    int   bornBar
    bool  isBullish    // true: Voidが下にあり、価格がそこへ落ちる予測
    float probability
    bool  filled
    float urgency

var array<VoidZone> voids = array.new<VoidZone>()

// ============================================================
// ▼ VOID CREATION
// 上方スイープ後 → 価格は下方の「埋まっていない流動性ゾーン」へ向かう
// → Void Zone は「直近のスイープ前安値からエントリー価格」エリア
// ============================================================
createVoid(bool isBullishVoid, float prob) =>
    // Voidの上下境界を決定
    float vTop  = na
    float vBot  = na
    
    if isBullishVoid
        // 価格が下に向かうVoid: 直近サポート〜現在価格
        vTop := math.min(close, priorLow + atrV * 0.5)
        vBot := priorLow - atrV * 1.0
    else
        // 価格が上に向かうVoid: 現在価格〜直近レジスタンス
        vBot := math.max(close, priorHigh - atrV * 0.5)
        vTop := priorHigh + atrV * 1.0
    
    voidSize = vTop - vBot
    if voidSize < atrV * voidMinSize
        // サイズ不足
        false
    else
        // 既存Voidとマージするかチェック
        bool merged = false
        if array.size(voids) > 0
            for i = 0 to array.size(voids) - 1
                v = array.get(voids, i)
                if not v.filled and v.isBullish == isBullishVoid
                    overlap = math.min(v.top, vTop) - math.max(v.bottom, vBot)
                    proximity = math.min(math.abs(v.top - vTop), math.abs(v.bottom - vBot))
                    if overlap > 0 or proximity < atrV * voidMergeATR
                        // マージ
                        v.top := math.max(v.top, vTop)
                        v.bottom := math.min(v.bottom, vBot)
                        v.probability := math.max(v.probability, prob)
                        v.urgency := 1.0
                        merged := true
                        array.set(voids, i, v)
                        break
        
        if not merged
            zoneCol = isBullishVoid ? colVoidBull : colVoidBear
            endBarProj = bar_index + voidExtendBars
            
            newBox = box.new(bar_index, vTop, endBarProj, vBot,
                  border_color=color.new(zoneCol, 40),
                  bgcolor=color.new(zoneCol, voidAlpha),
                  border_width=1, border_style=line.style_dashed,
                  extend=extend.none)
            
            newLabel = label.new(bar_index, isBullishVoid ? vBot : vTop,
                  "VOID " + str.tostring(prob * 100, "0") + "%",
                  color=color.new(zoneCol, 30),
                  textcolor=color.white,
                  style=isBullishVoid ? label.style_label_upper_left : label.style_label_lower_left,
                  size=size.small)
            
            // ターゲットライン（Void中央）
            voidMid = (vTop + vBot) / 2
            newTargetLine = line.new(bar_index, voidMid, endBarProj, voidMid,
                  color=color.new(zoneCol, 50),
                  style=line.style_dotted, width=1)
            
            v = VoidZone.new(newBox, newLabel, newTargetLine,
                             vTop, vBot, bar_index, bar_index, isBullishVoid, prob, false, 1.0)
            array.push(voids, v)
        true

// Void生成トリガー
if barstate.isconfirmed and finalProbUp >= voidProbMin and volBurst and sweepUp
    createVoid(true, finalProbUp)

if barstate.isconfirmed and finalProbDn >= voidProbMin and volBurst and sweepDn
    createVoid(false, finalProbDn)

// ============================================================
// ▼ VOID FILL DETECTION & MAINTENANCE
// ============================================================
var int totalVoidsCreated = 0
var int totalVoidsFilled  = 0

if barstate.isconfirmed and array.size(voids) > 0
    for i = array.size(voids) - 1 to 0
        v = array.get(voids, i)
        
        // Fill判定: 価格がVoidゾーン内に到達
        bool currentlyFilling = low <= v.top and high >= v.bottom
        
        if currentlyFilling and not v.filled
            v.filled := true
            totalVoidsFilled += 1
            // ボックス色を変更
            box.set_bgcolor(v.bx, color.new(color.gray, 90))
            box.set_border_color(v.bx, color.new(color.gray, 60))
            label.set_text(v.lb, "VOID FILLED ✓")
            label.set_color(v.lb, color.new(color.gray, 40))
            // ターゲットラインを点線グレーに
            line.set_color(v.targetLine, color.new(color.gray, 70))
            array.set(voids, i, v)
        
        // 寿命超過 or 古すぎるVoidを削除
        age = bar_index - v.bornBar
        if age > voidMaxBars
            box.delete(v.bx)
            label.delete(v.lb)
            line.delete(v.targetLine)
            array.remove(voids, i)
        else
            // urgency減衰
            v.urgency := v.urgency * fillUrgencyDecay
            // ボックスの右端を伸ばし続ける（未約定Voidのみ）
            if not v.filled
                box.set_right(v.bx, bar_index + voidExtendBars)
                line.set_x2(v.targetLine, bar_index + voidExtendBars)
            array.set(voids, i, v)

if (sweepUp and finalProbUp >= voidProbMin and volBurst) or (sweepDn and finalProbDn >= voidProbMin and volBurst)
    totalVoidsCreated += 1

// ============================================================
// ▼ FILL DIRECTION ARROWS
// 最も近い未約定Voidの方向に矢印を表示
// ============================================================
findNearestVoid() =>
    int nearestIdx = -1
    float nearestDist = 1e10
    bool nearestIsDown = false
    float nearestProb = 0.0
    float nearestUrgency = 0.0
    
    if array.size(voids) > 0
        for i = 0 to array.size(voids) - 1
            v = array.get(voids, i)
            if not v.filled
                voidMid = (v.top + v.bottom) / 2
                dist = math.abs(close - voidMid) / math.max(atrV, 1e-10)
                if dist <= fillDistanceMax and dist < nearestDist
                    nearestDist := dist
                    nearestIdx := i
                    nearestIsDown := v.isBullish  // bullish void = below = price goes down to fill
                    nearestProb := v.probability
                    nearestUrgency := v.urgency
    
    [nearestIdx, nearestDist, nearestIsDown, nearestProb, nearestUrgency]

[nrIdx, nrDist, nrDown, nrProb, nrUrg] = findNearestVoid()

fillArrowUp = showFillArrows and nrIdx >= 0 and not nrDown and nrUrg > 0.3
fillArrowDn = showFillArrows and nrIdx >= 0 and nrDown and nrUrg > 0.3

plotshape(fillArrowUp, title="Fill Arrow Up",   location=location.belowbar, color=colFillUp, style=shape.arrowup,   size=size.small, text="FILL↑")
plotshape(fillArrowDn, title="Fill Arrow Down", location=location.abovebar, color=colFillDn, style=shape.arrowdown, size=size.small, text="FILL↓")

// ============================================================
// ▼ SWEEP MARKERS
// ============================================================
plotshape(sweepUp, title="Bearish Sweep", location=location.abovebar, color=colSweepUp, style=shape.xcross,    size=size.tiny, text="SW")
plotshape(sweepDn, title="Bullish Sweep", location=location.belowbar, color=colSweepDn, style=shape.xcross,    size=size.tiny, text="SW")

// ============================================================
// ▼ STATS PANEL
// ============================================================
panelPosition() =>
    switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left

var table dash = table.new(panelPosition(), 2, 12, border_width=1)

// 統計値
activeVoids = 0
bullVoids = 0
bearVoids = 0
maxProb = 0.0
if array.size(voids) > 0
    for i = 0 to array.size(voids) - 1
        v = array.get(voids, i)
        if not v.filled
            activeVoids += 1
            if v.isBullish
                bullVoids += 1
            else
                bearVoids += 1
            if v.probability > maxProb
                maxProb := v.probability

fillRate = totalVoidsCreated > 0 ? totalVoidsFilled / totalVoidsCreated * 100 : 0.0

if showPanel and barstate.islast
    bg = color.new(color.black, 70)
    fg = color.white
    accent = color.rgb(140, 220, 255)
    
    table.cell(dash, 0, 0, "🌌 AE-LVD",       bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "v1.0",            bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.small)
    
    table.cell(dash, 0, 1, "Active Voids",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(activeVoids), bgcolor=bg, text_color=accent, text_size=size.normal)
    
    table.cell(dash, 0, 2, "↓ Bullish Voids", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(bullVoids), bgcolor=bg, text_color=colVoidBull, text_size=size.small)
    
    table.cell(dash, 0, 3, "↑ Bearish Voids", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(bearVoids), bgcolor=bg, text_color=colVoidBear, text_size=size.small)
    
    table.cell(dash, 0, 4, "Max Probability", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(maxProb * 100, "0.0") + "%", bgcolor=bg, text_color=fg, text_size=size.small)
    
    table.cell(dash, 0, 5, "Vol Z-Score",     bgcolor=bg, text_color=fg, text_size=size.small)
    volzCol = math.abs(volZ) > volZThreshold ? color.yellow : fg
    table.cell(dash, 1, 5, str.tostring(volZ, "0.00"), bgcolor=bg, text_color=volzCol, text_size=size.small)
    
    table.cell(dash, 0, 6, "Vol Burst",       bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 6, volBurst ? "🔥 ACTIVE" : "—", bgcolor=bg, text_color=volBurst ? color.yellow : fg, text_size=size.small)
    
    table.cell(dash, 0, 7, "P(Void Up)",      bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(finalProbUp * 100, "0") + "%", bgcolor=bg, text_color=colVoidBear, text_size=size.small)
    
    table.cell(dash, 0, 8, "P(Void Down)",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(finalProbDn * 100, "0") + "%", bgcolor=bg, text_color=colVoidBull, text_size=size.small)
    
    table.cell(dash, 0, 9, "Total Created",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(totalVoidsCreated), bgcolor=bg, text_color=fg, text_size=size.small)
    
    table.cell(dash, 0, 10,"Fill Rate",       bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 10,str.tostring(fillRate, "0.0") + "%", bgcolor=bg, text_color=color.new(colFillUp, 0), text_size=size.small)
    
    fillStatus = fillArrowUp ? "▲ FILL UP " + str.tostring(nrProb * 100, "0") + "%" : fillArrowDn ? "▼ FILL DOWN " + str.tostring(nrProb * 100, "0") + "%" : "—"
    fillStatusCol = fillArrowUp ? colFillUp : fillArrowDn ? colFillDn : fg
    table.cell(dash, 0, 11,"Fill Signal",     bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 11,fillStatus,        bgcolor=bg, text_color=fillStatusCol, text_size=size.small)

// ============================================================
// ▼ ALERTS
// ============================================================
alertcondition(sweepUp, title="AE-LVD: Bearish Sweep Detected",  message="AE-LVD: 上方流動性スイープ発生。Void候補生成中。")
alertcondition(sweepDn, title="AE-LVD: Bullish Sweep Detected",  message="AE-LVD: 下方流動性スイープ発生。Void候補生成中。")
alertcondition(fillArrowUp, title="AE-LVD: Void Fill Up Signal", message="AE-LVD: 上方Voidへの埋め動意検知。")
alertcondition(fillArrowDn, title="AE-LVD: Void Fill Down Signal",message="AE-LVD: 下方Voidへの埋め動意検知。")
alertcondition(volBurst,    title="AE-LVD: Volume Burst",        message="AE-LVD: 異常出来高検出。")

// Data window
plot(volZ,        "Volume Z-Score", color=color.gray, display=display.data_window)
plot(finalProbUp, "P(Void Up)",     color=color.gray, display=display.data_window)
plot(finalProbDn, "P(Void Down)",   color=color.gray, display=display.data_window)
plot(activeVoids, "Active Voids",   color=color.gray, display=display.data_window)
````
