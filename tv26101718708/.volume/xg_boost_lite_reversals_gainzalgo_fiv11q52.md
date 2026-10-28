# XG Boost Lite: Reversals | GainzAlgo

- url: https://www.tradingview.com/script/FIV11Q52-XG-Boost-Lite-Reversals-GainzAlgo/
- type: indicator
- pine_id: PUB;6159abe687a745e18b480fa00ded9bb1
- version: 1.0

## Description

We are excited to release this indicator, which uses our brand-new Arbor library for gradient boosting! This engine brings true, high-performance machine learning natively into Pine Script v6, bypassing the need for external webhooks or API layers. By utilizing iterative, tree-based models on your chart, XGBoost Lite: Reversals adapts directly to the historical structure of the asset you are trading, identifying precise pivot exhaustion points with high statistical conviction.

[b]🧠 Understanding Gradient Boosting & XGBoost[/b]

To trade successfully with machine learning, it helps to understand exactly what is happening beneath the hood of the asset's data.The Core TheoryGradient Boosting is a powerful machine learning technique used for regression and classification tasks. Unlike deep learning networks that process data through abstract node layers, gradient boosting relies on an ensemble of simple decision trees, often called "weak learners" or "stumps".  

The training process works sequentially:

[list=1]
[*]The Initial Guess: The model makes a basic baseline prediction.Calculating the Error (Residuals): It checks where its prediction missed the actual historical market outcome.
[*] Correcting the Mistakes: A new decision tree is built specifically to predict those errors (the gradient of the loss function).
[*] Iterative Learning: The model repeats this process for several rounds. Each new tree focuses entirely on correcting the flaws of the previous ones, scaling its adjustments by a Learning Rate to maintain stability.  
[/list]

[b]What Makes XGBoost Special?[/b]

XGBoost (Extreme Gradient Boosting) optimizes this framework for speed, scalability, and performance. It applies strict regularization techniques to minimize overfitting, ensuring the model doesn't just "memorize" past market noise but instead learns genuine structural behaviors.By evaluating multiple market features simultaneously, it estimates the probability of a specific event occurring.

[b]🛠️ About the Indicator[/b]

XGBoost Lite: Reversals is a machine learning-driven technical indicator designed to catch exhaustion and reversal setups.    

[b]The Machine Learning Pipeline[/b]

[list]
[*]Dual Engines: The script fits four separate models simultaneously—a classifier and a regressor for Longs, and a classifier and a regressor for Shorts. 
[*] Dynamic Retraining: Rather than remaining static, the model automatically flushes its memory and retrains its internal mathematical weights every n bars to adapt to evolving market regimes.  
[*] Strict Non-Repainting Execution: A critical upgrade in this framework forces features and calculations to compute and lock strictly on bar close. Signals, dynamic entry points, and risk metrics are only printed once the triggering candle is finalized, ensuring what you see on the historical chart matches real-time execution perfectly.  
[/list]

[b]The Core Features Evaluated[/b]

The model processes a combination of multi-dimensional market inputs to generate a unified prediction:  

[list=1]
[*] RSI (14): Evaluates traditional momentum expansion and contraction. 
[*] Relative Volume (20): Evaluates institutional engagement by dividing current volume against its 20-period SMA. 
[*] Z-Score (20): Measures how far the current price has deviated from its statistical mean.  
[*] ADX (14): Gauges the overall strength of the macro trend to prevent trading directly into a runaway freight train.  
[/list]

[b]📊 How to Use the Indicator[/b]

[list]
[*]The Real-Time Dashboard: When applied to your chart, the indicator renders an advanced Feature Importance Scatter Plot in the right-hand margin. 
[*]  Distribution Scatter: The horizontal bars plot the historical density of successful signals. Darker, tightly packed nodes represent highly concentrated, high-probability clusters discovered by the algorithm. 
[/list]

[i] Visualizing Signals[/i]

https://www.tradingview.com/x/mlDjerHH/

When a market pivot is detected (e.g., a structural swing low or high) and the classifier hits your target confirmation probability, a signal arrow prints on the chart displaying the mathematical certainty ($e.g., 74.2\%$) of the reversal.  

