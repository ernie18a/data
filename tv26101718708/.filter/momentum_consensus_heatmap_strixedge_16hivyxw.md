# Momentum Consensus Heatmap [StrixEDGE]

- url: https://www.tradingview.com/script/16hivYxw-Momentum-Consensus-Heatmap-StrixEDGE/
- type: indicator
- pine_id: PUB;24450c6b1ff4426fac93d6d424ca3637
- version: 1.0

## Description

█ MOMENTUM CONSENSUS HEATMAP

A multi-timeframe momentum aggregation system that scans 6 oscillators across 4 customizable timeframes and fires high-conviction BUY/SHORT signals only when a critical mass of indicators reach overbought or oversold consensus simultaneously.


█ CONCEPT

Most momentum-based strategies rely on a single oscillator on a single timeframe — a setup prone to false signals and noise. This indicator solves that by requiring cross-timeframe and cross-indicator agreement before generating a signal.

The core logic works in two layers:

  Layer 1 — Timeframe Consensus (per indicator):
  Each oscillator is evaluated across 4 timeframes (default: 15m, 1H, 4H, 1D). An indicator only qualifies as "Overbought" or "Oversold" when at least 3 out of 4 timeframes agree (configurable: 2/4, 3/4, or 4/4).

https://www.tradingview.com/x/eO4rLYXN/

  Layer 2 — Indicator Consensus (overall signal):
  A chart signal fires only when a user-defined number of indicators (default: 4 out of 6) have all independently reached Layer 1 consensus in the same direction.

https://www.tradingview.com/x/PEaLTwWU/

This dual-filter architecture dramatically reduces noise and isolates moments of genuine, broad-based momentum exhaustion.


█ OSCILLATORS USED

  • RSI (Relative Strength Index) — Classic momentum oscillator measuring speed and magnitude of price changes. Default OB/OS: 70/30.

https://www.tradingview.com/x/HTv0j96D/

  • Stochastic RSI — Stochastic formula applied to RSI values, more sensitive to short-term momentum shifts than raw RSI. Default OB/OS: 80/20.

https://www.tradingview.com/x/QeqFMXKx/

  • Stochastic Oscillator — Compares closing price to the high-low range over a lookback period. Independent from Stoch RSI. Default OB/OS: 80/20.

https://www.tradingview.com/x/Ww9hSEqn/

  • CCI (Commodity Channel Index) — Measures deviation from the statistical mean. Unbounded, making it useful for detecting extreme momentum. Default OB/OS: +100/−100.

https://www.tradingview.com/x/ez6u2sW5/

  • Williams %R — Reflects where the current close sits relative to the highest high. Inverted scale (−100 to 0). Default OB/OS: −20/−80.

https://www.tradingview.com/x/VQR9DExU/

  • MFI (Money Flow Index) — Volume-weighted RSI. Adds a volume confirmation dimension that pure price-based oscillators lack. Default OB/OS: 80/20.

https://www.tradingview.com/x/y0tVQq1d/

█ HEATMAP TABLE

The on-chart heatmap table provides a real-time dashboard of all 24 data points (6 indicators × 4 timeframes):

  • Each cell shows the live oscillator value with color-coded background:
      🔴 Red = Overbought zone
      🟢 Green = Oversold zone
      ⚫ Gray = Neutral

  • SCORE column shows how many timeframes agree for each indicator (e.g., "3/4 OB").

  • SIGNAL column shows whether that individual indicator has reached consensus ("SHORT ▼" / "BUY ▲" / "—").

  • CONSENSUS row at the bottom shows the overall verdict with a percentage score of indicator agreement.

Table position and text size are fully customizable through the settings panel.


█ CHART SIGNALS

When the overall consensus threshold is met:

  ▲ Green triangle below bar = BUY signal (oversold consensus)
  ▼ Red triangle above bar = SHORT signal (overbought consensus)

Signals fire only on the first bar of a new consensus event (no repeated signals while conditions persist). A subtle background color flash highlights the signal bar.


█ OPTIONAL TREND FILTER (EMA)

When enabled, signals are filtered by an EMA trend bias:
  • BUY signals require price above the EMA (buying in an uptrend)
  • SHORT signals require price below the EMA (shorting in a downtrend)
