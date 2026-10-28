# Volatility Radar - Muti-Timeframe [PUCHON]

- url: https://www.tradingview.com/script/oryQEG9c-Volatility-Radar-Muti-Timeframe-PUCHON/
- type: indicator
- pine_id: PUB;cd7a3356b6114a60be9b2b1b347db408
- version: 1.0

## Description

[b]Volatility Radar — MTF [PUCHON][/b]

Reads [b]ATR%[/b], [b]Historical Volatility (HV%)[/b], and [b]Bollinger Band Width (BBW%)[/b] across 5 timeframes simultaneously. Classifies each timeframe into a volatility regime — LOW / NORMAL / HIGH / EXTREME — using percentile rank computed independently per timeframe. A single consensus row summarises all 5 timeframes into one actionable signal.

Open-source script — full code visible in Pine Script editor.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]WHAT MAKES IT DIFFERENT[/b]

Most volatility tools work on a single timeframe. This dashboard:
[list]
[*] Runs three independent metrics per timeframe via bundled [i]request.security()[/i] — one call per TF, no redundant data fetching
[*] Classifies regime using [i]ta.percentrank()[/i] computed inside each TF's own bar history — "HIGH" on 5m and "HIGH" on Daily are both statistically meaningful relative to that TF's own past
[*] Renders a unicode sparkline row [b]█░[/b] to compare relative ATR across all timeframes at a glance
[*] Neon Dark styling: regime label pinned to last candle, colored regime badges, candle coloring, background state tint
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]HOW TO READ EACH ROW[/b]

[b]Row 1 — ATR %[/b]
Average True Range as a percentage of price. Answers: "How large are the candles right now, relative to price?"
[list]
[*] Higher ATR% = bigger candles, wider spreads, larger stop loss needed
[*] Compare across TFs: if 5m ATR% suddenly equals the 60m ATR%, intraday volatility has spiked unexpectedly
[*] Color reflects regime: Neon Green = Low  Cyan = Normal  Red = High  Magenta = Extreme
[/list]

[b]Row 2 — HV %[/b]
Historical Volatility (annualized). Standard deviation of log returns × √252.
[list]
[*] Answers: "At what annualized rate is this asset moving right now?"
[*] Rising HV = market accelerating. Falling HV = compressing toward a squeeze
[*] Cross-TF: if 5m HV is 3% but Daily HV is 37%, short-term is calm inside a long-term volatile environment — mean-reversion setup signal
[*] Displayed in neutral Cyan — informational, not regime-colored
[/list]

[b]Row 3 — BBW %[/b]
Bollinger Band Width = (Upper BB − Lower BB) / Midline × 100.
[list]
[*] Low BBW = bands squeezing → breakout risk rising
[*] High BBW = bands expanded → trend or momentum is active
[*] BBW spike after a Low regime = early breakout confirmation
[*] Multiple TFs showing Low BBW simultaneously = convergent squeeze — watch closely
[/list]

[b]Row 4 — REGIME[/b]
Percentile rank of current ATR% against the last [i]Regime Lookback[/i] bars of that same timeframe.
[list]
[*] [b]LOW[/b] — below 25th percentile → unusually quiet; possible accumulation or squeeze
[*] [b]NORMAL[/b] — 25th–75th percentile → average conditions; trend-following works well
[*] [b]HIGH[/b] — 75th–90th percentile → elevated; widen stops, reduce position size
[*] [b]EXTREME[/b] — above 90th percentile → rare spike; consider standing aside
[/list]
Regime is relative to the instrument's own history. 0.5% ATR could be LOW on a volatile crypto but EXTREME on a blue-chip stock. The percentile rank adapts automatically.

[b]Row 5 — ATR▐ (Sparkline)[/b]
Unicode bar [b]█[/b] (filled) / [b]░[/b] (empty) — each TF's ATR% as a proportion of the highest ATR% across all columns.
[list]
[*] Longest bar = most volatile timeframe right now
[*] Normal: bars grow left (5m) to right (Daily) — higher TFs are naturally more volatile in absolute terms
[*] Warning: a short-TF bar suddenly matching a long-TF bar → intraday volatility spike
[*] Bar color matches the regime of that column
[/list]

