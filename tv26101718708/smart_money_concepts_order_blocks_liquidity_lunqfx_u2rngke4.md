# Smart Money Concepts  Order Blocks, Liquidity [LunqFX]

- url: https://www.tradingview.com/script/u2RNGKe4-Smart-Money-Concepts-Order-Blocks-Liquidity-LunqFX/
- type: indicator
- pine_id: PUB;b1efb73a82dc4b38a81b4f22deea1d8e
- version: 1.0

## Description

Smart Money Concepts — Order Blocks & Liquidity [LunqFX]

A professional-grade SMC indicator that answers the three 
questions every trader needs before entering a trade:
① What is the current trend?
② Where is the key institutional zone?
③ Is price at that zone right now?


📋 HOW TO USE — STEP BY STEP

The indicator works as a 3-step confirmation system.
Do not enter a trade unless all 3 align.

STEP 1 — READ THE TREND (panel header)

Look at the panel in the top-right corner.

▲ BULLISH → only look for LONG setups
▼ BEARISH → only look for SHORT setups

If the gauge bar shows less than 40% or more than 60% 
— the bias is strong. Between 40–60% = no clear edge, 
reduce position size or wait.

STEP 2 — WAIT FOR STRUCTURE EVENT

• BOS appears  →  trend continuation confirmed.
  The market broke a key level and is likely to continue.
  Look for entries in the direction of the break.

• CHoCH appears  →  trend is reversing.
  This is the earliest signal of a new trend forming.
  Higher risk, higher reward — wait for Step 3 to confirm.

Rule: never trade against the last structure signal.

STEP 3 — WAIT FOR PRICE TO RETURN TO THE OB ZONE

After BOS or CHoCH fires, an Order Block zone is drawn 
on the chart (blue = bullish, pink = bearish).

Wait for price to pull back INTO that zone.

When price enters the zone:
  → The zone border brightens (active glow effect)
  → The panel "Zone" row shows ▲ BULL OB or ▼ BEAR OB
  → Candle color changes to the zone color

This is your entry window.

✅ FULL SETUP EXAMPLE (LONG)

[image]https://www.tradingview.com/x/8u9wdk1d/[/image]

1. Panel shows ▲ BULLISH
2. CHoCH or BOS fires bullish — structure confirmed
3. Blue Order Block zone is drawn below current price
4. Price pulls back into the blue zone
5. Panel Zone row shows "▲ BULL OB"
6. Enter long — Stop Loss below the OB zone bottom
7. Target: next swing high or previous resistance

✅ FULL SETUP EXAMPLE (SHORT)

1. Panel shows ▼ BEARISH
2. BOS fires bearish — downtrend continuation
3. Pink Order Block zone is drawn above current price
4. Price pulls back up into the pink zone
5. Panel Zone row shows "▼ BEAR OB"
6. Enter short — Stop Loss above the OB zone top
7. Target: next swing low or previous support

⚠️ WHAT TO AVOID

✗ Don't enter on the BOS/CHoCH candle itself — 
  wait for the pullback to the OB zone

✗ Don't trade a swept (faded/dashed) zone — 
  it was already mitigated, its edge is gone

✗ Don't fight the trend — if panel says BEARISH, 
  don't look for longs no matter how good it looks

✗ High ATR (volatile) = widen your stop loss 
  or reduce position size accordingly

🔷 ORDER BLOCKS
Automatically detects bullish and bearish Order Blocks — 
the last opposing candle before a Break of Structure. 
Zones use a 2-band gradient (dense core + lighter outer) 
to visualize institutional demand and supply areas.

• Active glow: border brightens when price enters the zone
• Swept zones: automatically fade to dashed when mitigated
• Age-based cleanup: old zones removed after set bar count
• Mitigation mode: choose Close or Wick for zone removal

📐 BREAK OF STRUCTURE (BOS) & CHANGE OF CHARACTER (CHoCH)

BOS confirms trend continuation. CHoCH signals a trend 
reversal. Only the most recent signal is displayed — 
CHoCH automatically clears stale BOS, and BOS clears 
stale CHoCH. No visual clutter.

• BOS: dashed line at broken structure level
• CHoCH: solid line with arrow label at pivot bar
• No repaint: all signals fire on confirmed closed candles only

💧 LIQUIDITY — Equal Highs / Equal Lows

Detects EQH and EQL liquidity pools — price levels where 
stop-losses cluster. Marks them with dotted lines so you 
can anticipate smart money liquidity sweeps.

⚡ FAIR VALUE GAPS (FVG)

Identifies bullish and bearish imbalance zones (3-candle 
gaps). Optional — hidden by default to keep the chart clean. 
Enable in settings when imbalance confluences matter.

🎨 MOMENTUM GRADIENT CANDLES
Every candle is colored by momentum strength relative to 
the last 30 bars. Weak candles = dark muted shade. Strong 
impulse candles = vivid bright color. Structure events 
(CHoCH/BOS) override with accent colors.

📊 LIVE DASHBOARD PANEL

[image]https://www.tradingview.com/x/mtugQQ8X/[/image]

Top-right panel shows at a glance:
• Trend bias (BULLISH / BEARISH) + visual gauge bar
• Last BOS and CHoCH direction and time
• Current zone status (price inside OB?)
• Active Order Block count per side
• Last confirmed Swing High and Swing Low prices
• ATR(14) with volatility label (LOW / NORMAL / HIGH)
• No Repaint confirmation

✅ NO REPAINT — CONFIRMED CLOSE ONLY

All pivot detections use ta.pivothigh() / ta.pivotlow() 
with confirmed lookback. All BOS/CHoCH signals require 
barstate.isconfirmed. What you see is what happened — 
no repainting, no false signals on open candles.

