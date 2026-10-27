# Dynamic Trend-Sensitive MTF Kijun Panel + Ichimoku

- url: https://www.tradingview.com/script/OCuc8Ra9/
- type: indicator
- pine_id: PUB;903919fd714b4015bb6220f56bac1e06
- version: 1.0

## Description

Dynamic Trend-Sensitive MTF Kijun Panel + Ichimoku
This indicator blends the traditional Ichimoku Kinko Hyo system with a modern multi-timeframe (MTF) approach. It provides horizontal support/resistance levels and overall trend direction on a single screen through a dynamic sorting panel.

Key Features:
Full Ichimoku Suite: Plots Tenkan-sen, Kijun-sen, Senkou Span A/B (The Cloud), and Chikou Span for the current chart timeframe.

MTF Kijun-sen Tracking: Monitors Kijun-sen levels across 8 different timeframes (from 1m to Daily) simultaneously on the chart.

Dynamic Sorting Panel: The bottom-right panel automatically ranks Kijun-sen values by price (highest to lowest). This allows you to instantly identify which timeframe acts as resistance or support.

Trend-Sensitive Coloring: Cells in the panel compare the Kijun value of a lower timeframe to its immediate higher counterpart. A green background indicates a bullish alignment (Lower TF > Higher TF), while red indicates a bearish alignment.

How to Use:
Cloud Analysis: First, determine if the price is above or below the Cloud on your current timeframe.

Kijun Magnet: Price tends to be attracted to MTF Kijun levels (the colored lines). Use the panel to find the closest "major" levels above and below the current price.

Confluence Zones: When Kijun lines from different timeframes cluster together, it signifies an exceptionally strong support or resistance zone.

-----------------------------------------------------------------------

Dynamic Trend-Sensitive MTF Kijun Panel + Ichimoku
Bu indikatör, klasik Ichimoku Kinko Hyo sistemini modern bir çoklu zaman dilimi (MTF) yaklaşımıyla birleştirir. Yatay destek/direnç seviyelerini ve ana trend yönünü tek bir ekranda, dinamik bir sıralama paneliyle sunar.

Ana Özellikler:
Tam Ichimoku Seti: Mevcut grafik periyodunuzda Tenkan-sen, Kijun-sen, Senkou Span A/B (Bulut) ve Chikou Span çizgilerini standart olarak çizer.

MTF Kijun-sen İzleme: 1 dakikadan günlük periyoda kadar 8 farklı zaman diliminin Kijun-sen seviyelerini grafik üzerinde anlık olarak takip eder.

Dinamik Sıralama Paneli: Sağ alt köşedeki panel, Kijun-sen değerlerini fiyata göre (en yüksekten en düşüğe) otomatik olarak sıralar. Bu, hangi zaman diliminin direnç, hangisinin destek olduğunu anında görmenizi sağlar.

Trend Renklendirme: Paneldeki hücreler, küçük periyodun Kijun değerini bir üst periyotla kıyaslar. Eğer küçük periyot büyükten yukarıdaysa (boğa sinyali) yeşil, aşağıdaysa (ayı sinyali) kırmızı arka plan rengi alır.

Nasıl Kullanılır?
Bulut Analizi: Mevcut periyotta fiyatın bulutun üstünde mi yoksa altında mı olduğunu kontrol edin.

Kijun Mıknatısı: Fiyat, MTF Kijun çizgilerine (renkli çizgiler) doğru çekilme eğilimindedir. Paneldeki sıralama sayesinde, fiyatın hemen üstündeki ve altındaki "majör" seviyeleri kolayca tespit edebilirsiniz.

Kesişimler: Farklı periyotların Kijun çizgilerinin birbirine çok yaklaşması, o bölgenin çok güçlü bir destek veya direnç olduğunu gösterir.

## Source Code

````pine
//@version=5
indicator("Dynamic Trend-Sensitive MTF Kijun Panel + Ichimoku", overlay=true, max_labels_count = 50)

// --- 1. SETTINGS ---
tenkan_len   = input.int(9, "Tenkan-sen Length")
kijun_len    = input.int(26, "Kijun-sen Length")
senkou_b_len = input.int(52, "Senkou B Length")
displacement = input.int(26, "Displacement")

donchian(len) => math.avg(ta.highest(len), ta.lowest(len))

// --- ICHIMOKU COMPONENTS (Current Timeframe) ---
tenkanSen = donchian(tenkan_len)
kijunSen  = donchian(kijun_len)
senkouA   = math.avg(tenkanSen, kijunSen)
senkouB   = donchian(senkou_b_len)

