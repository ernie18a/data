# Jorden's Daily Watchlist

- url: https://www.tradingview.com/script/E22sbynI-Jorden-s-Daily-Watchlist/
- type: indicator
- pine_id: PUB;1c582d73f84449adbee3dde24001ee56
- version: 1.0

## Description

Daily watchlist for up to 20 stocks showing real-time positioning against premarket and prior day highs/lows. Each row displays last price, PMH, PML, PDH, and PDL with green/red cells indicating whether price is above or below each level. A consolidated Trend column flags full bullish alignment (price above both PMH and PDH) or full bearish alignment (price below both PML and PDL) for quick directional bias at a glance.

## Source Code

````pine
//@version=6
indicator("Daily Watchlist - PM/PD Levels", overlay=true)

// ============================================================
// INPUTS - 20 ticker slots you edit each morning
// ============================================================
grp_symbols = "Watchlist Symbols (edit daily)"
s01 = input.symbol("NASDAQ:AAPL", "01", group=grp_symbols)
s02 = input.symbol("NASDAQ:MSFT", "02", group=grp_symbols)
s03 = input.symbol("NASDAQ:NVDA", "03", group=grp_symbols)
s04 = input.symbol("NASDAQ:TSLA", "04", group=grp_symbols)
s05 = input.symbol("NASDAQ:AMZN", "05", group=grp_symbols)
s06 = input.symbol("NASDAQ:META", "06", group=grp_symbols)
s07 = input.symbol("NASDAQ:GOOGL", "07", group=grp_symbols)
s08 = input.symbol("NASDAQ:AMD",   "08", group=grp_symbols)
s09 = input.symbol("NASDAQ:NFLX",  "09", group=grp_symbols)
s10 = input.symbol("NYSE:BABA",    "10", group=grp_symbols)
s11 = input.symbol("AAPL", "11", group=grp_symbols)
s12 = input.symbol("AAPL", "12", group=grp_symbols)
s13 = input.symbol("AAPL", "13", group=grp_symbols)
s14 = input.symbol("AAPL", "14", group=grp_symbols)
s15 = input.symbol("AAPL", "15", group=grp_symbols)
s16 = input.symbol("AAPL", "16", group=grp_symbols)
s17 = input.symbol("AAPL", "17", group=grp_symbols)
s18 = input.symbol("AAPL", "18", group=grp_symbols)
s19 = input.symbol("AAPL", "19", group=grp_symbols)
s20 = input.symbol("AAPL", "20", group=grp_symbols)

// ============================================================
// DISPLAY OPTIONS
// ============================================================
grp_display = "Display"
tbl_pos     = input.string("Top Right", "Table Position", options=["Top Left","Top Right","Middle Right","Bottom Left","Bottom Right"], group=grp_display)
txt_size    = input.string("Small",     "Text Size",      options=["Tiny","Small","Normal","Large"], group=grp_display)
show_levels = input.bool(true, "Plot PM/PD levels for chart symbol", group=grp_display)

bull_col    = input.color(color.new(color.green, 70), "Above level color", group=grp_display)
bear_col    = input.color(color.new(color.red,   70), "Below level color", group=grp_display)
neutral_col = input.color(color.new(color.gray,  80), "Neutral / no data", group=grp_display)

trend_up_col   = input.color(color.new(color.green, 20), "Trend: Full upside", group=grp_display)
trend_down_col = input.color(color.new(color.red,   20), "Trend: Full downside", group=grp_display)
trend_mix_col  = input.color(color.new(color.gray,  60), "Trend: Mixed", group=grp_display)

// ============================================================
// SESSION DEFINITION - 4:00 AM to 9:30 AM ET premarket
// ============================================================
pm_session = "0400-0930:23456"

// ============================================================
// HELPER: get all 5 values for one symbol in ONE request.security call
// ============================================================
// We pull everything from the 1-minute timeframe in a single tuple:
//   - close (last price)
//   - rolling premarket high/low (using session filter)
//   - prior day's regular-session high/low
// 
// This reduces request.security calls from 5 per symbol to 1 per symbol.

get_levels(string sym) =>
    [last_price, pmh, pml, pdh, pdl] = request.security(sym, "1",
         [
             close,
             ta.highest(na(time("1", pm_session, "America/New_York")) ? na : high, 390),
             ta.lowest( na(time("1", pm_session, "America/New_York")) ? na : low,  390),
             request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on),
             request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
         ],
         ignore_invalid_symbol=true)
    [last_price, pmh, pml, pdh, pdl]

