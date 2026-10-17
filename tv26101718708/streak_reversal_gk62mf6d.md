# Streak Reversal

- url: https://www.tradingview.com/script/Gk62mf6d/
- type: indicator
- pine_id: PUB;27d6555b6e974ed0a42bf5a5fc94751a
- version: 1.0

## Description

█ OVERVIEW
Streak Reversal detects potential reversals after a directional streak of same-color candles. A Long setup begins with a bearish streak followed by two consecutive bullish candles, while a Short setup begins with a bullish streak followed by two consecutive bearish candles.

The signal is generated only when the streak has reached the required length and move, the second opposite candle breaks the selected confirmation level of the first opposite candle, and all enabled candle, EMA, category, and distance filters are satisfied.

The indicator separates signals into two categories: Trend and Counter-trend. The category is determined by the position of price relative to the EMA. A Long signal above the EMA and a Short signal below the EMA are classified as Trend signals. The opposite cases are classified as Counter-trend signals.

An optional EMA movement filter can reject signals when the EMA is too flat. Additional distance filters can require Trend signals to remain sufficiently close to the EMA or Counter-trend signals to occur sufficiently far from it.

A diagnostic table continuously evaluates the current Long and Short setup separately. It shows the state of every major condition, identifies blocking conditions, displays trend strength, and reports the last signal that passed all filters.

An optional TP/SL module can plot Entry, Stop Loss, and up to three Take Profit levels. SL can be based on ATR or a fixed percentage, while TP levels are calculated from the selected Risk:Reward ratios.

█ CONCEPTS
The indicator combines candle streaks, reversal confirmation, candle structure, EMA position and movement, distance from the EMA, and optional TP/SL planning. A streak alone does not create a signal — the reversal must develop through the required sequence of candles and pass all enabled filters.

Streak Structure
A Long setup starts with a sequence of bearish candles followed by two bullish candles.
A Short setup starts with a sequence of bullish candles followed by two bearish candles.
The minimum number of same-color candles is controlled by Min. same-color candles. A doji, where close equals open, breaks the streak.
The two opposite candles are not counted as part of the original streak. They form the reversal sequence that follows it.
The signal appears on the close of the second opposite candle, provided that all other conditions are satisfied.

Streak Move
The optional Streak move filter measures whether the preceding streak covered a sufficiently large price distance relative to ATR.
For a bearish streak:
High of the first bearish candle − Low of the last bearish candle
For a bullish streak:
High of the last bullish candle − Low of the first bullish candle
The result is divided by the ATR measured at the last candle of the streak.
The minimum required value is defined by Min. streak move (ATR).
This filter is intended to distinguish a meaningful directional move from a short sequence of candles that produced only a small price displacement.

Reversal Confirmation
The second opposite candle must close beyond a level defined by the first opposite candle.
For a Long setup:
• Body — the close must break above the top edge of the first green candle's body.
• High/Low — the close must break above the first green candle's high.
For a Short setup:
• Body — the close must break below the bottom edge of the first red candle's body.
• High/Low — the close must break below the first red candle's low.
The signal therefore requires more than simply seeing two candles of the opposite color. The second candle must also confirm the reversal by breaking the selected level of the first opposite candle.

Signal Candle Filters
The signal candle can be filtered using its wick and size.

Opposite Wick Filter
For a Long signal, the indicator evaluates the upper wick of the signal candle.
For a Short signal, it evaluates the lower wick.
The wick is measured as a percentage of the candle's complete high-low range:
Wick % = Opposite wick ÷ Candle range × 100
A signal is rejected when this percentage exceeds Max. opposite wick.
The filter is designed to reject reversal candles whose structure contains an excessively large wick against the intended direction.

Candle Size Filter
The optional Candle size filter rejects confirmation candles that are too small relative to ATR.
The size can be measured as:
• Body — |Close − Open|
• Range — High − Low
The result is divided by the selected ATR and compared with Min. size (ATR).
The filter is disabled by default and can be used when very small confirmation candles are considered insufficient.

EMA Structure
The EMA determines the signal category and provides additional information about the current trend environment.
EMA length defines the moving average used by the indicator.
For Long signals:
• price ABOVE the EMA → Trend category,
• price BELOW the EMA → Counter-trend category.
For Short signals:
• price BELOW the EMA → Trend category,
• price ABOVE the EMA → Counter-trend category.
If the close is exactly equal to the EMA, both Long and Short setups are classified as Counter-trend.

Trend and Counter-trend categories can be enabled or disabled independently.
Trend signals therefore represent reversals that occur in the same directional context as the EMA position, while Counter-trend signals occur against that context.

Flat EMA Filter
The optional Flat EMA filter measures how much the EMA moved during the selected window.
EMA Move = Highest EMA − Lowest EMA
This value is divided by ATR to express the EMA movement in ATR units.
If the resulting value is below Min. EMA move (ATR), the signal is rejected.
This filter is shared by Long and Short signals.

Trend Strength
The table also evaluates the EMA movement as an informational trend-strength reading.
The EMA movement is classified using the selected thresholds:
• below Strong trend threshold → weak,
• at or above Strong trend threshold → strong,
• at or above Very strong trend threshold → very strong.
The EMA direction (↑ or ↓) is determined separately, by comparing the current EMA value with its value at the start of the EMA move window.
The table also indicates whether the EMA direction is aligned with the signal side (Long or Short).
For example:
• Long + rising EMA → aligned,
• Long + falling EMA → opposed,
• Short + falling EMA → aligned,
• Short + rising EMA → opposed.
When the trend is weak, the table shows "(flat)" instead of the aligned/opposed status.
This rating is informational only. It does not block a signal.

Distance from EMA
The distance between the current close and the EMA is measured in ATR:
Distance = |Close − EMA| ÷ ATR
Two independent filters can use this value.
Trend signals can use a maximum distance filter. A Trend signal is rejected when price is too far from the EMA.
Counter-trend signals can use a minimum distance filter. A Counter-trend signal is rejected when price is too close to the EMA.
This creates two different interpretations of EMA distance:
• Trend — preferably not excessively extended from the EMA.
• Counter-trend — preferably sufficiently extended from the EMA.
The distance value is also displayed in the signal label.

Signal Types
Every valid signal belongs to one of four types:
• Long Trend — bearish streak → bullish reversal above EMA.
• Long Counter — bearish streak → bullish reversal below EMA.
• Short Trend — bullish streak → bearish reversal below EMA.
• Short Counter — bullish streak → bearish reversal above EMA.
Triangles represent Trend signals.
Diamonds represent Counter-trend signals.
The optional signal labels show the category and the current distance from the EMA in ATR.

Signal Table
The table is a real-time diagnostic checklist for the current bar. It evaluates Long and Short independently and shows how close each direction is to producing a valid signal.
The table contains:
• Condition — the condition being evaluated,
• LONG — status and value for a Long setup,
• SHORT — status and value for a Short setup.
The status symbols mean:
✓ — condition is satisfied.
✗ — condition currently blocks the signal.
… — the condition cannot yet be finalized because more candles are required.
○ — the corresponding filter is disabled and therefore does not block the signal.
The table does not simply show whether a signal exists. It shows the individual components that lead to that result.

Streak length
Shows the length of the streak preceding the reversal.
For Long, this is the preceding bearish/red streak.
For Short, this is the preceding bullish/green streak.
The value is compared with Min. same-color candles.
When the streak is still running, the table can display … because its final length may still increase.

Streak move
Shows the price distance covered by the same streak, expressed in ATR.
It is compared with Min. streak move (ATR).
When the streak is still developing, a value below the minimum is shown as waiting rather than immediately treated as a final failure, because the move can still increase.

Opposite candles
Shows how many opposite-color candles have appeared after the streak.
The required sequence is 2/2.
For Long:
bearish streak → green candle → green candle.
For Short:
bullish streak → red candle → red candle.
The signal can only form on the close of the second opposite candle.

Level break
Shows whether the close of the second opposite candle has broken the confirmation level of the first opposite candle.
The exact level depends on Confirmation level:
• Body — body edge,
• High/Low — high for Long or low for Short.
Before the second opposite candle exists, the table shows that it is still awaiting confirmation.

Current candle wick
Shows the relevant wick of the current candle as a percentage of its complete range.
For Long, the relevant wick is the upper wick.
For Short, the relevant wick is the lower wick.
When the current candle is not the required opposite color, the condition is not yet applicable.
When the second opposite candle is present, this becomes the decisive wick value for the signal.

