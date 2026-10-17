# Drawing Memory Test  Date Filter

- url: https://www.tradingview.com/script/qfpAg3EN-Drawing-Memory-Test-Date-Filter/
- type: indicator
- pine_id: PUB;2ae4e0b1747e42a39a2604606eeb128f
- version: 1.0

## Description

[b]🧠 The Complete Lesson: The Date Filter System for Managing Drawings in Pine Script[/b]
[i]From the core idea to applying it on any indicator: line by line, setting by setting[/i]

---

[b]📚 Table of Contents[/b]

[list]
[*] 1. The Problem: Why We Need This System
[*] 2. The Idea (The Discovery)
[*] 3. Pine Script Basics You Need to Read the Code
[*] 4. Indicator Structure: The indicator() Declaration and Object Limits
[*] 5. Every Input Explained
[*] 6. How Pivots Work Under the Hood
[*] 7. The Time Gate: Why time[rightBars]
[*] 8. Drawing Functions, Parameter by Parameter
[*] 9. The START Marker
[*] 10. The Code at a Glance
[*] 11. Historical Data Limits (Lookback)
[*] 12. How to Test the System
[*] 13. What It Solves and What It Doesn't
[*] 14. Applying the System to Any Indicator (With Examples)
[*] 15. Advanced Upgrades
[*] 16. Common Mistakes
[/list]

---

[b]1. The Problem: Why We Need This System[/b]

Every indicator that draws [b]boxes[/b], [b]lines[/b] and [b]labels[/b] on TradingView has a cap on how many objects it can keep: [b]500 per type[/b] (the default is 50 unless you raise it). Once the cap is reached, TradingView [b]automatically deletes the oldest object[/b] to make room for the new one.

What happens in practice:

[list]
[*] The indicator runs from the very first bar of the chart's history and draws in old areas you don't care about.
[*] The 500 slots get spent on the distant past. When signals are frequent, older objects get deleted, sometimes the very ones you wanted.
[*] The chart gets cluttered with lines and zones that serve no purpose.
[*] You can't tell the indicator "start from this day" or "only analyze this period".
[/list]

---

[b]2. The Idea (The Discovery)[/b]

We add a [b]date gate[/b] before every drawing operation. Any object that doesn't pass through the gate is never created at all.

[list]
[*] You choose a [b]start date[/b].
[*] Default behavior: the indicator draws from that date [b]forward[/b] only.
[*] With Show Previous enabled: it draws only what happened [b]before[/b] that date.
[/list]

[b]The practical benefit:[/b] all 500 object slots are spent on the period you care about, the chart stays clean, and you control exactly which period you're testing.

[i]An honest note: the system does not raise the 500 limit. It lets you spend that limit in the right place.[/i]

---

[b]3. Pine Script Basics You Need to Read the Code[/b]

If you're a beginner, these concepts unlock the code.

[b]a) The version line[/b]
[pine]
//@version=6
[/pine]
The first line of the script. It declares that the code is written in Pine Script version 6. Any line starting with // is a comment and is not executed.

[b]b) Core built-in variables (series)[/b]

[list]
[*] [b]time:[/b] the open time of the current bar, in milliseconds since 1970.
[*] [b]bar_index:[/b] the number of the current bar, starting at 0 on the first bar of the chart.
[*] [b]high / low:[/b] the highest and lowest price of the bar.
[/list]

[b]c) Looking back with square brackets[/b]
[pine]
time[1]   // time of the previous bar
time[5]   // time of the bar 5 bars ago
[/pine]

[b]d) The if statement[/b]
[pine]
if showBoxes
    box.new(...)
[/pine]
The indentation (4 spaces) matters: it defines what belongs inside the condition. If showBoxes is true, the indented line runs.

[b]e) The ternary operator ? :[/b]
[pine]
bool allowed = showPrevious ? pivotTime < startDate : pivotTime >= startDate
[/pine]
Syntax: [b]condition ? value_if_true : value_if_false[/b].
Here: if showPrevious is true, allowed = (pivotTime < startDate). Otherwise, allowed = (pivotTime >= startDate).

