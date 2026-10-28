# Divergences - Elliott Wave Filtered

- url: https://www.tradingview.com/script/jCQyPKWy-Divergences-Elliott-Wave-Filtered/
- type: indicator
- pine_id: PUB;23c698bf380b4f0c84a8004e34348415
- version: 2.0

## Description

[b]Divergences — Elliott Wave Filtered[/b]
[i]A multi-oscillator divergence detection system that filters signals through a three-degree Elliott Wave engine and Bayesian probability fusion. Distinguishes between Regular divergences (reversal signals at wave ends) and Hidden divergences (continuation signals during corrections) using wave position scoring, Hurst regime analysis, and statistical quality metrics.[/i]
[b]What It Does[/b]
This indicator scans for price-oscillator divergences across four technical indicators (RSI, Stochastic RSI, MFI, ROC) and validates them against real-time Elliott Wave structure. Unlike standard divergence indicators that fire indiscriminately, this system employs a [b]wave-context gate[/b] — divergences only trigger if they align with specific wave positions (e.g., W5 endings for reversals, W2/W4 depths for continuations) across Small, Medium, and Large degrees.
[list]
[*][b]Regular Divergences[/b] (Reversal): Price makes higher high / lower low while oscillator makes lower high / higher low. Filtered for W5, Diagonal, Corrective C, Triangle E, and W4/W2 endings where trend exhaustion is probable.
[*][b]Hidden Divergences[/b] (Continuation): Price makes higher low / lower high while oscillator makes lower low / higher high. Filtered for W2, W4, and Corrective C positions where trend resumption is probable.
[/list]
[b]The Six Analytical Pillars[/b]
[list]
[*][b]Multi-Oscillator Concordance[/b]: Requires minimum 2-of-4 oscillators (RSI, Stoch RSI, MFI, ROC) to simultaneously register divergence, eliminating single-indicator false positives.
[*][b]Tri-Degree Wave Engine[/b]: Runs independent swing detection on Small (micro), Medium (minor), and Large (primary) degrees to determine if the divergence occurs at a significant wave node.
[*][b]Wave Position Scoring[/b]: Assigns base probabilities (0.0–1.0) to wave positions — W5 (0.92), Diagonal (0.88), W2 (0.38), W4 (0.42), etc. — with separate score tables for Regular vs Hidden divergence contexts.
[*][b]Cross-Degree Modifiers[/b]: Boosts probability when multiple degrees agree (e.g., Small=W5 + Medium=W5) or penalizes when they conflict (e.g., Small=W5 + Medium=W3).
[*][b]Regime Detection[/b]: Integrates Hurst Exponent (mean-reversion vs persistence) and Shannon Entropy (market disorder) to weight divergence reliability — low Hurst (<0.5) favors reversal divergences, high entropy reduces signal confidence.
[*][b]Bayesian Fusion[/b]: Combines concordance, z-score magnitude, wave context, trend agreement, and over-extension ratios through log-odds transformation to produce a final 0.0–1.0 probability score.
[/list]
[b]Key Features[/b]
[list]
[*][b]Wave Type Filtering[/b]: Independent toggle sets for Regular vs Hidden divergences — e.g., allow W5+Diagonal+Triangle E for reversals, but only W2+W4+Corr C for continuations.
[*][b]Slope Non-Intersection[/b]: Optional validation ensuring price does not cross the linear slope between P1 and P2 pivots (clean divergence requirement).
[*][b]Dynamic Target Projection[/b]: Upon valid divergence, projects Fibonacci extension targets (61.8%, 100%, 161.8%) from the swing leg and plots invalidation levels (pivot ± ticks).
[*][b]Degree Proximity Scaling[/b]: Small degree waves must be within 12 bars of divergence, Medium within 24 bars, Large within 48 bars — ensuring temporal relevance.
[*][b]Quality Gradient[/b]: Impulse and Diagonal patterns receive quality scores (0.0–1.0) based on momentum, channel alignment, and alternation, scaling the base wave position probability.
[*][b]Trend Agreement Check[/b]: Validates that divergence direction opposes (Regular) or aligns with (Hidden) the detected wave trend direction across degrees.
[/list]
[b]Inputs & Parameters[/b]
[i]Divergence Detection[/i]
[list]
[*]Pivot Left/Right Bars: Confirmation delay and lookback for pivot detection (default 3/1).
[*]Min/Max Bars P1→P2: Time window constraints for valid divergence legs (default 5–unlimited).
[*]Cooldown Bars: Minimum spacing between same-direction signals to prevent clustering (default 8).
[*]Require Slope Non-Intersection: Toggle strict linear slope validation.
[/list]
[i]Wave Filter — Regular vs Hidden[/i]
[list]
[*]Enable wave filter: Master toggle for each divergence type.
[*]Degree to check: Any, Small, Medium, Large, or All Degrees (consensus requirement).
[*]Allowed wave positions: Independent toggles for W5, Diagonal, W3, W2, W4, Corr C, Triangle E, and No Context.
[/list]
[i]Multi-Oscillator Concordance[/i]
[list]
[*]Individual length settings for RSI (33), Stoch RSI (33, %K 6), MFI (33), ROC (33).
[*]Min concordance: Required number of oscillators showing divergence (default 2 of 4).
[*]OB/OS Zones: Overbought/oversold thresholds for RSI (70/30), Stoch (80/20), MFI (80/20).
[/list]
[i]Statistical Quality & Bayesian Weights[/i]
[list]
[*]Z-score threshold: RSI deviation sensitivity (default 1.5).
[*]Hurst lookback/entropy bins: Regime calculation windows.
[*]Fusion weights: Concordance (0.28), Z-score (0.12), Hurst (0.12), Entropy (0.08), Wave context (0.25), Over-extension (0.08), Trend agreement (0.07).
[*]Prior log-odds: Base bias adjustment (−3 to +3).
[*]Min Score: Probability threshold for signal emission (default 0.85).
[/list]
[i]Wave Engine (Three Degrees)[/i]
[list]
[*]Small: Left 3–30, Right 1–3, Min swing 0.08%.
[*]Medium: Left 10–80, Right 1–5, Min swing 0.20%.
[*]Large: Left 25–200, Right 2–10, Min swing 0.50%.
[*]Wave-div proximity: 12 bars (Small), scaled 2×/4× for Medium/Large.
[/list]
[b]How to Read It[/b]
[list]
[*][b]Divergence Labels:[/b]
[list]
[*][b]R↑[/b] (Green): Regular Bullish divergence — price lower low, oscillator higher low. Expect reversal up.
[*][b]R↓[/b] (Red): Regular Bearish divergence — price higher high, oscillator lower high. Expect reversal down.
[*][b]H↑[/b] (Teal): Hidden Bullish divergence — price higher low, oscillator lower low. Expect continuation up.
[*][b]H↓[/b] (Orange): Hidden Bearish divergence — price lower high, oscillator higher high. Expect continuation down.
[/list]
[*][b]Label Annotations:[/b] Format "Type Concordance/Total Score% WavePos" — e.g., "R↑ 3/4 92% W5/mW5" indicates 3 of 4 oscillators agree, 92% Bayesian probability, Small=W5, Medium=W5.
[*][b]Dotted Lines:[/b] Connect P1 (previous pivot) to P2 (current pivot) showing the divergence slope.
[*][b]Target Lines:[/b] Horizontal dashed lines at T1 (61.8%), T2 (100%), T3 (161.8%) projected from the divergence leg.
[*][b]Invalidation Line:[/b] Solid grey line at the pivot price ± tick buffer — crossing this invalidates the divergence setup.
[*][b]Dashboard (Top-Right):[/b] Displays current Hurst (green <0.5 mean-reverting, red >0.5 trending), Entropy (high = disorder), and detected wave positions for S/M/L degrees.
[/list]
[b]Signal Logic & Validation[/b]
[list]
[*][b]Base Conditions:[/b] Price pivot confirmed, oscillator divergence detected, concordance ≥ minimum, within P1–P2 time window, cooldown satisfied.
[*][b]Wave Filter Gate:[/b] Divergence bar must be within proximity window of a classified wave end (W5, Diag, W2, W4, etc.) on the specified degree(s).
[*][b]Bayesian Calculation:[/b] Each component (concordance, z-score, Hurst, entropy, wave context, over-extension, trend) is converted to log-odds, weighted, summed with prior, and transformed back to probability.
[*][b]Emission Threshold:[/b] Final probability must exceed Min Score (default 85%) to plot signal.
[*][b]Over-Extension Ratio:[/b] Measures leg length vs previous similar leg — ratios >2.0 increase reversal probability (exhaustion signature).
[/list]
[b]Important Notes[/b]
[list]
[*][b]Wave Position Scoring:[/b] Regular and Hidden divergences use inverted score tables. W5 scores 0.92 for Regular (strong reversal) but only 0.15 for Hidden (weak continuation). Conversely, W2 scores 0.38 for Regular but 0.90 for Hidden.
[*][b]Cross-Degree Conflict:[/b] When degrees disagree (e.g., Small=W5 bullish, Medium=W3 bullish continuation), the system applies conflict penalties (−0.20 to −0.28) to the composite score, often suppressing the signal unless other factors compensate.
[*][b]Hurst Interpretation:[/b] Hurst < 0.5 (mean-reversion regime) adds probability to Regular divergences (reversal expected) and reduces Hidden divergence scores. Hurst > 0.5 (trending) does the opposite.
[*][b]Entropy Impact:[/b] High entropy (>0.7) indicates chaotic, non-cyclical market conditions — the system reduces confidence in all divergences during high entropy regimes.
[*][b]Non-Intersection Validation:[/b] When enabled, the system checks that no intermediate bar crosses the linear interpolation between P1 and P2 pivots, ensuring "clean" divergence without whipsaw noise.
[*][b]Quality Scaling:[/b] Impulse patterns are scored on momentum (W3 strength), channel parallelism, and alternation (W2 vs W4 slope difference). Higher quality waves boost the base position score by up to 30%.
[*][b]No Repainting:[/b] Uses confirmed pivots (right bars ≥ 1) and historical bar indexing. Once a divergence is plotted at P2 confirmation bar, it remains fixed.
[/list]
[b]Mathematical Summary[/b]
[i]Wave Position Base Scores (Regular)[/i]
W5 = 0.92, Diagonal = 0.88, Corr C = 0.65, Tri E = 0.60,
W4 = 0.42, W2 = 0.38, Neutral = 0.50, W3 = 0.12
[i]Wave Position Base Scores (Hidden)[/i]
W2 = 0.90, W4 = 0.88, Corr C = 0.70, Neutral = 0.50,
W5 = 0.15, W3 = 0.35
[i]Cross-Degree Modifiers[/i]
Triple Agreement = +0.20 (Tri Boost)
Dual Agreement = +0.15 (Agree Boost)
Single High vs Others Low = -0.20 to -0.28 (Conflict Penalty)
[i]Bayesian Fusion[/i]
L = PriorLO + Σ(Weight_i × log(p_i / (1 - p_i)))
Posterior = 1 / (1 + exp(-L))
[i]Impulse Quality[/i]
Quality = (Momentum × 0.35) + (Channel × 0.35) + (Alternation × 0.30)
FinalWaveScore = BaseScore + (BaseScore - 0.5) × Quality × 0.3

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22


