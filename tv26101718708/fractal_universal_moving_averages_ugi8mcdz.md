# Fractal Universal Moving Averages

- url: https://www.tradingview.com/script/uGi8mCDZ-Fractal-Universal-Moving-Averages/
- type: indicator
- pine_id: PUB;dc31ab0082da45a59a03157e3fe4f427
- version: 1.0

## Description

A moving average does not know what time it is. Its length is a count of bars, so a 50-period average means fifty days on a daily chart, fifty hours on an hourly chart and fifty quarter-hours on a 15-minute chart. The same setting describes three different crowds, and the label on the line never names the crowd in view.

Fractal Universal Moving Averages (FUMAs) is built on the premise that a moving average should be specified in time and then converted into the bars of whatever chart is open. It carries daily and weekly consensus onto intraday charts as smooth lines, draws a ranked braid of daily averages on the daily chart, and draws a weekly suite on the weekly chart. The sections below explain why ordinary averages break when the timeframe changes, why the usual repair creates new problems, and how to read the hourly chart above.

[b]A Length Is Counted in Bars, Not in Time
[/b]
Every standard moving average takes its length in bars. A trader who learns a 50-period average on the daily chart and then drops to the hourly chart without changing the setting is no longer watching a ten-week consensus. On a market that trades around the clock, fifty hourly bars cover roughly two days. On a regular-hours stock, which prints about seven hourly bars per session, they cover roughly seven sessions.

The distortion grows as the clock gets faster. A 200-period average, the market's most quoted line, spans 200 sessions on the daily chart, between eight days and nearly six weeks of trading on the hourly chart depending on the market's hours, and fewer than eight sessions of stock trading on the 15-minute chart. Each of those lines is calculated correctly. Each one answers a different question, and the chart presents all of them under the same name.

Volume-weighted averages inherit the same problem with a second layer. The volume in a bar depends on how long the bar lasts, so a VWMA weights participation differently on every clock. A trader comparing a daily VWMA with an hourly one compares two ledgers kept in different currencies.

[b]The Usual Repair Builds a Staircase
[/b]
The common remedy imports the higher timeframe's average directly. The daily average is calculated on daily bars and projected onto the hourly chart, where it holds one value for the whole session and then jumps when the next day begins. The result looks like a staircase laid across a ramp, and price spends every session negotiating with a level that cannot move until the session ends.

The staircase forces a second compromise. Either the imported line waits for the higher bar to close, so each step arrives late, or it updates with the forming bar and revises values the chart has already displayed. A trader working an hourly setup then reads either yesterday's consensus or a consensus that may change after the decision.

Translation avoids both compromises. Instead of importing a daily average, FUMAs builds an average whose memory spans one day, measured in the chart's own bars, and updates it on every bar. The line moves continuously beside price, it never revises a closed bar, and it keeps the meaning the trader intended when choosing the word "daily."

[b]Translation Instead of Importation
[/b]
On minute and hour charts, the instrument draws three lines. A daily EMA and a daily VWMA each average one day of bars, and a weekly EMA averages one week of bars. On the hourly chart those lengths are 24 and 120 bars; on the 15-minute chart they are 96 and 480. A seven-day option extends the weekly anchor to a full calendar week for markets that never close, crypto above all.

The space between the daily EMA and the daily VWMA is filled, and its color reports leadership. An EMA lead means price momentum is running ahead of the volume-weighted consensus. A VWMA lead means volume is building beneath price ahead of momentum's catch-up. The fill works like a litmus strip dipped into order flow, since the color itself is the measurement.

The weekly EMA is the ribbon's slowest line and its most important one. A pullback that touches the weekly anchor and closes back beyond it produces the strongest continuation reading the ribbon offers. A close through the anchor in the opposite direction places the intermediate structure under pressure. Between those events the anchor behaves like a waterline painted on a hull, where the crossing matters more than the ride.

[b]The Chart Chooses the Form
[/b]
The instrument reads the chart's resolution each time it loads and takes the form that suits it. The daily chart receives a braid of three filled pairs that turn at three speeds: a 21-day SMA and EMA that lead, a 50-day and 200-day EMA pair that confirms, and a 50-day and 200-day SMA pair that defines the trend. The weekly chart receives a 7-week EMA and VWMA ribbon, a 30-week ribbon, and a 200-week Hull average beneath both. On those clocks the averages are native, so no translation is needed.

