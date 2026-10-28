# Regime Compass [Markov]

- url: https://www.tradingview.com/script/7ihiHOFc-Regime-Compass-Markov/
- type: indicator
- pine_id: PUB;f1ac737213194aad98f8e45ce1bd6926
- version: 1.0

## Description

What it does
Answers one question with one number: is this session expanding or pinning?

How it works
Three orthogonal reads of price, each rescaled to the same −100…+100 axis and
blended 40/35/25:
• Volatility percentile — ATR as a share of price, ranked against its own
  history, so "high volatility" means high *for this instrument*.
• Efficiency ratio — net travel divided by total path over the lookback
  (Kaufman). High means the market is going somewhere; low means it is
  working the same area repeatedly.
• Persistence — a variance ratio: the standard deviation of n-bar returns
  against √n × the standard deviation of 1-bar returns. Above 1 leans
  trending, below 1 leans mean-reverting.
Above the threshold reads EXPANSION, below −threshold reads COMPRESSION.
A higher-timeframe read of the same score is available for confluence.

How to use it
As context, not as a signal. It says what kind of day you are in, not what to
do about it. The Markov strategies gate on this exact value — what you see
here is what they act on.

Settings Session · Regime engine (ATR length, percentile lookback,
efficiency length, persistence length, threshold) · Display · Alerts

Alerts State change; agreement with the higher timeframe.

Notes This is derived from price only. It is an expansion/compression
proxy — it is not dealer gamma and does not measure options positioning.
Context and education, not advice.

## Source Code

````pine
// Markov · Regime Compass — one number for "is this session expanding or
// pinning", built from volatility rank, path efficiency and return persistence.
// The same engine gates the three Markov strategies, so what you see here is
// literally what they trade on. Price-derived: this is not dealer gamma.
// © joshionchain

//@version=6
indicator("Regime Compass [Markov]", "MKV Regime", overlay = false, precision = 0)

M_ID   = "regime-compass"
M_NAME = "Regime Compass"

// >>> MARKOV:KERNEL v1.0.0 (ace21668) — generated from pine/kernel/markov-kernel.pine. Do not edit here; run `pnpm pine:sync`.
// ── brand ────────────────────────────────────────────────────────────────────
M_BRAND   = "MARKOV"
M_VER     = "1.0.0"
M_SITE    = "markov.io"

// Chart palette. Derived from the site tokens in apps/web/app/globals.css and
// lifted for legibility on dark chart backgrounds (site --accent #2b50ff is too
// dark against #0a0c10). Keep these two in sync by hand when the brand moves.
color M_C_ACCENT = #5a78ff  // site --accent, lifted
color M_C_UP     = #14c08a  // site --up, lifted
color M_C_DOWN   = #f0555a  // site --down, lifted
color M_C_INK    = #e8ecf2
color M_C_DIM    = #8a93a0
color M_C_LINE   = #2a2f3a
color M_C_PANEL  = #0a0c10

// ── session ──────────────────────────────────────────────────────────────────
g_mv_ses = "Session (futures-native)"
i_tz  = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "Europe/London", "Asia/Tokyo", "UTC"], group = g_mv_ses, tooltip = "All session windows below are evaluated in this timezone, not the chart's.")
i_rth = input.session("0930-1600", "Regular hours (RTH)", group = g_mv_ses)
i_on  = input.session("1800-0930", "Overnight (Globex)", group = g_mv_ses)

mvInRTH  = not na(time(timeframe.period, i_rth, i_tz))
mvInON   = not na(time(timeframe.period, i_on, i_tz))
mvNewRTH = mvInRTH and not mvInRTH[1]
mvEndRTH = not mvInRTH and mvInRTH[1]
mvNewON  = mvInON and not mvInON[1]

// ── anchored VWAP (computed by hand: `ta.vwap` errors on volume-less symbols) ─
g_mv_vwap = "VWAP"
i_vwapAnchor = input.string("RTH open", "Anchor", options = ["RTH open", "Globex open", "Daily"], group = g_mv_vwap)

mvNewAnchor = i_vwapAnchor == "RTH open" ? mvNewRTH : i_vwapAnchor == "Globex open" ? mvNewON : timeframe.change("D")

var float _mvPV  = 0.0
var float _mvVV  = 0.0
var float _mvP2V = 0.0
_mvW = nz(volume) > 0 ? volume : 1.0
if mvNewAnchor
    _mvPV  := 0.0
    _mvVV  := 0.0
    _mvP2V := 0.0
_mvPV  += hlc3 * _mvW
_mvVV  += _mvW
_mvP2V += hlc3 * hlc3 * _mvW
mvVwap   = _mvVV > 0 ? _mvPV / _mvVV : na
_mvVar   = _mvVV > 0 ? math.max(0.0, _mvP2V / _mvVV - mvVwap * mvVwap) : na
mvVwapSd = math.sqrt(_mvVar)

