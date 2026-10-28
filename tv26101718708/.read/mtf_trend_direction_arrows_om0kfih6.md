# MTF Trend Direction Arrows

- url: https://www.tradingview.com/script/oM0kfih6/
- type: indicator
- pine_id: PUB;ea5c2b97537d4a149c194f3ab9f41940
- version: 1.0

## Description

MTF Trend Direction Arrows

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "TF", text_color=textColor, bgcolor=headerBgColor)
    table.cell(panel, 1, 0, "方向", text_color=textColor, bgcolor=headerBgColor)

    table.cell(panel, 0, 1, "1M", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 1, f_arrow(dir1), text_color=arrowTextColor, bgcolor=f_bg(dir1), text_size=size.large)

    table.cell(panel, 0, 2, "5M", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 2, f_arrow(dir2), text_color=arrowTextColor, bgcolor=f_bg(dir2), text_size=size.large)

## Source Code

````pine
//@version=6
indicator("MTF Trend Direction Arrows", overlay=true)

// ===== パラメータ =====
atrPeriod = input.int(10, "Supertrend ATR期間", minval=1)
factor    = input.float(3.0, "Supertrend Factor", minval=0.01, step=0.01)

emaLen    = input.int(20, "角度判定EMA", minval=1)
slopeBars = input.int(5, "角度判定本数", minval=1)
flatLimit = input.float(0.5, "横ばい判定幅", step=0.1)

showPanel = input.bool(true, "MTF方向パネル表示")

// ===== 色設定 =====
panelBgColor   = input.color(color.black, "パネル背景色")
headerBgColor  = input.color(color.gray, "ヘッダー背景色")
textColor      = input.color(color.white, "文字色")
upColor        = input.color(color.green, "上方向カラー")
downColor      = input.color(color.red, "下方向カラー")
rangeColor     = input.color(color.gray, "レンジカラー")
arrowTextColor = input.color(color.white, "矢印文字色")

// ===== 時間足 =====
tf1 = input.timeframe("1", "時間足 1")
tf2 = input.timeframe("5", "時間足 2")
tf3 = input.timeframe("15", "時間足 3")
tf4 = input.timeframe("60", "時間足 4")
tf5 = input.timeframe("240", "時間足 5")
tf6 = input.timeframe("D", "時間足 6")

// ===== 方向判定関数 =====
f_direction() =>
    ema20 = ta.ema(close, emaLen)
    emaSlope = ema20 - ema20[slopeBars]

    emaUp   = emaSlope > flatLimit
    emaDown = emaSlope < -flatLimit
    emaFlat = math.abs(emaSlope) <= flatLimit

    [st, dir] = ta.supertrend(factor, atrPeriod)

    superUp   = dir < 0
    superDown = dir > 0

    emaFlat ? 0 : superUp and emaUp ? 1 : superDown and emaDown ? -1 : 0

// ===== 各時間足の方向 =====
dir1 = request.security(syminfo.tickerid, tf1, f_direction(), barmerge.gaps_off, barmerge.lookahead_off)
dir2 = request.security(syminfo.tickerid, tf2, f_direction(), barmerge.gaps_off, barmerge.lookahead_off)
dir3 = request.security(syminfo.tickerid, tf3, f_direction(), barmerge.gaps_off, barmerge.lookahead_off)
dir4 = request.security(syminfo.tickerid, tf4, f_direction(), barmerge.gaps_off, barmerge.lookahead_off)
dir5 = request.security(syminfo.tickerid, tf5, f_direction(), barmerge.gaps_off, barmerge.lookahead_off)
dir6 = request.security(syminfo.tickerid, tf6, f_direction(), barmerge.gaps_off, barmerge.lookahead_off)

// ===== 表示用 =====
f_arrow(_dir) =>
    _dir == 1 ? "↑" : _dir == -1 ? "↓" : "→"

f_bg(_dir) =>
    _dir == 1 ? upColor : _dir == -1 ? downColor : rangeColor

// ===== MTFパネル =====
var table panel = table.new(position.top_right, 2, 7, border_width=1)

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "TF", text_color=textColor, bgcolor=headerBgColor)
    table.cell(panel, 1, 0, "方向", text_color=textColor, bgcolor=headerBgColor)

    table.cell(panel, 0, 1, "1M", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 1, f_arrow(dir1), text_color=arrowTextColor, bgcolor=f_bg(dir1), text_size=size.large)

    table.cell(panel, 0, 2, "5M", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 2, f_arrow(dir2), text_color=arrowTextColor, bgcolor=f_bg(dir2), text_size=size.large)

    table.cell(panel, 0, 3, "15M", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 3, f_arrow(dir3), text_color=arrowTextColor, bgcolor=f_bg(dir3), text_size=size.large)

    table.cell(panel, 0, 4, "1H", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 4, f_arrow(dir4), text_color=arrowTextColor, bgcolor=f_bg(dir4), text_size=size.large)

    table.cell(panel, 0, 5, "4H", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 5, f_arrow(dir5), text_color=arrowTextColor, bgcolor=f_bg(dir5), text_size=size.large)

    table.cell(panel, 0, 6, "1D", text_color=textColor, bgcolor=panelBgColor)
    table.cell(panel, 1, 6, f_arrow(dir6), text_color=arrowTextColor, bgcolor=f_bg(dir6), text_size=size.large)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0)

// ===== アラート =====
shortAllUp = dir1 == 1 and dir2 == 1 and dir3 == 1
shortAllDn = dir1 == -1 and dir2 == -1 and dir3 == -1

alertcondition(shortAllUp, title="短期足 上方向一致", message="短期足の方向が上で一致しました")
alertcondition(shortAllDn, title="短期足 下方向一致", message="短期足の方向が下で一致しました")
````
