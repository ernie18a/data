<!-- tradingview-pine-id: PUB;648d4ea6b0d8402cabbfc5ecd1182146 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ml_vsa

Source: https://www.tradingview.com/script/HXOgXfMr-ml-vsa/

## Description

ml_vsa is a dependency-free library for Pine v6 that packages the classic Volume Spread Analysis reading of a bar into one shared vocabulary. Most studies describe absorption vaguely — "price made a high but the oscillator did not." Import one shared implementation and a script can instead say "Upthrust" or "Stopping Volume" — a named, directional event with a fixed definition — so "the same event" means the same thing across every script you build.

The idea

VSA reads each bar as EFFORT (volume) versus RESULT (the spread, and where the bar closed inside its range):

Effort with no result — heavy volume, narrow spread — is absorption: someone is soaking up orders without moving price.
Result with no effort — wide spread, light volume — is a move with nothing behind it.
A new extreme that gets rejected on volume — pushes past the prior high/low but closes back inside — is a trap (Upthrust up, Shakeout down).

Each function takes a series source (high, low, close, volume) and simple window lengths, so it drops into any study. Percentile thresholds follow standard VSA practice and are baked in; the windows are yours.

Primitives
closePos(h, l, c) — where the bar closed inside its range: 0 = on the low, 1 = on the high.
spreadPct(h, l, len) — the current bar's range as a percentile (0..100) of its own recent history. The RESULT axis: is this a wide bar or a narrow one, for this symbol right now.
volPct(v, len) — the current bar's volume as a percentile (0..100) of its own history. The EFFORT axis. On a volumeless symbol this is flat and the volume-gated events simply never fire.
Named events (one-bar classifications; each self-contained, each returns a bool unless noted)
noDemand(h,l,c,v,len) — bearish. An up-bar on NARROW spread and LOW volume: the rally has no effort behind it.
noSupply(h,l,c,v,len) — bullish. A down-bar on narrow spread and low volume: no selling pressure left.
upthrust(h,l,c,v,len,pivLen) — bearish. Pushes to a NEW HIGH (over the prior pivLen highs) on HIGH volume but closes back near the LOW — buyers trapped.
shakeout(h,l,c,v,len,pivLen) — bullish. Pushes to a NEW LOW on high volume but closes back near the HIGH — sellers trapped (a Spring).
stoppingVolume(h,l,c,v,len) — bullish. A WIDE down-bar on VERY HIGH volume that closes OFF the low — heavy demand stepping in to halt a decline.
climax(h,l,c,v,len) — returns +1 / −1 / 0. CLIMACTIC volume (≥90th pct) on a wide bar: an up-climax is a potential buying-climax exhaustion (returns −1, bearish); a down-climax is a selling-climax exhaustion (returns +1, bullish).
effortNoResult(h,l,v,len) — a NON-directional absorption flag. High volume, narrow spread: effort with no result. Where the market is soaking up orders; direction needs context.
Composites
vsaBias(h,l,c,v,len,pivLen) — the events netted to a direction: +1 bullish, −1 bearish, 0 none/conflict. (The non-directional absorption flag is deliberately excluded.) Use this one call so a "VSA-confirmed" read means the same thing on every engine.
vsaCode(h,l,c,v,len,pivLen) — an integer identifying WHICH event dominates (priority: climax > trap > stopping > no-demand/supply > absorption): 3 buying-climax · −3 selling-climax · 2 upthrust · −2 shakeout · −1 stopping · 4 no-demand · −4 no-supply · 5 absorption · 0 none. (The sign here identifies the event, not the trade direction — use vsaBias for direction.)
vsaLabel(h,l,c,v,len,pivLen) — the dominant event as a string ("Upthrust", "Stopping volume", …) for a dashboard or a marker.
How to use

Mark the events, and read a shared direction:

//@version=6
indicator("Example — VSA events", overlay = true)
import Market_Logic_India/ml_vsa/1 as vsa

len = input.int(50, "VSA history window")
piv = input.int(5,  "New-extreme lookback")

ut = vsa.upthrust(high, low, close, volume, len, piv)
so = vsa.shakeout(high, low, close, volume, len, piv)
sv = vsa.stoppingVolume(high, low, close, volume, len)

