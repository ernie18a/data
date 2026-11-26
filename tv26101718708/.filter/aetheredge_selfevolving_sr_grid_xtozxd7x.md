# AetherEdge Self-Evolving S/R Grid

- url: https://www.tradingview.com/script/xTOZxD7X/
- type: indicator
- pine_id: PUB;d7f89bc7cbbf4b1eb675fb3063de5cd7
- version: 1.0

## Description

🖊️ Overview
AetherEdge Self-Evolving S/R Grid is a revolutionary self-evolving support & resistance system that brings the philosophy of Q-learning into technical analysis. It learns from market reactions—rejections, breaks, and flips—as "rewards," automatically pruning low-value lines and constructing a Darwinian S/R grid where only functional levels survive. Moving beyond static line-drawing tools, it delivers a truly intelligent price-structure map that breathes and evolves alongside the market itself.

🔶 Key Features

Q-Learning-Style Score Updates: Reinforcement learning replicated through α (learning rate), γ (discount factor), and ε (exploration rate)
Self-Evolving Line Lifecycle: Fully automated birth → learning → reinforcement/pruning cycle
Multi-Source Grid Generation: Pivots / Williams Fractals / Round Numbers / Swing Extremes
Dynamic Reward System: Reject reward, break penalty, S/R flip bonus
ATR-Based Sensitivity: Market-adaptive touch tolerance and break confirmation
Volume-Weighted Reaction Detection: Filters out thin-volume false signals
Score-Based Visualization: Dynamic color, width, and transparency by line strength
Strong Zone Highlighting: Threshold-exceeding lines visually emphasized
Dying Line Display: Pre-pruning lines fade visibly
Comprehensive Stats Panel: Cumulative tracking of generations, deletions, rejects, breaks, flips
Safe Coordinate System: MAX_BARS_BACK clamping to prevent drawing errors on legacy bars

🧠 Technical Architecture

This indicator is an advanced system that reconstructs core reinforcement-learning concepts in Pine Script.

Q-Learning Update Equation: Applies newQ = Q + α × (R + γ × maxFutureQ − Q) to every active line each bar. Each line carries its own "value (Q-value)" and self-updates through market experience.
Reward Function: Price-line interactions are classified into three categories—rejection (+rejectReward), break (−breakPenalty), and S/R flip (+flipReward). Rewards are amplified when volume exceeds the moving average.
Exploration vs. Exploitation Dilemma: explorationRate governs new-line generation frequency. High ε aggressively probes uncharted price zones; low ε prioritizes exploitation of high-Q-value lines.
Grid Generation Strategy: Candidate prices extracted from four sources, deduplicated via existsNear(), validated against psychological levels via isRoundNumber(), and rendered safely using safeX1().
Line Lifecycle: bornBar → lastTouchBar → touches/rejects/breaks/flips accumulation → score update → if below minScore, active=false → automatic deletion.
Score Decay Mechanism: Unreacted lines decay by decayPerBar each bar, naturally pruning non-functional lines through a self-cleansing mechanism.
S/R Flip Detection: After a break, line type inverts; the pendingFlip flag monitors retests, and a flip reward is granted upon successful confirmation.
Visualization Layer: Dynamic line widths (>0.7=3px / >0.5=2px / else=1px) and transparency (80−score×60) by score.
Stats Panel: Five metrics cumulatively tracked via the stats array, with globalSuccessRate aggregating system-wide performance.

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H): learningRate=0.15, gridSpacingATR=1.5, maxLines=40, pivotStrength=10
ETH (1H): learningRate=0.20, gridSpacingATR=1.2, maxLines=50, genFrequency=15
SOL/XRP (15M): learningRate=0.25, gridSpacingATR=1.0, maxLines=60, decayPerBar=0.002
Long-Term (1D): learningRate=0.10, gridSpacingATR=2.5, maxLines=30, minScore=0.30
Tuning Guide:

Conservative Learning: α=0.05, γ=0.95 for slow, steady evolution—ideal for long-term trends
Aggressive Learning: α=0.30, ε=0.40 for rapid adaptation—ideal for high-volatility markets
Strict Pruning: minScore=0.35, decayPerBar=0.003 to keep only functional lines
Lenient Pruning: minScore=0.10, decayPerBar=0.0005 to retain more lines
High-Density Grid: gridSpacingATR=0.8, maxLines=80 for scalping
Sparse Grid: gridSpacingATR=3.0, maxLines=20 for long-term swing trading
Volume-Focused: Enable volumeBoost to reward only genuine reactions
Flip Hunting: flipReward=1.0 to emphasize structural reversals

💡 How to Use in Practice

Strong Lines (Yellow Highlight): colStrong lines represent high-Q-value proven levels—enter on confirmed rejection
S/R Flip Tracking: Post-break retest from the opposite side confirms a flip—powerful trend continuation signal
Breakout Strategy: Close beyond breakConfirm × ATR confirms the break—use as the origin of a new trend
Reverse Use of Dying Lines: colDying lines have lost relevance—useful as a filter to ignore stale levels
Multi-Timeframe Integration: Use higher-TF strong lines as anchor entries on lower TFs
AetherEdge Synergy: Combine with Pattern Recognition Trendline for pattern × S/R grid double confirmation
Round-Number Strategy: High-Q lines born from round numbers reflect psychological/institutional support
Grid Trading: High-density settings enable mechanical execution in ranging markets

⚠️ Important Notes

Initial Learning Period: At least 200–500 bars of data accumulation is required before signal quality stabilizes
Learning Reset: Settings changes or chart reloads reset all Q-values, requiring relearning
The ε Trap: Excessive exploration breeds low-quality lines; insufficient exploration delays adaptation
MAX_BARS_BACK Constraint: bornBar values older than 4500 bars are automatically clamped
maxLines Cap: When exceeded, oldest/lowest-score lines are auto-pruned
Regime Changes: During abrupt market shifts, legacy lines may temporarily lose validity until decay resolves them

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Q-learning-style scores are evaluations based on historical price reactions and do not guarantee future performance. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge Self-Evolving S/R Grid", shorttitle="AE-SEG", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ============================================================
// ▼ INPUTS
// ============================================================
grpL = "🧬 Learning Engine"
learningRate    = input.float(0.15, "Learning Rate (α)",      minval=0.01, maxval=1.0,  step=0.05, group=grpL, tooltip="新しい経験の重み (0.05=保守的 / 0.30=積極的)")
discountFactor  = input.float(0.90, "Discount Factor (γ)",    minval=0.5,  maxval=0.99, step=0.01, group=grpL, tooltip="将来報酬の割引率")
explorationRate = input.float(0.20, "Initial Exploration (ε)",minval=0.0,  maxval=1.0,  step=0.05, group=grpL, tooltip="新ラインの初期生成率")
decayPerBar     = input.float(0.001,"Score Decay/Bar",        minval=0.0,  maxval=0.05, step=0.001,group=grpL, tooltip="未反応ラインのスコア減衰")
minScore        = input.float(0.20, "Min Survival Score",     minval=0.0,  maxval=1.0,  step=0.05, group=grpL, tooltip="この値未満で自動削除")

grpG = "📐 Grid Generation"
gridSpacingATR  = input.float(1.5,  "Grid Spacing × ATR",     minval=0.3,  maxval=10.0, step=0.1, group=grpG)
maxLines        = input.int(40,     "Max Active Lines",       minval=10,   maxval=100,  group=grpG)
genFrequency    = input.int(20,     "Generation Frequency",   minval=5,    maxval=200,  group=grpG, tooltip="N バーごとに新規生成検討")
pivotStrength   = input.int(10,     "Pivot Strength",         minval=3,    maxval=50,   group=grpG)
useFractals     = input.bool(true,  "Use Fractal Pivots",     group=grpG)
useRoundNums    = input.bool(true,  "Use Round Numbers",      group=grpG, tooltip="00 / 50 / 0 等の節目")
useSwingExtremes= input.bool(true,  "Use Swing Extremes",     group=grpG)

