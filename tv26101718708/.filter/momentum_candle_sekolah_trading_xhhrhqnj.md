# Momentum Candle Sekolah Trading

- url: https://www.tradingview.com/script/XhhRHQnj/
- type: indicator
- pine_id: PUB;b144dd65a6ba42fa9aaaf83da80e2a25
- version: 1.0

## Description

Momentum Candle Sekolah Trading
Overview
Momentum Candle is a technical indicator designed to detect strong momentum candles based on body size and wick ratio validation. It is built to help traders quickly identify whether a candle represents genuine bullish or bearish momentum, or merely noise — across multiple forex pairs and BTCUSD.
This indicator is an evolution of the previous Momentum Candle v3, with significant improvements including multi-pair support, EMA trend filter, consolidation validation, dual signal modes, and a time-based alert system.

How It Works
The indicator evaluates each candle using two core criteria:

Minimum Body Size — The candle body (|close − open|) must meet or exceed a user-defined minimum size (in pips), configured separately for each pair and each timeframe (M5, M15, M30).
Wick Ratio — The total wick length must not exceed a configurable percentage of the total candle range (body + wick). Default is 30%, meaning candles with excessive wicks are filtered out.


Signal Modes
Two signal modes are available via the "Mode Candle" input:

Agresif (Aggressive): A signal is generated when the body is large enough and the wick ratio is acceptable, regardless of wick direction. Suitable for traders who want more frequent signals.
Konservatif (Conservative): Adds an additional directional wick check — bullish signals require the lower wick to be smaller than the upper wick, and vice versa for bearish. This reduces noise and false signals.


Alert Modes
Two alert timing modes are available via the "Mode Alert" input:

Agresif: Alert fires immediately every bar when the signal condition is met.
Konservatif: Alert fires only in the 20–90 second window before candle close, reducing premature alerts caused by candles that may still change before closing.


Consolidation Validation (Optional)
When enabled, the indicator checks that the N previous candles (configurable, default 3) are each smaller in body size than the current signal candle. This helps confirm the signal appears after a period of lower volatility, adding context to the momentum reading.

EMA Trend Filter (Optional)
An EMA trend filter can be activated to restrict signals to the direction of the prevailing trend:

Bullish signals only appear when price is above the EMA.
Bearish signals only appear when price is below the EMA.
The EMA timeframe (M5, M15, M30, H1) and period are fully configurable. Recommended: M5=21, M15=50, M30=50, H1=100.
A live trend label (table, top-right) shows the current EMA trend direction.


Supported Pairs and Timeframes
Each pair can be enabled or disabled independently. Minimum body size is configurable per pair and per timeframe:
PairM5 DefaultM15 DefaultM30 DefaultXAUUSD35 pips45 pips55 pipsUSDJPY10 pips15 pips20 pipsGBPUSD10 pips15 pips20 pipsAUDUSD10 pips15 pips20 pipsUSDCAD10 pips15 pips20 pipsEURUSD10 pips15 pips20 pipsNZDUSD10 pips15 pips20 pipsUSDCHF10 pips15 pips20 pipsBTCUSD80 pips120 pips160 pips

Signals

🔵 Blue triangle (below bar): Bullish momentum signal
🔴 Red triangle (above bar): Bearish momentum signal


How to Use

Select your pair and enable it in the "Aktifkan Pair" section.
Adjust the minimum body size for your preferred timeframe.
Set the wick ratio threshold (default 30% is recommended as a starting point).
Choose between Aggressive or Conservative mode depending on your trading style.
Optionally enable the EMA filter for trend-confirmed signals only.
Optionally enable consolidation validation for breakout-style confirmation.
Set up alerts using the built-in alert conditions for both bullish and bearish, in either Aggressive or Conservative alert mode.


Important Notes

This indicator is a tool for technical analysis only. It does not guarantee trading results.
It is strongly recommended to combine this indicator with price action context, support/resistance levels, and proper risk management.
Past signal performance does not guarantee future results.
This script does not use security() with lookahead to access future data. The EMA from a higher timeframe uses barmerge.lookahead_off to prevent repainting.
This script does not use Heikin Ashi or non-standard chart types. It is designed for standard candlestick charts.

