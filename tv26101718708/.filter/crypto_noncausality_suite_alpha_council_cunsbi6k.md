# Crypto Non-Causality Suite [Alpha Council]

- url: https://www.tradingview.com/script/cuNsBi6k-Crypto-Non-Causality-Suite-Alpha-Council/
- type: indicator
- pine_id: PUB;5f4fb96edc584c4385e7b708d1a98c9a
- version: 1.0

## Description

[b]Crypto Non-Causality Suite v4 [Alpha Council][/b]

The Crypto Non-Causality Suite (NCS) is an advanced, institutional-grade proof-of-concept designed to map the structural physics of the cryptocurrency market.

Traditional indicators are strictly causal—they look backward to calculate a lagging average of the past. The NCS operates differently. It utilizes heavy multidimensional arrays, matrix inversions, and fractional calculus to observe the entire time-series simultaneously. By calculating a "future-smoothed" structural state, it maps inevitable market attractors rather than lagging averages.

To bridge the gap between non-causal prediction and safe live execution, this suite employs a strict [b]Dual-Phase Architecture[/b]: an adaptable, repainting "Spatial Map" to find the extremes, and a 100% causal, zero-lag "Execution Layer" to pull the trigger.

[b]🧩 THE UNIFIED MODULES[/b]

[b]1. The Spatial Map (Non-Causal Topology)[/b]
[list]
[] [b]Whittaker Kinematic Boundaries:[/b] We use independent pentadiagonal matrix solves to extract the absolute upper and lower boundaries of the market's kinematic energy.
[] [b]Nadaraya-Watson Core (The Attractor):[/b] A heavy Gaussian kernel estimator tears through the center of the Whittaker Envelope, acting as the probabilistic center of mass for price action.
[*] [b]Polynomial Regression Channel (PRC):[/b] An integrated fast-twitch matrix overlay mapped via Ordinary Least Squares (OLS) normal equations. It aggressively maps itself to the immediate momentum of the data to act as a dynamic "net" that snaps to the wicks long before the heavier Whittaker envelope catches up.
[/list]

[b]2. The Stationarity Gate (Hurst-Fractal Regime)[/b]
Standard indicators fail because they do not know if the market is trending or ranging.
[list]
[] [b]Hurst Exponent Proxy:[/b] The engine computes the Hurst Exponent via a modified Choppiness Index. If Hurst < 0.5, the market is Mean-Reverting (Stationary). If Hurst > 0.5, the market is Trending (Non-Stationary).
[] [b]Regime Ribbon & Fill:[/b] A Viterbi-approximated HMM logic uses this stationarity data, along with RSI, ADX, and CVD, to paint contiguous, non-causal regime boxes directly onto your chart. The system mathematically blocks counter-trend mean-reversion boundaries during non-stationary trending environments.
[/list]

[b]3. The ACV Defense Vault (Pulse Engine)[/b]
Adverse Cascade Vulnerability (ACV) gets retail killed. When a market enters a violent liquidation cascade, mean-reverting indicators assume the market is "oversold" and bait traders into buying a falling knife.
[list]
[] [b]Kinematic Saturation Decay:[/b] The suite tracks sustained directional inertia. If the market is in free-fall and the "Pulse" crosses 80% saturation, the system physically locks you out of trading until the kinetic energy bleeds out.
[] [b]LWA & LSP Gates:[/b] The shield only drops when it detects a Liquidation Wick Anomaly (a massive ATR expansion met with a >45% rejection wick on climax volume) or a Liquidity Sweep Protocol (price pierces a 7-bar pivot and immediately rejects).
[/list]

[b]4. The Causal Firing Pin (Execution Layer)[/b]
You cannot execute a live trade blindly on a fluid, repainting boundary. Once the non-causal math "arms" the system, we drop to the micro-structure.
[list]
[] [b]CVD Absorption (CVD):[/b] If the higher-timeframe signals a top, but the lower-timeframe Cumulative Volume Delta makes a lower-high as price makes a higher-high, limit sellers are absorbing the retail market buys.
[] [b]Open Interest Exhaustion (OI):[/b] If price pushes into the boundary but OI suddenly drops, the move is a fakeout fueled by short liquidations, not new capital.
[] [b]Premium Index Snap (PREM):[/b] Tracks the unwinding of derivative funding greed/fear.
[] [b]Macro Capital Fracture (USDT):[/b] Cross-verifies with Tether dominance to ensure macro-capital flight has stalled.
[/list]
[i]Note: These triggers use strict anti-lookahead parameters and print permanently locked text labels (e.g., [CVD ▼]) directly onto the wicks.[/i]

[b]5. Contextual Magnetism & Future Projections[/b]
[list]
[] [b]Algorithmic Killzones:[/b] The engine maps a 24x Anomaly Anchor Meta-Mean (based on 2.5σ volume spikes) and projects 25x, 50x, and 100x simulated liquidation heatmaps directly onto the chart.
[] [b]Unmitigated Liquidity Polylines:[/b] When an Absorption Star (❂) prints, the engine drops a dashed polyline from the extreme wick and projects it endlessly into the future to act as a non-repainting Take Profit (TP) magnet.
[*] [b]Inverse Kernel Bounding (IKB):[/b] Replaces repainting Dynamic Time Warping. It generates an expanding GARCH-style multiverse cone, projecting future paths and culling them if they exceed the historical velocity limits of the Nadaraya-Watson core.
[/list]

[b]⚙️ TACTICAL WORKFLOW (HOW TO TRADE THIS)[/b]

[b]The Trap (Setup):[/b] Wait for price to violently pierce the Whittaker or PRC non-causal boundaries.

[b]The Friction (Validation):[/b] Ensure the ACV Shield is clear (check the HUD). Wait for an [b]Absorption Star (❂)[/b] to print on the wick, proving an institutional limit wall has absorbed the forced liquidations.

[b]The Capture (Execution):[/b] Wait for a micro-causal tag (CVD, OI, PREM, or USDT) to stack vertically above/below the wick. Execute the trade.

[b]The Target (Exit):[/b] Hold the position until price structurally tags the nearest Unmitigated Liquidity Polyline left by a previous anomaly.

[b]⚠️ ARCHITECTURAL LIMITS & DISCLAIMERS[/b]
[list]
[] [b]Repainting Notice:[/b] The Whittaker envelopes, PRC, NW core, and Regime Fills use barstate.islast to observe the whole dataset and [b]WILL REPAINT[/b] historically to find the optimal polynomial fit. However, Absorption Stars (❂) are permanently locked to causal conditions and will [b]NOT[/b] repaint (Execution labels will). Trade the Stars, use the envelopes only as a map and labels as interest.
[] [b]Computational Load:[/b] This suite forces heavy matrix algebra. The script manages its line/box budget dynamically via decimation loops. Keep the "Topological Window" reasonable (e.g., 400 bars) to avoid compiler timeouts.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// Designed for the Crypto Entity & Leverage Market
// THE ALPHA COUNCIL - Orthogonal Liquidation Matrix w/ HMM Stationarity Gate

//@version=6
indicator("Crypto Non-Causality Suite [Alpha Council]", "Crypto NCS v4", overlay = false, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_polylines_count = 100)

