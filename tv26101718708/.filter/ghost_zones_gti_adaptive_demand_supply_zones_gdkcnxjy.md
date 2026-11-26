# Ghost Zones GTI - Adaptive Demand & Supply Zones

- url: https://www.tradingview.com/script/gDKcNXjY-Ghost-Zones-GTI-Adaptive-Demand-Supply-Zones/
- type: indicator
- pine_id: PUB;7d099b238c1a46ba970c4d4fdbb93ab1
- version: 12.0

## Description

────────────────────

Adaptive Demand & Supply Zones (ADSZ)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Automatically plots dynamic demand and supply zones on daily and weekly timeframes. Unlike static support/resistance levels, these zones adapt in real-time to market volatility using ATR (Average True Range) — expanding during volatile markets and contracting during calm periods.

Works universally on any instrument: Stocks, Indices, Crypto, Commodities, and Forex.

🔍 HOW IT WORKS

The indicator computes Effective Volatility from the annualized ATR percentage, then derives statistically-grounded zone levels:

● Strong Zones (Demand & Supply) — placed at ±1σ from the session open. These represent high-probability reversal areas where price is statistically likely to find strong support or resistance.

● Weak Zones — placed closer to the open at ±σ/(2√2). These act as early warning levels — initial reaction zones where price may pause or consolidate before continuing.

● Zone Width — scales proportionally with volatility using the golden ratio (φ = 1.618). Strong zones are wider than weak zones, reflecting higher conviction at extreme levels.

● Weekly Point of Control (WPOC) — a key weekly pivot level anchored to Monday's open.

The Math:

Effective Volatility = ATR Slope × Annualized ATR%
σ (sigma) = Price × EffVol / (100 × √252)
Strong zones: Open ± σ
Weak zones:   Open ± σ/(2√2)
Strong width: σ/4
Weak width:   σ/(4×φ)

📊 ZONE GUIDE

🟢 Strong Demand (Green) — High-probability buy zone, price stretched to the downside
🟩 Weak Demand (Lime) — Early demand area, potential bounce or consolidation
🟧 Weak Supply (Orange) — Early supply area, potential rejection or consolidation
🔴 Strong Supply (Red) — High-probability sell zone, price stretched to the upside
🟡 WPOC (Gold) — Weekly Point of Control, key weekly pivot

⚙️ SETTINGS

Daily Parameters: • Daily ATR Period (default: 20) — ATR lookback on daily bars (~1 trading month) • Daily ATR Slope (default: 0.69) — Multiplier for zone width. Higher = wider zones • Daily Intercept (default: 0.0) — Keep at 0 for best cross-regime stability

Weekly Parameters: • Weekly ATR Period (default: 5) — ATR lookback on weekly bars (~1 trading month) • Weekly ATR Slope (default: 0.68) — Multiplier for zone width. Higher = wider zones • Weekly Intercept (default: 0.0) — Keep at 0 for best cross-regime stability

💡 HOW TO USE

1. Intraday Trading — Use daily zones as key levels for entries, exits, and stop-loss placement. Strong zones offer the highest probability reversals.
2. Swing Trading — Combine daily and weekly zones. When a daily strong demand aligns with weekly demand, it creates a confluence zone — very high probability entry.
3. Risk Management — Zone boundaries provide natural stop-loss levels. Place stops just beyond the strong zone boundary.
4. Volatility Awareness — Watch how zones expand and contract. Wider zones signal higher expected moves — adjust position sizing accordingly.
5. WPOC — Price above WPOC suggests bullish bias, below suggests bearish.

🔧 TUNING FOR DIFFERENT INSTRUMENTS

Defaults optimized for Indian indices (Nifty 50). For other instruments: • Higher slope (0.72–0.80) → more volatile (small-caps, crypto) • Lower slope (0.60–0.68) → less volatile (large-cap US stocks, bonds)

✅ KEY FEATURES

● Universal — works on any instrument, no external data dependencies
● Adaptive — zones auto-scale with market volatility via ATR
● Dual Timeframe — daily and weekly zones plotted simultaneously
● Statistically Grounded — annualized volatility + golden ratio geometry
● Fully Customizable — all parameters adjustable in settings
● Clean Display — toggle individual components on/off

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tip: For the cleanest chart, use on 5min or 15min timeframes with daily zones enabled, and use on 1-hr timeframe with weekly zones enabled

────────────────────

## Source Code

