# Otomatik Fibonacci Pro [OsmnBayram]

- url: https://www.tradingview.com/script/0aVsGZyy/
- type: indicator
- pine_id: PUB;687e56e7bcc64e2eb133368dfc7f792e
- version: 1.0

## Description

Auto Fibonacci Pro — Automatic Trend-Aware Fibonacci Levels
Auto Fibonacci Pro automatically detects the most recent significant swing high and swing low using pivot logic, then plots a complete set of Fibonacci retracement and extension levels — no manual drawing required. The tool reads the direction of the active leg (up or down) and orients the levels accordingly, so your Fibonacci stays correct as the market structure changes.
Key features:

Fully automatic swing detection with adjustable sensitivity (left/right pivot bars)
Trend-aware orientation — anchors flip automatically between bullish and bearish legs
Retracement levels: 0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0
Extension levels: 1.272, 1.414, 1.618, 2.0, 2.618 (each level can be toggled and recolored)
Golden Pocket highlight (0.618–0.65) for the most-watched reaction zone
Shaded zone fills, customizable labels (ratio, percentage, price), line style and width
Info table showing trend direction, swing high/low, range, and key level prices
Built-in alerts for crosses of the 0.5 / 0.618 / 0.786 levels and for new swing formation

How to use:

Increase the Left/Right Bar values to capture larger, more meaningful swings; decrease them for faster, more reactive levels. Higher values suit higher timeframes. The 0.618 level and the Golden Pocket zone are commonly watched for pullback entries, while the extension levels can serve as profit targets.
This script is for educational purposes and is not financial advice. Always combine with your own analysis and risk management.

## Source Code

