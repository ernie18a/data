# HTF Strat Bars w/stops [Market Breakers]

- url: https://www.tradingview.com/script/llBIh53A-HTF-Strat-Bars-w-stops-Market-Breakers/
- type: indicator
- pine_id: PUB;b4d3e36678104dbf8dad3a9dd2fb3e38
- version: 1.0

## Description

HTF Strat Bars w/stops [Market Breakers]

OVERVIEW
HTF Strat Bars w/stops puts up to four higher-timeframe candle panels on the right side of your chart. Each HTF bar is classified with The Strat numbering, and the script reads the active Strat combo on each timeframe. For every actionable or triggered setup it plots the entry, target and stop, calculates risk-to-reward, and adds a 50% stop when the standard stop gives a poor R:R. A summary table shows each timeframe's pattern and status, a weighted multi-timeframe bias, and Full Timeframe Continuity (FTFC).

The goal is to see the whole Strat picture across your timeframes, with trade levels already mapped, without flipping between charts.

HOW IT WORKS

HTF aggregation
HTF candles are built directly from the chart's own bars instead of request.security(). Each panel stays in sync with the chart, and the high/low of every HTF bar is traced back to the chart bar where it printed. Chart levels are anchored there. Each HTF must be higher than the chart timeframe. Intraday HTFs must also be an exact multiple of it. Invalid timeframes are skipped. Only standard chart types are supported.

Strat classification
Every HTF bar is compared to the bar before it:
- 1 = inside bar (took neither side)
- 2U = took the prior high only
- 2D = took the prior low only
- 3 = outside bar (took both sides)
Equal highs/lows count as "not taken."

In the panels, C1 and C2 are the last two closed HTF bars and C3 is the live bar.

Setup states
Each timeframe is in one of these states:

- Actionable — the last closed HTF bar is a 1 and the live bar hasn't broken it yet. Entry is the 1's high or low.
   - 2-1-1 / 3-1-1: target is the bar before the first 1 (both sides on 2-1-1, reversal side on 3-1-1)
   - 3-2-1 / 1-2-1: reversal side, target is the bar before the 2
   - Optional extras (off by default): 2-2-1, 3-1, and the continuation side of 3-1-1 / X-2-1

- In force — the live HTF bar is the trigger.
   - 2-1-2 / 3-1-2: entry is the 1, target is the bar before the 1
   - 2-1-1-2 / 3-1-1-2 / 3-2-1-2 / 1-2-1-2: triggered actionables, keeping their original target
   - 1-2-2 RevStrat: entry is the first 2, target is the bar before the 1
   - 3-2-2 Rev: entry is the first 2, target is the 3
   - 2-2 Rev: entry is the first 2, target is the bar before it
   - 2-2 Cont / 1-2: entry only, no target
   - 1-3: the live bar went outside after a 1; direction follows its candle color

- Watch — the live bar is still inside a closed 2. The script shows (faded) the 1-2-2 / 3-2-2 / 2-2 Rev trigger that would fire if that 2 is reversed. It's a heads-up only. It isn't actionable and doesn't count toward the bias.

- Target hit — the in-force setup reached its target.
- Outside — the live bar is a 3 (both sides taken).
- Watching — no qualifying combo.

Stops and R:R
- S1 (standard stop) is the opposite side of the trigger bar. Bull stop = trigger bar's low, bear stop = trigger bar's high. On the HTF, an in-force 2 can't reach its stop without becoming a 3, so a stop-out shows as "Outside."
- R:R = (entry → target) ÷ (entry → S1).
- S2 (50% stop) appears only when the S1 trade is below your minimum R:R (default 1:1). S2 sits at 50% of the trigger bar.
- If R:R is still below the minimum with S2, the setup is flagged SKIP in the table and alert.
- Setups with no target (1-2, 2-2 Cont) have no R:R and never get an S2.
- On two-sided actionable setups (2-1-1), each side's stop is the other side's entry, so no separate stop line is drawn. The table still lists both.

Bias and FTFC
- Bias is a weighted score of each timeframe's combo direction. Each HTF has its own weight (defaults 1/2/3/4, so higher timeframes count more). Two-sided setups, Watch and Watching count as neutral. The Agreement bar shows how much of the total weight points the same way.
- FTFC (Full Timeframe Continuity) shows when every enabled HTF's live candle is green, or every one is red.

WHAT'S ON THE CHART
- HTF panels: up to four panels (default 15m / 1h / 4h / D) with Strat-colored or direction-colored candles, Strat numbers under each bar, and the HTF name and current pattern above each panel with a status icon.
- Panel levels: entry (E), target (T), stop (S) and 50% stop (S2) lines, starting at the bar that defines each level.
- Prior HTF highs/lows: each panel can mark the highs and lows of its closed bars, optionally only the ones not yet taken. That's the resting liquidity price may reach for.
- FVG zones: optional shaded fair value gaps between panel bars.
- Chart levels (optional, per HTF): entry/target/stop lines on the main chart, anchored at the chart bar where each level printed, with tags like "1h E". They can hide automatically once the target is hit.
- Trigger marks: a label on the chart bar where an HTF combo first went in force. Checked on chart-bar close, one mark per HTF bar, and stacked when several timeframes trigger on the same bar.
- Chart bar coloring: optional Strat coloring of the chart's own bars (1 / 2U / 2D / 3).
- HTF1 separators: faint vertical lines marking each HTF1 bar open.

THE TABLE
- Bias, Agreement %, FTFC and a count of bull / bear / neutral combos
- Per-timeframe rows: pattern, status, and optionally the full combo sequence and Entry → Target · Stop · R:R
- The optional columns can be hidden for a narrower table on phone or tablet

HOW TO USE IT
1. Pick HTFs that are higher than your chart timeframe (and a multiple of it for intraday). A Daily panel on a 1–3m chart needs about 5 days of loaded history.
2. Read top-down. Use the higher-timeframe panels and the Bias/FTFC rows for direction, and the lower HTFs for timing.
3. Actionable (⏳) means a trigger level is set. In force (✅) means the trigger has fired. Target hit (🎯) means that setup has played out. Watch (👀) is a possible reversal to keep an eye on.
4. Check the R:R before acting. If S1 is under your minimum, the script shows the tighter S2. If it's flagged SKIP, the setup doesn't meet your R:R rule even with the tighter stop.
5. Turn on "Levels on chart" for the timeframe(s) you actually execute from, so the main chart doesn't get crowded.

ALERTS
- Detailed alerts: create an alert with "Any alert() function call." Each alert fires once per bar close when an HTF combo goes in force. The message includes the ticker, timeframe, pattern, entry, target, stop, R:R, and S2 / SKIP when it applies.
- Simple alert conditions: bullish combo in force, bearish combo in force, any combo in force, FTFC up, FTFC down.

SETTINGS (SUMMARY)
- HTF panels: timeframes, on/off, chart levels per HTF, bar style, color mode, bars shown, spacing and offset
- Actionable setups / In-force patterns: toggle each combo individually, plus the Watch hint
- Trigger marks: location, distance and stacking (ATR-based), colors, size, how many to keep
- Entry / target / stop levels: stops on/off, S2 and minimum R:R, hide levels after target hit, tag and price display, and separate line color/width/style for chart and panel levels
- Markings: label sizes, Strat numbers, C1–C3 tags, prior highs/lows, sweeps, FVGs, separators, chart bar coloring
- Colors: 1 / 2U / 2D / 3 colors, a light-chart option for 3s, custom border and wick
- Table: theme, size, position, optional columns, HTF weights, agreement bar length

NOTES AND LIMITATIONS
- Signals are evaluated on chart-bar close. The live HTF bar is still forming, so status, pattern and levels can change until that HTF bar closes.
- The first HTF bar on the chart may be partial and is excluded from the Strat reads.
- Works on standard chart types only (not Heikin Ashi, Renko, etc.).

CREDITS
This script is open source under the Mozilla Public License 2.0 and builds on:
- "HTF Fractal Bars [Herman]" by helmans13 (MPL 2.0): chart-bar HTF aggregation and the right-side panel concept
- "The Strat - Multi-Timeframe Combo Analyzer" by StonkTrader4 (MPL 2.0): Strat classification and combo rules
- The Strat methodology, created by Rob Smith

Added in this version: the actionable / in-force / watch combo engine with entry and target mapping, trigger-bar stops with R:R, the conditional 50% stop and SKIP flag, weighted multi-timeframe bias and FTFC, prior HTF high/low liquidity levels on the panels, chart-anchored level lines, trigger marks, and detailed alerts.

DISCLAIMER
This indicator is for educational and informational purposes only. It is not financial advice and does not guarantee results. Always use your own judgment and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © manny_mailbox2
//
// Built on:
//   • "HTF Fractal Bars [Herman]" © helmans13 (MPL 2.0) — chart-bar HTF aggregation + right-side panels
//   • "The Strat - Multi-Timeframe Combo Analyzer" © StonkTrader4 (MPL 2.0) — Strat classification & combo rules
//   • The Strat methodology by Rob Smith (@RobInTheBlack)

