# ATR Indicator

- url: https://www.tradingview.com/script/w5ReNHoM-ATR-Indicator/
- type: indicator
- pine_id: PUB;301698118e7e4949b9769feaa504c750
- version: 1.0

## Description

What this indicator does

The ATR Daily Progress measures how many ticks the market has already traveled during the current trading session and compares that value with the average daily movement calculated from previous sessions.

The indicator provides traders with a real-time view of the session's progress relative to its historical average range, helping them understand whether the market is operating below, near, or beyond its typical daily movement.

Key information displayed includes:

Current session ticks traveled
Average daily ticks based on historical sessions
Percentage of average range already completed
Real-time monitoring of daily expansion and exhaustion conditions
Who this indicator is for

This indicator is designed for:

Futures traders
Day traders
Scalpers
Intraday traders
Traders who use volatility and range analysis in their decision-making process

It is especially useful for traders who want to avoid entering trades after a significant portion of the average daily movement has already been completed.

What makes this indicator different

Unlike traditional ATR indicators that only display volatility values, this tool focuses on the practical intraday application of daily range statistics.

The indicator combines:

Real-time session range tracking
Historical average range analysis
Immediate visualization of daily progress
Session-based market exhaustion awareness

The goal is not simply to measure volatility, but to provide actionable context regarding how much of the market's expected daily movement has already occurred.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
// Traivend ATR — Sessions Panel (Replica für TradingView)
// ════════════════════════════════════════════════════════════════════
// Nachbildung des Traivend ATR Indikators (NinjaTrader/ATAS).
//
// Anzeige pro Session (ASIA / LONDON / US) + Tages-Total:
//   • Ø Range über X Tage (Default 3)
//   • Heutige Range in Pips/Ticks/Punkten + Auslastung in %
//   • Über-/Unterzug ggü. Durchschnitt (nur Total)
//   • Letzte X Tage als Vergleich
//   • Tagestyp: Outside / Inside / Trend Up / Trend Down
//
// Pfeile ▲/▼ zeigen: Range > Ø  =  ▲   |   Range < Ø  =  ▼
//
// Voraussetzung: Chart auf INTRADAY Timeframe (≤ 1H empfohlen),
// mindestens X+1 Tage Historie geladen.
// ════════════════════════════════════════════════════════════════════
indicator("Traivend ATR — Sessions", overlay = true, max_bars_back = 5000)

// ═══ Inputs ══════════════════════════════════════════════════════════
grpG = "Allgemein"
tzInput = input.string("Europe/Berlin", "Zeitzone", group = grpG, tooltip = "Zeitzone für Tagesgrenzen und Sessions")
avgDays = input.int(3, "Ø über X Tage", minval = 1, maxval = 30, group = grpG)

unitMode = input.string("Pips", "Anzeige-Einheit", options = ["Pips","Ticks","Punkte"], group = grpG, tooltip = "Pips: bei Forex automatisch = mintick × 10 (z.B. 0.0001 für EURUSD 5-stellig). Ticks: kleinster Preissprung. Punkte: 1.0 Preiseinheit (NQ-Punkt = 4 Ticks).")
pipSizeManual = input.float(0.0, "Pip-Größe (manuell, 0 = auto)", minval = 0.0, step = 0.00001, group = grpG, tooltip = "0 = auto. Override-Beispiele: 0.0001 (EURUSD 4-stellig), 0.01 (USDJPY 2-stellig), 1.0 (Indizes).")

grpS = "Sessions (Format HHMM-HHMM)"
sessAsia   = input.session("0000-0900", "ASIA",   group = grpS)
sessLondon = input.session("0900-1530", "LONDON", group = grpS)
sessUs     = input.session("1530-2200", "US",     group = grpS)

grpT = "Auslastung-Schwellen (%)"
thWarn = input.float(60.0,  "Warn",   group = grpT, step = 5.0)
thOver = input.float(100.0, "Über",   group = grpT, step = 5.0)
thExtr = input.float(130.0, "Extrem", group = grpT, step = 5.0)

