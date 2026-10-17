# CQ_(9)_Phase Counter + Adaptive Projection

- url: https://www.tradingview.com/script/ZLRUgcgm-CQ-9-Phase-Counter-Adaptive-Projection/
- type: indicator
- pine_id: PUB;686d89505c884b4cb429ec59caa60222
- version: 13.0

## Description

================================================================================
CQ_(9)_Phase Counter + Adaptive Projection
User Manual & Function Reference
Pine Script v6 | TradingView | Author: CQuevedo345 / Based on Julien Exe poblic code
================================================================================

--------------------------------------------------------------------------------
1. OVERVIEW
--------------------------------------------------------------------------------
This indicator is a ZigZag-based "phase counter" for price swings. It performs
four jobs at once, all built on the same underlying ZigZag pivot detection:

  1. Draws a confirmed ZigZag on the chart (bullish/bearish colored legs).
  2. Draws the currently forming ("live") leg separately, updating every bar.
  3. Projects two forward legs from the live price using the average
     length/slope of historical bullish and bearish legs (Adaptive Projection).
  4. Numbers every pivot 1-5 in a repeating cycle, anchored permanently to a
     specific pivot/time you choose, so the same physical pivot always shows
     the same number every time you reload the chart, refresh, or come back
     later (Leg Numbering / Phase Counter).

The indicator is overlay = true (draws directly on the price chart), and raises
Pine's drawing-object ceilings to max_lines_count = 500 and
max_labels_count = 500 so long pivot histories don't get silently truncated.

--------------------------------------------------------------------------------
2. VISUAL ELEMENTS ON THE CHART
--------------------------------------------------------------------------------
- CONFIRMED ZIGZAG LEGS: Solid/Dashed/Dotted lines connecting each confirmed
  pivot to the next. Colored per-leg: green-ish (Bullish Leg) if the leg fell
  from a high to a low... actually colored by comparing the leg's start/end
  price (see "Confirmed Style" settings) — bullish color when the earlier
  point is higher than the later one is NOT the rule; the rule used is:
  y1 > y2 -> Bullish color, else Bearish color, matching how each leg's own
  start (y1) and end (y2) prices compare.
- LIVE LEG: A separate line (style set by "Last Leg Style", default Dashed)
  connecting the most recent confirmed pivot to the current bar's close. This
  redraws every bar as price moves, showing the swing that hasn't reversed yet.
- ADAPTIVE PROJECTION: Up to two dotted (by default) forward-projected line
  segments extending from the current live price into the future. Segment 1
  completes the current leg out to the historical average length for its
  direction; Segment 2 projects the following opposite-direction leg using
  that direction's average length and slope. Purely illustrative/statistical
  — not a prediction guarantee.
- LEG NUMBER LABELS: A circled/styled digit (1-5, style configurable) placed
  at each pivot (or at that leg's midpoint, depending on settings), showing
  where that pivot falls in the repeating 1-5 counting cycle.
- ANCHOR MARKER (⚓): A small anchor-emoji label marking the exact pivot that
  was chosen as the permanent numbering origin, plus the leg number and
  timeframe it was anchored at (e.g. "⚓2 4h"). Only shown if enabled.

--------------------------------------------------------------------------------
3. SETTINGS REFERENCE
--------------------------------------------------------------------------------

--- GROUP: "🌀 Phases (ZigZag)" ---

Period (p1)
    Integer, default 45, range 10-100.
    Lookback window used to detect ZigZag pivots. A pivot high/low is
    confirmed when it is the highest high / lowest low over this many bars.
    Larger values = fewer, larger swings picked up; smaller values = more,
    smaller swings.

Bullish Leg / Bearish Leg (bull_color / bear_color)
    Colors for confirmed ZigZag legs, based on whether the leg's start price
    is above (bearish-looking down-leg colored "Bearish") or below
    ("Bullish") its end price.

Confirmed Style (s)
    Solid / Dashed / Dotted. Line style used for CONFIRMED ZigZag legs only.

Width (w)
    Integer, default 6, range 1-8. Line width for confirmed ZigZag legs (also
    reused for the live leg).

Last Leg Style (last_leg_style)
    Solid / Dashed / Dotted, default Dashed. Line style used ONLY for the
    live (currently forming, unconfirmed) leg, so it's visually distinct from
    confirmed legs even though it shares the same colors and width.

--- GROUP: "📈 Adaptive Projection" ---

Show Projection (show_projection)
    Boolean, default true. Master toggle for the two forward-projected line
    segments.

Bullish Projection / Bearish Projection (proj_bull_color / proj_bear_color)
    Colors for the projected segments, based on the direction of that
    specific projected segment (not the live leg's direction).

Style (proj_style)
    Solid / Dashed / Dotted, default Dotted. Line style for both projection
    segments.

Width (proj_width)
    Integer, default 1, range 1-5. Line width for both projection segments.

--- GROUP: "🔢 Leg Numbering" ---

Anchor Time (1h) / Anchor Pivot's Leg # (1h)
Anchor Time (4h) / Anchor Pivot's Leg # (4h)
Anchor Time (1d) / Anchor Pivot's Leg # (1d)
Anchor Time (1w) / Anchor Pivot's Leg # (1w)
Anchor Time (1m) / Anchor Pivot's Leg # (1m)
    Each of the 5 supported chart timeframes (1 hour, 4 hour, 1 day, 1 week,
    1 month) gets its OWN independent pair of settings:
      - Anchor Time: a specific date/time. The script finds whichever
        CONFIRMED pivot's time is closest to this timestamp and treats that
        exact pivot as the permanent numbering origin for that timeframe.
      - Anchor Pivot's Leg #: which number (1-5) that specific pivot should
        be labeled with. Every other pivot counts forward/backward from it,
        wrapping 5 back to 1 (and 1 back to 5 going the other direction).
    Because these are saved per-timeframe, switching timeframes never
    overwrites another timeframe's calibration.
    Defaults: 1h/1d/1w/1m = "2024-01-01 00:00", leg #1 (generic placeholders
    — recalibrate these to a pivot you can actually verify on your chart).
    4h = "2026-08-01 11:00 -0500", leg #2 (a working example calibration).

Anchor Timeframe Selection (anchor_tf_mode)
    Manual / Automatic, default Manual.
      - Manual: you explicitly pick which of the 5 saved anchor setups is
        "active" via the Anchor Timeframe (Manual) picker below, regardless
        of what timeframe the chart is actually showing. The counter only
        actually draws when the chart's real timeframe happens to match your
        pick — otherwise it stays silent.
      - Automatic: the script detects the chart's ACTUAL current timeframe
        itself (via timeframe.isintraday/isdaily/isweekly/ismonthly and
        timeframe.multiplier) and automatically uses that timeframe's saved
        anchor/leg#, with no manual switching needed. Flip between 1h, 4h,
        1d, 1w, and 1m charts and the same indicator instance keeps working,
        each using its own calibration. If the chart is on a timeframe
        outside those 5 presets (e.g. 15m, 2h, 12h), there is no saved
        anchor for it, so the counter silently displays nothing on that
        timeframe — same behavior as an unmatched Manual pick.

Anchor Timeframe (Manual) (anchor_tf_manual)
    1h / 4h / 1d / 1w / 1m, default 1h. Only used when Anchor Timeframe
    Selection above is set to Manual.

Mark Anchor Pivot (show_anchor_marker)
    Boolean, default true. Draws the ⚓ marker described in Section 2 on the
    pivot that was snapped to as the anchor, so you can visually confirm the
    right point was picked.

Numbering Style (char_style)
    One of: ①②③④⑤ / ❶❷❸❹❺ / Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ / 1️⃣2️⃣3️⃣4️⃣5️⃣ / ₁ ₂ ₃ ₄ ₅ / ⑴ ⑵ ⑶ ⑷ ⑸.
    Cosmetic choice of glyph set used to render the numbers 1 through 5.

Label Size (size_choice)
    Tiny / Small / Normal / Large / Huge, default Small. Size of the leg
    number labels.

Auto-Color by Leg Direction (auto_dir_color)
    Boolean, default true.
      - When ON: each label's background/text color is picked from the
        Bullish/Bearish Label Color settings below, based on whether the
        LEG THAT PIVOT STARTS rose or fell in price (background shown faded
        per "Label Background Fade %").
      - When OFF: every label instead uses the flat Custom Label Background
        Color / Custom Label Text Color below, ignoring direction entirely.

Bullish Label Color / Bearish Label Color (label_bull_color / label_bear_color)
    Colors used per-leg-direction when Auto-Color is ON.

Custom Label Background Color / Custom Label Text Color
(manual_bg_color / manual_txt_color)
    Flat colors used for all labels when Auto-Color is OFF.

Label Background Fade % (bg_fade_pct)
    Integer, default 90, range 0-100. Transparency applied to the label
    background color (0 = fully opaque, 100 = fully transparent). Text color
    is unaffected — it's shown at full opacity.

Label Position (label_pos)
    Pivot / Leg Midpoint, default Pivot.
      - Pivot: label sits directly on the pivot point itself.
      - Leg Midpoint: label sits halfway (averaging both time and price)
        along the leg that pivot STARTS — i.e. the leg running forward to
        the next numbered pivot. For the single newest numbered pivot (whose
        forward leg hasn't confirmed/frozen yet), the "next pivot" used for
        this averaging is the LIVE leg's current endpoint (current bar's
        time/close) rather than a confirmed pivot — so that one label keeps
        smoothly walking toward the eventual midpoint as the leg extends,
        instead of jumping abruptly the moment the leg finally confirms.

--------------------------------------------------------------------------------
4. HOW THE 1-5 NUMBERING CYCLE WORKS
--------------------------------------------------------------------------------
- Every confirmed pivot is assigned a number from 1 to 5, cycling
  continuously (…3,4,5,1,2,3,4,5,1…) in BOTH directions from a single anchor
  pivot you calibrate once.
- The anchor pivot is identified by finding whichever CONFIRMED pivot's
  timestamp is closest to your chosen "Anchor Time" for the active timeframe.
  Only confirmed pivots are eligible — the still-forming, constantly-moving
  newest pivot is deliberately excluded from this search, so the anchor never
  attaches itself to a point that later shifts position.
- Once found, that pivot's number is fixed to whatever you set in "Anchor
  Pivot's Leg #". Every pivot AFTER it counts forward with wraparound
  (5 -> 1); every pivot BEFORE it counts backward with the same wraparound
  (1 -> 5) applied in reverse.
- This entire numbering pass happens ONCE per chart load ("seeding"), the
  first time there are at least 2 confirmed pivots available. After that,
  each NEW pivot that confirms (i.e. the live leg finally reverses and
  freezes) is appended to the sequence by simply continuing the same forward
  wraparound from the last assigned number — it does not need to re-search
  for the anchor again.
- Because the anchor is a fixed timestamp saved in your settings (not a
  "most recent N pivots" scheme), the same physical pivot gets the same
  number every single time the script runs — after a refresh, a new
  session, or reopening the chart weeks later.

--------------------------------------------------------------------------------
5. TYPICAL SETUP WORKFLOW
--------------------------------------------------------------------------------
  1. Add the indicator to a chart on one of the 5 supported timeframes
     (1h, 4h, 1d, 1w, or 1m).
  2. Decide Manual or Automatic under "Anchor Timeframe Selection". Automatic
     is recommended if you plan to flip between several of the 5 supported
     timeframes on the same chart/instance.
  3. Identify a specific pivot on your chart you can clearly see and verify
     (e.g. a well-defined recent swing high/low).
  4. Set that timeframe's "Anchor Time" input to that pivot's timestamp, and
     set "Anchor Pivot's Leg #" to whatever number you want that specific
     pivot to represent (1 through 5) — this is your calibration choice, not
     something the script derives on its own.
  5. Enable "Mark Anchor Pivot" to visually confirm the ⚓ marker landed on
     the pivot you intended.
  6. Repeat steps 3-4 for any other timeframes you plan to use.
  7. Adjust cosmetic settings (numbering style, label size, colors, label
     position) to taste.

--------------------------------------------------------------------------------
6. LIMITS & BEHAVIOR NOTES
--------------------------------------------------------------------------------
- Hard ceiling of 500 lines and 500 labels total (Pine Script platform
  limit, set via max_lines_count / max_labels_count). With very long pivot
  histories on low timeframes, the oldest labels/lines may eventually stop
  being drawable — no trimming logic recycles them.
- All drawings use xloc.bar_time (absolute timestamps) rather than
  xloc.bar_index, specifically so that pivots far back in chart history
  don't trigger Pine's "x-value too far from current bar" restriction.
- The leg-numbering pass and the anchor marker only render on the last bar
  (barstate.islast) — cosmetic labels are not drawn bar-by-bar historically,
  only re-drawn fresh each time the last bar updates.
- If the chart's real timeframe does not match the active anchor timeframe
  (manual mismatch, or Automatic on an unsupported timeframe), the counter
  intentionally shows nothing rather than displaying numbers that don't
  correspond to the pivots you're actually viewing.
- The projection segments extrapolate from historical AVERAGE leg
  length/slope; they are not forecasts and carry no statistical guarantee of
  accuracy.

================================================================================
FUNCTION REFERENCE
================================================================================

--------------------------------------------------------------------------------
f_drawLeg(arr, x1, y1, x2, y2, col, lw, sty)
--------------------------------------------------------------------------------
Purpose:
    Draws a single ZigZag/live-leg line segment and registers it in a
    tracking array for later cleanup (delete-before-redraw pattern).
Parameters:
    arr  - array<line>, the registry this new line gets pushed into.
    x1,y1 - start point (x1 = a UNIX-ms timestamp, since xloc.bar_time is
            used; y1 = price).
    x2,y2 - end point (same coordinate system as x1,y1).
    col   - line color.
    lw    - line width.
    sty   - style string: "Solid", "Dashed", or "Dotted".
Returns:
    Nothing directly; the created line.new() reference is appended to `arr`.
Notes:
    Always uses xloc = xloc.bar_time to avoid Pine's bar-index distance
    restriction on historical drawings.

--------------------------------------------------------------------------------
add_to_zigzag(p, v, b)
--------------------------------------------------------------------------------
Purpose:
    Inserts a brand-new pivot (a fresh reversal) at the FRONT of the pivot
    array, storing it as a [price, time] pair.
Parameters:
    p - array<float>, the pivot array (`z`).
    v - float, the pivot's price.
    b - float/int, the pivot's time (UNIX ms).
Returns:
    Nothing (mutates `p` in place). After the two unshifts, p[0] = price,
    p[1] = time for the new pivot.

--------------------------------------------------------------------------------
update_zigzag(p, v, b, d)
--------------------------------------------------------------------------------
Purpose:
    Updates the CURRENTLY FORMING pivot (front of the array) in place as a
    swing continues to extend, rather than creating a new pivot entry.
Parameters:
    p - array<float>, the pivot array (`z`).
    v - float, candidate new extreme price.
    b - float/int, candidate new time.
    d - int, current direction (1 = up/bullish, -1 = down/bearish).
Behavior:
    - If `p` is empty, delegates to add_to_zigzag() to seed the first pivot.
    - Otherwise, only overwrites p[0]/p[1] if the new price is a more
      extreme high (d==1) or more extreme low (d==-1) than what's currently
      stored — i.e. the swing is still extending in the same direction.
Returns:
    0. (dummy numeric return; the real effect is the in-place mutation.)

--------------------------------------------------------------------------------
f_tfMatches(sel)
--------------------------------------------------------------------------------
Purpose:
    Checks whether the CHART'S ACTUAL current timeframe matches one of the 5
    supported preset buckets.
Parameters:
    sel - string, one of "1h", "4h", "1d", "1w", "1m" (the timeframe being
          tested against).
Returns:
    bool - true if the chart's real timeframe (via timeframe.isintraday /
    isdaily / isweekly / ismonthly plus timeframe.multiplier) matches `sel`;
    false otherwise (including for any `sel` value outside the 5 presets).