## Source Code

````pine
//@version=6
indicator("Momentum Candle Sekolah Trading", overlay=true)

// ===== 1. Mode =====
grpMode = "Mode"
modeCandle = input.string("Agresif", "Mode Candle",
     options=["Agresif", "Konservatif"],
     tooltip="Agresif: validasi body+wick saja\nKonservatif: tambah validasi arah wick",
     group=grpMode)
modeAlert = input.string("Agresif", "Mode Alert",
     options=["Agresif", "Konservatif"],
     tooltip="Agresif: alert langsung setiap bar\nKonservatif: alert hanya 20-90 detik sebelum candle close",
     group=grpMode)

// ===== 2. Validasi Ekor =====
grpWick = "Validasi Ekor"
wickPct = input.float(30.0, "Max Wick % dari Total Candle", group=grpWick,
     minval=1, maxval=99, step=1.0,
     tooltip="Berlaku di semua pair dan mode. Default 30%")

// ===== 3. Konsolidasi =====
grpKons   = "Validasi Konsolidasi"
useKons   = input.bool(false, "Aktifkan Validasi Konsolidasi", group=grpKons,
     tooltip="Sinyal hanya muncul jika candle sebelumnya lebih kecil dari candle momentum")
konsCount = input.int(3, "Jumlah Candle Konsolidasi", group=grpKons, minval=1, maxval=10)

// ===== 4. Filter Trend EMA =====
grpEMA = "Filter Trend EMA"
useEMA = input.bool(false, "Aktifkan Filter Trend EMA", group=grpEMA,
     tooltip="Jika aktif, sinyal hanya muncul sesuai arah trend EMA TF yang dipilih")
emaTF  = input.string("H1", "Timeframe EMA", options=["M5", "M15", "M30", "H1"], group=grpEMA)
emaLen = input.int(50, "EMA Period", group=grpEMA, minval=1,
     tooltip="Default 50. Rekomendasi: M5=21, M15=50, M30=50, H1=100. Bisa diadjust manual.")

// ===== 5. Pair On/Off =====
grpPair = "Aktifkan Pair"
useXAU = input.bool(true,  "XAUUSD", group=grpPair, inline="p1")
useJPY = input.bool(false, "USDJPY", group=grpPair, inline="p1")
useGBP = input.bool(false, "GBPUSD", group=grpPair, inline="p2")
useAUD = input.bool(false, "AUDUSD", group=grpPair, inline="p2")
useCAD = input.bool(false, "USDCAD", group=grpPair, inline="p3")
useEUR = input.bool(false, "EURUSD", group=grpPair, inline="p3")
useNZD = input.bool(false, "NZDUSD", group=grpPair, inline="p4")
useCHF = input.bool(false, "USDCHF", group=grpPair, inline="p4")
useBTC = input.bool(false, "BTCUSD", group=grpPair, inline="p5")

// ===== 6. Pip Input per Pair per TF =====
grpXAU     = "XAUUSD Min Body (pip)"
useXAU_M5  = input.bool(true,  "M5",  group=grpXAU, inline="xau1")
xauM5      = input.float(35,   "",    group=grpXAU, inline="xau1", minval=1)
useXAU_M15 = input.bool(true,  "M15", group=grpXAU, inline="xau2")
xauM15     = input.float(45,   "",    group=grpXAU, inline="xau2", minval=1)
useXAU_M30 = input.bool(true,  "M30", group=grpXAU, inline="xau3")
xauM30     = input.float(55,   "",    group=grpXAU, inline="xau3", minval=1)

grpJPY     = "USDJPY Min Body (pip)"
useJPY_M5  = input.bool(true,  "M5",  group=grpJPY, inline="jpy1")
jpyM5      = input.float(10,   "",    group=grpJPY, inline="jpy1", minval=1)
useJPY_M15 = input.bool(true,  "M15", group=grpJPY, inline="jpy2")
jpyM15     = input.float(15,   "",    group=grpJPY, inline="jpy2", minval=1)
useJPY_M30 = input.bool(true,  "M30", group=grpJPY, inline="jpy3")
jpyM30     = input.float(20,   "",    group=grpJPY, inline="jpy3", minval=1)

