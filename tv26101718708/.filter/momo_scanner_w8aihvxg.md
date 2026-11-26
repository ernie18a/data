# Momo Scanner

- url: https://www.tradingview.com/script/w8AIHvxg-Momo-Scanner/
- type: indicator
- pine_id: PUB;ae1c7f02961744ddb662127d2f91bb1c
- version: 1.0

## Description

Input up to 8 symbols to show an adjustable amount of timeframes that are above or below a certain RSI threshold.

## Source Code

````pine
//@version=6
indicator("Momo Scanner", overlay=true)

// ─── RSI ─────────────────────────────────────────────────────────────────────
RSI_LEN   = input.int(11,     "RSI Length",      minval=1,             group="RSI")
THRESH_UP = input.float(64.0, "Bullish RSI >=",  minval=1, maxval=99, step=0.5, group="RSI")
THRESH_DN = input.float(36.0, "Bearish RSI <=",  minval=1, maxval=99, step=0.5, group="RSI")
MIN_ALIGN = input.int(3,      "Min TFs aligned",  minval=1, maxval=5,  group="RSI", tooltip="Pair appears when at least this many enabled timeframes breach the threshold")

// ─── Timeframes — toggle on/off + choose which resolution ────────────────────
use_tf1 = input.bool(true,  "",  inline="tf1", group="Timeframes")
tf1     = input.timeframe("5",   "  ", inline="tf1", group="Timeframes")
use_tf2 = input.bool(true,  "",  inline="tf2", group="Timeframes")
tf2     = input.timeframe("15",  "  ", inline="tf2", group="Timeframes")
use_tf3 = input.bool(true,  "",  inline="tf3", group="Timeframes")
tf3     = input.timeframe("60",  "  ", inline="tf3", group="Timeframes")
use_tf4 = input.bool(true,  "",  inline="tf4", group="Timeframes")
tf4     = input.timeframe("240", "  ", inline="tf4", group="Timeframes")
use_tf5 = input.bool(true,  "",  inline="tf5", group="Timeframes")
tf5     = input.timeframe("D",   "  ", inline="tf5", group="Timeframes")

// ─── Pairs ───────────────────────────────────────────────────────────────────
p1 = input.symbol("FX:EURUSD", "Pair 1", group="Pairs")
p2 = input.symbol("FX:GBPUSD", "Pair 2", group="Pairs")
p3 = input.symbol("FX:USDJPY", "Pair 3", group="Pairs")
p4 = input.symbol("FX:USDCHF", "Pair 4", group="Pairs")
p5 = input.symbol("FX:AUDUSD", "Pair 5", group="Pairs")
p6 = input.symbol("FX:NZDUSD", "Pair 6", group="Pairs")
p7 = input.symbol("FX:USDCAD", "Pair 7", group="Pairs")
p8 = input.symbol("FX:EURJPY", "Pair 8", group="Pairs")

// ─── RSI Fetch — 5 TFs x 8 pairs = 40 request.security calls ─────────────────
f_rsi(sym, tf) => request.security(sym, tf, ta.rsi(close, RSI_LEN))

r1_1 = f_rsi(p1, tf1)
r1_2 = f_rsi(p1, tf2)
r1_3 = f_rsi(p1, tf3)
r1_4 = f_rsi(p1, tf4)
r1_5 = f_rsi(p1, tf5)
r2_1 = f_rsi(p2, tf1)
r2_2 = f_rsi(p2, tf2)
r2_3 = f_rsi(p2, tf3)
r2_4 = f_rsi(p2, tf4)
r2_5 = f_rsi(p2, tf5)
r3_1 = f_rsi(p3, tf1)
r3_2 = f_rsi(p3, tf2)
r3_3 = f_rsi(p3, tf3)
r3_4 = f_rsi(p3, tf4)
r3_5 = f_rsi(p3, tf5)
r4_1 = f_rsi(p4, tf1)
r4_2 = f_rsi(p4, tf2)
r4_3 = f_rsi(p4, tf3)
r4_4 = f_rsi(p4, tf4)
r4_5 = f_rsi(p4, tf5)
r5_1 = f_rsi(p5, tf1)
r5_2 = f_rsi(p5, tf2)
r5_3 = f_rsi(p5, tf3)
r5_4 = f_rsi(p5, tf4)
r5_5 = f_rsi(p5, tf5)
r6_1 = f_rsi(p6, tf1)
r6_2 = f_rsi(p6, tf2)
r6_3 = f_rsi(p6, tf3)
r6_4 = f_rsi(p6, tf4)
r6_5 = f_rsi(p6, tf5)
r7_1 = f_rsi(p7, tf1)
r7_2 = f_rsi(p7, tf2)
r7_3 = f_rsi(p7, tf3)
r7_4 = f_rsi(p7, tf4)
r7_5 = f_rsi(p7, tf5)
r8_1 = f_rsi(p8, tf1)
r8_2 = f_rsi(p8, tf2)
r8_3 = f_rsi(p8, tf3)
r8_4 = f_rsi(p8, tf4)
r8_5 = f_rsi(p8, tf5)

