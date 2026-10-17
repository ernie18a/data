# Two-Point Low Trendline with Bands

- url: https://www.tradingview.com/script/JJuLajvf/
- type: indicator
- pine_id: PUB;c40cc7a65de348d78a9f8acb070a5743
- version: 1.0

## Description

상승 추세선을 특정한 %의 밴드를 가지고 추적하는 기능

## Source Code

````pine
//@version=5
indicator("Two-Point Low Trendline with Bands", overlay=true)

// ─── 입력 ───────────────────────────────────────────────
date1     = input.time(timestamp("2024-01-01"), "📅 첫 번째 날짜", confirm=true)
date2     = input.time(timestamp("2024-06-01"), "📅 두 번째 날짜", confirm=true)
bandPct   = input.float(4.0, "밴드 폭 (%)", minval=0.1, maxval=20.0, step=0.1)
lineCol   = input.color(color.new(color.blue, 0), "선 색상")
fillAlpha = input.int(85, "채움 투명도", minval=0, maxval=100)

// ─── 날짜 매칭 ──────────────────────────────────────────
var float low1    = na
var float low2    = na
var int   barIdx1 = na
var int   barIdx2 = na

bool match1 = dayofmonth(date1) == dayofmonth(time) and month(date1) == month(time) and year(date1) == year(time)
bool match2 = dayofmonth(date2) == dayofmonth(time) and month(date2) == month(time) and year(date2) == year(time)

if match1 and na(low1)
    low1    := low
    barIdx1 := bar_index

if match2 and na(low2)
    low2    := low
    barIdx2 := bar_index

// ─── 마지막 봉에서 line 생성 ────────────────────────────
var line l_mid = na
var line l_up  = na
var line l_dn  = na
var linefill lf_up = na
var linefill lf_dn = na

if barstate.islast and not na(barIdx1) and not na(barIdx2)
    up1 = low1 * (1 + bandPct / 100)
    dn1 = low1 * (1 - bandPct / 100)
    up2 = low2 * (1 + bandPct / 100)
    dn2 = low2 * (1 - bandPct / 100)

    line.delete(l_mid)
    line.delete(l_up)
    line.delete(l_dn)
    linefill.delete(lf_up)
    linefill.delete(lf_dn)

    l_mid := line.new(barIdx1, low1, barIdx2, low2, extend=extend.right, color=lineCol, width=2, style=line.style_solid)
    l_up  := line.new(barIdx1, up1,  barIdx2, up2,  extend=extend.right, color=color.new(lineCol, 40), width=1, style=line.style_dashed)
    l_dn  := line.new(barIdx1, dn1,  barIdx2, dn2,  extend=extend.right, color=color.new(lineCol, 40), width=1, style=line.style_dashed)

    lf_up := linefill.new(l_mid, l_up, color=color.new(lineCol, fillAlpha))
    lf_dn := linefill.new(l_mid, l_dn, color=color.new(lineCol, fillAlpha))

// ─── 기준점 마커 ────────────────────────────────────────
plotshape(bar_index == barIdx1, title="점1", location=location.belowbar, style=shape.triangleup, color=lineCol, size=size.small)
plotshape(bar_index == barIdx2, title="점2", location=location.belowbar, style=shape.triangleup, color=lineCol, size=size.small)

// ─── 날짜 라벨 (삼각형 아래 여백 확보) ──────────────────
var label lbl1 = na
var label lbl2 = na

if match1 and na(lbl1)
    lbl1 := label.new(
         x=bar_index,
         y=low1 * (1 - bandPct / 100) * 0.90,
         text=str.tostring(year(date1)) + "/" + str.tostring(month(date1)) + "/" + str.tostring(dayofmonth(date1)),
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         textcolor=lineCol,
         size=size.normal)

if match2 and na(lbl2)
    lbl2 := label.new(
         x=bar_index,
         y=low2 * (1 - bandPct / 100) * 0.90,
         text=str.tostring(year(date2)) + "/" + str.tostring(month(date2)) + "/" + str.tostring(dayofmonth(date2)),
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_none,
         textcolor=lineCol,
         size=size.normal)
````
