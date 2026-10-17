# Adaptive Trend Bands

- url: https://www.tradingview.com/script/JAxIgbpv-Adaptive-Trend-Bands/
- type: indicator
- pine_id: PUB;7ae97ad6a44f497c80889e63cef7f231
- version: 1.0

## Description

Adaptive Trend Bands

Adaptive Trend Bands is a band indicator built around a centered weighted moving average with ATR-based envelopes. It looks a bit like Bollinger Bands, but the logic is different: the midline is a symmetrically weighted average, and the band width comes from a smoothed True Range instead of standard deviation.

WHAT YOU SEE ON THE CHART
- A median line in the center
- 3 upper bands and 3 lower bands, each with its own ATR multiplier
- All lines share a single, user-selectable color

HOW TO USE IT
- Bands 1, 2 and 3 mark increasing levels of price stretch away from the mean. Price reaching the outer bands can signal overextension.
- Combine it with your own tools such as price action, support/resistance and higher-timeframe bias. It is meant as a visual aid, not a standalone signal.

ALERTS
Six separate alerts are available: Upper Band 1, 2, 3 touch and Lower Band 1, 2, 3 touch. Each alert fires once when price first reaches the band. Optional triangle markers on the chart show the touches.

FULLY CUSTOMIZABLE
- Centered weighted-average half period (default 60)
- Price source (Close, Open, High, Low, Median, Typical, Weighted, Average)
- ATR period (default 100)
- ATR multipliers (defaults 4.2 / 3.5 / 2.8)
- Band color, midline color, line width
- Touch markers on/off

REPAINT DISCLOSURE
This indicator uses a centered (two-sided) weighted average, meaning the calculation for the most recent bars looks both backward and forward in time. As a result, the last ~60 bars can be recalculated and shift slightly as new price data arrives. Historical bars away from the current time are fully calculated and do not repaint. This is a known characteristic of centered filters and is disclosed here for transparency. Please account for this when testing and do not rely on the most recent bars for backtesting performance.

DISCLAIMER
This script is for educational and informational purposes only and is not financial advice. Trading involves risk. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Adaptive Trend Bands", "ATB", overlay = true, max_lines_count = 500, max_bars_back = 500)

// ================== AYARLAR ==================
g1 = "Hesaplama"
HalfLength     = input.int(60, "Centered YSR Half Period", minval = 1, maxval = 70, group = g1)
PriceType      = input.string("Weighted", "Price to Use", options = ["Close", "Open", "High", "Low", "Median", "Typical", "Weighted", "Average"], group = g1)
AtrPeriod      = input.int(100, "Average True Range Period", minval = 1, group = g1)
AtrMultiplier1 = input.float(4.2, "ATR Multiplier 1", step = 0.1, group = g1)
AtrMultiplier2 = input.float(3.5, "ATR Multiplier 2", step = 0.1, group = g1)
AtrMultiplier3 = input.float(2.8, "ATR Multiplier 3", step = 0.1, group = g1)

