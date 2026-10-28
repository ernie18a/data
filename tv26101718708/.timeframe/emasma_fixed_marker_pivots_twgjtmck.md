# EMA/SMA + Fixed Marker Pivots

- url: https://www.tradingview.com/script/TwgjTMck/
- type: indicator
- pine_id: PUB;b344e2fb6e934d5186600f2fed1683f9
- version: 1.0

## Description

Trend Table — EMA/SMA + Fixed Marker Pivots
Multi-Timeframe Trend-Übersicht für saubere Top-Down-Analyse. Zeigt auf einen Blick, in welchem Trendzustand sich ein Asset auf 15m, 1H, 4H, 1D und 1W befindet — direkt am Chart, ohne Timeframe-Wechsel.
Was er macht
Der Indikator kombiniert zwei visuelle Elemente:
1. Trend-Tabelle (rechts oben)
Bewertet jeden Timeframe als UPTREND, DOWNTREND oder SIDEWAYS anhand der Position des Preises zu EMA20 und SMA50.
2. Fixed Trend Marker (Pivots am Chart)
Markiert Swing Highs (rote Punkte) und Swing Lows (grüne Punkte) mit einstellbarer Pivot Length. Dient als visuelle Marktstruktur-Hilfe — zählt aber nicht in die Tabellen-Bewertung.
Zusätzlich werden EMA20 (grün) und SMA50 (rot) auf dem aktuellen Chart geplottet.
Trend-Logik
Die Tabelle nutzt die relative Position der beiden Moving Averages zum Preis:

Uptrend: Beide MAs unter den Kerzen UND EMA20 näher am Preis als SMA50
Downtrend: Beide MAs über den Kerzen UND EMA20 näher am Preis als SMA50
Sideways: Alles dazwischen — z. B. wenn der Preis zwischen den MAs liegt oder die langsame SMA näher am Preis ist als die schnelle EMA (typisch bei Trendwechseln und Konsolidierungen)

Die Sideways-Bedingung ist bewusst streng: Sie filtert die unklaren Phasen raus, in denen die MAs gerade kreuzen oder der Preis seitwärts läuft.
Einstellungen

EMA-Länge (Default 20) und SMA-Länge (Default 50)
Pivot Length für die Swing-Punkte (Default 5)
MAs, Pivot-Punkte und Tabelle einzeln ein-/ausblendbar
Tabellenposition (6 Optionen) und Größe (tiny bis large)

Anwendung
Klassisch für Top-Down-Workflow: Höhere Timeframes geben die Richtung vor, niedrigere das Timing. Wenn 1D und 4H beide UPTREND zeigen, sucht man auf 15m/1H Long-Setups. Bei Mismatch (z. B. 1W Uptrend, 1D Sideways) heißt es: abwarten oder kleinere Position. Die Pivot-Punkte am Chart helfen dir parallel dazu, die tatsächliche Marktstruktur (Higher Highs/Lower Lows) im Auge zu behalten — unabhängig von der MA-basierten Tabellen-Bewertung.

## Source Code

