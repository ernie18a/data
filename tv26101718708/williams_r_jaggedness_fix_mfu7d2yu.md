# Williams %R Jaggedness fix

- url: https://www.tradingview.com/script/MFu7d2Yu-Williams-R-Jaggedness-fix/
- type: indicator
- pine_id: PUB;61d568efc51845eebf1a9732ca3a0a47
- version: 3.0

## Description

[I. THE PROBLEM OF RETAIL JAGGEDNESS]
The standard Williams %R is extremely jagged. Relying on a naive (Highest - Close) / (Highest - Lowest) look-back formula makes it a victim of spatial illusion. It is highly vulnerable to "salt-and-pepper" noise, intraday microstructure stop-hunts, and high-frequency volatility spikes. It generates an erratic, jagged signal that triggers false regime shifts, trapping retail liquidity. 

[II. THE MULTI-STAGE SOLUTION] Solving the jaggedness problem is not about applying a single, lagging moving average. It requires a continuous-time signal processing pipeline. I developed 4, sovereign hypotheses to isolate the true kinematic intent of the market.



► HYPOTHESIS I: The Robust Nonlinear Butterworth %R (RNB-R)

The Mechanism: Amplitude and Noise Filtering.

The Execution: We cleanse the raw data using a 3-period Median Filter to instantly reject 1-bar liquidity sweeps without introducing lag. The resulting %R is then dynamically smoothed via a Volatility-Adaptive SuperSmoother. The lookback adapts kinematically—tightening during explosive volatility to capture breakouts, and expanding during consolidation to ignore chop.

► HYPOTHESIS II: The Decycled Zero-Lag Cycle Oscillator (DZL-R)

The Mechanism: Frequency Cancellation.

The Execution: We abandon the concept of "averaging" entirely. Using a 48-bar High-Pass filter, we isolate and subtract the high-frequency spectral noise directly from the price (Decycling). By mapping the Williams %R onto this Decycled Price, we produce a zero-lag, wave-like signal that perfectly reflects pure trend movement while ignoring micro-structural noise.

► HYPOTHESIS III: The IMF-Extracted Persistent Shape Wave (IMF-W)

The Mechanism: Spectral Shape Fitting & Empirical Mode Decomposition (EMD).

The Execution: We deconstruct the continuous price manifold into its intrinsic cyclical modes. We discard IMF 1 (high-frequency noise) and the residual (ultra-slow drift). By reconstructing the asset using only IMF 2 and IMF 3, we force the Williams %R to measure purely persistent, rhythmic structural cycles.

► HYPOTHESIS IV: The Bipolar Inverse Fisher Williams %R (BIF-R)

The Mechanism: Probability Distribution Transformation.

The Execution: To maximize state persistence, we smooth the standard oscillator with a 2-pole Gaussian filter, normalize it, and compress it through an Inverse Fisher Transform. This mathematical thermodynamic shift forces the oscillator into a bimodal, polarized state. It snaps quickly between extremes and stays there, eliminating nervous jaggedness in favor of pure regime tokenization.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// Extracted and Architected by THE ALPHA COUNCIL
//@version=6
indicator("Williams %R Multi-Stage Synthesizer [Alpha Council]", "W%R Synthesizer", overlay = false)

//---------------------------------------------------------------------------------------------------------------------}
// Constants & Colors
//---------------------------------------------------------------------------------------------------------------------{
color COLOR_BULL   = #089981
color COLOR_BEAR   = #f23645
color COLOR_NEUT   = color.gray

