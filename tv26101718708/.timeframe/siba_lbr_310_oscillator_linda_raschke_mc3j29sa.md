# [SIBA] LBR 3/10 Oscillator (Linda Raschke)

- url: https://www.tradingview.com/script/mc3J29Sa-SIBA-LBR-3-10-Oscillator-Linda-Raschke/
- type: indicator
- pine_id: PUB;0917386246034dcd915b343a5f2aedaf
- version: 2.0

## Description

# LBR 3/10 Oscillator [로베리단] — TradingView Publish Description

---

## 🇺🇸 ENGLISH

### LBR 3/10 Oscillator [로베리단]

This indicator is an implementation of the **3/10 Oscillator** publicly described by **Linda Bradford Raschke (LBR)** — a legendary floor trader, Market Wizard (Schwager, 1992), and one of the most respected systematic traders of our time.

The formula and construction logic are based on Raschke's own description published on her website and in interviews with Active Trader Magazine, as well as the methodology outlined in *Street Smarts* (Raschke & Connors, 1996).

---

### 📐 How It's Built

> *"It's the difference between a three-period simple moving average and a ten-period simple moving average. Plus, there's a second line which is a 16-period simple moving average of the 3/10 line."*
> — Linda Bradford Raschke, Active Trader Magazine

| Line | Formula |
|------|---------|
| **Fast Line** | SMA(3) − SMA(10) |
| **Slow Line (Signal)** | SMA(16) of Fast Line |
| **Histogram** | Fast Line − Slow Line |

---

### ⚡ How It Differs from Standard MACD

While the LBR 3/10 Oscillator is structurally similar to MACD, there are two critical differences:

| Feature | LBR 3/10 Oscillator | Standard MACD |
|---------|-------------------|---------------|
| **Moving Average Type** | Simple Moving Average (SMA) | Exponential Moving Average (EMA) |
| **Fast Period** | 3 | 12 |
| **Slow Period** | 10 | 26 |
| **Signal Period** | 16 | 9 |
| **Sensitivity** | Higher — reacts faster to price | Lower — smoother, more lag |
| **Best Use** | Intraday trend detection, first 30-min analysis | Swing / position trading |

**Why SMA instead of EMA?**
EMA assigns more weight to recent prices, which can create false signals during whipsaw conditions. Raschke's use of SMA gives equal weight to each bar in the lookback period, producing a cleaner, less noise-reactive oscillator — especially effective on intraday charts (5-min, 15-min) for detecting **Trend Day** conditions early.

---

### 🎯 Trading Setups (per Raschke's methodology)

**1. Trend Day Detection (Core Use Case)**
When the Slow Line shows strong directional momentum in the **first 30 minutes** of the session (deeply negative or positive), this is a classic early warning of a Trend Day. Raschke has publicly shared this concept multiple times.

**2. First Cross Setup**
After the Slow Line crosses the zero line (trend change), wait for the Fast Line to cross back against the Slow Line — this is the first pullback entry in the new trend direction.

**3. Pullback in Trend**
When the Fast Line crosses the Slow Line in the opposite direction of the prevailing trend (Slow Line side of zero), it signals a short-term pullback — an opportunity to add to the trend position.

**4. Divergence**
When price makes a new high/low but the Fast Line fails to confirm, a potential trend reversal is building.

---

### 🛠 Features in This Implementation

- ✅ Fast Line with directional color (rising = orange / falling = red)
- ✅ Slow Line (Signal) plotted separately
- ✅ 4-shade histogram (strong/weak bull/bear)
- ✅ Background shading by trend direction
- ✅ First Cross signals (▲ / ▼)
- ✅ Zero-line cross signals (trend change markers ○)
- ✅ Optional Standard Deviation Bands (overbought/oversold)
- ✅ Real-time info table (Fast, Slow values + trend status)
- ✅ 4 alert conditions (trend change up/down, first cross buy/sell)

---

### ⚙️ Default Settings

| Parameter | Default | Notes |
|-----------|---------|-------|
| Fast SMA | 3 | Raschke original |
| Slow SMA | 10 | Raschke original |
| Signal SMA | 16 | Raschke original |
| Histogram | On | Toggle on/off |
| Std Dev Bands | Off | Toggle on/off |

---

### 📚 Credits & References

