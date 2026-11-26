# Bitcoin ETF Flows Z-Score | Astral Vision 

- url: https://www.tradingview.com/script/zyVhpYmQ/
- type: indicator
- pine_id: PUB;b0c509ac5f3843e1bb0212a4a9080448
- version: 1.0

## Description

[b]Bitcoin ETF Flows Z-Score | Astral Vision 🌠💠[/b]

Daily ETF flow data is noisy by nature. A single large institutional redemption or creation event can dominate the raw number on any given day, making it difficult to distinguish between a statistically meaningful shift in institutional demand and normal day-to-day variation. This indicator solves that problem by normalizing each ETF's daily flow against its own rolling distribution, producing a Z-Score that measures how unusual today's flow is relative to that specific product's own history, and then combining those normalized readings into a single aggregate signal that is far more statistically robust than any raw flow total.

The key insight behind this approach is that absolute flow size is not what matters most. What matters is whether today's flow is unusual relative to what that ETF normally sees. A 5,000 BTC inflow into IBIT is unremarkable if IBIT regularly sees flows of that magnitude, but a 5,000 BTC inflow into a smaller product like EZBC would be an extreme outlier. By normalizing each product independently before aggregating, this indicator treats all ten ETFs as equal contributors to the signal regardless of their size, detecting coordinated multi-issuer flow anomalies that would be invisible in a simple raw total.

The oscillator in the sub-panel shows the 7-day smoothed aggregate Z-Score, filtered to reduce single-day noise. The table provides the real-time picture: the current Z-Score for each individual ETF plus its rolling average across three configurable periods, making it possible to see which issuers are driving or dragging the aggregate and whether their anomalous behavior is a single-day spike or a sustained trend.

[b]Analytical Framework[/b]
Type of analysis: institutional flow anomaly detection, ETF demand quality assessment
Recommended timeframe: daily chart, best used as a macro demand quality overlay for position trading.
Signal type: normalized Z-Score oscillator with per-issuer multi-period breakdown table

[b]How to interpret the signals[/b]

The oscillator and background color on the price chart are the primary real-time signals. When the smoothed Z-Score is above the upper threshold, ETF flows across the aggregate are statistically elevated relative to their own recent history, meaning institutional demand is running hotter than normal. This has historically preceded or accompanied upward price momentum. When it is below the lower threshold, flows are statistically depressed, meaning institutional demand is unusually weak even if some flows remain technically positive in raw terms.

The zero line is the most important structural reference. A sustained period of the Z-Score above zero means that more often than not, each day's flows are above each ETF's own historical average, indicating a regime of structurally elevated institutional demand. A sustained period below zero indicates the opposite: a regime where demand is consistently running below each product's own baseline.

The table is where the signal becomes actionable at the issuer level. Focus on the relationship between the current Z-Score and the rolling period averages for each ETF. An issuer with a high current Z-Score but a near-zero or negative long-period average is experiencing a sudden spike that is not part of a sustained trend, which may indicate a one-off event rather than a genuine shift in institutional appetite for that product. An issuer with a high Z-Score across all three periods, current, short, and long, is in a confirmed sustained flow expansion that is genuinely anomalous relative to its own history.

The most powerful signals come when multiple issuers simultaneously show elevated Z-Scores across all time periods. This indicates a broad coordinated increase in institutional demand across the entire ETF ecosystem, not just a rotation from one product to another, and has historically been associated with the strongest price performance windows.

GBTC's Z-Score readings deserve particular attention interpreted in reverse: a very negative GBTC Z-Score means outflows from that product are running unusually high even by GBTC's own elevated-outflow standards, adding unusual selling pressure on top of the structural outflow trend. When GBTC's Z-Score rises toward zero or positive, its outflow rate is normalizing, which historically has been a net positive for the aggregate balance.

[b]How it differs from existing tools[/b]

Standard ETF flow tools compare raw Bitcoin amounts across issuers of vastly different sizes, which systematically overstates the significance of large-cap product flows and understates signals from smaller products. This indicator normalizes each issuer independently against its own rolling mean and standard deviation, then aggregates. A +2σ reading from EZBC carries the same weight as a +2σ reading from IBIT, making the combined signal sensitive to broad-based demand shifts rather than dominated by the largest product.

[b]Plots 📊[/b]
[list]
[*]7-day smoothed aggregate Z-Score oscillator with upper and lower threshold lines
[*]Zero baseline
[*]Background color on the price chart when aggregate Z-Score is in extreme zones
[*]Table with current Z-Score and three-period rolling averages for all ten ETFs plus the aggregate total, color-coded by sign
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Z-Score Length: rolling window for per-ETF mean and standard deviation normalization
[*]Threshold High and Low: configurable extreme zone boundaries for the oscillator
[*]Period A, B, C: rolling average windows in days for the three period columns in the table
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
indicator("Bitcoin ETF Flows Z-Score | Astral Vision 🌠💠", format=format.volume, precision=2, max_bars_back=1000)