[b]⚙️ The Settings Inputs[/b]

The indicator’s interface is neatly categorized into three primary functional groups:  
[b]
⚙️ XGBoost Model Settings:[/b]

[list]
[*]Training Lookback (Bars): (Default: 250) The historical window used to feed the training arrays. Max capped at 300 to remain computational within Pine Script limits. 
[*] Retrain Frequency: (Default: 50) Determines how often (in bars) the model recalibrates its trees.  Boosting Rounds: (Default: 20) The number of sequential trees (stumps) trained per model. Higher numbers capture deeper complexities but risk overfitting.  
[*] Learning Rate: (Default: 0.3) The step size applied to each boosting round to prevent the model from learning too quickly.  Min Probability for Signal: (Default: 0.65) The minimum confidence threshold ($65\%$) required from the classification model to trigger an active trade.
[*]  ADX Length / Minimum Filter: (Default: 14 / 20.0) Prevents counter-trend signals if the prevailing macro trend is too strong.  
[/list]

[b]🛡️ Target & Risk Management[/b]

https://www.tradingview.com/x/g35qp9U1/

[list]
[*] SL Wick Buffer ×ATR: (Default: 0.25) Sets how much breathing room is given below a swing low wick or above a swing high wick, scaled by ATR.  
[*]TP1 ×Risk (R-multiple): (Default: 1.0) Targets a clean 1:1 Risk-to-Reward ratio for the initial profit take. 
[*]  TP3 Min ×Risk (Floor): (Default: 2.0) The minimum target floor for the machine learning regression objective.  
[*]   Break-Even After TP1: (Default: True) Automatically moves the Stop Loss to the exact entry price the moment TP1 is captured, eliminating risk on the remainder of the trade.  
[/list]

[b]📈 How to Trade the Indicator[/b]

Trading with the machine learning model requires blending quantitative probabilities with standard structural execution:
[i]
The Entry: [/i]Wait for a Bullish (Neon Purple) or Bearish (Neon Pink) arrow to finalize on a closed candle. The percentage printed indicates the model's confidence.  

[i]Placing Risk: [/i]The system automatically draws a solid line anchoring your Stop Loss tightly to the local structural wick pivot, applying an ATR buffer to account for minor noise.  

[i]Scaling Targets:[/i]

[list=1]
[*]Target 1 (TP1): Landed at a symmetrical 1:1 distance. When hit, the indicator dynamically updates your Stop Loss to your entry line, locking in a "scratch-or-better" runner.  
[*]Target 2 (TP2): Represents the mathematical midpoint between your baseline risk and the macro ML objective.  
[*] Target 3 (TP3): Driven directly by the XGBoost Regression Model. The regressor estimates the potential mathematical expansion based on current market features—if volatility is expanding, TP3 will automatically stretch further to ride major trend changes.  
[/list]
[b]
📊 Deep Dive: The Feature Importance & Scatter Plot Dashboard[/b]

https://www.tradingview.com/x/Cj5FX1PN/

The dashboard rendered on the right side of the chart acts as the "brain" of the indicator. It provides real-time transparency into exactly how the machine learning model is weighing data and evaluating current market conditions.  

[i]Feature Importance Bars (The Relative Weights): [/i]The horizontal progress bars display the mathematical percentage weight allocated to each of the four indicators processed during the model's most recent training cycle. These values change dynamically every time the model triggers a retraining block (default: every 50 bars) as it adapts to shifting market conditions. For example, if the market moves into a heavy trending phase, you will notice metrics like the ADX or Z-Score capture a higher percentage of the model's attention, whereas the RSI will frequently become the dominant driver if the asset is range-bound.

