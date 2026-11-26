# Kalman Trailing Stop (KTS)

- url: https://www.tradingview.com/script/HBt43voe-Kalman-Trailing-Stop-KTS/
- type: indicator
- pine_id: PUB;10ceeb4255be4ae3b4b30bdff901fcd8
- version: 3.0

## Description

█ [b]OVERVIEW[/b]
 
The [b]Kalman Trailing Stop (KTS) [/b]is an advanced, math-driven trend-following system designed to keep you in winning trades longer while dynamically filtering out market noise.

Instead of relying on static moving averages or basic ATR multipliers, KTS utilizes a [b]2D Kalman Filter[/b] combined with [b]Statistical Digital Signal Processing (DSP)[/b] and Williams Market Structure. It adapts to volatility and volume in real-time, effectively distinguishing between genuine trend shifts and temporary liquidity sweeps.

█ [b]CORE MECHANICS[/b]

[b]1. 2D Kalman Adaptive Trailing Stop[/b]

At the heart of the indicator is a robust 2D Kalman filter that tracks both price level and velocity.

[list]
[*] [b]Volume-Weighted Variance:[/b] The trailing stop becomes highly responsive during high-volume pushes (high trust) and flattens out during low-volume consolidation (low trust), preventing premature stop-outs.
[*] [b]Sigmoid Smoothing & Structural Anchoring:[/b] Instead of jagged, abrupt jumps, the stop uses sigmoid transitions to smoothly glide to new structural floors/ceilings derived from recent Intermediate-Term Highs and Lows (ITH/ITL).
[*] [b]Slope Confirmation:[/b] The trailing stop will only flip its directional bias if the underlying Kalman baseline slope confirms the reversal, neutralizing fake-outs.
[/list]

[b]2. Statistical Plunger Logic (Liquidity Sweeps)[/b]

Markets frequently sweep liquidity beyond technical levels before reversing. The "Plunger" logic mathematically identifies these traps.

[list]
[*] [b]Dynamic Sweep Multiplier:[/b] By tracking the kurtosis (fat-tail distribution) of price returns, the script dynamically expands its sweep threshold during periods of wild volatility.
[*] [b]Wick Filtering:[/b] It detects deep wicks that pierce the Kalman bands and close strongly back within the bar's range, highlighting statistically validated exhaustion points.
[/list]

[b]3. Algorithmic Pyramiding & Volatility Warnings[/b]

[list]
[*] [b]Scale-In Detection:[/b] KTS monitors volume footprints to identify safe zones to add to your position. It looks for a sequence of volume "dry-up" during a pullback, followed by a volume-backed breakout past recent market structure.
[*] [b]Livermore Ejector Concept:[/b] The indicator flags abnormal, massive range expansions that occur [i]against [/i]the prevailing trend, acting as an early warning system for sudden momentum shifts.
[/list]

[b]4. Built-in Risk & Performance Engine[/b]

[list]
[*] [b]Dynamic Position Sizing:[/b] Automatically calculates raw position and pyramid sizes based on your account equity, risk percentage, and maximum leverage.
[*] [b]Live Performance Dashboard:[/b] A built-in HUD tracks both the Global and Recent Profit Factor (PF) of the main trend signals, alongside the real-time distance to your trailing stop.
[/list]

█ [b]VISUAL GUIDE[/b]

[list]
[*] [b]Colored Gradient Band: [/b]The main Kalman Trailing Stop. Green indicates an active long trend; Red indicates an active short trend.
[*] [b]Large Diamonds (♦️):[/b] Main Trend Entries. Triggered when price breaks the Kalman Stop with slope confirmation.
[*] [b]Small Triangles (🔼/🔽): [/b]Bullish and Bearish Plunger signals. These indicate deep liquidity sweeps and wick rejections at statistical extremes.
[*] [b]Small Crosses (➕):[/b] Algorithmic Pyramid signals. Opportunities to scale into the current trend based on volume dry-ups and structural breakouts.
[*] [b]Yellow X-Crosses (❌):[/b] Abnormal Reaction Warnings. Signals a massive volatility spike moving against your active position.
[/list]

█ [b]SETTINGS[/b]

[b]Kalman Trailing Stop Settings[/b]

[list]
[*][b]Kalman Responsiveness: [/b]Adjusts how quickly the system reacts to price changes (1-100).
[*][b]Trailing Stop Distance (SD):[/b] Sets the baseline width of the trailing stop from the Kalman-smoothed price, measured in standard deviations of the True Range. A higher value (e.g., 3.0) gives the trade more breathing room, while a lower value tightens the stop.
[/list]

[b]Disclaimer[/b]

[i]This script is designed for educational and informational purposes only. Trading involves significant risk. The built-in performance table is an un-optimized raw calculation and should not be used as a guarantee of future system profitability.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fdx101
// Upgraded with Kalman Adaptive Trailing Stop & Statistical DSP Plunger Logic.

//@version=6
indicator('Kalman Trailing Stop', overlay = true, shorttitle = "KTS", max_bars_back = 5000)

// --- Inputs ---
group_cycle = "Cycle Configuration"
dominantCyclePeriod = input.int(30, 'Dominant Cycle Period', minval = 5, tooltip = 'The wavelength of the dominant market cycle (e.g., synchronized with CSM).', group = group_cycle)

group_plunger = "Plunger Settings"
closePercentage = input.float(30, 'Wick Filter %', minval = 1, maxval = 50, step = 1, tooltip = 'The close must be within this percentage of the bar\'s range from the extreme.', group = group_plunger) / 100
base_sweep_mult = input.float(1.5, 'Statistical Sweep Multiplier (SD)', minval = 0.5, step=0.1, group = group_plunger, tooltip = "How far outside the Kalman Band the wick must pierce to be considered a true mathematical liquidity sweep.")

