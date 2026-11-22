# Mark Minervini Trend Template & Exit Signals_KOSPI

- url: https://www.tradingview.com/script/SP0AzyKE/
- type: indicator
- pine_id: PUB;173a7287adea419b90ef011b03b4b137
- version: 1.0

## Description

Mark Minervini Trend Template & Exit Signals_KOSPI

## Source Code

````pine
//@version=5
indicator("Mark Minervini Trend Template & Exit Signals", overlay=true)
// ==========================================
// 0. 사용자 설정 입력 (Inputs) - 코스피/나스닥 자유롭게 전환 가능
// ==========================================
gp_market   = "시장 설정 (Market Selection)"
benchmark   = input.symbol("NASDAQ:QQQ", title="상대강도 비교 지수 (RS Benchmark)", group=gp_market, 
              tooltip="미국 주식은 NASDAQ:QQQ 나 SPY, 한국 코스피 주식은 KRX:KOSPI 나 KRX:069500(KODEX 200)을 입력하세요.")
// ==========================================
// 1. 이동평균선 설정 (Moving Averages)
// ==========================================
ema20  = ta.ema(close, 20)  // 단기 트레일링 스톱용 20 EMA
sma50  = ta.sma(close, 50)  // 중기 기준선 50 SMA
sma150 = ta.sma(close, 150) // 장기 추세선 150 SMA
sma200 = ta.sma(close, 200) // 생명선 200 SMA
// ==========================================
// 2. 52주 신고가/신저가 (대략 252 거래일 기준)
// ==========================================
high52 = ta.highest(high, 252)
low52 = ta.lowest(low, 252)
// 200일선 장기 추세 확인 (최소 1개월(21일) 이상 상승 추세인가?)
sma200_1m_ago = sma200[21]
sma200_trending_up = sma200 > sma200_1m_ago
// ==========================================
// 3. 상대강도 계산 (Relative Strength vs Selected Benchmark)
// ==========================================
bench_close = request.security(benchmark, timeframe.period, close)
rs = close / bench_close
rs_sma = ta.sma(rs, 50)
rs_condition = rs > rs_sma
// ==========================================
// 4. 마크 미너비니 트렌드 템플릿 조건 (Stage 2 Uptrend) - 매수 조건
// ==========================================
c1 = close > sma150 and close > sma200
c2 = sma150 > sma200
c3 = sma200_trending_up
c4 = sma50 > sma150 and sma50 > sma200
c5 = close > sma50
c6 = close >= (low52 * 1.30)
c7 = close >= (high52 * 0.75)
trend_template_met = c1 and c2 and c3 and c4 and c5 and c6 and c7 and rs_condition
// ==========================================
// 5. 마크 미너비니식 매도/익절/손절 조건 (Exit Signals)
// ==========================================
// 조건 A: 중기 추세 이탈 (50 SMA 하향 돌파) - 강력한 매도 신호
sell_50sma_break = ta.crossunder(close, sma50)
// 조건 B: 생명선 이탈 (200 SMA 하향 돌파) - 장기 추세 사망 (최종 탈출)
sell_200sma_break = ta.crossunder(close, sma200)
// 조건 C: 단기 추세 익절/트레일링 스톱 (20 EMA 이탈)
sell_20ema_break = ta.crossunder(close, ema20)
// 조건 D: 클라이맥스 탑 (Climax Top - 과열 매도)
climax_top = close > (sma50 * 1.40)
// ==========================================
// 6. 차트 시각화 (Plotting & Colors)
// ==========================================
// 이동평균선 그리기
plot(ema20,  color=color.new(color.purple, 30), title="20 EMA", linewidth=1)
plot(sma50,  color=color.new(color.blue, 0),    title="50 SMA", linewidth=2)
plot(sma150, color=color.new(color.orange, 0),  title="150 SMA", linewidth=2)
plot(sma200, color=color.new(color.red, 0),     title="200 SMA", linewidth=2)
// 2단계 상승추세 유지 시 배경색 표시 (초록색 투명)
bgcolor(trend_template_met ? color.new(color.green, 92) : na, title="Trend Template Active")
// [매수 신호] 2단계 상승 조건 최초 진입 시
buy_signal = trend_template_met and not trend_template_met[1]
plotshape(buy_signal, title="Buy Signal (Setup Met)", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
// [매도 신호]
// 1. 단기 익절 (20 EMA 하향 돌파) - 노란색 X
plotshape(sell_20ema_break and not trend_template_met[1], title="Trailing Stop (20 EMA Break)", style=shape.xcross, location=location.abovebar, color=color.yellow, size=size.small)
// 2. 주요 매도 (50 SMA 하향 돌파) - 주황색 역삼각형
plotshape(sell_50sma_break, title="Sell Signal (50 SMA Break)", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.normal)
// 3. 최종 추세 사망 (200 SMA 하향 돌파) - 빨간색 역삼각형 및 해골 표시
plotshape(sell_200sma_break, title="Fatal Sell (200 SMA Break)", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.large)
// 4. 클라이맥스 탑 (과열 매도 권고) - 분홍색 다이아몬드
plotshape(climax_top and not climax_top[1], title="Climax Top Warning", style=shape.diamond, location=location.abovebar, color=color.rgb(255, 0, 128), size=size.small)
// ==========================================
// 7. 알람 설정 (Alerts)
// ==========================================
alertcondition(buy_signal, title="Minervini Buy Setup!", message="마크 미너비니 트렌드 템플릿 진입: {{ticker}}")
alertcondition(sell_50sma_break, title="Minervini Sell (50 SMA Break)", message="[경고] 50일 이평선 이탈 매도 신호 발생: {{ticker}}")
alertcondition(sell_200sma_break, title="Minervini Critical Sell (200 SMA)", message="[위험] 200일 이평선 장기 추세 이탈! 최종 매도: {{ticker}}")
````
