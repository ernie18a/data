<!-- tradingview-pine-id: PUB;84808bdd2a4a4990a840a9ce63d0a4af -->
<!-- tradingviewscripts-format: 1 -->
# RSI & Stoch Multi-TF Watchlist · v6

Source: https://www.tradingview.com/script/GIk3Zr0C-RSI-Stoch-Multi-TF-Watchlist/

## Description

RSI and Stochastic Multi-TF Watchlist evaluates up to ten user-selected symbols and shows, in a single panel on the chart, the RSI and Stochastic values for each one on three configurable timeframes.
For every symbol the script computes the RSI and the smoothed Stochastic %K on each of the three timeframes you select. The values are displayed in a single table with color-coded cells: green when an indicator is oversold, red when overbought, gray in the neutral zone. Cells in oversold or overbought territory are bolded so extreme readings stand out at a glance.
The panel shows, for every symbol: the symbol name, then the RSI and Stochastic value pairs for timeframe one, timeframe two and timeframe three. The header shows the count of active symbols.
Settings include ten symbol picker slots (leave any empty to skip it), three timeframe inputs (the same three timeframes are used for both RSI and Stochastic), RSI length, Stochastic %K length and smooth, the overbought and oversold thresholds for both indicators, and the panel position.
Limitations. The script uses one request.security() call per symbol per timeframe, so it is capped at thirty calls (three timeframes times ten symbols) by Pine's call budget. Because of that, the same three timeframes are used for RSI and for Stochastic. If you need independent timeframes for each indicator, the symbol count has to be reduced to five or six. The companion indicator OB Watchlist Distance uses the same architecture for Order Block scanning and is published separately.
Recommended use. Configure the three timeframes to match the horizons you trade, for example fifteen minutes, one hour and four hours for intraday scanning, or four hours, one day and one week for swing context. Tune the overbought and oversold thresholds to match the volatility of your instruments.

---

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  RSI & Stochastic Multi-TF Watchlist · v6
//  ────────────────────────────
//  For each symbol (up to 10), shows RSI and Stochastic %K on 3 shared TFs.
//  Cells color-coded: red = overbought, green = oversold, gray = neutral.
//  Total: 30 request.security() calls (3 TFs × 10 symbols).
// ════════════════════════════════════════════════════════════════════════════

indicator("RSI & Stoch Multi-TF Watchlist · v6", overlay=true,
     max_boxes_count=10, max_labels_count=10)

// ── UDTs ─────────────────────────────────────────────────────────────────
type SymInfo
    string raw
    string short
    bool   valid

type SymbolOsc
    float rsi0
    float stk0
    float rsi1
    float stk1
    float rsi2
    float stk2

// ── Helpers ───────────────────────────────────────────────────────────────
fPos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        =>              position.bottom_center

fShort(string s) =>
    int idx = str.pos(s, ":")
    idx >= 0 ? str.substring(s, idx + 1) : s

string FALLBACK = "BINANCE:BTCUSDT"

// ── Inputs ────────────────────────────────────────────────────────────────
string G_WL = "── Watchlist (max 10, empty = skip) ──"
s0 = input.symbol("BINANCE:BTCUSDT",  "① Symbol 1",  group=G_WL)
s1 = input.symbol("BINANCE:ETHUSDT",  "② Symbol 2",  group=G_WL)
s2 = input.symbol("BINANCE:SOLUSDT",  "③ Symbol 3",  group=G_WL)
s3 = input.symbol("", "④ Symbol 4",  group=G_WL)
s4 = input.symbol("", "⑤ Symbol 5",  group=G_WL)
s5 = input.symbol("", "⑥ Symbol 6",  group=G_WL)
s6 = input.symbol("", "⑦ Symbol 7",  group=G_WL)
s7 = input.symbol("", "⑧ Symbol 8",  group=G_WL)
s8 = input.symbol("", "⑨ Symbol 9",  group=G_WL)
s9 = input.symbol("", "⑩ Symbol 10", group=G_WL)

string G_TF = "── Timeframes (RSI & Stoch use the same 3) ──"
tf0 = input.timeframe("15",  "① TF 1", group=G_TF)
tf1 = input.timeframe("60",  "② TF 2", group=G_TF)
tf2 = input.timeframe("240", "③ TF 3", group=G_TF)

string G_IND = "── Indicators ──"
rsiLen      = input.int(14, "RSI length",     minval=1, group=G_IND)
stochKLen   = input.int(14, "Stoch K length", minval=1, group=G_IND)
stochSmooth = input.int(3,  "Stoch smooth",   minval=1, group=G_IND)