//---------------------------------------------------------------------------------------------------------------------}
// Inputs & Multi-Routing
//---------------------------------------------------------------------------------------------------------------------{
string OPTION_NONE = "None (Disabled)"
string OPTION_0  = "Normal %R"
string OPTION_1  = "RNB-R (Median + Adaptive SuperSmoother)"
string OPTION_2  = "DZL-R (Decycled Zero-Lag)"
string OPTION_3  = "IMF-W (Empirical Mode Decomposition)"
string OPTION_4  = "BIF-R (Inverse Fisher Gaussian)"
string OPTION_5  = "MMP-F (Michaelis-Menten Flow)"
string OPTION_6  = "BZM-O (Belousov-Zhabotinsky)"
string OPTION_7  = "LSR-I (Lyapunov Stability)"
string OPTION_8  = "QDW-R (Quantum Denoised)"
string OPTION_9  = "MEP-I (Max Entropy)"
string OPTION_10 = "CFP-R (Caputo Fractional)"
string OPTION_11 = "NDF-O (Neutral Delay)"
string OPTION_12 = "SCD-I (Convergence Damping)"
string OPTION_13 = "HGA-S (HMM-Gas SuperSmoother)"
string OPTION_14 = "WPD-S (Wavelet-PCA Denoised)"
string OPTION_15 = "CK-%R (CEEMDAN-Kalman)"
string OPTION_16 = "TA-ZLS (Topologically Adaptive)"
string OPTION_17 = "W%X (Jurik Smoothed %R)"
string OPTION_18 = "DW%X (Double Jurik Smoothed %R)"
string OPTION_19 = "NG-W%X (No-Gap Jurik Smoothed %R)"

var string[] ALL_OPTIONS = array.from(OPTION_NONE, OPTION_0, OPTION_1, OPTION_2, OPTION_3, OPTION_4, OPTION_5, OPTION_6, OPTION_7, OPTION_8, OPTION_9, OPTION_10, OPTION_11, OPTION_12, OPTION_13, OPTION_14, OPTION_15, OPTION_16, OPTION_17, OPTION_18, OPTION_19)

string h1Input      = input.string(OPTION_0, "Primary Hypothesis", options=[OPTION_NONE, OPTION_0, OPTION_1, OPTION_2, OPTION_3, OPTION_4, OPTION_5, OPTION_6, OPTION_7, OPTION_8, OPTION_9, OPTION_10, OPTION_11, OPTION_12, OPTION_13, OPTION_14, OPTION_15, OPTION_16, OPTION_17, OPTION_18, OPTION_19], group="Confluence Matrix")
string h2Input      = input.string(OPTION_15, "Secondary Hypothesis", options=[OPTION_NONE, OPTION_0, OPTION_1, OPTION_2, OPTION_3, OPTION_4, OPTION_5, OPTION_6, OPTION_7, OPTION_8, OPTION_9, OPTION_10, OPTION_11, OPTION_12, OPTION_13, OPTION_14, OPTION_15, OPTION_16, OPTION_17, OPTION_18, OPTION_19], group="Confluence Matrix")
string h3Input      = input.string(OPTION_17, "Tertiary Hypothesis", options=[OPTION_NONE, OPTION_0, OPTION_1, OPTION_2, OPTION_3, OPTION_4, OPTION_5, OPTION_6, OPTION_7, OPTION_8, OPTION_9, OPTION_10, OPTION_11, OPTION_12, OPTION_13, OPTION_14, OPTION_15, OPTION_16, OPTION_17, OPTION_18, OPTION_19], group="Confluence Matrix")

int lengthInput     = input.int(14, "Base Lookback Length", minval=2)

//---------------------------------------------------------------------------------------------------------------------}
// Heavy Compute Functions & Mathematics
//---------------------------------------------------------------------------------------------------------------------{
// Standard %R Calculation Function with Dynamic Series Length Support
f_calc_wpr(float src, float h, float l, series int len) =>
    float highestHigh = ta.highest(h, len)
    float lowestLow   = ta.lowest(l, len)
    float denominator = highestHigh - lowestLow
    float safeDenom   = denominator == 0 ? 0.0001 : denominator
    -100.0 * (highestHigh - src) / safeDenom

// Sovereign Dynamic EMA Calculation (Bypasses v6 simple int constraints)
f_dynamic_ema(float src, series int len) =>
    float alpha = 2.0 / (math.max(1, len) + 1.0)
    var float ema_val = na
    ema_val := na(ema_val[1]) ? src : alpha * src + (1.0 - alpha) * nz(ema_val[1])
    ema_val

