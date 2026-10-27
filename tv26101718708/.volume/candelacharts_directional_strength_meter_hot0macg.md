# CandelaCharts - Directional Strength Meter

- url: https://www.tradingview.com/script/hoT0MACg-CandelaCharts-Directional-Strength-Meter/
- type: indicator
- pine_id: PUB;0924d748de1a4e7baa415c019e13c309
- version: 1.0

## Description

📝 [b]Overview[/b]

The [b]CandelaCharts - Directional Strength Meter[/b] is an all-in-one momentum dashboard that combines two complementary analyses:

[b]1. Directional Component[/b] — Aggregates 11+ oscillators (RSI, MACD, MFI, CCI, TSI, RVI, Stoch, Williams %R, ROC, Momentum, CMO) into a single normalized consensus line that shows where price pressure is pointing right now (bullish/bearish bias).

[b]2. Environmental Quality Component[/b] — Measures trend strength and market structure (ATR, ADX, Linear Regression slope, Correlation) to confirm whether conditions are actually worth trading on the directional signal.

The directional line is color-graded (orange → purple → blue) and bounded around −1…+1. The shaded band marks that zone; moving beyond ±1 flags potential extremes. Optional divergence labels highlight classic bullish/bearish divergences and can be filtered to only show high-probability cases.

 📦 [b]Features[/b]

A quick tour of what Directional Strength Meter can do so you know exactly what’s under the hood.
[list]
[*] [b]Composite Directional Line[/b] — Normalizes 11 momentum oscillators to a single −1…+1 scale, showing consensus bullish/bearish pressure.
[*] [b]Environmental Quality Gauge[/b] — Combines volatility (ATR), trend strength (ADX), structure quality (Linear Regression), and alignment (Correlation) to separate strong setups from weak noise.
[*] [b]Visual Zones & Coloring[/b] — Orange (bearish) → Purple (neutral) → Blue (bullish) gradient shows momentum direction and intensity. The shaded −1…+1 band marks "normal" range; moves beyond ±1 highlight extremes and potential exhaustion.
[*] [b]Configurable Mix[/b] — Toggle which directionals participate; add optional EMA/KAMA/etc. of the oscillator for signal smoothing.
[*] [b]Divergence Detection[/b] — Spots classic regular bullish (lower low price, higher low oscillator) and bearish (higher high price, lower high oscillator) divergences on the directional line. Optional high-probability filter ensures at least one pivot sits outside ±1 for added confidence.
[*] [b]Clean Alerts[/b] — Buy/Sell crosses with environmental quality gates, plus divergence alerts.
[*] [b]Workflow-Friendly[/b] — Thresholds, lengths, smoothing, and correlation window are all adjustable to suit scalps or swings.
[/list]

 ⚙️ [b]Settings[/b]

Tune the inputs and thresholds to match your asset, timeframe, and risk tolerance—without overcomplicating things.
[b]Settings (Core)[/b]
[list]
[*] [b]Plot Directionals MA?[/b] — Overlays a moving average of the main oscillator (not price). Helpful for crossover-style entries.
[*] [b]Directional MA / Color / Length[/b] — Choose EMA/SMA/SMMA/WMA/VWMA/HMA/ALMA; pick color and period.
[*] [b]Overall Length[/b] — Master multiplier applied to many directional lengths. Higher = smoother/slower; lower = snappier.
[*] [b][−1,1] Buy/Sell[/b] — Global quality threshold for environmental quality filter (default −0.25). Only trigger Buy/Sell when conditions meet/beat this line.
[*] [b]Sell / Buy Threshold[/b] — Levels that the alert source must cross for signals (defaults +1.25 / −1.25).
[*] [b]Correlation Length[/b] — Lookback used for nondirectional correlation coloring (informational).
[*] [b]Smoothing[/b] — Optional EMA smoothing of the composite (length configurable).
[/list]
[b]Directionals (what goes into the Directional Strength Meter head)[/b]
[list]
[*] [b]RSI / MFI[/b] — Core oscillators for momentum & volume-flow tilt.
[*] [b]MACD / CCI / TSI[/b] — Trend and momentum blend, normalized to the −1…+1 consensus scale.
[*] [b]RVI[/b] — Volatility-weighted directional pressure.
[*] [b]Stoch %K / Williams %R[/b] — Mean-reversion signals normalized into the consensus blend.
[*] [b]ROC / Momentum / CMO[/b] — Raw speed and directional burst.
[*] [b]Lengths[/b] — Each has a base length; many are multiplied by the Overall Length for fast/slow presets.
[/list]
[b]Nondirectionals (quality & structure)[/b]
[list]
[*] [b]ATR[/b] — Volatility expansion vs baseline.
[*] [b]ADX[/b] — Trend strength vs baseline.
[*] [b]Linear Regression Strength[/b] — Measures slope consistency.
[*] [b]Abs Correlation[/b] — How cleanly price aligns over time.
[*] [b]Plot Nondirectionals[/b] — Show the averaged nondirectional line and color it by ATR/ADX correlation level.
[/list]
[b]Divergence[/b]
[list]
[*] [b]Divergences[/b] — Enable regular bullish (LL price, HL oscillator) / bearish (HH price, LH oscillator).
[*] [b]Pivot Length Left/Right[/b] — Sensitivity of pivot finding.
[*] [b]Only show High-Prob[/b] — Require that the current or previous oscillator pivot sat outside the ±1 band (filters weak signals).
[*] [b]Colors / Label Text Color[/b] — Visual tweaks.
[/list]
[b]Alerts[/b]
[list]
[*] [b]Alert Condition[/b] — Choose “Directional Source” (raw Directional Strength Meter) or “Directional EMA” (Directional Strength Meter MA) as the crossing source. If you pick EMA, consider using ±1 for Buy/Sell thresholds.
[/list]

 ⚡️ [b]Showcase[/b]

