<!-- tradingview-pine-id: PUB;49bec9ab499e4e1f853de5a27b3bbb29 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_session

Source: https://www.tradingview.com/script/YmdSzuIx-ml-session/

## Description

ml_session is a dependency-free library for Pine v6 that fixes a blind spot every intraday study shares: a flat rolling average has no idea what time it is. Intraday volume and range have a strong U-shape — heavy at the open and the close, thin around lunch — so a normal open prints as a "volume spike" against a flat baseline, and a genuinely quiet mid-session bar looks average. This library judges the current bar against the same time-of-day slot on prior sessions, and lets you rank which slots of the day your signals actually pay in.

How it works

Each bar maps to a wall-clock slot (say every 5 minutes). The library keeps one rolling mean / stdev per slot, updated only when that slot occurs, so "how unusual is now" is always measured against this time of day's own history. The estimators are exponential — an N-session memory — so there are no large buffers and nothing repaints.

Slot mapping
slotOf(slotMinutes) — the time-of-day slot index for the current bar, from the symbol's exchange clock ((hour·60 + minute) ÷ slotMinutes). For NSE that's IST, so it lines up with NIFTY's 09:15–15:30 session.
slotCount(slotMinutes) — how many slots cover a 24h day at that granularity. Pass it as nSlots to size the per-slot state.
sessionAlpha(sessions) — the EMA weight for an N-session memory (≈ 2 / (N+1)). Feed it to the estimators below.
slotLabel(slot, slotMinutes) — an "HH:MM" label for a slot, for dashboards.
Per-slot baselines
slotMean(src, slot, nSlots, alpha) — the rolling mean of src for this time-of-day slot: the baseline itself.
slotStdev(src, slot, nSlots, alpha) — the rolling dispersion for this slot.
slotZ(src, slot, nSlots, alpha) — the time-of-day z-score, (src − slot mean) ÷ slot stdev, in one call. "How unusual is this bar for this time of day." The core self-calibrating read — pass volume, range, or any intraday series.
slotRatio(src, slot, nSlots, alpha) — src ÷ slot mean (1.0 = a normal reading for this time of day, 2.0 = twice the usual). Ideal for volume — "heavy for the open", not "heavy vs a flat average".
Time-of-day edge ranking
slotHitRate(add, win, slot, nSlots) — per-slot forward-test bookkeeping. When a signal outcome resolves, call with add = true and win = true/false, passing the signal bar's slot (e.g. slot[horizon]); it returns that slot's running hit rate (%). Use it to see which parts of the session your signal works in — and which to sit out.
slotCountN(add, slot, nSlots) — the sample count accrued for a slot, so you can weight its hit rate by confidence.
How to use

Make "high volume" mean high for this time of day, and pair it with a time-of-day edge read:

//@version=6
indicator("Example — time-of-day baselines", overlay = false)
import Market_Logic_India/ml_session/1 as sess

slotMin = input.int(5,  "Slot minutes")
memory  = input.int(20, "Session memory")

n   = sess.slotCount(slotMin)
a   = sess.sessionAlpha(memory)
sl  = sess.slotOf(slotMin)

volRatio = sess.slotRatio(volume, sl, n, a)     // volume vs its time-of-day norm
volZ     = sess.slotZ(volume, sl, n, a)         // standardized for this slot
plot(volRatio, "Vol vs ToD", color = volRatio > 1.5 ? color.orange : color.gray)

// time-of-day edge (host resolves `win` at its horizon):
// hit = sess.slotHitRate(resolvedNow, win, sl[horizon], n)

Pairs naturally with a VSA / effort-vs-result read: a true "climactic" bar is one whose volume is extreme for its slot, not merely above a flat mean.

Notes
Non-repainting: every read is a pure function of the values you pass and per-slot state that only moves forward. Feed confirmed-bar values (gate on barstate.isconfirmed) and the baselines never look ahead. No ta.* inside, so nothing can short-circuit.
Warm-up: each slot needs a few sessions before its baseline is meaningful; early bars return the seed value or na.
Types: pass series for the source and slot, simple int for nSlots, and simple float for alpha.
The clock is the symbol's exchange timezone, so it's correct for NSE without configuration; on a 24h symbol every slot simply fills.
Concept credits

