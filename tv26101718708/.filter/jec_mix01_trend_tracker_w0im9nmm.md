# JEC Mix01 + Trend Tracker

- url: https://www.tradingview.com/script/W0iM9nmM/
- type: indicator
- pine_id: PUB;92f7f1c52f9140dba16bd1dbe3eb1459
- version: 1.0

## Description

// ══════════════════════════════════════════════
// 이 스크립트는 두 가지 독립적인 분석 모듈을 
// 하나의 인디케이터로 통합한 복합 도구입니다.
// 각 모듈은 서로 다른 시간축 데이터를 참조하며
// 최종 시각화 및 알람 출력에서 결합됩니다.
// ══════════════════════════════════════════════

// ── 모듈 A ──────────────────────────────────
// 두 종류의 이동평균을 사용해 단기 방향성을 판단합니다.
// 빠른 선과 느린 선의 위치 관계로 현재 추세를 분류하며,
// 장기 기준선과의 관계를 추가로 확인해 신뢰도를 높입니다.
// 기준선은 사용자가 선택한 방식(SMA/EMA)으로 계산되며,
// 상위 타임프레임 데이터를 참조할 수 있어 리페인팅 없이
// 안정적인 값을 반환합니다.
// 기준선 주변에 일정 범위의 완충 구간이 설정되며,
// 가격이 이 구간 안에 있을 경우 방향성 없음으로 처리합니다.
// 방향성은 세 가지 상태(상승/하락/중립)로 압축되며
// 이후 모든 진입 및 청산 판단의 기반이 됩니다.

// 손절 기준선은 진입 시점의 가격에서 파생된 동적 수치로,
// 포지션 방향에 따라 위 또는 아래에 위치합니다.
// 가격이 이 선을 이탈하면 해당 포지션은 강제 청산됩니다.
// 손절선의 구체적인 산출 방식은 입력 파라미터에 종속됩니다.

// 캔들 색상은 현재 방향성 상태를 반영하며,
// 상승/하락 여부 및 강도에 따라 색조가 달라집니다.
// 골든크로스/데드크로스 감지 기능은 옵션으로 제공됩니다.

// ── 모듈 B ──────────────────────────────────
// 별도의 단기 타임프레임(5분봉) 데이터를 참조하여
// 현재 차트 위에 추세선을 표시합니다.
// 추세선은 가격의 변동성을 반영한 동적 밴드를 기준으로
// 방향이 결정되며, 스무딩 처리를 거쳐 출력됩니다.
// 현재 가격과 추세선의 거리에 따라 색상 농도가 달라지며,
// 멀수록 진하게, 가까울수록 연하게 표시됩니다.

// SAR(Stop and Reverse) 지표를 보조적으로 활용하며,
// 단순히 SAR 값을 표시하는 것이 아니라
// 특정 캔들 조건이 충족될 때만 활성화되는 필터가 적용됩니다.
// 추세 방향과 캔들 방향이 일치하는 시점부터만
// SAR이 화면에 나타나며, 그 이전에는 숨김 처리됩니다.

// ── 시그널 ───────────────────────────────────
// 진입과 청산 상태는 별도의 변수로 관리되며
// 중복 진입이 발생하지 않도록 이전 상태를 확인합니다.
// 롱/숏 진입 조건은 모듈 B의 상태값에 종속되며
// 바 확정 시점에만 평가됩니다.
// 청산은 추세 반전 또는 SAR 방향 전환 시 발생하며,
// 수익 청산과 손실 청산을 구분해 라벨로 표시합니다.
// 진입 시그널은 캔들 위/아래 삼각형으로 표시되며,
// 수익 청산은 💰, 손실 청산은 💥 라벨로 나타납니다.

// ── 알람 ─────────────────────────────────────
// 네 가지 조건(롱진입/숏진입/익절/손절)에 대해
// 각각 독립적인 알람 조건이 설정되어 있습니다.
// 거래량이 없거나 가격 데이터가 없는 종목(상폐 등)은
// 알람 대상에서 자동으로 제외됩니다.

## Source Code

````pine
//@version=6
indicator(title='JEC Mix01 + Trend Tracker', shorttitle='JEC Mix01', overlay=true)

// ═══════════════════════════════════════════════════════════
// ■ GROUP 1: Mix01 — EMA Cross + Trend Channel [Gu5]
// ═══════════════════════════════════════════════════════════
C_GREEN      = #006400
C_GREENLIGHT = #388e3c
C_RED        = #8B0000
C_REDLIGHT   = #b71c1c