````pine
//@version=6
// ============================================================================
//  OTOMATİK FİBONACCİ PRO
//  Otomatik swing tespiti + trende duyarlı çekme & uzanım seviyeleri
//  Pine Script v5  |  overlay indikatör
// ============================================================================
indicator('Otomatik Fibonacci Pro', shorttitle = 'AutoFib Pro', overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ============================================================================
//  1) GİRİŞ AYARLARI
// ============================================================================

// ---- Swing (Pivot) Tespiti ----
gP = '① Swing (Pivot) Tespiti'
pivotLeft = input.int(15, 'Sol Bar (hassasiyet)', minval = 1, maxval = 200, group = gP, tooltip = 'Pivot tespitinde soldaki bar sayısı. Büyük değer = daha büyük / daha önemli swingler, daha az sinyal.')
pivotRight = input.int(15, 'Sağ Bar (onay)', minval = 1, maxval = 200, group = gP, tooltip = 'Pivotun onaylanması için sağda beklenen bar sayısı. Büyük değer = daha geç ama daha güvenilir onay.')

// ---- Genel Görünüm ----
gD = '② Görünüm'
useTrendColor = input.bool(true, 'Trende göre renklendir', group = gD, tooltip = 'Açık: tüm çizgiler yükseliş/düşüş rengini alır. Kapalı: her seviye kendi rengini kullanır.')
upColor = input.color(#26a69a, 'Yükseliş rengi', group = gD, inline = 'c1')
downColor = input.color(#ef5350, 'Düşüş rengi', group = gD, inline = 'c1')
lineWidth = input.int(1, 'Çizgi kalınlığı', minval = 1, maxval = 4, group = gD)
lineStyleStr = input.string('Düz', 'Çizgi stili', options = ['Düz', 'Noktalı', 'Kesikli'], group = gD)
extendRight = input.bool(true, 'Çizgileri sağa uzat', group = gD)
fillZones = input.bool(true, 'Bölgeleri doldur', group = gD, inline = 'f1')
fillTransp = input.int(92, 'Dolgu şeffaflığı', minval = 50, maxval = 100, group = gD, inline = 'f1')

// ---- Etiketler ----
gL = '③ Etiketler'
showLabels = input.bool(true, 'Etiketleri göster', group = gL)
showRatio = input.bool(true, 'Oranı göster (0.618)', group = gL, inline = 'l1')
showPct = input.bool(true, 'Yüzdeyi göster (61.8%)', group = gL, inline = 'l1')
showPrice = input.bool(true, 'Fiyatı göster', group = gL)
labSizeStr = input.string('Normal', 'Etiket boyutu', options = ['Küçük', 'Normal', 'Büyük'], group = gL)

// ---- Bilgi Tablosu & Alarmlar ----
gT = '④ Tablo & Alarm'
showTable = input.bool(true, 'Bilgi tablosu göster', group = gT)
goldenPocket = input.bool(true, 'Golden Pocket vurgula (0.618–0.65)', group = gT, tooltip = '0.618 ile 0.65 arasındaki ünlü \'altın bölge\' özel renkle vurgulanır.')
gpColor = input.color(color.new(#ffd700, 70), 'Golden Pocket rengi', group = gT)

// ---- Fibonacci Seviyeleri (aç/kapat + renk) ----
gF = '⑤ Fibonacci Seviyeleri'
e0 = input.bool(true, '0.0', group = gF, inline = 'f00')
c0 = input.color(#787b86, '', group = gF, inline = 'f00')
e236 = input.bool(true, '0.236', group = gF, inline = 'f01')
c236 = input.color(#f5a623, '', group = gF, inline = 'f01')
e382 = input.bool(true, '0.382', group = gF, inline = 'f02')
c382 = input.color(#62b58f, '', group = gF, inline = 'f02')
e5 = input.bool(true, '0.5', group = gF, inline = 'f03')
c5 = input.color(#4a90d9, '', group = gF, inline = 'f03')
e618 = input.bool(true, '0.618', group = gF, inline = 'f04')
c618 = input.color(#f7525f, '', group = gF, inline = 'f04')
e786 = input.bool(true, '0.786', group = gF, inline = 'f05')
c786 = input.color(#9c27b0, '', group = gF, inline = 'f05')
e1 = input.bool(true, '1.0', group = gF, inline = 'f06')
c1 = input.color(#787b86, '', group = gF, inline = 'f06')
e1272 = input.bool(true, '1.272', group = gF, inline = 'f07')
c1272 = input.color(#2962ff, '', group = gF, inline = 'f07')
e1414 = input.bool(false, '1.414', group = gF, inline = 'f08')
c1414 = input.color(#2962ff, '', group = gF, inline = 'f08')
e1618 = input.bool(true, '1.618', group = gF, inline = 'f09')
c1618 = input.color(#2962ff, '', group = gF, inline = 'f09')
e2 = input.bool(false, '2.0', group = gF, inline = 'f10')
c2 = input.color(#2962ff, '', group = gF, inline = 'f10')
e2618 = input.bool(false, '2.618', group = gF, inline = 'f11')
c2618 = input.color(#2962ff, '', group = gF, inline = 'f11')

// ============================================================================
//  2) STİL EŞLEMELERİ
// ============================================================================
lineStyle = lineStyleStr == 'Noktalı' ? line.style_dotted : lineStyleStr == 'Kesikli' ? line.style_dashed : line.style_solid
labSize = labSizeStr == 'Küçük' ? size.small : labSizeStr == 'Büyük' ? size.large : size.normal

// ============================================================================
//  3) SEVİYE LİSTESİNİ KUR (ilk barda)
// ============================================================================
var array<float> lvVal = array.new<float>()
var array<color> lvCol = array.new<color>()
var array<bool> lvOn = array.new<bool>()

if barstate.isfirst
    array.push(lvVal, 0.0)
    array.push(lvCol, c0)
    array.push(lvOn, e0)
    array.push(lvVal, 0.236)
    array.push(lvCol, c236)
    array.push(lvOn, e236)
    array.push(lvVal, 0.382)
    array.push(lvCol, c382)
    array.push(lvOn, e382)
    array.push(lvVal, 0.5)
    array.push(lvCol, c5)
    array.push(lvOn, e5)
    array.push(lvVal, 0.618)
    array.push(lvCol, c618)
    array.push(lvOn, e618)
    array.push(lvVal, 0.786)
    array.push(lvCol, c786)
    array.push(lvOn, e786)
    array.push(lvVal, 1.0)
    array.push(lvCol, c1)
    array.push(lvOn, e1)
    array.push(lvVal, 1.272)
    array.push(lvCol, c1272)
    array.push(lvOn, e1272)
    array.push(lvVal, 1.414)
    array.push(lvCol, c1414)
    array.push(lvOn, e1414)
    array.push(lvVal, 1.618)
    array.push(lvCol, c1618)
    array.push(lvOn, e1618)
    array.push(lvVal, 2.0)
    array.push(lvCol, c2)
    array.push(lvOn, e2)
    array.push(lvVal, 2.618)
    array.push(lvCol, c2618)
    array.push(lvOn, e2618)

// ============================================================================
//  4) PİVOT TESPİTİ & EN SON SWING TAKİBİ
// ============================================================================
ph = ta.pivothigh(pivotLeft, pivotRight)
pl = ta.pivotlow(pivotLeft, pivotRight)

var float lastPHprice = na
var int lastPHbar = na
var float lastPLprice = na
var int lastPLbar = na

if not na(ph)
    lastPHprice := ph
    lastPHbar := bar_index - pivotRight
    lastPHbar
if not na(pl)
    lastPLprice := pl
    lastPLbar := bar_index - pivotRight
    lastPLbar

bool haveBoth = not na(lastPHprice) and not na(lastPLprice)
// En son onaylanan pivot HIGH ise -> yukarı bacak (low'dan high'a)
bool isUp = haveBoth and lastPHbar > lastPLbar

float swHigh = haveBoth ? lastPHprice : na
float swLow = haveBoth ? lastPLprice : na
int startBar = haveBoth ? isUp ? lastPLbar : lastPHbar : na // bacağın başladığı bar

// ---- Seviye fiyat fonksiyonu ----
// Yukarı bacakta 0=tepe, 1=dip  |  Aşağı bacakta 0=dip, 1=tepe (TradingView mantığı)
f_price(_lvl, _h, _l, _up) =>
    _rng = _h - _l
    _up ? _h - _rng * _lvl : _l + _rng * _lvl

// ---- Değişim tespiti (yeni swing oluştu mu?) ----
var float prevHigh = na
var float prevLow = na
bool changed = haveBoth and (swHigh != prevHigh or swLow != prevLow)

// ============================================================================
//  5) ÇİZİM (yeni swing oluştuğunda yeniden çiz)
// ============================================================================
var array<line> fLines = array.new<line>()
var array<label> fLabs = array.new<label>()
var array<linefill> fFills = array.new<linefill>()

f_clearAll() =>
    if array.size(fFills) > 0
        for i = 0 to array.size(fFills) - 1 by 1
            linefill.delete(array.get(fFills, i))
        array.clear(fFills)
    if array.size(fLines) > 0
        for i = 0 to array.size(fLines) - 1 by 1
            line.delete(array.get(fLines, i))
        array.clear(fLines)
    if array.size(fLabs) > 0
        for i = 0 to array.size(fLabs) - 1 by 1
            label.delete(array.get(fLabs, i))
        array.clear(fLabs)

if changed and haveBoth
    f_clearAll()
    baseCol = isUp ? upColor : downColor
    x2 = extendRight ? bar_index : bar_index
    // --- çizgi & etiketleri oluştur ---
    for i = 0 to array.size(lvVal) - 1 by 1
        if array.get(lvOn, i)
            lvl = array.get(lvVal, i)
            price = f_price(lvl, swHigh, swLow, isUp)
            col = useTrendColor ? baseCol : array.get(lvCol, i)
            ln = line.new(startBar, price, x2, price, xloc = xloc.bar_index, color = col, width = lineWidth, style = lineStyle, extend = extendRight ? extend.right : extend.none)
            array.push(fLines, ln)
            if showLabels
                txt = ''
                if showRatio
                    txt := txt + str.tostring(lvl, '0.###')
                    txt
                if showPct
                    txt := txt + (txt == '' ? '' : '  ') + '(' + str.tostring(lvl * 100, '0.0') + '%)'
                    txt
                if showPrice
                    txt := txt + (txt == '' ? '' : '  ') + str.tostring(price, format.mintick)
                    txt
                lb = label.new(x2, price, txt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 80), textcolor = col, size = labSize)
                array.push(fLabs, lb)
    // --- bölge dolguları (ardışık çizgiler arası) ---
    if fillZones and array.size(fLines) > 1
        for i = 0 to array.size(fLines) - 2 by 1
            ln1 = array.get(fLines, i)
            ln2 = array.get(fLines, i + 1)
            lvlA = array.get(lvVal, i) // not: kapalı seviyeler atlandığı için yaklaşık; görsel dolgu amaçlı
            isGP = goldenPocket and lvlA >= 0.6 and lvlA < 0.65
            fcol = isGP ? gpColor : color.new(isUp ? upColor : downColor, fillTransp)
            lf = linefill.new(ln1, ln2, fcol)
            array.push(fFills, lf)
    prevHigh := swHigh
    prevLow := swLow
    prevLow

// Her zaman güncel swing'i hatırla (ilk çizimden sonra da değişim yakalansın)
if haveBoth and na(prevHigh)
    prevHigh := swHigh
    prevLow := swLow
    prevLow

// ============================================================================
//  6) SON BARDA POZİSYONLARI GÜNCELLE (sağa takip etsin)
// ============================================================================
if barstate.islast and array.size(fLines) > 0
    for i = 0 to array.size(fLines) - 1 by 1
        line.set_x2(array.get(fLines, i), bar_index)
    if array.size(fLabs) > 0
        for i = 0 to array.size(fLabs) - 1 by 1
            label.set_x(array.get(fLabs, i), bar_index)

// ============================================================================
//  7) BİLGİ TABLOSU
// ============================================================================
var table tab = table.new(position.top_right, 2, 6, border_width = 1, frame_width = 1, frame_color = color.gray)
if barstate.islast and showTable and haveBoth
    trCol = isUp ? upColor : downColor
    rng = swHigh - swLow
    table.cell(tab, 0, 0, 'AUTO FIB', text_color = color.white, bgcolor = trCol, text_size = size.small)
    table.cell(tab, 1, 0, isUp ? '▲ YÜKSELİŞ' : '▼ DÜŞÜŞ', text_color = color.white, bgcolor = trCol, text_size = size.small)
    table.cell(tab, 0, 1, 'Tepe', text_color = color.gray, text_size = size.small)
    table.cell(tab, 1, 1, str.tostring(swHigh, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(tab, 0, 2, 'Dip', text_color = color.gray, text_size = size.small)
    table.cell(tab, 1, 2, str.tostring(swLow, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(tab, 0, 3, 'Aralık', text_color = color.gray, text_size = size.small)
    table.cell(tab, 1, 3, str.tostring(rng, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(tab, 0, 4, '0.618', text_color = color.gray, text_size = size.small)
    table.cell(tab, 1, 4, str.tostring(f_price(0.618, swHigh, swLow, isUp), format.mintick), text_color = #f7525f, text_size = size.small)
    table.cell(tab, 0, 5, '0.5', text_color = color.gray, text_size = size.small)
    table.cell(tab, 1, 5, str.tostring(f_price(0.5, swHigh, swLow, isUp), format.mintick), text_color = #4a90d9, text_size = size.small)

// ============================================================================
//  8) ALARMLAR
// ============================================================================
p618 = haveBoth ? f_price(0.618, swHigh, swLow, isUp) : na
p500 = haveBoth ? f_price(0.5, swHigh, swLow, isUp) : na
p786 = haveBoth ? f_price(0.786, swHigh, swLow, isUp) : na

alertcondition(haveBoth and ta.cross(close, p618), '0.618 Kesişimi', 'Fiyat 0.618 Fibonacci seviyesini kesti')
alertcondition(haveBoth and ta.cross(close, p500), '0.5 Kesişimi', 'Fiyat 0.5 Fibonacci seviyesini kesti')
alertcondition(haveBoth and ta.cross(close, p786), '0.786 Kesişimi', 'Fiyat 0.786 Fibonacci seviyesini kesti')
alertcondition(changed, 'Yeni Swing', 'Yeni otomatik Fibonacci swing oluştu')
````
