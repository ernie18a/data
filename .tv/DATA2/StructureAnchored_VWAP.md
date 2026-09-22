<!-- tradingview-pine-id: PUB;00db7ec4d8ca4028b4f69292ed785f01 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Structure-Anchored VWAP

Source: https://www.tradingview.com/script/lN4zjm3D-Structure-Anchored-VWAP/

## Description

Structure-Anchored VWAP — a VWAP that re-anchors to market structure, not the clock

A normal VWAP resets on a fixed session — the day, the week. But the level that matters is rarely the one measured from midnight; it's the one measured from the move you're actually trading: the last change of character, the last break of structure, the last liquidity sweep. Structure-Anchored VWAP resets its cumulative volume-weighted average price from the structural event YOU choose, so the mean / value line is always measured from what is driving price right now.

It's a value / mean-reference tool — a place to read where "fair value" sits for the current leg and how stretched price is from it. Free and open-source. Please read the honest note below — it makes no win-rate or profit claims.

── WHAT IT DOES ──────────────────────────────────────────

1) STRUCTURE-CHOSEN ANCHOR
   Pick the event that resets the VWAP (clears its cumulative price×volume sums and starts fresh from that bar):
   • Last CHoCH — the first break AGAINST the prevailing trend (change of character).
   • Last BOS — a break of structure in the trend direction (continuation).
   • Last liquidity sweep — a wick past the latest swing high/low that closes back inside (a stop-hunt).
   • Session start — the beginning of each session on a timeframe you set (D / W / …).
   • Any structure shift — whichever of BOS / CHoCH / sweep prints first.
   Every structural event is confirmed on bar close — it does not repaint.

2) MANUAL CUMULATIVE VWAP
   The line is a true anchored VWAP built by hand — Σ(price×volume) / Σ(volume) accumulated from the anchor bar forward — not the fixed session VWAP. Source is selectable (hlc3 default, or close / ohlc4 / hl2). On symbols with no volume, it falls back to an equal-weight average so the line still means something.

3) DEVIATION BANDS (±1σ / ±2σ)
   Inner and outer bands drawn from the volume-weighted standard deviation of price around the anchored VWAP (classic VWAP bands), shown as a shaded envelope. Bands are naturally tight right after an anchor and widen as the leg develops. Both multipliers are adjustable.

4) ANCHOR MARKERS
   A small ⚓ marker drops on every re-anchor, naming the event (BOS ▲/▼, CHoCH ▲/▼, Sweep ▲/▼, Session), so you can see exactly where and why the VWAP reset.

── HOW TO USE IT ─────────────────────────────────────────
• Value reference: the anchored VWAP is a running "fair value" for the current leg. Price trading back to it after an extension is a mean-reference event — where responsive participants often reappear.
• Bands as context: the outer band flags a statistically stretched excursion from the leg's mean. That's context for a decision, not a signal to fade — strong trends can ride an outer band.
• Anchor choice matters: a CHoCH anchor frames value from the last shift in character; a sweep anchor frames it from the last stop-hunt; a session anchor gives a classic session value line. Match the anchor to the question you're asking.

── NON-REPAINTING ────────────────────────────────────────
By the nature of a VWAP, the line and its bands UPDATE LIVE on the developing (unclosed) bar — that is expected and correct; a VWAP is a running average that finalises when the bar closes. The ANCHOR events that reset it are confirmed on bar close (barstate.isconfirmed) using closed-bar swing pivots, so they do not repaint — an anchor doesn't appear and then move once set.

Free & open-source (MPL-2.0). For research and education. Not financial advice; no guarantee of profit. Test on your own markets and manage your own risk.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © zebris_boris
//
// ──────────────────────────────────────────────────────────────
//  Structure-Anchored VWAP  ·  v1.0  ·  Boris Tatchou
// ──────────────────────────────────────────────────────────────
//  A VWAP that RE-ANCHORS to market structure instead of the clock.
//  A normal VWAP resets on a fixed session (the day, the week). But
//  the level that matters is usually measured from the move you are
//  actually trading — the last change of character, break of
//  structure, or liquidity sweep. This tool resets its cumulative
//  volume-weighted average price from the structural event you pick,
//  so the mean / value line is always measured from what is driving
//  price right now.
//    • Pick the anchor — last CHoCH, last BOS, last liquidity sweep,
//      a session start, or any structure shift.
//    • Manual cumulative VWAP (Σ price*vol / Σ vol), reset at anchor.
//    • ±1σ / ±2σ volume-weighted deviation bands.
//    • A small ⚓ marker on every re-anchor.
//
//  HONEST NOTE: VWAP is a genuine value / mean-reference measure —
//  price tends to trade around it and revert toward it — but this
//  tool makes NO win-rate or profit claims. The VWAP and its bands
//  update live on the developing bar by design (that is what a VWAP
//  is); the anchor events that reset it are confirmed on bar close
//  and do not repaint. Research / education — not financial advice.
//  Free & open-source.
// ──────────────────────────────────────────────────────────────
//@version=6
indicator("Structure-Anchored VWAP", "SA-VWAP", overlay = true, max_labels_count = 500)

