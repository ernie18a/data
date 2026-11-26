# Machine Learning Random Forest Strategy | GainzAlgo

- url: https://www.tradingview.com/script/AYYLVFTb-Machine-Learning-Random-Forest-Strategy-GainzAlgo/
- type: indicator
- pine_id: PUB;fab416ff3f7d4cf395603023dac09cc7
- version: 1.0

## Description

[b]Machine Learning Random Forest Strategy[/b]

We are excited to introduce the Machine Learning Based Random Forest Strategy indicator.

[b]What Even Is a Random Forest?[/b]

Machine learning and AI get thrown around so loosely these days that they've almost lost all meaning. So let's start from the beginning.

A Random Forest is an ensemble learning method. Instead of relying on a single model, it combines many models that work together and vote on an outcome.

The individual models are called decision trees.

A decision tree is essentially a flowchart:

[list]
[*]Is a feature above or below a threshold?
[*]If yes, go left.
[*]If no, go right.
[*]Continue until a prediction is reached.
[/list]

The problem with a single decision tree is that it is fragile. Train it on slightly different data and you may get a completely different tree. This creates high variance and causes overfitting.

This is the same weakness many rule-based indicators suffer from. They perform well in one market regime and break down when conditions change.

A Random Forest solves this problem through two core mechanisms:

[list]
[*][b]Bootstrap Sampling[/b] — Each tree is trained on a random subset of historical data using sampling with replacement.
[*][b]Random Feature Selection[/b] — Each tree can only evaluate a random subset of features at every split.
[/list]

Without random feature selection, every tree would focus on the same dominant signal and become nearly identical.

By forcing trees to learn different relationships, prediction errors become less correlated. When many uncorrelated predictors are averaged together, noise tends to cancel out while useful signal remains.

This is the foundation of ensemble learning and the reason Random Forests remain one of the most widely used machine learning models.

[b]The Pine Script Problem (And How We Solved It)[/b]

Pine Script was never designed to support traditional machine learning workflows.

There are no native machine learning primitives, no recursion, strict execution limits, and memory is largely restricted to arrays and matrices.

Building a traditional multi-level decision tree inside Pine Script is therefore extremely difficult.

The solution was to use decision stumps.

A decision stump is simply a decision tree with exactly one split.

By themselves, stumps are weak predictors. However, when many stumps are combined together using random feature selection, they form a legitimate shallow Random Forest.

The core ensemble behavior remains intact:

[list]
[*]Each stump learns a slightly different relationship.
[*]Prediction errors become decorrelated.
[*]Averaging outputs creates a more stable forecast.
[/list]

This is not a workaround.

A depth-1 Random Forest is still a Random Forest. Production libraries such as scikit-learn simply allow deeper trees, while the underlying ensemble mechanism remains the same.

[b]Threshold Optimization Using Information Gain[/b]

A naive stump implementation would select completely random thresholds.

The problem is that random thresholds often produce meaningless 50/50 predictions.

To solve this, the model performs a threshold search.

Each stump evaluates multiple candidate thresholds and selects the one that maximizes Information Gain using Gini Impurity.

[b]Gini Impurity Explained[/b]

[list]
[*]Gini = 0 → Perfectly pure node.
[*]Gini = 0.5 → Completely mixed node.
[*]Lower values are better.
[/list]

Information Gain measures how much impurity is reduced after a split.

The model evaluates multiple threshold candidates and selects the threshold that best separates bullish and bearish outcomes.

This is the same methodology used by scikit-learn's DecisionTreeClassifier using the Gini criterion.

[b]The Two Models Running In Parallel[/b]

The indicator actually runs two separate Random Forest models simultaneously.

[b]1. RF Classifier[/b]

The classifier answers a binary question:

"Is the next move likely bullish or bearish?"

It outputs a probability representing the likelihood that the next close will be higher than the current close.

This probability drives the signal generation process.

[list]
[*]Bull probability exceeds threshold → ▲ Bullish Signal
[*]Bear probability exceeds threshold → ▼ Bearish Signal
[/list]

[b]2. Regression Forest[/b]

The regression forest estimates the magnitude of the next move.

Instead of predicting direction, it predicts expected return.

This value appears as "Exp. Ret" inside the statistics table.

Having both models creates stronger confirmation.

[list]
[*]High Bull Probability + Positive Expected Return = Strong Confirmation
[*]High Bear Probability + Negative Expected Return = Strong Confirmation
[*]Conflicting Signals = Reduced Conviction
[/list]

[b]Features: What The Model Actually Looks At[/b]

All features are normalized to a 0-100 scale.

[b]Anchor Oscillator[/b]

Users can select:

[list]
[*]RSI
[*]MFI
[*]Stochastic
[*]Z-Score
[/list]

