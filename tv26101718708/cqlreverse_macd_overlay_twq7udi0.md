# CQ_(L)_Reverse MACD Overlay

- url: https://www.tradingview.com/script/Twq7UDi0-CQ-L-Reverse-MACD-Overlay/
- type: indicator
- pine_id: PUB;3e3c5325414a4e86a78d82429fd2c4c5
- version: 2.0

## Description

================================================================================
CQ_(L)_REVERSE MACD OVERLAY
User Manual
================================================================================

OVERVIEW
--------------------------------------------------------------------------------
This indicator draws a full MACD system (MACD line, EMA signal, SMA signal,
and histograms) directly on the price chart instead of in a separate pane,
and adds "Reverse MACD" math that back-solves for the exact price level at
which the MACD line would turn, cross its signal line, or cross zero. In
other words, instead of just showing where MACD is now, it can tell you
what price needs to happen next for MACD's behavior to change.

It combines two lineages of prior work: the reverse-MACD price-solving
formulas (adapted from The_Caretaker) and a price-scaled overlay/dashboard
rendering engine (also adapted from The_Caretaker's dashboard work, with an
overlay rendering approach adapted from dgtrd).


SECTION 1 — MACD PROPERTIES
--------------------------------------------------------------------------------
  Price Source          (default: close)
  Fast Period            (default: 12)
  Slow Period            (default: 26)
  EMA Signal Length      (default: 9)  - length of the EMA-based signal line
  SMA Signal Length      (default: 9)  - length of the SMA-based signal line

Both an EMA-based and an SMA-based signal line are calculated simultaneously;
each can be shown or hidden independently (see Sections 3 & 4).


SECTION 2 — MACD LINE PLOT SETTINGS
--------------------------------------------------------------------------------
  Show MACD Line     - toggle the main MACD line on/off
  Color Type         - "Single" (one fixed color) or "Dual" (color changes
                        based on whether MACD is rising or falling bar to bar)
  Single Color       - color used when Color Type = Single
  Dual Colors        - separate Rising / Falling colors when Color Type = Dual
  Line Width         - 1-4


SECTION 3 — EMA SIGNAL LINE SETTINGS
--------------------------------------------------------------------------------
Same structure as the MACD line settings, applied to the EMA signal line:
  Show EMA Signal, Color Type (Single/Dual), Single Color, Dual Rising/Falling
  colors, Line Width. Shown by default.


SECTION 4 — SMA SIGNAL LINE SETTINGS
--------------------------------------------------------------------------------
Same structure again, applied to the SMA signal line. Hidden by default —
enable "Show SMA Signal" if you want to compare an SMA-based signal against
the EMA-based one.


SECTION 5 — EMA HISTOGRAM SETTINGS
--------------------------------------------------------------------------------
  Show EMA Histogram        - toggle histogram (MACD minus EMA signal)
  Histogram Scaling Factor  (0-10) - multiplies histogram height for visibility
  Upper Rising / Upper Falling colors  - used when histogram is >= 0
  Lower Rising / Lower Falling colors  - used when histogram is < 0
  ("Rising/Falling" is determined bar-to-bar on the histogram value itself)


SECTION 6 — SMA HISTOGRAM SETTINGS
--------------------------------------------------------------------------------
Same structure as the EMA histogram, but built from MACD minus the SMA
signal line. Hidden by default.

Note: if both EMA and SMA histograms are off, the "active histogram" used
internally falls back to raw MACD; if EMA histogram is on it takes
priority over SMA for any calculation that needs a single active series.


SECTION 7 — OVERLAY LAYOUT
--------------------------------------------------------------------------------
  Highlight MACD/Signal Area
      Fills the area between the MACD line and whichever signal line is
      active (EMA takes priority if both are on). Fill color reflects
      whether MACD is currently above (bullish, blue) or below (bearish,
      orange) that signal line.

  Display MACD/Signal Crosses
      Shows small up/down triangle labels on the price chart itself
      whenever MACD crosses over/under its active signal line.

  Display Length (bars)     (default 50, range 10-250)
      How many recent bars are included in the overlay panel.

  Placement                 (Top / Bottom, default Bottom)
      Anchors the overlay panel to the highest or lowest visible price
      over the Display Length window.

  Height                    (default 7, internally inverted: 12 - input)
      Controls how tall the MACD/signal/histogram panel appears. Lower
      input values here produce a taller panel; higher input values
      produce a shorter, more compressed one.

  Vertical Position Adjustment  (default 5, i.e. 0.5 internally)
      Pushes the panel's baseline further from price based on the recent
      high/low range, giving more or less separation from candles.


SECTION 8 — DASHBOARD
--------------------------------------------------------------------------------
  Display Reverse MACD Dashboard   - toggles an on-chart table
  Position / Size                  - standard table placement and text size
                                      (use Tiny on mobile, Small on web)
  Text Color                       - table text color
  BG MACD Falling / BG MACD Rising - background color used throughout the
                                      table, switching based on whether MACD
                                      is currently rising or falling

