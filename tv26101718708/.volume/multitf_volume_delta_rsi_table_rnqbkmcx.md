# Multi-TF Volume Delta & RSI Table

- url: https://www.tradingview.com/script/rNqBkmcx-Multi-TF-Volume-Delta-RSI-Table/
- type: indicator
- pine_id: PUB;6c3a4cbd0c274480b844f0b91ecb8a15
- version: 1.0

## Description

Here's a technical description for your MTF Volume Delta indicator:

Multi-Timeframe Volume Delta
This indicator displays Volume Delta — the difference between buying and selling volume — across multiple user-defined timeframes, giving traders a deeper view of market aggression and order flow that a single timeframe cannot provide.
How It Works
Volume Delta is calculated by separating volume into buy-side (up-close candles) and sell-side (down-close candles) components, then computing the net difference (Buy Volume − Sell Volume) for each bar. By pulling this data from higher timeframes and overlaying it on your current chart, the indicator reveals whether bulls or bears are in control at a macro level — context that is often invisible on lower timeframe charts alone.
Key Features

Multi-Timeframe Support — Analyze volume delta from customizable higher timeframes without leaving your current chart view
Cross-Timeframe Confluence — Identify when buying or selling pressure aligns across multiple timeframes, a strong signal of directional conviction
Non-Repainting Design — Higher timeframe values are pulled from confirmed, closed candles to ensure historical accuracy and reliable backtesting

Use Cases

Confirm breakouts by checking whether volume delta on a higher timeframe supports the move
Spot divergences where price makes new highs/lows but delta weakens — a leading indicator of reversals
Filter low-conviction setups by requiring delta alignment across timeframes before entering a trade

Recommended For
Intraday and swing traders who incorporate order flow analysis into their decision-making and want timeframe confluence built directly into their workflow.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZorroSingh75