⚙️ SETTINGS

Structure:
  • Swing Length (3–30 bars)
  • Max BOS / CHoCH lines shown
  • BOS line length
  • Show/hide swing pivot markers

Order Blocks:
  • Max OBs per side
  • Max age in bars
  • Swept zone display + age
  • Mitigation mode: Close or Wick

Display:
  • Momentum candle coloring on/off
  • Dashboard panel on/off
  • Fair Value Gaps on/off
  • Equal H/L liquidity on/off

Works on all instruments and timeframes.
Best used on: Forex, Gold (XAUUSD), Indices, Crypto.
Recommended timeframes: 15m, 30m, 1H, 4H, 1D.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
// © LunqFX
//@version=6
indicator("Smart Money Concepts — Order Blocks & Liquidity [LunqFX] v3",
          shorttitle="SMC·LFX", overlay=true,
          max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpSTR     = "Structure"
swingLen   = input.int(10,    "Swing Length",           minval=3, maxval=30,   group=grpSTR)
showBOS    = input.bool(true, "Show BOS / CHoCH",                              group=grpSTR)
showSwg    = input.bool(true, "Show Swing Points",                             group=grpSTR)
maxBOS     = input.int(1,     "Max BOS Lines",          minval=1, maxval=10,   group=grpSTR)
maxCHoCH   = input.int(1,     "Max CHoCH Lines",        minval=1, maxval=8,    group=grpSTR)
bosLineLen = input.int(40,    "BOS Line Length (bars)", minval=5, maxval=200,   group=grpSTR)

grpOB      = "Order Blocks"
showOB     = input.bool(true,      "Show Order Blocks",                        group=grpOB)
showSwept  = input.bool(true,      "Show Swept Zones",                         group=grpOB)
obMaxAge   = input.int(300,        "Max Age (bars)",    minval=20, maxval=500,  group=grpOB)
sweptAge   = input.int(80,         "Swept Zone Age",    minval=20, maxval=300,  group=grpOB)
maxOBs     = input.int(1,          "Max per side",      minval=1,  maxval=5,   group=grpOB)
obMit      = input.string("Close", "Mitigation",        options=["Close","Wick"], group=grpOB)

grpFVG     = "Fair Value Gap"
showFVG    = input.bool(false, "Show FVG",                                     group=grpFVG)
fvgAge     = input.int(100,   "Max Age (bars)",         minval=10, maxval=300,  group=grpFVG)
fvgFill    = input.bool(true, "Hide when filled",                              group=grpFVG)

grpLIQ     = "Liquidity"
showLiq    = input.bool(false, "Show Equal H/L",                               group=grpLIQ)
eqPct      = input.float(0.08, "Threshold %",           minval=0.01, step=0.01, group=grpLIQ)
maxLiq     = input.int(3,      "Max per side",           minval=1, maxval=5,   group=grpLIQ)

grpVIS     = "Display"
showCndl   = input.bool(true, "Color Candles",                                 group=grpVIS)
showPanel  = input.bool(true, "Show Panel",                                    group=grpVIS)

// ══════════════════════════════════════════════════════════════════════════════
//  PALETTE
// ══════════════════════════════════════════════════════════════════════════════
C_OB_BULL        = #6366F1
C_OB_ACCENT_BULL = #818CF8
C_OB_BEAR        = #EC4899
C_OB_ACCENT_BEAR = #F472B6
C_BOS            = #FBBF24
C_CHOCH          = #A78BFA
C_EQH            = #22D3EE
C_EQL            = #FB923C
C_SWG_H          = #67E8F9
C_SWG_L          = #FCD34D

// ══════════════════════════════════════════════════════════════════════════════
//  ATR  (top-level)
// ══════════════════════════════════════════════════════════════════════════════
atr14    = ta.atr(14)
atrSma50 = ta.sma(atr14, 50)
_atrV    = str.tostring(atr14, format.mintick)
_atrLbl  = atr14 > atrSma50 * 1.5 ? "HIGH" : atr14 > atrSma50 * 0.8 ? "NORMAL" : "LOW"
_atrHot  = atr14 > atrSma50 * 1.5

// ══════════════════════════════════════════════════════════════════════════════
//  SWING DETECTION — confirmed pivots (no repaint)
// ══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,   swingLen, swingLen)

var float lastPH    = na
var int   lastPHBar = na
var float lastPL    = na
var int   lastPLBar = na
var float prevPH    = na
var float prevPL    = na

if not na(ph)
    prevPH    := lastPH
    lastPH    := ph
    lastPHBar := bar_index[swingLen]
if not na(pl)
    prevPL    := lastPL
    lastPL    := pl
    lastPLBar := bar_index[swingLen]

// ── Swing pivot dot markers — ◆ placed at actual pivot bar
var label[] swgHLbs = array.new<label>()
var label[] swgLLbs = array.new<label>()

// Swing pivot diamonds — kept to 20 most-recent per side to avoid clutter
if showSwg and not na(ph)
    _lb = label.new(bar_index[swingLen], ph + atr14 * 0.25, "◆",
                    style=label.style_none, textcolor=color.new(C_SWG_H, 0), size=size.normal)
    array.push(swgHLbs, _lb)
    if array.size(swgHLbs) > 20
        label.delete(array.shift(swgHLbs))

if showSwg and not na(pl)
    _lb = label.new(bar_index[swingLen], pl - atr14 * 0.25, "◆",
                    style=label.style_none, textcolor=color.new(C_SWG_L, 0), size=size.normal)
    array.push(swgLLbs, _lb)
    if array.size(swgLLbs) > 20
        label.delete(array.shift(swgLLbs))

// ══════════════════════════════════════════════════════════════════════════════
//  STRUCTURE — BOS / CHoCH
// ══════════════════════════════════════════════════════════════════════════════
var bool isBullTrend  = true
var int  bullBOSCount = 0
var int  bearBOSCount = 0

bosBull   = barstate.isconfirmed and not na(lastPH) and close > lastPH and close[1] <= lastPH
bosBear   = barstate.isconfirmed and not na(lastPL) and close < lastPL and close[1] >= lastPL
chochBull = bosBull and not isBullTrend
chochBear = bosBear and isBullTrend

if bosBull
    isBullTrend  := true
    bullBOSCount += 1
if bosBear
    isBullTrend  := false
    bearBOSCount += 1

var line[]  bosLines  = array.new<line>()
var label[] bosLabels = array.new<label>()
var line[]  cchLines  = array.new<line>()
var label[] cchLabels = array.new<label>()

if showBOS
    // ── Bullish BOS (trend continuation — NOT a reversal)
    if bosBull and not chochBull and not na(lastPHBar)
        // BOS fires: wipe any stale CHoCH visuals — only one structure signal at a time
        for _cl in cchLines
            line.delete(_cl)
        for _clb in cchLabels
            label.delete(_clb)
        array.clear(cchLines)
        array.clear(cchLabels)
        _ln = line.new(lastPHBar, lastPH, bar_index + bosLineLen, lastPH,
                       color=color.new(C_BOS, 10), style=line.style_dashed, width=2)
        _lb = label.new(bar_index, lastPH + atr14 * 1.1, "BOS",
                        style=label.style_label_down,
                        color=color.new(C_BOS, 10), textcolor=color.new(#0A0A14, 0), size=size.small)
        array.push(bosLines,  _ln)
        array.push(bosLabels, _lb)
        if array.size(bosLines) > maxBOS
            line.delete(array.shift(bosLines))
            label.delete(array.shift(bosLabels))

    // ── Bearish BOS (trend continuation — NOT a reversal)
    if bosBear and not chochBear and not na(lastPLBar)
        for _cl in cchLines
            line.delete(_cl)
        for _clb in cchLabels
            label.delete(_clb)
        array.clear(cchLines)
        array.clear(cchLabels)
        _ln = line.new(lastPLBar, lastPL, bar_index + bosLineLen, lastPL,
                       color=color.new(C_BOS, 10), style=line.style_dashed, width=2)
        _lb = label.new(bar_index, lastPL - atr14 * 1.1, "BOS",
                        style=label.style_label_up,
                        color=color.new(C_BOS, 10), textcolor=color.new(#0A0A14, 0), size=size.small)
        array.push(bosLines,  _ln)
        array.push(bosLabels, _lb)
        if array.size(bosLines) > maxBOS
            line.delete(array.shift(bosLines))
            label.delete(array.shift(bosLabels))

    // ── Bullish CHoCH (reversal — supersedes any pending BOS)
    if chochBull and not na(lastPHBar)
        // CHoCH fires: wipe stale BOS visuals — CHoCH overrides continuation signal
        for _bl in bosLines
            line.delete(_bl)
        for _blb in bosLabels
            label.delete(_blb)
        array.clear(bosLines)
        array.clear(bosLabels)
        _ln = line.new(lastPHBar, lastPH, bar_index + bosLineLen, lastPH,
                       color=color.new(C_CHOCH, 0), style=line.style_solid, width=2)
        // CHoCH label at pivot bar — 1.6 ATR above to clear the swing ◆ marker
        _lb = label.new(lastPHBar, lastPH + atr14 * 1.6, "⬆ CHoCH",
                        style=label.style_none, textcolor=color.new(C_CHOCH, 0), size=size.large)
        array.push(cchLines,  _ln)
        array.push(cchLabels, _lb)
        if array.size(cchLines) > maxCHoCH
            line.delete(array.shift(cchLines))
            label.delete(array.shift(cchLabels))

    // ── Bearish CHoCH (reversal — supersedes any pending BOS)
    if chochBear and not na(lastPLBar)
        for _bl in bosLines
            line.delete(_bl)
        for _blb in bosLabels
            label.delete(_blb)
        array.clear(bosLines)
        array.clear(bosLabels)
        _ln = line.new(lastPLBar, lastPL, bar_index + bosLineLen, lastPL,
                       color=color.new(C_CHOCH, 0), style=line.style_solid, width=2)
        _lb = label.new(lastPLBar, lastPL - atr14 * 1.6, "⬇ CHoCH",
                        style=label.style_none, textcolor=color.new(C_CHOCH, 0), size=size.large)
        array.push(cchLines,  _ln)
        array.push(cchLabels, _lb)
        if array.size(cchLines) > maxCHoCH
            line.delete(array.shift(cchLines))
            label.delete(array.shift(cchLabels))

// ══════════════════════════════════════════════════════════════════════════════
//  ORDER BLOCKS — 4-gradient quad zones
//  Visual concept: zone split into 4 horizontal sub-boxes with graduated
//  transparency, creating a gradient effect. Bull OB: densest at bottom
//  (key support). Bear OB: densest at top (key resistance).
// ══════════════════════════════════════════════════════════════════════════════
f_lastBear(startOff, maxLook) =>
    int _r = na
    for i = startOff to startOff + maxLook
        if na(_r) and close[i] < open[i]
            _r := i
    _r

f_lastBull(startOff, maxLook) =>
    int _r = na
    for i = startOff to startOff + maxLook
        if na(_r) and close[i] > open[i]
            _r := i
    _r

// ── OB: 7 parallel arrays per side (2-band gradient — clean single zone)
var box[]   bullOBQ0       = array.new<box>()   // bottom band (dense)
var box[]   bullOBQ1       = array.new<box>()   // top band (light)
var box[]   bullOBOutl     = array.new<box>()
var int[]   bullOBBars     = array.new<int>()
var bool[]  bullOBSwept    = array.new<bool>()
var int[]   bullOBSweptBar = array.new<int>()
var label[] bullOBLbls     = array.new<label>()

var box[]   bearOBQ0       = array.new<box>()   // top band (dense)
var box[]   bearOBQ1       = array.new<box>()   // bottom band (light)
var box[]   bearOBOutl     = array.new<box>()
var int[]   bearOBBars     = array.new<int>()
var bool[]  bearOBSwept    = array.new<bool>()
var int[]   bearOBSweptBar = array.new<int>()
var label[] bearOBLbls     = array.new<label>()

OB_EXT = 60

// ── Create Bull OB  (2 bands: bottom = dense support, top = lighter)
if showOB and bosBull
    _i = f_lastBear(1, 50)
    if not na(_i)
        _top  = math.max(open[_i], close[_i])
        _bot  = math.min(open[_i], close[_i])
        _mid  = _bot + (_top - _bot) * 0.5
        _left = bar_index - _i

        _q0 = box.new(_left, _mid, bar_index + OB_EXT, _bot,  border_color=na, bgcolor=color.new(C_OB_BULL, 30))
        _q1 = box.new(_left, _top, bar_index + OB_EXT, _mid,  border_color=na, bgcolor=color.new(C_OB_BULL, 58))
        _outl = box.new(_left, _top, bar_index + OB_EXT, _bot,
                        border_color=color.new(C_OB_ACCENT_BULL, 25), border_width=1, bgcolor=na)
        // Label placed inside zone at midpoint — no overlap with ◆ markers at zone edges
        _lbl  = label.new(_left, _mid, "▲ OB",
                          style=label.style_none, textcolor=color.new(C_OB_ACCENT_BULL, 0), size=size.small)

        array.push(bullOBQ0,       _q0)
        array.push(bullOBQ1,       _q1)
        array.push(bullOBOutl,     _outl)
        array.push(bullOBBars,     bar_index)
        array.push(bullOBSwept,    false)
        array.push(bullOBSweptBar, 0)
        array.push(bullOBLbls,     _lbl)

        if array.size(bullOBOutl) > maxOBs
            box.delete(array.shift(bullOBQ0))
            box.delete(array.shift(bullOBQ1))
            box.delete(array.shift(bullOBOutl))
            label.delete(array.shift(bullOBLbls))
            array.shift(bullOBBars)
            array.shift(bullOBSwept)
            array.shift(bullOBSweptBar)

// ── Create Bear OB  (2 bands: top = dense resistance, bottom = lighter)
if showOB and bosBear
    _i = f_lastBull(1, 50)
    if not na(_i)
        _top  = math.max(open[_i], close[_i])
        _bot  = math.min(open[_i], close[_i])
        _mid  = _bot + (_top - _bot) * 0.5
        _left = bar_index - _i

        _q0 = box.new(_left, _top, bar_index + OB_EXT, _mid,  border_color=na, bgcolor=color.new(C_OB_BEAR, 30))
        _q1 = box.new(_left, _mid, bar_index + OB_EXT, _bot,  border_color=na, bgcolor=color.new(C_OB_BEAR, 58))
        _outl = box.new(_left, _top, bar_index + OB_EXT, _bot,
                        border_color=color.new(C_OB_ACCENT_BEAR, 25), border_width=1, bgcolor=na)
        // Label placed inside zone at midpoint — no overlap with ◆ markers at zone edges
        _lbl  = label.new(_left, _mid, "▼ OB",
                          style=label.style_none, textcolor=color.new(C_OB_ACCENT_BEAR, 0), size=size.small)

        array.push(bearOBQ0,       _q0)
        array.push(bearOBQ1,       _q1)
        array.push(bearOBOutl,     _outl)
        array.push(bearOBBars,     bar_index)
        array.push(bearOBSwept,    false)
        array.push(bearOBSweptBar, 0)
        array.push(bearOBLbls,     _lbl)

        if array.size(bearOBOutl) > maxOBs
            box.delete(array.shift(bearOBQ0))
            box.delete(array.shift(bearOBQ1))
            box.delete(array.shift(bearOBOutl))
            label.delete(array.shift(bearOBLbls))
            array.shift(bearOBBars)
            array.shift(bearOBSwept)
            array.shift(bearOBSweptBar)

// ── Extend right edge + active glow when price is inside zone
if array.size(bullOBOutl) > 0
    for _qi = 0 to array.size(bullOBOutl) - 1
        if not array.get(bullOBSwept, _qi)
            _r       = bar_index + OB_EXT
            _zTop    = box.get_top(array.get(bullOBOutl, _qi))
            _zBot    = box.get_bottom(array.get(bullOBOutl, _qi))
            _active  = close >= _zBot and close <= _zTop
            _bdrC    = _active ? color.new(C_OB_ACCENT_BULL, 0)  : color.new(C_OB_ACCENT_BULL, 25)
            _bdrW    = _active ? 2 : 1
            box.set_right(array.get(bullOBQ0,   _qi), _r)
            box.set_right(array.get(bullOBQ1,   _qi), _r)
            box.set_right(array.get(bullOBOutl, _qi), _r)
            box.set_border_color(array.get(bullOBOutl, _qi), _bdrC)
            box.set_border_width(array.get(bullOBOutl, _qi), _bdrW)

if array.size(bearOBOutl) > 0
    for _qi = 0 to array.size(bearOBOutl) - 1
        if not array.get(bearOBSwept, _qi)
            _r       = bar_index + OB_EXT
            _zTop    = box.get_top(array.get(bearOBOutl, _qi))
            _zBot    = box.get_bottom(array.get(bearOBOutl, _qi))
            _active  = close >= _zBot and close <= _zTop
            _bdrC    = _active ? color.new(C_OB_ACCENT_BEAR, 0)  : color.new(C_OB_ACCENT_BEAR, 25)
            _bdrW    = _active ? 2 : 1
            box.set_right(array.get(bearOBQ0,   _qi), _r)
            box.set_right(array.get(bearOBQ1,   _qi), _r)
            box.set_right(array.get(bearOBOutl, _qi), _r)
            box.set_border_color(array.get(bearOBOutl, _qi), _bdrC)
            box.set_border_width(array.get(bearOBOutl, _qi), _bdrW)

// ── Bull OB: mitigation / age / swept
_bi = array.size(bullOBOutl) - 1
while _bi >= 0
    _outl     = array.get(bullOBOutl,     _bi)
    _isSwept  = array.get(bullOBSwept,    _bi)
    _crAge    = bar_index - array.get(bullOBBars,     _bi)
    _swAge    = _isSwept ? bar_index - array.get(bullOBSweptBar, _bi) : 0
    _mit      = not _isSwept and (obMit == "Close" ? close < box.get_bottom(_outl) : low < box.get_bottom(_outl))
    _shouldDel = _crAge > obMaxAge or (_isSwept and _swAge > sweptAge)

    if _shouldDel
        box.delete(array.get(bullOBQ0,   _bi))
        box.delete(array.get(bullOBQ1,   _bi))
        box.delete(_outl)
        label.delete(array.get(bullOBLbls, _bi))
        array.remove(bullOBQ0,       _bi)
        array.remove(bullOBQ1,       _bi)
        array.remove(bullOBOutl,     _bi)
        array.remove(bullOBLbls,     _bi)
        array.remove(bullOBBars,     _bi)
        array.remove(bullOBSwept,    _bi)
        array.remove(bullOBSweptBar, _bi)
    else if _mit
        if showSwept
            _fd = color.new(C_OB_BULL, 86)
            box.set_bgcolor(array.get(bullOBQ0, _bi), _fd)
            box.set_bgcolor(array.get(bullOBQ1, _bi), _fd)
            box.set_border_style(_outl, line.style_dashed)
            box.set_border_color(_outl, color.new(C_OB_ACCENT_BULL, 35))
            label.set_textcolor(array.get(bullOBLbls, _bi), color.new(C_OB_ACCENT_BULL, 50))
            array.set(bullOBSwept,    _bi, true)
            array.set(bullOBSweptBar, _bi, bar_index)
        else
            box.delete(array.get(bullOBQ0,   _bi))
            box.delete(array.get(bullOBQ1,   _bi))
            box.delete(_outl)
            label.delete(array.get(bullOBLbls, _bi))
            array.remove(bullOBQ0,       _bi)
            array.remove(bullOBQ1,       _bi)
            array.remove(bullOBOutl,     _bi)
            array.remove(bullOBLbls,     _bi)
            array.remove(bullOBBars,     _bi)
            array.remove(bullOBSwept,    _bi)
            array.remove(bullOBSweptBar, _bi)
    _bi -= 1

// ── Bear OB: mitigation / age / swept
_bri = array.size(bearOBOutl) - 1
while _bri >= 0
    _outl     = array.get(bearOBOutl,     _bri)
    _isSwept  = array.get(bearOBSwept,    _bri)
    _crAge    = bar_index - array.get(bearOBBars,     _bri)
    _swAge    = _isSwept ? bar_index - array.get(bearOBSweptBar, _bri) : 0
    _mit      = not _isSwept and (obMit == "Close" ? close > box.get_top(_outl) : high > box.get_top(_outl))
    _shouldDel = _crAge > obMaxAge or (_isSwept and _swAge > sweptAge)

    if _shouldDel
        box.delete(array.get(bearOBQ0,   _bri))
        box.delete(array.get(bearOBQ1,   _bri))
        box.delete(_outl)
        label.delete(array.get(bearOBLbls, _bri))
        array.remove(bearOBQ0,       _bri)
        array.remove(bearOBQ1,       _bri)
        array.remove(bearOBOutl,     _bri)
        array.remove(bearOBLbls,     _bri)
        array.remove(bearOBBars,     _bri)
        array.remove(bearOBSwept,    _bri)
        array.remove(bearOBSweptBar, _bri)
    else if _mit
        if showSwept
            _fd = color.new(C_OB_BEAR, 86)
            box.set_bgcolor(array.get(bearOBQ0, _bri), _fd)
            box.set_bgcolor(array.get(bearOBQ1, _bri), _fd)
            box.set_border_style(_outl, line.style_dashed)
            box.set_border_color(_outl, color.new(C_OB_ACCENT_BEAR, 35))
            label.set_textcolor(array.get(bearOBLbls, _bri), color.new(C_OB_ACCENT_BEAR, 50))
            array.set(bearOBSwept,    _bri, true)
            array.set(bearOBSweptBar, _bri, bar_index)
        else
            box.delete(array.get(bearOBQ0,   _bri))
            box.delete(array.get(bearOBQ1,   _bri))
            box.delete(_outl)
            label.delete(array.get(bearOBLbls, _bri))
            array.remove(bearOBQ0,       _bri)
            array.remove(bearOBQ1,       _bri)
            array.remove(bearOBOutl,     _bri)
            array.remove(bearOBLbls,     _bri)
            array.remove(bearOBBars,     _bri)
            array.remove(bearOBSwept,    _bri)
            array.remove(bearOBSweptBar, _bri)
    _bri -= 1

// ══════════════════════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS
// ══════════════════════════════════════════════════════════════════════════════
// barstate.isconfirmed guard prevents intra-bar repaint on FVG detection
bullFVG = barstate.isconfirmed and low > high[2]
bearFVG = barstate.isconfirmed and high < low[2]

var box[] bullFVGs    = array.new<box>()
var int[] bullFVGBars = array.new<int>()
var box[] bearFVGs    = array.new<box>()
var int[] bearFVGBars = array.new<int>()

if showFVG and bullFVG
    _b = box.new(bar_index - 2, low, bar_index + 30, high[2],
                 border_color=color.new(C_OB_BULL, 30), border_width=1,
                 border_style=line.style_dotted, bgcolor=color.new(C_OB_BULL, 72))
    array.push(bullFVGs, _b)
    array.push(bullFVGBars, bar_index)

if showFVG and bearFVG
    _b = box.new(bar_index - 2, low[2], bar_index + 30, high,
                 border_color=color.new(C_OB_BEAR, 30), border_width=1,
                 border_style=line.style_dotted, bgcolor=color.new(C_OB_BEAR, 72))
    array.push(bearFVGs, _b)
    array.push(bearFVGBars, bar_index)

for b in bullFVGs
    box.set_right(b, bar_index + 30)
for b in bearFVGs
    box.set_right(b, bar_index + 30)

_fi = array.size(bullFVGs) - 1
while _fi >= 0
    _b   = array.get(bullFVGs, _fi)
    _age = bar_index - array.get(bullFVGBars, _fi)
    if _age > fvgAge or (fvgFill and close < box.get_top(_b))
        box.delete(_b)
        array.remove(bullFVGs,    _fi)
        array.remove(bullFVGBars, _fi)
    _fi -= 1

_fj = array.size(bearFVGs) - 1
while _fj >= 0
    _b   = array.get(bearFVGs, _fj)
    _age = bar_index - array.get(bearFVGBars, _fj)
    if _age > fvgAge or (fvgFill and close > box.get_bottom(_b))
        box.delete(_b)
        array.remove(bearFVGs,    _fj)
        array.remove(bearFVGBars, _fj)
    _fj -= 1

// ══════════════════════════════════════════════════════════════════════════════
//  LIQUIDITY — Equal H/L
// ══════════════════════════════════════════════════════════════════════════════
var line[]  eqhLines  = array.new<line>()
var label[] eqhLabels = array.new<label>()
var line[]  eqlLines  = array.new<line>()
var label[] eqlLabels = array.new<label>()

_eqT = eqPct / 100.0

if showLiq and not na(ph) and not na(prevPH) and prevPH > 0.0
    if math.abs(ph - prevPH) / prevPH <= _eqT
        _l  = line.new(lastPHBar, ph, bar_index[swingLen], ph,
                       color=color.new(C_EQH, 15), style=line.style_dotted, width=2)
        // Offset above swing high to avoid overlapping the ◆ marker at ph
        _lb = label.new(bar_index[swingLen], ph + atr14 * 0.7, "EQH ≋",
                        style=label.style_none, textcolor=color.new(C_EQH, 0), size=size.small)
        array.push(eqhLines,  _l)
        array.push(eqhLabels, _lb)
        if array.size(eqhLines) > maxLiq
            line.delete(array.shift(eqhLines))
            label.delete(array.shift(eqhLabels))

if showLiq and not na(pl) and not na(prevPL) and prevPL > 0.0
    if math.abs(pl - prevPL) / prevPL <= _eqT
        _l  = line.new(lastPLBar, pl, bar_index[swingLen], pl,
                       color=color.new(C_EQL, 15), style=line.style_dotted, width=2)
        // Offset below swing low to avoid overlapping the ◆ marker at pl
        _lb = label.new(bar_index[swingLen], pl - atr14 * 0.7, "EQL ≋",
                        style=label.style_none, textcolor=color.new(C_EQL, 0), size=size.small)
        array.push(eqlLines,  _l)
        array.push(eqlLabels, _lb)
        if array.size(eqlLines) > maxLiq
            line.delete(array.shift(eqlLines))
            label.delete(array.shift(eqlLabels))

for l in eqhLines
    line.set_x2(l, bar_index)
for l in eqlLines
    line.set_x2(l, bar_index)

// ══════════════════════════════════════════════════════════════════════════════
//  OB ZONE STATUS — only ACTIVE (non-swept) zones count
// ══════════════════════════════════════════════════════════════════════════════
inBullOB = false
inBearOB = false
if array.size(bullOBOutl) > 0
    for _oi = 0 to array.size(bullOBOutl) - 1
        if not array.get(bullOBSwept, _oi)
            _b = array.get(bullOBOutl, _oi)
            if close >= box.get_bottom(_b) and close <= box.get_top(_b)
                inBullOB := true
if array.size(bearOBOutl) > 0
    for _oi = 0 to array.size(bearOBOutl) - 1
        if not array.get(bearOBSwept, _oi)
            _b = array.get(bearOBOutl, _oi)
            if close >= box.get_bottom(_b) and close <= box.get_top(_b)
                inBearOB := true

// ══════════════════════════════════════════════════════════════════════════════
//  CANDLE COLORING — momentum-based gradient
//  Every candle is gradient: weak = dark shade, strong = vivid bright
//  Uses color.from_gradient() on normalised momentum ratio
//  Events override (CHoCH/BOS/OB) take priority
// ══════════════════════════════════════════════════════════════════════════════
_isChoch = chochBull or chochBear
_isBos   = bosBull   or bosBear
_bullBar = close >= open

// Momentum ratio 0–1 (how strong is this candle vs recent range)
_momAbs   = math.abs(close - open)
_momRange = ta.highest(_momAbs, 30)
_mRatio   = _momRange > 0 ? math.min(_momAbs / _momRange, 1.0) : 0.5

// Gradient palettes — green for bull, red for bear
// Weak candle = muted/dark, strong momentum = vivid saturated
_bullGrad = color.from_gradient(_mRatio, 0, 1, color.new(#0D2B1A, 0), color.new(#00C853, 0))
_bearGrad = color.from_gradient(_mRatio, 0, 1, color.new(#2B0A0A, 0), color.new(#FF1744, 0))

color _cc = _isChoch ? color.new(C_CHOCH, 0) : _isBos ? color.new(C_BOS, 0) : inBullOB ? color.new(C_OB_BULL, 10) : inBearOB ? color.new(C_OB_BEAR, 10) : _bullBar ? _bullGrad : _bearGrad

barcolor(showCndl ? _cc : na)

// ══════════════════════════════════════════════════════════════════════════════
//  PANEL
// ══════════════════════════════════════════════════════════════════════════════
var string _lBOS   = "—"
var int    _bBOS   = na
var string _lCHOCH = "—"
var int    _bCHOCH = na

// BOS fires → reset stale CHoCH panel entry (CHoCH was superseded)
if bosBull and not chochBull
    _lBOS   := "BULL"
    _bBOS   := bar_index
    _lCHOCH := "—"
    _bCHOCH := na
if bosBear and not chochBear
    _lBOS   := "BEAR"
    _bBOS   := bar_index
    _lCHOCH := "—"
    _bCHOCH := na
// CHoCH fires → reset stale BOS panel entry (BOS was superseded by reversal)
if chochBull
    _lCHOCH := "BULL"
    _bCHOCH := bar_index
    _lBOS   := "—"
    _bBOS   := na
if chochBear
    _lCHOCH := "BEAR"
    _bCHOCH := bar_index
    _lBOS   := "—"
    _bBOS   := na

f_ago(i) =>
    d = bar_index - i
    d == 0 ? "now" : str.tostring(d) + "b ago"

_totalBOS = bullBOSCount + bearBOSCount
_bullPct  = _totalBOS > 0 ? bullBOSCount / _totalBOS : 0.5
_filledB  = math.round(_bullPct * 8)
_emptyB   = 8 - _filledB
_gFill    = ""
_gEmpty   = ""
for _gi = 0 to _filledB - 1
    _gFill  += "█"
for _gi = 0 to _emptyB - 1
    _gEmpty += "░"
_biasGauge = _gFill + _gEmpty
_biasPct   = str.tostring(math.round(_bullPct * 100)) + "% BULL"

_bosStr   = _lBOS   + (na(_bBOS)   ? "" : "  " + f_ago(_bBOS))
_chochStr = _lCHOCH + (na(_bCHOCH) ? "" : "  " + f_ago(_bCHOCH))

// Count only ACTIVE (non-swept) OB zones for panel display
_bullOBActive = 0
_bearOBActive = 0
if array.size(bullOBSwept) > 0
    for _ci = 0 to array.size(bullOBSwept) - 1
        if not array.get(bullOBSwept, _ci)
            _bullOBActive += 1
if array.size(bearOBSwept) > 0
    for _ci = 0 to array.size(bearOBSwept) - 1
        if not array.get(bearOBSwept, _ci)
            _bearOBActive += 1
_obStr    = str.tostring(_bullOBActive) + " ▲  " + str.tostring(_bearOBActive) + " ▼"
_fvgStr   = str.tostring(array.size(bullFVGs)) + " ▲    " + str.tostring(array.size(bearFVGs)) + " ▼"
_liqStr   = str.tostring(array.size(eqhLines)) + " EQH   " + str.tostring(array.size(eqlLines)) + " EQL"
_swgH     = na(lastPH) ? "—" : str.tostring(lastPH, format.mintick)
_swgL     = na(lastPL) ? "—" : str.tostring(lastPL, format.mintick)
_zoneStr  = inBullOB ? "▲  BULL OB" : inBearOB ? "▼  BEAR OB" : "—"
_phaseStr = chochBull or chochBear ? "REVERSAL" : bosBull or bosBear ? "BREAKOUT" : "RANGING"

_cBull    = color.new(#34D399, 0)
_cBear    = color.new(#F87171, 0)
_cObBull  = color.new(C_OB_BULL, 0)
_cObBear  = color.new(C_OB_BEAR, 0)
_cNeutral = color.new(#4B5563, 0)

_bosC     = _lBOS   == "BULL" ? _cBull : _lBOS   == "BEAR" ? _cBear : _cNeutral
_chochC   = _lCHOCH == "BULL" ? _cBull : _lCHOCH == "BEAR" ? _cBear : _cNeutral
_zoneC    = inBullOB ? _cObBull : inBearOB ? _cObBear : _cNeutral
_phaseC   = chochBull or chochBear ? color.new(C_CHOCH, 0) : bosBull or bosBear ? color.new(C_BOS, 0) : _cNeutral
_gaugeC   = isBullTrend ? _cBull : _cBear
_atrC     = _atrHot ? _cBear : color.new(#C8C3F0, 0)

_P_BG    = color.new(#0A0A14, 0)   // near black with tiny blue tint
_P_HDR   = isBullTrend ? color.new(#0D2B1E, 0) : color.new(#2B0E14, 0)
_P_SEC   = color.new(#111120, 0)   // section header bg
_P_ROW   = color.new(#0D0D1C, 0)   // alternating row bg
_P_SEP   = color.new(#2A2840, 0)   // separator line
_P_LBL   = color.new(#8886AA, 0)   // label names — readable medium gray-purple
_P_VAL   = color.new(#F0F0FF, 0)   // values — near white, max contrast
_P_DIM   = color.new(#6664A0, 0)   // section headers, footer
_HDR_C   = isBullTrend ? color.new(#2ECC71, 0) : color.new(#FF4757, 0)
_HDR_S   = isBullTrend ? "▲  BULLISH" : "▼  BEARISH"

if barstate.islast and showPanel
    var table T = table.new(position.top_right, 2, 22,
                             bgcolor      = _P_BG,
                             frame_color  = color.new(#2D2A70, 50),
                             frame_width  = 1,
                             border_color = _P_BG,
                             border_width = 0)

    table.cell(T, 0, 0, " " + _HDR_S,
               text_color=_HDR_C, bgcolor=_P_HDR,
               text_size=size.large, text_halign=text.align_left)
    table.cell(T, 1, 0, "SMC·LFX ",
               text_color=_P_DIM, bgcolor=_P_HDR,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 1, " " + _biasGauge,
               text_color=_gaugeC, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 1, _biasPct + " ",
               text_color=_gaugeC, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 2, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 2, "", bgcolor=_P_SEP, text_size=size.tiny)

    table.cell(T, 0, 3, " ◈  STRUCTURE",
               text_color=_P_DIM, bgcolor=_P_SEC,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 3, _phaseStr + " ",
               text_color=_phaseC, bgcolor=_P_SEC,
               text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 4, " BOS",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 4, _bosStr + " ",
               text_color=_bosC, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 5, " CHoCH",
               text_color=_P_LBL, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 5, _chochStr + " ",
               text_color=_chochC, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 6, " Zone",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 6, _zoneStr + " ",
               text_color=_zoneC, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 7, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 7, "", bgcolor=_P_SEP, text_size=size.tiny)

    table.cell(T, 0, 8, " ◈  ZONES",
               text_color=_P_DIM, bgcolor=_P_SEC,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 8, "", bgcolor=_P_SEC, text_size=size.tiny)

    table.cell(T, 0, 9, " Order Block",
               text_color=_P_LBL, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 9, _obStr + " ",
               text_color=_P_VAL, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 10, " Fair Value Gap",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 10, _fvgStr + " ",
               text_color=_P_VAL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 11, " Liquidity",
               text_color=_P_LBL, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 11, _liqStr + " ",
               text_color=color.new(C_EQH, 0), bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 12, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 12, "", bgcolor=_P_SEP, text_size=size.tiny)

    table.cell(T, 0, 13, " ◈  LEVELS",
               text_color=_P_DIM, bgcolor=_P_SEC,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 13, "", bgcolor=_P_SEC, text_size=size.tiny)

    table.cell(T, 0, 14, " Swing High",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 14, _swgH + " ",
               text_color=_cBear, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 15, " Swing Low",
               text_color=_P_LBL, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 15, _swgL + " ",
               text_color=_cBull, bgcolor=_P_BG,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 16, " ATR(14)",
               text_color=_P_LBL, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_left)
    table.cell(T, 1, 16, _atrV + "  " + _atrLbl + " ",
               text_color=_atrC, bgcolor=_P_ROW,
               text_size=size.normal, text_halign=text.align_right)

    table.cell(T, 0, 17, "", bgcolor=_P_SEP, text_size=size.tiny)
    table.cell(T, 1, 17, "", bgcolor=_P_SEP, text_size=size.tiny)

    table.cell(T, 0, 18, " BOS Count",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 18, str.tostring(bullBOSCount) + " ▲  " + str.tostring(bearBOSCount) + " ▼ ",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 19, " Swing Len",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 19, str.tostring(swingLen) + " bars ",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

    table.cell(T, 0, 20, "", bgcolor=_P_BG, text_size=size.tiny)
    table.cell(T, 1, 20, "", bgcolor=_P_BG, text_size=size.tiny)

    table.cell(T, 0, 21, " No Repaint",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_left)
    table.cell(T, 1, 21, "confirmed close ",
               text_color=_P_DIM, bgcolor=_P_BG,
               text_size=size.small, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════════════════
alertcondition(bosBull and not chochBull,    title="BOS Bullish",
     message="SMC [LunqFX]: Bullish BOS — uptrend continuation.")
alertcondition(bosBear and not chochBear,    title="BOS Bearish",
     message="SMC [LunqFX]: Bearish BOS — downtrend continuation.")
alertcondition(chochBull,                    title="CHoCH Bullish",
     message="SMC [LunqFX]: CHoCH BULLISH — reversal to the upside.")
alertcondition(chochBear,                    title="CHoCH Bearish",
     message="SMC [LunqFX]: CHoCH BEARISH — reversal to the downside.")
alertcondition(showOB and bosBull,           title="Bullish OB Created",
     message="SMC [LunqFX]: New Bullish Order Block — watch for retracement.")
alertcondition(showOB and bosBear,           title="Bearish OB Created",
     message="SMC [LunqFX]: New Bearish Order Block — watch for retracement.")
alertcondition(inBullOB and not inBullOB[1], title="Price Entered Bull OB",
     message="SMC [LunqFX]: Price entered Bullish OB — potential long setup.")
alertcondition(inBearOB and not inBearOB[1], title="Price Entered Bear OB",
     message="SMC [LunqFX]: Price entered Bearish OB — potential short setup.")
alertcondition(showFVG and bullFVG,          title="Bullish FVG",
     message="SMC [LunqFX]: Bullish Fair Value Gap created.")
alertcondition(showFVG and bearFVG,          title="Bearish FVG",
     message="SMC [LunqFX]: Bearish Fair Value Gap created.")
````
