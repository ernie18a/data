# Lempel Ziv Trend Coder [forexobroker]

- url: https://www.tradingview.com/script/xUozxOgB-Lempel-Ziv-Trend-Coder-forexobroker/
- type: indicator
- pine_id: PUB;2cb6d582439d44f9a72536044cba5f28
- version: 1.0

## Description

Lempel Ziv Trend Coder encodes the recent sign sequence of price changes into 3-bit (sign[t], sign[t-1], sign[t-2]) windows and tracks the frequency distribution of the eight resulting patterns. When one pattern dominates the share, the price sequence is structurally biased — that is the trending regime. Direction comes from the up-bar fraction.

🔶 ALGORITHM

1. For each k in [0, N-3], encode (b0, b1, b2) where bi = close[k+i] > close[k+i+1].
2. Increment count[p] where p = b0 * 4 + b1 * 2 + b2 (0..7).
3. dominance = max(count) / sum(count). Uniform random = 0.125.
4. Trending regime when dominance >= threshold.
5. Direction bias from up-bar fraction in the same window.

🔶 SIGNAL LOGIC

- Buy: trending AND up-fraction > 0.5 AND close crosses EMA up AND not already long AND cooldown elapsed AND barstate.isconfirmed.
- Sell: trending AND up-fraction < 0.5 AND close crosses EMA down.
- Position-lock state machine.

🔶 INPUTS

- Sign Window (default 40)
- Pullback EMA Length (default 8)
- Min Dominance (default 0.20)
- Cooldown Bars (default 4)
- Visual: dashboard, glow, EMA toggle, buy / sell colors

🔶 ALERTS

LZT Buy, LZT Sell, LZT Any Signal, LZT Trend Start, LZT Chop Start, LZT Very Trendy, LZT Very Choppy, LZT EMA Up, LZT Webhook JSON.

🔶 LIMITATIONS

- 3-bit encoding ignores bar magnitude; a tiny tick contributes the same as a large move.
- "Distinct patterns observed" alone saturates at 8 quickly with N >= 40 bars; dominance is a more discriminative measure but still coarse.
- LZ true complexity is closer to a substring count than a pattern-frequency count; this is a tractable approximation.
- Direction comes from up-fraction, not the LZ measure itself; in true random regimes the direction signal is meaningless and the regime gate correctly mutes signals.

## Source Code

````pine
// © forexobroker
//@version=6
// ALGORITHM: Lempel-Ziv-style algorithmic complexity on the binary string of recent price-change
// signs. Encodes the last N bars as a sequence of 3-bit windows over (sign[t], sign[t-1], sign[t-2]).
// 8 possible patterns; the count of distinct patterns observed is the complexity measure.
// Low complexity = trending (the same 1-2 patterns repeat); high complexity = chop (all 8
// patterns appear). Signals fire on close/EMA cross within a low-complexity (trending) regime.
// Different from any oscillator: this measures structure of the sign sequence itself.
indicator("Lempel Ziv Trend Coder [forexobroker]", shorttitle="LZT [fob]", overlay=true, max_bars_back=500, max_labels_count=500, max_boxes_count=500, max_lines_count=500)

string g_calc   = "Lempel-Ziv"
string g_signal = "Signal Logic"
string g_visual = "Visual"

