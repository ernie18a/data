# Nr_ATR Grid

- url: https://www.tradingview.com/script/c0Jq6Be4/
- type: indicator
- pine_id: PUB;b93c2f34d2a444df862015e37bb2ffdc
- version: 1.0

## Description

Nr_ATR Grid
ATRのグリッド

## Source Code

````pine
//@version=5
indicator("Nr_ATR Grid", overlay=true, max_lines_count=500, max_labels_count=500)

atrLen       = input.int(10,    "日足平均 計算期間")
gridLines    = input.int(10,    "片側グリッド本数", minval=1, maxval=20)
usePrevClose = input.bool(true, "基準：前セッション終値(✓) or 当セッション始値")

colorBull    = input.color(color.new(color.red,  30), "ATRBull ラインカラー")
colorBear    = input.color(color.new(color.blue, 30), "ATRBear ラインカラー")

showDay      = input.bool(true,  "デイセッション 表示", group="デイ セッション")
colorDay     = input.color(color.new(color.yellow, 80), "デイ 背景色", group="デイ セッション")
showDayRange = input.bool(true,  "レンジ表示", group="デイ セッション")

showNight      = input.bool(true,  "ナイトセッション 表示", group="ナイト セッション")
colorNight     = input.color(color.new(color.purple, 80), "ナイト 背景色", group="ナイト セッション")
showNightRange = input.bool(true,  "レンジ表示", group="ナイト セッション")

daySession   = "0845-1515:1234567"
nightSession = "1630-0530:1234567"

isDay   = not na(time("15", daySession,   "Asia/Tokyo"))
isNight = not na(time("15", nightSession, "Asia/Tokyo"))

atrDaily = request.security(syminfo.tickerid, "D", ta.atr(atrLen))
gridStep = atrDaily * 0.5

dayStart   = isDay   and not isDay[1]
nightStart = isNight and not isNight[1]

var float centerDay   = na
var float centerNight = na

if dayStart
    centerDay := usePrevClose ? close[1] : open

if nightStart
    centerNight := usePrevClose ? close[1] : open

center = isDay ? centerDay : isNight ? centerNight : na

bgcolor(isDay   and showDay   ? colorDay   : na, title="デイ背景")
bgcolor(isNight and showNight ? colorNight : na, title="ナイト背景")

p0  = center
p1u = not na(center) ? center + gridStep * 1 : na
p2u = not na(center) ? center + gridStep * 2 : na
p3u = not na(center) ? center + gridStep * 3 : na
p4u = not na(center) ? center + gridStep * 4 : na
p5u = not na(center) ? center + gridStep * 5 : na
p6u = not na(center) ? center + gridStep * 6 : na
p7u = not na(center) ? center + gridStep * 7 : na
p8u = not na(center) ? center + gridStep * 8 : na
p9u = not na(center) ? center + gridStep * 9 : na
p10u= not na(center) ? center + gridStep * 10: na

p1d = not na(center) ? center - gridStep * 1 : na
p2d = not na(center) ? center - gridStep * 2 : na
p3d = not na(center) ? center - gridStep * 3 : na
p4d = not na(center) ? center - gridStep * 4 : na
p5d = not na(center) ? center - gridStep * 5 : na
p6d = not na(center) ? center - gridStep * 6 : na
p7d = not na(center) ? center - gridStep * 7 : na
p8d = not na(center) ? center - gridStep * 8 : na
p9d = not na(center) ? center - gridStep * 9 : na
p10d= not na(center) ? center - gridStep * 10: na

// --- ラベル用 価格文字列 ---
f_label(price) => str.tostring(math.round_to_mintick(price))

