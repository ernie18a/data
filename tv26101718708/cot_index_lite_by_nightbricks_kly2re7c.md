# COT Index Lite - by Nightbricks

- url: https://www.tradingview.com/script/kLY2RE7c-COT-Index-Lite-by-Nightbricks/
- type: indicator
- pine_id: PUB;70d96535b5a14a62b45001875b07143d
- version: 3.0

## Description

The COT Index shows Managed Money (Non-Commercial) net positioning as a normalised
0–100 value, auto-detected from your chart symbol across 60+ futures markets. No manual
CFTC code required for supported assets.

**What it measures**

Net positioning (longs minus shorts) from the CFTC Commitment of Traders report,
normalised against a 3-year (156-week) lookback window:

- **100** — net longs at a 3-year high. The crowd is maximally long.
- **0** — net shorts at a 3-year high. The crowd is maximally short.
- **50** — the midpoint of the 3-year range.
- **Above 80** — historically crowded-long zone (red background shading).
- **Below 20** — historically crowded-short zone (green background shading).

Updated every Friday after the CFTC 3:30 PM ET release. The script reads the last
*completed* weekly value, so the printed reading does not repaint intra-week.

**Why a 3-year window?**

Many COT Index tools use a 26–52 week lookback. Short windows produce unstable readings
that jump as old extremes age out of the window. A 156-week window spans a full market
cycle, so an "extreme" reading is extreme relative to years of behaviour — not just the
last few months.

**Supported markets — auto-detected**

- Equity indices: S&P 500, Nasdaq 100, Dow, Russell 2000, Nikkei, VIX
- FX: EUR, GBP, JPY, CHF, CAD, AUD, NZD, MXN
- Rates: 30Y, 10Y, 5Y, 2Y T-Notes, Fed Funds
- Crypto: Bitcoin, Ethereum
- Energy: WTI, Brent, Natural Gas, Heating Oil, Gasoline
- Metals: Gold, Silver, Copper, Platinum, Palladium
- Grains: Corn, Wheat, Soybeans, Soybean Meal/Oil, Oats, Rice
- Softs: Cotton, Sugar, Coffee, Cocoa, OJ
- Livestock: Live Cattle, Lean Hogs, Feeder Cattle

For any unlisted instrument, type its CFTC market code into the "CFTC Code override" input.

**How to use it**

- Add it to a **Weekly** chart — COT data is weekly; the script warns you on other timeframes.
- Treat readings above 80 and below 20 as *context*, not signals. A crowded-long market
  can stay crowded; the index tells you how stretched positioning is, not when it turns.
- Combine with price structure and your own risk rules.

**What the COT Index does — and does not — tell you**

The COT Index answers one question: *where is positioning within its 3-year range?* By
design it does **not** measure how statistically extreme the reading is, whether
positioning is accelerating or unwinding, or whether price and positioning are diverging.
Those are separate calculations on the same underlying data — useful to understand as
their own concepts, but out of scope for a single 0–100 line.

Open-source. Read the code, fork it, learn from it.

## Source Code

````pine
//@version=6
// COT Index Lite — by Nightbricks
// Open-source. Speculative net positioning as a 0-100 index across 96 chart symbols (54 CFTC markets):
// Managed Money (Disaggregated) for commodities, Leveraged Funds (TFF) for financials.
// Normalised over a 3-year (156-week) lookback. Auto-detects the chart symbol — no manual CFTC code for supported assets.
// Licensed under the Mozilla Public License 2.0.
indicator("COT Index Lite — by Nightbricks", shorttitle="COT Index Lite | Nightbricks", overlay=false, max_bars_back=500)

// ── Inputs ────────────────────────────────────────────────────────────────────
cftc_override   = input.string("", "CFTC Code override (blank = auto-detect)")
is_fin_override = input.bool(false, "Financial instrument (only if using override)")

// ── Constants ─────────────────────────────────────────────────────────────────
// 156-week (3-year) lookback — longer context than most free tools (26–52w default)
int COTIDX_WIN = 156

