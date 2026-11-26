# Cumulative Delta Divergence [forexobroker]

- url: https://www.tradingview.com/script/cPFYllWo-Cumulative-Delta-Divergence-forexobroker/
- type: indicator
- pine_id: PUB;62dae4015b1749bdb6c1679dfea75578
- version: 1.0

## Description

Cumulative Delta Divergence detects exhaustion patterns where price extends but cumulative tick-rule signed volume does not follow. The z-scores of cumulative delta and price over the same window are differenced; sustained gaps mark institutional positioning against the current move. Signals fire on EMA cross in the resolution direction.

🔶 ALGORITHM

1. signed_vol = volume * sign(close - close[1]).
2. cum_delta = sum(signed_vol, N).
3. delta_z = cum_delta / (stdev(signed_vol, N) * sqrt(N)).
4. price_z = (close - sma(close, N)) / stdev(close, N).
5. divergence = price_z - delta_z. Bear divergence when divergence >= threshold; bull when <= -threshold.

🔶 SIGNAL LOGIC

- Buy: bull divergence AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: bear divergence AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- Cumulative Window (default 40)
- Pullback EMA Length (default 8)
- Min Divergence Z (default 0.30)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, EMA toggle, buy / sell colors

🔶 ALERTS

CDD Buy, CDD Sell, CDD Any Signal, CDD Bull Div On, CDD Bear Div On, CDD Strong Bear, CDD Strong Bull, CDD EMA Up, CDD Webhook JSON.

🔶 LIMITATIONS

- Tick-rule signed volume (sign of close - close[1]) is a proxy; true bid / ask delta requires order-book data not available in Pine.
- Forex broker volumes vary; instruments with consistent volume reporting produce cleaner divergences.
- Window N = 40 is the practical balance; shorter windows fire more but flag false divergences.
- Divergence resolution timing varies; some divergences last many bars before resolving.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Cumulative tick-rule signed volume vs price divergence. For each bar, signed volume
// = volume * sign(close - close[1]). Cumulative delta is the running sum over the window. The
// divergence between cumulative delta direction and price direction signals exhaustion: when
// price makes a new high but cumulative delta does not (bearish divergence), institutions are
// selling into strength. Signals fire on the resolution — close cross of an EMA against the prior
// price extreme. Distinct from OBV: this uses bar sign, not just volume direction, and explicitly
// looks for divergence resolutions.
indicator("Cumulative Delta Divergence [forexobroker]", shorttitle="CDD [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Cumulative Delta"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(40, "Cumulative Window", minval=10, maxval=200, group=g_calc)
int   i_emaLen   = input.int(8, "Pullback EMA Length", minval=3, maxval=50, group=g_signal)
float i_divThr   = input.float(0.30,"Min Divergence Z", minval=0.1, maxval=3.0, step=0.1, group=g_signal)
int   i_cooldown = input.int(4, "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showEma   = input.bool(true, "Show Pullback EMA", group=g_visual)
color i_buyColor  = input.color(#1de9b6, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff5252, "Sell Color", group=g_visual)

color c_white = #ffffff

float signedVol = volume * (close > close[1] ? 1.0 : close < close[1] ? -1.0 : 0.0)
float cumDelta  = math.sum(signedVol, i_winLen)
float deltaSd   = ta.stdev(signedVol, i_winLen) * math.sqrt(i_winLen)
float deltaZ    = deltaSd > 0 ? cumDelta / deltaSd : 0.0

// price z-score (price minus mean over window, normalised)
float priceMa = ta.sma(close, i_winLen)
float priceSd = ta.stdev(close, i_winLen)
float priceZ  = priceSd > 0 ? (close - priceMa) / priceSd : 0.0

float divergence = priceZ - deltaZ  // positive: price ahead, delta behind (bear divergence)
bool  bearDiv = divergence >=  i_divThr  // price up but delta isn't following
bool  bullDiv = divergence <= -i_divThr  // price down but delta isn't following

float ema     = ta.ema(close, i_emaLen)
bool  crossDn = ta.crossunder(close, ema)
bool  crossUp = ta.crossover(close, ema)
bool  entryUp   = bullDiv and crossUp
bool  entryDown = bearDiv and crossDn

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

color emaCol = bullDiv ? i_buyColor : bearDiv ? i_sellColor : color.new(color.gray, 50)
plot(i_showEma ? ema : na, "Pullback EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="CDD up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="CDD dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullDiv ? color.new(i_buyColor, 94) : bearDiv ? color.new(i_sellColor, 94) : na)

if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = bearDiv ? "BEAR DIVERGENCE" : bullDiv ? "BULL DIVERGENCE" : "ALIGNED"
    color  regimeCol = bearDiv ? i_sellColor : bullDiv ? i_buyColor : color.gray
    table.cell(dash, 0, 0, "Cumulative Delta Divergence", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                       text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Cum Delta Z",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(deltaZ, "0.00"),         text_color=deltaZ > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 2, "Price Z",                     text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(priceZ, "0.00"),         text_color=priceZ > 0 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 3, "Divergence",                  text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(divergence, "0.00"),     text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 4, "Threshold",                   text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(i_divThr, "0.00"),       text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                      text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                     text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",                    text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"CDD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"divergence":' + str.tostring(divergence, "0.00") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"CDD","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"divergence":' + str.tostring(divergence, "0.00") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "CDD Buy",          "Bullish delta divergence resolved on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "CDD Sell",         "Bearish delta divergence resolved on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "CDD Any Signal",   "Any CDD signal on {{ticker}} {{interval}}")
alertcondition(bullDiv and not bullDiv[1],                 "CDD Bull Div On",  "Bull divergence detected on {{ticker}} {{interval}}")
alertcondition(bearDiv and not bearDiv[1],                 "CDD Bear Div On",  "Bear divergence detected on {{ticker}} {{interval}}")
alertcondition(divergence >= 1.0,                          "CDD Strong Bear",  "Strong bear divergence on {{ticker}} {{interval}}")
alertcondition(divergence <= -1.0,                         "CDD Strong Bull",  "Strong bull divergence on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "CDD EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "CDD Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"CDD\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
