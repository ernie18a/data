# Bitcoin ETF Holdings Analysis | Astral Vision 

- url: https://www.tradingview.com/script/SdnBvtaw/
- type: indicator
- pine_id: PUB;b9aef27a8cbb4b10ab17e7330415bd7d
- version: 1.0

## Description

[b]Bitcoin ETF Holdings Analysis | Astral Vision 🌠💠[/b]

Knowing how much Bitcoin the ETFs hold today is only half the picture. What institutional analysts and serious traders actually watch is how those holdings are changing: whether the aggregate balance is growing or shrinking, at what rate, and which specific products are driving that change. This indicator provides that complete picture in a single view, combining a stacked area chart of absolute on-chain holdings across all ten US spot Bitcoin ETFs with a detailed table that shows the rate of change and raw Bitcoin delta for each issuer across two configurable time periods.

The stacked area chart plots the total Bitcoin held across all ten ETFs as a cumulative area, with each issuer's contribution as its own color-coded band. This makes it immediately visible not only how the total is evolving but also how the internal composition is shifting. A rising total with one band expanding rapidly indicates that a specific product is driving the accumulation. A flat or falling total with bands shifting relative to each other indicates rotation between products rather than net new demand.

The table provides the quantitative detail behind what the chart shows visually. For each ETF, it displays the current holdings in BTC and USD, the percentage rate of change over two configurable lookback periods, and the absolute Bitcoin delta over the same periods. The combination of rate of change and raw delta is deliberately designed to give two different analytical perspectives simultaneously: the rate of change shows whether the pace of accumulation is historically significant for that product, while the raw delta shows the absolute quantity of Bitcoin moving in absolute terms.


[b]Analytical Framework[/b]
Type of analysis: institutional custody tracking, absolute ETF holdings monitoring
Recommended timeframe: daily chart, best used as a structural demand context layer for position trading and long-term analysis.
Signal type: absolute holdings tracking with multi-period rate of change and raw delta per issuer

[b]How to interpret the signals[/b]

The stacked chart is the macro view. A steadily rising top line means the aggregate institutional Bitcoin custody is growing, which is structurally bullish regardless of short-term price action. A flattening or declining top line means institutional accumulation has stalled or reversed, which historically has preceded or accompanied price weakness. The shape of the individual bands tells you where demand is concentrated: when a single band is expanding disproportionately, that product is capturing the lion's share of new institutional allocation.

The table is where you make practical decisions. The ROC columns tell you whether the pace of holdings change is accelerating or decelerating. A product with a strongly positive short-period ROC and a weaker long-period ROC is accelerating recently after a period of slower growth, indicating fresh institutional interest in that specific vehicle. A product with the reverse, strong long-period ROC but weakening short-period, is showing momentum deceleration and may be approaching a plateau.

The raw delta columns are particularly important for GBTC. Because GBTC started with an enormous legacy balance, even a small negative percentage ROC translates to a very large absolute Bitcoin outflow. Watching the absolute delta column for GBTC tells you the actual Bitcoin quantity leaving that product each week or month, which directly represents selling pressure that the market must absorb from new-product inflows.

The total row at the bottom is the single most important summary: it tells you in plain numbers how many Bitcoin have entered or left the entire ETF ecosystem over each time window. When both periods show a positive delta, institutional custody is growing on both short and medium horizons, a structurally supportive condition. When the short-period delta turns negative while the long-period remains positive, a temporary pause or reversal is occurring within an ongoing accumulation trend.

[b]How it differs from existing tools[/b]

Standard on-chain ETF trackers display either a single product's balance or a simple total without per-issuer breakdown or rate-of-change context. This indicator provides both BTC and USD holdings simultaneously for each of the ten issuers, computes percentage ROC and absolute delta independently across two configurable periods, and renders the full composition as a stacked area chart. No standard TradingView indicator combines all-issuer absolute custody tracking, dual-metric multi-period analysis, and stacked composition visualization in a single tool.

[b]Plots 📊[/b]
[list]
[*]Stacked area chart showing total Bitcoin holdings across all ten ETFs with per-issuer color-coded bands
[*]Table with current BTC holdings, current USD holdings, short and long-period ROC, and short and long-period absolute BTC delta for all ten ETFs plus aggregate total row
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Period A: short lookback window in days for the first ROC and delta columns
[*]Period B: medium lookback window in days for the second ROC and delta columns
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura. Each ETF retains its fixed color across all indicators in the ETF suite for visual consistency.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin ETF Holdings Analysis | Astral Vision 🌠💠", format=format.volume, precision=0, max_bars_back=500)