// Ichimoku Plots
plot(tenkanSen, color=color.new(#0496ff, 0), title="Tenkan-sen")
plot(kijunSen, color=color.new(#991515, 0), title="Kijun-sen (Local)", linewidth=2)
plot(ta.lowest(low, 1)[displacement] ? close : na, offset = -displacement, color=color.new(#459915, 0), title="Chikou Span")

p1 = plot(senkouA, offset = displacement, color=color.new(color.green, 50), title="Senkou Span A")
p2 = plot(senkouB, offset = displacement, color=color.new(color.red, 50), title="Senkou Span B")
fill(p1, p2, color = senkouA > senkouB ? color.new(color.green, 90) : color.new(color.red, 90), title="Kumo (Cloud)")

// --- 2. DATA FETCHING (MTF Kijun-sen) ---
k1   = request.security(syminfo.tickerid, "1",   donchian(kijun_len), gaps=barmerge.gaps_off)
k5   = request.security(syminfo.tickerid, "5",   donchian(kijun_len), gaps=barmerge.gaps_off)
k15  = request.security(syminfo.tickerid, "15",  donchian(kijun_len), gaps=barmerge.gaps_off)
k30  = request.security(syminfo.tickerid, "30",  donchian(kijun_len), gaps=barmerge.gaps_off)
k60  = request.security(syminfo.tickerid, "60",  donchian(kijun_len), gaps=barmerge.gaps_off)
k120 = request.security(syminfo.tickerid, "120", donchian(kijun_len), gaps=barmerge.gaps_off)
k240 = request.security(syminfo.tickerid, "240", donchian(kijun_len), gaps=barmerge.gaps_off)
kD   = request.security(syminfo.tickerid, "D",   donchian(kijun_len), gaps=barmerge.gaps_off)

// --- 3. MTF PLOTS ---
plot(k1,   "1m Kijun",    color=color.new(color.gray, 60))
plot(k5,   "5m Kijun",    color=color.new(color.blue, 50))
plot(k15,  "15m Kijun",   color=color.new(color.aqua, 40))
plot(k30,  "30m Kijun",   color=color.new(color.orange, 30), linewidth=2)
plot(k60,  "1h Kijun",    color=color.new(color.red, 20), linewidth=2)
plot(k120, "2h Kijun",    color=color.new(color.purple, 10), linewidth=2)
plot(k240, "4h Kijun",    color=color.new(color.maroon, 0), linewidth=2)
plot(kD,   "Daily Kijun", color=color.new(color.yellow, 0), linewidth=3)

// --- 4. LABELS ---
update_label(_lbl, _price, _txt, _color) =>
    if barstate.islast
        label.set_xy(_lbl, bar_index + 2, _price)
        label.set_text(_lbl, _txt)
        label.set_textcolor(_lbl, _color)

var lb1   = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lb5   = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lb15  = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lb30  = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lb60  = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lb120 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lb240 = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)
var lbD   = label.new(na, na, "", style=label.style_label_left, color=color.new(color.black, 40), size=size.small)

update_label(lb1,   k1,   "1m", color.gray)
update_label(lb5,   k5,   "5m", color.blue)
update_label(lb15,  k15,  "15m", color.aqua)
update_label(lb30,  k30,  "30m", color.orange)
update_label(lb60,  k60,  "1h", color.red)
update_label(lb120, k120, "2h", color.purple)
update_label(lb240, k240, "4h", color.maroon)
update_label(lbD,   kD,   "D", color.yellow)

// --- 5. DYNAMIC SORTING AND TREND COLORING ---
var table trendPanel = table.new(position.bottom_right, 3, 9, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)

if barstate.islast
    // Prepare Arrays
    string[] names  = array.from("1m", "5m", "15m", "30m", "1h", "2h", "4h", "D")
    float[]  prices = array.from(k1, k5, k15, k30, k60, k120, k240, kD)
    color[]  colors = array.from(color.gray, color.blue, color.aqua, color.orange, color.red, color.purple, color.maroon, color.yellow)
    
    // Trend Logic: Lower TF vs Higher TF
    color c_1v5    = k1 > k5    ? color.new(color.green, 40) : color.new(color.red, 40)
    color c_5v15   = k5 > k15   ? color.new(color.green, 40) : color.new(color.red, 40)
    color c_15v30  = k15 > k30  ? color.new(color.green, 40) : color.new(color.red, 40)
    color c_30v60  = k30 > k60  ? color.new(color.green, 40) : color.new(color.red, 40)
    color c_60v120 = k60 > k120 ? color.new(color.green, 40) : color.new(color.red, 40)
    color c_120v240= k120 > k240? color.new(color.green, 40) : color.new(color.red, 40)
    color c_240vD  = k240 > kD   ? color.new(color.green, 40) : color.new(color.red, 40)
    color c_D      = color.new(color.gray, 80) 

    color[] trendColors = array.from(c_1v5, c_5v15, c_15v30, c_30v60, c_60v120, c_120v240, c_240vD, c_D)

    // Bubble Sort: Sync all arrays by price
    for i = 0 to array.size(prices) - 2
        for j = i + 1 to array.size(prices) - 1
            if array.get(prices, i) < array.get(prices, j)
                pTemp = array.get(prices, i), array.set(prices, i, array.get(prices, j)), array.set(prices, j, pTemp)
                nTemp = array.get(names, i),  array.set(names, i, array.get(names, j)),  array.set(names, j, nTemp)
                colTemp = array.get(colors, i), array.set(colors, i, array.get(colors, j)), array.set(colors, j, colTemp)
                tColTemp = array.get(trendColors, i), array.set(trendColors, i, array.get(trendColors, j)), array.set(trendColors, j, tColTemp)

    // Draw Table
    table.cell(trendPanel, 0, 0, "Rank", text_color=color.white)
    table.cell(trendPanel, 1, 0, "Timeframe", text_color=color.white)
    table.cell(trendPanel, 2, 0, "Value", text_color=color.white)

    for i = 0 to array.size(prices) - 1
        pName  = array.get(names, i)
        pVal   = array.get(prices, i)
        pColor = array.get(colors, i)
        tColor = array.get(trendColors, i)
        
        table.cell(trendPanel, 0, i + 1, str.tostring(i + 1), text_color=pColor)
        table.cell(trendPanel, 1, i + 1, pName, text_color=pColor, text_size=size.small)
        table.cell(trendPanel, 2, i + 1, str.tostring(pVal, "#.##"), text_color=color.white, bgcolor=tColor, text_size=size.small)
````
