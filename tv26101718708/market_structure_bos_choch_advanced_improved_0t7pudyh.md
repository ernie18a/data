# Market Structure (BOS / CHOCH), Advanced & Improved

- url: https://www.tradingview.com/script/0t7puDyH-Market-Structure-BOS-CHOCH-Advanced-Improved/
- type: indicator
- pine_id: PUB;188ff208f5a7431c8f05e79637f57dd8
- version: 1.0

## Description

[b]Market Structure (BOS / CHOCH)[/b]

A clean, dual-layer market structure tool that labels Break of Structure and Change of Character from a single, internally consistent trend engine, then projects the resting liquidity those swings leave behind.

[b]The core idea[/b]
BOS and CHOCH are the same break. What separates them is direction relative to the current trend, so this script tracks one trend state and derives the label from it:
[list]
[*][b]BOS (Break of Structure)[/b] : price breaks a swing level in the direction of the trend. Continuation.
[*][b]CHOCH (Change of Character)[/b] : price breaks a swing level against the trend. Reversal, and it flips the trend state.
[/list]
Because both signals come from one state machine, you never get contradictory labels: a break with the trend is always BOS, a break against it is always CHOCH.

[b]Dual-layer structure[/b]
The engine runs twice at the same time:
[list]
[*][b]Swing structure[/b] (longer pivot length) : the major skeleton, drawn bold, with trailing watched-level lines and HH / HL / LH / LL swing labels.
[*][b]Internal structure[/b] (shorter pivot length) : the minor continuation breaks inside each swing leg, drawn thin and faded so they read as secondary.
[/list]
This lets you see a minor bullish BOS unfolding inside a major downtrend, which is the context most single-length tools miss.

[b]Liquidity pools[/b]
Every unbroken swing high (buy-side) and swing low (sell-side) is projected to the right as a resting liquidity line, and removed the moment price wicks through it. What stays on screen is only live, untaken liquidity, the levels most likely to be targeted next.

[b]Features[/b]
[list]
[*]BOS / CHOCH detection with a single coherent trend state
[*]Dual-layer swing and internal structure
[*]Trailing lines marking the exact levels currently being watched
[*]HH / HL / LH / LL swing labels, color coded by structural meaning
[*]Buy-side and sell-side liquidity pools with auto removal on sweep
[*]Top-right trend table showing the swing and internal trend state
[*]Close or Wick break confirmation
[*]Eight alert conditions: swing and internal, BOS and CHOCH, bullish and bearish
[/list]

[b]Inputs[/b]
[list]
[*][b]Swing length[/b] and [b]Internal length[/b] : pivot lookback for each layer. Lower values catch more structure, higher values show only major moves.
[*][b]Break confirmation[/b] : Close requires a close beyond the level, Wick accepts any wick beyond it.
[*]Toggles for BOS, CHOCH, active levels, swing labels, liquidity, internal layer and the trend table.
[/list]

[b]How to use[/b]
[list]
[*]Trade with the swing trend, use internal CHOCH for early reversal warnings and internal BOS for continuation entries.
[*]Watch the liquidity pools as targets, a sweep of one followed by a CHOCH in the opposite direction is a classic reversal setup.
[*]Tune the swing length to your timeframe so the major structure matches the moves you actually trade.
[/list]

[b]Notes[/b]
Swing pivots confirm a fixed number of bars after they print, which is inherent to all structure tools and not repainting. On the live, unclosed bar a break can update until the bar closes, so set alerts to "Once Per Bar Close" for confirmed signals.

This script is a market analysis tool, not financial advice. Always do your own research and manage risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © cliteka-cell

