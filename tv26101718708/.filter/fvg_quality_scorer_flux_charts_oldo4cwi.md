# FVG Quality Scorer | Flux Charts

- url: https://www.tradingview.com/script/olDO4cWI-FVG-Quality-Scorer-Flux-Charts/
- type: indicator
- pine_id: PUB;2b0c6ece69da48aabe743bddbfae95c4
- version: 1.0

## Description

[b]GENERAL OVERVIEW:[/b]
FVG Quality Scorer is a Fair Value Gap analysis tool designed to extend beyond basic gap detection. Instead of treating every gap equally, this indicator evaluates each FVG across four independent scoring axes and assigns a letter grade (A through D) based on configurable thresholds. This creates a structured view of the chart where gaps are organized by their relative characteristics.

Every FVG is scored once at the moment of creation across Displacement Strength, Volume Delta, Contextual Location, and Structural Alignment. Each axis is scored from 0 to 25, producing a weighted composite score out of 100. Scores are fixed at creation, ensuring the evaluation reflects the conditions present at the time of formation and does not change retroactively. In contrast, each FVG’s lifecycle state (Fresh, Tested, Partially Filled, Mitigated) updates in real time as price interacts with the zone, providing a current view of how price is interacting with each gap.

A companion dashboard tracks grade distribution, active counts, total formations, and average fill times across the visible chart history. Score labels at the edge of each FVG box provide a quick reference to the assigned grade, with optional tooltips displaying the full scoring breakdown and current lifecycle state.

https://www.tradingview.com/x/Pok44d7z/ [Screenshot: Wide chart view showing multiple FVG boxes with different grades visible, score labels on right edges, and the dashboard in the top right corner. Show a mix of bullish and bearish FVGs across different lifecycle states.]

[b]FEATURES:[/b]
◇ Four-axis scoring system: Displacement Strength, Volume Delta, Contextual Location, and Structural Alignment, each scored from 0 to 25 for a maximum composite score of 100
◇ Letter grade assignment (A, B, C, D) using per-axis threshold gates with configurable minimum scores and required axes per grade
◇ Lower timeframe volume delta analysis using intrabar data to estimate directional volume distribution within the displacement candle
◇ Higher timeframe FVG nesting detection to identify when current timeframe gaps are positioned within higher timeframe imbalances
◇ Session timing reference covering Asian, London, New York AM, and New York PM sessions based on New York time
◇ Premium and Discount zone scoring using a proportional gradient based on the FVG’s position within a defined price range
◇ Market structure classification using swing high and swing low sequences to label conditions as bullish, bearish, or mixed
◇ Break of Structure (BOS) tracking using crossover logic to identify recent structural breaks relative to the FVG direction
◇ Post-sweep proximity detection identifying FVGs that form after a liquidity sweep of a swing level
◇ Lifecycle state tracking: Fresh → Tested → Partially Filled → Mitigated, with corresponding visual updates on the chart
◇ Score labels with optional tooltips displaying axis scores and current lifecycle state
◇ Dashboard displaying active counts, total formations, and average bars to mitigation per grade, along with nearest A-grade distance tracking
◇ Configurable axis weights for adjusting the influence of each scoring dimension in the composite score
◇ Alerts for newly formed A-grade and B-grade FVGs based on defined grading criteria

[b]WHAT IS A FAIR VALUE GAP?[/b]
A Fair Value Gap is a three-candle price formation that highlights an imbalance in price movement. It occurs when the third candle’s wick does not overlap with the first candle’s wick, leaving a visible gap created by the middle candle. This middle candle is often referred to as the “displacement” candle, as it reflects a relatively strong move in price over a short period.
In a bullish FVG, the low of the third candle is positioned above the high of the first candle. In a bearish FVG, the high of the third candle is positioned below the low of the first candle. The space between these two wicks defines the FVG zone.

Within ICT and Smart Money Concepts frameworks, these gaps are interpreted as areas where price moved quickly, leaving limited trading activity at certain levels. As a result, these zones are often monitored as areas of interest if price revisits them in the future. However, not all FVGs share the same characteristics, and variations in formation context are what this indicator evaluates using its scoring system.

https://www.tradingview.com/x/qDw4ADX7/ [Screenshot: Annotated chart showing a textbook bullish FVG formation.]

[b]WHAT IS THE THEORY BEHIND THIS INDICATOR?[/b]
The core premise behind FVG Quality Scorer is that gap detection alone does not capture the full context of how Fair Value Gaps form. On any given trading day, multiple FVGs can appear across timeframes, each with different characteristics depending on the surrounding price action. This indicator evaluates those characteristics using a structured scoring approach.

Not all FVGs form under the same conditions. For example, a gap created by a relatively small candle during low volume periods in a ranging market will differ in structure from one formed during a strong displacement move with increased volume, aligned with broader market structure and session timing. These differences are often considered when analyzing FVGs, but evaluating them manually across multiple factors and timeframes can be time intensive and subjective. FVG Quality Scorer standardizes this process by quantifying these characteristics into a consistent framework.

The indicator’s four-axis model reflects commonly used analytical considerations within ICT and Smart Money Concepts methodologies. These include measuring displacement strength, assessing volume characteristics, evaluating contextual positioning within a range or session, and identifying alignment with market structure. By organizing these factors into a rule-based system, the indicator provides a consistent method for comparing FVG formations based on their underlying attributes.

https://www.tradingview.com/x/gX5pLqfF/ [Screenshot: Zoomed in on a strong displacement candle forming a bullish FVG. ]

[b]Axis 1: Displacement Strength (0 to 25 points)[/b]
The displacement candle is the middle candle of the three-bar FVG formation and is the candle responsible for creating the gap. This axis evaluates the characteristics of that candle based on its size, structure, and relation to surrounding price action. Candles with larger bodies relative to their total range, higher relative size compared to recent volatility, and alignment with neighboring candles are scored differently than candles with smaller bodies or more pronounced wicks.

The indicator evaluates three sub-metrics within this axis. Body-to-range ratio (0 to 10 points) measures how much of the candle’s total range is composed of the body versus the wicks. A ratio of 0.85 or higher receives 10 points, ratios between 0.70 and 0.85 receive 7 points, ratios between 0.55 and 0.70 receive 4 points, and anything below 0.55 receives zero.
ATR multiple (0 to 10 points) compares the displacement candle’s total range to the 14-period Average True Range. A range equal to or greater than 2 times the ATR receives 10 points, 1.5x to 2x receives 7 points, 1x to 1.5x receives 4 points, and values below 1x receive zero.
Consecutive displacement (0 to 5 points) evaluates whether the candles immediately before and after the displacement candle close in the same direction as the FVG. If both surrounding candles align, the FVG receives 5 points. If one aligns, it receives 2 points. If neither aligns, it receives zero. This metric reflects the consistency of direction across the three-candle formation.

