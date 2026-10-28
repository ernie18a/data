# Advanced MTF RSI, Stochastic RSI & Trend Dashboard

- url: https://www.tradingview.com/script/ub9dNrc3-Advanced-MTF-RSI-Stochastic-RSI-Trend-Dashboard/
- type: indicator
- pine_id: PUB;de155525fa9b42e0899862dd89170cdf
- version: 1.0

## Description

Are you tired of constantly switching between timeframes to check market momentum and trend direction? The Advanced MTF RSI, Stochastic RSI & Trend Dashboard brings all the critical data you need into a single, fully customizable, and highly visual table on your chart.

Designed for day traders, swing traders, and scalpers, this indicator provides a macro and micro view of the market at a glance.

🔥 Key Features:

Multi-Timeframe (MTF) Power: Monitor 10 different timeframes simultaneously (from 1m up to 1M). You can toggle each timeframe on or off depending on your trading style.

Real-Time Trend Detection: Instantly see if the market is "Bull" or "Bear" across different timeframes based on the EMA 50.

Combined Momentum Metrics: Displays standard RSI alongside Stochastic RSI (both %K and %D lines) independently.

Dynamic Visual Alerts: The table background automatically changes color based on market conditions:

Overbought Zones: Turns Red (RSI ≥ 70, SRSI ≥ 80).

Oversold Zones: Turns Green (RSI ≤ 30, SRSI ≤ 20).

Trend Status: Green for Bull (Price > EMA 50), Red for Bear (Price < EMA 50).

Ultimate Customization:

Adjust the table's position (Top Right, Bottom Left, etc.) and text size to fit your screen perfectly.

Turn specific rows (Trend, RSI, SRSI K, SRSI D) on or off to keep your chart clean.

Fully customizable colors for headers, text, and conditional backgrounds.

Independent length and source settings for both RSI and Stochastic RSI.

💡 How to Use:
Use the Dashboard to find confluence. For example, if you are looking for a long entry, you might wait for the higher timeframes (4h, 1d) to show a "Bull" trend, while looking for the lower timeframes (5m, 15m) to hit the oversold (Green) levels on RSI/SRSI for an optimal entry point.

Disclaimer: This script is for educational and informational purposes only. It does not constitute financial advice.

## Source Code

````pine
//@version=5
indicator("Advanced MTF RSI, Stochastic RSI & Trend Dashboard", overlay=true)

// ================= AYARLAR =================

// --- Tablo Konum ve Boyut Ayarları ---
posInput = input.string("Sağ Üst", title="Tablo Konumu", options=["Sol Üst", "Sol Alt", "Orta Üst", "Orta Alt", "Sağ Üst", "Sağ Alt"], group="Tablo Genel Ayarları")
sizeInput = input.string("Normal", title="Tablo Boyutu", options=["Küçük", "Orta", "Normal"], group="Tablo Genel Ayarları")

// --- Trend Ayarları ---
trendEmaLength = input.int(50, title="Trend EMA Uzunluğu", group="Trend Ayarları", tooltip="Fiyat bu EMA'nın üzerindeyse Bull, altındaysa Bear kabul edilir.")

// --- RSI Ayarları ---
rsiSource = input.source(close, title="RSI Kaynağı", group="RSI Ayarları")
rsiLength = input.int(14, title="RSI Uzunluğu", group="RSI Ayarları")

// --- Stoch RSI Ayarları ---
smoothK = input.int(3, title="K", group="Stoch RSI Ayarları")
smoothD = input.int(3, title="D", group="Stoch RSI Ayarları")
stochRsiLen = input.int(14, title="RSI Length (Stoch İçin)", group="Stoch RSI Ayarları")
stochLength = input.int(8, title="Stochastic Length", group="Stoch RSI Ayarları")

// --- Satır Görünürlük Ayarları ---
show_Trend  = input.bool(true, title="Trend Satırını Tabloda Göster", group="Satır Görünürlüğü")
show_RSI    = input.bool(true, title="RSI Satırını Tabloda Göster", group="Satır Görünürlüğü")
show_SRSI_K = input.bool(true, title="SRSI K Satırını Tabloda Göster", group="Satır Görünürlüğü")
show_SRSI_D = input.bool(true, title="SRSI D Satırını Tabloda Göster", group="Satır Görünürlüğü")

// --- Zaman Dilimi Ayarları (Sütunlar) ---
show_1m  = input.bool(true, title="1 Dakika (1m)", group="Zaman Dilimleri")
show_5m  = input.bool(true, title="5 Dakika (5m)", group="Zaman Dilimleri")
show_15m = input.bool(true, title="15 Dakika (15m)", group="Zaman Dilimleri")
show_1h  = input.bool(true, title="1 Saat (1h)", group="Zaman Dilimleri")
show_4h  = input.bool(true, title="4 Saat (4h)", group="Zaman Dilimleri")
show_8h  = input.bool(true, title="8 Saat (8h)", group="Zaman Dilimleri")
show_12h = input.bool(true, title="12 Saat (12h)", group="Zaman Dilimleri")
show_1d  = input.bool(true, title="1 Gün (1d)", group="Zaman Dilimleri")
show_1w  = input.bool(true, title="1 Hafta (1w)", group="Zaman Dilimleri")
show_1M  = input.bool(true, title="1 Ay (1M)", group="Zaman Dilimleri")