- Linda Bradford Raschke — [lindaraschke.net](https://lindaraschke.net)
- *Street Smarts: High Probability Short-Term Trading Strategies* — Raschke & Connors (1996)
- Active Trader Magazine interview with Linda Raschke
- Shared by **로베리단 (LoBeriDan)** trading community

> This indicator is built strictly from publicly available information shared by Linda Raschke herself. No proprietary or private materials were used.

---
---

## 🇰🇷 한국어

### LBR 3/10 오실레이터 [로베리단]

이 인디케이터는 **Linda Bradford Raschke(LBR)**가 공개적으로 발표한 **3/10 오실레이터**를 Pine Script v6로 구현한 것입니다.

Linda Raschke는 시카고 상품거래소(CME) 출신의 전설적인 플로어 트레이더이자, Jack Schwager의 『New Market Wizards』(1992)에 소개된 Market Wizard입니다. 이 인디케이터의 로직은 Raschke가 자신의 웹사이트, Active Trader Magazine 인터뷰, 그리고 *Street Smarts* (Raschke & Connors, 1996)를 통해 직접 공개한 공식을 기반으로 합니다.

---

### 📐 계산 방법

> *"3기간 단순이동평균에서 10기간 단순이동평균을 뺀 값이 Fast Line입니다. 여기에 그 Fast Line의 16기간 단순이동평균을 Slow Line으로 추가합니다."*
> — Linda Bradford Raschke, Active Trader Magazine

| 라인 | 계산 공식 |
|------|---------|
| **Fast Line (빠른 선)** | SMA(3) − SMA(10) |
| **Slow Line / Signal (느린 선)** | Fast Line의 SMA(16) |
| **히스토그램** | Fast Line − Slow Line |

---

### ⚡ 일반 MACD와의 차이점

LBR 3/10 오실레이터는 MACD와 구조적으로 유사하지만, 실전에서 중요한 두 가지 핵심 차이가 있습니다.

| 항목 | LBR 3/10 오실레이터 | 일반 MACD |
|------|-----------------|---------|
| **이동평균 종류** | 단순이동평균 (SMA) | 지수이동평균 (EMA) |
| **Fast 기간** | 3 | 12 |
| **Slow 기간** | 10 | 26 |
| **Signal 기간** | 16 | 9 |
| **민감도** | 높음 — 가격 변화에 빠르게 반응 | 낮음 — 부드럽지만 후행성 큼 |
| **주요 활용** | 장중 트렌드 감지, 오전 30분 분석 | 스윙/포지션 트레이딩 |

**왜 EMA가 아닌 SMA인가?**
EMA는 최근 가격에 더 많은 가중치를 부여하기 때문에, 변동성이 급격한 구간에서 노이즈에 취약합니다. Raschke가 SMA를 사용한 이유는 룩백 기간의 모든 봉에 동일한 가중치를 부여함으로써 **더 깨끗하고 신뢰도 높은 모멘텀 신호**를 얻기 위해서입니다. 특히 5분봉, 15분봉 단기 차트에서 **트렌드 데이(Trend Day) 조기 감지**에 탁월합니다.

---

### 🎯 매매 셋업 (Raschke 방법론 기준)

**1. 트렌드 데이 조기 감지 (핵심 활용법)**
장 시작 후 **첫 30분 안에** Slow Line이 강하게 한 방향(크게 음수 또는 양수)으로 기울어지면, 이는 트렌드 데이의 클래식 조기 신호입니다. Raschke는 이 개념을 수년에 걸쳐 여러 차례 공개적으로 공유해 왔습니다.

**2. First Cross 셋업**
Slow Line이 제로선을 돌파(트렌드 전환)한 이후, Fast Line이 Slow Line을 처음으로 역방향 크로스하는 시점이 첫 번째 풀백 진입 기회입니다.

**3. 트렌드 내 풀백 진입**
이미 형성된 추세 방향에서 Fast Line이 Slow Line을 일시적으로 역크로스하면, 이는 단기 조정(풀백)으로 추가 진입 기회를 의미합니다.

**4. 다이버전스**
가격이 신고점/신저점을 갱신하지만 Fast Line이 이를 확인하지 못할 때, 추세 전환 가능성을 시사합니다.

---

### 🛠 구현 기능 목록

- ✅ Fast Line — 방향에 따른 색상 변화 (상승: 주황 / 하락: 빨강)
- ✅ Slow Line (Signal) 별도 표시
- ✅ 4단계 히스토그램 (강/약 상승·하락 구분)
- ✅ 트렌드 방향 배경색 (상승: 초록 / 하락: 빨강)
- ✅ First Cross 신호 (▲ / ▼)
- ✅ 제로선 크로스 신호 (트렌드 전환 마커 ○)
- ✅ 표준편차 밴드 옵션 (과매수/과매도 감지)
- ✅ 우측 상단 실시간 정보 테이블 (Fast/Slow 값 + 트렌드 상태)
- ✅ 알림 4종 (트렌드 전환 상승/하락, First Cross 매수/매도)

---

### ⚙️ 기본 설정값

| 파라미터 | 기본값 | 비고 |
|---------|------|------|
| Fast SMA | 3 | Raschke 원본 |
| Slow SMA | 10 | Raschke 원본 |
| Signal SMA | 16 | Raschke 원본 |
| 히스토그램 | ON | 토글 가능 |
| 표준편차 밴드 | OFF | 토글 가능 |

---

### 📚 참고 자료 및 크레딧

- Linda Bradford Raschke — [lindaraschke.net](https://lindaraschke.net)
- *Street Smarts: High Probability Short-Term Trading Strategies* — Raschke & Connors (1996)
- Active Trader Magazine — Linda Raschke 인터뷰
- **로베리단** 트레이딩 커뮤니티 공유

> 이 인디케이터는 Linda Raschke가 직접 공개한 자료만을 기반으로 제작되었습니다.

## Source Code

````pine
//@version=6
indicator(title="LBR 3/10 Oscillator (Linda Raschke)", shorttitle="LBR310", overlay=false, precision=2)

// ─────────────────────────────────────────────
//  Inputs
// ─────────────────────────────────────────────
// Core
fastLen   = input.int(3,  title="Fast SMA Length",   minval=1, group="Core")
slowLen   = input.int(10, title="Slow SMA Length",   minval=1, group="Core")
signalLen = input.int(16, title="Signal SMA Length", minval=1, group="Core")
showHist  = input.bool(true, title="Show Histogram", group="Core")

// Std Dev Bands / Exhaustion
showBands   = input.bool(false, title="Show Std Dev Bands", group="Bands & Exhaustion")
bandMult    = input.float(1.5,  title="Band Multiplier (sigma)", step=0.1, group="Bands & Exhaustion")
bandLen     = input.int(20,     title="Band Length", group="Bands & Exhaustion")
showExhaust = input.bool(true,  title="Show Band Exhaustion Signals", group="Bands & Exhaustion")

// Signals
strictFirstCross = input.bool(true, title="Strict First Cross Only (one signal per trend leg)", group="Signals")
showAnti         = input.bool(true, title="Show Anti Setup Signals", group="Signals")
antiMinPullback  = input.int(2,     title="Anti: Min Pullback Bars", minval=1, group="Signals")

// Divergence
showDiv      = input.bool(true, title="Show Divergence", group="Divergence")
divLookLeft  = input.int(5,  title="Pivot Lookback Left",  minval=1, group="Divergence")
divLookRight = input.int(5,  title="Pivot Lookback Right", minval=1, group="Divergence")
divRangeMin  = input.int(5,  title="Min Bars Between Pivots", minval=1, group="Divergence")
divRangeMax  = input.int(60, title="Max Bars Between Pivots", minval=2, group="Divergence")

// Higher Timeframe Filter
useHtfFilter = input.bool(false, title="Use HTF Trend Filter (blocks counter-trend signals)", group="HTF Filter")
htfTf        = input.timeframe("15", title="HTF Timeframe", group="HTF Filter")

// Webhook Automation
enableWebhook = input.bool(false, title="Enable alert() JSON Messages (webhook)", group="Webhook")

// Display
showTable = input.bool(false, title="Show Info Table", group="Display")

// ─────────────────────────────────────────────
//  Calculation (Linda Raschke original: SMA-based)
//  Fast Line  = SMA(3)  - SMA(10)
//  Slow Line  = SMA(16) of Fast Line
//  Histogram  = Fast - Slow
// ─────────────────────────────────────────────
fastLine = ta.sma(close, fastLen) - ta.sma(close, slowLen)
slowLine = ta.sma(fastLine, signalLen)
hist     = fastLine - slowLine

// ─────────────────────────────────────────────
//  Higher Timeframe Filter
//  Note: on the realtime bar the HTF value updates until the HTF bar
//  closes (standard behavior with lookahead_off, no future leak).
// ─────────────────────────────────────────────
htfSlow = request.security(syminfo.tickerid, htfTf, slowLine, lookahead=barmerge.lookahead_off)
htfBull = htfSlow > 0
htfBear = htfSlow < 0

longAllowed  = not useHtfFilter or htfBull
shortAllowed = not useHtfFilter or htfBear

// ─────────────────────────────────────────────
//  Standard Deviation Bands
// ─────────────────────────────────────────────
bandStd   = ta.stdev(fastLine, bandLen)
upperBand = bandMult * bandStd
lowerBand = -bandMult * bandStd

// ─────────────────────────────────────────────
//  Colors
// ─────────────────────────────────────────────
fastColor = fastLine > fastLine[1] ? color.new(color.orange, 0) : color.new(color.red, 0)
slowColor = color.new(color.orange, 40)
histColor = hist >= 0
     ? (hist >= hist[1] ? color.new(#00c853, 0) : color.new(#00c853, 50))
     : (hist <= hist[1] ? color.new(#ff1744, 0) : color.new(#ff1744, 50))

// ─────────────────────────────────────────────
//  Plots
// ─────────────────────────────────────────────
hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_solid, linewidth=1)

upperPlot = plot(showBands ? upperBand : na, title="Upper Band", color=color.new(color.gray, 70), linewidth=1, style=plot.style_line)
lowerPlot = plot(showBands ? lowerBand : na, title="Lower Band", color=color.new(color.gray, 70), linewidth=1, style=plot.style_line)
fill(upperPlot, lowerPlot, color=color.new(color.gray, 90), title="Band Fill")

plot(showHist ? hist : na,
     title     = "Histogram",
     style     = plot.style_histogram,
     color     = histColor,
     linewidth = 2)

plot(slowLine,
     title     = "Slow Line (Signal)",
     color     = slowColor,
     linewidth = 2)

plot(fastLine,
     title     = "Fast Line",
     color     = fastColor,
     linewidth = 2)

// ─────────────────────────────────────────────
//  Trend & First Cross Setup
// ─────────────────────────────────────────────
bullTrend = slowLine > 0
bearTrend = slowLine < 0

slowCrossUp   = ta.crossover(slowLine, 0)
slowCrossDown = ta.crossunder(slowLine, 0)

rawCrossBuy  = bullTrend and ta.crossover(fastLine, slowLine)
rawCrossSell = bearTrend and ta.crossunder(fastLine, slowLine)

// Fire only ONCE per trend leg (Raschke's actual First Cross definition)
var bool buySignalUsed  = false
var bool sellSignalUsed = false

if slowCrossUp
    buySignalUsed := false
if slowCrossDown
    sellSignalUsed := false

firstCrossBuy  = rawCrossBuy  and (not strictFirstCross or not buySignalUsed) and longAllowed
firstCrossSell = rawCrossSell and (not strictFirstCross or not sellSignalUsed) and shortAllowed

if firstCrossBuy
    buySignalUsed := true
if firstCrossSell
    sellSignalUsed := true

// ─────────────────────────────────────────────
//  Anti Setup (Raschke)
//  Slow Line slope defines the trend; Fast Line pulls back against it
//  for N+ bars, then hooks back in the trend direction.
// ─────────────────────────────────────────────
var int fastFallStreak = 0
var int fastRiseStreak = 0
fastFallStreak := fastLine < fastLine[1] ? fastFallStreak + 1 : 0
fastRiseStreak := fastLine > fastLine[1] ? fastRiseStreak + 1 : 0

antiLong  = showAnti and slowLine > slowLine[1] and fastLine > fastLine[1] and fastFallStreak[1] >= antiMinPullback and longAllowed
antiShort = showAnti and slowLine < slowLine[1] and fastLine < fastLine[1] and fastRiseStreak[1] >= antiMinPullback and shortAllowed

// ─────────────────────────────────────────────
//  Band Exhaustion
//  Fast Line was beyond +/- band and hooks back toward zero.
// ─────────────────────────────────────────────
exhaustSell = showExhaust and fastLine[1] > upperBand[1] and fastLine < fastLine[1]
exhaustBuy  = showExhaust and fastLine[1] < lowerBand[1] and fastLine > fastLine[1]

// ─────────────────────────────────────────────
//  Divergence (regular) — price vs Fast Line pivots
//  Note: confirmed divLookRight bars after the actual pivot (inherent lag).
// ─────────────────────────────────────────────
plFound = not na(ta.pivotlow(fastLine, divLookLeft, divLookRight))
phFound = not na(ta.pivothigh(fastLine, divLookLeft, divLookRight))

_inRange(cond) =>
    bars = ta.barssince(cond)
    divRangeMin <= bars and bars <= divRangeMax

// Bullish: price makes lower low, oscillator makes higher low
oscHL    = fastLine[divLookRight] > ta.valuewhen(plFound, fastLine[divLookRight], 1) and _inRange(plFound[1])
priceLL  = low[divLookRight] < ta.valuewhen(plFound, low[divLookRight], 1)
bullDiv  = showDiv and plFound and oscHL and priceLL

// Bearish: price makes higher high, oscillator makes lower high
oscLH    = fastLine[divLookRight] < ta.valuewhen(phFound, fastLine[divLookRight], 1) and _inRange(phFound[1])
priceHH  = high[divLookRight] > ta.valuewhen(phFound, high[divLookRight], 1)
bearDiv  = showDiv and phFound and oscLH and priceHH

// Divergence lines on the oscillator
plot(plFound ? fastLine[divLookRight] : na,
     title  = "Bullish Divergence Line",
     offset = -divLookRight,
     color  = bullDiv ? color.new(color.lime, 0) : color.new(color.lime, 100),
     linewidth = 2)

plot(phFound ? fastLine[divLookRight] : na,
     title  = "Bearish Divergence Line",
     offset = -divLookRight,
     color  = bearDiv ? color.new(color.red, 0) : color.new(color.red, 100),
     linewidth = 2)

// ─────────────────────────────────────────────
//  Background: trend direction
// ─────────────────────────────────────────────
bgcolor(bullTrend ? color.new(color.green, 95) : na, title="Bull Trend BG")
bgcolor(bearTrend ? color.new(color.red, 95)   : na, title="Bear Trend BG")

// ─────────────────────────────────────────────
//  Signal Shapes
// ─────────────────────────────────────────────
plotshape(firstCrossBuy,
     title    = "First Cross Buy",
     location = location.bottom,
     style    = shape.triangleup,
     color    = color.new(color.lime, 0),
     size     = size.small)

plotshape(firstCrossSell,
     title    = "First Cross Sell",
     location = location.top,
     style    = shape.triangledown,
     color    = color.new(color.red, 0),
     size     = size.small)

plotshape(antiLong,
     title    = "Anti Long",
     location = location.bottom,
     style    = shape.diamond,
     color    = color.new(color.teal, 0),
     size     = size.tiny)

plotshape(antiShort,
     title    = "Anti Short",
     location = location.top,
     style    = shape.diamond,
     color    = color.new(color.maroon, 0),
     size     = size.tiny)

plotshape(exhaustBuy,
     title    = "Exhaustion Buy",
     location = location.bottom,
     style    = shape.xcross,
     color    = color.new(color.yellow, 0),
     size     = size.tiny)

plotshape(exhaustSell,
     title    = "Exhaustion Sell",
     location = location.top,
     style    = shape.xcross,
     color    = color.new(color.yellow, 0),
     size     = size.tiny)

plotshape(bullDiv ? fastLine[divLookRight] : na,
     title    = "Bullish Divergence",
     location = location.absolute,
     offset   = -divLookRight,
     style    = shape.labelup,
     color    = color.new(color.lime, 20),
     text     = "Div",
     textcolor = color.white,
     size     = size.tiny)

plotshape(bearDiv ? fastLine[divLookRight] : na,
     title    = "Bearish Divergence",
     location = location.absolute,
     offset   = -divLookRight,
     style    = shape.labeldown,
     color    = color.new(color.red, 20),
     text     = "Div",
     textcolor = color.white,
     size     = size.tiny)

plotshape(slowCrossUp,
     title    = "Trend Change Up",
     location = location.bottom,
     style    = shape.circle,
     color    = color.new(color.aqua, 0),
     size     = size.tiny)

plotshape(slowCrossDown,
     title    = "Trend Change Down",
     location = location.top,
     style    = shape.circle,
     color    = color.new(color.fuchsia, 0),
     size     = size.tiny)

// ─────────────────────────────────────────────
//  Alerts — alertcondition (manual setup per signal)
// ─────────────────────────────────────────────
alertcondition(slowCrossUp,    title="Trend Change Up",   message="LBR310 {{ticker}} {{interval}}: Slow Line crossed above zero - bullish trend change")
alertcondition(slowCrossDown,  title="Trend Change Down", message="LBR310 {{ticker}} {{interval}}: Slow Line crossed below zero - bearish trend change")
alertcondition(firstCrossBuy,  title="First Cross Buy",   message="LBR310 {{ticker}} {{interval}}: First Fast Line cross up in bull trend - buy setup")
alertcondition(firstCrossSell, title="First Cross Sell",  message="LBR310 {{ticker}} {{interval}}: First Fast Line cross down in bear trend - sell setup")
alertcondition(antiLong,       title="Anti Long",         message="LBR310 {{ticker}} {{interval}}: Anti setup long - pullback hook in uptrend")
alertcondition(antiShort,      title="Anti Short",        message="LBR310 {{ticker}} {{interval}}: Anti setup short - pullback hook in downtrend")
alertcondition(bullDiv,        title="Bullish Divergence", message="LBR310 {{ticker}} {{interval}}: Bullish divergence detected")
alertcondition(bearDiv,        title="Bearish Divergence", message="LBR310 {{ticker}} {{interval}}: Bearish divergence detected")
alertcondition(exhaustBuy,     title="Exhaustion Buy",    message="LBR310 {{ticker}} {{interval}}: Fast Line hooked up from below lower band")
alertcondition(exhaustSell,    title="Exhaustion Sell",   message="LBR310 {{ticker}} {{interval}}: Fast Line hooked down from above upper band")

// ─────────────────────────────────────────────
//  Alerts — alert() JSON (single "Any alert() function call" alert,
//  webhook-ready for PickMyTrade / TradeSyncer etc.)
// ─────────────────────────────────────────────
f_jsonAlert(string sig, string dir) =>
    msg = '{"indicator":"LBR310","signal":"' + sig + '","direction":"' + dir +
         '","ticker":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix +
         '","interval":"' + timeframe.period + '","price":' + str.tostring(close) +
         ',"time":"' + str.format_time(time, "yyyy-MM-dd HH:mm:ss", syminfo.timezone) + '"}'
    alert(msg, alert.freq_once_per_bar_close)

if enableWebhook
    if firstCrossBuy
        f_jsonAlert("first_cross", "long")
    if firstCrossSell
        f_jsonAlert("first_cross", "short")
    if antiLong
        f_jsonAlert("anti", "long")
    if antiShort
        f_jsonAlert("anti", "short")
    if bullDiv
        f_jsonAlert("divergence", "long")
    if bearDiv
        f_jsonAlert("divergence", "short")
    if exhaustBuy
        f_jsonAlert("exhaustion", "long")
    if exhaustSell
        f_jsonAlert("exhaustion", "short")
    if slowCrossUp
        f_jsonAlert("trend_change", "long")
    if slowCrossDown
        f_jsonAlert("trend_change", "short")

// ─────────────────────────────────────────────
//  Info Table (off by default)
// ─────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast and showTable
    trend_str = bullTrend ? "▲ BULL" : bearTrend ? "▼ BEAR" : "─ NEUTRAL"
    trend_col = bullTrend ? color.green : bearTrend ? color.red : color.gray
    htf_str   = htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "─ NEUTRAL"
    htf_col   = htfBull ? color.green : htfBear ? color.red : color.gray

    table.cell(infoTable, 0, 0, "LBR310",    text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(infoTable, 1, 0, "Value",     text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(infoTable, 0, 1, "Fast Line", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(fastLine, "#.##"), text_color=fastLine >= 0 ? color.lime : color.red, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 0, 2, "Slow Line", text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(slowLine, "#.##"), text_color=slowLine >= 0 ? color.lime : color.red, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 0, 3, "Trend",     text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 1, 3, trend_str,   text_color=trend_col,   bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 0, 4, "HTF " + htfTf, text_color=color.white, bgcolor=color.new(color.gray, 60), text_size=size.small)
    table.cell(infoTable, 1, 4, htf_str,     text_color=htf_col,     bgcolor=color.new(color.gray, 60), text_size=size.small)
````
