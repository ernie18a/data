# SmartEdge RS [Entry & Exit]

- url: https://www.tradingview.com/script/0UII5wZt/
- type: indicator
- pine_id: PUB;22f194fadaba402c8519b1fec5e0b1a9
- version: 1.0

## Description

🇩🇪 Deutsch:

SmartEdge RS kombiniert Relative Stärke, Moving Averages (EMA 21/50), RSI und Volumen-Filter zu einem vollständigen Entry- & Exit-System. Grüne KAUF-Labels markieren günstige Einstiege, rote EXIT-Labels signalisieren den optimalen Ausstieg. Das integrierte Dashboard zeigt alle Metriken live auf einen Blick.


🇬🇧 English:

SmartEdge RS combines Relative Strength, Moving Averages (EMA 21/50), RSI and a Volume Filter into a complete entry & exit system. Green BUY labels mark favorable entries, red EXIT labels signal the optimal exit point. The built-in dashboard displays all metrics live at a glance.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════
//  SmartEdge RS [Entry & Exit]  │  Pine Script v5
//  Relative Strength + Smart Entry & Exit Signals
// ═══════════════════════════════════════════════════════════════
//@version=5
indicator("SmartEdge RS [Entry & Exit]", shorttitle="SmartEdge RS", overlay=true, max_bars_back=500)

// ───────────────────────────────────────────
// EINGABEN
// ───────────────────────────────────────────
grpRS   = "📊 Relative Stärke"
grpMA   = "📈 Moving Averages"
grpRSI  = "⚡ RSI Einstellungen"
grpFilt = "🔍 Filter"
grpVis  = "👁 Darstellung"

benchmarkSym  = input.symbol("SPY",  "Benchmark Symbol (z.B. SPY, QQQ, DAX)", group=grpRS)
rsLength      = input.int(10, "RS Glättungsperiode", minval=1, maxval=50, group=grpRS)
rsTrendLen    = input.int(5,  "RS Trendbestätigung (Bars)", minval=1, maxval=20, group=grpRS)

fastLen   = input.int(21, "Schnelle MA Periode", minval=1,  group=grpMA)
slowLen   = input.int(50, "Langsame MA Periode", minval=1,  group=grpMA)
maType    = input.string("EMA", "MA Typ", options=["EMA","SMA","WMA"], group=grpMA)

rsiLen        = input.int(14, "RSI Periode",        minval=2, maxval=50, group=grpRSI)
rsiOversold   = input.int(40, "Überverkauft Grenze", minval=1, maxval=49, group=grpRSI)
rsiOverbought = input.int(65, "Überkauft Grenze",    minval=51, maxval=99, group=grpRSI)

useVolFilter  = input.bool(true, "Volumen-Filter aktivieren", group=grpFilt)
volMult       = input.float(0.8, "Min. Volumen (× Ø)", minval=0.1, maxval=3.0, step=0.1, group=grpFilt)

showBgColor   = input.bool(true,  "Hintergrundfarbe (RS)", group=grpVis)
showDashboard = input.bool(true,  "Dashboard anzeigen",    group=grpVis)
showMARibbon  = input.bool(true,  "MA-Ribbon anzeigen",    group=grpVis)

// ───────────────────────────────────────────
// BERECHNUNGEN
// ───────────────────────────────────────────

// --- Moving Average Funktion ---
getMA(src, len, t) =>
    switch t
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        =>       ta.ema(src, len)

fastLine = getMA(close, fastLen, maType)
slowLine = getMA(close, slowLen, maType)

// --- RSI ---
rsiVal = ta.rsi(close, rsiLen)

// --- Relative Stärke (RS) vs. Benchmark ---
benchClose = request.security(benchmarkSym, timeframe.period, close)
rsRaw      = close / benchClose
rsLine     = ta.ema(rsRaw, rsLength)

// RS Trend: Steigt RS über mehrere Bars?
rsUp   = ta.rising(rsLine,  rsTrendLen)
rsDown = ta.falling(rsLine, rsTrendLen)
rsTrending = rsUp            // RS klar aufwärts
rsWeak     = rsDown          // RS klar abwärts
rsNeutral  = not rsUp and not rsDown