// Jurik Moving Average Calculation
f_jma(float _src, int _length) =>
    float phaseRatio = 1.5 + 50.0 / 100.0
    float beta = 0.45 * (_length - 1) / (0.45 * (_length - 1) + 2)
    float alpha = math.pow(beta, 2.0)
    var float jma = 0.0
    var float e0 = 0.0
    var float e1 = 0.0
    var float e2 = 0.0
    e0 := (1 - alpha) * _src + alpha * nz(e0[1], _src)
    e1 := (_src - e0) * (1 - beta) + beta * nz(e1[1], 0)
    e2 := (e0 + phaseRatio * e1 - nz(jma[1], _src)) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1], 0)
    jma := e2 + nz(jma[1], _src)
    jma

// Hypothesis 0: Standard %R
float wpr_normal = f_calc_wpr(close, high, low, lengthInput)

//---------------------------------------------------------------------------------------------------------------------}
// Hypotheses 1-14 Computations
//---------------------------------------------------------------------------------------------------------------------{
// H1: RNB-R 
float med_c = ta.median(close, 3)
float base_rnb_r = f_calc_wpr(med_c, ta.median(high, 3), ta.median(low, 3), lengthInput)
float vol = ta.stdev(close, 20)
float vol_baseline = ta.sma(vol, 50)
float vol_ratio = vol_baseline == 0 ? 1.0 : vol / vol_baseline
float dynamic_len = lengthInput * math.max(0.5, math.min(2.0, 1.0 / vol_ratio))
float a1_ss = math.exp(-1.414 * math.pi / dynamic_len)
float b1_ss = 2.0 * a1_ss * math.cos(1.414 * math.pi / dynamic_len)
float c1_ss = 1.0 - b1_ss - (-a1_ss * a1_ss)
var float wpr_rnb = na
wpr_rnb := c1_ss * base_rnb_r + b1_ss * nz(wpr_rnb[1], base_rnb_r) + (-a1_ss * a1_ss) * nz(wpr_rnb[2], base_rnb_r)

// H2: DZL-R
float alpha_hp = (math.cos(0.707 * 2.0 * math.pi / 48.0) + math.sin(0.707 * 2.0 * math.pi / 48.0) - 1.0) / math.cos(0.707 * 2.0 * math.pi / 48.0)
var float hp = na
hp := (1.0 - alpha_hp / 2.0) * (1.0 - alpha_hp / 2.0) * (close - 2.0 * nz(close[1], close) + nz(close[2], close)) + 2.0 * (1.0 - alpha_hp) * nz(hp[1], 0) - (1.0 - alpha_hp) * (1.0 - alpha_hp) * nz(hp[2], 0)
float decycled_price = close - hp
float wpr_dzl = f_calc_wpr(decycled_price, decycled_price, decycled_price, lengthInput)

// H3: IMF-W
float imf2 = ta.sma(close, 5) - ta.sma(close, 20)
float imf3 = ta.sma(close, 20) - ta.sma(close, 60)
float reconstructed_signal = imf2 + imf3
float wpr_imf = f_calc_wpr(reconstructed_signal, reconstructed_signal, reconstructed_signal, lengthInput)

// H4: BIF-R
float w_g = 2.0 * math.pi / lengthInput
float beta_g = 2.415 * (1.0 - math.cos(w_g)) / math.max(math.sin(w_g), 0.0001)
float alpha_g = -beta_g + math.sqrt(beta_g * beta_g + 2.0 * beta_g)
float c1_g = alpha_g * alpha_g
var float gauss_r = na
gauss_r := c1_g * wpr_normal + 2.0 * (1.0 - alpha_g) * nz(gauss_r[1], wpr_normal) - (1.0 - alpha_g) * (1.0 - alpha_g) * nz(gauss_r[2], wpr_normal)
float exp_2x = math.exp(2.0 * (0.1 * (gauss_r + 50.0)))
float wpr_bif = (((exp_2x - 1.0) / (exp_2x + 1.0)) + 1.0) * 50.0 - 100.0

// H5: MMP-F
float mom_mm = close - nz(close[1])
float km_mm = ta.stdev(close, lengthInput)
float rate_mm = 100.0 * mom_mm / ((km_mm == 0 ? 0.0001 : km_mm) + math.abs(mom_mm))
var float wpr_mmpf = -50.0
wpr_mmpf := math.max(-100.0, math.min(0.0, nz(wpr_mmpf[1]) + rate_mm * 0.1))

