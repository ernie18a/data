<!-- tradingview-pine-id: PUB;39462d3f21cf4ac6a87829b630dca978 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Macro HUD

Source: https://www.tradingview.com/script/zKSXWFbB-Macro-HUD/

## Description

Macro HUD is an on-chart panel that shows the macro context around the instrument you are trading, so you can read price with the broader backdrop in view rather than in isolation.

Most indicators transform the price already on your chart into another form of the same price. Macro HUD does something different: it reads a set of other markets and presents their current state as context on a single panel, so you do not have to open several extra charts or an economic calendar to see the wider picture. It is a context dashboard, not a signal generator.

What it shows
The panel has four sections:

[*]Macro engine — the US Dollar Index (DXY), the US 10-year and 2-year Treasury yields, crude oil, and the VIX. Each row shows its current value and a direction arrow measured over a lookback you set. The VIX row adds a volatility-regime band: Calm, Normal, Stressed, or Panic.
[*]Regime — two plain-language reads derived from the rows above: a dollar read (bid or offered, from its recent direction) and a risk read (risk-on, risk-off, or mixed, from a chosen index's trend together with the VIX band).
[*]Watchlist — up to five instruments of your choice, each labelled Bull or Bear depending on whether its price sits above or below a moving average, so you can see the directional state of a whole basket at a glance.
[*]Event — an optional manual countdown to your next key economic releases. You enter the events yourself; the panel displays whichever is soonest and turns red inside a stand-down window you define.

How it works
Every value in the panel is requested from another symbol on a timeframe you choose (Daily by default) using request.security. The direction arrows compare the current value to the value a set number of bars earlier. The VIX band and the dollar and risk reads are simple threshold and trend rules applied to those requested values — the band uses fixed volatility thresholds, and the risk read combines an index's position relative to its moving average with the VIX band. The watchlist Bull/Bear flags compare each requested symbol's price to an EMA of its own price. The event countdown compares the current time to the timestamps you enter and shows the nearest upcoming one. Nothing in the panel is predictive; it reports the current state of external data.

Why it is original, and why these parts are combined
Macro HUD is not a single built-in republished, and it is not a mashup of overlapping signals. Each component answers a different question, and they are gathered together because a discretionary trader usually needs all of them at once before acting:

[*]The macro engine answers "what is the broad backdrop?" — the dollar, rates, oil, and volatility.
[*]The regime rows condense that backdrop into a plain read that can be absorbed at a glance.
[*]The watchlist answers "what state is my basket in right now?" across several instruments without switching charts.
[*]The event row answers "is it safe to act, or is a major release imminent?" — the one piece Pine cannot source on its own.

The purpose of the combination is to assemble, on one panel, the external context a trader would otherwise gather from several separate windows plus an economic calendar. No component duplicates another; each covers a distinct part of the question "should I be looking at this market now, and with what lean?" That specific, purpose-built combination is what the script contributes.

How to use it
Add it to any chart. Open the settings and point the macro and watchlist symbols at instruments your data plan supports, set the read timeframe (Daily gives the broad regime regardless of your chart timeframe), and choose the EMA length used for the Bull/Bear flags. If you follow economic events, type your next few releases into the event slots. The panel then updates live. Panel text colour is theme-aware by default and can be forced to black or white.

Limitations and things to be aware of

[*]Pine cannot read the economic calendar or news, so the event slots are filled in by hand. If you do not maintain them, the event row simply shows that no event is set.
[*]The direction arrows show short-term direction over your chosen lookback, not the absolute level. A market can show a down arrow while still being historically high, so read the arrow as recent drift, not position.
[*]The regime reads are deliberately simple threshold and trend rules, not a proprietary model. They are a quick summary, not a forecast.
[*]Some symbols (DXY, yields, VIX) depend on your TradingView data plan. If a row shows "n/a", open the settings and replace that symbol with one your plan provides. The script handles missing symbols without failing.
[*]All values reflect the chosen read timeframe and update on that basis.

Scope
Macro HUD assembles context. It does not generate buy or sell signals, predict direction, or tell you what to do, and it makes no performance claims. The interpretation and every trading decision remain entirely yours.

This script is open-source. The full Pine code is available on this page for anyone to read, verify, and build upon.

---

## Source Code

````pine
//@version=6
indicator("Macro HUD", shorttitle="Macro HUD", overlay=true, max_lines_count=500)

// ============================================================================
//  MACRO HUD  ·  v1.2
//  A heads-up macro dashboard, on your chart.
// ----------------------------------------------------------------------------
//  Puts the market's macro context on one on-chart panel, so you're never
//  reading price in isolation:
//    • MACRO ENGINE  — Dollar (DXY), US 10Y & 2Y yields, Oil, VIX (+ regime band)
//    • REGIME        — a dollar read and a risk-on/off read, derived from those
//    • WATCHLIST     — Bull/Bear (vs an EMA) on any symbols you choose
//    • EVENT         — an optional manual countdown to your next key release
//
//  Every symbol is an editable input, so you can point the HUD at whatever
//  feed and instruments you trade. Text colour is theme-aware by default.
//
//  Honest scope: this is a context dashboard. It shows information; it does not
//  generate trade signals, predict, or tell you what to do. The read is yours.
//
//  Note: Pine can read price/symbol data only — it cannot read the economic
//  calendar or news. Fill the EVENT slots in by hand from your own calendar.
//
//  v1.1: removed the optional Ichimoku overlay to keep the tool to one clear
//  idea — a macro dashboard, nothing extraneous.
// ============================================================================


// ---------------------------------------------------------------- INPUTS: general
grpG = "General"
macroTF = input.timeframe("D", "Macro read timeframe", group=grpG, tooltip="Timeframe for all macro/watchlist reads. Daily ('D') gives the broad regime regardless of your chart timeframe.")
dirLen  = input.int(5, "Trend lookback (bars)", minval=1, group=grpG, tooltip="Bars back used to measure the ▲/▼ direction arrow for the macro engine.")
maLen   = input.int(50, "Watchlist trend EMA length", minval=2, group=grpG, tooltip="Bull/Bear per instrument = price above/below this EMA.")
tblPos  = input.string("Top Right", "Panel position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grpG)
txtSize = input.string("Normal", "Panel text size", options=["Tiny","Small","Normal","Large"], group=grpG)
txtMode = input.string("Auto (theme)", "Panel text colour", options=["Auto (theme)","Black","White"], group=grpG, tooltip="Auto adapts to your chart's light/dark theme.")

// ------------------------------------------ INPUTS: macro symbols (edit to your feed)
grpS = "Macro engine symbols (edit to match your data feed)"
symDXY = input.symbol("TVC:DXY",   "Dollar index", group=grpS)
sym10Y = input.symbol("TVC:US10Y", "US 10Y yield", group=grpS)
sym02Y = input.symbol("TVC:US02Y", "US 2Y yield",  group=grpS)
symOIL = input.symbol("TVC:USOIL", "Crude oil",    group=grpS)
symVIX = input.symbol("TVC:VIX",   "VIX",          group=grpS)

// ------------------------------------------------------- INPUTS: watchlist symbols
grpW = "Watchlist symbols (edit freely)"
symW1 = input.symbol("OANDA:XAUUSD", "Slot 1", group=grpW)
symW2 = input.symbol("OANDA:EURUSD", "Slot 2", group=grpW)
symW3 = input.symbol("OANDA:GBPUSD", "Slot 3", group=grpW)
symW4 = input.symbol("OANDA:USDJPY", "Slot 4", group=grpW)
symW5 = input.symbol("SP:SPX",       "Slot 5", group=grpW)

// ----------------------------- INPUTS: events (manual — Pine can't read the calendar)
// Fill in your next key releases. The panel shows whichever is SOONEST.
grpE = "Event countdown (manual)"
evtOn    = input.bool(true, "Show event row", group=grpE)
evtWarnH = input.int(3, "Stand-down window (hours before)", minval=0, group=grpE, tooltip="Inside this many hours before the event, the row turns red as a 'stand down' flag.")

e1On   = input.bool(false, "1", inline="e1", group=grpE)
e1Name = input.string("Event 1", "", inline="e1", group=grpE)
e1Time = input.time(timestamp("2026-01-01 13:30 +0000"), "", inline="e1", group=grpE)

e2On   = input.bool(false, "2", inline="e2", group=grpE)
e2Name = input.string("Event 2", "", inline="e2", group=grpE)
e2Time = input.time(timestamp("2026-01-01 13:30 +0000"), "", inline="e2", group=grpE)

e3On   = input.bool(false, "3", inline="e3", group=grpE)
e3Name = input.string("Event 3", "", inline="e3", group=grpE)
e3Time = input.time(timestamp("2026-01-01 13:30 +0000"), "", inline="e3", group=grpE)


// ------------------------------------------------------------------- THEME
txtColor = txtMode == "Black" ? color.black : txtMode == "White" ? color.white : chart.fg_color
headBg   = color.new(color.gray, 65)
titleBg  = color.new(color.blue, 55)


// ----------------------------------------------------------------- DATA: macro engine
f_macro(sym) =>
    [c, cPrev] = request.security(sym, macroTF, [close, close[dirLen]], ignore_invalid_symbol=true)
    dir = na(c) ? 0 : c > cPrev ? 1 : c < cPrev ? -1 : 0
    [c, dir]

[dxyV, dxyD] = f_macro(symDXY)
[y10V, y10D] = f_macro(sym10Y)
[y02V, y02D] = f_macro(sym02Y)
[oilV, oilD] = f_macro(symOIL)
[vixV, vixD] = f_macro(symVIX)

// ------------------------------------------------------------------- DATA: watchlist
f_watch(sym) =>
    [c, m] = request.security(sym, macroTF, [close, ta.ema(close, maLen)], ignore_invalid_symbol=true)
    st = na(c) ? 0 : c > m ? 1 : -1
    [c, st]

[w1V, w1S] = f_watch(symW1)
[w2V, w2S] = f_watch(symW2)
[w3V, w3S] = f_watch(symW3)
[w4V, w4S] = f_watch(symW4)
[w5V, w5S] = f_watch(symW5)


// ------------------------------------------------------------------- DERIVED READS
vixBand = na(vixV) ? "n/a" : vixV < 15 ? "CALM" : vixV < 25 ? "NORMAL" : vixV < 45 ? "STRESSED" : "PANIC"
vixCol  = na(vixV) ? color.gray : vixV < 15 ? color.green : vixV < 25 ? color.gray : vixV < 45 ? color.orange : color.red

dollarTxt = na(dxyV) ? "n/a" : dxyD > 0 ? "STRONG - USD bid" : dxyD < 0 ? "WEAK - USD offered" : "FLAT"
dollarCol = dxyD > 0 ? color.blue : dxyD < 0 ? color.orange : color.gray

// risk read uses watchlist slot 5 (an index by default) + VIX band
riskKnown = not na(vixV) and w5S != 0
riskOn  = riskKnown and w5S > 0 and vixV < 25
riskTxt = not riskKnown ? "n/a" : riskOn ? "RISK-ON" : (vixV >= 25 ? "RISK-OFF (stressed)" : "MIXED / CAUTION")
riskCol = not riskKnown ? color.gray : riskOn ? color.green : (vixV >= 25 ? color.red : color.orange)


// ------------------------------------------------------------------- PANEL HELPERS
f_arrow(d) => d > 0 ? "▲" : d < 0 ? "▼" : "—"
f_acol(d)  => d > 0 ? color.green : d < 0 ? color.red : color.gray
f_num(v, fmt) => na(v) ? "n/a" : str.tostring(v, fmt)

f_macroRow(tbl, row, lbl, valStr, d, note, ncol, ts, tc) =>
    table.cell(tbl, 0, row, lbl,        text_color=tc,        text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, row, valStr,     text_color=tc,        text_size=ts, text_halign=text.align_right)
    table.cell(tbl, 2, row, f_arrow(d), text_color=f_acol(d), text_size=ts)
    table.cell(tbl, 3, row, note,       text_color=ncol,      text_size=ts, text_halign=text.align_right)

f_watchRow(tbl, row, lbl, valStr, st, ts, tc) =>
    col = st > 0 ? color.green : st < 0 ? color.red : color.gray
    lab = st > 0 ? "BULL" : st < 0 ? "BEAR" : "n/a"
    arr = st > 0 ? "▲" : st < 0 ? "▼" : "—"
    table.cell(tbl, 0, row, lbl,    text_color=tc,  text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, row, valStr, text_color=tc,  text_size=ts, text_halign=text.align_right)
    table.cell(tbl, 2, row, arr,    text_color=col, text_size=ts)
    table.cell(tbl, 3, row, lab,    text_color=col, text_size=ts, text_halign=text.align_right)

f_head(tbl, row, txt, ts, tc, bg) =>
    table.cell(tbl, 0, row, txt, text_color=tc, bgcolor=bg, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, row, "",  bgcolor=bg)
    table.cell(tbl, 2, row, "",  bgcolor=bg)
    table.cell(tbl, 3, row, "",  bgcolor=bg)

f_summaryRow(tbl, row, lbl, txt, tcol, ts, tc) =>
    table.cell(tbl, 0, row, lbl, text_color=tc,   text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 1, row, txt, text_color=tcol, text_size=ts, text_halign=text.align_left)
    table.cell(tbl, 2, row, "")
    table.cell(tbl, 3, row, "")

// selectors
ts = txtSize == "Tiny" ? size.tiny : txtSize == "Small" ? size.small : txtSize == "Large" ? size.large : size.normal
posSel = tblPos == "Top Right" ? position.top_right : tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : position.middle_right

// short display labels from the chosen symbols (strip exchange prefix)
f_short(s) => array.size(str.split(s, ":")) > 1 ? array.get(str.split(s, ":"), 1) : s


// ------------------------------------------------------------------- DRAW PANEL
var table t = table.new(posSel, 4, 20, border_width=1, frame_width=1, frame_color=color.new(color.gray,40))

if barstate.islast
    // Title
    table.cell(t, 0, 0, "MACRO HUD", text_color=txtColor, bgcolor=titleBg, text_size=ts, text_halign=text.align_left)
    table.cell(t, 1, 0, "", bgcolor=titleBg)
    table.cell(t, 2, 0, "", bgcolor=titleBg)
    table.cell(t, 3, 0, macroTF + " read", text_color=txtColor, bgcolor=titleBg, text_size=ts, text_halign=text.align_right)

    // Macro engine
    f_head(t, 1, "MACRO ENGINE", ts, txtColor, headBg)
    f_macroRow(t, 2, "Dollar (DXY)", f_num(dxyV, "#.00"),     dxyD, "",      color.gray, ts, txtColor)
    f_macroRow(t, 3, "US 10Y",       f_num(y10V, "#.00")+"%", y10D, "",      color.gray, ts, txtColor)
    f_macroRow(t, 4, "US 2Y",        f_num(y02V, "#.00")+"%", y02D, "",      color.gray, ts, txtColor)
    f_macroRow(t, 5, "Oil",          f_num(oilV, "#.00"),     oilD, "",      color.gray, ts, txtColor)
    f_macroRow(t, 6, "VIX",          f_num(vixV, "#.00"),     vixD, vixBand, vixCol,     ts, txtColor)

    // Regime
    f_head(t, 7, "REGIME", ts, txtColor, headBg)
    f_summaryRow(t, 8, "Dollar", dollarTxt, dollarCol, ts, txtColor)
    f_summaryRow(t, 9, "Risk",   riskTxt,   riskCol,   ts, txtColor)

    // Watchlist
    f_head(t, 10, "WATCHLIST (vs " + str.tostring(maLen) + " EMA)", ts, txtColor, headBg)
    f_watchRow(t, 11, f_short(symW1), f_num(w1V, "#.####"), w1S, ts, txtColor)
    f_watchRow(t, 12, f_short(symW2), f_num(w2V, "#.####"), w2S, ts, txtColor)
    f_watchRow(t, 13, f_short(symW3), f_num(w3V, "#.####"), w3S, ts, txtColor)
    f_watchRow(t, 14, f_short(symW4), f_num(w4V, "#.####"), w4S, ts, txtColor)
    f_watchRow(t, 15, f_short(symW5), f_num(w5V, "#.####"), w5S, ts, txtColor)

    // Event (soonest upcoming across the 3 slots)
    if evtOn
        names = array.new<string>()
        times = array.new<int>()
        if e1On
            array.push(names, e1Name)
            array.push(times, e1Time)
        if e2On
            array.push(names, e2Name)
            array.push(times, e2Time)
        if e3On
            array.push(names, e3Name)
            array.push(times, e3Time)

        int nowMs = timenow
        bool haveUp = false
        float upDelta = 0.0
        string upName = ""
        bool havePast = false
        float pastDelta = 0.0
        string pastName = ""

        if array.size(times) > 0
            for i = 0 to array.size(times) - 1
                fd = float(array.get(times, i) - nowMs)
                if fd > 0
                    if not haveUp or fd < upDelta
                        haveUp := true
                        upDelta := fd
                        upName := array.get(names, i)
                else
                    if not havePast or fd > pastDelta
                        havePast := true
                        pastDelta := fd
                        pastName := array.get(names, i)

        string eTxt = "No upcoming event - set next"
        color  eCol = color.gray
        if haveUp
            totalH = int(math.floor(upDelta / 3600000.0))
            dd = int(math.floor(totalH / 24))
            hh = totalH % 24
            warn = (upDelta / 3600000.0) <= evtWarnH
            eTxt := warn ? ("STAND DOWN: " + upName) : (upName + " in " + str.tostring(dd) + "d " + str.tostring(hh) + "h")
            eCol := warn ? color.red : color.orange
        else if havePast and pastDelta > -7200000.0
            eTxt := pastName + " - LIVE / just passed"
            eCol := color.red

        table.cell(t, 0, 16, "⚠ EVENT", text_color=txtColor, bgcolor=color.new(eCol,70), text_size=ts, text_halign=text.align_left)
        table.cell(t, 1, 16, eTxt,      text_color=txtColor, bgcolor=color.new(eCol,70), text_size=ts, text_halign=text.align_left)
        table.cell(t, 2, 16, "", bgcolor=color.new(eCol,70))
        table.cell(t, 3, 16, "", bgcolor=color.new(eCol,70))
````
