# Wick Asymmetry Ratio (WAR)

- url: https://www.tradingview.com/script/JZttAx4x/
- type: indicator
- pine_id: PUB;d7d8242669234f7c9919966236debd9c
- version: 1.0

## Description

[b]Wick Asymmetry Ratio (WAR)[/b]

WAR is a bounded oscillator (−1 to +1) that measures which candle wick dominates — in other words, [b]where price was rejected[/b].

[b]How it's calculated[/b]
[pine]
upper = high − max(open, close)
lower = min(open, close) − low
WAR   = (lower − upper) / (high − low + ε)
[/pine]

Most wick tools compare each wick against the body. WAR instead [b]subtracts[/b] the two wicks and normalizes by the full bar range. Two consequences: it never breaks on doji candles (zero body, no division blow-up), and it produces a single symmetric value comparable across symbols and timeframes.

[b]How to read it[/b]
[list]
[*][b]WAR > 0[/b] → lower wick dominates → buyers defended the low (bullish rejection)
[*][b]WAR < 0[/b] → upper wick dominates → sellers capped the high (bearish rejection)
[*][b]WAR ≈ 0[/b] → clean body or symmetric wicks → no clear rejection
[/list]

[b]The signal filter — this is the point[/b]
A single strong wick means little in the middle of a range. WAR only marks a signal when a strong rejection coincides with the bar being the highest/lowest of the lookback window, plus a cooldown to prevent clusters. This is what separates it from "an arrow on every wick".

[b]Visual layers[/b]
[list]
[*]Colored histogram (sign + strength)
[*]Optional price-overlay pressure ribbon that shifts green↔red — read pressure without numbers
[*]Signal dots with a halo at filtered extremes
[*]Subtle background aura in strong zones
[/list]

[b]Limitations — read this[/b]
WAR is a [b]context / exhaustion[/b] tool, not a standalone entry trigger. It tells you who absorbed price on a given bar; it does not predict direction by itself. Use it as confluence with structure, support/resistance, or your own system. On sub-cent assets raise ε. The signal fires on bar close at the threshold cross.

[quote]Open-source. Wick analysis is a well-known concept; what's specific here is the subtractive, range-normalized oscillator plus the extreme + cooldown filter and the price-overlay ribbon. Feedback and forks welcome.[/quote]

[b]— Español —[/b]

WAR es un oscilador acotado (−1 a +1) que mide qué mecha de la vela domina, es decir, [b]dónde fue rechazado el precio[/b]. A diferencia de los ratios mecha/cuerpo, WAR resta ambas mechas y normaliza por el rango total: no se rompe en doji y da un valor simétrico comparable entre activos y temporalidades.

[list]
[*][b]WAR > 0[/b] → mecha inferior domina → rechazo comprador
[*][b]WAR < 0[/b] → mecha superior domina → rechazo vendedor
[*][b]WAR ≈ 0[/b] → cuerpo limpio o mechas simétricas → sin rechazo claro
[/list]

El filtro solo marca señal cuando un rechazo fuerte coincide con un extremo de la ventana, con cooldown para evitar racimos. Es una herramienta de [b]contexto / agotamiento[/b], no un gatillo de entrada por sí sola — úsala como confluencia. Toda la interfaz en inglés está traducida en esta descripción.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PoPey

//@version=6
indicator("Wick Asymmetry Ratio (WAR)", shorttitle="WAR", overlay=false, precision=3)

// ═══════════════════════════════════════════════════════════════════════════
//  WICK ASYMMETRY RATIO (WAR)
//  ---------------------------------------------------------------------------
//  A bounded (-1..+1) oscillator measuring which wick of a candle dominates,
//  i.e. where price was rejected. Unlike wick-to-body ratios, WAR subtracts
//  the two wicks and normalizes by the full bar range, so it never breaks on
//  doji candles (zero body) and stays symmetric and comparable across symbols
//  and timeframes.
//
//  CORE FORMULA
//    upper = high - max(open, close)     // upper wick length
//    lower = min(open, close) - low      // lower wick length
//    WAR   = (lower - upper) / (high - low + eps)
//
//  READING
//    WAR > 0  -> lower wick dominates -> buyers defended the low  (bullish rejection)
//    WAR < 0  -> upper wick dominates -> sellers capped the high  (bearish rejection)
//    WAR ~ 0  -> clean body or symmetric wicks -> no clear rejection
//
//  WAR is a CONTEXT / EXHAUSTION filter, not a standalone entry trigger.
//  A strong reading only matters at a swing extreme. The signal layer below
//  fires a mark only when a strong wick rejection coincides with the bar being
//  the highest/lowest of the lookback window, with a cooldown to avoid clusters.
//
//  NOTE: Wick analysis is a well-known concept. What is specific here is the
//  subtractive, range-normalized oscillator plus the extreme + cooldown filter
//  and the price-overlay pressure ribbon.
// ═══════════════════════════════════════════════════════════════════════════

// ─── Inputs / Entradas ─────────────────────────────────────
grpC   = "Calculation"
eps    = input.float(1e-9, "Epsilon (ε)", minval=0.0, step=1e-9, group=grpC, tooltip="Avoids division by zero on perfect doji. For sub-cent assets raise it or use mintick.\n[ES] Evita división por cero en doji. En activos sub-céntimo, súbelo o usa mintick.")
smooth = input.bool(false, "Smooth WAR", group=grpC, tooltip="Off = raw formula (default). On = EMA of WAR.\n[ES] Off = fórmula cruda. On = EMA del WAR.")
len    = input.int(5, "Smoothing length", minval=1, group=grpC)