// H6: BZM-O
var float bz_x = 0.1
var float bz_y = 0.1
var float bz_z = 0.1
float drive_x = ta.roc(close, 5) / 100.0
bz_x := math.max(0.001, bz_x + (77.27 * (bz_y - bz_x * bz_y + bz_x - 0.002 * math.pow(bz_x, 2))) * 0.01 + drive_x)
bz_y := math.max(0.001, bz_y + ((1.0 / 77.27) * (-bz_y - bz_x * bz_y + 1.0 * bz_z)) * 0.01)
bz_z := math.max(0.001, bz_z + (0.161 * (bz_x - bz_z)) * 0.01)
float wpr_bzm = -100.0 + math.min(bz_x * 50.0, 100.0)

// H7: LSR-I
float lyap_exp = math.log((math.abs(close - nz(close[1])) + 0.0001) / (math.abs(nz(close[1]) - nz(close[2])) + 0.0001))
float wpr_lsr = -50.0 + math.max(-50.0, math.min(50.0, ta.sma(lyap_exp, lengthInput) * 10.0))

// H8: QDW-R
float q_potential = ta.wma(close, lengthInput)
float q_wave = math.cos((close - q_potential) / (ta.stdev(close, lengthInput) + 0.001))
float wpr_qdw = -50.0 + (q_wave * 50.0)

// H9: MEP-I
float mep_mean = ta.sma(close, lengthInput)
float mep_boltz = math.exp(-math.pow(close - mep_mean, 2) / (2.0 * (ta.variance(close, lengthInput) + 0.0001)))
float wpr_mep = -100.0 * (1.0 - mep_boltz)

// H10: CFP-R
float frac_deriv = close - 0.5 * nz(close[1]) - 0.125 * nz(close[2]) - 0.0625 * nz(close[3])
float wpr_cfp = f_calc_wpr(close + frac_deriv, high + frac_deriv, low + frac_deriv, lengthInput)

// H11: NDF-O
float ndf_price = close + (close - nz(close[1])) + 0.5 * (nz(close[5]) - nz(close[6]))
float wpr_ndf = f_calc_wpr(ndf_price, high, low, lengthInput)

// H12: SCD-I
float scd_chi = (volume / (ta.stdev(close, lengthInput) + 0.001)) / (2.0 * (math.abs(ta.change(close)) + 0.001))
float wpr_scd = -50.0 + math.max(-50.0, math.min(50.0, (scd_chi - 1.0) * 10.0)) 

// H13: HGA-S
float hga_len = lengthInput * math.max(0.5, math.min(3.0, 1.0 + math.abs(ta.change(close) / (ta.stdev(close, lengthInput) + 0.001))))
float a1_hga = math.exp(-1.414 * math.pi / hga_len)
float b1_hga = 2.0 * a1_hga * math.cos(1.414 * math.pi / hga_len)
var float hga_smooth = na
hga_smooth := (1.0 - b1_hga - (-a1_hga * a1_hga)) * close + b1_hga * nz(hga_smooth[1], close) + (-a1_hga * a1_hga) * nz(hga_smooth[2], close)
float wpr_hga = f_calc_wpr(hga_smooth, hga_smooth + ta.tr, hga_smooth - ta.tr, lengthInput)

// H14: WPD-S
float haar_a = (close + nz(close[1])) / 1.414
float haar_d = (close - nz(close[1])) / 1.414
float pca_weight = haar_a / (math.abs(haar_a) + math.abs(haar_d) + 0.001)
float wpd_recon = close * pca_weight + ta.sma(close, lengthInput) * (1.0 - pca_weight)
float wpr_wpd = f_calc_wpr(wpd_recon, high, low, lengthInput)

//---------------------------------------------------------------------------------------------------------------------}
// Hypothesis 15: CK-%R (CEEMDAN-Kalman %R)
//---------------------------------------------------------------------------------------------------------------------{
// 1. Structural CEEMDAN Approximation (Subtract high-frequency IMF components)
float imf1_ck = close - nz(ta.sma(close, 4), close)
float imf2_ck = nz(ta.sma(close, 4), close) - nz(ta.sma(close, 8), close)
float clean_ck = close - imf1_ck - imf2_ck

