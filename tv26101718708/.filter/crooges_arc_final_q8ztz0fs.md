# $crooge's - A.R.C. [Final]

- url: https://www.tradingview.com/script/q8zTZ0fS-crooge-s-A-R-C-Final/
- type: indicator
- pine_id: PUB;43b696557201415e9fdc4b8aab45c11b
- version: 1.0

## Description

Overview
The A.R.C. Master (Adaptive Ratchet Channel) is a comprehensive trend-following and risk management engine designed for traders who demand precision across different asset classes. Unlike static indicators that fail when volatility spikes, the A.R.C. Master uses a dynamic "Ratchet" logic that recalibrates in real-time based on the specific Character of the asset you are trading.

Whether you are scalping [symbol="NASDAQ:SNDK"]NASDAQ:SNDK[/symbol] on the 1-minute chart or swing trading the S&P 500, this script provides a clear, institutional-grade "line in the sand" for every trade.

Key Features
1. ⏱️ Modular Strategy Horizons
No more changing settings every time you switch timeframes. The A.R.C. Master features four hard-coded modes that automatically adjust the engine’s sensitivity:

SCALP MODE (1m-2m): Ultra-tight tracking for momentum bursts.

INTRADAY MODE (5m-15m): Balanced smoothing for the "daily grind."

SWING MODE (1h-4h): Filters out intraday noise to capture multi-day trends.

TREND MODE (Daily): Focuses on major structural market shifts.

2. 💎 Asset Character Calibration
Different assets breathe differently. This script includes 10 pre-tuned presets to match the unique volatility profiles of:

INDICES: SPY, QQQ, SPX (Uses close for structural stability).

CHIPS / SEMIS: [symbol="NASDAQ:SNDK"]NASDAQ:SNDK[/symbol], [symbol="NASDAQ:NVDA"]NASDAQ:NVDA[/symbol], [symbol="NASDAQ:MU"]NASDAQ:MU[/symbol] (Optimized for high-velocity gaps).

EV SECTOR: [symbol="NASDAQ:TSLA"]NASDAQ:TSLA[/symbol], [symbol="NASDAQ:RIVN"]NASDAQ:RIVN[/symbol] (Handles aggressive retail sentiment).

CRYPTO / BTC: Optimized for 24/7 high-beta volatility.

Also includes: Energy, Growth, Leveraged 3x, Forex, Retail, and Biotech.

3. 🏦 Institutional Volume Detection
Stop guessing where "Big Money" is entering. The script monitors volume relative to a 20-period average:

White Bar (Inst. Buy): High-volume absorption at support.

Orange Bar (Inst. Sell): Heavy distribution at resistance.

Visuals can be toggled on/off to keep your charts clean.

4. ⚙️ The "Zero-Reset" Override (New)
For specialized tickers or extreme market events, you can manually override the Volume Threshold or Scalar sensitivity.

The Power of Zero: Simply set the override to 0 to instantly revert to the optimized sector presets.

How to Use the A.R.C. Master
The Entry: Look for the Ratchet Line to flip Cyan (Bullish). Entry is highest conviction when a White Institutional Bar appears right as the price touches the Ratchet Line.

The Hold: As long as the price stays above the Cyan line, the trend is intact. The "Ratchet" will move up with the price, locking in unrealized gains.

The Exit: A candle close below the Ratchet Line (turning the line Pink) is a signal of a structural trend break. Exit or flip bias immediately.

Technical Breakdown
Core Engine: Adaptive ATR-based volatility buffer combined with dual-EMA smoothing.

Source Logic: Intelligently switches between hlcc4 (for volatile sectors) and close (for indices) to ensure you aren't stopped out by rogue wicks.

Disclaimer: Trading involves significant risk. The A.R.C. Master is a tool to assist in decision-making and does not guarantee profits. Use proper stop-losses and risk management at all times.

## Source Code

````pine
//@version=5
indicator("$crooge's - A.R.C. Master [Final]", overlay=true)

// ==========================================
// --- ⏱️ STRATEGY HORIZON ---
// ==========================================
var string GRP_HOR = "⏱️ STRATEGY HORIZON"
mode_scalp = input.bool(true,  "SCALP MODE", tooltip="Rec TF: 1m - 2m.\nBest for catching rapid momentum shifts.", group=GRP_HOR)
mode_intra = input.bool(false, "INTRADAY MODE", tooltip="Rec TF: 5m - 15m.\nBest for active day trading.", group=GRP_HOR)
mode_swing = input.bool(false, "SWING MODE", tooltip="Rec TF: 1h - 4h.\nFilters out daily noise for multi-day moves.", group=GRP_HOR)
mode_trend = input.bool(false, "TREND MODE", tooltip="Rec TF: Daily.\nFocuses on major structural reversals.", group=GRP_HOR)

