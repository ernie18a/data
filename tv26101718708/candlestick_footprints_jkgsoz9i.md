# Candlestick Footprints

- url: https://www.tradingview.com/script/JkGsoZ9i/
- type: indicator
- pine_id: PUB;fd52c926e3d6455f84e8018caca294df
- version: 1.0

## Description

This layer builds the structural backbone of the indicator using confirmed market pivots.

Code behavior:
ta.pivothigh() detects swing highs
ta.pivotlow() detects swing lows
Both require confirmation (pivotLen delay), so they are non-repainting but lagging
Memory system:

The variables:

p1, p2, p3, p4

store the last four pivot points in sequence.

Each new pivot shifts the structure forward:

p1 → p2 → p3 → p4

Purpose:

This creates a market structural memory, allowing the system to analyze movement sequences instead of single candles.

2. CORE PROJECTION LAYER

This layer generates a directional projection based on the last impulse.

Core logic:
move = p4 - p3
proj = p4 + move
Interpretation:

The system assumes that:

the last impulse leg may repeat in magnitude

So it projects a mirrored movement forward from the last pivot.

Nature of this model:

This is a mirror impulse projection model, not a predictive statistical model.

It assumes structural repetition in price behavior.

3. CLUSTERING LAYER (CORE INTELLIGENCE)

This is the most important layer of the system.

It groups similar projected levels into liquidity zones.

Data structures:
bullMid / bullCnt → bullish clusters
bearMid / bearCnt → bearish clusters
Clustering logic:

If a new projection is close to an existing one:

abs(proj - old) < ATR * tolerance

Then:

the cluster count increases
the zone center is recalculated (averaged)
the liquidity zone becomes stronger
Outcome:

Repeated projections create:

liquidity magnet zones (price attraction areas)

4. VISUALIZATION LAYER

This layer is purely graphical.

Tools used:
box.new() for zones
label.new() for cluster information
Bull zones:
Aqua = weak bullish flow
Lime = strong bullish accumulation
Bear zones:
Red = bearish pressure zones
Important:

This layer does NOT generate trading signals.

It only visualizes clustered market structure.

5. DIRECTION LOGIC LAYER

Direction is determined by projection comparison:

isBull = proj > p4
isBear = proj < p4
Meaning:
If projection is above last pivot → bullish structure
If below → bearish structure

This is a structural direction classifier, not a momentum oscillator.

6. SYSTEM PHILOSOPHY

This indicator is not based on traditional technical indicators.

It does NOT use:

Moving averages
RSI
MACD

Instead, it focuses on:

structural repetition
pivot-based memory
clustering of projected price levels
Core idea:

Markets tend to revisit structurally repeated zones rather than random levels.

7. FINAL SYSTEM OUTPUT

The system produces:

Liquidity zones
Cluster strength (count-based)
Directional bias (bull/bear)
Visual heatmap of price memory
Final interpretation:

This is a structural probability map of where price tends to accumulate and react.

🇹🇷 TÜRKÇE AÇIKLAMA (TAM KATMANLI)
1. PIVOT YAPISI KATMANI

Bu katman sistemin iskeletini oluşturur ve piyasa pivotlarını kullanır.

Çalışma mantığı:
ta.pivothigh() swing high noktalarını bulur
ta.pivotlow() swing low noktalarını bulur
Pivotlar onaylıdır, bu yüzden gecikmelidir ama repaint yapmaz
Hafıza sistemi:
p1, p2, p3, p4

son 4 pivotu saklar.

Her yeni pivot geldiğinde yapı kayar:

p1 → p2 → p3 → p4

Amaç:

Bu yapı, tek mum değil:

piyasanın hareket dizisini analiz eden bir hafıza sistemi oluşturur

2. PROJEKSİYON KATMANI

Bu katman son hareketi baz alarak ileri projeksiyon üretir.

Temel hesap:
move = p4 - p3
proj = p4 + move
Mantık:

Sistem şunu varsayar:

son impuls hareket tekrar edebilir

Bu yüzden aynı hareketi ileri taşır.

Model tipi:

Bu bir:

ayna hareket projeksiyon modelidir

3. CLUSTER (KÜMELEME) KATMANI

Sistemin en önemli kısmıdır.

Benzer projeksiyonları aynı bölgede toplar.

Veri yapıları:
bullMid / bullCnt → bullish bölgeler
bearMid / bearCnt → bearish bölgeler
Çalışma mantığı:

Eğer yeni proje eski bölgeye yakınsa:

abs(proj - old) < ATR toleransı

Şunlar olur:

cluster sayısı artar
merkez yeniden hesaplanır
bölge güçlenir
Sonuç:

Tekrarlanan fiyat bölgeleri:

likidite mıknatıs alanları oluşturur

4. GÖRSELLEŞTİRME KATMANI

Bu katman sadece görsel sunum yapar.

Araçlar:
box.new() → zone çizimi
label.new() → bilgi etiketi
Bull bölgeler:
Aqua = zayıf bullish akış
Lime = güçlü bullish birikim
Bear bölgeler:
Red = satış baskısı
Önemli:

Bu katman sinyal üretmez.

