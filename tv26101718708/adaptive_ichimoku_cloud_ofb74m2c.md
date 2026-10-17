# Adaptive Ichimoku Cloud

- url: https://www.tradingview.com/script/OFB74M2c-Adaptive-Ichimoku-Cloud/
- type: indicator
- pine_id: PUB;72806f57628d45eea1fee9ba77411940
- version: 1.0

## Description

Adaptive Ichimoku Cloud

Adaptive Ichimoku Cloud is an Ichimoku-based chart study designed to visualize cloud structure, cloud direction, cloud transitions, and price location relative to the cloud.

The script keeps the core Ichimoku calculation structure while adding optional reference markers and a compact status table for easier chart review.

It does not provide buy or sell recommendations. The purpose of this script is to help users study Ichimoku cloud behavior and understand how price interacts with the cloud environment.

────────────────────
Core Concept
────────────────────

Ichimoku analysis is built around the relationship between several midpoint-based lines.

This script uses the standard Ichimoku components:

• Tenkan
• Kijun
• Senkou Span A
• Senkou Span B
• Cloud displacement

Senkou Span A is calculated from the midpoint of Tenkan and Kijun.
Senkou Span B is calculated from a longer high-low midpoint range.

The area between Senkou Span A and Senkou Span B forms the cloud.

When Senkou Span A is above Senkou Span B, the cloud is treated as bullish.
When Senkou Span A is below Senkou Span B, the cloud is treated as bearish.

────────────────────
What This Script Shows
────────────────────

The script can display:

• Ichimoku cloud
• Senkou Span A and Senkou Span B borders
• Optional Tenkan and Kijun lines
• Bullish and bearish cloud twist markers
• Price break above / below cloud reference markers
• Tenkan / Kijun cross reference markers
• A compact status table showing cloud state, price location, and active parameters

These elements are intended to make the current cloud structure easier to read.

────────────────────
How It Works
────────────────────

1. The script calculates Tenkan using the midpoint of the highest high and lowest low over the selected Tenkan length.
2. It calculates Kijun using the same midpoint method over the selected Kijun length.
3. It calculates Senkou Span A as the midpoint between Tenkan and Kijun.
4. It calculates Senkou Span B using a longer high-low midpoint range.
5. It plots Senkou Span A and Senkou Span B forward using the selected displacement.
6. It fills the area between both spans to create the cloud.
7. It optionally marks cloud twists, price/cloud events, and Tenkan/Kijun crosses.

────────────────────
Adaptive Parameters
────────────────────

The script includes an optional adaptive intraday parameter mode.

When adaptive mode is enabled, shorter intraday charts use faster cloud settings while higher timeframes use the standard Ichimoku structure.

The standard manual setting remains available:

• Tenkan: 9
• Kijun: 26
• Senkou Span B: 52
• Displacement: 26

Users can disable adaptive mode and manually adjust all core parameters.

────────────────────
Reference Markers
────────────────────

The script includes optional reference markers.

Cloud Twist:
Shows when Senkou Span A crosses Senkou Span B.

Price / Cloud Events:
Shows when price crosses above or below the current cloud area.

Tenkan / Kijun Cross:
Shows when Tenkan crosses above or below Kijun.

These markers are not trading signals. They are visual reference points for studying cloud transitions and price interaction with the cloud.

────────────────────
How To Use
────────────────────

Use the cloud to observe the broader chart environment.

General interpretation examples:

• Price above the cloud may indicate stronger upward structure.
• Price below the cloud may indicate weaker downward structure.
• Price inside the cloud may indicate a more neutral or transitional area.
• A cloud twist can show a change in future cloud direction.
• Tenkan / Kijun crosses can be used as additional reference points when studying momentum shifts.

This script should be used with independent analysis, risk management, and a defined trading plan.

────────────────────
Confirmation And Repainting Notes
────────────────────

The cloud is plotted with displacement, which is part of the traditional Ichimoku structure.

Senkou Span A and Senkou Span B are projected forward by the selected displacement value.