// ── regime engine ────────────────────────────────────────────────────────────
// Price-derived only. This is an expansion/compression proxy — it is NOT dealer
// gamma and must never be described as such. Three orthogonal reads, blended:
//   volatility percentile  · where is realised vol against its own history
//   efficiency ratio       · how much travel per unit of movement (Kaufman)
//   persistence            · variance ratio; >1 trends, <1 mean-reverts
g_mv_reg = "Regime engine"
i_regAtr   = input.int(14,  "ATR length",            minval = 2,  group = g_mv_reg)
i_regRank  = input.int(200, "Percentile lookback",   minval = 20, group = g_mv_reg, tooltip = "History used to rank current volatility and to normalise persistence.")
i_regEff   = input.int(20,  "Efficiency length",     minval = 2,  group = g_mv_reg)
i_regPer   = input.int(10,  "Persistence length",    minval = 2,  group = g_mv_reg)
i_regThr   = input.int(25,  "State threshold",       minval = 5, maxval = 90, group = g_mv_reg, tooltip = "Score above +threshold reads EXPANSION, below -threshold reads COMPRESSION.")

// ta.* must be evaluated on every bar to keep its internal state correct,
// so it is hoisted out of the ternary rather than called conditionally.
_mvAtr    = ta.atr(i_regAtr)
_mvAtrPct = close > 0 ? _mvAtr / close * 100 : na
mvVolPct  = ta.percentrank(_mvAtrPct, i_regRank)

_mvDir = math.abs(close - close[i_regEff])
_mvPath = math.sum(math.abs(ta.change(close)), i_regEff)
mvEff = _mvPath > 0 ? _mvDir / _mvPath : 0.0

_mvR1  = ta.change(math.log(close))
_mvRN  = ta.change(math.log(close), i_regPer)
_mvSd1 = ta.stdev(_mvR1, i_regRank)
_mvSdN = ta.stdev(_mvRN, i_regRank)
mvPersist = _mvSd1 > 0 ? _mvSdN / (_mvSd1 * math.sqrt(i_regPer)) : 1.0

f_mvClamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))

_mvZVol = nz(mvVolPct, 50.0) - 50.0
_mvZEff = f_mvClamp((mvEff - 0.35) * 200.0, -100.0, 100.0)
_mvZPer = f_mvClamp((nz(mvPersist, 1.0) - 1.0) * 150.0, -100.0, 100.0)
mvRegime = f_mvClamp(0.40 * _mvZVol + 0.35 * _mvZEff + 0.25 * _mvZPer, -100.0, 100.0)

mvState = mvRegime >= i_regThr ? "EXPANSION" : mvRegime <= -i_regThr ? "COMPRESSION" : "NEUTRAL"
mvStateColor = mvState == "EXPANSION" ? M_C_UP : mvState == "COMPRESSION" ? M_C_ACCENT : M_C_DIM
mvFlip = mvState != mvState[1]

// ── alert contract ───────────────────────────────────────────────────────────
// One JSON shape across the whole suite so a single webhook (and the Markov MCP
// surface) can consume every script. Bump "v" if the shape ever changes.
f_mvAlert(string kind, string dir, float px, string note) =>
    '{"v":1,"src":"markov","script":"' + M_ID + '","ver":"' + M_VER + '","sym":"' + syminfo.tickerid + '","tf":"' + timeframe.period + '","t":' + str.tostring(time_close) + ',"kind":"' + kind + '","dir":"' + dir + '","px":' + str.tostring(px, format.mintick) + ',"regime":"' + mvState + '","score":' + str.tostring(math.round(mvRegime)) + ',"note":"' + note + '"}'

// ── panel ────────────────────────────────────────────────────────────────────
g_mv_ui = "Panel"
i_panel    = input.bool(true, "Show panel", group = g_mv_ui)
i_panelPos = input.string("Bottom right", "Position", options = ["Top right", "Middle right", "Bottom right", "Bottom left"], group = g_mv_ui)

f_mvPanelPos() =>
    switch i_panelPos
        "Top right"    => position.top_right
        "Middle right" => position.middle_right
        "Bottom left"  => position.bottom_left
        => position.bottom_right

f_mvPanelNew(simple int rows) =>
    table.new(f_mvPanelPos(), 2, rows + 2, bgcolor = color.new(M_C_PANEL, 12), border_color = color.new(M_C_LINE, 30), border_width = 1, frame_color = color.new(M_C_LINE, 30), frame_width = 1)

f_mvPanelHead(table t) =>
    table.cell(t, 0, 0, M_BRAND, text_color = M_C_ACCENT, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, 0, M_NAME, text_color = M_C_DIM, text_size = size.tiny, text_halign = text.align_right)

f_mvPanelRow(table t, int row, string k, string v, color vc) =>
    table.cell(t, 0, row, k, text_color = M_C_DIM, text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, row, v, text_color = vc, text_size = size.tiny, text_halign = text.align_right)

f_mvPanelFoot(table t, int row) =>
    table.cell(t, 0, row, M_SITE, text_color = color.new(M_C_DIM, 35), text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, row, "context, not advice", text_color = color.new(M_C_DIM, 35), text_size = size.tiny, text_halign = text.align_right)
