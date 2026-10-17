# Allan Variance Stability Index [forexobroker]

- url: https://www.tradingview.com/script/Ppk21lwa-Allan-Variance-Stability-Index-forexobroker/
- type: indicator
- pine_id: PUB;d2ace8b803f8429dbd9d73743ca42926
- version: 1.0

## Description

Allan Variance Stability Index [forexobroker] adapts the Allan deviation — the standard tool for measuring atomic clock frequency stability — to financial returns. By computing the standard deviation of block-averaged log-returns across multiple timescales tau in {1, 2, 4, 8, 16, 32}, the script asks whether price drift behaves consistently or fragments across horizons. The single stability index S then collapses that multi-scale picture into one number that an adaptive median-and-sigma floor can monitor. The unique angle is borrowing a frequency-domain stability metric instead of a price-domain volatility one, so the script reads regime change rather than range size.

🔶 ALGORITHM

1. Log-returns r_t = log(close / close[1]) are computed and the last M (default 128) are used.
2. For each lag tau in {1, 2, 4, 8, 16, 32}: the return window is split into floor(M / tau) contiguous blocks, each block-averaged, and sigma(tau) is the standard deviation of those block averages.
3. The six log-sigmas are averaged and S = -stdev(log sigma(tau)) is computed — higher S means returns scale predictably across tau, lower S means timescales disagree.
4. An adaptive floor is computed each bar as median(S, adaptive median length default 80) minus k (default 1.0) times stdev(S) over the same window.
5. When S falls below the floor the regime is destabilising; the sign of close - close[momentum lookback default 3] arms a directional bias.
6. When S crosses back above the floor inside that armed bias, the entry fires — the script trades the trend that survived the instability.

🔶 SIGNAL LOGIC

- Buy: S crosses up through the floor AND active bias is bullish (close was above close[n] while S was under the floor) AND session filter passes AND position is not already long AND cooldown bars elapsed AND barstate.isconfirmed.
- Sell: S crosses up through the floor AND active bias is bearish AND session filter passes AND position is not already short AND cooldown bars elapsed AND barstate.isconfirmed.

The cross-back is the trigger; the bias is set during the instability window.

🔶 INPUTS

- Stability Calculation group: return window M default 128, adaptive median length default 80, floor k x sigma default 1.0.
- Signal Logic group: momentum lookback default 3, cooldown bars default 15.
- Filters group: session restriction (default 0000-2400).
- Visual group: dashboard, 3-layer glow, stability line color, floor color, buy and sell colors.

🔶 ALERTS

AVS Buy, AVS Sell, AVS Any Signal, AVS Floor Break, AVS Floor Reclaim, AVS Arm Up, AVS Arm Down, AVS Vol Expanding, AVS Vol Contracting, AVS Bias Flip, AVS Webhook JSON.

🔶 LIMITATIONS

- Needs M plus 32 confirmed returns of history before sigma(32) is reliable, so early-chart bars produce noisy S values.
- The Allan-style estimator was designed for stationary frequency oscillators; under structural market shifts S can stabilise around a new floor for several bars before the adaptive median catches up.
- Block averaging at large tau reduces the number of blocks, so sigma(32) is the noisiest leg of the curve and dominates S in low-history regimes.
- Defaults are tuned for liquid futures and crypto on intraday timeframes; very thin instruments produce zero-return blocks that pin sigma(1) and inflate S.
- The bias is set on the instability bar but only fires on the reclaim, so very short instability episodes can fire a signal with stale momentum context.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Allan Variance Stability Index. Borrowed from atomic-clock frequency stability analysis.
// Log-returns are block-averaged at lags tau in {1,2,4,8,16,32}; sigma(tau) is the stdev of those
// blocks. The stability index S = -stdev(log sigma(tau)) over the tau set — higher S means returns
// behave consistently across timescales (stable drift). When S falls through its adaptive floor
// (median - 1 sigma) the regime is destabilising and the script trades a pullback in the direction
// of 3-bar momentum; when S climbs back through the floor that pullback is the trend confirmation.
// Non-repainting: all stats are on confirmed bars, signals only on barstate.isconfirmed.
indicator("Allan Variance Stability Index [forexobroker]", shorttitle="AVS [fob]", overlay=false, max_bars_back=500)

