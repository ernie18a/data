# Oscillator MTF Fan RSI STOCH

- url: https://www.tradingview.com/script/IQNuE2je-Oscillator-MTF-Fan-RSI-STOCH/
- type: indicator
- pine_id: PUB;ed61c2d5dde14a5f970cb39abca504ff
- version: 1.0

## Description

Osc Fan plots three momentum legs (fast / mid / slow) on one timeframe you choose and shows the same fan across a multi-timeframe ladder in a compact dashboard. It is built to show where the legs DISAGREE, not to stack confirmations.

ENGINES
RSI: lengths 7 / 14 / 21, each compared to ONE shared, fixed EMA(9) signal.
Stoch: lengths 9 / 21 / 34 smoothed %K, each compared to its own %D. %K and %D smoothing are shared and fixed across the three legs.
Each leg is colored by its own state: above its signal = up, below = down. It is a momentum-state fan, so a green leg is above its signal, not necessarily rising. The signal is deliberately not scaled with length. A scaled stack (for example 15/3, 30/6, 45/9) draws the same curve at three zoom levels, while a fixed signal keeps the legs structurally different. Each engine keeps its own lengths, so switching between RSI and Stoch overwrites nothing.

THE PLOTTED FAN
The "Fan timeframe" input sets which timeframe is plotted in the pane (blank = chart timeframe). If you pick a timeframe below the chart's, the fan falls back to the chart timeframe and the dashboard marks it with *.

DASHBOARD
Columns: TF | F M S | FAN | AGR. One row per ladder timeframe (10 / 39 / 78 / 130 / D / W / M, with 78 and M off by default), each calculated in that timeframe's own bars. Timeframes below the chart's are skipped. The row matching the plotted fan is marked ▸.
F M S: value plus a state arrow. Under Stoch, a marker appears when %K is past overbought or oversold. The color still reflects K vs D, because strong trends can stay overbought.
FAN: ALL▲, ALL▼, or SPLIT (not unanimous).
AGR: how often the fast and slow legs agree over a lookback, counted only on bars where both are directional. The default κ mode is Cohen's kappa, which measures agreement beyond what each leg's own up/down tendency would produce, so a long trend that keeps both legs up does not inflate it. High κ means the slow leg flips on the same bars as the fast leg and adds no timing of its own. % mode shows raw agreement.
There is intentionally no "N of 7 aligned" score. Timeframes of one calculation are not independent votes; read the rows for disagreement and for which timeframe turned first.

LEVELS
RSI variance shrinks as length grows, so a fixed 30/70 means something different on each leg; under RSI only the 50 midline is drawn. Stoch range position is the same at every length, so overbought/oversold lines are drawn under Stoch.

REPAINTING
Higher timeframes are requested with lookahead off and no offset. On the live bar, higher-timeframe rows and a higher-timeframe plotted fan show the DEVELOPING higher-timeframe bar, which can change until it closes. After a reload, history shows closed-bar values only. This is live multi-timeframe data, not a non-repainting indicator.

ALERTS
Alerts cover the plotted fan only and fire once per event.
Live: uses the developing bar. Earliest, but can fire on a state that does not survive the close.
Confirmed: uses the last closed bar. Cannot be withdrawn, and arrives on the first tick after the close.
For a single alert, set "Alert mode" (Live, Confirmed or Both) and create an alert on "Any alert() function call". Six named conditions (Up, Down, Split × Live, Confirmed) are also available for separate alerts.