plotshape(ut, "Upthrust", shape.triangledown, location.abovebar, color.red,   text = "UT")
plotshape(so, "Shakeout", shape.triangleup,   location.belowbar, color.green, text = "SO")
plotshape(sv, "Stopping", shape.square,        location.belowbar, color.teal,  text = "SV")

bias = vsa.vsaBias(high, low, close, volume, len, piv)   // +1 / -1 / 0
bgcolor(bias > 0 ? color.new(color.green, 90) : bias < 0 ? color.new(color.red, 90) : na)

The events pair naturally with level and flow tools: an Upthrust into a resistance level, or Stopping Volume on a support level, is far stronger than either read alone.

Notes
Non-repainting: every read is a pure function of closed-bar spread, volume, close and their rolling history (ta.percentrank / ta.highest / ta.lowest). Nothing looks ahead. To be certain a live bar's event never flickers, gate on barstate.isconfirmed in your host script.
State safety: the composites call each event UNCONDITIONALLY and then select, so the ta.* inside every event runs on every bar (the correct Pine pattern). If you call the individual events yourself, keep them out of if/ternary branches for the same reason.
Types: pass series for the price/volume inputs and simple int for the window lengths.
These are OHLCV-based proxies for the classic tape reads, not exchange-grade order flow — pair every event with a forward test (e.g. ml_calib) before trusting its edge on your instrument.
Concept credits

Volume Spread Analysis and the effort-vs-result principle — with the named events No Demand, No Supply, Upthrust, Shakeout/Spring, Stopping Volume, Buying/Selling Climax and Test — descend from Richard D. Wyckoff and the VSA tradition associated with Tom Williams. This library is an original, dependency-free Pine v6 packaging of those public techniques; it is not affiliated with, nor endorsed by, any originator.

License

Mozilla Public License 2.0 — as required for TradingView libraries (open source). Free to import and build on.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
// ml_vsa — Volume-Spread-Analysis effort-vs-result taxonomy  (Wave D foundation library)
// One shared Wyckoff/VSA event vocabulary so every absorption / flow / order-flow script
// names the SAME thing the same way. Instead of a generic "price made a high but the
// oscillator did not", a script can say "Upthrust" or "Stopping Volume" — an interpretable,
// forward-testable event — and every study in the suite agrees on what that means.
//   import Market_Logic_India/ml_vsa/2 as vsa
// v2 (Batch-2) ADDS the QUANTIFIED effort-vs-result layer: a blended result scalar,
// net-delta dominance, the dominance−result absorption score, a compact effort/result
// STATE, and the headline FOUR-WAY ABSORPTION CONSENSUS (agree across OLS residual +
// cost-per-tick + dominance−result + qualitative VSA before calling absorption), plus a
// rolling background-bias context. Additive — every v1 export is unchanged.
//
// THE IDEA  VSA reads each bar as EFFORT (volume) versus RESULT (spread + where it closed).
//   • Effort with no result (high volume, narrow spread) = absorption.
//   • Result with no effort (wide spread, low volume) = a move with nothing behind it.
//   • A new extreme rejected on volume (closes back inside) = a trap (Upthrust / Shakeout).
//   The taxonomy turns those relationships into named, directional events.
//
// SCOPE / HONESTY  A charting platform sees a bar's volume and geometry, not the tape. These
//   are disciplined one-bar classifications from spread, close position and volume-vs-history —
//   an interpretable proxy for the classic Wyckoff/VSA reads, not exchange-grade order flow.
//   Percentile thresholds are baked to sensible VSA defaults (see each function); the window
//   lengths are yours. Pair every event with a forward test (e.g. ml_calib) before trusting it.
//
// NON-REPAINT  Every read is a pure function of CLOSED-bar spread / volume / close and their
//   rolling history (ta.percentrank / ta.highest / ta.lowest). Nothing looks ahead.
//
// CONCEPT CREDIT  Volume Spread Analysis / the effort-vs-result principle and the named events
//   (No Demand, No Supply, Upthrust, Shakeout/Spring, Stopping Volume, Buying/Selling Climax,
//   Test) descend from Richard D. Wyckoff and the VSA tradition (Tom Williams). This is an
//   original, dependency-free Pine v6 packaging of those public techniques; not affiliated with
//   nor endorsed by any originator.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
library("ml_vsa", overlay = false)