https://www.tradingview.com/x/cum9jl1Q/ [Screenshot: Chart showing a high scoring A grade FVG with the tooltip visible, displaying the full axis breakdown.]

[b]Axis 2: Volume Delta (0 to 25 points)[/b]
Volume reflects how much activity occurred, while volume delta separates that activity into directional components based on price movement. By analyzing lower timeframe data, volume can be divided into buying and selling activity within the displacement candle, providing additional context on how volume was distributed during the move.
The indicator uses lower timeframe intrabar data (configurable, default 1 minute) to estimate this distribution. Each lower timeframe candle within the displacement bar is classified as bullish volume (close above open) or bearish volume (close at or below open), and these values are aggregated to form a directional breakdown.

This axis evaluates three sub-metrics. LTF dominance (0 to 12 points) measures the percentage of total volume on the displacement candle that aligns with the FVG direction. Values above 75% receive 12 points, 60% to 75% receive 8 points, 50% to 60% receive 4 points, and values below 50% receive zero.

Relative volume (0 to 8 points) compares the displacement candle’s volume to the 20-period volume average. Volume equal to or greater than 2 times the average receives 8 points, 1.5x to 2x receives 5 points, 1x to 1.5x receives 2 points, and values below the average receive zero.
Volume rising (0 to 5 points) evaluates whether volume increases across the three candles of the formation, where volume on the displacement candle exceeds the prior candle, and the prior candle exceeds the one before it. This metric captures the progression of volume across the formation.

https://www.tradingview.com/x/LrDfGcyt/ Screenshot: Zoomed view showing the Delta volume panel below with visible volume spike on the displacement candle]

[b]Axis 3: Contextual Location (0 to 25 points)[/b]
The location of an FVG within the recent price range provides additional context for how it formed. In ICT methodology, the range is often divided into two halves using the equilibrium (50%) level. The lower half is referred to as the “discount zone,” while the upper half is referred to as the “premium zone.”

A bullish FVG forming in the lower portion of the range is positioned within the discount zone, while a bearish FVG forming in the upper portion is positioned within the premium zone. FVGs that form closer to the midpoint or on the opposite side of the range can be described as having different contextual positioning relative to the defined range.

This indicator incorporates that positioning into its scoring by evaluating where the FVG forms within the selected lookback range, using a proportional approach rather than a fixed cutoff at the midpoint.

https://www.tradingview.com/x/LmuP2XJY/ [Screenshot: Premium & Discount Zones]
In addition to premium and discount positioning, other contextual factors can be used to describe how an FVG forms within the broader price environment. These include whether the FVG appears after a liquidity sweep, whether it is positioned within a higher timeframe FVG, and whether it forms during specific session windows. These elements provide additional structure for evaluating the formation context.

This axis evaluates four sub-metrics. Premium and Discount scoring (0 to 8 points) uses a proportional gradient across the recent price range defined by the Range Lookback setting. For bullish FVGs, gaps forming in the lower half of the range (below equilibrium) receive the full 8 points. Gaps forming above equilibrium receive a reduced score that decreases progressively as the FVG approaches the top of the range. The same logic is applied in reverse for bearish FVGs.
HTF FVG nesting (0 to 8 points) evaluates whether the current FVG is fully contained within a higher timeframe FVG of the same direction. The indicator retrieves higher timeframe data using the configurable HTF input and checks for this containment condition.

Post-sweep proximity (0 to 5 points) evaluates whether a swing level was exceeded shortly before the FVG formed. A sweep is defined as price moving beyond a swing high or swing low and then returning back within the prior range. This metric checks for that condition within a configurable lookback window.

Killzone timing (0 to 4 points) evaluates whether the FVG forms during predefined session windows. The indicator converts bar time to New York time and checks against four intervals: Asian session (20:00 to 00:00), London session (02:00 to 05:00), New York AM (09:30 to 11:00), and New York PM (13:30 to 16:00).

https://www.tradingview.com/x/XfAEoVAD/ [Screenshot: Chart showing an FVG forming in the premium zone (upper half of recent range) ]

[b]Axis 4: Structural Alignment (0 to 25 points)[/b]
Market structure provides a framework for describing how price is evolving over time. This axis evaluates how the direction of an FVG relates to the current structure defined by swing highs and swing lows.

The indicator identifies swing highs and swing lows using pivot detection with a configurable swing length and evaluates three sub-metrics. Market structure classification (0 to 10 points) compares the most recent swing highs and swing lows to determine whether price is forming higher highs and higher lows, lower highs and lower lows, or a mixed sequence. These conditions are labeled as bullish, bearish, or mixed. Scoring is then assigned based on the relationship between the FVG direction and the identified structure.

EMA alignment (0 to 8 points) evaluates the position of price relative to a configurable Exponential Moving Average (default 50 period). For bullish FVGs, higher scores are assigned when price is positioned above the EMA, while for bearish FVGs, higher scores are assigned when price is positioned below the EMA. Scores are reduced when price is positioned on the opposite side relative to the FVG direction.

Recent BOS detection (0 to 7 points) evaluates whether a Break of Structure (BOS) has occurred within a configurable lookback window (default 20 bars). A BOS is defined as price closing beyond a recent swing high or swing low. The indicator uses crossover logic to identify these events and ensures each structural break is only counted once. Scoring is based on whether a recent BOS aligns with, differs from, or is absent relative to the FVG direction.

https://www.tradingview.com/x/CkQN6rqr/ Screenshot: Showing BoS and HH

[b]Grade Assignment System[/b]
Instead of using a single composite score cutoff, FVG Quality Scorer applies a per-axis threshold system for grade assignment. For each grade level (A, B, C), you can define which axes are required and the minimum score each must meet. An FVG must satisfy all required axis thresholds to be assigned a given grade. This structure ensures that each selected dimension is evaluated independently rather than relying on a single averaged value.

For example, with default settings, an A grade requires all four axes to meet a minimum score of 12 out of 25. A B grade requires only the Displacement and Volume axes to meet a minimum of 12, while a C grade requires those same axes to meet a minimum of 8. Any FVG that does not meet the criteria for A, B, or C is assigned a D grade. These thresholds and required axes can be fully customized for each grade level.