This indicator describes momentum state. It does not predict price and is not a trading system on its own.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// OSC FAN v1.10 — RSI or Stoch fan in the lower pane, plotted on ONE selected timeframe,
//                 plus a compact MTF ladder dashboard of the same fan
// ══════════════════════════════════════════════════════════
// v1.10 CHANGES:
//   [CHG] Ladder gains a 7th rung, Monthly. 78 and M are unchecked by default, so the default
//         dash is 10 / 39 / 130 / D / W; tick either "row" box to bring it back.
//   [CHG] The three fan lines no longer put value labels on the price scale. They still show
//         in the status line and data window.
//
// v1.9 CHANGES (third external review):
//   [CHG] The dash table is only created when "Show MTF dash" is on. The review's diagnosis
//         was off — changing an input re-runs the script from bar 0, so a hidden dash was
//         never a stale populated table — but an empty table could still draw its frame.
//         Not creating it removes that.
//   [DOC] κ tooltip says what "redundant" means: the slow leg flips on the same bars as the
//         fast leg. A slow leg with a useful timing lag cannot read high κ — the lag bars are
//         disagreement bars — so high κ is specifically "no timing information of its own".
//
// v1.8 CHANGES (second external review):
//   [NEW] One-alert setup. An "Alert mode" input (Live / Confirmed / Both) drives alert()
//         calls, so a single TradingView alert on "Any alert() function call" covers every
//         fan transition in the chosen mode. Messages carry ticker, fan timeframe, engine and
//         mode. Same rising-edge logic as the named conditions, frequency once per bar. The six
//         named alertconditions are unchanged for anyone who wants per-condition alerts.
//
// v1.7 CHANGES (external review + one bug the review missed):
//   [FIX] Alert spam on HTF fans. The transition flags are one-bar pulses in HTF bar-time, but
//         a request.security value is HELD across every chart bar inside the HTF bar — so with
//         the fan on 78 and the chart on 5, "Fan Unanimous Up" was true on many consecutive
//         chart bars and fired on each one. Alerts now fire on the chart-side RISING EDGE of
//         the flag: once per event.
//   [NEW] Live and Confirmed alert sets (pick in the alert dialog, frequency "Once Per Bar"):
//           Live      — developing HTF bar. Earliest, but can fire on a state that does not
//                       survive the HTF close.
//           Confirmed — the transition of the last CLOSED HTF bar, read on the bar after it.
//                       Cannot un-fire; arrives on the first tick after the HTF close.
//         With the fan on the chart timeframe, Live + "Once Per Bar Close" is already
//         confirmed and a bar earlier than the Confirmed set.
//   [CHG] AGR is chance-corrected by default (κ, Cohen's kappa). Raw agreement % mixes two
//         things: the legs making the same decision, and the market trending — in a trend both
//         legs sit "up" most of the window and agree by base rate alone. κ = (observed −
//         expected) / (1 − expected), with "expected" built from each leg's own up/down rates
//         in the window. κ ≈ 0 = agreement is what those base rates alone produce; κ near 1 =
//         the slow leg tracks the fast leg bar-for-bar beyond that, which is the actual
//         redundancy reading. "%" mode keeps the raw number, now neutral-colored (high raw
//         agreement in a trend is not an alarm). Both now count only bars where both legs are
//         directional, so warmup and on-signal ties no longer bias the number low.
//   [CHG] A fan timeframe below the chart timeframe falls back to the chart timeframe (same
//         rule as the ladder). The ▸ row shows * with a tooltip when that happens.
//   [DOC] SPLIT = not unanimous (also covers a leg sitting exactly on its signal).
//   [KEPT] bar_index warmup guard alongside the na checks, and both engines computed on every
//         bar. The review flagged these as redundant / costly; both are deliberate (belt-and-
//         braces warmup; unbroken ta.* history across engine toggles).
//
// LAYOUT
//   • The PANE plots the fan for the "Fan timeframe" input (blank = chart). That is the fan.
//   • The DASH shows the same fan on a shared ladder (10 / 39 / 78 / 130 / D / W / M, with 78
//     and M unchecked by default), one row per rung, built the same way as the MTF Regime dashes: per-row toggles, rungs
//     below the chart timeframe skipped, value+arrow cells.
//   • The dash row that matches the plotted timeframe is marked ▸. If the plotted timeframe
//     is not on the ladder, it gets its own ▸ row at the top.
//
// ENGINES (toggle — each keeps its own lengths)
//   RSI   : 7 / 14 / 21, each leg colored by its cross of a SHARED, FIXED signal EMA (9).
//   Stoch : 9 / 21 / 34 smoothed %K, each leg colored by %K vs its own %D. %K and %D
//           smoothing are shared and fixed across the legs — they do NOT scale with length.
//   Both are momentum-STATE fans: a green leg is above its signal, not necessarily rising.
//   Stoch value cells carry an extremity marker above overbought / below oversold ("94↑•");
//   the arrow and color stay K-vs-D, the marker only flags range location.
//
// DASH COLUMNS:  TF | F M S (value + arrow) | FAN | AGR
//     FAN  = ALL▲ / ALL▼ / SPLIT (not unanimous)
//     AGR  = fast/slow agreement over the lookback, κ (default) or raw %. See v1.7 note.
//   No aggregate "N of 6 aligned" column: stacked timeframes of one calc are the same
//   redundancy as stacked lengths. Read rows for disagreement, not a vote count.
//
// BANDS: RSI variance shrinks with length, so 30/70 means different things per leg — only
// the 50 midline is drawn. Stoch range position is length-invariant, so OB/OS lines are
// drawn under the Stoch engine.
//
// LIVE HTF MODE: lookahead_off, no offset. HTF rows and an HTF plotted fan show the
// DEVELOPING HTF bar on the realtime edge and can change until it closes; after a reload the
// history shows only the closed-bar state. This is live-developing MTF, not non-repainting
// MTF. Live alerts inherit it; Confirmed alerts do not.
//
// History: v1.6 LEAD/BARS removed; v1.5 engine toggle with per-engine lengths, Regime-style
// ladder dash, ▸ row; v1.3 AGR; v1.2 transitions inside the bundle; v1.1 explicit
// request.security instead of timeframe="" (CE10080).
// ══════════════════════════════════════════════════════════

