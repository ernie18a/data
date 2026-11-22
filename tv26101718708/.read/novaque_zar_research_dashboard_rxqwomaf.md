# Novaque ZAR Research Dashboard

- url: https://www.tradingview.com/script/rXqWOmaf-Novaque-ZAR-Research-Dashboard/
- type: indicator
- pine_id: PUB;742209cdeb4c4165952fba725efdbe14
- version: 1.0

## Description

Novaque ZAR Research Dashboard — Indicator Summary

The Novaque ZAR Research Dashboard is a TradingView indicator designed to help traders analyse South African rand currency pairs such as **USD/ZAR, EUR/ZAR, GBP/ZAR and other ZAR crosses** using a systematic multi-factor framework.

The indicator combines trend, momentum, volatility and risk-pressure signals into a single dashboard view. It is intended to support discretionary and systematic FX analysis by giving traders a clearer view of whether a ZAR pair is showing rand strength, rand weakness, or a mixed/neutral setup.

What the Indicator Shows

The dashboard includes:

* EMA trend structure using 21, 55 and 200-period exponential moving averages.
* Bollinger Bands to assess price extension, compression and mean-reversion zones.
* RSI to measure momentum strength or exhaustion.
* MACD histogram to track directional momentum.
* 20-bar and 60-bar momentum to compare short-term and medium-term price pressure.
* Realised volatility to assess whether market conditions are becoming more unstable.
* ATR percentage to measure current trading range relative to price.
* 20-bar drawdown to show how far price has pulled back from its recent high.
* Bullish/Bearish score that converts the indicator readings into a single market bias.

How to Read the Score

The score ranges from 0 to 100.

For USD/ZAR:

* Score above 70: Bullish USD/ZAR, indicating potential ZAR weakness.
* Score below 30: Bearish USD/ZAR, indicating potential ZAR support or rand strength.
* Score between 30 and 70: Neutral or mixed conditions.

The signal should not be used as a blind buy or sell trigger. It is best used as a market regime and trade-filtering tool.

How to Use It

1. Open a ZAR currency pair on TradingView, such as `OANDA:USDZAR`.
2. Apply the Novaque ZAR Research Dashboard indicator to the chart.
3. Start on the daily or 4-hour timeframe to establish the broader bias.
4. Move down to the 1-hour or 15-minute timeframe to look for execution opportunities.
5. Use the dashboard score to confirm whether price action, momentum and volatility are aligned.
6. Avoid trades when the score is neutral and the chart structure is unclear.
7. Use the EMAs, Bollinger Bands, support/resistance and market structure to define entries, invalidation and risk-reward.

Practical Trading Interpretation

A strong setup usually requires alignment between:

* Price trading above or below key EMAs.
* Momentum confirming the direction.
* MACD histogram supporting the move.
* RSI not showing extreme exhaustion.
* Volatility expanding in the direction of the trade.
* A clear market structure break, pullback or continuation setup.

For example, if USD/ZAR is below the 21, 55 and 200 EMAs, momentum is negative, and the score is below 30, the dashboard is suggesting ZAR support / USD/ZAR downside pressure. A trader could then look for bearish continuation setups, provided the risk-reward and invalidation level are clear.

If USD/ZAR is above the major EMAs, momentum is positive, and the score is above 70, the dashboard is suggesting ZAR pressure / USD/ZAR upside pressure. A trader could then look for long continuation setups after pullbacks or breakouts.

Important Notes

This indicator does not predict the future. It is a structured decision-support tool that helps traders assess whether market conditions are aligned. It should be used alongside macro context, liquidity levels, session timing, risk management and proper position sizing.

The indicator works best when used as part of a repeatable process:

Higher-timeframe bias → lower-timeframe setup → defined entry → clear invalidation → controlled risk.

Best Timeframes

Recommended timeframes:

* Daily: macro and swing bias.
* 4H: directional structure.
* 1H: tactical trade planning.
* 15M: entry refinement.

The dashboard can be applied to any FX pair, but the interpretation is specifically designed for ZAR-related pairs, especially pairs quoted as foreign currency versus rand, such as USD/ZAR, EUR/ZAR and GBP/ZAR.

## Source Code

````pine
//@version=6
indicator("Novaque ZAR Research Dashboard", overlay=true, max_lines_count=500, max_labels_count=100)

// ============================================================
// INPUTS
// ============================================================

emaFastLen   = input.int(21,  "EMA Fast", minval=1)
emaMidLen    = input.int(55,  "EMA Medium", minval=1)
emaSlowLen   = input.int(200, "EMA Slow", minval=1)

rsiLen       = input.int(14, "RSI Length", minval=1)
macdFastLen  = input.int(12, "MACD Fast", minval=1)
macdSlowLen  = input.int(26, "MACD Slow", minval=1)
macdSigLen   = input.int(9,  "MACD Signal", minval=1)