````pine
//@version=6
indicator(title="Adaptive Demand & Supply Zones", shorttitle="ADSZ", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

// ══════════════════════════════════════════════════════════════════════════════
// Adaptive Demand & Supply Zones (ADSZ)
//
// ATR-based volatility zones that work universally on any asset and timeframe.
// Plots demand/supply zones across 6 timeframes (4H, Daily, Weekly, Monthly,
// Quarterly, Half-Yearly) using statistical volatility derived from Average
// True Range. Zones auto-adapt — wider during high volatility, tighter during
// calm periods.
//
// Core formula:
//   • Effective Volatility = ATR Slope × Annualized ATR%
//   • Zone spread (σ) simplifies to: σ = Slope × ATR
//   • Strong zones at ±1σ from open, Weak zones at ±σ/2.83 (or σ/2.77)
//   • 2-layer display system — pick any 2 timeframes for confluence
//   • Independent POC toggles for each layer + standalone Weekly POC
//   • Zone entry alerts for all 6 timeframes (34 alert conditions)
//
// ICT Order Flow Tools (adapted from ICT Suite by LuxAlgo, © MPL 2.0):
//   • Volume Spikes — statistical anomaly detection with graduated bubbles
//   • Liquidity Zones — EQH/EQL detection with sweep tracking
//   • Market Structure — BOS/CHoCH pivot-based trend identification
//   • Fair Value Gaps — ATR-filtered imbalance zones
//   • HTF Projected Candles — higher-timeframe candle projection
//
// Works on: Stocks, Indices, Crypto, Commodities, Forex
//
// NOTE: If quarterly or half-yearly zones appear different on lower-timeframe
// charts (e.g., 4H) with multi-panel layouts, switch from "Extended Trading
// Hours" to "Regular Trading Hours" in chart settings. Extended hours load
// extra bars per day, reducing historical depth for higher-timeframe ATR.
// ══════════════════════════════════════════════════════════════════════════════

// ── INPUTS ───────────────────────────────────────────────────────────────────

// Daily parameters
int d_atr_period = input.int(20, title="Daily ATR Period", minval=5, maxval=50,
     tooltip="ATR lookback on daily bars. Default 20 (≈1 trading month).")
float d_slope = input.float(0.69, title="Daily ATR Slope", step=0.01,
     tooltip="Multiplier for daily annualized ATR%. Higher = wider zones.")
float d_intercept = input.float(0.0, title="Daily Intercept", step=0.01,
     tooltip="Additive offset for daily Effective Volatility. Keep at 0 for best stability across all volatility regimes.")

// Weekly parameters
int w_atr_period = input.int(5, title="Weekly ATR Period", minval=2, maxval=20,
     tooltip="ATR lookback on weekly bars. Default 5 (≈1 trading month).")
float w_slope = input.float(0.68, title="Weekly ATR Slope", step=0.01,
     tooltip="Multiplier for weekly annualized ATR%. Higher = wider zones.")
float w_intercept = input.float(0.0, title="Weekly Intercept", step=0.01,
     tooltip="Additive offset for weekly Effective Volatility. Keep at 0 for best stability across all volatility regimes.")

// Monthly parameters
int m_atr_period = input.int(20, title="Monthly ATR Period", minval=1, maxval=60,
     tooltip="ATR lookback on monthly bars. Default 20 (~5 years). Longer periods provide smoother zones across volatility regimes.")
float m_slope = input.float(0.90, title="Monthly ATR Slope", step=0.01,
     tooltip="Multiplier for monthly annualized ATR%. Higher = wider zones.")
float m_intercept = input.float(0.0, title="Monthly Intercept", step=0.01,
     tooltip="Additive offset for monthly Effective Volatility. Keep at 0 for best stability.")

// 4H parameters
int h4_atr_period = input.int(20, title="4H ATR Period", minval=5, maxval=50,
     tooltip="ATR lookback on 4-hour bars. Default 20.")
float h4_slope = input.float(0.92, title="4H ATR Slope", step=0.01,
     tooltip="Multiplier for 4H annualized ATR%. Default 0.92 (sigma ≈ 0.92 × ATR).")

// Quarterly parameters
int q_atr_period = input.int(20, title="Quarterly ATR Period", minval=1, maxval=30,
     tooltip="ATR lookback on quarterly (3M) bars. Default 20 (~5 years). Longer periods provide smoother zones across quarters.")
float q_slope = input.float(0.89, title="Quarterly ATR Slope", step=0.01,
     tooltip="Multiplier for quarterly annualized ATR%. Adjust to fit zone width.")

// Half-Yearly parameters
int hy_atr_period = input.int(20, title="Half-Yearly ATR Period", minval=1, maxval=30,
     tooltip="ATR lookback on half-yearly (6M) bars. Default 20 (~10 years).")
float hy_slope = input.float(0.88, title="Half-Yearly ATR Slope", step=0.01,
     tooltip="Multiplier for half-yearly annualized ATR%. Adjust to fit zone width.")

// Display — two selectable zone layers for confluence analysis
string layer1_tf = input.string("Daily",   title="Zone Layer 1", options=["None", "4H", "Daily", "Weekly", "Monthly", "Quarterly", "Half-Yearly"],
     tooltip="Primary zone timeframe. Set to None to hide.")
string layer2_tf = input.string("None",  title="Zone Layer 2", options=["None", "4H", "Daily", "Weekly", "Monthly", "Quarterly", "Half-Yearly"],
     tooltip="Secondary zone timeframe for confluence. Set to None to hide.")
bool show_l1_zones = input.bool(true, title="Show Layer 1 Zones")
bool show_l2_zones = input.bool(true, title="Show Layer 2 Zones")
bool show_l1_poc  = input.bool(true,  title="Show Layer 1 POC")
bool show_l2_poc  = input.bool(true,  title="Show Layer 2 POC")
bool show_wpoc    = input.bool(true,  title="Show Weekly POC")
bool show_labels  = input.bool(true,  title="Show Zone Labels")

// ─── Volume Spikes ────────────────────────────────────────────────────────────
grp_spk = "── Volume Spikes ──"
bool   showSpikes   = input.bool(true,   "Show Volume Spike Bubbles", group=grp_spk)
float  spikeThresh  = input.float(3.0,   "Spike Threshold (Std Dev)", step=0.5, group=grp_spk,
     tooltip="Minimum standard deviations above average volume to trigger a spike bubble.")

// ─── Liquidity Zones (EQH/EQL) ───────────────────────────────────────────────
grp_liq = "── Liquidity Zones (EQH/EQL) ──"
bool   showLiqZones    = input.bool(true,   "Show Liquidity Zones",     group=grp_liq)
int    liqLeftLen      = input.int(10,      "Pivot Left Length",  minval=1, group=grp_liq,
     tooltip="Bars to the left required to confirm a pivot high/low.")
int    liqRightLen     = input.int(2,       "Pivot Right Length", minval=1, group=grp_liq,
     tooltip="Bars to the right required to confirm a pivot high/low.")
float  liqThreshPct    = input.float(0.03,  "Equality Threshold (%)", minval=0, step=0.01, group=grp_liq,
     tooltip="Max % difference to consider two highs/lows equal (EQH/EQL).")
int    liqMaxZones     = input.int(60,      "Max Active Zones", minval=1, maxval=100, group=grp_liq)
color  liqBullColor    = input.color(#089981, "Bullish Zone Color",  group=grp_liq)
color  liqBearColor    = input.color(#f23645, "Bearish Zone Color",  group=grp_liq)
int    liqTransp       = input.int(85,      "Zone Transparency", minval=0, maxval=100, group=grp_liq)
bool   liqMidline      = input.bool(false,  "Show Midline",          group=grp_liq)
color  liqMidCol       = input.color(#787b86, "Midline Color",       group=grp_liq)
bool   liqShowVol      = input.bool(true,   "Show Volume on Zones",  group=grp_liq)
bool   liqDeleteOnSweep = input.bool(false, "Delete Zone on Sweep",  group=grp_liq,
     tooltip="When off, swept zones turn grey. When on, they are removed entirely.")

// ─── Market Structure (BOS/CHoCH) ────────────────────────────────────────────
grp_ms = "── Market Structure ──"
bool   showMs     = input.bool(true,   "Show Market Structure", group=grp_ms)
int    msSens     = input.int(5,       "Pivot Sensitivity", minval=1, group=grp_ms,
     tooltip="Number of bars on each side required to confirm a structural pivot.")
color  bullMsCss  = input.color(#089981, "Bullish Structure Color", group=grp_ms)
color  bearMsCss  = input.color(#f23645, "Bearish Structure Color", group=grp_ms)

// ─── Fair Value Gaps ──────────────────────────────────────────────────────────
grp_fvg = "── Fair Value Gaps ──"
bool   showFvg    = input.bool(false,  "Show FVGs", group=grp_fvg)
float  fvgSens    = input.float(0.5,   "Volatility Sensitivity", minval=0, step=0.1, group=grp_fvg,
     tooltip="Minimum FVG size relative to ATR. Higher = only show larger gaps.")
int    fvgExtend  = input.int(5,       "Extend Bars", minval=1, maxval=20, group=grp_fvg)
color  bullFvgCss = input.color(color.new(#089981, 70), "Bullish FVG Color", group=grp_fvg)
color  bearFvgCss = input.color(color.new(#f23645, 70), "Bearish FVG Color", group=grp_fvg)

// ─── HTF Projected Candles ────────────────────────────────────────────────────
grp_htf = "── HTF Projected Candles ──"
bool   showHtf       = input.bool(true,   "Show HTF Projected Candles", group=grp_htf)
string htfInput      = input.timeframe("D", "HTF Timeframe",            group=grp_htf,
     tooltip="The higher timeframe whose candles are projected to the right of current price.")
int    htfCount      = input.int(1,  "Number of Candles", minval=1, maxval=5, group=grp_htf)
int    htfOffset     = input.int(5,  "Projection Offset", minval=1, maxval=50, group=grp_htf,
     tooltip="Distance (in bars) of the first projected candle from the current bar.")
int    htfHistOpacity = input.int(40, "Historical Candle Opacity", minval=0, maxval=100, group=grp_htf)
color  openLineCss   = input.color(#5b9cf6, "Open Price Line Color", group=grp_htf)
bool   showHtfLines  = input.bool(true,   "Show Open Price Line",    group=grp_htf)

// ── CONSTANTS ────────────────────────────────────────────────────────────────

float phi     = 1.618034
float sqrt2   = math.sqrt(2)
float sqrt252 = math.sqrt(252)

// Ensure deep historical references work for liquidity/HTF features
max_bars_back(time,   5000)
max_bars_back(open,   5000)
max_bars_back(high,   5000)
max_bars_back(low,    5000)
max_bars_back(close,  5000)
max_bars_back(volume, 5000)

// ── HELPER FUNCTIONS ─────────────────────────────────────────────────────────
// Map a layer's timeframe selection to the correct zone value
f_z(string tf, float v4h, float vd, float vw, float vm, float vq, float vhy) =>
    tf == "None" ? na : tf == "4H" ? v4h : tf == "Daily" ? vd : tf == "Weekly" ? vw : tf == "Monthly" ? vm : tf == "Quarterly" ? vq : vhy

// f_c removed — inline ternaries used instead to avoid series-type promotion from function returns
// (PineScript functions promote return types to series, which doubles plot counts for colors)

// ── DAILY ZONES ──────────────────────────────────────────────────────────────

[day_open, day_atr, day_close_prev, day_high_prev, day_low_prev] = request.security(syminfo.tickerid, "D", [open, ta.atr(d_atr_period)[1], close[1], high[1], low[1]], lookahead=barmerge.lookahead_on)

// Effective Volatility from annualized ATR%
float atr_ann_pct = day_atr / day_close_prev * sqrt252 * 100
// float atr_ann_pct = day_atr / day_open * sqrt252 * 100          // ← Gap fix: uncomment this, comment line above
float effvol      = d_slope * atr_ann_pct + d_intercept

// Zone geometry
float P          = math.round(day_open)
float sigma      = P * effvol / (100.0 * sqrt252)
float dist_strong = sigma
float dist_weak   = sigma / (2.0 * sqrt2)
float ws          = math.round(sigma / 4.0)
float ww          = math.round(sigma / (4.0 * phi))

// Daily zone boundaries
float sd_low   = math.round(P - dist_strong - ws / 2)
float sd_high  = math.round(P - dist_strong + ws / 2)
float wd_low   = math.round(P - dist_weak   - ww / 2)
float wd_high  = math.round(P - dist_weak   + ww / 2)
float wsp_low  = math.round(P + dist_weak   - ww / 2)
float wsp_high = math.round(P + dist_weak   + ww / 2)
float ss_low   = math.round(P + dist_strong - ws / 2)
float ss_high  = math.round(P + dist_strong + ws / 2)

// Daily POC = CPR Central Pivot of previous day
float dpoc = math.round((day_high_prev + day_low_prev + day_close_prev) / 3)

// ── WEEKLY ZONES ─────────────────────────────────────────────────────────────

[week_open, w_atr_weekly, w_close_prev] = request.security(syminfo.tickerid, "W", [open, ta.atr(w_atr_period)[1], close[1]], lookahead=barmerge.lookahead_on)

// Weekly Effective Volatility
float w_atr_ann_pct = w_atr_weekly / w_close_prev * math.sqrt(52) * 100
// float w_atr_ann_pct = w_atr_weekly / week_open * math.sqrt(52) * 100  // ← Gap fix: uncomment this, comment line above

var float effvol_w = na
bool new_week = ta.change(time("W")) != 0
if new_week
    effvol_w := w_slope * w_atr_ann_pct + w_intercept
if na(effvol_w)
    effvol_w := w_slope * w_atr_ann_pct + w_intercept

float P_w          = math.round(week_open)
float sigma_w      = P_w * effvol_w / (100.0 * math.sqrt(252.0 / 5.0))
float dist_strong_w = sigma_w
float dist_weak_w   = sigma_w / (2.0 * sqrt2)
float ws_w          = math.round(sigma_w / 4.0)
float ww_w          = math.round(sigma_w / (4.0 * phi))

// Weekly zone boundaries
float wsd_low  = math.round(P_w - dist_strong_w - ws_w / 2)
float wsd_high = math.round(P_w - dist_strong_w + ws_w / 2)
float wwd_low  = math.round(P_w - dist_weak_w   - ww_w / 2)
float wwd_high = math.round(P_w - dist_weak_w   + ww_w / 2)
float wws_low  = math.round(P_w + dist_weak_w   - ww_w / 2)
float wws_high = math.round(P_w + dist_weak_w   + ww_w / 2)
float wss_low  = math.round(P_w + dist_strong_w - ws_w / 2)
float wss_high = math.round(P_w + dist_strong_w + ws_w / 2)
float wpoc     = P_w + 8

// ── MONTHLY ZONES ────────────────────────────────────────────────────────────

[month_open, m_atr_monthly, m_close_prev, m_high_prev, m_low_prev] = request.security(syminfo.tickerid, "M", [open, ta.atr(m_atr_period)[1], close[1], high[1], low[1]], lookahead=barmerge.lookahead_on)

// Monthly Effective Volatility
float m_atr_ann_pct = m_atr_monthly / month_open * math.sqrt(12) * 100

var float effvol_m = na
bool new_month = ta.change(time("M")) != 0
if new_month
    effvol_m := m_slope * m_atr_ann_pct + m_intercept
if na(effvol_m)
    effvol_m := m_slope * m_atr_ann_pct + m_intercept

float P_m           = math.round(month_open)
float sigma_m       = P_m * effvol_m / (100.0 * math.sqrt(12.0))
float dist_strong_m = sigma_m
float dist_weak_m   = sigma_m / 2.77
float ws_m          = math.round(sigma_m / 4.35)
float ww_m          = math.round(sigma_m / 5.1)

// Monthly zone boundaries
float msd_low  = math.round(P_m - dist_strong_m - ws_m / 2)
float msd_high = math.round(P_m - dist_strong_m + ws_m / 2)
float mwd_low  = math.round(P_m - dist_weak_m   - ww_m / 2)
float mwd_high = math.round(P_m - dist_weak_m   + ww_m / 2)
float mws_low  = math.round(P_m + dist_weak_m   - ww_m / 2)
float mws_high = math.round(P_m + dist_weak_m   + ww_m / 2)
float mss_low  = math.round(P_m + dist_strong_m - ws_m / 2)
float mss_high = math.round(P_m + dist_strong_m + ws_m / 2)

// Monthly POC = Standard Pivot of previous month
float mpoc = math.round((m_high_prev + m_low_prev + m_close_prev) / 3)

// ── QUARTERLY ZONES ──────────────────────────────────────────────────────────

[q_open, q_atr_val, q_close_prev, q_high_prev, q_low_prev] = request.security(syminfo.tickerid, "3M", [open, ta.atr(q_atr_period)[1], close[1], high[1], low[1]], lookahead=barmerge.lookahead_on)

// Quarterly Effective Volatility (normalize by q_open to handle gaps)
float q_atr_ann_pct = q_atr_val / q_open * math.sqrt(4) * 100

var float effvol_q = na
bool new_quarter = ta.change(time("3M")) != 0
if new_quarter
    effvol_q := q_slope * q_atr_ann_pct
if na(effvol_q)
    effvol_q := q_slope * q_atr_ann_pct

float P_q           = math.round(q_open)
float sigma_q       = P_q * effvol_q / (100.0 * math.sqrt(4.0))
float dist_strong_q = sigma_q
float dist_weak_q   = sigma_q / 2.77
float ws_q          = math.round(sigma_q / 4.35)
float ww_q          = math.round(sigma_q / 5.1)

// Quarterly zone boundaries
float qsd_low  = math.round(P_q - dist_strong_q - ws_q / 2)
float qsd_high = math.round(P_q - dist_strong_q + ws_q / 2)
float qwd_low  = math.round(P_q - dist_weak_q   - ww_q / 2)
float qwd_high = math.round(P_q - dist_weak_q   + ww_q / 2)
float qws_low  = math.round(P_q + dist_weak_q   - ww_q / 2)
float qws_high = math.round(P_q + dist_weak_q   + ww_q / 2)
float qss_low  = math.round(P_q + dist_strong_q - ws_q / 2)
float qss_high = math.round(P_q + dist_strong_q + ws_q / 2)

// Quarterly POC = Standard Pivot of previous quarter
float qpoc = math.round((q_high_prev + q_low_prev + q_close_prev) / 3)

// ── HALF-YEARLY ZONES ────────────────────────────────────────────────────────

[hy_open, hy_atr_val, hy_close_prev, hy_high_prev, hy_low_prev] = request.security(syminfo.tickerid, "6M", [open, ta.atr(hy_atr_period)[1], close[1], high[1], low[1]], lookahead=barmerge.lookahead_on)

// Half-Yearly Effective Volatility (normalize by hy_open to handle gaps)
float hy_atr_ann_pct = hy_atr_val / hy_open * math.sqrt(2) * 100

var float effvol_hy = na
bool new_half = ta.change(time("6M")) != 0
if new_half
    effvol_hy := hy_slope * hy_atr_ann_pct
if na(effvol_hy)
    effvol_hy := hy_slope * hy_atr_ann_pct

float P_hy           = math.round(hy_open)
float sigma_hy       = P_hy * effvol_hy / (100.0 * math.sqrt(2.0))
float dist_strong_hy = sigma_hy
float dist_weak_hy   = sigma_hy / 2.77
float ws_hy          = math.round(sigma_hy / 4.35)
float ww_hy          = math.round(sigma_hy / 5.1)

// Half-Yearly zone boundaries
float hysd_low  = math.round(P_hy - dist_strong_hy - ws_hy / 2)
float hysd_high = math.round(P_hy - dist_strong_hy + ws_hy / 2)
float hywd_low  = math.round(P_hy - dist_weak_hy   - ww_hy / 2)
float hywd_high = math.round(P_hy - dist_weak_hy   + ww_hy / 2)
float hyws_low  = math.round(P_hy + dist_weak_hy   - ww_hy / 2)
float hyws_high = math.round(P_hy + dist_weak_hy   + ww_hy / 2)
float hyss_low  = math.round(P_hy + dist_strong_hy - ws_hy / 2)
float hyss_high = math.round(P_hy + dist_strong_hy + ws_hy / 2)

// Half-Yearly POC = Standard Pivot of previous half-year
float hypoc = math.round((hy_high_prev + hy_low_prev + hy_close_prev) / 3)

// ── 4H ZONES ─────────────────────────────────────────────────────────────────

[h4_open, h4_atr, h4_close_prev, h4_high_prev, h4_low_prev, h4_high_prev2, h4_low_prev2, h4_close_prev2] = request.security(syminfo.tickerid, "240", [open, ta.atr(h4_atr_period)[1], close[1], high[1], low[1], high[2], low[2], close[2]], lookahead=barmerge.lookahead_on)

// 4H Effective Volatility (normalize by h4_open to handle overnight gaps)
float h4_atr_ann_pct = h4_atr / h4_open * math.sqrt(504) * 100
// float h4_atr_ann_pct = h4_atr / h4_close_prev * math.sqrt(504) * 100  // ← No gap fix: uncomment this, comment line above

var float effvol_4h = na
bool new_4h = ta.change(time("240")) != 0
if new_4h
    effvol_4h := h4_slope * h4_atr_ann_pct
if na(effvol_4h)
    effvol_4h := h4_slope * h4_atr_ann_pct

float P_4h          = math.round(h4_open)
float sigma_4h      = P_4h * effvol_4h / (100.0 * math.sqrt(504.0))
float dist_strong_4h = sigma_4h
float dist_weak_4h   = sigma_4h / 2.77
float ws_4h          = math.round(sigma_4h / 4.35)
float ww_4h          = math.round(sigma_4h / 5.1)

// 4H zone boundaries
float h4sd_low  = math.round(P_4h - dist_strong_4h - ws_4h / 2)
float h4sd_high = math.round(P_4h - dist_strong_4h + ws_4h / 2)
float h4wd_low  = math.round(P_4h - dist_weak_4h   - ww_4h / 2)
float h4wd_high = math.round(P_4h - dist_weak_4h   + ww_4h / 2)
float h4ws_low  = math.round(P_4h + dist_weak_4h   - ww_4h / 2)
float h4ws_high = math.round(P_4h + dist_weak_4h   + ww_4h / 2)
float h4ss_low  = math.round(P_4h + dist_strong_4h - ws_4h / 2)
float h4ss_high = math.round(P_4h + dist_strong_4h + ws_4h / 2)

// 4H POC: first session averages last 2 pivots (overnight smoothing),
// second session uses simple prev 4H pivot
float h4_pivot1 = (h4_high_prev + h4_low_prev + h4_close_prev) / 3
float h4_pivot2 = (h4_high_prev2 + h4_low_prev2 + h4_close_prev2) / 3

var bool in_first_4h_session = true
if ta.change(time("D")) != 0
    in_first_4h_session := true
else if new_4h
    in_first_4h_session := false

float h4poc = in_first_4h_session ? math.round((h4_pivot1 + h4_pivot2) / 2) : math.round(h4_pivot1)

// ── ZONE DISPLAY (2 Layers) ─────────────────────────────────────────────────
// Each layer maps its dropdown selection to the pre-computed zone boundaries.
// Colors use const literals directly in plot() to avoid series-type promotion
// (any conditional color — even on input.string — counts as series in PineScript).
// Layer 1: Green/Lime demand / Orange/Red supply / DodgerBlue POC
// Layer 2: Cyan/Teal demand / Magenta/Crimson supply / Dark Green POC

// Layer 1 — zone boundaries (hidden when show_l1_zones is off)
float l1_sd_l = show_l1_zones ? f_z(layer1_tf, h4sd_low,  sd_low,  wsd_low,  msd_low,  qsd_low,  hysd_low) : na
float l1_sd_h = show_l1_zones ? f_z(layer1_tf, h4sd_high, sd_high, wsd_high, msd_high, qsd_high, hysd_high) : na
float l1_wd_l = show_l1_zones ? f_z(layer1_tf, h4wd_low,  wd_low,  wwd_low,  mwd_low,  qwd_low,  hywd_low) : na
float l1_wd_h = show_l1_zones ? f_z(layer1_tf, h4wd_high, wd_high, wwd_high, mwd_high, qwd_high, hywd_high) : na
float l1_ws_l = show_l1_zones ? f_z(layer1_tf, h4ws_low,  wsp_low, wws_low,  mws_low,  qws_low,  hyws_low) : na
float l1_ws_h = show_l1_zones ? f_z(layer1_tf, h4ws_high, wsp_high,wws_high, mws_high, qws_high, hyws_high) : na
float l1_ss_l = show_l1_zones ? f_z(layer1_tf, h4ss_low,  ss_low,  wss_low,  mss_low,  qss_low,  hyss_low) : na
float l1_ss_h = show_l1_zones ? f_z(layer1_tf, h4ss_high, ss_high, wss_high, mss_high, qss_high, hyss_high) : na

// Break POC transitions by inserting na at period boundaries (avoids diagonal)
bool new_day = ta.change(time("D")) != 0
float h4poc_c  = new_4h ? na : h4poc
float dpoc_c   = new_day ? na : dpoc
float wpoc_c   = new_week ? na : wpoc
float mpoc_c   = new_month ? na : mpoc
float qpoc_c   = new_quarter ? na : qpoc
float hypoc_c  = new_half ? na : hypoc

float l1_poc  = show_l1_poc ? f_z(layer1_tf, h4poc_c, dpoc_c, wpoc_c, mpoc_c, qpoc_c, hypoc_c) : na

// Plot Layer 1 (steplinebr eliminates diagonal transitions without losing first bar)
l1a = plot(l1_sd_l, title="L1 SD Lo", color=color.new(color.green,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l1b = plot(l1_sd_h, title="L1 SD Hi", color=color.new(color.green,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l1a, l1b, color=color.new(color.green,75), title="L1 Strong Demand")
l1c = plot(l1_wd_l, title="L1 WD Lo", color=color.new(color.lime,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l1d = plot(l1_wd_h, title="L1 WD Hi", color=color.new(color.lime,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l1c, l1d, color=color.new(color.lime,82), title="L1 Weak Demand")
l1e = plot(l1_ws_l, title="L1 WS Lo", color=color.new(color.orange,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l1f = plot(l1_ws_h, title="L1 WS Hi", color=color.new(color.orange,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l1e, l1f, color=color.new(color.orange,82), title="L1 Weak Supply")
l1g = plot(l1_ss_l, title="L1 SS Lo", color=color.new(color.red,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l1h = plot(l1_ss_h, title="L1 SS Hi", color=color.new(color.red,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l1g, l1h, color=color.new(color.red,75), title="L1 Strong Supply")
plot(l1_poc, title="L1 POC", color=color.new(#1E90FF,0), linewidth=3, style=plot.style_linebr)

// Layer 2 — zone boundaries (hidden when show_l2_zones is off)
float l2_sd_l = show_l2_zones ? f_z(layer2_tf, h4sd_low,  sd_low,  wsd_low,  msd_low,  qsd_low,  hysd_low) : na
float l2_sd_h = show_l2_zones ? f_z(layer2_tf, h4sd_high, sd_high, wsd_high, msd_high, qsd_high, hysd_high) : na
float l2_wd_l = show_l2_zones ? f_z(layer2_tf, h4wd_low,  wd_low,  wwd_low,  mwd_low,  qwd_low,  hywd_low) : na
float l2_wd_h = show_l2_zones ? f_z(layer2_tf, h4wd_high, wd_high, wwd_high, mwd_high, qwd_high, hywd_high) : na
float l2_ws_l = show_l2_zones ? f_z(layer2_tf, h4ws_low,  wsp_low, wws_low,  mws_low,  qws_low,  hyws_low) : na
float l2_ws_h = show_l2_zones ? f_z(layer2_tf, h4ws_high, wsp_high,wws_high, mws_high, qws_high, hyws_high) : na
float l2_ss_l = show_l2_zones ? f_z(layer2_tf, h4ss_low,  ss_low,  wss_low,  mss_low,  qss_low,  hyss_low) : na
float l2_ss_h = show_l2_zones ? f_z(layer2_tf, h4ss_high, ss_high, wss_high, mss_high, qss_high, hyss_high) : na
float l2_poc  = show_l2_poc ? f_z(layer2_tf, h4poc_c, dpoc_c, wpoc_c, mpoc_c, qpoc_c, hypoc_c) : na

// Plot Layer 2 (cyan demand, magenta supply, dark green POC)
l2a = plot(l2_sd_l, title="L2 SD Lo", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l2b = plot(l2_sd_h, title="L2 SD Hi", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l2a, l2b, color=color.new(#00838F,75), title="L2 Strong Demand")
l2c = plot(l2_wd_l, title="L2 WD Lo", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l2d = plot(l2_wd_h, title="L2 WD Hi", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l2c, l2d, color=color.new(#00BCD4,82), title="L2 Weak Demand")
l2e = plot(l2_ws_l, title="L2 WS Lo", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l2f = plot(l2_ws_h, title="L2 WS Hi", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l2e, l2f, color=color.new(#E91E63,82), title="L2 Weak Supply")
l2g = plot(l2_ss_l, title="L2 SS Lo", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
l2h = plot(l2_ss_h, title="L2 SS Hi", color=color.new(color.black,100), display=display.none, linewidth=1, style=plot.style_steplinebr)
fill(l2g, l2h, color=color.new(#AD1457,75), title="L2 Strong Supply")
plot(l2_poc, title="L2 POC", color=color.new(#2E7D32,0), linewidth=3, style=plot.style_linebr)

// Standalone Weekly POC (independent of layer selection)
plot(show_wpoc ? wpoc_c : na, title="Weekly POC", color=color.new(#DAA520,0), linewidth=3, style=plot.style_linebr)

// ── LABELS ───────────────────────────────────────────────────────────────────
if show_labels and new_day
    label.new(bar_index, ss_high + 20,
              "SD:" + str.tostring(sd_low) + "-" + str.tostring(sd_high) +
              " | SS:" + str.tostring(ss_low) + "-" + str.tostring(ss_high),
              style=label.style_none, textcolor=color.gray, size=size.tiny)

if show_labels and new_month
    label.new(bar_index, mss_high + 100,
              "Mσ:" + str.tostring(math.round(sigma_m)) +
              " ATR:" + str.tostring(math.round(m_atr_monthly)) +
              " MSD:" + str.tostring(msd_low) + "-" + str.tostring(msd_high) +
              " MSS:" + str.tostring(mss_low) + "-" + str.tostring(mss_high) +
              " MPOC:" + str.tostring(mpoc),
              style=label.style_label_down, textcolor=color.white,
              color=color.new(#4B0082, 30), size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME SPIKES — graduated bubble size by sigma level
// ══════════════════════════════════════════════════════════════════════════════
float avgVol   = ta.sma(volume, 50)
float stdVol   = ta.stdev(volume, 50)
float volSigma = stdVol > 0 ? (volume - avgVol) / stdVol : 0.0
bool  isSpike  = showSpikes and volSigma >= spikeThresh

plotshape(isSpike and close > open  and volSigma <  4, "Bull Spike S1", shape.circle, location.belowbar, #089981, size=size.tiny)
plotshape(isSpike and close <= open and volSigma <  4, "Bear Spike S1", shape.circle, location.abovebar, #f23645, size=size.tiny)
plotshape(isSpike and close > open  and volSigma >= 4  and volSigma < 6,  "Bull Spike S2", shape.circle, location.belowbar, #089981, size=size.small)
plotshape(isSpike and close <= open and volSigma >= 4  and volSigma < 6,  "Bear Spike S2", shape.circle, location.abovebar, #f23645, size=size.small)
plotshape(isSpike and close > open  and volSigma >= 6  and volSigma < 9,  "Bull Spike S3", shape.circle, location.belowbar, #089981, size=size.normal)
plotshape(isSpike and close <= open and volSigma >= 6  and volSigma < 9,  "Bear Spike S3", shape.circle, location.abovebar, #f23645, size=size.normal)
plotshape(isSpike and close > open  and volSigma >= 9  and volSigma < 12, "Bull Spike S4", shape.circle, location.belowbar, #089981, size=size.large)
plotshape(isSpike and close <= open and volSigma >= 9  and volSigma < 12, "Bear Spike S4", shape.circle, location.abovebar, #f23645, size=size.large)
plotshape(isSpike and close > open  and volSigma >= 12, "Bull Spike S5", shape.circle, location.belowbar, #089981, size=size.huge)
plotshape(isSpike and close <= open and volSigma >= 12, "Bear Spike S5", shape.circle, location.abovebar, #f23645, size=size.huge)

// ══════════════════════════════════════════════════════════════════════════════
// LIQUIDITY ZONES (EQH / EQL)
// Detects equal highs/lows within threshold, draws zones, tracks sweeps.
// ══════════════════════════════════════════════════════════════════════════════

type LiquidityZone
    box   zbox
    line  zmid
    label zlbl
    label zb1
    label zb2
    label zv1
    label zv2
    float sweepLevel
    float totalVol
    int   createdIdx
    bool  isHigh
    bool  isSwept

type PivotPoint
    float price
    int   idx
    float vol

var array<LiquidityZone> liqZones   = array.new<LiquidityZone>()
var array<PivotPoint>    liqPivotHi = array.new<PivotPoint>()
var array<PivotPoint>    liqPivotLo = array.new<PivotPoint>()

liq_fmtVol(float v) =>
    string res = ""
    if v >= 1000000
        res := str.format("{0,number,#.#}M", v / 1000000)
    else if v >= 1000
        res := str.format("{0,number,#.#}K", v / 1000)
    else
        res := str.tostring(v, "#")
    res

liq_updateZone(LiquidityZone z) =>
    bool remove = false
    if not z.isSwept
        box.set_right(z.zbox, bar_index)
        if not na(z.zmid)
            line.set_x2(z.zmid, bar_index)
        label.set_x(z.zlbl, bar_index)
        if bar_index > z.createdIdx
            bool swept = z.isHigh ? high > z.sweepLevel : low < z.sweepLevel
            if swept
                z.isSwept := true
                remove    := true
                if liqDeleteOnSweep
                    box.delete(z.zbox)
                    line.delete(z.zmid)
                    label.delete(z.zlbl)
                    label.delete(z.zb1)
                    label.delete(z.zb2)
                    label.delete(z.zv1)
                    label.delete(z.zv2)
                else
                    box.set_bgcolor(z.zbox,      color.new(chart.fg_color, 95))
                    box.set_border_color(z.zbox, color.new(chart.fg_color, 80))
                    if not na(z.zmid)
                        line.set_color(z.zmid, color.new(chart.fg_color, 80))
                    label.set_textcolor(z.zlbl, color.new(chart.fg_color, 75))
                    string vs = liqShowVol ? str.format(" ({0})", liq_fmtVol(z.totalVol)) : ""
                    label.set_text(z.zlbl, "Swept " + (z.isHigh ? "EQH" : "EQL") + vs)
                    label.set_color(z.zb1, color.new(chart.fg_color, 85))
                    label.set_color(z.zb2, color.new(chart.fg_color, 85))
                    label.set_text(z.zv1, "")
                    label.set_text(z.zv2, "")
    remove

liq_consolidate(array<LiquidityZone> zones) =>
    int sz = zones.size()
    if sz > 0
        for i = 0 to sz - 1
            LiquidityZone z = zones.get(i)
            if not z.isSwept
                label.set_text(z.zlbl, "")
        array<int> done = array.new<int>()
        for i = 0 to sz - 1
            if done.includes(i) or zones.get(i).isSwept
                continue
            LiquidityZone base = zones.get(i)
            done.push(i)
            float cVol = base.totalVol
            int   cCnt = 1
            if i < sz - 1
                for j = i + 1 to sz - 1
                    if done.includes(j)
                        continue
                    LiquidityZone comp = zones.get(j)
                    if comp.isSwept
                        continue
                    if base.isHigh == comp.isHigh and math.abs(base.sweepLevel - comp.sweepLevel) / base.sweepLevel * 100 <= liqThreshPct * 3
                        cVol += comp.totalVol
                        cCnt += 1
                        done.push(j)
            string typeStr  = base.isHigh ? "EQH" : "EQL"
            string countStr = cCnt > 1 ? str.format("{0}x ", cCnt) : ""
            string volStr   = liqShowVol ? str.format(" ({0})", liq_fmtVol(cVol)) : ""
            label.set_text(base.zlbl, countStr + typeStr + volStr)

// Pivot detection
float liqPH = showLiqZones ? ta.pivothigh(liqLeftLen, liqRightLen) : na
float liqPL = showLiqZones ? ta.pivotlow(liqLeftLen,  liqRightLen) : na

// Equal Highs
if not na(liqPH) and showLiqZones
    int   pivIdx = bar_index - liqRightLen
    float pivVol = volume[liqRightLen]
    if liqPivotHi.size() > 0
        for i = 0 to liqPivotHi.size() - 1
            PivotPoint prev = liqPivotHi.get(i)
            float diff = math.abs(liqPH - prev.price) / prev.price * 100
            if diff <= liqThreshPct
                float top  = math.max(liqPH, prev.price)
                float bot  = math.min(liqPH, prev.price)
                float mid  = (top + bot) / 2
                float tVol = prev.vol + pivVol
                box   zb  = box.new(prev.idx, top, bar_index, bot, border_color=liqBearColor, bgcolor=color.new(liqBearColor, liqTransp))
                line  zml = liqMidline ? line.new(prev.idx, mid, bar_index, mid, color=liqMidCol, style=line.style_dashed) : na
                label zlb = label.new(bar_index, mid, "", color=#00000000, textcolor=liqBearColor, style=label.style_label_left, size=size.small)
                label zb1 = label.new(prev.idx, prev.price, "", color=liqBearColor, style=label.style_circle, size=size.small)
                label zb2 = label.new(pivIdx,   liqPH,      "", color=liqBearColor, style=label.style_circle, size=size.small)
                label zv1 = liqShowVol ? label.new(prev.idx, prev.price, liq_fmtVol(prev.vol), color=#00000000, textcolor=liqBearColor, style=label.style_label_down, size=size.small) : na
                label zv2 = liqShowVol ? label.new(pivIdx,   liqPH,      liq_fmtVol(pivVol),   color=#00000000, textcolor=liqBearColor, style=label.style_label_down, size=size.small) : na
                liqZones.push(LiquidityZone.new(zb, zml, zlb, zb1, zb2, zv1, zv2, top, tVol, bar_index, true, false))
                break
    liqPivotHi.unshift(PivotPoint.new(liqPH, pivIdx, pivVol))
    if liqPivotHi.size() > 50
        liqPivotHi.pop()

// Equal Lows
if not na(liqPL) and showLiqZones
    int   pivIdx = bar_index - liqRightLen
    float pivVol = volume[liqRightLen]
    if liqPivotLo.size() > 0
        for i = 0 to liqPivotLo.size() - 1
            PivotPoint prev = liqPivotLo.get(i)
            float diff = math.abs(liqPL - prev.price) / prev.price * 100
            if diff <= liqThreshPct
                float top  = math.max(liqPL, prev.price)
                float bot  = math.min(liqPL, prev.price)
                float mid  = (top + bot) / 2
                float tVol = prev.vol + pivVol
                box   zb  = box.new(prev.idx, top, bar_index, bot, border_color=liqBullColor, bgcolor=color.new(liqBullColor, liqTransp))
                line  zml = liqMidline ? line.new(prev.idx, mid, bar_index, mid, color=liqMidCol, style=line.style_dashed) : na
                label zlb = label.new(bar_index, mid, "", color=#00000000, textcolor=liqBullColor, style=label.style_label_left, size=size.small)
                label zb1 = label.new(prev.idx, prev.price, "", color=liqBullColor, style=label.style_circle, size=size.small)
                label zb2 = label.new(pivIdx,   liqPL,      "", color=liqBullColor, style=label.style_circle, size=size.small)
                label zv1 = liqShowVol ? label.new(prev.idx, prev.price, liq_fmtVol(prev.vol), color=#00000000, textcolor=liqBullColor, style=label.style_label_up, size=size.small) : na
                label zv2 = liqShowVol ? label.new(pivIdx,   liqPL,      liq_fmtVol(pivVol),   color=#00000000, textcolor=liqBullColor, style=label.style_label_up, size=size.small) : na
                liqZones.push(LiquidityZone.new(zb, zml, zlb, zb1, zb2, zv1, zv2, bot, tVol, bar_index, false, false))
                break
    liqPivotLo.unshift(PivotPoint.new(liqPL, pivIdx, pivVol))
    if liqPivotLo.size() > 50
        liqPivotLo.pop()

// Manage zones every bar
if showLiqZones and liqZones.size() > 0
    for i = liqZones.size() - 1 to 0
        LiquidityZone z = liqZones.get(i)
        bool swept = liq_updateZone(z)
        if swept
            liqZones.remove(i)
    while liqZones.size() > liqMaxZones
        liqZones.remove(0)
    if liqZones.size() > 0
        liq_consolidate(liqZones)

// ══════════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
// ══════════════════════════════════════════════════════════════════════════════
float fvgAtr    = ta.atr(14)
bool  isBullFvg = showFvg and low > high[2] and (low - high[2]) > (fvgAtr * fvgSens)
bool  isBearFvg = showFvg and high < low[2] and (low[2] - high) > (fvgAtr * fvgSens)

if isBullFvg
    float fvgMid = math.avg(low, high[2])
    box.new(bar_index - 1, low, bar_index + fvgExtend, high[2], bgcolor=bullFvgCss, border_color=na)
    line.new(bar_index - 1, fvgMid, bar_index + fvgExtend, fvgMid, color=color.new(bullFvgCss, 20), style=line.style_dotted)

if isBearFvg
    float fvgMid = math.avg(high, low[2])
    box.new(bar_index - 1, high, bar_index + fvgExtend, low[2], bgcolor=bearFvgCss, border_color=na)
    line.new(bar_index - 1, fvgMid, bar_index + fvgExtend, fvgMid, color=color.new(bearFvgCss, 20), style=line.style_dotted)

// ══════════════════════════════════════════════════════════════════════════════
// MARKET STRUCTURE — BOS / CHoCH
// ══════════════════════════════════════════════════════════════════════════════
var float msLastHi    = na
var float msLastLo    = na
var int   msLastHiIdx = na
var int   msLastLoIdx = na
var int   msTrend     = 0

float msPH = ta.pivothigh(msSens, msSens)
float msPL = ta.pivotlow(msSens,  msSens)

if not na(msPH)
    msLastHi    := msPH
    msLastHiIdx := bar_index - msSens
if not na(msPL)
    msLastLo    := msPL
    msLastLoIdx := bar_index - msSens

bool msBullBreak = not na(msLastHi) and ta.crossover(close,  msLastHi)
bool msBearBreak = not na(msLastLo) and ta.crossunder(close, msLastLo)

if showMs
    if msBullBreak
        bool isChoch = msTrend == -1
        label.new(int(math.avg(msLastHiIdx, bar_index)), msLastHi,
             isChoch ? "CHoCH" : "BOS",
             color=#00000000, textcolor=bullMsCss, style=label.style_label_down, size=size.tiny)
        line.new(msLastHiIdx, msLastHi, bar_index, msLastHi,
             color=bullMsCss, style=line.style_dotted)
        msTrend  := 1
        msLastHi := na
    if msBearBreak
        bool isChoch = msTrend == 1
        label.new(int(math.avg(msLastLoIdx, bar_index)), msLastLo,
             isChoch ? "CHoCH" : "BOS",
             color=#00000000, textcolor=bearMsCss, style=label.style_label_up, size=size.tiny)
        line.new(msLastLoIdx, msLastLo, bar_index, msLastLo,
             color=bearMsCss, style=line.style_dotted)
        msTrend  := -1
        msLastLo := na

// ══════════════════════════════════════════════════════════════════════════════
// HTF PROJECTED CANDLES
// ══════════════════════════════════════════════════════════════════════════════
var array<float> htfOpenArr  = array.new_float()
var array<float> htfHighArr  = array.new_float()
var array<float> htfLowArr   = array.new_float()
var array<float> htfCloseArr = array.new_float()
var array<int>   htfStartArr = array.new_int()

var float htfCurO      = na
var float htfCurH      = na
var float htfCurL      = na
var float htfSessClose = na
var int   htfCurStart  = na

bool isNewHtf = ta.change(time(htfInput)) != 0

if isNewHtf
    if not na(htfCurO)
        array.unshift(htfOpenArr,  htfCurO)
        array.unshift(htfHighArr,  htfCurH)
        array.unshift(htfLowArr,   htfCurL)
        array.unshift(htfCloseArr, nz(htfSessClose, close[1]))
        array.unshift(htfStartArr, htfCurStart)
        if array.size(htfOpenArr) > 10
            array.pop(htfOpenArr)
            array.pop(htfHighArr)
            array.pop(htfLowArr)
            array.pop(htfCloseArr)
            array.pop(htfStartArr)
    htfCurO     := open
    htfCurH     := high
    htfCurL     := low
    htfCurStart := bar_index
    htfSessClose := na
else
    htfCurH := math.max(high, nz(htfCurH, high))
    htfCurL := math.min(low,  nz(htfCurL, low))
    htfSessClose := close

var array<box>  htfBoxes  = array.new_box()
var array<line> htfWicks  = array.new_line()
var array<line> htfOLines = array.new_line()

if barstate.islast and showHtf
    if array.size(htfBoxes) > 0
        for i = 0 to array.size(htfBoxes) - 1
            box.delete(array.get(htfBoxes, i))
    if array.size(htfWicks) > 0
        for i = 0 to array.size(htfWicks) - 1
            line.delete(array.get(htfWicks, i))
    if array.size(htfOLines) > 0
        for i = 0 to array.size(htfOLines) - 1
            line.delete(array.get(htfOLines, i))
    array.clear(htfBoxes)
    array.clear(htfWicks)
    array.clear(htfOLines)

    for i = 0 to htfCount - 1
        float o = i == 0 ? htfCurO : (array.size(htfOpenArr)  > i-1 ? array.get(htfOpenArr,  i-1) : na)
        float h = i == 0 ? htfCurH : (array.size(htfHighArr)  > i-1 ? array.get(htfHighArr,  i-1) : na)
        float l = i == 0 ? htfCurL : (array.size(htfLowArr)   > i-1 ? array.get(htfLowArr,   i-1) : na)
        float c = i == 0 ? close   : (array.size(htfCloseArr) > i-1 ? array.get(htfCloseArr, i-1) : na)
        int   s = i == 0 ? htfCurStart : (array.size(htfStartArr) > i-1 ? array.get(htfStartArr, i-1) : na)

        if not na(o) and not na(h) and not na(l) and not na(c)
            int spacing   = 12
            int posIdx    = htfCount - 1 - i
            int left      = bar_index + htfOffset + (posIdx * spacing)
            int right     = left + 8
            color htfCss  = c >= o ? #089981 : #f23645
            int bodyTrans = i == 0 ? 50 : 100 - htfHistOpacity
            int lineTrans = i == 0 ? 0  : 100 - htfHistOpacity
            array.push(htfBoxes, box.new(left, math.max(o, c), right, math.min(o, c),
                 bgcolor=color.new(htfCss, bodyTrans), border_color=color.new(htfCss, lineTrans)))
            array.push(htfWicks, line.new(int(math.avg(left, right)), h,
                 int(math.avg(left, right)), l, color=color.new(htfCss, lineTrans)))
            if showHtfLines and not na(s)
                array.push(htfOLines, line.new(s, o, left, o, color=openLineCss, style=line.style_solid))

// ── ZONE ENTRY ALERTS ────────────────────────────────────────────────────────
// Fires when price first enters a zone (low dips into demand / high reaches supply).
// Users set alerts via: Right-click indicator → Add Alert → pick condition.

// Daily zone entries
bool enter_sd = low <= sd_high and low[1] > sd_high[1]
bool enter_wd = low <= wd_high and low[1] > wd_high[1]
bool enter_ws = high >= wsp_low and high[1] < wsp_low[1]
bool enter_ss = high >= ss_low and high[1] < ss_low[1]

// Weekly zone entries
bool enter_wsd = low <= wsd_high and low[1] > wsd_high[1]
bool enter_wwd = low <= wwd_high and low[1] > wwd_high[1]
bool enter_wws = high >= wws_low and high[1] < wws_low[1]
bool enter_wss = high >= wss_low and high[1] < wss_low[1]

// Monthly zone entries
bool enter_msd = low <= msd_high and low[1] > msd_high[1]
bool enter_mwd = low <= mwd_high and low[1] > mwd_high[1]
bool enter_mws = high >= mws_low and high[1] < mws_low[1]
bool enter_mss = high >= mss_low and high[1] < mss_low[1]

// 4H zone entries
bool enter_h4sd = low <= h4sd_high and low[1] > h4sd_high[1]
bool enter_h4wd = low <= h4wd_high and low[1] > h4wd_high[1]
bool enter_h4ws = high >= h4ws_low and high[1] < h4ws_low[1]
bool enter_h4ss = high >= h4ss_low and high[1] < h4ss_low[1]

// Quarterly zone entries
bool enter_qsd = low <= qsd_high and low[1] > qsd_high[1]
bool enter_qwd = low <= qwd_high and low[1] > qwd_high[1]
bool enter_qws = high >= qws_low and high[1] < qws_low[1]
bool enter_qss = high >= qss_low and high[1] < qss_low[1]

// Half-Yearly zone entries
bool enter_hysd = low <= hysd_high and low[1] > hysd_high[1]
bool enter_hywd = low <= hywd_high and low[1] > hywd_high[1]
bool enter_hyws = high >= hyws_low and high[1] < hyws_low[1]
bool enter_hyss = high >= hyss_low and high[1] < hyss_low[1]

// Composite alerts
bool enter_any_demand = enter_sd or enter_wd or enter_wsd or enter_wwd or enter_msd or enter_mwd or enter_h4sd or enter_h4wd or enter_qsd or enter_qwd or enter_hysd or enter_hywd
bool enter_any_supply = enter_ss or enter_ws or enter_wss or enter_wws or enter_mss or enter_mws or enter_h4ss or enter_h4ws or enter_qss or enter_qws or enter_hyss or enter_hyws
bool enter_daily_strong  = enter_sd or enter_ss
bool enter_weekly_strong = enter_wsd or enter_wss
bool enter_monthly_strong = enter_msd or enter_mss
bool enter_4h_strong = enter_h4sd or enter_h4ss
bool enter_quarterly_strong = enter_qsd or enter_qss
bool enter_halfyearly_strong = enter_hysd or enter_hyss
bool enter_any_strong = enter_sd or enter_ss or enter_wsd or enter_wss or enter_msd or enter_mss or enter_h4sd or enter_h4ss or enter_qsd or enter_qss or enter_hysd or enter_hyss
bool enter_any_zone = enter_any_demand or enter_any_supply

alertcondition(enter_sd,  title="Daily Strong Demand Entry",  message="Price entered Daily Strong Demand zone ({{ticker}})")
alertcondition(enter_wd,  title="Daily Weak Demand Entry",    message="Price entered Daily Weak Demand zone ({{ticker}})")
alertcondition(enter_ws,  title="Daily Weak Supply Entry",    message="Price entered Daily Weak Supply zone ({{ticker}})")
alertcondition(enter_ss,  title="Daily Strong Supply Entry",  message="Price entered Daily Strong Supply zone ({{ticker}})")

alertcondition(enter_wsd, title="Weekly Strong Demand Entry", message="Price entered Weekly Strong Demand zone ({{ticker}})")
alertcondition(enter_wwd, title="Weekly Weak Demand Entry",   message="Price entered Weekly Weak Demand zone ({{ticker}})")
alertcondition(enter_wws, title="Weekly Weak Supply Entry",   message="Price entered Weekly Weak Supply zone ({{ticker}})")
alertcondition(enter_wss, title="Weekly Strong Supply Entry", message="Price entered Weekly Strong Supply zone ({{ticker}})")

alertcondition(enter_msd, title="Monthly Strong Demand Entry", message="Price entered Monthly Strong Demand zone ({{ticker}})")
alertcondition(enter_mwd, title="Monthly Weak Demand Entry",   message="Price entered Monthly Weak Demand zone ({{ticker}})")
alertcondition(enter_mws, title="Monthly Weak Supply Entry",   message="Price entered Monthly Weak Supply zone ({{ticker}})")
alertcondition(enter_mss, title="Monthly Strong Supply Entry", message="Price entered Monthly Strong Supply zone ({{ticker}})")

alertcondition(enter_h4sd, title="4H Strong Demand Entry", message="Price entered 4H Strong Demand zone ({{ticker}})")
alertcondition(enter_h4wd, title="4H Weak Demand Entry",   message="Price entered 4H Weak Demand zone ({{ticker}})")
alertcondition(enter_h4ws, title="4H Weak Supply Entry",   message="Price entered 4H Weak Supply zone ({{ticker}})")
alertcondition(enter_h4ss, title="4H Strong Supply Entry", message="Price entered 4H Strong Supply zone ({{ticker}})")

alertcondition(enter_qsd, title="Quarterly Strong Demand Entry", message="Price entered Quarterly Strong Demand zone ({{ticker}})")
alertcondition(enter_qwd, title="Quarterly Weak Demand Entry",   message="Price entered Quarterly Weak Demand zone ({{ticker}})")
alertcondition(enter_qws, title="Quarterly Weak Supply Entry",   message="Price entered Quarterly Weak Supply zone ({{ticker}})")
alertcondition(enter_qss, title="Quarterly Strong Supply Entry", message="Price entered Quarterly Strong Supply zone ({{ticker}})")

alertcondition(enter_hysd, title="Half-Yearly Strong Demand Entry", message="Price entered Half-Yearly Strong Demand zone ({{ticker}})")
alertcondition(enter_hywd, title="Half-Yearly Weak Demand Entry",   message="Price entered Half-Yearly Weak Demand zone ({{ticker}})")
alertcondition(enter_hyws, title="Half-Yearly Weak Supply Entry",   message="Price entered Half-Yearly Weak Supply zone ({{ticker}})")
alertcondition(enter_hyss, title="Half-Yearly Strong Supply Entry", message="Price entered Half-Yearly Strong Supply zone ({{ticker}})")

alertcondition(enter_any_demand, title="⚡ Any Demand Zone Entry", message="Price entered a demand zone ({{ticker}})")
alertcondition(enter_any_supply, title="⚡ Any Supply Zone Entry", message="Price entered a supply zone ({{ticker}})")
alertcondition(enter_daily_strong,  title="⚡ Daily Strong Zone Entry",   message="Price entered Daily Strong Demand or Supply ({{ticker}})")
alertcondition(enter_weekly_strong, title="⚡ Weekly Strong Zone Entry",  message="Price entered Weekly Strong Demand or Supply ({{ticker}})")
alertcondition(enter_monthly_strong, title="⚡ Monthly Strong Zone Entry", message="Price entered Monthly Strong Demand or Supply ({{ticker}})")
alertcondition(enter_4h_strong, title="⚡ 4H Strong Zone Entry", message="Price entered 4H Strong Demand or Supply ({{ticker}})")
alertcondition(enter_quarterly_strong, title="⚡ Quarterly Strong Zone Entry", message="Price entered Quarterly Strong Demand or Supply ({{ticker}})")
alertcondition(enter_halfyearly_strong, title="⚡ Half-Yearly Strong Zone Entry", message="Price entered Half-Yearly Strong Demand or Supply ({{ticker}})")
alertcondition(enter_any_strong, title="⚡ Any Strong Zone Entry", message="Price entered a strong zone — any timeframe ({{ticker}})")
alertcondition(enter_any_zone,   title="⚡ Any Zone Entry",        message="Price entered a zone — any timeframe ({{ticker}})")
````