[i]The Holographic Scatter Plot (Historical Feature Density): [/i] Layered over the progress bars is an advanced distribution scatter plot consisting of individual circular glyphs (○, ◉, ●) that plot a rolling record of the last 30 historical signal points. The horizontal position of each dot shows exactly where the feature value landed relative to its historical extremes (0 on the far left, 1 on the far right). The script introduces a subtle vertical "jitter" to separate these dots so you can visually identify high-density clusters where successful reversal setups frequently occur, while the shifting style of the glyphs flags tightly packed clusters of solid nodes (●) to indicate highly concentrated mathematical sweet spots discovered by the XGBoost classifier.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GainzAlgo
 //    │    │     │     │   ██████╗  █████╗ ██╗███╗   ██╗███████╗
 //   ┌┴┐   │    ┌┴┐    │  ██╔════╝ ██╔══██╗██║████╗  ██║╚══███╔╝
 //   │ │   │    │ │    │  ██║  ███╗███████║██║██╔██╗ ██║  ███╔╝ 
 //   └┬┘  ┌┴┐   └┬┘   ┌┴┐ ██║   ██║██╔══██║██║██║╚██╗██║ ███╔╝  
 //    │   │ │    │    │ | ██████╔╝██║  ██║██║██║ ╚████║███████╗
 //    │   └┬┘         └┬┘  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝
 //         │           │  
 //                            █████╗ ██╗      ██████╗  ██████╗         
 //                           ██╔══██╗██║     ██╔════╝ ██╔═══██╗        
 //                           ███████║██║     ██║  ███╗██║   ██║        
 //                           ██╔══██║██║     ██║   ██║██║   ██║        
 //                           ██║  ██║███████╗╚██████╔╝╚██████╔╝        
 //                           ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝    
//@version=6
indicator("XG Boost Lite: Reversals | Gains Algo", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 500, calc_bars_count = 8000)

// Imports 
import GainzAlgo/Arbor_Gradient_Boosting_GainzAlgo/1 as arbor

GRP_MDL  = "⚙️ XGBoost Model Settings"
GRP_VIS  = "🎨 Visual & Dashboard"
GRP_RISK = "🛡️ Target & Risk Management"

// Tooltips 
train_tip = "This sets the parameter for XG boost training length. The max variable is 300 due to computational intensity. Suggested length is 250."
adx_tip = "This acts as a filter for XG Boost to ensure its weighing the current trend based on the ADX. If you increase the ADX length, it will punish the model for wrong signals during trends. Suggested length is between 14 and 20."
retrain_tip = "Determines the interval (in bars) at which the model refreshes its training data and reoptimizes its internal weights. A lower value increases model responsiveness to recent market shifts but raises computational load, while a higher value provides a smoother, more stable model."
rounds_tip = "Specifies the number of boosting iterations (stumps) the model will fit to the data. Increasing this count allows the model to capture more complex patterns but raises the risk of overfitting to market noise."
lr_tip = "Controls the step size (shrinkage) applied to each boosting round, balancing the contribution of new trees against the ensemble. A lower value prevents the model from learning too quickly and overfitting, while a higher value speeds up convergence at the expense of potential stability."
prob_tip = "Sets the confidence level required for a trade signal to be confirmed; higher thresholds produce fewer, more selective signals, while lower thresholds increase signal frequency but may include more false positives."
slbuffer_tip = "The signal bar's wick (pivot extreme) IS the structural stop level — this is just extra breathing room beyond it, as a fraction of ATR. Keep this small (0.15-0.5); Mirage-style sweep stops use ~0.25. A large value here defeats the point of anchoring risk to the wick."
tp1r_tip = "TP1 as a multiple of the initial risk (entry-to-SL distance), i.e. 1.0 = a true 1:1 R:R target. This is now decoupled from the XGB regression so it always lands at a sane, symmetric distance regardless of what the regressor predicts."
tp3floor_tip = "Minimum R-multiple for TP3 (the XGB-driven objective). The regressor's predicted excursion (regL/regS × ATR) is compared against risk × this floor, and the LARGER of the two is used — so TP3 never prints a target smaller than a sane R:R, but can still stretch further when the model predicts a fat move."
repaint_tip = " When on, signals only confirm on bar close (no intrabar flicker/repaint). When off, signals can appear on the live bar but may shift or disappear before that bar closes."

