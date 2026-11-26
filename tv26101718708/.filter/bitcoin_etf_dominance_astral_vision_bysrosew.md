# Bitcoin ETF Dominance | Astral Vision 

- url: https://www.tradingview.com/script/BySroSeW/
- type: indicator
- pine_id: PUB;52387f72928f4f95baf746bb5f903b49
- version: 1.0

## Description

[b]Bitcoin ETF Dominance | Astral Vision 🌠💠[/b]

Since the approval of spot Bitcoin ETFs in January 2024, institutional capital flows have become one of the most important signals in the Bitcoin market. But knowing the total ETF balance alone is not enough: what matters is which issuers are capturing market share, whether that share is shifting, and how fast those shifts are happening. This indicator tracks the internal competitive landscape of the US spot Bitcoin ETF ecosystem, showing in real time which products are gaining or losing dominance within the total ETF allocation and how that distribution is evolving across three configurable time windows.

The indicator fetches the on-chain Bitcoin balances of ten US spot ETFs from Glassnode and computes each issuer's percentage share of the total, updated daily. These shares are displayed as a stacked area chart where each band represents one ETF, making it immediately visible how the total pie is divided and how the boundaries between issuers are shifting over time. The table alongside provides the precise current dominance percentage for each ETF together with the change in that share over three configurable periods.

The dominance delta columns are the most actionable output. A positive delta for an issuer means it is capturing an increasing share of total ETF assets, indicating that new flows are preferentially entering that product or that other issuers are seeing net outflows. A negative delta means the issuer is losing share, which can happen either because it is experiencing outflows or because competitors are growing faster. These shifts in relative dominance often precede or accompany significant movements in total ETF flows, which in turn are a leading indicator for Bitcoin price action.


[b]Analytical Framework[/b]
Type of analysis: institutional flow structure, ETF market share dynamics
Recommended timeframe: daily chart. Best used as a macro context overlay for position trading and long-term analysis.
Signal type: continuous dominance tracking with configurable multi-period delta comparison

[b]How to interpret the signals[/b]

The stacked area chart provides a visual map of the ETF ecosystem at a glance. When a single issuer's band is expanding visually, it is capturing a disproportionate share of new inflows. When multiple bands are shifting simultaneously, it indicates a rotation between products rather than a change in total ETF appetite.

The table is where the actionable signals live. Focus on the dominance delta columns rather than the absolute dominance percentage. An issuer showing a large positive delta over the short period but a smaller positive delta over the long period is accelerating its market share capture, which is historically associated with that product being the primary destination for institutional inflows in the current cycle. An issuer showing consistent negative deltas across all three periods is losing share persistently, often because it carries higher fees or because a competing product has become the preferred vehicle for new institutional allocation.

BlackRock's IBIT has been the dominant flow vehicle since launch and its dominance delta is the most watched: when IBIT is gaining share, it typically means new institutional money is entering the market. When it is losing share to smaller issuers, it can indicate rotation by more sophisticated allocators toward lower-cost products, which is structurally bullish for the broader ETF ecosystem.

GBTC deserves special attention as the legacy product: persistent negative deltas for GBTC confirm that its structural outflow trend is continuing, which has historically been a source of selling pressure that absorbed bullish ETF inflows. When GBTC's negative delta begins to flatten, it removes a persistent headwind.

Use the three time windows together: short-period deltas for momentum, medium-period for trend, long-period for structural shift. When all three agree for a given issuer, the dominance trend is confirmed.

[b]How it differs from existing tools[/b]

Standard ETF flow indicators on TradingView display either the total Bitcoin balance across all ETFs or the flow for a single issuer, neither of which shows how the internal competitive structure of the ETF market is evolving. This indicator normalizes each issuer's balance to a percentage of the total, making the relative competitive dynamics visible in a way that absolute balance charts cannot. The three-period delta table provides temporal depth that a single current-day reading cannot, allowing the distinction between a momentary shift and a sustained structural trend.

[b]Plots 📊[/b]
[list]
[*]Stacked area chart with one band per ETF, color-coded by issuer, covering the full 0-100% range
[*]Table with current dominance percentage and configurable-period delta for all ten ETFs, color-coded by direction
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]Period A, B, C: the three lookback windows in days for the dominance delta columns in the table
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Infinito. Each ETF has a fixed distinct color in the stacked area chart for visual identification.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin ETF Dominance | Astral Vision 🌠💠", format=format.percent, precision=2, max_bars_back=500)

// --- GROUP: SETTINGS ---
per_a = input.int(7,  "Period A", group="Settings")
per_b = input.int(30, "Period B", group="Settings")
per_c = input.int(90, "Period C", group="Settings")