This acts as the model's primary momentum or mean reversion feature.

[b]Trend Correlation Feature[/b]

The model measures how strongly price has been correlated with time over a specified lookback period.

High values indicate strong directional trends.

Low values indicate choppy or sideways conditions.

[b]Momentum / ATR Feature[/b]

Raw momentum is normalized using ATR.

This allows momentum strength to remain comparable across different volatility environments.

[b]The Rolling Training Window[/b]

The model does not train on all historical data.

Instead, it continuously trains on the most recent N bars.

Every new bar:

[list]
[*]Oldest sample is removed.
[*]Newest sample is added.
[*]Model retrains using current market conditions.
[/list]

This is critical because markets are non-stationary.

Patterns that worked years ago may no longer be relevant today.

The rolling window helps the model adapt to changing market conditions.

[b]Preventing Lookahead Bias[/b]

Many TradingView machine learning indicators accidentally introduce lookahead bias.

This occurs when a model trains using information that would not have been available at the time of the prediction.

This implementation avoids that problem by using lagged feature values and future returns as targets.

The model only learns from information that genuinely existed before the outcome occurred.

[b]Adaptive Threshold: The Self-Correcting Layer[/b]

One of the most unique aspects of this indicator is its adaptive threshold system.

The default probability threshold is 60%.

However, that threshold is not fixed.

After trades resolve:

[list]
[*]Strong recent performance → Threshold remains relaxed.
[*]Weak recent performance → Threshold automatically increases.
[/list]

This forces the model to demand greater conviction during difficult market conditions.

When active, an orange ▲ marker appears next to the threshold value inside the statistics table.

This indicates that the model has tightened its own standards due to recent underperformance.

[b]Signal Logic & Cooldown[/b]

Signals are not generated continuously.

Instead, the indicator uses edge-detection logic.

Signals only trigger when probability crosses above the required threshold.

[list]
[*]Cross Above Threshold → New Signal
[*]Remain Above Threshold → No New Signal
[/list]

Additionally, a cooldown period prevents repetitive signals in the same direction.

The default cooldown is 10 bars.

This reduces signal clustering and improves overall readability.

[b]Reading The Statistics Table[/b]

The table provides a complete snapshot of model activity.

[list]
[*][b]Bull Prob[/b] — Current bullish probability estimate.
[*][b]Signal[/b] — Current directional bias.
[*][b]Exp. Ret[/b] — Expected return estimate.
[*][b]Anchor[/b] — Selected oscillator value.
[*][b]Eff. Thresh[/b] — Current effective threshold.
[/list]

The backtest section includes:

[list]
[*]Total Signals
[*]Win Rate
[*]Cumulative PnL
[*]Average Trade PnL
[*]Profit Factor
[*]Wins & Losses
[/list]

These values serve as a reality check based on current settings and chart conditions.

[b]How To Use The Indicator[/b]

Do not blindly chase every arrow.

The strongest opportunities occur when multiple components align.

Look for:

[list]
[*]High Bull Probability
[*]Positive Expected Return
[*]Clear Trend Structure
[*]Supportive Market Conditions
[/list]

When Bull Probability and Expected Return disagree, consider that a warning sign and reduce conviction.

[b]Training Window & Tree Selection[/b]

The training window controls how much recent history the model learns from.

[list]
[*]Short Window = Faster Adaptation
[*]Long Window = Greater Stability
[/list]

The number of trees controls prediction smoothness.

[list]
[*]More Trees = Smoother Predictions
[*]Fewer Trees = Faster Computation
[/list]

Default settings provide a balanced starting point for most markets.

[b]ADX Filtering[/b]

Optional ADX filtering can be enabled to isolate signals during stronger trending environments.

This tends to perform particularly well on higher timeframes.

[b]What This Isn't[/b]

A few honest disclaimers:

[list]
[*]This is not a deep neural network.
[*]This is not a full-depth Random Forest implementation.
[*]This is not a guaranteed profit system.
[*]This is not immune to changing market conditions.
[/list]

The model uses depth-1 decision stumps due to Pine Script limitations.

While this prevents complex nonlinear interactions, it preserves the core ensemble learning principles that make Random Forests effective.

The indicator intentionally uses only a handful of carefully selected features rather than overwhelming the model with unnecessary inputs.

[b]Wrapping It Up[/b]

The Machine Learning Random Forest Strategy combines legitimate ensemble learning concepts with practical market analysis.

By leveraging Random Forest classification, regression forecasting, adaptive probability thresholds, and rolling retraining windows, the indicator provides a unique framework for evaluating both direction and expected magnitude of future price movement.

Use it as a decision-support tool, combine it with sound risk management, and let probability—not prediction—guide your trading process.

## Source Code