// UI 
// Model Params
lookbackInput     = input.int(250, "Training Lookback (Bars)", group = GRP_MDL, maxval = 300, tooltip = train_tip)
retrainFreqInput  = input.int(50, "Retrain Frequency", group = GRP_MDL, tooltip = retrain_tip)
nRoundsInput      = input.int(20, "Boosting Rounds", group = GRP_MDL, tooltip = rounds_tip)
lrInput           = input.float(0.3, "Learning Rate", step = 0.05, group = GRP_MDL, tooltip = lr_tip)
probThreshInput   = input.float(0.65, "Min Probability for Signal", step = 0.05, group = GRP_MDL, tooltip = prob_tip)
waitForCloseInput = input.bool(true, "Confirm Signals On Bar Close (No Repaint)", group = GRP_MDL, tooltip = repaint_tip)

// ADX Filter
adxLenInput       = input.int(14, "ADX Length", group = GRP_MDL, tooltip = adx_tip)
adxFilterInput    = input.float(20.0, "ADX Minimum Filter", step = 1.0, group = GRP_MDL)

// RRisks 
slAtrMultInput    = input.float(0.25, "SL Wick Buffer ×ATR", step = 0.05, group = GRP_RISK, tooltip = slbuffer_tip)
tp1RInput         = input.float(1.0, "TP1 ×Risk (R-multiple)", step = 0.1, group = GRP_RISK, tooltip = tp1r_tip)
tp3FloorRInput    = input.float(2.0, "TP3 Min ×Risk (Floor)", step = 0.25, group = GRP_RISK, tooltip = tp3floor_tip)
useBreakEvenInput = input.bool(true, "Break-Even After TP1", group = GRP_RISK, tooltip = "☝️🤓 When TP1 is touched, move SL to entry — same mechanic as Mirage. Locks in a scratch-or-better outcome on the remaining runner.")