group_kf = "Kalman Trailing Stop Settings"
kf_speed = input.int(50, title = 'Kalman Responsiveness (1-100)', minval = 1, maxval = 100, group = group_kf, tooltip = "How fast the Trailing Stop reacts to price changes.")
use_vol_weighting = input.bool(true, title="Volume-Weighted Variance", group=group_kf, tooltip="Dynamically adjusts Kalman responsiveness based on volume. High volume = high trust (fast reaction). Low volume = low trust (flat baseline).")
kf_noise_len = input.int(100, title = 'Noise Variance Window', minval = 10, maxval = 200, group = group_kf)
kf_smooth_len = input.int(5, title='Kalman Smoothing (DEMA)', minval=1, maxval=20, group=group_kf, tooltip="Length of the DEMA smoother applied to the raw Kalman output.")
use_slope_confirm = input.bool(true, title='Use Kalman Slope Confirmation', group=group_kf, tooltip="Only flip the trailing stop if the Kalman baseline slope has also flipped, preventing fake-outs.")
mu_offset = input.float(0.0, "Signal Offset (μ in ATRs)", step=0.1, group=group_kf, tooltip="Trend flip requires price to penetrate the Kalman trailing stop by this many ATRs. Acts as a noise buffer against fake-outs.")
push_factor = input.float(0.2, title="Trend Agreement Push (ATR %)", minval=0.0, maxval=1.0, step=0.05, group=group_kf, tooltip="Actively pushes the trailing stop closer to price when momentum and market structure agree.")
use_sigmoid_smoothing = input.bool(true, title="Use Sigmoid Smoothing", group=group_kf, tooltip="Smooths out jagged vertical jumps in the trailing stop by gliding to the new structural floor.")
sig_len = input.int(1, "Sigmoid Transition Length", group=group_kf)
stop_mult = input.float(3.0, title = 'Trailing Stop Distance (SD)', minval = 0.5, step = 0.1, group = group_kf)
relax_factor = input.float(0.1, 'Volatility Relaxation %', minval=0.0, maxval=1.0, step=0.1, group=group_kf, tooltip="How much the stop is allowed to relax (widen) when market noise suddenly expands. 0.0 = Strict rigid ratchet. 0.5 = Absorbs 50% of volatility shocks.")

group_kf3d = "KF4 3D Oscillator (Mean Reversion)"
use_3d_osc = input.bool(false, "Enable 3D Oscillator State (KF4)", group=group_kf3d, tooltip="Upgrades the Kalman filter to a 3D state tracking Price, Velocity, and an Extremum Oscillator. Useful for scalping or mean-reverting assets to tighten stops at extremes.")
osc_len = input.int(14, "Oscillator Lookback Length", group=group_kf3d)

group_risk = "Risk & Position Sizing"
use_tp = input.bool(false, "Use Take Profit", group=group_risk, tooltip="Enable ATR-based Take Profit.")
tp_mult = input.float(4.0, "Take Profit Multiplier (ATR)", minval=0.5, step=0.1, group=group_risk)
account_size = input.float(10000, "Account Size ($)", group=group_risk)
risk_percent = input.float(2.0, "Risk Per Trade (%)", minval=0.1, step=0.1, group=group_risk) / 100.0
pyramid_factor = input.float(0.5, "Pyramid Size Multiplier", minval=0.1, step=0.1, maxval=1.0, tooltip="Multiplier for scale-in entries. 0.5 = Half Size.", group=group_risk)
max_leverage = input.float(1.0, "Max Account Leverage", minval=0.1, step=0.5, tooltip="1.0 = Cash account. 2.0 = Reg T Margin. 4.0 = Day Trade Margin. Caps position size to prevent impossible orders when stop loss is extremely tight.", group=group_risk)

group_display = "Display Settings"
showBullish = input.bool(false, 'Show Bullish Signals', group = group_display)
showBearish = input.bool(false, 'Show Bearish Signals', group = group_display)
show_williams_ms = input.bool(false, 'Show Market Structure (ITH/ITL)', group = group_display)

//--- Intraday Trading Mode
grp_intraday = 'Intraday Trading Mode'
useIntraday = input.bool(false, 'Enable Intraday Filter', group = grp_intraday, tooltip = 'Filters out overnight gaps from the Monte Carlo simulation by enforcing a trading session.')
sessionStr = input.session("0945-1550", 'Trading Session Window', group = grp_intraday)
sessionTz = input.string("America/New_York", 'Session Timezone', group = grp_intraday)

bool inSession = not useIntraday or not na(time(timeframe.period, sessionStr, sessionTz))

// --- Types ---

type Swing
    int idx
    float price
    bool isHigh

// --- Resolution of Parameters based on Dominant Cycle ---
atrLength = dominantCyclePeriod
plungerLength = math.max(5, math.round(dominantCyclePeriod * 0.35))