// ── Inputs ─────────────────────────────────────────────────
g1 = "① Anchor"
g2 = "② VWAP & bands"
g3 = "③ Colors"

anchorMode = input.string("Last CHoCH", "Anchor event", options = ["Last CHoCH", "Last BOS", "Last liquidity sweep", "Session start", "Any structure shift"], group = g1, tooltip = "The structural event that RE-ANCHORS the VWAP (resets its cumulative sums from that bar):\n• Last CHoCH — first break against the prevailing trend (change of character).\n• Last BOS — a break of structure in the trend direction (continuation).\n• Last liquidity sweep — a wick past the latest swing that closes back inside (stop-hunt).\n• Session start — the start of each session on the timeframe below.\n• Any structure shift — whichever of BOS / CHoCH / sweep comes first.\nAll structure events confirm on bar close (non-repainting).")
swingLen   = input.int(10, "Swing length", minval = 2, maxval = 50, group = g1, tooltip = "Pivot look-back that defines structure swings and sweep levels. Larger = only major structure re-anchors.")
breakBuf   = input.float(0.05, "Break confirmation (x ATR)", minval = 0.0, maxval = 5.0, step = 0.05, group = g1, tooltip = "Extra distance beyond the swing (in ATR) that price must close through to count as a BOS / CHoCH.")
sessTf     = input.timeframe("D", "Session timeframe", group = g1, tooltip = "Used when Anchor event = Session start. D = daily session, W = weekly, etc.")
showMarkers= input.bool(true, "Anchor markers", group = g1)
maxMarkers = input.int(20, "Max anchor markers", minval = 1, maxval = 100, group = g1, tooltip = "Old markers are removed once this many are on the chart (bounded pool).")

srcSel   = input.string("hlc3", "VWAP source", options = ["hlc3", "close", "ohlc4", "hl2"], group = g2)
showBands= input.bool(true, "Show deviation bands (±1σ / ±2σ)", group = g2)
mult1    = input.float(1.0, "Inner band ×σ", minval = 0.1, maxval = 10.0, step = 0.1, group = g2)
mult2    = input.float(2.0, "Outer band ×σ", minval = 0.1, maxval = 10.0, step = 0.1, group = g2)
fillBands= input.bool(true, "Shade band area", group = g2)