indicator(title = "Osc Fan", shorttitle = "OscFan", overlay = false)

// ══════════════════════════════════════
// INPUTS
// ══════════════════════════════════════
GRP_ENG  = "Fan"
GRP_RSI  = "RSI fan"
GRP_STO  = "Stoch fan"
GRP_LAD  = "MTF dash — ladder"
GRP_DASH = "MTF dash — display"
GRP_ALRT = "Alerts"
GRP_STY  = "Style"

engine  = input.string("RSI", "Oscillator", options = ["RSI", "Stoch"], group = GRP_ENG, tooltip = "Which fan is plotted AND which fan the dash shows. Each engine keeps its own lengths below, so toggling doesn't overwrite anything.")
isStoch = engine == "Stoch"
tfIn    = input.timeframe("", "Fan timeframe (plotted)", group = GRP_ENG, tooltip = "Blank = chart timeframe. Must be at or above the chart timeframe — if it's lower, the fan falls back to the chart timeframe and the ▸ row shows *. On an HTF the lines step (constant across the chart bars inside each HTF bar), warmup is in HTF bars, and the realtime edge shows the DEVELOPING HTF bar.")

rSrc  = input.source(close, "Source", group = GRP_RSI)
rLenF = input.int(7,  "Fast", minval = 2, maxval = 200, inline = "rl", group = GRP_RSI)
rLenM = input.int(14, "Mid",  minval = 2, maxval = 200, inline = "rl", group = GRP_RSI)
rLenS = input.int(21, "Slow", minval = 2, maxval = 200, inline = "rl", group = GRP_RSI)
rEma  = input.int(9, "Signal EMA (shared, fixed)", minval = 1, maxval = 100, group = GRP_RSI, tooltip = "Shared and fixed across all three RSI legs. Scaling it with length would make the legs proportionally identical — three zoom levels of one curve.")

kLenF   = input.int(9,  "Fast %K", minval = 2, maxval = 200, inline = "kl", group = GRP_STO)
kLenM   = input.int(21, "Mid %K",  minval = 2, maxval = 200, inline = "kl", group = GRP_STO)
kLenS   = input.int(34, "Slow %K", minval = 2, maxval = 200, inline = "kl", group = GRP_STO)
kSmooth = input.int(3, "%K smoothing", minval = 1, maxval = 50, inline = "ks", group = GRP_STO)
dSmooth = input.int(3, "%D smoothing", minval = 1, maxval = 50, inline = "ks", group = GRP_STO, tooltip = "Both smoothings are shared and fixed across the three legs. Each leg's state = its %K above / below its own %D.")
obLvl   = input.float(80, "Overbought", minval = 50, maxval = 100, step = 1, inline = "ob", group = GRP_STO)
osLvl   = input.float(20, "Oversold",   minval = 0,  maxval = 50,  step = 1, inline = "ob", group = GRP_STO)
extMark = input.string("•", "Extremity marker", options = ["•", "!", "*", "▪"], group = GRP_STO, tooltip = "Appended to a Stoch value in the dash when %K is above overbought or below oversold. Color still means K vs D — strong trends stay overbought, so the color is not reversed.")

