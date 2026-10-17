# Gann Square of 9 Auto Trend Chandelier Confluence

- url: https://www.tradingview.com/script/krTizeJR/
- type: indicator
- pine_id: PUB;da8c328d7c784843a9431fbd23245691
- version: 1.0

## Description

⚡ GANN SQUARE OF 9 — AUTO TREND ENGINE

Gann'ın spiral matematiği + modern trend filtreleri, tek araçta.
Grafiğine bakıp "şimdi nereden girsem, stop'u nereye koysam?" diye düşünmekten yoruldun mu?
Çoğu Gann aracı senden merkez fiyatı elle girmeni ister. Her swing'de tekrar tekrar. Çiz, sil, yeniden çiz. Bu araç o işi tamamen ortadan kaldırıyor.
Ne yapıyor:
Indikatör son swing high/low'u otomatik yakalıyor ve Gann Square of 9 seviyelerini (kardinal 90/180/270, diagonal 45/135/225) kendisi çiziyor. Hiçbir manuel girdi yok — grafiğe ekle, çalışsın.
Üstüne iki bağımsız trend filtresi koydum:

→ Lineer regresyon kanalı — ana trend yönünü ve standart sapma bantlarını gösterir

→ Chandelier Exit — ATR tabanlı trailing stop ve yön teyidi
Ve hepsini birleştiren parça: ⭐ A+ Confluence sinyali. Bu üçü — Gann seviyesi, kanal kenarı ve trend yönü — aynı noktada buluştuğunda araç bunu işaretler. Yani gürültüyü eler, sana sadece çoklu-onaylı bölgeleri gösterir.
İçinde ne var:

Otomatik Square of 9 seviyeleri (çok turlu, kardinal + diagonal)
Canlı spiral ızgara tablosu (fiyat-spiral veya klasik tamsayı modu)
Lineer regresyon trend kanalı (yön etiketli)
Entegre Chandelier Exit (trailing stop + Buy/Sell)
A+ Confluence işaretçisi (çift trend onaylı)
Gann zaman döngüsü projeksiyonları
Tüm sinyaller için hazır alarmlar

Nasıl kullanılır:

A+ etiketi çıktığında o bölgeyi incele. Girişini değerlendir, stop için CE'nin trailing çizgisini, hedef için bir üst Gann kardinalini referans al. Trend ve seviye birlikte konuştuğunda dinle.
Şimdi grafiğine ekle, kendi enstrümanında test et, ne gördüğünü yorumlara yaz. 👇

⚠️ Sorumluluk Reddi: Bu araç yalnızca eğitim ve teknik analiz amaçlıdır. Yatırım tavsiyesi değildir, kâr garantisi vermez. Tüm işlemlerinizi kendi araştırmanız ve risk yönetiminizle yapın. Geçmiş performans gelecek sonuçları garanti etmez.

## Source Code

````pine
//@version=6
indicator("Gann Square of 9 — Auto + Trend + Chandelier + Confluence", overlay=true, max_lines_count=500, max_labels_count=500)

// ═════════════════════════════════════════════════════════════════════════
// AYARLAR
// ═════════════════════════════════════════════════════════════════════════
gRef = "📍 Otomatik Merkez"
swingLen = input.int(20, "Swing Hassasiyeti", minval=2, group=gRef)

gAng = "🎯 Açısal Seviyeler"
showAngular = input.bool(true, "Açısal D/D (45/90/135...)", group=gAng)
levelCount = input.int(2, "Tur Sayısı (360°=1 tur)", minval=1, maxval=4, group=gAng)

gCard = "✚ Çember Eksenleri"
showCardinal = input.bool(true, "Kardinal (90/180/270/360)", group=gCard)
showDiagonal = input.bool(true, "Diagonal (45/135/225/315)", group=gCard)

gGrid = "🔢 Spiral Izgara"
showGrid = input.bool(true, "Square of 9 Tablosu", group=gGrid)
gridRings = input.int(4, "Halka Sayısı", minval=2, maxval=7, group=gGrid)
gridPos = input.string("Sağ Üst", "Konum", options=["Sağ Üst","Sağ Alt","Sol Üst","Sol Alt"], group=gGrid)
gridMode = input.string("Fiyat Spirali", "Hücre Değeri", options=["Fiyat Spirali","Klasik Tamsayı"], group=gGrid)

