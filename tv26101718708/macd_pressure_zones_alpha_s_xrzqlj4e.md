# MACD Pressure Zones | Alpha S+

- url: https://www.tradingview.com/script/XrZQLJ4E-MACD-Pressure-Zones-Alpha-S/
- type: indicator
- pine_id: PUB;9253051585d042b0891b7b5e9865671e
- version: 3.0

## Description

MACD Pressure Zones

MACD Pressure Zones is a normalized MACD histogram oscillator designed to show momentum pressure on a 0 to 100 scale.

Instead of displaying the raw MACD histogram around a zero line, this script normalizes the histogram over a selected lookback period and maps it into a bounded oscillator range. This allows users to compare MACD histogram pressure across different market conditions with fixed reference zones such as 90, 85, 50, 15, and 10.

The script does not provide entry or exit recommendations. Its purpose is to help users study momentum pressure, extended momentum areas, neutral pressure, and cooling or heating behavior inside a simplified MACD-based zone structure.

────────────────────
Core Concept
────────────────────

The standard MACD histogram shows the distance between the MACD line and the signal line.

When the histogram expands, momentum pressure is increasing.

When the histogram contracts, momentum pressure is weakening.

This script takes that MACD histogram value and normalizes it into a 0 to 100 range.

The normalized structure uses five main reference levels:

• 90: Extreme upper momentum pressure
• 85: Upper pressure zone
• 50: Neutral pressure level
• 15: Lower pressure zone
• 10: Extreme lower momentum pressure

The red line is a smoothed version of the normalized MACD histogram. It helps users read the broader momentum pressure curve rather than reacting to every individual histogram bar.

────────────────────
What This Script Shows
────────────────────

The script can display:

• normalized MACD histogram columns
• smoothed MACD pressure line
• 90 and 85 upper pressure levels
• 50 neutral pressure level
• 15 and 10 lower pressure levels
• upper and lower zone background highlights
• histogram expansion or contraction state
• current pressure zone
• momentum heating or cooling state
• positive or negative pressure bias
• number of bars spent inside upper or lower pressure zones
• optional status panel

These elements are designed to help users identify whether MACD histogram pressure is extended, recovering, cooling, expanding, or returning toward neutral.

────────────────────
How It Works
────────────────────

1. The script calculates the MACD line using the selected fast and slow EMA lengths.
2. The signal line is calculated from the MACD line.
3. The MACD histogram is calculated as MACD minus signal.
4. The histogram is normalized over the selected lookback period.
5. The normalized value is mapped into a 0 to 100 oscillator range.
6. A smoothed red pressure line is calculated from the normalized oscillator.
7. The script compares the pressure line with the 90, 85, 50, 15, and 10 reference levels.
8. Zone background highlights appear when the pressure line enters upper or lower pressure areas.
9. Histogram columns become visually stronger or weaker depending on expansion or contraction.
10. The status panel summarizes current pressure, zone, momentum state, bias, zone duration, and histogram condition.

This structure converts MACD histogram behavior into a cleaner zone-based momentum pressure map.

────────────────────
Inputs And Customization
────────────────────

Users can adjust:

• MACD fast length
• MACD slow length
• MACD signal length
• source price
• normalization lookback
• red line smoothing length
• 0 to 100 clamping
• extreme upper pressure level
• upper pressure level
• neutral pressure level
• lower pressure level
• extreme lower pressure level
• zone background visibility
• histogram visibility
• red line visibility
• status panel visibility
• panel position
• panel text size
• histogram colors
• red line color
• reference level color
• panel background color

The default levels are designed around a 90 / 85 / 50 / 15 / 10 pressure-zone framework.

────────────────────
Visual Elements
────────────────────

The script includes:

• normalized histogram columns
• smoothed red pressure line
• horizontal reference levels
• upper pressure background
• lower pressure background
• status panel

The histogram columns show the normalized MACD histogram value.

The red line smooths the normalized histogram and makes the pressure cycle easier to read.

The 50 level acts as the neutral pressure reference.

The 85 and 90 levels mark upper momentum pressure zones.

The 15 and 10 levels mark lower momentum pressure zones.

The panel summarizes the current state without adding directional trade labels to the chart.

────────────────────
Reference States
────────────────────

Extreme Upper Pressure:
The smoothed pressure line is at or above the upper extreme level.

Upper Pressure:
The smoothed pressure line is inside the upper pressure zone.