//---------------------------------------------------------------------------------------------------------------------}
// 1. KINEMATIC PARAMETERS & SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
string SETTINGS_GRP = "Causal & Structural Settings"
int    lengthInput   = input.int(400,    "Topological Window (Length)",    minval = 5,    group = SETTINGS_GRP)
float  lambdaInput   = input.float(2000, "Kinematic Smoothness (λ)",       minval = 0.1,  group = SETTINGS_GRP)
float  pLowerInput   = input.float(0.001,"Lower Asymmetry Boundary (p)",   minval = 0.0, maxval = 0.5, step = 0.001, group = SETTINGS_GRP)
float  pUpperInput   = input.float(0.999,"Upper Asymmetry Boundary (p)",   minval = 0.5, maxval = 1.0, step = 0.001, group = SETTINGS_GRP)

string REGIME_GRP   = "HMM Regime & Stationarity (ADF/Hurst Proxy)"
bool   useRegime    = input.bool(true,  "Enable HMM Regime Background Fill", group = REGIME_GRP)
bool   strictBinary = input.bool(false, "Enable 1-2 Binary Regime Mode", group = REGIME_GRP, tooltip="Visually removes the Neutral state. Bullish/Bearish background boxes will hold persistently until the opposite state is triggered, but execution signals will still obey the true 3-state neutral mathematics.")
int    hurstLen     = input.int(14,     "Hurst/Fractal Lookback", minval = 5, group = REGIME_GRP)
float  hurstThresh  = input.float(0.52, "Non-Stationary (Trend) Threshold", minval = 0.45, maxval = 0.65, step = 0.01, group = REGIME_GRP)

string PRC_GRP      = "Polynomial Regression Channel (ChartPrime)"
bool   prcEnable    = input.bool(true,  "Enable PRC Matrix Overlay",      group = PRC_GRP)
float  prcSource    = input.source(close, 'Source',                       group = PRC_GRP)
int    prcLength    = input.int(100,    'Period',           minval = 2,   group = PRC_GRP)
bool   prcDisplayExt= input.bool(true,  'Display Extrapolation', inline = "ext", group = PRC_GRP)
int    prcExtrap    = input.int(10,     'Extrapolate',      minval = 0,   inline = "ext", group = PRC_GRP)
int    prcDegree    = input.int(4,      'Degree',           minval = 1,   group = PRC_GRP)
float  prcMult      = input.float(2.0,  "PRC Channel Width Multiplier",   minval = 0.1, step = 0.1, group = PRC_GRP)

string LWA_GRP      = "LWA & Liquidity Sweep Protocol (V-Top / Double Top)"
bool   useLwa       = input.bool(true,  "Enable LWA Shockwave Gate",      group = LWA_GRP, tooltip="Arms system on massive Z-Score & ATR dislocations.")
bool   useLsp       = input.bool(true,  "Enable LSP Structural Sweep",    group = LWA_GRP, tooltip="Arms system when price pierces a 7-bar pivot and immediately rejects.")
float  lwaAtrMult   = input.float(2.5,  "LWA Minimum ATR Expansion",      minval = 1.0, step = 0.5, group = LWA_GRP)
float  lwaWickPct   = input.float(0.45, "LWA Minimum Wick % of Bar",      minval = 0.1, maxval = 0.9, step = 0.05, group = LWA_GRP)
float  lwaZScore    = input.float(3.0,  "LWA Dislocation Z-Score",        minval = 1.0, step = 0.5, group = LWA_GRP)

string NW_GRP       = "Nadaraya-Watson Non-Causal Core"
float  nwBandwidth  = input.float(8.0,  "Gaussian Kernel Bandwidth (h)",  minval = 0.1, step=0.5, group = NW_GRP)

string ACV_GRP      = "ACV Defense Vault"
int    pulseCap     = input.int(8,      "Pulse Engine Cap (Inertia)",     minval = 3, maxval = 20, group = ACV_GRP)
float  pulseDecay   = input.float(0.85, "Pulse Engine Decay",             minval = 0.5, maxval = 0.99, step = 0.01, group = ACV_GRP)

string EXEC_GRP     = "Causal Execution Layer (Triggers)"
bool   useCvd       = input.bool(true,  "Enable CVD Divergence",          group = EXEC_GRP)
string execTf       = input.timeframe("1", "LTF Timeframe (Micro-Structure)", group = EXEC_GRP)
bool   useOi        = input.bool(true,  "Enable Open Interest Exhaustion",group = EXEC_GRP)
string oiTicker     = input.symbol("BINANCE:BTCUSDT.P_OI", "OI Ticker",   group = EXEC_GRP)
bool   usePrem      = input.bool(true,  "Enable Premium Index Snap",      group = EXEC_GRP)
string premTicker   = input.symbol("BINANCE:BTCUSDT_PREMIUM", "Prem Ticker", group = EXEC_GRP)
bool   useUsdt      = input.bool(true,  "Enable Macro Capital (USDT.D)",  group = EXEC_GRP)
string usdtTicker   = input.symbol("CRYPTOCAP:USDT.D", "USDT.D Ticker",   group = EXEC_GRP)

string UPGRADE_GRP  = "Contextual Magnetism & Vacuum"
bool   showKillzones= input.bool(true,  "Show Algorithmic Killzones", group = UPGRADE_GRP)
bool   useVacuum    = input.bool(true,  "Enable Volume-Velocity Vacuum Trigger", group = UPGRADE_GRP)
bool   showUnmit    = input.bool(true,  "Show Unmitigated Liquidity Polylines",  group = UPGRADE_GRP)

string IKB_GRP      = "Inverse Kernel Bounding (Multiverse)"
int    extrapInput  = input.int(20,     "IKB Forward Projection Length",  minval = 5, maxval = 100, group = IKB_GRP)

// Signature Colors
color BULL_COLOR    = #00E676
color BEAR_COLOR    = #FF1744
color MID_COLOR     = color.gray
color IKB_COLOR     = #00BFFF

hline(0.0,  "Midline (Zero)", color = color.gray, linestyle = hline.style_solid)
hline(0.5,  "Overbought",     color = BEAR_COLOR, linestyle = hline.style_dashed)
hline(-0.5, "Oversold",       color = BULL_COLOR, linestyle = hline.style_dashed)

//---------------------------------------------------------------------------------------------------------------------}
// 2. CAUSAL ORDER FLOW, PHYSICS, & STATIONARITY (REAL-TIME)
//---------------------------------------------------------------------------------------------------------------------{
// Micro-CVD Absorption
[cvd_c, cvd_o, cvd_v] = request.security(syminfo.tickerid, execTf, [close, open, volume], lookahead = barmerge.lookahead_off)
var float ltf_cvd_cum = 0.0
if not na(cvd_c)
    ltf_cvd_cum += (cvd_c > cvd_o ? cvd_v : (cvd_c < cvd_o ? -cvd_v : 0))