// ─── Alignment — only count enabled TFs ──────────────────────────────────────
n_enabled = (use_tf1?1:0)+(use_tf2?1:0)+(use_tf3?1:0)+(use_tf4?1:0)+(use_tf5?1:0)

f_up(a, b, c, d, e) => (use_tf1 and nz(a) >= THRESH_UP ? 1 : 0) + (use_tf2 and nz(b) >= THRESH_UP ? 1 : 0) + (use_tf3 and nz(c) >= THRESH_UP ? 1 : 0) + (use_tf4 and nz(d) >= THRESH_UP ? 1 : 0) + (use_tf5 and nz(e) >= THRESH_UP ? 1 : 0)
f_dn(a, b, c, d, e) => (use_tf1 and nz(a,50) <= THRESH_DN ? 1 : 0) + (use_tf2 and nz(b,50) <= THRESH_DN ? 1 : 0) + (use_tf3 and nz(c,50) <= THRESH_DN ? 1 : 0) + (use_tf4 and nz(d,50) <= THRESH_DN ? 1 : 0) + (use_tf5 and nz(e,50) <= THRESH_DN ? 1 : 0)

up1 = f_up(r1_1, r1_2, r1_3, r1_4, r1_5)
dn1 = f_dn(r1_1, r1_2, r1_3, r1_4, r1_5)
up2 = f_up(r2_1, r2_2, r2_3, r2_4, r2_5)
dn2 = f_dn(r2_1, r2_2, r2_3, r2_4, r2_5)
up3 = f_up(r3_1, r3_2, r3_3, r3_4, r3_5)
dn3 = f_dn(r3_1, r3_2, r3_3, r3_4, r3_5)
up4 = f_up(r4_1, r4_2, r4_3, r4_4, r4_5)
dn4 = f_dn(r4_1, r4_2, r4_3, r4_4, r4_5)
up5 = f_up(r5_1, r5_2, r5_3, r5_4, r5_5)
dn5 = f_dn(r5_1, r5_2, r5_3, r5_4, r5_5)
up6 = f_up(r6_1, r6_2, r6_3, r6_4, r6_5)
dn6 = f_dn(r6_1, r6_2, r6_3, r6_4, r6_5)
up7 = f_up(r7_1, r7_2, r7_3, r7_4, r7_5)
dn7 = f_dn(r7_1, r7_2, r7_3, r7_4, r7_5)
up8 = f_up(r8_1, r8_2, r8_3, r8_4, r8_5)
dn8 = f_dn(r8_1, r8_2, r8_3, r8_4, r8_5)

bull1 = up1 >= MIN_ALIGN
bear1 = dn1 >= MIN_ALIGN and not bull1
bull2 = up2 >= MIN_ALIGN
bear2 = dn2 >= MIN_ALIGN and not bull2
bull3 = up3 >= MIN_ALIGN
bear3 = dn3 >= MIN_ALIGN and not bull3
bull4 = up4 >= MIN_ALIGN
bear4 = dn4 >= MIN_ALIGN and not bull4
bull5 = up5 >= MIN_ALIGN
bear5 = dn5 >= MIN_ALIGN and not bull5
bull6 = up6 >= MIN_ALIGN
bear6 = dn6 >= MIN_ALIGN and not bull6
bull7 = up7 >= MIN_ALIGN
bear7 = dn7 >= MIN_ALIGN and not bull7
bull8 = up8 >= MIN_ALIGN
bear8 = dn8 >= MIN_ALIGN and not bull8

qual1 = bull1 or bear1
qual2 = bull2 or bear2
qual3 = bull3 or bear3
qual4 = bull4 or bear4
qual5 = bull5 or bear5
qual6 = bull6 or bear6
qual7 = bull7 or bear7
qual8 = bull8 or bear8

// ─── Colors ──────────────────────────────────────────────────────────────────
C_HDR_BULL = color.new(color.green, 10)
C_HDR_BEAR = color.new(color.red,   10)
C_HDR      = color.new(color.gray,  10)
C_PAIR_BUL = color.new(color.green, 40)
C_PAIR_BER = color.new(color.red,   40)
C_UP       = color.new(color.green, 30)
C_DN       = color.new(color.red,   30)
C_NEUT     = color.new(color.gray,  60)
C_TXT      = color.white

f_bg(v)  => na(v) ? C_NEUT : v >= THRESH_UP ? C_UP : v <= THRESH_DN ? C_DN : C_NEUT
f_val(v) => na(v) ? "n/a"  : str.tostring(v, "#.#")

