# DTC Initial Balance Pro

- url: https://www.tradingview.com/script/Y1e0FQeP-DTC-Initial-Balance-Pro/
- type: indicator
- pine_id: PUB;aa6a72a2c0fa4e649976a71e188ce97e
- version: 2.0

## Description

WHAT THIS DOES

Every trading session has an "Initial Balance" — the first chunk of time
after the open (default: the first hour, 09:30-10:30 New York) where the
market sets its early high and low. Traders have long believed that
WHICH ONE FORMS FIRST — the high or the low — hints at which way the
rest of the day tends to go.

The problem: on a normal chart, you can't actually tell which came
first just by looking at a candle. A single 15-minute or 1-hour candle
can have both a new high AND a new low in it, and the candle's color
tells you nothing about the order they happened in.

This indicator solves that by secretly rebuilding the entire session
minute-by-minute in the background (even if your chart is on 15m, 1H,
or Daily), so it can tell you EXACTLY which one happened first — based
on real timestamps, never a guess.

HOW TO READ IT

- A colored box appears over the session: green means the low formed
  first, red means the high formed first. Gray means it's still
  forming.
- A small label shows the result once the session ends.
- A table (top-right by default) shows the full breakdown: exact
  prices, exact times, and a "Bias" (Long/Short) reading.

THE PART THAT MAKES THIS DIFFERENT

Most tools stop at "which formed first." This one keeps going and
actually checks your chart's history to answer the follow-up question:
"okay, but does that actually mean anything?" It tracks, for every
past session, what price did AFTERWARD — did it break above the
session high, or below the session low — and shows you the real
percentages. So instead of trusting a rule of thumb, you can see
whether it's actually held up on the exact symbol and timeframe you
trade.

It also projects price targets above and below the session (simple
multiples of the session's range) and shows how often price has
historically reached each one.

FEATURES
- Works on any chart timeframe - internally always reconstructed from
  1-minute (or 5-minute, for older history) data
- Fully customizable session times, not locked to the NY open
- Adjustable colors, box/line styles, and label sizes
- A statistics table with three sections: current session detail,
  all-time stats, and post-session breakout odds
- Price target lines (+0.5x to +3.0x the session range) with their own
  historical hit-rate table
- Alerts for session completion and for each outcome
- No repainting - once a session ends, its result is permanently frozen

A NOTE ON HONESTY
This indicator will tell you "Simultaneous" instead of guessing when
the high and low happen too close together to tell apart (this is a
hard limit of how granular historical data can get, not a shortcut).
Older history beyond what 1-minute data allows automatically falls back
to 5-minute reconstruction, clearly labeled in the table so you always
know the precision you're looking at.

This is an analytical tool for understanding market structure, not financial advice. 
Historical statistics describe the past 
they are not a guarantee of future behavior.

## Source Code

````pine
//@version=6
// =============================================================================
// DTC INITIAL BALANCE PRO
// -----------------------------------------------------------------------------
// Determines whether the Initial Balance LOW or HIGH formed first using the
// chart's OWN bars directly (same approach as noop42's original "Initial
// Balance" indicator) - no lower-timeframe reconstruction.
//
// CORE RULE: the determination is made STRICTLY by comparing the timestamps
// of the final (post-replacement) IB high and IB low. Prices are never
// compared to decide order - only "which timestamp happened first".
//
// KNOWN LIMITATION (documented, not silently ignored):
//   Formation order is only as precise as the chart's own bar size - on a
//   15-minute chart, "which formed first" can only be resolved to within the
//   same 15-minute candle, not true minute-level order (see "Simultaneous"
//   handling below for ties within one bar). Use a lower chart timeframe
//   (e.g. 1-minute) for finer-grained formation-order precision. In exchange
//   for this tradeoff, the script has no dependency on
//   request.security_lower_tf() at all, so it is not subject to that
//   function's ~100,000-bar historical cap, and it works correctly during
//   TradingView's Bar Replay feature (which request.security_lower_tf() does
//   not support), on any chart timeframe.
// =============================================================================
indicator("DTC Initial Balance Pro", shorttitle = "DTC IB Pro", overlay = true, max_boxes_count = 50, max_lines_count = 500, max_labels_count = 500)

// =============================================================================
// INPUTS
// =============================================================================
grpSession  = "General"
sessionPreset = input.string("NY Open", "Session Preset", options = ["NY Open", "London Open", "Asian Open", "Custom"], group = grpSession, tooltip = "Quick presets for the 3 major futures sessions (NY 9:30 ET, London 3:00 ET, Asian 19:00 ET). Each builds the IB from the first 60 minutes of that session's open, in ET - every table and stat on the chart (Current Session, All-Time Stats, Breakout Odds, Day-of-Week, Extension Targets, IB VWAP) recomputes for whichever window you pick. Choose Custom to set your own Start/End/Timezone below - those fields are ignored unless Custom is selected.")
ibStartHour   = input.int(9,  "IB Start - Hour (Custom only)",   minval = 0, maxval = 23, group = grpSession, inline = "start", tooltip = "When the Initial Balance session begins, in the Timezone set below. Only used when Session Preset above is set to Custom.")
ibStartMinute = input.int(30, "Minute",            minval = 0, maxval = 59, group = grpSession, inline = "start")
ibEndHour     = input.int(10, "IB End - Hour (Custom only)",     minval = 0, maxval = 23, group = grpSession, inline = "end", tooltip = "When the Initial Balance session ends. Only used when Session Preset above is set to Custom.")
ibEndMinute   = input.int(30, "Minute",            minval = 0, maxval = 59, group = grpSession, inline = "end")
ibTimezoneIn  = input.string("America/New_York", "Timezone (Custom only)", group = grpSession, tooltip = "IANA timezone used to evaluate the IB session when Session Preset is Custom, e.g. America/New_York")

// NY/London/Asian are all defined in ET regardless of preset; only Custom uses
// the manual Start/End/Timezone inputs above.
presetStartH = sessionPreset == "NY Open" ? 9  : sessionPreset == "London Open" ? 3 : sessionPreset == "Asian Open" ? 19 : ibStartHour
presetStartM = sessionPreset == "NY Open" ? 30 : sessionPreset == "London Open" ? 0 : sessionPreset == "Asian Open" ? 0  : ibStartMinute
presetEndH   = sessionPreset == "NY Open" ? 10 : sessionPreset == "London Open" ? 4 : sessionPreset == "Asian Open" ? 20 : ibEndHour
presetEndM   = sessionPreset == "NY Open" ? 30 : sessionPreset == "London Open" ? 0 : sessionPreset == "Asian Open" ? 0  : ibEndMinute
ibTimezone   = sessionPreset == "Custom" ? ibTimezoneIn : "America/New_York"

// Build a Pine session string ("HHMM-HHMM") from the effective start/end above
ibSession = str.format("{0,number,00}{1,number,00}-{2,number,00}{3,number,00}", presetStartH, presetStartM, presetEndH, presetEndM)

grpDisplay  = "Chart Objects"
showBox       = input.bool(true,  "Show IB Box",            group = grpDisplay, tooltip = "The shaded rectangle spanning the Initial Balance session, from IB High down to IB Low. Gray while the session is still forming, then turns green (Low Formed First) or red (High Formed First) once it completes.")
showMidline   = input.bool(true,  "Show IB Midline (50%)",  group = grpDisplay, tooltip = "A dashed line at the exact midpoint between IB High and IB Low.")
showLabels    = input.bool(true,  "Show Result Label",      group = grpDisplay, tooltip = "The small text above the box showing 'LOW FORMED FIRST' / 'HIGH FORMED FIRST'. Full details (times, range, bias) are in the stats table instead of on the chart, to keep things uncluttered.")
showTimes     = input.bool(true,  "Show Formation Times in Table", group = grpDisplay, tooltip = "Adds the exact clock times the IB High/Low formed, and the gap between them, to the 'Current Session' section of the stats table.")
showExtension = input.bool(true,  "Extend High/Low Lines After IB Ends", group = grpDisplay, tooltip = "Keeps the IB High/Low lines drawn out to the right after the session ends, so you can see them as support/resistance for the rest of the day. (This is separate from the +/- Extension Levels below, which are price TARGETS beyond the IB - this setting is just about the IB's own high/low lines.)")
lineWidthIn   = input.int(1, "Line Width", minval = 1, maxval = 5, group = grpDisplay, tooltip = "Thickness of the IB box border, midline, and high/low lines.")
labelSizeIn   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpDisplay, tooltip = "Text size of the 'LOW/HIGH FORMED FIRST' label above the box.")
boxFillTransparency = input.int(75, "Box Fill Transparency", minval = 0, maxval = 95, group = grpDisplay, tooltip = "Higher = more see-through. Low transparency on a red fill can read as pink - raise this if you want a lighter tint, lower it for a more solid red/green.")

grpPastSessions = "Historical Objects"
showPastSessionBoxes = input.bool(true, "Historical IB Boxes", group = grpPastSessions, tooltip = "By default only the CURRENT session's box is ever drawn - the moment a new session starts, the previous box is deleted. Turn this on to keep a rolling history of past session boxes on the chart instead (e.g. the last 5 Asian sessions if Session Preset above is set to Asian Open), so you can visually compare recent sessions side by side.")
pastSessionCount     = input.int(5, "Number of Past Sessions to Show", minval = 1, maxval = 20, group = grpPastSessions, tooltip = "How many completed sessions (including the current one) stay on the chart before the oldest is deleted. 3-5 is typical for eyeballing a recent pattern without cluttering the chart.")
showHistoricalExtLevels = input.bool(false, "Historical Extension Levels", group = grpPastSessions, tooltip = "By default extension target lines/labels are deleted the moment a new session begins (same as the IB box). Turn this on to keep past sessions' extension levels on the chart too.")
showHistoricalLabels    = input.bool(false, "Historical Labels", group = grpPastSessions, tooltip = "By default the 'LOW/HIGH FORMED FIRST' result label is deleted the moment a new session begins. Turn this on (together with Historical IB Boxes above) to keep past sessions' result labels visible alongside their boxes.")

grpColor    = "Chart Objects"
colorLowFirst  = input.color(color.new(color.green, 0), "Low Formed First Color", group = grpColor, tooltip = "Color used for the box, lines, and label when the IB Low formed before the IB High (bullish/LONG bias).")
colorHighFirst = input.color(color.new(color.red, 0),   "High Formed First Color", group = grpColor, tooltip = "Color used for the box, lines, and label when the IB High formed before the IB Low (bearish/SHORT bias).")
colorNeutral   = input.color(color.new(color.gray, 40), "In-Progress / Undetermined Color", group = grpColor, tooltip = "Color used while the IB session is still forming (result not decided yet), and for the rare 'Simultaneous' case where High and Low both happened on the same 1-minute bar.")
colorMid       = input.color(color.new(color.orange, 40), "Midline Color", group = grpColor, tooltip = "Color of the dashed 50% midpoint line inside the IB box.")

// =============================================================================
// IB INTERNAL FIB LEVELS - horizontal lines INSIDE the IB box at fixed
// fractions of the IB Range, created/updated/deleted exactly like the existing
// 50% midline. The midline stays exactly where it is and is untouched by this
// group: it IS the 0.5 level, and is still controlled by "Show IB Midline
// (50%)" in Chart Objects above.
//
// Every fraction is measured UP from the IB Low, so 25% sits a quarter of the
// way up the box and 78.6% sits near the top. Levels are toggled in mirrored
// pairs so the set reads the same in either direction - a 38.2% retracement
// measured DOWN from the IB High is the same line as 61.8% measured up from
// the IB Low, which is why the 0.786 you asked for is paired with 0.214.
// =============================================================================
grpInternal = "IB Internal Levels"
showInternalLevels = input.bool(false, "Show Internal Fib Levels", group = grpInternal, tooltip = "Master switch for the fib levels drawn inside the IB box. These are fractions of the completed IB Range measured up from the IB Low - unlike the Extensions group further down, which projects targets OUTSIDE the box. The 50% level is not listed here because it already exists as the IB Midline (Chart Objects group above); leave that on to complete the set. Levels are drawn from the moment the IB has a high and low, so they're visible while the session is still forming and settle once it freezes.")
showInt214_786 = input.bool(true, "21.4% / 78.6%", group = grpInternal, inline = "int1", tooltip = "Toggled in mirrored pairs, since a retracement measured down from the IB High is the same line as its complement measured up from the IB Low: 21.4% up from the Low IS 78.6% down from the High. Enabling a pair gives you both lines, so the set works whichever boundary you're measuring from.")
showInt382_618 = input.bool(true, "38.2% / 61.8%", group = grpInternal, inline = "int1")
colorInternal   = input.color(color.new(color.teal, 35), "Level Color", group = grpInternal, inline = "int2")
internalWidthIn = input.int(1, "Width", minval = 1, maxval = 5, group = grpInternal, inline = "int2")
internalStyleIn = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], group = grpInternal, inline = "int2", tooltip = "Dotted by default so the internal levels stay visually subordinate to the IB High/Low and the midline - with up to 6 extra lines inside the box, solid lines at full width read as clutter.")

