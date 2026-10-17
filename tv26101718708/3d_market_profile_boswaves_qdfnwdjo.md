# 3D Market Profile [BOSWaves]

- url: https://www.tradingview.com/script/QdfnWDjO-3D-Market-Profile-BOSWaves/
- type: indicator
- pine_id: PUB;5cd53559b8d24913980f87066715dbb2
- version: 1.0

## Description

[b]3D Market Profile [BOSWaves] - TPO Time Price Distribution with Polyline 3D Extrusion, Value Area Construction, and Initial Balance Mapping[/b]

[b]Overview[/b]

3D Market Profile [BOSWaves] is a Time Price Opportunity profile system that constructs a TPO distribution from recent chart history and renders it as a three-dimensional extruded structure using polyline geometry, where row width reflects the number of TPO period prints at each price level, density-based gradient coloring communicates participation concentration, and perspective faces on the top and side edges of each row provide spatial depth that standard two-dimensional profiles cannot convey.

[image]https://www.tradingview.com/x/WSzYQvVX/[/image]

Instead of displaying a flat histogram alongside price, this system aggregates chart bars into complete TPO periods at the configured timeframe, assigns sequential alphabet letters to each period, and accumulates per-row letter counts across the full profile window. The resulting distribution drives a full market profile analytical framework including Point of Control identification, Value Area expansion from the POC outward, and Initial Balance range derivation from the opening TPO periods. All structural levels are rendered as extending reference lines and labeled price readouts that project beyond the profile face.

This creates a market profile visualization that combines the structural depth of conventional TPO analysis with a three-dimensional rendering system that makes profile shape and density immediately readable across varying chart zoom levels. The extruded top and side faces follow the profile contour row by row, the rear glass plane frames the distribution within a perspective bounding box, and the complete wireframe connects front and rear geometry with depth-offset corner lines that reinforce the spatial orientation of the profile structure.

Price is therefore evaluated against a fully formed TPO distribution anchored to recent chart history, with POC, Value Area, and Initial Balance levels providing the standard market profile reference framework in a spatially rich visual presentation.

[b]Conceptual Framework[/b]

3D Market Profile is founded on the principle that TPO market profile analysis becomes significantly more visually accessible when the distribution is rendered with three-dimensional spatial depth, allowing traders to read profile shape, density concentration, and structural levels at a glance without the visual ambiguity that flat two-dimensional histogram representations produce at different zoom levels and screen resolutions.

Traditional market profile implementations render uniform flat row boxes where the only visual differentiation between high and low density rows is bar width, which becomes difficult to assess comparatively when profiles contain many rows or are viewed on smaller screens. This framework adds spatial depth through extruded top and side faces that follow the profile contour, creating a volumetric bar chart where density is communicated through both width and three-dimensional geometry simultaneously, and gradient coloring that progresses from the configured low-density to high-density colors adds a third visual dimension that reinforces the density reading.

Three core principles guide the design:
[list=1]
[*]TPO distribution should be constructed from complete timeframe periods rather than individual bars, ensuring each period contributes exactly one letter print to each price row it trades through regardless of how many chart bars compose that period.
[*]The three-dimensional extrusion should follow the profile contour row by row rather than applying a uniform rectangular extrusion, preserving the profile's structural shape in the depth geometry and maintaining the analytical significance of the distribution's outline.
[*]Standard market profile reference levels including POC, Value Area High, Value Area Low, and Initial Balance should be derived from the TPO distribution using conventional methodology and rendered as structural references that extend beyond the profile face for ongoing price interaction monitoring.
[/list]
This shifts market profile visualization from flat histogram reading into a spatially rich three-dimensional distribution analysis where density, shape, and structural levels are simultaneously communicated through geometry, color, and depth.

[b]Theoretical Foundation[/b]

The indicator combines chart bar aggregation into complete TPO periods at the configured timeframe, sequential alphabetical letter assignment per period, per-row letter count accumulation across the full profile window, density-normalized gradient coloring with power transformation, POC identification through maximum count with proximity tiebreaking, outward value area expansion from POC with alternating upper and lower priority, Initial Balance derivation from the opening period count, and polyline-based 3D geometry construction using depth-offset coordinates for top faces, side end caps, and rear glass plane.

Period aggregation groups chart bars by their TPO clock value, merging consecutive bars sharing the same period timestamp into a single period high-low range. Each completed period receives the next sequential alphabet letter from A through Z then a through z, repeating modularly for profiles with more periods than the alphabet. Row assignment maps each period's full high-low range to the corresponding row bins, contributing one print to every row from the period low bin to the period high bin inclusive. The POC selection resolves ties between equal-count rows by choosing the one closest to the mid-range price. Value area expansion adds rows alternately from the high and low sides of the POC based on which adjacent row has the greater count, continuing until the accumulated count reaches the target percentage of total prints.

Four internal systems operate in tandem:
[list]
[*][i]Period Aggregation Engine[/i]: Groups chart bars by TPO clock timestamp into complete periods, accumulating per-period high-low ranges and assigning sequential letter identifiers that are used for both letter rendering and Initial Balance period counting.
[*][i]TPO Distribution Builder[/i]: Accumulates per-row letter strings and print counts from the period high-low ranges, producing the row width and text data that drives all subsequent profile rendering and level calculations.
[*][i]3D Geometry Engine[/i]: Constructs polyline polygon arrays for the extruded top faces following each row's width contour, side end cap faces at the outer edge of each row, and the rear glass plane bounding box, using configurable depth bar and depth row offsets to establish perspective coordinates.
[*][i]Level and Label System[/i]: Derives POC, VAH, VAL, and IB level prices from the distribution, renders dual glow and core lines extending across the profile and beyond with configurable tail length, and places price readout labels at the right edge of the level lines.
[/list]
This design ensures the 3D geometry follows the actual distribution contour while all standard market profile reference levels are derived from the same underlying TPO count data that drives the visual rendering.