// ============================================================
// PULL DATA FOR ALL 20 SYMBOLS - now 20 calls total
// ============================================================
[p01, h01, l01, dh01, dl01] = get_levels(s01)
[p02, h02, l02, dh02, dl02] = get_levels(s02)
[p03, h03, l03, dh03, dl03] = get_levels(s03)
[p04, h04, l04, dh04, dl04] = get_levels(s04)
[p05, h05, l05, dh05, dl05] = get_levels(s05)
[p06, h06, l06, dh06, dl06] = get_levels(s06)
[p07, h07, l07, dh07, dl07] = get_levels(s07)
[p08, h08, l08, dh08, dl08] = get_levels(s08)
[p09, h09, l09, dh09, dl09] = get_levels(s09)
[p10, h10, l10, dh10, dl10] = get_levels(s10)
[p11, h11, l11, dh11, dl11] = get_levels(s11)
[p12, h12, l12, dh12, dl12] = get_levels(s12)
[p13, h13, l13, dh13, dl13] = get_levels(s13)
[p14, h14, l14, dh14, dl14] = get_levels(s14)
[p15, h15, l15, dh15, dl15] = get_levels(s15)
[p16, h16, l16, dh16, dl16] = get_levels(s16)
[p17, h17, l17, dh17, dl17] = get_levels(s17)
[p18, h18, l18, dh18, dl18] = get_levels(s18)
[p19, h19, l19, dh19, dl19] = get_levels(s19)
[p20, h20, l20, dh20, dl20] = get_levels(s20)

// ============================================================
// TREND HELPER - full alignment up / down / mixed
// ============================================================
f_trend(float price, float pmh, float pml, float pdh, float pdl) =>
    if na(price) or na(pmh) or na(pml) or na(pdh) or na(pdl)
        0
    else if price > pmh and price > pdh
        1
    else if price < pml and price < pdl
        -1
    else
        0

f_trend_txt(int t) =>
    t == 1 ? "UP" : t == -1 ? "DOWN" : "—"

f_trend_col(int t) =>
    t == 1 ? trend_up_col : t == -1 ? trend_down_col : trend_mix_col

// ============================================================
// TABLE BUILD
// ============================================================
tbl_position = tbl_pos == "Top Left" ? position.top_left : tbl_pos == "Top Right" ? position.top_right : tbl_pos == "Middle Right" ? position.middle_right : tbl_pos == "Bottom Left" ? position.bottom_left : position.bottom_right

tsize = txt_size == "Tiny" ? size.tiny : txt_size == "Small" ? size.small : txt_size == "Normal" ? size.normal : size.large

var table watchTbl = table.new(tbl_position, 7, 22, border_width=1, frame_color=color.new(color.gray, 50))

f_cell_col(float price, float level) =>
    na(price) or na(level) ? neutral_col : price >= level ? bull_col : bear_col

f_cell_txt(float level) =>
    na(level) ? "—" : str.tostring(level, format.mintick)

f_short(string sym) =>
    if sym == ""
        ""
    else
        parts = str.split(sym, ":")
        array.size(parts) > 1 ? array.get(parts, 1) : sym

