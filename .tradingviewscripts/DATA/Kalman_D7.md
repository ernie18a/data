<!-- tradingview-pine-id: PUB;807bfbf7b139432c86d7eec612ed1cb9 -->
<!-- tradingviewscripts-format: 1 -->
# Kalman D7

Source: https://www.tradingview.com/script/c75aF3t1-Fractional-EMA-Kalman-Filter-D7/

## Description

Fractional EMA Kalman Filter [D7]

1. Description
Fractional EMA Kalman Filter [D7] is an experimental smoothing and state-estimation tool that combines a Kalman filter framework with a fractional EMA input. The objective is to create a filter that remains subdued during ranging conditions while retaining responsiveness when directional structure emerges. By integrating adaptive variance logic and residual-based state control, D7 aims to balance smoothness, reactivity, and structural awareness.[image]https://www.tradingview.com/x/dDFFyRSw/[/image]
2. Construct
D7 uses a single-state Kalman architecture with the following components: 
[*]State (X)
The current filtered estimate of price, updated using a fractional-length EMA measurement input. This is what the filter believes the true underlying value to be at each step.

[*]Innovation
The difference between the incoming measurement and the current state estimate; the correction signal the filter acts on. Innovation = EMA − X

[*]Kalman Gain (K)
The adaptive weighting factor that balances trust between the new measurement and the prior prediction. K = P / (P + R)

[*]P - State uncertainty variance
Represents how uncertain the filter is about its current state estimate.

[*]Q - Process noise variance
Represents uncertainty in how the state evolves between steps. Higher Q makes the filter more responsive to change.

[*]R - Measurement noise variance
 Represents uncertainty in the incoming measurement. Higher R makes the filter more sceptical of new observations.State Update
[pine]X := X + K × Innovation
P := (1 − K) × (P + Q)
[/pine]
3. Features

[*]Fractional EMA Layer 
Applies a double sub‑integer EMA length (e.g., 0.5‑period) to generate a high‑resolution measurement signal that responds to structural volatility and regime transitions faster than conventional smoothing. The fractional EMA is not intended to estimate price, but to precondition the observation space so that regime changes manifest as large, legible innovations. By transforming the input prior to filtering, the measurement emphasizes moments of structural change rather than steady‑state behavior, improving the responsiveness of adaptive state estimation.[image]https://www.tradingview.com/x/R4Kr5uxs/[/image]
[*]Innovation Engine 
Computes the innovation/residual error squared and normalizes by ATR, producing a scale-consistent noise estimate that adapts across instruments without manual recalibration.[image]https://www.tradingview.com/x/GqJt2LbO/[/image]
[*]Dynamic Q/R Model 
 Process noise (Q) and measurement noise (R) are derived from short and long lookback windows of the normalized residual variance. This allows the filter to adapt using its own tracking error rather than relying solely on external volatility measures. When prediction error is consistently large, the filter knows its model is inadequate for current conditions and adjusts accordingly. 

Most Kalman filter implementations use either fixed Q or R values or; external volatility proxies such as ATR to modulate Q/R. These approaches respond to price volatility, but not to whether the filter itself is tracking effectively.[image]https://www.tradingview.com/x/mEKLRZaj/[/image]
[*]R Gate 
A sensitivity floor applied to the residual variance. This ensures R does not fall below a structurally meaningful minimum, preventing the filter from becoming overconfident during low-volatility periods.

4. Rationale

[*]Fractional EMA
A fractional EMA intentionally overshoots and oscillates around price, producing a bounded zig‑zag structure. This behavior is intentional by design: the oscillation self‑balances under steady conditions, while disruptions to that balance generate exaggerated transient values during regime or volatility shifts. Compared to raw price or conventionally smoothed inputs, the fractional EMA yields an information‑dense measurement stream in which structural transitions are amplified, improving innovation visibility for adaptive Kalman filtering.[image]https://www.tradingview.com/x/73Bv7nEH/[/image]

[*]Adaptive Q/R 
Rather than relying on fixed noise parameters, D7 continuously derives Q and R from residual behavior. This allows the filter to self-tune across changing market conditions without manual recalibration:
      -  During directional persistence, responsiveness increases
      -  During noisy or unstable conditions, caution or scepticism increases
      -  Prediction error becomes part of the control loop rather than external tuning[image]https://www.tradingview.com/x/Ir30IT5S/[/image]
A core design goal of D7 is structural suppression during sideways conditions. When price lacks directional intent, residual variance decreases, causing Q to fall relative to R. This reduces the Kalman gain, and the filter trusts its prior state estimate more than incoming measurements. The result is a filter that compresses and flattens naturally, rather than oscillating as conventional moving averages do through range-bound price action.[image]https://www.tradingview.com/x/De5oxP2R/[/image]