// ============ Center ============
plot(p0, "Center", color=color.new(#000000, 20), linewidth=2, style=plot.style_line)

// ============ Bull+ side (Even=linewidth2, Odd=linewidth1) ============
plot(gridLines >= 1  ? p1u  : na, "Bull+1",  color=colorBull, linewidth=1)
if barstate.islast and gridLines >= 1 and not na(p1u)
    label.new(bar_index, p1u, f_label(p1u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 2  ? p2u  : na, "Bull+2",  color=colorBull, linewidth=2)
if barstate.islast and gridLines >= 2 and not na(p2u)
    label.new(bar_index, p2u, f_label(p2u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 3  ? p3u  : na, "Bull+3",  color=colorBull, linewidth=1)
if barstate.islast and gridLines >= 3 and not na(p3u)
    label.new(bar_index, p3u, f_label(p3u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 4  ? p4u  : na, "Bull+4",  color=colorBull, linewidth=2)
if barstate.islast and gridLines >= 4 and not na(p4u)
    label.new(bar_index, p4u, f_label(p4u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 5  ? p5u  : na, "Bull+5",  color=colorBull, linewidth=1)
if barstate.islast and gridLines >= 5 and not na(p5u)
    label.new(bar_index, p5u, f_label(p5u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 6  ? p6u  : na, "Bull+6",  color=colorBull, linewidth=2)
if barstate.islast and gridLines >= 6 and not na(p6u)
    label.new(bar_index, p6u, f_label(p6u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 7  ? p7u  : na, "Bull+7",  color=colorBull, linewidth=1)
if barstate.islast and gridLines >= 7 and not na(p7u)
    label.new(bar_index, p7u, f_label(p7u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 8  ? p8u  : na, "Bull+8",  color=colorBull, linewidth=2)
if barstate.islast and gridLines >= 8 and not na(p8u)
    label.new(bar_index, p8u, f_label(p8u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 9  ? p9u  : na, "Bull+9",  color=colorBull, linewidth=1)
if barstate.islast and gridLines >= 9 and not na(p9u)
    label.new(bar_index, p9u, f_label(p9u), style=label.style_none, textcolor=colorBull, size=size.small)

plot(gridLines >= 10 ? p10u : na, "Bull+10", color=colorBull, linewidth=2)
if barstate.islast and gridLines >= 10 and not na(p10u)
    label.new(bar_index, p10u, f_label(p10u), style=label.style_none, textcolor=colorBull, size=size.small)

// ============ Bear- side (Even=linewidth2, Odd=linewidth1) ============
plot(gridLines >= 1  ? p1d  : na, "Bear-1",  color=colorBear, linewidth=1)
if barstate.islast and gridLines >= 1 and not na(p1d)
    label.new(bar_index, p1d, f_label(p1d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 2  ? p2d  : na, "Bear-2",  color=colorBear, linewidth=2)
if barstate.islast and gridLines >= 2 and not na(p2d)
    label.new(bar_index, p2d, f_label(p2d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 3  ? p3d  : na, "Bear-3",  color=colorBear, linewidth=1)
if barstate.islast and gridLines >= 3 and not na(p3d)
    label.new(bar_index, p3d, f_label(p3d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 4  ? p4d  : na, "Bear-4",  color=colorBear, linewidth=2)
if barstate.islast and gridLines >= 4 and not na(p4d)
    label.new(bar_index, p4d, f_label(p4d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 5  ? p5d  : na, "Bear-5",  color=colorBear, linewidth=1)
if barstate.islast and gridLines >= 5 and not na(p5d)
    label.new(bar_index, p5d, f_label(p5d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 6  ? p6d  : na, "Bear-6",  color=colorBear, linewidth=2)
if barstate.islast and gridLines >= 6 and not na(p6d)
    label.new(bar_index, p6d, f_label(p6d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 7  ? p7d  : na, "Bear-7",  color=colorBear, linewidth=1)
if barstate.islast and gridLines >= 7 and not na(p7d)
    label.new(bar_index, p7d, f_label(p7d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 8  ? p8d  : na, "Bear-8",  color=colorBear, linewidth=2)
if barstate.islast and gridLines >= 8 and not na(p8d)
    label.new(bar_index, p8d, f_label(p8d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 9  ? p9d  : na, "Bear-9",  color=colorBear, linewidth=1)
if barstate.islast and gridLines >= 9 and not na(p9d)
    label.new(bar_index, p9d, f_label(p9d), style=label.style_none, textcolor=colorBear, size=size.small)

plot(gridLines >= 10 ? p10d : na, "Bear-10", color=colorBear, linewidth=2)
if barstate.islast and gridLines >= 10 and not na(p10d)
    label.new(bar_index, p10d, f_label(p10d), style=label.style_none, textcolor=colorBear, size=size.small)
````