Table layout (columns: REVERSE MACD / ACTUAL / PROJECTION / LEVEL / DIF.):
  Row 1 - Tendency:    whether MACD is now rising or falling, the price
                        level ("Reverse ▲/▼") where that would flip, and the
                        dollar difference from current price.
  Row 2 - EMA Signal:  bars since the last EMA signal cross (with
                        direction arrow), the price level needed for MACD
                        to cross the EMA signal the *other* way, and the
                        dollar difference. Shows "OFF" if EMA signal is
                        disabled.
  Row 3 - SMA Signal:  same as Row 2, but for the SMA signal line. Shows
                        "OFF" if SMA signal is disabled.
  Row 4 - Zero Cross:  bars since MACD last crossed zero, the price level
                        needed for the next zero cross, and the dollar
                        difference.
  Row 5 - MACD Now:    current MACD, EMA signal, and EMA histogram values
                        (raw numbers, 4 decimal places).

  Inline Label on Overlay (separate from the table)
      Show Inline Label on Overlay  - places a compact text label directly
                                       next to the price-scaled MACD line
                                       on the overlay panel, showing:
                                       tendency (rising/falling), reverse
                                       level + $ difference, EMA/SMA cross
                                       levels + bars-ago, and the zero-cross
                                       level + bars-ago.
      Label Bar Offset  (1-10)        - how many bars to the right of the
                                        last drawn bar the label sits.
      Label Text Size                 - tiny/small/normal/large.


SECTION 9 — REVERSE MACD MATH (what the numbers mean)
--------------------------------------------------------------------------------
These are closed-form solutions (not simulations) for the exact price that
would need to print on the current bar to produce a specific MACD outcome:

  Reverse Level (macd_eq)
      The price at which the MACD line's slope would flip — i.e. the point
      where MACD stops rising and starts falling, or vice versa.

  Zero Cross Level (macd_level at 0)
      The price at which MACD would cross the zero line.

  EMA Cross Level (macd_cross_ema)
      The price at which MACD would cross its EMA signal line.

  SMA Cross Level (macd_cross_sma)
      The price at which MACD would cross its SMA signal line.

Each of these is recalculated every bar using the prior bar's EMA/SMA
values algebraically solved for the current bar's price, so they update in
real time as price moves intrabar.


