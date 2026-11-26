# Macro Liquidity Flow Index V3

- url: https://www.tradingview.com/script/9xWvysFS/
- type: indicator
- pine_id: PUB;c415408ea00742ac9b2d3bf2886d4cdf
- version: 1.0

## Description

[b]Konstruktionsmethodik: [/b]
Z-Score Normalisierung 
Da wir Datenreihen mit völlig unterschiedlichen Einheiten (Prozentpunkte bei Zinsen, dimensionslose Ratios bei HYG/IEF) kombinieren, ist eine Normalisierung zwingend erforderlich. Wir verwenden den Z-Score (Standard-Score), der misst, wie viele Standardabweichungen ein Wert vom gleitenden Durchschnitt abweicht. Dies macht die Volatilität der verschiedenen Komponenten vergleichbar.

Formel für den Z-Score einer Zeitreihe $x$ über eine Periode $n$ (z.B. 252 Handelstage):$$Z_t = \frac{x_t - \mu_n}{\sigma_n}$$

[b]Die Komponenten des MLFI[/b]
Der Indikator setzt sich aus vier gewichteten Sub-Komponenten zusammen:

1.Yield Curve Momentum ($Z_{Curve}$):
Formel: US10Y - US02Y
Logik: Ein steiler werdender Spread (Steepening) aus einer Inversion heraus ist oft der Beginn eines neuen Zyklus. Wir bewerten Normalisierung positiv.
Gewichtung: 25%

2.Credit Risk Appetite ($Z_{Credit}$):
Formel: HYG / IEF (Schlusskurse)
Logik: Steigendes Ratio = Risk-On. Dies ist die wichtigste Komponente.
Gewichtung: 35%

3.Growth Impulse ($Z_{Growth}$):
Formel: HG1! / GOLD (Kupfer Futures / Gold Spot)
Logik: Steigendes Ratio = Industrielle Nachfrage > Monetäre Angst.Gewichtung: 20%Monetary Conditions ($Z_{RealRates}$):Formel: (US10Y - USGGBE10) * -1 (Invertiert)
Logik: Steigende Realzinsen sind restriktiv. Durch die Invertierung wird ein fallender Realzins zu einem positiven Wert für den Indikator (Lockerung).
Gewichtung: 20%

Gesamtformel:$[symbol="ECONOMICS:MLFI"]ECONOMICS:MLFI[/symbol] = 0.35 \cdot Z_{Credit} + 0.25 \cdot Z_{Curve} + 0.20 \cdot Z_{Growth} + 0.20 \cdot Z_{RealRates}$$

Disclaimer:
The information and tools provided are for research and analytical purposes only and are not intended as investment advice. Market analysis involves uncertainty, and outcomes may differ from expectations. Users should conduct their own due diligence and consider their individual circumstances before making any financial decisions. Past performance is not necessarily indicative of future results.

## Source Code

````pine
//@version=6
indicator('Macro Liquidity Flow Index V3', shorttitle = 'MLFI.3', overlay = false)

// --- Eingabe Parameter ---
lookback = input.int(252, 'Z-Score Lookback (Handelstage)', minval = 50, group = 'Allgemeine Einstellungen')
smooth = input.int(20, 'Signal Glättung (EMA)', minval = 1, group = 'Allgemeine Einstellungen')
noise_threshold = input.float(0.25, 'Neutraler Bereich (+/-)', minval = 0.0, step = 0.05, tooltip = 'Innerhalb dieses Bereichs werden Linie und Füllung grau.', group = 'Allgemeine Einstellungen')

// --- Gewichtung ---
grp_weight = 'Gewichtung der Komponenten'
w_credit = input.float(0.35, 'Gewichtung: Credit Ratio (HYG / IEF)', minval = 0.0, step = 0.05, group = grp_weight)
w_curve = input.float(0.25, 'Gewichtung: Yield Curve (US10Y - US02Y)', minval = 0.0, step = 0.05, group = grp_weight)
w_growth = input.float(0.20, 'Gewichtung: Growth Ratio (HG1! / GOLD)', minval = 0.0, step = 0.05, group = grp_weight)
w_real = input.float(0.20, 'Gewichtung: Real Yield (US10Y - FRED:T10YIE)', minval = 0.0, step = 0.05, group = grp_weight)

// --- Zusätzliche Schwellen ---
grp_thresh = 'Zusätzliche Schwellenwerte'
show_extra_thresh = input.bool(true, 'Zusätzliche Schwellen anzeigen?', group = grp_thresh)
extra_thresh_val = input.float(0.75, 'Wert (+/-)', step = 0.05, group = grp_thresh)

