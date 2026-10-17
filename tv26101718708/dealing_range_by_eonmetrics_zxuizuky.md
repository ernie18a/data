# Dealing Range by EonMetrics

- url: https://www.tradingview.com/script/zXUIZUKy-Dealing-Range-by-EonMetrics/
- type: indicator
- pine_id: PUB;deec07c93cee4f249efef804ba176468
- version: 1.0

## Description

Dealing Range by EonMetrics

[b]WHAT IT DOES[/b]

This indicator draws one box around the exact price range you're currently trading inside — from the most recent significant low up to the most recent significant high (or vice versa). It then splits that box into two halves at the exact middle: the top half is labeled "Premium" (price here is relatively expensive — a place to look for selling opportunities) and the bottom half is labeled "Discount" (price here is relatively cheap — a place to look for buying opportunities). The exact halfway line is called "Equilibrium" — a common point where price pauses or reverses.

https://www.tradingview.com/x/UzhDFqW2/

Instead of waiting for both ends of the range to fully finish forming (which most similar tools do, and which makes the box lag behind price), one end of this box is locked to the last confirmed turning point, while the other end keeps following the live price in real time. This means the box always contains the current candle and never leaves it stranded outside — you're never looking at a stale, outdated range.

[b]HOW TO ACTUALLY USE IT (STEP BY STEP)[/b]

1. Decide which side you want to trade, then wait for price to come to you — don't chase it in the middle of the box.
   - Looking to buy (go long)? Wait for price to fall all the way down into the green Discount zone before considering an entry.
   - Looking to sell (go short)? Wait for price to rise all the way up into the red Premium zone before considering an entry.
2. Once price reaches the zone you're waiting for, look for an actual trigger before entering — a reversal candle, a price gap, a small break of structure — rather than buying or selling the instant price merely touches the colored area.
3. Treat the Equilibrium (halfway) line as a "fair value" reference — price often reacts around this line before deciding its next move, so it can act as a first target or a place price pauses on the way to the far zone.
4. Watch the two dots marking the range's boundaries (0 = the low, 1 = the high) — these are the exact swing points the box is built from.
5. The box updates and can shift over time as new swings form — that's expected behavior, not a bug; it means the range is following the market's current structure.

https://www.tradingview.com/x/If4bt9yj/

[b]EVERY SETTING EXPLAINED[/b]

Range Detection group
- Swing Length — how many candles on each side must be smaller/bigger for a point to count as a real turning point. A bigger number only catches major, important swings (slower-updating, bigger ranges); a smaller number catches minor ones (faster-updating, smaller ranges).
- Lock Range Until Band Break — when ON (recommended), the box stays fixed in place while price bounces around inside it, and only redraws once price actually breaks all the way out through the top or bottom. When OFF, the box updates every time a new turning point confirms, which reacts faster but can shift the box around more while you're watching it.

Visualization group
- Premium Zone — fill color of the top (expensive) half.
- Discount Zone — fill color of the bottom (cheap) half.
- Boundary Lines (0 / 1) — color of the lines marking the very top and bottom of the box.
- Show Equilibrium (50%) — turns the halfway line on or off.
- Equilibrium Color.
- Equilibrium Style — solid, dashed, or dotted line.
- Extend Right — stretches the box and lines all the way to the right edge of your chart. Turn off to have them stop at the current candle instead.

Swing Markers group
- Show Swing Points — turns on two small dots marking exactly where the box's high and low come from.
- High Swing (1) / Low Swing (0) — colors for those two dots.

Labels group
- Show Fib Levels (0 / 0.5 / 1) — labels the bottom of the box as "0", the middle as "0.5", and the top as "1" (standard reference numbers used to describe where price sits inside the range).
- Show Premium / Discount Labels — writes the words "Premium" and "Discount" inside each half.
- Show Prices — adds the actual price number next to the 0 / 0.5 / 1 labels.
- Label Position — puts the text labels on the right side (following the current candle) or the left side (where the range originally started).
- Label Text Color.

## Source Code

````pine
//@version=6
indicator("Dealing Range by EonMetrics", overlay=true, max_boxes_count=10, max_lines_count=10, max_labels_count=20)

// Draws the current dealing range as the LEG between the most recent alternating
// swing Low and swing High — ICT Premium / Discount.
//   • Top half  = Premium (red)   → look for sells
//   • Bottom half = Discount (green) → look for buys
//   • Split at the 50% Equilibrium, with Fib 0 / 0.5 / 1 levels and swing markers.
// A single, correctly-anchored current range — deliberately simple.
// (Historical chain, OTE golden-pocket zones, alerts and MTF live in OTE Suite.)