[b]How It Works[/b]

3D Market Profile evaluates price through a sequence of aggregation and profile-building processes:
[list=1]
[*][i]Profile Range Calculation[/i]: The highest high and lowest low across the configured bar count establish the full profile range, which is divided into the configured number of rows to produce the uniform row height used for all price-to-row mapping.
[*][i]TPO Period Aggregation[/i]: Chart bars are grouped by their TPO timeframe clock value. Consecutive bars sharing the same period timestamp are merged into a single period with the accumulated high and low. Each completed period boundary triggers storage of the completed period data.
[*][i]Letter Assignment and Row Filling[/i]: Each period is assigned the next sequential alphabet letter. For each period, the low and high row bins are calculated and the period letter is appended to the row text string for every row from low to high inclusive, with the row print count incremented accordingly.
[*][i]Initial Balance Derivation[/i]: The first N periods as configured by the IB Periods setting contribute their highs and lows to the Initial Balance range, producing the IBH and IBL reference levels that mark the range established during the opening portion of the profile window.
[*][i]POC Identification[/i]: The row with the maximum print count is identified as the POC. When multiple rows share the maximum count the row closest to the profile mid-range price is selected, providing a consistent tie-breaking rule that favors centrally located levels.
[*][i]Value Area Construction[/i]: Starting from the POC row, adjacent rows are added one at a time by selecting the higher-count neighbor on each iteration until the accumulated count reaches the VA percentage target of total prints.
[*][i]Profile Geometry Calculation[/i]: The profile start position is determined by the placement setting, with Right of Price positioning the profile in forward chart space at the configured right offset and On Range anchoring it to the beginning of the analyzed window. Row widths are calculated as print count multiplied by cell width.
[*][i]3D Top Face Construction[/i]: For each occupied row, a quadrilateral polyline polygon is constructed connecting the row's front top-left, front top-right, depth-offset rear top-right, and depth-offset rear top-left coordinates, producing the extruded top surface that follows the profile contour.
[*][i]3D Side Cap Construction[/i]: For each occupied row, a quadrilateral polyline polygon connects the front right edge top, front right edge bottom, depth-offset rear right bottom, and depth-offset rear right top, producing the side end cap that closes the extruded row geometry.
[*][i]Front Profile Rendering[/i]: Box objects are created for each occupied row with density-gradient fill coloring, POC and single print override coloring, and border styling that distinguishes the POC row, single print rows, Value Area rows, and standard rows.
[*][i]TPO Letter Rendering[/i]: Individual label objects are placed at the center x and mid-price y position of each letter's cell within the profile, with color distinguishing POC, single print, and standard rows.
[*][i]Level and Label Rendering[/i]: POC lines are rendered as dual glow and core polylines. VAH and VAL render as dotted lines. IBH and IBL render as dashed lines. All extend from the configured tail length left of the profile to the right edge of the depth geometry. Price labels are placed at the right extent of each line.
[/list]
Together, these elements form a complete three-dimensional market profile rendering where the TPO distribution drives both the analytical reference framework and the spatial geometry of the extruded visualization.

[b]Interpretation[/b]

3D Market Profile should be interpreted as a conventional TPO market profile with three-dimensional spatial depth encoding applied to the distribution geometry:
[list]
[*][i]Profile Width[/i]: The horizontal extent of each row reflects its total TPO print count relative to the maximum, with wider rows indicating more time spent at that price level and narrower rows indicating less acceptance.
[*][i]Density Gradient Coloring[/i]: Row fill progresses from the configured low-density color at minimum print count to the high-density color at maximum print count, with a power-transformed gradient that spreads color differentiation across the density range.
[*][i]Point of Control Row (POC)[/i]: The widest row rendered in the POC color identifies the price level with the greatest time-at-price concentration across the profile window, representing the most accepted price during the analyzed period.
[*][i]Value Area[/i]: Rows between VAH and VAL rendered with full opacity represent the price range containing the configured percentage of total TPO prints, identifying the zone of concentrated acceptance around the POC.
[*][i]Non-Value Area Rows[/i]: Rows outside the Value Area are rendered with additional transparency and darkened coloring, visually receding from the Value Area rows to communicate their reduced relative acceptance.
[*][i]Single Print Rows[/i]: Rows with exactly one TPO period print are highlighted in the high-density color with a distinct border, marking price levels visited by only one period that price may return to complete the auction.
[*][i]TPO Letters[/i]: Sequential alphabet letters within each row identify which periods traded through that price level, with the letter sequence providing a chronological audit trail of price movement across the profile window.
[*][i]3D Top Faces[/i]: Extruded top surfaces following the profile contour row by row provide depth cues that make the profile shape readable as a three-dimensional structure, with the contour step pattern revealing the distribution's outline in spatial form.
[*][i]3D Side Caps[/i]: End cap faces at the outer edge of each row close the extruded geometry and reinforce the row width differences through the depth dimension, with darker coloring distinguishing the side geometry from the front profile.
[*][i]3D Frame[/i]: The rear glass plane and wireframe perspective box orient the profile within three-dimensional chart space, connecting front and rear geometry with corner depth lines that establish the spatial extent of the distribution structure.
[*][i]POC Level[/i]: Dual glow and core lines extending from the profile mark the POC price for ongoing reference, with the glow providing visual prominence that makes the POC immediately identifiable against background price action.
[*][i]VAH and VAL Lines[/i]: Dotted lines at the Value Area boundaries mark the upper and lower edges of the high-acceptance zone for ongoing price interaction monitoring.
[*][i]IBH and IBL Lines[/i]: Dashed lines at the Initial Balance high and low mark the range established during the opening TPO periods, providing the conventional IB reference framework for range extension and balance monitoring.
[/list]
Profile shape, POC location, Value Area extent, single print density, and IB range collectively provide more structural context than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

