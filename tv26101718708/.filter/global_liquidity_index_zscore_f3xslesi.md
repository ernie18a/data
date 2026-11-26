# Global Liquidity Index (Z-Score)

- url: https://www.tradingview.com/script/f3XslEsI-Global-Liquidity-Index-Z-Score/
- type: indicator
- pine_id: PUB;b5f395b1b31a40199739329b68ce0458
- version: 1.0

## Description

Global Liquidity Index (Quant Normalized Edition)

Overview
The Global Liquidity Index (Quant Normalized Edition) is a professional-grade macro indicator designed to track the "lifeblood" of financial markets: Fiat Liquidity. Unlike retail-focused momentum oscillators, this tool dives deep into the Market Plumbing of the world’s major central banks to provide a lead-lag perspective on asset prices.

The Core Logic
Liquidity is not a single number; it is a flow. This indicator aggregates data from the Federal Reserve (FED), ECB, PBoC, BoJ, BoE, and SNB.
It offers two distinct calculation modes:
-Net Central Banks: Focuses on the "true" spendable liquidity by calculating: (Balance Sheet - RRP - TGA) for the US, plus major global central bank assets.
-Global M2: Tracks the broad money supply growth across the world's largest economies.

Key Features
-Z-Score Normalization Layer: The breakthrough feature of this version. By applying a Z-score normalization to the liquidity Rate of Change (ROC), the script standardizes the different magnitudes of central bank balance sheets. This ensures that a massive move in the PBoC is weighted correctly against the FED, providing a balanced signal.
-4-Phase Liquidity Engine: The indicator categorizes the market regime into four distinct stages:
Phase 1: IGNITION (Blue) – Liquidity is beginning to accelerate, often preceding a major breakout.
Phase 2: FULL THRUST (Green) – Maximum liquidity momentum; the "Golden Window" for trend-following.
Phase 3: ROTATION (Orange) – Liquidity is decelerating. Momentum is fading, suggesting risk-off or distribution.
Phase 4: DROUGHT (Red) – Net liquidity is contracting.Historically associated with increased volatility and "rug pulls".
-X-Ray Projection (Offset): Includes a time-shifting engine that allows users to project the liquidity signal forward (or backward) to identify lead-lag correlations with price action.
-Dynamic Correlation: An integrated dashboard shows the real-time correlation between the liquidity flow and the current chart's price action.

How to Use
-Bullish Environments: Look for Phase 1 (Ignition) transitions into Phase 2 (Full Thrust).
-Risk Mitigation: Be cautious when the signal enters Phase 3 (Rotation), as this often marks the "topping out" of the liquidity cycle.
-Divergence: Watch for "Price vs. Liquidity" divergences, where price moves higher while liquidity (GLI) is making lower highs.

Credits & Disclaimer
Credits: The foundational macro-data fetching logic was inspired by the original work of QuantitativeAlpha. This version has been deeply modified and independently developed to include a proprietary Z-Score normalization layer, a time-shifting engine, and a 4-phase algorithmic regime filter.

Disclaimer: This indicator is for educational and informational purposes only. It does not constitute financial or investment advice.

## Source Code

````pine
// © giorgosgttsivis
//@version=6
indicator(title = 'Global Liquidity Index (Z-Score)', shorttitle = 'GLI Z', overlay = false)

// ==============================================================================
// 1. INPUTS & SETTINGS
// ==============================================================================
calc_mode   = input.string('Net Central Banks', title = 'Liquidity Metric', options = ['Net Central Banks', 'Global M2'])

// Το "Χρονομηχανή" Input (X-Ray)
offset_bars = input.int(0, title = 'Projection Offset (Bars Forward)')

// ΝΕΟ: Z-Score Normalization Layer (από V6)
use_norm    = input.bool(true, title = 'Normalize Signal (Z-Score)', tooltip="Εξισορροπεί τις διαφορές μεγέθους μεταξύ των Κεντρικών Τραπεζών.")
norm_len    = input.int(100, title = 'Normalization Length', minval=10)

// Ανάλυση & Εξομάλυνση (Ο πυρήνας του V5)
base_smooth = input.int(3, title = 'Base Data Smoothing', minval=1)
roc_len     = input.int(12, title = 'Momentum Length')

// Οι 3 Ταχύτητες
fast_len    = input.int(4,  title = 'Fast EMA (Mega Caps)')
med_len     = input.int(12, title = 'Medium EMA (Broad Market)')
slow_len    = input.int(26, title = 'Slow EMA (Small Caps)')

// Correlation
corr_len    = input.int(24, title = 'Correlation Length')

// ==============================================================================
// 2. MACRO DATA FETCHING (ADAPTIVE TIMEFRAME)
// ==============================================================================
tf = timeframe.period

fed_bs  = request.security('ECONOMICS:USCBBS', tf, close, currency = currency.USD)
fed_rrp = request.security('FRED:RRPONTSYD',   tf, close, currency = currency.USD)
fed_tga = request.security('FRED:WTREGEN',     tf, close, currency = currency.USD)
us_m2   = request.security('ECONOMICS:USM2',   tf, close, currency = currency.USD)