// ═══════════════════════════════════════════════════════════════════════════════
//  RANGE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
group_det = "Range Detection"

swing_len = input.int(20, "Swing Length", minval=2,
  group=group_det,
  tooltip="Bars on each side of a pivot used to confirm swing Highs and Lows (left arm = right arm). The range is built from two alternating confirmed swings, so it always frames a real leg. Larger values track major swings; smaller values react to minor ones. A swing confirms this many bars after it forms — the range never repaints.")

lock_range = input.bool(true, "Lock Range Until Band Break",
  group=group_det,
  tooltip="ON (recommended): once a range is drawn it stays put while price retraces. A new range only appears when price breaks OUT through the 0 or 1 boundary. Intermediate swings that confirm inside the range are ignored, keeping the zone stable while you wait for a reaction.\n\nOFF: the range re-anchors to every newly confirmed swing (developing-leg mode) — more responsive but the zone can shift mid-retracement.")

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALIZATION
// ═══════════════════════════════════════════════════════════════════════════════
group_viz = "Visualization"

premium_color = input.color(color.new(color.red, 88), "Premium Zone",
  group=group_viz,
  tooltip="Fill for the upper half of the range (above Equilibrium, Fib 0.5–1). Price here is 'expensive' — ICT context favours looking for sells.")

discount_color = input.color(color.new(color.green, 88), "Discount Zone",
  group=group_viz,
  tooltip="Fill for the lower half of the range (below Equilibrium, Fib 0–0.5). Price here is 'cheap' — ICT context favours looking for buys.")

boundary_color = input.color(color.new(color.gray, 35), "Boundary Lines (0 / 1)",
  group=group_viz,
  tooltip="Colour of the High (1) and Low (0) boundary lines that frame the dealing range.")

show_eq = input.bool(true, "Show Equilibrium (50%)",
  group=group_viz,
  tooltip="Draws the 50% midpoint line (Fib 0.5) that splits Premium from Discount. The Equilibrium is the fair-value level price often retraces to.")

eq_color = input.color(color.new(color.gray, 0), "Equilibrium Color",
  group=group_viz,
  tooltip="Colour of the 50% Equilibrium line.")

eq_style_inp = input.string("Dashed", "Equilibrium Style", options=["Solid", "Dashed", "Dotted"],
  group=group_viz,
  tooltip="Line style for the Equilibrium (50%) line.")

extend_right = input.bool(true, "Extend Right",
  group=group_viz,
  tooltip="Extend the zones, boundaries and Equilibrium to the right edge of the chart. When off, the drawing stops at the current bar.")

// ═══════════════════════════════════════════════════════════════════════════════
//  SWING MARKERS
// ═══════════════════════════════════════════════════════════════════════════════
group_sw = "Swing Markers"

show_dots = input.bool(true, "Show Swing Points",
  group=group_sw,
  tooltip="Marks the two swings that define the range with a dot: a Low dot (Fib 0) and a High dot (Fib 1).")

high_dot_color = input.color(color.red, "High Swing (1)",
  group=group_sw,
  tooltip="Colour of the dot placed on the swing High that forms the top of the range.")

low_dot_color = input.color(color.green, "Low Swing (0)",
  group=group_sw,
  tooltip="Colour of the dot placed on the swing Low that forms the bottom of the range.")

// ═══════════════════════════════════════════════════════════════════════════════
//  LABELS
// ═══════════════════════════════════════════════════════════════════════════════
group_lbl = "Labels"

show_fib = input.bool(true, "Show Fib Levels (0 / 0.5 / 1)",
  group=group_lbl,
  tooltip="Labels the Low boundary as 0, the Equilibrium as 0.5 and the High boundary as 1.")

show_zones = input.bool(true, "Show Premium / Discount Labels",
  group=group_lbl,
  tooltip="Adds 'Premium' and 'Discount' text inside the two halves of the range.")

show_prices = input.bool(false, "Show Prices",
  group=group_lbl,
  tooltip="Append the price of the High, Low and Equilibrium levels to their Fib labels.")

label_pos = input.string("Right", "Label Position", options=["Right", "Left"],
  group=group_lbl,
  tooltip="Anchor labels to the right edge (current bar) or the left edge (where the leg began).")

text_color = input.color(color.white, "Label Text Color",
  group=group_lbl,
  tooltip="Colour of all text labels.")

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
eq_line_style() =>
    switch eq_style_inp
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

fmt(float p) => str.tostring(p, format.mintick)