string g_calc = "Stability Calculation"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_win     = input.int(128,  "Return Window M",       minval=64,  maxval=500, group=g_calc, tooltip="Number of log-returns used to estimate sigma(tau).")
int   i_medLen  = input.int(80,   "Adaptive Median Length",minval=20,  maxval=300, group=g_calc, tooltip="Window used to compute the median and stdev floor of S.")
float i_floorK  = input.float(1.0,"Floor k x Sigma",       minval=0.25, maxval=3.0, step=0.05, group=g_calc, tooltip="Floor = median(S) - k * stdev(S). Falling through arms a pullback, rising back through fires it.")
int   i_momLen  = input.int(3,    "Momentum Lookback",     minval=1,   maxval=20,  group=g_sig,  tooltip="Sign of close - close[n] sets the directional bias once instability is arming.")
int   i_cooldown= input.int(15,   "Cooldown Bars",         minval=1,   maxval=60,  group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                            group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                       group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                  group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                               group=g_vis)
color i_buyColor= input.color(#39ff14,"Buy Color",                                   group=g_vis)
color i_sellColor=input.color(#ff2d78,"Sell Color",                                  group=g_vis)
color i_lineColor=input.color(#00d4ff,"Stability Line",                              group=g_vis)
color i_floorColor=input.color(#ffaa00,"Floor Line",                                 group=g_vis)
color i_dashBg  = input.color(color.new(#0c1810, 16),"Dashboard BG",                 group=g_vis)

color c_white = #ffffff

float r = na(close[1]) ? 0.0 : math.log(close / close[1])

f_sigmaTau(int tau) =>
    int blocks = math.floor(i_win / math.max(tau, 1))
    float meanB = 0.0
    int   cnt   = 0
    if blocks >= 2
        for b = 0 to blocks - 1
            float s = 0.0
            for k = 0 to tau - 1
                s += nz(r[b * tau + k])
            float avg = s / math.max(tau, 1)
            meanB += avg
            cnt += 1
    meanB := cnt > 0 ? meanB / cnt : 0.0
    float varB = 0.0
    if blocks >= 2
        for b = 0 to blocks - 1
            float s = 0.0
            for k = 0 to tau - 1
                s += nz(r[b * tau + k])
            float avg = s / math.max(tau, 1)
            varB += math.pow(avg - meanB, 2)
    varB := cnt > 1 ? varB / (cnt - 1) : 0.0
    math.sqrt(math.max(varB, 1e-20))

float s1  = f_sigmaTau(1)
float s2  = f_sigmaTau(2)
float s4  = f_sigmaTau(4)
float s8  = f_sigmaTau(8)
float s16 = f_sigmaTau(16)
float s32 = f_sigmaTau(32)

float l1  = math.log(s1)
float l2  = math.log(s2)
float l4  = math.log(s4)
float l8  = math.log(s8)
float l16 = math.log(s16)
float l32 = math.log(s32)

float lMean = (l1 + l2 + l4 + l8 + l16 + l32) / 6.0
float lVar  = (math.pow(l1 - lMean, 2) + math.pow(l2 - lMean, 2) + math.pow(l4 - lMean, 2) + math.pow(l8 - lMean, 2) + math.pow(l16 - lMean, 2) + math.pow(l32 - lMean, 2)) / 5.0
float S     = -math.sqrt(math.max(lVar, 0.0))

float medS  = ta.median(S, i_medLen)
float sdS   = ta.stdev(S, i_medLen)
float floor_= medS - i_floorK * sdS

bool armUp   = S < floor_ and close > close[i_momLen]
bool armDown = S < floor_ and close < close[i_momLen]

var int bias = 0
if armUp
    bias := 1
if armDown
    bias := -1

bool cross = ta.crossover(S, floor_)
bool inSession = not i_useSess or not na(time(timeframe.period, i_sess))

bool entryUp   = inSession and cross and bias ==  1
bool entryDown = inSession and cross and bias == -1

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

plot(S,      "Stability S", color=i_lineColor, linewidth=2)
plot(medS,   "Median S",    color=color.new(color.silver, 30))
plot(floor_, "Floor",       color=i_floorColor, linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 60))
bgcolor(S < floor_ ? color.new(i_floorColor, 92) : na)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.circle, location.bottom, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.circle, location.bottom, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.circle, location.bottom, color.new(i_buyColor, 0),  size=size.normal, text="AVS", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.circle, location.top,    color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.circle, location.top,    color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.circle, location.top,    color.new(i_sellColor, 0),  size=size.normal, text="AVS", textcolor=c_white)

// PRICE-PANE MIRROR (Pine v6 force_overlay): the same entry signals projected onto the
// candlesticks so the trade is visible on the main chart even though this oscillator lives
// in its own pane. 3-layer neon glow preserved.
plotshape(i_showGlow and buySignal,  "Buy Glow 1 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 70), size=size.huge,   force_overlay=true)
plotshape(i_showGlow and buySignal,  "Buy Glow 2 (price)",  shape.triangleup,   location.belowbar, color.new(i_buyColor, 40), size=size.large,  force_overlay=true)
plotshape(buySignal,                 "Buy (price)",         shape.triangleup,   location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="AVS", textcolor=c_white, force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 1 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 70), size=size.huge,  force_overlay=true)
plotshape(i_showGlow and sellSignal, "Sell Glow 2 (price)", shape.triangledown, location.abovebar, color.new(i_sellColor, 40), size=size.large, force_overlay=true)
plotshape(sellSignal,                "Sell (price)",        shape.triangledown, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="AVS", textcolor=c_white, force_overlay=true)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 10, bgcolor=i_dashBg, border_color=color.new(i_lineColor, 55), border_width=1)
    string st = S < floor_ ? "INSTABILITY" : "STABLE"
    color  sc = S < floor_ ? i_floorColor : i_buyColor
    table.cell(dash, 0, 0, "Allan Variance Stability", text_color=i_lineColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                    text_color=color.new(i_lineColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Regime",                   text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, st,                         text_color=sc, text_size=size.small)
    table.cell(dash, 0, 2, "S (stability)",            text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(S, "#.####"),  text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 3, "Floor",                    text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(floor_, "#.####"), text_color=i_floorColor, text_size=size.small)
    table.cell(dash, 0, 4, "Sigma(1)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(s1, "#.######"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Sigma(8)",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(s8, "#.######"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 6, "Sigma(32)",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(s32, "#.######"), text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 7, "Bias",                     text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, bias ==  1 ? "UP" : bias == -1 ? "DOWN" : "NONE", text_color=bias ==  1 ? i_buyColor : bias == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 8, "Position",                 text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 9, "Last Signal",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"AVS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"AVS","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "AVS Buy",            "Stability reclaim long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "AVS Sell",           "Stability reclaim short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "AVS Any Signal",     "Any AVS signal on {{ticker}} {{interval}}")
alertcondition(S < floor_ and S[1] >= floor_,      "AVS Floor Break",    "S broke below floor on {{ticker}} {{interval}}")
alertcondition(ta.crossover(S, floor_),            "AVS Floor Reclaim",  "S reclaimed floor on {{ticker}} {{interval}}")
alertcondition(armUp,                              "AVS Arm Up",         "Instability arming long bias on {{ticker}} {{interval}}")
alertcondition(armDown,                            "AVS Arm Down",       "Instability arming short bias on {{ticker}} {{interval}}")
alertcondition(s1 > s1[1] and s8 > s8[1],          "AVS Vol Expanding",  "Multi-tau sigma rising on {{ticker}} {{interval}}")
alertcondition(s1 < s1[1] and s8 < s8[1],          "AVS Vol Contracting","Multi-tau sigma falling on {{ticker}} {{interval}}")
alertcondition(bias != bias[1],                    "AVS Bias Flip",      "AVS bias flipped on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "AVS Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"AVS\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
