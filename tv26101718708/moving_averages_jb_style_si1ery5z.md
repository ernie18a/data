# Moving averages. JB style

- url: https://www.tradingview.com/script/si1ERy5Z-Moving-averages-JB-style/
- type: indicator
- pine_id: PUB;588c42cb9c71417fa3c6b57ed5b1ad4c
- version: 1.0

## Description

[b]Moving averages. JB style[/b]

A clean, configurable multi-MA overlay. Up to four moving averages, each colored by its own slope, with debounced crossover markers, weight-scaled line widths, an EMA/SMA switch, a regular-hours session lock, and five color palettes — all tuned so the indicator reads as a separate layer over your candles instead of blending into them.


[b]WHAT IT DOES[/b]

- Up to 4 moving averages. Defaults are 9 / 21 / 50 / 200, and every slot has its own editable length and show/hide toggle, so you can run one MA or all four. Source is fixed to close to keep the panel simple.

- EMA or SMA from one dropdown. The MA Type dropdown flips all lines between simple and exponential, reusing the same lengths and styling.

- Slope-based coloring. Each line is colored by its own slope: a blue tone when rising, an orange/amber tone when falling, and neutral gray when essentially flat. Colors sit deliberately off the green/red axis so the lines never blend into the candles.

- Weight-scaled widths. Faster MAs are thin, slower MAs are thick, so the long-term anchors stand out at a glance. The slowest MA is drawn as a dotted circle line to mark it as the long-term reference.

- Crossover markers. A hollow ring with a centered dot marks crossovers between adjacent MAs (1x2, 2x3, 3x4) — including the classic 50/200 — a bright bull tone for a bullish cross and an amber tone for a bearish one, placed right at the crossing price.

- Five palettes. Dark, Light, Neon, Ocean, and Solarized. Candles are never recolored on any theme.


[b]WHY IT'S DIFFERENT[/b]

Most moving-average indicators just draw lines and color them by whether price is above or below — which whipsaws constantly. This one is built around signal reliability:

1. Slope coloring instead of price-vs-MA coloring. Color reflects whether the average itself is rising or falling — a steadier read of trend than the noisy "is price above the line" flip.

2. A slope deadband kills color flicker. Near-flat averages normally strobe between colors on every tick. Here the slope must clear an ATR-scaled threshold before the color flips; otherwise the line goes neutral. A flat ribbon looks flat — which is itself useful information.

3. Crossovers are MA vs MA, not price vs MA. A faster average crossing a slower one needs agreement between two degrees of smoothing, so it fires far less on noise than a single line being touched by price.

4. A debounce filter removes chop without lagging the signal. The marker fires on the actual crossover, then suppresses further crosses until the two averages genuinely separate (by an ATR-scaled amount) and reconverge. A cluster of back-and-forth chop crosses produces one marker on the real cross — not a smear of noise, and not delayed to a later cross.

5. Confirmed-bar markers don't repaint. A crossover marker appears only after the bar closes, so it never flashes mid-bar and then vanishes.

6. Regular-hours session lock. Every MA (and the ATR behind the filters) is computed from a regular-session feed, so a 200-MA reads the same whether your chart shows extended hours or not. The lines simply hold flat through pre/post-market instead of drifting. On 24/7 instruments this is a harmless no-op.

7. Always the chart's own timeframe. The session lock swaps only the session, never the timeframe — the MAs are always calculated on the timeframe you're viewing.

8. Lines that don't fight the candles. Bull/bear line colors are deliberately blue/orange rather than green/red, so the indicator reads as a clean layer over the candles instead of camouflaging into them.


[b]INPUTS[/b]

- Palette: color theme for lines and markers (Dark / Light / Neon / Ocean / Solarized).
- MA Type: SMA or EMA, applied to all lines.
- Regular Hours Only: compute all MAs and ATR from a regular-session feed, regardless of the chart's session.
- Show Crossovers: toggle all crossover markers.
- Slope Deadband (x ATR): minimum slope before the color flips; 0 disables (default 0.02).
- Crossover Min Sep (x ATR): debounce gap — after a marked cross, the next one is suppressed until the MAs separate by this amount and reconverge; 0 disables (default 0.10).
- MA #1-4 Show / Length: per-slot visibility and period (defaults 9 / 21 / 50 / 200).