//@version=5
indicator("Divergences - Elliott Wave Filtered",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_boxes_count  = 200,
     precision        = 5)

// ============================================================================
// ================================ CONSTANTS =================================
// ============================================================================

var int PH =  1
var int PL = -1

var int DIV_REG_BULL  = 1
var int DIV_REG_BEAR  = 2
var int DIV_HID_BULL  = 3
var int DIV_HID_BEAR  = 4

// Wave position base scores — REGULAR divergences (reversal)
var float WPC_W5       = 0.92
var float WPC_DIAG     = 0.88
var float WPC_CORR_C   = 0.65
var float WPC_TRI_E    = 0.60
var float WPC_W4       = 0.42
var float WPC_W2       = 0.38
var float WPC_NEUTRAL  = 0.50
var float WPC_W3       = 0.12

// Wave position base scores — HIDDEN divergences (continuation)
var float WPCH_W2      = 0.90
var float WPCH_W4      = 0.88
var float WPCH_CORR_C  = 0.70
var float WPCH_NEUTRAL = 0.50
var float WPCH_W5      = 0.15
var float WPCH_W3      = 0.35

// Cross-degree modifiers
var float XDEG_AGREE_BOOST   =  0.15
var float XDEG_TRI_BOOST     =  0.20
var float XDEG_CONFLICT_PEN  = -0.20
var float XDEG_TRI_CONFLICT  = -0.28

// ============================================================================
// ============================== USER INPUTS =================================
// ============================================================================

string GD = "Divergence Detection"
int   pivLB   = input.int(3,   "Pivot Left Bars",  minval = 1, group = GD)
int   pivRB   = input.int(1,   "Pivot Right Bars", minval = 1, group = GD)
int   minBP   = input.int(5,   "Min bars P1→P2",   minval = 1, group = GD)
int   maxBP   = input.int(0, "Max bars P1→P2 (0=off)", minval = 0, group = GD)
int   cdBars  = input.int(8,   "Cooldown bars", minval = 0, group = GD)
int   maxPivs = input.int(50,  "Max stored pivots", minval = 2, group = GD)
bool  reqNI   = input.bool(true, "Require slope non-intersection", group = GD)

string GDT = "Divergence Types"
bool  enableRegular = input.bool(true, "Enable Regular Divergences (reversal)", group = GDT)
bool  enableHidden  = input.bool(false, "Enable Hidden Divergences (continuation)", group = GDT)

// ── Wave Type Filter — Regular ──
string GFR = "Wave Filter — Regular Divs"
bool   frEnable = input.bool(false, "Enable wave filter for Regular", group = GFR)
string frDegree = input.string("All Degrees", "Degree to check",
     options = ["Any Degree", "Small", "Medium", "Large", "All Degrees"], group = GFR)
bool   frW5     = input.bool(true, "Allow W5 end",      group = GFR)
bool   frDiag   = input.bool(true, "Allow Diagonal end", group = GFR)
bool   frW3     = input.bool(false, "Allow W3 end",     group = GFR)
bool   frW2     = input.bool(false, "Allow W2 end",     group = GFR)
bool   frW4     = input.bool(false, "Allow W4 end",     group = GFR)
bool   frCorrC  = input.bool(false, "Allow Corrective C", group = GFR)
bool   frTriE   = input.bool(true, "Allow Triangle E",  group = GFR)
bool   frNone   = input.bool(false, "Allow No wave ctx", group = GFR)

// ── Wave Type Filter — Hidden ──
string GFH = "Wave Filter — Hidden Divs"
bool   fhEnable = input.bool(true, "Enable wave filter for Hidden", group = GFH)
string fhDegree = input.string("All Degrees", "Degree to check",
     options = ["Any Degree", "Small", "Medium", "Large", "All Degrees"], group = GFH)
bool   fhW5     = input.bool(false, "Allow W5 end",     group = GFH)
bool   fhDiag   = input.bool(false, "Allow Diagonal end", group = GFH)
bool   fhW3     = input.bool(false, "Allow W3 end",     group = GFH)
bool   fhW2     = input.bool(true, "Allow W2 end",      group = GFH)
bool   fhW4     = input.bool(true, "Allow W4 end",      group = GFH)
bool   fhCorrC  = input.bool(true, "Allow Corrective C", group = GFH)
bool   fhTriE   = input.bool(false, "Allow Triangle E", group = GFH)
bool   fhNone   = input.bool(false, "Allow No wave ctx", group = GFH)

string GO = "Multi-Oscillator Concordance"
int   rsiLen   = input.int(33, "RSI Length",       minval = 1, group = GO)
int   stochLen = input.int(33, "Stoch RSI Length", minval = 1, group = GO)
int   stochK   = input.int(6,  "Stoch RSI %K",    minval = 1, group = GO)
int   mfiLen   = input.int(33, "MFI Length",       minval = 1, group = GO)
int   rocLen   = input.int(33, "ROC Length",       minval = 1, group = GO)
bool  useRSI   = input.bool(true, "Use RSI",          group = GO)
bool  useStoch = input.bool(true, "Use Stochastic RSI", group = GO)
bool  useMFI   = input.bool(true, "Use MFI",          group = GO)
bool  useROC   = input.bool(true, "Use ROC",          group = GO)
int   minConc  = input.int(2, "Min concordance (1–4)", minval = 1, maxval = 4, group = GO)

string GZ = "OB / OS Zones"
float obRSI   = input.float(70.0, "RSI OB",    group = GZ)
float osRSI   = input.float(30.0, "RSI OS",    group = GZ)
float obStoch = input.float(80.0, "Stoch OB",  group = GZ)
float osStoch = input.float(20.0, "Stoch OS",  group = GZ)
float obMFI   = input.float(80.0, "MFI OB",    group = GZ)
float osMFI   = input.float(20.0, "MFI OS",    group = GZ)

string GQ = "Statistical Quality"
float zThr      = input.float(1.5,  "Z-score threshold",    minval = 0.5, step = 0.1, group = GQ)
int   hurstWin  = input.int(40,     "Hurst lookback",       minval = 10, maxval = 200, group = GQ)
int   entBins   = input.int(10,     "Entropy bins",         minval = 5, maxval = 30, group = GQ)
float hurstMRw  = input.float(0.70, "Hurst MR bonus weight", minval = 0, maxval = 1, step = 0.05, group = GQ)

