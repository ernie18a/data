# 1Min Scalping HA-TSI with Trend

- url: https://www.tradingview.com/script/oj6t5KMH/
- type: indicator
- pine_id: PUB;516265f259f9440aa2ee46284cb6636c
- version: 1.0

## Description

1. 주요 지표 구성 요소
TSI 라인 (민감한 실선): 상승 시 청록색, 하락 시 빨간색으로 변하며 현재 힘의 방향을 나타냅니다.
시그널 라인 (회색 점선): TSI의 이동평균선으로, 돌파 시점의 기준이 됩니다.
과매수(30) / 과매도(-30) 기준선: 시장의 과열 및 침체 구간을 나타냅니다.
배경색 (초록/빨강): TSI가 시그널을 돌파하고 방향이 일치할 때 진입 타이밍을 알려줍니다.

2. 매매 전략 (타이밍)
🟢 매수 진입 (Long)
조건: 배경색이 연한 초록색으로 바뀔 때.
세부 확인: TSI 라인(청록색)이 시그널 라인(회색)을 골든크로스(위로 돌파)하고, TSI 라인 자체가 상승하고 있어야 합니다.
추가 팁: TSI 라인이 -30(과매도 구간) 근처나 그 아래에서 골든크로스가 일어날 때 승률이 가장 높습니다.

🔴 매도 진입 / 숏 (Short)
조건: 배경색이 연한 빨간색으로 바뀔 때.
세부 확인: TSI 라인(빨간색)이 시그널 라인(회색)을 데드크로스(아래로 돌파)하고, TSI 라인 자체가 하락하고 있어야 합니다.
추가 팁: TSI 라인이 +30(과매수 구간) 근처나 그 위에서 데드크로스가 일어날 때 승률이 가장 높습니다.

3. 익절 및 손절 (청산)
익절 (Take Profit): TSI 라인의 색상이 바뀔 때(청록색 ➡️ 빨간색 또는 반대) 또는 반대편 기준선(30 또는 -30)에 도달했을 때 분할 청산합니다.
손절 (Stop Loss): 진입 원인이 된 배경색이 사라지거나 반대색으로 바뀔 때, 또는 직전 캔들의 고점/저점을 이탈할 때 칼같이 손절합니다.

1. Core Components
TSI Line (Main Line): Changes to Cyan when rising and Red when falling, showing the immediate momentum.
Signal Line (Gray Line): The moving average of the TSI, used as a trigger for crossovers.
Overbought (30) / Oversold (-30) Levels: Thresholds identifying extreme market conditions.
Background Color (Green/Red): Highlights high-probability entry windows where trend and momentum align.

2. Trading Strategy (Signals)
🟢 Long Entry (Buy)
Trigger: Enter when the background turns Light Green.
Confirmation: The TSI line (Cyan) must cross above the Signal line (Gray) while the TSI line itself is sloping upward.
Pro-Tip: Higher success rates occur when this golden cross happens near or below the -30 (Oversold) line.
🔴 Short Entry (Sell)
Trigger: Enter when the background turns Light Red.
Confirmation: The TSI line (Red) must cross below the Signal line (Gray) while the TSI line itself is sloping downward.
Pro-Tip: Higher success rates occur when this dead cross happens near or above the +30 (Overbought) line.

3. Exit and Risk Management
Take Profit (TP): Secure profits when the TSI line changes color (Cyan ➡️ Red or vice versa) or when it touches the opposite threshold (+30 or -30).
Stop Loss (SL): Close the position immediately if the background color disappears/reverses, or if the price breaks the recent swing high/low.

## Source Code

````pine
//@version=5
indicator("1Min Scalping HA-TSI with Trend", shorttitle="1m-HA-TSI", overlay=false)

// --- 설정 (1분봉에 최적화된 짧은 주기) ---
longLen = input.int(18, "Long Term (추세)", minval=1)
shortLen = input.int(8, "Short Term (반응)", minval=1)
sigLen = input.int(8, "Signal Line", minval=1)
trendLookback = input.int(5, "Trend Sensitivity", minval=1) // 추세선 민감도

// --- 하이킨 아시 데이터 ---
haClose = (open + high + low + close) / 4

// --- TSI 계산 ---
pc = ta.change(haClose)
doubleSmoothPC = ta.ema(ta.ema(pc, longLen), shortLen)
doubleSmoothAbsPC = ta.ema(ta.ema(math.abs(pc), longLen), shortLen)

tsiValue = 100 * (doubleSmoothPC / doubleSmoothAbsPC)
sigLine = ta.ema(tsiValue, sigLen)

// --- 추세 색상 로직 (기울기 기반) ---
tsiColor = tsiValue > tsiValue[1] ? color.new(#00ffbb, 0) : color.new(#ff1100, 0)
trendColor = tsiValue > sigLine ? color.new(color.green, 50) : color.new(color.red, 50)

// --- 출력 ---
// TSI 메인 라인 (상승 시 굵고 밝은 색)
plot(tsiValue, "TSI Line", color=tsiColor, linewidth=2)
// 시그널 라인
plot(sigLine, "Signal Line", color=color.gray, linewidth=1)

// 기준선 (0선 및 과매수/과매도)
hline(0, "Zero", color=color.new(color.white, 70), linestyle=hline.style_dotted)
h1 = hline(30, "Overbought", color=color.new(#ff5252, 80))
h2 = hline(-30, "Oversold", color=color.new(#4caf50, 80))
fill(h1, h2, color=color.new(color.gray, 95)) // 중앙 박스 구역

// --- 단타용 추세 돌파 신호 (배경색) ---
bgTrend = tsiValue > sigLine and tsiValue > tsiValue[1] ? color.new(color.green, 90) : 
           tsiValue < sigLine and tsiValue < tsiValue[1] ? color.new(color.red, 90) : na
bgcolor(bgTrend)

// --- 추세선 (Trendline) 그리기 로직 ---
// 최근 저점/고점을 연결하는 간단한 추세 시각화 (단타용)
var line trendLine = na
if (ta.rising(tsiValue, trendLookback))
    line.delete(trendLine)
    // 현재 상승 추세면 아래 지지선 느낌으로 시각화 가능 (필요 시 추가 기능)
````