// --- Volumen-Filter ---
avgVol   = ta.sma(volume, 20)
volOk    = not useVolFilter or (volume >= avgVol * volMult)

// --- Trend-Zustand ---
bullTrend = fastLine > slowLine
bearTrend = fastLine < slowLine

// ───────────────────────────────────────────
// SIGNAL-LOGIK
// ───────────────────────────────────────────

// ✅ KAUF-Signal (Long Entry)
// Bedingungen: MA-Crossover + RS steigt + RSI nicht überkauft + Volumen ok
longEntry = ta.crossover(fastLine, slowLine) and
  rsTrending and
  rsiVal > rsiOversold and
  rsiVal < rsiOverbought and
  volOk

// 📌 ZUSATZ-EINSTIEG: Rücksetzer in Aufwärtstrend
// Kurs fällt kurz unter FastMA und kehrt zurück → günstige Nackkauf-Zone
bounceEntry = bullTrend and
  close > fastLine and
  close[1] < fastLine[1] and
  rsTrending and
  rsiVal < 58 and
  volOk

// ❌ AUSSTIEG Long
// MA-Crossunder ODER RS bricht ein UND RSI überhitzt
longExit = ta.crossunder(fastLine, slowLine) or
  (rsWeak and rsiVal > rsiOverbought)

// 🔴 SHORT-Signal (Short Entry) – nur für Short-fähige Instrumente
shortEntry = ta.crossunder(fastLine, slowLine) and
  rsWeak and
  rsiVal < (100 - rsiOversold) and
  volOk

// 🟢 SHORT-AUSSTIEG (Cover)
shortExit = ta.crossover(fastLine, slowLine) or rsTrending

