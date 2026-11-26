# Weis Wave Renko - Effort vs Result

- url: https://www.tradingview.com/script/uKQBgrg2-Weis-Wave-Renko-Effort-vs-Result/
- type: indicator
- pine_id: PUB;82504657b01c4817ac7533b571ee7a2b
- version: 6.0

## Description

[b]ABOUT THIS SCRIPT
[/b]
[b]Weis Wave Renko – Effort vs Result indicator[/b]combines Renko price structure with Weis Wave volume analysis to help assess the relationship between market effort and price result.

This script is a fork and substantial extension of the original “Weis Wave Volume” script published by [b]modhelius[/b]. Full credit is given to [b]modhelius[/b] for the original Weis Wave calculation, Renko assignment methodology and histogram on which this version is based.

[b]PURPOSE[/b]
The script was developed to support the following workflow:
[list=1]
[*]Use VSA/Wyckoff analysis to identify the market background and possible exhaustion, absorption or testing activity.
[*]Use Weis Wave volume to compare the effort behind successive buying and selling waves.
[*]Use Renko structure to confirm changes of direction, higher lows, lower highs and sustained reversals.
[*]Use the developing relationship between effort and result to assess whether supply or demand is strengthening, weakening or being absorbed.
[*]Where appropriate, use a confirmed Renko reversal as part of an entry, stop-placement or trade-management process.
[/list]The script is intended to support a discretionary Wyckoff/VSA-style analysis of Renko charts.
It does not treat every Renko colour change as a trading signal. Instead, it is designed to help answer questions such as:[list]
[*]Is demand expanding or contracting?
[*]Is supply expanding or contracting?
[*]Is price rising with less apparent selling resistance?
[*]Is price falling because support beneath the market is weak?
[*]Is increased volume producing less price progress?
[*]Does a high-volume wave represent a possible buying or selling climax?
[*]Has a later lower-volume test supported or rejected that interpretation?
[/list]The underlying concept is effort versus result:
[list]
[*]Effort = cumulative wave volume.
[*]Result = the price movement achieved by the Renko wave.
[/list]
[b]PIVOT STATISTICS[/b]
At each completed Renko peak or trough, the script displays:[list]
[*]Weis Wave volume.
[*]Number of Renko boxes contained in the wave.[/list]
The statistics box refers to the completed wave that formed that peak or trough.
The current uncompleted wave can also display a live statistics box. Live statistics remain provisional until the wave is completed by a confirmed change of direction.

[b]WAVE COMMENTS[/b]
Each completed wave can receive a separate comment box connected to the centre of the relevant Renko leg.

The comment box may contain three distinct sections:
[list=1]
[*]Structural conclusion.
[*]Primary wave classification from the Scenario Key.
[*]Explanation based on later price and volume behaviour.
[/list]
For example:
Buying climax confirmed

Demand expanding

Next up-wave retest failed below the climax high on lower volume

The primary wave classification describes the completed wave relative to the previous wave in the same direction.

The structural conclusion may update later as additional waves complete reflecting the dynamic nature of the indicator.

[b]PRIMARY WAVE CLASSIFICATIONS[/b]

[b]Up-waves are compared with the preceding completed up-wave:[/b][i][/i]

Demand expanding - More volume accompanied by a longer rise.

Demand contracting - Less volume accompanied by a shorter rise.

Less effort needed to rise - Similar or lower volume produced the same or greater upward progress.

Buying effort absorbed - More volume produced a shorter rise, suggesting that buying effort encountered supply.

[b]Down-waves are compared with the preceding completed down-wave:[/b][i][/i]

Supply expanding - More volume accompanied by a longer decline.

Supply contracting - Less volume accompanied by a shorter decline.

Less support beneath price - Similar or lower volume produced the same or greater downward progress.

Selling effort absorbed - More volume produced a shorter decline, suggesting that selling effort encountered demand.

No material change - Neither volume nor price result changed sufficiently to exceed the selected Material Change Threshold.

[b]CLIMAX ANALYSIS[/b]

A large wave is not classified as a confirmed climax merely because it has high volume.  The script uses a staged process:

[b][i]Possible buying climax:[/i][/b][list=1]
[*]An up-wave becomes a buying-climax candidate.
[*]The next down-wave must produce the selected Renko reversal confirmation, which defaults to three boxes.
[*]The immediately following up-wave is treated as the retest.
[*]The buying climax is confirmed only when that next up-wave:[/list][list]   [*]has lower volume than the original climax up-wave;   [*]produces a shorter rise; and   [*]fails below the climax high.[/list]The comment can then state:

Buying climax confirmed - [Primary up-wave classification]
Next up-wave retest failed below the climax high on lower volume - Possible selling climax
[list=1]   [*]A down-wave becomes a selling-climax candidate.   [*]The next up-wave must produce the selected Renko reversal confirmation.   [*]The immediately following down-wave is treated as the test.   [*]The selling climax is confirmed only when that next down-wave:[/list][list]   [*]has lower volume than the original climax down-wave;   [*]produces a shorter decline; and   [*]holds above the climax low.[/list]
The comment can then state:

Selling climax confirmed - [Primary down-wave classification]
Next down-wave test held above the climax low on lower volume

Only the immediate next corresponding up-wave or down-wave is used for the test. The script does not search through later waves to find a result that retrospectively fits the climax interpretation.

[b]NO SUPPLY AND NO DEMAND
[/b]
[b][i]Possible no supply requires a down-wave that:[/i][/b][list]
[*]has lower volume than the previous down-wave;
[*]produces a shorter decline; and
[*]forms a higher low.
[/list]The following up-wave must then sustain the selected number of reversal boxes.

[b][i]Possible no demand requires an up-wave that:[/i][/b][list]
[*]has lower volume than the previous up-wave;
[*]produces a shorter rise; and
[*]forms a lower high.
[/list]
The following down-wave must then sustain the selected number of reversal boxes.
These are rule-based interpretations of wave behaviour. They are not substitutes for a full Wyckoff or VSA analysis of background, location and market structure.

[b]DEVELOPING WAVES[/b]

The current wave comment can update dynamically as volume and Renko-box count accumulate.
Developing comments use provisional wording such as:[list]
[*]Demand currently expanding.
[*]Supply currently contracting.
[*]Buying effort currently absorbed.
[*]Possible no supply.
[*]Possible no demand.[/list]
A developing classification can change before the wave completes.

[b]PROJECTION BOXES/BRICKS[/b]
TradingView can display projection boxes/bricks while the source-timeframe bar remains open.
Projection does not mean that the script is forecasting future bricks. It means that current price before the time period close has already moved far enough to meet one or more Renko thresholds during the still-open source bar.
For example, on a Daily Renko chart:[list]
[*]intraday price movement can produce provisional Renko bricks;
[*]those bricks can appear before the Daily bar closes;
[*]they can change or disappear before the close;
[*]they become part of the confirmed historical Renko structure only after the source bar is confirmed.[/list]
The same principle applies to Weekly and other source intervals.
Live statistics and developing comments should therefore be treated as provisional.

b]RENKO ASSIGNMENT METHODS[/b]

[b]Traditional:[/b] Traditional uses a fixed price-unit assignment value.
If the TradingView chart is set to: Traditional box size = 3, the indicator should normally also be set to the same Renko Assignment Method = Traditional Value = 3
The script cannot automatically read the Renko box-size setting from the TradingView chart.

[b]ATR:[/b] ATR derives the assignment value from Average True Range.  The Value input represents the ATR lookback period rather than a fixed number of price points.  ATR adapts to volatility, but changing box/brick size make historical box-count comparisons less directly uniform than Traditional sizing.

[b]Part of Price:[/b]  The inherited Part of Price method calculates close ÷ Value
For example:  Value 20 = approximately 5% of price.  This is not identical to TradingView’s Percentage LTP Renko setting.

[b]DISPLAY AND POSITIONING[/b]
The script includes adjustable controls for:[list]
[*]up-wave and down-wave histogram colours;
[*]histogram transparency;
[*]pivot statistics placement;
[*]statistics font size;
[*]statistics connector lines;
[*]adjacent statistics-label stacking;
[*]wave-comment font size and line wrapping;
[*]wave-comment vertical and horizontal offsets;
[*]adjacent wave-comment stacking;
[*]comment connector lines;
[*]Permanent Note position and dimensions;
[*]Scenario Key position and dimensions.[/list]
Adjacent label and chart leg comment box stacking is optional.  Because Pine cannot measure the rendered pixel width or height of labels, collision avoidance is based on bar distance and price-coordinate separation rather than exact screen-pixel boundaries.  The user may need to adjust these settings in the user interface panel to avoid overlapping of labels and comment boxes.

[b]SCENARIO KEY[/b]
The Scenario Key translates observable effort-and-result combinations into the primary wave comments used by the script.
The table also explains the structural sequences used for:[list]
[*]climax candidates;
[*]confirmed buying and selling climaxes;
[*]possible no supply;
[*]possible no demand;
[*]failed follow-through;
[*]provisional current-wave conclusions.[/list]

[b]TIMEFRAME CONSIDERATIONS[/b]
Changing the TradingView chart timeframe changes the source data used to construct the Renko chart.
A Daily Renko structure and a Weekly Renko structure are therefore separate reconstructions, not merely different zoom levels of the same sequence.
Weekly charts may be useful for broad structural background.
Daily charts may provide more responsive directional changes.
Lower source intervals generally provide greater granularity but also produce more noise and more frequent projection box/brick changes.

[b]LIMITATIONS[/b]
Renko charts use synthetic price construction.
The apparent Renko box/brick price is not always a directly tradable execution price.
Projection boxes/bricks can repaint while the source bar is open.
Historical calculations can change when:[list]
[*]the chart timeframe changes;
[*]Renko settings change;
[*]indicator assignment settings change;
[*]additional lower-timeframe data becomes available;
[*]TradingView reconstructs the Renko history.[/list]
This indicator should not be used to assume fills at ideal Renko box/brick prices.
Any strategy testing should use confirmed signals and actual market OHLC prices, with appropriate allowance for spread, slippage and execution delay.
The script provides analytical context. It does not provide financial advice or guarantee that any identified climax, test, no-supply condition, no-demand condition or Renko reversal will lead to a profitable trade.

[b]CREDITS[/b]
Original Weis Wave Volume script and core calculation: [b]modhelius[/b]
This version is an amended and extended fork incorporating:[list]
[*]Renko peak and trough statistics;
[*]wave box counts;
[*]dynamic wave comments;
[*]effort-versus-result classifications;
[*]climax and test sequencing;
[*]no-supply and no-demand analysis;
[*]projection-brick context;
[*]configurable display, positioning and overlap-management controls.[/list]

[b]DEVELOPMENT CONTEXT[/b]
The extended analytical concept implemented in this fork was developed following [b]James Knox[/b]’s presentation to the "To The Tick" trading group on 20/7/26 combining:[list]
[*]TradeGuider VSA observations;
[*]Wyckoff concepts of effort versus result, climaxes, tests, springs, no supply and no demand;
[*]Weis Wave volume;
[*]Renko changes of direction and structural pivots.[/list]

The script’s classifications and dynamic comments were developed to make those relationships more easily visible directly on the Renko chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © paulgill28

