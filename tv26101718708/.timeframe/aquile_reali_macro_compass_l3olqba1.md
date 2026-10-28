# Aquile Reali Macro Compass

- url: https://www.tradingview.com/script/L3oLqbA1/
- type: indicator
- pine_id: PUB;04bcdb3c1f5f443ba783055fca717ec9
- version: 3.0

## Description

AQUILE REALI MACRO COMPASS

Available in English and Italian: switch with the "Language / Lingua" option.
Disponibile in inglese e italiano: cambia lingua con l'opzione "Language / Lingua".

WHAT IT DOES
Gold does not move alone. It reacts to the US dollar, to interest rates and, above all, to real yields. This indicator puts the main macro drivers of gold under your chart, aligned on the same time scale, and summarizes them in a single "compass" that tells you whether the macro backdrop is bullish, bearish or mixed for gold on every timeframe from 1 hour to monthly.

THE COMPASS LOGIC
The compass compares two instruments:
- TIP (iShares TIPS Bond ETF), used as a real-time proxy of US real yields. TIP up = real yields down.
- DXY, the US Dollar Index.

Rules:
- TIP up + DXY down = BULLISH gold (real yields and dollar both easing)
- TIP down + DXY up = BEARISH gold (real yields and dollar both rising)
- Any other combination = MIXED signal (the two drivers disagree, no clean macro read)

Direction is measured as the change over the last N bars (default 3, adjustable). On intraday charts the compass updates only during US cash hours, because TIP does not trade outside them.

The dashboard shows the compass state on 1H, 4H, 8H, 12H, D, W and M at the same time, so you can see immediately where timeframes agree. It reads the same on any chart timeframe.

AVAILABLE PANELS
Add the indicator once per pane and choose a different panel each time:
- DXY – Dollar Index
- Yield Curve 10Y-2Y – the spread between the 10-year and 2-year Treasury yields. A falling curve means the 2-year is rising faster than the 10-year, i.e. the market is pricing Fed hikes. Below zero = inversion.
- TIP – Real Yield Proxy
- US10Y + US02Y – both yields in one pane, to see which one moves faster
- WTI Crude Oil – continuous contract, as oil feeds inflation expectations and yields
- DFII10 – the official 10-year real yield (daily data only, not suitable for intraday)
- Custom – any symbol, as a single line, two lines or a spread

Each panel shows a large label with the symbol name and last value, in the color of its line, plus a short description of how to read it (can be hidden).

LANGUAGE
On-chart text (titles, descriptions, compass and alert messages) is available in English or Italian: choose it with the "Language / Lingua" option. Settings menus are in English.

HOW TO SET IT UP
1. Open a gold chart (futures or spot).
2. Add the indicator five times and select DXY, Yield Curve 10Y-2Y, TIP, US10Y + US02Y and WTI Crude Oil.
3. In ONE pane only (for example DXY), enable "This is the main panel". The compass line and the multi-timeframe dashboard appear there, and that pane sends the alerts.
4. Save the layout.

ALERTS
Create one alert on the indicator with the condition "Any alert() function call". It covers:
- Compass state changes. With the higher-trend filter enabled (default: weekly), you are notified only when the signal on your chart timeframe agrees with the higher trend, plus whenever the higher trend itself changes.
- Sharp moves in the 2-year yield (default 10 basis points in one bar), typical after inflation and jobs data.
- The 10Y-2Y yield curve crossing zero.
- Price levels on DXY, US10Y, WTI and your chart symbol. The default values are the author's key levels for Micro Gold futures (MGC) at the time of publication: replace them with your own levels, or set a value to 0 to disable it.
Tip: create the alert on a 1H chart. On a weekly chart it would only trigger once a week.

TECHNICAL NOTE
Gold futures bars close at 17:00 New York time, while yield and dollar index bars run midnight to midnight. Requested on the same timeframe, the last yield bar of the week would close after the futures bar and would be skipped, showing the previous day's value. The script therefore reads a lower timeframe (4H on weekly, 1H on daily and intraday above 1H), so the values shown match the real closing values.

LIMITATIONS
- TIP is a bond ETF and only an approximation of real yields.
- The compass is a macro filter, not an entry signal. Use it to decide which direction to favor, and use your own price action for timing.
- Outside US cash hours TIP is flat, so intraday compass readings refer to the last US session.
- Intermarket relationships can weaken for periods of time, for example when geopolitical flows or central bank buying dominate.