// 2. Base %R mapped to clean price
float tr_safe_ck = nz(ta.tr, close * 0.001)
float base_wpr_ck = f_calc_wpr(clean_ck, clean_ck + tr_safe_ck, clean_ck - tr_safe_ck, lengthInput)
float safe_base = nz(base_wpr_ck, -50.0)

// 3. 1D Dynamic Kalman Filter State Estimation
var float kf_p = 1.0
var float wpr_ck = -50.0
float kf_r = nz(ta.variance(safe_base, 20), 100.0) + 0.001 // Measurement Noise heavily shielded
float kf_q = 2.0 // Process Noise Covariance
float kf_k = nz(kf_p / (kf_p + kf_r), 0.5) // Kalman Gain

wpr_ck := nz(wpr_ck[1], -50.0) + kf_k * (safe_base - nz(wpr_ck[1], -50.0))
kf_p := (1.0 - kf_k) * nz(kf_p, 1.0) + kf_q

//---------------------------------------------------------------------------------------------------------------------}
// Hypothesis 16: TA-ZLS (Topologically Adaptive Zero-Lag Stochastic)
//---------------------------------------------------------------------------------------------------------------------{
// 1. Topological Complexity Score (via guarded 50-period Efficiency Ratio mapping)
float net_move = math.abs(close - nz(close[50], close))
float tot_move = nz(math.sum(math.abs(close - nz(close[1], close)), 50), 0.0)
float er_ta = tot_move == 0 ? 0.0 : net_move / tot_move
float complexity = nz(1.0 - er_ta, 0.5) // 0 = Pure Trend, 1 = Pure Noise/Chop, shielded by nz()

// 2. Dynamic Parameter Shifting
float dyn_len_ta = lengthInput * (0.5 + complexity) // Expands length when complex, shrinks when trending
int i_dyn_len_ta = math.max(2, int(nz(dyn_len_ta, lengthInput))) // Mathematically guaranteed not to be NA

// 3. Smooth Trending State (Zero-Lag EMA utilizing Sovereign Dynamic function)
float ema1_ta = f_dynamic_ema(close, i_dyn_len_ta)
float ema2_ta = f_dynamic_ema(ema1_ta, i_dyn_len_ta)
float zls_price = 2.0 * ema1_ta - ema2_ta

// 4. Choppy Complex State (Median Adaptive Smoothing utilizing SMA to prevent wma scalar errors)
float med_price_ta = ta.median(close, 5)
float smooth_med_ta = ta.sma(med_price_ta, i_dyn_len_ta)

// 5. Topological Blend mapped to %R
float adapt_price = (complexity * smooth_med_ta) + ((1.0 - complexity) * zls_price)
float wpr_tazls = f_calc_wpr(adapt_price, adapt_price + ta.tr, adapt_price - ta.tr, i_dyn_len_ta)

//---------------------------------------------------------------------------------------------------------------------}
// Hypothesis 17: W%X (Jurik Smoothed %R)
//---------------------------------------------------------------------------------------------------------------------{
// Passing the raw, chaotic Williams %R signal directly into the Zero-Lag Jurik matrix
float wpr_wpx = f_jma(wpr_normal, lengthInput)

//---------------------------------------------------------------------------------------------------------------------}
// Hypothesis 18: DW%X (Double Jurik Smoothed %R)
//---------------------------------------------------------------------------------------------------------------------{
// Dual-layered smoothing matrix on the core signal
float wpr_dwpx = f_jma(wpr_wpx, lengthInput)

//---------------------------------------------------------------------------------------------------------------------}
// Hypothesis 19: NG-W%X (No-Gap Jurik Smoothed %R)
//---------------------------------------------------------------------------------------------------------------------{
// FIX: Isolate calculation entirely from f_calc_wpr and f_jma to guarantee no compiler context bugs
// 1. Calculate True High and True Low safely
float trueHigh = math.max(nz(high), nz(close[1], nz(high)))
float trueLow = math.min(nz(low), nz(close[1], nz(low)))