## Source Code

````pine
//@version=6
indicator('Moving averages. JB style', shorttitle = 'MAs', overlay = true)

// Show lines on the chart pane ONLY — keeps the status line, price scale, and
// data window clean (no per-plot values, name tags, or crossover markers).
disp = display.pane

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
palette   = input.string('Dark', 'Palette', options = ['Dark', 'Light', 'Neon', 'Ocean', 'Solarized'], group = 'General')
ma_type   = input.string('SMA', 'MA Type', options = ['SMA', 'EMA'], group = 'General')
reg_hours = input.bool(true, 'Regular Hours Only', group = 'General')
show_x    = input.bool(true, 'Show Crossovers', group = 'General')

slope_db  = input.float(0.02, 'Slope Deadband (× ATR)', minval = 0, step = 0.01, group = 'Filters')
cross_sep = input.float(0.10, 'Crossover Min Sep (× ATR)', minval = 0, step = 0.05, group = 'Filters')

show1 = input.bool(true, 'Show', inline = 'ma1', group = 'MA #1 (fastest)')
len1  = input.int(9, 'Length', minval = 1, inline = 'ma1', group = 'MA #1 (fastest)')

show2 = input.bool(true, 'Show', inline = 'ma2', group = 'MA #2')
len2  = input.int(21, 'Length', minval = 1, inline = 'ma2', group = 'MA #2')

show3 = input.bool(true, 'Show', inline = 'ma3', group = 'MA #3')
len3  = input.int(50, 'Length', minval = 1, inline = 'ma3', group = 'MA #3')

show4 = input.bool(true, 'Show', inline = 'ma4', group = 'MA #4 (slowest)')
len4  = input.int(200, 'Length', minval = 1, inline = 'ma4', group = 'MA #4 (slowest)')