Positive Pressure:
The pressure line is above the neutral level but below the upper pressure zone.

Neutral Pressure:
The pressure line is near the neutral reference level.

Negative Pressure:
The pressure line is below the neutral level but above the lower pressure zone.

Lower Pressure:
The smoothed pressure line is inside the lower pressure zone.

Extreme Lower Pressure:
The smoothed pressure line is at or below the lower extreme level.

Heating:
The smoothed pressure line is rising.

Cooling:
The smoothed pressure line is falling.

Expanding:
The normalized histogram is increasing compared with the prior bar.

Contracting:
The normalized histogram is decreasing compared with the prior bar.

These states are informational and should not be interpreted as trading instructions.

────────────────────
How To Use
────────────────────

Use this script as a MACD histogram pressure and momentum-zone viewer.

General interpretation examples:

• When the red line is above 85, MACD histogram pressure is in an upper extended area.
• When the red line is above 90, the upper pressure condition is more extreme.
• When the red line moves down from the upper pressure zone, momentum pressure may be cooling.
• When the red line is near 50, MACD histogram pressure is closer to neutral.
• When the red line is below 15, MACD histogram pressure is in a lower extended area.
• When the red line is below 10, the lower pressure condition is more extreme.
• When the red line rises from the lower pressure zone, momentum pressure may be heating.
• Zone Bars can help users see how long the pressure line has remained in an upper or lower pressure zone.
• Histogram expansion can show strengthening pressure, while contraction can show fading pressure.

This script is best reviewed together with price action, trend structure, volatility, support and resistance, and higher-timeframe context.

────────────────────
Confirmation And Repainting Notes
────────────────────

The script calculates MACD, the histogram, normalization range, and the smoothed pressure line from available chart data.

On realtime candles, values can change before the candle closes because the MACD histogram and normalization values can update intrabar.

For more conservative analysis, users should review the oscillator after candle confirmation.

The script does not use future price data to predict market direction.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide entry or exit recommendations.

A high pressure reading does not guarantee a reversal.

A low pressure reading does not guarantee a rebound.

MACD histogram behavior can remain extended during strong trends.

Normalization depends on the selected lookback period, so readings may change when the lookback setting changes.

Different symbols and timeframes may require different settings.

This script should not be used as a standalone trading system.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to trade any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

MACD Pressure Zones

MACD Pressure Zones는 MACD 히스토그램을 0~100 범위로 정규화하여 모멘텀 압력 구간을 보여주는 오실레이터형 지표입니다.

일반 MACD 히스토그램을 0선 중심으로 표시하는 대신, 이 스크립트는 선택한 lookback 구간 안에서 히스토그램 값을 정규화하고 이를 고정된 오실레이터 범위로 변환합니다. 이를 통해 90, 85, 50, 15, 10과 같은 기준 구간을 사용해 다양한 시장 상황의 MACD 히스토그램 압력을 비교할 수 있습니다.

이 지표는 진입 또는 청산 추천을 제공하지 않습니다. 목적은 모멘텀 압력, 확장된 모멘텀 구간, 중립 압력, cooling 또는 heating 상태를 단순한 MACD 기반 구간 구조 안에서 분석하는 것입니다.

────────────────────
핵심 개념
────────────────────

일반 MACD 히스토그램은 MACD 라인과 시그널 라인 사이의 거리를 보여줍니다.

히스토그램이 확장되면 모멘텀 압력이 증가하는 상태로 볼 수 있습니다.

히스토그램이 수축되면 모멘텀 압력이 약해지는 상태로 볼 수 있습니다.

이 스크립트는 MACD 히스토그램 값을 0~100 범위로 정규화합니다.

정규화된 구조는 다섯 개의 주요 기준선을 사용합니다.

• 90: 극단적 상단 모멘텀 압력
• 85: 상단 압력 구간
• 50: 중립 압력 기준선
• 15: 하단 압력 구간
• 10: 극단적 하단 모멘텀 압력

빨간선은 정규화된 MACD 히스토그램을 평활화한 값입니다. 개별 히스토그램 막대보다 넓은 모멘텀 압력 곡선을 읽는 데 도움을 줍니다.