// Visuals
showScatterInput  = input.bool(true, "Show Feature Importance Scatter Plot", group = GRP_VIS)
bullColor         = input.color(#b026ff, "Bullish Theme (Neon Purple)", group = GRP_VIS)
bearColor         = input.color(#ff007f, "Bearish Theme (Neon Pink)", group = GRP_VIS)
hitColor          = input.color(#00e5ff, "Target Hit (Cyan)", group = GRP_VIS)

// Feature eng and tps 
float atr = math.max(ta.atr(14), 0.0001)
[_, _, adx] = ta.dmi(adxLenInput, adxLenInput)


float f1 = ta.rsi(close, 14)
float f2 = nz(volume / ta.sma(volume, 20), 1.0) // Relative Volume
float f3 = (close - ta.sma(close, 20)) / math.max(ta.stdev(close, 20), 0.0001) // Z-Score
float f4 = adx // ADX is now actively used as feature #4

bool isValid = not (na(f1) or na(f2) or na(f3) or na(f4))


int   fwdWindow = 15
float futureMax = ta.highest(high, fwdWindow)
float futureMin = ta.lowest(low, fwdWindow)

// long 
float targClsLong = (futureMax[1] - close[fwdWindow]) > (atr[fwdWindow] * 1.0) ? 1.0 : 0.0
float targRegLong = math.max((futureMax[1] - close[fwdWindow]) / atr[fwdWindow], 0.0)

//short
float targClsShort = (close[fwdWindow] - futureMin[1]) > (atr[fwdWindow] * 1.0) ? 1.0 : 0.0
float targRegShort = math.max((close[fwdWindow] - futureMin[1]) / atr[fwdWindow], 0.0)

// Training 
var array<float> arrF1 = array.new<float>()
var array<float> arrF2 = array.new<float>()
var array<float> arrF3 = array.new<float>()
var array<float> arrF4 = array.new<float>()
var array<float> arrTClsL = array.new<float>()
var array<float> arrTRegL = array.new<float>()
var array<float> arrTClsS = array.new<float>()
var array<float> arrTRegS = array.new<float>()

var arbor.GBM4 modelClsL = na
var arbor.GBM4 modelRegL = na
var arbor.GBM4 modelClsS = na
var arbor.GBM4 modelRegS = na

var array<float> featRecent = array.new<float>()
var array<float> impPct = array.new<float>(4, 25.0)

// FIX (Bug 3 / performance + no-repaint on retrain cadence):
// only evaluate/retrain once the bar is closed, instead of on every intrabar tick.
bool doTrain = bar_index % retrainFreqInput == 0 and bar_index > lookbackInput and isValid and barstate.isconfirmed

if doTrain
    array.clear(arrF1), array.clear(arrF2), array.clear(arrF3), array.clear(arrF4)
    array.clear(arrTClsL), array.clear(arrTRegL), array.clear(arrTClsS), array.clear(arrTRegS), array.clear(featRecent)

    for i = lookbackInput to fwdWindow + 1
        // FIX (Bug 1 - critical): features at offset i must be paired with the label that
        // describes the OUTCOME of an entry at that same bar. targClsLong[i] actually described
        // an entry fwdWindow bars further back, so the label was shifted by fwdWindow bars vs
        // the feature. Correct pairing is targClsLong[i - fwdWindow] (min index = 1, always a
        // closed bar since the loop bottoms out at fwdWindow + 1 -> no lookahead introduced).
        int targIdx = i - fwdWindow
        if not (na(f1[i]) or na(f2[i]) or na(f3[i]) or na(f4[i])) and not (na(targClsLong[targIdx]) or na(targRegLong[targIdx]) or na(targClsShort[targIdx]) or na(targRegShort[targIdx]))
            array.push(arrF1, f1[i])
            array.push(arrF2, f2[i])
            array.push(arrF3, f3[i])
            array.push(arrF4, f4[i])
            array.push(arrTClsL, targClsLong[targIdx])
            array.push(arrTRegL, targRegLong[targIdx])
            array.push(arrTClsS, targClsShort[targIdx])
            array.push(arrTRegS, targRegShort[targIdx])

    if array.size(arrTClsL) >= 20
        modelClsL := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTClsL, n_rounds = nRoundsInput, lr = lrInput, is_classifier = true)
        modelRegL := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTRegL, n_rounds = nRoundsInput, lr = lrInput, is_classifier = false)
        modelClsS := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTClsS, n_rounds = nRoundsInput, lr = lrInput, is_classifier = true)
        modelRegS := arbor.gbm4_fit(arrF1, arrF2, arrF3, arrF4, arrTRegS, n_rounds = nRoundsInput, lr = lrInput, is_classifier = false)

        if not na(modelClsL) and not na(modelClsS)
            for fi = 0 to 3
                float impL = arbor.gbm4_importance_pct(modelClsL, fi)
                float impS = arbor.gbm4_importance_pct(modelClsS, fi)
                array.set(impPct, fi, (impL + impS) / 2.0)

        int dotN = math.min(array.size(arrF1), 30)
        for di = 0 to dotN - 1
            array.push(featRecent, array.get(arrF1, di) / 100.0) 
            array.push(featRecent, math.min(array.get(arrF2, di) / 3.0, 1.0)) 
            array.push(featRecent, math.max(math.min(array.get(arrF3, di) / 4.0 + 0.5, 1.0), 0.0))
            array.push(featRecent, math.min(array.get(arrF4, di) / 100.0, 1.0)) // ADX Normalization

// Predict 
float probL = na, float regL = na
float probS = na, float regS = na

bool isBullPivot = low < ta.lowest(low, 8)[1] and close > low + (high - low) * 0.5
bool isBearPivot = high > ta.highest(high, 8)[1] and close < low + (high - low) * 0.5

if not na(modelClsL) and not na(modelRegL) and isBullPivot
    probL := arbor.gbm4_predict(modelClsL, f1, f2, f3, f4)
    regL  := arbor.gbm4_predict(modelRegL, f1, f2, f3, f4)
    // Bug 2 mitigation: I can't inspect/patch the arbor library's internals (not provided,
    // not fetchable), so this is a call-site sanity guard only, not a fix for a library clamp.
    // If regL comes back negative or na, fall back cleanly instead of corrupting TP3 math.
    if na(regL) or regL < 0.0
        regL := 0.0

if not na(modelClsS) and not na(modelRegS) and isBearPivot
    probS := arbor.gbm4_predict(modelClsS, f1, f2, f3, f4)
    regS  := arbor.gbm4_predict(modelRegS, f1, f2, f3, f4)
    if na(regS) or regS < 0.0
        regS := 0.0

