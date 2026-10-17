# QWF Trailing Signals

- url: https://www.tradingview.com/script/wxS09bmz/
- type: indicator
- pine_id: PUB;f2d7b684c376430986e724d4a76932b2
- version: 1.0

## Description

# QWF Trailing Signals

## Overview
This indicator combines three powerful technical concepts into a single, 
clean visual tool:
1. **Quadratic Weighted Filter (QWF)** — a smoothing algorithm that gives 
   exponentially more weight to recent price action
2. **ATR-based trailing stop** — provides the dynamic trend line that 
   adapts to market volatility
3. **Deviation bands** — four-tier volatility channels around the QWF 
   baseline for identifying price extremes

## Key Features

### 🎯 Dynamic Color-Changing Trend Line
The main trend line shifts color based on a separately-calculated trend 
filter, preventing the "color flickering" common in single-ATR systems:
- **White**: Confirmed uptrend
- **Orange**: Confirmed downtrend

Color changes only after N consecutive bars confirm the new direction, 
filtering out noise during consolidation.

### 📊 Five-Layer Deviation Bands
Built on a QWF baseline with standard deviation multipliers:
- Upper Deviation (outer band)
- Upper Mid Deviation
- QWF Central Line
- Lower Mid Deviation
- Lower Deviation (outer band)

These bands expand and contract with market volatility, highlighting 
overextension zones.

### 🔔 Trend Reversal Alerts
Built-in alert conditions fire when confirmed trend direction flips, 
with a minimum-bars filter to prevent signal spam during choppy markets.

### 📍 Optional TP/SL Visualization
Toggle on-chart take-profit and stop-loss levels displayed as horizontal 
lines for the most recent signal, with configurable percentages.

## How It Works

The script maintains two independent trailing systems running in parallel:

**1. Line Position System** — uses a short QWF period and tight ATR multiplier 
to keep the trend line hugging price action closely. This gives responsive, 
step-like movement that tracks the market in real time.

**2. Color Filter System** — uses a longer QWF period and wider ATR multiplier 
with a consecutive-bar confirmation requirement. This determines whether the 
line appears in uptrend (white) or downtrend (orange) color.

By separating these two systems, the indicator achieves something rare: a 
line that moves with price but only changes color on genuine trend shifts.

## Input Parameters

### Main
- **Amplitude** (default: 30) — Controls band width relative to baseline

### QWF Settings
- **Peariod** (default: 60) — Base period for QWF calculations
- **Sec777** (default: 8) — Divisor for the fast QWF period
- **QWF Length** (default: 80) — Length for the deviation band baseline
- **Deviation Length** (default: 80) — Lookback for standard deviation
- **Multiplier** (default: 2.0) — Band width multiplier

### Trailing Stop
- **Trailing ATR Multiplier** (default: 2.0) — Distance of trend line from price
- **ATR Period** (default: 14) — ATR calculation period

### Trend Filter (Color)
- **Trend ATR Multiplier** (default: 3.5) — Higher = less frequent color changes
- **Trend Confirmation Bars** (default: 3) — Bars needed to confirm direction change

### Signal Filter
- **Minimum Bars Between Signals** (default: 50) — Prevents over-trading

### Risk Management
- **Take Profit %** (default: 1.0)
- **Stop Loss %** (default: 1.0)
- **Show TP/SL Lines** (default: off)

## How to Use

### Trend-Following Strategy
1. Wait for the trend line color to change (white → orange or vice versa)
2. Enter in the direction of the new color after the next candle closes
3. Use the opposite outer deviation band as a dynamic stop-loss reference
4. Exit when the trend line color flips back

### Mean-Reversion Strategy
1. When price touches the outer deviation bands, watch for reversal signals
2. Use the middle QWF line as a target for counter-trend entries
3. Confirm with trend line color — only take longs when line is white, 
   shorts when line is orange

### Best Practices
- Works across all timeframes but best tuned for 1-minute to 1-hour charts
- Increase "Trend ATR Multiplier" on lower timeframes to reduce whipsaws
- Combine with volume or momentum indicators for higher-probability entries
- Test parameter combinations on your specific instrument before live use

## Recommended Settings by Timeframe

