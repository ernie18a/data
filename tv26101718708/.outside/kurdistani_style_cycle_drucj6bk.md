# Kurdistani Style Cycle

- url: https://www.tradingview.com/script/DRuCJ6Bk-Kurdistani-Style-Cycle/
- type: indicator
- pine_id: PUB;8ab62d6e61e7435b82f190b5f834652e
- version: 1.0

## Description

Kurdistani Style Cycle

A composite on-chain indicator that identifies Bitcoin market cycle phases 
using a weighted Z-score of MVRV, NUPL, and a SOPR proxy. It maps market 
conditions into five distinct phases and overlays normalized BTC price.

═══════════════════════════════════════════════════
  KEY ON‑CHAIN METRICS USED
═══════════════════════════════════════════════════

1. MVRV (Market Value to Realized Value)
   MVRV = Market Cap / Realized Cap
   - High values: large unrealized profit, possible market tops.
   - Low values: large unrealized loss, possible market bottoms.

2. NUPL (Net Unrealized Profit/Loss)
   NUPL = 1 – (1 / MVRV)   (derived from MVRV to ensure consistency)
   - Strongly positive (e.g., >0.75): euphoria / overheated.
   - Negative: fear, potential bottoming zone.

3. SOPR Proxy
   Since real SOPR requires UTXO data unavailable on TradingView, a proxy 
   is built from price position relative to short-term and long-term 
   highest/lowest bands:
   
   Short-term position (STH):
     STH_pos = (Price – STH_low) / (STH_high – STH_low)   (range 0–1)
   Long-term position (LTH):
     LTH_pos = (Price – LTH_low) / (LTH_high – LTH_low)   (range 0–1)
   
   Raw SOPR Proxy = STH_pos – LTH_pos
   Smoothed SOPR Proxy = 5-period SMA of Raw SOPR Proxy

═══════════════════════════════════════════════════
  HOW THE COMPOSITE INDEX IS BUILT
═══════════════════════════════════════════════════

Step 1 – Z-Score Normalization
For each component (MVRV, NUPL, SOPR Proxy) a Z-score is calculated 
with a common lookback period L (default 365):
    Z = (Value – SMA(Value, L)) / StdDev(Value, L)

Step 2 – Weighted Combination (PnL Index)
User-defined weights w1, w2, w3 (default 0.4, 0.4, 0.2). 
If the fraction of non‑null components meets or exceeds the 
'Min Valid Weight Fraction' threshold, the PnL Index is:

PnL Index = (w1 * MVRV_Z + w2 * NUPL_Z + w3 * SOPR_Z) / (w1 + w2 + w3)

Step 3 – Bull‑Bear Indicator
The final oscillator removes the long-term trend using a simple moving 
average (default length 365):

Bull‑Bear = PnL Index – SMA(PnL Index, 365)

Positive values indicate a bullish regime relative to the long-term average, 
negative values indicate a bearish regime.

═══════════════════════════════════════════════════
  PHASES – THRESHOLDS & INTERPRETATION
═══════════════════════════════════════════════════

The Bull‑Bear value is classified into five phases using two thresholds:
  Overheated Threshold (default +1.5)
  Early Bull Upper Limit (default +0.5)
  Extreme Bear Threshold (default -1.5)

Phase                Condition                            Interpretation
─────────────────────────────────────────────────────────────────────────
Extreme Bear     Bull‑Bear ≤ -1.5                     Possible deep bottom, extreme fear
Bear             -1.5 < Bull‑Bear ≤ 0                 Downtrend / consolidation
Early Bull        0 < Bull‑Bear ≤ 0.5                 First signs of recovery
Bull             0.5 < Bull‑Bear ≤ 1.5                Healthy uptrend
Overheated Bull  Bull‑Bear > 1.5                      Euphoria, high risk of correction

Colors on the histogram:
  Extreme Bear    → solid blue
  Bear            → cyan / teal
  Early Bull      → green
  Bull            → orange
  Overheated Bull → red
  No data         → transparent gray

Small markers:
  A green dot above Early Bull columns
  A red dot below Overheated Bull columns

═══════════════════════════════════════════════════
  WHAT YOU SEE ON THE CHART
═══════════════════════════════════════════════════

• Gray line: the Bull‑Bear oscillator value.
• Colored columns: histogram displaying the current phase.
• Green horizontal line at zero (neutral boundary).
• Red dotted line at the Overheated Threshold (+1.5).
• Blue dotted line at the Extreme Bear Threshold (-1.5).
• Light gray/white line (optional): Z‑score of log(BTC price) 
  over the same lookback period, showing how far current price 
  deviates from its long‑term log mean.