Cloud twist markers are also displayed with the same displacement so they visually align with the projected cloud area.

Price/cloud reference markers and Tenkan/Kijun cross markers are based on current bar conditions.

Users should understand that projected cloud values are visual structural references and should not be interpreted as future price prediction.

────────────────────
Limitations
────────────────────

This script does not predict future price movement.

It does not provide buy or sell recommendations.

It does not guarantee that price will continue in the direction of the cloud.

It does not replace independent analysis or risk management.

The cloud may be less useful in noisy, sideways, or low-volatility conditions.

────────────────────
Disclaimer
────────────────────

This publication is for educational and informational chart analysis only.

It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

All trading and investment decisions are the responsibility of the user.

━━━━━━━━━━━━━━━━━━━━

Adaptive Ichimoku Cloud

Adaptive Ichimoku Cloud는 일목균형표 기반의 차트 분석 보조지표로, 구름 구조, 구름 방향, 구름 전환, 그리고 가격이 구름과 어떤 위치 관계에 있는지를 시각적으로 확인하기 위해 설계되었습니다.

이 스크립트는 일목균형표의 핵심 계산 구조를 유지하면서, 차트 복기를 돕기 위한 참고 마커와 간단한 상태 테이블을 추가합니다.

이 지표는 매수 또는 매도 추천을 제공하지 않습니다.
목적은 사용자가 일목 구름 구조와 가격의 상호작용을 더 쉽게 관찰할 수 있도록 돕는 것입니다.

────────────────────
핵심 개념
────────────────────

일목균형표는 여러 개의 고저점 중간값 기반 선들의 관계를 바탕으로 시장 구조를 해석합니다.

이 스크립트는 다음 일목 구성 요소를 사용합니다.

• 전환선
• 기준선
• 선행스팬 A
• 선행스팬 B
• 구름 표시 이동값

선행스팬 A는 전환선과 기준선의 중간값으로 계산됩니다.
선행스팬 B는 더 긴 기간의 고점과 저점 중간값으로 계산됩니다.

선행스팬 A와 선행스팬 B 사이의 영역이 구름입니다.

선행스팬 A가 선행스팬 B 위에 있으면 상승 구름으로 해석합니다.
선행스팬 A가 선행스팬 B 아래에 있으면 하락 구름으로 해석합니다.

────────────────────
표시 요소
────────────────────

이 스크립트는 다음 요소를 표시할 수 있습니다.

• 일목 구름
• 선행스팬 A / 선행스팬 B 테두리
• 선택 가능한 전환선 / 기준선
• 상승 및 하락 구름 전환 마커
• 가격의 구름 상단 돌파 / 하단 이탈 참고 마커
• 전환선 / 기준선 교차 참고 마커
• 구름 상태, 가격 위치, 현재 파라미터를 보여주는 상태 테이블

이 요소들은 현재 구름 구조를 더 쉽게 읽기 위한 시각적 참고 자료입니다.

────────────────────
작동 방식
────────────────────

1. 선택된 전환선 기간 동안의 최고가와 최저가 중간값으로 전환선을 계산합니다.
2. 선택된 기준선 기간 동안의 최고가와 최저가 중간값으로 기준선을 계산합니다.
3. 전환선과 기준선의 중간값으로 선행스팬 A를 계산합니다.
4. 더 긴 기간의 최고가와 최저가 중간값으로 선행스팬 B를 계산합니다.
5. 선택된 이동값만큼 선행스팬 A와 선행스팬 B를 앞으로 표시합니다.
6. 두 선 사이를 채워 구름을 형성합니다.
7. 선택에 따라 구름 전환, 가격/구름 이벤트, 전환선/기준선 교차를 표시합니다.

────────────────────
Adaptive 파라미터
────────────────────

이 스크립트는 선택 가능한 분봉 대응 파라미터 기능을 제공합니다.

Adaptive 모드를 켜면 짧은 분봉 차트에서는 더 빠른 구름 설정을 사용하고, 높은 시간봉에서는 정석 일목 구조에 가까운 설정을 사용합니다.