````pine
//@version=6
indicator("Machine Learning Random Forest Strategy | GainzAlgo", overlay=true, max_labels_count=500, max_lines_count=200)


// User inputs 
anchorType      = input.string("RSI", "Anchor Oscillator", options=["RSI", "MFI", "Stochastic", "Z-Score"])
anchorLen       = input.int(14, "Anchor Length", minval=2, maxval=100)

// Feats 
trendLen        = input.int(20, "Trend Correlation Length", minval=5, maxval=100)
momLen          = input.int(10, "Momentum / ATR Length", minval=2, maxval=50)

//RF settings 
lookback        = input.int(60, "Training Window (bars)", minval=20, maxval=300)
numTrees        = input.int(30, "Number of Trees", minval=10, maxval=100)
probThreshold   = input.float(0.60, "Signal Probability Threshold", minval=0.5, maxval=0.95, step=0.01)
signalCooldown  = input.int(10,   "Min Bars Between Like Signals",  minval=1,   maxval=50)

// Thresh inputs, defaulting to auto 
adaptiveOn      = input.bool(true,  "Adaptive Threshold (tighten on losses)")
adaptLookback   = input.int(5,    "Trades to Look Back For Adaptation", minval=3, maxval=20)
adaptMaxBoost   = input.float(0.08, "Max Threshold Boost",  minval=0.01, maxval=0.20, step=0.01)

// nTree 
numTreesReg     = input.int(20, "Regression Trees", minval=5, maxval=100)

// TP and SL 
atrMultTP       = input.float(2.0, "Target Price ATR Multiple", minval=0.5, maxval=10.0, step=0.1)
atrMultSL       = input.float(2.0, "Stop Loss ATR Multiple",    minval=0.5, maxval=10.0, step=0.1)
tpSlLen         = input.int(14, "ATR Length for TP/SL",         minval=2,   maxval=50)
lineLookback    = input.int(20, "TP/SL Line Extension (bars)",  minval=5,   maxval=100)

// Design 
showSignals     = input.bool(true,  "Show Signal Labels with Probability")
showTPSL        = input.bool(true,  "Show Target / Stop Lines")
showHistLines   = input.bool(false, "Show Historical TP/SL Lines (off = current signal only)")
showBacktest    = input.bool(true,  "Show Backtest Table")

// ADX Filter
adxFilterOn     = input.bool(false, "Enable ADX Trend Filter", group="ADX Filter")
adxLen          = input.int(14,     "ADX Length",              group="ADX Filter", minval=2, maxval=100)
adxThreshold    = input.float(25.0, "Minimum ADX Level",       group="ADX Filter", minval=5.0, maxval=80.0, step=0.5)

type TreeStump
    int   featureIndex
    float threshold
    float leftValue
    float rightValue

type RandomForest
    array<TreeStump> trees

type ClfStump
    int   featureIndex
    float threshold
    float leftProb
    float rightProb

type RFClassifier
    array<ClfStump> trees

// RANDOM FOREST ENSEMBLE — trainForest() + predict()
// Pine Script has no native ML primitives, so this implements a
// Random Forest from scratch using two cooperating methods.
//
// A true Random Forest is a collection of decision trees, each trained
// on a random bootstrap sample of the data, that vote together to
// produce a final prediction. Averaging many decorrelated trees
// dramatically reduces variance compared to any single tree.
//
// Pine's execution model (no recursion, no dynamic memory beyond
// arrays/matrices, strict per-bar compute limits) means we cannot
// grow full multi-level trees. Instead each tree is a decision
// stump, a single binary split on one feature, which is the
// minimal unit of a decision tree. An ensemble of stumps is
// mathematically equivalent to a depth 1 Random Forest and retains
// the core ensemble property: individually weak learners combining
// into a stronger, more stable predictor.
//
// trainForest()
// Accepts a feature matrix X (samples × features) and a target vector
// Y of continuous values (e.g. forward returns), plus nTrees stumps
// to build. For each stump it:
//   1. Picks a random feature column  (stochastic feature selection —
//      the defining characteristic of RF vs plain bagging)
//   2. Picks a random sample row as the split threshold
//   3. Partitions all training samples left (≤ threshold) or right
//   4. Computes the mean target value on each side (leftMean/rightMean)
//   5. Stores the stump as a TreeStump UDT and pushes it to the forest
//
// Random feature selection at step 1 is what decorrelates the stumps
// from each other — without it, every stump would gravitate toward
// the same dominant feature and the ensemble would behave like a
// single model. This mirrors the sqrt(nFeatures) subspace sampling
// used in production RF libraries.
//
// 
// Given a live feature vector, each stump routes the observation
// left or right and returns its precomputed leaf mean. predict()
// averages all stump outputs — this is the ensemble vote. Because
// each stump was trained on a random feature/threshold combination,
// their errors are largely uncorrelated, so the average converges
// toward the true conditional expectation of Y faster than any
// individual stump could. This is the bias-variance tradeoff that
// makes Random Forests work.