SECTION 10 — SIGNALS & ALERTS
--------------------------------------------------------------------------------
  Long Cross / Short Cross shapes
      Small up/down labels plotted below/above bars when MACD crosses over
      or under whichever signal line is active (EMA preferred, otherwise
      SMA). Controlled by "Display MACD/Signal Crosses."

  Four built-in alerts (set these up in TradingView's Alert dialog):
      Long : Early Warning        - fires the moment MACD crosses over signal
      Long : Trading Opportunity  - fires one bar after, once the cross
                                     has held (confirmation)
      Short : Early Warning       - mirror of the long early warning
      Short : Trading Opportunity - mirror of the long confirmation

  All four alert messages include exchange, ticker, price, and time.


SECTION 11 — HOW THE OVERLAY IS DRAWN (for reference)
--------------------------------------------------------------------------------
On the last bar, all previously drawn lines, histogram boxes, and fills are
deleted and redrawn across the "Display Length" window:
  1. A baseline price is anchored to the highest (Top placement) or lowest
     (Bottom placement) price over that window, adjusted outward using the
     Vertical Position Adjustment and the recent price range.
  2. Each bar's MACD, EMA signal, and SMA signal values are scaled relative
     to the largest recent absolute MACD value ("oscHighest") and the
     Height setting, then converted into a price offset from the baseline.
  3. Line segments are drawn bar-to-bar for each enabled series (MACD, EMA
     signal, SMA signal), plus histogram boxes for each enabled histogram.
  4. If "Highlight MACD/Signal Area" is on, a colored fill is drawn between
     the MACD line and the active signal line for each bar pair.
  5. The inline label (if enabled) is placed a few bars to the right of the
     last drawn bar, at the price-scaled Y position of the current MACD
     value.


SECTION 12 — PRACTICAL NOTES & LIMITS
--------------------------------------------------------------------------------
- Declared limits: max_lines_count = 500, max_boxes_count = 250,
  max_bars_back = 500. The drawing loop stops adding new lines once 501
  are queued, as a safety guard.
- "Display Length" is capped at 250 bars; larger values increase how many
  lines/boxes get drawn per refresh (relevant if you also enable both
  histograms and the highlight fill at once).
- The Dashboard and the Inline Label are independent features — you can
  run either, both, or neither without affecting the overlay lines
  themselves.
- EMA signal takes priority over SMA signal for cross detection, active
  histogram fallback, and the "Highlight MACD/Signal Area" fill whenever
  both are enabled at the same time.
- The Reverse MACD levels (Reverse, Zero Cross, EMA Cross, SMA Cross) are
  price *projections* based on current EMA/SMA state — they describe what
  price would need to do, not a prediction that it will.

================================================================================
End of manual — CQ_(L)_Reverse MACD Overlay
================================================================================

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// © CQuevedo345
// Base reverse-MACD logic: © The_Caretaker (adapted)
// Overlay rendering engine: © dgtrd (adapted)

indicator('CQ_(L)_Reverse MACD Overlay', overlay = true,
     max_lines_count = 500, max_boxes_count = 250, max_bars_back = 500)

display = display.all - display.status_line

// ════════════════════════════════════════════════════════════════════════════════
// ── INPUTS ───────────────────────────────────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

// ── MACD Properties ──────────────────────────────────────────────────────────
grp_macd = 'MACD Properties'
i_source_price = input.source(close,  'Price Source',  inline = '1', group = grp_macd, display = display)
i_fast_length  = input.int(12,        'Fast Period',   minval = 1, maxval = 500, inline = '2', group = grp_macd, display = display)
i_slow_length  = input.int(26,        'Slow Period',   minval = 1, maxval = 500, inline = '3', group = grp_macd, display = display)
i_emaLen       = input.int(9,         'EMA Signal Length', minval = 1, group = grp_macd, display = display)
i_smaLen       = input.int(9,         'SMA Signal Length', minval = 1, group = grp_macd, display = display)

// ── MACD Line ─────────────────────────────────────────────────────────────────
grp_line = 'MACD Line Plot Settings'
i_MACDOn       = input.bool(true,   'Show MACD Line',  inline = '1', group = grp_line, display = display)
i_c_typ_line   = input.string('Dual','Color Type',     options = ['Single', 'Dual'], inline = '2', group = grp_line, display = display)
i_c_line       = input.color(color.rgb(255, 187, 0),   'Single Color',         inline = '3', group = grp_line, display = display)
i_c_line_rise  = input.color(color.rgb(0, 189, 13),    'Dual Color (Rising)',  inline = '4', group = grp_line, display = display)
i_c_line_fall  = input.color(color.rgb(185, 0, 0),     'Dual Color (Falling)', inline = '4', group = grp_line, display = display)
i_p_width_line = input.int(1, 'Line Width', minval = 1, maxval = 4, inline = '5', group = grp_line, display = display)

// ── EMA Signal ────────────────────────────────────────────────────────────────
grp_ema = 'EMA Signal Line Settings'
i_ema_on       = input.bool(true,    'Show EMA Signal',  inline = '1', group = grp_ema, display = display)
i_c_typ_ema    = input.string('Dual','Color Type',       options = ['Single', 'Dual'], inline = '2', group = grp_ema, display = display)
i_c_ema        = input.color(color.rgb(255, 255, 255),   'Single Color',         inline = '3', group = grp_ema, display = display)
i_c_ema_rise   = input.color(color.rgb(255, 187, 0),     'Dual Color (Rising)',  inline = '4', group = grp_ema, display = display)
i_c_ema_fall   = input.color(color.rgb(156, 115, 0),     'Dual Color (Falling)', inline = '4', group = grp_ema, display = display)
i_p_width_ema  = input.int(2, 'Line Width', minval = 1, maxval = 4, inline = '5', group = grp_ema, display = display)

// ── SMA Signal ────────────────────────────────────────────────────────────────
grp_sma = 'SMA Signal Line Settings'
i_sma_on       = input.bool(false,   'Show SMA Signal',  inline = '1', group = grp_sma, display = display)
i_c_typ_sma    = input.string('Dual','Color Type',       options = ['Single', 'Dual'], inline = '2', group = grp_sma, display = display)
i_c_sma        = input.color(color.rgb(255, 255, 255),   'Single Color',         inline = '3', group = grp_sma, display = display)
i_c_sma_rise   = input.color(color.rgb(0, 140, 255),     'Dual Color (Rising)',  inline = '4', group = grp_sma, display = display)
i_c_sma_fall   = input.color(color.rgb(0, 140, 255, 50), 'Dual Color (Falling)', inline = '4', group = grp_sma, display = display)
i_p_width_sma  = input.int(2, 'Line Width', minval = 1, maxval = 4, inline = '5', group = grp_sma, display = display)

// ── EMA Histogram ─────────────────────────────────────────────────────────────
grp_histe = 'EMA Histogram Settings'
i_hist_e_On    = input.bool(true, 'Show EMA Histogram',       inline = '1', group = grp_histe, display = display)
i_hist_e_Fact  = input.int(1,    'Histogram Scaling Factor', minval = 0, maxval = 10, inline = '2', group = grp_histe, display = display)
i_c_hist_e_Urise = input.color(color.rgb(38, 166, 154),    'Upper Rising',  inline = '3', group = grp_histe, display = display)
i_c_hist_e_Ufall = input.color(color.rgb(178, 223, 219),   'Upper Falling', inline = '3', group = grp_histe, display = display)
i_c_hist_e_Lfall = input.color(color.rgb(239, 83, 80),     'Lower Falling', inline = '4', group = grp_histe, display = display)
i_c_hist_e_Lrise = input.color(color.rgb(255, 205, 210),   'Lower Rising',  inline = '4', group = grp_histe, display = display)

// ── SMA Histogram ─────────────────────────────────────────────────────────────
grp_hists = 'SMA Histogram Settings'
i_hist_s_On    = input.bool(false, 'Show SMA Histogram',      inline = '1', group = grp_hists, display = display)
i_hist_s_Fact  = input.int(1,     'Histogram Scaling Factor', minval = 0, maxval = 10, inline = '2', group = grp_hists, display = display)
i_c_hist_s_Urise = input.color(color.rgb(0, 255, 0, 49),    'Upper Rising',  inline = '3', group = grp_hists, display = display)
i_c_hist_s_Ufall = input.color(color.rgb(127, 255, 127, 50),'Upper Falling', inline = '3', group = grp_hists, display = display)
i_c_hist_s_Lfall = input.color(color.rgb(255, 0, 0, 50),    'Lower Falling', inline = '4', group = grp_hists, display = display)
i_c_hist_s_Lrise = input.color(color.rgb(255, 127, 127, 50),'Lower Rising',  inline = '4', group = grp_hists, display = display)

// ── Overlay Layout ────────────────────────────────────────────────────────────
grp_lay = 'Overlay Layout'
i_highlight     = input.bool(true, 'Highlight MACD/Signal Area',
     tooltip     = 'Fills the area between the active signal line(s) and the MACD line.\nColor reflects bullish or bearish momentum.',
     group = grp_lay, display = display)
i_macdSigCross  = input.bool(true, 'Display MACD/Signal Crosses',
     tooltip     = 'Shows on-chart labels when MACD crosses any active signal line.',
     group = grp_lay, display = display)
i_lookback      = input.int(50,  'Display Length (bars)', minval = 10, maxval = 250, group = grp_lay, display = display)
i_placement     = input.string('Bottom', 'Placement', options = ['Top', 'Bottom'], inline = 'LAY', group = grp_lay, display = display)
i_height        = 12 - input.int(7, 'Height', minval = 1, maxval = 10, inline = 'LAY', group = grp_lay, display = display)
i_vertAdj       = input.int(5, 'Vertical Position Adjustment', minval = 0, maxval = 10, group = grp_lay, display = display) / 10
i_histBoxWidth    = input.float(100, 'Histogram Box Width (%)', minval = 10, maxval = 100, step = 5, group = grp_lay, display = display,
     tooltip = 'Percentage of the full bar width each histogram column occupies, centered on the bar.')
i_histBorderWidth = input.int(1, 'Histogram Border Width', minval = 1, maxval = 5, inline = 'HBORD', group = grp_lay, display = display)
i_histBorderColor = input.color(color.new(color.black, 100), 'Border Color', inline = 'HBORD', group = grp_lay, display = display)

// ── Dashboard ─────────────────────────────────────────────────────────────────
grp_dash = 'Dashboard'
i_showTable     = input.bool(false, 'Display Reverse MACD Dashboard', inline = '1', group = grp_dash)
i_tablePos      = input.string(position.middle_right, 'Position', inline = '2', group = grp_dash,
     options     = [position.bottom_left, position.top_left, position.bottom_center,
                    position.middle_right, position.top_right])
i_tableSize     = input.string(size.tiny, 'Size', inline = '2', group = grp_dash,
     options     = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge],
     tooltip     = 'Use Tiny on mobile, Small on web.')