This script is for educational purposes and is not financial advice.

──────────────

🇮🇹 ITALIANO

Lo script è disponibile anche in italiano: nelle impostazioni, alla voce "Language / Lingua", scegli "Italiano".

L'oro non si muove da solo: reagisce al dollaro, ai tassi e soprattutto ai rendimenti reali. Questo indicatore mette sotto il grafico i principali fattori macro dell'oro, allineati sulla stessa scala temporale, e li riassume in una "bussola" che indica se il quadro macro è rialzista, ribassista o misto per l'oro su ogni timeframe, dall'1 ora al mensile.

La bussola confronta TIP (proxy in tempo reale dei rendimenti reali USA) e DXY (indice del dollaro):
- TIP su + DXY giù = RIALZISTA per l'oro
- TIP giù + DXY su = RIBASSISTA per l'oro
- Qualsiasi altra combinazione = segnale MISTO, nessuna lettura pulita

Pannelli disponibili: DXY, Curva 10Y-2Y, TIP, US10Y + US02Y, WTI, DFII10 e Personalizzato. Aggiungi l'indicatore una volta per pannello e attiva "This is the main panel" in uno solo: lì compaiono la bussola multi-timeframe e partono gli alert.

Scritte sul grafico e messaggi degli alert disponibili in inglese o italiano: scegli la lingua con l'opzione "Language / Lingua". I menu delle impostazioni sono in inglese.

I livelli degli alert preimpostati sono quelli dell'autore su MGC al momento della pubblicazione: sostituiscili con i tuoi, oppure metti 0 per disattivarli.

La bussola è un filtro macro, non un segnale d'ingresso. Contenuto a scopo educativo, non è una consulenza finanziaria.

Nate per volare, nate per osare · Be Stable. Be Strong. 🦅

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © giua64 — Aquile Reali
//@version=6
indicator("Aquile Reali Macro Compass", shorttitle = "AR Compass", overlay = false, precision = 3)

// ═══════════════════════════════════════════════════════════
// PANEL SELECTION
// Add the indicator once per pane and pick a different panel each time.
// Suggested layout under a gold chart: DXY · Yield Curve · TIP · US10Y + US02Y · WTI
// ═══════════════════════════════════════════════════════════
lang  = input.string("English", "Language / Lingua", options = ["English", "Italiano"])
isIT  = lang == "Italiano"
tr(string en, string itx) => isIT ? itx : en

panel = input.string("DXY", "Panel",
     options = ["DXY", "Yield Curve 10Y-2Y", "TIP", "US10Y + US02Y", "WTI Crude Oil", "DFII10 (daily data)", "Custom"])

