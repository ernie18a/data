# Prev OHLC + VWAP + Prev VWAP

- url: https://www.tradingview.com/script/0hGVByv0/
- type: indicator
- pine_id: PUB;9a287947097744dbb2dada531b6bebd6
- version: 5.0

## Description

Prev OHLC + VWAP + Prev VWAP

A clean, all-in-one intraday reference indicator that combines previous day's
OHLC levels with current and previous session VWAP. Designed for traders who
want key price reference levels without cluttering the chart.

─── Features ───

- Previous Day OHLC
  Plots the prior trading day's High, Low, Close, and Open as horizontal
  reference levels. Only shown on intraday timeframes.

- VWAP (Volume Weighted Average Price)
  Standard session-anchored VWAP using the official TradingView calculation
  (ta.vwap with period reset). Anchor period is configurable: Session, Week,
  Month, Quarter, or Year.

- Previous Session VWAP
  Locks the final VWAP value from the prior session and displays it as a
  horizontal reference throughout the current session. Useful for identifying
  carry-over support/resistance from the previous day's volume-weighted mean.

─── Color & Style ───

  Prev High   — pink cross, width 2
  Prev Low    — blue cross, width 2
  Prev Close  — green cross, width 2
  Prev Open   — yellow cross, width 1
  VWAP        — cyan solid line, width 3
  Prev VWAP   — dark blue circles, width 1

All three modules (Prev OHLC / VWAP / Prev VWAP) can be toggled independently
from the settings panel.

─── Notes ───

- Prev OHLC and Prev VWAP are displayed only on intraday timeframes.
- VWAP requires volume data; the indicator will alert if none is provided.
- Built in Pine Script v6.

## Source Code

````pine
//@version=6
indicator(title="Prev OHLC + VWAP + Prev VWAP", shorttitle="PrevOHLC+VWAP", overlay=true, max_lines_count=50, max_labels_count=50)

// ============================================================
// 出来高の有無チェック（VWAP系の表示制御に使用。エラーは出さない）
// ============================================================
cumVolume = ta.cum(volume)
hasVolume = not (barstate.islast and cumVolume == 0)

// ============================================================
// ① Prev OHLC（前日のOHLC）
// ============================================================
grpOHLC = "Prev OHLC"
showPrevOHLC = input.bool(true, title="Show Prev OHLC", group=grpOHLC)

D_High  = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_on)
D_Low   = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_on)
D_Close = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_on)
D_Open  = request.security(syminfo.tickerid, "D", open[1],  barmerge.gaps_off, barmerge.lookahead_on)