grpStats    = "Dashboard"
showStatsTable = input.bool(true, "Show Dashboard", group = grpStats, tooltip = "Master switch for the whole dashboard panel. Turn off entirely if you only want the chart drawings.")
dashboardMode  = input.string("Compact", "Dashboard Mode", options = ["Compact", "Advanced"], group = grpStats, tooltip = "Compact: a tiny 4-5 row panel - Bias, Breakout Probability, Primary Target, Target Hit %, and Confidence. Nothing else. Advanced: the full modular dashboard below, with each section independently switchable.")
statsTablePos  = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = grpStats)
statsTableSizeIn = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpStats, tooltip = "Tiny keeps the table compact so it doesn't take over the chart.")
showCurrentSessionSection  = input.bool(true,  "Section: Current Session", group = grpStats, tooltip = "Advanced Mode only. Shows today's (or the most recent) IB: date, result, High/Low/Mid, range, formation times, directional bias, and live break type.")
showAllTimeStatsSection    = input.bool(false, "Section: Historical Statistics", group = grpStats, tooltip = "Advanced Mode only. Shows aggregated stats across every completed IB session your chart has loaded: how often Low vs High formed first, etc.")
showBreakoutOddsSection    = input.bool(false, "Section: Breakout Odds", group = grpStats, tooltip = "Advanced Mode only. Shows what price ACTUALLY did after each IB completed - e.g. of the sessions where the Low formed first, what % later broke above the IB High vs below the IB Low - plus the Single/Double/No-Break split. Real backtested stats from your chart's history, not a rule of thumb.")
showBiasTargetSection      = input.bool(false, "Section: Bias Follow-Through to 0.5", group = grpStats, tooltip = "Advanced Mode only. Takes the Breakout Odds section one step further: not just WHICH side broke, but whether that break went anywhere. For each of the four formation-order/break-side combinations it shows how often price then reached the 0.5 extension in the direction it broke (+0.5 above IB High for an upside break, -0.5 below IB Low for a downside one). So 'Low First -> Broke High -> +0.5' reads as: of the sessions where the Low formed first AND price broke the High, this many went on to hit +0.5. The denominator is that break combination alone, NOT all sessions - a row showing 40% means 40% of THOSE sessions followed through, not 40% of the whole sample. Sessions where both boundaries broke in the same bar are excluded (direction can't be determined). Rows with a thin sample (denominator under 50) are marked with * - treat those percentages as low-confidence.")
showExpectancySection      = input.bool(false, "Section: Expectancy (Stop @ IB Mid)", group = grpStats, tooltip = "Advanced Mode only. A hit-rate percentage alone doesn't tell you if a setup is profitable - this runs one fixed simulated trade per break (same idea as the removed Entry Style Lab, but slimmed to just this one setup): enter at the broken IB boundary, stop at the IB Mid, target the 0.5 extension in the breakout direction. Reports Win/Loss/Open counts and Expectancy in R (average R per resolved trade - a loss is always -1R by construction, since the IB Mid IS this trade's risk unit). If a single bar's range spans both stop and target, the stop is assumed hit first (this script's standing 'never guess in the trade's favor' rule). One row per formation-order/break-side combination, same four buckets as the Bias Follow-Through section above - a positive Exp(R) means that combination would have been profitable trading this exact fixed setup, historically.")
showExtensionTargetsSection = input.bool(false, "Section: Extension Targets", group = grpStats, tooltip = "Advanced Mode only. Historical hit-rate and live distance for each IB extension level - Compact or Expanded per the Extension Panel Mode setting in the Extensions group.")
showDayStatsSection         = input.bool(false, "Section: Day Statistics", group = grpStats, tooltip = "Advanced Mode only. By default shows just TODAY's weekday (historical bias, High-First %, Follow-Through %). Enable 'Show Full Week Table' below for the complete Monday-Friday breakdown instead, shown as its own separate table.")