string GB = "Bayesian Fusion Weights"
float wConc    = input.float(0.28, "Wt: Concordance",    minval = 0, maxval = 1, step = 0.01, group = GB)
float wZsc     = input.float(0.12, "Wt: Z-score",        minval = 0, maxval = 1, step = 0.01, group = GB)
float wHur     = input.float(0.12, "Wt: Hurst",          minval = 0, maxval = 1, step = 0.01, group = GB)
float wEnt     = input.float(0.08, "Wt: Entropy",        minval = 0, maxval = 1, step = 0.01, group = GB)
float wWave    = input.float(0.25, "Wt: Wave context",   minval = 0, maxval = 1, step = 0.01, group = GB)
float wOvr     = input.float(0.08, "Wt: Over-extension", minval = 0, maxval = 1, step = 0.01, group = GB)
float wTrend   = input.float(0.07, "Wt: Trend agreement", minval = 0, maxval = 1, step = 0.01, group = GB)
float priorLO  = input.float(0.0,  "Prior log-odds",     minval = -3, maxval = 3, step = 0.1, group = GB)
float minPost  = input.float(0.85, "Min Score",  minval = 0.5, maxval = 0.95, step = 0.01, group = GB)

// ── Wave Context Engine (Three Degrees) ──
string GWS = "Wave Engine — Small Degree"
int   wsLMin = input.int(3,   "Small left min",  minval = 1, group = GWS)
int   wsLMax = input.int(30,  "Small left max",  minval = 1, group = GWS)
int   wsRMin = input.int(1,   "Small right min", minval = 0, group = GWS)
int   wsRMax = input.int(3,   "Small right max", minval = 0, group = GWS)
float wsMinPct = input.float(0.08, "Small min swing %", minval = 0, step = 0.02, group = GWS)

string GWM = "Wave Engine — Medium Degree"
int   wmLMin = input.int(10,  "Medium left min",  minval = 1, group = GWM)
int   wmLMax = input.int(80,  "Medium left max",  minval = 1, group = GWM)
int   wmRMin = input.int(1,   "Medium right min", minval = 0, group = GWM)
int   wmRMax = input.int(5,   "Medium right max", minval = 0, group = GWM)
float wmMinPct = input.float(0.20, "Medium min swing %", minval = 0, step = 0.05, group = GWM)

string GWL = "Wave Engine — Large Degree"
int   wlLMin = input.int(25,   "Large left min",  minval = 1, group = GWL)
int   wlLMax = input.int(200,  "Large left max",  minval = 1, group = GWL)
int   wlRMin = input.int(2,    "Large right min", minval = 0, group = GWL)
int   wlRMax = input.int(10,   "Large right max", minval = 0, group = GWL)
float wlMinPct = input.float(0.50, "Large min swing %", minval = 0, step = 0.10, group = GWL)

string GWC = "Wave Engine — Common"
int   wvMax     = input.int(60, "Max swings per degree", minval = 12, maxval = 200, group = GWC)
float wvMinQ    = input.float(0.35, "Min impulse quality", minval = 0, maxval = 1, step = 0.01, group = GWC)
float wvChanTol = input.float(0.25, "Channel tolerance",   minval = 0, maxval = 1, step = 0.01, group = GWC)
int   wvProx    = input.int(12, "Wave-div proximity (bars)", minval = 1, maxval = 50, group = GWC)
bool  showWvLn  = input.bool(false, "Show wave swing lines", group = GWC)

string GV = "Visual"
bool  showDivLn  = input.bool(true,  "Show div trendlines", group = GV)
bool  showLbl    = input.bool(true,  "Show signal labels",  group = GV)
bool  annScore   = input.bool(true,  "Annotate score %",    group = GV)
bool  annConc    = input.bool(true,  "Annotate concordance", group = GV)
bool  annWave    = input.bool(true,  "Annotate wave ctx",   group = GV)
bool  annType    = input.bool(true,  "Annotate div type (R/H)", group = GV)
color regBullCol = input.color(color.new(color.green, 0), "Regular Bull color", group = GV)
color regBearCol = input.color(color.new(color.red,   0), "Regular Bear color", group = GV)
color hidBullCol = input.color(color.new(color.teal,  0), "Hidden Bull color",  group = GV)
color hidBearCol = input.color(color.new(color.orange, 0), "Hidden Bear color", group = GV)

string GTG = "Targets & Invalidation"
bool  showTgt    = input.bool(false, "Show targets", group = GTG)
int   tgtExt     = input.int(200,   "Target extend bars", minval = 20, maxval = 2000, group = GTG)
int   invTicks   = input.int(100,   "Invalidation ticks", minval = 0, maxval = 500, group = GTG)

// ============================================================================
// ========================== UTILITY FUNCTIONS ================================
// ============================================================================

f_clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
f_bb(int a, int b) => math.abs(a - b)
f_p2lo(float p) =>
    float c = f_clamp(p, 0.001, 0.999)
    math.log(c / (1.0 - c))
f_lo2p(float lo) => 1.0 / (1.0 + math.exp(-lo))

// ============================================================================
// ================== WAVE FILTER FUNCTIONS ====================================
// ============================================================================

// Check if a single posType is allowed under the Regular filter set
f_ptAllowedReg(int pt) =>
    (pt == 0 and frNone) or (pt == 1 and frW5) or (pt == 2 and frDiag) or
     (pt == 3 and frW3) or (pt == 4 and frW2) or (pt == 5 and frW4) or
     (pt == 6 and frCorrC) or (pt == 7 and frTriE)

// Check if a single posType is allowed under the Hidden filter set
f_ptAllowedHid(int pt) =>
    (pt == 0 and fhNone) or (pt == 1 and fhW5) or (pt == 2 and fhDiag) or
     (pt == 3 and fhW3) or (pt == 4 and fhW2) or (pt == 5 and fhW4) or
     (pt == 6 and fhCorrC) or (pt == 7 and fhTriE)

// Master filter gate — called with the three degree posTypes and whether this is regular or hidden
f_waveFilterPass(int sPT, int mPT, int lgPT, bool isRegDiv) =>
    bool useFilter = isRegDiv ? frEnable : fhEnable
    if not useFilter
        true
    else
        string degMode = isRegDiv ? frDegree : fhDegree
        bool sOK  = isRegDiv ? f_ptAllowedReg(sPT)  : f_ptAllowedHid(sPT)
        bool mOK  = isRegDiv ? f_ptAllowedReg(mPT)  : f_ptAllowedHid(mPT)
        bool lgOK = isRegDiv ? f_ptAllowedReg(lgPT) : f_ptAllowedHid(lgPT)
        bool pass = false
        if degMode == "Any Degree"
            pass := sOK or mOK or lgOK
        else if degMode == "Small"
            pass := sOK
        else if degMode == "Medium"
            pass := mOK
        else if degMode == "Large"
            pass := lgOK
        else  // "All Degrees"
            pass := sOK and mOK and lgOK
        pass

// ============================================================================
// ================== OSCILLATORS =============================================
// ============================================================================

float oRsi   = ta.rsi(close, rsiLen)
float rForS  = ta.rsi(close, stochLen)
float sRaw   = ta.stoch(rForS, rForS, rForS, stochLen)
float oStoch = ta.sma(sRaw, stochK)
float oMfi   = ta.mfi(hlc3, mfiLen)
float rawRoc = ta.roc(close, rocLen)
float rocSig = ta.stdev(rawRoc, 50)
float oRoc   = 50.0 + 25.0 * (rocSig > 0 ? rawRoc / rocSig : 0.0)
float atr14  = ta.atr(14)

// ============================================================================
// ================== HURST EXPONENT ==========================================
// ============================================================================

f_hurst(int w) =>
    float H = 0.5
    if bar_index >= w
        float mr = 0.0
        for i = 0 to w - 2
            mr += math.log(close[i] / close[i + 1])
        mr := mr / (w - 1)
        float cd = 0.0
        float mx = -1e18
        float mn =  1e18
        for i = 0 to w - 2
            float r = math.log(close[i] / close[i + 1])
            cd += (r - mr)
            mx := math.max(mx, cd)
            mn := math.min(mn, cd)
        float R = mx - mn
        float S = ta.stdev(close, w)
        float RS = S > 0 ? R / S : 0.0
        H := RS > 0 and w > 1 ? math.log(RS) / math.log(w) : 0.5
        H := f_clamp(H, 0.0, 1.0)
    H

float curHurst = f_hurst(hurstWin)