bbLen        = input.int(20, "Bollinger Length", minval=2)
bbMult       = input.float(2.0, "Bollinger Multiplier", step=0.1)

atrLen       = input.int(14, "ATR Length", minval=1)
volLen       = input.int(20, "Realised Vol Lookback", minval=2)
momFastLen   = input.int(20, "Momentum Fast Lookback", minval=1)
momSlowLen   = input.int(60, "Momentum Slow Lookback", minval=1)

showEMAs     = input.bool(true, "Show EMAs")
showBB       = input.bool(true, "Show Bollinger Bands")
showTable    = input.bool(true, "Show Research Table")
showCone     = input.bool(true, "Show Probability Cone")

coneLookback = input.int(252, "Cone Lookback Bars", minval=30)
coneBars     = input.int(30, "Cone Forecast Bars", minval=5, maxval=100)
useDrift     = input.bool(true, "Use Drift in Cone")

// Optional macro overlays from TradingView symbols
useMacro     = input.bool(false, "Use Macro Overlay in Score")
usdIndexSym  = input.symbol("TVC:DXY", "USD Index Symbol")
us10ySym     = input.symbol("TVC:US10Y", "US 10Y Yield Symbol")
vixSym       = input.symbol("CBOE:VIX", "VIX Symbol")

// ============================================================
// CORE INDICATORS
// ============================================================

ema21  = ta.ema(close, emaFastLen)
ema55  = ta.ema(close, emaMidLen)
ema200 = ta.ema(close, emaSlowLen)

rsi14 = ta.rsi(close, rsiLen)

[macdLine, macdSignal, macdHist] = ta.macd(close, macdFastLen, macdSlowLen, macdSigLen)

bbMid   = ta.sma(close, bbLen)
bbDev   = bbMult * ta.stdev(close, bbLen)
bbUpper = bbMid + bbDev
bbLower = bbMid - bbDev
bbPct   = (close - bbLower) / math.max(bbUpper - bbLower, syminfo.mintick)

atr14  = ta.atr(atrLen)
atrPct = atr14 / close

logRet = math.log(close / close[1])
realisedVol20 = ta.stdev(logRet, volLen) * math.sqrt(252)

mom20 = close / close[momFastLen] - 1
mom60 = close / close[momSlowLen] - 1

drawdown20 = close / ta.highest(close, 20) - 1

// ============================================================
// OPTIONAL MACRO DATA
// ============================================================

usdIndex = request.security(usdIndexSym, timeframe.period, close)
us10y    = request.security(us10ySym, timeframe.period, close)
vix      = request.security(vixSym, timeframe.period, close)

usdChange20 = usdIndex / usdIndex[20] - 1
us10yChange20 = us10y / us10y[20] - 1
vixChange20 = vix / vix[20] - 1

// ============================================================
// SCORE ENGINE
// 0 = bearish USD/ZAR / ZAR support
// 50 = neutral
// 100 = bullish USD/ZAR / ZAR pressure
// ============================================================

float score = 50.0

// Trend
score += close > ema21 ? 7 : -7
score += ema21 > ema55 ? 7 : -7
score += close > ema200 ? 10 : -10

// Momentum
score += mom20 > 0 ? 6 : -6
score += mom60 > 0 ? 6 : -6

// MACD
score += macdLine > macdSignal ? 8 : -8

// RSI
if rsi14 > 70
    score += 5
else if rsi14 > 55
    score += 6
else if rsi14 < 30
    score -= 5
else if rsi14 < 45
    score -= 6

// Bollinger position
if bbPct > 0.8
    score += 4
else if bbPct < 0.2
    score -= 4

// Volatility pressure
medianVol = ta.sma(realisedVol20, 252)

if realisedVol20 > medianVol * 1.25
    score += 3
else if realisedVol20 < medianVol * 0.75
    score -= 2

// Optional macro overlay
if useMacro
    score += usdChange20 > 0 ? 3 : usdChange20 < 0 ? -3 : 0
    score += us10yChange20 > 0 ? 3 : us10yChange20 < 0 ? -3 : 0
    score += vixChange20 > 0 ? 3 : vixChange20 < 0 ? -3 : 0

score := math.max(0, math.min(100, score))

string signalLabel = score >= 70 ? "Bullish USD/ZAR / ZAR pressure" :
     score <= 30 ? "Bearish USD/ZAR / ZAR support" :
     "Neutral / mixed"

color scoreColor = score >= 70 ? color.new(color.red, 0) :
     score <= 30 ? color.new(color.green, 0) :
     color.new(color.orange, 0)

// ============================================================
// PLOTS
// ============================================================