[i]Main Line[/i]
https://www.tradingview.com/x/c8IsCuHs/

[i]Divergences[/i]
https://www.tradingview.com/x/b2KmDt3l/

[i]Directional & Non-directional[/i]
https://www.tradingview.com/x/jMsHLn1v/

[i]Moving Average[/i]
https://www.tradingview.com/x/Cq7dHrEL/

 📒 [b]Usage[/b]

Learn how to read the directional and nondirectional lines and turn them into clear, repeatable trade decisions.
[list]
[*] [b]Read the Bias[/b] — Above 0 = bullish tilt; below 0 = bearish tilt. Color fades → build/decay in momentum.
[*] [b]Use the Gates[/b] — A Buy/Sell alert fires only if: (1) the directional line (or its MA) crosses your Buy/Sell threshold, [i]and[/i] (2) environmental quality is at/above your filter.
[*] [b]Respect the Band[/b] — ±1 marks "stretched" momentum states. Sustained moves beyond +1 often signal trend continuation; quick rejections may warn of exhaustion. Mirror logic applies to −1 (bearish side).
[*] [b]Divergences[/b] — Bullish (lower lows in price, higher lows in oscillator) often precedes rallies; Bearish (higher highs in price, lower highs in oscillator) often precedes drops. High-Prob filter focuses on turns anchored by true extremes (outside ±1).
[*] [b]Timeframe Tips[/b] — The indicator adapts well from intraday to swing. Increase Overall Length + Smoothing for higher TFs; do the opposite for LTFs.
[*] [b]Confluence[/b] — Best used alongside price structure (support/resistance, HTF trend bias), volume, and risk management. Treat the directional line as the momentum engine; use price action and levels to confirm entry/exit timing.
[/list]

 🚨 [b]Alerts[/b]

Set up Buy/Sell and divergence alerts and know precisely when and why each alert fires.
[list]
[*] [b]Buy Signal[/b] — Fires when the directional line (or its MA) [i]crosses above[/i] the Buy Threshold (default −1.25) [i]and[/i] environmental quality ≥ filter (default −0.25).
[*] [b]Sell Signal[/b] — Fires when the directional line (or its MA) [i]crosses below[/i] the Sell Threshold (default +1.25) [i]and[/i] environmental quality ≥ filter.
[*] [b]Regular Bullish/Bearish Divergence[/b] — Optional alerts for classic divergences on the composite. With “Only High-Prob” ON, at least one oscillator pivot must be outside ±1.
[*] [b]Setup Tip[/b] — If you set [i]Alert Condition[/i] to “Directional EMA,” consider thresholds near −1 / +1 for cleaner MA cross behavior.
[/list]

 ⚠️ [b]Disclaimer[/b]

Trading involves significant risk, and many participants may incur losses. The content on this site is not intended as financial advice and should not be interpreted as such. Decisions to buy, sell, hold, or trade securities, commodities, or other financial instruments carry inherent risks and are best made with guidance from qualified financial professionals. Past performance is not indicative of future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CandelaCharts