plot(showPrevOHLC and timeframe.isintraday ? D_High  : na, title="Prev Daily High",  style=plot.style_cross, color=#e91e63, linewidth=2)
plot(showPrevOHLC and timeframe.isintraday ? D_Low   : na, title="Prev Daily Low",   style=plot.style_cross, color=#3179f5, linewidth=2)
plot(showPrevOHLC and timeframe.isintraday ? D_Close : na, title="Prev Daily Close", style=plot.style_cross, color=#81c784, linewidth=2)
plot(showPrevOHLC and timeframe.isintraday ? D_Open  : na, title="Prev Daily Open",  style=plot.style_cross, color=#fff176, linewidth=1)

// ============================================================
// ③ VWAP（Session）
// ============================================================
grpVWAP = "VWAP Settings"
showVWAP  = input.bool(true,  title="Show VWAP",                group=grpVWAP)
hideonDWM = input.bool(true,  title="Hide VWAP on 1D or Above", group=grpVWAP)
anchor    = input.string("Session", title="Anchor Period",
     options=["Session", "Week", "Month", "Quarter", "Year"], group=grpVWAP)
src       = input.source(hlc3, title="Source", group=grpVWAP)

isNewPeriod = switch anchor
    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year"    => timeframe.change("12M")
    => false

if na(src[1])
    isNewPeriod := true

// 出来高があるときだけVWAP計算
float vwapValue = na
if hasVolume
    [_vwap, _, _] = ta.vwap(src, isNewPeriod, 1)
    vwapValue := _vwap

bool hideSessionVwap = hideonDWM and timeframe.isdwm

plot(showVWAP and not hideSessionVwap and hasVolume ? vwapValue : na, title="VWAP", color=#00bcd4, linewidth=3)

// ============================================================
// ④ Prev VWAP
// ============================================================
grpPrevVWAP = "Prev VWAP"
showPrevVWAP = input.bool(true, title="Show Prev VWAP", group=grpPrevVWAP)

var float prevSessionVwap = na
var float runningPrev     = na

if isNewPeriod and not na(runningPrev)
    prevSessionVwap := runningPrev

if not na(vwapValue)
    runningPrev := vwapValue

plot(showPrevVWAP and timeframe.isintraday and hasVolume ? prevSessionVwap : na,
     title="Prev VWAP", color=#01579b, linewidth=1, style=plot.style_circles)

// ============================================================
// ⑤ W-VWAP（Weekly VWAP）― 機関投資家ベンチマーク視点
//     週初日（月曜）: 前週W-VWAPを表示（今週のW-VWAPは形成途中で意味をなさないため）
//     週2日目以降:   今週W-VWAPを表示
// ============================================================
grpWVWAP = "W-VWAP"
showWVWAP      = input.bool(false, title="Show W-VWAP",       group=grpWVWAP)
colWVWAP       = input.color(#e91e63, title="W-VWAP Color",   group=grpWVWAP)
showWVWAPLbl   = input.bool(true,  title="Show W-VWAP Label", group=grpWVWAP)
hideWVWAPonDWM = input.bool(false, title="Hide W-VWAP on 1D or Above", group=grpWVWAP)
showPrevWTag   = input.bool(true,  title="Show 'Prev W' tag on Monday", group=grpWVWAP,
     tooltip="週初日（月曜）は前週のW-VWAPを表示する仕様。ラベルに(Prev W)と付記する。")

isNewWeek = timeframe.change("W")
if na(src[1])
    isNewWeek := true

// 今週のW-VWAP（通常計算）
float wVwapCurrent = na
if hasVolume
    [_wvwap, _, _] = ta.vwap(src, isNewWeek, 1)
    wVwapCurrent := _wvwap

// 前週のW-VWAPを保持
// isNewWeek が true になった瞬間 = 新しい週の最初のバー
// その時点で runningPrevWeek にはまだ「先週最後のW-VWAP値」が残っているので、
// それを prevWeekVwap に確定させる
var float prevWeekVwap = na
var float runningPrevWeek = na

if isNewWeek and not na(runningPrevWeek)
    prevWeekVwap := runningPrevWeek

if not na(wVwapCurrent)
    runningPrevWeek := wVwapCurrent

// 週初日（その週の最初の営業日）判定 ― 分足のみ有効
// 日足以上では isWeekFirstDay = false となり、常に今週W-VWAPが表示される（従来通り）
// 分足では月曜（祝日明けなら火曜）に true となり、前週W-VWAPを表示することで
// セッションVWAPとの融合を回避する
bool isWeekFirstDay = timeframe.isintraday and (time("D") == time("W"))

// 表示するW-VWAP値を決定
// 週初日なら前週W-VWAP、2日目以降なら今週W-VWAP
float wVwapDisplay = isWeekFirstDay ? prevWeekVwap : wVwapCurrent

bool hideWVwap = hideWVWAPonDWM and timeframe.isdwm

plot(showWVWAP and not hideWVwap and hasVolume ? wVwapDisplay : na,
     title="W-VWAP", color=colWVWAP, linewidth=2)

// ラベル ― 最終バーでのみ描画（y=wVwapDisplay が最新の線位置と一致することを保証）
var label wVwapLabel = na

if barstate.islast
    // 既存ラベルを削除してから新規作成
    if not na(wVwapLabel)
        label.delete(wVwapLabel)
        wVwapLabel := na
    
    // 条件を満たすときのみラベル作成
    if showWVWAP and not hideWVwap and hasVolume and showWVWAPLbl and not na(wVwapDisplay)
        labelText = isWeekFirstDay and showPrevWTag ? "W-VWAP (Prev W)" : "W-VWAP"
        wVwapLabel := label.new(
             x=bar_index + 3, y=wVwapDisplay,
             text=labelText,
             xloc=xloc.bar_index,
             textcolor=colWVWAP,
             style=label.style_none,
             size=size.tiny)

// ============================================================
// ⑥ Percentage Levels from Prev Close (±1, 3, 5, 7, 10%)
// ============================================================
grpPct = "Percent Levels"
showPctLevels = input.bool(false, title="Show % Levels from Prev Close", group=grpPct)

colPctSmall = input.color(color.new(color.gray,   50), title="±1% color",   group=grpPct)
colPctMid   = input.color(color.new(color.gray,   30), title="±3/5% color", group=grpPct)
colPctLarge = input.color(color.new(color.orange, 20), title="±7% color",   group=grpPct)
colPctMax   = input.color(color.new(color.red,     0), title="±10% color",  group=grpPct)

pctLevels = array.from(-10.0, -7.0, -5.0, -3.0, -1.0, 1.0, 3.0, 5.0, 7.0, 10.0)
pctWidths = array.from(2, 1, 1, 1, 1, 1, 1, 1, 1, 2)
pctStyles = array.from(line.style_solid, line.style_solid, line.style_solid, line.style_dashed, line.style_dashed, line.style_dashed, line.style_dashed, line.style_solid, line.style_solid, line.style_solid)

var line[]  pctLineArr  = array.new<line>()
var label[] pctLabelArr = array.new<label>()

f_clearPct() =>
    if array.size(pctLineArr) > 0
        for i = 0 to array.size(pctLineArr) - 1
            line.delete(array.get(pctLineArr, i))
        array.clear(pctLineArr)
    if array.size(pctLabelArr) > 0
        for i = 0 to array.size(pctLabelArr) - 1
            label.delete(array.get(pctLabelArr, i))
        array.clear(pctLabelArr)

f_pctColor(float pct) =>
    absPct = math.abs(pct)
    color result = colPctSmall
    if absPct >= 10
        result := colPctMax
    else if absPct >= 7
        result := colPctLarge
    else if absPct >= 3
        result := colPctMid
    result

if showPctLevels and timeframe.isintraday and isNewPeriod and not na(D_Close)
    f_clearPct()
    rightBar = bar_index + 50
    
    for i = 0 to array.size(pctLevels) - 1
        pct   = array.get(pctLevels, i)
        lvl   = D_Close * (1 + pct / 100.0)
        col   = f_pctColor(pct)
        width = array.get(pctWidths, i)
        styl  = array.get(pctStyles, i)
        
        ln = line.new(x1=bar_index, y1=lvl, x2=rightBar, y2=lvl,
                      xloc=xloc.bar_index, color=col, width=width, style=styl,
                      extend=extend.right)
        array.push(pctLineArr, ln)
        
        lbl = label.new(x=rightBar, y=lvl,
                        text=(pct > 0 ? "+" : "") + str.tostring(pct, "#.#") + "%",
                        xloc=xloc.bar_index,
                        textcolor=col,
                        style=label.style_none,
                        size=size.small)
        array.push(pctLabelArr, lbl)

if not showPctLevels and (array.size(pctLineArr) > 0 or array.size(pctLabelArr) > 0)
    f_clearPct()

// ============================================================
// ⑦ Day High / DD Table（横並び1行）
// ============================================================
grpDD = "Day DD Table"
showDDTable = input.bool(false, title="Show Day DD Table", group=grpDD)
tablePos    = input.string("top_center", title="Position",
     options=["top_right", "top_center", "top_left", "bottom_right", "bottom_center", "bottom_left"], group=grpDD)
rightOffset = input.int(10, title="Right offset (spaces from center)", minval=0, maxval=40, group=grpDD, tooltip="top_center選択時に中央から右方向へテーブルをずらすためのスペース数")

var float dayHigh = na

if isNewPeriod
    dayHigh := high
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)

ddFromHigh = not na(dayHigh) and dayHigh > 0 ? (close - dayHigh) / dayHigh * 100 : na

f_ddColor(float v) =>
    absV = math.abs(v)
    color result = color.new(#e91e63, 0)
    if absV < 2
        result := color.new(#81c784, 0)
    else if absV < 5
        result := color.new(#fff176, 0)
    result

f_ddTextColor(float v) =>
    absV = math.abs(v)
    color txt = color.white
    if absV < 5
        txt := color.black
    txt

f_pad(int n) =>
    string s = ""
    if n > 0
        for i = 0 to n - 1
            s := s + " "
    s

var table ddTable = na
if barstate.islast
    if showDDTable and timeframe.isintraday
        tblPos = tablePos == "top_right"     ? position.top_right :
             tablePos == "top_center"    ? position.top_center :
             tablePos == "top_left"      ? position.top_left :
             tablePos == "bottom_right"  ? position.bottom_right :
             tablePos == "bottom_center" ? position.bottom_center :
                                           position.bottom_left
        
        useRightShift = tablePos == "top_center" and rightOffset > 0
        ncols = useRightShift ? 5 : 4
        
        if na(ddTable)
            ddTable := table.new(tblPos, ncols, 1,
                                 bgcolor=color.new(color.black, 100),
                                 border_width=0,
                                 border_color=color.new(color.black, 100))
        
        startCol = useRightShift ? 1 : 0
        
        if useRightShift
            table.cell(ddTable, 0, 0, f_pad(rightOffset),
                       text_color=color.new(color.black, 100),
                       bgcolor=color.new(color.black, 100))
        
        table.cell(ddTable, startCol, 0, "Day High",
                   text_color=color.white, text_size=size.small,
                   bgcolor=color.new(color.gray, 70))
        
        table.cell(ddTable, startCol + 1, 0,
                   na(dayHigh) ? "—" : str.tostring(dayHigh, format.mintick),
                   text_color=color.white, text_size=size.small,
                   bgcolor=color.new(color.black, 50))
        
        table.cell(ddTable, startCol + 2, 0, "DD from H",
                   text_color=color.white, text_size=size.small,
                   bgcolor=color.new(color.gray, 70))
        
        table.cell(ddTable, startCol + 3, 0,
                   na(ddFromHigh) ? "—" : str.tostring(ddFromHigh, "0.00") + "%",
                   text_color=na(ddFromHigh) ? color.white : f_ddTextColor(ddFromHigh),
                   text_size=size.small,
                   bgcolor=na(ddFromHigh) ? color.new(color.gray, 70) : f_ddColor(ddFromHigh))

if not showDDTable and not na(ddTable)
    table.delete(ddTable)
    ddTable := na
````