Notes:
    Compares structurally (intraday/daily/weekly/monthly + multiplier)
    rather than string-matching timeframe.period, since raw period strings
    ("60" vs "1H", etc.) vary across data feeds/script versions.

--------------------------------------------------------------------------------
f_detectTf()
--------------------------------------------------------------------------------
Purpose:
    The reverse of f_tfMatches() — with no preset given, works out on its
    own which (if any) of the 5 supported buckets the chart's actual current
    timeframe falls into. Powers "Automatic" anchor timeframe mode.
Parameters:
    None (reads timeframe.isintraday/isdaily/isweekly/ismonthly and
    timeframe.multiplier directly).
Returns:
    string - one of "1h", "4h", "1d", "1w", "1m" if the chart's timeframe
    matches a supported preset, otherwise "none".
Notes:
    Returning "none" is intentional: downstream, f_tfMatches("none") falls
    through every case to its default `false`, so the counter cleanly stays
    silent on unsupported timeframes with no special-case handling required
    elsewhere in the script.

--------------------------------------------------------------------------------
f_labelSize(sel)
--------------------------------------------------------------------------------
Purpose:
    Maps the "Label Size" dropdown's string value to the corresponding Pine
    `size.*` constant.
Parameters:
    sel - string, one of "Tiny", "Small", "Normal", "Large", "Huge".
Returns:
    A `size.*` built-in constant (size.tiny / size.small / size.normal /
    size.large / size.huge).

--------------------------------------------------------------------------------
f_legChar(num, style)
--------------------------------------------------------------------------------
Purpose:
    Converts a leg number (1-5) into the display glyph for the user's chosen
    numbering style.
Parameters:
    num   - int, 1 through 5.
    style - string, one of the 6 supported style option strings (e.g.
            "①②③④⑤").
Returns:
    string - the single glyph representing `num` in the chosen style
    (e.g. f_legChar(3, "①②③④⑤") returns "③").
Notes:
    Internally builds all 6 possible 5-element glyph arrays every call and
    picks the matching one; simple and correct at this scale, not optimized
    for call frequency (only invoked inside the once-per-last-bar label
    redraw loop, so this is not a performance concern in practice).

================================================================================
END OF DOCUMENT
================================================================================

## Source Code

````pine
//@version=6
indicator('CQ_(9)_Phases Counter + Adaptive Projection', overlay = true, max_lines_count = 500, max_labels_count = 500)

// 🌀 ZIGZAG SETTINGS
grp_zz = "🌀 Phases (ZigZag)"
p1 = input.int(45, 'Period', 10, 100, group = grp_zz)

bull_color = input.color(color.rgb(0, 137, 123), 'Bullish Leg', inline = 'zzcol', group = grp_zz)
bear_color = input.color(color.rgb(255, 153, 0), 'Bearish Leg', inline = 'zzcol', group = grp_zz)

s = input.string('Solid', 'Confirmed Style', ['Solid', 'Dashed', 'Dotted'], inline = 'zzstyle', group = grp_zz)
w = input.int(2, 'Width', 1, 8, inline = 'zzstyle', group = grp_zz)

last_leg_style = input.string('Dashed', 'Active Leg Style', ['Solid', 'Dashed', 'Dotted'], group = grp_zz)
prev_leg_style = input.string('Solid', 'Unconfirmed Leg Style', ['Solid', 'Dashed', 'Dotted'], group = grp_zz)

show_leg_markers = input.bool(true, 'Mark Active Leg Start/End', inline = 'legmark', group = grp_zz)
marker_size_choice = input.string('Small', '', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline = 'legmark', group = grp_zz)

show_prev_leg_markers = input.bool(true, 'Mark Unconfirmed Leg Start/End', inline = 'legmark2', group = grp_zz)
prev_marker_size_choice = input.string('Normal', '', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline = 'legmark2', group = grp_zz)

f_drawLeg(arr, x1, y1, x2, y2, col, lw, sty) =>
    line_style = sty == 'Solid' ? line.style_solid : sty == 'Dashed' ? line.style_dashed : line.style_dotted
    ml = line.new(x1 = x1, y1 = y1, x2 = x2, y2 = y2, xloc = xloc.bar_time, color = col, width = lw, style = line_style)
    array.push(arr, ml)

