# Swing Gradient TPOs [BOSWaves]

- url: https://www.tradingview.com/script/ZTNPXC20-Swing-Gradient-TPOs-BOSWaves/
- type: indicator
- pine_id: PUB;227e7514b0d64cbcb23bddc9a2c19cf9
- version: 2.0

## Description

[b]Swing Gradient TPOs [BOSWaves] - Swing-Anchored Time Price Opportunity Profiles with Gradient Chronology and Single Print Detection[/b]

[b]Overview[/b]

Swing Gradient TPOs [BOSWaves] is a swing-anchored market profile system that constructs Time Price Opportunity profiles within each detected swing range, where letter assignment, gradient coloring, POC identification, and single print detection are driven by chronological time period progression across the swing rather than fixed session boundaries or arbitrary time windows.

[image]https://www.tradingview.com/x/3xUI39Ew/[/image]

Instead of applying TPO profiles to calendar sessions or user-defined time blocks, this system anchors each profile to the confirmed swing structure of the instrument itself, building a complete letter-by-letter participation map for every swing from high to low and low to high. Each time period within the swing receives a sequential alphabetical letter, and those letters are colored using a configurable gradient that visually encodes the chronological progression of price activity from swing origin to completion.

This creates a profile framework that reflects how participation distributed across price within each structural swing rather than within arbitrary time containers. The gradient coloring reveals whether price visited certain levels early or late in the swing's development, the POC identifies the price level with the greatest time-based participation, the value area captures the range containing the configured percentage of total activity, and single print zones mark levels touched by only a single time period and project them forward as potential reaction areas until price revisits them.

Price structure and participation distribution are therefore evaluated together, with each swing producing a self-contained profile that answers both where price spent time and when within the swing that activity occurred.

[b]Conceptual Framework[/b]

Swing Gradient TPOs is founded on the principle that TPO-based market profile analysis becomes structurally meaningful when profiles are anchored to confirmed swing boundaries rather than to session times that carry no relationship to the instrument's actual directional behavior.

Traditional market profile approaches build TPO distributions within daily or weekly sessions, which imposes a time container on the data that is independent of how price is actually behaving structurally. This framework replaces session-based profile construction with swing-event-driven profile building, where each profile begins at a confirmed swing extreme and ends at the next confirmed swing extreme in the opposing direction, ensuring the participation map covers exactly one complete directional structural move.

Three core principles guide the design:
[list=1]
[*]TPO profiles should be anchored to swing structure rather than calendar time, ensuring each profile captures participation within a single directional move rather than across an arbitrary time boundary that may span multiple structural events.
[*]Gradient coloring should encode chronological letter progression visually, revealing whether price visited particular levels early or late in the swing rather than treating all activity within the swing as temporally equivalent.
[*]Single print zones represent structurally significant levels visited by only one time period and should be projected forward as active reference areas until price returns to test them, at which point reclaim or rejection behavior provides actionable signal context.
[/list]
This shifts market profile analysis from session-container-based participation tracking into swing-anchored structural profile construction with gradient-encoded temporal intelligence and forward-projecting single print monitoring.

[b]Theoretical Foundation[/b]

The indicator combines swing high and low detection through highest and lowest lookback comparison, alphabetical letter assignment by configurable TPO timeframe period, three-color gradient interpolation for chronological letter coloring, POC identification through maximum TPO count per price bin, value area expansion from POC outward, single print detection and forward projection, and retest signal generation when price sweeps and reclaims a single print zone.

Swing detection tracks whether the most recent extreme high or low is the highest or lowest reading in the lookback window, registering a swing point when price rotates away from a prior extreme. TPO letter assignment maps each bar within the swing to a time period based on the ratio between the chart timeframe and the configured TPO timeframe, with sequential alphabet letters A through Z then a through z assigned chronologically across the swing's duration. Gradient coloring maps each letter's alphabetical index to a position along a three-stop gradient, producing a color sequence that progresses from swing start to swing end. Price bins are calculated from the swing range divided into segments sized relative to recent ATR, with each bin's letter count determining POC and value area membership.

Four internal systems operate in tandem:
[list]
[*][i]Swing Detection Engine[/i]: Tracks highest and lowest readings over the configurable lookback window, registering confirmed swing highs and lows when price rotates away from prior extremes and triggering profile construction on each swing direction change.
[*][i]TPO Profile Builder[/i]: Assigns sequential alphabetical letters to time periods within each swing, maps each bar's high and low range to the appropriate price bins, accumulates letter strings and counts per bin, and derives POC and value area from the resulting distribution.
[*][i]Gradient Chronology Engine[/i]: Maps each letter's sequential index to a position along a configurable three-stop gradient, producing coloring that encodes when within the swing each price level was visited rather than applying uniform directional color across the entire profile.
[*][i]Single Print Detection and Signal System[/i]: Identifies price bins touched by exactly one time period letter, projects those zones forward as extended boxes until price revisits them, monitors for sweep-and-reclaim behavior with configurable cooldown, and generates directional retest signals when qualifying conditions are met.
[/list]
This design allows each swing to produce a complete participation profile with temporal depth encoded visually, while structurally significant single print zones remain active as forward reference areas with signal generation capability.

[b]How It Works[/b]