// ─────────────────────────────────────────────
// PALETTE  — resolves to 5 colors; no inline hex elsewhere
// Bull = blue family, bear = orange/amber family — deliberately OFF the
// green/red axis so the lines never blend into the candles.
// ─────────────────────────────────────────────
[bull_col, bear_col, flat_col, bull_x_col, bear_x_col] = switch palette
    'Dark'      => [#2962FF, #FF9800, #B2B5BE, #82B1FF, #FFD54F]
    'Light'     => [#1565C0, #E65100, #607D8B, #1E88E5, #FB8C00]
    'Neon'      => [#00E5FF, #FF9E00, #B388FF, #18FFFF, #FFD300]
    'Ocean'     => [#00ACC1, #FB8C00, #546E7A, #26C6DA, #FFB300]
    'Solarized' => [#268BD2, #CB4B16, #93A1A1, #5FAFE0, #E07B3C]
    => [#2962FF, #FF9800, #B2B5BE, #82B1FF, #FFD54F]

// ─────────────────────────────────────────────
// COMPUTATION  — EMA/SMA on a session-locked feed (timeframe = chart's)
// ─────────────────────────────────────────────
ma(s, l) => ma_type == 'EMA' ? ta.ema(s, l) : ta.sma(s, l)

rth_tid = ticker.new(syminfo.prefix, syminfo.ticker, session = session.regular)
src_tid = reg_hours ? rth_tid : syminfo.tickerid

out1 = request.security(src_tid, timeframe.period, ma(close, len1), lookahead = barmerge.lookahead_off)
out2 = request.security(src_tid, timeframe.period, ma(close, len2), lookahead = barmerge.lookahead_off)
out3 = request.security(src_tid, timeframe.period, ma(close, len3), lookahead = barmerge.lookahead_off)
out4 = request.security(src_tid, timeframe.period, ma(close, len4), lookahead = barmerge.lookahead_off)

atr14 = request.security(src_tid, timeframe.period, ta.atr(14), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
// SLOPE COLOR + LINES  — color by slope (deadband → neutral); width = weight
// ─────────────────────────────────────────────
slopeColor(cur) =>
    th = slope_db * atr14
    d  = cur - cur[1]
    d > th ? bull_col : d < -th ? bear_col : flat_col

plot(show1 ? out1 : na, 'MA #1', color = slopeColor(out1), linewidth = 1, editable = false, display = disp)
plot(show2 ? out2 : na, 'MA #2', color = slopeColor(out2), linewidth = 2, editable = false, display = disp)
plot(show3 ? out3 : na, 'MA #3', color = slopeColor(out3), linewidth = 3, editable = false, display = disp)
plot(show4 ? out4 : na, 'MA #4', color = slopeColor(out4), linewidth = 2, style = plot.style_circles, editable = false, display = disp)

// ─────────────────────────────────────────────
// CROSSOVERS  — adjacent visible pairs; ATR-separation + confirmed-bar filtered
// ─────────────────────────────────────────────
// Returns [draw?, bullish?]. DEBOUNCE filter: the marker fires on the FIRST
// cross (right at the crossover bar), then is suppressed until the pair has
// genuinely separated by cross_sep × ATR and reconverged — so chop is filtered
// without delaying the real signal. cross_sep = 0 disables the filter.
crossSignal(fast, slow) =>
    var bool armed = true
    sep = math.abs(fast - slow)
    // Re-arm once the MAs have separated past the threshold since the last
    // marked cross. At a cross bar sep ≈ 0, so this never re-arms on the cross
    // itself — only after a genuine divergence opens up.
    if cross_sep == 0 or sep >= cross_sep * atr14
        armed := true
    xUp  = ta.crossover(fast, slow)
    xDn  = ta.crossunder(fast, slow)
    fire = (xUp or xDn) and armed
    // Disarm on a confirmed fired cross (same gate as emission) so a realtime
    // intrabar flicker can't consume the arm and hide the next real cross.
    if fire and barstate.isconfirmed
        armed := false
    [fire and barstate.isconfirmed, xUp]

[sig12, dir12] = crossSignal(out1, out2)
[sig23, dir23] = crossSignal(out2, out3)
[sig34, dir34] = crossSignal(out3, out4)

vis12 = show1 and show2
vis23 = show2 and show3
vis34 = show3 and show4

// Crossover markers at the crossing price: a hollow ring (◯, size.small) with a
// filled centered dot (•, size.normal) layered on top, same color. The • glyph
// is intrinsically much smaller than ◯ per size step, so a normal dot sits
// centered inside the small ring. The ring reads against the lines; the dot
// pins the exact level. (Bump/drop the dot's size to taste.)
m1 = show_x and vis12 and sig12 ? out2 : na
m2 = show_x and vis23 and sig23 ? out3 : na
m3 = show_x and vis34 and sig34 ? out4 : na

plotchar(m1, 'Cross 1×2', char = '◯', location = location.absolute, color = dir12 ? bull_x_col : bear_x_col, size = size.small, editable = false, display = disp)
plotchar(m2, 'Cross 2×3', char = '◯', location = location.absolute, color = dir23 ? bull_x_col : bear_x_col, size = size.small, editable = false, display = disp)
plotchar(m3, 'Cross 3×4', char = '◯', location = location.absolute, color = dir34 ? bull_x_col : bear_x_col, size = size.small, editable = false, display = disp)

plotchar(m1, 'Cross 1×2 dot', char = '•', location = location.absolute, color = dir12 ? bull_x_col : bear_x_col, size = size.normal, editable = false, display = disp)
plotchar(m2, 'Cross 2×3 dot', char = '•', location = location.absolute, color = dir23 ? bull_x_col : bear_x_col, size = size.normal, editable = false, display = disp)
plotchar(m3, 'Cross 3×4 dot', char = '•', location = location.absolute, color = dir34 ? bull_x_col : bear_x_col, size = size.normal, editable = false, display = disp)
````
