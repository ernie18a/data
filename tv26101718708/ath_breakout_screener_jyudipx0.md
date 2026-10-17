# ATH Breakout Screener

- url: https://www.tradingview.com/script/jyuDipX0-ATH-Breakout-Screener/
- type: indicator
- pine_id: PUB;586e28789dbe454984af78e0fa8fa10b
- version: 1.0

## Description

ATH Breakout Screener. This is to find all the time high breakouts.

## Source Code

````pine
// ═══════════════════════════════════════════════════════
// ATH Breakout Screener — NSE Daily
// Pine Script v6
// — True ATH from full chart history
// — Signal only on current bar (barstate.islast)
// — Flat horizontal lines via line.new() + extend.both
// ═══════════════════════════════════════════════════════

//@version=6
indicator("ATH Breakout Screener", overlay = true)

// ── Inputs ────────────────────────────────────────────
int   min_gap   = input.int  (6,     title = "Min bars since ATH",  minval = 1)
float pct_range = input.float(5.0,  title = "ATH proximity %",     minval = 0.1, maxval = 20.0)
float min_price = input.float(100.0, title = "Min price ₹",         minval = 0.0)

// ── All-Time High tracking (full history) ─────────────
var int   ath_bar = 0
var float ath_val = 0.0

if high >= ath_val
    ath_val := high
    ath_bar  := bar_index

// ── Derived values ────────────────────────────────────
int   bars_since = bar_index - ath_bar
float lower_band = ath_val * (1.0 - pct_range / 100.0)
float upper_band = ath_val * (1.0 + pct_range / 100.0)

// ── Conditions ────────────────────────────────────────
bool cond_gap      = bars_since >= min_gap
bool cond_near_ath = close >= lower_band and close <= upper_band
bool cond_price    = close > min_price
bool signal        = cond_gap and cond_near_ath and cond_price and barstate.islast

// ── Flat horizontal lines via line.new() ──────────────
// var line ensures object is created once, not on every bar
var line l_ath   = na
var line l_lower = na
var line l_upper = na

if barstate.islast
    // Delete previous lines if they exist (handles real-time updates)
    if not na(l_ath)
        line.delete(l_ath)
        line.delete(l_lower)
        line.delete(l_upper)

    l_ath   := line.new(x1 = bar_index, y1 = ath_val,
                 x2 = bar_index - 1, y2 = ath_val,
                 extend = extend.both,
                 color  = color.red,
                 width  = 2,
                 style  = line.style_solid)

    l_lower := line.new(x1 = bar_index, y1 = lower_band,
                 x2 = bar_index - 1, y2 = lower_band,
                 extend = extend.both,
                 color  = color.new(color.orange, 30),
                 width  = 1,
                 style  = line.style_dashed)

    l_upper := line.new(x1 = bar_index, y1 = upper_band,
                 x2 = bar_index - 1, y2 = upper_band,
                 extend = extend.both,
                 color  = color.new(color.green, 30),
                 width  = 1,
                 style  = line.style_dashed)

// ── Signal marker (current bar only) ─────────────────
plotshape(signal,
     title    = "ATH Breakout Signal",
     style    = shape.triangleup,
     location = location.belowbar,
     color    = color.lime,
     size     = size.normal)

bgcolor(signal ? color.new(color.lime, 85) : na,
     title = "Signal bar highlight")

// ── Alert ─────────────────────────────────────────────
alertcondition(signal,
     title   = "ATH Breakout Setup",
     message = "{{ticker}} — within 5% of ATH. Bars since ATH: {{plot_0}}. Close: {{close}}")
````