grpA = "Anzeige"
showTable = input.bool(true, "Tabelle anzeigen", group = grpA)
posInput  = input.string("Oben rechts", "Position", options = ["Oben rechts","Oben links","Unten rechts","Unten links","Mitte rechts","Mitte links"], group = grpA)
sizeInput = input.string("Klein", "Schriftgröße", options = ["Winzig","Klein","Normal","Groß"], group = grpA)

cLow   = input.color(#26a69a, "Farbe < Warn",         group = grpA)
cMid   = input.color(#ffa726, "Farbe Warn-Über",      group = grpA)
cHigh  = input.color(#ef5350, "Farbe Über-Extrem",    group = grpA)
cExtr  = input.color(#c62828, "Farbe > Extrem",       group = grpA)
cText  = input.color(#e8e8e8, "Textfarbe",            group = grpA)
cDim   = input.color(#888888, "Sekundär-Text",        group = grpA)
cBg1   = input.color(#1a1a1a, "Hintergrund 1",        group = grpA)
cBg2   = input.color(#252525, "Hintergrund 2",        group = grpA)
cBgHdr = input.color(#0d1b1c, "Header BG",            group = grpA)

// ═══ Einheit berechnen ═══════════════════════════════════════════════
tickSize = syminfo.mintick

f_autoPipSize() =>
    syminfo.type == "forex" ? syminfo.mintick * 10 : syminfo.mintick

pipSize   = pipSizeManual > 0 ? pipSizeManual : f_autoPipSize()
unitSize  = unitMode == "Pips" ? pipSize : (unitMode == "Punkte" ? 1.0 : tickSize)
unitLabel = unitMode

// ═══ Helpers ═════════════════════════════════════════════════════════
f_inSess(string s) =>
    not na(time(timeframe.period, s, tzInput))

// Auslastung-Farbe nach Schwellen (if-expression statt multi-line Ternär)
f_color(float pct) =>
    if na(pct)
        cDim
    else if pct < thWarn
        cLow
    else if pct < thOver
        cMid
    else if pct < thExtr
        cHigh
    else
        cExtr

f_pos() =>
    switch posInput
        "Oben rechts"  => position.top_right
        "Oben links"   => position.top_left
        "Unten rechts" => position.bottom_right
        "Unten links"  => position.bottom_left
        "Mitte rechts" => position.middle_right
        "Mitte links"  => position.middle_left
        => position.top_right

f_size() =>
    switch sizeInput
        "Winzig" => size.tiny
        "Klein"  => size.small
        "Normal" => size.normal
        "Groß"   => size.large
        => size.small

// Richtung: Range > Ø → 1 (▲) | Range < Ø → -1 (▼) | sonst 0
f_dirVsAvg(float v, float a) =>
    (na(v) or na(a)) ? 0 : (v >= a ? 1 : -1)

f_arrow(int d) =>
    d > 0 ? "▲" : (d < 0 ? "▼" : "▬")

f_arrowCol(int d) =>
    d > 0 ? cLow : (d < 0 ? cHigh : cDim)

// Block-Balken: 15 Zeichen, Skala 0–150 %
f_bar(float pct) =>
    int nCh = 15
    float v = na(pct) ? 0.0 : math.max(0.0, pct)
    int filled = math.min(nCh, math.round(v * nCh / 150.0))
    string s = ""
    for i = 1 to nCh
        s := s + (i <= filled ? "█" : "░")
    s

f_avg(array<float> arr) =>
    arr.size() == 0 ? na : array.avg(arr)

// Roh-Preisdifferenz → formatierter Wert in der gewählten Einheit
f_fmtUnit(float priceDiff) =>
    na(priceDiff) ? "n/a" : str.tostring(priceDiff / unitSize, "#.#")

// Auslastung in % berechnen (todayRng / avgR × 100), na-sicher
f_pct(float todayRng, float avgR) =>
    (na(avgR) or avgR == 0 or na(todayRng)) ? na : todayRng / avgR * 100.0

// "Letzte X T" String — ältester links, neuester rechts. Arrow je Wert vs Ø
f_lastNStr(array<float> arr, float avg) =>
    string s = ""
    int sz = arr.size()
    if sz == 0
        s := "n/a"
    else
        for i = 0 to sz - 1
            int j = sz - 1 - i
            float r = arr.get(j)
            int d = f_dirVsAvg(r, avg)
            s := s + f_arrow(d) + f_fmtUnit(r) + "  "
    s

// ═══ UDT: Session-Zustand (speichert RAW-Preisdifferenzen) ═══════════
type SessState
    float hi = na
    float lo = na
    float todayRange = na
    bool  wasIn = false
    array<float> pastRanges

f_updateSess(SessState s, bool inSess, bool nd) =>
    if nd
        if not na(s.hi) and not na(s.lo)
            float rng = s.hi - s.lo
            s.pastRanges.unshift(rng)
            if s.pastRanges.size() > avgDays
                s.pastRanges.pop()
        s.hi := na
        s.lo := na
        s.todayRange := na
        s.wasIn := false
    if inSess
        if not s.wasIn
            s.hi := high
            s.lo := low
        else
            s.hi := math.max(s.hi, high)
            s.lo := math.min(s.lo, low)
        s.todayRange := s.hi - s.lo
    s.wasIn := inSess
    s

// ═══ Tageswechsel erkennen (gemäß tzInput) ═══════════════════════════
int todayTz = dayofmonth(time, tzInput)
int prevTz  = dayofmonth(time[1], tzInput)
bool isNewDay = na(prevTz) ? true : (todayTz != prevTz)

// ═══ Init Session-States ═════════════════════════════════════════════
var SessState asia   = SessState.new(pastRanges = array.new<float>())
var SessState london = SessState.new(pastRanges = array.new<float>())
var SessState us     = SessState.new(pastRanges = array.new<float>())

asia   := f_updateSess(asia,   f_inSess(sessAsia),   isNewDay)
london := f_updateSess(london, f_inSess(sessLondon), isNewDay)
us     := f_updateSess(us,     f_inSess(sessUs),     isNewDay)

// ═══ Tages-Total Tracking ════════════════════════════════════════════
var float dayHi  = na
var float dayLo  = na
var float pdayHi = na
var float pdayLo = na
var array<float> dayPastRanges = array.new<float>()

if isNewDay
    if not na(dayHi) and not na(dayLo)
        pdayHi := dayHi
        pdayLo := dayLo
        dayPastRanges.unshift(dayHi - dayLo)
        if dayPastRanges.size() > avgDays
            dayPastRanges.pop()
    dayHi := high
    dayLo := low
else
    if not na(dayHi)
        dayHi := math.max(dayHi, high)
        dayLo := math.min(dayLo, low)
    else
        dayHi := high
        dayLo := low

float todayTotalRange = (na(dayHi) or na(dayLo)) ? na : (dayHi - dayLo)

// ═══ Tagestyp: Outside / Inside / Trend Up / Trend Down ══════════════
string tagesType  = "—"
color  tagesColor = cDim

if not na(pdayHi) and not na(pdayLo) and not na(dayHi) and not na(dayLo)
    bool outAbove = dayHi > pdayHi
    bool outBelow = dayLo < pdayLo
    if outAbove and outBelow
        tagesType  := "Outside Day"
        tagesColor := cMid
    else if (not outAbove) and (not outBelow)
        tagesType  := "Inside Day"
        tagesColor := cDim
    else if outAbove
        tagesType  := "Trend Up"
        tagesColor := cLow
    else
        tagesType  := "Trend Down"
        tagesColor := cHigh

// ═══ Helper: Session-Block in Tabelle zeichnen ═══════════════════════
f_drawSection(table t, int r0, string title, string sessStr, float todayRng, array<float> pastRng) =>
    float avgR = f_avg(pastRng)
    float pct  = f_pct(todayRng, avgR)
    int   dir  = f_dirVsAvg(todayRng, avgR)
    color barC = f_color(pct)
    string sub = "(" + sessStr + ")"

    // Section-Header
    table.cell(t, 0, r0, title + "  " + sub, text_color = cText, bgcolor = cBgHdr, text_size = f_size(), text_halign = text.align_left)
    table.cell(t, 1, r0, "", bgcolor = cBgHdr)
    table.cell(t, 2, r0, "", bgcolor = cBgHdr)

    // Ø (Xd)
    string avgTxt = na(avgR) ? "n/a" : f_fmtUnit(avgR) + " " + unitLabel
    table.cell(t, 0, r0 + 1, "Ø (" + str.tostring(avgDays) + "d)", text_color = cDim, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_left)
    table.cell(t, 1, r0 + 1, "", bgcolor = cBg1)
    table.cell(t, 2, r0 + 1, avgTxt, text_color = cText, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_right)

    // Heute
    string pctStr = na(pct) ? "" : "  (" + str.tostring(pct, "#.#") + "%)"
    string rngTxt = (na(todayRng) ? "n/a" : f_fmtUnit(todayRng) + " " + unitLabel) + pctStr
    table.cell(t, 0, r0 + 2, "Heute", text_color = cDim, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_left)
    table.cell(t, 1, r0 + 2, f_arrow(dir), text_color = f_arrowCol(dir), bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)
    table.cell(t, 2, r0 + 2, rngTxt, text_color = cText, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)

    // Progress-Balken
    string barPctStr = na(pct) ? "" : str.tostring(pct, "#.#") + "%"
    table.cell(t, 0, r0 + 3, f_bar(pct), text_color = barC, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_left)
    table.cell(t, 1, r0 + 3, "", bgcolor = cBg1)
    table.cell(t, 2, r0 + 3, barPctStr, text_color = barC, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_right)

    // Letzte XT
    table.cell(t, 0, r0 + 4, "Letzte " + str.tostring(avgDays) + "T", text_color = cDim, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_left)
    table.cell(t, 1, r0 + 4, "", bgcolor = cBg2)
    table.cell(t, 2, r0 + 4, f_lastNStr(pastRng, avgR), text_color = cText, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)

    r0 + 5

// ═══ Tabelle aufbauen ════════════════════════════════════════════════
var table tbl = na

if showTable and barstate.islast
    tbl := table.new(f_pos(), 3, 35, border_width = 0, frame_color = color.new(color.gray, 70), frame_width = 1)

    int r = 0

    // Master-Header
    table.cell(tbl, 0, r, "▶ Traivend ATR", text_color = cMid, bgcolor = cBgHdr, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, "", bgcolor = cBgHdr)
    table.cell(tbl, 2, r, syminfo.ticker + "  " + timeframe.period, text_color = cDim, bgcolor = cBgHdr, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // ── Total ──
    float avgDay = f_avg(dayPastRanges)
    float pctDay = f_pct(todayTotalRange, avgDay)
    int   dirDay = f_dirVsAvg(todayTotalRange, avgDay)

    // ATR (Xd) — Durchschnitt
    string totAvgTxt = na(avgDay) ? "n/a" : f_fmtUnit(avgDay) + " " + unitLabel
    table.cell(tbl, 0, r, "ATR (" + str.tostring(avgDays) + "d)", text_color = cDim, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, "", bgcolor = cBg1)
    table.cell(tbl, 2, r, totAvgTxt, text_color = cText, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // Heute Total
    string pctDayStr = na(pctDay) ? "" : "  (" + str.tostring(pctDay, "#.#") + "%)"
    string totRngTxt = (na(todayTotalRange) ? "n/a" : f_fmtUnit(todayTotalRange) + " " + unitLabel) + pctDayStr
    table.cell(tbl, 0, r, "Heute", text_color = cDim, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, f_arrow(dirDay), text_color = f_arrowCol(dirDay), bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)
    table.cell(tbl, 2, r, totRngTxt, text_color = cText, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // Über-/Unterzogen
    float diffT  = (na(avgDay) or na(todayTotalRange)) ? na : todayTotalRange - avgDay
    float diffP  = na(pctDay) ? na : pctDay - 100.0
    string dLbl  = na(diffT) ? "—" : (diffT >= 0 ? "Überzogen" : "Unterzogen")
    color  dCol  = na(diffP) ? cDim : (diffP >= 0 ? cHigh : cLow)
    string dSign = (not na(diffT) and diffT >= 0) ? "+" : ""
    string pSign = (not na(diffP) and diffP >= 0) ? "+" : ""
    string dStr  = na(diffT) ? "n/a" : dSign + f_fmtUnit(diffT) + " " + unitLabel + "  (" + pSign + str.tostring(diffP, "#.#") + "%)"
    table.cell(tbl, 0, r, dLbl, text_color = cDim, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, "", bgcolor = cBg1)
    table.cell(tbl, 2, r, dStr, text_color = dCol, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // Progress-Balken Total
    color barCTot = f_color(pctDay)
    string totBarPctStr = na(pctDay) ? "" : str.tostring(pctDay, "#.#") + "%"
    table.cell(tbl, 0, r, f_bar(pctDay), text_color = barCTot, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, "", bgcolor = cBg2)
    table.cell(tbl, 2, r, totBarPctStr, text_color = barCTot, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // Tagestyp
    table.cell(tbl, 0, r, "Tagestyp", text_color = cDim, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, "", bgcolor = cBg1)
    table.cell(tbl, 2, r, tagesType, text_color = tagesColor, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // Letzte XT Total
    table.cell(tbl, 0, r, "Letzte " + str.tostring(avgDays) + "T", text_color = cDim, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_left)
    table.cell(tbl, 1, r, "", bgcolor = cBg2)
    table.cell(tbl, 2, r, f_lastNStr(dayPastRanges, avgDay), text_color = cText, bgcolor = cBg2, text_size = f_size(), text_halign = text.align_right)
    r += 1

    // ── Session-Blöcke ──
    r := f_drawSection(tbl, r, "ASIA",   sessAsia,   asia.todayRange,   asia.pastRanges)
    r := f_drawSection(tbl, r, "LONDON", sessLondon, london.todayRange, london.pastRanges)
    r := f_drawSection(tbl, r, "US",     sessUs,     us.todayRange,     us.pastRanges)

    // ── Footer-Warnung wenn TF zu groß ──
    if timeframe.in_seconds() > 60 * 60
        table.cell(tbl, 0, r, "⚠ TF zu hoch", text_color = cHigh, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_left)
        table.cell(tbl, 1, r, "", bgcolor = cBg1)
        table.cell(tbl, 2, r, "Bitte ≤ 1H verwenden", text_color = cHigh, bgcolor = cBg1, text_size = f_size(), text_halign = text.align_right)

// ═══ Alerts ══════════════════════════════════════════════════════════
float avgForAlert = f_avg(dayPastRanges)
float pctForAlert = f_pct(todayTotalRange, avgForAlert)

alertcondition(not na(pctForAlert) and pctForAlert >= thOver, "ATR-Auslastung über 100%", "Tagesrange hat den Mehrtages-Durchschnitt überschritten")
alertcondition(not na(pctForAlert) and pctForAlert >= thExtr, "ATR-Auslastung Extrem",    "Tagesrange weit über dem Mehrtages-Durchschnitt")
alertcondition(tagesType == "Outside Day",                    "Outside Day erkannt",      "Heutige Range liegt komplett außerhalb der gestrigen")
````
