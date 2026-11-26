# Level Range Scanner-Watchlist

- url: https://www.tradingview.com/script/kU9pm1jb-Level-Range-Scanner-Watchlist/
- type: indicator
- pine_id: PUB;7bce4a4a72c340f5bc770b647b5b0cce
- version: 1.0

## Description

[b]Level Range Scanner — Watchlist[/b]

See how price is progressing toward your key levels across an entire watchlist at a glance. No more flipping between 18 charts wondering how much further a stock has to go before it tags premarket or prior-day levels — this scanner draws a live progress bar for every level on every symbol, so you can instantly see what's coiled and about to break.

[b]WHAT IT DOES[/b]
Track up to 20 symbols in a single on-chart table. For each ticker it monitors four critical intraday levels and shows you, with a filling progress bar, exactly how close price is to breaking each one:

- PDH — Previous Day High
- PDL — Previous Day Low
- PMH — Premarket High
- PML — Premarket Low

When price has room to run, you see a partially filled bar (more fill = closer to the level). The moment a level breaks, the bar flips to a green dot (high broken) or red dot (low broken) so confirmed breaks jump out instantly.

[b]HOW TO USE IT[/b]
1. Add the indicator to any intraday chart (1m–15m works best — it needs intraday data for premarket levels).
2. Open settings and type your tickers into Symbol 01–20. Leave slots blank to hide them.
3. Watch the table. Bars filling toward the top of a range = building pressure toward a breakout; bars filling toward the bottom = pressure toward a breakdown.
4. Set an alert (see below) and let it watch the list for you.

[b]READING THE COLUMNS[/b]
- Ticker / Price / Volume — Symbol, last price, and accumulated session volume (auto-formatted K/M/B).
- % Change — Move vs. the prior close — green up, red down.
- PDH / PDL Break — Progress bar from the opposite level toward the prior-day high/low. Green/red dot on break.
- PMH / PML Break — Same idea, for the premarket high/low.
- Trend — Up arrow = price broke BOTH PDH and PMH (bullish trend established). Down arrow = broke BOTH PDL and PML (bearish). Warning icon = mixed / not yet confirmed.

The Trend column is the headline signal: an up or down arrow means a symbol has cleared both its daily AND premarket level in the same direction — a higher-conviction continuation setup than a single-level poke.

[b]ALERTS[/b]
Use "LE Scanner Triggered." It fires whenever any watched symbol breaks both its premarket and prior-day level in the same direction (i.e. flips to an up or down arrow). Add it once and the scanner watches all 20 names for you in the background.

[b]SETTINGS[/b]
- Table Size / Position — fit it anywhere on your layout.
- Show Empty Rows — keep or hide blank symbol slots.

[b]NOTES[/b]
- Levels are calculated using extended-hours data (premarket/after-hours included), so PDH/PDL reflect the full trading day, not regular session only.
- Requires an intraday timeframe for the premarket columns to populate.
- Best on liquid stocks/ETFs where premarket and prior-day levels carry weight.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YakoCollins