────────────────────
이 스크립트가 보여주는 것
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 정규화된 MACD 히스토그램 막대
• 평활화된 MACD 압력선
• 90 및 85 상단 압력 기준선
• 50 중립 압력 기준선
• 15 및 10 하단 압력 기준선
• 상단 및 하단 구간 배경 강조
• 히스토그램 확장 또는 수축 상태
• 현재 압력 구간
• 모멘텀 heating 또는 cooling 상태
• positive 또는 negative 압력 방향
• 상단 또는 하단 압력 구간 체류 봉 수
• 선택 가능한 상태 패널

이 요소들은 MACD 히스토그램 압력이 확장, 회복, 둔화, 확장 지속, 또는 중립 회귀 중 어디에 가까운지 확인하는 데 도움을 줍니다.

────────────────────
작동 방식
────────────────────

1. 선택한 fast EMA와 slow EMA 길이를 사용해 MACD 라인을 계산합니다.
2. MACD 라인에서 시그널 라인을 계산합니다.
3. MACD에서 시그널을 뺀 값으로 MACD 히스토그램을 계산합니다.
4. 선택한 lookback 구간에서 히스토그램을 정규화합니다.
5. 정규화된 값을 0~100 오실레이터 범위로 변환합니다.
6. 정규화 오실레이터에서 평활화된 빨간 압력선을 계산합니다.
7. 압력선을 90, 85, 50, 15, 10 기준선과 비교합니다.
8. 압력선이 상단 또는 하단 압력 구간에 진입하면 배경이 강조됩니다.
9. 히스토그램 막대는 확장 또는 수축 여부에 따라 다르게 표시됩니다.
10. 상태 패널은 현재 압력, 구간, 모멘텀 상태, 방향성, 구간 체류 시간, 히스토그램 상태를 요약합니다.

이 구조는 MACD 히스토그램 행동을 더 깔끔한 구간 기반 모멘텀 압력 맵으로 변환합니다.

────────────────────
입력값 및 설정
────────────────────

사용자는 다음 항목을 조정할 수 있습니다.

• MACD fast length
• MACD slow length
• MACD signal length
• source price
• normalization lookback
• red line smoothing length
• 0 to 100 clamping
• extreme upper pressure level
• upper pressure level
• neutral pressure level
• lower pressure level
• extreme lower pressure level
• zone background visibility
• histogram visibility
• red line visibility
• status panel visibility
• panel position
• panel text size
• histogram colors
• red line color
• reference level color
• panel background color

기본 기준선은 90 / 85 / 50 / 15 / 10 압력 구간 구조를 중심으로 설계되어 있습니다.

────────────────────
시각 요소
────────────────────

이 스크립트는 다음 시각 요소를 포함합니다.

• 정규화 히스토그램 막대
• 평활화된 빨간 압력선
• 수평 기준선
• 상단 압력 배경
• 하단 압력 배경
• 상태 패널

히스토그램 막대는 정규화된 MACD 히스토그램 값을 보여줍니다.

빨간선은 정규화된 히스토그램을 평활화하여 압력 사이클을 더 쉽게 읽게 해줍니다.

50선은 중립 압력 기준선 역할을 합니다.

85와 90은 상단 모멘텀 압력 구간을 표시합니다.

15와 10은 하단 모멘텀 압력 구간을 표시합니다.

패널은 차트에 방향성 매매 라벨을 추가하지 않고도 현재 상태를 요약합니다.

────────────────────
참고 상태
────────────────────

Extreme Upper Pressure:
평활화된 압력선이 상단 극단 기준선 이상에 있는 상태입니다.

Upper Pressure:
평활화된 압력선이 상단 압력 구간에 있는 상태입니다.

Positive Pressure:
압력선이 중립 기준선 위에 있지만 상단 압력 구간 아래에 있는 상태입니다.

Neutral Pressure:
압력선이 중립 기준선 부근에 있는 상태입니다.

Negative Pressure:
압력선이 중립 기준선 아래에 있지만 하단 압력 구간 위에 있는 상태입니다.

Lower Pressure:
평활화된 압력선이 하단 압력 구간에 있는 상태입니다.

Extreme Lower Pressure:
평활화된 압력선이 하단 극단 기준선 이하에 있는 상태입니다.

Heating:
평활화된 압력선이 상승 중인 상태입니다.

Cooling:
평활화된 압력선이 하락 중인 상태입니다.

Expanding:
정규화된 히스토그램이 직전 봉보다 증가하는 상태입니다.

Contracting:
정규화된 히스토그램이 직전 봉보다 감소하는 상태입니다.