Swing Gradient TPOs evaluates price through a sequence of structure-aware and profile-building processes:
[list=1]
[*][i]Swing Direction Tracking[/i]: On each bar, price is compared against the highest high and lowest low over the configured lookback. When the current high matches the lookback high, the swing is classified as transitioning to a downswing. When the current low matches the lookback low, it is classified as transitioning to an upswing.
[*][i]Swing Point Registration[/i]: When price rotates away from a prior extreme, the swing point price and bar index are recorded for both highs and lows independently, maintaining the most recent confirmed swing high and low as profile anchors.
[*][i]Profile Build Trigger[/i]: When swing direction changes, a profile build is triggered using the recorded swing high and low as boundaries, constructing the complete TPO distribution for the completed swing.
[*][i]Price Bin Calculation[/i]: The swing range is divided into bins sized relative to a smoothed ATR-derived tick amount, capped at 80 bins to maintain visual clarity and computational efficiency.
[*][i]Letter Assignment and Accumulation[/i]: Each bar within the swing is mapped to a time period letter based on the ratio of the configured TPO timeframe to the chart timeframe. For each bar, its high and low determine which price bins it touches, and the period letter is appended to each qualifying bin's letter string if not already present.
[*][i]POC Identification[/i]: The bin with the greatest accumulated letter count is identified as the Point of Control, representing the price level with the most time-based participation across the swing.
[*][i]Value Area Expansion[/i]: Starting from the POC bin, the value area expands outward by adding the adjacent bin with the greater letter count, continuing until the accumulated count reaches the configured value area percentage of total swing activity.
[*][i]Gradient Color Mapping[/i]: Each letter's alphabetical index is divided by the maximum period index to produce a normalized position along the three-stop gradient, assigning colors that progress from the gradient start color early in the swing to the gradient end color late in the swing.
[*][i]Single Print Identification and Projection[/i]: Bins with exactly one letter in their string are classified as single prints and, when the extension setting is enabled, receive forward-projecting zone boxes that extend rightward on each bar until price enters the zone.
[*][i]Single Print Sweep and Reclaim Detection[/i]: When price enters a single print zone the zone is marked as swept. If price then exits the zone in the opposing direction and closes beyond the zone boundary with sufficient cooldown observed, a directional retest signal is generated.
[*][i]Real-Time Profile Rendering[/i]: On the last bar, the developing swing from the most recent confirmed extreme to current price is rendered as a live TPO profile that updates with each new bar, providing a continuously refreshing participation map for the current incomplete swing.
[/list]
Together, these elements form a continuously updating swing profile system where each completed swing produces a gradient-encoded participation map, single print zones project forward as active structural references, and retest signals identify price reclaims of structurally thin areas.

[b]Interpretation[/b]

Swing Gradient TPOs should be interpreted as a swing-anchored participation distribution system with temporal depth encoding and forward-projecting structural reference zones:
[list]
[*][i]TPO Letter Boxes[/i]: Each lettered box represents a single time period's visit to that price level within the swing. The letter itself identifies which time period made the visit, and the gradient color reveals where in the swing's chronological sequence that period falls.
[*][i]Gradient Coloring[/i]: The gradient progression from swing start to swing end colors early-swing activity in the gradient start color and late-swing activity in the gradient end color, visually encoding whether price visited each level early or late in the structural move.
[*][i]Point of Control (POC)[/i]: The horizontal line through the price level with the most accumulated TPO letters represents the level where price spent the greatest amount of time within the swing, acting as a gravitational reference for the swing's dominant auction zone.
[*][i]Value Area[/i]: The vertical line at the swing origin spanning the value area high and low with dotted horizontal boundary projections marks the price range containing the configured percentage of total swing TPO activity, identifying the zone of concentrated acceptance during the swing.
[*][i]Single Print Zones (Highlighted)[/i]: Price bins touched by exactly one time period letter are visually distinguished within the profile, indicating levels that price passed through quickly without sustained participation, representing structurally thin areas vulnerable to future reaction.
[*][i]Single Print Extensions (Projected)[/i]: When extension is enabled, single print zones project forward as shaded boxes beyond the swing boundary, maintaining active visual reference until price revisits the zone and the extension is consumed.
[*][i]Retest Signals[/i]: Arrow signals generated when price sweeps through an extended single print zone and then reclaims it by closing beyond the zone boundary, identifying potential continuation opportunities at structurally thin levels that have now been tested and defended.
[*][i]Real-Time Profile[/i]: The developing profile on the current incomplete swing updates continuously with each new bar, providing a live participation map anchored to the most recent confirmed swing extreme using the same gradient, POC, and value area logic as completed historical swings.
[/list]
POC location, value area boundaries, gradient temporal distribution, and single print zone positioning collectively provide more structural and participatory intelligence than any element in isolation.

[b]Signal Logic & Visual Cues[/b]

Swing Gradient TPOs presents two retest signal types derived from single print zone interaction:
[list=1]
[*][i]Bullish Single Print Reclaim[/i]: Generated when price sweeps into a bullish single print zone from an upswing and subsequently closes above the zone's upper boundary, indicating the structurally thin area has been swept and reclaimed with bullish resolution.
[*][i]Bearish Single Print Rejection[/i]: Generated when price sweeps into a bearish single print zone from a downswing and subsequently closes below the zone's lower boundary, indicating the structurally thin area has been swept and rejected with bearish resolution.
[/list]
Both signal types require the zone to have been swept before reclaim or rejection can register, and a configurable cooldown enforces minimum bar separation between consecutive signals to prevent clustering during active zone interaction.

