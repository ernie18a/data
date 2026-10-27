# Alpha Council - Non-Causality Suite

- url: https://www.tradingview.com/script/Sv12WJc1-Alpha-Council-Non-Causality-Suite/
- type: indicator
- pine_id: PUB;95aef27776ca40818109a849d98598e7
- version: 2.0

## Description

Alpha Council - Non-Causality Suite: PRC & AMD Synthesis

Overview

The Non-Causality Suite is an advanced, multi-dimensional analytical tool designed to identify liquidity sweeps, structural market transitions, and statistical extremes. Traditional indicators often rely on heavily lagging averages, leaving traders vulnerable to sudden market shifts. This suite bypasses traditional chronological lag by integrating a Polynomial Regression Channel (PRC), an Accumulation, Manipulation, Distribution (AMD) microstructure tracker, and a robust Adverse Cascade Vulnerability (ACV) filtering system.

This indicator does not provide automated trading or guaranteed signals; rather, it acts as a "diagnostic dashboard" for the chart's current structural and kinematic state, allowing traders to visualize exactly when a market is overextended and whether that overextension is being absorbed by limit orders.

Core Mechanics: How It Works

This suite is built on three primary mathematical and behavioral pillars:

1. The Spatial Map: Polynomial Regression Channel (PRC)

Instead of using standard moving averages or rigid envelopes that suffer from "curve accommodation" (bending too slowly to extreme wicks), this suite utilizes an Ordinary Least Squares (OLS) Matrix Inversion.

The script continuously calculates a 2nd-degree (or higher) polynomial curve to fit the immediate momentum of the data.

This generates a fast-twitch "net" (the PRC) that dynamically expands based on local volatility. It snaps to liquidation wicks instantly, providing a highly responsive boundary for statistical extremes.

2. Behavioral Structure: AMD Liquidity Tracking

Markets, especially highly leveraged ones, are driven by liquidity hunting. The suite maps this via the AMD (Accumulation, Manipulation, Distribution) cycle:

Accumulation: The script tracks rolling Swing Highs and Swing Lows to identify tight, localized ranges where stop-losses are clustered.

Manipulation (The Sweep): When price violently breaks out of this accumulation box and simultaneously pierces the outer bands of the PRC, it is flagged as a potential manipulation sweep (liquidity grab).

Distribution (The Reclaim): The suite waits for the price to reject the extreme and close back inside the accumulation zone before confirming the structural shift.

3. Defense Vault: Adverse Cascade Vulnerability (ACV)

The most significant danger in trading extremes is stepping in front of a "falling knife" or a macro-liquidation cascade. The ACV Vault is a series of mathematical gates designed to lock the system down during these events:

The Pulse Engine: Measures the kinematic saturation (inertia) of the market. If downside momentum reaches maximum saturation, the system visually warns of a cascade and locks out bullish structural signals.

Effort vs. Result (Absorption): A volume-anomaly tracker. It requires proof that limit orders are absorbing the panic (e.g., a massive volume spike resulting in a tight doji candle) before validating a sweep.

Micro-Structure ChoCh: Requires the price to physically break the previous candle's pivot, proving a localized change of character.

How to Use This Indicator

This tool is designed to provide deep contextual awareness. Here is how to interpret its outputs:

AMD Sweep Markers (▲ / ▼): These markers print on the main chart when the criteria for an AMD liquidity sweep are perfectly met—meaning price has breached an accumulation zone, pierced the non-causal PRC boundary, and survived the ACV safety filters.

The Tactical HUD: The built-in dashboard provides real-time verdicts on the market's state. Monitor the "STATE" row:

ARMED: The market has hit a statistical extreme and is showing signs of structural absorption.

ACV LOCKDOWN: The market is in an uncontrolled freefall or blow-off top. Do not attempt to catch the extreme; wait for the Pulse Engine to decay and absorption to appear.

Subpane Kinematics: The lower oscillator pane visualizes the underlying market cycles using Nadaraya-Watson kernels and Hilbert Transforms, helping you identify phase shifts between bullish and bearish control.

Settings & Customization

Topological Window: Adjusts the primary lookback length for the baseline digital signal processing.

PRC Settings: Control the 'Degree' and 'Multiplier' of the Polynomial Regression Channel to suit the volatility of your specific asset.

ACV Handlers: You can individually toggle the safety filters (Time Exhaustion, G-Force Acceleration, Effort vs. Result) to make the indicator more or less restrictive based on your trading style.

Disclaimer: This script is strictly for educational and analytical purposes. Past performance of specific mathematical models does not guarantee future results in live trading environments.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// Original Whittaker Concept: LuxAlgo
// WESO, Web, Hilbert, IKB, HP & SG Hacks: THE ALPHA COUNCIL

//@version=6
indicator("Alpha Council - Non-Causality Suite", "Alpha Council - Non-Causal Suite", overlay = false, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_polylines_count = 100, max_bars_back = 5000)

//---------------------------------------------------------------------------------------------------------------------}
// THE CONSULTANT'S KINEMATIC PARAMETERS
//---------------------------------------------------------------------------------------------------------------------{
int   LENGTH_MIN    = 5
float LAMBDA_MIN    = 0.1
int   ITERS_MAX     = 50

string SETTINGS_GRP = "Causal & Structural Settings"
lengthInput         = input.int(400,    "Topological Window (Length)",    minval = LENGTH_MIN,    group = SETTINGS_GRP)
lambdaInput         = input.float(1000, "Kinematic Smoothness (λ)",       minval = LAMBDA_MIN,    group = SETTINGS_GRP)
pLowerInput         = input.float(0.001,"Lower Asymmetry Boundary (p)",   minval = 0.0, maxval = 0.5, step = 0.001, group = SETTINGS_GRP)
pUpperInput         = input.float(0.999,"Upper Asymmetry Boundary (p)",   minval = 0.5, maxval = 1.0, step = 0.001, group = SETTINGS_GRP)
webBandsInput       = input.int(4,      "Webbing Layers (Interpolations)",minval = 1,   maxval = 50, group = SETTINGS_GRP)

string PRC_GRP      = "Polynomial Regression Channel (PRC)"
prcEnable           = input.bool(true,  "Enable PRC Matrix Overlay",      group = PRC_GRP)
prcLength           = input.int(100,    "Period", minval = 2, maxval=200, group = PRC_GRP)
prcDegree           = input.int(4,      "Degree", minval = 1, maxval=10,  group = PRC_GRP)
prcMult             = input.float(2.0,  "PRC Channel Width Multiplier",   minval = 0.1, step = 0.1, group = PRC_GRP)

string AMD_GRP      = "Structural Behavioral Mapping (AMD Sessions)"
amdEnable           = input.bool(true,  "Enable AMD Accumulation Tracking", group=AMD_GRP)
sess_asia           = input.session("0000-0800", "Accumulation Session (Asia)", group=AMD_GRP)
sess_lon            = input.session("0800-1600", "Manipulation Session (London)", group=AMD_GRP)
sess_ny             = input.session("1300-2100", "Distribution Session (NY)", group=AMD_GRP)

string NW_GRP       = "Nadaraya-Watson Non-Causal Core"
nwBandwidthInput    = input.float(8.0,  "Gaussian Kernel Bandwidth (h)",  minval = 0.1, step=0.5, group = NW_GRP)
nwEnvEnable         = input.bool(true,  "Enable NW Attractor Envelopes",  group = NW_GRP, tooltip="Adds a secondary double-boundary layer wrapping the NW attractor using NW-smoothed absolute deviations.")
nwEnvMult           = input.float(1.5,  "NW Envelope Multiplier",         minval = 0.1, step=0.1, group = NW_GRP)

string MACRO_GRP    = "Macro & Polynomial Filters"
hpEnable            = input.bool(true,  "Enable Hodrick-Prescott (HP) Filter", group = MACRO_GRP)
hpLambda            = input.float(10000,"HP Filter Lambda (Macro Trend)", minval = 1.0, group = MACRO_GRP)
sgEnable            = input.bool(true,  "Enable Savitzky-Golay (SG) Filter", group = MACRO_GRP)
sgLength            = input.int(15,     "SG Filter Window (Must be odd)", step=2, minval=5, group = MACRO_GRP)

string HMM_GRP      = "Baum-Welch HMM Regime"
hmmEnable           = input.bool(true,  "Enable Non-Causal HMM Regime Ribbon", group = HMM_GRP)
hmmBgEnable         = input.bool(true,  "Enable HMM Background Fill (Main Chart)", group = HMM_GRP)

string WESO_GRP     = "WESO Oscillator Mechanics"
emaLenInput         = input.int(5,      "Signal Line Smoothing (EMA)",    minval = 1,             group = WESO_GRP)
slopeScaleInput     = input.float(8.0,  "Slope Gradient Multiplier",      minval = 1.0,           group = WESO_GRP)
sqzThresholdInput   = input.float(0.4,  "Squeeze Compression Ratio",      minval = 0.1, step=0.1, group = WESO_GRP)

string VOL_GRP      = "Microstructure Squeeze Mechanics"
volLenInput         = input.int(20,     "Volume Z-Score Window",          minval = 2,                 group = VOL_GRP)
volScaleInput       = input.float(0.35, "Volume Sensitivity Scale",       minval = 0.0, step = 0.05,  group = VOL_GRP)

string HILBERT_GRP  = "Hilbert Transform (Phase Space)"
hilbertEnable       = input.bool(true,  "Enable Hilbert Sine/Lead Wave",  group = HILBERT_GRP)

string IKB_GRP      = "Inverse Kernel Bounding (Multiverse)"
ikbEnable           = input.bool(true,  "Enable IKB Probability Mesh", group = IKB_GRP)
ikbPaths            = input.int(50,     "Generated Seeds (Multiverse)", minval = 10, maxval = 200, group = IKB_GRP)
ikbLength           = input.int(15,     "Projection Length", minval = 5, maxval = 50, group = IKB_GRP)
ikbBoundMult        = input.float(1.5,  "Kinematic Limit Tolerance (BoundMult)", minval = 1.0, group = IKB_GRP)

string COMPUTE_GRP  = "Execution & Compute Limits"
itersInput          = input.int(10,     "ALS Iterations (Brute-Force)",   minval = 1,   maxval = ITERS_MAX,  group = COMPUTE_GRP)

string CAUSAL_GRP   = "Causal Execution Layer (HUD & Triggers)"
longOnly            = input.bool(false, "Long-Only Mode", group = CAUSAL_GRP, tooltip="Disables all short entries and signals.")
causalMode          = input.string("Institutional", "Execution Mode", options=["Retail", "Institutional"], group=CAUSAL_GRP, tooltip="Retail uses standard oscillators. Institutional uses the 24x Meta-Mean Volume Anomaly Consensus adaptation.")
tf1_inp             = input.timeframe("",    "Base Timeframe (TF1)", group = CAUSAL_GRP)
tf2_inp             = input.timeframe("5",   "Timeframe 2 (TF2)",    group = CAUSAL_GRP)
tf3_inp             = input.timeframe("60",  "Timeframe 3 (TF3)",    group = CAUSAL_GRP)
tf4_inp             = input.timeframe("240", "Timeframe 4 (TF4)",    group = CAUSAL_GRP)

useExec             = input.bool(true,  "Enable CVD Divergence", group = CAUSAL_GRP)
useObvExec          = input.bool(true,  "Enable OBV Divergence", group = CAUSAL_GRP)
useRsiExec          = input.bool(true,  "Enable RSI Extremes", group = CAUSAL_GRP)
useSrsiExec         = input.bool(true,  "Enable Stoch RSI Snaps", group = CAUSAL_GRP)
useMacdExec         = input.bool(true,  "Enable MACD Convergence", group = CAUSAL_GRP)
useAroonExec        = input.bool(true,  "Enable Aroon Extremes", group = CAUSAL_GRP)
usePremExec         = input.bool(false, "Enable Premium Index Snap", group = CAUSAL_GRP)
premTicker          = input.symbol("BINANCE:BTCUSDT_PREMIUM", "Premium Index Ticker", group = CAUSAL_GRP)
premThreshold       = input.float(2.0,  "Premium Threshold", minval = 0.1, group = CAUSAL_GRP)
useOiExec           = input.bool(false, "Enable Open Interest Exhaustion", group = CAUSAL_GRP)
oiTicker            = input.symbol("BINANCE:BTCUSDT.P_OI", "Open Interest Ticker", group = CAUSAL_GRP)
useUsdtExec         = input.bool(false, "Enable Macro Capital (USDT.D)", group = CAUSAL_GRP)
usdtTicker          = input.symbol("CRYPTOCAP:USDT.D", "Macro Capital Ticker", group = CAUSAL_GRP)
useVwapExec         = input.bool(false, "Enable Anchor-State VWAP Reclaim (TF1 Only)", group = CAUSAL_GRP)

