# GoldAlgo Sessions

- url: https://www.tradingview.com/script/gLMGZXcK-GoldAlgo-Sessions/
- type: indicator
- pine_id: PUB;819bb4605151456f97f49deca420fbe2
- version: 1.0

## Description

GoldAlgo Sessions marks the three trading sessions of the Gold (XAUUSD) day — Asia, London and New York — as clean, low-opacity boxes directly on your chart, so you always know which market is driving price right now.

HOW IT WORKS

Each session is drawn as a subtle shaded box that tracks the session's live high and low as it develops, with the session name written faintly inside. Session hours are defined in UTC, so the boxes are identical on every chart and match the GoldAlgo engine clock:

1. Asia (23:00–07:00 UTC). Tokyo and Sydney. The ranging hours on gold — most fake breakouts happen here.

2. London (07:00–16:00 UTC). The session that sets the day's direction on gold. The London open is the first real volume of the day.

3. New York (12:30–21:00 UTC). US data drops at 12:30 UTC and COMEX volume. The London/New York overlap is the most liquid window of the day.

All hours are fully editable, so you can adapt the boxes to your broker or your own definitions.

ON-CHART DASHBOARD

A live panel shows each session's status (LIVE or closed) and its current range in gold pips, so you can see at a glance whether the day is expanding or contracting and which session produced the move.

SETTINGS

Session hours per session, how many days of boxes to keep on the chart, box fill and border transparency, session names on/off, and full color customization.

IMPORTANT

GoldAlgo Sessions works only on Gold (XAUUSD) and on intraday timeframes (M1 to H2). On any other symbol or timeframe it displays a notice instead of drawings. This is an educational analysis tool: it does not predict the market and it is not financial advice. Always use proper risk management and never risk capital you cannot afford to lose.

## Source Code

````pine
//@version=6
indicator("GoldAlgo Sessions", "GoldAlgo Sessions", overlay = true, max_boxes_count = 500, max_labels_count = 500)

string G_SESS  = "Sessions (UTC)"
string G_STYLE = "Style"
string G_UI    = "Dashboard & Colors"

showAsia   = input.bool(true, "Asia", group = G_SESS, inline = "asia")
asiaSess   = input.session("2300-0700", "", group = G_SESS, inline = "asia", tooltip = "Tokyo + Sydney. Ranging hours on gold — most fake breakouts happen here.")
showLon    = input.bool(true, "London", group = G_SESS, inline = "lon")
lonSess    = input.session("0700-1600", "", group = G_SESS, inline = "lon", tooltip = "The session that sets the day's direction on gold. The London open (07:00 UTC) is the first real volume of the day.")
showNy     = input.bool(true, "New York", group = G_SESS, inline = "ny")
nySess     = input.session("1230-2100", "", group = G_SESS, inline = "ny", tooltip = "US data drops at 12:30 UTC and COMEX volume. The London/NY overlap (12:30–16:00) is the most liquid window of the day.")
tzName     = input.string("UTC", "Timezone", options = ["UTC"], group = G_SESS, tooltip = "Session hours are read in UTC so the boxes are identical on every chart, matching the GoldAlgo engine clock.")
keepDays   = input.int(10, "Days of boxes to keep", minval = 1, maxval = 60, group = G_SESS)

fillTransp = input.int(94, "Box fill transparency", minval = 80, maxval = 99, group = G_STYLE, tooltip = "Higher = fainter. Default 94 keeps the boxes visible without covering the candles.")
bordTransp = input.int(65, "Box border transparency", minval = 0, maxval = 95, group = G_STYLE)
showNames  = input.bool(true, "Session name inside the box", group = G_STYLE)

showDash   = input.bool(true, "Show dashboard", group = G_UI)
colAsia    = input.color(#E8B33C, "Asia", group = G_UI, inline = "col")
colLon     = input.color(#10A66E, "London", group = G_UI, inline = "col")
colNy      = input.color(#D9414B, "New York", group = G_UI, inline = "col")
colGold    = input.color(#E8B33C, "Brand", group = G_UI, inline = "col2")

bool isGold = str.contains(syminfo.ticker, "XAU") or str.contains(syminfo.ticker, "GOLD")
// Hidden bars on higher timeframes would smear the boxes — sessions only make sense intraday
bool tfOk = isGold and timeframe.in_seconds() <= timeframe.in_seconds("120")
var table warn = table.new(position.middle_center, 1, 1)
if not tfOk and barstate.islast
    table.cell(warn, 0, 0, not isGold ? "  GoldAlgo Sessions works only on Gold — open an XAUUSD chart  " : "  GoldAlgo Sessions works on intraday charts — use M1 to H2  ", text_color = colGold, text_size = size.normal, bgcolor = #0E0C07)

// One call site per session: the var arrays inside are per-session automatically
drawSession(bool enabled, string sess, string sName, color col) =>
    bool inSess = enabled and tfOk and not na(time(timeframe.period, sess, tzName))
    var array<box> bxs = array.new<box>()
    var box cur = na
    if inSess and not inSess[1]
        cur := box.new(bar_index, high, bar_index, low, border_color = color.new(col, bordTransp), border_width = 1, bgcolor = color.new(col, fillTransp), text = showNames ? sName : "", text_color = color.new(col, 35), text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)
        array.push(bxs, cur)
        if array.size(bxs) > keepDays
            box.delete(array.shift(bxs))
    if inSess and not na(cur)
        box.set_right(cur, bar_index)
        box.set_top(cur, math.max(box.get_top(cur), high))
        box.set_bottom(cur, math.min(box.get_bottom(cur), low))
    float rng = not na(cur) ? box.get_top(cur) - box.get_bottom(cur) : na
    [inSess, rng]

[asiaLive, asiaRng] = drawSession(showAsia, asiaSess, "ASIA", colAsia)
[lonLive,  lonRng]  = drawSession(showLon,  lonSess,  "LONDON", colLon)
[nyLive,   nyRng]   = drawSession(showNy,   nySess,   "NEW YORK", colNy)

rngTxt(float r) =>
    na(r) ? "—" : str.tostring(r / 0.1, "#") + " pips"

var table dash = table.new(position.bottom_right, 3, 5, bgcolor = #0E0C07, frame_width = 2, frame_color = color.new(#E8B33C, 25), border_width = 1, border_color = color.new(#E8B33C, 92))
if showDash and tfOk and barstate.islast
    color lblCol = #CFC6B0
    table.cell(dash, 0, 0, "  GoldAlgo Sessions  ", text_color = colGold, text_size = size.normal, bgcolor = #060502, text_halign = text.align_center)
    table.merge_cells(dash, 0, 0, 2, 0)
    table.cell(dash, 0, 1, "  Asia", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, asiaLive ? "● LIVE" : "closed", text_color = asiaLive ? colAsia : color.new(lblCol, 50), text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 2, 1, rngTxt(asiaRng) + "  ", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 2, "  London", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, lonLive ? "● LIVE" : "closed", text_color = lonLive ? colLon : color.new(lblCol, 50), text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 2, 2, rngTxt(lonRng) + "  ", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 3, "  New York", text_color = lblCol, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, nyLive ? "● LIVE" : "closed", text_color = nyLive ? colNy : color.new(lblCol, 50), text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 2, 3, rngTxt(nyRng) + "  ", text_color = color.white, text_size = size.small, text_halign = text.align_right)
    table.cell(dash, 0, 4, "  SGHK Softwares Limited  ", text_color = color.new(colGold, 20), text_size = size.tiny, text_halign = text.align_center)
    table.merge_cells(dash, 0, 4, 2, 4)
````