tf1 = input.timeframe("10",  "Timeframe 1", inline = "L1", group = GRP_LAD)
sh1 = input.bool(true, "row", inline = "L1", group = GRP_LAD)
tf2 = input.timeframe("39",  "Timeframe 2", inline = "L2", group = GRP_LAD)
sh2 = input.bool(true, "row", inline = "L2", group = GRP_LAD)
tf3 = input.timeframe("78",  "Timeframe 3", inline = "L3", group = GRP_LAD)
sh3 = input.bool(false, "row", inline = "L3", group = GRP_LAD)
tf4 = input.timeframe("130", "Timeframe 4", inline = "L4", group = GRP_LAD)
sh4 = input.bool(true, "row", inline = "L4", group = GRP_LAD)
tf5 = input.timeframe("D",   "Timeframe 5", inline = "L5", group = GRP_LAD)
sh5 = input.bool(true, "row", inline = "L5", group = GRP_LAD)
tf6 = input.timeframe("W",   "Timeframe 6", inline = "L6", group = GRP_LAD)
sh6 = input.bool(true, "row", inline = "L6", group = GRP_LAD)
tf7 = input.timeframe("M",   "Timeframe 7", inline = "L7", group = GRP_LAD)
sh7 = input.bool(false, "row", inline = "L7", group = GRP_LAD)

showDash = input.bool(true, "Show MTF dash", group = GRP_DASH)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group = GRP_DASH)
dashFont = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = GRP_DASH, tooltip = "Lower panes are short — if rows get clipped, switch to Tiny or drag the pane taller.")
showAgr  = input.bool(true, "Show AGR column", group = GRP_DASH)
agrMode  = input.string("κ", "AGR units", options = ["κ", "%"], group = GRP_DASH, tooltip = "Fast/slow agreement over the lookback, counted only on bars where both legs are directional. κ = chance-corrected (Cohen's kappa): agreement beyond what each leg's own up/down rates would produce by themselves, so a trend that keeps both legs 'up' does not inflate it. κ ≈ 0 = no agreement beyond base rates; near 1 = the slow leg flips on the same bars as the fast leg, so it adds no timing information of its own (redundant). A slow leg that lags usefully can't read high κ: the lag bars count as disagreement. '—' when either leg barely changed state in the window — there is nothing to agree about. % = raw agreement, neutral-colored: high raw agreement in a trend is coherence, not a problem.")
agrLen   = input.int(100, "AGR lookback (bars)", minval = 20, maxval = 500, group = GRP_DASH, tooltip = "In each row's own bars. Needs at least half the lookback to be directional bars before a value prints.")
kapHi    = input.float(0.8, "κ highlight ≥", minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_DASH, tooltip = "κ at or above this renders amber: the slow leg is mostly re-deciding the fast leg's call in that window. κ mode only.")

alertMode = input.string("Confirmed", "Alert mode", options = ["Live", "Confirmed", "Both"], group = GRP_ALRT, tooltip = "Drives ONE TradingView alert: create it on this indicator with condition 'Any alert() function call'. Live = developing fan-timeframe bar (earliest, can fire on a state that doesn't survive the close). Confirmed = last closed fan-timeframe bar (cannot un-fire, arrives on the first tick after the close). Both = each event can fire twice, live then confirmed. The six named conditions in the alert dialog still work for per-condition alerts.")