i_maSrc     = input.source    (close,  'MA Source',           group='EMAs')
i_maFast1   = input.int       (26,     'EMA Fast',            group='EMAs')
i_maFast2   = input.int       (50,     'EMA Medium',          group='EMAs')
i_maLen     = input.int       (200,    'MA Trend',            group='Trend Channel')
i_maLenSel  = input.string    ('SMA',  'MA Type',             group='Trend Channel', options=['EMA','SMA'])
i_htf       = input.timeframe ('',     'Higher Timeframe',    group='Trend Channel')
i_rangeLen  = input.float     (0.618,  'Channel Range',       group='Trend Channel')
i_slOn      = input.bool      (true,   '■ Stop Loss On/Off',  group='Stop Loss')
i_sl        = input.float     (1.5,    'SL %',                group='Stop Loss', step=0.1)
i_channelOn = input.bool      (false,  '■ Channel On/Off',    group='Display')
i_goldenOn  = input.bool      (false,  '■ Golden Cross',      group='Display')
i_barColOn  = input.bool      (true,   '■ Bar Color On/Off',  group='Display')

maFast1     = ta.ema(i_maSrc, i_maFast1)
maFast2     = ta.ema(i_maSrc, i_maFast2)
maDir       = maFast1 > maFast2 ? 1 : -1
maTrend     = request.security(syminfo.tickerid, i_htf,
              i_maLenSel == 'SMA' ? ta.sma(close, i_maLen)[1] : ta.ema(close, i_maLen)[1],
              lookahead=barmerge.lookahead_on)
maTrendDir  = i_maSrc >= maTrend ? 1 : -1
rangeAtr    = ta.atr(i_maLen) * i_rangeLen
rangeTop    = maTrend + rangeAtr
rangeBot    = maTrend - rangeAtr
rangeCh     = (open <= rangeTop or close <= rangeTop) and (open >= rangeBot or close >= rangeBot)
trendDir    = rangeCh                                              ?  0 :
              maTrendDir ==  1 and maDir ==  1                    ?  1 :
              maTrendDir == -1 and maDir == -1                    ? -1 : 0

condition   = 0.0
slEntry     = close * i_sl / 100
slTop       = close + slEntry
slBot       = close - slEntry
entryLong_m = trendDir ==  1
entryShort_m= trendDir == -1
condition  := condition[1] !=  1 and entryLong_m  ?  1 :
              condition[1] != -1 and entryShort_m ? -1 :
              condition[1] ==  1 and trendDir != 1 ?  0 :
              condition[1] == -1 and trendDir != -1?  0 : nz(condition[1])

slTopBuff   = ta.valuewhen(condition[1] !=  1 and entryLong_m,  slBot, 0)
slBotBuff   = ta.valuewhen(condition[1] != -1 and entryShort_m, slTop, 0)
slLine      = condition[1] ==  1 ? slTopBuff :
              condition[1] == -1 ? slBotBuff : na
slTopCross  = condition[1] ==  1 and ta.crossunder(low,  slLine)
slBotCross  = condition[1] == -1 and ta.crossover (high, slLine)
slExit      = i_slOn ? slTopCross or slBotCross : false

GCross      = i_goldenOn ? ta.crossover (maFast2, maTrend) : false
DCross      = i_goldenOn ? ta.crossunder(maFast2, maTrend) : false

c_emas      = trendDir ==  1 and maDir ==  1 ? color.new(C_GREEN, 99) :
              trendDir == -1 and maDir == -1 ? color.new(C_RED,   99) : color.new(color.orange, 99)
c_maFill    = trendDir ==  1 and maDir ==  1 ? color.new(C_GREEN, 70) :
              trendDir == -1 and maDir == -1 ? color.new(C_RED,   70) : color.new(color.orange, 70)
c_maTrend   = trendDir ==  0                           ? color.new(color.orange,  0) :
              trendDir ==  1 and maTrend[1]  < maTrend ? color.new(C_GREEN,       0) :
              trendDir ==  1 and maTrend[1] >= maTrend ? color.new(C_GREENLIGHT,  0) :
              trendDir == -1 and maTrend[1]  < maTrend ? color.new(C_REDLIGHT,    0) :
              trendDir == -1 and maTrend[1] >= maTrend ? color.new(C_RED,         0) : na
c_ch        = trendDir ==  0 ? color.new(color.orange, 50) :
              trendDir ==  1 ? color.new(C_GREEN, 50) :
              trendDir == -1 ? color.new(C_RED,   50) : na

p_maFast1   = plot(maFast1, 'EMA Fast 1',   color=c_emas,    linewidth=1)
p_maFast2   = plot(maFast2, 'EMA Fast 2',   color=c_emas,    linewidth=2)
fill(p_maFast1, p_maFast2, title='EMAs Fill', color=c_maFill)
plot(maTrend, 'SMA Trend', color=c_maTrend, linewidth=3)
p_chTop     = plot(i_channelOn ? rangeTop : na, 'Top Channel',    color=c_maTrend)
p_chBot     = plot(i_channelOn ? rangeBot : na, 'Bottom Channel', color=c_maTrend)
fill(p_chTop, p_chBot, title='Channel', color=c_ch)
plot(i_slOn and condition != 0 ? slLine : na, 'Stop Loss', color=color.red, linewidth=1, style=plot.style_linebr)