• Information table (top‑right): shows live readings for Phase, 
  Bull‑Bear value, MVRV, NUPL, SOPR Proxy, BTC price, normalized 
  price Z‑score, and the composite PnL Index (Z).
• A star (*) next to a metric name and an orange warning dot 
  indicates stale (non‑updating) data, typically on intraday 
  timeframes where on‑chain data is not refreshed in real time.

A label on the last bar displays the current phase name.

═══════════════════════════════════════════════════
  INPUT SETTINGS (fully adjustable)
═══════════════════════════════════════════════════

- MA Length for Cycle (default 365): moving average length 
  used to extract the cycle from the PnL Index. Shorter 
  values increase responsiveness but add noise.
- Z‑Score Lookback (default 365): lookback for mean and 
  standard deviation when normalizing MVRV, NUPL, and SOPR.
- Overheated Bull Threshold (Z) (default 1.5): Z‑score level 
  that triggers the Overheated phase.
- Early Bull Upper Limit (Z) (default 0.5): upper bound of 
  the Early Bull phase; crossing above enters the Bull phase.
- Extreme Bear Threshold (Z) (default -1.5): lower bound for 
  the Extreme Bear phase.
- STH Lookback (default 155): period for short‑term high/low 
  in the SOPR proxy calculation.
- LTH Lookback (default 365): period for long‑term high/low 
  in the SOPR proxy calculation.
- MVRV Weight (default 0.4)
- NUPL Weight (default 0.4)
- SOPR Weight (default 0.2)
- Min Valid Weight Fraction (default 0.5): minimum fraction 
  of total weight that must have valid (non‑null) data for the 
  composite index to be calculated. Prevents unreliable signals 
  when one or more components are missing.
- Show Normalized BTC Price Overlay (true/false)
- Price Symbol (default BINANCE:BTCUSDT)
- Price Normalization Lookback (default 365)

═══════════════════════════════════════════════════
  DATA SOURCES & STALENESS
═══════════════════════════════════════════════════

• BTC_MARKETCAP (Market Cap) and BTC_MARKETCAPREAL (Realized 
  Cap) are fetched via request.security from TradingView’s 
  internal symbols. 
• Price is fetched from the user‑selected symbol (default 
  BINANCE:BTCUSDT).
• On intraday timeframes (less than 1D), on‑chain data often 
  does not update on every bar. In those cases a star (*) 
  appears next to the metric and an orange dot is plotted. 
  Daily or higher timeframes are recommended for the cleanest 
  signals.

═══════════════════════════════════════════════════
  PRACTICAL USAGE GUIDE
═══════════════════════════════════════════════════

- Accumulation / long‑term entries: Extreme Bear (blue columns) 
  often marks excellent long‑term buying zones.
- Confirmed trend change: Entering Early Bull (green columns) 
  after a bear phase provides a higher‑probability entry once 
  momentum turns positive.
- Holding during uptrend: Bull phase (orange) represents a 
  healthy market. Consider moving stop‑losses higher but 
  avoid premature exits.
- Taking profits / reducing exposure: Overheated Bull (red 
  columns) signals that the market is statistically stretched. 
  A phased exit or partial sell strategy is prudent.
- The normalized price overlay provides a second opinion: when 
  both the Bull‑Bear indicator and price Z‑score reach 
  simultaneous extremes, the signal is stronger.

═══════════════════════════════════════════════════
  LIMITATIONS
═══════════════════════════════════════════════════

• The SOPR component is a proxy and not real SOPR data.
• On lower timeframes, stale data may cause slight lag. 
• In long sideways markets the oscillator may whipsaw 
  between Bear and Early Bull. Always combine with other 
  technical or fundamental analysis.
• This indicator is not financial advice. Past performance 
  does not guarantee future results.

═══════════════════════════════════════════════════
  HOW TO INSTALL
═══════════════════════════════════════════════════

Add the indicator to your chart from TradingView’s “Indicators” 
panel. It will appear in a separate pane below the price chart. 
Adjust the settings via the gear icon to fit your own cycle 
analysis framework.

## Source Code

````pine
//@version=6
indicator('Kurdistani Style Cycle', overlay = false, max_bars_back = 5000)