| Timeframe | Peariod | Trailing ATR | Trend ATR | Min Bars |
|-----------|---------|--------------|-----------|----------|
| 1 min     | 60      | 2.0          | 3.5       | 50       |
| 5 min     | 40      | 1.8          | 3.0       | 30       |
| 15 min    | 30      | 1.5          | 2.5       | 20       |
| 1 hour    | 20      | 1.5          | 2.5       | 10       |
| 4 hour    | 14      | 1.2          | 2.0       | 5        |

## Notes

- This indicator is designed for discretionary trading and strategy 
  development, not as a standalone signal system
- Past performance does not guarantee future results
- Always combine with proper risk management and market context analysis
- The QWF calculation is computationally intensive; expect slight delay 
  on very long lookback periods

## Disclaimer

This script is provided for educational and informational purposes only. 
It is not financial advice. Trading involves substantial risk of loss. 
Always do your own research and never trade with money you cannot afford 
to lose.

## Source Code

````pine
//@version=5
indicator("QWF Trailing Signals [v8]", overlay=true, max_labels_count=500)

// ========== 입력값 ==========
amplitude    = input.int(30, "Amplitude", minval=1, group="메인")

upColor      = input.color(color.white,  "Up 색상",   group="추세 색상")
downColor    = input.color(color.orange, "Down 색상", group="추세 색상")

tpPercent    = input.float(1.0, "TP %", step=0.1, group="손익")
slPercent    = input.float(1.0, "SL %", step=0.1, group="손익")
showTPSL     = input.bool(false, "TP/SL 박스 표시", group="손익")

peariod      = input.int(60, "피어리어드", minval=1, group="QWF")
sec777       = input.int(8,  "Sec777",    minval=1, group="QWF")
qwfLength    = input.int(80, "QWF 길이",   minval=2, group="QWF")
devLength    = input.int(80, "Deviation Length", minval=2, group="QWF")
multiplier   = input.float(2.0, "멀티플라이어", step=0.1, group="QWF")

trailATRMult = input.float(2.0, "트레일링 ATR 배율", step=0.1, group="트레일링")
atrPeriod    = input.int(14, "ATR 기간", minval=1, group="트레일링")

trendATRMult     = input.float(3.5, "추세 판단 ATR 배율", step=0.1, group="추세 필터", tooltip="클수록 색상이 덜 자주 바뀜")
trendConfirmBars = input.int(3, "추세 확정 봉 수", minval=1, maxval=10, group="추세 필터", tooltip="N봉 연속 같은 방향일 때만 색상 변경")

minBarsBetween = input.int(50, "신호 간 최소 봉 수", minval=1, group="🎯 필터")

// ========== QWF ==========
qwf(source, length) =>
    sum = 0.0
    weight = 0.0
    for i = 0 to length - 1
        w = math.pow(length - i, 2)
        sum := sum + nz(source[i]) * w
        weight := weight + w
    weight != 0 ? sum / weight : source

baseSrc = close
qwfSrc  = hl2

trendBase = qwf(baseSrc, math.max(2, peariod / sec777))

// ========== ATR 트레일링 스톱 (라인 위치) ==========
atrVal = ta.atr(atrPeriod)

trendUp_raw = trendBase + atrVal * trailATRMult
trendDn_raw = trendBase - atrVal * trailATRMult

var float tUp = na
var float tDn = na
var int   tDir = 1

tUp := na(tUp[1]) ? trendUp_raw : (close[1] < tUp[1] ? math.min(trendUp_raw, tUp[1]) : trendUp_raw)
tDn := na(tDn[1]) ? trendDn_raw : (close[1] > tDn[1] ? math.max(trendDn_raw, tDn[1]) : trendDn_raw)

newTDir = tDir
if tDir == -1 and close > tUp[1]
    newTDir := 1
else if tDir == 1 and close < tDn[1]
    newTDir := -1
tDir := newTDir

trendLine = tDir == 1 ? tDn : tUp

// ========== 별도 추세 판단 로직 (색상용) ==========
trendFilterBase = qwf(baseSrc, peariod)
trendFilterUp = trendFilterBase + atrVal * trendATRMult
trendFilterDn = trendFilterBase - atrVal * trendATRMult

var float fUp = na
var float fDn = na
var int   rawTrendDir = 1

