# QT_Mehr_Aria V5

- url: https://www.tradingview.com/script/ETOadTrL-QT-Mehr-Aria-V5/
- type: indicator
- pine_id: PUB;3277767823e54c2daff4e17150e5fc23
- version: 2.0

## Description

Here's a publish-ready description — it presents the tool's features and how to use it, while keeping every proprietary rule out (consistent with the sanitized script). I'll save it in the repo docs too.

Saved to tradingview-description.md. Here's the text to paste into the TradingView publication:

QT_Mehr_Aria V5 — Quarterly Theory Cycles + Triad SMT

WHAT IT DOES

This indicator maps the market's time structure into nested cycles based on Quarterly Theory — from 22/23-minute micro cycles up to yearly and 4-year cycles — and scans a triad of three correlated instruments for SMT divergence at every scale. It draws cycle boundaries, quarter labels and True Opens, and prints signal and entry marks with configurable triggers and alerts.

CYCLES

Nine nested scales: Micro (22/23 min), 90-Minute, 6H, Daily, Weekly, Monthly, Quarterly, Yearly and 4-Year — all anchored to the New York 18:00 session open, DST-safe. On every chart timeframe the indicator works three tiers (LTF / MTF / HTF); higher scales can be shown optionally. Supported chart timeframes: 1m, 5m, 15m, 1h, 4h, Daily, Weekly and Monthly.

SMT DETECTION

Choose a triad preset (NQ/ES/YM · DXY/EU/GU · NQ/ES/NKD · BTC/ETH/SOL · DXY/6E/6B · GC/SI/HG · ZB/TN/ZF) or set three custom symbols. Each symbol is evaluated against its own reference level inside the cycle structure; when the triad disagrees, a divergence mark prints on the bar where it happened:

▽ bearish SMT · △ bullish SMT · ▼ / ▲ entry marks · ✕ invalidated signal · Ts true sweep (optional) · ▽? / △? forming on the live bar (optional)

Inverse-correlated triads (e.g., DXY against EU/GU) are handled automatically — custom triads get per-symbol inverse switches. Detection basis is selectable (wick, close, or wick+close confluence), and the entry trigger can be immediate or CISD close-through. A quarter-pair panel controls which quarter relationships are evaluated, and an optional True-Open premium/discount gate is included (off by default).

TRUE OPENS

TMSO, TSO (session), TDO (daily), TWO (weekly), TMO (monthly), TQO (quarterly) and TYO (yearly) — each drawn from the true opening price of its cycle, on the chart timeframes where it is tradeable.

QUARTER LABELS

A label row names each timeframe's quarters — micro quarters on 1m, up through days, weeks, months, calendar quarters and years on higher charts. One label per window, centered in the window.

SIGNAL CONTROL

The Signals group shows exactly what you want and nothing more: SMT marks, entry marks, invalidation ✕, TS marks, forming marks, and whether scales above your HTF tier draw at all. Per-cycle and per-tier visibility switches are separate. An experimental time-based signal filter is included (off by default).

ALERTS

Four static alert conditions (SMT bearish/bullish, CISD entry bearish/bullish) plus detailed alert() payloads carrying the scale, pair, symbols and cause — create the alert with "Any alert() function call". Alerts can be scoped to one scale or all.

NOTES





Chart one of the triad symbols for the cleanest reading; with an inverse member in the triad (e.g., DXY), signal direction reads from the other two symbols.



Time anchors are New York based; built around futures sessions and also usable on FX, crypto and stocks.



The top-right readout always shows the active triad and configuration.



Educational tool for time-based market analysis — not financial advice.

What it deliberately does not contain: how divergence is judged inside the quarters, the pair semantics, the close/wick reference rule, the inverse-mirroring mechanics, and the experimental filter's rules — those stay only in your local repo docs. It names features (which anyone can see in the settings panel anyway) and explains usage, which is what TradingView moderators require for protected-source publications.