// ── PRIMITIVES ─────────────────────────────────────────────────────────────────
// Close position within the bar's range: 0 = closed on the low, 1 = closed on the high.
export closePos(series float h, series float l, series float c) =>
    float rng = h - l
    rng > 0.0 ? (c - l) / rng : 0.5

// Spread percentile (0..100): how wide THIS bar's range is versus its own recent history.
export spreadPct(series float h, series float l, simple int len) =>
    ta.percentrank(h - l, len)

// Volume percentile (0..100): how heavy THIS bar's volume is versus its own recent history.
// (Effort. On volumeless symbols this is flat and the volume-gated events simply never fire.)
export volPct(series float v, simple int len) =>
    ta.percentrank(v, len)

// ── EVENTS (one-bar classifications; each is self-contained) ────────────────────
// Thresholds follow standard VSA practice: "narrow/low" ≤ 35th pct, "wide/high" ≥ 60th,
// "very high" ≥ 80th, "climactic" ≥ 90th, close "near low" ≤ 0.35, "near high" ≥ 0.65.

// NO DEMAND (bearish) — an up-bar on NARROW spread and LOW volume: the rally has no effort
// behind it. Most meaningful inside an up-move.
export noDemand(series float h, series float l, series float c, series float v, simple int len) =>
    float sp = spreadPct(h, l, len)
    float vp = volPct(v, len)
    bool up  = c > c[1]
    up and sp <= 35.0 and vp <= 35.0

// NO SUPPLY (bullish) — a down-bar on NARROW spread and LOW volume: no selling pressure left.
export noSupply(series float h, series float l, series float c, series float v, simple int len) =>
    float sp = spreadPct(h, l, len)
    float vp = volPct(v, len)
    bool dn  = c < c[1]
    dn and sp <= 35.0 and vp <= 35.0

// UPTHRUST (bearish) — pushes to a NEW HIGH (over the prior pivLen highs) on HIGH volume but
// closes back near the LOW: buyers trapped, supply overwhelmed the breakout.
export upthrust(series float h, series float l, series float c, series float v, simple int len, simple int pivLen) =>
    float vp   = volPct(v, len)
    float cp   = closePos(h, l, c)
    float pHi  = ta.highest(h, pivLen)[1]
    bool  newHi = h >= pHi
    newHi and cp <= 0.35 and vp >= 60.0

// SHAKEOUT / SPRING (bullish) — pushes to a NEW LOW on HIGH volume but closes back near the
// HIGH: sellers trapped, demand absorbed the break.
export shakeout(series float h, series float l, series float c, series float v, simple int len, simple int pivLen) =>
    float vp   = volPct(v, len)
    float cp   = closePos(h, l, c)
    float pLo  = ta.lowest(l, pivLen)[1]
    bool  newLo = l <= pLo
    newLo and cp >= 0.65 and vp >= 60.0

// STOPPING VOLUME (bullish) — a WIDE down-bar on VERY HIGH volume that closes OFF the low:
// heavy demand stepping in to halt a decline.
export stoppingVolume(series float h, series float l, series float c, series float v, simple int len) =>
    float sp = spreadPct(h, l, len)
    float vp = volPct(v, len)
    float cp = closePos(h, l, c)
    bool  dn = c < c[1]
    dn and sp >= 60.0 and vp >= 80.0 and cp >= 0.45

// CLIMAX — a genuine CLIMACTIC bar: the HEAVIEST volume in the window (a true local peak, not
// merely a high percentile) on a WIDE bar. Up-climax = potential buying-climax exhaustion
// (bearish); down-climax = selling-climax exhaustion (bullish). Returns +1 / -1 / 0. Rare by
// design — a percentile threshold fires on a fixed fraction of bars and so cannot mean "extreme".
export climax(series float h, series float l, series float c, series float v, simple int len) =>
    float sp  = spreadPct(h, l, len)
    float vpk = ta.highest(v, len)          // heaviest volume in the window (incl. this bar)
    bool  up  = c > c[1]
    bool  dn  = c < c[1]
    bool  clx = v >= vpk and sp >= 70.0      // new volume peak + wide range = climactic
    clx and up ? -1 : clx and dn ? 1 : 0