// --- GROUP: SETTINGS ---
zlen      = input.int(90,   "Z-Score Length",   minval=10,  maxval=365, group="Settings")
thresh_hi = input.float(1.0,  "Threshold High", minval=0.1,  maxval=5.0,  step=0.1, group="Settings")
thresh_lo = input.float(-1.0, "Threshold Low",  minval=-5.0, maxval=-0.1, step=0.1, group="Settings")
per_a     = input.int(7,  "Period A", minval=1, maxval=365, group="Settings")
per_b     = input.int(30, "Period B", minval=1, maxval=365, group="Settings")
per_c     = input.int(90, "Period C", minval=1, maxval=365, group="Settings")

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
col_txt = color.black
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

// --- DAILY DELTA ---
d1_ibit = nz(ibit_b[1]) - nz(ibit_b[2])
d1_fbtc = nz(fbtc_b[1]) - nz(fbtc_b[2])
d1_gbtc = nz(gbtc_b[1]) - nz(gbtc_b[2])
d1_arkb = nz(arkb_b[1]) - nz(arkb_b[2])
d1_bitb = nz(bitb_b[1]) - nz(bitb_b[2])
d1_hodl = nz(hodl_b[1]) - nz(hodl_b[2])
d1_brrr = nz(brrr_b[1]) - nz(brrr_b[2])
d1_btco = nz(btco_b[1]) - nz(btco_b[2])
d1_btcw = nz(btcw_b[1]) - nz(btcw_b[2])
d1_ezbc = nz(ezbc_b[1]) - nz(ezbc_b[2])

// --- TOTAL FLOW ---
total_flow = d1_ibit + d1_fbtc + d1_gbtc + d1_arkb + d1_bitb + d1_hodl + d1_brrr + d1_btco + d1_btcw + d1_ezbc

// --- Z-SCORE TOTALE ---
z_mean = ta.sma(total_flow, zlen)
z_std  = ta.stdev(total_flow, zlen)
z_tot  = z_std > 0 ? (total_flow - z_mean) / z_std : 0.0

// --- Z-SCORE PER ETF ---
zscore(src) =>
    m = ta.sma(src, zlen)
    s = ta.stdev(src, zlen)
    s > 0 ? (src - m) / s : 0.0

z_ibit = zscore(d1_ibit)
z_fbtc = zscore(d1_fbtc)
z_gbtc = zscore(d1_gbtc)
z_arkb = zscore(d1_arkb)
z_bitb = zscore(d1_bitb)
z_hodl = zscore(d1_hodl)
z_brrr = zscore(d1_brrr)
z_btco = zscore(d1_btco)
z_btcw = zscore(d1_btcw)
z_ezbc = zscore(d1_ezbc)

// --- ROLLING MEAN Z-SCORE PER ETF (per tabella periodi) ---
za_ibit = ta.sma(z_ibit, per_a)
za_fbtc = ta.sma(z_fbtc, per_a)
za_gbtc = ta.sma(z_gbtc, per_a)
za_arkb = ta.sma(z_arkb, per_a)
za_bitb = ta.sma(z_bitb, per_a)
za_hodl = ta.sma(z_hodl, per_a)
za_brrr = ta.sma(z_brrr, per_a)
za_btco = ta.sma(z_btco, per_a)
za_btcw = ta.sma(z_btcw, per_a)
za_ezbc = ta.sma(z_ezbc, per_a)

zb_ibit = ta.sma(z_ibit, per_b)
zb_fbtc = ta.sma(z_fbtc, per_b)
zb_gbtc = ta.sma(z_gbtc, per_b)
zb_arkb = ta.sma(z_arkb, per_b)
zb_bitb = ta.sma(z_bitb, per_b)
zb_hodl = ta.sma(z_hodl, per_b)
zb_brrr = ta.sma(z_brrr, per_b)
zb_btco = ta.sma(z_btco, per_b)
zb_btcw = ta.sma(z_btcw, per_b)
zb_ezbc = ta.sma(z_ezbc, per_b)

zc_ibit = ta.sma(z_ibit, per_c)
zc_fbtc = ta.sma(z_fbtc, per_c)
zc_gbtc = ta.sma(z_gbtc, per_c)
zc_arkb = ta.sma(z_arkb, per_c)
zc_bitb = ta.sma(z_bitb, per_c)
zc_hodl = ta.sma(z_hodl, per_c)
zc_brrr = ta.sma(z_brrr, per_c)
zc_btco = ta.sma(z_btco, per_c)
zc_btcw = ta.sma(z_btcw, per_c)
zc_ezbc = ta.sma(z_ezbc, per_c)