//@version=6
indicator(title = "CandelaCharts - Directional Strength Meter", shorttitle = "CandelaCharts - Directional Strength Meter", overlay = false)











// # ========================================================================= #
// # |   Colors   |
// # ========================================================================= #

//#region

// # Core -------------------------------------------------------------------- #

colors_white                        = color.white
colors_black                        = color.black
colors_purple                       = color.purple
colors_red                          = color.red
colors_gray                         = color.gray
colors_blue                         = color.blue
colors_orange                       = color.orange
colors_green                        = color.green
color_transparent                   = #ffffff00

// # Custom ------------------------------------------------------------------ #

colors_cyan_dark                    = #089981
colors_red_bright                   = #f23645
colors_purple_dark                  = #7E57C2

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Inputs   |
// # ========================================================================= #

//#region

// # General ----------------------------------------------------------------- #

general_font                            = input.string("Monospace", "Text                   ", options = ["Default", "Monospace"], inline = "1.0", group = "General")
general_text                            = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], inline = "1.0", group = "General", tooltip = "Customize global text size and style")
general_brand_show                      = input.bool(false, "Hide Brand", group = "General")

hm_ma_show                              = input.bool(false, "Plot Directionals MA?", inline = "1.0", group = "Settings")
hm_ma_type                              = input.string("EMA", "Directional MA    ", inline = "2.0", group = "Settings", options = ["EMA","SMA","SMMA (RMA)","WMA","VWMA","HMA","ALMA"])
hm_ma_color                             = input.color(color.gray, "", inline = "2.0", group = "Settings")
hm_ma_length                            = input.int(14, "MA Length         ", inline = "3.0", group = "Settings")
hm_overall_length                       = input.int(3, "Overall Length    ", inline = "4.0", group = "Settings")
hm_filter_nd                            = input.float(-0.25,"[-1,1] Buy/Sell    ", inline = "5.0", group = "Settings", tooltip = "Buy/Sell Threshold")
hm_filter_d_sell                        = input.float(1.25, "Sell Threshold    ", inline = "6.0", group = "Settings")
hm_filter_d_buy                         = input.float(-1.25,"Buy Threshold    ", inline = "7.0", group = "Settings")
hm_correlation_length                   = input.int(50, "Correlation         ", inline = "8.0", group = "Settings", tooltip = "Correlation Length")
hm_smooth_enable                        = input.bool(false, "Smoothing  ", inline = "9.0", group = "Settings")
hm_smooth_length                        = input.int(3, "", minval = 1, inline = "9.0", group = "Settings")

hm_plot_dir                             = input.bool(true,  "Plot Directionals",  inline = "0.0", group = "Directionals")
hm_rsi_show                             = input.bool(true,  "RSI            ",  inline = "1.0", group = "Directionals")
hm_rsi_length                           = input.int(14, "", inline = "1.0", group = "Directionals")
hm_mfi_show                             = input.bool(true,  "MFI            ",  inline = "2.0", group = "Directionals")
hm_mfi_length                           = input.int(14, "", inline = "2.0", group = "Directionals")
hm_macd_show                            = input.bool(true,  "MACD        ", inline = "3.0", group = "Directionals")
hm_macd_length                          = input.int(12, "", inline = "3.0", group = "Directionals")
hm_cci_show                             = input.bool(true,  "CCI            ",  inline = "4.0", group = "Directionals")
hm_cci_length                           = input.int(20, "", inline = "4.0", group = "Directionals")
hm_tsi_show                             = input.bool(true,  "TSI             ",  inline = "5.0", group = "Directionals")
hm_tsi_length                           = input.int(13, "", inline = "5.0", group = "Directionals")
hm_rvi_show                             = input.bool(true,  "RVI             ",  inline = "6.0", group = "Directionals")
hm_rvi_length                           = input.int(10, "", inline = "6.0", group = "Directionals")
hm_stoch_show                           = input.bool(true,  "Stoch %K    ", inline = "7.0", group = "Directionals")
hm_stoch_length                         = input.int(14, "", inline = "7.0", group = "Directionals")
hm_wpr_show                             = input.bool(true,  "Williams %R", inline = "8.0", group = "Directionals")
hm_wpr_length                           = input.int(14, "", inline = "8.0", group = "Directionals")
// hm_dmi_dir_show                         = input.bool(false,  "+DI/−DI       ", inline = "9.0", group = "Directionals")
// hm_dmi_length                           = input.int(14, "", inline = "9.0", group = "Directionals")
hm_roc_show                             = input.bool(true,  "ROC            ", inline = "11.0", group = "Directionals")
hm_roc_length                           = input.int(9, "", inline = "11.0", group = "Directionals")
hm_mom_show                             = input.bool(true,  "Momentum  ", inline = "12.0", group = "Directionals")
hm_mom_length                           = input.int(10, "", inline = "12.0", group = "Directionals")
hm_cmo_show                             = input.bool(true,  "CMO           ", inline = "13.0", group = "Directionals")
hm_cmo_length                           = input.int(14, "", inline = "13.0", group = "Directionals")
// hm_obv_show                             = input.bool(false,  "OBV            ", inline = "14.0", group = "Directionals")
// hm_obv_length                           = input.int(50, "", inline = "14.0", group = "Directionals")

