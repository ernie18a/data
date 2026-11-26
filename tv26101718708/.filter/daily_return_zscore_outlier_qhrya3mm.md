# Daily Return Z-Score / Outlier

- url: https://www.tradingview.com/script/qHrya3Mm/
- type: indicator
- pine_id: PUB;9d8a2a1947684a3fa8f6bf7dd25fb4bc
- version: 1.0

## Description

[b]Daily Return Z-Score / Outlier[/b]

[b]What this indicator does[/b]

[b]Daily Return Z-Score / Outlier[/b] measures how unusual today's daily return is relative to the instrument's own historical return distribution. It converts the current return into a Z-Score (standard-deviation scale) and colours the bars according to whether the return sits in the normal range, a warning zone, or an extreme zone (fat-tail event).

The goal is to make statistical outliers visible — days on which the price move is materially larger than the recent history would suggest.

[b]How it works[/b]

[list=1]
[*][b]Data basis (daily context):[/b] Daily returns are sampled on the daily timeframe ("D") via request.security, independent of the chart timeframe currently displayed. This keeps the statistical reference consistent.
[*][b]Return calculation:[/b] Either simple percentage returns (close − close[1]) / close[1] or log returns ln(close / close[1]).
[*][b]Distribution statistics over a rolling window[/b] (default: 252 trading days ≈ 1 year). Two methods are available:
[list]
[*][b]MAD (robust):[/b] Median and median absolute deviation. Insensitive to individual extreme values. The Z-Score is computed as 0.6745 · (return − median) / MAD (scaled to the normal distribution).
[*][b]Classic:[/b] Mean and standard deviation. Z = (return − mean) / stdev. More reactive to, and distorted by, extreme values.
[/list]
[*][b]Empirical percentiles:[/b] In addition to the Z-Score, warning and extreme thresholds are derived directly from the observed percentiles of the return distribution (e.g. 5% / 95% for warning, 1% / 99% for extreme). Bar colour follows these empirical percentiles rather than normality assumptions.
[*][b]Live return:[/b] The running return is computed against yesterday's daily close, so the classification updates intraday as the current day develops.
[/list]

[b]Display[/b]

[list]
[*][b]Histogram[/b] of the Z-Score on a common sigma scale.
[*][b]Reference lines[/b] at 0, ±1, ±2 and ±3 sigma for visual orientation.
[*][b]Live label[/b] showing the current Z-Score on the last bar.
[*][b]Values table[/b] (optional, bottom-right) with Z-Score, band classification, selected method, today's return, the dispersion measure (MAD or stdev), warning/extreme thresholds, and the effective sample size.
[/list]

[b]Colour logic[/b]

[list]
[*][b]Normal[/b] — return within the warning percentiles.
[*][b]Warn + / −[/b] — return beyond the warning percentile.
[*][b]EXTREME + / −[/b] — return beyond the extreme percentile (fat tail).
[/list]

[b]Settings[/b]

[list]
[*][b]Method:[/b] MAD (robust) or Classic (mean/stdev).
[*][b]Lookback (days):[/b] Length of the statistics window (5–1000).
[*][b]Log returns:[/b] Log instead of percentage returns.
[*][b]Warning percentile %[/b] and [b]Extreme percentile %:[/b] Colouring thresholds.
[*][b]Colours[/b] for bullish/bearish warning and extreme zones.
[*][b]Show values table.[/b]
[/list]

[b]Alerts[/b]

[list]
[*][i]Extreme outlier UP[/i] — daily return beyond the upper extreme percentile.
[*][i]Extreme outlier DOWN[/i] — daily return beyond the lower extreme percentile.
[*][i]Extreme outlier (both directions)[/i] — combined condition.
[/list]

[b]How to use it[/b]

The indicator helps highlight days with a statistically notable move — for example to add context to news days, to watch for volatility clustering, or as a filter alongside an existing strategy. The MAD method is recommended when the history contains isolated strong outliers.

[b]Notes[/b]

[list]
[*]A Z-Score measures how [i]unusual[/i] a move is, not its direction as a forecast.
[*]Significance depends on a sufficiently large sample (see the "Sample" field in the table).
[*]This script is an analysis tool and does not constitute financial advice. Past distributions are no guarantee of future behaviour.
[/list]


[b]═══════════════════════════════════════[/b]


[b]Daily Return Z-Score / Outlier — Deutsch[/b]

[b]Was macht dieser Indikator?[/b]