// ── Instrument mapping ──────────────────────────────────────────────────────────
// Returns [cftc_code, is_fin]. is_fin=true -> COT3 Leveraged Funds (TFF);
// is_fin=false -> COT2 Managed Money (Disaggregated). Matches the COTInsight dashboard.
f_resolve(_ticker, _override, _is_fin_ov) =>
    if _override != ""
        [_override, _is_fin_ov]
    else
        switch _ticker
            // Equity Indices (financial)
            "ES1!"   => ["13874+", true]
            "MES1!"  => ["13874+", true]
            "SPX"    => ["13874+", true]
            "SPY"    => ["13874+", true]
            "NQ1!"   => ["20974+", true]
            "MNQ1!"  => ["20974+", true]
            "NDX"    => ["20974+", true]
            "QQQ"    => ["20974+", true]
            "YM1!"   => ["124603", true]
            "MYM1!"  => ["124603", true]
            "DJI"    => ["124603", true]
            "DIA"    => ["124603", true]
            "RTY1!"  => ["239742", true]
            "M2K1!"  => ["239742", true]
            "RUT"    => ["239742", true]
            "IWM"    => ["239742", true]
            "NKD1!"  => ["240741", true]
            "NI225"  => ["240741", true]
            "VX1!"   => ["1170E1", true]
            "VIX"    => ["1170E1", true]
            // FX (financial)
            "EURUSD" => ["099741", true]
            "EURGBP" => ["099741", true]
            "EURJPY" => ["099741", true]
            "GBPUSD" => ["096742", true]
            "GBPJPY" => ["096742", true]
            "USDJPY" => ["097741", true]
            "JPYUSD" => ["097741", true]
            "USDCHF" => ["092741", true]
            "CHFUSD" => ["092741", true]
            "USDCAD" => ["090741", true]
            "CADUSD" => ["090741", true]
            "AUDUSD" => ["232741", true]
            "AUDNZD" => ["232741", true]
            "NZDUSD" => ["112741", true]
            "USDMXN" => ["095741", true]
            "MXNUSD" => ["095741", true]
            "USDBRL" => ["102741", true]
            // Rates (financial)
            "UB1!"  => ["020604", true]
            "ZB1!"  => ["020601", true]
            "TN1!"  => ["246605", true]
            "ZN1!"  => ["043602", true]
            "ZF1!"  => ["044601", true]
            "ZT1!"  => ["042601", true]
            "ZQ1!"  => ["045601", true]
            // Crypto (financial)
            "BTC1!"   => ["133741", true]
            "BTCUSD"  => ["133741", true]
            "BTCUSDT" => ["133741", true]
            "MBT1!"   => ["133741", true]
            "ETH1!"   => ["146021", true]
            "ETHUSD"  => ["146021", true]
            "MET1!"   => ["146022", true]
            // Energy (commodity)
            "CL1!"     => ["067651", false]
            "MCL1!"    => ["067651", false]
            "USOIL"    => ["067651", false]
            "WTICOUSD" => ["067651", false]
            "BZ1!"     => ["06765T", false]
            "UKOIL"    => ["06765T", false]
            "BCOUSD"   => ["06765T", false]
            "NG1!"     => ["023651", false]
            "NATGAS"   => ["023651", false]
            "HO1!"     => ["022651", false]
            "RB1!"     => ["111659", false]
            // Metals (commodity)
            "GC1!"   => ["088691", false]
            "MGC1!"  => ["088691", false]
            "XAUUSD" => ["088691", false]
            "GOLD"   => ["088691", false]
            "SI1!"   => ["084691", false]
            "MSI1!"  => ["084691", false]
            "XAGUSD" => ["084691", false]
            "SILVER" => ["084691", false]
            "HG1!"   => ["085692", false]
            "XCUUSD" => ["085692", false]
            "COPPER" => ["085692", false]
            "PL1!"   => ["076651", false]
            "XPTUSD" => ["076651", false]
            "PA1!"   => ["075651", false]
            "XPDUSD" => ["075651", false]
            // Grains (commodity)
            "ZC1!"  => ["002602", false]
            "ZW1!"  => ["001602", false]
            "KE1!"  => ["001612", false]
            "MWE1!" => ["001626", false]
            "ZS1!"  => ["005602", false]
            "ZM1!"  => ["026603", false]
            "ZL1!"  => ["007601", false]
            "ZO1!"  => ["004603", false]
            "ZR1!"  => ["039601", false]
            // Softs (commodity)
            "CT1!"  => ["033661", false]
            "SB1!"  => ["080732", false]
            "KC1!"  => ["083731", false]
            "CC1!"  => ["073732", false]
            "OJ1!"  => ["040701", false]
            // Livestock (commodity)
            "LE1!"  => ["057642", false]
            "HE1!"  => ["054642", false]
            "GF1!"  => ["061641", false]
            // Other (commodity)
            "LBS1!" => ["058643", false]
            "LBR1!" => ["058644", false]
            => ["", false]