hm_plot_non_dir                         = input.bool(false, "Plot Nondirectionals", inline = "0.0", group = "Nondirectionals")
hm_plot_non_dir_color                   = input.color(color.yellow, "", inline = "0.0", group = "Nondirectionals")
hm_atr_show                             = input.bool(true, "ATR            ", inline = "1.0", group = "Nondirectionals")
hm_atr_length                           = input.int(14, "", inline = "1.0", group = "Nondirectionals")
hm_adx_show                             = input.bool(true, "ADX            ", inline = "2.0", group = "Nondirectionals")
hm_adx_length                           = input.int(14, "", inline = "2.0", group = "Nondirectionals")
hm_linreg_show                          = input.bool(true, "LinReg        ", inline = "3.0", group = "Nondirectionals", tooltip = "LinReg Strength")
hm_linreg_length                        = input.int(50, "", inline = "3.0", group = "Nondirectionals")
hm_corr_show                            = input.bool(true, "Abs Correl   ", inline = "4.0", group = "Nondirectionals", tooltip = "Abs Correlation")
hm_corr_length                          = input.int(50, "", inline = "4.0", group = "Nondirectionals")

hm_div_calc                             = input.bool(false,  "Divergences", inline = "1.0", group = "Divergence", display = display.data_window, tooltip = "Enable to compute regular bullish/bearish divergences on the aggregated oscillator.")
hm_div_bull_color                       = input.color(color.blue, "", inline = "1.0", group = "Divergence")
hm_div_bear_color                       = input.color(color.orange, "", inline = "1.0", group = "Divergence")
hm_div_lookback_right                   = input.int(5, "Pivot Length Right", minval = 1, inline = "2.0", group = "Divergence", display = display.data_window)
hm_lookback_left                        = input.int(5, "Pivot Length Left  ", minval = 1, inline = "3.0", group = "Divergence", display = display.data_window)
// hm_range_upper                          = input.int(60, "Bars Upper          ", minval = 1, inline = "4.0", group = "Divergence", display = display.data_window, tooltip = "Bars Window Upper")
// hm_range_lower                          = input.int(5, "Bars Lower          ", minval = 1, inline = "5.0", group = "Divergence", display = display.data_window, tooltip = "Bars Window Lower")
hm_label_text_color                     = input.color(color.white, "Label Text Color   ", inline = "6.0", group = "Divergence")
hm_div_filter_highprob                  = input.bool(true, "Only show High-Prob", inline = "7.0", group = "Divergence", tooltip = "Filters divergences so that at least one oscillator pivot anchor (current or previous) is outside the [-1, 1] band.")

hm_alert_condition                      = input.string("Directional Source", "Alert Condition", options = ["Directional EMA", "Directional Source"], group = "Alerts", tooltip = "Changing this to 'Directional EMA' might mean you want to change the Directional Buy/Sell thresholds to -1 and 1.")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #












// # ========================================================================= #
// # |   Functions   |
// # ========================================================================= #

//#region

text_size(size) =>
    switch size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.auto

font_family(font) =>
    switch font
        "Default"   => font.family_default
        "Monospace" => font.family_monospace

f_normalize(x, hi, lo) =>
    x > 0 ? x / hi : x < 0 ? x / math.abs(lo) : 0

ma_for(type, src, len) =>
    switch type
        "SMA"        => ta.sma(src, len)
        "EMA"        => ta.ema(src, len)
        "SMMA (RMA)" => ta.rma(src, len)
        "WMA"        => ta.wma(src, len)
        "VWMA"       => ta.vwma(src, len)
        "HMA"        => ta.hma(src, len)
        "ALMA"       => ta.alma(src, len, 0.85, 6)
        => ta.ema(src, len)  // fallback

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #













// # ========================================================================= #
// # |   Directional Components   |
// # ========================================================================= #

//#region

rsi_norm = (ta.rsi(close, hm_rsi_length) - 50.0) / 20.0
mfi_norm = (ta.mfi(close, hm_mfi_length) - 50.0) / 20.0

[macd_raw, _, _] = ta.macd(close, hm_macd_length * hm_overall_length, hm_macd_length * 2 * hm_overall_length, 9)
macd_hi = ta.highest(macd_raw, hm_macd_length * hm_overall_length)
macd_lo = ta.lowest(macd_raw,  hm_macd_length * hm_overall_length)
macd_norm = f_normalize(macd_raw, macd_hi, macd_lo)

cci_norm = ta.cci(close, hm_cci_length * hm_overall_length) / 100.0

tsi_raw = ta.tsi(close, hm_tsi_length * hm_overall_length, hm_tsi_length * 2 * hm_overall_length)
tsi_hi  = ta.highest(tsi_raw, hm_tsi_length * hm_overall_length)
tsi_lo  = ta.lowest(tsi_raw,  hm_tsi_length * hm_overall_length)
tsi_norm = f_normalize(tsi_raw, tsi_hi, tsi_lo)

// // RVI (ratio of up/down std dev), mapped to [-1, 1]
// src = close
// len = 14
// stddev = ta.stdev(src, hm_rvi_length * hm_overall_length)
// upper  = ta.ema(ta.change(src) <= 0 ? 0 : stddev, len)
// lower  = ta.ema(ta.change(src) >  0 ? 0 : stddev, len)
// rvi_norm = ((upper / (upper + lower) * 100.0) - 50.0) / 20.0

// RVI (ratio of up/down std dev), mapped to [-1, 1]
rvi_len = hm_rvi_length * hm_overall_length
rvi_sd  = ta.stdev(close, rvi_len)
rvi_up  = ta.ema(ta.change(close) <= 0 ? 0 : rvi_sd, rvi_len)
rvi_dn  = ta.ema(ta.change(close) >  0 ? 0 : rvi_sd, rvi_len)
rvi_norm = ((rvi_up / (rvi_up + rvi_dn) * 100.0) - 50.0) / 20.0

// Stochastic %K (0..100) → [-1..1]
stoch_len    = hm_stoch_length * hm_overall_length
stoch_k_raw  = ta.stoch(high, low, close, stoch_len)
stoch_k      = ta.sma(stoch_k_raw, 3)
stoch_norm   = (stoch_k - 50.0) / 50.0

// Williams %R (-100..0) → [-1..1]
wpr_len   = hm_wpr_length * hm_overall_length
wpr_raw   = ta.wpr(wpr_len)
wpr_norm  = (wpr_raw + 50.0) / 50.0

// +DI / −DI (0..100) → [-1..1]
// [dmi_plus, dmi_minus, _d_adx_ignore] = ta.dmi(17, hm_dmi_length)
// [dmi_plus, dmi_minus, _] = ta.dmi(hm_dmi_length * hm_overall_length, hm_dmi_length * hm_overall_length)
// dmi_dir_norm = (dmi_plus - dmi_minus) / 100.0

// Rate of Change (unbounded) → normalized signed
roc_len  = hm_roc_length * hm_overall_length
roc_raw  = ta.roc(close, roc_len)
roc_hi   = ta.highest(roc_raw, roc_len)
roc_lo   = ta.lowest(roc_raw,  roc_len)
roc_norm = f_normalize(roc_raw, roc_hi, roc_lo)

// Momentum (unbounded) → normalized signed
mom_len  = hm_mom_length * hm_overall_length
mom_raw  = ta.mom(close, mom_len)
mom_hi   = ta.highest(mom_raw, mom_len)
mom_lo   = ta.lowest(mom_raw,  mom_len)
mom_norm = f_normalize(mom_raw, mom_hi, mom_lo)

// Chande Momentum Oscillator (-100..100) → [-1..1]
cmo_len  = hm_cmo_length * hm_overall_length
cmo_norm = ta.cmo(close, cmo_len) / 100.0