// --- GROUP: ASTRAL COLORS ---
theme      = input.string("Infinito", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes","Custom"], group="Astral Colors")
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

// --- TOTAL & DOMINANCE % ---
total = nz(ibit_b) + nz(fbtc_b) + nz(gbtc_b) + nz(arkb_b) + nz(bitb_b) + nz(hodl_b) + nz(brrr_b) + nz(btco_b) + nz(btcw_b) + nz(ezbc_b)

dom_ibit = total > 0 ? nz(ibit_b) / total * 100 : 0.0
dom_fbtc = total > 0 ? nz(fbtc_b) / total * 100 : 0.0
dom_gbtc = total > 0 ? nz(gbtc_b) / total * 100 : 0.0
dom_arkb = total > 0 ? nz(arkb_b) / total * 100 : 0.0
dom_bitb = total > 0 ? nz(bitb_b) / total * 100 : 0.0
dom_hodl = total > 0 ? nz(hodl_b) / total * 100 : 0.0
dom_brrr = total > 0 ? nz(brrr_b) / total * 100 : 0.0
dom_btco = total > 0 ? nz(btco_b) / total * 100 : 0.0
dom_btcw = total > 0 ? nz(btcw_b) / total * 100 : 0.0
dom_ezbc = total > 0 ? nz(ezbc_b) / total * 100 : 0.0

// --- STACKED LEVELS ---
l0  = 0.0
l1  = l0  + dom_ibit
l2  = l1  + dom_fbtc
l3  = l2  + dom_gbtc
l4  = l3  + dom_arkb
l5  = l4  + dom_bitb
l6  = l5  + dom_hodl
l7  = l6  + dom_brrr
l8  = l7  + dom_btco
l9  = l8  + dom_btcw
l10 = l9  + dom_ezbc

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
fmt_pct(v) =>
    str.tostring(math.round(v, 2)) + "%"

fmt_dpct(v) =>
    s = v > 0 ? "▲ +" : v < 0 ? "▼ " : "= "
    s + str.tostring(math.round(math.abs(v), 2)) + "%"

bg(v) =>
    v > 0 ? color.new(col_pos, 60) : v < 0 ? color.new(col_neg, 60) : color.new(col_txt, 80)

// --- TABLE ---
var table tbl = table.new(
     position.top_right, 5, 12,
     bgcolor=col_bg,
     border_color=col_bdr,
     border_width=1,
     frame_color=col_bdr,
     frame_width=1,
     force_overlay=true)

lbl_a = "Δ " + str.tostring(per_a) + "d"
lbl_b = "Δ " + str.tostring(per_b) + "d"
lbl_c = "Δ " + str.tostring(per_c) + "d"

if barstate.islast
    table.cell(tbl, 0, 0, "ETF",       text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 0, "Dom %",     text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 0, lbl_a,       text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 0, lbl_b,       text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 4, 0, lbl_c,       text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)

    names   = array.from("BlackRock (IBIT)", "Fidelity (FBTC)", "Grayscale (GBTC)", "ARK 21Shares (ARKB)", "Bitwise (BITB)", "VanEck (HODL)", "Valkyrie (BRRR)", "Invesco (BTCO)", "WisdomTree (BTCW)", "Franklin (EZBC)")
    etfcols = array.from(color.rgb(255,165,0), color.rgb(30,144,255), color.rgb(180,0,255), color.rgb(0,210,255), color.rgb(0,255,140), color.rgb(255,80,80), color.rgb(255,220,0), color.rgb(160,255,100), color.rgb(200,100,255), color.rgb(100,200,255))

    dom_arr = array.from(dom_ibit, dom_fbtc, dom_gbtc, dom_arkb, dom_bitb, dom_hodl, dom_brrr, dom_btco, dom_btcw, dom_ezbc)
    doma_arr = array.from(dom_ibit - dom_ibit[per_a], dom_fbtc - dom_fbtc[per_a], dom_gbtc - dom_gbtc[per_a], dom_arkb - dom_arkb[per_a], dom_bitb - dom_bitb[per_a], dom_hodl - dom_hodl[per_a], dom_brrr - dom_brrr[per_a], dom_btco - dom_btco[per_a], dom_btcw - dom_btcw[per_a], dom_ezbc - dom_ezbc[per_a])
    domb_arr = array.from(dom_ibit - dom_ibit[per_b], dom_fbtc - dom_fbtc[per_b], dom_gbtc - dom_gbtc[per_b], dom_arkb - dom_arkb[per_b], dom_bitb - dom_bitb[per_b], dom_hodl - dom_hodl[per_b], dom_brrr - dom_brrr[per_b], dom_btco - dom_btco[per_b], dom_btcw - dom_btcw[per_b], dom_ezbc - dom_ezbc[per_b])
    domc_arr = array.from(dom_ibit - dom_ibit[per_c], dom_fbtc - dom_fbtc[per_c], dom_gbtc - dom_gbtc[per_c], dom_arkb - dom_arkb[per_c], dom_bitb - dom_bitb[per_c], dom_hodl - dom_hodl[per_c], dom_brrr - dom_brrr[per_c], dom_btco - dom_btco[per_c], dom_btcw - dom_btcw[per_c], dom_ezbc - dom_ezbc[per_c])

    for i = 0 to 9
        row  = i + 1
        nm   = array.get(names,    i)
        c    = array.get(etfcols,  i)
        vd   = array.get(dom_arr,  i)
        va   = array.get(doma_arr, i)
        vb   = array.get(domb_arr, i)
        vc   = array.get(domc_arr, i)

        row_bg = color.new(color.rgb(12, 12, 22), 0)

        table.cell(tbl, 0, row, nm,          bgcolor=row_bg,  text_color=c,           text_halign=text.align_left,   text_font_family=font.family_monospace)
        table.cell(tbl, 1, row, fmt_pct(vd), bgcolor=row_bg,  text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 2, row, fmt_dpct(va),bgcolor=bg(va),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 3, row, fmt_dpct(vb),bgcolor=bg(vb),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)
        table.cell(tbl, 4, row, fmt_dpct(vc),bgcolor=bg(vc),  text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace)

    table.cell(tbl, 0, 11, "TOTAL",    bgcolor=col_hdr, text_color=color.white, text_halign=text.align_left,   text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 11, "100.00%",  bgcolor=col_hdr, text_color=color.white, text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 11, "—",        bgcolor=col_hdr, text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 11, "—",        bgcolor=col_hdr, text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 4, 11, "—",        bgcolor=col_hdr, text_color=col_txt,     text_halign=text.align_center,  text_font_family=font.family_monospace, text_formatting=text.format_bold)
````