// --- Renk Ayarları ---
headerBgColor    = input.color(color.new(color.black, 30), title="Başlık Arkaplan Rengi", group="Renk Ayarları")
headerTextColor  = input.color(color.white, title="Başlık Metin Rengi", group="Renk Ayarları")
dataTextColor    = input.color(color.white, title="Veri Metin Rengi", group="Renk Ayarları")

trendBullColor   = input.color(color.new(color.green, 40), title="Trend Bull Arkaplan", group="Renk Ayarları")
trendBearColor   = input.color(color.new(color.red, 40), title="Trend Bear Arkaplan", group="Renk Ayarları")

rsiObColor       = input.color(color.new(color.red, 40), title="RSI Aşırı Alım Arkaplan", group="Renk Ayarları")
rsiOsColor       = input.color(color.new(color.green, 40), title="RSI Aşırı Satım Arkaplan", group="Renk Ayarları")
rsiNeutralColor  = input.color(color.new(color.gray, 80), title="RSI Nötr Arkaplan", group="Renk Ayarları")

srsiObColor      = input.color(color.new(color.red, 40), title="SRSI Aşırı Alım Arkaplan", group="Renk Ayarları")
srsiOsColor      = input.color(color.new(color.green, 40), title="SRSI Aşırı Satım Arkaplan", group="Renk Ayarları")
srsiNeutralColor = input.color(color.new(color.gray, 80), title="SRSI Nötr Arkaplan", group="Renk Ayarları")

// ================= İŞLEMLER =================

// Konum Seçimi İşlemi
tablePos = switch posInput
    "Sol Üst"  => position.top_left
    "Sol Alt"  => position.bottom_left
    "Orta Üst" => position.top_center
    "Orta Alt" => position.bottom_center
    "Sağ Üst"  => position.top_right
    "Sağ Alt"  => position.bottom_right
    => position.top_right

// Boyut Seçimi İşlemi
textSize = switch sizeInput
    "Küçük"  => size.small
    "Orta"   => size.normal
    "Normal" => size.large
    => size.normal

// RSI Renk Belirleme
getRsiColor(val) =>
    if na(val)
        color.new(color.gray, 100)
    else if val >= 70
        rsiObColor
    else if val <= 30
        rsiOsColor
    else
        rsiNeutralColor

// SRSI Renk Belirleme
getSrsiColor(val) =>
    if na(val)
        color.new(color.gray, 100)
    else if val >= 80
        srsiObColor
    else if val <= 20
        srsiOsColor
    else
        srsiNeutralColor

// Değerleri Hesaplama Fonksiyonu
getValues() =>
    // Normal RSI Hesabı
    r = ta.rsi(rsiSource, rsiLength)
    
    // Stokastik RSI Hesabı
    rsiForStoch = ta.rsi(rsiSource, stochRsiLen)
    stoch = ta.stoch(rsiForStoch, rsiForStoch, rsiForStoch, stochLength)
    k = ta.sma(stoch, smoothK)
    d = ta.sma(k, smoothD)
    
    // Trend Hesabı: Fiyat EMA'nın üzerindeyse 1 (Bull), altındaysa 0 (Bear)
    trendEma = ta.ema(close, trendEmaLength)
    isBull = close > trendEma ? 1 : 0
    
    [r, k, d, isBull]

// --- Çoklu Zaman Dilimi (MTF) Veri Çekimi ---
[r1m, k1m, d1m, t1m]       = request.security(syminfo.tickerid, "1", getValues())
[r5m, k5m, d5m, t5m]       = request.security(syminfo.tickerid, "5", getValues())
[r15m, k15m, d15m, t15m]   = request.security(syminfo.tickerid, "15", getValues())
[r1h, k1h, d1h, t1h]       = request.security(syminfo.tickerid, "60", getValues())
[r4h, k4h, d4h, t4h]       = request.security(syminfo.tickerid, "240", getValues())
[r8h, k8h, d8h, t8h]       = request.security(syminfo.tickerid, "480", getValues())
[r12h, k12h, d12h, t12h]   = request.security(syminfo.tickerid, "720", getValues())
[r1d, k1d, d1d, t1d]       = request.security(syminfo.tickerid, "D", getValues())
[r1w, k1w, d1w, t1w]       = request.security(syminfo.tickerid, "W", getValues())
[r1M_val, k1M_val, d1M_val, t1M_val] = request.security(syminfo.tickerid, "M", getValues())

// ================= TABLO OLUŞTURMA =================

// Maksimum sütun: 1 Başlık Sütunu + 10 Zaman Dilimi = 11
// Maksimum satır: 1 Başlık Satırı + 4 Veri Satırı (Trend, RSI, K, D) = 5
var table mtfTable = table.new(tablePos, 11, 5, border_width = 1, border_color = color.gray)