colUp   = input.color(#2DD4A7, "Up",   inline = "c", group = GRP_STY)
colDn   = input.color(#FF6B6B, "Down", inline = "c", group = GRP_STY)
colFlat = input.color(#9AA0A6, "Flat / n-a", inline = "c", group = GRP_STY)
wF = input.int(1, "Fast width", minval = 1, maxval = 4, inline = "w", group = GRP_STY)
wM = input.int(2, "Mid width",  minval = 1, maxval = 4, inline = "w", group = GRP_STY)
wS = input.int(3, "Slow width", minval = 1, maxval = 4, inline = "w", group = GRP_STY)

colSplit = #F5C542

// ══════════════════════════════════════
// HELPERS
// ══════════════════════════════════════

f_tfRes(string tf) =>
    tf == "" ? timeframe.period : tf

tf_valid(string tf) =>
    tf == "" or timeframe.in_seconds(tf) >= timeframe.in_seconds(timeframe.period)

format_tf(string tf) =>
    string d = f_tfRes(tf)
    string res = d
    if str.contains(d, "M") and not str.contains(d, "S")
        res := str.replace(d, "M", "Mn")
    res

f_state(float v, float sig, bool ok) =>
    not ok or na(v) or na(sig) ? 0 : v > sig ? 1 : v < sig ? -1 : 0

f_col(int s) =>
    s == 1 ? colUp : s == -1 ? colDn : colFlat

// ══════════════════════════════════════
// BUNDLE — one security context per timeframe, everything in that timeframe's bar-time
// ══════════════════════════════════════
type FanData
    float vF
    float vM
    float vS
    int   sF
    int   sM
    int   sS
    int   warm
    int   unan
    float agrP
    float agrK
    int   upT
    int   dnT
    int   splitT
    int   upC
    int   dnC
    int   splitC

f_bundle() =>
    // Both engines run unconditionally so every ta.* call keeps unbroken history; the
    // toggle only picks which set is used.
    float rF  = ta.rsi(rSrc, rLenF)
    float rM  = ta.rsi(rSrc, rLenM)
    float rS  = ta.rsi(rSrc, rLenS)
    float reF = ta.ema(rF, rEma)
    float reM = ta.ema(rM, rEma)
    float reS = ta.ema(rS, rEma)

    float kF  = ta.sma(ta.stoch(close, high, low, kLenF), kSmooth)
    float kM  = ta.sma(ta.stoch(close, high, low, kLenM), kSmooth)
    float kS  = ta.sma(ta.stoch(close, high, low, kLenS), kSmooth)
    float kdF = ta.sma(kF, dSmooth)
    float kdM = ta.sma(kM, dSmooth)
    float kdS = ta.sma(kS, dSmooth)

    float vF = isStoch ? kF  : rF
    float vM = isStoch ? kM  : rM
    float vS = isStoch ? kS  : rS
    float gF = isStoch ? kdF : reF
    float gM = isStoch ? kdM : reM
    float gS = isStoch ? kdS : reS

    // Warmup: slowest leg + its signal must be populated before any direction is asserted.
    int warmBars = isStoch ? math.max(math.max(kLenF, kLenM), kLenS) + kSmooth + dSmooth : math.max(math.max(rLenF, rLenM), rLenS) + rEma
    bool ok = bar_index >= warmBars and not na(gF) and not na(gM) and not na(gS)

    int sF = f_state(vF, gF, ok)
    int sM = f_state(vM, gM, ok)
    int sS = f_state(vS, gS, ok)

    bool unan = ok and sF == sM and sM == sS and sF != 0

    // LIVE transitions — this (possibly developing) bar vs the last closed one.
    int upT    = unan and sF ==  1 and not unan[1] ? 1 : 0
    int dnT    = unan and sF == -1 and not unan[1] ? 1 : 0
    int splitT = not unan and unan[1] ? 1 : 0

    // CONFIRMED transitions — what happened on the last CLOSED bar, read one bar later.
    // Every input here is a closed bar, so the value cannot change while the current HTF bar
    // develops.
    int upC    = unan[1] and sF[1] ==  1 and not unan[2] ? 1 : 0
    int dnC    = unan[1] and sF[1] == -1 and not unan[2] ? 1 : 0
    int splitC = not unan[1] and unan[2] ? 1 : 0

    // AGR — fast/slow agreement over the window, on bars where BOTH legs are directional.
    // math.sum carries state, so every sum runs every bar.
    //   po = observed agreement rate
    //   pe = agreement expected from base rates alone = P(F up)·P(S up) + P(F dn)·P(S dn)
    //   κ  = (po − pe) / (1 − pe)
    // A trend that pins both legs "up" raises pe as much as po, so κ stays near 0 unless the
    // legs agree on WHICH bars beyond that. 1 − pe near zero means at least one leg barely
    // changed state in the window — κ is undefined there, shown as "—".
    bool  both    = ok and sF != 0 and sS != 0
    float nV      = math.sum(both ? 1.0 : 0.0, agrLen)
    float nA      = math.sum(both and sF == sS ? 1.0 : 0.0, agrLen)
    float nFU     = math.sum(both and sF == 1  ? 1.0 : 0.0, agrLen)
    float nSU     = math.sum(both and sS == 1  ? 1.0 : 0.0, agrLen)
    bool  enough  = not na(nV) and nV >= agrLen * 0.5
    float po      = enough ? nA / nV : na
    float pf      = enough ? nFU / nV : na
    float ps      = enough ? nSU / nV : na
    float pe      = na(pf) ? na : pf * ps + (1.0 - pf) * (1.0 - ps)
    float agrK    = na(pe) or (1.0 - pe) < 0.02 ? na : (po - pe) / (1.0 - pe)
    float agrP    = na(po) ? na : po * 100.0

    FanData.new(vF = vF, vM = vM, vS = vS, sF = sF, sM = sM, sS = sS, warm = ok ? 1 : 0, unan = unan ? 1 : 0, agrP = agrP, agrK = agrK, upT = upT, dnT = dnT, splitT = splitT, upC = upC, dnC = dnC, splitC = splitC)

// ══════════════════════════════════════
// REQUESTS — plotted fan + up to six ladder rungs
// ══════════════════════════════════════
// A fan timeframe below the chart timeframe falls back to the chart timeframe, same rule as
// the ladder.
bool   tfInOk = tf_valid(tfIn)
string tfUse  = tfInOk ? f_tfRes(tfIn) : timeframe.period

FanData m = request.security(syminfo.tickerid, tfUse, f_bundle(), lookahead = barmerge.lookahead_off)
if na(m)
    m := FanData.new()

bool on1 = sh1 and tf_valid(tf1)
bool on2 = sh2 and tf_valid(tf2)
bool on3 = sh3 and tf_valid(tf3)
bool on4 = sh4 and tf_valid(tf4)
bool on5 = sh5 and tf_valid(tf5)
bool on6 = sh6 and tf_valid(tf6)
bool on7 = sh7 and tf_valid(tf7)

FanData b1 = on1 ? request.security(syminfo.tickerid, f_tfRes(tf1), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b1)
    b1 := FanData.new()
FanData b2 = on2 ? request.security(syminfo.tickerid, f_tfRes(tf2), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b2)
    b2 := FanData.new()
FanData b3 = on3 ? request.security(syminfo.tickerid, f_tfRes(tf3), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b3)
    b3 := FanData.new()
FanData b4 = on4 ? request.security(syminfo.tickerid, f_tfRes(tf4), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b4)
    b4 := FanData.new()
FanData b5 = on5 ? request.security(syminfo.tickerid, f_tfRes(tf5), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b5)
    b5 := FanData.new()
FanData b6 = on6 ? request.security(syminfo.tickerid, f_tfRes(tf6), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b6)
    b6 := FanData.new()
FanData b7 = on7 ? request.security(syminfo.tickerid, f_tfRes(tf7), f_bundle(), lookahead = barmerge.lookahead_off) : FanData.new()
if na(b7)
    b7 := FanData.new()

// ══════════════════════════════════════
// PLOT — the fan for the selected timeframe
// ══════════════════════════════════════
bool mWarm = nz(m.warm) == 1

hline(50, "Midline", color = #808080, linestyle = hline.style_dotted)
hline(obLvl, "Overbought", color = #808080, linestyle = hline.style_dashed, display = isStoch ? display.all : display.none)
hline(osLvl, "Oversold",   color = #808080, linestyle = hline.style_dashed, display = isStoch ? display.all : display.none)

// No price-scale labels: three moving value tags on the right axis add clutter to a short
// pane. Values remain in the status line and data window.
plot(mWarm ? m.vF : na, "Fast", color = f_col(nz(m.sF)), linewidth = wF, style = plot.style_linebr, display = display.all - display.price_scale)
plot(mWarm ? m.vM : na, "Mid",  color = f_col(nz(m.sM)), linewidth = wM, style = plot.style_linebr, display = display.all - display.price_scale)
plot(mWarm ? m.vS : na, "Slow", color = f_col(nz(m.sS)), linewidth = wS, style = plot.style_linebr, display = display.all - display.price_scale)

// ══════════════════════════════════════
// DASH FORMATTERS
// ══════════════════════════════════════

f_valTxt(float v, int s, bool w) =>
    if not w or na(v)
        "—"
    else
        string arrow = s == 1 ? "↑" : s == -1 ? "↓" : "·"
        string mk = isStoch and (v > obLvl or v < osLvl) ? extMark : ""
        str.tostring(v, "#") + arrow + mk

f_valCol(int s, bool w) =>
    not w or s == 0 ? colFlat : s == 1 ? colUp : colDn

f_fanLbl(bool w, bool u, int s) =>
    not w ? "—" : u ? (s == 1 ? "ALL▲" : "ALL▼") : "SPLIT"

f_fanBg(bool w, bool u, int s) =>
    not w ? color.new(color.gray, 45) : u ? color.new(s == 1 ? colUp : colDn, 10) : color.new(colSplit, 10)

f_agrTxt(bool w, FanData d) =>
    if agrMode == "κ"
        not w or na(d.agrK) ? "—" : str.tostring(d.agrK, "0.00")
    else
        not w or na(d.agrP) ? "—" : str.tostring(d.agrP, "#") + "%"

f_agrCol(bool w, FanData d) =>
    if agrMode == "κ"
        not w or na(d.agrK) ? colFlat : d.agrK >= kapHi ? colSplit : #D6D6D6
    else
        not w or na(d.agrP) ? colFlat : #D6D6D6

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Middle Left"  => position.middle_left
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        => position.top_right

f_font() =>
    switch dashFont
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

// ══════════════════════════════════════
// MTF DASH
// ══════════════════════════════════════
// Row count is fixed for a run (inputs + chart timeframe can't change mid-run), so a plain
// var table is enough.

int tfUseSec = timeframe.in_seconds(tfUse)
f_isPlot(string tf) =>
    timeframe.in_seconds(f_tfRes(tf)) == tfUseSec

bool inLadder = (on1 and f_isPlot(tf1)) or (on2 and f_isPlot(tf2)) or (on3 and f_isPlot(tf3)) or (on4 and f_isPlot(tf4)) or (on5 and f_isPlot(tf5)) or (on6 and f_isPlot(tf6)) or (on7 and f_isPlot(tf7))
int nLad  = (on1 ? 1 : 0) + (on2 ? 1 : 0) + (on3 ? 1 : 0) + (on4 ? 1 : 0) + (on5 ? 1 : 0) + (on6 ? 1 : 0) + (on7 ? 1 : 0)
int nRows = 1 + nLad + (inLadder ? 0 : 1)
int nCols = showAgr ? 6 : 5

string fbNote = tfInOk ? "" : "Fan timeframe " + tfIn + " is below the chart timeframe — plotting the chart timeframe instead."

// Created only when shown: an input change re-runs the script from bar 0, so this is all the
// show/hide logic needs, and a hidden dash leaves no empty frame behind.
var table dash = showDash ? table.new(f_pos(dashPos), nCols, nRows, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 60), bgcolor = color.new(color.black, 100)) : na

f_row(int r, string tf, bool isPlot, FanData d, string fs) =>
    color tp = color.new(color.black, 100)
    bool w  = nz(d.warm) == 1
    bool u  = nz(d.unan) == 1
    int  s1 = nz(d.sF)
    int  s2 = nz(d.sM)
    int  s3 = nz(d.sS)
    bool fb = isPlot and not tfInOk
    string lab = (isPlot ? "▸ " : "") + format_tf(tf) + (fb ? "*" : "")
    table.cell(dash, 0, r, lab, text_color = isPlot ? color.white : #D6D6D6, text_size = fs, bgcolor = isPlot ? color.new(color.gray, 75) : tp, tooltip = fb ? fbNote : "")
    table.cell(dash, 1, r, f_valTxt(d.vF, s1, w), text_color = f_valCol(s1, w), text_size = fs, bgcolor = tp)
    table.cell(dash, 2, r, f_valTxt(d.vM, s2, w), text_color = f_valCol(s2, w), text_size = fs, bgcolor = tp)
    table.cell(dash, 3, r, f_valTxt(d.vS, s3, w), text_color = f_valCol(s3, w), text_size = fs, bgcolor = tp)
    table.cell(dash, 4, r, f_fanLbl(w, u, s1), text_color = color.white, text_size = fs, bgcolor = f_fanBg(w, u, s1))
    if showAgr
        table.cell(dash, 5, r, f_agrTxt(w, d), text_color = f_agrCol(w, d), text_size = fs, bgcolor = tp)

if showDash and barstate.islast
    string fs = f_font()
    color tp = color.new(color.black, 100)
    color hc = color.new(color.gray, 0)
    string pre = isStoch ? "K" : "R"
    table.cell(dash, 0, 0, "TF", text_color = hc, text_size = fs, bgcolor = tp)
    table.cell(dash, 1, 0, pre + str.tostring(isStoch ? kLenF : rLenF), text_color = hc, text_size = fs, bgcolor = tp)
    table.cell(dash, 2, 0, pre + str.tostring(isStoch ? kLenM : rLenM), text_color = hc, text_size = fs, bgcolor = tp)
    table.cell(dash, 3, 0, pre + str.tostring(isStoch ? kLenS : rLenS), text_color = hc, text_size = fs, bgcolor = tp)
    table.cell(dash, 4, 0, "FAN", text_color = hc, text_size = fs, bgcolor = tp)
    if showAgr
        table.cell(dash, 5, 0, agrMode == "κ" ? "AGRκ" : "AGR%", text_color = hc, text_size = fs, bgcolor = tp)

    int r = 1
    if not inLadder
        f_row(r, tfUse, true, m, fs)
        r += 1
    if on1
        f_row(r, tf1, f_isPlot(tf1), b1, fs)
        r += 1
    if on2
        f_row(r, tf2, f_isPlot(tf2), b2, fs)
        r += 1
    if on3
        f_row(r, tf3, f_isPlot(tf3), b3, fs)
        r += 1
    if on4
        f_row(r, tf4, f_isPlot(tf4), b4, fs)
        r += 1
    if on5
        f_row(r, tf5, f_isPlot(tf5), b5, fs)
        r += 1
    if on6
        f_row(r, tf6, f_isPlot(tf6), b6, fs)
        r += 1
    if on7
        f_row(r, tf7, f_isPlot(tf7), b7, fs)

// ══════════════════════════════════════
// ALERTS — plotted fan only
// ══════════════════════════════════════
// The flags arrive from the fan's own bar-time but are HELD across every chart bar inside an
// HTF bar, so each alert fires on the chart-side rising edge — once per event, not once per
// chart bar. Use frequency "Once Per Bar".
//   Live      : developing HTF bar — earliest, can fire on a state that doesn't survive close.
//   Confirmed : last CLOSED HTF bar — cannot un-fire, arrives on the first tick after close.
int mUpL = nz(m.upT)
int mDnL = nz(m.dnT)
int mSpL = nz(m.splitT)
int mUpC = nz(m.upC)
int mDnC = nz(m.dnC)
int mSpC = nz(m.splitC)

bool aUpL = mUpL == 1 and mUpL[1] != 1
bool aDnL = mDnL == 1 and mDnL[1] != 1
bool aSpL = mSpL == 1 and mSpL[1] != 1
bool aUpC = mUpC == 1 and mUpC[1] != 1
bool aDnC = mDnC == 1 and mDnC[1] != 1
bool aSpC = mSpC == 1 and mSpC[1] != 1

// Named conditions — one TradingView alert per condition.
alertcondition(aUpL, "Fan Unanimous Up — live",        "Osc Fan: all three legs above their signal (developing bar)")
alertcondition(aDnL, "Fan Unanimous Down — live",      "Osc Fan: all three legs below their signal (developing bar)")
alertcondition(aSpL, "Fan Split — live",               "Osc Fan: fan broke ranks (developing bar)")
alertcondition(aUpC, "Fan Unanimous Up — confirmed",   "Osc Fan: all three legs closed above their signal")
alertcondition(aDnC, "Fan Unanimous Down — confirmed", "Osc Fan: all three legs closed below their signal")
alertcondition(aSpC, "Fan Split — confirmed",          "Osc Fan: fan broke ranks on a closed bar")

// One-alert setup (v1.8) — create a single alert on "Any alert() function call"; the Alert mode
// input picks which set fires.
bool useLive = alertMode != "Confirmed"
bool useConf = alertMode != "Live"
string aTag  = "Osc Fan " + syminfo.ticker + " " + format_tf(tfUse) + " " + engine + ": "

if useLive and aUpL
    alert(aTag + "ALL▲ (live)", alert.freq_once_per_bar)
if useLive and aDnL
    alert(aTag + "ALL▼ (live)", alert.freq_once_per_bar)
if useLive and aSpL
    alert(aTag + "SPLIT (live)", alert.freq_once_per_bar)
if useConf and aUpC
    alert(aTag + "ALL▲ (confirmed)", alert.freq_once_per_bar)
if useConf and aDnC
    alert(aTag + "ALL▼ (confirmed)", alert.freq_once_per_bar)
if useConf and aSpC
    alert(aTag + "SPLIT (confirmed)", alert.freq_once_per_bar)
````