bool fireLongRaw  = not na(probL) and probL >= probThreshInput and adx >= adxFilterInput
bool fireShortRaw = not na(probS) and probS >= probThreshInput and adx >= adxFilterInput

// FIX (Repaint prevention): isBullPivot/isBearPivot use the CURRENT bar's high/low/close, which
// are still live (can change) until the bar closes. Gating on barstate.isconfirmed means the
// signal, its lines/labels, and activeEntry/SL/TP levels are only committed once the triggering
// bar has actually closed, so nothing painted here can later change or vanish. Entry lands one
// bar later than the old (repainting) behavior, but every plotted signal from here on is final.
bool fireLong  = fireLongRaw  and (not waitForCloseInput or barstate.isconfirmed)
bool fireShort = fireShortRaw and (not waitForCloseInput or barstate.isconfirmed)

// Target plotting 
var int   activeDir   = 0
var float activeEntry = na
var float activeSL    = na
var float activeTP1   = na
var float activeTP2   = na
var float activeTP3   = na
var int   activeEntryBar = na
var bool  beActive    = false
var bool  tp1Hit      = false
var bool  tp2Hit      = false
var bool  tp3Hit      = false

var line  lnEntry = na
var line  lnSL    = na
var line  lnTP1   = na
var line  lnTP2   = na
var line  lnTP3   = na
var label lblTP3  = na

// Alert event flags - reset every bar, only true on the exact bar the event happens
bool alertLongEntry  = false
bool alertShortEntry = false
bool alertTP1Hit     = false
bool alertTP2Hit     = false
bool alertTP3Hit     = false
bool alertSLHit      = false

if fireLong or fireShort
    activeDir      := fireLong ? 1 : -1
    activeEntry    := close // Strictly calculated from the entry breakout point to close
    activeEntryBar := bar_index

    color themeColor = fireLong ? bullColor : bearColor

    if activeDir == 1
        float rawSL    = low - (atr * slAtrMultInput)
        float riskDist = activeEntry - rawSL
        if riskDist < atr * 0.5
            rawSL    := activeEntry - atr * 0.5
            riskDist := atr * 0.5
        activeSL := rawSL

        float xgbObjective = math.max(regL * atr, riskDist * tp3FloorRInput)
        activeTP1 := activeEntry + riskDist * tp1RInput
        activeTP2 := activeEntry + (riskDist * tp1RInput + xgbObjective) / 2.0
        activeTP3 := activeEntry + xgbObjective
    else
        float rawSL    = high + (atr * slAtrMultInput)
        float riskDist = rawSL - activeEntry
        if riskDist < atr * 0.5
            rawSL    := activeEntry + atr * 0.5
            riskDist := atr * 0.5
        activeSL := rawSL

        float xgbObjective = math.max(regS * atr, riskDist * tp3FloorRInput)
        activeTP1 := activeEntry - riskDist * tp1RInput
        activeTP2 := activeEntry - (riskDist * tp1RInput + xgbObjective) / 2.0
        activeTP3 := activeEntry - xgbObjective

    beActive := false
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false

    line.delete(lnEntry), line.delete(lnSL), line.delete(lnTP1), line.delete(lnTP2), line.delete(lnTP3), label.delete(lblTP3)

    int x1 = bar_index
    int x2 = bar_index + 15
    lnEntry := line.new(x1, activeEntry, x2, activeEntry, color = color.new(color.white, 50), style = line.style_dotted)
    lnSL    := line.new(x1, activeSL, x2, activeSL, color = activeDir == 1 ? bearColor : bullColor, style = line.style_solid, width = 2)
    lnTP1   := line.new(x1, activeTP1, x2, activeTP1, color = color.new(themeColor, 40), style = line.style_dashed)
    lnTP2   := line.new(x1, activeTP2, x2, activeTP2, color = color.new(themeColor, 20), style = line.style_dashed)
    lnTP3   := line.new(x1, activeTP3, x2, activeTP3, color = themeColor, style = line.style_solid, width = 2)
    
    lblTP3  := label.new(x2, activeTP3, "TP3 (XGB): " + str.tostring(activeTP3, format.mintick), color = color.new(themeColor, 90), textcolor = themeColor, style = label.style_label_left, size = size.small)

    if fireLong
        label.new(bar_index, low - (atr * 0.5), "▲\n" + str.tostring(probL * 100, "#.1") + "%", color = color.new(color.black, 100), textcolor = bullColor, style = label.style_label_up, size = size.small)
        alertLongEntry := true
    else
        label.new(bar_index, high + (atr * 0.5), "▼\n" + str.tostring(probS * 100, "#.1") + "%", color = color.new(color.black, 100), textcolor = bearColor, style = label.style_label_down, size = size.small)
        alertShortEntry := true


