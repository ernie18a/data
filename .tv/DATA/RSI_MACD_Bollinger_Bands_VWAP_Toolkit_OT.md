<!-- tradingview-pine-id: PUB;e883fe326adc420ba2598541769a7ddf -->
<!-- tradingviewscripts-format: 1 -->
# RSI MACD + Bollinger Bands & VWAP Toolkit [OT]

Source: https://www.tradingview.com/script/je4VVPoN/

## Description

This indicator combines RSI, MACD, Bollinger Bands, VWAP, and a simple momentum status table into one clean toolkit.

It is designed to help traders check momentum, volatility, and intraday price position without adding multiple separate indicators to the chart.

Main features:
- RSI with 70 / 50 / 30 reference levels
- Normalized MACD histogram in the RSI panel
- Optional MACD signal lines
- Bollinger Bands displayed on the main chart
- Session VWAP displayed on the main chart
- Momentum background based on RSI, MACD, and VWAP conditions
- Status table showing Bias, Score, RSI, MACD, and Volatility

Default settings:
- RSI: 14 period
- MACD: 12 / 26 / 9
- Bollinger Bands: 20 period, 2 standard deviations
- VWAP: Session VWAP, hidden on daily or higher timeframes by default
- Momentum Score: 0 to 3 based on RSI position, MACD signal, and MACD histogram

This indicator does not generate automatic buy or sell signals. It is intended as a visual reference tool for trend, momentum, volatility, and market condition analysis. Please use it together with your own strategy, risk management, and other forms of analysis.

이 지표는 RSI, MACD, 볼린저 밴드, VWAP, 모멘텀 상태표를 하나로 합친 깔끔한 트레이딩 툴킷입니다.

여러 개의 지표를 따로 추가하지 않아도 모멘텀, 변동성, 장중 가격 위치를 한 화면에서 확인할 수 있도록 제작했습니다.

주요 기능:
- RSI 70 / 50 / 30 기준선
- RSI 패널 안에 정규화된 MACD 히스토그램 표시
- 선택 가능한 MACD 시그널 라인
- 메인 차트 위 볼린저 밴드 표시
- 메인 차트 위 세션 VWAP 표시
- RSI, MACD, VWAP 조건을 기반으로 한 모멘텀 배경색
- Bias, Score, RSI, MACD, Volatility 상태표 제공

기본 설정:
- RSI: 14 기간
- MACD: 12 / 26 / 9
- Bollinger Bands: 20 기간, 표준편차 2
- VWAP: 세션 VWAP, 기본적으로 일봉 이상에서는 숨김
- Momentum Score: RSI 위치, MACD 시그널, MACD 히스토그램 기준으로 0~3점 표시

이 지표는 자동 매수/매도 신호를 제공하지 않습니다. 추세, 모멘텀, 변동성, 시장 상태를 시각적으로 참고하기 위한 도구이며, 본인의 전략과 리스크 관리, 다른 분석과 함께 사용하는 것을 권장합니다.

---

## Source Code

