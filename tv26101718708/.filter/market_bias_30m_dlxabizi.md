# Market Bias 30m

- url: https://www.tradingview.com/script/dLXABizi/
- type: indicator
- pine_id: PUB;65dd5b96620347e99ad2a85b83d64237
- version: 1.0

## Description

상승 돌파 조건
//  ① 상승 편향 확인
//  ② 직전 봉 저항 이하 → 현재 봉 저항 상향 돌파 (양봉 마감)
//  ③ 볼륨 증가

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © maziblend35

//@version=6

indicator("Market Bias · 30분봉 상승 돌파", overlay=true, max_bars_back=500)

// ══════════════════════════════════════════════════════════
//  입력 파라미터
// ══════════════════════════════════════════════════════════
grp_ema  = "EMA 설정"
grp_str  = "구조 설정"
grp_brk  = "돌파 설정"

fast_len  = input.int(20,  "단기 EMA",         minval=1,   group=grp_ema)
mid_len   = input.int(50,  "중기 EMA",         minval=1,   group=grp_ema)
trend_len = input.int(200, "추세 EMA",         minval=1,   group=grp_ema)

swing_len = input.int(5,   "스윙 고저 기간",   minval=2, maxval=20, group=grp_str)
vol_mult  = input.float(1.5,"돌파 볼륨 배수",  minval=1.0, step=0.1, group=grp_brk)
req_vol   = input.bool(true,"볼륨 필터 사용",  group=grp_brk)

// ══════════════════════════════════════════════════════════
//  EMA 계산
// ══════════════════════════════════════════════════════════
ema20  = ta.ema(close, fast_len)
ema50  = ta.ema(close, mid_len)
ema200 = ta.ema(close, trend_len)

// ══════════════════════════════════════════════════════════
//  Market Bias 판정
//  상승: EMA20 > EMA50 > EMA200, 가격 > EMA200
//  하락: EMA20 < EMA50 < EMA200, 가격 < EMA200
// ══════════════════════════════════════════════════════════
bias_bull = ema20 > ema50 and ema50 > ema200 and close > ema200
bias_bear = ema20 < ema50 and ema50 < ema200 and close < ema200

// ══════════════════════════════════════════════════════════
//  스윙 고점 (저항선)  – pivothigh는 swing_len 봉 지연 반영
// ══════════════════════════════════════════════════════════
ph = ta.pivothigh(high, swing_len, swing_len)

var float res_level = na   // 최근 저항선

if not na(ph)
    res_level := ph

// ══════════════════════════════════════════════════════════
//  볼륨 필터
// ══════════════════════════════════════════════════════════
avg_vol    = ta.sma(volume, 20)
vol_ok     = req_vol ? volume > avg_vol * vol_mult : true

// ══════════════════════════════════════════════════════════
//  상승 돌파 조건
//  ① 상승 편향 확인
//  ② 직전 봉 저항 이하 → 현재 봉 저항 상향 돌파 (양봉 마감)
//  ③ 볼륨 증가
// ══════════════════════════════════════════════════════════
bull_breakout = not na(res_level)
             and close[1] <= res_level
             and close    >  res_level
             and close    >  open          // 양봉
             and bias_bull
             and vol_ok

// EMA50 골든크로스 보조 신호
ema50_cross = ta.crossover(close, ema50) and close > ema200 and vol_ok

// ══════════════════════════════════════════════════════════
//  시각화
// ══════════════════════════════════════════════════════════
// EMA 라인
plot(ema20,  "EMA 20",  color=color.new(color.blue,   0), linewidth=1)
plot(ema50,  "EMA 50",  color=color.new(color.orange,  0), linewidth=2)
plot(ema200, "EMA 200", color=color.new(color.red,     0), linewidth=2)

// 저항선
plot(res_level, "저항선", color=color.new(color.purple, 40),
     style=plot.style_stepline_diamond, linewidth=1)

// 배경색 (Market Bias)
bgcolor(bias_bull ? color.new(color.teal,  90) :
        bias_bear ? color.new(color.red,   90) : na,
        title="Market Bias 배경")

// 돌파 신호 아이콘
plotshape(bull_breakout,
          title="🚀 상승 돌파",
          style=shape.triangleup,
          location=location.belowbar,
          color=color.new(color.lime, 0),
          size=size.normal,
          text="돌파")

plotshape(ema50_cross and not bull_breakout,
          title="EMA50 돌파",
          style=shape.circle,
          location=location.belowbar,
          color=color.new(color.aqua, 0),
          size=size.small,
          text="E50")

// ══════════════════════════════════════════════════════════
//  정보 테이블 (우측 상단)
// ══════════════════════════════════════════════════════════
var table t = table.new(position.top_right, 2, 5,
     bgcolor=color.new(color.black, 70),
     border_color=color.gray, border_width=1)

if barstate.islast
    b_col  = bias_bull ? color.lime : bias_bear ? color.red : color.yellow
    b_txt  = bias_bull ? "▲ 상승 편향" : bias_bear ? "▼ 하락 편향" : "─ 중립"
    res_str = not na(res_level) ? str.tostring(math.round(res_level, 2)) : "없음"

    table.cell(t, 0, 0, "Market Bias",  text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 0, b_txt,          text_color=b_col,        text_size=size.small)
    table.cell(t, 0, 1, "EMA 20",       text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 1, str.tostring(math.round(ema20,  2)), text_color=color.blue,   text_size=size.small)
    table.cell(t, 0, 2, "EMA 50",       text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 2, str.tostring(math.round(ema50,  2)), text_color=color.orange, text_size=size.small)
    table.cell(t, 0, 3, "EMA 200",      text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 3, str.tostring(math.round(ema200, 2)), text_color=color.red,    text_size=size.small)
    table.cell(t, 0, 4, "저항선",       text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 4, res_str,        text_color=color.purple, text_size=size.small)

// ══════════════════════════════════════════════════════════
//  알림 조건 (Alerts)
// ══════════════════════════════════════════════════════════
alertcondition(bull_breakout,
     title="🚀 [Market Bias] 상승 돌파!",
     message="상승 돌파 신호 발생!\n저항선 {{plot_1}} 상향 돌파\nMarket Bias: 상승 편향\n볼륨: 확인됨")

alertcondition(ema50_cross,
     title="📈 [Market Bias] EMA50 상향 돌파",
     message="EMA50 상향 돌파 발생!\n상승 전환 확인 필요")

alertcondition(bias_bull and not bias_bull[1],
     title="🟢 [Market Bias] 상승 편향 전환",
     message="시장 편향이 상승으로 전환되었습니다!")
plot(close)
````