이 상태들은 정보 제공용이며, 매매 지시로 해석해서는 안 됩니다.

────────────────────
사용 방법
────────────────────

이 스크립트는 MACD 히스토그램 압력 및 모멘텀 구간 확인 도구로 사용하는 것이 적절합니다.

일반적인 해석 예시는 다음과 같습니다.

• 빨간선이 85 위에 있으면 MACD 히스토그램 압력이 상단 확장 구간에 있는 상태로 볼 수 있습니다.
• 빨간선이 90 위에 있으면 더 극단적인 상단 압력 상태로 볼 수 있습니다.
• 빨간선이 상단 압력 구간에서 하락하면 모멘텀 압력이 cooling 되는 과정일 수 있습니다.
• 빨간선이 50 부근에 있으면 MACD 히스토그램 압력이 중립에 가까운 상태입니다.
• 빨간선이 15 아래에 있으면 MACD 히스토그램 압력이 하단 확장 구간에 있는 상태로 볼 수 있습니다.
• 빨간선이 10 아래에 있으면 더 극단적인 하단 압력 상태로 볼 수 있습니다.
• 빨간선이 하단 압력 구간에서 상승하면 모멘텀 압력이 heating 되는 과정일 수 있습니다.
• Zone Bars는 압력선이 상단 또는 하단 압력 구간에 얼마나 오래 머물렀는지 확인하는 데 사용할 수 있습니다.
• Histogram expansion은 압력 강화, contraction은 압력 둔화를 보여줄 수 있습니다.

이 스크립트는 가격 행동, 추세 구조, 변동성, 지지와 저항, 상위 시간대 컨텍스트와 함께 검토하는 것이 좋습니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

이 스크립트는 사용 가능한 차트 데이터를 기준으로 MACD, 히스토그램, 정규화 범위, 평활화된 압력선을 계산합니다.

실시간 캔들에서는 MACD 히스토그램과 정규화 값이 봉 마감 전까지 변경될 수 있으므로 값이 변할 수 있습니다.

보다 보수적인 분석을 원한다면 봉 마감 이후 오실레이터를 검토하는 것이 적절합니다.

이 스크립트는 미래 가격 데이터를 사용해 시장 방향을 예측하지 않습니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

진입 또는 청산 추천을 제공하지 않습니다.

높은 압력 수치가 반전을 보장하지 않습니다.

낮은 압력 수치가 반등을 보장하지 않습니다.

강한 추세에서는 MACD 히스토그램 압력이 오랜 시간 확장 구간에 머무를 수 있습니다.

정규화 값은 선택한 lookback period에 따라 달라질 수 있습니다.

종목과 시간대에 따라 적절한 설정값이 달라질 수 있습니다.

이 스크립트를 단독 매매 시스템으로 사용해서는 안 됩니다.

────────────────────
중요 고지
────────────────────

본 게시물은 교육 및 정보 제공 목적의 차트 분석 자료입니다.

투자 자문, 특정 금융상품 거래 권유, 또는 수익 보장을 의미하지 않습니다.

모든 투자 판단과 그 결과에 대한 책임은 이용자 본인에게 있습니다.

## Source Code

````pine
//@version=6
indicator("MACD Pressure Zones | Alpha S+", shorttitle="MACDZone", overlay=false, max_labels_count=50)

// Inputs
groupMacd = "MACD"
fastLen = input.int(90, "Fast Length", minval=1, group=groupMacd)
slowLen = input.int(50, "Slow Length", minval=1, group=groupMacd)
signalLen = input.int(10, "Signal Length", minval=1, group=groupMacd)
src = input.source(close, "Source", group=groupMacd)

groupNorm = "Normalization"
normLen = input.int(100, "Normalization Lookback", minval=20, maxval=500, group=groupNorm)
smoothLen = input.int(5, "Red Line Smooth", minval=1, maxval=50, group=groupNorm)
clampValue = input.bool(true, "Clamp 0-100", group=groupNorm)

groupLevels = "Levels"
strongSellLevel = input.float(90.0, "Strong Sell Level", minval=50.0, maxval=100.0, step=0.5, group=groupLevels)
sellLevel = input.float(85.0, "Sell Level", minval=50.0, maxval=100.0, step=0.5, group=groupLevels)
neutralLevel = input.float(50.0, "Neutral Level", minval=1.0, maxval=99.0, step=0.5, group=groupLevels)
buyLevel = input.float(15.0, "Buy Level", minval=0.0, maxval=50.0, step=0.5, group=groupLevels)
strongBuyLevel = input.float(10.0, "Strong Buy Level", minval=0.0, maxval=50.0, step=0.5, group=groupLevels)

