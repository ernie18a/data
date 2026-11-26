# Modern Dow Theory - Weekly Confirmation

- url: https://www.tradingview.com/script/RwObwByV-Modern-Dow-Theory-Weekly-Confirmation/
- type: indicator
- pine_id: PUB;fe0f520ae2b64ae9bcb67a29d3abb1f4
- version: 1.0

## Description

This indicator compares weekly participation across software, semiconductors, industrials and transports using IGV, SMH, XLI and IYT. Use a standard weekly or shorter chart.

Default readings are 100 × (three-week EMA of price / its 40-week SMA − 1). A sector confirms above its baseline. The optional breakout filter also requires the smoothed price to meet or exceed its preceding 26-week high. The background counts confirmations: green for four, yellow for three, orange for two and red for zero or one.

The digital line averages software and semiconductor readings equally. Separate credit context shows 100 × ((HYG / IEI) / its 20-week SMA − 1) without affecting the sector score. Alerts cover transitions into full confirmation, caution and disagreement between the digital sectors.

Results use the previous completed week on the SPX calendar by default and update when the next anchor week begins. Gaps can carry earlier values forward; the date checks the calendar, not each feed. This is descriptive sector context, not a tested trading strategy.

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danielpjacobs
//@version=6
indicator("Modern Dow Theory v2.0 — Weekly Confirmation", overlay=false, precision=2)

md_sym_dig_make = input.symbol("AMEX:IGV", "Software", group="Assets")
md_sym_dig_move = input.symbol("NASDAQ:SMH", "Semiconductors", group="Assets")
md_sym_phy_make = input.symbol("AMEX:XLI", "Industrials", group="Assets")
md_sym_phy_move = input.symbol("AMEX:IYT", "Transports", group="Assets")
spine = input.symbol("SP:SPX", "Weekly calendar anchor", group="Assets")
maLen = input.int(40, "Trend baseline (weeks)", minval=10, group="Weekly analysis")
smoothLen = input.int(3, "Price smoothing (weeks)", minval=1, group="Weekly analysis")
useBreakout = input.bool(false, "Also require a new high", group="Weekly analysis")
brkLen = input.int(26, "Breakout lookback (weeks)", minval=5, group="Weekly analysis")
showComposite = input.bool(true, "Show equal-weight digital context", group="Display")
showHUD = input.bool(true, "Show dashboard", group="Display")
showCredit = input.bool(true, "Show credit confirmation", group="Credit")
symRisk = input.symbol("AMEX:HYG", "High-yield credit", group="Credit")
symSafe = input.symbol("NASDAQ:IEI", "Treasuries", group="Credit")
creditLen = input.int(20, "Credit baseline (weeks)", minval=5, group="Credit")

if timeframe.in_seconds() > timeframe.in_seconds("W")
    runtime.error("Use a weekly or shorter chart. Calculations always use completed weeks.")