gTrend = "📈 Trend Kanalı"
showTrend = input.bool(true, "Trend Kanalını Göster", group=gTrend)
trendLen = input.int(100, "Kanal Periyodu", minval=10, group=gTrend)
chMult = input.float(2.0, "Kanal Genişliği (StdDev)", minval=0.5, step=0.5, group=gTrend)

gCE = "🕯️ Chandelier Exit"
showCE = input.bool(true, "Chandelier Exit Göster", group=gCE)
ceLength = input.int(22, "CE ATR Periyodu", group=gCE)
ceMult = input.float(3.0, "CE ATR Çarpanı", step=0.1, group=gCE)
ceUseClose = input.bool(true, "Ekstremum için Kapanış Kullan", group=gCE)
ceShowLabels = input.bool(true, "CE Buy/Sell Etiketleri", group=gCE)

gConf = "⭐ A+ Confluence"
showConf = input.bool(true, "Confluence Sinyali", group=gConf)
confTol = input.float(0.5, "Çakışma Toleransı (ATR katı)", minval=0.1, step=0.1, group=gConf)
requireCE = input.bool(true, "CE Onayı Zorunlu (çift trend onayı)", group=gConf, tooltip="Açıkken A+ sinyali sadece CE yönü ile regresyon trendi aynıyken çıkar")

gTime = "⏱️ Zaman Döngüsü"
showTime = input.bool(true, "Zaman Çizgileri", group=gTime)
timeFactor = input.float(1.0, "Zaman Çarpanı", minval=0.1, group=gTime)

gStyle = "🎨 Görsel"
colRes = input.color(color.new(color.red, 0), "Direnç", group=gStyle)
colSup = input.color(color.new(color.green, 0), "Destek", group=gStyle)
colCard = input.color(color.new(color.blue, 20), "Kardinal", group=gStyle)
colDiag = input.color(color.new(color.orange, 20), "Diagonal", group=gStyle)
extendRight = input.int(60, "Çizgi Uzunluğu (bar)", group=gStyle)
showLabels = input.bool(true, "Etiketleri Göster", group=gStyle)

// ═════════════════════════════════════════════════════════════════════════
// 1. OTOMATİK MERKEZ FİYAT
// ═════════════════════════════════════════════════════════════════════════
var float centerPrice = na
var int   centerBar   = na
var int   centerTime  = na

ph = ta.pivothigh(swingLen, swingLen)
pl = ta.pivotlow(swingLen, swingLen)

if not na(ph)
    centerPrice := ph
    centerBar   := bar_index - swingLen
    centerTime  := time[swingLen]
else if not na(pl)
    centerPrice := pl
    centerBar   := bar_index - swingLen
    centerTime  := time[swingLen]

// ═════════════════════════════════════════════════════════════════════════
// 2. ÇEKİRDEK + ATR
// ═════════════════════════════════════════════════════════════════════════
sq9(float price, float degree, bool isUp) =>
    float result = na
    if not na(price) and price > 0
        float root = math.sqrt(price)
        float tRoot = isUp ? root + degree / 180.0 : root - degree / 180.0
        result := tRoot <= 0 ? na : tRoot * tRoot
    result

atrVal = ta.atr(14)

var int barMs = na
if not na(time) and not na(time[1])
    barMs := time - time[1]

// ═════════════════════════════════════════════════════════════════════════
// 3. CHANDELIER EXIT
// ═════════════════════════════════════════════════════════════════════════
ceAtr = ceMult * ta.atr(ceLength)

longStop = (ceUseClose ? ta.highest(close, ceLength) : ta.highest(high, ceLength)) - ceAtr
longStopPrev = nz(longStop[1], longStop)
longStop := close[1] > longStopPrev ? math.max(longStop, longStopPrev) : longStop

shortStop = (ceUseClose ? ta.lowest(close, ceLength) : ta.lowest(low, ceLength)) + ceAtr
shortStopPrev = nz(shortStop[1], shortStop)
shortStop := close[1] < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop

var int ceDir = 1
ceDir := close > shortStopPrev ? 1 : close < longStopPrev ? -1 : ceDir

