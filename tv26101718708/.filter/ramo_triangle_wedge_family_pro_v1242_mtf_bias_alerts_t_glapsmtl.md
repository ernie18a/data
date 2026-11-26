# RAMO Triangle & Wedge Family Pro V1.2.4.2 - MTF Bias, Alerts & T

- url: https://www.tradingview.com/script/GlApsmtl/
- type: indicator
- pine_id: PUB;a3fc42ff7d7f48fc8725da64d28cf314
- version: 1.0

## Description

RAMO Triangle & Wedge Family Pro V1.2.4.2 is an advanced pattern-detection indicator designed to identify, classify, and monitor triangle and wedge formations with multi-timeframe context.

The script currently supports:

Ascending Triangle
Descending Triangle
Symmetrical Triangle
Rising Wedge
Falling Wedge

The detection engine is based on confirmed pivot structures, multi-candidate boundary analysis, convergence, touch quality, containment, pattern duration, apex position, and structural validation. Instead of forcing every consolidation into a pattern, the system attempts to reject weak or inconsistent geometry.

For ascending and descending triangles, horizontal support/resistance areas are additionally validated using pivot clustering rather than relying only on trendline slope.

For symmetrical triangles, direction is intentionally kept neutral before a confirmed breakout. A separate multi-timeframe RSI and volume bias system evaluates larger timeframes to provide a directional preference such as LONG or SHORT bias without treating that bias as a confirmed trade signal. The actual direction is still determined by a confirmed breakout.

The indicator also includes a parent/child timeframe structure check. Lower-timeframe formations can be compared with larger-timeframe structures to reduce conflicting classifications when both charts are showing the same broader pattern.

Breakout and Retest Logic

Breakouts are evaluated using candle closes rather than wick-only movements. After a confirmed breakout, the indicator can track a possible retest and update the formation state accordingly.

The panel displays:

Pattern type
Pattern stage
Confidence score
Direction / MTF bias
Entry reference
Alarm level
Stop reference
Target
Touch count / formation progress
Pattern detected on another relevant timeframe

For symmetrical triangles, both possible upside and downside targets may be displayed before the breakout. Once direction is confirmed, the active target is updated accordingly.

Wedge Direction Logic

Rising Wedge: bearish / SHORT bias after downside confirmation.

Falling Wedge: bullish / LONG bias after upside confirmation.

The wedge engine operates separately from the triangle-selection engine so that wedge candidates do not distort or replace otherwise valid triangle geometry.

Alerts

The script provides alert conditions for:

LONG breakout
SHORT breakout
New triangle or wedge structure
Rising wedge detection
Falling wedge detection
Retest
Failed breakout

The displayed alarm level is intended to show the price area where the relevant breakout or retest condition becomes important.

Important Disclaimer

This indicator is provided for educational, informational, and technical-analysis purposes only. It does not constitute financial or investment advice and is not a recommendation to buy, sell, or hold any financial asset.

Pattern detection, RSI/volume bias, entry references, alarm levels, stop levels, breakout conditions, and projected targets are technical calculations only and may fail or produce false signals. Historical pattern behavior does not guarantee future results.

Always perform your own research and use appropriate risk management before making any trading or investment decision.

Comments and suggestions for improving the indicator are always welcome.

## Source Code

````pine
//@version=6
indicator("RAMO ÜÇGEN + TAKOZ AİLESİ PRO V1.2.4.2 | TARGET PREVIEW FIX", overlay = true, max_bars_back = 3000, max_lines_count = 40, max_labels_count = 40)

//=====================================================================
// 1. GENEL
//=====================================================================
grpGeneral = "1 - Genel"

confirmedOnly   = input.bool(true, "Sadece Mum Kapanışında Sinyal", group = grpGeneral)
showPanel       = input.bool(true, "Küçük Bilgi Panosu", group = grpGeneral)
showOtherTF     = input.bool(true, "Diğer TF Üçgenini Panoda Göster", group = grpGeneral)
showTriangle    = input.bool(true, "Üçgen / Takoz Sınırlarını Göster", group = grpGeneral)
showLevels      = input.bool(true, "Alarm / Stop / Hedef", group = grpGeneral)
showDebug       = input.bool(false, "DEBUG Bilgisi", group = grpGeneral)

minCandidateScore = input.float(64.0, "Minimum Üçgen Skoru", minval = 40.0, maxval = 95.0, step = 1.0, group = grpGeneral)

//=====================================================================
// 2. ÇOK ÖLÇEKLİ SWING / PIVOT MOTORU
//=====================================================================
grpPivot = "2 - Swing / Pivot"

pivotFast  = input.int(3, "Mikro Pivot", minval = 2, maxval = 6, group = grpPivot)
pivotBase  = input.int(5, "Ana Pivot", minval = 3, maxval = 10, group = grpPivot)
pivotMacro = input.int(8, "Makro Pivot", minval = 5, maxval = 15, group = grpPivot)

maxPivots       = input.int(9, "Hafızadaki Tepe/Dip", minval = 6, maxval = 14, group = grpPivot)
clusterBars     = input.int(2, "Pivot Birleştirme Barı", minval = 0, maxval = 5, group = grpPivot)
clusterTolATR   = input.float(0.45, "Pivot Birleştirme ATR", minval = 0.10, maxval = 1.50, step = 0.05, group = grpPivot)
minAnchorGap    = input.int(8, "Çizgi Anchor Min Bar", minval = 3, maxval = 40, group = grpPivot)

//=====================================================================
// 3. ÜÇGEN GEOMETRİSİ
//=====================================================================
grpTri = "3 - Üçgen Geometrisi"

atrLen             = input.int(14, "ATR", minval = 5, maxval = 50, group = grpTri)
minPatternBars     = input.int(18, "Minimum Üçgen Süresi", minval = 10, maxval = 120, group = grpTri)
maxPatternBars     = input.int(240, "Maksimum Üçgen Süresi", minval = 60, maxval = 600, group = grpTri)
minHeightATR       = input.float(2.0, "Minimum Başlangıç Yüksekliği ATR", minval = 0.8, maxval = 8.0, step = 0.1, group = grpTri)

lineTolATR         = input.float(0.65, "Sınır Temas Toleransı ATR", minval = 0.20, maxval = 1.50, step = 0.05, group = grpTri)
lineTolPct         = input.float(0.35, "Sınır Temas Toleransı %", minval = 0.05, maxval = 1.50, step = 0.05, group = grpTri)
minContainment     = input.float(72.0, "Minimum İçeride Kalma %", minval = 50.0, maxval = 95.0, step = 1.0, group = grpTri)

flatSlopeATR       = input.float(0.040, "Yatay Sınır Eşiği ATR/Bar", minval = 0.005, maxval = 0.15, step = 0.005, group = grpTri)
minSlopeATR        = input.float(0.015, "Minimum Eğik Sınır ATR/Bar", minval = 0.005, maxval = 0.15, step = 0.005, group = grpTri)

minContractionPct  = input.float(10.0, "Minimum Daralma %", minval = 5.0, maxval = 50.0, step = 1.0, group = grpTri)
minProgressPct     = input.float(22.0, "Minimum Apex İlerlemesi %", minval = 10.0, maxval = 50.0, step = 1.0, group = grpTri)
maxProgressPct     = input.float(94.0, "Maksimum Apex İlerlemesi %", minval = 70.0, maxval = 99.0, step = 1.0, group = grpTri)
minBreakProgress   = input.float(32.0, "Breakout İçin Min Apex İlerlemesi %", minval = 15.0, maxval = 70.0, step = 1.0, group = grpTri)

macroDominanceRatio = input.float(1.35, "Büyük Yapı Span Üstünlüğü", minval = 1.10, maxval = 2.0, step = 0.05, group = grpTri)
macroScoreSlack     = input.float(8.0, "Büyük Yapı Skor Toleransı", minval = 0.0, maxval = 20.0, step = 0.5, group = grpTri)

// Yükselen/alçalan üçgende yatay taraf yalnız slope ile değil,
// gerçek pivot kümelenmesiyle doğrulanır.
flatZoneMinTouches = input.int(3, "Yatay Zone Min Pivot", minval = 2, maxval = 6, group = grpTri)
flatZoneMinSpanPct = input.float(28.0, "Yatay Zone Min Zaman Yayılımı %", minval = 10.0, maxval = 70.0, step = 1.0, group = grpTri)
flatZoneTolATR = input.float(0.70, "Yatay Zone Toleransı ATR", minval = 0.20, maxval = 1.50, step = 0.05, group = grpTri)
flatZoneMaxRecentAgePct = input.float(32.0, "Yatay Zone Son Temas Max Yaşı %", minval = 10.0, maxval = 60.0, step = 1.0, group = grpTri)

// Simetrik üçgende trend çizgisinin pivot tepelerini/diplerini kesmesine ceza.
envelopeTolATR = input.float(0.35, "Simetrik Sınır İhlal Toleransı ATR", minval = 0.10, maxval = 1.0, step = 0.05, group = grpTri)
envelopePenaltyPerPivot = input.float(4.0, "Sınır İhlali Başına Skor Cezası", minval = 1.0, maxval = 10.0, step = 0.5, group = grpTri)

// Alt TF aynı ana yapıyı yeniden ve yanlış sınıflandırmasın.
useParentCoherence = input.bool(true, "1H/2H Parent Yapı Uyum Kontrolü", group = grpTri)
parentMinDurationRatio = input.float(0.58, "Parent Min Süre Benzerliği", minval = 0.30, maxval = 0.95, step = 0.02, group = grpTri)
parentMidTolATR = input.float(1.60, "Parent Orta Hat Toleransı ATR", minval = 0.50, maxval = 4.0, step = 0.10, group = grpTri)
parentScoreSlack = input.float(10.0, "Parent Skor Toleransı", minval = 0.0, maxval = 25.0, step = 0.5, group = grpTri)

//=====================================================================
// 4. TAKOZ — AYRI MOTOR
//=====================================================================
grpWedge = "4 - Takoz"

useWedges = input.bool(true, "Yükselen / Düşen Takoz", group = grpWedge)
wedgeMinSlopeGapATR = input.float(0.012, "Minimum Yakınsama Eğim Farkı ATR/Bar", minval = 0.002, maxval = 0.10, step = 0.002, group = grpWedge)
wedgeMinSlopeRatio = input.float(1.20, "Minimum Takoz Eğim Oranı", minval = 1.02, maxval = 3.0, step = 0.05, group = grpWedge)
wedgeMaxSlopeRatio = input.float(5.0, "Maksimum Takoz Eğim Oranı", minval = 2.0, maxval = 12.0, step = 0.25, group = grpWedge)
wedgeMinContractionPct = input.float(18.0, "Minimum Takoz Daralması %", minval = 8.0, maxval = 60.0, step = 1.0, group = grpWedge)

//=====================================================================
// 5. SİMETRİK ÜÇGEN MTF YÖN BIAS
//=====================================================================
grpBias = "5 - Simetrik Üçgen MTF Bias"