method trainForest(matrix<float> X, array<float> Y, int nTrees) =>
    int ns = array.size(Y)
    int nf = matrix.columns(X)
    array<TreeStump> stumps = array.new<TreeStump>()
    if ns > 0 and nf > 0
        for i = 0 to nTrees - 1
            int fIdx      = math.min(int(math.random(0, nf)), nf - 1)
            int rSamp     = math.min(int(math.random(0, ns)), ns - 1)
            float thresh  = matrix.get(X, rSamp, fIdx)
            float lSum = 0., float rSum = 0.
            int   lCnt = 0,  int   rCnt = 0
            for s = 0 to ns - 1
                float fv = matrix.get(X, s, fIdx)
                float tv = array.get(Y, s)
                if fv <= thresh
                    lSum += tv
                    lCnt += 1
                else
                    rSum += tv
                    rCnt += 1
            float lMean = lCnt > 0 ? lSum / lCnt : 0.
            float rMean = rCnt > 0 ? rSum / rCnt : 0.
            array.push(stumps, TreeStump.new(fIdx, thresh, lMean, rMean))
    RandomForest.new(stumps)

method predict(RandomForest rf, array<float> features) =>
    float s = 0.
    int n   = array.size(rf.trees)
    if n > 0
        for i = 0 to n - 1
            TreeStump st = array.get(rf.trees, i)
            float val    = array.get(features, st.featureIndex)
            s += val <= st.threshold ? st.leftValue : st.rightValue
        s / n
    else
        na

// RF CLASSIFIER — trainClassifier() + predictProb()
// This pair is the classification counterpart to trainForest/predict.
// Where trainForest predicts a continuous value (regression), this
// predicts a probability specifically, the probability that the
// next move is bullish (class 1 vs class 0).
//
// The critical upgrade over a naive random stump ensemble is the
// threshold search loop. A naive implementation picks one random
// threshold and keeps it regardless of quality, producing stumps that
// are essentially coin flippers, whose outputs average to ~0.50 and
// never cross a meaningful signal threshold. This implementation
// instead searches nThreshTries candidate thresholds per stump and
// keeps only the one that maximises Information Gain, making each
// stump a genuine discriminator rather than noise.
//
// Gini Impurity & Information Gain
// Gini impurity measures how mixed a node is:
// Gini = 1 - p² - (1-p)²
// where p is the proportion of class-1 (bull) samples. A pure node
// (all bull or all bear) has Gini = 0. A perfectly mixed node has
// Gini = 0.5. Information Gain is the reduction in weighted Gini
// achieved by a split:
// Gain = Gini(parent) - (nL/n)*Gini(left) - (nR/n)*Gini(right)
// A split that perfectly separates bulls from bears maximises Gain.
// A split that puts the same mix on both sides has Gain ≈ 0 and is
// discarded. This is the same criterion used by scikit-learn's
// DecisionTreeClassifier with criterion="gini".
//
// trainClassifier() 
// For each of nTrees stumps:
//   1. Randomly selects a feature (decorrelates stumps core RF trait)
//   2. Pre-computes the dataset's base Gini impurity once, outside the
//      threshold loop, to avoid redundant recalculation
//   3. Tries nThreshTries random sample values as candidate thresholds
//   4. For each candidate, partitions the training set and computes
//      the weighted Gini of the resulting left/right nodes
//   5. Skips degenerate splits (all samples on one side — zero info)
//   6. Retains the threshold that produced the highest Information Gain
//   7. Stores leftProb and rightProb, the empirical bull probability
//      on each side of the winning split as the stump's leaf values
//
// nThreshTries is the tuning knob between speed and split quality.
// At 10 tries the search finds a meaningfully better threshold than
// random chance without being prohibitively slow in Pine's per-bar
// compute budget. Higher values improve split quality at the cost of
// indicator load time.
//
// predictProb()
// Routes a live feature vector through every stump and averages the
// leaf probabilities. Each stump contributes either its leftProb or
// rightProb depending on which side the live observation falls.
// Averaging N decorrelated probability estimates converges toward the
// true conditional probability of a bullish outcome the law of large
// numbers working in our favour. The result is compared against
// effectiveThreshold (base + adaptive boost) to gate signal emission,
// ensuring only high-conviction ensemble agreement produces an arrow.