if barstate.islast
    table.clear(watchTbl, 0, 0, 6, 21)

    hdr_bg = color.new(color.black, 30)
    table.cell(watchTbl, 0, 0, "Symbol", text_color=color.white, bgcolor=hdr_bg, text_size=tsize)
    table.cell(watchTbl, 1, 0, "Last",   text_color=color.white, bgcolor=hdr_bg, text_size=tsize)
    table.cell(watchTbl, 2, 0, "PMH",    text_color=color.white, bgcolor=hdr_bg, text_size=tsize)
    table.cell(watchTbl, 3, 0, "PML",    text_color=color.white, bgcolor=hdr_bg, text_size=tsize)
    table.cell(watchTbl, 4, 0, "PDH",    text_color=color.white, bgcolor=hdr_bg, text_size=tsize)
    table.cell(watchTbl, 5, 0, "PDL",    text_color=color.white, bgcolor=hdr_bg, text_size=tsize)
    table.cell(watchTbl, 6, 0, "Trend",  text_color=color.white, bgcolor=hdr_bg, text_size=tsize)

    syms   = array.from(s01, s02, s03, s04, s05, s06, s07, s08, s09, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20)
    prices = array.from(p01, p02, p03, p04, p05, p06, p07, p08, p09, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20)
    pmhs   = array.from(h01, h02, h03, h04, h05, h06, h07, h08, h09, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20)
    pmls   = array.from(l01, l02, l03, l04, l05, l06, l07, l08, l09, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20)
    pdhs   = array.from(dh01, dh02, dh03, dh04, dh05, dh06, dh07, dh08, dh09, dh10, dh11, dh12, dh13, dh14, dh15, dh16, dh17, dh18, dh19, dh20)
    pdls   = array.from(dl01, dl02, dl03, dl04, dl05, dl06, dl07, dl08, dl09, dl10, dl11, dl12, dl13, dl14, dl15, dl16, dl17, dl18, dl19, dl20)

    for i = 0 to 19
        sym   = array.get(syms,   i)
        price = array.get(prices, i)
        pmh   = array.get(pmhs,   i)
        pml   = array.get(pmls,   i)
        pdh   = array.get(pdhs,   i)
        pdl   = array.get(pdls,   i)
        row   = i + 1

        if sym == ""
            empty_bg = color.new(color.black, 90)
            table.cell(watchTbl, 0, row, "", bgcolor=empty_bg, text_size=tsize)
            table.cell(watchTbl, 1, row, "", bgcolor=empty_bg, text_size=tsize)
            table.cell(watchTbl, 2, row, "", bgcolor=empty_bg, text_size=tsize)
            table.cell(watchTbl, 3, row, "", bgcolor=empty_bg, text_size=tsize)
            table.cell(watchTbl, 4, row, "", bgcolor=empty_bg, text_size=tsize)
            table.cell(watchTbl, 5, row, "", bgcolor=empty_bg, text_size=tsize)
            table.cell(watchTbl, 6, row, "", bgcolor=empty_bg, text_size=tsize)
        else
            row_bg = color.new(color.black, 70)
            trend  = f_trend(price, pmh, pml, pdh, pdl)

            table.cell(watchTbl, 0, row, f_short(sym), text_color=color.white, bgcolor=row_bg, text_size=tsize)
            table.cell(watchTbl, 1, row, na(price) ? "—" : str.tostring(price, format.mintick), text_color=color.white, bgcolor=row_bg, text_size=tsize)
            table.cell(watchTbl, 2, row, f_cell_txt(pmh), text_color=color.white, bgcolor=f_cell_col(price, pmh), text_size=tsize)
            table.cell(watchTbl, 3, row, f_cell_txt(pml), text_color=color.white, bgcolor=f_cell_col(price, pml), text_size=tsize)
            table.cell(watchTbl, 4, row, f_cell_txt(pdh), text_color=color.white, bgcolor=f_cell_col(price, pdh), text_size=tsize)
            table.cell(watchTbl, 5, row, f_cell_txt(pdl), text_color=color.white, bgcolor=f_cell_col(price, pdl), text_size=tsize)
            table.cell(watchTbl, 6, row, f_trend_txt(trend), text_color=color.white, bgcolor=f_trend_col(trend), text_size=tsize, text_halign=text.align_center)

// ============================================================
// OPTIONAL: plot PM/PD levels for the chart's current symbol
// We reuse the values already pulled for whichever slot matches the chart symbol if possible,
// otherwise pull fresh in one bundled call.
// ============================================================
[chart_pmh, chart_pml, chart_pdh, chart_pdl] = request.security(syminfo.tickerid, "1",
     [
         ta.highest(na(time("1", pm_session, "America/New_York")) ? na : high, 390),
         ta.lowest( na(time("1", pm_session, "America/New_York")) ? na : low,  390),
         request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on),
         request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
     ])

plot(show_levels ? chart_pmh : na, "PMH", color=color.orange, style=plot.style_linebr, linewidth=1)
plot(show_levels ? chart_pml : na, "PML", color=color.orange, style=plot.style_linebr, linewidth=1)
plot(show_levels ? chart_pdh : na, "PDH", color=color.blue,   style=plot.style_linebr, linewidth=1)
plot(show_levels ? chart_pdl : na, "PDL", color=color.blue,   style=plot.style_linebr, linewidth=1)
````
