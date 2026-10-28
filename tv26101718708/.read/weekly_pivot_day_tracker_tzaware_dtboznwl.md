# Weekly Pivot Day Tracker (TZ-aware)

- url: https://www.tradingview.com/script/dTbozNWl/
- type: indicator
- pine_id: PUB;f614d689248f47838c6f1d6e79b0cef5
- version: 1.0

## Description

Tracks which weekday the weekly high and low actually land on, and tallies the distribution over all loaded bars.
Most "Monday reversal" type claims are sensitive to where the week boundary sits. This indicator exposes a timezone selector (Exchange / Seoul / New York / UTC) so you can check for yourself whether a weekday pattern survives a boundary shift — or whether it was just a calendar artifact.
Features
• Monday background highlight
• Markers when the weekly high/low prints on Monday
• Live stats table: % of weeks where the pivot landed on Monday vs. the 14.3% uniform baseline
Best on the 1D timeframe. Scroll back to load more history for a larger sample. This is an analysis tool, not a signal — it helps you test a hypothesis, not trade one.

## Source Code

````pine
//@version=6
indicator("월요일 표시 + 주간 피벗", overlay=true)

// ── 설정 ──
tzOpt   = input.string("Exchange", "요일 기준 타임존", options=["Exchange", "Asia/Seoul", "America/New_York", "UTC"])
showBg  = input.bool(true,  "월요일 배경 칠하기")
showPiv = input.bool(true,  "주간 고점/저점이 월요일이면 마커")
showTbl = input.bool(true,  "통계 표 (일봉 차트 권장)")

tz    = tzOpt == "Exchange" ? syminfo.timezone : tzOpt
dow   = dayofweek(time, tz)
isMon = dow == dayofweek.monday

// ── 월요일 배경 ──
bgcolor(showBg and isMon ? color.new(color.blue, 88) : na, title="월요일")

// ── 주간 고점/저점이 나온 요일 추적 ──
var float wH  = na
var float wL  = na
var int   wHd = na
var int   wLd = na
var int   total   = 0
var int   monHigh = 0
var int   monLow  = 0

newWk = timeframe.change("1W")

// 새 주 진입 = 직전 주 확정 후 집계
if newWk and not na(wL)
    total := total + 1
    if wHd == dayofweek.monday
        monHigh := monHigh + 1
    if wLd == dayofweek.monday
        monLow := monLow + 1

// 주간 극값 갱신 (새 주면 리셋)
if newWk
    wH := high, wL := low, wHd := dow, wLd := dow
else
    if high > wH
        wH := high, wHd := dow
    if low < wL
        wL := low, wLd := dow

// ── 마커: 월요일 캔들이 현재 주 극값 위치일 때 ──
plotshape(showPiv and isMon and low  == wL ? wL : na, title="월 저점",
          style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(showPiv and isMon and high == wH ? wH : na, title="월 고점",
          style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.tiny)

// ── 통계 표 ──
var table t = table.new(position.top_right, 2, 4, border_width=1)
if showTbl and barstate.islast and total > 0
    pL = str.tostring(monLow  / total * 100, "#.0")
    pH = str.tostring(monHigh / total * 100, "#.0")
    table.cell(t, 0, 0, "집계 " + str.tostring(total) + "주", bgcolor=color.gray, text_color=color.white)
    table.cell(t, 1, 0, "월요일", bgcolor=color.gray, text_color=color.white)
    table.cell(t, 0, 1, "주간 저점")
    table.cell(t, 1, 1, str.tostring(monLow)  + " (" + pL + "%)")
    table.cell(t, 0, 2, "주간 고점")
    table.cell(t, 1, 2, str.tostring(monHigh) + " (" + pH + "%)")
    table.cell(t, 0, 3, "균등 기댓값")
    table.cell(t, 1, 3, "14.3%")
````