grpBiasLabel = "Bias Label"
showBiasLabel = input.bool(true, "Show Top-Center Bias Label", group = grpBiasLabel, tooltip = "A single always-visible label fixed to the top-center of the chart showing this session's Bias (LONG/SHORT), sourced directly from the RESULT section's timestamp-only formation-order rule - the same Bias shown in the dashboard, just surfaced somewhere easy to see at a glance. Not a recommendation.")
biasLabelSizeIn = input.string("Normal", "Bias Label Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpBiasLabel)

// =============================================================================
// IB EXTENSION LEVELS (Edgeful-style) - simple multiples of the completed IB
// Range, plotted only once the Initial Balance has finalized. This is purely
// additive to the existing IB detection logic above and does not touch it.
// =============================================================================
grpExt = "Extensions"
showExtensions    = input.bool(true, "Show Extensions", group = grpExt, tooltip = "Master switch for the extension-level lines. These are simple price targets computed as multiples of the completed IB Range (e.g. +1.0 = IB High + 1x the range) - NOT Fibonacci levels, and they only appear once the IB session has finished. Turn this off to hide all extension lines regardless of the other settings below.")
showPosExtensions = input.bool(true, "Show Positive Extensions", group = grpExt, tooltip = "Show the upside targets (+0.5, +1.0, etc.), projected above IB High.")
showNegExtensions = input.bool(true, "Show Negative Extensions", group = grpExt, tooltip = "Show the downside targets (-0.5, -1.0, etc.), projected below IB Low.")
showExtLabels     = input.bool(true, "Show Labels", group = grpExt, tooltip = "Show the small +0.5/+1.0/etc. price tags next to each extension line.")
showExtPrices     = input.bool(true, "Show Extension Prices", group = grpExt, tooltip = "Include the actual price value alongside the level name in each label, e.g. '+0.5  7567.0' instead of just '+0.5'.")
extLineWidthIn    = input.int(2, "Extension Line Width", minval = 1, maxval = 5, group = grpExt, tooltip = "Thickness of the extension level lines.")
extLineStyleIn    = input.string("Solid", "Extension Line Style", options = ["Solid", "Dashed", "Dotted"], group = grpExt)
extLabelSizeIn    = input.string("Small", "Extension Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpExt)
extLabelOffsetMinutes = input.int(0, "Extension Label Offset (minutes)", minval = 0, maxval = 720, group = grpExt, tooltip = "Shifts the +/- level labels this many minutes further right than the end of the extension line. A fixed real-world duration (like the line length above), not a bar count, so it stays sensible on any chart timeframe.")
extLineLengthMinutes = input.int(120, "Extension Line Length (minutes past IB end)", minval = 15, maxval = 1440, group = grpExt, tooltip = "Lines run from the start of the IB box, through it, and this many MINUTES past the end of the IB - then stop. This is a fixed real-world duration, not a bar count, so the lines stay a sensible length whether you're on a 1m or a Daily chart - on a 1m chart 'bars' and minutes are the same thing, but on a 1H or Daily chart a bar-count length would stretch the lines for days or weeks and run straight through the on-screen tables.")
extPanelMode      = input.string("Compact", "Extension Panel Mode", options = ["Compact", "Expanded"], group = grpExt, tooltip = "Compact: the dashboard's Extension Targets section shows only the single nearest level in today's bias direction (e.g. Target -0.5, Hit % 68%). Expanded: shows every toggled level with Hit % and live Dist %, like the original full table.")

// Per-level toggles - by default only the innermost levels are shown to keep
// the chart clean; the outer levels are opt-in
grpExtLevels = "Extensions"
showLvl0_5 = input.bool(true,  "Show ±0.5 Level", group = grpExtLevels, inline = "lvl1", tooltip = "Each level is a multiple of the IB Range added to IB High (upside) or subtracted from IB Low (downside). E.g. if the IB Range is 50 points, +0.5 = IB High + 25, and -0.5 = IB Low - 25. Only the innermost levels (±0.5, ±1.0) are on by default to keep the chart clean - turn on the others if you want to see further targets.")
showLvl1_0 = input.bool(true,  "Show ±1.0 Level", group = grpExtLevels, inline = "lvl1")
showLvl1_5 = input.bool(false, "Show ±1.5 Level", group = grpExtLevels, inline = "lvl2")
showLvl2_0 = input.bool(false, "Show ±2.0 Level", group = grpExtLevels, inline = "lvl2")
showLvl2_5 = input.bool(false, "Show ±2.5 Level", group = grpExtLevels, inline = "lvl3")
showLvl3_0 = input.bool(false, "Show ±3.0 Level", group = grpExtLevels, inline = "lvl3")

grpExtColor = "Extensions"
colorPosExt = input.color(color.new(color.blue, 0),  "Positive Extension Color", group = grpExtColor, tooltip = "Color for the upside (+) extension lines and labels.")
colorNegExt = input.color(color.new(color.red, 0),   "Negative Extension Color", group = grpExtColor, tooltip = "Color for the downside (-) extension lines and labels.")
// Midline color = colorMid (Colors group above). IB Box color already tracks the
// Low/High Formed First result colors from the Colors group above by design -
// that existing behaviour is left untouched per the "don't modify existing
// calculations" requirement.

// Extension Targets no longer has its own table/position/size - in Advanced
// Dashboard Mode it's rendered as a section inside the one unified dashboard
// (see "Section: Extension Targets" toggle in the Dashboard group above),
// Compact or Expanded per Extension Panel Mode above.

grpDow = "Dashboard"
showDowTable = input.bool(false, "Show Full Week Table (instead of Today Only)", group = grpDow, tooltip = "The dashboard's Day Statistics section defaults to just TODAY's weekday (historical bias, High-First %, Follow-Through %). Turn this on for the full Monday-Friday breakdown instead, shown as its own separate table since it needs a wider grid layout. Off by default: with only a handful of sessions per weekday, these numbers need a lot of history to become meaningful.")
dowTablePos     = input.string("Bottom Left", "Full Week Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = grpDow)
dowTableSizeIn  = input.string("Tiny", "Full Week Table Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpDow)

// =============================================================================
// NEW DAY DIVIDER + WEEKDAY LABELS - ported in as-is from a standalone script,
// self-contained (no shared state with the IB logic above/below).
// =============================================================================
grpDayDivider = "Chart Objects"
dayDividerTimezone = input.string("America/New_York", "Timezone", options = ["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Anchorage", "America/Phoenix", "America/Indiana/Indianapolis", "UTC", "UTC-12", "UTC-11", "UTC-10", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3", "UTC-2", "UTC-1", "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+6", "UTC+7", "UTC+8", "UTC+9", "UTC+10", "UTC+11", "UTC+12"], group = grpDayDivider)
dayStartOption = input.string("Use Midnight", "New Day Start Time", options = ["Use Midnight", "Use Digital Open"], group = grpDayDivider, tooltip = "Use Digital Open draws the divider at 18:00 New York time (the CME futures 'new day' rollover), regardless of the Timezone selected above.")
dividerColor = input.color(color.new(color.red, 60), "Divider Color", group = grpDayDivider, tooltip = "Drawn with bgcolor() (a full-height background highlight on the divider bar) rather than a line with manually computed top/bottom coordinates - that guarantees it can never distort the chart's price scale, which a fixed or computed-range line can under some instruments/timeframes. Use the color's built-in transparency to control how strong the highlight looks.")

grpWeekdayLabels = "Chart Objects"
showDOW = input.bool(true, "Show Days of Week", group = grpWeekdayLabels)
dowLabelColor = input.color(color.red, "Day of Week Color", inline = "dow_color_settings", group = grpWeekdayLabels)
dowMonColor   = input.color(color.red, "Monday Label Color", inline = "dow_color_settings", group = grpWeekdayLabels)
dowLabelPosIn = input.string("Top", "Weekday Labels", options = ["Top", "Bottom"], inline = "dow_position_settings", group = grpWeekdayLabels)
dowLabelOffset = input.int(10, "Day Label Offset", inline = "dow_position_settings", group = grpWeekdayLabels)
dowLabelLoc = dowLabelPosIn == "Bottom" ? location.bottom : location.top

// =============================================================================
// TRADE PLANNER - a separate optional panel that summarizes today's stats.
// Generates NO trade recommendations and NO buy/sell arrows - statistics only.
// =============================================================================
grpTradePlanner = "Trade Planner"
showTradePlanner  = input.bool(false, "Show Trade Planner", group = grpTradePlanner, tooltip = "A separate small panel summarizing today's bias, breakout probability, and the two nearest extension targets with their historical hit probabilities. Pure statistics - no recommendations, no buy/sell signals.")
tradePlannerPos    = input.string("Bottom Right", "Trade Planner Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = grpTradePlanner)
tradePlannerSizeIn = input.string("Tiny", "Trade Planner Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpTradePlanner)

// =============================================================================
// RETRACEMENT DEPTH - a single statistics section, no simulated trades.
// =============================================================================
grpRetrace = "Retracement Depth"
showRetracementSection = input.bool(false, "Section: Retracement Depth (Pre-Break)", group = grpRetrace, tooltip = "Advanced Dashboard Mode only. Adds a section showing, across every session that broke out, the historical distribution of how deep price wandered back into the IB range BEFORE it broke - i.e. the window between the IB closing and the first break of the IB High/Low, bucketed by the deepest standard Fibonacci ratio reached (measured from the boundary that eventually broke, back toward the opposite IB boundary). Answers \'how far back into the range does price usually come before it finally goes\', which is what you\'d want if you\'re placing an entry inside the IB ahead of the break instead of at the boundary. The breakout bar\'s own wick is excluded, and sessions that never broke are excluded (no pre-break window to close). Note depth here is always under 1.0 by construction: reaching the opposite boundary IS a break, which would have ended the window first.")

// =============================================================================
// FORMATION TIMING - buckets sessions by actual MINUTES into the IB window,
// not a fixed fraction of it, so the cutoffs mean the same thing regardless
// of IB length and can be tuned directly (e.g. "did this decide in the last
// 15 minutes" is a concrete, checkable question; "did this decide in the
// final third" isn't, if you don't already know the IB is 60 minutes).
// =============================================================================
grpTiming = "Formation Timing"
showTimingSection = input.bool(false, "Section: Formation Timing", group = grpTiming, tooltip = "Advanced Mode only. Breakout Odds treats every 'Low/High Formed First' session the same, regardless of WHEN the deciding (later-forming) extreme actually formed within the IB window. This section splits that apart: for each formation side, buckets sessions by minutes-into-the-IB the deciding extreme formed - Early (before the Early Cutoff below), Mid (between the two cutoffs), Late (after the Late Cutoff) - and shows the same breakout-confirmation rate per bucket. If Late sessions confirm more (or less) often than Early ones, that's real evidence from your own chart's history, not folklore. Sessions where High and Low formed simultaneously are excluded (no 'later' extreme to time).")
timingEarlyCutoffMin = input.int(20, "Early Cutoff (minutes into IB)", minval = 1, group = grpTiming, tooltip = "Sessions where the deciding extreme formed BEFORE this many minutes into the IB window fall in the Early bucket. Defaults (20 / 40) split a standard 60-minute IB into thirds, but these are independent of IB length - set them to whatever actual time window you want to test, e.g. 15 for 'formed in the first quarter-hour'.")
timingLateCutoffMin  = input.int(40, "Late Cutoff (minutes into IB)", minval = 1, group = grpTiming, tooltip = "Sessions where the deciding extreme formed AT OR AFTER this many minutes into the IB window fall in the Late bucket (everything between the two cutoffs is Mid). Must be greater than the Early Cutoff. If this exceeds your configured IB length, the Late bucket will always be empty - no session can decide later than the IB itself runs.")

// =============================================================================
// HELPERS
// =============================================================================
f_labelSize(sizeStr) =>
    switch sizeStr
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_tablePos(posStr) =>
    switch posStr
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_lineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

// Pine tables have no real bold - bumping headers one size step above the data
// rows is the only way to give them visual weight/emphasis
f_bumpSizeStr(s) =>
    switch s
        "Tiny"   => "Small"
        "Small"  => "Normal"
        "Normal" => "Large"
        "Large"  => "Huge"
        "Huge"   => "Huge"
        => "Normal"

labelSizeVal      = f_labelSize(labelSizeIn)
tablePosVal       = f_tablePos(statsTablePos)
extLabelSizeVal   = f_labelSize(extLabelSizeIn)
extLineStyleVal   = f_lineStyle(extLineStyleIn)
internalStyleVal  = f_lineStyle(internalStyleIn)
statsTableSizeVal      = f_labelSize(statsTableSizeIn)
statsTableHeaderSizeVal      = f_labelSize(f_bumpSizeStr(statsTableSizeIn))
dowTablePosVal          = f_tablePos(dowTablePos)
dowTableSizeVal         = f_labelSize(dowTableSizeIn)
dowTableHeaderSizeVal   = f_labelSize(f_bumpSizeStr(dowTableSizeIn))
tradePlannerPosVal      = f_tablePos(tradePlannerPos)
tradePlannerSizeVal     = f_labelSize(tradePlannerSizeIn)
tradePlannerHeaderSizeVal = f_labelSize(f_bumpSizeStr(tradePlannerSizeIn))
biasLabelSizeVal = f_labelSize(biasLabelSizeIn)

// dayofweek() returns 1 (Sunday) .. 7 (Saturday) - index into the 7-slot
// day-of-week arrays as (dayofweek(...) - 1), giving 0=Sunday..6=Saturday
f_dayName(idx) =>
    switch idx
        0 => "Sun"
        1 => "Mon"
        2 => "Tue"
        3 => "Wed"
        4 => "Thu"
        5 => "Fri"
        6 => "Sat"
        => "?"

// index k into extMultipliers/extLevelNames (0=0.5, 1=1.0, ... 5=3.0) -> is that level toggled on
f_levelEnabled(k) =>
    switch k
        0 => showLvl0_5
        1 => showLvl1_0
        2 => showLvl1_5
        3 => showLvl2_0
        4 => showLvl2_5
        5 => showLvl3_0
        => false

// IB internal fib levels - fractions of the IB Range measured UP from the IB
// Low, and which pair toggle governs each. Kept as a single ordered list so
// the create/update/delete passes below always walk them in the same order
// (the update pass relies on that to match line objects to fractions).
var array<float> internalFracs = array.from(0.214, 0.382, 0.618, 0.786)
f_internalEnabled(k) =>
    switch k
        0 => showInt214_786
        1 => showInt382_618
        2 => showInt382_618
        3 => showInt214_786
        => false

// IMPORTANT: the timeframe argument here MUST be timeframe.period (the
// chart's own resolution) - passing any other resolution string makes
// time() behave like an implicit intraday data request under the hood
// (the same class of limitation as request.security_lower_tf(): unreliable
// in Bar Replay, and not guaranteed the same historical depth as the chart's
// own native bars).
f_inSession() => not na(time(timeframe.period, ibSession, ibTimezone))

// =============================================================================
// PERSISTENT IB STATE (never repaints once frozen)
// =============================================================================
var float ibHigh        = na
var float ibLow         = na
var int   ibHighTime    = na
var int   ibLowTime     = na
var int   ibSessionStartTime = na
var int   ibLastBarTime = na
var int   ibLastBarResMs = 60000  // resolution (ms) of the chart's own timeframe, set from timeframe.in_seconds() at the last in-session bar
var bool  ibActive      = false
var bool  ibFinalized   = false   // true only on the exact bar the IB just closed (one-shot for alerts/labels)
var bool  ibHasSession   = false  // true once at least one session has fully formed

// Visual object handles - recreated per session
var box   ibBoxObj      = na
var line  ibHighLineObj = na
var line  ibLowLineObj  = na
var line  ibMidLineObj  = na
var label ibLabelObj    = na

// Past Session Boxes history - when showPastSessionBoxes is on, the previous
// session's finalized box/lines/label are pushed here instead of deleted, and
// trimmed back to pastSessionCount (oldest deleted first) every new session.
var array<box>   pastBoxArr   = array.new_box()
var array<line>  pastHighArr  = array.new_line()
var array<line>  pastLowArr   = array.new_line()
var array<line>  pastMidArr   = array.new_line()
var array<label> pastLabelArr = array.new_label()

// IB internal fib level lines. Unlike the box/high/low/mid/label handles above
// there are N of them per session (N = however many pair toggles are on), so
// history is kept as a FLAT line array plus a parallel per-session count -
// the trim loop shifts a count, then deletes exactly that many lines off the
// front, keeping the flat array in lockstep with the other 5 history arrays.
var array<line> ibInternalLines  = array.new_line()  // current session only
var array<line> pastInternalArr  = array.new_line()  // flattened history, oldest session first
var array<int>  pastInternalCnt  = array.new_int()   // lines contributed by each historical session

// Statistics accumulators
var int   statSessions          = 0
var int   statLowFirstCount     = 0
var int   statHighFirstCount    = 0
var int   statSimultaneousCount = 0
var float statRangeSum          = 0.0
var float statGapSumMin         = 0.0   // sum of minutes between the low and high forming (reversal speed)

// -----------------------------------------------------------------------------
// POST-IB BREAKOUT TRACKING - which side actually got broken first after the
// Initial Balance froze, correlated against which extreme formed first. This
// turns "low/high formed first" into a real directional-bias statistic
// instead of a rule of thumb.
// -----------------------------------------------------------------------------
var bool sessionLowFirst   = false  // snapshot of this session's result, held until the next reset
var bool sessionHighFirst  = false
var bool breakDetected     = false  // true once IB High or IB Low has been broken post-IB (stops the FIRST-break stats above from re-firing)
var int  statLowFirst_BrokeHigh  = 0  // Low formed first, price later broke ABOVE IB High (bias confirmed)
var int  statLowFirst_BrokeLow   = 0  // Low formed first, price later broke BELOW IB Low  (bias failed)
var int  statHighFirst_BrokeHigh = 0  // High formed first, price later broke ABOVE IB High (bias failed)
var int  statHighFirst_BrokeLow  = 0  // High formed first, price later broke BELOW IB Low  (bias confirmed)
var int  statAmbiguousBreak      = 0  // both sides breached within the same 1-minute bar (can't order)

// -----------------------------------------------------------------------------
// FORMATION TIMING - does WHEN the deciding (later-forming) extreme set within
// the IB window matter, or is a last-minute flip just as meaningful as an
// early one? sessionTimingBucket is computed once at finalize: the fraction of
// the IB window elapsed when the LATER extreme formed, bucketed into thirds
// (0=Early <33%, 1=Mid 33-66%, 2=Late >66%). na for the rare Simultaneous
// case (no "later" extreme to time). Held until the next reset, same pattern
// as sessionLowFirst/sessionHighFirst above.
// -----------------------------------------------------------------------------
var int sessionTimingBucket = na
var float sessionTimingMinutes = na  // how many minutes into the IB window the deciding extreme formed, for the Current Session dashboard row - same value sessionTimingBucket was computed from
var array<int> timingLowSessions   = array.new_int(3, 0)  // Low-first sessions, by bucket
var array<int> timingLowBrokeHigh  = array.new_int(3, 0)  // ...that later broke ABOVE IB High (confirmed)
var array<int> timingLowBrokeLow   = array.new_int(3, 0)  // ...that later broke BELOW IB Low  (failed)
var array<int> timingHighSessions  = array.new_int(3, 0)  // High-first sessions, by bucket
var array<int> timingHighBrokeHigh = array.new_int(3, 0)  // ...that later broke ABOVE IB High (failed)
var array<int> timingHighBrokeLow  = array.new_int(3, 0)  // ...that later broke BELOW IB Low  (confirmed)

// -----------------------------------------------------------------------------
// FOLLOW-THROUGH TO THE 0.5 EXTENSION - the four counters above answer "which
// side broke", but not whether the break actually went anywhere. These add the
// next step: of the sessions in each formation-order/break-side combination,
// how many later reached the 0.5 extension in the direction they broke
// (+0.5 above IB High for an upside break, -0.5 below IB Low for a downside
// one). Each counter is a strict SUBSET of its matching counter above, so its
// percentage is read against that counter as the denominator - e.g.
// statLF_BH_Hit / statLowFirst_BrokeHigh = "when Low formed first AND price
// broke the High, how often did it then reach +0.5".
//
// breakComboIdx records which of the four buckets the CURRENT session landed
// in, set once at the break; ambiguous breaks (both boundaries in one bar)
// leave it na and are excluded, matching how they're handled everywhere else.
// -----------------------------------------------------------------------------
var int  breakComboIdx = na  // 0=LowFirst/BrokeHigh, 1=LowFirst/BrokeLow, 2=HighFirst/BrokeHigh, 3=HighFirst/BrokeLow
var int  statLF_BH_Hit = 0   // Low first, broke High, later reached +0.5 (bias confirmed AND followed through)
var int  statLF_BL_Hit = 0   // Low first, broke Low,  later reached -0.5 (bias failed, but the failure ran)
var int  statHF_BH_Hit = 0   // High first, broke High, later reached +0.5 (bias failed, but the failure ran)
var int  statHF_BL_Hit = 0   // High first, broke Low,  later reached -0.5 (bias confirmed AND followed through)

// -----------------------------------------------------------------------------
// EXPECTANCY (STOP @ IB MID) - one fixed simulated trade per session that
// broke: entry at the broken boundary, stop at the IB Mid, target the 0.5
// extension in the breakout direction. Only ONE combo can be active per
// session (whichever one the first break landed in, same breakComboIdx as
// above), so these are scalars for the live trade, plus one set of aggregate
// counters per combo (indices match breakComboIdx: 0/1/2/3).
// -----------------------------------------------------------------------------
var bool  cmbEntered     = false
var bool  cmbResolved    = false
var bool  cmbIsLong      = false
var float cmbEntryPrice  = na
var float cmbStopPrice   = na   // IB Mid, frozen at the moment of entry
var float cmbTargetPrice = na
var array<int>   statComboWins   = array.new_int(4, 0)
var array<int>   statComboLosses = array.new_int(4, 0)
var array<int>   statComboOpen   = array.new_int(4, 0)   // entered but session ended before stop or target - neither a win nor a loss
var array<float> statComboSumR   = array.new_float(4, 0.0)

// -----------------------------------------------------------------------------
// SINGLE/DOUBLE/NO-BREAK TRACKING - independent of breakDetected above (which
// only cares about the FIRST side broken). These two flags keep getting
// checked for the entire post-IB period regardless of what already broke, so
// a session where price breaks the High first and LATER also breaks the Low
// (or vice versa) is correctly counted as a "Double Break" instead of being
// silently lumped in with single-break sessions - the exact 74.6%/23.02%/2.38%
// single/double/no-break split from Edgeful's IBB stats.
// -----------------------------------------------------------------------------
var bool postBrokeHigh   = false  // IB High has been broken at any point post-IB this session
var bool postBrokeLow    = false  // IB Low has been broken at any point post-IB this session
var int  statSingleBreak = 0      // exactly one side broke before the next session started
var int  statDoubleBreak = 0      // BOTH sides broke before the next session started
var int  statNoBreakout  = 0      // neither side broke before the next session started

// -----------------------------------------------------------------------------
// DAY-OF-WEEK BREAKDOWN - the same result/breakout stats as above, but bucketed
// by which calendar day (in the IB timezone) the session's start fell on.
// Index 0=Sunday..6=Saturday, matching dayofweek()-1.
// -----------------------------------------------------------------------------
var array<int> dowSessions           = array.new_int(7, 0)
var array<int> dowLowFirst           = array.new_int(7, 0)
var array<int> dowHighFirst          = array.new_int(7, 0)
var array<int> dowLowFirst_BrokeHigh = array.new_int(7, 0)
var array<int> dowLowFirst_BrokeLow  = array.new_int(7, 0)
var array<int> dowHighFirst_BrokeHigh = array.new_int(7, 0)
var array<int> dowHighFirst_BrokeLow  = array.new_int(7, 0)
var int sessionDowIndex = na  // day index of the session currently being breakout-monitored

// -----------------------------------------------------------------------------
// IB EXTENSION LEVELS STATE - lines/labels are created ONCE per session (right
// when the IB finalizes) and never recreated every candle. Labels are simply
// repositioned each bar to hug the current right edge; the lines themselves
// use extend.right so they never need per-bar updates at all.
// -----------------------------------------------------------------------------
var array<line>  extLinesArr  = array.new_line()
var array<label> extLabelsArr = array.new_label()
// multiples of the IB Range and their display names - kept as parallel arrays
// so this list is the single place to edit if more levels are ever needed
var array<float>  extMultipliers = array.from(0.5, 1.0, 1.5, 2.0, 2.5, 3.0)
var array<string> extLevelNames  = array.from("0.5", "1", "1.5", "2", "2.5", "3")

// -----------------------------------------------------------------------------
// IB EXTENSION TARGET HIT-RATE TRACKING - real historical stats (replaces the
// original placeholder table). Indices 0-5 are the positive levels (+0.5..+3),
// indices 6-11 are the negative levels (-0.5..-3), matching extTargetNames.
// -----------------------------------------------------------------------------
var array<float> currentTargetPrices  = array.new_float(12, na)  // this session's frozen target prices, set at finalize
var array<bool>  levelHitThisSession  = array.new_bool(12, false) // has each level already been reached this session
var array<int>   statLevelHitCounts   = array.new_int(12, 0)      // total sessions where each level was ever reached


// Fibonacci retracement DEPTH distribution - PRE-BREAK. Answers "after the IB
// closes but BEFORE either boundary breaks, how deep back into the range does
// price wander" as a plain
// historical distribution, bucketed by the deepest standard fib ratio reached
// (measured from the boundary that eventually broke, back toward the opposite
// IB boundary). Which boundary that is isn't known until the break happens, so
// both directions are tracked in parallel and the matching one is committed at
// the moment of the break.
//
// Because a full 1.0 excursion would mean touching the OPPOSITE boundary -
// which is itself a break, and would therefore have ended the pre-break window
// first - the measured depth is strictly inside [0, 1). There is no ">=1.0"
// band here, unlike the post-break version this replaced.
var float preBreakMaxFromHigh = 0.0  // deepest excursion DOWN from IB High, as a fraction of IB Range, so far this session
var float preBreakMaxFromLow  = 0.0  // deepest excursion UP from IB Low, same units
var array<string> fibBandNames      = array.from("< 0.236", "0.236 - 0.382", "0.382 - 0.5", "0.5 - 0.618", "0.618 - 0.786", ">= 0.786")
var array<int>    statFibBandCounts = array.new_int(6, 0)  // index i matches fibBandNames

// =============================================================================
// CORE PROCESSOR - updates IB high/low/timestamps using ONLY timestamp logic
// -----------------------------------------------------------------------------
// NOTE: Pine Script does not allow user-defined functions to reassign global
// `var` variables (CE10088), so the reset / update-extremes / finalize steps
// are inlined at each call site below instead of being wrapped in functions.
// =============================================================================

// =============================================================================
// MAIN DRIVER - chart bar IS the resolution we detect formation order at.
// =============================================================================
ibFinalized := false  // one-shot flag: only true on the bar a session actually finalizes

inSessNow  = f_inSession()
newSessNow = inSessNow and not f_inSession()[1]
endedNow   = f_inSession()[1] and not inSessNow
if newSessNow
    // if the prior session finalized, tally its single/double/no-break outcome before wiping state
    if ibHasSession and not ibActive
        if postBrokeHigh and postBrokeLow
            statDoubleBreak += 1
        else if postBrokeHigh or postBrokeLow
            statSingleBreak += 1
        else
            statNoBreakout += 1
        // NOTE: retracement depth is committed at the break, not here - see
        // the "Retracement depth" comment inside the break-detection block below.
        if cmbEntered and not cmbResolved
            array.set(statComboOpen, breakComboIdx, array.get(statComboOpen, breakComboIdx) + 1)
    // --- reset for new session ---
    ibHigh := na
    ibLow := na
    ibHighTime := na
    ibLowTime := na
    ibSessionStartTime := time
    ibActive := true
    ibFinalized := false
    breakDetected := false
    postBrokeHigh := false
    postBrokeLow := false
    sessionLowFirst := false
    sessionHighFirst := false
    sessionTimingBucket := na
    sessionTimingMinutes := na
    breakComboIdx := na
    cmbEntered := false
    cmbResolved := false
    cmbIsLong := false
    cmbEntryPrice := na
    cmbStopPrice := na
    cmbTargetPrice := na
    array.fill(levelHitThisSession, false)
    // Retracement depth: wipe per-session state
    preBreakMaxFromHigh := 0.0
    preBreakMaxFromLow := 0.0
    if showPastSessionBoxes and not na(ibBoxObj)
        array.push(pastBoxArr, ibBoxObj)
        array.push(pastHighArr, ibHighLineObj)
        array.push(pastLowArr, ibLowLineObj)
        array.push(pastMidArr, ibMidLineObj)
        if showHistoricalLabels
            array.push(pastLabelArr, ibLabelObj)
        else
            label.delete(ibLabelObj)
            array.push(pastLabelArr, na)
        // Internal fib levels: move this session's lines into the flat
        // history array and record how many there were, same pattern as
        // pastBoxArr/pastHighArr/etc. above.
        array.push(pastInternalCnt, array.size(ibInternalLines))
        if array.size(ibInternalLines) > 0
            for j = 0 to array.size(ibInternalLines) - 1
                array.push(pastInternalArr, array.get(ibInternalLines, j))
        while array.size(pastBoxArr) > pastSessionCount
            box.delete(array.shift(pastBoxArr))
            line.delete(array.shift(pastHighArr))
            line.delete(array.shift(pastLowArr))
            line.delete(array.shift(pastMidArr))
            label.delete(array.shift(pastLabelArr))
            oldInternalCntDirect = array.shift(pastInternalCnt)
            if oldInternalCntDirect > 0
                for j = 1 to oldInternalCntDirect
                    line.delete(array.shift(pastInternalArr))
    else
        box.delete(ibBoxObj)
        line.delete(ibHighLineObj)
        line.delete(ibLowLineObj)
        line.delete(ibMidLineObj)
        label.delete(ibLabelObj)
        if array.size(ibInternalLines) > 0
            for j = 0 to array.size(ibInternalLines) - 1
                line.delete(array.get(ibInternalLines, j))
    array.clear(ibInternalLines)
    ibBoxObj := na
    ibHighLineObj := na
    ibLowLineObj := na
    ibMidLineObj := na
    ibLabelObj := na
    // extension objects: only wiped on a new session when in "Only Current Session" mode
    if not showHistoricalExtLevels
        if array.size(extLinesArr) > 0
            for j = 0 to array.size(extLinesArr) - 1
                line.delete(array.get(extLinesArr, j))
            array.clear(extLinesArr)
        if array.size(extLabelsArr) > 0
            for j = 0 to array.size(extLabelsArr) - 1
                label.delete(array.get(extLabelsArr, j))
            array.clear(extLabelsArr)
if inSessNow
    // --- update extremes: every new high/low replaces BOTH price and timestamp ---
    if na(ibHigh) or high > ibHigh
        ibHigh := high
        ibHighTime := time
    if na(ibLow) or low < ibLow
        ibLow := low
        ibLowTime := time
    ibLastBarTime := time
    ibLastBarResMs := timeframe.in_seconds() * 1000
else if endedNow and ibActive
    // --- finalize session ---
    ibActive := false
    ibFinalized := true
    ibHasSession := true
    statSessions += 1
    ibRangeCalcDirect = ibHigh - ibLow
    gapMinCalcDirect = math.abs(ibHighTime - ibLowTime) / 60000.0
    statRangeSum += ibRangeCalcDirect
    statGapSumMin += gapMinCalcDirect
    sessionDowIndex := dayofweek(ibSessionStartTime, ibTimezone) - 1
    array.set(dowSessions, sessionDowIndex, array.get(dowSessions, sessionDowIndex) + 1)
    if ibLowTime < ibHighTime
        statLowFirstCount += 1
        sessionLowFirst := true
        array.set(dowLowFirst, sessionDowIndex, array.get(dowLowFirst, sessionDowIndex) + 1)
    else if ibHighTime < ibLowTime
        statHighFirstCount += 1
        sessionHighFirst := true
        array.set(dowHighFirst, sessionDowIndex, array.get(dowHighFirst, sessionDowIndex) + 1)
    else
        statSimultaneousCount += 1
    // Formation Timing: actual MINUTES into the IB window when the LATER
    // (deciding) extreme formed, bucketed against the two configured
    // cutoffs. Skipped (left na) for Simultaneous sessions - there's no
    // "later" extreme.
    sessionTimingBucket := na
    laterExtremeTimeDirect = sessionLowFirst ? ibHighTime : sessionHighFirst ? ibLowTime : int(na)
    if not na(laterExtremeTimeDirect)
        minutesIntoIBDirect = (laterExtremeTimeDirect - ibSessionStartTime) / 60000.0
        sessionTimingBucket := minutesIntoIBDirect < timingEarlyCutoffMin ? 0 : minutesIntoIBDirect < timingLateCutoffMin ? 1 : 2
        sessionTimingMinutes := minutesIntoIBDirect
        if sessionLowFirst
            array.set(timingLowSessions, sessionTimingBucket, array.get(timingLowSessions, sessionTimingBucket) + 1)
        else if sessionHighFirst
            array.set(timingHighSessions, sessionTimingBucket, array.get(timingHighSessions, sessionTimingBucket) + 1)
else if not inSessNow and not ibActive and ibHasSession and not na(ibHigh)
    // --- post-IB breakout monitoring: which side gets hit FIRST (stops after the first cross) ---
    if not breakDetected
        crossedHigh = high >= ibHigh
        crossedLow  = low <= ibLow
        if crossedHigh and crossedLow
            statAmbiguousBreak += 1
            breakDetected := true
            // direction can't be honestly determined from a single bar
            // that crossed both boundaries at once - the retracement
            // depth stat sits this session out rather than guessing.
        else if crossedHigh
            breakDetected := true
            if sessionLowFirst
                statLowFirst_BrokeHigh += 1
                array.set(dowLowFirst_BrokeHigh, sessionDowIndex, array.get(dowLowFirst_BrokeHigh, sessionDowIndex) + 1)
                if not na(sessionTimingBucket)
                    array.set(timingLowBrokeHigh, sessionTimingBucket, array.get(timingLowBrokeHigh, sessionTimingBucket) + 1)
            else if sessionHighFirst
                statHighFirst_BrokeHigh += 1
                array.set(dowHighFirst_BrokeHigh, sessionDowIndex, array.get(dowHighFirst_BrokeHigh, sessionDowIndex) + 1)
                if not na(sessionTimingBucket)
                    array.set(timingHighBrokeHigh, sessionTimingBucket, array.get(timingHighBrokeHigh, sessionTimingBucket) + 1)
            // Which of the four bias/break buckets this session is in -
            // read later by the 0.5-extension follow-through counters.
            breakComboIdx := na
            if sessionLowFirst
                breakComboIdx := 0
            else if sessionHighFirst
                breakComboIdx := 2
            if not na(breakComboIdx)
                cmbEntered := true
                cmbIsLong := true
                cmbEntryPrice := ibHigh
                cmbStopPrice := (ibHigh + ibLow) / 2.0
                cmbTargetPrice := array.get(currentTargetPrices, 0)
            // Retracement depth: pre-break window just ended - commit the
            // excursion measured from the IB High (the boundary that broke).
            fibBandIdxUpDirect = preBreakMaxFromHigh >= 0.786 ? 5 : preBreakMaxFromHigh >= 0.618 ? 4 : preBreakMaxFromHigh >= 0.5 ? 3 : preBreakMaxFromHigh >= 0.382 ? 2 : preBreakMaxFromHigh >= 0.236 ? 1 : 0
            array.set(statFibBandCounts, fibBandIdxUpDirect, array.get(statFibBandCounts, fibBandIdxUpDirect) + 1)
        else if crossedLow
            breakDetected := true
            if sessionLowFirst
                statLowFirst_BrokeLow += 1
                array.set(dowLowFirst_BrokeLow, sessionDowIndex, array.get(dowLowFirst_BrokeLow, sessionDowIndex) + 1)
                if not na(sessionTimingBucket)
                    array.set(timingLowBrokeLow, sessionTimingBucket, array.get(timingLowBrokeLow, sessionTimingBucket) + 1)
            else if sessionHighFirst
                statHighFirst_BrokeLow += 1
                array.set(dowHighFirst_BrokeLow, sessionDowIndex, array.get(dowHighFirst_BrokeLow, sessionDowIndex) + 1)
                if not na(sessionTimingBucket)
                    array.set(timingHighBrokeLow, sessionTimingBucket, array.get(timingHighBrokeLow, sessionTimingBucket) + 1)
            breakComboIdx := na
            if sessionLowFirst
                breakComboIdx := 1
            else if sessionHighFirst
                breakComboIdx := 3
            if not na(breakComboIdx)
                cmbEntered := true
                cmbIsLong := false
                cmbEntryPrice := ibLow
                cmbStopPrice := (ibHigh + ibLow) / 2.0
                cmbTargetPrice := array.get(currentTargetPrices, 6)
            // Retracement depth: mirror of the long case above.
            fibBandIdxDnDirect = preBreakMaxFromLow >= 0.786 ? 5 : preBreakMaxFromLow >= 0.618 ? 4 : preBreakMaxFromLow >= 0.5 ? 3 : preBreakMaxFromLow >= 0.382 ? 2 : preBreakMaxFromLow >= 0.236 ? 1 : 0
            array.set(statFibBandCounts, fibBandIdxDnDirect, array.get(statFibBandCounts, fibBandIdxDnDirect) + 1)
    // --- retracement depth (PRE-break): deepest excursion back into the IB
    // range from each boundary, accumulated only while NO break has happened
    // yet. Placed AFTER the break-detection block above and gated on
    // breakDetected, so the breaking bar's own wick never counts toward the
    // pre-break depth. ---
    if not breakDetected
        ibRangePreDirect = ibHigh - ibLow
        if ibRangePreDirect > 0
            fromHighDirect = (ibHigh - low) / ibRangePreDirect
            fromLowDirect  = (high - ibLow) / ibRangePreDirect
            if fromHighDirect > preBreakMaxFromHigh
                preBreakMaxFromHigh := fromHighDirect
            if fromLowDirect > preBreakMaxFromLow
                preBreakMaxFromLow := fromLowDirect
    // --- single/double break tracking: keeps checking BOTH sides for the whole
    // post-IB period, independent of breakDetected above ---
    if high >= ibHigh
        postBrokeHigh := true
    if low <= ibLow
        postBrokeLow := true
    // --- extension target hit-rate tracking: independent of breakDetected, keeps
    // checking every not-yet-hit level for the rest of the post-IB period ---
    for lv = 0 to array.size(currentTargetPrices) - 1
        if not array.get(levelHitThisSession, lv)
            targetPrice = array.get(currentTargetPrices, lv)
            levelHit = lv < 6 ? high >= targetPrice : low <= targetPrice
            if levelHit
                array.set(levelHitThisSession, lv, true)
                array.set(statLevelHitCounts, lv, array.get(statLevelHitCounts, lv) + 1)
                // 0.5-extension follow-through: only the +0.5 (lv 0) and
                // -0.5 (lv 6) levels count, and only toward the bucket
                // whose break direction MATCHES the level - reaching
                // -0.5 after an upside break says nothing about that
                // break following through. na combo (ambiguous break,
                // or no break yet) counts toward nothing.
                if not na(breakComboIdx)
                    if lv == 0 and breakComboIdx == 0
                        statLF_BH_Hit += 1
                    if lv == 0 and breakComboIdx == 2
                        statHF_BH_Hit += 1
                    if lv == 6 and breakComboIdx == 1
                        statLF_BL_Hit += 1
                    if lv == 6 and breakComboIdx == 3
                        statHF_BL_Hit += 1
    // --- Expectancy (Stop @ IB Mid): resolve the fixed simulated trade for
    // this session, if one is armed and not yet resolved. Conservative
    // intrabar tie-break: if one bar's range spans BOTH stop and target, the
    // stop is assumed hit first (this script's standing "never guess in the
    // trade's favor" rule). ---
    if cmbEntered and not cmbResolved
        cmbStopHitDirect   = cmbIsLong ? low <= cmbStopPrice   : high >= cmbStopPrice
        cmbTargetHitDirect = cmbIsLong ? high >= cmbTargetPrice : low <= cmbTargetPrice
        if cmbStopHitDirect
            array.set(statComboLosses, breakComboIdx, array.get(statComboLosses, breakComboIdx) + 1)
            array.set(statComboSumR, breakComboIdx, array.get(statComboSumR, breakComboIdx) - 1.0)
            cmbResolved := true
        else if cmbTargetHitDirect
            array.set(statComboWins, breakComboIdx, array.get(statComboWins, breakComboIdx) + 1)
            cmbRDenomDirect = cmbIsLong ? (cmbEntryPrice - cmbStopPrice) : (cmbStopPrice - cmbEntryPrice)
            cmbTradeRDirect = cmbRDenomDirect > 0 ? (cmbIsLong ? (cmbTargetPrice - cmbEntryPrice) / cmbRDenomDirect : (cmbEntryPrice - cmbTargetPrice) / cmbRDenomDirect) : 1.0
            array.set(statComboSumR, breakComboIdx, array.get(statComboSumR, breakComboIdx) + cmbTradeRDirect)
            cmbResolved := true

// =============================================================================
// RESULT (timestamp comparison ONLY - never price comparison)
// =============================================================================
bool lowFormedFirst  = not na(ibHighTime) and not na(ibLowTime) and ibLowTime  < ibHighTime
bool highFormedFirst = not na(ibHighTime) and not na(ibLowTime) and ibHighTime < ibLowTime
bool simultaneous    = not na(ibHighTime) and not na(ibLowTime) and ibHighTime == ibLowTime

resultColor = simultaneous ? colorNeutral : lowFormedFirst ? colorLowFirst : highFormedFirst ? colorHighFirst : colorNeutral
resultText  = simultaneous ? "SIMULTANEOUS" : lowFormedFirst ? "LOW FORMED FIRST" : highFormedFirst ? "HIGH FORMED FIRST" : "FORMING..."
// Directional read: whichever extreme formed LAST reflects who currently controls order flow.
// Kept short (just "LONG"/"SHORT") - table columns auto-size to their widest
// cell, so a long sentence here was forcing the whole value column to stretch.
biasText = lowFormedFirst ? "LONG" : highFormedFirst ? "SHORT" : simultaneous ? "None" : "Forming..."

// Moved up from the VISUALIZATION section below - the Quant Bias Execution
// Model's Fib 0.5 trigger needs this value, and it's cheap to compute early.
ibMid = not na(ibHigh) and not na(ibLow) ? (ibHigh + ibLow) / 2.0 : na

// Extension target prices - computed unconditionally the instant the IB
// finalizes, independent of showExtensions (a chart-drawing toggle). Bug fix:
// this used to live inside the VISUALIZATION section's `if showExtensions and
// ibFinalized` block, so turning extension LINES off silently froze every
// level's target price at whatever the last session with them enabled last
// computed - and every hit-rate stat, Quant Bias Factor 2, the Compact
// Dashboard, and the Trade Planner all read these prices. Compute vs. draw
// are now two independent concerns; only drawing stays gated by showExtensions.
if ibFinalized
    ibRangeExt = ibHigh - ibLow
    for k = 0 to array.size(extMultipliers) - 1
        mult = array.get(extMultipliers, k)
        array.set(currentTargetPrices, k, ibHigh + ibRangeExt * mult)
        array.set(currentTargetPrices, k + 6, ibLow - ibRangeExt * mult)

// sessionComplete/postIB: general "has this session's IB finished and closed"
// flags used by the dashboard's live Break Type row below - not tied to any
// scoring/trigger model.
sessionComplete = ibHasSession and not ibActive
postIB = sessionComplete and not na(ibHigh) and not na(ibLow)

// =============================================================================
// TOP-CENTER BIAS LABEL - a quick-glance summary of this session's Bias
// (LONG/SHORT, from the RESULT section's timestamp-only formation-order rule
// above - nothing new computed here). No score, no entry-ready gating.
// =============================================================================
if barstate.islast and showBiasLabel
    biasLabelColor = lowFormedFirst ? colorLowFirst : highFormedFirst ? colorHighFirst : colorNeutral
    biasLabelText = not sessionComplete ? "IB FORMING" : simultaneous ? "NO BIAS (Simultaneous)" : "BIAS: " + biasText
    var table biasLabelTbl = table.new(position.top_center, 1, 1, border_width = 1)
    table.cell(biasLabelTbl, 0, 0, biasLabelText, text_color = biasLabelColor, text_size = biasLabelSizeVal)

// =============================================================================
// VISUALIZATION - drawn using xloc.bar_time so multiple sessions inside one
// large chart bar (daily/weekly charts) are still placed correctly.
// =============================================================================
// ibMid is computed earlier, right after RESULT.

if not na(ibHigh) and not na(ibLow)
    boxColor  = ibActive ? colorNeutral : resultColor
    // ibLastBarTime holds the OPEN time of the last in-session bar, at
    // whichever resolution (1m normally, 5m if the fallback kicked in) was
    // active when that bar was processed - ibLastBarResMs tracks which.
    // The true session boundary is exactly ibLastBarTime + ibLastBarResMs
    // (that bar's close) - but landing EXACTLY on a boundary that is
    // simultaneously the open of the next chart candle is an unresolved tie:
    // TradingView appears to resolve it toward the candle that starts there,
    // not the one that ends there, making the box visually bleed one candle
    // too far. Backing off by 1 second removes the tie entirely - still
    // visually flush against the end of the last in-session candle, but
    // unambiguously on its side.
    endTimeX  = ibActive ? time_close : ibLastBarTime + ibLastBarResMs - 1000

    if showBox
        if na(ibBoxObj)
            ibBoxObj := box.new(ibSessionStartTime, ibHigh, endTimeX, ibLow, border_color = boxColor, bgcolor = color.new(boxColor, boxFillTransparency), xloc = xloc.bar_time, extend = extend.none)
        else
            box.set_top(ibBoxObj, ibHigh)
            box.set_bottom(ibBoxObj, ibLow)
            box.set_right(ibBoxObj, endTimeX)
            box.set_border_color(ibBoxObj, boxColor)
            box.set_bgcolor(ibBoxObj, color.new(boxColor, boxFillTransparency))

    if showMidline
        if na(ibMidLineObj)
            ibMidLineObj := line.new(ibSessionStartTime, ibMid, endTimeX, ibMid, xloc = xloc.bar_time, color = colorMid, width = lineWidthIn, style = line.style_dashed)
        else
            line.set_y1(ibMidLineObj, ibMid)
            line.set_y2(ibMidLineObj, ibMid)
            line.set_x2(ibMidLineObj, endTimeX)

    // Internal fib levels - same create-once-then-reposition pattern as the
    // midline above, just N lines instead of one. Both passes walk
    // internalFracs in the same order and skip on the same f_internalEnabled
    // test, so the k'th ENABLED fraction always maps to element `slot` of
    // ibInternalLines. Prices track ibLow/ibHigh every bar, so the levels
    // follow the box while the IB is still forming and freeze with it.
    if showInternalLevels
        ibRangeInternal = ibHigh - ibLow
        if array.size(ibInternalLines) == 0
            for k = 0 to array.size(internalFracs) - 1
                if f_internalEnabled(k)
                    lvlPrice = ibLow + array.get(internalFracs, k) * ibRangeInternal
                    array.push(ibInternalLines, line.new(ibSessionStartTime, lvlPrice, endTimeX, lvlPrice, xloc = xloc.bar_time, color = colorInternal, width = internalWidthIn, style = internalStyleVal))
        else
            slot = 0
            for k = 0 to array.size(internalFracs) - 1
                if f_internalEnabled(k) and slot < array.size(ibInternalLines)
                    lvlPrice = ibLow + array.get(internalFracs, k) * ibRangeInternal
                    lvlLine = array.get(ibInternalLines, slot)
                    line.set_y1(lvlLine, lvlPrice)
                    line.set_y2(lvlLine, lvlPrice)
                    line.set_x2(lvlLine, endTimeX)
                    slot += 1

    if na(ibHighLineObj)
        ibHighLineObj := line.new(ibSessionStartTime, ibHigh, endTimeX, ibHigh, xloc = xloc.bar_time, color = boxColor, width = lineWidthIn)
    else
        line.set_y1(ibHighLineObj, ibHigh)
        line.set_y2(ibHighLineObj, ibHigh)
        line.set_color(ibHighLineObj, boxColor)
        if ibActive or showExtension
            line.set_x2(ibHighLineObj, endTimeX)

    if na(ibLowLineObj)
        ibLowLineObj := line.new(ibSessionStartTime, ibLow, endTimeX, ibLow, xloc = xloc.bar_time, color = boxColor, width = lineWidthIn)
    else
        line.set_y1(ibLowLineObj, ibLow)
        line.set_y2(ibLowLineObj, ibLow)
        line.set_color(ibLowLineObj, boxColor)
        if ibActive or showExtension
            line.set_x2(ibLowLineObj, endTimeX)

    // Kept deliberately minimal - just the headline result. All the detail
    // (High/Low/Mid/Range/Times/Bias) now lives in the "Current Session"
    // section of the IB Order Statistics table (top-right by default) so the
    // chart itself doesn't get cluttered with a big text block.
    if showLabels and ibFinalized
        labelCenterX = int(math.round((ibSessionStartTime + endTimeX) / 2))
        label.delete(ibLabelObj)
        ibLabelObj := label.new(labelCenterX, ibHigh, resultText, xloc = xloc.bar_time, style = label.style_label_down, color = color(na), textcolor = resultColor, size = labelSizeVal)

    // -------------------------------------------------------------------
    // IB EXTENSION LEVELS - created ONCE, exactly when the IB finalizes.
    // Never plotted while the IB is still forming (guarded by ibFinalized,
    // which is only true on the single bar a session just completed).
    // -------------------------------------------------------------------
    // Target prices are computed unconditionally on finalize (below, before
    // this VISUALIZATION section runs) regardless of showExtensions - they
    // feed real statistics (hit-rate table, Quant Bias Factor 2, Compact
    // Dashboard, Trade Planner) that must stay correct even
    // when the extension lines themselves are hidden. This block only draws.
    if showExtensions and ibFinalized
        // Lines run from the LEFT edge of the IB box (like the box/high/low
        // lines already do) through the box and a fixed distance past the IB
        // end, then stop (extend.none). They no longer extend to infinity, so
        // they can't grow into and collide with screen-docked tables.
        lineX1 = ibSessionStartTime
        lineX2 = endTimeX + extLineLengthMinutes * 60000
        labelX = lineX2 + extLabelOffsetMinutes * 60000
        for k = 0 to array.size(extMultipliers) - 1
            mult = array.get(extMultipliers, k)
            name = array.get(extLevelNames, k)
            posPrice = array.get(currentTargetPrices, k)
            negPrice = array.get(currentTargetPrices, k + 6)
            if showPosExtensions and f_levelEnabled(k)
                posLine = line.new(lineX1, posPrice, lineX2, posPrice, xloc = xloc.bar_time, color = colorPosExt, width = extLineWidthIn, style = extLineStyleVal, extend = extend.none)
                array.push(extLinesArr, posLine)
                if showExtLabels
                    posLabelTxt = "+" + name + (showExtPrices ? "  " + str.tostring(posPrice, format.mintick) : "")
                    // style_label_down sits the text bubble ABOVE the anchor price so it
                    // doesn't render directly on top of / overlapping the line itself
                    posLabel = label.new(labelX, posPrice, posLabelTxt, xloc = xloc.bar_time, style = label.style_label_down, color = color(na), textcolor = colorPosExt, size = extLabelSizeVal)
                    array.push(extLabelsArr, posLabel)
            if showNegExtensions and f_levelEnabled(k)
                negLine = line.new(lineX1, negPrice, lineX2, negPrice, xloc = xloc.bar_time, color = colorNegExt, width = extLineWidthIn, style = extLineStyleVal, extend = extend.none)
                array.push(extLinesArr, negLine)
                if showExtLabels
                    negLabelTxt = "-" + name + (showExtPrices ? "  " + str.tostring(negPrice, format.mintick) : "")
                    // style_label_up sits the text bubble BELOW the anchor price, appropriate
                    // for negative (downside) levels so labels don't collide with each other
                    negLabel = label.new(labelX, negPrice, negLabelTxt, xloc = xloc.bar_time, style = label.style_label_up, color = color(na), textcolor = colorNegExt, size = extLabelSizeVal)
                    array.push(extLabelsArr, negLabel)

// =============================================================================
// SHARED DERIVED STATS - computed once, reused by Compact Dashboard, Advanced
// Dashboard, and Trade Planner below. None of this touches the underlying
// calculations/accumulators - it's read-only presentation math on top of them.
// =============================================================================
var array<string> extTargetNames = array.from("+0.5", "+1.0", "+1.5", "+2.0", "+2.5", "+3.0", "-0.5", "-1.0", "-1.5", "-2.0", "-2.5", "-3.0")

// Row count for Extension Targets (Expanded mode) is driven by inputs only
// (level toggles + pos/neg side toggles), fixed for the whole run.
extActiveRowCount = 0
if showPosExtensions
    for k = 0 to 5
        if f_levelEnabled(k)
            extActiveRowCount += 1
if showNegExtensions
    for k = 0 to 5
        if f_levelEnabled(k)
            extActiveRowCount += 1

if barstate.islast and (showStatsTable or showTradePlanner)
    lowPct     = statSessions > 0 ? (statLowFirstCount     / float(statSessions)) * 100.0 : na
    highPct    = statSessions > 0 ? (statHighFirstCount    / float(statSessions)) * 100.0 : na

    // conditional breakout odds: of the sessions where each side formed first, which way did price actually break?
    lowFirstTotal      = statLowFirst_BrokeHigh + statLowFirst_BrokeLow
    highFirstTotal     = statHighFirst_BrokeHigh + statHighFirst_BrokeLow
    lowFirstBrokeHighPct = lowFirstTotal  > 0 ? (statLowFirst_BrokeHigh  / float(lowFirstTotal))  * 100.0 : na
    lowFirstBrokeLowPct  = lowFirstTotal  > 0 ? (statLowFirst_BrokeLow   / float(lowFirstTotal))  * 100.0 : na
    highFirstBrokeLowPct = highFirstTotal > 0 ? (statHighFirst_BrokeLow  / float(highFirstTotal)) * 100.0 : na
    highFirstBrokeHighPct = highFirstTotal > 0 ? (statHighFirst_BrokeHigh / float(highFirstTotal)) * 100.0 : na
    noBreakoutPct = statSessions > 0 ? (statNoBreakout / float(statSessions)) * 100.0 : na
    singleBreakPct = statSessions > 0 ? (statSingleBreak / float(statSessions)) * 100.0 : na
    doubleBreakPct = statSessions > 0 ? (statDoubleBreak / float(statSessions)) * 100.0 : na

    // Live break-type read for the CURRENT session (not historical) - what
    // has actually happened post-IB so far, updated every bar
    breakTypeNow = not postIB ? "-" : (postBrokeHigh and postBrokeLow) ? "Double Break" : postBrokeHigh ? "Single (High)" : postBrokeLow ? "Single (Low)" : "No Break Yet"
    breakTypeColor = breakTypeNow == "Double Break" ? color.blue : breakTypeNow == "Single (High)" ? colorHighFirst : breakTypeNow == "Single (Low)" ? colorLowFirst : colorNeutral

    // this session's detail (the stuff that used to clutter the on-chart label)
    curTimeHighStr  = not na(ibHighTime) ? str.format_time(ibHighTime, "HH:mm", ibTimezone) : "-"
    curTimeLowStr   = not na(ibLowTime)  ? str.format_time(ibLowTime, "HH:mm", ibTimezone)  : "-"
    curDateStr      = not na(ibSessionStartTime) ? str.format_time(ibSessionStartTime, "dd MMM yyyy", ibTimezone) : "-"
    curGapMin       = not na(ibHighTime) and not na(ibLowTime) ? math.abs(ibHighTime - ibLowTime) / 60000.0 : na

    // Breakout Probability for TODAY's bias specifically (Low-first -> Broke High,
    // or High-first -> Broke Low) - drives Compact Mode, Confidence Score, and
    // Trade Planner. Uses explicit if/else (not chained ternary) because Pine
    // evaluates BOTH branches of `?:`, and array.get with a bad/negative index
    // would throw even in an untaken branch.
    breakoutProbToday = float(na)
    if lowFormedFirst
        breakoutProbToday := lowFirstBrokeHighPct
    else if highFormedFirst
        breakoutProbToday := highFirstBrokeLowPct

    // Formation Timing read for the CURRENT session - which bucket its
    // deciding extreme landed in, plus that exact bucket's historical
    // confirmation rate, so the Current Session section doesn't just say
    // "Low First" but "Low First, Late (52m) - historically confirms 76.5%
    // of the time (n=269)". na (still forming, or Simultaneous) shows "-".
    sessionTimingLabel = "-"
    sessionTimingConfirmPct = float(na)
    sessionTimingConfirmN = 0
    if not na(sessionTimingBucket)
        tBucketName = sessionTimingBucket == 0 ? "Early" : sessionTimingBucket == 1 ? "Mid" : "Late"
        sessionTimingLabel := tBucketName + " (" + str.tostring(math.round(sessionTimingMinutes)) + "m)"
        if lowFormedFirst
            tCurBH = array.get(timingLowBrokeHigh, sessionTimingBucket)
            tCurBL = array.get(timingLowBrokeLow, sessionTimingBucket)
            sessionTimingConfirmN := tCurBH + tCurBL
            sessionTimingConfirmPct := sessionTimingConfirmN > 0 ? tCurBH / float(sessionTimingConfirmN) * 100.0 : na
        else if highFormedFirst
            tCurBH = array.get(timingHighBrokeHigh, sessionTimingBucket)
            tCurBL = array.get(timingHighBrokeLow, sessionTimingBucket)
            sessionTimingConfirmN := tCurBH + tCurBL
            sessionTimingConfirmPct := sessionTimingConfirmN > 0 ? tCurBL / float(sessionTimingConfirmN) * 100.0 : na

    // Confidence Score (Section 8 placeholder) = Breakout Probability only, for
    // now - a placeholder for future weighted factors.
    confidenceScore = breakoutProbToday
    confidenceLabel = na(confidenceScore) ? "N/A" : confidenceScore >= 80 ? "Very High" : confidenceScore >= 65 ? "High" : confidenceScore >= 50 ? "Medium" : "Low"

    // Primary (±0.5) and secondary (±1.0) extension targets in today's bias
    // direction - drives Compact Extension Panel, Compact Dashboard, and Trade
    // Planner. Constant indices only (0/6/1/7), so no invalid array.get risk.
    primaryName = "-"
    primaryHitPct = float(na)
    primaryDistPct = float(na)
    secondName = "-"
    secondHitPct = float(na)
    secondDistPct = float(na)
    if lowFormedFirst
        primaryName := array.get(extTargetNames, 0)
        primaryHitPct := statSessions > 0 ? array.get(statLevelHitCounts, 0) / float(statSessions) * 100.0 : na
        pTx = array.get(currentTargetPrices, 0)
        primaryDistPct := not na(pTx) and pTx != 0 ? (pTx - close) / close * 100.0 : na
        secondName := array.get(extTargetNames, 1)
        secondHitPct := statSessions > 0 ? array.get(statLevelHitCounts, 1) / float(statSessions) * 100.0 : na
        sTx = array.get(currentTargetPrices, 1)
        secondDistPct := not na(sTx) and sTx != 0 ? (sTx - close) / close * 100.0 : na
    else if highFormedFirst
        primaryName := array.get(extTargetNames, 6)
        primaryHitPct := statSessions > 0 ? array.get(statLevelHitCounts, 6) / float(statSessions) * 100.0 : na
        pTx = array.get(currentTargetPrices, 6)
        primaryDistPct := not na(pTx) and pTx != 0 ? (close - pTx) / close * 100.0 : na
        secondName := array.get(extTargetNames, 7)
        secondHitPct := statSessions > 0 ? array.get(statLevelHitCounts, 7) / float(statSessions) * 100.0 : na
        sTx = array.get(currentTargetPrices, 7)
        secondDistPct := not na(sTx) and sTx != 0 ? (close - sTx) / close * 100.0 : na

    // No fill on title/section rows - distinguished by color + caps only,
    // keeping the table visually light instead of blocked out in solid color
    titleTextColor   = color.new(color.blue, 0)
    // chart.fg_color auto-adapts to the user's theme: near-black on a light
    // chart, near-white on a dark chart - fixes the low-contrast gray that
    // was barely visible, without hardcoding either theme
    sectionTextColor = chart.fg_color
    sz               = statsTableSizeVal
    hsz              = statsTableHeaderSizeVal

    // =========================================================================
    // COMPACT DASHBOARD MODE - Bias, Breakout Probability, Primary Target,
    // Target Hit %, Confidence. Nothing else, regardless of the section
    // toggles below (those only apply in Advanced Mode).
    // =========================================================================
    if showStatsTable and dashboardMode == "Compact"
        var table compactTbl = table.new(tablePosVal, 2, 6, border_width = 1)
        table.cell(compactTbl, 0, 0, "DTC IB PRO", text_color = titleTextColor, text_size = hsz)
        table.cell(compactTbl, 1, 0, "", text_size = hsz)
        table.cell(compactTbl, 0, 1, "Bias", text_size = sz)
        table.cell(compactTbl, 1, 1, biasText, text_color = resultColor, text_size = sz)
        table.cell(compactTbl, 0, 2, "Probability", text_size = sz)
        table.cell(compactTbl, 1, 2, na(breakoutProbToday) ? "-" : str.tostring(breakoutProbToday, "#.##") + "%", text_color = resultColor, text_size = sz)
        table.cell(compactTbl, 0, 3, "Target", text_size = sz)
        table.cell(compactTbl, 1, 3, primaryName, text_size = sz)
        table.cell(compactTbl, 0, 4, "Hit %", text_size = sz)
        table.cell(compactTbl, 1, 4, na(primaryHitPct) ? "-" : str.tostring(primaryHitPct, "#.##") + "%", text_size = sz)
        table.cell(compactTbl, 0, 5, "Confidence", text_size = sz)
        table.cell(compactTbl, 1, 5, confidenceLabel, text_color = chart.fg_color, text_size = sz)

    // =========================================================================
    // ADVANCED DASHBOARD MODE - one modular table, each section independently
    // switchable. Extension Targets is 3 columns (Level/Hit%/Dist%) in Expanded
    // mode, so the whole dashboard uses 3 columns throughout; rows that only
    // need one value simply leave column 2 blank.
    // =========================================================================
    if showStatsTable and dashboardMode == "Advanced"
        advRowCount = 1 + (showCurrentSessionSection ? 9 : 0) + (showAllTimeStatsSection ? 4 : 0) + (showBreakoutOddsSection ? 8 : 0) + (showTimingSection ? 8 : 0) + (showBiasTargetSection ? 7 : 0) + (showExpectancySection ? 6 : 0) + (showExtensionTargetsSection ? (extPanelMode == "Compact" ? 2 : 2 + extActiveRowCount) : 0) + (showDayStatsSection and not showDowTable ? 4 : 0) + (showRetracementSection ? 7 : 0)
        var table statsTbl = table.new(tablePosVal, 3, math.max(advRowCount, 1), border_width = 1)
        table.cell(statsTbl, 0, 0, "IB ORDER STATISTICS", text_color = titleTextColor, text_size = hsz)
        table.cell(statsTbl, 1, 0, "", text_size = hsz)
        table.cell(statsTbl, 2, 0, "", text_size = hsz)

        sRow = 1  // NOT var - must reset every redraw, same reasoning as rowIdx below
        if showCurrentSessionSection
            table.cell(statsTbl, 0, sRow, "Current Session", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Date", text_size = sz)
            table.cell(statsTbl, 1, sRow, curDateStr, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Result", text_size = sz)
            table.cell(statsTbl, 1, sRow, resultText, text_color = resultColor, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "IB Mid", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(ibMid) ? "-" : str.tostring(ibMid, format.mintick), text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Low / High Formed At", text_size = sz)
            table.cell(statsTbl, 1, sRow, showTimes ? curTimeLowStr + " / " + curTimeHighStr : "-", text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Reversal Gap", text_size = sz)
            table.cell(statsTbl, 1, sRow, showTimes and not na(curGapMin) ? str.tostring(curGapMin, "#.#") + " min" : "-", text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Bias", text_size = sz)
            table.cell(statsTbl, 1, sRow, biasText, text_color = resultColor, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Break Type (Live)", text_size = sz)
            table.cell(statsTbl, 1, sRow, breakTypeNow, text_color = breakTypeColor, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Formation Timing", text_size = sz)
            table.cell(statsTbl, 1, sRow, sessionTimingLabel + (na(sessionTimingConfirmPct) ? "" : " - " + str.tostring(sessionTimingConfirmPct, "#.#") + "%"), text_color = resultColor, text_size = sz)
            sRow += 1

        if showAllTimeStatsSection
            table.cell(statsTbl, 0, sRow, "Historical Statistics", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Sessions", text_size = sz)
            table.cell(statsTbl, 1, sRow, str.tostring(statSessions), text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Low Formed First %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(lowPct) ? "-" : str.tostring(lowPct, "#.##") + "%", text_color = colorLowFirst, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "High Formed First %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(highPct) ? "-" : str.tostring(highPct, "#.##") + "%", text_color = colorHighFirst, text_size = sz)
            sRow += 1

        if showBreakoutOddsSection
            table.cell(statsTbl, 0, sRow, "Breakout Odds", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Low First -> Broke High %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(lowFirstBrokeHighPct) ? "-" : str.tostring(lowFirstBrokeHighPct, "#.##") + "%", text_color = colorLowFirst, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Low First -> Broke Low %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(lowFirstBrokeLowPct) ? "-" : str.tostring(lowFirstBrokeLowPct, "#.##") + "%", text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "High First -> Broke Low %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(highFirstBrokeLowPct) ? "-" : str.tostring(highFirstBrokeLowPct, "#.##") + "%", text_color = colorHighFirst, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "High First -> Broke High %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(highFirstBrokeHighPct) ? "-" : str.tostring(highFirstBrokeHighPct, "#.##") + "%", text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "No Breakout by Next Session %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(noBreakoutPct) ? "-" : str.tostring(noBreakoutPct, "#.##") + "%", text_color = colorNeutral, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Single Break %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(singleBreakPct) ? "-" : str.tostring(singleBreakPct, "#.##") + "%", text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Double Break %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(doubleBreakPct) ? "-" : str.tostring(doubleBreakPct, "#.##") + "%", text_color = color.blue, text_size = sz)
            sRow += 1

        // =====================================================================
        // FORMATION TIMING - Breakout Odds above treats every Low/High-First
        // session identically regardless of WHEN the deciding extreme formed
        // within the IB window. This buckets sessions by that timing (Early/
        // Mid/Late thirds of the window) and shows the same confirmation rate
        // per bucket - if Late sessions confirm less often than Early ones,
        // that's evidence a last-minute flip is weaker signal than an early
        // one. Denominator is BROKE sessions in that bucket (not all sessions
        // in the bucket), same convention as Breakout Odds above.
        // =====================================================================
        if showTimingSection
            table.cell(statsTbl, 0, sRow, "Formation Timing", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Bucket", text_size = sz, text_color = sectionTextColor)
            table.cell(statsTbl, 1, sRow, "Sessions", text_size = sz, text_color = sectionTextColor)
            table.cell(statsTbl, 2, sRow, "Confirm %", text_size = sz, text_color = sectionTextColor)
            sRow += 1
            timingBucketNames = array.from("Early (<" + str.tostring(timingEarlyCutoffMin) + "m)", "Mid (" + str.tostring(timingEarlyCutoffMin) + "-" + str.tostring(timingLateCutoffMin) + "m)", "Late (>" + str.tostring(timingLateCutoffMin) + "m)")
            for tb = 0 to 2
                tLowN = array.get(timingLowSessions, tb)
                tLowBH = array.get(timingLowBrokeHigh, tb)
                tLowBL = array.get(timingLowBrokeLow, tb)
                tLowConfirmPct = (tLowBH + tLowBL) > 0 ? tLowBH / float(tLowBH + tLowBL) * 100.0 : na
                table.cell(statsTbl, 0, sRow, "Low First - " + array.get(timingBucketNames, tb), text_size = sz)
                table.cell(statsTbl, 1, sRow, str.tostring(tLowN), text_size = sz)
                table.cell(statsTbl, 2, sRow, na(tLowConfirmPct) ? "-" : str.tostring(tLowConfirmPct, "#.#") + "%", text_color = colorLowFirst, text_size = sz)
                sRow += 1
            for tb = 0 to 2
                tHighN = array.get(timingHighSessions, tb)
                tHighBH = array.get(timingHighBrokeHigh, tb)
                tHighBL = array.get(timingHighBrokeLow, tb)
                tHighConfirmPct = (tHighBH + tHighBL) > 0 ? tHighBL / float(tHighBH + tHighBL) * 100.0 : na
                table.cell(statsTbl, 0, sRow, "High First - " + array.get(timingBucketNames, tb), text_size = sz)
                table.cell(statsTbl, 1, sRow, str.tostring(tHighN), text_size = sz)
                table.cell(statsTbl, 2, sRow, na(tHighConfirmPct) ? "-" : str.tostring(tHighConfirmPct, "#.#") + "%", text_color = colorHighFirst, text_size = sz)
                sRow += 1

        // =====================================================================
        // BIAS FOLLOW-THROUGH TO 0.5 - Breakout Odds above answers "which side
        // broke"; this answers "and did the break go anywhere". Each row's
        // denominator is its own break combination (not all sessions), so the
        // percentages are conditional: given this formation order AND this
        // break side, how often did price reach the 0.5 extension in the
        // direction it broke. Count is shown alongside the percentage because
        // these buckets subdivide the sample four ways and can get thin fast -
        // a 100% on a denominator of 2 is not a 100%.
        // =====================================================================
        if showBiasTargetSection
            table.cell(statsTbl, 0, sRow, "Bias Follow-Through to 0.5", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Bias -> Break -> Target", text_size = sz, text_color = sectionTextColor)
            table.cell(statsTbl, 1, sRow, "Hit / Broke", text_size = sz, text_color = sectionTextColor)
            table.cell(statsTbl, 2, sRow, "Hit %", text_size = sz, text_color = sectionTextColor)
            sRow += 1
            lfbhHitPct = statLowFirst_BrokeHigh  > 0 ? statLF_BH_Hit / float(statLowFirst_BrokeHigh)  * 100.0 : na
            lfblHitPct = statLowFirst_BrokeLow   > 0 ? statLF_BL_Hit / float(statLowFirst_BrokeLow)   * 100.0 : na
            hfblHitPct = statHighFirst_BrokeLow  > 0 ? statHF_BL_Hit / float(statHighFirst_BrokeLow)  * 100.0 : na
            hfbhHitPct = statHighFirst_BrokeHigh > 0 ? statHF_BH_Hit / float(statHighFirst_BrokeHigh) * 100.0 : na
            // Confirmed-bias rows first (Low first -> broke High, High first ->
            // broke Low), then the two failed-bias rows - same ordering the
            // Breakout Odds section above uses.
            lfbhThin = statLowFirst_BrokeHigh  < 50
            hfblThin = statHighFirst_BrokeLow  < 50
            lfblThin = statLowFirst_BrokeLow   < 50
            hfbhThin = statHighFirst_BrokeHigh < 50
            table.cell(statsTbl, 0, sRow, "Low First -> Broke High -> +0.5", text_size = sz)
            table.cell(statsTbl, 1, sRow, str.tostring(statLF_BH_Hit) + "/" + str.tostring(statLowFirst_BrokeHigh), text_size = sz)
            table.cell(statsTbl, 2, sRow, na(lfbhHitPct) ? "-" : str.tostring(lfbhHitPct, "#.#") + "%" + (lfbhThin ? "*" : ""), text_color = colorLowFirst, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "High First -> Broke Low -> -0.5", text_size = sz)
            table.cell(statsTbl, 1, sRow, str.tostring(statHF_BL_Hit) + "/" + str.tostring(statHighFirst_BrokeLow), text_size = sz)
            table.cell(statsTbl, 2, sRow, na(hfblHitPct) ? "-" : str.tostring(hfblHitPct, "#.#") + "%" + (hfblThin ? "*" : ""), text_color = colorHighFirst, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Low First -> Broke Low -> -0.5", text_size = sz)
            table.cell(statsTbl, 1, sRow, str.tostring(statLF_BL_Hit) + "/" + str.tostring(statLowFirst_BrokeLow), text_size = sz)
            table.cell(statsTbl, 2, sRow, na(lfblHitPct) ? "-" : str.tostring(lfblHitPct, "#.#") + "%" + (lfblThin ? "*" : ""), text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "High First -> Broke High -> +0.5", text_size = sz)
            table.cell(statsTbl, 1, sRow, str.tostring(statHF_BH_Hit) + "/" + str.tostring(statHighFirst_BrokeHigh), text_size = sz)
            table.cell(statsTbl, 2, sRow, na(hfbhHitPct) ? "-" : str.tostring(hfbhHitPct, "#.#") + "%" + (hfbhThin ? "*" : ""), text_size = sz)
            sRow += 1
            if lfbhThin or hfblThin or lfblThin or hfbhThin
                table.cell(statsTbl, 0, sRow, "* denominator under 50 - low confidence", text_size = sz, text_color = colorNeutral)
                sRow += 1

        // =====================================================================
        // EXPECTANCY (STOP @ IB MID) - one fixed simulated trade per session
        // that broke: entry at the boundary, stop at IB Mid, target the 0.5
        // extension in the breakout direction. A loss is always exactly -1R
        // by construction (IB Mid IS this trade's risk unit from any entry
        // price), so Exp(R) directly answers whether this exact setup would
        // have been profitable, historically - unlike the raw Hit % above,
        // which says nothing about the stop side of the trade.
        // =====================================================================
        if showExpectancySection
            table.cell(statsTbl, 0, sRow, "Expectancy (Stop @ IB Mid)", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Bias -> Break -> Target", text_size = sz, text_color = sectionTextColor)
            table.cell(statsTbl, 1, sRow, "W/L/Open", text_size = sz, text_color = sectionTextColor)
            table.cell(statsTbl, 2, sRow, "Exp(R)", text_size = sz, text_color = sectionTextColor)
            sRow += 1
            comboLabels = array.from("Low First -> Broke High -> +0.5", "Low First -> Broke Low -> -0.5", "High First -> Broke High -> +0.5", "High First -> Broke Low -> -0.5")
            comboColors = array.new_color(4)
            array.set(comboColors, 0, colorLowFirst)
            array.set(comboColors, 1, chart.fg_color)
            array.set(comboColors, 2, chart.fg_color)
            array.set(comboColors, 3, colorHighFirst)
            for cIdx = 0 to 3
                cWins = array.get(statComboWins, cIdx)
                cLosses = array.get(statComboLosses, cIdx)
                cOpen = array.get(statComboOpen, cIdx)
                cResolvedN = cWins + cLosses
                cExpR = cResolvedN > 0 ? array.get(statComboSumR, cIdx) / float(cResolvedN) : na
                table.cell(statsTbl, 0, sRow, array.get(comboLabels, cIdx), text_size = sz)
                table.cell(statsTbl, 1, sRow, str.tostring(cWins) + "/" + str.tostring(cLosses) + "/" + str.tostring(cOpen), text_size = sz)
                table.cell(statsTbl, 2, sRow, na(cExpR) ? "-" : str.tostring(cExpR, "+0.00") + "R", text_color = na(cExpR) ? array.get(comboColors, cIdx) : (cExpR >= 0 ? colorLowFirst : colorHighFirst), text_size = sz)
                sRow += 1

        if showExtensionTargetsSection
            table.cell(statsTbl, 0, sRow, "Extension Targets", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            if extPanelMode == "Compact"
                table.cell(statsTbl, 0, sRow, "Target", text_size = sz)
                table.cell(statsTbl, 1, sRow, primaryName, text_color = resultColor, text_size = sz)
                table.cell(statsTbl, 2, sRow, na(primaryHitPct) ? "-" : str.tostring(primaryHitPct, "#.##") + "%", text_size = sz)
                sRow += 1
            else
                table.cell(statsTbl, 0, sRow, "Level", text_size = sz, text_color = sectionTextColor)
                table.cell(statsTbl, 1, sRow, "Hit %", text_size = sz, text_color = sectionTextColor)
                table.cell(statsTbl, 2, sRow, "Dist %", text_size = sz, text_color = sectionTextColor)
                sRow += 1
                if showPosExtensions
                    for k = 0 to 5
                        if f_levelEnabled(k)
                            hitPct = statSessions > 0 ? (array.get(statLevelHitCounts, k) / float(statSessions)) * 100.0 : na
                            targetPx = array.get(currentTargetPrices, k)
                            distPct  = not na(targetPx) and targetPx != 0 ? (targetPx - close) / close * 100.0 : na
                            table.cell(statsTbl, 0, sRow, array.get(extTargetNames, k), text_size = sz, text_color = colorPosExt)
                            table.cell(statsTbl, 1, sRow, na(hitPct) ? "--" : str.tostring(hitPct, "#.##") + "%", text_size = sz)
                            table.cell(statsTbl, 2, sRow, na(distPct) ? "--" : str.tostring(distPct, "#.##") + "%", text_size = sz)
                            sRow += 1
                if showNegExtensions
                    for k = 0 to 5
                        if f_levelEnabled(k)
                            hitPct = statSessions > 0 ? (array.get(statLevelHitCounts, k + 6) / float(statSessions)) * 100.0 : na
                            targetPx = array.get(currentTargetPrices, k + 6)
                            distPct  = not na(targetPx) and targetPx != 0 ? (close - targetPx) / close * 100.0 : na
                            table.cell(statsTbl, 0, sRow, array.get(extTargetNames, k + 6), text_size = sz, text_color = colorNegExt)
                            table.cell(statsTbl, 1, sRow, na(hitPct) ? "--" : str.tostring(hitPct, "#.##") + "%", text_size = sz)
                            table.cell(statsTbl, 2, sRow, na(distPct) ? "--" : str.tostring(distPct, "#.##") + "%", text_size = sz)
                            sRow += 1

        if showDayStatsSection and not showDowTable
            todayIdx = dayofweek(time, ibTimezone) - 1
            table.cell(statsTbl, 0, sRow, "Day Statistics - " + f_dayName(todayIdx), text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            tN = array.get(dowSessions, todayIdx)
            tLowFirst  = array.get(dowLowFirst, todayIdx)
            tHighFirst = array.get(dowHighFirst, todayIdx)
            tLowPct  = tN > 0 ? (tLowFirst  / float(tN)) * 100.0 : na
            tHighPct = tN > 0 ? (tHighFirst / float(tN)) * 100.0 : na
            tLowFollowTotal = array.get(dowLowFirst_BrokeHigh, todayIdx) + array.get(dowLowFirst_BrokeLow, todayIdx)
            tLowFollowPct   = tLowFollowTotal > 0 ? (array.get(dowLowFirst_BrokeHigh, todayIdx) / float(tLowFollowTotal)) * 100.0 : na
            tHighFollowTotal = array.get(dowHighFirst_BrokeHigh, todayIdx) + array.get(dowHighFirst_BrokeLow, todayIdx)
            tHighFollowPct   = tHighFollowTotal > 0 ? (array.get(dowHighFirst_BrokeLow, todayIdx) / float(tHighFollowTotal)) * 100.0 : na
            // same dominant-side + follow-through-reliability heuristic used by the full week table below
            tShareDiff = (na(tLowPct) or na(tHighPct)) ? na : tLowPct - tHighPct
            tUseShareDiff = not na(tShareDiff) and math.abs(tShareDiff) > 5
            tDomIsLow = true
            if tUseShareDiff
                tDomIsLow := tShareDiff > 0
            else if na(tLowFollowPct) and na(tHighFollowPct)
                tDomIsLow := true
            else if na(tLowFollowPct)
                tDomIsLow := false
            else if na(tHighFollowPct)
                tDomIsLow := true
            else
                tDomIsLow := tLowFollowPct >= tHighFollowPct
            tDomConfirm = tDomIsLow ? tLowFollowPct : tHighFollowPct
            tVerdict = na(tDomConfirm) ? "-" : tDomConfirm >= 60 ? (tDomIsLow ? "Bullish" : "Bearish") : "Choppy"
            tVerdictColor = tVerdict == "Bullish" ? colorLowFirst : tVerdict == "Bearish" ? colorHighFirst : colorNeutral
            table.cell(statsTbl, 0, sRow, "Historical Bias", text_size = sz)
            table.cell(statsTbl, 1, sRow, tVerdict, text_color = tVerdictColor, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "High First %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(tHighPct) ? "-" : str.tostring(tHighPct, "#.#") + "%", text_color = colorHighFirst, text_size = sz)
            sRow += 1
            table.cell(statsTbl, 0, sRow, "Follow Through %", text_size = sz)
            table.cell(statsTbl, 1, sRow, na(tDomConfirm) ? "-" : str.tostring(tDomConfirm, "#.#") + "%", text_color = tVerdictColor, text_size = sz)
            sRow += 1

        // =====================================================================
        // RETRACEMENT DEPTH (PRE-BREAK) - across every session that broke out,
        // the distribution of the DEEPEST standard fib ratio price retraced
        // back to (measured from the boundary that eventually broke, toward
        // the opposite IB boundary) in the window BETWEEN the IB closing and
        // that break. A plain "how far back into the range does it wander
        // before it goes" read, useful for placing an entry inside the IB
        // ahead of the break rather than chasing the boundary itself.
        // =====================================================================
        if showRetracementSection
            table.cell(statsTbl, 0, sRow, "Retracement Depth (Pre-Break)", text_size = hsz, text_color = sectionTextColor)
            sRow += 1
            fibBandTotal = 0
            for bIdx = 0 to array.size(statFibBandCounts) - 1
                fibBandTotal += array.get(statFibBandCounts, bIdx)
            for bIdx = 0 to array.size(statFibBandCounts) - 1
                bCount = array.get(statFibBandCounts, bIdx)
                bPct = fibBandTotal > 0 ? bCount / float(fibBandTotal) * 100.0 : na
                table.cell(statsTbl, 0, sRow, array.get(fibBandNames, bIdx), text_size = sz)
                table.cell(statsTbl, 1, sRow, str.tostring(bCount), text_size = sz)
                table.cell(statsTbl, 2, sRow, na(bPct) ? "-" : str.tostring(bPct, "#.#") + "%", text_size = sz)
                sRow += 1

    // =========================================================================
    // TRADE PLANNER - separate optional panel. Pure statistics summary, no
    // recommendations, no buy/sell arrows.
    // =========================================================================
    if showTradePlanner
        var table plannerTbl = table.new(tradePlannerPosVal, 2, 7, border_width = 1)
        pSz  = tradePlannerSizeVal
        pHsz = tradePlannerHeaderSizeVal
        table.cell(plannerTbl, 0, 0, "TRADE PLANNER", text_color = titleTextColor, text_size = pHsz)
        table.cell(plannerTbl, 1, 0, "", text_size = pHsz)
        table.cell(plannerTbl, 0, 1, "Bias", text_size = pSz)
        table.cell(plannerTbl, 1, 1, biasText, text_color = resultColor, text_size = pSz)
        table.cell(plannerTbl, 0, 2, "Breakout Probability", text_size = pSz)
        table.cell(plannerTbl, 1, 2, na(breakoutProbToday) ? "-" : str.tostring(breakoutProbToday, "#.##") + "%", text_size = pSz)
        table.cell(plannerTbl, 0, 3, "Target", text_size = pSz)
        table.cell(plannerTbl, 1, 3, primaryName, text_size = pSz)
        table.cell(plannerTbl, 0, 4, "Hit Probability", text_size = pSz)
        table.cell(plannerTbl, 1, 4, na(primaryHitPct) ? "-" : str.tostring(primaryHitPct, "#.##") + "%", text_size = pSz)
        table.cell(plannerTbl, 0, 5, "Extension", text_size = pSz)
        table.cell(plannerTbl, 1, 5, secondName, text_size = pSz)
        table.cell(plannerTbl, 0, 6, "Hit Probability", text_size = pSz)
        table.cell(plannerTbl, 1, 6, na(secondHitPct) ? "-" : str.tostring(secondHitPct, "#.##") + "%", text_size = pSz)

// =============================================================================
// FULL WEEK TABLE (optional) - same result + breakout-follow-through stats,
// bucketed by every calendar weekday. Kept as its own table (separate from the
// unified dashboard above) since its 6-column grid layout doesn't fit the
// dashboard's 2-3 column format. Only rendered when both Section: Day
// Statistics AND Show Full Week Table are on - otherwise the dashboard's
// Day Statistics section already shows today's weekday alone.
// "Follow-Through %" = of the sessions that day where a bias formed AND later
// broke one side or the other, how often did price confirm that bias (Low
// First -> broke High, or High First -> broke Low) rather than fail it.
// =============================================================================
if showDayStatsSection and showDowTable and barstate.islast
    var table dowTbl = table.new(dowTablePosVal, 6, 6, border_width = 1)
    dsz  = dowTableSizeVal
    dhsz = dowTableHeaderSizeVal
    table.cell(dowTbl, 0, 0, "DAY-OF-WEEK", text_color = color.new(color.blue, 0), text_size = dhsz)
    table.cell(dowTbl, 1, 0, "Bias", text_color = chart.fg_color, text_size = dhsz)
    table.cell(dowTbl, 2, 0, "Low%", text_color = chart.fg_color, text_size = dhsz)
    table.cell(dowTbl, 3, 0, "High%", text_color = chart.fg_color, text_size = dhsz)
    table.cell(dowTbl, 4, 0, "Low FT%", text_color = chart.fg_color, text_size = dhsz)
    table.cell(dowTbl, 5, 0, "High FT%", text_color = chart.fg_color, text_size = dhsz)
    for d = 1 to 5  // Monday(1) .. Friday(5) only - Sunday/Saturday dropped (no data on most instruments, pure clutter)
        n = array.get(dowSessions, d)
        dLowFirst  = array.get(dowLowFirst, d)
        dHighFirst = array.get(dowHighFirst, d)
        dLowPct  = n > 0 ? (dLowFirst  / float(n)) * 100.0 : na
        dHighPct = n > 0 ? (dHighFirst / float(n)) * 100.0 : na
        // Low-first follow-through: of Low-first sessions that later broke a side, how often did they break the High (confirming the LONG bias)
        dLowFollowTotal = array.get(dowLowFirst_BrokeHigh, d) + array.get(dowLowFirst_BrokeLow, d)
        dLowFollowPct   = dLowFollowTotal > 0 ? (array.get(dowLowFirst_BrokeHigh, d) / float(dLowFollowTotal)) * 100.0 : na
        // High-first follow-through: of High-first sessions that later broke a side, how often did they break the Low (confirming the SHORT bias)
        dHighFollowTotal = array.get(dowHighFirst_BrokeHigh, d) + array.get(dowHighFirst_BrokeLow, d)
        dHighFollowPct   = dHighFollowTotal > 0 ? (array.get(dowHighFirst_BrokeLow, d) / float(dHighFollowTotal)) * 100.0 : na

        // --- Plain-English verdict ---
        // 1) Find the dominant formation side (whichever forms first more often).
        //    If it's close to a 50/50 split (within 5pts), there's no real
        //    dominant side, so fall back to whichever follow-through is stronger.
        // 2) A verdict only "counts" as directional if the dominant side's own
        //    follow-through is at least 60% (a real lean, not a coin flip) -
        //    otherwise the day is labeled Choppy: the obvious pattern forms but
        //    doesn't reliably continue, so it's not a clean bullish/bearish read.
        shareDiff = (na(dLowPct) or na(dHighPct)) ? na : dLowPct - dHighPct
        useShareDiff = not na(shareDiff) and math.abs(shareDiff) > 5
        // Pine disallows `na` as a ternary/if condition, so na cases are
        // resolved with explicit if/else guards rather than chained `?:`.
        domIsLow = true
        if useShareDiff
            domIsLow := shareDiff > 0
        else if na(dLowFollowPct) and na(dHighFollowPct)
            domIsLow := true  // arbitrary - domConfirm below will be na either way
        else if na(dLowFollowPct)
            domIsLow := false
        else if na(dHighFollowPct)
            domIsLow := true
        else
            domIsLow := dLowFollowPct >= dHighFollowPct
        domConfirm = domIsLow ? dLowFollowPct : dHighFollowPct
        dayVerdict = na(domConfirm) ? "-" : domConfirm >= 60 ? (domIsLow ? "Bullish" : "Bearish") : "Choppy"
        dayVerdictColor = dayVerdict == "Bullish" ? colorLowFirst : dayVerdict == "Bearish" ? colorHighFirst : colorNeutral

        dayLabel = f_dayName(d) + " (" + str.tostring(n) + ")"
        table.cell(dowTbl, 0, d, dayLabel, text_size = dsz)
        table.cell(dowTbl, 1, d, dayVerdict, text_color = dayVerdictColor, text_size = dsz)
        table.cell(dowTbl, 2, d, na(dLowPct)  ? "-" : str.tostring(dLowPct, "#.#")  + "%", text_color = colorLowFirst,  text_size = dsz)
        table.cell(dowTbl, 3, d, na(dHighPct) ? "-" : str.tostring(dHighPct, "#.#") + "%", text_color = colorHighFirst, text_size = dsz)
        table.cell(dowTbl, 4, d, na(dLowFollowPct)  ? "-" : str.tostring(dLowFollowPct, "#.#")  + "%", text_color = colorLowFirst,  text_size = dsz)
        table.cell(dowTbl, 5, d, na(dHighFollowPct) ? "-" : str.tostring(dHighFollowPct, "#.#") + "%", text_color = colorHighFirst, text_size = dsz)

// =============================================================================
// NEW DAY DIVIDER + WEEKDAY LABELS
// =============================================================================
dayDividerHour   = hour(time, dayDividerTimezone)
dayDividerMinute = minute(time, dayDividerTimezone)

newDayStart = false
if dayStartOption == "Use Midnight"
    newDayStart := dayDividerHour == 0 and dayDividerMinute == 0
else if dayStartOption == "Use Digital Open"
    // Digital Open = 18:00 New York time (CME futures day rollover), checked in NY time regardless of the Timezone input above
    digitalOpenHour   = hour(time, "America/New_York")
    digitalOpenMinute = minute(time, "America/New_York")
    newDayStart := digitalOpenHour == 18 and digitalOpenMinute == 0

// bgcolor() paints the full height of the pane for this bar without ever
// participating in price-scale autoscaling - unlike line.new (even with a
// "safe" computed range), which can still stretch the axis on instruments/
// timeframes where the recent high/low happens to span a wide range. This is
// the only approach that's guaranteed never to distort the scale again.
bgcolor(newDayStart ? dividerColor : na, title = "New Day Divider")

plotchar(showDOW ? hour == dowLabelOffset and minute == 0 and dayofweek == dayofweek.monday    : false, offset = 0, char = " ", text = "Monday",    color = color.new(dowMonColor, 0), location = dowLabelLoc, textcolor = dowMonColor, editable = false)
plotchar(showDOW ? hour == dowLabelOffset and minute == 0 and dayofweek == dayofweek.tuesday   : false, offset = 0, char = " ", text = "Tuesday",   color = color.new(dowLabelColor, 0), location = dowLabelLoc, textcolor = dowLabelColor, editable = false)
plotchar(showDOW ? hour == dowLabelOffset and minute == 0 and dayofweek == dayofweek.wednesday : false, offset = 0, char = " ", text = "Wednesday", color = color.new(dowLabelColor, 0), location = dowLabelLoc, textcolor = dowLabelColor, editable = false)
plotchar(showDOW ? hour == dowLabelOffset and minute == 0 and dayofweek == dayofweek.thursday  : false, offset = 0, char = " ", text = "Thursday",  color = color.new(dowLabelColor, 0), location = dowLabelLoc, textcolor = dowLabelColor, editable = false)
plotchar(showDOW ? hour == dowLabelOffset and minute == 0 and dayofweek == dayofweek.friday    : false, offset = 0, char = " ", text = "Friday",    color = color.new(dowLabelColor, 0), location = dowLabelLoc, textcolor = dowLabelColor, editable = false)

// =============================================================================
// ALERTS - fire exactly once, on the bar the IB session finalizes
// =============================================================================
alertcondition(ibFinalized, title = "IB Completed", message = "Initial Balance session has completed and is now frozen.")
alertcondition(ibFinalized and lowFormedFirst,  title = "Low Formed First",  message = "Initial Balance: LOW formed first.")
alertcondition(ibFinalized and highFormedFirst, title = "High Formed First", message = "Initial Balance: HIGH formed first.")

if ibFinalized
    alert("IB Completed: " + resultText, alert.freq_once_per_bar)
````