// ============================================================================
// ================== SHANNON ENTROPY =========================================
// ============================================================================

f_entropy(int w, int nb) =>
    float res = 0.0
    if bar_index >= w and w > 1
        float mnR =  1e18
        float mxR = -1e18
        for i = 0 to w - 2
            float r = math.log(close[i] / close[i + 1])
            mnR := math.min(mnR, r)
            mxR := math.max(mxR, r)
        float rng = mxR - mnR
        if rng > 0
            var int[] bins = array.new_int()
            array.clear(bins)
            for _b = 0 to nb - 1
                array.push(bins, 0)
            int tot = 0
            for i = 0 to w - 2
                float r = math.log(close[i] / close[i + 1])
                int bi = math.min(nb - 1, math.floor((r - mnR) / rng * nb))
                if bi >= 0 and bi < nb
                    array.set(bins, bi, array.get(bins, bi) + 1)
                    tot += 1
            if tot > 0
                float ent = 0.0
                for b = 0 to nb - 1
                    int c = array.get(bins, b)
                    if c > 0
                        float p = c * 1.0 / tot
                        ent -= p * math.log(p)
                float maxE = math.log(nb)
                res := maxE > 0 ? ent / maxE : 0.0
    res

float curEntropy = f_entropy(hurstWin, entBins)

// ============================================================================
// ========= WAVE CONTEXT ENGINE — THREE DEGREES ==============================
// ============================================================================

f_addSw(float p, int b, int t, float[] pr, int[] br, int[] tp) =>
    array.push(pr, p)
    array.push(br, b)
    array.push(tp, t)

f_procSw(bool hF, float hP, int hI, bool lF, float lP, int lI,
         float minPc, float[] pr, int[] br, int[] tp, int mx) =>
    float opp = array.size(pr) > 0 ? array.get(pr, array.size(pr) - 1) : na
    bool add = false
    if hF and lF
        if hI <= lI
            if na(opp) or math.abs(hP - opp) / math.max(math.abs(opp), 1e-9) * 100 >= minPc
                f_addSw(hP, hI, PH, pr, br, tp)
                add := true
                opp := hP
            if na(opp) or math.abs(lP - opp) / math.max(math.abs(opp), 1e-9) * 100 >= minPc
                f_addSw(lP, lI, PL, pr, br, tp)
                add := true
        else
            if na(opp) or math.abs(lP - opp) / math.max(math.abs(opp), 1e-9) * 100 >= minPc
                f_addSw(lP, lI, PL, pr, br, tp)
                add := true
                opp := lP
            if na(opp) or math.abs(hP - opp) / math.max(math.abs(opp), 1e-9) * 100 >= minPc
                f_addSw(hP, hI, PH, pr, br, tp)
                add := true
    else if hF
        if na(opp) or math.abs(hP - opp) / math.max(math.abs(opp), 1e-9) * 100 >= minPc
            f_addSw(hP, hI, PH, pr, br, tp)
            add := true
    else if lF
        if na(opp) or math.abs(lP - opp) / math.max(math.abs(opp), 1e-9) * 100 >= minPc
            f_addSw(lP, lI, PL, pr, br, tp)
            add := true
    bool rn = false
    if add and array.size(tp) > 1
        int la = array.size(tp) - 1
        int pv = la - 1
        if array.get(tp, la) == array.get(tp, pv)
            if array.get(tp, la) == PH
                if array.get(pr, la) > array.get(pr, pv)
                    array.set(pr, pv, array.get(pr, la))
                    array.set(br, pv, array.get(br, la))
            else
                if array.get(pr, la) < array.get(pr, pv)
                    array.set(pr, pv, array.get(pr, la))
                    array.set(br, pv, array.get(br, la))
            array.pop(pr)
            array.pop(br)
            array.pop(tp)
            rn := true
        else
            rn := true
    else if add
        rn := true
    while array.size(pr) > mx
        array.shift(pr)
        array.shift(br)
        array.shift(tp)
    rn

f_scanPiv(int lMin, int lMax, int rMin, int rMax, int lastB) =>
    int lLo = math.min(lMin, lMax)
    int lHi = math.max(lMin, lMax)
    int rLo = math.min(rMin, rMax)
    int rHi = math.max(rMin, rMax)
    bool hF = false
    float hP = na
    int hI = na
    bool lF = false
    float lP = na
    int lI = na
    for l = lLo to lHi
        for r = rLo to rHi
            float ph = ta.pivothigh(high, l, r)
            if not na(ph) and (bar_index - r) > lastB
                if na(hP) or ph > hP
                    hF := true
                    hP := ph
                    hI := bar_index - r
            float pl = ta.pivotlow(low, l, r)
            if not na(pl) and (bar_index - r) > lastB
                if na(lP) or pl < lP
                    lF := true
                    lP := pl
                    lI := bar_index - r
    [hF, hP, hI, lF, lP, lI]

f_impQ(int i0, int i1, int i2, int i3, int i4, int i5,
       float[] pr, int[] br) =>
    float p0 = array.get(pr, i0)
    float p1 = array.get(pr, i1)
    float p2 = array.get(pr, i2)
    float p3 = array.get(pr, i3)
    float p4 = array.get(pr, i4)
    float p5 = array.get(pr, i5)
    float a1 = math.abs(p1 - p0)
    float a3 = math.abs(p3 - p2)
    float a5 = math.abs(p5 - p4)
    int b0 = array.get(br, i0)
    int b1 = array.get(br, i1)
    int b2 = array.get(br, i2)
    int b3 = array.get(br, i3)
    int b4 = array.get(br, i4)
    int b5 = array.get(br, i5)
    bool hr1 = p1 > p0 ? (p2 > p0) : (p2 < p0)
    bool hr2 = not (a3 < a1 and a3 < a5)
    bool hr3 = p1 > p0 ? (math.min(p3, p4) > math.max(p0, p1)) : (math.max(p3, p4) < math.min(p0, p1))
    bool hr4 = p1 > p0 ? (p3 > p1) : (p3 < p1)
    bool ok = hr1 and hr2 and hr3 and hr4
    int t1 = f_bb(b0, b1)
    int t3 = f_bb(b2, b3)
    int t5 = f_bb(b4, b5)
    float s1 = a1 / math.max(1, t1)
    float s3 = a3 / math.max(1, t3)
    float s5 = a5 / math.max(1, t5)
    float momR = math.min(s1 > 0 ? s3 / s1 : 5.0, s5 > 0 ? s3 / s5 : 5.0)
    float momSc = momR >= 1.0 ? 1.0 : f_clamp(momR, 0, 1)
    float pR = math.max(a1, math.max(a3, a5))
    float bSlp = (b4 != b0) ? (p4 - p0) / (b4 - b0) : 0.0
    float uSlp = (b3 != b1) ? (p3 - p1) / (b3 - b1) : 0.0
    float nB = pR > 0 ? bSlp / pR : 0.0
    float nU = pR > 0 ? uSlp / pR : 0.0
    float cSc = f_clamp(1.0 - math.abs(nB - nU) / wvChanTol, 0, 1)
    float sh2 = t1 > 0 ? math.abs(p2 - p1) / f_bb(b1, b2) : 0.0
    float sh4 = t3 > 0 ? math.abs(p4 - p3) / f_bb(b3, b4) : 0.0
    float altSc = (sh2 + sh4) > 0 ? math.abs(sh2 - sh4) / (sh2 + sh4) : 0.0
    float qual = ok ? (momSc * 0.35 + cSc * 0.35 + altSc * 0.30) : 0.0
    bool isUp = p1 > p0
    [ok, qual, isUp]

f_diaQ(int i0, int i1, int i2, int i3, int i4, int i5,
       float[] pr, int[] br) =>
    float p0 = array.get(pr, i0)
    float p1 = array.get(pr, i1)
    float p2 = array.get(pr, i2)
    float p3 = array.get(pr, i3)
    float p4 = array.get(pr, i4)
    float a1 = math.abs(p1 - p0)
    float a3 = math.abs(p3 - p2)
    float a5 = math.abs(array.get(pr, i5) - p4)
    int b1 = array.get(br, i1)
    int b2 = array.get(br, i2)
    int b3 = array.get(br, i3)
    int b4 = array.get(br, i4)
    bool dr1 = p1 > p0 ? (p2 > p0) : (p2 < p0)
    bool dr2 = not (a3 < a1 and a3 < a5)
    bool dr3 = p1 > p0 ? (math.min(p3, p4) <= math.max(p0, p1)) : (math.max(p3, p4) >= math.min(p0, p1))
    float hS = (b3 != b1) ? (p3 - p1) / (b3 - b1) : 0.0
    float lS = (b4 != b2) ? (p4 - p2) / (b4 - b2) : 0.0
    bool ok = dr1 and dr2 and dr3 and (hS != lS)
    bool isUp = p1 > p0
    [ok, ok ? 0.45 : 0.0, isUp]

