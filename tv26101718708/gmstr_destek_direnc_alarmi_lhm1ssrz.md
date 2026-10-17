# GMSTR Destek / Direnc Alarmi

- url: https://www.tradingview.com/script/lHm1sSrz-GMSTR-Destek-Direnc-Alarmi/
- type: indicator
- pine_id: PUB;9925c62db268448e94d45318d2d6cb34
- version: 1.0

## Description

15 minutes support and resistance with notifications; please use it with other indicators, dont use alone, confluence is key to success

## Source Code

````pine
//@version=6
indicator("GMSTR Destek / Direnç Alarmı", overlay=true, max_lines_count=200, max_labels_count=200)

// =========================
// Inputs
// =========================
leftBars   = input.int(3,  "Pivot Left Bars",  minval=1)
rightBars  = input.int(3,  "Pivot Right Bars", minval=1)
showLabels = input.bool(true, "Etiket göster")
extendBars = input.int(150, "Çizgiyi sağa uzat (bar)", minval=10)
useATRFilter = input.bool(true, "ATR filtre kullan")
atrLen     = input.int(14, "ATR Length", minval=1)
atrMult    = input.float(0.40, "Min pivot range / ATR", step=0.05)
useBodyBreakFilter = input.bool(false, "Aynı seviyeye çok yakın sinyalleri filtrele")
minGapPct  = input.float(0.35, "Min yeni seviye farkı (%)", step=0.05)

// =========================
// Core calculations
// =========================
atr = ta.atr(atrLen)

pivHigh = ta.pivothigh(high, leftBars, rightBars)
pivLow  = ta.pivotlow(low, leftBars, rightBars)

// Pivot'ın gerçek bulunduğu bar
pivotBarIndex = bar_index - rightBars

// Pivot mumunun range'i
pivotRangeHigh = high[rightBars] - low[rightBars]
pivotRangeLow  = high[rightBars] - low[rightBars]

// ATR filtresi
validHighATR = not useATRFilter or (pivotRangeHigh >= atr[rightBars] * atrMult)
validLowATR  = not useATRFilter or (pivotRangeLow  >= atr[rightBars] * atrMult)

// Çok yakın seviye filtresi
var float lastResistance = na
var float lastSupport    = na

enoughGapFromLastResistance = na(lastResistance) or not useBodyBreakFilter or math.abs(pivHigh - lastResistance) / lastResistance * 100 >= minGapPct
enoughGapFromLastSupport    = na(lastSupport)    or not useBodyBreakFilter or math.abs(pivLow  - lastSupport)  / lastSupport  * 100 >= minGapPct

newResistance = not na(pivHigh) and validHighATR and enoughGapFromLastResistance
newSupport    = not na(pivLow)  and validLowATR  and enoughGapFromLastSupport

if newResistance
    lastResistance := pivHigh

if newSupport
    lastSupport := pivLow

// =========================
// Plot lines
// =========================
if newResistance
    line.new(
         x1 = pivotBarIndex, y1 = pivHigh,
         x2 = pivotBarIndex + extendBars, y2 = pivHigh,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(color.red, 0),
         width = 2,
         style = line.style_solid
     )
    if showLabels
        label.new(
             x = pivotBarIndex,
             y = pivHigh,
             text = "Direnç\n" + str.tostring(pivHigh, format.mintick),
             style = label.style_label_down,
             color = color.new(color.red, 0),
             textcolor = color.white
         )

if newSupport
    line.new(
         x1 = pivotBarIndex, y1 = pivLow,
         x2 = pivotBarIndex + extendBars, y2 = pivLow,
         xloc = xloc.bar_index,
         extend = extend.none,
         color = color.new(color.green, 0),
         width = 2,
         style = line.style_solid
     )
    if showLabels
        label.new(
             x = pivotBarIndex,
             y = pivLow,
             text = "Destek\n" + str.tostring(pivLow, format.mintick),
             style = label.style_label_up,
             color = color.new(color.green, 0),
             textcolor = color.white
         )

// =========================
// Alert conditions
// =========================
alertcondition(
     newSupport,
     title = "GMSTR Yeni Destek",
     message = "GMSTR için yeni DESTEK oluştu. Seviye: {{close}} | Grafik: {{interval}}"
)

alertcondition(
     newResistance,
     title = "GMSTR Yeni Direnç",
     message = "GMSTR için yeni DİRENÇ oluştu. Seviye: {{close}} | Grafik: {{interval}}"
)

// İstersen dinamik alert() de çalışsın
if newSupport
    alert("GMSTR yeni DESTEK oluştu. Seviye: " + str.tostring(pivLow, format.mintick) + " | TF: " + timeframe.period, alert.freq_once_per_bar_close)

if newResistance
    alert("GMSTR yeni DİRENÇ oluştu. Seviye: " + str.tostring(pivHigh, format.mintick) + " | TF: " + timeframe.period, alert.freq_once_per_bar_close)
````