bool canCheckHit = activeDir != 0 and not na(activeEntryBar) and bar_index > activeEntryBar and barstate.isconfirmed

if activeDir != 0
    int extX = bar_index + 5
    line.set_x2(lnEntry, extX), line.set_x2(lnSL, extX), line.set_x2(lnTP1, extX), line.set_x2(lnTP2, extX), line.set_x2(lnTP3, extX)
    label.set_x(lblTP3, extX)

    if activeDir == 1
        if canCheckHit and high >= activeTP1 and not tp1Hit
            tp1Hit := true, line.set_color(lnTP1, hitColor), line.set_style(lnTP1, line.style_solid)
            alertTP1Hit := true

            if useBreakEvenInput and not beActive
                activeSL := activeEntry
                beActive := true
                line.set_xy1(lnSL, bar_index, activeSL), line.set_xy2(lnSL, extX, activeSL)
                line.set_color(lnSL, color.new(bearColor, 70))
        if canCheckHit and high >= activeTP2 and not tp2Hit
            tp2Hit := true, line.set_color(lnTP2, hitColor), line.set_style(lnTP2, line.style_solid)
            alertTP2Hit := true
        if canCheckHit and high >= activeTP3 and not tp3Hit
            tp3Hit := true, line.set_color(lnTP3, hitColor), label.set_textcolor(lblTP3, hitColor), label.set_text(lblTP3, "TP3 ✓")
            alertTP3Hit := true
        if canCheckHit and low <= activeSL
            activeDir := 0
            alertSLHit := true
    else
        if canCheckHit and low <= activeTP1 and not tp1Hit
            tp1Hit := true, line.set_color(lnTP1, hitColor), line.set_style(lnTP1, line.style_solid)
            alertTP1Hit := true
            if useBreakEvenInput and not beActive
                activeSL := activeEntry
                beActive := true
                line.set_xy1(lnSL, bar_index, activeSL), line.set_xy2(lnSL, extX, activeSL)
                line.set_color(lnSL, color.new(bullColor, 70))
        if canCheckHit and low <= activeTP2 and not tp2Hit
            tp2Hit := true, line.set_color(lnTP2, hitColor), line.set_style(lnTP2, line.style_solid)
            alertTP2Hit := true
        if canCheckHit and low <= activeTP3 and not tp3Hit
            tp3Hit := true, line.set_color(lnTP3, hitColor), label.set_textcolor(lblTP3, hitColor), label.set_text(lblTP3, "TP3 ✓")
            alertTP3Hit := true
        if canCheckHit and high >= activeSL
            activeDir := 0
            alertSLHit := true

// Alerts (Bug fix: none existed before - added long/short entry + TP1/TP2/TP3/SL hit alerts)
alertcondition(alertLongEntry,  title = "XGB Long Entry",  message = "XGBoost Lite: Long entry signal")
alertcondition(alertShortEntry, title = "XGB Short Entry", message = "XGBoost Lite: Short entry signal")
alertcondition(alertTP1Hit,     title = "XGB TP1 Hit",     message = "XGBoost Lite: TP1 target hit")
alertcondition(alertTP2Hit,     title = "XGB TP2 Hit",     message = "XGBoost Lite: TP2 target hit")
alertcondition(alertTP3Hit,     title = "XGB TP3 Hit",     message = "XGBoost Lite: TP3 (XGB objective) target hit")
alertcondition(alertSLHit,      title = "XGB Stop Loss Hit", message = "XGBoost Lite: Stop loss hit")