// WICHTIG: Wir erzwingen hier "D" (Daily)
res_tf = 'D'

// --- Datenabruf (Request Security) ---
us10y = request.security('US10Y', res_tf, close)
us02y = request.security('US02Y', res_tf, close)
yield_curve = us10y - us02y

hyg = request.security('AMEX:HYG', res_tf, close)
ief = request.security('NASDAQ:IEF', res_tf, close)
credit_ratio = hyg / ief

copper = request.security('COMEX:HG1!', res_tf, close)
gold = request.security('TVC:GOLD', res_tf, close)
growth_ratio = copper / gold

breakeven = request.security('FRED:T10YIE', res_tf, close)
real_yield = us10y - breakeven

// --- Z-Score Funktion ---
f_zscore(_src, _len) =>
    _avg = ta.sma(_src, _len)
    _std = ta.stdev(_src, _len)
    _result = _std != 0 ? (_src - _avg) / _std : 0
    _result

// --- Berechnung ---
z_curve = f_zscore(yield_curve, lookback)
z_credit = f_zscore(credit_ratio, lookback)
z_growth = f_zscore(growth_ratio, lookback)
z_real = f_zscore(real_yield, lookback)

// Berechnung mit den neuen variablen Gewichtungen
// Hinweis: Real Yield wird hier weiterhin invertiert (* -1), wie im Original
mlfi_raw = w_credit * z_credit + w_curve * z_curve + w_growth * z_growth + w_real * z_real * -1
mlfi_signal = ta.ema(mlfi_raw, smooth)

// --- Farb-Logik ---

// Prüfung: Ist das Signal im "Noise"-Bereich (zwischen -Noise und +Noise)?
is_noise = math.abs(mlfi_signal) <= noise_threshold

// 1. Farbe für die LINIE (Volle Deckkraft oder leichte Transparenz bei Extremen)
col_line = if is_noise
    color.gray // Grau im neutralen Bereich
else if mlfi_signal > 0
    mlfi_signal > 1.5 ? color.new(color.green, 0) : color.new(color.green, 0) // Grün (Risk On)
else
    mlfi_signal < -1.5 ? color.new(color.red, 0) : color.new(color.red, 0) // Rot (Risk Off)

// 2. Farbe für die FÜLLUNG (Höhere Transparenz)
col_fill = if is_noise
    color.new(color.gray, 60) // Grau, leicht transparent
else if mlfi_signal > 0
    color.new(color.green, 85) // Grün, sehr transparent
else
    color.new(color.red, 85) // Rot, sehr transparent

// --- Plotting ---

// Hauptlinie
p_signal = plot(mlfi_signal, 'Macro Liquidity Flow', color = col_line, linewidth = 2, style = plot.style_line)

// Nulllinie (Unsichtbar plotten für fill, sichtbar als hline)
p_zero = plot(0, display = display.none)

// Füllung zwischen Signal und Null
fill(p_signal, p_zero, color = col_fill, title = 'Regime Fill')

// --- Horizontale Linien ---
hline(0, 'Zero Line', color = color.gray, linestyle = hline.style_dotted)
hline(1.5, 'Extreme Risk-On', color = color.green, linestyle = hline.style_dashed)
hline(-1.5, 'Extreme Risk-Off', color = color.red, linestyle = hline.style_dashed)

// Dynamische Linien für den eingestellten Noise-Bereich
hline(noise_threshold, 'Noise Top', color = color.gray, linestyle = hline.style_dotted)
hline(-noise_threshold, 'Noise Bottom', color = color.gray, linestyle = hline.style_dotted)

// Neue einstellbare Schwellenwerte (z.B. 0.75 und -0.75)
// Wir nutzen 'plot', da hline keine variablen Inputs akzeptiert, oder wir nutzen hline mit festen Werten.
// Da du es "einstellbar" haben möchtest, nutzen wir hline in Kombination mit dem Input, 
// da Inputs in hline erlaubt sind, solange sie 'const' sind (was input.float ist).
hline(show_extra_thresh ? extra_thresh_val : na, 'Extra Top', color = color.new(color.gray, 50), linestyle = hline.style_dotted)
hline(show_extra_thresh ? -extra_thresh_val : na, 'Extra Bottom', color = color.new(color.gray, 50), linestyle = hline.style_dotted)
````
