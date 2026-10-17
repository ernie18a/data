# Adaptive Sharpe Regime [forexobroker]

- url: https://www.tradingview.com/script/1AbetLW4-Adaptive-Sharpe-Regime-forexobroker/
- type: indicator
- pine_id: PUB;4fc340a6522e4e17a36993cbecd5f255
- version: 1.0

## Description

Adaptive Sharpe Regime [forexobroker] computes a rolling Sharpe ratio of bar returns and sorts the result into directional regime tiers, then times entries with a reclaim-EMA cross. The unique angle is a Newey-West lag-1 autocovariance correction that stops serial correlation in returns from artificially inflating the Sharpe, making the regime read self-normalising and comparable across instruments and timeframes.

🔶 ALGORITHM

1. Compute per-bar returns (log returns by default, or simple returns) and their rolling mean and variance over the Sharpe window.
2. Estimate the lag-1 autocovariance of demeaned returns over the same window.
3. Apply the Newey-West correction: corrected variance = variance + 2 x autocovariance, then take the square root for the corrected volatility.
4. Sharpe = mean return / corrected volatility (guarded against zero volatility).
5. Sort the Sharpe into five regime tiers using the Strong and Mild thresholds: strong+ (+2), mild+ (+1), flat (0), mild- (-1), strong- (-2). The tier sign is the directional bias.
6. With a bias set, a close crossover (long) or crossunder (short) of the reclaim EMA times the actual entry. Signals respect an optional strong-only filter, a bar cooldown, position-lock, and bar-close confirmation. Non-repainting.

🔶 SIGNAL LOGIC

- Buy: in-session AND tier is tradable AND bias = +1 AND close crosses over the reclaim EMA AND position not already long AND cooldown elapsed AND barstate.isconfirmed (then position locks long).
- Sell: in-session AND tier is tradable AND bias = -1 AND close crosses under the reclaim EMA AND position not already short AND cooldown elapsed AND barstate.isconfirmed (then position locks short).
- Only fires when the Sharpe tier is tradable (mild or stronger; strong-only if "Require Strong Tier" is on).

🔶 INPUTS

- Sharpe group: window length over which returns and Sharpe are measured; default Sharpe Window 40.
- Returns mode: log vs simple returns toggle; default Log Returns on.
- Newey-West: toggle the lag-1 autocovariance variance inflation; default on.
- Regime tiers: Strong and Mild absolute-Sharpe thresholds; default Strong Sharpe 0.8.
- Mild threshold: lower band for the mild tier; default Mild Sharpe 0.2.
- Volatility reference: ATR length used for the dashboard reference; default ATR Length 14.
- Signal Logic group: entry reclaim EMA, strong-only filter, cooldown; default Entry Reclaim EMA 9.
- Cooldown: minimum bars between signals; default Cooldown Bars 5.
- Filters group: optional session restriction and session window; default Restrict to Session off.
- Visual group: dashboard, 3-layer glow, reclaim EMA, buy/sell colors, dashboard background.

🔶 ALERTS

ASH Buy, ASH Sell, ASH Any Signal, ASH Strong Plus, ASH Strong Minus, ASH Bias Bull, ASH Bias Bear, ASH EMA Up, ASH EMA Down, ASH Sharpe Zero, ASH Tier Change, ASH Armed, ASH Webhook JSON.

🔶 LIMITATIONS

