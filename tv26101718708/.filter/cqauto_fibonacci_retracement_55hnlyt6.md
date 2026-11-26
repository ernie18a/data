# CQ_Auto Fibonacci Retracement

- url: https://www.tradingview.com/script/55hNLYt6-CQ-Auto-Fibonacci-Retracement/
- type: indicator
- pine_id: PUB;16031f8eae264df1aae769861148204f
- version: 1.0

## Description

================================================================================
  CQ AUTO FIBONACCI RETRACEMENT — USER MANUAL
  Fib.Retracement core is from tradingview built-in FBR -> upgrade new-type GUI, 
  and performance tuned / CQuevedo345
================================================================================


OVERVIEW
--------
CQ Auto Fibonacci Retracement is an automatic Fibonacci retracement
indicator built for TradingView in Pine Script v6. It detects swing pivots
(highs and lows) in real time and draws a full Fibonacci scale between them,
including a live gauge that shows where the current price sits within the
retracement range.

The indicator is fully color-coded by market bias: teal for bullish swings
(last confirmed pivot is a low) and orange for bearish swings (last confirmed
pivot is a high). All elements — the trend line, fib level lines, scale labels,
and the gauge — switch color together the moment a new pivot is confirmed.


--------------------------------------------------------------------------------
SECTION 1 — MASTER CONTROL
--------------------------------------------------------------------------------

  Enable Indicator (toggle)
      Master on/off switch. When disabled, all drawing is suppressed but the
      indicator remains on the chart. Use this to quickly hide the overlay
      without removing it.

  How Far  (integer, default 10, range 1–100)
      Lookback depth for pivot detection. Controls how many bars to the left
      and right of a candidate bar must be lower (for a high pivot) or higher
      (for a low pivot) before that bar qualifies as a pivot. Lower values
      produce more frequent, shorter swings. Higher values produce fewer,
      larger swings.

  Wave Size  (float, default 10, step 0.5, min 1)
      Sensitivity multiplier applied to the ATR-based deviation threshold. A
      new pivot is only confirmed when price has moved at least this multiple
      of the normalized ATR from the previous pivot. Higher values require a
      larger price move to flip the swing direction, filtering out noise.
      Lower values make the indicator more reactive.

  Fibonacci Level Toggles  (25% / 40% / 50% / 60% / 75% / 90%)
      Six individual checkboxes to show or hide specific intermediate fib
      levels. The 0% and 100% anchor levels and all extension levels are
      always visible and cannot be individually toggled.


