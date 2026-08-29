<!-- tradingview-pine-id: PUB;c95104a2abce48b296b0b14831620d8f -->
<!-- tradingviewscripts-format: 1 -->
# OB Watchlist Distance · v6

Source: https://www.tradingview.com/script/YKnnOI31-OB-Watchlist-Distance/

## Description

OB Watchlist Distance evaluates up to ten user-selected symbols and shows, in a single panel on the chart, how far each one is from its nearest active Order Block and the quality score of that Order Block.
For each symbol the script detects bullish and bearish Order Blocks on Break of Structure on the timeframe you select. The most recent unmitigated Order Block on each side is found, and whichever is closer to the current price is reported.
The panel shows, for every symbol: side (BULL or BEAR), OB price, current price, distance to the OB in percent, score from 1 to 10, and state (Active or No OB). Rows where the distance is within the proximity threshold and the score meets the high-quality threshold are highlighted in yellow. The header shows the count of active symbols.
Settings include ten symbol picker slots (leave any empty to skip it), OB detection parameters (pivot length, BOS body filter, OB lookback bars, ATR length), and visual options for the panel position and the proximity and score thresholds.
Limitations. The script uses one request.security() call per symbol, so it is capped at ten symbols by Pine's call budget. Only the current chart's symbol can be drawn with boxes on the price chart; the other symbols are summarized in the panel only. The score used here is a lightweight displacement-only formula to keep the inline per-symbol evaluation fast. For the full five-feature score (Displacement, Volume, FVG, Freshness, Trend) and on-chart Order Block drawings, use the companion Order Blocks Score [1-10] indicator.
Recommended timeframe: 1D or 4H for swing context, 1H for intraday scanning.

---

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  OB Watchlist Distance · v6 (symbol picker UI)
//  ────────────────────────────
//  10 input.symbol() slots, leave any empty to skip. request.security() uses
//  a fallback for empty slots so it doesn't error. Display loop filters.
// ════════════════════════════════════════════════════════════════════════════

indicator("OB Watchlist Distance · v6", overlay=true,
     max_boxes_count=10, max_labels_count=10)

// ── UDTs ─────────────────────────────────────────────────────────────────
type SymInfo
    string raw
    string short
    bool   valid

type OBData
    float bullTop
    float bullBot
    float bullScore
    bool  bullMit
    float bearTop
    float bearBot
    float bearScore
    bool  bearMit
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

string FALLBACK = "BINANCE:BTCUSDT"

// ── Inputs ────────────────────────────────────────────────────────────────
string G_WL = "── Watchlist (vacío = skip) ──"
s0 = input.symbol("BINANCE:BTCUSDT",  "① Symbol 1",  group=G_WL)
s1 = input.symbol("BINANCE:ETHUSDT",  "② Symbol 2",  group=G_WL)
s2 = input.symbol("BINANCE:SOLUSDT",  "③ Symbol 3",  group=G_WL)
s3 = input.symbol("",                 "④ Symbol 4",  group=G_WL, tooltip="Deja vacío para omitir")
s4 = input.symbol("",                 "⑤ Symbol 5",  group=G_WL)
s5 = input.symbol("",                 "⑥ Symbol 6",  group=G_WL)
s6 = input.symbol("",                 "⑦ Symbol 7",  group=G_WL)
s7 = input.symbol("",                 "⑧ Symbol 8",  group=G_WL)
s8 = input.symbol("",                 "⑨ Symbol 9",  group=G_WL)
s9 = input.symbol("",                 "⑩ Symbol 10", group=G_WL)

string G_OB = "── OB Detection ──"
tfOB       = input.timeframe("1D", "OB timeframe", group=G_OB)
swingLen   = input.int(5, "Swing length",        minval=2,  maxval=20,  group=G_OB)
lookback   = input.int(10, "OB lookback bars",   minval=3,  maxval=30,  group=G_OB)
dispMult   = input.float(0.5, "BOS body / ATR",   minval=0.1, step=0.05, group=G_OB)
atrLen     = input.int(14, "ATR length",          minval=1,              group=G_OB)

