# Market Conditions Panel PRO (Multi-Market)

- url: https://www.tradingview.com/script/0D4HTaoP/
- type: indicator
- pine_id: PUB;4065d3c9a64d4d66a5fabcb431fd43b4
- version: 1.0

## Description

Market Conditions Panel PRO ist ein manuelles Multi-Market-Dashboard für TradingView. Der Indikator zeigt direkt im Chart die vorher definierte Markteinschätzung für verschiedene Futures- oder CFD-Märkte an.

Das Panel dient als visuelle Checkliste für die Marktstruktur und unterstützt einen strukturierten Tradingprozess über mehrere Zeitebenen.

Funktionen
Automatische Erkennung des aktuellen Charts über Symbol-Filter
Unterstützung mehrerer Märkte, z. B. MES, ES, NQ, FDAX, YM
Frei definierbarer Markt-Bias: Bullish, Bearish oder Neutral
Drei individuell einstellbare Zeitebenen, z. B. Daily, 4H und 1H
Manuelle Klassifizierung der Marktbedingungen:
Trendy Long
Trendy Short
Choppy Long
Choppy Short
Seitwärts
Farbige Darstellung für schnelle Orientierung
Pfeilsymbole zur visuellen Richtungsanzeige
Optionales Notizfeld für Setup-Kommentare, Bias-Fenster oder wichtige Marktinformationen
Flexible Panel-Positionierung im Chart
Zweck

Der Indikator berechnet keine automatischen Signale und generiert keine Kauf- oder Verkaufsempfehlungen. Er ist als manuelles Analyse- und Entscheidungsdashboard gedacht.

Er hilft dabei, den eigenen Tradingplan konsequent umzusetzen, indem Bias, Marktstruktur und Zeitebenen direkt im Chart sichtbar bleiben.

Typischer Einsatz

Der Indikator eignet sich besonders für Trader, die mit einem mehrstufigen Entscheidungsprozess arbeiten:

Markt-Bias bestimmen
Marktstruktur auf mehreren Zeitebenen prüfen
Nur Setups handeln, die zum Bias und zur Struktur passen
Notizen und Kontext direkt im Chart sichtbar halten

Dadurch wird der Tradingprozess klarer, disziplinierter und besser dokumentierbar.

Hinweis

Alle Zustände im Panel werden manuell eingestellt. Der Indikator ist kein automatisches Handelssystem, sondern ein visuelles Framework zur Unterstützung der eigenen Marktanalyse.

## Source Code

````pine
//@version=6
indicator("Market Conditions Panel PRO (Multi-Market)", overlay=true)

//====================================================
// GENERAL SETTINGS
//====================================================
groupGeneral = "General Settings"

panelPosition = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupGeneral)
matchMode     = input.string("Exact", "Symbol Match Mode", options=["Exact", "Contains"], group=groupGeneral)
showNotes     = input.bool(true, "Show Notes Field", group=groupGeneral)

//====================================================
// HELPER FUNCTIONS
//====================================================
getPanelPosition(pos) =>
    p = position.top_right
    if pos == "Top Left"
        p := position.top_left
    else if pos == "Bottom Right"
        p := position.bottom_right
    else if pos == "Bottom Left"
        p := position.bottom_left
    p

normalize(txt) =>
    str.upper(str.trim(txt))

symbolMatches(filterText, mode) =>
    f  = normalize(filterText)
    tk = normalize(syminfo.ticker)
    rt = normalize(syminfo.root)
    id = normalize(syminfo.tickerid)

    mode == "Contains" ?
         (f != "" and (str.contains(tk, f) or str.contains(rt, f) or str.contains(id, f))) :
         (f != "" and (tk == f or rt == f or id == f))

getArrow(state) =>
    arrow = "?"
    if state == "Trendy Long"
        arrow := "↑"
    else if state == "Trendy Short"
        arrow := "↓"
    else if state == "Choppy Long"
        arrow := "↗"
    else if state == "Choppy Short"
        arrow := "↘"
    else if state == "Seitwärts"
        arrow := "↔"
    arrow

getStateBgColor(state) =>
    c = color.new(color.gray, 70)
    if state == "Trendy Long"
        c := color.new(color.green, 0)
    else if state == "Trendy Short"
        c := color.new(color.red, 0)
    else if state == "Choppy Long"
        c := color.new(color.green, 78)
    else if state == "Choppy Short"
        c := color.new(color.red, 78)
    else if state == "Seitwärts"
        c := color.new(color.gray, 70)
    c

getStateTextColor(state) =>
    c = color.black
    if state == "Trendy Long" or state == "Trendy Short"
        c := color.white
    c