f_labelSize(sel) =>
    sel == "Tiny" ? size.tiny : sel == "Small" ? size.small : sel == "Normal" ? size.normal : sel == "Large" ? size.large : size.huge

float ph = ta.highestbars(high, p1) == 0 ? high : na
float pl = ta.lowestbars(low, p1) == 0 ? low : na

isPh = not na(ph)
isPl = not na(pl)

var dir = 0
prev_dir = dir
dir := isPh and not isPl ? 1 : isPl and not isPh ? -1 : dir
dc = dir != prev_dir ? 1 : 0

var z = array.new_float(0)
var zbar = array.new_int(0)

add_to_zigzag(p, pb, v, b, bidx) =>
    array.unshift(p, b)
    array.unshift(p, v)
    array.unshift(pb, bidx)

update_zigzag(p, pb, v, b, d, bidx) =>
    if array.size(p) == 0
        add_to_zigzag(p, pb, v, b, bidx)
    else if (d == 1 and v > array.get(p, 0)) or (d == -1 and v < array.get(p, 0))
        array.set(p, 0, v)
        array.set(p, 1, b)
        array.set(pb, 0, bidx)
    0.

if isPh or isPl
    if dc != 0
        add_to_zigzag(z, zbar, dir == 1 ? ph : pl, time, bar_index)
    else if not(isPh and isPl)
        update_zigzag(z, zbar, dir == 1 ? ph : pl, time, dir, bar_index)

var array<line> zigzag_lines = array.new_line()
var array<label> prev_leg_markers = array.new_label()
if array.size(z) >= 4
    while array.size(zigzag_lines) > 0
        line.delete(array.pop(zigzag_lines))
    while array.size(prev_leg_markers) > 0
        label.delete(array.pop(prev_leg_markers))

    last_valid = array.size(z) - 4
    if last_valid >= 0
        for i = 0 to last_valid by 2
            x1 = int(array.get(z, i + 1))
            y1 = array.get(z, i)
            x2 = int(array.get(z, i + 3))
            y2 = array.get(z, i + 2)
            leg_color = y1 > y2 ? bull_color : bear_color
            leg_style = i == 0 ? prev_leg_style : s
            f_drawLeg(zigzag_lines, x1, y1, x2, y2, leg_color, w, leg_style)

            if i == 0 and show_prev_leg_markers
                prev_marker_size = f_labelSize(prev_marker_size_choice)
                prev_start_marker = label.new(x1, y1, "◯",
                     xloc = xloc.bar_time,
                     style = label.style_label_center,
                     color = color.new(color.white, 100),
                     textcolor = leg_color,
                     size = prev_marker_size)
                prev_end_marker = label.new(x2, y2, "◯",
                     xloc = xloc.bar_time,
                     style = label.style_label_center,
                     color = color.new(color.white, 100),
                     textcolor = leg_color,
                     size = prev_marker_size)
                array.push(prev_leg_markers, prev_start_marker)
                array.push(prev_leg_markers, prev_end_marker)

grp_proj = "📈 Adaptive Projection"
show_projection = input.bool(true, "Show Projection", group = grp_proj)
proj_bull_color = input.color(color.rgb(0, 137, 123), 'Bullish Projection', inline = 'projcol', group = grp_proj)
proj_bear_color = input.color(color.rgb(255, 153, 0), 'Bearish Projection', inline = 'projcol', group = grp_proj)
proj_style = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = 'proj', group = grp_proj)
proj_width = input.int(1, "Width", 1, 5, inline = 'proj', group = grp_proj)

var float avg_bearish_length = 0.0
var float avg_bullish_length = 0.0
var float avg_bearish_slope = 0.0
var float avg_bullish_slope = 0.0

if array.size(z) >= 4
    bearish_lengths = array.new_float(0)
    bullish_lengths = array.new_float(0)
    bearish_slopes = array.new_float(0)
    bullish_slopes = array.new_float(0)
    i = 0
    while i < array.size(z) - 2
        yA = array.get(z, i)
        xA = array.get(z, i + 1)
        yB = array.get(z, i + 2)
        xB = array.get(z, i + 3)
        if xA != xB
            segment_direction = yA > yB ? 1 : -1
            segment_length = math.abs(yA - yB)
            segment_slope = (yA - yB) / (xA - xB)
            if segment_direction == -1
                array.push(bearish_lengths, segment_length)
                array.push(bearish_slopes, segment_slope)
            else
                array.push(bullish_lengths, segment_length)
                array.push(bullish_slopes, segment_slope)
        i += 2
    avg_bearish_length := array.size(bearish_lengths) > 0 ? array.avg(bearish_lengths) : 0
    avg_bullish_length := array.size(bullish_lengths) > 0 ? array.avg(bullish_lengths) : 0
    avg_bearish_slope := array.size(bearish_slopes) > 0 ? array.avg(bearish_slopes) : 0
    avg_bullish_slope := array.size(bullish_slopes) > 0 ? array.avg(bullish_slopes) : 0

grp_leg = "🔢 Leg Numbering"

anchor_time_1h = input.time(timestamp("2024-01-01 00:00"), "Pivot⚓ (1H)", group = grp_leg, inline = '1H',
     tooltip = "Anchor time used only when Anchor Timeframe below is set to 1h.")
last_verified_leg_1h = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '1H',
     tooltip = "Phase number (1-5) that belongs to the 1H anchor pivot above.")

anchor_time_4h = input.time(timestamp("2026-08-01T11:00:00-0500"), "Pivot⚓ (4H)", group = grp_leg, inline = '4H',
     tooltip = "Anchor time used only when Anchor Timeframe below is set to 4h.")
last_verified_leg_4h = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '4H',
     tooltip = "Phase number (1-5) that belongs to the 4H anchor pivot above.")

anchor_time_1d = input.time(timestamp("2026-05-05 19:00"), "Pivot⚓ (1D)", group = grp_leg, inline = '1D',
     tooltip = "Anchor time used only when Anchor Timeframe below is set to 1D.")
last_verified_leg_1d = input.int(5, "", minval = 1, maxval = 5, group = grp_leg, inline = '1D',
     tooltip = "Phase number (1-5) that belongs to the 1D anchor pivot above.")

anchor_time_1w = input.time(timestamp("2024-01-01 00:00"), "Pivot⚓ (1W)", group = grp_leg, inline = '1W',
     tooltip = "Anchor time used only when Anchor Timeframe below is set to 1W.")
last_verified_leg_1w = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '1W',
     tooltip = "Phase number (1-5) that belongs to the 1W anchor pivot above.")

anchor_time_1m = input.time(timestamp("2024-01-01 00:00"), "Pivot⚓ (1M)", group = grp_leg, inline = '1M',
     tooltip = "Anchor time used only when Anchor Timeframe below is set to 1M.")
last_verified_leg_1m = input.int(1, "", minval = 1, maxval = 5, group = grp_leg, inline = '1M',
     tooltip = "Phase number (1-5) that belongs to the 1M anchor pivot above.")

f_tfMatches(sel) =>
    switch sel
        "1h" => timeframe.isintraday and timeframe.multiplier == 60
        "4h" => timeframe.isintraday and timeframe.multiplier == 240
        "1d" => timeframe.isdaily and timeframe.multiplier == 1
        "1w" => timeframe.isweekly and timeframe.multiplier == 1
        "1m" => timeframe.ismonthly and timeframe.multiplier == 1
        => false

f_detectTf() =>
    timeframe.isintraday and timeframe.multiplier == 60 ? "1h" :
     timeframe.isintraday and timeframe.multiplier == 240 ? "4h" :
     timeframe.isdaily and timeframe.multiplier == 1 ? "1d" :
     timeframe.isweekly and timeframe.multiplier == 1 ? "1w" :
     timeframe.ismonthly and timeframe.multiplier == 1 ? "1m" :
     "none"

anchor_tf_mode = input.string("Manual", "Anchor Timeframe Selection", options = ["Manual", "Automatic"], group = grp_leg,
     tooltip = "Manual: the 'Anchor Timeframe' picker below chooses which saved anchor/leg# setup is active, regardless of what timeframe the chart is actually on — the counter only displays when the chart happens to match your pick. Automatic: the script detects the chart's current timeframe itself and switches to that timeframe's saved anchor/leg# automatically, so the same instance keeps working as you flip between 1h/4h/1d/1w/1m charts with no manual switching. On a timeframe outside those 5 presets, Automatic has no saved anchor to use and the counter stays silent, same as an unmatched Manual pick.")
anchor_tf_manual = input.string("1h", "Anchor Timeframe (Manual)", options = ["1h", "4h", "1d", "1w", "1m"], group = grp_leg,
     tooltip = "Only used when Anchor Timeframe Selection above is set to Manual. The chart timeframe this anchor/leg-numbering setup was built for. Picking a timeframe here selects which anchor time above is active, and the counter (labels + anchor marker) only displays when the chart is actually on this timeframe — so the same indicator instance stays silent and uncluttered on every other timeframe instead of numbering pivots that don't correspond to this setup.")

detected_tf = f_detectTf()
anchor_tf = anchor_tf_mode == "Automatic" ? detected_tf : anchor_tf_manual

anchor_time = switch anchor_tf
    "1h" => anchor_time_1h
    "4h" => anchor_time_4h
    "1d" => anchor_time_1d
    "1w" => anchor_time_1w
    "1m" => anchor_time_1m
    => anchor_time_1h

tf_matches = f_tfMatches(anchor_tf)

last_verified_leg = switch anchor_tf
    "1h" => last_verified_leg_1h
    "4h" => last_verified_leg_4h
    "1d" => last_verified_leg_1d
    "1w" => last_verified_leg_1w
    "1m" => last_verified_leg_1m
    => last_verified_leg_1h
show_anchor_marker = input.bool(true, "Mark Anchor Pivot", group = grp_leg,
     tooltip = "Draws a small ⚓ marker on the pivot that was snapped to as the anchor, so you can confirm the right point was picked.")