[b]f) The na value[/b]
[pine]
if not na(pivotHigh)
[/pine]
na means "no value". ta.pivothigh returns na on most bars and returns a number only when a pivot high is confirmed. So the condition reads: "if we detected a pivot high".

[b]g) Variable types[/b]
[list]
[*] [b]float:[/b] a decimal number (prices).
[*] [b]int:[/b] a whole number (times, counts).
[*] [b]bool:[/b] true or false.
[/list]

---

[b]4. Indicator Structure: The indicator() Declaration and Object Limits[/b]

[pine]
indicator("Drawing Memory Test • Date Filter", overlay=true,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500)
[/pine]

[list]
[*] [b]Title:[/b] the name shown on the chart.
[*] [b]overlay=true:[/b] draws on top of the main chart (not in a separate pane below it).
[*] [b]max_boxes_count=500:[/b] the maximum number of boxes the script keeps. The default is 50 and the upper limit is 500.
[*] [b]max_lines_count=500:[/b] the same for lines.
[*] [b]max_labels_count=500:[/b] the same for labels.
[/list]

[b]Important:[/b] if you don't raise these values, the limit stays at 50 and older objects are deleted quickly. Each type has its own independent limit, so the possible total is 1500 objects.

---

[b]5. Every Input Explained[/b]

Inputs are organized into groups (the group parameter) so they appear neatly in the settings window.

[b]📅 The Drawing Control group[/b]

[b]Drawing Start Date[/b]
[pine]
startDate = input.time(timestamp("01 Sep 2026 00:00 +0000"), "Drawing Start Date", group=groupDrawing)
[/pine]
[list]
[*] The input type is input.time: it gives you a date and time picker in the settings.
[*] The default is 1 September 2026 at 00:00 UTC (+0000).
[*] This is the foundation the gate is built on.
[*] Change it to the beginning of the period you're studying.
[/list]

[b]Show Previous Drawings[/b]
[list]
[*] [b]OFF (default):[/b] draws from the start date forward.
[*] [b]ON:[/b] draws only what came before the date.
[*] Useful for reviewing the past or comparing two periods (run once with OFF and once with ON).
[/list]

[b]Show Boxes / Show Lines / Show Labels[/b]
[list]
[*] Three switches that turn each drawing type on or off.
[*] If a type is off, no objects of that type are created, so none of its limit is consumed.
[*] Tip: if the chart gets crowded, keep only the lines and turn off the rest.
[/list]

[b]📍 The Pivot Detection group[/b]

[b]Pivot Left Bars (default 5)[/b]
[list]
[*] The number of bars on the [b]left[/b] of the point that must be lower (for a high) or higher (for a low).
[*] minval=1: you can't go below 1.
[/list]

[b]Pivot Right Bars (default 5)[/b]
[list]
[*] The number of bars on the [b]right[/b] of the point used for confirmation.
[*] Important: the pivot isn't confirmed until this many bars have passed, so the drawing appears [b]delayed[/b] by the Right value.
[/list]

[b]Tuning guide:[/b]
[list]
[*] 2-3: many sensitive points with plenty of noise, and they consume the limit fast.
[*] 5-8: a good balance for most timeframes.
[*] 10-15: fewer, stronger points, but confirmation is slower.
[/list]

---

[b]6. How Pivots Work Under the Hood[/b]

[pine]
float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
[/pine]

[b]A Pivot High:[/b] a bar whose high is higher than the highs of [b]leftBars[/b] bars before it, and higher than the highs of [b]rightBars[/b] bars after it.

[b]Example with Left = 2 and Right = 2[/b] (the high of each bar):

[list]
[*] Bars: 10, 12, [b]15[/b], 13, 11
[*] The bar with a high of 15 is higher than the two bars before it and the two bars after it, so it is a pivot high.
[*] But the function can't know that until the second bar after it appears (the last one, 11).
[/list]

