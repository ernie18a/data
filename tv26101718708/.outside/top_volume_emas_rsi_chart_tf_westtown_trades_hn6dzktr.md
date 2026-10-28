# Top Volume + EMAs + RSI [Chart TF] - Westtown Trades

- url: https://www.tradingview.com/script/Hn6DZkTR-Top-Volume-EMAs-RSI-Chart-TF-Westtown-Trades/
- type: indicator
- pine_id: PUB;0ce9ca10e1264953aeb1d5dc07086787
- version: 8.0

## Description

Top Volume + EMAs + RSI [Chart TF]  This powerful scanner displays a clean, real-time table of the top volume stocks from your chosen watchlist, sorted by today's trading volume. It combines high-volume activity with key technical signals (EMAs and RSI) all in one compact overlay-free table — perfect for quickly spotting momentum, unusual volume, and potential breakout candidates.Key Features:Volume Leaderboard — Shows today's volume, 7-day average volume, and the Volume Ratio (how many times above average).  
Multi-Timeframe EMA Direction — Instant visual arrows (▲/▼) for EMA 10, 20, 50, and 200 on the chart's current timeframe.  
RSI Analysis — Current RSI value with color coding:  Green = Oversold  
Red = Overbought  
White = Neutral

Fully Customizable —  Add any tickers (comma separated)  
Choose how many to display (Top 5–25)  
Table position, background colors, and header style  
RSI length and levels

How to Use:Add your favorite tickers in the settings (default: NVDA, AAPL, MSFT, GOOGL, AMZN).  
Set your desired number of rows and table position.  
Switch chart timeframes — the indicator automatically updates volume, EMAs, and RSI for the active timeframe.  
Look for high Volume Ratio + bullish EMA alignment + healthy RSI for strong momentum plays.

Ideal for day traders, swing traders, and momentum scanners who want to instantly see which stocks are seeing the heaviest activity combined with technical confirmation.Works on any chart timeframe and any symbol — the scanner runs independently of the chart’s main ticker.Pro Tip: Use this on a 5m or 15m chart during market hours to catch real-time volume surges.Enjoy spotting the next big movers!

## Source Code

````pine
//@version=6
indicator("Top Volume + EMAs + RSI + WaveTrend + Confluence + CHoCH + BOS + CHoCH+ + BOS+", shorttitle="Vol + Full SMC", overlay=false, max_bars_back=1000)

// ── Inputs ─────────────────────────────────────
tickers_input = input.string("SPY,QQQ, NVDA,AAPL,GOOGL,MSFT,AMZN,AVGO,META,TSLA,COST,NFLX,AMD,IREN,ONDS,PLTR,MARA,QCOM,RIOT,CLSK", 
     "Tickers (comma separated)")