// --- GROUP 1: SETTINGS ---
per_a = input.int(7,  "Period A", minval=1, maxval=365, group="Settings")
per_b = input.int(30, "Period B", minval=1, maxval=365, group="Settings")

// --- GROUP 2: ASTRAL COLORS ---
theme = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes","Custom"], group="Astral Colors")
custom_pos = input.color(color.rgb(0, 255, 180), "Custom Positive", group="Astral Colors")
custom_neg = input.color(color.rgb(180, 0, 255), "Custom Negative", group="Astral Colors")

col_pos = theme == "Inferno"  ? color.rgb(255, 0, 0)     :
          theme == "Paradiso" ? color.rgb(0, 210, 255)   :
          theme == "Futura"   ? color.rgb(0, 255, 180)   :
          theme == "Infinito" ? color.rgb(180, 120, 255) :
          theme == "Hermes"   ? color.rgb(255, 160, 0)   :
          custom_pos

col_neg = theme == "Inferno"  ? color.rgb(120, 0, 0)     :
          theme == "Paradiso" ? color.rgb(0, 80, 160)    :
          theme == "Futura"   ? color.rgb(180, 0, 255)   :
          theme == "Infinito" ? color.rgb(255, 220, 80)  :
          theme == "Hermes"   ? color.rgb(0, 180, 120)   :
          custom_neg

col_hdr = color.rgb(10, 10, 20)
col_bg  = color.rgb(8, 8, 16)
col_txt = color.rgb(200, 200, 220)
col_bdr = color.rgb(30, 30, 50)

tf = "1D"

