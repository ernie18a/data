<!-- tradingview-pine-id: PUB;582adac9c0ee4d36a54051fb0bd23b68 -->
<!-- tradingviewscripts-format: 1 -->
# Tyson Uppercut Compression Spring Breakout (Viprasol)

Source: https://www.tradingview.com/script/0IHJFTMI-Tyson-Uppercut-Compression-Spring-Breakout-Viprasol/

## Description

Tyson Uppercut — Compression Spring Breakout 🥊 [Viprasol]

(The name is an affectionate combat-sports homage — this is an educational pattern tool, not affiliated with or endorsed by any athlete or organization.)

CONCEPT
A spring loaded by VOLATILITY, not by swings. The tool measures the recent bar-range and requires it to be compressed — noticeably tighter than the window before it (energy coiling). Then the uppercut: one wide-range bar that bursts up out of the compression on the close = the release. Distinct from swing-decay coils; this reads raw range contraction directly from the bars.

HOW IT DETECTS
- Compression is measured on CLOSED bars only: the highest high and lowest low over a window (default 10 bars, offset by one bar).
- That compression range must be tight versus the prior, wider window (default: <= 60% of the range over twice the lookback) AND not larger than a set ATR cap.
- Release: the current bar closes above the compression high, its full bar range is at least a set ATR multiple (default 1.3x ATR), and it closes up (close > open).
- All logic runs on bar close (barstate.isconfirmed). An optional dotted live box previews an active compression before any break.

ENTRY / STOP / TARGET
- Entry: on the confirmed release close (long only).
- Stop: below the compression low, minus an ATR buffer.
- Target: entry + R multiple of risk (default 2R, adjustable).
- Drawn as a solid compression box plus an entry line and filled TP/SL zones that extend right until price touches one; the hit side thickens.

NON-REPAINTING
Compression is read from already-closed bars (a one-bar offset is used), and the release is confirmed on the bar close. A printed signal does not move or disappear afterward. The live dotted preview is informational only and is not a signal.

KEY FEATURES
- Volatility-compression detection from raw range, with an ATR height cap to avoid oversized "boxes".
- Release requires a genuinely wide breakout bar, not just a marginal close.
- Optional live compression preview; option to hide new setups while a trade is active.
- Filled, extend-until-hit TP/SL zones and an on-chart status table (open trades). Alert condition included.

INPUTS OVERVIEW
- The spring: compression window (bars), tightness fraction vs prior window, max compression height (x ATR), release bar range (x ATR), ATR length.
- The knockout: TP as R multiple, SL buffer (x ATR), minimum bars between signals, one-trade-at-a-time, hide-setup-while-in-trade.
- Visuals: compression box / entry / TP / SL colors, label offset, zone transparency, show-live toggle.

HOW TO USE
1. Add to a liquid symbol and timeframe; it is fully overlay-based.
2. Set the compression window and tightness fraction to define how coiled the range must be.
3. Raise the release ATR multiple to demand a stronger breakout bar.
4. Watch the live dotted box to anticipate setups, and study the TP/SL zones on your instrument.
5. Optionally create an alert from the built-in condition.

LIMITATIONS (read this)
- This is a pattern/education tool, not a signal service and not financial advice. It does not predict the future.
- Compression breakouts frequently fail or reverse (false breakouts are common), especially in ranging markets.
- It is long-only by design; it does not trade downside releases.
- Range readings depend on the chosen windows; different settings can materially change what counts as "compressed".
- Results depend heavily on your inputs, instrument, and timeframe. Always use your own risk management and discretion.

CREDITS
ATR uses Wilder's Average True Range. Highest/lowest range measurement uses standard public functions (ta.highest / ta.lowest). The raw-range compression-and-release detection and the trade-zone visualization are original Viprasol design.

Original Viprasol work; no third-party Pine code reused.

---

## Source Code

````pine
//@version=6
// Tyson Uppercut — "Compression Spring Breakout" 🥊  ·  Viprasol   ·  ORIGINAL geometry (long)
// ─────────────────────────────────────────────────────────────────────────────
// The idea: a spring loaded by VOLATILITY, not swings. We measure the recent bar-range and
// require it to be compressed — much tighter than the window before it (energy coiling). Then
// the uppercut: one wide-range bar that bursts up out of the compression = the release → LONG.
// Distinct from the Helix Coil (which decays swing legs); this measures raw range contraction.
// Pure geometry. Non-repainting (range read from closed bars; entry on bar close).
// Draws the compression box + the breakout. Filled TP/SL zones extend until hit.
indicator("Tyson Uppercut Compression Spring Breakout (Viprasol)", "Tyson", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=200)

// ── The spring (range compression) ───────────────────────
gA = "The spring (range compression)"
compLen    = input.int(10,  "Compression window (bars)", minval=3, group=gA)
compFrac   = input.float(0.6,"Tight ≤ this × prior window", minval=0.2, step=0.05, group=gA)
maxCompATR = input.float(3.0,"Max compression height (× ATR)", minval=0.5, step=0.1, group=gA)
expMult    = input.float(1.3,"Release bar range ≥ (× ATR)", minval=0.3, step=0.1, group=gA)
atrLen     = input.int(14,  "ATR length", minval=1, group=gA)

