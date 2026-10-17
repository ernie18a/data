# Position Architect [JOAT]

- url: https://www.tradingview.com/script/lLXC91nn-Position-Architect-JOAT/
- type: indicator
- pine_id: PUB;d0af6fa1f36a47ce9d3cd2ba5ad4e0ff
- version: 1.0

## Description

[b]Position Architect [JOAT][/b]

Position Architect is an auto-triggered trade-plan visualizer. It consumes a signal source (any plot of another indicator, or a fallback SMA-cross), arms a trade with ATR-scaled stop loss and three risk-reward-scaled targets, and tracks the trade live with breakeven slide, R-multiple lines, MFE / MAE tracking, multi-currency PnL, position sizing, required margin, Kelly sizing suggestion, and a trade-history strip.

[image]https://www.tradingview.com/x/KlYd2a8N/[/image]

[b]What makes it different[/b]
[list]
[*] Most trade-planner indicators are manual: the user clicks entry, stop, and target. Position Architect is auto-triggered via input.source, so it plans trades from external signal feeds (other JOAT indicators or any compatible script).
[*] Four trigger modes: Manual toggle, Source-above-SMA, Source-cross-above-SMA, Source-cross-below-SMA. These cover bias, breakout, and counter-trend logics.
[*] A three-target ladder (not just one or two) with intermediate R-multiple lines (0.5R, 1R, 1.5R, 2R, 2.5R, 3R) drawn between entry and Target 3 so you see partial-take levels at a glance.
[*] Live R-multiple, MFE, MAE displayed next to the trade in real time. After the trade closes, those values are baked into a persistent history label.
[*] Kelly sizing suggestion based on an assumed win rate and the current risk-reward, capped at 25% to avoid pathological recommendations.
[/list]

[b]How it works[/b]
[list=1]
[*] The signal source is the user-selected input.source. The trigger rule (one of four modes) determines when a long or short is armed.
[*] On arm: entry equals the current close. SL equals low minus ATR(14) times slMult for longs (or symmetric for shorts). Three targets at entry plus or minus risk times tp1Mult / tp2Mult / tp3Mult.
[*] Lifecycle gates on bar_index greater than tradeBar so the arm bar itself cannot also register hits (preventing spurious instant fills).
[*] Each subsequent bar: check for TP1, TP2, TP3 hits in order, plus stop-loss. TP3 takes precedence over SL on same-bar pierces. If TP1 hits and breakeven is enabled, the stop slides to entry.
[*] Position sizing: pos_size equals (capital times riskPct / 100) divided by (sl_pct / 100). Required margin equals pos_size divided by leverage.
[*] Kelly suggestion: f-star equals winRate minus (1 minus winRate) divided by RR, clamped to 25% max.
[/list]

[b]Reading the chart[/b]
[list]
[*] Five horizontal price lines: entry (blue), SL (red), TP1 / TP2 / TP3 (green shades), each width 3 to 5.
[*] Five price-only labels at the right edge with R-multiples and percentages.
[*] Two linefills: a translucent red risk zone between entry and SL, a translucent green reward zone between entry and TP3.
[*] bgcolor tint while a trade is open.
[*] A 1-bar bgcolor pulse on TP / SL / breakeven events.
[*] A live R+0.8 MFE+1.5 MAE-0.3 label updating each bar near current price.
[*] Bars-in-trade counter near the entry.
[*] Trade-history strip above past entries with W/L outcomes and R-multiples.
[*] R-multiple intermediate lines with right-edge labels.
[*] A daily trade count plus win-rate summary.
[*] A comprehensive dashboard with capital, risk, leverage, R:R, Kelly, position size, required margin, direction, entry, current price, live PnL, status (OPEN / WIN / LOSS), bars in trade.
[/list]

[b]Signals[/b]
[list]
[*] Trade activated long / short
[*] Target 1 / 2 / 3 hit
[*] Stop loss hit
[*] Breakeven slid
[/list]
All gated on barstate.isconfirmed or barstate.ishistory. No future references.

[b]Inputs[/b]
[list]
[*] [b]Signal[/b]: signal source, trigger mode, signal SMA length, manual long / short toggles.
[*] [b]Targets[/b]: SL ATR multiplier, TP1 / TP2 / TP3 risk multipliers, breakeven toggle, line extension bars.
[*] [b]Capital[/b]: capital amount, risk percent, leverage, currency code.
[*] [b]Kelly[/b]: assumed win rate.
[*] [b]Visual[/b]: bullish / bearish colors, entry line color, SL line color, TP line color, R-multiple lines toggle, history strip toggle.
[*] [b]Dashboard[/b]: position, size.
[/list]

[b]How traders use this[/b]
[list]
[*] [b]Discretionary planning[/b]: switch to Manual mode and toggle manualLong / manualShort to drop a complete plan at the current price, with ATR-aware stops and risk-aware sizing.
[*] [b]Signal integration[/b]: connect Position Architect's signal source to another JOAT indicator's plot output (for example the composite of Iridescent Helix or the Stage-3 line of Sentinel Cascade) and let it auto-arm trades.
[*] [b]Risk audit[/b]: the dashboard's R:R, position size, required margin, and Kelly suggestion are an instant pre-trade audit. You can compare across instruments.
[*] [b]Performance review[/b]: the trade-history strip lets you scroll back through recent trades on the chart and see R-multiples without needing a separate journal.
[/list]

[b]Limitations[/b]
[list]
[*] Kelly sizing assumes a stable win-rate-and-R distribution. Real performance varies. The suggestion is a calibration reference, not a recommendation.
[*] Position sizing is in price units. For futures or forex contracts the user must convert to contract count manually.
[*] The signal source must be a series compatible with input.source. If the connected indicator does not expose a useful plot, the trigger logic falls back to close.
[*] Trade lifecycle assumes one open position at a time. No pyramiding inside this script.
[/list]

[b]Compatibility[/b]
Pine Script v6 open-source indicator (overlay). Any symbol, any timeframe. ASCII currency codes (no Unicode glyphs) for cross-platform display. No request.security calls.