useMtfBias = input.bool(true, "Simetrik Üçgende MTF RSI + Hacim Bias", group = grpBias)
biasRsiLen = input.int(14, "RSI Periyodu", minval = 5, maxval = 50, group = grpBias)
biasVolLen = input.int(20, "Ortalama Hacim Periyodu", minval = 5, maxval = 100, group = grpBias)
biasRsiBull = input.float(55.0, "RSI LONG Eşiği", minval = 50.0, maxval = 70.0, step = 0.5, group = grpBias)
biasRsiBear = input.float(45.0, "RSI SHORT Eşiği", minval = 30.0, maxval = 50.0, step = 0.5, group = grpBias)
biasMinRvol = input.float(1.05, "Hacim Etkisi İçin Min RVOL", minval = 0.80, maxval = 2.0, step = 0.05, group = grpBias)
biasThreshold = input.float(18.0, "LONG/SHORT Bias Eşiği", minval = 5.0, maxval = 50.0, step = 1.0, group = grpBias)

//=====================================================================
// 6. BREAKOUT / RETEST / RİSK
//=====================================================================
grpTrade = "6 - Breakout / Retest"

breakBufferPct = input.float(0.15, "Breakout Buffer %", minval = 0.02, maxval = 1.0, step = 0.01, group = grpTrade)
breakBufferATR = input.float(0.18, "Breakout Buffer ATR", minval = 0.05, maxval = 1.0, step = 0.01, group = grpTrade)
retestTolPct   = input.float(0.75, "Retest Toleransı %", minval = 0.10, maxval = 2.5, step = 0.05, group = grpTrade)
retestBars     = input.int(20, "Retest İzleme Barı", minval = 3, maxval = 60, group = grpTrade)
failATR        = input.float(0.35, "Failed Breakout ATR", minval = 0.10, maxval = 1.5, step = 0.05, group = grpTrade)

earlyNearATR   = input.float(0.80, "Erken Giriş Sınır Yakınlığı ATR", minval = 0.25, maxval = 2.0, step = 0.05, group = grpTrade)
entryBufferATR = input.float(0.10, "Giriş Buffer ATR", minval = 0.0, maxval = 0.5, step = 0.01, group = grpTrade)
stopBufferATR  = input.float(0.55, "Stop Buffer ATR", minval = 0.15, maxval = 2.0, step = 0.05, group = grpTrade)
maxRiskPct     = input.float(4.5, "Maksimum Stop Riski %", minval = 1.0, maxval = 12.0, step = 0.1, group = grpTrade)
maxRiskATR     = input.float(3.0, "Maksimum Stop Mesafesi ATR", minval = 0.5, maxval = 6.0, step = 0.1, group = grpTrade)

atr = ta.atr(atrLen)

//=====================================================================
// 5. SONUÇ TİPİ
//=====================================================================
type RamoPatternResult
    bool valid = false
    int kind = 0                      // 1=Yükselen Üçgen, 2=Alçalan Üçgen, 3=Simetrik, 4=Yükselen Takoz, 5=Düşen Takoz
    float score = 0.0                  // Görünen güven puanı
    float selectScore = 0.0            // Geometri seçimi için V1.0.1 uyumlu puan
    int key = 0

    int startBar = na
    int endBar = na
    int spanBars = 0

    int hOldBar = na
    int hNewBar = na
    int lOldBar = na
    int lNewBar = na
    float hOld = na
    float hNew = na
    float lOld = na
    float lNew = na

    float upperSlope = na
    float lowerSlope = na
    float upperIntercept = na
    float lowerIntercept = na
    float upperNow = na
    float lowerNow = na

    float startWidth = na
    float nowWidth = na
    float contractionPct = 0.0
    float apexBar = na
    float progressPct = 0.0

    int upperTouches = 0
    int lowerTouches = 0
    float containment = 0.0
    float touchQuality = 0.0
    float slopeQuality = 0.0

    float internalHigh = na
    float internalLow = na

f_emptyPatternResult() =>
    RamoPatternResult.new()

//=====================================================================
// 6. YARDIMCI FONKSİYONLAR
//=====================================================================
f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_tfLabel(string tf) =>
    string out = tf
    if tf == "60"
        out := "1H"
    else if tf == "120"
        out := "2H"
    else if tf == "240"
        out := "4H"
    else if tf == "360"
        out := "6H"
    else if tf == "720"
        out := "12H"
    else if tf == "1D"
        out := "1D"
    else if tf == "3D"
        out := "3D"
    else if tf == "1W"
        out := "1W"
    out

f_tfMinutes(string tf) =>
    float out = 0.0
    if tf == "60"
        out := 60.0
    else if tf == "120"
        out := 120.0
    else if tf == "240"
        out := 240.0
    else if tf == "360"
        out := 360.0
    else if tf == "720"
        out := 720.0
    else if tf == "1D"
        out := 1440.0
    else if tf == "3D"
        out := 4320.0
    else if tf == "1W"
        out := 10080.0
    out

// Son kapanmış barın relative volume değeri.
f_rvolNow() =>
    float avgVol = ta.sma(volume, biasVolLen)
    float out = 1.0
    if not na(volume) and not na(avgVol) and avgVol > 0
        out := volume / avgVol
    out

// request.security() içinde kullanılacak CONFIRMED değerler.
// [1] + lookahead_on = yalnız kapanmış HTF barı.
f_ctxRsiConfirmed() =>
    float r = ta.rsi(close, biasRsiLen)
    r[1]

f_ctxRvolConfirmed() =>
    float rv = f_rvolNow()
    rv[1]

f_ctxDirConfirmed() =>
    float d = 0.0
    if close > open
        d := 1.0
    else if close < open
        d := -1.0
    d[1]

// RSI'ı -1..+1 bias sinyaline çevir.
// 45-55 civarı nötr banttır.
f_rsiBias(float r) =>
    float out = 0.0
    if not na(r)
        if r >= biasRsiBull
            out := f_clamp((r - 50.0) / 20.0, 0.0, 1.0)
        else if r <= biasRsiBear
            out := -f_clamp((50.0 - r) / 20.0, 0.0, 1.0)
    out

// Hacim tek başına yön söylemez.
// Yalnız RVOL yükselmişse kapanan mum yönü kadar katkı verir.
f_volBias(float rv, float candleDir) =>
    float out = 0.0
    if not na(rv) and rv >= biasMinRvol and candleDir != 0.0
        float strength = f_clamp((rv - biasMinRvol) / 1.25, 0.0, 1.0)
        out := candleDir * strength
    out

f_contextBias(float rsiValue, float rv, float candleDir) =>
    f_rsiBias(rsiValue) * 0.70 + f_volBias(rv, candleDir) * 0.30

f_lineAt(float m, float q, int x) =>
    m * float(x) + q

f_pairRiskOK(float entry, float stop, bool isLong) =>
    bool directionOK = not na(entry) and not na(stop) and (isLong ? stop < entry : stop > entry)
    float riskPct = directionOK ? math.abs(entry - stop) / math.max(math.abs(entry), syminfo.mintick) * 100.0 : 999.0
    float riskATR = directionOK ? math.abs(entry - stop) / math.max(atr, syminfo.mintick) : 999.0
    directionOK and riskPct <= maxRiskPct and riskATR <= maxRiskATR

// Çok ölçekli pivotlar aynı swing ise tek pivotta birleştirilir.
// Yeni gelen pivot kronolojik sıraya yerleştirilir; dizi en yeni -> en eski sıralıdır.
f_addPivot(array<float> vals, array<int> bars, array<int> scales, array<float> atrs, float v, int b, int sc, float a, bool isHigh) =>
    bool merged = false
    int n = array.size(bars)

    if n > 0
        for i = 0 to n - 1
            int eb = array.get(bars, i)
            float ev = array.get(vals, i)
            float ea = array.get(atrs, i)
            float tol = math.max(math.max(a, ea) * clusterTolATR, syminfo.mintick * 3.0)

            if math.abs(b - eb) <= clusterBars and math.abs(v - ev) <= tol
                float nv = isHigh ? math.max(v, ev) : math.min(v, ev)
                int ns = math.max(sc, array.get(scales, i))
                float nax = math.max(a, ea)
                array.set(vals, i, nv)
                array.set(scales, i, ns)
                array.set(atrs, i, nax)
                merged := true
                break

    if not merged
        int insertAt = array.size(bars)
        int sz = array.size(bars)

        if sz > 0
            for i = 0 to sz - 1
                if b > array.get(bars, i)
                    insertAt := i
                    break

        array.insert(vals, insertAt, v)
        array.insert(bars, insertAt, b)
        array.insert(scales, insertAt, sc)
        array.insert(atrs, insertAt, a)

        if array.size(bars) > maxPivots
            array.pop(vals)
            array.pop(bars)
            array.pop(scales)
            array.pop(atrs)

// Bir çizgiye gerçek pivot temaslarını say.
// Anchor dışındaki pivotların da aynı sınıra oturması kaliteyi yükseltir.
f_touchStats(bool upperSide, float m, float q, int patternStart,
             array<float> hVals, array<int> hBars, array<float> hAtrs,
             array<float> lVals, array<int> lBars, array<float> lAtrs) =>
    int touches = 0
    float errSum = 0.0

    if upperSide
        int n = array.size(hBars)
        if n > 0
            for i = 0 to n - 1
                int pb = array.get(hBars, i)
                if pb >= patternStart and pb <= bar_index
                    float pv = array.get(hVals, i)
                    float pa = array.get(hAtrs, i)
                    float ly = f_lineAt(m, q, pb)
                    float tol = math.max(pa * lineTolATR, math.abs(ly) * lineTolPct / 100.0)
                    float err = math.abs(pv - ly)
                    if err <= tol
                        touches += 1
                        errSum += err / math.max(tol, syminfo.mintick)
    else
        int n = array.size(lBars)
        if n > 0
            for i = 0 to n - 1
                int pb = array.get(lBars, i)
                if pb >= patternStart and pb <= bar_index
                    float pv = array.get(lVals, i)
                    float pa = array.get(lAtrs, i)
                    float ly = f_lineAt(m, q, pb)
                    float tol = math.max(pa * lineTolATR, math.abs(ly) * lineTolPct / 100.0)
                    float err = math.abs(pv - ly)
                    if err <= tol
                        touches += 1
                        errSum += err / math.max(tol, syminfo.mintick)

    float fit = touches > 0 ? f_clamp(100.0 - (errSum / float(touches)) * 100.0, 0.0, 100.0) : 0.0
    [touches, fit]

// Fiyatın üçgen havzasında gerçekten iki sınır arasında kalıp kalmadığını
// 11 örnek noktayla ölç. Bu kontrol anchor seçildikten SONRA değil,
// HER aday kombinasyonunda yapılır.
f_containment(float uM, float uQ, float lM, float lQ, int startB, int endB) =>
    int samples = 0
    int inside = 0

    if endB > startB
        int span = endB - startB
        for k = 0 to 10
            int x = startB + int(math.round(float(k) / 10.0 * float(span)))
            int off = bar_index - x

            if off >= 0 and off <= bar_index
                float u = f_lineAt(uM, uQ, x)
                float d = f_lineAt(lM, lQ, x)
                float a = atr[off]
                float tol = math.max(a * lineTolATR, math.max(math.abs(u), math.abs(d)) * lineTolPct / 100.0)

                if u > d and not na(high[off]) and not na(low[off])
                    samples += 1
                    if high[off] <= u + tol and low[off] >= d - tol
                        inside += 1

    samples > 0 ? float(inside) / float(samples) * 100.0 : 0.0