Current candle size
Shows the size of the current candle in ATR.
Depending on Measure size as, this is either:
• the candle body, or
• the complete high-low range.
The table compares the value with Min. size (ATR) when the Candle size filter is enabled.

Flat EMA
Shows the EMA movement over EMA move window, expressed in ATR.
The value is compared with Min. EMA move (ATR) when the Flat EMA filter is enabled.
Because this condition is shared, the same EMA movement is evaluated for both Long and Short.

Trend strength
Shows the EMA direction and its current strength.
The table displays:
• ↑ or ↓ — EMA direction,
• weak / strong / very strong — EMA movement strength,
• aligned / opposed — whether that EMA direction agrees with the current signal side; for a weak trend, "(flat)" is shown instead.
This row is informational only and never blocks a signal.

Category
Shows whether the current Long or Short setup belongs to the Trend or Counter category and whether that category is enabled.
The classification is based on the current close relative to the EMA.
If the relevant category is disabled in the Signals settings, the table marks it as blocking.

Distance from EMA
Shows the current close's distance from the EMA in ATR.
The applicable filter depends on the signal category:
• Trend → maximum allowed distance,
• Counter → minimum required distance.
If the corresponding filter is disabled, the cell shows ○.

Signal
The SIGNAL row summarizes the current state after evaluating the blocking conditions.
Possible states include:
YES · Trend
YES · Counter
NO · followed by the blocking conditions.
waiting
off — the direction is disabled in the Signals settings.
When a signal is blocked, the table lists the blocking conditions. Up to two are displayed directly in the cell, while additional conditions are represented as +N. Hovering over the cell shows the complete list.
When no condition is currently blocking the setup but additional candles are still required, the result is shown as waiting.
The Long and Short columns are evaluated independently, so it is possible for one side to be blocked while the other is still waiting or already confirmed.

Last signal
Shows the most recent Long or Short signal that passed all filters and was generated by the indicator, regardless of whether shapes or labels are displayed.
Blocked setups are not counted as signals.
The table also identifies whether that last signal was Trend or Counter.

Signal Labels and Shapes
The optional signal shapes use different symbols for the two categories:
• ▲ / ▼ triangle — Trend signal.
• ◆ diamond — Counter-trend signal.
An optional circle marks the first opposite candle — the candle whose confirmation level was broken by the second opposite candle. The circle is plotted retroactively on that candle once a valid signal is confirmed.
The signal label contains:
• Trend or Counter,
• distance from the EMA in ATR.
The label's vertical offset is independently adjustable using ATR.

EMA and Glow
The EMA changes color according to the current price position.
When price is above the EMA, the bullish color is used.
When price is below the EMA, the bearish color is used.
The optional glow creates a gradient around the EMA. Its width is based on ATR and its transparency can be adjusted independently.

TP/SL
After a signal, the TP/SL module plots Entry, Stop Loss, and up to three Take Profit levels.
Entry is the close of the signal candle.
Stop Loss can be calculated in two ways:
- ATR-based: SL distance = ATR × SL ATR multiplier
- Percentage-based: SL distance = Entry × SL % ÷ 100
The Take Profit levels are calculated from the Entry-to-SL distance:
TP1 = Entry ± Risk × TP1 Risk:Reward
TP2 = Entry ± Risk × TP2 Risk:Reward
TP3 = Entry ± Risk × TP3 Risk:Reward
The direction depends on whether the signal is Long or Short.
A new signal removes the previous TP/SL set and creates a new one.
The levels extend with price until either the Stop Loss or the farthest visible Take Profit is reached. At that point, the active TP/SL set stops extending.

█ FEATURES
• Reversal detection after a configurable streak of same-color candles.
• Separate Long and Short reversal conditions.
• Minimum streak length filter with doji-based streak termination.
• Optional minimum streak movement measured in ATR.
• Two-candle reversal confirmation.
• Confirmation based on either the first opposite candle's body or High/Low.
• Optional opposite-wick filter.
• Optional signal-candle size filter based on Body or Range.
• EMA-based Trend and Counter-trend signal classification.
• Independent enabling/disabling of Trend and Counter-trend signals.
• Optional Flat EMA filter.
• Informational EMA trend-strength rating: weak, strong, very strong.
• Trend-alignment information in the diagnostic table.
• Optional maximum EMA distance for Trend signals.
• Optional minimum EMA distance for Counter-trend signals.
• Configurable bullish and bearish colors.
• Optional signal triangles and diamonds.
• Optional marker for the first opposite candle.
• Signal labels showing category and EMA distance in ATR.
• Configurable EMA line and ATR-based glow.
• Diagnostic Long/Short table with condition-by-condition status.
• Table result showing blocking conditions and waiting state.
• Last valid Long/Short signal tracking.
• Optional Entry, SL, TP1, TP2 and TP3 levels.
• ATR-based or percentage-based Stop Loss.
• Independent Risk:Reward settings for TP1-TP3.
• Optional display of individual SL and TP levels.
• Risk and reward zone visualization.
• Four hidden outputs for external backtesting.
• Alerts for all signals, Long/Short signals, and Trend/Counter variants.

█ APPLICATIONS
Reversal Analysis
The indicator can be used to study reversals that develop after an identifiable directional candle streak rather than treating every opposite-colored candle as a reversal.
The combination of streak length, streak movement, and the two-candle confirmation creates a structured sequence:
Directional streak → first opposite candle → second opposite candle → confirmation.

EMA Extension Analysis
The distance from EMA can be used to distinguish between two different situations.
A Trend signal can be filtered when price has moved too far away from the EMA.
A Counter-trend signal can instead require price to be sufficiently far from the EMA.
The EMA distance displayed on each signal label also provides a direct reference for comparing how extended different signals were.

Signal Quality Filtering
The candle filters allow the reversal definition to be made stricter.
For example, the streak-move filter can require a sufficiently large preceding move, while the wick filter can reject confirmation candles with an excessive opposite wick.
The candle-size filter can additionally exclude very small confirmation candles.
These filters can be combined or disabled independently depending on how selective the strategy should be.

Example of Use
A Streak Reversal signal is better treated as a structured event rather than an automatic trade instruction.
Before acting on a signal, it can be useful to consider:
• the length and size of the preceding streak,
• the strength and direction of the EMA,
• whether the signal is Trend or Counter,
• the distance from the EMA,
• the structure of the confirmation candle,
• the market's broader price structure,
• support and resistance,
• momentum and higher-timeframe context.

The table is particularly useful for diagnosing why a setup is not producing a signal. Instead of waiting for a triangle or diamond, the user can see which individual condition is currently preventing the Long or Short setup.

The TP/SL module can then be used to visualize a predefined risk/reward structure and inspect how different SL and Risk:Reward settings would be positioned relative to the signal.

█ NOTES
• Signals are calculated on the close of the second opposite candle. On the realtime bar, the signal, its label, TP/SL levels and alerts may appear and disappear until the bar closes. On historical bars, signals reflect closed candles only. 
• Trend strength in the table is informational only and does not block signals.
• TP/SL is a visual level-planning tool and does not assess the quality of a signal.
• This indicator does not replace independent market analysis or risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Streak Reversal", overlay = true, max_labels_count = 500)

// INPUTS
string SIZE_OPTS_TINY   = "Tiny"
string SIZE_OPTS_SMALL  = "Small"
string SIZE_OPTS_NORMAL = "Normal"
string SIZE_OPTS_LARGE  = "Large"

// 1. Signals 
string GRP_SIG = "1. Signals"
bool showLong           = input.bool(true, "Long (after bearish streak)",  group = GRP_SIG, tooltip = "Looks for an upside reversal: a streak of red candles followed by 2 green candles.\nThe signal appears on the close of the second green candle.")
bool showShort          = input.bool(true, "Short (after bullish streak)", group = GRP_SIG, tooltip = "Looks for a downside reversal: a streak of green candles followed by 2 red candles.\nThe signal appears on the close of the second red candle.")
bool showTrendSignals   = input.bool(true, "Trend (end of pullback)",      group = GRP_SIG, tooltip = "Long when price is ABOVE the EMA / Short when price is BELOW the EMA.\nQuality improves the CLOSER the signal candle is to the EMA.\nDistance limit: section 5.")
bool showCounterSignals = input.bool(true, "Counter-trend",                group = GRP_SIG, tooltip = "Long when price is BELOW the EMA / Short when price is ABOVE the EMA.\nQuality improves the FARTHER the signal candle is from the EMA (move exhaustion).\nDistance limit: section 5.")

