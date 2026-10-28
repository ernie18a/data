# Margin Debt Expansion vs Contraction Indicator

- url: https://www.tradingview.com/script/uQ4dx2SI-Margin-Debt-Expansion-vs-Contraction-Indicator/
- type: indicator
- pine_id: PUB;79e1020d451849afa2ba9897992fe964
- version: 1.0

## Description

█ OVERVIEW

This indicator plots the year over year percentage change in a quarterly measure of U.S. margin debt in a separate pane, classifies that rate of change into an expansion regime and a contraction regime, and marks the quarters in which the rate of change turns while inside either regime. The thesis is that the second derivative of speculative leverage, rather than its absolute level, is what distinguishes one phase of a market cycle from another.


█ HISTORY / BACKGROUND

Aggregate customer margin debt has been reported for U.S. brokerage accounts for many decades. The NYSE compiled and published the series historically. FINRA later assumed responsibility for aggregating and distributing margin statistics from its member firms, on a monthly basis. The Federal Reserve publishes a closely related quarterly aggregate as part of the Z.1 Financial Accounts under the heading "Security Brokers and Dealers; Receivables Due from Customers (Margin Loans and Other Receivables); Asset, Level."

The observation that leverage growth accelerates into cycle peaks and contracts violently during forced deleveraging is long standing and not proprietary to any single author. The absolute level of margin debt trends upward with nominal market capitalisation and with the size of the brokerage system, which makes level comparisons across decades of limited use. Expressing the series as a year over year rate of change removes that trend and puts every cycle on a comparable scale. This script implements that transform and adds a regime classification and turn detection layer on top of it.


█ HOW IT WORKS

  •  The script issues two requests against FRED:BOGZ1FL663067003Q at the 3M resolution, both with gaps off and lookahead off. The first returns the current quarterly value. The second returns the same series offset by four quarters.
  •  The year over year rate of change is computed as (current minus prior year) divided by prior year, multiplied by 100. The calculation is skipped and the plot returns na when either request is na or when the prior year value is zero.
  •  Because the source is quarterly and the chart is not, the resulting series is a step function. It holds a constant value across every chart bar inside a quarter and changes only on the first chart bar after a new quarterly value becomes available.
  •  Two regimes are derived from the rate of change. The expansion regime is active when the reading is at or above the Red Zone Lower input. The contraction regime is active when the reading is at or below the Green Zone Upper input. The Red Zone Upper and Green Zone Lower inputs define the outer edge of the shaded bands and do not participate in regime classification, so a reading that jumps past the outer edge still registers.
  •  A threshold cross is flagged on the first bar on which a regime becomes active after not being active on the prior bar. A triangle marker prints at the value of the line.
  •  A rollover is flagged when the regime is active and the current reading is below the prior bar reading while the prior bar reading was at or above the reading before it. On a step function this resolves to the first chart bar of any quarter whose value moved against the direction of the regime. The contraction rollover is the mirror condition. A circle marker prints at the value of the line.
  •  The line is coloured red while the expansion regime is active, green while the contraction regime is active, and neutral otherwise.


█ HOW TO USE

Use this on a daily or weekly chart. The underlying data is quarterly, so a daily chart gives enough resolution to see each quarterly step clearly while still covering a multi decade span on one screen. Intraday timeframes add no information because the value cannot change intraday. Timeframes at or above 3M collapse the step structure and are not useful.

The chart symbol does not enter the calculation. The output is identical on every symbol. Load it beneath a broad U.S. equity index if you want visual correspondence between the leverage cycle and the price cycle, but understand that the indicator is not reading the chart.

Reading the output:

  •  [b]The line[/b] is the year over year rate of change of margin debt in percent. Zero means leverage is flat against the same quarter one year earlier.
  •  [b]The red band[/b] spans the expansion thresholds. A reading inside or above it means leverage is growing at a pace that has historically clustered in the later stages of an advance.
  •  [b]The green band[/b] spans the contraction thresholds. A reading inside or below it means leverage is shrinking at a pace that has historically clustered around and after deep declines.
  •  [b]Triangle markers[/b] mark the quarter in which a regime first became active.
  •  [b]Circle markers[/b] mark a quarter in which the rate of change moved against the direction of the active regime. These can print more than once inside a single regime episode, since any adverse quarter qualifies. Treat a run of consecutive circles as more informative than a single one.

