<!-- tradingview-pine-id: PUB;b7a2804c03b64f30a32db58ddd2d0549 -->
<!-- tradingviewscripts-format: 1 -->
# Kinetic Slippage Index (KSI)

Source: https://www.tradingview.com/script/2RrjPh4H-Kinetic-Slippage-Index-KSI/

## Description

//@version=6
indicator("켈트너채널 50/2.8 다음봉 시가 알람", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 설정
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
kcLength   = input.int(50, "켈트너채널 기간", minval=1)
kcMultiple = input.float(2.8, "ATR 배수", minval=0.1, step=0.1)
showSignal = input.bool(true, "차트에 신호 표시")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 켈트너채널 계산
// 중심선: EMA 50
// 채널 폭: ATR 50 × 2.8
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
basis = ta.ema(close, kcLength)
atrValue = ta.atr(kcLength)

upperBand = basis + atrValue * kcMultiple
lowerBand = basis - atrValue * kcMultiple

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조건봉 판정
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// 숏 조건봉
// 1. 고가가 상단선 터치
// 2. 음봉
// 3. 시가와 종가가 모두 상단선 아래
shortSetup =
     high >= upperBand and
     close < open and
     open < upperBand and
     close < upperBand

// 롱 조건봉
// 1. 저가가 하단선 터치
// 2. 양봉
// 3. 시가와 종가가 모두 하단선 위
longSetup =
     low <= lowerBand and
     close > open and
     open > lowerBand and
     close > lowerBand

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 조건봉 다음 봉이 시작될 때 알람
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
shortAlert = barstate.isnew and shortSetup[1]
longAlert  = barstate.isnew and longSetup[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 채널 표시
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
basisPlot = plot(basis, "중심선 EMA 50", color=color.orange)
upperPlot = plot(upperBand, "켈트너 상단선", color=color.red)
lowerPlot = plot(lowerBand, "켈트너 하단선", color=color.blue)

fill(upperPlot, lowerPlot, color=color.new(color.gray, 92))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 신호 표시
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     showSignal and shortAlert,
     title="숏 알람",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SHORT",
     textcolor=color.white,
     size=size.small
)

plotshape(
     showSignal and longAlert,
     title="롱 알람",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="LONG",
     textcolor=color.white,
     size=size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TradingView 알람 조건
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(
     shortAlert,
     title="켈트너 숏 알람",
     message="SHORT|{{ticker}}|{{interval}}|price={{open}}"
)

alertcondition(
     longAlert,
     title="켈트너 롱 알람",
     message="LONG|{{ticker}}|{{interval}}|price={{open}}"
)

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HPotter
////////////////////////////////////////////////////////////
// Copyright by HPotter v1.01 28/06/2026
// The indicator evaluates the "efficiency" of price movement relative to the volume expended. 
// It helps identify hidden unloading opportunities for major players and trend exhaustion points.
//
// Logic: Measures the ratio of the squared true range (ATR)
//
// Signals:
// KSI spikes upward: Price is soaring on low volume (market emptiness, reversal is imminent).
// KSI drops to zero: Huge volume is not moving the price (order density, trapped flat).
//@version=6
indicator("Kinetic Slippage Index (KSI)", shorttitle="KSI", overlay=false, timeframe="", timeframe_gaps=true, precision = 6)

//Inputs
int atrLength    = input.int(14, title="ATR / Range Period", minval=1)
int volEmaLength = input.int(20, title="Volume EMA Period", minval=1)
int sigLength    = input.int(9,  title="Signal Line Period", minval=1)
float sigSpike    = input.float(0,  title="Spike Signal Level", minval=0)

//Calculate
float trueRange = ta.tr(true)
float emaVolume = ta.ema(volume, volEmaLength)
float ksiRaw = emaVolume > 0 ? (math.pow(trueRange, 2) / (volume * emaVolume)) : 0
float ksi = ksiRaw * 1000000
float signal = ta.ema(ksi, sigLength)

//Hist coloring
color histColor = ksi > signal ? color.new(color.green, 30) : color.new(color.red, 30)

//Draw
plot(ksi, title="KSI Histogram", color=histColor, style=plot.style_histogram, linewidth=2)
plot(signal, title="Signal Line", color=color.orange,  linewidth=1)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
hline(sigSpike, "Spike Line", color=color.orange, linestyle=hline.style_dashed)

//Alerts
bool isSpike = ta.crossover(ksi, sigSpike)
alertcondition(isSpike, title="KSI Anomalous Spike", message="KSI Alert! Anomalous volume/range divergence detected on {{exchange}}:{{ticker}}, TF: {{interval}}. Potential trend exhaustion or false breakout.")
````