i_c_label_txt   = input.color(color.rgb(255, 255, 255),   'Text Color',       inline = '3', group = grp_dash)
i_label_bg_fall = input.color(color.rgb(255, 0, 0, 70),   'BG MACD Falling',  inline = '4', group = grp_dash)
i_label_bg_rise = input.color(color.rgb(0, 255, 17, 70),  'BG MACD Rising',   inline = '4', group = grp_dash)

i_showInlineLabel = input.bool(true, 'Show Inline Label on Overlay',
     tooltip = 'Displays a compact info label to the right of the overlaid MACD line,\n' +
               'anchored at the current MACD price-scaled Y position.\n' +
               'Shows: tendency, reverse level, EMA/SMA cross levels, and zero-cross level.',
     group = grp_dash)
i_inlineLabelOffset = input.int(2, 'Label Bar Offset', minval = 1, maxval = 10, group = grp_dash,
     tooltip = 'Number of bars to the right of the last drawn bar where the label is placed.')
i_inlineLabelSize = input.string(size.tiny, 'Label Text Size', group = grp_dash,
     options = [size.tiny, size.small, size.normal, size.large])

// ════════════════════════════════════════════════════════════════════════════════
// ── REVERSE MACD MATH (© The_Caretaker) ─────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
alpha(len) =>
    2 / (len + 1)

// Price at which MACD stops rising / starts falling (or vice versa)
macd_eq(price, fast_len, slow_len) =>
    (alpha(fast_len) * ta.ema(price, fast_len)[1] - alpha(slow_len) * ta.ema(price, slow_len)[1]) / (alpha(fast_len) - alpha(slow_len))

// Price at which MACD equals a target level (e.g. 0 for zero-line cross)
macd_level(level, price, fast_len, slow_len) =>
    (level + (1 - alpha(slow_len)) * ta.ema(price, slow_len)[1] - (1 - alpha(fast_len)) * ta.ema(price, fast_len)[1]) / (alpha(fast_len) - alpha(slow_len))

// Price at which MACD crosses its EMA signal line
macd_cross_ema(P, V, X, Y, Z) =>
    pEMAx = ta.ema(P, X)[1]
    pEMAy = ta.ema(P, Y)[1]
    pEMAz = ta.ema(V, Z)[1]
    (pEMAx * alpha(X) * alpha(Z) - pEMAy * alpha(Y) * alpha(Z) - pEMAx * alpha(X) + pEMAy * alpha(Y) + pEMAy * alpha(Z) + pEMAz * alpha(Z) - pEMAx * alpha(Z) - pEMAy - pEMAz + pEMAx) / (alpha(X) * alpha(Z) - alpha(Y) * alpha(Z) - alpha(X) + alpha(Y))