if barstate.islast
    // Dinamik diziler
    string[] tfNames = array.new_string(0)
    float[] rsiVals  = array.new_float(0)
    float[] kVals    = array.new_float(0)
    float[] dVals    = array.new_float(0)
    float[] tVals    = array.new_float(0) // Trend değerleri için yeni dizi

    // Açık zaman dilimlerini dizilere ekleme
    if show_1m
        array.push(tfNames, "1m"), array.push(rsiVals, r1m), array.push(kVals, k1m), array.push(dVals, d1m), array.push(tVals, t1m)
    if show_5m
        array.push(tfNames, "5m"), array.push(rsiVals, r5m), array.push(kVals, k5m), array.push(dVals, d5m), array.push(tVals, t5m)
    if show_15m
        array.push(tfNames, "15m"), array.push(rsiVals, r15m), array.push(kVals, k15m), array.push(dVals, d15m), array.push(tVals, t15m)
    if show_1h
        array.push(tfNames, "1h"), array.push(rsiVals, r1h), array.push(kVals, k1h), array.push(dVals, d1h), array.push(tVals, t1h)
    if show_4h
        array.push(tfNames, "4h"), array.push(rsiVals, r4h), array.push(kVals, k4h), array.push(dVals, d4h), array.push(tVals, t4h)
    if show_8h
        array.push(tfNames, "8h"), array.push(rsiVals, r8h), array.push(kVals, k8h), array.push(dVals, d8h), array.push(tVals, t8h)
    if show_12h
        array.push(tfNames, "12h"), array.push(rsiVals, r12h), array.push(kVals, k12h), array.push(dVals, d12h), array.push(tVals, t12h)
    if show_1d
        array.push(tfNames, "1d"), array.push(rsiVals, r1d), array.push(kVals, k1d), array.push(dVals, d1d), array.push(tVals, t1d)
    if show_1w
        array.push(tfNames, "1w"), array.push(rsiVals, r1w), array.push(kVals, k1w), array.push(dVals, d1w), array.push(tVals, t1w)
    if show_1M
        array.push(tfNames, "1M"), array.push(rsiVals, r1M_val), array.push(kVals, k1M_val), array.push(dVals, d1M_val), array.push(tVals, t1M_val)

    // 1. Satır: Sütun Başlıklarını Yazdır (Zaman Dilimleri)
    table.cell(mtfTable, 0, 0, "", bgcolor=headerBgColor, text_size=textSize) 
    for i = 0 to array.size(tfNames) == 0 ? na : array.size(tfNames) - 1
        table.cell(mtfTable, i + 1, 0, array.get(tfNames, i), text_color=headerTextColor, bgcolor=headerBgColor, text_size=textSize)

    int currentRow = 1
    
    // Yeni Eklenen Trend Satırı
    if show_Trend
        table.cell(mtfTable, 0, currentRow, "Trend", text_color=headerTextColor, bgcolor=headerBgColor, text_size=textSize)
        for i = 0 to array.size(tVals) == 0 ? na : array.size(tVals) - 1
            trendStatus = array.get(tVals, i)
            isBullish = trendStatus == 1
            trendText = isBullish ? "Bull" : "Bear"
            trendBgColor = isBullish ? trendBullColor : trendBearColor
            table.cell(mtfTable, i + 1, currentRow, trendText, bgcolor=trendBgColor, text_color=dataTextColor, text_size=textSize)
        currentRow += 1

    // RSI Satırı
    if show_RSI
        table.cell(mtfTable, 0, currentRow, "RSI", text_color=headerTextColor, bgcolor=headerBgColor, text_size=textSize)
        for i = 0 to array.size(rsiVals) == 0 ? na : array.size(rsiVals) - 1
            val = array.get(rsiVals, i)
            table.cell(mtfTable, i + 1, currentRow, str.tostring(val, "#.##"), bgcolor=getRsiColor(val), text_color=dataTextColor, text_size=textSize)
        currentRow += 1

    // SRSI K Satırı
    if show_SRSI_K
        table.cell(mtfTable, 0, currentRow, "SRSI K", text_color=headerTextColor, bgcolor=headerBgColor, text_size=textSize)
        for i = 0 to array.size(kVals) == 0 ? na : array.size(kVals) - 1
            val = array.get(kVals, i)
            table.cell(mtfTable, i + 1, currentRow, str.tostring(val, "#.##"), bgcolor=getSrsiColor(val), text_color=dataTextColor, text_size=textSize)
        currentRow += 1

    // SRSI D Satırı
    if show_SRSI_D
        table.cell(mtfTable, 0, currentRow, "SRSI D", text_color=headerTextColor, bgcolor=headerBgColor, text_size=textSize)
        for i = 0 to array.size(dVals) == 0 ? na : array.size(dVals) - 1
            val = array.get(dVals, i)
            table.cell(mtfTable, i + 1, currentRow, str.tostring(val, "#.##"), bgcolor=getSrsiColor(val), text_color=dataTextColor, text_size=textSize)
````