[b]Daily Return Z-Score / Outlier[/b] misst, wie ungewöhnlich der heutige Tages-Return im Vergleich zur eigenen historischen Verteilung des Wertpapiers ist. Der Indikator wandelt den aktuellen Return in einen Z-Score (Standardabweichungs-Skala) um und färbt die Balken danach ein, ob sich der Return im normalen Bereich, in einer Warn-Zone oder in einer Extrem-Zone (Fat-Tail-Ereignis) befindet.

Ziel ist es, statistische Ausreisser sichtbar zu machen — also Tage, an denen die Kursbewegung deutlich grösser ausfällt, als es die jüngste Historie nahelegt.

[b]Wie es funktioniert[/b]

[list=1]
[*][b]Datenbasis (Daily-Kontext):[/b] Über request.security werden die Tages-Returns auf dem Tages-Timeframe ("D") erhoben, unabhängig vom aktuell angezeigten Chart-Timeframe. So bleibt der statistische Bezug konsistent.
[*][b]Return-Berechnung:[/b] Wahlweise einfache prozentuale Returns (close − close[1]) / close[1] oder Log-Returns ln(close / close[1]).
[*][b]Verteilungsstatistik über ein rollierendes Fenster[/b] (Standard: 252 Handelstage ≈ 1 Jahr). Zwei Methoden stehen zur Wahl:
[list]
[*][b]MAD (robust):[/b] Median und Median-Absolutabweichung. Unempfindlich gegen einzelne Extremwerte. Der Z-Score wird als 0.6745 · (Return − Median) / MAD berechnet (skaliert auf die Normalverteilung).
[*][b]Klassisch:[/b] Mittelwert und Standardabweichung. Z = (Return − Mean) / Stdev. Reagiert stärker auf Extremwerte und wird von diesen verzerrt.
[/list]
[*][b]Empirische Perzentile:[/b] Zusätzlich zum Z-Score werden Warn- und Extrem-Schwellen direkt aus den beobachteten Perzentilen der Return-Verteilung gebildet (z. B. 5% / 95% für Warnung, 1% / 99% für Extrem). Die Balkenfarbe richtet sich nach diesen empirischen Perzentilen, nicht nach Normalverteilungs-Annahmen.
[*][b]Live-Return:[/b] Der laufende Return wird gegen den gestrigen Tages-Schluss berechnet, sodass die Einordnung schon während des laufenden Tages aktualisiert wird.
[/list]

[b]Anzeige[/b]

[list]
[*][b]Histogramm[/b] des Z-Scores auf einer gemeinsamen Sigma-Skala.
[*][b]Referenzlinien[/b] bei 0, ±1, ±2 und ±3 Sigma zur visuellen Orientierung.
[*][b]Live-Label[/b] mit dem aktuellen Z-Score am letzten Balken.
[*][b]Werte-Tabelle[/b] (optional, unten rechts) mit Z-Score, Band-Einstufung, gewählter Methode, heutigem Return, Streuungsmass (MAD bzw. Stdev), Warn-/Extrem-Schwellen sowie der effektiven Stichprobengrösse.
[/list]

[b]Farb-Logik[/b]

[list]
[*][b]Normal[/b] — Return innerhalb der Warn-Perzentile.
[*][b]Warn + / −[/b] — Return jenseits des Warn-Perzentils.
[*][b]EXTREM + / −[/b] — Return jenseits des Extrem-Perzentils (Fat Tail).
[/list]

[b]Einstellungen[/b]

[list]
[*][b]Methode:[/b] MAD (robust) oder Klassisch (mean/stdev).
[*][b]Lookback (Tage):[/b] Länge des Statistik-Fensters (5–1000).
[*][b]Log-Returns:[/b] Log- statt prozentuale Returns.
[*][b]Warn-Perzentil %[/b] und [b]Extrem-Perzentil %:[/b] Schwellen für die Färbung.
[*][b]Farben[/b] für bullische/bärische Warn- und Extrem-Zonen.
[*][b]Werte-Tabelle anzeigen.[/b]
[/list]

[b]Alerts[/b]

[list]
[*][i]Extrem-Ausreisser HOCH[/i] — Tagesreturn jenseits des oberen Extrem-Perzentils.
[*][i]Extrem-Ausreisser RUNTER[/i] — Tagesreturn jenseits des unteren Extrem-Perzentils.
[*][i]Extrem-Ausreisser (beide Richtungen)[/i] — kombinierte Bedingung.
[/list]

[b]Verwendung[/b]

Der Indikator eignet sich, um Tage mit statistisch auffälliger Bewegung hervorzuheben — etwa zur Kontext-Einordnung von News-Tagen, zur Beobachtung von Volatilitäts-Clustern oder als Filter neben einer bestehenden Strategie. Die MAD-Methode wird empfohlen, wenn die Historie einzelne starke Ausreisser enthält.

[b]Hinweise[/b]