// ───────────────────────────────────────────
// DARSTELLUNG – Moving Averages + Ribbon
// ───────────────────────────────────────────
fastColor = bullTrend ? color.new(#00C9FF, 0) : color.new(#FF5252, 0)

p1 = plot(fastLine, "Fast MA", color=fastColor, linewidth=2)
p2 = plot(slowLine, "Slow MA", color=color.new(#FFD700, 40), linewidth=2)

// Ribbon-Füllung zwischen den MAs (fill muss im globalen Scope stehen)
ribbonColor = showMARibbon ? (bullTrend ? color.new(#00C9FF, 90) : color.new(#FF5252, 90)) : na
fill(p1, p2, color=ribbonColor, title="MA Ribbon")

// ───────────────────────────────────────────
// HINTERGRUND-FARBE nach RS-Zustand
// ───────────────────────────────────────────
bgCol = rsTrending ? color.new(color.green, 95) : rsWeak ? color.new(color.red, 95) : color.new(color.gray, 98)

bgcolor(showBgColor ? bgCol : na, title="RS Hintergrund")

// ───────────────────────────────────────────
// SIGNAL-SYMBOLE IM CHART
// ───────────────────────────────────────────

// 🟢 KAUF
plotshape(longEntry,
  title    = "KAUF Signal",
  style    = shape.labelup,
  location = location.belowbar,
  color    = #00FF88,
  size     = size.normal,
  text     = "KAUF",
  textcolor = color.black)

// 📌 Rücksetzer-Einstieg
plotshape(bounceEntry and not longEntry,
  title    = "Rücksetzer-Einstieg",
  style    = shape.triangleup,
  location = location.belowbar,
  color    = color.new(#00BFFF, 0),
  size     = size.small)

// 🔴 AUSSTIEG Long
plotshape(longExit,
  title    = "AUSSTIEG",
  style    = shape.labeldown,
  location = location.abovebar,
  color    = #FF4444,
  size     = size.normal,
  text     = "EXIT",
  textcolor = color.white)

// ⬇ SHORT
plotshape(shortEntry,
  title    = "SHORT Signal",
  style    = shape.labeldown,
  location = location.abovebar,
  color    = #FF8800,
  size     = size.small,
  text     = "SHORT",
  textcolor = color.white)

// ⬆ SHORT COVER
plotshape(shortExit and not longEntry,
  title    = "Short Ausstieg",
  style    = shape.triangleup,
  location = location.belowbar,
  color    = color.new(#AAFFCC, 0),
  size     = size.tiny)

// ───────────────────────────────────────────
// DASHBOARD (oben rechts)
// ───────────────────────────────────────────
var table dash = table.new(
  position     = position.top_right,
  columns      = 2,
  rows         = 6,
  bgcolor      = color.new(#0d0d1a, 5),
  border_width = 1,
  border_color = color.new(#2a2a4a, 40),
  frame_width  = 1,
  frame_color  = color.new(#00C9FF, 60))

headerBg = color.new(#16213e, 0)

if showDashboard and barstate.islast

    // Header
    table.cell(dash, 0, 0, "📊 INDIKATOR",
      text_color = #7cb9e8, text_size = size.small,
      bgcolor = headerBg, text_halign = text.align_left)
    table.cell(dash, 1, 0, "STATUS",
      text_color = #7cb9e8, text_size = size.small,
      bgcolor = headerBg)

    // Relative Stärke
    rsStatus = rsTrending ? "▲ STARK" : rsWeak ? "▼ SCHWACH" : "► NEUTRAL"
    rsColor  = rsTrending ? #00FF88   : rsWeak  ? #FF4444    : #AAAAAA
    table.cell(dash, 0, 1, "Rel. Stärke",
      text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, rsStatus,
      text_color = rsColor, text_size = size.small)

    // MA Trend
    maStatus = bullTrend ? "▲ AUFWÄRTS" : "▼ ABWÄRTS"
    maColor  = bullTrend ? #00FF88 : #FF4444
    table.cell(dash, 0, 2, "MA Trend",
      text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, maStatus,
      text_color = maColor, text_size = size.small)

    // RSI
    rsiStr   = str.tostring(math.round(rsiVal))
    rsiLabel = rsiVal > rsiOverbought ? "ÜBERKAUFT " + rsiStr : rsiVal < rsiOversold ? "ÜBERVERKAUFT " + rsiStr : "NEUTRAL " + rsiStr
    rsiCol   = rsiVal > rsiOverbought ? #FF4444 : rsiVal < rsiOversold ? #00FF88 : color.white
    table.cell(dash, 0, 3, "RSI (" + str.tostring(rsiLen) + ")",
      text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, rsiLabel,
      text_color = rsiCol, text_size = size.small)

    // Volumen
    volRatio  = math.round(volume / avgVol * 100)
    volLabel  = str.tostring(volRatio) + "% Ø"
    volCol    = volume > avgVol ? #00FF88 : #AAAAAA
    table.cell(dash, 0, 4, "Volumen",
      text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, volLabel,
      text_color = volCol, text_size = size.small)

    // Gesamt-Setup
    setupLong  = rsTrending and bullTrend and rsiVal < rsiOverbought
    setupShort = rsWeak and bearTrend and rsiVal > (100 - rsiOverbought)
    setupLabel = setupLong ? "✓ LONG SETUP" : setupShort ? "✓ SHORT SETUP" : "◌ WARTEN"
    setupColor = setupLong ? #00FF88 : setupShort ? #FF8800 : #888888
    table.cell(dash, 0, 5, "Setup",
      text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, setupLabel,
      text_color = setupColor, text_size = size.small)

// ───────────────────────────────────────────
// ALERT-BEDINGUNGEN
// ───────────────────────────────────────────
alertcondition(longEntry,   "🟢 Kaufsignal",        "RS+Signal: Kauf-Einstieg! MA-Crossover + RS stark")
alertcondition(bounceEntry, "📌 Rücksetzer-Einstieg","RS+Signal: Günstiger Rücksetzer im Aufwärtstrend")
alertcondition(longExit,    "🔴 Ausstieg Long",      "RS+Signal: Ausstieg! MA-Crossunder oder RS schwach")
alertcondition(shortEntry,  "⬇ Short-Signal",       "RS+Signal: Short-Einstieg erkannt")
alertcondition(shortExit,   "⬆ Short-Ausstieg",     "RS+Signal: Short-Position schließen")
````