f_classifyPos(float[] pr, int[] br, int[] tp) =>
    int sz = array.size(pr)
    float posScore = WPC_NEUTRAL
    float qual = 0.0
    int   posType = 0
    int   trendDir = 0

    if sz >= 6
        int i5 = sz - 1
        int i4 = sz - 2
        int i3 = sz - 3
        int i2 = sz - 4
        int i1 = sz - 5
        int i0 = sz - 6
        [impOK, impQ, impUp] = f_impQ(i0, i1, i2, i3, i4, i5, pr, br)
        [diaOK, diaQ, diaUp] = f_diaQ(i0, i1, i2, i3, i4, i5, pr, br)
        if impOK and impQ >= wvMinQ
            posScore := WPC_W5
            qual     := impQ
            posType  := 1
            trendDir := impUp ? 1 : -1
        else if diaOK and diaQ >= wvMinQ
            posScore := WPC_DIAG
            qual     := diaQ
            posType  := 2
            trendDir := diaUp ? 1 : -1

    if sz >= 4 and posType == 0
        float pA = array.get(pr, sz - 4)
        float pB = array.get(pr, sz - 3)
        float pC = array.get(pr, sz - 2)
        float pD = array.get(pr, sz - 1)
        float a1w = math.abs(pB - pA)
        float a3w = math.abs(pD - pC)
        bool sameDir = (pB > pA and pD > pC) or (pB < pA and pD < pC)
        if sameDir and a3w > a1w * 1.1
            posScore := WPC_W3
            qual     := f_clamp(a3w / math.max(a1w, 1e-9) / 3.0, 0, 1)
            posType  := 3
            trendDir := pD > pC ? 1 : -1

    if sz >= 3 and posType == 0
        float pO = array.get(pr, sz - 3)
        float pW1 = array.get(pr, sz - 2)
        float pW2 = array.get(pr, sz - 1)
        float w1amp = math.abs(pW1 - pO)
        float w2amp = math.abs(pW2 - pW1)
        float retr = w1amp > 0 ? w2amp / w1amp : 0.0
        bool isRetrace = (pW1 > pO and pW2 < pW1 and pW2 > pO) or
                         (pW1 < pO and pW2 > pW1 and pW2 < pO)
        if isRetrace and retr >= 0.236 and retr <= 0.786
            posScore := WPC_W2
            qual     := f_clamp(1.0 - math.abs(retr - 0.5) * 3.0, 0.2, 0.8)
            posType  := 4
            trendDir := pW1 > pO ? 1 : -1

    if sz >= 5 and posType == 0
        float p0 = array.get(pr, sz - 5)
        float p1 = array.get(pr, sz - 4)
        float p2 = array.get(pr, sz - 3)
        float p3 = array.get(pr, sz - 2)
        float p4 = array.get(pr, sz - 1)
        float a1w = math.abs(p1 - p0)
        float a3w = math.abs(p3 - p2)
        float a4w = math.abs(p4 - p3)
        float retr4 = a3w > 0 ? a4w / a3w : 0.0
        bool sameDir13 = (p1 > p0 and p3 > p2) or (p1 < p0 and p3 < p2)
        bool w4retrace = (p3 > p2 and p4 < p3 and p4 > p2) or
                         (p3 < p2 and p4 > p3 and p4 < p2)
        if sameDir13 and w4retrace and retr4 >= 0.236 and retr4 <= 0.618
            bool noOverlap = p1 > p0 ? (math.min(p3, p4) > math.max(p0, p1)) : (math.max(p3, p4) < math.min(p0, p1))
            if noOverlap
                posScore := WPC_W4
                qual     := f_clamp(1.0 - math.abs(retr4 - 0.382) * 3.0, 0.2, 0.8)
                posType  := 5
                trendDir := p1 > p0 ? 1 : -1

    if sz >= 4 and posType == 0
        float pA = array.get(pr, sz - 4)
        float pB = array.get(pr, sz - 3)
        float pC = array.get(pr, sz - 2)
        float pD = array.get(pr, sz - 1)
        float wA = math.abs(pB - pA)
        float wB = math.abs(pC - pB)
        float retrB = wA > 0 ? wB / wA : 0.0
        if retrB < 0.618 and math.abs(pD - pC) > 0
            posScore := WPC_CORR_C
            qual     := 0.55
            posType  := 6
            trendDir := pD < pC ? 1 : -1

    if sz >= 5 and posType == 0
        int t0 = sz - 5
        int t4 = sz - 1
        bool alt = true
        for ii = t0 to t4 - 1
            if array.get(tp, ii) == array.get(tp, ii + 1)
                alt := false
        if alt
            float hOld = na
            float hNew = na
            float lOld = na
            float lNew = na
            for ii = t0 to t4
                int tvp = array.get(tp, ii)
                float pvl = array.get(pr, ii)
                if tvp == PH
                    if na(hOld)
                        hOld := pvl
                    else if na(hNew)
                        hNew := pvl
                    else
                        hOld := hNew
                        hNew := pvl
                else
                    if na(lOld)
                        lOld := pvl
                    else if na(lNew)
                        lNew := pvl
                    else
                        lOld := lNew
                        lNew := pvl
            bool hv = not na(hOld) and not na(hNew) and not na(lOld) and not na(lNew)
            if hv and hNew < hOld and lNew > lOld
                posScore := WPC_TRI_E
                qual     := 0.55
                posType  := 7

    if trendDir == 0 and sz >= 2
        trendDir := array.get(pr, sz - 1) > array.get(pr, sz - 2) ? 1 : -1

    [posScore, qual, posType, trendDir]

f_flipForHidden(int pt) =>
    float out = WPCH_NEUTRAL
    if pt == 1 or pt == 2
        out := WPCH_W5
    else if pt == 4
        out := WPCH_W2
    else if pt == 5
        out := WPCH_W4
    else if pt == 6
        out := WPCH_CORR_C
    else if pt == 3
        out := WPCH_W3
    out

// ── Run Small Degree ──
var float[] wsPr = array.new_float()
var int[]   wsBr = array.new_int()
var int[]   wsTp = array.new_int()
var int     wsLB = -1

[wsHF, wsHP, wsHI, wsLF, wsLP, wsLI] = f_scanPiv(wsLMin, wsLMax, wsRMin, wsRMax, wsLB)
bool wsNew = f_procSw(wsHF, wsHP, wsHI, wsLF, wsLP, wsLI, wsMinPct, wsPr, wsBr, wsTp, wvMax)
if wsNew and array.size(wsBr) > 0
    wsLB := array.get(wsBr, array.size(wsBr) - 1)
if showWvLn and wsNew and array.size(wsPr) >= 2
    int li = array.size(wsPr) - 1
    line.new(array.get(wsBr, li - 1), array.get(wsPr, li - 1),
             array.get(wsBr, li),     array.get(wsPr, li),
             color = color.new(color.blue, 70), width = 1)

// ── Run Medium Degree ──
var float[] wmPr = array.new_float()
var int[]   wmBr = array.new_int()
var int[]   wmTp = array.new_int()
var int     wmLB = -1

[wmHF, wmHP, wmHI, wmLF, wmLP, wmLI] = f_scanPiv(wmLMin, wmLMax, wmRMin, wmRMax, wmLB)
bool wmNew = f_procSw(wmHF, wmHP, wmHI, wmLF, wmLP, wmLI, wmMinPct, wmPr, wmBr, wmTp, wvMax)
if wmNew and array.size(wmBr) > 0
    wmLB := array.get(wmBr, array.size(wmBr) - 1)
if showWvLn and wmNew and array.size(wmPr) >= 2
    int li = array.size(wmPr) - 1
    line.new(array.get(wmBr, li - 1), array.get(wmPr, li - 1),
             array.get(wmBr, li),     array.get(wmPr, li),
             color = color.new(color.purple, 70), width = 1)

// ── Run Large Degree ──
var float[] wlPr = array.new_float()
var int[]   wlBr = array.new_int()
var int[]   wlTp = array.new_int()
var int     wlLB = -1

[wlHF, wlHP, wlHI, wlLF, wlLP, wlLI] = f_scanPiv(wlLMin, wlLMax, wlRMin, wlRMax, wlLB)
bool wlNew = f_procSw(wlHF, wlHP, wlHI, wlLF, wlLP, wlLI, wlMinPct, wlPr, wlBr, wlTp, wvMax)
if wlNew and array.size(wlBr) > 0
    wlLB := array.get(wlBr, array.size(wlBr) - 1)
