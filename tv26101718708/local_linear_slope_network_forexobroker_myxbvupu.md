# Local Linear Slope Network [forexobroker]

- url: https://www.tradingview.com/script/myXBvUpU-Local-Linear-Slope-Network-forexobroker/
- type: indicator
- pine_id: PUB;fa7aba9570d544c1abdd78b8c630c55d
- version: 1.0

## Description

Local Linear Slope Network runs four `ta.linreg` regressions at windows 10/20/40/80, computes each line's slope sign per bar, and only fires signals when at least N slopes agree AND the previous bar did NOT yet have agreement. A clean fractal trend-confirmation entry — most trend indicators use one length; this one votes across four.

🔶 ALGORITHM

For each window n in {10, 20, 40, 80}:
1. linreg_n = ta.linreg(close, n, 0)
2. slope_n = linreg_n − linreg_n[1]
3. slope-sign vote: count how many slopes are > 0 (upCount) and how many are < 0 (dnCount)
4. Agreement edge: at least N slopes agree AND previous bar agreement was below the same threshold

The "agreement edge" requirement gates the signal to a single bar at the regime change, not a stream of confirmations.

🔶 SIGNAL LOGIC

- Buy: upCount ≥ N AND previous bar upCount < N AND cooldown AND barstate.isconfirmed
- Sell: dnCount ≥ N AND previous bar dnCount < N AND cooldown AND barstate.isconfirmed

🔶 INPUTS

- Window 1/2/3/4 (defaults 10/20/40/80 — dyadic spacing)
- Min Slopes Agreeing (default 3 of 4)
- Signal Cooldown (default 8)
- Visual toggles for slowest line, dashboard, glow, colors

🔶 ALERTS

LLN Buy / Sell, Any Signal, Full Bull (4/4), Full Bear (4/4), Fast Pair Up/Dn, Webhook JSON.

🔶 LIMITATIONS