char_style = input.string("①②③④⑤", "Numbering Style", options = ["①②③④⑤", "❶❷❸❹❺", "Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ", "1️⃣2️⃣3️⃣4️⃣5️⃣", "₍₁₎ ₍₂₎ ₍₃₎ ₍₄₎ ₍₅₎", "⑴ ⑵ ⑶ ⑷ ⑸"], group = grp_leg)
size_choice = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_leg)

auto_dir_color = input.bool(true, "Auto-Color by Leg Direction", group = grp_leg,
     tooltip = "When enabled, each label's background and text use the Bullish/Bearish Label colors set below, based on whether that leg's price rose or fell from the prior one (background shown faded per the Fade % below). Disable to use the custom colors below instead.")
label_bull_color = input.color(color.rgb(0, 137, 123), 'Bullish Label Color', inline = 'lblcol', group = grp_leg)
label_bear_color = input.color(color.rgb(255, 153, 0), 'Bearish Label Color', inline = 'lblcol', group = grp_leg)
manual_bg_color = input.color(color.rgb(54, 58, 69, 50), "Custom Label Background Color", group = grp_leg)
manual_txt_color = input.color(color.rgb(255, 255, 255, 50), "Custom Label Text Color", group = grp_leg)
bg_fade_pct = input.int(90, "Label Background Fade %", minval = 0, maxval = 100, group = grp_leg)
label_pos = input.string("Pivot", "Label Position", options = ["Pivot", "Leg Midpoint"], group = grp_leg,
     tooltip = "Pivot: label sits on the pivot point itself (original behavior). Leg Midpoint: label sits halfway (in both time and price) along the leg this pivot starts — the leg connecting it to the next numbered pivot. The newest numbered label tracks the leg's live in-progress endpoint until that leg is confirmed, so it walks smoothly toward the eventual midpoint instead of jumping once the leg freezes.")

lbl_size = f_labelSize(size_choice)

f_legChar(num, style) =>
    style1 = array.from("①", "②", "③", "④", "⑤")
    style2 = array.from("❶", "❷", "❸", "❹", "❺")
    style3 = array.from("Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ")
    style4 = array.from("1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣")
    style5 = array.from("₍₁₎", "₍₂₎", "₍₃₎", "₍₄₎", "₍₅₎")
    style6 = array.from("⑴", "⑵", "⑶", "⑷", "⑸")
    chosen = style == "①②③④⑤" ? style1 : style == "❶❷❸❹❺" ? style2 : style == "Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ" ? style3 : style == "1️⃣2️⃣3️⃣4️⃣5️⃣" ? style4 : style == "₍₁₎ ₍₂₎ ₍₃₎ ₍₄₎ ₍₅₎" ? style5 : style6
    array.get(chosen, num - 1)

f_invertTendencyCol(col) =>
    col == label_bull_color ? label_bear_color : col == label_bear_color ? label_bull_color : col

var array<int>   leg_bar_arr   = array.new_int(0)
var array<float> leg_price_arr = array.new_float(0)
var array<int>   leg_num_arr   = array.new_int(0)

var bool seeded             = false
var int  last_recorded_bar  = na
var int  last_assigned_num  = na
var label anchor_label      = na
var int  anchor_bar_saved   = na
var float anchor_price_saved = na
var bool  anchor_is_high    = false

if barstate.islast and not seeded and array.size(z) >= 4
    num_pairs = int(array.size(z) / 2)

    anchor_idx = 2
    best_diff = float(na)
    for i = 1 to num_pairs - 1
        t = array.get(z, i * 2 + 1)
        diff = math.abs(t - anchor_time)
        if na(best_diff) or diff < best_diff
            best_diff := diff
            anchor_idx := i * 2

    neighbor_idx = anchor_idx + 2 <= array.size(z) - 2 ? anchor_idx + 2 : (anchor_idx - 2 >= 0 ? anchor_idx - 2 : anchor_idx)
    anchor_is_high := array.get(z, anchor_idx) > array.get(z, neighbor_idx)

    for idx = (num_pairs - 1) * 2 to 2 by 2
        num = 0
        if idx > anchor_idx
            step_back = int((idx - anchor_idx) / 2)
            num := ((last_verified_leg - 1 - step_back) % 5 + 5) % 5 + 1
        else
            step_fwd = int((anchor_idx - idx) / 2)
            num := (last_verified_leg - 1 + step_fwd) % 5 + 1
        array.push(leg_bar_arr, int(array.get(z, idx + 1)))
        array.push(leg_price_arr, array.get(z, idx))
        array.push(leg_num_arr, num)

    anchor_bar_saved := int(array.get(z, anchor_idx + 1))
    anchor_price_saved := array.get(z, anchor_idx)

    last_recorded_bar := int(array.get(z, 3))
    last_assigned_num := array.get(leg_num_arr, array.size(leg_num_arr) - 1)
    seeded := true

if seeded and array.size(z) >= 4
    frozen_bar = int(array.get(z, 3))
    if frozen_bar != last_recorded_bar
        frozen_px = array.get(z, 2)
        next_num = last_assigned_num % 5 + 1
        array.push(leg_bar_arr, frozen_bar)
        array.push(leg_price_arr, frozen_px)
        array.push(leg_num_arr, next_num)
        last_assigned_num := next_num
        last_recorded_bar := frozen_bar

var array<label> leg_labels = array.new_label()
if barstate.islast
    while array.size(leg_labels) > 0
        label.delete(array.pop(leg_labels))
    label.delete(anchor_label)
    anchor_label := na

    if tf_matches
        if array.size(leg_num_arr) > 0
            last_leg_i = array.size(leg_num_arr) - 1
            for i = 0 to last_leg_i
                bx  = array.get(leg_bar_arr, i)
                px  = array.get(leg_price_arr, i)
                num = array.get(leg_num_arr, i)

                dir_color = i == last_leg_i ? label_bull_color : (array.get(leg_price_arr, i + 1) > px ? label_bull_color : label_bear_color)
                bg_col  = auto_dir_color ? color.new(dir_color, bg_fade_pct) : color.new(manual_bg_color, bg_fade_pct)
                txt_col = auto_dir_color ? dir_color : manual_txt_color

                next_x = i < last_leg_i ? array.get(leg_bar_arr, i + 1) : time
                next_y = i < last_leg_i ? array.get(leg_price_arr, i + 1) : close
                lbl_x = label_pos == "Leg Midpoint" ? int(math.round((bx + next_x) / 2.0)) : bx
                lbl_y = label_pos == "Leg Midpoint" ? (px + next_y) / 2.0 : px

                lbl = label.new(lbl_x, lbl_y, f_legChar(num, char_style),
                     xloc = xloc.bar_time,
                     style = label.style_label_center,
                     color = bg_col,
                     textcolor = txt_col,
                     size = lbl_size)
                array.push(leg_labels, lbl)

        if show_anchor_marker and not na(anchor_bar_saved)
            anchor_buf = ta.atr(20) * 2
            anchor_y = anchor_is_high ? anchor_price_saved + anchor_buf : anchor_price_saved - anchor_buf
            anchor_style = anchor_is_high ? label.style_label_down : label.style_label_up
            anchor_label := label.new(anchor_bar_saved, anchor_y, "⚓" + str.tostring(last_verified_leg) + " " + anchor_tf,
                 xloc = xloc.bar_time,
                 style = anchor_style,
                 color = color.new(color.blue, 0),
                 textcolor = color.white,
                 size = size.small)

var array<line> current_leg_lines = array.new_line()
var array<label> current_leg_markers = array.new_label()
var float last_pivot_y = na
var int last_pivot_x = na
if array.size(z) >= 2
    while array.size(current_leg_lines) > 0
        line.delete(array.pop(current_leg_lines))
    while array.size(current_leg_markers) > 0
        label.delete(array.pop(current_leg_markers))
    last_pivot_y := array.get(z, 0)
    last_pivot_x := int(array.get(z, 1))
    live_leg_color = close > last_pivot_y ? bull_color : bear_color
    f_drawLeg(current_leg_lines, last_pivot_x, last_pivot_y, time, close, live_leg_color, w, last_leg_style)

    if show_leg_markers
        marker_size = f_labelSize(marker_size_choice)
        start_marker = label.new(last_pivot_x, last_pivot_y, "◯",
             xloc = xloc.bar_time,
             style = label.style_label_center,
             color = color.new(color.white, 100),
             textcolor = live_leg_color,
             size = marker_size)
        end_marker = label.new(time, close, "◯",
             xloc = xloc.bar_time,
             style = label.style_label_center,
             color = color.new(color.white, 100),
             textcolor = live_leg_color,
             size = marker_size)
        array.push(current_leg_markers, start_marker)
        array.push(current_leg_markers, end_marker)

p0_bar = array.size(zbar) > 0 ? array.get(zbar, 0) : int(na)
p1_bar = array.size(zbar) > 1 ? array.get(zbar, 1) : int(na)

leg_window_len = na(p1_bar) ? int(na) : bar_index - p1_bar + 1
leg_high = na(leg_window_len) ? float(na) : ta.highest(high, leg_window_len)
leg_low = na(leg_window_len) ? float(na) : ta.lowest(low, leg_window_len)

active_window_len = na(p0_bar) ? int(na) : bar_index - p0_bar + 1
active_leg_high = na(active_window_len) ? float(na) : ta.highest(high, active_window_len)
active_leg_low = na(active_window_len) ? float(na) : ta.lowest(low, active_window_len)

prev_confirmed_leg_bars = array.size(zbar) >= 2 ? array.get(zbar, 0) - array.get(zbar, 1) : int(na)

var int current_direction = 0
var float current_length = 0.0
var float current_slope = 0.0
if not na(last_pivot_x)
    current_direction := close > last_pivot_y ? 1 : -1
    current_length := math.abs(close - last_pivot_y)
    dx = math.max(1.0, float(time - last_pivot_x))
    current_slope := (close - last_pivot_y) / dx