g2 = "Görünüm"
bandColor      = input.color(#2962ff, "Bant Rengi (tüm bantlar tek renk)", group = g2)
midColor       = input.color(#2962ff, "Orta Çizgi Rengi", group = g2)
lineWidth      = input.int(1, "Çizgi Kalınlığı", minval = 1, maxval = 5, group = g2)
showMarkers    = input.bool(true, "Bant teması işaretleri", group = g2)

// ================== FONKSİYONLAR ==================
price(int x) =>
    float p = switch PriceType
        "Close"    => close[x]
        "Open"     => open[x]
        "High"     => high[x]
        "Low"      => low[x]
        "Median"   => (high[x] + low[x]) / 2
        "Typical"  => (high[x] + low[x] + close[x]) / 3
        "Weighted" => (high[x] + low[x] + close[x] + close[x]) / 4
        "Average"  => (high[x] + low[x] + close[x] + open[x]) / 4
    p

calc(int i) =>
    float atr = 0.0
    for j = 0 to AtrPeriod - 1
        atr += math.max(high[i + j + 10], close[i + j + 11]) - math.min(low[i + j + 10], close[i + j + 11])
    atr /= AtrPeriod
    float sum  = (HalfLength + 1) * price(i)
    float sumw = HalfLength + 1
    int k = HalfLength
    for j = 1 to HalfLength
        sum  += k * price(i + j)
        sumw += k
        if j <= i
            sum  += k * price(i - j)
            sumw += k
        k -= 1
    [sum / sumw, atr]

// ================== GEÇMİŞ (ortalanmış) SERİ ==================
[cC, aC] = calc(HalfLength)

plot(cC + AtrMultiplier3 * aC, "Üst Bant 3", color = bandColor, linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)
plot(cC + AtrMultiplier2 * aC, "Üst Bant 2", color = bandColor, linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)
plot(cC + AtrMultiplier1 * aC, "Üst Bant 1", color = bandColor, linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)
plot(cC,                       "Orta",       color = midColor,  linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)
plot(cC - AtrMultiplier1 * aC, "Alt Bant 1", color = bandColor, linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)
plot(cC - AtrMultiplier2 * aC, "Alt Bant 2", color = bandColor, linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)
plot(cC - AtrMultiplier3 * aC, "Alt Bant 3", color = bandColor, linewidth = lineWidth, offset = -HalfLength, editable = false, display = display.pane)

// ================== SAĞ UÇ (güncel fiyata bakan bantlar) ==================
[cE, aE] = calc(0)

u1 = cE + AtrMultiplier1 * aE
u2 = cE + AtrMultiplier2 * aE
u3 = cE + AtrMultiplier3 * aE
d1 = cE - AtrMultiplier1 * aE
d2 = cE - AtrMultiplier2 * aE
d3 = cE - AtrMultiplier3 * aE

// ================== SON BARDA ÇİZGİLERİ ÇİZ ==================
if barstate.islast
    for l in line.all
        line.delete(l)

    float pc = na
    float pu1 = na
    float pu2 = na
    float pu3 = na
    float pd1 = na
    float pd2 = na
    float pd3 = na

    for i = HalfLength to 0
        [c, a] = calc(i)
        float su1 = c + AtrMultiplier1 * a
        float su2 = c + AtrMultiplier2 * a
        float su3 = c + AtrMultiplier3 * a
        float sd1 = c - AtrMultiplier1 * a
        float sd2 = c - AtrMultiplier2 * a
        float sd3 = c - AtrMultiplier3 * a

        if i < HalfLength
            int x1 = bar_index - (i + 1)
            int x2 = bar_index - i
            line.new(x1, pu1, x2, su1, width = lineWidth, color = bandColor)
            line.new(x1, pu2, x2, su2, width = lineWidth, color = bandColor)
            line.new(x1, pu3, x2, su3, width = lineWidth, color = bandColor)
            line.new(x1, pc,  x2, c,   width = lineWidth, color = midColor)
            line.new(x1, pd1, x2, sd1, width = lineWidth, color = bandColor)
            line.new(x1, pd2, x2, sd2, width = lineWidth, color = bandColor)
            line.new(x1, pd3, x2, sd3, width = lineWidth, color = bandColor)

        pc := c
        pu1 := su1
        pu2 := su2
        pu3 := su3
        pd1 := sd1
        pd2 := sd2
        pd3 := sd3

// ================== ALARMLAR ==================
tU1 = high >= u1
tU2 = high >= u2
tU3 = high >= u3
tD1 = low <= d1
tD2 = low <= d2
tD3 = low <= d3

evU1 = tU1 and not tU1[1]
evU2 = tU2 and not tU2[1]
evU3 = tU3 and not tU3[1]
evD1 = tD1 and not tD1[1]
evD2 = tD2 and not tD2[1]
evD3 = tD3 and not tD3[1]

alertcondition(evU1, "Üst Bant 1 Temas", "{{ticker}} fiyat ÜST BANT 1'e değdi")
alertcondition(evU2, "Üst Bant 2 Temas", "{{ticker}} fiyat ÜST BANT 2'ye değdi")
alertcondition(evU3, "Üst Bant 3 Temas", "{{ticker}} fiyat ÜST BANT 3'e değdi")
alertcondition(evD1, "Alt Bant 1 Temas", "{{ticker}} fiyat ALT BANT 1'e değdi")
alertcondition(evD2, "Alt Bant 2 Temas", "{{ticker}} fiyat ALT BANT 2'ye değdi")
alertcondition(evD3, "Alt Bant 3 Temas", "{{ticker}} fiyat ALT BANT 3'e değdi")

plotshape(showMarkers and (evU1 or evU2 or evU3), "Üst Temas", shape.triangledown, location.abovebar, bandColor, size = size.tiny)
plotshape(showMarkers and (evD1 or evD2 or evD3), "Alt Temas", shape.triangleup, location.belowbar, bandColor, size = size.tiny)
````