fUp := na(fUp[1]) ? trendFilterUp : (close[1] < fUp[1] ? math.min(trendFilterUp, fUp[1]) : trendFilterUp)
fDn := na(fDn[1]) ? trendFilterDn : (close[1] > fDn[1] ? math.max(trendFilterDn, fDn[1]) : trendFilterDn)

newRawDir = rawTrendDir
if rawTrendDir == -1 and close > fUp[1]
    newRawDir := 1
else if rawTrendDir == 1 and close < fDn[1]
    newRawDir := -1
rawTrendDir := newRawDir

// 추세 확정 필터
var int confirmedTrend = 1
var int consecutiveBars = 0

if rawTrendDir == confirmedTrend
    consecutiveBars := 0
else
    consecutiveBars := consecutiveBars + 1
    if consecutiveBars >= trendConfirmBars
        confirmedTrend := rawTrendDir
        consecutiveBars := 0

trendUp    = confirmedTrend == 1
trendColor = trendUp ? upColor : downColor

// ========== 밴드 ==========
qwfBasis = qwf(qwfSrc, qwfLength)
stdev    = ta.stdev(qwfSrc, devLength)
ampF     = amplitude / 30.0

upperDev    = qwfBasis + stdev * multiplier * ampF
upperMidDev = qwfBasis + stdev * multiplier * 0.5 * ampF
lowerMidDev = qwfBasis - stdev * multiplier * 0.5 * ampF
lowerDev    = qwfBasis - stdev * multiplier * ampF

// ========== 플로팅 ==========
pU  = plot(upperDev,    "Upper Dev", color=color.new(color.white, 65), linewidth=1)
pUM = plot(upperMidDev, "Upper Mid", color=color.new(color.white, 80), linewidth=1)
pQ  = plot(qwfBasis,    "QWF",       color=color.new(color.gray, 40), linewidth=1)
pLM = plot(lowerMidDev, "Lower Mid", color=color.new(color.white, 80), linewidth=1)
pL  = plot(lowerDev,    "Lower Dev", color=color.new(color.white, 65), linewidth=1)

fill(pU,  pUM, color=color.new(color.white, 90))
fill(pUM, pQ,  color=color.new(color.white, 93))
fill(pQ,  pLM, color=color.new(color.white, 93))
fill(pLM, pL,  color=color.new(color.white, 90))

plot(trendLine, "추세선", color=trendColor, linewidth=3)

// ========== 신호 계산 ==========
trendChangeUp   = confirmedTrend ==  1 and confirmedTrend[1] == -1
trendChangeDown = confirmedTrend == -1 and confirmedTrend[1] ==  1

var int lastSignalDir = 0
var int lastSignalBar = -9999

barsOK = (bar_index - lastSignalBar) >= minBarsBetween

buySignal  = trendChangeUp   and barsOK and lastSignalDir != 1
sellSignal = trendChangeDown and barsOK and lastSignalDir != -1

if buySignal
    lastSignalBar := bar_index
    lastSignalDir := 1
if sellSignal
    lastSignalBar := bar_index
    lastSignalDir := -1

// ========== TP/SL ==========
var float entryPrice = na
var int   entryBar   = na
var int   entryDir   = 0

if buySignal
    entryPrice := close
    entryBar   := bar_index
    entryDir   := 1
if sellSignal
    entryPrice := close
    entryBar   := bar_index
    entryDir   := -1

showLine = showTPSL and not na(entryBar) and (bar_index - entryBar) < 50

tpLine = showLine and entryDir == 1  ? entryPrice * (1 + tpPercent / 100) : (showLine and entryDir == -1 ? entryPrice * (1 - tpPercent / 100) : na)
slLine = showLine and entryDir == 1  ? entryPrice * (1 - slPercent / 100) : (showLine and entryDir == -1 ? entryPrice * (1 + slPercent / 100) : na)

plot(tpLine, "TP", color=color.new(color.green, 30), style=plot.style_linebr, linewidth=1)
plot(slLine, "SL", color=color.new(color.red,   30), style=plot.style_linebr, linewidth=1)

// ========== 알림 ==========
alertcondition(buySignal,  "매수", "QWF 매수 진입")
alertcondition(sellSignal, "매도", "QWF 매도 진입")
````