string ACV_GRP      = "Adverse Cascade Vulnerability (ACV) Handlers"
useAcvChoch         = input.bool(true,  "Enable Micro-Structure ChoCh (Price Tell)", group = ACV_GRP)
useAcvDecel         = input.bool(true,  "Enable Kinematic Deceleration (Physics Tell)", group = ACV_GRP)
useAcvTime          = input.bool(true,  "Enable Temporal Exhaustion (Time Tell)", group = ACV_GRP)
acvTimeMax          = input.int(4,      "Max Bars in Exhaustion (Time Tell)", minval = 1, maxval = 20, group = ACV_GRP)
useAcvPulse         = input.bool(true,  "Enable Kinematic Saturation Decay (Pulse Tell)", group = ACV_GRP)
useAcvGForce        = input.bool(true,  "Enable 2nd Derivative G-Force (Acceleration Tell)", group = ACV_GRP)
useAcvAbsorb        = input.bool(true,  "Enable Effort vs. Result (Absorption Tell)", group = ACV_GRP)
strictLiveEdge      = input.bool(false, "Strict Live-Edge Shield (Demand Wick Break)", group = ACV_GRP, tooltip="If false, 0-lag execution demands the pivot candle closes above the previous candle's Open. If true, it strictly demands a close above the previous candle's High wick.")
pulseCloseZone      = input.float(0.3,  "Pulse Conviction Zone", minval=0.1, maxval=0.5, step=0.05, group=ACV_GRP)
pulseDecay          = input.float(0.85, "Pulse Decay Factor", minval=0.5, maxval=0.99, step=0.01, group=ACV_GRP)
pulseCap            = input.int(5,      "Pulse Saturation Cap", minval=3, maxval=20, group=ACV_GRP)
pulseLockThresh     = input.float(0.75, "Pulse Lockdown Threshold", minval=0.5, maxval=1.0, step=0.05, group=ACV_GRP)
pulseReleaseThresh  = input.float(0.4,  "Pulse Release Threshold", minval=0.1, maxval=0.5, step=0.1, group=ACV_GRP)
showHidden          = input.bool(false, "Show Hidden (Blocked) Signals", group = ACV_GRP, tooltip="Displays execution signals that met oscillator conditions but were blocked by ACV / Integrity gates.")

string ADV_ACV_GRP  = "Advanced ACV Protocols (The V3 Trio)"
useDALS             = input.bool(true,  "Enable Dynamic ALS (D-ALS) Expansion", group = ADV_ACV_GRP, tooltip="Stretches the non-causal extreme bounds dynamically during high ADX trends to prevent the knife.")
useVShape           = input.bool(true,  "Enable V-Shape / Sweep Override", group = ADV_ACV_GRP, tooltip="Detects violent V-Tops, Pin-bars, and Liquidity Sweeps. If detected, instantly bypasses lagging deceleration and fast-kernel gates to catch the absolute top/bottom wick.")
dalsMultiplier      = input.float(0.8,  "D-ALS ADX Stretch Multiplier", minval=0.1, step=0.1, group = ADV_ACV_GRP)
useDualKernel       = input.bool(true,  "Enable Fast-Kernel Slope Alignment", group = ADV_ACV_GRP, tooltip="Only triggers signals when the high-velocity fast kernel's slope flips to support the trade.")
nwFastBandwidth     = input.float(3.0,  "Fast NW Bandwidth (h)", minval = 0.1, step=0.5, group = ADV_ACV_GRP)
useVolProfileDef    = input.bool(true,  "Enable Liquidity Void Rejection", group = ADV_ACV_GRP, tooltip="Rejects and mutes any execution signal if historical localized volume is extremely low (a void/gap).")
volVoidThresh       = input.float(0.25, "Liquidity Void Threshold", minval=0.05, maxval=1.0, step=0.05, group = ADV_ACV_GRP, tooltip="If historical volume in this zone is less than this % of average, the signal is muted.")

string HUD_GRP      = "Tactical HUD"
showHUD             = input.bool(true,  "Enable MTF Table HUD",   group = HUD_GRP)