Alert generation covers completed swing high and swing low events as well as bullish and bearish single print reclaim signals for systematic structural and zone-based monitoring workflows.

[b]Strategy Integration[/b]

Swing Gradient TPOs fits within market profile-informed and structure-based participation analysis approaches:
[list]
[*][i]POC Reaction Trading[/i]: Monitor price behavior when it returns to a prior swing's POC level. The POC represents the most accepted price within the swing and frequently acts as a reference for future support, resistance, or reversion behavior.
[*][i]Value Area Boundary Framing[/i]: Use value area high and low projections as structural boundary references, with price outside the value area representing potential imbalance and price returning to the value area suggesting reversion toward prior acceptance.
[*][i]Single Print Zone Trading[/i]: Use extended single print zones as anticipatory structural references, monitoring price behavior on approach for the sweep-and-reclaim or sweep-and-reject patterns that trigger retest signals.
[*][i]Gradient Temporal Analysis[/i]: Use gradient distribution within each swing to assess whether participation at key levels occurred early or late in the move. Heavily late-swing activity at a level suggests climactic behavior, while early-swing concentration may indicate initial acceptance or rejection zones.
[*][i]Real-Time Profile Monitoring[/i]: Use the developing live profile to assess current swing participation distribution in real time, identifying emerging POC levels and single prints within the active structural move before it completes.
[*][i]Multi-Swing Profile Comparison[/i]: Compare POC locations, value area widths, and single print density across successive swings to assess whether participation is concentrating or dispersing as the broader trend develops.
[/list]
[b]Technical Implementation Details[/b]
[list]
[*][i]Swing Detection[/i]: Highest and lowest lookback comparison with direction tracking and confirmed extreme registration on price rotation
[*][i]TPO Construction[/i]: Alphabetical letter assignment by timeframe-ratio-derived period with per-bin letter string accumulation and count tracking
[*][i]Profile Analytics[/i]: Maximum count POC identification, outward value area expansion to configurable percentage threshold, and single print bin classification
[*][i]Gradient Engine[/i]: Three-stop gradient interpolation with letter index normalized to maximum period for chronological color mapping
[*][i]Single Print System[/i]: Array-managed forward-projecting zone boxes with sweep state tracking, reclaim direction testing, and cooldown-gated signal generation
[*][i]Real-Time Rendering[/i]: Last-bar-triggered live profile construction rebuilding on every bar update with independent box and line arrays cleared and redrawn each render cycle
[*][i]Visualization[/i]: Per-letter TPO boxes with gradient, POC, and value area coloring, POC dual-line overlay, value area vertical and horizontal boundary lines, single print zone extensions, and retest signal arrows
[*][i]Performance Profile[/i]: Optimized with calc_bars_count and max_bars_back configuration and array size caps for object management across extended histories
[/list]
[b]Optimal Application Parameters[/b]

Timeframe Guidance:
[list]
[*][i]1 - 5 min[/i]: Intraday swing profile mapping with shorter swing length and faster TPO timeframe for responsive participation tracking within intraday structural moves
[*][i]15 - 60 min[/i]: Session-level swing profile analysis with balanced swing length and TPO timeframe producing meaningful letter distributions across typical session swings
[*][i]4H - Daily[/i]: Swing-level structural participation mapping with longer swing detection and higher TPO timeframe for profiles that reflect multi-day directional move participation
[/list]
Suggested Baseline Configuration:
[list]
[*][i]Swing Length[/i]: 12
[*][i]TPO Timeframe[/i]: 30
[*][i]Box Width[/i]: 2
[*][i]Show POC[/i]: Enabled
[*][i]Show Value Area[/i]: Enabled
[*][i]Value Area %[/i]: 70
[*][i]Gradient Preset[/i]: Sunset
[*][i]Highlight Single Prints[/i]: Enabled
[*][i]Extend Single Prints[/i]: Enabled
[*][i]Show Retest Signals[/i]: Enabled
[*][i]Signal Cooldown[/i]: 5
[/list]
These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's swing frequency, typical swing range, and preferred profile granularity, so fine-tuning is expected for optimal performance.

[b]Parameter Calibration Notes[/b]

Use the following adjustments to refine behavior without altering the core logic:
[list]
[*][i]Swings too frequent[/i]: Increase Swing Length to require more bars on each side of an extreme before it registers as a confirmed swing point, filtering minor oscillations and producing fewer, more structurally significant profiles.
[*][i]Swings too infrequent[/i]: Decrease Swing Length toward 10 for more sensitive swing detection, producing profiles on smaller structural moves within the overall trend.
[*][i]Too few letters per profile[/i]: Decrease TPO Timeframe to assign letters to shorter time periods, increasing letter density within each swing and producing more granular participation distributions.
[*][i]Too many letters cluttering the profile[/i]: Increase TPO Timeframe so each letter covers a longer period, reducing letter density and producing cleaner, more readable profiles on the target timeframe.
[*][i]Profile bins too coarse[/i]: The bin count derives from the swing range divided by a smoothed ATR-based tick size. On instruments with large typical bar ranges relative to the swing, the profile may appear coarse. Consider using a higher timeframe chart or adjusting swing length to capture larger swings with more granular bin resolution.
[*][i]Too many single print signals[/i]: Increase Signal Cooldown to enforce greater bar separation between consecutive retest signals, or increase Swing Length to produce swings with fewer single print zones through greater overall participation density.
[*][i]Single print extensions cluttering the chart[/i]: Disable Extend Single Prints to remove forward projection boxes while retaining single print highlighting within the historical profile, or reduce Max Zones (capped internally at 50) by allowing older zones to naturally expire as price revisits them.
[/list]
Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