if showWvLn and wlNew and array.size(wlPr) >= 2
    int li = array.size(wlPr) - 1
    line.new(array.get(wlBr, li - 1), array.get(wlPr, li - 1),
             array.get(wlBr, li),     array.get(wlPr, li),
             color = color.new(color.orange, 70), width = 1)

// ── Classify all three degrees ──
[sPosScore, sQual, sPosType, sTrendDir] = f_classifyPos(wsPr, wsBr, wsTp)
[mPosScore, mQual, mPosType, mTrendDir] = f_classifyPos(wmPr, wmBr, wmTp)
[lPosScore, lQual, lPosType, lTrendDir] = f_classifyPos(wlPr, wlBr, wlTp)

// ── Composite wave context score (tri-degree) ──
f_compositeWaveCtx(int divBar, bool isRegular, bool isBullDiv) =>
    float sScore = WPC_NEUTRAL
    float sQ = 0.0
    int   sTD = 0
    int   sPT = 0
    if array.size(wsBr) > 0
        int lastSBar = array.get(wsBr, array.size(wsBr) - 1)
        if math.abs(lastSBar - divBar) <= wvProx
            sScore := sPosScore
            sQ     := sQual
            sTD    := sTrendDir
            sPT    := sPosType

    float mScore = WPC_NEUTRAL
    float mQ = 0.0
    int   mTD = 0
    int   mPT = 0
    if array.size(wmBr) > 0
        int lastMBar = array.get(wmBr, array.size(wmBr) - 1)
        if math.abs(lastMBar - divBar) <= wvProx * 2
            mScore := mPosScore
            mQ     := mQual
            mTD    := mTrendDir
            mPT    := mPosType

    float lgScore = WPC_NEUTRAL
    float lgQ = 0.0
    int   lgTD = 0
    int   lgPT = 0
    if array.size(wlBr) > 0
        int lastLBar = array.get(wlBr, array.size(wlBr) - 1)
        if math.abs(lastLBar - divBar) <= wvProx * 4
            lgScore := lPosScore
            lgQ     := lQual
            lgTD    := lTrendDir
            lgPT    := lPosType

    float sAdj  = isRegular ? sScore  : f_flipForHidden(sPT)
    float mAdj  = isRegular ? mScore  : f_flipForHidden(mPT)
    float lgAdj = isRegular ? lgScore : f_flipForHidden(lgPT)

    float sFinal  = WPC_NEUTRAL + (sAdj  - WPC_NEUTRAL) * math.max(sQ, 0.3)
    float mFinal  = WPC_NEUTRAL + (mAdj  - WPC_NEUTRAL) * math.max(mQ, 0.3)
    float lgFinal = WPC_NEUTRAL + (lgAdj - WPC_NEUTRAL) * math.max(lgQ, 0.3)

    float xdeg = 0.0
    bool sHigh  = sAdj  > 0.6
    bool mHigh  = mAdj  > 0.6
    bool lgHigh = lgAdj > 0.6
    bool sLow   = sAdj  < 0.3
    bool mLow   = mAdj  < 0.3
    bool lgLow  = lgAdj < 0.3

    if sHigh and mHigh and lgHigh
        xdeg := XDEG_TRI_BOOST
    else if (sHigh and mHigh) or (sHigh and lgHigh) or (mHigh and lgHigh)
        xdeg := XDEG_AGREE_BOOST
    else if isRegular and sAdj > 0.7 and mLow and lgLow
        xdeg := XDEG_TRI_CONFLICT
    else if not isRegular and sAdj > 0.7 and mLow and lgLow
        xdeg := XDEG_TRI_CONFLICT
    else if isRegular and sAdj > 0.7 and (mLow or lgLow)
        xdeg := XDEG_CONFLICT_PEN
    else if not isRegular and sAdj > 0.7 and (mLow or lgLow)
        xdeg := XDEG_CONFLICT_PEN

    float composite = sFinal * 0.45 + mFinal * 0.30 + lgFinal * 0.25 + xdeg
    composite := f_clamp(composite, 0.05, 0.95)

    float trendP = WPC_NEUTRAL
    int refTD = mTD != 0 ? mTD : lgTD
    if refTD != 0
        if isRegular
            bool opposing = (isBullDiv and refTD == -1) or (not isBullDiv and refTD == 1)
            trendP := opposing ? 0.75 : 0.30
        else
            bool agreeing = (isBullDiv and refTD == 1) or (not isBullDiv and refTD == -1)
            trendP := agreeing ? 0.80 : 0.25
    if mTD != 0 and lgTD != 0 and mTD == lgTD
        if isRegular
            bool opposing = (isBullDiv and mTD == -1) or (not isBullDiv and mTD == 1)
            trendP := opposing ? f_clamp(trendP + 0.08, 0.05, 0.95) : f_clamp(trendP - 0.08, 0.05, 0.95)
        else
            bool agreeing = (isBullDiv and mTD == 1) or (not isBullDiv and mTD == -1)
            trendP := agreeing ? f_clamp(trendP + 0.08, 0.05, 0.95) : f_clamp(trendP - 0.08, 0.05, 0.95)

    [composite, trendP, sPT, mPT, lgPT]

// ============================================================================
// ================ DIVERGENCE PIVOT STORES ===================================
// ============================================================================

var int[]   dpLB = array.new_int()
var float[] dpLP = array.new_float()
var float[] dpLR = array.new_float()
var float[] dpLS = array.new_float()
var float[] dpLM = array.new_float()
var float[] dpLO = array.new_float()

var int[]   dpHB = array.new_int()
var float[] dpHP = array.new_float()
var float[] dpHR = array.new_float()
var float[] dpHS = array.new_float()
var float[] dpHM = array.new_float()
var float[] dpHO = array.new_float()

var int lastBullA = na
var int lastBearA = na

float plD = ta.pivotlow(low,   pivLB, pivRB)
float phD = ta.pivothigh(high, pivLB, pivRB)

// ============================================================================
// ================ TARGET / LINE MANAGEMENT ==================================
// ============================================================================

var line[]  tLn = array.new_line()
var label[] tLb = array.new_label()

f_pruneT() =>
    while array.size(tLn) > 200
        line.delete(array.shift(tLn))
    while array.size(tLb) > 200
        label.delete(array.shift(tLb))

f_pH(float y, color c, string t, int x, int e, bool d) =>
    line ln = line.new(x, y, math.max(x + 1, x + e), y, xloc = xloc.bar_index,
                       color = c, width = 2, style = d ? line.style_dashed : line.style_solid)
    array.push(tLn, ln)
    label lb = label.new(x, y, t, style = label.style_label_left,
                         textcolor = color.white, color = color.new(c, 70))
    array.push(tLb, lb)
    f_pruneT()

f_wvTxt(int pt, string prefix) =>
    string r = pt == 1 ? prefix + "W5" : pt == 2 ? prefix + "Diag" : pt == 3 ? prefix + "W3!" :
               pt == 4 ? prefix + "W2" : pt == 5 ? prefix + "W4" : pt == 6 ? prefix + "CorrC" :
               pt == 7 ? prefix + "TriE" : ""
    r

// ============================================================================
// ===================== CORE DIVERGENCE SCANNER ==============================
// ============================================================================

// ============================================================================
// ============================= ALERT FLAGS ==================================
// ============================================================================

bool alertRegBull = false
bool alertHidBull = false
bool alertRegBear = false
bool alertHidBear = false