// // OBV (cumulative, unbounded) → normalized signed
// obv_win  = hm_obv_length * hm_overall_length
// obv_raw  = ta.obv
// obv_hi   = ta.highest(obv_raw, obv_win)
// obv_lo   = ta.lowest(obv_raw,  obv_win)
// obv_norm = f_normalize(obv_raw, obv_hi, obv_lo)

// A) Main oscillator (affected by checkboxes)
dir_sum = 0.0
dir_n   = 0
if hm_rsi_show
    dir_sum += rsi_norm
    dir_n += 1
if hm_mfi_show
    dir_sum += mfi_norm
    dir_n += 1
if hm_macd_show
    dir_sum += macd_norm
    dir_n += 1
if hm_cci_show
    dir_sum += cci_norm
    dir_n += 1
if hm_tsi_show
    dir_sum += tsi_norm
    dir_n += 1
if hm_rvi_show
    dir_sum += rvi_norm
    dir_n += 1
if hm_stoch_show
    dir_sum += stoch_norm
    dir_n += 1
if hm_wpr_show
    dir_sum += wpr_norm
    dir_n += 1
// if hm_dmi_dir_show
//     dir_sum += dmi_dir_norm
//     dir_n += 1
if hm_roc_show
    dir_sum += roc_norm
    dir_n += 1
if hm_mom_show
    dir_sum += mom_norm
    dir_n += 1
if hm_cmo_show
    dir_sum += cmo_norm
    dir_n += 1
// if hm_obv_show
//     dir_sum += obv_norm
//     dir_n += 1

super_dir = dir_n > 0 ? dir_sum / dir_n : 0.0
signal = ta.sma(super_dir, 5)

// Main oscillator after optional smoothing (EMA-based)
super_main = hm_smooth_enable ? ta.ema(super_dir, hm_smooth_length) : super_dir

// B) Divergence oscillator (ALWAYS includes all components; NOT affected by checkboxes)
super_dir_div = (rsi_norm + mfi_norm + macd_norm + cci_norm + tsi_norm + rvi_norm) / 6.0

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #













// # ========================================================================= #
// # |   Nondirectional Components   |
// # ========================================================================= #

//#region

atr_raw  = ta.atr(hm_atr_length)
atr_sd   = ta.stdev(atr_raw, hm_atr_length)
atr_ema  = ta.ema(atr_raw, hm_atr_length)
atr_norm = ((atr_raw / atr_ema) - 1.0) * (1.0 + atr_sd) - 1.0

// [_, _, adx_raw] = ta.dmi(17, hm_adx_length)
[_, _, adx_raw] = ta.dmi(hm_adx_length * hm_overall_length, hm_adx_length  * hm_overall_length)
adx_sd   = ta.stdev(adx_raw, hm_adx_length)
adx_ema  = ta.ema(adx_raw, hm_adx_length)
adx_norm = ((adx_raw / adx_ema) - 1.0) * (1.0 + adx_sd)

// Linear Regression "strength" (slope magnitude) → zero-centered normalized
lrs_len   = hm_linreg_length
lrs_now   = ta.linreg(close, lrs_len, 0)
lrs_prev  = ta.linreg(close, lrs_len, 1)
lrs_slope = math.abs(lrs_now - lrs_prev)
lrs_sd    = ta.stdev(lrs_slope, lrs_len)
lrs_ema   = ta.ema(lrs_slope, lrs_len)
lrs_norm  = ((lrs_slope / lrs_ema) - 1.0) * (1.0 + lrs_sd) - 1.0

// |Correlation(price, time)| → zero-centered normalized
corr_len   = hm_corr_length
corr_abs   = math.abs(ta.correlation(close, float(bar_index), corr_len))
corr_sd    = ta.stdev(corr_abs, corr_len)
corr_ema   = ta.ema(corr_abs, corr_len)
corr_norm  = ((corr_abs / corr_ema) - 1.0) * (1.0 + corr_sd) - 1.0

// Aggregate nondirectional (equal-weight over enabled)
nd_sum = 0.0
nd_n   = 0
if hm_atr_show
    nd_sum += atr_norm
    nd_n += 1
if hm_adx_show
    nd_sum += adx_norm
    nd_n += 1
if hm_linreg_show
    nd_sum += lrs_norm
    nd_n += 1
if hm_corr_show
    nd_sum += corr_norm
    nd_n += 1

super_non_dir_rough = nd_n > 0 ? nd_sum / nd_n : 0.0
non_dir_hi = ta.highest(super_non_dir_rough, 200)
non_dir_lo = ta.lowest(super_non_dir_rough,  200)
super_nondir = f_normalize(super_non_dir_rough, non_dir_hi, non_dir_lo)

