# CVD Divergence

- url: https://www.tradingview.com/script/rySqwsjc-CVD-Divergence/
- type: indicator
- pine_id: PUB;04bc9fa95bfc4a23913ec4a310936fb2
- version: 1.0

## Description

CVD Divergence highlights when price and Cumulative Volume Delta (CVD) disagree — a classic early warning that order-flow pressure is fading and a potential turning point may be forming.

How it works
The script builds a continuous CVD line by requesting lower-timeframe candles with request.security_lower_tf and summing their delta (up-volume minus down-volume) on every bar, without resetting per session. It then detects swing highs and lows (pivots) on the CVD line and compares each pivot to the previous one against the matching price pivot.

What it detects
- Regular Bullish — price makes a lower low while CVD makes a higher low (selling pressure fading).
- Regular Bearish — price makes a higher high while CVD makes a lower high (buying pressure fading).
- Hidden Bullish / Hidden Bearish — trend-continuation variants, off by default.

Each confirmed divergence is drawn as a line connecting the two CVD pivots, with a label (Bull / Bear / H Bull / H Bear). Four alert conditions are included so you can be notified automatically.

Settings
- Lower timeframe — resolution used to estimate delta (default 1 min).
- Pivot left / right length — swing sensitivity. Smaller values = more signals; larger = fewer but stronger.
- Min / Max pivot distance — allowed spacing between the two pivots being compared.
- Show Regular / Show Hidden — toggle each divergence family.

How to use
Treat divergences as context, not a standalone entry. They work best near support/resistance, prior highs/lows, or other confluence. Signals confirm only after the pivot's right-side bars complete, so they appear with an inherent delay and the latest swing may not be confirmed yet.

Notes & limitations
Standard chart data contains no true bid/ask tick information, so delta is approximated from lower-timeframe candle direction. Results are most reliable on liquid instruments with genuine volume (futures, crypto, major equities) and on intraday timeframes — on high timeframes the available lower-timeframe history is limited. For analysis and educational purposes only; not financial advice.

## Source Code

````pine
//@version=6
indicator("CVD Divergence", overlay = false, format = format.volume, precision = 0)

// ── 輸入 ──
lowerTf  = input.timeframe("1", "計算用較低時框",        group = "CVD")
lbL      = input.int(5,  "Pivot 左側長度", minval = 1,   group = "背離設定")
lbR      = input.int(5,  "Pivot 右側長度", minval = 1,   group = "背離設定")
rangeMax = input.int(60, "兩 Pivot 最大間隔", minval = 5, group = "背離設定")
rangeMin = input.int(5,  "兩 Pivot 最小間隔", minval = 1, group = "背離設定")
showReg  = input.bool(true,  "顯示常規背離 (Regular)",  group = "顯示")
showHid  = input.bool(false, "顯示隱藏背離 (Hidden)",   group = "顯示")

// ── 取得連續 CVD(不重置)──
[ltfO, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, lowerTf, [open, close, volume])
calcDelta() =>
    float d = 0.0
    if array.size(ltfC) > 0
        for i = 0 to array.size(ltfC) - 1
            o = array.get(ltfO, i)
            c = array.get(ltfC, i)
            v = array.get(ltfV, i)
            d += c > o ? v : c < o ? -v : 0.0
    d
var float cvd = 0.0
cvd := cvd + calcDelta()
osc = cvd

plot(osc, "CVD", color = color.new(color.gray, 0), linewidth = 2)
hline(0, color = color.new(color.gray, 50), linestyle = hline.style_dashed)

// ── Pivot 偵測(在 CVD 上)──
ph = ta.pivothigh(osc, lbL, lbR)
pl = ta.pivotlow(osc, lbL, lbR)
plFound = not na(pl)
phFound = not na(ph)

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeMin <= bars and bars <= rangeMax

// ── 背離判斷 ──
// 常規多頭:價格更低低點、CVD 更高低點
oscHL    = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceLL  = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCond = showReg and priceLL and oscHL and plFound

// 隱藏多頭:價格更高低點、CVD 更低低點
oscLL          = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL        = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCond = showHid and priceHL and oscLL and plFound

// 常規空頭:價格更高高點、CVD 更低高點
oscLH    = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceHH  = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCond = showReg and priceHH and oscLH and phFound

// 隱藏空頭:價格更低高點、CVD 更高高點
oscHH          = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH        = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCond = showHid and priceLH and oscHH and phFound

// ── 畫線 + 標籤 ──
bullCol = color.green, hBullCol = color.new(color.green, 40)
bearCol = color.red,   hBearCol = color.new(color.red, 40)

plot(plFound ? osc[lbR] : na, "多頭線",   offset = -lbR, color = bullCond       ? bullCol  : na, linewidth = 2)
plot(plFound ? osc[lbR] : na, "隱藏多頭線", offset = -lbR, color = hiddenBullCond ? hBullCol : na, linewidth = 2)
plot(phFound ? osc[lbR] : na, "空頭線",   offset = -lbR, color = bearCond       ? bearCol  : na, linewidth = 2)
plot(phFound ? osc[lbR] : na, "隱藏空頭線", offset = -lbR, color = hiddenBearCond ? hBearCol : na, linewidth = 2)

plotshape(bullCond       ? osc[lbR] : na, "多頭",   shape.labelup,   location.absolute, bullCol,  offset = -lbR, text = "Bull",   textcolor = color.white, size = size.tiny)
plotshape(hiddenBullCond ? osc[lbR] : na, "隱藏多頭", shape.labelup,   location.absolute, hBullCol, offset = -lbR, text = "H Bull", textcolor = color.white, size = size.tiny)
plotshape(bearCond       ? osc[lbR] : na, "空頭",   shape.labeldown, location.absolute, bearCol,  offset = -lbR, text = "Bear",   textcolor = color.white, size = size.tiny)
plotshape(hiddenBearCond ? osc[lbR] : na, "隱藏空頭", shape.labeldown, location.absolute, hBearCol, offset = -lbR, text = "H Bear", textcolor = color.white, size = size.tiny)

// ── 警報 ──
alertcondition(bullCond,       "CVD 常規多頭背離", "CVD 常規多頭背離")
alertcondition(bearCond,       "CVD 常規空頭背離", "CVD 常規空頭背離")
alertcondition(hiddenBullCond, "CVD 隱藏多頭背離", "CVD 隱藏多頭背離")
alertcondition(hiddenBearCond, "CVD 隱藏空頭背離", "CVD 隱藏空頭背離")
````