Sadece yapıyı görselleştirir.

5. YÖN MANTIĞI KATMANI

Yön projeksiyona göre belirlenir:

isBull = proj > p4
isBear = proj < p4
Anlamı:
yukarı projeksiyon → bullish yapı
aşağı projeksiyon → bearish yapı

Bu bir momentum değil:

yapısal yön sınıflandırmasıdır

6. SİSTEM FELSEFESİ

Bu indicator klasik teknik analiz değildir.

Şunları kullanmaz:

MA (hareketli ortalama)
RSI
MACD

Bunun yerine:

piyasa tekrarları
pivot hafızası
cluster davranışı

kullanır.

Temel fikir:

Piyasa rastgele değil:

belirli yapısal bölgeleri tekrar ziyaret eder

7. SONUÇ

Sistem şunları üretir:

likidite bölgeleri
cluster gücü
yön biası (bull/bear)
fiyatın hafıza haritası
Final yorum:

Bu sistem fiyatın nerede reaksiyon verme ihtimalinin yüksek olduğunu gösteren yapısal bir olasılık haritasıdır.

## Source Code

````pine
//@version=5
indicator("KOTAN Resonance Final Clean", overlay=true, max_boxes_count=300, max_labels_count=300)

//====================================================
// INPUTS
//====================================================

pivotLen     = input.int(5, "Pivot Length", minval=2)
toleranceATR = input.float(1.5, "Cluster Tolerance ATR")
minCluster   = input.int(2, "Min Cluster")

atrValue = ta.atr(14)

//====================================================
// PIVOTS
//====================================================

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float p1 = na
var float p2 = na
var float p3 = na
var float p4 = na

newPivot = false

if not na(ph)
    p1 := p2
    p2 := p3
    p3 := p4
    p4 := ph
    newPivot := true

if not na(pl)
    p1 := p2
    p2 := p3
    p3 := p4
    p4 := pl
    newPivot := true

//====================================================
// STORAGE
//====================================================

var float[] bullMid = array.new_float()
var int[] bullCnt   = array.new_int()

var float[] bearMid = array.new_float()
var int[] bearCnt   = array.new_int()

//====================================================
// CORE PROJECTION
//====================================================

if newPivot and not na(p1) and not na(p2) and not na(p3) and not na(p4)

    move = p4 - p3
    proj = p4 + move

    isBull = proj > p4
    isBear = proj < p4

    //========================
    // BULL
    //========================

    if isBull

        found = false

        if array.size(bullMid) > 0

            for i = 0 to array.size(bullMid) - 1

                old = array.get(bullMid, i)

                if math.abs(proj - old) < atrValue * toleranceATR

                    array.set(bullCnt, i, array.get(bullCnt, i) + 1)
                    array.set(bullMid, i, (old + proj) / 2)

                    found := true

        if not found
            array.push(bullMid, proj)
            array.push(bullCnt, 1)

    //========================
    // BEAR
    //========================

    if isBear

        found = false

        if array.size(bearMid) > 0

            for i = 0 to array.size(bearMid) - 1

                old = array.get(bearMid, i)

                if math.abs(proj - old) < atrValue * toleranceATR

                    array.set(bearCnt, i, array.get(bearCnt, i) + 1)
                    array.set(bearMid, i, (old + proj) / 2)

                    found := true

        if not found
            array.push(bearMid, proj)
            array.push(bearCnt, 1)

//====================================================
// DRAW BULL ZONES (AQUA / LIME)
//====================================================

if array.size(bullMid) > 0

    for i = 0 to array.size(bullMid) - 1

        c = array.get(bullCnt, i)

        if c >= minCluster

            m = array.get(bullMid, i)

            col = c >= 5 ? color.lime : color.aqua

            box.new(
                 left = bar_index - 20,
                 right = bar_index + 20,
                 top = m + atrValue,
                 bottom = m - atrValue,
                 bgcolor = color.new(col, 97),     // 🔥 ghost layer
                 border_color = color.new(col, 100),
                 border_width = 0)

            label.new(
                 x = bar_index + 8,
                 y = m,
                 text = c >= 5 ? "🟢 STRONG BULL ×" + str.tostring(c)
                               : "🔵 AQUA FLOW ×" + str.tostring(c),
                 style = label.style_label_left,
                 color = col,
                 textcolor = color.white,
                 size = size.small)

//====================================================
// DRAW BEAR ZONES
//====================================================

if array.size(bearMid) > 0

    for i = 0 to array.size(bearMid) - 1

        c = array.get(bearCnt, i)

        if c >= minCluster

            m = array.get(bearMid, i)

            box.new(
                 left = bar_index - 20,
                 right = bar_index + 20,
                 top = m + atrValue,
                 bottom = m - atrValue,
                 bgcolor = color.new(color.red, 97),   // 🔥 ghost layer
                 border_color = color.new(color.red, 100),
                 border_width = 0)

            label.new(
                 x = bar_index + 8,
                 y = m,
                 text = "🔴 BEAR ×" + str.tostring(c),
                 style = label.style_label_left,
                 color = color.red,
                 textcolor = color.white,
                 size = size.small)
````
