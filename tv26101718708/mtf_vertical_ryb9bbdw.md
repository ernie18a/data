# MTF vertical

- url: https://www.tradingview.com/script/rYB9BBdW/
- type: indicator
- pine_id: PUB;37eadf4080ad45948f8c0e3ba18bc051
- version: 2.0

## Description

MTF vertical

뭘 자꾸 설명하래

3-30
5-60
15-240
60-D

## Source Code

````pine
//@version=5
indicator("MTF 수직선", overlay=true, max_lines_count=500)

// ───────────────────────────────────────────
// 수직선 설정
// ───────────────────────────────────────────
line_color       = input.color(color.new(color.white, 50), "수직선 색상", group="수직선")
line_width       = input.int(1, "선 두께", minval=1, maxval=4, group="수직선")
line_style_input = input.string("dashed", "선 스타일", options=["solid", "dashed", "dotted"], group="수직선")
_style = line_style_input == "dashed" ? line.style_dashed : line_style_input == "dotted" ? line.style_dotted : line.style_solid

// ───────────────────────────────────────────
// 타임프레임 설정
// ───────────────────────────────────────────
tf = timeframe.period

string higher_tf   = ""
string model_label = ""
int    ref_seconds = 0

if tf == "3"
    higher_tf   := "30"
    model_label := "3m → 30m"
    ref_seconds := 30 * 60
else if tf == "5"
    higher_tf   := "60"
    model_label := "5m → 1H"
    ref_seconds := 60 * 60
else if tf == "15"
    higher_tf   := "240"
    model_label := "15m → 4H"
    ref_seconds := 4 * 60 * 60
else if tf == "60"
    higher_tf   := "D"
    model_label := "1H → 1D"
    ref_seconds := 24 * 60 * 60

// ───────────────────────────────────────────
// 수직선 그리기
// ───────────────────────────────────────────
bool htf_new_bar = higher_tf != "" and ta.change(time(higher_tf)) != 0

if htf_new_bar
    line.new(x1=bar_index, y1=high, x2=bar_index, y2=low, extend=extend.both, color=line_color, style=_style, width=line_width)

// ───────────────────────────────────────────
// 카운트다운
// ───────────────────────────────────────────
string rem_str = ""
if ref_seconds > 0
    int remaining = ref_seconds - int(time % (ref_seconds * 1000)) / 1000
    rem_str := "Next: " + str.tostring(remaining / 3600, "00") + ":" + str.tostring((remaining % 3600) / 60, "00") + ":" + str.tostring(remaining % 60, "00")

// ───────────────────────────────────────────
// 정보 박스 (오른쪽 하단)
// 배경 없음 / 테두리 검은색
// ───────────────────────────────────────────
var table info_box = table.new(position=position.bottom_right, columns=1, rows=3, bgcolor=color.new(color.white, 100), border_color=color.new(color.black, 100), border_width=0, frame_color=color.new(color.black, 100), frame_width=0)

if barstate.islast and model_label != ""
    table.cell(table_id=info_box, column=0, row=0, text=syminfo.ticker + " (" + tf + ")", text_color=color.black, text_size=size.normal, bgcolor=color.new(color.white, 100))
    table.cell(table_id=info_box, column=0, row=1, text=model_label, text_color=color.black, text_size=size.small, bgcolor=color.new(color.white, 100))
    table.cell(table_id=info_box, column=0, row=2, text=rem_str, text_color=color.black, text_size=size.small, bgcolor=color.new(color.white, 100))
````
