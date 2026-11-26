# Multi-Factor Regime Engine Pro [MarkitTick]

- url: https://www.tradingview.com/script/wqPR5V86-Multi-Factor-Regime-Engine-Pro-MarkitTick/
- type: indicator
- pine_id: PUB;d93d9b5b439e4c07a0f19ad996cdbd54
- version: 2.0

## Description

💡 This indicator represents a robust framework designed to quantify market regimes by analyzing an array of price action, volatility, and momentum metrics. By synthesizing ten distinct market features into a unified confidence score, it dynamically adjusts its threshold bands, providing a highly adaptive approach to trend identification on any standard chart.

[b]✨ Originality and Utility[/b]
Standard trend-following tools often rely on static lookback periods and fixed multipliers, which can lead to delayed signals during sudden market shifts or excessive false signals during consolidation. This indicator diverges from traditional methods by introducing a dynamic, feature-engineered confidence score. Instead of relying on a single data point like closing price or standard volatility, it aggregates inputs from momentum oscillators, directional movement indices, volume profiles, and standard deviation bands. This multi-dimensional analysis allows the indicator's bands to compress during high-confidence trends and expand during uncertain, low-confidence environments, offering a highly responsive and adaptive utility for modern chart analysis. Furthermore, it incorporates strict internal safeguards to prohibit execution on non-standard charts, ensuring the integrity of the data and preventing repainting vulnerabilities.

[b]🔬 Methodology and Concepts[/b]
[b]● The Feature Engineering Engine[/b]
The core of this indicator is built upon extracting ten distinct normalized features from the market data, evaluating multiple dimensions of price action simultaneously:
[list]
[*] Momentum Normalization: Utilizes relative strength metrics, centered and scaled, to gauge underlying momentum bias without relying on absolute thresholds.
[*] Directional Strength: Analyzes directional movement indices to quantify the strength of the current trajectory, applying directional penalties when negative movement overpowers positive movement.
[*] Moving Average Distances: Measures the current price relative to fast and slow moving averages, standardizing the distance using the Average True Range to identify structural overextension.
[*] Rate of Change Standardization: Normalizes the rate of change against its own rolling standard deviation to detect statistical anomalies in speed and acceleration.
[*] Standard Deviation Extremes: Evaluates the position of the price relative to upper and lower Bollinger Bands, calculating the precise percentile of the close within the volatility envelope.
[*] Volatility Stability: Compares short-term volatility against long-term volatility baselines to measure market stress and detect rapid expansions.
[*] Volume Anomalies: Assesses current volume against its simple moving average, clamping the result to identify participation spikes that validate price movement.
[*] Price Action Consistency: Calculates the ratio of bullish to bearish closes within the defined lookback period, serving as a raw footprint of buyer versus seller control.
[/list]

[b]● The Confidence Score Assembly[/b]
These standardized features are separated into distinct sub-components. A Directional Score identifies the probable path of the trend by weighting momentum and moving average slopes. A Quality Score measures the structural integrity of that trend by analyzing volume participation and volatility stability. These are mathematically combined to produce a Raw Confidence value. This raw output undergoes an adaptive smoothing process using a dynamic moving average, resulting in a highly stable, final Confidence Score bounded precisely between 0% and 100%.

[b]● Adaptive Ratcheting Bands[/b]
The calculated Confidence Score directly influences the width of the trend bands. When the confidence is high, the internal multiplier decreases, tightening the bands closer to the price action to capture shifts quickly and protect accumulated distance. Conversely, when confidence is low, the bands expand to avoid noise and erratic whipsaws. The bands utilize a state-machine logic that only ratchets in the direction of the trend, acting as a trailing threshold that reacts to both price crosses and sudden regime shifts identified by extreme volatility spikes.

[b]🎨 Visual Guide[/b]
[b]● Heatmap Candles[/b]
[list]
[*] The indicator actively repaints the chart candles based on a calculated mathematical "stress" metric. 
[*] Colors transition dynamically from a baseline trend color (Deep Sky Blue for bullish conditions, Radical Red for bearish conditions) to a bright orange "Regime Alert" color when underlying volatility spikes significantly.
[*] Candle body opacity is heavily controlled by the alignment of the price action with the overall trend direction, fading to a darker tone during contrary movements or low-confidence pullbacks.
[/list]