[b]Performance Characteristics[/b]

High Effectiveness:
[list]
[*]Trending markets with clear directional swings where each profile captures a single sustained move and produces meaningful POC and value area levels that serve as ongoing structural references
[*]Instruments with sufficient intrabar participation where TPO letter accumulation produces well-distributed profiles with identifiable concentration zones rather than sparse single-print-dominated structures
[*]Market profile-based trading approaches that benefit from swing-anchored rather than session-anchored participation context, aligning profile boundaries with actual structural events
[*]Single print zone strategies where structurally thin levels within completed swings provide anticipatory reference areas for future price reactions with defined signal criteria
[/list]
Reduced Effectiveness:
[list]
[*]Choppy, low-range markets where frequent swing direction changes produce thin profiles with minimal letter accumulation and limited POC or value area differentiation
[*]Extremely fast-moving instruments where swing ranges are so large relative to the TPO timeframe that letters are thinly distributed across a wide range, reducing profile interpretive value
[*]Low-liquidity instruments where participation is insufficient to produce meaningful time-at-price distributions, resulting in profiles dominated by single prints with no identifiable acceptance zones
[*]Markets where the relationship between swing structure and participation distribution is inconsistent, reducing the reliability of POC and value area levels as structural references across successive swings
[*]Very short timeframe charts where the ratio between chart timeframe and TPO timeframe produces insufficient letter differentiation to build interpretable profiles within typical swing durations
[/list]
[b]Integration Guidelines[/b]
[list]
[*][i]Confluence[/i]: Combine with BOSWaves structural tools, order flow analysis, or momentum indicators to validate POC and value area reactions with broader analytical context before acting on profile-based reference levels
[*][i]POC Migration Awareness[/i]: Track whether POC levels across successive swings are migrating higher, lower, or remaining stable as a secondary indicator of directional participation bias beyond raw trend direction
[*][i]Single Print Zone Patience[/i]: Allow single print zones to extend and be approached naturally rather than anticipating reactions prematurely. The sweep-and-reclaim or sweep-and-reject sequence that triggers signals requires zone interaction to complete before directional evidence is confirmed.
[*][i]Gradient Reading[/i]: Use gradient distribution within profiles to contextualize POC and value area location. A POC formed late in the gradient sequence suggests late-swing acceptance, potentially indicating exhaustion. An early-forming POC suggests early directional commitment that may carry more structural weight.
[*][i]Real-Time Profile Monitoring[/i]: Treat the live developing profile as probabilistic rather than confirmed. POC and value area locations in the real-time profile will shift as new bars are added and should be interpreted as dynamic rather than fixed until the swing completes and the historical profile is committed.
[/list]
[b]Disclaimer[/b]

Swing Gradient TPOs [BOSWaves] is a professional-grade swing-anchored market profile and structural participation analysis tool. It uses TPO letter accumulation with gradient chronology encoding and single print zone projection but does not predict future price movements. Results depend on market conditions, instrument participation characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates momentum context, order flow analysis, and comprehensive risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Swing Gradient TPOs [BOSWaves]", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500,
     calc_bars_count = 2000, max_bars_back = 5000)

// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string gSwing = "Swing Detection"
const string gTPO   = "TPO Profile"
const string gStyle = "Style"
const string gSP    = "Single Prints"
const string gSig   = "Signals"
const string gVis   = "Colors"

int    swingLen  = input.int(12, "Swing Length", minval = 10, maxval = 200, group = gSwing,
     tooltip = "Lookback for detecting swing highs and lows.")
string tpoTF     = input.timeframe("30", "TPO Timeframe", group = gTPO,
     tooltip = "Each period at this timeframe gets a letter.")
int    boxWidth  = input.int(2, "Box Width", minval = 1, maxval = 5, group = gTPO,
     tooltip = "Width of each TPO letter box in bars.")
bool   showPOC   = input.bool(true, "Show POC", group = gTPO)
bool   showVA    = input.bool(true, "Show Value Area", group = gTPO)
float  vaPct     = input.float(70, "Value Area %", minval = 30, maxval = 90, group = gTPO) / 100
string txtSize   = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = gTPO)

string gradPreset = input.string("Sunset", "Gradient Preset",
     options = ["None", "Sunset", "Ocean", "Neon", "Earth", "Monochrome", "Custom"], group = gStyle,
     tooltip = "None uses flat swing colors. Choose a preset or Custom for your own.")