var line extension_line1 = na
var line extension_line2 = na
if array.size(z) >= 2 and show_projection and not na(current_slope)
    line.delete(extension_line1)
    line.delete(extension_line2)
    start_x = time
    start_y = close
    ms_per_bar = timeframe.in_seconds() * 1000
    max_future_ms = 500 * ms_per_bar
    max_x = start_x + max_future_ms
    last_zigzag_length = current_length
    projection_length1 = current_direction == 1 ? (avg_bullish_length > last_zigzag_length ? avg_bullish_length - last_zigzag_length : 0) : (avg_bearish_length > last_zigzag_length ? avg_bearish_length - last_zigzag_length : 0)
    abs_slope_current = math.max(1e-10, math.abs(current_slope))
    proj_line_style = proj_style == 'Solid' ? line.style_solid : proj_style == 'Dashed' ? line.style_dashed : line.style_dotted
    if projection_length1 > 0
        raw_dx1 = int(math.round(projection_length1 / abs_slope_current))
        dx1 = math.max(1, math.min(raw_dx1, max_x - start_x))
        end_x1 = start_x + dx1
        end_y1 = start_y + current_slope * dx1
        seg1_color = current_direction == 1 ? proj_bull_color : proj_bear_color
        extension_line1 := line.new(x1 = start_x, y1 = start_y, x2 = end_x1, y2 = end_y1, xloc = xloc.bar_time, extend = extend.none, color = seg1_color, width = proj_width, style = proj_line_style)
        projection_length2 = current_direction == 1 ? avg_bearish_length : avg_bullish_length
        projection_slope2 = current_direction == 1 ? avg_bearish_slope : avg_bullish_slope
        abs_slope2 = math.max(1e-10, math.abs(projection_slope2))
        raw_dx2 = int(math.round(projection_length2 / abs_slope2))
        dx2 = math.max(1, math.min(raw_dx2, max_x - end_x1))
        end_x2 = end_x1 + dx2
        end_y2 = end_y1 + projection_slope2 * dx2
        seg2_color = current_direction == 1 ? proj_bear_color : proj_bull_color
        extension_line2 := line.new(x1 = end_x1, y1 = end_y1, x2 = end_x2, y2 = end_y2, xloc = xloc.bar_time, extend = extend.none, color = seg2_color, width = proj_width, style = proj_line_style)
    else
        projection_length2 = current_direction == 1 ? avg_bearish_length : avg_bullish_length
        projection_slope2 = current_direction == 1 ? avg_bearish_slope : avg_bullish_slope
        abs_slope2 = math.max(1e-10, math.abs(projection_slope2))
        raw_dx2 = int(math.round(projection_length2 / abs_slope2))
        dx2 = math.max(1, math.min(raw_dx2, max_x - start_x))
        end_x2 = start_x + dx2
        end_y2 = start_y + projection_slope2 * dx2
        seg2_color = current_direction == 1 ? proj_bear_color : proj_bull_color
        extension_line2 := line.new(x1 = start_x, y1 = start_y, x2 = end_x2, y2 = end_y2, xloc = xloc.bar_time, extend = extend.none, color = seg2_color, width = proj_width, style = proj_line_style)

// === 📊 PHASE STATISTICS TABLE ===
grp_stats = "📊 Phase Statistics Table"
show_stats_table = input.bool(true, "Show Table", group = grp_stats)
stats_orientation = input.string("Vertical", "Orientation", options = ["Vertical", "Horizontal"], group = grp_stats)
stats_position = input.string("Bottom Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grp_stats)
stats_text_size = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grp_stats)
stats_header_bg = input.color(color.rgb(19, 29, 58, 30), "Header Background", inline = 'statshdr', group = grp_stats)
stats_header_txt = input.color(color.rgb(104, 138, 212), "Header Text", inline = 'statshdr', group = grp_stats)
stats_cell_bg = input.color(color.rgb(13, 20, 39, 30), "Cell Background", inline = 'statscell', group = grp_stats)
stats_cell_txt = input.color(color.rgb(255, 255, 255), "Cell Text", inline = 'statscell', group = grp_stats)
stats_dir_text_mode = input.string("Tendency Color", "Value Cell Style", options = ["White", "Tendency Color", "Tendency Background"], group = grp_stats,
     tooltip = "Controls how every value cell in the table (Dir, High/Low, Growth, Bars, Retracement, etc.) is colored, based on which leg that cell belongs to. White: flat 'Cell Background' with flat 'Cell Text'. Tendency Color: flat 'Cell Background' with text colored by that leg's own Bullish/Bearish Label Color. Tendency Background: the cell's background itself is colored by that leg's Bullish/Bearish color (set below), with a single flat text color (set below) on top.")
stats_tendbg_bull_color = input.color(color.rgb(0, 137, 123, 85), "Tendency BG: Bullish", inline = 'tendbgcol', group = grp_stats,
     tooltip = "Only used when Value Cell Style above is set to Tendency Background. Background color for value cells belonging to a bullish leg.")
stats_tendbg_bear_color = input.color(color.rgb(255, 153, 0, 85), "Tendency BG: Bearish", inline = 'tendbgcol', group = grp_stats,
     tooltip = "Only used when Value Cell Style above is set to Tendency Background. Background color for value cells belonging to a bearish leg.")
stats_tendbg_txt_color = input.color(color.white, "Tendency BG: Text Color", group = grp_stats,
     tooltip = "Only used when Value Cell Style above is set to Tendency Background. Flat text color drawn over the colored backgrounds above.")
stats_border_color = input.color(color.rgb(0, 0, 0), "Border Color", group = grp_stats)
retrace_bar_style = input.string("▩ / ▢", "Retracement Bar Glyphs", options = ["▩ / ▢", "▮ / ▯", "⁞ / .", "● / ◌"], group = grp_stats,
     tooltip = "Filled / empty character pair used to draw the 10-segment retracement scale in the table.")
show_retrace_bar = input.bool(true, "Show Retracement Progress Bar", group = grp_stats,
     tooltip = "When enabled, every Retracement value gets its own extra cell holding just the 10-segment progress bar, right next to its %/$ value. Disable to omit the bar entirely and show only the % and $ retracement values.")
table_layout = input.string("Original", "Table Layout", options = ["Original", "By Leg/Phase Number"], group = grp_stats,
     tooltip = "Original: the single-column layout as originally designed, where Tendency/Growth describe only the previous (last confirmed) leg while Bars/Retracement show both legs. By Leg/Phase Number: the same metrics reorganized into matched groups, one per leg number, with every metric computed for each leg shown.")
num_legs_shown = input.int(5, "Legs Shown", minval = 2, maxval = 10, group = grp_stats,
     tooltip = "How many legs the Phase Statistics table displays, counting the active (still-forming) leg plus confirmed legs going backward in time. 2 shows just Active + Previous. Higher values add more historical, fully-closed legs to the left (Original layout) or as extra left-hand columns/rows (By Leg/Phase Number layout) — each computed from fixed pivot-to-pivot data, showing — for any leg beyond how much zigzag history has formed yet.")
show_retrace_targets = input.bool(true, "Show Retracement % Targets", group = grp_stats,
     tooltip = "Adds 3 separate 'Retracement %' cells (40%, 50%, 60%) for every leg shown in the table, each giving the price at that retracement level of the leg's own range (measured from its more recent pivot back toward its older one; the Active leg uses its forming pivot and the current price).")
show_reached_marker = input.bool(true, "Mark Reached Retracement Levels", group = grp_stats,
     tooltip = "When enabled, a Retracement % target cell (40/50/60%) gets the Reached Marker Glyph appended to its price once price has actually retraced that far. Historical legs use their final, confirmed retracement; the Previous leg uses the live Active Retracement %; the Active leg's own targets are forward-looking projections and never show as reached.")
reached_marker_glyph = input.string("▶", "Reached Marker Glyph", options = ["▶", "→", "✓", "★"], group = grp_stats)

// 📐 TABLE POSITION PADDING
// Adds an invisible, fully transparent padding row above and below, and a
// padding column to the left and right of, the table's actual content —
// each merged into a single cell spanning its whole side, so no extra grid
// lines show through. Because the table is always anchored to one
// corner/edge (per the Position input above), growing one of these padding
// cells changes the table's total footprint and shifts where the visible
// content lands relative to that anchor — a fine-grained way to nudge the
// table without touching the coarse Position preset. Defaults to 0 (no
// padding, i.e. today's behavior). ▦▲ ▼▦ ►▦ ▦◄
//
// Claude Instructions:
// The pasted script shows a table, add a row at the top, bottom and left and right side,
// the extra rows will be used as padding to manually move the table from the original position up,
// down, right or left. Merge the cells on the added rows/columns and make them completely
// transparent. Allow the user to increase the size of the columns and/or rows in order to
// fine tune the location of the table on the chart.

grp_pad = "📐 Table Position Fine Tunning"
pad_top = input.float(0, "▼▦", minval = 0, maxval = 100, inline = 'padTB', group = grp_pad,
     tooltip = "Height (as a % of the table) of an invisible row added above the table's content. Tune this to nudge the table's on-screen position.")
pad_bottom = input.float(0, "▦▲", minval = 0, maxval = 100, inline = 'padTB', group = grp_pad,
     tooltip = "Height (as a % of the table) of an invisible row added below the table's content. Tune this to nudge the table's on-screen position.")
pad_left = input.float(0, "►▦", minval = 0, maxval = 100, inline = 'padLR', group = grp_pad,
     tooltip = "Width (as a % of the table) of an invisible column added to the left of the table's content. Tune this to nudge the table's on-screen position.")
pad_right = input.float(0, "▦◄", minval = 0, maxval = 100, inline = 'padLR', group = grp_pad,
     tooltip = "Width (as a % of the table) of an invisible column added to the right of the table's content. Tune this to nudge the table's on-screen position.")

f_tablePos(sel) =>
    switch sel
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_statsTextSize(sel) =>
    sel == "Tiny" ? size.tiny : sel == "Small" ? size.small : sel == "Normal" ? size.normal : sel == "Large" ? size.large : size.huge

stats_size = f_statsTextSize(stats_text_size)