기본 수동 설정은 다음과 같습니다.

• 전환선: 9
• 기준선: 26
• 선행스팬 B: 52
• 구름 이동값: 26

사용자는 Adaptive 모드를 끄고 모든 핵심 파라미터를 직접 조정할 수 있습니다.

────────────────────
참고 마커
────────────────────

이 스크립트에는 선택 가능한 참고 마커가 포함되어 있습니다.

구름 전환:
선행스팬 A가 선행스팬 B를 상향 또는 하향 교차할 때 표시합니다.

가격 / 구름 이벤트:
가격이 현재 구름 영역의 위로 돌파하거나 아래로 이탈할 때 표시합니다.

전환선 / 기준선 교차:
전환선이 기준선을 상향 또는 하향 교차할 때 표시합니다.

이 마커들은 매매 신호가 아닙니다.
구름 전환과 가격의 구름 상호작용을 관찰하기 위한 시각적 참고 지점입니다.

────────────────────
사용 방법
────────────────────

구름은 전체적인 차트 환경을 확인하는 데 사용할 수 있습니다.

일반적인 해석 예시는 다음과 같습니다.

• 가격이 구름 위에 있으면 상대적으로 강한 상승 구조로 볼 수 있습니다.
• 가격이 구름 아래에 있으면 상대적으로 약한 하락 구조로 볼 수 있습니다.
• 가격이 구름 안에 있으면 중립 또는 전환 구간으로 볼 수 있습니다.
• 구름 전환은 미래 구름 방향의 변화를 관찰하는 참고 지점이 될 수 있습니다.
• 전환선 / 기준선 교차는 모멘텀 변화 복기 시 보조 참고 요소로 사용할 수 있습니다.

이 스크립트는 독립적인 분석, 리스크 관리, 본인의 매매 계획과 함께 참고해야 합니다.

────────────────────
확인봉 및 리페인트 안내
────────────────────

구름은 전통적인 일목균형표 구조에 따라 이동값을 적용해 표시됩니다.

선행스팬 A와 선행스팬 B는 선택한 이동값만큼 앞으로 표시됩니다.

구름 전환 마커도 구름 영역과 시각적으로 맞도록 같은 이동값을 적용해 표시됩니다.

가격/구름 참고 마커와 전환선/기준선 교차 마커는 현재 봉 조건을 기준으로 표시됩니다.

사용자는 앞으로 표시되는 구름 값이 시각적 구조 참고용이며, 미래 가격을 예측하는 값이 아니라는 점을 이해해야 합니다.

────────────────────
한계
────────────────────

이 스크립트는 미래 가격 움직임을 예측하지 않습니다.

매수 또는 매도 추천을 제공하지 않습니다.

가격이 구름 방향대로 계속 움직인다는 것을 보장하지 않습니다.

독립적인 분석과 리스크 관리를 대체하지 않습니다.

노이즈가 많은 횡보장, 저변동성 구간에서는 구름 해석의 유용성이 낮아질 수 있습니다.

────────────────────
중요 고지
────────────────────

본 게시물은 교육 및 정보 제공 목적의 차트 분석 자료입니다.

투자 자문, 매수·매도 추천, 특정 금융상품 거래 권유를 의미하지 않습니다.

모든 투자 판단과 그 결과에 대한 책임은 이용자 본인에게 있습니다.

## Source Code

````pine
//@version=6
indicator("Adaptive Ichimoku Cloud", overlay=true, max_lines_count=50, max_labels_count=100, max_bars_back=5000)

// Adaptive Ichimoku Cloud
// This script visualizes Ichimoku cloud structure using Tenkan, Kijun,
// Senkou Span A, Senkou Span B, and a configurable cloud displacement.
// It is intended for educational chart analysis and visual study of trend,
// cloud support/resistance, cloud transitions, and price location relative to the cloud.

//────────────────────────────────────────────────────────────────────
// Groups
//────────────────────────────────────────────────────────────────────
groupPreset = "Preset"
groupCore = "Core Settings"
groupVisual = "Visual Settings"
groupSignals = "Reference Markers"
groupTable = "Status Table"