// --- Information Filter (Canonical Parameterization) ---
// Highly numerically stable against 64-bit float precision drift compared to standard Kalman
f_kalman2d(float val, float noise_variance, float system_variance, float r_vol, bool use_vol) =>
    var float x0 = na // Level
    var float x1 = na // Velocity
    var float p00 = na
    var float p01 = na
    var float p10 = na
    var float p11 = na
    
    if not na(val) and not na(noise_variance) and not na(system_variance)
        if na(x0)
            x0 := val
            x1 := 0.0
            p00 := 1.0
            p01 := 0.0
            p10 := 0.0
            p11 := 1.0
        else
            float q0 = system_variance
            float q1 = system_variance * 0.1
            
            float R = use_vol and r_vol > 0.0 ? math.max(noise_variance / r_vol, 1e-6) : math.max(noise_variance, 1e-6)
            
            // PREDICT STEP
            float x_pred_0 = x0 + x1
            float x_pred_1 = x1
            
            float p_pred_00 = p00 + p01 + p10 + p11 + q0
            float p_pred_01 = p01 + p11
            float p_pred_10 = p10 + p11
            float p_pred_11 = p11 + q1
            
            // UPDATE STEP
            float y = val - x_pred_0
            float S = p_pred_00 + R
            
            float k0 = p_pred_00 / S
            float k1 = p_pred_10 / S
            
            x0 := x_pred_0 + k0 * y
            x1 := x_pred_1 + k1 * y
            
            float new_p00 = (1.0 - k0) * p_pred_00
            float new_p01 = (1.0 - k0) * p_pred_01
            float new_p10 = -k1 * p_pred_00 + p_pred_10
            float new_p11 = -k1 * p_pred_01 + p_pred_11
            
            p00 := new_p00
            p01 := new_p01
            p10 := new_p10
            p11 := new_p11
            
    [x0, x1, p00 + p11]

// --- 3D Information Filter (KF4) ---
f_kalman3d(float val, float osc_val, float noise_variance, float osc_variance, float system_variance, float r_vol, bool use_vol) =>
    var float x0 = na // Level
    var float x1 = na // Velocity
    var float x2 = na // Oscillator
    
    var float p00 = na
    var float p01 = na
    var float p02 = na
    var float p10 = na
    var float p11 = na
    var float p12 = na
    var float p20 = na
    var float p21 = na
    var float p22 = na
    
    if not na(val) and not na(osc_val) and not na(noise_variance) and not na(osc_variance) and not na(system_variance)
        if na(x0)
            x0 := val
            x1 := 0.0
            x2 := osc_val
            p00 := 1.0
            p01 := 0.0
            p02 := 0.0
            p10 := 0.0
            p11 := 1.0
            p12 := 0.0
            p20 := 0.0
            p21 := 0.0
            p22 := 1.0
        else
            float q0 = system_variance
            float q1 = system_variance * 0.1
            float q2 = system_variance
            
            float R0 = use_vol and r_vol > 0.0 ? math.max(noise_variance / r_vol, 1e-6) : math.max(noise_variance, 1e-6)
            float R1 = use_vol and r_vol > 0.0 ? math.max(osc_variance / r_vol, 1e-6) : math.max(osc_variance, 1e-6)
            
            float xp0 = x0 + x1
            float xp1 = x1
            float xp2 = x2
            
            float pp00 = p00 + p10 + p01 + p11 + q0
            float pp01 = p01 + p11
            float pp02 = p02 + p12
            float pp10 = p10 + p11
            float pp11 = p11 + q1
            float pp12 = p12
            float pp20 = p20 + p21
            float pp21 = p21
            float pp22 = p22 + q2
            
            float y0 = val - xp0
            float y1 = osc_val - xp2
            
            float S00 = pp00 + R0
            float S01 = pp02
            float S10 = pp20
            float S11 = pp22 + R1
            
            float det_S = (S00 * S11) - (S01 * S10)
            if det_S == 0
                det_S := 1e-12
                
            float invS00 = S11 / det_S
            float invS01 = -S01 / det_S
            float invS10 = -S10 / det_S
            float invS11 = S00 / det_S
            
            float k00 = pp00 * invS00 + pp02 * invS10
            float k01 = pp00 * invS01 + pp02 * invS11
            float k10 = pp10 * invS00 + pp12 * invS10
            float k11 = pp10 * invS01 + pp12 * invS11
            float k20 = pp20 * invS00 + pp22 * invS10
            float k21 = pp20 * invS01 + pp22 * invS11
            
            x0 := xp0 + k00 * y0 + k01 * y1
            x1 := xp1 + k10 * y0 + k11 * y1
            x2 := xp2 + k20 * y0 + k21 * y1
            
            float m00 = 1.0 - k00
            float m01 = 0.0
            float m02 = -k01
            float m10 = -k10
            float m11 = 1.0
            float m12 = -k11
            float m20 = -k20
            float m21 = 0.0
            float m22 = 1.0 - k21
            
            float new_p00 = m00 * pp00 + m02 * pp20
            float new_p01 = m00 * pp01 + m02 * pp21
            float new_p02 = m00 * pp02 + m02 * pp22
            float new_p10 = m10 * pp00 + m11 * pp10 + m12 * pp20
            float new_p11 = m10 * pp01 + m11 * pp11 + m12 * pp21
            float new_p12 = m10 * pp02 + m11 * pp12 + m12 * pp22
            float new_p20 = m20 * pp00 + m22 * pp20
            float new_p21 = m20 * pp01 + m22 * pp21
            float new_p22 = m20 * pp02 + m22 * pp22
            
            p00 := new_p00
            p01 := new_p01
            p02 := new_p02
            p10 := new_p10
            p11 := new_p11
            p12 := new_p12
            p20 := new_p20
            p21 := new_p21
            p22 := new_p22
            
    [x0, x1, x2, p00 + p11 + p22]

// --- Double Exponential Moving Average (DEMA) ---
f_dema(float src, int len) =>
    float e1 = ta.ema(src, len)
    float e2 = ta.ema(e1, len)
    2.0 * e1 - e2

// --- Sigmoid Transition Helpers ---
f_clamp(float val, float low_val, float high_val) => math.min(math.max(val, low_val), high_val)

f_sigmoid(float t) =>
    float x = -6.0 + 12.0 * f_clamp(t, 0.0, 1.0)
    float sMin = 1.0 / (1.0 + math.exp(6.0))
    float sMax = 1.0 / (1.0 + math.exp(-6.0))
    float sig = 1.0 / (1.0 + math.exp(-x))
    (sig - sMin) / (sMax - sMin)