// 2. Streak 
string GRP_STREAK = "2. Streak"
int   minStreak      = input.int(2, "Min. same-color candles", minval = 1, maxval = 50, group = GRP_STREAK, tooltip = "How many consecutive candles of one color must precede the reversal.\nA doji candle (close = open) breaks the streak.")
bool  useAtrFilter   = input.bool(true, "Streak move filter", group = GRP_STREAK, tooltip = "The streak must cover a minimum distance measured in ATR.")
float minAtrMove     = input.float(1.5, "Min. streak move (ATR)", minval = 0.1, step = 0.1, group = GRP_STREAK, tooltip = "Bearish streak: high of the first candle − low of the last candle.\nBullish streak: high of the last candle − low of the first candle.\nThe result is divided by the ATR at the last candle of the streak.")
int   atrLenStreak   = input.int(100, "ATR length (streak move)", minval = 1, maxval = 500, group = GRP_STREAK, tooltip = "ATR period used to measure the streak move.")

// 3. Signal candle 
string GRP_SIGCANDLE = "3. Signal candle"
string confirmLevel        = input.string("Body", "Confirmation level", options = ["Body", "High/Low"], group = GRP_SIGCANDLE, tooltip = "Level of the first opposite candle that the signal candle's close must break.\nBody: top (long) / bottom (short) edge of the body.\nHigh/Low: high (long) / low (short).")
bool   useOppWickFilter    = input.bool(true, "Opposite wick filter", group = GRP_SIGCANDLE, tooltip = "Long: rejects a signal candle with an upper wick that is too large.\nShort: rejects a signal candle with a lower wick that is too large.")
float  maxOppWickPct       = input.float(40.0, "Max. opposite wick (% of range)", minval = 5.0, maxval = 90.0, step = 1.0, group = GRP_SIGCANDLE, tooltip = "Maximum share of the opposite wick in the candle's full range (high−low).")
bool   useSignalSizeFilter = input.bool(false, "Candle size filter", group = GRP_SIGCANDLE, tooltip = "Filters out tiny confirmation candles.")
string signalSizeMode      = input.string("Body", "Measure size as", options = ["Body", "Range"], group = GRP_SIGCANDLE, tooltip = "Body = |close−open|.\nRange = high−low.")
float  minSignalSizeAtr    = input.float(0.30, "Min. size (ATR)", minval = 0.05, maxval = 5.0, step = 0.05, group = GRP_SIGCANDLE, tooltip = "Minimum size of the signal candle in ATR.")
int    atrLenSize          = input.int(100, "ATR length (candle size)", minval = 1, maxval = 500, group = GRP_SIGCANDLE, tooltip = "ATR period used to measure the signal candle size.")

// 4. EMA (trend)
string GRP_EMA = "4. EMA (trend)"
int    emaLen           = input.int(100, "EMA length", minval = 2, maxval = 400, group = GRP_EMA, tooltip = "Determines the signal category: trend / counter-trend.")
bool   useEmaMoveFilter = input.bool(false, "Flat EMA filter", group = GRP_EMA, tooltip = "EMA move = highest(EMA) − lowest(EMA) over the window, in ATR.\nIf it is below the minimum, the signal is rejected.")
int    emaMoveLen       = input.int(20, "EMA move window (bars)", minval = 2, maxval = 300, group = GRP_EMA, tooltip = "Shared by the flat EMA filter and the trend strength rating in the table.")
float  minEmaMoveAtr    = input.float(0.50, "Min. EMA move (ATR)", minval = 0.05, maxval = 10.0, step = 0.05, group = GRP_EMA, tooltip = "Flat EMA filter threshold.")
int    atrLenEmaMove    = input.int(100, "ATR length (EMA move)", minval = 1, maxval = 500, group = GRP_EMA, tooltip = "Shared by the flat EMA filter and the trend strength rating.")
float  strongTrendAtr   = input.float(1.0, "Strong trend threshold (ATR)", minval = 0.05, maxval = 20.0, step = 0.05, group = GRP_EMA, tooltip = "Trend strength rating in the table (EMA move over the window, in ATR):\n< strong threshold → weak (flat EMA)\n≥ strong threshold → strong\n≥ very strong threshold → very strong\nInformational only — does not block signals.")
float  vStrongTrendAtr  = input.float(2.5, "Very strong trend threshold (ATR)", minval = 0.05, maxval = 30.0, step = 0.05, group = GRP_EMA, tooltip = "Should be greater than the strong trend threshold.")

// 5. Distance from EMA
string GRP_DIST = "5. Distance from EMA"
bool  useTrendMaxDist   = input.bool(false, "Max. distance filter — trend", group = GRP_DIST, tooltip = "A trend signal is rejected when the signal candle's close is too FAR from the EMA.")
float maxTrendDistAtr   = input.float(2.0, "Max. distance from EMA (ATR)", minval = 0.0, maxval = 20.0, step = 0.1, group = GRP_DIST, tooltip = "Applies to trend signals only.")
bool  useCounterMinDist = input.bool(false, "Min. distance filter — counter-trend", group = GRP_DIST, tooltip = "A counter-trend signal is rejected when the signal candle's close is too CLOSE to the EMA.")
float minCounterDistAtr = input.float(3.0, "Min. distance from EMA (ATR)", minval = 0.0, maxval = 20.0, step = 0.1, group = GRP_DIST, tooltip = "Applies to counter-trend signals only.")
int   atrLenDist        = input.int(100, "ATR length (EMA distance)", minval = 1, maxval = 500, group = GRP_DIST, tooltip = "Shared by both distance filters; also used for label values and label offset (section 8).")