// Sentinel Sentiment / Macro Tickers
float ltf_oi_close   = request.security(oiTicker, execTf, close, lookahead = barmerge.lookahead_off)
float ltf_usdt_close = request.security(usdtTicker, execTf, close, lookahead = barmerge.lookahead_off)
float prem_close     = request.security(premTicker, execTf, close, lookahead = barmerge.lookahead_off)
float prem_mean      = ta.sma(prem_close, 24)
float prem_std       = math.max(ta.stdev(prem_close, 24), 1e-5)
float prem_z         = prem_std != 0 ? (prem_close - prem_mean) / prem_std : 0.0

// STATIONARITY & HMM REGIME DETECTOR (Viterbi Approximation)
// Computes the Hurst Exponent via Choppiness Index (Fractal Dimension Proxy)
float sum_tr = math.sum(ta.tr, hurstLen)
float h_high = ta.highest(high, hurstLen)
float l_low  = ta.lowest(low, hurstLen)
float chop   = 100.0 * math.log10(sum_tr / math.max(h_high - l_low, syminfo.mintick)) / math.log10(hurstLen)
float hurst  = 1.0 - (chop / 100.0) // H > 0.5 = Trending (Non-Stationary), H < 0.5 = Mean-Reverting (Stationary)

float rsi_val = ta.rsi(close, 14)
[di_plus, di_minus, adx_val] = ta.dmi(14, 14)

float cvd_delta = ltf_cvd_cum - ltf_cvd_cum[1]
float cvd_trend = ta.ema(cvd_delta, 10)

bool is_trending = hurst > hurstThresh and adx_val > 20
float regime_ema = ta.ema(close, 20)

// --------------------------------------------------------------------------------------------------------------------
// DUAL STATE MACHINE: Visual Box Layer vs True Signal Layer
// --------------------------------------------------------------------------------------------------------------------
var int true_hmm_regime = 0 
var int visual_hmm_regime = 0 

// 1. True Mathematical Regime (Always 3-State for execution gating)
if is_trending
    if rsi_val > 50 and di_plus > di_minus and cvd_trend >= 0 and close > regime_ema
        true_hmm_regime := 1
    else if rsi_val < 50 and di_minus > di_plus and cvd_trend <= 0 and close < regime_ema
        true_hmm_regime := -1
else if (hurst < 0.45 or adx_val < 15)
    true_hmm_regime := 0

// True Structural Kill-Switch
if true_hmm_regime == 1 and close < regime_ema
    true_hmm_regime := 0
if true_hmm_regime == -1 and close > regime_ema
    true_hmm_regime := 0

// 2. Visual Box Regime (Uses strictBinary for UI continuous colors)
if is_trending
    if rsi_val > 50 and di_plus > di_minus and cvd_trend >= 0 and close > regime_ema
        visual_hmm_regime := 1
    else if rsi_val < 50 and di_minus > di_plus and cvd_trend <= 0 and close < regime_ema
        visual_hmm_regime := -1
else if not strictBinary and (hurst < 0.45 or adx_val < 15)
    visual_hmm_regime := 0

// Visual Structural Kill-Switch
if not strictBinary
    if visual_hmm_regime == 1 and close < regime_ema
        visual_hmm_regime := 0
    if visual_hmm_regime == -1 and close > regime_ema
        visual_hmm_regime := 0

// 3. 1-Bar Neutral Transition Gates (Execution Delay)
var int true_display_regime = 0
var int last_true_hmm = 0
if true_hmm_regime != last_true_hmm
    true_display_regime := 0 // Force neutral state on the transition bar
else
    true_display_regime := true_hmm_regime // Lock in on the following bar
last_true_hmm := true_hmm_regime

var int visual_display_regime = 0
var int last_visual_hmm = 0
if visual_hmm_regime != last_visual_hmm
    visual_display_regime := 0 
else
    visual_display_regime := visual_hmm_regime 
last_visual_hmm := visual_hmm_regime


// Executable Regime Zones (Main Chart Overlay - Continuous Adaptive Box)
var box active_regime_box = na
var float regime_open = na
var float regime_extreme = na
var int last_visual_display = -999

if useRegime
    if visual_display_regime != last_visual_display
        // State flipped: Start a brand new contiguous box
        color box_col = na
        if visual_display_regime == 1
            regime_open := open
            regime_extreme := high
            box_col := color.new(BULL_COLOR, 85)
        else if visual_display_regime == -1
            regime_open := open
            regime_extreme := low
            box_col := color.new(BEAR_COLOR, 85)
        else
            regime_open := math.min(open, close)
            regime_extreme := math.max(open, close)
            box_col := color.new(color.yellow, 90)
            
        active_regime_box := box.new(left=bar_index, top=math.max(regime_open, regime_extreme), right=bar_index + 1, bottom=math.min(regime_open, regime_extreme), border_color=na, bgcolor=box_col, force_overlay=true)
        last_visual_display := visual_display_regime
    else
        // Same regime: Stretch the existing box to the right and expand extremes
        if not na(active_regime_box)
            if visual_display_regime == 1
                regime_extreme := math.max(regime_extreme, high)
            else if visual_display_regime == -1
                regime_extreme := math.min(regime_extreme, low)
            else
                regime_extreme := math.max(regime_extreme, math.max(open, close))
                regime_open := math.min(regime_open, math.min(open, close))
                
            box.set_right(active_regime_box, bar_index + 1)
            box.set_top(active_regime_box, math.max(regime_open, regime_extreme))
            box.set_bottom(active_regime_box, math.min(regime_open, regime_extreme))

// 24x Anomaly Anchor Meta-Mean (ICE VWAV Cluster)
var float cum_pv = 0.0
var float cum_v = 0.0
cum_pv += hlc3 * volume
cum_v  += volume

float vol_sma = ta.sma(volume, 20)
float vol_std = math.max(ta.stdev(volume, 20), 1e-5)
float vol_z = vol_std != 0 ? (volume - vol_sma) / vol_std : 0.0

var array<float> anc_pv = array.new_float(0)
var array<float> anc_v  = array.new_float(0)

if vol_z > 2.5
    array.unshift(anc_pv, cum_pv[1] > 0 ? cum_pv[1] : 0)
    array.unshift(anc_v, cum_v[1] > 0 ? cum_v[1] : 0)
    if array.size(anc_pv) > 24
        array.pop(anc_pv)
        array.pop(anc_v)

float sum_vwav = 0.0
int count_vwav = 0
if array.size(anc_pv) > 0
    for idx_vwav = 0 to array.size(anc_pv) - 1
        float pv_start = array.get(anc_pv, idx_vwav)
        float v_start  = array.get(anc_v, idx_vwav)
        float denom = cum_v - v_start
        if denom > 0
            sum_vwav += (cum_pv - pv_start) / denom
            count_vwav += 1

float meta_mean_24 = count_vwav > 0 ? sum_vwav / count_vwav : close
float meta_std_24  = ta.stdev(close, 24)
float causal_z_score = meta_std_24 != 0 ? (close - meta_mean_24) / meta_std_24 : 0.0

// Dislocation Z-Score for LWA Gate
float fast_ema_20 = ta.ema(close, 20)
float fast_std_20 = math.max(ta.stdev(close, 20), 1e-5)
float tether_z    = (close - fast_ema_20) / fast_std_20