// --- Market Structure Engine (ITH/ITL) ---
bool ms_isInside = high <= high[1] and low >= low[1]

var float[] ms_highs = array.new_float()
var float[] ms_lows = array.new_float()
var int[] ms_idx = array.new_int()

if not ms_isInside
    array.unshift(ms_highs, high)
    array.unshift(ms_lows, low)
    array.unshift(ms_idx, bar_index)
    if array.size(ms_highs) > 100
        array.pop(ms_highs)
        array.pop(ms_lows)
        array.pop(ms_idx)

var array<Swing> ms_sths = array.new<Swing>()
var array<Swing> ms_stls = array.new<Swing>()

bool ms_newSTH = false
bool ms_newSTL = false

var float recent_sth = na
var float recent_stl = na

if not ms_isInside and array.size(ms_highs) >= 3
    float h0 = array.get(ms_highs, 0)
    float h1 = array.get(ms_highs, 1)
    float h2 = array.get(ms_highs, 2)
    float l0 = array.get(ms_lows, 0)
    float l1 = array.get(ms_lows, 1)
    float l2 = array.get(ms_lows, 2)
    int idx1 = array.get(ms_idx, 1)
    
    if h1 >= h0 and h1 > h2
        Swing sth = Swing.new(idx1, h1, true)
        array.push(ms_sths, sth)
        ms_newSTH := true
        recent_sth := h1
        if array.size(ms_sths) > 100
            array.shift(ms_sths)
            
    if l1 <= l0 and l1 < l2
        Swing stl = Swing.new(idx1, l1, false)
        array.push(ms_stls, stl)
        ms_newSTL := true
        recent_stl := l1
        if array.size(ms_stls) > 100
            array.shift(ms_stls)

var array<Swing> ms_itls = array.new<Swing>()
var array<Swing> ms_iths = array.new<Swing>()

var float recent_itl = na
var float recent_ith = na

if ms_newSTL and array.size(ms_stls) >= 3
    int n = array.size(ms_stls)
    Swing s0 = array.get(ms_stls, n - 1)
    Swing s1 = array.get(ms_stls, n - 2)
    Swing s2 = array.get(ms_stls, n - 3)
    if s1.price <= s0.price and s1.price < s2.price
        array.push(ms_itls, s1)
        recent_itl := s1.price
        if array.size(ms_itls) > 50
            array.shift(ms_itls)

if ms_newSTH and array.size(ms_sths) >= 3
    int n = array.size(ms_sths)
    Swing s0 = array.get(ms_sths, n - 1)
    Swing s1 = array.get(ms_sths, n - 2)
    Swing s2 = array.get(ms_sths, n - 3)
    if s1.price >= s0.price and s1.price > s2.price
        array.push(ms_iths, s1)
        recent_ith := s1.price
        if array.size(ms_iths) > 50
            array.shift(ms_iths)

// Calculate real-time market noise for the Kalman Filter on Price
float rolling_variance = ta.variance(close, kf_noise_len)
float system_variance_scaled = rolling_variance * math.pow(10.0, (kf_speed - 50) / 10.0)

float rVol = volume / ta.median(volume, 20)
float clamped_rVol = math.max(0.1, math.min(nz(rVol, 1.0), 3.0))

// Calculate Raw Oscillator for 3D state
float low_n = ta.lowest(low, osc_len)
float high_n = ta.highest(high, osc_len)
float raw_osc = (high_n - low_n) == 0 ? 0.5 : (close - low_n) / (high_n - low_n)
float osc_var = ta.variance(raw_osc, kf_noise_len)

// Compute dynamic baseline via 2D or 3D Kalman Filter
float k_level = na
float k_velocity = na
float k_osc = na
float k_ptrace = na

if use_3d_osc
    [l, v, o, p] = f_kalman3d(close, raw_osc, rolling_variance, osc_var, system_variance_scaled, clamped_rVol, use_vol_weighting)
    k_level := l
    k_velocity := v
    k_osc := o
    k_ptrace := p
else
    [l, v, p] = f_kalman2d(close, rolling_variance, system_variance_scaled, clamped_rVol, use_vol_weighting)
    k_level := l
    k_velocity := v
    k_ptrace := p

// Use native Kalman level and velocity directly
float k_smooth = k_level
float k_slope = k_velocity

float k_error = close - k_smooth // Error calculated from smooth baseline

// Compute dynamic Standard Deviation using Kalman error (EMA decay prevents window drop-off)
float k_variance_ema = ta.ema(k_error * k_error, kf_noise_len)
float k_std = math.sqrt(k_variance_ema) // Residual Variance (For Plunger Exhaustion)
float atr_std = ta.ema(ta.tr, kf_noise_len) // True Range Variance (For Trailing Stop)

// --- Kalman Adaptive Trailing Stop ---
float k_upper = k_smooth + (stop_mult * atr_std)
float k_lower = k_smooth - (stop_mult * atr_std)

var float trailing_stop = na
var int trend_dir = 1
var int active_trade_dir = 0

var float rolling_high = na
var float rolling_low = na

var bool isAdjusting = false
var int sigCounter = 0
var float startLevel = na

