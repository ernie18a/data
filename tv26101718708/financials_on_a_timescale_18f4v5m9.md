# Financials on a timescale

- url: https://www.tradingview.com/script/18f4V5M9/
- type: indicator
- pine_id: PUB;8966ad55389543008a8256356db074ab
- version: 2.0

## Description

Description:

This indicator displays key financial metrics of a stock over time as individual lines in a separate pane. It allows you to see at a glance how a company's fundamentals have developed – without switching to the financials tab.

What the Indicator Shows

The four main metrics are displayed by default: Book Value (Equity) in blue, Total Debt in red, Net Income in green, and Total Revenue in fuchsia. An additional nine metrics can be enabled in the settings, including Gross Profit, EBITDA, Operating Income, Free Cash Flow, Operating Cash Flow, Total Assets, Total Liabilities, and Research & Development. A dotted zero line helps with orientation. The indicator uses TradingView's volume format, which automatically scales values to K, M, or B for better readability.

Settings

The reporting period can be switched between Fiscal Year (FY), Fiscal Quarter (FQ), and Trailing Twelve Months (TTM). Note that balance sheet items (Book Value, Debt, Assets, Liabilities, R&D) do not support TTM – the indicator automatically falls back to FQ for these metrics. Line width is adjustable from 1 to 5. Each metric can be individually toggled on or off, and its color can be customized.

Usage Notes

The indicator only works for stocks with available fundamental data and is most useful on the daily or weekly chart. Financial data is typically updated with a delay after earnings releases, so the most recent bar may not reflect the latest quarter until TradingView updates its database. Comparing revenue and earnings lines over multiple years can help visualize growth trends, while the relationship between equity and debt provides a quick view of the balance sheet structure.

Important Note

This indicator is for informational and educational purposes only and does not constitute investment advice or a buy/sell recommendation. Financial metrics alone should never be the sole basis for investment decisions – they should always be evaluated in the context of the business model, industry dynamics, and future outlook. Fundamental data is provided by TradingView; no guarantee is given for its accuracy or completeness.

Financials – Buchwert · Schulden · Gewinn · Umsatz

Beschreibung:

Dieser Indikator stellt die wichtigsten Fundamentalkennzahlen einer Aktie als einzelne Linien in einem eigenen Fenster dar. So lässt sich auf einen Blick erkennen, wie sich die Finanzdaten eines Unternehmens über die Zeit entwickelt haben – ohne in den Finanzdaten-Tab wechseln zu müssen.

Was der Indikator zeigt

Standardmäßig werden die vier Hauptkennzahlen dargestellt: der Buchwert (Eigenkapital) in Blau, die gesamten Schulden in Rot, der Nettogewinn in Grün und der Umsatz in Pink. Neun weitere Kennzahlen lassen sich in den Einstellungen zuschalten: Bruttogewinn, EBITDA, Operatives Ergebnis, Free Cashflow, Operativer Cashflow, Bilanzsumme (Vermögen), Verbindlichkeiten gesamt sowie Forschung & Entwicklung. Eine gepunktete Nulllinie dient der Orientierung. Der Indikator verwendet das Volumenformat von TradingView, das die Werte automatisch in K, Mio. oder Mrd. skaliert.

Einstellmöglichkeiten

Der Berichtszeitraum lässt sich zwischen Geschäftsjahr (FY), Quartal (FQ) und den letzten zwölf Monaten (TTM) umschalten. Bilanzpositionen (Buchwert, Schulden, Vermögen, Verbindlichkeiten, F&E) unterstützen kein TTM – hier wird automatisch FQ verwendet. Die Linienstärke ist von 1 bis 5 einstellbar. Jede Kennzahl kann einzeln ein- oder ausgeschaltet und farblich angepasst werden.

Hinweise zur Nutzung

Der Indikator funktioniert nur bei Aktien mit verfügbaren Fundamentaldaten und ist am sinnvollsten auf dem Tages- oder Wochenchart. Fundamentaldaten werden in der Regel mit Verzögerung nach Quartalsberichten aktualisiert, sodass der aktuellste Balken möglicherweise noch nicht das letzte Quartal widerspiegelt. Der Vergleich von Umsatz- und Gewinnlinien über mehrere Jahre kann Wachstumstrends sichtbar machen, während das Verhältnis von Eigenkapital zu Schulden einen schnellen Blick auf die Bilanzstruktur erlaubt.

Wichtiger Hinweis