[b]The key consequence:[/b]
[list]
[*] The function executes on the current bar (the last one, 11).
[*] But the pivot itself sits [b]rightBars[/b] bars back.
[*] The returned value is the pivot's price (15), and everything else is na.
[/list]

This is exactly why all the drawing code uses [b]bar_index[rightBars][/b] to locate the real position of the pivot.

[b]The Pivot Low[/b] follows the same logic, reversed:
[pine]
float pivotLow = ta.pivotlow(low, leftBars, rightBars)
[/pine]

[b]A note on repainting:[/b] once a pivot is confirmed, it doesn't change or disappear, because its confirmation conditions are complete. The delay is the price you pay for stability.

---

[b]7. The Time Gate: Why time[rightBars][/b]

[pine]
int pivotTime = time[rightBars]

bool allowed = showPrevious
     ? pivotTime < startDate
     : pivotTime >= startDate
[/pine]

If we filtered by [b]time[/b] (the current bar's time), we'd be judging the date of the [i]confirmation[/i], not the date of the pivot.

[b]Example:[/b] the start date is 1 September, the pivot formed on 31 August and was confirmed on 1 September.
[list]
[*] Filtering by time: the pivot is accepted (because the confirmation is after the start). That's wrong, since it belongs to August.
[*] Filtering by time[rightBars]: the pivot is rejected, which is correct.
[/list]

[b]The golden rule:[/b] ask "when was this object [i]born[/i]?" and filter by its real birth time.

---

[b]8. Drawing Functions, Parameter by Parameter[/b]

[b]📦 box.new[/b]
[pine]
box.new(
     left=bar_index[rightBars],
     top=pivotHigh,
     right=bar_index,
     bottom=pivotHigh - syminfo.mintick * 20,
     border_color=color.red,
     bgcolor=color.new(color.red, 85))
[/pine]
[list]
[*] [b]left:[/b] the left edge, at the real pivot bar.
[*] [b]right:[/b] the right edge, at the current bar (the confirmation bar). So the box is exactly Right bars wide and does not extend into the future.
[*] [b]top / bottom:[/b] the upper and lower edges. For a high: from the pivot price down 20 ticks.
[*] [b]syminfo.mintick:[/b] the smallest price movement of the symbol. We multiplied it by 20 so the box height scales to the symbol.
[*] [b]border_color:[/b] the outline color.
[*] [b]bgcolor:[/b] the fill color.
[/list]

[b]🎨 color.new(color.red, 85)[/b]
The second number is the [b]transparency[/b], from 0 to 100: 0 = fully solid, 100 = fully transparent. 85 gives a very light fill that doesn't cover the candles.

For a pivot low the box is mirrored: top = pivotLow + 20 ticks and bottom = pivotLow.

[b]📏 line.new[/b]
[pine]
line.new(
     x1=bar_index[rightBars],
     y1=pivotHigh,
     x2=bar_index,
     y2=pivotHigh,
     extend=extend.right,
     color=color.red,
     width=1)
[/pine]
[list]
[*] [b]x1, y1:[/b] the starting point (the pivot bar and its price).
[*] [b]x2, y2:[/b] the end point (the current bar at the same price, so the line is horizontal).
[*] [b]extend.right:[/b] extends the line to the right indefinitely, so it works as a support, resistance or liquidity level.
[*] [b]width:[/b] the line thickness.
[/list]

[b]🏷️ label.new[/b]
[pine]
label.new(
     x=bar_index[rightBars],
     y=pivotHigh,
     text="HIGH",
     style=label.style_label_down,
     textcolor=color.white,
     color=color.red)
[/pine]
[list]
[*] [b]x, y:[/b] the label position.
[*] [b]text:[/b] the displayed text.
[*] [b]style_label_down:[/b] a label with a downward pointer, so it sits above the high. For lows we use style_label_up, so the label sits below the low.
[*] [b]textcolor:[/b] the text color.
[*] [b]color:[/b] the label background color.
[/list]

---

[b]9. The START Marker[/b]

[pine]
bool isStartDate = time >= startDate and time[1] < startDate

plotshape(
     isStartDate,
     title="Start Date",
     style=shape.diamond,
     location=location.abovebar,
     color=color.yellow,
     size=size.small,
     text="START")
[/pine]

[list]
[*] The condition becomes true on the first bar that crosses the start date: it is after the date (time >= startDate) while the bar before it was earlier (time[1] < startDate).
[*] plotshape draws a yellow diamond above that bar with the text START.
[*] Its purpose is visual: to confirm the filter is anchored where you expect.
[/list]

---

[b]10. The Code at a Glance[/b]

The logical order:
[list]
[*] 1) Indicator declaration and object limits.
[*] 2) Inputs (date, switches, pivot values).
[*] 3) Detect pivot highs. If one exists: compute its birth time, pass it through the gate, then draw.
[*] 4) Do the same for pivot lows.
[*] 5) The START marker.
[/list]