plot(showEMAs ? ema21 : na,  "EMA 21",  linewidth=2)
plot(showEMAs ? ema55 : na,  "EMA 55",  linewidth=2)
plot(showEMAs ? ema200 : na, "EMA 200", linewidth=2)

plot(showBB ? bbUpper : na, "BB Upper", linewidth=1)
plot(showBB ? bbMid : na,   "BB Mid", linewidth=1)
plot(showBB ? bbLower : na, "BB Lower", linewidth=1)

barcolor(score >= 70 ? color.new(color.red, 70) : score <= 30 ? color.new(color.green, 70) : na)

// ============================================================
// PROBABILITY CONE
// Pine cannot project true business days like Python,
// but can project future chart bars.
// ============================================================

var line[] coneLines = array.new_line()

if barstate.islast and showCone
    while array.size(coneLines) > 0
        line.delete(array.pop(coneLines))

    meanRet = ta.sma(logRet, coneLookback)
    devRet = ta.stdev(logRet, coneLookback)
    anchor = close

    for i = 1 to coneBars
        drift = useDrift ? meanRet * i : 0.0
        sqrtI = math.sqrt(i)

        meanPrice = anchor * math.exp(drift)
        upper1 = anchor * math.exp(drift + devRet * sqrtI)
        lower1 = anchor * math.exp(drift - devRet * sqrtI)
        upper2 = anchor * math.exp(drift + 2 * devRet * sqrtI)
        lower2 = anchor * math.exp(drift - 2 * devRet * sqrtI)

        if i > 1
            prevDrift = useDrift ? meanRet * (i - 1) : 0.0
            prevSqrtI = math.sqrt(i - 1)

            prevMean = anchor * math.exp(prevDrift)
            prevUpper1 = anchor * math.exp(prevDrift + devRet * prevSqrtI)
            prevLower1 = anchor * math.exp(prevDrift - devRet * prevSqrtI)
            prevUpper2 = anchor * math.exp(prevDrift + 2 * devRet * prevSqrtI)
            prevLower2 = anchor * math.exp(prevDrift - 2 * devRet * prevSqrtI)

            array.push(coneLines, line.new(bar_index + i - 1, prevMean,   bar_index + i, meanPrice, color=color.new(color.gray, 0), width=2))
            array.push(coneLines, line.new(bar_index + i - 1, prevUpper1, bar_index + i, upper1,    color=color.new(color.red, 20), width=1))
            array.push(coneLines, line.new(bar_index + i - 1, prevLower1, bar_index + i, lower1,    color=color.new(color.green, 20), width=1))
            array.push(coneLines, line.new(bar_index + i - 1, prevUpper2, bar_index + i, upper2,    color=color.new(color.red, 50), width=1))
            array.push(coneLines, line.new(bar_index + i - 1, prevLower2, bar_index + i, lower2,    color=color.new(color.green, 50), width=1))

// ============================================================
// DASHBOARD TABLE
// ============================================================

var table dash = table.new(position.top_right, 2, 11, border_width=1)

if barstate.islast and showTable
    table.cell(dash, 0, 0, "Novaque ZAR Dashboard", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "Score", text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(score, "#.0"), text_color=color.white, bgcolor=scoreColor)

    table.cell(dash, 0, 2, "Signal", text_color=color.white)
    table.cell(dash, 1, 2, signalLabel, text_color=color.white, bgcolor=scoreColor)

    table.cell(dash, 0, 3, "Close", text_color=color.white)
    table.cell(dash, 1, 3, str.tostring(close, format.mintick), text_color=color.white)

    table.cell(dash, 0, 4, "RSI", text_color=color.white)
    table.cell(dash, 1, 4, str.tostring(rsi14, "#.0"), text_color=color.white)

    table.cell(dash, 0, 5, "MACD Hist", text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(macdHist, "#.0000"), text_color=color.white)

    table.cell(dash, 0, 6, "20-Bar Momentum", text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(mom20 * 100, "#.00") + "%", text_color=color.white)

    table.cell(dash, 0, 7, "60-Bar Momentum", text_color=color.white)
    table.cell(dash, 1, 7, str.tostring(mom60 * 100, "#.00") + "%", text_color=color.white)

    table.cell(dash, 0, 8, "Realised Vol", text_color=color.white)
    table.cell(dash, 1, 8, str.tostring(realisedVol20 * 100, "#.00") + "%", text_color=color.white)

    table.cell(dash, 0, 9, "ATR %", text_color=color.white)
    table.cell(dash, 1, 9, str.tostring(atrPct * 100, "#.00") + "%", text_color=color.white)

    table.cell(dash, 0, 10, "20-Bar Drawdown", text_color=color.white)
    table.cell(dash, 1, 10, str.tostring(drawdown20 * 100, "#.00") + "%", text_color=color.white)
````