groupDisplay = "Display"
showBackground = input.bool(true, "Show Zone Background", group=groupDisplay)
showHistogram = input.bool(true, "Show Histogram", group=groupDisplay)
showRedLine = input.bool(true, "Show Red Line", group=groupDisplay)
showPanel = input.bool(true, "Show Status Panel", group=groupDisplay)
panelPosition = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDisplay)
panelSize = input.string("Small", "Panel Text Size", options=["Tiny", "Small", "Normal"], group=groupDisplay)

groupStyle = "Style"
histExpandColor = input.color(color.rgb(170, 170, 170), "Histogram Expanding", group=groupStyle)
histContractColor = input.color(color.rgb(100, 100, 100), "Histogram Contracting", group=groupStyle)
lineColor = input.color(color.red, "Red Line Color", group=groupStyle)
levelColor = input.color(color.rgb(100, 160, 100), "Level Line Color", group=groupStyle)
panelBgColor = input.color(color.rgb(25, 25, 30), "Panel Background", group=groupStyle)

// Helpers
f_table_pos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Bottom Right" ? position.bottom_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.top_right

f_text_size(_size) =>
    _size == "Tiny" ? size.tiny :
     _size == "Normal" ? size.normal :
     size.small

f_zone_text(_value, _strongSell, _sell, _neutral, _buy, _strongBuy) =>
    string z = "Neutral"
    if _value >= _strongSell
        z := "Extreme Sell"
    else if _value >= _sell
        z := "Sell"
    else if _value <= _strongBuy
        z := "Extreme Buy"
    else if _value <= _buy
        z := "Buy"
    else if _value > _neutral
        z := "Positive"
    else if _value < _neutral
        z := "Negative"
    else
        z := "Neutral"
    z

f_zone_color(_value, _strongSell, _sell, _neutral, _buy, _strongBuy) =>
    color c = color.new(color.gray, 0)
    if _value >= _strongSell
        c := color.new(color.red, 0)
    else if _value >= _sell
        c := color.new(color.orange, 0)
    else if _value <= _strongBuy
        c := color.new(color.lime, 0)
    else if _value <= _buy
        c := color.new(color.teal, 0)
    else if _value > _neutral
        c := color.new(color.aqua, 0)
    else if _value < _neutral
        c := color.new(color.gray, 0)
    c

// MACD
fastMa = ta.ema(src, fastLen)
slowMa = ta.ema(src, slowLen)
macd = fastMa - slowMa
signal = ta.ema(macd, signalLen)
hist = macd - signal

// Normalize MACD histogram to 0-100
histLow = ta.lowest(hist, normLen)
histHigh = ta.highest(hist, normLen)
histRange = math.max(histHigh - histLow, syminfo.mintick)

rawOsc = (hist - histLow) / histRange * 100.0
osc = clampValue ? math.min(math.max(rawOsc, 0.0), 100.0) : rawOsc
redLine = ta.ema(osc, smoothLen)

// State
isHeating = redLine > redLine[1]
isCooling = redLine < redLine[1]

strongSellZone = redLine >= strongSellLevel
sellZone = redLine >= sellLevel and redLine < strongSellLevel
strongBuyZone = redLine <= strongBuyLevel
buyZone = redLine <= buyLevel and redLine > strongBuyLevel

positivePressure = redLine > neutralLevel
negativePressure = redLine < neutralLevel

histExpanding = osc > osc[1]
histContracting = osc < osc[1]

zoneText = f_zone_text(redLine, strongSellLevel, sellLevel, neutralLevel, buyLevel, strongBuyLevel)
zoneColor = f_zone_color(redLine, strongSellLevel, sellLevel, neutralLevel, buyLevel, strongBuyLevel)

momentumText = isHeating ? "Heating" : isCooling ? "Cooling" : "Flat"
momentumColor = isHeating ? color.new(color.lime, 0) : isCooling ? color.new(color.red, 0) : color.new(color.gray, 0)

biasText = positivePressure ? "Positive" : negativePressure ? "Negative" : "Neutral"
biasColor = positivePressure ? color.new(color.aqua, 0) : negativePressure ? color.new(color.gray, 0) : color.new(color.white, 0)