[b]Note:[/b] the original code has a variable called canDraw that is defined but never used, because the real filter is allowed inside each pivot block. You can delete it with no effect. Also, pivotTime and allowed are declared twice (once for highs and once for lows), which is fine, because each sits inside its own separate if block.

---

[b]11. Historical Data Limits (Lookback)[/b]

TradingView loads a limited number of bars for each chart, and that number depends on your subscription plan and the timeframe.

[list]
[*] If you set a start date older than the first loaded bar, nothing will appear before that first bar.
[*] On small timeframes (1 minute, 5 minutes) the loaded bars cover only a few days, so an old date won't work.
[*] The fix: use a larger timeframe, move the start date closer to today, or scroll the chart left so more history loads.
[/list]

---

[b]12. How to Test the System[/b]

[list]
[*] 1) Add the indicator to a daily or 4-hour chart (long history).
[*] 2) Change Start Date to a date you can see on the chart and confirm the START diamond appears on the first bar of that date.
[*] 3) With OFF: confirm all drawings appear only after the diamond.
[*] 4) Enable Show Previous: confirm all drawings appear only before the diamond.
[*] 5) Try turning Boxes, Lines and Labels off one at a time.
[*] 6) Change Left and Right and watch how the number of points changes.
[*] 7) Try a Start Date in the future: nothing will appear, which is expected.
[/list]

---

[b]13. What It Solves and What It Doesn't[/b]

[b]✅ Solves:[/b]
[list]
[*] Spending the 500-object limit on old periods you don't care about.
[*] Chart clutter.
[*] Precisely defining a testing or review period.
[*] Comparing "before" and "after" a specific date.
[/list]

[b]⚠️ Does not solve:[/b]
[list]
[*] It does not raise the maximum (500 stays 500).
[*] It does not reduce the indicator's calculations, since they still run on every bar. The filter controls drawing only.
[/list]

---

[b]14. Applying the System to Any Indicator[/b]

[b]Step 1: Add the inputs and the function at the top of your indicator[/b]
[pine]
startDate = input.time(timestamp("01 Sep 2026 00:00 +0000"), "Drawing Start Date", group="Drawing Control")
showPrevious = input.bool(false, "Show Previous Drawings", group="Drawing Control")

inRange(int t) => showPrevious ? t < startDate : t >= startDate
[/pine]
The inRange function takes a time and returns true if that time is allowed.

[b]Step 2: Raise the object limits[/b]
[pine]
indicator("My Indicator", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)
[/pine]

[b]Step 3: Add the condition before every drawing, using the event's real time[/b]

[b]Example 1: Fair Value Gap (FVG)[/b]
[pine]
bullFVG = low > high[2]

if bullFVG and inRange(time[2])
    box.new(bar_index[2], low, bar_index, high[2],
         border_color=color.green, bgcolor=color.new(color.green, 85))
[/pine]
The gap starts two bars back, so we filter with time[2].