// EFFORT vs RESULT anomaly (absorption; NON-directional flag) — HIGH volume, NARROW spread:
// effort with no result. Where the market is soaking up orders; direction needs context.
export effortNoResult(series float h, series float l, series float v, simple int len) =>
    float sp = spreadPct(h, l, len)
    float vp = volPct(v, len)
    vp >= 75.0 and sp <= 30.0

// ── COMPOSITE ──────────────────────────────────────────────────────────────────
// Net directional bias from the events above: +1 bullish, -1 bearish, 0 none/conflict.
// (Absorption/effortNoResult is deliberately excluded — it is a context flag, not a direction.)
export vsaBias(series float h, series float l, series float c, series float v, simple int len, simple int pivLen) =>
    // hoist every event to an UNCONDITIONAL call so the ta.* inside each runs every bar
    int  clx = climax(h, l, c, v, len)
    bool nd  = noDemand(h, l, c, v, len)
    bool ut  = upthrust(h, l, c, v, len, pivLen)
    bool ns  = noSupply(h, l, c, v, len)
    bool sk  = shakeout(h, l, c, v, len, pivLen)
    bool sv  = stoppingVolume(h, l, c, v, len)
    bool bear = nd or ut or clx == -1
    bool bull = ns or sk or sv or clx == 1
    (bull and not bear) ? 1 : (bear and not bull) ? -1 : 0

// Integer CODE of the dominant event (priority: climax > trap > stopping > no-demand/supply >
// absorption > none):  3 up-climax · -3 dn-climax · 2 upthrust · -2 shakeout · -1 stopping ·
// 4 no-demand · -4 no-supply · 5 absorption · 0 none. (Sign is NOT direction here — use vsaBias
// for direction; the code identifies WHICH event, vsaLabel names it.)
export vsaCode(series float h, series float l, series float c, series float v, simple int len, simple int pivLen) =>
    // hoist every event to an UNCONDITIONAL call (their ta.* must run every bar), THEN select
    int  clx = climax(h, l, c, v, len)
    bool ut  = upthrust(h, l, c, v, len, pivLen)
    bool sk  = shakeout(h, l, c, v, len, pivLen)
    bool sv  = stoppingVolume(h, l, c, v, len)
    bool nd  = noDemand(h, l, c, v, len)
    bool ns  = noSupply(h, l, c, v, len)
    bool enr = effortNoResult(h, l, v, len)
    clx == -1 ? 3 : clx == 1 ? -3 : ut ? 2 : sk ? -2 : sv ? -1 : nd ? 4 : ns ? -4 : enr ? 5 : 0

// STRING label of the dominant event, for a dashboard.
export vsaLabel(series float h, series float l, series float c, series float v, simple int len, simple int pivLen) =>
    int code = vsaCode(h, l, c, v, len, pivLen)
    code == 3 ? "Buying climax" : code == -3 ? "Selling climax" : code == 2 ? "Upthrust" : code == -2 ? "Shakeout" : code == -1 ? "Stopping volume" : code == 4 ? "No demand" : code == -4 ? "No supply" : code == 5 ? "Absorption" : "—"

// ══════════════════════════════════════════════════════════════════════════════
// v2 ▸ QUANTIFIED EFFORT-vs-RESULT & THE FOUR-WAY ABSORPTION CONSENSUS
// Absorption can be measured four independent ways; a call is only trustworthy when
// several agree. This block supplies the two VSA-native measures and the consensus that
// fuses them with the two flow measures (OLS residual z from ml_dsp, cost-per-tick pct
// from ml_flow) — the host computes those two and passes them in (no cross-lib import).
// ══════════════════════════════════════════════════════════════════════════════

// RESULT scalar (0..1): how much price ACTUALLY achieved this bar in `dir` (+1 up / -1
// down) — blends body travel and close location. The numeric "result" in effort-vs-result.
export resultScore(series float o, series float h, series float l, series float c, series int dir) =>
    float rng  = math.max(h - l, 1e-9)
    float body = dir > 0 ? math.max(c - o, 0.0) : math.max(o - c, 0.0)
    float clv  = dir > 0 ? (c - l) / rng : (h - c) / rng
    (body / rng + clv) / 2.0