- ta.linreg internally is OLS regression — robust but assumes linear local trend. Works well on liquid trending instruments.
- Slope is computed as endpoint difference (linreg − linreg[1]) — sensitive to outlier bars.
- Slowest window (80 default) sets warmup.
- The dyadic spacing (10/20/40/80) is opinionated; tighter/wider spacings change signal frequency drastically.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Local linear regression slope at four windows (10/20/40/80). Each ta.linreg gives the
// fitted endpoint and its slope sign. Network agreement = how many slopes agree on direction. Signals
// fire when at least N slopes agree AND the next-shorter window also agrees on direction (cascade
// from short to long agreement). Combines fractal slope confirmation with cascade-direction logic.
indicator("Local Linear Slope Network [forexobroker]", shorttitle="LLN [fob]", overlay=true,
     max_bars_back=500, max_labels_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
string g_calc   = "Slope Network"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_n1 = input.int(10, "Window 1 (fast)",   minval=5,  maxval=30, group=g_calc)
int   i_n2 = input.int(20, "Window 2",          minval=10, maxval=60, group=g_calc)
int   i_n3 = input.int(40, "Window 3",          minval=20, maxval=120, group=g_calc)
int   i_n4 = input.int(80, "Window 4 (slow)",   minval=40, maxval=240, group=g_calc)
int   i_minAgree = input.int(3, "Min Slopes Agreeing", minval=2, maxval=4, group=g_signal)
int   i_cooldown = input.int(8, "Signal Cooldown Bars", minval=2, maxval=40, group=g_signal)
bool  i_showLine = input.bool(true, "Show Slowest Linreg", group=g_visual)
bool  i_showTable = input.bool(true, "Show Slope Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Signal Glow", group=g_visual)
color i_buyColor  = input.color(#00d4ff, "Buy Color (Cyan)", group=g_visual)
color i_sellColor = input.color(#ff2d78, "Sell Color (Pink)", group=g_visual)

color c_white = #ffffff

// ─── LOCAL LINEAR REGRESSION SLOPES ───────────────────────────────────────────
// Slope is approximated by linreg endpoint - linreg endpoint shifted back 1 bar.
f_slope(int n) =>
    float lr = ta.linreg(close, n, 0)
    lr - nz(lr[1])

float l1 = ta.linreg(close, i_n1, 0)
float l2 = ta.linreg(close, i_n2, 0)
float l3 = ta.linreg(close, i_n3, 0)
float l4 = ta.linreg(close, i_n4, 0)

float s1 = f_slope(i_n1)
float s2 = f_slope(i_n2)
float s3 = f_slope(i_n3)
float s4 = f_slope(i_n4)

int upCount = (s1 > 0 ? 1 : 0) + (s2 > 0 ? 1 : 0) + (s3 > 0 ? 1 : 0) + (s4 > 0 ? 1 : 0)
int dnCount = (s1 < 0 ? 1 : 0) + (s2 < 0 ? 1 : 0) + (s3 < 0 ? 1 : 0) + (s4 < 0 ? 1 : 0)

// ─── SIGNAL LOGIC ──────────────────────────────────────────────────────────────
bool agreeUp = upCount >= i_minAgree
bool agreeDn = dnCount >= i_minAgree
bool wasNotAgreeUp = (upCount[1] < i_minAgree)
bool wasNotAgreeDn = (dnCount[1] < i_minAgree)

var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = agreeUp and wasNotAgreeUp and cooldownOk and confirmed
bool sellSignal = agreeDn and wasNotAgreeDn and cooldownOk and confirmed
if buySignal or sellSignal
    lastSignalBar := bar_index

// ─── VISUAL: SLOWEST LINREG ───────────────────────────────────────────────────
color trendCol = upCount > dnCount ? i_buyColor : dnCount > upCount ? i_sellColor : color.gray
plot(i_showLine ? l4 : na, "L4 Glow", color=color.new(trendCol, 70), linewidth=5)
plot(i_showLine ? l4 : na, "L4 Glow", color=color.new(trendCol, 40), linewidth=3)
plot(i_showLine ? l4 : na, "Linreg 4", color=color.new(trendCol, 0), linewidth=1)

// ─── VISUAL: 3-LAYER GLOW ──────────────────────────────────────────────────────
plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="LLN", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="LLN", textcolor=c_white)
barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

// ─── DASHBOARD ─────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    table.cell(dash, 0, 0, "Slope Network", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]", text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Slope " + str.tostring(i_n1), text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, s1 > 0 ? "▲" : s1 < 0 ? "▼" : "·", text_color=s1 > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 2, "Slope " + str.tostring(i_n2), text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, s2 > 0 ? "▲" : s2 < 0 ? "▼" : "·", text_color=s2 > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Slope " + str.tostring(i_n3), text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, s3 > 0 ? "▲" : s3 < 0 ? "▼" : "·", text_color=s3 > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 4, "Slope " + str.tostring(i_n4), text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, s4 > 0 ? "▲" : s4 < 0 ? "▼" : "·", text_color=s4 > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Up Count", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(upCount), text_color=upCount >= i_minAgree ? i_buyColor : c_white, text_size=size.small)
    table.cell(dash, 0, 6, "Down Count", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(dnCount), text_color=dnCount >= i_minAgree ? i_sellColor : c_white, text_size=size.small)
    table.cell(dash, 0, 7, "Min Required", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(i_minAgree), text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
if buySignal
    alert('{"action":"BUY","indicator":"LLN","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"agree_up":' + str.tostring(upCount) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"LLN","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"agree_dn":' + str.tostring(dnCount) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                "LLN Buy",          "Slope network bullish on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,               "LLN Sell",         "Slope network bearish on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,  "LLN Any Signal",   "Any LLN signal on {{ticker}} {{interval}}")
alertcondition(upCount == 4,             "LLN Full Bull",    "All 4 slopes positive on {{ticker}} {{interval}}")
alertcondition(dnCount == 4,             "LLN Full Bear",    "All 4 slopes negative on {{ticker}} {{interval}}")
alertcondition(s1 > 0 and s2 > 0,        "LLN Fast Pair Up", "Fast pair slopes up on {{ticker}} {{interval}}")
alertcondition(s1 < 0 and s2 < 0,        "LLN Fast Pair Dn", "Fast pair slopes down on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,  "LLN Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"LLN\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