method trainClassifier(matrix<float> X, array<int> Y, int nTrees) =>
    int ns = array.size(Y)
    int nf = matrix.columns(X)
    array<ClfStump> stumps = array.new<ClfStump>()
    int nThreshTries = 10
    if ns > 0 and nf > 0
        int totalBull = 0
        for s = 0 to ns - 1
            if array.get(Y, s) == 1
                totalBull += 1
        float pBase    = float(totalBull) / float(ns)
        float giniBase = 1.0 - pBase * pBase - (1.0 - pBase) * (1.0 - pBase)

        for i = 0 to nTrees - 1
            int fIdx = math.min(int(math.random(0, nf)), nf - 1)
            float bestGain   = -1.0
            float bestThresh = matrix.get(X, 0, fIdx)
            float bestLProb  = 0.5
            float bestRProb  = 0.5

            for t = 0 to nThreshTries - 1
                int   rSamp  = math.min(int(math.random(0, ns)), ns - 1)
                float thresh = matrix.get(X, rSamp, fIdx)

                int lBull = 0, int lTotal = 0
                int rBull = 0, int rTotal = 0
                for s = 0 to ns - 1
                    float fv  = matrix.get(X, s, fIdx)
                    int   cls = array.get(Y, s)
                    if fv <= thresh
                        lTotal += 1
                        if cls == 1
                            lBull += 1
                    else
                        rTotal += 1
                        if cls == 1
                            rBull += 1


                if lTotal > 0 and rTotal > 0
                    float pL    = float(lBull) / float(lTotal)
                    float pR    = float(rBull) / float(rTotal)
                    float giniL = 1.0 - pL * pL - (1.0 - pL) * (1.0 - pL)
                    float giniR = 1.0 - pR * pR - (1.0 - pR) * (1.0 - pR)
                    float weightedGini = (float(lTotal) * giniL + float(rTotal) * giniR) / float(ns)
                    float infoGain     = giniBase - weightedGini

                    if infoGain > bestGain
                        bestGain   := infoGain
                        bestThresh := thresh
                        bestLProb  := pL
                        bestRProb  := pR

            array.push(stumps, ClfStump.new(fIdx, bestThresh, bestLProb, bestRProb))
    RFClassifier.new(stumps)

method predictProb(RFClassifier clf, array<float> features) =>
    float probSum = 0.
    int n         = array.size(clf.trees)
    if n > 0
        for i = 0 to n - 1
            ClfStump st = array.get(clf.trees, i)
            float val   = array.get(features, st.featureIndex)
            probSum    += val <= st.threshold ? st.leftProb : st.rightProb
        probSum / n
    else
        na

// Feat engineering 


float anchorRaw = switch anchorType
    "RSI"        => ta.rsi(close, anchorLen)
    "MFI"        => ta.mfi(hlc3, anchorLen)
    "Stochastic" => ta.stoch(close, high, low, anchorLen)
    "Z-Score"    =>
        float m  = ta.sma(close, anchorLen)
        float s2 = ta.stdev(close, anchorLen)
        s2 > 0 ? math.max(0, math.min(100, 50 + (close - m) / s2 * 16.67)) : 50.
    => ta.rsi(close, anchorLen)

float trendCorr = ta.correlation(close, bar_index, trendLen)
float trendFeat = 50 + trendCorr * 50

float momRaw    = ta.mom(close, momLen)
float atrRaw    = ta.atr(momLen)
float momNorm   = atrRaw > 0 ? momRaw / atrRaw : 0
float momFeat   = math.max(0, math.min(100, 50 + momNorm * 16.67))

float atrTP     = ta.atr(tpSlLen)

// ADX calculation
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
bool  adxPass   = not adxFilterOn or adxVal >= adxThreshold

int   classTarget = close > close[1] ? 1 : 0
float regTarget   = close - close[1]

// Training data on a rolling window. 
// Training data on a rolling window ensures continious alignment with current regime as well as prevents 
// memorization or overfitting. This is critical as many Pine based MLAs succumb to an overfitting/overrepresentation bias 
// where they know what comes ahead and are "peaking" on the data. 

var matrix<float> X_clf = matrix.new<float>(0, 3)
var array<int>    Y_clf = array.new<int>()
var matrix<float> X_reg = matrix.new<float>(0, 3)
var array<float>  Y_reg = array.new<float>()

if barstate.isconfirmed
    array<float> histFeatures = array.from(anchorRaw[1], trendFeat[1], momFeat[1])
    matrix.add_row(X_clf, matrix.rows(X_clf), histFeatures)
    array.push(Y_clf, classTarget)
    matrix.add_row(X_reg, matrix.rows(X_reg), histFeatures)
    array.push(Y_reg, regTarget)
    if array.size(Y_clf) > lookback
        matrix.remove_row(X_clf, 0)
        array.shift(Y_clf)
        matrix.remove_row(X_reg, 0)
        array.shift(Y_reg)

// Execution:
// Train and predict happens here 

var float bullProb       = na
var float expectedReturn = na