// --- OSCILLATOR ---
p_zero   = plot(0.0,   color=color.new(col_txt, 70), linewidth=1, title="Zero")
plot(thresh_hi, color=color.new(col_pos, 50), linewidth=1, title="+Threshold")
plot(thresh_lo, color=color.new(col_neg, 50), linewidth=1, title="-Threshold")

ma_z    = ta.sma(z_tot, 7)
ma_col  = ma_z >= thresh_hi ? color.new(col_pos, 0) : ma_z <= thresh_lo ? color.new(col_neg, 0) : color.new(col_txt, 0)
plot(ma_z, color=ma_col, linewidth=2, title="MA 7 Z-Score")
bgcolor(ma_z >= thresh_hi ? color.new(col_pos, 40) : ma_z <= thresh_lo ? color.new(col_neg, 40) : na, force_overlay=true)
// --- HELPERS ---
fmt_z(v) =>
    s = v > 0 ? "▲ +" : v < 0 ? "▼ " : "= "
    s + str.tostring(math.round(v, 2)) + "σ"

bg(v) =>
    v >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)

// --- TABLE ---
tot_za = ta.sma(ma_z, per_a)
tot_zb = ta.sma(ma_z, per_b)
tot_zc = ta.sma(ma_z, per_c)

var table tbl = table.new(
     position.top_right, 5, 12,
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
    table.cell(tbl, 0, 0, "ETF",         text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 0, "Z now",       text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 0, "Z̄ " + lbl_a, text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 0, "Z̄ " + lbl_b, text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 4, 0, "Z̄ " + lbl_c, text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)

    names   = array.from("BlackRock (IBIT)", "Fidelity (FBTC)", "Grayscale (GBTC)", "ARK 21Shares (ARKB)", "Bitwise (BITB)", "VanEck (HODL)", "Valkyrie (BRRR)", "Invesco (BTCO)", "WisdomTree (BTCW)", "Franklin (EZBC)")
    etfcols = array.from(color.rgb(255,165,0), color.rgb(30,144,255), color.rgb(180,0,255), color.rgb(0,210,255), color.rgb(0,255,140), color.rgb(255,80,80), color.rgb(255,220,0), color.rgb(160,255,100), color.rgb(200,100,255), color.rgb(100,200,255))

    zn_arr = array.from(z_ibit, z_fbtc, z_gbtc, z_arkb, z_bitb, z_hodl, z_brrr, z_btco, z_btcw, z_ezbc)
    za_arr = array.from(za_ibit, za_fbtc, za_gbtc, za_arkb, za_bitb, za_hodl, za_brrr, za_btco, za_btcw, za_ezbc)
    zb_arr = array.from(zb_ibit, zb_fbtc, zb_gbtc, zb_arkb, zb_bitb, zb_hodl, zb_brrr, zb_btco, zb_btcw, zb_ezbc)
    zc_arr = array.from(zc_ibit, zc_fbtc, zc_gbtc, zc_arkb, zc_bitb, zc_hodl, zc_brrr, zc_btco, zc_btcw, zc_ezbc)

    for i = 0 to 9
        row = i + 1
        nm  = array.get(names,   i)
        c   = array.get(etfcols, i)
        vn  = array.get(zn_arr,  i)
        va  = array.get(za_arr,  i)
        vb  = array.get(zb_arr,  i)
        vc  = array.get(zc_arr,  i)

        row_bg = color.new(color.rgb(12, 12, 22), 0)
        table.cell(tbl, 0, row, nm,        bgcolor=row_bg,  text_color=c,           text_halign=text.align_left,   text_font_family=font.family_monospace)
        table.cell(tbl, 1, row, fmt_z(vn), bgcolor=bg(vn),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 2, row, fmt_z(va), bgcolor=bg(va),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 3, row, fmt_z(vb), bgcolor=bg(vb),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 4, row, fmt_z(vc), bgcolor=bg(vc),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)

    table.cell(tbl, 0, 11, "TOTAL",         bgcolor=col_hdr,       text_color=color.white, text_halign=text.align_left,   text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 11, fmt_z(ma_z),    bgcolor=bg(ma_z),     text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 11, fmt_z(tot_za),  bgcolor=bg(tot_za),   text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 11, fmt_z(tot_zb),  bgcolor=bg(tot_zb),   text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 4, 11, fmt_z(tot_zc),  bgcolor=bg(tot_zc),   text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
````