// 2. Safely get the Highest True High and Lowest True Low
float hh_nogap = ta.highest(trueHigh, lengthInput)
float ll_nogap = ta.lowest(trueLow, lengthInput)
float denom_nogap = hh_nogap - ll_nogap
float safe_denom_nogap = denom_nogap == 0 ? 0.0001 : denom_nogap

// 3. Prevent Division by Zero and NA poisoning
float wpr_nogap = nz(-100.0 * (hh_nogap - nz(close)) / safe_denom_nogap, -50.0)

// 4. Inline Jurik Smoothing Matrix (Guarantees isolation from f_jma multi-instance bug)
float phaseRatio_ng = 1.5 + 50.0 / 100.0
float beta_ng = 0.45 * (lengthInput - 1) / (0.45 * (lengthInput - 1) + 2)
float alpha_ng = math.pow(beta_ng, 2.0)

var float e0_ng = 0.0
var float e1_ng = 0.0
var float e2_ng = 0.0
var float wpr_ngwpx = 0.0

e0_ng := (1 - alpha_ng) * wpr_nogap + alpha_ng * nz(e0_ng[1], wpr_nogap)
e1_ng := (wpr_nogap - e0_ng) * (1 - beta_ng) + beta_ng * nz(e1_ng[1], 0)
e2_ng := (e0_ng + phaseRatio_ng * e1_ng - nz(wpr_ngwpx[1], wpr_nogap)) * math.pow(1 - alpha_ng, 2) + math.pow(alpha_ng, 2) * nz(e2_ng[1], 0)
wpr_ngwpx := e2_ng + nz(wpr_ngwpx[1], wpr_nogap)

//---------------------------------------------------------------------------------------------------------------------}
// Execution Switchboard: Tri-Layer Confluence Routing
//---------------------------------------------------------------------------------------------------------------------{
f_get_osc(string opt) =>
    float osc = switch opt
        OPTION_0 => wpr_normal
        OPTION_1 => wpr_rnb
        OPTION_2 => wpr_dzl
        OPTION_3 => wpr_imf
        OPTION_4 => wpr_bif
        OPTION_5 => wpr_mmpf
        OPTION_6 => wpr_bzm
        OPTION_7 => wpr_lsr
        OPTION_8 => wpr_qdw
        OPTION_9 => wpr_mep
        OPTION_10 => wpr_cfp
        OPTION_11 => wpr_ndf
        OPTION_12 => wpr_scd
        OPTION_13 => wpr_hga
        OPTION_14 => wpr_wpd
        OPTION_15 => wpr_ck
        OPTION_16 => wpr_tazls
        OPTION_17 => wpr_wpx
        OPTION_18 => wpr_dwpx
        OPTION_19 => wpr_ngwpx
        => na
    osc

float osc1 = f_get_osc(h1Input)
float osc2 = f_get_osc(h2Input)
float osc3 = f_get_osc(h3Input)

//---------------------------------------------------------------------------------------------------------------------}
// Visuals: Convergence Overlays
//---------------------------------------------------------------------------------------------------------------------{
hline(-20, "Overbought", color.new(COLOR_BEAR, 50), hline.style_dashed)
hline(-80, "Oversold",   color.new(COLOR_BULL, 50), hline.style_dashed)
hline(-50, "Median",     color.new(COLOR_NEUT, 50), hline.style_dotted)

// Primary Hypothesis (Solid & Dominant)
color osc1_color = osc1 > nz(osc1[1]) ? COLOR_BULL : COLOR_BEAR
plot(osc1, title="Primary Hypothesis", color=osc1_color, linewidth=2)

// Secondary Hypothesis (Translucent Support)
color osc2_color = osc2 > nz(osc2[1]) ? color.new(COLOR_BULL, 40) : color.new(COLOR_BEAR, 40)
plot(osc2, title="Secondary Hypothesis", color=osc2_color, linewidth=1, style=plot.style_line)

// Tertiary Hypothesis (Dotted Matrix Confluence)
color osc3_color = osc3 > nz(osc3[1]) ? color.new(COLOR_BULL, 60) : color.new(COLOR_BEAR, 60)
plot(osc3, title="Tertiary Hypothesis", color=osc3_color, linewidth=1, style=plot.style_circles)
//---------------------------------------------------------------------------------------------------------------------}
````