// Price at which MACD crosses its SMA signal line
macd_cross_sma(P, V, X, Y, Z) =>
    pEMAx = ta.ema(P, X)[1]
    pEMAy = ta.ema(P, Y)[1]
    (pEMAx * alpha(X) * Z - pEMAy * alpha(Y) * Z + math.sum(V[1], Z - 1) - pEMAx * alpha(X) + pEMAy * alpha(Y) - pEMAx * Z + pEMAy * Z + pEMAx - pEMAy) / ((-1 + Z) * (alpha(X) - alpha(Y)))

// ── Calculations ─────────────────────────────────────────────────────────────
fast_ema     = ta.ema(i_source_price, i_fast_length)
slow_ema     = ta.ema(i_source_price, i_slow_length)
macd         = fast_ema - slow_ema

ema_sig_line = ta.ema(macd, i_emaLen)
sma_sig_line = ta.sma(macd, i_smaLen)

ema_hist     = macd - ema_sig_line
sma_hist     = macd - sma_sig_line

// Active histogram (EMA preferred; fall back to SMA if EMA off)
activeHist   = i_hist_e_On ? ema_hist * i_hist_e_Fact : i_hist_s_On ? sma_hist * i_hist_s_Fact : macd

// Active signal for highlight/cross logic
activeSig    = i_ema_on ? ema_sig_line : i_sma_on ? sma_sig_line : na

// Reverse levels
reverse_macd   = macd_eq(i_source_price, i_fast_length, i_slow_length)
macd_ema_cross = macd_cross_ema(i_source_price, macd, i_fast_length, i_slow_length, i_emaLen)
macd_sma_cross = macd_cross_sma(i_source_price, macd, i_fast_length, i_slow_length, i_smaLen)
macd_zero_line = macd_level(0, i_source_price, i_fast_length, i_slow_length)

// Colors
c_macd   = i_c_typ_line == 'Single' ? i_c_line : macd > macd[1] ? i_c_line_rise : i_c_line_fall
c_ema    = i_c_typ_ema  == 'Single' ? i_c_ema  : ema_sig_line > ema_sig_line[1] ? i_c_ema_rise  : i_c_ema_fall
c_sma    = i_c_typ_sma  == 'Single' ? i_c_sma  : sma_sig_line > sma_sig_line[1] ? i_c_sma_rise  : i_c_sma_fall

c_hist_e = ema_hist >= 0 ? ema_hist[1] < ema_hist ? i_c_hist_e_Urise : i_c_hist_e_Ufall : ema_hist[1] < ema_hist ? i_c_hist_e_Lrise : i_c_hist_e_Lfall
c_hist_s = sma_hist >= 0 ? sma_hist[1] < sma_hist ? i_c_hist_s_Urise : i_c_hist_s_Ufall : sma_hist[1] < sma_hist ? i_c_hist_s_Lrise : i_c_hist_s_Lfall

c_label  = macd < macd[1] ? i_label_bg_fall : i_label_bg_rise

// ── MACD/Signal crosses → on-chart shapes ────────────────────────────────────
longCross  = ta.crossover(macd,  activeSig)
shortCross = ta.crossunder(macd, activeSig)

plotshape(i_macdSigCross and not na(activeSig) ? longCross  : false,
     'Long Cross',  shape.labelup,   location.belowbar,
     color.rgb(0, 255, 8), size = size.tiny, show_last = i_lookback, display = display)
plotshape(i_macdSigCross and not na(activeSig) ? shortCross : false,
     'Short Cross', shape.labeldown, location.abovebar,
     color.rgb(255, 0, 0), size = size.tiny, show_last = i_lookback, display = display)

// ── Alert conditions ─────────────────────────────────────────────────────────
alertcondition(longCross,      'Long : Early Warning',      'Reverse MACD Overlay — Probable Long\n{{exchange}}:{{ticker}} Price={{close}} Time={{time}}')
alertcondition(longCross[1],   'Long : Trading Opportunity','Reverse MACD Overlay — Confirmed Long\n{{exchange}}:{{ticker}} Price={{close}} Time={{time}}')
alertcondition(shortCross,     'Short : Early Warning',     'Reverse MACD Overlay — Probable Short\n{{exchange}}:{{ticker}} Price={{close}} Time={{time}}')
alertcondition(shortCross[1],  'Short : Trading Opportunity','Reverse MACD Overlay — Confirmed Short\n{{exchange}}:{{ticker}} Price={{close}} Time={{time}}')

// ════════════════════════════════════════════════════════════════════════════════
// ── DASHBOARD HELPERS (must precede drawing block) ───────────────────────────
// ════════════════════════════════════════════════════════════════════════════════
i_dec_places = 0

fmt(float x) =>
    '$' + str.tostring(math.round(x, i_dec_places))

fmtDiff(float x) =>
    '$' + str.tostring(math.round(x - close, i_dec_places))