ceBuySignal  = ceDir == 1 and ceDir[1] == -1
ceSellSignal = ceDir == -1 and ceDir[1] == 1

plot(showCE and ceDir == 1 ? longStop : na, "CE Long Stop", style=plot.style_linebr, linewidth=2, color=color.green)
plot(showCE and ceDir == -1 ? shortStop : na, "CE Short Stop", style=plot.style_linebr, linewidth=2, color=color.red)
plotshape(showCE and ceBuySignal ? longStop : na, "CE Buy Start", location=location.absolute, style=shape.circle, size=size.tiny, color=color.green)
plotshape(showCE and ceBuySignal and ceShowLabels ? longStop : na, "CE Buy", text="Buy", location=location.absolute, style=shape.labelup, size=size.tiny, color=color.green, textcolor=color.white)
plotshape(showCE and ceSellSignal ? shortStop : na, "CE Sell Start", location=location.absolute, style=shape.circle, size=size.tiny, color=color.red)
plotshape(showCE and ceSellSignal and ceShowLabels ? shortStop : na, "CE Sell", text="Sell", location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.red, textcolor=color.white)

// ═════════════════════════════════════════════════════════════════════════
// 4. ÇİZİM DEPOSU + GANN SEVİYE LİSTESİ
// ═════════════════════════════════════════════════════════════════════════
var array<line>  lines  = array.new<line>()
var array<label> labels = array.new<label>()
var array<float> gannSupports = array.new<float>()
var array<float> gannResists  = array.new<float>()

clearAll() =>
    for ln in lines
        line.delete(ln)
    array.clear(lines)
    for lb in labels
        label.delete(lb)
    array.clear(labels)

drawLevel(float price, string txt, color col, string sty) =>
    if not na(price)
        line ln = line.new(bar_index, price, bar_index + extendRight, price, color=col, width=1, style=sty)
        array.push(lines, ln)
        if showLabels
            label lb = label.new(bar_index + extendRight, price, txt + "  " + str.tostring(price, format.mintick), style=label.style_label_left, color=color.new(col, 85), textcolor=col, size=size.small)
            array.push(labels, lb)

centerChanged = ta.change(centerPrice) != 0 and not na(centerPrice)

if centerChanged
    clearAll()
    array.clear(gannSupports)
    array.clear(gannResists)
    drawLevel(centerPrice, "⊙ MERKEZ", color.new(color.gray, 0), line.style_solid)

    if showAngular
        for ring = 0 to levelCount - 1
            for a in array.from(45, 90, 135, 180, 225, 270, 315, 360)
                int d = ring * 360 + a
                float up = sq9(centerPrice, d, true)
                float dn = sq9(centerPrice, d, false)
                drawLevel(up, "R " + str.tostring(d) + "°", colRes, line.style_dashed)
                drawLevel(dn, "S " + str.tostring(d) + "°", colSup, line.style_dashed)
                if not na(up)
                    array.push(gannResists, up)
                if not na(dn)
                    array.push(gannSupports, dn)

    if showCardinal
        for c in array.from(90, 180, 270, 360)
            float up = sq9(centerPrice, c, true)
            float dn = sq9(centerPrice, c, false)
            drawLevel(up, "✚ " + str.tostring(c) + "°", colCard, line.style_solid)
            drawLevel(dn, "✚ " + str.tostring(c) + "°", colCard, line.style_solid)
            if not na(up)
                array.push(gannResists, up)
            if not na(dn)
                array.push(gannSupports, dn)

    if showDiagonal
        for dg in array.from(45, 135, 225, 315)
            float up = sq9(centerPrice, dg, true)
            float dn = sq9(centerPrice, dg, false)
            drawLevel(up, "✖ " + str.tostring(dg) + "°", colDiag, line.style_dotted)
            drawLevel(dn, "✖ " + str.tostring(dg) + "°", colDiag, line.style_dotted)
            if not na(up)
                array.push(gannResists, up)
            if not na(dn)
                array.push(gannSupports, dn)

// ═════════════════════════════════════════════════════════════════════════
// 5. SPIRAL IZGARA
// ═════════════════════════════════════════════════════════════════════════
var table grid = na

tblPos(string p) => p == "Sağ Üst" ? position.top_right : p == "Sağ Alt" ? position.bottom_right : p == "Sol Üst" ? position.top_left : position.bottom_left