// ──── LOW PIVOT (Bullish regular + Hidden bullish) ────
if not na(plD)
    int   P2bi = bar_index - pivRB
    float P2p  = low[pivRB]
    float P2r  = oRsi[pivRB]
    float P2s  = oStoch[pivRB]
    float P2m  = oMfi[pivRB]
    float P2o  = oRoc[pivRB]

    if array.size(dpLB) > 0
        for i = 0 to array.size(dpLB) - 1
            if i >= array.size(dpLP)
                continue
            int P1bi = array.get(dpLB, i)
            if P2bi <= P1bi
                continue
            int db = P2bi - P1bi
            if db < minBP
                continue
            if maxBP > 0 and db > maxBP
                continue
            if not na(lastBullA) and (P2bi - lastBullA) < cdBars
                continue

            float P1p = array.get(dpLP, i)

            bool regBull = enableRegular and (P2p < P1p)
            bool hidBull = enableHidden  and (P2p > P1p)

            if not regBull and not hidBull
                continue

            int conc = 0
            int oscN = 0

            if useRSI and i < array.size(dpLR)
                oscN += 1
                float P1r = array.get(dpLR, i)
                if regBull and P2r > P1r and P1r < osRSI
                    conc += 1
                else if hidBull and P2r < P1r
                    conc += 1

            if useStoch and i < array.size(dpLS)
                oscN += 1
                float P1s = array.get(dpLS, i)
                if regBull and P2s > P1s and P1s < osStoch
                    conc += 1
                else if hidBull and P2s < P1s
                    conc += 1

            if useMFI and i < array.size(dpLM)
                oscN += 1
                float P1m = array.get(dpLM, i)
                if regBull and P2m > P1m and P1m < osMFI
                    conc += 1
                else if hidBull and P2m < P1m
                    conc += 1

            if useROC and i < array.size(dpLO)
                oscN += 1
                float P1o = array.get(dpLO, i)
                if regBull and P2o > P1o
                    conc += 1
                else if hidBull and P2o < P1o
                    conc += 1

            bool isReg = regBull and conc >= minConc
            bool isHid = hidBull and conc >= minConc and not isReg

            if not isReg and not isHid
                continue

            if reqNI
                float pSlp = (P2p - P1p) / db
                bool pCr = false
                float pPD = 0.0
                for j = 1 to db - 1
                    int hO = bar_index - (P1bi + j)
                    if hO >= 0 and hO < 5000
                        float dev = low[hO] - (P1p + pSlp * j)
                        if j > 1 and pPD != 0.0 and math.sign(dev) != math.sign(pPD)
                            pCr := true
                        pPD := dev
                if pCr
                    continue

            // ═══════════ WAVE CONTEXT + FILTER GATE ═══════════

            [wCtx, trendP, sWPT, mWPT, lgWPT] = f_compositeWaveCtx(P2bi, isReg, true)

            // ── Wave type filter — reject before remaining fusion ──
            if not f_waveFilterPass(sWPT, mWPT, lgWPT, isReg)
                continue

            // ═══════════ BAYESIAN FUSION ═══════════

            float pConc = oscN > 0 ? conc * 1.0 / oscN : 0.5

            float rDelta = 0.0
            if useRSI and i < array.size(dpLR)
                rDelta := math.abs(P2r - array.get(dpLR, i))
            float rStd = ta.stdev(oRsi, 50)
            float zSc = rStd > 0 ? rDelta / rStd : 0.0
            float pZ = f_clamp(zSc / (zThr * 2.0), 0.05, 0.95)

            float pH = curHurst < 0.5 ?
                 (0.5 + (0.5 - curHurst) * hurstMRw) :
                 (0.5 - (curHurst - 0.5) * hurstMRw)
            pH := f_clamp(pH, 0.05, 0.95)

            float pE = f_clamp(curEntropy, 0.05, 0.95)

            float oER = 1.0
            float midHi = na
            for h = 0 to math.min(array.size(dpHB) - 1, maxPivs - 1)
                int hb = array.get(dpHB, h)
                if hb > P1bi and hb < P2bi
                    float cp = array.get(dpHP, h)
                    if na(midHi) or cp > midHi
                        midHi := cp
            float prevHi = na
            for h = 0 to math.min(array.size(dpHB) - 1, maxPivs - 1)
                int hb = array.get(dpHB, h)
                if hb < P1bi
                    float cp = array.get(dpHP, h)
                    if na(prevHi) or cp > prevHi
                        prevHi := cp
            if not na(midHi) and not na(prevHi)
                float lL = math.abs(P2p - midHi) / math.max(1e-9, midHi)
                float pL = math.abs(P1p - prevHi) / math.max(1e-9, prevHi)
                oER := pL == 0 ? 5.0 : lL / pL
            float pOE = f_clamp((oER - 1.0) / 3.0, 0.05, 0.95)

            float L = priorLO
            L += wConc  * f_p2lo(pConc)
            L += wZsc   * f_p2lo(pZ)
            L += wHur   * f_p2lo(pH)
            L += wEnt   * f_p2lo(pE)
            L += wWave  * f_p2lo(wCtx)
            L += wOvr   * f_p2lo(pOE)
            L += wTrend * f_p2lo(trendP)

            float post = f_lo2p(L)

            if post >= minPost
                lastBullA := P2bi
                if isReg
                    alertRegBull := true
                else
                    alertHidBull := true


                color sigCol = isReg ? regBullCol : hidBullCol

                string tag = isReg ? "Bull" : "H.Bull"
                if annType
                    tag := isReg ? "R↑" : "H↑"
                if annConc
                    tag += " " + str.tostring(conc) + "/" + str.tostring(oscN)
                if annScore
                    tag += " " + str.tostring(math.round(post * 100)) + "%"
                if annWave
                    string swT = f_wvTxt(sWPT, "")
                    if swT != ""
                        tag += " " + swT
                    string mwT = f_wvTxt(mWPT, "m")
                    if mwT != "" and mWPT != sWPT
                        tag += "/" + mwT
                    string lwT = f_wvTxt(lgWPT, "L")
                    if lwT != "" and lgWPT != sWPT and lgWPT != mWPT
                        tag += "/" + lwT

                if showDivLn
                    line.new(P1bi, P1p, P2bi, P2p, xloc = xloc.bar_index,
                             color = sigCol, style = line.style_dotted, width = 2)
                if showLbl
                    label.new(P2bi, P2p, tag, yloc = yloc.belowbar,
                              style = label.style_label_up, color = color.new(sigCol, 40),
                              textcolor = color.white, size = size.small)
                if showTgt
                    float leg = na(midHi) ? math.abs(P2p - P1p) : math.abs(P2p - midHi)
                    if leg == 0
                        leg := atr14 * 2
                    f_pH(P2p + leg * 0.618, sigCol, "T1", P2bi, tgtExt, true)
                    f_pH(P2p + leg * 1.0,   sigCol, "T2", P2bi, tgtExt, true)
                    f_pH(P2p + leg * 1.618, sigCol, "T3", P2bi, tgtExt, true)
                    f_pH(P2p - syminfo.mintick * invTicks, color.gray, "Inv", P2bi, tgtExt, false)
                break

    array.unshift(dpLB, P2bi)
    array.unshift(dpLP, P2p)
    array.unshift(dpLR, P2r)
    array.unshift(dpLS, P2s)
    array.unshift(dpLM, P2m)
    array.unshift(dpLO, P2o)
    while array.size(dpLB) > maxPivs
        array.pop(dpLB)
        array.pop(dpLP)
        array.pop(dpLR)
        array.pop(dpLS)
        array.pop(dpLM)
        array.pop(dpLO)