5. Display Overview
The chart displays both a baseline Kalman filter and a faster-reacting Kalman filter simultaneously, allowing users to visually compare responsiveness, smoothness, and structural behavior under different parameter settings. This dual-filter layout is intended to help users observe how changes in Q/R dynamics and filter sensitivity affect state estimation across varying market conditions.

The fractional EMA input can also be optionally displayed. This observation is turned off by default to preserve chart clarity but may be enabled for users who wish to examine the relationship between the conditioned input signal and the resulting Kalman state estimates.[image]https://www.tradingview.com/x/FCenWgRy/[/image]
6. Default Settings
EMA lengths: 0.5, 0.5

Kalman base and fast filter settings:
Q multiplier (process noise): 0.002, 0.005
R (measurement noise): 50, 50
R Gate: 1, 1 

7. Future Development
D7 serves as the foundational implementation of the Kalman filter within the ET Massif framework. Subsequent versions will introduce external regime-aware Q/R modulation and multi-state architecture, progressively increasing adaptability while preserving the core filter mechanics established here.

日本語概要 (Japanese Summary)
Fractional EMA Kalman Filter [D7] は、カルマンフィルターに Fractional EMA（小数期間EMA） を組み合わせた研究用インジケーターです。Fractional EMA とは、期間設定に整数ではなく小数点以下の値を用いる手法です。これにより、従来のEMAよりも短期的な価格変化やボラティリティの拡大を、より高精度かつ敏感に捉えることが可能になります。本インジケーターは、レンジ相場ではラインが水平（フラット）に推移してノイズを軽減する一方、トレンド発生時には極めて素早く反応するように設計されています。

中文概要（Chinese Summary）
Fractional EMA Kalman Filter [D7] 是一款結合卡爾曼濾波（Kalman Filter）與 分數階 EMA（Fractional EMA） 的研究型技術指標。所謂的 Fractional EMA，是指打破傳統整數週期的限制，採用小數參數進行計算。這項技術能更細膩地捕捉短期價格波動與結構性變化，提供比傳統指標更高的靈敏度。本指標的核心設計在於：橫盤整理時維持平滑走勢以過濾雜訊，而在趨勢發動時展現極速反應。此外，它能透過殘差（Residuals）動態調整參數 Q（過程雜訊）與 R（測量雜訊），確保在不同波動率下的自我適應能力。

Disclaimer:
This script is a research tool for market structure analysis and educational purposes only. It does not constitute financial advice. Trading involves risk.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © et20tradeview

//@version=6
indicator("Kalman D7", overlay=true)


//pre --- EMA inputs ---
show_pul = input.bool(defval=false, title="Show EMA", group ="EMA Settings")
source = input(close, title="Source", group ="EMA Settings")
factor = input.float(defval= 0.5 , minval=0.1, step=0.1, group ="EMA Settings", tooltip = "EMA length1")   //first ema
factor2 = input.float(defval= 0.5 , minval=0.1, step=0.1, group ="EMA Settings",tooltip="EMA Length2")    // second ema


//1. --- standard values ---
qlen  =5  // short Q lookback

// base Kalman filter settings
r_ratiob   = input.int(50, "R base", step=5, group="Kalman Settings", tooltip="Uncertainty measurement lookback")
q_ratiob   = input.float(0.002, "q multiplier base", step=0.001, group="Kalman Settings", tooltip="Process noise variance, higher values makes the filter more responsive to change")
r_gate_multb      = input.float(1, "R Gate Multiplier base", step=0.1 , group="Kalman Settings", tooltip="R sensitivity baseline")


// shorter Kalman filter  more responsive with q = 0.005
r_ratios   = input.int(50, "R fast", step=5, group="Kalman Settings", tooltip="Uncertainty measurement lookback")
q_ratios   = input.float(0.005, "q multiplier fast", step=0.001, group="Kalman Settings", tooltip="Process noise variance, higher values makes the filter more responsive to change")
r_gate_mults      = input.float(1, "R Gate Multiplier fast", step=0.1, group="Kalman Settings", tooltip="R sensitivity baseline")


// --- 2. Helper Functions ---

pine_ema(src, length) => 
    alpha = 2 / (length + 1)
    sum = src
    
    //The original code by Tradingview
    // sum = 0
    //sum := na(sum[1]) ? sma(src, length) : alpha * src + (1 - alpha) * nz(sum[1])
    
    sum := alpha * src + (1 - alpha) * nz(sum[1])

//------------------
clamp(x, a, b) =>
    math.min(math.max(x, a), b)


// --- 3. Generate state measurement----
ema1 = pine_ema(source, factor)
ema2 = pine_ema(ema1, factor2)