if not na(k_upper) and not na(k_lower)
    if na(trailing_stop)
        trailing_stop := close > k_smooth ? k_lower : k_upper
        trend_dir := close > k_smooth ? 1 : -1
        rolling_high := high
        rolling_low := low
    else
        // Uptrend
        if trend_dir == 1
            rolling_high := math.max(nz(rolling_high, high), high)
            bool slope_cond = not use_slope_confirm or k_slope < 0
            
            // Hysteresis breach check: close below stop AND close lower than previous close AND slope confirmed
            float bearish_flip_threshold = trailing_stop - (mu_offset * atr_std)
            if close < bearish_flip_threshold and close < nz(close[1], close) and slope_cond
                trend_dir := -1
                rolling_low := low
                float initial_ceiling = rolling_low + (stop_mult * atr_std)
                trailing_stop := math.min(k_upper, initial_ceiling)
                isAdjusting := false
            else
                // 1. Base Ratchet & Push (Calculate target stop before relaxation)
                float target_stop = math.max(nz(trailing_stop[1]), k_lower)
                
                if k_slope > 0 and close > nz(close[1], close)
                    target_stop := target_stop + (push_factor * atr_std)
                    target_stop := math.min(target_stop, k_upper)
                
                // 1.5 3D Oscillator Tightening (KF4)
                if use_3d_osc and not na(k_osc) and k_osc > 0.9
                    target_stop := math.max(target_stop, close - (0.5 * atr_std))
                
                // 2. Responsive Ratchet
                float structural_floor = na(recent_itl) ? na : (recent_itl - (1.0 * atr_std))
                float live_floor = rolling_high - (stop_mult * atr_std)
                float effective_floor = na(structural_floor) ? live_floor : math.max(structural_floor, live_floor)
                
                if effective_floor > target_stop
                    target_stop := math.min(effective_floor, close - (0.5 * atr_std))
                    
                // 3. Apply Volatility Relaxation ONLY if it expands the stop away from price
                if atr_std > nz(atr_std[1])
                    float relaxation = (atr_std - nz(atr_std[1])) * stop_mult * relax_factor
                    float relaxed_stop = nz(trailing_stop[1]) - relaxation
                    target_stop := math.min(target_stop, math.max(relaxed_stop, k_lower))
                    
                // --- Structural Sigmoid Fusion Layer ---
                if use_sigmoid_smoothing
                    float dist = math.abs(target_stop - nz(trailing_stop[1]))
                    if dist > (0.2 * atr_std) and not isAdjusting
                        isAdjusting := true
                        sigCounter := 0
                        startLevel := nz(trailing_stop[1])
                        
                    if isAdjusting
                        sigCounter += 1
                        float t = sigCounter / math.max(1.0, float(sig_len))
                        float candidate = startLevel + (target_stop - startLevel) * f_sigmoid(t)
                        trailing_stop := math.max(k_lower, candidate)
                        
                        if sigCounter >= sig_len
                            isAdjusting := false
                            trailing_stop := target_stop
                    else
                        trailing_stop := target_stop
                else
                    trailing_stop := target_stop

        // Downtrend
        else if trend_dir == -1
            rolling_low := math.min(nz(rolling_low, low), low)
            bool slope_cond = not use_slope_confirm or k_slope > 0
            
            // Hysteresis breach check: close above stop AND close higher than previous close AND slope confirmed
            float bullish_flip_threshold = trailing_stop + (mu_offset * atr_std)
            if close > bullish_flip_threshold and close > nz(close[1], close) and slope_cond
                trend_dir := 1
                rolling_high := high
                float initial_floor = rolling_high - (stop_mult * atr_std)
                trailing_stop := math.max(k_lower, initial_floor)
                isAdjusting := false
            else
                // 1. Base Ratchet & Push (Calculate target stop before relaxation)
                float target_stop = math.min(nz(trailing_stop[1]), k_upper)
                
                if k_slope < 0 and close < nz(close[1], close)
                    target_stop := target_stop - (push_factor * atr_std)
                    target_stop := math.max(target_stop, k_lower)
                    
                // 1.5 3D Oscillator Tightening (KF4)
                if use_3d_osc and not na(k_osc) and k_osc < 0.1
                    target_stop := math.min(target_stop, close + (0.5 * atr_std))
                    
                // 2. Responsive Ratchet
                float structural_ceiling = na(recent_ith) ? na : (recent_ith + (1.0 * atr_std))
                float live_ceiling = rolling_low + (stop_mult * atr_std)
                float effective_ceiling = na(structural_ceiling) ? live_ceiling : math.min(structural_ceiling, live_ceiling)
                
                if effective_ceiling < target_stop
                    target_stop := math.max(effective_ceiling, close + (0.5 * atr_std))
                    
                // 3. Apply Volatility Relaxation ONLY if it expands the stop away from price
                if atr_std > nz(atr_std[1])
                    float relaxation = (atr_std - nz(atr_std[1])) * stop_mult * relax_factor
                    float relaxed_stop = nz(trailing_stop[1]) + relaxation
                    target_stop := math.max(target_stop, math.min(relaxed_stop, k_upper))
                    
                // --- Structural Sigmoid Fusion Layer ---
                if use_sigmoid_smoothing
                    float dist = math.abs(target_stop - nz(trailing_stop[1]))
                    if dist > (0.2 * atr_std) and not isAdjusting
                        isAdjusting := true
                        sigCounter := 0
                        startLevel := nz(trailing_stop[1])
                        
                    if isAdjusting
                        sigCounter += 1
                        float t = sigCounter / math.max(1.0, float(sig_len))
                        float candidate = startLevel + (target_stop - startLevel) * f_sigmoid(t)
                        trailing_stop := math.min(k_upper, candidate)
                        
                        if sigCounter >= sig_len
                            isAdjusting := false
                            trailing_stop := target_stop
                    else
                        trailing_stop := target_stop
                else
                    trailing_stop := target_stop


var float active_entry_price = na

// --- Regime Filter State Machine ---

bool force_exit = false
if active_trade_dir == 1 and use_tp and high >= active_entry_price + (tp_mult * atr_std)
    force_exit := true
else if active_trade_dir == -1 and use_tp and low <= active_entry_price - (tp_mult * atr_std)
    force_exit := true

if not inSession and active_trade_dir != 0
    force_exit := true