string G_V = "── Visuals ──"
showPanel  = input.bool(true, "Show watchlist panel", group=G_V)
nearPct    = input.float(1.0, "Highlight when Δ% ≤", minval=0.1, step=0.1, group=G_V)
hiScore    = input.int(7, "Highlight score ≥",       minval=1,   maxval=10, group=G_V)
panelPos   = input.string("Bottom Right", "Panel position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Bottom Center"], group=G_V)

// ── Build syms desde inputs (filtra vacíos) ───────────────────────────────
string[] rawInputs = array.from(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9)
var SymInfo[] syms = array.new<SymInfo>(10)
array.clear(syms)
for i = 0 to 9
    s = array.get(rawInputs, i)
    if str.length(s) > 0
        array.push(syms, SymInfo.new(s, fShort(s), true))

nSyms = array.size(syms)

// Pad con fallback para los request.security() (no se muestran)
while array.size(syms) < 10
    array.push(syms, SymInfo.new(FALLBACK, fShort(FALLBACK), false))

// ── IIFE: detección de OB ────────────────────────────────────────────────
ob_data() =>
    ph = ta.pivothigh(high, swingLen, swingLen)
    pl = ta.pivotlow (low,  swingLen, swingLen)
    var float lastH = na
    var float lastL = na
    if not na(ph)
        lastH := ph
    if not na(pl)
        lastL := pl

    atr14  = ta.atr(atrLen)
    bodyUp = (close - open) > dispMult * atr14
    bodyDn = (open - close) > dispMult * atr14
    bosUp  = not na(lastH) and close > lastH and close[1] <= lastH and bodyUp
    bosDn  = not na(lastL) and close < lastL and close[1] >= lastL and bodyDn

    var float bullTop   = na
    var float bullBot   = na
    var float bullScore = na
    var bool  bullMit   = true
    var float bearTop   = na
    var float bearBot   = na
    var float bearScore = na
    var bool  bearMit   = true

    if bosUp
        for i = 1 to lookback
            if close[i] < open[i]
                bullTop   := high[i]
                bullBot   := low[i]
                float d   = (close - bullTop) / math.max(atr14, syminfo.mintick)
                bullScore := d > 3.0 ? 10.0 : d > 2.0 ? 8.0 : d > 1.0 ? 6.0 : 4.0
                bullMit   := false
                break

    if bosDn
        for i = 1 to lookback
            if close[i] > open[i]
                bearTop   := high[i]
                bearBot   := low[i]
                float d   = (bearTop - close) / math.max(atr14, syminfo.mintick)
                bearScore := d > 3.0 ? 10.0 : d > 2.0 ? 8.0 : d > 1.0 ? 6.0 : 4.0
                bearMit   := false
                break

    if not bullMit and not na(bullBot) and close < bullBot
        bullMit := true
    if not bearMit and not na(bearTop) and close > bearTop
        bearMit := true

    OBData.new(bullTop, bullBot, bullScore, bullMit, bearTop, bearBot, bearScore, bearMit, close)