--------------------------------------------------------------------------------
SECTION 2 — COLOR SETTINGS
--------------------------------------------------------------------------------

  THEME COLORS

  Bullish (▲)  (color picker, default teal #26A69A)
      Color applied to all elements when the last confirmed pivot is a LOW,
      meaning price swung upward from it. Affects: trend line, pivot circles,
      all fib level lines, scale labels, gauge box, gauge highlight bar, and
      the extreme price label.

  Bearish (▼)  (color picker, default orange #FF8A3D)
      Color applied to all elements when the last confirmed pivot is a HIGH,
      meaning price swung downward from it. Same scope as the bullish color.

  The indicator flips both colors simultaneously the moment a new pivot is
  confirmed. Historical drawings retain the color they had when drawn.


  TREND LINE

  Show Trend Line  (toggle, default on)
      Shows or hides the dotted line connecting consecutive pivot points.

  Width  (integer, default 3)
      Stroke width of the dotted trend line in pixels.

  Show Pivot Points  (toggle, default on)
      Shows or hides the hollow circle markers (◯) drawn at each pivot
      endpoint.


  GAUGE

  Gauge Highlight ▲  (color picker, default teal at 40% opacity)
      Color of the moving highlight bar inside the gauge when bullish. This
      bar tracks the current close price within the gauge range.

  Gauge Highlight ▼  (color picker, default orange at 40% opacity)
      Same as above for bearish swings.

  Draw Gauge ⌈∥⌉  (toggle, default on)
      Shows or hides the vertical gauge element entirely. When off, the gauge
      box, highlight bar, range cap lines, and extreme price label are all
      suppressed.


  LAYOUT

  Gauge X-Offset  (integer, default -2)
      Shifts the gauge and all associated labels left or right along the
      x-axis, measured in bars. Negative values move it left; positive values
      move it right. Adjust this to prevent overlap with candles or other
      indicators.

  Level Tick Length (Right)  (integer, default 1, range 1–9)
      Length in bars of the small horizontal tick marks drawn to the right of
      the gauge for each fib level. Increase to make the scale easier to read.

  Show Price on Labels  (toggle, default on)
      When on, each fib scale label shows two lines: the percentage level on
      top and the absolute price below. When off, only the percentage is shown.

  Label Size  (dropdown, default Small)
      Font size for all scale labels, extension labels, and the extreme price
      label. Options: Tiny / Small / Normal / Large / Huge.

  Gauge at Line End (vs Current Bar)  (toggle, default off)
      Controls where the gauge and its labels are anchored on the x-axis.

      OFF (default): The gauge follows the current bar, always at the right
      edge of the chart. Labels and tick marks update every bar.

      ON: The gauge is pinned to the x2 endpoint of the dotted trend line —
      the most recent confirmed pivot bar. The gauge stays fixed at that
      historical position until a new pivot is confirmed. Useful for a less
      cluttered look when price has moved far from the pivot.


--------------------------------------------------------------------------------
SECTION 3 — VISUAL ELEMENTS EXPLAINED
--------------------------------------------------------------------------------

  TREND LINE  (dotted)
      Connects the last two confirmed pivot points. Direction indicates the
      current swing: rising line = last pivot was a low (bullish); falling
      line = last pivot was a high (bearish).

  PIVOT CIRCLES  (◯)
      Hollow circles drawn at each pivot point on the trend line. The start
      circle marks the older pivot; the end circle marks the more recent one.

  FIBONACCI LEVEL LINES
      Horizontal lines drawn at each active fib level across the chart.
      The 0% line sits at the most recent pivot price (the base). The 100%
      line sits at the previous pivot price (the target). Intermediate levels
      are drawn between them. Extension levels (above 100% or below 0%) appear
      automatically when price breaks outside the retracement range.

      Line visibility:
        - 0% and 100% lines are always solid and fully opaque.
        - Intermediate lines are dotted and fully opaque when price is near
          that level; they fade to 70% transparency when price is far away.
        - Extension lines only appear when price has moved beyond the
          corresponding boundary.

  SCALE LABELS  (right side of gauge)
      Each fib level has a small label showing the level percentage and,
      optionally, the absolute price. Labels are color-matched to the current
      theme. The label for each level is positioned at the gauge x-offset
      and updates every bar.

  EXTENSION LABELS  (auto mode)
      When price moves beyond the 0%–100% range, extension levels are drawn
      automatically at -0.25, -0.50, -1.00, -1.50, -2.00 (below 0%) and
      1.25, 1.50, 2.00 (above 100%). These carry their own labels and short
      tick marks at the gauge position.


--------------------------------------------------------------------------------
SECTION 4 — THE GAUGE
--------------------------------------------------------------------------------

The gauge is a vertical bar drawn at the gauge position (either the current
bar or the trend line endpoint, depending on the Gauge at Line End setting).
It is the most information-dense element of the indicator.

  GAUGE BACKGROUND BOX  (faint filled rectangle)
      Spans from the lowest low to the highest high reached since the last
      pivot. This is the full price range of the current swing, not just the
      0%–100% fib span. It visually shows how far price has traveled relative
      to the fib boundaries.

  TOP CAP LINE  (thin white horizontal line)
      Marks the highest high reached since the pivot. Drawn at the top of the
      gauge background box.

  BOTTOM CAP LINE  (theme-colored horizontal line)
      Marks the lowest low reached since the pivot. Drawn at the bottom of
      the gauge background box.

  GAUGE BODY  (semi-transparent filled box, theme color)
      A narrower vertical bar spanning from the current close price to the
      pivot price (fb_pLast). This shows the current unrealized move from the
      pivot in absolute price terms.

  HIGHLIGHT BAR  (wide line, gauge highlight color)
      A thick horizontal line at the current close price that moves every bar.
      This is the "needle" of the gauge — it shows at a glance where price
      sits within the full range.

  EXTREME PRICE LABEL  (left side of gauge)
      Displayed to the left of the gauge. Shows:
        - A directional arrow (▲ for bullish, ▼ for bearish)
        - The extreme price reached since the pivot (highest high if bullish,
          lowest low if bearish)
        - The percentage change from the pivot price to that extreme

      Example (bullish): ▲ 109,432.50
                          +8.43%

      Example (bearish): ▼ 94,210.00
                          -6.71%

      The label updates every bar as price extends the move. The percentage
      is always calculated from fb_pLast (the most recent confirmed pivot
      price), not from the entry price or any other reference.

  PROFIT LABEL  (at 0% level, gauge position)
      A small label at the 0% fib level showing the raw price difference
      between the current close and the pivot price. Displayed as a signed
      dollar amount (e.g., +$4,230 or -$2,180).


--------------------------------------------------------------------------------
SECTION 5 — PIVOT LOGIC
--------------------------------------------------------------------------------

A pivot is confirmed when:

  1. A bar exists such that all bars within the lookback depth (How Far) to
     its left and right are lower (for a high pivot) or higher (for a low
     pivot).

  2. The price deviation from the previous pivot exceeds the Wave Size
     threshold: (ATR_20 / close * 100 * Wave Size).

When both conditions are met:
  - The trend line moves from the previous pivot to the new one.
  - The Fibonacci levels recalculate based on the new pivot pair.
  - The theme color switches (teal if the new pivot is a low, orange if high).
  - The gauge resets its range tracking.

If a new pivot is in the same direction as the current one (e.g., a higher
high when the last pivot was already a high), the trend line simply extends
to the new extreme rather than creating a new swing.


--------------------------------------------------------------------------------
SECTION 6 — FIBONACCI LEVELS REFERENCE
--------------------------------------------------------------------------------

  Level     Description
  -------   ---------------------------------------------------------------
  -2.000    Extension: 200% below 0% (deep extension)
  -1.500    Extension: 150% below 0%
  -1.000    Extension: 100% below 0% (mirror of full range)
  -0.500    Extension: 50% below 0%
  -0.250    Extension: 25% below 0%
   0.000    Base — most recent pivot price (always shown)
   0.250    25% retracement (optional)
   0.400    40% retracement (optional)
   0.500    50% retracement (optional)
   0.600    60% retracement (optional, uses key line color)
   0.750    75% retracement (optional)
   0.900    90% retracement (optional)
   1.000    Target — previous pivot price (always shown)
   1.250    Extension: 125% above 100%
   1.500    Extension: 150% above 100%
   2.000    Extension: 200% above 100%

Negative levels appear when price drops below the 0% base.
Levels above 1.000 appear when price exceeds the 100% target.
Extensions are shown automatically based on where price is relative to the
retracement range; they do not need to be toggled on.


--------------------------------------------------------------------------------
SECTION 7 — TIPS & RECOMMENDED SETTINGS
--------------------------------------------------------------------------------

For higher timeframe swing trading (4H, Daily):
  - How Far: 20–30
  - Wave Size: 15–20
  - This captures major structural swings and ignores intraday noise.

For intraday scalping (5m, 15m):
  - How Far: 5–10
  - Wave Size: 5–8
  - This picks up shorter swings with faster pivot confirmation.

Reducing clutter:
  - Enable "Gauge at Line End" to pin the gauge to the pivot bar instead
    of the live candle. This keeps the right side of the chart cleaner.
  - Disable "Show Price on Labels" if the chart is zoomed out and labels
    overlap. Percentage-only labels are narrower.
  - Set Label Size to Tiny on zoomed-out views.
  - Reduce Level Tick Length to 1 if the tick marks extend too far right.

Overlapping indicators:
  - Use Gauge X-Offset (negative values) to push the gauge further left,
    away from other indicators drawn at the chart edge.


--------------------------------------------------------------------------------
SECTION 8 — KNOWN BEHAVIORS
--------------------------------------------------------------------------------

  Pivot repainting
      Pivot confirmation requires a full lookback depth of bars to the right
      of the candidate bar, so the most recent pivot is always fb_depth/2
      bars in the past. The indicator does not repaint confirmed pivots; only
      the live trend line endpoint moves as price discovers new extremes in
      the same direction.

  Color on historical bars
      Historical segments retain the color they carried at the time they were
      drawn. Only the current active segment updates its color live.

  Extension level auto-visibility
      Extension lines and labels appear and disappear dynamically based on
      whether price has crossed the corresponding boundary. This is
      intentional — the chart only shows the levels that are currently
      relevant to where price is trading.

  Gauge range vs fib range
      The gauge background box shows the full high-to-low range since the
      pivot, which will often be wider than the 0%–100% fib span. This is
      correct: the gauge tracks actual price excursion, while the fib levels
      track the retracement within the defined swing.

  First bar initialization
      On the very first bars of a chart or after a long gap, fb_pLast
      initializes to 0 and fb_lineLast to na. The indicator will not draw
      until at least one valid pivot pair has been confirmed.


================================================================================
  END OF MANUAL
  CQ Auto Fibonacci Retracement / CQuevedo345
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CQuevedo345
//@version=6
indicator("CQ_Auto Fibonacci Retracement", overlay = true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, explicit_plot_zorder = true, max_bars_back = 4000)
plot(close)

var COLOR_TRANSP = color.rgb(255, 255, 255, 100)
var basicgr      = '⚙️ Master Control'
var fb_tooltip   = '\nHow Far: The minimum number of bars that will be taken into account when calculating the indicator (Default 20).\n\nWave Size: a multiplier that affects how much the price should deviate from the previous pivot in order for the bar to become a new pivot.\n'

show_indicator = input.bool(true, '⚡ Enable Indicator', group = '🪙 F i b o n a c c i  R e t r a c e m e n t')

fb_depth     = input.int  (10,  minval = 1, maxval = 100, title = 'How Far   ', inline = 'FBR1', group = basicgr, tooltip = fb_tooltip)
fb_dev_ratio = input.float(10,  minval = 1, step = 0.5,   title = 'Wave Size ', inline = 'FBR1', group = basicgr)

fb_dev_threshold = ta.atr(20) / close * 100 * fb_dev_ratio

fb250 = input(true, '25% ', inline = 'fbl', group = basicgr)
fb400 = input(true, '40% ', inline = 'fbl', group = basicgr)
fb500 = input(true, '50% ', inline = 'fbl', group = basicgr)
fb600 = input(true, '60% ', inline = 'fbl', group = basicgr)
fb750 = input(true, '75% ', inline = 'fbl', group = basicgr)
fb900 = input(true, '90%',  inline = 'fbl', group = basicgr)

// ─── COLOR SETTINGS ───────────────────────────────────────────────────────────
view_gr = 'Color Settings'

col_bull = input.color(color.rgb( 38, 166, 154), '▲ Bullish (last pivot = low)',  inline = 'theme', group = view_gr)
col_bear = input.color(color.rgb(255, 138,  61), '▼ Bearish (last pivot = high)', inline = 'theme', group = view_gr)

draw_tline       = input.bool(true, 'Show Trend Line',   inline = 'tline', group = view_gr)
draw_tline_width = input.int (3,    'Width',              inline = 'tline', group = view_gr)
draw_pmark       = input.bool(true, 'Show Pivot Points',  inline = 'tline', group = view_gr)

fb_guide_highlight_bull = input.color(color.rgb( 38, 166, 154, 40), '▌Gauge Highlight ▲', inline = 'gauge', group = view_gr)
fb_guide_highlight_bear = input.color(color.rgb(255, 138,  61, 40), '▌Gauge Highlight ▼', inline = 'gauge', group = view_gr)
fb_guide_draw           = input.bool (true, 'Draw Gauge ⌈∥⌉',                              inline = 'gauge', group = view_gr)

// ─── LAYOUT ───────────────────────────────────────────────────────────────────
fb_gauge_position = input.int (defval = -2, title = 'Gauge X-Offset',            inline = 'pos', group = view_gr)
fb_line_lenght    = input.int (defval =  1, minval = 1, maxval = 9,
                                title = 'Level Tick Length (Right)',              inline = 'pos', group = view_gr)
draw_simplelabel  = input.bool(true, 'Show Price on Labels',                      inline = 'lbl', group = view_gr)

_lbl_size_raw = input.string('Small', 'Label Size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'],
     inline  = 'lbl', group = view_gr)

fb_lbl_size = switch _lbl_size_raw
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    'Large'  => size.large
    'Huge'   => size.huge
    => size.small

gauge_at_line_end = input.bool(false, 'Gauge at Line End  (vs Current Bar)', group = view_gr)
// ─────────────────────────────────────────────────────────────────────────────

[k_volume, k_open, k_close, k_high, k_low, k_hlc3, k_hlcc4, k_ohlc4, k_hl2, k_close_mintick, k_trtrue, k_atr14, k_atr14_mintick, k_rsipvt14] = request.security(syminfo.tickerid, '', [volume, open, close, high, low, hlc3, hlcc4, ohlc4, hl2, str.tostring(close, format.mintick), ta.tr(true), ta.atr(14), str.tostring(ta.atr(14), format.mintick), ta.rsi(ta.pvt, 14)])

// ─── PIVOT DETECTION ──────────────────────────────────────────────────────────
var line  fb_lineLast         = na
var label fb_label_start_last = na
var label fb_label_end_last   = na
var int   fb_iLast    = 0
var int   fb_iPrev    = 0
var float fb_pLast    = 0
var bool  fb_isHighLast = false

high_none = ta.highest(high, fb_depth) > nz(high[fb_depth / 2])
fb_iH = high_none ? int(na)   : bar_index[fb_depth / 2]
fb_pH = high_none ? float(na) : nz(high[fb_depth / 2])
low_none  = ta.lowest(low,  fb_depth) < nz(low[fb_depth / 2])
fb_iL = low_none  ? int(na)   : bar_index[fb_depth / 2]
fb_pL = low_none  ? float(na) : nz(low[fb_depth / 2])

calc_dev(_base_price, _price) =>
    100 * (_price - _base_price) / _price

pivotFound(dev, isHigh, index, price) =>
    if fb_isHighLast == isHigh and not na(fb_lineLast)
        if fb_isHighLast ? price > fb_pLast : price < fb_pLast
            line.set_xy2(fb_lineLast, index, price)
            label.set_xy(fb_label_end_last, index, price)
            [fb_lineLast, fb_isHighLast, fb_label_start_last, fb_label_end_last]
        else
            [line(na), bool(na), label(na), label(na)]
    else
        if math.abs(dev) > fb_dev_threshold
            _tline_transp = show_indicator and draw_tline ? 0 : 50
            _pmark_transp = show_indicator and draw_pmark ? 0 : 100
            _theme_c = isHigh ? col_bear : col_bull
            id_fb_line = line.new(fb_iLast, fb_pLast, index, price,
                 color = color.new(_theme_c, _tline_transp),
                 width = draw_tline_width, style = line.style_dotted)
            id_fb_label_start = label.new(fb_iLast, fb_pLast,
                 color     = COLOR_TRANSP,
                 size      = size.large,
                 style     = label.style_label_center,
                 textcolor = color.new(_theme_c, _pmark_transp),
                 text      = '◯')
            id_fb_label_end = label.new(index, price,
                 color     = COLOR_TRANSP,
                 size      = size.large,
                 style     = label.style_label_center,
                 textcolor = color.new(_theme_c, _pmark_transp),
                 text      = '◯')
            [id_fb_line, isHigh, id_fb_label_start, id_fb_label_end]
        else
            [line(na), bool(na), label(na), label(na)]

fb_new_line = false
if not na(fb_iH)
    fb_dev = calc_dev(fb_pLast, fb_pH)
    [fb_id, fb_isHigh, fb_la_s_id, fb_la_e_id] = pivotFound(fb_dev, true, fb_iH, fb_pH)
    if not na(fb_id)
        if fb_id != fb_lineLast
            line.delete(fb_lineLast)
            label.delete(fb_label_start_last)
            label.delete(fb_label_end_last)
            fb_new_line := true
        fb_lineLast           := fb_id
        fb_label_start_last   := fb_la_s_id
        fb_label_end_last     := fb_la_e_id
        fb_isHighLast         := fb_isHigh
        fb_iPrev              := fb_iLast
        fb_iLast              := fb_iH
        fb_pLast              := fb_pH
else if not na(fb_iL)
    fb_dev = calc_dev(fb_pLast, fb_pL)
    [fb_id, fb_isHigh, fb_la_s_id, fb_la_e_id] = pivotFound(fb_dev, false, fb_iL, fb_pL)
    if not na(fb_id)
        if fb_id != fb_lineLast
            line.delete(fb_lineLast)
            label.delete(fb_label_start_last)
            label.delete(fb_label_end_last)
            fb_new_line := true
        fb_lineLast           := fb_id
        fb_label_start_last   := fb_la_s_id
        fb_label_end_last     := fb_la_e_id
        fb_isHighLast         := fb_isHigh
        fb_iPrev              := fb_iLast
        fb_iLast              := fb_iL
        fb_pLast              := fb_pL

// ─── RETRACEMENT DRAWING ──────────────────────────────────────────────────────
fb_retracement(_show, _fib_level, _switch) =>
    if not show_indicator
        na
    else
        _col      = fb_isHighLast ? col_bear : col_bull
        _gauge_hl = fb_isHighLast ? fb_guide_highlight_bear : fb_guide_highlight_bull

        _price             = fb_pLast + (line.get_y1(fb_lineLast) - fb_pLast) * _fib_level
        _fibo_id_line_show = false
        _position          = bar_index - line.get_x2(fb_lineLast)
        _fbr_max_highest   = math.max(ta.highest(high, nz(math.max(1, _position), 1)), fb_pLast)
        _fbr_min_lowest    = math.min(ta.lowest (low,  nz(math.max(1, _position), 1)), fb_pLast)
        _fbr_line_max      = fb_pLast < _price ? _fbr_max_highest : fb_pLast > _price ? _fbr_min_lowest : fb_pLast
        _fibo_id_line_show := fb_pLast < _price and _price - k_atr14 / 4 <= _fbr_line_max ? true
                             : fb_pLast > _price and _price + k_atr14 / 4 >= _fbr_line_max ? true : false

        _gauge_x = gauge_at_line_end ? line.get_x2(fb_lineLast) : bar_index

        if _switch == 'auto' and not na(fb_lineLast)
            fibo_id_auto     = line.new(line.get_x2(fb_lineLast), _price, bar_index + 6, _price,
                                 style = line.style_solid,
                                 color = color.new(_col, _fibo_id_line_show ? 0 : 100),
                                 width = 1, extend = extend.none)
            fibo_id_ext_auto = line.new(_gauge_x + fb_gauge_position - 2, _price, _gauge_x + fb_gauge_position + 1, _price,
                                 color = color.new(_col, 0), width = 1, extend = extend.none)
            fb_label_auto    = label.new(x = _gauge_x + fb_gauge_position, y = _price,
                                 text      = str.tostring(math.round(_fib_level, 02), '000%') + (draw_simplelabel ? '\n' + str.tostring(_price, ' $00,000') : ''),
                                 textcolor = color.new(_col, 0),
                                 style     = label.style_label_left,
                                 textalign = text.align_left,
                                 color     = #00000000,
                                 size      = fb_lbl_size)
            line.delete (fibo_id_auto[1])
            line.delete (fibo_id_ext_auto[1])
            label.delete(fb_label_auto[1])
            if not _show
                line.delete (fibo_id_auto)
                line.delete (fibo_id_ext_auto)
                label.delete(fb_label_auto)

        if _show and _switch == ''
            var fibo_id     = line.new(fb_iLast, _price, bar_index, _price, color = color.new(_col, 0), width = 2, extend = extend.none, style = line.style_solid)
            var fibo_id_ext = line.new(fb_iLast, _price, bar_index, _price, color = color.new(_col, 0), width = 2, extend = extend.none, style = line.style_solid)
            var fb_label    = label.new(x = bar_index, y = _price, text = '',
                                 textcolor = COLOR_TRANSP,
                                 style     = label.style_label_right,
                                 textalign = text.align_right,
                                 color     = color.rgb(0, 0, 0, 100),
                                 size      = fb_lbl_size)
            var fb_label2   = label.new(x = bar_index, y = _price, text = '',
                                 textcolor = COLOR_TRANSP,
                                 style     = label.style_label_left,
                                 textalign = text.align_left,
                                 color     = color.rgb(0, 0, 0, 100),
                                 size      = fb_lbl_size)

            if not na(fb_lineLast)
                line.set_xy1   (fibo_id, _fib_level == 1.0 ? line.get_x1(fb_lineLast) : line.get_x2(fb_lineLast), _price)
                line.set_xy2   (fibo_id, _fib_level == 1.0 or _fib_level == 0.0 ? _gauge_x + fb_gauge_position - 2 : bar_index, _price)
                line.set_color (fibo_id, color.new(_col, _fib_level == 0.0 ? 0 : _fib_level == 1.0 ? 0 : _fibo_id_line_show ? 0 : 70))
                line.set_style (fibo_id, _fib_level == 0.0 or _fib_level == 1.0 ? line.style_solid : line.style_dotted)
                line.set_width (fibo_id, _fib_level == 0.0 or _fib_level == 1.0 ? 2 : 1)

                line.set_xy1  (fibo_id_ext, _gauge_x + fb_gauge_position - 1, _price)
                line.set_xy2  (fibo_id_ext, _gauge_x + fb_gauge_position + fb_line_lenght, _price)
                line.set_color(fibo_id_ext, color.new(_col, 0))
                line.set_width(fibo_id_ext, _fib_level == 0.0 or _fib_level == 1.0 or _fib_level == 0.60 ? 2 : 1)

                label.set_xy       (fb_label, _gauge_x + fb_gauge_position, _price)
                label.set_text     (fb_label, str.tostring(math.round(_fib_level, 02), '00%') + (draw_simplelabel ? '\n' + str.tostring(_price, '$0,000') : ''))
                label.set_tooltip  (fb_label, str.tostring(((_price - fb_pLast) / fb_pLast) * 100, format.percent) + ' ' + str.tostring(math.round(_price - fb_pLast, 0), '$00,000') + ' from 00% ' + str.tostring(math.round(fb_pLast, 0), '$00,000'))
                label.set_textcolor(fb_label, color.new(_col, 0))
                label.set_size     (fb_label, fb_lbl_size)

                label.set_xy       (fb_label2, bar_index + 66, _price)
                label.set_text     (fb_label2, '🔚\n🚧')
                label.set_textcolor(fb_label2, color.new(_col, 0))
                label.set_size     (fb_label2, fb_lbl_size)

                if _fib_level == 1.0 and fb_guide_draw
                    _extreme_price = fb_isHighLast ? _fbr_min_lowest : _fbr_max_highest
                    _extreme_chg   = (_extreme_price - fb_pLast) / fb_pLast * 100
                    _extreme_sign  = _extreme_chg >= 0 ? '▲ ' : '▼ '
                    _extreme_txt   = _extreme_sign
                                   + str.tostring(_extreme_price, '$0,000')
                                   + '\n' + str.tostring(math.round(_extreme_chg, 2), '0.0') + '%'

                    var fibo_box_max  = box.new (bar_index, close, bar_index, fb_pLast,
                                          border_color = color.new(_col, 50), border_width = 1,
                                          border_style = line.style_dotted,
                                          bgcolor      = color.new(_col, 80),
                                          text = 'FIB/RET', text_valign = text.align_top,
                                          text_size = size.tiny, text_color = _col)
                    var fibo_line_max = line.new(bar_index, close, bar_index, fb_pLast, color = color.white, width = 1)
                    var fibo_line_min = line.new(bar_index, close, bar_index, fb_pLast, color = _col, width = 1)
                    var fibo_box_ext  = box.new (bar_index, close, bar_index, fb_pLast,
                                          border_color = color.new(_col, 70),
                                          border_width = 7,
                                          bgcolor      = color.new(_col, 70))
                    var fibo_line_ext = line.new(bar_index, close, bar_index, fb_pLast, color = _gauge_hl, width = 4)

                    // extreme label — left hand side of the gauge
                    var fibo_extreme_label = label.new(
                                          x         = _gauge_x + fb_gauge_position - 2,
                                          y         = _extreme_price,
                                          text      = _extreme_txt,
                                          textcolor = color.new(_col, 0),
                                          style     = label.style_label_right,
                                          textalign = text.align_right,
                                          color     = color.new(_col, 90),
                                          size      = fb_lbl_size)

                    box.set_lefttop     (fibo_box_max,  _gauge_x + fb_gauge_position - 1, _fbr_max_highest)
                    box.set_rightbottom (fibo_box_max,  _gauge_x + fb_gauge_position + 1, _fbr_min_lowest)
                    box.set_border_color(fibo_box_max,  color.new(_col, 50))
                    box.set_bgcolor     (fibo_box_max,  color.new(_col, 80))
                    box.set_text_color  (fibo_box_max,  _col)
                    line.set_xy1        (fibo_line_max, _gauge_x + fb_gauge_position - 1, _fbr_max_highest)
                    line.set_xy2        (fibo_line_max, _gauge_x + fb_gauge_position + 1, _fbr_max_highest)
                    line.set_xy1        (fibo_line_min, _gauge_x + fb_gauge_position - 1, _fbr_min_lowest)
                    line.set_xy2        (fibo_line_min, _gauge_x + fb_gauge_position + 1, _fbr_min_lowest)
                    line.set_color      (fibo_line_min, _col)
                    box.set_lefttop     (fibo_box_ext,  _gauge_x + fb_gauge_position,     close)
                    box.set_rightbottom (fibo_box_ext,  _gauge_x + fb_gauge_position,     fb_pLast)
                    box.set_border_color(fibo_box_ext,  color.new(_col, 70))
                    box.set_bgcolor     (fibo_box_ext,  color.new(_col, 70))
                    line.set_xy1        (fibo_line_ext, _gauge_x + fb_gauge_position,     close)
                    line.set_xy2        (fibo_line_ext, _gauge_x + fb_gauge_position,     close)
                    line.set_color      (fibo_line_ext, _gauge_hl)

                    // update every bar
                    label.set_xy       (fibo_extreme_label, _gauge_x + fb_gauge_position - 2, _extreme_price)
                    label.set_text     (fibo_extreme_label, _extreme_txt)
                    label.set_textcolor(fibo_extreme_label, color.new(_col, 0))
                    label.set_color    (fibo_extreme_label, color.new(_col, 90))
                    label.set_size     (fibo_extreme_label, fb_lbl_size)
                    label.set_style    (fibo_extreme_label, label.style_label_right)
                    label.set_textalign(fibo_extreme_label, text.align_right)

                if _fib_level == 0.0 and fb_guide_draw
                    var fibo_prof_label = label.new(bar_index, close,
                                              str.tostring(math.round(close - fb_pLast, 0), '$0,000'),
                                              size = fb_lbl_size)
                    label.set_xy       (fibo_prof_label, _gauge_x + fb_gauge_position, close)
                    label.set_text     (fibo_prof_label, str.tostring(math.round(close - fb_pLast, 0), '$0,000'))
                    label.set_tooltip  (fibo_prof_label, str.tostring(((close - fb_pLast) / fb_pLast) * 100, format.percent) + ' ' + str.tostring(math.round(close - fb_pLast, 0), '$0,000') + ' from 00% ' + str.tostring(math.round(fb_pLast, 0), '$00,000'))
                    label.set_color    (fibo_prof_label, color.new(_col, 100))
                    label.set_textcolor(fibo_prof_label, color.white)
                    label.set_size     (fibo_prof_label, fb_lbl_size)
                    label.set_style    (fibo_prof_label, label.style_label_right)
                    label.set_textalign(fibo_prof_label, text.align_right)

// ─── RANGE FLAGS ──────────────────────────────────────────────────────────────
fb_new = fb_pLast[1] != fb_pLast or fb_new_line or fb_iLast[1] != fb_iLast

fb_height    = line.get_y1(fb_lineLast) - fb_pLast
fb_k_low_cr  = ta.lowest (k_low,  2)
fb_k_high_cr = ta.highest(k_high, 2)

fb_over_1500  = fb_height < 0 and fb_k_low_cr  < fb_height * 1.500 + fb_pLast or fb_height > 0 and fb_k_high_cr > fb_height * 1.500 + fb_pLast
fb_over_1     = fb_height < 0 and fb_k_low_cr  < line.get_y1(fb_lineLast)      or fb_height > 0 and fb_k_high_cr > line.get_y1(fb_lineLast)
fb_over_1000  = fb_height < 0 and fb_k_low_cr  < fb_height * 0.750 + fb_pLast  or fb_height > 0 and fb_k_high_cr > fb_height * 0.750 + fb_pLast
fb_under_0    = fb_height < 0 and fb_k_low_cr  > fb_pLast                       or fb_height > 0 and fb_k_high_cr < fb_pLast
fb_under_1000 = fb_height < 0 and fb_k_low_cr  > fb_height * -0.400 + fb_pLast  or fb_height > 0 and fb_k_high_cr < fb_height * -0.400 + fb_pLast
fb_under_1500 = fb_height < 0 and fb_k_low_cr  > fb_height * -0.500 + fb_pLast  or fb_height > 0 and fb_k_high_cr < fb_height * -0.500 + fb_pLast
fb_under_m1   = fb_height < 0 and fb_k_low_cr  > fb_height * -1     + fb_pLast  or fb_height > 0 and fb_k_high_cr < fb_height * -1     + fb_pLast

// ─── DRAW ─────────────────────────────────────────────────────────────────────
fb_retracement(fb_under_m1  , -2.000, 'auto')
fb_retracement(fb_under_1500, -1.500, 'auto')
fb_retracement(fb_under_1000, -1.000, 'auto')
fb_retracement(fb_under_0   , -0.500, 'auto')
fb_retracement(true         , -0.250, 'auto')
fb_retracement(true         ,  0.000, '')
fb_retracement(fb250        ,  0.250, '')
fb_retracement(fb400        ,  0.400, '')
fb_retracement(fb500        ,  0.500, '')
fb_retracement(fb600        ,  0.500, '')
fb_retracement(fb750        ,  0.750, '')
fb_retracement(fb900        ,  0.900, '')
fb_retracement(true         ,  1.000, '')
fb_retracement(fb_over_1000 ,  1.250, 'auto')
fb_retracement(fb_over_1    ,  1.500, 'auto')
fb_retracement(fb_over_1500 ,  2.000, 'auto')
````