// --- DATA ---
ibit_btc = request.security("GLASSNODE:BTC_IBIT_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
fbtc_btc = request.security("GLASSNODE:BTC_FBTC_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
gbtc_btc = request.security("GLASSNODE:BTC_GBTC_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
arkb_btc = request.security("GLASSNODE:BTC_ARKB_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
bitb_btc = request.security("GLASSNODE:BTC_BITB_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
hodl_btc = request.security("GLASSNODE:BTC_HODL_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
brrr_btc = request.security("GLASSNODE:BTC_BRRR_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
btco_btc = request.security("GLASSNODE:BTC_BTCO_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
btcw_btc = request.security("GLASSNODE:BTC_BTCW_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)
ezbc_btc = request.security("GLASSNODE:BTC_EZBC_USSPOTETFBALANCES",    tf, close, ignore_invalid_symbol=true)

ibit_usd = request.security("GLASSNODE:BTC_IBIT_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
fbtc_usd = request.security("GLASSNODE:BTC_FBTC_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
gbtc_usd = request.security("GLASSNODE:BTC_GBTC_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
arkb_usd = request.security("GLASSNODE:BTC_ARKB_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
bitb_usd = request.security("GLASSNODE:BTC_BITB_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
hodl_usd = request.security("GLASSNODE:BTC_HODL_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
brrr_usd = request.security("GLASSNODE:BTC_BRRR_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
btco_usd = request.security("GLASSNODE:BTC_BTCO_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
btcw_usd = request.security("GLASSNODE:BTC_BTCW_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)
ezbc_usd = request.security("GLASSNODE:BTC_EZBC_USSPOTETFBALANCESUSD", tf, close, ignore_invalid_symbol=true)

// --- STACKED LEVELS ---
l0  = 0.0
l1  = l0  + nz(ibit_btc)
l2  = l1  + nz(fbtc_btc)
l3  = l2  + nz(gbtc_btc)
l4  = l3  + nz(arkb_btc)
l5  = l4  + nz(bitb_btc)
l6  = l5  + nz(hodl_btc)
l7  = l6  + nz(brrr_btc)
l8  = l7  + nz(btco_btc)
l9  = l8  + nz(btcw_btc)
l10 = l9  + nz(ezbc_btc)

p0  = plot(l0,  display=display.none)
p1  = plot(l1,  color=color.new(color.white, 60), linewidth=1)
p2  = plot(l2,  color=color.new(color.white, 60), linewidth=1)
p3  = plot(l3,  color=color.new(color.white, 60), linewidth=1)
p4  = plot(l4,  color=color.new(color.white, 60), linewidth=1)
p5  = plot(l5,  color=color.new(color.white, 60), linewidth=1)
p6  = plot(l6,  color=color.new(color.white, 60), linewidth=1)
p7  = plot(l7,  color=color.new(color.white, 60), linewidth=1)
p8  = plot(l8,  color=color.new(color.white, 60), linewidth=1)
p9  = plot(l9,  color=color.new(color.white, 60), linewidth=1)
p10 = plot(l10, color=color.new(color.white, 60), linewidth=1)

fill(p0,  p1,  color.new(color.rgb(255, 165,   0), 20))
fill(p1,  p2,  color.new(color.rgb( 30, 144, 255), 20))
fill(p2,  p3,  color.new(color.rgb(180,   0, 255), 20))
fill(p3,  p4,  color.new(color.rgb(  0, 210, 255), 20))
fill(p4,  p5,  color.new(color.rgb(  0, 255, 140), 20))
fill(p5,  p6,  color.new(color.rgb(255,  80,  80), 20))
fill(p6,  p7,  color.new(color.rgb(255, 220,   0), 20))
fill(p7,  p8,  color.new(color.rgb(160, 255, 100), 20))
fill(p8,  p9,  color.new(color.rgb(200, 100, 255), 20))
fill(p9,  p10, color.new(color.rgb(100, 200, 255), 20))

// --- HELPERS ---
fmt_btc(v) =>
    str.tostring(math.round(v), format.volume) + " ₿"

fmt_usd(v) =>
    a = math.abs(v)
    s = v < 0 ? "-$" : "$"
    a >= 1e9 ? s + str.tostring(math.round(a / 1e9, 2)) + "B" :
     a >= 1e6 ? s + str.tostring(math.round(a / 1e6, 1)) + "M" :
     s + str.tostring(math.round(a / 1e3), "#,###") + "K"

fmt_roc(v) =>
    s = v >= 0 ? "▲ +" : "▼ "
    s + str.tostring(math.round(v, 2)) + "%"

fmt_delta(v) =>
    s = v >= 0 ? "▲ +" : "▼ "
    s + str.tostring(math.round(math.abs(v)), format.volume)

roc(cur, prev) =>
    (na(prev) or prev == 0) ? float(na) : (cur - prev) / prev * 100

// --- TABLE ---
var table tbl = table.new(
     position.top_right, 7, 12,
     bgcolor=col_bg,
     border_color=col_bdr,
     border_width=1,
     frame_color=col_bdr,
     frame_width=1,
     force_overlay=true)

lbl_a = "ROC " + str.tostring(per_a) + "d"
lbl_b = "ROC " + str.tostring(per_b) + "d"
lbl_da = "Δ " + str.tostring(per_a) + "d (BTC)"
lbl_db = "Δ " + str.tostring(per_b) + "d (BTC)"

if barstate.islast
    table.cell(tbl, 0, 0, "ETF",    text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 0, "Holdings BTC", text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 0, "Holdings USD", text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 0, lbl_a,    text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 4, 0, lbl_da,   text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 5, 0, lbl_b,    text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 6, 0, lbl_db,   text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)

    names  = array.from("BlackRock (IBIT)", "Fidelity (FBTC)", "Grayscale (GBTC)", "ARK 21Shares (ARKB)", "Bitwise (BITB)", "VanEck (HODL)", "Valkyrie (BRRR)", "Invesco (BTCO)", "WisdomTree (BTCW)", "Franklin (EZBC)")
    colors = array.from(
         color.rgb(255, 165,   0),
         color.rgb( 30, 144, 255),
         color.rgb(180,   0, 255),
         color.rgb(  0, 210, 255),
         color.rgb(  0, 255, 140),
         color.rgb(255,  80,  80),
         color.rgb(255, 220,   0),
         color.rgb(160, 255, 100),
         color.rgb(200, 100, 255),
         color.rgb(100, 200, 255))

    btc_arr  = array.from(ibit_btc, fbtc_btc, gbtc_btc, arkb_btc, bitb_btc, hodl_btc, brrr_btc, btco_btc, btcw_btc, ezbc_btc)
    usd_arr  = array.from(ibit_usd, fbtc_usd, gbtc_usd, arkb_usd, bitb_usd, hodl_usd, brrr_usd, btco_usd, btcw_usd, ezbc_usd)
    btca_arr = array.from(ibit_btc[per_a], fbtc_btc[per_a], gbtc_btc[per_a], arkb_btc[per_a], bitb_btc[per_a], hodl_btc[per_a], brrr_btc[per_a], btco_btc[per_a], btcw_btc[per_a], ezbc_btc[per_a])
    btcb_arr = array.from(ibit_btc[per_b], fbtc_btc[per_b], gbtc_btc[per_b], arkb_btc[per_b], bitb_btc[per_b], hodl_btc[per_b], brrr_btc[per_b], btco_btc[per_b], btcw_btc[per_b], ezbc_btc[per_b])

    for i = 0 to 9
        row    = i + 1
        cur    = array.get(btc_arr,  i)
        curusd = array.get(usd_arr,  i)
        pa     = array.get(btca_arr, i)
        pb     = array.get(btcb_arr, i)
        c      = array.get(colors,   i)
        nm     = array.get(names,    i)

        ra  = roc(cur, pa)
        da  = cur - pa
        rb  = roc(cur, pb)
        db  = cur - pb

        ra_bg  = na(ra) ? col_bg : ra >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)
        da_bg  = na(da) ? col_bg : da >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)
        rb_bg  = na(rb) ? col_bg : rb >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)
        db_bg  = na(db) ? col_bg : db >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)

        row_bg = color.new(color.rgb(12, 12, 22), 0)

        table.cell(tbl, 0, row, nm,                                  bgcolor=row_bg, text_color=c,           text_halign=text.align_left,   text_font_family=font.family_monospace)
        table.cell(tbl, 1, row, na(cur)    ? "—" : fmt_btc(cur),     bgcolor=row_bg, text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 2, row, na(curusd) ? "—" : fmt_usd(curusd),  bgcolor=row_bg, text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 3, row, na(ra)     ? "—" : fmt_roc(ra),      bgcolor=ra_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 4, row, na(da)     ? "—" : fmt_delta(da),    bgcolor=da_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 5, row, na(rb)     ? "—" : fmt_roc(rb),      bgcolor=rb_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 6, row, na(db)     ? "—" : fmt_delta(db),    bgcolor=db_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)

    tot_btc = nz(ibit_btc)+nz(fbtc_btc)+nz(gbtc_btc)+nz(arkb_btc)+nz(bitb_btc)+nz(hodl_btc)+nz(brrr_btc)+nz(btco_btc)+nz(btcw_btc)+nz(ezbc_btc)
    tot_usd = nz(ibit_usd)+nz(fbtc_usd)+nz(gbtc_usd)+nz(arkb_usd)+nz(bitb_usd)+nz(hodl_usd)+nz(brrr_usd)+nz(btco_usd)+nz(btcw_usd)+nz(ezbc_usd)
    tota    = nz(ibit_btc[per_a])+nz(fbtc_btc[per_a])+nz(gbtc_btc[per_a])+nz(arkb_btc[per_a])+nz(bitb_btc[per_a])+nz(hodl_btc[per_a])+nz(brrr_btc[per_a])+nz(btco_btc[per_a])+nz(btcw_btc[per_a])+nz(ezbc_btc[per_a])
    totb    = nz(ibit_btc[per_b])+nz(fbtc_btc[per_b])+nz(gbtc_btc[per_b])+nz(arkb_btc[per_b])+nz(bitb_btc[per_b])+nz(hodl_btc[per_b])+nz(brrr_btc[per_b])+nz(btco_btc[per_b])+nz(btcw_btc[per_b])+nz(ezbc_btc[per_b])

    tra  = roc(tot_btc, tota)
    tda  = tot_btc - tota
    trb  = roc(tot_btc, totb)
    tdb  = tot_btc - totb

    tra_bg  = tra >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)
    tda_bg  = tda >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)
    trb_bg  = trb >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)
    tdb_bg  = tdb >= 0 ? color.new(col_pos, 60) : color.new(col_neg, 60)

    table.cell(tbl, 0, 11, "TOTAL",          bgcolor=col_hdr, text_color=color.white, text_halign=text.align_left,   text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 11, fmt_btc(tot_btc), bgcolor=col_hdr, text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 11, fmt_usd(tot_usd), bgcolor=col_hdr, text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 11, fmt_roc(tra),     bgcolor=tra_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 4, 11, fmt_delta(tda),   bgcolor=tda_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 5, 11, fmt_roc(trb),     bgcolor=trb_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 6, 11, fmt_delta(tdb),   bgcolor=tdb_bg,  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
````