string G_V = "── Visuals ──"
showPanel = input.bool(true, "Show panel", group=G_V)
rsiOB     = input.float(70.0, "RSI overbought",   minval=50, maxval=95, step=5, group=G_V)
rsiOS     = input.float(30.0, "RSI oversold",     minval=5,  maxval=50, step=5, group=G_V)
stkOB     = input.float(80.0, "Stoch overbought", minval=50, maxval=95, step=5, group=G_V)
stkOS     = input.float(20.0, "Stoch oversold",   minval=5,  maxval=50, step=5, group=G_V)
panelPos  = input.string("Bottom Right", "Panel position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Bottom Center"], group=G_V)

// ── Build syms ────────────────────────────────────────────────────────────
string[] rawInputs = array.from(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9)
var SymInfo[] syms = array.new<SymInfo>(10)
array.clear(syms)
for i = 0 to 9
    s = array.get(rawInputs, i)
    if str.length(s) > 0
        array.push(syms, SymInfo.new(s, fShort(s), true))

nSyms = array.size(syms)
while array.size(syms) < 10
    array.push(syms, SymInfo.new(FALLBACK, fShort(FALLBACK), false))

// ── IIFE: RSI + Stochastic %K ────────────────────────────────────────────
osc_data() =>
    rsi = ta.rsi(close, rsiLen)
    float hh = ta.highest(high, stochKLen)
    float ll = ta.lowest(low, stochKLen)
    float rawK = (close - ll) / math.max(hh - ll, syminfo.mintick) * 100.0
    stk = ta.sma(rawK, stochSmooth)
    [rsi, stk]

