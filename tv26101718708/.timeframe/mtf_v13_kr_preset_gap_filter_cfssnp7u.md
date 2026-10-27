# MTF  V1.3 KR - Preset Gap Filter

- url: https://www.tradingview.com/script/CFssNp7u/
- type: indicator
- pine_id: PUB;9afaa26cc0c946958f863377fce900fe
- version: 1.0

## Description

MTF Long / Short / Reload Zone Classifier

This indicator classifies market conditions into Long Zone, Short Zone, Caution Zone, and Neutral Zone using a multi-timeframe EMA structure.

Features:
• 4H + 2H + 15m market regime analysis
• Trend expansion and trend exhaustion detection
• Adaptive gap filtering between higher timeframe EMA93 and EMA240
• Preset profiles for BTC/ETH, SOL, and high-volatility altcoins
• Long-only, Short-only, Caution, and Neutral market classification
• Non-repainting higher timeframe calculations using confirmed candles only
• Visual background zones and real-time status dashboard
• Designed for market filtering, trade selection, and regime analysis rather than direct buy/sell signals

Recommended for traders who want to trade with the dominant higher timeframe trend while avoiding late-stage trend exhaustion and low-quality market conditions.

MTF 롱/숏/리로드 구간 분류기

4시간봉(4H), 2시간봉(2H), 15분봉(15m)의 EMA 구조를 활용하여 현재 시장 상태를 롱구간, 숏구간, 주의구간, 중립구간으로 분류하는 멀티 타임프레임 레짐 분석 지표입니다.

주요 기능:

• 4H + 2H + 15m 기반 시장 상태 분석
• 추세 확장(Trend Expansion)과 추세 소모(Trend Exhaustion) 감지
• 상위 타임프레임 EMA93-EMA240 이격도 분석
• BTC/ETH, SOL, 고변동성 알트코인용 적응형 설정 지원
• 롱구간 / 숏구간 / 관망구간 자동 분류
• 확정봉 기반 비리페인팅(Non-Repainting) 구조
• 배경색 및 상태 테이블 시각화 제공
• 직접 매수·매도 신호보다는 시장 상태 분류와 매매 필터링에 최적화

추세 초입과 추세 종료 구간을 구분하고, 확률이 높은 구간만 선별하여 매매하려는 트레이더를 위한 레짐 분석 도구입니다.

## Source Code

