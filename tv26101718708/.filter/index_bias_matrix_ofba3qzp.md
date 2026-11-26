# Index Bias Matrix

- url: https://www.tradingview.com/script/OfBa3Qzp/
- type: indicator
- pine_id: PUB;d234a1fc621b4efba63b5e859b23c9b6
- version: 1.0

## Description

This indicator provides a real-time visual representation of the current market regime by combining trend direction and risk sentiment into a dynamic 2D heatmap dashboard. Inspired by the visual matrix concepts, this tool is specifically designed to analyze broad market indices, helping traders filter out the noise and identify the underlying market bias.

How it works & Calculation:
The script calculates a composite score based on two core dimensions over a user-defined lookback period:

    Trend Metric (X-Axis): It evaluates the closing price relative to the 50-period Exponential Moving Average (EMA). Consistent closes above the EMA increase the bullish score, while closes below increase the bearish score.

    Risk Sentiment (Y-Axis): It compares the CBOE Volatility Index (VIX) to its 20-period Simple Moving Average (SMA). A VIX reading below its average indicates a "Risk-On" environment (market confidence), while a spiking VIX signals "Risk-Off" (fear or hedging). Note: If VIX data is unavailable for the selected ticker, the script automatically falls back to an ATR-based volatility measurement.

The indicator maps these metrics onto an 11x11 dashboard in the bottom right corner, categorized into four market quadrants:

    Green (Top Right): Bullish Trend + Risk-On (Strong uptrend environment)

    Red (Bottom Left): Bearish Trend + Risk-Off (Defensive / panic environment)

    Blue (Top Left): Bearish Trend + Risk-On (Potential early recovery phase)

    Orange (Bottom Right): Bullish Trend + Risk-Off (Warning / distribution phase)


Disclaimer:
The information and tools provided are for research and analytical purposes only and are not intended as investment advice. Market analysis involves uncertainty, and outcomes may differ from expectations. Users should conduct their own due diligence and consider their individual circumstances before making any financial decisions. Past performance is not necessarily indicative of future results.

## Source Code

````pine
// Adapted for the Index Composite Bias Score (Trend vs. Risk-On/Off)

//@version=6
indicator("Index Bias Matrix", shorttitle="IBM", overlay = true)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
grp1 = "Basis Einstellungen"
tf = input.timeframe("", title="Indikator Timeframe", group=grp1)
len = input.int(20, "Lookback Length (Glättung)", group=grp1)

grp2 = "Visuelle Unterstützung"
show_smas = input.bool(true, title="SMA 50 & 200 anzeigen", group=grp2)
color_candles = input.bool(true, title="Kerzen nach Bias einfärben", group=grp2)
// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// 1. Abrufen der Preis- und Trend-Daten aus der gewählten Zeitebene (MTF)
[mtf_close, mtf_ema50, mtf_sma50, mtf_sma200, mtf_atr, mtf_atr_sma] = request.security(syminfo.tickerid, tf, [close, ta.ema(close, 50), ta.sma(close, 50), ta.sma(close, 200), ta.atr(14), ta.sma(ta.atr(14), 20)])

// 2. Risk Metric (VIX vs VIX SMA) separat aus der Ziel-Zeitebene abrufen
vix = request.security("CBOE:VIX", tf, close)
vix_sma = request.security("CBOE:VIX", tf, ta.sma(close, 20))

float trend = 0.0
float risk_on = 0.0

// Glättung der Metriken über die eingestellte Länge
for i = 0 to len 
    if mtf_close[i] > mtf_ema50[i]
        trend += 1
    else 
        trend -= 1

for i = 0 to len 
    if not na(vix[i])
        if vix[i] < vix_sma[i]
            risk_on += 1
        else 
            risk_on -= 1
    else 
        if mtf_atr[i] < mtf_atr_sma[i]
            risk_on += 1
        else 
            risk_on -= 1

coeff = 10 / len