A weighted composite score (0 to 100) is also calculated and displayed in the score label tooltip for reference, but it does not determine the assigned grade. This allows the grading system to operate independently of the composite value. The composite score uses configurable axis weights (default 25 per axis), which can be adjusted to modify how each dimension contributes to the total score.

https://www.tradingview.com/x/4p7KI32T/ [Screenshot: Show multiple FVGs with different grades side by side]

[b]Lifecycle State Machine[/b]
Each FVG is tracked through a series of lifecycle states as price interacts with the zone, and these transitions occur automatically regardless of grade. The lifecycle begins at Fresh when the FVG forms and no candle has interacted with the zone boundary. When price first wicks into the boundary (detected using crossover logic that excludes the formation candle), the state transitions to Tested.

If price closes within the zone, the state changes to Partially Filled, and the visual appearance of the box is adjusted to reflect this state. If price later closes back outside the zone, the state returns to Tested rather than Fresh, as the zone has already been interacted with. When price fully crosses through the zone, the FVG is marked as Mitigated. The definition of mitigation can be configured to require either a wick crossing or a full candle close beyond the zone.

Mitigated FVGs can either be removed from the chart or remain visible as dimmed boxes using the Show Historic setting. When mitigation occurs, the right edge of the box is fixed at the candle where the event took place. The current lifecycle state is displayed in the tooltip alongside the scoring breakdown when hovering over the score label.

https://www.tradingview.com/x/nyAfLBlG/ [Screenshot: Chart showing FVGs in different lifecycle states on the same view.]

🔹 Dashboard
The dashboard provides a statistical summary of FVG activity across the visible chart history. It is structured as a table with one row per grade (A through D) and three data columns. The Active column displays the number of unmitigated FVGs currently present on the chart for each grade. The Total column shows the total number of FVGs formed for each grade across the chart history. The Avg Fill Time column displays the average number of bars between formation and mitigation for FVGs of that grade that have been fully mitigated. This calculation includes only completed (mitigated) FVGs.

A bottom row in the dashboard tracks the nearest active A-grade FVG relative to the current price. It displays the distance from the current close to the nearest boundary of the zone (the lower boundary if the FVG is above price, or the upper boundary if below), along with a directional indicator. If price is currently within an A-grade zone, the dashboard displays “Inside zone.” If no A-grade FVGs are active, it displays “None active.” The dashboard position and text size can be configured.

https://www.tradingview.com/x/OFSxWbKA/ Screenshot: Close up of the dashboard table showing all four grade rows with Active, Total, and Avg Fill Time populated. Include the Nearest A row showing a directional arrow with distance.

🔹 Score Labels and Tooltips
Each FVG box displays its grade letter (A, B, C, or D) centered inside the zone. At the right edge of the box, a small label shows the composite quality score out of 100. Hovering over this label reveals a detailed tooltip with the complete scoring breakdown: the total score, the grade, individual scores for all four axes (each out of 25), and the current lifecycle state. This gives you instant access to why a particular FVG earned its grade without needing to open any settings. Score labels can be toggled off using the Show Score Labels setting if you prefer a cleaner chart.

[b]INPUTS:[/b]
🔹 Settings
◇ Swing Length: Lookback period for pivot high and pivot low detection used in market structure analysis, BOS tracking, and sweep detection. Higher values produce fewer, more significant swing points. Default 5.
◇ ATR Length: Period for the Average True Range calculation used in displacement scoring. Default 14.
◇ LTF for Volume Delta: Lower timeframe used to calculate intrabar volume delta on the displacement candle. Default 1 minute. Must be lower than the chart timeframe for accurate results.
◇ HTF for FVG Nesting: Higher timeframe checked for FVG nesting confluence. Default 60 minutes (1 hour). Should be higher than the chart timeframe.
◇ Range Lookback: Number of bars used to calculate the premium and discount range for contextual scoring. Default 50.
◇ Sweep Proximity Window: Number of bars to look back for recent liquidity sweeps when scoring post sweep proximity. Default 5.
◇ BOS/CHoCH Lookback: Maximum number of bars a Break of Structure can be from the current bar and still be considered "recent" for structural scoring. Default 20.
◇ EMA Length: Period for the Exponential Moving Average used in structural alignment scoring. Default 50.
◇ Mitigation Method: Determines how FVG invalidation is measured. Wick mode triggers mitigation when a wick crosses through the zone. Close mode requires a candle close beyond the zone. Default Wick.
https://www.tradingview.com/x/5gMZIE4u/ Screenshot of the Settings input group in TradingView showing all the configurable parameters: Swing Length, ATR Length, LTF, HTF, Range Lookback, Sweep Window, BOS Lookback, EMA Length, and Mitigation Method. 

🔹 Axis Weights
◇ Displacement Weight: Relative weight applied to the Displacement Strength axis when calculating the composite score displayed in the tooltip. Higher weight increases this axis's influence on the total score. Default 25.
◇ Volume Delta Weight: Relative weight for the Volume Delta axis. Default 25.
◇ Contextual Weight: Relative weight for the Contextual Location axis. Default 25.
◇ Structural Weight: Relative weight for the Structural Alignment axis. Default 25.

🔹 Display
◇ Minimum Display Grade: Hides FVGs below this grade threshold from the chart. Set to D to show all grades, or A to show only the highest quality gaps. Default C.
◇ Show Historic (Mitigated): When enabled, mitigated FVGs remain visible as grayed out boxes instead of being removed from the chart. Useful for studying how different grade levels performed historically. Default off.
◇ Show Score Labels: Toggles the score labels at the right edge of each FVG box. Hover over the label to see the full axis breakdown tooltip. Default on.
◇ Grade Colors (A → D): Four color pickers on a single row controlling the color for each grade tier. Defaults are green (A), teal (B), amber (C), and gray (D).

🔹 Dashboard
◇ Show Dashboard: Toggles the statistics dashboard on or off. Default on.
◇ Dashboard Position: Choose from all nine screen positions (top, middle, bottom combined with left, center, right). Default Top Right.
◇ Dashboard Size: Controls the text size of the dashboard. Options are Tiny, Small, Normal, and Large. Default Small.

🔹 A Grade / B Grade / C Grade
◇ Each grade tier has its own settings group with four minimum score thresholds (one per axis, 0 to 25) and four toggle switches to select which axes are required for that grade. An FVG must meet or exceed the minimum score on every required axis to earn the grade. Grades are checked top down: A first, then B, then C. Any FVG that fails all three checks receives a D grade. Unchecking a required axis means that axis is ignored for that grade's evaluation, allowing you to create grade profiles that focus on specific quality dimensions.
https://www.tradingview.com/x/nhTB8u2Q/  Screenshot of the settings panel showing the A Grade, and B Grade input groups with their min score thresholds and require toggles visible.

