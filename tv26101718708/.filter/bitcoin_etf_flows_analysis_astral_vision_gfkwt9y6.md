# Bitcoin ETF Flows Analysis | Astral Vision 

- url: https://www.tradingview.com/script/gfkwt9y6/
- type: indicator
- pine_id: PUB;1c0ed09baeb743f4a1bc146177f9e6ef
- version: 1.0

## Description

[b]Bitcoin ETF Flows Analysis | Astral Vision 🌠💠[/b]

ETF flows are the single most watched institutional signal in the Bitcoin market since the launch of US spot products in January 2024. A positive flow day means authorized participants are creating new ETF shares by depositing Bitcoin into the trust, indicating net buying pressure from institutional and retail investors accessing Bitcoin through regulated wrappers. A negative flow day means shares are being redeemed and Bitcoin is leaving the trust, indicating net selling pressure. This indicator tracks those daily flows across all ten US spot Bitcoin ETFs simultaneously, breaks them down per issuer, and aggregates them across three configurable time windows so that both the current momentum and the medium-term trend of institutional accumulation are immediately visible.

The histogram plots the combined net daily flow across all selected ETFs in Bitcoin. Each bar represents the aggregate Bitcoin that moved into or out of the entire ETF ecosystem on that day. The optional mean line smooths this into a trend, filtering out the day-to-day noise of individual large transactions or weekend reporting distortions and revealing the underlying directional bias of institutional flows. The table provides the per-issuer breakdown across three rolling periods, making it possible to see not just the total but which products are driving or dragging the aggregate.

Each issuer can be toggled independently, allowing the aggregate to be computed for any subset of ETFs. This is particularly useful for isolating the behavior of a specific issuer cohort, such as comparing the new-launch products against GBTC, or analyzing the two largest products in isolation.


[b]Analytical Framework[/b]
Type of analysis: institutional flow tracking, ETF demand monitoring
Recommended timeframe: daily chart. Best used as a macro demand context overlay for position trading.
Signal type: daily net flow histogram with multi-period cumulative table

[b]How to interpret the signals[/b]

The histogram is the primary real-time signal. Consecutive positive days, especially with increasing bar height, indicate sustained institutional accumulation and historically correlate with upward price momentum. Consecutive negative days indicate persistent redemption pressure, which has historically been a headwind for price regardless of on-chain fundamentals. The transition from negative to positive histogram bars after a period of outflows has historically been one of the cleaner short-to-medium-term entry signals in the post-ETF Bitcoin market.

The mean line mode is more useful for identifying trend direction than individual days. When the smoothed line is rising and positive, institutional demand is structurally present. When it is flattening from positive territory, momentum is slowing even if individual days remain positive, which has historically been an early warning of near-term consolidation or correction. When the mean line turns negative, institutional selling is becoming the dominant force.

The table columns are where the most nuanced signals emerge. Look at each issuer's flow sum across all three periods simultaneously. An issuer showing large positive flows in the short period but flat or negative flows in the long period is accelerating recently after a previous pause, indicating fresh demand entering that product. An issuer showing the reverse is losing momentum. When GBTC shows persistent negative flows across all periods while other issuers show positive, the structural outflow from the legacy product is continuing, and the question is whether new-product inflows are more than offsetting it.

The total row at the bottom of the table is the most important single number: it shows whether the entire ETF complex is in net accumulation or net distribution across each time horizon. When the 7-day, 30-day, and 90-day totals are all positive and growing, the institutional bid is structurally strong. When they diverge, with short-term negative but long-term positive, the market is in a temporary pullback within an ongoing accumulation trend.

[b]How it differs from existing tools[/b]

Standard ETF flow tools on TradingView either display a single ETF's balance or a simple total without per-issuer breakdown. This indicator computes daily deltas from on-chain balance data for all ten issuers simultaneously, aggregates them with per-ETF toggle control, and provides rolling cumulative sums across three independent time windows per issuer. No standard TradingView indicator combines per-issuer flow isolation, multi-period rolling aggregation, and a toggleable issuer selection into a single tool.