grpGBP     = "GBPUSD Min Body (pip)"
useGBP_M5  = input.bool(true,  "M5",  group=grpGBP, inline="gbp1")
gbpM5      = input.float(10,   "",    group=grpGBP, inline="gbp1", minval=1)
useGBP_M15 = input.bool(true,  "M15", group=grpGBP, inline="gbp2")
gbpM15     = input.float(15,   "",    group=grpGBP, inline="gbp2", minval=1)
useGBP_M30 = input.bool(true,  "M30", group=grpGBP, inline="gbp3")
gbpM30     = input.float(20,   "",    group=grpGBP, inline="gbp3", minval=1)

grpAUD     = "AUDUSD Min Body (pip)"
useAUD_M5  = input.bool(true,  "M5",  group=grpAUD, inline="aud1")
audM5      = input.float(10,   "",    group=grpAUD, inline="aud1", minval=1)
useAUD_M15 = input.bool(true,  "M15", group=grpAUD, inline="aud2")
audM15     = input.float(15,   "",    group=grpAUD, inline="aud2", minval=1)
useAUD_M30 = input.bool(true,  "M30", group=grpAUD, inline="aud3")
audM30     = input.float(20,   "",    group=grpAUD, inline="aud3", minval=1)

grpCAD     = "USDCAD Min Body (pip)"
useCAD_M5  = input.bool(true,  "M5",  group=grpCAD, inline="cad1")
cadM5      = input.float(10,   "",    group=grpCAD, inline="cad1", minval=1)
useCAD_M15 = input.bool(true,  "M15", group=grpCAD, inline="cad2")
cadM15     = input.float(15,   "",    group=grpCAD, inline="cad2", minval=1)
useCAD_M30 = input.bool(true,  "M30", group=grpCAD, inline="cad3")
cadM30     = input.float(20,   "",    group=grpCAD, inline="cad3", minval=1)

grpEUR     = "EURUSD Min Body (pip)"
useEUR_M5  = input.bool(true,  "M5",  group=grpEUR, inline="eur1")
eurM5      = input.float(10,   "",    group=grpEUR, inline="eur1", minval=1)
useEUR_M15 = input.bool(true,  "M15", group=grpEUR, inline="eur2")
eurM15     = input.float(15,   "",    group=grpEUR, inline="eur2", minval=1)
useEUR_M30 = input.bool(true,  "M30", group=grpEUR, inline="eur3")
eurM30     = input.float(20,   "",    group=grpEUR, inline="eur3", minval=1)

grpNZD     = "NZDUSD Min Body (pip)"
useNZD_M5  = input.bool(true,  "M5",  group=grpNZD, inline="nzd1")
nzdM5      = input.float(10,   "",    group=grpNZD, inline="nzd1", minval=1)
useNZD_M15 = input.bool(true,  "M15", group=grpNZD, inline="nzd2")
nzdM15     = input.float(15,   "",    group=grpNZD, inline="nzd2", minval=1)
useNZD_M30 = input.bool(true,  "M30", group=grpNZD, inline="nzd3")
nzdM30     = input.float(20,   "",    group=grpNZD, inline="nzd3", minval=1)

grpCHF     = "USDCHF Min Body (pip)"
useCHF_M5  = input.bool(true,  "M5",  group=grpCHF, inline="chf1")
chfM5      = input.float(10,   "",    group=grpCHF, inline="chf1", minval=1)
useCHF_M15 = input.bool(true,  "M15", group=grpCHF, inline="chf2")
chfM15     = input.float(15,   "",    group=grpCHF, inline="chf2", minval=1)
useCHF_M30 = input.bool(true,  "M30", group=grpCHF, inline="chf3")
chfM30     = input.float(20,   "",    group=grpCHF, inline="chf3", minval=1)

grpBTC     = "BTCUSD Min Body (pip)"
useBTC_M5  = input.bool(true,  "M5",  group=grpBTC, inline="btc1")
btcM5      = input.float(80,   "",    group=grpBTC, inline="btc1", minval=1)
useBTC_M15 = input.bool(true,  "M15", group=grpBTC, inline="btc2")
btcM15     = input.float(120,  "",    group=grpBTC, inline="btc2", minval=1)
useBTC_M30 = input.bool(true,  "M30", group=grpBTC, inline="btc3")
btcM30     = input.float(160,  "",    group=grpBTC, inline="btc3", minval=1)