3D Market Profile does not generate discrete entry or exit signals but provides continuous structural reference through the standard market profile analytical framework:
[list=1]
[*][i]POC Magnetic Reference[/i]: The POC level identifies the price where the greatest time-based acceptance occurred within the window, frequently acting as a mean reversion magnet when price extends to the Value Area boundaries.
[*][i]Value Area Boundary Interaction[/i]: Price moving outside the Value Area enters statistically less accepted price territory, providing context for potential reversion trades back toward the Value Area or range extension trades when acceptance establishes beyond the boundary.
[/list]
Initial Balance range interactions provide the conventional IB framework where price accepting above IBH or below IBL signals potential range extension, while price remaining within the IB range suggests balanced auction conditions.

[b]Strategy Integration[/b]

3D Market Profile fits within conventional market profile and auction theory-based analytical approaches:
[list]
[*][i]POC Reversion Framework[/i]: Use the POC line as a dynamic mean reversion reference when price has extended to or beyond the Value Area boundaries, with the POC representing the price where the distribution's greatest acceptance occurred and where reversion activity frequently concentrates.
[*][i]Value Area Boundary Trading[/i]: Monitor price behavior at VAH and VAL for acceptance or rejection signals. Price accepting above VAH or below VAL by closing multiple bars beyond the boundary suggests genuine range extension. Price rejecting at the boundaries and returning inside the Value Area suggests reversion continuation.
[*][i]Initial Balance Range Extension[/i]: Use IBH and IBL as directional range extension references. Price establishing acceptance above IBH with sustained closes indicates potential bullish range extension. Price accepting below IBL indicates potential bearish extension.
[*][i]Single Print Targeting[/i]: Treat single print rows as potential return targets for incomplete auction areas, monitoring for price to revisit and fill these levels with additional TPO participation in subsequent sessions.
[*][i]Profile Placement Selection[/i]: Use Right of Price placement to keep the profile in forward chart space as a live reference for current and upcoming price interaction. Use On Range placement to anchor the profile to the historical window for post-session analysis and retrospective structural assessment.
[*][i]Timeframe and Length Calibration[/i]: Match the TPO timeframe to the trading session type being analyzed. Thirty-minute TPOs with standard length produce a conventional daily profile. Shorter timeframes produce intraday micro-profiles. Longer timeframes produce multi-day macro profiles that reveal larger structural distribution patterns.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Period Aggregation[/i]: TPO clock-based grouping of chart bars into complete periods with high-low range accumulation and sequential letter assignment
[*][i]Distribution Builder[/i]: Per-row letter string accumulation and print count tracking across the full period set
[*][i]POC Selection[/i]: Maximum count identification with mid-range proximity tiebreaking for consistent level placement
[*][i]Value Area Engine[/i]: Outward expansion from POC with alternating upper and lower priority based on adjacent row count comparison
[*][i]3D Geometry[/i]: Polyline quadrilateral construction for top faces and side caps using depth bar and depth row offset coordinates
[*][i]Front Profile[/i]: Box objects with density gradient fill, POC override, single print override, and Value Area transparency differentiation
[*][i]Level System[/i]: Dual glow and core POC lines, dotted VA lines, dashed IB lines, and price readout labels at configurable tail length
[*][i]Performance Profile[/i]: Full object cleanup and rebuild on last bar with label count cap enforcement and configurable profile length maximum
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday micro-profile analysis with shorter length and faster TPO timeframe for session-level distribution tracking within a single trading day
[*][i]15 - 60 min[/i]: Session profile construction with standard thirty-minute TPO timeframe and balanced row count for conventional daily market profile analysis
[*][i]4H - Daily[/i]: Multi-session macro-profile analysis with longer length and higher TPO timeframe for structural distribution patterns spanning multiple sessions
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Length[/i]: 180
[*][i]Rows[/i]: 24
[*][i]Value Area %[/i]: 70
[*][i]Placement[/i]: Right of Price
[*][i]TPO Timeframe[/i]: 30
[*][i]Show TPO Letters[/i]: Enabled
[*][i]Initial Balance Periods[/i]: 2
[*][i]3D Depth (Bars)[/i]: 6
[*][i]3D Height (Rows)[/i]: 0.42
[*][i]Show 3D Frame[/i]: Enabled
[*][i]Show POC / VA[/i]: Enabled
[*][i]Show Initial Balance[/i]: Enabled
[*][i]Show Level Labels[/i]: Enabled
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's session structure, typical daily range, and preferred profile granularity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Too few or too many rows[/i]: Adjust Rows to increase or decrease vertical price resolution, calibrating row height to the instrument's typical daily range so rows represent meaningful price increments rather than noise-level or excessively large bands.
[*][i]Letters too cramped or too sparse[/i]: Adjust TPO Cell Width to control the horizontal space allocated to each letter, increasing for wider, more readable letter display or decreasing to fit more prints within the same profile width.
[*][i]Profile too narrow or too wide[/i]: The profile width scales automatically with the maximum row print count multiplied by cell width. Adjust Length to include more or fewer bars in the profile window, and adjust Cell Width to scale the resulting profile width.
[*][i]3D extrusion too deep or shallow[/i]: Adjust 3D Depth (Bars) to control horizontal perspective extent and 3D Height (Rows) to control vertical depth, calibrating the spatial effect to the chart's aspect ratio and current zoom level.
[*][i]Profile overlapping price action[/i]: Use Right of Price placement with a larger Right Offset value to push the profile further from current price, or switch to On Range placement to anchor it to the beginning of the analyzed window instead.
[*][i]Initial Balance range too narrow or wide[/i]: Adjust Initial Balance Periods to include more or fewer opening TPO periods in the IB calculation. Two periods represents the conventional first trading hour using thirty-minute TPOs; increase for a wider opening range definition.
[*][i]TPO timeframe mismatch[/i]: Match the TPO Timeframe to the session type being analyzed. Using a thirty-minute timeframe on a daily chart produces very few periods and minimal distribution differentiation; use a timeframe appropriate to the chart timeframe and session length.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Session-structured markets where a defined trading window produces a clear distribution with identifiable POC and Value Area that serve as reliable structural references across subsequent sessions
[*]Instruments with consistent daily range where row height calibrates to meaningful price increments and the distribution produces a recognizable bell-curve or skewed profile shape
[*]Market profile-based trading approaches where POC, Value Area, and Initial Balance provide the primary structural reference framework for directional bias and level interaction analysis
[*]Three-dimensional visualization workflows where the extruded profile geometry provides immediate spatial readability that improves structural assessment speed relative to flat two-dimensional profiles
[/list]
Reduced Effectiveness:
[list]
[*]Markets with highly variable daily ranges where a fixed row count produces inconsistent row heights across different sessions, reducing the comparability of distribution shapes between profile windows
[*]Instruments without clear session structure where the TPO period aggregation produces few complete periods within the profile length, resulting in sparse distributions with limited analytical differentiation
[*]Very short profile lengths where insufficient bars produce too few TPO periods to create a statistically meaningful distribution with identifiable POC and Value Area levels
[*]Extremely compressed consolidation environments where price trades within a narrow range and all rows receive similar print counts, producing a flat distribution without the structural differentiation that makes POC and Value Area meaningful
[*]Markets with frequent large gaps where the profile range is dominated by gap space rather than traded price, producing distributions with many empty rows that reduce the analytical value of the concentration levels
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, order flow analysis, or momentum indicators to validate POC and Value Area interactions with broader analytical context before acting on market profile reference levels
[*][i]POC Migration Tracking[/i]: Monitor whether successive profile POC levels are migrating higher, lower, or remaining stable as a secondary directional bias indicator. Consistently rising POC levels across multiple sessions suggest sustained upward value migration.
[*][i]Value Area Overlap Assessment[/i]: Compare Value Area ranges across successive profiles to assess whether price is finding acceptance in overlapping value zones, indicating market balance, or developing non-overlapping value areas, indicating directional value migration.
[*][i]Single Print Completion Monitoring[/i]: Track single print rows as potential return targets in subsequent sessions. The market profile principle that incomplete auctions tend to be revisited makes single prints valuable anticipatory reference levels for future price behavior.
[*][i]IB Range Context[/i]: Use the Initial Balance range as a daily bias anchor. Strong directional moves that establish acceptance well outside the IB range early in the session carry greater continuation probability than marginal IB extensions that quickly revert inside.
[/list]
[b]Disclaimer[/b]

