# OneTrades Trend Dashboard

- url: https://www.tradingview.com/script/zrTDo2K2-OneTrades-Trend-Dashboard/
- type: indicator
- pine_id: PUB;ed36c2dc5db34ee492487a3b321ab3b0
- version: 1.0

## Description

This is trend analysis dashboard that help traders to identify (bias) focusing on Gold , BTC and etc. Use wisely . This is all giving back to community . 

May ‎اَللّهُ bless everyone , Allahumma Baarik

## Source Code

````pine
//@version=5
indicator("MTF Trend Dashboard", overlay=true, max_lines_count=0, max_labels_count=0)

grp_ema = "📐 EMA Settings"
fast_len  = input.int(21,  "Fast EMA",  minval=1, maxval=500, group=grp_ema)
slow_len  = input.int(50,  "Slow EMA",  minval=1, maxval=500, group=grp_ema)
trend_len = input.int(200, "Trend EMA", minval=1, maxval=500, group=grp_ema)

grp_tf = "⏱ Timeframes"
tf1 = input.timeframe("D",   "Timeframe 1", group=grp_tf)
tf2 = input.timeframe("240", "Timeframe 2", group=grp_tf)
tf3 = input.timeframe("60",  "Timeframe 3", group=grp_tf)
tf4 = input.timeframe("30",  "Timeframe 4", group=grp_tf)
tf5 = input.timeframe("15",  "Timeframe 5", group=grp_tf)
tf6 = input.timeframe("5",   "Timeframe 6", group=grp_tf)

grp_ui = "🎨 Display"
ui_pos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp_ui)
ui_size = input.string("Small", "Text Size", options=["Auto","Tiny","Small","Normal","Large"], group=grp_ui)

getTrend(tf) =>
    c  = request.security(syminfo.tickerid, tf, close,                    lookahead=barmerge.lookahead_off)
    ef = request.security(syminfo.tickerid, tf, ta.ema(close, fast_len),  lookahead=barmerge.lookahead_off)
    es = request.security(syminfo.tickerid, tf, ta.ema(close, slow_len),  lookahead=barmerge.lookahead_off)
    et = request.security(syminfo.tickerid, tf, ta.ema(close, trend_len), lookahead=barmerge.lookahead_off)
    c > et and ef > es

b1 = getTrend(tf1)
b2 = getTrend(tf2)
b3 = getTrend(tf3)
b4 = getTrend(tf4)
b5 = getTrend(tf5)
b6 = getTrend(tf6)

tfName(tf) =>
    switch tf
        "D"   => "  DAILY "
        "W"   => "  WEEKLY"
        "M"   => " MONTHLY"
        "240" => "  4 HOUR"
        "60"  => "  1 HOUR"
        "30"  => "  30 MIN"
        "15"  => "  15 MIN"
        "5"   => "   5 MIN"
        "3"   => "   3 MIN"
        "1"   => "   1 MIN"
        => "  " + tf

tPos() =>
    switch ui_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        => position.bottom_left

tSize() =>
    switch ui_size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.auto

C_BULL_BG   = color.new(#00c853, 5)
C_BEAR_BG   = color.new(#d32f2f, 5)
C_BULL_DOT  = color.new(#00e676, 0)
C_BEAR_DOT  = color.new(#ff1744, 0)
C_HDR_BG    = color.new(#1a1f4e, 10)
C_HDR_TXT   = color.new(#9fa8da, 0)
C_ROW_ODD   = color.new(#0c0c1c, 8)
C_ROW_EVEN  = color.new(#12122a, 8)
C_ROW_TXT   = color.new(#e0e0ff, 0)
C_WHITE     = color.white
C_MIX_BG    = color.new(#b84c00, 10)
C_MIX_TXT   = color.new(#ffcc02, 0)
C_BULL_ALL  = color.new(#1b5e20, 10)
C_BULL_ATXT = color.new(#69f0ae, 0)
C_BEAR_ALL  = color.new(#7f0000, 10)
C_BEAR_ATXT = color.new(#ff5252, 0)

var table dash = table.new(tPos(), 3, 8,
     bgcolor      = color.new(#080812, 8),
     border_width = 1,
     border_color = color.new(#2a2a60, 0),
     frame_width  = 2,
     frame_color  = color.new(#3a3aaa, 20))

if barstate.islast
    sz = tSize()

    table.cell(dash, 0, 0, "  TIME  ", bgcolor=C_HDR_BG, text_color=C_HDR_TXT, text_size=sz, text_halign=text.align_center)
    table.cell(dash, 1, 0, " TREND  ", bgcolor=C_HDR_BG, text_color=C_HDR_TXT, text_size=sz, text_halign=text.align_center)
    table.cell(dash, 2, 0, " STATUS ", bgcolor=C_HDR_BG, text_color=C_HDR_TXT, text_size=sz, text_halign=text.align_center)

    tfs   = array.from(tf1, tf2, tf3, tf4, tf5, tf6)
    bulls = array.from(b1,  b2,  b3,  b4,  b5,  b6)

    for i = 0 to 5
        bull  = array.get(bulls, i)
        tf    = array.get(tfs, i)
        rowBg = i % 2 == 0 ? C_ROW_ODD : C_ROW_EVEN

        table.cell(dash, 0, i + 1, tfName(tf), bgcolor=rowBg, text_color=C_ROW_TXT, text_size=sz, text_halign=text.align_center)
        table.cell(dash, 1, i + 1, bull ? " BULL " : " BEAR ", bgcolor=bull ? C_BULL_BG : C_BEAR_BG, text_color=C_WHITE, text_size=sz, text_halign=text.align_center)
        table.cell(dash, 2, i + 1, "  ●  ", bgcolor=rowBg, text_color=bull ? C_BULL_DOT : C_BEAR_DOT, text_size=sz, text_halign=text.align_center)

    bullCount = (b1?1:0) + (b2?1:0) + (b3?1:0) + (b4?1:0) + (b5?1:0) + (b6?1:0)
    allBull   = bullCount == 6
    allBear   = bullCount == 0

    sigTxt = allBull ? "✅  FULL BULL  —  STRONG BUY" : allBear ? "🔴  FULL BEAR  —  STRONG SELL" : "⚠  MIXED SIGNALS  (" + str.tostring(bullCount) + " / 6 Bull)"
    sigBg  = allBull ? C_BULL_ALL  : allBear ? C_BEAR_ALL  : C_MIX_BG
    sigClr = allBull ? C_BULL_ATXT : allBear ? C_BEAR_ATXT : C_MIX_TXT

    table.merge_cells(dash, 0, 7, 2, 7)
    table.cell(dash, 0, 7, sigTxt, bgcolor=sigBg, text_color=sigClr, text_size=sz, text_halign=text.align_center)
````
