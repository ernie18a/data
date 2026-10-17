# edgeful - iFVG - inverse fair value gaps

- url: https://www.tradingview.com/script/eReDWB2w-edgeful-iFVG-inverse-fair-value-gaps/
- type: indicator
- pine_id: PUB;32684a59c8504ade8a70459ed462dc0b
- version: 1.0

## Description

edgeful – iFVG (Inverse Fair Value Gaps)

What it is, in plain English

This indicator plots Inverse Fair Value Gap zones on your chart — areas where a previous price imbalance failed, flipped polarity, and now (in theory) acts as the opposite kind of pressure. It's an ICT/SMC concept: a Fair Value Gap that gets violated isn't dead — it becomes a "trap" zone that the market often respects from the other side.

The indicator does three things, in sequence:

1. Finds every standard 3-candle Fair Value Gap as it forms.
2. Watches each one, waiting to see if price comes back and breaks through it.
3. Flips any broken FVG into an iFVG with the opposite polarity, drawing a new box in a different color.

It also keeps the chart clean by removing zones that are too old or that get fully invalidated, and it can fire alerts when new iFVGs form.

---

The core concept it's built on

A Fair Value Gap (FVG)

An FVG is a three-candle pattern where the wicks of candle 1 and candle 3 don't touch each other — leaving a literal gap in price that was never "traded through." It represents a moment of one-sided urgency where buyers (or sellers) ran price so fast that intermediate prices were skipped.

- Bullish FVG: an upward gap, where candle 3's low is above candle 1's high. The space between them is unfilled bullish imbalance — often acts as support if revisited.
- Bearish FVG: a downward gap, where candle 3's high is below candle 1's low. The space is unfilled bearish imbalance — often acts as resistance if revisited.

The ICT/SMC narrative is that institutions tend to revisit and "fill" these gaps to rebalance order flow before continuing the move.

An Inverse FVG (iFVG)

Here's where this indicator earns its name. The iFVG idea says:

When a Fair Value Gap is decisively broken through instead of merely respected, its meaning inverts. The trapped participants on the wrong side of that broken zone now defend the opposite direction.

So:
- A bullish FVG that gets broken to the downside becomes a bearish iFVG — the area where buyers got trapped now acts as resistance.
- A bearish FVG that gets broken to the upside becomes a bullish iFVG — the area where sellers got trapped now acts as support.

The iFVG occupies the exact same price coordinates as the original FVG. What changes is its polarity — and how a trader treats it.

---

How the indicator detects an FVG

On every confirmed bar, it looks at the last three candles and checks the classic textbook pattern:

- Bullish FVG: the current candle's low is above the high of two candles ago, and the middle candle's close also broke above that two-bars-ago high (a confirmation that real upward displacement happened, not just a wick).
- Bearish FVG: the mirror — current candle's high is below the low of two candles ago, with the middle candle's close confirming the downward break.

There's an optional Min FVG Size % filter. If you set it above zero, the gap has to be at least that percentage of price to count. Set to 0, every qualifying 3-candle gap is detected. This is useful on lower timeframes where tiny micro-gaps would otherwise clutter the chart.

There's also an optional Session filter — when enabled, only FVGs that form inside the chosen session window (default NY 09:30–16:00, America/New_York) are tracked. Anything outside is ignored.

When an FVG is detected, the indicator records its high, low, direction (bull/bear), and the timestamp of the first candle of the formation. If the "Show Original FVGs" toggle is on, it also draws a translucent box over the gap.

---

How it tracks mitigation

Once an FVG exists, every new bar checks whether price has violated it. You choose how strict that check is:

- Close mode (default): the candle's close must move beyond the far side of the zone. Bullish FVG mitigates only when a bar closes below its bottom; bearish FVG mitigates only when a bar closes above its top. This is more conservative — it ignores wicks.
- Wick mode: the candle's wick is enough. Bullish FVG mitigates when any low pierces below the bottom; bearish FVG mitigates when any high pierces above the top. This is more sensitive — every tag counts.

While an FVG is not yet mitigated, its box keeps getting extended to the right edge of the chart, so it remains visible as a live zone. The "Extend Boxes (bars)" input controls how far ahead the right edge of the box is drawn.

---

The flip from FVG to iFVG

The moment an FVG is mitigated, the indicator does this:

1. Deletes the original FVG box from the chart.
2. Creates a new iFVG record with the same exact price coordinates (same top, same bottom, same starting timestamp) but with the direction reversed.
3. Draws a new box in the iFVG color palette (cyan for bullish iFVG, orange for bearish iFVG by default), distinct from the FVG colors (blue/red), so you can visually tell at a glance which zones are "fresh imbalances" vs. which are "flipped traps."

If you keep "Show Original FVGs" off (the default), you never see the FVG itself — you only see iFVGs at the moment they're born. This keeps the chart focused on the zones the indicator is actually designed to highlight.

---

What happens to iFVGs after they form

iFVGs aren't permanent either. The indicator continues to watch them with the same mitigation logic:

- A bullish iFVG (acting as support) is invalidated when price closes or wicks below its lower boundary.
- A bearish iFVG (acting as resistance) is invalidated when price closes or wicks above its upper boundary.

When an iFVG is invalidated, it's deleted — there's no further flip. The cycle is one-way: FVG → iFVG → gone.

While an iFVG is still alive, its box keeps extending to the right, just like the FVG box did.

---

Housekeeping: the "Max Zone Age" filter

A common problem with FVG-style indicators is chart clutter — every stale zone from days or weeks ago lingers forever. This indicator solves that with Max Zone Age (bars), default 500.

If any zone (FVG or iFVG) is older than that many bars and still hasn't been mitigated, it's silently removed. No iFVG is spawned in that case — old, ignored zones just expire without ceremony.

This means the chart only ever shows zones that are recent enough to plausibly matter to current price action.

---

How a trader would actually use it

The intended workflow:

1. Watch for an iFVG zone to appear — this signals that an imbalance was just broken, and the market may now defend the opposite side.
2. Wait for price to retrace back into the iFVG — the entry trigger.
3. Use it as a directional bias:
   - Bullish iFVG (cyan) = look for longs from this zone.
   - Bearish iFVG (orange) = look for shorts from this zone.
4. Treat invalidation as a hard stop: if price closes (or wicks, depending on your mode) cleanly through the far side of the iFVG, the trade thesis is dead.

iFVGs are often used in multi-timeframe confluence: an HTF iFVG (say, 1H) lining up with an LTF entry pattern (5m order block, sweep, etc.) is the classic ICT setup.

---

Built-in alerts

Two alert conditions fire automatically:

- Bullish iFVG Created — fires the bar a bearish FVG flips into a bullish iFVG (new potential support).
- Bearish iFVG Created — fires the bar a bullish FVG flips into a bearish iFVG (new potential resistance).

Useful if you want to be pinged when a fresh trap zone is born without staring at the chart.

---

Practical notes

- All detection happens on confirmed bars only, so the zones don't repaint mid-bar.
- Boxes use bar-time coordinates (not bar-index), which means the indicator works correctly on long historical charts without hitting TradingView's lookback distance limit.
- Default settings: NY session filter is off (detects everywhere), close-based mitigation, original FVGs hidden, iFVGs shown, 500-bar extension, 500-bar max age.
- Colors are fully customizable for both FVG and iFVG, bull and bear.

---

TL;DR

It finds 3-candle imbalances, watches them, and when one gets broken, it draws a flipped version on the same spot — because broken imbalances often become the opposite kind of magnet/barrier. It's a clean, automated implementation of the ICT "iFVG" concept with mitigation modes, session filtering, age limits, and alerts so you don't have to draw any of this by hand.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © edgeful