// Correlation-based coloring (only if both enabled)
correlation_nondir = (hm_atr_show and hm_adx_show) ? ta.correlation(atr_norm, adx_norm, hm_correlation_length) : na
col_nondir = na(correlation_nondir) ? color.new(hm_plot_non_dir_color, 50) :
             correlation_nondir >= .75 ? color.new(hm_plot_non_dir_color, 35) :
             correlation_nondir >= .66 ? color.new(hm_plot_non_dir_color, 40) :
             correlation_nondir >= .50 ? color.new(hm_plot_non_dir_color, 45) :
                                         color.new(hm_plot_non_dir_color, 50)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #













// # ========================================================================= #
// # |   Baselines & Band   |
// # ========================================================================= #

//#region

hline(0)
hl_top = hline(1)
hl_bot = hline(-1)

// Gradient color for the main line (two 5-arg calls, split at 0)
bear_c = color.orange
mid_c  = color.purple
bull_c = color.blue
dir_grad_color = super_main >= 0 ? color.from_gradient(super_main, 0.0,  1.0, mid_c,  bull_c) : color.from_gradient(super_main, -1.0, 0.0, bear_c, mid_c)

// Visible directional plot (gradient-colored)
dir_plot_visible = plot(hm_plot_dir ? super_main : na, color = dir_grad_color, title = "Directional Jumper", linewidth = 2)

// Keep band shading inside [-1, 1]
fill(hl_top, hl_bot, color.new(color.gray, 95))

// Hidden plots for gradient zone fills
dir_plot_fill = plot(super_main, color = na, display = display.none, title = "Directional Hidden (Fill)")
thresh_top    = plot(1, color = na, display = display.none, title = "Threshold +1 (Fill)")
thresh_bot    = plot(-1, color = na, display = display.none, title = "Threshold -1 (Fill)")

plot(hm_plot_non_dir ? super_nondir : na, title = "Nondirectional Average", color = col_nondir)

// Directional MA of the source (based on MAIN line; supports multiple MA types)
dir_ma = ma_for(hm_ma_type, super_main, hm_ma_length)
plot(hm_ma_show ? dir_ma : na, color = hm_ma_color, title = "Directional MA", linewidth = 1)

// Gradient fills for > +1 and < -1 zones
ob_top_color    = super_main > 1 ? color.new(color.blue,   0)  : na
ob_bottom_color = super_main > 1 ? color.new(color.blue,  90)  : na
fill(dir_plot_fill, thresh_top,  top_color = ob_top_color, bottom_color = ob_bottom_color, title = "Overbought Gradient Fill")

os_top_color    = super_main < -1 ? color.new(color.orange,  0) : na
os_bottom_color = super_main < -1 ? color.new(color.orange, 90) : na
fill(dir_plot_fill, thresh_bot,  top_color = os_top_color, bottom_color = os_bottom_color, title = "Oversold Gradient Fill")

zone_bg = super_main > 1 ? color.new(color.blue, 85) :
          super_main < -1 ? color.new(color.orange, 85) :
                           na
bgcolor(zone_bg)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #














// # ========================================================================= #
// # |   Divergences   |
// # ========================================================================= #

//#region

range_uper  = 60
range_lower = 5

hd_in_range(cond) =>
    bars = ta.barssince(cond)
    range_lower <= bars and bars <= range_uper

var bool hd_plFound   = false
var bool hd_phFound   = false
var bool hd_bullCond  = false
var bool hd_bearCond  = false

superLBR_div = super_main[hm_div_lookback_right]

if hm_div_calc
    // Regular Bullish: Price LL, Oscillator HL at pivot lows
    hd_plFound := not na(ta.pivotlow(super_main, hm_lookback_left, hm_div_lookback_right))
    oscHL      = superLBR_div > ta.valuewhen(hd_plFound, superLBR_div, 1) and hd_in_range(hd_plFound[1])
    lowLBR     = low[hm_div_lookback_right]
    priceLL    = lowLBR < ta.valuewhen(hd_plFound, lowLBR, 1)
    hd_bullCond := priceLL and oscHL and hd_plFound

    // Regular Bearish: Price HH, Oscillator LH at pivot highs
    hd_phFound := not na(ta.pivothigh(super_main, hm_lookback_left, hm_div_lookback_right))
    oscLH      = superLBR_div < ta.valuewhen(hd_phFound, superLBR_div, 1) and hd_in_range(hd_phFound[1])
    highLBR    = high[hm_div_lookback_right]
    priceHH    = highLBR > ta.valuewhen(hd_phFound, highLBR, 1)
    hd_bearCond := priceHH and oscLH and hd_phFound