Charts in seconds, ticks, months or years receive a visible refusal instead of a distortion. The instrument draws nothing and posts a single centered notice naming the supported resolutions. A stretched ribbon on a seconds chart would have produced a line with no defensible meaning, and a quiet failure of that kind would teach the wrong lesson.

Inactive forms resolve to nothing at the value level, so the Data Window and the legend show live numbers only for the active form. One script also carries all three forms, so a layout that moves between the 15-minute, hourly, daily and weekly charts spends a single indicator slot on its averages. The recovered room can hold the volume, momentum or structure tools that averages cannot replace.

[b]Reading the Screenshot
[/b]
The chart above shows Helus Pharma (HELP) on the hourly clock with regular hours, captured after the close of 9 October, with the ribbon in a custom palette. The legend reads the daily EMA at 11.17, the daily VWMA at 11.04 and the weekly EMA at 11.88, followed by empty markers for the dormant daily and weekly forms. Price rallied through September with the ribbon riding above a rising weekly anchor and printed its 14.88 high on 18 September. The ribbon crossed beneath the anchor at month's end and followed price down to the 10.20 low of 8 October.

On 9 October price surged back through both daily lines, and the fill turned to show momentum leading volume. Price closed at 11.78, just beneath the weekly anchor at 11.88. A close back above the anchor would convert a sharp bounce into a reclaim, while a rejection would leave the anchor marking the boundary between a pullback and damage. The instrument does not answer that question; it shows where the answer will be printed.

FUMAs is a supplementary instrument. It reports where slower consensus lies and whether momentum or volume leads, and it leaves the trigger to the trader's own method. A trend trail, a volume profile and bar-by-bar volume analysis supply push, location and participation, which the averages cannot measure. Nothing in this description or in the script is financial advice, and past behavior of the averages does not predict future prices.

[b]The Day Is a Convention
[/b]
The ribbon defines a day as 1,440 minutes, which is literally true for crypto and quietly false for a regular-hours stock. On HELP's hourly chart, the 24-bar daily lines span between three and four sessions, and the 120-bar weekly anchor spans more than three weeks of trading. That stretch happens to suit equities, where pullback trading wants a slower consensus than one session can supply.

The deeper point concerns every average on every chart. A moving average is a claim on how long a market remembers, and a length typed in bars makes that claim without stating its unit. FUMAs states the unit and converts it, and in doing so it exposes the question every other average quietly answers for the trader, which is whose day, and whose week, the line is counting.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  UNIFIED MA SUITE — TIMEFRAME-AWARE
//  One script, three self-contained modes, selected by chart resolution:
//    · Granular MA Ribbon ............. minutes & hours (calibrated 15M / 1H)
//    · Triple Differential MA Braid ... 1D
//    · Weekly MA Suite ................ 1W
//  Seconds, ticks, months, and years are out of domain: nothing prints and a
//  centered notice appears instead. Plots belonging to inactive modes resolve
//  to na at the value level, so the Data Window never shows stale numbers.
//  No alertcondition(). No strategy constructs. Live discretionary use only.
//  Plot budget: 14 plots + 6 fills — comfortably inside the 64-plot ceiling.
// ═══════════════════════════════════════════════════════════════════════════
indicator("Fractal Universal Moving Averages", shorttitle="FUMAs", overlay=true)

// ─────────────────────────── MODE DETECTION ────────────────────────────────
bool modeIntraday    = timeframe.isminutes            // minutes and hours
bool modeDaily       = timeframe.isdaily
bool modeWeekly      = timeframe.isweekly
bool modeUnsupported = not (modeIntraday or modeDaily or modeWeekly)

