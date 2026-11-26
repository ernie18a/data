# Liquidity Grab Detector v4.7

- url: https://www.tradingview.com/script/197K7640-liquidity-grab-detector-v4-7/
- type: indicator
- pine_id: PUB;d01909c4fdb444dbbb43cf9a715b0b1f
- version: 2.0

## Description

**Parameters Reference Guide**  
*What each parameter does — explained in simple terms*

### Pool Detection — Liquidity Pool Detection

| Parameter                  | Default | Range       | Explanation |
|---------------------------|---------|-------------|-----------|
| Swing Length              | 10      | 5–15        | Sensitivity of swing pivot detection. Lower = more pools, more noise. Higher = fewer but more significant pools. |
| Merge Distance (×ATR)     | 0.35    | 0.2–0.6     | If two pools are closer than this distance, they merge into one. Removes duplicates. |
| Pool Half-Width (×ATR)    | 0.40    | 0.25–0.60   | Width of the pool zone on each side of the midpoint. Wider = fewer false sweeps, but larger SL. |
| Max Pools Per Side        | 8       | 6–12        | Maximum active pools on each side (buy/sell). Higher = more cluttered chart. |
| Pool Min Age (bars)       | 15      | 10–25       | Pool must exist for at least N bars before sweep is considered. Protects from micro-sweeps. |
| Pool Max Age (bars)       | 1000    | 500–1500    | Pool is removed after N bars. On 5M ≈ 2.5 trading days. |
| Min Pool Health (%)       | 30      | 20–45       | Don’t trade sweeps on pools with health below 30%. Liquidity already taken. |

### Fixed Levels — Institutional Fixed Levels

| Parameter              | Default              | Range     | Explanation |
|-----------------------|----------------------|-----------|-----------|
| PDH / PDL             | ON                   | ON/OFF    | Previous Day High/Low. Most important levels for index futures. |
| PWH / PWL             | OFF (ON Mon-Tue)     | ON/OFF    | Previous Week High/Low. Best to enable only on first 2 days of the week. |
| Equal H/L             | ON                   | ON/OFF    | Detection of Equal Highs/Lows — classic market maker traps. |
| EQ Threshold (×ATR)   | 0.30                 | 0.15–0.50 | Pivots are considered “equal” if difference is less than this × ATR. |
| Round Numbers         | ON                   | ON/OFF    | Round numbers as liquidity levels. |
| Round Number Step     | 100 (indices)        | —         | Step for round number detection (Gold = 10, Dow = 1000). |

### Sweep Detection — Signal Parameters

| Parameter                | Default | Range    | Explanation |
|-------------------------|---------|----------|-----------|
| Min Penetration (×ATR)  | 0.0     | 0.0–0.2  | Minimum depth of pool penetration. 0.0 = any sweep (score will filter weak ones). |
| Activate Score Filter   | OFF     | ON/OFF   | OFF = show all sweeps (score is only informational). ON = block signals below Min Score. |
| Min Score               | 55      | 45–75    | Minimum sweep quality (0–100). Works only if Score Filter is ON. |
| Cooldown (bars)         | 6       | 4–12     | Minimum bars between signals. Prevents overtrading on the same pool. |
| Confirmation Window (bars) | 0    | 0–3      | How many bars to wait for confirmation after sweep. 0 = immediate scalping entry. |

### SFP Trigger Engine — BullByte-style Signals

| Parameter               | Default | Range      | Explanation |
|------------------------|---------|------------|-----------|
| Enable SFP             | ON      | ON/OFF     | Enable second signal channel (AVWAP exhaustion + PR gating + BOS). |
| Impulse AVWAP Anchor   | 50      | 20–100     | Impulse AVWAP reset period. |
| Daily AVWAP            | ON      | ON/OFF     | Institutional fair price reference for the day. |
| PR Lookback            | 250     | 100–350    | Lookback period for Percentile Rank calculation. |
| Arm Long at PR ≤       | 0.10    | 0.05–0.15  | Arm long when extremely oversold. |
| Arm Short at PR ≥      | 0.90    | 0.85–0.95  | Arm short when extremely overbought. |
| Armed TTL (bars)       | 8       | 5–12       | How long the system stays “armed”. |
| BOS Length (bars)      | 3       | 2–5        | Break of Structure length. |
| Min Stretch (×ATR)     | 1.2     | 0.8–2.0    | Minimum AVWAP stretch required to arm. |

### HTF Trend Filter

| Parameter            | Default     | Range       | Explanation |
|---------------------|-------------|-------------|-----------|
| Enable HTF Filter   | ON          | ON/OFF      | **Very important**. Trade only in the direction of HTF trend. |
| HTF Timeframe       | 60 (1H)     | 15, 60, 240 | Higher timeframe for trend filter. |
| HTF EMA Length      | 200         | 100–200     | EMA 200 — institutional long-term trend. |

### Risk Zones — SL/TP Zones

| Parameter         | Default | Range     | Explanation |
|------------------|---------|-----------|-----------|
| Show Risk Zones  | ON      | ON/OFF    | Show SL/TP zones on every signal. |
| SL Multiplier (×ATR) | 1.0  | 0.7–1.5   | SL placed 1 ATR beyond the probe extreme. |
| TP1 R:R          | 1.0     | 0.8–1.5   | TP1 = 1:1. Close 50% and move SL to breakeven. |
| TP2 R:R          | 2.0     | 1.5–3.0   | TP2 = 1:2. Next structural zone / liquidity pool. |

## Source Code

````pine
//@version=6
// Liquidity Grab Detector v6 (LGD v6) — FINAL MERGED BUILD
//
// Built from v5 base + v6 additions:
//   - All v5 features: auto-cal, sessions, regime, MTF pools, grind sweep
//   - Volume Vacuum (from Liquidity Echo): quiet period before sweep = score boost
//   - Cross-engine: pool sweeps feed SFP arming signal

indicator('Liquidity Grab Detector v6', 'LGD v6', overlay = true,
     max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, max_bars_back = 5000)

// ═══════════════════════════════════════════════════════════════════════════
// §1. INPUTS
// ═══════════════════════════════════════════════════════════════════════════

grp_pool = 'Pool Detection'
swing_len         = input.int(10,    'Swing Length',             minval=3,  maxval=50,   group=grp_pool)
merge_atr         = input.float(0.35,'Merge Distance (×ATR)',   step=0.05, minval=0.05, group=grp_pool)
pool_half_atr_in  = input.float(0.40,'Pool Zone Half-Width (×ATR)', step=0.05, minval=0.1, group=grp_pool,
     tooltip='Manual default. Overridden by auto-calibration if §2.5 enabled.')
pool_max_per_side = input.int(10,    'Max Pools Per Side',      minval=4,  maxval=20,   group=grp_pool)
pool_max_age      = input.int(1500,  'Pool Max Age (bars)',     minval=200,maxval=5000,  group=grp_pool)
use_pdhl          = input.bool(true, 'Include PDH/PDL',         group=grp_pool)
use_pwhl          = input.bool(false,'Include PWH/PWL',         group=grp_pool)
use_equal_hl      = input.bool(true, 'Include Equal H/L',       group=grp_pool)
eq_thr_atr_in     = input.float(0.3, 'Equal H/L Threshold (×ATR)', step=0.05, group=grp_pool,
     tooltip='Manual default. Overridden by auto-calibration if §2.5 enabled.')

grp_sweep = 'Sweep Detection'
min_pen_atr_in    = input.float(0.0, 'Min Penetration (×ATR)',   step=0.01, group=grp_sweep,
     tooltip='Manual default. Overridden by auto-calibration if §2.5 enabled.')
use_scoring       = input.bool(false,'Activate Score Filter',     group=grp_sweep)
min_score         = input.float(55.0,'Min Score (when filter ON)',step=5.0,  group=grp_sweep)
sweep_cooldown    = input.int(8,     'Cooldown (bars)',           minval=1,  group=grp_sweep)
confirm_window    = input.int(0,     'Confirmation Window (bars)',minval=0, maxval=5, group=grp_sweep)

// ───────────────────────────────────────────────────────────────────────────
// NEW §1.X: AUTO-CALIBRATION
// ───────────────────────────────────────────────────────────────────────────
grp_cal           = 'Auto-Calibration (v6)'
use_auto_cal      = input.bool(true, 'Enable Auto-Calibration', group=grp_cal,
     tooltip='Measures wick/body ratio, volume CV, and ATR percentile over the calibration window. ' +
             'Adapts pool_half_atr, min_pen_atr, eq_thr_atr, and grind detection toggle per instrument.')
cal_window        = input.int(100,   'Calibration Window (bars)', minval=50, maxval=300, group=grp_cal)
cal_bias          = input.string('NEUTRAL', 'Sensitivity Bias',
     options=['CONSERVATIVE','NEUTRAL','AGGRESSIVE'], group=grp_cal,
     tooltip='Scales calibrated thresholds. CONSERVATIVE = tighter (fewer signals). AGGRESSIVE = looser.')

// ───────────────────────────────────────────────────────────────────────────
// NEW §1.Y: GRIND SWEEP PATH
// ───────────────────────────────────────────────────────────────────────────
grp_grind         = 'Grind Sweep Path (v6)'
use_grind         = input.bool(true, 'Enable Grind Sweep Detection', group=grp_grind,
     tooltip='Detects slow-grind sweeps: price was beyond pool boundary for K bars, then closes back inside. ' +
             'No spike wick required. Especially useful for FX/index futures with low wick/body ratios.')
grind_lookback    = input.int(3,     'Grind Lookback (bars)', minval=1, maxval=8, group=grp_grind)
grind_max_close   = input.float(0.30,'Max Close Distance From Pool (×ATR)', step=0.05, minval=0.05, maxval=1.0, group=grp_grind,
     tooltip='Returning close must be within this distance from the pool boundary. Prevents misclassifying breakout runs.')