string VISUAL_GRP   = "Visual Customization"
color SINE_COLOR    = input.color(color.black, "Sine Wave Color", group = VISUAL_GRP)
color LEAD_COLOR    = input.color(#FF1744, "Lead Sine Wave Color", group = VISUAL_GRP)
color IKB_COLOR     = input.color(#00BFFF, "IKB Binding Matrix Color", group = VISUAL_GRP)
color NW_COLOR      = input.color(#FFD700, "Nadaraya-Watson Attractor", group = VISUAL_GRP)
color NW_F_COLOR    = input.color(#FF8C00, "Fast NW Attractor", group = VISUAL_GRP)
color NW_ENV_COLOR  = input.color(color.new(#FFD700, 60), "NW Envelope Bounds", group = VISUAL_GRP)
color HP_COLOR      = input.color(color.white, "Hodrick-Prescott Line", group = VISUAL_GRP)
color SG_COLOR      = input.color(#8A2BE2, "Savitzky-Golay Line", group = VISUAL_GRP)

// Signature Institutional Colors
color BULL_COLOR    = #089981
color BEAR_COLOR    = #f23645
color MID_COLOR     = color.gray

color COL_BULL_ACC  = color.rgb(0, 255, 0)
color COL_BULL_DEC  = color.rgb(0, 140, 140)
color COL_BEAR_ACC  = color.rgb(255, 40, 0)
color COL_BEAR_DEC  = color.rgb(180, 100, 0)

// Specific Causal execution dot colors
color C_CVD         = #FF9800
color C_OBV         = #00BCD4
color C_RSI         = #2196F3
color C_SRSI        = #9C27B0
color C_MACD        = #FF00FF
color C_AROON       = #00FF00
color C_YELL        = #FFEB3B
color C_VWAP        = #39FF14

// Reference Lines (Rendered globally in the subpane)
hline(0.0,  "Midline (Zero)", color = color.gray, linestyle = hline.style_solid)
hline(0.5,  "Overbought",     color = BEAR_COLOR, linestyle = hline.style_dashed)
hline(-0.5, "Oversold",       color = BULL_COLOR, linestyle = hline.style_dashed)
hline(0.95, "Lead Exhaustion Top", color = color.new(LEAD_COLOR, 50), linestyle = hline.style_dotted)
hline(-0.95, "Lead Exhaustion Bot", color = color.new(LEAD_COLOR, 50), linestyle = hline.style_dotted)

//---------------------------------------------------------------------------------------------------------------------}
// VOLUME Z-SCORE SHOCK & STATE-LOCK MECHANISM (REAL-TIME CAUSAL)
//---------------------------------------------------------------------------------------------------------------------{

float mean_20 = ta.sma(volume, volLenInput)
float std_20  = ta.stdev(volume, volLenInput)

float z_val = 0.0
if std_20 != 0
    z_val := (volume - mean_20) / std_20

float z_smooth = ta.ema(z_val, emaLenInput)
float vol_mapped = 0.8 + (z_smooth * volScaleInput)
float vol_mod_clamped = math.max(0.3, math.min(1.5, vol_mapped))

float meta_mean_24 = ta.sma(close, 24)
float meta_std_24  = ta.stdev(close, 24)

float atr_3 = ta.atr(3)
float atr_50 = ta.atr(50)
float atr_14_val = ta.atr(14)
float vol_mean_50 = ta.sma(volume, 50)

//---------------------------------------------------------------------------------------------------------------------}
// STRUCTURAL BEHAVIORAL MAPPING (AMD SESSIONS)
//---------------------------------------------------------------------------------------------------------------------{

in_session(sess) => not na(time(timeframe.period, sess))
is_new_session(sess) => in_session(sess) and not in_session(sess)[1]

var float asia_hi = na
var float asia_lo = na
var box asia_box = na

if amdEnable
    if is_new_session(sess_asia)
        asia_hi := high
        asia_lo := low
        asia_box := box.new(left=bar_index, top=high, right=bar_index+1, bottom=low, bgcolor=color.new(color.purple, 85), border_color=color.purple)
    else if in_session(sess_asia)
        asia_hi := math.max(nz(asia_hi, high), high)
        asia_lo := math.min(nz(asia_lo, low), low)
        if not na(asia_box)
            box.set_top(asia_box, asia_hi)
            box.set_bottom(asia_box, asia_lo)
            box.set_right(asia_box, bar_index+1)

bool sweep_asia_hi = amdEnable and high > asia_hi and close < asia_hi and in_session(sess_lon)
bool sweep_asia_lo = amdEnable and low < asia_lo and close > asia_lo and in_session(sess_lon)

//---------------------------------------------------------------------------------------------------------------------}
// HMM REGIME FEATURES & BASE CAUSAL ARRAYS (REAL-TIME CAUSAL)
//---------------------------------------------------------------------------------------------------------------------{
var float cvd = 0.0
cvd += (close > open ? volume : (close < open ? -volume : 0))
float rsi_val = ta.rsi(close, 14)
float obv_val = ta.obv
[di_plus_val, di_minus_val, adx_val] = ta.dmi(14, 14)

// HUD & Timeframe Setup
f_tf_name(string t) => t == "" ? "CHRT" : t
f_pad(string s) =>
    int len = str.length(s)
    string out = s
    if len == 1
        out := s + "   "
    else if len == 2
        out := s + "  "
    else if len == 3
        out := s + " "
    else if len > 4
        out := str.substring(s, 0, 4)
    out

f_update_state(bool b, bool bu, string current) => (b and not longOnly) ? "SHRT" : (bu ? "LONG" : current)

string tf1 = tf1_inp == "" ? timeframe.period : tf1_inp
string tf2 = tf2_inp
string tf3 = tf3_inp
string tf4 = tf4_inp

string tf1_name = f_tf_name(tf1_inp)
string tf2_name = f_tf_name(tf2_inp)
string tf3_name = f_tf_name(tf3_inp)
string tf4_name = f_tf_name(tf4_inp)

f_eval_mtf_state(float tf_prem, float tf_oi, float tf_usdt, string mode) =>
    float d_cvd = ta.cum(close > open ? volume : (close < open ? -volume : 0))
    float d_obv = ta.obv
    float d_rsi = ta.rsi(close, 14)
    float d_rsi_inst = ta.rsi(close, 24)
    float d_stoch_k = ta.sma(ta.stoch(d_rsi, d_rsi, d_rsi, 14), 3)
    float d_stoch_d = ta.sma(d_stoch_k, 3)
    float d_stoch_k_inst = ta.sma(ta.stoch(d_rsi_inst, d_rsi_inst, d_rsi_inst, 24), 3)
    float d_stoch_d_inst = ta.sma(d_stoch_k_inst, 3)
    float proxy_alma = ta.alma(close, 40, 0.85, 6)
    float proxy_dev = ta.stdev(close, 40)
    [d_macd, d_macd_sig, histLine] = ta.macd(close, 12, 26, 9)
    float proxy_macd = d_macd
    float d_v = volume

    // Aroon Computations
    float aroon_up = 100 * (14 + ta.highestbars(high, 14)) / 14
    float aroon_dn = 100 * (14 + ta.lowestbars(low, 14)) / 14
    float aroon_up_inst = 100 * (24 + ta.highestbars(high, 24)) / 24
    float aroon_dn_inst = 100 * (24 + ta.lowestbars(low, 24)) / 24
    float inst_aroon_osc = aroon_up_inst - aroon_dn_inst

    float vol_z = ta.stdev(d_v, 24) != 0 ? (d_v - ta.sma(d_v, 24)) / ta.stdev(d_v, 24) : 0.0
    bool is_anom = vol_z > 2.5

    // 24x Institutional Cloned Anchor Queues
    var array<float> a_cvd = array.new_float(24, 0.0)
    var array<float> a_obv = array.new_float(24, 0.0)
    var array<float> a_rsi = array.new_float(24, 0.0)
    var array<float> a_macd = array.new_float(24, 0.0)
    var array<float> a_aroon = array.new_float(24, 0.0)
    var array<float> a_usdt = array.new_float(24, 0.0)

    if is_anom
        a_cvd.unshift(d_cvd), a_cvd.pop()
        a_obv.unshift(d_obv), a_obv.pop()
        a_rsi.unshift(d_rsi_inst), a_rsi.pop()
        a_macd.unshift(d_macd), a_macd.pop()
        a_aroon.unshift(inst_aroon_osc), a_aroon.pop()
        a_usdt.unshift(tf_usdt), a_usdt.pop()

    // Institutional Consensus: The Web / Cluster Mode
    int valid_anc = 0
    int cvd_b_votes = 0, int cvd_bu_votes = 0
    int obv_b_votes = 0, int obv_bu_votes = 0
    int rsi_b_votes = 0, int rsi_bu_votes = 0
    int macd_b_votes = 0, int macd_bu_votes = 0
    int aroon_b_votes = 0, int aroon_bu_votes = 0
    int u_b_votes = 0, int u_bu_votes = 0

    float cvd_chg = ta.change(d_cvd)
    float obv_chg = ta.change(d_obv)
    float macd_chg = ta.change(d_macd)
    float aroon_chg = ta.change(inst_aroon_osc)
    float u_chg = ta.change(tf_usdt)
    float rsi_prev = d_rsi_inst[1]

    for k = 0 to 23
        float anc_c = a_cvd.get(k)
        if anc_c != 0.0
            valid_anc += 1
            
            float i_cvd = d_cvd - anc_c
            if cvd_chg < 0 and i_cvd > 0
                cvd_b_votes += 1
            if cvd_chg > 0 and i_cvd < 0
                cvd_bu_votes += 1
                
            float i_obv = d_obv - a_obv.get(k)
            if obv_chg < 0 and i_obv > 0
                obv_b_votes += 1
            if obv_chg > 0 and i_obv < 0
                obv_bu_votes += 1
                
            float i_rsi = d_rsi_inst - a_rsi.get(k)
            float i_rsi_prev = rsi_prev - a_rsi.get(k)
            if i_rsi_prev > 15 and i_rsi <= 15
                rsi_b_votes += 1
            if i_rsi_prev < -15 and i_rsi >= -15
                rsi_bu_votes += 1
                
            float i_macd = d_macd - a_macd.get(k)
            if macd_chg < 0 and i_macd > 0
                macd_b_votes += 1
            if macd_chg > 0 and i_macd < 0
                macd_bu_votes += 1
                
            float i_aroon = inst_aroon_osc - a_aroon.get(k)
            if aroon_chg < 0 and i_aroon > 0
                aroon_b_votes += 1
            if aroon_chg > 0 and i_aroon < 0
                aroon_bu_votes += 1
                
            float i_u = tf_usdt - a_usdt.get(k)
            if u_chg > 0 and i_u < 0
                u_b_votes += 1
            if u_chg < 0 and i_u > 0
                u_bu_votes += 1

    int consensus_thresh = math.max(1, math.floor(valid_anc * 0.75))

    bool cvd_b = false, bool cvd_bu = false
    if useExec
        if mode == "Retail"
            cvd_b := ta.change(d_cvd) < 0 and d_cvd > ta.sma(d_cvd, 10)
            cvd_bu := ta.change(d_cvd) > 0 and d_cvd < ta.sma(d_cvd, 10)
        else
            cvd_b := valid_anc > 0 and (cvd_b_votes >= consensus_thresh)
            cvd_bu := valid_anc > 0 and (cvd_bu_votes >= consensus_thresh)

    bool obv_b = false, bool obv_bu = false
    if useObvExec
        if mode == "Retail"
            obv_b := ta.change(d_obv) < 0 and d_obv > ta.sma(d_obv, 10)
            obv_bu := ta.change(d_obv) > 0 and d_obv < ta.sma(d_obv, 10)
        else
            obv_b := valid_anc > 0 and (obv_b_votes >= consensus_thresh)
            obv_bu := valid_anc > 0 and (obv_bu_votes >= consensus_thresh)

    bool rsi_b = false, bool rsi_bu = false
    if useRsiExec
        if mode == "Retail"
            rsi_b := ta.crossunder(d_rsi, 70)
            rsi_bu := ta.crossover(d_rsi, 30)
        else
            rsi_b := valid_anc > 0 and (rsi_b_votes >= consensus_thresh)
            rsi_bu := valid_anc > 0 and (rsi_bu_votes >= consensus_thresh)

    bool srsi_b = false, bool srsi_bu = false
    if useSrsiExec
        if mode == "Retail"
            srsi_b := ta.crossunder(d_stoch_k, d_stoch_d) and d_stoch_k > 80
            srsi_bu := ta.crossover(d_stoch_k, d_stoch_d) and d_stoch_k < 20
        else
            srsi_b := ta.crossunder(d_stoch_k_inst, d_stoch_d_inst) and d_stoch_k_inst > 80
            srsi_bu := ta.crossover(d_stoch_k_inst, d_stoch_d_inst) and d_stoch_k_inst < 20

    bool macd_b = false, bool macd_bu = false
    if useMacdExec
        if mode == "Retail"
            macd_b := ta.crossunder(d_macd, d_macd_sig)
            macd_bu := ta.crossover(d_macd, d_macd_sig)
        else
            macd_b := valid_anc > 0 and (macd_b_votes >= consensus_thresh)
            macd_bu := valid_anc > 0 and (macd_bu_votes >= consensus_thresh)

    bool aroon_b = false, bool aroon_bu = false
    if useAroonExec
        if mode == "Retail"
            aroon_b := ta.crossunder(aroon_up, aroon_dn)
            aroon_bu := ta.crossover(aroon_up, aroon_dn)
        else
            aroon_b := valid_anc > 0 and (aroon_b_votes >= consensus_thresh)
            aroon_bu := valid_anc > 0 and (aroon_bu_votes >= consensus_thresh)

    bool prem_b = false, bool prem_bu = false
    if usePremExec
        if mode == "Retail"
            prem_b := ta.crossunder(tf_prem, 0)
            prem_bu := ta.crossover(tf_prem, 0)
        else
            float p_mean = ta.sma(tf_prem, 24)
            float p_std = ta.stdev(tf_prem, 24)
            float p_z = p_std != 0 ? (tf_prem - p_mean) / p_std : 0.0
            prem_b := ta.crossunder(p_z, premThreshold)
            prem_bu := ta.crossover(p_z, -premThreshold)

    bool oi_b = false, bool oi_bu = false
    if useOiExec
        if mode == "Retail"
            oi_b := ta.change(tf_oi) < 0
            oi_bu := ta.change(tf_oi) < 0
        else
            float oi_mean = ta.sma(tf_oi, 24)
            float oi_std = ta.stdev(tf_oi, 24)
            float oi_z = oi_std != 0 ? (tf_oi - oi_mean) / oi_std : 0.0
            oi_b := ta.change(oi_z) < -0.5
            oi_bu := ta.change(oi_z) < -0.5

    bool usdt_b = false, bool usdt_bu = false
    if useUsdtExec
        if mode == "Retail"
            usdt_b := ta.change(tf_usdt) > 0 and tf_usdt < ta.sma(tf_usdt, 10)
            usdt_bu := ta.change(tf_usdt) < 0 and tf_usdt > ta.sma(tf_usdt, 10)
        else
            usdt_b := valid_anc > 0 and (u_b_votes >= consensus_thresh)
            usdt_bu := valid_anc > 0 and (u_bu_votes >= consensus_thresh)

    bool nc_weso_b = close > (proxy_alma + proxy_dev * 2)
    bool nc_weso_bu = close < (proxy_alma - proxy_dev * 2)
    bool nc_phase_b = ta.crossunder(proxy_macd, 0)
    bool nc_phase_bu = ta.crossover(proxy_macd, 0)

    int state = 0
    if cvd_b
        state += 1
    if cvd_bu
        state += 2
    if obv_b
        state += 4
    if obv_bu
        state += 8
    if rsi_b
        state += 16
    if rsi_bu
        state += 32
    if srsi_b
        state += 64
    if srsi_bu
        state += 128
    if prem_b
        state += 256
    if prem_bu
        state += 512
    if oi_b
        state += 1024
    if oi_bu
        state += 2048
    if usdt_b
        state += 4096
    if usdt_bu
        state += 8192
    if nc_weso_b
        state += 16384
    if nc_weso_bu
        state += 32768
    if nc_phase_b
        state += 65536
    if nc_phase_bu
        state += 131072
    if macd_b
        state += 262144
    if macd_bu
        state += 524288
    if aroon_b
        state += 1048576
    if aroon_bu
        state += 2097152
    state

float prem_1 = usePremExec ? request.security(premTicker, tf1, close) : 0.0
float prem_2 = usePremExec ? request.security(premTicker, tf2, close) : 0.0
float prem_3 = usePremExec ? request.security(premTicker, tf3, close) : 0.0
float prem_4 = usePremExec ? request.security(premTicker, tf4, close) : 0.0

float oi_1 = useOiExec ? request.security(oiTicker, tf1, close) : 0.0
float oi_2 = useOiExec ? request.security(oiTicker, tf2, close) : 0.0
float oi_3 = useOiExec ? request.security(oiTicker, tf3, close) : 0.0
float oi_4 = useOiExec ? request.security(oiTicker, tf4, close) : 0.0

float usdt_1 = useUsdtExec ? request.security(usdtTicker, tf1, close) : 0.0
float usdt_2 = useUsdtExec ? request.security(usdtTicker, tf2, close) : 0.0
float usdt_3 = useUsdtExec ? request.security(usdtTicker, tf3, close) : 0.0
float usdt_4 = useUsdtExec ? request.security(usdtTicker, tf4, close) : 0.0

[vwap_c, vwap_v, vwap_h3] = request.security(syminfo.tickerid, tf1, [close, volume, hlc3], lookahead = barmerge.lookahead_off)

f_decode(int val, int bit) =>
    int div = int(math.pow(2, bit))
    int bit_val = int(math.floor(val / div)) % 2
    bit_val == 1

int ts1 = request.security(syminfo.tickerid, tf1, f_eval_mtf_state(prem_1, oi_1, usdt_1, causalMode))
int ts2 = request.security(syminfo.tickerid, tf2, f_eval_mtf_state(prem_2, oi_2, usdt_2, causalMode))
int ts3 = request.security(syminfo.tickerid, tf3, f_eval_mtf_state(prem_3, oi_3, usdt_3, causalMode))
int ts4 = request.security(syminfo.tickerid, tf4, f_eval_mtf_state(prem_4, oi_4, usdt_4, causalMode))

bool c_b_1_s = f_decode(ts1, 0), bool c_bu_1_s = f_decode(ts1, 1)
bool o_b_1_s = f_decode(ts1, 2), bool o_bu_1_s = f_decode(ts1, 3)
bool r_b_1_s = f_decode(ts1, 4), bool r_bu_1_s = f_decode(ts1, 5)
bool srsi_b_1_s = f_decode(ts1, 6), bool srsi_bu_1_s = f_decode(ts1, 7)
bool p_b_1_s = f_decode(ts1, 8), bool p_bu_1_s = f_decode(ts1, 9)
bool oi_b_1_s = f_decode(ts1, 10), bool oi_bu_1_s = f_decode(ts1, 11)
bool u_b_1_s = f_decode(ts1, 12), bool u_bu_1_s = f_decode(ts1, 13)
bool nc_w_b_1_s = f_decode(ts1, 14), bool nc_w_bu_1_s = f_decode(ts1, 15)
bool nc_p_b_1_s = f_decode(ts1, 16), bool nc_p_bu_1_s = f_decode(ts1, 17)
bool m_b_1_s = f_decode(ts1, 18), bool m_bu_1_s = f_decode(ts1, 19)
bool a_b_1_s = f_decode(ts1, 20), bool a_bu_1_s = f_decode(ts1, 21)

bool c_b_2_s = f_decode(ts2, 0), bool c_bu_2_s = f_decode(ts2, 1)
bool o_b_2_s = f_decode(ts2, 2), bool o_bu_2_s = f_decode(ts2, 3)
bool r_b_2_s = f_decode(ts2, 4), bool r_bu_2_s = f_decode(ts2, 5)
bool srsi_b_2_s = f_decode(ts2, 6), bool srsi_bu_2_s = f_decode(ts2, 7)
bool p_b_2_s = f_decode(ts2, 8), bool p_bu_2_s = f_decode(ts2, 9)
bool oi_b_2_s = f_decode(ts2, 10), bool oi_bu_2_s = f_decode(ts2, 11)
bool u_b_2_s = f_decode(ts2, 12), bool u_bu_2_s = f_decode(ts2, 13)
bool nc_w_b_2_s = f_decode(ts2, 14), bool nc_w_bu_2_s = f_decode(ts2, 15)
bool nc_p_b_2_s = f_decode(ts2, 16), bool nc_p_bu_2_s = f_decode(ts2, 17)
bool m_b_2_s = f_decode(ts2, 18), bool m_bu_2_s = f_decode(ts2, 19)
bool a_b_2_s = f_decode(ts2, 20), bool a_bu_2_s = f_decode(ts2, 21)

bool c_b_3_s = f_decode(ts3, 0), bool c_bu_3_s = f_decode(ts3, 1)
bool o_b_3_s = f_decode(ts3, 2), bool o_bu_3_s = f_decode(ts3, 3)
bool r_b_3_s = f_decode(ts3, 4), bool r_bu_3_s = f_decode(ts3, 5)
bool srsi_b_3_s = f_decode(ts3, 6), bool srsi_bu_3_s = f_decode(ts3, 7)
bool p_b_3_s = f_decode(ts3, 8), bool p_bu_3_s = f_decode(ts3, 9)
bool oi_b_3_s = f_decode(ts3, 10), bool oi_bu_3_s = f_decode(ts3, 11)
bool u_b_3_s = f_decode(ts3, 12), bool u_bu_3_s = f_decode(ts3, 13)
bool nc_w_b_3_s = f_decode(ts3, 14), bool nc_w_bu_3_s = f_decode(ts3, 15)
bool nc_p_b_3_s = f_decode(ts3, 16), bool nc_p_bu_3_s = f_decode(ts3, 17)
bool m_b_3_s = f_decode(ts3, 18), bool m_bu_3_s = f_decode(ts3, 19)
bool a_b_3_s = f_decode(ts3, 20), bool a_bu_3_s = f_decode(ts3, 21)

bool c_b_4_s = f_decode(ts4, 0), bool c_bu_4_s = f_decode(ts4, 1)
bool o_b_4_s = f_decode(ts4, 2), bool o_bu_4_s = f_decode(ts4, 3)
bool r_b_4_s = f_decode(ts4, 4), bool r_bu_4_s = f_decode(ts4, 5)
bool srsi_b_4_s = f_decode(ts4, 6), bool srsi_bu_4_s = f_decode(ts4, 7)
bool p_b_4_s = f_decode(ts4, 8), bool p_bu_4_s = f_decode(ts4, 9)
bool oi_b_4_s = f_decode(ts4, 10), bool oi_bu_4_s = f_decode(ts4, 11)
bool u_b_4_s = f_decode(ts4, 12), bool u_bu_4_s = f_decode(ts4, 13)
bool nc_w_b_4_s = f_decode(ts4, 14), bool nc_w_bu_4_s = f_decode(ts4, 15)
bool nc_p_b_4_s = f_decode(ts4, 16), bool nc_p_bu_4_s = f_decode(ts4, 17)
bool m_b_4_s = f_decode(ts4, 18), bool m_bu_4_s = f_decode(ts4, 19)
bool a_b_4_s = f_decode(ts4, 20), bool a_bu_4_s = f_decode(ts4, 21)

var string h_w_1 = "--", var string h_w_2 = "--", var string h_w_3 = "--", var string h_w_4 = "--"
var string h_ph_1 = "--", var string h_ph_2 = "--", var string h_ph_3 = "--", var string h_ph_4 = "--"
var string h_c_1 = "--", var string h_c_2 = "--", var string h_c_3 = "--", var string h_c_4 = "--"
var string h_o_1 = "--", var string h_o_2 = "--", var string h_o_3 = "--", var string h_o_4 = "--"
var string h_r_1 = "--", var string h_r_2 = "--", var string h_r_3 = "--", var string h_r_4 = "--"
var string h_s_1 = "--", var string h_s_2 = "--", var string h_s_3 = "--", var string h_s_4 = "--"
var string h_p_1 = "--", var string h_p_2 = "--", var string h_p_3 = "--", var string h_p_4 = "--"
var string h_oi_1 = "--", var string h_oi_2 = "--", var string h_oi_3 = "--", var string h_oi_4 = "--"
var string h_u_1 = "--", var string h_u_2 = "--", var string h_u_3 = "--", var string h_u_4 = "--"
var string h_m_1 = "--", var string h_m_2 = "--", var string h_m_3 = "--", var string h_m_4 = "--"
var string h_a_1 = "--", var string h_a_2 = "--", var string h_a_3 = "--", var string h_a_4 = "--"
var string h_v_1 = "--"

h_w_1 := f_update_state(nc_w_b_1_s, nc_w_bu_1_s, h_w_1), h_w_2 := f_update_state(nc_w_b_2_s, nc_w_bu_2_s, h_w_2), h_w_3 := f_update_state(nc_w_b_3_s, nc_w_bu_3_s, h_w_3), h_w_4 := f_update_state(nc_w_b_4_s, nc_w_bu_4_s, h_w_4)
h_ph_1 := f_update_state(nc_p_b_1_s, nc_p_bu_1_s, h_ph_1), h_ph_2 := f_update_state(nc_p_b_2_s, nc_p_bu_2_s, h_ph_2), h_ph_3 := f_update_state(nc_p_b_3_s, nc_p_bu_3_s, h_ph_3), h_ph_4 := f_update_state(nc_p_b_4_s, nc_p_bu_4_s, h_ph_4)
h_c_1 := f_update_state(c_b_1_s, c_bu_1_s, h_c_1), h_c_2 := f_update_state(c_b_2_s, c_bu_2_s, h_c_2), h_c_3 := f_update_state(c_b_3_s, c_bu_3_s, h_c_3), h_c_4 := f_update_state(c_b_4_s, c_bu_4_s, h_c_4)
h_o_1 := f_update_state(o_b_1_s, o_bu_1_s, h_o_1), h_o_2 := f_update_state(o_b_2_s, o_bu_2_s, h_o_2), h_o_3 := f_update_state(o_b_3_s, o_bu_3_s, h_o_3), h_o_4 := f_update_state(o_b_4_s, o_bu_4_s, h_o_4)
h_r_1 := f_update_state(r_b_1_s, r_bu_1_s, h_r_1), h_r_2 := f_update_state(r_b_2_s, r_bu_2_s, h_r_2), h_r_3 := f_update_state(r_b_3_s, r_bu_3_s, h_r_3), h_r_4 := f_update_state(r_b_4_s, r_bu_4_s, h_r_4)
h_s_1 := f_update_state(srsi_b_1_s, srsi_bu_1_s, h_s_1), h_s_2 := f_update_state(srsi_b_2_s, srsi_bu_2_s, h_s_2), h_s_3 := f_update_state(srsi_b_3_s, srsi_bu_3_s, h_s_3), h_s_4 := f_update_state(srsi_b_4_s, srsi_bu_4_s, h_s_4)
h_p_1 := f_update_state(p_b_1_s, p_bu_1_s, h_p_1), h_p_2 := f_update_state(p_b_2_s, p_bu_2_s, h_p_2), h_p_3 := f_update_state(p_b_3_s, p_bu_3_s, h_p_3), h_p_4 := f_update_state(p_b_4_s, p_bu_4_s, h_p_4)
h_oi_1 := f_update_state(oi_b_1_s, oi_bu_1_s, h_oi_1), h_oi_2 := f_update_state(oi_b_2_s, oi_bu_2_s, h_oi_2), h_oi_3 := f_update_state(oi_b_3_s, oi_bu_3_s, h_oi_3), h_oi_4 := f_update_state(oi_b_4_s, oi_bu_4_s, h_oi_4)
h_u_1 := f_update_state(u_b_1_s, u_bu_1_s, h_u_1), h_u_2 := f_update_state(u_b_2_s, u_bu_2_s, h_u_2), h_u_3 := f_update_state(u_b_3_s, u_bu_3_s, h_u_3), h_u_4 := f_update_state(u_b_4_s, u_bu_4_s, h_u_4)
h_m_1 := f_update_state(m_b_1_s, m_bu_1_s, h_m_1), h_m_2 := f_update_state(m_b_2_s, m_bu_2_s, h_m_2), h_m_3 := f_update_state(m_b_3_s, m_bu_3_s, h_m_3), h_m_4 := f_update_state(m_b_4_s, m_bu_4_s, h_m_4)
h_a_1 := f_update_state(a_b_1_s, a_bu_1_s, h_a_1), h_a_2 := f_update_state(a_b_2_s, a_bu_2_s, h_a_2), h_a_3 := f_update_state(a_b_3_s, a_bu_3_s, h_a_3), h_a_4 := f_update_state(a_b_4_s, a_bu_4_s, h_a_4)

//---------------------------------------------------------------------------------------------------------------------}
// HUD & TABLE DEFINITION (NATIVE TO SUBPANE)
//---------------------------------------------------------------------------------------------------------------------{
var table hud = table.new(position.top_right, 5, 14, bgcolor = color.new(color.black, 80), border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 60), frame_width = 1)

f_fill_hud_row(table t, int r, string title, color title_col, string v1, string v2, string v3, string v4) =>
    table.cell(t, 0, r, title, text_color=title_col, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 1, r, v1, text_color=v1=="SHRT"?color.red:(v1=="LONG"?color.green:color.gray), bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 2, r, v2, text_color=v2=="SHRT"?color.red:(v2=="LONG"?color.green:color.gray), bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 3, r, v3, text_color=v3=="SHRT"?color.red:(v3=="LONG"?color.green:color.gray), bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 4, r, v4, text_color=v4=="SHRT"?color.red:(v4=="LONG"?color.green:color.gray), bgcolor=color.new(color.black, 70), text_size=size.small)

//---------------------------------------------------------------------------------------------------------------------}
// HEAVY MATRIX OPERATIONS (ANTI-OPTIMIZATION MANDATE)
//---------------------------------------------------------------------------------------------------------------------{

solvePentadiagonal(array<float> b, array<float> d, array<float> c, array<float> f, int n, array<float> x) =>
    var array<float> d_tmp = array.new_float(n)
    var array<float> c_tmp = array.new_float(n)
    var array<float> b_tmp = array.new_float(n)
    
    for i = 0 to n - 1
        d_tmp.set(i, d.get(i))
        c_tmp.set(i, c.get(i))
        b_tmp.set(i, b.get(i))

    float r = c_tmp.get(0)
    float s = c_tmp.get(1)
    float t = f.get(0)
    float xmult = 0.0
    int l1 = n - 1
    int l2 = n - 2

    for i = 1 to l2
        float d_prev = d_tmp.get(i - 1)
        xmult := r / d_prev
        d_tmp.set(i, d_tmp.get(i) - xmult * c_tmp.get(i - 1))
        c_tmp.set(i, c_tmp.get(i) - xmult * f.get(i - 1))
        b_tmp.set(i, b_tmp.get(i) - xmult * b_tmp.get(i - 1))
        xmult := t / d_prev
        r     := s - xmult * c_tmp.get(i - 1)
        d_tmp.set(i + 1, d_tmp.get(i + 1) - xmult * f.get(i - 1))
        b_tmp.set(i + 1, b_tmp.get(i + 1) - xmult * b_tmp.get(i - 1))
        if i < l2
            s := c_tmp.get(i + 1)
            t := f.get(i)
        
    xmult := r / d_tmp.get(l2)
    d_tmp.set(l1, d_tmp.get(l1) - xmult * c_tmp.get(l2))
    x.set(l1, (b_tmp.get(l1) - xmult * b_tmp.get(l2)) / d_tmp.get(l1))
    x.set(l2, (b_tmp.get(l2) - c_tmp.get(l2) * x.get(l1)) / d_tmp.get(l2))
    
    for i = n - 3 to 0 by 1
        x.set(i, (b_tmp.get(i) - f.get(i) * x.get(i + 2) - c_tmp.get(i) * x.get(i + 1)) / d_tmp.get(i))

whittakerALS(array<float> prices, array<float> d_base, array<float> c_base, array<float> f_base, int n, int iters, float p, array<float> z) =>
    var array<float> weights = array.new_float(lengthInput, 1.0)
    var array<float> b_curr  = array.new_float(lengthInput)
    var array<float> d_curr  = array.new_float(lengthInput)
    weights.fill(1.0)
    
    for it = 1 to iters
        for i = 0 to n - 1
            float w = weights.get(i)
            d_curr.set(i, d_base.get(i) + w)
            b_curr.set(i, w * prices.get(i))
        solvePentadiagonal(b_curr, d_curr, c_base, f_base, n, z)
        for i = 0 to n - 1
            weights.set(i, prices.get(i) > z.get(i) ? p : 1.0 - p)

nadarayaWatson(array<float> src, int n, float h, array<float> out) =>
    int window = math.max(1, math.ceil(h * 4.0))
    for i = 0 to n - 1
        float sum_w = 0.0
        float sum_xw = 0.0
        int start_j = math.max(0, i - window)
        int end_j = math.min(n - 1, i + window)
        for j = start_j to end_j
            float diff = i - j
            float weight = math.exp(-(diff * diff) / (2.0 * h * h))
            sum_w += weight
            sum_xw += src.get(j) * weight
        out.set(i, sum_xw / sum_w)

sgFilter(array<float> src, int n, int m, array<float> out) =>
    for i = 0 to n - 1
        float sum_val = 0.0
        float sum_w = 0.0
        for j = -m to m
            int idx = i + j
            if idx >= 0 and idx < n
                float w = 3.0 * (3.0 * m * m + 3.0 * m - 1.0 - 5.0 * j * j)
                sum_val += src.get(idx) * w
                sum_w += w
        out.set(i, sum_val / sum_w)

calc_atan2(float y, float x) =>
    float res = 0.0
    if x > 0.0
        res := math.atan(y / x)
    else if x < 0.0 and y >= 0.0
        res := math.atan(y / x) + math.pi
    else if x < 0.0 and y < 0.0
        res := math.atan(y / x) - math.pi
    else if x == 0.0 and y > 0.0
        res := math.pi / 2.0
    else if x == 0.0 and y < 0.0
        res := -math.pi / 2.0
    res

//---------------------------------------------------------------------------------------------------------------------}
// STRUCTURAL INITIALIZATION & KINEMATIC MEMORY
//---------------------------------------------------------------------------------------------------------------------{

var array<float> d_base = array.new_float(lengthInput)
var array<float> c_base = array.new_float(lengthInput)
var array<float> f_base = array.new_float(lengthInput)

var array<float> d_hp = array.new_float(lengthInput)
var array<float> c_hp = array.new_float(lengthInput)
var array<float> f_hp = array.new_float(lengthInput)

if barstate.isfirst
    float k = lambdaInput
    float k_hp = hpLambda
    for i = 0 to lengthInput - 1
        float di = 6.0 * k
        float ci = -4.0 * k
        float fi = k
        float di_hp = 1.0 + 6.0 * k_hp
        float ci_hp = -4.0 * k_hp
        float fi_hp = k_hp
        
        if i == 0
            di := k
            ci := -2.0 * k
            di_hp := 1.0 + k_hp
            ci_hp := -2.0 * k_hp
        else if i == 1
            di := 5.0 * k
            di_hp := 1.0 + 5.0 * k_hp
        else if i == lengthInput - 2
            di := 5.0 * k
            ci := -2.0 * k
            di_hp := 1.0 + 5.0 * k_hp
            ci_hp := -2.0 * k_hp
        else if i == lengthInput - 1
            di := k
            ci := 0.0
            fi := 0.0
            di_hp := 1.0 + k_hp
            ci_hp := 0.0
            fi_hp := 0.0
            
        d_base.set(i, di)
        c_base.set(i, ci)
        f_base.set(i, fi)
        d_hp.set(i, di_hp)
        c_hp.set(i, ci_hp)
        f_hp.set(i, fi_hp)

var array<float> arr_open      = array.new_float()
var array<float> arr_highs     = array.new_float()
var array<float> arr_bodyTops  = array.new_float()
var array<float> arr_bodyBots  = array.new_float()
var array<float> arr_lows      = array.new_float()
var array<float> arr_close     = array.new_float()
var array<float> arr_tr        = array.new_float()
var array<float> arr_volMods   = array.new_float()
var array<float> arr_cvd       = array.new_float()
var array<float> arr_obv       = array.new_float()
var array<float> arr_rsi       = array.new_float()
var array<float> arr_adx       = array.new_float()
var array<float> arr_diplus    = array.new_float()
var array<float> arr_diminus   = array.new_float()
var array<float> arr_vwap_c    = array.new_float()
var array<float> arr_vwap_v    = array.new_float()
var array<float> arr_vwap_h3   = array.new_float()

var array<float> arr_meta_mean = array.new_float()
var array<float> arr_meta_std  = array.new_float()
var array<float> arr_atr_ratio = array.new_float()
var array<float> arr_atr14     = array.new_float()
var array<float> arr_atr3      = array.new_float()
var array<float> arr_raw_vol   = array.new_float()
var array<float> arr_vol_mean  = array.new_float()

var array<bool> arr_sweep_hi   = array.new<bool>()
var array<bool> arr_sweep_lo   = array.new<bool>()

// Dynamic Replay-Mode Safe Allocations
var array<chart.point> weso_pts = array.new<chart.point>()
var array<chart.point> sine_pts = array.new<chart.point>()
var array<chart.point> lead_pts = array.new<chart.point>()

var array<chart.point> hist_bull_acc = array.new<chart.point>()
var array<chart.point> hist_bull_dec = array.new<chart.point>()
var array<chart.point> hist_bear_acc = array.new<chart.point>()
var array<chart.point> hist_bear_dec = array.new<chart.point>()

var array<float> sim_path_vals = array.new_float()

//---------------------------------------------------------------------------------------------------------------------}
// MAIN SKELETON EXTRACTION & WESO GENERATION (REPAINTING ARCHITECTURE)
//---------------------------------------------------------------------------------------------------------------------{

bool is_replay_mode = barstate.isrealtime == false and barstate.ishistory == true
bool can_execute = is_replay_mode ? barstate.isconfirmed : true
bool is_active_tick = barstate.islast and can_execute

// ROLLING HISTORY QUEUE (O(1) Memory Optimization)
arr_open.unshift(open), arr_highs.unshift(high), arr_bodyTops.unshift(math.max(open, close)), arr_bodyBots.unshift(math.min(open, close)), arr_lows.unshift(low), arr_close.unshift(close), arr_tr.unshift(ta.tr), arr_volMods.unshift(vol_mod_clamped)
arr_cvd.unshift(cvd), arr_obv.unshift(obv_val), arr_rsi.unshift(rsi_val), arr_adx.unshift(adx_val), arr_diplus.unshift(di_plus_val), arr_diminus.unshift(di_minus_val), arr_meta_mean.unshift(meta_mean_24), arr_meta_std.unshift(meta_std_24)
arr_vwap_c.unshift(vwap_c), arr_vwap_v.unshift(vwap_v), arr_vwap_h3.unshift(vwap_h3), arr_atr_ratio.unshift(atr_50 != 0 ? atr_3 / atr_50 : 1.0), arr_atr14.unshift(atr_14_val), arr_atr3.unshift(atr_3), arr_raw_vol.unshift(volume), arr_vol_mean.unshift(vol_mean_50)
arr_sweep_hi.unshift(sweep_asia_hi), arr_sweep_lo.unshift(sweep_asia_lo)

if arr_open.size() > lengthInput
    arr_open.pop(), arr_highs.pop(), arr_bodyTops.pop(), arr_bodyBots.pop(), arr_lows.pop(), arr_close.pop(), arr_tr.pop(), arr_volMods.pop()
    arr_cvd.pop(), arr_obv.pop(), arr_rsi.pop(), arr_adx.pop(), arr_diplus.pop(), arr_diminus.pop(), arr_meta_mean.pop(), arr_meta_std.pop()
    arr_vwap_c.pop(), arr_vwap_v.pop(), arr_vwap_h3.pop(), arr_atr_ratio.pop(), arr_atr14.pop(), arr_atr3.pop(), arr_raw_vol.pop(), arr_vol_mean.pop()
    arr_sweep_hi.pop(), arr_sweep_lo.pop()

// ALERTS: Declare global trackers for zero-lag trigger detection
var bool alert_weso_ob = false
var bool alert_weso_os = false
var bool alert_lead_top = false
var bool alert_lead_bot = false

alert_weso_ob := false
alert_weso_os := false
alert_lead_top := false
alert_lead_bot := false

if is_active_tick and arr_open.size() == lengthInput
    if label.all.size() > 0
        int window_start = bar_index - lengthInput
        for lb in label.all
            if label.get_x(lb) > window_start
                label.delete(lb)
                
    if line.all.size() > 0
        for l in line.all
            line.delete(l)
    if box.all.size() > 0
        for bx in box.all
            box.delete(bx)
    if polyline.all.size() > 0
        for pl in polyline.all
            polyline.delete(pl)
            
    float global_max_h   = array.max(arr_highs)
    float global_min_l   = array.min(arr_lows)
    float global_chart_h = math.max(global_max_h - global_min_l, global_min_l * 0.01)
        
    var array<float> zExtUp = array.new_float(lengthInput)
    var array<float> zIntUp = array.new_float(lengthInput)
    var array<float> zIntDn = array.new_float(lengthInput)
    var array<float> zExtDn = array.new_float(lengthInput)
    var array<float> zNW    = array.new_float(lengthInput)
    var array<float> zNW_f  = array.new_float(lengthInput)
    var array<float> zNW_dev= array.new_float(lengthInput)
    var array<float> zNW_mae= array.new_float(lengthInput)
    var array<float> zHP    = array.new_float(lengthInput)
    var array<float> zSG    = array.new_float(lengthInput)
    var array<float> zPRC   = array.new_float(lengthInput, na)
        
    whittakerALS(arr_highs,    d_base, c_base, f_base, lengthInput, itersInput, pUpperInput, zExtUp)
    whittakerALS(arr_bodyTops, d_base, c_base, f_base, lengthInput, itersInput, pUpperInput, zIntUp)
    whittakerALS(arr_bodyBots, d_base, c_base, f_base, lengthInput, itersInput, pLowerInput, zIntDn)
    whittakerALS(arr_lows,     d_base, c_base, f_base, lengthInput, itersInput, pLowerInput, zExtDn)
    
    nadarayaWatson(arr_close, lengthInput, nwBandwidthInput, zNW)
    
    if nwEnvEnable
        for i = 0 to lengthInput - 1
            zNW_dev.set(i, math.abs(arr_close.get(i) - zNW.get(i)))
        nadarayaWatson(zNW_dev, lengthInput, nwBandwidthInput, zNW_mae)
    
    if hpEnable
        solvePentadiagonal(arr_close, d_hp, c_hp, f_hp, lengthInput, zHP)
        
    if sgEnable
        int m_sg = math.max(1, math.floor(sgLength / 2))
        sgFilter(arr_close, lengthInput, m_sg, zSG)

    float prc_std = 0.0
    if prcEnable
        int actual_len = math.min(prcLength, lengthInput)
        if actual_len >= 2
            matrix<float> Y = matrix.new<float>(actual_len, 1)
            matrix<float> X = matrix.new<float>(actual_len, prcDegree + 1)
            for i = 0 to actual_len - 1
                Y.set(i, 0, arr_close.get(i))
                for j = 0 to prcDegree
                    X.set(i, j, math.pow(i, j))
            matrix<float> X_T = matrix.transpose(X)
            matrix<float> X_T_X = matrix.mult(X_T, X)
            matrix<float> B = matrix.mult(matrix.pinv(X_T_X), matrix.mult(X_T, Y))

            float sq_err = 0.0
            for i = 0 to actual_len - 1
                float estimate = 0.0
                for j = 0 to prcDegree
                    estimate += B.get(j, 0) * math.pow(i, j)
                zPRC.set(i, estimate)
                float err = arr_close.get(i) - estimate
                sq_err += err * err
            prc_std := math.sqrt(sq_err / actual_len)
        
    var array<float> zRegime = array.new_float(lengthInput)
    if hmmEnable
        for i = 0 to lengthInput - 1
            float current_hp = hpEnable ? zHP.get(i) : 0.0
            float prev_hp    = hpEnable ? ((i + 1 < lengthInput) ? zHP.get(i + 1) : current_hp) : 0.0
            float hp_slope   = current_hp - prev_hp
            
            float current_nw = zNW.get(i)
            float prev_nw    = (i + 1 < lengthInput) ? zNW.get(i + 1) : current_nw
            float val_mid = (zExtUp.get(i) + zIntUp.get(i) + zIntDn.get(i) + zExtDn.get(i)) / 4.0
            float iPhase = current_nw - val_mid
            float quad   = (current_nw - prev_nw) * 8.0
            float phase  = calc_atan2(quad, iPhase)
            
            float cvd_delta = (i + 1 < lengthInput) ? (arr_cvd.get(i) - arr_cvd.get(i+1)) : 0.0
            float obv_delta = (i + 1 < lengthInput) ? (arr_obv.get(i) - arr_obv.get(i+1)) : 0.0
            float rsi = arr_rsi.get(i)
            float adx = arr_adx.get(i)
            float dip = arr_diplus.get(i)
            float dim = arr_diminus.get(i)
            
            float e_bull = (rsi > 50 ? 1.0 : 0.0) + (dip > dim and adx > 20 ? 1.0 : 0.0) + (cvd_delta > 0 ? 1.0 : 0.0) + (obv_delta > 0 ? 1.0 : 0.0) + (hp_slope > 0 ? 1.0 : 0.0) + (math.sin(phase) > 0 ? 1.0 : 0.0)
            float e_bear = (rsi < 50 ? 1.0 : 0.0) + (dim > dip and adx > 20 ? 1.0 : 0.0) + (cvd_delta < 0 ? 1.0 : 0.0) + (obv_delta < 0 ? 1.0 : 0.0) + (hp_slope < 0 ? 1.0 : 0.0) + (math.sin(phase) < 0 ? 1.0 : 0.0)
            
            float raw_state = e_bull > e_bear and e_bull >= 4 ? 1.0 : (e_bear > e_bull and e_bear >= 4 ? -1.0 : 0.0)
            zRegime.set(i, raw_state)
            
    array.clear(weso_pts)
    array.clear(sine_pts)
    array.clear(lead_pts)
    array.clear(hist_bull_acc)
    array.clear(hist_bull_dec)
    array.clear(hist_bear_acc)
    array.clear(hist_bear_dec)
    
    float alpha = 2.0 / (emaLenInput + 1.0)
    float prev_ema = na
    float val_prev = na
    
    int   active_regime = 0
    float track_weso    = na
    float track_eU      = na
    float track_eD      = na
    int   track_idx     = na
    float track_sine    = na
    float track_lead    = na

    bool acv_cleared_short_state = false
    bool acv_cleared_long_state  = false
    int bars_in_extreme_short = 0
    int bars_in_extreme_long  = 0
    bool acv_failed_time_short = false
    bool acv_failed_time_long  = false
    bool has_touched_extreme_short = false
    bool has_touched_extreme_long  = false
    bool acv_lockdown_0 = false

    float last_armed_price_short     = na
    float last_armed_cvd_short       = na
    float last_armed_price_long      = na
    float last_armed_cvd_long        = na
    float last_armed_price_short_oi  = na
    float last_armed_oi_short        = na
    float last_armed_price_long_oi   = na
    float last_armed_oi_long         = na
    float last_armed_price_short_obv = na
    float last_armed_obv_short       = na
    float last_armed_price_long_obv  = na
    float last_armed_obv_long        = na
    float last_armed_price_short_usdt= na
    float last_armed_usdt_short      = na
    float last_armed_price_long_usdt = na
    float last_armed_usdt_long       = na
    float last_armed_price_short_rsi = na
    float last_armed_rsi_short       = na
    float last_armed_price_long_rsi  = na
    float last_armed_rsi_long        = na

    bool  trig_cvd_short             = false
    bool  trig_cvd_long              = false
    bool  trig_oi_short              = false
    bool  trig_oi_long               = false
    bool  trig_obv_short             = false
    bool  trig_obv_long              = false
    bool  trig_usdt_short            = false
    bool  trig_usdt_long             = false
    bool  trig_prem_short            = false
    bool  trig_prem_long             = false
    bool  trig_srsi_short            = false
    bool  trig_srsi_long             = false
    bool  trig_rsi_short             = false
    bool  trig_rsi_long              = false
    bool  trig_macd_short            = false
    bool  trig_macd_long             = false
    bool  trig_aroon_short           = false
    bool  trig_aroon_long            = false
    bool  prem_snapped_short         = false
    bool  prem_snapped_long          = false
    
    float cum_vol_short     = 0.0
    float cum_tp_vol_short  = 0.0
    float cum_vol_long      = 0.0
    float cum_tp_vol_long   = 0.0
    bool  was_armed_short   = false
    bool  was_armed_long    = false
    bool  trig_vwap_short   = false
    bool  trig_vwap_long    = false
    float prev_ltf_c        = na
    float prev_vwap_short   = na
    float prev_vwap_long    = na

    int running_top_stack = 0
    int last_top_idx      = -10
    int running_bot_stack = 0
    int last_bot_idx      = -10

    float bullPulse = 0.0
    float bearPulse = 0.0
    bool acv_pulse_locked = false

    float max_nw_slope = 0.0
    float max_nw_accel = 0.0
    for idx_nw = 20 to lengthInput - 3
        float s1 = math.abs(zNW.get(idx_nw) - zNW.get(idx_nw+1))
        float s2 = math.abs(zNW.get(idx_nw+1) - zNW.get(idx_nw+2))
        float a1 = math.abs(s1 - s2)
        if s1 > max_nw_slope
            max_nw_slope := s1
        if a1 > max_nw_accel
            max_nw_accel := a1
            
    bool final_vwap_sf = false
    bool final_vwap_lf = false
    bool final_armed_short = false
    bool final_armed_long = false

    for i = lengthInput - 1 to 0
        int idx = bar_index - i
        
        if idx - last_top_idx > 3
            running_top_stack := 0
        if idx - last_bot_idx > 3
            running_bot_stack := 0
            
        float val_eU = zExtUp.get(i)
        float val_iU = zIntUp.get(i)
        float val_iD = zIntDn.get(i)
        float val_eD = zExtDn.get(i)
        float val_c  = arr_close.get(i)
        
        float val_mid = (val_eU + val_iU + val_iD + val_eD) / 4.0
        float envWidth = val_eU - val_eD
        float bandWidth = val_iU - val_iD
        float spreadRatio = math.max(0.0, math.min(1.0, bandWidth / envWidth))
        float halfEnv = envWidth / 2.0
        float pricePos = math.max(-1.0, math.min(1.0, (val_c - val_mid) / halfEnv))
        float weso_val = pricePos * (0.3 + 0.7 * spreadRatio)
        
        if na(prev_ema)
            prev_ema := weso_val
        else
            prev_ema := alpha * weso_val + (1.0 - alpha) * prev_ema
            
        weso_pts.push(chart.point.from_index(idx, weso_val))
        
        float current_hp = hpEnable ? zHP.get(i) : 0.0
        float prev_hp    = hpEnable ? ((i + 1 < lengthInput) ? zHP.get(i + 1) : current_hp) : 0.0
        float hp_slope   = current_hp - prev_hp
        
        float current_sg = sgEnable ? zSG.get(i) : 0.0
        float prev_sg    = sgEnable ? ((i + 1 < lengthInput) ? zSG.get(i + 1) : current_sg) : 0.0
        float sg_slope   = current_sg - prev_sg
        
        bool hp_bull = not hpEnable or hp_slope >= 0
        bool hp_bear = not hpEnable or hp_slope <= 0
        bool sg_bull = not sgEnable or sg_slope >= 0
        bool sg_bear = not sgEnable or sg_slope <= 0
        
        int transp_bull = hp_bull ? (sg_bull ? 0 : 50) : 85
        int transp_bear = hp_bear ? (sg_bear ? 0 : 50) : 85
        
        float hist_mean = arr_meta_mean.get(i)
        float hist_std  = arr_meta_std.get(i)

        if not na(track_weso)
            if track_weso < 0.5 and track_weso > -0.5
                active_regime := 0
            if track_weso >= 0.5 and active_regime != -1
                if val_eU <= track_eU or weso_val < track_weso
                    int tr_i = bar_index - track_idx
                    float tr_hp_slope = hpEnable ? (zHP.get(tr_i) - (tr_i + 1 < lengthInput ? zHP.get(tr_i + 1) : zHP.get(tr_i))) : 0.0
                    float tr_sg_slope = sgEnable ? (zSG.get(tr_i) - (tr_i + 1 < lengthInput ? zSG.get(tr_i + 1) : zSG.get(tr_i))) : 0.0
                    bool tr_hp_bear = not hpEnable or tr_hp_slope <= 0
                    bool tr_sg_bear = not sgEnable or tr_sg_slope <= 0
                    int tr_transp_bear = tr_hp_bear ? (tr_sg_bear ? 0 : 50) : 85
                    
                    float tr_val_h = arr_highs.get(tr_i)
                    float tr_atr   = arr_atr14.get(tr_i)
                    
                    string tooltip_top = "Whittaker Kinematic Top\nAlignment: " + (tr_transp_bear == 0 ? "Solid (Passes HP & SG)" : (tr_transp_bear == 50 ? "Dim (Passes HP)" : "Dimmest (Fails Macro)"))
                    label.new(x=track_idx, y=tr_val_h + tr_atr * 1.5, text="▼", style=label.style_none, textcolor=color.new(color.red, tr_transp_bear), size=size.small, tooltip=tooltip_top, force_overlay=true)
                    active_regime := -1
                    
            if track_weso <= -0.5 and active_regime != 1
                if val_eD >= track_eD or weso_val > track_weso
                    int tr_i = bar_index - track_idx
                    float tr_hp_slope = hpEnable ? (zHP.get(tr_i) - (tr_i + 1 < lengthInput ? zHP.get(tr_i + 1) : zHP.get(tr_i))) : 0.0
                    float tr_sg_slope = sgEnable ? (zSG.get(tr_i) - (tr_i + 1 < lengthInput ? zSG.get(tr_i + 1) : zSG.get(tr_i))) : 0.0
                    bool tr_hp_bull = not hpEnable or tr_hp_slope >= 0
                    bool tr_sg_bull = not sgEnable or tr_sg_slope >= 0
                    int tr_transp_bull = tr_hp_bull ? (tr_sg_bull ? 0 : 50) : 85
                    
                    float tr_val_l = arr_lows.get(tr_i)
                    float tr_atr   = arr_atr14.get(tr_i)
                    
                    string tooltip_bot = "Whittaker Kinematic Bottom\nAlignment: " + (tr_transp_bull == 0 ? "Solid (Passes HP & SG)" : (tr_transp_bull == 50 ? "Dim (Passes HP)" : "Dimmest (Fails Macro)"))
                    label.new(x=track_idx, y=tr_val_l - tr_atr * 1.5, text="▲", style=label.style_none, textcolor=color.new(color.green, tr_transp_bull), size=size.small, tooltip=tooltip_bot, force_overlay=true)
                    active_regime := 1

            // 🔔 EXACT WESO CROSSING ALERTS: Detected dynamically on the live edge (i == 0)
            if i == 0
                if track_weso < 0.5 and weso_val >= 0.5
                    alert_weso_ob := true
                    alert("WESO Crossed Overbought (+0.5)", alert.freq_once_per_bar_close)
                if track_weso > -0.5 and weso_val <= -0.5
                    alert_weso_os := true
                    alert("WESO Crossed Oversold (-0.5)", alert.freq_once_per_bar_close)
                    
        track_weso := weso_val
        track_eU  := val_eU
        track_eD  := val_eD
        track_idx := idx

        float slope = 0.0
        if not na(val_prev)
            slope := prev_ema - val_prev
        val_prev := prev_ema
        
        if prev_ema >= 0.0
            if slope > 0.0
                hist_bull_acc.push(chart.point.from_index(idx, 0.0))
                hist_bull_acc.push(chart.point.from_index(idx, prev_ema))
                hist_bull_acc.push(chart.point.from_index(idx, 0.0))
            else
                hist_bull_dec.push(chart.point.from_index(idx, 0.0))
                hist_bull_dec.push(chart.point.from_index(idx, prev_ema))
                hist_bull_dec.push(chart.point.from_index(idx, 0.0))
        else
            if slope > 0.0
                hist_bear_dec.push(chart.point.from_index(idx, 0.0))
                hist_bear_dec.push(chart.point.from_index(idx, prev_ema))
                hist_bear_dec.push(chart.point.from_index(idx, 0.0))
            else
                hist_bear_acc.push(chart.point.from_index(idx, 0.0))
                hist_bear_acc.push(chart.point.from_index(idx, prev_ema))
                hist_bear_acc.push(chart.point.from_index(idx, 0.0))

        if hilbertEnable
            float current_nw = zNW.get(i)
            float prev_nw    = (i + 2 < lengthInput) ? zNW.get(i + 2) : current_nw
            float iPhase = current_nw - val_mid
            float quad   = (current_nw - prev_nw) * 8.0 
            float phase  = calc_atan2(quad, iPhase)
            
            float sine_val = math.sin(phase)
            float lead_val = math.sin(phase + math.pi / 4.0)
            
            float cur_h = arr_highs.get(i)
            float cur_l = arr_lows.get(i)
            float cur_atr = arr_atr14.get(i)
            
            int conf_bull_curr = transp_bull == 0 ? 100 : (transp_bull == 50 ? 50 : 15)
            int conf_bear_curr = transp_bear == 0 ? 100 : (transp_bear == 50 ? 50 : 15)
            
            if not na(track_sine) and not na(track_lead)
                if track_sine <= track_lead and sine_val > lead_val
                    string tt_phase_bull = "Hilbert Phase Shift: Bullish\nAlignment: " + (transp_bull == 0 ? "Solid (Passes All)" : (transp_bull == 50 ? "Dim (Passes HP)" : "Dimmest (Fails All)"))
                    label.new(x=idx, y=cur_l - cur_atr * 2.0, text="◆", style=label.style_none, textcolor=color.new(color.green, transp_bull), size=size.small, tooltip=tt_phase_bull, force_overlay=true)
                else if track_sine >= track_lead and sine_val < lead_val
                    string tt_phase_bear = "Hilbert Phase Shift: Bearish\nAlignment: " + (transp_bear == 0 ? "Solid (Passes All)" : (transp_bear == 50 ? "Dim (Passes HP)" : "Dimmest (Fails All)"))
                    label.new(x=idx, y=cur_h + cur_atr * 2.0, text="◆", style=label.style_none, textcolor=color.new(color.red, transp_bear), size=size.small, tooltip=tt_phase_bear, force_overlay=true)
                
                if track_lead < 0.95 and lead_val >= 0.95
                    label.new(x=idx, y=cur_h + cur_atr * 2.5, text="★", style=label.style_none, textcolor=color.black, size=size.small, tooltip="Lead Sine Exhaustion (Top)", force_overlay=true)
                    // 🔔 EXACT HILBERT LEAD CROSSING ALERTS: Detected dynamically on the live edge (i == 0)
                    if i == 0
                        alert_lead_top := true
                        alert("Lead Sine Exhaustion Top (+0.95)", alert.freq_once_per_bar_close)
                else if track_lead > -0.95 and lead_val <= -0.95
                    label.new(x=idx, y=cur_l - cur_atr * 2.5, text="★", style=label.style_none, textcolor=color.black, size=size.small, tooltip="Lead Sine Exhaustion (Bottom)", force_overlay=true)
                    // 🔔 EXACT HILBERT LEAD CROSSING ALERTS: Detected dynamically on the live edge (i == 0)
                    if i == 0
                        alert_lead_bot := true
                        alert("Lead Sine Exhaustion Bottom (-0.95)", alert.freq_once_per_bar_close)
            
            track_sine := sine_val
            track_lead := lead_val
            
            sine_pts.push(chart.point.from_index(idx, sine_val))
            lead_pts.push(chart.point.from_index(idx, lead_val))

        bool is_bear_candle = arr_close.get(i) < arr_open.get(i)
        bool is_bull_candle = arr_close.get(i) > arr_open.get(i)
        
        float current_adx = arr_adx.get(i)
        float nw_up = zNW.get(i) + (zNW_mae.get(i) * nwEnvMult)
        float nw_dn = zNW.get(i) - (zNW_mae.get(i) * nwEnvMult)
        
        bool hit_whittaker_short = arr_highs.get(i) >= val_eU
        bool hit_nw_short        = nwEnvEnable and (arr_highs.get(i) >= nw_up)
        bool hit_prc_short       = prcEnable and i < prcLength and (arr_highs.get(i) >= zPRC.get(i) + prc_std * prcMult)
        bool in_extreme_short    = hit_whittaker_short or hit_nw_short or hit_prc_short
        
        bool hit_whittaker_long  = arr_lows.get(i) <= val_eD
        bool hit_nw_long         = nwEnvEnable and (arr_lows.get(i) <= nw_dn)
        bool hit_prc_long        = prcEnable and i < prcLength and (arr_lows.get(i) <= zPRC.get(i) - prc_std * prcMult)
        bool in_extreme_long     = hit_whittaker_long or hit_nw_long or hit_prc_long

        // AMD Marker Injection
        bool is_amd_sweep_sh = amdEnable and arr_sweep_hi.get(i)
        bool is_amd_sweep_lo = amdEnable and arr_sweep_lo.get(i)

        if is_amd_sweep_sh and in_extreme_short
            label.new(idx, arr_highs.get(i) + (arr_atr14.get(i) * 1.0), "AMD\nSWEEP\n▼", color=color.new(color.black, 50), textcolor=BEAR_COLOR, style=label.style_label_down, size=size.tiny, tooltip="AMD Manipulation Phase\nSweeping into Causal/PRC Boundary", force_overlay=true)

        if is_amd_sweep_lo and in_extreme_long
            label.new(idx, arr_lows.get(i) - (arr_atr14.get(i) * 1.0), "AMD\nSWEEP\n▲", color=color.new(color.black, 50), textcolor=BULL_COLOR, style=label.style_label_up, size=size.tiny, tooltip="AMD Manipulation Phase\nSweeping into Causal/PRC Boundary", force_overlay=true)

        if in_extreme_short
            has_touched_extreme_short := true
        if in_extreme_long
            has_touched_extreme_long := true

        if in_extreme_short
            bars_in_extreme_short += 1
            if bars_in_extreme_short > acvTimeMax
                acv_failed_time_short := true
        else
            bars_in_extreme_short := 0

        if in_extreme_long
            bars_in_extreme_long += 1
            if bars_in_extreme_long > acvTimeMax
                acv_failed_time_long := true
        else
            bars_in_extreme_long := 0

        float curr_tr = arr_tr.get(i)
        float prev_tr = i + 1 < lengthInput ? arr_tr.get(i+1) : curr_tr
        bool is_decelerating = curr_tr <= (prev_tr * 1.5)

        float sig_c = arr_close.get(i)
        float prev_h = i + 1 < lengthInput ? arr_highs.get(i+1) : sig_c
        float prev_l = i + 1 < lengthInput ? arr_lows.get(i+1) : sig_c
        float prev_o = i + 1 < lengthInput ? arr_open.get(i+1) : arr_open.get(i)

        bool is_bear_choch = strictLiveEdge ? (sig_c < prev_l) : (sig_c < prev_o)
        bool is_bull_choch = strictLiveEdge ? (sig_c > prev_h) : (sig_c > prev_o)

        float atr_ratio = arr_atr_ratio.get(i)
        bool is_acv_bull_cascade = atr_ratio > 1.5 and hp_slope > 0
        bool is_acv_bear_cascade = atr_ratio > 1.5 and hp_slope < 0

        float barRange_p = math.max(arr_highs.get(i) - arr_lows.get(i), syminfo.mintick)
        float closeLoc = (arr_close.get(i) - arr_lows.get(i)) / barRange_p
        bool bullConv = closeLoc >= (1.0 - pulseCloseZone) and arr_close.get(i) > arr_open.get(i)
        bool bearConv = closeLoc <= pulseCloseZone and arr_close.get(i) < arr_open.get(i)

        bullPulse := bullConv ? math.min(bullPulse + 1.0, float(pulseCap)) : bullPulse * pulseDecay
        bearPulse := bearConv ? math.min(bearPulse + 1.0, float(pulseCap)) : bearPulse * pulseDecay

        float saturation = math.max(bullPulse, bearPulse) / float(pulseCap)
        int dominantDir = bullPulse > bearPulse ? 1 : (bearPulse > bullPulse ? -1 : 0)

        if saturation >= pulseLockThresh
            acv_pulse_locked := true
        else if saturation <= pulseReleaseThresh
            acv_pulse_locked := false

        bool is_pulse_lock_short = useAcvPulse and acv_pulse_locked and dominantDir == 1
        bool is_pulse_lock_long  = useAcvPulse and acv_pulse_locked and dominantDir == -1
        
        float live_nw_slope = i + 1 < lengthInput ? math.abs(zNW.get(i) - zNW.get(i+1)) : 0.0
        float live_nw_slope_prev = i + 2 < lengthInput ? math.abs(zNW.get(i+1) - zNW.get(i+2)) : 0.0
        float live_nw_accel = math.abs(live_nw_slope - live_nw_slope_prev)
        bool acv_lockdown = live_nw_slope > (max_nw_slope * ikbBoundMult) or live_nw_accel > (max_nw_accel * ikbBoundMult)

        if i == 0
            acv_lockdown_0 := acv_lockdown

        float atr_curr  = arr_atr3.get(i)
        float atr_prev1 = i + 1 < lengthInput ? arr_atr3.get(i+1) : atr_curr
        float atr_prev2 = i + 2 < lengthInput ? arr_atr3.get(i+2) : atr_prev1
        float delta1 = atr_curr - atr_prev1
        float delta2 = atr_prev1 - atr_prev2
        float g_force = delta1 - delta2
        bool is_gforce_accelerating = g_force > 0

        float body = math.abs(arr_close.get(i) - arr_open.get(i))
        float rng  = math.max(arr_highs.get(i) - arr_lows.get(i), syminfo.mintick)
        float body_ratio = body / rng
        bool is_absorption = (arr_raw_vol.get(i) > arr_vol_mean.get(i) * 1.5) and (body_ratio < 0.3)
        
        bool gforce_lock = useAcvGForce and is_gforce_accelerating and not (useAcvAbsorb and is_absorption)

        bool is_armed_short_global = has_touched_extreme_short and not is_acv_bull_cascade and not acv_lockdown and not is_pulse_lock_short and not gforce_lock
        bool is_armed_long_global  = has_touched_extreme_long  and not is_acv_bear_cascade and not acv_lockdown and not is_pulse_lock_long and not gforce_lock

        bool pass_choch_short = not useAcvChoch or is_bear_choch
        bool pass_choch_long  = not useAcvChoch or is_bull_choch
        bool pass_decel       = not useAcvDecel or is_decelerating
        bool pass_time_short  = not useAcvTime  or not acv_failed_time_short or is_bear_choch
        bool pass_time_long   = not useAcvTime  or not acv_failed_time_long  or is_bull_choch

        if is_armed_short_global and pass_choch_short and pass_decel and pass_time_short
            acv_cleared_short_state := true

        if is_armed_long_global and pass_choch_long and pass_decel and pass_time_long
            acv_cleared_long_state := true

        if val_c < hist_mean
            last_armed_price_short      := na
            last_armed_cvd_short        := na
            trig_cvd_short              := false
            last_armed_price_short_oi   := na
            last_armed_oi_short         := na
            trig_oi_short               := false
            last_armed_price_short_obv  := na
            last_armed_obv_short        := na
            trig_obv_short              := false
            last_armed_price_short_usdt := na
            last_armed_usdt_short       := na
            trig_usdt_short             := false
            last_armed_price_short_rsi  := na
            last_armed_rsi_short        := na
            trig_srsi_short             := false
            trig_rsi_short              := false
            trig_macd_short             := false
            trig_aroon_short            := false
            trig_prem_short             := false
            prem_snapped_short          := false
            cum_vol_short               := 0.0
            cum_tp_vol_short            := 0.0
            trig_vwap_short             := false
            was_armed_short             := false
            acv_cleared_short_state     := false
            acv_failed_time_short       := false
            has_touched_extreme_short   := false

        if val_c > hist_mean
            last_armed_price_long       := na
            last_armed_cvd_long         := na
            trig_cvd_long               := false
            last_armed_price_long_oi    := na
            last_armed_oi_long          := na
            trig_oi_long                := false
            last_armed_price_long_obv   := na
            last_armed_obv_long         := na
            trig_obv_long               := false
            last_armed_price_long_usdt  := na
            last_armed_usdt_long        := na
            trig_usdt_long              := false
            last_armed_price_long_rsi   := na
            last_armed_rsi_long         := na
            trig_srsi_long              := false
            trig_rsi_long               := false
            trig_macd_long              := false
            trig_aroon_long             := false
            trig_prem_long              := false
            prem_snapped_long           := false
            cum_vol_long                := 0.0
            cum_tp_vol_long             := 0.0
            trig_vwap_long              := false
            was_armed_long              := false
            acv_cleared_long_state      := false
            acv_failed_time_long        := false
            has_touched_extreme_long    := false

        bool c_b_1 = c_b_1_s[i], bool c_bu_1 = c_bu_1_s[i]
        bool o_b_1 = o_b_1_s[i], bool o_bu_1 = o_bu_1_s[i]
        bool r_b_1 = r_b_1_s[i], bool r_bu_1 = r_bu_1_s[i]
        bool srsi_b_1 = srsi_b_1_s[i], bool srsi_bu_1 = srsi_bu_1_s[i]
        bool p_b_1 = p_b_1_s[i], bool p_bu_1 = p_bu_1_s[i]
        bool oi_b_1 = oi_b_1_s[i], bool oi_bu_1 = oi_bu_1_s[i]
        bool u_b_1 = u_b_1_s[i], bool u_bu_1 = u_bu_1_s[i]
        bool m_b_1 = m_b_1_s[i], bool m_bu_1 = m_bu_1_s[i]
        bool a_b_1 = a_b_1_s[i], bool a_bu_1 = a_bu_1_s[i]

        float curr_ltf_v  = arr_vwap_v.get(i)
        float curr_ltf_h3 = arr_vwap_h3.get(i)
        float curr_ltf_c  = arr_vwap_c.get(i)
        
        bool vwap_sf = false
        bool vwap_lf = false
        
        if is_armed_short_global
            if not was_armed_short
                cum_vol_short    := 0.0
                cum_tp_vol_short := 0.0
            cum_vol_short    += curr_ltf_v
            cum_tp_vol_short += curr_ltf_v * curr_ltf_h3
            float curr_vwap_short = cum_vol_short > 0 ? cum_tp_vol_short / cum_vol_short : curr_ltf_c
            if was_armed_short and not na(prev_ltf_c) and not na(prev_vwap_short)
                if prev_ltf_c >= prev_vwap_short and curr_ltf_c < curr_vwap_short
                    vwap_sf := true
            prev_vwap_short := curr_vwap_short
        was_armed_short := is_armed_short_global

        if is_armed_long_global
            if not was_armed_long
                cum_vol_long    := 0.0
                cum_tp_vol_long := 0.0
            cum_vol_long    += curr_ltf_v
            cum_tp_vol_long += curr_ltf_v * curr_ltf_h3
            float curr_vwap_long = cum_vol_long > 0 ? cum_tp_vol_long / cum_vol_long : curr_ltf_c
            if was_armed_long and not na(prev_ltf_c) and not na(prev_vwap_long)
                if prev_ltf_c <= prev_vwap_long and curr_ltf_c > curr_vwap_long
                    vwap_lf := true
            prev_vwap_long := curr_vwap_long
        was_armed_long := is_armed_long_global
        prev_ltf_c := curr_ltf_c

        float cur_atr_m = arr_atr14.get(i)
        float top_y_base_m = arr_highs.get(i) + cur_atr_m * 0.75
        float bot_y_base_m = arr_lows.get(i) - cur_atr_m * 0.75
        float y_step_m = cur_atr_m * 0.35

        if is_armed_short_global
            if c_b_1 and not trig_cvd_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_CVD, style=label.style_none, size=size.normal, tooltip="CVD Divergence (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_cvd_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="CVD Divergence [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_cvd_short := true
                    
            if o_b_1 and not trig_obv_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_OBV, style=label.style_none, size=size.normal, tooltip="OBV Divergence (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_obv_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="OBV Divergence [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_obv_short := true

            if r_b_1 and not trig_rsi_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_RSI, style=label.style_none, size=size.normal, tooltip="RSI Extreme (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_rsi_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="RSI Extreme [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_rsi_short := true

            if srsi_b_1 and not trig_srsi_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_SRSI, style=label.style_none, size=size.normal, tooltip="Stoch RSI Overbought (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_srsi_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="Stoch RSI [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_srsi_short := true
                    
            if m_b_1 and not trig_macd_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_MACD, style=label.style_none, size=size.normal, tooltip="MACD Divergence (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_macd_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="MACD Divergence [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_macd_short := true

            if a_b_1 and not trig_aroon_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_AROON, style=label.style_none, size=size.normal, tooltip="Aroon Extreme (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_aroon_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="Aroon Extreme [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_aroon_short := true

            if p_b_1 and not trig_prem_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_YELL, style=label.style_none, size=size.normal, tooltip="Premium Snap (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_prem_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="PREM Snap [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_prem_short := true

            if oi_b_1 and not trig_oi_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_YELL, style=label.style_none, size=size.normal, tooltip="OI Exhaustion (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_oi_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="OI Exhaustion [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_oi_short := true

            if u_b_1 and not trig_usdt_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_YELL, style=label.style_none, size=size.normal, tooltip="USDT.D Macro Fracture (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_usdt_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="USDT Fracture [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_usdt_short := true

            if vwap_sf and not trig_vwap_short
                if acv_cleared_short_state and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=C_VWAP, style=label.style_none, size=size.normal, tooltip="Anchor VWAP Reclaim (Short)", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_vwap_short := true
                else if showHidden and is_bear_candle
                    label.new(idx, top_y_base_m + (running_top_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="VWAP Reclaim [BLOCKED]", force_overlay = true)
                    running_top_stack += 1, last_top_idx := idx, trig_vwap_short := true

        if is_armed_long_global
            if c_bu_1 and not trig_cvd_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_CVD, style=label.style_none, size=size.normal, tooltip="CVD Divergence (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_cvd_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="CVD Divergence [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_cvd_long := true

            if o_bu_1 and not trig_obv_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_OBV, style=label.style_none, size=size.normal, tooltip="OBV Divergence (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_obv_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="OBV Divergence [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_obv_long := true

            if r_bu_1 and not trig_rsi_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_RSI, style=label.style_none, size=size.normal, tooltip="RSI Extreme (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_rsi_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="RSI Extreme [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_rsi_long := true

            if srsi_bu_1 and not trig_srsi_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_SRSI, style=label.style_none, size=size.normal, tooltip="Stoch RSI Oversold (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_srsi_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="Stoch RSI [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_srsi_long := true

            if m_bu_1 and not trig_macd_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_MACD, style=label.style_none, size=size.normal, tooltip="MACD Divergence (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_macd_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="MACD Divergence [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_macd_long := true

            if a_bu_1 and not trig_aroon_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_AROON, style=label.style_none, size=size.normal, tooltip="Aroon Extreme (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_aroon_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="Aroon Extreme [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_aroon_long := true

            if p_bu_1 and not trig_prem_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_YELL, style=label.style_none, size=size.normal, tooltip="Premium Snap (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_prem_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="PREM Snap [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_prem_long := true

            if oi_bu_1 and not trig_oi_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_YELL, style=label.style_none, size=size.normal, tooltip="OI Exhaustion (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_oi_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="OI Exhaustion [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_oi_long := true

            if u_bu_1 and not trig_usdt_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_YELL, style=label.style_none, size=size.normal, tooltip="USDT.D Macro Fracture (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_usdt_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="USDT Fracture [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_usdt_long := true

            if vwap_lf and not trig_vwap_long
                if acv_cleared_long_state and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=C_VWAP, style=label.style_none, size=size.normal, tooltip="Anchor VWAP Reclaim (Long)", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_vwap_long := true
                else if showHidden and is_bull_candle
                    label.new(idx, bot_y_base_m - (running_bot_stack * y_step_m), "●", textcolor=color.gray, style=label.style_none, size=size.normal, tooltip="VWAP Reclaim [BLOCKED]", force_overlay = true)
                    running_bot_stack += 1, last_bot_idx := idx, trig_vwap_long := true

        if i == 0
            final_vwap_sf := vwap_sf
            final_vwap_lf := vwap_lf
            final_armed_short := is_armed_short_global
            final_armed_long  := is_armed_long_global

    h_v_1 := f_update_state(final_vwap_sf, final_vwap_lf, h_v_1)

    if showHUD
        table.cell(hud, 0, 0, "SIGNAL", text_color = color.white, bgcolor = color.new(color.gray, 60), text_size=size.small)
        table.cell(hud, 1, 0, f_pad(tf1_name), text_color = color.white, bgcolor = color.new(color.gray, 60), text_size=size.small)
        table.cell(hud, 2, 0, f_pad(tf2_name), text_color = color.white, bgcolor = color.new(color.gray, 60), text_size=size.small)
        table.cell(hud, 3, 0, f_pad(tf3_name), text_color = color.white, bgcolor = color.new(color.gray, 60), text_size=size.small)
        table.cell(hud, 4, 0, f_pad(tf4_name), text_color = color.white, bgcolor = color.new(color.gray, 60), text_size=size.small)

        f_fill_hud_row(hud, 1, "WESO",  color.white, h_w_1, h_w_2, h_w_3, h_w_4)
        f_fill_hud_row(hud, 2, "PHASE", color.white, h_ph_1, h_ph_2, h_ph_3, h_ph_4)
        f_fill_hud_row(hud, 3, "CVD",   C_CVD, h_c_1, h_c_2, h_c_3, h_c_4)
        f_fill_hud_row(hud, 4, "OBV",   C_OBV, h_o_1, h_o_2, h_o_3, h_o_4)
        f_fill_hud_row(hud, 5, "RSI",   C_RSI, h_r_1, h_r_2, h_r_3, h_r_4)
        f_fill_hud_row(hud, 6, "StRSI", C_SRSI, h_s_1, h_s_2, h_s_3, h_s_4)
        f_fill_hud_row(hud, 7, "MACD",  C_MACD, h_m_1, h_m_2, h_m_3, h_m_4)
        f_fill_hud_row(hud, 8, "AROON", C_AROON, h_a_1, h_a_2, h_a_3, h_a_4)
        f_fill_hud_row(hud, 9, "PREM",  C_YELL, h_p_1, h_p_2, h_p_3, h_p_4)
        f_fill_hud_row(hud, 10, "OI",    C_YELL, h_oi_1, h_oi_2, h_oi_3, h_oi_4)
        f_fill_hud_row(hud, 11, "USDT",  C_YELL, h_u_1, h_u_2, h_u_3, h_u_4)
        f_fill_hud_row(hud, 12, "VWAP", C_VWAP, h_v_1, "--", "--", "--")

        string global_state = "AWAITING DIRECTION..."
        if acv_lockdown_0
            global_state := "ACV LOCKDOWN 🛑"
        else if final_armed_short
            global_state := "ARMED (SHORT) ▼"
        else if final_armed_long
            global_state := "ARMED (LONG) ▲"
        
        table.cell(hud, 0, 13, "STATE:", text_color=color.gray, bgcolor=color.new(color.black, 70), text_size=size.small)
        table.cell(hud, 1, 13, global_state, text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small, text_halign=text.align_center)
        table.merge_cells(hud, 1, 13, 4, 13)

    if acv_lockdown_0
        box.new(left=bar_index - 5, top=global_max_h + global_chart_h * 5.0, right=bar_index, bottom=math.max(0.0000001, global_min_l - global_chart_h * 5.0), border_color=na, bgcolor=color.new(color.maroon, 80), force_overlay=true)

    polyline.new(weso_pts, line_color = color.blue, line_width = 2)
    polyline.new(hist_bull_acc, line_color = COL_BULL_ACC, line_width = 3)
    polyline.new(hist_bull_dec, line_color = COL_BULL_DEC, line_width = 3)
    polyline.new(hist_bear_acc, line_color = COL_BEAR_ACC, line_width = 3)
    polyline.new(hist_bear_dec, line_color = COL_BEAR_DEC, line_width = 3)
    
    if hilbertEnable
        polyline.new(sine_pts, line_color = SINE_COLOR, line_width = 1)
        polyline.new(lead_pts, line_color = LEAD_COLOR, line_width = 1, line_style = line.style_dashed)

    int active_attractors = 2 + (hpEnable ? 1 : 0) + (sgEnable ? 1 : 0) + (nwEnvEnable ? 2 : 0) + (prcEnable ? 3 : 0)
    int attractor_lookback = math.min(120, lengthInput - 2)
    int attractor_step = 2
    
    if (attractor_lookback / attractor_step) * active_attractors > 350
        attractor_step := int(math.ceil((attractor_lookback * active_attractors) / 350.0))
        
    int attractor_lines = int(attractor_lookback / attractor_step) * active_attractors
    int ikb_lines_reserve = ikbEnable ? 50 : 0
    int available_web_lines = math.max(20, 490 - ikb_lines_reserve - attractor_lines)
    int web_lines_per_step = 3 + (webBandsInput * 2) 
    int max_web_steps = math.max(1, available_web_lines / web_lines_per_step)
    
    int web_lookback = math.min(120, lengthInput - 2)
    int web_step = math.max(1, int(math.ceil(web_lookback * 1.0 / max_web_steps)))
    
    int w_start = int(math.floor(web_lookback / web_step) * web_step)
    if w_start > 0
        for i = w_start to web_step by web_step
            int idx1 = bar_index - i
            int idx2 = bar_index - (i - web_step)
            
            float v_eU1 = zExtUp.get(i)
            float v_eU2 = zExtUp.get(i - web_step)
            float v_eD1 = zExtDn.get(i)
            float v_eD2 = zExtDn.get(i - web_step)
            float v_mid1 = (v_eU1 + zIntUp.get(i) + zIntDn.get(i) + v_eD1) / 4.0
            float v_mid2 = (v_eU2 + zIntUp.get(i - web_step) + zIntDn.get(i - web_step) + v_eD2) / 4.0
            
            float vol1 = arr_volMods.get(i)
            float vol2 = arr_volMods.get(i - web_step)
            
            line.new(idx1, v_eU1, idx2, v_eU2, color=color.new(BEAR_COLOR, 0), force_overlay=true, width=2)
            line.new(idx1, v_eD1, idx2, v_eD2, color=color.new(BULL_COLOR, 0), force_overlay=true, width=2)
            line.new(idx1, v_mid1, idx2, v_mid2, color=color.new(MID_COLOR, 60), force_overlay=true, style=line.style_dashed)
            
            for b = 1 to webBandsInput
                float baseFrac = b / (webBandsInput + 1.0)
                float f1 = baseFrac * vol1
                float f2 = baseFrac * vol2
                
                float w_up1 = v_mid1 + f1 * (v_eU1 - v_mid1)
                float w_dn1 = v_mid1 + f1 * (v_eD1 - v_mid1)
                float w_up2 = v_mid2 + f2 * (v_eU2 - v_mid2)
                float w_dn2 = v_mid2 + f2 * (v_eD2 - v_mid2)
                int transp = math.round(100.0 - (20.0 + baseFrac * 25.0))
                
                line.new(idx1, w_up1, idx2, w_up2, color=color.new(BEAR_COLOR, transp), force_overlay=true, width=1)
                line.new(idx1, w_dn1, idx2, w_dn2, color=color.new(BULL_COLOR, transp), force_overlay=true, width=1)

    int a_start = int(math.floor(attractor_lookback / attractor_step) * attractor_step)
    if a_start > 0
        for i = a_start to attractor_step by attractor_step
            int idx1 = bar_index - i
            int idx2 = bar_index - (i - attractor_step)
            
            line.new(idx1, zNW.get(i), idx2, zNW.get(i - attractor_step), color=color.new(NW_COLOR, 0), force_overlay=true, width=3)
            line.new(idx1, zNW_f.get(i), idx2, zNW_f.get(i - attractor_step), color=color.new(NW_F_COLOR, 0), force_overlay=true, width=2)
            
            if prcEnable and i < prcLength
                float curr_prc = zPRC.get(i)
                float prev_prc = zPRC.get(i - attractor_step)
                if not na(curr_prc) and not na(prev_prc)
                    line.new(idx1, curr_prc, idx2, prev_prc, color=color.new(#00BFFF, 30), force_overlay=true, width=2)
                    line.new(idx1, curr_prc + prc_std * prcMult, idx2, prev_prc + prc_std * prcMult, color=color.new(BEAR_COLOR, 60), force_overlay=true, width=1, style=line.style_dashed)
                    line.new(idx1, curr_prc - prc_std * prcMult, idx2, prev_prc - prc_std * prcMult, color=color.new(BULL_COLOR, 60), force_overlay=true, width=1, style=line.style_dashed)

            if nwEnvEnable
                float up1 = zNW.get(i) + zNW_mae.get(i) * nwEnvMult
                float dn1 = zNW.get(i) - zNW_mae.get(i) * nwEnvMult
                float up2 = zNW.get(i - attractor_step) + zNW_mae.get(i - attractor_step) * nwEnvMult
                float dn2 = zNW.get(i - attractor_step) - zNW_mae.get(i - attractor_step) * nwEnvMult
                
                line.new(idx1, up1, idx2, up2, color=NW_ENV_COLOR, force_overlay=true, width=1, style=line.style_dashed)
                line.new(idx1, dn1, idx2, dn2, color=NW_ENV_COLOR, force_overlay=true, width=1, style=line.style_dashed)
            
            if hpEnable
                line.new(idx1, zHP.get(i), idx2, zHP.get(i - attractor_step), color=HP_COLOR, force_overlay=true, width=2)
            if sgEnable
                line.new(idx1, zSG.get(i), idx2, zSG.get(i - attractor_step), color=SG_COLOR, force_overlay=true, width=2)

    if hmmEnable and hmmBgEnable
        float top_y = global_max_h + global_chart_h * 5.0
        float bot_y = math.max(0.0000001, global_min_l - global_chart_h * 5.0)
        
        int   start_regime_idx = na
        int   current_reg_state = na
        
        for i = lengthInput - 1 to 0
            int idx = bar_index - i
            float reg_val = zRegime.get(i)
            int state = reg_val > 0.3 ? 1 : (reg_val < -0.3 ? -1 : 0)
            
            if na(current_reg_state)
                current_reg_state := state
                start_regime_idx := idx
            else if state != current_reg_state or i == 0
                color bg_col = current_reg_state == 1 ? color.new(BULL_COLOR, 92) : (current_reg_state == -1 ? color.new(BEAR_COLOR, 92) : color.new(MID_COLOR, 95))
                box.new(left=start_regime_idx, top=top_y, right=idx, bottom=bot_y, border_color=na, bgcolor=bg_col, force_overlay=true)
                current_reg_state := state
                start_regime_idx := idx

    if ikbEnable
        int valid_paths_count = 0
        int lines_drawn = 0
        float current_std = arr_meta_std.get(0)
        float p_y_start = zNW.get(0)
        float live_nw_slope_0 = math.abs(zNW.get(0) - zNW.get(1))

        for p = 1 to ikbPaths
            float prev_proj_val = p_y_start
            float current_sim_slope = live_nw_slope_0
            bool is_valid = true
            array.clear(sim_path_vals)

            for k = 1 to ikbLength
                float drift = math.random(-1.0, 1.0) * (current_std * 0.5)
                float proj_val = prev_proj_val + drift
                float sim_slope = math.abs(proj_val - prev_proj_val)
                float sim_accel = math.abs(sim_slope - current_sim_slope)

                if sim_slope > (max_nw_slope * ikbBoundMult) or sim_accel > (max_nw_accel * ikbBoundMult)
                    is_valid := false
                    break

                sim_path_vals.push(proj_val)
                current_sim_slope := sim_slope
                prev_proj_val := proj_val

            if is_valid
                valid_paths_count += 1
                if lines_drawn + sim_path_vals.size() <= 50 // Enforce strict 50 line budget for IKB
                    float p_y = p_y_start
                    for k = 0 to sim_path_vals.size() - 1
                        float n_y = sim_path_vals.get(k)
                        line.new(bar_index + k, p_y, bar_index + k + 1, n_y, color=color.new(IKB_COLOR, 85), width=1, force_overlay=true)
                        p_y := n_y
                        lines_drawn += 1

        if valid_paths_count > 0
            label.new(bar_index + ikbLength, p_y_start, text="Binding Matrix\nSurviving Paths: " + str.tostring(valid_paths_count), style=label.style_label_left, color=color.new(color.black, 30), textcolor=IKB_COLOR, size=size.tiny, tooltip="Inverse Kernel Bounding\nProjected Future Trajectory", force_overlay=true)

    if hmmEnable
        int hmm_step = math.max(1, int(math.ceil(lengthInput / 150.0))) 
        int hmm_start = int(math.floor(lengthInput / hmm_step) * hmm_step)
        if hmm_start > 0
            for i = hmm_start to hmm_step by hmm_step
                int idx1 = bar_index - i
                int idx2 = bar_index - (i - hmm_step)
                float reg1 = zRegime.get(i)
                color col1 = reg1 > 0.3 ? BULL_COLOR : reg1 < -0.3 ? BEAR_COLOR : MID_COLOR
                line.new(idx1, -0.85, idx2, -0.85, color=col1, width=6, force_overlay=false)

// 🔔 GLOBAL ALERT CONDITIONS FOR TRADINGVIEW MENU
alertcondition(alert_weso_ob, title="WESO Overbought (+0.5)", message="WESO crossed above 0.5")
alertcondition(alert_weso_os, title="WESO Oversold (-0.5)", message="WESO crossed below -0.5")
alertcondition(alert_lead_top, title="Lead Sine Top (+0.95)", message="Lead Sine crossed above 0.95")
alertcondition(alert_lead_bot, title="Lead Sine Bottom (-0.95)", message="Lead Sine crossed below -0.95")
alertcondition(alert_lead_top, title="Lead Sine Top (+0.50)", message="Lead Sine crossed above 0.50")
alertcondition(alert_lead_bot, title="Lead Sine Bottom (-0.50)", message="Lead Sine crossed below -0.50")
````