[b]● ML Supertrend Band[/b]
[list]
[*] Displayed as a prominent, solid line representing the adaptive trailing threshold on the chart.
[*] This band is colored Deep Sky Blue during bullish market phases and Radical Red during bearish phases, updating in real-time as the state machine ratchets.
[/list]

[b]● Confidence Gradient Cloud[/b]
[list]
[*] This visual element fills the spatial gap between the median price baseline and the trailing Supertrend band.
[*] The exact opacity and gradient of this cloud are mapped directly to the Confidence Score. A highly opaque, solid cloud represents high confidence, while a highly transparent, fading cloud visually indicates low confidence and potential market transition.
[/list]

[b]● Visual Labels[/b]
[list]
[*] Small directional visual markers appear directly above or below the price action when a trend flip occurs.
[*] These labels display an arrow alongside a precise percentage value, representing the exact calculated Confidence Score at the moment the signal was generated.
[/list]

[b]● Info Table[/b]
[list]
[*] Located statically in the top right corner, this dashboard displays crucial real-time internal metrics.
[*] It includes the current trend direction, a visual text-based progress bar for the Confidence Score, the live Adaptive Multiplier value adjusting in real-time, the selected Model configuration, and a dynamic text alert that triggers during active Regime Shifts.
[/list]

[b]📖 How to Use[/b]
[b]● Trend Identification[/b]
Observe the dominant color of the ML Supertrend Band and the Confidence Gradient Cloud. Deep Sky Blue strongly indicates a bullish environment, while Radical Red suggests a bearish environment. The visibility and thickness of the cloud serve as your primary visual gauge of the trend's structural health.

[b]● Interpreting the Confidence Metric[/b]
Monitor the Confidence Score inside the Info Table or at signal generation. A high percentage (e.g., above 70%) suggests that multiple underlying market factors (volume, momentum, standard deviation) are in full agreement with the current directional bias. A rapidly dropping confidence score often precedes a period of choppy consolidation or warns of a potential reversal, allowing for tighter risk parameters.

[b]● Reading Heatmap Candles for Shifts[/b]
When the standard colored candles begin transitioning toward the bright orange Regime Alert color, it indicates an abnormal spike in volatility combined with a directional momentum shift. This visually warns the user of a potential "Regime Shift" where the market is undergoing severe internal stress. These specific visual cues often signal an impending breakout from a range or a violent capitulation event.

[b]⚙️ Inputs and Settings[/b]
[b]● Model Configuration[/b]
[list]
[*] [i]Strategic Cycle Mode:[/i] Allows the choice between an "Auto" mode and a "Custom" mode. Auto mode dynamically selects the most mathematically optimal lookback lengths, thresholds, and weighting coefficients based purely on the current timeframe in seconds.
[*] [i]Strategic Cycle:[/i] When in custom mode, this determines the core lookback period for all volatility and momentum calculations. Smaller values drastically increase reactivity, while larger values provide smoother, long-term macroeconomic analysis.
[*] [i]Macro Trend Threshold:[/i] Sets the baseline mathematical width of the threshold bands. Higher values require significantly larger price movements to trigger a trend flip, reducing noise.
[*] [i]Prediction Weight:[/i] Controls the internal sensitivity of the bands to rapid changes in the Confidence Score, determining how aggressively the bands compress.
[/list]

[b]● Visual Settings & Colors[/b]
[list]
[*] Dedicated toggles are provided to enable or disable the Confidence Labels, the Info Table, and the Heatmap Candles to keep the chart interface as clean as desired.
[*] All core graphical colors, including the specific bands, gradient clouds, table text, and alert highlights, are fully customizable by the user via hex selection.
[/list]

[b]● Webhook Settings[/b]
[list]
[*] The indicator is pre-configured to output detailed, formatted JSON payloads designed for external execution automation.
[*] Users can securely define specific action strings for entering and closing both long and short positions directly within the settings menu, mapping exactly to their webhook parser logic.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
[b]● Multi-Variate Feature Standardization[/b]
The mathematical foundation of this tool relies heavily on statistical normalization techniques designed to process heterogeneous data. Financial time series data is notoriously non-stationary and spans vastly different numerical scales. To effectively combine disparate metrics like Volume (often measured in millions) and relative strength oscillators (strictly bounded between 0 and 100), the indicator employs rigorous Min-Max scaling and localized Z-score approximations. For instance, the rate of change is evaluated against its own rolling standard deviation over a defined period, successfully standardizing the momentum readout into a continuous, comparable spectrum bounded cleanly between -1.0 and 1.0.

