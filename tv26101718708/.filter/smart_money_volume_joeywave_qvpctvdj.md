# Smart Money Volume [JoeyWave]

- url: https://www.tradingview.com/script/qvpCtvdJ-Smart-Money-Volume-JoeyWave/
- type: indicator
- pine_id: PUB;9dc8520e13d44e2daa75a879c6ac8370
- version: 1.0

## Description

Smart Money Volume highlights statistically abnormal volume bars and quantifies real-time buy/sell pressure using two well-established methods from quantitative finance.

═══════════════════════════════
WHAT IT DOES
═══════════════════════════════

• Volume Panel — amber bars mark statistical outliers detected via Tukey's IQR method
• Pressure HUD (top-right) — shows current dominant side (BUY / SELL), pressure magnitude (%), and strength (WEAK / MODERATE / STRONG)

═══════════════════════════════
METHODOLOGY
═══════════════════════════════

1. Outlier Detection — Tukey's Interquartile Range
   threshold = Q3 + k × (Q3 − Q1)
   Default k = 2.0 ("extreme outlier" by Tukey's standard). This is robust to skewed volume distributions where mean/std-based methods fail.

2. Buy/Sell Classification — Bulk Volume Classification (BVC)
   Based on Easley, López de Prado, O'Hara (2012). Each bar's volume is split into buy/sell proportions using the normalized log-return:
       buy_fraction ≈ Φ(log_return / σ)
   where Φ is the standard normal CDF, approximated with a logistic function.

3. Aggregated Pressure
   Weighted buy and sell volumes are summed over the lookback window (default 20 bars). Pressure = buy_volume / total_volume.

═══════════════════════════════
HOW TO READ
═══════════════════════════════

• Amber bars   → unusual volume activity worth investigating
• HUD BUY ▲   → buyers dominant; check % for conviction
• HUD SELL ▼  → sellers dominant
• STRONG ≥ 65% → high conviction
• MODERATE ≥ 55% → moderate
• WEAK < 55% → indecisive, near equilibrium

═══════════════════════════════
HOW TO USE
═══════════════════════════════

• Confluence tool — confirm breakouts, reversals, or trend continuation when an outlier aligns with your setup
• Pressure HUD as a regime filter — only take long setups when HUD shows BUY MODERATE+, shorts when SELL MODERATE+
• Look for divergences — price making new highs while pressure flips to SELL is a classic exhaustion signal

═══════════════════════════════
SETTINGS
═══════════════════════════════

• IQR Lookback — bars used for percentile calculation (default 50)
• IQR Multiplier — 1.5 = standard outlier, 2.0 = extreme (default)
• BVC Sigma Window — return volatility window (default 50)
• Pressure Lookback — bars aggregated for the HUD (default 20)

═══════════════════════════════
REFERENCES
═══════════════════════════════

Easley, D., López de Prado, M., O'Hara, M. (2012) — "Flow Toxicity and Liquidity in a High Frequency World." Review of Financial Studies.

Tukey, J. W. (1977) — "Exploratory Data Analysis." Addison-Wesley.

═══════════════════════════════

Works on any symbol and timeframe with available volume data. Tested on FX (OANDA tick volume), futures, indices, and crypto.

Author: JoeyWave

## Source Code

````pine
//@version=5
// ╔══════════════════════════════════════════════════════════════════╗
// ║   Smart Money Volume [JoeyWave]                                  ║
// ║                                                                  ║
// ║  Volume panel:  amber bars = statistical outliers (Tukey IQR)    ║
// ║  Top-right HUD: current buy/sell pressure (BVC, last 20 bars)    ║
// ║                                                                  ║
// ║  Author: JoeyWave                                                ║
// ╚══════════════════════════════════════════════════════════════════╝
indicator("Smart Money Volume [JoeyWave]", "SM Volume", overlay=false)

// ========== INPUTS ==========
iqr_len    = input.int(50, "IQR Lookback", minval=20, maxval=300, group="Outlier")
iqr_mult   = input.float(2.0, "IQR Multiplier", minval=1.0, maxval=4.0, step=0.25, group="Outlier", tooltip="Tukey: 1.5 = outlier, 2.0 = extreme outlier (recommended).")
bvc_sigma  = input.int(50, "BVC Sigma Window", minval=10, maxval=200, group="Pressure")
press_len  = input.int(20, "Pressure Lookback", minval=5, maxval=100, group="Pressure", tooltip="Bars used to compute current buy/sell pressure.")
show_hud   = input.bool(true, "Show Pressure HUD", group="Display")
show_thresh = input.bool(true, "Show Threshold Line", group="Display")

// ========== OUTLIER (IQR) ==========
q1     = ta.percentile_nearest_rank(volume, iqr_len, 25)
q3     = ta.percentile_nearest_rank(volume, iqr_len, 75)
thresh = q3 + iqr_mult * (q3 - q1)
isOutlier = volume > thresh

// ========== BVC PRESSURE ==========
// Bulk Volume Classification (Easley, López de Prado, O'Hara 2012)
// buy_frac ≈ Φ(z) via logistic: 1 / (1 + exp(-1.7055 z))
lr       = math.log(close / nz(close[1], close))
lr_sigma = ta.stdev(lr, bvc_sigma)
z        = lr_sigma > 0 ? lr / lr_sigma : 0.0
buy_frac = 1.0 / (1.0 + math.exp(-1.7055 * z))

buy_vol  = volume * buy_frac
sell_vol = volume * (1.0 - buy_frac)
sum_buy  = math.sum(buy_vol, press_len)
sum_sell = math.sum(sell_vol, press_len)
total_v  = sum_buy + sum_sell
pressure = total_v > 0 ? sum_buy / total_v : 0.5

isBuyDom   = pressure > 0.5
displayPct = (isBuyDom ? pressure : 1.0 - pressure) * 100.0
strength   = displayPct >= 65 ? "STRONG" : displayPct >= 55 ? "MODERATE" : "WEAK"

// ========== COLORS ==========
C_OUTLIER = color.new(#FFB300, 0)    // amber  — abnormal volume
C_DIM     = color.new(#455A64, 50)   // slate  — normal volume
C_BUY     = #66BB6A                  // green
C_SELL    = #FFB74D                  // amber
C_BG      = color.new(#0D1117, 15)
C_TEXT    = color.new(color.white, 0)

volColor = isOutlier ? C_OUTLIER : C_DIM
sideColor = isBuyDom ? C_BUY : C_SELL

// ========== PLOTS ==========
plot(volume, "Volume", color=volColor, style=plot.style_columns)
plot(show_thresh ? thresh : na, "IQR Threshold", color=color.new(#EF5350, 60), linewidth=1)
plot(show_thresh ? ta.sma(volume, iqr_len) : na, "Avg Volume", color=color.new(color.white, 80), linewidth=1)

// ========== HUD ==========
sideTxt = isBuyDom ? "BUY ▲" : "SELL ▼"
hudTxt  = sideTxt + "  " + str.tostring(displayPct, "#.#") + "%  " + strength

var table hud = table.new(position.top_right, 1, 1, border_width=1, border_color=color.new(color.white, 70))
if show_hud and barstate.islast
    table.cell(hud, 0, 0, hudTxt, text_color=sideColor, text_size=size.normal, bgcolor=C_BG)

// ========== ALERTS ==========
alertcondition(isOutlier, "Volume Outlier", "Abnormal volume detected (IQR)")
alertcondition(isBuyDom and displayPct >= 65 and not isBuyDom[1], "Buy Pressure Strong", "Buy pressure flipped to STRONG")
alertcondition(not isBuyDom and displayPct >= 65 and isBuyDom[1], "Sell Pressure Strong", "Sell pressure flipped to STRONG")
````