if array.size(Y_clf) == lookback
    array<float> curFeatures = array.from(anchorRaw, trendFeat, momFeat)
    RFClassifier clfModel    = X_clf.trainClassifier(Y_clf, numTrees)
    bullProb                := clfModel.predictProb(curFeatures)
    RandomForest regModel    = X_reg.trainForest(Y_reg, numTreesReg)
    expectedReturn          := regModel.predict(curFeatures)




// ADAPTIVE THRESHOLD
// Track recent resolved trade PnLs to gauge recent performance.
// If recent trades are net-negative, raise the effective threshold
// (require higher conviction). If they're net-positive, relax it back.

var array<float> adapt_pnlHistory = array.new<float>()


var float adaptThreshBoost = 0.0

float effectiveThreshold = probThreshold + (adaptiveOn ? adaptThreshBoost : 0.0)

// Signals 

float bearProb   = na(bullProb) ? na : 1.0 - bullProb
bool  bullSignal = not na(bullProb) and bullProb >= effectiveThreshold
bool  bearSignal = not na(bullProb) and bearProb >= effectiveThreshold

var bool prevBullSig    = false
var bool prevBearSig    = false
var int  lastBullBar    = -999
var int  lastBearBar    = -999

bool coolBull = bar_index - lastBullBar >= signalCooldown
bool coolBear = bar_index - lastBearBar >= signalCooldown

bool freshBull = bullSignal and not prevBullSig and coolBull and adxPass
bool freshBear = bearSignal and not prevBearSig and coolBear and adxPass

if barstate.isconfirmed
    prevBullSig := bullSignal
    prevBearSig := bearSignal
    if freshBull
        lastBullBar := bar_index
    if freshBear
        lastBearBar := bar_index

// Labels and Prob display 

if showSignals and barstate.isconfirmed
    if freshBull
        int pct = int(math.round(bullProb * 100))
        label.new(bar_index, low * 0.9995,
             text    = "▲ " + str.tostring(pct) + "%",
             color   = color.new(color.green, 10),
             textcolor = color.white,
             style   = label.style_label_up,
             size    = size.normal)

    if freshBear
        int pct = int(math.round(bearProb * 100))
        label.new(bar_index, high * 1.0005,
             text    = "▼ " + str.tostring(pct) + "%",
             color   = color.new(color.red, 10),
             textcolor = color.white,
             style   = label.style_label_down,
             size    = size.normal)


// Determing price target and SL. 
// We draw a TP line and SL line when a fresh signal fires.
// TP = entry ± atrMultTP * ATR
// SL = entry ∓ atrMultSL * ATR
// When showHistLines is off, we keep only the most recent TP/SL pair
// by deleting the previous lines before drawing new ones.

var line lastTPLine = na
var line lastSLLine = na
var label lastTPLabel = na
var label lastSLLabel = na

if showTPSL and barstate.isconfirmed
    if freshBull
        float tp = close + atrMultTP * atrTP
        float sl = close - atrMultSL * atrTP
        if not showHistLines
            line.delete(lastTPLine)
            line.delete(lastSLLine)
            label.delete(lastTPLabel)
            label.delete(lastSLLabel)
        lastTPLine  := line.new(bar_index, tp, bar_index + lineLookback, tp,
             color     = color.new(color.lime, 20),
             style     = line.style_dashed,
             width     = 2)
        lastSLLine  := line.new(bar_index, sl, bar_index + lineLookback, sl,
             color     = color.new(color.red, 20),
             style     = line.style_dashed,
             width     = 2)
        lastTPLabel := label.new(bar_index + lineLookback, tp,
             text      = "TP " + str.tostring(math.round(tp, 2)),
             color     = color.new(color.lime, 30),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small)
        lastSLLabel := label.new(bar_index + lineLookback, sl,
             text      = "SL " + str.tostring(math.round(sl, 2)),
             color     = color.new(color.red, 30),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small)

    if freshBear
        float tp = close - atrMultTP * atrTP
        float sl = close + atrMultSL * atrTP
        if not showHistLines
            line.delete(lastTPLine)
            line.delete(lastSLLine)
            label.delete(lastTPLabel)
            label.delete(lastSLLabel)
        lastTPLine  := line.new(bar_index, tp, bar_index + lineLookback, tp,
             color     = color.new(color.lime, 20),
             style     = line.style_dashed,
             width     = 2)
        lastSLLine  := line.new(bar_index, sl, bar_index + lineLookback, sl,
             color     = color.new(color.red, 20),
             style     = line.style_dashed,
             width     = 2)
        lastTPLabel := label.new(bar_index + lineLookback, tp,
             text      = "TP " + str.tostring(math.round(tp, 2)),
             color     = color.new(color.lime, 30),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small)
        lastSLLabel := label.new(bar_index + lineLookback, sl,
             text      = "SL " + str.tostring(math.round(sl, 2)),
             color     = color.new(color.red, 30),
             textcolor = color.white,
             style     = label.style_label_left,
             size      = size.small)