// Simetrik üçgende yalnız diagonal çizgi kırılımı yetmez.
// En yeni "iç" swing de kırılmalı.
f_internalSwing(bool wantHigh, float m, float q, int patternStart,
                array<float> hVals, array<int> hBars, array<float> hAtrs,
                array<float> lVals, array<int> lBars, array<float> lAtrs) =>
    float found = na

    if wantHigh
        int n = array.size(hBars)
        if n > 0
            for i = 0 to n - 1
                int pb = array.get(hBars, i)
                if pb >= patternStart and pb <= bar_index
                    float pv = array.get(hVals, i)
                    float pa = array.get(hAtrs, i)
                    float ly = f_lineAt(m, q, pb)
                    float tol = math.max(pa * lineTolATR, math.abs(ly) * lineTolPct / 100.0)

                    if math.abs(pv - ly) > tol * 1.35
                        found := pv
                        break
    else
        int n = array.size(lBars)
        if n > 0
            for i = 0 to n - 1
                int pb = array.get(lBars, i)
                if pb >= patternStart and pb <= bar_index
                    float pv = array.get(lVals, i)
                    float pa = array.get(lAtrs, i)
                    float ly = f_lineAt(m, q, pb)
                    float tol = math.max(pa * lineTolATR, math.abs(ly) * lineTolPct / 100.0)

                    if math.abs(pv - ly) > tol * 1.35
                        found := pv
                        break

    found

// Dört anchorın en az bir kez upper-lower-upper veya lower-upper-lower
// sıralaması üretmesi istenir. Bu "çizgiler yaklaşıyor" ama fiyatın
// gerçekten salınmadığı sahte geometrileri azaltır.
f_anchorAlternates(int hOldB, int hNewB, int lOldB, int lNewB) =>
    bool a = hOldB < lOldB and lOldB < hNewB
    bool b = lOldB < hOldB and hOldB < lNewB
    bool c = hOldB < lNewB and lNewB < hNewB
    bool d = lOldB < hNewB and hNewB < lNewB
    a or b or c or d

// Yatay tarafta gerçek pivot cluster/zone doğrulaması.
// Aynı mikro salınımdaki çok yakın pivotlar tek temas sayılır.
f_flatZoneStats(float center, int patternStart, int patternBars,
                array<float> vals, array<int> bars, array<float> atrs) =>
    int count = 0
    int newestAccepted = na
    int oldestAccepted = na
    int lastAccepted = na

    int dynamicGap = math.max(2, int(math.round(float(patternBars) * 0.08)))
    int n = array.size(bars)

    if n > 0
        for i = 0 to n - 1
            int pb = array.get(bars, i)

            if pb >= patternStart and pb <= bar_index
                float pv = array.get(vals, i)
                float pa = array.get(atrs, i)
                float tol = math.max(pa * flatZoneTolATR, math.abs(center) * lineTolPct / 100.0)

                if math.abs(pv - center) <= tol
                    bool gapOK = na(lastAccepted) or math.abs(pb - lastAccepted) >= dynamicGap

                    if gapOK
                        count += 1
                        lastAccepted := pb

                        if na(newestAccepted)
                            newestAccepted := pb

                        oldestAccepted := pb

    int span = count >= 2 and not na(newestAccepted) and not na(oldestAccepted) ? math.abs(newestAccepted - oldestAccepted) : 0
    float spreadPct = patternBars > 0 ? float(span) / float(patternBars) * 100.0 : 0.0
    float recentAgePct = patternBars > 0 and not na(newestAccepted) ? float(bar_index - newestAccepted) / float(patternBars) * 100.0 : 999.0
    [count, spreadPct, recentAgePct]

// Simetrik üçgende çizginin anlamlı pivotları "kesmesini" say.
// Üst sınır pivot tepesinin altında, alt sınır pivot dibinin üstünde kalırsa ihlal.
f_envelopeViolations(bool upperSide, float m, float q, int patternStart,
                     array<float> vals, array<int> bars, array<float> atrs) =>
    int violations = 0
    int n = array.size(bars)

    if n > 0
        for i = 0 to n - 1
            int pb = array.get(bars, i)

            if pb >= patternStart and pb <= bar_index
                float pv = array.get(vals, i)
                float pa = array.get(atrs, i)
                float ly = f_lineAt(m, q, pb)
                float tol = math.max(pa * envelopeTolATR, math.abs(ly) * 0.10 / 100.0)

                if upperSide
                    if pv > ly + tol
                        violations += 1
                else
                    if pv < ly - tol
                        violations += 1

    violations

//=====================================================================
// 7. PIVOT HAFIZASI
// Pivot belleği aşağıdaki f_triangleEngine() içinde tutulur.
// Böylece ana TF ve istenen diğer TF birbirinin pivotlarını karıştırmaz.
//=====================================================================