````pine
//@version=6
indicator("MTF 롱/숏/리로드 구간 분류기 V1.3 KR - Preset Gap Filter", overlay=true, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 입력
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
mode = input.string("1순위: 4H+2H+15m", "구간 분류 방식", options=["1순위: 4H+2H+15m", "2순위: 2H+15m", "3순위: 3H 단독"])
presetMode = input.string("SOL 중변동", "종목 프리셋", options=["BTC/ETH 안정형", "SOL 중변동", "DOGE/고변동 알트", "직접입력"])

tf4h = input.timeframe("240", "4H 배경 TF")
tf2h = input.timeframe("120", "2H 전환 TF")
tf3h = input.timeframe("180", "3H 단독 TF")

emaFastLen = input.int(14, "현재TF EMA 14")
emaMidLen = input.int(28, "현재TF EMA 28")
emaBaseLen = input.int(93, "현재TF EMA 93")
emaLongLen = input.int(240, "현재TF EMA 240")

htfWhiteLen = input.int(93, "상위TF 흰선 EMA")
htfPurpleLen = input.int(240, "상위TF 보라선 EMA")

slopeLen = input.int(3, "상위TF 기울기 확인 봉수", minval=1)
gapCheckLen = input.int(6, "흰-보라 이격 증가/감소 확인 봉수", minval=1)

manualMinMoveAfterCrossPct = input.float(10.0, "직접입력: 크로스 이후 최소 이동률 %", step=0.5)
manualReloadDevPct = input.float(1.5, "직접입력: 리로드 EMA93 최대 이격 %", step=0.1)
manualMin4hGapPct = input.float(1.5, "직접입력: 4H 최소 Gap%", step=0.1)
manualMin2hGapPct = input.float(1.2, "직접입력: 2H 최소 Gap%", step=0.1)
manualMax4hHealthyGapPct = input.float(6.0, "직접입력: 4H 과이격 기준 Gap%", step=0.1)
manualMax2hHealthyGapPct = input.float(5.0, "직접입력: 2H 과이격 기준 Gap%", step=0.1)

useStrictShortStack = input.bool(true, "숏구간: 현재TF 14<28<93 조건 사용")
useStrictLongStack = input.bool(false, "롱구간: 현재TF 14>28>93 조건 사용")

useGapExpansionFilter = input.bool(true, "롱/숏구간: 흰-보라 이격 증가 필터 사용")
useMoveAfterCrossFilter = input.bool(true, "주의구간: 크로스 이후 이동률 필터 사용")
useReloadNear93 = input.bool(true, "리로드: EMA93 근처 조건 사용")
useFastWeakCaution = input.bool(false, "빠른 약화로 주의 전환 사용")

showCurrentMa = input.bool(true, "현재TF 이평선 표시")
showHtfLines = input.bool(true, "상위TF 흰선/보라선 표시")
showBg = input.bool(true, "구간 배경 표시")
showTable = input.bool(true, "상태 테이블 표시")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 프리셋
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
float minMoveAfterCrossPct = manualMinMoveAfterCrossPct
float reloadDevPct = manualReloadDevPct
float min4hGapPct = manualMin4hGapPct
float min2hGapPct = manualMin2hGapPct
float max4hHealthyGapPct = manualMax4hHealthyGapPct
float max2hHealthyGapPct = manualMax2hHealthyGapPct

if presetMode == "BTC/ETH 안정형"
    minMoveAfterCrossPct := 6.0
    reloadDevPct := 1.0
    min4hGapPct := 0.8
    min2hGapPct := 0.6
    max4hHealthyGapPct := 4.0
    max2hHealthyGapPct := 3.0
else if presetMode == "SOL 중변동"
    minMoveAfterCrossPct := 10.0
    reloadDevPct := 1.5
    min4hGapPct := 1.5
    min2hGapPct := 1.2
    max4hHealthyGapPct := 6.0
    max2hHealthyGapPct := 5.0
else if presetMode == "DOGE/고변동 알트"
    minMoveAfterCrossPct := 14.0
    reloadDevPct := 2.0
    min4hGapPct := 2.0
    min2hGapPct := 1.5
    max4hHealthyGapPct := 10.0
    max2hHealthyGapPct := 8.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 현재 TF 이평선
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema14 = ta.ema(close, emaFastLen)
ema28 = ta.ema(close, emaMidLen)
ema93 = ta.ema(close, emaBaseLen)
ema240 = ta.ema(close, emaLongLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 상위 TF 값 - 직전 확정봉 기준
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
h4Close = request.security(syminfo.tickerid, tf4h, close[1], barmerge.gaps_off, barmerge.lookahead_off)
h4White = request.security(syminfo.tickerid, tf4h, ta.ema(close, htfWhiteLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
h4Purple = request.security(syminfo.tickerid, tf4h, ta.ema(close, htfPurpleLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
h4WhitePast = request.security(syminfo.tickerid, tf4h, ta.ema(close, htfWhiteLen)[1 + slopeLen], barmerge.gaps_off, barmerge.lookahead_off)
h4GapWhitePast = request.security(syminfo.tickerid, tf4h, ta.ema(close, htfWhiteLen)[1 + gapCheckLen], barmerge.gaps_off, barmerge.lookahead_off)
h4GapPurplePast = request.security(syminfo.tickerid, tf4h, ta.ema(close, htfPurpleLen)[1 + gapCheckLen], barmerge.gaps_off, barmerge.lookahead_off)

h2Close = request.security(syminfo.tickerid, tf2h, close[1], barmerge.gaps_off, barmerge.lookahead_off)
h2White = request.security(syminfo.tickerid, tf2h, ta.ema(close, htfWhiteLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
h2Purple = request.security(syminfo.tickerid, tf2h, ta.ema(close, htfPurpleLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
h2WhitePast = request.security(syminfo.tickerid, tf2h, ta.ema(close, htfWhiteLen)[1 + slopeLen], barmerge.gaps_off, barmerge.lookahead_off)
h2GapWhitePast = request.security(syminfo.tickerid, tf2h, ta.ema(close, htfWhiteLen)[1 + gapCheckLen], barmerge.gaps_off, barmerge.lookahead_off)
h2GapPurplePast = request.security(syminfo.tickerid, tf2h, ta.ema(close, htfPurpleLen)[1 + gapCheckLen], barmerge.gaps_off, barmerge.lookahead_off)

h3Close = request.security(syminfo.tickerid, tf3h, close[1], barmerge.gaps_off, barmerge.lookahead_off)
h3White = request.security(syminfo.tickerid, tf3h, ta.ema(close, htfWhiteLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
h3Purple = request.security(syminfo.tickerid, tf3h, ta.ema(close, htfPurpleLen)[1], barmerge.gaps_off, barmerge.lookahead_off)
h3WhitePast = request.security(syminfo.tickerid, tf3h, ta.ema(close, htfWhiteLen)[1 + slopeLen], barmerge.gaps_off, barmerge.lookahead_off)
h3GapWhitePast = request.security(syminfo.tickerid, tf3h, ta.ema(close, htfWhiteLen)[1 + gapCheckLen], barmerge.gaps_off, barmerge.lookahead_off)
h3GapPurplePast = request.security(syminfo.tickerid, tf3h, ta.ema(close, htfPurpleLen)[1 + gapCheckLen], barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 기울기
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
h4WhiteUp = h4White > h4WhitePast
h4WhiteDown = h4White < h4WhitePast

h2WhiteUp = h2White > h2WhitePast
h2WhiteDown = h2White < h2WhitePast

h3WhiteUp = h3White > h3WhitePast
h3WhiteDown = h3White < h3WhitePast

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 흰선-보라선 이격 증가/감소
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
h4GapNow = math.abs(h4White - h4Purple)
h4GapPast = math.abs(h4GapWhitePast - h4GapPurplePast)
h4GapExpanding = h4GapNow > h4GapPast
h4GapContracting = h4GapNow < h4GapPast

h2GapNow = math.abs(h2White - h2Purple)
h2GapPast = math.abs(h2GapWhitePast - h2GapPurplePast)
h2GapExpanding = h2GapNow > h2GapPast
h2GapContracting = h2GapNow < h2GapPast

h3GapNow = math.abs(h3White - h3Purple)
h3GapPast = math.abs(h3GapWhitePast - h3GapPurplePast)
h3GapExpanding = h3GapNow > h3GapPast
h3GapContracting = h3GapNow < h3GapPast

float h4GapPct = 0.0
if h4Purple > 0
    h4GapPct := h4GapNow / h4Purple * 100.0

float h2GapPct = 0.0
if h2Purple > 0
    h2GapPct := h2GapNow / h2Purple * 100.0

float h3GapPct = 0.0
if h3Purple > 0
    h3GapPct := h3GapNow / h3Purple * 100.0

h4GapEnough = h4GapPct >= min4hGapPct
h2GapEnough = h2GapPct >= min2hGapPct

h4GapHealthy = h4GapPct <= max4hHealthyGapPct
h2GapHealthy = h2GapPct <= max2hHealthyGapPct

h4OverGap = h4GapPct > max4hHealthyGapPct
h2OverGap = h2GapPct > max2hHealthyGapPct

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 크로스 이벤트 저장
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
h4Golden = ta.crossover(h4White, h4Purple)
h4Dead = ta.crossunder(h4White, h4Purple)

var int h4CrossDir = 0
var float h4CrossPrice = na

if h4Golden
    h4CrossDir := 1
    h4CrossPrice := h4Close
else if h4Dead
    h4CrossDir := -1
    h4CrossPrice := h4Close

float moveAfterCrossPct = 0.0
if not na(h4CrossPrice) and h4CrossPrice > 0
    if h4CrossDir == 1
        moveAfterCrossPct := (h4Close - h4CrossPrice) / h4CrossPrice * 100.0
    else if h4CrossDir == -1
        moveAfterCrossPct := (h4CrossPrice - h4Close) / h4CrossPrice * 100.0

moveAfterCrossOk = true
if useMoveAfterCrossFilter
    moveAfterCrossOk := moveAfterCrossPct >= minMoveAfterCrossPct

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 현재TF 상태
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
curLongStack = (
     ema14 > ema28
     and ema28 > ema93
)

curShortStack = (
     ema14 < ema28
     and ema28 < ema93
)

curLongOk = close > ema93
if useStrictLongStack
    curLongOk := close > ema93 and curLongStack

curShortOk = close < ema93
if useStrictShortStack
    curShortOk := close < ema93 and curShortStack

float closeToEma93DevPct = 0.0
if ema93 > 0
    closeToEma93DevPct := math.abs(close - ema93) / ema93 * 100.0

reloadNear93Ok = true
if useReloadNear93
    reloadNear93Ok := closeToEma93DevPct <= reloadDevPct

fastWeakLong = (
     ema14 < ema28
     or close < ema28
)

fastWeakShort = (
     ema14 > ema28
     or close > ema28
)

fastWeakCautionLong = false
fastWeakCautionShort = false

if useFastWeakCaution
    fastWeakCautionLong := fastWeakLong
    fastWeakCautionShort := fastWeakShort

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4H / 2H / 3H 상태 정의
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
h4LongBase = (
     h4White > h4Purple
     and h4Close > h4Purple
)

h4ShortBase = (
     h4White < h4Purple
     and h4Close < h4White
)

h2LongBase = (
     h2White > h2Purple
     and h2Close > h2Purple
)

h2ShortBase = (
     h2White < h2Purple
     and h2Close < h2White
)

h3LongBase = (
     h3White > h3Purple
     and h3Close > h3Purple
)

h3ShortBase = (
     h3White < h3Purple
     and h3Close < h3White
)

h4LongExpansion = (
     h4LongBase
     and h4WhiteUp
     and h4GapExpanding
     and h4GapEnough
     and h4GapHealthy
)

h4ShortExpansion = (
     h4ShortBase
     and h4WhiteDown
     and h4GapExpanding
     and h4GapEnough
     and h4GapHealthy
)

h2LongExpansion = (
     h2LongBase
     and h2WhiteUp
     and h2GapExpanding
     and h2GapEnough
     and h2GapHealthy
)

h2ShortExpansion = (
     h2ShortBase
     and h2WhiteDown
     and h2GapExpanding
     and h2GapEnough
     and h2GapHealthy
)

h3LongExpansion = (
     h3LongBase
     and h3WhiteUp
     and h3GapExpanding
)

h3ShortExpansion = (
     h3ShortBase
     and h3WhiteDown
     and h3GapExpanding
)

h4LongExhaustion = (
     h4LongBase
     and moveAfterCrossOk
     and (
         h4GapContracting
         or h4OverGap
     )
)

h4ShortExhaustion = (
     h4ShortBase
     and moveAfterCrossOk
     and (
         h4GapContracting
         or h4OverGap
     )
)

h2LongExhaustion = (
     h2LongBase
     and (
         h2GapContracting
         or h2OverGap
     )
)

h2ShortExhaustion = (
     h2ShortBase
     and (
         h2GapContracting
         or h2OverGap
     )
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 최종 상태
//  2 = 롱구간 / 신규 롱 가능
//  1 = 롱주의 / 방향은 롱이나 신규 롱 보수
//  0 = 완전중립
// -1 = 숏주의 / 방향은 숏이나 신규 숏 보수
// -2 = 숏구간 / 신규 숏 가능
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int regimeState = 0

gapLongOk = true
gapShortOk = true

if useGapExpansionFilter
    gapLongOk := h4GapExpanding and h2GapExpanding and h4GapHealthy and h2GapHealthy
    gapShortOk := h4GapExpanding and h2GapExpanding and h4GapHealthy and h2GapHealthy

if mode == "1순위: 4H+2H+15m"
    if h4LongExpansion and h2LongExpansion and curLongOk and gapLongOk
        regimeState := 2
    else if h4ShortExpansion and h2ShortExpansion and curShortOk and gapShortOk
        regimeState := -2
    else if h4LongExhaustion or h2LongExhaustion or fastWeakCautionLong
        if h4LongBase
            regimeState := 1
        else
            regimeState := 0
    else if h4ShortExhaustion or h2ShortExhaustion or fastWeakCautionShort
        if h4ShortBase
            regimeState := -1
        else
            regimeState := 0
    else if h4LongBase and reloadNear93Ok
        regimeState := 1
    else if h4ShortBase and reloadNear93Ok
        regimeState := -1
    else
        regimeState := 0

if mode == "2순위: 2H+15m"
    if h2LongExpansion and curLongOk
        regimeState := 2
    else if h2ShortExpansion and curShortOk
        regimeState := -2
    else if h2LongExhaustion or fastWeakCautionLong
        if h2LongBase
            regimeState := 1
        else
            regimeState := 0
    else if h2ShortExhaustion or fastWeakCautionShort
        if h2ShortBase
            regimeState := -1
        else
            regimeState := 0
    else
        regimeState := 0

if mode == "3순위: 3H 단독"
    if h3LongExpansion
        regimeState := 2
    else if h3ShortExpansion
        regimeState := -2
    else if h3LongBase and h3GapContracting
        regimeState := 1
    else if h3ShortBase and h3GapContracting
        regimeState := -1
    else
        regimeState := 0

isLongZone = regimeState == 2
isLongCaution = regimeState == 1
isNeutralZone = regimeState == 0
isShortCaution = regimeState == -1
isShortZone = regimeState == -2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 시각화
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showCurrentMa ? ema14 : na, "EMA 14", color=color.yellow)
plot(showCurrentMa ? ema28 : na, "EMA 28", color=color.aqua)
plot(showCurrentMa ? ema93 : na, "EMA 93", color=color.gray, linewidth=2)
plot(showCurrentMa ? ema240 : na, "EMA 240", color=color.red, linewidth=2)

float activeWhite = h4White
float activePurple = h4Purple

if mode == "2순위: 2H+15m"
    activeWhite := h2White
    activePurple := h2Purple

if mode == "3순위: 3H 단독"
    activeWhite := h3White
    activePurple := h3Purple

plot(showHtfLines ? activeWhite : na, "선택 TF 흰선 EMA93", color=color.white, linewidth=2)
plot(showHtfLines ? activePurple : na, "선택 TF 보라선 EMA240", color=color.fuchsia, linewidth=3)

bgColor = color.new(color.gray, 100)

if showBg and isLongZone
    bgColor := color.new(color.green, 86)
else if showBg and isLongCaution
    bgColor := color.new(color.teal, 91)
else if showBg and isShortZone
    bgColor := color.new(color.red, 86)
else if showBg and isShortCaution
    bgColor := color.new(color.orange, 91)
else if showBg and isNeutralZone
    bgColor := color.new(color.gray, 96)

bgcolor(bgColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 테이블
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table infoTable = table.new(position.top_right, 2, 19, border_width=1)

stateText = "완전중립"
stateColor = color.gray

if isLongZone
    stateText := "롱구간/신규롱"
    stateColor := color.lime
else if isLongCaution
    stateText := "롱주의/보수"
    stateColor := color.teal
else if isShortZone
    stateText := "숏구간/신규숏"
    stateColor := color.red
else if isShortCaution
    stateText := "숏주의/보수"
    stateColor := color.orange

if showTable and barstate.islast
    table.cell(infoTable, 0, 0, "항목", text_color=color.white, bgcolor=color.gray)
    table.cell(infoTable, 1, 0, "값", text_color=color.white, bgcolor=color.gray)

    table.cell(infoTable, 0, 1, "선택모드", text_color=color.white)
    table.cell(infoTable, 1, 1, mode, text_color=color.white)

    table.cell(infoTable, 0, 2, "종목프리셋", text_color=color.white)
    table.cell(infoTable, 1, 2, presetMode, text_color=color.white)

    table.cell(infoTable, 0, 3, "최종상태", text_color=color.white)
    table.cell(infoTable, 1, 3, stateText, text_color=stateColor)

    table.cell(infoTable, 0, 4, "4H 롱베이스", text_color=color.white)
    table.cell(infoTable, 1, 4, h4LongBase ? "ON" : "OFF", text_color=h4LongBase ? color.lime : color.gray)

    table.cell(infoTable, 0, 5, "4H 숏베이스", text_color=color.white)
    table.cell(infoTable, 1, 5, h4ShortBase ? "ON" : "OFF", text_color=h4ShortBase ? color.red : color.gray)

    table.cell(infoTable, 0, 6, "4H 이격", text_color=color.white)
    table.cell(infoTable, 1, 6, h4GapExpanding ? "확장" : "둔화", text_color=h4GapExpanding ? color.lime : color.orange)

    table.cell(infoTable, 0, 7, "2H 이격", text_color=color.white)
    table.cell(infoTable, 1, 7, h2GapExpanding ? "확장" : "둔화", text_color=h2GapExpanding ? color.lime : color.orange)

    table.cell(infoTable, 0, 8, "4H Gap%", text_color=color.white)
    table.cell(infoTable, 1, 8, str.tostring(h4GapPct, "#.##") + "%", text_color=h4OverGap ? color.orange : h4GapEnough ? color.lime : color.gray)

    table.cell(infoTable, 0, 9, "2H Gap%", text_color=color.white)
    table.cell(infoTable, 1, 9, str.tostring(h2GapPct, "#.##") + "%", text_color=h2OverGap ? color.orange : h2GapEnough ? color.lime : color.gray)

    table.cell(infoTable, 0, 10, "4H 과이격", text_color=color.white)
    table.cell(infoTable, 1, 10, h4OverGap ? "ON" : "OFF", text_color=h4OverGap ? color.orange : color.gray)

    table.cell(infoTable, 0, 11, "2H 과이격", text_color=color.white)
    table.cell(infoTable, 1, 11, h2OverGap ? "ON" : "OFF", text_color=h2OverGap ? color.orange : color.gray)

    table.cell(infoTable, 0, 12, "4H 롱소모", text_color=color.white)
    table.cell(infoTable, 1, 12, h4LongExhaustion ? "ON" : "OFF", text_color=h4LongExhaustion ? color.orange : color.gray)

    table.cell(infoTable, 0, 13, "4H 숏소모", text_color=color.white)
    table.cell(infoTable, 1, 13, h4ShortExhaustion ? "ON" : "OFF", text_color=h4ShortExhaustion ? color.orange : color.gray)

    table.cell(infoTable, 0, 14, "15m 실행상태", text_color=color.white)
    table.cell(infoTable, 1, 14, curLongOk ? "롱가능" : curShortOk ? "숏가능" : "중립", text_color=curLongOk ? color.lime : curShortOk ? color.red : color.gray)

    table.cell(infoTable, 0, 15, "EMA93 이격", text_color=color.white)
    table.cell(infoTable, 1, 15, str.tostring(closeToEma93DevPct, "#.##") + "%", text_color=reloadNear93Ok ? color.lime : color.gray)

    table.cell(infoTable, 0, 16, "크로스후 이동률", text_color=color.white)
    table.cell(infoTable, 1, 16, str.tostring(moveAfterCrossPct, "#.##") + "%", text_color=moveAfterCrossOk ? color.lime : color.gray)

    table.cell(infoTable, 0, 17, "빠른 약화", text_color=color.white)
    table.cell(infoTable, 1, 17, fastWeakCautionLong ? "롱약화" : fastWeakCautionShort ? "숏약화" : "OFF", text_color=fastWeakCautionLong or fastWeakCautionShort ? color.orange : color.gray)

    table.cell(infoTable, 0, 18, "매매해석", text_color=color.white)
    table.cell(infoTable, 1, 18, isLongZone ? "신규롱 가능" : isShortZone ? "신규숏 가능" : isLongCaution ? "롱 보수/추격금지" : isShortCaution ? "숏 보수/추격금지" : "관망", text_color=stateColor)
````