[b]ALERTS:[/b]
◇ New A Grade FVG: Fires when a new Fair Value Gap is detected that meets all A grade requirements. Use this to get notified of the highest quality setups without watching the chart continuously.
◇ New B Grade FVG: Fires when a new Fair Value Gap is detected that meets B grade requirements but does not qualify for A grade.

[b]UNIQUENESS:[/b]
Many FVG indicators on TradingView focus on detecting gaps and may include basic filtering based on size or direction. FVG Quality Scorer extends this approach by evaluating each gap across multiple dimensions, including lower timeframe volume distribution, higher timeframe positioning, market structure classification, and session-based context. These factors are combined into a structured scoring framework.

The axis-based grading system provides an alternative to single-threshold scoring methods. Instead of relying on a single composite cutoff, each grade level is determined by minimum requirements across selected axes. This ensures that each specified dimension meets defined criteria rather than being offset by higher values in other areas.

The lifecycle state system tracks how each FVG evolves as price interacts with the zone, while the dashboard aggregates metrics such as counts and average bars to mitigation across grade levels. These features provide a structured way to review how FVGs have behaved over the selected chart history and to adjust grading configurations accordingly.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fluxchart

//@version=6
indicator("FVG Quality Scorer | Flux Charts", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 5000)

//#region CONSTANTS

GP_SCORE      = "Settings"
GP_WEIGHT     = "Axis Weights"
GP_DISP       = "Display"
GP_DASH       = "Dashboard"

TT_LTF        = "Lower timeframe used to calculate intrabar volume delta. Use '1' for 1-minute."
TT_HTF        = "Higher timeframe to check for FVG nesting confluence."
TT_WEIGHT     = "Relative weight for this scoring axis. All weights are normalized to 100."
TT_GRADE      = "Hide FVGs below this grade threshold."
TT_MIT        = "Wick: invalidated when wick crosses zone. Close: invalidated when close crosses zone."
TT_HIST       = "When enabled, mitigated FVGs remain visible as gray boxes."

STATE_FRESH   = "Fresh"
STATE_TESTED  = "Tested"
STATE_PARTIAL = "PartiallyFilled"
STATE_MIT     = "Mitigated"

EXTEND_BARS   = 20

GREEN         = #00C853
TEAL          = #00BFA5
AMBER         = #FFC107
GRAY          = #9E9E9E
DASH_DARK     = #1a1a2e
DASH_MID      = #16213e
DASH_ROW      = #0f3460

//#endregion CONSTANTS

//#region INPUTS

//#region Settings
swingLen   = input.int(5,              "Swing Length",              minval = 2, maxval = 50,        group = GP_SCORE,  display = display.none)
atrLen     = input.int(14,             "ATR Length",                minval = 5, maxval = 50,        group = GP_SCORE,  display = display.none)
ltfTf      = input.timeframe("1",      "LTF for Volume Delta",                                      group = GP_SCORE,  display = display.none, tooltip = TT_LTF)
htfTf      = input.timeframe("60",     "HTF for FVG Nesting",                                       group = GP_SCORE,  display = display.none, tooltip = TT_HTF)
rangeLb    = input.int(50,             "Range Lookback",            minval = 10, maxval = 200,      group = GP_SCORE,  display = display.none)
sweepWin   = input.int(5,              "Sweep Proximity Window",    minval = 1, maxval = 20,        group = GP_SCORE,  display = display.none)
bosLb      = input.int(20,             "BOS/CHoCH Lookback",        minval = 5, maxval = 50,        group = GP_SCORE,  display = display.none)
emaLen     = input.int(50,             "EMA Length",                minval = 10, maxval = 200,      group = GP_SCORE,  display = display.none)
//#endregion Settings

//#region Axis Weights
dispW      = input.int(25,             "Displacement Weight",       minval = 0, maxval = 100,       group = GP_WEIGHT, display = display.none, tooltip = TT_WEIGHT)
volW       = input.int(25,             "Volume Delta Weight",       minval = 0, maxval = 100,       group = GP_WEIGHT, display = display.none, tooltip = TT_WEIGHT)
ctxW       = input.int(25,             "Contextual Weight",         minval = 0, maxval = 100,       group = GP_WEIGHT, display = display.none, tooltip = TT_WEIGHT)
strW       = input.int(25,             "Structural Weight",         minval = 0, maxval = 100,       group = GP_WEIGHT, display = display.none, tooltip = TT_WEIGHT)
//#endregion Axis Weights

//#region Display
minGrade   = input.string("C",         "Minimum Display Grade",     options = ["A", "B", "C", "D"], group = GP_DISP,   display = display.none, tooltip = TT_GRADE)
showHist   = input.bool(false,         "Show Historic (Mitigated)",                                 group = GP_DISP,   display = display.none, tooltip = TT_HIST)
showLabels = input.bool(true,          "Show Score Labels",                                         group = GP_DISP,   display = display.none)
colA       = input.color(GREEN,        "Grade Colors (A → D)",      inline = "gradeColors",         group = GP_DISP,   display = display.none)
colB       = input.color(TEAL,         "",                          inline = "gradeColors",         group = GP_DISP,   display = display.none)
colC       = input.color(AMBER,        "",                          inline = "gradeColors",         group = GP_DISP,   display = display.none)
colD       = input.color(GRAY,         "",                          inline = "gradeColors",         group = GP_DISP,   display = display.none)
//#endregion Display

mitMethod  = input.string("Wick",      "Mitigation Method",         options = ["Close", "Wick"],    group = GP_SCORE,  display = display.none, tooltip = TT_MIT)

//#region Dashboard
showDash   = input.bool(true,          "Show Dashboard",                                            group = GP_DASH)
dashPos    = input.string("Top Right", "Dashboard Position",        options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = GP_DASH,   display = display.none)
dashSize   = input.string("Small",     "Dashboard Size",            options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = GP_DASH,   display = display.none)
//#endregion Dashboard

//#region A-Grade Requirements
aMinDisp   = input.int(12,             "A: Min Displacement Score", minval = 0, maxval = 25,        group = "A Grade", display = display.none)
aMinVol    = input.int(12,             "A: Min Volume Score",       minval = 0, maxval = 25,        group = "A Grade", display = display.none)
aMinCtx    = input.int(12,             "A: Min Contextual Score",   minval = 0, maxval = 25,        group = "A Grade", display = display.none)
aMinStr    = input.int(12,             "A: Min Structural Score",   minval = 0, maxval = 25,        group = "A Grade", display = display.none)
aReqDisp   = input.bool(true,          "A: Require Displacement",                                   group = "A Grade", display = display.none)
aReqVol    = input.bool(true,          "A: Require Volume",                                         group = "A Grade", display = display.none)
aReqCtx    = input.bool(true,          "A: Require Contextual",                                     group = "A Grade", display = display.none)
aReqStr    = input.bool(true,          "A: Require Structural",                                     group = "A Grade", display = display.none)
//#endregion A-Grade Requirements

