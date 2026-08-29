<!-- tradingview-pine-id: PUB;9eb52dbe4be34b378947ca93aa4c95b5 -->
<!-- tradingviewscripts-format: 1 -->
# Keep It Simple

Source: https://www.tradingview.com/script/nP5fBSfa/

## Description

**Keep It Simple — dominant market force in one glance**

The main goal of this indicator is to show which force is dominant on each candle, through a colored EMA cloud and an intuitive color code. The Bollinger Bands help you read whether volatility is expanding or contracting, and the thickness of the short moving-average line tells you whether a trend exists and whether it is gaining force or not.

A simplified read of structure and direction in a single overlay:

- **Bollinger Bands** (length 21 · deviation 1.3 · EMA basis) with a blue cloud between them — the price "territory". Band lines can stay hidden; the cloud alone keeps the read clean.
- **Short EMA (8)** — the direction line; its thickness increases as the trend gains force (thickness driven by ADX plus a short range index, and only while that force is rising).
- **Long EMA (21)** — hidden by default (toggle-able); it always feeds the state color.
- **Cloud between the EMAs**, painted in the color of the current market state.

**How to read the colors (market state · EMAs and cloud):**

- Green — full up (price above EMA 8 · EMA 8 above EMA 21)
- Blue — pullback in an uptrend (price below EMA 8 · EMA 8 above EMA 21)
- Gray — neutral / transition
- Purple — pullback in a downtrend (price above EMA 8 · EMA 8 below EMA 21)
- Red — full down (price below EMA 8 · EMA 8 below EMA 21)

**Why combine these three?** Bands alone tell you *where* price is working; a plain moving average tells you *which way*; neither tells you *how strong* or *what regime*. Here they are wired together: the bands/cloud give the territory and its volatility, the thick colored short EMA gives direction plus strength in one line, and the shared state color ties price, short EMA and long EMA into a single regime read — so one glance answers where price is, which way it leans, and how strong that lean is.

Open-source and fully commented, so you can see exactly how each part is computed and adapt it.

Success to all,
Fabio Maistro

---

## Source Code

````pine
//@version=6
// © Fabio Maistro
//
// Keep It Simple — compact structure + direction reader
// -----------------------------------------------------------------
// Three ideas on one overlay, made to work together:
//   1) Bollinger Bands as the price "territory" (optional blue cloud
//      between the bands; band lines can stay hidden).
//   2) A short EMA as the direction line — it gets THICKER as the
//      trend gains strength (thickness driven by ADX + a range index).
//   3) A market-state color shared by the EMAs and their cloud, read
//      from price vs short EMA vs long EMA (5 states).
//
// HOW TO READ THE COLORS (market state · EMAs and their cloud):
//   Green  -> full up   (price > short EMA · short EMA > long EMA)
//   Blue   -> pullback in an uptrend (price < short EMA · short > long)
//   Gray   -> neutral / transition
//   Purple -> pullback in a downtrend (price > short EMA · short < long)
//   Red    -> full down (price < short EMA · short EMA < long EMA)
//
// WHY THE MASHUP: bands give the territory, the colored short EMA gives
// direction + strength in one line, and the state color ties price,
// short EMA and long EMA into a single at-a-glance read — so the same
// overlay answers "where is price working" and "which way, how strong".
//
// Note: ta.dmi returns a tuple; diP/diM are a required by-product of
// adxV (not dead code).
// -----------------------------------------------------------------
indicator("Keep It Simple", shorttitle = "Keep It Simple", overlay = true)

// ===== Bollinger Bands (structure) ==============================
grpBB = "Bollinger Bands (structure)"
periodoBB   = input.int(21, "Bands length", minval = 2, tooltip = "Fibonacci scale", group = grpBB, display = display.none)
desvioBB    = input.float(1.3, "Bands deviation", minval = 0.1, step = 0.1, group = grpBB, display = display.none)
tipoMediaBB = input.int(1, "Bands MA type", minval = 0, maxval = 3, tooltip = "0=SMA | 1=EMA | 2=RMA (Wilder) | 3=WMA", group = grpBB, display = display.none)
plotarBandas = input.bool(false, "Plot band lines", tooltip = "Hidden by default; calculation stays active (the lines anchor the cloud)", group = grpBB, display = display.none)
mostrarNuvem = input.bool(true, "Cloud between bands", group = grpBB, display = display.none)
transpNuvem  = input.int(65, "Bands cloud transparency (0-100)", minval = 0, maxval = 100, group = grpBB, display = display.none)

// ===== Long EMA (context) =======================================
grpLonga = "Long EMA (context)"
periodoMMELonga = input.int(21, "Long EMA length", minval = 1, tooltip = "Fibonacci scale", group = grpLonga, display = display.none)
plotarMMELonga  = input.bool(false, "Plot long EMA", tooltip = "Hidden by default; calculation stays active (feeds the state color)", group = grpLonga, display = display.none)

