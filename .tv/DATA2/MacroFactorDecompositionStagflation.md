<!-- tradingview-pine-id: PUB;f12e39c3cbc248b2b60171bc2026d770 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# MacroFactorDecomposition_Stagflation

Source: https://www.tradingview.com/script/MUNw4dEi-MacroFactorDecomposition-Stagflation/

## Description

Library "Calc_MacroFactorDecomposition_Stagflation"

Calculates the 6-Factor Macro Regime & Stagflation Decomposition and composite score   Parameters:

Rolling bar window for multi-period return and Z-score (e.g., 63 bars)
   Weight for Inflation factor (TIP / IEF)
   Weight for Growth Deceleration factor (-IWM / SPY)
   Weight for Rate Shock factor (-IEF)
   Weight for USD Weakness / Debasement factor (-UUP)
   Weight for Fiscal Dominance factor (SHY / TLT)
   Weight for Supply Bottleneck / Cost-Push factor (DBC / XLI)
  
Returns: [composite, z_inf, z_growth, z_rate, z_usd, z_fiscal, z_bottleneck]

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OMEGA-CVaR=MACRO

//@version=6
// =============================================================================
// LIBRARY: MacroFactorDecomposition_Stagflation (v6 Institutional Edition)
// =============================================================================
// Decomposes market regimes into 6 orthogonal macro drivers:
// 1. Inflation Expectations (TIP / IEF)
// 2. Growth Deceleration (-1.0 * [IWM / SPY])
// 3. Real / Nominal Rate Shock (-1.0 * IEF)
// 4. Fiat Debasement / USD Weakness (-1.0 * UUP)
// 5. Fiscal Dominance / Curve Steepening (SHY / TLT)
// 6. Supply Bottleneck / Cost-Push Spread (DBC / XLI)
//
// Quantitative Risk Engines:
// - Volume-Weighted Omega Ratio (Empirical Distribution)
// - Volume-Weighted CVaR / Expected Shortfall (Paired Sort Integration)
// =============================================================================
library("MacroFactorDecomposition_Stagflation", overlay = false)

// =============================================================================
// SECTION 1: CORE DATA INGESTION & STATISTICAL HELPERS
// =============================================================================