MACDCrossZero = bar_index - ta.valuewhen(ta.cross(macd, 0),            bar_index, 0)
MACDEMACross  = bar_index - ta.valuewhen(ta.cross(macd, ema_sig_line), bar_index, 0)
MACDSMACross  = bar_index - ta.valuewhen(ta.cross(macd, sma_sig_line), bar_index, 0)


priceHighest    = ta.highest(high, i_lookback)
priceLowest     = ta.lowest(low,   i_lookback)
priceChangeRate = (priceHighest - priceLowest) / priceHighest
priceLowest    := priceLowest  * (1 - priceChangeRate * i_vertAdj)
priceHighest   := priceHighest * (1 + priceChangeRate * i_vertAdj)
oscHighest      = ta.highest(math.abs(macd), i_lookback)
oscHighest     := oscHighest == 0 ? 1 : oscHighest

// Baseline price anchor (top or bottom of chart range)
basePrice(float ph, float pl) =>
    i_placement == 'Top' ? ph : pl

// Scale a MACD value to a price offset from the baseline
scaledPrice(float val, float ph, float pl, float osc, float hAdj) =>
    basePrice(ph, pl) * (1 + val / osc * hAdj)

// Histogram boxes are drawn with xloc.bar_time (instead of the bar_index xloc
// used everywhere else) because box x-coordinates in xloc.bar_index mode must
// land on whole bar indices — they can't express a sub-bar-width column. Time
// coordinates are continuous, so i_histBoxWidth can shrink each column
// symmetrically around its bar's center.
barMs = timeframe.in_seconds() * 1000
histHalfWidthMs = int(math.round(barMs * (i_histBoxWidth / 100) / 2))

var a_lines    = array.new_line()
var a_hist     = array.new_box()
var a_fill     = array.new_linefill()
var label inlineLbl = na

if barstate.islast
    // ── Clear previous drawings ───────────────────────────────────────────────
    if array.size(a_lines) > 0
        for _i = 1 to array.size(a_lines)
            line.delete(array.shift(a_lines))
    if array.size(a_hist) > 0
        for _i = 1 to array.size(a_hist)
            box.delete(array.shift(a_hist))
    if array.size(a_fill) > 0
        for _i = 1 to array.size(a_fill)
            linefill.delete(array.shift(a_fill))

    hAdj = priceChangeRate / i_height
    float base  = basePrice(priceHighest, priceLowest)
    float base1 = base  // same anchor both bars; drawn as a column from base → macd level

    // ── PASS 1: histogram boxes (EMA + SMA) — drawn first so every line
    // created in Pass 2 is guaranteed to render on top of them, since Pine
    // stacks later-created drawing objects above earlier ones regardless of
    // type or bar position. ─────────────────────────────────────────────────
    for b = 0 to i_lookback - 1
        if array.size(a_hist) < 240

            int histCenterT = time[b] + int(barMs / 2)

            // ── EMA Histogram boxes ──────────────────────────────────────────
            if i_hist_e_On
                float histTop    = base * (1 + ema_hist[b] * i_hist_e_Fact / oscHighest * hAdj)
                array.push(a_hist, box.new(
                     histCenterT - histHalfWidthMs, base, histCenterT + histHalfWidthMs, histTop,
                     xloc = xloc.bar_time, border_color = i_histBorderColor, border_width = i_histBorderWidth, bgcolor = c_hist_e[b]))

            // ── SMA Histogram boxes ──────────────────────────────────────────
            if i_hist_s_On
                float sHistTop   = base * (1 + sma_hist[b] * i_hist_s_Fact / oscHighest * hAdj)
                array.push(a_hist, box.new(
                     histCenterT - histHalfWidthMs, base, histCenterT + histHalfWidthMs, sHistTop,
                     xloc = xloc.bar_time, border_color = i_histBorderColor, border_width = i_histBorderWidth, bgcolor = c_hist_s[b]))

    // ── PASS 2: MACD / EMA / SMA lines + highlight fill — created after
    // every box above, so they always sit visually on top of the histogram. ──
    for b = 0 to i_lookback - 1
        if array.size(a_lines) < 490

            // ── MACD line ────────────────────────────────────────────────────
            if i_MACDOn
                array.push(a_lines, line.new(
                     bar_index[b],     base  * (1 + macd[b]   / oscHighest * hAdj),
                     bar_index[b + 1], base1 * (1 + macd[b+1] / oscHighest * hAdj),
                     xloc.bar_index, extend.none, c_macd[b], line.style_solid, i_p_width_line))

            // ── EMA signal line ──────────────────────────────────────────────
            if i_ema_on
                array.push(a_lines, line.new(
                     bar_index[b],     base  * (1 + ema_sig_line[b]   / oscHighest * hAdj),
                     bar_index[b + 1], base1 * (1 + ema_sig_line[b+1] / oscHighest * hAdj),
                     xloc.bar_index, extend.none, c_ema[b], line.style_solid, i_p_width_ema))

            // ── SMA signal line ──────────────────────────────────────────────
            if i_sma_on
                array.push(a_lines, line.new(
                     bar_index[b],     base  * (1 + sma_sig_line[b]   / oscHighest * hAdj),
                     bar_index[b + 1], base1 * (1 + sma_sig_line[b+1] / oscHighest * hAdj),
                     xloc.bar_index, extend.none, c_sma[b], line.style_solid, i_p_width_sma))

            // ── Highlight fill (MACD vs active signal) ───────────────────────
            if i_highlight and i_MACDOn and (i_ema_on or i_sma_on)
                // Pairs: last pushed MACD line vs last pushed signal line
                int macdIdx = array.size(a_lines) - (i_ema_on and i_sma_on ? 2 : 1)
                int sigIdx  = array.size(a_lines) - 1
                // Only fill using EMA signal if both are on (EMA takes priority)
                int fillSig = i_ema_on ? (i_sma_on ? sigIdx - 1 : sigIdx) : sigIdx
                array.push(a_fill, linefill.new(
                     array.get(a_lines, macdIdx),
                     array.get(a_lines, fillSig),
                     macd[b] > (i_ema_on ? ema_sig_line[b] : sma_sig_line[b]) ?
                          color.rgb(41, 98, 255, 50) : color.rgb(255, 109, 0, 50)))

    // ── Inline MACD label ─────────────────────────────────────────────────────
    label.delete(inlineLbl)
    if i_showInlineLabel
        float hAdj2   = priceChangeRate / i_height
        float lblY    = base * (1 + macd / oscHighest * hAdj2)
        int   lblX    = bar_index + i_inlineLabelOffset

        bool rising    = i_source_price > reverse_macd
        bool emaAbove  = i_source_price > macd_ema_cross
        bool smaAbove  = i_source_price > macd_sma_cross
        bool zeroAbove = i_source_price > macd_zero_line

        string tendLine = (rising ? 'MACD:    ▲ RISING' : 'MACD:    ▼ FALLING') +
             '  rev @: ' + fmt(reverse_macd) + ' (' + fmtDiff(reverse_macd) + ')'
        string emaLine  = i_ema_on ?
             'EMA ✕:   ' + (emaAbove ? '▲' : '▼') + ' ' + fmt(macd_ema_cross) +
             ' (' + fmtDiff(macd_ema_cross) + ')  ' +
             str.tostring(MACDEMACross + 1) + 'b ago' : ''
        string smaLine  = i_sma_on ?
             'SMA ✕:   ' + (smaAbove ? '▲' : '▼') + ' ' + fmt(macd_sma_cross) +
             ' (' + fmtDiff(macd_sma_cross) + ')  ' +
             str.tostring(MACDSMACross + 1) + 'b ago' : ''
        string zeroLine = 'ZERO ✕: ' + (zeroAbove ? '▲' : '▼') + ' ' +
             fmt(macd_zero_line) + ' (' + fmtDiff(macd_zero_line) + ')  ' +
             str.tostring(MACDCrossZero + 1) + 'b ago'

        // Compose only non-empty lines
        string txt = tendLine
        txt := i_ema_on  ? txt + '\n' + emaLine  : txt
        txt := i_sma_on  ? txt + '\n' + smaLine  : txt
        txt := txt + '\n' + zeroLine

        inlineLbl := label.new(
             lblX + 2, lblY, txt,
             xloc          = xloc.bar_index,
             yloc          = yloc.price,
             color         = c_label,
             textcolor     = i_c_label_txt,
             style         = label.style_label_left,
             size          = i_inlineLabelSize,
             textalign     = text.align_left)