//#region B-Grade Requirements
bMinDisp   = input.int(12,             "B: Min Displacement Score", minval = 0, maxval = 25,        group = "B Grade", display = display.none)
bMinVol    = input.int(12,             "B: Min Volume Score",       minval = 0, maxval = 25,        group = "B Grade", display = display.none)
bMinCtx    = input.int(12,             "B: Min Contextual Score",   minval = 0, maxval = 25,        group = "B Grade", display = display.none)
bMinStr    = input.int(12,             "B: Min Structural Score",   minval = 0, maxval = 25,        group = "B Grade", display = display.none)
bReqDisp   = input.bool(true,          "B: Require Displacement",                                   group = "B Grade", display = display.none)
bReqVol    = input.bool(true,          "B: Require Volume",                                         group = "B Grade", display = display.none)
bReqCtx    = input.bool(false,         "B: Require Contextual",                                     group = "B Grade", display = display.none)
bReqStr    = input.bool(false,         "B: Require Structural",                                     group = "B Grade", display = display.none)
//#endregion B-Grade Requirements

//#region C-Grade Requirements
cMinDisp   = input.int(8,              "C: Min Displacement Score", minval = 0, maxval = 25,        group = "C Grade", display = display.none)
cMinVol    = input.int(8,              "C: Min Volume Score",       minval = 0, maxval = 25,        group = "C Grade", display = display.none)
cMinCtx    = input.int(8,              "C: Min Contextual Score",   minval = 0, maxval = 25,        group = "C Grade", display = display.none)
cMinStr    = input.int(8,              "C: Min Structural Score",   minval = 0, maxval = 25,        group = "C Grade", display = display.none)
cReqDisp   = input.bool(true,          "C: Require Displacement",                                   group = "C Grade", display = display.none)
cReqVol    = input.bool(true,          "C: Require Volume",                                         group = "C Grade", display = display.none)
cReqCtx    = input.bool(false,         "C: Require Contextual",                                     group = "C Grade", display = display.none)
cReqStr    = input.bool(false,         "C: Require Structural",                                     group = "C Grade", display = display.none)
//#endregion C-Grade Requirements

//#endregion INPUTS

//#region DECLARATIONS

//#region USER-DEFINED TYPES

type FVG
    int     formedAt
    float   top
    float   bottom
    bool    isBullish
    string  state
    int     dispScore
    int     volScore
    int     ctxScore
    int     strScore
    int     totalScore
    string  grade
    int     mitigatedAt = na

//#endregion USER-DEFINED TYPES

//#endregion DECLARATIONS

//#region CALCULATIONS

//#region GLOBAL CALCULATIONS

atrVal   = ta.atr(atrLen)
ema50    = ta.ema(close, emaLen)
volSma20 = ta.sma(volume, 20)

//#region Swing Highs / Lows for Market Structure

pivHi = ta.pivothigh(high, swingLen, swingLen)
pivLo = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh    = na
var float prevSwingHigh    = na
var int   lastSwingHighBar = na
var float lastSwingLow     = na
var float prevSwingLow     = na
var int   lastSwingLowBar  = na

if not na(pivHi)
    prevSwingHigh    := lastSwingHigh
    lastSwingHigh    := pivHi
    lastSwingHighBar := bar_index - swingLen

if not na(pivLo)
    prevSwingLow    := lastSwingLow
    lastSwingLow    := pivLo
    lastSwingLowBar := bar_index - swingLen

//#endregion Swing Highs / Lows for Market Structure

//#region BOS Tracking

var int    lastBosBar      = na
var bool   lastBosBull     = false
var float  brokenSwingHigh = na
var float  brokenSwingLow  = na

if not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh and lastSwingHigh != brokenSwingHigh
    lastBosBar      := bar_index
    lastBosBull     := true
    brokenSwingHigh := lastSwingHigh

if not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow and lastSwingLow != brokenSwingLow
    lastBosBar     := bar_index
    lastBosBull    := false
    brokenSwingLow := lastSwingLow

//#endregion BOS Tracking

//#region LTF Volume Delta via request.security_lower_tf

[ltfBullVol, ltfBearVol] = request.security_lower_tf(syminfo.tickerid, ltfTf, [close > open ? volume : 0.0, close <= open ? volume : 0.0])

sumBullVol = 0.0
sumBearVol = 0.0

if not na(ltfBullVol) and ltfBullVol.size() > 0
    for i = 0 to ltfBullVol.size() - 1
        sumBullVol += ltfBullVol.get(i)
        sumBearVol += ltfBearVol.get(i)

// sumBullVol[1] / sumBearVol[1] used in scoreVolumeDelta for displacement candle

//#endregion LTF Volume Delta via request.security_lower_tf

//#region HTF FVG Nesting Data

[htfHigh0, htfLow0, htfHigh2, htfLow2] = request.security(syminfo.tickerid, htfTf, [high, low, high[2], low[2]], lookahead = barmerge.lookahead_off)

//#endregion HTF FVG Nesting Data

//#region Killzone Detection (New York Time)

nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
nyTime   = nyHour * 100 + nyMinute

inKillzone() =>
    inAsian  = nyTime >= 2000
    inLondon = nyTime >= 200 and nyTime < 500
    inNYAM   = nyTime >= 930 and nyTime < 1100
    inNYPM   = nyTime >= 1330 and nyTime < 1600
    inAsian or inLondon or inNYAM or inNYPM

isKillzone = inKillzone()

//#endregion Killzone Detection (New York Time)

//#region Range for Premium / Discount

rangeHigh = ta.highest(high, rangeLb)
rangeLow  = ta.lowest(low, rangeLb)
rangeMid  = (rangeHigh + rangeLow) / 2.0

//#endregion Range for Premium / Discount
//#endregion GLOBAL CALCULATIONS

//#region FVG STORAGE

var fvgArr = array.new<FVG>()

// Dashboard stats
var aTotal     = 0
var aBarsSum   = 0
var aBarsCount = 0
var bTotal     = 0
var bBarsSum   = 0
var bBarsCount = 0
var cTotal     = 0
var cBarsSum   = 0
var cBarsCount = 0
var dTotal     = 0
var dBarsSum   = 0
var dBarsCount = 0