[list]
[*]Ein Z-Score misst die [i]Ungewöhnlichkeit[/i] einer Bewegung, nicht deren Richtung im Sinne einer Prognose.
[*]Die Aussagekraft hängt von einer ausreichend grossen Stichprobe ab (siehe Feld "Sample" in der Tabelle).
[*]Dieses Skript ist ein Analyse-Werkzeug und stellt keine Anlageberatung dar. Vergangene Verteilungen sind keine Garantie für zukünftiges Verhalten.
[/list]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) Tools-for-Trader

//@version=6
indicator(title = "Daily Return Z-Score / Outlier", shorttitle = "DR Outlier", overlay = false, format = format.price, precision = 2)

// --- Inputs --------------------------------------------------------------
string methodInput    = input.string("MAD (robust)", "Method", options = ["MAD (robust)", "Classic (mean/stdev)"], tooltip = "MAD: median + median absolute deviation, robust against outliers. Classic: mean + stdev, distorted by extreme values.")
int    lookbackInput  = input.int(252, "Lookback (days)", minval = 5, maxval = 1000, tooltip = "Number of daily returns used for the distribution statistics (252 ~ 1 trading year)")
bool   useLogInput    = input.bool(false, "Log returns", tooltip = "Log returns instead of simple percentage returns")
float  pWarnInput     = input.float(5.0, "Warning percentile %", minval = 0.5, maxval = 20.0, step = 0.5, group = "Thresholds", tooltip = "Warning colour beyond the p / (100-p) percentile")
float  pExtInput      = input.float(1.0, "Extreme percentile %", minval = 0.1, maxval = 10.0, step = 0.1, group = "Thresholds", tooltip = "Extreme colour beyond the p / (100-p) percentile (fat tails)")
color  bullColorInput = input.color(#26a69a, "Bullish colour (warn)", group = "Colours")
color  bearColorInput = input.color(#ef5350, "Bearish colour (warn)", group = "Colours")
color  extBullInput   = input.color(#00e676, "Extreme bullish colour", group = "Colours")
color  extBearInput   = input.color(#ff1744, "Extreme bearish colour", group = "Colours")
bool   showTblInput   = input.bool(true, "Show values table", group = "Colours")

// --- Helper functions (global scope) -------------------------------------
fmt(float val)    => str.tostring(val, "#,##0.00")
fmtPct(float val) => str.tostring(val * 100, "#,##0.00") + "%"

// Distribution statistics of daily returns (rets is a function-local var so
// it can be mutated inside a function evaluated in request.security)
calcStats() =>
    var array<float> rets = array.new<float>()
    float r = useLogInput ? math.log(close / close[1]) : (close - close[1]) / close[1]
    if barstate.isconfirmed and not na(r)
        array.push(rets, r)
        if array.size(rets) > lookbackInput
            array.shift(rets)
    int n = array.size(rets)
    float mu    = n > 1 ? array.avg(rets)    : na
    float sigma = n > 1 ? array.stdev(rets)  : na
    float med   = n > 1 ? array.median(rets) : na
    float mad   = na
    if n > 1
        array<float> ad = array.new<float>()
        for v in rets
            array.push(ad, math.abs(v - med))
        mad := array.median(ad)
    float pWlo = n > 1 ? array.percentile_linear_interpolation(rets, pWarnInput) : na
    float pWhi = n > 1 ? array.percentile_linear_interpolation(rets, 100.0 - pWarnInput) : na
    float pElo = n > 1 ? array.percentile_linear_interpolation(rets, pExtInput) : na
    float pEhi = n > 1 ? array.percentile_linear_interpolation(rets, 100.0 - pExtInput) : na
    [mu, sigma, med, mad, pWlo, pWhi, pElo, pEhi, n]

// --- Daily statistics from calcStats() -----------------------------------
[mu, sigma, med, mad, pWlo, pWhi, pElo, pEhi, nSamples] = request.security(syminfo.tickerid, "D", calcStats(), lookahead = barmerge.lookahead_off)

// --- Current (live) return: price vs. yesterday's daily close ------------
float yClose   = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)
float todayRet = useLogInput ? math.log(close / yClose) : (close - yClose) / yClose

// --- Indicator value (common sigma scale) --------------------------------
bool  isMad   = methodInput == "MAD (robust)"
float zScore  = na(todayRet) ? 0.0 : isMad ? ((na(mad) or mad == 0) ? 0.0 : 0.6745 * (todayRet - med) / mad) : ((na(sigma) or sigma == 0) ? 0.0 : (todayRet - mu) / sigma)

// --- Colour by empirical percentiles -------------------------------------
color barColor = na(todayRet) or na(med) ? color.new(color.gray, 50) : todayRet >= pEhi ? extBullInput : todayRet >= pWhi ? bullColorInput : todayRet <= pElo ? extBearInput : todayRet <= pWlo ? bearColorInput : todayRet > med ? color.new(bullColorInput, 45) : color.new(bearColorInput, 45)
string band    = na(todayRet) or na(med) ? "n/a"                      : todayRet >= pEhi ? "EXTREME +" : todayRet >= pWhi ? "Warn +" : todayRet <= pElo ? "EXTREME -" : todayRet <= pWlo ? "Warn -" : "Normal"

// --- Alerts (extreme outliers beyond extreme percentile) -----------------
bool extUp = not na(todayRet) and not na(pEhi) and todayRet >= pEhi
bool extDn = not na(todayRet) and not na(pElo) and todayRet <= pElo
alertcondition(extUp, title = "Extreme outlier UP", message = "{{ticker}}: Extreme outlier UP - daily return beyond extreme percentile")
alertcondition(extDn, title = "Extreme outlier DOWN", message = "{{ticker}}: Extreme outlier DOWN - daily return beyond extreme percentile")
alertcondition(extUp or extDn, title = "Extreme outlier (both directions)", message = "{{ticker}}: Extreme outlier - daily return beyond extreme percentile")

var bool firedToday = false
if bool(ta.change(time("D")))
    firedToday := false
if (extUp or extDn) and not firedToday
    alert("Extreme outlier " + (extUp ? "UP +" : "DOWN -") + " " + syminfo.ticker + "  |  z=" + fmt(zScore) + " s  |  Return=" + fmtPct(todayRet) + "  |  Method=" + (isMad ? "MAD" : "mean/stdev"), alert.freq_once_per_bar)
    firedToday := true

// --- Reference lines (sigma scale) ---------------------------------------
hline(0,  "0 sigma", color.gray, hline.style_solid)
hline(1,  "+1 sigma", color.new(color.gray, 60), hline.style_dashed)
hline(-1, "-1 sigma", color.new(color.gray, 60), hline.style_dashed)
hline(2,  "+2 sigma", color.new(color.orange, 50), hline.style_dotted)
hline(-2, "-2 sigma", color.new(color.orange, 50), hline.style_dotted)
hline(3,  "+3 sigma", color.new(color.red, 40), hline.style_dotted)
hline(-3, "-3 sigma", color.new(color.red, 40), hline.style_dotted)

// --- Bar chart + live label ----------------------------------------------
plot(zScore, "Z-Score", barColor, 3, plot.style_histogram, histbase = 0)

var label lbl = na
if barstate.islast
    label.delete(lbl)
    lbl := label.new(bar_index, zScore, text = fmt(zScore) + " s", style = zScore >= 0 ? label.style_label_down : label.style_label_up, color = barColor, textcolor = color.white, size = size.small)

// --- Values table (bottom right) -----------------------------------------
if showTblInput
    var table t = table.new(position.bottom_right, 2, 7, bgcolor = color.new(#111111, 75), border_width = 1, border_color = color.new(color.gray, 70))
    string arrow = todayRet >= 0 ? "+" : ""
    table.cell(t, 0, 0, "Z-Score",                                     text_color = color.gray,  text_size = size.small, width = 11)
    table.cell(t, 1, 0, fmt(zScore) + " s",                            text_color = barColor,     text_size = size.normal, width = 12)
    table.cell(t, 0, 1, "Band",                                        text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 1, band,                                          text_color = barColor,     text_size = size.normal)
    table.cell(t, 0, 2, "Method",                                      text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 2, isMad ? "MAD" : "mean/stdev",                  text_color = color.white,  text_size = size.small)
    table.cell(t, 0, 3, "Today",                                       text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 3, arrow + fmtPct(todayRet) + " vs yesterday",    text_color = todayRet >= 0 ? bullColorInput : bearColorInput, text_size = size.small)
    table.cell(t, 0, 4, "Dispersion",                                  text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 4, isMad ? "MAD " + fmtPct(mad) : "s " + fmtPct(sigma), text_color = color.white, text_size = size.small)
    table.cell(t, 0, 5, "Warn / Ext",                                  text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 5, fmtPct(pWlo) + " / " + fmtPct(pElo) + "  ..  " + fmtPct(pWhi) + " / " + fmtPct(pEhi), text_color = color.white, text_size = size.tiny)
    table.cell(t, 0, 6, "Sample",                                      text_color = color.gray,  text_size = size.small)
    table.cell(t, 1, 6, str.tostring(nSamples) + " / " + str.tostring(lookbackInput) + " d", text_color = color.white, text_size = size.small)
````