Dieser Indikator dient ausschließlich Informations- und Bildungszwecken und stellt keine Anlageberatung oder Kauf-/Verkaufsempfehlung dar. Einzelne Fundamentalkennzahlen sollten niemals die alleinige Grundlage für Anlageentscheidungen sein, sondern stets im Zusammenhang mit dem Geschäftsmodell, der Branchendynamik und den Zukunftsaussichten betrachtet werden. Die Fundamentaldaten werden von TradingView bereitgestellt; für deren Richtigkeit und Vollständigkeit wird keine Gewähr übernommen.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════
//  FINANCIALS  –  Buchwert · Schulden · Gewinn · Umsatz
//  Fundamentaldaten als Linien in eigenem Fenster, wahlweise pro Aktie.
//  + Qualitäts- & Dividenden-Scorecard als Tabelle (zuschaltbar)
// ════════════════════════════════════════════════════════════════
indicator("Financials – Buchwert · Schulden · Gewinn · Umsatz",
     shorttitle = "Financials",
     overlay    = false,          // eigenes Fenster (separate Pane)
     format     = format.volume)  // skaliert automatisch (abs.: K/Mio./Mrd. · je Aktie: Dezimalwert)

// ───────────── Allgemeine Einstellungen ─────────────
gAllg    = "Allgemein"
proAktie = input.bool(true, "Werte pro Aktie anzeigen", group = gAllg,
     tooltip = "An: jeder Wert wird durch die ausstehenden Aktien geteilt (z. B. Buchwert/Aktie).\nAus: absolute Werte in Währung.")
periode  = input.string("FY", "Berichtszeitraum", options = ["FY", "FQ", "TTM"], group = gAllg,
     tooltip = "FY = Geschäftsjahr · FQ = Quartal · TTM = letzte 12 Monate.\nBilanzpositionen (Buchwert, Schulden, Vermögen, Verbindlichkeiten, F&E, Aktienzahl) kennen kein TTM – dort wird dann automatisch FQ verwendet.")
lw       = input.int(2, "Linienstärke", minval = 1, maxval = 5, group = gAllg)

// TTM existiert nur für Erfolgs-/Cashflow-Größen, nicht für Bilanzpositionen
periodeNoTTM = periode == "TTM" ? "FQ" : periode

f_flow(id)  => request.financial(syminfo.tickerid, id, periode,      ignore_invalid_symbol = true)
f_stock(id) => request.financial(syminfo.tickerid, id, periodeNoTTM, ignore_invalid_symbol = true)

// Aktienzahl (für die Umrechnung pro Aktie)
shares = f_stock("TOTAL_SHARES_OUTSTANDING")

// Hilfsfunktion: bei "pro Aktie" durch Aktienzahl teilen (mit Schutz vor 0 / na)
perShare(v) => not proAktie ? v : (na(shares) or shares == 0 ? na : v / shares)

// ───────────── Hauptkennzahlen ─────────────
gMain = "Hauptkennzahlen"
eBuchwert = input.bool(true, "Buchwert (Eigenkapital)", group = gMain, inline = "1")
cBuchwert = input.color(color.blue,    "", group = gMain, inline = "1")
eSchulden = input.bool(true, "Schulden",                group = gMain, inline = "2")
cSchulden = input.color(color.red,     "", group = gMain, inline = "2")
eGewinn   = input.bool(true, "Gewinn (Nettoergebnis)",  group = gMain, inline = "3")
cGewinn   = input.color(color.green,   "", group = gMain, inline = "3")
eUmsatz   = input.bool(true, "Umsatz",                  group = gMain, inline = "4")
cUmsatz   = input.color(color.fuchsia, "", group = gMain, inline = "4")

// ───────────── Weitere Kennzahlen (standardmäßig aus) ─────────────
gAdd = "Weitere Kennzahlen"
eBrutto = input.bool(false, "Bruttogewinn",             group = gAdd, inline = "5")
cBrutto = input.color(color.teal,   "", group = gAdd, inline = "5")
eEbitda = input.bool(false, "EBITDA",                   group = gAdd, inline = "6")
cEbitda = input.color(color.orange, "", group = gAdd, inline = "6")
eOpInc  = input.bool(false, "Operatives Ergebnis",      group = gAdd, inline = "7")
cOpInc  = input.color(color.yellow, "", group = gAdd, inline = "7")
eFcf    = input.bool(false, "Free Cashflow",            group = gAdd, inline = "8")
cFcf    = input.color(color.aqua,   "", group = gAdd, inline = "8")
eOpCf   = input.bool(false, "Operativer Cashflow",      group = gAdd, inline = "9")
cOpCf   = input.color(color.lime,   "", group = gAdd, inline = "9")
eAssets = input.bool(false, "Bilanzsumme (Vermögen)",   group = gAdd, inline = "10")
cAssets = input.color(color.gray,   "", group = gAdd, inline = "10")
eLiab   = input.bool(false, "Verbindlichkeiten gesamt", group = gAdd, inline = "11")
cLiab   = input.color(color.maroon, "", group = gAdd, inline = "11")
eRnd    = input.bool(false, "Forschung & Entwicklung",  group = gAdd, inline = "12")
cRnd    = input.color(color.purple, "", group = gAdd, inline = "12")

