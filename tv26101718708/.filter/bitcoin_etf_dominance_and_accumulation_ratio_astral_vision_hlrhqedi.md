# Bitcoin ETF Dominance and Accumulation Ratio | Astral Vision 

- url: https://www.tradingview.com/script/hlrHQEDI/
- type: indicator
- pine_id: PUB;0fe3239d9dd64c22b89e3dc0f4b9e408
- version: 1.0

## Description

[b]Bitcoin ETF Market Dominance and Accumulation Ratio | Astral Vision 🌠💠[/b]

Since the launch of US spot Bitcoin ETFs, institutional custody of Bitcoin has grown to represent a significant and expanding share of the total 21 million supply. This indicator tracks that relationship through two complementary analytical lenses: how much of Bitcoin's fixed supply is now held in institutional custody across all ten ETFs, and whether the pace at which ETFs are accumulating Bitcoin is increasing or decreasing relative to price, providing a forward-looking measure of institutional conviction that goes beyond raw holdings data.

The indicator operates in two modes that address fundamentally different questions about the same underlying data.

ETF Bitcoin Market Dominance mode answers the question of how much of Bitcoin's total supply institutional investors have removed from circulation through ETF wrappers. The oscillator shows the total ETF holdings as a percentage of the 21 million hard cap, updated daily from on-chain Glassnode data. A rising line means ETFs are capturing an increasing share of the fixed supply, reducing the available float for other market participants and historically creating upward price pressure. The table shows each issuer's contribution to that dominance percentage alongside the change in their supply share across three configurable periods, making it possible to see both the current structural picture and the direction of change at the issuer level.

Accumulation Ratio mode answers a more nuanced question: are ETFs accumulating Bitcoin faster or slower than price is rising? The ratio is constructed as the cumulative net flow of all ETFs divided by the Bitcoin price. A rising ratio means ETFs are adding holdings faster than price appreciation alone would explain, indicating genuine net accumulation rather than passive appreciation of existing holdings. A falling ratio means price is rising faster than ETF accumulation, which can indicate that ETF demand is not the primary driver of the current price move. This ratio is then Z-Score normalized against its own rolling history and inverted so that negative Z-Scores, representing periods where price has outrun ETF accumulation, appear above zero as a warning signal, while positive Z-Scores, representing periods of active ETF accumulation, appear below zero as a supportive condition.

[b]Analytical Framework[/b]
Type of analysis: institutional supply absorption, accumulation pace relative to price
Recommended timeframe: daily chart, suited for position trading and long-term cycle analysis
Signal type: continuous oscillator with per-issuer multi-period breakdown table, two analytical modes

[b]How to interpret the signals[/b]

In ETF Bitcoin Market Dominance mode, the oscillator shows a steadily rising line as long as ETFs continue to absorb supply. The rate of that rise is what matters most. A steeply rising oscillator means ETFs are pulling Bitcoin off the market faster than recent history, historically a condition associated with price strength. A flattening oscillator means absorption has stalled, which has historically preceded consolidation phases. Watch the supply delta columns in the table for each issuer: issuers showing positive supply deltas across all three periods are in sustained accumulation, while those showing consistent negative deltas across all periods are in structural outflow that is reducing their share of the fixed supply.

In Accumulation Ratio mode, the Z-Score oscillator inverted interpretation is the key. When the oscillator is below the lower threshold, it means ETFs are accumulating strongly relative to price, a structurally bullish signal indicating that institutional demand is driving or supporting the price move. When the oscillator rises above the upper threshold, price is running ahead of ETF accumulation, which has historically been a caution signal indicating reduced institutional sponsorship of the current price level. The table ROC columns show which specific issuers are driving changes in the ratio, allowing the identification of the products most actively accumulating relative to their own history.

Across both modes, the total row in the table is the most important single reading. It gives the aggregate institutional picture without needing to process each issuer individually.

[b]How it differs from existing tools[/b]

No standard TradingView indicator tracks ETF holdings as a percentage of Bitcoin's fixed 21 million supply across all ten issuers simultaneously with multi-period supply delta analysis. The Accumulation Ratio mode is entirely original: dividing cumulative net flows by price and Z-Score normalizing the result produces a signal that is fundamentally different from both raw flow data and simple holdings levels, capturing the relationship between institutional demand intensity and price that neither measure alone can express.