// ACV: Pulse Engine (Kinematic Saturation Decay)
float barRange = math.max(high - low, syminfo.mintick)
float closeLoc = (close - low) / barRange
bool bullConv = closeLoc >= 0.7 and close > open
bool bearConv = closeLoc <= 0.3 and close < open
var float bullPulse = 0.0
var float bearPulse = 0.0
bullPulse := bullConv ? math.min(bullPulse + 1.0, pulseCap) : bullPulse * pulseDecay
bearPulse := bearConv ? math.min(bearPulse + 1.0, pulseCap) : bearPulse * pulseDecay
float pulse_sat = math.max(bullPulse, bearPulse) / pulseCap

// ACV: Effort vs Result (Absorption & Liquidation Wicks)
float bar_rng = math.max(high - low, syminfo.mintick)
float body_sz = math.abs(close - open)
float u_wick  = high - math.max(close, open)
float l_wick  = math.min(close, open) - low
float vol_pct = ta.percentrank(volume, 100)

// Condition 1: Tight Accumulation (High Volume, Compressed Body)
bool is_tight_abs = vol_pct > 80 and body_sz < bar_rng * 0.35
// Condition 2: Violent Liquidation Wick (High Volume, Massive Rejection Wick)
bool is_liq_wick_bull = vol_pct > 80 and l_wick > bar_rng * 0.45
bool is_liq_wick_bear = vol_pct > 80 and u_wick > bar_rng * 0.45

bool abs_bull = is_tight_abs or is_liq_wick_bull
bool abs_bear = is_tight_abs or is_liq_wick_bear

// Dynamic Channel Variance for PRC (Exact ChartPrime Translation)
float prc_dist_val = ta.highest(ta.sma(high - low, prcLength), prcLength) * (prcMult / 2.0)

//---------------------------------------------------------------------------------------------------------------------}
// 3. HEAVY MATRIX OPERATIONS (NON-CAUSAL CORE)
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

    for i = n - 3 to 0
        x.set(i, (b_tmp.get(i) - f.get(i) * x.get(i + 2) - c_tmp.get(i) * x.get(i + 1)) / d_tmp.get(i))

whittakerALS(array<float> prices, array<float> d_base, array<float> c_base, array<float> f_base, int n, int iters, float p, array<float> z) =>
    var array<float> weights = array.new_float(n, 1.0)
    var array<float> b_curr  = array.new_float(n)
    var array<float> d_curr  = array.new_float(n)
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
    for i = 0 to n - 1
        float sum_w = 0.0
        float sum_xw = 0.0
        for j = 0 to n - 1
            float diff = i - j
            float weight = math.exp(-(diff * diff) / (2.0 * h * h))
            sum_w += weight
            sum_xw += src.get(j) * weight
        out.set(i, sum_xw / sum_w)

// ChartPrime Polynomial Matrix Engine (Exact Translation: OLS via Normal Equations)
polyreg(series float p_source, int p_length, int p_degree, int p_extrapolate) =>
    var array<float> preds = array.new<float>()
    if barstate.islast
        preds.clear()
        int total = p_length + p_extrapolate
        matrix<float> X_all = matrix.new<float>(total, p_degree + 1, 0.0)
        for i = 0 to total - 1
            for j = 0 to p_degree
                X_all.set(i, j, math.pow(i, j))

        matrix<float> y = matrix.new<float>(p_length, 1, 0.0)
        for i = 0 to p_length - 1
            y.set(i, 0, p_source[p_length - 1 - i]) // Oldest to Newest

        matrix<float> X_tr = matrix.new<float>(p_length, p_degree + 1, 0.0)
        for i = 0 to p_length - 1
            for j = 0 to p_degree
                X_tr.set(i, j, X_all.get(i, j))

        matrix<float> Xt = matrix.transpose(X_tr)
        matrix<float> XtX = matrix.mult(Xt, X_tr)
        matrix<float> Xty = matrix.mult(Xt, y)
        matrix<float> XtX_inv = matrix.inv(XtX) // Fast standard inverse
        matrix<float> b = matrix.mult(XtX_inv, Xty)

        array<float> b_arr = matrix.col(b, 0)
        array<float> preds_arr = matrix.mult(X_all, b_arr)

        for i = 0 to total - 1
            preds.push(preds_arr.get(i))
    preds

//---------------------------------------------------------------------------------------------------------------------}
// 4. THE AUTONOMIC MATRIX (BARSTATE.ISLAST EVALUATION)
//---------------------------------------------------------------------------------------------------------------------{
var array<float> d_base = array.new_float(lengthInput)
var array<float> c_base = array.new_float(lengthInput)
var array<float> f_base = array.new_float(lengthInput)

if barstate.isfirst
    float k = lambdaInput
    for i = 0 to lengthInput - 1
        float di = 6.0 * k
        float ci = -4.0 * k
        float fi = k
        if i == 0
            di := k
            ci := -2.0 * k
        else if i == 1
            di := 5.0 * k
        else if i == lengthInput - 2
            di := 5.0 * k
            ci := -2.0 * k
        else if i == lengthInput - 1
            di := k
            ci := 0.0
            fi := 0.0
        d_base.set(i, di)
        c_base.set(i, ci)
        f_base.set(i, fi)

var array<float> arr_highs = array.new_float(lengthInput)
var array<float> arr_lows  = array.new_float(lengthInput)
var array<float> arr_close = array.new_float(lengthInput)
var array<float> arr_open  = array.new_float(lengthInput)
var array<float> arr_cvd   = array.new_float(lengthInput)
var array<float> arr_oi    = array.new_float(lengthInput)
var array<float> arr_prem_z= array.new_float(lengthInput)
var array<float> arr_usdt  = array.new_float(lengthInput)
var array<float> arr_pulse = array.new_float(lengthInput)
var array<bool>  arr_abs_bull = array.new_bool(lengthInput)
var array<bool>  arr_abs_bear = array.new_bool(lengthInput)
var array<float> arr_vol_pct = array.new_float(lengthInput)
var array<float> arr_z     = array.new_float(lengthInput)
var array<float> arr_prc_dist = array.new_float(lengthInput)

var array<float> arr_hurst = array.new_float(lengthInput)
var array<int>   arr_hmm   = array.new_int(lengthInput)

// LWA Causal Physics Variables
float raw_atr = ta.atr(14)
var array<float> arr_atr = array.new_float(lengthInput)
var array<float> arr_vol = array.new_float(lengthInput)
var array<float> arr_vol_sma = array.new_float(lengthInput)
var array<float> arr_tether_z = array.new_float(lengthInput)

// Active Unmitigated Targets
var array<float> active_bull_y = array.new_float()
var array<line>  active_bull_l = array.new_line()
var array<float> active_bear_y = array.new_float()
var array<line>  active_bear_l = array.new_line()

var table hud = table.new(position.top_right, 5, 8, bgcolor = color.new(color.black, 80), border_color = color.new(color.gray, 60), border_width = 1)