// ===== 7. Pair & TF Detection =====
pair = syminfo.ticker
tf   = timeframe.period
isM5  = tf == "5"
isM15 = tf == "15"
isM30 = tf == "30"

// ===== 8. Cek pair & TF aktif =====
isPairActive =
     (pair == "XAUUSD" and useXAU) or
     (pair == "USDJPY" and useJPY) or
     (pair == "GBPUSD" and useGBP) or
     (pair == "AUDUSD" and useAUD) or
     (pair == "USDCAD" and useCAD) or
     (pair == "EURUSD" and useEUR) or
     (pair == "NZDUSD" and useNZD) or
     (pair == "USDCHF" and useCHF) or
     (pair == "BTCUSD" and useBTC)

isTFActive =
     (isM5  and ((pair == "XAUUSD" and useXAU_M5)  or (pair == "USDJPY" and useJPY_M5)  or
                 (pair == "GBPUSD" and useGBP_M5)  or (pair == "AUDUSD" and useAUD_M5)  or
                 (pair == "USDCAD" and useCAD_M5)  or (pair == "EURUSD" and useEUR_M5)  or
                 (pair == "NZDUSD" and useNZD_M5)  or (pair == "USDCHF" and useCHF_M5)  or
                 (pair == "BTCUSD" and useBTC_M5))) or
     (isM15 and ((pair == "XAUUSD" and useXAU_M15) or (pair == "USDJPY" and useJPY_M15) or
                 (pair == "GBPUSD" and useGBP_M15) or (pair == "AUDUSD" and useAUD_M15) or
                 (pair == "USDCAD" and useCAD_M15) or (pair == "EURUSD" and useEUR_M15) or
                 (pair == "NZDUSD" and useNZD_M15) or (pair == "USDCHF" and useCHF_M15) or
                 (pair == "BTCUSD" and useBTC_M15))) or
     (isM30 and ((pair == "XAUUSD" and useXAU_M30) or (pair == "USDJPY" and useJPY_M30) or
                 (pair == "GBPUSD" and useGBP_M30) or (pair == "AUDUSD" and useAUD_M30) or
                 (pair == "USDCAD" and useCAD_M30) or (pair == "EURUSD" and useEUR_M30) or
                 (pair == "NZDUSD" and useNZD_M30) or (pair == "USDCHF" and useCHF_M30) or
                 (pair == "BTCUSD" and useBTC_M30)))

// ===== 9. Min Range =====
float minRange = na
if isPairActive and isTFActive
    float usePip  = na
    float pipMult = na

    if pair == "XAUUSD"
        usePip  := isM5 ? xauM5 : isM15 ? xauM15 : xauM30
        pipMult := 0.1
    else if pair == "USDJPY"
        usePip  := isM5 ? jpyM5 : isM15 ? jpyM15 : jpyM30
        pipMult := 0.01
    else if pair == "GBPUSD"
        usePip  := isM5 ? gbpM5 : isM15 ? gbpM15 : gbpM30
        pipMult := 0.0001
    else if pair == "AUDUSD"
        usePip  := isM5 ? audM5 : isM15 ? audM15 : audM30
        pipMult := 0.0001
    else if pair == "USDCAD"
        usePip  := isM5 ? cadM5 : isM15 ? cadM15 : cadM30
        pipMult := 0.0001
    else if pair == "EURUSD"
        usePip  := isM5 ? eurM5 : isM15 ? eurM15 : eurM30
        pipMult := 0.0001
    else if pair == "NZDUSD"
        usePip  := isM5 ? nzdM5 : isM15 ? nzdM15 : nzdM30
        pipMult := 0.0001
    else if pair == "USDCHF"
        usePip  := isM5 ? chfM5 : isM15 ? chfM15 : chfM30
        pipMult := 0.0001
    else if pair == "BTCUSD"
        usePip  := isM5 ? btcM5 : isM15 ? btcM15 : btcM30
        pipMult := 1.0

    minRange := usePip * pipMult