//────────────────────────────────────────────────────────────────────
// Preset / Auto timeframe settings
//────────────────────────────────────────────────────────────────────
useAutoTimeframe = input.bool(true, "Use adaptive intraday parameters", group=groupPreset)

manualTenkanLength = input.int(9, "Tenkan Length", minval=1, maxval=200, group=groupCore)
manualKijunLength = input.int(26, "Kijun Length", minval=1, maxval=300, group=groupCore)
manualSenkouBLength = input.int(52, "Senkou B Length", minval=1, maxval=500, group=groupCore)
manualDisplacement = input.int(26, "Cloud Displacement", minval=1, maxval=200, group=groupCore)

tfMinutes = timeframe.in_seconds(timeframe.period) / 60.0

autoTenkanLength =
     tfMinutes <= 3  ? 6 :
     tfMinutes <= 5  ? 7 :
     tfMinutes <= 10 ? 9 :
     9

autoKijunLength =
     tfMinutes <= 3  ? 18 :
     tfMinutes <= 5  ? 22 :
     tfMinutes <= 10 ? 26 :
     26

autoSenkouBLength =
     tfMinutes <= 3  ? 36 :
     tfMinutes <= 5  ? 44 :
     tfMinutes <= 10 ? 52 :
     52

autoDisplacement =
     tfMinutes <= 3  ? 18 :
     tfMinutes <= 5  ? 22 :
     tfMinutes <= 10 ? 26 :
     26

tenkanLength = useAutoTimeframe ? autoTenkanLength : manualTenkanLength
kijunLength = useAutoTimeframe ? autoKijunLength : manualKijunLength
senkouBLength = useAutoTimeframe ? autoSenkouBLength : manualSenkouBLength
displacement = useAutoTimeframe ? autoDisplacement : manualDisplacement

//────────────────────────────────────────────────────────────────────
// Visual settings
//────────────────────────────────────────────────────────────────────
showCloud = input.bool(true, "Show cloud", group=groupVisual)
showCloudBorders = input.bool(true, "Show cloud borders", group=groupVisual)
showTenkanKijun = input.bool(false, "Show Tenkan and Kijun", group=groupVisual)
cloudTransparency = input.int(85, "Cloud Transparency", minval=50, maxval=100, group=groupVisual)
borderTransparency = input.int(35, "Border Transparency", minval=0, maxval=100, group=groupVisual)
borderWidth = input.int(1, "Border Width", minval=1, maxval=5, group=groupVisual)

bullCloudColor = input.color(color.rgb(0, 150, 136), "Bullish Cloud Color", group=groupVisual)
bearCloudColor = input.color(color.rgb(244, 67, 54), "Bearish Cloud Color", group=groupVisual)
tenkanColor = input.color(color.rgb(33, 150, 243), "Tenkan Color", group=groupVisual)
kijunColor = input.color(color.rgb(255, 193, 7), "Kijun Color", group=groupVisual)

//────────────────────────────────────────────────────────────────────
// Reference marker settings
//────────────────────────────────────────────────────────────────────
showCloudTwist = input.bool(true, "Show cloud twist markers", group=groupSignals)
showPriceCloudEvents = input.bool(false, "Show price / cloud reference markers", group=groupSignals)
showTkCrossMarkers = input.bool(false, "Show Tenkan / Kijun cross markers", group=groupSignals)

//────────────────────────────────────────────────────────────────────
// Status table settings
//────────────────────────────────────────────────────────────────────
showStatusTable = input.bool(true, "Show status table", group=groupTable)
tablePositionInput = input.string("Top Left", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=groupTable)

tablePosition =
     tablePositionInput == "Top Right" ? position.top_right :
     tablePositionInput == "Bottom Left" ? position.bottom_left :
     tablePositionInput == "Bottom Right" ? position.bottom_right :
     position.top_left