[b]Defaults[/b]
SL ATR multiplier 1.5, targets at 1R / 2R / 3.5R, breakeven on after TP1, mint / red palette, ten-thousand-dollar capital with one percent risk and one times leverage, top-right medium dashboard.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
// JOAT — Position Architect | Pine v6, overlay
// Auto-triggered trade planner: arms Entry / SL / TP1-3, tracks lifecycle.
indicator("Position Architect [JOAT]", "PSA [JOAT]", overlay=true, explicit_plot_zorder=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, behind_chart=false)

// ════════════════════════════════════════════════════════════════════
// INPUTS
// ════════════════════════════════════════════════════════════════════
g_signal   = "Signal"
g_targets  = "Targets"
g_capital  = "Capital"
g_kelly    = "Kelly"
g_visual   = "Visual"
g_history  = "History & R-Zones"
g_dash     = "Dashboard"

// ── Signal ──────────────────────────────────────────────────────────
sigSrc       = input.source(close, "Signal Source",                                            group=g_signal,   tooltip="Connect to another indicator's plot, or use close as a fallback. The Trigger Mode below decides how this source arms a trade.")
triggerMode  = input.string("Source Cross Above SMA", "Trigger Mode",
     options=["Manual","Source Above SMA","Source Cross Above SMA","Source Cross Below SMA"], group=g_signal,   tooltip="Mode that converts the signal source into a long / short arm. Manual fires when you toggle the bool inputs below.")
sigSmaLen    = input.int(20,    "Signal SMA Length",        minval=2,                          group=g_signal,   tooltip="SMA length applied to the signal source for cross-based trigger modes.")
manualLong   = input.bool(false,"Manual Long Arm (toggle to fire)",                            group=g_signal,   tooltip="Toggle this bool to arm a long trade on the next confirmed bar (Manual mode only).")
manualShort  = input.bool(false,"Manual Short Arm (toggle to fire)",                           group=g_signal,   tooltip="Toggle this bool to arm a short trade on the next confirmed bar (Manual mode only).")

// ── Targets ─────────────────────────────────────────────────────────
slMult       = input.float(1.5, "SL ATR Multiplier",         minval=0.1, step=0.1,             group=g_targets,  tooltip="Stop distance from swing low/high in multiples of ATR(14).")
tp1Mult      = input.float(1.0, "TP1 Risk Multiplier",       minval=0.1, step=0.1,             group=g_targets,  tooltip="First target distance, in multiples of the initial risk (entry to stop). 1.0 = 1R.")
tp2Mult      = input.float(2.0, "TP2 Risk Multiplier",       minval=0.1, step=0.1,             group=g_targets,  tooltip="Second target distance, in multiples of the initial risk. 2.0 = 2R.")
tp3Mult      = input.float(3.5, "TP3 Risk Multiplier",       minval=0.1, step=0.1,             group=g_targets,  tooltip="Final target distance, in multiples of the initial risk. 3.5 = 3.5R.")
useBreakeven = input.bool(true, "Move SL to Breakeven after TP1",                              group=g_targets,  tooltip="If enabled, the working stop slides to entry the moment TP1 is reached.")
extendBars   = input.int(60,    "Line Extension (bars)",     minval=10,                        group=g_targets,  tooltip="How many bars to the right of the current bar the price ladder extends.")
maxTradeAge  = input.int(100,   "Max Trade Age (bars)",      minval=30,                        group=g_targets,  tooltip="Soft trade-age budget. TP/SL line alpha fades over the final 30 bars of this budget to visually telegraph time pressure.")

// ── Capital ─────────────────────────────────────────────────────────
capital      = input.float(10000.0, "Capital", step=100,                                       group=g_capital,  tooltip="Total trading capital. Risk amount = Capital * Risk % / 100.")
riskPct      = input.float(1.0, "Risk %",      minval=0.1, maxval=10, step=0.1,                group=g_capital,  tooltip="Percent of capital risked per trade. Drives the position size calculation.")
leverage     = input.int(1, "Leverage",        minval=1, maxval=125,                           group=g_capital,  tooltip="Leverage multiplier. Affects required margin and the leveraged PnL %.")
currency     = input.string("USD", "Currency",
     options=["USD","EUR","JPY","GBP","CHF","AUD","CAD","HKD","SGD","INR","BTC","ETH","USDT"], group=g_capital,  tooltip="Display-only currency code prefixed to monetary values in the dashboard.")

// ── Kelly ───────────────────────────────────────────────────────────
winRate      = input.float(0.5, "Assumed Win Rate (Kelly)",  minval=0.1, maxval=0.9, step=0.05, group=g_kelly,   tooltip="Assumed historical win rate used in the Kelly sizing suggestion. Output is capped at 25%.")