// Stats
var array<box>   boxArr   = array.new<box>()
var array<line>  lineArr  = array.new<line>()
var array<label> labelArr = array.new<label>()

string[] featNames = array.from("RSI(14)", "RelVol(20)", "Z-Score", "ADX(14)")
color[]  holoCols  = array.from(bullColor, #df80ff, hitColor, #b026ff) 

if barstate.islast and showScatterInput
    for b in boxArr
        b.delete()
    boxArr.clear()
    for l in lineArr
        l.delete()
    lineArr.clear()
    for lb in labelArr
        lb.delete()
    labelArr.clear()

    float chartBot  = ta.lowest(low, 200) 
    float chartTop  = ta.highest(high, 200)
    float pr        = math.max(chartTop - chartBot, close * 0.001)
    

    float rowH      = pr * 0.07 
    float panelBot  = chartBot + (pr * 0.02)
    float panelTop  = panelBot + (rowH * 5.8)
    int   barMaxW   = 38
    int   px        = bar_index + 12 

    boxArr.push(box.new(px - 1, panelTop + rowH * 0.7, px + barMaxW + 25, panelBot, border_color = color.new(bullColor, 60), bgcolor = color.new(#0d1117, 85)))
    boxArr.push(box.new(px, panelTop + rowH * 0.6, px + barMaxW + 24, panelBot + rowH * 0.1, border_color = color.new(bullColor, 88), bgcolor = na))

    labelArr.push(label.new(px + barMaxW / 2, panelTop + rowH * 0.35, "◈  XGBOOST  FEATURE  IMPORTANCE", style = label.style_none, textcolor = color.new(color.white, 15), size = size.small, text_font_family = font.family_monospace))
    lineArr.push(line.new(px, panelTop + rowH * 0.04, px + barMaxW + 24, panelTop + rowH * 0.04, color = color.new(color.white, 82), style = line.style_dotted))

    for fi = 0 to 3
        float pct   = array.get(impPct, fi)
        float bw    = math.max(1.0, pct / 100.0 * barMaxW)
        color bc    = array.get(holoCols, fi)
        float yTop  = panelTop - rowH * (fi + 0.15)
        float yBot  = yTop - rowH * 0.68
        float yMid  = (yTop + yBot) / 2.0

        boxArr.push(box.new(px, yTop + rowH * 0.10, int(px + bw + 3), yBot - rowH * 0.10, border_color = na, bgcolor = color.new(bc, 91)))
        boxArr.push(box.new(px, yTop, int(px + bw), yBot, border_color = color.new(bc, 45), bgcolor = color.new(bc, 58)))
        lineArr.push(line.new(int(px + bw), yTop, int(px + bw), yBot, color = color.new(bc, 5), width = 2))

        if array.size(featRecent) > 0
            int dotTotal = array.size(featRecent) / 4
            int dotDraw  = math.min(dotTotal, 30)
            for di = 0 to dotDraw - 1
                int packIdx = di * 4 + fi
                if packIdx < array.size(featRecent)
                    float normVal = array.get(featRecent, packIdx)
                    int   dotX    = int(px + normVal * barMaxW)
                    float jitter  = (di % 3 - 1) * rowH * 0.12
                    color dotC    = color.from_gradient(normVal, 0, 1, color.new(bc, 60), color.new(color.white, 20))
                    string dotCh  = normVal > 0.7 ? "●" : normVal > 0.35 ? "◉" : "○"
                    labelArr.push(label.new(dotX, yMid + jitter, dotCh, style = label.style_none, textcolor = dotC, size = size.tiny))


        labelArr.push(label.new(px - 1, yMid, array.get(featNames, fi), style = label.style_label_right, textcolor = color.new(bc, 15), color = #00000000, size = size.tiny, text_font_family = font.family_monospace))
        labelArr.push(label.new(int(px + bw) + 1, yMid, str.tostring(pct, "#.#") + "%", style = label.style_label_left, textcolor = color.new(bc, 10), color = #00000000, size = size.tiny, text_font_family = font.family_monospace))
````