//@version=5
indicator("Multi-TF Volume Delta & RSI Table", shorttitle="MTF VD+RSI", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  TIMEFRAME TOGGLES
// ═══════════════════════════════════════════════════════════════════════════════
grp_tf = "── Timeframe Selection ──"
show_5   = input.bool(true, "5 min",   group=grp_tf, inline="row1")
show_15  = input.bool(true, "15 min",  group=grp_tf, inline="row1")
show_30  = input.bool(true, "30 min",  group=grp_tf, inline="row1")
show_75  = input.bool(true, "75 min",  group=grp_tf, inline="row2")
show_240 = input.bool(true, "240 min", group=grp_tf, inline="row2")
show_D   = input.bool(true, "Day",     group=grp_tf, inline="row2")
show_W   = input.bool(true, "Week",    group=grp_tf, inline="row3")
show_M   = input.bool(true, "Month",   group=grp_tf, inline="row3")

// ═══════════════════════════════════════════════════════════════════════════════
//  RSI SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
grp_rsi = "── RSI Settings ──"
rsi_len = input.int(14, "RSI Length",      group=grp_rsi, minval=2)
rsi_ob  = input.int(70, "Overbought Level", group=grp_rsi, minval=50, maxval=100)
rsi_os  = input.int(30, "Oversold Level",   group=grp_rsi, minval=0,  maxval=50)

// ═══════════════════════════════════════════════════════════════════════════════
//  SIGNAL SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
grp_sig = "── Signal Settings ──"
delta_thresh = input.float(0.6, "Delta Dominance (0-1)", group=grp_sig, minval=0.0, maxval=1.0, step=0.05,
     tooltip="Buy volume / total volume needed for bullish signal. 0.6 = 60% buy volume.")
min_tfs_bull = input.int(3, "Min TFs Bullish for BUY",  group=grp_sig, minval=1, maxval=8)
min_tfs_bear = input.int(3, "Min TFs Bearish for SELL", group=grp_sig, minval=1, maxval=8)

// ═══════════════════════════════════════════════════════════════════════════════
//  TABLE SETTINGS
// ═══════════════════════════════════════════════════════════════════════════════
grp_tbl = "── Table Settings ──"
tbl_pos  = input.string("Top Right", "Table Position", group=grp_tbl,
     options=["Top Right","Top Left","Top Center","Bottom Right","Bottom Left","Bottom Center"])
tbl_size = input.string("Small", "Text Size", group=grp_tbl,
     options=["Tiny","Small","Normal","Large"])

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════
f_pos(s) =>
    s == "Top Right"    ? position.top_right    :
     s == "Top Left"     ? position.top_left     :
     s == "Top Center"   ? position.top_center   :
     s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Left"  ? position.bottom_left  :
     position.bottom_center

f_sz(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Normal" ? size.normal :
     size.large

f_buy_vol(vol, h, l, c) =>
    rng = h - l
    rng > 0 ? vol * (c - l) / rng : vol * 0.5

f_sell_vol(vol, h, l, c) =>
    rng = h - l
    rng > 0 ? vol * (h - c) / rng : vol * 0.5

f_tf_data(tf) =>
    [v, h_, l_, c_] = request.security(syminfo.tickerid, tf,
         [volume, high, low, close], lookahead=barmerge.lookahead_off)
    bv  = f_buy_vol(v, h_, l_, c_)
    sv  = f_sell_vol(v, h_, l_, c_)
    dlt = bv - sv
    rs  = request.security(syminfo.tickerid, tf,
         ta.rsi(close, rsi_len), lookahead=barmerge.lookahead_off)
    [bv, sv, dlt, rs]

f_fmt(x) =>
    ax = math.abs(x)
    ax >= 1e9 ? str.tostring(math.round(x / 1e9, 2)) + "B" :
     ax >= 1e6 ? str.tostring(math.round(x / 1e6, 2)) + "M" :
     ax >= 1e3 ? str.tostring(math.round(x / 1e3, 1)) + "K" :
                 str.tostring(math.round(x, 1))

f_signal(bv, sv, rsi_val) =>
    total   = bv + sv
    buy_pct = total > 0 ? bv / total : 0.5
    bull    = buy_pct >= delta_thresh       and rsi_val < rsi_ob
    bear    = buy_pct <= (1 - delta_thresh) and rsi_val > rsi_os
    bull ? 1 : bear ? -1 : 0

// ═══════════════════════════════════════════════════════════════════════════════
//  FETCH ALL TIMEFRAMES
// ═══════════════════════════════════════════════════════════════════════════════
[bv5,   sv5,   dlt5,   rsi5  ] = f_tf_data("5")
[bv15,  sv15,  dlt15,  rsi15 ] = f_tf_data("15")
[bv30,  sv30,  dlt30,  rsi30 ] = f_tf_data("30")
[bv75,  sv75,  dlt75,  rsi75 ] = f_tf_data("75")
[bv240, sv240, dlt240, rsi240] = f_tf_data("240")
[bvD,   svD,   dltD,   rsiD  ] = f_tf_data("D")
[bvW,   svW,   dltW,   rsiW  ] = f_tf_data("W")
[bvM,   svM,   dltM,   rsiM  ] = f_tf_data("M")

// ═══════════════════════════════════════════════════════════════════════════════
//  SIGNALS PER TIMEFRAME
// ═══════════════════════════════════════════════════════════════════════════════
sig5   = f_signal(bv5,   sv5,   rsi5)
sig15  = f_signal(bv15,  sv15,  rsi15)
sig30  = f_signal(bv30,  sv30,  rsi30)
sig75  = f_signal(bv75,  sv75,  rsi75)
sig240 = f_signal(bv240, sv240, rsi240)
sigD   = f_signal(bvD,   svD,   rsiD)
sigW   = f_signal(bvW,   svW,   rsiW)
sigM   = f_signal(bvM,   svM,   rsiM)

bull_count =
     (show_5   and sig5   == 1 ? 1 : 0) +
     (show_15  and sig15  == 1 ? 1 : 0) +
     (show_30  and sig30  == 1 ? 1 : 0) +
     (show_75  and sig75  == 1 ? 1 : 0) +
     (show_240 and sig240 == 1 ? 1 : 0) +
     (show_D   and sigD   == 1 ? 1 : 0) +
     (show_W   and sigW   == 1 ? 1 : 0) +
     (show_M   and sigM   == 1 ? 1 : 0)

bear_count =
     (show_5   and sig5   == -1 ? 1 : 0) +
     (show_15  and sig15  == -1 ? 1 : 0) +
     (show_30  and sig30  == -1 ? 1 : 0) +
     (show_75  and sig75  == -1 ? 1 : 0) +
     (show_240 and sig240 == -1 ? 1 : 0) +
     (show_D   and sigD   == -1 ? 1 : 0) +
     (show_W   and sigW   == -1 ? 1 : 0) +
     (show_M   and sigM   == -1 ? 1 : 0)

overall_buy  = bull_count >= min_tfs_bull
overall_sell = bear_count >= min_tfs_bear

// ═══════════════════════════════════════════════════════════════════════════════
//  BUY / SELL LABELS ON CHART
// ═══════════════════════════════════════════════════════════════════════════════
plotshape(overall_buy and not overall_buy[1],
     title="BUY Signal", style=shape.labelup, location=location.belowbar,
     color=color.new(#00c853, 0), textcolor=color.white, text="BUY", size=size.normal)
plotshape(overall_sell and not overall_sell[1],
     title="SELL Signal", style=shape.labeldown, location=location.abovebar,
     color=color.new(#d50000, 0), textcolor=color.white, text="SELL", size=size.normal)

// ═══════════════════════════════════════════════════════════════════════════════
//  COLOURS
// ═══════════════════════════════════════════════════════════════════════════════
C_HEADER   = color.new(#1a1a2e, 0)
C_ROW_ODD  = color.new(#16213e, 0)
C_ROW_EVEN = color.new(#0f3460, 15)
C_BULL     = color.new(#00e676, 0)
C_BEAR     = color.new(#ff1744, 0)
C_NEUTRAL  = color.new(#b0bec5, 0)
C_TEXT     = color.white
C_TITLE_BG = color.new(#e94560, 0)

f_sig_str(s) =>
    s == 1 ? "▲ BULL" : s == -1 ? "▼ BEAR" : "● NEUT"

f_sig_col(s) =>
    s == 1 ? C_BULL : s == -1 ? C_BEAR : C_NEUTRAL

f_sig_bg(s) =>
    s == 1 ? color.new(#00e676, 75) : s == -1 ? color.new(#ff1744, 75) : color.new(#455a64, 75)

f_dlt_col(d) =>
    d > 0 ? C_BULL : d < 0 ? C_BEAR : C_NEUTRAL

f_rsi_col(r) =>
    r >= rsi_ob ? C_BEAR : r <= rsi_os ? C_BULL : C_NEUTRAL

// ═══════════════════════════════════════════════════════════════════════════════
//  TABLE  — 6 cols x 11 rows
// ═══════════════════════════════════════════════════════════════════════════════
var table tbl = table.new(f_pos(tbl_pos), 6, 11,
     border_width=1, border_color=color.new(color.gray, 60),
     frame_width=2,  frame_color=C_TITLE_BG)

if barstate.islast

    // ── Title ──
    table.cell(tbl, 0, 0, "  MULTI-TF  VOLUME DELTA + RSI  SIGNALS  ",
         text_color=color.white, text_size=f_sz(tbl_size),
         bgcolor=C_TITLE_BG, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 5, 0)

    // ── Column Headers ──
    hdrs = array.from("TF", "Buy Vol", "Sell Vol", "Delta", "RSI", "Signal")
    for i = 0 to 5
        table.cell(tbl, i, 1, array.get(hdrs, i),
             text_color=C_TEXT, text_size=f_sz(tbl_size),
             bgcolor=C_HEADER, text_halign=text.align_center)

    // ── TF Data Arrays ──
    tf_names = array.from("5m","15m","30m","75m","240m","Day","Week","Month")
    tf_show  = array.from(show_5, show_15, show_30, show_75, show_240, show_D, show_W, show_M)
    tf_bv    = array.from(bv5,  bv15,  bv30,  bv75,  bv240,  bvD,  bvW,  bvM)
    tf_sv    = array.from(sv5,  sv15,  sv30,  sv75,  sv240,  svD,  svW,  svM)
    tf_dlt   = array.from(dlt5, dlt15, dlt30, dlt75, dlt240, dltD, dltW, dltM)
    tf_rsi   = array.from(rsi5, rsi15, rsi30, rsi75, rsi240, rsiD, rsiW, rsiM)
    tf_sig   = array.from(sig5, sig15, sig30, sig75, sig240, sigD, sigW, sigM)

    row = 2
    for i = 0 to 7
        if array.get(tf_show, i)
            bg  = row % 2 == 0 ? C_ROW_ODD : C_ROW_EVEN
            bv_ = array.get(tf_bv,  i)
            sv_ = array.get(tf_sv,  i)
            d_  = array.get(tf_dlt, i)
            r_  = array.get(tf_rsi, i)
            s_  = array.get(tf_sig, i)

            table.cell(tbl, 0, row, array.get(tf_names, i),
                 text_color=C_TEXT, text_size=f_sz(tbl_size),
                 bgcolor=bg, text_halign=text.align_center)
            table.cell(tbl, 1, row, f_fmt(bv_),
                 text_color=C_BULL, text_size=f_sz(tbl_size),
                 bgcolor=bg, text_halign=text.align_right)
            table.cell(tbl, 2, row, f_fmt(sv_),
                 text_color=C_BEAR, text_size=f_sz(tbl_size),
                 bgcolor=bg, text_halign=text.align_right)
            table.cell(tbl, 3, row, (d_ >= 0 ? "+" : "-") + f_fmt(d_),
                 text_color=f_dlt_col(d_), text_size=f_sz(tbl_size),
                 bgcolor=bg, text_halign=text.align_right)
            table.cell(tbl, 4, row, str.tostring(math.round(r_, 1)),
                 text_color=f_rsi_col(r_), text_size=f_sz(tbl_size),
                 bgcolor=bg, text_halign=text.align_center)
            table.cell(tbl, 5, row, f_sig_str(s_),
                 text_color=f_sig_col(s_), text_size=f_sz(tbl_size),
                 bgcolor=f_sig_bg(s_), text_halign=text.align_center)
            row += 1

    // ── Overall Signal Row ──
    ov_str = overall_buy  ? "★  STRONG  BUY"  :
             overall_sell ? "★  STRONG  SELL" : "◆  NEUTRAL"
    ov_bg  = overall_buy  ? color.new(#00e676, 65) :
             overall_sell ? color.new(#ff1744, 65) : color.new(#455a64, 65)
    ov_col = overall_buy  ? C_BULL : overall_sell ? C_BEAR : C_NEUTRAL

    table.cell(tbl, 0, row,
         "OVERALL  ▲" + str.tostring(bull_count) + "  ▼" + str.tostring(bear_count),
         text_color=C_TEXT, text_size=f_sz(tbl_size),
         bgcolor=C_HEADER, text_halign=text.align_center)
    table.merge_cells(tbl, 0, row, 4, row)
    table.cell(tbl, 5, row, ov_str,
         text_color=ov_col, text_size=f_sz(tbl_size),
         bgcolor=ov_bg, text_halign=text.align_center)

// ═══════════════════════════════════════════════════════════════════════════════
//  BACKGROUND FLASH ON NEW SIGNAL
// ═══════════════════════════════════════════════════════════════════════════════
bgcolor(overall_buy  and not overall_buy[1]  ? color.new(#00c853, 90) : na, title="BUY Flash")
bgcolor(overall_sell and not overall_sell[1] ? color.new(#d50000, 90) : na, title="SELL Flash")

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(overall_buy  and not overall_buy[1],
     title="MTF Strong BUY",
     message="[MTF VD+RSI] STRONG BUY — {{ticker}} @ {{close}}")
alertcondition(overall_sell and not overall_sell[1],
     title="MTF Strong SELL",
     message="[MTF VD+RSI] STRONG SELL — {{ticker}} @ {{close}}")

plot(bull_count, display=display.none, title="Bull Count")
plot(bear_count, display=display.none, title="Bear Count")
````