Intraday seasonality — the U-shaped time-of-day profile of volume and volatility — is long established in market-microstructure research. This library is an original, dependency-free Pine v6 packaging of that idea; it is not affiliated with, nor endorsed by, any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_session — Session & time-of-day baselines  (Wave D foundation library)
// Built for NIFTY's clock. Intraday series have a strong time-of-day shape — volume is
// heavy at the open and the close, thin at lunch — so a flat rolling average mislabels a
// normal open as a "volume spike". This library judges the current bar against the SAME
// time-of-day slot on prior sessions, and ranks which slots of the day actually carry edge.
//   import Market_Logic_India/ml_session/2 as sess
// v2 (Batch-3) ADDS Initial Balance (opening-range high/low), an opening-window helper
// (opening-lock / IB window), a new-day flag, an IB-break read, and a ToD SIGNIFICANCE
// gate wrapping slotZ. Additive — every v1 export is unchanged.
//
// HOW IT WORKS  Each bar maps to a wall-clock slot (e.g. every 5 minutes). One rolling
// mean / stdev is kept PER SLOT and updated only when that slot occurs, so "how unusual is
// now" is measured against this time of day's own history — a per-session-anchored baseline.
// The estimators are exponential (an N-session memory) so no big buffers are needed.
//
// NON-REPAINT  Every read is a pure function of the values you pass and per-slot state that
// only advances forward. Feed confirmed-bar values (gate on barstate.isconfirmed in the host)
// and the baselines never look ahead. No ta.* inside — nothing to short-circuit.
//
// CONCEPT CREDIT  Time-of-day / intraday seasonality in volume and volatility is long
// established in market-microstructure research (e.g. the U-shaped intraday volume curve).
// This is an original, dependency-free Pine v6 packaging of that idea.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_session", overlay = false)

// ── SLOT MAPPING ────────────────────────────────────────────────────────────────
// Time-of-day slot index from the bar's exchange wall-clock: (hour*60+minute) / slotMinutes.
// NIFTY futures trade 09:15–15:30 IST; `hour`/`minute` are in the symbol's exchange timezone.
export slotOf(simple int slotMinutes) =>
    int mins = hour * 60 + minute
    slotMinutes > 0 ? int(mins / slotMinutes) : 0

// Number of slots that cover a full 24h day at this granularity — pass as `nSlots` for sizing.
export slotCount(simple int slotMinutes) =>
    slotMinutes > 0 ? int(math.ceil(1440.0 / slotMinutes)) : 1

// EMA weight for an N-session memory: alpha ≈ 2 / (N + 1). Pass to the slot estimators.
export sessionAlpha(simple int sessions) =>
    2.0 / (math.max(sessions, 1) + 1.0)

// Human-readable "HH:MM" label for a slot (start of the slot). For dashboards.
export slotLabel(series int slot, simple int slotMinutes) =>
    int mins = slot * slotMinutes
    int hh = int(mins / 60)
    int mm = mins % 60
    (hh < 10 ? "0" : "") + str.tostring(hh) + ":" + (mm < 10 ? "0" : "") + str.tostring(mm)

// ── PER-SLOT BASELINES ──────────────────────────────────────────────────────────
// Rolling MEAN of src for THIS time-of-day slot. Keeps one EMA per slot, updates only the
// current bar's slot, and returns that slot's running mean — the time-of-day baseline.
export slotMean(series float src, series int slot, simple int nSlots, simple float alpha) =>
    var array<float> mean = array.new<float>(nSlots, na)
    int i = (slot >= 0 and slot < nSlots) ? slot : 0
    float prev = array.get(mean, i)
    float cur  = na(src) ? prev : na(prev) ? src : prev + alpha * (src - prev)
    array.set(mean, i, cur)
    cur

// Rolling STDEV of src for this slot (from EMA of value and value²). The slot's dispersion.
export slotStdev(series float src, series int slot, simple int nSlots, simple float alpha) =>
    var array<float> m1 = array.new<float>(nSlots, na)
    var array<float> m2 = array.new<float>(nSlots, na)
    int i = (slot >= 0 and slot < nSlots) ? slot : 0
    float p1 = array.get(m1, i)
    float p2 = array.get(m2, i)
    float c1 = na(src) ? p1 : na(p1) ? src : p1 + alpha * (src - p1)
    float c2 = na(src) ? p2 : na(p2) ? src * src : p2 + alpha * (src * src - p2)
    array.set(m1, i, c1)
    array.set(m2, i, c2)
    float v = (na(c1) or na(c2)) ? na : c2 - c1 * c1
    (not na(v) and v > 0.0) ? math.sqrt(v) : 0.0

// Time-of-day Z-SCORE: (src − slot mean) / slot stdev, in ONE call (keeps mean+var per slot).
// "How unusual is this bar for THIS time of day." The core self-calibrating read.
export slotZ(series float src, series int slot, simple int nSlots, simple float alpha) =>
    var array<float> m1 = array.new<float>(nSlots, na)
    var array<float> m2 = array.new<float>(nSlots, na)
    int i = (slot >= 0 and slot < nSlots) ? slot : 0
    float p1 = array.get(m1, i)
    float p2 = array.get(m2, i)
    float c1 = na(src) ? p1 : na(p1) ? src : p1 + alpha * (src - p1)
    float c2 = na(src) ? p2 : na(p2) ? src * src : p2 + alpha * (src * src - p2)
    array.set(m1, i, c1)
    array.set(m2, i, c2)
    float sd = (na(c1) or na(c2)) ? na : math.sqrt(math.max(c2 - c1 * c1, 0.0))
    (not na(src) and not na(sd) and sd > 0.0) ? (src - c1) / sd : 0.0