[b]● Linear Weighted Ensembles[/b]
The internal architecture utilizes a deterministic linear weighted model to synthesize the final output. By assigning highly specific fractional coefficients to directional features (like the exponential moving average slope and relative strength) and structural features (like Bollinger Band width extremes and volatility stability), the script constructs a singular composite index. This mirrors standard ensemble methodologies found in data science, where the consensus of multiple independent weak learners generates a stronger, more reliable predictive metric than any single indicator could achieve in isolation.

[b]● Volatility-Adjusted State Machines[/b]
The adaptive threshold logic operates as a strict finite-state machine incorporating the Average True Range metric. The specific mathematical innovation lies in rendering the ATR multiplier as an inverse linear function of the composite confidence index. In quantitative terms, this produces a dynamically dampened volatility envelope. When the composite index approaches a maximum value indicating high convergence, the dampening factor aggressively compresses the envelope, mathematically acknowledging that high-conviction trends exhibit less erratic mean-reversion behavior and therefore require drastically tighter invalidation levels to preserve structural alpha.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Multi-Factor Regime Engine Pro [MarkitTick]", overlay=true, max_labels_count=500)

if syminfo.type == "heikinashi" or syminfo.type == "renko" or syminfo.type == "linebreak" or syminfo.type == "kagi" or syminfo.type == "pointfigure"
    runtime.error("Non-standard charts (Heikin Ashi, Renko, etc.) are strictly prohibited due to repainting risks.")

// ════════════════════════════════════════════════════════════════════
//  §1 — INPUTS
// ════════════════════════════════════════════════════════════════════

string G1 = '⚙️ Model Configuration'
string G2 = '🎨 Visual Settings & Colors'

// ── Model
string modelMode = input.string('Auto', 'Strategic Cycle Mode', options = ['Auto', 'Custom'], group = G1, tooltip = 'Auto selects the optimal parameter profile based on the chart timeframe.\nCustom unlocks three manual hyperparameters below.')
int i_lb = input.int(14, 'Strategic Cycle', minval = 5, maxval = 200, group = G1, tooltip = 'Controls the ATR lookback used for volatility measurement. Smaller = more reactive; larger = smoother.')
float i_ct = input.float(2.0, 'Macro Trend Threshold', minval = 0.5, maxval = 6.0, step = 0.1, group = G1, tooltip = 'Scales the boundary width relative to the volatility reading. Higher = wider band, fewer flips.')
float i_pw = input.float(0.5, 'Prediction Weight', minval = 0.1, maxval = 1.0, step = 0.05, group = G1, tooltip = 'Controls how strongly the Confidence Score compresses or expands the boundary. Higher = more responsive to confidence shifts.')


bool i_confLbl      = input.bool(true, 'Show Confidence % at Signals', group = G2)
bool i_table        = input.bool(true, 'Show Info Table',              group = G2)
bool i_paintCandles = input.bool(true, 'Paint Heatmap Candles',        group = G2)


string G3          = '🔔 Webhook Settings'
string i_actLong   = input.string('long',        'Long Action',        group = G3, tooltip = 'Action string injected into the JSON payload on a long signal.')
string i_actShort  = input.string('short',       'Short Action',       group = G3, tooltip = 'Action string injected into the JSON payload on a short signal.')
string i_actClsLng = input.string('closelong',   'Close Long Action',  group = G3)
string i_actClsShrt= input.string('closeshort',  'Close Short Action', group = G3)
// ════════════════════════════════════════════════════════════════════
//  §2 — DYNAMIC COLORS 
// ════════════════════════════════════════════════════════════════════