3D Market Profile [BOSWaves] is a professional-grade TPO market profile visualization and auction theory analysis tool. It uses timeframe-based period aggregation with standard market profile methodology but does not predict future price movements. Results depend on market conditions, instrument session structure, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("3D Market Profile [BOSWaves]", overlay = true, max_polylines_count = 100, max_boxes_count = 100, max_lines_count = 100, max_labels_count = 500, calc_bars_count = 500, max_bars_back = 500)

// ┌────────────────────────────── BOSWaves ─ Groups ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gProfile = "Profile"
const string gTPO     = "TPO"
const string g3D      = "3D Rendering"
const string gLevels  = "Levels"
const string gVis     = "Display"

// ┌────────────────────────────── BOSWaves ─ Tooltips ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string tt_length      = "Number of chart bars included in the developing profile. The complete high-low range inside this window defines the profile."
const string tt_rows        = "Number of price rows used by the TPO distribution. Higher values increase price resolution; lower values produce broader rows."
const string tt_vaPct       = "Percentage of total TPO prints included in the Value Area around the Point of Control."
const string tt_placement   = "Right of Price places the profile in forward chart space. On Range anchors it to the beginning of the analyzed window."
const string tt_offset      = "Horizontal gap between current price and the profile."
const string tt_cellWidth   = "Horizontal width allocated to every individual TPO print. Increase this if letters appear too tightly packed."
const string tt_tpoTF       = "Timeframe defining one TPO period. Each completed period contributes one print to every price row traded through by its high-low range."
const string tt_letters     = "Print period letters inside each profile row. Disabling this leaves the density-shaded row blocks without letter overlays."
const string tt_letterSize  = "Display size of individual TPO letters. Small is recommended with a cell width of 2 or 3 bars."
const string tt_ibPeriods   = "Number of opening TPO periods used for Initial Balance. Two periods equals the conventional first hour when using 30-minute TPOs."
const string tt_depthX      = "Horizontal perspective offset of the extruded rear face."
const string tt_depthY      = "Vertical perspective offset expressed in profile-row heights."
const string tt_frame       = "Draw the rear glass plane and perspective wireframe around the profile."
const string tt_levels      = "Display Point of Control, Value Area High, Value Area Low and their reference levels."
const string tt_ib          = "Plot the Initial Balance high and low derived from the opening TPO periods of the analyzed window."
const string tt_labels      = "Print price readouts for Point of Control, Value Area and Initial Balance to the right of the profile."
const string tt_lblSize     = "Display size of the Point of Control, Value Area and Initial Balance price labels."
const string tt_levelTail   = "How many bars profile levels extend left of the profile face."
const string tt_single      = "Highlight rows containing only one TPO print."
const string tt_trans       = "Base transparency applied to profile rows. Rows outside the Value Area receive additional transparency on top of this value."
const string tt_lowCol      = "Color used for low-density TPO rows."
const string tt_highCol     = "Color used for high-density TPO rows."
const string tt_pocCol      = "Color used for the Point of Control row and reference."
const string tt_vaCol       = "Color used for Value Area references."
const string tt_ibCol       = "Color used for Initial Balance levels and labels."

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
int    profileLen  = input.int(180, "Length", minval = 40, maxval = 220, group = gProfile, tooltip = tt_length)
int    rows        = input.int(24, "Rows", minval = 10, maxval = 30, group = gProfile, tooltip = tt_rows)
float  vaPct       = input.float(70, "Value Area %", minval = 30, maxval = 90, step = 1, group = gProfile, tooltip = tt_vaPct) / 100
string placement   = input.string("Right of Price", "Placement", options = ["Right of Price", "On Range"], group = gProfile, tooltip = tt_placement)
int    rightOffset = input.int(8, "Right Offset", minval = 1, maxval = 30, group = gProfile, tooltip = tt_offset)
int    cellWidth   = input.int(2, "TPO Cell Width", minval = 1, maxval = 4, group = gProfile, tooltip = tt_cellWidth)