//────────────────────────────────────────────────────────────────────
// Ichimoku calculation
//────────────────────────────────────────────────────────────────────
f_midpoint(int length) =>
    (ta.highest(high, length) + ta.lowest(low, length)) / 2.0

tenkan = f_midpoint(tenkanLength)
kijun = f_midpoint(kijunLength)
senkouA = (tenkan + kijun) / 2.0
senkouB = f_midpoint(senkouBLength)

cloudTop = math.max(senkouA, senkouB)
cloudBottom = math.min(senkouA, senkouB)

bullCloud = senkouA > senkouB
bearCloud = senkouA < senkouB

cloudFillColor =
     bullCloud ? color.new(bullCloudColor, cloudTransparency) :
     bearCloud ? color.new(bearCloudColor, cloudTransparency) :
     color.new(color.gray, cloudTransparency)

spanAColor =
     bullCloud ? color.new(bullCloudColor, showCloudBorders ? borderTransparency : 100) :
     color.new(color.rgb(0, 188, 212), showCloudBorders ? borderTransparency : 100)

spanBColor =
     bearCloud ? color.new(bearCloudColor, showCloudBorders ? borderTransparency : 100) :
     color.new(color.rgb(255, 193, 7), showCloudBorders ? borderTransparency : 100)

//────────────────────────────────────────────────────────────────────
// Plots
//────────────────────────────────────────────────────────────────────
plot(showTenkanKijun ? tenkan : na, "Tenkan", color=tenkanColor, linewidth=1)
plot(showTenkanKijun ? kijun : na, "Kijun", color=kijunColor, linewidth=1)

spanAPlot = plot(showCloud ? senkouA : na, "Senkou Span A", color=spanAColor, linewidth=borderWidth, offset=displacement)
spanBPlot = plot(showCloud ? senkouB : na, "Senkou Span B", color=spanBColor, linewidth=borderWidth, offset=displacement)

fill(spanAPlot, spanBPlot, color=showCloud ? cloudFillColor : color.new(color.black, 100), title="Ichimoku Cloud")

//────────────────────────────────────────────────────────────────────
// Reference conditions
//────────────────────────────────────────────────────────────────────
bullTwist = ta.crossover(senkouA, senkouB)
bearTwist = ta.crossunder(senkouA, senkouB)

priceAboveCloud = close > cloudTop
priceBelowCloud = close < cloudBottom
priceInsideCloud = close <= cloudTop and close >= cloudBottom

priceBreaksAboveCloud = ta.crossover(close, cloudTop)
priceDropsBelowCloud = ta.crossunder(close, cloudBottom)

tenkanCrossUp = ta.crossover(tenkan, kijun)
tenkanCrossDown = ta.crossunder(tenkan, kijun)

//────────────────────────────────────────────────────────────────────
// Reference markers
//────────────────────────────────────────────────────────────────────
plotshape(showCloudTwist and bullTwist ? senkouA : na, title="Bullish Cloud Twist", style=shape.circle, location=location.absolute, color=color.new(bullCloudColor, 0), size=size.tiny, offset=displacement, text="Twist")
plotshape(showCloudTwist and bearTwist ? senkouA : na, title="Bearish Cloud Twist", style=shape.circle, location=location.absolute, color=color.new(bearCloudColor, 0), size=size.tiny, offset=displacement, text="Twist")

plotshape(showPriceCloudEvents and priceBreaksAboveCloud, title="Price Breaks Above Cloud", style=shape.triangleup, location=location.belowbar, color=color.new(bullCloudColor, 0), size=size.tiny, text="Cloud ↑")
plotshape(showPriceCloudEvents and priceDropsBelowCloud, title="Price Drops Below Cloud", style=shape.triangledown, location=location.abovebar, color=color.new(bearCloudColor, 0), size=size.tiny, text="Cloud ↓")

plotshape(showTkCrossMarkers and tenkanCrossUp, title="Tenkan Crosses Above Kijun", style=shape.triangleup, location=location.belowbar, color=color.new(tenkanColor, 0), size=size.tiny, text="TK ↑")
plotshape(showTkCrossMarkers and tenkanCrossDown, title="Tenkan Crosses Below Kijun", style=shape.triangledown, location=location.abovebar, color=color.new(kijunColor, 0), size=size.tiny, text="TK ↓")