[cftc_code, is_fin] = f_resolve(syminfo.ticker, cftc_override, is_fin_override)
no_data     = cftc_code == ""
// Commodities -> COT2 Managed Money; financials -> COT3 Leveraged Funds; F+O combined.
// `close` (not close[1]) so the pane reflects the latest CFTC report, matching the dashboard.
cot_prefix  = is_fin ? "COT3:" : "COT2:"
sfx_long    = is_fin ? "_FO_LMP_L" : "_FO_MMP_L"
sfx_short   = is_fin ? "_FO_LMP_S" : "_FO_MMP_S"
cftc_long   = no_data ? na : request.security(cot_prefix + cftc_code + sfx_long,  "W", close, ignore_invalid_symbol=true)
cftc_short  = no_data ? na : request.security(cot_prefix + cftc_code + sfx_short, "W", close, ignore_invalid_symbol=true)
net_spec    = cftc_long - cftc_short
cot_missing = na(cftc_long) or na(cftc_short)
active      = not no_data and not cot_missing

// ── COT Index 0–100 (3-year lookback) ─────────────────────────────────────────
net_lo    = ta.lowest(net_spec,  COTIDX_WIN)
net_hi    = ta.highest(net_spec, COTIDX_WIN)
cot_index = active and (net_hi - net_lo) != 0 ?
     math.max(0, math.min(100, (net_spec - net_lo) / (net_hi - net_lo) * 100)) : na

// ── Colours ───────────────────────────────────────────────────────────────────
col_bull = color.new(#22c55e, 0)
col_bear = color.new(#ef4444, 0)
col_neut = color.new(#64748b, 10)

idx_col  = not na(cot_index) ?
     (cot_index > 80 ? col_bear : cot_index < 20 ? col_bull : col_neut) : col_neut

_bg = active and not na(cot_index) ? (cot_index > 80 ? color.new(col_bear, 90) : cot_index < 20 ? color.new(col_bull, 90) : na) : na
bgcolor(_bg)

// ── Timeframe guard ───────────────────────────────────────────────────────────
var label lbl_tf = na
if not timeframe.isweekly and barstate.islast
    lbl_tf_txt = "⚠ COT Index requires a Weekly ('W') chart."
    if na(lbl_tf)
        lbl_tf := label.new(bar_index, 50, lbl_tf_txt,
             style=label.style_label_center, color=color.new(color.orange, 70),
             textcolor=color.white, size=size.normal)
    else
        label.set_xy(lbl_tf, bar_index, 50)

// ── No-data guard ─────────────────────────────────────────────────────────────
var label lbl_nd = na
if (no_data or cot_missing) and barstate.islast
    nd_txt = no_data ?
         "No COT data for this symbol.\nUse the CFTC Code override input." :
         "COT data not yet available.\nCheck after the next CFTC release (Friday)."
    if na(lbl_nd)
        lbl_nd := label.new(bar_index, 50, nd_txt,
             style=label.style_label_center, color=color.new(color.gray, 80),
             textcolor=color.white, size=size.normal)
    else
        label.set_xy(lbl_nd, bar_index, 50)
        label.set_text(lbl_nd, nd_txt)

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(active ? cot_index : na, "COT Index", idx_col, linewidth=2)
plot(active ? 80.0      : na, "Overbought (80)", color.new(col_bear, 60), linewidth=1)
plot(active ? 20.0      : na, "Oversold (20)",   color.new(col_bull, 60), linewidth=1)
plot(active ? 50.0      : na, "Midpoint",         color.new(color.white, 70), linewidth=1)

// ── Label: index value only — no regime, no bias, no z-score ─────────────────
var label lbl_idx = na
if active and barstate.islast
    lbl_txt = "COT Index: " + str.tostring(cot_index, "#.#")
    if na(lbl_idx)
        lbl_idx := label.new(bar_index, cot_index, lbl_txt,
             style=label.style_label_left, color=color.new(color.black, 80),
             textcolor=idx_col, size=size.small)
    else
        label.set_xy(lbl_idx, bar_index, cot_index)
        label.set_text(lbl_idx, lbl_txt)
        label.set_textcolor(lbl_idx, idx_col)
````