[b]Plots 📊[/b]
[list]
[*]Oscillator showing ETF supply percentage of the 21M hard cap with fill (ETF Bitcoin Market Dominance mode)
[*]Inverted Z-Score oscillator of the cumulative flow-to-price ratio with threshold lines and fill (Accumulation Ratio mode)
[*]Zero baseline
[*]Table with per-issuer supply dominance, supply percentage, and three-period supply delta (ETF Bitcoin Market Dominance mode)
[*]Table with per-issuer holdings ROC across three periods and accumulation ratio delta across three periods (Accumulation Ratio mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Mode: ETF Bitcoin Market Dominance or Accumulation Ratio
[*]Period A, B, C: configurable lookback windows in days for the three table columns
[*]Z-Score Length: rolling normalization window for the Accumulation Ratio mode
[*]Threshold High and Low: configurable extreme zone boundaries for the Accumulation Ratio oscillator
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Hermes.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin ETF Market Dominance and Accumulation Ratio | Astral Vision 🌠💠", format=format.volume, precision=2, max_bars_back=1000)

// --- GROUP: SETTINGS ---
mode  = input.string("ETF Bitcoin Market Dominance", "Mode", options=["ETF Bitcoin Market Dominance", "Accumulation Ratio"], group="Settings")
per_a = input.int(7,  "Period A", minval=1, maxval=365, group="Settings")
per_b = input.int(30, "Period B", minval=1, maxval=365, group="Settings")
per_c = input.int(90, "Period C", minval=1, maxval=365, group="Settings")
zlen  = input.int(90, "Z-Score Length (Ratio mode)", minval=10, maxval=365, group="Settings")
// --- OSCILLATOR INPUTS ---
thresh_hi = input.float(2.0,  "Threshold High", minval=0.1,  maxval=5.0,  step=0.1, group="Settings")
thresh_lo = input.float(-2.5, "Threshold Low",  minval=-5.0, maxval=-0.1, step=0.1, group="Settings")


// --- GROUP: ASTRAL COLORS ---
theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes","Custom"], group="Astral Colors")
custom_pos = input.color(color.rgb(0, 255, 180), "Custom Positive", group="Astral Colors")
custom_neg = input.color(color.rgb(180, 0, 255), "Custom Negative", group="Astral Colors")

col_pos = theme == "Inferno"  ? color.rgb(255, 0, 0)     :
          theme == "Paradiso" ? color.rgb(0, 210, 255)   :
          theme == "Futura"   ? color.rgb(0, 255, 180)   :
          theme == "Infinito" ? color.rgb(180, 120, 255) :
          theme == "Hermes"   ? color.rgb(255, 160, 0)   : custom_pos

col_neg = theme == "Inferno"  ? color.rgb(120, 0, 0)     :
          theme == "Paradiso" ? color.rgb(0, 80, 160)    :
          theme == "Futura"   ? color.rgb(180, 0, 255)   :
          theme == "Infinito" ? color.rgb(255, 220, 80)  :
          theme == "Hermes"   ? color.rgb(0, 180, 120)   : custom_neg

col_hdr = color.rgb(10, 10, 20)
col_bg  = color.rgb(8, 8, 16)
col_txt = color.rgb(200, 200, 220)
col_bdr = color.rgb(30, 30, 50)

tf = "1D"

// --- BALANCES ---
ibit_b = request.security("GLASSNODE:BTC_IBIT_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
fbtc_b = request.security("GLASSNODE:BTC_FBTC_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
gbtc_b = request.security("GLASSNODE:BTC_GBTC_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
arkb_b = request.security("GLASSNODE:BTC_ARKB_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
bitb_b = request.security("GLASSNODE:BTC_BITB_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
hodl_b = request.security("GLASSNODE:BTC_HODL_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
brrr_b = request.security("GLASSNODE:BTC_BRRR_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
btco_b = request.security("GLASSNODE:BTC_BTCO_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
btcw_b = request.security("GLASSNODE:BTC_BTCW_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)
ezbc_b = request.security("GLASSNODE:BTC_EZBC_USSPOTETFBALANCES", tf, close, ignore_invalid_symbol=true)

btc_price = request.security("INDEX:BTCUSD", tf, close)
btc_supply = 21000000.0

// --- TOTALS ---
total_etf = nz(ibit_b) + nz(fbtc_b) + nz(gbtc_b) + nz(arkb_b) + nz(bitb_b) + nz(hodl_b) + nz(brrr_b) + nz(btco_b) + nz(btcw_b) + nz(ezbc_b)

// --- MODE 1: ETF VS BTC SUPPLY ---
supply_pct = total_etf / btc_supply * 100

// --- MODE 2: ACCUMULATION RATIO ---
d1_ibit = nz(ibit_b) - nz(ibit_b[1])
d1_fbtc = nz(fbtc_b) - nz(fbtc_b[1])
d1_gbtc = nz(gbtc_b) - nz(gbtc_b[1])
d1_arkb = nz(arkb_b) - nz(arkb_b[1])
d1_bitb = nz(bitb_b) - nz(bitb_b[1])
d1_hodl = nz(hodl_b) - nz(hodl_b[1])
d1_brrr = nz(brrr_b) - nz(brrr_b[1])
d1_btco = nz(btco_b) - nz(btco_b[1])
d1_btcw = nz(btcw_b) - nz(btcw_b[1])
d1_ezbc = nz(ezbc_b) - nz(ezbc_b[1])

total_flow  = d1_ibit + d1_fbtc + d1_gbtc + d1_arkb + d1_bitb + d1_hodl + d1_brrr + d1_btco + d1_btcw + d1_ezbc
cum_flow    = ta.cum(total_flow)
ratio_raw   = btc_price > 0 ? cum_flow / btc_price : 0.0
ratio_mean  = ta.sma(ratio_raw, zlen)
ratio_std   = ta.stdev(ratio_raw, zlen)
ratio_z     = ratio_std > 0 ? (ratio_raw - ratio_mean) / ratio_std : 0.0
ratio_z_inv = ratio_z * -1

// per ETF
cum_ibit = ta.cum(d1_ibit)
cum_fbtc = ta.cum(d1_fbtc)
cum_gbtc = ta.cum(d1_gbtc)
cum_arkb = ta.cum(d1_arkb)
cum_bitb = ta.cum(d1_bitb)
cum_hodl = ta.cum(d1_hodl)
cum_brrr = ta.cum(d1_brrr)
cum_btco = ta.cum(d1_btco)
cum_btcw = ta.cum(d1_btcw)
cum_ezbc = ta.cum(d1_ezbc)

ratio_ibit = btc_price > 0 ? cum_ibit / btc_price : 0.0
ratio_fbtc = btc_price > 0 ? cum_fbtc / btc_price : 0.0
ratio_gbtc = btc_price > 0 ? cum_gbtc / btc_price : 0.0
ratio_arkb = btc_price > 0 ? cum_arkb / btc_price : 0.0
ratio_bitb = btc_price > 0 ? cum_bitb / btc_price : 0.0
ratio_hodl = btc_price > 0 ? cum_hodl / btc_price : 0.0
ratio_brrr = btc_price > 0 ? cum_brrr / btc_price : 0.0
ratio_btco = btc_price > 0 ? cum_btco / btc_price : 0.0
ratio_btcw = btc_price > 0 ? cum_btcw / btc_price : 0.0
ratio_ezbc = btc_price > 0 ? cum_ezbc / btc_price : 0.0

// --- OSCILLATOR PLOT ---
is_supply = mode == "ETF Bitcoin Market Dominance"

osc_val = is_supply ? supply_pct : ratio_z_inv
osc_col = osc_val >= 0 ? color.new(col_pos, 20) : color.new(col_neg, 20)

p_osc  = plot(osc_val,                          color=osc_col,                           linewidth=2, title="Oscillator")
p_zero = plot(0.0,                               color=color.new(col_txt, 70),            linewidth=1, title="Zero")
fill(p_osc, p_zero, color.new(osc_col, 70))

p_hi = plot(is_supply ? float(na) : thresh_hi, color=color.new(col_pos, 50), linewidth=1, style=plot.style_line, title="+Threshold")
p_lo = plot(is_supply ? float(na) : thresh_lo, color=color.new(col_neg, 50), linewidth=1, style=plot.style_line, title="-Threshold")
// --- HELPERS ---
fmt_pct(v) =>
    str.tostring(math.round(v, 3)) + "%"

fmt_dpct(v) =>
    s = v > 0 ? "▲ +" : v < 0 ? "▼ " : "= "
    s + str.tostring(math.round(math.abs(v), 3)) + "%"

fmt_ratio(v) =>
    s = v > 0 ? "▲ " : v < 0 ? "▼ " : "= "
    s + str.tostring(math.round(v, 4))

bg(v) =>
    v > 0 ? color.new(col_pos, 60) : v < 0 ? color.new(col_neg, 60) : color.new(col_txt, 80)

roc_pct(cur, prev) =>
    (na(prev) or prev == 0) ? 0.0 : (cur - prev) / math.abs(prev) * 100

// --- TABLE ---
var table tbl = table.new(
     position.top_right, 7, 12,
     bgcolor=col_bg,
     border_color=col_bdr,
     border_width=1,
     frame_color=col_bdr,
     frame_width=1,
     force_overlay=true)

lbl_a = str.tostring(per_a) + "d"
lbl_b = str.tostring(per_b) + "d"
lbl_c = str.tostring(per_c) + "d"

if barstate.islast
    names   = array.from("BlackRock (IBIT)", "Fidelity (FBTC)", "Grayscale (GBTC)", "ARK 21Shares (ARKB)", "Bitwise (BITB)", "VanEck (HODL)", "Valkyrie (BRRR)", "Invesco (BTCO)", "WisdomTree (BTCW)", "Franklin (EZBC)")
    etfcols = array.from(color.rgb(255,165,0), color.rgb(30,144,255), color.rgb(180,0,255), color.rgb(0,210,255), color.rgb(0,255,140), color.rgb(255,80,80), color.rgb(255,220,0), color.rgb(160,255,100), color.rgb(200,100,255), color.rgb(100,200,255))

    if is_supply
        // HEADER
        table.cell(tbl, 0, 0, "ETF",             text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 1, 0, "ETF Dom%",         text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 2, 0, "Supply%",          text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 3, 0, "Δ " + lbl_a,      text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 4, 0, "Δ " + lbl_b,      text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 5, 0, "Δ " + lbl_c,      text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 6, 0, "",                 text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)

        dom_total = total_etf > 0 ? total_etf : 1.0
        bal_arr   = array.from(nz(ibit_b), nz(fbtc_b), nz(gbtc_b), nz(arkb_b), nz(bitb_b), nz(hodl_b), nz(brrr_b), nz(btco_b), nz(btcw_b), nz(ezbc_b))
        bala_arr  = array.from(nz(ibit_b[per_a]), nz(fbtc_b[per_a]), nz(gbtc_b[per_a]), nz(arkb_b[per_a]), nz(bitb_b[per_a]), nz(hodl_b[per_a]), nz(brrr_b[per_a]), nz(btco_b[per_a]), nz(btcw_b[per_a]), nz(ezbc_b[per_a]))
        balb_arr  = array.from(nz(ibit_b[per_b]), nz(fbtc_b[per_b]), nz(gbtc_b[per_b]), nz(arkb_b[per_b]), nz(bitb_b[per_b]), nz(hodl_b[per_b]), nz(brrr_b[per_b]), nz(btco_b[per_b]), nz(btcw_b[per_b]), nz(ezbc_b[per_b]))
        balc_arr  = array.from(nz(ibit_b[per_c]), nz(fbtc_b[per_c]), nz(gbtc_b[per_c]), nz(arkb_b[per_c]), nz(bitb_b[per_c]), nz(hodl_b[per_c]), nz(brrr_b[per_c]), nz(btco_b[per_c]), nz(btcw_b[per_c]), nz(ezbc_b[per_c]))

        for i = 0 to 9
            row    = i + 1
            nm     = array.get(names,    i)
            c      = array.get(etfcols,  i)
            bal    = array.get(bal_arr,  i)
            bala   = array.get(bala_arr, i)
            balb   = array.get(balb_arr, i)
            balc   = array.get(balc_arr, i)

            dom    = bal / dom_total * 100
            sup    = bal / btc_supply * 100
            da     = (bal - bala) / btc_supply * 100
            db     = (bal - balb) / btc_supply * 100
            dc     = (bal - balc) / btc_supply * 100

            row_bg = color.new(color.rgb(12, 12, 22), 0)
            table.cell(tbl, 0, row, nm,            bgcolor=row_bg,  text_color=c,           text_halign=text.align_left,   text_font_family=font.family_monospace)
            table.cell(tbl, 1, row, fmt_pct(dom),  bgcolor=row_bg,  text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace)
            table.cell(tbl, 2, row, fmt_pct(sup),  bgcolor=row_bg,  text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace)
            table.cell(tbl, 3, row, fmt_dpct(da),  bgcolor=bg(da),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
            table.cell(tbl, 4, row, fmt_dpct(db),  bgcolor=bg(db),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
            table.cell(tbl, 5, row, fmt_dpct(dc),  bgcolor=bg(dc),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
            table.cell(tbl, 6, row, "",             bgcolor=row_bg,  text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace)

        tot_sup  = total_etf / btc_supply * 100
        tot_supa = (total_etf - (nz(ibit_b[per_a])+nz(fbtc_b[per_a])+nz(gbtc_b[per_a])+nz(arkb_b[per_a])+nz(bitb_b[per_a])+nz(hodl_b[per_a])+nz(brrr_b[per_a])+nz(btco_b[per_a])+nz(btcw_b[per_a])+nz(ezbc_b[per_a]))) / btc_supply * 100
        tot_supb = (total_etf - (nz(ibit_b[per_b])+nz(fbtc_b[per_b])+nz(gbtc_b[per_b])+nz(arkb_b[per_b])+nz(bitb_b[per_b])+nz(hodl_b[per_b])+nz(brrr_b[per_b])+nz(btco_b[per_b])+nz(btcw_b[per_b])+nz(ezbc_b[per_b]))) / btc_supply * 100
        tot_supc = (total_etf - (nz(ibit_b[per_c])+nz(fbtc_b[per_c])+nz(gbtc_b[per_c])+nz(arkb_b[per_c])+nz(bitb_b[per_c])+nz(hodl_b[per_c])+nz(brrr_b[per_c])+nz(btco_b[per_c])+nz(btcw_b[per_c])+nz(ezbc_b[per_c]))) / btc_supply * 100

        table.cell(tbl, 0, 11, "TOTAL",              bgcolor=col_hdr,      text_color=color.white, text_halign=text.align_left,   text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 1, 11, "100%",               bgcolor=col_hdr,      text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 2, 11, fmt_pct(tot_sup),     bgcolor=col_hdr,      text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 3, 11, fmt_dpct(tot_supa),   bgcolor=bg(tot_supa), text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 4, 11, fmt_dpct(tot_supb),   bgcolor=bg(tot_supb), text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 5, 11, fmt_dpct(tot_supc),   bgcolor=bg(tot_supc), text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 6, 11, "",                   bgcolor=col_hdr,      text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)

    else
        // HEADER
        table.cell(tbl, 0, 0, "ETF",           text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 1, 0, "ROC " + lbl_a, text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 2, 0, "ROC " + lbl_b, text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 3, 0, "ROC " + lbl_c, text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 4, 0, "R/" + lbl_a,   text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 5, 0, "R/" + lbl_b,   text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 6, 0, "R/" + lbl_c,   text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)

        bal_arr    = array.from(nz(ibit_b), nz(fbtc_b), nz(gbtc_b), nz(arkb_b), nz(bitb_b), nz(hodl_b), nz(brrr_b), nz(btco_b), nz(btcw_b), nz(ezbc_b))
        bala_arr   = array.from(nz(ibit_b[per_a]), nz(fbtc_b[per_a]), nz(gbtc_b[per_a]), nz(arkb_b[per_a]), nz(bitb_b[per_a]), nz(hodl_b[per_a]), nz(brrr_b[per_a]), nz(btco_b[per_a]), nz(btcw_b[per_a]), nz(ezbc_b[per_a]))
        balb_arr   = array.from(nz(ibit_b[per_b]), nz(fbtc_b[per_b]), nz(gbtc_b[per_b]), nz(arkb_b[per_b]), nz(bitb_b[per_b]), nz(hodl_b[per_b]), nz(brrr_b[per_b]), nz(btco_b[per_b]), nz(btcw_b[per_b]), nz(ezbc_b[per_b]))
        balc_arr   = array.from(nz(ibit_b[per_c]), nz(fbtc_b[per_c]), nz(gbtc_b[per_c]), nz(arkb_b[per_c]), nz(bitb_b[per_c]), nz(hodl_b[per_c]), nz(brrr_b[per_c]), nz(btco_b[per_c]), nz(btcw_b[per_c]), nz(ezbc_b[per_c]))
        rat_arr    = array.from(ratio_ibit, ratio_fbtc, ratio_gbtc, ratio_arkb, ratio_bitb, ratio_hodl, ratio_brrr, ratio_btco, ratio_btcw, ratio_ezbc)
        rata_arr   = array.from(ratio_ibit[per_a], ratio_fbtc[per_a], ratio_gbtc[per_a], ratio_arkb[per_a], ratio_bitb[per_a], ratio_hodl[per_a], ratio_brrr[per_a], ratio_btco[per_a], ratio_btcw[per_a], ratio_ezbc[per_a])
        ratb_arr   = array.from(ratio_ibit[per_b], ratio_fbtc[per_b], ratio_gbtc[per_b], ratio_arkb[per_b], ratio_bitb[per_b], ratio_hodl[per_b], ratio_brrr[per_b], ratio_btco[per_b], ratio_btcw[per_b], ratio_ezbc[per_b])
        ratc_arr   = array.from(ratio_ibit[per_c], ratio_fbtc[per_c], ratio_gbtc[per_c], ratio_arkb[per_c], ratio_bitb[per_c], ratio_hodl[per_c], ratio_brrr[per_c], ratio_btco[per_c], ratio_btcw[per_c], ratio_ezbc[per_c])

        for i = 0 to 9
            row  = i + 1
            nm   = array.get(names,    i)
            c    = array.get(etfcols,  i)
            bal  = array.get(bal_arr,  i)
            bala = array.get(bala_arr, i)
            balb = array.get(balb_arr, i)
            balc = array.get(balc_arr, i)
            ra   = array.get(rat_arr,  i)
            raa  = array.get(rata_arr, i)
            rb   = array.get(ratb_arr, i)
            rc   = array.get(ratc_arr, i)

            roc_a  = roc_pct(bal, bala)
            roc_b  = roc_pct(bal, balb)
            roc_c  = roc_pct(bal, balc)
            dra    = ra - raa
            drb    = ra - rb
            drc    = ra - rc

            row_bg = color.new(color.rgb(12, 12, 22), 0)
            table.cell(tbl, 0, row, nm,              bgcolor=row_bg,  text_color=c,           text_halign=text.align_left,   text_font_family=font.family_monospace)
            table.cell(tbl, 1, row, fmt_dpct(roc_a), bgcolor=bg(roc_a), text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
            table.cell(tbl, 2, row, fmt_dpct(roc_b), bgcolor=bg(roc_b), text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
            table.cell(tbl, 3, row, fmt_dpct(roc_c), bgcolor=bg(roc_c), text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
            table.cell(tbl, 4, row, fmt_ratio(dra),  bgcolor=bg(dra),   text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
            table.cell(tbl, 5, row, fmt_ratio(drb),  bgcolor=bg(drb),   text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
            table.cell(tbl, 6, row, fmt_ratio(drc),  bgcolor=bg(drc),   text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)

        tot_roc_a = roc_pct(total_etf, nz(ibit_b[per_a])+nz(fbtc_b[per_a])+nz(gbtc_b[per_a])+nz(arkb_b[per_a])+nz(bitb_b[per_a])+nz(hodl_b[per_a])+nz(brrr_b[per_a])+nz(btco_b[per_a])+nz(btcw_b[per_a])+nz(ezbc_b[per_a]))
        tot_roc_b = roc_pct(total_etf, nz(ibit_b[per_b])+nz(fbtc_b[per_b])+nz(gbtc_b[per_b])+nz(arkb_b[per_b])+nz(bitb_b[per_b])+nz(hodl_b[per_b])+nz(brrr_b[per_b])+nz(btco_b[per_b])+nz(btcw_b[per_b])+nz(ezbc_b[per_b]))
        tot_roc_c = roc_pct(total_etf, nz(ibit_b[per_c])+nz(fbtc_b[per_c])+nz(gbtc_b[per_c])+nz(arkb_b[per_c])+nz(bitb_b[per_c])+nz(hodl_b[per_c])+nz(brrr_b[per_c])+nz(btco_b[per_c])+nz(btcw_b[per_c])+nz(ezbc_b[per_c]))
        tot_dra   = ratio_raw - ratio_raw[per_a]
        tot_drb   = ratio_raw - ratio_raw[per_b]
        tot_drc   = ratio_raw - ratio_raw[per_c]

        table.cell(tbl, 0, 11, "TOTAL",               bgcolor=col_hdr,       text_color=color.white, text_halign=text.align_left,   text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 1, 11, fmt_dpct(tot_roc_a),   bgcolor=bg(tot_roc_a), text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 2, 11, fmt_dpct(tot_roc_b),   bgcolor=bg(tot_roc_b), text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 3, 11, fmt_dpct(tot_roc_c),   bgcolor=bg(tot_roc_c), text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 4, 11, fmt_ratio(tot_dra),    bgcolor=bg(tot_dra),   text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 5, 11, fmt_ratio(tot_drb),    bgcolor=bg(tot_drb),   text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
        table.cell(tbl, 6, 11, fmt_ratio(tot_drc),    bgcolor=bg(tot_drc),   text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
````