// ──── HIGH PIVOT (Bearish regular + Hidden bearish) ────
if not na(phD)
    int   P2bi = bar_index - pivRB
    float P2p  = high[pivRB]
    float P2r  = oRsi[pivRB]
    float P2s  = oStoch[pivRB]
    float P2m  = oMfi[pivRB]
    float P2o  = oRoc[pivRB]

    if array.size(dpHB) > 0
        for i = 0 to array.size(dpHB) - 1
            if i >= array.size(dpHP)
                continue
            int P1bi = array.get(dpHB, i)
            if P2bi <= P1bi
                continue
            int db = P2bi - P1bi
            if db < minBP
                continue
            if maxBP > 0 and db > maxBP
                continue
            if not na(lastBearA) and (P2bi - lastBearA) < cdBars
                continue

            float P1p = array.get(dpHP, i)

            bool regBear = enableRegular and (P2p > P1p)
            bool hidBear = enableHidden  and (P2p < P1p)

            if not regBear and not hidBear
                continue

            int conc = 0
            int oscN = 0

            if useRSI and i < array.size(dpHR)
                oscN += 1
                float P1r = array.get(dpHR, i)
                if regBear and P2r < P1r and P1r > obRSI
                    conc += 1
                else if hidBear and P2r > P1r
                    conc += 1

            if useStoch and i < array.size(dpHS)
                oscN += 1
                float P1s = array.get(dpHS, i)
                if regBear and P2s < P1s and P1s > obStoch
                    conc += 1
                else if hidBear and P2s > P1s
                    conc += 1

            if useMFI and i < array.size(dpHM)
                oscN += 1
                float P1m = array.get(dpHM, i)
                if regBear and P2m < P1m and P1m > obMFI
                    conc += 1
                else if hidBear and P2m > P1m
                    conc += 1

            if useROC and i < array.size(dpHO)
                oscN += 1
                float P1o = array.get(dpHO, i)
                if regBear and P2o < P1o
                    conc += 1
                else if hidBear and P2o > P1o
                    conc += 1

            bool isReg = regBear and conc >= minConc
            bool isHid = hidBear and conc >= minConc and not isReg

            if not isReg and not isHid
                continue

            if reqNI
                float pSlp = (P2p - P1p) / db
                bool pCr = false
                float pPD = 0.0
                for j = 1 to db - 1
                    int hO = bar_index - (P1bi + j)
                    if hO >= 0 and hO < 5000
                        float dev = high[hO] - (P1p + pSlp * j)
                        if j > 1 and pPD != 0.0 and math.sign(dev) != math.sign(pPD)
                            pCr := true
                        pPD := dev
                if pCr
                    continue

            // ═══════════ WAVE CONTEXT + FILTER GATE ═══════════

            [wCtx, trendP, sWPT, mWPT, lgWPT] = f_compositeWaveCtx(P2bi, isReg, false)

            // ── Wave type filter — reject before remaining fusion ──
            if not f_waveFilterPass(sWPT, mWPT, lgWPT, isReg)
                continue

            // ═══════════ BAYESIAN FUSION ═══════════

            float pConc = oscN > 0 ? conc * 1.0 / oscN : 0.5

            float rDelta = 0.0
            if useRSI and i < array.size(dpHR)
                rDelta := math.abs(P2r - array.get(dpHR, i))
            float rStd = ta.stdev(oRsi, 50)
            float zSc = rStd > 0 ? rDelta / rStd : 0.0
            float pZ = f_clamp(zSc / (zThr * 2.0), 0.05, 0.95)

            float pHur = curHurst < 0.5 ?
                 (0.5 + (0.5 - curHurst) * hurstMRw) :
                 (0.5 - (curHurst - 0.5) * hurstMRw)
            pHur := f_clamp(pHur, 0.05, 0.95)

            float pEnt = f_clamp(curEntropy, 0.05, 0.95)

            float oER = 1.0
            float midLo = na
            for li = 0 to math.min(array.size(dpLB) - 1, maxPivs - 1)
                int lb = array.get(dpLB, li)
                if lb > P1bi and lb < P2bi
                    float cp = array.get(dpLP, li)
                    if na(midLo) or cp < midLo
                        midLo := cp
            float prevLo = na
            for li = 0 to math.min(array.size(dpLB) - 1, maxPivs - 1)
                int lb = array.get(dpLB, li)
                if lb < P1bi
                    float cp = array.get(dpLP, li)
                    if na(prevLo) or cp < prevLo
                        prevLo := cp
            if not na(midLo) and not na(prevLo)
                float lL = math.abs(P2p - midLo) / math.max(1e-9, midLo)
                float pL = math.abs(P1p - prevLo) / math.max(1e-9, prevLo)
                oER := pL == 0 ? 5.0 : lL / pL
            float pOE = f_clamp((oER - 1.0) / 3.0, 0.05, 0.95)

            float L = priorLO
            L += wConc  * f_p2lo(pConc)
            L += wZsc   * f_p2lo(pZ)
            L += wHur   * f_p2lo(pHur)
            L += wEnt   * f_p2lo(pEnt)
            L += wWave  * f_p2lo(wCtx)
            L += wOvr   * f_p2lo(pOE)
            L += wTrend * f_p2lo(trendP)

            float post = f_lo2p(L)

            if post >= minPost
                lastBearA := P2bi
                if isReg
                    alertRegBear := true
                else
                    alertHidBear := true


                color sigCol = isReg ? regBearCol : hidBearCol

                string tag = ""
                if annType
                    tag := isReg ? "R↓" : "H↓"
                else
                    tag := isReg ? "Bear" : "H.Bear"
                if annConc
                    tag += " " + str.tostring(conc) + "/" + str.tostring(oscN)
                if annScore
                    tag += " " + str.tostring(math.round(post * 100)) + "%"
                if annWave
                    string swT = f_wvTxt(sWPT, "")
                    if swT != ""
                        tag += " " + swT
                    string mwT = f_wvTxt(mWPT, "m")
                    if mwT != "" and mWPT != sWPT
                        tag += "/" + mwT
                    string lwT = f_wvTxt(lgWPT, "L")
                    if lwT != "" and lgWPT != sWPT and lgWPT != mWPT
                        tag += "/" + lwT

                if showDivLn
                    line.new(P1bi, P1p, P2bi, P2p, xloc = xloc.bar_index,
                             color = sigCol, style = line.style_dotted, width = 2)
                if showLbl
                    label.new(P2bi, P2p, tag, yloc = yloc.abovebar,
                              style = label.style_label_down, color = color.new(sigCol, 40),
                              textcolor = color.white, size = size.small)
                if showTgt
                    float leg = na(midLo) ? math.abs(P2p - P1p) : math.abs(P2p - midLo)
                    if leg == 0
                        leg := atr14 * 2
                    f_pH(P2p - leg * 0.618, sigCol, "T1", P2bi, tgtExt, true)
                    f_pH(P2p - leg * 1.0,   sigCol, "T2", P2bi, tgtExt, true)
                    f_pH(P2p - leg * 1.618, sigCol, "T3", P2bi, tgtExt, true)
                    f_pH(P2p + syminfo.mintick * invTicks, color.gray, "Inv", P2bi, tgtExt, false)
                break

    array.unshift(dpHB, P2bi)
    array.unshift(dpHP, P2p)
    array.unshift(dpHR, P2r)
    array.unshift(dpHS, P2s)
    array.unshift(dpHM, P2m)
    array.unshift(dpHO, P2o)
    while array.size(dpHB) > maxPivs
        array.pop(dpHB)
        array.pop(dpHP)
        array.pop(dpHR)
        array.pop(dpHS)
        array.pop(dpHM)
        array.pop(dpHO)

// ============================================================================
// ============================= DASHBOARD ====================================
// ============================================================================

var table dash = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 80))
table.cell(dash, 0, 0, "Hurst",   text_color = color.white, text_size = size.tiny)
table.cell(dash, 1, 0, str.tostring(math.round(curHurst * 1000) / 1000),
           text_color = curHurst < 0.5 ? color.green : color.red, text_size = size.tiny)
table.cell(dash, 0, 1, "Entropy", text_color = color.white, text_size = size.tiny)
table.cell(dash, 1, 1, str.tostring(math.round(curEntropy * 1000) / 1000),
           text_color = curEntropy > 0.7 ? color.green : color.white, text_size = size.tiny)

string sWvTxt = sPosType == 1 ? "W5" : sPosType == 2 ? "Diag" : sPosType == 3 ? "W3" :
                 sPosType == 4 ? "W2" : sPosType == 5 ? "W4" : sPosType == 6 ? "CorrC" :
                 sPosType == 7 ? "TriE" : "—"
string mWvTxt = mPosType == 1 ? "W5" : mPosType == 2 ? "Diag" : mPosType == 3 ? "W3" :
                 mPosType == 4 ? "W2" : mPosType == 5 ? "W4" : mPosType == 6 ? "CorrC" :
                 mPosType == 7 ? "TriE" : "—"
string lWvTxt = lPosType == 1 ? "W5" : lPosType == 2 ? "Diag" : lPosType == 3 ? "W3" :
                 lPosType == 4 ? "W2" : lPosType == 5 ? "W4" : lPosType == 6 ? "CorrC" :
                 lPosType == 7 ? "TriE" : "—"

table.cell(dash, 0, 2, "Wave(S)", text_color = color.white, text_size = size.tiny)
table.cell(dash, 1, 2, sWvTxt,
           text_color = sPosScore >= 0.7 ? color.green : sPosScore <= 0.2 ? color.red : color.white,
           text_size = size.tiny)
table.cell(dash, 0, 3, "Wave(M)", text_color = color.white, text_size = size.tiny)
table.cell(dash, 1, 3, mWvTxt,
           text_color = mPosScore >= 0.7 ? color.green : mPosScore <= 0.2 ? color.red : color.white,
           text_size = size.tiny)
table.cell(dash, 0, 4, "Wave(L)", text_color = color.white, text_size = size.tiny)
table.cell(dash, 1, 4, lWvTxt,
           text_color = lPosScore >= 0.7 ? color.green : lPosScore <= 0.2 ? color.red : color.white,
           text_size = size.tiny)

// Refresh target lines
if array.size(tLn) > 0
    for i = 0 to array.size(tLn) - 1
        line ln = array.get(tLn, i)
        if not na(ln)
            int x1 = line.get_x1(ln)
            line.set_x2(ln, math.max(x1 + 1, x1 + tgtExt))


// ============================================================================
// ============================= ALERTS =======================================
// ============================================================================

alertcondition(alertRegBull, title="Regular Bullish Divergence", message='Regular Bullish Divergence on {{ticker}} at {{time}}. Price: {{close}}')
alertcondition(alertHidBull, title="Hidden Bullish Divergence", message='Hidden Bullish Divergence on {{ticker}} at {{time}}. Price: {{close}}')
alertcondition(alertRegBear, title="Regular Bearish Divergence", message='Regular Bearish Divergence on {{ticker}} at {{time}}. Price: {{close}}')
alertcondition(alertHidBear, title="Hidden Bearish Divergence", message='Hidden Bearish Divergence on {{ticker}} at {{time}}. Price: {{close}}')
````