// <<< MARKOV:KERNEL
// ── inputs ───────────────────────────────────────────────────────────────────
g_d = "Display"
i_comps  = input.bool(false, "Show components", group = g_d, tooltip = "Volatility percentile, efficiency ratio and persistence, each rescaled to the same -100…100 axis as the score.")
i_tint   = input.bool(true,  "Tint the pane by state", group = g_d)
i_htfOn  = input.bool(true,  "Higher-timeframe regime", inline = "h", group = g_d)
i_htf    = input.timeframe("60", "", inline = "h", group = g_d)

g_al = "Alerts"
i_alFlip = input.bool(true,  "State change", group = g_al)
i_alAgree= input.bool(false, "This timeframe agrees with the higher one", group = g_al)

// ── higher-timeframe read ────────────────────────────────────────────────────
// Same expression, evaluated in the higher-timeframe context. lookahead_off and
// a confirmed-bar read: the historical series never sees the future.
htfRegime = i_htfOn ? request.security(syminfo.tickerid, i_htf, mvRegime[1], lookahead = barmerge.lookahead_off) : na
htfState  = na(htfRegime) ? "—" : htfRegime >= i_regThr ? "EXPANSION" : htfRegime <= -i_regThr ? "COMPRESSION" : "NEUTRAL"
agree     = not na(htfRegime) and htfState == mvState and mvState != "NEUTRAL"

// bars spent in the current state
var int stateBars = 0
stateBars := mvFlip ? 1 : stateBars + 1

// ── plots ────────────────────────────────────────────────────────────────────
scoreCol = mvRegime >= i_regThr ? M_C_UP : mvRegime <= -i_regThr ? M_C_ACCENT : M_C_DIM
plot(mvRegime, "Regime score", color = scoreCol, linewidth = 2)
plot(mvRegime, "Regime histogram", color = color.new(scoreCol, 78), style = plot.style_histogram, linewidth = 1, display = display.pane)

hline(0, "Zero", color = color.new(M_C_LINE, 20), linestyle = hline.style_solid)
hUp = hline(i_regThr,  "Expansion threshold",   color = color.new(M_C_UP, 55), linestyle = hline.style_dotted)
hDn = hline(-i_regThr, "Compression threshold", color = color.new(M_C_ACCENT, 55), linestyle = hline.style_dotted)
hline(100, "Max", color = color.new(M_C_LINE, 70), linestyle = hline.style_dotted)
hline(-100, "Min", color = color.new(M_C_LINE, 70), linestyle = hline.style_dotted)
fill(hUp, hDn, color = color.new(M_C_LINE, 94), title = "Neutral band")

plot(i_comps ? nz(mvVolPct, 50) - 50 : na, "Volatility percentile", color = color.new(M_C_DOWN, 40), display = display.pane)
plot(i_comps ? f_mvClamp((mvEff - 0.35) * 200, -100, 100) : na, "Efficiency", color = color.new(M_C_UP, 40), display = display.pane)
plot(i_comps ? f_mvClamp((nz(mvPersist, 1) - 1) * 150, -100, 100) : na, "Persistence", color = color.new(M_C_ACCENT, 40), display = display.pane)

plot(i_htfOn ? htfRegime : na, "HTF regime", color = color.new(M_C_INK, 55), style = plot.style_stepline)

bgcolor(i_tint and mvState == "EXPANSION" ? color.new(M_C_UP, 93) : i_tint and mvState == "COMPRESSION" ? color.new(M_C_ACCENT, 93) : na, title = "State tint")
plotshape(mvFlip and barstate.isconfirmed, "Regime flip", shape.diamond, location.bottom, color.new(mvStateColor, 25), size = size.tiny)

// ── alerts ───────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    if i_alFlip and mvFlip
        alert(f_mvAlert("regime_flip", mvState == "EXPANSION" ? "expansion" : mvState == "COMPRESSION" ? "compression" : "neutral", close, "state change"), alert.freq_once_per_bar_close)
    if i_alAgree and agree and not agree[1]
        alert(f_mvAlert("regime_agree", str.lower(mvState), close, "aligned with " + i_htf), alert.freq_once_per_bar_close)

// ── panel ────────────────────────────────────────────────────────────────────
var table pnl = f_mvPanelNew(5)
if i_panel and barstate.islast
    f_mvPanelHead(pnl)
    f_mvPanelRow(pnl, 1, "state", mvState + "  " + str.tostring(math.round(mvRegime)), mvStateColor)
    f_mvPanelRow(pnl, 2, "held for", str.tostring(stateBars) + " bars", M_C_INK)
    f_mvPanelRow(pnl, 3, "vol pct", str.tostring(math.round(nz(mvVolPct))), nz(mvVolPct, 50) >= 50 ? M_C_DOWN : M_C_DIM)
    f_mvPanelRow(pnl, 4, "efficiency", str.tostring(mvEff, "#.00"), mvEff >= 0.35 ? M_C_UP : M_C_DIM)
    f_mvPanelRow(pnl, 5, i_htfOn ? i_htf : "htf", i_htfOn ? htfState : "off", agree ? mvStateColor : M_C_DIM)
    f_mvPanelFoot(pnl, 6)
````