//@version=6
indicator('Weis Wave Renko - Effort vs Result v.41', shorttitle='WWV E/R', overlay=false, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// Forked from the original Weis Wave Volume script by modhelius.
// Original Weis Wave calculation, Renko assignment methodology and histogram retained.
// Extended with compact pivot statistics, dynamic three-part wave comments,
// configurable histogram styling and explanatory tables.
// Scenario Key body text is left-aligned and wrapped using width- and font-responsive
// maximum-character settings. Each row now uses Pine's automatic height mode,
// so short one-line rows remain compact while longer rows expand only as needed.
// The opening column widths and wrap limits are calibrated for the full explicit
// 23-scenario wording so the Key remains compact enough to share the main pane
// with the Permanent Note. Column widths, wrap limits and font size remain independently adjustable.
// Pivot statistics support selectable default or
// monospaced typefaces, optional bold text and selectable text colour. Wave comments also support
// optional bold text. Adjacent statistics use bounded inward reusable lanes.
// Adjacent wave comments first use the configured reusable lanes and then apply
// automatic text-height-aware outward separation when necessary to prevent overlap.

// ============================================================================
// ORIGINAL WEIS WAVE INPUTS
// ============================================================================

methodtype = input.string(defval='Traditional', options=['ATR', 'Traditional', 'Part of Price'], title='Renko Assignment Method', display=display.status_line)
methodvalue = input.float(defval=3.0, minval=0.000001, title='Value', tooltip='ATR: lookback length. Traditional: fixed price-unit assignment value, which should match the chart Renko box size. Part of Price: divisor; for example, 20 means 5% of price.', display=display.status_line)
pricesource = input.string(defval='Close', options=['Close', 'Open / Close', 'High / Low'], title='Price Source', display=display.none)
useClose = pricesource == 'Close'
useOpenClose = pricesource == 'Open / Close' or useClose
useTrueRange = input.string(defval='Auto', options=['Always', 'Auto', 'Never'], title='Use True Range instead of Volume', display=display.none)
isOscillating = input.bool(defval=false, title='Oscillating', display=display.none)
normalize = input.bool(defval=false, title='Normalize', display=display.none)

// ============================================================================
// WAVE HISTOGRAM STYLE
// ============================================================================

const string HISTOGRAM_GROUP = 'Wave Histogram Style'

upWaveHistogramColour = input.color(defval=color.green, title='Up-wave Colour', group=HISTOGRAM_GROUP, display=display.none)
downWaveHistogramColour = input.color(defval=color.red, title='Down-wave Colour', group=HISTOGRAM_GROUP, display=display.none)
upWaveHistogramTransparency = input.int(defval=0, minval=0, maxval=100, title='Up-wave Transparency', tooltip='0 is fully opaque. 100 is invisible.', group=HISTOGRAM_GROUP, display=display.none)
downWaveHistogramTransparency = input.int(defval=0, minval=0, maxval=100, title='Down-wave Transparency', tooltip='0 is fully opaque. 100 is invisible.', group=HISTOGRAM_GROUP, display=display.none)

// ============================================================================
// PIVOT STATISTICS
// ============================================================================

const string STATS_GROUP = 'Pivot Statistics'

showCompletedWaveLabels = input.bool(defval=true, title='Show Completed Wave Statistics', group=STATS_GROUP, display=display.none)
showCurrentWaveLabel = input.bool(defval=true, title='Show Current Uncompleted Wave Statistics', tooltip='The current statistics box changes and moves until the wave is completed by a confirmed reversal.', group=STATS_GROUP, display=display.none)
peakPlacement = input.string(defval='Above', options=['Above', 'Below'], title='Peak Statistics Placement', group=STATS_GROUP, display=display.none)
troughPlacement = input.string(defval='Below', options=['Above', 'Below'], title='Trough Statistics Placement', group=STATS_GROUP, display=display.none)
verticalDistanceUnit = input.string(defval='Renko Boxes', options=['Renko Boxes', 'Ticks', 'Price Units'], title='Statistics Distance Unit', group=STATS_GROUP, display=display.none)
peakDistance = input.float(defval=25.0, minval=0.0, step=0.25, title='Peak Vertical Distance', group=STATS_GROUP, display=display.none)
troughDistance = input.float(defval=25.0, minval=0.0, step=0.25, title='Trough Vertical Distance', group=STATS_GROUP, display=display.none)
labelFontSize = input.int(defval=12, minval=6, maxval=48, title='Statistics Font Size', group=STATS_GROUP, display=display.none)
statisticsTypeface = input.string(defval='Default', options=['Default', 'Monospaced'], title='Statistics Typeface', tooltip='Monospaced gives every character equal width, which makes the volume and box-count figures easier to compare and gives the statistics labels more predictable widths.', group=STATS_GROUP, display=display.none)
boldWaveStatisticsText = input.bool(defval=true, title='Bold Wave Statistics Text', tooltip='Applies bold formatting to completed and current wave statistics labels.', group=STATS_GROUP, display=display.none)
statisticsTextColour = input.color(defval=color.rgb(0, 0, 0), title='Statistics Text Colour', tooltip='Sets the text colour for completed and current wave statistics labels.', group=STATS_GROUP, display=display.none)
upWaveStatisticsFillColour = input.color(defval=color.rgb(76, 175, 80), title='Up-wave Statistics Fill Colour', tooltip='Sets the fill colour for completed and current up-wave statistics labels.', group=STATS_GROUP, display=display.none)
downWaveStatisticsFillColour = input.color(defval=color.rgb(255, 82, 82), title='Down-wave Statistics Fill Colour', tooltip='Sets the fill colour for completed and current down-wave statistics labels.', group=STATS_GROUP, display=display.none)
completedStatisticsFillTransparency = input.int(defval=0, minval=0, maxval=100, title='Completed Statistics Fill Transparency', tooltip='0 is fully opaque. 100 is invisible.', group=STATS_GROUP, display=display.none)
developingStatisticsFillTransparency = input.int(defval=35, minval=0, maxval=100, title='Developing Statistics Fill Transparency', tooltip='0 is fully opaque. 100 is invisible.', group=STATS_GROUP, display=display.none)
showConnectorLines = input.bool(defval=true, title='Show Statistics Connector Lines', group=STATS_GROUP, display=display.none)
connectorLineThickness = input.int(defval=1, minval=1, maxval=10, title='Statistics Connector Thickness', tooltip='Thickness in pixels.', group=STATS_GROUP, display=display.none)
volumeDivisor = input.float(defval=1000000.0, minval=0.000001, title='Volume Divisor', tooltip='Use 1 for full values, 1,000 for thousands, 1,000,000 for millions or 1,000,000,000 for billions.', group=STATS_GROUP, display=display.none)
decimalPlaces = input.int(defval=0, minval=0, maxval=4, title='Decimal Places', group=STATS_GROUP, display=display.none)
maximumHistoricalLabels = input.int(defval=200, minval=3, maxval=250, title='Maximum Historical Waves', tooltip='The script retains at least three completed waves so multi-wave confirmation logic can finish.', group=STATS_GROUP, display=display.none)
enableAdjacentStatsStacking = input.bool(defval=true, title='Enable Adjacent Statistics Stacking', tooltip='Compares each statistics label with the preceding label in the same wave direction. The newer label is staggered only when their estimated horizontal ranges overlap and their vertical ranges do not have sufficient clearance.', group=STATS_GROUP, display=display.none)
adjacentStatsDistanceBars = input.int(defval=30, minval=1, maxval=500, title='Adjacent Statistics Distance — Bars', tooltip='Calibrates the estimated horizontal width of statistics labels in bars. Larger values make the collision test more cautious when the chart is compressed horizontally.', group=STATS_GROUP, display=display.none)
statsStackingDistanceUnit = input.string(defval='Price Units', options=['Price Units', 'Renko Boxes', 'Percentage of Price'], title='Statistics Stacking Unit', tooltip='Price Units uses the instrument price scale. Renko Boxes multiplies the separation by the visible brick size. Percentage of Price scales it to the pivot price.', group=STATS_GROUP, display=display.none)
minimumStatsVerticalSeparation = input.float(defval=50.0, minval=0.0, step=0.25, title='Minimum Statistics Vertical Separation', tooltip='Minimum clear vertical distance between the estimated bottom edge of one adjacent statistics label and the estimated top edge of the next. The newer label is moved farther away from price when necessary.', group=STATS_GROUP, display=display.none)

string statisticsFontFamily = statisticsTypeface == 'Monospaced' ? font.family_monospace : font.family_default
statisticsTextFormatting = boldWaveStatisticsText ? text.format_bold : text.format_none

// ============================================================================
// WAVE COMMENTS
// ============================================================================

const string CALLOUT_GROUP = 'Wave Comments'

showWaveCallouts = input.bool(defval=true, title='Show Completed Wave Comments', group=CALLOUT_GROUP, display=display.none)
showCurrentWaveCallout = input.bool(defval=true, title='Show Current Developing Wave Comment', group=CALLOUT_GROUP, display=display.none)
calloutFontSize = input.int(defval=12, minval=6, maxval=30, title='Comment Font Size', group=CALLOUT_GROUP, display=display.none)
boldWaveCommentText = input.bool(defval=true, title='Bold Wave Comment Text', tooltip='Applies bold formatting to completed and current developing wave-comment labels.', group=CALLOUT_GROUP, display=display.none)
commentTextFormatting = boldWaveCommentText ? text.format_bold : text.format_none
calloutMaxCharacters = input.int(defval=18, minval=8, maxval=50, title='Maximum Characters per Line', tooltip='Smaller values produce narrower, taller comment boxes.', group=CALLOUT_GROUP, display=display.none)
calloutDistanceUnit = input.string(defval='Price Units', options=['Renko Boxes', 'Ticks', 'Price Units'], title='Comment Gap Unit', group=CALLOUT_GROUP, display=display.none)
upCalloutGap = input.float(defval=220.0, minval=0.0, step=0.25, title='Up-wave Gap above Statistics', tooltip='Additional vertical distance above the peak statistics box.', group=CALLOUT_GROUP, display=display.none)
downCalloutGap = input.float(defval=220.0, minval=0.0, step=0.25, title='Down-wave Gap below Statistics', tooltip='Additional vertical distance below the trough statistics box.', group=CALLOUT_GROUP, display=display.none)
upCalloutHorizontalOffset = input.int(defval=0, minval=-100, maxval=100, title='Up-wave Horizontal Offset — Bars', tooltip='Moves the comment and its vertical connector away from the exact wave midpoint.', group=CALLOUT_GROUP, display=display.none)
downCalloutHorizontalOffset = input.int(defval=0, minval=-100, maxval=100, title='Down-wave Horizontal Offset — Bars', tooltip='Moves the comment and its vertical connector away from the exact wave midpoint.', group=CALLOUT_GROUP, display=display.none)
enableAdjacentCommentStacking = input.bool(defval=true, title='Enable Adjacent Comment Stacking', tooltip='After statistics-label positions are fixed, each wave comment is compared with the preceding comment in the same wave direction. The newer comment is staggered only when their estimated horizontal and vertical ranges would collide.', group=CALLOUT_GROUP, display=display.none)
adjacentCommentDistanceBars = input.int(defval=50, minval=1, maxval=2000, title='Adjacent Comment Distance — Bars', tooltip='Calibrates the estimated horizontal width of wave-comment boxes in bars. Larger values make the collision test more cautious when the chart is compressed horizontally.', group=CALLOUT_GROUP, display=display.none)
stackingDistanceUnit = input.string(defval='Price Units', options=['Price Units', 'Renko Boxes', 'Percentage of Price'], title='Stacking Distance Unit', tooltip='Price Units uses the instrument price scale. Renko Boxes multiplies the selected separation by the visible Renko brick size. Percentage of Price scales the separation to the wave price.', group=CALLOUT_GROUP, display=display.none)
minimumVerticalSeparation = input.float(defval=350.0, minval=0.0, step=0.25, title='Minimum Vertical Separation', tooltip='Minimum centre-to-centre spacing for horizontally adjacent same-direction comments. The script automatically increases this when taller wrapped comments require more room.', group=CALLOUT_GROUP, display=display.none)
maximumStaggerLevels = input.int(defval=2, minval=1, maxval=50, title='Maximum Stagger Levels', tooltip='Number of reusable outward staggering levels. Exact edge clearance is still enforced whenever estimated horizontal and vertical ranges would collide.', group=CALLOUT_GROUP, display=display.none)
calloutBackgroundTransparency = input.int(defval=15, minval=0, maxval=100, title='Completed Comment Transparency', group=CALLOUT_GROUP, display=display.none)
liveCalloutBackgroundTransparency = input.int(defval=55, minval=0, maxval=100, title='Developing Comment Transparency', group=CALLOUT_GROUP, display=display.none)
calloutTextColour = input.color(defval=color.rgb(0, 0, 0), title='Comment Text Colour', group=CALLOUT_GROUP, display=display.none)
showCalloutConnectorLines = input.bool(defval=true, title='Show Comment Connector Lines', group=CALLOUT_GROUP, display=display.none)
calloutConnectorThickness = input.int(defval=1, minval=1, maxval=10, title='Comment Connector Thickness', group=CALLOUT_GROUP, display=display.none)
calloutConnectorTransparency = input.int(defval=25, minval=0, maxval=100, title='Comment Connector Transparency', group=CALLOUT_GROUP, display=display.none)
comparisonThresholdPercent = input.float(defval=10.0, minval=0.0, maxval=100.0, step=1.0, title='Material Change Threshold %', tooltip='Smaller changes are treated as broadly similar.', group=CALLOUT_GROUP, display=display.none)
climaxResultIncreasePercent = input.float(defval=100.0, minval=0.0, maxval=5000.0, step=10.0, title='Climax Extension Threshold %', tooltip='A wave with higher volume and a result exceeding its previous same-direction wave by at least this amount becomes a climax candidate if price subsequently reverses.', group=CALLOUT_GROUP, display=display.none)
sustainedReversalBoxes = input.int(defval=3, minval=1, maxval=100, title='Reversal Confirmation Boxes', tooltip='Number of opposite-direction Renko boxes required to confirm the price reversal.', group=CALLOUT_GROUP, display=display.none)

// ============================================================================
// PERMANENT NOTE
// ============================================================================

const string NOTE_GROUP = 'Permanent Note'

showPermanentNote = input.bool(defval=true, title='Show Permanent Note', group=NOTE_GROUP, display=display.none)
notePositionInput = input.string(defval='Top Right', options=['Top Left', 'Top Centre', 'Top Right', 'Middle Left', 'Middle Centre', 'Middle Right', 'Bottom Left', 'Bottom Centre', 'Bottom Right'], title='Note Position', tooltip='The Note and Scenario Key should normally use different positions.', group=NOTE_GROUP, display=display.none)
noteFontSize = input.int(defval=14, minval=6, maxval=30, title='Note Font Size', group=NOTE_GROUP, display=display.none)
noteMaxCharacters = input.int(defval=61, minval=20, maxval=150, title='Note Maximum Characters per Line', tooltip='Reference wrap length at the opening Note width and font size. The effective wrap length scales automatically when Note Width or Note Font Size changes. Note height is calculated automatically from the resulting wrapped text.', group=NOTE_GROUP, display=display.none)
noteWidthPercent = input.float(defval=15.05, minval=5.0, maxval=100.0, step=1.0, title='Note Width — % of Pane', group=NOTE_GROUP, display=display.none)
noteBackgroundTransparency = input.int(defval=5, minval=0, maxval=100, title='Note Background Transparency', group=NOTE_GROUP, display=display.none)
noteFrameWidth = input.int(defval=1, minval=0, maxval=10, title='Note Frame Thickness', group=NOTE_GROUP, display=display.none)

// ============================================================================
// SCENARIO KEY
// ============================================================================

const string KEY_GROUP = 'Scenario Key'

showScenarioKey = input.bool(defval=true, title='Show Scenario Key', group=KEY_GROUP, display=display.none)
keyPositionInput = input.string(defval='Bottom Right', options=['Top Left', 'Top Centre', 'Top Right', 'Middle Left', 'Middle Centre', 'Middle Right', 'Bottom Left', 'Bottom Centre', 'Bottom Right'], title='Scenario Key Position', tooltip='The Note and Scenario Key should normally use different positions.', group=KEY_GROUP, display=display.none)
keyFontSize = input.int(defval=12, minval=6, maxval=24, title='Key Font Size', tooltip='Sets the Scenario Key font size directly.', group=KEY_GROUP, display=display.none)
keyScenarioWidthPercent = input.float(defval=9.0, minval=3.0, maxval=50.0, step=0.5, title='Scenario Column Width — %', tooltip='Sets the Scenario column width directly.', group=KEY_GROUP, display=display.none)
keyCommentWidthPercent = input.float(defval=6.0, minval=3.0, maxval=50.0, step=0.5, title='Comment Column Width — %', tooltip='Sets the Wave Comment column width directly.', group=KEY_GROUP, display=display.none)
keyScenarioMaxCharacters = input.int(defval=42, minval=8, maxval=160, title='Scenario Maximum Characters per Line', tooltip='Reference wrap length at the opening Scenario column width and font size. The effective wrap length scales automatically when the column width or Key Font Size changes, so widening the column allows longer lines.', group=KEY_GROUP, display=display.none)
keyCommentMaxCharacters = input.int(defval=31, minval=8, maxval=160, title='Comment Maximum Characters per Line', tooltip='Reference wrap length at the opening Wave Comment column width and font size. The effective wrap length scales automatically when the column width or Key Font Size changes, so widening the column allows longer lines.', group=KEY_GROUP, display=display.none)
keyBackgroundTransparency = input.int(defval=5, minval=0, maxval=100, title='Key Background Transparency', group=KEY_GROUP, display=display.none)
keyFrameWidth = input.int(defval=1, minval=0, maxval=10, title='Key Frame Thickness', group=KEY_GROUP, display=display.none)
keyBorderWidth = input.int(defval=1, minval=0, maxval=10, title='Key Cell Border Thickness', group=KEY_GROUP, display=display.none)

// ============================================================================
// RENKO WAVE OVERLAY
// ============================================================================

const string RENKO_OVERLAY_GROUP = 'Renko Wave Overlay'

showRenkoWaveOverlay = input.bool(defval=false, title='Show Renko Wave Overlay', group=RENKO_OVERLAY_GROUP, display=display.none)
renkoOverlayUpColour = input.color(defval=color.green, title='Up-wave Line Colour', tooltip='Applies to completed and developing up-wave overlay lines.', group=RENKO_OVERLAY_GROUP, display=display.none)
renkoOverlayDownColour = input.color(defval=color.red, title='Down-wave Line Colour', tooltip='Applies to completed and developing down-wave overlay lines.', group=RENKO_OVERLAY_GROUP, display=display.none)
completedRenkoOverlayStyleInput = input.string(defval='Solid', options=['Solid', 'Dashed', 'Dotted'], title='Completed Wave Line Style', group=RENKO_OVERLAY_GROUP, display=display.none)
completedRenkoOverlayWidth = input.int(defval=2, minval=1, maxval=5, title='Completed Wave Line Width', tooltip='Thickness in pixels.', group=RENKO_OVERLAY_GROUP, display=display.none)
developingRenkoOverlayStyleInput = input.string(defval='Dashed', options=['Solid', 'Dashed', 'Dotted'], title='Developing Wave Line Style', group=RENKO_OVERLAY_GROUP, display=display.none)
developingRenkoOverlayWidth = input.int(defval=2, minval=1, maxval=5, title='Developing Wave Line Width', tooltip='Thickness in pixels.', group=RENKO_OVERLAY_GROUP, display=display.none)
developingRenkoOverlayTransparency = input.int(defval=55, minval=0, maxval=100, title='Developing Wave Transparency', tooltip='0 is fully opaque. 100 is invisible.', group=RENKO_OVERLAY_GROUP, display=display.none)

// ============================================================================
// REMOTE TRADINGVIEW RENKO STATE
// ============================================================================

// On a conventional chart the complete Weis Wave calculation runs inside
// TradingView's requested Renko context. Compact current-wave state and the four
// most recent completed-wave snapshots are returned to the chart context. Those
// snapshots drive the visible overlay, canonical pivots, statistics and comments.
// The lower pane uses the native plot.style_columns series on both conventional
// and Renko charts, so every source chart bar retains an auditable WWV column.
bool useRequestedRenkoState = showRenkoWaveOverlay and not chart.is_renko

float internalSourceEffort = useTrueRange == 'Always' or useTrueRange == 'Auto' and na(volume) ? ta.tr : volume

orderedRenkoEffort() =>
    useTrueRange == 'Always' or useTrueRange == 'Auto' and na(volume) ? ta.tr : volume

orderedRenkoAssignmentValue() =>
    float orderedAssignmentValue = methodvalue

    if methodtype == 'ATR'
        orderedAssignmentValue := ta.atr(int(math.round(methodvalue)))

    if methodtype == 'Part of Price'
        orderedAssignmentValue := close / methodvalue

    orderedAssignmentValue

string orderedRenkoStyle = methodtype == 'ATR' ? 'ATR' : methodtype == 'Part of Price' ? 'PercentageLTP' : 'Traditional'
float orderedRenkoParameter = methodtype == 'Part of Price' ? 100.0 / methodvalue : methodvalue
string orderedRenkoSource = pricesource == 'Close' ? 'Close' : 'OHLC'
bool orderedRenkoWicks = pricesource == 'High / Low'
string orderedRenkoTickerId = ticker.renko(ticker.standard(syminfo.tickerid), orderedRenkoStyle, orderedRenkoParameter, orderedRenkoWicks, orderedRenkoSource)

// The complete Weis Wave state is calculated inside TradingView's Renko context.
// Only the current state and the four most recent completed-wave snapshots cross
// the request boundary. This avoids transporting and retaining dozens of Renko bars
// for every conventional-chart bar while preserving multiple reversals that can
// occur inside one source bar.
type RemoteWaveEvent
    int serial
    int direction
    float displayedEffort
    float effort
    int boxes
    float result
    float extreme
    int extremeTime
    float extremeBoxMidpoint
    float extremeBoxSize
    float startPrice
    int startTime
    int nextDirection
    float nextDisplayedEffort
    float nextStartPrice
    int nextStartTime

type RemoteWaveEventBlock
    RemoteWaveEvent event3
    RemoteWaveEvent event2
    RemoteWaveEvent event1
    RemoteWaveEvent event0

type RemoteWaveCurrentState
    int direction
    float displayedEffort
    float effort
    int boxes
    float startPrice
    int startTime
    float extremePrice
    int extremeTime
    float extremeBoxMidpoint
    float extremeBoxSize
    int serial

type RemoteWeisState
    RemoteWaveCurrentState current
    RemoteWaveEventBlock events

getRemoteWeisState() =>
    float remoteEffort = orderedRenkoEffort()
    float remoteOpenSource = useClose ? close : open
    float remoteHighSource = useOpenClose ? close >= remoteOpenSource ? close : remoteOpenSource : high
    float remoteLowSource = useOpenClose ? close <= remoteOpenSource ? close : remoteOpenSource : low
    float remoteAssignmentValue = orderedRenkoAssignmentValue()

    float remoteAssignedClose = na
    float remotePreviousAssignedClose = nz(remoteAssignedClose[1])
    float remotePreviousHigh = remotePreviousAssignedClose + remoteAssignmentValue
    float remotePreviousLow = remotePreviousAssignedClose - remoteAssignmentValue
    remoteAssignedClose := remoteHighSource >= remotePreviousHigh ? remoteHighSource : remoteLowSource <= remotePreviousLow ? remoteLowSource : remotePreviousAssignedClose

    int remoteDirection = na
    remoteDirection := remoteAssignedClose > remotePreviousAssignedClose ? 1 : remoteAssignedClose < remotePreviousAssignedClose ? -1 : nz(remoteDirection[1])
    int remoteDirectionChange = ta.change(remoteDirection)
    bool remoteDirectionChanged = remoteDirectionChange != 0
    bool remoteDirectionUp = remoteDirection > 0
    bool remoteDirectionValid = not na(remoteDirection) and remoteDirection != 0

    int remoteNormaliseCount = 1
    remoteNormaliseCount := not remoteDirectionChanged and normalize ? remoteNormaliseCount[1] + remoteNormaliseCount : remoteNormaliseCount
    remoteEffort := not remoteDirectionChanged ? remoteEffort[1] + remoteEffort : remoteEffort
    float remoteDisplayedEffort = remoteNormaliseCount > 1 ? remoteEffort / remoteNormaliseCount : remoteEffort

    float remoteBoxTop = math.max(open, close)
    float remoteBoxBottom = math.min(open, close)
    float remoteBoxMidpoint = (remoteBoxTop + remoteBoxBottom) / 2.0
    float remoteBoxSize = math.max(math.abs(remoteBoxTop - remoteBoxBottom), syminfo.mintick)

    int remoteWaveBoxes = 0
    remoteWaveBoxes := not remoteDirectionValid ? 0 : remoteDirectionChanged or nz(remoteWaveBoxes[1]) == 0 ? 1 : remoteWaveBoxes[1] + 1

    float remoteWaveStartPrice = na
    remoteWaveStartPrice := not remoteDirectionValid ? na : remoteDirectionChanged or na(remoteWaveStartPrice[1]) ? remoteDirectionUp ? remoteBoxBottom : remoteBoxTop : remoteWaveStartPrice[1]

    int remoteWaveStartTime = na
    remoteWaveStartTime := not remoteDirectionValid ? na : remoteDirectionChanged or na(remoteWaveStartTime[1]) ? time : remoteWaveStartTime[1]

    float remoteWaveExtremePrice = na
    int remoteWaveExtremeTime = na
    float remoteWaveExtremeBoxMidpoint = na
    float remoteWaveExtremeBoxSize = na
    bool remoteNewWave = remoteDirectionValid and (remoteDirectionChanged or na(remoteWaveExtremePrice[1]))
    bool remoteNewUpExtreme = remoteDirectionValid and remoteDirectionUp and not remoteNewWave and remoteBoxTop >= remoteWaveExtremePrice[1]
    bool remoteNewDownExtreme = remoteDirectionValid and not remoteDirectionUp and not remoteNewWave and remoteBoxBottom <= remoteWaveExtremePrice[1]
    bool remoteNewExtreme = remoteNewWave or remoteNewUpExtreme or remoteNewDownExtreme
    float remoteDirectionalExtreme = remoteDirectionUp ? remoteBoxTop : remoteBoxBottom
    remoteWaveExtremePrice := not remoteDirectionValid ? na : remoteNewExtreme ? remoteDirectionalExtreme : remoteWaveExtremePrice[1]
    remoteWaveExtremeTime := not remoteDirectionValid ? na : remoteNewExtreme ? time : remoteWaveExtremeTime[1]
    remoteWaveExtremeBoxMidpoint := not remoteDirectionValid ? na : remoteNewExtreme ? remoteBoxMidpoint : remoteWaveExtremeBoxMidpoint[1]
    remoteWaveExtremeBoxSize := not remoteDirectionValid ? na : remoteNewExtreme ? remoteBoxSize : remoteWaveExtremeBoxSize[1]

    bool remoteWaveEnded = remoteDirectionChanged and bar_index > 0 and not na(remoteDirection[1]) and remoteDirection[1] != 0 and not na(remoteEffort[1]) and not na(remoteDisplayedEffort[1]) and not na(remoteWaveExtremePrice[1]) and not na(remoteWaveStartPrice[1])
    float remoteEndedResult = remoteWaveEnded ? math.abs(remoteWaveExtremePrice[1] - remoteWaveStartPrice[1]) : na
    int remoteWaveSerial = 0
    remoteWaveSerial := nz(remoteWaveSerial[1]) + (remoteWaveEnded ? 1 : 0)

    int remoteEvent0Serial = na
    remoteEvent0Serial := remoteWaveEnded ? remoteWaveSerial : remoteEvent0Serial[1]
    int remoteEvent0Direction = na
    remoteEvent0Direction := remoteWaveEnded ? remoteDirection[1] : remoteEvent0Direction[1]
    float remoteEvent0DisplayedEffort = na
    remoteEvent0DisplayedEffort := remoteWaveEnded ? remoteDisplayedEffort[1] : remoteEvent0DisplayedEffort[1]
    float remoteEvent0Effort = na
    remoteEvent0Effort := remoteWaveEnded ? remoteEffort[1] : remoteEvent0Effort[1]
    int remoteEvent0Boxes = na
    remoteEvent0Boxes := remoteWaveEnded ? remoteWaveBoxes[1] : remoteEvent0Boxes[1]
    float remoteEvent0Result = na
    remoteEvent0Result := remoteWaveEnded ? remoteEndedResult : remoteEvent0Result[1]
    float remoteEvent0Extreme = na
    remoteEvent0Extreme := remoteWaveEnded ? remoteWaveExtremePrice[1] : remoteEvent0Extreme[1]
    int remoteEvent0ExtremeTime = na
    remoteEvent0ExtremeTime := remoteWaveEnded ? remoteWaveExtremeTime[1] : remoteEvent0ExtremeTime[1]
    float remoteEvent0ExtremeBoxMidpoint = na
    remoteEvent0ExtremeBoxMidpoint := remoteWaveEnded ? remoteWaveExtremeBoxMidpoint[1] : remoteEvent0ExtremeBoxMidpoint[1]
    float remoteEvent0ExtremeBoxSize = na
    remoteEvent0ExtremeBoxSize := remoteWaveEnded ? remoteWaveExtremeBoxSize[1] : remoteEvent0ExtremeBoxSize[1]
    float remoteEvent0StartPrice = na
    remoteEvent0StartPrice := remoteWaveEnded ? remoteWaveStartPrice[1] : remoteEvent0StartPrice[1]
    int remoteEvent0StartTime = na
    remoteEvent0StartTime := remoteWaveEnded ? remoteWaveStartTime[1] : remoteEvent0StartTime[1]
    int remoteEvent0NextDirection = na
    remoteEvent0NextDirection := remoteWaveEnded ? remoteDirection : remoteEvent0NextDirection[1]
    float remoteEvent0NextDisplayedEffort = na
    remoteEvent0NextDisplayedEffort := remoteWaveEnded ? remoteDisplayedEffort : remoteEvent0NextDisplayedEffort[1]
    float remoteEvent0NextStartPrice = na
    remoteEvent0NextStartPrice := remoteWaveEnded ? remoteWaveStartPrice : remoteEvent0NextStartPrice[1]
    int remoteEvent0NextStartTime = na
    remoteEvent0NextStartTime := remoteWaveEnded ? remoteWaveStartTime : remoteEvent0NextStartTime[1]

    int remoteEvent1Serial = na
    remoteEvent1Serial := remoteWaveEnded ? remoteEvent0Serial[1] : remoteEvent1Serial[1]
    int remoteEvent1Direction = na
    remoteEvent1Direction := remoteWaveEnded ? remoteEvent0Direction[1] : remoteEvent1Direction[1]
    float remoteEvent1DisplayedEffort = na
    remoteEvent1DisplayedEffort := remoteWaveEnded ? remoteEvent0DisplayedEffort[1] : remoteEvent1DisplayedEffort[1]
    float remoteEvent1Effort = na
    remoteEvent1Effort := remoteWaveEnded ? remoteEvent0Effort[1] : remoteEvent1Effort[1]
    int remoteEvent1Boxes = na
    remoteEvent1Boxes := remoteWaveEnded ? remoteEvent0Boxes[1] : remoteEvent1Boxes[1]
    float remoteEvent1Result = na
    remoteEvent1Result := remoteWaveEnded ? remoteEvent0Result[1] : remoteEvent1Result[1]
    float remoteEvent1Extreme = na
    remoteEvent1Extreme := remoteWaveEnded ? remoteEvent0Extreme[1] : remoteEvent1Extreme[1]
    int remoteEvent1ExtremeTime = na
    remoteEvent1ExtremeTime := remoteWaveEnded ? remoteEvent0ExtremeTime[1] : remoteEvent1ExtremeTime[1]
    float remoteEvent1ExtremeBoxMidpoint = na
    remoteEvent1ExtremeBoxMidpoint := remoteWaveEnded ? remoteEvent0ExtremeBoxMidpoint[1] : remoteEvent1ExtremeBoxMidpoint[1]
    float remoteEvent1ExtremeBoxSize = na
    remoteEvent1ExtremeBoxSize := remoteWaveEnded ? remoteEvent0ExtremeBoxSize[1] : remoteEvent1ExtremeBoxSize[1]
    float remoteEvent1StartPrice = na
    remoteEvent1StartPrice := remoteWaveEnded ? remoteEvent0StartPrice[1] : remoteEvent1StartPrice[1]
    int remoteEvent1StartTime = na
    remoteEvent1StartTime := remoteWaveEnded ? remoteEvent0StartTime[1] : remoteEvent1StartTime[1]
    int remoteEvent1NextDirection = na
    remoteEvent1NextDirection := remoteWaveEnded ? remoteEvent0NextDirection[1] : remoteEvent1NextDirection[1]
    float remoteEvent1NextDisplayedEffort = na
    remoteEvent1NextDisplayedEffort := remoteWaveEnded ? remoteEvent0NextDisplayedEffort[1] : remoteEvent1NextDisplayedEffort[1]
    float remoteEvent1NextStartPrice = na
    remoteEvent1NextStartPrice := remoteWaveEnded ? remoteEvent0NextStartPrice[1] : remoteEvent1NextStartPrice[1]
    int remoteEvent1NextStartTime = na
    remoteEvent1NextStartTime := remoteWaveEnded ? remoteEvent0NextStartTime[1] : remoteEvent1NextStartTime[1]

    int remoteEvent2Serial = na
    remoteEvent2Serial := remoteWaveEnded ? remoteEvent1Serial[1] : remoteEvent2Serial[1]
    int remoteEvent2Direction = na
    remoteEvent2Direction := remoteWaveEnded ? remoteEvent1Direction[1] : remoteEvent2Direction[1]
    float remoteEvent2DisplayedEffort = na
    remoteEvent2DisplayedEffort := remoteWaveEnded ? remoteEvent1DisplayedEffort[1] : remoteEvent2DisplayedEffort[1]
    float remoteEvent2Effort = na
    remoteEvent2Effort := remoteWaveEnded ? remoteEvent1Effort[1] : remoteEvent2Effort[1]
    int remoteEvent2Boxes = na
    remoteEvent2Boxes := remoteWaveEnded ? remoteEvent1Boxes[1] : remoteEvent2Boxes[1]
    float remoteEvent2Result = na
    remoteEvent2Result := remoteWaveEnded ? remoteEvent1Result[1] : remoteEvent2Result[1]
    float remoteEvent2Extreme = na
    remoteEvent2Extreme := remoteWaveEnded ? remoteEvent1Extreme[1] : remoteEvent2Extreme[1]
    int remoteEvent2ExtremeTime = na
    remoteEvent2ExtremeTime := remoteWaveEnded ? remoteEvent1ExtremeTime[1] : remoteEvent2ExtremeTime[1]
    float remoteEvent2ExtremeBoxMidpoint = na
    remoteEvent2ExtremeBoxMidpoint := remoteWaveEnded ? remoteEvent1ExtremeBoxMidpoint[1] : remoteEvent2ExtremeBoxMidpoint[1]
    float remoteEvent2ExtremeBoxSize = na
    remoteEvent2ExtremeBoxSize := remoteWaveEnded ? remoteEvent1ExtremeBoxSize[1] : remoteEvent2ExtremeBoxSize[1]
    float remoteEvent2StartPrice = na
    remoteEvent2StartPrice := remoteWaveEnded ? remoteEvent1StartPrice[1] : remoteEvent2StartPrice[1]
    int remoteEvent2StartTime = na
    remoteEvent2StartTime := remoteWaveEnded ? remoteEvent1StartTime[1] : remoteEvent2StartTime[1]
    int remoteEvent2NextDirection = na
    remoteEvent2NextDirection := remoteWaveEnded ? remoteEvent1NextDirection[1] : remoteEvent2NextDirection[1]
    float remoteEvent2NextDisplayedEffort = na
    remoteEvent2NextDisplayedEffort := remoteWaveEnded ? remoteEvent1NextDisplayedEffort[1] : remoteEvent2NextDisplayedEffort[1]
    float remoteEvent2NextStartPrice = na
    remoteEvent2NextStartPrice := remoteWaveEnded ? remoteEvent1NextStartPrice[1] : remoteEvent2NextStartPrice[1]
    int remoteEvent2NextStartTime = na
    remoteEvent2NextStartTime := remoteWaveEnded ? remoteEvent1NextStartTime[1] : remoteEvent2NextStartTime[1]

    int remoteEvent3Serial = na
    remoteEvent3Serial := remoteWaveEnded ? remoteEvent2Serial[1] : remoteEvent3Serial[1]
    int remoteEvent3Direction = na
    remoteEvent3Direction := remoteWaveEnded ? remoteEvent2Direction[1] : remoteEvent3Direction[1]
    float remoteEvent3DisplayedEffort = na
    remoteEvent3DisplayedEffort := remoteWaveEnded ? remoteEvent2DisplayedEffort[1] : remoteEvent3DisplayedEffort[1]
    float remoteEvent3Effort = na
    remoteEvent3Effort := remoteWaveEnded ? remoteEvent2Effort[1] : remoteEvent3Effort[1]
    int remoteEvent3Boxes = na
    remoteEvent3Boxes := remoteWaveEnded ? remoteEvent2Boxes[1] : remoteEvent3Boxes[1]
    float remoteEvent3Result = na
    remoteEvent3Result := remoteWaveEnded ? remoteEvent2Result[1] : remoteEvent3Result[1]
    float remoteEvent3Extreme = na
    remoteEvent3Extreme := remoteWaveEnded ? remoteEvent2Extreme[1] : remoteEvent3Extreme[1]
    int remoteEvent3ExtremeTime = na
    remoteEvent3ExtremeTime := remoteWaveEnded ? remoteEvent2ExtremeTime[1] : remoteEvent3ExtremeTime[1]
    float remoteEvent3ExtremeBoxMidpoint = na
    remoteEvent3ExtremeBoxMidpoint := remoteWaveEnded ? remoteEvent2ExtremeBoxMidpoint[1] : remoteEvent3ExtremeBoxMidpoint[1]
    float remoteEvent3ExtremeBoxSize = na
    remoteEvent3ExtremeBoxSize := remoteWaveEnded ? remoteEvent2ExtremeBoxSize[1] : remoteEvent3ExtremeBoxSize[1]
    float remoteEvent3StartPrice = na
    remoteEvent3StartPrice := remoteWaveEnded ? remoteEvent2StartPrice[1] : remoteEvent3StartPrice[1]
    int remoteEvent3StartTime = na
    remoteEvent3StartTime := remoteWaveEnded ? remoteEvent2StartTime[1] : remoteEvent3StartTime[1]
    int remoteEvent3NextDirection = na
    remoteEvent3NextDirection := remoteWaveEnded ? remoteEvent2NextDirection[1] : remoteEvent3NextDirection[1]
    float remoteEvent3NextDisplayedEffort = na
    remoteEvent3NextDisplayedEffort := remoteWaveEnded ? remoteEvent2NextDisplayedEffort[1] : remoteEvent3NextDisplayedEffort[1]
    float remoteEvent3NextStartPrice = na
    remoteEvent3NextStartPrice := remoteWaveEnded ? remoteEvent2NextStartPrice[1] : remoteEvent3NextStartPrice[1]
    int remoteEvent3NextStartTime = na
    remoteEvent3NextStartTime := remoteWaveEnded ? remoteEvent2NextStartTime[1] : remoteEvent3NextStartTime[1]

    RemoteWaveCurrentState remoteCurrent = RemoteWaveCurrentState.new(remoteDirection, remoteDisplayedEffort, remoteEffort, remoteWaveBoxes, remoteWaveStartPrice, remoteWaveStartTime, remoteWaveExtremePrice, remoteWaveExtremeTime, remoteWaveExtremeBoxMidpoint, remoteWaveExtremeBoxSize, remoteWaveSerial)
    RemoteWaveEventBlock remoteEvents = RemoteWaveEventBlock.new(RemoteWaveEvent.new(remoteEvent3Serial, remoteEvent3Direction, remoteEvent3DisplayedEffort, remoteEvent3Effort, remoteEvent3Boxes, remoteEvent3Result, remoteEvent3Extreme, remoteEvent3ExtremeTime, remoteEvent3ExtremeBoxMidpoint, remoteEvent3ExtremeBoxSize, remoteEvent3StartPrice, remoteEvent3StartTime, remoteEvent3NextDirection, remoteEvent3NextDisplayedEffort, remoteEvent3NextStartPrice, remoteEvent3NextStartTime), RemoteWaveEvent.new(remoteEvent2Serial, remoteEvent2Direction, remoteEvent2DisplayedEffort, remoteEvent2Effort, remoteEvent2Boxes, remoteEvent2Result, remoteEvent2Extreme, remoteEvent2ExtremeTime, remoteEvent2ExtremeBoxMidpoint, remoteEvent2ExtremeBoxSize, remoteEvent2StartPrice, remoteEvent2StartTime, remoteEvent2NextDirection, remoteEvent2NextDisplayedEffort, remoteEvent2NextStartPrice, remoteEvent2NextStartTime), RemoteWaveEvent.new(remoteEvent1Serial, remoteEvent1Direction, remoteEvent1DisplayedEffort, remoteEvent1Effort, remoteEvent1Boxes, remoteEvent1Result, remoteEvent1Extreme, remoteEvent1ExtremeTime, remoteEvent1ExtremeBoxMidpoint, remoteEvent1ExtremeBoxSize, remoteEvent1StartPrice, remoteEvent1StartTime, remoteEvent1NextDirection, remoteEvent1NextDisplayedEffort, remoteEvent1NextStartPrice, remoteEvent1NextStartTime), RemoteWaveEvent.new(remoteEvent0Serial, remoteEvent0Direction, remoteEvent0DisplayedEffort, remoteEvent0Effort, remoteEvent0Boxes, remoteEvent0Result, remoteEvent0Extreme, remoteEvent0ExtremeTime, remoteEvent0ExtremeBoxMidpoint, remoteEvent0ExtremeBoxSize, remoteEvent0StartPrice, remoteEvent0StartTime, remoteEvent0NextDirection, remoteEvent0NextDisplayedEffort, remoteEvent0NextStartPrice, remoteEvent0NextStartTime))
    RemoteWeisState.new(remoteCurrent, remoteEvents)

RemoteWaveEvent emptyRemoteWaveEvent = RemoteWaveEvent.new(na, 0, na, na, 0, na, na, na, na, na, na, na, 0, na, na, na)
RemoteWaveCurrentState emptyRemoteWaveCurrent = RemoteWaveCurrentState.new(0, na, na, 0, na, na, na, na, na, na, 0)
RemoteWaveEventBlock emptyRemoteWaveEvents = RemoteWaveEventBlock.new(emptyRemoteWaveEvent, emptyRemoteWaveEvent, emptyRemoteWaveEvent, emptyRemoteWaveEvent)
RemoteWeisState remoteWeisState = request.security(orderedRenkoTickerId, timeframe.period, getRemoteWeisState(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
if na(remoteWeisState)
    remoteWeisState := RemoteWeisState.new(emptyRemoteWaveCurrent, emptyRemoteWaveEvents)

RemoteWaveCurrentState remoteCurrentState = remoteWeisState.current
RemoteWaveEventBlock remoteCompletedWaveEvents = remoteWeisState.events


// Conventional-chart source-bar registry. Remote Renko timestamps are mapped to
// actual source-bar coordinates before any overlay, statistic or histogram object
// is drawn. This prevents session gaps, bank holidays and weekly start-date shifts
// from displacing completed Renko events on a conventional chart.
var array<int> requestedSourceBarTimes = array.new<int>()
var array<int> requestedSourceBarIndexes = array.new<int>()

mapRequestedTimeToSourceTime(int targetTime) =>
    int mappedTime = targetTime
    int sourceBarCount = array.size(requestedSourceBarTimes)

    if not na(targetTime) and sourceBarCount > 0
        int exactPosition = array.indexof(requestedSourceBarTimes, targetTime)

        if exactPosition >= 0
            mappedTime := array.get(requestedSourceBarTimes, exactPosition)
        else
            int nearestPosition = 0
            int nearestDistance = math.abs(array.get(requestedSourceBarTimes, 0) - targetTime)

            if sourceBarCount > 1
                for sourcePosition = 1 to sourceBarCount - 1
                    int candidateDistance = math.abs(array.get(requestedSourceBarTimes, sourcePosition) - targetTime)

                    if candidateDistance < nearestDistance
                        nearestDistance := candidateDistance
                        nearestPosition := sourcePosition

            mappedTime := array.get(requestedSourceBarTimes, nearestPosition)

    mappedTime

mapRequestedTimeToSourceBar(int targetTime) =>
    int mappedBar = bar_index
    int sourceBarCount = array.size(requestedSourceBarTimes)

    if not na(targetTime) and sourceBarCount > 0
        int exactPosition = array.indexof(requestedSourceBarTimes, targetTime)

        if exactPosition >= 0
            mappedBar := array.get(requestedSourceBarIndexes, exactPosition)
        else
            int nearestPosition = 0
            int nearestDistance = math.abs(array.get(requestedSourceBarTimes, 0) - targetTime)

            if sourceBarCount > 1
                for sourcePosition = 1 to sourceBarCount - 1
                    int candidateDistance = math.abs(array.get(requestedSourceBarTimes, sourcePosition) - targetTime)

                    if candidateDistance < nearestDistance
                        nearestDistance := candidateDistance
                        nearestPosition := sourcePosition

            mappedBar := array.get(requestedSourceBarIndexes, nearestPosition)

    mappedBar

getSourceSlotHalfWidth(int centreTime) =>
    int nominalSpan = math.max(int(timeframe.in_seconds(timeframe.period) * 1000.0), 1)
    int slotSpan = nominalSpan
    int sourceBarCount = array.size(requestedSourceBarTimes)
    int sourcePosition = not na(centreTime) ? array.indexof(requestedSourceBarTimes, centreTime) : -1

    if sourcePosition >= 0
        int previousGap = sourcePosition > 0 ? centreTime - array.get(requestedSourceBarTimes, sourcePosition - 1) : na
        int nextGap = sourcePosition < sourceBarCount - 1 ? array.get(requestedSourceBarTimes, sourcePosition + 1) - centreTime : na
        bool previousGapValid = not na(previousGap) and previousGap > 0
        bool nextGapValid = not na(nextGap) and nextGap > 0
        slotSpan := previousGapValid and nextGapValid ? math.min(previousGap, nextGap) : previousGapValid ? math.min(previousGap, nominalSpan) : nextGapValid ? math.min(nextGap, nominalSpan) : nominalSpan

    math.max(int(math.floor(float(slotSpan) * 0.46)), 1)

if array.size(requestedSourceBarTimes) == 0 or array.get(requestedSourceBarTimes, array.size(requestedSourceBarTimes) - 1) != time
    array.push(requestedSourceBarTimes, time)
    array.push(requestedSourceBarIndexes, bar_index)

    if array.size(requestedSourceBarTimes) > 500
        array.shift(requestedSourceBarTimes)
        array.shift(requestedSourceBarIndexes)

// Existing event arrays are retained as the chart-context interface used by the
// overlay, statistics and comments. Remote completed events are appended oldest
// to newest, followed by the current wave snapshot.
array<int> requestedEventDirections = array.new<int>()
array<float> requestedEventValues = array.new<float>()
array<int> requestedEventWaveSerials = array.new<int>()
array<int> requestedEventLastEndedDirections = array.new<int>()
array<float> requestedEventLastEndedExtremes = array.new<float>()
array<int> requestedEventLastEndedExtremeTimes = array.new<int>()
array<float> requestedEventLastEndedStartPrices = array.new<float>()
array<int> requestedEventLastEndedStartTimes = array.new<int>()
array<float> requestedEventWaveStartPrices = array.new<float>()
array<int> requestedEventWaveStartTimes = array.new<int>()
array<int> requestedCompletedEventSerials = array.new<int>()
array<int> requestedCompletedEventDirections = array.new<int>()
array<float> requestedCompletedEventValues = array.new<float>()
array<int> requestedCompletedEventBoxes = array.new<int>()
array<float> requestedCompletedEventExtremes = array.new<float>()
array<int> requestedCompletedEventExtremeTimes = array.new<int>()
array<float> requestedCompletedEventExtremeBoxMidpoints = array.new<float>()
array<float> requestedCompletedEventExtremeBoxSizes = array.new<float>()

var bool requestedRemoteStateInitialised = false
var int requestedProcessedRemoteWaveSerial = 0
var int requestedMappedWaveStartTime = na
var int requestedMappedWaveStartBar = na
var int requestedMappedWaveExtremeTime = na
var int requestedMappedWaveExtremeBar = na

int previousMappedWaveStartTime = requestedMappedWaveStartTime
int previousMappedWaveStartBar = requestedMappedWaveStartBar
int previousMappedWaveExtremeTime = requestedMappedWaveExtremeTime
int previousMappedWaveExtremeBar = requestedMappedWaveExtremeBar
bool requestedWaveEndedThisBar = false
int newestRequestedEventExtremeBar = na
int newestRequestedEventStartBar = na

if useRequestedRenkoState
    if not requestedRemoteStateInitialised
        requestedProcessedRemoteWaveSerial := math.max(remoteCurrentState.serial - 4, 0)
        requestedRemoteStateInitialised := true

    array<RemoteWaveEvent> remoteEventQueue = array.from(remoteCompletedWaveEvents.event3, remoteCompletedWaveEvents.event2, remoteCompletedWaveEvents.event1, remoteCompletedWaveEvents.event0)

    for remoteEvent in remoteEventQueue
        if not na(remoteEvent.serial) and remoteEvent.serial > requestedProcessedRemoteWaveSerial
            int eventExtremeBar = mapRequestedTimeToSourceBar(remoteEvent.extremeTime)
            int eventStartBar = mapRequestedTimeToSourceBar(remoteEvent.startTime)
            array.push(requestedEventDirections, remoteEvent.nextDirection)
            array.push(requestedEventValues, remoteEvent.nextDisplayedEffort)
            array.push(requestedEventWaveSerials, remoteEvent.serial)
            array.push(requestedEventLastEndedDirections, remoteEvent.direction)
            array.push(requestedEventLastEndedExtremes, remoteEvent.extreme)
            array.push(requestedEventLastEndedExtremeTimes, remoteEvent.extremeTime)
            array.push(requestedEventLastEndedStartPrices, remoteEvent.startPrice)
            array.push(requestedEventLastEndedStartTimes, remoteEvent.startTime)
            array.push(requestedEventWaveStartPrices, remoteEvent.nextStartPrice)
            array.push(requestedEventWaveStartTimes, remoteEvent.nextStartTime)
            array.push(requestedCompletedEventSerials, remoteEvent.serial)
            array.push(requestedCompletedEventDirections, remoteEvent.direction)
            array.push(requestedCompletedEventValues, remoteEvent.displayedEffort)
            array.push(requestedCompletedEventBoxes, remoteEvent.boxes)
            array.push(requestedCompletedEventExtremes, remoteEvent.extreme)
            array.push(requestedCompletedEventExtremeTimes, remoteEvent.extremeTime)
            array.push(requestedCompletedEventExtremeBoxMidpoints, remoteEvent.extremeBoxMidpoint)
            array.push(requestedCompletedEventExtremeBoxSizes, remoteEvent.extremeBoxSize)
            newestRequestedEventExtremeBar := eventExtremeBar
            newestRequestedEventStartBar := eventStartBar
            requestedProcessedRemoteWaveSerial := remoteEvent.serial
            requestedWaveEndedThisBar := true

    RemoteWaveEvent latestQueueCompletedEvent = remoteCompletedWaveEvents.event0
    if remoteCurrentState.direction != 0 and not na(remoteCurrentState.displayedEffort)
        array.push(requestedEventDirections, remoteCurrentState.direction)
        array.push(requestedEventValues, remoteCurrentState.displayedEffort)
        array.push(requestedEventWaveSerials, remoteCurrentState.serial)
        array.push(requestedEventLastEndedDirections, latestQueueCompletedEvent.direction)
        array.push(requestedEventLastEndedExtremes, latestQueueCompletedEvent.extreme)
        array.push(requestedEventLastEndedExtremeTimes, latestQueueCompletedEvent.extremeTime)
        array.push(requestedEventLastEndedStartPrices, latestQueueCompletedEvent.startPrice)
        array.push(requestedEventLastEndedStartTimes, latestQueueCompletedEvent.startTime)
        array.push(requestedEventWaveStartPrices, remoteCurrentState.startPrice)
        array.push(requestedEventWaveStartTimes, remoteCurrentState.startTime)

    if na(requestedMappedWaveStartTime) or remoteCurrentState.startTime != requestedMappedWaveStartTime
        requestedMappedWaveStartTime := remoteCurrentState.startTime
        requestedMappedWaveStartBar := mapRequestedTimeToSourceBar(remoteCurrentState.startTime)

    if na(requestedMappedWaveExtremeTime) or remoteCurrentState.extremeTime != requestedMappedWaveExtremeTime
        requestedMappedWaveExtremeTime := remoteCurrentState.extremeTime
        requestedMappedWaveExtremeBar := mapRequestedTimeToSourceBar(remoteCurrentState.extremeTime)
else
    requestedRemoteStateInitialised := false
    requestedProcessedRemoteWaveSerial := 0
    requestedMappedWaveStartTime := na
    requestedMappedWaveStartBar := na
    requestedMappedWaveExtremeTime := na
    requestedMappedWaveExtremeBar := na

RemoteWaveEvent latestRemoteCompletedEvent = remoteCompletedWaveEvents.event0
float requestedVol = useRequestedRenkoState ? remoteCurrentState.effort : na
float requestedRes = useRequestedRenkoState ? remoteCurrentState.displayedEffort : na
int requestedDirection = useRequestedRenkoState ? remoteCurrentState.direction : 0
int requestedWaveBoxCount = useRequestedRenkoState ? remoteCurrentState.boxes : 0
float requestedWaveStartPrice = useRequestedRenkoState ? remoteCurrentState.startPrice : na
int requestedWaveStartTime = useRequestedRenkoState ? remoteCurrentState.startTime : na
int requestedWaveStartBarValue = useRequestedRenkoState ? requestedMappedWaveStartBar : na
float requestedWaveExtremePrice = useRequestedRenkoState ? remoteCurrentState.extremePrice : na
int requestedWaveExtremeTime = useRequestedRenkoState ? remoteCurrentState.extremeTime : na
int requestedWaveExtremeBarValue = useRequestedRenkoState ? requestedMappedWaveExtremeBar : na
float requestedWaveExtremeBoxMidpoint = useRequestedRenkoState ? remoteCurrentState.extremeBoxMidpoint : na
float requestedWaveExtremeBoxSize = useRequestedRenkoState ? remoteCurrentState.extremeBoxSize : na
float requestedWavePriceResult = useRequestedRenkoState and not na(remoteCurrentState.startPrice) and not na(remoteCurrentState.extremePrice) ? math.abs(remoteCurrentState.extremePrice - remoteCurrentState.startPrice) : na
int requestedWaveSerial = useRequestedRenkoState ? remoteCurrentState.serial : 0
int requestedLastEndedDirection = useRequestedRenkoState ? latestRemoteCompletedEvent.direction : 0
float requestedLastEndedDisplayedEffort = useRequestedRenkoState ? latestRemoteCompletedEvent.displayedEffort : na
float requestedLastEndedEffort = useRequestedRenkoState ? latestRemoteCompletedEvent.effort : na
int requestedLastEndedBoxes = useRequestedRenkoState ? latestRemoteCompletedEvent.boxes : 0
float requestedLastEndedResult = useRequestedRenkoState ? latestRemoteCompletedEvent.result : na
float requestedLastEndedExtreme = useRequestedRenkoState ? latestRemoteCompletedEvent.extreme : na
int requestedLastEndedExtremeTime = useRequestedRenkoState ? latestRemoteCompletedEvent.extremeTime : na
int requestedLastEndedExtremeBarValue = useRequestedRenkoState ? newestRequestedEventExtremeBar : na
float requestedLastEndedExtremeBoxMidpoint = useRequestedRenkoState ? latestRemoteCompletedEvent.extremeBoxMidpoint : na
float requestedLastEndedExtremeBoxSize = useRequestedRenkoState ? latestRemoteCompletedEvent.extremeBoxSize : na
float requestedLastEndedStartPrice = useRequestedRenkoState ? latestRemoteCompletedEvent.startPrice : na
int requestedLastEndedStartTime = useRequestedRenkoState ? latestRemoteCompletedEvent.startTime : na
int requestedLastEndedStartBarValue = useRequestedRenkoState ? newestRequestedEventStartBar : na


// ============================================================================
// ORIGINAL WEIS WAVE CALCULATION
// ============================================================================

vol = useTrueRange == 'Always' or useTrueRange == 'Auto' and na(volume) ? ta.tr : volume
op = useClose ? close : open
hi = useOpenClose ? close >= op ? close : op : high
lo = useOpenClose ? close <= op ? close : op : low

float assignmentValue = methodvalue

if methodtype == 'ATR'
    assignmentValue := ta.atr(int(math.round(methodvalue)))

if methodtype == 'Part of Price'
    assignmentValue := close / methodvalue

currclose = float(na)
prevclose = nz(currclose[1])
prevhigh = prevclose + assignmentValue
prevlow = prevclose - assignmentValue
currclose := hi >= prevhigh ? hi : lo <= prevlow ? lo : prevclose

direction = int(na)
direction := currclose > prevclose ? 1 : currclose < prevclose ? -1 : nz(direction[1])
directionHasChanged = ta.change(direction) != 0
directionIsUp = direction > 0
directionIsDown = direction < 0

barcount = 1
barcount := not directionHasChanged and normalize ? barcount[1] + barcount : barcount
vol := not directionHasChanged ? vol[1] + vol : vol
res = barcount > 1 ? vol / barcount : vol

if useRequestedRenkoState
    vol := requestedVol
    res := requestedRes
    direction := requestedDirection
    directionHasChanged := requestedWaveEndedThisBar
    directionIsUp := direction > 0
    directionIsDown := direction < 0

// The native plot.style_columns histogram is the single lower-pane renderer on
// both conventional price charts and native Renko charts. On a conventional chart
// each WWV value is centred on its source price bar, uses TradingView's normal
// column-slot width and remains identical to the Wave Volume Data Window/CSV series.
// Completed-wave statistics labels remain authoritative for final Renko-wave totals.
color waveVolumePlotColour = directionIsUp ? color.new(upWaveHistogramColour, upWaveHistogramTransparency) : color.new(downWaveHistogramColour, downWaveHistogramTransparency)
plot(isOscillating and directionIsDown ? -res : res, style=plot.style_columns, color=waveVolumePlotColour, linewidth=3, title='Wave Volume')

// ============================================================================
// CONVENTIONAL-CHART WWV HISTOGRAM
// ============================================================================

// No box-based replacement renderer is used. The Wave Volume plot above supplies
// one continuous native column for every conventional source bar. This removes the
// sparse/missing-column and overlapping-colour artefacts created by retrospective
// box replacement. A completed Renko pivot can fall at a source-bar boundary rather
// than at the visual centre of the sampled WWV column; that is the accepted trade-off
// for a complete histogram that exactly matches Data Window and CSV output.

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

formatNumber(float value, int places) => str.tostring(value, places == 0 ? '#' : places == 1 ? '#.0' : places == 2 ? '#.00' : places == 3 ? '#.000' : '#.0000')
getVolumeSuffix(float divisor) => divisor == 1000000000.0 ? 'B' : divisor == 1000000.0 ? 'M' : divisor == 1000.0 ? 'K' : ''
formatVolume(float value) => formatNumber(value / volumeDivisor, decimalPlaces) + getVolumeSuffix(volumeDivisor)
percentChange(float currentValue, float previousValue) => na(previousValue) or previousValue == 0.0 ? na : (currentValue / previousValue - 1.0) * 100.0
compareState(float changeValue, float threshold) => na(changeValue) ? 0 : changeValue >= threshold ? 1 : changeValue <= -threshold ? -1 : 0
getRenkoOverlayLineStyle(string selectedStyle) => selectedStyle == 'Dashed' ? line.style_dashed : selectedStyle == 'Dotted' ? line.style_dotted : line.style_solid

findRequestedPivotOffset(bool upWave, float pivotPrice, int waveStartTime) =>
    int foundOffset = na
    int maximumOffset = math.min(bar_index, 5000)
    float tolerance = syminfo.mintick * 0.5

    if not na(pivotPrice)
        for offset = 0 to maximumOffset
            bool withinWave = na(waveStartTime) or time_close[offset] > waveStartTime

            if not withinWave
                break

            float sourceUpper = pricesource == 'Close' ? close[offset] : pricesource == 'Open / Close' ? math.max(open[offset], close[offset]) : high[offset]
            float sourceLower = pricesource == 'Close' ? close[offset] : pricesource == 'Open / Close' ? math.min(open[offset], close[offset]) : low[offset]
            bool pivotReached = upWave ? sourceUpper >= pivotPrice - tolerance : sourceLower <= pivotPrice + tolerance

            if pivotReached
                foundOffset := offset

    foundOffset

getTablePosition(string selectedPosition) =>
    switch selectedPosition
        'Top Left' => position.top_left
        'Top Centre' => position.top_center
        'Top Right' => position.top_right
        'Middle Left' => position.middle_left
        'Middle Centre' => position.middle_center
        'Middle Right' => position.middle_right
        'Bottom Left' => position.bottom_left
        'Bottom Centre' => position.bottom_center
        'Bottom Right' => position.bottom_right
        => position.top_left

getTableColumn(string selectedPosition) =>
    selectedPosition == 'Top Left' or selectedPosition == 'Middle Left' or selectedPosition == 'Bottom Left' ? 0 : selectedPosition == 'Top Centre' or selectedPosition == 'Middle Centre' or selectedPosition == 'Bottom Centre' ? 1 : 2

isTopTablePosition(string selectedPosition) => selectedPosition == 'Top Left' or selectedPosition == 'Top Centre' or selectedPosition == 'Top Right'
isBottomTablePosition(string selectedPosition) => selectedPosition == 'Bottom Left' or selectedPosition == 'Bottom Centre' or selectedPosition == 'Bottom Right'

wrapText(string sourceText, int maximumCharacters) =>
    string cleanedText = str.replace_all(sourceText, '\n', ' ')
    array<string> words = str.split(cleanedText, ' ')
    string currentLine = ''
    string wrappedText = ''
    int wordCount = array.size(words)

    if wordCount > 0
        for wordIndex = 0 to wordCount - 1
            string word = array.get(words, wordIndex)
            string candidateLine = currentLine == '' ? word : currentLine + ' ' + word

            if str.length(candidateLine) > maximumCharacters and currentLine != ''
                wrappedText := wrappedText + (wrappedText == '' ? '' : '\n') + currentLine
                currentLine := word
            else
                currentLine := candidateLine

        wrappedText := wrappedText + (wrappedText == '' ? '' : '\n') + currentLine

    wrappedText

scaledWrapCharacters(int referenceCharacters, float currentWidthPercent, float referenceWidthPercent, int currentFontSize, int referenceFontSize) =>
    float widthScale = currentWidthPercent / referenceWidthPercent
    float fontScale = float(referenceFontSize) / math.max(float(currentFontSize), 1.0)
    int scaledCharacters = int(math.round(referenceCharacters * widthScale * fontScale))
    math.max(8, math.min(160, scaledCharacters))

composeComment(string conclusion, string primaryComment, string explanation, int maximumCharacters) =>
    string outputText = ''

    if conclusion != ''
        outputText := wrapText(conclusion, maximumCharacters)

    if primaryComment != ''
        outputText := outputText + (outputText == '' ? '' : '\n\n') + wrapText(primaryComment, maximumCharacters)

    if explanation != ''
        outputText := outputText + (outputText == '' ? '' : '\n\n') + wrapText(explanation, maximumCharacters)

    outputText

getStatisticsDistanceUnit(float boxSize) => verticalDistanceUnit == 'Ticks' ? syminfo.mintick : verticalDistanceUnit == 'Price Units' ? 1.0 : math.max(boxSize, syminfo.mintick)
getCalloutDistanceUnit(float boxSize) => calloutDistanceUnit == 'Ticks' ? syminfo.mintick : calloutDistanceUnit == 'Price Units' ? 1.0 : math.max(boxSize, syminfo.mintick)

getStatsY(bool upWave, float extremePrice, float boxSize) =>
    float selectedDistance = upWave ? peakDistance : troughDistance
    string selectedPlacement = upWave ? peakPlacement : troughPlacement
    float offsetValue = selectedDistance * getStatisticsDistanceUnit(boxSize)
    selectedPlacement == 'Above' ? extremePrice + offsetValue : extremePrice - offsetValue

getTextLineCount(string textValue) =>
    array<string> textLines = str.split(textValue, '\n')
    math.max(array.size(textLines), 1)

getLongestTextLineLength(string textValue) =>
    array<string> textLines = str.split(textValue, '\n')
    int longestLineLength = 0

    for textLine in textLines
        longestLineLength := math.max(longestLineLength, str.length(textLine))

    math.max(longestLineLength, 1)

getEstimatedTextHalfHeight(string textValue, int fontSize, float separationBasis) =>
    float lineCount = float(getTextLineCount(textValue))
    float fontScale = math.max(float(fontSize), 1.0) / 12.0
    separationBasis * lineCount * fontScale / 16.0

getEstimatedTextHalfWidthBars(string textValue, int fontSize, int referenceCharacters, int referenceDistanceBars, bool boldText, bool monospacedText) =>
    float longestLineCharacters = float(getLongestTextLineLength(textValue))
    float characterScale = longestLineCharacters / math.max(float(referenceCharacters), 1.0)
    float fontScale = math.max(float(fontSize), 1.0) / 12.0
    float boldScale = boldText ? 1.08 : 1.0
    float typefaceScale = monospacedText ? 1.05 : 1.0
    float estimatedFullWidthBars = math.max(float(referenceDistanceBars), 1.0) * math.max(characterScale, 0.35) * fontScale * boldScale * typefaceScale
    estimatedFullWidthBars / 2.0

horizontalRangesOverlap(int currentAnchorBar, float currentHalfWidthBars, int previousAnchorBar, float previousHalfWidthBars, int referenceDistanceBars) =>
    float horizontalClearanceBars = math.max(1.0, float(referenceDistanceBars) * 0.04)
    float currentLeft = float(currentAnchorBar) - currentHalfWidthBars
    float currentRight = float(currentAnchorBar) + currentHalfWidthBars
    float previousLeft = float(previousAnchorBar) - previousHalfWidthBars
    float previousRight = float(previousAnchorBar) + previousHalfWidthBars
    currentLeft <= previousRight + horizontalClearanceBars and currentRight >= previousLeft - horizontalClearanceBars

getCalloutBaseY(bool upWave, float extremePrice, float boxSize, bool statisticsVisible, float statisticsY, string statisticsText, string calloutText, float separationBasis) =>
    float referenceY = statisticsVisible and not na(statisticsY) ? statisticsY : extremePrice
    float gapValue = (upWave ? upCalloutGap : downCalloutGap) * getCalloutDistanceUnit(boxSize)
    float requiredCenterDistance = gapValue

    if statisticsVisible and not na(statisticsY)
        float calloutHalfHeight = getEstimatedTextHalfHeight(calloutText, calloutFontSize, separationBasis)
        float statisticsHalfHeight = getEstimatedTextHalfHeight(statisticsText, labelFontSize, separationBasis)
        float automaticDaylight = separationBasis * 0.10
        requiredCenterDistance := math.max(gapValue, calloutHalfHeight + statisticsHalfHeight + automaticDaylight)

    upWave ? math.max(extremePrice, referenceY) + requiredCenterDistance : math.min(extremePrice, referenceY) - requiredCenterDistance

getStatsStackingSeparation(float boxSize, float referencePrice) => statsStackingDistanceUnit == 'Percentage of Price' ? math.abs(referencePrice) * minimumStatsVerticalSeparation / 100.0 : statsStackingDistanceUnit == 'Renko Boxes' ? minimumStatsVerticalSeparation * math.max(boxSize, syminfo.mintick) : minimumStatsVerticalSeparation

getStackedStatsPosition(bool placeAbove, float normalY, float boxSize, float referencePrice, int anchorBar, int previousAnchorBar, label previousStatsLabel, string currentText) =>
    float stackedY = normalY
    bool hasPreviousLabel = enableAdjacentStatsStacking and not na(previousAnchorBar) and not na(previousStatsLabel)

    if hasPreviousLabel
        string previousText = label.get_text(previousStatsLabel)
        float currentHalfWidthBars = getEstimatedTextHalfWidthBars(currentText, labelFontSize, 10, adjacentStatsDistanceBars, boldWaveStatisticsText, statisticsTypeface == 'Monospaced')
        float previousHalfWidthBars = getEstimatedTextHalfWidthBars(previousText, labelFontSize, 10, adjacentStatsDistanceBars, boldWaveStatisticsText, statisticsTypeface == 'Monospaced')
        bool horizontalCollision = horizontalRangesOverlap(anchorBar, currentHalfWidthBars, previousAnchorBar, previousHalfWidthBars, adjacentStatsDistanceBars)

        if horizontalCollision
            float requestedEdgeSeparation = getStatsStackingSeparation(boxSize, referencePrice)
            float previousY = label.get_y(previousStatsLabel)
            float currentHalfHeight = getEstimatedTextHalfHeight(currentText, labelFontSize, requestedEdgeSeparation)
            float previousHalfHeight = getEstimatedTextHalfHeight(previousText, labelFontSize, requestedEdgeSeparation)
            float currentTop = normalY + currentHalfHeight
            float currentBottom = normalY - currentHalfHeight
            float previousTop = previousY + previousHalfHeight
            float previousBottom = previousY - previousHalfHeight
            bool verticalClearanceExists = currentBottom >= previousTop + requestedEdgeSeparation or currentTop <= previousBottom - requestedEdgeSeparation

            if not verticalClearanceExists
                float outwardTargetY = placeAbove ? previousTop + requestedEdgeSeparation + currentHalfHeight : previousBottom - requestedEdgeSeparation - currentHalfHeight
                stackedY := placeAbove ? math.max(normalY, outwardTargetY) : math.min(normalY, outwardTargetY)

    stackedY

getStackingSeparation(float boxSize, float referencePrice) => stackingDistanceUnit == 'Percentage of Price' ? math.abs(referencePrice) * minimumVerticalSeparation / 100.0 : stackingDistanceUnit == 'Renko Boxes' ? minimumVerticalSeparation * math.max(boxSize, syminfo.mintick) : minimumVerticalSeparation

getStackedCalloutPosition(bool upWave, float normalY, float boxSize, float referencePrice, int anchorBar, int previousAnchorBar, label previousCalloutLabel, int previousLevel, string currentText) =>
    int laneCount = math.max(maximumStaggerLevels, 1)
    int stackLevel = 0
    float stackedY = normalY
    bool hasPreviousLabel = enableAdjacentCommentStacking and not na(previousAnchorBar) and not na(previousCalloutLabel)

    if hasPreviousLabel
        string previousText = label.get_text(previousCalloutLabel)
        float currentHalfWidthBars = getEstimatedTextHalfWidthBars(currentText, calloutFontSize, calloutMaxCharacters, adjacentCommentDistanceBars, boldWaveCommentText, false)
        float previousHalfWidthBars = getEstimatedTextHalfWidthBars(previousText, calloutFontSize, calloutMaxCharacters, adjacentCommentDistanceBars, boldWaveCommentText, false)
        bool horizontalCollision = horizontalRangesOverlap(anchorBar, currentHalfWidthBars, previousAnchorBar, previousHalfWidthBars, adjacentCommentDistanceBars)

        if horizontalCollision
            float requestedSeparation = getStackingSeparation(boxSize, referencePrice)
            float previousY = label.get_y(previousCalloutLabel)
            float currentHalfHeight = getEstimatedTextHalfHeight(currentText, calloutFontSize, requestedSeparation)
            float previousHalfHeight = getEstimatedTextHalfHeight(previousText, calloutFontSize, requestedSeparation)
            float automaticDaylight = requestedSeparation * 0.10
            float requiredCenterSeparation = math.max(requestedSeparation, currentHalfHeight + previousHalfHeight + automaticDaylight)
            bool verticalCollision = math.abs(normalY - previousY) < requiredCenterSeparation

            if verticalCollision
                stackLevel := laneCount > 1 ? (previousLevel + 1) % laneCount : 0
                float laneOffset = stackLevel * requestedSeparation
                float laneY = upWave ? normalY + laneOffset : normalY - laneOffset
                float exactOutwardY = upWave ? previousY + requiredCenterSeparation : previousY - requiredCenterSeparation
                stackedY := upWave ? math.max(laneY, exactOutwardY) : math.min(laneY, exactOutwardY)

    [stackedY, stackLevel]

getStatsFillColour(bool upWave, bool provisional) =>
    color baseColour = upWave ? upWaveStatisticsFillColour : downWaveStatisticsFillColour
    color.new(baseColour, provisional ? developingStatisticsFillTransparency : completedStatisticsFillTransparency)

getStatsConnectorColour(bool upWave, bool provisional) =>
    color baseColour = upWave ? color.rgb(76, 175, 80) : color.rgb(255, 82, 82)
    provisional ? color.new(baseColour, 35) : baseColour

getCalloutColour(bool upWave, bool provisional) =>
    color baseColour = upWave ? color.rgb(76, 175, 80) : color.rgb(255, 82, 82)
    color.new(baseColour, provisional ? liveCalloutBackgroundTransparency : calloutBackgroundTransparency)

getCalloutConnectorColour(bool upWave) =>
    color baseColour = upWave ? color.rgb(76, 175, 80) : color.rgb(255, 82, 82)
    color.new(baseColour, calloutConnectorTransparency)

buildStatsText(float displayedEffort, int boxes, bool provisional) => (provisional ? 'LIVE\n' : '') + 'Vol ' + formatVolume(displayedEffort) + '\n' + str.tostring(boxes) + ' boxes'

getGeneralComment(bool upWave, int effortState, int resultState) =>
    string comment = 'No material change'

    if upWave
        if effortState == 1 and resultState == 1
            comment := 'Demand expanding'
        else if effortState == -1 and resultState == -1
            comment := 'Demand contracting'
        else if (effortState == -1 and resultState >= 0) or (effortState == 0 and resultState == 1)
            comment := 'Less effort needed to rise'
        else if (effortState == 1 and resultState <= 0) or (effortState == 0 and resultState == -1)
            comment := 'Buying effort absorbed'
    else
        if effortState == 1 and resultState == 1
            comment := 'Supply expanding'
        else if effortState == -1 and resultState == -1
            comment := 'Supply contracting'
        else if (effortState == -1 and resultState >= 0) or (effortState == 0 and resultState == 1)
            comment := 'Less support beneath price'
        else if (effortState == 1 and resultState <= 0) or (effortState == 0 and resultState == -1)
            comment := 'Selling effort absorbed'

    comment

getDevelopingPrimaryComment(bool upWave, int effortState, int resultState) =>
    string comment = upWave ? 'Developing buying wave' : 'Developing selling wave'

    if upWave
        if effortState == 1 and resultState == 1
            comment := 'Demand currently expanding'
        else if effortState == -1 and resultState == -1
            comment := 'Demand currently contracting'
        else if (effortState == -1 and resultState >= 0) or (effortState == 0 and resultState == 1)
            comment := 'Less effort currently needed to rise'
        else if (effortState == 1 and resultState <= 0) or (effortState == 0 and resultState == -1)
            comment := 'Buying effort currently absorbed'
        else
            comment := 'No material change yet'
    else
        if effortState == 1 and resultState == 1
            comment := 'Supply currently expanding'
        else if effortState == -1 and resultState == -1
            comment := 'Supply currently contracting'
        else if (effortState == -1 and resultState >= 0) or (effortState == 0 and resultState == 1)
            comment := 'Less support currently beneath price'
        else if (effortState == 1 and resultState <= 0) or (effortState == 0 and resultState == -1)
            comment := 'Selling effort currently absorbed'
        else
            comment := 'No material change yet'

    comment

// Canonical structural wording. The Scenario Key uses present tense and completed
// comment boxes use past tense, while retaining the same wording and word order.
getBuyingClimaxPendingText(bool completedTense) => completedTense ? 'Up-wave met the climax threshold; next down-wave reversal confirmation pending' : 'Up-wave meets the climax threshold; next down-wave reversal confirmation pending'
getSellingClimaxPendingText(bool completedTense) => completedTense ? 'Down-wave met the climax threshold; next up-wave reversal confirmation pending' : 'Down-wave meets the climax threshold; next up-wave reversal confirmation pending'

getBuyingClimaxCandidateText(bool completedTense, int reversalBoxes) =>
    string reversalVerb = completedTense ? 'confirmed' : 'confirms'
    'Next down-wave ' + reversalVerb + ' a ' + str.tostring(reversalBoxes) + '-box reversal; awaiting the next up-wave retest'

getSellingClimaxCandidateText(bool completedTense, int reversalBoxes) =>
    string reversalVerb = completedTense ? 'confirmed' : 'confirms'
    'Next up-wave ' + reversalVerb + ' a ' + str.tostring(reversalBoxes) + '-box reversal; awaiting the next down-wave test'

getBuyingClimaxConfirmedText(bool completedTense) => completedTense ? 'Next up-wave retest produced a shorter rise and failed below the climax high on lower volume' : 'Next up-wave retest produces a shorter rise and fails below the climax high on lower volume'
getSellingClimaxConfirmedText(bool completedTense) => completedTense ? 'Next down-wave test produced a shorter decline and held above the climax low on lower volume' : 'Next down-wave test produces a shorter decline and holds above the climax low on lower volume'

getBuyingClimaxReversalFailureText(bool completedTense, int reversalBoxes) => (completedTense ? 'Next down-wave reversal failed before ' : 'Next down-wave reversal fails before ') + str.tostring(reversalBoxes) + ' boxes'
getSellingClimaxReversalFailureText(bool completedTense, int reversalBoxes) => (completedTense ? 'Next up-wave reversal failed before ' : 'Next up-wave reversal fails before ') + str.tostring(reversalBoxes) + ' boxes'
getBuyingClimaxHighFailureText(bool completedTense) => completedTense ? 'Next up-wave retest reached or exceeded the climax high' : 'Next up-wave retest reaches or exceeds the climax high'
getSellingClimaxLowFailureText(bool completedTense) => completedTense ? 'Next down-wave test broke the climax low' : 'Next down-wave test breaks the climax low'
getBuyingClimaxVolumeFailureText(bool completedTense) => completedTense ? 'Next up-wave retest was not on lower volume' : 'Next up-wave retest is not on lower volume'
getSellingClimaxVolumeFailureText(bool completedTense) => completedTense ? 'Next down-wave test was not on lower volume' : 'Next down-wave test is not on lower volume'
getBuyingClimaxResultFailureText(bool completedTense) => completedTense ? 'Next up-wave retest did not produce a shorter rise' : 'Next up-wave retest does not produce a shorter rise'
getSellingClimaxResultFailureText(bool completedTense) => completedTense ? 'Next down-wave test did not produce a shorter decline' : 'Next down-wave test does not produce a shorter decline'

getBuyingClimaxFailureSummaryText(bool completedTense) => completedTense ? 'Required next wave did not satisfy the buying-climax confirmation sequence' : 'Required next wave does not satisfy the buying-climax confirmation sequence'
getSellingClimaxFailureSummaryText(bool completedTense) => completedTense ? 'Required next wave did not satisfy the selling-climax confirmation sequence' : 'Required next wave does not satisfy the selling-climax confirmation sequence'
getCandidateReversalFailureSummaryText(bool completedTense, int reversalBoxes) => (completedTense ? 'Required next confirmation wave failed before ' : 'Required next confirmation wave fails before ') + str.tostring(reversalBoxes) + ' boxes'

getNoSupplyPendingText(bool completedTense) => completedTense ? 'Lower-volume, shorter down-wave formed a low above the previous completed down-wave low; next up-wave reversal confirmation pending' : 'Lower-volume, shorter down-wave forms a low above the previous completed down-wave low; next up-wave reversal confirmation pending'
getNoDemandPendingText(bool completedTense) => completedTense ? 'Lower-volume, shorter up-wave formed a high below the previous completed up-wave high; next down-wave reversal confirmation pending' : 'Lower-volume, shorter up-wave forms a high below the previous completed up-wave high; next down-wave reversal confirmation pending'
getNoSupplyConfirmedText(bool completedTense, int reversalBoxes) => (completedTense ? 'Next up-wave sustained a ' : 'Next up-wave sustains a ') + str.tostring(reversalBoxes) + '-box reversal from the higher low'
getNoDemandConfirmedText(bool completedTense, int reversalBoxes) => (completedTense ? 'Next down-wave sustained a ' : 'Next down-wave sustains a ') + str.tostring(reversalBoxes) + '-box reversal from the lower high'
getNoSupplyFailureText(bool completedTense, int reversalBoxes) => (completedTense ? 'Next up-wave reversal failed before ' : 'Next up-wave reversal fails before ') + str.tostring(reversalBoxes) + ' boxes'
getNoDemandFailureText(bool completedTense, int reversalBoxes) => (completedTense ? 'Next down-wave reversal failed before ' : 'Next down-wave reversal fails before ') + str.tostring(reversalBoxes) + ' boxes'

getSellingClimaxTestFailure(bool lowerVolume, bool shorterDecline, bool higherLow) =>
    string explanation = 'Next down-wave test did not satisfy all confirmation conditions'

    if not higherLow
        explanation := getSellingClimaxLowFailureText(true)
    else if not lowerVolume
        explanation := getSellingClimaxVolumeFailureText(true)
    else if not shorterDecline
        explanation := getSellingClimaxResultFailureText(true)

    explanation

getBuyingClimaxTestFailure(bool lowerVolume, bool shorterRise, bool lowerHigh) =>
    string explanation = 'Next up-wave retest did not satisfy all confirmation conditions'

    if not lowerHigh
        explanation := getBuyingClimaxHighFailureText(true)
    else if not lowerVolume
        explanation := getBuyingClimaxVolumeFailureText(true)
    else if not shorterRise
        explanation := getBuyingClimaxResultFailureText(true)

    explanation

// ============================================================================
// VISIBLE RENKO GEOMETRY
// ============================================================================

renkoBoxTop = math.max(open, close)
renkoBoxBottom = math.min(open, close)
renkoBoxMidpoint = (open + close) / 2.0
renkoBoxSize = math.max(math.abs(close - open), syminfo.mintick)
validDirection = not na(direction) and direction != 0

// ============================================================================
// ACTIVE WAVE TRACKING
// ============================================================================

int waveBoxCount = 0
waveBoxCount := not validDirection ? 0 : directionHasChanged or nz(waveBoxCount[1]) == 0 ? 1 : waveBoxCount[1] + 1

waveStartPrice = float(na)
waveStartPrice := not validDirection ? na : directionHasChanged or na(waveStartPrice[1]) ? directionIsUp ? renkoBoxBottom : renkoBoxTop : waveStartPrice[1]

waveStartBar = int(na)
waveStartBar := not validDirection ? na : directionHasChanged or na(waveStartBar[1]) ? bar_index : waveStartBar[1]

waveExtremePrice = float(na)
waveExtremeBar = int(na)
waveExtremeTime = int(na)
waveExtremeBoxMidpoint = float(na)
waveExtremeBoxSize = float(na)

waveIsNew = validDirection and (directionHasChanged or na(waveExtremePrice[1]))
newUpExtreme = validDirection and directionIsUp and not waveIsNew and renkoBoxTop >= waveExtremePrice[1]
newDownExtreme = validDirection and directionIsDown and not waveIsNew and renkoBoxBottom <= waveExtremePrice[1]
newWaveExtreme = waveIsNew or newUpExtreme or newDownExtreme
currentDirectionalExtreme = directionIsUp ? renkoBoxTop : renkoBoxBottom

waveExtremePrice := not validDirection ? na : newWaveExtreme ? currentDirectionalExtreme : waveExtremePrice[1]
waveExtremeBar := not validDirection ? na : newWaveExtreme ? bar_index : waveExtremeBar[1]
waveExtremeTime := not validDirection ? na : newWaveExtreme ? time : waveExtremeTime[1]
waveExtremeBoxMidpoint := not validDirection ? na : newWaveExtreme ? renkoBoxMidpoint : waveExtremeBoxMidpoint[1]
waveExtremeBoxSize := not validDirection ? na : newWaveExtreme ? renkoBoxSize : waveExtremeBoxSize[1]

wavePriceResult = validDirection and not na(waveStartPrice) and not na(waveExtremePrice) ? math.abs(waveExtremePrice - waveStartPrice) : na

int mappedWaveStartBar = useRequestedRenkoState ? requestedWaveStartBarValue : na
int mappedWaveExtremeBar = useRequestedRenkoState ? requestedWaveExtremeBarValue : na
int mappedWaveExtremeTime = useRequestedRenkoState ? mapRequestedTimeToSourceTime(requestedWaveExtremeTime) : na

if useRequestedRenkoState
    waveBoxCount := requestedWaveBoxCount
    waveStartPrice := requestedWaveStartPrice
    waveStartBar := requestedWaveStartBarValue
    waveExtremePrice := requestedWaveExtremePrice
    waveExtremeBar := requestedWaveExtremeBarValue
    waveExtremeTime := mapRequestedTimeToSourceTime(requestedWaveExtremeTime)
    waveExtremeBoxMidpoint := requestedWaveExtremeBoxMidpoint
    waveExtremeBoxSize := requestedWaveExtremeBoxSize
    wavePriceResult := requestedWavePriceResult

// Track the most recently ended up-wave and down-wave at every direction
// change, including provisional Renko projection changes. This keeps the live
// comparison tied to the visually immediate previous same-direction wave;
// confirmed historical bars retain the same values after recalculation.
bool directWaveEndedThisBar = directionHasChanged and bar_index > 0 and not na(direction[1]) and direction[1] != 0 and not na(vol[1]) and not na(wavePriceResult[1]) and not na(waveExtremePrice[1])
bool waveEndedThisBar = useRequestedRenkoState ? requestedWaveEndedThisBar and requestedLastEndedDirection != 0 and not na(requestedLastEndedEffort) and not na(requestedLastEndedResult) and not na(requestedLastEndedExtreme) : directWaveEndedThisBar
int endedDirection = useRequestedRenkoState ? requestedLastEndedDirection : direction[1]
float endedDisplayedEffort = useRequestedRenkoState ? requestedLastEndedDisplayedEffort : res[1]
float endedEffort = useRequestedRenkoState ? requestedLastEndedEffort : vol[1]
int endedBoxes = useRequestedRenkoState ? requestedLastEndedBoxes : waveBoxCount[1]
float endedResult = useRequestedRenkoState ? requestedLastEndedResult : wavePriceResult[1]
float endedExtreme = useRequestedRenkoState ? requestedLastEndedExtreme : waveExtremePrice[1]
int endedExtremeTime = useRequestedRenkoState ? mapRequestedTimeToSourceTime(requestedLastEndedExtremeTime) : waveExtremeTime[1]
float endedExtremeBoxMidpoint = useRequestedRenkoState ? requestedLastEndedExtremeBoxMidpoint : waveExtremeBoxMidpoint[1]
float endedExtremeBoxSize = useRequestedRenkoState ? requestedLastEndedExtremeBoxSize : waveExtremeBoxSize[1]
float endedStartPrice = useRequestedRenkoState ? requestedLastEndedStartPrice : waveStartPrice[1]
int endedStartBar = useRequestedRenkoState ? requestedLastEndedStartBarValue : waveStartBar[1]


int endedExtremeBar = useRequestedRenkoState ? requestedLastEndedExtremeBarValue : waveExtremeBar[1]

lastCompletedUpEffort = float(na)
lastCompletedDownEffort = float(na)
lastCompletedUpResult = float(na)
lastCompletedDownResult = float(na)
lastCompletedUpExtreme = float(na)
lastCompletedDownExtreme = float(na)

lastCompletedUpEffort := waveEndedThisBar and endedDirection > 0 ? endedEffort : lastCompletedUpEffort[1]
lastCompletedDownEffort := waveEndedThisBar and endedDirection < 0 ? endedEffort : lastCompletedDownEffort[1]
lastCompletedUpResult := waveEndedThisBar and endedDirection > 0 ? endedResult : lastCompletedUpResult[1]
lastCompletedDownResult := waveEndedThisBar and endedDirection < 0 ? endedResult : lastCompletedDownResult[1]
lastCompletedUpExtreme := waveEndedThisBar and endedDirection > 0 ? endedExtreme : lastCompletedUpExtreme[1]
lastCompletedDownExtreme := waveEndedThisBar and endedDirection < 0 ? endedExtreme : lastCompletedDownExtreme[1]

// Freeze the immediately preceding same-direction wave measurements when each
// new wave begins. All developing and completed comparisons for that wave use
// this fixed reference, preventing a later state update from changing which
// prior high, low, effort or result is being compared.
waveReferenceEffort = float(na)
waveReferenceResult = float(na)
waveReferenceExtreme = float(na)

bool initialiseWaveReference = validDirection and ((useRequestedRenkoState ? requestedWaveEndedThisBar : directionHasChanged) or na(waveReferenceExtreme[1]))
waveReferenceEffort := not validDirection ? na : initialiseWaveReference ? (directionIsUp ? lastCompletedUpEffort : lastCompletedDownEffort) : waveReferenceEffort[1]
waveReferenceResult := not validDirection ? na : initialiseWaveReference ? (directionIsUp ? lastCompletedUpResult : lastCompletedDownResult) : waveReferenceResult[1]
waveReferenceExtreme := not validDirection ? na : initialiseWaveReference ? (directionIsUp ? lastCompletedUpExtreme : lastCompletedDownExtreme) : waveReferenceExtreme[1]

// ============================================================================
// DRAWING ARRAYS
// ============================================================================

var array<label> completedStatsLabels = array.new<label>()
var array<label> completedCalloutLabels = array.new<label>()
var array<line> completedStatsLines = array.new<line>()
var array<line> completedCalloutLines = array.new<line>()
var array<line> completedRenkoOverlayLines = array.new<line>()
var array<line> requestedCompletedRenkoOverlayLines = array.new<line>()

var label currentStatsLabel = na
var line currentStatsLine = na
var label currentCalloutLabel = na
var line currentCalloutLine = na
var line currentRenkoOverlayLine = na
var int lastConfirmedWavePivotBar = na
var int lastConfirmedWavePivotTime = na
var float lastConfirmedWavePivotPrice = na
var int requestedProcessedWaveSerial = na
var int requestedCanonicalPivotTime = na
var float requestedCanonicalPivotPrice = na

var int lastPeakStatsAnchorBar = na
var int lastTroughStatsAnchorBar = na
var label lastPeakStatsLabel = na
var label lastTroughStatsLabel = na

var int lastUpCalloutAnchorBar = na
var int lastDownCalloutAnchorBar = na
var label lastUpCalloutLabel = na
var label lastDownCalloutLabel = na
var int lastUpCalloutStackLevel = 0
var int lastDownCalloutStackLevel = 0

// ============================================================================
// DYNAMIC INTERPRETATION STATES
// ============================================================================

var label noSupplyCallout = na
var string noSupplyPrimaryComment = ''
var int noSupplyStage = 0

var label noDemandCallout = na
var string noDemandPrimaryComment = ''
var int noDemandStage = 0

var label sellingClimaxCallout = na
var string sellingClimaxPrimaryComment = ''
var float sellingClimaxEffort = na
var float sellingClimaxResult = na
var float sellingClimaxExtreme = na
var int sellingClimaxStage = 0

var label buyingClimaxCallout = na
var string buyingClimaxPrimaryComment = ''
var float buyingClimaxEffort = na
var float buyingClimaxResult = na
var float buyingClimaxExtreme = na
var int buyingClimaxStage = 0

// ============================================================================
// NOTE AND SCENARIO TABLES
// ============================================================================

const int KEY_ROW_COUNT = 25

int displayedKeyFontSize = keyFontSize
int noteWrapCharacters = scaledWrapCharacters(noteMaxCharacters, noteWidthPercent, 15.0, noteFontSize, 14)
int keyScenarioWrapCharacters = scaledWrapCharacters(keyScenarioMaxCharacters, keyScenarioWidthPercent, 9.0, keyFontSize, 12)
int keyCommentWrapCharacters = scaledWrapCharacters(keyCommentMaxCharacters, keyCommentWidthPercent, 6.0, keyFontSize, 12)

var table noteTable = table.new(position.top_left, 1, 1, force_overlay=true)
var table keyTable = table.new(position.bottom_right, 2, KEY_ROW_COUNT, force_overlay=true)

if barstate.islast
    table.set_position(noteTable, getTablePosition(notePositionInput))
    table.set_bgcolor(noteTable, color.new(color.white, noteBackgroundTransparency))
    table.set_frame_color(noteTable, color.black)
    table.set_frame_width(noteTable, noteFrameWidth)
    table.clear(noteTable, 0, 0, 0, 0)

    if showPermanentNote
        string noteText = 'NOTE\n' + wrapText('Pivot statistics show the volume and box count for each wave.', noteWrapCharacters) + '\n' + wrapText('Primary wave comments compare each wave with the previous wave in the same direction.', noteWrapCharacters) + '\n' + wrapText('Structural comment boxes show: conclusion; Scenario Key wave comment; follow-through explanation.', noteWrapCharacters) + '\n' + wrapText('Developing comments are provisional and update until the wave completes.', noteWrapCharacters) + '\n' + wrapText('Projection bricks on an open source-timeframe bar can change before that bar closes.', noteWrapCharacters)
        table.cell(noteTable, 0, 0, noteText, width=noteWidthPercent, text_color=color.black, text_size=noteFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=color.new(color.white, noteBackgroundTransparency))

    table.set_position(keyTable, getTablePosition(keyPositionInput))
    table.set_bgcolor(keyTable, color.new(color.white, keyBackgroundTransparency))
    table.set_frame_color(keyTable, color.black)
    table.set_frame_width(keyTable, keyFrameWidth)
    table.set_border_color(keyTable, color.new(color.gray, 35))
    table.set_border_width(keyTable, keyBorderWidth)
    table.clear(keyTable, 0, 0, 1, KEY_ROW_COUNT - 1)

    if showScenarioKey
        color headerColour = color.rgb(70, 70, 70)
        color subHeaderColour = color.rgb(95, 95, 95)
        color upKeyColour = color.new(color.green, 88)
        color downKeyColour = color.new(color.red, 90)
        color neutralKeyColour = color.new(color.gray, 92)

        table.cell(keyTable, 0, 0, 'SCENARIO', width=keyScenarioWidthPercent, text_color=color.white, text_size=displayedKeyFontSize, text_halign=text.align_center, text_valign=text.align_top, bgcolor=headerColour)
        table.cell(keyTable, 1, 0, 'WAVE COMMENT', width=keyCommentWidthPercent, text_color=color.white, text_size=displayedKeyFontSize, text_halign=text.align_center, text_valign=text.align_top, bgcolor=headerColour)
        table.cell(keyTable, 0, 1, wrapText('More volume produces a longer rise', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 1, wrapText('Demand expanding', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 2, wrapText('Less volume produces a shorter rise', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 2, wrapText('Demand contracting', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 3, wrapText('Less volume produces the same or a longer rise, or similar volume produces a longer rise', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 3, wrapText('Less effort needed to rise', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 4, wrapText('More volume produces the same or a shorter rise, or similar volume produces a shorter rise', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 4, wrapText('Buying effort absorbed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 5, wrapText('More volume produces a longer decline', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 5, wrapText('Supply expanding', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 6, wrapText('Less volume produces a shorter decline', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 6, wrapText('Supply contracting', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 7, wrapText('Less volume produces the same or a longer decline, or similar volume produces a longer decline', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 7, wrapText('Less support beneath price', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 8, wrapText('More volume produces the same or a shorter decline, or similar volume produces a shorter decline', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 8, wrapText('Selling effort absorbed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 9, wrapText('Similar volume produces similar price movement', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 1, 9, wrapText('No material change', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 0, 10, 'FOLLOW-THROUGH WORDING', width=keyScenarioWidthPercent, text_color=color.white, text_size=displayedKeyFontSize, text_halign=text.align_center, text_valign=text.align_top, bgcolor=subHeaderColour)
        table.cell(keyTable, 1, 10, 'DYNAMIC CONCLUSION', width=keyCommentWidthPercent, text_color=color.white, text_size=displayedKeyFontSize, text_halign=text.align_center, text_valign=text.align_top, bgcolor=subHeaderColour)

        table.cell(keyTable, 0, 11, wrapText(getBuyingClimaxPendingText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 11, wrapText('Possible buying climax', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 12, wrapText(getBuyingClimaxCandidateText(false, sustainedReversalBoxes), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 12, wrapText('Buying climax candidate', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 13, wrapText(getBuyingClimaxConfirmedText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 13, wrapText('Buying climax confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 14, wrapText(getBuyingClimaxFailureSummaryText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 1, 14, wrapText('Buying climax not confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)

        table.cell(keyTable, 0, 15, wrapText(getSellingClimaxPendingText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 15, wrapText('Possible selling climax', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 16, wrapText(getSellingClimaxCandidateText(false, sustainedReversalBoxes), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 16, wrapText('Selling climax candidate', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 17, wrapText(getSellingClimaxConfirmedText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 17, wrapText('Selling climax confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 18, wrapText(getSellingClimaxFailureSummaryText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 1, 18, wrapText('Selling climax not confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)

        table.cell(keyTable, 0, 19, wrapText(getNoSupplyPendingText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 19, wrapText('Possible no supply', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 20, wrapText(getNoSupplyConfirmedText(false, sustainedReversalBoxes), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 1, 20, wrapText('No supply confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=downKeyColour)
        table.cell(keyTable, 0, 21, wrapText(getNoDemandPendingText(false), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 21, wrapText('Possible no demand', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 22, wrapText(getNoDemandConfirmedText(false, sustainedReversalBoxes), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 1, 22, wrapText('No demand confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=upKeyColour)
        table.cell(keyTable, 0, 23, wrapText(getCandidateReversalFailureSummaryText(false, sustainedReversalBoxes), keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 1, 23, wrapText('No supply or no demand candidate not confirmed', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 0, 24, wrapText('Provisional until the current wave completes', keyScenarioWrapCharacters), width=keyScenarioWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)
        table.cell(keyTable, 1, 24, wrapText('Developing / provisional', keyCommentWrapCharacters), width=keyCommentWidthPercent, text_color=color.black, text_size=displayedKeyFontSize, text_halign=text.align_left, text_valign=text.align_top, bgcolor=neutralKeyColour)

        // Reapply each selected column width to every row so both width controls remain fully responsive.
        for keyRow = 0 to KEY_ROW_COUNT - 1
            table.cell_set_width(keyTable, 0, keyRow, keyScenarioWidthPercent)
            table.cell_set_width(keyTable, 1, keyRow, keyCommentWidthPercent)

// ============================================================================
// DRAWING LIMIT MANAGEMENT
// ============================================================================

int labelsPerCompletedWave = (showCompletedWaveLabels ? 1 : 0) + (showWaveCallouts ? 1 : 0)
int linesPerCompletedWave = (showCompletedWaveLabels and showConnectorLines ? 1 : 0) + (showWaveCallouts and showCalloutConnectorLines ? 1 : 0) + (showRenkoWaveOverlay ? 1 : 0)
int liveLabelAllowance = (showCurrentWaveLabel ? 1 : 0) + (showCurrentWaveCallout ? 1 : 0)
int liveLineAllowance = (showCurrentWaveLabel and showConnectorLines ? 1 : 0) + (showCurrentWaveCallout and showCalloutConnectorLines ? 1 : 0) + (showRenkoWaveOverlay ? 1 : 0)
int availableCompletedLabels = math.max(1, 500 - liveLabelAllowance)
int availableCompletedLines = math.max(1, 500 - liveLineAllowance)
int labelWaveLimit = labelsPerCompletedWave > 0 ? int(math.floor(availableCompletedLabels / labelsPerCompletedWave)) : maximumHistoricalLabels
int lineWaveLimit = linesPerCompletedWave > 0 ? int(math.floor(availableCompletedLines / linesPerCompletedWave)) : maximumHistoricalLabels
int effectiveHistoricalWaves = math.max(3, math.min(maximumHistoricalLabels, math.min(labelWaveLimit, lineWaveLimit)))


// ============================================================================
// CONVENTIONAL-CHART REMOTE-RENKO WAVE OVERLAY
// ============================================================================

// Actual completed remote-state events are processed oldest to newest. Renko
// timestamps are first mapped to conventional source bars, and each accepted event
// advances the canonical pivot before the following segment is constructed. If
// several waves complete inside one source bar, intermediate statistics are drawn
// here because the main production completion block can consume only the latest
// event on that conventional bar.
if useRequestedRenkoState
    int requestedOverlayEventCount = array.size(requestedCompletedEventSerials)

    if requestedOverlayEventCount > 0
        for overlayEventPosition = 0 to requestedOverlayEventCount - 1
            int eventWaveSerial = array.get(requestedCompletedEventSerials, overlayEventPosition)
            int eventLastEndedDirection = array.get(requestedCompletedEventDirections, overlayEventPosition)
            float eventLastEndedDisplayedEffort = array.get(requestedCompletedEventValues, overlayEventPosition)
            int eventLastEndedBoxes = array.get(requestedCompletedEventBoxes, overlayEventPosition)
            float eventLastEndedExtreme = array.get(requestedCompletedEventExtremes, overlayEventPosition)
            int eventLastEndedExtremeTime = array.get(requestedCompletedEventExtremeTimes, overlayEventPosition)
            float eventLastEndedExtremeBoxMidpoint = array.get(requestedCompletedEventExtremeBoxMidpoints, overlayEventPosition)
            float eventLastEndedExtremeBoxSize = array.get(requestedCompletedEventExtremeBoxSizes, overlayEventPosition)
            float eventLastEndedStartPrice = array.get(requestedEventLastEndedStartPrices, overlayEventPosition)
            int eventLastEndedStartTime = array.get(requestedEventLastEndedStartTimes, overlayEventPosition)
            int mappedEventExtremeTime = mapRequestedTimeToSourceTime(eventLastEndedExtremeTime)
            int mappedEventStartTime = mapRequestedTimeToSourceTime(eventLastEndedStartTime)
            int mappedEventExtremeBar = mapRequestedTimeToSourceBar(eventLastEndedExtremeTime)
            bool completedEventIsNew = not na(eventWaveSerial) and (na(requestedProcessedWaveSerial) or eventWaveSerial > requestedProcessedWaveSerial)

            if completedEventIsNew
                bool completedEventSerialGap = not na(requestedProcessedWaveSerial) and eventWaveSerial > requestedProcessedWaveSerial + 1
                int segmentStartTime = na(requestedCanonicalPivotTime) or completedEventSerialGap ? mappedEventStartTime : requestedCanonicalPivotTime
                float segmentStartPrice = na(requestedCanonicalPivotPrice) or completedEventSerialGap ? eventLastEndedStartPrice : requestedCanonicalPivotPrice
                bool completedEventCoordinatesAvailable = not na(segmentStartTime) and not na(segmentStartPrice) and not na(mappedEventExtremeTime) and not na(eventLastEndedExtreme)

                if showRenkoWaveOverlay and completedEventCoordinatesAvailable
                    color eventSegmentColour = eventLastEndedDirection > 0 ? renkoOverlayUpColour : renkoOverlayDownColour
                    line eventSegmentLine = line.new(segmentStartTime, segmentStartPrice, mappedEventExtremeTime, eventLastEndedExtreme, xloc=xloc.bar_time, extend=extend.none, color=eventSegmentColour, style=getRenkoOverlayLineStyle(completedRenkoOverlayStyleInput), width=completedRenkoOverlayWidth, force_overlay=true)
                    array.push(requestedCompletedRenkoOverlayLines, eventSegmentLine)

                    if array.size(requestedCompletedRenkoOverlayLines) > effectiveHistoricalWaves
                        line oldRequestedOverlayLine = array.shift(requestedCompletedRenkoOverlayLines)
                        line.delete(oldRequestedOverlayLine)

                // The normal production completion block below draws the newest
                // event. Draw only earlier events here to avoid duplicate labels.
                bool intermediateCompletedEvent = overlayEventPosition < requestedOverlayEventCount - 1

                if showCompletedWaveLabels and intermediateCompletedEvent and eventLastEndedDirection != 0 and not na(eventLastEndedDisplayedEffort) and not na(eventLastEndedExtreme) and not na(eventLastEndedExtremeBoxSize)
                    if array.size(completedStatsLabels) >= effectiveHistoricalWaves
                        label oldStatsLabel = array.shift(completedStatsLabels)
                        label oldCalloutLabel = array.shift(completedCalloutLabels)
                        line oldStatsLine = array.shift(completedStatsLines)
                        line oldCalloutLine = array.shift(completedCalloutLines)
                        line oldRenkoOverlayLine = array.shift(completedRenkoOverlayLines)

                        if not na(oldStatsLabel)
                            label.delete(oldStatsLabel)

                        if not na(oldCalloutLabel)
                            label.delete(oldCalloutLabel)

                        if not na(oldStatsLine)
                            line.delete(oldStatsLine)

                        if not na(oldCalloutLine)
                            line.delete(oldCalloutLine)

                        if not na(oldRenkoOverlayLine)
                            line.delete(oldRenkoOverlayLine)

                    bool intermediateUpWave = eventLastEndedDirection > 0
                    color intermediateFillColour = getStatsFillColour(intermediateUpWave, false)
                    color intermediateConnectorColour = getStatsConnectorColour(intermediateUpWave, false)
                    string intermediateStatsText = buildStatsText(eventLastEndedDisplayedEffort, eventLastEndedBoxes, false)
                    float normalIntermediateStatsY = getStatsY(intermediateUpWave, eventLastEndedExtreme, eventLastEndedExtremeBoxSize)
                    bool intermediateStatsPlaceAbove = intermediateUpWave ? peakPlacement == 'Above' : troughPlacement == 'Above'
                    int previousStatsAnchorBar = intermediateUpWave ? lastPeakStatsAnchorBar : lastTroughStatsAnchorBar
                    label previousStatsLabel = intermediateUpWave ? lastPeakStatsLabel : lastTroughStatsLabel
                    float intermediateStatsY = getStackedStatsPosition(intermediateStatsPlaceAbove, normalIntermediateStatsY, eventLastEndedExtremeBoxSize, eventLastEndedExtreme, mappedEventExtremeBar, previousStatsAnchorBar, previousStatsLabel, intermediateStatsText)
                    label intermediateStatsLabel = label.new(mappedEventExtremeTime, intermediateStatsY, intermediateStatsText, xloc=xloc.bar_time, yloc=yloc.price, color=intermediateFillColour, style=label.style_label_center, textcolor=statisticsTextColour, size=labelFontSize, textalign=text.align_center, text_font_family=statisticsFontFamily, text_formatting=statisticsTextFormatting, force_overlay=true)
                    line intermediateStatsLine = na

                    if showConnectorLines
                        intermediateStatsLine := line.new(mappedEventExtremeTime, eventLastEndedExtremeBoxMidpoint, mappedEventExtremeTime, intermediateStatsY, xloc=xloc.bar_time, extend=extend.none, color=intermediateConnectorColour, style=line.style_solid, width=connectorLineThickness, force_overlay=true)

                    if intermediateUpWave
                        lastPeakStatsAnchorBar := mappedEventExtremeBar
                        lastPeakStatsLabel := intermediateStatsLabel
                    else
                        lastTroughStatsAnchorBar := mappedEventExtremeBar
                        lastTroughStatsLabel := intermediateStatsLabel

                    array.push(completedStatsLabels, intermediateStatsLabel)
                    array.push(completedCalloutLabels, na)
                    array.push(completedStatsLines, intermediateStatsLine)
                    array.push(completedCalloutLines, na)
                    array.push(completedRenkoOverlayLines, na)

                requestedCanonicalPivotTime := mappedEventExtremeTime
                requestedCanonicalPivotPrice := eventLastEndedExtreme
                requestedProcessedWaveSerial := eventWaveSerial

    if na(requestedCanonicalPivotTime) and requestedDirection != 0
        requestedCanonicalPivotTime := mapRequestedTimeToSourceTime(requestedWaveStartTime)
        requestedCanonicalPivotPrice := requestedWaveStartPrice
        requestedProcessedWaveSerial := requestedWaveSerial

    int mappedRequestedWaveExtremeTime = mapRequestedTimeToSourceTime(requestedWaveExtremeTime)
    bool requestedDevelopingCoordinatesAvailable = not na(requestedCanonicalPivotTime) and not na(requestedCanonicalPivotPrice) and not na(mappedRequestedWaveExtremeTime) and not na(requestedWaveExtremePrice)

    if showRenkoWaveOverlay and requestedDirection != 0 and requestedDevelopingCoordinatesAvailable
        color requestedDevelopingBaseColour = requestedDirection > 0 ? renkoOverlayUpColour : renkoOverlayDownColour
        color requestedDevelopingColour = color.new(requestedDevelopingBaseColour, developingRenkoOverlayTransparency)

        if na(currentRenkoOverlayLine)
            currentRenkoOverlayLine := line.new(requestedCanonicalPivotTime, requestedCanonicalPivotPrice, mappedRequestedWaveExtremeTime, requestedWaveExtremePrice, xloc=xloc.bar_time, extend=extend.none, color=requestedDevelopingColour, style=getRenkoOverlayLineStyle(developingRenkoOverlayStyleInput), width=developingRenkoOverlayWidth, force_overlay=true)
        else
            line.set_xy1(currentRenkoOverlayLine, requestedCanonicalPivotTime, requestedCanonicalPivotPrice)
            line.set_xy2(currentRenkoOverlayLine, mappedRequestedWaveExtremeTime, requestedWaveExtremePrice)
            line.set_color(currentRenkoOverlayLine, requestedDevelopingColour)
            line.set_style(currentRenkoOverlayLine, getRenkoOverlayLineStyle(developingRenkoOverlayStyleInput))
            line.set_width(currentRenkoOverlayLine, developingRenkoOverlayWidth)
    else if not na(currentRenkoOverlayLine)
        line.delete(currentRenkoOverlayLine)
        currentRenkoOverlayLine := na
else
    if not na(currentRenkoOverlayLine)
        line.delete(currentRenkoOverlayLine)
        currentRenkoOverlayLine := na

    if array.size(requestedCompletedRenkoOverlayLines) > 0
        for requestedOverlayLinePosition = 0 to array.size(requestedCompletedRenkoOverlayLines) - 1
            line.delete(array.get(requestedCompletedRenkoOverlayLines, requestedOverlayLinePosition))

    array.clear(requestedCompletedRenkoOverlayLines)
    requestedProcessedWaveSerial := na
    requestedCanonicalPivotTime := na
    requestedCanonicalPivotPrice := na

// ============================================================================
// COMPLETED WAVE PROCESSING
// ============================================================================

confirmedWaveCompletion = waveEndedThisBar and barstate.isconfirmed and bar_index > 0 and endedDirection != 0 and not na(endedDisplayedEffort) and not na(endedExtreme) and not na(endedResult) and not na(endedExtremeBar)

if confirmedWaveCompletion
    bool completedUpWave = endedDirection > 0
    int completedDirection = endedDirection
    float completedDisplayedEffort = endedDisplayedEffort
    float completedEffort = endedEffort
    int completedBoxes = endedBoxes
    float completedResult = endedResult
    float completedExtreme = endedExtreme
    int completedStartBar = endedStartBar
    float completedStartPrice = endedStartPrice
    int completedExtremeBar = endedExtremeBar
    int completedExtremeTime = endedExtremeTime
    float completedExtremeBoxMidpoint = endedExtremeBoxMidpoint
    float completedExtremeBoxSize = endedExtremeBoxSize

    // Resolve no-supply/no-demand candidates whose next opposite wave ended early.
    if noSupplyStage == 1 and completedDirection == 1
        if not na(noSupplyCallout)
            label.set_text(noSupplyCallout, composeComment('Possible no supply not confirmed', noSupplyPrimaryComment, getNoSupplyFailureText(true, sustainedReversalBoxes), calloutMaxCharacters))
        noSupplyCallout := na
        noSupplyPrimaryComment := ''
        noSupplyStage := 0

    if noDemandStage == 1 and completedDirection == -1
        if not na(noDemandCallout)
            label.set_text(noDemandCallout, composeComment('Possible no demand not confirmed', noDemandPrimaryComment, getNoDemandFailureText(true, sustainedReversalBoxes), calloutMaxCharacters))
        noDemandCallout := na
        noDemandPrimaryComment := ''
        noDemandStage := 0

    // Resolve climax candidates whose next opposite wave failed to reach the reversal threshold.
    if sellingClimaxStage == 1 and completedDirection == 1
        if not na(sellingClimaxCallout)
            label.set_text(sellingClimaxCallout, composeComment('Possible selling climax not confirmed', sellingClimaxPrimaryComment, getSellingClimaxReversalFailureText(true, sustainedReversalBoxes), calloutMaxCharacters))
        sellingClimaxCallout := na
        sellingClimaxPrimaryComment := ''
        sellingClimaxStage := 0

    if buyingClimaxStage == 1 and completedDirection == -1
        if not na(buyingClimaxCallout)
            label.set_text(buyingClimaxCallout, composeComment('Possible buying climax not confirmed', buyingClimaxPrimaryComment, getBuyingClimaxReversalFailureText(true, sustainedReversalBoxes), calloutMaxCharacters))
        buyingClimaxCallout := na
        buyingClimaxPrimaryComment := ''
        buyingClimaxStage := 0

    // Validate a selling climax when the next down-wave test completes.
    if sellingClimaxStage == 2 and completedDirection == -1
        bool lowerTestVolume = completedEffort <= sellingClimaxEffort * (1.0 - comparisonThresholdPercent / 100.0)
        bool shorterTestDecline = completedResult <= sellingClimaxResult * (1.0 - comparisonThresholdPercent / 100.0)
        bool higherTestLow = completedExtreme > sellingClimaxExtreme
        string sellingConclusion = lowerTestVolume and shorterTestDecline and higherTestLow ? 'Selling climax confirmed' : 'Selling climax not confirmed'
        string sellingExplanation = lowerTestVolume and shorterTestDecline and higherTestLow ? getSellingClimaxConfirmedText(true) : getSellingClimaxTestFailure(lowerTestVolume, shorterTestDecline, higherTestLow)

        if not na(sellingClimaxCallout)
            label.set_text(sellingClimaxCallout, composeComment(sellingConclusion, sellingClimaxPrimaryComment, sellingExplanation, calloutMaxCharacters))

        sellingClimaxCallout := na
        sellingClimaxPrimaryComment := ''
        sellingClimaxStage := 0

    // Validate a buying climax when the next up-wave retest completes.
    if buyingClimaxStage == 2 and completedDirection == 1
        bool lowerTestVolume = completedEffort <= buyingClimaxEffort * (1.0 - comparisonThresholdPercent / 100.0)
        bool shorterTestRise = completedResult <= buyingClimaxResult * (1.0 - comparisonThresholdPercent / 100.0)
        bool lowerTestHigh = completedExtreme < buyingClimaxExtreme
        string buyingConclusion = lowerTestVolume and shorterTestRise and lowerTestHigh ? 'Buying climax confirmed' : 'Buying climax not confirmed'
        string buyingExplanation = lowerTestVolume and shorterTestRise and lowerTestHigh ? getBuyingClimaxConfirmedText(true) : getBuyingClimaxTestFailure(lowerTestVolume, shorterTestRise, lowerTestHigh)

        if not na(buyingClimaxCallout)
            label.set_text(buyingClimaxCallout, composeComment(buyingConclusion, buyingClimaxPrimaryComment, buyingExplanation, calloutMaxCharacters))

        buyingClimaxCallout := na
        buyingClimaxPrimaryComment := ''
        buyingClimaxStage := 0

    float previousSameEffort = waveReferenceEffort[1]
    float previousSameResult = waveReferenceResult[1]
    float previousSameExtreme = waveReferenceExtreme[1]
    float effortChange = percentChange(completedEffort, previousSameEffort)
    float resultChange = percentChange(completedResult, previousSameResult)
    int effortState = compareState(effortChange, comparisonThresholdPercent)
    int resultState = compareState(resultChange, comparisonThresholdPercent)
    bool hasPriorComparison = not na(previousSameEffort) and not na(previousSameResult)
    bool higherLow = not completedUpWave and not na(previousSameExtreme) and completedExtreme > previousSameExtreme
    bool lowerHigh = completedUpWave and not na(previousSameExtreme) and completedExtreme < previousSameExtreme
    bool noSupplyCandidate = hasPriorComparison and not completedUpWave and effortState == -1 and resultState == -1 and higherLow
    bool noDemandCandidate = hasPriorComparison and completedUpWave and effortState == -1 and resultState == -1 and lowerHigh
    bool climaxExtension = not na(resultChange) and resultChange >= climaxResultIncreasePercent
    bool sellingClimaxCandidate = hasPriorComparison and not completedUpWave and effortState == 1 and (resultState == -1 or climaxExtension)
    bool buyingClimaxCandidate = hasPriorComparison and completedUpWave and effortState == 1 and (resultState == -1 or climaxExtension)
    string primaryComment = hasPriorComparison ? getGeneralComment(completedUpWave, effortState, resultState) : ''
    string structuralConclusion = ''
    string structuralExplanation = ''

    if noSupplyCandidate
        structuralConclusion := 'Possible no supply'
        structuralExplanation := getNoSupplyPendingText(true)
    else if noDemandCandidate
        structuralConclusion := 'Possible no demand'
        structuralExplanation := getNoDemandPendingText(true)
    else if sellingClimaxCandidate
        structuralConclusion := 'Possible selling climax'
        structuralExplanation := getSellingClimaxPendingText(true)
    else if buyingClimaxCandidate
        structuralConclusion := 'Possible buying climax'
        structuralExplanation := getBuyingClimaxPendingText(true)

    string completedComment = primaryComment == '' ? '' : wrapText(primaryComment, calloutMaxCharacters)

    if structuralConclusion != ''
        completedComment := composeComment(structuralConclusion, primaryComment, structuralExplanation, calloutMaxCharacters)

    if array.size(completedStatsLabels) >= effectiveHistoricalWaves
        label oldStatsLabel = array.shift(completedStatsLabels)
        label oldCalloutLabel = array.shift(completedCalloutLabels)
        line oldStatsLine = array.shift(completedStatsLines)
        line oldCalloutLine = array.shift(completedCalloutLines)
        line oldRenkoOverlayLine = array.shift(completedRenkoOverlayLines)

        if not na(oldStatsLabel)
            label.delete(oldStatsLabel)

        if not na(oldCalloutLabel)
            label.delete(oldCalloutLabel)

        if not na(oldStatsLine)
            line.delete(oldStatsLine)

        if not na(oldCalloutLine)
            line.delete(oldCalloutLine)

        if not na(oldRenkoOverlayLine)
            line.delete(oldRenkoOverlayLine)

    label completedStatsLabel = na
    line completedStatsLine = na
    label completedCalloutLabel = na
    line completedCalloutLine = na
    line completedRenkoOverlayLine = na
    color completedFillColour = getStatsFillColour(completedUpWave, false)
    color completedConnectorColour = getStatsConnectorColour(completedUpWave, false)

    float completedStatsY = na
    string completedStatsText = buildStatsText(completedDisplayedEffort, completedBoxes, false)

    bool completedPivotCoordinatesAvailable = (useRequestedRenkoState ? not na(lastConfirmedWavePivotTime) and not na(completedExtremeTime) : not na(lastConfirmedWavePivotBar)) and not na(lastConfirmedWavePivotPrice) and not na(completedExtreme)
    bool completedDirectionMatchesSlope = completedUpWave ? completedExtreme >= lastConfirmedWavePivotPrice : completedExtreme <= lastConfirmedWavePivotPrice

    if showRenkoWaveOverlay and not useRequestedRenkoState and completedPivotCoordinatesAvailable
        color completedRenkoOverlayColour = completedDirectionMatchesSlope ? (completedUpWave ? renkoOverlayUpColour : renkoOverlayDownColour) : completedExtreme > lastConfirmedWavePivotPrice ? renkoOverlayUpColour : renkoOverlayDownColour

        if useRequestedRenkoState
            completedRenkoOverlayLine := line.new(lastConfirmedWavePivotTime, lastConfirmedWavePivotPrice, completedExtremeTime, completedExtreme, xloc=xloc.bar_time, extend=extend.none, color=completedRenkoOverlayColour, style=getRenkoOverlayLineStyle(completedRenkoOverlayStyleInput), width=completedRenkoOverlayWidth, force_overlay=true)
        else
            completedRenkoOverlayLine := line.new(lastConfirmedWavePivotBar, lastConfirmedWavePivotPrice, completedExtremeBar, completedExtreme, xloc=xloc.bar_index, extend=extend.none, color=completedRenkoOverlayColour, style=getRenkoOverlayLineStyle(completedRenkoOverlayStyleInput), width=completedRenkoOverlayWidth, force_overlay=true)

    if showCompletedWaveLabels
        float normalCompletedStatsY = getStatsY(completedUpWave, completedExtreme, completedExtremeBoxSize)
        bool completedStatsPlaceAbove = completedUpWave ? peakPlacement == 'Above' : troughPlacement == 'Above'
        int previousStatsAnchorBar = completedUpWave ? lastPeakStatsAnchorBar : lastTroughStatsAnchorBar
        label previousStatsLabel = completedUpWave ? lastPeakStatsLabel : lastTroughStatsLabel
        completedStatsY := getStackedStatsPosition(completedStatsPlaceAbove, normalCompletedStatsY, completedExtremeBoxSize, completedExtreme, completedExtremeBar, previousStatsAnchorBar, previousStatsLabel, completedStatsText)

        if useRequestedRenkoState
            completedStatsLabel := label.new(completedExtremeTime, completedStatsY, completedStatsText, xloc=xloc.bar_time, yloc=yloc.price, color=completedFillColour, style=label.style_label_center, textcolor=statisticsTextColour, size=labelFontSize, textalign=text.align_center, text_font_family=statisticsFontFamily, text_formatting=statisticsTextFormatting, force_overlay=true)
        else
            completedStatsLabel := label.new(completedExtremeBar, completedStatsY, completedStatsText, xloc=xloc.bar_index, yloc=yloc.price, color=completedFillColour, style=label.style_label_center, textcolor=statisticsTextColour, size=labelFontSize, textalign=text.align_center, text_font_family=statisticsFontFamily, text_formatting=statisticsTextFormatting, force_overlay=true)

        if showConnectorLines
            if useRequestedRenkoState
                completedStatsLine := line.new(completedExtremeTime, completedExtreme, completedExtremeTime, completedStatsY, xloc=xloc.bar_time, extend=extend.none, color=completedConnectorColour, style=line.style_solid, width=connectorLineThickness, force_overlay=true)
            else
                completedStatsLine := line.new(completedExtremeBar, completedExtremeBoxMidpoint, completedExtremeBar, completedStatsY, xloc=xloc.bar_index, extend=extend.none, color=completedConnectorColour, style=line.style_solid, width=connectorLineThickness, force_overlay=true)

        if completedUpWave
            lastPeakStatsAnchorBar := completedExtremeBar
            lastPeakStatsLabel := completedStatsLabel
        else
            lastTroughStatsAnchorBar := completedExtremeBar
            lastTroughStatsLabel := completedStatsLabel

    if showWaveCallouts and completedComment != ''
        int selectedHorizontalOffset = completedUpWave ? upCalloutHorizontalOffset : downCalloutHorizontalOffset
        int minimumWaveBar = math.min(completedStartBar, completedExtremeBar)
        int maximumWaveBar = math.max(completedStartBar, completedExtremeBar)
        int midpointBar = int(math.round((completedStartBar + completedExtremeBar) / 2.0))
        int rawAnchorBar = midpointBar + selectedHorizontalOffset
        int calloutAnchorBar = math.max(minimumWaveBar, math.min(maximumWaveBar, rawAnchorBar))
        float waveBarSpan = completedExtremeBar - completedStartBar
        float anchorFraction = waveBarSpan != 0.0 ? (calloutAnchorBar - completedStartBar) / waveBarSpan : 0.5
        float calloutAnchorPrice = completedStartPrice + (completedExtreme - completedStartPrice) * anchorFraction
        int previousCalloutAnchorBar = completedUpWave ? lastUpCalloutAnchorBar : lastDownCalloutAnchorBar
        label previousCalloutLabel = completedUpWave ? lastUpCalloutLabel : lastDownCalloutLabel
        int previousCalloutStackLevel = completedUpWave ? lastUpCalloutStackLevel : lastDownCalloutStackLevel
        float completedCalloutSeparationBasis = getStackingSeparation(completedExtremeBoxSize, completedExtreme)
        float normalCalloutY = getCalloutBaseY(completedUpWave, completedExtreme, completedExtremeBoxSize, showCompletedWaveLabels, completedStatsY, completedStatsText, completedComment, completedCalloutSeparationBasis)
        [completedCalloutY, completedCalloutStackLevel] = getStackedCalloutPosition(completedUpWave, normalCalloutY, completedExtremeBoxSize, completedExtreme, calloutAnchorBar, previousCalloutAnchorBar, previousCalloutLabel, previousCalloutStackLevel, completedComment)

        completedCalloutLabel := label.new(calloutAnchorBar, completedCalloutY, completedComment, xloc=xloc.bar_index, yloc=yloc.price, color=getCalloutColour(completedUpWave, false), style=label.style_label_center, textcolor=calloutTextColour, size=calloutFontSize, textalign=text.align_center, text_formatting=commentTextFormatting, force_overlay=true)

        if showCalloutConnectorLines
            completedCalloutLine := line.new(calloutAnchorBar, calloutAnchorPrice, calloutAnchorBar, completedCalloutY, xloc=xloc.bar_index, extend=extend.none, color=getCalloutConnectorColour(completedUpWave), style=line.style_solid, width=calloutConnectorThickness, force_overlay=true)

        if completedUpWave
            lastUpCalloutAnchorBar := calloutAnchorBar
            lastUpCalloutLabel := completedCalloutLabel
            lastUpCalloutStackLevel := completedCalloutStackLevel
        else
            lastDownCalloutAnchorBar := calloutAnchorBar
            lastDownCalloutLabel := completedCalloutLabel
            lastDownCalloutStackLevel := completedCalloutStackLevel

    array.push(completedStatsLabels, completedStatsLabel)
    array.push(completedCalloutLabels, completedCalloutLabel)
    array.push(completedStatsLines, completedStatsLine)
    array.push(completedCalloutLines, completedCalloutLine)
    array.push(completedRenkoOverlayLines, completedRenkoOverlayLine)
    if not useRequestedRenkoState
        lastConfirmedWavePivotBar := completedExtremeBar
        lastConfirmedWavePivotTime := completedExtremeTime
        lastConfirmedWavePivotPrice := completedExtreme

    if noSupplyCandidate and not na(completedCalloutLabel)
        noSupplyCallout := completedCalloutLabel
        noSupplyPrimaryComment := primaryComment
        noSupplyStage := 1

    if noDemandCandidate and not na(completedCalloutLabel)
        noDemandCallout := completedCalloutLabel
        noDemandPrimaryComment := primaryComment
        noDemandStage := 1

    if sellingClimaxCandidate and not na(completedCalloutLabel)
        sellingClimaxCallout := completedCalloutLabel
        sellingClimaxPrimaryComment := primaryComment
        sellingClimaxEffort := completedEffort
        sellingClimaxResult := completedResult
        sellingClimaxExtreme := completedExtreme
        sellingClimaxStage := 1

    if buyingClimaxCandidate and not na(completedCalloutLabel)
        buyingClimaxCallout := completedCalloutLabel
        buyingClimaxPrimaryComment := primaryComment
        buyingClimaxEffort := completedEffort
        buyingClimaxResult := completedResult
        buyingClimaxExtreme := completedExtreme
        buyingClimaxStage := 1

// ============================================================================
// CURRENT DEVELOPING RENKO WAVE OVERLAY
// ============================================================================

if not useRequestedRenkoState
    bool developingPivotCoordinatesAvailable = not na(lastConfirmedWavePivotBar) and not na(waveExtremeBar) and not na(lastConfirmedWavePivotPrice) and not na(waveExtremePrice)
    bool developingDirectionMatchesSlope = directionIsUp ? waveExtremePrice >= lastConfirmedWavePivotPrice : waveExtremePrice <= lastConfirmedWavePivotPrice

    if showRenkoWaveOverlay and validDirection and developingPivotCoordinatesAvailable
        color developingRenkoOverlayBaseColour = developingDirectionMatchesSlope ? (directionIsUp ? renkoOverlayUpColour : renkoOverlayDownColour) : waveExtremePrice > lastConfirmedWavePivotPrice ? renkoOverlayUpColour : renkoOverlayDownColour
        color developingRenkoOverlayColour = color.new(developingRenkoOverlayBaseColour, developingRenkoOverlayTransparency)

        if na(currentRenkoOverlayLine)
            currentRenkoOverlayLine := line.new(lastConfirmedWavePivotBar, lastConfirmedWavePivotPrice, waveExtremeBar, waveExtremePrice, xloc=xloc.bar_index, extend=extend.none, color=developingRenkoOverlayColour, style=getRenkoOverlayLineStyle(developingRenkoOverlayStyleInput), width=developingRenkoOverlayWidth, force_overlay=true)
        else
            line.set_xy1(currentRenkoOverlayLine, lastConfirmedWavePivotBar, lastConfirmedWavePivotPrice)
            line.set_xy2(currentRenkoOverlayLine, waveExtremeBar, waveExtremePrice)
            line.set_color(currentRenkoOverlayLine, developingRenkoOverlayColour)
            line.set_style(currentRenkoOverlayLine, getRenkoOverlayLineStyle(developingRenkoOverlayStyleInput))
            line.set_width(currentRenkoOverlayLine, developingRenkoOverlayWidth)
    else if not na(currentRenkoOverlayLine)
        line.delete(currentRenkoOverlayLine)
        currentRenkoOverlayLine := na

// ============================================================================
// UPDATE COMPLETED-WAVE COMMENTS AS FOLLOW-THROUGH DEVELOPS
// ============================================================================

if validDirection
    if noSupplyStage == 1 and directionIsUp
        int progress = math.min(waveBoxCount, sustainedReversalBoxes)
        string conclusion = waveBoxCount >= sustainedReversalBoxes ? 'No supply confirmed' : 'Possible no supply'
        string explanation = waveBoxCount >= sustainedReversalBoxes ? getNoSupplyConfirmedText(true, sustainedReversalBoxes) : 'Next up-wave reversal has reached ' + str.tostring(progress) + ' of ' + str.tostring(sustainedReversalBoxes) + ' boxes'

        if not na(noSupplyCallout)
            label.set_text(noSupplyCallout, composeComment(conclusion, noSupplyPrimaryComment, explanation, calloutMaxCharacters))

        if waveBoxCount >= sustainedReversalBoxes
            noSupplyCallout := na
            noSupplyPrimaryComment := ''
            noSupplyStage := 0

    if noDemandStage == 1 and directionIsDown
        int progress = math.min(waveBoxCount, sustainedReversalBoxes)
        string conclusion = waveBoxCount >= sustainedReversalBoxes ? 'No demand confirmed' : 'Possible no demand'
        string explanation = waveBoxCount >= sustainedReversalBoxes ? getNoDemandConfirmedText(true, sustainedReversalBoxes) : 'Next down-wave reversal has reached ' + str.tostring(progress) + ' of ' + str.tostring(sustainedReversalBoxes) + ' boxes'

        if not na(noDemandCallout)
            label.set_text(noDemandCallout, composeComment(conclusion, noDemandPrimaryComment, explanation, calloutMaxCharacters))

        if waveBoxCount >= sustainedReversalBoxes
            noDemandCallout := na
            noDemandPrimaryComment := ''
            noDemandStage := 0

    if sellingClimaxStage == 1 and directionIsUp
        int progress = math.min(waveBoxCount, sustainedReversalBoxes)
        string conclusion = waveBoxCount >= sustainedReversalBoxes ? 'Selling climax candidate' : 'Possible selling climax'
        string explanation = waveBoxCount >= sustainedReversalBoxes ? getSellingClimaxCandidateText(true, sustainedReversalBoxes) : 'Next up-wave reversal has reached ' + str.tostring(progress) + ' of ' + str.tostring(sustainedReversalBoxes) + ' boxes'

        if not na(sellingClimaxCallout)
            label.set_text(sellingClimaxCallout, composeComment(conclusion, sellingClimaxPrimaryComment, explanation, calloutMaxCharacters))

        if waveBoxCount >= sustainedReversalBoxes
            sellingClimaxStage := 2

    if buyingClimaxStage == 1 and directionIsDown
        int progress = math.min(waveBoxCount, sustainedReversalBoxes)
        string conclusion = waveBoxCount >= sustainedReversalBoxes ? 'Buying climax candidate' : 'Possible buying climax'
        string explanation = waveBoxCount >= sustainedReversalBoxes ? getBuyingClimaxCandidateText(true, sustainedReversalBoxes) : 'Next down-wave reversal has reached ' + str.tostring(progress) + ' of ' + str.tostring(sustainedReversalBoxes) + ' boxes'

        if not na(buyingClimaxCallout)
            label.set_text(buyingClimaxCallout, composeComment(conclusion, buyingClimaxPrimaryComment, explanation, calloutMaxCharacters))

        if waveBoxCount >= sustainedReversalBoxes
            buyingClimaxStage := 2

    if sellingClimaxStage == 2 and directionIsDown and not na(sellingClimaxCallout)
        bool lowerVolumeNow = vol <= sellingClimaxEffort * (1.0 - comparisonThresholdPercent / 100.0)
        bool shorterDeclineNow = wavePriceResult <= sellingClimaxResult * (1.0 - comparisonThresholdPercent / 100.0)
        bool higherLowNow = waveExtremePrice > sellingClimaxExtreme
        string explanation = not higherLowNow ? 'Next down-wave test has broken the climax low' : not lowerVolumeNow ? 'Next down-wave test remains above the climax low, but volume is not sufficiently lower' : not shorterDeclineNow ? 'Next down-wave test remains above the climax low on lower volume, but the decline is not sufficiently shorter' : 'Next down-wave test is developing above the climax low on lower volume with a shorter decline'
        label.set_text(sellingClimaxCallout, composeComment('Selling climax candidate', sellingClimaxPrimaryComment, explanation, calloutMaxCharacters))

    if buyingClimaxStage == 2 and directionIsUp and not na(buyingClimaxCallout)
        bool lowerVolumeNow = vol <= buyingClimaxEffort * (1.0 - comparisonThresholdPercent / 100.0)
        bool shorterRiseNow = wavePriceResult <= buyingClimaxResult * (1.0 - comparisonThresholdPercent / 100.0)
        bool lowerHighNow = waveExtremePrice < buyingClimaxExtreme
        string explanation = not lowerHighNow ? 'Next up-wave retest has reached or exceeded the climax high' : not lowerVolumeNow ? 'Next up-wave retest remains below the climax high, but volume is not sufficiently lower' : not shorterRiseNow ? 'Next up-wave retest remains below the climax high on lower volume, but the rise is not sufficiently shorter' : 'Next up-wave retest is developing below the climax high on lower volume with a shorter rise'
        label.set_text(buyingClimaxCallout, composeComment('Buying climax candidate', buyingClimaxPrimaryComment, explanation, calloutMaxCharacters))

// ============================================================================
// CURRENT DEVELOPING-WAVE STATISTICS
// ============================================================================

float currentStatsDisplayY = na
string currentStatsDisplayText = ''

if showCurrentWaveLabel and validDirection and not na(waveExtremeBar) and not na(res)
    bool currentUpWave = directionIsUp
    float normalCurrentStatsY = getStatsY(currentUpWave, waveExtremePrice, waveExtremeBoxSize)
    bool currentStatsPlaceAbove = currentUpWave ? peakPlacement == 'Above' : troughPlacement == 'Above'
    int previousCurrentStatsAnchorBar = currentUpWave ? lastPeakStatsAnchorBar : lastTroughStatsAnchorBar
    label previousCurrentStatsLabel = currentUpWave ? lastPeakStatsLabel : lastTroughStatsLabel
    currentStatsDisplayText := buildStatsText(res, waveBoxCount, true)
    currentStatsDisplayY := getStackedStatsPosition(currentStatsPlaceAbove, normalCurrentStatsY, waveExtremeBoxSize, waveExtremePrice, waveExtremeBar, previousCurrentStatsAnchorBar, previousCurrentStatsLabel, currentStatsDisplayText)
    color currentFillColour = getStatsFillColour(currentUpWave, true)
    color currentConnectorColour = getStatsConnectorColour(currentUpWave, true)

    if na(currentStatsLabel)
        if useRequestedRenkoState
            currentStatsLabel := label.new(mappedWaveExtremeTime, currentStatsDisplayY, currentStatsDisplayText, xloc=xloc.bar_time, yloc=yloc.price, color=currentFillColour, style=label.style_label_center, textcolor=statisticsTextColour, size=labelFontSize, textalign=text.align_center, text_font_family=statisticsFontFamily, text_formatting=statisticsTextFormatting, force_overlay=true)
        else
            currentStatsLabel := label.new(waveExtremeBar, currentStatsDisplayY, currentStatsDisplayText, xloc=xloc.bar_index, yloc=yloc.price, color=currentFillColour, style=label.style_label_center, textcolor=statisticsTextColour, size=labelFontSize, textalign=text.align_center, text_font_family=statisticsFontFamily, text_formatting=statisticsTextFormatting, force_overlay=true)
    else
        label.set_xy(currentStatsLabel, useRequestedRenkoState ? mappedWaveExtremeTime : waveExtremeBar, currentStatsDisplayY)
        label.set_text(currentStatsLabel, currentStatsDisplayText)
        label.set_color(currentStatsLabel, currentFillColour)
        label.set_size(currentStatsLabel, labelFontSize)
        label.set_text_font_family(currentStatsLabel, statisticsFontFamily)
        label.set_text_formatting(currentStatsLabel, statisticsTextFormatting)

    if showConnectorLines
        if na(currentStatsLine)
            if useRequestedRenkoState
                currentStatsLine := line.new(mappedWaveExtremeTime, waveExtremePrice, mappedWaveExtremeTime, currentStatsDisplayY, xloc=xloc.bar_time, extend=extend.none, color=currentConnectorColour, style=line.style_dashed, width=connectorLineThickness, force_overlay=true)
            else
                currentStatsLine := line.new(waveExtremeBar, waveExtremeBoxMidpoint, waveExtremeBar, currentStatsDisplayY, xloc=xloc.bar_index, extend=extend.none, color=currentConnectorColour, style=line.style_dashed, width=connectorLineThickness, force_overlay=true)
        else
            line.set_xy1(currentStatsLine, useRequestedRenkoState ? mappedWaveExtremeTime : waveExtremeBar, useRequestedRenkoState ? waveExtremePrice : waveExtremeBoxMidpoint)
            line.set_xy2(currentStatsLine, useRequestedRenkoState ? mappedWaveExtremeTime : waveExtremeBar, currentStatsDisplayY)
            line.set_color(currentStatsLine, currentConnectorColour)
            line.set_style(currentStatsLine, line.style_dashed)
            line.set_width(currentStatsLine, connectorLineThickness)
    else if not na(currentStatsLine)
        line.delete(currentStatsLine)
        currentStatsLine := na
else
    if not na(currentStatsLabel)
        label.delete(currentStatsLabel)
        currentStatsLabel := na

    if not na(currentStatsLine)
        line.delete(currentStatsLine)
        currentStatsLine := na

// ============================================================================
// CURRENT DEVELOPING-WAVE COMMENT
// ============================================================================

if showCurrentWaveCallout and validDirection and not na(waveStartBar) and not na(waveExtremeBar) and not na(wavePriceResult)
    bool currentUpWave = directionIsUp
    float previousSameEffort = waveReferenceEffort
    float previousSameResult = waveReferenceResult
    float previousSameExtreme = waveReferenceExtreme
    float currentEffortChange = percentChange(vol, previousSameEffort)
    float currentResultChange = percentChange(wavePriceResult, previousSameResult)
    int currentEffortState = compareState(currentEffortChange, comparisonThresholdPercent)
    int currentResultState = compareState(currentResultChange, comparisonThresholdPercent)
    bool hasCurrentComparison = not na(previousSameEffort) and not na(previousSameResult)
    bool currentStructureCandidate = hasCurrentComparison and currentEffortState == -1 and currentResultState == -1 and not na(previousSameExtreme) and (currentUpWave ? waveExtremePrice < previousSameExtreme : waveExtremePrice > previousSameExtreme)
    string currentPrimaryComment = hasCurrentComparison ? getDevelopingPrimaryComment(currentUpWave, currentEffortState, currentResultState) : (currentUpWave ? 'Developing buying wave' : 'Developing selling wave')
    string currentConclusion = currentStructureCandidate ? (currentUpWave ? 'Possible no demand' : 'Possible no supply') : ''
    string currentExplanation = currentStructureCandidate ? (currentUpWave ? 'Current lower-volume, shorter up-wave remains below the previous completed up-wave high; next down-wave reversal confirmation will be required after completion' : 'Current lower-volume, shorter down-wave remains above the previous completed down-wave low; next up-wave reversal confirmation will be required after completion') : 'Provisional until the current wave completes'
    string currentComment = composeComment(currentConclusion, currentPrimaryComment, currentExplanation, calloutMaxCharacters)
    int selectedHorizontalOffset = currentUpWave ? upCalloutHorizontalOffset : downCalloutHorizontalOffset
    int minimumWaveBar = math.min(waveStartBar, waveExtremeBar)
    int maximumWaveBar = math.max(waveStartBar, waveExtremeBar)
    int midpointBar = int(math.round((waveStartBar + waveExtremeBar) / 2.0))
    int rawAnchorBar = midpointBar + selectedHorizontalOffset
    int currentCalloutAnchorBar = math.max(minimumWaveBar, math.min(maximumWaveBar, rawAnchorBar))
    float currentWaveBarSpan = waveExtremeBar - waveStartBar
    float currentAnchorFraction = currentWaveBarSpan != 0.0 ? (currentCalloutAnchorBar - waveStartBar) / currentWaveBarSpan : 0.5
    float currentCalloutAnchorPrice = waveStartPrice + (waveExtremePrice - waveStartPrice) * currentAnchorFraction
    int previousCurrentCalloutAnchorBar = currentUpWave ? lastUpCalloutAnchorBar : lastDownCalloutAnchorBar
    label previousCurrentCalloutLabel = currentUpWave ? lastUpCalloutLabel : lastDownCalloutLabel
    int previousCurrentCalloutStackLevel = currentUpWave ? lastUpCalloutStackLevel : lastDownCalloutStackLevel
    float currentCalloutSeparationBasis = getStackingSeparation(waveExtremeBoxSize, waveExtremePrice)
    float normalCurrentCalloutY = getCalloutBaseY(currentUpWave, waveExtremePrice, waveExtremeBoxSize, showCurrentWaveLabel, currentStatsDisplayY, currentStatsDisplayText, currentComment, currentCalloutSeparationBasis)
    [currentCalloutY, currentCalloutStackLevel] = getStackedCalloutPosition(currentUpWave, normalCurrentCalloutY, waveExtremeBoxSize, waveExtremePrice, currentCalloutAnchorBar, previousCurrentCalloutAnchorBar, previousCurrentCalloutLabel, previousCurrentCalloutStackLevel, currentComment)

    if na(currentCalloutLabel)
        currentCalloutLabel := label.new(currentCalloutAnchorBar, currentCalloutY, currentComment, xloc=xloc.bar_index, yloc=yloc.price, color=getCalloutColour(currentUpWave, true), style=label.style_label_center, textcolor=calloutTextColour, size=calloutFontSize, textalign=text.align_center, text_formatting=commentTextFormatting, force_overlay=true)
    else
        label.set_xy(currentCalloutLabel, currentCalloutAnchorBar, currentCalloutY)
        label.set_text(currentCalloutLabel, currentComment)
        label.set_color(currentCalloutLabel, getCalloutColour(currentUpWave, true))
        label.set_textcolor(currentCalloutLabel, calloutTextColour)
        label.set_style(currentCalloutLabel, label.style_label_center)
        label.set_size(currentCalloutLabel, calloutFontSize)
        label.set_text_formatting(currentCalloutLabel, commentTextFormatting)

    if showCalloutConnectorLines
        if na(currentCalloutLine)
            currentCalloutLine := line.new(currentCalloutAnchorBar, currentCalloutAnchorPrice, currentCalloutAnchorBar, currentCalloutY, xloc=xloc.bar_index, extend=extend.none, color=getCalloutConnectorColour(currentUpWave), style=line.style_dashed, width=calloutConnectorThickness, force_overlay=true)
        else
            line.set_xy1(currentCalloutLine, currentCalloutAnchorBar, currentCalloutAnchorPrice)
            line.set_xy2(currentCalloutLine, currentCalloutAnchorBar, currentCalloutY)
            line.set_color(currentCalloutLine, getCalloutConnectorColour(currentUpWave))
            line.set_style(currentCalloutLine, line.style_dashed)
            line.set_width(currentCalloutLine, calloutConnectorThickness)
    else if not na(currentCalloutLine)
        line.delete(currentCalloutLine)
        currentCalloutLine := na
else
    if not na(currentCalloutLabel)
        label.delete(currentCalloutLabel)
        currentCalloutLabel := na

    if not na(currentCalloutLine)
        line.delete(currentCalloutLine)
        currentCalloutLine := na
````