inUpperZone = redLine >= sellLevel
inLowerZone = redLine <= buyLevel

barsInSellZone = ta.barssince(not inUpperZone)
barsInBuyZone = ta.barssince(not inLowerZone)

sellZoneBars = inUpperZone ? nz(barsInSellZone, 0) + 1 : 0
buyZoneBars = inLowerZone ? nz(barsInBuyZone, 0) + 1 : 0

zoneBarsText = inUpperZone ? str.tostring(sellZoneBars) : inLowerZone ? str.tostring(buyZoneBars) : "0"

// Background zones
bgcolor(showBackground and strongSellZone ? color.new(color.red, 88) : na)
bgcolor(showBackground and sellZone ? color.new(color.red, 94) : na)
bgcolor(showBackground and buyZone ? color.new(color.lime, 94) : na)
bgcolor(showBackground and strongBuyZone ? color.new(color.lime, 88) : na)

// Level lines
hline(strongSellLevel, "90", color=color.new(levelColor, 25), linestyle=hline.style_solid)
hline(sellLevel, "85", color=color.new(levelColor, 45), linestyle=hline.style_solid)
hline(neutralLevel, "50", color=color.new(levelColor, 35), linestyle=hline.style_solid)
hline(buyLevel, "15", color=color.new(levelColor, 45), linestyle=hline.style_solid)
hline(strongBuyLevel, "10", color=color.new(levelColor, 25), linestyle=hline.style_solid)

// Plots
histPlotColor = histExpanding ? color.new(histExpandColor, 10) : histContracting ? color.new(histContractColor, 18) : color.new(histContractColor, 35)

plot(showHistogram ? osc : na, title="Normalized MACD Histogram", style=plot.style_columns, histbase=neutralLevel, color=histPlotColor, linewidth=1)
plot(showRedLine ? redLine : na, title="Smoothed MACD Histogram Pressure", color=lineColor, linewidth=3)

// Status panel
var table panel = table.new(f_table_pos(panelPosition), 2, 6, border_width=1)

if showPanel and barstate.islast
    txtSize = f_text_size(panelSize)

    table.cell(panel, 0, 0, "MACD Pressure", text_color=color.white, bgcolor=color.new(panelBgColor, 0), text_size=txtSize)
    table.cell(panel, 1, 0, str.tostring(redLine, "#.##"), text_color=color.white, bgcolor=color.new(panelBgColor, 0), text_size=txtSize)

    table.cell(panel, 0, 1, "Zone", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(panel, 1, 1, zoneText, text_color=zoneColor, bgcolor=color.new(color.black, 0), text_size=txtSize)

    table.cell(panel, 0, 2, "Momentum", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(panel, 1, 2, momentumText, text_color=momentumColor, bgcolor=color.new(color.black, 0), text_size=txtSize)

    table.cell(panel, 0, 3, "Bias", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(panel, 1, 3, biasText, text_color=biasColor, bgcolor=color.new(color.black, 0), text_size=txtSize)

    table.cell(panel, 0, 4, "Zone Bars", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(panel, 1, 4, zoneBarsText, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)

    table.cell(panel, 0, 5, "Histogram", text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=txtSize)
    table.cell(panel, 1, 5, histExpanding ? "Expanding" : histContracting ? "Contracting" : "Flat", text_color=histExpanding ? color.new(color.lime, 0) : histContracting ? color.new(color.orange, 0) : color.new(color.gray, 0), bgcolor=color.new(color.black, 0), text_size=txtSize)

if not showPanel and barstate.islast
    table.clear(panel, 0, 0, 1, 5)

// Alerts
alertcondition(ta.crossover(redLine, strongBuyLevel), title="MACD Pressure Leaves Extreme Buy Zone", message="MACD pressure line recovered from the extreme buy zone.")
alertcondition(ta.crossunder(redLine, strongSellLevel), title="MACD Pressure Leaves Extreme Sell Zone", message="MACD pressure line cooled from the extreme sell zone.")
alertcondition(ta.crossover(redLine, neutralLevel), title="MACD Pressure Crosses Above Neutral", message="MACD pressure line crossed above the neutral level.")
alertcondition(ta.crossunder(redLine, neutralLevel), title="MACD Pressure Crosses Below Neutral", message="MACD pressure line crossed below the neutral level.")
````
