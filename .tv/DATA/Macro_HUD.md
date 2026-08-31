<!-- tradingview-pine-id: PUB;45eff6f275d74389be78ca9f52459284 -->
<!-- tradingviewscripts-format: 1 -->
# Macro HUD

Source: https://www.tradingview.com/script/YRdjBtgK-MACRO-HUD/

## Description

MACRO HUD — macro context, on your chart

Most indicators re-arrange the price you're already looking at. Macro HUD does the opposite: it puts the market's macro context on a single on-chart panel, so you're never reading price in isolation. It's a dashboard, not a signal generator.
 
 
WHAT IT SHOWS
 
MACRO ENGINE — the dollar (DXY), US 10Y and 2Y yields, oil, and the VIX, each with its current value and a direction arrow. The VIX also carries a regime band: Calm / Normal / Stressed / Panic.
 
REGIME — two plain-language reads derived from the engine: a dollar read (bid / offered) and a risk read (risk-on / risk-off / mixed).
 
WATCHLIST — up to five instruments of your choice, each flagged Bull or Bear versus an EMA, so you can see the state of your whole watchlist at a glance. Defaults to gold, EUR/USD, GBP/USD, USD/JPY and the S&P 500 — change them to whatever you trade.
 
EVENT — an optional manual countdown. Type in your next few key releases (name plus date/time) and the panel shows whichever is soonest, turning red inside a "stand-down" window you set. Pine can't read the economic calendar, so this part is filled in by hand.
 
 
HOW TO USE IT
 
Add it to any chart. Open the settings and point the symbols at feeds your plan supports, choose your watchlist instruments, and set the read timeframe — Daily by default, which gives the broad regime regardless of your chart timeframe. Everything else is automatic and updates live. Text colour is theme-aware, so it reads on light or dark charts.
 
 
WHAT IT DOES NOT DO
 
It does not generate buy/sell signals, predict direction, or tell you what to do. It assembles context; the read — and the decision — stay yours. There are no performance claims here, by design.
 
 
NOTES
 
Some data symbols (DXY, yields, VIX) depend on your TradingView data plan. If a row shows "n/a", open the settings and swap that symbol for one your plan supports — the tool handles missing symbols gracefully rather than breaking.
 
Open-source. Read the code, fork it, adapt it to your own workflow.

MACRO HUD: "Built to support discretion, not replace it"

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