//=====================================================================
// 8. ADAY DEĞERLENDİRME
//=====================================================================
f_evalCandidate(int hOldIdx, int hNewIdx, int lOldIdx, int lNewIdx,
                array<float> hVals, array<int> hBars, array<int> hScales, array<float> hAtrs,
                array<float> lVals, array<int> lBars, array<int> lScales, array<float> lAtrs) =>
    RamoPatternResult r = f_emptyPatternResult()

    int hOB = array.get(hBars, hOldIdx)
    int hNB = array.get(hBars, hNewIdx)
    int lOB = array.get(lBars, lOldIdx)
    int lNB = array.get(lBars, lNewIdx)

    float hO = array.get(hVals, hOldIdx)
    float hN = array.get(hVals, hNewIdx)
    float lO = array.get(lVals, lOldIdx)
    float lN = array.get(lVals, lNewIdx)

    bool anchorOrderOK = hOB < hNB and lOB < lNB
    bool anchorGapOK = hNB - hOB >= minAnchorGap and lNB - lOB >= minAnchorGap

    if anchorOrderOK and anchorGapOK
        float uM = (hN - hO) / float(hNB - hOB)
        float lM = (lN - lO) / float(lNB - lOB)
        float uQ = hO - uM * float(hOB)
        float lQ = lO - lM * float(lOB)

        int startB = math.min(hOB, lOB)
        int geomEndB = math.max(hNB, lNB)
        int patternBars = bar_index - startB

        float atrSafe = math.max(atr, syminfo.mintick)
        float uN = uM / atrSafe
        float lNrm = lM / atrSafe

        // --------------------------------------------------------------
        // GEOMETRY LOCK:
        // selectionKind V1.0.1'deki eski sınıflandırma sırasını yalnızca
        // aday çizgi puanlamak için korur. Böylece classifier düzeltmesi
        // seçilen upper/lower sınırları değiştirmez.
        // --------------------------------------------------------------
        bool selUpperFlat = math.abs(uN) <= flatSlopeATR
        bool selLowerFlat = math.abs(lNrm) <= flatSlopeATR
        bool selUpperDown = uN <= -minSlopeATR
        bool selLowerUp = lNrm >= minSlopeATR

        int selectionKind = 0
        if selUpperFlat and selLowerUp
            selectionKind := 1
        else if selUpperDown and selLowerFlat
            selectionKind := 2
        else if selUpperDown and selLowerUp
            selectionKind := 3

        // --------------------------------------------------------------
        // DISPLAY CLASSIFIER:
        // Geometri seçildikten sonra isim mutually-exclusive sınıflanır.
        // Örn. -0.025 artık aynı anda FLAT ve DOWN olamaz.
        // --------------------------------------------------------------
        bool clsUpperDown = uN <= -minSlopeATR
        bool clsUpperUp = uN >= minSlopeATR
        bool clsLowerUp = lNrm >= minSlopeATR
        bool clsLowerDown = lNrm <= -minSlopeATR

        bool clsUpperFlat = not clsUpperDown and not clsUpperUp and math.abs(uN) <= flatSlopeATR
        bool clsLowerFlat = not clsLowerUp and not clsLowerDown and math.abs(lNrm) <= flatSlopeATR

        int displayKind = 0
        if clsUpperDown and clsLowerUp
            displayKind := 3
        else if clsUpperFlat and clsLowerUp
            displayKind := 1
        else if clsUpperDown and clsLowerFlat
            displayKind := 2

        bool convergingDirection = lM > uM

        if selectionKind != 0 and displayKind != 0 and convergingDirection and patternBars >= minPatternBars and patternBars <= maxPatternBars
            float uStart = f_lineAt(uM, uQ, startB)
            float dStart = f_lineAt(lM, lQ, startB)
            float uNow = f_lineAt(uM, uQ, bar_index)
            float dNow = f_lineAt(lM, lQ, bar_index)

            float startWidth = uStart - dStart
            float nowWidth = uNow - dNow
            float contraction = startWidth > syminfo.mintick ? (1.0 - nowWidth / startWidth) * 100.0 : 0.0

            float denom = lM - uM
            float apex = math.abs(denom) > 1e-10 ? (uQ - lQ) / denom : na
            float progress = not na(apex) and apex > float(startB) ? (float(bar_index - startB) / math.max(apex - float(startB), 1.0)) * 100.0 : 0.0

            bool widthOK = startWidth >= atrSafe * minHeightATR and nowWidth > atrSafe * 0.15
            bool contractionOK = contraction >= minContractionPct
            bool apexOK = not na(apex) and apex > float(bar_index) and progress >= minProgressPct and progress <= maxProgressPct
            bool alternateOK = f_anchorAlternates(hOB, hNB, lOB, lNB)

            [uTouches, uFit] = f_touchStats(true, uM, uQ, startB, hVals, hBars, hAtrs, lVals, lBars, lAtrs)
            [lTouches, lFit] = f_touchStats(false, lM, lQ, startB, hVals, hBars, hAtrs, lVals, lBars, lAtrs)

            bool touchOK = uTouches >= 2 and lTouches >= 2 and (uTouches + lTouches) >= 5

            float contain = f_containment(uM, uQ, lM, lQ, startB, geomEndB)
            bool containOK = contain >= minContainment

            // Yatay taraf slope ile "flat" görünse bile gerçek zone oluşmadan
            // yükselen/alçalan üçgen kabul edilmez.
            float upperZoneCenter = (hO + hN) * 0.5
            float lowerZoneCenter = (lO + lN) * 0.5

            [upperZoneTouches, upperZoneSpread, upperZoneRecentAge] = f_flatZoneStats(upperZoneCenter, startB, patternBars, hVals, hBars, hAtrs)
            [lowerZoneTouches, lowerZoneSpread, lowerZoneRecentAge] = f_flatZoneStats(lowerZoneCenter, startB, patternBars, lVals, lBars, lAtrs)

            bool upperZoneOK = upperZoneTouches >= flatZoneMinTouches and upperZoneSpread >= flatZoneMinSpanPct and upperZoneRecentAge <= flatZoneMaxRecentAgePct
            bool lowerZoneOK = lowerZoneTouches >= flatZoneMinTouches and lowerZoneSpread >= flatZoneMinSpanPct and lowerZoneRecentAge <= flatZoneMaxRecentAgePct

            bool flatSideZoneOK = true
            if displayKind == 1
                flatSideZoneOK := upperZoneOK
            else if displayKind == 2
                flatSideZoneOK := lowerZoneOK

            int hScaleMax = math.max(array.get(hScales, hOldIdx), array.get(hScales, hNewIdx))
            int lScaleMax = math.max(array.get(lScales, lOldIdx), array.get(lScales, lNewIdx))
            bool structuralAnchor = math.max(hScaleMax, lScaleMax) >= 2 or (uTouches + lTouches) >= 6

            float touchCountScore = f_clamp(float(uTouches + lTouches - 4) / 3.0 * 100.0, 0.0, 100.0)
            float touchBalanceScore = f_clamp(float(math.min(uTouches, lTouches)) / math.max(float(math.max(uTouches, lTouches)), 1.0) * 100.0, 0.0, 100.0)
            float touchFitScore = (uFit + lFit) / 2.0
            float touchQuality = touchCountScore * 0.45 + touchBalanceScore * 0.25 + touchFitScore * 0.30

            float contractionScore = f_clamp((contraction - minContractionPct) / 45.0 * 100.0, 0.0, 100.0)
            float progressCenter = 62.0
            float progressScore = f_clamp(100.0 - math.abs(progress - progressCenter) * 1.75, 0.0, 100.0)

            // ----------------------------------------------------------
            // V1.0.1 GEOMETRY SCORE
            // Bu puan yalnızca hangi çizgi çiftinin seçileceğini belirler.
            // Eski classifier sırası korunur ki V1.0.1 geometrisi kaymasın.
            // ----------------------------------------------------------
            float selectSlopeQuality = 0.0
            if selectionKind == 1
                float flatQ = f_clamp(100.0 - math.abs(uN) / math.max(flatSlopeATR, 0.001) * 100.0, 0.0, 100.0)
                float riseQ = f_clamp((lNrm - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                selectSlopeQuality := flatQ * 0.55 + riseQ * 0.45
            else if selectionKind == 2
                float flatQ = f_clamp(100.0 - math.abs(lNrm) / math.max(flatSlopeATR, 0.001) * 100.0, 0.0, 100.0)
                float fallQ = f_clamp((math.abs(uN) - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                selectSlopeQuality := flatQ * 0.55 + fallQ * 0.45
            else
                float uq = f_clamp((math.abs(uN) - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                float lq = f_clamp((lNrm - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                float sym = f_clamp(float(math.min(math.abs(uN), math.abs(lNrm))) / math.max(float(math.max(math.abs(uN), math.abs(lNrm))), 0.001) * 100.0, 0.0, 100.0)
                selectSlopeQuality := uq * 0.35 + lq * 0.35 + sym * 0.30

            // Görünen güven puanı doğru display classifier'a göre hesaplanır.
            float displaySlopeQuality = 0.0
            if displayKind == 1
                float flatQ = f_clamp(100.0 - math.abs(uN) / math.max(flatSlopeATR, 0.001) * 100.0, 0.0, 100.0)
                float riseQ = f_clamp((lNrm - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                displaySlopeQuality := flatQ * 0.55 + riseQ * 0.45
            else if displayKind == 2
                float flatQ = f_clamp(100.0 - math.abs(lNrm) / math.max(flatSlopeATR, 0.001) * 100.0, 0.0, 100.0)
                float fallQ = f_clamp((math.abs(uN) - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                displaySlopeQuality := flatQ * 0.55 + fallQ * 0.45
            else
                float uq = f_clamp((math.abs(uN) - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                float lq = f_clamp((lNrm - minSlopeATR) / math.max(minSlopeATR * 4.0, 0.001) * 100.0, 0.0, 100.0)
                float sym = f_clamp(float(math.min(math.abs(uN), math.abs(lNrm))) / math.max(float(math.max(math.abs(uN), math.abs(lNrm))), 0.001) * 100.0, 0.0, 100.0)
                displaySlopeQuality := uq * 0.35 + lq * 0.35 + sym * 0.30

            float durationScore = f_clamp(float(patternBars - minPatternBars) / math.max(float(maxPatternBars - minPatternBars), 1.0) * 100.0, 0.0, 100.0)

            int upperEnvelopeViolations = displayKind == 3 ? f_envelopeViolations(true, uM, uQ, startB, hVals, hBars, hAtrs) : 0
            int lowerEnvelopeViolations = displayKind == 3 ? f_envelopeViolations(false, lM, lQ, startB, lVals, lBars, lAtrs) : 0
            float envelopePenalty = displayKind == 3 ? f_clamp(float(upperEnvelopeViolations + lowerEnvelopeViolations) * envelopePenaltyPerPivot, 0.0, 24.0) : 0.0

            // Tam V1.0.1 seçim puanı + yalnız simetrikte envelope cezası.
            float selectScore = (
                touchQuality * 0.30 +
                contain * 0.24 +
                contractionScore * 0.14 +
                selectSlopeQuality * 0.16 +
                progressScore * 0.10 +
                durationScore * 0.06
            ) - envelopePenalty

            float displayBaseScore = (
                touchQuality * 0.30 +
                contain * 0.24 +
                contractionScore * 0.14 +
                displaySlopeQuality * 0.16 +
                progressScore * 0.10 +
                durationScore * 0.06
            ) - envelopePenalty

            // Late penalty yalnız kullanıcıya gösterilen güveni etkiler.
            // Geometri seçimini veya candidate validity'yi değiştirmez.
            float latePenalty = progress > 82.0 ? (progress - 82.0) * 1.10 : 0.0
            float zoneBonus = 0.0
            if displayKind == 1
                zoneBonus := f_clamp(float(upperZoneTouches - flatZoneMinTouches) * 2.0, 0.0, 6.0)
            else if displayKind == 2
                zoneBonus := f_clamp(float(lowerZoneTouches - flatZoneMinTouches) * 2.0, 0.0, 6.0)

            float displayScore = f_clamp(displayBaseScore - latePenalty + zoneBonus, 0.0, 100.0)

            bool hardValid = widthOK and contractionOK and apexOK and alternateOK and touchOK and containOK and structuralAnchor and flatSideZoneOK

            if hardValid and selectScore >= minCandidateScore
                r.valid := true
                r.kind := displayKind
                r.score := displayScore
                r.selectScore := selectScore
                r.startBar := startB
                r.endBar := geomEndB
                r.spanBars := patternBars

                r.hOldBar := hOB
                r.hNewBar := hNB
                r.lOldBar := lOB
                r.lNewBar := lNB
                r.hOld := hO
                r.hNew := hN
                r.lOld := lO
                r.lNew := lN

                r.upperSlope := uM
                r.lowerSlope := lM
                r.upperIntercept := uQ
                r.lowerIntercept := lQ
                r.upperNow := uNow
                r.lowerNow := dNow

                r.startWidth := startWidth
                r.nowWidth := nowWidth
                r.contractionPct := contraction
                r.apexBar := apex
                r.progressPct := progress

                r.upperTouches := uTouches
                r.lowerTouches := lTouches
                r.containment := contain
                r.touchQuality := touchQuality
                r.slopeQuality := displaySlopeQuality

                r.internalHigh := f_internalSwing(true, uM, uQ, startB, hVals, hBars, hAtrs, lVals, lBars, lAtrs)
                r.internalLow := f_internalSwing(false, lM, lQ, startB, hVals, hBars, hAtrs, lVals, lBars, lAtrs)

                // Aynı büyük yapı yeni temaslar aldıkça key değişmesin:
                // tür + başlangıç barı.
                r.key := displayKind * 1000000 + startB

    r

f_betterCandidate(RamoPatternResult cand, RamoPatternResult best) =>
    bool better = false

    if cand.valid
        if not best.valid
            better := true
        else
            bool candMacroDominant = float(cand.spanBars) >= float(best.spanBars) * macroDominanceRatio and cand.selectScore >= best.selectScore - macroScoreSlack
            bool bestMacroDominant = float(best.spanBars) >= float(cand.spanBars) * macroDominanceRatio and best.selectScore >= cand.selectScore - macroScoreSlack

            if candMacroDominant
                better := true
            else if not bestMacroDominant and cand.selectScore > best.selectScore
                better := true

    better

//=====================================================================
// 9. MULTI-CANDIDATE ÜÇGEN TARAMASI
//=====================================================================
f_scanTriangles(array<float> hVals, array<int> hBars, array<int> hScales, array<float> hAtrs,
                array<float> lVals, array<int> lBars, array<int> lScales, array<float> lAtrs) =>
    RamoPatternResult best = f_emptyPatternResult()

    int nh = array.size(hBars)
    int nl = array.size(lBars)

    if nh >= 2 and nl >= 2
        // Diziler en yeni -> en eski.
        // old index > new index olacak şekilde tüm anchor çiftleri denenir.
        for hOldIdx = 1 to nh - 1
            for hNewIdx = 0 to hOldIdx - 1
                int hbOld = array.get(hBars, hOldIdx)
                int hbNew = array.get(hBars, hNewIdx)

                if hbNew - hbOld >= minAnchorGap
                    for lOldIdx = 1 to nl - 1
                        for lNewIdx = 0 to lOldIdx - 1
                            int lbOld = array.get(lBars, lOldIdx)
                            int lbNew = array.get(lBars, lNewIdx)

                            if lbNew - lbOld >= minAnchorGap
                                int startB = math.min(hbOld, lbOld)
                                int age = bar_index - startB

                                if age >= minPatternBars and age <= maxPatternBars
                                    RamoPatternResult cand = f_evalCandidate(hOldIdx, hNewIdx, lOldIdx, lNewIdx,
                                                                        hVals, hBars, hScales, hAtrs,
                                                                        lVals, lBars, lScales, lAtrs)

                                    if f_betterCandidate(cand, best)
                                        best := cand

    best

//=====================================================================
// 9A. AYRI TAKOZ MOTORU
// V1.1.3 üçgen evaluator/scanner aynen korunur.
//=====================================================================
f_evalWedgeCandidate(int hOldIdx, int hNewIdx, int lOldIdx, int lNewIdx,
                     array<float> hVals, array<int> hBars, array<int> hScales, array<float> hAtrs,
                     array<float> lVals, array<int> lBars, array<int> lScales, array<float> lAtrs) =>
    RamoPatternResult r = f_emptyPatternResult()

    int hOB = array.get(hBars, hOldIdx)
    int hNB = array.get(hBars, hNewIdx)
    int lOB = array.get(lBars, lOldIdx)
    int lNB = array.get(lBars, lNewIdx)

    float hO = array.get(hVals, hOldIdx)
    float hN = array.get(hVals, hNewIdx)
    float lO = array.get(lVals, lOldIdx)
    float lN = array.get(lVals, lNewIdx)

    bool anchorOrderOK = hOB < hNB and lOB < lNB
    bool anchorGapOK = hNB - hOB >= minAnchorGap and lNB - lOB >= minAnchorGap

    if useWedges and anchorOrderOK and anchorGapOK
        float uM = (hN - hO) / float(hNB - hOB)
        float lM = (lN - lO) / float(lNB - lOB)
        float uQ = hO - uM * float(hOB)
        float lQ = lO - lM * float(lOB)

        int startB = math.min(hOB, lOB)
        int geomEndB = math.max(hNB, lNB)
        int patternBars = bar_index - startB

        float atrSafe = math.max(atr, syminfo.mintick)
        float uN = uM / atrSafe
        float lNrm = lM / atrSafe

        // Takozun iki sınırı da gerçekten eğimli olmalı.
        // flatSlopeATR içindeki hafif eğimler üçgene bırakılır.
        bool bothClearlyUp = uN > flatSlopeATR and lNrm > flatSlopeATR
        bool bothClearlyDown = uN < -flatSlopeATR and lNrm < -flatSlopeATR

        float slopeGap = lNrm - uN
        float riseRatio = bothClearlyUp ? lNrm / math.max(uN, 0.000001) : 0.0
        float fallRatio = bothClearlyDown ? math.abs(uN) / math.max(math.abs(lNrm), 0.000001) : 0.0

        bool risingWedge = (
          bothClearlyUp and
          slopeGap >= wedgeMinSlopeGapATR and
          riseRatio >= wedgeMinSlopeRatio and
          riseRatio <= wedgeMaxSlopeRatio
        )

        bool fallingWedge = (
          bothClearlyDown and
          slopeGap >= wedgeMinSlopeGapATR and
          fallRatio >= wedgeMinSlopeRatio and
          fallRatio <= wedgeMaxSlopeRatio
        )

        int wedgeKind = risingWedge ? 4 : fallingWedge ? 5 : 0
        bool convergingDirection = lM > uM

        if wedgeKind != 0 and convergingDirection and patternBars >= minPatternBars and patternBars <= maxPatternBars
            float uStart = f_lineAt(uM, uQ, startB)
            float dStart = f_lineAt(lM, lQ, startB)
            float uNow = f_lineAt(uM, uQ, bar_index)
            float dNow = f_lineAt(lM, lQ, bar_index)

            float startWidth = uStart - dStart
            float nowWidth = uNow - dNow
            float contraction = startWidth > syminfo.mintick ? (1.0 - nowWidth / startWidth) * 100.0 : 0.0

            float denom = lM - uM
            float apex = math.abs(denom) > 1e-10 ? (uQ - lQ) / denom : na
            float progress = not na(apex) and apex > float(startB) ? (float(bar_index - startB) / math.max(apex - float(startB), 1.0)) * 100.0 : 0.0

            bool widthOK = startWidth >= atrSafe * minHeightATR and nowWidth > atrSafe * 0.15
            bool contractionOK = contraction >= math.max(minContractionPct, wedgeMinContractionPct)
            bool apexOK = not na(apex) and apex > float(bar_index) and progress >= minProgressPct and progress <= maxProgressPct
            bool alternateOK = f_anchorAlternates(hOB, hNB, lOB, lNB)

            [uTouches, uFit] = f_touchStats(true, uM, uQ, startB, hVals, hBars, hAtrs, lVals, lBars, lAtrs)
            [lTouches, lFit] = f_touchStats(false, lM, lQ, startB, hVals, hBars, hAtrs, lVals, lBars, lAtrs)

            bool touchOK = uTouches >= 2 and lTouches >= 2 and (uTouches + lTouches) >= 5

            float contain = f_containment(uM, uQ, lM, lQ, startB, geomEndB)
            bool containOK = contain >= minContainment

            int hScaleMax = math.max(array.get(hScales, hOldIdx), array.get(hScales, hNewIdx))
            int lScaleMax = math.max(array.get(lScales, lOldIdx), array.get(lScales, lNewIdx))
            bool structuralAnchor = math.max(hScaleMax, lScaleMax) >= 2 or (uTouches + lTouches) >= 6

            float touchCountScore = f_clamp(float(uTouches + lTouches - 4) / 3.0 * 100.0, 0.0, 100.0)
            float touchBalanceScore = f_clamp(float(math.min(uTouches, lTouches)) / math.max(float(math.max(uTouches, lTouches)), 1.0) * 100.0, 0.0, 100.0)
            float touchFitScore = (uFit + lFit) / 2.0
            float touchQuality = touchCountScore * 0.45 + touchBalanceScore * 0.25 + touchFitScore * 0.30

            float contractionScore = f_clamp((contraction - wedgeMinContractionPct) / 45.0 * 100.0, 0.0, 100.0)
            float progressScore = f_clamp(100.0 - math.abs(progress - 62.0) * 1.75, 0.0, 100.0)

            float ratio = wedgeKind == 4 ? riseRatio : fallRatio
            float minAbsSlope = wedgeKind == 4 ? math.min(uN, lNrm) : math.min(math.abs(uN), math.abs(lNrm))
            float directionQ = f_clamp((minAbsSlope - flatSlopeATR) / math.max(flatSlopeATR * 2.0, 0.001) * 100.0, 0.0, 100.0)
            float gapQ = f_clamp((slopeGap - wedgeMinSlopeGapATR) / math.max(wedgeMinSlopeGapATR * 5.0, 0.001) * 100.0, 0.0, 100.0)
            float ratioQ = f_clamp((ratio - wedgeMinSlopeRatio) / math.max(wedgeMinSlopeRatio, 0.001) * 100.0, 0.0, 100.0)
            float wedgeSlopeQuality = directionQ * 0.35 + gapQ * 0.35 + ratioQ * 0.30

            float durationScore = f_clamp(float(patternBars - minPatternBars) / math.max(float(maxPatternBars - minPatternBars), 1.0) * 100.0, 0.0, 100.0)

            float baseScore = (
              touchQuality * 0.30 +
              contain * 0.24 +
              contractionScore * 0.16 +
              wedgeSlopeQuality * 0.18 +
              progressScore * 0.08 +
              durationScore * 0.04
            )

            float latePenalty = progress > 82.0 ? (progress - 82.0) * 1.10 : 0.0
            float displayScore = f_clamp(baseScore - latePenalty, 0.0, 100.0)

            bool hardValid = widthOK and contractionOK and apexOK and alternateOK and touchOK and containOK and structuralAnchor

            if hardValid and baseScore >= minCandidateScore
                r.valid := true
                r.kind := wedgeKind
                r.score := displayScore
                r.selectScore := baseScore
                r.startBar := startB
                r.endBar := geomEndB
                r.spanBars := patternBars

                r.hOldBar := hOB
                r.hNewBar := hNB
                r.lOldBar := lOB
                r.lNewBar := lNB
                r.hOld := hO
                r.hNew := hN
                r.lOld := lO
                r.lNew := lN

                r.upperSlope := uM
                r.lowerSlope := lM
                r.upperIntercept := uQ
                r.lowerIntercept := lQ
                r.upperNow := uNow
                r.lowerNow := dNow

                r.startWidth := startWidth
                r.nowWidth := nowWidth
                r.contractionPct := contraction
                r.apexBar := apex
                r.progressPct := progress

                r.upperTouches := uTouches
                r.lowerTouches := lTouches
                r.containment := contain
                r.touchQuality := touchQuality
                r.slopeQuality := wedgeSlopeQuality
                r.internalHigh := na
                r.internalLow := na
                r.key := wedgeKind * 1000000 + startB

    r

f_betterWedge(RamoPatternResult cand, RamoPatternResult best) =>
    bool better = false

    if cand.valid
        if not best.valid
            better := true
        else
            bool candMacroDominant = float(cand.spanBars) >= float(best.spanBars) * macroDominanceRatio and cand.selectScore >= best.selectScore - macroScoreSlack
            bool bestMacroDominant = float(best.spanBars) >= float(cand.spanBars) * macroDominanceRatio and best.selectScore >= cand.selectScore - macroScoreSlack

            if candMacroDominant
                better := true
            else if not bestMacroDominant and cand.selectScore > best.selectScore
                better := true

    better

f_scanWedges(array<float> hVals, array<int> hBars, array<int> hScales, array<float> hAtrs,
             array<float> lVals, array<int> lBars, array<int> lScales, array<float> lAtrs) =>
    RamoPatternResult best = f_emptyPatternResult()

    int nh = array.size(hBars)
    int nl = array.size(lBars)

    if useWedges and nh >= 2 and nl >= 2
        for hOldIdx = 1 to nh - 1
            for hNewIdx = 0 to hOldIdx - 1
                int hbOld = array.get(hBars, hOldIdx)
                int hbNew = array.get(hBars, hNewIdx)

                if hbNew - hbOld >= minAnchorGap
                    for lOldIdx = 1 to nl - 1
                        for lNewIdx = 0 to lOldIdx - 1
                            int lbOld = array.get(lBars, lOldIdx)
                            int lbNew = array.get(lBars, lNewIdx)

                            if lbNew - lbOld >= minAnchorGap
                                int startB = math.min(hbOld, lbOld)
                                int age = bar_index - startB

                                if age >= minPatternBars and age <= maxPatternBars
                                    RamoPatternResult cand = f_evalWedgeCandidate(
                                      hOldIdx, hNewIdx, lOldIdx, lNewIdx,
                                      hVals, hBars, hScales, hAtrs,
                                      lVals, lBars, lScales, lAtrs
                                    )

                                    if f_betterWedge(cand, best)
                                        best := cand

    best

// Üçgen ve takoz ayrı motorlarda seçilir.
// Geçerli üçgen varsa V1.1.3 sonucu korunur.
// Takoz yalnız üçgen motoru geçerli yapı bulamadığında ana form olur.
// Slope aileleri zaten ayrık olduğundan gerçek belirgin takozlar yine yakalanır.
f_chooseFamily(RamoPatternResult triangle, RamoPatternResult wedge) =>
    RamoPatternResult chosen = triangle

    if not triangle.valid and wedge.valid
        chosen := wedge

    chosen

//=====================================================================
// 9B. İZOLE ÜÇGEN MOTORU — ANA TF + DİĞER TF AYNI CLASSIFIER
//=====================================================================
f_triangleEngine(bool requestMode) =>
    var array<float> eHVals = array.new_float()
    var array<int>   eHBars = array.new_int()
    var array<int>   eHScales = array.new_int()
    var array<float> eHAtrs = array.new_float()

    var array<float> eLVals = array.new_float()
    var array<int>   eLBars = array.new_int()
    var array<int>   eLScales = array.new_int()
    var array<float> eLAtrs = array.new_float()

    float eAtr = ta.atr(atrLen)

    float ePhFast = ta.pivothigh(high, pivotFast, pivotFast)
    float ePlFast = ta.pivotlow(low, pivotFast, pivotFast)

    float ePhBase = ta.pivothigh(high, pivotBase, pivotBase)
    float ePlBase = ta.pivotlow(low, pivotBase, pivotBase)

    float ePhMacro = ta.pivothigh(high, pivotMacro, pivotMacro)
    float ePlMacro = ta.pivotlow(low, pivotMacro, pivotMacro)

    // Ana grafikte yalnız kapanmış barda belleğe yaz.
    // request.security() bağlamında barstate.isconfirmed kullanılamadığı için
    // orada pivot akışını doğal bağlamında çalıştırıp aşağıdaki wrapper ile
    // bir önceki UDT sonucunu döndürüyoruz.
    bool canUpdate = requestMode or barstate.isconfirmed

    if canUpdate
        if not na(ePhFast)
            f_addPivot(eHVals, eHBars, eHScales, eHAtrs, ePhFast, bar_index - pivotFast, 1, eAtr[pivotFast], true)
        if not na(ePlFast)
            f_addPivot(eLVals, eLBars, eLScales, eLAtrs, ePlFast, bar_index - pivotFast, 1, eAtr[pivotFast], false)

        if not na(ePhBase)
            f_addPivot(eHVals, eHBars, eHScales, eHAtrs, ePhBase, bar_index - pivotBase, 2, eAtr[pivotBase], true)
        if not na(ePlBase)
            f_addPivot(eLVals, eLBars, eLScales, eLAtrs, ePlBase, bar_index - pivotBase, 2, eAtr[pivotBase], false)

        if not na(ePhMacro)
            f_addPivot(eHVals, eHBars, eHScales, eHAtrs, ePhMacro, bar_index - pivotMacro, 3, eAtr[pivotMacro], true)
        if not na(ePlMacro)
            f_addPivot(eLVals, eLBars, eLScales, eLAtrs, ePlMacro, bar_index - pivotMacro, 3, eAtr[pivotMacro], false)

    RamoPatternResult triangleResult = f_scanTriangles(eHVals, eHBars, eHScales, eHAtrs, eLVals, eLBars, eLScales, eLAtrs)
    RamoPatternResult wedgeResult = f_scanWedges(eHVals, eHBars, eHScales, eHAtrs, eLVals, eLBars, eLScales, eLAtrs)
    f_chooseFamily(triangleResult, wedgeResult)

f_triangleEngineConfirmed() =>
    RamoPatternResult current = f_triangleEngine(true)
    RamoPatternResult previous = current[1]
    RamoPatternResult out = f_emptyPatternResult()

    // İlk HTF barlarında previous nesnesinin kendisi na olabilir.
    // UDT alanına erişmeden önce gerçek bir boş nesneye normalize et.
    if not na(previous)
        out := previous

    out

// Parent TF sonucunu local chart bar_index koordinatına dönüştür.
// Fiyat geometrisi parent'tan gelir; çizim local barlarda yapılabilir.
f_parentToLocal(RamoPatternResult parent, float barsPerParent) =>
    RamoPatternResult out = f_emptyPatternResult()

    // Reference-type UDT nesnesinin kendisi na olabilir.
    if not na(parent)
        if parent.valid and barsPerParent > 0
            int localSpan = math.max(1, int(math.round(float(parent.spanBars) * barsPerParent)))

            float localUpperSlope = parent.upperSlope / barsPerParent
            float localLowerSlope = parent.lowerSlope / barsPerParent

            float progressFrac = parent.progressPct > 0.1 ? parent.progressPct / 100.0 : 0.0
            float parentTotalBars = progressFrac > 0.0 ? float(parent.spanBars) / progressFrac : float(parent.spanBars + 1)
            float parentRemainBars = math.max(parentTotalBars - float(parent.spanBars), 1.0)

            out.valid := true
            out.kind := parent.kind
            out.score := parent.score
            out.selectScore := parent.selectScore
            out.key := parent.key

            out.startBar := bar_index - localSpan
            out.endBar := bar_index
            out.spanBars := localSpan

            out.hOldBar := out.startBar
            out.hNewBar := bar_index
            out.lOldBar := out.startBar
            out.lNewBar := bar_index

            out.hOld := na
            out.hNew := na
            out.lOld := na
            out.lNew := na

            out.upperSlope := localUpperSlope
            out.lowerSlope := localLowerSlope
            out.upperIntercept := parent.upperNow - localUpperSlope * float(bar_index)
            out.lowerIntercept := parent.lowerNow - localLowerSlope * float(bar_index)
            out.upperNow := parent.upperNow
            out.lowerNow := parent.lowerNow

            out.startWidth := parent.startWidth
            out.nowWidth := parent.nowWidth
            out.contractionPct := parent.contractionPct
            out.apexBar := float(bar_index) + parentRemainBars * barsPerParent
            out.progressPct := parent.progressPct

            out.upperTouches := parent.upperTouches
            out.lowerTouches := parent.lowerTouches
            out.containment := parent.containment
            out.touchQuality := parent.touchQuality
            out.slopeQuality := parent.slopeQuality

            out.internalHigh := parent.internalHigh
            out.internalLow := parent.internalLow

    out

// 1H/2H local üçgen parent 4H ile aynı ana yapıdaysa yalnız şüpheli
// "flat" taraf parent'tan alınır. Diğer yerel eğik sınır KORUNUR.
// kind 1 (ascending): local lower korunur, parent upper alınır.
// kind 2 (descending): local upper korunur, parent lower alınır.
f_repairChildFlatSide(RamoPatternResult child, RamoPatternResult parent, float barsPerParent) =>
    RamoPatternResult out = child

    if not na(child) and not na(parent)
        if child.valid and parent.valid and parent.kind == 3 and barsPerParent > 0 and (child.kind == 1 or child.kind == 2)
            RamoPatternResult p = f_parentToLocal(parent, barsPerParent)

            if p.valid
                float newUM = child.upperSlope
                float newUQ = child.upperIntercept
                float newLM = child.lowerSlope
                float newLQ = child.lowerIntercept

                if child.kind == 1
                    // Yerel yükselen destek iyi; yalnız yatay üst tarafı parent'tan düzelt.
                    newUM := p.upperSlope
                    newUQ := p.upperIntercept
                else if child.kind == 2
                    // Yerel alçalan direnç iyi; yalnız yatay alt tarafı parent'tan düzelt.
                    newLM := p.lowerSlope
                    newLQ := p.lowerIntercept

                float newUpperNow = f_lineAt(newUM, newUQ, bar_index)
                float newLowerNow = f_lineAt(newLM, newLQ, bar_index)
                float denom = newLM - newUM
                float newApex = math.abs(denom) > 1e-10 ? (newUQ - newLQ) / denom : na

                int newStart = math.min(child.startBar, p.startBar)
                float newStartWidth = f_lineAt(newUM, newUQ, newStart) - f_lineAt(newLM, newLQ, newStart)
                float newNowWidth = newUpperNow - newLowerNow
                float newContraction = newStartWidth > syminfo.mintick ? (1.0 - newNowWidth / newStartWidth) * 100.0 : child.contractionPct
                float newProgress = not na(newApex) and newApex > float(newStart) ? float(bar_index - newStart) / math.max(newApex - float(newStart), 1.0) * 100.0 : child.progressPct

                bool geometryOK = newUpperNow > newLowerNow and not na(newApex) and newApex > float(bar_index)

                if geometryOK
                    out.kind := 3
                    out.score := math.max(child.score, parent.score - 3.0)
                    out.selectScore := math.max(child.selectScore, parent.selectScore - 3.0)
                    out.key := 3000000 + newStart

                    out.startBar := newStart
                    out.spanBars := bar_index - newStart
                    out.upperSlope := newUM
                    out.upperIntercept := newUQ
                    out.lowerSlope := newLM
                    out.lowerIntercept := newLQ
                    out.upperNow := newUpperNow
                    out.lowerNow := newLowerNow
                    out.startWidth := newStartWidth
                    out.nowWidth := newNowWidth
                    out.contractionPct := newContraction
                    out.apexBar := newApex
                    out.progressPct := newProgress

                    if child.kind == 1
                        out.upperTouches := parent.upperTouches
                        out.lowerTouches := child.lowerTouches
                    else
                        out.upperTouches := child.upperTouches
                        out.lowerTouches := parent.lowerTouches

                    out.internalHigh := na
                    out.internalLow := na

    out

RamoPatternResult tri = f_triangleEngine(false)

// Tek ek request: paneli büyütmeden tamamlayıcı ana zaman dilimini göster.
// 1D <-> 4H; 1H/2H için 4H referans.
string otherTf = "240"
if timeframe.period == "1D"
    otherTf := "240"
else if timeframe.period == "240"
    otherTf := "1D"
else if timeframe.period == "120"
    otherTf := "240"
else if timeframe.period == "60"
    otherTf := "240"

RamoPatternResult otherTri = f_emptyPatternResult()

if showOtherTF
    RamoPatternResult requestedOtherTri = request.security(syminfo.tickerid, otherTf, f_triangleEngineConfirmed(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

    // request.security ilk dataset barlarında na object ID döndürebilir.
    // Aşağıdaki parent/panel kodu her zaman gerçek bir nesne görsün.
    if not na(requestedOtherTri)
        otherTri := requestedOtherTri

//=====================================================================
// 9C. PARENT / CHILD STRUCTURAL COHERENCE
//=====================================================================
// 1H/2H aynı ana 4H yapısını farklı tür diye yeniden adlandırmasın.
// Küçük gerçek LOCAL yapı duration-ratio filtresi sayesinde korunur.
bool childTfForCoherence = timeframe.period == "60" or timeframe.period == "120"
float childMinutes = f_tfMinutes(timeframe.period)
float parentMinutes = f_tfMinutes(otherTf)
float barsPerParent = childMinutes > 0.0 ? parentMinutes / childMinutes : 0.0

bool triObjectOK = not na(tri)
bool parentObjectOK = not na(otherTri)
bool childValid = triObjectOK ? tri.valid : false
bool parentValid = parentObjectOK ? otherTri.valid : false

float childDurationMin = childValid ? float(tri.spanBars) * childMinutes : 0.0
float parentDurationMin = parentValid ? float(otherTri.spanBars) * parentMinutes : 0.0
float durationSimilarity = childDurationMin > 0.0 and parentDurationMin > 0.0 ? math.min(childDurationMin, parentDurationMin) / math.max(childDurationMin, parentDurationMin) : 0.0

float childMid = childValid ? (tri.upperNow + tri.lowerNow) * 0.5 : na
float parentMid = parentValid ? (otherTri.upperNow + otherTri.lowerNow) * 0.5 : na
bool midlineNear = childValid and parentValid and not na(childMid) and not na(parentMid) and math.abs(childMid - parentMid) <= atr * parentMidTolATR

bool bothTriangleFamilies = childValid and parentValid and tri.kind >= 1 and tri.kind <= 3 and otherTri.kind >= 1 and otherTri.kind <= 3
bool parentScoreOK = childValid and parentValid and otherTri.score >= tri.score - parentScoreSlack

// Parent envelope yakınlığı: duration filtresinden daha önemli.
// 1H/2H'de current price parent yapının içinde/yakınında ve parent simetrikse,
// local ascending/descending formun yalnız flat tarafını parent ile onar.
float parentEnvelopeTol = atr * parentMidTolATR
bool insideParentEnvelope = parentValid and close <= otherTri.upperNow + parentEnvelopeTol and close >= otherTri.lowerNow - parentEnvelopeTol
bool childNeedsFlatRepair = childValid and (tri.kind == 1 or tri.kind == 2)
bool parentIsSymmetric = parentValid and otherTri.kind == 3

bool sameMainStructure = useParentCoherence and childTfForCoherence and childNeedsFlatRepair and parentIsSymmetric and insideParentEnvelope and midlineNear and parentScoreOK

if sameMainStructure
    tri := f_repairChildFlatSide(tri, otherTri, barsPerParent)

//=====================================================================
// 9D. SİMETRİK ÜÇGEN — CONFIRMED MTF RSI + HACİM BIAS
//=====================================================================
// Harita: chart TF'den daha büyük iki bağlam.
// 1H/2H -> 4H + 1D
// 4H/6H -> 12H + 1D
// 12H   -> 1D + 3D
// 1D    -> 3D + 1W
string biasTf1 = "240"
string biasTf2 = "1D"

if timeframe.period == "60" or timeframe.period == "120"
    biasTf1 := "240"
    biasTf2 := "1D"
else if timeframe.period == "240" or timeframe.period == "360"
    biasTf1 := "720"
    biasTf2 := "1D"
else if timeframe.period == "720"
    biasTf1 := "1D"
    biasTf2 := "3D"
else if timeframe.period == "1D"
    biasTf1 := "3D"
    biasTf2 := "1W"

// Current TF: son kapanmış bar.
float localRsiSeries = ta.rsi(close, biasRsiLen)
float localRvolSeries = f_rvolNow()
float localDirSeries = close > open ? 1.0 : close < open ? -1.0 : 0.0

float localRsi = localRsiSeries[1]
float localRvol = localRvolSeries[1]
float localDir = localDirSeries[1]

// Büyük TF'lerde repaint etmemek için expression zaten [1] döndürüyor,
// request.security lookahead_on kullanıyor.
[ctx1Rsi, ctx1Rvol, ctx1Dir] = request.security(syminfo.tickerid, biasTf1, [f_ctxRsiConfirmed(), f_ctxRvolConfirmed(), f_ctxDirConfirmed()], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[ctx2Rsi, ctx2Rvol, ctx2Dir] = request.security(syminfo.tickerid, biasTf2, [f_ctxRsiConfirmed(), f_ctxRvolConfirmed(), f_ctxDirConfirmed()], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

float localBias = f_contextBias(localRsi, localRvol, localDir)
float ctx1Bias = f_contextBias(ctx1Rsi, ctx1Rvol, ctx1Dir)
float ctx2Bias = f_contextBias(ctx2Rsi, ctx2Rvol, ctx2Dir)

// Büyük TF daha ağır. Bias yalnız yön önceliği verir; breakout kapısı değildir.
float mtfBiasScore = (
  localBias * 0.20 +
  ctx1Bias * 0.35 +
  ctx2Bias * 0.45
) * 100.0

int mtfBiasDir = 0
if useMtfBias
    if mtfBiasScore >= biasThreshold
        mtfBiasDir := 1
    else if mtfBiasScore <= -biasThreshold
        mtfBiasDir := -1

string mtfBiasText = "NÖTR"
if mtfBiasDir == 1
    mtfBiasText := "LONG " + str.tostring(math.abs(mtfBiasScore), "#")
else if mtfBiasDir == -1
    mtfBiasText := "SHORT " + str.tostring(math.abs(mtfBiasScore), "#")

//=====================================================================
// 10. BREAKOUT / RETEST / FAILED STATE MOTORU
//=====================================================================
float upperBuf = tri.valid ? math.max(math.abs(tri.upperNow) * breakBufferPct / 100.0, math.max(atr * breakBufferATR, syminfo.mintick * 2.0)) : na
float lowerBuf = tri.valid ? math.max(math.abs(tri.lowerNow) * breakBufferPct / 100.0, math.max(atr * breakBufferATR, syminfo.mintick * 2.0)) : na

float upperBreak = tri.valid ? tri.upperNow + upperBuf : na
float lowerBreak = tri.valid ? tri.lowerNow - lowerBuf : na

float symUpConfirm = tri.valid and tri.kind == 3 and not na(tri.internalHigh) ? math.max(upperBreak, tri.internalHigh + upperBuf) : upperBreak
float symDnConfirm = tri.valid and tri.kind == 3 and not na(tri.internalLow) ? math.min(lowerBreak, tri.internalLow - lowerBuf) : lowerBreak

bool progressAllowsBreak = tri.valid and tri.progressPct >= minBreakProgress

bool rawBreakUp = tri.valid and progressAllowsBreak and close > (tri.kind == 3 ? symUpConfirm : upperBreak)
bool rawBreakDn = tri.valid and progressAllowsBreak and close < (tri.kind == 3 ? symDnConfirm : lowerBreak)

// Yön politikası:
// 1 Yükselen Üçgen = LONG
// 2 Alçalan Üçgen = SHORT
// 3 Simetrik = breakout yönü
// 4 Yükselen Takoz = SHORT
// 5 Düşen Takoz = LONG
bool allowedBreakUp = rawBreakUp and (tri.kind == 1 or tri.kind == 3 or tri.kind == 5)
bool allowedBreakDn = rawBreakDn and (tri.kind == 2 or tri.kind == 3 or tri.kind == 4)

bool wrongSideBreak = tri.valid and (
  (tri.kind == 1 and close < lowerBreak) or
  (tri.kind == 2 and close > upperBreak) or
  (tri.kind == 4 and close > upperBreak) or
  (tri.kind == 5 and close < lowerBreak)
)

var int lockedKey = 0
var int breakDir = 0
var int breakBar = na
var float breakLevel = na
var bool retested = false
var bool failed = false

bool signalNow = not confirmedOnly or barstate.isconfirmed

if barstate.isconfirmed
    if tri.valid
        if lockedKey != tri.key
            lockedKey := tri.key
            breakDir := 0
            breakBar := na
            breakLevel := na
            retested := false
            failed := false

        if breakDir == 0 and not wrongSideBreak
            if allowedBreakUp
                breakDir := 1
                breakBar := bar_index
                breakLevel := tri.upperNow
                retested := false
                failed := false
            else if allowedBreakDn
                breakDir := -1
                breakBar := bar_index
                breakLevel := tri.lowerNow
                retested := false
                failed := false

        if breakDir != 0 and not na(breakBar) and not na(breakLevel)
            int age = bar_index - breakBar
            float rtTol = math.max(math.abs(breakLevel) * retestTolPct / 100.0, atr * 0.25)
            float failTol = math.max(atr * failATR, math.abs(breakLevel) * 0.20 / 100.0)

            if age >= 1 and age <= retestBars and not failed
                if breakDir == 1
                    if low <= breakLevel + rtTol and close >= breakLevel - rtTol
                        retested := true
                    if close < breakLevel - failTol
                        failed := true
                else
                    if high >= breakLevel - rtTol and close <= breakLevel + rtTol
                        retested := true
                    if close > breakLevel + failTol
                        failed := true
    else
        lockedKey := 0
        breakDir := 0
        breakBar := na
        breakLevel := na
        retested := false
        failed := false

bool stateForCurrent = tri.valid and lockedKey == tri.key

//=====================================================================
// 11. AŞAMA / YÖN / GİRİŞ / STOP / HEDEF
//=====================================================================
string formText = "YOK"
if tri.valid
    if tri.kind == 1
        formText := "YÜKSELEN ÜÇGEN"
    else if tri.kind == 2
        formText := "ALÇALAN ÜÇGEN"
    else if tri.kind == 3
        formText := "SİMETRİK ÜÇGEN"
    else if tri.kind == 4
        formText := "YÜKSELEN TAKOZ"
    else if tri.kind == 5
        formText := "DÜŞEN TAKOZ"

bool wickUpperTest = tri.valid and high > tri.upperNow and close <= upperBreak
bool wickLowerTest = tri.valid and low < tri.lowerNow and close >= lowerBreak

string stageText = "YOK"
if tri.valid
    if wrongSideBreak and breakDir == 0
        stageText := "BOZULDU"
    else if stateForCurrent and breakDir != 0
        stageText := failed ? "FAILED" : retested ? "RETEST" : "BREAKOUT"
    else if wickUpperTest
        stageText := "ÜST TEST"
    else if wickLowerTest
        stageText := "ALT TEST"
    else
        stageText := tri.progressPct >= 55.0 ? "OLGUN" : "GELİŞİYOR"

string dirText = "-"
if tri.valid
    if tri.kind == 1
        dirText := "LONG"
    else if tri.kind == 2
        dirText := "SHORT"
    else if tri.kind == 3
        if stateForCurrent and breakDir == 1
            dirText := "LONG"
        else if stateForCurrent and breakDir == -1
            dirText := "SHORT"
        else
            dirText := useMtfBias ? "NÖTR | " + mtfBiasText : "NÖTR"
    else if tri.kind == 4
        dirText := stateForCurrent and breakDir == -1 ? "SHORT" : "SHORT ADAY"
    else if tri.kind == 5
        dirText := stateForCurrent and breakDir == 1 ? "LONG" : "LONG ADAY"

// Panel/çizgi için aksiyon alarm seviyeleri.
// Simetrikte iki yön de açık kalır; MTF bias sadece öncelik sırasını gösterir.
float alarmLongLevel = na
float alarmShortLevel = na

if tri.valid
    if tri.kind == 1
        alarmLongLevel := upperBreak
    else if tri.kind == 2
        alarmShortLevel := lowerBreak
    else if tri.kind == 3
        alarmLongLevel := symUpConfirm
        alarmShortLevel := symDnConfirm
    else if tri.kind == 4
        alarmShortLevel := lowerBreak
    else if tri.kind == 5
        alarmLongLevel := upperBreak

string alarmText = "-"
if tri.valid
    if wrongSideBreak
        alarmText := "BOZULDU"
    else if stateForCurrent and breakDir != 0
        if failed
            alarmText := "İPTAL"
        else if retested
            alarmText := "RETEST TAMAM"
        else
            alarmText := "RETEST " + str.tostring(breakLevel, format.mintick)
    else if tri.kind == 3
        string longAlarm = not na(alarmLongLevel) ? "L>" + str.tostring(alarmLongLevel, format.mintick) : "-"
        string shortAlarm = not na(alarmShortLevel) ? "S<" + str.tostring(alarmShortLevel, format.mintick) : "-"
        if mtfBiasDir == 1
            alarmText := longAlarm + " * / " + shortAlarm
        else if mtfBiasDir == -1
            alarmText := shortAlarm + " * / " + longAlarm
        else
            alarmText := longAlarm + " / " + shortAlarm
    else if not na(alarmLongLevel)
        alarmText := "L>" + str.tostring(alarmLongLevel, format.mintick)
    else if not na(alarmShortLevel)
        alarmText := "S<" + str.tostring(alarmShortLevel, format.mintick)

// Kırılım öncesi hedef önizlemeleri.
// Simetrikte iki yön birden gösterilir; breakout sonrası tek gerçek hedef kullanılır.
float previewLongTarget = na
float previewShortTarget = na

if tri.valid
    if tri.kind == 1
        previewLongTarget := alarmLongLevel + tri.startWidth
    else if tri.kind == 2
        previewShortTarget := alarmShortLevel - tri.startWidth
    else if tri.kind == 3
        previewLongTarget := alarmLongLevel + tri.startWidth
        previewShortTarget := alarmShortLevel - tri.startWidth
    else if tri.kind == 4
        previewShortTarget := alarmShortLevel - tri.startWidth
    else if tri.kind == 5
        previewLongTarget := alarmLongLevel + tri.startWidth

float entry = na
float stop = na
float target = na
string entryMode = "BEKLE"

// Pre-break erken giriş yalnız yönlü üçgenlerde sınır retestinde.
// Simetrik üçgende breakout + retest beklenir.
if tri.valid and not wrongSideBreak
    if stateForCurrent and breakDir != 0
        if not failed and retested
            if breakDir == 1
                float e = breakLevel + atr * entryBufferATR
                float s = breakLevel - atr * stopBufferATR
                if f_pairRiskOK(e, s, true)
                    entry := e
                    stop := s
                    entryMode := "RETEST"
                    target := breakLevel + tri.startWidth
            else
                float e = breakLevel - atr * entryBufferATR
                float s = breakLevel + atr * stopBufferATR
                if f_pairRiskOK(e, s, false)
                    entry := e
                    stop := s
                    entryMode := "RETEST"
                    target := breakLevel - tri.startWidth
        else if not failed
            target := breakDir == 1 ? breakLevel + tri.startWidth : breakLevel - tri.startWidth
    else
        if tri.kind == 1
            bool nearLower = low <= tri.lowerNow + atr * earlyNearATR and close >= tri.lowerNow
            float e = tri.lowerNow + atr * entryBufferATR
            float s = tri.lowerNow - atr * stopBufferATR

            if nearLower and f_pairRiskOK(e, s, true)
                entry := e
                stop := s
                entryMode := "ALT SINIR"
            target := tri.upperNow + tri.startWidth

        else if tri.kind == 2
            bool nearUpper = high >= tri.upperNow - atr * earlyNearATR and close <= tri.upperNow
            float e = tri.upperNow - atr * entryBufferATR
            float s = tri.upperNow + atr * stopBufferATR

            if nearUpper and f_pairRiskOK(e, s, false)
                entry := e
                stop := s
                entryMode := "ÜST SINIR"
            target := tri.lowerNow - tri.startWidth

        else
            // Simetrik ve takoz: kırılım/onay gelmeden işlem önerilmez.
            entryMode := "BREAK+RETEST"

//=====================================================================
// 12. ÇİZİMLER
//=====================================================================
var line upperLine = na
var line lowerLine = na
var line alarmLine1 = na
var line alarmLine2 = na
var line stopLine = na
var line targetLine = na
var label debugLabel = na

if barstate.islast
    if not na(upperLine)
        line.delete(upperLine)
    if not na(lowerLine)
        line.delete(lowerLine)
    if not na(alarmLine1)
        line.delete(alarmLine1)
    if not na(alarmLine2)
        line.delete(alarmLine2)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(targetLine)
        line.delete(targetLine)
    if not na(debugLabel)
        label.delete(debugLabel)

    if tri.valid and showTriangle
        int apexX = int(math.round(tri.apexBar))
        int drawX2 = math.min(apexX, bar_index + 300)

        float upperX2 = f_lineAt(tri.upperSlope, tri.upperIntercept, drawX2)
        float lowerX2 = f_lineAt(tri.lowerSlope, tri.lowerIntercept, drawX2)

        upperLine := line.new(tri.startBar, f_lineAt(tri.upperSlope, tri.upperIntercept, tri.startBar),
                              drawX2, upperX2, xloc = xloc.bar_index, color = color.blue, width = 2)

        lowerLine := line.new(tri.startBar, f_lineAt(tri.lowerSlope, tri.lowerIntercept, tri.startBar),
                              drawX2, lowerX2, xloc = xloc.bar_index, color = color.orange, width = 2)

    if tri.valid and showLevels
        int x2 = bar_index + 35

        // Breakout öncesi alarm sınırları; breakout sonrası retest alarmı.
        if stateForCurrent and breakDir != 0 and not failed and not retested and not na(breakLevel)
            alarmLine1 := line.new(bar_index, breakLevel, x2, breakLevel, xloc = xloc.bar_index, color = color.orange, style = line.style_dashed)
        else if not stateForCurrent or breakDir == 0
            if not na(alarmLongLevel)
                alarmLine1 := line.new(bar_index, alarmLongLevel, x2, alarmLongLevel, xloc = xloc.bar_index, color = color.orange, style = line.style_dashed)
            if not na(alarmShortLevel)
                alarmLine2 := line.new(bar_index, alarmShortLevel, x2, alarmShortLevel, xloc = xloc.bar_index, color = color.red, style = line.style_dashed)

        if not na(stop)
            stopLine := line.new(bar_index, stop, x2, stop, xloc = xloc.bar_index, color = color.red, style = line.style_dashed)
        if not na(target)
            targetLine := line.new(bar_index, target, x2, target, xloc = xloc.bar_index, color = color.fuchsia, width = 2)
        else
            // Yön kesinleşmeden yalnız bias tarafındaki tek hedef çizgisini göster.
            // Simetrikte iki target çizgisi yerine panelde iki hedef birden tutulur.
            float previewTargetLine = na
            if tri.kind == 3
                if mtfBiasDir == 1
                    previewTargetLine := previewLongTarget
                else if mtfBiasDir == -1
                    previewTargetLine := previewShortTarget
            else if not na(previewLongTarget)
                previewTargetLine := previewLongTarget
            else if not na(previewShortTarget)
                previewTargetLine := previewShortTarget

            if not na(previewTargetLine)
                targetLine := line.new(bar_index, previewTargetLine, x2, previewTargetLine, xloc = xloc.bar_index, color = color.fuchsia, width = 1, style = line.style_dashed)

    if tri.valid and showDebug
        string dbg = "KIND " + str.tostring(tri.kind) +
                     "\nU/L TOUCH " + str.tostring(tri.upperTouches) + "/" + str.tostring(tri.lowerTouches) +
                     "\nSCORE " + str.tostring(tri.score, "#.0") +
                     "\nSEL " + str.tostring(tri.selectScore, "#.0") +
                     "\nIN " + str.tostring(tri.containment, "#.0") +
                     "\nCONTR " + str.tostring(tri.contractionPct, "#.0") +
                     "\nPROG " + str.tostring(tri.progressPct, "#.0") +
                     "\nSPAN " + str.tostring(tri.spanBars) +
                     "\nPARENT REPAIR " + (sameMainStructure ? "ON" : "OFF") +
                     "\nAPEX +" + str.tostring(int(math.round(tri.apexBar)) - bar_index)

        debugLabel := label.new(bar_index, high + atr, dbg, style = label.style_label_down, textcolor = color.black, color = color.white, size = size.tiny)

//=====================================================================
// 13. KÜÇÜK PANO — 10 SATIR
//=====================================================================
var table panel = table.new(position.bottom_right, 2, 12, bgcolor = color.new(color.white, 8), border_width = 1)

if barstate.islast
    if showPanel
        string scoreText = tri.valid ? str.tostring(tri.score, "#.0") + "/100" : "-"
        string entryText = "-"
        if tri.valid
            if not na(entry)
                entryText := str.tostring(entry, format.mintick) + " " + entryMode
            else
                entryText := entryMode

        string stopText = tri.valid and not na(stop) ? str.tostring(stop, format.mintick) : "-"
        string targetText = "-"
        if tri.valid
            if not na(target)
                targetText := str.tostring(target, format.mintick)
            else if tri.kind == 3
                string longT = not na(previewLongTarget) ? "L " + str.tostring(previewLongTarget, format.mintick) : "-"
                string shortT = not na(previewShortTarget) ? "S " + str.tostring(previewShortTarget, format.mintick) : "-"

                if mtfBiasDir == 1
                    targetText := longT + " * / " + shortT
                else if mtfBiasDir == -1
                    targetText := shortT + " * / " + longT
                else
                    targetText := longT + " / " + shortT
            else if not na(previewLongTarget)
                targetText := str.tostring(previewLongTarget, format.mintick)
            else if not na(previewShortTarget)
                targetText := str.tostring(previewShortTarget, format.mintick)

        table.cell(panel, 0, 0, "RAMO FORMASYON V1.2.4.2", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 0, f_tfLabel(timeframe.period), text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 1, "FORM", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 1, formText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 2, "AŞAMA", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 2, stageText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 3, "GÜVEN", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 3, scoreText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 4, "YÖN", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 4, dirText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 5, "GİRİŞ", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 5, entryText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 6, "ALARM", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 6, alarmText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 7, "STOP", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 7, stopText, text_color = color.black, text_size = size.tiny)

        table.cell(panel, 0, 8, "HEDEF", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 8, targetText, text_color = color.black, text_size = size.tiny)

        string touchText = tri.valid ? str.tostring(tri.upperTouches) + "+" + str.tostring(tri.lowerTouches) + " / " + str.tostring(tri.progressPct, "#") + "%" : "-"
        table.cell(panel, 0, 9, "TEMAS/OLUŞ", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 9, touchText, text_color = color.black, text_size = size.tiny)

        string otherName = "YOK"
        if parentValid
            if otherTri.kind == 1
                otherName := "YÜKSELEN ÜÇGEN"
            else if otherTri.kind == 2
                otherName := "ALÇALAN ÜÇGEN"
            else if otherTri.kind == 3
                otherName := "SİMETRİK"
            else if otherTri.kind == 4
                otherName := "YÜKSELEN TAKOZ"
            else if otherTri.kind == 5
                otherName := "DÜŞEN TAKOZ"

        string otherText = showOtherTF ? f_tfLabel(otherTf) + "  " + otherName + (parentValid ? "  " + str.tostring(otherTri.score, "#") : "") : "KAPALI"
        table.cell(panel, 0, 10, "DİĞER TF", text_color = color.black, text_size = size.tiny)
        table.cell(panel, 1, 10, otherText, text_color = color.black, text_size = size.tiny)

        // Küçük görünmez alt satır paneli bottom-right içinde biraz yukarı taşır.
        table.cell(panel, 0, 11, "", height = 2, text_color = color.new(color.white, 100), bgcolor = color.new(color.white, 100), text_size = size.tiny)
        table.cell(panel, 1, 11, "", height = 2, text_color = color.new(color.white, 100), bgcolor = color.new(color.white, 100), text_size = size.tiny)
    else
        table.clear(panel, 0, 0, 1, 11)

//=====================================================================
// 14. ALARMLAR
//=====================================================================
// Pine v6: UDT alanına doğrudan [1] uygulanamaz.
bool triValidSeries = tri.valid
int triKeySeries = tri.key
int triKindSeries = tri.kind

bool newPattern = signalNow and triValidSeries and (not triValidSeries[1] or triKeySeries != triKeySeries[1])
bool newBreakUp = signalNow and triValidSeries and allowedBreakUp and not allowedBreakUp[1]
bool newBreakDn = signalNow and triValidSeries and allowedBreakDn and not allowedBreakDn[1]
bool newRetest = signalNow and triValidSeries and stateForCurrent and retested and not retested[1]
bool newFailed = signalNow and triValidSeries and stateForCurrent and failed and not failed[1]
bool newRisingWedge = newPattern and triKindSeries == 4
bool newFallingWedge = newPattern and triKindSeries == 5

alertcondition(newPattern, title = "Yeni Üçgen / Takoz Yapısı", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | yeni geçerli üçgen/takoz")
alertcondition(newRisingWedge, title = "Yeni Yükselen Takoz", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | yükselen takoz | SHORT aday")
alertcondition(newFallingWedge, title = "Yeni Düşen Takoz", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | düşen takoz | LONG aday")
alertcondition(newBreakUp, title = "RAMO LONG ALARM", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | LONG breakout alarmı")
alertcondition(newBreakDn, title = "RAMO SHORT ALARM", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | SHORT breakout alarmı")
alertcondition(newRetest, title = "Breakout Retest", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | breakout retest")
alertcondition(newFailed, title = "Failed Breakout", message = "RAMO FORMASYON V1.2.4.2 | {{ticker}} | failed breakout")
````