grpS   = "Signals"
thr    = input.float(0.45, "Strength threshold", minval=0.0, maxval=1.0, step=0.05, group=grpS, tooltip="How much one wick must dominate. Higher = fewer signals.\n[ES] Cuánto debe dominar una mecha. Más alto = menos señales.")
look   = input.int(10, "Extreme window", minval=2, group=grpS, tooltip="Bar must be highest/lowest of N bars to validate the rejection.\n[ES] La vela debe ser el máx/mín de N velas para validar el rechazo.")
cool   = input.int(5,  "Cooldown (bars)", minval=0, group=grpS, tooltip="Bars to wait after a signal before allowing another.\n[ES] Velas a esperar tras una señal antes de permitir otra.")

grpV   = "Visual"
showRibbon = input.bool(true, "Pressure ribbon (price)", group=grpV, tooltip="[ES] Cinta de presión sobre el precio.")
ribLen     = input.int(8, "Ribbon smoothing", minval=1, group=grpV)
showAura   = input.bool(true, "Background aura (panel)", group=grpV, tooltip="[ES] Aura de fondo en el panel, solo en zona fuerte.")
showDots   = input.bool(true, "Signal dots (price)", group=grpV, tooltip="[ES] Puntos de señal sobre el precio.")
glow       = input.bool(true, "Halo on dots", group=grpV, tooltip="[ES] Halo en los puntos.")

// ─── Calculation / Cálculo ─────────────────────────────────
upper = high - math.max(open, close)
lower = math.min(open, close) - low
rng   = high - low + eps

warRaw = (lower - upper) / rng
war    = smooth ? ta.ema(warRaw, len) : warRaw

// ─── Palette / Paleta ──────────────────────────────────────
cBull = #26a69a
cBear = #ef5350
cZero = color.new(#787b86, 60)

// Continuous color by sign + strength / Color continuo por signo y fuerza
warColor(v, baseTransp) =>
    inten = math.min(math.abs(v) / thr, 1.0)
    v >= 0 ? color.from_gradient(inten, 0, 1, color.new(cBull, baseTransp), cBull)
           : color.from_gradient(inten, 0, 1, color.new(cBear, baseTransp), cBear)

// ─── Panel: histogram + line / histograma + línea ──────────
barCol = warColor(war, 70)
plot(war, "WAR", color=barCol, style=plot.style_columns, histbase=0)
plot(war, "WAR line", color=color.new(barCol, 25), linewidth=1)

hline(0, "Zero", color=cZero, linewidth=1)
hline(thr,  "Threshold +", color=color.new(cBull, 55), linestyle=hline.style_dashed)
hline(-thr, "Threshold −", color=color.new(cBear, 55), linestyle=hline.style_dashed)

// Aura: tints the panel only in strong zone, not on every bar
// [ES] Tiñe el panel solo en zona fuerte, no en cada vela
auraCol = war > thr ? color.new(cBull, 88) : war < -thr ? color.new(cBear, 88) : na
bgcolor(showAura ? auraCol : na, title="Pressure aura")

// ─── Pressure ribbon on price / Cinta de presión ───────────
warEMA = ta.ema(war, ribLen)
basis  = ta.ema(hlc3, ribLen)
ribCol = warColor(warEMA, 0)

plot(showRibbon ? basis : na, "Ribbon", color=ribCol, linewidth=2, force_overlay=true)
band = ta.atr(ribLen) * 0.5
pu = plot(showRibbon ? basis + band : na, "", color=na, force_overlay=true)
pd = plot(showRibbon ? basis - band : na, "", color=na, force_overlay=true)
fill(pu, pd, color=showRibbon ? warColor(warEMA, 88) : na, title="Ribbon halo")

// ─── Filtered signals (extreme rejection + cooldown) ───────
// [ES] Señales filtradas (rechazo en extremo + cooldown)
extLow  = low  <= ta.lowest(low,  look)
extHigh = high >= ta.highest(high, look)
sigUp = war >  thr and extLow
sigDn = war < -thr and extHigh

var int lastSig = na
ready = na(lastSig) or (bar_index - lastSig) > cool
buy  = sigUp and ready
sell = sigDn and ready
if buy or sell
    lastSig := bar_index

// ─── Dots with halo / Puntos con halo ──────────────────────
plotshape(showDots and glow and buy  ? low  : na, "Buy halo",  shape.circle, location.belowbar, color.new(cBull, 65), size=size.normal, force_overlay=true)
plotshape(showDots and glow and sell ? high : na, "Sell halo", shape.circle, location.abovebar, color.new(cBear, 65), size=size.normal, force_overlay=true)
plotshape(showDots and buy  ? low  : na, "Buy",  shape.circle, location.belowbar, cBull, size=size.tiny, force_overlay=true)
plotshape(showDots and sell ? high : na, "Sell", shape.circle, location.abovebar, cBear, size=size.tiny, force_overlay=true)

// Discrete panel marks / Marcas discretas en el panel
plotshape(buy  ? war : na, "", shape.diamond, location.absolute, cBull, size=size.tiny)
plotshape(sell ? war : na, "", shape.diamond, location.absolute, cBear, size=size.tiny)

// ─── Alerts / Alertas ──────────────────────────────────────
alertcondition(buy,  "WAR Buy",  "WAR: buyer absorption at low / absorción compradora en mínimo")
alertcondition(sell, "WAR Sell", "WAR: seller absorption at high / absorción vendedora en máximo")
````