This is disabled by default to keep the indicator pure momentum-based, but can significantly improve signal quality in trending markets.


█ SETTINGS OVERVIEW

  ⏱ Timeframes — All 4 timeframes are independently configurable.

  ⚙ Indicator Lengths — Full control over each oscillator's lookback period.

  📊 OB/OS Thresholds — Adjust overbought/oversold levels for every oscillator independently.

  🎯 Signal Rules:
    • Min TF Consensus: How many timeframes must agree per indicator (2-4, default 3).
    • Min Indicators: How many indicators must reach consensus for a chart signal (1-6, default 4).

  🎨 Table Appearance — Position, size, and full color customization (OB color, OS color, neutral, header, text).

  🔔 Alerts — Native TradingView alerts with detailed messages including ticker, timeframe, and consensus count.


█ HOW TO USE

  1. Apply the indicator to any chart (works on all instruments and timeframes).

  2. The heatmap table updates in real time — use it as a momentum dashboard.

  3. Watch for chart signals:
     • When 4+ indicators show oversold consensus across 3+ timeframes → BUY signal.
     • When 4+ indicators show overbought consensus across 3+ timeframes → SHORT signal.

  4. Set up TradingView alerts to get notified when signals fire.

  5. For higher conviction:
     • Increase "Min Indicators" to 5 or 6 (fewer but stronger signals).
     • Require 4/4 timeframe agreement instead of 3/4.
     • Enable the EMA trend filter.


█ IMPORTANT NOTES

  • This indicator uses request.security() to fetch multi-timeframe data. On the current timeframe, values update in real time. Higher timeframe values reflect the last closed bar of that timeframe.

  • Signals are non-repainting once the bar closes. Intrabar, the table values and potential signals update as new ticks arrive (expected behavior for a real-time dashboard).

  • This tool is designed for identifying momentum exhaustion zones. It does not predict direction — use it in confluence with price action, support/resistance, and your broader trading plan.

  • Past performance is not indicative of future results. Always use proper risk management.


█ CREDITS & LICENSE

  Open source under Mozilla Public License 2.0.
  Built with Pine Script™ v6.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator(
     title            = "Momentum Consensus Heatmap [StrixEDGE]"
     , shorttitle     = "Momentum Consensus Heatmap [StrixEDGE]"
     , overlay        = true
     , max_labels_count = 500
     , max_lines_count  = 500
     )


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//                            INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── Timeframes ───────────────────────────────────────────────────────
string GRP_TF   = "⏱ Timeframes"
i_tf1           = input.timeframe("15",  "Timeframe 1", group = GRP_TF)
i_tf2           = input.timeframe("60",  "Timeframe 2", group = GRP_TF)
i_tf3           = input.timeframe("240", "Timeframe 3", group = GRP_TF)
i_tf4           = input.timeframe("D",   "Timeframe 4", group = GRP_TF)

// ── Indicator Lengths ────────────────────────────────────────────────
string GRP_LEN  = "⚙ Indicator Lengths"
i_rsiLen        = input.int(14,  "RSI Length",             minval = 2, group = GRP_LEN)
i_srsiLen       = input.int(14,  "Stochastic RSI Length",  minval = 2, group = GRP_LEN)
i_srsiSmooth    = input.int(3,   "Stoch RSI Smooth K",    minval = 1, group = GRP_LEN)
i_stochLen      = input.int(14,  "Stochastic Length",      minval = 2, group = GRP_LEN)
i_stochSmooth   = input.int(3,   "Stochastic Smooth K",   minval = 1, group = GRP_LEN)
i_cciLen        = input.int(20,  "CCI Length",             minval = 2, group = GRP_LEN)
i_wprLen        = input.int(14,  "Williams %R Length",     minval = 2, group = GRP_LEN)
i_mfiLen        = input.int(14,  "MFI Length",             minval = 2, group = GRP_LEN)