// P&L logic 
// For each completed signal we check, after lineLookback bars,
// whether the trade hit TP first or SL first (or neither = open).
// We track: total signals, wins (TP hit), losses (SL hit), avg pnl %.

var int   bt_total       = 0
var int   bt_wins        = 0
var int   bt_losses      = 0
var float bt_pnlSum      = 0.0   
var float bt_grossProfit = 0.0   
var float bt_grossLoss   = 0.0   


var array<float> bt_entry  = array.new<float>()
var array<int>   bt_dir    = array.new<int>()
var array<float> bt_tp     = array.new<float>()
var array<float> bt_sl     = array.new<float>()
var array<int>   bt_barIdx = array.new<int>()

if barstate.isconfirmed
    if freshBull
        array.push(bt_entry,  close)
        array.push(bt_dir,    1)
        array.push(bt_tp,     close + atrMultTP * atrTP)
        array.push(bt_sl,     close - atrMultSL * atrTP)
        array.push(bt_barIdx, bar_index)

    if freshBear
        array.push(bt_entry,  close)
        array.push(bt_dir,    -1)
        array.push(bt_tp,     close - atrMultTP * atrTP)
        array.push(bt_sl,     close + atrMultSL * atrTP)
        array.push(bt_barIdx, bar_index)


    int i = 0
    while i < array.size(bt_barIdx)
        int   openBar = array.get(bt_barIdx, i)
        int   dir     = array.get(bt_dir,    i)
        float ep      = array.get(bt_entry,  i)
        float tpLvl   = array.get(bt_tp,     i)
        float slLvl   = array.get(bt_sl,     i)

        bool  tpHit   = dir == 1 ? high >= tpLvl : low  <= tpLvl
        bool  slHit   = dir == 1 ? low  <= slLvl : high >= slLvl
        bool  expired = bar_index - openBar >= lineLookback

        if tpHit or slHit or expired
            bt_total += 1
            float pnl = 0.0
            if tpHit and not slHit
                bt_wins  += 1
                pnl      := dir * (tpLvl - ep) / ep * 100 
            else if slHit and not tpHit
                bt_losses += 1
                pnl      := dir * (slLvl - ep) / ep * 100  
            else if expired and not (tpHit or slHit)
                pnl      := dir * (close - ep) / ep * 100
                if pnl > 0
                    bt_wins += 1
                else
                    bt_losses += 1
            else
 
                bt_losses += 1
                pnl      := dir * (slLvl - ep) / ep * 100
            bt_pnlSum += pnl
            if pnl > 0
                bt_grossProfit += pnl
            else
                bt_grossLoss   += math.abs(pnl)


            if adaptiveOn
                array.push(adapt_pnlHistory, pnl)

                if array.size(adapt_pnlHistory) > adaptLookback
                    array.shift(adapt_pnlHistory)
       
                float recentSum = 0.0
                int   rn        = array.size(adapt_pnlHistory)
                for ri = 0 to rn - 1
                    recentSum += array.get(adapt_pnlHistory, ri)
                float recentAvg = rn > 0 ? recentSum / rn : 0.0
        
                float rawBoost = recentAvg < 0 ? math.min(math.abs(recentAvg) / 2.0, adaptMaxBoost) : 0.0
                adaptThreshBoost := rawBoost

            array.remove(bt_entry,  i)
            array.remove(bt_dir,    i)
            array.remove(bt_tp,     i)
            array.remove(bt_sl,     i)
            array.remove(bt_barIdx, i)
        else
            i += 1
//Stats Table 

var table mainTable = table.new(position.top_right, 2, 14,
     bgcolor      = color.new(color.black, 75),
     border_color = color.new(color.gray, 50),
     border_width = 1,
     frame_color  = color.new(color.gray, 40),
     frame_width  = 1)