f_addCommas(numStr) =>
    len = str.length(numStr)
    result = ""
    cnt = 0
    for i = len - 1 to 0
        ch = str.substring(numStr, i, i + 1)
        result := ch + result
        cnt += 1
        if cnt % 3 == 0 and i != 0
            result := "," + result
    result

f_fmtPrice(price) =>
    sign = price < 0 ? "-" : ""
    rounded = math.round(math.abs(price))
    intStr = str.tostring(rounded, "#")
    sign + "$" + f_addCommas(intStr)

f_fmtPct(pct) =>
    str.tostring(pct, "#.#") + "%"

// Three separate "Retracement %" target cells (40%, 50%, 60%) for a leg
// spanning newPx (more recent end) -> oldPx (older end). Works regardless of
// whether the leg was bullish or bearish, and degrades to em-dashes when
// either endpoint isn't available yet. achieved_pct is the actual retracement
// % already reached against this same leg's range (na when not applicable,
// e.g. the Active leg's own forward-looking targets) — any tier at or below
// it gets the Reached Marker Glyph appended.
f_retraceLevelTexts(newPx, oldPx, achieved_pct) =>
    p40 = newPx - (newPx - oldPx) * 0.40
    p50 = newPx - (newPx - oldPx) * 0.50
    p60 = newPx - (newPx - oldPx) * 0.60
    marker = show_reached_marker ? " " + reached_marker_glyph : ""
    t40 = na(p40) ? "—" : f_fmtPrice(p40) + (not na(achieved_pct) and achieved_pct >= 40 ? marker : "")
    t50 = na(p50) ? "—" : f_fmtPrice(p50) + (not na(achieved_pct) and achieved_pct >= 50 ? marker : "")
    t60 = na(p60) ? "—" : f_fmtPrice(p60) + (not na(achieved_pct) and achieved_pct >= 60 ? marker : "")
    [t40, t50, t60]

f_retraceBar(pct, glyph_style) =>
    filled = math.max(0, math.min(10, int(math.round(pct / 10))))
    fill_ch = glyph_style == "▩ / ▢" ? "▩" : glyph_style == "▮ / ▯" ? "▮" : glyph_style == "⁞ / ." ? "⁞" : "●"
    empty_ch = glyph_style == "▩ / ▢" ? "▢" : glyph_style == "▮ / ▯" ? "▯" : glyph_style == "⁞ / ." ? "." : "◌"
    bar = ""
    for i = 1 to 10
        bar := bar + (i <= filled ? fill_ch : empty_ch)
    bar

// Maps a leg's tendency color (either label_bull_color, label_bear_color, or a
// neutral fallback such as stats_cell_txt) to the corresponding user-customizable
// background color for the "Tendency Background" Value Cell Style. Neutral colors
// (no leg direction yet) fall back to the flat stats_cell_bg.
f_tendBgColor(col) =>
    col == label_bull_color ? stats_tendbg_bull_color : col == label_bear_color ? stats_tendbg_bear_color : stats_cell_bg

// Draws the transparent padding frame (top/bottom rows, left/right
// columns) around a table's content block. `total_cols`/`total_rows` are
// the FULL grid dimensions — content plus the 2 extra padding columns and
// 2 extra padding rows the caller already added when sizing the table.
// The top/bottom rows each span the table's full width (so they also cover
// the top-left/top-right/bottom-left/bottom-right corners); the left/right
// columns then only need to span the remaining middle rows.
f_addTablePadding(t, total_cols, total_rows, top_h, bottom_h, left_w, right_w) =>
    transparent = color.new(color.black, 100)
    table.cell(t, 0, 0, "", height = top_h, bgcolor = transparent)
    table.merge_cells(t, 0, 0, total_cols - 1, 0)
    table.cell(t, 0, total_rows - 1, "", height = bottom_h, bgcolor = transparent)
    table.merge_cells(t, 0, total_rows - 1, total_cols - 1, total_rows - 1)
    table.cell(t, 0, 1, "", width = left_w, bgcolor = transparent)
    table.merge_cells(t, 0, 1, 0, total_rows - 2)
    table.cell(t, total_cols - 1, 1, "", width = right_w, bgcolor = transparent)
    table.merge_cells(t, total_cols - 1, 1, total_cols - 1, total_rows - 2)

