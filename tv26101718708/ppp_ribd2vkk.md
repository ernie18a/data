# PPP

- url: https://www.tradingview.com/script/riBD2vkK/
- type: indicator
- pine_id: PUB;a6f9e5bebaef471a976e61e2196d04e4
- version: 1.0

## Description

ぴぴぴぴぴぴ

## Source Code

````pine
//@version=5
indicator(title="セッション表示 (Tokyo / London / NY)", shorttitle="Sessions", overlay=false, max_bars_back=500)

var GS = "設定"
var GC = "カラー"

use_dst = input.bool(true, "夏時間 (DST) を使用する", group=GS, tooltip="夏: 3月〜11月頃 / 冬: 11月〜3月頃")

show_tokyo  = input.bool(true, "東京時間を表示",    group=GS)
show_london = input.bool(true, "ロンドン時間を表示", group=GS)
show_ny     = input.bool(true, "NY時間を表示",       group=GS)

tokyo_col  = input.color(color.new(#42A5F5, 35), "東京",    group=GC)
london_col = input.color(color.new(#4CAF50, 35), "ロンドン", group=GC)
ny_col     = input.color(color.new(#EF5350, 35), "NY",       group=GC)

TOKYO_SUMMER  = "2300-0800:23456"
LONDON_SUMMER = "0700-1600:23456"
NY_SUMMER     = "1200-2100:23456"

TOKYO_WINTER  = "0000-0900:23456"
LONDON_WINTER = "0800-1700:23456"
NY_WINTER     = "1300-2200:23456"

tokyo_sess  = use_dst ? TOKYO_SUMMER  : TOKYO_WINTER
london_sess = use_dst ? LONDON_SUMMER : LONDON_WINTER
ny_sess     = use_dst ? NY_SUMMER     : NY_WINTER

in_tokyo  = show_tokyo  and not na(time(timeframe.period, tokyo_sess,  "UTC"))
in_london = show_london and not na(time(timeframe.period, london_sess, "UTC"))
in_ny     = show_ny     and not na(time(timeframe.period, ny_sess,     "UTC"))

plot(0, display=display.none)
plot(4, display=display.none)

plot(in_tokyo  ? 3 : na, title="東京",     color=tokyo_col,  linewidth=8, style=plot.style_linebr)
plot(in_london ? 2 : na, title="ロンドン", color=london_col, linewidth=8, style=plot.style_linebr)
plot(in_ny     ? 1 : na, title="NY",       color=ny_col,     linewidth=8, style=plot.style_linebr)
````