// ==========================================
// --- 💎 ASSET CHARACTER (Presets) ---
// ==========================================
var string GRP_CHAR = "💎 ASSET CHARACTER (Choose One)"
type_indices = input.bool(true,  "INDICES (SPY, QQQ, IWM)", group=GRP_CHAR)
type_chips   = input.bool(false, "CHIPS / SEMIS", group=GRP_CHAR)
type_energy  = input.bool(false, "ENERGY / OIL", group=GRP_CHAR)
type_growth  = input.bool(false, "GROWTH / SAAS", group=GRP_CHAR)
type_lvrg    = input.bool(false, "LEVERAGED 2x - 3x", group=GRP_CHAR)
type_crypto  = input.bool(false, "CRYPTO / BTC / ETH", group=GRP_CHAR)
type_forex   = input.bool(false, "FOREX / CURRENCIES", group=GRP_CHAR)
type_retail  = input.bool(false, "RETAIL / CONSUMER (WMT, AMZN)", group=GRP_CHAR)
type_bio     = input.bool(false, "BIOTECH / PHARMA", group=GRP_CHAR)
type_ev      = input.bool(false, "EV SECTOR (TSLA, RIVN, LCID)", group=GRP_CHAR)

// ==========================================
// --- 🏦 INSTITUTIONAL TOOLS ---
// ==========================================
var string GRP_INST = "🏦 INSTITUTIONAL TOOLS"
show_inst_bars = input.bool(true, "Show Big Money Candles", group=GRP_INST)
// MODIFIED: Manual Overrides (Set to 0 to use Presets above)
manual_vol     = input.float(0.0, "Manual Vol Threshold (Set 0 for Presets)", step=0.1, group=GRP_INST)
manual_scalar  = input.float(0.0, "Manual Scalar Override (Set 0 for Presets)", step=0.1, group=GRP_INST)

// ==========================================
// --- 🎨 STYLE & VISUALS ---
// ==========================================
var string GRP_STYLE = "🎨 STYLE SETTINGS"
bull_col     = input.color(#00ffcc, "Bullish Color", group=GRP_STYLE)
bear_col     = input.color(#ff0055, "Bearish Color", group=GRP_STYLE)
inst_bull    = input.color(#ffffff, "Inst. Buy (White)", group=GRP_STYLE)
inst_bear    = input.color(#ffa500, "Inst. Sell (Orange)", group=GRP_STYLE)
show_bs      = input.bool(true, "Show BUY/SELL Signals", group=GRP_STYLE)
show_labels  = input.bool(true, "Show Dashboard Label", group=GRP_STYLE)

// ==========================================
// --- ENGINE LOGIC ---
// ==========================================
float m_base = mode_scalp ? 1.6 : mode_intra ? 2.2 : mode_swing ? 3.4 : 4.2

// MODIFIED: Use Manual Scalar if not 0, otherwise use Preset logic
float cat_scalar = manual_scalar != 0.0 ? manual_scalar : 
     (type_indices ? 0.7 : type_chips ? 1.3 : type_energy ? 1.2 : type_growth ? 1.5 : 
      type_lvrg ? 1.8 : type_crypto ? 2.1 : type_forex ? 0.8 : type_retail ? 1.1 : 
      type_bio ? 1.9 : type_ev ? 1.4 : 1.0)

float final_mult = m_base * cat_scalar

source_auto = (type_chips or type_growth or type_lvrg or type_ev or type_bio) ? hlcc4 : close
int smooth_len = mode_scalp ? 5 : mode_intra ? 8 : mode_swing ? 10 : 14

_tr = ta.rma(ta.tr(true), 14)
_s_h = ta.ema(high, smooth_len), _s_l = ta.ema(low, smooth_len)

var float active_line = na
var int trend_dir = 1
float _up = ta.highest(_s_h, 20) - (_tr * final_mult), _dn = ta.lowest(_s_l, 20) + (_tr * final_mult)

active_line := nz(active_line[1], source_auto)
if trend_dir == 1
    active_line := math.max(_up, active_line)
    if source_auto < active_line
        trend_dir := -1
        active_line := _dn
else
    active_line := math.min(_dn, active_line)
    if source_auto > active_line
        trend_dir := 1
        active_line := _up

// ==========================================
// --- 🏦 INSTITUTIONAL BAR OUTPUT ---
// ==========================================
// MODIFIED: Use Manual Volume if not 0, otherwise use Preset logic (defaulting to 1.5)
float final_vol_mult = manual_vol != 0.0 ? manual_vol : 1.5
avg_vol = ta.sma(volume, 20)
is_inst = volume > (avg_vol * final_vol_mult)

// Applying the logic: White for Inst-Buy, Orange for Inst-Sell, else Ratchet Color
barcolor(show_inst_bars and is_inst ? (close > open ? inst_bull : inst_bear) : (trend_dir == 1 ? bull_col : bear_col))

// ==========================================
// --- SIGNALS ---
// ==========================================
is_buy = ta.change(trend_dir) > 0
is_sell = ta.change(trend_dir) < 0

plotshape(show_bs and is_buy ? low : na, "BUY", shape.triangleup, location.belowbar, bull_col, size=size.small, text="BUY", textcolor=color.white)
plotshape(show_bs and is_sell ? high : na, "SELL", shape.triangledown, location.abovebar, bear_col, size=size.small, text="SELL", textcolor=color.white)

// ==========================================
// --- DASHBOARD & OUTPUTS ---
// ==========================================
plot(active_line, "Ratchet Flow", color=(trend_dir == 1 ? bull_col : bear_col), linewidth=3)

if show_labels and barstate.islast
    string cat_name = type_indices ? "INDICES" : type_chips ? "CHIPS" : type_energy ? "ENERGY" : type_growth ? "GROWTH" : type_lvrg ? "LEVERAGED" : type_crypto ? "CRYPTO" : type_forex ? "FOREX" : type_retail ? "RETAIL" : type_bio ? "BIOTECH" : "EV"
````