// ───────────────────────────────────────────────────────────────────────────
// NEW §1.Z: MULTI-TF POOLS
// ───────────────────────────────────────────────────────────────────────────
grp_mtf           = 'Multi-TF Pools (v6)'
use_mtf1          = input.bool(true, 'Enable HTF1 Pools', group=grp_mtf)
mtf1_tf           = input.timeframe('60', 'HTF1 Timeframe', group=grp_mtf)
use_mtf2          = input.bool(true, 'Enable HTF2 Pools', group=grp_mtf)
mtf2_tf           = input.timeframe('240', 'HTF2 Timeframe', group=grp_mtf)
mtf_swing_len     = input.int(5, 'HTF Swing Length', minval=3, maxval=20, group=grp_mtf,
     tooltip='Swing pivot length used on each HTF. Lower than chart TF length because HTF bars carry more weight.')

// ───────────────────────────────────────────────────────────────────────────
// NEW §1.W: REGIME DETECTOR
// ───────────────────────────────────────────────────────────────────────────
grp_regime        = 'Regime Detector (v6)'
use_regime        = input.bool(true, 'Enable Regime-Aware Weights', group=grp_regime,
     tooltip='Detects TREND / RANGE / COIL regime via ADX and BB width. Adjusts scoring weights per regime: ' +
             'TREND favors HTF + MSS; RANGE favors pool significance + channel position; COIL boosts all weights.')
adx_len           = input.int(14, 'ADX Length', minval=5, maxval=30, group=grp_regime)
adx_trend_thr     = input.float(25.0, 'ADX Trend Threshold', step=1.0, group=grp_regime)
adx_coil_thr      = input.float(18.0, 'ADX Coil Threshold (also requires low BB width)', step=1.0, group=grp_regime)
bb_coil_pct       = input.float(30.0, 'BB Width Coil Percentile', step=5.0, minval=10.0, maxval=50.0, group=grp_regime)

// ───────────────────────────────────────────────────────────────────────────
// NEW §1.V: SESSION FILTER
// ───────────────────────────────────────────────────────────────────────────
grp_session       = 'Session Filter (v6)'
use_session       = input.bool(true, 'Enable Session-Aware Scoring', group=grp_session,
     tooltip='Classifies current bar by trading session (UTC). Acts as score multiplier (not hard gate by default). ' +
             'Session boundaries are standard: Asia 00-07, London 07-12, NY pre 12-13:30, NY RTH 13:30-20, NY post 20-22, Overnight 22-00.')
session_mode      = input.string('Multiplier', 'Session Mode', options=['Multiplier','Gate','Off'], group=grp_session,
     tooltip='Multiplier = soft scoring effect. Gate = block signals in low-quality sessions. Off = ignore session.')
// Per-session quality weights (default profile for US equity/futures bias)
sw_asia           = input.float(0.85, 'Asia Quality (00-07 UTC)', step=0.05, minval=0.3, maxval=1.2, group=grp_session)
sw_lon            = input.float(1.00, 'London Quality (07-12 UTC)', step=0.05, minval=0.3, maxval=1.2, group=grp_session)
sw_ny_pre         = input.float(0.95, 'NY Pre-RTH Quality (12-13:30 UTC)', step=0.05, minval=0.3, maxval=1.2, group=grp_session)
sw_ny_rth         = input.float(1.10, 'NY RTH Quality (13:30-20 UTC)', step=0.05, minval=0.3, maxval=1.2, group=grp_session)
sw_ny_post        = input.float(0.80, 'NY Post-RTH Quality (20-22 UTC)', step=0.05, minval=0.3, maxval=1.2, group=grp_session)
sw_overnight      = input.float(0.70, 'Overnight Quality (22-00 UTC)', step=0.05, minval=0.3, maxval=1.2, group=grp_session)
gate_threshold    = input.float(0.80, 'Gate Threshold (if Mode=Gate)', step=0.05, minval=0.3, maxval=1.2, group=grp_session,
     tooltip='When session_mode=Gate, sessions below this quality block signals entirely.')

// ───────────────────────────────────────────────────────────────────────────
// NEW §1.U: VOLUME VACUUM (from Liquidity Echo)
// ───────────────────────────────────────────────────────────────────────────
grp_vacuum        = 'Volume Vacuum (v6)'
show_vacuum_bg    = input.bool(true, 'Highlight Vacuum Bars',    group=grp_vacuum,
     tooltip='Subtle yellow tint on bars where volume is below vacuum threshold.')
vac_min_bars      = input.int(2,     'Min Consecutive Low-Vol Bars', minval=1, maxval=5, group=grp_vacuum,
     tooltip='Volume must stay below threshold for this many bars before vacuum activates.')

grp_sfp = 'SFP Trigger Engine'
use_sfp           = input.bool(true, 'Enable SFP Triggers',     group=grp_sfp)
sfp_anchor_len    = input.int(50,    'Impulse AVWAP Anchor',    minval=10, group=grp_sfp)
sfp_use_dvwap     = input.bool(true, 'Use Daily AVWAP',         group=grp_sfp)
sfp_pr_len        = input.int(250,   'PR Lookback',             minval=50, group=grp_sfp)
sfp_q_hi          = input.float(0.90,'Arm Short at PR ≥',       step=0.01, group=grp_sfp)
sfp_q_lo          = input.float(0.10,'Arm Long at PR ≤',        step=0.01, group=grp_sfp)
sfp_ttl           = input.int(8,     'Armed TTL (bars)',         minval=2,  group=grp_sfp)
sfp_bos_len       = input.int(3,     'BOS Length',               minval=2,  group=grp_sfp)
sfp_cd            = input.int(8,     'SFP Cooldown (bars)',      minval=0,  group=grp_sfp)

grp_htf = 'HTF Trend (legacy v4)'
use_htf           = input.bool(true, 'Enable HTF EMA Filter',   group=grp_htf,
     tooltip='Legacy binary HTF filter from v4. Distinct from §1.Z Multi-TF Pools.')
htf_tf            = input.timeframe('60','HTF EMA Timeframe',   group=grp_htf)
htf_ema_len       = input.int(200,   'HTF EMA Length',           minval=20, group=grp_htf)

grp_risk = 'Risk Zones'
show_risk         = input.bool(true, 'Show SL/TP Zone',         group=grp_risk)
sl_atr            = input.float(1.0, 'SL (×ATR beyond probe)',  step=0.1, group=grp_risk)
tp1_rr            = input.float(1.0, 'TP1 R:R',                 step=0.5, group=grp_risk)
tp2_rr            = input.float(2.0, 'TP2 R:R',                 step=0.5, group=grp_risk)