if ta.change(trend_dir) != 0 or force_exit
    if active_trade_dir != 0 and (trend_dir != active_trade_dir or force_exit)
        active_trade_dir := 0

if active_trade_dir == 0
    if trend_dir == 1
        active_trade_dir := 1
    else if trend_dir == -1
        active_trade_dir := -1

// Plot Trailing Stop
color stop_color = active_trade_dir == 1 ? #00998786 : (active_trade_dir == -1 ? #cc33117d : color.new(color.gray, 60))
p_stop = plot(trailing_stop, title="Kalman Trailing Stop", color=stop_color, linewidth=2, style=plot.style_linebr)

step  = (close - trailing_stop) / 6
grad1 = trailing_stop + step * 1
grad2 = trailing_stop + step * 2

p_grad1 = plot(grad1, display = display.none, editable = false)
p_grad2 = plot(grad2, display = display.none, editable = false)

fill(p_stop, p_grad1, color = color.new(stop_color, 68))
fill(p_grad1, p_grad2, color = color.new(stop_color, 88))

// --- S-Plunger Calculations (Cycle-Proportional + Kalman Sweep) ---

// 1. Check for New N-bar High/Low (Structural Trap)
isNewNBarHigh = high == ta.highest(high, plungerLength)
isNewNBarLow  = low  == ta.lowest(low, plungerLength)

// 2. Calculate Bar Range
float barRange = high - low
bool isValidBarRange = barRange > 0

// 3. Check Close Position within Bar Range (Wick Rejection)
bool isCloseInTopPercent = (high - close) / barRange <= closePercentage
bool isCloseInBottomPercent = (close - low) / barRange <= closePercentage

// 4. Volatility Filter (Avoid flat markets)
float averageRange = ta.atr(atrLength)
bool isBarRangeSignificant = na(averageRange) ? false : barRange >= (averageRange / 2)

// 5. Plunger Fat-Tail Kurtosis Tracker (Student-t MLE Approx)
float return_val = nz(ta.change(close), 0.0)
float mean_ret = ta.ema(return_val, kf_noise_len)
float diff_ret = return_val - mean_ret
float var2 = ta.ema(diff_ret * diff_ret, kf_noise_len)
float var4 = ta.ema(math.pow(diff_ret, 4), kf_noise_len)
float kurtosis = (var2 > 0) ? (var4 / (var2 * var2)) : 3.0
// Clamp kurtosis to prevent extreme tail distortion (assume 3.0 is normal Gaussian)
float clamped_kurtosis = math.max(3.0, math.min(kurtosis, 20.0))

// Dynamically warp the sweep multiplier for Fat-Tail Exhaustion
float dynamic_sweep_mult = base_sweep_mult * math.sqrt(clamped_kurtosis / 3.0)

bool isBullishSweep = low < (k_smooth - dynamic_sweep_mult * k_std)
bool isBearishSweep = high > (k_smooth + dynamic_sweep_mult * k_std)

// --- Signal Conditions (Upgraded) ---
bullishPlungerCondition = isNewNBarLow and close > open and isCloseInTopPercent and isValidBarRange and isBarRangeSignificant and isBullishSweep
bearishPlungerCondition = isNewNBarHigh and close < open and isCloseInBottomPercent and isValidBarRange and isBarRangeSignificant and isBearishSweep

