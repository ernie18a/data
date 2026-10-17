# SMA+ADX Filter[yusufk]

- url: https://www.tradingview.com/script/C7FtUAcd-SMA-ADX-Filter-yusufk/
- type: indicator
- pine_id: PUB;f3c74cde571a4830a9c8b92281d14c7b
- version: 2.0

## Description

A simple SMA 25 cross indicator with optional ADX filter for momentum confirmation. BUY and SELL signals are generated on candle close to help reduce false signals in sideways market conditions.

Thanks,
yusufk

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at [https://mozilla.org/MPL/2.0/](https://mozilla.org/MPL/2.0/)
// © iping99
//@version=6
indicator("MA+ADX+LongPeriodFilter[yusufk]", overlay=true)

// ==========================================
// 1. INPUT PARAMETER
// ==========================================
// MA Utama
maType = input.string("SMA", title="Tipe MA Utama", options=["SMA", "EMA"], group="Main MA")
maLength = input.int(25, title="Panjang MA", group="Main MA")

// Filter ADX
useAdxFilter = input.bool(false, title="Gunakan Filter ADX (Deteksi Sideways)?", group="Filter ADX")
adxLen = input.int(14, title="ADX Length", group="Filter ADX")
adxThreshold = input.float(22.0, title="Batas Minimum ADX", group="Filter ADX")

// Filter Long Period MA
useLongFilter = input.bool(true, title="Gunakan Filter Long Period?", group="Filter Long Period")
longMaType = input.string("EMA", title="Tipe Long Period MA", options=["SMA", "EMA"], group="Filter Long Period")
longMaLength = input.int(100, title="Panjang Long Period", minval=1, group="Filter Long Period")

// ==========================================
// 2. PERHITUNGAN ADX
// ==========================================
trueRange = math.max(math.max(high - low, math.abs(high - nz(close[1]))), math.abs(low - nz(close[1])))
directionalMovementPlus = high - nz(high[1]) > nz(low[1]) - low ? math.max(high - nz(high[1]), 0) : 0
directionalMovementMinus = nz(low[1]) - low > high - nz(high[1]) ? math.max(nz(low[1]) - low, 0) : 0

var float smoothedTrueRange = 0.0
smoothedTrueRange := nz(smoothedTrueRange[1]) - (nz(smoothedTrueRange[1]) / adxLen) + trueRange

var float smoothedDirectionalMovementPlus = 0.0
smoothedDirectionalMovementPlus := nz(smoothedDirectionalMovementPlus[1]) - (nz(smoothedDirectionalMovementPlus[1]) / adxLen) + directionalMovementPlus

var float smoothedDirectionalMovementMinus = 0.0
smoothedDirectionalMovementMinus := nz(smoothedDirectionalMovementMinus[1]) - (nz(smoothedDirectionalMovementMinus[1]) / adxLen) + directionalMovementMinus

diPlus = smoothedDirectionalMovementPlus / smoothedTrueRange * 100
diMinus = smoothedDirectionalMovementMinus / smoothedTrueRange * 100
dx = math.abs(diPlus - diMinus) / (diPlus + diMinus) * 100
adx = ta.sma(dx, adxLen)

// Logika Filter ADX
adxFilter = useAdxFilter ? (adx >= adxThreshold) : true

// ==========================================
// 3. PERHITUNGAN MA UTAMA & LONG PERIOD MA
// ==========================================
// Kalkulasi dinamis berdasarkan pilihan dropdown pengguna
maValue = maType == "SMA" ? ta.sma(close, maLength) : ta.ema(close, maLength)
maColor = close > maValue ? color.green : color.red
plot(maValue, color=maColor, title="Garis MA Utama", linewidth=2)

longMaValue = longMaType == "SMA" ? ta.sma(close, longMaLength) : ta.ema(close, longMaLength)

// Plot Long Period MA hanya jika enable
plot(useLongFilter ? longMaValue : na, title="Long Period MA", color=color.orange, linewidth=2)

// ==========================================
// 4. LOGIKA FILTER LONG PERIOD MA
// ==========================================
// Buy hanya jika close di atas Long Period MA
longBuyFilter = useLongFilter ? close > longMaValue : true

// Sell hanya jika close di bawah Long Period MA
longSellFilter = useLongFilter ? close < longMaValue : true

// ==========================================
// 5. LOGIKA SINYAL DASAR
// ==========================================
// Cross MA utama dengan harga
buyLogic = ta.crossover(close, maValue)
sellLogic = ta.crossunder(close, maValue)

// Kombinasi sinyal
buyCondition = buyLogic and adxFilter and longBuyFilter
sellCondition = sellLogic and adxFilter and longSellFilter

// ==========================================
// 6. PLOT SIGNAL
// ==========================================
plotshape(series=buyCondition, title="Buy Signal", text="B", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(series=sellCondition, title="Sell Signal", text="S", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

// ==========================================
// 7. ALERT REALTIME SAAT CANDLE CLOSE
// ==========================================
buyAlertCondition = buyCondition and barstate.isconfirmed
sellAlertCondition = sellCondition and barstate.isconfirmed

alertcondition(buyAlertCondition, title="Buy Signal", message="Buy Signal")
alertcondition(sellAlertCondition, title="Sell Signal", message="Sell Signal")
````