// ───────────── Daten abrufen & ggf. pro Aktie umrechnen ─────────────
buchwert = perShare(f_stock("TOTAL_EQUITY"))
schulden = perShare(f_stock("TOTAL_DEBT"))
assets   = perShare(f_stock("TOTAL_ASSETS"))
liab     = perShare(f_stock("TOTAL_LIABILITIES"))
rnd      = perShare(f_stock("RESEARCH_AND_DEV"))

gewinn = perShare(f_flow("NET_INCOME"))
umsatz = perShare(f_flow("TOTAL_REVENUE"))
brutto = perShare(f_flow("GROSS_PROFIT"))
ebitda = perShare(f_flow("EBITDA"))
opinc  = perShare(f_flow("OPER_INCOME"))
fcf    = perShare(f_flow("FREE_CASH_FLOW"))
opcf   = perShare(f_flow("CASH_F_OPERATING_ACTIVITIES"))

// Zusatz im Linien-Titel kennzeichnen
sfx = proAktie ? " /Aktie" : ""

// ───────────── Plotten ─────────────
plot(eBuchwert ? buchwert : na, "Buchwert",            color = cBuchwert, linewidth = lw)
plot(eSchulden ? schulden : na, "Schulden",            color = cSchulden, linewidth = lw)
plot(eGewinn   ? gewinn   : na, "Gewinn",              color = cGewinn,   linewidth = lw)
plot(eUmsatz   ? umsatz   : na, "Umsatz",              color = cUmsatz,   linewidth = lw)
plot(eBrutto   ? brutto   : na, "Bruttogewinn",        color = cBrutto,   linewidth = lw)
plot(eEbitda   ? ebitda   : na, "EBITDA",              color = cEbitda,   linewidth = lw)
plot(eOpInc    ? opinc    : na, "Operatives Ergebnis", color = cOpInc,    linewidth = lw)
plot(eFcf      ? fcf      : na, "Free Cashflow",       color = cFcf,      linewidth = lw)
plot(eOpCf     ? opcf     : na, "Operativer Cashflow", color = cOpCf,     linewidth = lw)
plot(eAssets   ? assets   : na, "Bilanzsumme",         color = cAssets,   linewidth = lw)
plot(eLiab     ? liab     : na, "Verbindlichkeiten",   color = cLiab,     linewidth = lw)
plot(eRnd      ? rnd      : na, "F&E",                  color = cRnd,      linewidth = lw)

// Nulllinie zur Orientierung
hline(0, "Null", color = color.new(color.gray, 60), linestyle = hline.style_dotted)

// ════════════════════════════════════════════════════════════════
//  QUALITÄTS- & DIVIDENDEN-SCORECARD  (Tabelle, zuschaltbar)
//  Aus separatem Indikator übernommen. Hier wird NUR die Tabelle
//  gezeichnet – keine Score-Linie, damit die Finanz-Linien-Skala
//  nicht verändert wird.
// ════════════════════════════════════════════════════════════════
gScore = "Scorecard-Tabelle"
showTable = input.bool(true, "Scorecard-Tabelle anzeigen", group = gScore)
posSel = input.string("Oben rechts", "Tabellenposition", group = gScore,
     options = ["Oben rechts", "Oben links", "Unten rechts", "Unten links"])

// ═══ Hilfsfunktionen ════════════════════════════════════════
qd_avg(float[] arr) =>
    float s = 0.0, int c = 0
    for v in arr
        if not na(v)
            s += v
            c += 1
    c > 0 ? s / c : na

qd_wavg(float[] vals, float[] wts) =>
    float s = 0.0, float w = 0.0
    for i = 0 to array.size(vals) - 1
        v = array.get(vals, i)
        if not na(v)
            s += v * array.get(wts, i)
            w += array.get(wts, i)
    w > 0 ? s / w : na