// ═══════════════════════════════════════════════════════════
// ■ GROUP 2: Trend Tracker Pro — 5분봉 추세선 + SAR
// ═══════════════════════════════════════════════════════════
tt_length   = input.int   (16,   '추세 길이',    group='Trend Tracker')
tt_mult     = input.float (2.0,  'ATR 배수',     group='Trend Tracker', step=0.1)
tt_smooth   = input.int   (20,   '추세선 스무딩', group='Trend Tracker')
sarStart    = input.float (0.02, 'SAR 시작값',   group='SAR', step=0.01)
sarInc      = input.float (0.02, 'SAR 가속도',   group='SAR', step=0.01)
sarMax      = input.float (0.2,  'SAR 최대값',   group='SAR', step=0.1)

getTrendData(len, mult, smooth) =>
    _atr = ta.atr(len)
    _ema = ta.ema(close, len)
    _upper = _ema + mult * _atr
    _lower = _ema - mult * _atr
    var float _tl = close
    float _raw = _tl
    if close > _upper
        _raw := _lower
    else if close < _lower
        _raw := _upper
    else
        _raw := nz(_raw[1], close)
    [ta.ema(_raw, smooth), _atr]

[trendLine_5m, atr_5m] = request.security(syminfo.tickerid, '5', getTrendData(tt_length, tt_mult, tt_smooth))

float trendStrength = math.min(math.abs(close - trendLine_5m) / atr_5m, 1.0)
color trendColor    = color.from_gradient(trendStrength, 0, 1, color.new(color.white, 70), color.new(color.white, 0))
plot(trendLine_5m, '추세선 (5m)', color=trendColor, linewidth=3)

psar        = ta.sar(sarStart, sarInc, sarMax)
bool isSarLong  = psar < close
bool sarFlipped = isSarLong != isSarLong[1]

color cColor = na
if close > trendLine_5m
    cColor := psar > close ? color.black : color.aqua
else
    cColor := psar < close ? color.black : color.red

var bool showSar = false
if sarFlipped
    showSar := false
if cColor == color.aqua and close > open
    showSar := true
if cColor == color.red and close < open
    showSar := true

color sarColor = (cColor == color.black or not showSar) ? color.new(color.white,100) : (isSarLong ? color.aqua : color.red)
plot(na(sarColor) ? na : psar, 'SAR', style=plot.style_linebr, color=sarColor, linewidth=2)

// ═══════════════════════════════════════════════════════════
// ■ Bar Color (Mix01 우선, SAR 보조)
// ═══════════════════════════════════════════════════════════
barcolor(i_barColOn ? cColor : na)
// ═══════════════════════════════════════════════════════════
// ■ 진입/청산 시그널 (Trend Tracker SAR 기반)
// ═══════════════════════════════════════════════════════════
var int   trade      = 0
var float entryPrice = na
var int   lastDir    = 0

bool entryL  = barstate.isconfirmed and trade != 1  and cColor == color.aqua and close > open and showSar
bool entryS  = barstate.isconfirmed and trade != -1 and cColor == color.red  and close < open and showSar
bool exitSig = barstate.isconfirmed and ((trade == 1 and (cColor != color.aqua or sarFlipped)) or (trade == -1 and (cColor != color.red or sarFlipped)))
bool exitPro = exitSig and ((trade == 1 and close > entryPrice) or (trade == -1 and close < entryPrice))
bool exitLos = exitSig and not exitPro

if entryL
    trade := 1
    entryPrice := close
    lastDir := 1
else if entryS
    trade := -1
    entryPrice := close
    lastDir := -1
else if exitSig
    trade := 0
    entryPrice := na

plotshape(entryL,  style=shape.triangleup,   location=location.belowbar, color=color.aqua, size=size.small, title='Entry Long')
plotshape(entryS,  style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.small, title='Entry Short')

float exitY = lastDir == 1 ? math.max(open,close) : math.min(open,close)
if exitSig and exitPro
    label.new(bar_index, exitY, '💰', style=label.style_none, textcolor=color.blue, size=size.large)
if exitSig and exitLos
    label.new(bar_index, exitY, '💥', style=label.style_none, textcolor=color.red,  size=size.large)

// ═══════════════════════════════════════════════════════════
// ■ 알람
// ═══════════════════════════════════════════════════════════
isActive = volume > 0 and not na(close) and close > 0
sym  = syminfo.ticker
pric = str.tostring(close)
tc   = str.tostring(time_close)
alertcondition(entryL  and isActive, '롱 진입', '롱')
alertcondition(entryS  and isActive, '숏 진입', '숏')
alertcondition(exitSig and exitPro and isActive, '익절', '익절')
alertcondition(exitSig and exitLos and isActive, '손절', '손절')
````