// === Settings ===
len_ma = input.int(365, 'MA Length for Cycle', minval = 100)
z_len = input.int(365, 'Z-Score Lookback', minval = 60)
overheated_th = input.float(1.5, 'Overheated Bull Threshold (Z)')
early_bull_upper = input.float(0.5, 'Early Bull Upper Limit (Z)')
extreme_bear_th = input.float(-1.5, 'Extreme Bear Threshold (Z)')
sth_len = input.int(155, 'STH Lookback', minval = 30)
lth_len = input.int(365, 'LTH Lookback', minval = 100)
w_mvrv_in = input.float(0.4, 'MVRV Weight', minval = 0)
w_nupl_in = input.float(0.4, 'NUPL Weight', minval = 0)
w_sopr_in = input.float(0.2, 'SOPR Weight', minval = 0)
min_valid_weight = input.float(0.5, 'Min Valid Weight Fraction (0-1)', minval = 0, maxval = 1)
show_price = input.bool(true, 'Show Normalized BTC Price Overlay')
price_symbol = input.symbol('BINANCE:BTCUSDT', 'Price Symbol')
price_z_len = input.int(365, 'Price Normalization Lookback (log-return z-score)', minval = 60)

// ============================================
// 1. Receive data
// ============================================
marketCap = request.security('BTC_MARKETCAP', timeframe.period, close, ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
realizedCap = request.security('BTC_MARKETCAPREAL', timeframe.period, close, ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
btc_price = request.security(price_symbol, timeframe.period, close, ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
btc_high = request.security(price_symbol, timeframe.period, high, ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
btc_low = request.security(price_symbol, timeframe.period, low, ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
price_stale = na(btc_price)

// ============================================
// 2. MVRV / NUPL با fixnan
// ============================================
mvrv_raw = na(marketCap) or na(realizedCap) or realizedCap == 0 ? na : marketCap / realizedCap
mvrv = fixnan(mvrv_raw)
nupl_raw = na(mvrv) or mvrv == 0 ? na : 1 - 1 / mvrv
nupl = fixnan(nupl_raw)
mvrv_stale = na(mvrv_raw)

// ============================================
// 3. SOPR proxy — based on btc_price/high/low
// ============================================
btc_price_safe = fixnan(btc_price)
btc_high_safe = fixnan(btc_high)
btc_low_safe = fixnan(btc_low)

sth_high = ta.highest(btc_high_safe, sth_len)
sth_low = ta.lowest(btc_low_safe, sth_len)
lth_high = ta.highest(btc_high_safe, lth_len)
lth_low = ta.lowest(btc_low_safe, lth_len)

sth_pos = sth_high == sth_low ? 0.5 : (btc_price_safe - sth_low) / (sth_high - sth_low)
lth_pos = lth_high == lth_low ? 0.5 : (btc_price_safe - lth_low) / (lth_high - lth_low)
sopr_raw = sth_pos - lth_pos
sopr_proxy = ta.sma(sopr_raw, 5)

// ============================================
// 4. Z-Score
// ============================================
f_zscore(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    na(src) or na(m) or na(s) or s == 0 ? na : (src - m) / s

mvrv_z = f_zscore(mvrv, z_len)
nupl_z = f_zscore(nupl, z_len)
sopr_z = f_zscore(sopr_proxy, z_len)

// ============================================
// 5. Weighted combination
// ============================================
c_mvrv = na(mvrv_z) ? 0.0 : w_mvrv_in
c_nupl = na(nupl_z) ? 0.0 : w_nupl_in
c_sopr = na(sopr_z) ? 0.0 : w_sopr_in
w_sum = c_mvrv + c_nupl + c_sopr
w_total = w_mvrv_in + w_nupl_in + w_sopr_in
enough_data = w_total > 0 and w_sum / w_total >= min_valid_weight
pnl_index = enough_data ? (nz(mvrv_z) * c_mvrv + nz(nupl_z) * c_nupl + nz(sopr_z) * c_sopr) / w_sum : na

bull_bear = na(pnl_index) ? na : pnl_index - ta.sma(pnl_index, len_ma)

// ============================================
// Phases
// ============================================
is_overheated = not na(bull_bear) and bull_bear > overheated_th
is_bull = not na(bull_bear) and bull_bear > early_bull_upper and bull_bear <= overheated_th
is_early_bull = not na(bull_bear) and bull_bear > 0 and bull_bear <= early_bull_upper
is_bear = not na(bull_bear) and bull_bear <= 0 and bull_bear > extreme_bear_th
is_extreme_bear = not na(bull_bear) and bull_bear <= extreme_bear_th

col = is_overheated ? color.new(#FF0000, 15) : is_bull ? color.new(#FF8C00, 15) : is_early_bull ? color.new(#00C853, 15) : is_bear ? color.new(#00BCD4, 25) : is_extreme_bear ? color.new(#1565C0, 15) : color.new(color.gray, 60)

string phaseTxt = is_overheated ? 'Overheated Bull' : is_bull ? 'Bull' : is_early_bull ? 'Early Bull' : is_bear ? 'Bear' : is_extreme_bear ? 'Extreme Bear' : 'No Data'

// ============================================
// Main drawing
// ============================================
plot(bull_bear, 'Bull-Bear Indicator', color = color.gray, linewidth = 1)
plot(bull_bear, 'Phase Columns', style = plot.style_columns, color = col)

plotchar(is_early_bull, title = 'Early Bull Marker', char = '•', location = location.top, color = color.new(#00C853, 20), size = size.tiny)
plotchar(is_overheated, title = 'Overheated Marker', char = '•', location = location.bottom, color = color.new(#FF0000, 20), size = size.tiny)

hline(0, 'Zero Line', color = color.new(color.green, 0))
hline(overheated_th, 'Overheated', color = color.new(color.red, 50), linestyle = hline.style_dotted)
hline(extreme_bear_th, 'Extreme Bear', color = color.new(color.blue, 50), linestyle = hline.style_dotted)

// ============================================
// Normalized price — lighter color for better visibility on dark theme
// ============================================
log_price = na(btc_price) or btc_price <= 0 ? na : math.log(btc_price)
price_z_raw = f_zscore(log_price, price_z_len)

plot(show_price ? price_z_raw : na, 'BTC Price (Normalized Z)', color = color.new(#C9D1D9, 30), linewidth = 2)

// ============================================
// Phase label
// ============================================
var label phaseLbl = na
if barstate.islast
    label.delete(phaseLbl)
    if not na(bull_bear)
        phaseLbl := label.new(bar_index, bull_bear, phaseTxt, style = label.style_label_left, color = col, textcolor = color.white, size = size.normal)
        phaseLbl
    else
        float lastValid = ta.valuewhen(not na(bull_bear), bull_bear, 0)
        phaseLbl := label.new(bar_index, nz(lastValid, 0), 'No Data', style = label.style_label_left, color = color.gray, textcolor = color.white, size = size.normal)
        phaseLbl

// ============================================
// Data table — both actual + normalized price, modified star description
// ============================================
var table infoTable = table.new(position.top_right, 2, 9, bgcolor = color.new(color.black, 60), border_width = 1, border_color = color.new(color.gray, 40), frame_width = 1, frame_color = color.new(color.gray, 40))
if barstate.islast
    table.cell(infoTable, 0, 0, 'Metric', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 20))
    table.cell(infoTable, 1, 0, 'Value', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 20))

    table.cell(infoTable, 0, 1, 'Phase', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 1, phaseTxt, text_color = col, text_size = size.small)

    table.cell(infoTable, 0, 2, 'Bull-Bear', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 2, na(bull_bear) ? 'N/A' : str.tostring(bull_bear, '#.###'), text_color = col, text_size = size.small)

    table.cell(infoTable, 0, 3, 'MVRV' + (mvrv_stale ? ' *' : ''), text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 3, na(mvrv) ? 'N/A' : str.tostring(mvrv, '#.###'), text_color = mvrv_stale ? color.orange : color.white, text_size = size.small)

    table.cell(infoTable, 0, 4, 'NUPL', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 4, na(nupl) ? 'N/A' : str.tostring(nupl, '#.###'), text_color = color.white, text_size = size.small)

    table.cell(infoTable, 0, 5, 'SOPR Proxy', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 5, na(sopr_proxy) ? 'N/A' : str.tostring(sopr_proxy, '#.###'), text_color = color.white, text_size = size.small)

    table.cell(infoTable, 0, 6, 'BTC Price' + (price_stale ? ' *' : ''), text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 6, na(btc_price) ? 'N/A' : str.tostring(btc_price, '#.##'), text_color = price_stale ? color.orange : color.white, text_size = size.small)

    table.cell(infoTable, 0, 7, 'BTC Price (Z-norm)', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 7, na(price_z_raw) ? 'N/A' : str.tostring(price_z_raw, '#.###'), text_color = color.white, text_size = size.small)

    table.cell(infoTable, 0, 3, 'PnL Index (Z)', text_color = color.gray, text_size = size.small)
    table.cell(infoTable, 1, 3, na(pnl_index) ? 'N/A' : str.tostring(pnl_index, '#.###'), text_color = color.white, text_size = size.small)

show_stale_warning = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
plotchar(mvrv_stale and show_stale_warning, 'MVRV Stale', '•', location.top, color = color.orange, size = size.tiny)
````