// Time-of-day RATIO: src ÷ slot mean (1.0 = a normal reading for this time of day; 2.0 = twice
// the usual). Ideal for volume — "heavy for the open" instead of "heavy vs a flat average".
export slotRatio(series float src, series int slot, simple int nSlots, simple float alpha) =>
    var array<float> mean = array.new<float>(nSlots, na)
    int i = (slot >= 0 and slot < nSlots) ? slot : 0
    float prev = array.get(mean, i)
    float cur  = na(src) ? prev : na(prev) ? src : prev + alpha * (src - prev)
    array.set(mean, i, cur)
    (not na(src) and not na(cur) and cur > 0.0) ? src / cur : na

// ── TIME-OF-DAY EDGE RANKING ─────────────────────────────────────────────────────
// Per-slot forward-test bookkeeping. When a signal outcome RESOLVES, call with add=true and
// win=true/false, passing the SIGNAL bar's slot (e.g. slot[horizon]). Returns that slot's
// running hit rate (%). Use it to rank which parts of the session actually pay.
export slotHitRate(series bool add, series bool win, series int slot, simple int nSlots) =>
    var array<float> w = array.new<float>(nSlots, 0.0)
    var array<float> n = array.new<float>(nSlots, 0.0)
    int i = (slot >= 0 and slot < nSlots) ? slot : 0
    if add
        array.set(n, i, array.get(n, i) + 1.0)
        if win
            array.set(w, i, array.get(w, i) + 1.0)
    float nn = array.get(n, i)
    (nn > 0.0) ? array.get(w, i) / nn * 100.0 : na

// Sample count accrued for a slot (companion to slotHitRate — read its confidence).
export slotCountN(series bool add, series int slot, simple int nSlots) =>
    var array<float> n = array.new<float>(nSlots, 0.0)
    int i = (slot >= 0 and slot < nSlots) ? slot : 0
    if add
        array.set(n, i, array.get(n, i) + 1.0)
    array.get(n, i)

// ══════════════════════════════════════════════════════════════════════════════
// v2 ▸ INITIAL BALANCE · OPENING WINDOW · ToD SIGNIFICANCE GATE
// ══════════════════════════════════════════════════════════════════════════════

// New-day flag from the daily timestamp (no ta.*): true on the first bar of a new session.
export isNewDay() =>
    na(time("D")[1]) or time("D") != time("D")[1]

// Is the current bar inside a wall-clock opening window [start, start+windowMins)?
// NIFTY opening-lock / Initial-Balance window: inOpeningWindow(9, 15, 60) = 09:15–10:15.
export inOpeningWindow(simple int startHour, simple int startMin, simple int windowMins) =>
    int nowM   = hour * 60 + minute
    int startM = startHour * 60 + startMin
    nowM >= startM and nowM < startM + windowMins

// INITIAL BALANCE high/low: reset each session, expand while inIB (e.g. inOpeningWindow).
// Returns [ibHigh, ibLow] — the opening auction's range, a first-class NIFTY intraday level.
export initialBalance(series bool isNewSession, series bool inIB, series float h, series float l) =>
    var float ibH = na
    var float ibL = na
    if isNewSession
        ibH := na
        ibL := na
    if inIB
        ibH := na(ibH) ? h : math.max(ibH, h)
        ibL := na(ibL) ? l : math.min(ibL, l)
    [ibH, ibL]

// IB break state: +1 = above IB high (bullish break), -1 = below IB low, 0 = inside.
export ibBreak(series float c, series float ibHigh, series float ibLow) =>
    (not na(ibHigh) and c > ibHigh) ? 1 : (not na(ibLow) and c < ibLow) ? -1 : 0

// ToD SIGNIFICANCE GATE: is this bar's `src` unusual FOR THIS TIME OF DAY beyond zThr?
// Convenience wrapper over slotZ — "big for the open", not "big vs a flat average".
export slotSignificant(series float src, series int slot, simple int nSlots, simple float alpha, simple float zThr) =>
    float z = slotZ(src, slot, nSlots, alpha)
    not na(z) and math.abs(z) >= zThr

// ── demo output (library preview only) ──
// Volume relative to its own 5-minute time-of-day baseline over ~20 sessions (1.0 = normal).
plot(slotRatio(volume, slotOf(5), slotCount(5), sessionAlpha(20)), "Vol vs ToD baseline (demo)", color = color.new(#6f9bd8, 0))
````