if barstate.islast

    table.cell(mainTable, 0, 0, "RF COMBO",    text_color=color.new(color.white, 10), text_size=size.small, bgcolor=color.new(color.navy, 40))
    table.cell(mainTable, 1, 0, "VALUE",        text_color=color.new(color.white, 10), text_size=size.small, bgcolor=color.new(color.navy, 40))


    float bpDisp = na(bullProb) ? na : math.round(bullProb * 100, 1)
    color bpCol  = na(bullProb) ? color.gray : bullProb > 0.5 ? color.new(color.lime, 10) : color.new(color.red, 10)
    table.cell(mainTable, 0, 1, "Bull Prob",   text_color=color.gray,  text_size=size.small)
    table.cell(mainTable, 1, 1, na(bpDisp) ? "..." : str.tostring(bpDisp) + "%", text_color=bpCol, text_size=size.small)

    string callStr = na(bullProb) ? "..." : bullProb >= probThreshold ? "BULL ▲" : (1 - bullProb) >= probThreshold ? "BEAR ▼" : "NEUTRAL"
    color  callCol = na(bullProb) ? color.gray : bullProb >= probThreshold ? color.lime : (1 - bullProb) >= probThreshold ? color.red : color.gray
    table.cell(mainTable, 0, 2, "Signal",       text_color=color.gray,  text_size=size.small)
    table.cell(mainTable, 1, 2, callStr,         text_color=callCol,     text_size=size.small)

    float erDisp = na(expectedReturn) ? na : math.round(expectedReturn, 4)
    color erCol  = na(expectedReturn) ? color.gray : expectedReturn > 0 ? color.lime : color.red
    table.cell(mainTable, 0, 3, "Exp. Ret",    text_color=color.gray,  text_size=size.small)
    table.cell(mainTable, 1, 3, na(erDisp) ? "..." : str.tostring(erDisp), text_color=erCol, text_size=size.small)

    table.cell(mainTable, 0, 4, "Anchor",       text_color=color.gray,  text_size=size.small)
    table.cell(mainTable, 1, 4, anchorType + " " + str.tostring(math.round(anchorRaw, 1)),
               text_color=color.white, text_size=size.small)


    float dispThresh = math.round(effectiveThreshold * 100, 1)
    color threshCol  = adaptThreshBoost > 0.01 ? color.new(color.orange, 10) : color.new(color.gray, 10)
    table.cell(mainTable, 0, 5, "Eff. Thresh",  text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 5, str.tostring(dispThresh) + "%" + (adaptThreshBoost > 0.005 ? " ▲" : ""),
               text_color=threshCol, text_size=size.small)

    float adxDisp  = math.round(adxVal, 1)
    color adxCol   = not adxFilterOn ? color.new(color.gray, 40) : adxVal >= adxThreshold ? color.new(color.lime, 10) : color.new(color.red, 10)
    string adxStr  = not adxFilterOn ? str.tostring(adxDisp) + " (off)" : adxVal >= adxThreshold ? str.tostring(adxDisp) + " ✓" : str.tostring(adxDisp) + " ✗"
    table.cell(mainTable, 0, 6, "ADX",           text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 6, adxStr,           text_color=adxCol,    text_size=size.small)


    table.cell(mainTable, 0, 7, "── BACKTEST ──", text_color=color.new(color.gray, 30), text_size=size.small)
    table.cell(mainTable, 1, 7, "",               text_color=color.gray, text_size=size.small)


    table.cell(mainTable, 0, 8, "Signals",      text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 8, str.tostring(bt_total), text_color=color.white, text_size=size.small)

    float winRate = bt_total > 0 ? math.round(float(bt_wins) / float(bt_total) * 100, 1) : na
    color wrCol   = na(winRate) ? color.gray : winRate >= 50 ? color.lime : color.red
    table.cell(mainTable, 0, 9, "Win Rate",     text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 9, na(winRate) ? "..." : str.tostring(winRate) + "%", text_color=wrCol, text_size=size.small)


    float cumulPnl = math.round(bt_pnlSum, 2)
    color cpCol    = cumulPnl >= 0 ? color.lime : color.red
    table.cell(mainTable, 0, 10,  "Cumul PnL",    text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 10,  str.tostring(cumulPnl) + "%", text_color=cpCol, text_size=size.small)


    float avgPnl = bt_total > 0 ? math.round(bt_pnlSum / bt_total, 2) : na
    color apCol  = na(avgPnl) ? color.gray : avgPnl >= 0 ? color.lime : color.red
    table.cell(mainTable, 0, 11, "Avg PnL/Trade", text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 11, na(avgPnl) ? "..." : str.tostring(avgPnl) + "%", text_color=apCol, text_size=size.small)


    float pf    = bt_grossLoss > 0 ? math.round(bt_grossProfit / bt_grossLoss, 2) : bt_grossProfit > 0 ? 999.0 : na
    color pfCol = na(pf) ? color.gray : pf >= 1.0 ? color.lime : color.red
    string pfStr = na(pf) ? "..." : pf == 999.0 ? "MAX" : str.tostring(pf)
    table.cell(mainTable, 0, 12, "Profit Factor", text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 12, pfStr,            text_color=pfCol,     text_size=size.small)

    table.cell(mainTable, 0, 13, "W / L",          text_color=color.gray, text_size=size.small)
    table.cell(mainTable, 1, 13, str.tostring(bt_wins) + " / " + str.tostring(bt_losses),
               text_color=color.white, text_size=size.small)
````