// ════════════════════════════════════════════════════════════════════════════════
// ── DASHBOARD (© The_Caretaker, adapted) ─────────────────────────────────────
// ════════════════════════════════════════════════════════════════════════════════

var table MACDtable = table.new(i_tablePos, 5, 6,
     border_width = 1,
     bgcolor      = color.new(#001d35, 50),
     border_color = color.new(#000000, 50))

// ── FIX: phantom dashboard bug ──────────────────────────────────────────────
// Previously the table was only ever touched inside `if barstate.islast and
// i_showTable`. table.cell() calls simply stop running the moment the user
// unticks "Display Reverse MACD Dashboard" — nothing ever clears the cells
// that are already sitting in the (persistent, `var`) table object. The last
// populated dashboard is left behind on the chart as a phantom, ignoring the
// toggle. Fix: always clear the table first, and only repopulate it when the
// toggle is on, so turning the dashboard off actually removes it.
if barstate.islast
    table.clear(MACDtable, 0, 0, 4, 5)

    if i_showTable
        sz = i_tableSize

        // ── Header row ───────────────────────────────────────────────────────────
        table.cell(MACDtable, 0, 0, 'REVERSE MACD',   text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_center)
        table.cell(MACDtable, 1, 0, 'ACTUAL',         text_color = i_c_label_txt, text_size = sz, text_halign = text.align_center)
        table.cell(MACDtable, 2, 0, 'PROJECTION',     text_color = i_c_label_txt, text_size = sz, text_halign = text.align_center)
        table.cell(MACDtable, 3, 0, 'LEVEL',          text_color = i_c_label_txt, text_size = sz, text_halign = text.align_center)
        table.cell(MACDtable, 4, 0, 'DIF.',           text_color = i_c_label_txt, text_size = sz, text_halign = text.align_center)

        // ── Row 1: MACD Tendency ─────────────────────────────────────────────────
        bool rising = i_source_price > reverse_macd
        table.cell(MACDtable, 0, 1, 'TENDENCY:',                           text_color = i_c_label_txt, text_size = sz, text_halign = text.align_right)
        table.cell(MACDtable, 1, 1, rising ? 'NOW RISING' : 'NOW FALLING', text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        table.cell(MACDtable, 2, 1, rising ? 'Reverse ▼:' : 'Reverse ▲:',  text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        table.cell(MACDtable, 3, 1, fmt(reverse_macd),                     text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_left)
        table.cell(MACDtable, 4, 1, fmtDiff(reverse_macd),                 text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)

        // ── Row 2: EMA Signal Cross ───────────────────────────────────────────────
        if i_ema_on
            bool emaAbove = i_source_price > macd_ema_cross
            table.cell(MACDtable, 0, 2, 'EMA SIGNAL:',                          text_color = i_c_label_txt, text_size = sz, text_halign = text.align_right)
            table.cell(MACDtable, 1, 2, str.tostring(MACDEMACross + 1) + ' Bars' + (emaAbove ? ' ▲' : ' ▼'),
                 text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
            table.cell(MACDtable, 2, 2, emaAbove ? 'Below EMA:' : 'Above EMA:', text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
            table.cell(MACDtable, 3, 2, fmt(macd_ema_cross),                    text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_left)
            table.cell(MACDtable, 4, 2, fmtDiff(macd_ema_cross),                text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        else
            table.cell(MACDtable, 0, 2, 'EMA SIGNAL:', text_color = color.gray, text_size = sz, text_halign = text.align_right)
            table.cell(MACDtable, 1, 2, 'OFF', text_color = color.gray, text_size = sz, text_halign = text.align_center)
            table.cell(MACDtable, 2, 2, '—',   text_color = color.gray, text_size = sz, text_halign = text.align_center)
            table.cell(MACDtable, 3, 2, '—',   text_color = color.gray, text_size = sz, text_halign = text.align_center)
            table.cell(MACDtable, 4, 2, '—',   text_color = color.gray, text_size = sz, text_halign = text.align_center)

        // ── Row 3: SMA Signal Cross ───────────────────────────────────────────────
        if i_sma_on
            bool smaAbove = i_source_price > macd_sma_cross
            table.cell(MACDtable, 0, 3, 'SMA SIGNAL:',                          text_color = i_c_label_txt, text_size = sz, text_halign = text.align_right)
            table.cell(MACDtable, 1, 3, str.tostring(MACDSMACross + 1) + ' Bars' + (smaAbove ? ' ▲' : ' ▼'),
                 text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
            table.cell(MACDtable, 2, 3, smaAbove ? 'Below SMA:' : 'Above SMA:', text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
            table.cell(MACDtable, 3, 3, fmt(macd_sma_cross),                    text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_left)
            table.cell(MACDtable, 4, 3, fmtDiff(macd_sma_cross),                text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        else
            table.cell(MACDtable, 0, 3, 'SMA SIGNAL:', text_color = color.gray, text_size = sz, text_halign = text.align_right)
            table.cell(MACDtable, 1, 3, 'OFF', text_color = color.gray, text_size = sz, text_halign = text.align_center)
            table.cell(MACDtable, 2, 3, '—',   text_color = color.gray, text_size = sz, text_halign = text.align_center)
            table.cell(MACDtable, 3, 3, '—',   text_color = color.gray, text_size = sz, text_halign = text.align_center)
            table.cell(MACDtable, 4, 3, '—',   text_color = color.gray, text_size = sz, text_halign = text.align_center)

        // ── Row 4: Zero-line Cross ────────────────────────────────────────────────
        bool zeroAbove = i_source_price > macd_zero_line
        table.cell(MACDtable, 0, 4, 'ZERO CROSS:',                            text_color = i_c_label_txt, text_size = sz, text_halign = text.align_right)
        table.cell(MACDtable, 1, 4, str.tostring(MACDCrossZero + 1) + ' Bars' + (zeroAbove ? ' ▲' : ' ▼'),
             text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        table.cell(MACDtable, 2, 4, zeroAbove ? 'Below 0:' : 'Above 0:',     text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        table.cell(MACDtable, 3, 4, fmt(macd_zero_line),                      text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_left)
        table.cell(MACDtable, 4, 4, fmtDiff(macd_zero_line),                  text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)

        // ── Row 5: Current MACD value ─────────────────────────────────────────────
        table.cell(MACDtable, 0, 5, 'MACD NOW:',                              text_color = i_c_label_txt, text_size = sz, text_halign = text.align_right)
        table.cell(MACDtable, 1, 5, str.tostring(math.round(macd, 4)),        text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        table.cell(MACDtable, 2, 5, 'EMA Sig:',                               text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)
        table.cell(MACDtable, 3, 5, str.tostring(math.round(ema_sig_line, 4)),text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_left)
        table.cell(MACDtable, 4, 5, str.tostring(math.round(ema_hist, 4)),    text_color = i_c_label_txt, text_size = sz, bgcolor = c_label, text_halign = text.align_right)

// ── Branding ──────────────────────────────────────────────────────────────────
var table logo = table.new(position.bottom_right, 1, 1)
````