trend := trend * coeff
risk_on := risk_on * coeff

// Farbverlauf für die Kerzen basierend auf dem Trend-Score
color_t = trend > 0? color.from_gradient(trend, 0, 10, color.orange, color.lime) : color.from_gradient(trend, -10, 0, color.red, color.orange)
// }


// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// Optionale SMAs direkt auf den Preis plotten
plot(show_smas? mtf_sma50 : na, title="SMA 50", color=color.new(#008cff, 0), linewidth=2)
plot(show_smas? mtf_sma200 : na, title="SMA 200", color=#ff0000, linewidth=2)

// LÖSUNG: Wir nutzen plotcandle anstelle von barcolor. 
// Dadurch "gehören" die Kerzen zum Indikator und verschwinden nicht beim Hovern über die Tabelle.
plotcandle(color_candles? open : na, color_candles? high : na, color_candles? low : na, color_candles? close : na, title='Candles Color', color = color_t, wickcolor=color_t, bordercolor = color_t)

// Mapping der berechneten Werte auf das 11x11 Grid für das Dashboard
val_trend = math.round((trend+10)/2)
val_risk  = math.round((risk_on+10)/2)

// Sicherheitsbegrenzung auf den Index 0 bis 10
val_trend := math.max(0, math.min(10, val_trend))
val_risk  := math.max(0, math.min(10, val_risk))

if barstate.islast
    // Dashboard-Tabelle unten rechts
    dash = table.new(position.bottom_right, 100, 100, border_color = chart.bg_color, border_width = 1)

    dash.merge_cells(1, 0, 11, 0)
    dash.merge_cells(0, 1, 0, 11)

    dash.cell(0, 1, "\n\nO\nN\n\nR\nI\nS\nK\n\nO\nF\nF\n", text_color = chart.fg_color)
    dash.cell(1, 0, "➖  TREND  ➕", text_color = chart.fg_color)

    // Farbpalette für die vier Markt-Quadranten
    color_bull_on  = #318d5f  // Oben Rechts: Bullisch + Risk-On (Grün)
    color_bear_off = #8d3131  // Unten Links: Bärisch + Risk-Off (Rot)
    color_bear_on  = #366ca7  // Oben Links: Bärisch + Risk-On (Blau / Erholungsphase)
    color_bull_off = #8d7c31  // Unten Rechts: Bullisch + Risk-Off (Orange / Warnung)

    point_col =  val_trend+1 < 6 and 11-val_risk < 6? color.from_gradient(11-val_risk, -4, 6, na, color_bear_on) : val_trend+1 > 6 and 11-val_risk > 6? color.from_gradient(11-val_risk, 1, 12, color_bull_off, na) : val_trend+1 > 6 and 11-val_risk < 6? color.from_gradient(11-val_risk, -4, 6, na, color_bull_on) : val_trend+1 < 6 and 11-val_risk > 6? color.from_gradient(11-val_risk, 1, 12, color_bear_off, na) : val_trend+1 == 6 and 11-val_risk == 6? #2d3e76 : #1b2445
    
    // Raster der Heatmap einfärben
    for row = 1 to 11
        for col = 1 to 11
            if row > 0
                bgc = col < 6 and row < 6? color.from_gradient(row, -4, 6, na, color_bear_on) : col > 6 and row > 6? color.from_gradient(row, 1, 12, color_bull_off, na) : col > 6 and row < 6? color.from_gradient(row, -4, 6, na, color_bull_on) : col < 6 and row > 6? color.from_gradient(row, 1, 12, color_bear_off, na) : col == 6 and row == 6? #2d3e76 : #1b2445
                dash.cell(col, row, bgcolor = bgc, height = 3, width = 1)

    // Den animierten Punkt (Slider) im entsprechenden Grid-Feld platzieren
    dash.cell(val_trend+1, 11-val_risk, height = 3, bgcolor = point_col, text = "🔵", width = 1)
// }
````