خلاصه: متن توضیحات برای انتشار در تریدینگ‌ویو آماده شد — فقط قابلیت‌ها و طرز استفاده را می‌گوید، هیچ قاعده‌ای از منطق پشت ابزار لو نمی‌رود. متن در docs/tradingview-description.md ذخیره شده؛ کافی است همین را در صفحه‌ی انتشار کپی کنی.Here's a publish-ready description — it presents the tool's features and how to use it, while keeping every proprietary rule out (consistent with the sanitized script). I'll save it in the repo docs too.

Saved to tradingview-description.md. Here's the text to paste into the TradingView publication:

QT_Mehr_Aria V5 — Quarterly Theory Cycles + Triad SMT

WHAT IT DOES

This indicator maps the market's time structure into nested cycles based on Quarterly Theory — from 22/23-minute micro cycles up to yearly and 4-year cycles — and scans a triad of three correlated instruments for SMT divergence at every scale. It draws cycle boundaries, quarter labels and True Opens, and prints signal and entry marks with configurable triggers and alerts.

CYCLES

Nine nested scales: Micro (22/23 min), 90-Minute, 6H, Daily, Weekly, Monthly, Quarterly, Yearly and 4-Year — all anchored to the New York 18:00 session open, DST-safe. On every chart timeframe the indicator works three tiers (LTF / MTF / HTF); higher scales can be shown optionally. Supported chart timeframes: 1m, 5m, 15m, 1h, 4h, Daily, Weekly and Monthly.

SMT DETECTION

Choose a triad preset (NQ/ES/YM · DXY/EU/GU · NQ/ES/NKD · BTC/ETH/SOL · DXY/6E/6B · GC/SI/HG · ZB/TN/ZF) or set three custom symbols. Each symbol is evaluated against its own reference level inside the cycle structure; when the triad disagrees, a divergence mark prints on the bar where it happened:

▽ bearish SMT · △ bullish SMT · ▼ / ▲ entry marks · ✕ invalidated signal · Ts true sweep (optional) · ▽? / △? forming on the live bar (optional)

Inverse-correlated triads (e.g., DXY against EU/GU) are handled automatically — custom triads get per-symbol inverse switches. Detection basis is selectable (wick, close, or wick+close confluence), and the entry trigger can be immediate or CISD close-through. A quarter-pair panel controls which quarter relationships are evaluated, and an optional True-Open premium/discount gate is included (off by default).

TRUE OPENS

TMSO, TSO (session), TDO (daily), TWO (weekly), TMO (monthly), TQO (quarterly) and TYO (yearly) — each drawn from the true opening price of its cycle, on the chart timeframes where it is tradeable.

QUARTER LABELS

A label row names each timeframe's quarters — micro quarters on 1m, up through days, weeks, months, calendar quarters and years on higher charts. One label per window, centered in the window.

SIGNAL CONTROL

The Signals group shows exactly what you want and nothing more: SMT marks, entry marks, invalidation ✕, TS marks, forming marks, and whether scales above your HTF tier draw at all. Per-cycle and per-tier visibility switches are separate. An experimental time-based signal filter is included (off by default).

ALERTS

Four static alert conditions (SMT bearish/bullish, CISD entry bearish/bullish) plus detailed alert() payloads carrying the scale, pair, symbols and cause — create the alert with "Any alert() function call". Alerts can be scoped to one scale or all.

NOTES





Chart one of the triad symbols for the cleanest reading; with an inverse member in the triad (e.g., DXY), signal direction reads from the other two symbols.



Time anchors are New York based; built around futures sessions and also usable on FX, crypto and stocks.



The top-right readout always shows the active triad and configuration.



Educational tool for time-based market analysis — not financial advice.

What it deliberately does not contain: how divergence is judged inside the quarters, the pair semantics, the close/wick reference rule, the inverse-mirroring mechanics, and the experimental filter's rules — those stay only in your local repo docs. It names features (which anyone can see in the settings panel anyway) and explains usage, which is what TradingView moderators require for protected-source publications.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Simple SMT — stripped-down version of QT_Mehr_Aria V5
// One scale only: Daily quarters (Q1–Q4, 6h each, anchored to NY 18:00).
// Detects SMT divergence: current quarter sweeps the PREVIOUS quarter's high/low
// on some (but not all) of the three symbols.
//@version=6
indicator("QT SMT Simple", overlay=true, max_labels_count=200)