//#endregion FVG STORAGE

//#endregion CALCULATIONS

//#region FUNCTIONS

//#region HELPER FUNCTIONS

gradeColor(string g) =>
    switch g
        "A" => colA
        "B" => colB
        "C" => colC
        => colD

gradeMinScore(string g) =>
    switch g
        "A" => 75
        "B" => 50
        "C" => 25
        => 0

passesFilter(string g) =>
    minS               = gradeMinScore(minGrade)
    gScore             = gradeMinScore(g)
    gScore >= minS

dashPosition() =>
    switch dashPos
        "Top Right"      => position.top_right
        "Top Center"     => position.top_center
        "Top Left"       => position.top_left
        "Middle Right"   => position.middle_right
        "Middle Center"  => position.middle_center
        "Middle Left"    => position.middle_left
        "Bottom Right"   => position.bottom_right
        "Bottom Center"  => position.bottom_center
        => position.bottom_left

dashTextSize() =>
    switch dashSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

avgBars(int sumBars, int count) =>
    count > 0 ? str.tostring(math.round(sumBars / count)) + " Bars" : "—"

//#endregion HELPER FUNCTIONS

//#region Axis 1: Displacement Strength

scoreDisplacement(bool isBull) =>
    // Body-to-range ratio (0-10)
    bodyRange = high[1] - low[1]
    ratio     = bodyRange > 0 ? math.abs(close[1] - open[1]) / bodyRange : 0.0
    ptsBody   = ratio >= 0.85 ? 10 : ratio >= 0.70 ? 7 : ratio >= 0.55 ? 4 : 0

    // ATR multiple (0-10)
    mult   = atrVal > 0 ? bodyRange / atrVal : 0.0
    ptsATR = mult >= 2.0 ? 10 : mult >= 1.5 ? 7 : mult >= 1.0 ? 4 : 0

    // Consecutive displacement (0-5)
    bar3Aligned = isBull ? close[2] > open[2] : close[2] < open[2]
    bar1Aligned = isBull ? close > open : close < open
    alignCount  = (bar3Aligned ? 1 : 0) + (bar1Aligned ? 1 : 0)
    ptsConsec   = alignCount == 2 ? 5 : alignCount == 1 ? 2 : 0

    ptsBody + ptsATR + ptsConsec

//#endregion Axis 1: Displacement Strength

//#region Axis 2: Volume Delta

scoreVolumeDelta(bool isBull) =>
    // LTF bull/bear dominance (0-12) — displacement candle's (bar N-1) LTF data
    totalVol  = sumBullVol[1] + sumBearVol[1]
    dominance = totalVol > 0 ? (isBull ? sumBullVol[1] / totalVol : sumBearVol[1] / totalVol) : 0.0
    ptsDom    = dominance > 0.75 ? 12 : dominance >= 0.60 ? 8 : dominance >= 0.50 ? 4 : 0

    // Relative volume (0-8)
    relVol = volSma20 > 0 ? volume[1] / volSma20 : 0.0
    ptsRel = relVol > 2.0 ? 8 : relVol >= 1.5 ? 5 : relVol >= 1.0 ? 2 : 0

    // Volume rising into gap (0-5)
    rising  = volume[1] > volume[2] and volume[2] > volume[3]
    ptsRise = rising ? 5 : 0

    ptsDom + ptsRel + ptsRise

//#endregion Axis 2: Volume Delta

//#region Axis 3: Contextual Location

scoreContextual(bool isBull, float fvgTop, float fvgBottom) =>
    fvgMid = (fvgTop + fvgBottom) / 2.0

    // Premium/Discount zone (0-8)
    // Full points in favorable half, gradient in unfavorable half
    rangeSize = rangeHigh - rangeLow
    ptsPD     = 0
    if rangeSize > 0
        pos = (fvgMid - rangeLow) / rangeSize
        if isBull
            // Below midpoint = discount = 8 pts, above midpoint = gradient 4→0
            ptsPD := pos <= 0.5 ? 8 : math.round((1.0 - pos) * 8.0)
        else
            // Above midpoint = premium = 8 pts, below midpoint = gradient 4→0
            ptsPD := pos >= 0.5 ? 8 : math.round(pos * 8.0)

    // HTF FVG nesting (0-8)
    ptsHTF     = 0
    htfBullFvg = not na(htfLow0) and not na(htfHigh2) and htfLow0 > htfHigh2
    htfBearFvg = not na(htfHigh0) and not na(htfLow2) and htfHigh0 < htfLow2
    if isBull and htfBullFvg
        htfFvgTop = htfLow0
        htfFvgBot = htfHigh2
        if fvgTop <= htfFvgTop and fvgBottom >= htfFvgBot
            ptsHTF := 8
    else if not isBull and htfBearFvg
        htfFvgTop = htfLow2
        htfFvgBot = htfHigh0
        if fvgTop <= htfFvgTop and fvgBottom >= htfFvgBot
            ptsHTF := 8

    // Post-sweep proximity (0-5)
    ptsSweep = 0
    for i = 1 to sweepWin
        if isBull
            swingLowAtI = lastSwingLow[i]
            if not na(swingLowAtI) and low[i] < swingLowAtI and close[i] > swingLowAtI
                ptsSweep := 5
                break
        if not isBull
            swingHighAtI = lastSwingHigh[i]
            if not na(swingHighAtI) and high[i] > swingHighAtI and close[i] < swingHighAtI
                ptsSweep := 5
                break

    // Killzone timing (0-4)
    ptsKZ = isKillzone ? 4 : 0

    ptsPD + ptsHTF + ptsSweep + ptsKZ

//#endregion Axis 3: Contextual Location

//#region Axis 4: Structural Alignment

scoreStructural(bool isBull) =>
    // Market structure bias (0-10)
    bullStruct = not na(prevSwingHigh) and not na(prevSwingLow) and lastSwingHigh > prevSwingHigh and lastSwingLow > prevSwingLow
    bearStruct = not na(prevSwingHigh) and not na(prevSwingLow) and lastSwingHigh < prevSwingHigh and lastSwingLow < prevSwingLow

    ptsMkt = 0
    if isBull
        ptsMkt := bullStruct ? 10 : bearStruct ? 0 : 2
    else
        ptsMkt := bearStruct ? 10 : bullStruct ? 0 : 2

    // EMA alignment (0-8)
    ptsEma = 0
    if isBull and close > ema50
        ptsEma := 8
    else if not isBull and close < ema50
        ptsEma := 8

    // Recent BOS/CHoCH (0-7)
    ptsBos = 2
    if not na(lastBosBar) and (bar_index - lastBosBar) <= bosLb
        if isBull and lastBosBull
            ptsBos := 7
        else if not isBull and not lastBosBull
            ptsBos := 7
        else
            ptsBos := 0

    ptsMkt + ptsEma + ptsBos