// --- Plotting Signals ---
plotshape(series = showBullish and bullishPlungerCondition ? low : na, title = 'Bullish Signal', location = location.belowbar, color = #00998784, style = shape.triangleup, size = size.tiny, display = display.all - display.status_line)
barcolor(bullishPlungerCondition ? #009988 : na, title = 'Bullish Color')

plotshape(series = showBearish and bearishPlungerCondition ? high : na, title = 'Bearish Signal', location = location.abovebar, color = #cc33117e, style = shape.triangledown, size = size.tiny, display = display.all - display.status_line)
barcolor(bearishPlungerCondition ? #CC3311 : na, title = 'Bearish Color')

// --- Main Trend Entry Signals ---
bool entered_long = active_trade_dir != nz(active_trade_dir[1]) and active_trade_dir == 1
bool entered_short = active_trade_dir != nz(active_trade_dir[1]) and active_trade_dir == -1
bool exited_to_cash = active_trade_dir != nz(active_trade_dir[1]) and active_trade_dir == 0

float atr_14 = ta.atr(14)
plotshape(series = entered_long ? low - atr_14 : na, title = 'Main Entry Long', location = location.absolute, color = #009988, style = shape.diamond, size = size.tiny, display = display.all - display.status_line)
plotshape(series = entered_short ? high + atr_14 : na, title = 'Main Entry Short', location = location.absolute, color = #CC3311, style = shape.diamond, size = size.tiny, display = display.all - display.status_line)

// --- Risk % Label ---
float sl_distance = math.abs(close - trailing_stop)
float sl_percent = sl_distance / close
float risk_amount = account_size * risk_percent
float dollar_risk_per_unit = sl_distance * syminfo.pointvalue
float raw_position_size = dollar_risk_per_unit > 0 ? (risk_amount / dollar_risk_per_unit) : 0.0

// Apply Account Buying Power Cap
float max_affordable_size = (account_size * max_leverage) / (close * syminfo.pointvalue)
float position_size = math.min(raw_position_size, max_affordable_size)
float pyramid_size = position_size * pyramid_factor

plot(position_size, title="Position Size", display=display.none)
plot(pyramid_size, title="Pyramid Size", display=display.none)



// --- Abnormal Reaction Warning (Livermore Ejector Concept) ---
float avg_tr = ta.ema(ta.tr, 20)
bool abnormal_bear_warning = trend_dir == 1 and close < open and ta.tr > (avg_tr * 2.5)
bool abnormal_bull_warning = trend_dir == -1 and close > open and ta.tr > (avg_tr * 2.5)

plotshape(series=abnormal_bear_warning ? high : na, title="Abnormal Bear Warning", location=location.abovebar, color=color.new(color.yellow, 30), style=shape.xcross, size=size.tiny, display = display.all - display.status_line)
plotshape(series=abnormal_bull_warning ? low : na, title="Abnormal Bull Warning", location=location.belowbar, color=color.new(color.yellow, 30), style=shape.xcross, size=size.tiny, display = display.all - display.status_line)

// --- Algorithmic Pyramiding (Scale-In) ---
var int add_cooldown = 0
var array<int> live_trade_times = array.new_int()

// --- Performance Tracking (Profit Factor) ---
var float gross_profit_all = 0.0
var float gross_loss_all = 0.0
var int total_trades_all = 0
var array<float> recent_profits = array.new_float()
var array<float> recent_losses = array.new_float()

if active_trade_dir != nz(active_trade_dir[1]) and nz(active_trade_dir[1]) != 0
    total_trades_all += 1
    float exit_price = close
    float trade_return = (exit_price - active_entry_price) / active_entry_price
    if nz(active_trade_dir[1]) == -1
        trade_return := -trade_return
        
    if trade_return > 0
        gross_profit_all += trade_return
        array.push(recent_profits, trade_return)
        array.push(recent_losses, 0.0)
    else
        gross_loss_all += math.abs(trade_return)
        array.push(recent_profits, 0.0)
        array.push(recent_losses, math.abs(trade_return))
        
    if array.size(recent_profits) > 50
        array.shift(recent_profits)
        array.shift(recent_losses)

// --- Update Entry Price for New Trades ---
if active_trade_dir != nz(active_trade_dir[1]) and active_trade_dir != 0
    active_entry_price := close
    array.unshift(live_trade_times, time)
    if array.size(live_trade_times) > 500
        array.pop(live_trade_times)

add_cooldown := math.max(0, nz(add_cooldown[1]) - 1)

bool can_pyramid_long = (active_trade_dir == 1) and (trailing_stop >= active_entry_price)
bool can_pyramid_short = (active_trade_dir == -1) and (trailing_stop <= active_entry_price)

var float pullback_sum_vol_long = 0.0
var int pullback_count_long = 0
var float pullback_sum_vol_short = 0.0
var int pullback_count_short = 0

if ms_newSTH
    pullback_sum_vol_long := 0.0
    pullback_count_long := 0
if ms_newSTL
    pullback_sum_vol_short := 0.0
    pullback_count_short := 0

pullback_sum_vol_long += volume
pullback_count_long += 1
pullback_sum_vol_short += volume
pullback_count_short += 1

float pullback_vol_long = pullback_count_long > 0 ? (pullback_sum_vol_long / pullback_count_long) : nz(volume)
float pullback_vol_short = pullback_count_short > 0 ? (pullback_sum_vol_short / pullback_count_short) : nz(volume)
float macro_vol_avg = ta.median(volume, 20)

// Exclude the current breakout candle's volume from the dry-up check
bool volume_dried_up_long = nz(pullback_vol_long[1], volume) < (macro_vol_avg * 0.9)
bool volume_dried_up_short = nz(pullback_vol_short[1], volume) < (macro_vol_avg * 0.9)

// Confirm the breakout candle has expanding volume
bool breakout_vol_confirm_long = volume > nz(pullback_vol_long[1], volume)
bool breakout_vol_confirm_short = volume > nz(pullback_vol_short[1], volume)

bool pyramid_long_trigger = ta.crossover(close, recent_sth) and volume_dried_up_long and breakout_vol_confirm_long and can_pyramid_long and add_cooldown == 0
bool pyramid_short_trigger = ta.crossunder(close, recent_stl) and volume_dried_up_short and breakout_vol_confirm_short and can_pyramid_short and add_cooldown == 0

if pyramid_long_trigger or pyramid_short_trigger
    add_cooldown := 5

plotshape(series=pyramid_long_trigger ? low : na, title="Pyramid Long (ADD)", location=location.belowbar, color=color.new(#009988, 30), style=shape.cross, size=size.tiny, display = display.all - display.status_line)
plotshape(series=pyramid_short_trigger ? high : na, title="Pyramid Short (ADD)", location=location.abovebar, color=color.new(#CC3311, 30), style=shape.cross, size=size.tiny, display = display.all - display.status_line)

// --- Alerts ---
alertcondition(bullishPlungerCondition, title = 'Bullish Plunger', message = 'Bullish Plunger Detected (Statistically Validated)')
alertcondition(bearishPlungerCondition, title = 'Bearish Plunger', message = 'Bearish Plunger Detected (Statistically Validated)')

// --- Trade Alerts (Regime Filtered) ---
alertcondition(entered_long, title = 'Trade Entry: LONG', message = 'Trend flipped Bullish. ENTER LONG.')
alertcondition(entered_short, title = 'Trade Entry: SHORT', message = 'Trend flipped Bearish. ENTER SHORT.')
alertcondition(exited_to_cash, title = 'Trade Exit: CASH', message = 'Trailing Stop Hit. EXIT POSITION.')

alertcondition(abnormal_bear_warning or abnormal_bull_warning, title='Abnormal Reaction Warning', message='Abnormal Market Reaction Warning (Volatility Spike Against Trend)')
alertcondition(pyramid_long_trigger, title='Pyramid Long (ADD)', message='Algorithmic Scale-In Long Detected (Volume Dry-Up + Breakout)')
alertcondition(pyramid_short_trigger, title='Pyramid Short (ADD)', message='Algorithmic Scale-In Short Detected (Volume Dry-Up + Breakout)')

// --- Williams Market Structure Visualization ---
var polyline iLine = na
var array<label> iLabels = array.new<label>()
// OPT: Track last known swing array sizes to skip redundant redraws
var int last_iths_size = 0
var int last_itls_size = 0
int curr_iths_size = array.size(ms_iths)
int curr_itls_size = array.size(ms_itls)
bool swings_changed = (curr_iths_size != last_iths_size) or (curr_itls_size != last_itls_size)

if show_williams_ms and (swings_changed or barstate.islast)
    last_iths_size := curr_iths_size
    last_itls_size := curr_itls_size
    if not na(iLine)
        polyline.delete(iLine)
    if array.size(iLabels) > 0
        for i = 0 to array.size(iLabels) - 1
            label.delete(array.get(iLabels, i))
    array.clear(iLabels)

    if array.size(ms_itls) > 0 or array.size(ms_iths) > 0
        array<Swing> all_iSwings = array.new<Swing>()
        
        if array.size(ms_itls) > 0
            for i = 0 to array.size(ms_itls) - 1
                array.push(all_iSwings, array.get(ms_itls, i))
                
        if array.size(ms_iths) > 0
            for i = 0 to array.size(ms_iths) - 1
                array.push(all_iSwings, array.get(ms_iths, i))
            
        array<int> sort_times = array.new<int>()
        
        if array.size(all_iSwings) > 0
            for i = 0 to array.size(all_iSwings) - 1
                array.push(sort_times, array.get(all_iSwings, i).idx)
                
            array<int> sorted_indices = array.sort_indices(sort_times)
            
            array<Swing> clean_iSwings = array.new<Swing>()
            
            bool last_was_high = false
            
            if array.size(sorted_indices) > 0
                for i = 0 to sorted_indices.size() - 1
                    Swing current = array.get(all_iSwings, array.get(sorted_indices, i))
                    
                    if array.size(clean_iSwings) == 0
                        array.push(clean_iSwings, current)
                        last_was_high := current.isHigh
                    else
                        if current.isHigh == last_was_high
                            Swing last_swing = array.get(clean_iSwings, array.size(clean_iSwings) - 1)
                            if current.isHigh and current.price > last_swing.price
                                array.set(clean_iSwings, array.size(clean_iSwings) - 1, current)
                            else if not current.isHigh and current.price < last_swing.price
                                array.set(clean_iSwings, array.size(clean_iSwings) - 1, current)
                        else
                            Swing last_swing = array.get(clean_iSwings, array.size(clean_iSwings) - 1)
                            if (current.isHigh and current.price > last_swing.price) or (not current.isHigh and current.price < last_swing.price)
                                array.push(clean_iSwings, current)
                                last_was_high := current.isHigh

            array<chart.point> iPoints = array.new<chart.point>()
            
            if array.size(clean_iSwings) > 0
                for i = 0 to array.size(clean_iSwings) - 1
                    Swing s = array.get(clean_iSwings, i)
                    array.push(iPoints, chart.point.from_index(s.idx, s.price))
                    
                    string txt = s.isHigh ? "ITH" : "ITL"
                    color col = s.isHigh ? color.new(color.red, 30) : color.new(color.green, 30)
                    lbl = label.new(s.idx, s.price, text=txt, style=s.isHigh ? label.style_label_down : label.style_label_up, color=color.new(color.white, 100), textcolor=col, size=size.tiny, text_font_family = font.family_monospace)
                    array.push(iLabels, lbl)
                    
                if array.size(iPoints) > 1
                    iLine := polyline.new(iPoints, curved=false, line_color=color.new(color.blue, 30), line_width=1, line_style=line.style_dotted)


// --- Performance Table ---
var table perf_table = na
if barstate.islast
    float recent_profit_sum = array.sum(recent_profits)
    float recent_loss_sum = array.sum(recent_losses)
    float global_pf = gross_loss_all > 0 ? (gross_profit_all / gross_loss_all) : (gross_profit_all > 0 ? 99.99 : 0.0)
    float recent_pf = recent_loss_sum > 0 ? (recent_profit_sum / recent_loss_sum) : (recent_profit_sum > 0 ? 99.99 : 0.0)
    
    if na(perf_table)
        perf_table := table.new(position.middle_right, 2, 3, frame_color=color.white, frame_width=1, border_color=color.white, border_width=1)
        
    table.cell(perf_table, 0, 0, "Global PF (" + str.tostring(total_trades_all) + ")", text_color=color.white, bgcolor=color.black, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(perf_table, 1, 0, str.tostring(global_pf, "#.##"), text_color=color.white, bgcolor=global_pf > 1.2 ? color.new(#009988, 50) : color.new(#CC3311, 50), text_size=size.tiny, text_font_family=font.family_monospace)
    
    table.cell(perf_table, 0, 1, "Recent PF (" + str.tostring(array.size(recent_profits)) + ")", text_color=color.white, bgcolor=color.black, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(perf_table, 1, 1, str.tostring(recent_pf, "#.##"), text_color=color.white, bgcolor=recent_pf > 1.2 ? color.new(#009988, 50) : color.new(#CC3311, 50), text_size=size.tiny, text_font_family=font.family_monospace)
    
    table.cell(perf_table, 0, 2, "Trailing Stop", text_color=color.white, bgcolor=color.black, text_size=size.tiny, text_font_family=font.family_monospace)
    table.cell(perf_table, 1, 2, str.tostring(trailing_stop, format.mintick) + " (" + str.tostring(sl_percent * 100, "#.##") + "%)", text_color=color.white, bgcolor=trend_dir == 1 ? color.new(#009988, 70) : color.new(#CC3311, 70), text_size=size.tiny, text_font_family=font.family_monospace)
````