- The Sharpe ratio needs a full window of returns to stabilise, so the first Sharpe Window bars are warm-up and tiers should not be trusted there.
- The Newey-West correction only addresses lag-1 serial correlation; higher-order autocorrelation is not modelled and the corrected variance is clamped to a small positive floor.
- Regime tiers are statistical classifications, not forecasts; a strong tier describes recent risk-adjusted drift, not future returns.
- Default thresholds are tuned for liquid instruments; thin or gappy symbols can produce unstable Sharpe values.
- Entries confirm on bar close, so the reclaim-EMA cross is acknowledged with one-bar lag versus intrabar price.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Adaptive Sharpe Regime. A rolling Sharpe ratio of bar returns is computed, then
// the return variance is Newey-West corrected with the lag-1 autocovariance so serial
// correlation does not inflate it. The corrected Sharpe is sorted into regime tiers (strong+,
// mild+, flat, mild-, strong-). The tier sign is the bias and a reclaim-EMA cross times
// entries. Non-repainting, bar-close, self-normalising across instruments.
indicator("Adaptive Sharpe Regime [forexobroker]", shorttitle="ASH [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc = "Sharpe"
string g_sig  = "Signal Logic"
string g_filt = "Filters"
string g_vis  = "Visual"

int   i_shLen   = input.int(40,   "Sharpe Window",         minval=10, maxval=200, group=g_calc, tooltip="Bars of returns the Sharpe ratio is computed over.")
bool  i_useLog  = input.bool(true,"Log Returns",                                  group=g_calc, tooltip="On = log returns; Off = simple returns.")
bool  i_newey   = input.bool(true,"Newey-West Correction",                        group=g_calc, tooltip="Inflate variance by the lag-1 autocovariance term.")
float i_strongS = input.float(0.8,"Strong Sharpe",         minval=0.2, maxval=3.0, step=0.1, group=g_calc, tooltip="|Sharpe| above this = strong regime.")
float i_mildS   = input.float(0.2,"Mild Sharpe",           minval=0.0, maxval=2.0, step=0.1, group=g_calc, tooltip="|Sharpe| above this but below Strong = mild.")
int   i_atrLen  = input.int(14,   "ATR Length",            minval=5,  maxval=50, group=g_calc)
int   i_emaLen  = input.int(9,    "Entry Reclaim EMA",     minval=2,  maxval=50, group=g_sig, tooltip="After the Sharpe tier sets a bias, a close-cross of this EMA in that direction times the entry.")
bool  i_strongOnly=input.bool(false,"Require Strong Tier",                        group=g_sig, tooltip="On = only trade in the strong Sharpe tier.")
int   i_cooldown= input.int(5,    "Cooldown Bars",         minval=1,  maxval=40, group=g_sig)
bool  i_useSess = input.bool(false,"Restrict to Session",                         group=g_filt)
string i_sess   = input.session("0000-2400","Session Window",                     group=g_filt)
bool  i_showTable=input.bool(true,"Show Dashboard",                                group=g_vis)
bool  i_showGlow= input.bool(true,"Show 3-Layer Glow",                             group=g_vis)
bool  i_showEma = input.bool(true,"Show Reclaim EMA",                              group=g_vis)
color i_buyColor= input.color(#90f1ef,"Buy Color",                                 group=g_vis)
color i_sellColor=input.color(#ffb3c6,"Sell Color",                                group=g_vis)
color i_dashBg  = input.color(color.new(#03151a, 14),"Dashboard BG",              group=g_vis)

color c_white = #ffffff

float atr   = nz(ta.atr(i_atrLen), 0.0)
float ret   = i_useLog ? math.log(close / close[1]) : close / close[1] - 1.0
float mu    = ta.sma(ret, i_shLen)
float varr  = ta.variance(ret, i_shLen)
float acov  = ta.sma((ret - mu) * (nz(ret[1]) - mu), i_shLen)
float varNW = i_newey ? varr + 2.0 * acov : varr
float sd    = math.sqrt(math.max(varNW, 1e-12))
float sharpe= sd > 0 ? mu / sd : 0.0
bool  inSession = not i_useSess or not na(time(timeframe.period, i_sess))

int tier = sharpe >=  i_strongS ? 2 : sharpe >=  i_mildS ? 1 : sharpe <= -i_strongS ? -2 : sharpe <= -i_mildS ? -1 : 0
int bias = tier >= 1 ? 1 : tier <= -1 ? -1 : 0
bool strong = math.abs(tier) == 2
bool tradable = i_strongOnly ? strong : math.abs(tier) >= 1
float emaFast = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, emaFast)
bool  crossDn = ta.crossunder(close, emaFast)
bool entryUp   = inSession and tradable and bias ==  1 and crossUp
bool entryDown = inSession and tradable and bias == -1 and crossDn

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

plot(i_showEma ? emaFast : na, "Reclaim EMA", color=bias == 1 ? color.new(i_buyColor, 30) : bias == -1 ? color.new(i_sellColor, 30) : color.new(color.gray, 50), linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.square, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.square, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy",         shape.square, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="ASH", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.square, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.square, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell",        shape.square, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="ASH", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(tier == 2 ? color.new(i_buyColor, 88) : tier == 1 ? color.new(i_buyColor, 94) : tier == -2 ? color.new(i_sellColor, 88) : tier == -1 ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=i_dashBg, border_color=color.new(i_buyColor, 50), border_width=2)
    string tt = tier == 2 ? "STRONG +" : tier == 1 ? "MILD +" : tier == -1 ? "MILD -" : tier == -2 ? "STRONG -" : "FLAT"
    color  tc = tier >= 1 ? i_buyColor : tier <= -1 ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Adaptive Sharpe",       text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                 text_color=color.new(i_buyColor, 50), text_size=size.tiny)
    table.cell(dash, 0, 1, "Sharpe Tier",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, tt,                      text_color=tc, text_size=size.small)
    table.cell(dash, 0, 2, "Sharpe",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(sharpe, "0.000"), text_color=sharpe >= 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Mean Ret",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(mu * 100, "0.000") + "%", text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 4, "NW Vol",                text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(sd * 100, "0.000") + "%", text_color=color.silver, text_size=size.small)
    table.cell(dash, 0, 5, "Tradable",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, tradable ? "YES" : "NO", text_color=tradable ? i_buyColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 6, "Position",              text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",           text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"ASH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"ASH","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                          "ASH Buy",            "Positive-Sharpe long on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                         "ASH Sell",           "Negative-Sharpe short on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,            "ASH Any Signal",     "Any ASH signal on {{ticker}} {{interval}}")
alertcondition(tier == 2 and tier[1] != 2,         "ASH Strong Plus",    "Strong positive Sharpe on {{ticker}} {{interval}}")
alertcondition(tier == -2 and tier[1] != -2,       "ASH Strong Minus",   "Strong negative Sharpe on {{ticker}} {{interval}}")
alertcondition(bias == 1 and bias[1] != 1,         "ASH Bias Bull",      "Sharpe bias turned bullish on {{ticker}} {{interval}}")
alertcondition(bias == -1 and bias[1] != -1,       "ASH Bias Bear",      "Sharpe bias turned bearish on {{ticker}} {{interval}}")
alertcondition(crossUp,                            "ASH EMA Up",         "Reclaim EMA crossed up on {{ticker}} {{interval}}")
alertcondition(crossDn,                            "ASH EMA Down",       "Reclaim EMA crossed down on {{ticker}} {{interval}}")
alertcondition(ta.cross(sharpe, 0),                "ASH Sharpe Zero",    "Sharpe crossed zero on {{ticker}} {{interval}}")
alertcondition(tier != tier[1],                    "ASH Tier Change",    "Sharpe tier changed on {{ticker}} {{interval}}")
alertcondition(tradable and not tradable[1],       "ASH Armed",          "Sharpe regime became tradable on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,            "ASH Webhook JSON",   "{\"action\":\"signal\",\"indicator\":\"ASH\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