if showGrid and barstate.islast and not na(centerPrice)
    int side = gridRings * 2 + 1
    if not na(grid)
        table.delete(grid)
    grid := table.new(tblPos(gridPos), side, side + 1, border_width=1)
    table.cell(grid, 0, 0, "Sq9 ⊙ " + str.tostring(math.round(centerPrice, 2)), bgcolor=color.new(color.navy, 0), text_color=color.white, text_size=size.small)

    int cx = gridRings
    int cy = gridRings
    float rootC = math.sqrt(centerPrice)

    int x = 0
    int y = 0
    int dx = 0
    int dy = -1
    int maxI = side * side
    for i = 0 to maxI - 1
        int gx = cx + x
        int gy = cy + y + 1
        if gx >= 0 and gx < side and gy >= 1 and gy <= side
            bool isCenter = x == 0 and y == 0
            bool onCardinal = x == 0 or y == 0
            bool onDiagonal = math.abs(x) == math.abs(y)
            string cellTxt = ""
            if isCenter
                cellTxt := gridMode == "Klasik Tamsayı" ? "1" : str.tostring(math.round(centerPrice, 2))
            else if gridMode == "Klasik Tamsayı"
                cellTxt := str.tostring(i + 1)
            else
                int ring = math.max(math.abs(x), math.abs(y))
                float ang = 0.0
                if x > 0
                    ang := math.atan(y / x) * 180 / math.pi
                else if x < 0 and y >= 0
                    ang := (math.atan(y / x) + math.pi) * 180 / math.pi
                else if x < 0 and y < 0
                    ang := (math.atan(y / x) - math.pi) * 180 / math.pi
                else if x == 0 and y > 0
                    ang := 90.0
                else if x == 0 and y < 0
                    ang := -90.0
                float angAdj = ang < 0 ? ang + 360 : ang
                float stepRoot = rootC + ring - 1 + angAdj / 360.0
                cellTxt := str.tostring(math.round(stepRoot * stepRoot, 2))
            color bg = isCenter ? color.new(color.navy, 0) : onCardinal ? color.new(color.blue, 65) : onDiagonal ? color.new(color.orange, 65) : color.new(color.gray, 88)
            table.cell(grid, gx, gy, cellTxt, bgcolor=bg, text_color=color.white, text_size=size.tiny)
        bool turnCond = (x == y) or (x < 0 and x == -y) or (x > 0 and x == (1 - y))
        if turnCond
            int tmp = dx
            dx := -dy
            dy := tmp
        x := x + dx
        y := y + dy

// ═════════════════════════════════════════════════════════════════════════
// 6. TREND KANALI
// ═════════════════════════════════════════════════════════════════════════
var line midLine = na
var line upLine  = na
var line lowLine = na
var label trendLbl = na
var float chUpperNow = na
var float chLowerNow = na
var int   trendDir   = 0

if showTrend and barstate.islast
    line.delete(midLine)
    line.delete(upLine)
    line.delete(lowLine)
    label.delete(trendLbl)

    float sumX = 0.0
    float sumY = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    int n = trendLen
    for k = 0 to n - 1
        float px = k
        float py = close[n - 1 - k]
        sumX  += px
        sumY  += py
        sumXY += px * py
        sumX2 += px * px
    float denom = n * sumX2 - sumX * sumX
    float slope = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0
    float intercept = (sumY - slope * sumX) / n

    float sumSq = 0.0
    for k = 0 to n - 1
        float fit = intercept + slope * k
        float dev = close[n - 1 - k] - fit
        sumSq += dev * dev
    float stdev = math.sqrt(sumSq / n)
    float band = stdev * chMult

    int xStart = bar_index - (n - 1)
    int xEnd   = bar_index
    float yStart = intercept
    float yEnd   = intercept + slope * (n - 1)

    trendDir   := slope > 0 ? 1 : -1
    chUpperNow := yEnd + band
    chLowerNow := yEnd - band

    color trendCol = slope > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
    midLine := line.new(xStart, yStart, xEnd, yEnd, color=trendCol, width=2)
    upLine  := line.new(xStart, yStart + band, xEnd, yEnd + band, color=color.new(trendCol, 50), width=1, style=line.style_dashed)
    lowLine := line.new(xStart, yStart - band, xEnd, yEnd - band, color=color.new(trendCol, 50), width=1, style=line.style_dashed)

    string trendTxt = slope > 0 ? "▲ YÜKSELİŞ" : "▼ DÜŞÜŞ"
    trendLbl := label.new(xEnd, yEnd + band, trendTxt, style=label.style_label_left, color=color.new(trendCol, 70), textcolor=trendCol, size=size.normal)

