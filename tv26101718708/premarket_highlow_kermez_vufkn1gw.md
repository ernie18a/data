# Premarket High/Low - Kermez

- url: https://www.tradingview.com/script/vufKn1gw-Premarket-High-Low-Kermez/
- type: indicator
- pine_id: PUB;13a92370d23e4b2983dfcc04cf5a766e
- version: 1.0

## Description

Here's a description you can paste into TradingView's publish form. It follows their publication guidelines (clear explanation, no vague claims, no promotion) and is structured how experienced publishers format theirs.

---

**Premarket High/Low**

This indicator tracks the highest high and lowest low made during the US equity premarket session (04:00–09:00 ET by default) and projects those two levels as horizontal lines across the regular trading session (09:30–16:00 ET). Many traders use premarket extremes as intraday support and resistance — breaks above the PM high or below the PM low often coincide with momentum moves during regular hours.

**How it works**

During premarket, the script records the running high and low of that window. Once premarket closes at 09:00, the levels lock in and are drawn as horizontal lines that extend through to the 16:00 close. Lines do not carry over past the close — each trading day gets its own fresh PM range.

**Features**

- Timezone-aware session detection — works correctly regardless of your chart timezone (default America/New_York, configurable to major exchange zones).
- Live range building during premarket so you can watch the levels form in real time.
- Projected horizontal lines from 09:00 to 16:00, drawn even before the current bar catches up to 16:00.
- Labels at the regular-session open showing the exact PM high and PM low prices.
- Optional premarket background tint to visually highlight the session window.
- Two built-in alert conditions: **Break above Premarket High** and **Break below Premarket Low**, both restricted to regular trading hours so you aren't woken up by overnight prints.
- All colors, line width, and toggles exposed as inputs.

**How to use**

Apply to any US equity, ETF, or index on an intraday timeframe — 1, 5, or 15-minute charts work best. The indicator will not draw on daily or higher timeframes (by design). Once applied, right-click either plotted line and select "Add alert on…" or use the chart-level Alerts dialog to wire up breakout notifications.

**Settings**

- *Premarket Window* — default 04:00–09:00. Adjust if you trade a different session.
- *Regular Session* — default 09:30–16:00. Used to detect the open bar and restrict alerts.
- *Timezone* — set this to match the instrument you're trading.
- *Style* — colors, line width, background tint, and label visibility.
- *Alerts* — toggle breakout alerts on/off.

**Notes**

This is an informational tool, not a trading system — the PM high and PM low are reference levels, not signals on their own. Breakouts can and do fail; always combine with your own risk management. Works on any symbol that has meaningful premarket activity; low-volume instruments may produce noisy ranges.

Pine Script v6.

---

A few practical tips for the rest of the publish form:

- **Title** — keep it short, something like `Premarket High/Low`. TradingView rejects titles that sound marketing-y.
- **Tags/Categories** — pick Volatility or Trend Analysis; tag with `premarket`, `support`, `resistance`, `breakout`, `day-trading`.
- **Screenshot** — TradingView requires one. Take a clean chart shot with the indicator applied, ideally on a liquid name like SPY or QQQ on a 5-min chart showing both lines and a label. Avoid screenshots with other indicators or personal annotations cluttering the view.
- **Release notes** — leave blank on first publish; you'll use this field later if you update the script.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Premarket High/Low (04:00–09:00)
// ─────────────────────────────────────────────────────────────────────────────
// Tracks the high and low of the US equity premarket window and projects those
// levels as horizontal lines from the end of premarket (09:00) through the
// regular-session close (16:00). Fires alerts when price breaks above or below
// the premarket range during regular hours.
//
// Line behavior:
//   • 04:00–09:00  live plot — PM high/low update as new extremes are set
//   • 09:00–16:00  horizontal projected lines at the locked-in PM levels
//   • 16:00 →      lines stop (no overnight extension)
// ─────────────────────────────────────────────────────────────────────────────

indicator("Premarket High/Low",
     shorttitle       = "PM H/L",
     overlay          = true,
     max_labels_count = 500,
     max_lines_count  = 500)