top_n         = input.int(20, "Show Top N", minval=5, maxval=50)
table_pos     = input.string("Top Right", "Table Position", options=["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Center", "Bottom Left", "Middle Right", "Middle Center", "Middle Left"])
table_bg      = input.color(color.new(#1e222d, 0), "Table Background")
header_bg     = input.color(#363a45, "Header Background")
show_rank     = input.bool(true, "Show Rank")

// WaveTrend Settings
wt_channel = input.int(10, "WaveTrend Channel Length", minval=5, group="WaveTrend")
wt_average = input.int(21, "WaveTrend Average Length", minval=5, group="WaveTrend")
wt_signal  = input.int(4,  "WaveTrend Signal Length",  minval=1, group="WaveTrend")

// RSI Settings
rsi_length = input.int(14, "RSI Length", minval=2, maxval=50)
rsi_ob     = input.int(70, "RSI Overbought", minval=50, maxval=90)
rsi_os     = input.int(30, "RSI Oversold", minval=10, maxval=50)

// Confluence Settings
confluence_lookback = input.int(20, "Confluence Lookback Bars", minval=10, group="Confluence")
vol_multiplier      = input.float(1.8, "Volume Spike Multiplier", minval=1.2, group="Confluence")

// ── Table Position ─────
var string table_position = position.top_right
if barstate.isfirst
    table_position := table_pos == "Top Left"      ? position.top_left      :
                      table_pos == "Top Center"    ? position.top_center    :
                      table_pos == "Top Right"     ? position.top_right     :
                      table_pos == "Middle Left"   ? position.middle_left   :
                      table_pos == "Middle Center" ? position.middle_center :
                      table_pos == "Middle Right"  ? position.middle_right  :
                      table_pos == "Bottom Left"   ? position.bottom_left   :
                      table_pos == "Bottom Center" ? position.bottom_center :
                                                     position.bottom_right

// ── Parse Tickers ───────────────────────────────
sym_list = str.split(tickers_input, ",")
var string[] clean_symbols = array.new_string()

if barstate.isfirst
    for i = 0 to array.size(sym_list) - 1
        trimmed = str.trim(array.get(sym_list, i))
        if str.length(trimmed) > 0
            array.push(clean_symbols, trimmed)

// ── Table Setup (18 columns) ─────────────────────
var table volTable = table.new(table_position, 18, top_n + 2, bgcolor = table_bg, border_width = 1)

// ── Optimized Data Fetch ─────────────────────
get_symbol_data(string sym) =>
    [vol_today, avg7d, ema10_pos, ema20_pos, ema50_pos, ema200_pos, rsi_val, wt_now, wt_prev, confluence, choch, bos, choch_plus, bos_plus] = request.security(sym, timeframe.period,
         [
            volume,
            ta.sma(volume, 7),
            close > ta.ema(close, 10) ? "▲" : "▼",
            close > ta.ema(close, 20) ? "▲" : "▼",
            close > ta.ema(close, 50) ? "▲" : "▼",
            close > ta.ema(close, 200) ? "▲" : "▼",
            ta.rsi(close, rsi_length),
            
            // WaveTrend Current
            ta.crossover(ta.ema((hlc3 - ta.ema(hlc3, wt_channel)) / (0.015 * ta.ema(math.abs(hlc3 - ta.ema(hlc3, wt_channel)), wt_channel)), wt_average),
                         ta.sma(ta.ema((hlc3 - ta.ema(hlc3, wt_channel)) / (0.015 * ta.ema(math.abs(hlc3 - ta.ema(hlc3, wt_channel)), wt_channel)), wt_average), wt_signal)) ? "Buy Signal 🟢" :
            ta.crossover(ta.sma(ta.ema((hlc3 - ta.ema(hlc3, wt_channel)) / (0.015 * ta.ema(math.abs(hlc3 - ta.ema(hlc3, wt_channel)), wt_channel)), wt_average), wt_signal),
                         ta.ema((hlc3 - ta.ema(hlc3, wt_channel)) / (0.015 * ta.ema(math.abs(hlc3 - ta.ema(hlc3, wt_channel)), wt_channel)), wt_average)) ? "Sell Signal 🔴" : " - ",
            
            // WaveTrend Previous
            ta.crossover(ta.ema((hlc3[1] - ta.ema(hlc3[1], wt_channel)) / (0.015 * ta.ema(math.abs(hlc3[1] - ta.ema(hlc3[1], wt_channel)), wt_channel)), wt_average),
                         ta.sma(ta.ema((hlc3[1] - ta.ema(hlc3[1], wt_channel)) / (0.015 * ta.ema(math.abs(hlc3[1] - ta.ema(hlc3[1], wt_channel)), wt_channel)), wt_average), wt_signal)) ? "Buy Signal 🟢" :
            ta.crossover(ta.sma(ta.ema((hlc3[1] - ta.ema(hlc3[1], wt_channel)) / (0.015 * ta.ema(math.abs(hlc3[1] - ta.ema(hlc3[1], wt_channel)), wt_channel)), wt_average), wt_signal),
                         ta.ema((hlc3[1] - ta.ema(hlc3[1], wt_channel)) / (0.015 * ta.ema(math.abs(hlc3[1] - ta.ema(hlc3[1], wt_channel)), wt_channel)), wt_average)) ? "Sell Signal 🔴" : " - ",
            
            // Confluence
            (close > ta.highest(high[1], confluence_lookback) and volume > ta.sma(volume, 20) * vol_multiplier and close > ta.ema(close, 9)) ? "bullish" :
            (close < ta.lowest(low[1], confluence_lookback) and volume > ta.sma(volume, 20) * vol_multiplier and close < ta.ema(close, 9)) ? "bearish" : "none",
            
            // CHoCH
            (high > ta.highest(high[1], 25) and low[1] < ta.lowest(low[1], 10)) ? "bullish" :
            (low  < ta.lowest(low[1],  25) and high[1] > ta.highest(high[1], 10)) ? "bearish" : "none",
            
            // BOS
            (high > ta.highest(high[1], 20)) ? "bullish" :
            (low  < ta.lowest(low[1],  20)) ? "bearish" : "none",
            
            // CHoCH+
            (ta.barssince(high > ta.highest(high[1], 25) and low[1] < ta.lowest(low[1], 10)) <= 5 and 
             high > ta.highest(high[1], 25) and low[1] < ta.lowest(low[1], 10)) ? "bullish" :
            (ta.barssince(low  < ta.lowest(low[1],  25) and high[1] > ta.highest(high[1], 10)) <= 5 and 
             low  < ta.lowest(low[1],  25) and high[1] > ta.highest(high[1], 10)) ? "bearish" : "none",
            
            // BOS+
            (ta.barssince(high > ta.highest(high[1], 20)) <= 5 and high > ta.highest(high[1], 20)) ? "bullish" :
            (ta.barssince(low  < ta.lowest(low[1],  20)) <= 5 and low  < ta.lowest(low[1],  20)) ? "bearish" : "none"
         ], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    
    [vol_today, avg7d, ema10_pos, ema20_pos, ema50_pos, ema200_pos, rsi_val, wt_now, wt_prev, confluence, choch, bos, choch_plus, bos_plus]

// ── Main Logic ──────────────────────────────────
if barstate.islastconfirmedhistory or barstate.islast
    var float[]   today_vol      = array.new_float()
    var float[]   avg7d_vol      = array.new_float()
    var string[]  symbols        = array.new_string()
    var string[]  ema10_arr      = array.new_string()
    var string[]  ema20_arr      = array.new_string()
    var string[]  ema50_arr      = array.new_string()
    var string[]  ema200_arr     = array.new_string()
    var float[]   rsi_values     = array.new_float()
    var string[]  wt_now_arr     = array.new_string()
    var string[]  wt_prev_arr    = array.new_string()
    var string[]  confluence_arr = array.new_string()
    var string[]  choch_arr      = array.new_string()
    var string[]  bos_arr        = array.new_string()
    var string[]  choch_plus_arr = array.new_string()
    var string[]  bos_plus_arr   = array.new_string()

    array.clear(today_vol)
    array.clear(avg7d_vol)
    array.clear(symbols)
    array.clear(ema10_arr)
    array.clear(ema20_arr)
    array.clear(ema50_arr)
    array.clear(ema200_arr)
    array.clear(rsi_values)
    array.clear(wt_now_arr)
    array.clear(wt_prev_arr)
    array.clear(confluence_arr)
    array.clear(choch_arr)
    array.clear(bos_arr)
    array.clear(choch_plus_arr)
    array.clear(bos_plus_arr)

    for i = 0 to array.size(clean_symbols) - 1
        sym = array.get(clean_symbols, i)
        [vol_today, avg7d, e10, e20, e50, e200, rsi_val, wt_now, wt_prev, conf, ch, bs, ch_plus, bs_plus] = get_symbol_data(sym)

        if not na(vol_today) and vol_today > 0
            array.push(today_vol, vol_today)
            array.push(avg7d_vol, nz(avg7d))
            array.push(symbols, sym)
            array.push(ema10_arr, e10)
            array.push(ema20_arr, e20)
            array.push(ema50_arr, e50)
            array.push(ema200_arr, e200)
            array.push(rsi_values, nz(rsi_val, 50))
            array.push(wt_now_arr, wt_now)
            array.push(wt_prev_arr, wt_prev)
            array.push(confluence_arr, conf)
            array.push(choch_arr, ch)
            array.push(bos_arr, bs)
            array.push(choch_plus_arr, ch_plus)
            array.push(bos_plus_arr, bs_plus)

    if array.size(today_vol) > 0
        sorted_indices = array.sort_indices(today_vol, order.descending)

        // Header
        table.cell(volTable, 0, 0, "Rank",       bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 1, 0, "Ticker",     bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 2, 0, "Vol",        bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 3, 0, "Avg 7",      bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 4, 0, "Ratio",      bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 5, 0, "EMA10",      bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 6, 0, "EMA20",      bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 7, 0, "EMA50",      bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 8, 0, "EMA200",     bgcolor=header_bg, text_color=color.white)
        table.cell(volTable, 9, 0, "RSI",        bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,10, 0, "WT Signal",  bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,11, 0, "Prev",       bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,12, 0, "Confluence", bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,13, 0, "CHoCH",      bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,14, 0, "BOS",        bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,15, 0, "CHoCH+",     bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,16, 0, "BOS+",       bgcolor=header_bg, text_color=color.white)
        table.cell(volTable,17, 0, "Ticker",     bgcolor=header_bg, text_color=color.white)

        max_show = math.min(top_n, array.size(sorted_indices))
        for row = 1 to max_show
            idx = array.get(sorted_indices, row - 1)
            sym = array.get(symbols, idx)
            vol = array.get(today_vol, idx)
            avg = array.get(avg7d_vol, idx)
            rsi = array.get(rsi_values, idx)
            wt_n = array.get(wt_now_arr, idx)
            wt_p = array.get(wt_prev_arr, idx)
            conf = array.get(confluence_arr, idx)
            ch   = array.get(choch_arr, idx)
            bs   = array.get(bos_arr, idx)
            chp  = array.get(choch_plus_arr, idx)
            bsp  = array.get(bos_plus_arr, idx)

            vol_str   = str.tostring(math.round(vol / 1000000, 2), "#,###.##") + "M"
            avg_str   = str.tostring(math.round(avg / 1000000, 2), "#,###.##") + "M"
            ratio_str = str.tostring(avg > 0 ? vol / avg : 0, "#.##") + "x"

            rsi_color = rsi >= rsi_ob ? color.red : rsi <= rsi_os ? color.green : color.white

            table.cell(volTable, 0, row, show_rank ? str.tostring(row) : "", text_color=color.gray)
            table.cell(volTable, 1, row, sym, text_color=color.yellow)
            table.cell(volTable, 2, row, vol_str, text_color = vol > 5e7 ? color.lime : color.white)
            table.cell(volTable, 3, row, avg_str, text_color=color.aqua)
            table.cell(volTable, 4, row, ratio_str, text_color = (avg > 0 and vol/avg > 2) ? color.fuchsia : color.white)

            table.cell(volTable, 5, row, array.get(ema10_arr, idx),  text_color = array.get(ema10_arr, idx)  == "▲" ? color.lime : color.red)
            table.cell(volTable, 6, row, array.get(ema20_arr, idx),  text_color = array.get(ema20_arr, idx)  == "▲" ? color.lime : color.red)
            table.cell(volTable, 7, row, array.get(ema50_arr, idx),  text_color = array.get(ema50_arr, idx)  == "▲" ? color.lime : color.red)
            table.cell(volTable, 8, row, array.get(ema200_arr, idx), text_color = array.get(ema200_arr, idx) == "▲" ? color.lime : color.red)

            table.cell(volTable, 9, row, str.tostring(math.round(rsi, 1)), text_color=rsi_color)
            table.cell(volTable,10, row, wt_n, text_color = str.contains(wt_n, "Buy") ? color.lime : str.contains(wt_n, "Sell") ? color.red : color.white)
            table.cell(volTable,11, row, wt_p, text_color = str.contains(wt_p, "Buy") ? color.lime : str.contains(wt_p, "Sell") ? color.red : color.white)
            table.cell(volTable,12, row, conf, text_color = conf == "bullish" ? color.lime : conf == "bearish" ? color.red : color.gray)
            table.cell(volTable,13, row, ch == "bullish" or ch == "bearish" ? "CHoCH" : "", text_color = ch == "bullish" ? color.lime : ch == "bearish" ? color.red : color.gray)
            table.cell(volTable,14, row, bs == "bullish" or bs == "bearish" ? "BOS" : "", text_color = bs == "bullish" ? color.lime : bs == "bearish" ? color.red : color.gray)
            table.cell(volTable,15, row, chp == "bullish" or chp == "bearish" ? "CHoCH+" : "", text_color = chp == "bullish" ? color.lime : chp == "bearish" ? color.red : color.gray)
            table.cell(volTable,16, row, bsp == "bullish" or bsp == "bearish" ? "BOS+" : "", text_color = bsp == "bullish" ? color.lime : bsp == "bearish" ? color.red : color.gray)
            table.cell(volTable,17, row, sym, text_color=color.yellow)   // Duplicate Ticker column

        // Clear extra rows
        for r = max_show + 1 to top_n + 1
            for c = 0 to 17
                table.cell(volTable, c, r, "", bgcolor=table_bg)
````