color  gradCustS = input.color(#ff5252, "Custom Start", inline = "gr", group = gStyle)
color  gradCustM = input.color(#74ffbc, "Custom Mid", inline = "gr", group = gStyle)
color  gradCustE = input.color(#651fff, "Custom End", inline = "gr", group = gStyle)
string boxBG     = input.string("Transparent", "Box Background", options = ["Transparent", "Custom"], group = gStyle)
color  boxBGcol  = input.color(#000000, "Custom BG Color", group = gStyle)
int    boxBGalp  = input.int(30, "Custom BG Transparency", minval = 0, maxval = 90, group = gStyle)

bool   showSP    = input.bool(true, "Highlight Single Prints", group = gSP)
bool   extendSP  = input.bool(true, "Extend Single Prints", group = gSP,
     tooltip = "Projects single print zones forward until price revisits them.")

bool   showSig   = input.bool(true, "Show Retest Signals", group = gSig,
     tooltip = "Plots an arrow when price sweeps through a single print zone and reclaims it.")
int    sigCD     = input.int(5, "Signal Cooldown", minval = 1, maxval = 30, group = gSig,
     tooltip = "Minimum bars between consecutive signals.")

color  upCol     = input.color(#00ff00, "Up Swing", inline = "c", group = gVis)
color  dnCol     = input.color(#ff0000, "Down Swing", inline = "c", group = gVis)
color  pocCol    = input.color(#FFEB3B, "POC", group = gVis)
color  vaCol     = input.color(#74ffbc, "Value Area", group = gVis)
color  spCol     = input.color(#ff7474, "Single Print", group = gVis)

// ┌────────────────────────────── BOSWaves ─ Gradient Resolution ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
bool useGrad = gradPreset != "None"

[gradStart, gradMid, gradEnd] = switch gradPreset
    "Sunset"     => [color.rgb(255, 82, 82),   color.rgb(255, 167, 38),  color.rgb(255, 235, 59)]
    "Ocean"      => [color.rgb(0, 150, 136),    color.rgb(3, 169, 244),   color.rgb(101, 31, 255)]
    "Neon"       => [color.rgb(255, 0, 110),    color.rgb(0, 255, 136),   color.rgb(0, 200, 255)]
    "Earth"      => [color.rgb(141, 110, 99),   color.rgb(174, 159, 56),  color.rgb(56, 142, 60)]
    "Monochrome" => [color.rgb(180, 180, 180),  color.rgb(255, 255, 255), color.rgb(120, 120, 120)]
    "Custom"     => [gradCustS, gradCustM, gradCustE]
    => [gradCustS, gradCustM, gradCustE]

// ┌────────────────────────────── BOSWaves ─ Helpers ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
sz = switch txtSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal

bool useCustomBG = boxBG == "Custom"

var string[] alphabet = array.from(
     "A","B","C","D","E","F","G","H","I","J","K","L","M",
     "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
     "a","b","c","d","e","f","g","h","i","j","k","l",
     "m","n","o","p","q","r","s","t","u","v","w","x","y","z")

int alphaSize = alphabet.size()

f_grad3(float t, color c1, color c2, color c3) =>
    t <= 0.5 ? color.from_gradient(t, 0, 0.5, c1, c2) : color.from_gradient(t, 0.5, 1, c2, c3)

// ┌────────────────────────────── BOSWaves ─ Swing Detection ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
type SwingPt
    float price
    int   idx

var SwingPt hiPt = SwingPt.new(na, na)
var SwingPt loPt = SwingPt.new(na, na)
var bool isDown  = false

float hh = ta.highest(high, swingLen)
float ll = ta.lowest(low, swingLen)

if high == hh
    isDown := true
if low == ll
    isDown := false

if high[1] == hh[1] and high < hh
    hiPt.idx   := bar_index - 1
    hiPt.price := high[1]

if low[1] == ll[1] and low > ll
    loPt.idx   := bar_index - 1
    loPt.price := low[1]

// ┌────────────────────────────── BOSWaves ─ Tick Size ──────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float rawTick = ta.atr(200) * 0.5
float tickAmt = na(rawTick) or rawTick <= 0 ? syminfo.mintick * 100 : rawTick

var histBoxes  = array.new<box>()
var histLines  = array.new<line>()
var histLabels = array.new<label>()
var rtBoxes    = array.new<box>()
var rtLines    = array.new<line>()

// Single print zone tracking
var spPrices = array.new<float>()
var spTops   = array.new<float>()
var spBots   = array.new<float>()
var spBoxes  = array.new<box>()
var spSwept  = array.new<bool>()
var spSide   = array.new<int>()

// Signal tracking
var int lastSigBar = 0
bool bullSig = false
bool bearSig = false

// ┌────────────────────────────── BOSWaves ─ SP Zone Management ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if spBoxes.size() > 0
    for i = spBoxes.size() - 1 to 0
        box   bx    = spBoxes.get(i)
        float mid   = spPrices.get(i)
        float top   = spTops.get(i)
        float bot   = spBots.get(i)
        bool  swept = spSwept.get(i)
        int   side  = spSide.get(i)

        bool priceInZone = high >= bot and low <= top

        if not swept and priceInZone
            spSwept.set(i, true)

        else if swept and not priceInZone
            bool cdOk = (bar_index - lastSigBar) >= sigCD

            if showSig and cdOk
                if side == 1 and close > top
                    bullSig    := true
                    lastSigBar := bar_index

                if side == -1 and close < bot
                    bearSig    := true
                    lastSigBar := bar_index

            bx.delete()
            spBoxes.remove(i)
            spPrices.remove(i)
            spTops.remove(i)
            spBots.remove(i)
            spSwept.remove(i)
            spSide.remove(i)
            continue

        if extendSP
            bx.set_right(bar_index)

while spBoxes.size() > 50
    spBoxes.shift().delete()
    spPrices.shift()
    spTops.shift()
    spBots.shift()
    spSwept.shift()
    spSide.shift()

// ┌────────────────────────────── BOSWaves ─ Build Historical TPO ───────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
buildSwingTPO(int startIdx, int endIdx, float swBot, float swTop, color swCol, bool isDn) =>
    float range_ = swTop - swBot

    if range_ > tickAmt and range_ > 0
        int binCount = math.min(80, math.max(1, int(range_ / tickAmt)))
        float step   = range_ / binCount
        int prevIdx  = math.min(startIdx, endIdx)
        int nextIdx  = math.max(startIdx, endIdx)
        int barOff   = bar_index - nextIdx
        int totalBars = nextIdx - prevIdx

        if totalBars > 0 and binCount > 0
            letters  = array.new<string>(binCount, "")
            counts   = array.new<int>(binCount, 0)
            buyCount = array.new<int>(binCount, 0)
            selCount = array.new<int>(binCount, 0)

            int desiredTF     = timeframe.in_seconds(tpoTF)
            int chartTF       = timeframe.in_seconds()
            int barsPerPeriod = math.max(1, desiredTF / chartTF)

            int maxPeriods = int(math.ceil(float(totalBars) / barsPerPeriod))
            if maxPeriods > alphaSize
                barsPerPeriod := int(math.ceil(float(totalBars) / alphaSize))

            int actualMaxPeriod = 0

            for i = barOff to barOff + totalBars
                if i < 0
                    continue

                int barNum    = i - barOff
                int letterIdx = int(barNum / barsPerPeriod)

                if letterIdx >= alphaSize
                    continue

                if letterIdx > actualMaxPeriod
                    actualMaxPeriod := letterIdx

                string letter = alphabet.get(letterIdx)
                float h = high[i]
                float l = low[i]

                if na(h) or na(l)
                    continue

                bool isBuy = close[i] > open[i]

                int kStart = int(math.max(0, math.floor((l - swBot) / step)))
                int kEnd   = int(math.min(binCount - 1, math.floor((h - swBot) / step)))
                kStart    := math.max(0, math.min(kStart, binCount - 1))
                kEnd      := math.max(0, math.min(kEnd, binCount - 1))

                if kStart <= kEnd
                    for k = kStart to kEnd
                        string existing = letters.get(k)
                        if not str.contains(existing, letter)
                            letters.set(k, existing + letter)
                            counts.set(k, counts.get(k) + 1)
                            if isBuy
                                buyCount.set(k, buyCount.get(k) + 1)
                            else
                                selCount.set(k, selCount.get(k) + 1)

            int maxTPO = counts.size() > 0 ? counts.max() : 0
            float maxPeriodF = math.max(1., float(actualMaxPeriod))

            if maxTPO > 0
                int sumTPO = counts.sum()
                int pocK   = counts.indexof(maxTPO)

                if pocK >= 0 and pocK < binCount
                    int vaBot = pocK
                    int vaTop = pocK
                    int vaSum = counts.get(pocK)
                    float vaThresh = sumTPO * vaPct

                    while vaSum < vaThresh
                        float addBot = vaBot > 0 ? counts.get(vaBot - 1) : 0
                        float addTop = vaTop < binCount - 1 ? counts.get(vaTop + 1) : 0
                        if addBot >= addTop and vaBot > 0
                            vaBot -= 1
                            vaSum += counts.get(vaBot)
                        else if vaTop < binCount - 1
                            vaTop += 1
                            vaSum += counts.get(vaTop)
                        else
                            break

                    int spCount = 0

                    for k = 0 to binCount - 1
                        string ltrs = letters.get(k)
                        int cnt     = counts.get(k)
                        if cnt <= 0
                            continue

                        float bBot = swBot + k * step
                        float bTop = bBot + step
                        float bMid = math.avg(bBot, bTop)
                        bool isPOC = k == pocK
                        bool inVA  = k >= vaBot and k <= vaTop
                        bool isSP  = cnt == 1

                        if isSP
                            spCount += 1

                        int strLen = str.length(ltrs)
                        if strLen > 0
                            for c = 0 to strLen - 1
                                string ch = str.substring(ltrs, c, c + 1)
                                int left  = prevIdx + c * boxWidth
                                int right = left + boxWidth

                                int alpIdx  = alphabet.indexof(ch)
                                float gradT = alpIdx >= 0 ? float(alpIdx) / maxPeriodF : 0.5

                                color bgC = na
                                color bdC = na
                                color txC = na

                                if isPOC
                                    bgC := useCustomBG ? color.new(boxBGcol, boxBGalp) : color.new(pocCol, 10)
                                    bdC := color.new(pocCol, 20)
                                    txC := useCustomBG ? pocCol : color.black
                                else if isSP and showSP
                                    bgC := useCustomBG ? color.new(boxBGcol, boxBGalp) : color.new(spCol, 25)
                                    bdC := color.new(spCol, 40)
                                    txC := useCustomBG ? spCol : color.white
                                else if useGrad
                                    color gCol = f_grad3(gradT, gradStart, gradMid, gradEnd)
                                    int trn = inVA ? 15 : 40
                                    bgC := useCustomBG ? color.new(boxBGcol, boxBGalp) : color.new(gCol, trn)
                                    bdC := color.new(gCol, inVA ? 40 : 65)
                                    txC := useCustomBG ? gCol : color.white
                                else if inVA
                                    bgC := useCustomBG ? color.new(boxBGcol, boxBGalp) : color.new(swCol, 20)
                                    bdC := color.new(swCol, 60)
                                    txC := useCustomBG ? swCol : color.white
                                else
                                    bgC := useCustomBG ? color.new(boxBGcol, boxBGalp + 20) : color.new(swCol, 55)
                                    bdC := color.new(swCol, 85)
                                    txC := useCustomBG ? color.new(swCol, 30) : color.new(color.white, 40)

                                histBoxes.push(box.new(left, bTop, right, bBot,
                                     border_color = bdC,
                                     bgcolor = bgC,
                                     text = ch,
                                     text_color = txC,
                                     text_size = sz,
                                     border_width = 1))

                        if isSP and showSP and extendSP
                            int spStart = prevIdx + strLen * boxWidth
                            spPrices.push(bMid)
                            spTops.push(bTop)
                            spBots.push(bBot)
                            spSwept.push(false)
                            spSide.push(isDn ? -1 : 1)
                            spBoxes.push(box.new(spStart, bTop, bar_index, bBot,
                                 bgcolor = color.new(spCol, 88),
                                 border_color = color.new(spCol, 70),
                                 border_width = 1))

                    if showPOC
                        float pocPrice = swBot + pocK * step + step * 0.5
                        histLines.push(line.new(prevIdx, pocPrice, nextIdx, pocPrice,
                             color = color.new(pocCol, 60), width = 5))
                        histLines.push(line.new(prevIdx, pocPrice, nextIdx, pocPrice,
                             color = pocCol, width = 2))

                    if showVA
                        float vaTopP = swBot + (vaTop + 1) * step
                        float vaBotP = swBot + vaBot * step

                        histLines.push(line.new(prevIdx, vaTopP, prevIdx, vaBotP,
                             color = color.new(vaCol, 70), width = 7))
                        histLines.push(line.new(prevIdx, vaTopP, prevIdx, vaBotP,
                             color = vaCol, width = 3))

                        histLines.push(line.new(prevIdx, vaTopP, nextIdx, vaTopP,
                             color = color.new(vaCol, 50), width = 1, style = line.style_dotted))
                        histLines.push(line.new(prevIdx, vaBotP, nextIdx, vaBotP,
                             color = color.new(vaCol, 50), width = 1, style = line.style_dotted))

                    int totalBuys = buyCount.sum()
                    int totalSels = selCount.sum()
                    float deltaPct = (totalBuys + totalSels) > 0 ?
                         (totalBuys - totalSels) / (totalBuys + totalSels) * 100 : 0.

                    string tip = "TPO Count: " + str.tostring(sumTPO) +
                         "\nPOC: " + str.tostring(swBot + pocK * step + step * 0.5, format.mintick) +
                         "\nVA: " + str.tostring(vaPct * 100, "#") + "%" +
                         "\nSingle Prints: " + str.tostring(spCount) +
                         "\nDelta: " + str.tostring(deltaPct, "#.0") + "%"

// ┌────────────────────────────── BOSWaves ─ Trigger Historical ─────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if isDown != isDown[1]
    float swBot = math.min(hiPt.price, loPt.price)
    float swTop = math.max(hiPt.price, loPt.price)

    if not na(swBot) and not na(swTop) and swTop > swBot
        buildSwingTPO(hiPt.idx, loPt.idx, swBot, swTop,
             isDown ? dnCol : upCol, isDown)

// ┌────────────────────────────── BOSWaves ─ Real-Time Swing TPO ────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
for b in rtBoxes
    b.delete()
rtBoxes.clear()
for ln in rtLines
    ln.delete()
rtLines.clear()

if barstate.islast
    int   rtStart = isDown ? hiPt.idx : loPt.idx
    float rtHi    = isDown ? hiPt.price : high
    float rtLo    = isDown ? low : loPt.price

    if not na(rtStart) and not na(rtHi) and not na(rtLo) and rtHi > rtLo
        float range_ = rtHi - rtLo

        if range_ > tickAmt
            int binCount = math.min(80, math.max(1, int(range_ / tickAmt)))
            float step   = range_ / binCount
            int barSpan  = bar_index - rtStart

            if barSpan > 0 and binCount > 0
                int desiredTF     = timeframe.in_seconds(tpoTF)
                int chartTF       = timeframe.in_seconds()
                int barsPerPeriod = math.max(1, desiredTF / chartTF)

                int maxPeriods = int(math.ceil(float(barSpan) / barsPerPeriod))
                if maxPeriods > alphaSize
                    barsPerPeriod := int(math.ceil(float(barSpan) / alphaSize))

                letters = array.new<string>(binCount, "")
                counts  = array.new<int>(binCount, 0)
                int actualMaxPeriod = 0

                for i = 0 to barSpan
                    int barNum    = barSpan - i
                    int letterIdx = int(barNum / barsPerPeriod)

                    if letterIdx >= alphaSize
                        continue

                    if letterIdx > actualMaxPeriod
                        actualMaxPeriod := letterIdx

                    string letter = alphabet.get(letterIdx)
                    float h = high[i]
                    float l = low[i]

                    if na(h) or na(l)
                        continue

                    int kStart = int(math.max(0, math.floor((l - rtLo) / step)))
                    int kEnd   = int(math.min(binCount - 1, math.floor((h - rtLo) / step)))
                    kStart    := math.max(0, math.min(kStart, binCount - 1))
                    kEnd      := math.max(0, math.min(kEnd, binCount - 1))

                    if kStart <= kEnd
                        for k = kStart to kEnd
                            string existing = letters.get(k)
                            if not str.contains(existing, letter)
                                letters.set(k, existing + letter)
                                counts.set(k, counts.get(k) + 1)

                int maxTPO = counts.size() > 0 ? counts.max() : 0
                float maxPeriodF = math.max(1., float(actualMaxPeriod))

                if maxTPO > 0
                    int pocK = counts.indexof(maxTPO)

                    if pocK >= 0 and pocK < binCount
                        int vaBot = pocK
                        int vaTop = pocK
                        int vaSum = counts.get(pocK)
                        float vaThresh = counts.sum() * vaPct

                        while vaSum < vaThresh
                            float addBot = vaBot > 0 ? counts.get(vaBot - 1) : 0
                            float addTop = vaTop < binCount - 1 ? counts.get(vaTop + 1) : 0
                            if addBot >= addTop and vaBot > 0
                                vaBot -= 1
                                vaSum += counts.get(vaBot)
                            else if vaTop < binCount - 1
                                vaTop += 1
                                vaSum += counts.get(vaTop)
                            else
                                break

                        color rtCol = chart.fg_color

                        for k = 0 to binCount - 1
                            string ltrs = letters.get(k)
                            int cnt     = counts.get(k)
                            if cnt <= 0
                                continue

                            float bBot = rtLo + k * step
                            float bTop = bBot + step
                            bool isPOC = k == pocK
                            bool inVA  = k >= vaBot and k <= vaTop
                            bool isSP  = cnt == 1

                            int strLen = str.length(ltrs)
                            if strLen > 0
                                for c = 0 to strLen - 1
                                    string ch = str.substring(ltrs, c, c + 1)
                                    int left  = rtStart + c * boxWidth
                                    int right = left + boxWidth

                                    int alpIdx  = alphabet.indexof(ch)
                                    float gradT = alpIdx >= 0 ? float(alpIdx) / maxPeriodF : 0.5

                                    color bgC = na
                                    color bdC = na
                                    color txC = na

                                    if isPOC
                                        bgC := color.new(pocCol, 10)
                                        bdC := color.new(pocCol, 20)
                                        txC := color.black
                                    else if isSP and showSP
                                        bgC := color.new(spCol, 25)
                                        bdC := color.new(spCol, 40)
                                        txC := color.white
                                    else if useGrad
                                        color gCol = f_grad3(gradT, gradStart, gradMid, gradEnd)
                                        int trn = inVA ? 15 : 40
                                        bgC := color.new(gCol, trn)
                                        bdC := color.new(gCol, inVA ? 40 : 65)
                                        txC := color.white
                                    else
                                        bgC := inVA ? color.new(rtCol, 25) : color.new(rtCol, 55)
                                        bdC := inVA ? color.new(rtCol, 60) : color.new(rtCol, 85)
                                        txC := color.white

                                    rtBoxes.push(box.new(left, bTop, right, bBot,
                                         border_color = bdC,
                                         bgcolor = bgC,
                                         text = ch,
                                         text_color = txC,
                                         text_size = sz,
                                         border_width = 1))

                        if showPOC
                            float pocPrice = rtLo + pocK * step + step * 0.5
                            rtLines.push(line.new(rtStart, pocPrice, bar_index, pocPrice,
                                 color = color.new(pocCol, 60), width = 5))
                            rtLines.push(line.new(rtStart, pocPrice, bar_index, pocPrice,
                                 color = pocCol, width = 2))

                        if showVA
                            float vaTopP = rtLo + (vaTop + 1) * step
                            float vaBotP = rtLo + vaBot * step

                            rtLines.push(line.new(rtStart, vaTopP, rtStart, vaBotP,
                                 color = color.new(vaCol, 70), width = 7))
                            rtLines.push(line.new(rtStart, vaTopP, rtStart, vaBotP,
                                 color = vaCol, width = 3))


// ┌────────────────────────────── BOSWaves ─- Alerts ─────────────────────────────────┐
// └───────────────────────────────────────────────────────────────────────────────────┘
alertcondition(isDown != isDown[1] and isDown, "Swing High", "Swing high completed on {{ticker}}")
alertcondition(isDown != isDown[1] and not isDown, "Swing Low", "Swing low completed on {{ticker}}")
alertcondition(bullSig, "SP Reclaim Bull", "Single print reclaimed bullish on {{ticker}}")
alertcondition(bearSig, "SP Reclaim Bear", "Single print rejected bearish on {{ticker}}")
````