// ─── Inputs: Sessions ────────────────────────────────────────────────────────
grpSess   = "Sessions"
pmSession = input.session("0400-0900", "Premarket Window", group = grpSess)
rgSession = input.session("0930-1600", "Regular Session",  group = grpSess)
tz        = input.string("America/New_York", "Timezone",
     options = ["America/New_York", "America/Chicago", "America/Los_Angeles",
                "Europe/London", "Europe/Berlin", "Asia/Tokyo",
                "Asia/Hong_Kong", "Australia/Sydney", "UTC"],
     group   = grpSess)

// ─── Inputs: Style ───────────────────────────────────────────────────────────
grpStyle  = "Style"
hiColor   = input.color(color.red,   "PM High Color", group = grpStyle)
loColor   = input.color(color.green, "PM Low Color",  group = grpStyle)
lineWidth = input.int  (2, "Line Width", minval = 1, maxval = 5, group = grpStyle)
showBG    = input.bool (true, "Tint Premarket Bars",  group = grpStyle)
showLbl   = input.bool (true, "Show Level Labels at Open", group = grpStyle)

// ─── Inputs: Alerts ──────────────────────────────────────────────────────────
grpAlert  = "Alerts"
useAlerts = input.bool(true, "Enable breakout alerts (regular hours only)", group = grpAlert)

// ─── Guard: intraday only ────────────────────────────────────────────────────
if not timeframe.isintraday
    runtime.error("Premarket High/Low requires an intraday timeframe (≤ 30 min recommended).")

// ─── Session membership (timezone-aware) ─────────────────────────────────────
inPremarket = not na(time(timeframe.period, pmSession, tz))
inRegular   = not na(time(timeframe.period, rgSession, tz))
isOpenBar   = inRegular and not inRegular[1]

// ─── Track premarket high / low ──────────────────────────────────────────────
var float pmHigh = na
var float pmLow  = na

enterPM = inPremarket and not inPremarket[1]
if enterPM
    pmHigh := high
    pmLow  := low
else if inPremarket
    pmHigh := math.max(pmHigh, high)
    pmLow  := math.min(pmLow,  low)

// ─── Live plot during premarket only (watch the range build) ─────────────────
livePmHi = inPremarket ? pmHigh : na
livePmLo = inPremarket ? pmLow  : na
plot(livePmHi, "PM High (live)", color = hiColor, linewidth = lineWidth, style = plot.style_linebr)
plot(livePmLo, "PM Low (live)",  color = loColor, linewidth = lineWidth, style = plot.style_linebr)

// ─── Projected horizontal lines: 09:00 → 16:00 each trading day ──────────────
var line hiLine = na
var line loLine = na

if isOpenBar and not na(pmHigh) and not na(pmLow)
    // Anchor the line from end-of-premarket (09:00) to regular close (16:00)
    // in the user-selected timezone so it works regardless of chart tz.
    y         = year      (time, tz)
    m         = month     (time, tz)
    d         = dayofmonth(time, tz)
    sessStart = timestamp(tz, y, m, d,  9, 0)
    sessEnd   = timestamp(tz, y, m, d, 16, 0)

    hiLine := line.new(sessStart, pmHigh, sessEnd, pmHigh,
         xloc  = xloc.bar_time,
         color = hiColor,
         width = lineWidth)
    loLine := line.new(sessStart, pmLow, sessEnd, pmLow,
         xloc  = xloc.bar_time,
         color = loColor,
         width = lineWidth)

// ─── Labels at regular-session open ──────────────────────────────────────────
if showLbl and isOpenBar and not na(pmHigh) and not na(pmLow)
    label.new(bar_index, pmHigh,
         " PM High: " + str.tostring(pmHigh, format.mintick) + " ",
         color     = hiColor,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.normal)
    label.new(bar_index, pmLow,
         " PM Low: "  + str.tostring(pmLow, format.mintick) + " ",
         color     = loColor,
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.normal)

// ─── Background tint during premarket ────────────────────────────────────────
bgcolor(showBG and inPremarket ? color.new(color.blue, 90) : na, title = "Premarket Zone")

// ─── Breakout alerts (regular session only) ──────────────────────────────────
breakUp = useAlerts and inRegular and not na(pmHigh) and ta.crossover (close, pmHigh)
breakDn = useAlerts and inRegular and not na(pmLow)  and ta.crossunder(close, pmLow)

alertcondition(breakUp, title = "Break above Premarket High",
     message = "{{ticker}} broke above PM High at {{close}}")
alertcondition(breakDn, title = "Break below Premarket Low",
     message = "{{ticker}} broke below PM Low at {{close}}")
````