getBiasColor(bias) =>
    c = color.new(color.gray, 70)
    if bias == "Bullish"
        c := color.new(color.green, 0)
    else if bias == "Bearish"
        c := color.new(color.red, 0)
    else if bias == "Neutral"
        c := color.new(color.gray, 70)
    c

//====================================================
// MARKET 1
//====================================================
groupM1 = "Market 1"
enable1 = input.bool(true, "Enable", group=groupM1)
filter1 = input.string("MES1!", "Symbol Filter", group=groupM1)
bias1   = input.string("Neutral", "Bias", options=["Bullish", "Bearish", "Neutral"], group=groupM1)

tf1_1    = input.string("1D", "Timeframe 1", group=groupM1)
state1_1 = input.string("Trendy Long", "Condition 1", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM1)

tf2_1    = input.string("4H", "Timeframe 2", group=groupM1)
state2_1 = input.string("Seitwärts", "Condition 2", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM1)

tf3_1    = input.string("1H", "Timeframe 3", group=groupM1)
state3_1 = input.string("Choppy Short", "Condition 3", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM1)

note1    = input.string("", "Notes", group=groupM1)

//====================================================
// MARKET 2
//====================================================
groupM2 = "Market 2"
enable2 = input.bool(true, "Enable", group=groupM2)
filter2 = input.string("FDAX1!", "Symbol Filter", group=groupM2)
bias2   = input.string("Neutral", "Bias", options=["Bullish", "Bearish", "Neutral"], group=groupM2)

tf1_2    = input.string("1D", "Timeframe 1", group=groupM2)
state1_2 = input.string("Trendy Long", "Condition 1", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM2)

tf2_2    = input.string("4H", "Timeframe 2", group=groupM2)
state2_2 = input.string("Seitwärts", "Condition 2", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM2)

tf3_2    = input.string("1H", "Timeframe 3", group=groupM2)
state3_2 = input.string("Choppy Short", "Condition 3", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM2)

note2    = input.string("", "Notes", group=groupM2)

//====================================================
// MARKET 3
//====================================================
groupM3 = "Market 3"
enable3 = input.bool(true, "Enable", group=groupM3)
filter3 = input.string("NQ1!", "Symbol Filter", group=groupM3)
bias3   = input.string("Neutral", "Bias", options=["Bullish", "Bearish", "Neutral"], group=groupM3)

tf1_3    = input.string("1D", "Timeframe 1", group=groupM3)
state1_3 = input.string("Trendy Long", "Condition 1", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM3)

tf2_3    = input.string("4H", "Timeframe 2", group=groupM3)
state2_3 = input.string("Seitwärts", "Condition 2", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM3)

tf3_3    = input.string("1H", "Timeframe 3", group=groupM3)
state3_3 = input.string("Choppy Short", "Condition 3", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM3)

note3    = input.string("", "Notes", group=groupM3)

//====================================================
// MARKET 4
//====================================================
groupM4 = "Market 4"
enable4 = input.bool(false, "Enable", group=groupM4)
filter4 = input.string("ES1!", "Symbol Filter", group=groupM4)
bias4   = input.string("Neutral", "Bias", options=["Bullish", "Bearish", "Neutral"], group=groupM4)

tf1_4    = input.string("1D", "Timeframe 1", group=groupM4)
state1_4 = input.string("Trendy Long", "Condition 1", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM4)

tf2_4    = input.string("4H", "Timeframe 2", group=groupM4)
state2_4 = input.string("Seitwärts", "Condition 2", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM4)

tf3_4    = input.string("1H", "Timeframe 3", group=groupM4)
state3_4 = input.string("Choppy Short", "Condition 3", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM4)

note4    = input.string("", "Notes", group=groupM4)

//====================================================
// MARKET 5
//====================================================
groupM5 = "Market 5"
enable5 = input.bool(false, "Enable", group=groupM5)
filter5 = input.string("YM1!", "Symbol Filter", group=groupM5)
bias5   = input.string("Neutral", "Bias", options=["Bullish", "Bearish", "Neutral"], group=groupM5)

tf1_5    = input.string("1D", "Timeframe 1", group=groupM5)
state1_5 = input.string("Trendy Long", "Condition 1", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM5)

tf2_5    = input.string("4H", "Timeframe 2", group=groupM5)
state2_5 = input.string("Seitwärts", "Condition 2", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM5)

tf3_5    = input.string("1H", "Timeframe 3", group=groupM5)
state3_5 = input.string("Choppy Short", "Condition 3", options=["Trendy Long", "Trendy Short", "Choppy Long", "Choppy Short", "Seitwärts"], group=groupM5)

note5    = input.string("", "Notes", group=groupM5)

