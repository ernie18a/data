# Latencia Public [L1]

- url: https://www.tradingview.com/script/UD1N59l8-Latencia-Public-L1/
- type: indicator
- pine_id: PUB;9f5ace4e11104010bf31652c8b57b631
- version: 1.0

## Description

[b]Latencia Public [L1][/b] · a minimal visual layer for reading the latency between cause and effect on any market.

[b]What it does[/b]

Three context EMAs · 20, 50, 200 · over the candles. A subtle backdrop that marks high vs low volatility regime using ATR percentiles. A discreet Latencia mark in the lower-right corner.

The point is not the formula · it's the reading. EMAs ordered and well-separated speak to a trend with room. Compressed EMAs speak to indecision. The terracotta wash marks that conditional variance rose · the forest-green wash marks that the market is sleeping. When the regime changes, price reacts after.

[b]How to use it[/b]

[list]
[*] Drop it on any symbol · works the same on BTC, on LATAM pairs, on commodities. The volatility regime is asset-agnostic.
[*] Timeframe · daily for macro · weekly for cycle · 4h for timing.
[*] Combine with your own structure · this is context, not a signal.
[/list]

[b]Foundations[/b]

[list]
[*] EMAs · Wilder 1978, popularized by Murphy 1999 as the standard adaptive moving averages.
[*] ATR · Wilder 1978. Realized volatility is the base of any serious regime read.
[*] Conditional regime · narrative economics (Shiller 2017) · the variance of narratives precedes the variance of price.
[/list]

[b]When NOT to use it[/b]

[list]
[*] Ultra-illiquid markets · ATR percentiles are noise.
[*] The first 200 bars of any symbol · EMA 200 has no history to stabilize.
[*] Structural-break events · no regime detector works through discontinuities.
[/list]

[b]Latencia[/b] teaches frameworks institutional money uses to read markets, translated to LATAM Spanish. This is educational. NFA · DYOR.

[hr]

[b]En español[/b]

[b]Latencia Public [L1][/b] · una capa visual mínima para leer la latencia entre causa y efecto en cualquier mercado.

Tres EMAs de contexto · 20, 50, 200 · sobre las velas. Un fondo sutil que marca régimen de volatilidad alta vs baja usando ATR percentiles. Marca discreta de Latencia en esquina inferior derecha.

Lo importante no es la fórmula · es la lectura. Las EMAs ordenadas y separadas hablan de tendencia con margen. Las EMAs comprimidas hablan de indecisión. El fondo terracota marca que la varianza condicional subió · el verde forestal marca que el mercado está dormido. Cuando el régimen cambia, el precio reacciona después.

Cargar sobre cualquier símbolo · funciona igual en BTC, en pares LATAM, en commodities. Marco temporal · diario para macro · semanal para ciclo · 4h para timing. Combinar con tu propia estructura · esto es contexto, no señal.

Latencia enseña marcos que el dinero institucional usa para leer mercados, traducidos al español de LATAM. Esto es educativo. NFA · esto no es consejo financiero · DYOR.

## Source Code

````pine
//@version=6
// Latencia Public [L1]
// Brand chart layer for @latencia_es educational publications.
// Palette tuned for default TV light theme · earth tones that read on white bg.
// Educational only · NFA, DYOR.

indicator("Latencia Public [L1]", overlay=true, max_lines_count=20, max_labels_count=20)

// ─────────────────────────────────────────────────────────────
// Palette · alta montaña LATAM, earth tones tuned for light bg
// ─────────────────────────────────────────────────────────────
COL_EMA_20    = color.new(#6B5D54, 25)    // warm taupe · short-term context
COL_EMA_50    = color.new(#B8924C, 15)    // andean gold · medium-term anchor
COL_EMA_200   = color.new(#8C3A2A, 10)    // volcano red · long-term trend
COL_VOL_LOW   = color.new(#4A8060, 94)    // soft forest green wash · low-vol regime
COL_VOL_HIGH  = color.new(#B57860, 94)    // terracotta wash · high-vol regime
COL_MARK_TXT  = color.new(#4A3D34, 15)    // warm dark grey · brand mark text
COL_MARK_BG   = color.new(#F5F0E6, 35)    // cream pill · subtle on light bg

// ─────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────
show_emas    = input.bool(true,  "EMAs 20 · 50 · 200",                group="Context")
show_vol_bg  = input.bool(true,  "Volatility-regime backdrop",        group="Context")
vol_lookback = input.int(100,    "Vol-regime lookback (bars)",        minval=30, maxval=500, group="Context")
show_brand   = input.bool(true,  "Latencia mark (bottom-right)",      group="Brand")

// ─────────────────────────────────────────────────────────────
// EMAs · 20 / 50 / 200 over the candles
// ─────────────────────────────────────────────────────────────
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
plot(show_emas ? ema20  : na, title="EMA 20",  color=COL_EMA_20,  linewidth=1)
plot(show_emas ? ema50  : na, title="EMA 50",  color=COL_EMA_50,  linewidth=2)
plot(show_emas ? ema200 : na, title="EMA 200", color=COL_EMA_200, linewidth=2)

// ─────────────────────────────────────────────────────────────
// Volatility regime backdrop · ATR percentile bands
// Subtle wash · low-vol greenish, high-vol terracotta
// ─────────────────────────────────────────────────────────────
atr14    = ta.atr(14)
atr_pct  = atr14 / close * 100
p_low    = ta.percentile_linear_interpolation(atr_pct, vol_lookback, 33)
p_high   = ta.percentile_linear_interpolation(atr_pct, vol_lookback, 66)
vol_low  = atr_pct < p_low
vol_high = atr_pct > p_high
bgcolor(show_vol_bg and vol_low  ? COL_VOL_LOW  : na, title="Vol regime · low")
bgcolor(show_vol_bg and vol_high ? COL_VOL_HIGH : na, title="Vol regime · high")

// ─────────────────────────────────────────────────────────────
// Latencia mark · bottom-right corner via table cell
// ─────────────────────────────────────────────────────────────
var table mark = table.new(position=position.bottom_right, columns=1, rows=1, bgcolor=COL_MARK_BG, border_width=0)
if show_brand and barstate.islast
    table.cell(mark, 0, 0, "  Latencia  ", text_color=COL_MARK_TXT, text_size=size.small)
````