string tpoTF          = input.timeframe("30", "TPO Timeframe", group = gTPO, tooltip = tt_tpoTF)
bool   showLetters    = input.bool(true, "Show TPO Letters", group = gTPO, tooltip = tt_letters)
string letterSizeInput = input.string("Small", "Letter Size", options = ["Tiny", "Small", "Normal"], group = gTPO, tooltip = tt_letterSize)
bool   showSingles    = input.bool(true, "Highlight Single Prints", group = gTPO, tooltip = tt_single)
int    ibPeriods      = input.int(2, "Initial Balance Periods", minval = 1, maxval = 8, group = gTPO, tooltip = tt_ibPeriods)

int    depthBars = input.int(6, "3D Depth (Bars)", minval = 1, maxval = 16, group = g3D, tooltip = tt_depthX)
float  depthRows = input.float(0.42, "3D Height (Rows)", minval = -1.0, maxval = 1.0, step = 0.02, group = g3D, tooltip = tt_depthY)
bool   showFrame = input.bool(true, "Show 3D Frame", group = g3D, tooltip = tt_frame)

bool   showLevels  = input.bool(true, "Show POC / VA", group = gLevels, tooltip = tt_levels)
bool   showIB      = input.bool(true, "Show Initial Balance", group = gLevels, tooltip = tt_ib)
bool   showLabels  = input.bool(true, "Show Level Labels", group = gLevels, tooltip = tt_labels)
string lblSizeInput = input.string("Small", "Level Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gLevels, tooltip = tt_lblSize)
int    levelLength = input.int(8, "Level Tail", minval = 2, maxval = 30, group = gLevels, tooltip = tt_levelTail)

int    profileTrans = input.int(12, "Profile Transparency", minval = 0, maxval = 60, group = gVis, tooltip = tt_trans)
color  lowCol       = input.color(#532dff, "Low Density", inline = "d", group = gVis, tooltip = tt_lowCol)
color  highCol      = input.color(#00e5ff, "High Density", inline = "d", group = gVis, tooltip = tt_highCol)
color  pocCol       = input.color(#fff200, "POC", inline = "l", group = gVis, tooltip = tt_pocCol)
color  vaCol        = input.color(#ffffff, "VA", inline = "l", group = gVis, tooltip = tt_vaCol)
color  ibCol        = input.color(#ff9800, "IB", group = gVis, tooltip = tt_ibCol)

// ┌────────────────────────────── BOSWaves ─ Alphabet ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var string[] alpha = array.from(
     "A","B","C","D","E","F","G","H","I","J","K","L","M",
     "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l",
     "m","n","o","p","q","r","s","t","u","v","w","x","y","z")

// ┌────────────────────────────── BOSWaves ─ Helpers ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
darken(color c, float amount) =>
    color.rgb(
         color.r(c) * (1 - amount),
         color.g(c) * (1 - amount),
         color.b(c) * (1 - amount),
         color.t(c))

lighten(color c, float amount) =>
    color.rgb(
         color.r(c) + (255 - color.r(c)) * amount,
         color.g(c) + (255 - color.g(c)) * amount,
         color.b(c) + (255 - color.b(c)) * amount,
         color.t(c))

string letterSize = switch letterSizeInput
    "Normal" => size.normal
    "Small"  => size.small
    => size.tiny

string levelLblSize = switch lblSizeInput
    "Large"  => size.large
    "Normal" => size.normal
    "Small"  => size.small
    => size.tiny

int tpoClock = time(tpoTF)

// ┌────────────────────────────── BOSWaves ─ Drawing Storage ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var polyline[] activePolys = array.new<polyline>()
var box[]      activeBoxes = array.new<box>()
var line[]     activeLines = array.new<line>()
var label[]    activeLbls  = array.new<label>()

// ┌────────────────────────────── BOSWaves ─ Main Render ─────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if barstate.islast and bar_index >= profileLen
    for p in activePolys
        p.delete()
    activePolys.clear()

    for b in activeBoxes
        b.delete()
    activeBoxes.clear()

    for l in activeLines
        l.delete()
    activeLines.clear()

    for lb in activeLbls
        lb.delete()
    activeLbls.clear()

    // ── Full profile range ──
    float rangeHigh = high
    float rangeLow  = low

    for off = 0 to profileLen - 1
        rangeHigh := math.max(rangeHigh, high[off])
        rangeLow  := math.min(rangeLow, low[off])

    float rangeSpan = rangeHigh - rangeLow
    float rowH      = rangeSpan / rows

    if rowH > 0
        // ── Aggregate chart bars into complete TPO periods ──
        periodHighs = array.new<float>()
        periodLows  = array.new<float>()
        periodTimes = array.new<int>()

        int   currentTime = na
        float currentHigh = na
        float currentLow  = na

        for off = profileLen - 1 to 0
            int thisTime = tpoClock[off]

            if na(thisTime)
                continue

            if na(currentTime)
                currentTime := thisTime
                currentHigh := high[off]
                currentLow  := low[off]

            else if thisTime != currentTime
                periodTimes.push(currentTime)
                periodHighs.push(currentHigh)
                periodLows.push(currentLow)

                currentTime := thisTime
                currentHigh := high[off]
                currentLow  := low[off]

            else
                currentHigh := math.max(currentHigh, high[off])
                currentLow  := math.min(currentLow, low[off])

        if not na(currentTime)
            periodTimes.push(currentTime)
            periodHighs.push(currentHigh)
            periodLows.push(currentLow)

        int periodCount = periodHighs.size()

        if periodCount > 0
            // ── Build TPO distribution ──
            tpoCounts = array.new<int>(rows, 0)
            rowText   = array.new<string>(rows, "")

            float ibHigh = na
            float ibLow  = na

            for p = 0 to periodCount - 1
                float pHigh = periodHighs.get(p)
                float pLow  = periodLows.get(p)

                int loRow = int(math.floor((pLow - rangeLow) / rowH))
                int hiRow = int(math.floor((pHigh - rangeLow) / rowH))

                loRow := math.max(0, math.min(rows - 1, loRow))
                hiRow := math.max(0, math.min(rows - 1, hiRow))

                string letter = alpha.get(p % alpha.size())

                for row = loRow to hiRow
                    tpoCounts.set(row, tpoCounts.get(row) + 1)
                    rowText.set(row, rowText.get(row) + letter)

                if p < ibPeriods
                    ibHigh := na(ibHigh) ? pHigh : math.max(ibHigh, pHigh)
                    ibLow  := na(ibLow) ? pLow : math.min(ibLow, pLow)

            // ── Point of Control ──
            int   maxCount = 0
            int   pocRow   = -1
            float midPx    = (rangeHigh + rangeLow) * 0.5
            float bestDist = 1e10

            for row = 0 to rows - 1
                int cnt      = tpoCounts.get(row)
                float rowMid = rangeLow + (row + 0.5) * rowH
                float dist   = math.abs(rowMid - midPx)

                if cnt > maxCount or (cnt == maxCount and cnt > 0 and dist < bestDist)
                    maxCount := cnt
                    pocRow   := row
                    bestDist := dist

            int totalPrints = tpoCounts.sum()

            // ── Value Area ──
            int vaBot = pocRow
            int vaTop = pocRow
            int vaSum = pocRow >= 0 ? tpoCounts.get(pocRow) : 0

            float vaTarget = totalPrints * vaPct

            while vaSum < vaTarget and pocRow >= 0
                int lowerCount = vaBot > 0 ? tpoCounts.get(vaBot - 1) : -1
                int upperCount = vaTop < rows - 1 ? tpoCounts.get(vaTop + 1) : -1

                if lowerCount < 0 and upperCount < 0
                    break

                if upperCount > lowerCount and vaTop < rows - 1
                    vaTop += 1
                    vaSum += tpoCounts.get(vaTop)

                else if lowerCount > upperCount and vaBot > 0
                    vaBot -= 1
                    vaSum += tpoCounts.get(vaBot)

                else
                    if vaBot > 0
                        vaBot -= 1
                        vaSum += tpoCounts.get(vaBot)

                    if vaSum < vaTarget and vaTop < rows - 1
                        vaTop += 1
                        vaSum += tpoCounts.get(vaTop)

            // ── Profile geometry ──
            int rangeStartX = bar_index - profileLen + 1
            int profileX    = placement == "Right of Price" ? bar_index + rightOffset : rangeStartX
            int profileW    = maxCount * cellWidth
            int profileEndX = profileX + profileW

            float depthY = rowH * depthRows

            rowWidths = array.new<int>(rows, 0)
            rowFronts = array.new<color>(rows, color.new(chart.fg_color, 100))
            rowSides  = array.new<color>(rows, color.new(chart.fg_color, 100))
            rowTops   = array.new<color>(rows, color.new(chart.fg_color, 100))

            for row = 0 to rows - 1
                int cnt = tpoCounts.get(row)

                if cnt == 0
                    continue

                float density = maxCount > 0 ? float(cnt) / float(maxCount) : 0

                bool isPOC    = row == pocRow
                bool inVA     = row >= vaBot and row <= vaTop
                bool isSingle = cnt == 1

                color rawC = color.from_gradient(
                     math.pow(density, 0.72),
                     0,
                     1,
                     lowCol,
                     highCol)

                color frontC = isPOC ? color.new(pocCol, 3) :
                     isSingle and showSingles ? color.new(highCol, 8) :
                     inVA ? color.new(rawC, profileTrans) :
                     color.new(darken(rawC, 0.48), math.min(88, profileTrans + 34))

                color sideC = darken(frontC, 0.34)
                color topC  = lighten(frontC, 0.22)

                rowWidths.set(row, cnt * cellWidth)
                rowFronts.set(row, frontC)
                rowSides.set(row, sideC)
                rowTops.set(row, topC)

            // ── Rear glass plane ──
            if showFrame
                backPts = array.new<chart.point>()

                backPts.push(chart.point.from_index(
                     profileX + depthBars,
                     rangeLow + depthY))

                backPts.push(chart.point.from_index(
                     profileX + depthBars,
                     rangeHigh + depthY))

                backPts.push(chart.point.from_index(
                     profileEndX + depthBars,
                     rangeHigh + depthY))

                backPts.push(chart.point.from_index(
                     profileEndX + depthBars,
                     rangeLow + depthY))

                activePolys.push(polyline.new(
                     backPts,
                     closed = true,
                     curved = false,
                     line_color = na,
                     fill_color = color.new(chart.fg_color, 97)))

            // ── 3D horizontal faces ──
            if depthY >= 0
                for row = 0 to rows - 1
                    int w = rowWidths.get(row)

                    if w == 0
                        continue

                    float y2 = rangeLow + (row + 1) * rowH
                    color c  = rowTops.get(row)

                    topPts = array.new<chart.point>()

                    topPts.push(chart.point.from_index(profileX, y2))
                    topPts.push(chart.point.from_index(profileX + w, y2))
                    topPts.push(chart.point.from_index(profileX + w + depthBars, y2 + depthY))
                    topPts.push(chart.point.from_index(profileX + depthBars, y2 + depthY))

                    activePolys.push(polyline.new(
                         topPts,
                         closed = true,
                         curved = false,
                         line_color = color.new(c, 45),
                         fill_color = color.new(c, 8)))

            else
                for row = rows - 1 to 0
                    int w = rowWidths.get(row)

                    if w == 0
                        continue

                    float y1 = rangeLow + row * rowH
                    color c  = rowTops.get(row)

                    botPts = array.new<chart.point>()

                    botPts.push(chart.point.from_index(profileX, y1))
                    botPts.push(chart.point.from_index(profileX + w, y1))
                    botPts.push(chart.point.from_index(profileX + w + depthBars, y1 + depthY))
                    botPts.push(chart.point.from_index(profileX + depthBars, y1 + depthY))

                    activePolys.push(polyline.new(
                         botPts,
                         closed = true,
                         curved = false,
                         line_color = color.new(c, 45),
                         fill_color = color.new(c, 8)))

            // ── 3D row end caps ──
            if depthY >= 0
                for row = 0 to rows - 1
                    int w = rowWidths.get(row)

                    if w == 0
                        continue

                    float y1 = rangeLow + row * rowH
                    float y2 = y1 + rowH
                    color c  = rowSides.get(row)

                    sidePts = array.new<chart.point>()

                    sidePts.push(chart.point.from_index(profileX + w, y1))
                    sidePts.push(chart.point.from_index(profileX + w, y2))
                    sidePts.push(chart.point.from_index(profileX + w + depthBars, y2 + depthY))
                    sidePts.push(chart.point.from_index(profileX + w + depthBars, y1 + depthY))

                    activePolys.push(polyline.new(
                         sidePts,
                         closed = true,
                         curved = false,
                         line_color = color.new(c, 35),
                         fill_color = c))

            else
                for row = rows - 1 to 0
                    int w = rowWidths.get(row)

                    if w == 0
                        continue

                    float y1 = rangeLow + row * rowH
                    float y2 = y1 + rowH
                    color c  = rowSides.get(row)

                    sidePts = array.new<chart.point>()

                    sidePts.push(chart.point.from_index(profileX + w, y1))
                    sidePts.push(chart.point.from_index(profileX + w, y2))
                    sidePts.push(chart.point.from_index(profileX + w + depthBars, y2 + depthY))
                    sidePts.push(chart.point.from_index(profileX + w + depthBars, y1 + depthY))

                    activePolys.push(polyline.new(
                         sidePts,
                         closed = true,
                         curved = false,
                         line_color = color.new(c, 35),
                         fill_color = c))

            // ┌──────────────────────── BOSWaves ─ Front Profile ──────────────────────────┐
            // └────────────────────────────────────────────────────────────────────────────┘
            for row = 0 to rows - 1
                int w = rowWidths.get(row)

                if w == 0
                    continue

                int cnt = tpoCounts.get(row)

                float y1 = rangeLow + row * rowH
                float y2 = y1 + rowH

                bool isPOC    = row == pocRow
                bool inVA     = row >= vaBot and row <= vaTop
                bool isSingle = cnt == 1

                color frontC = rowFronts.get(row)

                color borderC = isPOC ? pocCol :
                     isSingle and showSingles ? highCol :
                     inVA ? color.new(frontC, 12) :
                     color.new(frontC, 58)

                activeBoxes.push(box.new(
                     left = profileX,
                     top = y2,
                     right = profileX + w,
                     bottom = y1,
                     bgcolor = frontC,
                     border_color = borderC,
                     border_width = isPOC or (isSingle and showSingles) ? 2 : 1))

            // ┌──────────────────────── BOSWaves ─ TPO Letters ────────────────────────────┐
            // └────────────────────────────────────────────────────────────────────────────┘
            if showLetters
                int letterLabels = 0
                int maxLetterLabels = 490

                for row = 0 to rows - 1
                    string txt = rowText.get(row)
                    int chars  = str.length(txt)

                    if chars == 0
                        continue

                    float rowMid = rangeLow + (row + 0.5) * rowH

                    bool isPOC    = row == pocRow
                    bool isSingle = chars == 1

                    color txtCol = isPOC ? color.black :
                         isSingle and showSingles ? color.white :
                         color.white

                    for c = 0 to chars - 1
                        if letterLabels >= maxLetterLabels
                            break

                        string ch = str.substring(txt, c, c + 1)

                        int cellLeft = profileX + c * cellWidth
                        int cellMid  = cellLeft + int(math.max(1, math.floor(cellWidth * 0.5)))

                        activeLbls.push(label.new(
                             x = cellMid,
                             y = rowMid,
                             text = ch,
                             xloc = xloc.bar_index,
                             yloc = yloc.price,
                             style = label.style_none,
                             textcolor = txtCol,
                             size = letterSize))

                        letterLabels += 1

            // ┌──────────────────────── BOSWaves ─ Structural Levels ──────────────────────┐
            // └────────────────────────────────────────────────────────────────────────────┘
            float pocPrice = rangeLow + (pocRow + 0.5) * rowH
            float vahPrice = rangeLow + (vaTop + 1) * rowH
            float valPrice = rangeLow + vaBot * rowH

            int levelX1 = profileX - levelLength
            int levelX2 = profileEndX + depthBars

            if showLevels
                activeLines.push(line.new(
                     levelX1,
                     pocPrice,
                     levelX2,
                     pocPrice,
                     color = color.new(pocCol, 72),
                     width = 7))

                activeLines.push(line.new(
                     levelX1,
                     pocPrice,
                     levelX2,
                     pocPrice,
                     color = pocCol,
                     width = 2))

                activeLines.push(line.new(
                     levelX1,
                     vahPrice,
                     levelX2,
                     vahPrice,
                     color = color.new(vaCol, 30),
                     style = line.style_dotted,
                     width = 1))

                activeLines.push(line.new(
                     levelX1,
                     valPrice,
                     levelX2,
                     valPrice,
                     color = color.new(vaCol, 30),
                     style = line.style_dotted,
                     width = 1))

            if showIB and not na(ibHigh) and not na(ibLow)
                activeLines.push(line.new(
                     levelX1,
                     ibHigh,
                     levelX2,
                     ibHigh,
                     color = color.new(ibCol, 30),
                     style = line.style_dashed,
                     width = 1))

                activeLines.push(line.new(
                     levelX1,
                     ibLow,
                     levelX2,
                     ibLow,
                     color = color.new(ibCol, 30),
                     style = line.style_dashed,
                     width = 1))

            // ┌──────────────────────── BOSWaves ─ 3D Wireframe ───────────────────────────┐
            // └────────────────────────────────────────────────────────────────────────────┘
            if showFrame
                color frameC = color.new(chart.fg_color, 76)

                int bx1 = profileX + depthBars
                int bx2 = profileEndX + depthBars

                float by1 = rangeLow + depthY
                float by2 = rangeHigh + depthY

                activeLines.push(line.new(profileX, rangeLow, profileX, rangeHigh, color = frameC))
                activeLines.push(line.new(profileX, rangeHigh, profileEndX, rangeHigh, color = frameC))
                activeLines.push(line.new(profileEndX, rangeHigh, profileEndX, rangeLow, color = frameC))
                activeLines.push(line.new(profileEndX, rangeLow, profileX, rangeLow, color = frameC))

                activeLines.push(line.new(bx1, by1, bx1, by2, color = frameC))
                activeLines.push(line.new(bx1, by2, bx2, by2, color = frameC))
                activeLines.push(line.new(bx2, by2, bx2, by1, color = frameC))
                activeLines.push(line.new(bx2, by1, bx1, by1, color = frameC))

                activeLines.push(line.new(profileX, rangeLow, bx1, by1, color = frameC))
                activeLines.push(line.new(profileX, rangeHigh, bx1, by2, color = frameC))
                activeLines.push(line.new(profileEndX, rangeHigh, bx2, by2, color = frameC))
                activeLines.push(line.new(profileEndX, rangeLow, bx2, by1, color = frameC))

            // ┌──────────────────────── BOSWaves ─ Level Labels ───────────────────────────┐
            // └────────────────────────────────────────────────────────────────────────────┘
            if showLabels
                int labelX = levelX2 + 2

                activeLbls.push(label.new(
                     labelX,
                     pocPrice,
                     "POC  " + str.tostring(pocPrice, format.mintick),
                     style = label.style_none,
                     textcolor = pocCol,
                     size = levelLblSize))

                activeLbls.push(label.new(
                     labelX,
                     vahPrice,
                     "VAH  " + str.tostring(vahPrice, format.mintick),
                     style = label.style_none,
                     textcolor = vaCol,
                     size = levelLblSize))

                activeLbls.push(label.new(
                     labelX,
                     valPrice,
                     "VAL  " + str.tostring(valPrice, format.mintick),
                     style = label.style_none,
                     textcolor = vaCol,
                     size = levelLblSize))

                if showIB and not na(ibHigh) and not na(ibLow)
                    activeLbls.push(label.new(
                         labelX,
                         ibHigh,
                         "IBH  " + str.tostring(ibHigh, format.mintick),
                         style = label.style_none,
                         textcolor = ibCol,
                         size = levelLblSize))

                    activeLbls.push(label.new(
                         labelX,
                         ibLow,
                         "IBL  " + str.tostring(ibLow, format.mintick),
                         style = label.style_none,
                         textcolor = ibCol,
                         size = levelLblSize))
````
