# Market Structure [Proozac]

- url: https://www.tradingview.com/script/Gsv2ycj6-Market-Structure-Proozac/
- type: indicator
- pine_id: PUB;6bb91bb76e20470a9404e67011a9f8ee
- version: 1.0

## Description

[b]Market Structure — HH · HL · LH · LL[/b]

Labels every significant swing as a Higher High, Higher Low, Lower High, or Lower Low, then draws Break of Structure (BOS) and Change of Character (CHoCH) lines automatically. The result is a clean structural map of the market directly on the price chart, with no manual markup required.

[b]How it works[/b]

The indicator uses Pine's built-in pivot detection to find confirmed swing highs and lows. A swing is only confirmed after `Swing Length` bars have closed on each side — meaning labels always appear slightly to the left of the current bar, which is the correct behavior for non-repainting detection.

[b]Pivot High logic:[/b]

- If the new swing high is above the previous swing high → labeled **HH** (bullish continuation)
- If the new swing high is below the previous swing high → labeled **LH** (bearish continuation)
- When a HH forms after a bearish trend → a **CHoCH** line is drawn (first sign of structural flip)
- When a HH forms during an already-bullish trend → a **BOS** line is drawn (continuation confirmed)

[b]Pivot Low logic:[/b]

- If the new swing low is below the previous swing low → labeled **LL** (bearish continuation)
- If the new swing low is above the previous swing low → labeled **HL** (bullish continuation)
- When a LL forms after a bullish trend → **CHoCH** (structural reversal signal)
- When a LL forms during a bearish trend → **BOS** (continuation confirmed)

The zig-zag line connects consecutive pivot points in chronological order, giving a quick visual read of the overall swing sequence.

Visual output

- 🟢 HH label (above bar) → Higher High — bullish structure
- 🟢 HL label (below bar) → Higher Low — bullish pullback held
- 🔴 LH label (above bar) → Lower High — bearish structure
- 🔴 LL label (below bar) → Lower Low — bearish continuation
- 🔵 Dashed line + BOS +/− label → Break of Structure (trend continuation)
- 🟠 Dashed line + CHoCH +/− label → Change of Character (potential reversal)
- Gray zig-zag line → swing sequence connector
- Subtle background tint → green during bullish bias, red during bearish bias
- Live label on last bar → current structural bias ("Bullish" / "Bearish" / "Undefined")

[b]Configurable parameters[/b]

[b]Detection[/b]

- Swing Length — number of bars required on each side to confirm a pivot (default 10). Lower values = more sensitive, more noise. Higher values = fewer but more significant pivots
- Show Zig-Zag — toggle the connecting line between swings
- Show BOS / CHoCH — toggle the structural break lines and labels

Labels
- Individual toggles for **HH**, **HL**, **LH**, and **LL** labels

Colors
- Bullish Structure — color used for HH and HL labels (default teal)
- Bearish Structure — color used for LH and LL labels (default red)
- Zig-Zag Line — color of the swing connector
- BOS — color for Break of Structure lines (default blue)
- CHoCH — color for Change of Character lines (default orange)

[b]Recommended use[/b]

Start with the default swing length of 10 on your primary timeframe and only adjust if the swing count feels too noisy (lower it) or too sparse (raise it). On 15m and 1H charts, 10 works well for most instruments. On daily charts, consider dropping to 5–7.

CHoCH is the early signal — it's the first opposite-direction structural break after a trend. BOS confirms the new trend is continuing. The highest-probability setups occur when you see a CHoCH, then a pullback that holds as a HL or LH, followed by a BOS in the new direction.

Pair this indicator with the Liquidity Sweep Detector: a sweep of the last HL (in a bullish structure) followed by a BOS to the upside is one of the cleanest confluences available in price action trading.

## Source Code

````pine
//@version=6
// Market Structure — HH · HL · LH · LL · BOS · CHoCH
indicator("Market Structure — HH · HL · LH · LL", shorttitle="Mkt Structure", overlay=true, max_lines_count=500, max_labels_count=300)

// ── Inputs ────────────────────────────────────────────────────────────────────
g1 = "Detection"
swing_len   = input.int(10, "Swing Length", group=g1, minval=2, maxval=50)
show_zigzag = input.bool(true, "Show Zig-Zag", group=g1)
show_struct = input.bool(true, "Show BOS / CHoCH", group=g1)