// ═══════════════════════════════════════════════════════════════════════════════
//  DEVELOPING-LEG RANGE
//  The range is the leg currently in progress: one end is the most recent CONFIRMED
//  swing (the anchor), the other end is the LIVE extreme on the opposite side since
//  that swing. So the range always contains price and follows the active move
//  immediately — no waiting `swing_len` bars for the opposite pivot to confirm.
//    • anchor = swing High  → down-leg: top fixed at the High, bottom tracks the live Low
//    • anchor = swing Low   → up-leg:   bottom fixed at the Low,  top tracks the live High
//  When the live extreme later confirms as a pivot, it becomes the new anchor (re-anchor).
//  And if price breaks back THROUGH the anchor before that pivot confirms, the leg has
//  reversed: the live extreme is promoted to the new anchor immediately (breakout flip),
//  so the range always contains price. A flipped anchor locks at the flip; only the live
//  side keeps moving.
// ═══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(swing_len, swing_len)
pl = ta.pivotlow(swing_len, swing_len)

// Window extremes since a pivot forms (swing_len+1 bars = from the pivot bar to now).
// Called every bar (execution-model safe) — used only when re-seeding the live side.
win_low   = ta.lowest(low,   swing_len + 1)
win_lowb  = ta.lowestbars(low,   swing_len + 1)
win_high  = ta.highest(high, swing_len + 1)
win_highb = ta.highestbars(high, swing_len + 1)

var float anchor      = na   // last confirmed swing value (the fixed end)
var int   anchor_bar  = na
var int   anchor_time = na   // open-time of the anchor bar (for xloc.bar_time drawing)
var int   anchor_dir  = 0    // 1 = anchor is a High (down-leg), -1 = anchor is a Low (up-leg)

// ── Re-anchor on a freshly CONFIRMED pivot (the clean, non-repainting case) ──
// When lock_range is ON, only direction-FLIPPING pivots are blocked:
//   • Up-leg   (anchor_dir == -1): block ph → would flip to down-leg.
//   • Down-leg (anchor_dir ==  1): block pl → would flip to up-leg.
// Same-direction pivots (higher lows in up-leg, lower highs in down-leg) are always allowed.
// First pivot always seeds (no anchor yet → lock inactive).
have_range_lock = not na(anchor) and lock_range
block_ph = have_range_lock and anchor_dir == -1
block_pl = have_range_lock and anchor_dir ==  1

bool reseed = false
if not na(ph) and not block_ph
    anchor      := ph
    anchor_bar  := bar_index - swing_len
    anchor_time := time[swing_len]
    anchor_dir  := 1
    reseed := true
if not na(pl) and not block_pl
    anchor      := pl
    anchor_bar  := bar_index - swing_len
    anchor_time := time[swing_len]
    anchor_dir  := -1
    reseed := true

var float live_val  = na     // running extreme on the developing (opposite) side
var int   live_bar  = na
var int   live_time = na     // open-time of the live-extreme bar (for xloc.bar_time drawing)

// ── Breakout flip: price has violated the frozen anchor on its OWN side, so the leg
//    has reversed. Promote the current live extreme to the new (now frozen) anchor and
//    start tracking the breakout side live — instead of stranding the old anchor until a
//    new pivot confirms swing_len bars later. The range therefore always contains price.
bool flipped = false
if not reseed and not na(anchor) and not na(live_val)
    if anchor_dir == 1 and high > anchor
        // new high above a down-leg High → flip to an up-leg from the live Low
        anchor      := live_val
        anchor_bar  := live_bar
        anchor_time := live_time
        anchor_dir  := -1
        live_val    := high
        live_bar    := bar_index
        live_time   := time
        flipped     := true
    else if anchor_dir == -1 and low < anchor
        // new low below an up-leg Low → flip to a down-leg from the live High
        anchor      := live_val
        anchor_bar  := live_bar
        anchor_time := live_time
        anchor_dir  := 1
        live_val    := low
        live_bar    := bar_index
        live_time   := time
        flipped     := true

if reseed
    // seed the live side from the window between the new pivot and now
    if anchor_dir == 1
        live_val  := win_low
        live_bar  := bar_index + win_lowb
        live_time := time[-win_lowb]
    else
        live_val  := win_high
        live_bar  := bar_index + win_highb
        live_time := time[-win_highb]
else if not flipped and anchor_dir == 1
    // down-leg → push the live Low lower as price falls
    if na(live_val) or low < live_val
        live_val  := low
        live_bar  := bar_index
        live_time := time
else if not flipped and anchor_dir == -1
    // up-leg → push the live High higher as price rises
    if na(live_val) or high > live_val
        live_val  := high
        live_bar  := bar_index
        live_time := time

has_range = not na(anchor) and not na(live_val) and anchor != live_val

