# Bipower Jump Detector [forexobroker]

- url: https://www.tradingview.com/script/cOqumSt7-Bipower-Jump-Detector-forexobroker/
- type: indicator
- pine_id: PUB;5e56cca4738e4216bd61e2e4fda0a47a
- version: 1.0

## Description

🔶 OVERVIEW

Bipower Jump Detector [forexobroker] implements the Barndorff-Nielsen jump test: realized variance (RV) captures both diffusion and jump risk, while bipower variation (BV) — built from products of adjacent absolute returns scaled by pi/2 — is jump-robust. Their non-negative difference isolates the jump component J; the standardized Jump-Z statistic tests whether that difference is significant. When Jump-Z exceeds the cutoff (default 1.96, 95% one-sided), the script enters in the direction of the largest absolute return inside the window. The unique angle is using a peer-reviewed jump test rather than ad-hoc bar-size thresholds.

🔶 ALGORITHM

1. Log-returns r_t = log(close / close[1]) are computed each bar.
2. Realized variance RV = sum of r_t^2 over the window (default 20).
3. Bipower variation BV = (pi/2) * sum of |r_t| * |r_{t-1}| over the window (jump-robust by construction).
4. Jump component J = max(RV - BV, 0) is plotted as a histogram.
5. Jump-Z = sqrt(N) * (RV - BV) / sqrt(theta * BV^2 * 0.5) with theta = pi^2/4 + pi - 5 (Barndorff-Nielsen and Shephard, 2006).
6. Direction is the sign of the largest |r_k| inside the window — the dominant jump bar drives the entry side.
7. Significant jump = Jump-Z > threshold (default 1.96); a 15-bar cooldown and position state flip-prevention stop the same jump cluster from firing multiple entries.

🔶 SIGNAL LOGIC

- Buy: Jump-Z above threshold AND dominant return in the window is positive AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: Jump-Z above threshold AND dominant return in the window is negative AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

The Z test is the gate, the dominant return is the direction.

🔶 INPUTS

- Jump Calculation group: window length default 20, significance Z default 1.96 (raise to 2.58 for stricter 99%).
- Signal Logic group: cooldown bars default 15.
- Filters group: session restriction (default 0000-2400).
- Visual group: dashboard, 3-layer glow, jump markers, jump component color, Jump-Z color, buy and sell colors.

🔶 ALERTS

BJD Buy, BJD Sell, BJD Any Signal, BJD Significant, BJD Jump Up, BJD Jump Down, BJD Z Rising, BJD J Rising, BJD High Jump Ratio, BJD Quiet Diffusion, BJD Webhook JSON.

🔶 LIMITATIONS

- The Barndorff-Nielsen test was designed for high-frequency intraday returns; on daily timeframes the diffusion-jump decomposition is harder to interpret and BV becomes a less precise diffusion proxy.
- Bipower variation needs at least two adjacent non-zero absolute returns; a window with one or two zero returns inflates Jump-Z artificially.
- The direction comes from the single dominant return in the window — when two large opposite jumps occur back-to-back, the entry side may not reflect the most recent move.
- Defaults are tuned for liquid crypto and intraday futures; thin instruments with frequent zero-volume bars produce noisy BV estimates.
- The Z formula uses a simplified variance approximation (theta * BV^2 * 0.5); under extreme volatility the small-sample distribution deviates from the normal approximation.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Bipower Jump Detector. Barndorff-Nielsen and Shephard showed that realized variance
// (sum of squared returns) over a window includes both continuous diffusion and discrete jumps,
// while bipower variation (sum of products of adjacent absolute returns scaled by pi/2) is robust
// to jumps. The non-negative difference J = max(RV - BV, 0) isolates the jump component, and the
// standardized statistic Jump-Z = sqrt(N) (RV - BV) / sqrt(theta * BV^2) tests significance. When
// Jump-Z exceeds 1.96 the bar contains a statistically significant jump; the script enters in the
// direction of the largest absolute return inside the window. Non-repainting: confirmed bars only.
indicator("Bipower Jump Detector [forexobroker]", shorttitle="BJD [fob]", overlay=false, max_bars_back=500)