//@version=6
indicator("Market Structure (BOS / CHOCH)", shorttitle="Structure", overlay=true,
          max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// MARKET STRUCTURE (BOS / CHOCH)
//
// Two events off one break engine and a single trend state, run as TWO layers:
//
//   BOS   (Break of Structure):  break with the trend. Continuation.
//   CHOCH (Change of Character): break against the trend. Reversal, flips trend.
//
// SWING layer (long length):    the major structure skeleton. Bold, solid,
//                               with trailing watched-level lines and HH/HL/LH/LL.
// INTERNAL layer (short length): the minor continuation structure inside each
//                               swing leg. Thin and faded, secondary.
//
// LIQUIDITY: every unbroken swing high (buy-side) / low (sell-side) is projected
// right as a resting pool, removed when wicked through (where SFP setups fire).
//
// Each layer owns its own object arrays + cap, so the internal layer can never
// evict the swing layer's labels from the global drawing budget.
// ═══════════════════════════════════════════════════════════════════════════

// ── Structure ────────────────────────────────────────────────────────────────
var g_s = "Structure"
swingLen     = input.int   (25, "Swing length", minval=2, group=g_s, tooltip="Pivot lookback for the major structure skeleton.")
intLen       = input.int   (5,  "Internal length", minval=2, group=g_s, tooltip="Shorter pivot lookback for the minor structure drawn inside each swing leg. Keep below the swing length.")
showInternal = input.bool  (true, "Show internal structure", group=g_s, tooltip="Adds a faded, thinner layer of BOS/CHOCH for the continuation legs inside the major swing structure.")
confirmation = input.string("Close", "Break confirmation", options=["Close", "Wick"], group=g_s, tooltip="Close: price must close beyond the level. Wick: any wick beyond the level counts.")

// ── Display ──────────────────────────────────────────────────────────────────
var g_d = "Display"
showBOS    = input.bool (true,  "Show BOS",           group=g_d)
showCHOCH  = input.bool (true,  "Show CHOCH",         group=g_d)
showLevels = input.bool (true,  "Show active levels", group=g_d, tooltip="Dashed line tracking the current unbroken swing high and low (swing layer only).")
showSwings = input.bool (true,  "Show HH/HL/LH/LL",   group=g_d, tooltip="Swing-structure pivot labels (swing layer only).")
showTable  = input.bool (true,  "Show trend table",   group=g_d, tooltip="Top-right readout of the current swing and internal trend state.")
bullCol    = input.color(color.new(#26a69a, 0), "Bullish", group=g_d, inline="col")
bearCol    = input.color(color.new(#ef5350, 0), "Bearish", group=g_d, inline="col")
lineWidth  = input.int  (2, "Swing line width", minval=1, maxval=4, group=g_d)

// ── Liquidity ────────────────────────────────────────────────────────────────
var g_l = "Liquidity"
showLiq = input.bool (true, "Show liquidity levels", group=g_l, tooltip="Dotted line projected right from every unbroken swing high (buy-side) and low (sell-side). Removed when price wicks through it (liquidity taken). These are the pools SFP setups fire on.")
liqCol  = input.color(color.new(color.gray, 35), "Liquidity color", group=g_l)
maxLiq  = input.int  (10, "Max levels per side", minval=1, maxval=50, group=g_l, tooltip="Cap on resting liquidity lines kept per side. Oldest are dropped first.")

// ═══════════════════════════════════════════════════════════════════════════
// MSLayer: all per-layer state in one object so both layers share the engine.
// A level's stored value doubles as the prev-pivot reference for HH/HL.
// labels/lines + caps make each layer self-contained in the drawing budget.
// ═══════════════════════════════════════════════════════════════════════════
type MSLayer
    int   len        = 0
    bool  thin       = false   // internal layer = thin/faded styling, no extras
    int   maxLabels  = 200     // per-layer object caps (sum stays under 500)
    int   maxLines   = 150
    array<label> labels = na
    array<line>  lines  = na
    float bullLevel  = na
    int   bullBar    = na
    bool  bullBroken = true
    line  bullLine   = na
    float bearLevel  = na
    int   bearBar    = na
    bool  bearBroken = true
    line  bearLine   = na
    int   trend      = 0        // +1 bull, -1 bear, 0 neutral

// ── Object tracking: push and trim oldest, per layer ───────────────────────────
method trackLabel(MSLayer this, label lbl) =>
    array.push(this.labels, lbl)
    if array.size(this.labels) > this.maxLabels
        label.delete(array.shift(this.labels))

method trackLine(MSLayer this, line ln) =>
    array.push(this.lines, ln)
    if array.size(this.lines) > this.maxLines
        line.delete(array.shift(this.lines))

// ── Engine: process one layer for the current bar, return its 4 event flags ────
method process(MSLayer this, float ph, float pl, float bullSrc, float bearSrc) =>
    bool bullBOS   = false
    bool bullCHOCH = false
    bool bearBOS   = false
    bool bearCHOCH = false

    lblSz    = this.thin ? size.tiny : size.small
    brkWidth = this.thin ? 1  : lineWidth
    brkTrans = this.thin ? 50 : 0       // break line transparency
    bgTrans  = this.thin ? 40 : 15      // break label background transparency

    // New pivot high: (swing only) label + trailing line, (both) arm bull level
    if not na(ph)
        if showSwings and not this.thin
            t = na(this.bullLevel) ? "H" : (ph > this.bullLevel ? "HH" : "LH")
            c = na(this.bullLevel) ? color.gray : (ph > this.bullLevel ? bullCol : bearCol)
            this.trackLabel(label.new(bar_index - this.len, ph, t, style=label.style_label_down, color=color.new(c, 60), textcolor=color.white, size=size.tiny))
        if showLevels and not this.thin and not na(this.bullLine) and not this.bullBroken
            line.delete(this.bullLine)
            this.bullLine := na
        this.bullLevel  := ph
        this.bullBar    := bar_index - this.len
        this.bullBroken := false
        if showLevels and not this.thin
            this.bullLine := line.new(this.bullBar, this.bullLevel, bar_index, this.bullLevel, color=color.new(bullCol, 40), style=line.style_dashed)

    // New pivot low: (swing only) label + trailing line, (both) arm bear level
    if not na(pl)
        if showSwings and not this.thin
            t = na(this.bearLevel) ? "L" : (pl < this.bearLevel ? "LL" : "HL")
            c = na(this.bearLevel) ? color.gray : (pl < this.bearLevel ? bearCol : bullCol)
            this.trackLabel(label.new(bar_index - this.len, pl, t, style=label.style_label_up, color=color.new(c, 60), textcolor=color.white, size=size.tiny))
        if showLevels and not this.thin and not na(this.bearLine) and not this.bearBroken
            line.delete(this.bearLine)
            this.bearLine := na
        this.bearLevel  := pl
        this.bearBar    := bar_index - this.len
        this.bearBroken := false
        if showLevels and not this.thin
            this.bearLine := line.new(this.bearBar, this.bearLevel, bar_index, this.bearLevel, color=color.new(bearCol, 40), style=line.style_dashed)

    // Extend the active trailing lines (swing only; na on the internal layer)
    if not na(this.bullLine) and not this.bullBroken
        line.set_x2(this.bullLine, bar_index)
    if not na(this.bearLine) and not this.bearBroken
        line.set_x2(this.bearLine, bar_index)

    // Break detection
    bullBreak = not this.bullBroken and not na(this.bullLevel) and bullSrc > this.bullLevel
    bearBreak = not this.bearBroken and not na(this.bearLevel) and bearSrc < this.bearLevel

    // If one bar breaks both, the candle body decides which wins
    if bullBreak and bearBreak
        if close >= open
            bearBreak := false
        else
            bullBreak := false

    // State machine: break with trend = BOS, against = CHOCH (flips trend)
    if bullBreak
        isCHOCH = this.trend == -1
        this.trend := 1
        if isCHOCH
            bullCHOCH := true
        else
            bullBOS := true
        if not na(this.bullLine)
            line.delete(this.bullLine)
            this.bullLine := na
        if (isCHOCH and showCHOCH) or (not isCHOCH and showBOS)
            this.trackLine(line.new(this.bullBar, this.bullLevel, bar_index, this.bullLevel, color=color.new(bullCol, brkTrans), width=brkWidth, style = isCHOCH ? line.style_dashed : line.style_solid))
            this.trackLabel(label.new(bar_index, this.bullLevel, isCHOCH ? "CHOCH" : "BOS", style=label.style_label_down, color=color.new(bullCol, bgTrans), textcolor=color.white, size=lblSz))
        this.bullBroken := true

    if bearBreak
        isCHOCH = this.trend == 1
        this.trend := -1
        if isCHOCH
            bearCHOCH := true
        else
            bearBOS := true
        if not na(this.bearLine)
            line.delete(this.bearLine)
            this.bearLine := na
        if (isCHOCH and showCHOCH) or (not isCHOCH and showBOS)
            this.trackLine(line.new(this.bearBar, this.bearLevel, bar_index, this.bearLevel, color=color.new(bearCol, brkTrans), width=brkWidth, style = isCHOCH ? line.style_dashed : line.style_solid))
            this.trackLabel(label.new(bar_index, this.bearLevel, isCHOCH ? "CHOCH" : "BOS", style=label.style_label_up, color=color.new(bearCol, bgTrans), textcolor=color.white, size=lblSz))
        this.bearBroken := true

    [bullBOS, bearBOS, bullCHOCH, bearCHOCH]

// ── Liquidity: extend each resting pool, remove the moment a wick takes it ─────
sweepLiq(array<line> arr, bool isHigh) =>
    if array.size(arr) > 0
        // iterate high-to-low so a removal never shifts an unvisited index
        for i = array.size(arr) - 1 to 0
            ln    = array.get(arr, i)
            lvl   = line.get_y1(ln)
            taken = isHigh ? (high > lvl) : (low < lvl)
            if taken
                array.remove(arr, i)
                line.delete(ln)          // both branches end on a void call
            else
                line.set_x2(ln, bar_index)

// ── Trend table helpers ────────────────────────────────────────────────────────
trendTxt(int t) => t > 0 ? "Bullish" : (t < 0 ? "Bearish" : "Neutral")
trendCol(int t) => t > 0 ? bullCol   : (t < 0 ? bearCol   : color.gray)

// ═══════════════════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════════════════
// Fresh arrays per instance (passed at construction, NOT as field defaults,
// which would make both layers share one array)
var MSLayer swing    = MSLayer.new(len=swingLen, thin=false, maxLabels=240, maxLines=150, labels=array.new<label>(), lines=array.new<line>())
var MSLayer internal = MSLayer.new(len=intLen,   thin=true,  maxLabels=120, maxLines=120, labels=array.new<label>(), lines=array.new<line>())

var array<line> bslLines = array.new<line>()   // buy-side liquidity (above swing highs)
var array<line> sslLines = array.new<line>()   // sell-side liquidity (below swing lows)

// Pivots: computed unconditionally at global scope (ta.* is stateful)
phI = ta.pivothigh(intLen,   intLen)
plI = ta.pivotlow (intLen,   intLen)
phS = ta.pivothigh(swingLen, swingLen)
plS = ta.pivotlow (swingLen, swingLen)

bullSrc = confirmation == "Wick" ? high : close
bearSrc = confirmation == "Wick" ? low  : close

// Liquidity from the swing pivots only
if showLiq and not na(phS)
    array.push(bslLines, line.new(bar_index - swingLen, phS, bar_index, phS, color=liqCol, style=line.style_dotted))
    if array.size(bslLines) > maxLiq
        line.delete(array.shift(bslLines))
if showLiq and not na(plS)
    array.push(sslLines, line.new(bar_index - swingLen, plS, bar_index, plS, color=liqCol, style=line.style_dotted))
    if array.size(sslLines) > maxLiq
        line.delete(array.shift(sslLines))
if showLiq
    sweepLiq(bslLines, true)
    sweepLiq(sslLines, false)

// Internal layer first so the swing layer renders on top
iBullBOS   = false
iBearBOS   = false
iBullCHOCH = false
iBearCHOCH = false
if showInternal
    [a, b, c, d] = internal.process(phI, plI, bullSrc, bearSrc)
    iBullBOS   := a
    iBearBOS   := b
    iBullCHOCH := c
    iBearCHOCH := d

[sBullBOS, sBearBOS, sBullCHOCH, sBearCHOCH] = swing.process(phS, plS, bullSrc, bearSrc)

// ── Trend table (top-right readout) ─────────────────────────────────────────────
var table tt = table.new(position.top_right, 2, 2, frame_color=color.new(color.gray, 50), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)
if showTable and barstate.islast
    table.cell(tt, 0, 0, "Swing",    text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(tt, 1, 0, trendTxt(swing.trend), text_color=trendCol(swing.trend), text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(tt, 0, 1, "Internal", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 0))
    table.cell(tt, 1, 1, showInternal ? trendTxt(internal.trend) : "Off", text_color = showInternal ? trendCol(internal.trend) : color.gray, text_size=size.small, bgcolor=color.new(color.black, 0))

// ── Alerts  (set the alert to "Once Per Bar Close" to avoid intrabar repaint) ───
alertcondition(sBullBOS,   "Swing Bullish BOS",   "Swing Bullish Break of Structure")
alertcondition(sBearBOS,   "Swing Bearish BOS",   "Swing Bearish Break of Structure")
alertcondition(sBullCHOCH, "Swing Bullish CHOCH", "Swing Bullish Change of Character")
alertcondition(sBearCHOCH, "Swing Bearish CHOCH", "Swing Bearish Change of Character")
alertcondition(iBullBOS,   "Internal Bullish BOS",   "Internal Bullish Break of Structure")
alertcondition(iBearBOS,   "Internal Bearish BOS",   "Internal Bearish Break of Structure")
alertcondition(iBullCHOCH, "Internal Bullish CHOCH", "Internal Bullish Change of Character")
alertcondition(iBearCHOCH, "Internal Bearish CHOCH", "Internal Bearish Change of Character")
````