// ===== Short EMA (direction) ====================================
grpCurta = "Short EMA (direction)"
periodoMMECurta = input.int(8, "Short EMA length", minval = 1, tooltip = "Fibonacci scale", group = grpCurta, display = display.none)
plotarMMECurta  = input.bool(true, "Plot short EMA", tooltip = "The direction line; thickness grows with trend strength", group = grpCurta, display = display.none)

// ===== Cloud between EMAs =======================================
grpNuvem = "Cloud between EMAs"
mostrarNuvemMME = input.bool(true, "Cloud between EMAs", group = grpNuvem, display = display.none)
transpNuvemMME  = input.int(80, "EMAs cloud transparency (0-100)", minval = 0, maxval = 100, group = grpNuvem, display = display.none)

// ===== Colors ===================================================
CINZAGRID       = color.rgb(55, 60, 80, 85)
AZUL_NUVEM_BOLL = color.rgb(20, 35, 70, 75)
VERDE_ALTA      = color.rgb(10, 255, 10)
VERMELHO_QUEDA  = color.rgb(255, 10, 10)
AZUL_PB         = color.rgb(30, 95, 135)
ROXO_PB         = color.rgb(130, 50, 150)
INVISIVEL       = color.new(color.white, 100)

// ===== Calculations =============================================
mediaBB = tipoMediaBB == 0 ? ta.sma(close, periodoBB) :
      tipoMediaBB == 1 ? ta.ema(close, periodoBB) :
      tipoMediaBB == 2 ? ta.rma(close, periodoBB) :
      ta.wma(close, periodoBB)
desvPad     = ta.stdev(close, periodoBB)
bbSuperior  = mediaBB + desvioBB * desvPad
bbInferior  = mediaBB - desvioBB * desvPad
mmeLonga    = ta.ema(close, periodoMMELonga)
mmeCurta    = ta.ema(close, periodoMMECurta)

// Trend strength (drives the short EMA thickness)
[diP, diM, adxV] = ta.dmi(13, 13)
variacao = 100 * math.abs(ta.sma(close, 5) - ta.sma(close, 13)) / ta.sma(close, 13)
forca = bar_index >= 13 ? adxV + variacao : 0.0
espessura = forca > forca[1] ? (forca > 30 ? 5 : forca > 25 ? 4 : forca > 20 ? 3 : forca > 15 ? 2 : 1) : 1

// Market state (colors the EMAs and the cloud between them)
corEstado = close > mmeCurta and mmeCurta > mmeLonga ? VERDE_ALTA :
      close < mmeCurta and mmeCurta > mmeLonga ? AZUL_PB :
      close > mmeCurta and mmeCurta < mmeLonga ? ROXO_PB :
      close < mmeCurta and mmeCurta < mmeLonga ? VERMELHO_QUEDA :
      CINZAGRID

// ===== Plots ====================================================
// The band lines stay plotted even when hidden: they anchor the cloud fill.
pBBSup = plot(bbSuperior, "BB Upper", plotarBandas ? CINZAGRID : INVISIVEL, 1, plot.style_linebr, display = display.pane)
pBBInf = plot(bbInferior, "BB Lower", plotarBandas ? CINZAGRID : INVISIVEL, 1, plot.style_linebr, display = display.pane)
fill(pBBSup, pBBInf, mostrarNuvem ? color.new(AZUL_NUVEM_BOLL, transpNuvem) : na, "Bands cloud")
plot(plotarMMELonga ? mmeLonga : na, "Long EMA", corEstado, 1, plot.style_linebr, display = display.pane)

// Short EMA with variable thickness
sCurta(k) => plotarMMECurta and (espessura == k or espessura[1] == k) ? mmeCurta : na
plot(sCurta(1), "Short EMA w1", corEstado, 1, plot.style_linebr, display = display.pane)
plot(sCurta(2), "Short EMA w2", corEstado, 2, plot.style_linebr, display = display.pane)
plot(sCurta(3), "Short EMA w3", corEstado, 3, plot.style_linebr, display = display.pane)
plot(sCurta(4), "Short EMA w4", corEstado, 4, plot.style_linebr, display = display.pane)
plot(sCurta(5), "Short EMA w5", corEstado, 5, plot.style_linebr, display = display.pane)

// ===== Cloud between EMAs =======================================
pGuiaCurta = plot(mmeCurta, "short EMA guide", INVISIVEL, 1, plot.style_linebr, display = display.pane, editable = false)
pGuiaLonga = plot(mmeLonga, "long EMA guide",  INVISIVEL, 1, plot.style_linebr, display = display.pane, editable = false)
fill(pGuiaCurta, pGuiaLonga, mostrarNuvemMME ? color.new(corEstado, transpNuvemMME) : na, "EMAs cloud")
````