[b]Plots 📊[/b]
[list]
[*]Daily net flow histogram across all selected ETFs in Bitcoin, colored positive or negative
[*]Optional smoothed mean line replacing the histogram for trend visualization
[*]Zero baseline
[*]Table with per-issuer cumulative flows across three configurable periods, plus aggregate total row, color-coded by direction
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]ETF toggles: individual on/off control for each of the ten US spot Bitcoin ETFs
[*]Period A, B, C: rolling windows in days for the three cumulative sum columns in the table
[*]Plot Mode: Daily histogram or smoothed Mean line
[*]Mean Length: smoothing period when Mean mode is selected
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Futura. Each ETF retains its fixed color in the table for consistency with the Dominance indicator.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Bitcoin ETF Flows Analysis | Astral Vision 🌠💠", format=format.volume, precision=0, max_bars_back=500)

// --- GROUP: ETF SELECTION ---
use_ibit = input.bool(true, "BlackRock (IBIT)",    group="ETF", inline="1")
use_fbtc = input.bool(true, "Fidelity (FBTC)",     group="ETF", inline="1")
use_gbtc = input.bool(true, "Grayscale (GBTC)",    group="ETF", inline="2")
use_arkb = input.bool(true, "ARK 21Shares (ARKB)", group="ETF", inline="2")
use_bitb = input.bool(true, "Bitwise (BITB)",      group="ETF", inline="3")
use_hodl = input.bool(true, "VanEck (HODL)",       group="ETF", inline="3")
use_brrr = input.bool(true, "Valkyrie (BRRR)",     group="ETF", inline="4")
use_btco = input.bool(true, "Invesco (BTCO)",      group="ETF", inline="4")
use_btcw = input.bool(true, "WisdomTree (BTCW)",   group="ETF", inline="5")
use_ezbc = input.bool(true, "Franklin (EZBC)",     group="ETF", inline="5")

// --- GROUP: SETTINGS ---
per_a = input.int(7,  "Period A (days)", minval=1, maxval=365, group="Settings")
per_b = input.int(30, "Period B (days)", minval=1, maxval=365, group="Settings")
per_c = input.int(90, "Period C (days)", minval=1, maxval=365, group="Settings")
plot_mode = input.string("Daily", "Plot Mode", options=["Daily", "Mean"], group="Settings")
mean_len  = input.int(14, "Mean Length", minval=1, maxval=365, group="Settings")