````pine
//@version=5
indicator("EMA/SMA + Fixed Marker Pivots", overlay=true, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
grpMA   = "Moving Averages"
emaLen  = input.int(20, "EMA Länge", minval=1, group=grpMA)
smaLen  = input.int(50, "SMA Länge", minval=1, group=grpMA)
showMA  = input.bool(true, "MAs anzeigen", group=grpMA)

grpPiv  = "Fixed Trend Marker"
pivLen  = input.int(5, "Pivot Length", minval=1, group=grpPiv)
showPiv = input.bool(true, "Pivot Punkte anzeigen", group=grpPiv)

grpTbl  = "Tabelle"
showTbl = input.bool(true, "Tabelle anzeigen", group=grpTbl)
tblPos  = input.string("top_right", "Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=grpTbl)
tblSize = input.string("normal", "Größe", options=["tiny","small","normal","large"], group=grpTbl)

// ============================================================
// EMA/SMA POSITIONSLOGIK
// ============================================================
f_method2(float c, float ema, float sma) =>
    bothBelow = c > ema and c > sma
    bothAbove = c < ema and c < sma

    string res = "SIDEWAYS"
    if bothBelow
        res := ema > sma ? "UPTREND" : "SIDEWAYS"
    else if bothAbove
        res := ema < sma ? "DOWNTREND" : "SIDEWAYS"
    else
        res := "SIDEWAYS"
    res

// ============================================================
// MULTI-TIMEFRAME REQUESTS
// ============================================================
f_getM2(string tf) =>
    c = request.security(syminfo.tickerid, tf, close, barmerge.gaps_off, barmerge.lookahead_off)
    e = request.security(syminfo.tickerid, tf, ta.ema(close, emaLen), barmerge.gaps_off, barmerge.lookahead_off)
    s = request.security(syminfo.tickerid, tf, ta.sma(close, smaLen), barmerge.gaps_off, barmerge.lookahead_off)
    f_method2(c, e, s)

tf15 = "15"
tf1H = "60"
tf4H = "240"
tfD  = "D"
tfW  = "W"

t_15 = f_getM2(tf15)
t_1H = f_getM2(tf1H)
t_4H = f_getM2(tf4H)
t_D  = f_getM2(tfD)
t_W  = f_getM2(tfW)

// ============================================================
// MAS UND PIVOTS AUF AKTUELLEM CHART
// ============================================================
emaVal = ta.ema(close, emaLen)
smaVal = ta.sma(close, smaLen)
plot(showMA ? emaVal : na, "EMA 20", color=color.new(color.green, 0), linewidth=2)
plot(showMA ? smaVal : na, "SMA 50", color=color.new(color.red,   0), linewidth=2)

phNow = ta.pivothigh(high, pivLen, pivLen)
plNow = ta.pivotlow(low,  pivLen, pivLen)
plotshape(showPiv and not na(phNow), title="Pivot High", style=shape.circle, location=location.abovebar, color=color.new(color.red, 0),   size=size.tiny, offset=-pivLen)
plotshape(showPiv and not na(plNow), title="Pivot Low",  style=shape.circle, location=location.belowbar, color=color.new(color.green, 0), size=size.tiny, offset=-pivLen)

// ============================================================
// TABELLE
// ============================================================
f_pos(string p) =>
    p == "top_right"     ? position.top_right     :
     p == "top_left"      ? position.top_left      :
     p == "bottom_right"  ? position.bottom_right  :
     p == "bottom_left"   ? position.bottom_left   :
     p == "middle_right"  ? position.middle_right  :
     position.middle_left

f_size(string s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large :
     size.normal

f_cellColor(string state) =>
    state == "UPTREND"   ? color.new(color.green, 20) :
     state == "DOWNTREND" ? color.new(color.red,   20) :
     color.new(color.gray, 40)

f_arrow(string state) =>
    state == "UPTREND"   ? "▲ UPTREND"   :
     state == "DOWNTREND" ? "▼ DOWNTREND" :
     "◆ SIDEWAYS"

var table tbl = table.new(f_pos(tblPos), 2, 8, border_width=1)

if barstate.islast and showTbl
    table.cell(tbl, 0, 0, "TIMEFRAME", bgcolor=color.new(color.black, 0), text_color=color.white, text_size=f_size(tblSize))
    table.cell(tbl, 1, 0, "TREND",     bgcolor=color.new(color.black, 0), text_color=color.white, text_size=f_size(tblSize))

    rows   = array.from("15m","1H","4H","1D","1W")
    states = array.from(t_15, t_1H, t_4H, t_D, t_W)

    for i = 0 to 4
        lbl = array.get(rows,   i)
        st  = array.get(states, i)
        table.cell(tbl, 0, i+1, lbl,        bgcolor=color.new(color.black, 0), text_color=color.white, text_size=f_size(tblSize))
        table.cell(tbl, 1, i+1, f_arrow(st), bgcolor=f_cellColor(st),          text_color=color.white, text_size=f_size(tblSize))

if not showTbl
    table.clear(tbl, 0, 0, 1, 5)
````