// Resolve High / Low ends (anchor + live side), guarded so the box never inverts
hi_val   = math.max(anchor, live_val)
lo_val   = math.min(anchor, live_val)
hi_bar   = anchor >= live_val ? anchor_bar : live_bar
lo_bar   = anchor <  live_val ? anchor_bar : live_bar
leg_left = math.min(anchor_bar, live_bar)

// ═══════════════════════════════════════════════════════════════════════════════
//  DRAW
//  Single live range — rebuilt on the last bar (and each realtime tick). The anchor
//  end is a confirmed swing (no repaint); the opposite end is the live extreme and
//  the right edge both follow price.
// ═══════════════════════════════════════════════════════════════════════════════
var box   prem_box = na
var box   disc_box = na
var line  hi_line  = na
var line  lo_line  = na
var line  eq_line  = na
var label hi_dot   = na
var label lo_dot   = na
var label hi_lbl   = na
var label lo_lbl   = na
var label eq_lbl   = na
var label prem_lbl = na
var label disc_lbl = na

if barstate.islast and has_range
    // wipe the previous build (delete on a na id is a safe no-op)
    box.delete(prem_box)
    box.delete(disc_box)
    line.delete(hi_line)
    line.delete(lo_line)
    line.delete(eq_line)
    label.delete(hi_dot)
    label.delete(lo_dot)
    label.delete(hi_lbl)
    label.delete(lo_lbl)
    label.delete(eq_lbl)
    label.delete(prem_lbl)
    label.delete(disc_lbl)

    eq           = (hi_val + lo_val) / 2.0
    right_time   = time
    ext          = extend_right ? extend.right : extend.none

    leg_left_time = anchor_bar <= live_bar ? anchor_time : live_time
    hi_bar_time   = anchor >= live_val ? anchor_time : live_time
    lo_bar_time   = anchor <  live_val ? anchor_time : live_time
    lbl_x_time    = label_pos == "Right" ? right_time : leg_left_time
    lbl_sty       = label_pos == "Right" ? label.style_label_left : label.style_label_right
    lbl_bg        = color.new(color.gray, 100)

    // Premium (top half) and Discount (bottom half) fills
    prem_box := box.new(leg_left_time, hi_val, right_time, eq,
      border_color=na, bgcolor=premium_color, extend=ext, xloc=xloc.bar_time)
    disc_box := box.new(leg_left_time, eq, right_time, lo_val,
      border_color=na, bgcolor=discount_color, extend=ext, xloc=xloc.bar_time)

    // Boundary lines — 1 (High) and 0 (Low)
    hi_line := line.new(leg_left_time, hi_val, right_time, hi_val,
      color=boundary_color, width=1, extend=ext, xloc=xloc.bar_time)
    lo_line := line.new(leg_left_time, lo_val, right_time, lo_val,
      color=boundary_color, width=1, extend=ext, xloc=xloc.bar_time)

    // Equilibrium — 0.5
    eq_line := show_eq ? line.new(leg_left_time, eq, right_time, eq,
      color=eq_color, style=eq_line_style(), width=1, extend=ext, xloc=xloc.bar_time) : na

    // Dots on the two ends of the leg (confirmed-swing anchor + live extreme)
    if show_dots
        hi_dot := label.new(hi_bar_time, hi_val, "",
          color=high_dot_color, style=label.style_circle, size=size.tiny, xloc=xloc.bar_time)
        lo_dot := label.new(lo_bar_time, lo_val, "",
          color=low_dot_color, style=label.style_circle, size=size.tiny, xloc=xloc.bar_time)

    if show_fib
        hi_lbl := label.new(lbl_x_time, hi_val, "1" + (show_prices ? "  " + fmt(hi_val) : ""),
          color=lbl_bg, textcolor=text_color, style=lbl_sty, size=size.small, xloc=xloc.bar_time)
        lo_lbl := label.new(lbl_x_time, lo_val, "0" + (show_prices ? "  " + fmt(lo_val) : ""),
          color=lbl_bg, textcolor=text_color, style=lbl_sty, size=size.small, xloc=xloc.bar_time)
        eq_lbl := show_eq ? label.new(lbl_x_time, eq, "0.5" + (show_prices ? "  " + fmt(eq) : ""),
          color=lbl_bg, textcolor=text_color, style=lbl_sty, size=size.small, xloc=xloc.bar_time) : na

    if show_zones
        prem_lbl := label.new(lbl_x_time, (hi_val + eq) / 2.0, "Premium",
          color=lbl_bg, textcolor=text_color, style=lbl_sty, size=size.small, xloc=xloc.bar_time)
        disc_lbl := label.new(lbl_x_time, (eq + lo_val) / 2.0, "Discount",
          color=lbl_bg, textcolor=text_color, style=lbl_sty, size=size.small, xloc=xloc.bar_time)
````