// 6. Colors
string GRP_COL = "6. Colors"
color  bullCol         = input.color(#26a69a, "Bullish (long / above EMA)", group = GRP_COL, tooltip = "Main long-side color, used throughout the indicator:\n• long signals — triangle, diamond, opposite-candle circle, label background\n• EMA line and glow when price is ABOVE the EMA\n• TP/SL: long entry, TP and reward zone; short SL and risk zone\n• table: LONG header, ✓ statuses, aligned trend, last long signal")
color  bearCol         = input.color(#ef5350, "Bearish (short / below EMA)", group = GRP_COL, tooltip = "Main short-side color, used throughout the indicator:\n• short signals — triangle, diamond, opposite-candle circle, label background\n• EMA line and glow when price is BELOW the EMA\n• TP/SL: short entry, TP and reward zone; long SL and risk zone\n• table: SHORT header, ✗ statuses, last short signal")
color  trendLabelCol   = input.color(color.white, "Label text — trend",         group = GRP_COL, tooltip = "Text color of trend signal labels.")
color  counterLabelCol = input.color(color.white, "Label text — counter-trend", group = GRP_COL, tooltip = "Text color of counter-trend signal labels.")
color  tblBgCol        = input.color(color.new(#131722, 0), "Table — background",        group = GRP_COL, tooltip = "Table background color and transparency.")
color  tblTxtCol       = input.color(color.new(#d1d4dc, 0), "Table — text",              group = GRP_COL, tooltip = "Color of the condition names (first table column).")
color  tblHdrCol       = input.color(color.new(#2a2e39, 0), "Table — header background", group = GRP_COL, tooltip = "Background of the header row and the result row.")

// 7. Display — shapes
string GRP_VIS_SHAPE = "7. Display — shapes"
bool   showShapes   = input.bool(false, "Show signal shapes", group = GRP_VIS_SHAPE, tooltip = "Triangle = trend, diamond = counter-trend.")
string shapeSizeStr = input.string(SIZE_OPTS_TINY, "Shape size", options = [SIZE_OPTS_TINY, SIZE_OPTS_SMALL, SIZE_OPTS_NORMAL], group = GRP_VIS_SHAPE, tooltip = "Size of the signal triangles and diamonds.")
bool   highlightOpp = input.bool(true, "Mark opposite candle", group = GRP_VIS_SHAPE, tooltip = "Circle below/above the first opposite candle (the one whose level was broken by the signal candle).")

// 8. Display — labels
string GRP_VIS_LAB = "8. Display — labels"
bool   showDistLabel   = input.bool(true, "Show labels", group = GRP_VIS_LAB, tooltip = "Signal category + distance from the EMA in ATR (ATR from section 5).")
string labelSizeStr    = input.string(SIZE_OPTS_SMALL, "Label size", options = [SIZE_OPTS_TINY, SIZE_OPTS_SMALL, SIZE_OPTS_NORMAL], group = GRP_VIS_LAB, tooltip = "Text size of the signal labels.")
float  labelOffsetAtr  = input.float(0.6, "Offset from candle (x ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = GRP_VIS_LAB, tooltip = "Vertical distance of the label from the low (long) / high (short), in ATR from section 5.\n0 = the label touches the candle. Consider a smaller value when shapes are hidden.")

// 9. Display — EMA
string GRP_VIS_EMA = "9. Display — EMA"
bool  showEma        = input.bool(true, "Show EMA", group = GRP_VIS_EMA, tooltip = "The EMA line changes color: bullish when price is above it, bearish when below.")
int   emaWidth       = input.int(3, "Line width", minval = 1, maxval = 8, group = GRP_VIS_EMA, tooltip = "EMA line width.")
bool  showEmaGlow    = input.bool(true, "Show glow", group = GRP_VIS_EMA, tooltip = "Gradient in a channel around the EMA — strongest at the EMA, fading toward the edges.")
float glowOffsetMult = input.float(4, "Glow width (x ATR)", minval = 0.1, maxval = 5.0, step = 0.01, group = GRP_VIS_EMA, tooltip = "Distance of the glow edge from the EMA, in ATR.")
int   glowNearTransp = input.int(80, "Glow transparency", minval = 0, maxval = 99, group = GRP_VIS_EMA, tooltip = "0 = solid color, 99 = nearly invisible.")
int   atrLenGlow     = input.int(100, "ATR length (glow width)", minval = 1, maxval = 500, group = GRP_VIS_EMA, tooltip = "ATR period used for the glow width.")

// 10. Table 
string GRP_TBL = "10. Table"
bool   showTable  = input.bool(true, "Show table", group = GRP_TBL, tooltip = "Checklist of signal conditions for the current bar, shown separately for long and short.\n✓ met · ✗ blocking · … waiting for more bars · ○ filter off.\nHover over a table cell to see details.")
string tblPosStr  = input.string("Top right", "Position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = GRP_TBL, tooltip = "Table position on the chart.")
string tblSizeStr = input.string(SIZE_OPTS_SMALL, "Text size", options = [SIZE_OPTS_TINY, SIZE_OPTS_SMALL, SIZE_OPTS_NORMAL, SIZE_OPTS_LARGE], group = GRP_TBL, tooltip = "Table text size.")

// 11. TP/SL 
string GRP_TPSL = "11. TP/SL"
bool  showTargets = input.bool(true, "Show TP/SL levels", group = GRP_TPSL, tooltip = "Draws the entry, Stop Loss and Take Profit 1–3 for each new signal.\nEntry = signal candle close.\nA new signal replaces the previous levels. Levels stop extending once SL or the farthest visible TP is hit.")
bool  useAtrSL    = input.bool(true, "ATR-based SL", group = GRP_TPSL, tooltip = "On: SL distance from entry = ATR × multiplier.\nOff: fixed percentage of the entry price (SL % from entry).")
int   tpAtrPeriod = input.int(14, "ATR length (TP/SL)", minval = 1, maxval = 500, group = GRP_TPSL, tooltip = "ATR period used to calculate the SL distance. Independent of the other ATR settings.")
float slAtrMult   = input.float(1.5, "SL ATR multiplier", minval = 0.1, step = 0.1, group = GRP_TPSL, tooltip = "SL distance from entry as a multiple of ATR. Applies when “ATR-based SL” is enabled.")
float slPercent   = input.float(1.0, "SL % from entry", minval = 0.01, step = 0.1, group = GRP_TPSL, tooltip = "SL distance from the entry price as a percentage. Applies when “ATR-based SL” is disabled.")
float rrTP1       = input.float(1.0, "TP1 risk:reward", minval = 0.1, step = 0.1, group = GRP_TPSL, tooltip = "Reward-to-risk ratio for TP1.\n1.0 = TP1 at the same distance from entry as the SL.")
float rrTP2       = input.float(2.0, "TP2 risk:reward", minval = 0.1, step = 0.1, group = GRP_TPSL, tooltip = "Reward-to-risk ratio for TP2.")
float rrTP3       = input.float(3.0, "TP3 risk:reward", minval = 0.1, step = 0.1, group = GRP_TPSL, tooltip = "Reward-to-risk ratio for TP3.")

// 12. TP/SL — display 
string GRP_TPSL_DISP = "12. TP/SL — display"
bool showSlLevel  = input.bool(true, "Show SL",  group = GRP_TPSL_DISP, tooltip = "Stop Loss line and label, plus the risk zone fill.")
bool showTp1Level = input.bool(true, "Show TP1", group = GRP_TPSL_DISP, tooltip = "Take Profit 1 line and label.")
bool showTp2Level = input.bool(true, "Show TP2", group = GRP_TPSL_DISP, tooltip = "Take Profit 2 line and label.")
bool showTp3Level = input.bool(true, "Show TP3", group = GRP_TPSL_DISP, tooltip = "Take Profit 3 line and label.\nWhen the farthest visible TP is hit, the levels stop extending.")

// CALCULATIONS

bool isBull = close > open
bool isBear = close < open

int bullStreak = 0
int bearStreak = 0
bullStreak := isBull ? nz(bullStreak[1]) + 1 : 0
bearStreak := isBear ? nz(bearStreak[1]) + 1 : 0

float bearFirstHigh = na
float bullFirstLow  = na
bearFirstHigh := isBear ? (bearStreak == 1 ? high : nz(bearFirstHigh[1])) : na
bullFirstLow  := isBull ? (bullStreak == 1 ? low  : nz(bullFirstLow[1]))  : na

float oppBodyHigh = math.max(open[1], close[1])
float oppBodyLow  = math.min(open[1], close[1])
float longLevel   = confirmLevel == "Body" ? oppBodyHigh : high[1]
float shortLevel  = confirmLevel == "Body" ? oppBodyLow  : low[1]

// ATR — a separate one for each measurement
float atrStreak  = ta.atr(atrLenStreak)
float atrSize    = ta.atr(atrLenSize)
float atrEmaMove = ta.atr(atrLenEmaMove)
float atrDist    = ta.atr(atrLenDist)
float atrGlow    = ta.atr(atrLenGlow)

float emaVal = ta.ema(close, emaLen)
bool aboveEma = close > emaVal
bool belowEma = close < emaVal

// EMA move (range over the window) — flat EMA filter + trend strength
float emaRange   = ta.highest(emaVal, emaMoveLen) - ta.lowest(emaVal, emaMoveLen)
float emaMoveAtr = nz(atrEmaMove) > 0 ? emaRange / atrEmaMove : na
bool  emaMoveOk  = not useEmaMoveFilter or (not na(emaMoveAtr) and emaMoveAtr >= minEmaMoveAtr)
bool  emaRising  = emaVal >= nz(emaVal[emaMoveLen], emaVal)

// Streak move filter
float bearDrop = nz(bearFirstHigh[2]) - low[2]
float bullRise = high[2] - nz(bullFirstLow[2])
bool longMoveOk  = not useAtrFilter or (nz(atrStreak[2]) > 0 and bearDrop / atrStreak[2] >= minAtrMove)
bool shortMoveOk = not useAtrFilter or (nz(atrStreak[2]) > 0 and bullRise / atrStreak[2] >= minAtrMove)

// Signal candle filters
float candleRange = high - low
float upperWick   = high - math.max(open, close)
float lowerWick   = math.min(open, close) - low
float bodySize    = math.abs(close - open)
float oppWickPct  = candleRange > 0 ? (upperWick / candleRange) * 100.0 : 0.0
float lowWickPct  = candleRange > 0 ? (lowerWick / candleRange) * 100.0 : 0.0
bool longWickOk   = not useOppWickFilter or (candleRange > 0 and oppWickPct <= maxOppWickPct)
bool shortWickOk  = not useOppWickFilter or (candleRange > 0 and lowWickPct <= maxOppWickPct)
float signalSize  = signalSizeMode == "Body" ? bodySize : candleRange
float signalSizeAtr = nz(atrSize) > 0 ? signalSize / atrSize : na
bool signalSizeOk = not useSignalSizeFilter or (not na(signalSizeAtr) and signalSizeAtr >= minSignalSizeAtr)

// Category: trend (continuation after a pullback) vs counter-trend
bool longIsTrend     = aboveEma
bool shortIsTrend    = belowEma
bool categoryOkLong  = (longIsTrend  and showTrendSignals) or (not longIsTrend  and showCounterSignals)
bool categoryOkShort = (shortIsTrend and showTrendSignals) or (not shortIsTrend and showCounterSignals)

// EMA distance filters (measured at the signal candle's close)
float emaDistAtr    = nz(atrDist) > 0 ? math.abs(close - emaVal) / atrDist : na
bool  trendDistOk   = not useTrendMaxDist   or (not na(emaDistAtr) and emaDistAtr <= maxTrendDistAtr)
bool  counterDistOk = not useCounterMinDist or (not na(emaDistAtr) and emaDistAtr >= minCounterDistAtr)
bool  longDistOk    = longIsTrend  ? trendDistOk : counterDistOk
bool  shortDistOk   = shortIsTrend ? trendDistOk : counterDistOk

// SIGNALS

bool longSignal =
     showLong
     and bearStreak[2] >= minStreak
     and isBull[1]
     and isBull
     and longMoveOk
     and longWickOk
     and signalSizeOk
     and emaMoveOk
     and categoryOkLong
     and longDistOk
     and close > longLevel

bool shortSignal =
     showShort
     and bullStreak[2] >= minStreak
     and isBear[1]
     and isBear
     and shortMoveOk
     and shortWickOk
     and signalSizeOk
     and emaMoveOk
     and categoryOkShort
     and shortDistOk
     and close < shortLevel

bool longTrendSig    = longSignal  and longIsTrend
bool longCounterSig  = longSignal  and not longIsTrend
bool shortTrendSig   = shortSignal and shortIsTrend
bool shortCounterSig = shortSignal and not shortIsTrend
bool sigIsTrend      = longTrendSig or shortTrendSig

// SETUP STATE FOR THE TABLE (current bar)
// Streak = the streak PRECEDING a potential reversal:
//   0 opposite candles → the streak is still running (current bar is part of it)
//   1 opposite candle  → the streak ended on the previous bar
//   2 opposite candles → the streak ended 2 bars ago (signal moment)

float bearMoveNow = isBear and nz(atrStreak) > 0 ? (bearFirstHigh - low) / atrStreak : na
float bullMoveNow = isBull and nz(atrStreak) > 0 ? (high - bullFirstLow) / atrStreak : na
float bearMove1 = bearMoveNow[1]
float bearMove2 = bearMoveNow[2]
float bullMove1 = bullMoveNow[1]
float bullMove2 = bullMoveNow[2]
int   bearLen1  = nz(bearStreak[1])
int   bearLen2  = nz(bearStreak[2])
int   bullLen1  = nz(bullStreak[1])
int   bullLen2  = nz(bullStreak[2])

// Long: red streak + green opposite candles
int   lOpp  = isBull and isBull[1] ? 2 : isBull and isBear[1] ? 1 : 0
int   lLen  = lOpp == 2 ? bearLen2  : lOpp == 1 ? bearLen1  : bearStreak
float lMove = lOpp == 2 ? bearMove2 : lOpp == 1 ? bearMove1 : bearMoveNow

// Short: green streak + red opposite candles
int   sOpp  = isBear and isBear[1] ? 2 : isBear and isBull[1] ? 1 : 0
int   sLen  = sOpp == 2 ? bullLen2  : sOpp == 1 ? bullLen1  : bullStreak
float sMove = sOpp == 2 ? bullMove2 : sOpp == 1 ? bullMove1 : bullMoveNow

// Last signals
var int  lastLongBar    = na
var bool lastLongTrend  = false
var int  lastShortBar   = na
var bool lastShortTrend = false
if longSignal
    lastLongBar   := bar_index
    lastLongTrend := longIsTrend
if shortSignal
    lastShortBar   := bar_index
    lastShortTrend := shortIsTrend

// DRAWING


// EMA + glow 
color emaCol        = close >= emaVal ? bullCol : bearCol
float glowOffset    = atrGlow * glowOffsetMult
float emaUpperBound = emaVal + glowOffset
float emaLowerBound = emaVal - glowOffset

pCore   = plot(showEma ? emaVal : na, "EMA", emaCol, emaWidth)
pGlowUp = plot(showEma and showEmaGlow ? emaUpperBound : na, "EMA Glow Upper", color.new(emaCol, 100), 1, display = display.none)
pGlowDn = plot(showEma and showEmaGlow ? emaLowerBound : na, "EMA Glow Lower", color.new(emaCol, 100), 1, display = display.none)

fill(pCore,   pGlowUp, emaUpperBound, emaVal,        showEmaGlow ? color.new(emaCol, 100) : na, showEmaGlow ? color.new(emaCol, glowNearTransp) : na)
fill(pGlowDn, pCore,   emaVal,        emaLowerBound, showEmaGlow ? color.new(emaCol, glowNearTransp) : na, showEmaGlow ? color.new(emaCol, 100) : na)

// Signal shapes 
// plotshape accepts only a constant size, so each size has its own set;
// only the set selected in the settings is drawn.
bool szT = showShapes and shapeSizeStr == SIZE_OPTS_TINY
bool szS = showShapes and shapeSizeStr == SIZE_OPTS_SMALL
bool szN = showShapes and shapeSizeStr == SIZE_OPTS_NORMAL

plotshape(szT and longTrendSig,    "Long trend (tiny)",      shape.triangleup,   location.belowbar, bullCol, size = size.tiny)
plotshape(szT and longCounterSig,  "Long counter (tiny)",    shape.diamond,      location.belowbar, bullCol, size = size.tiny)
plotshape(szT and shortTrendSig,   "Short trend (tiny)",     shape.triangledown, location.abovebar, bearCol, size = size.tiny)
plotshape(szT and shortCounterSig, "Short counter (tiny)",   shape.diamond,      location.abovebar, bearCol, size = size.tiny)

plotshape(szS and longTrendSig,    "Long trend (small)",     shape.triangleup,   location.belowbar, bullCol, size = size.small)
plotshape(szS and longCounterSig,  "Long counter (small)",   shape.diamond,      location.belowbar, bullCol, size = size.small)
plotshape(szS and shortTrendSig,   "Short trend (small)",    shape.triangledown, location.abovebar, bearCol, size = size.small)
plotshape(szS and shortCounterSig, "Short counter (small)",  shape.diamond,      location.abovebar, bearCol, size = size.small)

plotshape(szN and longTrendSig,    "Long trend (normal)",    shape.triangleup,   location.belowbar, bullCol, size = size.normal)
plotshape(szN and longCounterSig,  "Long counter (normal)",  shape.diamond,      location.belowbar, bullCol, size = size.normal)
plotshape(szN and shortTrendSig,   "Short trend (normal)",   shape.triangledown, location.abovebar, bearCol, size = size.normal)
plotshape(szN and shortCounterSig, "Short counter (normal)", shape.diamond,      location.abovebar, bearCol, size = size.normal)

plotshape(highlightOpp and longSignal,  "Opposite candle (long)",  shape.circle, location.belowbar, color.new(bullCol, 30), offset = -1, size = size.tiny)
plotshape(highlightOpp and shortSignal, "Opposite candle (short)", shape.circle, location.abovebar, color.new(bearCol, 30), offset = -1, size = size.tiny)

// Labels 
string labelSizeSel = switch labelSizeStr
    SIZE_OPTS_TINY   => size.tiny
    SIZE_OPTS_SMALL  => size.small
    => size.normal

if showDistLabel and (longSignal or shortSignal) and not na(emaDistAtr)
    string distTxt = (sigIsTrend ? "Trend" : "Counter") + "\n" + str.tostring(emaDistAtr, "#.##") + " ATR"
    color  labCol  = sigIsTrend ? trendLabelCol : counterLabelCol
    if longSignal
        label.new(bar_index, low - atrDist * labelOffsetAtr, distTxt, style = label.style_label_up, color = color.new(bullCol, 20), textcolor = labCol, size = labelSizeSel)
    if shortSignal
        label.new(bar_index, high + atrDist * labelOffsetAtr, distTxt, style = label.style_label_down, color = color.new(bearCol, 20), textcolor = labCol, size = labelSizeSel)

// TABLE — signal condition checklist (columns: Long | Short)

string tblPos = switch tblPosStr
    "Top left"      => position.top_left
    "Top center"    => position.top_center
    "Top right"     => position.top_right
    "Middle left"   => position.middle_left
    "Middle center" => position.middle_center
    "Middle right"  => position.middle_right
    "Bottom left"   => position.bottom_left
    "Bottom center" => position.bottom_center
    => position.bottom_right

string tblSize = switch tblSizeStr
    SIZE_OPTS_TINY   => size.tiny
    SIZE_OPTS_SMALL  => size.small
    SIZE_OPTS_NORMAL => size.normal
    => size.large

// Cell statuses
int ST_OK   = 1   // ✓ condition met
int ST_FAIL = 2   // ✗ condition blocks the signal
int ST_WAIT = 3   // … cannot be evaluated yet — waiting for more bars
int ST_OFF  = 4   // ○ filter disabled (not blocking)
int ST_INFO = 5   // information only, no evaluation

color WAIT_COL = color.orange
color OFF_COL  = color.gray

f_num(float x) =>
    na(x) ? "—" : str.tostring(x, "0.00")

f_icon(int st) =>
    st == ST_OK ? "✓ " : st == ST_FAIL ? "✗ " : st == ST_WAIT ? "… " : st == ST_OFF ? "○ " : ""

f_stCol(int st) =>
    st == ST_OK ? bullCol : st == ST_FAIL ? bearCol : st == ST_WAIT ? WAIT_COL : OFF_COL

f_cell(table t, int c, int r, int st, string txt, string tip, color col) =>
    table.cell(t, c, r, f_icon(st) + txt, text_color = na(col) ? f_stCol(st) : col, text_size = tblSize, text_halign = text.align_left, tooltip = tip)

f_label(table t, int r, string txt, string tip) =>
    table.cell(t, 0, r, txt, text_color = tblTxtCol, text_size = tblSize, text_halign = text.align_left, tooltip = tip)

// Fills the column for one side (Long or Short)
f_fillSide(table t, int c, bool isL, bool enabled, int opp, int len, float mv, bool rightColor, float wPct, bool lvlOk, float lvlPrice, bool isTrendCat, bool catOn, bool distOk, bool sig, int lastBar, bool lastTrend) =>
    string serName = isL ? "bearish (red)" : "bullish (green)"
    string oppName = isL ? "green" : "red"
    int nFail = 0
    int nWait = 0
    bool noSeries = len == 0

    // 1. Streak length
    int stLen = noSeries ? ST_FAIL : len >= minStreak ? ST_OK : opp == 0 ? ST_WAIT : ST_FAIL
    string txtLen = noSeries ? "none" : str.tostring(len) + " bars (min " + str.tostring(minStreak) + ")"
    string tipLen = noSeries ? "There is no " + serName + " streak before the current bars." : opp == 0 ? "The " + serName + " streak is still running — the current bar is part of it, so the count may still grow." : "The " + serName + " streak ended " + str.tostring(opp) + " bar(s) ago — its length is final."
    f_cell(t, c, 1, stLen, txtLen, tipLen, na)
    nFail += stLen == ST_FAIL ? 1 : 0
    nWait += stLen == ST_WAIT ? 1 : 0

    // 2. Streak move
    int stMv = not useAtrFilter ? ST_OFF : noSeries or na(mv) ? ST_FAIL : mv >= minAtrMove ? ST_OK : opp == 0 ? ST_WAIT : ST_FAIL
    string txtMv = (na(mv) ? "—" : f_num(mv) + " ATR") + (useAtrFilter ? " (min " + f_num(minAtrMove) + ")" : " · off")
    string tipMv = "Move of the same streak as in the row above, in ATR(" + str.tostring(atrLenStreak) + ")." + (opp == 0 ? "\nThe streak is still running — the move may still grow, so a value below the minimum is shown as “waiting”, not as blocking." : "")
    f_cell(t, c, 2, stMv, txtMv, tipMv, na)
    nFail += stMv == ST_FAIL ? 1 : 0
    nWait += stMv == ST_WAIT ? 1 : 0

    // 3. Opposite candles
    int stOpp = noSeries ? ST_INFO : opp == 2 ? ST_OK : ST_WAIT
    string txtOpp = noSeries ? "—" : str.tostring(opp) + "/2"
    string tipOpp = "How many " + oppName + " candles have appeared after the streak.\nA signal can only form on the close of the second one."
    f_cell(t, c, 3, stOpp, txtOpp, tipOpp, noSeries ? OFF_COL : na)
    nWait += stOpp == ST_WAIT ? 1 : 0

    // 4. Confirmation level break
    int stLvl = opp == 2 ? (lvlOk ? ST_OK : ST_FAIL) : ST_WAIT
    string txtLvl = opp == 2 ? (isL ? "close > " : "close < ") + str.tostring(lvlPrice, format.mintick) : "awaiting 2nd candle"
    string tipLvl = "The close of the 2nd opposite candle must break the " + (confirmLevel == "Body" ? (isL ? "top edge of the body" : "bottom edge of the body") : (isL ? "high" : "low")) + " of the 1st opposite candle (section 3)."
    f_cell(t, c, 4, stLvl, txtLvl, tipLvl, na)
    nFail += stLvl == ST_FAIL ? 1 : 0
    nWait += stLvl == ST_WAIT ? 1 : 0

    // 5. Opposite wick — current bar
    string wickName = isL ? "upper" : "lower"
    int stWick = not rightColor ? ST_WAIT : not useOppWickFilter ? ST_OFF : candleRange > 0 and wPct <= maxOppWickPct ? ST_OK : ST_FAIL
    string txtWick = (rightColor ? str.tostring(wPct, "0") + "%" : "—") + (useOppWickFilter ? " (max " + str.tostring(maxOppWickPct, "0") + "%)" : " · off")
    string tipWick = "The " + wickName + " wick of the CURRENT candle as % of its range.\n" + (not rightColor ? "The current candle is not " + (isL ? "green" : "red") + " — not applicable." : opp == 2 ? "This is the signal candle (2nd opposite) — this value is decisive." : "Preview: this is not the signal candle yet — the wick of the 2nd opposite candle is decisive.")
    f_cell(t, c, 5, stWick, txtWick, tipWick, na)
    nFail += stWick == ST_FAIL ? 1 : 0
    nWait += stWick == ST_WAIT ? 1 : 0

    // 6. Candle size — current bar
    int stSize = not rightColor ? ST_WAIT : not useSignalSizeFilter ? ST_OFF : signalSizeOk ? ST_OK : ST_FAIL
    string txtSize = (rightColor ? f_num(signalSizeAtr) + " ATR" : "—") + (useSignalSizeFilter ? " (min " + f_num(minSignalSizeAtr) + ")" : " · off")
    string tipSize = "Size of the CURRENT candle (" + (signalSizeMode == "Body" ? "body" : "high−low range") + ") in ATR(" + str.tostring(atrLenSize) + ").\n" + (opp == 2 ? "This is the signal candle — this value is decisive." : "Preview — the 2nd opposite candle is decisive.")
    f_cell(t, c, 6, stSize, txtSize, tipSize, na)
    nFail += stSize == ST_FAIL ? 1 : 0
    nWait += stSize == ST_WAIT ? 1 : 0

    // 7. Flat EMA filter
    int stFlat = not useEmaMoveFilter ? ST_OFF : emaMoveOk ? ST_OK : ST_FAIL
    string txtFlat = f_num(emaMoveAtr) + " ATR" + (useEmaMoveFilter ? " (min " + f_num(minEmaMoveAtr) + ")" : " · off")
    string tipFlat = "EMA range (highest − lowest) over the last " + str.tostring(emaMoveLen) + " bars, in ATR(" + str.tostring(atrLenEmaMove) + ").\nShared by long and short."
    f_cell(t, c, 7, stFlat, txtFlat, tipFlat, na)
    nFail += stFlat == ST_FAIL ? 1 : 0

    // 8. Trend strength (information)
    bool weak = na(emaMoveAtr) or emaMoveAtr < strongTrendAtr
    string strength = na(emaMoveAtr) ? "—" : emaMoveAtr >= vStrongTrendAtr ? "very strong" : emaMoveAtr >= strongTrendAtr ? "strong" : "weak"
    bool aligned = isL == emaRising
    string txtTr = (emaRising ? "↑ " : "↓ ") + strength + (weak ? " (flat)" : aligned ? " · aligned" : " · opposed")
    color colTr = weak ? OFF_COL : aligned ? bullCol : WAIT_COL
    string tipTr = "EMA direction over a " + str.tostring(emaMoveLen) + "-bar window and strength based on the EMA move (" + f_num(emaMoveAtr) + " ATR).\nWeak < " + f_num(strongTrendAtr) + " ≤ strong < " + f_num(vStrongTrendAtr) + " ≤ very strong.\nAligned = trend in the direction of this signal. Informational only — does not block."
    f_cell(t, c, 8, ST_INFO, txtTr, tipTr, colTr)

    // 9. Category
    int stCat = catOn ? ST_OK : ST_FAIL
    string txtCat = (isTrendCat ? "Trend" : "Counter") + (catOn ? "" : " · off")
    string tipCat = "Category a " + (isL ? "long" : "short") + " signal would receive at the current close: price is " + (close > emaVal ? "ABOVE" : close < emaVal ? "BELOW" : "AT") + " the EMA.\n" + (catOn ? "This category is enabled (section 1)." : "This category is disabled in section 1 — blocking.")
    f_cell(t, c, 9, stCat, txtCat, tipCat, na)
    nFail += stCat == ST_FAIL ? 1 : 0

    // 10. Distance from EMA
    bool distFilterOn = isTrendCat ? useTrendMaxDist : useCounterMinDist
    int stDist = not distFilterOn ? ST_OFF : distOk ? ST_OK : ST_FAIL
    string txtDist = f_num(emaDistAtr) + " ATR" + (distFilterOn ? (isTrendCat ? " (max " + f_num(maxTrendDistAtr) + ")" : " (min " + f_num(minCounterDistAtr) + ")") : " · off")
    string tipDist = "Distance of the current bar's close from the EMA in ATR(" + str.tostring(atrLenDist) + ").\n" + (isTrendCat ? "A MAXIMUM applies to the Trend category" : "A MINIMUM applies to the Counter category") + " (section 5)."
    f_cell(t, c, 10, stDist, txtDist, tipDist, na)
    nFail += stDist == ST_FAIL ? 1 : 0

    // 11. Result — names of blocking conditions (✗)
    array<int>    stArr = array.from(stLen, stMv, stLvl, stWick, stSize, stFlat, stCat, stDist)
    array<string> nmArr = array.from("streak", "streak move", "level break", "wick", "size", "flat EMA", "category", "distance")
    string failShort = ""
    string failAll   = ""
    int    failCnt   = 0
    for i = 0 to array.size(stArr) - 1
        if array.get(stArr, i) == ST_FAIL
            string nm = array.get(nmArr, i)
            failAll += (failCnt > 0 ? ", " : "") + nm
            if failCnt < 2
                failShort += (failCnt > 0 ? ", " : "") + nm
            failCnt += 1
    string failTxt = failShort + (failCnt > 2 ? " +" + str.tostring(failCnt - 2) : "")

    int stRes = not enabled ? ST_OFF : sig ? ST_OK : failCnt > 0 ? ST_FAIL : ST_WAIT
    string txtRes = not enabled ? "off" : sig ? "YES · " + (isTrendCat ? "Trend" : "Counter") : failCnt > 0 ? "NO · " + failTxt : "waiting"
    string tipRes = not enabled ? "This direction is disabled in section 1." : sig ? "Signal on the current bar (confirmed at bar close)." : failCnt > 0 ? "Blocking (✗): " + failAll + ".\nConditions marked “…” may still change." : "No condition is blocking — waiting for more bars (" + str.tostring(nWait) + "× …)."
    table.cell(t, c, 11, f_icon(stRes) + txtRes, text_color = f_stCol(stRes), bgcolor = tblHdrCol, text_size = tblSize, text_halign = text.align_left, tooltip = tipRes)

    // 12. Last signal
    string txtLast = na(lastBar) ? "none" : (bar_index - lastBar == 0 ? "now" : str.tostring(bar_index - lastBar) + " bars ago") + " · " + (lastTrend ? "Trend" : "Counter")
    string tipLast = "Last " + (isL ? "long" : "short") + " signal that passed all filters (drawn on the chart). Blocked signals are not counted here."
    f_cell(t, c, 12, ST_INFO, txtLast, tipLast, na(lastBar) ? OFF_COL : isL ? bullCol : bearCol)

var table tbl = na
if showTable and barstate.islast
    if na(tbl)
        tbl := table.new(tblPos, 3, 13, bgcolor = tblBgCol, frame_color = color.new(color.gray, 60), frame_width = 1, border_color = color.new(color.gray, 80), border_width = 1)

    // Header
    table.cell(tbl, 0, 0, "Condition", text_color = tblTxtCol, bgcolor = tblHdrCol, text_size = tblSize, text_halign = text.align_left, tooltip = "Signal condition checklist for the CURRENT bar.\n✓ met\n✗ blocks the signal\n… cannot be evaluated yet (waiting for more bars)\n○ filter off\nHover over a cell to see details.")
    table.cell(tbl, 1, 0, "LONG",      text_color = bullCol,   bgcolor = tblHdrCol, text_size = tblSize, text_halign = text.align_left, tooltip = "Upside reversal: streak of red candles → 2 green candles.")
    table.cell(tbl, 2, 0, "SHORT",     text_color = bearCol,   bgcolor = tblHdrCol, text_size = tblSize, text_halign = text.align_left, tooltip = "Downside reversal: streak of green candles → 2 red candles.")

    // Row names
    f_label(tbl, 1,  "Streak length",       "Length of the streak preceding the reversal (long: red, short: green).\nSingle opposite candles are not counted as a streak.\nSection 2.")
    f_label(tbl, 2,  "Streak move",         "Distance covered by this streak, in ATR.\nSection 2.")
    f_label(tbl, 3,  "Opposite candles",    "How many opposite candles have appeared after the streak (2 required).")
    f_label(tbl, 4,  "Level break",         "Close of the 2nd opposite candle beyond the level of the 1st opposite candle.\nSection 3.")
    f_label(tbl, 5,  "Current candle wick", "Opposite wick of the current candle (long: upper, short: lower) as % of its range.\nSection 3.")
    f_label(tbl, 6,  "Current candle size", "Body or range of the current candle in ATR.\nSection 3.")
    f_label(tbl, 7,  "Flat EMA",            "Flat EMA filter — EMA range over the window, in ATR.\nSection 4.")
    f_label(tbl, 8,  "Trend strength",      "Trend direction and strength based on the EMA move; thresholds in section 4.\nInformational only.")
    f_label(tbl, 9,  "Category",            "Trend / Counter — based on price position relative to the EMA; shows whether this category is enabled.\nSection 1.")
    f_label(tbl, 10, "Distance from EMA",   "Distance of the close from the EMA in ATR, with the applicable limit.\nSection 5.")
    table.cell(tbl, 0, 11, "SIGNAL", text_color = tblTxtCol, bgcolor = tblHdrCol, text_size = tblSize, text_halign = text.align_left, tooltip = "Whether there is a signal on the current bar.\nYES — with the signal category.\nNO — names of the blocking conditions (max 2, “+N” = more; full list in the cell tooltip).\nwaiting — nothing is blocking, more bars are needed.")
    f_label(tbl, 12, "Last signal",         "Last signal that passed all filters.")

    // Columns
    f_fillSide(tbl, 1, true,  showLong,  lOpp, lLen, lMove, isBull, oppWickPct, close > longLevel,  longLevel,  longIsTrend,  categoryOkLong,  longDistOk,  longSignal,  lastLongBar,  lastLongTrend)
    f_fillSide(tbl, 2, false, showShort, sOpp, sLen, sMove, isBear, lowWickPct, close < shortLevel, shortLevel, shortIsTrend, categoryOkShort, shortDistOk, shortSignal, lastShortBar, lastShortTrend)

// TP/SL

float atrTP = ta.atr(tpAtrPeriod)

var int      tpslDir        = 0      // 1 = long, -1 = short, 0 = no active position
var int      tpslEntryBar   = na
var float    tpslSL         = na
var float    tpslExtreme    = na     // farthest visible TP — hitting it ends the levels
var line     tpslEntryLn    = na
var label    tpslEntryLb    = na
var line     tpslSlLn       = na
var label    tpslSlLb       = na
var line     tpslTp1Ln      = na
var label    tpslTp1Lb      = na
var line     tpslTp2Ln      = na
var label    tpslTp2Lb      = na
var line     tpslTp3Ln      = na
var label    tpslTp3Lb      = na
var line     tpslExtLn      = na     // invisible helper line for the reward zone fill
var linefill tpslRiskFill   = na
var linefill tpslRewardFill = na

// New signal → new levels (previous ones are removed)
if showTargets and (longSignal or shortSignal)
    bool isLongTrade = longSignal

    line.delete(tpslEntryLn)
    label.delete(tpslEntryLb)
    line.delete(tpslSlLn)
    label.delete(tpslSlLb)
    line.delete(tpslTp1Ln)
    label.delete(tpslTp1Lb)
    line.delete(tpslTp2Ln)
    label.delete(tpslTp2Lb)
    line.delete(tpslTp3Ln)
    label.delete(tpslTp3Lb)
    line.delete(tpslExtLn)
    linefill.delete(tpslRiskFill)
    linefill.delete(tpslRewardFill)
    tpslSlLn  := na
    tpslSlLb  := na
    tpslTp1Ln := na
    tpslTp1Lb := na
    tpslTp2Ln := na
    tpslTp2Lb := na
    tpslTp3Ln := na
    tpslTp3Lb := na
    tpslExtLn := na

    tpslDir      := isLongTrade ? 1 : -1
    tpslEntryBar := bar_index

    float entryP   = close
    float riskDist = useAtrSL ? atrTP * slAtrMult : entryP * (slPercent / 100.0)

    color entryCol    = color.new(isLongTrade ? bullCol : bearCol, 40)
    color slCol       = color.new(isLongTrade ? bearCol : bullCol, 40)
    color tpCol       = color.new(isLongTrade ? bullCol : bearCol, 40)
    // TP/SL labels — same transparency as the signal labels (20)
    color entryLbCol  = color.new(isLongTrade ? bullCol : bearCol, 20)
    color slLbCol     = color.new(isLongTrade ? bearCol : bullCol, 20)
    color tpLbCol     = color.new(isLongTrade ? bullCol : bearCol, 20)
    color riskFillC   = color.new(isLongTrade ? bearCol : bullCol, 80)
    color rewardFillC = color.new(isLongTrade ? bullCol : bearCol, 80)

    float slP  = isLongTrade ? entryP - riskDist         : entryP + riskDist
    float tp1P = isLongTrade ? entryP + riskDist * rrTP1 : entryP - riskDist * rrTP1
    float tp2P = isLongTrade ? entryP + riskDist * rrTP2 : entryP - riskDist * rrTP2
    float tp3P = isLongTrade ? entryP + riskDist * rrTP3 : entryP - riskDist * rrTP3

    tpslSL := slP

    tpslEntryLn := line.new(bar_index, entryP, bar_index + 1, entryP, color = entryCol, width = 2)
    tpslEntryLb := label.new(bar_index, entryP, (isLongTrade ? "LONG " : "SHORT ") + str.tostring(entryP, format.mintick), style = label.style_label_left, color = entryLbCol, textcolor = color.white, size = size.small)

    if showSlLevel
        tpslSlLn := line.new(bar_index, slP, bar_index + 1, slP, color = slCol, width = 1, style = line.style_dashed)
        tpslSlLb := label.new(bar_index, slP, "SL " + str.tostring(slP, format.mintick), style = label.style_label_left, color = slLbCol, textcolor = color.white, size = size.small)
        tpslRiskFill := linefill.new(tpslEntryLn, tpslSlLn, riskFillC)

    if showTp1Level
        tpslTp1Ln := line.new(bar_index, tp1P, bar_index + 1, tp1P, color = tpCol, width = 1)
        tpslTp1Lb := label.new(bar_index, tp1P, "TP1 " + str.tostring(tp1P, format.mintick), style = label.style_label_left, color = tpLbCol, textcolor = color.white, size = size.small)

    if showTp2Level
        tpslTp2Ln := line.new(bar_index, tp2P, bar_index + 1, tp2P, color = tpCol, width = 1)
        tpslTp2Lb := label.new(bar_index, tp2P, "TP2 " + str.tostring(tp2P, format.mintick), style = label.style_label_left, color = tpLbCol, textcolor = color.white, size = size.small)

    if showTp3Level
        tpslTp3Ln := line.new(bar_index, tp3P, bar_index + 1, tp3P, color = tpCol, width = 1, style = line.style_dotted)
        tpslTp3Lb := label.new(bar_index, tp3P, "TP3 " + str.tostring(tp3P, format.mintick), style = label.style_label_left, color = tpLbCol, textcolor = color.white, size = size.small)

    // Farthest visible TP: ends the levels when hit + outer edge of the reward zone
    float fillExtreme = na
    if showTp1Level or showTp2Level or showTp3Level
        float t1 = showTp1Level ? tp1P : entryP
        float t2 = showTp2Level ? tp2P : entryP
        float t3 = showTp3Level ? tp3P : entryP
        fillExtreme := isLongTrade ? math.max(t1, t2, t3) : math.min(t1, t2, t3)
    tpslExtreme := fillExtreme
    if not na(fillExtreme) and fillExtreme != entryP
        tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na)
        tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)

// Extending the levels and detecting an SL / farthest TP hit
f_lnX(line l, int x) =>
    if not na(l)
        line.set_x2(l, x)

f_lbX(label l, int x) =>
    if not na(l)
        label.set_x(l, x)

if tpslDir != 0
    f_lbX(tpslEntryLb, bar_index)
    f_lbX(tpslSlLb,    bar_index)
    f_lbX(tpslTp1Lb,   bar_index)
    f_lbX(tpslTp2Lb,   bar_index)
    f_lbX(tpslTp3Lb,   bar_index)

    f_lnX(tpslEntryLn, bar_index + 1)
    f_lnX(tpslSlLn,    bar_index + 1)
    f_lnX(tpslTp1Ln,   bar_index + 1)
    f_lnX(tpslTp2Ln,   bar_index + 1)
    f_lnX(tpslTp3Ln,   bar_index + 1)
    f_lnX(tpslExtLn,   bar_index + 1)

    bool slHit = tpslDir == 1 ? low <= tpslSL : high >= tpslSL
    bool tpHit = not na(tpslExtreme) and (tpslDir == 1 ? high >= tpslExtreme : low <= tpslExtreme)

    if bar_index > tpslEntryBar and (slHit or tpHit)
        f_lnX(tpslEntryLn, bar_index)
        f_lnX(tpslSlLn,    bar_index)
        f_lnX(tpslTp1Ln,   bar_index)
        f_lnX(tpslTp2Ln,   bar_index)
        f_lnX(tpslTp3Ln,   bar_index)
        f_lnX(tpslExtLn,   bar_index)
        tpslDir := 0

// BACKTESTER OUTPUT PLOTS

plot(longTrendSig    ? 1 : na, "backtest_buy_trend",    display = display.none)
plot(longCounterSig  ? 1 : na, "backtest_buy_counter",  display = display.none)
plot(shortTrendSig   ? 1 : na, "backtest_sell_trend",   display = display.none)
plot(shortCounterSig ? 1 : na, "backtest_sell_counter", display = display.none)

// ALERTS (select in the "Create Alert" dialog — recommended: "Once Per Bar Close")

alertcondition(longSignal or shortSignal, "REV — Any signal",       "REV {{ticker}} {{interval}}: reversal signal @ {{close}}")
alertcondition(longSignal,                "REV — Long",             "REV LONG {{ticker}} {{interval}} @ {{close}}")
alertcondition(shortSignal,               "REV — Short",            "REV SHORT {{ticker}} {{interval}} @ {{close}}")
alertcondition(longTrendSig,              "REV — Long (trend)",     "REV LONG (trend) {{ticker}} {{interval}} @ {{close}}")
alertcondition(longCounterSig,            "REV — Long (counter)",   "REV LONG (counter) {{ticker}} {{interval}} @ {{close}}")
alertcondition(shortTrendSig,             "REV — Short (trend)",    "REV SHORT (trend) {{ticker}} {{interval}} @ {{close}}")
alertcondition(shortCounterSig,           "REV — Short (counter)",  "REV SHORT (counter) {{ticker}} {{interval}} @ {{close}}")
````