grp_vis = 'Visuals'
show_pools        = input.bool(true, 'Show Pool Zones',         group=grp_vis)
show_avwap        = input.bool(true, 'Show AVWAP Lines',        group=grp_vis)
show_armed_bg     = input.bool(true, 'Shade Armed Window',      group=grp_vis)
show_dash         = input.bool(true, 'Show Dashboard',          group=grp_vis)
bull_c            = input.color(color.new(#14b8a6, 0),'Bullish', group=grp_vis)
bear_c            = input.color(color.new(#ff5a5f, 0),'Bearish', group=grp_vis)
sweep_c           = input.color(color.new(#f59e0b, 0),'Sweep',   group=grp_vis)
mtf_c             = input.color(color.new(#a855f7, 0),'MTF Pool Border', group=grp_vis,
     tooltip='Distinct border color for multi-TF (HTF1/HTF2) pools to differentiate from local swing pools.')

// ═══════════════════════════════════════════════════════════════════════════
// §2. CORE SERIES
// ═══════════════════════════════════════════════════════════════════════════

atr14   = ta.atr(14)
atr100  = ta.atr(100)
vol_sma = ta.sma(volume, 20)
hlc_v   = hlc3
tr_val  = ta.tr

// HTF EMA (legacy v4 binary filter)
htf_ema_e  = ta.ema(close, htf_ema_len)
htf_ema_v  = request.security(syminfo.tickerid, htf_tf, htf_ema_e, barmerge.gaps_off, barmerge.lookahead_off)
htf_close  = request.security(syminfo.tickerid, htf_tf, close,      barmerge.gaps_off, barmerge.lookahead_off)
htf_bull   = htf_close > htf_ema_v
htf_bear   = htf_close < htf_ema_v

// PDH/PDL/PWH/PWL
pdh = request.security(syminfo.tickerid, 'D', high[1], barmerge.gaps_off, barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, 'D', low[1],  barmerge.gaps_off, barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, 'W', high[1], barmerge.gaps_off, barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, 'W', low[1],  barmerge.gaps_off, barmerge.lookahead_on)

// Local swings
ph_v = ta.pivothigh(high, swing_len, swing_len)
pl_v = ta.pivotlow(low,   swing_len, swing_len)

var float last_sh = na
var float last_sl = na
var float prev_sh = na
var float prev_sl = na
if not na(ph_v)
    prev_sh := last_sh
    last_sh := ph_v
if not na(pl_v)
    prev_sl := last_sl
    last_sl := pl_v

// Micro CHoCH
var float m_hh = na
var float m_ll = na
var int m_trend = 0
float m_ph = ta.pivothigh(high, 5, 5)
float m_pl = ta.pivotlow(low, 5, 5)
if not na(m_ph)
    m_hh := m_ph
if not na(m_pl)
    m_ll := m_pl
if m_trend <= 0 and not na(m_hh) and close > m_hh
    m_trend := 1
if m_trend >= 0 and not na(m_ll) and close < m_ll
    m_trend := -1

// ═══════════════════════════════════════════════════════════════════════════
// §2.5  AUTO-CALIBRATION (NEW in v5)
// ═══════════════════════════════════════════════════════════════════════════
// Measures three behavioral properties of the current instrument over cal_window
// bars and adjusts key parameters accordingly. Bias scaler is the only manual
// user decision. Reasoned heuristics — NOT backtested per instrument.

// Bias multipliers (CONSERVATIVE = tighter thresholds, fewer signals)
bias_tight = cal_bias == 'CONSERVATIVE' ? 0.80 : cal_bias == 'AGGRESSIVE' ? 1.20 : 1.00
bias_loose = cal_bias == 'CONSERVATIVE' ? 1.20 : cal_bias == 'AGGRESSIVE' ? 0.80 : 1.00

// Metric A: wick/body ratio — high = spike character, low = grind character
cal_avg_wick = ta.sma((high - math.max(open, close)) + (math.min(open, close) - low), cal_window)
cal_avg_body = ta.sma(math.abs(close - open), cal_window)
cal_wb_ratio = cal_avg_body > 0 ? cal_avg_wick / cal_avg_body : 1.0

// Metric B: volume coefficient of variation — high = session-structured
cal_vol_mean = ta.sma(volume, cal_window)
cal_vol_std  = ta.stdev(volume, cal_window)
cal_vol_cv   = cal_vol_mean > 0 ? cal_vol_std / cal_vol_mean : 0.5

// Metric C: ATR mean percentile — current volatility rank
cal_atr_hi = ta.highest(atr14, cal_window)
cal_atr_lo = ta.lowest(atr14, cal_window)
cal_atr_pct = (cal_atr_hi - cal_atr_lo) > 0 ? (atr14 - cal_atr_lo) / (cal_atr_hi - cal_atr_lo) : 0.5
cal_atr_mean = ta.sma(cal_atr_pct, cal_window)

// Derived thresholds (effective values used downstream)
// Wicky instruments (high wb_ratio) → wider pool zones, stricter penetration
// Grindy instruments → narrower pool zones, looser penetration (grind path active)
auto_pool_half = math.max(math.min(0.30 + cal_wb_ratio * 0.10, 0.65), 0.25) * bias_loose
auto_min_pen   = math.max(math.min(cal_wb_ratio * 0.04, 0.20), 0.0) * bias_tight
auto_eq_thr    = math.max(math.min(0.20 + cal_atr_mean * 0.20, 0.50), 0.15) * bias_loose

// Effective parameters: auto if enabled, else manual
pool_half_atr  = use_auto_cal ? auto_pool_half : pool_half_atr_in
min_pen_atr    = use_auto_cal ? auto_min_pen   : min_pen_atr_in
eq_thr_atr     = use_auto_cal ? auto_eq_thr    : eq_thr_atr_in

// Auto grind enable: instruments with wb_ratio < 0.85 benefit from grind path
auto_grind_recommended = cal_wb_ratio < 0.85
grind_active = use_grind  // user toggle wins; recommendation shown in dashboard

// ═══════════════════════════════════════════════════════════════════════════
// §2.6  VOLUME VACUUM (NEW in v6, from Liquidity Echo)
// ═══════════════════════════════════════════════════════════════════════════
// Detects quiet periods (low volume) before sweep. Stale liquidity pools
// accumulate more stops during quiet periods → sweep after vacuum = stronger.
float vac_vol_cv_adj = math.max(math.min(cal_vol_cv, 1.5), 0.3)
float eff_vac_thr = math.max(math.min(0.55 + vac_vol_cv_adj * 0.25, 0.90), 0.50)
int vac_vol_window = cal_vol_cv > 0.80 ? 50 : 20
float vol_ma_vac = ta.sma(volume, vac_vol_window)
float vol_ratio_vac = vol_ma_vac > 0 ? volume / vol_ma_vac : 1.0
var int vac_count = 0
vac_count := vol_ratio_vac < eff_vac_thr ? vac_count + 1 : 0
bool vac_active = vac_count >= vac_min_bars

bgcolor(show_vacuum_bg and vac_active ? color.new(#FFF176, 96) : na, title='Volume Vacuum')

// Equal H/L (uses auto-calibrated eq_thr if cal enabled)
eq_thr     = atr14 * eq_thr_atr
has_eq_hi  = use_equal_hl and not na(prev_sh) and not na(last_sh) and math.abs(last_sh - prev_sh) < eq_thr
has_eq_lo  = use_equal_hl and not na(prev_sl) and not na(last_sl) and math.abs(last_sl - prev_sl) < eq_thr

// ═══════════════════════════════════════════════════════════════════════════
// §2.7  SESSION DETECTION (NEW in v5)
// ═══════════════════════════════════════════════════════════════════════════
// Classifies current bar by UTC hour into one of 6 trading sessions.
// Returns session name + quality multiplier.
// Multiplier is reasoned default for US futures/equity bias — adjust if your
// instrument set is FX-dominant or crypto-dominant.

f_session() =>
    int hr_utc = hour(time, 'UTC')
    int min_utc = minute(time, 'UTC')
    int total_min = hr_utc * 60 + min_utc
    string sn = ''
    float sw = 1.0
    if total_min >= 0 and total_min < 420            // 00:00 - 07:00
        sn := 'ASIA'
        sw := sw_asia
    else if total_min >= 420 and total_min < 720    // 07:00 - 12:00
        sn := 'LON'
        sw := sw_lon
    else if total_min >= 720 and total_min < 810    // 12:00 - 13:30
        sn := 'NY-PRE'
        sw := sw_ny_pre
    else if total_min >= 810 and total_min < 1200   // 13:30 - 20:00
        sn := 'NY-RTH'
        sw := sw_ny_rth
    else if total_min >= 1200 and total_min < 1320  // 20:00 - 22:00
        sn := 'NY-POST'
        sw := sw_ny_post
    else                                            // 22:00 - 24:00
        sn := 'OVN'
        sw := sw_overnight
    [sn, sw]

[cur_session, session_w] = f_session()
session_active = session_mode != 'Off'
session_pass   = not session_active or session_mode == 'Multiplier' or session_w >= gate_threshold

// ═══════════════════════════════════════════════════════════════════════════
// §2.8  REGIME DETECTOR (NEW in v5)
// ═══════════════════════════════════════════════════════════════════════════
// Simple regime detection: ADX for trend strength, BB width percentile for compression.
// TREND = high ADX. COIL = low ADX + low BB width. RANGE = everything else.
// Regime drives adaptive scoring weights below.

// ADX (built-in via [dirmov] is not available in v6 directly; compute manually)
f_adx(int len) =>
    float up = ta.change(high)
    float dn = -ta.change(low)
    float plusDM = na(up) ? na : (up > dn and up > 0 ? up : 0.0)
    float minusDM = na(dn) ? na : (dn > up and dn > 0 ? dn : 0.0)
    float trur = ta.rma(ta.tr, len)
    float plus = 100.0 * ta.rma(plusDM, len) / math.max(trur, 0.0001)
    float minus = 100.0 * ta.rma(minusDM, len) / math.max(trur, 0.0001)
    float sum = plus + minus
    float dx = 100.0 * math.abs(plus - minus) / (sum == 0 ? 1.0 : sum)
    ta.rma(dx, len)

adx_v = f_adx(adx_len)

// BB width percentile (lower = compression)
bb_basis = ta.sma(close, 20)
bb_dev   = ta.stdev(close, 20)
bb_width = (bb_basis > 0) ? ((bb_basis + 2*bb_dev) - (bb_basis - 2*bb_dev)) / bb_basis : 0.0
bb_pct   = ta.percentrank(bb_width, 100)

// Regime classification (priority: COIL → TREND → RANGE)
is_coil  = use_regime and not na(adx_v) and adx_v < adx_coil_thr and bb_pct < bb_coil_pct
is_trend = use_regime and not na(adx_v) and adx_v > adx_trend_thr and not is_coil
is_range = use_regime and not is_coil and not is_trend

regime_str = is_trend ? 'TREND' : is_coil ? 'COIL' : is_range ? 'RANGE' : 'OFF'

// ═══════════════════════════════════════════════════════════════════════════
// §3. AVWAP ENGINE
// ═══════════════════════════════════════════════════════════════════════════

var float ipv = na
var float iv  = na
bool nhi = high > ta.highest(high, sfp_anchor_len)[1]
bool nlo = low  < ta.lowest(low,  sfp_anchor_len)[1]
if barstate.isfirst
    ipv := hlc_v * volume
    iv  := volume
else
    if nhi or nlo
        ipv := hlc_v * volume
        iv  := volume
    else
        ipv += hlc_v * volume
        iv  += volume
impAVWAP = ipv / math.max(iv, 1.0)

var float dpv = na
var float dv  = na
bool nd = ta.change(time('D')) != 0
if barstate.isfirst or nd
    dpv := hlc_v * volume
    dv  := volume
else
    dpv += hlc_v * volume
    dv  += volume
dAVWAP = dpv / math.max(dv, 1.0)

stretchImp = (close - impAVWAP) / math.max(atr100, syminfo.mintick)
stretchDay = (close - dAVWAP) / math.max(atr100, syminfo.mintick)
upperW = high - math.max(open, close)
lowerW = math.min(open, close) - low
wickSkew = tr_val > 0 ? (upperW - lowerW) / tr_val : 0.0

f_z(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s > 0 ? (src - m) / s : 0.0

volZ = f_z(volume, 50)

f_tanh(x) =>
    xc = math.min(math.max(x, -10.0), 10.0)
    e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

exh_raw = ta.ema(stretchImp + (sfp_use_dvwap ? 0.8 * stretchDay : 0) + 0.7 * wickSkew + 0.35 * math.max(volZ, 0) * math.sign(stretchImp), 5)
emaC  = ta.ema(close, 34)
rocP  = ta.roc(emaC, 9)
curv  = -(rocP - ta.ema(rocP, 3)[1])
score_bb = 100.0 * f_tanh(1.1 * exh_raw + 0.9 * curv)
pr = ta.percentrank(score_bb, sfp_pr_len)

// ═══════════════════════════════════════════════════════════════════════════
// §3.5  MULTI-TF POOL SOURCES (NEW in v5)
// ═══════════════════════════════════════════════════════════════════════════
// Request swing pivots from HTF1 and HTF2 timeframes. These bars carry more
// institutional weight than chart TF — registered as pools with weight=3.
// Single tuple call per HTF to ensure consistent context.

f_htf_pivots(int len) =>
    float ph = ta.pivothigh(high, len, len)
    float pl = ta.pivotlow(low, len, len)
    [ph, pl]

[mtf1_ph_raw, mtf1_pl_raw] = request.security(syminfo.tickerid, mtf1_tf,
     f_htf_pivots(mtf_swing_len), barmerge.gaps_off, barmerge.lookahead_off)
[mtf2_ph_raw, mtf2_pl_raw] = request.security(syminfo.tickerid, mtf2_tf,
     f_htf_pivots(mtf_swing_len), barmerge.gaps_off, barmerge.lookahead_off)

// Track last registered values to avoid duplicate registration
var float last_mtf1_ph = na
var float last_mtf1_pl = na
var float last_mtf2_ph = na
var float last_mtf2_pl = na

mtf1_ph_new = use_mtf1 and not na(mtf1_ph_raw) and mtf1_ph_raw != last_mtf1_ph
mtf1_pl_new = use_mtf1 and not na(mtf1_pl_raw) and mtf1_pl_raw != last_mtf1_pl
mtf2_ph_new = use_mtf2 and not na(mtf2_ph_raw) and mtf2_ph_raw != last_mtf2_ph
mtf2_pl_new = use_mtf2 and not na(mtf2_pl_raw) and mtf2_pl_raw != last_mtf2_pl

// ═══════════════════════════════════════════════════════════════════════════
// §4. POOL SYSTEM
// ═══════════════════════════════════════════════════════════════════════════

// Pool arrays — sell (resistance) and buy (support)
var float[]  s_mid    = array.new_float()
var float[]  s_top    = array.new_float()
var float[]  s_bot    = array.new_float()
var int[]    s_hits   = array.new_int()
var float[]  s_health = array.new_float()
var int[]    s_state  = array.new_int()
var int[]    s_birth  = array.new_int()
var int[]    s_wt     = array.new_int()
var string[] s_src    = array.new_string()
var box[]    s_box    = array.new_box()
var line[]   s_line   = array.new_line()
var int[]    s_pend   = array.new_int()
var int[]    s_pbar   = array.new_int()
var float[]  s_pbase  = array.new_float()
var int[]    s_touch  = array.new_int()

var float[]  b_mid    = array.new_float()
var float[]  b_top    = array.new_float()
var float[]  b_bot    = array.new_float()
var int[]    b_hits   = array.new_int()
var float[]  b_health = array.new_float()
var int[]    b_state  = array.new_int()
var int[]    b_birth  = array.new_int()
var int[]    b_wt     = array.new_int()
var string[] b_src    = array.new_string()
var box[]    b_box    = array.new_box()
var line[]   b_line   = array.new_line()
var int[]    b_pend   = array.new_int()
var int[]    b_pbar   = array.new_int()
var float[]  b_pbase  = array.new_float()
var int[]    b_touch  = array.new_int()

f_del_pool(int idx, float[] mid, float[] top, float[] bot, int[] hits, float[] health, int[] state, int[] birth, int[] wt, string[] src, box[] bx, line[] ln, int[] pend, int[] pbar, float[] pbase, int[] touch) =>
    box.delete(array.get(bx, idx))
    line.delete(array.get(ln, idx))
    array.remove(mid, idx)
    array.remove(top, idx)
    array.remove(bot, idx)
    array.remove(hits, idx)
    array.remove(health, idx)
    array.remove(state, idx)
    array.remove(birth, idx)
    array.remove(wt, idx)
    array.remove(src, idx)
    array.remove(bx, idx)
    array.remove(ln, idx)
    array.remove(pend, idx)
    array.remove(pbar, idx)
    array.remove(pbase, idx)
    array.remove(touch, idx)

f_add_pool(float price, int x, float atr_r, bool is_sell, string source, int weight, float[] mid, float[] top, float[] bot, int[] hits, float[] health, int[] state, int[] birth, int[] wt, string[] src, box[] bx, line[] ln, int[] pend, int[] pbar, float[] pbase, int[] touch, int max_n) =>
    float half = math.max(atr_r * pool_half_atr, syminfo.mintick * 5)
    float t = price + half
    float b = price - half

    float merge_band = math.max(atr_r * merge_atr, syminfo.mintick * 8)
    int nearest = -1
    float best_d = 1e10
    if array.size(mid) > 0
        for i = 0 to array.size(mid) - 1
            if array.get(state, i) < 2
                float d = math.abs(price - array.get(mid, i))
                if d <= merge_band and d < best_d
                    best_d := d
                    nearest := i

    if nearest >= 0
        float old_mid = array.get(mid, nearest)
        int old_hits = array.get(hits, nearest)
        int new_hits = old_hits + 1
        float new_mid = (old_mid * old_hits + price) / new_hits
        float new_half = math.max(atr_r * pool_half_atr * (1 + math.min(new_hits, 8) * 0.05), syminfo.mintick * 5)
        if weight > array.get(wt, nearest)
            array.set(wt, nearest, weight)
            array.set(src, nearest, source)
        array.set(mid, nearest, new_mid)
        array.set(top, nearest, new_mid + new_half)
        array.set(bot, nearest, new_mid - new_half)
        array.set(hits, nearest, new_hits)
    else
        color pc = is_sell ? bear_c : bull_c
        // MTF pools get a distinctive border color
        bool is_mtf = str.contains(source, '-1H') or str.contains(source, '-4H') or str.contains(source, 'MTF')
        color bc = is_mtf ? mtf_c : pc
        box nb = box.new(x, t, bar_index + 10, b, bgcolor=color.new(pc, 88), border_color=color.new(bc, is_mtf ? 30 : 60), border_width=is_mtf ? 2 : 1)
        box.set_text_size(nb, size.tiny)
        box.set_text_halign(nb, text.align_left)
        box.set_text_valign(nb, is_sell ? text.align_top : text.align_bottom)
        line nl = line.new(x, price, bar_index + 10, price, color=color.new(pc, 40), style=line.style_dotted, width=1)
        array.push(mid, price)
        array.push(top, t)
        array.push(bot, b)
        array.push(hits, 1)
        array.push(health, 100.0)
        array.push(state, 0)
        array.push(birth, x)
        array.push(wt, weight)
        array.push(src, source)
        array.push(bx, nb)
        array.push(ln, nl)
        array.push(pend, 0)
        array.push(pbar, -1)
        array.push(pbase, 0.0)
        array.push(touch, -1)
    while array.size(mid) > max_n
        f_del_pool(0, mid, top, bot, hits, health, state, birth, wt, src, bx, ln, pend, pbar, pbase, touch)

// Register local swing pivots
if not na(ph_v)
    int sx = bar_index - swing_len
    float ar = nz(atr14[swing_len], atr14)
    f_add_pool(ph_v, sx, ar, true, 'SwH', 2, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch, pool_max_per_side)

if not na(pl_v)
    int sx = bar_index - swing_len
    float ar = nz(atr14[swing_len], atr14)
    f_add_pool(pl_v, sx, ar, false, 'SwL', 2, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch, pool_max_per_side)

// Register MTF pools (v5 NEW)
if mtf1_ph_new
    f_add_pool(mtf1_ph_raw, bar_index, atr14, true, 'SwH-1H', 3, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch, pool_max_per_side)
    last_mtf1_ph := mtf1_ph_raw
if mtf1_pl_new
    f_add_pool(mtf1_pl_raw, bar_index, atr14, false, 'SwL-1H', 3, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch, pool_max_per_side)
    last_mtf1_pl := mtf1_pl_raw
if mtf2_ph_new
    f_add_pool(mtf2_ph_raw, bar_index, atr14, true, 'SwH-4H', 3, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch, pool_max_per_side)
    last_mtf2_ph := mtf2_ph_raw
if mtf2_pl_new
    f_add_pool(mtf2_pl_raw, bar_index, atr14, false, 'SwL-4H', 3, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch, pool_max_per_side)
    last_mtf2_pl := mtf2_pl_raw

// Register fixed levels (PDH/PDL/PWH/PWL)
var float prev_pdh = na
var float prev_pdl = na
if use_pdhl and not na(pdh) and pdh != prev_pdh
    f_add_pool(pdh, bar_index, atr14, true, 'PDH', 3, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch, pool_max_per_side)
    prev_pdh := pdh
if use_pdhl and not na(pdl) and pdl != prev_pdl
    f_add_pool(pdl, bar_index, atr14, false, 'PDL', 3, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch, pool_max_per_side)
    prev_pdl := pdl

var float prev_pwh = na
var float prev_pwl = na
if use_pwhl and not na(pwh) and pwh != prev_pwh
    f_add_pool(pwh, bar_index, atr14, true, 'PWH', 3, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch, pool_max_per_side)
    prev_pwh := pwh
if use_pwhl and not na(pwl) and pwl != prev_pwl
    f_add_pool(pwl, bar_index, atr14, false, 'PWL', 3, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch, pool_max_per_side)
    prev_pwl := pwl

// Equal H/L
var bool eq_hi_prev = false
var bool eq_lo_prev = false
bool eq_hi_new = has_eq_hi and not eq_hi_prev
bool eq_lo_new = has_eq_lo and not eq_lo_prev
eq_hi_prev := has_eq_hi
eq_lo_prev := has_eq_lo

if eq_hi_new and not na(last_sh)
    f_add_pool(last_sh, bar_index, atr14, true, 'EQH', 3, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch, pool_max_per_side)
if eq_lo_new and not na(last_sl)
    f_add_pool(last_sl, bar_index, atr14, false, 'EQL', 3, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch, pool_max_per_side)

// ═══════════════════════════════════════════════════════════════════════════
// §5. SCORING FUNCTIONS (regime-aware in v5)
// ═══════════════════════════════════════════════════════════════════════════

f_clamp(float v, float lo, float hi) => math.min(math.max(v, lo), hi)
f_norm(float x, float lo, float hi) => f_clamp((x - lo) / math.max(hi - lo, 1e-6), 0.0, 1.0)

// Regime-aware weights (v6)
// Trend regime: HTF + MSS dominant
// Range regime: pool significance + channel position dominant
// Coil regime: balanced + bonus
// Off (regime disabled): use v4 baseline weights
f_get_weights() =>
    float wP = 14.0  // C1 penetration
    float wR = 16.0  // C2 reclaim
    float wW = 12.0  // C3 wick dominance
    float wB = 6.0   // C4 body bias
    float wPs = 12.0 // C5 pool significance
    float wS = 10.0  // C6 stretch
    float wH = 8.0   // C7 HTF
    float wV = 10.0  // C8 volume
    float wCh = 6.0  // C9 micro CHoCH
    float wM = 10.0  // C10 MSS
    float wCp = 6.0  // C11 channel pos
    if use_regime
        if is_trend
            wH := 14.0
            wM := 14.0
            wPs := 8.0
            wCp := 4.0
            wW := 10.0
        else if is_range
            wPs := 16.0
            wCp := 10.0
            wH := 5.0
            wM := 8.0
            wW := 14.0
        else if is_coil
            wP := 16.0
            wR := 18.0
            wPs := 14.0
            wH := 10.0
    [wP, wR, wW, wB, wPs, wS, wH, wV, wCh, wM, wCp]

f_score_sweep(float pen_atr, float reclaim_pct, float wick_ratio, bool body_ok, int pool_hits, float pool_health, int pool_wt, float stretch, bool htf_ok, float vol_ratio, bool choch_ok, float mss_dist_atr, float channel_pct) =>
    [W_PEN, W_REC, W_WCK, W_BOD, W_PSG, W_STR, W_HTF, W_VOL, W_CHO, W_MSS, W_CHP] = f_get_weights()

    float pen_target = 0.35
    float pen_half = 0.65
    float pen_s = 1.0 - math.abs(pen_atr - pen_target) / math.max(pen_half, 0.2)
    pen_s := f_clamp(pen_s, 0.0, 1.0)

    float rec_s = f_norm(reclaim_pct, 30.0, 100.0)
    float wck_s = f_clamp(wick_ratio / 1.5, 0.0, 1.0)
    float bod_s = body_ok ? 1.0 : 0.3

    float hit_s = f_clamp(float(pool_hits) / 6.0, 0.0, 1.0)
    float hlt_s = f_norm(pool_health, 20.0, 100.0)
    float wt_s = pool_wt >= 3 ? 1.0 : pool_wt >= 2 ? 0.6 : 0.3
    float psg_s = (hit_s * 0.4 + hlt_s * 0.3 + wt_s * 0.3)

    float str_s = f_clamp(math.abs(stretch) / 2.0, 0.0, 1.0)
    float htf_s = not use_htf ? 0.5 : htf_ok ? 1.0 : 0.0
    float vol_s = na(vol_ratio) ? 0.5 : f_norm(vol_ratio, 0.7, 2.0)
    float cho_s = choch_ok ? 1.0 : 0.0
    float mss_s = f_clamp(mss_dist_atr / 1.2, 0.0, 1.0)
    float chp_s = na(channel_pct) ? 0.5 : channel_pct > 70.0 ? f_norm(channel_pct, 70.0, 100.0) : channel_pct < 30.0 ? f_norm(30.0 - channel_pct, 0.0, 30.0) : 0.2

    float total_w = W_PEN + W_REC + W_WCK + W_BOD + W_PSG + W_STR + W_HTF + W_VOL + W_CHO + W_MSS + W_CHP
    float total_s = W_PEN*pen_s + W_REC*rec_s + W_WCK*wck_s + W_BOD*bod_s + W_PSG*psg_s + W_STR*str_s + W_HTF*htf_s + W_VOL*vol_s + W_CHO*cho_s + W_MSS*mss_s + W_CHP*chp_s
    float base_score = total_w > 0 ? total_s / total_w * 100.0 : 0.0

    // Session multiplier (v6)
    float sess_mult = session_mode == 'Multiplier' ? session_w : 1.0
    // Regime coil bonus
    float coil_bonus = (use_regime and is_coil) ? 1.05 : 1.0

    base_score * sess_mult * coil_bonus

f_rev_type(float vol_z, float wick_r, float reclaim_p, bool body_ok) =>
    if vol_z > 1.5 and wick_r > 0.5 and reclaim_p > 60
        "ABS"
    else if wick_r > 0.6 and reclaim_p > 70 and body_ok
        "REJ"
    else if vol_z > 1.0 and reclaim_p > 50 and wick_r < 0.4
        "DIV"
    else
        "EXH"

f_type_min_score(string rev_type) =>
    rev_type == "ABS" ? 40.0 : rev_type == "REJ" ? 45.0 : rev_type == "DIV" ? 65.0 : 999.0

// ═══════════════════════════════════════════════════════════════════════════
// §6. POOL UPDATE + SWEEP DETECTION (spike path — v4 logic preserved)
// ═══════════════════════════════════════════════════════════════════════════

var int    last_sweep_bar = 0
var string last_sweep_dir = ""
var string last_sweep_lvl = ""
var float  last_sweep_score = 0.0
var string last_sweep_type = ""
var string last_sweep_path = ""    // "SPIKE" or "GRIND" (v6)
bool sweep_long  = false
bool sweep_short = false
float sweep_score_out = 0.0
string sweep_type_out = ""
string sweep_pool_src = ""
float sweep_pool_px = na
string sweep_path_out = ""

float near_sell = na
float near_buy  = na
for i = 0 to math.max(array.size(s_mid) - 1, 0)
    if i < array.size(s_mid) and array.get(s_state, i) < 2
        float m = array.get(s_mid, i)
        if m > close and (na(near_sell) or m < near_sell)
            near_sell := m
for i = 0 to math.max(array.size(b_mid) - 1, 0)
    if i < array.size(b_mid) and array.get(b_state, i) < 2
        float m = array.get(b_mid, i)
        if m < close and (na(near_buy) or m > near_buy)
            near_buy := m

float chan_pct = na
if not na(near_sell) and not na(near_buy) and near_sell > near_buy
    chan_pct := f_clamp((close - near_buy) / (near_sell - near_buy) * 100.0, 0.0, 100.0)

float mss_lo = ta.lowest(low, sfp_bos_len)[1]
float mss_hi = ta.highest(high, sfp_bos_len)[1]

// SELL pools (spike + grind path in v5)
if barstate.isconfirmed and array.size(s_mid) > 0 and session_pass
    for i = array.size(s_mid) - 1 to 0
        if i >= array.size(s_mid)
            continue
        float mid = array.get(s_mid, i)
        float top = array.get(s_top, i)
        float bot = array.get(s_bot, i)
        int st = array.get(s_state, i)
        int age = bar_index - array.get(s_birth, i)

        if st >= 2 or age > pool_max_age
            f_del_pool(i, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch)
            continue

        int last_t = array.get(s_touch, i)
        bool touch_spaced = last_t == -1 or (bar_index - last_t) >= 3
        if high >= bot and high <= top and close < mid and touch_spaced
            array.set(s_hits, i, array.get(s_hits, i) + 1)
            array.set(s_touch, i, bar_index)

        if close >= bot and close <= top
            float cap = vol_sma * 20
            float consumed = cap > 0 ? volume / cap * 5.0 : 0.0
            array.set(s_health, i, math.max(array.get(s_health, i) - consumed, 0.0))

        // SPIKE PATH (v4 preserved)
        float pen_spike = atr14 > 0 ? math.max(high - top, 0.0) / atr14 : 0.0
        float reclaim_spike = high > low ? (high - close) / (high - low) * 100.0 : 0.0
        bool sweep_spike = high > top and close < mid and pen_spike > min_pen_atr and reclaim_spike > 0

        // GRIND PATH (v5 NEW) — was above pool top in last K bars, now close back inside
        bool sweep_grind_short = false
        float pen_grind = 0.0
        if grind_active and not sweep_spike
            bool was_above = false
            for k = 1 to grind_lookback
                if bar_index >= k and close[k] > top + atr14 * 0.05
                    was_above := true
                    break
            // Current close back inside pool but not too deep below
            bool back_inside = close < top and close > bot - atr14 * grind_max_close
            bool body_bear = close < open
            sweep_grind_short := was_above and back_inside and body_bear
            if sweep_grind_short
                pen_grind := atr14 > 0 ? math.max(high - top, 0.0) / atr14 : 0.0

        bool sweep_raw = sweep_spike or sweep_grind_short
        bool is_grind_branch = sweep_grind_short and not sweep_spike
        float pen_used = is_grind_branch ? pen_grind : pen_spike
        float reclaim_used = is_grind_branch ? math.max(reclaim_spike, 50.0) : reclaim_spike  // grind has weaker wick reclaim; floor it
        int pend_st = array.get(s_pend, i)

        if sweep_raw and st == 0 and pend_st == 0
            bool body_ok = close < open
            float wick_r = tr_val > 0 ? upperW / tr_val : 0.0
            float vol_r = not na(vol_sma) and vol_sma > 0 ? volume / vol_sma : na
            bool htf_ok = not use_htf or htf_bear
            float mss_d = atr14 > 0 ? math.max(mss_lo - close, 0.0) / atr14 : 0.0
            bool cho_ok = false
            for j = 0 to math.min(5, bar_index - 1)
                if bar_index > j + 1 and m_trend[j+1] >= 0 and m_trend[j] < 0
                    cho_ok := true
                    break

            float sc = f_score_sweep(pen_used, reclaim_used, wick_r, body_ok, array.get(s_hits, i), array.get(s_health, i), array.get(s_wt, i), stretchImp, htf_ok, vol_r, cho_ok, mss_d, chan_pct)
            float age_ratio = f_clamp(float(age) / 25.0, 0.0, 1.0)
            float age_penalty = f_clamp(0.20 + math.pow(age_ratio, 1.6) * 0.80, 0.20, 1.0)
            sc := sc * age_penalty
            // Volume vacuum bonus: quiet period before sweep = higher conviction
            if vac_active
                sc := sc * 1.08
            // Session multiplier applied once inside f_score_sweep — do not apply again here
            bool score_ok = not use_scoring or sc >= min_score

            if confirm_window == 0
                string rev = is_grind_branch ? 'GRIND' : f_rev_type(volZ, wick_r, reclaim_used, body_ok)
                float type_min = is_grind_branch ? 50.0 : f_type_min_score(rev)
                bool type_ok = sc >= type_min
                if score_ok and type_ok and bar_index - last_sweep_bar >= sweep_cooldown and sc > sweep_score_out
                    array.set(s_state, i, 1)
                    sweep_short := true
                    sweep_score_out := sc
                    sweep_type_out := rev
                    sweep_pool_src := array.get(s_src, i)
                    sweep_pool_px := mid
                    sweep_path_out := is_grind_branch ? 'GRIND' : 'SPIKE'
                    last_sweep_bar := bar_index
                    last_sweep_dir := "SHORT"
                    last_sweep_lvl := sweep_pool_src
                    last_sweep_score := sc
                    last_sweep_type := sweep_type_out
                    last_sweep_path := sweep_path_out
            else
                array.set(s_pend, i, 1)
                array.set(s_pbar, i, bar_index)
                array.set(s_pbase, i, sc)

        if pend_st == 1 and confirm_window > 0
            int pg = bar_index - array.get(s_pbar, i)
            float base_sc = array.get(s_pbase, i)
            bool disp_ok = pg >= 1 and pg <= confirm_window and close < bot
            bool expired = pg > confirm_window
            bool invalid = close > high[1]

            if disp_ok and (not use_scoring or base_sc >= min_score) and bar_index - last_sweep_bar >= sweep_cooldown
                string rev = f_rev_type(volZ, tr_val > 0 ? upperW / tr_val : 0.0, 70.0, close < open)
                float type_min = f_type_min_score(rev)
                if base_sc >= type_min
                    array.set(s_state, i, 1)
                    sweep_short := true
                    sweep_score_out := base_sc
                    sweep_type_out := rev
                    sweep_pool_src := array.get(s_src, i)
                    sweep_pool_px := mid
                    sweep_path_out := 'SPIKE'
                    last_sweep_bar := bar_index
                    last_sweep_dir := "SHORT"
                    last_sweep_lvl := sweep_pool_src
                    last_sweep_score := base_sc
                    last_sweep_type := sweep_type_out
                    last_sweep_path := sweep_path_out
                    array.set(s_pend, i, 0)
                else
                    array.set(s_pend, i, 0)
            else if expired or invalid
                array.set(s_pend, i, 0)

        if close > top and close[1] > top
            f_del_pool(i, s_mid, s_top, s_bot, s_hits, s_health, s_state, s_birth, s_wt, s_src, s_box, s_line, s_pend, s_pbar, s_pbase, s_touch)

// BUY pools (spike + grind path in v5)
if barstate.isconfirmed and array.size(b_mid) > 0 and session_pass
    for i = array.size(b_mid) - 1 to 0
        if i >= array.size(b_mid)
            continue
        float mid = array.get(b_mid, i)
        float top = array.get(b_top, i)
        float bot = array.get(b_bot, i)
        int st = array.get(b_state, i)
        int age = bar_index - array.get(b_birth, i)

        if st >= 2 or age > pool_max_age
            f_del_pool(i, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch)
            continue

        int last_t = array.get(b_touch, i)
        bool touch_spaced = last_t == -1 or (bar_index - last_t) >= 3
        if low <= top and low >= bot and close > mid and touch_spaced
            array.set(b_hits, i, array.get(b_hits, i) + 1)
            array.set(b_touch, i, bar_index)

        if close >= bot and close <= top
            float cap = vol_sma * 20
            float consumed = cap > 0 ? volume / cap * 5.0 : 0.0
            array.set(b_health, i, math.max(array.get(b_health, i) - consumed, 0.0))

        // SPIKE PATH
        float pen_spike = atr14 > 0 ? math.max(bot - low, 0.0) / atr14 : 0.0
        float reclaim_spike = high > low ? (close - low) / (high - low) * 100.0 : 0.0
        bool sweep_spike = low < bot and close > mid and pen_spike > min_pen_atr and reclaim_spike > 0

        // GRIND PATH (v5 NEW) — was below pool bot in last K bars, now close back inside
        bool sweep_grind_long = false
        float pen_grind = 0.0
        if grind_active and not sweep_spike
            bool was_below = false
            for k = 1 to grind_lookback
                if bar_index >= k and close[k] < bot - atr14 * 0.05
                    was_below := true
                    break
            bool back_inside = close > bot and close < top + atr14 * grind_max_close
            bool body_bull = close > open
            sweep_grind_long := was_below and back_inside and body_bull
            if sweep_grind_long
                pen_grind := atr14 > 0 ? math.max(bot - low, 0.0) / atr14 : 0.0

        bool sweep_raw = sweep_spike or sweep_grind_long
        bool is_grind_branch = sweep_grind_long and not sweep_spike
        float pen_used = is_grind_branch ? pen_grind : pen_spike
        float reclaim_used = is_grind_branch ? math.max(reclaim_spike, 50.0) : reclaim_spike
        int pend_st = array.get(b_pend, i)

        if sweep_raw and st == 0 and pend_st == 0
            bool body_ok = close > open
            float wick_r = tr_val > 0 ? lowerW / tr_val : 0.0
            float vol_r = not na(vol_sma) and vol_sma > 0 ? volume / vol_sma : na
            bool htf_ok = not use_htf or htf_bull
            float mss_d = atr14 > 0 ? math.max(close - mss_hi, 0.0) / atr14 : 0.0
            bool cho_ok = false
            for j = 0 to math.min(5, bar_index - 1)
                if bar_index > j + 1 and m_trend[j+1] <= 0 and m_trend[j] > 0
                    cho_ok := true
                    break

            float sc = f_score_sweep(pen_used, reclaim_used, wick_r, body_ok, array.get(b_hits, i), array.get(b_health, i), array.get(b_wt, i), stretchImp, htf_ok, vol_r, cho_ok, mss_d, chan_pct)
            float age_ratio = f_clamp(float(age) / 25.0, 0.0, 1.0)
            float age_penalty = f_clamp(0.20 + math.pow(age_ratio, 1.6) * 0.80, 0.20, 1.0)
            sc := sc * age_penalty
            // Volume vacuum bonus
            if vac_active
                sc := sc * 1.08
            // Session multiplier applied once inside f_score_sweep — do not apply again here
            bool score_ok = not use_scoring or sc >= min_score

            if confirm_window == 0
                string rev = is_grind_branch ? 'GRIND' : f_rev_type(volZ, wick_r, reclaim_used, body_ok)
                float type_min = is_grind_branch ? 50.0 : f_type_min_score(rev)
                bool type_ok = sc >= type_min
                if score_ok and type_ok and bar_index - last_sweep_bar >= sweep_cooldown and sc > sweep_score_out
                    array.set(b_state, i, 1)
                    sweep_long := true
                    sweep_score_out := sc
                    sweep_type_out := rev
                    sweep_pool_src := array.get(b_src, i)
                    sweep_pool_px := mid
                    sweep_path_out := is_grind_branch ? 'GRIND' : 'SPIKE'
                    last_sweep_bar := bar_index
                    last_sweep_dir := "LONG"
                    last_sweep_lvl := sweep_pool_src
                    last_sweep_score := sc
                    last_sweep_type := sweep_type_out
                    last_sweep_path := sweep_path_out
            else
                array.set(b_pend, i, 1)
                array.set(b_pbar, i, bar_index)
                array.set(b_pbase, i, sc)

        if pend_st == 1 and confirm_window > 0
            int pg = bar_index - array.get(b_pbar, i)
            float base_sc = array.get(b_pbase, i)
            bool disp_ok = pg >= 1 and pg <= confirm_window and close > top
            bool expired = pg > confirm_window
            bool invalid = close < low[1]

            if disp_ok and (not use_scoring or base_sc >= min_score) and bar_index - last_sweep_bar >= sweep_cooldown
                string rev = f_rev_type(volZ, tr_val > 0 ? lowerW / tr_val : 0.0, 70.0, close > open)
                float type_min = f_type_min_score(rev)
                if base_sc >= type_min
                    array.set(b_state, i, 1)
                    sweep_long := true
                    sweep_score_out := base_sc
                    sweep_type_out := rev
                    sweep_pool_src := array.get(b_src, i)
                    sweep_pool_px := mid
                    sweep_path_out := 'SPIKE'
                    last_sweep_bar := bar_index
                    last_sweep_dir := "LONG"
                    last_sweep_lvl := sweep_pool_src
                    last_sweep_score := base_sc
                    last_sweep_type := sweep_type_out
                    last_sweep_path := sweep_path_out
                    array.set(b_pend, i, 0)
                else
                    array.set(b_pend, i, 0)
            else if expired or invalid
                array.set(b_pend, i, 0)

        if close < bot and close[1] < bot
            f_del_pool(i, b_mid, b_top, b_bot, b_hits, b_health, b_state, b_birth, b_wt, b_src, b_box, b_line, b_pend, b_pbar, b_pbase, b_touch)

// ═══════════════════════════════════════════════════════════════════════════
// §7. SFP TRIGGER ENGINE
// ═══════════════════════════════════════════════════════════════════════════

liqBear = (stretchImp > 1.2 and math.max(volZ, 0) > 0.5) or sweep_short
liqBull = (stretchImp < -1.2 and math.max(volZ, 0) > 0.5) or sweep_long
armSC = pr >= (sfp_q_hi * 100.0)
armLC = pr <= (sfp_q_lo * 100.0)

var int aST = 0
var int aLT = 0
var int cS = 0
var int cL = 0
var int ltb = -1

cS := math.max(cS - 1, 0)
cL := math.max(cL - 1, 0)

if armSC and liqBear and aST == 0 and cS == 0
    aST := sfp_ttl
else
    aST := math.max(aST - 1, 0)
if armLC and liqBull and aLT == 0 and cL == 0
    aLT := sfp_ttl
else
    aLT := math.max(aLT - 1, 0)

bool sfp_trig_s = barstate.isconfirmed and use_sfp and aST > 0 and close < mss_lo and (ltb == -1 or bar_index - ltb >= 12) and session_pass
bool sfp_trig_l = barstate.isconfirmed and use_sfp and aLT > 0 and close > mss_hi and (ltb == -1 or bar_index - ltb >= 12) and session_pass

if sfp_trig_s
    ltb := bar_index
    aST := 0
    cS := sfp_cd
if sfp_trig_l
    ltb := bar_index
    aLT := 0
    cL := sfp_cd

// ═══════════════════════════════════════════════════════════════════════════
// §8. POOL VISUALIZATION
// ═══════════════════════════════════════════════════════════════════════════

for i = 0 to math.max(array.size(s_mid) - 1, 0)
    if i >= array.size(s_mid)
        break
    int st = array.get(s_state, i)
    box bx = array.get(s_box, i)
    line ln = array.get(s_line, i)
    if st < 2 and show_pools
        float mid = array.get(s_mid, i)
        float t = array.get(s_top, i)
        float b = array.get(s_bot, i)
        float h = array.get(s_health, i)
        int hits = array.get(s_hits, i)
        string src = array.get(s_src, i)
        int rx = bar_index + 10
        color pc = st == 1 ? sweep_c : bear_c
        bool is_mtf = str.contains(src, '-1H') or str.contains(src, '-4H')
        color bc = is_mtf and st == 0 ? mtf_c : pc
        int alpha = int(math.round(f_clamp(88 - hits * 3, 55, 92)))
        box.set_lefttop(bx, array.get(s_birth, i), t)
        box.set_rightbottom(bx, rx, b)
        box.set_bgcolor(bx, color.new(pc, alpha))
        box.set_border_color(bx, color.new(bc, st == 1 ? 20 : (is_mtf ? 30 : 55)))
        box.set_text(bx, src + ' x' + str.tostring(hits) + '  ' + str.tostring(int(h)) + '%')
        box.set_text_color(bx, color.new(pc, 20))
        line.set_xy1(ln, array.get(s_birth, i), mid)
        line.set_xy2(ln, rx, mid)
        line.set_color(ln, color.new(pc, 40))
    else
        box.set_bgcolor(bx, na)
        box.set_border_color(bx, na)
        box.set_text(bx, '')
        line.set_color(ln, na)

for i = 0 to math.max(array.size(b_mid) - 1, 0)
    if i >= array.size(b_mid)
        break
    int st = array.get(b_state, i)
    box bx = array.get(b_box, i)
    line ln = array.get(b_line, i)
    if st < 2 and show_pools
        float mid = array.get(b_mid, i)
        float t = array.get(b_top, i)
        float b = array.get(b_bot, i)
        float h = array.get(b_health, i)
        int hits = array.get(b_hits, i)
        string src = array.get(b_src, i)
        int rx = bar_index + 10
        color pc = st == 1 ? sweep_c : bull_c
        bool is_mtf = str.contains(src, '-1H') or str.contains(src, '-4H')
        color bc = is_mtf and st == 0 ? mtf_c : pc
        int alpha = int(math.round(f_clamp(88 - hits * 3, 55, 92)))
        box.set_lefttop(bx, array.get(b_birth, i), t)
        box.set_rightbottom(bx, rx, b)
        box.set_bgcolor(bx, color.new(pc, alpha))
        box.set_border_color(bx, color.new(bc, st == 1 ? 20 : (is_mtf ? 30 : 55)))
        box.set_text(bx, src + ' x' + str.tostring(hits) + '  ' + str.tostring(int(h)) + '%')
        box.set_text_color(bx, color.new(pc, 20))
        line.set_xy1(ln, array.get(b_birth, i), mid)
        line.set_xy2(ln, rx, mid)
        line.set_color(ln, color.new(pc, 40))
    else
        box.set_bgcolor(bx, na)
        box.set_border_color(bx, na)
        box.set_text(bx, '')
        line.set_color(ln, na)

// ═══════════════════════════════════════════════════════════════════════════
// §9. SIGNAL LABELS + RISK ZONES
// ═══════════════════════════════════════════════════════════════════════════

if sweep_long
    string path_tag = sweep_path_out == 'GRIND' ? ' (G)' : ''
    string txt = sweep_type_out + path_tag + ' ' + str.tostring(sweep_score_out, '#.0')
    label.new(bar_index, low, txt, style=label.style_label_up, color=color.new(bull_c, 10), textcolor=color.white, size=size.small,
         tooltip='Sweep LONG | Path: ' + sweep_path_out + ' | Type: ' + sweep_type_out + ' | Score: ' + str.tostring(sweep_score_out, '#.1') + '/100 | Pool: ' + sweep_pool_src + ' | Session: ' + cur_session + ' | Regime: ' + regime_str)
if sweep_short
    string path_tag = sweep_path_out == 'GRIND' ? ' (G)' : ''
    string txt = sweep_type_out + path_tag + ' ' + str.tostring(sweep_score_out, '#.0')
    label.new(bar_index, high, txt, style=label.style_label_down, color=color.new(bear_c, 10), textcolor=color.white, size=size.small,
         tooltip='Sweep SHORT | Path: ' + sweep_path_out + ' | Type: ' + sweep_type_out + ' | Score: ' + str.tostring(sweep_score_out, '#.1') + '/100 | Pool: ' + sweep_pool_src + ' | Session: ' + cur_session + ' | Regime: ' + regime_str)

if sfp_trig_l
    label.new(bar_index, low, 'SFP | PR ' + str.tostring(pr, '#.0'), style=label.style_label_up, color=color.new(#00BFFF, 10), textcolor=color.white, size=size.tiny)
if sfp_trig_s
    label.new(bar_index, high, 'SFP | PR ' + str.tostring(pr, '#.0'), style=label.style_label_down, color=color.new(#00BFFF, 10), textcolor=color.white, size=size.tiny)

var box rz = na
var line rz_sl = na
var line rz_t1 = na
var line rz_t2 = na

bool any_l = sweep_long or sfp_trig_l
bool any_s = sweep_short or sfp_trig_s

if show_risk and (any_l or any_s)
    if not na(rz)
        box.delete(rz)
    if not na(rz_sl)
        line.delete(rz_sl)
    if not na(rz_t1)
        line.delete(rz_t1)
    if not na(rz_t2)
        line.delete(rz_t2)

    float e = close
    float sd = atr14 * sl_atr
    int zw = 8
    if any_l
        float sl = low - sd
        float r = e - sl
        float t1 = e + r * tp1_rr
        float t2 = e + r * tp2_rr
        rz    := box.new(bar_index, t2, bar_index + zw, sl, bgcolor=color.new(bull_c, 92), border_color=color.new(bull_c, 60))
        rz_sl := line.new(bar_index, sl, bar_index + zw, sl, color=color.new(bear_c, 30), style=line.style_dashed)
        rz_t1 := line.new(bar_index, t1, bar_index + zw, t1, color=color.new(bull_c, 50), style=line.style_dotted)
        rz_t2 := line.new(bar_index, t2, bar_index + zw, t2, color=color.new(bull_c, 30), style=line.style_dotted)
    else
        float sl = high + sd
        float r = sl - e
        float t1 = e - r * tp1_rr
        float t2 = e - r * tp2_rr
        rz    := box.new(bar_index, sl, bar_index + zw, t2, bgcolor=color.new(bear_c, 92), border_color=color.new(bear_c, 60))
        rz_sl := line.new(bar_index, sl, bar_index + zw, sl, color=color.new(bear_c, 30), style=line.style_dashed)
        rz_t1 := line.new(bar_index, t1, bar_index + zw, t1, color=color.new(bull_c, 50), style=line.style_dotted)
        rz_t2 := line.new(bar_index, t2, bar_index + zw, t2, color=color.new(bull_c, 30), style=line.style_dotted)

// ═══════════════════════════════════════════════════════════════════════════
// §10. PLOTS
// ═══════════════════════════════════════════════════════════════════════════

plot(show_avwap ? impAVWAP : na, 'Impulse AVWAP', color=color.new(color.teal, 0), linewidth=2)
plot(show_avwap and sfp_use_dvwap ? dAVWAP : na, 'Daily AVWAP', color=color.new(color.aqua, 0), linewidth=2, style=plot.style_linebr)

bg_armed = aLT > 0 ? color.new(bull_c, 92) : aST > 0 ? color.new(bear_c, 92) : na
bgcolor(show_armed_bg ? bg_armed : na)

plotshape(sfp_trig_s, 'SFP ↓', style=shape.triangledown, location=location.abovebar, color=bear_c, size=size.small)
plotshape(sfp_trig_l, 'SFP ↑', style=shape.triangleup,   location=location.belowbar, color=bull_c, size=size.small)

// ── BUY / SELL sweep arrows (v6 final) ──────────────────────────────────────
// sweep_long / sweep_short are only true on barstate.isconfirmed bars (§6 gate)
// Spike path = large arrow, Grind path = small arrow to differentiate visually
plotshape(sweep_long  and sweep_path_out == 'SPIKE', 'BUY ▲ Spike', style=shape.arrowup,      location=location.belowbar, color=bull_c, size=size.normal)
plotshape(sweep_long  and sweep_path_out == 'GRIND', 'BUY ▲ Grind', style=shape.arrowup,      location=location.belowbar, color=color.new(bull_c, 40), size=size.small)
plotshape(sweep_short and sweep_path_out == 'SPIKE', 'SELL ▼ Spike', style=shape.arrowdown,   location=location.abovebar, color=bear_c, size=size.normal)
plotshape(sweep_short and sweep_path_out == 'GRIND', 'SELL ▼ Grind', style=shape.arrowdown,   location=location.abovebar, color=color.new(bear_c, 40), size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// §11. DASHBOARD (extended in v5)
// ═══════════════════════════════════════════════════════════════════════════

var table dash = table.new(position.bottom_right, 2, 19, border_width=1, bgcolor=color.new(#0f172a, 8))

if show_dash and barstate.islast
    color ok_c = color.new(#69F0AE, 0)
    color no_c = color.new(#FF5252, 0)
    color hd_c = color.new(#0b1220, 0)
    color bg_c = color.new(color.gray, 30)
    color wh   = color.white
    color v6_c = color.new(#a855f7, 0)

    int s_act = 0
    int b_act = 0
    int s_mtf = 0
    int b_mtf = 0
    for i = 0 to math.max(array.size(s_state) - 1, 0)
        if i < array.size(s_state) and array.get(s_state, i) < 2
            s_act += 1
            string sr = array.get(s_src, i)
            if str.contains(sr, '-1H') or str.contains(sr, '-4H')
                s_mtf += 1
    for i = 0 to math.max(array.size(b_state) - 1, 0)
        if i < array.size(b_state) and array.get(b_state, i) < 2
            b_act += 1
            string sr = array.get(b_src, i)
            if str.contains(sr, '-1H') or str.contains(sr, '-4H')
                b_mtf += 1

    table.cell(dash, 0, 0, 'LGD v6', text_color=v6_c, text_size=size.small, bgcolor=hd_c)
    table.cell(dash, 1, 0, syminfo.ticker + ' | ' + timeframe.period, text_color=wh, text_size=size.small, bgcolor=hd_c)

    table.cell(dash, 0, 1, 'Sell Pools', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 1, str.tostring(s_act) + ' (MTF: ' + str.tostring(s_mtf) + ')', text_color=color.new(bear_c, 0), text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 0, 2, 'Buy Pools', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 2, str.tostring(b_act) + ' (MTF: ' + str.tostring(b_mtf) + ')', text_color=color.new(bull_c, 0), text_size=size.tiny, bgcolor=bg_c)

    string ch_txt = na(chan_pct) ? 'Outside' : str.tostring(chan_pct, '#.0') + '%'
    color ch_clr = na(chan_pct) ? color.gray : chan_pct > 70 ? no_c : chan_pct < 30 ? ok_c : color.new(#f59e0b, 0)
    table.cell(dash, 0, 3, 'Channel', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 3, ch_txt, text_color=ch_clr, text_size=size.tiny, bgcolor=bg_c)

    // v5 sections
    table.cell(dash, 0, 4, '── v6 CONTEXT ──', text_color=v6_c, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 4, '', text_color=wh, text_size=size.tiny, bgcolor=bg_c)

    string sess_txt = cur_session + ' (' + str.tostring(session_w, '#.0#') + 'x)'
    color sess_clr = session_w >= 1.0 ? ok_c : session_w >= 0.8 ? color.new(#f59e0b, 0) : no_c
    table.cell(dash, 0, 5, 'Session', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 5, sess_txt, text_color=sess_clr, text_size=size.tiny, bgcolor=bg_c)

    string reg_txt = regime_str + (use_regime ? ' (ADX ' + str.tostring(adx_v, '#.0') + ')' : '')
    color reg_clr = is_trend ? ok_c : is_coil ? color.new(#f59e0b, 0) : is_range ? color.new(#00BFFF, 0) : color.gray
    table.cell(dash, 0, 6, 'Regime', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 6, reg_txt, text_color=reg_clr, text_size=size.tiny, bgcolor=bg_c)

    string cal_txt = use_auto_cal ? 'WB:' + str.tostring(cal_wb_ratio, '#.0#') + ' CV:' + str.tostring(cal_vol_cv, '#.0#') + ' ATR:' + str.tostring(cal_atr_mean * 100, '#') + '%' : 'OFF'
    table.cell(dash, 0, 7, 'Auto-Cal', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 7, cal_txt, text_color=wh, text_size=size.tiny, bgcolor=bg_c)

    string grind_txt = grind_active ? 'ON' + (auto_grind_recommended ? ' (R)' : '') : 'OFF' + (auto_grind_recommended ? ' (rec ON)' : '')
    color grind_clr = grind_active ? ok_c : color.gray
    table.cell(dash, 0, 8, 'Grind Path', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 8, grind_txt, text_color=grind_clr, text_size=size.tiny, bgcolor=bg_c)

    // Last sweep
    table.cell(dash, 0, 9, '── LAST SWEEP ──', text_color=color.new(wh, 40), text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 9, '', text_color=wh, text_size=size.tiny, bgcolor=bg_c)

    string ls_txt = last_sweep_dir != "" ? last_sweep_type + (last_sweep_path == 'GRIND' ? '/G ' : ' ') + str.tostring(last_sweep_score, '#.0') : '—'
    color ls_clr = last_sweep_dir == "LONG" ? ok_c : last_sweep_dir == "SHORT" ? no_c : color.gray
    table.cell(dash, 0, 10, 'Signal', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 10, ls_txt, text_color=ls_clr, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 0, 11, 'Pool/Path', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 11, last_sweep_lvl != "" ? last_sweep_lvl + ' / ' + last_sweep_path : '—', text_color=wh, text_size=size.tiny, bgcolor=bg_c)

    // SFP
    table.cell(dash, 0, 12, '── SFP ENGINE ──', text_color=color.new(#00BFFF, 40), text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 12, '', text_color=wh, text_size=size.tiny, bgcolor=bg_c)

    string arm_txt = aLT > 0 ? 'ARMED ↑ (' + str.tostring(aLT) + ')' : aST > 0 ? 'ARMED ↓ (' + str.tostring(aST) + ')' : 'Idle'
    color arm_c = aLT > 0 ? color.new(bull_c, 70) : aST > 0 ? color.new(bear_c, 70) : bg_c
    table.cell(dash, 0, 13, 'State', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 13, arm_txt, text_color=wh, text_size=size.tiny, bgcolor=arm_c)

    table.cell(dash, 0, 14, 'PR', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 14, str.tostring(pr, '#.0'), text_color=pr <= 10 ? ok_c : pr >= 90 ? no_c : wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 0, 15, 'Stretch', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 15, str.tostring(stretchImp, '#.00'), text_color=wh, text_size=size.tiny, bgcolor=bg_c)

    // Session pass status
    table.cell(dash, 0, 16, 'Sess Gate', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    color sg_clr = session_pass ? ok_c : no_c
    string sg_txt = session_pass ? 'PASS' : 'BLOCK'
    table.cell(dash, 1, 16, sg_txt, text_color=sg_clr, text_size=size.tiny, bgcolor=bg_c)

    // Vacuum status (v6)
    string vac_txt = vac_active ? 'ACTIVE (' + str.tostring(vac_count) + ' bars)' : 'NO'
    color vac_clr = vac_active ? color.new(#FFF176, 0) : color.gray
    table.cell(dash, 0, 17, 'Vacuum', text_color=wh, text_size=size.tiny, bgcolor=bg_c)
    table.cell(dash, 1, 17, vac_txt, text_color=vac_clr, text_size=size.tiny, bgcolor=bg_c)

    string stat_txt = (sweep_long or sfp_trig_l) ? 'LONG ✓' : (sweep_short or sfp_trig_s) ? 'SHORT ✓' : 'SCANNING'
    color stat_c = (sweep_long or sfp_trig_l) ? ok_c : (sweep_short or sfp_trig_s) ? no_c : color.new(wh, 40)
    table.cell(dash, 0, 18, 'STATUS', text_color=wh, text_size=size.small, bgcolor=hd_c)
    table.cell(dash, 1, 18, stat_txt, text_color=stat_c, text_size=size.small, bgcolor=hd_c)

// ═══════════════════════════════════════════════════════════════════════════
// §12. ALERTS (extended JSON payload — v6)
// ═══════════════════════════════════════════════════════════════════════════

f_json_sweep_v6(string dir, string rev, float sc, string pool, string path) =>
    '{"type":"sweep","version":"v6","reversal":"' + rev + '","path":"' + path +
     '","dir":"' + dir +
     '","score":' + str.tostring(sc, '#.0') +
     ',"pool":"' + pool +
     '","stretch":' + str.tostring(stretchImp, '#.00') +
     ',"pr":' + str.tostring(pr, '#.0') +
     ',"regime":"' + regime_str +
     '","session":"' + cur_session +
     '","session_w":' + str.tostring(session_w, '#.00') +
     ',"vacuum":' + (vac_active ? 'true' : 'false') +
     ',"price":' + str.tostring(math.round_to_mintick(close)) +
     ',"ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '"}'

if sweep_long
    alert(f_json_sweep_v6('LONG', sweep_type_out, sweep_score_out, sweep_pool_src, sweep_path_out), alert.freq_once_per_bar_close)
if sweep_short
    alert(f_json_sweep_v6('SHORT', sweep_type_out, sweep_score_out, sweep_pool_src, sweep_path_out), alert.freq_once_per_bar_close)
if sfp_trig_l
    alert('{"type":"sfp","version":"v6","dir":"LONG","pr":' + str.tostring(pr, '#.0') + ',"regime":"' + regime_str + '","session":"' + cur_session + '","price":' + str.tostring(math.round_to_mintick(close)) + ',"ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '"}', alert.freq_once_per_bar_close)
if sfp_trig_s
    alert('{"type":"sfp","version":"v6","dir":"SHORT","pr":' + str.tostring(pr, '#.0') + ',"regime":"' + regime_str + '","session":"' + cur_session + '","price":' + str.tostring(math.round_to_mintick(close)) + ',"ticker":"' + syminfo.ticker + '","tf":"' + timeframe.period + '"}', alert.freq_once_per_bar_close)

alertcondition(sweep_long,                'Sweep LONG',  'Sweep LONG — {{ticker}} {{interval}} @ {{close}}')
alertcondition(sweep_short,               'Sweep SHORT', 'Sweep SHORT — {{ticker}} {{interval}} @ {{close}}')
alertcondition(sfp_trig_l,                'SFP LONG',    'SFP Trigger LONG — {{ticker}} {{interval}} @ {{close}}')
alertcondition(sfp_trig_s,                'SFP SHORT',   'SFP Trigger SHORT — {{ticker}} {{interval}} @ {{close}}')
alertcondition(sweep_long or sfp_trig_l,  'Any LONG',    'Signal LONG — {{ticker}} {{interval}} @ {{close}}')
alertcondition(sweep_short or sfp_trig_s, 'Any SHORT',   'Signal SHORT — {{ticker}} {{interval}} @ {{close}}')
````
