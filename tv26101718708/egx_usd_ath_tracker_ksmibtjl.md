# EGX USD ATH Tracker

- url: https://www.tradingview.com/script/KSmIBTJl-EGX-USD-ATH-Tracker/
- type: indicator
- pine_id: PUB;12c48b9fea664501aeca4968f927cbfa
- version: 1.0

## Description

EGP price vs. USD all-time high at live FX rates. 
Green line = true dollar gain above the devaluation noise.


HOW TO READ

Green: The stock is truly worth more in dollars than ever before, a real breakout.

Red: Nominal EGP gains are just devaluation; the stock hasn't recovered in hard-currency terms.

Dashed grey zero line: Breakeven, where EGP price equals the old USD peak at today's rate.

SETTINGS

Reference Level: ATH or 52-Week High

NOTES

Requires OANDA:USDEGP or FX_IDC:USDEGP on your data plan
Use a daily timeframe for best ATH accuracy (more bars loaded)
Works on any EGX stock, applies across your watchlist to find real USD leaders

## Source Code

````pine
//@version=6
indicator("EGX USD ATH Tracker", overlay=false, format=format.percent, precision=2)

// ─── Reference level selection ──────────────────────────────────────────────────────
reference_type = input.string("ATH", "Reference Level", options=["ATH", "52W High"])
table_size_str = input.string("Small", "Table Text Size", options=["Small", "Normal", "Large"])
tbl_size = table_size_str == "Small" ? size.small : table_size_str == "Normal" ? size.normal : size.large

// ─── 1. Fetch USD/EGP exchange rate ─────────────────────────────────────────────────
// Primary source: OANDA (well-known forex provider)
usd_egp_primary = request.security("OANDA:USDEGP", timeframe.period, close, ignore_invalid_symbol=true)
// Fallback: FX_IDC (TradingView's own data feed)
usd_egp_fallback = request.security("FX_IDC:USDEGP", timeframe.period, close, ignore_invalid_symbol=true)
// Use primary if non-na, else fallback
usd_egp = nz(usd_egp_primary, usd_egp_fallback)

// ─── 2. Convert EGP close → USD price (at THAT bar's FX rate) ──────────────────────
price_usd = na(usd_egp) or usd_egp == 0 ? na : close / usd_egp

// ─── 3. Track all-time-high in USD terms ────────────────────────────────────────────
var float ath_usd = na
if not na(price_usd)
    ath_usd := na(ath_usd) ? price_usd : math.max(ath_usd, price_usd)

// Track all-time-high in EGP terms (raw stock price)
var float egp_ath = na
if not na(close)
    egp_ath := na(egp_ath) ? close : math.max(egp_ath, close)

// Track 52-week high (252 trading days ≈ 1 year of daily data)
high52w_usd = ta.highest(price_usd, 252)

// ─── 4. Choose reference level (ATH or 52W High) ────────────────────────────────────
// ─── 5. Pick the active reference and convert to EGP at current FX ─────────────────
ref_usd = reference_type == "ATH" ? ath_usd : high52w_usd
ref_egp = na(ref_usd) or na(usd_egp) ? na : ref_usd * usd_egp

// ─── 6. Percentage difference ───────────────────────────────────────────────────────
// (close - ref_egp) / ref_egp   — format=format.percent auto-×100 for display
pct_diff = na(ref_egp) or ref_egp == 0 ? na : ((close - ref_egp) / ref_egp) * 100

// % EGP ATH vs USD-ref-equivalent EGP price
egp_ath_pct = na(egp_ath) or na(ref_egp) or ref_egp == 0 ? na : (egp_ath / ref_egp - 1) * 100

// ─── 7. Zero-line at the reference (USD) level ──────────────────────────────────────
hline(0, "Ref Level (USD)", color=color.new(color.gray, 40), linestyle=hline.style_dashed)

// ─── 8. Plot — green above zero, red below ──────────────────────────────────────────
plot_color = na(pct_diff) ? color.gray : pct_diff >= 0 ? color.green : color.red
plot(pct_diff, "% vs Ref Level", color=plot_color, style=plot.style_line, linewidth=2)

// ─── USD ATH / 52W High on the price chart ─────────────────────────────────────────
plot(ref_egp, "USD ATH", color=color.green, linewidth=2, style=plot.style_line, force_overlay=true, display=reference_type == "ATH" ? display.all : display.none)
plot(ref_egp, "USD 52W High", color=color.green, linewidth=2, style=plot.style_line, force_overlay=true, display=reference_type == "52W High" ? display.all : display.none)

// ─── 9. Info table (top-right of indicator pane) ────────────────────────────────────
var tbl = table.new(position.top_right, 2, 5,
     bgcolor=color.new(color.silver, 90),
     border_color=color.new(color.gray, 40),
     border_width=1)

if barstate.islast
    // — Header row —
    table.cell(tbl, 0, 0, "Metric", text_color=color.gray, text_size=tbl_size)
    table.cell(tbl, 1, 0, "Value",  text_color=color.gray, text_size=tbl_size)

    // — Reference level in USD —
    ref_label_usd = reference_type == "ATH" ? "ATH (USD)" : "52W High (USD)"
    ref_usd_str = na(ref_usd) ? "—" : str.tostring(ref_usd, "#.##")
    table.cell(tbl, 0, 1, ref_label_usd, text_color=color.white, text_size=tbl_size)
    table.cell(tbl, 1, 1, ref_usd_str,  text_color=color.yellow, text_size=tbl_size)

    // — Current USD/EGP rate —
    usd_egp_str = na(usd_egp) ? "—" : str.tostring(usd_egp, "#.####")
    table.cell(tbl, 0, 2, "USD/EGP", text_color=color.white, text_size=tbl_size)
    table.cell(tbl, 1, 2, usd_egp_str,  text_color=color.aqua, text_size=tbl_size)

    // — Reference-equivalent EGP price at current FX —
    ref_label_egp = reference_type == "ATH" ? "ATH (EGP)" : "52W High (EGP)"
    ref_egp_str = na(ref_egp) ? "—" : str.tostring(ref_egp, "#.##")
    table.cell(tbl, 0, 3, ref_label_egp, text_color=color.white, text_size=tbl_size)
    table.cell(tbl, 1, 3, ref_egp_str,  text_color=color.lime, text_size=tbl_size)

    // — % EGP ATH vs USD-ref-equivalent EGP —
    egp_ath_pct_str = na(egp_ath_pct) ? "—" : str.tostring(egp_ath_pct, "#.##") + "%"
    egp_ath_pct_color = na(egp_ath_pct) ? color.gray : egp_ath_pct >= 0 ? color.green : color.red
    table.cell(tbl, 0, 4, "% EGP ATH vs Ref", text_color=color.white, text_size=tbl_size)
    table.cell(tbl, 1, 4, egp_ath_pct_str,  text_color=egp_ath_pct_color, text_size=tbl_size)
````