//@version=6
indicator("Level Range Scanner-Watchlist", overlay=true)
// ===================================================================================================================
// INPUTS
// ===================================================================================================================
grp_ui = "UI Settings"
tbl_size_inp = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=grp_ui)
tbl_pos_inp  = input.string("Middle Right", "Table Position", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left", "Top Center", "Middle Center", "Bottom Center"], group=grp_ui)
show_empty   = input.bool(false, "Show Empty Rows", tooltip="Hide rows where symbol is empty.", group=grp_ui)
get_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge
get_pos(p) =>
    p == "Top Right" ? position.top_right : p == "Middle Right" ? position.middle_right : p == "Bottom Right" ? position.bottom_right : p == "Top Left" ? position.top_left : p == "Middle Left" ? position.middle_left : p == "Bottom Left" ? position.bottom_left : p == "Top Center" ? position.top_center : p == "Middle Center" ? position.middle_center : position.bottom_center
grp_sym = "Watchlist Symbols (Max 20)"
s1  = input.symbol("SPY", "Symbol 01", group=grp_sym)
s2  = input.symbol("QQQ", "Symbol 02", group=grp_sym)
s3  = input.symbol("IWM", "Symbol 03", group=grp_sym)
s4  = input.symbol("NVDA", "Symbol 04", group=grp_sym)
s5  = input.symbol("TSLA", "Symbol 05", group=grp_sym)
s6  = input.symbol("META", "Symbol 06", group=grp_sym)
s7  = input.symbol("PLTR", "Symbol 07", group=grp_sym)
s8  = input.symbol("MSFT", "Symbol 08", group=grp_sym)
s9  = input.symbol("AMD", "Symbol 09", group=grp_sym)
s10 = input.symbol("AAPL", "Symbol 10", group=grp_sym)
s11 = input.symbol("AMZN", "Symbol 11", group=grp_sym)
s12 = input.symbol("ORCL", "Symbol 12", group=grp_sym)
s13 = input.symbol("COIN", "Symbol 13", group=grp_sym)
s14 = input.symbol("AVGO", "Symbol 14", group=grp_sym)
s15 = input.symbol("GOOGL", "Symbol 15", group=grp_sym)
s16 = input.symbol("MSTR", "Symbol 16", group=grp_sym)
s17 = input.symbol("BAC", "Symbol 17", group=grp_sym)
s18 = input.symbol("INTC", "Symbol 18", group=grp_sym)
s19 = input.symbol("", "Symbol 19", group=grp_sym)
s20 = input.symbol("", "Symbol 20", group=grp_sym)
// ===================================================================================================================
// DATA FETCHING LOGIC
// ===================================================================================================================
f_get_ticker_data() =>
    var float cur_day_high = na
    var float cur_day_low = na
    var float pdh_val = na
    var float pdl_val = na
    var float p_close = na
    var float daily_vol = 0
    is_new_day = ta.change(time("D")) != 0
    if is_new_day
        pdh_val := cur_day_high
        pdl_val := cur_day_low
        p_close := close[1]
        cur_day_high := high
        cur_day_low := low
        daily_vol := volume
    else
        cur_day_high := math.max(nz(cur_day_high, high), high)
        cur_day_low := math.min(nz(cur_day_low, low), low)
        daily_vol += volume
    var float cur_pm_high = na
    var float cur_pm_low = na
    var float pmh_val = na
    var float pml_val = na
    is_premarket = session.ispremarket
    new_premarket = is_premarket and not is_premarket[1]
    is_market = session.ismarket
    new_market = is_market and not is_market[1]
    
    if new_premarket
        cur_pm_high := high
        cur_pm_low := low
    else if is_premarket
        cur_pm_high := math.max(nz(cur_pm_high, high), high)
        cur_pm_low := math.min(nz(cur_pm_low, low), low)
    if new_market
        pmh_val := cur_pm_high
        pml_val := cur_pm_low
    perc_change = na(p_close) ? na : ((close - p_close) / p_close * 100)
    [pdh_val, pdl_val, pmh_val, pml_val, close, daily_vol, perc_change]
get_ticker_id(sym) =>
    sym != "" ? ticker.modify(sym, session.extended) : ""
// Fetch all 20 streams
[pdh1, pdl1, pmh1, pml1, c1, v1, pc1] = request.security(get_ticker_id(s1), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh2, pdl2, pmh2, pml2, c2, v2, pc2] = request.security(get_ticker_id(s2), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh3, pdl3, pmh3, pml3, c3, v3, pc3] = request.security(get_ticker_id(s3), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh4, pdl4, pmh4, pml4, c4, v4, pc4] = request.security(get_ticker_id(s4), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh5, pdl5, pmh5, pml5, c5, v5, pc5] = request.security(get_ticker_id(s5), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh6, pdl6, pmh6, pml6, c6, v6, pc6] = request.security(get_ticker_id(s6), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh7, pdl7, pmh7, pml7, c7, v7, pc7] = request.security(get_ticker_id(s7), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh8, pdl8, pmh8, pml8, c8, v8, pc8] = request.security(get_ticker_id(s8), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh9, pdl9, pmh9, pml9, c9, v9, pc9] = request.security(get_ticker_id(s9), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh10, pdl10, pmh10, pml10, c10, v10, pc10] = request.security(get_ticker_id(s10), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh11, pdl11, pmh11, pml11, c11, v11, pc11] = request.security(get_ticker_id(s11), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh12, pdl12, pmh12, pml12, c12, v12, pc12] = request.security(get_ticker_id(s12), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh13, pdl13, pmh13, pml13, c13, v13, pc13] = request.security(get_ticker_id(s13), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh14, pdl14, pmh14, pml14, c14, v14, pc14] = request.security(get_ticker_id(s14), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh15, pdl15, pmh15, pml15, c15, v15, pc15] = request.security(get_ticker_id(s15), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh16, pdl16, pmh16, pml16, c16, v16, pc16] = request.security(get_ticker_id(s16), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh17, pdl17, pmh17, pml17, c17, v17, pc17] = request.security(get_ticker_id(s17), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh18, pdl18, pmh18, pml18, c18, v18, pc18] = request.security(get_ticker_id(s18), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh19, pdl19, pmh19, pml19, c19, v19, pc19] = request.security(get_ticker_id(s19), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
[pdh20, pdl20, pmh20, pml20, c20, v20, pc20] = request.security(get_ticker_id(s20), timeframe.period, f_get_ticker_data(), ignore_invalid_symbol=true)
a_sym = array.from(s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20)
a_pdh = array.from(pdh1, pdh2, pdh3, pdh4, pdh5, pdh6, pdh7, pdh8, pdh9, pdh10, pdh11, pdh12, pdh13, pdh14, pdh15, pdh16, pdh17, pdh18, pdh19, pdh20)
a_pdl = array.from(pdl1, pdl2, pdl3, pdl4, pdl5, pdl6, pdl7, pdl8, pdl9, pdl10, pdl11, pdl12, pdl13, pdl14, pdl15, pdl16, pdl17, pdl18, pdl19, pdl20)
a_pmh = array.from(pmh1, pmh2, pmh3, pmh4, pmh5, pmh6, pmh7, pmh8, pmh9, pmh10, pmh11, pmh12, pmh13, pmh14, pmh15, pmh16, pmh17, pmh18, pmh19, pmh20)
a_pml = array.from(pml1, pml2, pml3, pml4, pml5, pml6, pml7, pml8, pml9, pml10, pml11, pml12, pml13, pml14, pml15, pml16, pml17, pml18, pml19, pml20)
a_c   = array.from(c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20)
a_v   = array.from(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20)
a_pc  = array.from(pc1, pc2, pc3, pc4, pc5, pc6, pc7, pc8, pc9, pc10, pc11, pc12, pc13, pc14, pc15, pc16, pc17, pc18, pc19, pc20)
// ===================================================================================================================
// VISUAL LOGIC
// ===================================================================================================================
f_get_visual(price, start_price, target_price, is_bullish) =>
    if na(price) or na(start_price) or na(target_price)
        ""
    else
        if is_bullish
            if price >= target_price
                "🟢"
            else
                diff = target_price - start_price
                travel = price - start_price
                pct = diff > 0 ? (travel / diff) : 0
                pct := math.max(0, math.min(1, pct))
                if pct <= 0
                    ""
                else
                    filled = math.max(1, math.round(pct * 10)) // ensure at least 1 bar visible if pct > 0
                    empty = 10 - filled
                    str.repeat("█", filled) + str.repeat("┈", empty)
        else
            if price <= target_price
                "🔴"
            else
                diff = start_price - target_price
                travel = start_price - price
                pct = diff > 0 ? (travel / diff) : 0
                pct := math.max(0, math.min(1, pct))
                if pct <= 0
                    ""
                else
                    filled = math.max(1, math.round(pct * 10))
                    empty = 10 - filled
                    str.repeat("█", filled) + str.repeat("┈", empty)
f_format_vol(v) =>
    if na(v)
        "0"
    else if v >= 1000000000
        str.tostring(v / 1000000000, "#.##") + "B"
    else if v >= 1000000
        str.tostring(v / 1000000, "#.##") + "M"
    else if v >= 1000
        str.tostring(v / 1000, "#.##") + "K"
    else
        str.tostring(v, "#.##")
f_strip_exchange(s) =>
    arr = str.split(s, ":")
    array.size(arr) > 1 ? array.get(arr, 1) : s
// ===================================================================================================================
// TABLE RENDERING
// ===================================================================================================================
var table sc_tbl = table.new(get_pos(tbl_pos_inp), 9, 21, bgcolor=#131722, border_width=1, border_color=#363A45)
if barstate.islast
    table.cell(sc_tbl, 0, 0, "Ticker", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 1, 0, "Price", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 2, 0, "Volume", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 3, 0, "% Change", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 4, 0, "PDH Break", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 5, 0, "PDL Break", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 6, 0, "PMH Break", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 7, 0, "PML Break", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    table.cell(sc_tbl, 8, 0, "Trend", text_color=color.white, bgcolor=#1E222D, text_size=get_size(tbl_size_inp))
    int disp_row = 1
    for i = 0 to 19
        sym = array.get(a_sym, i)
        if sym == "" and not show_empty
            continue
            
        c   = array.get(a_c, i)
        pdh = array.get(a_pdh, i)
        pdl = array.get(a_pdl, i)
        pmh = array.get(a_pmh, i)
        pml = array.get(a_pml, i)
        v   = array.get(a_v, i)
        pc  = array.get(a_pc, i)
        
        is_pdh_brk = not na(pdh) and not na(c) and c >= pdh
        is_pdl_brk = not na(pdl) and not na(c) and c <= pdl
        is_pmh_brk = not na(pmh) and not na(c) and c >= pmh
        is_pml_brk = not na(pml) and not na(c) and c <= pml
        
        bool is_bull_trend = is_pdh_brk and is_pmh_brk
        bool is_bear_trend = is_pdl_brk and is_pml_brk
        
        color bg_trend = is_bull_trend ? color.lime : is_bear_trend ? color.red : na
        string text_trend = is_bull_trend ? "▲" : is_bear_trend ? "▼" : "⚠️"
        color tc_trend = is_bull_trend or is_bear_trend ? color.white : color.yellow
        
        string v_pdh = f_get_visual(c, pdl, pdh, true)
        string v_pdl = f_get_visual(c, pdh, pdl, false)
        string v_pmh = f_get_visual(c, pml, pmh, true)
        string v_pml = f_get_visual(c, pmh, pml, false)
        
        pc_tc = pc > 0 ? color.lime : pc < 0 ? color.red : color.white
        
        disp_sym = f_strip_exchange(sym == "" ? "-" : sym)
        table.cell(sc_tbl, 0, disp_row, disp_sym, text_color=color.white, text_size=get_size(tbl_size_inp))
        table.cell(sc_tbl, 1, disp_row, na(c) ? "-" : str.tostring(c, "#.##"), text_color=color.white, text_size=get_size(tbl_size_inp))
        table.cell(sc_tbl, 2, disp_row, f_format_vol(v), text_color=color.white, text_size=get_size(tbl_size_inp))
        table.cell(sc_tbl, 3, disp_row, na(pc) ? "-" : str.tostring(pc, "#.##")+"%", text_color=pc_tc, text_size=get_size(tbl_size_inp))
        
        table.cell(sc_tbl, 4, disp_row, v_pdh, text_color=color.lime, text_size=get_size(tbl_size_inp), text_halign=(v_pdh == "🟢" or v_pdh == "🔴" ? text.align_center : text.align_left))
        table.cell(sc_tbl, 5, disp_row, v_pdl, text_color=color.red, text_size=get_size(tbl_size_inp), text_halign=(v_pdl == "🟢" or v_pdl == "🔴" ? text.align_center : text.align_left))
        table.cell(sc_tbl, 6, disp_row, v_pmh, text_color=color.lime, text_size=get_size(tbl_size_inp), text_halign=(v_pmh == "🟢" or v_pmh == "🔴" ? text.align_center : text.align_left))
        table.cell(sc_tbl, 7, disp_row, v_pml, text_color=color.red, text_size=get_size(tbl_size_inp), text_halign=(v_pml == "🟢" or v_pml == "🔴" ? text.align_center : text.align_left))
        
        table.cell(sc_tbl, 8, disp_row, text_trend, text_color=tc_trend, bgcolor=bg_trend, text_size=get_size(tbl_size_inp))
        
        disp_row += 1
// ===================================================================================================================
// ALERTS
// ===================================================================================================================
bool trigger_alert = false
for i = 0 to 19
    sym = array.get(a_sym, i)
    if sym != ""
        c   = array.get(a_c, i)
        pdh = array.get(a_pdh, i)
        pdl = array.get(a_pdl, i)
        pmh = array.get(a_pmh, i)
        pml = array.get(a_pml, i)
        is_pdh_brk = not na(pdh) and not na(c) and c >= pdh
        is_pdl_brk = not na(pdl) and not na(c) and c <= pdl
        is_pmh_brk = not na(pmh) and not na(c) and c >= pmh
        is_pml_brk = not na(pml) and not na(c) and c <= pml
        
        if (is_pdh_brk and is_pmh_brk) or (is_pdl_brk and is_pml_brk)
            trigger_alert := true
alertcondition(trigger_alert, "LE Scanner Triggered", "A watched symbol breached both PM and Daily levels! Trend established.")
````