// ─────────────── INPUTS · MODE 1 — GRANULAR MA RIBBON ──────────────────────
string G1 = "Mode 1 · Granular MA Ribbon (minutes & hours)"
bool  use7DayWeek        = input.bool(false, "Use 7-Day Week (For Crypto)", group = G1)
bool  showRibEma1D       = input.bool(true, "Show 1D EMA", group = G1)
color colRibEma1D        = input.color(color.blue, "1D EMA Color", group = G1)
int   widRibEma1D        = input.int(2, "1D EMA Line Width", group = G1)
bool  showRibVwma1D      = input.bool(true, "Show 1D VWMA", group = G1)
color colRibVwma1D       = input.color(color.orange, "1D VWMA Color", group = G1)
int   widRibVwma1D       = input.int(2, "1D VWMA Line Width", group = G1)
bool  showRibEma1W       = input.bool(true, "Show 1W EMA (Intraday)", group = G1)
color colRibEma1W        = input.color(color.purple, "1W EMA Color (Intraday)", group = G1)
int   widRibEma1W        = input.int(2, "1W EMA Line Width (Intraday)", group = G1)
bool  showRibFill        = input.bool(true, "Show Ribbon Fill", group = G1)
color colRibFillEmaLead  = input.color(color.blue, "Ribbon Fill — EMA Leading", group = G1)
color colRibFillVwmaLead = input.color(color.orange, "Ribbon Fill — VWMA Leading", group = G1)
int   ribFillTransp      = input.int(85, "Ribbon Fill Transparency", minval = 0, maxval = 100, group = G1)