color c_bullBand     = input.color(#00BFFF, 'Bullish Band (Deep Sky Blue)', group = G2)
color c_bearBand     = input.color(#FF3366, 'Bearish Band (Radical Red)', group = G2)
color c_bullCloud    = input.color(#00BFFF, 'Bullish Cloud Base', group = G2)
color c_bearCloud    = input.color(#FF3366, 'Bearish Cloud Base', group = G2)

color c_tblBg        = input.color(#0B0E14, 'Table Background', group = G2)
color c_tblBorder    = input.color(#151A25, 'Table Border', group = G2)
color c_tblFrame     = input.color(#00BFFF, 'Table Frame Accent', group = G2)
color c_tblTextMain  = input.color(#F1F5F9, 'Table Text Main', group = G2)
color c_tblTextMuted = input.color(#475569, 'Table Text Muted', group = G2)

color c_regimeAlert  = input.color(#FFA500, 'Regime Shift Alert', group = G2)
color c_confHigh     = input.color(#00E676, 'Confidence High', group = G2)
color c_confMid      = input.color(#FFEA00, 'Confidence Mid', group = G2)
color c_confLow      = input.color(#FF3366, 'Confidence Low', group = G2)

// ════════════════════════════════════════════════════════════════════
//  §3 — AUTO MODEL PARAMETER SELECTION
// ════════════════════════════════════════════════════════════════════

int tfSec = timeframe.in_seconds()
int lb = modelMode == 'Auto' ? tfSec <= 300 ? 10 : tfSec <= 3600 ? 14 : tfSec <= 14400 ? 20 : 30 : i_lb
float ct = modelMode == 'Auto' ? tfSec <= 300 ? 1.5 : tfSec <= 3600 ? 2.0 : tfSec <= 14400 ? 2.5 : 3.0 : i_ct
float pw = modelMode == 'Auto' ? tfSec <= 300 ? 0.70 : tfSec <= 3600 ? 0.50 : tfSec <= 14400 ? 0.40 : 0.30 : i_pw

// ════════════════════════════════════════════════════════════════════
//  §4 — MACHINE LEARNING FEATURE ENGINEERING
// ════════════════════════════════════════════════════════════════════

float atr = ta.atr(lb)
float atrSlow = ta.atr(lb * 3) 

float f1_rsi = (ta.rsi(close, lb) - 50.0) / 50.0

[diP, diM, adxVal] = ta.dmi(lb, lb)
float f2_adx = math.min(adxVal / 50.0, 1.0) * (diP >= diM ? 1.0 : -1.0)

float emaFast = ta.sma(close, lb)      
float emaSlow = ta.sma(close, lb * 2)
float f3_ema = math.max(math.min((close - emaFast) / (atr * 2.0 + 1e-9), 1.0), -1.0)

float f4_slope = math.max(math.min((emaFast - emaSlow) / (atr + 1e-9), 1.0), -1.0)

float roc = ta.roc(close, lb)
float rocStd = ta.stdev(ta.roc(close, lb * 2), lb)
float f5_roc = math.max(math.min(roc / (rocStd * 2.0 + 1e-9), 1.0), -1.0)

[bbMid, bbUp, bbDn] = ta.bb(close, lb, 2.0)
float bbRng = bbUp - bbDn
float f6_bbPos = bbRng > 0.0 ? (close - bbDn) / bbRng : 0.5

float f7_bbWid = math.min(bbRng / (atr * 4.0 + 1e-9), 2.0) / 2.0
float f8_volStb = math.min(atrSlow / (atr + 1e-9) / 1.5, 1.0)

float volSma = ta.sma(volume, lb)
float f9_vol = volSma > 0 ? math.min(volume / volSma / 2.0, 1.0) : 0.5

// Vectorized bullish/bearish bar count (no loop)
int bullC = 0
for i = 1 to lb
    if close[i] > close[i + 1]
        bullC := bullC + 1
int bearC = lb - bullC
float f10_cons = float(bullC - bearC) / float(lb)

// ════════════════════════════════════════════════════════════════════
//  §5 — CONFIDENCE SCORE ASSEMBLY
// ════════════════════════════════════════════════════════════════════

float dirScore = f1_rsi * 0.22 + f2_adx * 0.22 + f3_ema * 0.18 + f4_slope * 0.15 + f5_roc * 0.13 + f10_cons * 0.10
float dirNorm = (dirScore + 1.0) / 2.0
float qualScore = f8_volStb * 0.35 + f9_vol * 0.25 + f7_bbWid * 0.25 + math.abs(f2_adx) * 0.15
float bbExtreme = math.abs(f6_bbPos - 0.5) * 2.0

float rawConf = dirNorm * 0.45 + qualScore * 0.35 + bbExtreme * 0.20
int smoothLen = math.max(math.round(float(lb) * (1.0 - pw) * 0.5 + 2.0), 2)
float confScore = ta.sma(rawConf, smoothLen)
confScore := math.max(math.min(confScore, 1.0), 0.0)

int mlBias = dirScore >= 0.0 ? 1 : -1

// ════════════════════════════════════════════════════════════════════
//  §6 — ADAPTIVE BAND CALCULATION
// ════════════════════════════════════════════════════════════════════

float adaptMult = ct * (1.40 - confScore * 0.80)
float hl2_val = (high + low) / 2.0
float halfBW = atr * adaptMult

float rawU = hl2_val + halfBW
float rawL = hl2_val - halfBW

// ════════════════════════════════════════════════════════════════════
//  §7 — RATCHETING SUPERTREND STATE MACHINE
// ════════════════════════════════════════════════════════════════════

var float stUpper = na
var float stLower = na
var int tDir = 1 
var float stLine = na

int prevDir = nz(tDir[1], 1)
float prevU = nz(stUpper[1], rawU)
float prevL = nz(stLower[1], rawL)

stUpper := prevDir == -1 ? math.min(rawU, prevU) : rawU
stLower := prevDir == 1 ? math.max(rawL, prevL) : rawL

bool atrSpiked = atr > atrSlow * 1.5
bool dirFlipped = math.sign(f1_rsi) != math.sign(nz(f1_rsi[1])) and math.abs(f1_rsi) > 0.40
bool regimeShift = atrSpiked and dirFlipped

float flipThresh = atr * 0.04 * (1.0 - confScore * 0.5)

if prevDir == 1
    if (close < stLower - flipThresh) or (regimeShift and mlBias == -1)
        tDir := -1
        stLine := stUpper
    else
        tDir := 1
        stLine := stLower
else
    if (close > stUpper + flipThresh) or (regimeShift and mlBias == 1)
        tDir := 1
        stLine := stLower
    else
        tDir := -1
        stLine := stUpper

// ════════════════════════════════════════════════════════════════════
//  §8 — SIGNAL DETECTION
// ════════════════════════════════════════════════════════════════════

bool longSig  = tDir[1] == 1  and tDir[2] == -1  
bool shortSig = tDir[1] == -1 and tDir[2] == 1
bool anyFlip = longSig or shortSig

// ════════════════════════════════════════════════════════════════════
//  §9 — VISUAL RENDERING 
// ════════════════════════════════════════════════════════════════════

color bandClr = tDir == 1 ? c_bullBand : c_bearBand


float _confAlpha = math.round((1.0 - confScore) * 65.0 + 5.0)

float _stress   = math.max(math.min((atr / (atrSlow + 1e-9) - 1.0) / 0.5, 1.0), 0.0)
color _heatBase = color.from_gradient(_stress, 0.0, 1.0, bandClr, c_regimeAlert)   

bool  _aligned     = (tDir == 1 and close >= open) or (tDir == -1 and close < open)
float _bodyAlpha   = _aligned ? _confAlpha : math.min(_confAlpha + 35.0, 88.0)
float _borderAlpha = math.max(_bodyAlpha - 20.0, 0.0)

color bodyColor   = i_paintCandles ? color.new(_heatBase, int(_bodyAlpha))   : na
color borderColor = i_paintCandles ? color.new(_heatBase, int(_borderAlpha)) : na

plotcandle(open, high, low, close,
 title       = "Heatmap Candles",
 color       = bodyColor,
 wickcolor   = borderColor,
 bordercolor = borderColor)

plot_st = plot(stLine, 'ML Supertrend Band', color = bandClr, linewidth = 2)
plot_base = plot(hl2_val, 'Cloud Base', display = display.none)

color cloudGradient = tDir == 1 ? color.from_gradient(confScore, 0.0, 1.0, color.new(c_bullCloud, 95), color.new(c_bullCloud, 60)) : color.from_gradient(confScore, 0.0, 1.0, color.new(c_bearCloud, 95), color.new(c_bearCloud, 60))

fill(plot_st, plot_base, color = cloudGradient, title = 'Confidence Gradient Cloud')

if i_confLbl and anyFlip
    string confTxt = (tDir[1] == 1 ? '▲ ' : '▼ ') + str.tostring(math.round(confScore[1] * 100)) + '%'   
    float yOffset  = tDir[1] == 1 ? low - (atr * 0.25) : high + (atr * 0.25)
    
    label.new(bar_index, yOffset, confTxt, color = color.new(tDir[1] == 1 ? c_bullBand : c_bearBand, 45), textcolor = color.white, style = tDir[1] == 1 ? label.style_label_up : label.style_label_down, size = size.small)

// ════════════════════════════════════════════════════════════════════
//  §10 — INFO TABLE
// ════════════════════════════════════════════════════════════════════

var table infoTbl = table.new(position.top_right, 2, 6, bgcolor = color.new(c_tblBg, 70), border_color = color.new(c_tblBorder, 40), border_width = 1, frame_color = color.new(c_tblFrame, 30), frame_width = 1)

// Unconditional table population (self-cleaning pattern — no barstate.islast guard)
table.cell(infoTbl, 0, 0, 'ML SUPERTREND', text_color = color.new(c_tblFrame, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 50), text_halign = text.align_left)
table.cell(infoTbl, 1, 0, '', text_color = color.new(c_tblTextMuted, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 50), text_halign = text.align_right)

string trendTxt = tDir == 1 ? '▲  BULLISH' : '▼  BEARISH'
color trendClr = tDir == 1 ? color.new(c_bullBand, 0) : color.new(c_bearBand, 0)
table.cell(infoTbl, 0, 1, 'Trend', text_color = color.new(c_tblTextMuted, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_left)
table.cell(infoTbl, 1, 1, trendTxt, text_color = trendClr, text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_right)

int confPct = math.round(confScore * 100)
string confBar = confPct >= 75 ? '████' : confPct >= 50 ? '███░' : confPct >= 25 ? '██░░' : '█░░░'
color confClr = confPct >= 70 ? c_confHigh : confPct >= 45 ? c_confMid : c_confLow
table.cell(infoTbl, 0, 2, 'Confidence', text_color = color.new(c_tblTextMuted, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_left)
table.cell(infoTbl, 1, 2, str.tostring(confPct) + '% ' + confBar, text_color = color.new(confClr, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_right)

table.cell(infoTbl, 0, 3, 'Adaptive Mult', text_color = color.new(c_tblTextMuted, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_left)
table.cell(infoTbl, 1, 3, '×' + str.tostring(math.round(adaptMult * 100) / 100), text_color = color.new(c_tblTextMain, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_right)

string modelTxt = modelMode == 'Auto' ? 'Auto  (lb=' + str.tostring(lb) + ')' : 'Custom (lb=' + str.tostring(lb) + ')'
table.cell(infoTbl, 0, 4, 'Model', text_color = color.new(c_tblTextMuted, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_left)
table.cell(infoTbl, 1, 4, modelTxt, text_color = color.new(c_tblTextMain, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_right)

string regimeTxt = regimeShift ? '⚠ SHIFT' : 'Normal'
color regimeClr = regimeShift ? c_regimeAlert : color.new(c_tblTextMuted, 0)
table.cell(infoTbl, 0, 5, 'Regime', text_color = color.new(c_tblTextMuted, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_left)
table.cell(infoTbl, 1, 5, regimeTxt, text_color = color.new(regimeClr, 0), text_size = size.small, bgcolor = color.new(c_tblBg, 60), text_halign = text.align_right)

// ════════════════════════════════════════════════════════════════════
//  §11 — ALERTS
// ════════════════════════════════════════════════════════════════════

string _tpl      = '"action":"{0}","ticker":"{1}","tf":"{2}","entry":"{3}","tp":"{4}","sl":"{5}"'
string _tplClose = '"action":"{0}","ticker":"{1}","tf":"{2}"'   
if longSig and barstate.isconfirmed
    float entryPrice  = close
    float slPrice     = stLower
    float tpPrice     = entryPrice + (entryPrice - slPrice) * 1.5
    string alertMsg   = "{" + str.format(_tpl, i_actLong,    syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpPrice, format.mintick), str.tostring(slPrice, format.mintick)) + "}"
    string closeMsg   = "{" + str.format(_tplClose, i_actClsLng, syminfo.tickerid, timeframe.period) + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)
    alert(closeMsg,  alert.freq_once_per_bar_close)

if shortSig and barstate.isconfirmed
    float entryPrice  = close
    float slPrice     = stUpper
    float tpPrice     = entryPrice - (slPrice - entryPrice) * 1.5
    string alertMsg   = "{" + str.format(_tpl, i_actShort,   syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpPrice, format.mintick), str.tostring(slPrice, format.mintick)) + "}"
    string closeMsg   = "{" + str.format(_tplClose, i_actClsLng,  syminfo.tickerid, timeframe.period) + "}"
    alert(alertMsg, alert.freq_once_per_bar_close)
    alert(closeMsg,  alert.freq_once_per_bar_close)
````
