# Top 15-Min Volume Tickers + 7D Avg

- url: https://www.tradingview.com/script/ye9MH3XR-Top-15-Min-Volume-Tickers-7D-Avg/
- type: indicator
- pine_id: PUB;50043981680846319c33453b90bf57fe
- version: 1.0

## Description

Top 15-Min Volume Leaders + 7D AvgDisplays a real-time table of the highest volume stocks/crypto over the last 15 minutes, ranked from a custom watchlist (default Top 50 market cap). Includes:Current 15-minute volume
Average daily volume over the past 7 days
Volume ratio (15m vs 7D avg) to highlight unusual activity

Perfect for spotting volume surges and momentum opportunities quickly. Fully customizable ticker list and refresh settings.

## Source Code

````pine
//@version=6
indicator("Top 15-Min Volume Tickers + 7D Avg", shorttitle="Top Vol 15m + Avg", overlay=false, max_bars_back=500)

// ── Inputs ─────────────────────────────────────
tickers_input = input.string("NVDA,GOOGL,AAPL,MSFT,SPCX,AMZN,TSM,AVGO,TSLA,META,MU", "Tickers (comma separated)", tooltip="Max ~30 recommended")

top_n        = input.int(10, "Show Top N", minval=5, maxval=20)
tf           = input.timeframe("15", "Volume Timeframe")
table_bg     = input.color(color.new(#1e222d, 0), "Table Background")
header_bg    = input.color(#363a45, "Header Background")
show_rank    = input.bool(true, "Show Rank")

// ── Parse and clean tickers ─────────────────────
sym_list = str.split(tickers_input, ",")

var string[] clean_symbols = array.new_string()
if barstate.isfirst
    for i = 0 to array.size(sym_list) - 1
        trimmed = str.trim(array.get(sym_list, i))
        if str.length(trimmed) > 0
            array.push(clean_symbols, trimmed)

// ── Table & Data Arrays ─────────────────────────
var table volTable = table.new(position.top_right, 5, top_n + 2, bgcolor = table_bg, border_width = 1)

var float[]   volumes     = array.new_float()
var float[]   avg7d_vol   = array.new_float()
var string[]  symbols     = array.new_string()

// ── Volume Functions ────────────────────────────
f_get_15m_volume(string sym) =>
    request.security(sym, tf, volume, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_get_avg7d_volume(string sym) =>
    // Average daily volume over last 7 days
    request.security(sym, "1D", ta.sma(volume, 7), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ── Main Logic ───────────────────────────────────
if barstate.islastconfirmedhistory or barstate.islast

    array.clear(volumes)
    array.clear(avg7d_vol)
    array.clear(symbols)

    // Fetch data for all symbols
    for i = 0 to math.min(array.size(clean_symbols) - 1, 35)
        sym = array.get(clean_symbols, i)
        
        vol15m = f_get_15m_volume(sym)
        avg7d  = f_get_avg7d_volume(sym)
        
        if not na(vol15m) and vol15m > 0
            array.push(volumes, vol15m)
            array.push(avg7d_vol, nz(avg7d, 0))
            array.push(symbols, sym)

    // Sort by 15m volume (descending)
    if array.size(volumes) > 0
        sorted_indices = array.sort_indices(volumes, order.descending)

        // Header
        table.cell(volTable, 0, 0, "Rank",      bgcolor=header_bg, text_color=color.white, text_size=size.small)
        table.cell(volTable, 1, 0, "Ticker",    bgcolor=header_bg, text_color=color.white, text_size=size.small)
        table.cell(volTable, 2, 0, "15m Vol",   bgcolor=header_bg, text_color=color.white, text_size=size.small)
        table.cell(volTable, 3, 0, "Avg 7D",    bgcolor=header_bg, text_color=color.white, text_size=size.small)
        table.cell(volTable, 4, 0, "Ratio",     bgcolor=header_bg, text_color=color.white, text_size=size.small)

        // Fill rows
        max_show = math.min(top_n, array.size(sorted_indices))
        for row = 1 to max_show
            idx     = array.get(sorted_indices, row - 1)
            sym     = array.get(symbols, idx)
            vol15m  = array.get(volumes, idx)
            avg7d   = array.get(avg7d_vol, idx)
            
            vol15m_str = str.tostring(math.round(vol15m / 1000000, 2), "#,###.##") + "M"
            avg7d_str  = str.tostring(math.round(avg7d  / 1000000, 2), "#,###.##") + "M"
            ratio      = avg7d > 0 ? vol15m / avg7d : 0
            ratio_str  = str.tostring(ratio, "#.##") + "x"

            table.cell(volTable, 0, row, show_rank ? str.tostring(row) : "", text_color=color.gray)
            table.cell(volTable, 1, row, sym, text_color=color.yellow)
            table.cell(volTable, 2, row, vol15m_str, text_color = vol15m > 5e7 ? color.lime : color.white)
            table.cell(volTable, 3, row, avg7d_str,  text_color=color.aqua)
            table.cell(volTable, 4, row, ratio_str,  text_color = ratio > 2.0 ? color.fuchsia : color.white)

        // Clear unused rows
        for row = max_show + 1 to top_n + 1
            for col = 0 to 4
                table.cell(volTable, col, row, "", bgcolor=table_bg)
````