// ─────────── INPUTS · MODE 2 — TRIPLE DIFFERENTIAL MA BRAID ────────────────
string G2 = "Mode 2 · Triple Differential MA Braid (1D)"
int   gsFastLen = input.int(50,  "Golden Section Fast Length", group = G2)
int   gsSlowLen = input.int(200, "Golden Section Slow Length", group = G2)
int   rgFastLen = input.int(50,  "Royal Guard Fast Length", group = G2)
int   rgSlowLen = input.int(200, "Royal Guard Slow Length", group = G2)
int   stLen     = input.int(21,  "Silver Thread Length", group = G2)
// Line colors — exposed as inputs; defaults reproduce the source hard-codes.
color colGSFastLine = input.color(color.yellow, "Golden Section Fast Line", group = G2)
color colGSSlowLine = input.color(color.yellow, "Golden Section Slow Line", group = G2)
color colRGFastLine = input.color(color.purple, "Royal Guard Fast Line", group = G2)
color colRGSlowLine = input.color(color.rgb(234, 167, 207), "Royal Guard Slow Line", group = G2)
color colSTFastLine = input.color(color.silver, "Silver Thread Fast Line", group = G2)
color colSTSlowLine = input.color(color.gray, "Silver Thread Slow Line", group = G2)
// Fill colors — defaults identical to the source script.
color colGSAbove = input.color(color.new(color.yellow, 50), "Golden Section Above Fill", group = G2)
color colGSBelow = input.color(color.new(#dea44c, 50), "Golden Section Below Fill", group = G2)
color colRGAbove = input.color(color.new(#8f1fa3, 40), "Royal Guard Above Fill", group = G2)
color colRGBelow = input.color(color.new(#ca17c7, 40), "Royal Guard Below Fill", group = G2)
color colSTAbove = input.color(color.new(#5a88d7, 0), "Silver Thread Above Fill", group = G2)
color colSTBelow = input.color(color.new(#5bc2d7, 0), "Silver Thread Below Fill", group = G2)

// ─────────────── INPUTS · MODE 3 — WEEKLY MA SUITE ─────────────────────────
string G3 = "Mode 3 · Weekly MA Suite (1W)"
bool  show1WEMA      = input.bool(true, "Show 1W EMA", group = G3)
bool  show1WVWMA     = input.bool(true, "Show 1W VWMA", group = G3)
color col1WEMA       = input.color(color.blue, "1W EMA Color", group = G3)
color col1WVWMA      = input.color(color.orange, "1W VWMA Color", group = G3)
bool  showRibbon1W   = input.bool(true, "Show 1W EMA-VWMA Ribbon", group = G3)
color ribbonColor1W  = input.color(color.blue, "1W Ribbon Fill Color", group = G3)
int   ribbonTransp1W = input.int(50, "1W Ribbon Transparency", minval = 0, maxval = 100, group = G3)
bool  show30WEMA      = input.bool(true, "Show 30W EMA", group = G3)
bool  show30WVWMA     = input.bool(true, "Show 30W VWMA", group = G3)
color col30WEMA       = input.color(color.green, "30W EMA Color", group = G3)
color col30WVWMA      = input.color(color.yellow, "30W VWMA Color", group = G3)
bool  showRibbon30W   = input.bool(true, "Show 30W EMA-VWMA Ribbon", group = G3)
color ribbonColor30W  = input.color(color.green, "30W Ribbon Fill Color", group = G3)
int   ribbonTransp30W = input.int(50, "30W Ribbon Transparency", minval = 0, maxval = 100, group = G3)
bool  show200WHMA     = input.bool(true, "Show 200W HMA", group = G3)
color col200WHMA      = input.color(color.red, "200W HMA Color", group = G3)

// ─────────────── MODE 1 · GRANULAR MA RIBBON — CALCULATIONS ────────────────
// Bar-count conversion assumes a 1440-minute (24-hour) day, matching the
// source design: 96 × 15M = 1440 and 24 × 60M = 1440. The weekly anchor uses
// 7200 minutes (5-day week) or 10080 minutes (7-day week): 480 or 672 bars at
// 15M, 120 or 168 bars at 1H. The formula reproduces the source constants
// exactly at 15M and 1H and extends coherently to other minute resolutions;
// 15M and 1H remain the calibrated targets. Off-mode, lengths collapse to
// trivial values purely to avoid wasted computation — the results are never
// plotted outside intraday mode.
int tfMin  = modeIntraday ? timeframe.multiplier : 1440
int bars1D = math.max(1, int(math.round(1440.0 / tfMin)))
int bars1W = math.max(1, int(math.round((use7DayWeek ? 10080.0 : 7200.0) / tfMin)))

float ribEma1D  = ta.ema(close, bars1D)
float ribSumPV  = ta.sma(close * volume, bars1D)
float ribSumV   = ta.sma(volume, bars1D)
float ribVwma1D = ribSumV > 0 ? ribSumPV / ribSumV : na
float ribEma1W  = ta.ema(close, bars1W)

// ─────────── MODE 2 · TRIPLE DIFFERENTIAL MA BRAID — CALCULATIONS ──────────
float gsFastMA = ta.sma(close, gsFastLen)   // Golden Section: 50D / 200D SMA
float gsSlowMA = ta.sma(close, gsSlowLen)
float rgFastMA = ta.ema(close, rgFastLen)   // Royal Guard: 50D / 200D EMA
float rgSlowMA = ta.ema(close, rgSlowLen)
float stFastMA = ta.sma(close, stLen)       // Silver Thread Fast: 21D SMA
float stSlowMA = ta.ema(close, stLen)       // Silver Thread Slow: 21D EMA

// ─────────────── MODE 3 · WEEKLY MA SUITE — CALCULATIONS ───────────────────
// Custom HMA preserved verbatim from the source (identical to standard HMA).
f_hma(src, length) =>
    ta.wma(2 * ta.wma(src, length / 2) - ta.wma(src, length), math.round(math.sqrt(length)))

// Single tuple request replaces seven separate calls; the math is unchanged.
[wkEma1W, wkVwma1W, wkEma30W, wkVwma30W, wkHma200W] =
     request.security(syminfo.tickerid, "W",
         [ta.ema(close, 7),
          ta.sma(close * volume, 7)  / ta.sma(volume, 7),
          ta.ema(close, 30),
          ta.sma(close * volume, 30) / ta.sma(volume, 30),
          f_hma(close, 200)])

// ─────────────────────── PLOTS · MODE 1 (INTRADAY) ─────────────────────────
pRibEma  = plot(modeIntraday and showRibEma1D  ? ribEma1D  : na, title = "1D EMA",
     color = colRibEma1D, linewidth = widRibEma1D)
pRibVwma = plot(modeIntraday and showRibVwma1D ? ribVwma1D : na, title = "1D VWMA",
     color = colRibVwma1D, linewidth = widRibVwma1D)
plot(modeIntraday and showRibEma1W ? ribEma1W : na, title = "1W EMA (Intraday)",
     color = colRibEma1W, linewidth = widRibEma1W)

// Ribbon fill encodes EMA-vs-VWMA leadership, per the documented behavior.
color ribFillColor = modeIntraday and showRibFill ?
     color.new(ribEma1D >= ribVwma1D ? colRibFillEmaLead : colRibFillVwmaLead, ribFillTransp) :
     color(na)
fill(pRibEma, pRibVwma, color = ribFillColor, title = "EMA-VWMA Ribbon")

// ─────────────────────── PLOTS · MODE 2 (DAILY) ────────────────────────────
pGSf = plot(modeDaily ? gsFastMA : na, title = "Golden Section Fast", color = colGSFastLine, linewidth = 1)
pGSs = plot(modeDaily ? gsSlowMA : na, title = "Golden Section Slow", color = colGSSlowLine, linewidth = 1)
pRGf = plot(modeDaily ? rgFastMA : na, title = "Royal Guard Fast",    color = colRGFastLine, linewidth = 1)
pRGs = plot(modeDaily ? rgSlowMA : na, title = "Royal Guard Slow",    color = colRGSlowLine, linewidth = 1)
pSTf = plot(modeDaily ? stFastMA : na, title = "Silver Thread Fast",  color = colSTFastLine, linewidth = 1)
pSTs = plot(modeDaily ? stSlowMA : na, title = "Silver Thread Slow",  color = colSTSlowLine, linewidth = 1)

fill(pGSf, pGSs, color = modeDaily ? (gsFastMA > gsSlowMA ? colGSAbove : colGSBelow) : color(na),
     title = "Golden Section Fill")
fill(pRGf, pRGs, color = modeDaily ? (rgFastMA > rgSlowMA ? colRGAbove : colRGBelow) : color(na),
     title = "Royal Guard Fill")
fill(pSTf, pSTs, color = modeDaily ? (stFastMA > stSlowMA ? colSTAbove : colSTBelow) : color(na),
     title = "Silver Thread Fill")

// ─────────────────────── PLOTS · MODE 3 (WEEKLY) ───────────────────────────
// Plot order preserved from the source to retain z-ordering:
// 1W pair → 200W HMA → 30W pair.
pW1 = plot(modeWeekly and show1WEMA  ? wkEma1W  : na, title = "1W EMA",  color = col1WEMA,  linewidth = 1)
pW2 = plot(modeWeekly and show1WVWMA ? wkVwma1W : na, title = "1W VWMA", color = col1WVWMA, linewidth = 1)
fill(pW1, pW2, color = modeWeekly and showRibbon1W ?
     color.new(ribbonColor1W, ribbonTransp1W) : color(na), title = "1W EMA-VWMA Ribbon")

plot(modeWeekly and show200WHMA ? wkHma200W : na, title = "200W HMA", color = col200WHMA, linewidth = 2)

pW3 = plot(modeWeekly and show30WEMA  ? wkEma30W  : na, title = "30W EMA",  color = col30WEMA,  linewidth = 1)
pW4 = plot(modeWeekly and show30WVWMA ? wkVwma30W : na, title = "30W VWMA", color = col30WVWMA, linewidth = 1)
fill(pW3, pW4, color = modeWeekly and showRibbon30W ?
     color.new(ribbonColor30W, ribbonTransp30W) : color(na), title = "30W Ribbon")

// ─────────────────── OUT-OF-DOMAIN TIMEFRAME NOTICE ────────────────────────
// Seconds, ticks, months, and years: no mode activates, nothing prints, and
// a single centered notice replaces the chart output. A visible refusal was
// chosen over runtime.error() so a mistaken load fails gracefully on screen.
if modeUnsupported and barstate.islast
    var table notice = table.new(position.middle_center, 1, 1)
    table.cell(notice, 0, 0,
         "UNIFIED MA SUITE\nUnsupported timeframe.\nSupported resolutions: minutes, hours, 1D, 1W.",
         text_color = color.white, bgcolor = color.new(color.red, 15), text_size = size.normal)
````