f_tflabel(tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "10"  => "10m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1h"
        "120" => "2h"
        "180" => "3h"
        "240" => "4h"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        => tf

f_name(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

// ─── Table ───────────────────────────────────────────────────────────────────
if barstate.islast
    n = (qual1?1:0)+(qual2?1:0)+(qual3?1:0)+(qual4?1:0)+(qual5?1:0)+(qual6?1:0)+(qual7?1:0)+(qual8?1:0)
    n_cols = 1 + n_enabled

    if n == 0
        t = table.new(position.top_right, 1, 2, border_width=1, border_color=color.new(color.gray, 70))
        table.cell(t, 0, 0, "Momo Scanner",     bgcolor=C_HDR,  text_color=C_TXT, text_size=size.small)
        table.cell(t, 0, 1, "No pairs trending", bgcolor=C_NEUT, text_color=C_TXT, text_size=size.small)
    else
        t = table.new(position.top_right, n_cols, n + 1, border_width=1, border_color=color.new(color.gray, 70))

        // Header
        table.cell(t, 0, 0, "Pair", bgcolor=C_HDR, text_color=C_TXT, text_size=size.small)
        hcol = 1
        if use_tf1
            table.cell(t, hcol, 0, f_tflabel(tf1), bgcolor=C_HDR, text_color=C_TXT, text_size=size.small)
            hcol := hcol + 1
        if use_tf2
            table.cell(t, hcol, 0, f_tflabel(tf2), bgcolor=C_HDR, text_color=C_TXT, text_size=size.small)
            hcol := hcol + 1
        if use_tf3
            table.cell(t, hcol, 0, f_tflabel(tf3), bgcolor=C_HDR, text_color=C_TXT, text_size=size.small)
            hcol := hcol + 1
        if use_tf4
            table.cell(t, hcol, 0, f_tflabel(tf4), bgcolor=C_HDR, text_color=C_TXT, text_size=size.small)
            hcol := hcol + 1
        if use_tf5
            table.cell(t, hcol, 0, f_tflabel(tf5), bgcolor=C_HDR, text_color=C_TXT, text_size=size.small)

        row = 1

        if qual1
            table.cell(t, 0, row, f_name(p1), bgcolor=bull1?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r1_1), bgcolor=f_bg(r1_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r1_2), bgcolor=f_bg(r1_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r1_3), bgcolor=f_bg(r1_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r1_4), bgcolor=f_bg(r1_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r1_5), bgcolor=f_bg(r1_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual2
            table.cell(t, 0, row, f_name(p2), bgcolor=bull2?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r2_1), bgcolor=f_bg(r2_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r2_2), bgcolor=f_bg(r2_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r2_3), bgcolor=f_bg(r2_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r2_4), bgcolor=f_bg(r2_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r2_5), bgcolor=f_bg(r2_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual3
            table.cell(t, 0, row, f_name(p3), bgcolor=bull3?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r3_1), bgcolor=f_bg(r3_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r3_2), bgcolor=f_bg(r3_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r3_3), bgcolor=f_bg(r3_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r3_4), bgcolor=f_bg(r3_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r3_5), bgcolor=f_bg(r3_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual4
            table.cell(t, 0, row, f_name(p4), bgcolor=bull4?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r4_1), bgcolor=f_bg(r4_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r4_2), bgcolor=f_bg(r4_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r4_3), bgcolor=f_bg(r4_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r4_4), bgcolor=f_bg(r4_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r4_5), bgcolor=f_bg(r4_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual5
            table.cell(t, 0, row, f_name(p5), bgcolor=bull5?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r5_1), bgcolor=f_bg(r5_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r5_2), bgcolor=f_bg(r5_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r5_3), bgcolor=f_bg(r5_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r5_4), bgcolor=f_bg(r5_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r5_5), bgcolor=f_bg(r5_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual6
            table.cell(t, 0, row, f_name(p6), bgcolor=bull6?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r6_1), bgcolor=f_bg(r6_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r6_2), bgcolor=f_bg(r6_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r6_3), bgcolor=f_bg(r6_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r6_4), bgcolor=f_bg(r6_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r6_5), bgcolor=f_bg(r6_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual7
            table.cell(t, 0, row, f_name(p7), bgcolor=bull7?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r7_1), bgcolor=f_bg(r7_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r7_2), bgcolor=f_bg(r7_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r7_3), bgcolor=f_bg(r7_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r7_4), bgcolor=f_bg(r7_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r7_5), bgcolor=f_bg(r7_5), text_color=C_TXT, text_size=size.small)
            row := row + 1

        if qual8
            table.cell(t, 0, row, f_name(p8), bgcolor=bull8?C_PAIR_BUL:C_PAIR_BER, text_color=C_TXT, text_size=size.small)
            dcol = 1
            if use_tf1
                table.cell(t, dcol, row, f_val(r8_1), bgcolor=f_bg(r8_1), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf2
                table.cell(t, dcol, row, f_val(r8_2), bgcolor=f_bg(r8_2), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf3
                table.cell(t, dcol, row, f_val(r8_3), bgcolor=f_bg(r8_3), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf4
                table.cell(t, dcol, row, f_val(r8_4), bgcolor=f_bg(r8_4), text_color=C_TXT, text_size=size.small)
                dcol := dcol + 1
            if use_tf5
                table.cell(t, dcol, row, f_val(r8_5), bgcolor=f_bg(r8_5), text_color=C_TXT, text_size=size.small)
````