// ── Inputs ──
sym1 = input.symbol("NQ1!", "Symbol 1")
sym2 = input.symbol("ES1!", "Symbol 2")
sym3 = input.symbol("YM1!", "Symbol 3")
show_lines = input.bool(true, "Quarter boundaries")
col_bull = input.color(#089981, "Bullish")
col_bear = input.color(#F23645, "Bearish")
col_line = input.color(#787B86, "Lines")

// ── Triad data ──
[h1, l1] = request.security(sym1, timeframe.period, [high, low])
[h2, l2] = request.security(sym2, timeframe.period, [high, low])
[h3, l3] = request.security(sym3, timeframe.period, [high, low])

// ── Daily quarters (NY time, 18:00 anchor) ──
inQ(_s) => not na(time(timeframe.period, _s, "America/New_York"))
q = inQ("1800-0000") ? 1 : inQ("0000-0600") ? 2 : inQ("0600-1200") ? 3 : 4
newQ = q != q[1]

// ── Quarter extremes per symbol (current + previous quarter) ──
var float qh1 = na
var float ql1 = na
var float qh2 = na
var float ql2 = na
var float qh3 = na
var float ql3 = na
var float ph1 = na
var float pl1 = na
var float ph2 = na
var float pl2 = na
var float ph3 = na
var float pl3 = na
var bool doneBear = false
var bool doneBull = false

if newQ
    // roll current → previous, reset current
    ph1 := qh1
    pl1 := ql1
    ph2 := qh2
    pl2 := ql2
    ph3 := qh3
    pl3 := ql3
    qh1 := h1
    ql1 := l1
    qh2 := h2
    ql2 := l2
    qh3 := h3
    ql3 := l3
    doneBear := false
    doneBull := false
    if show_lines
        line.new(time, high, time, low, xloc=xloc.bar_time, extend=extend.both, color=col_line, style=line.style_dotted)
else
    qh1 := math.max(nz(qh1, h1), h1)
    ql1 := math.min(nz(ql1, l1), l1)
    qh2 := math.max(nz(qh2, h2), h2)
    ql2 := math.min(nz(ql2, l2), l2)
    qh3 := math.max(nz(qh3, h3), h3)
    ql3 := math.min(nz(ql3, l3), l3)

// ── SMT detection (one-shot per quarter, confirmed bars only) ──
ready = not na(ph1) and not na(ph2) and not na(ph3)

swH1 = qh1 > ph1
swH2 = qh2 > ph2
swH3 = qh3 > ph3
swL1 = ql1 < pl1
swL2 = ql2 < pl2
swL3 = ql3 < pl3

smtBear = ready and (swH1 or swH2 or swH3) and not (swH1 and swH2 and swH3)
smtBull = ready and (swL1 or swL2 or swL3) and not (swL1 and swL2 and swL3)

evBear = false
evBull = false

roleStr(_b) => _b ? "SWEEP" : "HOLD"

if barstate.isconfirmed
    if smtBear and not doneBear
        doneBear := true
        evBear := true
        label.new(bar_index, na, "▽", yloc=yloc.abovebar, style=label.style_none, size=size.small, textcolor=col_bear, tooltip="Bearish SMT | " + sym1 + ":" + roleStr(swH1) + " " + sym2 + ":" + roleStr(swH2) + " " + sym3 + ":" + roleStr(swH3))
    if smtBull and not doneBull
        doneBull := true
        evBull := true
        label.new(bar_index, na, "△", yloc=yloc.belowbar, style=label.style_none, size=size.small, textcolor=col_bull, tooltip="Bullish SMT | " + sym1 + ":" + roleStr(swL1) + " " + sym2 + ":" + roleStr(swL2) + " " + sym3 + ":" + roleStr(swL3))

// ── Alerts ──
alertcondition(evBear, title="SMT Bearish", message="Simple SMT: Bearish divergence (roof)")
alertcondition(evBull, title="SMT Bullish", message="Simple SMT: Bullish divergence (floor)")
````