// ── 10 slots hardcoded de request.security() ─────────────────────────────
OBData ob0 = request.security(array.get(syms, 0).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob1 = request.security(array.get(syms, 1).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob2 = request.security(array.get(syms, 2).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob3 = request.security(array.get(syms, 3).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob4 = request.security(array.get(syms, 4).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob5 = request.security(array.get(syms, 5).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob6 = request.security(array.get(syms, 6).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob7 = request.security(array.get(syms, 7).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob8 = request.security(array.get(syms, 8).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)
OBData ob9 = request.security(array.get(syms, 9).raw, tfOB, ob_data(), barmerge.gaps_off, barmerge.lookahead_off)

// ── Almacenar ────────────────────────────────────────────────────────────
var OBData[] obs = array.new<OBData>(10)
array.set(obs, 0, ob0), array.set(obs, 1, ob1), array.set(obs, 2, ob2), array.set(obs, 3, ob3), array.set(obs, 4, ob4)
array.set(obs, 5, ob5), array.set(obs, 6, ob6), array.set(obs, 7, ob7), array.set(obs, 8, ob8), array.set(obs, 9, ob9)

// ── Panel ────────────────────────────────────────────────────────────────
var table t = table.new(fPos(panelPos), 7, 11,
     bgcolor=color.new(color.black, 20), border_width=1,
     border_color=color.new(color.gray, 50))

if barstate.islast and showPanel
    table.cell(t, 0, 0, "Symbol (" + str.tostring(nSyms) + ")", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 1, 0, "Side",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 2, 0, "OB",     text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 3, 0, "Now",    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 4, 0, "Δ %",    text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 5, 0, "Score",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)
    table.cell(t, 6, 0, "State",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.blue, 40), text_formatting=text.format_bold)

    for i = 0 to nSyms - 1
        SymInfo sym = array.get(syms, i)
        if not sym.valid
            continue
        OBData ob = array.get(obs, i)
        float c = ob.close

        bool useBull = not ob.bullMit and not na(ob.bullTop)
        bool useBear = not ob.bearMit and not na(ob.bearTop)

        string sideStr  = "—"
        float  obPrice  = na
        float  obScore  = na
        string stateStr = "—"
        color  rowBg    = color.new(color.gray, 80)

        if useBull and useBear
            float dB = math.abs(c - ob.bullBot)
            float dS = math.abs(c - ob.bearTop)
            if dB <= dS
                sideStr  := "▲ BULL"
                obPrice  := (ob.bullTop + ob.bullBot) / 2.0
                obScore  := ob.bullScore
                stateStr := "Active"
                rowBg    := color.new(#26a69a, 80)
            else
                sideStr  := "▼ BEAR"
                obPrice  := (ob.bearTop + ob.bearBot) / 2.0
                obScore  := ob.bearScore
                stateStr := "Active"
                rowBg    := color.new(#ef5350, 80)
        else if useBull
            sideStr  := "▲ BULL"
            obPrice  := (ob.bullTop + ob.bullBot) / 2.0
            obScore  := ob.bullScore
            stateStr := "Active"
            rowBg    := color.new(#26a69a, 80)
        else if useBear
            sideStr  := "▼ BEAR"
            obPrice  := (ob.bearTop + ob.bearBot) / 2.0
            obScore  := ob.bearScore
            stateStr := "Active"
            rowBg    := color.new(#ef5350, 80)
        else
            sideStr  := "—"
            stateStr := "No OB"

        float distPct = not na(obPrice) ? math.abs(c - obPrice) / c * 100.0 : na
        bool  near    = not na(distPct) and distPct <= nearPct
        bool  hiQ     = not na(obScore) and obScore >= hiScore

        if near and hiQ
            rowBg := color.new(color.yellow, 60)

        table.cell(t, 0, i + 1, sym.short,                                            text_color=color.white, text_size=size.tiny, bgcolor=rowBg, text_formatting=text.format_bold)
        table.cell(t, 1, i + 1, sideStr,                                              text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
        table.cell(t, 2, i + 1, na(obPrice) ? "—" : str.tostring(obPrice, "#.####"),  text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
        table.cell(t, 3, i + 1, na(c) ? "—" : str.tostring(c, "#.####"),              text_color=color.white, text_size=size.tiny, bgcolor=rowBg)
        table.cell(t, 4, i + 1, na(distPct) ? "—" : str.tostring(distPct, "#.##") + "%", text_color=near ? color.yellow : color.white, text_size=size.tiny, bgcolor=rowBg, text_formatting=near ? text.format_bold : text.format_none)
        table.cell(t, 5, i + 1, na(obScore) ? "—" : str.tostring(math.round(obScore)),  text_color=hiQ  ? color.yellow : color.white, text_size=size.tiny, bgcolor=rowBg, text_formatting=hiQ  ? text.format_bold : text.format_none)
        table.cell(t, 6, i + 1, stateStr,                                             text_color=color.gray,  text_size=size.tiny, bgcolor=rowBg)
````