//====================================================
// MATCH LOGIC
//====================================================
match1 = enable1 and symbolMatches(filter1, matchMode)
match2 = enable2 and symbolMatches(filter2, matchMode)
match3 = enable3 and symbolMatches(filter3, matchMode)
match4 = enable4 and symbolMatches(filter4, matchMode)
match5 = enable5 and symbolMatches(filter5, matchMode)

//====================================================
// ACTIVE SLOT SELECTION
// First matching slot wins
//====================================================
string activeBias = ""
string activeTF1  = ""
string activeTF2  = ""
string activeTF3  = ""
string activeST1  = ""
string activeST2  = ""
string activeST3  = ""
string activeNote = ""

if match1
    activeBias := bias1
    activeTF1  := tf1_1
    activeTF2  := tf2_1
    activeTF3  := tf3_1
    activeST1  := state1_1
    activeST2  := state2_1
    activeST3  := state3_1
    activeNote := note1
else if match2
    activeBias := bias2
    activeTF1  := tf1_2
    activeTF2  := tf2_2
    activeTF3  := tf3_2
    activeST1  := state1_2
    activeST2  := state2_2
    activeST3  := state3_2
    activeNote := note2
else if match3
    activeBias := bias3
    activeTF1  := tf1_3
    activeTF2  := tf2_3
    activeTF3  := tf3_3
    activeST1  := state1_3
    activeST2  := state2_3
    activeST3  := state3_3
    activeNote := note3
else if match4
    activeBias := bias4
    activeTF1  := tf1_4
    activeTF2  := tf2_4
    activeTF3  := tf3_4
    activeST1  := state1_4
    activeST2  := state2_4
    activeST3  := state3_4
    activeNote := note4
else if match5
    activeBias := bias5
    activeTF1  := tf1_5
    activeTF2  := tf2_5
    activeTF3  := tf3_5
    activeST1  := state1_5
    activeST2  := state2_5
    activeST3  := state3_5
    activeNote := note5

showPanel = activeBias != ""

// Automatische Marktanzeige aus dem aktuellen Chart
currentMarket = syminfo.root != "" ? syminfo.root : syminfo.ticker

//====================================================
// TABLE
//====================================================
rows = 7
var table panel = table.new(getPanelPosition(panelPosition), 3, rows, border_width=1)

//====================================================
// DRAW
//====================================================
if barstate.islast
    table.clear(panel, 0, 0, 2, rows - 1)

    if showPanel
        // Header
        table.cell(panel, 0, 0, "MARKET", bgcolor=color.new(color.blue, 0), text_color=color.white)
        table.cell(panel, 1, 0, currentMarket, bgcolor=color.new(color.blue, 0), text_color=color.white)
        table.cell(panel, 2, 0, "", bgcolor=color.new(color.blue, 0), text_color=color.white)

        // Bias
        table.cell(panel, 0, 1, "BIAS", bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(panel, 1, 1, activeBias, bgcolor=getBiasColor(activeBias), text_color=color.black)
        table.cell(panel, 2, 1, "", bgcolor=getBiasColor(activeBias), text_color=color.black)

        // Column Header
        table.cell(panel, 0, 2, "TF", bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(panel, 1, 2, "CONDITION", bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(panel, 2, 2, "ARROW", bgcolor=color.new(color.black, 0), text_color=color.white)

        // Row 1
        table.cell(panel, 0, 3, activeTF1, bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(panel, 1, 3, activeST1, bgcolor=getStateBgColor(activeST1), text_color=getStateTextColor(activeST1))
        table.cell(panel, 2, 3, getArrow(activeST1), bgcolor=getStateBgColor(activeST1), text_color=getStateTextColor(activeST1))

        // Row 2
        table.cell(panel, 0, 4, activeTF2, bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(panel, 1, 4, activeST2, bgcolor=getStateBgColor(activeST2), text_color=getStateTextColor(activeST2))
        table.cell(panel, 2, 4, getArrow(activeST2), bgcolor=getStateBgColor(activeST2), text_color=getStateTextColor(activeST2))

        // Row 3
        table.cell(panel, 0, 5, activeTF3, bgcolor=color.new(color.black, 0), text_color=color.white)
        table.cell(panel, 1, 5, activeST3, bgcolor=getStateBgColor(activeST3), text_color=getStateTextColor(activeST3))
        table.cell(panel, 2, 5, getArrow(activeST3), bgcolor=getStateBgColor(activeST3), text_color=getStateTextColor(activeST3))

        // Notes
        if showNotes
            table.cell(panel, 0, 6, "NOTES", bgcolor=color.new(color.black, 0), text_color=color.white)
            table.cell(panel, 1, 6, activeNote, bgcolor=color.new(color.gray, 85), text_color=color.black)
            table.cell(panel, 2, 6, "", bgcolor=color.new(color.gray, 85), text_color=color.black)
````