// ── 30 request.security() calls (3 TFs × 10 symbols) ─────────────────────
[rsi00, stk00] = request.security(array.get(syms, 0).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi01, stk01] = request.security(array.get(syms, 0).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi02, stk02] = request.security(array.get(syms, 0).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi10, stk10] = request.security(array.get(syms, 1).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi11, stk11] = request.security(array.get(syms, 1).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi12, stk12] = request.security(array.get(syms, 1).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi20, stk20] = request.security(array.get(syms, 2).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi21, stk21] = request.security(array.get(syms, 2).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi22, stk22] = request.security(array.get(syms, 2).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi30, stk30] = request.security(array.get(syms, 3).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi31, stk31] = request.security(array.get(syms, 3).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi32, stk32] = request.security(array.get(syms, 3).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi40, stk40] = request.security(array.get(syms, 4).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi41, stk41] = request.security(array.get(syms, 4).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi42, stk42] = request.security(array.get(syms, 4).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi50, stk50] = request.security(array.get(syms, 5).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi51, stk51] = request.security(array.get(syms, 5).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi52, stk52] = request.security(array.get(syms, 5).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi60, stk60] = request.security(array.get(syms, 6).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi61, stk61] = request.security(array.get(syms, 6).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi62, stk62] = request.security(array.get(syms, 6).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi70, stk70] = request.security(array.get(syms, 7).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi71, stk71] = request.security(array.get(syms, 7).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi72, stk72] = request.security(array.get(syms, 7).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi80, stk80] = request.security(array.get(syms, 8).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi81, stk81] = request.security(array.get(syms, 8).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi82, stk82] = request.security(array.get(syms, 8).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

[rsi90, stk90] = request.security(array.get(syms, 9).raw, tf0, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi91, stk91] = request.security(array.get(syms, 9).raw, tf1, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)
[rsi92, stk92] = request.security(array.get(syms, 9).raw, tf2, osc_data(), barmerge.gaps_off, barmerge.lookahead_off)

// ── Build SymbolOsc array ─────────────────────────────────────────────────
var SymbolOsc[] oscArr = array.new<SymbolOsc>(10)
array.set(oscArr, 0, SymbolOsc.new(rsi00, stk00, rsi01, stk01, rsi02, stk02))
array.set(oscArr, 1, SymbolOsc.new(rsi10, stk10, rsi11, stk11, rsi12, stk12))
array.set(oscArr, 2, SymbolOsc.new(rsi20, stk20, rsi21, stk21, rsi22, stk22))
array.set(oscArr, 3, SymbolOsc.new(rsi30, stk30, rsi31, stk31, rsi32, stk32))
array.set(oscArr, 4, SymbolOsc.new(rsi40, stk40, rsi41, stk41, rsi42, stk42))
array.set(oscArr, 5, SymbolOsc.new(rsi50, stk50, rsi51, stk51, rsi52, stk52))
array.set(oscArr, 6, SymbolOsc.new(rsi60, stk60, rsi61, stk61, rsi62, stk62))
array.set(oscArr, 7, SymbolOsc.new(rsi70, stk70, rsi71, stk71, rsi72, stk72))
array.set(oscArr, 8, SymbolOsc.new(rsi80, stk80, rsi81, stk81, rsi82, stk82))
array.set(oscArr, 9, SymbolOsc.new(rsi90, stk90, rsi91, stk91, rsi92, stk92))

// ── Panel ────────────────────────────────────────────────────────────────
var table t = table.new(fPos(panelPos), 7, 11,
     bgcolor=color.new(color.black, 20), border_width=1,
     border_color=color.new(color.gray, 50))

if barstate.islast and showPanel
    table.cell(t, 0, 0, "Sym (" + str.tostring(nSyms) + ")", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 1, 0, "RSI " + tf0, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 2, 0, "Stk " + tf0, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 3, 0, "RSI " + tf1, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 4, 0, "Stk " + tf1, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 5, 0, "RSI " + tf2, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 6, 0, "Stk " + tf2, text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)

    for i = 0 to nSyms - 1
        SymInfo sym = array.get(syms, i)
        if not sym.valid
            continue
        SymbolOsc osc = array.get(oscArr, i)

        color cR0 = osc.rsi0 > rsiOB ? color.new(color.red, 60) : osc.rsi0 < rsiOS ? color.new(color.green, 60) : color.new(color.gray, 80)
        color cR1 = osc.rsi1 > rsiOB ? color.new(color.red, 60) : osc.rsi1 < rsiOS ? color.new(color.green, 60) : color.new(color.gray, 80)
        color cR2 = osc.rsi2 > rsiOB ? color.new(color.red, 60) : osc.rsi2 < rsiOS ? color.new(color.green, 60) : color.new(color.gray, 80)
        color cS0 = osc.stk0 > stkOB ? color.new(color.red, 60) : osc.stk0 < stkOS ? color.new(color.green, 60) : color.new(color.gray, 80)
        color cS1 = osc.stk1 > stkOB ? color.new(color.red, 60) : osc.stk1 < stkOS ? color.new(color.green, 60) : color.new(color.gray, 80)
        color cS2 = osc.stk2 > stkOB ? color.new(color.red, 60) : osc.stk2 < stkOS ? color.new(color.green, 60) : color.new(color.gray, 80)

        bool bR0 = osc.rsi0 > rsiOB or osc.rsi0 < rsiOS
        bool bR1 = osc.rsi1 > rsiOB or osc.rsi1 < rsiOS
        bool bR2 = osc.rsi2 > rsiOB or osc.rsi2 < rsiOS
        bool bS0 = osc.stk0 > stkOB or osc.stk0 < stkOS
        bool bS1 = osc.stk1 > stkOB or osc.stk1 < stkOS
        bool bS2 = osc.stk2 > stkOB or osc.stk2 < stkOS

        table.cell(t, 0, i + 1, sym.short,                     text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 70), text_formatting=text.format_bold)
        table.cell(t, 1, i + 1, str.tostring(osc.rsi0, "#.#"), text_color=color.white, text_size=size.tiny, bgcolor=cR0, text_formatting=bR0 ? text.format_bold : text.format_none)
        table.cell(t, 2, i + 1, str.tostring(osc.stk0, "#.#"), text_color=color.white, text_size=size.tiny, bgcolor=cS0, text_formatting=bS0 ? text.format_bold : text.format_none)
        table.cell(t, 3, i + 1, str.tostring(osc.rsi1, "#.#"), text_color=color.white, text_size=size.tiny, bgcolor=cR1, text_formatting=bR1 ? text.format_bold : text.format_none)
        table.cell(t, 4, i + 1, str.tostring(osc.stk1, "#.#"), text_color=color.white, text_size=size.tiny, bgcolor=cS1, text_formatting=bS1 ? text.format_bold : text.format_none)
        table.cell(t, 5, i + 1, str.tostring(osc.rsi2, "#.#"), text_color=color.white, text_size=size.tiny, bgcolor=cR2, text_formatting=bR2 ? text.format_bold : text.format_none)
        table.cell(t, 6, i + 1, str.tostring(osc.stk2, "#.#"), text_color=color.white, text_size=size.tiny, bgcolor=cS2, text_formatting=bS2 ? text.format_bold : text.format_none)
````
