# NEXUS PRO - RSI UYUMSUZLUK

- url: https://www.tradingview.com/script/RA5tkDqc/
- type: indicator
- pine_id: PUB;48453cb379df4a59a11464261cc414ac
- version: 1.0

## Description

NEXUS PRO - RSI Divergence Visualizer
NEXUS PRO is a precision-engineered tool designed to detect and visualize RSI divergences directly on your price chart. Divergences are one of the most powerful signals in technical analysis, often marking the exhaustion of a trend and the beginning of a reversal.
How it works:
The script monitors price pivots (Highs/Lows) and compares them with the RSI oscillator. When price creates a lower low but RSI shows a higher low, a Bullish Divergence is identified. Conversely, when price hits a higher high but RSI lags with a lower high, a Bearish Divergence is triggered.
Key Features:
Automatic Trendlines: Draws solid lines between price pivots to provide clear visual confirmation.
Customizable Sensitivity: Adjust Pivot Left/Right bars to filter out noise or capture micro-divergences.
Minimalist UI: Uses clean diamond shapes and customizable colors to keep your chart clutter-free.
Real-time Alerts: Integrated alert conditions for both Bullish and Bearish signals so you never miss a move.

## Source Code

````pine
//@version=5
indicator("NEXUS PRO - RSI Çizgili Uyumsuzluk", overlay=true, max_lines_count=500)

// =================================================================
// --- GİRDİLER ---
// =================================================================
rsiLen_div = input.int(14, title="RSI Periyodu (Uyumsuzluk)", group="RSI Uyumsuzluk Ayarları")
lbR_div    = input.int(5,  title="Pivot Sağ Boşluk", group="RSI Uyumsuzluk Ayarları")
lbL_div    = input.int(5,  title="Pivot Sol Boşluk", group="RSI Uyumsuzluk Ayarları")

// --- Görünüm Ayarları ---
colBull    = input.color(color.green, title="Pozitif (Boğa) Uyumsuzluk Rengi", group="Görünüm Ayarları")
colBear    = input.color(color.red, title="Negatif (Ayı) Uyumsuzluk Rengi", group="Görünüm Ayarları")
lineWidth  = input.int(1, title="Çizgi Kalınlığı", minval=1, maxval=4, group="Görünüm Ayarları")

// =================================================================
// --- HESAPLAMALAR ---
// =================================================================
rsi_div = ta.rsi(close, rsiLen_div)

// Pivot noktalarını belirle
plFound_div = not na(ta.pivotlow(rsi_div, lbL_div, lbR_div))
phFound_div = not na(ta.pivothigh(rsi_div, lbL_div, lbR_div))

// Önceki pivotların bar indeksleri ve fiyat değerleri
prev_pl_bar = ta.valuewhen(plFound_div, bar_index[lbR_div], 1)
prev_pl_val = ta.valuewhen(plFound_div, low[lbR_div], 1)

prev_ph_bar = ta.valuewhen(phFound_div, bar_index[lbR_div], 1)
prev_ph_val = ta.valuewhen(phFound_div, high[lbR_div], 1)

// Pozitif Uyumsuzluk (Boğa)
bullCond_div = low[lbR_div] < prev_pl_val and rsi_div[lbR_div] > ta.valuewhen(plFound_div, rsi_div[lbR_div], 1)
bullishDiv   = plFound_div and bullCond_div

// Negatif Uyumsuzluk (Ayı)
bearCond_div = high[lbR_div] > prev_ph_val and rsi_div[lbR_div] < ta.valuewhen(phFound_div, rsi_div[lbR_div], 1)
bearishDiv   = phFound_div and bearCond_div

// =================================================================
// --- ÇİZİMLER ---
// =================================================================
// Al/Sat yazısı olmadan sadece minik elmaslar (Renkler ayar menüsünden gelir)
plotshape(bullishDiv ? low[lbR_div] : na, offset=-lbR_div, title="RSI Pozitif Uyumsuzluk", style=shape.diamond, location=location.belowbar, color=colBull, size=size.tiny)
plotshape(bearishDiv ? high[lbR_div] : na, offset=-lbR_div, title="RSI Negatif Uyumsuzluk", style=shape.diamond, location=location.abovebar, color=colBear, size=size.tiny)

// Uyumsuzluk Çizgilerini Fiyat Grafiğine Çiz (Düz Çizgi ve Seçilebilir Renk)
if bullishDiv
    line.new(x1=prev_pl_bar, y1=prev_pl_val, x2=bar_index[lbR_div], y2=low[lbR_div], color=colBull, width=lineWidth, style=line.style_solid)

if bearishDiv
    line.new(x1=prev_ph_bar, y1=prev_ph_val, x2=bar_index[lbR_div], y2=high[lbR_div], color=colBear, width=lineWidth, style=line.style_solid)

// =================================================================
// --- ALARMLAR ---
// =================================================================
alertcondition(bullishDiv, title="NEXUS PRO: Pozitif Uyumsuzluk", message="NEXUS PRO: RSI Pozitif Uyumsuzluk Tespit Edildi! (Alış Yönlü İncele)")
alertcondition(bearishDiv, title="NEXUS PRO: Negatif Uyumsuzluk", message="NEXUS PRO: RSI Negatif Uyumsuzluk Tespit Edildi! (Satış Yönlü İncele)")
````