ecb_cb  = request.security('ECONOMICS:EUCBBS', tf, close, currency = currency.USD)
eu_m2   = request.security('ECONOMICS:EUM2',   tf, close, currency = currency.USD)

pboc_cb = request.security('ECONOMICS:CNCBBS', tf, close, currency = currency.USD)
cn_m2   = request.security('ECONOMICS:CNM2',   tf, close, currency = currency.USD)

boj_cb  = request.security('ECONOMICS:JPCBBS', tf, close, currency = currency.USD)
jp_m2   = request.security('ECONOMICS:JPM2',   tf, close, currency = currency.USD)

boe_cb  = request.security('ECONOMICS:GBCBBS', tf, close, currency = currency.USD)
uk_m2   = request.security('ECONOMICS:GBM2',   tf, close, currency = currency.USD)

snb_cb  = request.security('ECONOMICS:CHCBBS', tf, close, currency = currency.USD)
ch_m2   = request.security('ECONOMICS:CHM2',   tf, close, currency = currency.USD)

// ==============================================================================
// 3. CORE LOGIC & DATA SMOOTHING
// ==============================================================================
var float raw_liquidity = 0.0

if calc_mode == 'Net Central Banks'
    raw_liquidity := (fed_bs - fed_rrp - fed_tga) + ecb_cb + pboc_cb + boj_cb + boe_cb + snb_cb
else
    raw_liquidity := us_m2 + eu_m2 + cn_m2 + jp_m2 + uk_m2 + ch_m2

total_liquidity = ta.ema(raw_liquidity, base_smooth)

// Βασικό Momentum
liq_roc = ta.roc(total_liquidity, roc_len)

// Quant Layer: Z-Score Normalization (εφαρμόζεται στο ROC για να μην χαθεί το momentum)
norm_roc = liq_roc
if use_norm
    roc_sma = ta.sma(liq_roc, norm_len)
    roc_std = ta.stdev(liq_roc, norm_len)
    // Προστασία από division by zero
    norm_roc := roc_std != 0 ? (liq_roc - roc_sma) / roc_std : 0

// Οι 3 ταχύτητες (Τρέχουν πάνω στο Normalized ROC)
fast_liq = ta.ema(norm_roc, fast_len)
med_liq  = ta.ema(norm_roc, med_len)
slow_liq = ta.ema(norm_roc, slow_len)

// ==============================================================================
// 4. TIME-SHIFT ENGINE (X-RAY ΜΕΛΛΟΝΤΟΣ)
// ==============================================================================
lookback = math.max(0, offset_bars)

fast_eval = fast_liq[lookback]
med_eval  = med_liq[lookback]
slow_eval = slow_liq[lookback]

// ==============================================================================
// 5. PHASE RECOGNITION 
// ==============================================================================
is_phase_1 = fast_eval > med_eval and med_eval <= slow_eval
is_phase_2 = fast_eval > med_eval and med_eval > slow_eval
is_phase_3 = fast_eval < med_eval and med_eval >= slow_eval
is_phase_4 = fast_eval < med_eval and med_eval < slow_eval

// ==============================================================================
// 6. PRICE CORRELATION
// ==============================================================================
price_roc = ta.roc(close, roc_len)
price_corr = ta.correlation(fast_eval, price_roc, corr_len)

// ==============================================================================
// 7. VISUALS & DASHBOARD
// ==============================================================================
bg_color = is_phase_2 ? color.new(color.green, 85) :
           is_phase_3 ? color.new(color.orange, 85) :
           is_phase_4 ? color.new(color.red, 85) :
           is_phase_1 ? color.new(color.blue, 85) : na
bgcolor(bg_color, title="Liquidity Phases")

hline(0, "Zero Line", color.gray, hline.style_dotted)

plot(fast_liq, title="Fast", color=color.green, linewidth=2, offset=offset_bars)
plot(med_liq, title="Medium", color=color.orange, linewidth=2, offset=offset_bars)
plot(slow_liq, title="Slow", color=color.red, linewidth=2, offset=offset_bars)

var table t = table.new(position.bottom_right, 1, 3, border_width = 1)
if barstate.islast
    phase_text = is_phase_1 ? "PHASE 1: IGNITION" :
                 is_phase_2 ? "PHASE 2: FULL THRUST" :
                 is_phase_3 ? "PHASE 3: ROTATION" :
                 is_phase_4 ? "PHASE 4: DROUGHT" : "TRANSITION"
                 
    phase_color = is_phase_1 ? color.blue :
                  is_phase_2 ? color.green :
                  is_phase_3 ? color.orange :
                  is_phase_4 ? color.red : color.gray
                  
    corr_color = price_corr > 0.7 ? color.green : 
                 price_corr < -0.7 ? color.red : color.gray

    table.cell(t, 0, 0, "MODE: " + calc_mode, text_color = color.white, bgcolor = color.black)
    table.cell(t, 0, 1, phase_text, text_color = color.white, bgcolor = phase_color)
    table.cell(t, 0, 2, "Corr (X-Ray): " + str.tostring(price_corr, "#.##"), text_color = color.white, bgcolor = corr_color)
````
