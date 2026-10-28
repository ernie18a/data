# Dynamic ATR v1.0

- url: https://www.tradingview.com/script/EIgpbB7r-Dynamic-ATR-v1-0/
- type: indicator
- pine_id: PUB;b133ce99528b45f6b6d44efb62ffe87d
- version: 1.0

## Description

Dynamic ATR displays the Average True Range of any token across two timeframes — the chart timeframe and a configurable higher timeframe (default 2H) — with an…Dynamic ATR displays the Average True Range of any token across two timeframes — the chart timeframe and a configurable higher timeframe (default 2H) — with an optional 0–50 normalization that scales each ATR value relative to its own 360-bar history, making volatility directly comparable across different tokens regardless of their price magnitude. Alongside the current readings, it also shows a snapshot of both ATR values from 10 calendar days ago, giving you a quick sense of whether volatility has expanded or contracted recently. The result is a compact table you can position anywhere on the chart, useful for scanning multiple tokens side by side and spotting which ones are in high or low volatility regimes relative to their own history.

Created by Milad Saberi — April 2026

## Source Code

````pine
// ============================================================
// Dynamic ATR v1.0
// Created by Milad Saberi — April 2026
// ============================================================

//@version=5
indicator("Dynamic ATR", overlay=true, max_bars_back=500)


// ─────────────────────────────────────────────────────────────
// §1 · INPUTS
// ─────────────────────────────────────────────────────────────
var string GRP    = "ATR Settings"
var string GRP_UI = "Display"

i_len   = input.int      (14,    "ATR Length",       minval=1, group=GRP)
i_tf2   = input.timeframe("120", "ATR 2 Timeframe",            group=GRP)
i_scale = input.bool     (true,  "Scaled (0 – 50)",            group=GRP, tooltip="Normalises ATR to a 0–50 range using a rolling min/max.\nMakes cross-token comparison meaningful.")
i_pos   = input.string("Middle Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=GRP_UI)


// ─────────────────────────────────────────────────────────────
// §2 · 10-DAY OFFSET  (must be before security calls that use it)
// ─────────────────────────────────────────────────────────────

_T10      = timenow - 10 * 24 * 60 * 60 * 1000
_bars_10d = ta.barssince(time[1] < _T10 and time >= _T10)
_offset   = nz(_bars_10d, 0)


// ─────────────────────────────────────────────────────────────
// §3 · RAW ATR CALCULATIONS
// ─────────────────────────────────────────────────────────────

_atr1_raw     = ta.atr(i_len)
_atr1_10d_raw = _atr1_raw[_offset]

_atr2_raw     = request.security(syminfo.tickerid, i_tf2, ta.atr(i_len),          lookahead=barmerge.lookahead_on)
_atr2_10d_raw = request.security(syminfo.tickerid, i_tf2, ta.atr(i_len)[_offset], lookahead=barmerge.lookahead_on)


// §4 · SCALING
f_norm(v) =>
    _lo  = ta.lowest (v, 360)
    _hi  = ta.highest(v, 360)
    _rng = _hi - _lo
    _rng > 0 ? (v - _lo) / _rng * 50 : 25.0

// Scale the full series first
atr1_scaled = i_scale ? f_norm(_atr1_raw) : _atr1_raw
atr2_scaled = i_scale ? f_norm(_atr2_raw) : _atr2_raw

// Then index into the scaled series for 10D ago
atr1     = atr1_scaled
atr1_10d = atr1_scaled[_offset]
atr2     = atr2_scaled
atr2_10d = atr2_scaled[_offset]


// ─────────────────────────────────────────────────────────────
// §5 · HELPERS
// ─────────────────────────────────────────────────────────────

f_pos(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        =>                 position.middle_right

_token  = syminfo.basecurrency
f_fmt(v)  => str.tostring(v, i_scale ? "#.##" : "#.####")
f_cell(v) => na(v) ? "—" : f_fmt(v)


// ─────────────────────────────────────────────────────────────
// §6 · TABLE DISPLAY
// ─────────────────────────────────────────────────────────────

C_HDR_BG     = color.new(#1b2a4a, 0)
C_HDR_FG     = color.white
C_LBL_BG     = color.new(#1a1f2e, 40)
C_LBL_FG     = color.new(color.silver, 10)
C_VAL_BG     = color.new(#0d1117, 50)
C_VAL_FG     = color.white
C_NOW_HDR_BG = color.new(#1976d2, 0)
C_NOW_HDR_FG = color.white
C_NOW_VAL_BG = color.new(#0d47a1, 25)
C_NOW_VAL_FG = color.new(#90caf9, 0)
C_BORDER     = color.new(color.gray, 55)

_prefix    = i_scale ? "ATR (Scaled)" : "ATR"
_header    = _prefix + "  |  " + _token
_lbl_chart = "ATR " + str.tostring(i_len) + "  ·  Chart"
_lbl_htf   = "ATR " + str.tostring(i_len) + "  ·  " + i_tf2

var table T = table.new(position=f_pos(i_pos), columns=3, rows=3, border_width=1, border_color=C_BORDER, frame_width=1, frame_color=C_BORDER)

if barstate.islast
    table.cell(T, 0, 0, _header,          bgcolor=C_HDR_BG,     text_color=C_HDR_FG,     text_size=size.normal)
    table.cell(T, 1, 0, "10D Ago",        bgcolor=C_HDR_BG,     text_color=C_HDR_FG,     text_size=size.normal)
    table.cell(T, 2, 0, "Now",            bgcolor=C_NOW_HDR_BG, text_color=C_NOW_HDR_FG, text_size=size.normal)

    table.cell(T, 0, 1, _lbl_chart,       bgcolor=C_LBL_BG,     text_color=C_LBL_FG,     text_size=size.normal)
    table.cell(T, 1, 1, f_cell(atr1_10d), bgcolor=C_VAL_BG,     text_color=C_VAL_FG,     text_size=size.normal)
    table.cell(T, 2, 1, f_cell(atr1),     bgcolor=C_NOW_VAL_BG, text_color=C_NOW_VAL_FG, text_size=size.normal)

    table.cell(T, 0, 2, _lbl_htf,         bgcolor=C_LBL_BG,     text_color=C_LBL_FG,     text_size=size.normal)
    table.cell(T, 1, 2, f_cell(atr2_10d), bgcolor=C_VAL_BG,     text_color=C_VAL_FG,     text_size=size.normal)
    table.cell(T, 2, 2, f_cell(atr2),     bgcolor=C_NOW_VAL_BG, text_color=C_NOW_VAL_FG, text_size=size.normal)
````
