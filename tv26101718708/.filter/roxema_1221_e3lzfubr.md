# Roxema 12/21

- url: https://www.tradingview.com/script/e3LzfubR/
- type: indicator
- pine_id: PUB;b6c5f568631946b0b5c621d83e19d76b
- version: 1.0

## Description

🇮🇹 ITALIANO
Roxema 12/21 — EMA Cross Multi-Timeframe

Indicatore semplice e pulito basato sull'incrocio di due medie mobili esponenziali — la EMA 12 (veloce) e la EMA 21 (lenta), uno degli strumenti più usati per leggere il trend.

• Segnale LONG quando la EMA 12 incrocia sopra la EMA 21
• Segnale di USCITA quando la 12 incrocia sotto la 21
• Sfondo verde in zona long, etichette BUY/SELL, alert pronti su entrata e uscita

Funzione Multi-Timeframe: lascia il timeframe vuoto (le EMA seguono il grafico) oppure fissale su un TF più alto (es. 4h, giornaliero) mentre guardi un grafico più piccolo. Modalità non-repaint attiva di default: usa la barra superiore chiusa, niente ridisegno.

Impostazioni: lunghezze EMA (default 12/21), timeframe EMA, non-repaint ON/OFF.

Come usarlo: è un filtro di trend, non un segnale automatico di acquisto. L'incrocio di medie rende meglio su timeframe alti e genera molti falsi segnali su quelli bassi.

⚠️ Strumento educativo, non consulenza finanziaria e non un sistema che garantisce guadagni. Fai sempre le tue verifiche.

———————————————

🇬🇧 ENGLISH
Roxema 12/21 — EMA Cross Multi-Timeframe

A simple, clean indicator based on the crossover of two exponential moving averages — the EMA 12 (fast) and the EMA 21 (slow), one of the most widely used tools to read the trend.

• LONG signal when the EMA 12 crosses above the EMA 21
• EXIT signal when the 12 crosses back below the 21
• Green background while in the long zone, BUY/SELL labels, ready-to-use alerts on entry and exit

Multi-Timeframe feature: leave the timeframe empty (the EMAs follow the chart) or lock them to a higher timeframe (e.g. 4h, daily) while you watch a lower one. Non-repaint mode is on by default: it uses the closed higher-timeframe bar, so no repainting.

Settings: EMA lengths (default 12/21), EMA timeframe, non-repaint ON/OFF.

How to use it: treat it as a trend filter, not an automatic buy signal. Moving-average crossovers work better on higher timeframes and produce many false signals on lower ones.

⚠️ Educational tool, not financial advice and not a system that guarantees profits. Always do your own research.

## Source Code

````pine
//@version=6
indicator("Roxema 12/21", shorttitle="Roxema 12/21", overlay=true)

// ----------------------- Input ---------------------------------------
fastLen = input.int(12, "EMA veloce", minval=1)
slowLen = input.int(21, "EMA lenta",  minval=1)
src     = input.source(close, "Sorgente")

// ----------------------- Timeframe (NUOVO) ---------------------------
// Vuoto = segue il timeframe del grafico (scorre coi TF).
// Impostato (es. "60", "240", "D") = fissa le EMA su quel TF (MTF).
tfInput  = input.timeframe("", "Timeframe EMA (vuoto = segue il grafico)", group="Timeframe")
nonRepaint = input.bool(true, "Non-repaint (usa barra HTF chiusa)", group="Timeframe",
     tooltip="ON = valori confermati, niente ridisegno (raccomandato). OFF = valore live del TF fisso, ma ridisegna.")
showInfo = input.bool(true, "Mostra TF attivo", group="Timeframe")

useChart = tfInput == "" or tfInput == timeframe.period

// ----------------------- Calcolo EMA (chart o MTF) -------------------
// Sul TF del grafico: calcolo nativo (nessun lag).
emaFastChart = ta.ema(src, fastLen)
emaSlowChart = ta.ema(src, slowLen)

// Su TF fisso: request.security non-repaint (barra precedente confermata in realtime).
f_sec(simple string tf, series float expr) =>
    request.security(syminfo.tickerid, tf,
         nonRepaint ? expr[barstate.isrealtime ? 1 : 0] : expr,
         lookahead = barmerge.lookahead_off)

tfUse   = useChart ? timeframe.period : tfInput
emaFast = useChart ? emaFastChart : f_sec(tfUse, ta.ema(src, fastLen))
emaSlow = useChart ? emaSlowChart : f_sec(tfUse, ta.ema(src, slowLen))

// ----------------------- Segnali -------------------------------------
longEntry = ta.crossover(emaFast, emaSlow)   // EMA12 incrocia sopra EMA21
longExit  = ta.crossunder(emaFast, emaSlow)  // EMA12 incrocia sotto  EMA21

var bool inLong = false
if longEntry
    inLong := true
if longExit
    inLong := false

// ----------------------- Grafica -------------------------------------
plot(emaFast, "EMA 12", color=color.new(color.aqua,   0), linewidth=2)
plot(emaSlow, "EMA 21", color=color.new(color.orange, 0), linewidth=2)
bgcolor(inLong ? color.new(color.green, 90) : na, title="Zona Long")

plotshape(longEntry, title="BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(longExit,  title="SELL", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,   0), text="SELL", textcolor=color.white, size=size.small)

// ----------------------- Info TF attivo ------------------------------
var table info = table.new(position.top_right, 1, 1)
if showInfo and barstate.islast
    string lbl = useChart ? "EMA su grafico (" + timeframe.period + ")" : "EMA fissa su " + tfInput
    table.cell(info, 0, 0, lbl, text_color=color.white,
         bgcolor=color.new(useChart ? color.gray : color.blue, 20), text_size=size.small)

// ----------------------- Alert ---------------------------------------
alertcondition(longEntry, title="Segnale LONG (entrata)", message="EMA12 ha incrociato AL RIALZO la EMA21 - ENTRATA LONG su {{ticker}} @ {{close}}")
alertcondition(longExit,  title="Segnale EXIT (uscita)",  message="EMA12 ha incrociato AL RIBASSO la EMA21 - USCITA su {{ticker}} @ {{close}}")
````