int   i_winLen   = input.int(40,    "Sign Window", minval=15, maxval=120, group=g_calc, tooltip="Bars whose sign sequence is encoded into 3-grams.")
int   i_emaLen   = input.int(8,    "Pullback EMA Length", minval=3, maxval=50, group=g_signal)
float i_domThr   = input.float(0.20,"Min Dominance (most-frequent pattern share)", minval=0.13, maxval=0.50, step=0.01, group=g_signal, tooltip="Most-frequent 3-gram share. Uniform random = 0.125. Threshold above = trending regime.")
int   i_cooldown = input.int(4,    "Cooldown Bars", minval=1, maxval=20, group=g_signal)
bool  i_showTable = input.bool(true, "Show Dashboard", group=g_visual)
bool  i_showGlow  = input.bool(true, "Show 3-Layer Glow", group=g_visual)
bool  i_showEma   = input.bool(true, "Show Pullback EMA", group=g_visual)
color i_buyColor  = input.color(#1de9b6, "Buy Color",  group=g_visual)
color i_sellColor = input.color(#ff5252, "Sell Color", group=g_visual)

color c_white = #ffffff

// ─── COMPLEXITY: COUNT 3-BIT PATTERN FREQUENCIES ───────────────────────────────
var int[] counts = array.new_int(8, 0)
for k = 0 to 7
    array.set(counts, k, 0)
int upCount = 0
int totalPatterns = 0
for k = 0 to i_winLen - 3
    int b0 = nz(close[k])     > nz(close[k + 1]) ? 1 : 0
    int b1 = nz(close[k + 1]) > nz(close[k + 2]) ? 1 : 0
    int b2 = nz(close[k + 2]) > nz(close[k + 3]) ? 1 : 0
    int p  = b0 * 4 + b1 * 2 + b2
    array.set(counts, p, array.get(counts, p) + 1)
    upCount += b0
    totalPatterns += 1

int maxCount = 0
int distinct = 0
for k = 0 to 7
    int c = array.get(counts, k)
    if c > maxCount
        maxCount := c
    if c > 0
        distinct += 1
float dominance = totalPatterns > 0 ? maxCount / float(totalPatterns) : 0.125
bool  trending  = dominance >= i_domThr

// Direction bias from up-bar fraction
float upFrac    = upCount / float(i_winLen - 2)
bool  bullBias  = trending and upFrac > 0.5
bool  bearBias  = trending and upFrac < 0.5

// ─── ENTRY TRIGGER ─────────────────────────────────────────────────────────────
float ema     = ta.ema(close, i_emaLen)
bool  crossUp = ta.crossover(close, ema)
bool  crossDn = ta.crossunder(close, ema)

bool entryUp   = bullBias and crossUp
bool entryDown = bearBias and crossDn

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

// ─── VISUAL ───────────────────────────────────────────────────────────────────
color emaCol = bullBias ? i_buyColor : bearBias ? i_sellColor : color.new(color.gray, 50)
plot(i_showEma ? ema : na, "Pullback EMA", color=emaCol, linewidth=2)

plotshape(i_showGlow and buySignal,  "Buy Glow 1",  shape.diamond, location.belowbar, color.new(i_buyColor, 70), size=size.huge)
plotshape(i_showGlow and buySignal,  "Buy Glow 2",  shape.diamond, location.belowbar, color.new(i_buyColor, 40), size=size.large)
plotshape(buySignal,                 "Buy Signal",  shape.diamond, location.belowbar, color.new(i_buyColor, 0),  size=size.normal, text="LZT up", textcolor=c_white)
plotshape(i_showGlow and sellSignal, "Sell Glow 1", shape.diamond, location.abovebar, color.new(i_sellColor, 70), size=size.huge)
plotshape(i_showGlow and sellSignal, "Sell Glow 2", shape.diamond, location.abovebar, color.new(i_sellColor, 40), size=size.large)
plotshape(sellSignal,                "Sell Signal", shape.diamond, location.abovebar, color.new(i_sellColor, 0),  size=size.normal, text="LZT dn", textcolor=c_white)

barcolor(buySignal ? i_buyColor : sellSignal ? i_sellColor : na)
bgcolor(bullBias ? color.new(i_buyColor, 95) : bearBias ? color.new(i_sellColor, 95) : na)

// ─── DASHBOARD ────────────────────────────────────────────────────────────────
if i_showTable and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 20), border_color=color.new(color.white, 80), border_width=1)
    string regimeTxt = trending ? (bullBias ? "TRENDING UP" : "TRENDING DOWN") : "CHOPPY"
    color  regimeCol = bullBias ? i_buyColor : bearBias ? i_sellColor : color.gray
    table.cell(dash, 0, 0, "Lempel Ziv Trend Coder", text_color=i_buyColor, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[fob]",                  text_color=color.gray, text_size=size.tiny)
    table.cell(dash, 0, 1, "Distinct Patterns",      text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(distinct) + " / 8",     text_color=c_white, text_size=size.small)
    table.cell(dash, 0, 2, "Dominance",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(dominance, "0.000"),    text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 3, "Threshold",              text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(i_domThr, "0.00"),      text_color=color.gray, text_size=size.small)
    table.cell(dash, 0, 4, "Up Fraction",            text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(upFrac, "0.00"),        text_color=upFrac > 0.5 ? i_buyColor : i_sellColor, text_size=size.small)
    table.cell(dash, 0, 5, "Regime",                 text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, regimeTxt,                text_color=regimeCol, text_size=size.small)
    table.cell(dash, 0, 6, "Position",               text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, posState ==  1 ? "LONG" : posState == -1 ? "SHORT" : "FLAT", text_color=posState ==  1 ? i_buyColor : posState == -1 ? i_sellColor : color.gray, text_size=size.small)
    table.cell(dash, 0, 7, "Last Signal",            text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(bar_index - lastSignalBar) + "b ago", text_color=c_white, text_size=size.small)

if buySignal
    alert('{"action":"BUY","indicator":"LZT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"dominance":' + str.tostring(dominance, "0.000") + '}', alert.freq_once_per_bar_close)
if sellSignal
    alert('{"action":"SELL","indicator":"LZT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"dominance":' + str.tostring(dominance, "0.000") + '}', alert.freq_once_per_bar_close)

alertcondition(buySignal,                                  "LZT Buy",          "LZ trending bull on {{ticker}} {{interval}} at {{close}}")
alertcondition(sellSignal,                                 "LZT Sell",         "LZ trending bear on {{ticker}} {{interval}} at {{close}}")
alertcondition(buySignal or sellSignal,                    "LZT Any Signal",   "Any LZT signal on {{ticker}} {{interval}}")
alertcondition(trending and not trending[1],               "LZT Trend Start",  "Trending regime entered on {{ticker}} {{interval}}")
alertcondition(not trending and trending[1],               "LZT Chop Start",   "Choppy regime entered on {{ticker}} {{interval}}")
alertcondition(distinct <= 3,                              "LZT Very Trendy",  "Only 3 or fewer patterns on {{ticker}} {{interval}}")
alertcondition(distinct >= 7,                              "LZT Very Choppy",  "7 or 8 patterns on {{ticker}} {{interval}}")
alertcondition(crossUp,                                    "LZT EMA Up",       "Close crossed EMA up on {{ticker}} {{interval}}")
alertcondition(buySignal or sellSignal,                    "LZT Webhook JSON", "{\"action\":\"signal\",\"indicator\":\"LZT\",\"ticker\":\"{{ticker}}\",\"interval\":\"{{interval}}\",\"price\":\"{{close}}\"}")
````