//@version=6
indicator("edgeful - iFVG - inverse fair value gaps", overlay=true,
  max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ─── UDT ────────────────────────────────────────────────────────────────────
// Stores the price boundaries and direction of each FVG / iFVG zone.
// bar_time records the timestamp (ms) of the first candle in the 3-candle
// pattern. Used as the box left edge with xloc.bar_time to avoid the
// bar_index distance limit on long histories.
type fvg
    float max
    float min
    bool  isbull
    int   bar_time

// ─── INPUTS ─────────────────────────────────────────────────────────────────

// --- Session Settings ---
grpSession = "Session Settings"
tzInput       = input.string("America/New_York", "Timezone", group=grpSession,
  tooltip="Timezone for session filter. Use IANA format.")
useSession    = input.bool(false, "Filter to Session", group=grpSession,
  tooltip="Only detect FVGs during the specified session window.")
sessionInput  = input.session("0930-1600", "Session", group=grpSession,
  tooltip="Session window for FVG detection (NY default).")

// --- FVG Settings ---
grpFVG = "FVG Settings"
threshold     = input.float(0.0, "Min FVG Size %", minval=0.0, step=0.01,
  group=grpFVG,
  tooltip="Minimum gap size as % of price. 0 = detect all.")
mitType       = input.string("Close", "Mitigation By",
  options=["Close", "Wick"], group=grpFVG,
  tooltip="Close: candle close must violate zone. Wick: candle wick (low for bull, high for bear).")
showFVG       = input.bool(false, "Show Original FVGs", group=grpFVG,
  tooltip="Display the original FVG boxes before they flip to iFVGs.")
showIFVG      = input.bool(true, "Show iFVG Zones", group=grpFVG,
  tooltip="Display the inverted FVG zones after polarity flip.")
extendBars    = input.int(500, "Extend Boxes (bars)", minval=0, maxval=5000,
  group=grpFVG,
  tooltip="How many bars to extend zone boxes to the right.")
maxAgeBars    = input.int(500, "Max Zone Age (bars)", minval=10, maxval=5000,
  group=grpFVG,
  tooltip="Remove FVG and iFVG zones older than this many bars. Keeps the chart clean.")

// --- Visual Settings ---
grpVisual = "Visual Settings"
bullFVGColor  = input.color(color.new(#2962FF, 80), "Bull FVG Color",
  group=grpVisual, inline="fvg")
bearFVGColor  = input.color(color.new(#F23645, 80), "Bear FVG Color",
  group=grpVisual, inline="fvg")
bullIFVGColor = input.color(color.new(#00BCD4, 70), "Bull iFVG Color",
  group=grpVisual, inline="ifvg")
bearIFVGColor = input.color(color.new(#FF9800, 70), "Bear iFVG Color",
  group=grpVisual, inline="ifvg")

// ─── SESSION FILTER ─────────────────────────────────────────────────────────
// When useSession is false, inSession is always true so every bar qualifies.
inSession = useSession ? not na(time(timeframe.period, sessionInput, tzInput)) : true

// ─── ARRAYS ─────────────────────────────────────────────────────────────────
// Four parallel arrays: FVG records+boxes and iFVG records+boxes.
// Boxes may contain na when the corresponding show toggle is off.
var fvg_records  = array.new<fvg>(0)
var fvg_boxes    = array.new<box>(0)
var ifvg_records = array.new<fvg>(0)
var ifvg_boxes   = array.new<box>(0)

// ─── EXTEND DURATION ────────────────────────────────────────────────────────
// Convert extendBars to milliseconds so box right edges stay correct when
// using xloc.bar_time. timeframe.in_seconds() returns current TF seconds.
int tfMs       = math.round(timeframe.in_seconds() * 1000)
int extendMs   = extendBars * tfMs
int cutoffTime = time - maxAgeBars * tfMs

// ─── FVG DETECTION ──────────────────────────────────────────────────────────
// Classic 3-candle FVG pattern:
//   Bull FVG: candle 0's low > candle 2's high (gap up), confirmed by
//             candle 1's close above candle 2's high.
//   Bear FVG: candle 0's high < candle 2's low (gap down), confirmed by
//             candle 1's close below candle 2's low.
// The threshold filter requires the gap to be at least X% of price.
bull_fvg = low > high[2] and close[1] > high[2] and (threshold == 0.0 or (low - high[2]) / high[2] >= threshold / 100)
bear_fvg = high < low[2] and close[1] < low[2] and (threshold == 0.0 or (low[2] - high) / high >= threshold / 100)

// ─── FVG REGISTRATION ───────────────────────────────────────────────────────
// On detection, store the FVG record and optionally draw a box.
// time[2] is the timestamp of the first candle in the 3-candle formation.
if bull_fvg and inSession and barstate.isconfirmed
    fvg_records.unshift(fvg.new(low, high[2], true, time[2]))
    fvg_boxes.unshift(showFVG ? box.new(time[2], low, time + extendMs, high[2], xloc=xloc.bar_time, border_color=na, bgcolor=bullFVGColor) : na)

if bear_fvg and inSession and barstate.isconfirmed
    fvg_records.unshift(fvg.new(low[2], high, false, time[2]))
    fvg_boxes.unshift(showFVG ? box.new(time[2], low[2], time + extendMs, high, xloc=xloc.bar_time, border_color=na, bgcolor=bearFVGColor) : na)

// ─── FVG MITIGATION LOOP ───────────────────────────────────────────────────
// Iterate backwards so removing elements mid-loop is safe.
// When a FVG is fully violated by price, it flips into an iFVG:
//   - Bull FVG mitigated (price closes/wicks below min) -> bearish iFVG (resistance)
//   - Bear FVG mitigated (price closes/wicks above max) -> bullish iFVG (support)
// The iFVG keeps the same price coordinates but flipped polarity.

// Track whether new iFVGs were created this bar (for alerts)
var bool bull_ifvg_created = false
var bool bear_ifvg_created = false
bull_ifvg_created := false
bear_ifvg_created := false

if fvg_records.size() > 0
    for i = fvg_records.size() - 1 to 0
        fvg g = fvg_records.get(i)
        // Mitigation source depends on user choice and FVG direction
        bool mitigated = false
        if g.isbull
            float mitSrc = mitType == "Close" ? close : low
            mitigated := mitSrc < g.min
        else
            float mitSrc = mitType == "Close" ? close : high
            mitigated := mitSrc > g.max

        bool tooOld = g.bar_time < cutoffTime

        if tooOld
            // Age-expired: delete box silently, no iFVG spawned
            box b = fvg_boxes.get(i)
            if not na(b)
                b.delete()
            fvg_boxes.remove(i)
            fvg_records.remove(i)

        else if mitigated
            // Delete original FVG box
            box b = fvg_boxes.get(i)
            if not na(b)
                b.delete()
            fvg_boxes.remove(i)
            fvg_records.remove(i)

            // Create iFVG with flipped polarity, same coordinates
            bool ifvgBull = not g.isbull
            ifvg_records.unshift(fvg.new(g.max, g.min, ifvgBull, g.bar_time))

            color ifvgColor = ifvgBull ? bullIFVGColor : bearIFVGColor
            ifvg_boxes.unshift(showIFVG ? box.new(g.bar_time, g.max, time + extendMs, g.min, xloc=xloc.bar_time, border_color=na, bgcolor=ifvgColor) : na)

            // Flag for alertcondition
            if ifvgBull
                bull_ifvg_created := true
            else
                bear_ifvg_created := true
        else
            // Not mitigated -- extend box right edge to keep zone visible
            if showFVG
                box b = fvg_boxes.get(i)
                if not na(b)
                    b.set_right(time + extendMs)

// ─── iFVG MITIGATION LOOP ──────────────────────────────────────────────────
// Same mitigation logic applied to iFVG zones. When price fully violates
// an iFVG, the zone is invalidated and removed (no further flip).
if ifvg_records.size() > 0
    for i = ifvg_records.size() - 1 to 0
        fvg g = ifvg_records.get(i)
        bool mitigated = false
        if g.isbull
            // Bullish iFVG (support) invalidated when price breaks below
            float mitSrc = mitType == "Close" ? close : low
            mitigated := mitSrc < g.min
        else
            // Bearish iFVG (resistance) invalidated when price breaks above
            float mitSrc = mitType == "Close" ? close : high
            mitigated := mitSrc > g.max

        bool tooOld = g.bar_time < cutoffTime

        if tooOld or mitigated
            box b = ifvg_boxes.get(i)
            if not na(b)
                b.delete()
            ifvg_boxes.remove(i)
            ifvg_records.remove(i)
        else
            // Not mitigated -- extend box right edge
            if showIFVG
                box b = ifvg_boxes.get(i)
                if not na(b)
                    b.set_right(time + extendMs)

// [EXTENSION] Add confluence scoring here (e.g., iFVG overlapping with
// order block or VWAP band gets higher confidence rating)

// [EXTENSION] Add label at iFVG creation point showing zone price range

// [EXTENSION] Add HTF iFVG detection via request.security() for
// multi-timeframe confluence

// ─── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(bull_ifvg_created, "Bullish iFVG Created",
  "Bullish iFVG formed -- potential support zone")
alertcondition(bear_ifvg_created, "Bearish iFVG Created",
  "Bearish iFVG formed -- potential resistance zone")
````