// ── OB / OS Thresholds ──────────────────────────────────────────────
string GRP_LVL  = "📊 OB / OS Thresholds"
i_rsiOB         = input.float(70,    "RSI  Overbought",    group = GRP_LVL)
i_rsiOS         = input.float(30,    "RSI  Oversold",      group = GRP_LVL)
i_srsiOB        = input.float(80,    "SRSI Overbought",    group = GRP_LVL)
i_srsiOS        = input.float(20,    "SRSI Oversold",      group = GRP_LVL)
i_stochOB       = input.float(80,    "STOCH Overbought",   group = GRP_LVL)
i_stochOS       = input.float(20,    "STOCH Oversold",     group = GRP_LVL)
i_cciOB         = input.float(100,   "CCI  Overbought",    group = GRP_LVL)
i_cciOS         = input.float(-100,  "CCI  Oversold",      group = GRP_LVL)
i_wprOB         = input.float(-20,   "W%R  Overbought",    group = GRP_LVL)
i_wprOS         = input.float(-80,   "W%R  Oversold",      group = GRP_LVL)
i_mfiOB         = input.float(80,    "MFI  Overbought",    group = GRP_LVL)
i_mfiOS         = input.float(20,    "MFI  Oversold",      group = GRP_LVL)

// ── Signal Rules ────────────────────────────────────────────────────
string GRP_SIG  = "🎯 Signal Rules"
i_minTF         = input.int(3, "Min TF Consensus (per indicator)",
                     minval = 2, maxval = 4, group = GRP_SIG,
                     tooltip = "An indicator counts as OB/OS only when at least this many timeframes agree.")
i_minInd        = input.int(4, "Min Indicators for Chart Signal",
                     minval = 1, maxval = 6, group = GRP_SIG,
                     tooltip = "Chart signal fires only when this many indicators have reached TF consensus in the same direction.")

// ── Entry Display ───────────────────────────────────────────────────
string GRP_ENT  = "📍 Entry Display"
i_showEntry     = input.bool(true,  "Show Entry on Chart",         group = GRP_ENT)
i_showEntryLbl  = input.bool(true,  "Show Entry Label",            group = GRP_ENT)
i_showEntryLine = input.bool(true,  "Show Entry Price Line",       group = GRP_ENT)
i_entryLineLen  = input.int(20,     "Line Length (bars)",          minval = 5,  maxval = 100, group = GRP_ENT)
i_entryStyle    = input.string("Full", "Entry Label Style",
                     options = ["Full", "Compact", "Minimal"],      group = GRP_ENT,
                     tooltip = "Full = multi-line card · Compact = two lines · Minimal = price only")
