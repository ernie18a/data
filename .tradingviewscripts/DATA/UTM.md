<!-- tradingview-pine-id: PUB;b384ca73959940f3a3b6b9f596911a9b -->
<!-- tradingviewscripts-format: 1 -->
# UTM 共感覺 식스센스 차트

Source: https://www.tradingview.com/script/rhMKpuxi-UTM-Synesthesia-ESP-4-Market-Phases-Indicator/

## Description

Description:
Overview
The "UTM Synesthesia ESP" is a highly intuitive trend-following indicator designed to identify the current market phase by utilizing two core dynamic base lines: the Pami (Shifted Mid-Channel) and the Nomi (Volatility-based Trailing Stop). By evaluating the price action relative to these two levels, the indicator divides the market into four distinct phases, projecting them via clear background colors.

Key Components

Pami (Mid-Channel, Blue Line): A price channel calculated based on historical closing prices, shifted horizontally. It serves as the primary gauge for the macro-trend direction.

Nomi (Volatility Trailing Line, Yellow Line): A responsive trailing stop level calculated using a combination of the Average True Range (ATR) and Weighted Moving Average (WMA). It acts as a dynamic support/resistance for short-term momentum.

4 Market Phases (Background Colors)
The indicator paints the chart background to help traders instantly recognize the current market condition:

🟢 Strong Bull (Bright Green): Price > Pami AND Price > Nomi. Indicates strong upward momentum. Ideal for trend-following long positions.

⚫ Weak Bull / Pullback (Dark Green): Price > Pami BUT Price < Nomi. The macro trend remains bullish, but the market is experiencing short-term consolidation or a pullback.

🔴 Strong Bear (Bright Red): Price < Pami AND Price < Nomi. Indicates strong downward momentum. Ideal for trend-following short positions.

⚫ Weak Bear / Pullback (Dark Red): Price < Pami BUT Price > Nomi. The macro trend remains bearish, but a short-term bounce or sideways consolidation is occurring.

How to Use

Trend Riding: Focus on capitalizing on the Bright Green and Bright Red zones where both macro and micro trends align.

Pullback Entries: Use the Dark Green and Dark Red zones to identify potential "buy the dip" or "sell the rally" opportunities, or to take profits and manage risk during consolidations.

Customizability: All inputs—including channel lookback, shift periods, and volatility multipliers—are fully customizable to suit your trading style, asset class, and timeframe.

---

## Source Code

````pine
//@version=6
// 이 지표는 '파미'와 '노미'를 기준으로 시장을 4개의 국면으로 나누어 배경색으로 표현합니다.
indicator(title='UTM 共感覺 식스센스 차트', shorttitle='UTM Synesthesia ESP', overlay=true)

// =========================================================================
// 입력 설정 (Inputs)
// =========================================================================

// 1. 채널 설정
grp_channel = "1. 채널 설정"
lookback = input.int(title='채널 기간', defval=34, minval=1, group=grp_channel)
shift = input.int(title='채널 Shift', defval=26, minval=0, group=grp_channel)

// 2. 노미 설정
grp_tts = "2. 노미 설정"
tts_Length = input.int(21, title="노미 기간", group=grp_tts)
tts_Multiplier = input.float(3.0, title="노미 승수", group=grp_tts)

// 3. 배경색 설정
grp_colors = "3. 배경색 설정"
strongBullColor = input.color(color.new(color.green, 80), title="🟢 강세 (가격>파미, 가격>노미)", group=grp_colors)
weakBullColor = input.color(color.new(#004D00, 80), title="⚫ 약한 강세/조정 (가격>파미, 가격<노미)", group=grp_colors) // 검정에 가까운 녹색
strongBearColor = input.color(color.new(color.red, 80), title="🔴 약세 (가격<파미, 가격<노미)", group=grp_colors)
weakBearColor = input.color(color.new(#330000, 80), title="⚫ 약한 약세/조정 (가격<파미, 가격>노미)", group=grp_colors) // 검정에 가까운 빨간색


// =========================================================================
// 계산 (Calculations)
// =========================================================================

// 1. 채널 및 파미 계산
upper = ta.highest(close, lookback)[shift]
lower = ta.lowest(close, lookback)[shift]
midchannel = (upper + lower) / 2 // '파미'

// 2. 노미 라인 계산
avgTR_tts = ta.wma(ta.atr(1), tts_Length)
highestC_tts = ta.highest(close, tts_Length)
lowestC_tts = ta.lowest(close, tts_Length)
hiLimit_tts = highestC_tts[1] - avgTR_tts[1] * tts_Multiplier
loLimit_tts = lowestC_tts[1] + avgTR_tts[1] * tts_Multiplier
var float tts_line = 0.0
tts_line := close > hiLimit_tts and close > loLimit_tts ? hiLimit_tts : close < loLimit_tts and close < hiLimit_tts ? loLimit_tts : nz(tts_line[1], close)

// 3. 4분할 배경색 결정 로직
var color bgColor = na
if close > midchannel and close > tts_line
    bgColor := strongBullColor // 강세 조건
else if close > midchannel and close < tts_line
    bgColor := weakBullColor // 강세 중 조정 조건
else if close < midchannel and close < tts_line
    bgColor := strongBearColor // 약세 조건
else if close < midchannel and close > tts_line
    bgColor := weakBearColor // 약세 중 조정 조건

// =========================================================================
// 차트 출력 (Plots)
// =========================================================================

// 1. 배경색 적용
bgcolor(bgColor, title="4분할 배경색")

// 2. 지표 라인 플롯
plot(upper, '상단채널', linewidth=2, color=color.new(color.aqua, 0))
plot(lower, '하단채널', linewidth=2, color=color.new(color.fuchsia, 0))
plot(midchannel, '파미', linewidth=1, color=color.new(#0000FF, 0))
plot(tts_line, '노미', linewidth=2, color=color.new(color.yellow, 0))
````
