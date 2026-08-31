<!-- tradingview-pine-id: PUB;1a3a654c2fc64487a72b7af6f62a01bb -->
<!-- tradingviewscripts-format: 1 -->
# Fibo Multi-Symbol Watchlist · v6

Source: https://www.tradingview.com/script/lMn3M7T3-Fibonacci-Multi-Symbol-Watchlist/

## Description

Fibo Multi-Symbol Watchlist evaluates up to ten user-selected symbols and shows, in a single panel on the chart, the price at each standard Fibonacci retracement level for every symbol on its own configurable timeframe.
For every symbol the script detects the most recent swing high and swing low on the chosen timeframe using pivot detection with a configurable swing length and lookback window. The seven standard retracement levels (zero percent, twenty-three point six, thirty-eight point two, fifty, sixty-one point eight, seventy-eight point six, and one hundred percent) are computed between the swing low (zero percent) and the swing high (one hundred percent). The current price is also shown as a reference column.
The level closest to the current price is automatically highlighted. When the distance between the price and that level is within the configured proximity threshold, its cell turns yellow and is bolded so the nearest level stands out at a glance. If no recent swing has been detected within the lookback window, the cells show a dash and no level is highlighted.
Settings include ten symbol and timeframe pairs (leave any symbol empty to skip it), pivot swing length, pivot lookback in bars, the proximity percentage for highlighting the nearest level, and the panel position. Each symbol has its own timeframe input, so the same panel can show a one-hour fibo for Bitcoin, a four-hour fibo for Ethereum, and a daily fibo for any other symbol at the same time.
Limitations. The script uses one request.security() call per symbol, so it is capped at ten symbols by Pine's call budget. The fibo is always drawn from the swing low to the swing high; for downtrends the user can interpret the levels inversely. Only the seven standard retracement levels are included; extension levels (one hundred twenty-seven point two percent, one hundred sixty-one point eight percent, and so on) are not shown.
Recommended use. Set the timeframe per symbol to match the analysis horizon you trade. For intraday scalping, one hour to four hours usually works well. For swing trading, daily to weekly. Adjust the swing length to ignore noise on the selected timeframe and the proximity threshold to match the volatility of the instruments.

---

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  Fibo Multi-Symbol Watchlist · v6
//  ────────────────────────────
//  Per-symbol Fibonacci panel. Each symbol has its own TF input. Panel
//  shows the price at each standard fibo level. The level nearest to the
//  current price (within threshold) is highlighted in yellow.
// ════════════════════════════════════════════════════════════════════════════

indicator("Fibo Multi-Symbol Watchlist · v6", overlay=true,
     max_boxes_count=10, max_labels_count=10)

// ── UDTs ─────────────────────────────────────────────────────────────────
type SymInfo
    string raw
    string short
    string tf
    bool   valid

type FiboData
    float l0
    float l236
    float l382
    float l500
    float l618
    float l786
    float l100
    float close

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

string FALLBACK    = "BINANCE:BTCUSDT"
string FALLBACK_TF = "60"

// ── Inputs ────────────────────────────────────────────────────────────────
string G_WL = "── Watchlist (TF per symbol) ──"
s0  = input.symbol("BINANCE:BTCUSDT",  "① Ticker", group=G_WL, inline="r0")
tf0 = input.timeframe("60",              "TF",      group=G_WL, inline="r0")
s1  = input.symbol("BINANCE:ETHUSDT",  "② Ticker", group=G_WL, inline="r1")
tf1 = input.timeframe("60",              "TF",      group=G_WL, inline="r1")
s2  = input.symbol("BINANCE:SOLUSDT",  "③ Ticker", group=G_WL, inline="r2")
tf2 = input.timeframe("60",              "TF",      group=G_WL, inline="r2")
s3  = input.symbol("",                  "④ Ticker", group=G_WL, inline="r3")
tf3 = input.timeframe("60",              "TF",      group=G_WL, inline="r3")
s4  = input.symbol("",                  "⑤ Ticker", group=G_WL, inline="r4")
tf4 = input.timeframe("60",              "TF",      group=G_WL, inline="r4")
s5  = input.symbol("",                  "⑥ Ticker", group=G_WL, inline="r5")
tf5 = input.timeframe("60",              "TF",      group=G_WL, inline="r5")
s6  = input.symbol("",                  "⑦ Ticker", group=G_WL, inline="r6")
tf6 = input.timeframe("60",              "TF",      group=G_WL, inline="r6")
s7  = input.symbol("",                  "⑧ Ticker", group=G_WL, inline="r7")
tf7 = input.timeframe("60",              "TF",      group=G_WL, inline="r7")
s8  = input.symbol("",                  "⑨ Ticker", group=G_WL, inline="r8")
tf8 = input.timeframe("60",              "TF",      group=G_WL, inline="r8")
s9  = input.symbol("",                  "⑩ Ticker", group=G_WL, inline="r9")
tf9 = input.timeframe("60",              "TF",      group=G_WL, inline="r9")

string G_F = "── Fibo Detection ──"
swingLen = input.int(5,  "Pivot swing length",  minval=2,  maxval=20,  group=G_F)
lookback = input.int(50, "Pivot lookback bars", minval=10, maxval=500, step=10, group=G_F)