vwapCol    = input.color(#2962ff, "VWAP line", group = g3)
colorByBias= input.bool(false, "Colour VWAP by side (above / below)", group = g3, tooltip = "Colour the line by whether price is above (bull) or below (bear) it, instead of a single colour.")
upCol      = input.color(#26a69a, "Above / bullish", group = g3)
dnCol      = input.color(#ef5350, "Below / bearish", group = g3)

cNeu = color.rgb(198, 203, 212)

// ── Structure / anchor detection ───────────────────────────
// Returns [reset, event, trend].  event codes:
//   1 BOS▲  -1 BOS▼   2 CHoCH▲  -2 CHoCH▼   3 sweep-high(bearish)  -3 sweep-low(bullish)   4 session
f_reset(int _mode, int _swing, float _brk, string _sessTf) =>
    float _atr = ta.atr(14)
    float _ph  = ta.pivothigh(high, _swing, _swing)
    float _pl  = ta.pivotlow(low, _swing, _swing)
    var float _msH = na
    var float _msL = na
    var bool  _msHb = true
    var bool  _msLb = true
    var int   _trend = 0
    if not na(_ph)
        _msH := _ph
        _msHb := false
    if not na(_pl)
        _msL := _pl
        _msLb := false
    bool _bosUp = not na(_msH) and not _msHb and close > _msH + _brk * _atr and barstate.isconfirmed
    bool _bosDn = not na(_msL) and not _msLb and close < _msL - _brk * _atr and barstate.isconfirmed
    var float _th1 = na
    var float _tl1 = na
    var bool  _thSw = false
    var bool  _tlSw = false
    if not na(_ph)
        _th1 := _ph
        _thSw := false
    if not na(_pl)
        _tl1 := _pl
        _tlSw := false
    bool _swHi = not na(_th1) and not _thSw and high > _th1 and close < _th1 and barstate.isconfirmed
    bool _swLo = not na(_tl1) and not _tlSw and low  < _tl1 and close > _tl1 and barstate.isconfirmed
    if _swHi
        _thSw := true
    if _swLo
        _tlSw := true
    int _evt = 0
    if _bosUp
        _evt := _trend == -1 ? 2 : 1
        _trend := 1
        _msHb := true
    if _bosDn
        _evt := _trend == 1 ? -2 : -1
        _trend := -1
        _msLb := true
    int _swEvt = _swHi ? 3 : _swLo ? -3 : 0
    bool _sess = timeframe.change(_sessTf)
    bool _isChoch = _evt == 2 or _evt == -2
    bool _isBos   = _evt == 1 or _evt == -1
    bool _isSweep = _swEvt != 0
    bool _reset = _mode == 1 ? _isChoch : _mode == 2 ? _isBos : _mode == 3 ? _isSweep : _mode == 4 ? _sess : (_isBos or _isChoch or _isSweep)
    int _anchEvt = 0
    if _reset
        _anchEvt := _mode == 4 ? 4 : _isChoch ? _evt : _isBos ? _evt : _isSweep ? _swEvt : 0
    [_reset, _anchEvt, _trend]

// ── Anchored VWAP accumulation (cumulative Σpv/Σv, volume-weighted σ) ─
f_accum(bool _reset, float _src, float _vol, float _atr, int _bandMode, float _m1, float _m2) =>
    var float _cumV  = 0.0
    var float _cumPV = 0.0
    var float _cumP2 = 0.0
    if _reset
        _cumV  := 0.0
        _cumPV := 0.0
        _cumP2 := 0.0
    _cumV  := _cumV + _vol
    _cumPV := _cumPV + _src * _vol
    _cumP2 := _cumP2 + _src * _src * _vol
    float _v   = _cumV > 0 ? _cumPV / _cumV : _src
    float _var = _cumV > 0 ? math.max(0.0, _cumP2 / _cumV - _v * _v) : 0.0
    float _sd  = math.sqrt(_var)
    float _b1  = _bandMode == 1 ? _m1 * _sd : _m1 * _atr
    float _b2  = _bandMode == 1 ? _m2 * _sd : _m2 * _atr
    [_v, _v + _b1, _v - _b1, _v + _b2, _v - _b2, _sd]

// ── Resolve inputs → numbers ───────────────────────────────
srcSelN = srcSel == "close" ? 1 : srcSel == "ohlc4" ? 2 : srcSel == "hl2" ? 3 : 0
src     = srcSelN == 1 ? close : srcSelN == 2 ? ohlc4 : srcSelN == 3 ? hl2 : hlc3
atr     = ta.atr(14)
modeN   = anchorMode == "Last CHoCH" ? 1 : anchorMode == "Last BOS" ? 2 : anchorMode == "Last liquidity sweep" ? 3 : anchorMode == "Session start" ? 4 : 5

var bool volSeen = false
if not na(volume) and volume > 0
    volSeen := true
vol = volSeen ? (na(volume) ? 0.0 : volume) : 1.0

// ── Anchored VWAP (live on the developing bar) ─────────────
[rst, evt, _tr] = f_reset(modeN, swingLen, breakBuf, sessTf)
[v, u1, l1, u2, l2, _sd] = f_accum(rst, src, vol, atr, 1, mult1, mult2)

// ── Plots: VWAP + bands ────────────────────────────────────
centerCol = colorByBias ? (close >= v ? upCol : dnCol) : vwapCol
plot(v, "Anchored VWAP", color = color.new(centerCol, 0), linewidth = 2)
pU1 = plot(showBands ? u1 : na, "Inner band +", color = color.new(vwapCol, 55))
pL1 = plot(showBands ? l1 : na, "Inner band -", color = color.new(vwapCol, 55))
pU2 = plot(showBands ? u2 : na, "Outer band +", color = color.new(vwapCol, 70))
pL2 = plot(showBands ? l2 : na, "Outer band -", color = color.new(vwapCol, 70))
fill(pU1, pL1, showBands and fillBands ? color.new(vwapCol, 91) : na, title = "Inner fill")
fill(pU2, pU1, showBands and fillBands ? color.new(vwapCol, 95) : na, title = "Upper outer fill")
fill(pL1, pL2, showBands and fillBands ? color.new(vwapCol, 95) : na, title = "Lower outer fill")

// ── Anchor markers (bounded label pool) ────────────────────
var label[] anchLabels = array.new<label>()
if showMarkers and rst and barstate.isconfirmed
    _lbl = evt == 1 ? "⚓ BOS ▲" : evt == -1 ? "⚓ BOS ▼" : evt == 2 ? "⚓ CHoCH ▲" : evt == -2 ? "⚓ CHoCH ▼" : evt == 3 ? "⚓ Sweep ▼" : evt == -3 ? "⚓ Sweep ▲" : evt == 4 ? "⚓ Session" : "⚓ Anchor"
    _above = evt == -1 or evt == -2 or evt == 3
    _mcol  = (evt == 1 or evt == 2 or evt == -3) ? upCol : (evt == -1 or evt == -2 or evt == 3) ? dnCol : cNeu
    _lb = label.new(bar_index, _above ? high : low, _lbl, xloc = xloc.bar_index, style = _above ? label.style_label_down : label.style_label_up, color = color.new(_mcol, 12), textcolor = color.white, size = size.small)
    array.push(anchLabels, _lb)
    if array.size(anchLabels) > maxMarkers
        label.delete(array.shift(anchLabels))

// ── Alerts (non-repaint: evaluate on bar close) ────────────
// Suppress the cross the instant the VWAP re-anchors — that jump is a
// reset artifact, not a genuine price/VWAP cross.
vwapCross = ta.cross(close, v) and not rst
alertcondition(rst,       "New anchor set", "SA-VWAP: new structure anchor set on {{ticker}} ({{interval}})")
alertcondition(vwapCross, "VWAP cross",     "SA-VWAP: price crossed the anchored VWAP on {{ticker}} ({{interval}})")
````