qd_col(s) => na(s) ? color.gray : s >= 70 ? color.green : s >= 45 ? color.orange : color.red

// ═══ Rohdaten abrufen ═══════════════════════════════════════
roe    = request.financial(syminfo.tickerid, "RETURN_ON_EQUITY",            "FY",  ignore_invalid_symbol = true)
roic   = request.financial(syminfo.tickerid, "RETURN_ON_INVESTED_CAPITAL",  "FY",  ignore_invalid_symbol = true)
de     = request.financial(syminfo.tickerid, "DEBT_TO_EQUITY",              "FQ",  ignore_invalid_symbol = true)
payout = request.financial(syminfo.tickerid, "DIVIDEND_PAYOUT_RATIO",       "FY",  ignore_invalid_symbol = true)
dpsFY  = request.financial(syminfo.tickerid, "DPS_COMMON_STOCK_PRIM_ISSUE", "FY",  ignore_invalid_symbol = true)
qdFcf  = request.financial(syminfo.tickerid, "FREE_CASH_FLOW",              "FY",  ignore_invalid_symbol = true)
qdShares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING",  "FQ",  ignore_invalid_symbol = true)
eps    = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE",          "TTM", ignore_invalid_symbol = true)
bvps   = request.financial(syminfo.tickerid, "BOOK_VALUE_PER_SHARE",        "FQ",  ignore_invalid_symbol = true)

// Normalisierung (manche Feeds liefern Bruch statt Prozent o. umgekehrt)
roe_n  = na(roe)    ? na : (math.abs(roe)  <= 1.5 ? roe  * 100 : roe)
roic_n = na(roic)   ? na : (math.abs(roic) <= 1.5 ? roic * 100 : roic)
de_n   = na(de)     ? na : (de > 10 ? de / 100 : de)
pay_n  = na(payout) ? na : (payout <= 2 ? payout * 100 : payout)

// ═══ Dividendenwachstum (CAGR aus jährlichen DPS-Werten) ════
var float[] dpsHist = array.new_float()
if not na(dpsFY) and (na(dpsFY[1]) or dpsFY != dpsFY[1])
    array.push(dpsHist, dpsFY)
    if array.size(dpsHist) > 6
        array.shift(dpsHist)
float divGrowth = na
if array.size(dpsHist) >= 2
    f = array.get(dpsHist, 0)
    l = array.get(dpsHist, array.size(dpsHist) - 1)
    if f > 0 and l > 0
        divGrowth := (math.pow(l / f, 1.0 / (array.size(dpsHist) - 1)) - 1) * 100

// ═══ Abgeleitete Kennzahlen ═════════════════════════════════
yld      = (not na(dpsFY) and close > 0) ? dpsFY / close * 100 : na
totalDiv = (not na(dpsFY) and not na(qdShares)) ? dpsFY * qdShares : na
fcfPay   = (not na(totalDiv) and not na(qdFcf) and qdFcf > 0) ? totalDiv / qdFcf * 100 : na
kgv      = (not na(eps) and eps > 0)   ? close / eps  : na
kbv      = (not na(bvps) and bvps > 0) ? close / bvps : na

// ═══ Einzel-Scores (0–100) ══════════════════════════════════
sRoe = na(roe_n)  ? na : roe_n  >= 20 ? 100 : roe_n  >= 15 ? 85 : roe_n  >= 10 ? 60 : roe_n  >= 5 ? 35 : roe_n  > 0 ? 15 : 0
sRoic= na(roic_n) ? na : roic_n >= 15 ? 100 : roic_n >= 12 ? 85 : roic_n >= 9  ? 65 : roic_n >= 6 ? 40 : roic_n > 0 ? 15 : 0
sDe  = na(de_n)   ? na : de_n < 0.3 ? 100 : de_n < 0.5 ? 85 : de_n < 0.75 ? 70 : de_n < 1.0 ? 55 : de_n < 1.5 ? 35 : de_n < 2.0 ? 20 : 5
sYld = na(yld)    ? na : yld <= 0 ? 0 : yld < 1 ? 30 : yld < 2 ? 55 : yld <= 4 ? 100 : yld <= 6 ? 80 : 60
sPay = na(pay_n)  ? na : pay_n <= 0 ? 0 : pay_n < 20 ? 50 : pay_n <= 60 ? 100 : pay_n <= 75 ? 80 : pay_n <= 90 ? 50 : 20
sGro = na(divGrowth) ? na : divGrowth >= 10 ? 100 : divGrowth >= 7 ? 85 : divGrowth >= 5 ? 70 : divGrowth >= 2 ? 50 : divGrowth > 0 ? 35 : divGrowth == 0 ? 15 : 0
sKgv = na(kgv) ? (na(eps) ? na : 0) : kgv < 12 ? 100 : kgv < 16 ? 85 : kgv < 20 ? 70 : kgv < 25 ? 50 : kgv < 30 ? 30 : kgv < 40 ? 15 : 5
sKbv = na(kbv) ? na : kbv < 1.5 ? 100 : kbv < 2.5 ? 85 : kbv < 3.5 ? 65 : kbv < 5 ? 45 : kbv < 8 ? 25 : 10