grpR = "🎯 Reaction Detection"
touchTolerance  = input.float(0.3,  "Touch Tolerance × ATR",  minval=0.05, maxval=2.0,  step=0.05, group=grpR)
breakConfirm    = input.float(0.5,  "Break Confirm × ATR",    minval=0.1,  maxval=3.0,  step=0.1, group=grpR)
volumeBoost     = input.bool(true,  "Volume-Weighted Reactions", group=grpR)
rejectReward    = input.float(1.0,  "Reject Reward",          minval=0.1,  maxval=3.0,  step=0.1, group=grpR, tooltip="リジェクト時の正の報酬")
breakPenalty    = input.float(0.7,  "Break Penalty",          minval=0.1,  maxval=3.0,  step=0.1, group=grpR, tooltip="ブレイク時の負の報酬")
flipReward      = input.float(0.5,  "Flip Reward",            minval=0.0,  maxval=2.0,  step=0.1, group=grpR, tooltip="S/Rフリップ時のボーナス")

grpV = "🎨 Visualization"
showLabels      = input.bool(true,  "Show Score Labels",      group=grpV)
showAge         = input.bool(true,  "Show Age in Labels",     group=grpV)
showZones       = input.bool(true,  "Show Strong Zones",      group=grpV)
strongThreshold = input.float(0.70, "Strong Line Threshold",  minval=0.5, maxval=1.0, step=0.05, group=grpV)
colSupport      = input.color(color.rgb(80, 220, 140), "Support Color",     group=grpV)
colResistance   = input.color(color.rgb(255, 110, 110),"Resistance Color",  group=grpV)
colNeutral      = input.color(color.rgb(180, 180, 200),"Neutral Color",     group=grpV)
colStrong       = input.color(color.rgb(255, 220, 80), "Strong Highlight",  group=grpV)
colDying        = input.color(color.rgb(120, 120, 130),"Dying Lines",       group=grpV)
showPanel       = input.bool(true,  "Show Stats Panel",       group=grpV)
panelPos        = input.string("Top Right", "Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpV)

// ============================================================
// ▼ CONSTANTS
// ============================================================
// Pine の bar_index ベース座標は現在バーから約5000バーまで。安全マージンを取って4500。
int MAX_BARS_BACK = 4500

// 安全な x1 を返す（古すぎる bornBar をクランプ）
safeX1(int b) =>
    math.max(b, bar_index - MAX_BARS_BACK)

// ============================================================
// ▼ INDICATORS
// ============================================================
atrV    = ta.atr(14)
volSma  = ta.sma(volume, 20)
volRatio= volume / math.max(volSma, 1e-10)
ema21   = ta.ema(close, 21)
ema55   = ta.ema(close, 55)
trendBias = ema21 > ema55 ? 1 : ema21 < ema55 ? -1 : 0

// Pivots
ph = ta.pivothigh(high, pivotStrength, pivotStrength)
pl = ta.pivotlow(low, pivotStrength, pivotStrength)

// Williams Fractals (5-bar)
isUpFractal = high[2] > high[1] and high[2] > high[0] and high[2] > high[3] and high[2] > high[4]
isDnFractal = low[2]  < low[1]  and low[2]  < low[0]  and low[2]  < low[3]  and low[2]  < low[4]

// ============================================================
// ▼ S/R LINE OBJECT (User-Defined Type)
// ============================================================
type SRLine
    float price
    int   bornBar
    int   lastTouchBar
    int   touches
    int   rejects
    int   breaks
    int   flips
    float score
    float reward
    float volReactSum
    bool  isSupport
    bool  active
    line  ln
    label lb
    int   lastBreakBar
    bool  pendingFlip

var array<SRLine> srLines = array.new<SRLine>()

// ============================================================
// ▼ STATS COUNTERS (array-based, mutable inside functions)
// ============================================================
// stats[0] = totalGenerated
// stats[1] = totalDeleted
// stats[2] = totalRejects
// stats[3] = totalBreaks
// stats[4] = totalFlips
var array<int> stats = array.new<int>(5, 0)
var float globalSuccessRate = 0.5

incStat(int idx) =>
    array.set(stats, idx, array.get(stats, idx) + 1)

// ============================================================
// ▼ HELPERS
// ============================================================
isRoundNumber(float p) =>
    float log10p = math.log10(math.max(p, 1e-10))
    float magnitude = math.pow(10.0, math.floor(log10p) - 1)
    float rounded00 = math.round(p / magnitude / 100) * magnitude * 100
    float rounded50 = math.round(p / magnitude / 50)  * magnitude * 50
    float rounded10 = math.round(p / magnitude / 10)  * magnitude * 10
    float nearest = math.abs(p - rounded00) < math.abs(p - rounded50) ? rounded00 : rounded50
    nearest := math.abs(p - nearest) < math.abs(p - rounded10) ? nearest : rounded10
    [nearest, math.abs(p - nearest) / math.max(p, 1e-10) < 0.001]

existsNear(float p, float tolerance) =>
    bool found = false
    if array.size(srLines) > 0
        for i = 0 to array.size(srLines) - 1
            SRLine l = array.get(srLines, i)
            if l.active and math.abs(l.price - p) < tolerance
                found := true
                break
    found

updateScore(float curScore, float reward, float futureMax) =>
    float newQ = curScore + learningRate * (reward + discountFactor * futureMax - curScore)
    math.max(0.0, math.min(1.0, newQ))

// ============================================================
// ▼ LINE CREATION
// ============================================================
createLine(float p, int b, bool isSup, float initScore) =>
    SRLine sr = SRLine.new()
    sr.price        := p
    sr.bornBar      := b
    sr.lastTouchBar := b
    sr.touches      := 0
    sr.rejects      := 0
    sr.breaks       := 0
    sr.flips        := 0
    sr.score        := initScore
    sr.reward       := 0.0
    sr.volReactSum  := 0.0
    sr.isSupport    := isSup
    sr.active       := true
    sr.lastBreakBar := -1
    sr.pendingFlip  := false

    color baseCol = isSup ? colSupport : colResistance
    int   lw = initScore > 0.7 ? 3 : initScore > 0.5 ? 2 : 1
    int   transp = int(math.round(80 - initScore * 60))

    int x1 = safeX1(b)
    sr.ln := line.new(x1, p, bar_index + 50, p, color=color.new(baseCol, transp), width=lw, style=line.style_solid, extend=extend.right)
    sr.lb := label.new(bar_index + 50, p, "", color=color.new(baseCol, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)

    array.push(srLines, sr)
    incStat(0)  // totalGenerated += 1

// ============================================================
// ▼ NEW LINE GENERATION (Exploration)
// ============================================================
if not na(ph)
    float tol = atrV * gridSpacingATR * 0.5
    if not existsNear(ph, tol) and useSwingExtremes
        createLine(ph, bar_index - pivotStrength, false, 0.5)

if not na(pl)
    float tol = atrV * gridSpacingATR * 0.5
    if not existsNear(pl, tol) and useSwingExtremes
        createLine(pl, bar_index - pivotStrength, true, 0.5)

if useFractals and isUpFractal
    float p = high[2]
    float tol = atrV * gridSpacingATR * 0.4
    if not existsNear(p, tol)
        createLine(p, bar_index - 2, false, 0.4)

if useFractals and isDnFractal
    float p = low[2]
    float tol = atrV * gridSpacingATR * 0.4
    if not existsNear(p, tol)
        createLine(p, bar_index - 2, true, 0.4)

if bar_index % genFrequency == 0 and array.size(srLines) < maxLines
    int totalReacts = array.get(stats, 2) + array.get(stats, 3)
    float currentEpsilon = explorationRate * math.exp(-totalReacts / 200.0)

    if math.random(0, 100) / 100.0 < currentEpsilon
        float spacing = atrV * gridSpacingATR
        for i = 1 to 3
            float pUp = close + spacing * i
            float tolUp = spacing * 0.4
            if not existsNear(pUp, tolUp) and array.size(srLines) < maxLines
                createLine(pUp, bar_index, false, 0.3)
        for i = 1 to 3
            float pDn = close - spacing * i
            float tolDn = spacing * 0.4
            if not existsNear(pDn, tolDn) and array.size(srLines) < maxLines
                createLine(pDn, bar_index, true, 0.3)

    if useRoundNums
        [rn, isRn] = isRoundNumber(close)
        if isRn and not existsNear(rn, atrV * 0.3) and array.size(srLines) < maxLines
            createLine(rn, bar_index, close > rn, 0.55)

// ============================================================
// ▼ REACTION DETECTION & LEARNING UPDATE
// ============================================================
if barstate.isconfirmed and array.size(srLines) > 0
    int sz = array.size(srLines)

    float futureMax = 0.0
    for i = 0 to sz - 1
        SRLine l = array.get(srLines, i)
        if l.active and l.score > futureMax
            futureMax := l.score

    for i = 0 to sz - 1
        SRLine sr = array.get(srLines, i)
        if not sr.active
            continue

        float tol         = atrV * touchTolerance
        float breakLevel  = atrV * breakConfirm
        float volWeight   = volumeBoost ? math.min(volRatio, 3.0) : 1.0

        bool touched  = (high >= sr.price - tol and low <= sr.price + tol)
        bool brokeUp  = close > sr.price + breakLevel and open < sr.price
        bool brokeDn  = close < sr.price - breakLevel and open > sr.price
        bool rejected = false
        float reward  = 0.0

        if touched
            sr.touches := sr.touches + 1
            sr.lastTouchBar := bar_index

            if sr.isSupport
                if low <= sr.price + tol and close > sr.price + tol * 0.5 and not brokeDn
                    rejected := true
                    reward := rejectReward * volWeight
                    sr.rejects := sr.rejects + 1
                    incStat(2)
                    sr.volReactSum := sr.volReactSum + volRatio
                else if brokeDn
                    sr.breaks := sr.breaks + 1
                    incStat(3)
                    sr.lastBreakBar := bar_index
                    sr.pendingFlip  := true
                    reward := -breakPenalty * volWeight
            else
                if high >= sr.price - tol and close < sr.price - tol * 0.5 and not brokeUp
                    rejected := true
                    reward := rejectReward * volWeight
                    sr.rejects := sr.rejects + 1
                    incStat(2)
                    sr.volReactSum := sr.volReactSum + volRatio
                else if brokeUp
                    sr.breaks := sr.breaks + 1
                    incStat(3)
                    sr.lastBreakBar := bar_index
                    sr.pendingFlip  := true
                    reward := -breakPenalty * volWeight

        if sr.pendingFlip and bar_index - sr.lastBreakBar >= 3 and bar_index - sr.lastBreakBar <= 30
            if sr.isSupport and high >= sr.price - tol and close < sr.price
                sr.isSupport   := false
                sr.flips       := sr.flips + 1
                sr.pendingFlip := false
                incStat(4)
                reward += flipReward * volWeight
            else if not sr.isSupport and low <= sr.price + tol and close > sr.price
                sr.isSupport   := true
                sr.flips       := sr.flips + 1
                sr.pendingFlip := false
                incStat(4)
                reward += flipReward * volWeight

        int idleBars = bar_index - sr.lastTouchBar
        if idleBars > 5
            reward -= decayPerBar

        if reward != 0.0
            sr.score  := updateScore(sr.score, reward, futureMax)
            sr.reward := sr.reward + reward

        sr.score := math.max(0.0, sr.score - decayPerBar * 0.1)

        array.set(srLines, i, sr)

if array.get(stats, 2) + array.get(stats, 3) > 0
    globalSuccessRate := array.get(stats, 2) / float(array.get(stats, 2) + array.get(stats, 3))

// ============================================================
// ▼ EVOLUTION: PRUNING & VISUAL UPDATE
// ============================================================
if barstate.isconfirmed and array.size(srLines) > 0
    int i = 0
    while i < array.size(srLines)
        SRLine sr = array.get(srLines, i)

        if sr.active and sr.score < minScore and bar_index - sr.bornBar > 20
            line.delete(sr.ln)
            label.delete(sr.lb)
            sr.active := false
            incStat(1)
            array.remove(srLines, i)
            continue

        if sr.active
            color baseCol = sr.score >= strongThreshold ? colStrong : sr.isSupport ? colSupport : colResistance

            int lw = sr.score >= 0.85 ? 4 : sr.score >= 0.70 ? 3 : sr.score >= 0.50 ? 2 : 1

            int transp = int(math.round(85 - sr.score * 70))
            transp := math.max(5, math.min(90, transp))

            string lstyle = sr.score < 0.30 ? line.style_dotted : sr.score < 0.50 ? line.style_dashed : line.style_solid

            line.set_color(sr.ln, color.new(baseCol, transp))
            line.set_width(sr.ln, lw)
            line.set_style(sr.ln, lstyle)
            // ★ x1 をクランプして「too far from current bar」エラーを回避
            int safeBornBar = safeX1(sr.bornBar)
            line.set_xy1(sr.ln, safeBornBar, sr.price)
            line.set_xy2(sr.ln, bar_index + 50, sr.price)

            if showLabels
                int age = bar_index - sr.bornBar
                string ageStr  = showAge ? " [" + str.tostring(age) + "b]" : ""
                string scoreStr= str.tostring(math.round(sr.score * 100)) + "%"
                string symbolStr = sr.score >= 0.85 ? "★★★ " : sr.score >= 0.70 ? "★★ " : sr.score >= 0.50 ? "★ " : ""
                string typeStr = sr.isSupport ? "S " : "R "
                string statsStr= " " + str.tostring(sr.rejects) + "R/" + str.tostring(sr.breaks) + "B"
                if sr.flips > 0
                    statsStr := statsStr + "/" + str.tostring(sr.flips) + "F"

                label.set_xy(sr.lb, bar_index + 50, sr.price)
                label.set_text(sr.lb, symbolStr + typeStr + scoreStr + statsStr + ageStr)
                label.set_color(sr.lb, color.new(baseCol, math.max(20, transp - 20)))
                label.set_textcolor(sr.lb, sr.score >= 0.5 ? color.white : color.gray)
                label.set_size(sr.lb, sr.score >= strongThreshold ? size.small : size.tiny)
            else
                label.set_text(sr.lb, "")

            array.set(srLines, i, sr)

        i := i + 1

// Enforce max line cap (remove weakest)
if array.size(srLines) > maxLines
    float minS = 1.1
    int   minIdx = -1
    for i = 0 to array.size(srLines) - 1
        SRLine l = array.get(srLines, i)
        if l.active and l.score < minS
            minS   := l.score
            minIdx := i
    if minIdx >= 0
        SRLine weak = array.get(srLines, minIdx)
        line.delete(weak.ln)
        label.delete(weak.lb)
        incStat(1)
        array.remove(srLines, minIdx)

// ============================================================
// ▼ STRONG ZONES (Box highlight near strong lines)
// ============================================================
var array<box> zoneBoxes = array.new<box>()

if barstate.islast and array.size(zoneBoxes) > 0
    for i = 0 to array.size(zoneBoxes) - 1
        box.delete(array.get(zoneBoxes, i))
    array.clear(zoneBoxes)

if showZones and barstate.islast and array.size(srLines) > 0
    int drawn = 0
    for i = 0 to array.size(srLines) - 1
        if drawn >= 8
            break
        SRLine l = array.get(srLines, i)
        if l.active and l.score >= strongThreshold
            float halfW = atrV * touchTolerance * 1.2
            color zCol = l.isSupport ? colSupport : colResistance
            // ★ box の x1 もクランプ
            int boxX1 = safeX1(l.bornBar)
            box b = box.new(boxX1, l.price + halfW, bar_index + 30, l.price - halfW, bgcolor=color.new(zCol, 88), border_color=color.new(zCol, 60), border_width=1, border_style=line.style_dotted)
            array.push(zoneBoxes, b)
            drawn := drawn + 1

// ============================================================
// ▼ STATS PANEL
// ============================================================
panelPosition() =>
    string r = position.top_right
    if panelPos == "Top Right"
        r := position.top_right
    else if panelPos == "Top Left"
        r := position.top_left
    else if panelPos == "Bottom Right"
        r := position.bottom_right
    else if panelPos == "Bottom Left"
        r := position.bottom_left
    r

var table dash = table.new(panelPosition(), 2, 14, border_width=1)

if showPanel and barstate.islast
    int activeCount = 0
    int strongCount = 0
    int dyingCount  = 0
    float avgScore  = 0.0
    float maxScore  = 0.0
    int   totalTouches = 0
    int   totalRejs = 0
    int   totalBrks = 0

    if array.size(srLines) > 0
        for i = 0 to array.size(srLines) - 1
            SRLine l = array.get(srLines, i)
            if l.active
                activeCount := activeCount + 1
                avgScore    := avgScore + l.score
                if l.score > maxScore
                    maxScore := l.score
                if l.score >= strongThreshold
                    strongCount := strongCount + 1
                if l.score < 0.35
                    dyingCount := dyingCount + 1
                totalTouches := totalTouches + l.touches
                totalRejs    := totalRejs + l.rejects
                totalBrks    := totalBrks + l.breaks
        if activeCount > 0
            avgScore := avgScore / activeCount

    int totalGen     = array.get(stats, 0)
    int totalDel     = array.get(stats, 1)
    int totalRejAll  = array.get(stats, 2)
    int totalBrkAll  = array.get(stats, 3)
    int totalFlpAll  = array.get(stats, 4)

    int totalReact = totalRejAll + totalBrkAll
    float liveSuccessRate = totalReact > 0 ? totalRejAll / float(totalReact) * 100 : 0.0

    int totalLifetime = totalGen
    float survivalRate = totalLifetime > 0 ? activeCount / float(totalLifetime) * 100 : 0.0

    int totalReactsAll = totalRejAll + totalBrkAll
    float curEps = explorationRate * math.exp(-totalReactsAll / 200.0)

    color bg     = color.new(color.black, 75)
    color accent = color.rgb(180, 200, 255)
    color fg     = color.white

    table.cell(dash, 0, 0, "🧬 AE-SEG",       bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.normal)
    table.cell(dash, 1, 0, "Self-Evolving",   bgcolor=color.new(accent, 30), text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "Active Lines",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(activeCount) + " / " + str.tostring(maxLines), bgcolor=bg, text_color=accent, text_size=size.normal)

    table.cell(dash, 0, 2, "Strong Lines (★)",bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(strongCount), bgcolor=bg, text_color=colStrong, text_size=size.small)

    table.cell(dash, 0, 3, "Dying Lines",     bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(dyingCount), bgcolor=bg, text_color=colDying, text_size=size.small)

    table.cell(dash, 0, 4, "Avg Score",       bgcolor=bg, text_color=fg, text_size=size.small)
    color avgCol = avgScore >= 0.65 ? color.lime : avgScore >= 0.45 ? color.yellow : color.orange
    table.cell(dash, 1, 4, str.tostring(avgScore * 100, "0.0") + "%", bgcolor=bg, text_color=avgCol, text_size=size.small)

    table.cell(dash, 0, 5, "Max Score",       bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(maxScore * 100, "0.0") + "%", bgcolor=bg, text_color=colStrong, text_size=size.small)

    table.cell(dash, 0, 6, "Total Generated", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(totalGen), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 7, "Total Pruned",    bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(totalDel), bgcolor=bg, text_color=colDying, text_size=size.small)

    table.cell(dash, 0, 8, "Survival Rate",   bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 8, str.tostring(survivalRate, "0.0") + "%", bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0, 9, "Rejects / Breaks",bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1, 9, str.tostring(totalRejAll) + " / " + str.tostring(totalBrkAll), bgcolor=bg, text_color=fg, text_size=size.small)

    table.cell(dash, 0,10, "S/R Flips",       bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,10, str.tostring(totalFlpAll), bgcolor=bg, text_color=color.aqua, text_size=size.small)

    table.cell(dash, 0,11, "Win Rate (Live)", bgcolor=bg, text_color=fg, text_size=size.small)
    color wRateCol = liveSuccessRate >= 60 ? color.lime : liveSuccessRate >= 40 ? color.yellow : color.orange
    table.cell(dash, 1,11, totalReact > 0 ? str.tostring(liveSuccessRate, "0.0") + "%" : "—", bgcolor=bg, text_color=wRateCol, text_size=size.normal)

    table.cell(dash, 0,12, "Exploration (ε)", bgcolor=bg, text_color=fg, text_size=size.small)
    table.cell(dash, 1,12, str.tostring(curEps * 100, "0.0") + "%", bgcolor=bg, text_color=accent, text_size=size.small)

    table.cell(dash, 0,13, "Trend Bias",      bgcolor=bg, text_color=fg, text_size=size.small)
    string biasStr = trendBias > 0 ? "▲ Up" : trendBias < 0 ? "▼ Down" : "↔ Neutral"
    color  biasCol = trendBias > 0 ? color.lime : trendBias < 0 ? colResistance : color.gray
    table.cell(dash, 1,13, biasStr, bgcolor=bg, text_color=biasCol, text_size=size.small)

// ============================================================
// ▼ ALERTS
// ============================================================
bool nearStrongLine = false
bool brokeStrongLine = false
bool flipDetected = false
bool newGen = false

if barstate.isconfirmed and array.size(srLines) > 0
    for i = 0 to array.size(srLines) - 1
        SRLine l = array.get(srLines, i)
        if l.active and l.score >= strongThreshold
            float tol = atrV * touchTolerance * 1.5
            if math.abs(close - l.price) < tol
                nearStrongLine := true
            bool brokeS = l.isSupport and close < l.price - atrV * breakConfirm
            bool brokeR = (not l.isSupport) and close > l.price + atrV * breakConfirm
            if brokeS or brokeR
                brokeStrongLine := true
        if l.active and l.flips > 0 and bar_index - l.lastBreakBar < 3
            flipDetected := true

if not na(ph) or not na(pl)
    newGen := true

alertcondition(nearStrongLine,  title="AE-SEG: Approaching Strong Line",  message="価格が強力なS/Rライン近接")
alertcondition(brokeStrongLine, title="AE-SEG: Strong Line Break",        message="強力なS/Rラインがブレイクされました")
alertcondition(flipDetected,    title="AE-SEG: S/R Flip Detected",        message="サポートとレジスタンスのフリップを検出")
alertcondition(newGen,          title="AE-SEG: New Line Generated",       message="新規S/Rラインが生成されました")

plotshape(nearStrongLine,  title="Near Strong", style=shape.diamond,    location=location.belowbar, color=color.new(colStrong, 30), size=size.tiny)
plotshape(flipDetected,    title="Flip",        style=shape.triangleup, location=location.abovebar, color=color.new(color.aqua, 30), size=size.tiny)
````