// Net-delta DOMINANCE (−1..1): (buy − sell) / (buy + sell). Feed your signed volumes.
export dominance(series float buyVol, series float sellVol) =>
    float tot = buyVol + sellVol
    tot > 0.0 ? (buyVol - sellVol) / tot : 0.0

// DOMINANCE-minus-RESULT absorption score (the cheapest of the four measures — no
// regression). A side dominated the flow but price under-delivered. Returns
// [score, side]: higher score = more absorption; side +1 = buy-absorption (buyers
// dominant, price stalled), -1 = sell-absorption. Gate with an absolute threshold
// (~0.3) or percentile-rank the score host-side.
export domResultAbsorb(series float buyVol, series float sellVol, series float o, series float h, series float l, series float c) =>
    float net     = dominance(buyVol, sellVol)
    float buyDom  = math.max(net, 0.0)
    float sellDom = math.max(-net, 0.0)
    float buyRes  = resultScore(o, h, l, c, 1)
    float sellRes = resultScore(o, h, l, c, -1)
    float buyAbs  = buyDom - buyRes
    float sellAbs = sellDom - sellRes
    float score   = math.max(buyAbs, sellAbs)
    int   side    = buyAbs >= sellAbs ? 1 : -1
    [score, side]

// Compact EFFORT-vs-RESULT STATE (percentile Effort × Result geometry):
//   1        = Compression / Absorption   (high effort, narrow spread)
//   2 / -2   = Bullish / Bearish Efficiency (high effort, wide spread, closes with move)
//   3 / -3   = Easy Up / Down move         (low effort, wide spread = vacuum)
//   0        = neutral / mixed
export effortResultState(series float h, series float l, series float c, series float v, simple int len) =>
    float sp = spreadPct(h, l, len)
    float vp = volPct(v, len)
    float cp = closePos(h, l, c)
    bool  up = c > c[1]
    int st = 0
    if vp >= 70.0 and sp <= 35.0
        st := 1
    else if vp >= 70.0 and sp >= 60.0
        st := cp >= 0.6 ? 2 : cp <= 0.4 ? -2 : 0
    else if vp <= 35.0 and sp >= 60.0
        st := up ? 3 : -3
    st

// FOUR-WAY ABSORPTION CONSENSUS — the headline U9 upgrade. Counts how many independent
// absorption measures agree on THIS bar; only call it absorption when ≥ minAgree concur:
//   (1) OLS residual z of Δprice on signed flow  — pass from dsp.olsResidZ(dPrice, flow, len)
//   (2) cost-per-tick percentile                 — pass from flow.costPerTickPct(dPrice, flow, len)
//   (3) dominance − result score                 — computed here from buy/sell + o/h/l/c
//   (4) qualitative VSA state == Compression     — computed here (effortResultState == 1)
// Returns [count 0..4, isAbsorb (count ≥ minAgree), side (+1 buy / -1 sell absorption)].
// Non-directional strength with a side hint — take direction from `side` / your delta sign.
export absorptionConsensus(series float residualZ, series float costPct, series float buyVol, series float sellVol, series float o, series float h, series float l, series float c, series float v, simple int len, simple float zThr, simple float costThr, simple float domThr, simple int minAgree) =>
    [domAbs, domSide] = domResultAbsorb(buyVol, sellVol, o, h, l, c)
    int er = effortResultState(h, l, c, v, len)
    int c1 = (not na(residualZ) and residualZ >= zThr)  ? 1 : 0
    int c2 = (not na(costPct)   and costPct   >= costThr) ? 1 : 0
    int c3 = domAbs >= domThr ? 1 : 0
    int c4 = er == 1 ? 1 : 0
    int count = c1 + c2 + c3 + c4
    [count, count >= minAgree, domSide]

// BACKGROUND-BIAS context: rolling net of per-bar vsaBias over `len`. Positive =
// accumulated bullish background, negative = bearish. Gives every event a regime read.
export bgBias(series int vsaBiasVal, simple int len) =>
    math.sum(vsaBiasVal, len)

// ── demo output (library preview only) ──
plot(closePos(high, low, close) * 100.0, "Close position % (demo)", color = color.new(#6f9bd8, 0))
````