[b]Row 6 — SIGNAL[/b]
Consensus across all 5 timeframes. Counts TFs in HIGH or EXTREME regime.
[list]
[*] [b]STABLE — NORMAL VOLATILITY[/b] → 0–1 TFs elevated. Trade normally.
[*] [b]ELEVATED ACROSS TIMEFRAMES[/b] → 2–3 TFs elevated. Widen stops, reduce size.
[*] [b]⚠ RISK OFF — EXTREME VOLATILITY[/b] → 4–5 TFs elevated. Consider standing aside.
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]CANDLE & BACKGROUND COLORING[/b]

Candles and background tint reflect the current chart timeframe's regime:
[list]
[*] 🟢 [b]LOW[/b] — calm market, potential accumulation zone
[*] 🔵 [b]NORMAL[/b] — standard conditions, trend strategies work well
[*] 🔴 [b]HIGH[/b] — elevated, tighten stops and reduce size
[*] 🟣 [b]EXTREME[/b] — dangerous conditions, reduce or close exposure
[/list]
A glow label above the last candle shows the current regime at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]PRACTICAL SCENARIOS[/b]

[b]Scenario A — Safe to trade[/b]
All TFs: NORMAL or LOW → SIGNAL: STABLE
Action: Use momentum strategies. ATR% bars are short and roughly equal.

[b]Scenario B — Reduce size[/b]
5m: NORMAL | 15m: HIGH | 60m: EXTREME | 240m: HIGH | D: NORMAL → SIGNAL: ELEVATED
Action: Widen stop to accommodate 60m ATR range. Reduce position by 30–50%.
The 60m sparkline bar will be the longest — confirming where volatility is concentrated.

[b]Scenario C — Stand aside[/b]
ALL TFs: EXTREME → SIGNAL: ⚠ RISK OFF
Action: Wait for regime to cool to NORMAL before re-entering. Occurs during major news events, flash crashes, or market opens.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]HOW TO USE[/b]

[list=1]
[*] Add to any chart as an overlay — works on all instruments and timeframes
[*] Set your 5 analysis timeframes in the [b]Timeframes[/b] settings group
[*] Check [b]REGIME row[/b] — identify which timeframes are elevated
[*] Check [b]SIGNAL row[/b] — use as your position sizing guide
[*] Read [b]sparkline bar row[/b] — longest bar = where volatility is concentrated
[*] Enable [b]candle coloring[/b] and [b]background tint[/b] for instant visual scanning
[*] Set alert on [b]Regime Escalation[/b] to be notified when volatility rises
[*] Set alert on [b]Regime Cooling[/b] to re-enter after a volatility spike
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]SETTINGS GUIDE[/b]

[list]
[*] [b]TF 1–5[/b] — Five analysis timeframes (default: 5 / 15 / 60 / 240 / Daily)
[*] [b]ATR Length[/b] (default: 14) — ATR period. 14 is standard; increase for smoother values on noisy instruments
[*] [b]HV Length[/b] (default: 20) — Log-return standard deviation lookback for HV%
[*] [b]BBW Length[/b] (default: 20) — Bollinger Band period for width calculation
[*] [b]Regime Lookback[/b] (default: 100) — Percentile rank window per TF. Higher = more stable labels, slower to react. Lower = faster but noisier
[*] [b]Color Candles by Regime[/b] — Toggle neon candle coloring on/off
[*] [b]Background Tint[/b] — Toggle near-invisible regime background tint
[*] [b]ATR% Sparkline Row[/b] — Toggle unicode bar chart row visibility
[*] [b]Table Position[/b] — Move dashboard to any of the four chart corners
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]ALERTS[/b]

Five built-in alert conditions:
[list]
[*] [b]Extreme Volatility[/b] — current TF enters EXTREME regime
[*] [b]High+ Volatility[/b] — current TF enters HIGH or EXTREME regime
[*] [b]Low Volatility[/b] — current TF enters LOW regime (watch for squeeze)
[*] [b]Regime Escalation[/b] — volatility rises from Normal to High/Extreme
[*] [b]Regime Cooling[/b] — volatility falls back from High/Extreme to Normal
[/list]
Set via: Right-click chart → Add alert → Condition: [b]Volatility Dashboard — MTF[/b]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]LIMITATIONS[/b]

