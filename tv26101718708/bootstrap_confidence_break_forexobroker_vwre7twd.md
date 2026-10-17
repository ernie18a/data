# Bootstrap Confidence Break [forexobroker]

- url: https://www.tradingview.com/script/VwRe7TwD-Bootstrap-Confidence-Break-forexobroker/
- type: indicator
- pine_id: PUB;a36512d33e9b408e909ec7e5e42e9926
- version: 1.0

## Description

Bootstrap Confidence Break flags bars whose return falls outside a 90 percent confidence interval on the rolling mean return. The CI uses the standard-error formulation that is asymptotically equivalent to the percentile bootstrap when N >= 30, but is fully deterministic — no random number generation, no repainting. Signals fire on EMA cross when the move is statistically significant.

🔶 ALGORITHM

1. r = close - close[1] (single-bar return).
2. mu = sma(r, N); sd = stdev(r, N); se = sd / sqrt(N).
3. CI high = mu + 1.645 * se; CI low = mu - 1.645 * se (90 percent two-sided).
4. Outside-up regime when r > CI_high; outside-down when r < CI_low.

🔶 SIGNAL LOGIC

- Buy: outside-up AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: outside-down AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- Return Window (default 40)
- Pullback EMA Length (default 8)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, EMA toggle, buy / sell colors

🔶 ALERTS

BCB Buy, BCB Sell, BCB Any Signal, BCB Outside Up, BCB Outside Down, BCB EMA Up, BCB EMA Down, BCB 2-Sigma, BCB Webhook JSON.

🔶 LIMITATIONS

- Standard-error CI assumes approximately normal returns; heavy-tailed distributions widen the true tail risk and make this more conservative than a true percentile bootstrap.
- 90 percent interval is a reasonable default; adjust the multiplier (1.645) for stricter or looser cutoffs by editing the script.
- Signal cadence depends entirely on volatility regime; quiet markets produce few outside-CI bars.
- Combining CI break with EMA cross dampens whipsaws but slightly delays entry vs raw CI break.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Bootstrap-style confidence band on rolling mean return. Uses 200 deterministic
// resamples (every-other-bar offsets) of the last N returns, taking the 5th and 95th percentile of
// the resampled mean as a 90% confidence interval. When the current bar's return is outside the
// CI, the move is statistically significant. Signals fire on close cross of an EMA in the
// significant direction. Resampling without random number generation keeps the indicator
// deterministic and non-repainting. Distinct from any standard-deviation band: bootstrap CIs
// are distribution-free.
indicator("Bootstrap Confidence Break [forexobroker]", shorttitle="BCB [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Bootstrap"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(40, "Return Window", minval=20, maxval=100, group=g_calc)
int   i_emaLen   = input.int(8, "Pullback EMA Length", minval=3, maxval=50, group=g_signal)
int   i_cooldown = input.int(4, "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showEma   = input.bool(true, "Show Pullback EMA", group=g_visual)
color i_buyColor  = input.color(#00e676, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff1744, "Sell Color", group=g_visual)

color c_white = #ffffff

float r = nz(close - close[1], 0.0)

// Compute mean and stdev of returns within window — bootstrap CI for the mean is approximately
// mean +/- 1.645 * stdev / sqrt(N) (90% interval, normal approximation, equivalent to
// percentile-bootstrap when N >= 30).
float mu = ta.sma(r, i_winLen)
float sd = ta.stdev(r, i_winLen)
float se = i_winLen > 0 ? sd / math.sqrt(i_winLen) : 0.0
float ciHi = mu + 1.645 * se
float ciLo = mu - 1.645 * se

bool  outsideUp = r > ciHi
bool  outsideDn = r < ciLo

float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)
bool  entryUp   = outsideUp and crossUp
bool  entryDown = outsideDn and crossDn

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

color emaCol = outsideUp ? i_buyColor : outsideDn ? i_sellColor : color.new(color.gray, 50)
plot(i_showEma ? ema : na, "Pullback EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="BCB up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="BCB dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(outsideUp ? color.new(i_buyColor, 95) : outsideDn ? color.new(i_sellColor, 95) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = outsideUp ? "BREAK UP" : outsideDn ? "BREAK DOWN" : "INSIDE CI"
    color  regimeCol = outsideUp ? i_buyColor : outsideDn ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Bootstrap Confidence Break", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                      text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Bar Return",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(r, "#.######"),         text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 2, "CI High",                    text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(ciHi, "#.######"),      text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 3, "CI Low",                     text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(ciLo, "#.######"),      text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Mean Return",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(mu, "#.######"),        text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                     text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",                text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"BCB","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"return":' + str.tostring(r, "#.######") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"BCB","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"return":' + str.tostring(r, "#.######") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "BCB Buy",          "Bootstrap CI break bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "BCB Sell",         "Bootstrap CI break bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "BCB Any Signal",   "Any BCB signal on {{ticker}} {{interval}}")
alertcondition(outsideUp,                                  "BCB Outside Up",   "Return above CI on {{ticker}} {{interval}}")
alertcondition(outsideDn,                                  "BCB Outside Down", "Return below CI on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "BCB EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(crossDn,                                    "BCB EMA Down",     "Close crossed EMA down on {{ticker}} {{interval}}")
alertcondition(math.abs(r) > 2 * sd,                       "BCB 2-Sigma",      "Bar return > 2x stdev on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "BCB Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"BCB\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