// ── The knockout (entry & exits) ─────────────────────────
gE = "The knockout (entry & exits)"
rr         = input.float(2.0, "TP = R multiple (× risk)", minval=0.5, step=0.5, group=gE)
slBuf      = input.float(0.3, "SL buffer (× ATR)", minval=0.0, step=0.1, group=gE)
sigGap     = input.int(15,   "Min bars between signals", minval=0, group=gE)
oneAtATime = input.bool(true, "One trade at a time", group=gE)
hideSetupInTrade = input.bool(true, "Hide new setup while a trade is active", group=gE)

// ── Visuals ──────────────────────────────────────────────
gV = "Visuals"
cBox   = input.color(color.new(#ef5350,0), "Compression box", group=gV)
cEntry = input.color(color.blue,   "Entry line", group=gV)
cTP    = input.color(color.green,  "TP zone", group=gV)
cSL    = input.color(color.red,    "SL zone", group=gV)
labelOff= input.float(1.0, "Label offset (× ATR)", minval=0.0, step=0.1, group=gV)
zoneTrans= input.int(85, "TP/SL zone fill transparency (0-100)", minval=0, maxval=100, group=gV)
showLive= input.bool(true, "Show live compression (dotted)", group=gV)

atr = ta.atr(atrLen)
var int lastSig = -100000

// ── Compression measured on closed bars (non-repaint) ────
compHigh  = ta.highest(high[1], compLen)
compLow   = ta.lowest(low[1],  compLen)
compRange = compHigh - compLow
wideRange = ta.highest(high[1], compLen * 2) - ta.lowest(low[1], compLen * 2)
compressed = compRange > 0 and compRange <= compFrac * wideRange and compRange <= maxCompATR * atr
release    = close > compHigh and (high - low) >= expMult * atr and close > open

// ── Trade scaffold (filled TP/SL zones, extend-until-hit) ─
var array<line>  tEntry = array.new<line>()
var array<box>   tTPb   = array.new<box>()
var array<box>   tSLb   = array.new<box>()
var array<float> tTPl   = array.new_float()
var array<float> tSLl   = array.new_float()

openTrades = array.size(tTPl)
blocked    = oneAtATime and openTrades > 0

// live compression preview
var box liveBox = na
if showLive
    if not na(liveBox)
        box.delete(liveBox)
        liveBox := na
    if compressed and not blocked and not (hideSetupInTrade and openTrades > 0)
        liveBox := box.new(bar_index - compLen, compHigh, bar_index, compLow, xloc=xloc.bar_index, border_color=color.new(cBox, 40), border_style=line.style_dotted, bgcolor=color.new(cBox, 92))

sig = compressed and release and not blocked and (bar_index - lastSig) > sigGap and barstate.isconfirmed

if sig
    lastSig := bar_index
    entry   = close
    slLvl   = compLow - atr * slBuf
    tpLvl   = entry + rr * (entry - slLvl)
    box.new(bar_index - compLen, compHigh, bar_index, compLow, xloc=xloc.bar_index, border_color=color.new(cBox, 0), bgcolor=color.new(cBox, 88))
    label.new(bar_index, low - atr * labelOff, "UPPERCUT 🥊", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(color.green, 0), textcolor=color.white, size=size.normal)
    array.push(tEntry, line.new(bar_index, entry, bar_index, entry, xloc=xloc.bar_index, color=color.new(cEntry, 0), width=1))
    array.push(tTPb,   box.new(bar_index, math.max(entry, tpLvl), bar_index, math.min(entry, tpLvl), xloc=xloc.bar_index, border_color=color.new(cTP, 0), border_width=1, bgcolor=color.new(cTP, zoneTrans)))
    array.push(tSLb,   box.new(bar_index, math.max(entry, slLvl), bar_index, math.min(entry, slLvl), xloc=xloc.bar_index, border_color=color.new(cSL, 0), border_width=1, bgcolor=color.new(cSL, zoneTrans)))
    array.push(tTPl,   tpLvl)
    array.push(tSLl,   slLvl)

if barstate.isconfirmed and array.size(tTPl) > 0
    idx = array.size(tTPl) - 1
    while idx >= 0
        le = array.get(tEntry, idx)
        bt = array.get(tTPb, idx)
        bs = array.get(tSLb, idx)
        tp = array.get(tTPl, idx)
        sl = array.get(tSLl, idx)
        line.set_x2(le, bar_index)
        box.set_right(bt, bar_index)
        box.set_right(bs, bar_index)
        hitTP = high >= tp
        hitSL = low  <= sl
        if hitTP or hitSL
            box.set_border_width(hitTP ? bt : bs, 2)
            array.remove(tEntry, idx)
            array.remove(tTPb, idx)
            array.remove(tSLb, idx)
            array.remove(tTPl, idx)
            array.remove(tSLl, idx)
        idx := idx - 1

alertcondition(sig, "Tyson Compression Spring", "Tyson Uppercut — compression spring (buy) on {{ticker}}")

var table tb = table.new(position.top_right, 1, 2, border_width=1)
if barstate.islast
    table.cell(tb, 0, 0, "Tyson · Compression Spring 🥊", bgcolor=color.new(color.green, 0), text_color=color.white, text_size=size.small)
    table.cell(tb, 0, 1, "Open trades: " + str.tostring(array.size(tTPl)), bgcolor=color.new(color.black, 20), text_color=color.white, text_size=size.small)
````