// --- GROUP: ASTRAL COLORS ---
theme      = input.string("Futura", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes","Custom"], group="Astral Colors")
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

// --- DAILY DELTA (shift di 1 per prendere ultimo giorno chiuso) ---
d1_ibit = use_ibit ? nz(ibit_b[1]) - nz(ibit_b[2]) : 0.0
d1_fbtc = use_fbtc ? nz(fbtc_b[1]) - nz(fbtc_b[2]) : 0.0
d1_gbtc = use_gbtc ? nz(gbtc_b[1]) - nz(gbtc_b[2]) : 0.0
d1_arkb = use_arkb ? nz(arkb_b[1]) - nz(arkb_b[2]) : 0.0
d1_bitb = use_bitb ? nz(bitb_b[1]) - nz(bitb_b[2]) : 0.0
d1_hodl = use_hodl ? nz(hodl_b[1]) - nz(hodl_b[2]) : 0.0
d1_brrr = use_brrr ? nz(brrr_b[1]) - nz(brrr_b[2]) : 0.0
d1_btco = use_btco ? nz(btco_b[1]) - nz(btco_b[2]) : 0.0
d1_btcw = use_btcw ? nz(btcw_b[1]) - nz(btcw_b[2]) : 0.0
d1_ezbc = use_ezbc ? nz(ezbc_b[1]) - nz(ezbc_b[2]) : 0.0

total_flow = d1_ibit + d1_fbtc + d1_gbtc + d1_arkb + d1_bitb + d1_hodl + d1_brrr + d1_btco + d1_btcw + d1_ezbc


// --- ROLLING SUMS PER ETF ---
sa_ibit = math.sum(d1_ibit, per_a)
sa_fbtc = math.sum(d1_fbtc, per_a)
sa_gbtc = math.sum(d1_gbtc, per_a)
sa_arkb = math.sum(d1_arkb, per_a)
sa_bitb = math.sum(d1_bitb, per_a)
sa_hodl = math.sum(d1_hodl, per_a)
sa_brrr = math.sum(d1_brrr, per_a)
sa_btco = math.sum(d1_btco, per_a)
sa_btcw = math.sum(d1_btcw, per_a)
sa_ezbc = math.sum(d1_ezbc, per_a)

sb_ibit = math.sum(d1_ibit, per_b)
sb_fbtc = math.sum(d1_fbtc, per_b)
sb_gbtc = math.sum(d1_gbtc, per_b)
sb_arkb = math.sum(d1_arkb, per_b)
sb_bitb = math.sum(d1_bitb, per_b)
sb_hodl = math.sum(d1_hodl, per_b)
sb_brrr = math.sum(d1_brrr, per_b)
sb_btco = math.sum(d1_btco, per_b)
sb_btcw = math.sum(d1_btcw, per_b)
sb_ezbc = math.sum(d1_ezbc, per_b)

sc_ibit = math.sum(d1_ibit, per_c)
sc_fbtc = math.sum(d1_fbtc, per_c)
sc_gbtc = math.sum(d1_gbtc, per_c)
sc_arkb = math.sum(d1_arkb, per_c)
sc_bitb = math.sum(d1_bitb, per_c)
sc_hodl = math.sum(d1_hodl, per_c)
sc_brrr = math.sum(d1_brrr, per_c)
sc_btco = math.sum(d1_btco, per_c)
sc_btcw = math.sum(d1_btcw, per_c)
sc_ezbc = math.sum(d1_ezbc, per_c)

float plot_val = plot_mode == "Mean" ? ta.sma(total_flow, mean_len) : total_flow

bar_col = plot_val >= 0 ? color.new(col_pos, 20) : color.new(col_neg, 20)

plot(plot_val,
     style = plot_mode == "Daily" ? plot.style_columns : plot.style_line,
     color = bar_col,
     linewidth = plot_mode == "Mean" ? 2 : 1)

plot(0, color=color.new(col_txt, 80), linewidth=1, title="Zero")

// --- HELPERS ---
fmt_d(v) =>
    s = v > 0 ? "▲ +" : v < 0 ? "▼ " : "= "
    a = math.abs(v)
    a >= 1e6 ? s + str.tostring(math.round(a / 1e6, 2)) + "M" :
     a >= 1e3 ? s + str.tostring(math.round(a / 1e3, 1)) + "K" :
     s + str.tostring(math.round(a))

bg(v) =>
    v > 0 ? color.new(col_pos, 60) : v < 0 ? color.new(col_neg, 60) : color.new(col_txt, 80)

var table tbl = table.new(
     position.top_right, 4, 12,
     bgcolor=col_bg,
     border_color=col_bdr,
     border_width=1,
     frame_color=col_bdr,
     frame_width=1,
     force_overlay=true)

lbl_a = "Σ " + str.tostring(per_a) + "d"
lbl_b = "Σ " + str.tostring(per_b) + "d"
lbl_c = "Σ " + str.tostring(per_c) + "d"

if barstate.islast
    table.cell(tbl, 0, 0, "ETF", text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 0, lbl_a, text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 0, lbl_b, text_color=col_pos, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 0, lbl_c, text_color=col_neg, bgcolor=col_hdr, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)

    names   = array.from("BlackRock (IBIT)", "Fidelity (FBTC)", "Grayscale (GBTC)", "ARK 21Shares (ARKB)", "Bitwise (BITB)", "VanEck (HODL)", "Valkyrie (BRRR)", "Invesco (BTCO)", "WisdomTree (BTCW)", "Franklin (EZBC)")
    etfcols = array.from(color.rgb(255,165,0), color.rgb(30,144,255), color.rgb(180,0,255), color.rgb(0,210,255), color.rgb(0,255,140), color.rgb(255,80,80), color.rgb(255,220,0), color.rgb(160,255,100), color.rgb(200,100,255), color.rgb(100,200,255))
    active  = array.from(use_ibit, use_fbtc, use_gbtc, use_arkb, use_bitb, use_hodl, use_brrr, use_btco, use_btcw, use_ezbc)
    sa_arr  = array.from(sa_ibit, sa_fbtc, sa_gbtc, sa_arkb, sa_bitb, sa_hodl, sa_brrr, sa_btco, sa_btcw, sa_ezbc)
    sb_arr  = array.from(sb_ibit, sb_fbtc, sb_gbtc, sb_arkb, sb_bitb, sb_hodl, sb_brrr, sb_btco, sb_btcw, sb_ezbc)
    sc_arr  = array.from(sc_ibit, sc_fbtc, sc_gbtc, sc_arkb, sc_bitb, sc_hodl, sc_brrr, sc_btco, sc_btcw, sc_ezbc)

    for i = 0 to 9
        row      = i + 1
        nm       = array.get(names,   i)
        c        = array.get(etfcols, i)
        act      = array.get(active,  i)
        va       = array.get(sa_arr,  i)
        vb       = array.get(sb_arr,  i)
        vc       = array.get(sc_arr,  i)

        row_bg   = color.new(color.rgb(12, 12, 22), 0)
        name_col = act ? c : color.new(c, 70)

        table.cell(tbl, 0, row, nm,                    bgcolor=row_bg,         text_color=name_col,    text_halign=text.align_left,   text_font_family=font.family_monospace)
        table.cell(tbl, 1, row, act ? fmt_d(va) : "—", bgcolor=act ? bg(va) : row_bg, text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
        table.cell(tbl, 2, row, act ? fmt_d(vb) : "—", bgcolor=act ? bg(vb) : row_bg, text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)
        table.cell(tbl, 3, row, act ? fmt_d(vc) : "—", bgcolor=act ? bg(vc) : row_bg, text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace)

    tot_a = array.get(sa_arr,0) + array.get(sa_arr,1) + array.get(sa_arr,2) + array.get(sa_arr,3) + array.get(sa_arr,4) + array.get(sa_arr,5) + array.get(sa_arr,6) + array.get(sa_arr,7) + array.get(sa_arr,8) + array.get(sa_arr,9)
    tot_b = array.get(sb_arr,0) + array.get(sb_arr,1) + array.get(sb_arr,2) + array.get(sb_arr,3) + array.get(sb_arr,4) + array.get(sb_arr,5) + array.get(sb_arr,6) + array.get(sb_arr,7) + array.get(sb_arr,8) + array.get(sb_arr,9)
    tot_c = array.get(sc_arr,0) + array.get(sc_arr,1) + array.get(sc_arr,2) + array.get(sc_arr,3) + array.get(sc_arr,4) + array.get(sc_arr,5) + array.get(sc_arr,6) + array.get(sc_arr,7) + array.get(sc_arr,8) + array.get(sc_arr,9)

    table.cell(tbl, 0, 11, "TOTAL",      bgcolor=col_hdr,  text_color=color.white, text_halign=text.align_left,   text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 1, 11, fmt_d(tot_a), bgcolor=bg(tot_a), text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 2, 11, fmt_d(tot_b), bgcolor=bg(tot_b), text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
    table.cell(tbl, 3, 11, fmt_d(tot_c), bgcolor=bg(tot_c), text_color=color.white, text_halign=text.align_center, text_font_family=font.family_monospace, text_formatting=text.format_bold)
````