var table statsTable = na
if barstate.islast
    table.delete(statsTable)
    if show_stats_table and not na(leg_high) and not na(leg_low)
        bars_in_leg = na(p0_bar) ? 0 : bar_index - p0_bar + 1
        leg_size = leg_high - leg_low

        prev_leg_num = seeded ? last_assigned_num : int(na)
        prior_confirmed_leg_num = seeded and array.size(leg_num_arr) >= 2 ? array.get(leg_num_arr, array.size(leg_num_arr) - 2) : int(na)
        active_leg_num = seeded ? (last_assigned_num % 5 + 1) : na

        p1_price = array.size(z) >= 4 ? array.get(z, 2) : float(na)
        leg_tendency = na(p1_price) ? 0 : (close > p1_price ? 1 : close < p1_price ? -1 : 0)
        tendency_label = na(prev_leg_num) ? "Dir" : f_legChar(prev_leg_num, char_style) + " Dir"
        tendency_txt = leg_tendency == 1 ? "UP" : leg_tendency == -1 ? "DN" : "—"
        tendency_col = leg_tendency == 1 ? label_bull_color : leg_tendency == -1 ? label_bear_color : stats_cell_txt

        prior_leg_size = array.size(z) >= 4 ? math.abs(array.get(z, 0) - array.get(z, 2)) : na
        retrace_dollar = current_length
        retrace_pct = not na(prior_leg_size) and prior_leg_size > 0 ? (retrace_dollar / prior_leg_size) * 100 : na
        retrace_pct_txt = na(retrace_pct) ? "—" : f_fmtPct(retrace_pct)
        retrace_dollar_txt = na(prior_leg_size) ? "—" : f_fmtPrice(retrace_dollar)
        retrace_bar_txt = na(retrace_pct) ? "" : f_retraceBar(retrace_pct, retrace_bar_style)
        retrace_label = na(prev_leg_num) ? "Active\nRetrcmnt" : f_legChar(active_leg_num, char_style) + " Active\nRetrcmnt"

        // === Per-leg Retracement % targets (40/50/60% of that leg's own range), each its own cell ===
        // Previous confirmed leg (P1 -> P0); achieved_pct is the live Active Retracement % (retrace_pct),
        // since the active leg retracing this same P1->P0 range is exactly what that figure measures:
        [prev_retrace_40, prev_retrace_50, prev_retrace_60] = f_retraceLevelTexts(array.size(z) >= 4 ? array.get(z, 0) : float(na), array.size(z) >= 4 ? array.get(z, 2) : float(na), retrace_pct)
        // Active (still-forming) leg, using its start pivot and the current price — these are forward-looking
        // projections for once the leg reverses, so they never show as reached (achieved_pct = na):
        [active_retrace_40, active_retrace_50, active_retrace_60] = f_retraceLevelTexts(na(last_pivot_y) ? float(na) : close, last_pivot_y, float(na))

        confirmed_prior_size = array.size(z) >= 6 ? math.abs(array.get(z, 2) - array.get(z, 4)) : na
        unconf_retrace_dollar = array.size(z) >= 4 ? math.abs(close - array.get(z, 2)) : na
        unconf_retrace_pct = not na(confirmed_prior_size) and confirmed_prior_size > 0 and not na(unconf_retrace_dollar) ? (unconf_retrace_dollar / confirmed_prior_size) * 100 : na
        unconf_retrace_pct_txt = na(unconf_retrace_pct) ? "—" : f_fmtPct(unconf_retrace_pct)
        unconf_retrace_dollar_txt = na(unconf_retrace_dollar) or na(confirmed_prior_size) ? "—" : f_fmtPrice(unconf_retrace_dollar)
        unconf_retrace_bar_txt = na(unconf_retrace_pct) ? "" : f_retraceBar(unconf_retrace_pct, retrace_bar_style)
        unconf_retrace_label = na(prior_confirmed_leg_num) ? "Previous\nRetrcmnt" : f_legChar(prev_leg_num, char_style) + " Previous\nRetrcmnt"

        // === Historical legs further left (leg index j: 2 = one left of "Previous", 3 = two left, ...) ===
        // num_legs_shown counts Active + Previous + these historical legs, so we loop j = 2..num_legs_shown-1.
        num_hist_legs = num_legs_shown - 1
        hist_prefix          = array.new_string(0)
        hist_tendency_txt     = array.new_string(0)
        hist_tendency_col     = array.new_color(0)
        hist_hilo_txt         = array.new_string(0)
        hist_growth_txt       = array.new_string(0)
        hist_bars_txt         = array.new_string(0)
        hist_retrace_txt      = array.new_string(0)
        hist_retrace_bar_txt  = array.new_string(0)
        hist_retrace_40       = array.new_string(0)
        hist_retrace_50       = array.new_string(0)
        hist_retrace_60       = array.new_string(0)

        for j = 2 to num_hist_legs
            idx_new = 2 * (j - 1)
            idx_old = 2 * j
            has_leg_j = array.size(z) >= idx_old + 2
            leg_num_j = seeded and array.size(leg_num_arr) >= j ? array.get(leg_num_arr, array.size(leg_num_arr) - j) : int(na)
            prefix_j = na(leg_num_j) ? "Leg-" + str.tostring(j) : f_legChar(leg_num_j, char_style)
            bars_j = has_leg_j and array.size(zbar) >= j + 1 ? array.get(zbar, j - 1) - array.get(zbar, j) : int(na)
            high_j = has_leg_j ? math.max(array.get(z, idx_new), array.get(z, idx_old)) : float(na)
            low_j  = has_leg_j ? math.min(array.get(z, idx_new), array.get(z, idx_old)) : float(na)
            size_j = has_leg_j ? math.abs(array.get(z, idx_new) - array.get(z, idx_old)) : float(na)
            tendency_j = has_leg_j ? (array.get(z, idx_new) > array.get(z, idx_old) ? 1 : -1) : 0
            tendency_txt_j = tendency_j == 1 ? "UP" : tendency_j == -1 ? "DN" : "—"
            tendency_col_j = tendency_j == 1 ? label_bull_color : tendency_j == -1 ? label_bear_color : stats_cell_txt
            hilo_txt_j = na(high_j) or na(low_j) ? "—" : f_fmtPrice(high_j) + "\n" + f_fmtPrice(low_j)
            growth_txt_j = na(size_j) ? "—" : f_fmtPrice(size_j)
            bars_txt_j = na(bars_j) ? "—" : str.tostring(bars_j)
            // retracement: how much the NEXT (more recent) confirmed leg retraced this one
            next_new_idx = 2 * (j - 2)
            next_dollar_j = array.size(z) > idx_new ? math.abs(array.get(z, next_new_idx) - array.get(z, idx_new)) : float(na)
            next_pct_j = has_leg_j and not na(next_dollar_j) and size_j > 0 ? (next_dollar_j / size_j) * 100 : na
            next_pct_txt_j = na(next_pct_j) ? "—" : f_fmtPct(next_pct_j)
            next_dollar_txt_j = na(next_dollar_j) ? "—" : f_fmtPrice(next_dollar_j)
            next_bar_txt_j = na(next_pct_j) ? "" : f_retraceBar(next_pct_j, retrace_bar_style)
            retrace_combo_j = next_pct_txt_j + "\n" + next_dollar_txt_j
            // this leg's own Retracement % targets, marked reached against its actual (final) retracement next_pct_j:
            [retrace_40_j, retrace_50_j, retrace_60_j] = f_retraceLevelTexts(has_leg_j ? array.get(z, idx_new) : float(na), has_leg_j ? array.get(z, idx_old) : float(na), next_pct_j)

            array.push(hist_prefix, prefix_j)
            array.push(hist_tendency_txt, tendency_txt_j)
            array.push(hist_tendency_col, tendency_col_j)
            array.push(hist_hilo_txt, hilo_txt_j)
            array.push(hist_growth_txt, growth_txt_j)
            array.push(hist_bars_txt, bars_txt_j)
            array.push(hist_retrace_txt, retrace_combo_j)
            array.push(hist_retrace_bar_txt, next_bar_txt_j)
            array.push(hist_retrace_40, retrace_40_j)
            array.push(hist_retrace_50, retrace_50_j)
            array.push(hist_retrace_60, retrace_60_j)

        hist_n = array.size(hist_prefix)

        leg_hilo_label = na(prev_leg_num) ? "Leg High\n/Low" : f_legChar(prev_leg_num, char_style) + " Phase\nHigh/Low"
        leg_hilo_txt = f_fmtPrice(leg_high) + "\n" + f_fmtPrice(leg_low)
        retrace_combo_txt = retrace_pct_txt + "\n" + retrace_dollar_txt
        unconf_retrace_combo_txt = unconf_retrace_pct_txt + "\n" + unconf_retrace_dollar_txt

        actual_size_txt = na(active_leg_num) ? str.tostring(bars_in_leg) : f_legChar(active_leg_num, char_style) + "  " + str.tostring(bars_in_leg)
        prev_size_txt = na(prev_confirmed_leg_bars) ? "—" : (na(prev_leg_num) ? str.tostring(prev_confirmed_leg_bars) : f_legChar(prev_leg_num, char_style) + "  " + str.tostring(prev_confirmed_leg_bars))
        bars_label_txt = "Active Bars (Projected)" + "\n" + "Prev.   Bars (Unconfirmed)"
        bars_combo_txt = actual_size_txt + "\n" + prev_size_txt

        prev_bars_plain = na(prev_confirmed_leg_bars) ? "—" : str.tostring(prev_confirmed_leg_bars)
        active_bars_plain = str.tostring(bars_in_leg)

        active_tendency = current_direction
        active_tendency_txt = active_tendency == 1 ? "UP" : active_tendency == -1 ? "DN" : "—"
        active_tendency_col = active_tendency == 1 ? label_bull_color : active_tendency == -1 ? label_bear_color : stats_cell_txt
        active_hilo_txt = na(active_leg_high) or na(active_leg_low) ? "—" : f_fmtPrice(active_leg_high) + "\n" + f_fmtPrice(active_leg_low)
        active_growth_txt = na(active_leg_high) or na(active_leg_low) ? "—" : f_fmtPrice(active_leg_high - active_leg_low)

        prev_prefix_lbl = na(prev_leg_num) ? "Previous" : f_legChar(prev_leg_num, char_style)
        active_prefix_lbl = na(active_leg_num) ? "Active" : f_legChar(active_leg_num, char_style)

        labels_arr = array.new_string(0)
        values_arr = array.new_string(0)
        row_tendcol_arr = array.new_color(0)

        array.push(labels_arr, tendency_label + "\nUnconfirmed")
        array.push(values_arr, tendency_txt)
        array.push(row_tendcol_arr, tendency_col)
        array.push(labels_arr, leg_hilo_label + "\nUnconfirmed")
        array.push(values_arr, leg_hilo_txt)
        array.push(row_tendcol_arr, tendency_col)
        array.push(labels_arr, f_legChar(prev_leg_num, char_style) + " Growght" + "\nUnconfirmed")
        array.push(values_arr, f_fmtPrice(leg_size))
        array.push(row_tendcol_arr, tendency_col)
        array.push(labels_arr, bars_label_txt)
        array.push(values_arr, bars_combo_txt)
        array.push(row_tendcol_arr, tendency_col)
        array.push(labels_arr, retrace_label + "\nProjected")
        array.push(values_arr, retrace_combo_txt)
        array.push(row_tendcol_arr, tendency_col)
        if show_retrace_bar
            array.push(labels_arr, retrace_label + " Bar" + "\nProjected")
            array.push(values_arr, retrace_bar_txt)
            array.push(row_tendcol_arr, tendency_col)
        array.push(labels_arr, unconf_retrace_label + "\nUnconfirmed")
        array.push(values_arr, unconf_retrace_combo_txt)
        array.push(row_tendcol_arr, tendency_col)
        if show_retrace_bar
            array.push(labels_arr, unconf_retrace_label + " Bar" + "\nUnconfirmed")
            array.push(values_arr, unconf_retrace_bar_txt)
            array.push(row_tendcol_arr, tendency_col)

        for k = 0 to hist_n - 1
            prefix_k = array.get(hist_prefix, k)
            tcol_k = array.get(hist_tendency_col, k)
            array.push(labels_arr, prefix_k + "D")
            array.push(values_arr, array.get(hist_tendency_txt, k))
            array.push(row_tendcol_arr, tcol_k)
            array.push(labels_arr, prefix_k + " Phase\nHigh/Low")
            array.push(values_arr, array.get(hist_hilo_txt, k))
            array.push(row_tendcol_arr, tcol_k)
            array.push(labels_arr, prefix_k + " Growght")
            array.push(values_arr, array.get(hist_growth_txt, k))
            array.push(row_tendcol_arr, tcol_k)
            array.push(labels_arr, prefix_k + " Bars")
            array.push(values_arr, array.get(hist_bars_txt, k))
            array.push(row_tendcol_arr, tcol_k)
            array.push(labels_arr, prefix_k + " Retrcmnt")
            array.push(values_arr, array.get(hist_retrace_txt, k))
            array.push(row_tendcol_arr, tcol_k)
            if show_retrace_bar
                array.push(labels_arr, prefix_k + " Retrcmnt Bar")
                array.push(values_arr, array.get(hist_retrace_bar_txt, k))
                array.push(row_tendcol_arr, tcol_k)
        if show_retrace_targets
            // Three "Retracement %" rows (40%, 50%, 60%) per displayed leg, ordered oldest -> newest ->
            // Previous -> Active (matching the left-to-right column order used in the By Leg/Phase Number
            // layout). These rows use the INVERTED tendency color relative to the leg's own direction.
            for k = hist_n - 1 to 0
                prefix_k = array.get(hist_prefix, k)
                inv_col_k = f_invertTendencyCol(array.get(hist_tendency_col, k))
                array.push(labels_arr, prefix_k + "Rtd 40%")
                array.push(values_arr, array.get(hist_retrace_40, k))
                array.push(row_tendcol_arr, inv_col_k)
                array.push(labels_arr, prefix_k + "Rtd 50%")
                array.push(values_arr, array.get(hist_retrace_50, k))
                array.push(row_tendcol_arr, inv_col_k)
                array.push(labels_arr, prefix_k + "Rtd 60%")
                array.push(values_arr, array.get(hist_retrace_60, k))
                array.push(row_tendcol_arr, inv_col_k)
            inv_prev_col = f_invertTendencyCol(tendency_col)
            array.push(labels_arr, prev_prefix_lbl + "Rtd 40%" + "\nUnconfirmed")
            array.push(values_arr, prev_retrace_40)
            array.push(row_tendcol_arr, inv_prev_col)
            array.push(labels_arr, prev_prefix_lbl + "Rtd 50%" + "\nUnconfirmed")
            array.push(values_arr, prev_retrace_50)
            array.push(row_tendcol_arr, inv_prev_col)
            array.push(labels_arr, prev_prefix_lbl + "Rtd 60%" + "\nUnconfirmed")
            array.push(values_arr, prev_retrace_60)
            array.push(row_tendcol_arr, inv_prev_col)
            inv_active_col = f_invertTendencyCol(active_tendency_col)
            array.push(labels_arr, active_prefix_lbl + "Rtd 40%" + "\nProjected")
            array.push(values_arr, active_retrace_40)
            array.push(row_tendcol_arr, inv_active_col)
            array.push(labels_arr, active_prefix_lbl + "Rtd 50%" + "\nProjected")
            array.push(values_arr, active_retrace_50)
            array.push(row_tendcol_arr, inv_active_col)
            array.push(labels_arr, active_prefix_lbl + "Rtd 60%" + "\nProjected")
            array.push(values_arr, active_retrace_60)
            array.push(row_tendcol_arr, inv_active_col)
        n = array.size(labels_arr)

        title_txt = na(active_leg_num) ? "PHASES STATISTICS" : "PHASES STATISTICS"

        if table_layout == "Original"
            if stats_orientation == "Vertical"
                statsTable := table.new(f_tablePos(stats_position), 4, n + 3, border_width = 1, border_color = stats_border_color)
                table.cell(statsTable, 1, 1, title_txt, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                table.merge_cells(statsTable, 1, 1, 2, 1)
                for i = 0 to n - 1
                    lbl = array.get(labels_arr, i)
                    val = array.get(values_arr, i)
                    // Each row's tendency color was recorded at push time into
                    // row_tendcol_arr (see the labels_arr/values_arr build above),
                    // so no index math is needed here to figure out which leg or
                    // row-kind (value vs. bar vs. retracement target) a row is.
                    row_tendency_col = array.get(row_tendcol_arr, i)
                    val_txt_col = stats_dir_text_mode == "Tendency Color" ? row_tendency_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt
                    val_bg_col  = stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_tendency_col) : stats_cell_bg
                    table.cell(statsTable, 1, i + 2, lbl, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                    table.cell(statsTable, 2, i + 2, val, text_color = val_txt_col, bgcolor = val_bg_col, text_size = stats_size)
                f_addTablePadding(statsTable, 4, n + 3, pad_top, pad_bottom, pad_left, pad_right)
            else
                statsTable := table.new(f_tablePos(stats_position), n + 2, 5, border_width = 1, border_color = stats_border_color)
                table.cell(statsTable, 1, 1, title_txt, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                table.merge_cells(statsTable, 1, 1, n, 1)
                for i = 0 to n - 1
                    lbl = array.get(labels_arr, i)
                    val = array.get(values_arr, i)
                    // See the matching comment in the Vertical branch above — each
                    // row's tendency color was recorded at push time.
                    row_tendency_col = array.get(row_tendcol_arr, i)
                    val_txt_col = stats_dir_text_mode == "Tendency Color" ? row_tendency_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt
                    val_bg_col  = stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_tendency_col) : stats_cell_bg
                    table.cell(statsTable, i + 1, 2, lbl, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                    table.cell(statsTable, i + 1, 3, val, text_color = val_txt_col, bgcolor = val_bg_col, text_size = stats_size)
                f_addTablePadding(statsTable, n + 2, 5, pad_top, pad_bottom, pad_left, pad_right)
        else
            metric_labels = array.from("Dir", "High\nLow", "Growth", "Bars", "Retraced")
            if show_retrace_bar
                array.push(metric_labels, "Rtd %")
            if show_retrace_targets
                array.push(metric_labels, "Rtd 40%")
                array.push(metric_labels, "Rtd 50%")
                array.push(metric_labels, "Rtd 60%")
            m = array.size(metric_labels)

            prev_col_hdr = (na(prev_leg_num) ? "Prev" : f_legChar(prev_leg_num, char_style)) + "\nUnconfirmed"
            active_col_hdr = (na(active_leg_num) ? "Active" : f_legChar(active_leg_num, char_style)) + "\nProjected"

            // Build a flattened [column][metric] matrix so the column count can vary with num_legs_shown.
            // Column order (left to right): oldest historical leg ... newest historical leg, Prev, Active.
            total_data_cols = hist_n + 2
            col_hdrs   = array.new_string(total_data_cols)
            col_vals   = array.new_string(total_data_cols * m)
            col_txtcol = array.new_color(total_data_cols * m)
            col_bgcol  = array.new_color(total_data_cols * m)

            for c = 0 to hist_n - 1
                k = hist_n - 1 - c
                array.set(col_hdrs, c, array.get(hist_prefix, k))
                array.set(col_vals, c * m + 0, array.get(hist_tendency_txt, k))
                array.set(col_vals, c * m + 1, array.get(hist_hilo_txt, k))
                array.set(col_vals, c * m + 2, array.get(hist_growth_txt, k))
                array.set(col_vals, c * m + 3, array.get(hist_bars_txt, k))
                array.set(col_vals, c * m + 4, array.get(hist_retrace_txt, k))
                if show_retrace_bar
                    array.set(col_vals, c * m + 5, array.get(hist_retrace_bar_txt, k))
                if show_retrace_targets
                    array.set(col_vals, c * m + (m - 3), array.get(hist_retrace_40, k))
                    array.set(col_vals, c * m + (m - 2), array.get(hist_retrace_50, k))
                    array.set(col_vals, c * m + (m - 1), array.get(hist_retrace_60, k))
                for i = 0 to m - 1
                    // The last 3 metric rows (Retracement % 40/50/60 targets) get the inverted
                    // direction color relative to the leg's own tendency color; all other metrics
                    // (Dir, High/Low, Growth, Bars, Retraced) keep the normal color.
                    base_col = array.get(hist_tendency_col, k)
                    row_col = show_retrace_targets and i >= m - 3 ? f_invertTendencyCol(base_col) : base_col
                    array.set(col_txtcol, c * m + i, stats_dir_text_mode == "Tendency Color" ? row_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt)
                    array.set(col_bgcol, c * m + i, stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_col) : stats_cell_bg)

            prev_c = hist_n
            array.set(col_hdrs, prev_c, prev_col_hdr)
            array.set(col_vals, prev_c * m + 0, tendency_txt)
            array.set(col_vals, prev_c * m + 1, leg_hilo_txt)
            array.set(col_vals, prev_c * m + 2, f_fmtPrice(leg_size))
            array.set(col_vals, prev_c * m + 3, prev_bars_plain)
            array.set(col_vals, prev_c * m + 4, unconf_retrace_combo_txt)
            if show_retrace_bar
                array.set(col_vals, prev_c * m + 5, unconf_retrace_bar_txt)
            if show_retrace_targets
                array.set(col_vals, prev_c * m + (m - 3), prev_retrace_40)
                array.set(col_vals, prev_c * m + (m - 2), prev_retrace_50)
                array.set(col_vals, prev_c * m + (m - 1), prev_retrace_60)
            for i = 0 to m - 1
                // Same inversion rule as above, applied to the Previous-leg column.
                row_col = show_retrace_targets and i >= m - 3 ? f_invertTendencyCol(tendency_col) : tendency_col
                array.set(col_txtcol, prev_c * m + i, stats_dir_text_mode == "Tendency Color" ? row_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt)
                array.set(col_bgcol, prev_c * m + i, stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_col) : stats_cell_bg)

            active_c = hist_n + 1
            array.set(col_hdrs, active_c, active_col_hdr)
            array.set(col_vals, active_c * m + 0, active_tendency_txt)
            array.set(col_vals, active_c * m + 1, active_hilo_txt)
            array.set(col_vals, active_c * m + 2, active_growth_txt)
            array.set(col_vals, active_c * m + 3, active_bars_plain)
            array.set(col_vals, active_c * m + 4, retrace_combo_txt)
            if show_retrace_bar
                array.set(col_vals, active_c * m + 5, retrace_bar_txt)
            if show_retrace_targets
                // Active (Projected) column: forward-looking Rtd % targets are intentionally
                // left blank here, since the leg hasn't confirmed yet — the computed
                // active_retrace_40/50/60 values are still used by the Original layout's
                // Active row below, just not shown as this column's own cells.
                array.set(col_vals, active_c * m + (m - 3), "—")
                array.set(col_vals, active_c * m + (m - 2), "—")
                array.set(col_vals, active_c * m + (m - 1), "—")
            for i = 0 to m - 1
                // Same inversion rule as above, applied to the Active-leg column.
                row_col = show_retrace_targets and i >= m - 3 ? f_invertTendencyCol(active_tendency_col) : active_tendency_col
                array.set(col_txtcol, active_c * m + i, stats_dir_text_mode == "Tendency Color" ? row_col : stats_dir_text_mode == "Tendency Background" ? stats_tendbg_txt_color : stats_cell_txt)
                array.set(col_bgcol, active_c * m + i, stats_dir_text_mode == "Tendency Background" ? f_tendBgColor(row_col) : stats_cell_bg)

            if stats_orientation == "Vertical"
                total_cols = total_data_cols + 3
                statsTable := table.new(f_tablePos(stats_position), total_cols, m + 4, border_width = 1, border_color = stats_border_color)
                table.cell(statsTable, 1, 1, title_txt, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                table.merge_cells(statsTable, 1, 1, total_data_cols + 1, 1)
                table.cell(statsTable, 1, 2, "Metric", text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                for c = 0 to total_data_cols - 1
                    table.cell(statsTable, c + 2, 2, array.get(col_hdrs, c), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                for i = 0 to m - 1
                    table.cell(statsTable, 1, i + 3, array.get(metric_labels, i), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                    for c = 0 to total_data_cols - 1
                        table.cell(statsTable, c + 2, i + 3, array.get(col_vals, c * m + i), text_color = array.get(col_txtcol, c * m + i), bgcolor = array.get(col_bgcol, c * m + i), text_size = stats_size)
                f_addTablePadding(statsTable, total_cols, m + 4, pad_top, pad_bottom, pad_left, pad_right)
            else
                total_rows = total_data_cols + 4
                statsTable := table.new(f_tablePos(stats_position), m + 3, total_rows, border_width = 1, border_color = stats_border_color)
                table.cell(statsTable, 1, 1, title_txt, text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                table.merge_cells(statsTable, 1, 1, m + 1, 1)
                table.cell(statsTable, 1, 2, "Phase", text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                for i = 0 to m - 1
                    table.cell(statsTable, i + 2, 2, array.get(metric_labels, i), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                for c = 0 to total_data_cols - 1
                    table.cell(statsTable, 1, c + 3, array.get(col_hdrs, c), text_color = stats_header_txt, bgcolor = stats_header_bg, text_size = stats_size)
                    for i = 0 to m - 1
                        table.cell(statsTable, i + 2, c + 3, array.get(col_vals, c * m + i), text_color = array.get(col_txtcol, c * m + i), bgcolor = array.get(col_bgcol, c * m + i), text_size = stats_size)
                f_addTablePadding(statsTable, m + 3, total_rows, pad_top, pad_bottom, pad_left, pad_right)

plot(na)

// EOF
````