//#endregion Axis 4: Structural Alignment

//#region Weighted Total

calcWeightedTotal(int dsp, int vol, int ctx, int str_score) =>
    wSum                                                    = dispW + volW + ctxW + strW
    dW                                                      = wSum > 0 ? dispW : 25.0
    vW                                                      = wSum > 0 ? volW  : 25.0
    cW                                                      = wSum > 0 ? ctxW  : 25.0
    sW                                                      = wSum > 0 ? strW  : 25.0
    ws                                                      = wSum > 0 ? wSum : 100.0
    weighted                                                = (dsp / 25.0) * dW + (vol / 25.0) * vW + (ctx / 25.0) * cW + (str_score / 25.0) * sW
    result                                                  = math.round(weighted * (100.0 / ws))
    math.min(result, 100)

getGrade(int dsp, int vol, int ctx, int str_score) =>
    aPass                                          = (not aReqDisp or dsp >= aMinDisp) and (not aReqVol or vol >= aMinVol) and (not aReqCtx or ctx >= aMinCtx) and (not aReqStr or str_score >= aMinStr)
    bPass                                          = (not bReqDisp or dsp >= bMinDisp) and (not bReqVol or vol >= bMinVol) and (not bReqCtx or ctx >= bMinCtx) and (not bReqStr or str_score >= bMinStr)
    cPass                                          = (not cReqDisp or dsp >= cMinDisp) and (not cReqVol or vol >= cMinVol) and (not cReqCtx or ctx >= cMinCtx) and (not cReqStr or str_score >= cMinStr)
    aPass ? "A" : bPass ? "B" : cPass ? "C" : "D"

//#endregion Weighted Total

//#region FVG DETECTION

bullFVG = low > high[2]
bearFVG = high < low[2]

//#endregion FVG DETECTION

//#region TOOLTIP BUILDER

buildTooltip(int dsp, int vol, int ctx, int str_score, int total, string g, string st) =>
    str.format("FVG Quality Score: {0}/100 ({1})\n──────────────────\nDisplacement: {2}/25\nVolume Delta: {3}/25\nContextual:   {4}/25\nStructural:   {5}/25\n──────────────────\nState: {6}", total, g, dsp, vol, ctx, str_score, st)

//#endregion TOOLTIP BUILDER

//#endregion FUNCTIONS

//#region EXECUTION

//#region CREATE NEW FVGs

isBullDetect = bullFVG
fvgTop       = isBullDetect ? low : low[2]
fvgBottom    = isBullDetect ? high[2] : high

// Call scoring functions on every bar for series consistency
dspScore   = scoreDisplacement(isBullDetect)
volScore   = scoreVolumeDelta(isBullDetect)
ctxScore   = scoreContextual(isBullDetect, fvgTop, fvgBottom)
strScore   = scoreStructural(isBullDetect)
totalScore = calcWeightedTotal(dspScore, volScore, ctxScore, strScore)
gradeVal   = getGrade(dspScore, volScore, ctxScore, strScore)

if bullFVG or bearFVG
    // Dashboard tracking
    switch gradeVal
        "A" => aTotal += 1
        "B" => bTotal += 1
        "C" => cTotal += 1
        "D" => dTotal += 1

    newFvg = FVG.new(bar_index, fvgTop, fvgBottom, isBullDetect, STATE_FRESH, dspScore, volScore, ctxScore, strScore, totalScore, gradeVal)
    fvgArr.push(newFvg)

//#endregion CREATE NEW FVGs

//#region LIFECYCLE STATE MANAGEMENT

if fvgArr.size() > 0
    for i = fvgArr.size() - 1 to 0
        fvg = fvgArr.get(i)

        if fvg.state == STATE_MIT
            continue

        isBull = fvg.isBullish
        top    = fvg.top
        bot    = fvg.bottom

        // Check mitigation
        mitigated = false
        if mitMethod == "Close"
            mitigated := isBull ? close < bot : close > top
        else
            mitigated := isBull ? low < bot : high > top

        if mitigated
            fvg.state := STATE_MIT
            fvg.mitigatedAt := bar_index
            barsAlive = bar_index - fvg.formedAt
            switch fvg.grade
                "A" =>
                    aBarsSum += barsAlive
                    aBarsCount += 1
                "B" =>
                    bBarsSum += barsAlive
                    bBarsCount += 1
                "C" =>
                    cBarsSum += barsAlive
                    cBarsCount += 1
                "D" =>
                    dBarsSum += barsAlive
                    dBarsCount += 1
            continue

        // Check partially filled
        partial = false
        if isBull
            partial := close < top and close > bot
        else
            partial := close > bot and close < top

        if partial and fvg.state != STATE_PARTIAL
            fvg.state := STATE_PARTIAL

        // Check tested (price touched zone boundary but didn't enter)
        else if not partial and fvg.state == STATE_FRESH
            tested = false
            if isBull
                tested := low <= top and low[1] >= top
            else
                tested := high >= bot and high[1] <= bot
            if tested
                fvg.state := STATE_TESTED

        // Revert from partial to tested if price exits
        else if not partial and fvg.state == STATE_PARTIAL
            fvg.state := STATE_TESTED

//#endregion LIFECYCLE STATE MANAGEMENT

//#region MEMORY MANAGEMENT

while fvgArr.size() > 200
    fvgArr.shift()

//#endregion MEMORY MANAGEMENT

//#endregion EXECUTION

//#region VISUALS

//#region DEFERRED DRAWING (barstate.islast only)

var drawnBoxes  = array.new<box>()
var drawnLabels = array.new<label>()

