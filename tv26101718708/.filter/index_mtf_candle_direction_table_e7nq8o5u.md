# Index MTF Candle Direction Table

- url: https://www.tradingview.com/script/e7nQ8o5U-Index-MTF-Candle-Direction-Table/
- type: indicator
- pine_id: PUB;10f0a056128c4947bea37c752743ce02
- version: 1.0

## Description

[b]Index MTF Candle Direction Table[/b]
This indicator displays the candle direction of 13 major NSE and BSE indices across three fixed timeframes — 3 minutes, 5 minutes, and 10 minutes — in a compact table on the chart.

[b]How it works[/b]
For each index, request.security fetches the open and close on the 3m, 5m, and 10m timeframes. Each cell is then colored based on the direction of that candle: green if close is above open, red if close is below open, and gray if they are equal. The table updates on every bar.

[b]Indices tracked[/b]
Nifty 50, Bank Nifty, Sensex, CNX IT, CNX Finance, Nifty Mid Select, CNX Auto, CNX Pharma, CNX Metal, CNX PSU Bank, CNX FMCG, CNX Realty, Nifty Private Bank.

[b]Cell indicators[/b]
[list]
[*]Green / + — bullish candle (close above open) on that timeframe
[*]Red / - — bearish candle (close below open) on that timeframe
[*]Gray / o — neutral candle (close equals open) on that timeframe
[/list]

[b]Settings[/b]

[list]
[*]Table Position — choose which corner of the chart the table appears in (top right, top left, bottom right, bottom left)
[/list]

Designed for NSE/BSE charts. Works on any base timeframe; the table always shows 3m, 5m, and 10m data regardless of the chart timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © lazyhacker

//@version=6
indicator("Index MTF Candle Direction Table", shorttitle="Index MTF", overlay=true)

// --- Inputs ---
inpPosition = input.string(
  title   = "Table Position",
  defval  = position.top_right,
  options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left])

// --- Helper: fetch candle direction for a symbol on a given timeframe ---
// Returns 1 (bullish), -1 (bearish), or 0 (neutral)
f_dir(sym, tf) =>
    request.security(sym, tf, close > open ? 1 : close < open ? -1 : 0)

// --- Helper: paint a single color cell with direction arrow ---
f_paintCell(t, row, col, dir) =>
    bg  = dir == 1 ? color.green : dir == -1 ? color.red : color.gray
    txt = dir == 1 ? "+" : dir == -1 ? "-" : "o"
    table.cell(t, col, row, txt, text_color=color.white, bgcolor=bg, text_size=size.small)

// --- Table: 4 columns (Symbol, 3m, 5m, 10m), 14 rows (header + 13 indices) ---
var table t = table.new(position=inpPosition, columns=4, rows=14, border_width=1)

// --- Header row ---
if barstate.isfirst
    table.cell(t, 0, 0, "Index",  text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 1, 0, "3m",     text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 2, 0, "5m",     text_color=color.white, bgcolor=color.black, text_size=size.small)
    table.cell(t, 3, 0, "10m",    text_color=color.white, bgcolor=color.black, text_size=size.small)

    table.cell(t, 0, 1,  "NIFTY",         text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 2,  "BANKNIFTY",     text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 3,  "SENSEX",        text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 4,  "CNXIT",         text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 5,  "CNXFINANCE",    text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 6,  "MID SELECT",    text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 7,  "CNXAUTO",       text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 8,  "CNXPHARMA",     text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 9,  "CNXMETAL",      text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 10, "CNXPSUBANK",    text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 11, "CNXFMCG",       text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 12, "CNXREALTY",     text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)
    table.cell(t, 0, 13, "NIFTYPVTBANK",  text_color=color.white, bgcolor=color.new(color.black, 70), text_size=size.small)

// --- Fetch directions and paint cells on every bar ---
f_paintCell(t, 1,  1, f_dir("NSE:NIFTY",            "3"))
f_paintCell(t, 1,  2, f_dir("NSE:NIFTY",            "5"))
f_paintCell(t, 1,  3, f_dir("NSE:NIFTY",            "10"))

f_paintCell(t, 2,  1, f_dir("NSE:BANKNIFTY",        "3"))
f_paintCell(t, 2,  2, f_dir("NSE:BANKNIFTY",        "5"))
f_paintCell(t, 2,  3, f_dir("NSE:BANKNIFTY",        "10"))

f_paintCell(t, 3,  1, f_dir("BSE:SENSEX",           "3"))
f_paintCell(t, 3,  2, f_dir("BSE:SENSEX",           "5"))
f_paintCell(t, 3,  3, f_dir("BSE:SENSEX",           "10"))

f_paintCell(t, 4,  1, f_dir("NSE:CNXIT",            "3"))
f_paintCell(t, 4,  2, f_dir("NSE:CNXIT",            "5"))
f_paintCell(t, 4,  3, f_dir("NSE:CNXIT",            "10"))

f_paintCell(t, 5,  1, f_dir("NSE:CNXFINANCE",       "3"))
f_paintCell(t, 5,  2, f_dir("NSE:CNXFINANCE",       "5"))
f_paintCell(t, 5,  3, f_dir("NSE:CNXFINANCE",       "10"))

f_paintCell(t, 6,  1, f_dir("NSE:NIFTY_MID_SELECT", "3"))
f_paintCell(t, 6,  2, f_dir("NSE:NIFTY_MID_SELECT", "5"))
f_paintCell(t, 6,  3, f_dir("NSE:NIFTY_MID_SELECT", "10"))

f_paintCell(t, 7,  1, f_dir("NSE:CNXAUTO",          "3"))
f_paintCell(t, 7,  2, f_dir("NSE:CNXAUTO",          "5"))
f_paintCell(t, 7,  3, f_dir("NSE:CNXAUTO",          "10"))

f_paintCell(t, 8,  1, f_dir("NSE:CNXPHARMA",        "3"))
f_paintCell(t, 8,  2, f_dir("NSE:CNXPHARMA",        "5"))
f_paintCell(t, 8,  3, f_dir("NSE:CNXPHARMA",        "10"))

f_paintCell(t, 9,  1, f_dir("NSE:CNXMETAL",         "3"))
f_paintCell(t, 9,  2, f_dir("NSE:CNXMETAL",         "5"))
f_paintCell(t, 9,  3, f_dir("NSE:CNXMETAL",         "10"))

f_paintCell(t, 10, 1, f_dir("NSE:CNXPSUBANK",       "3"))
f_paintCell(t, 10, 2, f_dir("NSE:CNXPSUBANK",       "5"))
f_paintCell(t, 10, 3, f_dir("NSE:CNXPSUBANK",       "10"))

f_paintCell(t, 11, 1, f_dir("NSE:CNXFMCG",          "3"))
f_paintCell(t, 11, 2, f_dir("NSE:CNXFMCG",          "5"))
f_paintCell(t, 11, 3, f_dir("NSE:CNXFMCG",          "10"))

f_paintCell(t, 12, 1, f_dir("NSE:CNXREALTY",        "3"))
f_paintCell(t, 12, 2, f_dir("NSE:CNXREALTY",        "5"))
f_paintCell(t, 12, 3, f_dir("NSE:CNXREALTY",        "10"))

f_paintCell(t, 13, 1, f_dir("NSE:NIFTYPVTBANK",     "3"))
f_paintCell(t, 13, 2, f_dir("NSE:NIFTYPVTBANK",     "5"))
f_paintCell(t, 13, 3, f_dir("NSE:NIFTYPVTBANK",     "10"))
````