[b]Example 2: Break of Structure (BOS)[/b]
[pine]
if breakCondition and inRange(time[swingOffset])
    line.new(bar_index[swingOffset], swingLevel, bar_index, swingLevel, color=color.blue)
[/pine]
Here we filter by the time of the swing that was broken, not the time of the break.

[b]Example 3: Buy or sell signal[/b]
[pine]
if buySignal and inRange(time)
    label.new(bar_index, low, "BUY", style=label.style_label_up)
[/pine]
The signal belongs to the current bar, so we use time directly.

[b]Example 4: Order Block indicator[/b]
[pine]
if obDetected and inRange(time[obOffset])
    box.new(bar_index[obOffset], obHigh, bar_index, obLow, bgcolor=color.new(color.blue, 85))
[/pine]
We filter by the time of the Order Block candle itself.

[b]Step 4: Special cases[/b]
[list]
[*] If your indicator stores drawings in arrays, apply inRange when adding to the array, not when drawing later.
[*] If the indicator updates an existing object (such as extending a box), you don't need a filter on the update, because the object was never created if it failed the gate.
[*] If one drawing has several events (a start and an end), filter by the [b]start[/b] time.
[/list]

---

[b]15. Advanced Upgrades[/b]

[b]a) An end date (a fixed window)[/b]
[pine]
endDate = input.time(timestamp("30 Sep 2026 00:00 +0000"), "Drawing End Date", group="Drawing Control")

inRange(int t) => t >= startDate and t <= endDate
[/pine]
You select a period from one date to another.

[b]b) Last N days without a manual date[/b]
[pine]
daysBack = input.int(30, "Draw Last N Days", minval=1, group="Drawing Control")

inRange(int t) => t >= timenow - daysBack * 86400000
[/pine]
timenow is the current time, and 86400000 is the number of milliseconds in a day. This makes the window move automatically with time.

[b]c) A master switch for the whole filter[/b]
[pine]
useFilter = input.bool(true, "Use Date Filter", group="Drawing Control")

inRange(int t) => not useFilter or (showPrevious ? t < startDate : t >= startDate)
[/pine]
If you turn it off, the indicator draws everything as usual.

---

[b]16. Common Mistakes[/b]

[list]
[*] Filtering by time when it should be time[offset], so results appear late or incomplete.
[*] Forgetting to raise max_boxes_count, max_lines_count and max_labels_count.
[*] Setting the date after the last bar on the chart, so nothing shows.
[*] Setting a date older than the loaded data (see the Lookback section).
[*] Mixing up the Show Previous direction: OFF is from the date forward, ON is before the date.
[*] Using very small Pivot values, which fills the limit with weak points.
[*] Forgetting that a pivot is confirmed late by the Right value, and assuming the indicator is broken.
[*] Expecting the filter to speed up the indicator, when it only controls drawing.
[/list]

---

[b]📌 Summary[/b]

The Date Filter System is a simple and powerful idea: [b]a time gate before every drawing operation[/b]. The indicator only draws what serves the period you care about, so the 500-object slots are spent on what matters, the chart stays clean, and you can review the past or follow the present precisely. You can install it on almost any indicator with an inRange function and one condition before each drawing, always keeping the object's birth time in mind.

[i]Draw what matters, ignore the rest.[/i]

---

[b]⚠️ Disclaimer[/b]

This lesson is intended for educational and programming purposes only. Nothing in it constitutes financial advice or an invitation to buy or sell any asset. Risk management and capital preservation remain entirely the responsibility of the trader.