if barstate.islast
    // Clean up previous drawings
    if drawnBoxes.size() > 0
        for i = 0 to drawnBoxes.size() - 1
            box.delete(drawnBoxes.get(i))
    if drawnLabels.size() > 0
        for i = 0 to drawnLabels.size() - 1
            label.delete(drawnLabels.get(i))
    drawnBoxes.clear()
    drawnLabels.clear()

    // Draw all FVGs from array
    if fvgArr.size() > 0
        for i = 0 to fvgArr.size() - 1
            fvg = fvgArr.get(i)

            if not passesFilter(fvg.grade)
                continue

            if fvg.state == STATE_MIT and not showHist
                continue

            gradeCol  = gradeColor(fvg.grade)
            bgCol     = color.new(gradeCol, 80)
            borderCol = color.new(gradeCol, 50)

            // Dim for partial fill
            if fvg.state == STATE_PARTIAL
                bgCol := color.new(gradeCol, 90)

            // Gray out mitigated
            if fvg.state == STATE_MIT
                bgCol     := color.new(colD, 90)
                borderCol := color.new(colD, 70)
                gradeCol  := color.new(colD, 50)

            // Right edge: mitigated = freeze at mitigatedAt, active = extend
            rightEdge = not na(fvg.mitigatedAt) ? fvg.mitigatedAt : bar_index + EXTEND_BARS

            box bx = box.new(fvg.formedAt - 2, fvg.top, rightEdge, fvg.bottom, border_color = borderCol, bgcolor = bgCol, border_width = 1, text = fvg.grade, text_color = gradeCol, text_size = size.normal, text_halign = text.align_center, text_valign = text.align_center)
            drawnBoxes.push(bx)

            if showLabels
                ttText   = buildTooltip(fvg.dispScore, fvg.volScore, fvg.ctxScore, fvg.strScore, fvg.totalScore, fvg.grade, fvg.state)
                label lb = label.new(rightEdge, (fvg.top + fvg.bottom) / 2.0, str.tostring(fvg.totalScore), style = label.style_label_left, color = color.new(gradeCol, 60), textcolor = gradeCol, size = size.small, tooltip = ttText)
                drawnLabels.push(lb)

//#endregion DEFERRED DRAWING (barstate.islast only)

//#region DASHBOARD

var table dash = na

if showDash and na(dash)
    dash := table.new(dashPosition(), 4, 7, border_width = 1, border_color = color.new(color.gray, 60), frame_width = 2, frame_color = color.new(color.gray, 40))

    txtSize = dashTextSize()

    // Header
    table.cell(dash, 0, 0, "FVG Quality Scorer", text_color = color.white, text_size = txtSize, bgcolor = color.new(DASH_DARK, 0), text_halign = text.align_center)
    table.merge_cells(dash, 0, 0, 3, 0)

    // Column headers
    table.cell(dash, 0, 1, "Grade", text_color         = color.white, text_size = txtSize, bgcolor = color.new(DASH_MID, 0), text_halign = text.align_center)
    table.cell(dash, 1, 1, "Active", text_color        = color.white, text_size = txtSize, bgcolor = color.new(DASH_MID, 0), text_halign = text.align_center)
    table.cell(dash, 2, 1, "Total", text_color         = color.white, text_size = txtSize, bgcolor = color.new(DASH_MID, 0), text_halign = text.align_center)
    table.cell(dash, 3, 1, "Avg Fill Time", text_color = color.white, text_size = txtSize, bgcolor = color.new(DASH_MID, 0), text_halign = text.align_center, tooltip = "Average number of bars from FVG creation to mitigation (mitigated FVGs only)")

    // Grade letter cells (static)
    rowBg                                  = color.new(DASH_ROW, 0)
    table.cell(dash, 0, 2, "A", text_color = colA, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 0, 3, "B", text_color = colB, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 0, 4, "C", text_color = colC, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 0, 5, "D", text_color = colD, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)

if showDash and barstate.islast
    txtSize = dashTextSize()
    rowBg   = color.new(DASH_ROW, 0)

    // Count active per grade
    aActive            = 0
    bActive            = 0
    cActive            = 0
    dActive            = 0
    float nearestADist = na
    nearestAAbove      = false

    for i = 0 to fvgArr.size() - 1
        fvg = fvgArr.get(i)
        if fvg.state != STATE_MIT
            switch fvg.grade
                "A" => aActive += 1
                "B" => bActive += 1
                "C" => cActive += 1
                "D" => dActive += 1

            // Track nearest A-grade
            if fvg.grade == "A"
                isInside = close <= fvg.top and close >= fvg.bottom
                dist     = 0.0
                isAbove  = false
                if isInside
                    dist := 0.0
                else
                    isAbove := fvg.bottom > close
                    edge = isAbove ? fvg.bottom : fvg.top
                    dist := math.abs(close - edge)
                if na(nearestADist) or dist < nearestADist
                    nearestADist  := dist
                    nearestAAbove := isAbove

    // Update dynamic cells
    table.cell(dash, 1, 2, str.tostring(aActive), text_color         = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 2, 2, str.tostring(aTotal), text_color          = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 3, 2, avgBars(aBarsSum, aBarsCount), text_color = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)

    table.cell(dash, 1, 3, str.tostring(bActive), text_color         = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 2, 3, str.tostring(bTotal), text_color          = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 3, 3, avgBars(bBarsSum, bBarsCount), text_color = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)

    table.cell(dash, 1, 4, str.tostring(cActive), text_color         = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 2, 4, str.tostring(cTotal), text_color          = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 3, 4, avgBars(cBarsSum, cBarsCount), text_color = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)

    table.cell(dash, 1, 5, str.tostring(dActive), text_color         = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 2, 5, str.tostring(dTotal), text_color          = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)
    table.cell(dash, 3, 5, avgBars(dBarsSum, dBarsCount), text_color = color.white, text_size = txtSize, bgcolor = rowBg, text_halign = text.align_center)

    // Nearest A row
    nearestTxt = "Nearest A: "
    if not na(nearestADist)
        if nearestADist == 0.0
            nearestTxt += "Inside zone"
        else
            arrow = nearestAAbove ? "↑" : "↓"
            nearestTxt += arrow + " " + str.tostring(nearestADist, format.mintick) + " away"
    else
        nearestTxt += "None active"

    table.cell(dash, 0, 6, nearestTxt, text_color = colA, text_size = txtSize, bgcolor = color.new(DASH_DARK, 0), text_halign = text.align_center)
    table.merge_cells(dash, 0, 6, 3, 6)

//#endregion DASHBOARD

//#endregion VISUALS

//#region ALERTS

newAGrade = false
newBGrade = false

if bullFVG or bearFVG
    if fvgArr.size() > 0
        latest = fvgArr.last()
        if latest.formedAt == bar_index
            newAGrade := latest.grade == "A"
            newBGrade := latest.grade == "B"

alertcondition(newAGrade, "New A-Grade FVG", "New A-Grade FVG detected on {{ticker}} {{interval}}")
alertcondition(newBGrade, "New B-Grade FVG", "New B-Grade FVG detected on {{ticker}} {{interval}}")

//#endregion ALERTS
````