//@version=6
indicator("HTF Strat Bars w/stops [Market Breakers]", shorttitle = "HTF Strat Bars w/stops", overlay = true, max_lines_count = 500, max_boxes_count = 200, max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════
//                                 ABOUT
// ══════════════════════════════════════════════════════════════════════
// HTF candles are aggregated from the chart's own bars (no request.security()).
// C1 / C2 = last two CLOSED HTF bars, C3 = the LIVE HTF bar.
//
// Every HTF bar is classified against the bar before it:
//   1  = inside (did not take either side)      2U = took the high only
//   2D = took the low only                      3  = took both sides
//
// ACTIONABLE — last CLOSED HTF bar is a 1 and the live bar has not broken it yet.
//   Entry = the closed 1's high / low
//   2-1-1 / 3-1-1  Target = the bar before the first 1 (both sides for 2-1-1, reversal side for 3-1-1)
//   3-2-1 / 1-2-1  Reversal side, Target = the bar before the 2 (the 3 / the first 1)
//   Extras (off by default): 2-2-1, 3-1, continuation sides
//
// IN FORCE — the live HTF bar is the trigger.
//   2-1-2 / 3-1-2   Entry = the 1          Target = bar before the 1
//   2-1-1-2 / 3-1-1-2 / 3-2-1-2 / 1-2-1-2  triggered actionables, keep the actionable target
//   1-2-2 RevStrat  Entry = the first 2    Target = bar before the 1
//   3-2-2 Rev       Entry = the first 2    Target = the 3
//   2-2 Rev         Entry = the first 2    Target = bar before the first 2
//   2-2 Cont / 1-2  Entry = prior bar      no target (per the in-force sheet)
//   1-3             live bar is a 3 after a 1, direction = its candle color
//
// STOP — the opposite side of the trigger bar (the bar the entry comes off).
//   Bull stop = trigger bar's low, Bear stop = trigger bar's high.
//   On the HTF, an in-force 2 cannot reach its stop without becoming a 3, so a stop-out
//   shows as "Outside".
// S2 (50% STOP) — only when the S1 trade is under the minimum R:R (default 1:1).
//   S2 = 50% of the trigger bar. If R:R is still under the minimum with S2, the setup is flagged SKIP.
//   Setups with no target (1-2, 2-2 Cont) have no R:R, so they never get an S2.
//
// WATCH (hint) — live bar still inside a closed 2: shows the 1-2-2 / 3-2-2 / 2-2 Rev trigger
//   that would fire if the 2 is reversed. Not actionable, not scored in the bias.
//
// Status per HTF: Actionable · Watch · In force · Target hit · Outside (3) · Watching
//
// FTFC = Full Timeframe Continuity: every enabled HTF's live candle is green (or red).

// ══════════════════════════════════════════════════════════════════════
//                            INPUT GROUPS
// ══════════════════════════════════════════════════════════════════════
string G_PANELS = "01 | HTF panels"
string G_STRAT  = "02c | Trigger marks"
string G_LEVELS = "03 | Entry / target / stop levels"
string G_MARKS  = "04 | Markings"
string G_STYLE  = "05 | Colors"
string G_TABLE  = "06 | Strat table"

// ══════════════════════════════════════════════════════════════════════
//                               INPUTS
// ══════════════════════════════════════════════════════════════════════
bool   showHTF1 = input.bool(true,  "HTF1", inline = "h1", group = G_PANELS)
string htf1     = input.timeframe("15", "", inline = "h1", group = G_PANELS)
bool   lvlHTF1  = input.bool(true,  "Levels on chart", inline = "h1", group = G_PANELS)
bool   showHTF2 = input.bool(true,  "HTF2", inline = "h2", group = G_PANELS)
string htf2     = input.timeframe("60", "", inline = "h2", group = G_PANELS)
bool   lvlHTF2  = input.bool(false,  "Levels on chart", inline = "h2", group = G_PANELS)
bool   showHTF3 = input.bool(true,  "HTF3", inline = "h3", group = G_PANELS)
string htf3     = input.timeframe("240", "", inline = "h3", group = G_PANELS)
bool   lvlHTF3  = input.bool(false,  "Levels on chart", inline = "h3", group = G_PANELS)
bool   showHTF4 = input.bool(true, "HTF4", inline = "h4", group = G_PANELS)
string htf4     = input.timeframe("D", "", inline = "h4", group = G_PANELS)
bool   lvlHTF4  = input.bool(false, "Levels on chart", inline = "h4", group = G_PANELS, tooltip = "Each HTF must be higher than the chart timeframe (and an exact multiple of it for intraday HTFs). Invalid timeframes are skipped. A Daily panel on a 1-3m chart needs ~5 days of loaded history and will compress the price scale, so HTF4 is off by default.")

string barStyle    = input.string("Candles", "Bar style", options = ["Candles", "OHLC bars"], group = G_PANELS)
string colorMode   = input.string("Strat type", "Bar colors", options = ["Strat type", "Candle direction"], group = G_PANELS)
int    barsShown   = input.int(5, "Bars shown", minval = 3, maxval = 8, group = G_PANELS)
int    panelOffset = input.int(30, "Right offset", minval = 3, maxval = 150, group = G_PANELS, tooltip = "Distance in chart bars between the last bar and the first panel. Raise it if the chart level price tags overlap the panels.")
int    barSpacing  = input.int(6, "Bar spacing", minval = 4, maxval = 15, group = G_PANELS)
int    tickWidth   = input.int(1, "Body / tick half-width", minval = 1, maxval = 4, group = G_PANELS)
int    panelGap    = input.int(8, "Gap between HTFs", minval = 2, maxval = 30, group = G_PANELS)
bool   showHTFNames     = input.bool(true, "HTF name above panel", group = G_PANELS)
bool   showPanelPattern = input.bool(true, "Pattern name above panel", group = G_PANELS)

string G_ACT = "02a | Actionable setups (closed 1, not triggered)"
bool showSetups = input.bool(true, "Show actionable setups", group = G_ACT)
bool use211     = input.bool(true,  "2-1-1", inline = "a1", group = G_ACT)
bool use311     = input.bool(true,  "3-1-1", inline = "a1", group = G_ACT)
bool use321     = input.bool(true,  "3-2-1", inline = "a2", group = G_ACT)
bool use121     = input.bool(true,  "1-2-1", inline = "a2", group = G_ACT)
bool use221     = input.bool(false, "2-2-1 (extra)", inline = "a3", group = G_ACT)
bool use31      = input.bool(false, "3-1 (extra)", inline = "a3", group = G_ACT)
bool actCont    = input.bool(false, "Continuation side of 3-1-1 / X-2-1 (extra)", group = G_ACT, tooltip = "The actionable sheet only shows the reversal side of 3-1-1, 3-2-1 and 1-2-1. Turn on to also show the continuation trigger (targets the 2 or the 3). 2-1-1 always shows both sides, as on the sheet.")

string G_IF = "02b | In-force patterns (triggered)"
bool use212     = input.bool(true, "2-1-2", inline = "f1", group = G_IF)
bool use312     = input.bool(true, "3-1-2", inline = "f1", group = G_IF)
bool use322     = input.bool(true, "3-2-2", inline = "f1", group = G_IF)
bool use122     = input.bool(true, "1-2-2 RevStrat", inline = "f2", group = G_IF)
bool use22      = input.bool(true, "2-2 Rev", inline = "f2", group = G_IF)
bool use22c     = input.bool(true, "2-2 Cont", inline = "f2", group = G_IF)
bool use12      = input.bool(true, "1-2", inline = "f3", group = G_IF)
bool use13      = input.bool(true, "1-3", inline = "f3", group = G_IF, tooltip = "1-2, 1-3 and 2-2 Cont have no target on the in-force sheet, so they show an entry only. A 1-3's direction follows the live 3's candle color. Triggered 2-1-1 / 3-1-1 / 3-2-1 / 1-2-1 setups keep their actionable target and are named 2-1-1-2, 3-1-1-2, 3-2-1-2, 1-2-1-2.")
bool showWatch  = input.bool(true, "Watch hint: reversal trigger of a closed 2", group = G_IF, tooltip = "1-2-2, 3-2-2 and 2-2 Rev start from a closed 2, so they have no actionable stage. While the live bar is still inside that 2, the status shows Watch with the reversal entry / target (faded). It does not count toward the bias score and is not an actionable setup.")
bool watchChart = input.bool(false, "Watch levels on main chart", group = G_IF)
bool showTrigMarks = input.bool(true, "Mark HTF combo triggers on chart", group = G_STRAT, tooltip = "A label on the chart bar where an HTF combo first went in force. Evaluated on chart-bar close, one mark per HTF bar.")
int    maxMarks    = input.int(10, "Trigger marks retained", minval = 1, maxval = 100, group = G_STRAT)
bool   markTwoLine = input.bool(true, "Two-line label (TF / pattern)", group = G_STRAT)
string markPos     = input.string("Automatic", "Location", options = ["Automatic", "Above bar", "Below bar"], group = G_STRAT, tooltip = "Automatic puts bullish marks below the bar and bearish marks above.")
float  markDist    = input.float(7, "Distance from wick (× ATR)", minval = 0, maxval = 20, step = 0.1, group = G_STRAT, tooltip = "How far the mark sits from the high / low of the trigger bar, in multiples of the chart's ATR(14). Raise it to lift marks clear of the wicks.")
float  markStack   = input.float(1.5, "Stack spacing (× ATR)", minval = 0.2, maxval = 20, step = 0.1, group = G_STRAT, tooltip = "When two or more HTFs trigger on the same chart bar, each extra mark is pushed this much further out so they don't sit on top of each other.")
color  markBullCol = input.color(color.rgb(22, 110, 74), "Label  Bull", inline = "mc", group = G_STRAT)
color  markBearCol = input.color(color.rgb(136, 30, 28), "Bear", inline = "mc", group = G_STRAT)
int    markTransp  = input.int(15, "Label transparency", minval = 0, maxval = 100, group = G_STRAT)
color  markTxtCol  = input.color(#ffffff, "Font color", inline = "mt", group = G_STRAT)
string markSize    = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "mt", group = G_STRAT, tooltip = "In Pine the label box always sizes itself to the text, so this one setting scales both the font and the label.")

bool   lvlPanel   = input.bool(true, "Entry / target on panels", group = G_LEVELS)
bool   showStops  = input.bool(true, "Show stops", group = G_LEVELS, tooltip = "Stop = the opposite side of the trigger bar (the bar the entry comes off). Bull: the trigger bar's low. Bear: its high. On two-sided actionable setups (2-1-1) each side's stop is the other side's entry, so no separate stop line is drawn there; the table still lists both.")
bool   showStop2  = input.bool(true, "50% stop (S2) when R:R is under", inline = "s2", group = G_LEVELS, active = showStops)
float  rrMin      = input.float(1.0, "", minval = 0.1, maxval = 10, step = 0.1, inline = "s2", group = G_LEVELS, active = showStops, tooltip = "When entry → target divided by entry → S1 is below this, S2 is drawn at 50% of the trigger bar. If the trade is still below this with S2, the table flags it SKIP. Setups with no target (1-2, 2-2 Cont) have no R:R and never get an S2.")
bool   hideHit    = input.bool(true, "Hide chart levels once target is hit", group = G_LEVELS)
bool   showLvlLbl = input.bool(true, "Chart level tags", inline = "tag", group = G_LEVELS)
bool   showLvlPx  = input.bool(true, "Price in tag", inline = "tag", group = G_LEVELS, tooltip = "Chart level tags show the HTF and E / T / S (e.g. \"1h E\"). Untick Price in tag to drop only the price, the TF and letter stay.")
color  chEntryCol = input.color(color.rgb(54, 191, 201), "Chart entry ", inline = "ce", group = G_LEVELS)
int    chEntryW   = input.int(2, "", minval = 1, maxval = 5, inline = "ce", group = G_LEVELS)
string chEntrySty = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "ce", group = G_LEVELS)
color  chTgtCol   = input.color(color.rgb(48, 171, 202), "Chart target", inline = "ct", group = G_LEVELS)
int    chTgtW     = input.int(2, "", minval = 1, maxval = 5, inline = "ct", group = G_LEVELS)
string chTgtSty   = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "ct", group = G_LEVELS)
color  chStopCol  = input.color(#ff5252, "Chart stop  ", inline = "cs", group = G_LEVELS)
int    chStopW    = input.int(2, "", minval = 1, maxval = 5, inline = "cs", group = G_LEVELS)
string chStopSty  = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], inline = "cs", group = G_LEVELS)
color  chStop2Col = input.color(#ff9800, "Chart S2    ", inline = "cs2", group = G_LEVELS)
int    chStop2W   = input.int(2, "", minval = 1, maxval = 5, inline = "cs2", group = G_LEVELS)
string chStop2Sty = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "cs2", group = G_LEVELS)
color  pnEntryCol = input.color(color.rgb(135, 21, 241), "Panel entry ", inline = "pe", group = G_LEVELS)
int    pnEntryW   = input.int(2, "", minval = 1, maxval = 5, inline = "pe", group = G_LEVELS)
string pnEntrySty = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "pe", group = G_LEVELS)
color  pnTgtCol   = input.color(color.rgb(135, 21, 241), "Panel target", inline = "pt", group = G_LEVELS)
int    pnTgtW     = input.int(2, "", minval = 1, maxval = 5, inline = "pt", group = G_LEVELS)
string pnTgtSty   = input.string("Dotted", "", options = ["Solid", "Dashed", "Dotted"], inline = "pt", group = G_LEVELS)
color  pnStopCol  = input.color(color.rgb(196, 35, 57), "Panel stop  ", inline = "ps", group = G_LEVELS)
int    pnStopW    = input.int(2, "", minval = 1, maxval = 5, inline = "ps", group = G_LEVELS)
string pnStopSty  = input.string("Solid", "", options = ["Solid", "Dashed", "Dotted"], inline = "ps", group = G_LEVELS)
color  pnStop2Col = input.color(#ff9800, "Panel S2    ", inline = "ps2", group = G_LEVELS)
int    pnStop2W   = input.int(2, "", minval = 1, maxval = 5, inline = "ps2", group = G_LEVELS)
string pnStop2Sty = input.string("Dashed", "", options = ["Solid", "Dashed", "Dotted"], inline = "ps2", group = G_LEVELS)
string pnTagSize  = input.string("Small", "Panel E / T / S tag size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_LEVELS)

string hdrLblSize    = input.string("Normal", "HTF name / pattern label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_MARKS)
string barLblSize    = input.string("Small", "2U / 2D / C1-C3 label size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_MARKS)
float  lblGap        = input.float(0.8, "Label gap from wick", minval = 0, maxval = 10, step = 0.1, group = G_MARKS, tooltip = "Space between a candle's wick and its labels (below the low for 2U / 2D / C tags, above the panel high for the HTF name / pattern). Labels are anchored by their edge, so bigger label sizes grow away from the wick instead of into it.")
bool showStratNums   = input.bool(true, "Strat numbers under panel bars", group = G_MARKS)
bool showMarks       = input.bool(false, "C1 / C2 / C3 tags", group = G_MARKS)
string G_PL = "04a | Prior HTF highs / lows (panel levels)"
bool   showPanelLevels = input.bool(true, "Show prior highs / lows", group = G_PL, tooltip = "The panel equivalent of flipping to each HTF and marking its highs and lows. Drawn on the panels only, so they never collide with the entry / target levels on the main chart.")
string plScope   = input.string("All closed bars", "Mark", options = ["All closed bars", "C1 / C2 only"], group = G_PL, active = showPanelLevels)
bool   plUntaken = input.bool(true, "Only levels not yet taken", group = G_PL, active = showPanelLevels, tooltip = "A high is dropped once any later HTF bar in the panel (including the live bar) trades above it; a low once any later bar trades below it. What's left is the liquidity still resting — the levels price is likely to reach for.")
bool   plExtend  = input.bool(true, "Extend to E / T line length", group = G_PL, active = showPanelLevels, tooltip = "Off = short stub next to the candle.")
color  plHighCol = input.color(#26a69a, "Highs", inline = "plc", group = G_PL, active = showPanelLevels)
color  plLowCol  = input.color(#26a69a, "Lows", inline = "plc", group = G_PL, active = showPanelLevels)
int    plWidth   = input.int(2, "Width", minval = 1, maxval = 4, inline = "pls", group = G_PL, active = showPanelLevels)
string plStyle   = input.string("Dotted", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "pls", group = G_PL, active = showPanelLevels)
bool showSweeps      = input.bool(false, "Subtle sweep lines", group = G_MARKS)
bool showGaps        = input.bool(true, "Grey FVG zones", group = G_MARKS)
bool showSeparators  = input.bool(true, "HTF1 subtle separators", group = G_MARKS)
int  separatorCount  = input.int(20, "HTF1 separators retained", minval = 1, maxval = 100, group = G_MARKS)
bool colorChartBars  = input.bool(true, "Color chart bars by Strat type", group = G_MARKS, tooltip = "Leave off if Manny's Strat Indi is already coloring bars.")

color col1         = input.color(#4a4d57, "1 (Inside)", inline = "sc1", group = G_STYLE)
color col3         = input.color(#ffffff, "3 (Outside)", inline = "sc1", group = G_STYLE)
bool  swap3Light   = input.bool(false, "Swap 3 color on light charts", inline = "sw", group = G_STYLE)
color col3Light    = input.color(#2457a6, "", inline = "sw", group = G_STYLE)
string edgeApply   = input.string("All bars", "Custom border / wick on", options = ["3s only", "All bars", "Off"], group = G_STYLE, tooltip = "3s only: white 3s get the border / wick color below for contrast, every other bar keeps its body color. All bars: every panel candle uses them. Off: border and wick match the body.")
color candleBorder = input.color(#000000, "Border", inline = "bw", group = G_STYLE)
color candleWick   = input.color(#000000, "Wick", inline = "bw", group = G_STYLE)
color col2u        = input.color(color.rgb(28, 129, 87), "2U", inline = "sc2", group = G_STYLE)
color col2d        = input.color(color.rgb(145, 36, 34), "2D", inline = "sc2", group = G_STYLE)
color neutralColor = input.color(#9298a1, "Neutral / text", group = G_STYLE)
color levelColor   = input.color(#9298a1, "Levels / separators", group = G_STYLE)
color gapColor     = input.color(color.rgb(44, 160, 141), "FVG grey", group = G_STYLE)
int   gapOpacity   = input.int(70, "FVG transparency", minval = 0, maxval = 100, group = G_STYLE)
int   lineWidth    = input.int(2, "Wick / OHLC line width", minval = 1, maxval = 3, group = G_STYLE)

bool   showTable  = input.bool(true, "Show table", group = G_TABLE)
bool   colCombo   = input.bool(false, "Combo column", inline = "cols", group = G_TABLE, active = showTable)
bool   colET      = input.bool(false, "Entry → Target column", inline = "cols", group = G_TABLE, active = showTable, tooltip = "Hide these to make the table narrower on a phone or tablet. Entry / target / stop levels are still drawn on the panels and chart.")
string tableTheme = input.string("Dark", "Theme", options = ["Dark", "Light"], group = G_TABLE)
string tableSize  = input.string("small", "Size", options = ["tiny", "small", "normal", "large"], group = G_TABLE)
string tablePos   = input.string(position.bottom_right, "Position", options = [position.top_right, position.middle_right, position.bottom_right, position.top_left, position.middle_left, position.bottom_left], group = G_TABLE)
int    w1         = input.int(1, "Weight  HTF1", minval = 0, maxval = 10, inline = "w", group = G_TABLE, active = showTable)
int    w2         = input.int(2, "HTF2", minval = 0, maxval = 10, inline = "w", group = G_TABLE, active = showTable)
int    w3         = input.int(3, "HTF3", minval = 0, maxval = 10, inline = "w2", group = G_TABLE, active = showTable)
int    w4         = input.int(4, "HTF4", minval = 0, maxval = 10, inline = "w2", group = G_TABLE, active = showTable, tooltip = "Weight of each HTF's combo direction in the bias score. Two-sided setups and Watching count as neutral.")
int    barSegs    = input.int(10, "Progress bar segments", minval = 5, maxval = 20, group = G_TABLE, active = showTable)

// ══════════════════════════════════════════════════════════════════════
//                               PALETTE
// ══════════════════════════════════════════════════════════════════════
var color c_green = na
var color c_red   = na
var color c_nbg   = na
var color c_ntxt  = na
var color c_hdr   = na
var color c_dhdr  = na
var color c_sep   = na

if tableTheme == "Dark"
    c_green := #29a071, c_red := #e54b4b
    c_nbg   := #1e222d, c_ntxt := #e0e0e0
    c_hdr   := #2a2e39, c_dhdr := #363a45
    c_sep   := #373a46
else
    c_green := #29a071, c_red := #e54b4b
    c_nbg   := #f7f7f7, c_ntxt := #1e2025
    c_hdr   := #e5eef7, c_dhdr := #dfe2f1
    c_sep   := #e1e4e6

color nbg2 = color.new(c_nbg, 50)

float chartBgLum = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
color col3Auto   = swap3Light and chartBgLum >= 128 ? col3Light : col3

f_lblSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.small

f_lineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

// ══════════════════════════════════════════════════════════════════════
//                              HELPERS
// ══════════════════════════════════════════════════════════════════════
font_sz(sz) =>
    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        =>           size.small

f_tfText(string tf) =>
    float sec = timeframe.in_seconds(tf)
    string result = tf
    if not na(sec)
        result := sec < 3600 ? str.tostring(sec / 60, "#") + "m" : sec < 86400 ? str.tostring(sec / 3600, "#.##") + "h" : tf
    result

f_isValidTf(string tf) =>
    float chartSec = timeframe.in_seconds()
    float tfSec = timeframe.in_seconds(tf)
    bool basic = chart.is_standard and not na(chartSec) and not na(tfSec) and tfSec > chartSec
    bool aligned = not basic ? false : tfSec >= 86400 or tfSec % chartSec == 0
    basic and aligned

f_stratColor(int s) =>
    s == 1 ? col1 : s == 3 ? col3Auto : s == 2 ? col2u : s == -2 ? col2d : neutralColor

f_dirColor(int d) =>
    d > 0 ? c_green : d < 0 ? c_red : c_ntxt

f_bar(float pct, int segs) =>
    int filled = na(pct) ? 0 : math.round(pct / 100.0 * segs)
    str.repeat("█", filled) + str.repeat("░", segs - filled)

f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

f_rr(float v) =>
    na(v) ? "—" : str.tostring(v, "#.##") + "R"

// ══════════════════════════════════════════════════════════════════════
//                             DATA MODEL
// ══════════════════════════════════════════════════════════════════════
type Candle
    int t
    int finish
    float o
    float h
    float l
    float c
    int highTime
    int lowTime
    int firstTime
    int lastTime
    int bars
    bool full

// Only the first candle in the chart's history can start mid-period, so only it is marked incomplete.
f_newCandle(int t, int finish, bool isFirst) =>
    Candle.new(t, finish, open, high, low, close, time, time, time, time, 1, not isFirst and time_close <= finish)

method absorb(Candle a) =>
    if high > a.h
        a.h := high
        a.highTime := time
    if low < a.l
        a.l := low
        a.lowTime := time
    a.c := close
    a.lastTime := time
    a.bars := a.bars + 1
    if time_close > a.finish
        a.full := false

// Strat number of bar `a` against the bar before it: 1 inside, 2 = 2U, -2 = 2D, 3 outside, 0 unknown.
// Equal highs / lows count as "not taken", matching the chart-TF Strat indicator.
f_sn(Candle a, Candle p) =>
    int s = 0
    if not na(a) and not na(p)
        s := a.h > p.h and a.l < p.l ? 3 : a.h > p.h ? 2 : a.l < p.l ? -2 : 1
    s

f_ss(int s) =>
    s == 1 ? "1" : s == 3 ? "3" : s == 2 ? "2U" : s == -2 ? "2D" : "·"

// Table form: 1s and 3s carry their candle color as an arrow.
f_ssDir(int s, Candle a) =>
    string out = "–"
    if s == 2
        out := "2↑"
    else if s == -2
        out := "2↓"
    else if (s == 1 or s == 3) and not na(a)
        out := str.tostring(s) + (a.c >= a.o ? "↑" : "↓")
    out

// Direction of a bar: 2s by the side they broke, 1s / 3s by candle color.
f_dirOf(int s, Candle a) =>
    s == 2 ? true : s == -2 ? false : a.c >= a.o

// One HTF: its candles plus the current Strat read.
type Tf
    string tf
    string name
    bool show
    bool onChart
    int weight
    bool valid
    Candle live
    array<Candle> past
    int sL = 0
    int s1 = 0
    int s2 = 0
    int s3 = 0
    string pattern = ""
    int status = -1
    int dir = 0
    float eL = na
    float tL = na
    float eS = na
    float tS = na
    float stpL = na
    float stpS = na
    float stp2L = na
    float stp2S = na
    float rrL = na
    float rrS = na
    float rr2L = na
    float rr2S = na
    int eLB = 1
    int tLB = 2
    int eSB = 1
    int tSB = 2
    int firedT = 0

// back = 0 → live bar, 1 → last closed (C2), 2 → C1, ...
method getBar(Tf this, int back) =>
    Candle c = na
    if back == 0
        c := this.live
    else if this.past.size() >= back
        c := this.past.get(this.past.size() - back)
    c

// Aggregate the chart bar into this HTF. Returns true when a new HTF bar starts.
method update(Tf this, int t, int tEnd) =>
    bool isNew = false
    if this.show and this.valid and not na(t)
        bool first = na(this.live)
        bool rolled = true
        if not first
            rolled := t != this.live.t
        if rolled
            if not first
                if this.live.full
                    this.past.push(this.live)
                    if this.past.size() > 8
                        this.past.shift()
                else
                    this.past.clear()
            this.live := f_newCandle(t, tEnd, first)
            isNew := true
        else
            this.live.absorb()
    isNew

// ══════════════════════════════════════════════════════════════════════
//                          STRAT COMBO ENGINE
// ══════════════════════════════════════════════════════════════════════
// Every entry comes off p1 (the closed 1 or the first 2), so p1 is always the trigger bar:
// bull stop = p1.l, bear stop = p1.h.
method analyze(Tf this) =>
    this.pattern := ""
    this.status  := -1
    this.dir     := 0
    this.sL      := 0
    this.s1      := 0
    this.s2      := 0
    this.s3      := 0
    this.eL      := na
    this.tL      := na
    this.eS      := na
    this.tS      := na
    this.stpL    := na
    this.stpS    := na
    this.stp2L   := na
    this.stp2S   := na
    this.rrL     := na
    this.rrS     := na
    this.rr2L    := na
    this.rr2S    := na
    if this.show and this.valid and not na(this.live)
        Candle L  = this.live
        Candle p1 = this.getBar(1)
        Candle p2 = this.getBar(2)
        Candle p3 = this.getBar(3)
        Candle p4 = this.getBar(4)
        int sL = f_sn(L, p1)
        int s1 = f_sn(p1, p2)
        int s2 = f_sn(p2, p3)
        int s3 = f_sn(p3, p4)
        this.sL := sL
        this.s1 := s1
        this.s2 := s2
        this.s3 := s3
        if sL != 0 and s1 != 0
            this.status := 0
            bool twoL  = sL == 2 or sL == -2
            bool two1  = s1 == 2 or s1 == -2
            bool two2  = s2 == 2 or s2 == -2

            // ════════════════ IN FORCE: live HTF bar is the trigger 2 ════════════════
            if twoL
                bool   bull     = sL == 2
                string dTxt     = bull ? "Bull " : "Bear "
                string nm       = ""
                float  e        = na
                float  tg       = na
                int    tb       = 2
                bool   noTarget = false

                // ── The live bar broke a closed 1 (an actionable setup triggered) ──
                if s1 == 1
                    e := bull ? p1.h : p1.l
                    bool family = (s2 == 1 and (s3 == 2 or s3 == -2 or s3 == 3)) or s2 == 3 or two2
                    if s2 == 1 and (s3 == 2 or s3 == -2) and use211
                        nm := "2-1-1-2 " + dTxt + (f_dirOf(s3, p3) == bull ? "Cont" : "Rev")
                        tg := bull ? p3.h : p3.l
                        tb := 3
                    else if s2 == 1 and s3 == 3 and use311
                        nm := "3-1-1-2 " + dTxt + (f_dirOf(s3, p3) == bull ? "Cont" : "Rev")
                        tg := bull ? p3.h : p3.l
                        tb := 3
                    else if s2 == 3 and use312
                        nm := "3-1-2 " + dTxt + (f_dirOf(s2, p2) == bull ? "Cont" : "Rev")
                        tg := bull ? p2.h : p2.l
                    else if two2
                        bool revSide = (s2 == 2) != bull
                        if revSide and s3 == 3 and use321
                            nm := "3-2-1-2 " + dTxt + "Rev"
                            tg := bull ? p3.h : p3.l
                            tb := 3
                        else if revSide and s3 == 1 and use121
                            nm := "1-2-1-2 " + dTxt + "Rev"
                            tg := bull ? p3.h : p3.l
                            tb := 3
                        else if use212
                            nm := "2-1-2 " + dTxt + (revSide ? "Rev" : "Cont")
                            tg := bull ? p2.h : p2.l
                    if nm == "" and not family and use12
                        nm       := "1-2 " + dTxt + (f_dirOf(1, p1) == bull ? "Cont" : "Rev")
                        noTarget := true

                // ── The live bar reversed a closed 2 ──
                else if two1 and s1 != sL
                    e := bull ? p1.h : p1.l
                    if s2 == 1 and use122
                        nm := "1-2-2 RevStrat " + dTxt
                        tg := bull ? p3.h : p3.l
                        tb := 3
                    else if s2 == 3 and use322
                        nm := "3-2-2 " + dTxt + "Rev"
                        tg := bull ? p2.h : p2.l
                    else if s2 != 1 and s2 != 3 and use22
                        nm := "2-2 " + dTxt + "Rev"
                        tg := bull ? p2.h : p2.l

                // ── The live bar continued a closed 2 ──
                else if two1 and s1 == sL and use22c
                    e        := bull ? p1.h : p1.l
                    nm       := "2-2 " + dTxt + "Cont"
                    noTarget := true

                if nm != "" and (noTarget or (bull ? tg > e : tg < e))
                    this.pattern := nm
                    this.dir     := bull ? 1 : -1
                    this.status  := noTarget ? 2 : (bull ? L.h >= tg : L.l <= tg) ? 3 : 2
                    if bull
                        this.eL   := e
                        this.tL   := noTarget ? float(na) : tg
                        this.stpL := p1.l
                        this.eLB  := 1
                        this.tLB  := tb
                    else
                        this.eS   := e
                        this.tS   := noTarget ? float(na) : tg
                        this.stpS := p1.h
                        this.eSB  := 1
                        this.tSB  := tb

            // ════════════════ Live HTF bar took both sides ════════════════
            else if sL == 3
                if s1 == 1 and use13
                    bool b3 = L.c >= L.o
                    this.status  := 2
                    this.dir     := b3 ? 1 : -1
                    this.pattern := "1-3 " + (b3 ? "Bull" : "Bear") + " Rev"
                else
                    this.status  := 4
                    this.pattern := "3 · both sides taken"

            // ════════════════ ACTIONABLE: closed 1, live bar not triggered yet ════════════════
            else if showSetups and s1 == 1
                string nm   = ""
                float  lT   = na
                float  sT   = na
                int    lTb  = 2
                int    sTb  = 2
                string lTag = ""
                string sTag = ""

                // X-1-1 : entry = the last 1, target = the bar before the first 1
                if s2 == 1 and (s3 == 2 or s3 == -2) and use211
                    bool b3 = f_dirOf(s3, p3)
                    nm   := "2-1-1"
                    lT   := p3.h
                    sT   := p3.l
                    lTb  := 3
                    sTb  := 3
                    lTag := b3 ? "Cont" : "Rev"
                    sTag := b3 ? "Rev" : "Cont"
                else if s2 == 1 and s3 == 3 and use311
                    bool b3 = f_dirOf(s3, p3)
                    nm  := "3-1-1"
                    lTb := 3
                    sTb := 3
                    if not b3 or actCont
                        lT   := p3.h
                        lTag := b3 ? "Cont" : "Rev"
                    if b3 or actCont
                        sT   := p3.l
                        sTag := b3 ? "Rev" : "Cont"

                // X-2-1 : reversal side targets the bar before the 2 (3-2-1 / 1-2-1),
                //         2-2-1 reversal and every continuation side target the 2
                else if two2 and ((s3 == 3 and use321) or (s3 == 1 and use121) or ((s3 == 2 or s3 == -2) and use221))
                    bool  up    = s2 == 2
                    bool  far   = s3 == 3 or s3 == 1
                    float revT  = far ? (up ? p3.l : p3.h) : (up ? p2.l : p2.h)
                    int   revTb = far ? 3 : 2
                    nm := (s3 == 3 ? "3" : s3 == 1 ? "1" : "2") + "-2-1"
                    if up
                        sT   := revT
                        sTb  := revTb
                        sTag := "Rev"
                        if actCont
                            lT   := p2.h
                            lTag := "Cont"
                    else
                        lT   := revT
                        lTb  := revTb
                        lTag := "Rev"
                        if actCont
                            sT   := p2.l
                            sTag := "Cont"

                // 3-1 (extra, not on the actionable sheet) : targets the 3
                else if s2 == 3 and use31
                    bool b2 = f_dirOf(s2, p2)
                    nm   := "3-1"
                    lT   := p2.h
                    sT   := p2.l
                    lTag := b2 ? "Cont" : "Rev"
                    sTag := b2 ? "Rev" : "Cont"

                if nm != ""
                    if not na(lT) and lT > p1.h
                        this.eL   := p1.h
                        this.tL   := lT
                        this.stpL := p1.l
                        this.eLB  := 1
                        this.tLB  := lTb
                    if not na(sT) and sT < p1.l
                        this.eS   := p1.l
                        this.tS   := sT
                        this.stpS := p1.h
                        this.eSB  := 1
                        this.tSB  := sTb
                    bool hasL = not na(this.eL)
                    bool hasS = not na(this.eS)
                    if hasL or hasS
                        this.status  := 1
                        this.dir     := hasL and hasS ? 0 : hasL ? 1 : -1
                        this.pattern := hasL and hasS ? nm + "  ▲" + lTag + " ▼" + sTag : hasL ? nm + " Bull " + lTag : nm + " Bear " + sTag

            // ════════════════ WATCH: live bar inside a closed 2 — reversal trigger hint ════════════════
            else if showWatch and two1
                bool   bull = s1 == -2
                string dTxt = bull ? "Bull " : "Bear "
                string nm   = ""
                float  tg   = na
                int    tb   = 2
                if s2 == 1 and use122
                    nm := "1-2-2 RevStrat " + dTxt
                    tg := bull ? p3.h : p3.l
                    tb := 3
                else if s2 == 3 and use322
                    nm := "3-2-2 " + dTxt + "Rev"
                    tg := bull ? p2.h : p2.l
                else if s2 != 1 and s2 != 3 and use22
                    nm := "2-2 " + dTxt + "Rev"
                    tg := bull ? p2.h : p2.l
                float e = bull ? p1.h : p1.l
                if nm != "" and (bull ? tg > e : tg < e)
                    this.status  := 5
                    this.dir     := bull ? 1 : -1
                    this.pattern := nm + " watch"
                    if bull
                        this.eL   := e
                        this.tL   := tg
                        this.stpL := p1.l
                        this.eLB  := 1
                        this.tLB  := tb
                    else
                        this.eS   := e
                        this.tS   := tg
                        this.stpS := p1.h
                        this.eSB  := 1
                        this.tSB  := tb
    // ── R:R with S1, then the 50% stop (S2) when S1 is under the minimum ──
    // Entry and S1 are the trigger bar's two extremes, so their midpoint is the trigger bar's 50%.
    if not na(this.eL) and not na(this.tL) and not na(this.stpL) and this.eL > this.stpL
        this.rrL := (this.tL - this.eL) / (this.eL - this.stpL)
        if showStop2 and this.rrL < rrMin
            float mid = math.round_to_mintick((this.eL + this.stpL) / 2)
            if mid < this.eL
                this.stp2L := mid
                this.rr2L  := (this.tL - this.eL) / (this.eL - mid)
    if not na(this.eS) and not na(this.tS) and not na(this.stpS) and this.stpS > this.eS
        this.rrS := (this.eS - this.tS) / (this.stpS - this.eS)
        if showStop2 and this.rrS < rrMin
            float mid = math.round_to_mintick((this.eS + this.stpS) / 2)
            if mid > this.eS
                this.stp2S := mid
                this.rr2S  := (this.eS - this.tS) / (mid - this.eS)
    // Explicit return so Pine doesn't treat the if-chain above as the method's return value
    this.status

// ══════════════════════════════════════════════════════════════════════
//                             HTF OBJECTS
// ══════════════════════════════════════════════════════════════════════
var Tf h1 = Tf.new(tf = htf1, name = "HTF1", show = showHTF1, onChart = lvlHTF1, weight = w1, valid = f_isValidTf(htf1), past = array.new<Candle>())
var Tf h2 = Tf.new(tf = htf2, name = "HTF2", show = showHTF2, onChart = lvlHTF2, weight = w2, valid = f_isValidTf(htf2), past = array.new<Candle>())
var Tf h3 = Tf.new(tf = htf3, name = "HTF3", show = showHTF3, onChart = lvlHTF3, weight = w3, valid = f_isValidTf(htf3), past = array.new<Candle>())
var Tf h4 = Tf.new(tf = htf4, name = "HTF4", show = showHTF4, onChart = lvlHTF4, weight = w4, valid = f_isValidTf(htf4), past = array.new<Candle>())
var array<Tf> tfs = array.from(h1, h2, h3, h4)

bool new1 = h1.update(time(htf1), time_close(htf1))
bool new2 = h2.update(time(htf2), time_close(htf2))
bool new3 = h3.update(time(htf3), time_close(htf3))
bool new4 = h4.update(time(htf4), time_close(htf4))

for h in tfs
    h.analyze()

// HTF1 separators on the main chart
var array<line> separators = array.new<line>()
if new1 and showSeparators and not na(h1.live)
    separators.push(line.new(h1.live.t, low, h1.live.t, high + syminfo.mintick, xloc = xloc.bar_time, extend = extend.both, color = color.new(levelColor, 85), style = line.style_dotted))
    if separators.size() > separatorCount
        line.delete(separators.shift())

// ══════════════════════════════════════════════════════════════════════
//                      TRIGGERS, MARKS AND ALERTS
// ══════════════════════════════════════════════════════════════════════
bool bullTrig = false
bool bearTrig = false
var array<label> trigMarks = array.new<label>()

// Evaluated on chart-bar close only, once per HTF bar.
float chartATR = ta.atr(14)
int   nAbove   = 0
int   nBelow   = 0

if barstate.isconfirmed
    for h in tfs
        if h.show and (h.status == 2 or h.status == 3) and h.firedT != h.live.t
            h.firedT := h.live.t
            bool isBull = h.dir > 0
            bullTrig := bullTrig or isBull
            bearTrig := bearTrig or not isBull
            float e  = isBull ? h.eL : h.eS
            float tg = isBull ? h.tL : h.tS
            float st  = isBull ? h.stpL : h.stpS
            float st2 = isBull ? h.stp2L : h.stp2S
            float rr  = isBull ? h.rrL : h.rrS
            float rr2 = isBull ? h.rr2L : h.rr2S
            string riskTxt = (na(rr) ? "" : " (" + f_rr(rr) + ")") + (na(st2) ? "" : " | S2 " + f_px(st2) + " (" + f_rr(rr2) + ")" + (rr2 < rrMin ? " SKIP" : ""))
            if showTrigMarks
                bool   above = markPos == "Above bar" or (markPos == "Automatic" and not isBull)
                int    idx   = above ? nAbove : nBelow
                float  dist  = nz(chartATR, high - low) * (markDist + idx * markStack)
                float  y     = above ? high + dist : low - dist
                string txt   = f_tfText(h.tf) + (markTwoLine ? "\n" : " ") + h.pattern
                trigMarks.push(label.new(bar_index, y, txt, yloc = yloc.price, style = above ? label.style_label_down : label.style_label_up, color = color.new(isBull ? markBullCol : markBearCol, markTransp), textcolor = markTxtCol, size = f_lblSize(markSize), textalign = text.align_center))
                if above
                    nAbove += 1
                else
                    nBelow += 1
                if trigMarks.size() > maxMarks
                    label.delete(trigMarks.shift())
            alert(syminfo.ticker + " " + f_tfText(h.tf) + " " + h.pattern + " in force | E " + f_px(e) + " | T " + f_px(tg) + " | S " + f_px(st) + riskTxt, alert.freq_once_per_bar_close)

// ══════════════════════════════════════════════════════════════════════
//                     BIAS / FTFC (weighted agreement)
// ══════════════════════════════════════════════════════════════════════
int wSum    = 0
int score   = 0
int nActive = 0
int nBull   = 0
int nBear   = 0
int nLive   = 0
int nUp     = 0
int nDn     = 0
for h in tfs
    if h.show and h.valid and not na(h.live)
        nLive += 1
        nUp   += h.live.c > h.live.o ? 1 : 0
        nDn   += h.live.c < h.live.o ? 1 : 0
        if h.status >= 0
            nActive += 1
            wSum    += h.weight
            int d    = h.status == 5 ? 0 : h.dir
            score   += h.weight * d
            nBull   += d > 0 ? 1 : 0
            nBear   += d < 0 ? 1 : 0

float agreePct = wSum > 0 ? 100.0 * math.abs(score) / wSum : na
bool  ftfcUp   = nLive >= 2 and nUp == nLive
bool  ftfcDn   = nLive >= 2 and nDn == nLive

// ══════════════════════════════════════════════════════════════════════
//                        CHART BAR STRAT COLORS
// ══════════════════════════════════════════════════════════════════════
int chartS = na(high[1]) ? 0 : high > high[1] and low < low[1] ? 3 : high > high[1] ? 2 : low < low[1] ? -2 : 1
barcolor(colorChartBars and chartS != 0 ? f_stratColor(chartS) : na, title = "Strat bar color")

// ══════════════════════════════════════════════════════════════════════
//                          DRAWING HELPERS
// ══════════════════════════════════════════════════════════════════════
var array<line>  drawnLines  = array.new<line>()
var array<box>   drawnBoxes  = array.new<box>()
var array<label> drawnLabels = array.new<label>()

f_clearDrawings() =>
    while drawnLines.size() > 0
        line.delete(drawnLines.pop())
    while drawnBoxes.size() > 0
        box.delete(drawnBoxes.pop())
    while drawnLabels.size() > 0
        label.delete(drawnLabels.pop())

f_line(int x1, float y1, int x2, float y2, color c, string xs, string style, int width) =>
    drawnLines.push(line.new(x1, y1, x2, y2, xloc = xs, color = c, width = width, style = style))

f_box(int left, float top, int right, float bottom, color border, color fill, string xs) =>
    drawnBoxes.push(box.new(left, top, right, bottom, xloc = xs, border_color = border, border_width = 1, bgcolor = fill))

f_label(int x, float y, string message, color textColour, string xs, string labelSize) =>
    drawnLabels.push(label.new(x, y, message, xloc = xs, style = label.style_none, textcolor = textColour, size = labelSize, textalign = text.align_center))

// Text-only label anchored by its EDGE at y: above = text sits above y, otherwise below y.
// Larger sizes therefore grow away from the candle instead of into the wick.
f_tag(int x, float y, string message, color textColour, string labelSize, bool above) =>
    drawnLabels.push(label.new(x, y, message, xloc = xloc.bar_index, style = above ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = textColour, size = labelSize, textalign = text.align_center))

f_patternChartColor(Tf h) =>
    h.status == 5 ? color.new(h.dir > 0 ? col2u : col2d, 40) : h.dir > 0 ? col2u : h.dir < 0 ? col2d : h.status == 1 ? #f0b90b : neutralColor

// Level kinds: 0 = entry, 1 = target, 2 = stop (S1), 3 = 50% stop (S2)
f_kindLetter(int kind) =>
    kind == 0 ? "E" : kind == 1 ? "T" : kind == 2 ? "S" : "S2"

// Entry / target / stop line on a panel, starting at the bar that defines the level.
f_panelLevel(int left, int n, int back, float y, int right, int kind, bool faded) =>
    if not na(y)
        int    x1   = left + math.max(0, n - back) * barSpacing
        color  base = kind == 0 ? pnEntryCol : kind == 1 ? pnTgtCol : kind == 2 ? pnStopCol : pnStop2Col
        string sty  = kind == 0 ? pnEntrySty : kind == 1 ? pnTgtSty : kind == 2 ? pnStopSty : pnStop2Sty
        int    w    = kind == 0 ? pnEntryW : kind == 1 ? pnTgtW : kind == 2 ? pnStopW : pnStop2W
        color  c    = color.new(base, faded ? 55 : 0)
        f_line(x1, y, right, y, c, xloc.bar_index, f_lineStyle(sty), w)
        f_label(right + 2, y, f_kindLetter(kind), c, xloc.bar_index, f_lblSize(pnTagSize))

// Entry / target / stop line on the main chart, anchored at the time the level was printed.
f_chartLevel(Tf h, float y, int back, bool isHigh, int kind, string arrow, int x2) =>
    Candle src = h.getBar(back)
    if not na(src) and not na(y)
        int    x1   = isHigh ? src.highTime : src.lowTime
        color  base = kind == 0 ? chEntryCol : kind == 1 ? chTgtCol : kind == 2 ? chStopCol : chStop2Col
        string sty  = kind == 0 ? chEntrySty : kind == 1 ? chTgtSty : kind == 2 ? chStopSty : chStop2Sty
        int    w    = kind == 0 ? chEntryW : kind == 1 ? chTgtW : kind == 2 ? chStopW : chStop2W
        color  c    = color.new(base, h.status == 5 ? 55 : 0)
        f_line(x1, y, x2, y, c, xloc.bar_time, f_lineStyle(sty), w)
        if showLvlLbl
            string txt = f_tfText(h.tf) + " " + arrow + f_kindLetter(kind) + (showLvlPx ? " " + str.tostring(y, format.mintick) : "")
            drawnLabels.push(label.new(x2, y, txt, xloc = xloc.bar_time, style = label.style_label_left, color = c, textcolor = kind >= 2 ? color.white : color.black, size = size.tiny))

f_panel(Tf h, int left, float basePad) =>
    int sz = h.past.size()
    int n  = math.min(barsShown - 1, sz)
    array<Candle> items = array.new<Candle>()
    array<int>    sns   = array.new<int>()
    if n > 0
        for k = sz - n to sz - 1
            items.push(h.past.get(k))
    items.push(h.live)

    float hi = na
    float lo = na
    for k = 0 to items.size() - 1
        Candle a = items.get(k)
        Candle p = na
        if k > 0
            p := items.get(k - 1)
        else if sz - n - 1 >= 0
            p := h.past.get(sz - n - 1)
        sns.push(f_sn(a, p))
        hi := na(hi) ? a.h : math.max(hi, a.h)
        lo := na(lo) ? a.l : math.min(lo, a.l)
    float pp = math.max(basePad, (hi - lo) * 0.03)

    // FVG zones first so the bars stay on top.
    if showGaps and items.size() >= 3
        for k = 2 to items.size() - 1
            Candle a   = items.get(k)
            Candle old = items.get(k - 2)
            int x = left + k * barSpacing
            if a.l > old.h
                f_box(x - barSpacing, a.l, x + tickWidth, old.h, color.new(gapColor, 65), color.new(gapColor, gapOpacity), xloc.bar_index)
            if a.h < old.l
                f_box(x - barSpacing, old.l, x + tickWidth, a.h, color.new(gapColor, 65), color.new(gapColor, gapOpacity), xloc.bar_index)

    for k = 0 to items.size() - 1
        Candle a = items.get(k)
        int    s = sns.get(k)
        int    x = left + k * barSpacing
        bool   isLive = k == items.size() - 1
        color  c = colorMode == "Strat type" ? f_stratColor(s) : a.c > a.o ? col2u : a.c < a.o ? col2d : neutralColor

        bool   customEdge = edgeApply == "All bars" or (edgeApply == "3s only" and s == 3)
        color  edgeCol    = customEdge ? candleBorder : c
        color  wickCol    = customEdge ? candleWick : c

        if barStyle == "Candles"
            f_line(x, a.h, x, a.l, wickCol, xloc.bar_index, line.style_solid, lineWidth)
            f_box(x - tickWidth, math.max(a.o, a.c), x + tickWidth, math.min(a.o, a.c), edgeCol, isLive ? color.new(c, 45) : c, xloc.bar_index)
        else
            f_line(x, a.h, x, a.l, wickCol, xloc.bar_index, line.style_solid, lineWidth)
            f_line(x - tickWidth, a.o, x, a.o, wickCol, xloc.bar_index, line.style_solid, lineWidth)
            f_line(x, a.c, x + tickWidth, a.c, wickCol, xloc.bar_index, line.style_solid, lineWidth)

        // Prior HTF highs / lows on closed bars (the live bar's own range is still forming)
        if showPanelLevels and not isLive and (plScope == "All closed bars" or k >= n - 2)
            bool hiTaken = false
            bool loTaken = false
            if plUntaken
                for j = k + 1 to items.size() - 1
                    Candle later = items.get(j)
                    hiTaken := hiTaken or later.h > a.h
                    loTaken := loTaken or later.l < a.l
            int plRight = plExtend ? left + n * barSpacing + tickWidth + 2 : x + tickWidth + 2
            string sty  = f_lineStyle(plStyle)
            if not hiTaken
                f_line(x, a.h, plRight, a.h, plHighCol, xloc.bar_index, sty, plWidth)
            if not loTaken
                f_line(x, a.l, plRight, a.l, plLowCol, xloc.bar_index, sty, plWidth)

        string tag = k == n ? "C3" : k == n - 1 ? "C2" : k == n - 2 ? "C1" : ""
        string txt = showStratNums ? f_ss(s) : ""
        if showMarks and tag != ""
            txt := txt == "" ? tag : txt + "\n" + tag
        if txt != ""
            f_tag(x, a.l - pp * lblGap, txt, s == 1 or s == 0 or (s == 3 and chartBgLum >= 128) ? neutralColor : f_stratColor(s), f_lblSize(barLblSize), false)

        if showSweeps and k > 0
            Candle prev = items.get(k - 1)
            int prevX = x - barSpacing
            if a.h > prev.h and a.c <= prev.h
                f_line(prevX, prev.h, x, prev.h, color.new(levelColor, 45), xloc.bar_index, line.style_dotted, 1)
            if a.l < prev.l and a.c >= prev.l
                f_line(prevX, prev.l, x, prev.l, color.new(levelColor, 45), xloc.bar_index, line.style_dotted, 1)

    if lvlPanel and ((h.status >= 1 and h.status <= 3) or h.status == 5)
        int  right    = left + n * barSpacing + tickWidth + 2
        bool fade     = h.status == 5
        bool twoSided = not na(h.eL) and not na(h.eS)
        f_panelLevel(left, n, h.eLB, h.eL, right, 0, fade)
        f_panelLevel(left, n, h.tLB, h.tL, right, 1, fade)
        f_panelLevel(left, n, h.eSB, h.eS, right, 0, fade)
        f_panelLevel(left, n, h.tSB, h.tS, right, 1, fade)
        if showStops and not twoSided
            f_panelLevel(left, n, 1, h.stpL, right, 2, fade)
            f_panelLevel(left, n, 1, h.stpS, right, 2, fade)
            f_panelLevel(left, n, 1, h.stp2L, right, 3, fade)
            f_panelLevel(left, n, 1, h.stp2S, right, 3, fade)

    // Both header labels sit on the same anchor above the panel high. The pattern label carries
    // an extra blank (non-breaking space) line, which lifts it exactly one line above the HTF name
    // at any label size.
    int    centreX = left + int(n * barSpacing / 2)
    float  hy      = hi + pp * lblGap
    string hSize   = f_lblSize(hdrLblSize)
    if showHTFNames
        f_tag(centreX, hy, h.name + "  " + f_tfText(h.tf), neutralColor, hSize, true)
    if showPanelPattern and h.pattern != ""
        string st = h.status == 1 ? " ⏳" : h.status == 2 ? " ✅" : h.status == 3 ? " 🎯" : h.status == 5 ? " 👀" : ""
        f_tag(centreX, hy, h.pattern + st + (showHTFNames ? "\n " : ""), f_patternChartColor(h), hSize, true)

// ══════════════════════════════════════════════════════════════════════
//                               RENDER
// ══════════════════════════════════════════════════════════════════════
if barstate.islast
    f_clearDrawings()

    bool anyEnabled = showHTF1 or showHTF2 or showHTF3 or showHTF4
    bool anyValid   = (showHTF1 and h1.valid) or (showHTF2 and h2.valid) or (showHTF3 and h3.valid) or (showHTF4 and h4.valid)
    if anyEnabled and not anyValid
        string msg = chart.is_standard ? "HTF Strat Bars w/stops: select timeframes higher than, and a multiple of, the chart timeframe." : "HTF Strat Bars w/stops: standard chart types only."
        drawnLabels.push(label.new(bar_index, close, msg, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(chart.bg_color, 100), textcolor = chart.fg_color, size = size.small))

    float pad = math.max(nz(chartATR, high - low) * 0.10, syminfo.mintick * 10)

    // Main-chart entry / target / stop levels
    int rightTime = time_close + int(timeframe.in_seconds() * 1000 * 2)
    for h in tfs
        if h.show and h.valid and h.onChart and ((h.status >= 1 and h.status <= 3) or (h.status == 5 and watchChart)) and not (hideHit and h.status == 3)
            bool twoSided = not na(h.eL) and not na(h.eS)
            if not na(h.eL)
                f_chartLevel(h, h.eL, h.eLB, true, 0, twoSided ? "▲" : "", rightTime)
                f_chartLevel(h, h.tL, h.tLB, true, 1, twoSided ? "▲" : "", rightTime)
                if showStops and not twoSided
                    f_chartLevel(h, h.stpL, 1, false, 2, "", rightTime)
                    f_chartLevel(h, h.stp2L, 1, false, 3, "", rightTime)
            if not na(h.eS)
                f_chartLevel(h, h.eS, h.eSB, false, 0, twoSided ? "▼" : "", rightTime)
                f_chartLevel(h, h.tS, h.tSB, false, 1, twoSided ? "▼" : "", rightTime)
                if showStops and not twoSided
                    f_chartLevel(h, h.stpS, 1, true, 2, "", rightTime)
                    f_chartLevel(h, h.stp2S, 1, true, 3, "", rightTime)

    // Panels
    int nextLeft   = bar_index + panelOffset
    int panelWidth = math.max(1, (barsShown - 1) * barSpacing + tickWidth * 2)
    for h in tfs
        if h.show and h.valid and not na(h.live)
            f_panel(h, nextLeft, pad)
            nextLeft += panelWidth + panelGap

// ══════════════════════════════════════════════════════════════════════
//                             STRAT TABLE
// ══════════════════════════════════════════════════════════════════════
// Column map (optional columns shift the rest left)
int cCombo  = 1
int cPat    = colCombo ? 2 : 1
int cStat   = cPat + 1
int cET     = cStat + 1
int lastCol = colET ? cET : cStat

f_row(table t, int row, string lbl, string val, color bg, color valColor, string fsz, bool mono) =>
    table.cell(t, 0, row, lbl, bgcolor = bg, text_color = c_ntxt, text_size = fsz, text_halign = text.align_left)
    if mono
        table.cell(t, 1, row, val, bgcolor = bg, text_color = valColor, text_size = fsz, text_halign = text.align_left, text_font_family = font.family_monospace)
    else
        table.cell(t, 1, row, val, bgcolor = bg, text_color = valColor, text_size = fsz, text_halign = text.align_left)
    table.merge_cells(t, 1, row, lastCol, row)

f_statusText(int st) =>
    switch st
        0 => "Watching"
        1 => "Actionable"
        2 => "In force"
        3 => "Target hit"
        4 => "Outside"
        5 => "Watch"
        =>   "n/a"

f_statusColor(Tf h) =>
    h.status == 5 ? #5b9cf6 : h.status == 1 ? #f0b90b : h.status == 2 ? f_dirColor(h.dir) : h.status == 3 ? c_green : c_ntxt

f_comboText(Tf h) =>
    f_ssDir(h.s3, h.getBar(3)) + " → " + f_ssDir(h.s2, h.getBar(2)) + " → " + f_ssDir(h.s1, h.getBar(1)) + " → " + f_ssDir(h.sL, h.live)

// "S 30371.75 0.58R  S2 30399.00 1.17R" — S2 only when S1 is under the minimum R:R; SKIP if S2 is too.
f_stopText(float st, float rr, float st2, float rr2) =>
    string s = ""
    if showStops and not na(st)
        s := "  S " + f_px(st) + (na(rr) ? "" : " " + f_rr(rr))
        if not na(st2)
            s := s + "  S2 " + f_px(st2) + " " + f_rr(rr2) + (rr2 < rrMin ? " SKIP" : "")
    s

f_etText(Tf h) =>
    string s = ""
    if (h.status >= 1 and h.status <= 3) or h.status == 5
        if not na(h.eL)
            s := "▲ " + f_px(h.eL) + " → " + f_px(h.tL) + f_stopText(h.stpL, h.rrL, h.stp2L, h.rr2L)
        if not na(h.eS)
            s := s + (s != "" ? "\n" : "") + "▼ " + f_px(h.eS) + " → " + f_px(h.tS) + f_stopText(h.stpS, h.rrS, h.stp2S, h.rr2S)
    s == "" ? "—" : s

var table tbl = na

if showTable and barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(tablePos, lastCol + 1, 12, bgcolor = c_nbg, border_width = 1, frame_width = 1, border_color = c_sep, frame_color = c_sep)
    string fsz = font_sz(tableSize)
    int r = 0

    table.cell(tbl, 0, r, "📊 HTF STRAT BARS w/STOPS  [Market Breakers]", text_color = #f0b90b, bgcolor = c_hdr, text_size = fsz)
    table.merge_cells(tbl, 0, r, lastCol, r)
    r += 1

    int    dirAll   = score > 0 ? 1 : score < 0 ? -1 : 0
    bool   enough   = nActive >= 2 and wSum > 0
    string biasTxt  = not enough ? "Need 2+ HTFs" : dirAll > 0 ? "🟢 Bullish" : dirAll < 0 ? "🔴 Bearish" : nBull > 0 and nBear > 0 ? "⚠ Conflict" : "⚪ Neutral"
    string agreeTxt = not enough ? "n/a" : f_bar(agreePct, barSegs) + "  " + str.tostring(agreePct, "#") + "%"
    string ftfcTxt  = nLive < 2 ? "Need 2+ HTFs" : ftfcUp ? "▲ FULL CONTINUITY UP" : ftfcDn ? "▼ FULL CONTINUITY DOWN" : "Mixed  (▲ " + str.tostring(nUp) + " / ▼ " + str.tostring(nDn) + ")"
    color  ftfcCol  = ftfcUp ? c_green : ftfcDn ? c_red : c_ntxt

    f_row(tbl, r, "Bias", biasTxt, nbg2, enough ? f_dirColor(dirAll) : c_ntxt, fsz, false), r += 1
    f_row(tbl, r, "Agreement", agreeTxt, c_nbg, enough ? f_dirColor(dirAll) : c_ntxt, fsz, true), r += 1
    f_row(tbl, r, "FTFC", ftfcTxt, nbg2, ftfcCol, fsz, false), r += 1
    f_row(tbl, r, "Combos", "▲ " + str.tostring(nBull) + "   ▼ " + str.tostring(nBear) + "   · " + str.tostring(nActive - nBull - nBear), c_nbg, c_ntxt, fsz, false), r += 1

    table.cell(tbl, 0, r, "TF", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    if colCombo
        table.cell(tbl, cCombo, r, "Combo", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    table.cell(tbl, cPat, r, "Pattern", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    table.cell(tbl, cStat, r, "Status", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    if colET
        table.cell(tbl, cET, r, showStops ? "Entry → Target · Stop · R:R" : "Entry → Target", text_color = c_ntxt, bgcolor = c_dhdr, text_size = fsz)
    r += 1

    bool zebra = true
    for h in tfs
        if h.show
            color bg = zebra ? nbg2 : c_nbg
            table.cell(tbl, 0, r, h.name + "  " + f_tfText(h.tf), text_color = c_ntxt, bgcolor = bg, text_size = fsz, text_halign = text.align_left)
            if not h.valid
                table.cell(tbl, 1, r, "invalid TF", text_color = c_ntxt, bgcolor = bg, text_size = fsz)
                table.merge_cells(tbl, 1, r, lastCol, r)
            else if h.status < 0
                table.cell(tbl, 1, r, "loading HTF history…", text_color = c_ntxt, bgcolor = bg, text_size = fsz)
                table.merge_cells(tbl, 1, r, lastCol, r)
            else
                color sc = f_statusColor(h)
                if colCombo
                    table.cell(tbl, cCombo, r, f_comboText(h), text_color = c_ntxt, bgcolor = bg, text_size = fsz, text_font_family = font.family_monospace)
                table.cell(tbl, cPat, r, h.pattern == "" ? "—" : h.pattern, text_color = h.dir != 0 ? f_dirColor(h.dir) : h.status == 1 ? #f0b90b : c_ntxt, bgcolor = bg, text_size = fsz)
                table.cell(tbl, cStat, r, f_statusText(h.status), text_color = sc, bgcolor = color.new(sc, 85), text_size = fsz)
                if colET
                    table.cell(tbl, cET, r, f_etText(h), text_color = h.dir != 0 ? f_dirColor(h.dir) : c_ntxt, bgcolor = bg, text_size = fsz, text_font_family = font.family_monospace)
            r += 1
            zebra := not zebra

// ══════════════════════════════════════════════════════════════════════
//                               ALERTS
// ══════════════════════════════════════════════════════════════════════
alertcondition(bullTrig, "HTF Strat: bullish combo in force", "Bullish HTF Strat combo in force on {{ticker}} — close {{close}}")
alertcondition(bearTrig, "HTF Strat: bearish combo in force", "Bearish HTF Strat combo in force on {{ticker}} — close {{close}}")
alertcondition(bullTrig or bearTrig, "HTF Strat: any combo in force", "HTF Strat combo in force on {{ticker}} — close {{close}}")
alertcondition(ftfcUp and not ftfcUp[1], "HTF Strat: FTFC up", "Full timeframe continuity UP on {{ticker}}")
alertcondition(ftfcDn and not ftfcDn[1], "HTF Strat: FTFC down", "Full timeframe continuity DOWN on {{ticker}}")
````