// ─── Line colors ──────────────────────────────────────────
gC      = "Line colors"
cDXY    = input.color(#00897B, "DXY", group = gC)
cCurve  = input.color(#9C27B0, "Yield Curve 10Y-2Y", group = gC)
cTIP    = input.color(#42A5F5, "TIP", group = gC)
c10Y    = input.color(#E53935, "US10Y", group = gC)
c02Y    = input.color(#FB8C00, "US02Y", group = gC)
cWTI    = input.color(#212121, "WTI Crude Oil", group = gC)
cDFII   = input.color(#6D4C41, "DFII10", group = gC)
cCustA  = input.color(#1848CC, "Custom – line A", group = gC)
cCustB  = input.color(#D4A017, "Custom – line B", group = gC)
colZero = input.color(color.new(color.gray, 40), "Zero line", group = gC)
colTxt  = input.color(color.gray, "Label text", group = gC)

// ─── Style ────────────────────────────────────────────────
gS       = "Style"
lineW    = input.int(2, "Line width", minval = 1, maxval = 4, group = gS)
showZero = input.bool(true, "Show zero line (Yield Curve)", group = gS)
showScl  = input.bool(false, "Show labels on price scale", group = gS)
showDesc = input.bool(true, "Show description under the title", group = gS)
colDesc  = input.color(color.gray, "Description color", group = gS)
showChg  = input.bool(true, "Show daily change next to the name", group = gS,
     tooltip = "Daily % change vs the previous daily close. Spread panels (yield curve) in basis points.")
colUp    = input.color(#26A69A, "Daily change – up", group = gS)
colDn    = input.color(#EF5350, "Daily change – down", group = gS)
dispPlot = showScl ? display.all : display.pane + display.data_window + display.status_line

// ─── Custom panel ─────────────────────────────────────────
gU      = "Custom panel"
uTitle  = input.string("Custom", "Title", group = gU)
uMode   = input.string("Single line", "Mode", options = ["Single line", "Two lines", "Spread A - B"], group = gU)
uSymA   = input.symbol("TVC:GOLD", "Symbol A", group = gU)
uSymB   = input.symbol("TVC:US02Y", "Symbol B", group = gU)
uDesc   = input.string("", "Description", group = gU)

// ─── Presets ──────────────────────────────────────────────
title = switch panel
    "DXY"                 => tr("DXY – Dollar Index", "DXY – Indice del dollaro")
    "Yield Curve 10Y-2Y"  => tr("Yield Curve 10Y-2Y", "Curva dei rendimenti 10Y-2Y")
    "TIP"                 => tr("TIP – Real Yield Proxy", "TIP – Proxy rendimenti reali")
    "US10Y + US02Y"       => "US10Y / US02Y"
    "WTI Crude Oil"       => tr("WTI – Crude Oil", "WTI – Petrolio")
    "DFII10 (daily data)" => tr("Real 10Y Yield (DFII10)", "Rendimento reale 10Y (DFII10)")
    => uTitle

mode = switch panel
    "Yield Curve 10Y-2Y" => "Spread A - B"
    "US10Y + US02Y"      => "Two lines"
    "Custom"             => uMode
    => "Single line"

symA = switch panel
    "DXY"                 => "TVC:DXY"
    "Yield Curve 10Y-2Y"  => "TVC:US10Y"
    "TIP"                 => "AMEX:TIP"
    "US10Y + US02Y"       => "TVC:US10Y"
    "WTI Crude Oil"       => "NYMEX:CL1!"
    "DFII10 (daily data)" => "FRED:DFII10"
    => uSymA

symB = switch panel
    "Yield Curve 10Y-2Y" => "TVC:US02Y"
    "US10Y + US02Y"      => "TVC:US02Y"
    => uSymB

colA = switch panel
    "DXY"                 => cDXY
    "Yield Curve 10Y-2Y"  => cCurve
    "TIP"                 => cTIP
    "US10Y + US02Y"       => c10Y
    "WTI Crude Oil"       => cWTI
    "DFII10 (daily data)" => cDFII
    => cCustA

colB = panel == "US10Y + US02Y" ? c02Y : cCustB

desc = switch panel
    "DXY"                 => tr("Dollar up = gold down  ·  Dollar down = gold up", "Dollaro su = oro giù  ·  Dollaro giù = oro su")
    "Yield Curve 10Y-2Y"  => tr("10Y minus 2Y  ·  Falling = market prices Fed hikes  ·  Rising = cuts or long-end stress  ·  Below 0 = recession warning", "Distanza 10Y−2Y  ·  Scende = mercato prezza rialzi Fed  ·  Sale = tagli o paura sul lungo  ·  Sotto 0 = segnale recessione")
    "TIP"                 => tr("TIP up = real yields down = gold up  ·  TIP down = gold down  ·  Moves only during US cash hours", "TIP su = rendimenti reali giù = oro su  ·  TIP giù = oro giù  ·  Si muove solo 15:30–22:00")
    "US10Y + US02Y"       => tr("Rate levels  ·  Rising rates = pressure on gold  ·  2Y rising faster than 10Y = Fed hike expectations", "Livello dei tassi  ·  Tassi su = oro sotto pressione  ·  2Y più veloce del 10Y = attese di rialzi Fed")
    "WTI Crude Oil"       => tr("Oil up = inflation expectations up = yields up = gold down", "Petrolio su = inflazione attesa su = rendimenti su = oro giù")
    "DFII10 (daily data)" => tr("Real yield up = gold down  ·  Daily data, do not use intraday", "Rendimento reale su = oro giù  ·  Dato giornaliero, non usarlo intraday")
    => uDesc

// ═══════════════════════════════════════════════════════════
// DATA
// Futures bars (e.g. COMEX gold) close at 17:00 New York, while TVC yield and
// dollar bars run midnight to midnight: the last TVC bar of the period closes
// AFTER the chart bar and would be skipped. A lower timeframe is requested so
// its bars fit inside the chart bar and the real last value is used.
// ═══════════════════════════════════════════════════════════
tfReq = timeframe.ismonthly ? "D" : timeframe.isweekly ? "240" : timeframe.isdaily ? "60" : timeframe.in_seconds() > 3600 ? "60" : timeframe.period
// FRED series (e.g. DFII10) only have daily data: requesting them intraday returns NaN
tfFor(string s) => str.startswith(s, "FRED:") ? "D" : tfReq
a = request.security(symA, tfFor(symA), close, ignore_invalid_symbol = true)
b = request.security(symB, tfFor(symB), close, ignore_invalid_symbol = true)

isSpread = mode == "Spread A - B"
isTwo    = mode == "Two lines"
valA = isSpread ? a - b : a
valB = isTwo ? b : na

plot(valA, "Value", color = colA, linewidth = lineW, display = dispPlot)
plot(valB, "Value 2", color = colB, linewidth = lineW, display = dispPlot)
plot(isSpread and showZero ? 0.0 : na, "Zero", color = colZero, linewidth = 1, display = dispPlot)

// ═══════════════════════════════════════════════════════════
// DAILY CHANGE
// Current daily close vs previous daily close, same result on any chart timeframe.
// Yields and spreads: basis points. Prices/indices: points and %.
// ═══════════════════════════════════════════════════════════
[dA, dA1] = request.security(symA, "D", [close, close[1]], ignore_invalid_symbol = true)
[dB, dB1] = request.security(symB, "D", [close, close[1]], ignore_invalid_symbol = true)

isRate(string s) => str.match(s, "[A-Z]{2}\\d{2}Y") != "" or str.contains(s, "DFII")

rateA  = isSpread ? isRate(symA) and isRate(symB) : isRate(symA)
rateB  = isRate(symB)
chgA   = isSpread ? (dA - dB) - (dA1 - dB1) : dA - dA1
prevA  = isSpread ? na : dA1
chgB   = dB - dB1

// Daily % change. Spread (e.g. yield curve): % is meaningless near zero, so basis points.
chgTxt(float d, float prev, bool rate) =>
    string out = ""
    if not na(d)
        sgn = d > 0 ? "+" : ""
        out := (d > 0 ? "▲ " : d < 0 ? "▼ " : "■ ")
        if not na(prev) and prev != 0
            out += sgn + str.tostring(d / prev * 100, "#.##") + "%"
        else if rate
            out += sgn + str.tostring(d * 100, "#.#") + tr(" bp", " pb")
        else
            out += sgn + str.tostring(d, "#.###")
    out

chgCol(float d) => na(d) or d == 0 ? colTxt : d > 0 ? colUp : colDn

// ═══════════════════════════════════════════════════════════
// MAIN PANEL: COMPASS DASHBOARD + ALERTS
// Enable in ONE pane only, otherwise alerts are duplicated.
// ═══════════════════════════════════════════════════════════
gM       = "Main panel: compass + alerts (enable in ONE pane only)"
isMain   = input.bool(false, "This is the main panel (compass dashboard + alerts)", group = gM)
nConf    = input.int(3, "Lookback bars for direction", minval = 1, maxval = 20, group = gM)
dashPos  = input.string("Bottom right", "Dashboard position", options = ["Bottom right", "Bottom left", "Top left"], group = gM)
dashSize = input.string("Medium", "Dashboard size", options = ["Small", "Medium", "Large"], group = gM)
szDash   = dashSize == "Small" ? size.small : dashSize == "Medium" ? size.normal : size.large

gAl       = "Alerts"
aCompass  = input.bool(true, "Compass state change (TIP vs DXY)", group = gAl)
useFilter = input.bool(true, "Compass alerts only in the direction of the higher trend", group = gAl)
tfFilter  = input.timeframe("W", "Higher trend timeframe", group = gAl)
aSpike    = input.bool(true, "Sharp US02Y move", group = gAl)
spikeMult = input.float(2.5, "US02Y: x times its normal move per bar", minval = 1, step = 0.25, group = gAl,
     tooltip = "Adaptive threshold: fires when the US02Y moves at least N times its normal per-bar move (last 100 bars). Works on any timeframe.")
spikeMin  = input.float(1.0, "US02Y: minimum move (basis points)", minval = 0.1, step = 0.1, group = gAl,
     tooltip = "No adaptive alert below this move, to avoid noise in very flat markets.")
spikeBp   = input.float(10, "US02Y: fires anyway above (basis points per bar)", minval = 1, group = gAl)
aCurve    = input.bool(true, "Yield curve crossing zero", group = gAl)

gL      = "Level alerts (0 = disabled)"
dxyUp   = input.float(0.0, "DXY above", group = gL)
dxyDn   = input.float(0.0, "DXY below", group = gL)
y10Up   = input.float(0.0, "US10Y above", group = gL)
y10Dn   = input.float(0.0, "US10Y below", group = gL)
wtiUp   = input.float(0.0, "WTI above", group = gL)
wtiDn   = input.float(0.0, "WTI below", group = gL)
pxUp    = input.float(0.0, "Chart price above", group = gL)
pxDn    = input.float(0.0, "Chart price below", group = gL)

dxy = request.security("TVC:DXY",    tfReq, close, ignore_invalid_symbol = true)
tip = request.security("AMEX:TIP",   tfReq, close, ignore_invalid_symbol = true)
y10 = request.security("TVC:US10Y",  tfReq, close, ignore_invalid_symbol = true)
y02 = request.security("TVC:US02Y",  tfReq, close, ignore_invalid_symbol = true)
wti = request.security("NYMEX:CL1!", tfReq, close, ignore_invalid_symbol = true)
curve = y10 - y02

// TIP only moves during US cash hours: on intraday charts the compass is updated only then
tipLive = not timeframe.isintraday or not na(time(timeframe.period, "0930-1600", "America/New_York"))

// Compass state: +1 bullish gold, -1 bearish gold, 0 mixed signal (no trade)
cTip = ta.change(tip, nConf)
cDxy = ta.change(dxy, nConf)
newState = cTip > 0 and cDxy < 0 ? 1 : cTip < 0 and cDxy > 0 ? -1 : 0
var int state = 0
var int stateTime = na
if tipLive and not na(newState)
    state := newState
    stateTime := time_close
stateChanged = state != state[1]

stateTF(simple string tf) =>
    ct = request.security("AMEX:TIP", tf, ta.change(close, nConf), ignore_invalid_symbol = true)
    cd = request.security("TVC:DXY",  tf, ta.change(close, nConf), ignore_invalid_symbol = true)
    ct > 0 and cd < 0 ? 1 : ct < 0 and cd > 0 ? -1 : 0

s15  = stateTF("15")
s1H  = stateTF("60")
s4H  = stateTF("240")
s8H  = stateTF("480")
s12H = stateTF("720")
sD   = stateTF("D")
sW   = stateTF("W")
sM   = stateTF("M")
sFilter = stateTF(tfFilter)
filterChanged = sFilter != sFilter[1]

// TIP open right now? (NYSE cash session, Mon-Fri 09:30-16:00 New York; US holidays not handled)
tNow   = barstate.islast ? timenow : time
tzNY   = "America/New_York"
tzShow = isIT ? "Europe/Rome" : tzNY
minNY  = hour(tNow, tzNY) * 60 + minute(tNow, tzNY)
dowNY  = dayofweek(tNow, tzNY)
wkday  = dowNY >= dayofweek.monday and dowNY <= dayofweek.friday
tipOpen = wkday and minNY >= 570 and minNY < 960
int k = wkday and minNY < 570 ? 0 : 1
for i = 0 to 3
    dw = dayofweek(tNow + k * 86400000, tzNY)
    if dw == dayofweek.saturday or dw == dayofweek.sunday
        k += 1
tNext  = tNow + k * 86400000
tReopen = timestamp(tzNY, year(tNext, tzNY), month(tNext, tzNY), dayofmonth(tNext, tzNY), 9, 30)
tzLbl  = isIT ? "" : " NY"
closedTxt = tr("TIP closed · reopens ", "TIP chiuso · riapre ") + str.format_time(tReopen, "dd/MM HH:mm", tzShow) + tzLbl
asOfTxt   = na(stateTime) ? "" : tr(" · as of ", " · dato delle ") + str.format_time(stateTime, "dd/MM HH:mm", tzShow) + tzLbl

stateName(s)  => s == 1 ? tr("BULLISH gold", "LONG oro") : s == -1 ? tr("BEARISH gold", "SHORT oro") : tr("mixed signal", "segnale sporco")
stateShort(s) => s == 1 ? tr("BULL", "LONG") : s == -1 ? tr("BEAR", "SHORT") : tr("mixed", "sporco")
stateEmoji(s) => s == 1 ? "🟢" : s == -1 ? "🔴" : "⚪"
stateColor(s) => s == 1 ? #26A69A : s == -1 ? #EF5350 : #9E9E9E

fmt(x)   => str.tostring(x, "#.###")
arrow(x) => x > 0 ? " ↑" : x < 0 ? " ↓" : " →"

// Crossings computed on every bar, then enabled only if the level is not 0
cxDxyUp = ta.crossover(dxy, dxyUp)
cxDxyDn = ta.crossunder(dxy, dxyDn)
cxY10Up = ta.crossover(y10, y10Up)
cxY10Dn = ta.crossunder(y10, y10Dn)
cxWtiUp = ta.crossover(wti, wtiUp)
cxWtiDn = ta.crossunder(wti, wtiDn)
cxPxUp  = ta.crossover(close, pxUp)
cxPxDn  = ta.crossunder(close, pxDn)
xDxyUp = dxyUp > 0 and cxDxyUp
xDxyDn = dxyDn > 0 and cxDxyDn
xY10Up = y10Up > 0 and cxY10Up
xY10Dn = y10Dn > 0 and cxY10Dn
xWtiUp = wtiUp > 0 and cxWtiUp
xWtiDn = wtiDn > 0 and cxWtiDn
xPxUp  = pxUp > 0 and cxPxUp
xPxDn  = pxDn > 0 and cxPxDn
xCurDn = ta.crossunder(curve, 0)
xCurUp = ta.crossover(curve, 0)
bp02   = (y02 - y02[1]) * 100
sd02   = ta.stdev(bp02, 100)
z02    = na(sd02) or sd02 == 0 ? na : bp02 / sd02
spike02 = not na(bp02) and (math.abs(bp02) >= spikeBp or (not na(z02) and math.abs(z02) >= spikeMult and math.abs(bp02) >= spikeMin))

msg = ""
if aCompass and useFilter and filterChanged
    msg += "🧭 " + tfFilter + tr(" trend changed: ", " trend cambia: ") + stateEmoji(sFilter) + " " + stateName(sFilter) + "\n"
okFilter = not useFilter or (state != 0 and state == sFilter)
if aCompass and stateChanged and okFilter
    msg += stateEmoji(state) + tr(" Compass ", " Bussola ") + stateName(state) + " (" + timeframe.period + (useFilter ? tr(", with the ", ", a favore del trend ") + tfFilter + tr(" trend", "") : "") + ")"
    msg += " | DXY " + fmt(dxy) + arrow(cDxy) + " / TIP " + fmt(tip) + arrow(cTip) + "\n"
if xDxyUp
    msg += tr("⚠️ DXY above ", "⚠️ DXY sopra ") + fmt(dxyUp) + " (" + fmt(dxy) + ")\n"
if xDxyDn
    msg += tr("⚠️ DXY below ", "⚠️ DXY sotto ") + fmt(dxyDn) + " (" + fmt(dxy) + ")\n"
if xY10Up
    msg += tr("⚠️ US10Y above ", "⚠️ US10Y sopra ") + fmt(y10Up) + "% (" + fmt(y10) + ")\n"
if xY10Dn
    msg += tr("⚠️ US10Y below ", "⚠️ US10Y sotto ") + fmt(y10Dn) + "% (" + fmt(y10) + ")\n"
if xWtiUp
    msg += tr("🛢️ WTI above ", "🛢️ WTI sopra ") + fmt(wtiUp) + " (" + fmt(wti) + ")\n"
if xWtiDn
    msg += tr("🛢️ WTI below ", "🛢️ WTI sotto ") + fmt(wtiDn) + " (" + fmt(wti) + ")\n"
if xPxUp
    msg += "⚠️ " + syminfo.ticker + tr(" above ", " sopra ") + fmt(pxUp) + " (" + fmt(close) + ")\n"
if xPxDn
    msg += "⚠️ " + syminfo.ticker + tr(" below ", " sotto ") + fmt(pxDn) + " (" + fmt(close) + ")\n"
if aSpike and spike02
    msg += "⚡ US02Y " + (bp02 > 0 ? "+" : "") + str.tostring(bp02, "#.#") + tr(" bp in one bar", " pb in una barra") + (na(z02) ? "" : " (" + str.tostring(math.abs(z02), "#.#") + tr("x normal", "x il normale") + ")") + " · " + fmt(y02) + (bp02 > 0 ? tr(" · against gold", " · contro oro") : tr(" · supports gold", " · pro oro")) + "\n"
if aCurve and xCurDn
    msg += tr("🔻 Yield curve 10Y-2Y INVERTED (", "🔻 Curva 10Y-2Y INVERTITA (") + fmt(curve) + ")\n"
if aCurve and xCurUp
    msg += tr("🔺 Yield curve 10Y-2Y back above zero (", "🔺 Curva 10Y-2Y tornata positiva (") + fmt(curve) + ")\n"

if isMain and msg != ""
    alert(msg, alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════
// LABELS
// Row 0: name + value | daily change  [| name B + value | daily change B]
// Rows 1-2 are merged across all used columns.
// ═══════════════════════════════════════════════════════════
nameA = panel == "US10Y + US02Y" ? "US10Y" : title
nameB = panel == "US10Y + US02Y" ? "US02Y" : uTitle + " B"
clear = color.new(color.black, 100)
chgTip = tr("Change vs previous daily close", "Variazione rispetto alla chiusura del giorno precedente")

var table tb = table.new(position.top_center, 4, 3)
varip bool merged1 = false
varip bool merged2 = false
nCols = isTwo ? 4 : 2
if barstate.islast
    table.cell(tb, 0, 0, nameA + "  " + fmt(valA), text_color = colA, text_size = size.large, bgcolor = clear, tooltip = desc)
    table.cell(tb, 1, 0, showChg ? "  " + chgTxt(chgA, prevA, rateA) : "", text_color = chgCol(chgA), text_size = size.large, bgcolor = clear, tooltip = chgTip)
    if isTwo
        table.cell(tb, 2, 0, "     " + nameB + "  " + fmt(valB), text_color = colB, text_size = size.large, bgcolor = clear, tooltip = desc)
        table.cell(tb, 3, 0, showChg ? "  " + chgTxt(chgB, dB1, rateB) : "", text_color = chgCol(chgB), text_size = size.large, bgcolor = clear, tooltip = chgTip)
    if isMain
        staleTxt = timeframe.isintraday and not tipOpen ? "  (" + closedTxt + asOfTxt + ")" : ""
        table.cell(tb, 0, 1, stateEmoji(state) + tr(" Compass ", " Bussola ") + timeframe.period + ": " + stateName(state) + staleTxt, text_color = colTxt, text_size = szDash, bgcolor = clear)
        for c = 1 to nCols - 1
            table.cell(tb, c, 1, "", bgcolor = clear)
        if not merged1
            table.merge_cells(tb, 0, 1, nCols - 1, 1)
            merged1 := true
    if showDesc and desc != ""
        table.cell(tb, 0, 2, desc, text_color = colDesc, text_size = size.small, bgcolor = clear)
        for c = 1 to nCols - 1
            table.cell(tb, c, 2, "", bgcolor = clear)
        if not merged2
            table.merge_cells(tb, 0, 2, nCols - 1, 2)
            merged2 := true

posD = dashPos == "Bottom right" ? position.bottom_right : dashPos == "Bottom left" ? position.bottom_left : position.top_left
varip bool dashMerged = false
var table dash = table.new(posD, 9, 3, border_width = 1, border_color = color.new(color.gray, 70))
if barstate.islast and isMain
    tfs = array.from("15m", "1H", "4H", "8H", "12H", "D", "W", "M")
    sts = array.from(s15, s1H, s4H, s8H, s12H, sD, sW, sM)
    table.cell(dash, 0, 0, "🧭", text_color = colTxt, text_size = szDash, bgcolor = clear)
    table.cell(dash, 0, 1, tr("Compass", "Bussola"), text_color = colTxt, text_size = szDash, bgcolor = clear)
    for i = 0 to 7
        s = array.get(sts, i)
        // intraday cells (15m-12H) are dimmed while TIP is closed: last session value, not live
        stale = not tipOpen and i <= 4
        table.cell(dash, i + 1, 0, array.get(tfs, i), text_color = colTxt, text_size = szDash, bgcolor = clear)
        table.cell(dash, i + 1, 1, stateShort(s), text_color = color.white, text_size = szDash, bgcolor = stale ? color.new(stateColor(s), 65) : stateColor(s))
    if not tipOpen
        table.cell(dash, 0, 2, closedTxt + tr(" · faded = last session", " · sbiadito = ultima seduta"), text_color = colTxt, text_size = size.small, bgcolor = clear)
        if not dashMerged
            table.merge_cells(dash, 0, 2, 8, 2)
            dashMerged := true
    else
        table.cell(dash, 0, 2, "", bgcolor = clear)
````