f_price(sym) =>
    request.security(sym, "W", ta.ema(close, smoothLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
f_norm(x, m) =>
    not na(m) and m != 0 ? 100 * (x / m - 1) : na

// All history-dependent calculations execute on the US weekly calendar.
// Each returned field is offset one week; lookahead_on below therefore cannot expose the current week's close.
f_engine() =>
    p1 = f_price(md_sym_dig_make)
    p2 = f_price(md_sym_dig_move)
    p3 = f_price(md_sym_phy_make)
    p4 = f_price(md_sym_phy_move)
    m1 = ta.sma(p1, maLen)
    m2 = ta.sma(p2, maLen)
    m3 = ta.sma(p3, maLen)
    m4 = ta.sma(p4, maLen)
    h1 = ta.highest(p1, brkLen)[1]
    h2 = ta.highest(p2, brkLen)[1]
    h3 = ta.highest(p3, brkLen)[1]
    h4 = ta.highest(p4, brkLen)[1]
    ok1 = p1 > m1 and (not useBreakout or p1 >= h1)
    ok2 = p2 > m2 and (not useBreakout or p2 >= h2)
    ok3 = p3 > m3 and (not useBreakout or p3 >= h3)
    ok4 = p4 > m4 and (not useBreakout or p4 >= h4)
    v1 = f_norm(p1, m1)
    v2 = f_norm(p2, m2)
    v3 = f_norm(p3, m3)
    v4 = f_norm(p4, m4)
    risk = request.security(symRisk, "W", close, ignore_invalid_symbol=true)
    safe = request.security(symSafe, "W", close, ignore_invalid_symbol=true)
    ratio = not na(safe) and safe > 0 ? risk / safe : na
    ratioMA = ta.sma(ratio, creditLen)
    credit = f_norm(ratio, ratioMA)
    ready = not na(v1) and not na(v2) and not na(v3) and not na(v4) and (not useBreakout or (not na(h1) and not na(h2) and not na(h3) and not na(h4)))
    [v1[1], v2[1], v3[1], v4[1], ok1[1], ok2[1], ok3[1], ok4[1], credit[1], ready[1], time_close[1]]

[v1, v2, v3, v4, ok1, ok2, ok3, ok4, credit, ready, sourceClose] = request.security(spine, "W", f_engine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
score = (ok1 ? 1 : 0) + (ok2 ? 1 : 0) + (ok3 ? 1 : 0) + (ok4 ? 1 : 0)
fullConfirm = ready and score == 4
caution = ready and score <= 1
semisLead = ready and ok2 and not ok1
softwareLead = ready and ok1 and not ok2
newWeek = not na(sourceClose[1]) and sourceClose != sourceClose[1]
regimeColor = not ready ? na : score == 4 ? color.new(color.green, 85) : score == 3 ? color.new(color.yellow, 88) : score == 2 ? color.new(color.orange, 90) : color.new(color.red, 90)
bgcolor(regimeColor, title="Weekly sector confirmation")
plot(v1, "Software: % vs weekly baseline", color=color.blue, linewidth=2)
plot(v2, "Semis: % vs weekly baseline", color=color.teal, linewidth=2)
plot(v3, "Industrials: % vs weekly baseline", color=color.orange, linewidth=2)
plot(v4, "Transports: % vs weekly baseline", color=color.fuchsia, linewidth=2)
plot(showComposite ? (v1 + v2) / 2 : na, "Equal-weight digital context", color=color.new(chart.fg_color, 50))
hline(0, "Weekly baseline", color=color.gray, linestyle=hline.style_dotted)

f_pct(x) => na(x) ? "N/A" : str.tostring(x, "#.##") + "%"
f_state(x, ok) => na(x) ? "WARMUP / NO DATA" : ok ? "CONFIRMED" : "BELOW / NO BREAKOUT"
f_row(table t, int row, string label, float value, bool ok, color c) =>
    table.cell(t, 0, row, label, text_color=c, text_size=size.small)
    table.cell(t, 1, row, f_pct(value), text_color=c, text_size=size.small)
    table.cell(t, 2, row, f_state(value, ok), text_color=na(value) ? color.gray : ok ? color.lime : color.orange, text_size=size.small)
var table hud = table.new(position.top_left, 3, 9, bgcolor=color.rgb(28, 31, 40))
if barstate.islast
    table.clear(hud, 0, 0, 2, 8)
    if showHUD
        table.cell(hud, 0, 0, "", height=5, text_size=size.small)
        table.cell(hud, 1, 0, "", height=5, text_size=size.small)
        table.cell(hud, 2, 0, "", height=5, text_size=size.small)
        table.cell(hud, 0, 1, "MODERN DOW v2.0", text_color=color.white, text_size=size.small)
        table.cell(hud, 1, 1, "Completed weeks", text_color=color.silver, text_size=size.small)
        table.cell(hud, 2, 1, ready ? str.tostring(score) + "/4" : "WARMUP / NO DATA", text_color=ready ? color.white : color.orange, text_size=size.small)
        f_row(hud, 2, "Software", v1, ok1, color.blue)
        f_row(hud, 3, "Semiconductors", v2, ok2, color.teal)
        f_row(hud, 4, "Industrials", v3, ok3, color.orange)
        f_row(hud, 5, "Transports", v4, ok4, color.fuchsia)
        if showCredit
            f_row(hud, 6, "Credit: HYG / IEI", credit, credit > 0, color.silver)
        table.cell(hud, 0, 7, "Digital divergence", text_color=color.silver, text_size=size.small)
        table.cell(hud, 1, 7, not ready ? "N/A" : semisLead ? "Semis lead" : softwareLead ? "Software leads" : "None", text_color=color.white, text_size=size.small)
        table.cell(hud, 0, 8, "Week closed", text_color=color.silver, text_size=size.small)
        table.cell(hud, 1, 8, na(sourceClose) ? "N/A" : str.format_time(sourceClose, "yyyy-MM-dd", "America/New_York"), text_color=color.white, text_size=size.small)
        table.cell(hud, 2, 8, not na(sourceClose) and timenow - sourceClose > 12 * 86400000 ? "STALE CALENDAR" : "", text_color=color.orange, text_size=size.small)

alertcondition(newWeek and ready and ready[1] and fullConfirm and not fullConfirm[1], "Entered full confirmation", "Modern Dow: all four sectors entered weekly confirmation.")
alertcondition(newWeek and ready and ready[1] and caution and not caution[1], "Entered caution", "Modern Dow: only zero or one sector confirms this week.")
alertcondition(newWeek and ready and ready[1] and semisLead and not semisLead[1], "Semiconductors began leading", "Modern Dow: semiconductors confirm while software does not.")
alertcondition(newWeek and ready and ready[1] and softwareLead and not softwareLead[1], "Software began leading", "Modern Dow: software confirms while semiconductors do not.")
````