// --- 4. The Kalman Loop ---

// --- 4a. Initialize Kalman ---
var float kf_stateb = na
var float p_covb    = 1.0
var float kf_states = na
var float p_covs    = 1.0


// ---4b. Kalman function ---

calc_kalman(float src, float p_state, float p_cv, float R_raw, float Q_raw, float res_var, float q_ratio, float gate_mult) =>
    float q_process = clamp(nz(Q_raw, 0.1), 0.001, 10.0) * q_ratio
    
    float r_dynamic_floor = res_var * gate_mult
    float r_adaptive = math.max(nz(R_raw, 1.0), r_dynamic_floor)

    float current_p_cov = p_cv + q_process
    float k_gain = current_p_cov / (current_p_cov + r_adaptive + 1e-10)
    
    float next_state = nz(p_state, src)
    float next_cov   = current_p_cov

    if not na(k_gain)
        next_state := next_state + k_gain * (src - next_state)
        next_cov   := (1 - k_gain) * current_p_cov
    
    [next_state, next_cov]


//-----end kalman function


// --- 5. Kalman filter baseline version ---

//  ---I Calculate residual---
residualb = ema2 - nz(kf_stateb[1], ema2)

// --- II Normalized Variance ---
vol_baseb = ta.atr(14)
vol_baseb := math.max(vol_baseb, 1e-6)

// --- III Squared variance---
// We square both the residual and the ATR to maintain unit consistency (Variance/Variance)
residual_varianceb = math.pow(residualb, 2) / math.pow(vol_baseb, 2)

// --- IV  Noise Estimation (R and Q) ---
// R is the long-term baseline of variance
R_rawb = ta.rma(residual_varianceb, r_ratiob)
R_rawb := nz(R_rawb, 1.0)

// Q is the short-term burst of variance (the "Process Noise")
Q_rawb = ta.rma(residual_varianceb, qlen)
Q_rawb := nz(Q_rawb, 0.1)


// --- V Call the kalman function ---
[new_valb, new_covb] = calc_kalman(ema2, kf_stateb, p_covb, R_rawb, Q_rawb, residual_varianceb, q_ratiob , r_gate_multb)

// --- VI Update state for the next bar ---
kf_stateb := new_valb
p_covb    := new_covb

//--- VII Smooth out microtwitch ---
smoothb= pine_ema(kf_stateb, 3)

////////////////////////////////////////////////////////////////////////////////

// --- 6. Kalman filter fast version ---

//  ---I Calculate residual---
residuals = ema2 - nz(kf_states[1], ema2)

// --- II Normalized Variance ---
vol_bases = ta.atr(14)
vol_bases := math.max(vol_bases, 1e-6)

// --- III Squared variance---
// We square both the residual and the ATR to maintain unit consistency (Variance/Variance)
residual_variances = math.pow(residuals, 2) / math.pow(vol_bases, 2)

// --- IV  Noise Estimation (R and Q) ---
// R is the long-term baseline of variance
R_raws = ta.rma(residual_variances, r_ratios)
R_raws := nz(R_raws, 1.0)

// Q is the short-term burst of variance (the "Process Noise")
Q_raws = ta.rma(residual_variances, qlen)
Q_raws := nz(Q_raws, 0.1)


// --- V Call the kalman function ---
[new_vals, new_covs] = calc_kalman(ema2, kf_states, p_covs, R_raws, Q_raws, residual_variances, q_ratios , r_gate_mults)

// --- VI Update state for the next bar ---
kf_states := new_vals
p_covs    := new_covs

//--- VII Smooth out microtwitch ---
smooths= pine_ema(kf_states, 5)

////////////////////////////////////////////////////////////////////////////////


// --- 7.  Plots ---
//plot EMA
//p1 not in use
p2 = plot( show_pul  ? ema2: na, "Pumori", color=color.new(color.purple, 70), force_overlay = true)
p3 =  plot(show_pul  ? ema2 : na, offset=-1, color=color.new(color.purple, 70), force_overlay = true)
fill(p2, p3, color=color.new(#69359C, 70), title="Lag Shading")


//Plot Kalman filter
p4 = plot(smoothb, color=color.rgb(230, 65, 195) ,linewidth=2) 
p5 = plot(smooths, color=color.rgb(80, 100, 240) ,linewidth=2) 

fillColor = smooths > smoothb ? color.new(color.aqua, 80) : color.new(color.red, 80)
fill(p4, p5, color=fillColor, title="Kalman fill")

//debugging
//plot(R_rawb, color=color.blue)
//plot(Q_rawb , color=color.teal)
//plot(residual_varianceb, color=color.yellow)
````