[i]Trade with a plan. Trade with discipline. 📈[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © pine_astro



//@version=6
// ═══════════════════════════════════════════════════════════════════════
//  DRAWING MEMORY TEST • DATE FILTER   (fully commented edition)
// ═══════════════════════════════════════════════════════════════════════
//
//  WHAT THIS SCRIPT DOES
//  ---------------------
//  It detects pivot highs and pivot lows and draws a box, a horizontal
//  line and a label for each one. The special part is the DATE GATE:
//  every pivot must pass a date check BEFORE anything is drawn.
//
//    Show Previous = OFF  ->  draw only pivots born ON/AFTER the start date
//    Show Previous = ON   ->  draw only pivots born BEFORE the start date
//
//  WHY IT MATTERS
//  --------------
//  TradingView keeps at most 500 boxes, 500 lines and 500 labels per
//  script. When the limit is reached, the OLDEST object is deleted.
//  The date gate stops the script from wasting those 500 slots on old
//  history you don't care about, so they are spent on your chosen period.
//
//  IMPORTANT HONESTY NOTE
//  ----------------------
//  The gate controls DRAWING only. It does not raise the 500 limit and
//  it does not reduce calculations (the script still runs on every bar).
//
//  HOW TO READ THE COMMENTS
//  ------------------------
//  "//" starts a comment. Comments are ignored by TradingView, so you can
//  delete any of them without changing how the script behaves.
// ═══════════════════════════════════════════════════════════════════════

// ───────────────────────────────────────────────────────────────────────
// indicator() declares this script as an indicator (not a strategy).
//
//   "Drawing Memory Test • Date Filter" : the name shown on the chart.
//   overlay=true                        : draw ON TOP of the price chart
//                                         (false = separate pane below).
//   max_boxes_count=500                 : keep up to 500 boxes (default 50,
//                                         500 is the maximum allowed).
//   max_lines_count=500                 : same idea for lines.
//   max_labels_count=500                : same idea for labels.
//
// Each object type has its OWN limit, so the total possible is 1500.
// If you forget these three parameters the limit stays at 50 and older
// drawings disappear very quickly.
// ───────────────────────────────────────────────────────────────────────
indicator("Drawing Memory Test  Date Filter", overlay=true,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING CONTROL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// A string used as a "group" name. Every input that uses this variable
// appears under the same heading in the settings window.
groupDrawing = "Drawing Control"

// ── Input 1: the start date ────────────────────────────────────────────
// input.time() creates a date/time picker in the settings window.
// The value is stored as a number: milliseconds since 1 Jan 1970 (UTC),
// the same unit as the built-in `time` variable, so the two can be
// compared directly with <, >=, etc.
//
// timestamp("01 Sep 2026 00:00 +0000") builds the default value:
// 1 September 2026, 00:00, UTC offset +0000.
//
// This date is the foundation of the whole gate. Set it to the beginning
// of the period you want to study.
startDate = input.time(
     timestamp("01 Sep 2026 00:00 +0000"),
     "Drawing Start Date",
     group=groupDrawing)

// ── Input 2: the direction switch ──────────────────────────────────────
// input.bool() creates a checkbox.
//   false (OFF, default) -> draw from startDate FORWARD
//   true  (ON)           -> draw BEFORE startDate only
// Useful for reviewing the past or comparing "before" vs "after".
showPrevious = input.bool(
     false,
     "Show Previous Drawings",
     group=groupDrawing)

// ── Inputs 3-5: per-type visibility switches ───────────────────────────
// Each switch turns one drawing type on or off. When a type is OFF, no
// objects of that type are created at all, so none of its 500-slot
// limit is consumed.
showBoxes = input.bool(
     true,
     "Show Boxes",
     group=groupDrawing)

showLines = input.bool(
     true,
     "Show Lines",
     group=groupDrawing)

showLabels = input.bool(
     true,
     "Show Labels",
     group=groupDrawing)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupPivot = "Pivot Detection"

// ── Input 6: Left Bars ─────────────────────────────────────────────────
// input.int() creates a whole-number field. minval=1 prevents values < 1.
// A pivot HIGH must be higher than this many bars on its LEFT side
// (a pivot LOW must be lower than this many bars on its left).
leftBars = input.int(
     5,
     "Pivot Left Bars",
     minval=1,
     group=groupPivot)

// ── Input 7: Right Bars ────────────────────────────────────────────────
// Same idea on the RIGHT side, and this is also the CONFIRMATION delay:
// a pivot is only confirmed after this many bars have closed after it.
// So the drawing appears `rightBars` bars late. That is normal.
//
// Tuning guide (for both Left and Right):
//   2-3   -> many sensitive points, lots of noise, eats the limit fast
//   5-8   -> balanced for most timeframes
//   10-15 -> fewer but stronger points, slower confirmation
rightBars = input.int(
     5,
     "Pivot Right Bars",
     minval=1,
     group=groupPivot)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAWING FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// OFF = draw from selected date forward
// ON  = draw before selected date

// NOTE: `canDraw` is declared but NEVER USED anywhere below. The real
// filtering happens through the `allowed` variable inside each pivot
// block (see further down). You can safely delete this variable.
//
// How the ternary operator works here:  condition ? value_if_true : value_if_false
//   showPrevious ON  -> canDraw = (current bar time < startDate)
//   showPrevious OFF -> canDraw = (current bar time >= startDate)
// It uses the CURRENT bar's time, which is exactly why it is not good
// enough for pivots (see the explanation in the PIVOT HIGH section).
bool canDraw = showPrevious
     ? time < startDate
     : time >= startDate

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT HIGH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ta.pivothigh(source, leftBars, rightBars)
//
// A bar is a pivot high when its `high` is higher than the highs of
// `leftBars` bars before it AND `rightBars` bars after it.
//
// The function runs on EVERY bar but returns:
//   - the pivot's PRICE on the bar where a pivot gets confirmed
//   - na ("no value") on all other bars
//
// KEY POINT: the confirmation bar is `rightBars` bars AFTER the real
// pivot bar. So when a value is returned, the real pivot candle is
// located at bar_index[rightBars], not at the current bar.
float pivotHigh = ta.pivothigh(high, leftBars, rightBars)

// na() checks whether a value is "no value". `not na(...)` therefore
// means "a pivot high was just confirmed on this bar".
if not na(pivotHigh)

    // ── THE TIME GATE ──────────────────────────────────────────────────
    // time[rightBars] is the time of the REAL pivot candle (its "birth
    // time"), not the time of the confirmation candle.
    //
    // Why this matters (example): start date = 1 Sep.
    //   The pivot formed on 31 Aug and was confirmed on 1 Sep.
    //   Filtering with `time`            -> accepted (WRONG, it is August)
    //   Filtering with `time[rightBars]` -> rejected (CORRECT)
    //
    // Golden rule: always filter by when the object was BORN.
    int pivotTime = time[rightBars]

    // The gate itself:
    //   Show Previous OFF -> allowed only if the pivot was born ON/AFTER startDate
    //   Show Previous ON  -> allowed only if the pivot was born BEFORE startDate
    bool allowed = showPrevious
         ? pivotTime < startDate
         : pivotTime >= startDate

    // Nothing below is executed unless the pivot passed the gate.
    // Objects that fail the gate are never created, so they use no slots.
    if allowed

        // ── BOX ────────────────────────────────────────────────────────
        // Parameters:
        //   left         : left edge = the real pivot candle
        //   top          : upper edge = the pivot's price
        //   right        : right edge = current bar (the confirmation bar),
        //                  so the box is `rightBars` bars wide and does
        //                  NOT extend into the future
        //   bottom       : lower edge = pivot price minus 20 ticks.
        //                  syminfo.mintick is the smallest price step of
        //                  the symbol, so the height scales with the symbol
        //   border_color : outline color (red = resistance side)
        //   bgcolor      : fill color. color.new(color, 85) sets the
        //                  TRANSPARENCY: 0 = solid, 100 = invisible,
        //                  85 = very light so candles stay visible
        if showBoxes
            box.new(
                 left=bar_index[rightBars],
                 top=pivotHigh,
                 right=bar_index,
                 bottom=pivotHigh - syminfo.mintick * 20,
                 border_color=color.red,
                 bgcolor=color.new(color.red, 85))

        // ── LINE ───────────────────────────────────────────────────────
        // Parameters:
        //   x1, y1 : start point (pivot candle, pivot price)
        //   x2, y2 : end point (current bar, SAME price -> horizontal line)
        //   extend : extend.right pushes the line to the right forever,
        //            so it works as a resistance / liquidity level
        //   color  : line color
        //   width  : thickness in pixels
        if showLines
            line.new(
                 x1=bar_index[rightBars],
                 y1=pivotHigh,
                 x2=bar_index,
                 y2=pivotHigh,
                 extend=extend.right,
                 color=color.red,
                 width=1)

        // ── LABEL ──────────────────────────────────────────────────────
        // Parameters:
        //   x, y      : position (pivot candle, pivot price)
        //   text      : the text to show
        //   style     : label.style_label_down = pointer faces DOWN, so
        //               the label sits ABOVE the high
        //   textcolor : text color
        //   color     : label background color
        if showLabels
            label.new(
                 x=bar_index[rightBars],
                 y=pivotHigh,
                 text="HIGH",
                 style=label.style_label_down,
                 textcolor=color.white,
                 color=color.red)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOT LOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Exact mirror of the pivot high section, using lows instead of highs.
// A pivot low is a bar whose `low` is lower than `leftBars` bars before
// it and `rightBars` bars after it. Returns the price on the confirmation
// bar and na on every other bar.
float pivotLow = ta.pivotlow(low, leftBars, rightBars)

if not na(pivotLow)

    // Birth time of the real pivot candle (same logic as the pivot high).
    // `pivotTime` and `allowed` are declared again here without any
    // conflict, because each one lives inside its own separate `if` block.
    int pivotTime = time[rightBars]

    // Same gate as above.
    bool allowed = showPrevious
         ? pivotTime < startDate
         : pivotTime >= startDate

    if allowed

        // ── BOX ────────────────────────────────────────────────────────
        // Mirrored: the box sits ABOVE the low.
        //   top    = pivot price + 20 ticks
        //   bottom = pivot price
        // Green = support side.
        if showBoxes
            box.new(
                 left=bar_index[rightBars],
                 top=pivotLow + syminfo.mintick * 20,
                 right=bar_index,
                 bottom=pivotLow,
                 border_color=color.green,
                 bgcolor=color.new(color.green, 85))

        // ── LINE ───────────────────────────────────────────────────────
        // Horizontal line at the low's price, extended to the right so
        // it works as a support / liquidity level.
        if showLines
            line.new(
                 x1=bar_index[rightBars],
                 y1=pivotLow,
                 x2=bar_index,
                 y2=pivotLow,
                 extend=extend.right,
                 color=color.green,
                 width=1)

        // ── LABEL ──────────────────────────────────────────────────────
        // label.style_label_up = pointer faces UP, so the label sits
        // BELOW the low.
        if showLabels
            label.new(
                 x=bar_index[rightBars],
                 y=pivotLow,
                 text="LOW",
                 style=label.style_label_up,
                 textcolor=color.white,
                 color=color.green)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// START DATE MARKER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Becomes TRUE only on the FIRST bar that crosses the start date:
//   time >= startDate  -> this bar is on/after the start date
//   time[1] < startDate -> the previous bar was still before it
// Both must be true, so it fires exactly once.
//
// Purpose: a visual check that the filter is anchored where you expect.
// If you can't see the diamond, your date is outside the loaded history
// (too old for the timeframe, or in the future).
bool isStartDate = time >= startDate and time[1] < startDate

// plotshape() draws a symbol on the bars where the condition is true.
//   isStartDate        : the condition (true on exactly one bar)
//   title              : name shown in the settings / data window
//   style=shape.diamond: diamond-shaped symbol
//   location           : location.abovebar places it above the candle
//   color              : yellow
//   size               : small
//   text               : the word printed next to the symbol
plotshape(
     isStartDate,
     title="Start Date",
     style=shape.diamond,
     location=location.abovebar,
     color=color.yellow,
     size=size.small,
     text="START")
````