// FCF-Deckung gesondert (negativer FCF bei Dividende = Warnsignal)
float sFcf = na
if not na(totalDiv) and not na(qdFcf)
    sFcf := qdFcf <= 0 ? (totalDiv > 0 ? 5 : 50) : fcfPay < 50 ? 100 : fcfPay < 70 ? 85 : fcfPay < 85 ? 65 : fcfPay < 100 ? 40 : 15

// ═══ Säulen + gewichteter Gesamt-Score ══════════════════════
qual = qd_avg(array.from(sRoe, sRoic))
safe = sDe
divp = qd_avg(array.from(sYld, sPay, sFcf, sGro))
valu = qd_avg(array.from(sKgv, sKbv))
totScore = qd_wavg(array.from(qual, safe, divp, valu), array.from(0.25, 0.15, 0.35, 0.25))

// ═══ Tabelle ════════════════════════════════════════════════
pos = posSel == "Oben rechts" ? position.top_right : posSel == "Oben links" ? position.top_left : posSel == "Unten rechts" ? position.bottom_right : position.bottom_left

var table t = table.new(pos, 3, 11, border_width = 1, border_color = color.gray)
qd_row(_t, _r, _label, _valTxt, _score) =>
    table.cell(_t, 0, _r, _label,  text_size = size.small, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(_t, 1, _r, _valTxt, text_size = size.small, text_color = color.white, bgcolor = color.new(color.gray, 70))
    table.cell(_t, 2, _r, na(_score) ? "n/v" : str.tostring(_score, "#"), text_size = size.small, text_color = color.white, bgcolor = color.new(qd_col(_score), 30))

if barstate.islast and showTable
    table.cell(t, 0, 0, "Kennzahl", text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)
    table.cell(t, 1, 0, "Wert",     text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)
    table.cell(t, 2, 0, "Score",    text_color = color.white, bgcolor = color.new(color.blue, 30), text_size = size.small)
    qd_row(t, 1, "ROE",          na(roe_n)  ? "n/v" : str.tostring(roe_n, "#.#")  + "%", sRoe)
    qd_row(t, 2, "ROIC",         na(roic_n) ? "n/v" : str.tostring(roic_n,"#.#")  + "%", sRoic)
    qd_row(t, 3, "Verschuld. D/E", na(de_n) ? "n/v" : str.tostring(de_n, "#.##"),        sDe)
    qd_row(t, 4, "Div.-Rendite", na(yld)    ? "n/v" : str.tostring(yld, "#.##")   + "%", sYld)
    qd_row(t, 5, "Payout (Gew.)",na(pay_n)  ? "n/v" : str.tostring(pay_n,"#.#")   + "%", sPay)
    qd_row(t, 6, "FCF-Deckung",  na(fcfPay) ? "n/v" : str.tostring(fcfPay,"#.#")  + "%", sFcf)
    qd_row(t, 7, "Div.-Wachstum",na(divGrowth)? "n/v":str.tostring(divGrowth,"#.#")+"%", sGro)
    qd_row(t, 8, "KGV",          na(kgv)    ? "n/v" : str.tostring(kgv, "#.#"),          sKgv)
    qd_row(t, 9, "KBV",          na(kbv)    ? "n/v" : str.tostring(kbv, "#.##"),         sKbv)
    table.cell(t, 0, 10, "GESAMT", text_color = color.white, bgcolor = color.new(color.blue, 10), text_size = size.normal)
    table.cell(t, 1, 10, "/100",   text_color = color.white, bgcolor = color.new(color.blue, 10), text_size = size.normal)
    table.cell(t, 2, 10, na(totScore) ? "n/v" : str.tostring(totScore,"#"), text_color = color.white, bgcolor = color.new(qd_col(totScore), 10), text_size = size.normal)
````