string G_V = "── Visuals ──"
showPanel = input.bool(true, "Show panel", group=G_V)
nearPct   = input.float(0.5, "Highlight level when within % of price", minval=0.05, step=0.05, group=G_V)
panelPos  = input.string("Bottom Right", "Panel position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Bottom Center"], group=G_V)

// ── Build syms (with TF) ──────────────────────────────────────────────────
string[] rawSyms = array.from(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9)
string[] rawTFs  = array.from(tf0, tf1, tf2, tf3, tf4, tf5, tf6, tf7, tf8, tf9)
var SymInfo[] syms = array.new<SymInfo>(10)
array.clear(syms)
for i = 0 to 9
    s = array.get(rawSyms, i)
    t = array.get(rawTFs, i)
    if str.length(s) > 0
        array.push(syms, SymInfo.new(s, fShort(s), t, true))

nSyms = array.size(syms)
while array.size(syms) < 10
    array.push(syms, SymInfo.new(FALLBACK, fShort(FALLBACK), FALLBACK_TF, false))

// ── IIFE: pivots → fibo levels ───────────────────────────────────────────
fibo_data() =>
    ph = ta.pivothigh(high, swingLen, swingLen)
    pl = ta.pivotlow (low,  swingLen, swingLen)
    var float lastH    = na
    var float lastL    = na
    var int   lastHBar = -99999
    var int   lastLBar = -99999
    if not na(ph)
        lastH    := ph
        lastHBar := bar_index - swingLen
    if not na(pl)
        lastL    := pl
        lastLBar := bar_index - swingLen
    if bar_index - lastHBar > lookback
        lastH := na
    if bar_index - lastLBar > lookback
        lastL := na

    float diff = lastH - lastL
    FiboData.new(
         lastL,
         lastL + diff * 0.236,
         lastL + diff * 0.382,
         lastL + diff * 0.5,
         lastL + diff * 0.618,
         lastL + diff * 0.786,
         lastH,
         close)

// ── 10 request.security() calls (1 por símbolo, TF por símbolo) ──────────
FiboData f0 = request.security(array.get(syms, 0).raw, array.get(syms, 0).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f1 = request.security(array.get(syms, 1).raw, array.get(syms, 1).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f2 = request.security(array.get(syms, 2).raw, array.get(syms, 2).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f3 = request.security(array.get(syms, 3).raw, array.get(syms, 3).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f4 = request.security(array.get(syms, 4).raw, array.get(syms, 4).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f5 = request.security(array.get(syms, 5).raw, array.get(syms, 5).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f6 = request.security(array.get(syms, 6).raw, array.get(syms, 6).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f7 = request.security(array.get(syms, 7).raw, array.get(syms, 7).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f8 = request.security(array.get(syms, 8).raw, array.get(syms, 8).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)
FiboData f9 = request.security(array.get(syms, 9).raw, array.get(syms, 9).tf, fibo_data(), barmerge.gaps_off, barmerge.lookahead_off)

var FiboData[] fibArr = array.new<FiboData>(10)
array.set(fibArr, 0, f0), array.set(fibArr, 1, f1), array.set(fibArr, 2, f2), array.set(fibArr, 3, f3), array.set(fibArr, 4, f4)
array.set(fibArr, 5, f5), array.set(fibArr, 6, f6), array.set(fibArr, 7, f7), array.set(fibArr, 8, f8), array.set(fibArr, 9, f9)

// ── Panel ────────────────────────────────────────────────────────────────
var table t = table.new(fPos(panelPos), 10, 11,
     bgcolor=color.new(color.black, 20), border_width=1,
     border_color=color.new(color.gray, 50))

if barstate.islast and showPanel
    table.cell(t, 0, 0, "Sym (" + str.tostring(nSyms) + ")", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 1, 0, "TF",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 2, 0, "Now", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 3, 0, "0%",    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 4, 0, "23.6%", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 5, 0, "38.2%", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 6, 0, "50%",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 7, 0, "61.8%", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 8, 0, "78.6%", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 9, 0, "100%",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)

    for i = 0 to nSyms - 1
        SymInfo sym = array.get(syms, i)
        if not sym.valid
            continue
        FiboData f = array.get(fibArr, i)
        float c = f.close

        float[] levels = array.from(f.l0, f.l236, f.l382, f.l500, f.l618, f.l786, f.l100)
        float minDist = 1e10
        int   nearestIdx = -1
        for j = 0 to 6
            float lvl = array.get(levels, j)
            if na(lvl)
                continue
            float dist = math.abs(c - lvl) / c * 100.0
            if dist < minDist
                minDist    := dist
                nearestIdx := j

        bool isNear = nearestIdx >= 0 and minDist <= nearPct

        table.cell(t, 0, i + 1, sym.short,                                 text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 70), text_formatting=text.format_bold)
        table.cell(t, 1, i + 1, sym.tf,                                    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 80))
        table.cell(t, 2, i + 1, na(c) ? "—" : str.tostring(c, "#.####"),   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 80))

        for j = 0 to 6
            float lvl    = array.get(levels, j)
            color cellBg = (j == nearestIdx and isNear) ? color.new(color.yellow, 50) : color.new(color.gray, 80)
            bool  bold   = (j == nearestIdx and isNear)
            string txt   = na(lvl) ? "—" : str.tostring(lvl, "#.####")
            table.cell(t, j + 3, i + 1, txt, text_color=color.white, text_size=size.tiny, bgcolor=cellBg, text_formatting=bold ? text.format_bold : text.format_none)
````