string g_calc = "Jump Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_win     = input.int(20,    "Window Length",         minval=5,   maxval=200, group=g_calc, tooltip="Bars used for RV and BV. Must be at least 5.")
float i_zThresh = input.float(1.96,"Significance Z",        minval=1.0, maxval=4.0, step=0.05, group=g_calc, tooltip="One-sided test cutoff. 1.96 ~ 95%, 2.58 ~ 99%.")
int   i_cooldown= input.int(15,    "Cooldown Bars",         minval=1,   maxval=60,  group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                            group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                       group=g_filt)
bool  i_showTable=input.bool(true, "Show Dashboard",                                 group=g_vis)
bool  i_showGlow= input.bool(true, "Show 3-Layer Glow",                              group=g_vis)
bool  i_showLine= input.bool(true, "Show Jump Markers",                              group=g_vis)
color i_buyColor= input.color(#39ff14,"Buy Color",                                   group=g_vis)
color i_sellColor=input.color(#ff2d78,"Sell Color",                                  group=g_vis)
color i_jColor  = input.color(#a855f7,"Jump Component",                              group=g_vis)
color i_zColor  = input.color(#00d4ff,"Jump-Z Line",                                 group=g_vis)
color i_dashBg  = input.color(color.new(#0c1810, 16),"Dashboard BG",                 group=g_vis)

color c_white = #ffffff

float r = na(close[1]) ? 0.0 : math.log(close / close[1])
float r2 = r * r
float aPair = math.abs(r) * math.abs(nz(r[1]))

float RV = math.sum(r2,     i_win)
float BV = (math.pi / 2.0) * math.sum(aPair, i_win)

float J  = math.max(RV - BV, 0.0)

float Nf    = i_win
float theta = (math.pi * math.pi / 4.0) + math.pi - 5.0
float den   = math.sqrt(math.max(theta * BV * BV * 0.5, 1e-20))
float zJ    = math.sqrt(Nf) * (RV - BV) / den

// Direction = sign of largest |r| in the window
float maxAbsR = 0.0
float dirR    = 0.0
if bar_index >= i_win
    for k = 0 to i_win - 1
        float rk = nz(r[k])
        if math.abs(rk) > maxAbsR
            maxAbsR := math.abs(rk)
            dirR    := rk

bool sigJump = zJ > i_zThresh
bool jumpUp  = sigJump and dirR > 0
bool jumpDn  = sigJump and dirR < 0

bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool entryUp   = inSession and jumpUp
bool entryDown = inSession and jumpDn

var int posState      = 0
var int lastSignalBar = 0
bool cooldownOk = (bar_index - lastSignalBar) >= i_cooldown
bool confirmed  = barstate.isconfirmed
bool buySignal  = entryUp   and posState <= 0 and cooldownOk and confirmed
bool sellSignal = entryDown and posState >= 0 and cooldownOk and confirmed
if buySignal
    posState := 1
    lastSignalBar := bar_index
if sellSignal
    posState := -1
    lastSignalBar := bar_index

plot(J,  "Jump Component (J)", color=i_jColor, style=plot.style_columns)
plot(zJ, "Jump-Z",              color=i_zColor, linewidth=2)
hline(i_zThresh,  "Z Threshold (+)", color=color.new(#ffaa00, 30), linestyle=hline.style_dashed)
hline(-i_zThresh, "Z Threshold (-)", color=color.new(#ffaa00, 30), linestyle=hline.style_dashed)
hline(0, "Zero", color=color.new(color.gray, 60))
bgcolor(sigJump ? color.new(i_jColor, 88) : na)

var line jumpMark = na
if i_showLine and sigJump and barstate.isconfirmed
    line.delete(jumpMark)
    jumpMark := line.new(bar_index, 0.0, bar_index, zJ, color=color.new(dirR > 0 ? i_buyColor : i_sellColor, 0), width=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.bottom, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.bottom, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.diamond, location.bottom, color.new(i_buyColor, 0),  size=size.normal, text="BJD", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.top,    color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.top,    color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.diamond, location.top,    color.new(i_sellColor, 0),  size=size.normal, text="BJD", textcolor=c_white)

// PRICE-PANE MIRROR (Pine v6 force_overlay): same entry signals projected onto the candlesticks.
plotshape(i_showGlow and buySignal,  "Buy Glow 1 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge,   force_overlay=true)
plotshape(i_showGlow and buySignal,  "Buy Glow 2 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large,  force_overlay=true)
plotshape(buySignal,                 "Buy (price)",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="BJD", textcolor=c_white, force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 1 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 2 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large, force_overlay=true)
plotshape(sellSignal,                "Sell (price)",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BJD", textcolor=c_white, force_overlay=true)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=i_dashBg, border_color=color.new(i_zColor, 55), border_width=1)
    string st = sigJump ? (dirR > 0 ? "JUMP UP" : "JUMP DOWN") : "NO JUMP"
    color  sc = sigJump ? (dirR > 0 ? i_buyColor : i_sellColor) : color.gray
    table.cell(dash, 0, 0, "Bipower Jump Detector", text_color=i_zColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_zColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "State",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                      text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "RV",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(RV, "#.######"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "BV",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(BV, "#.######"), text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "J = max(RV-BV,0)",      text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(J, "#.######"), text_color=i_jColor, text_size=size.small)
    table.cell(dash, 0, 5, "Jump-Z",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(zJ, "#.##"), text_color=zJ > i_zThresh ? i_sellColor : color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Direction",             text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, dirR > 0 ? "UP" : dirR < 0 ? "DOWN" : "FLAT", text_color=dirR > 0 ? i_buyColor : dirR < 0 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"BJD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"BJD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "BJD Buy",            "Bipower jump long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "BJD Sell",           "Bipower jump short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "BJD Any Signal",     "Any BJD signal on {{ticker}} {{interval}}")
alertcondition(sigJump,                            "BJD Significant",    "Significant jump detected on {{ticker}} {{interval}}")
alertcondition(jumpUp,                             "BJD Jump Up",        "Upward jump on {{ticker}} {{interval}}")
alertcondition(jumpDn,                             "BJD Jump Down",      "Downward jump on {{ticker}} {{interval}}")
alertcondition(zJ > zJ[1] and zJ > 0,              "BJD Z Rising",       "Jump-Z rising on {{ticker}} {{interval}}")
alertcondition(J > J[1],                           "BJD J Rising",       "Jump component rising on {{ticker}} {{interval}}")
alertcondition(RV > BV * 1.5,                      "BJD High Jump Ratio","RV exceeds 1.5 x BV on {{ticker}} {{interval}}")
alertcondition(zJ < -i_zThresh,                    "BJD Quiet Diffusion","Z below negative threshold on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "BJD Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"BJD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