// ═════════════════════════════════════════════════════════════════════════
// 7. ⭐ A+ CONFLUENCE
// ═════════════════════════════════════════════════════════════════════════
nearestLevel(array<float> arr, float ref) =>
    float best = na
    float bestDist = na
    if array.size(arr) > 0
        for lv in arr
            float d = math.abs(lv - ref)
            if na(bestDist) or d < bestDist
                bestDist := d
                best := lv
    [best, bestDist]

var label confLbl = na
var bool aPlusLong = false
var bool aPlusShort = false

if showConf and barstate.islast and not na(chUpperNow) and not na(chLowerNow) and not na(atrVal)
    label.delete(confLbl)
    aPlusLong := false
    aPlusShort := false
    float tol = atrVal * confTol

    bool longConfirmed  = trendDir == 1  and (not requireCE or ceDir == 1)
    bool shortConfirmed = trendDir == -1 and (not requireCE or ceDir == -1)

    if longConfirmed
        [lvl, dist] = nearestLevel(gannSupports, chLowerNow)
        if not na(dist) and dist <= tol and math.abs(close - chLowerNow) <= atrVal * 1.5
            aPlusLong := true
            string ceTxt = requireCE ? "\nCE: ✓ Long" : ""
            confLbl := label.new(bar_index, low - atrVal * 0.5, "⭐ A+ LONG\nGann S: " + str.tostring(lvl, format.mintick) + ceTxt, style=label.style_label_up, color=color.new(color.green, 10), textcolor=color.white, size=size.normal)

    if shortConfirmed
        [lvl, dist] = nearestLevel(gannResists, chUpperNow)
        if not na(dist) and dist <= tol and math.abs(close - chUpperNow) <= atrVal * 1.5
            aPlusShort := true
            string ceTxt = requireCE ? "\nCE: ✓ Short" : ""
            confLbl := label.new(bar_index, high + atrVal * 0.5, "⭐ A+ SHORT\nGann R: " + str.tostring(lvl, format.mintick) + ceTxt, style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=size.normal)

// ═════════════════════════════════════════════════════════════════════════
// 8. ZAMAN DÖNGÜSÜ (bar_time tabanlı — 500 bar limiti YOK)
// ═════════════════════════════════════════════════════════════════════════
var array<line> tLines = array.new<line>()

if showTime and centerChanged and not na(centerTime) and not na(barMs) and barMs > 0
    for tl in tLines
        line.delete(tl)
    array.clear(tLines)
    float rootT = math.sqrt(centerPrice) * timeFactor
    for deg in array.from(90, 180, 270, 360)
        int barsAhead = math.round(deg / 360.0 * rootT * 4)
        if barsAhead > 0
            int tTime = centerTime + barsAhead * barMs
            line tl = line.new(tTime, low, tTime, high, xloc=xloc.bar_time, color=color.new(color.purple, 40), width=1, style=line.style_dashed, extend=extend.both)
            array.push(tLines, tl)
            if showLabels
                label lb = label.new(tTime, high, "T" + str.tostring(deg) + "°", xloc=xloc.bar_time, style=label.style_label_down, color=color.new(color.purple, 70), textcolor=color.purple, size=size.tiny)
                array.push(labels, lb)

// ═════════════════════════════════════════════════════════════════════════
// 9. ALARMLAR
// ═════════════════════════════════════════════════════════════════════════
alertcondition(aPlusLong, "A+ Long Confluence", "Gann + Kanal + CE çakışması: A+ LONG setup")
alertcondition(aPlusShort, "A+ Short Confluence", "Gann + Kanal + CE çakışması: A+ SHORT setup")
alertcondition(ceBuySignal, "CE Buy", "Chandelier Exit Buy sinyali")
alertcondition(ceSellSignal, "CE Sell", "Chandelier Exit Sell sinyali")
````