i_entryBuyClr   = input.color(#00E676, "BUY Color",               group = GRP_ENT)
i_entrySellClr  = input.color(#FF1744, "SELL Color",               group = GRP_ENT)

// ── Trend Filter (optional) ─────────────────────────────────────────
string GRP_FLT  = "📈 Trend Filter (EMA)"
i_useTrend      = input.bool(false, "Enable EMA Trend Filter",    group = GRP_FLT,
                     tooltip = "When enabled, BUY signals require price > EMA and SELL signals require price < EMA.")
i_emaLen        = input.int(200,    "EMA Length",  minval = 1,     group = GRP_FLT)

// ── Table Appearance ────────────────────────────────────────────────
string GRP_TBL  = "🎨 Table Appearance"
i_showTbl       = input.bool(true, "Show Table",                  group = GRP_TBL)
i_tblPos        = input.string("Bottom Right", "Position",
                     options = ["Top Left","Top Center","Top Right",
                                "Middle Left","Middle Center","Middle Right",
                                "Bottom Left","Bottom Center","Bottom Right"],
                     group = GRP_TBL)
i_tblSize       = input.string("Small", "Text Size",
                     options = ["Tiny","Small","Normal","Large"],
                     group = GRP_TBL)
i_obClr         = input.color(#EF5350,  "Overbought Color",       group = GRP_TBL)
i_osClr         = input.color(#26A69A,  "Oversold Color",         group = GRP_TBL)
i_neuClr        = input.color(#2A2E39,  "Neutral Color",          group = GRP_TBL)
i_hdrClr        = input.color(#131722,  "Header Background",      group = GRP_TBL)
i_cellClr       = input.color(#1E222D,  "Cell Background",        group = GRP_TBL)
i_txtClr        = input.color(#D1D4DC,  "Text Color",             group = GRP_TBL)
i_txtBright     = input.color(#FFFFFF,  "Signal Text Color",      group = GRP_TBL)

// ── Alerts ──────────────────────────────────────────────────────────
string GRP_ALT  = "🔔 Alerts"
i_alertBuy      = input.bool(true, "Alert on BUY",                group = GRP_ALT)
i_alertSell     = input.bool(true, "Alert on SELL",               group = GRP_ALT)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//                       CORE CALCULATIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

calcAll() =>
    float rsiV   = ta.rsi(close, i_rsiLen)
    float rRaw   = ta.rsi(close, i_srsiLen)
    float srsiV  = ta.sma(ta.stoch(rRaw, rRaw, rRaw, i_srsiLen), i_srsiSmooth)
    float stchV  = ta.sma(ta.stoch(close, high, low, i_stochLen), i_stochSmooth)
    float cciV   = ta.cci(close, i_cciLen)
    float hh     = ta.highest(high, i_wprLen)
    float ll     = ta.lowest(low,  i_wprLen)
    float wprV   = (hh - ll) != 0 ? -100.0 * (hh - close) / (hh - ll) : na
    float mfiV   = ta.mfi(hlc3, i_mfiLen)
    [rsiV, srsiV, stchV, cciV, wprV, mfiV]

[r1, sr1, st1, c1, w1, m1] = request.security(syminfo.tickerid, i_tf1, calcAll())
[r2, sr2, st2, c2, w2, m2] = request.security(syminfo.tickerid, i_tf2, calcAll())
[r3, sr3, st3, c3, w3, m3] = request.security(syminfo.tickerid, i_tf3, calcAll())
[r4, sr4, st4, c4, w4, m4] = request.security(syminfo.tickerid, i_tf4, calcAll())

float emaVal     = ta.ema(close, i_emaLen)
bool  trendUp    = close > emaVal
bool  trendDown  = close < emaVal


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//                       CONSENSUS LOGIC
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

b2i(bool b) => b ? 1 : 0

obCnt(float v1, float v2, float v3, float v4, float lvl) =>
    b2i(not na(v1) and v1 >= lvl) + b2i(not na(v2) and v2 >= lvl) +
     b2i(not na(v3) and v3 >= lvl) + b2i(not na(v4) and v4 >= lvl)

osCnt(float v1, float v2, float v3, float v4, float lvl) =>
    b2i(not na(v1) and v1 <= lvl) + b2i(not na(v2) and v2 <= lvl) +
     b2i(not na(v3) and v3 <= lvl) + b2i(not na(v4) and v4 <= lvl)

int rsiOBn   = obCnt(r1,  r2,  r3,  r4,  i_rsiOB)
int rsiOSn   = osCnt(r1,  r2,  r3,  r4,  i_rsiOS)
int srsiOBn  = obCnt(sr1, sr2, sr3, sr4, i_srsiOB)
int srsiOSn  = osCnt(sr1, sr2, sr3, sr4, i_srsiOS)
int stOBn    = obCnt(st1, st2, st3, st4, i_stochOB)
int stOSn    = osCnt(st1, st2, st3, st4, i_stochOS)
int cciOBn   = obCnt(c1,  c2,  c3,  c4,  i_cciOB)
int cciOSn   = osCnt(c1,  c2,  c3,  c4,  i_cciOS)
int wprOBn   = obCnt(w1,  w2,  w3,  w4,  i_wprOB)
int wprOSn   = osCnt(w1,  w2,  w3,  w4,  i_wprOS)
int mfiOBn   = obCnt(m1,  m2,  m3,  m4,  i_mfiOB)
int mfiOSn   = osCnt(m1,  m2,  m3,  m4,  i_mfiOS)

bool rsiOB   = rsiOBn  >= i_minTF
bool rsiOS   = rsiOSn  >= i_minTF
bool srsiOB  = srsiOBn >= i_minTF
bool srsiOS  = srsiOSn >= i_minTF
bool stOB    = stOBn   >= i_minTF
bool stOS    = stOSn   >= i_minTF
bool cciOB   = cciOBn  >= i_minTF
bool cciOS   = cciOSn  >= i_minTF
bool wprOB   = wprOBn  >= i_minTF
bool wprOS   = wprOSn  >= i_minTF
bool mfiOB   = mfiOBn  >= i_minTF
bool mfiOS   = mfiOSn  >= i_minTF

int totOB    = b2i(rsiOB)  + b2i(srsiOB) + b2i(stOB) + b2i(cciOB) + b2i(wprOB) + b2i(mfiOB)
int totOS    = b2i(rsiOS)  + b2i(srsiOS) + b2i(stOS) + b2i(cciOS) + b2i(wprOS) + b2i(mfiOS)

bool rawSell = totOB >= i_minInd
bool rawBuy  = totOS >= i_minInd
bool sellSig = i_useTrend ? (rawSell and trendDown) : rawSell
bool buySig  = i_useTrend ? (rawBuy  and trendUp)   : rawBuy

bool sellTrigger = sellSig and not sellSig[1]
bool buyTrigger  = buySig  and not buySig[1]


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//                     ENTRY SIGNAL SYSTEM
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float entryPrice = close

// ── Strength bar builder ──
strengthBar(int n) =>
    if n >= 6
        "██████"
    else if n == 5
        "█████░"
    else if n == 4
        "████░░"
    else if n == 3
        "███░░░"
    else if n == 2
        "██░░░░"
    else
        "█░░░░░"

// ── Label content by style ──
buyLabel(string style, float price, int strength) =>
    if style == "Full"
        "╭─── BUY ENTRY ───╮"
         + "\n│  " + syminfo.ticker
         + "\n│  " + str.tostring(price, format.mintick)
         + "\n│  " + strengthBar(strength) + "  " + str.tostring(strength) + "/6"
         + "\n╰──────────────────╯"
    else if style == "Compact"
        "▲ BUY  " + str.tostring(price, format.mintick)
         + "\n   " + strengthBar(strength) + " " + str.tostring(strength) + "/6"
    else
        "▲ " + str.tostring(price, format.mintick)

sellLabel(string style, float price, int strength) =>
    if style == "Full"
        "╭─── SELL ENTRY ──╮"
         + "\n│  " + syminfo.ticker
         + "\n│  " + str.tostring(price, format.mintick)
         + "\n│  " + strengthBar(strength) + "  " + str.tostring(strength) + "/6"
         + "\n╰──────────────────╯"
    else if style == "Compact"
        "▼ SELL  " + str.tostring(price, format.mintick)
         + "\n   " + strengthBar(strength) + " " + str.tostring(strength) + "/6"
    else
        "▼ " + str.tostring(price, format.mintick)


// ── BUY ENTRY ───────────────────────────────────────────────────────
if buyTrigger and i_showEntry

    // Arrow marker on candle
    label.new(bar_index, low, "▲",
         style     = label.style_label_up,
         color     = i_entryBuyClr,
         textcolor = #FFFFFF,
         size      = size.normal)

    // Info label
    if i_showEntryLbl
        label.new(bar_index + 3, low, buyLabel(i_entryStyle, entryPrice, totOS),
             style     = label.style_label_up,
             color     = color.new(i_entryBuyClr, 5),
             textcolor = #FFFFFF,
             size      = size.small,
             textalign = text.align_left)

    // Entry price line
    if i_showEntryLine
        line.new(bar_index, entryPrice, bar_index + i_entryLineLen, entryPrice,
             color = i_entryBuyClr, style = line.style_dashed, width = 2)
        label.new(bar_index + i_entryLineLen, entryPrice,
             " " + str.tostring(entryPrice, format.mintick),
             style = label.style_label_left,
             color = color.new(i_entryBuyClr, 20),
             textcolor = #FFFFFF,
             size = size.tiny)


// ── SELL ENTRY ──────────────────────────────────────────────────────
if sellTrigger and i_showEntry

    // Arrow marker on candle
    label.new(bar_index, high, "▼",
         style     = label.style_label_down,
         color     = i_entrySellClr,
         textcolor = #FFFFFF,
         size      = size.normal)

    // Info label
    if i_showEntryLbl
        label.new(bar_index + 3, high, sellLabel(i_entryStyle, entryPrice, totOB),
             style     = label.style_label_down,
             color     = color.new(i_entrySellClr, 5),
             textcolor = #FFFFFF,
             size      = size.small,
             textalign = text.align_left)

    // Entry price line
    if i_showEntryLine
        line.new(bar_index, entryPrice, bar_index + i_entryLineLen, entryPrice,
             color = i_entrySellClr, style = line.style_dashed, width = 2)
        label.new(bar_index + i_entryLineLen, entryPrice,
             " " + str.tostring(entryPrice, format.mintick),
             style = label.style_label_left,
             color = color.new(i_entrySellClr, 20),
             textcolor = #FFFFFF,
             size = size.tiny)


// ── Background highlight ────────────────────────────────────────────
color sellFlash = na
color buyFlash  = na
if sellTrigger
    sellFlash := color.new(i_entrySellClr, 85)
if buyTrigger
    buyFlash := color.new(i_entryBuyClr, 85)
bgcolor(sellFlash, title = "Sell BG")
bgcolor(buyFlash,  title = "Buy BG")

plot(i_useTrend ? emaVal : na, "Trend EMA", color = color.new(#FF9800, 40), linewidth = 2)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//                         HEATMAP TABLE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tablePos() =>
    switch i_tblPos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

tableSz() =>
    switch i_tblSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        =>          size.large

cellBg(float val, float ob, float os) =>
    color result = i_cellClr
    if na(val)
        result := color.new(i_neuClr, 50)
    else if val >= ob
        result := i_obClr
    else if val <= os
        result := i_osClr
    result

sigBg(int obN, int osN) =>
    color result = i_cellClr
    if obN >= i_minTF
        result := i_obClr
    else if osN >= i_minTF
        result := i_osClr
    result

fv(float val) =>
    if na(val)
        "—"
    else
        str.tostring(math.round(val * 10) / 10)

scoreTxt(int obN, int osN) =>
    if obN >= i_minTF
        str.tostring(obN) + "/4 OB"
    else if osN >= i_minTF
        str.tostring(osN) + "/4 OS"
    else
        int maxN = math.max(obN, osN)
        if maxN > 0
            str.tostring(maxN) + "/4"
        else
            "—"

sigTxt(int obN, int osN) =>
    if obN >= i_minTF
        "SELL ▼"
    else if osN >= i_minTF
        "BUY ▲"
    else
        "—"

tfLbl(string tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "D"   => "1D"
        "1D"  => "1D"
        "W"   => "1W"
        "1W"  => "1W"
        "M"   => "1M"
        "1M"  => "1M"
        => tf

if i_showTbl and barstate.islast

    var tbl = table.new(tablePos(), 7, 9, bgcolor = i_hdrClr,
         border_color = color.new(#363A45, 0), border_width = 1,
         frame_color  = color.new(#363A45, 0), frame_width  = 2)
    sz = tableSz()

    // Row 0 — Title
    table.cell(tbl, 0, 0, "⚡ MTF MOMENTUM HEATMAP StrixEDGE", text_color = i_txtBright, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.merge_cells(tbl, 0, 0, 6, 0)

    // Row 1 — Headers
    string[] hdr = array.from("INDICATOR", tfLbl(i_tf1), tfLbl(i_tf2), tfLbl(i_tf3), tfLbl(i_tf4), "SCORE", "SIGNAL")
    for col = 0 to 6
        table.cell(tbl, col, 1, array.get(hdr, col), text_color = color.new(i_txtClr, 20), text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_center)

    // Row 2 — RSI
    table.cell(tbl, 0, 2, "RSI",  text_color = i_txtClr, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_left)
    table.cell(tbl, 1, 2, fv(r1), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(r1, i_rsiOB, i_rsiOS), text_halign = text.align_center)
    table.cell(tbl, 2, 2, fv(r2), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(r2, i_rsiOB, i_rsiOS), text_halign = text.align_center)
    table.cell(tbl, 3, 2, fv(r3), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(r3, i_rsiOB, i_rsiOS), text_halign = text.align_center)
    table.cell(tbl, 4, 2, fv(r4), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(r4, i_rsiOB, i_rsiOS), text_halign = text.align_center)
    table.cell(tbl, 5, 2, scoreTxt(rsiOBn, rsiOSn), text_color = i_txtBright, text_size = sz, bgcolor = sigBg(rsiOBn, rsiOSn), text_halign = text.align_center)
    table.cell(tbl, 6, 2, sigTxt(rsiOBn, rsiOSn),   text_color = i_txtBright, text_size = sz, bgcolor = sigBg(rsiOBn, rsiOSn), text_halign = text.align_center)

    // Row 3 — SRSI
    table.cell(tbl, 0, 3, "SRSI",  text_color = i_txtClr, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_left)
    table.cell(tbl, 1, 3, fv(sr1), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(sr1, i_srsiOB, i_srsiOS), text_halign = text.align_center)
    table.cell(tbl, 2, 3, fv(sr2), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(sr2, i_srsiOB, i_srsiOS), text_halign = text.align_center)
    table.cell(tbl, 3, 3, fv(sr3), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(sr3, i_srsiOB, i_srsiOS), text_halign = text.align_center)
    table.cell(tbl, 4, 3, fv(sr4), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(sr4, i_srsiOB, i_srsiOS), text_halign = text.align_center)
    table.cell(tbl, 5, 3, scoreTxt(srsiOBn, srsiOSn), text_color = i_txtBright, text_size = sz, bgcolor = sigBg(srsiOBn, srsiOSn), text_halign = text.align_center)
    table.cell(tbl, 6, 3, sigTxt(srsiOBn, srsiOSn),   text_color = i_txtBright, text_size = sz, bgcolor = sigBg(srsiOBn, srsiOSn), text_halign = text.align_center)

    // Row 4 — STOCH
    table.cell(tbl, 0, 4, "STOCH", text_color = i_txtClr, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_left)
    table.cell(tbl, 1, 4, fv(st1), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(st1, i_stochOB, i_stochOS), text_halign = text.align_center)
    table.cell(tbl, 2, 4, fv(st2), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(st2, i_stochOB, i_stochOS), text_halign = text.align_center)
    table.cell(tbl, 3, 4, fv(st3), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(st3, i_stochOB, i_stochOS), text_halign = text.align_center)
    table.cell(tbl, 4, 4, fv(st4), text_color = i_txtBright, text_size = sz, bgcolor = cellBg(st4, i_stochOB, i_stochOS), text_halign = text.align_center)
    table.cell(tbl, 5, 4, scoreTxt(stOBn, stOSn), text_color = i_txtBright, text_size = sz, bgcolor = sigBg(stOBn, stOSn), text_halign = text.align_center)
    table.cell(tbl, 6, 4, sigTxt(stOBn, stOSn),   text_color = i_txtBright, text_size = sz, bgcolor = sigBg(stOBn, stOSn), text_halign = text.align_center)

    // Row 5 — CCI
    table.cell(tbl, 0, 5, "CCI",   text_color = i_txtClr, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_left)
    table.cell(tbl, 1, 5, fv(c1),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(c1, i_cciOB, i_cciOS), text_halign = text.align_center)
    table.cell(tbl, 2, 5, fv(c2),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(c2, i_cciOB, i_cciOS), text_halign = text.align_center)
    table.cell(tbl, 3, 5, fv(c3),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(c3, i_cciOB, i_cciOS), text_halign = text.align_center)
    table.cell(tbl, 4, 5, fv(c4),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(c4, i_cciOB, i_cciOS), text_halign = text.align_center)
    table.cell(tbl, 5, 5, scoreTxt(cciOBn, cciOSn), text_color = i_txtBright, text_size = sz, bgcolor = sigBg(cciOBn, cciOSn), text_halign = text.align_center)
    table.cell(tbl, 6, 5, sigTxt(cciOBn, cciOSn),   text_color = i_txtBright, text_size = sz, bgcolor = sigBg(cciOBn, cciOSn), text_halign = text.align_center)

    // Row 6 — W%R
    table.cell(tbl, 0, 6, "W%R",   text_color = i_txtClr, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_left)
    table.cell(tbl, 1, 6, fv(w1),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(w1, i_wprOB, i_wprOS), text_halign = text.align_center)
    table.cell(tbl, 2, 6, fv(w2),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(w2, i_wprOB, i_wprOS), text_halign = text.align_center)
    table.cell(tbl, 3, 6, fv(w3),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(w3, i_wprOB, i_wprOS), text_halign = text.align_center)
    table.cell(tbl, 4, 6, fv(w4),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(w4, i_wprOB, i_wprOS), text_halign = text.align_center)
    table.cell(tbl, 5, 6, scoreTxt(wprOBn, wprOSn), text_color = i_txtBright, text_size = sz, bgcolor = sigBg(wprOBn, wprOSn), text_halign = text.align_center)
    table.cell(tbl, 6, 6, sigTxt(wprOBn, wprOSn),   text_color = i_txtBright, text_size = sz, bgcolor = sigBg(wprOBn, wprOSn), text_halign = text.align_center)

    // Row 7 — MFI
    table.cell(tbl, 0, 7, "MFI",   text_color = i_txtClr, text_size = sz, bgcolor = i_hdrClr, text_halign = text.align_left)
    table.cell(tbl, 1, 7, fv(m1),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(m1, i_mfiOB, i_mfiOS), text_halign = text.align_center)
    table.cell(tbl, 2, 7, fv(m2),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(m2, i_mfiOB, i_mfiOS), text_halign = text.align_center)
    table.cell(tbl, 3, 7, fv(m3),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(m3, i_mfiOB, i_mfiOS), text_halign = text.align_center)
    table.cell(tbl, 4, 7, fv(m4),  text_color = i_txtBright, text_size = sz, bgcolor = cellBg(m4, i_mfiOB, i_mfiOS), text_halign = text.align_center)
    table.cell(tbl, 5, 7, scoreTxt(mfiOBn, mfiOSn), text_color = i_txtBright, text_size = sz, bgcolor = sigBg(mfiOBn, mfiOSn), text_halign = text.align_center)
    table.cell(tbl, 6, 7, sigTxt(mfiOBn, mfiOSn),   text_color = i_txtBright, text_size = sz, bgcolor = sigBg(mfiOBn, mfiOSn), text_halign = text.align_center)

    // Row 8 — CONSENSUS
    string conLabel = "NEUTRAL"
    color  conBg    = i_hdrClr
    string conScore = "—"
    string conPct   = "—"
    if sellSig
        conLabel := "⚡ SELL"
        conBg    := i_obClr
        conScore := str.tostring(totOB) + "/6"
        conPct   := str.tostring(math.round(totOB / 6.0 * 100)) + "%"
    else if buySig
        conLabel := "⚡ BUY"
        conBg    := i_osClr
        conScore := str.tostring(totOS) + "/6"
        conPct   := str.tostring(math.round(totOS / 6.0 * 100)) + "%"

    table.cell(tbl, 0, 8, "CONSENSUS", text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.cell(tbl, 1, 8, "",     text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_center)
    table.cell(tbl, 2, 8, "",     text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_center)
    table.cell(tbl, 3, 8, conPct, text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_center)
    table.merge_cells(tbl, 1, 8, 3, 8)
    table.cell(tbl, 4, 8, "",       text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_center)
    table.cell(tbl, 5, 8, conScore, text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_center)
    table.cell(tbl, 6, 8, conLabel, text_color = i_txtBright, text_size = sz, bgcolor = conBg, text_halign = text.align_center, text_font_family = font.family_monospace)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//                            ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(buyTrigger,           title = "MTF — BUY Entry",    message = "MTF Consensus BUY ENTRY on {{ticker}} ({{interval}})")
alertcondition(sellTrigger,          title = "MTF — SELL Entry",   message = "MTF Consensus SELL ENTRY on {{ticker}} ({{interval}})")
alertcondition(buyTrigger or sellTrigger, title = "MTF — Any Entry", message = "MTF Consensus Entry signal on {{ticker}} ({{interval}})")

if buyTrigger and i_alertBuy
    alert("🟢 BUY ENTRY │ " + syminfo.ticker + " │ " + str.tostring(close, format.mintick) + " │ Strength " + str.tostring(totOS) + "/6", alert.freq_once_per_bar)
if sellTrigger and i_alertSell
    alert("🔴 SELL ENTRY │ " + syminfo.ticker + " │ " + str.tostring(close, format.mintick) + " │ Strength " + str.tostring(totOB) + "/6", alert.freq_once_per_bar)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
````