// @function Fetches close price for a specified symbol safely across chart contexts
// @param sym Security ticker string (e.g., "AMEX:TIP")
// @returns Series float close price synchronized to chart resolution
f_get_close(simple string sym) =>
    request.security(sym, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

// @function Calculates rolling statistical Z-Score
// @param src Raw input series
// @param len Rolling lookback window
// @returns Standardized Z-Score series (0.0 if standard deviation is zero or undefined)
f_zscore(series float src, simple int len) =>
    mean  = ta.sma(src, len)
    stdev = ta.stdev(src, len)
    stdev > 0 ? (src - mean) / stdev : 0.0

// =============================================================================
// SECTION 2: VOLUME-WEIGHTED RISK & PERFORMANCE ENGINES
// =============================================================================

// @function Computes the Volume-Weighted Omega Ratio over historical return & volume arrays
// @param rets Array of period returns
// @param vols Array of period volumes (or dollar volume weights)
// @param L Threshold/hurdle return (e.g., 0.0 or risk-free rate per period)
// @returns Volume-weighted Omega ratio
export calc_vw_omega(float[] rets, float[] vols, simple float L = 0.0) =>
    float sum_v    = array.sum(vols)
    float up_accum = 0.0
    float dn_accum = 0.0
    int   n        = array.size(rets)

    if sum_v > 0 and n > 0
        for i = 0 to n - 1
            float w = array.get(vols, i) / sum_v
            float r = array.get(rets, i)
            if r > L
                up_accum += w * (r - L)
            else if r < L
                dn_accum += w * (L - r)

    dn_accum > 0.0 ? (up_accum / dn_accum) : 10.0

// @function Computes Volume-Weighted Conditional Value-at-Risk (Expected Shortfall)
// @param rets Array of period returns
// @param vols Array of period volumes (or dollar volume weights)
// @param a Tail risk alpha level (e.g., 0.05 for 95% CVaR)
// @returns Volume-weighted average loss in the left alpha tail
export calc_vw_cvar(float[] rets, float[] vols, simple float a = 0.05) =>
    int   n     = array.size(rets)
    float sum_v = array.sum(vols)
    float cvar  = 0.0

    if n > 0 and sum_v > 0
        // Clone arrays to prevent mutating input series
        float[] s_rets = array.copy(rets)
        float[] s_vols = array.copy(vols)

        // Paired Insertion Sort (ascending order of return)
        for i = 1 to n - 1
            float key_r = array.get(s_rets, i)
            float key_v = array.get(s_vols, i)
            int j = i - 1
            while j >= 0 and array.get(s_rets, j) > key_r
                array.set(s_rets, j + 1, array.get(s_rets, j))
                array.set(s_vols, j + 1, array.get(s_vols, j))
                j -= 1
            array.set(s_rets, j + 1, key_r)
            array.set(s_vols, j + 1, key_v)

        // Integrate tail up to cumulative volume weight alpha
        float cum_w              = 0.0
        float weighted_tail_loss = 0.0

        for i = 0 to n - 1
            float w = array.get(s_vols, i) / sum_v
            float r = array.get(s_rets, i)

            if cum_w + w <= a
                weighted_tail_loss += w * r
                cum_w += w
            else
                float remaining_w = a - cum_w
                if remaining_w > 0
                    weighted_tail_loss += remaining_w * r
                    cum_w += remaining_w
                break

        cvar := cum_w > 0 ? (weighted_tail_loss / cum_w) : array.get(s_rets, 0)
    cvar

// @function Fetches synchronized historical returns and volumes into fixed-length arrays
// @param sym Security ticker string (e.g., "AMEX:SPY")
// @param len Rolling window length
// @returns [returns_array, volumes_array]
export get_history_arrays(simple string sym, simple int len) =>
    [c, v] = request.security(sym, timeframe.period, [close, volume], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

    var float[] ret_arr = array.new_float(0)
    var float[] vol_arr = array.new_float(0)

    float r = (c[1] != 0 and not na(c[1])) ? ((c - c[1]) / c[1]) : 0.0
    array.push(ret_arr, nz(r, 0.0))
    array.push(vol_arr, nz(v, 1.0))

    if array.size(ret_arr) > len
        array.shift(ret_arr)
        array.shift(vol_arr)

    [ret_arr, vol_arr]

// =============================================================================
// SECTION 3: EXPORTED MACRO DECOMPOSITION ENGINE
// =============================================================================

// @function Calculates the 6-Factor Macro Regime and Stagflation Decomposition and composite score
// @param lookback_period Rolling bar window for multi-period return and Z-score (e.g., 63 bars ~ 1 quarter)
// @param smooth_len EMA smoothing length applied to Z-scores (default = 5)
// @param w_inf Weight for Inflation factor (TIP / IEF)
// @param w_growth Weight for Growth Deceleration factor (-IWM / SPY)
// @param w_rate Weight for Rate Shock factor (-IEF)
// @param w_usd Weight for USD Weakness / Debasement factor (-UUP)
// @param w_fiscal Weight for Fiscal Dominance factor (SHY / TLT)
// @param w_bottleneck Weight for Supply Bottleneck / Cost-Push factor (DBC / XLI)
// @returns [composite, z_inf, z_growth, z_rate, z_usd, z_fiscal, z_bottleneck]
export calc_stagflation(
     simple int   lookback_period = 63, 
     simple int   smooth_len      = 5,
     simple float w_inf           = 0.16667,
     simple float w_growth        = 0.16667,
     simple float w_rate          = 0.16667,
     simple float w_usd           = 0.16667,
     simple float w_fiscal        = 0.16667,
     simple float w_bottleneck    = 0.16667
     ) =>

    // -------------------------------------------------------------------------
    // 1. Ticker Definitions (6-Factor Proxies)
    // -------------------------------------------------------------------------
    sym_tip = "AMEX:TIP"   // iShares TIPS Bond ETF (Inflation Protected)
    sym_ief = "NASDAQ:IEF" // iShares 7-10 Year Treasury Bond ETF (Intermediate Duration)
    sym_iwm = "AMEX:IWM"   // iShares Russell 2000 ETF (Small-Cap Domestic Growth)
    sym_spy = "AMEX:SPY"   // SPDR S&P 500 ETF Trust (Broad Equity Benchmark)
    sym_uup = "AMEX:UUP"   // Invesco DB US Dollar Index Bullish Fund (Fiat Currency)
    sym_shy = "NASDAQ:SHY" // iShares 1-3 Year Treasury Bond ETF (Front-End Sovereign Debt)
    sym_tlt = "NASDAQ:TLT" // iShares 20+ Year Treasury Bond ETF (Long-End Sovereign Debt)
    sym_dbc = "AMEX:DBC"   // Invesco DB Commodity Index Tracking Fund (Raw Physical Commodities)
    sym_xli = "AMEX:XLI"   // Industrial Select Sector SPDR Fund (Industrial Production)

    // -------------------------------------------------------------------------
    // 2. Security Price Feeds (Synchronized)
    // -------------------------------------------------------------------------
    px_tip = f_get_close(sym_tip)
    px_ief = f_get_close(sym_ief)
    px_iwm = f_get_close(sym_iwm)
    px_spy = f_get_close(sym_spy)
    px_uup = f_get_close(sym_uup)
    px_shy = f_get_close(sym_shy)
    px_tlt = f_get_close(sym_tlt)
    px_dbc = f_get_close(sym_dbc)
    px_xli = f_get_close(sym_xli)

    // -------------------------------------------------------------------------
    // 3. Multi-Bar Rate of Change Over Lookback Horizon
    // -------------------------------------------------------------------------
    ratio_inf    = (px_ief != 0) ? (px_tip / px_ief) : 1.0
    raw_inf      = (ratio_inf[lookback_period] != 0) ? (ta.change(ratio_inf, lookback_period) / ratio_inf[lookback_period]) : 0.0

    ratio_growth = (px_spy != 0) ? (px_iwm / px_spy) : 1.0
    raw_growth   = (ratio_growth[lookback_period] != 0) ? -1.0 * (ta.change(ratio_growth, lookback_period) / ratio_growth[lookback_period]) : 0.0

    raw_rate     = (px_ief[lookback_period] != 0) ? -1.0 * (ta.change(px_ief, lookback_period) / px_ief[lookback_period]) : 0.0
    raw_usd      = (px_uup[lookback_period] != 0) ? -1.0 * (ta.change(px_uup, lookback_period) / px_uup[lookback_period]) : 0.0

    ratio_fiscal = (px_tlt != 0) ? (px_shy / px_tlt) : 1.0
    raw_fiscal   = (ratio_fiscal[lookback_period] != 0) ? (ta.change(ratio_fiscal, lookback_period) / ratio_fiscal[lookback_period]) : 0.0

    ratio_bot    = (px_xli != 0) ? (px_dbc / px_xli) : 1.0
    raw_bot      = (ratio_bot[lookback_period] != 0) ? (ta.change(ratio_bot, lookback_period) / ratio_bot[lookback_period]) : 0.0

    // -------------------------------------------------------------------------
    // 4. Statistical Normalization (Z-Scores) and EMA Smoothing
    // -------------------------------------------------------------------------
    z_inf        = ta.ema(f_zscore(raw_inf,    lookback_period), smooth_len)
    z_growth     = ta.ema(f_zscore(raw_growth, lookback_period), smooth_len)
    z_rate       = ta.ema(f_zscore(raw_rate,   lookback_period), smooth_len)
    z_usd        = ta.ema(f_zscore(raw_usd,    lookback_period), smooth_len)
    z_fiscal     = ta.ema(f_zscore(raw_fiscal, lookback_period), smooth_len)
    z_bottleneck = ta.ema(f_zscore(raw_bot,    lookback_period), smooth_len)

    // -------------------------------------------------------------------------
    // 5. Linear Weighted Composite Regime Score
    // -------------------------------------------------------------------------
    total_weight = w_inf + w_growth + w_rate + w_usd + w_fiscal + w_bottleneck
    composite = total_weight > 0 ? (
        (w_inf        * z_inf)        + 
        (w_growth     * z_growth)     + 
        (w_rate       * z_rate)       + 
        (w_usd        * z_usd)        + 
        (w_fiscal     * z_fiscal)     + 
        (w_bottleneck * z_bottleneck)
        ) / total_weight : 0.0

    [composite, z_inf, z_growth, z_rate, z_usd, z_fiscal, z_bottleneck]
````