g2 = "Labels"
show_hh = input.bool(true, "HH", group=g2)
show_hl = input.bool(true, "HL", group=g2)
show_lh = input.bool(true, "LH", group=g2)
show_ll = input.bool(true, "LL", group=g2)

g3 = "Colors"
bull_col  = input.color(#26a69a, "Bullish Structure", group=g3)
bear_col  = input.color(#ef5350, "Bearish Structure", group=g3)
zz_col    = input.color(color.new(color.gray, 30), "Zig-Zag Line", group=g3)
bos_col   = input.color(#2196F3, "BOS", group=g3)
choch_col = input.color(#FF9800, "CHoCH", group=g3)

// ── Pivot Detection ───────────────────────────────────────────────────────────
ph = ta.pivothigh(high, swing_len, swing_len)
pl = ta.pivotlow(low,  swing_len, swing_len)

// ── Structure Tracking ────────────────────────────────────────────────────────
var float last_ph = na,  var int last_ph_bar = na
var float prev_ph = na
var float last_pl = na,  var int last_pl_bar = na
var float prev_pl = na
var int   trend   = 0
var float last_point = na, var int last_point_bar = na

// ── Pivot High Logic ──────────────────────────────────────────────────────────
if not na(ph)
    cb = bar_index - swing_len

    if show_zigzag and not na(last_point_bar)
        line.new(last_point_bar, last_point, cb, ph, color=zz_col, width=1)

    if not na(prev_ph)
        if ph > last_ph
            if show_hh
                label.new(cb, ph, "HH", style=label.style_label_down, size=size.tiny, color=color.new(bull_col, 20), textcolor=color.white)
            if show_struct
                bos_type = trend == -1 ? "CHoCH" : "BOS"
                bos_c    = trend == -1 ? choch_col : bos_col
                line.new(last_ph_bar, last_ph, cb, last_ph, color=bos_c, style=line.style_dashed, width=2)
                label.new(cb, last_ph, bos_type + " +", style=label.style_label_down, size=size.tiny, color=color.new(bos_c, 20), textcolor=color.white)
            trend := 1
        else
            if show_lh
                label.new(cb, ph, "LH", style=label.style_label_down, size=size.tiny, color=color.new(bear_col, 20), textcolor=color.white)
            trend := -1

    prev_ph       := last_ph
    last_ph       := ph
    last_ph_bar   := cb
    last_point    := ph
    last_point_bar := cb

// ── Pivot Low Logic ───────────────────────────────────────────────────────────
if not na(pl)
    cb = bar_index - swing_len

    if show_zigzag and not na(last_point_bar)
        line.new(last_point_bar, last_point, cb, pl, color=zz_col, width=1)

    if not na(prev_pl)
        if pl < last_pl
            if show_ll
                label.new(cb, pl, "LL", style=label.style_label_up, size=size.tiny, color=color.new(bear_col, 20), textcolor=color.white)
            if show_struct
                bos_type = trend == 1 ? "CHoCH" : "BOS"
                bos_c    = trend == 1 ? choch_col : bos_col
                line.new(last_pl_bar, last_pl, cb, last_pl, color=bos_c, style=line.style_dashed, width=2)
                label.new(cb, last_pl, bos_type + " -", style=label.style_label_up, size=size.tiny, color=color.new(bos_c, 20), textcolor=color.white)
            trend := -1
        else
            if show_hl
                label.new(cb, pl, "HL", style=label.style_label_up, size=size.tiny, color=color.new(bull_col, 20), textcolor=color.white)
            trend := 1

    prev_pl       := last_pl
    last_pl       := pl
    last_pl_bar   := cb
    last_point    := pl
    last_point_bar := cb

// ── Background ────────────────────────────────────────────────────────────────
struct_bg = trend == 1 ? color.new(bull_col, 97) : trend == -1 ? color.new(bear_col, 97) : na
bgcolor(struct_bg, title="Structure Bias Background")

// ── Current structure label ───────────────────────────────────────────────────
var label info_label = na
if barstate.islast
    label.delete(info_label)
    trend_txt  = trend == 1 ? "Bullish" : trend == -1 ? "Bearish" : "Undefined"
    trend_c    = trend == 1 ? bull_col : bear_col
    info_label := label.new(bar_index, high, "Structure: " + trend_txt, style=label.style_label_left, color=color.new(trend_c, 20), textcolor=color.white, size=size.small)
````