// --- High-probability filter: at least one oscillator anchor outside [-1, 1]
prevOscBull = ta.valuewhen(hd_plFound, superLBR_div, 1)
prevOscBear = ta.valuewhen(hd_phFound, superLBR_div, 1)

bull_has_extreme = (math.abs(superLBR_div) > 1) or (not na(prevOscBull) and math.abs(prevOscBull) > 1)
bear_has_extreme = (math.abs(superLBR_div) > 1) or (not na(prevOscBear) and math.abs(prevOscBear) > 1)

hd_bullFinal = hm_div_filter_highprob ? (hd_bullCond and bull_has_extreme) : hd_bullCond
hd_bearFinal = hm_div_filter_highprob ? (hd_bearCond and bear_has_extreme) : hd_bearCond

divNoneColor = color.new(color.white, 100)

// Plots (use filtered conditions)
plot(
     hd_plFound ? superLBR_div : na,
     offset    = -hm_div_lookback_right,
     title     = "DSM Regular Bullish (Osc)",
     linewidth = 2,
     color     = (hd_bullFinal ? hm_div_bull_color : divNoneColor),
     display   = display.pane,
     editable  = hm_div_calc)

plotshape(
     hd_bullFinal ? superLBR_div : na,
     offset    = -hm_div_lookback_right,
     title     = "DSM Regular Bullish Label",
     text      = " Bull ",
     style     = shape.labelup,
     location  = location.absolute,
     color     = hm_div_bull_color,
     textcolor = hm_label_text_color,
     display   = display.pane,
     editable  = hm_div_calc)

plot(
     hd_phFound ? superLBR_div : na,
     offset    = -hm_div_lookback_right,
     title     = "DSM Regular Bearish (Osc)",
     linewidth = 2,
     color     = (hd_bearFinal ? hm_div_bear_color : divNoneColor),
     display   = display.pane,
     editable  = hm_div_calc)

plotshape(
     hd_bearFinal ? superLBR_div : na,
     offset    = -hm_div_lookback_right,
     title     = "DSM Regular Bearish Label",
     text      = " Bear ",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = hm_div_bear_color,
     textcolor = hm_label_text_color,
     display   = display.pane,
     editable  = hm_div_calc)

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #














// # ========================================================================= #
// # |   Alerts   |
// # ========================================================================= #

//#region

alert_switch = hm_alert_condition == "Directional Source" ? super_main : dir_ma
buy_signal  = ta.crossover(alert_switch, hm_filter_d_buy)   and super_nondir >= hm_filter_nd
sell_signal = ta.crossunder(alert_switch, hm_filter_d_sell) and super_nondir >= hm_filter_nd

alertcondition(buy_signal,  "DSM Oscillator Buy Signal")
alertcondition(sell_signal, "DSM Oscillator Sell Signal")

// Divergence Alerts (on DSM oscillator fixed set)
// alertcondition(hd_bullCond, title = "DSM Regular Bullish Divergence", message = "DSM: Regular Bullish Divergence found (oscillator vs price).")
// alertcondition(hd_bearCond, title = "DSM Regular Bearish Divergence", message = "DSM: Regular Bearish Divergence found (oscillator vs price).")
alertcondition(hd_bullFinal, title = "DSM Regular Bullish Divergence", message = "DSM: Regular Bullish Divergence found (oscillator vs price).")
alertcondition(hd_bearFinal, title = "DSM Regular Bearish Divergence", message = "DSM: Regular Bearish Divergence found (oscillator vs price).")

//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #













// # ========================================================================= #
// # |   Brand Label   |
// # ========================================================================= #

//#region

if barstate.isfirst and not general_brand_show
    var table brand_table = table.new(position.bottom_right, 1, 1, bgcolor=chart.bg_color)
    table.cell(brand_table, 0, 0, "© CandelaCharts", text_color=color.new(colors_gray, 30),
               text_halign=text.align_center, text_size=text_size(general_text),
               text_font_family=font_family(general_font))
//#endregion

// # ========================================================================= #
// # |   End   |
// # ========================================================================= #
````