The measure is coincident to lagging with respect to price. It describes the state of leverage rather than anticipating price. Read it alongside independent inputs such as breadth, credit spreads and the yield curve.


█ SETTINGS

Zone Thresholds

  •  [b]Red Zone Upper (%)[/b], default 55. Outer edge of the expansion band. Shading only.
  •  [b]Red Zone Lower (%)[/b], default 40. Expansion threshold. Regime classification, marker logic and line colour key off this level.
  •  [b]Green Zone Upper (%)[/b], default -20. Contraction threshold. Regime classification, marker logic and line colour key off this level.
  •  [b]Green Zone Lower (%)[/b], default -40. Outer edge of the contraction band. Shading only.

Display

  •  [b]Show Zone Markers[/b], default on. Toggles the triangle and circle markers. The line, bands and alert conditions are unaffected by this input.


█ WHAT MAKES IT ORIGINAL

Plotting margin debt, or its rate of change, is not itself novel. What this script does differently is separate three things that are usually collapsed into one threshold test.

First, regime membership is defined by a single inner threshold per side rather than by band membership, so the classification does not fail when the series gaps past the outer edge of the shaded band. The band remains a visual reference for how far into the regime the reading sits.

Second, turn detection is evaluated only conditionally, inside an active regime. An adverse quarter in the middle of the range carries no signal and produces no marker. The same adverse quarter above the expansion threshold is the event the script is built to isolate.

Third, the turn test is written for a step function rather than a continuous series. It fires on the first chart bar carrying a new quarterly value that moved against the regime, which is the only bar on which new information actually arrived, rather than repeating across the plateau.

The combination of a one sided regime gate with a step aware turn test applied to a quarterly macro leverage series is what distinguishes this from a threshold crossing plot of the same data.


█ NOTES / LIMITATIONS

  •  [b]Quarterly source.[/b] FRED:BOGZ1FL663067003Q is published quarterly. FINRA's monthly margin debt series is not available natively on this platform. Every regime change and every marker resolves to quarterly granularity. A turn that a monthly series would show in month one will not appear here until the quarter closes.
  •  [b]Publication lag.[/b] The Z.1 Financial Accounts are released roughly ten weeks after the quarter they cover. The script positions each quarterly value at the close of the quarter it describes, which is earlier than the date on which that value became publicly known. Historical marker placement is therefore ahead of real world availability by approximately one quarter. This is inherent to charting a macro release against calendar time and cannot be corrected inside the script.
  •  [b]Revisions.[/b] The Z.1 series is revised. Historical values, and therefore historical markers, can change when the source data is revised.
  •  [b]No lookahead.[/b] Both requests use barmerge.lookahead_off, so a quarterly value is not shown on chart bars that precede the close of its own quarter. The most recent quarter updates as new data arrives, in the normal way for any real time series.
  •  [b]History dependence.[/b] The rate of change requires five quarterly observations before it can be computed, and the plot returns na until they exist. On charts whose own history is shorter than the available FRED history, the line only covers the bars the chart has. Applying the script to a recently listed symbol will truncate the visible record accordingly.
  •  [b]Symbol independence.[/b] The output does not depend on the chart symbol and will be identical on any instrument. It is a U.S. aggregate leverage measure and carries no meaning with respect to the price series it is displayed against.
  •  [b]Timeframe sensitivity.[/b] Intraday resolutions cannot resolve the source data and produce a flat line across long stretches. Resolutions at or above 3M compress the step structure to the point of illegibility. Daily or weekly is the intended range.
  •  [b]Threshold provenance.[/b] The default threshold values are round numbers chosen to sit near the extremes observed in the available history. The number of complete leverage cycles contained in the series is small, so the thresholds should be treated as adjustable reference levels rather than as fixed boundaries with statistical support.
  •  [b]Repeated rollover markers.[/b] The rollover test flags any adverse quarter inside an active regime, not only the first or the extreme one. Multiple circles inside a single regime episode are expected behaviour, not a defect.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BY_Tse

//@version=6
indicator("Margin Debt Expansion vs Contraction Indicator", shorttitle="MarginDebt YoY%", overlay=false, precision=1)