// ===== 10. Struktur candle =====
totalRange = math.abs(close - open)
upperWick  = high - math.max(open, close)
lowerWick  = math.min(open, close) - low
totalWick  = upperWick + lowerWick

// ===== 11. Validasi candle =====
isActive    = not na(minRange)
isBigCandle = isActive and totalRange >= minRange
isWickOk    = isActive and (totalWick / (totalRange + totalWick)) <= (wickPct / 100)
isBullish   = close > open
isBearish   = close < open

// Mode Agresif
bullAgresif = isBigCandle and isWickOk and isBullish
bearAgresif = isBigCandle and isWickOk and isBearish

// Mode Konservatif
isBullishValid  = isBullish and lowerWick < upperWick
isBearishValid  = isBearish and upperWick < lowerWick
bullKonservatif = isBigCandle and isWickOk and isBullishValid
bearKonservatif = isBigCandle and isWickOk and isBearishValid

// Pilih sinyal candle
isCandleAgresif = modeCandle == "Agresif"
bullSignal = isCandleAgresif ? bullAgresif : bullKonservatif
bearSignal = isCandleAgresif ? bearAgresif : bearKonservatif

// ===== 12. Validasi Konsolidasi =====
isKonsValid = true
if useKons
    allSmall = true
    for i = 1 to konsCount
        prevBody = math.abs(close[i] - open[i])
        if prevBody >= totalRange
            allSmall := false
    isKonsValid := allSmall

bullSignal := bullSignal and isKonsValid
bearSignal := bearSignal and isKonsValid

// ===== 13. Filter Trend EMA =====
emaTFString = emaTF == "M5" ? "5" : emaTF == "M15" ? "15" : emaTF == "M30" ? "30" : "60"
emaValue = request.security(syminfo.tickerid, emaTFString, ta.ema(close, emaLen), lookahead=barmerge.lookahead_off)

isTrendBull = close > emaValue
isTrendBear = close < emaValue

if useEMA
    bullSignal := bullSignal and isTrendBull
    bearSignal := bearSignal and isTrendBear

// ===== 14. Label Trend EMA (Table - Fixed Position) =====
var table trendTable = table.new(position.top_right, 1, 1)
if barstate.islast
    trendText  = "Trend EMA " + emaTF + ": " + (isTrendBull ? "BULLISH ↑" : "BEARISH ↓")
    trendColor = isTrendBull ? color.new(color.blue, 0) : color.new(color.red, 0)
    table.cell(trendTable, 0, 0, trendText, text_color=color.white, bgcolor=trendColor, text_size=size.small)

// ===== 15. Alert timing =====
barTimeLeft    = time_close - timenow
alertWindow    = barTimeLeft <= 90000 and barTimeLeft >= 20000
isAlertAgresif = modeAlert == "Agresif"

validBull = isAlertAgresif ? bullSignal : (bullSignal and alertWindow and not barstate.isconfirmed)
validBear = isAlertAgresif ? bearSignal : (bearSignal and alertWindow and not barstate.isconfirmed)

// ===== 16. Plot =====
plotshape(bullSignal, location=location.belowbar, style=shape.triangleup,
     color=color.new(color.blue, 0), size=size.small, title="Bull Signal")
plotshape(bearSignal, location=location.abovebar, style=shape.triangledown,
     color=color.new(color.red, 0), size=size.small, title="Bear Signal")

// ===== 17. Alert =====
alertcondition(validBull and isAlertAgresif,
     title="Momentum Bullish - Agresif",
     message="Candle momentum BULLISH valid - Mode Agresif")
alertcondition(validBear and isAlertAgresif,
     title="Momentum Bearish - Agresif",
     message="Candle momentum BEARISH valid - Mode Agresif")
alertcondition(validBull and not isAlertAgresif,
     title="Momentum Bullish - Konservatif",
     message="Candle momentum BULLISH valid - Mode Konservatif")
alertcondition(validBear and not isAlertAgresif,
     title="Momentum Bearish - Konservatif",
     message="Candle momentum BEARISH valid - Mode Konservatif")
````