// ── Visual ──────────────────────────────────────────────────────────
bullColor       = input.color(#00ffbb, "Bullish", inline="cBull",                              group=g_visual,   tooltip="Primary bullish color — JOAT brand mint.")
bearColor       = input.color(#ff1100, "Bearish", inline="cBull",                              group=g_visual,   tooltip="Primary bearish color — JOAT brand red.")
entryLineColor  = input.color(#4da6ff, "Entry Line",      inline="cLine",                      group=g_visual,   tooltip="Color of the entry level line.")
slLineColor     = input.color(#ff4d6d, "Stop Loss Line",  inline="cLine",                      group=g_visual,   tooltip="Color of the stop loss line and the risk linefill.")
tpLineColor     = input.color(#00c88a, "Take Profit Line",inline="cLine",                      group=g_visual,   tooltip="Color of the TP1/TP2/TP3 lines and the reward linefill.")
showTint        = input.bool(true, "Tint Bars While Trade Open",                               group=g_visual,   tooltip="Subtle bgcolor tint on every bar while the active trade is open.")
showPulses      = input.bool(true, "Hit-Event Pulses",                                         group=g_visual,   tooltip="One-bar bgcolor flashes on TP1, TP2, TP3, SL and breakeven-slide events.")

// ── History & R-Zones ───────────────────────────────────────────────
showTradeHistory = input.bool(true, "Show Trade History Strip (last 15)",                      group=g_history,  tooltip="Draws a small label above each completed trade's entry bar showing direction, final R-multiple and outcome. FIFO-capped at 15.")
showRLevels      = input.bool(true, "Show R-Multiple Zones (0.5R – 3.0R)",                     group=g_history,  tooltip="While a trade is active, draws six faint dotted horizontal lines at 0.5R / 1.0R / 1.5R / 2.0R / 2.5R / 3.0R from entry in the trade direction, with right-edge price labels.")
showLiveR        = input.bool(true, "Show Live R / PnL Label",                                 group=g_history,  tooltip="Right-edge persistent label with current R-multiple, MFE, MAE and live PnL while a trade is open.")
showBarsLabel    = input.bool(true, "Show Bars-In-Trade Label",                                group=g_history,  tooltip="Persistent label anchored near the entry showing how many bars the active trade has been open.")
showWinRate      = input.bool(true, "Show Win-Rate Cluster (right edge)",                      group=g_history,  tooltip="Right-edge persistent label aggregating Win/Loss count, Win %, and average R-multiple across the trade history.")
showLast10R      = input.bool(true, "Show Last-10 R-Sum (right edge)",                         group=g_history,  tooltip="Right-edge persistent label summing the R-multiples of the most recent 10 completed trades.")
showSession      = input.bool(true, "Show Today's Trade Count (right edge)",                   group=g_history,  tooltip="Right-edge persistent label tracking trades activated and resolved during the current chart day. Resets on each new daily bar.")
showArming       = input.bool(true, "Show Manual Arming Preview",                              group=g_history,  tooltip="In Manual trigger mode, when a manual long/short toggle is true but the trade has not yet armed, shows a faint preview line and label at current price.")

// ── Dashboard ───────────────────────────────────────────────────────
showDash     = input.bool(true, "Show Dashboard",                                              group=g_dash,     tooltip="Toggle the institutional dashboard panel.")
dashPos      = input.string("top_right", "Dashboard Position",
     options=["top_right","top_center","top_left","middle_right","middle_center","middle_left","bottom_right","bottom_center","bottom_left"],
     group=g_dash, tooltip="Anchor the dashboard to any of the 9 chart positions.")
dashSize     = input.string("Medium", "Dashboard Size",
     options=["Tiny","Small","Medium","Large"],
     group=g_dash, tooltip="Cell text size for the dashboard.")

// ════════════════════════════════════════════════════════════════════
// HELPERS
// ════════════════════════════════════════════════════════════════════

// Map dashboard position string to native enum
posFromString(string s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

// Map dashboard size string to native enum
sizeFromString(string s) =>
    s == "Tiny"   ? size.tiny    :
     s == "Small" ? size.small   :
     s == "Large" ? size.large   :
     size.normal

// Currency code -> ASCII display prefix (no Unicode glyphs).
currencySym(string c) =>
    switch c
        "USD"  => "$"
        "EUR"  => "EUR "
        "JPY"  => "JPY "
        "GBP"  => "GBP "
        "CHF"  => "CHF "
        "AUD"  => "AUD "
        "CAD"  => "CAD "
        "HKD"  => "HKD "
        "SGD"  => "SGD "
        "INR"  => "INR "
        "BTC"  => "BTC "
        "ETH"  => "ETH "
        "USDT" => "USDT "
        => "$"

// Confirmed-bar gate. Every trigger and lifecycle transition is gated
// on this so the trade plan never flickers mid-bar.
confirmedBar = barstate.isconfirmed or barstate.ishistory

// FIFO trim helpers for typed drawing-object arrays.
fifoTrimLabels(array<label> a, int cap) =>
    while array.size(a) > cap
        label old = array.shift(a)
        label.delete(old)

fifoTrimLines(array<line> a, int cap) =>
    while array.size(a) > cap
        line old = array.shift(a)
        line.delete(old)

// ════════════════════════════════════════════════════════════════════
// SIGNAL / TRIGGER DETECTION
// ════════════════════════════════════════════════════════════════════
sigSma = ta.sma(sigSrc, sigSmaLen)

// Edge-detect manual toggles.
var bool prev_ml = false
var bool prev_ms = false

// CW10003: ta.* must run every bar — extract to top level, not inside ternaries.
bool srcCrossUp   = ta.crossover(sigSrc, sigSma)
bool srcCrossDown = ta.crossunder(sigSrc, sigSma)

armLong = triggerMode == "Manual" ? (manualLong  and not prev_ml) : triggerMode == "Source Above SMA" ? sigSrc > sigSma and not (sigSrc[1] > sigSma[1]) : triggerMode == "Source Cross Above SMA" ? srcCrossUp   : false
armShort = triggerMode == "Manual" ? (manualShort and not prev_ms) : triggerMode == "Source Above SMA" ? sigSrc < sigSma and not (sigSrc[1] < sigSma[1]) : triggerMode == "Source Cross Below SMA" ? srcCrossDown : false

prev_ml := manualLong
prev_ms := manualShort

// ════════════════════════════════════════════════════════════════════
// TRADE STATE
// ════════════════════════════════════════════════════════════════════
atr14 = ta.atr(14)

var int    tradeDir   = 0          // +1 long, -1 short, 0 flat
var float  entry      = na
var float  sl         = na         // initial stop (immutable for the life of the trade)
var float  tp1        = na
var float  tp2        = na
var float  tp3        = na
var int    tradeBar   = na         // bar index of trade arm
var float  currentSL  = na         // working stop (may slide to breakeven after TP1)
var bool   tp1Hit     = false
var bool   tp2Hit     = false
var bool   tp3Hit     = false
var bool   slHit      = false
var bool   beSlid     = false      // true after the breakeven slide fires
var float  riskAbs    = na         // |entry - sl| at arm time (anchored, used for R math)

// MFE / MAE per-trade running stats, expressed as R-multiples.
var float  mfeR       = 0.0
var float  maeR       = 0.0

// ── Arm a new trade on a confirmed trigger ──────────────────────────
if (armLong or armShort) and confirmedBar
    tradeDir  := armLong ? 1 : -1
    entry     := close
    sl        := tradeDir == 1 ? low  - atr14 * slMult : high + atr14 * slMult
    riskAbs   := math.abs(entry - sl)
    tp1       := entry + tradeDir * riskAbs * tp1Mult
    tp2       := entry + tradeDir * riskAbs * tp2Mult
    tp3       := entry + tradeDir * riskAbs * tp3Mult
    currentSL := sl
    tradeBar  := bar_index
    tp1Hit    := false
    tp2Hit    := false
    tp3Hit    := false
    slHit     := false
    beSlid    := false
    mfeR      := 0.0
    maeR      := 0.0

// ── Lifecycle: walk each bar through TP / SL hits ───────────────────
// Intrabar hits, TP3 takes priority over SL, arm bar excluded.
if not na(entry) and not (tp3Hit or slHit) and bar_index > nz(tradeBar, bar_index)
    if tradeDir == 1
        if high >= tp1 and not tp1Hit
            tp1Hit := true
            if useBreakeven
                currentSL := entry
                beSlid    := true
        if high >= tp2 and not tp2Hit
            tp2Hit := true
        if high >= tp3 and not tp3Hit
            tp3Hit := true
        if low <= currentSL and not tp3Hit
            slHit := true
    else if tradeDir == -1
        if low <= tp1 and not tp1Hit
            tp1Hit := true
            if useBreakeven
                currentSL := entry
                beSlid    := true
        if low <= tp2 and not tp2Hit
            tp2Hit := true
        if low <= tp3 and not tp3Hit
            tp3Hit := true
        if high >= currentSL and not tp3Hit
            slHit := true

tradeClosed = tp3Hit or slHit
in_position = not na(entry) and not tradeClosed

// ── Live R-multiple, MFE / MAE updates ──────────────────────────────
liveR = in_position and not na(entry) and riskAbs > 0 ? (close - entry) / riskAbs * tradeDir : 0.0
float favPx = in_position ? (tradeDir == 1 ? high : low ) : na
float advPx = in_position ? (tradeDir == 1 ? low  : high) : na
favR  = in_position and riskAbs > 0 ? (favPx - entry) / riskAbs * tradeDir : 0.0
advR  = in_position and riskAbs > 0 ? (advPx - entry) / riskAbs * tradeDir : 0.0

if in_position and confirmedBar
    if favR > mfeR
        mfeR := favR
    if advR < maeR
        maeR := advR

// ════════════════════════════════════════════════════════════════════
// POSITION SIZING + RISK MATH
// ════════════════════════════════════════════════════════════════════
sl_pct     = not na(entry) and entry != 0 ? math.abs(entry - sl) / entry * 100.0 : 0.0
tp1_pct    = not na(entry) and entry != 0 ? math.abs(tp1   - entry) / entry * 100.0 : 0.0
tp2_pct    = not na(entry) and entry != 0 ? math.abs(tp2   - entry) / entry * 100.0 : 0.0
tp3_pct    = not na(entry) and entry != 0 ? math.abs(tp3   - entry) / entry * 100.0 : 0.0

risk_amt   = capital * (riskPct / 100.0)
pos_size   = sl_pct > 0 ? risk_amt / (sl_pct / 100.0) : 0.0
req_margin = pos_size / leverage

current_rr = not na(entry) and math.abs(entry - sl) > 0 ? math.abs(tp3 - entry) / math.abs(entry - sl) : 0.0

// Kelly fraction f* = p - (1-p)/b, capped at 25%.
rrForKelly = math.max(current_rr, 0.5)
kellyF     = math.max(0.0, math.min(0.25, winRate - (1.0 - winRate) / rrForKelly))

// ── Live PnL (only meaningful while in position) ────────────────────
float raw_pnl_pct = in_position ? (close - entry) / entry * 100.0 * tradeDir : na
leveraged_pnl_pct = raw_pnl_pct * leverage
pnl_amt           = pos_size * (raw_pnl_pct / 100.0)

// ════════════════════════════════════════════════════════════════════
// SIGNAL ENGINE — derived booleans for alerts and visuals
// ════════════════════════════════════════════════════════════════════
activatedLong  = armLong  and confirmedBar
activatedShort = armShort and confirmedBar

t1HitBar    = tp1Hit  and not tp1Hit[1] and confirmedBar
t2HitBar    = tp2Hit  and not tp2Hit[1] and confirmedBar
t3HitBar    = tp3Hit  and not tp3Hit[1] and confirmedBar
slHitBar    = slHit   and not slHit[1]  and confirmedBar
beTriggered = beSlid  and not beSlid[1] and confirmedBar

// One-shot trade-close detector: fires the bar a trade resolves into
// WIN (tp3) or LOSS (sl). Used to push to history + counters.
tradeClosedEvent = t3HitBar or slHitBar

// ════════════════════════════════════════════════════════════════════
// AGGREGATE STATISTICS — fed by tradeClosedEvent
// ════════════════════════════════════════════════════════════════════
var array<float> rHistory = array.new<float>()
var int  totalWins   = 0
var int  totalLosses = 0

// Per-trade snapshot at close for the history label.
finalR = tp3Hit ? math.max(tp3Mult, 0.0) : (slHit and beSlid) ? 0.0 : slHit ? -1.0 : 0.0

if tradeClosedEvent
    array.push(rHistory, finalR)
    while array.size(rHistory) > 200
        array.shift(rHistory)
    if tp3Hit
        totalWins   += 1
    else if slHit and not beSlid
        totalLosses += 1
    // slHit-after-breakeven: partial, not counted as loss

// Aggregate stats: win rate %, avg R across history, last-10 R sum.
nHist     = array.size(rHistory)
sumR      = 0.0
if nHist > 0
    for i = 0 to nHist - 1
        sumR += array.get(rHistory, i)
avgR      = nHist > 0 ? sumR / nHist : 0.0

last10Sum = 0.0
last10N   = math.min(nHist, 10)
if last10N > 0
    for i = nHist - last10N to nHist - 1
        last10Sum += array.get(rHistory, i)

totalDecided = totalWins + totalLosses
winPct       = totalDecided > 0 ? totalWins / totalDecided * 100.0 : 0.0

// Daily session counters — reset on each new chart day.
var int dayLongs   = 0
var int dayShorts  = 0
var int dayWins    = 0
var int dayLosses  = 0
newDay = ta.change(time("D")) != 0
if newDay
    dayLongs   := 0
    dayShorts  := 0
    dayWins    := 0
    dayLosses  := 0
if activatedLong
    dayLongs   += 1
if activatedShort
    dayShorts  += 1
if tradeClosedEvent
    if tp3Hit
        dayWins   += 1
    else if slHit and not beSlid
        dayLosses += 1

// ════════════════════════════════════════════════════════════════════
// TIME-DECAY ALPHA — fade TP/SL lines as trade approaches maxTradeAge
// ════════════════════════════════════════════════════════════════════
barsInTrade = not na(tradeBar) ? bar_index - tradeBar : 0
decayStart  = math.max(maxTradeAge - 30, 1)

// Returns a fresh color with alpha boosted to telegraph time pressure.
fadeColor(color base, int baseAlpha) =>
    int   add = 0
    if in_position and barsInTrade > decayStart
        float t = math.min(1.0, (barsInTrade - decayStart) / 30.0)
        add := int(math.round(t * 40.0))
    color.new(base, math.min(95, baseAlpha + add))

// ════════════════════════════════════════════════════════════════════
// VISUALS — price ladder, labels, linefills
// ════════════════════════════════════════════════════════════════════
var line  l_entry  = na
var line  l_sl     = na
var line  l_tp1    = na
var line  l_tp2    = na
var line  l_tp3    = na
var label lb_entry = na
var label lb_sl    = na
var label lb_tp1   = na
var label lb_tp2   = na
var label lb_tp3   = na
var linefill lf_risk   = na
var linefill lf_reward = na

// R-multiple zone lines (0.5R .. 3.0R), FIFO-capped at 7.
var array<line>  rLevelLines  = array.new<line>()
var array<label> rLevelLabels = array.new<label>()

// Trade-history strip (one label per completed trade), FIFO-capped at 15.
var array<label> tradeHistory = array.new<label>()

// Live R / PnL persistent label (right edge, follows close).
var label currentRLabel = na
// Bars-in-trade persistent label (anchored at entry bar).
var label barsInTradeLbl = na
// Right-edge aggregate cluster labels.
var label winRateLbl = na
var label last10Lbl  = na
var label sessionLbl = na
// Manual arming preview line + label.
var line  armingLine  = na
var label armingLabel = na

// ── R-zone redraw helper: dotted line + label at each fractional R ──
drawRLevels(int x1, int x2) =>
    // Clear prior
    while array.size(rLevelLines) > 0
        line  old_l = array.pop(rLevelLines)
        line.delete(old_l)
    while array.size(rLevelLabels) > 0
        label old_b = array.pop(rLevelLabels)
        label.delete(old_b)
    if showRLevels and not na(entry) and riskAbs > 0
        float[] frac = array.from(0.5, 1.0, 1.5, 2.0, 2.5, 3.0)
        for i = 0 to array.size(frac) - 1
            float f   = array.get(frac, i)
            float px  = entry + tradeDir * riskAbs * f
            int   alp = int(math.round(70 - f * 8.0))   // darker as R grows
            color col = color.new(tpLineColor, math.max(40, math.min(85, alp)))
            line  rl  = line.new(x1, px, x2, px, color=col, width=1, style=line.style_dotted)
            array.push(rLevelLines, rl)
            string rtxt = str.tostring(f, "0.0") + "R " + str.tostring(px, format.mintick)
            label rb = label.new(x2, px, rtxt, style=label.style_label_left, color=color.new(#000000, 80), textcolor=col, size=size.tiny)
            array.push(rLevelLabels, rb)
        fifoTrimLines(rLevelLines, 7)
        fifoTrimLabels(rLevelLabels, 7)

// On every fresh arm: nuke the prior ladder + linefills and recreate.
if (armLong or armShort) and confirmedBar
    line.delete(l_entry)
    line.delete(l_sl)
    line.delete(l_tp1)
    line.delete(l_tp2)
    line.delete(l_tp3)
    label.delete(lb_entry)
    label.delete(lb_sl)
    label.delete(lb_tp1)
    label.delete(lb_tp2)
    label.delete(lb_tp3)
    linefill.delete(lf_risk)
    linefill.delete(lf_reward)

    int x1     = bar_index
    int x2     = bar_index + extendBars
    color cTP1 = color.new(tpLineColor, 35)
    color cTP2 = color.new(tpLineColor, 20)
    color cTP3 = tpLineColor
    color cSL  = slLineColor
    color cEN  = entryLineColor

    l_entry := line.new(x1, entry,     x2, entry,     color=cEN,  width=3, style=line.style_solid)
    l_sl    := line.new(x1, currentSL, x2, currentSL, color=cSL,  width=4, style=line.style_solid)
    l_tp1   := line.new(x1, tp1,       x2, tp1,       color=cTP1, width=4, style=line.style_solid)
    l_tp2   := line.new(x1, tp2,       x2, tp2,       color=cTP2, width=4, style=line.style_solid)
    l_tp3   := line.new(x1, tp3,       x2, tp3,       color=cTP3, width=4, style=line.style_solid)

    lf_risk   := linefill.new(l_entry, l_sl,  color.new(slLineColor, 90))
    lf_reward := linefill.new(l_entry, l_tp3, color.new(tpLineColor, 90))

    string entryTxt = "ENTRY " + str.tostring(entry, format.mintick)
    string slTxt    = "SL "    + str.tostring(currentSL, format.mintick) + "  (-" + str.tostring(sl_pct,  "0.00") + "%)"
    string tp1Txt   = "TP1 "   + str.tostring(tp1, format.mintick)       + "  (+" + str.tostring(tp1_pct, "0.00") + "% / " + str.tostring(tp1Mult, "0.0") + "R)"
    string tp2Txt   = "TP2 "   + str.tostring(tp2, format.mintick)       + "  (+" + str.tostring(tp2_pct, "0.00") + "% / " + str.tostring(tp2Mult, "0.0") + "R)"
    string tp3Txt   = "TP3 "   + str.tostring(tp3, format.mintick)       + "  (+" + str.tostring(tp3_pct, "0.00") + "% / " + str.tostring(tp3Mult, "0.0") + "R)"

    lb_entry := label.new(x2, entry,     entryTxt, style=label.style_label_left, color=cEN,  textcolor=color.white, size=size.small)
    lb_sl    := label.new(x2, currentSL, slTxt,    style=label.style_label_left, color=cSL,  textcolor=color.white, size=size.small)
    lb_tp1   := label.new(x2, tp1,       tp1Txt,   style=label.style_label_left, color=cTP1, textcolor=color.white, size=size.small)
    lb_tp2   := label.new(x2, tp2,       tp2Txt,   style=label.style_label_left, color=cTP2, textcolor=color.white, size=size.small)
    lb_tp3   := label.new(x2, tp3,       tp3Txt,   style=label.style_label_left, color=cTP3, textcolor=color.white, size=size.small)

    // R-zone lines for this trade.
    drawRLevels(x1, x2)
    // Bars-in-trade anchor — placed at entry bar, offset above by 0.5*ATR.
    if not na(barsInTradeLbl)
        label.delete(barsInTradeLbl)
        barsInTradeLbl := na
    if showBarsLabel
        float lblY = entry + (tradeDir == 1 ? -atr14 * 0.5 : atr14 * 0.5)
        barsInTradeLbl := label.new(x1, lblY, "0 bars open", style=label.style_label_right, color=color.new(#000000, 70), textcolor=#e2e2f0, size=size.tiny)
    // Any arming preview is now obsolete — clear inline (Pine v6 forbids modifying globals from inside a function).
    line.delete(armingLine)
    armingLine := na
    label.delete(armingLabel)
    armingLabel := na

// Trail the ladder's right edge and refresh SL line on breakeven slide.
if in_position and not (armLong or armShort)
    int rx = bar_index + extendBars
    line.set_x2(l_entry, rx)
    label.set_x(lb_entry, rx)
    line.set_x2(l_sl, rx)
    label.set_x(lb_sl, rx)
    line.set_x2(l_tp1, rx)
    label.set_x(lb_tp1, rx)
    line.set_x2(l_tp2, rx)
    label.set_x(lb_tp2, rx)
    line.set_x2(l_tp3, rx)
    label.set_x(lb_tp3, rx)
    // Time-decay alpha on TP/SL lines (entry stays full-strength).
    line.set_color(l_sl,  fadeColor(slLineColor, 0))
    line.set_color(l_tp1, fadeColor(tpLineColor, 35))
    line.set_color(l_tp2, fadeColor(tpLineColor, 20))
    line.set_color(l_tp3, fadeColor(tpLineColor, 0))
    // Reflect a breakeven slide on the SL line + label immediately.
    if beSlid
        line.set_y1(l_sl, currentSL)
        line.set_y2(l_sl, currentSL)
        label.set_y(lb_sl, currentSL)
        label.set_text(lb_sl, "SL " + str.tostring(currentSL, format.mintick) + "  (breakeven)")
    // Right-edge anchor for the R-zone label set.
    if showRLevels and array.size(rLevelLabels) > 0
        for i = 0 to array.size(rLevelLabels) - 1
            label.set_x(array.get(rLevelLabels, i), rx)
            line.set_x2(array.get(rLevelLines, i), rx)

// ── Bar-tint while in position + 1-bar hit pulses ───────────────────
tintCol  = in_position and showTint ? color.new(tradeDir == 1 ? bullColor : bearColor, 96) : na
pulseT1  = showPulses and t1HitBar    ? color.new(tpLineColor, 70) : na
pulseT2  = showPulses and t2HitBar    ? color.new(tpLineColor, 60) : na
pulseT3  = showPulses and t3HitBar    ? color.new(tpLineColor, 45) : na
pulseSL  = showPulses and slHitBar    ? color.new(slLineColor, 55) : na
pulseBE  = showPulses and beTriggered ? color.new(entryLineColor, 75) : na

bgcolor(tintCol, title="Trade Open Tint")
bgcolor(pulseT1, title="TP1 Pulse")
bgcolor(pulseT2, title="TP2 Pulse")
bgcolor(pulseT3, title="TP3 Pulse")
bgcolor(pulseSL, title="SL Pulse")
bgcolor(pulseBE, title="Breakeven Pulse")

// ════════════════════════════════════════════════════════════════════
// LIVE R / PNL LABEL  (right-edge, follows close while in position)
// ════════════════════════════════════════════════════════════════════
if showLiveR and confirmedBar
    if in_position
        if na(currentRLabel)
            currentRLabel := label.new(bar_index + 30, close, "", style=label.style_label_left, color=color.new(#000000, 60), textcolor=color.white, size=size.small)
        string rSign     = liveR >= 0 ? "+" : ""
        string mfeSign   = mfeR  >= 0 ? "+" : ""
        string maeSign   = maeR  >= 0 ? "+" : ""
        string pnlSign   = not na(pnl_amt) and pnl_amt >= 0 ? "+" : "-"
        string pnlStr    = not na(pnl_amt) ? currencySym(currency) + str.format("{0,number,#,###.0}", math.abs(pnl_amt)) : "—"
        string txt = "R " + rSign + str.tostring(liveR, "0.00") + "   MFE " + mfeSign + str.tostring(mfeR, "0.00") + "   MAE " + maeSign + str.tostring(maeR, "0.00") + "   PnL " + pnlSign + pnlStr
        label.set_xy(currentRLabel, bar_index + 30, close)
        label.set_text(currentRLabel, txt)
        label.set_textcolor(currentRLabel, liveR >= 0 ? tpLineColor : slLineColor)
    else
        if not na(currentRLabel)
            label.delete(currentRLabel)
            currentRLabel := na

// ════════════════════════════════════════════════════════════════════
// BARS-IN-TRADE LABEL  (anchored near entry, updates each bar)
// ════════════════════════════════════════════════════════════════════
if showBarsLabel and confirmedBar
    if in_position and not na(barsInTradeLbl)
        label.set_text(barsInTradeLbl, str.tostring(barsInTrade) + " bars open")
    else if not in_position and not na(barsInTradeLbl)
        label.delete(barsInTradeLbl)
        barsInTradeLbl := na

// ════════════════════════════════════════════════════════════════════
// TRADE-HISTORY STRIP  (one label per closed trade, FIFO 15)
// ════════════════════════════════════════════════════════════════════
if showTradeHistory and tradeClosedEvent
    string dirCode = tradeDir == 1 ? "L" : "S"
    string sign    = finalR >= 0 ? "+" : ""
    string outcome = tp3Hit ? "WIN" : (slHit and beSlid) ? "partial" : "LOSS"
    string txt     = dirCode + "  " + sign + str.tostring(finalR, "0.0") + "R  " + outcome + "   MFE+" + str.tostring(mfeR, "0.0") + "  MAE" + (maeR >= 0 ? "+" : "") + str.tostring(maeR, "0.0")
    color  bg      = tp3Hit ? color.new(tpLineColor, 60) : (slHit and beSlid) ? color.new(entryLineColor, 65) : color.new(slLineColor, 60)
    float  ay      = tradeDir == 1 ? high + atr14 * 1.5 : low - atr14 * 1.5
    int    ax      = nz(tradeBar, bar_index)
    label hb = label.new(ax, ay, txt, style=tradeDir == 1 ? label.style_label_down : label.style_label_up, color=bg, textcolor=color.white, size=size.tiny)
    array.push(tradeHistory, hb)
    fifoTrimLabels(tradeHistory, 15)

// ════════════════════════════════════════════════════════════════════
// RIGHT-EDGE CLUSTER — win-rate, last 10R, session count
// ════════════════════════════════════════════════════════════════════
if barstate.islast
    if showWinRate
        if na(winRateLbl)
            winRateLbl := label.new(bar_index + 30, high * 1.02, "", style=label.style_label_left, color=color.new(#000000, 65), textcolor=color.white, size=size.small)
        string wlStr  = "W/L " + str.tostring(totalWins) + "/" + str.tostring(totalLosses)
        string wpStr  = "Win% " + str.tostring(winPct, "0.0")
        string avgStr = "Avg R " + (avgR >= 0 ? "+" : "") + str.tostring(avgR, "0.00")
        label.set_xy(winRateLbl, bar_index + 30, high * 1.02)
        label.set_text(winRateLbl, wlStr + "   " + wpStr + "   " + avgStr)
        label.set_textcolor(winRateLbl, avgR >= 0 ? tpLineColor : slLineColor)
    else if not na(winRateLbl)
        label.delete(winRateLbl)
        winRateLbl := na

    if showLast10R
        if na(last10Lbl)
            last10Lbl := label.new(bar_index + 35, high * 1.04, "", style=label.style_label_left, color=color.new(#000000, 65), textcolor=color.white, size=size.small)
        string l10 = "Last " + str.tostring(last10N) + "R: " + (last10Sum >= 0 ? "+" : "") + str.tostring(last10Sum, "0.0")
        label.set_xy(last10Lbl, bar_index + 35, high * 1.04)
        label.set_text(last10Lbl, l10)
        label.set_textcolor(last10Lbl, last10Sum >= 0 ? tpLineColor : slLineColor)
    else if not na(last10Lbl)
        label.delete(last10Lbl)
        last10Lbl := na

    if showSession
        if na(sessionLbl)
            sessionLbl := label.new(bar_index + 30, high * 1.06, "", style=label.style_label_left, color=color.new(#000000, 65), textcolor=color.white, size=size.small)
        int totalToday = dayLongs + dayShorts
        string sTxt = "Today: " + str.tostring(totalToday) + " trades   " + str.tostring(dayWins) + "W " + str.tostring(dayLosses) + "L"
        label.set_xy(sessionLbl, bar_index + 30, high * 1.06)
        label.set_text(sessionLbl, sTxt)
        label.set_textcolor(sessionLbl, dayWins >= dayLosses ? tpLineColor : slLineColor)
    else if not na(sessionLbl)
        label.delete(sessionLbl)
        sessionLbl := na

// ════════════════════════════════════════════════════════════════════
// MANUAL ARMING PREVIEW — only in Manual mode, pre-confirmation
// ════════════════════════════════════════════════════════════════════
armingPending = triggerMode == "Manual" and (manualLong or manualShort) and not in_position and not (armLong or armShort)
if showArming and confirmedBar
    if armingPending
        string side = manualLong ? "bull" : "bear"
        color  acol = manualLong ? bullColor : bearColor
        if na(armingLine)
            armingLine := line.new(bar_index, close, bar_index + extendBars, close, color=color.new(acol, 65), width=1, style=line.style_dashed)
            armingLabel := label.new(bar_index + extendBars, close, "ARMED " + side + "   next bar", style=label.style_label_left, color=color.new(#000000, 65), textcolor=acol, size=size.small)
        else
            line.set_xy1(armingLine,  bar_index, close)
            line.set_xy2(armingLine,  bar_index + extendBars, close)
            line.set_color(armingLine, color.new(acol, 65))
            label.set_xy(armingLabel, bar_index + extendBars, close)
            label.set_text(armingLabel, "ARMED " + side + "   next bar")
            label.set_textcolor(armingLabel, acol)
    else
        line.delete(armingLine)
        armingLine := na
        label.delete(armingLabel)
        armingLabel := na

// ════════════════════════════════════════════════════════════════════
// DASHBOARD
// ════════════════════════════════════════════════════════════════════
var color c_bg     = #111118
var color c_frame  = #252535
var color c_label  = #9090b0
var color c_text   = #e2e2f0
var color c_accent = #4da6ff

var table T = table.new(posFromString(dashPos), 2, 17, bgcolor=c_bg, border_width=1, border_color=c_frame, frame_width=1, frame_color=c_frame)

if showDash and barstate.islast
    cellSize = sizeFromString(dashSize)
    string sym = currencySym(currency)

    // Row 0 — header (merged)
    table.cell(T, 0, 0, "Position Architect [JOAT]", text_color=color.white, text_size=cellSize, text_halign=text.align_center, bgcolor=color.new(c_accent, 70))
    table.merge_cells(T, 0, 0, 1, 0)

    // Row 1 — Capital
    table.cell(T, 0, 1, "Capital", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 1, sym + str.format("{0,number,#,###}", capital), text_color=c_text, text_size=cellSize, text_halign=text.align_right)

    // Row 2 — Risk %
    table.cell(T, 0, 2, "Risk %", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 2, str.tostring(riskPct, "0.0") + "%  (" + sym + str.format("{0,number,#,###.0}", risk_amt) + ")", text_color=slLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 3 — Leverage
    table.cell(T, 0, 3, "Leverage", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 3, "x" + str.tostring(leverage), text_color=entryLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 4 — Stop Loss
    table.cell(T, 0, 4, "Stop Loss", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 4, sl_pct > 0 ? str.tostring(sl_pct, "0.00") + "%" : "—", text_color=slLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 5 — Current R:R
    table.cell(T, 0, 5, "Current R:R", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 5, current_rr > 0 ? "1 : " + str.tostring(current_rr, "0.0") : "—", text_color=tpLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 6 — Kelly Suggest
    table.cell(T, 0, 6, "Kelly Suggest", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 6, str.tostring(kellyF * 100.0, "0.0") + "%", text_color=tpLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 7 — Position Size
    table.cell(T, 0, 7, "Position Size", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 7, pos_size > 0 ? str.format("{0,number,#,###.0}", pos_size) : "—", text_color=tpLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 8 — Required Margin
    table.cell(T, 0, 8, "Required Margin", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 8, req_margin > 0 ? sym + str.format("{0,number,#,###.0}", req_margin) : "—", text_color=entryLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 9 — Direction (tinted)
    string dirTxt = tradeDir == 1 ? "LONG" : tradeDir == -1 ? "SHORT" : "—"
    color  dirBg  = tradeDir == 1 ? color.new(bullColor, 70) : tradeDir == -1 ? color.new(bearColor, 70) : color.new(c_frame, 0)
    table.cell(T, 0, 9, "Direction", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 9, dirTxt, text_color=color.white, text_size=cellSize, text_halign=text.align_right, bgcolor=dirBg)

    // Row 10 — Entry
    table.cell(T, 0, 10, "Entry", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 10, not na(entry) ? str.tostring(entry, format.mintick) : "—", text_color=entryLineColor, text_size=cellSize, text_halign=text.align_right)

    // Row 11 — Current
    table.cell(T, 0, 11, "Current", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 11, str.tostring(close, format.mintick), text_color=c_text, text_size=cellSize, text_halign=text.align_right)

    // Row 12 — PnL %
    string pnlPctStr = in_position and not na(leveraged_pnl_pct) ? (leveraged_pnl_pct >= 0 ? "+" : "") + str.tostring(leveraged_pnl_pct, "0.00") + "%" : "—"
    color  pnlPctCl  = in_position and not na(leveraged_pnl_pct) ? (leveraged_pnl_pct >= 0 ? tpLineColor : slLineColor) : c_text
    table.cell(T, 0, 12, "PnL %  (x" + str.tostring(leverage) + ")", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 12, pnlPctStr, text_color=pnlPctCl, text_size=cellSize, text_halign=text.align_right)

    // Row 13 — PnL
    string pnlAmtStr = in_position and not na(pnl_amt) ? (pnl_amt >= 0 ? "+" : "-") + sym + str.format("{0,number,#,###.0}", math.abs(pnl_amt)) : "—"
    color  pnlAmtCl  = in_position and not na(pnl_amt) ? (pnl_amt >= 0 ? tpLineColor : slLineColor) : c_text
    table.cell(T, 0, 13, "PnL", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 13, pnlAmtStr, text_color=pnlAmtCl, text_size=cellSize, text_halign=text.align_right)

    // Row 14 — Status (tinted)
    string statusTxt = na(entry) ? "—" : tradeClosed and tp3Hit ? "WIN" : tradeClosed and slHit ? "LOSS" : "OPEN"
    color statusBg = na(entry) ? color.new(c_frame, 0) : tradeClosed and tp3Hit ? color.new(tpLineColor, 60) : tradeClosed and slHit ? color.new(slLineColor, 60) : color.new(entryLineColor, 70)
    table.cell(T, 0, 14, "Status", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 14, statusTxt, text_color=color.white, text_size=cellSize, text_halign=text.align_right, bgcolor=statusBg)

    // Row 15 — Bars in Trade
    table.cell(T, 0, 15, "Bars in Trade", text_color=c_label, text_size=cellSize, text_halign=text.align_left)
    table.cell(T, 1, 15, not na(tradeBar) ? str.tostring(bar_index - tradeBar) : "—", text_color=c_text, text_size=cellSize, text_halign=text.align_right)

    // Row 16 — Watermark (merged)
    table.cell(T, 0, 16, "JOAT — Position Architect", text_color=color.new(c_label, 50), text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(T, 0, 16, 1, 16)

// ════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════
alertcondition(activatedLong,  title="PSA Trade Activated Long",  message="Position Architect [JOAT] — Long trade activated")
alertcondition(activatedShort, title="PSA Trade Activated Short", message="Position Architect [JOAT] — Short trade activated")
alertcondition(t1HitBar,       title="PSA TP1 Hit",               message="Position Architect [JOAT] — TP1 reached")
alertcondition(t2HitBar,       title="PSA TP2 Hit",               message="Position Architect [JOAT] — TP2 reached")
alertcondition(t3HitBar,       title="PSA TP3 Hit",               message="Position Architect [JOAT] — TP3 reached (trade closed win)")
alertcondition(slHitBar,       title="PSA Stop Loss Hit",         message="Position Architect [JOAT] — Stop loss triggered")
alertcondition(beTriggered,    title="PSA Breakeven Slid",        message="Position Architect [JOAT] — Stop loss moved to breakeven")
````
