# GoldAlgo News

- url: https://www.tradingview.com/script/H1CLVU1g-GoldAlgo-News/
- type: indicator
- pine_id: PUB;f460dacfb263493392ebaa47db9a80f1
- version: 1.0

## Description

GoldAlgo News marks the high-impact US economic releases that move Gold (XAUUSD) — directly on your chart, with a no-trade window around each one and a plain-language note on what to expect.

THE EVENTS

1. NFP — Non-Farm Payrolls. Computed automatically as the first Friday of every month, 8:30 ET. The single most violent recurring move on gold: a two-way spike on release, widened spreads, and then the real move. Stand aside and let the first M5 candle close.

2. CPI — the US inflation report, 8:30 ET. Dates loaded from the official BLS release calendar. Hot inflation = USD up, gold down; cool inflation = gold up. The fastest repricing of all — never hold a position into it.

3. FOMC — the Fed rate decision, 14:00 ET. Dates loaded from the Fed's published meeting calendar. Two waves: the statement at the release, then the press conference 30 minutes later — the second often reverses the first. The widest no-trade window of the month.

Release times are stored in US Eastern time and converted to UTC with proper daylight-saving handling, so the marks stay accurate all year round.

HOW IT WORKS

Around every enabled event the chart background shades red for a configurable blackout window (default: 30 minutes before to 60 minutes after). Upcoming events are drawn ahead of price as dashed vertical lines with a labeled marker — hover the label to read the full "what to expect" note for that release.

ON-CHART DASHBOARD

A live panel shows the current status (clear to trade, or which news window you are inside), the next red event with its date, time and a live countdown, and a one-line expectation for it.

ALERTS

An alert condition fires the moment a news blackout window opens, so you can flatten or stand aside before the release — straight to your phone.

SETTINGS

Each event type on/off, how many upcoming events to draw, the blackout window before and after each release, and full color customization.

IMPORTANT

GoldAlgo News works only on Gold (XAUUSD). On any other symbol it displays a notice instead of drawings. Event dates are taken from the official published calendars; agencies occasionally reschedule a release, so always confirm against an economic calendar before trading. This is an educational analysis tool: it does not predict the market and it is not financial advice. Always use proper risk management and never risk capital you cannot afford to lose.

## Source Code

````pine
//@version=6
indicator("GoldAlgo News", "GoldAlgo News", overlay = true, max_lines_count = 500, max_labels_count = 500)

string G_EV  = "Red news"
string G_WIN = "No-trade window"
string G_UI  = "Dashboard & Colors"

showNFP  = input.bool(true, "NFP — Non-Farm Payrolls (first Friday, 8:30 ET)", group = G_EV, tooltip = "Computed automatically: first Friday of every month. The single most violent recurring move on gold.")
showCPI  = input.bool(true, "CPI — inflation report (8:30 ET)", group = G_EV, tooltip = "Dates hardcoded from the BLS release calendar for 2025–2026. Verify on bls.gov if a date looks off.")
showFOMC = input.bool(true, "FOMC — rate decision (14:00 ET)", group = G_EV, tooltip = "Dates hardcoded from the Fed's published 2025–2026 meeting calendar. Powell's press conference follows 30 minutes later.")
maxAhead = input.int(5, "Upcoming events to draw", minval = 1, maxval = 10, group = G_EV)

preMin   = input.int(30, "Blackout: minutes before", minval = 0, group = G_WIN, tooltip = "Background turns red this long before a release. No entries inside the window — spreads widen and stops get hunted.")
postMin  = input.int(60, "Blackout: minutes after", minval = 0, group = G_WIN, tooltip = "The first hour after a red release is repricing, not trading. Let the dust settle.")