// ──────────────────────────────────────────────────────────────────────────────
// Inputs
// ──────────────────────────────────────────────────────────────────────────────
string  GRP_ZONES   = "Zone Thresholds"
float   redHi       = input.float(55.0,  "Red Zone Upper (%)",    group=GRP_ZONES, tooltip="Upper edge of the expansion band. Shading only.")
float   redLo       = input.float(40.0,  "Red Zone Lower (%)",    group=GRP_ZONES, tooltip="Expansion threshold. Entries and rollovers key off this level.")
float   greenHi     = input.float(-20.0, "Green Zone Upper (%)",  group=GRP_ZONES, tooltip="Contraction threshold. Entries and rollovers key off this level.")
float   greenLo     = input.float(-40.0, "Green Zone Lower (%)",  group=GRP_ZONES, tooltip="Lower edge of the contraction band. Shading only.")

string  GRP_DISPLAY = "Display"
bool    showLabels  = input.bool(true, "Show Zone Markers", group=GRP_DISPLAY)

// ──────────────────────────────────────────────────────────────────────────────
// Data: quarterly broker/dealer customer receivables (Z.1 Financial Accounts)
// ──────────────────────────────────────────────────────────────────────────────
marginDebt   = request.security("FRED:BOGZ1FL663067003Q", "3M", close,    gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
marginDebt4Q = request.security("FRED:BOGZ1FL663067003Q", "3M", close[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

float yoy = na
if not na(marginDebt) and not na(marginDebt4Q) and marginDebt4Q != 0
    yoy := (marginDebt - marginDebt4Q) / marginDebt4Q * 100

// ──────────────────────────────────────────────────────────────────────────────
// Regime classification
// ──────────────────────────────────────────────────────────────────────────────
bool redActive   = not na(yoy) and yoy >= redLo
bool greenActive = not na(yoy) and yoy <= greenHi

bool redEntry    = redActive   and not redActive[1]
bool greenEntry  = greenActive and not greenActive[1]

bool redRollover   = redActive   and yoy < yoy[1] and yoy[1] >= yoy[2]
bool greenRollover = greenActive and yoy > yoy[1] and yoy[1] <= yoy[2]

// ──────────────────────────────────────────────────────────────────────────────
// Plots
// ──────────────────────────────────────────────────────────────────────────────
p_redHi   = plot(redHi,   "Red Upper",   color=color.new(color.red, 80))
p_redLo   = plot(redLo,   "Red Lower",   color=color.new(color.red, 80))
fill(p_redHi, p_redLo, color=color.new(color.red, 85), title="Expansion Band")

p_greenHi = plot(greenHi, "Green Upper", color=color.new(color.green, 80))
p_greenLo = plot(greenLo, "Green Lower", color=color.new(color.green, 80))
fill(p_greenHi, p_greenLo, color=color.new(color.green, 85), title="Contraction Band")

hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)

yoyColor = redActive ? color.red : greenActive ? color.green : color.new(color.white, 20)
plot(yoy, "Margin Debt YoY%", color=yoyColor, linewidth=2)

plotshape(showLabels and redEntry      ? yoy : na, "Expansion Threshold Cross",   shape.triangledown, location.absolute, color.red,                   size=size.small)
plotshape(showLabels and greenEntry    ? yoy : na, "Contraction Threshold Cross", shape.triangleup,   location.absolute, color.green,                 size=size.small)
plotshape(showLabels and redRollover   ? yoy : na, "Expansion Rollover",          shape.circle,       location.absolute, color.new(color.red, 30),    size=size.tiny)
plotshape(showLabels and greenRollover ? yoy : na, "Contraction Rollover",        shape.circle,       location.absolute, color.new(color.green, 30),  size=size.tiny)

// ──────────────────────────────────────────────────────────────────────────────
// Alerts
// ──────────────────────────────────────────────────────────────────────────────
alertcondition(redEntry,      "Expansion Threshold Cross",   "Margin debt YoY% has crossed above the expansion threshold")
alertcondition(greenEntry,    "Contraction Threshold Cross", "Margin debt YoY% has crossed below the contraction threshold")
alertcondition(redRollover,   "Expansion Rollover",          "Margin debt YoY% declined quarter over quarter while above the expansion threshold")
alertcondition(greenRollover, "Contraction Rollover",        "Margin debt YoY% rose quarter over quarter while below the contraction threshold")
````
