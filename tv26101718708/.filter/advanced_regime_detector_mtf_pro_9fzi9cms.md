# Advanced Regime Detector (MTF Pro)

- url: https://www.tradingview.com/script/9FZi9cms/
- type: indicator
- pine_id: PUB;1f2e6b91c6044c4b9a7cbaab5d962cfd
- version: 1.0

## Description

Regime detector based on DEMA 50 4H, Momentum (Current Time Frame), Volatility (ATR) (Daily Chart), Trend Strength (ADX)

Recommendation: Only trade green if 3 or 4 out of 4 indicators are positive

Suitable only for long swing strategies

## Source Code

````pine
//@version=5
indicator("Advanced Regime Detector (MTF Pro)", overlay=true)

// === INPUTS ===
demaLength = input.int(50, "DEMA Length")
adxLength = input.int(14, "ADX Length")
atrLength = input.int(14, "ATR Length")
adxThreshold = input.int(20, "ADX Threshold")

trendTF = input.timeframe("240", "Trend TF (4H)")
htfTF   = input.timeframe("D", "Volatility + ADX TF (Daily)")

// === FUNCTIONS ===
f_dema(src, len) =>
    ema1 = ta.ema(src, len)
    ema2 = ta.ema(ema1, len)
    2 * ema1 - ema2

f_adx(len) =>
    plusDM = ta.change(high)
    minusDM = -ta.change(low)
    plusDM := plusDM > minusDM and plusDM > 0 ? plusDM : 0
    minusDM := minusDM > plusDM and minusDM > 0 ? minusDM : 0
    tr = ta.rma(ta.tr(true), len)
    plusDI = 100 * ta.rma(plusDM, len) / tr
    minusDI = 100 * ta.rma(minusDM, len) / tr
    dx = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
    ta.rma(dx, len)

// === TREND (4H) ===
trend_close = request.security(syminfo.tickerid, trendTF, close)
trend_dema  = request.security(syminfo.tickerid, trendTF, f_dema(close, demaLength))

trendBull = trend_close > trend_dema
trendBear = trend_close < trend_dema

// === MOMENTUM (CURRENT TF) ===
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
momentumBull = macdLine > signalLine
momentumBear = macdLine < signalLine

// === VOLATILITY (DAILY) ===
d_atr = request.security(syminfo.tickerid, htfTF, ta.atr(atrLength))
d_atr_avg = request.security(syminfo.tickerid, htfTF, ta.sma(ta.atr(atrLength), 50))

volHigh = d_atr > d_atr_avg
volLow  = d_atr < d_atr_avg

// === TREND STRENGTH (DAILY ADX) ===
d_adx = request.security(syminfo.tickerid, htfTF, f_adx(adxLength))

strongTrend = d_adx > adxThreshold
weakTrend   = d_adx < adxThreshold

// === REGIME ===
var string regime = ""

if (trendBull and momentumBull and strongTrend and volHigh)
    regime := "STRONG TREND LONG"
else if (trendBear and momentumBear and strongTrend and volHigh)
    regime := "STRONG TREND SHORT"
else if (strongTrend and not volHigh)
    regime := "WEAK TREND"
else if (weakTrend and volLow)
    regime := "RANGE / CHOP"
else if (volHigh and weakTrend)
    regime := "VOLATILE CHAOS"
else
    regime := "UNCLEAR"

// === TABLE ===
var table t = table.new(position.top_right, 2, 6, border_width=1)

getColor(cond) =>
    cond ? color.green : color.red

if barstate.islast
    table.cell(t, 0, 0, "Factor", text_color=color.yellow, bgcolor=color.black)
    table.cell(t, 1, 0, "State", text_color=color.yellow, bgcolor=color.black)

    table.cell(t, 0, 1, "Trend (4H)", text_color=color.yellow)
    table.cell(t, 1, 1, trendBull ? "Bullish" : "Bearish", bgcolor=getColor(trendBull), text_color=color.yellow)

    table.cell(t, 0, 2, "Momentum", text_color=color.yellow)
    table.cell(t, 1, 2, momentumBull ? "Bullish" : "Bearish", bgcolor=getColor(momentumBull), text_color=color.yellow)

    table.cell(t, 0, 3, "Volatility (D)", text_color=color.yellow)
    table.cell(t, 1, 3, volHigh ? "High" : "Low", bgcolor=getColor(volHigh), text_color=color.yellow)

    table.cell(t, 0, 4, "Trend Strength (D)", text_color=color.yellow)
    table.cell(t, 1, 4, strongTrend ? "Strong" : "Weak", bgcolor=getColor(strongTrend), text_color=color.yellow)

    table.cell(t, 0, 5, "REGIME", text_color=color.yellow)
    table.cell(t, 1, 5, regime, bgcolor=color.orange, text_color=color.black)

// === OPTIONAL: DEMA PLOT ===
dema = f_dema(close, demaLength)
plot(dema, color=color.yellow, linewidth=2)
````