//────────────────────────────────────────────────────────────────────
// Status table
//────────────────────────────────────────────────────────────────────
var table statusTable = table.new(tablePosition, 2, 6, bgcolor=color.new(color.black, 30), border_width=1, border_color=color.new(color.gray, 70))

if barstate.islast and showStatusTable
    modeText = useAutoTimeframe ? "Adaptive" : "Manual"

    cloudStateText =
         bullCloud ? "Bullish" :
         bearCloud ? "Bearish" :
         "Flat"

    priceLocationText =
         priceAboveCloud ? "Above Cloud" :
         priceBelowCloud ? "Below Cloud" :
         priceInsideCloud ? "Inside Cloud" :
         "Neutral"

    tkStateText =
         tenkan > kijun ? "Tenkan > Kijun" :
         tenkan < kijun ? "Tenkan < Kijun" :
         "Tenkan = Kijun"

    cloudStateColor =
         bullCloud ? color.new(bullCloudColor, 0) :
         bearCloud ? color.new(bearCloudColor, 0) :
         color.gray

    priceLocationColor =
         priceAboveCloud ? color.new(bullCloudColor, 0) :
         priceBelowCloud ? color.new(bearCloudColor, 0) :
         color.new(color.orange, 0)

    table.cell(statusTable, 0, 0, "Ichimoku Cloud", text_color=color.white, text_size=size.small)
    table.cell(statusTable, 1, 0, modeText, text_color=useAutoTimeframe ? color.lime : color.orange, text_size=size.small)

    table.cell(statusTable, 0, 1, "TF", text_color=color.gray, text_size=size.tiny)
    table.cell(statusTable, 1, 1, str.tostring(tfMinutes, "#") + "m", text_color=color.white, text_size=size.tiny)

    table.cell(statusTable, 0, 2, "T / K", text_color=color.gray, text_size=size.tiny)
    table.cell(statusTable, 1, 2, str.tostring(tenkanLength) + " / " + str.tostring(kijunLength), text_color=color.white, text_size=size.tiny)

    table.cell(statusTable, 0, 3, "SB / Disp", text_color=color.gray, text_size=size.tiny)
    table.cell(statusTable, 1, 3, str.tostring(senkouBLength) + " / " + str.tostring(displacement), text_color=color.white, text_size=size.tiny)

    table.cell(statusTable, 0, 4, "Cloud", text_color=color.gray, text_size=size.tiny)
    table.cell(statusTable, 1, 4, cloudStateText, text_color=cloudStateColor, text_size=size.tiny)

    table.cell(statusTable, 0, 5, "Price", text_color=color.gray, text_size=size.tiny)
    table.cell(statusTable, 1, 5, priceLocationText + " / " + tkStateText, text_color=priceLocationColor, text_size=size.tiny)

//────────────────────────────────────────────────────────────────────
// Alerts
//────────────────────────────────────────────────────────────────────
alertcondition(showCloudTwist and bullTwist, "Bullish Cloud Twist", "Senkou Span A crossed above Senkou Span B.")
alertcondition(showCloudTwist and bearTwist, "Bearish Cloud Twist", "Senkou Span A crossed below Senkou Span B.")
alertcondition(showPriceCloudEvents and priceBreaksAboveCloud, "Price Breaks Above Cloud", "Price crossed above the cloud area.")
alertcondition(showPriceCloudEvents and priceDropsBelowCloud, "Price Drops Below Cloud", "Price crossed below the cloud area.")
alertcondition(showTkCrossMarkers and tenkanCrossUp, "Tenkan Crosses Above Kijun", "Tenkan crossed above Kijun.")
alertcondition(showTkCrossMarkers and tenkanCrossDown, "Tenkan Crosses Below Kijun", "Tenkan crossed below Kijun.")
````