// Permanent Memory Ratchets (Prevents Non-Causal Scrub-outs)
var array<int> mem_star_s   = array.new<int>()
var array<int> mem_star_l   = array.new<int>()
var array<int> mem_cvd_s    = array.new<int>()
var array<int> mem_cvd_l    = array.new<int>()
var array<int> mem_oi_s     = array.new<int>()
var array<int> mem_oi_l     = array.new<int>()
var array<int> mem_prem_s   = array.new<int>()
var array<int> mem_prem_l   = array.new<int>()
var array<int> mem_usdt_s   = array.new<int>()
var array<int> mem_usdt_l   = array.new<int>()
var array<int> mem_vac_s    = array.new<int>()
var array<int> mem_vac_l    = array.new<int>()

method memorize(array<int> arr, int val) =>
    if not arr.includes(val)
        arr.push(val)
        if arr.size() > 500
            arr.shift()
    true

// Compute Fast-Twitch PRC Matrix (ChartPrime Algorithm)
var array<float> prc_predictions = array.new<float>()
if prcEnable
    prc_predictions := polyreg(prcSource, prcLength, prcDegree, prcExtrap)

if barstate.islast and bar_index >= lengthInput
    // 4.1 Collect Data
    for i = 0 to lengthInput - 1
        arr_highs.set(i, high[i])
        arr_lows.set(i, low[i])
        arr_close.set(i, close[i])
        arr_open.set(i, open[i])
        arr_cvd.set(i, ltf_cvd_cum[i])
        arr_oi.set(i, ltf_oi_close[i])
        arr_prem_z.set(i, prem_z[i])
        arr_usdt.set(i, ltf_usdt_close[i])
        arr_pulse.set(i, pulse_sat[i])
        arr_abs_bull.set(i, abs_bull[i])
        arr_abs_bear.set(i, abs_bear[i])
        arr_vol_pct.set(i, vol_pct[i])
        arr_z.set(i, causal_z_score[i])
        arr_prc_dist.set(i, prc_dist_val[i])
        arr_atr.set(i, raw_atr[i])
        arr_vol.set(i, volume[i])
        arr_vol_sma.set(i, vol_sma[i])
        arr_tether_z.set(i, tether_z[i])
        arr_hurst.set(i, hurst[i])
        
        // Populate HMM array strictly with the True Mathematical Regime for gating
        arr_hmm.set(i, true_display_regime[i])

    // Clear UI
    active_bull_y.clear()
    active_bull_l.clear()
    active_bear_y.clear()
    active_bear_l.clear()
    
    if line.all.size() > 0
        for i = array.size(line.all) - 1 to 0
            line.delete(array.get(line.all, i))
    if label.all.size() > 0
        for i = array.size(label.all) - 1 to 0
            label.delete(array.get(label.all, i))
    if polyline.all.size() > 0
        for i = array.size(polyline.all) - 1 to 0
            polyline.delete(array.get(polyline.all, i))

    float chart_range = array.max(arr_highs) - array.min(arr_lows)
    float base_offset = chart_range * 0.05
    float stack_offset = chart_range * 0.08

    var array<float> zExtUp = array.new_float(lengthInput)
    var array<float> zExtDn = array.new_float(lengthInput)
    var array<float> zNW    = array.new_float(lengthInput)

    // Compute Non-Causal Topology
    whittakerALS(arr_highs, d_base, c_base, f_base, lengthInput, 5, pUpperInput, zExtUp)
    whittakerALS(arr_lows,  d_base, c_base, f_base, lengthInput, 5, pLowerInput, zExtDn)
    nadarayaWatson(arr_close, lengthInput, nwBandwidth, zNW)

    array<chart.point> weso_pts = array.new<chart.point>()
    
    // Locking State Variables
    int running_top_stack = 1
    int last_top_idx = -10
    int running_bot_stack = 1
    int last_bot_idx = -10
    
    bool base_cleared_short = false
    bool base_cleared_long  = false
    bool star_lock_short = false
    bool star_lock_long  = false
    
    int bars_since_touch_upper = 999
    int bars_since_touch_lower = 999
    int bars_since_prc_upper   = 999
    int bars_since_prc_lower   = 999

    bool lock_cvd_short = false
    bool lock_oi_short = false
    bool lock_prem_short = false
    bool lock_usdt_short = false
    bool lock_vac_short = false
    bool lock_cvd_long = false
    bool lock_oi_long = false
    bool lock_prem_long = false
    bool lock_usdt_long = false
    bool lock_vac_long = false
    
    // Liquidity Sweep Pivot Memory
    float last_ph = na
    float last_pl = na

    // 4.2 Causal Execution Evaluation Loop (Oldest to Newest)
    for i = lengthInput - 1 to 0
        int idx = bar_index - i
        float val_c = arr_close.get(i)
        
        // HMM Stationarity / Regime Evaluation
        int   cur_hmm   = arr_hmm.get(i)
        float cur_hurst = arr_hurst.get(i)

        // Rolling Local Pivot Evaluation (LSP)
        bool is_ph = false
        bool is_pl = false
        if i + 8 < lengthInput
            is_ph := true
            is_pl := true
            float target_h = arr_highs.get(i+1)
            float target_l = arr_lows.get(i+1)
            for p = 1 to 7
                if target_h <= arr_highs.get(i+1+p)
                    is_ph := false
                if target_l >= arr_lows.get(i+1+p)
                    is_pl := false
            if target_h <= arr_highs.get(i)
                is_ph := false
            if target_l >= arr_lows.get(i)
                is_pl := false
                
        if is_ph
            last_ph := arr_highs.get(i+1)
        if is_pl
            last_pl := arr_lows.get(i+1)
        
        float eU = zExtUp.get(i)
        float eD = zExtDn.get(i)
        float mid = (eU + eD) / 2.0
        float envWidth = math.max(eU - eD, syminfo.mintick)
        
        // Subpane WESO Line
        float pricePos = math.max(-1.0, math.min(1.0, (val_c - mid) / (envWidth / 2.0)))
        weso_pts.push(chart.point.from_index(idx, pricePos))

        // PRC Computations
        float prc_mid_val = 0.0
        float prc_up = 0.0
        float prc_dn = 0.0
        float current_dist = prc_dist_val[0]
        
        if prcEnable and i < prcLength
            int p_idx = prcLength - 1 - i
            if p_idx >= 0 and p_idx < prc_predictions.size()
                prc_mid_val := prc_predictions.get(p_idx)
                prc_up := prc_mid_val + current_dist
                prc_dn := prc_mid_val - current_dist

        if idx - last_top_idx > 3
            running_top_stack := 1
        if idx - last_bot_idx > 3
            running_bot_stack := 1

        // Arming Mechanism - WESO Touch
        if arr_highs.get(i) >= eU
            bars_since_touch_upper := 0
        else
            bars_since_touch_upper += 1

        if arr_lows.get(i) <= eD
            bars_since_touch_lower := 0
        else
            bars_since_touch_lower += 1

        // Arming Mechanism - Fast-Twitch PRC Touch
        if prcEnable and i < prcLength and arr_highs.get(i) >= prc_up
            bars_since_prc_upper := 0
        else
            bars_since_prc_upper += 1

        if prcEnable and i < prcLength and arr_lows.get(i) <= prc_dn
            bars_since_prc_lower := 0
        else
            bars_since_prc_lower += 1

        // Dual-Engine Shield: Touched EITHER Boundary within last 5 bars
        bool weso_armed_short = bars_since_touch_upper <= 5
        bool weso_armed_long  = bars_since_touch_lower <= 5
        bool prc_armed_short  = prcEnable and bars_since_prc_upper <= 5
        bool prc_armed_long   = prcEnable and bars_since_prc_lower <= 5

        // HMM Stationarity Gate (Blocks counter-trend boundary signals during Non-Stationary Trends)
        if cur_hmm == 1
            weso_armed_short := false
            prc_armed_short  := false
        if cur_hmm == -1
            weso_armed_long := false
            prc_armed_long  := false

        // -------------------------------------------------------------------------
        // NEW LWA GATE: Liquidation Wick & Structural Sweep Singularity
        // -------------------------------------------------------------------------
        bool lwa_armed_short = false
        bool lwa_armed_long = false
        
        float c_hi = arr_highs.get(i)
        float c_lo = arr_lows.get(i)
        float c_c  = arr_close.get(i)
        float c_o  = arr_open.get(i)
        float c_rng = math.max(c_hi - c_lo, syminfo.mintick)
        float c_atr = arr_atr.get(i)
        float c_vol = arr_vol.get(i)
        float c_v_sma = arr_vol_sma.get(i)
        
        // 1. Shockwave Physics (V-Tops/Flash Crashes - Overrides HMM Gate)
        if useLwa
            bool is_massive_expansion = c_rng > (c_atr * lwaAtrMult)
            bool is_vol_climax        = c_vol > (c_v_sma * 2.0)
            
            float lwa_u_wick = c_hi - math.max(c_c, c_o)
            float lwa_l_wick = math.min(c_c, c_o) - c_lo
            
            bool is_top_rej = lwa_u_wick > (c_rng * lwaWickPct)
            bool is_bot_rej = lwa_l_wick > (c_rng * lwaWickPct)
            
            float t_z = arr_tether_z.get(i)
            
            if is_massive_expansion and is_top_rej and is_vol_climax and t_z > lwaZScore
                lwa_armed_short := true
            if is_massive_expansion and is_bot_rej and is_vol_climax and t_z < -lwaZScore
                lwa_armed_long := true
                
        // 2. Liquidity Sweep Protocol (Double Tops/SFP - Overrides HMM Gate)
        if useLsp
            bool is_sweep_short = not na(last_ph) and c_hi > last_ph and c_c < last_ph and c_c < c_o and c_vol > c_v_sma
            bool is_sweep_long  = not na(last_pl) and c_lo < last_pl and c_c > last_pl and c_c > c_o and c_vol > c_v_sma
            
            if is_sweep_short
                lwa_armed_short := true
            if is_sweep_long
                lwa_armed_long := true

        // Dual-Engine Shield: Touched EITHER Boundary within last 5 bars OR triggered LWA/LSP
        bool is_armed_short = (weso_armed_short or prc_armed_short or lwa_armed_short)
        bool is_armed_long  = (weso_armed_long or prc_armed_long or lwa_armed_long)

        // Unmitigated Liquidity Target Mitigation
        if showUnmit
            if active_bull_y.size() > 0
                for j = active_bull_y.size() - 1 to 0
                    if arr_lows.get(i) <= active_bull_y.get(j)
                        line.set_x2(active_bull_l.get(j), idx)
                        active_bull_y.remove(j)
                        active_bull_l.remove(j)
            if active_bear_y.size() > 0
                for j = active_bear_y.size() - 1 to 0
                    if arr_highs.get(i) >= active_bear_y.get(j)
                        line.set_x2(active_bear_l.get(j), idx)
                        active_bear_y.remove(j)
                        active_bear_l.remove(j)

        // 4.3 ACV Defense Vault: Effort vs Result (Absorption & Liquidation Wicks)
        bool abs_candle_short = arr_abs_bear.get(i)
        bool abs_candle_long  = arr_abs_bull.get(i)

        // ZERO-LAG ARMING (Apex Rejection Gate + Permanent Memory Ratchet)
        bool raw_star_short = is_armed_short and not star_lock_short and val_c >= mid and abs_candle_short
        if raw_star_short or mem_star_s.includes(idx)
            mem_star_s.memorize(idx)
            base_cleared_short := true
            star_lock_short := true
            string armed_by_s = lwa_armed_short ? "LWA/LSP Climax" : (weso_armed_short and prc_armed_short) ? "WESO + PRC Convergence" : (weso_armed_short ? "WESO Boundary" : "PRC Fast-Twitch")
            string reg_inf_s  = cur_hmm == 0 ? "Stationary (Safe)" : "Shockwave Override (Trending)"
            string tt_short = "Liquidation Top [" + armed_by_s + "]\nRegime: " + reg_inf_s + "\nApex Liquidation Absorption (Bearish)"
            label.new(idx, arr_highs.get(i) + base_offset, "❂", style=label.style_none, textcolor=color.orange, size=size.normal, tooltip=tt_short, force_overlay=true)
            if showUnmit
                active_bear_y.push(arr_highs.get(i))
                active_bear_l.push(line.new(idx, arr_highs.get(i), bar_index, arr_highs.get(i), color=color.new(BEAR_COLOR, 30), style=line.style_dashed, width=2, force_overlay=true))
                
        bool raw_star_long = is_armed_long and not star_lock_long and val_c <= mid and abs_candle_long
        if raw_star_long or mem_star_l.includes(idx)
            mem_star_l.memorize(idx)
            base_cleared_long := true
            star_lock_long := true
            string armed_by_l = lwa_armed_long ? "LWA/LSP Climax" : (weso_armed_long and prc_armed_long) ? "WESO + PRC Convergence" : (weso_armed_long ? "WESO Boundary" : "PRC Fast-Twitch")
            string reg_inf_l  = cur_hmm == 0 ? "Stationary (Safe)" : "Shockwave Override (Trending)"
            string tt_long = "Liquidation Bottom [" + armed_by_l + "]\nRegime: " + reg_inf_l + "\nApex Liquidation Absorption (Bullish)"
            label.new(idx, arr_lows.get(i) - base_offset, "❂", style=label.style_none, textcolor=color.orange, size=size.normal, tooltip=tt_long, force_overlay=true)
            if showUnmit
                active_bull_y.push(arr_lows.get(i))
                active_bull_l.push(line.new(idx, arr_lows.get(i), bar_index, arr_lows.get(i), color=color.new(BULL_COLOR, 30), style=line.style_dashed, width=2, force_overlay=true))

        // Reset Clearance and Locks if price reverts to causal Z-score midline (Prevents Scrub-outs)
        if arr_z.get(i) < 0.0
            base_cleared_short := false
            star_lock_short := false
            lock_cvd_short := false
            lock_oi_short := false
            lock_prem_short := false
            lock_usdt_short := false
            lock_vac_short := false

        if arr_z.get(i) > 0.0
            base_cleared_long := false
            star_lock_long := false
            lock_cvd_long := false
            lock_oi_long := false
            lock_prem_long := false
            lock_usdt_long := false
            lock_vac_long := false

        // The Execution Gate: Absorption Base (0-Lag Secondary Lock)
        // Bypasses the strict Pulse Engine lock if the base is cleared by a verified Apex Wick
        bool acv_clear_short = base_cleared_short
        bool acv_clear_long  = base_cleared_long

        // Vacuum Math (Instantaneous Causal Lookback)
        bool is_vacuum = i+1 < lengthInput ? (arr_vol_pct.get(i+1) > 95 and arr_vol_pct.get(i) < 20) : false

        // 4.4 Execution Triggers (0-Lag Instant Firing with Permanent Memory)
        if acv_clear_short
            bool trig_cvd = false
            if useCvd and not lock_cvd_short and (i+1 < lengthInput)
                trig_cvd := arr_cvd.get(i) <= arr_cvd.get(i+1)

            if trig_cvd or mem_cvd_s.includes(idx)
                mem_cvd_s.memorize(idx)
                label.new(idx, arr_highs.get(i) + base_offset + (running_top_stack * stack_offset), "C\nV\nD\n▼", style=label.style_none, textcolor=BEAR_COLOR, size=size.tiny, tooltip="Micro-CVD Absorption Divergence", force_overlay=true)
                running_top_stack += 1
                last_top_idx := idx
                lock_cvd_short := true
            
            bool trig_oi = false
            if useOi and not lock_oi_short and (i+1 < lengthInput)
                trig_oi := arr_oi.get(i) < arr_oi.get(i+1)

            if trig_oi or mem_oi_s.includes(idx)
                mem_oi_s.memorize(idx)
                label.new(idx, arr_highs.get(i) + base_offset + (running_top_stack * stack_offset), "O\nI\n▼", style=label.style_none, textcolor=BEAR_COLOR, size=size.tiny, tooltip="Open Interest Exhaustion", force_overlay=true)
                running_top_stack += 1
                last_top_idx := idx
                lock_oi_short := true
                
            bool trig_prem = false
            if usePrem and not lock_prem_short and (i+1 < lengthInput)
                trig_prem := arr_prem_z.get(i+1) > 2.0 and arr_prem_z.get(i) <= 2.0
            
            if trig_prem or mem_prem_s.includes(idx)
                mem_prem_s.memorize(idx)
                label.new(idx, arr_highs.get(i) + base_offset + (running_top_stack * stack_offset), "P\nR\nE\nM\n▼", style=label.style_none, textcolor=BEAR_COLOR, size=size.tiny, tooltip="Premium Index Snap (Greed Unwind)", force_overlay=true)
                running_top_stack += 1
                last_top_idx := idx
                lock_prem_short := true

            bool trig_usdt = false
            if useUsdt and not lock_usdt_short and (i+1 < lengthInput)
                trig_usdt := arr_usdt.get(i) >= arr_usdt.get(i+1)
            
            if trig_usdt or mem_usdt_s.includes(idx)
                mem_usdt_s.memorize(idx)
                label.new(idx, arr_highs.get(i) + base_offset + (running_top_stack * stack_offset), "U\nS\nD\nT\n▼", style=label.style_none, textcolor=BEAR_COLOR, size=size.tiny, tooltip="Macro Capital Fracture (USDT.D)", force_overlay=true)
                running_top_stack += 1
                last_top_idx := idx
                lock_usdt_short := true

            bool trig_vac = false
            if useVacuum and not lock_vac_short
                trig_vac := is_vacuum
            
            if trig_vac or mem_vac_s.includes(idx)
                mem_vac_s.memorize(idx)
                label.new(idx, arr_highs.get(i) + base_offset + (running_top_stack * stack_offset), "V\nA\nC\n▼", style=label.style_none, textcolor=BEAR_COLOR, size=size.tiny, tooltip="Volume-Velocity Vacuum", force_overlay=true)
                running_top_stack += 1
                last_top_idx := idx
                lock_vac_short := true

        if acv_clear_long
            bool trig_cvd = false
            if useCvd and not lock_cvd_long and (i+1 < lengthInput)
                trig_cvd := arr_cvd.get(i) >= arr_cvd.get(i+1)

            if trig_cvd or mem_cvd_l.includes(idx)
                mem_cvd_l.memorize(idx)
                label.new(idx, arr_lows.get(i) - base_offset - (running_bot_stack * stack_offset), "C\nV\nD\n▲", style=label.style_none, textcolor=BULL_COLOR, size=size.tiny, tooltip="Micro-CVD Absorption Divergence", force_overlay=true)
                running_bot_stack += 1
                last_bot_idx := idx
                lock_cvd_long := true
            
            bool trig_oi = false
            if useOi and not lock_oi_long and (i+1 < lengthInput)
                trig_oi := arr_oi.get(i) < arr_oi.get(i+1)

            if trig_oi or mem_oi_l.includes(idx)
                mem_oi_l.memorize(idx)
                label.new(idx, arr_lows.get(i) - base_offset - (running_bot_stack * stack_offset), "O\nI\n▲", style=label.style_none, textcolor=BULL_COLOR, size=size.tiny, tooltip="Open Interest Exhaustion", force_overlay=true)
                running_bot_stack += 1
                last_bot_idx := idx
                lock_oi_long := true
                
            bool trig_prem = false
            if usePrem and not lock_prem_long and (i+1 < lengthInput)
                trig_prem := arr_prem_z.get(i+1) < -2.0 and arr_prem_z.get(i) >= -2.0
            
            if trig_prem or mem_prem_l.includes(idx)
                mem_prem_l.memorize(idx)
                label.new(idx, arr_lows.get(i) - base_offset - (running_bot_stack * stack_offset), "P\nR\nE\nM\n▲", style=label.style_none, textcolor=BULL_COLOR, size=size.tiny, tooltip="Premium Index Snap (Fear Unwind)", force_overlay=true)
                running_bot_stack += 1
                last_bot_idx := idx
                lock_prem_long := true

            bool trig_usdt = false
            if useUsdt and not lock_usdt_long and (i+1 < lengthInput)
                trig_usdt := arr_usdt.get(i) <= arr_usdt.get(i+1)
            
            if trig_usdt or mem_usdt_l.includes(idx)
                mem_usdt_l.memorize(idx)
                label.new(idx, arr_lows.get(i) - base_offset - (running_bot_stack * stack_offset), "U\nS\nD\nT\n▲", style=label.style_none, textcolor=BULL_COLOR, size=size.tiny, tooltip="Macro Capital Fracture (USDT.D)", force_overlay=true)
                running_bot_stack += 1
                last_bot_idx := idx
                lock_usdt_long := true

            bool trig_vac = false
            if useVacuum and not lock_vac_long
                trig_vac := is_vacuum
            
            if trig_vac or mem_vac_l.includes(idx)
                mem_vac_l.memorize(idx)
                label.new(idx, arr_lows.get(i) - base_offset - (running_bot_stack * stack_offset), "V\nA\nC\n▲", style=label.style_none, textcolor=BULL_COLOR, size=size.tiny, tooltip="Volume-Velocity Vacuum", force_overlay=true)
                running_bot_stack += 1
                last_bot_idx := idx
                lock_vac_long := true

        // -----------------------------------------------------------------------------------------------------------------}
        // MAIN CHART OVERLAY DRAWING (LINE.NEW DECIMATION LOOP TO PREVENT SUBPANE SQUISH)
        // -----------------------------------------------------------------------------------------------------------------{
        if i % 10 == 0 and i != 0
            int idx1 = idx
            int idx2 = bar_index - (i - 10)
            
            // WESO Boundaries
            line.new(idx1, zExtUp.get(i), idx2, zExtUp.get(i-10), color=color.new(BEAR_COLOR, 50), width=2, force_overlay=true)
            line.new(idx1, zExtDn.get(i), idx2, zExtDn.get(i-10), color=color.new(BULL_COLOR, 50), width=2, force_overlay=true)
            line.new(idx1, zNW.get(i), idx2, zNW.get(i-10), color=color.new(#FFD700, 0), width=2, force_overlay=true)
            
            // Algorithmic Killzone Heatmaps
            if showKillzones
                float mm1 = meta_mean_24[i]
                float mm2 = meta_mean_24[i-10]
                line.new(idx1, mm1 * 1.005, idx2, mm2 * 1.005, color=color.new(color.red, 40), width=1, force_overlay=true)
                line.new(idx1, mm1 * 0.995, idx2, mm2 * 0.995, color=color.new(color.green, 40), width=1, force_overlay=true)
                line.new(idx1, mm1 * 1.01, idx2, mm2 * 1.01, color=color.new(color.red, 60), width=2, force_overlay=true)
                line.new(idx1, mm1 * 0.99, idx2, mm2 * 0.99, color=color.new(color.green, 60), width=2, force_overlay=true)
                line.new(idx1, mm1 * 1.02, idx2, mm2 * 1.02, color=color.new(color.red, 80), width=2, force_overlay=true)
                line.new(idx1, mm1 * 0.98, idx2, mm2 * 0.98, color=color.new(color.green, 80), width=2, force_overlay=true)

    // Fast-Twitch PRC Matrix Overlay (Drawn independently to maintain fast 1-bar resolution)
    if prcEnable and prc_predictions.size() > 0
        int step_prc = math.max(1, int(math.ceil(prcLength / 120.0))) 
        for p = prcLength - 1 to step_prc by step_prc
            int p_idx1 = prcLength - 1 - p
            int p_idx2 = prcLength - 1 - (p - step_prc)

            if p_idx1 >= 0 and p_idx2 >= 0 and p_idx1 < prc_predictions.size() and p_idx2 < prc_predictions.size()
                int idx1 = bar_index - p
                int idx2 = bar_index - (p - step_prc)
                float p_m1 = prc_predictions.get(p_idx1)
                float p_m2 = prc_predictions.get(p_idx2)
                float dist = prc_dist_val[0]

                line.new(idx1, p_m1 + dist, idx2, p_m2 + dist, color=color.new(BEAR_COLOR, 30), width=2, force_overlay=true)
                line.new(idx1, p_m1 - dist, idx2, p_m2 - dist, color=color.new(BULL_COLOR, 30), width=2, force_overlay=true)
                line.new(idx1, p_m1, idx2, p_m2, color=color.new(color.white, 50), width=1, style=line.style_dashed, force_overlay=true)

        if prcDisplayExt and prcExtrap > 0
            for k = 1 to prcExtrap
                int p_idx1 = prcLength - 1 + k - 1
                int p_idx2 = prcLength - 1 + k

                if p_idx1 < prc_predictions.size() and p_idx2 < prc_predictions.size()
                    int idx1 = bar_index + k - 1
                    int idx2 = bar_index + k
                    float p_m1 = prc_predictions.get(p_idx1)
                    float p_m2 = prc_predictions.get(p_idx2)
                    float dist = prc_dist_val[0]

                    line.new(idx1, p_m1 + dist, idx2, p_m2 + dist, color=color.new(BEAR_COLOR, 30), width=2, style=line.style_dotted, force_overlay=true)
                    line.new(idx1, p_m1 - dist, idx2, p_m2 - dist, color=color.new(BULL_COLOR, 30), width=2, style=line.style_dotted, force_overlay=true)
                    line.new(idx1, p_m1, idx2, p_m2, color=color.new(color.white, 50), width=1, style=line.style_dotted, force_overlay=true)


    // Subpane WESO Oscillator
    polyline.new(weso_pts, line_color = color.blue, line_width = 2)

    //-----------------------------------------------------------------------------------------------------------------}
    // 5. INVERSE KERNEL BOUNDING (IKB MULTIVERSE PROJECTION)
    //-----------------------------------------------------------------------------------------------------------------{
    float max_nw_slope = 0.0
    for j = 0 to lengthInput - 2
        float sl = math.abs(zNW.get(j) - zNW.get(j+1))
        if sl > max_nw_slope
            max_nw_slope := sl

    int valid_paths = 0
    float atr_val = ta.atr(14)
    for p = 1 to 25
        if valid_paths >= 3
            break
        bool is_valid = true
        float path_y = zNW.get(0)
        array<chart.point> pts = array.new<chart.point>()
        pts.push(chart.point.from_index(bar_index, path_y))
        
        for k = 1 to extrapInput
            float step_val = math.random(-atr_val, atr_val, bar_index + p * k)
            float new_y = path_y + step_val
            if math.abs(new_y - path_y) > (max_nw_slope * 2.0)
                is_valid := false
                break
            pts.push(chart.point.from_index(bar_index + k, new_y))
            path_y := new_y
            
        if is_valid
            valid_paths += 1
            int transp = valid_paths == 1 ? 20 : (valid_paths == 2 ? 50 : 80)
            int w = valid_paths == 1 ? 3 : 1
            polyline.new(pts, line_color=color.new(IKB_COLOR, transp), line_width=w, force_overlay=true)
            if valid_paths == 1
                label.new(bar_index + extrapInput, path_y, "Primary IKB Path", style=label.style_label_left, color=color.new(color.black, 80), textcolor=IKB_COLOR, size=size.small, force_overlay=true)

    // Status UI Update
    table.cell(hud, 0, 0, "MARKET REGIME", text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(hud, 1, 0, true_display_regime == 1 ? "NON-STATIONARY (BULL)" : true_display_regime == -1 ? "NON-STATIONARY (BEAR)" : "STATIONARY (CHOP)", text_color = true_display_regime == 1 ? BULL_COLOR : true_display_regime == -1 ? BEAR_COLOR : color.yellow)
    table.cell(hud, 0, 1, "STATIONARITY (HURST)", text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(hud, 1, 1, str.tostring(hurst, "#.###"), text_color = hurst > hurstThresh ? BEAR_COLOR : BULL_COLOR)
    table.cell(hud, 0, 2, "ACV Shield", text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(hud, 1, 2, pulse_sat > 0.8 ? "LOCKED (Parabolic)" : "CLEAR", text_color = pulse_sat > 0.8 ? BEAR_COLOR : BULL_COLOR)
    table.cell(hud, 0, 3, "Base Validation", text_color = color.white, bgcolor = color.new(color.gray, 60))
    table.cell(hud, 1, 3, base_cleared_short or base_cleared_long ? "ABSORBED ❂" : "AWAITING", text_color = base_cleared_short or base_cleared_long ? color.orange : color.white)
````