````pine
//@version=6
indicator(title="RSI MACD + Bollinger Bands & VWAP Toolkit [OT]", shorttitle="RSI MACD BB VWAP", overlay=false)
// Display
groupDisplay = "Display"
showRSI       = input.bool(true, "Show RSI", group=groupDisplay)
showMACDHist  = input.bool(true, "Show MACD Histogram", group=groupDisplay)
showMACDLines = input.bool(false, "Show MACD Lines", group=groupDisplay)
showBB        = input.bool(true, "Show Bollinger Bands on Chart", group=groupDisplay)
showVWAP      = input.bool(true, "Show Session VWAP on Chart", group=groupDisplay)
showTrendBg   = input.bool(true, "Show Momentum Background", group=groupDisplay)
showTable     = input.bool(true, "Show Status Table", group=groupDisplay)
src = input.source(close, "Source")
// RSI
groupRSI = "RSI"
rsiLen = input.int(14, "RSI Length", minval=1, group=groupRSI)
rsiOB  = input.float(70.0, "Overbought", group=groupRSI)
rsiOS  = input.float(30.0, "Oversold", group=groupRSI)
rsiValue = ta.rsi(src, rsiLen)
rsiColor = rsiValue >= rsiOB ? color.rgb(255, 80, 80) : rsiValue <= rsiOS ? color.rgb(0, 210, 130) : rsiValue >= 50 ? color.rgb(255, 230, 0) : color.rgb(120, 180, 255)
hline(rsiOB, "RSI Overbought", color=color.new(color.red, 70), linestyle=hline.style_dashed)
hline(50, "RSI Middle", color=color.new(color.gray, 70))
hline(rsiOS, "RSI Oversold", color=color.new(color.green, 70), linestyle=hline.style_dashed)
plot(showRSI ? rsiValue : na, title="RSI", color=rsiColor, linewidth=2)
// MACD, normalized to share the RSI pane.
groupMACD = "MACD"
macdFast    = input.int(12, "Fast Length", minval=1, group=groupMACD)
macdSlow    = input.int(26, "Slow Length", minval=1, group=groupMACD)
macdSignal  = input.int(9, "Signal Length", minval=1, group=groupMACD)
macdNormLen = input.int(100, "Normalization Lookback", minval=20, group=groupMACD)
[macdLine, signalLine, histLine] = ta.macd(src, macdFast, macdSlow, macdSignal)
macdLineMax   = nz(ta.highest(math.abs(macdLine), macdNormLen))
signalLineMax = nz(ta.highest(math.abs(signalLine), macdNormLen))
histLineMax   = nz(ta.highest(math.abs(histLine), macdNormLen))
macdScale     = math.max(macdLineMax, signalLineMax)
macdNorm   = macdScale != 0.0 ? 50.0 + macdLine / macdScale * 20.0 : 50.0
signalNorm = macdScale != 0.0 ? 50.0 + signalLine / macdScale * 20.0 : 50.0
histNorm   = histLineMax != 0.0 ? 50.0 + histLine / histLineMax * 20.0 : 50.0
histColor = histLine >= 0 ? histLine > histLine[1] ? color.rgb(0, 210, 130) : color.rgb(90, 170, 130) : histLine < histLine[1] ? color.rgb(255, 80, 80) : color.rgb(210, 130, 120)
plot(showMACDHist ? histNorm : na, title="MACD Histogram", style=plot.style_columns, histbase=50, color=color.new(histColor, 25))
plot(showMACDLines ? macdNorm : na, title="MACD Line", color=color.rgb(0, 170, 255), linewidth=2)
plot(showMACDLines ? signalNorm : na, title="MACD Signal", color=color.rgb(255, 170, 0), linewidth=2)
// Optional chart overlays
groupOverlay = "Optional Chart Overlays"
bbLen   = input.int(20, "BB Length", minval=1, group=groupOverlay)
bbMult  = input.float(2.0, "BB StdDev", minval=0.1, step=0.1, group=groupOverlay)
bbColor = input.color(color.rgb(120, 170, 255), "BB Color", group=groupOverlay)
bbBasis = ta.sma(src, bbLen)
bbDev   = bbMult * ta.stdev(src, bbLen)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
bbWidthPct = not na(bbBasis) and bbBasis != 0.0 ? (bbUpper - bbLower) / bbBasis * 100.0 : na
bbWidthAvg = ta.sma(bbWidthPct, 100)
bbU = plot(showBB ? bbUpper : na, title="BB Upper", color=color.new(bbColor, 35), linewidth=1, style=plot.style_linebr, force_overlay=true)
bbM = plot(showBB ? bbBasis : na, title="BB Basis", color=color.new(bbColor, 10), linewidth=1, style=plot.style_linebr, force_overlay=true)
bbL = plot(showBB ? bbLower : na, title="BB Lower", color=color.new(bbColor, 35), linewidth=1, style=plot.style_linebr, force_overlay=true)
fill(bbU, bbL, color=showBB ? color.new(bbColor, 94) : na, title="BB Fill")
vwapSrc        = input.source(hlc3, "VWAP Source", group=groupOverlay)
hideVWAPDaily  = input.bool(true, "Hide VWAP on Daily or Higher", group=groupOverlay)
vwapColor      = input.color(color.rgb(0, 220, 220), "VWAP Color", group=groupOverlay)
vwapValue      = ta.vwap(vwapSrc)
vwapVisible    = showVWAP and (not hideVWAPDaily or timeframe.isintraday)
newVWAPSession = timeframe.change("D")
vwapPlotValue  = vwapVisible and not newVWAPSession ? vwapValue : na
plot(vwapPlotValue, title="Session VWAP", color=vwapColor, linewidth=2, style=plot.style_linebr, force_overlay=true)
// Status logic
momentumScore = (rsiValue >= 50 ? 1 : 0) + (macdLine > signalLine ? 1 : 0) + (histLine > 0 ? 1 : 0)
bullBackground = momentumScore >= 2 and (not vwapVisible or na(vwapValue) or close >= vwapValue)
bearBackground = momentumScore <= 1 and (not vwapVisible or na(vwapValue) or close <= vwapValue)
bgcolor(showTrendBg ? bullBackground ? color.new(color.green, 92) : bearBackground ? color.new(color.red, 92) : na : na, title="Momentum Background", force_overlay=true)
biasText = momentumScore == 3 ? "Bullish" : momentumScore == 0 ? "Bearish" : momentumScore == 2 ? "Leaning Bull" : "Leaning Bear"
rsiText = rsiValue >= rsiOB ? "Overbought" : rsiValue <= rsiOS ? "Oversold" : rsiValue >= 50 ? "Bullish Zone" : "Bearish Zone"
macdText = macdLine > signalLine and histLine > 0 ? "Bullish" : macdLine < signalLine and histLine < 0 ? "Bearish" : "Neutral"
volText = na(bbWidthPct) or na(bbWidthAvg) ? "N/A" : bbWidthPct > bbWidthAvg ? "Expanding" : "Quiet"
bullColor    = color.rgb(0, 140, 90)
bearColor    = color.rgb(190, 60, 60)
neutralColor = color.rgb(70, 70, 70)
warmColor    = color.rgb(180, 120, 30)
headerColor  = color.rgb(35, 35, 35)
biasBg = momentumScore == 3 ? bullColor : momentumScore == 0 ? bearColor : neutralColor
rsiBg = rsiValue >= rsiOB ? bearColor : rsiValue <= rsiOS ? bullColor : rsiValue >= 50 ? bullColor : bearColor
macdBg = macdLine > signalLine and histLine > 0 ? bullColor : macdLine < signalLine and histLine < 0 ? bearColor : neutralColor
volBg = na(bbWidthPct) or na(bbWidthAvg) ? neutralColor : bbWidthPct > bbWidthAvg ? warmColor : neutralColor
// Status table
var table statusTable = table.new(position.top_right, 2, 6, border_width=1)
f_cell(row, label, value, bg) =>
    table.cell(statusTable, 0, row, label, text_color=color.white, bgcolor=color.new(color.black, 10), text_size=size.small)
    table.cell(statusTable, 1, row, value, text_color=color.white, bgcolor=bg, text_size=size.small)