[list]
[*] Regime needs at least [i]Regime Lookback[/i] confirmed bars on each TF. First bars on very high timeframes may show "—" until enough history is loaded
[*] HV uses √252 annualization (trading days). Crypto 24/7 markets are slightly understated — actual annualized vol is ~17% higher than displayed
[*] Does [b]not[/b] predict direction. HIGH and EXTREME regimes occur in both strong trends and sharp crashes. Use with a directional indicator
[*] Requesting a TF lower than the chart's own TF has no effect — Pine Script cannot look inside the current bar
[*] Current (unconfirmed) bar values update in real time and may differ from the final bar-close value. This is normal behavior, not repainting
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]OPEN SOURCE[/b]

Published under [b]Mozilla Public License 2.0[/b].
Free to use, modify, and build upon.
If you publish a modified version, credit to the original script is appreciated.

⚠ Disclaimer: This script is for educational and informational purposes only. It does not constitute financial advice. Volatility analysis does not guarantee profitable trades. Past volatility patterns do not predict future price movements. Always conduct your own analysis and apply proper risk management before trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ProPuchon
//@version=6
indicator("Volatility Radar — MTF [PUCHON]", overlay=true, max_labels_count=1)

// ============================================================================
// THEME — Neon Dark (Cyberpunk / Crypto Native)
// Low=Neon Green | Normal=Cyan | High=Neon Red | Extreme=Magenta
// ============================================================================
C_TEAL      = color.new(#39FF14, 0)   // Neon Green  — Low vol
C_AMBER     = color.new(#FF0055, 0)   // Neon Red    — High vol
C_INDIGO    = color.new(#00FFFF, 0)   // Cyan        — Normal
C_RED       = color.new(#FF00FF, 0)   // Magenta     — Extreme


C_SURFACE_D = color.new(#0A0A0A, 85)  // Near-black panel
C_BORDER    = color.new(#1A1A1A, 0)   // Barely visible border
C_TEXT_H    = color.new(#FFFFFF, 0)   // White headers
C_TEXT_V    = color.new(#00FFFF, 0)   // Cyan values
C_TEXT_L    = color.new(#FFFFFF, 0)   // White label text (visible on dark theme)

C_BG_LOW    = color.new(#39FF14, 97)  // Barely-visible neon green tint
C_BG_NORM   = color.new(#00FFFF, 98)  // Barely-visible cyan tint
C_BG_HIGH   = color.new(#FF0055, 97)  // Barely-visible red tint
C_BG_EXTR   = color.new(#FF00FF, 96)  // Barely-visible magenta tint

HDR_BG      = color.new(#39FF14, 75)  // Neon green header

// ============================================================================
// INPUTS
// ============================================================================
grp_tf = "Timeframes"
tf1    = input.timeframe("5",   "TF 1", group=grp_tf)
tf2    = input.timeframe("15",  "TF 2", group=grp_tf)
tf3    = input.timeframe("60",  "TF 3", group=grp_tf)
tf4    = input.timeframe("240", "TF 4", group=grp_tf)
tf5    = input.timeframe("D",   "TF 5", group=grp_tf)

grp_c  = "Calculations"
atrLen = input.int(14,  "ATR Length",       minval=2,  group=grp_c,
     tooltip="ATR period for ATR% calculation")
hvLen  = input.int(20,  "HV Length",        minval=5,  group=grp_c,
     tooltip="Lookback for Historical Volatility (annualized log-return std dev)")
bbLen  = input.int(20,  "BBW Length",       minval=5,  group=grp_c,
     tooltip="Bollinger Band period for Band Width calculation")
regLen = input.int(100, "Regime Lookback",  minval=20, group=grp_c,
     tooltip="Bars used to compute percentile rank for Low/Normal/High/Extreme classification")

grp_v      = "Visualization"
showCandle = input.bool(true, "Color Candles by Regime",    group=grp_v,
     tooltip="Color each candle based on the current timeframe's volatility regime")
showBG     = input.bool(true, "Background Tint by Regime",  group=grp_v,
     tooltip="Apply a subtle background tint to indicate the current regime")
showBars   = input.bool(true, "Show ATR% Sparkline Row",    group=grp_v,
     tooltip="Show a unicode bar chart row comparing relative ATR% across timeframes")
tblPos     = input.string("Top Right", "Table Position", group=grp_v,
     options=["Top Right", "Top Center", "Top Left",
              "Middle Right", "Middle Center", "Middle Left",
              "Bottom Right", "Bottom Center", "Bottom Left"])
txtSizeOpt = input.string("Small", "Text Size", group=grp_v,
     options=["Tiny", "Small", "Normal", "Large"],
     tooltip="Dashboard table text size. Badge and sparkline rows are always one step smaller.")

// ============================================================================
// CALCULATION FUNCTIONS
// ============================================================================

// ATR as % of current price
atrPctCalc(len) =>
    close > 0 ? ta.atr(len) / close * 100 : na

// Annualized historical volatility via log returns
hvCalc(src, len) =>
    prev = nz(src[1], src)
    logRet = prev > 0 ? math.log(src / prev) : float(na)
    ta.stdev(logRet, len) * math.sqrt(252) * 100

// Bollinger Band Width as % of midline
bbwCalc(src, len) =>
    basis = ta.sma(src, len)
    basis > 0 ? ta.stdev(src, len) * 2.0 / basis * 100 : na

// Regime classifier: 0=Low 1=Normal 2=High 3=Extreme
regimeCalc(val, len) =>
    pr = ta.percentrank(val, len)
    pr < 25 ? 0 : pr < 75 ? 1 : pr < 90 ? 2 : 3

// Bundle all four metrics into a tuple for a single security() call
volBundle(aLen, hLen, bLen, rLen) =>
    atr = atrPctCalc(aLen)
    hv  = hvCalc(close, hLen)
    bw  = bbwCalc(close, bLen)
    reg = regimeCalc(atr, rLen)
    [atr, hv, bw, reg]

// ============================================================================
// DISPLAY HELPERS
// ============================================================================

// Regime → brand color
rColor(r) =>
    r == 0 ? C_TEAL : r == 1 ? C_INDIGO : r == 2 ? C_AMBER : C_RED

// Regime → text label
rLabel(r) =>
    r == 0 ? "LOW" : r == 1 ? "NORMAL" : r == 2 ? "HIGH" : "EXTREME"

// na-safe formatters
fmt2(v) => na(v) ? "—" : str.format("{0,number,#.##}", v)
fmt1(v) => na(v) ? "—" : str.format("{0,number,#.#}",  v)

// Unicode bar chart: 10 blocks, filled relative to maxVal
sparkBar(val, maxVal) =>
    filled = maxVal > 0 ? math.round(math.min(val / maxVal * 10, 10)) : 0
    result = ""
    for i = 0 to 9
        result += i < filled ? "█" : "░"
    result

// ============================================================================
// CURRENT TIMEFRAME
// ============================================================================
[curATR, curHV, curBBW, curReg] = volBundle(atrLen, hvLen, bbLen, regLen)

// ============================================================================
// MULTI-TIMEFRAME (one security() call per TF, bundled)
// ============================================================================
[a1, h1, b1, r1] = request.security(syminfo.tickerid, tf1,
     volBundle(atrLen, hvLen, bbLen, regLen), lookahead=barmerge.lookahead_off)

[a2, h2, b2, r2] = request.security(syminfo.tickerid, tf2,
     volBundle(atrLen, hvLen, bbLen, regLen), lookahead=barmerge.lookahead_off)

[a3, h3, b3, r3] = request.security(syminfo.tickerid, tf3,
     volBundle(atrLen, hvLen, bbLen, regLen), lookahead=barmerge.lookahead_off)

[a4, h4, b4, r4] = request.security(syminfo.tickerid, tf4,
     volBundle(atrLen, hvLen, bbLen, regLen), lookahead=barmerge.lookahead_off)

[a5, h5, b5, r5] = request.security(syminfo.tickerid, tf5,
     volBundle(atrLen, hvLen, bbLen, regLen), lookahead=barmerge.lookahead_off)

// ============================================================================
// VISUAL — Background tint + Candle coloring
// ============================================================================
bgCol     = curReg == 0 ? C_BG_LOW : curReg == 1 ? C_BG_NORM : curReg == 2 ? C_BG_HIGH : C_BG_EXTR
candleCol = rColor(curReg)

bgcolor(showBG     ? bgCol     : na, title="Regime Background")
barcolor(showCandle ? candleCol : na, title="Regime Candle")

// ============================================================================
// TABLE POSITION + TEXT SIZE
// ============================================================================
pos = switch tblPos
    "Top Right"     => position.top_right
    "Top Center"    => position.top_center
    "Top Left"      => position.top_left
    "Middle Right"  => position.middle_right
    "Middle Center" => position.middle_center
    "Middle Left"   => position.middle_left
    "Bottom Right"  => position.bottom_right
    "Bottom Center" => position.bottom_center
    => position.bottom_left

szMain = switch txtSizeOpt
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    => size.large

szSub = switch txtSizeOpt
    "Normal" => size.small
    "Large"  => size.normal
    => size.tiny

// ============================================================================
// DASHBOARD TABLE
// Cols: 0=Label | 1=TF1 | 2=TF2 | 3=TF3 | 4=TF4 | 5=TF5 | 6=Current
// Rows: 0=Header | 1=ATR% | 2=HV% | 3=BBW% | 4=Regime | 5=Sparkline | 6=Signal
// ============================================================================
if barstate.islast
    var tbl = table.new(pos, 7, 7,
         bgcolor      = C_SURFACE_D,
         border_color = C_BORDER,
         border_width = 1,
         frame_color  = C_BORDER,
         frame_width  = 1)

    // ── Row 0: Header ────────────────────────────────────────────────────────
    table.cell(tbl, 0, 0, "VOLATILITY",   text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)
    table.cell(tbl, 1, 0, tf1,            text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)
    table.cell(tbl, 2, 0, tf2,            text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)
    table.cell(tbl, 3, 0, tf3,            text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)
    table.cell(tbl, 4, 0, tf4,            text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)
    table.cell(tbl, 5, 0, tf5,            text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)
    table.cell(tbl, 6, 0, "CURRENT",      text_color=C_TEXT_H, text_size=szMain, bgcolor=HDR_BG)

    // ── Row 1: ATR% — color-coded by regime ──────────────────────────────────
    table.cell(tbl, 0, 1, "ATR %",        text_color=C_TEXT_L, text_size=szMain)
    table.cell(tbl, 1, 1, fmt2(a1),       text_color=rColor(r1),    text_size=szMain)
    table.cell(tbl, 2, 1, fmt2(a2),       text_color=rColor(r2),    text_size=szMain)
    table.cell(tbl, 3, 1, fmt2(a3),       text_color=rColor(r3),    text_size=szMain)
    table.cell(tbl, 4, 1, fmt2(a4),       text_color=rColor(r4),    text_size=szMain)
    table.cell(tbl, 5, 1, fmt2(a5),       text_color=rColor(r5),    text_size=szMain)
    table.cell(tbl, 6, 1, fmt2(curATR),   text_color=rColor(curReg),text_size=szMain)

    // ── Row 2: HV% — neutral value color ─────────────────────────────────────
    table.cell(tbl, 0, 2, "HV %",         text_color=C_TEXT_L, text_size=szMain)
    table.cell(tbl, 1, 2, fmt1(h1),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 2, 2, fmt1(h2),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 3, 2, fmt1(h3),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 4, 2, fmt1(h4),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 5, 2, fmt1(h5),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 6, 2, fmt1(curHV),    text_color=C_TEXT_V, text_size=szMain)

    // ── Row 3: BBW% ───────────────────────────────────────────────────────────
    table.cell(tbl, 0, 3, "BBW %",        text_color=C_TEXT_L, text_size=szMain)
    table.cell(tbl, 1, 3, fmt2(b1),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 2, 3, fmt2(b2),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 3, 3, fmt2(b3),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 4, 3, fmt2(b4),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 5, 3, fmt2(b5),       text_color=C_TEXT_V, text_size=szMain)
    table.cell(tbl, 6, 3, fmt2(curBBW),   text_color=C_TEXT_V, text_size=szMain)

    // ── Row 4: Regime badge — colored cell background ─────────────────────────
    table.cell(tbl, 0, 4, "REGIME",          text_color=C_TEXT_L, text_size=szMain)
    table.cell(tbl, 1, 4, rLabel(r1),        text_color=rColor(r1),    text_size=szSub, bgcolor=color.new(rColor(r1),    85))
    table.cell(tbl, 2, 4, rLabel(r2),        text_color=rColor(r2),    text_size=szSub, bgcolor=color.new(rColor(r2),    85))
    table.cell(tbl, 3, 4, rLabel(r3),        text_color=rColor(r3),    text_size=szSub, bgcolor=color.new(rColor(r3),    85))
    table.cell(tbl, 4, 4, rLabel(r4),        text_color=rColor(r4),    text_size=szSub, bgcolor=color.new(rColor(r4),    85))
    table.cell(tbl, 5, 4, rLabel(r5),        text_color=rColor(r5),    text_size=szSub, bgcolor=color.new(rColor(r5),    85))
    table.cell(tbl, 6, 4, rLabel(curReg),    text_color=rColor(curReg),text_size=szSub, bgcolor=color.new(rColor(curReg),85))

    // ── Row 5: ATR% sparkline bar chart ──────────────────────────────────────
    maxA = math.max(nz(a1), nz(a2), nz(a3), nz(a4), nz(a5), nz(curATR))
    table.cell(tbl, 0, 5, showBars ? "ATR▐" : "",             text_color=C_TEXT_L,     text_size=szSub)
    table.cell(tbl, 1, 5, showBars ? sparkBar(nz(a1), maxA) : "",    text_color=rColor(r1),    text_size=szSub)
    table.cell(tbl, 2, 5, showBars ? sparkBar(nz(a2), maxA) : "",    text_color=rColor(r2),    text_size=szSub)
    table.cell(tbl, 3, 5, showBars ? sparkBar(nz(a3), maxA) : "",    text_color=rColor(r3),    text_size=szSub)
    table.cell(tbl, 4, 5, showBars ? sparkBar(nz(a4), maxA) : "",    text_color=rColor(r4),    text_size=szSub)
    table.cell(tbl, 5, 5, showBars ? sparkBar(nz(a5), maxA) : "",    text_color=rColor(r5),    text_size=szSub)
    table.cell(tbl, 6, 5, showBars ? sparkBar(nz(curATR), maxA) : "",text_color=rColor(curReg),text_size=szSub)

    // ── Row 6: Consensus signal (cells 1–6 merged) ───────────────────────────
    highCount = (r1 >= 2 ? 1 : 0) + (r2 >= 2 ? 1 : 0) + (r3 >= 2 ? 1 : 0) + (r4 >= 2 ? 1 : 0) + (r5 >= 2 ? 1 : 0)
    sig      = highCount >= 4 ? "⚠  RISK OFF — EXTREME VOLATILITY" : highCount >= 2 ? "ELEVATED ACROSS TIMEFRAMES" : "STABLE — NORMAL VOLATILITY"
    sigColor = highCount >= 4 ? C_RED : highCount >= 2 ? C_AMBER : C_TEAL

    table.cell(tbl, 0, 6, "SIGNAL",  text_color=C_TEXT_L,  text_size=szMain)
    table.merge_cells(tbl, 1, 6, 6, 6)
    table.cell(tbl, 1, 6, sig, text_color=sigColor, text_size=szMain, bgcolor=color.new(sigColor, 88))

// ============================================================================
// REGIME LABEL — pinned to the last bar, black text on neon fill
// Single label — var + set_* pattern to avoid duplicates on real-time ticks
// ============================================================================
var label solidLabel = na

regLbl = rLabel(curReg)
regCol = rColor(curReg)
yPos   = high * 1.001

if barstate.islast
    if na(solidLabel)
        solidLabel := label.new(bar_index, yPos,
             text      = regLbl,
             style     = label.style_label_down,
             color     = color.new(regCol, 20),
             textcolor = color.new(#000000, 0),
             size      = size.small)
    else
        label.set_xy(solidLabel, bar_index, yPos)
        label.set_text(solidLabel, regLbl)
        label.set_color(solidLabel, color.new(regCol, 20))
        label.set_textcolor(solidLabel, color.new(#000000, 0))

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(curReg == 3,                   "Extreme Volatility",    "Vol Dashboard: EXTREME regime — high risk environment")
alertcondition(curReg >= 2,                   "High+ Volatility",      "Vol Dashboard: HIGH or EXTREME regime")
alertcondition(curReg == 0,                   "Low Volatility",        "Vol Dashboard: LOW regime — watch for breakout/squeeze")
alertcondition(curReg[1] < 2 and curReg >= 2, "Regime Escalation",    "Vol Dashboard: Volatility escalated to HIGH/EXTREME")
alertcondition(curReg[1] >= 2 and curReg < 2, "Regime Cooling",       "Vol Dashboard: Volatility cooled back to LOW/NORMAL")
````