showDash = input.bool(true, "Show dashboard", group = G_UI)
colUp    = input.color(#10A66E, "Bullish", group = G_UI, inline = "col")
colDn    = input.color(#D9414B, "Bearish", group = G_UI, inline = "col")
colGold  = input.color(#E8B33C, "Brand", group = G_UI, inline = "col")

bool isGold = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
var table warn = table.new(position.middle_center, 1, 1)
if not isGold and barstate.islast
    table.cell(warn, 0, 0, "  GoldAlgo News is calibrated for Gold — open an XAUUSD chart  ", text_color = colGold, text_size = size.normal, bgcolor = #0E0C07)

// ---- US Eastern time → UTC (handles daylight saving) ----
nthDay(int y, int m, int fromD, int wd) =>
    int d = fromD
    while dayofweek(timestamp("GMT", y, m, d, 12, 0), "GMT") != wd
        d += 1
    d

isUsDst(int y, int m, int d) =>
    m > 3 and m < 11 ? true : m == 3 ? d >= nthDay(y, 3, 8, dayofweek.sunday) : m == 11 ? d < nthDay(y, 11, 1, dayofweek.sunday) : false

etStamp(int y, int m, int d, int hh, int mm) =>
    timestamp("GMT", y, m, d, hh + (isUsDst(y, m, d) ? 4 : 5), mm)

// ---- Event calendar (built once) ----
var array<int>    evT = array.new<int>()
var array<string> evN = array.new<string>()

addEv(int y, int m, int d, int hh, int mm, string nm) =>
    array.push(evT, etStamp(y, m, d, hh, mm))
    array.push(evN, nm)

if barstate.isfirst
    for y = 2025 to 2026
        for m = 1 to 12
            addEv(y, m, nthDay(y, m, 1, dayofweek.friday), 8, 30, "NFP")
    // CPI (BLS release calendar) — day of month per year
    array<int> cpi25 = array.from(15, 12, 12, 10, 13, 11, 15, 12, 11, 15, 13, 10)
    array<int> cpi26 = array.from(13, 11, 11, 14, 12, 10, 14, 12, 11, 13, 17, 15)
    for m = 1 to 12
        addEv(2025, m, array.get(cpi25, m - 1), 8, 30, "CPI")
        addEv(2026, m, array.get(cpi26, m - 1), 8, 30, "CPI")
    // FOMC rate decisions (Fed meeting calendar, day 2) — month/day pairs
    array<int> fomc25 = array.from(1, 29, 3, 19, 5, 7, 6, 18, 7, 30, 9, 17, 10, 29, 12, 10)
    array<int> fomc26 = array.from(1, 28, 3, 18, 4, 29, 6, 17, 7, 29, 9, 16, 10, 28, 12, 9)
    for k = 0 to 7
        addEv(2025, array.get(fomc25, k * 2), array.get(fomc25, k * 2 + 1), 14, 0, "FOMC")
        addEv(2026, array.get(fomc26, k * 2), array.get(fomc26, k * 2 + 1), 14, 0, "FOMC")

evOn(string nm) =>
    nm == "NFP" ? showNFP : nm == "CPI" ? showCPI : showFOMC

expect(string nm) =>
    nm == "NFP" ? "Violent two-way spike on release, then the real move. Spreads widen. Stand aside and let the first M5 candle close." :
      nm == "CPI" ? "Hot inflation = USD up, gold down. Cool = gold up. The fastest repricing of all — never hold a position into it." :
      "Two waves: the statement at the release, then Powell 30 min later — the second often reverses the first. Widest no-trade window of the month."

expectShort(string nm) =>
    nm == "NFP" ? "Two-way spike, wait for the first M5 close" :
      nm == "CPI" ? "Hot = gold down, cool = gold up. Flat into it" :
      "Statement + Powell 30 min later. Widest window"

// ---- Blackout shading + alert ----
bool nearEvent = false
string nearName = na
if isGold and array.size(evT) > 0
    for i = 0 to array.size(evT) - 1
        int et = array.get(evT, i)
        if evOn(array.get(evN, i)) and time >= et - preMin * 60000 and time <= et + postMin * 60000
            nearEvent := true
            nearName := array.get(evN, i)

bgcolor(nearEvent ? color.new(colDn, 93) : na, title = "News blackout window")
alertcondition(nearEvent and not nearEvent[1], "GoldAlgo — Red news window opening", "Red news window opening on {{ticker}} — stand aside")

// ---- Upcoming events on the chart ----
var bool drawn = false
if barstate.islast and isGold and not drawn
    drawn := true
    int shown = 0
    for i = 0 to array.size(evT) - 1
        int    et = array.get(evT, i)
        string nm = array.get(evN, i)
        if evOn(nm) and et > timenow and shown < maxAhead
            shown += 1
            line.new(et, close, et, close + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(colDn, 40), style = line.style_dashed, width = 1)
            label lb = label.new(et, close, nm, xloc = xloc.bar_time, style = label.style_label_down, color = color.new(colDn, 10), textcolor = color.white, size = 8)
            label.set_tooltip(lb, expect(nm))

// ---- Dashboard ----
int    nxtT = na
string nxtN = na
if isGold and array.size(evT) > 0
    for i = 0 to array.size(evT) - 1
        int et = array.get(evT, i)
        if evOn(array.get(evN, i)) and et > timenow and (na(nxtT) or et < nxtT)
            nxtT := et
            nxtN := array.get(evN, i)

countdown(int t) =>
    int df = t - timenow
    int dd = math.floor(df / 86400000.0)
    int hh = math.floor(df % 86400000 / 3600000.0)
    int mm = math.floor(df % 3600000 / 60000.0)
    (dd > 0 ? str.tostring(dd) + "d " : "") + str.tostring(hh) + "h " + str.tostring(mm) + "m"

var table dash = table.new(position.bottom_right, 2, 6, bgcolor = #0E0C07, frame_width = 2, frame_color = color.new(#E8B33C, 25), border_width = 1, border_color = color.new(#E8B33C, 92))
if showDash and isGold and barstate.islast
    color lblCol = #CFC6B0
    table.cell(dash, 0, 0, "  GoldAlgo News  ", text_color = colGold, text_size = size.normal, bgcolor = #060502, text_halign = text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 1, "  Status", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, (nearEvent ? "⛔ " + nearName + " window — stand aside" : "✓ Clear to trade") + "  ", text_color = nearEvent ? colDn : colUp, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "  Next red news", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, (na(nxtN) ? "—" : nxtN) + "  ", text_color = colGold, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "  When (UTC)", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, (na(nxtT) ? "—" : str.format_time(nxtT, "dd MMM HH:mm", "GMT") + " · in " + countdown(nxtT)) + "  ", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "  What to expect", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, (na(nxtN) ? "—" : expectShort(nxtN)) + "  ", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 5, "  SGHK Softwares Limited  ", text_color = color.new(colGold, 20), text_size = size.tiny, text_halign = text.align_center)
    table.merge_cells(dash, 0, 5, 1, 5)
````