if barstate.islast and showTable
    table.cell(statusTable, 0, 0, "RSI MACD Toolkit", text_color=color.white, bgcolor=headerColor, text_size=size.small)
    table.cell(statusTable, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=headerColor, text_size=size.small)
    f_cell(1, "Bias", biasText, biasBg)
    f_cell(2, "Score", str.tostring(momentumScore) + " / 3", biasBg)
    f_cell(3, "RSI", rsiText, rsiBg)
    f_cell(4, "MACD", macdText, macdBg)
    f_cell(5, "Volatility", volText, volBg)
// Alerts
alertcondition(momentumScore == 3 and momentumScore[1] < 3, title="Momentum Turns Bullish", message="Momentum score turned bullish.")
alertcondition(momentumScore == 0 and momentumScore[1] > 0, title="Momentum Turns Bearish", message="Momentum score turned bearish.")
alertcondition(ta.crossover(rsiValue, 50), title="RSI Crosses Above 50", message="RSI crossed above 50.")
alertcondition(ta.crossunder(rsiValue, 50), title="RSI Crosses Below 50", message="RSI crossed below 50.")
alertcondition(ta.crossover(macdLine, signalLine), title="MACD Bullish Cross", message="MACD crossed above the signal line.")
alertcondition(ta.crossunder(macdLine, signalLine), title="MACD Bearish Cross", message="MACD crossed below the signal line.")
````
