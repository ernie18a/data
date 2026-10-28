# TGIF Weekly Retracement+ (M1D)

- url: https://www.tradingview.com/script/TVyOho94-TGIF-Weekly-Retracement-M1D/
- type: indicator
- pine_id: PUB;0b99c067a861441eaba87f8f44f78d73
- version: 3.0

## Description

[b]TGIF "Thank God It's Friday"-[/b]
Is a weekly retracement model taught by ICT. It is day-specific: it appears once a week, on Friday. Once the week has expanded and delivered into a higher-timeframe objective, Friday's job is not more expansion but a retracement back inside the weekly range — roughly 20-30% of that range given back before the weekly close. Structurally it is the distribution phase of the weekly Power 3.

This script measures the range and maps the draw. It takes no directional opinion of its own.


[b]THE RANGE-[/b]

The weekly range is the lowest low of the week up to its highest high. Both anchors are weekly extremes, so the percentages are cut from the weekly range itself.

Direction comes from the sequence of those two extremes. Whichever printed later is the terminus the retracement runs back from; the opposite extreme is the origin. A week making higher highs into Friday is measured low to high; a week that topped midweek and sold off into Friday is measured high to low. The read refreshes on every confirmed bar, so a week that re-expands and takes its other side flips the measurement with it.


[b]THE PRECONDITION-[/b]

The model expects price to have already delivered into a higher-timeframe premium array in a bullish week, or a discount array in a bearish week. Without that the week can keep expanding and close on its extreme with no retracement at all. It is the condition that separates the two, so it is checked rather than assumed, and enforced by default.

Monthly, Weekly and 3D are scanned. Each keeps at most one discount and one premium array, the most recent to pass validation. Two kinds of void qualify: a three-candle displacement gap, where an order block registers only if its displacement left a gap and the gap only registers if it clears a height floor with a real body behind it; and the void across a candle boundary, from one higher-timeframe candle's close to the next one's open, which nothing traded through at all — on the weekly, the weekend.

A week qualifies when its terminus extreme has traded a set depth into one of those arrays, 25% by default, measured from the edge price approached. The array checked is the one opposite the week's direction: a bullish week rallies into premium, a bearish week drops into discount. Because the test runs against that week's own extreme it reads correctly on every week in history, and the dashboard names what qualified it.

One array per side is drawn by default, highest timeframe winning where two overlap in price. Raising the count draws the next one down that sits elsewhere. That is display only — the check reads every array found, so tidying the chart cannot change which weeks qualify. An array stays drawn until price has traded fully through it.


A SPENT DRAW IS NOT A SETUP-

Friday is meant to deliver the give-back. A week that already paid it out on Wednesday has nothing left, however cleanly the rest reads. The deepest pullback from the terminus is tracked, and if it reached the retracement band before Friday the week is marked as worked rather than shown as live. That measurement restarts whenever the terminus moves, since a new extreme begins a new leg with its own untouched draw.

A stricter reading is available, off by default: require the terminus to have formed on Thursday or Friday.

[b](Visual shows the setting ON)[/b]

[b]CONFIRMATION-[/b]

Friday's swing sets no level. It is the gate on conviction: a swing on the terminus side, confirmed on the 15M or 30M and held on a closing basis. The zones are a draw on liquidity, drawn in anticipation rather than waited on, which is how the model is used. Confirmation fires the alert and locks the measurement, so the levels stop moving. If the swing is later broken the lock releases and it re-arms on the next one.

Before that lock the levels do move, because the weekly range is not final until the extreme stops extending. That is the model rather than a repaint: nothing is read from an unclosed bar, no decision taken on a closed bar is ever revised, and the confirmation timeframe is requested one bar back so no forming higher-timeframe bar can contribute a pivot that later disappears.


[b]WHAT IT DRAWS-[/b]

- The weekly range as an outline: a dotted level on each extreme, each beginning at the candle that formed it, closed by a riser at each end. It draws from early in the week.
- TGIF 20-30%, the retracement zone measured from the terminus back inside the range, with a midline through it — the 25% marker at default settings. The zones begin at the candle that formed the terminus, since a retracement cannot start before the extreme it runs back from exists.
- A reversal band beyond the draw. Not a target: past roughly 40% the move stops describing a Friday retracement and starts describing a larger reversal, and by 50% most of a TGIF position would already be off.
- The higher-timeframe arrays, captioned BISI, SIBI, OB+, OB- or VI alongside the timeframe that owns them.
- A dashboard carrying the chart timeframe, a countdown to the Friday close, model status, the array that qualified the week, the weekly range in points, and the distance from price to each zone.

Callouts sit at the right edge of the drawing, spaced by ATR-derived clearance so they do not stack on one another.


[b]SETTINGS-[/b]

- Timezone, IANA format, defaulting to America/New_York. All day-of-week resolution uses it.
- Whether delivery into a higher-timeframe array is required, which of the three timeframes are scanned, the depth that counts as delivery, and how many arrays are drawn per side.
- Whether the terminus must have formed on Thursday or Friday, and how many completed weeks stay on the chart.
- The Friday hour past which the extreme is treated as set, 13:30 by default. Reported in the dashboard; it does not stop the anchors tracking a genuine new extreme.
- Swing confirmation timeframe, 15M or 30M, with adjustable pivot bars.
- Both bands are adjustable. 20/30 and 40/50 are defaults, not fixed values.
- Colours, label visibility and offset, dashboard position, and the Friday close time the countdown counts to.


[b]NOTES-[/b]

- Non-repainting. All structure is read on closed bars.
- Completed weeks stay on the chart behind the current one, two by default and up to eight, frozen as they finished and with their callouts dropped so old text does not sit over live price. Set the count to zero for the current week only.
- Three alert conditions: Friday swing confirmed, price tapping the retracement zone, and price entering the reversal band.
- This is a mapping tool. It draws the model's levels and reports where price sits relative to them; it produces no entries, targets or stops. ICT is explicit that TGIF supplies the draw and the day, and that the entry is whichever of his models you prefer.

[b]Disclaimer-[/b]
This is not financial advice. Levels drawn by a model are context, not a recommendation to trade, and the past behaviour of a weekly range says nothing certain about the next one.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mayb1dayy

//@version=6

// -----------------------------------------------------------------------------
//  TGIF - Thank God It's Friday
//  Weekly retracement model
//
//  TGIF is not a Monday-to-Friday range tool. The week does its expansion early:
//  price runs one side of weekly liquidity across a two-to-three day leg, and by
//  the back half of the week that leg has been delivered. Friday's job is not
//  more expansion - it is the retracement back inside the range that was built.
//  The expectation is that the back of the week, from Thursday afternoon through
//  Friday, gives back roughly 20-30% of the weekly range, with 20% the first
//  objective.
//
//  The range measured is the whole week: its lowest low up to its highest high.
//
//    Direction - read from the sequence of the two weekly extremes. Whichever
//               printed later is the terminus the retracement runs back from; the
//               opposite extreme is the origin. A week making higher highs into
//               Friday is measured low to high; a week that topped midweek and
//               sold off into Friday is measured high to low. The read refreshes
//               on every confirmed bar, so a week that re-expands and takes its
//               other side flips the measurement with it.
//
//    Anchor A - the origin extreme of the week.
//    Anchor B - the terminus extreme of the week, and the level the retracement
//               is measured from.
//
//    Precondition - the model expects price to have already delivered into a
//               higher-timeframe premium array in a bullish week, or a discount
//               array in a bearish week. Without that the week can keep expanding
//               and close on its extreme with no retracement at all. Monthly,
//               Weekly and Daily are scanned for validated arrays and the week
//               qualifies once its terminus extreme has traded a set depth into one
//               on the side opposite its own direction. The test runs against that
//               week's own extreme, so it is a fact about the week rather than a
//               setting applied to all of them.
//
//    Retracement - 20-30% of the weekly range, measured from Anchor B back inside
//               the range, with a midline through it. This is the TGIF draw.
//
//    Target   - a single level at 20% of the weekly range, the first objective
//               of the draw.
//
//    Reversal - a band beyond the draw. A retracement carrying past roughly 40%
//               of the weekly range stops describing a Friday retracement and
//               starts describing a larger reversal, and by 50% most of a TGIF
//               position would already be off. It marks where the model ends, not
//               a target to aim at.
//
//    Setup window - Thursday from 13:00 New York through the end of Friday. The
//               zones draw inside it and a swing only confirms inside it.
//
//    Confirmation - the window's swing sets no level. It is the gate on conviction: a
//               swing high on the terminus side, or a swing low in the bearish
//               case, confirmed on the 15M (5M at the lowest, or 30M) and held on a
//               closing basis. The
//               zones are a draw on liquidity and are drawn in anticipation; the
//               swing upgrades them from projected to confirmed.
//
//  A close back through the confirming swing means the week did not turn there. The
//  status drops back to projected, the range unlocks and resumes tracking, and it
//  re-arms on the next swing to confirm on the terminus side.
//
//  Non-repainting. Structure is read on closed bars only, and the confirmation
//  timeframe is requested one bar back so no forming higher-timeframe bar can
//  contribute a pivot that later disappears. The levels do move while the week is
//  still setting its extreme, because the range is not final until the extreme stops
//  extending; that is the model, not a repaint. Once structure turns they lock.
//
//  Model concept and terminology: ICT (Inner Circle Trader).
// -----------------------------------------------------------------------------

indicator("TGIF Weekly Retracement+ (M1D)", shorttitle = "TGIF+ (M1D)", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// == CONSTANTS ================================================================

const string GRP_MODEL           = "TGIF Model"
const string GRP_ZONES           = "Zones"
const string GRP_OUTLINE         = "Range Outline"
const string GRP_HTF             = "HTF Arrays"
const string GRP_LABELS          = "Labels"
const string GRP_DASH            = "Dashboard"

const string CONF_TF_5           = "5"
const string CONF_TF_15          = "15"
const string CONF_TF_30          = "30"
const string CONF_CHOICE_5       = "5M"
const string CONF_CHOICE_30      = "30M"

const string TGIF_LABEL_PREFIX   = "TGIF "
const string REVERSAL_PREFIX     = "Reversal "
const string EN_DASH             = "–"
const string PERCENT_SIGN        = "%"
const string WEEK_HIGH_LABEL     = "Week High"
const string WEEK_LOW_LABEL      = "Week Low"
const string PCT_FORMAT          = "#.##"

const string BISI_LABEL          = "BISI"
const string SIBI_LABEL          = "SIBI"
const string OB_BULL_LABEL       = "OB+"
const string OB_BEAR_LABEL       = "OB-"
const string VI_LABEL            = "VI"

const int    KIND_NONE           = 0
const int    KIND_FVG            = 1
const int    KIND_OB             = 2
const int    KIND_VI             = 3
const string TF_MONTHLY          = "M"
const string TF_WEEKLY           = "W"
const string TF_DAILY            = "D"
const string TARGET_PREFIX       = "Target "

const string BRAND_TEXT          = "TGIF+"
const string DASH_SEP            = "¦"
const string PREMIUM_TEXT       = " premium"
const string DISCOUNT_TEXT       = " discount"
const string NYAM_KZ_TEXT        = "NY AM kill zone"
const string NY_OPEN_TEXT        = "NY open"
const string OUTSIDE_TEXT        = "Outside"
const string PTS_SUFFIX          = " pts"
const string IN_ZONE_TEXT        = "IN ZONE"
const string DASH_EMPTY          = "-"
const string NOT_REACHED_TEXT    = "Not reached"

const int    DASH_COLUMNS        = 2

const int    HTF_COUNT           = 3
const int    ARRAY_FILL_TRANSP   = 88
const int    ARRAY_BORDER_TRANSP = 55

const int    SECONDS_PER_MINUTE  = 60
const int    SECONDS_PER_HOUR    = 3600
const int    SECONDS_PER_DAY     = 86400
const int    MINUTES_PER_HOUR    = 60
const int    DAYS_PER_WEEK       = 7
const int    MS_PER_DAY          = 86400000
const int    NYAM_KZ_START       = 420
const int    NYAM_KZ_END         = 540
const int    NY_OPEN_START       = 570
const int    NY_OPEN_END         = 660

// Zone bases are deep rather than pastel so they carry on a white chart background.
const color  RETRACE_DEFAULT     = #6A0DAD
const color  REVERSAL_DEFAULT    = #4A4A4A

// All text, on chart and in the dashboard, renders solid black.
const color  TEXT_INK            = #000000

const int    ATR_LENGTH          = 14
const int    ZONE_FILL_TRANSP    = 70
const int    ZONE_BORDER_TRANSP  = 10
const int    ZONE_BORDER_WIDTH   = 1
const int    OUTLINE_WIDTH       = 1
const int    BRACKET_GAP_BARS    = 1
const int    MS_PER_SECOND       = 1000
const float  PERCENT_DIVISOR     = 100.0

// == INPUTS ===================================================================

string tzInput = input.string("America/New_York", "Timezone (IANA)", group = GRP_MODEL,
     tooltip = "Day-of-week resolution always uses this timezone, never chart-local time.")

string confTFChoice = input.string("15M", "Swing confirmation timeframe",
     options = ["5M", "15M", "30M"], group = GRP_MODEL,
     tooltip = "The timeframe the confirming swing is read on. 15M is the confirmation sequence to aim for; 5M is the lowest.")

int setupStartHour = input.int(13, "Setup window opens Thursday (hour)", minval = 0, maxval = 23,
     group = GRP_MODEL,
     tooltip = "Hour on Thursday, in the timezone above, from which the setup window runs through the end of Friday. The zones draw inside the window and a swing only confirms inside it.")

int pivotLeftBars = input.int(2, "Pivot left bars", minval = 1, maxval = 20, group = GRP_MODEL,
     tooltip = "Bars required on the left of the swing. ICT's three-candle swing is 1 and 1.")

int pivotRightBars = input.int(2, "Pivot right bars", minval = 1, maxval = 20, group = GRP_MODEL,
     tooltip = "Bars required on the right of the swing. Higher values confirm later but filter harder.")

bool requireDelivery = input.bool(true, "Require delivery into a HTF array", group = GRP_MODEL,
     tooltip = "The model's precondition: TGIF expects price to have already delivered into a higher-timeframe premium array in a bullish week, or a discount array in a bearish week. Without it the week can keep expanding and close on its extreme, which is the condition that separates a week that retraces from one that does not. On by default. Turn it off on a week where you can see a array the scan has not counted — it reads only the timeframes selected below and only arrays that pass validation, so it will miss some you would take.")

bool requireRecentTerminus = input.bool(false, "Terminus must form Thursday or Friday",
     group = GRP_MODEL,
     tooltip = "The model assumes the weekly extreme forms on Friday, which is what makes the Friday swing a confirmation of that extreme rather than of something unrelated to it. On a week whose extreme was set on Monday or Tuesday the retracement has usually already run, so the Friday swing confirms a turn three hundred points away from the level it is supposed to be validating. Off by default: the spent-draw check already rejects most of those weeks, and this is the stricter reading.")

int lockHour = input.int(13, "Assume extreme set from (hour)", minval = 0, maxval = 23,
     group = GRP_MODEL,
     tooltip = "Friday time, in the timezone above, past which the weekly extreme is treated as set. Reported in the dashboard; it does not stop the anchors tracking a genuine new extreme.")

int lockMinute = input.int(30, "Assume extreme set from (minute)", minval = 0, maxval = 59,
     group = GRP_MODEL)

bool showTarget = input.bool(true, "Show target level", group = GRP_ZONES,
     tooltip = "A single solid level at the first objective of the draw, measured from the terminus extreme back inside the weekly range.")

float targetPct = input.float(20, "Target (%)", minval = 1, maxval = 100, step = 1, group = GRP_ZONES)

bool showRetraceZone = input.bool(true, "Show TGIF retracement zone", group = GRP_ZONES)

float band1LoPct = input.float(20, "Retracement band from (%)", minval = 0, maxval = 100,
     step = 1, group = GRP_ZONES)

float band1HiPct = input.float(30, "Retracement band to (%)", minval = 0, maxval = 100,
     step = 1, group = GRP_ZONES)

bool showMidline = input.bool(true, "Show retracement midline", group = GRP_ZONES,
     tooltip = "A line through the middle of the retracement band. At the default 20/30 that is the 25% marker.")

bool showReversalZone = input.bool(true, "Show reversal band", group = GRP_ZONES,
     tooltip = "Not a target. A draw past roughly 40% of the weekly range is where the model stops describing a Friday retracement and starts describing a larger reversal, and 50% is where most of a TGIF position would already be off.")

float band2LoPct = input.float(40, "Reversal band from (%)", minval = 0, maxval = 100,
     step = 1, group = GRP_ZONES)

float band2HiPct = input.float(50, "Reversal band to (%)", minval = 0, maxval = 100,
     step = 1, group = GRP_ZONES)

color retraceColorInput  = input.color(RETRACE_DEFAULT,  "Retracement zone colour", group = GRP_ZONES)
color reversalColorInput = input.color(REVERSAL_DEFAULT, "Reversal band colour",    group = GRP_ZONES)

int priorWeeksKept = input.int(2, "Prior weeks kept on chart", minval = 0, maxval = 8,
     group = GRP_ZONES,
     tooltip = "How many completed weeks stay on the chart behind the current one. Their zones and outline are frozen as they finished; their callouts are dropped so old text does not sit over live price. Set to 0 to show the current week only.")

bool useMonthly = input.bool(true, "Monthly", group = GRP_HTF, inline = "tf")
bool useWeekly  = input.bool(true, "Weekly",  group = GRP_HTF, inline = "tf")
bool useDaily   = input.bool(true, "Daily",   group = GRP_HTF, inline = "tf",
     tooltip = "Which higher timeframes are scanned for the array the week has to deliver into. Each keeps at most one discount and one premium array — the most recent that passed validation — so the chart carries six boxes at the very most.")

bool showArrays = input.bool(true, "Draw the arrays", group = GRP_HTF,
     tooltip = "Off hides the boxes while the delivery check still runs.")

int arraysPerSide = input.int(1, "Arrays drawn per side", minval = 1, maxval = 3, group = GRP_HTF,
     tooltip = "Highest timeframe wins where arrays overlap: a monthly array covering the same price as a weekly or daily one stands in for both, rather than three boxes stacking in one place. Raise this to also draw the next array down that sits somewhere else. Display only — the delivery check reads every array found regardless of what is drawn, so tidying the chart cannot change which weeks qualify.")

float arrayMinHeight = input.float(0.15, "Array min height (× ATR)", minval = 0.0, step = 0.05,
     group = GRP_HTF,
     tooltip = "A gap has to clear this to register. Matches the Confluence Engine's FVG sensitivity.")

float arrayDispBody = input.float(0.6, "Displacement body (× ATR)", minval = 0.0, step = 0.1,
     group = GRP_HTF,
     tooltip = "The candle that opens the gap must have a body at least this large in the gap's direction. This is what makes it a displacement rather than a routine three-candle gap, and it is the same validation the Confluence Engine applies. A order block registers only when its displacement left a gap: no gap, no order block.")

float deliveryPct = input.float(25, "Delivery into the array (%)", minval = 1, maxval = 100,
     step = 5, group = GRP_HTF,
     tooltip = "How far price must trade into the array, measured from the edge it approached, before the week counts as having delivered. Only a array that already existed when the week's extreme printed counts. Separate from mitigation: a array stays drawn until a candle closes through it.")

color arrayBullColor = input.color(#7246CE, "Discount array", group = GRP_HTF, inline = "ac")
color arrayBearColor = input.color(#DB1D9C, "Premium array",  group = GRP_HTF, inline = "ac")

bool showOutline = input.bool(true, "Show range outline", group = GRP_OUTLINE,
     tooltip = "One box around the whole week: from its first candle to the live candle, top at the week high, bottom at the week low. Drawn from early in the week, well ahead of Friday.")

color outlineColor = input.color(#000000, "Outline colour", group = GRP_OUTLINE)

bool showLabels = input.bool(true, "Show labels", group = GRP_LABELS)

string textSizeChoice = input.string("small", "Text size", options = ["tiny", "small", "normal", "large"],
     group = GRP_LABELS, tooltip = "Size of the chart labels and the dashboard text.")

int labelOffsetBars = input.int(3, "Label offset (bars right of zone)", minval = 0, maxval = 50,
     group = GRP_LABELS)

bool showDash = input.bool(true, "Show dashboard", group = GRP_DASH)

string dashPosChoice = input.string("Top right", "Dashboard position",
     options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"],
     group = GRP_DASH)

int fridayCloseHour = input.int(16, "Friday close hour", minval = 0, maxval = 23, group = GRP_DASH,
     tooltip = "The time the countdown counts to, in the timezone set above. Drives the dashboard only: the model itself reads Friday as the calendar day, so a swing confirming late in the session still counts.")

int fridayCloseMinute = input.int(59, "Friday close minute", minval = 0, maxval = 59, group = GRP_DASH)

// == DERIVED SETTINGS =========================================================

string TXT_SZ = switch textSizeChoice
    "tiny"   => size.tiny
    "normal" => size.normal
    "large"  => size.large
    =>          size.small

string confTF = confTFChoice == CONF_CHOICE_30 ? CONF_TF_30 : confTFChoice == CONF_CHOICE_5 ? CONF_TF_5 : CONF_TF_15

float  targetFrac      = targetPct / PERCENT_DIVISOR
string targetLabelText = TARGET_PREFIX + str.tostring(targetPct, PCT_FORMAT) + PERCENT_SIGN

float band1Lo = math.min(band1LoPct, band1HiPct) / PERCENT_DIVISOR
float band1Hi = math.max(band1LoPct, band1HiPct) / PERCENT_DIVISOR
float band2Lo = math.min(band2LoPct, band2HiPct) / PERCENT_DIVISOR
float band2Hi = math.max(band2LoPct, band2HiPct) / PERCENT_DIVISOR

string retraceLabelText = TGIF_LABEL_PREFIX
     + str.tostring(math.min(band1LoPct, band1HiPct), PCT_FORMAT) + EN_DASH
     + str.tostring(math.max(band1LoPct, band1HiPct), PCT_FORMAT) + PERCENT_SIGN

string reversalLabelText = REVERSAL_PREFIX
     + str.tostring(math.min(band2LoPct, band2HiPct), PCT_FORMAT) + EN_DASH
     + str.tostring(math.max(band2LoPct, band2HiPct), PCT_FORMAT) + PERCENT_SIGN

// Midline of the retracement band, which at the default 20/30 is the 25% marker.
float band1Mid = (band1Lo + band1Hi) / 2

string dashPosition = switch dashPosChoice
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    "Bottom left"  => position.bottom_left
    =>                position.top_right

color retraceFill    = color.new(retraceColorInput, ZONE_FILL_TRANSP)
color retraceBorder  = color.new(retraceColorInput, ZONE_BORDER_TRANSP)
color reversalFill   = color.new(reversalColorInput, ZONE_FILL_TRANSP)
color reversalBorder = color.new(reversalColorInput, ZONE_BORDER_TRANSP)

// == STATE MODEL ==============================================================

//@type Per-week TGIF state. The two anchors are the week's own extremes; the rest
//      tracks the setup-window swing that has to confirm before the zones commit. Every
//      field is reset in one place, by reset(), on the weekly boundary.
type TgifState
    int   weekStart        = 0
    float weekHigh         = na
    float weekLow          = na
    int   weekHighTime     = 0
    int   weekLowTime      = 0
    bool  directionSet     = false
    bool  terminusIsHigh   = false
    float anchorA          = na
    int   anchorATime      = 0
    float anchorB          = na
    int   anchorBTime      = 0
    float confirmPivot     = na
    float retraceExtreme   = na
    bool  drawSpent        = false
    bool  active           = false
    bool  rangeLocked      = false
    int   lastPivotTime    = 0
    bool  tappedTarget     = false
    bool  tappedRetrace    = false
    bool  tappedReversal   = false

//@type One completed week's drawings, frozen as they finished. Callouts are not
//      kept: old text sitting over live price is clutter, the shapes are the record.
type WeekDrawing
    box  retraceBox   = na
    box  reversalBox  = na
    box  weekBox      = na
    line midline      = na
    line targetLine   = na

//@function Deletes every drawing a retired week owns.
//@param this (WeekDrawing) The retired week.
//@returns (bool) Always true.
method clear(WeekDrawing this) =>
    line.delete(this.targetLine)
    box.delete(this.retraceBox)
    box.delete(this.reversalBox)
    box.delete(this.weekBox)
    line.delete(this.midline)
    true

//@type The live discount and premium array on one higher timeframe. Each side holds
//      at most one: the most recent that passed validation. Each drawn array carries
//      its name as a label past the right edge, on the box's centre line.
type HtfArray
    string tf       = ""
    float  bullTop  = na
    float  bullBot  = na
    int    bullTime = 0
    string bullName = ""
    int    bullFormed = 0
    int    bullDead   = 0
    float  bearTop  = na
    float  bearBot  = na
    int    bearTime = 0
    string bearName = ""
    int    bearFormed = 0
    int    bearDead   = 0
    bool   bullShown = false
    bool   bearShown = false
    box    bullBox  = na
    box    bearBox  = na
    label  bullLbl  = na
    label  bearLbl  = na

//@function Resolves what a array is called from its kind.
//@param kind   (int) One of the KIND_ constants.
//@param isBull (bool) True for the discount side.
//@returns (string) Caption text.
arrayName(int kind, bool isBull) =>
    switch kind
        KIND_FVG => isBull ? BISI_LABEL : SIBI_LABEL
        KIND_OB  => isBull ? OB_BULL_LABEL : OB_BEAR_LABEL
        KIND_VI  => VI_LABEL
        =>          ""

//@function Takes a fresh reading for one timeframe. A reading with a new origin
//          candle replaces the stored array on that side; a repeat of the same
//          origin is the array already held, and the origin of a array already
//          retired is never taken back.
//@param this (HtfArray) The timeframe's slot.
//@param dTop (float) Discount array top, na when none formed.
//@param dBot (float) Discount array bottom.
//@param dKind (int) Kind of the discount array.
//@param dTime (int) Opening time of the candle it originates from.
//@param pTop (float) Premium array top, na when none formed.
//@param pBot (float) Premium array bottom.
//@param pKind (int) Kind of the premium array.
//@param pTime (int) Opening time of the candle it originates from.
//@param formed (int) Time from which both arrays were known.
//@returns (bool) Always true.
method ingest(HtfArray this, float dTop, float dBot, int dKind, int dTime, float pTop,
     float pBot, int pKind, int pTime, int formed) =>
    if not na(dTop) and dTime != this.bullTime and dTime != this.bullDead
        this.bullTop    := dTop
        this.bullBot    := dBot
        this.bullTime   := dTime
        this.bullName   := arrayName(dKind, true)
        this.bullFormed := formed
    if not na(pTop) and pTime != this.bearTime and pTime != this.bearDead
        this.bearTop    := pTop
        this.bearBot    := pBot
        this.bearTime   := pTime
        this.bearName   := arrayName(pKind, false)
        this.bearFormed := formed
    true

//@function Drops a side once a candle closes through it — a spent array is no longer
//          a PD array. A wick through is a touch and leaves it standing.
//@param this (HtfArray) The timeframe's slot.
//@returns (bool) Always true.
method retireFilled(HtfArray this) =>
    if not na(this.bullBot) and close < this.bullBot
        this.bullDead := this.bullTime
        this.bullTop  := na
        this.bullBot  := na
        this.bullTime := 0
    if not na(this.bearTop) and close > this.bearTop
        this.bearDead := this.bearTime
        this.bearTop  := na
        this.bearBot  := na
        this.bearTime := 0
    true

//@function Most recent validated discount and premium array on the requested
//          timeframe, read from closed candles only. Two kinds of void qualify.
//
//          A three-candle displacement gap, where a order block registers only if
//          its displacement left a gap — no gap, no order block — and the gap itself
//          only registers if it clears a height floor and the candle that opened it
//          carried a real body in the gap's direction.
//
//          A close-to-open void across the candle boundary. Nothing trades between a
//          higher-timeframe candle's close and the next one's open, so that space was
//          never delivered into at all. On the weekly this is the weekend void. It is
//          measured from the two prices themselves rather than from body overlap,
//          which is what separates it from a body gap drawn over range price did
//          trade through.
//
//          The later origin wins on each side. Every input is a closed candle, the ATR
//          included, so the reading is final from the moment the candle after them
//          opens and can be requested with lookahead.
//@param minHeight (float) Minimum void height as a multiple of ATR.
//@param dispBody  (float) Minimum displacement body as a multiple of ATR.
//@returns (tuple) discount top/bottom/kind/origin, premium top/bottom/kind/origin, time known from
htfPdArray(float minHeight, float dispBody) =>
    float atrHtf    = ta.atr(ATR_LENGTH)[1]
    float gapFloor  = atrHtf * minHeight
    float bodyFloor = atrHtf * dispBody

    bool bisi = low[1] > high[3] and (low[1] - high[3]) >= gapFloor
         and (close[2] - open[2]) >= bodyFloor
    bool sibi = high[1] < low[3] and (low[3] - high[1]) >= gapFloor
         and (open[2] - close[2]) >= bodyFloor

    bool obBull = bisi and close[3] < open[3]
    bool obBear = sibi and close[3] > open[3]

    bool viBull = open[1] > close[2] and (open[1] - close[2]) >= gapFloor
    bool viBear = open[1] < close[2] and (close[2] - open[1]) >= gapFloor

    float dTop  = na
    float dBot  = na
    int   dKind = KIND_NONE
    int   dTime = 0
    if bisi
        dTop  := obBull ? open[3]  : low[1]
        dBot  := obBull ? close[3] : high[3]
        dKind := obBull ? KIND_OB  : KIND_FVG
        dTime := time[3]
    if viBull and time[2] > dTime
        dTop  := open[1]
        dBot  := close[2]
        dKind := KIND_VI
        dTime := time[2]

    float pTop  = na
    float pBot  = na
    int   pKind = KIND_NONE
    int   pTime = 0
    if sibi
        pTop  := obBear ? close[3] : low[3]
        pBot  := obBear ? open[3]  : high[1]
        pKind := obBear ? KIND_OB  : KIND_FVG
        pTime := time[3]
    if viBear and time[2] > pTime
        pTop  := close[2]
        pBot  := open[1]
        pKind := KIND_VI
        pTime := time[2]

    [dTop, dBot, dKind, dTime, pTop, pBot, pKind, pTime, time]

//@function Whether price reached far enough into a array to count as delivery.
//@param extreme  (float) The week's terminus extreme.
//@param zoneTop  (float) Array top.
//@param zoneBot  (float) Array bottom.
//@param fromBelow (bool) True when price approaches the array from underneath.
//@param frac     (float) Required penetration as a fraction of the array's height.
//@returns (bool) True once the extreme has traded that far in.
deliveredInto(float extreme, float zoneTop, float zoneBot, bool fromBelow, float frac) =>
    bool hit = false
    if not na(zoneTop) and not na(zoneBot) and not na(extreme)
        float depth = (zoneTop - zoneBot) * frac
        hit := fromBelow ? extreme >= zoneBot + depth : extreme <= zoneTop - depth
    hit

//@function Clears every field for a fresh trading week. The single reset point.
//@param this          (TgifState) The state object.
//@param weekStartTime (int) Opening time of the first bar of the new week.
//@returns (bool) Always true.
method reset(TgifState this, int weekStartTime) =>
    this.weekStart       := weekStartTime
    this.weekHigh        := na
    this.weekLow         := na
    this.weekHighTime    := 0
    this.weekLowTime     := 0
    this.directionSet    := false
    this.terminusIsHigh  := false
    this.anchorA         := na
    this.anchorATime     := 0
    this.anchorB         := na
    this.anchorBTime     := 0
    this.confirmPivot    := na
    this.retraceExtreme  := na
    this.drawSpent       := false
    this.active          := false
    this.rangeLocked     := false
    this.lastPivotTime   := 0
    this.tappedTarget    := false
    this.tappedRetrace   := false
    this.tappedReversal  := false
    true

// The pivot is read one confirmation bar back so only fully closed higher-timeframe
// bars contribute. Without the offset the forming confirmation bar sits inside the
// pivot's right-hand window, and a pivot can appear then disappear intrabar. With the
// offset in place the request takes lookahead, so history and live read the same bar.
//@function Latest confirmed swing pivots on the confirmation timeframe.
//@returns (tuple) [pivot low price, pivot high price, opening time of the pivot bar]
confirmationPivots() =>
    [ta.pivotlow(low, pivotLeftBars, pivotRightBars)[1],
     ta.pivothigh(high, pivotLeftBars, pivotRightBars)[1],
     time[1 + pivotRightBars]]

//@function Distance from a price to the near edge of a zone.
//@param price   (float) Price to measure from.
//@param zoneTop (float) Upper zone boundary.
//@param zoneBot (float) Lower zone boundary.
//@returns (float) Distance to the near edge, zero when the price is inside.
zoneDistance(float price, float zoneTop, float zoneBot) =>
    price > zoneTop ? price - zoneTop : price < zoneBot ? zoneBot - price : 0.0

//@function Two-digit zero-padded number for clock text.
//@param value (int) Value to pad.
//@returns (string) Padded value.
pad2(int value) =>
    (value < 10 ? "0" : "") + str.tostring(value)

//@function Formats a millisecond span as a countdown.
//@param spanMs (int) Milliseconds remaining.
//@returns (string) "Nd HH:MM" beyond a day, otherwise "HH:MM:SS".
countdownText(int spanMs) =>
    int totalSeconds = math.max(0, math.floor(spanMs / MS_PER_SECOND))
    int days    = math.floor(totalSeconds / SECONDS_PER_DAY)
    int hours   = math.floor(totalSeconds % SECONDS_PER_DAY / SECONDS_PER_HOUR)
    int minutes = math.floor(totalSeconds % SECONDS_PER_HOUR / SECONDS_PER_MINUTE)
    int seconds = totalSeconds % SECONDS_PER_MINUTE
    days > 0
         ? str.tostring(days) + "d " + pad2(hours) + ":" + pad2(minutes)
         : pad2(hours) + ":" + pad2(minutes) + ":" + pad2(seconds)

//@function The chart's own timeframe, written the way it reads on the toolbar.
//@returns (string) Formatted timeframe.
chartTfText() =>
    string out = timeframe.period
    if timeframe.isseconds
        out := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes
        out := timeframe.multiplier % MINUTES_PER_HOUR == 0
             ? str.tostring(math.floor(timeframe.multiplier / MINUTES_PER_HOUR)) + "H"
             : str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        out := "1D"
    else if timeframe.isweekly
        out := "1W"
    else if timeframe.ismonthly
        out := "1M"
    out

//@function Writes one name-and-reading row into the dashboard. The tooltip on both
//          cells says what the row means and how the reading was worked out.
//@param id        (table)  Dashboard handle.
//@param row       (int)    Row index.
//@param rowLabel  (string) Name, in capitals.
//@param rowValue  (string) Reading.
//@param tip       (string) What the row means.
//@returns (int) The next row index.
dashRow(table id, int row, string rowLabel, string rowValue, string tip) =>
    table.cell(id, 0, row, rowLabel, text_color = TEXT_INK, text_size = TXT_SZ,
         text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = tip)
    table.cell(id, 1, row, rowValue, text_color = TEXT_INK, text_size = TXT_SZ,
         text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = tip)
    row + 1

//@function Packs one dashboard row so rows can be collected before the table is sized.
//@param name (string) Row name.
//@param val  (string) Reading.
//@param tip  (string) What the row means.
//@returns (string) The packed row.
dashEntry(string name, string val, string tip) =>
    name + DASH_SEP + val + DASH_SEP + tip

//@function Whether a time falls inside the TGIF setup window: Thursday from the
//          opening hour, or any time on Friday.
//@param t (int) Time to test.
//@returns (bool) True inside the window.
inSetupWindow(int t) =>
    int d = dayofweek(t, tzInput)
    d == dayofweek.friday or (d == dayofweek.thursday and hour(t, tzInput) >= setupStartHour)

//@function Where a price sits inside a range, as a percentage from its low, with
//          the side of equilibrium it is on.
//@param price (float) Price to place.
//@param hi    (float) Range high.
//@param lo    (float) Range low.
//@returns (string) "72% premium", or the empty marker when the range is unknown.
rangePositionText(float price, float hi, float lo) =>
    string out = DASH_EMPTY
    if not na(hi) and not na(lo) and hi > lo
        float pct = (price - lo) / (hi - lo) * PERCENT_DIVISOR
        out := str.tostring(math.round(pct)) + PERCENT_SIGN + (pct >= 50 ? PREMIUM_TEXT : DISCOUNT_TEXT)
    out

// == PERSISTENT HANDLES =======================================================

//@variable Whole-week TGIF state.
var TgifState st = TgifState.new()

//@variable The single retracement zone box, reused all week.
var box retraceBox = na
//@variable The single reversal-band box, reused all week.
var box reversalBox = na
//@variable Midline through the retracement band.
var line midlineLine = na
//@variable The target level at the first objective of the draw.
var line targetLine = na
//@variable Callout for the target level.
var label targetLbl = na
//@variable The box around the whole week, first candle to the live candle.
var box weekBox = na
//@variable Callout for the retracement zone.
var label retraceLbl = na
//@variable Callout for the reversal band.
var label reversalLbl = na
//@variable Callout naming Anchor A.
var label anchorALbl = na
//@variable Callout naming Anchor B.
var label anchorBLbl = na
//@variable Completed weeks still on the chart, oldest first.
var array<WeekDrawing> weekHistory = array.new<WeekDrawing>(0)
//@variable One slot per higher timeframe, in the order Monthly, Weekly, Daily.
var array<HtfArray> htfSlots = array.new<HtfArray>(0)
if barstate.isfirst
    htfSlots.push(HtfArray.new(TF_MONTHLY))
    htfSlots.push(HtfArray.new(TF_WEEKLY))
    htfSlots.push(HtfArray.new(TF_DAILY))
//@variable The dashboard. Built on the last bar only, never per week.
var table dash = na
//@variable Row count the dashboard was last built with; a change rebuilds it.
var int dashRowsDrawn = na

// == CLOCK ====================================================================

int  dayOfWeekNy = dayofweek(time, tzInput)
bool isFriday    = dayOfWeekNy == dayofweek.friday
bool inSetup     = inSetupWindow(time)

// The week boundary is derived from the New York day of week rather than taken from
// the chart's own weekly aggregation. Asking the platform when a week turns means
// inheriting how it bins a shortened or missing session, which slices weeks in the
// wrong place around a holiday. Ordering the days from Sunday and watching for the
// sequence to wrap is exact on any timeframe: the first bar whose day sits earlier
// in the week than the bar before it opens a new week, whether that bar is a Sunday
// evening reopen, a Monday after a dark Sunday, or a daily candle.
int  weekOrder        = dayOfWeekNy == dayofweek.sunday ? 0 : dayOfWeekNy - 1
bool isNewTradingWeek = barstate.isfirst or weekOrder < weekOrder[1]

// == WEEKLY BOUNDARY ==========================================================
// The finished week's shapes are retired here, before anything is redrawn: the live
// handles still point at objects last updated on that week's closing bar, so they
// freeze exactly as they ended. Its callouts are always deleted — old text sitting
// over live price is clutter — and the shapes are either kept as history or dropped.
// Not gated on barstate.isconfirmed: it only ever clears, and it has to take effect
// on the first tick of the new week.

if isNewTradingWeek
    st.reset(time)

    label.delete(targetLbl)
    label.delete(retraceLbl)
    label.delete(reversalLbl)
    label.delete(anchorALbl)
    label.delete(anchorBLbl)
    targetLbl   := na
    retraceLbl  := na
    reversalLbl := na
    anchorALbl  := na
    anchorBLbl  := na

    WeekDrawing finished = WeekDrawing.new(retraceBox, reversalBox, weekBox, midlineLine,
         targetLine)

    // A week that drew nothing leaves no record and must not consume a history slot.
    bool drewAnything = not na(retraceBox) or not na(reversalBox) or not na(weekBox)

    if priorWeeksKept > 0 and drewAnything
        weekHistory.push(finished)
        while weekHistory.size() > priorWeeksKept
            WeekDrawing retired = weekHistory.shift()
            retired.clear()
    else
        finished.clear()

    retraceBox       := na
    reversalBox      := na
    midlineLine      := na
    targetLine       := na
    weekBox          := na

// == CONFIRMATION TIMEFRAME REQUEST ===========================================

[confPivotLow, confPivotHigh, confPivotTime] = request.security(syminfo.tickerid, confTF,
     confirmationPivots(), lookahead = barmerge.lookahead_on)

// == HTF ARRAY REQUESTS =======================================================
// htfPdArray reads closed candles only, so lookahead puts each array on the chart
// from the opening of the candle after it formed, the same on history as live.
// Without it history shows each array one whole higher-timeframe candle late.

[mDTop, mDBot, mDKind, mDTime, mPTop, mPBot, mPKind, mPTime, mKnown] = request.security(
     syminfo.tickerid, TF_MONTHLY, htfPdArray(arrayMinHeight, arrayDispBody),
     lookahead = barmerge.lookahead_on)

[wDTop, wDBot, wDKind, wDTime, wPTop, wPBot, wPKind, wPTime, wKnown] = request.security(
     syminfo.tickerid, TF_WEEKLY, htfPdArray(arrayMinHeight, arrayDispBody),
     lookahead = barmerge.lookahead_on)

[dDTop, dDBot, dDKind, dDTime, dPTop, dPBot, dPKind, dPTime, dKnown] = request.security(
     syminfo.tickerid, TF_DAILY, htfPdArray(arrayMinHeight, arrayDispBody),
     lookahead = barmerge.lookahead_on)

// The forming month's high and low, read for the dashboard on the last bar only.
[monthHigh, monthLow] = request.security(syminfo.tickerid, TF_MONTHLY, [high, low],
     lookahead = barmerge.lookahead_on)

// == SESSION STATE ============================================================

//@variable True once Friday has passed the hour at which the weekly extreme is
//          treated as set.
bool pastExtremeLock = isFriday
     and (hour(time, tzInput) > lockHour
     or (hour(time, tzInput) == lockHour and minute(time, tzInput) >= lockMinute))

//@variable Fires on the bar where the setup-window swing first confirms.
bool rangeArmed = false
//@variable Fires on the first touch of the target level this week.
bool tapTarget = false
//@variable Fires on the first tap of the retracement zone this week.
bool tapRetrace = false
//@variable Fires on the first tap of the reversal band this week.
bool tapReversal = false

// == WEEKLY RANGE AND ANCHORS =================================================
// The measured range is the whole week: lowest low to highest high. Both anchors
// are weekly extremes, so the range the percentages are cut from is the weekly
// range itself, exactly as the model defines it.
//
// Direction comes from the sequence. The extreme that printed later is the
// terminus the retracement runs back from; the opposite extreme is the origin.
// It is re-read on every confirmed bar, so a week that re-expands and takes out
// its other side flips the measurement rather than holding a stale one.

if barstate.isconfirmed
    HtfArray monthlySlot = htfSlots.get(0)
    HtfArray weeklySlot  = htfSlots.get(1)
    HtfArray dailySlot   = htfSlots.get(2)
    monthlySlot.ingest(mDTop, mDBot, mDKind, mDTime, mPTop, mPBot, mPKind, mPTime, mKnown)
    weeklySlot.ingest(wDTop, wDBot, wDKind, wDTime, wPTop, wPBot, wPKind, wPTime, wKnown)
    dailySlot.ingest(dDTop, dDBot, dDKind, dDTime, dPTop, dPBot, dPKind, dPTime, dKnown)
    for i = 0 to HTF_COUNT - 1
        HtfArray ageing = htfSlots.get(i)
        ageing.retireFilled()

    if na(st.weekHigh) or high > st.weekHigh
        st.weekHigh     := high
        st.weekHighTime := time
    if na(st.weekLow) or low < st.weekLow
        st.weekLow     := low
        st.weekLowTime := time

    if not na(st.weekHigh) and not na(st.weekLow)
        bool terminusIsHigh = st.weekHighTime > st.weekLowTime

        if not st.directionSet or terminusIsHigh != st.terminusIsHigh
            // First read of the week, or the range has flipped. A confirmation
            // taken on the opposite side no longer applies, so it is released.
            st.directionSet   := true
            st.terminusIsHigh := terminusIsHigh
            st.confirmPivot   := na
            st.active         := false
            st.rangeLocked    := false
            st.lastPivotTime  := 0
            st.tappedTarget   := false
            st.tappedRetrace  := false
            st.tappedReversal := false

        // Origin-candle anchoring: each anchor carries the time of the candle that
        // formed it, so its level starts where the extreme was made.
        //
        // The anchors stop tracking once the setup-window swing has confirmed. Structure
        // turning is the statement that the extreme is in, so the range it measures
        // is fixed from that point and the levels a trader is working stay put. The
        // weekly extremes themselves keep updating underneath; if the swing is later
        // broken the lock releases and the anchors catch up to the new extreme.
        bool terminusMoved = false
        if not st.rangeLocked
            int terminusTime = terminusIsHigh ? st.weekHighTime : st.weekLowTime
            if terminusTime != st.anchorBTime
                // The terminus moved, so the pullback measured from it starts over
                // and any draw worked off the old one no longer applies.
                st.retraceExtreme := na
                st.drawSpent      := false
                terminusMoved     := true
            st.anchorA     := terminusIsHigh ? st.weekLow     : st.weekHigh
            st.anchorATime := terminusIsHigh ? st.weekLowTime : st.weekHighTime
            st.anchorB     := terminusIsHigh ? st.weekHigh    : st.weekLow
            st.anchorBTime := terminusTime

        // How far price has come back off the terminus, and whether it had already
        // worked the draw before Friday. The model expects Friday to deliver the
        // give-back; a week that already paid it out on Wednesday has no setup left,
        // however cleanly the rest of the picture reads. The candle that printed the
        // extreme is not part of the pullback: its other end was traded on the way
        // into the extreme, not back out of it, so measuring starts on the next candle.
        if not na(st.anchorB) and not na(st.anchorA) and not terminusMoved
            if st.terminusIsHigh
                st.retraceExtreme := na(st.retraceExtreme) ? low : math.min(st.retraceExtreme, low)
            else
                st.retraceExtreme := na(st.retraceExtreme) ? high : math.max(st.retraceExtreme, high)
            float rangeNow = math.abs(st.anchorA - st.anchorB)
            if rangeNow > 0 and not na(st.retraceExtreme) and not inSetup
                if math.abs(st.anchorB - st.retraceExtreme) / rangeNow >= band1Lo
                    st.drawSpent := true

// == CONFIRMATION: FRIDAY'S HELD SWING ========================================
// The swing does not set a level. It is the gate: inside the setup window the week
// has to turn on the terminus side, on a closed confirmation-timeframe swing, and
// that swing has to hold.

bool pivotInWindow = inSetupWindow(confPivotTime)
bool pivotInWeek   = confPivotTime >= st.weekStart
bool pivotIsFresh  = confPivotTime != st.lastPivotTime

if barstate.isconfirmed and st.directionSet
    // Held check first. A close beyond the confirming swing, further into the
    // expansion, means Friday did not turn there: stand down and wait for the next
    // swing. The reference stays the swing that armed the model, so a ordinary
    // pullback inside the retracement cannot trip it.
    if st.active and (st.terminusIsHigh ? close > st.confirmPivot : close < st.confirmPivot)
        st.active         := false
        st.rangeLocked    := false
        st.confirmPivot   := na
        st.tappedTarget   := false
        st.tappedRetrace  := false
        st.tappedReversal := false

    float candidate = st.terminusIsHigh ? confPivotHigh : confPivotLow
    if not na(candidate) and pivotIsFresh and pivotInWindow and pivotInWeek
        st.lastPivotTime := confPivotTime
        if not st.active
            st.confirmPivot   := candidate
            st.active         := true
            st.rangeLocked    := true
            st.tappedTarget   := false
            st.tappedRetrace  := false
            st.tappedReversal := false
            // No alert on a week with no draw left to work.
            rangeArmed        := not st.drawSpent

// == ZONE GEOMETRY ============================================================

// == HTF DELIVERY =============================================================
// The week must have delivered into a higher-timeframe array on the side opposite
// its own direction: a bullish week rallies into a premium array and exhausts, a
// bearish week drops into a discount one. The check runs against the week's terminus
// extreme, so it is a fact about this week and re-reads correctly on every week in
// history rather than being one setting applied to all of them.

float deliveryFrac = deliveryPct / PERCENT_DIVISOR
bool  tfEnabled0   = useMonthly
bool  tfEnabled1   = useWeekly
bool  tfEnabled2   = useDaily

bool   htfDelivered = false
string htfSource    = NOT_REACHED_TEXT

for i = 0 to HTF_COUNT - 1
    bool enabled = i == 0 ? tfEnabled0 : i == 1 ? tfEnabled1 : tfEnabled2
    if enabled and not htfDelivered
        HtfArray slot = htfSlots.get(i)
        // A array that formed after the extreme printed cannot be what the week
        // delivered into: it is the retracement's own footprint, below a high or above
        // a low by construction.
        if st.terminusIsHigh
            if slot.bearFormed <= st.weekHighTime
                 and deliveredInto(st.weekHigh, slot.bearTop, slot.bearBot, true, deliveryFrac)
                htfDelivered := true
                htfSource    := slot.tf + " " + slot.bearName
        else
            if slot.bullFormed <= st.weekLowTime
                 and deliveredInto(st.weekLow, slot.bullTop, slot.bullBot, false, deliveryFrac)
                htfDelivered := true
                htfSource    := slot.tf + " " + slot.bullName

bool deliveryMet = htfDelivered or not requireDelivery

//@variable True once the week has both extremes. The outline draws from here.
bool anchorsKnown = not na(st.anchorA) and not na(st.anchorB)

//@variable The day the terminus extreme was formed, in the model's timezone.
int terminusDay = anchorsKnown ? dayofweek(st.anchorBTime, tzInput) : na

//@variable Whether the extreme is late enough in the week for a Friday swing to be
//          confirming that extreme rather than something unrelated to it.
bool terminusRecent = not requireRecentTerminus
     or terminusDay == dayofweek.thursday
     or terminusDay == dayofweek.friday

float legRange = anchorsKnown ? math.abs(st.anchorA - st.anchorB) : na

//@variable The zones belong to the setup window, and only where the higher-timeframe
//          array has been reached. Confirmation upgrades their status, it does not gate
//          them: the levels are a draw on liquidity, anticipated rather than waited on.
bool zonesLive = inSetup and deliveryMet and terminusRecent and not st.drawSpent
     and not na(legRange) and legRange > 0

//@variable The zones are drawn on every week with a measurable range, so where the
//          retracement sits can always be checked by eye. Where the model has not
//          qualified the week they are drawn dotted, for reference only.
bool zonesDrawn = anchorsKnown and not na(legRange) and legRange > 0

//@variable Sign of the retracement: back inside the range, from Anchor B toward
//          Anchor A. Negative when the range terminated at the high.
float dirSign = st.terminusIsHigh ? -1.0 : 1.0

float band1EdgeA = st.anchorB + dirSign * band1Lo * legRange
float band1EdgeB = st.anchorB + dirSign * band1Hi * legRange
float band2EdgeA = st.anchorB + dirSign * band2Lo * legRange
float band2EdgeB = st.anchorB + dirSign * band2Hi * legRange

float retraceTop  = math.max(band1EdgeA, band1EdgeB)
float retraceBot  = math.min(band1EdgeA, band1EdgeB)
float reversalTop = math.max(band2EdgeA, band2EdgeB)
float reversalBot = math.min(band2EdgeA, band2EdgeB)

float midlineLevel = st.anchorB + dirSign * band1Mid * legRange
float targetLevel  = st.anchorB + dirSign * targetFrac * legRange
float reversalMid  = (reversalTop + reversalBot) / 2

// The outline is one box around the whole week, from its first candle to just past the
// live candle, top at the week high and bottom at the week low.
//
// The zones do not share that span. A retracement can only begin once the terminus
// extreme exists, so the zones start at the candle that formed it and project right
// from there. Spanning them back across the whole week would draw them over price
// action that predates the measurement.
int barSpanMs = timeframe.in_seconds() * MS_PER_SECOND
int zoneRight = time_close
int zoneLeft  = st.anchorBTime
int bracketX  = zoneRight + BRACKET_GAP_BARS * barSpanMs
int labelX    = bracketX + labelOffsetBars * barSpanMs

string anchorALabelText = st.terminusIsHigh ? WEEK_LOW_LABEL  : WEEK_HIGH_LABEL
string anchorBLabelText = st.terminusIsHigh ? WEEK_HIGH_LABEL : WEEK_LOW_LABEL

// Every callout sits on its own price in the right-hand column. Levels a few
// percent of the week apart are separated by the price axis itself.
float labelYAnchorB  = st.anchorB
float labelYTarget   = targetLevel
float labelYRetrace  = (retraceTop + retraceBot) / 2
float labelYReversal = reversalMid
float labelYAnchorA  = st.anchorA

// == RENDER ===================================================================
// A fixed set of handles for the life of the week: three boxes, two lines, five
// labels. Created once, updated in place, extended right to the current bar,
// deleted on the weekly boundary.

bool drawRetrace  = zonesDrawn and showRetraceZone
bool drawReversal = zonesDrawn and showReversalZone
bool drawMidline  = zonesDrawn and showRetraceZone and showMidline
bool drawOutline  = showOutline and anchorsKnown
bool drawTarget   = zonesDrawn and showTarget

//@variable Solid when the model has qualified the week, dotted when the zones are
//          drawn for reference only.
string zoneStyle = zonesLive ? line.style_solid : line.style_dotted

// -- Target: one solid level at the first objective, running from the terminus
//    extreme's candle to the right edge.

if drawTarget
    if na(targetLine)
        targetLine := line.new(zoneLeft, targetLevel, zoneRight, targetLevel,
             xloc = xloc.bar_time, color = TEXT_INK, style = line.style_solid,
             width = OUTLINE_WIDTH)
    line.set_xy1(targetLine, zoneLeft, targetLevel)
    line.set_xy2(targetLine, zoneRight, targetLevel)
    line.set_style(targetLine, zoneStyle)
else if not na(targetLine)
    line.delete(targetLine)
    targetLine := na

if drawTarget and showLabels
    if na(targetLbl)
        targetLbl := label.new(labelX, labelYTarget, text = targetLabelText,
             xloc = xloc.bar_time, style = label.style_label_left,
             textalign = text.align_left, color = color.new(#000000, 100),
             textcolor = TEXT_INK, size = TXT_SZ)
        label.set_text_font_family(targetLbl, font.family_monospace)
    label.set_xy(targetLbl, labelX, labelYTarget)
    label.set_text(targetLbl, targetLabelText)
else if not na(targetLbl)
    label.delete(targetLbl)
    targetLbl := na

if drawRetrace
    if na(retraceBox)
        retraceBox := box.new(zoneLeft, retraceTop, zoneRight, retraceBot,
             xloc = xloc.bar_time, border_color = retraceBorder,
             border_width = ZONE_BORDER_WIDTH, border_style = line.style_solid,
             bgcolor = retraceFill)
    box.set_left(retraceBox, zoneLeft)
    box.set_right(retraceBox, zoneRight)
    box.set_top(retraceBox, retraceTop)
    box.set_bottom(retraceBox, retraceBot)
    box.set_border_style(retraceBox, zoneStyle)
else if not na(retraceBox)
    box.delete(retraceBox)
    retraceBox := na

if drawRetrace and showLabels
    if na(retraceLbl)
        retraceLbl := label.new(labelX, labelYRetrace, text = retraceLabelText,
             xloc = xloc.bar_time, style = label.style_label_left,
             textalign = text.align_left, color = color.new(#000000, 100),
             textcolor = TEXT_INK, size = TXT_SZ)
        label.set_text_font_family(retraceLbl, font.family_monospace)
    label.set_xy(retraceLbl, labelX, labelYRetrace)
    label.set_text(retraceLbl, retraceLabelText)
else if not na(retraceLbl)
    label.delete(retraceLbl)
    retraceLbl := na

// -- Midline through the retracement band, unlabelled. At the default 20/30 it is
//    the 25% marker the model names alongside the two band edges.

if drawMidline
    if na(midlineLine)
        midlineLine := line.new(zoneLeft, midlineLevel, zoneRight, midlineLevel,
             xloc = xloc.bar_time, color = retraceBorder, style = line.style_dotted,
             width = OUTLINE_WIDTH)
    line.set_xy1(midlineLine, zoneLeft, midlineLevel)
    line.set_xy2(midlineLine, zoneRight, midlineLevel)
else if not na(midlineLine)
    line.delete(midlineLine)
    midlineLine := na

if drawReversal
    if na(reversalBox)
        reversalBox := box.new(zoneLeft, reversalTop, zoneRight, reversalBot,
             xloc = xloc.bar_time, border_color = reversalBorder,
             border_width = ZONE_BORDER_WIDTH, border_style = line.style_solid,
             bgcolor = reversalFill)
    box.set_left(reversalBox, zoneLeft)
    box.set_right(reversalBox, zoneRight)
    box.set_top(reversalBox, reversalTop)
    box.set_bottom(reversalBox, reversalBot)
    box.set_border_style(reversalBox, zoneStyle)
else if not na(reversalBox)
    box.delete(reversalBox)
    reversalBox := na

if drawReversal and showLabels
    if na(reversalLbl)
        reversalLbl := label.new(labelX, labelYReversal, text = reversalLabelText,
             xloc = xloc.bar_time, style = label.style_label_left,
             textalign = text.align_left, color = color.new(#000000, 100),
             textcolor = TEXT_INK, size = TXT_SZ)
        label.set_text_font_family(reversalLbl, font.family_monospace)
    label.set_xy(reversalLbl, labelX, labelYReversal)
    label.set_text(reversalLbl, reversalLabelText)
else if not na(reversalLbl)
    label.delete(reversalLbl)
    reversalLbl := na

// -- Week box: the whole week end to end, first candle to just past the live candle,
//    top at the week high and bottom at the week low. Drawn as soon as both extremes
//    are known, ahead of Friday's confirmation.

float weekTop = math.max(st.anchorA, st.anchorB)
float weekBot = math.min(st.anchorA, st.anchorB)

if drawOutline
    if na(weekBox)
        weekBox := box.new(st.weekStart, weekTop, bracketX, weekBot, xloc = xloc.bar_time,
             border_color = outlineColor, border_width = OUTLINE_WIDTH,
             border_style = line.style_dotted, bgcolor = color.new(#000000, 100))
    box.set_lefttop(weekBox, st.weekStart, weekTop)
    box.set_rightbottom(weekBox, bracketX, weekBot)
    box.set_border_color(weekBox, outlineColor)
else if not na(weekBox)
    box.delete(weekBox)
    weekBox := na

if drawOutline and showLabels
    if na(anchorALbl)
        anchorALbl := label.new(labelX, labelYAnchorA, text = anchorALabelText,
             xloc = xloc.bar_time, style = label.style_label_left,
             textalign = text.align_left, color = color.new(#000000, 100),
             textcolor = TEXT_INK, size = TXT_SZ)
        label.set_text_font_family(anchorALbl, font.family_monospace)
    label.set_xy(anchorALbl, labelX, labelYAnchorA)
    label.set_text(anchorALbl, anchorALabelText)
else if not na(anchorALbl)
    label.delete(anchorALbl)
    anchorALbl := na

if drawOutline and showLabels
    if na(anchorBLbl)
        anchorBLbl := label.new(labelX, labelYAnchorB, text = anchorBLabelText,
             xloc = xloc.bar_time, style = label.style_label_left,
             textalign = text.align_left, color = color.new(#000000, 100),
             textcolor = TEXT_INK, size = TXT_SZ)
        label.set_text_font_family(anchorBLbl, font.family_monospace)
    label.set_xy(anchorBLbl, labelX, labelYAnchorB)
    label.set_text(anchorBLbl, anchorBLabelText)
else if not na(anchorBLbl)
    label.delete(anchorBLbl)
    anchorBLbl := na

// -- HTF arrays. Highest timeframe wins where two overlap in price: a monthly array
//    covering the same ground as a weekly or daily one stands in for both rather than
//    stacking boxes. Raising the per-side count draws the next array down that sits
//    somewhere else. This is display only — the delivery check above already ran
//    against every array found, so decluttering cannot change which weeks qualify.

int bullDrawn = 0
int bearDrawn = 0
for i = 0 to HTF_COUNT - 1
    HtfArray slot = htfSlots.get(i)
    bool enabled  = i == 0 ? tfEnabled0 : i == 1 ? tfEnabled1 : tfEnabled2
    slot.bullShown := false
    slot.bearShown := false

    if enabled and not na(slot.bullTop) and bullDrawn < arraysPerSide
        bool clash = false
        if i > 0
            for j = 0 to i - 1
                HtfArray higher = htfSlots.get(j)
                if higher.bullShown and slot.bullTop >= higher.bullBot
                     and higher.bullTop >= slot.bullBot
                    clash := true
        if not clash
            slot.bullShown := true
            bullDrawn += 1

    if enabled and not na(slot.bearTop) and bearDrawn < arraysPerSide
        bool clash = false
        if i > 0
            for j = 0 to i - 1
                HtfArray higher = htfSlots.get(j)
                if higher.bearShown and slot.bearTop >= higher.bearBot
                     and higher.bearTop >= slot.bearBot
                    clash := true
        if not clash
            slot.bearShown := true
            bearDrawn += 1

for i = 0 to HTF_COUNT - 1
    HtfArray slot  = htfSlots.get(i)
    bool drawBull  = showArrays and slot.bullShown
    bool drawBear  = showArrays and slot.bearShown

    if drawBull
        if na(slot.bullBox)
            slot.bullBox := box.new(slot.bullTime, slot.bullTop, zoneRight, slot.bullBot,
                 xloc = xloc.bar_time, border_color = color.new(arrayBullColor, ARRAY_BORDER_TRANSP),
                 border_width = ZONE_BORDER_WIDTH, border_style = line.style_solid,
                 bgcolor = color.new(arrayBullColor, ARRAY_FILL_TRANSP))
        box.set_lefttop(slot.bullBox, slot.bullTime, slot.bullTop)
        box.set_rightbottom(slot.bullBox, zoneRight, slot.bullBot)
        float bullMid = (slot.bullTop + slot.bullBot) / 2
        if showLabels
            if na(slot.bullLbl)
                slot.bullLbl := label.new(labelX, bullMid, slot.tf + " " + slot.bullName,
                     xloc = xloc.bar_time, style = label.style_label_left,
                     textalign = text.align_left, color = color.new(#000000, 100),
                     textcolor = TEXT_INK, size = TXT_SZ)
                label.set_text_font_family(slot.bullLbl, font.family_monospace)
            label.set_xy(slot.bullLbl, labelX, bullMid)
            label.set_text(slot.bullLbl, slot.tf + " " + slot.bullName)
        else if not na(slot.bullLbl)
            label.delete(slot.bullLbl)
            slot.bullLbl := na
    else
        if not na(slot.bullBox)
            box.delete(slot.bullBox)
            slot.bullBox := na
        if not na(slot.bullLbl)
            label.delete(slot.bullLbl)
            slot.bullLbl := na

    if drawBear
        if na(slot.bearBox)
            slot.bearBox := box.new(slot.bearTime, slot.bearTop, zoneRight, slot.bearBot,
                 xloc = xloc.bar_time, border_color = color.new(arrayBearColor, ARRAY_BORDER_TRANSP),
                 border_width = ZONE_BORDER_WIDTH, border_style = line.style_solid,
                 bgcolor = color.new(arrayBearColor, ARRAY_FILL_TRANSP))
        box.set_lefttop(slot.bearBox, slot.bearTime, slot.bearTop)
        box.set_rightbottom(slot.bearBox, zoneRight, slot.bearBot)
        float bearMid = (slot.bearTop + slot.bearBot) / 2
        if showLabels
            if na(slot.bearLbl)
                slot.bearLbl := label.new(labelX, bearMid, slot.tf + " " + slot.bearName,
                     xloc = xloc.bar_time, style = label.style_label_left,
                     textalign = text.align_left, color = color.new(#000000, 100),
                     textcolor = TEXT_INK, size = TXT_SZ)
                label.set_text_font_family(slot.bearLbl, font.family_monospace)
            label.set_xy(slot.bearLbl, labelX, bearMid)
            label.set_text(slot.bearLbl, slot.tf + " " + slot.bearName)
        else if not na(slot.bearLbl)
            label.delete(slot.bearLbl)
            slot.bearLbl := na
    else
        if not na(slot.bearBox)
            box.delete(slot.bearBox)
            slot.bearBox := na
        if not na(slot.bearLbl)
            label.delete(slot.bearLbl)
            slot.bearLbl := na

// == ZONE INTERACTION =========================================================

if zonesLive and barstate.isconfirmed
    if not st.tappedTarget and high >= targetLevel and low <= targetLevel
        st.tappedTarget := true
        tapTarget       := true
    if not st.tappedRetrace and high >= retraceBot and low <= retraceTop
        st.tappedRetrace := true
        tapRetrace       := true
    if not st.tappedReversal and high >= reversalBot and low <= reversalTop
        st.tappedReversal := true
        tapReversal       := true

// == DASHBOARD ================================================================
// The countdown runs off wall-clock time rather than bar time, so it continues to
// tick between bars. The whole panel is written on the last bar only.

int nowDayOfWeek = dayofweek(timenow, tzInput)
int daysToFriday = dayofweek.friday - nowDayOfWeek
if daysToFriday < 0
    daysToFriday += DAYS_PER_WEEK

// Land on Friday's calendar date, then rebuild the close in-timezone so the
// countdown stays correct either side of a daylight-saving change.
int fridayDateMs  = timenow + daysToFriday * MS_PER_DAY
int fridayCloseMs = timestamp(tzInput, year(fridayDateMs, tzInput), month(fridayDateMs, tzInput),
     dayofmonth(fridayDateMs, tzInput), fridayCloseHour, fridayCloseMinute)
if fridayCloseMs <= timenow
    int nextFridayMs = fridayDateMs + DAYS_PER_WEEK * MS_PER_DAY
    fridayCloseMs := timestamp(tzInput, year(nextFridayMs, tzInput), month(nextFridayMs, tzInput),
         dayofmonth(nextFridayMs, tzInput), fridayCloseHour, fridayCloseMinute)

float targetGap   = zonesDrawn ? math.abs(close - targetLevel) : na
float retraceGap  = zonesDrawn ? zoneDistance(close, retraceTop, retraceBot) : na

string targetGapText = na(targetGap) ? DASH_EMPTY
     : st.tappedTarget ? "Reached"
     : str.tostring(targetGap, format.mintick) + PTS_SUFFIX

int    nyMinuteOfDay = hour(time, tzInput) * MINUTES_PER_HOUR + minute(time, tzInput)
string windowText    = nyMinuteOfDay >= NYAM_KZ_START and nyMinuteOfDay < NYAM_KZ_END ? NYAM_KZ_TEXT
     : nyMinuteOfDay >= NY_OPEN_START and nyMinuteOfDay < NY_OPEN_END ? NY_OPEN_TEXT
     : OUTSIDE_TEXT
float reversalGap = zonesDrawn ? zoneDistance(close, reversalTop, reversalBot) : na

string retraceGapText = switch
    na(retraceGap)  => DASH_EMPTY
    retraceGap == 0 => IN_ZONE_TEXT
    =>                 str.tostring(retraceGap, format.mintick) + PTS_SUFFIX

string reversalGapText = switch
    na(reversalGap)  => DASH_EMPTY
    reversalGap == 0 => IN_ZONE_TEXT
    =>                  str.tostring(reversalGap, format.mintick) + PTS_SUFFIX

string rangeText = na(legRange) ? DASH_EMPTY : str.tostring(legRange, format.mintick) + PTS_SUFFIX

string statusText = switch
    not anchorsKnown   => "Range forming"
    not inSetup        => "Before Thu " + pad2(setupStartHour) + ":00"
    not deliveryMet    => "No HTF delivery"
    (st.drawSpent)     => "Draw already worked"
    not terminusRecent => "Extreme set too early"
    st.active          => st.terminusIsHigh ? "Locked, retrace down" : "Locked, retrace up"
    (pastExtremeLock)  => "Extreme assumed set"
    =>                    st.terminusIsHigh ? "Projected, retrace down" : "Projected, retrace up"

string statusTip = switch
    not anchorsKnown   => "The week has not printed both a high and a low yet."
    not inSetup        => "The TGIF window opens Thursday " + pad2(setupStartHour) + ":00 New York and runs to the end of Friday. Nothing is projected before it."
    not deliveryMet    => "The week's extreme has not traded into a higher-timeframe array on the HTF ARRAY row, so the week can keep expanding. No zones."
    (st.drawSpent)     => "Price already came back 20% or more off the extreme before the window opened. The give-back is spent, so there is no Friday setup."
    not terminusRecent => "The extreme formed before Thursday, and the setting asks for a Thursday or Friday extreme."
    st.active          => "A swing on the confirmation timeframe has formed in the window and is holding on closes. The range is locked."
    (pastExtremeLock)  => "Past the Friday time the extreme is treated as set. Zones are projected; no swing has confirmed."
    =>                    "Zones are drawn in anticipation. A swing on the confirmation timeframe, held on closes, locks them."

string stateWord = zonesLive ? (st.active ? "LOCKED" : "PROJECTED") : zonesDrawn ? "REFERENCE" : ""

if showDash and barstate.islast
    array<string> rows = array.new<string>()
    rows.push(dashEntry("INSTRUMENT", syminfo.ticker, "The symbol being read."))
    rows.push(dashEntry("TIMEFRAME", chartTfText(), "The chart's timeframe."))
    rows.push(dashEntry("STATUS", statusText, statusTip))
    rows.push(dashEntry("FRI CLOSE IN", countdownText(fridayCloseMs - timenow),
         "Time left to Friday " + pad2(fridayCloseHour) + ":" + pad2(fridayCloseMinute)
         + " New York, the end of the TGIF window."))
    if windowText != OUTSIDE_TEXT
        rows.push(dashEntry("SESSION", windowText, "The New York kill zone price is in now."))
    rows.push(dashEntry("HTF ARRAY", htfSource,
         "The higher-timeframe array the week's extreme traded at least " + str.tostring(deliveryPct, PCT_FORMAT)
         + "% into: premium for a week that topped, discount for one that bottomed. Not reached means the precondition is not met yet."))
    if anchorsKnown
        rows.push(dashEntry("WEEK RANGE", rangeText,
             "Week High " + str.tostring(math.max(st.anchorA, st.anchorB), format.mintick) + " - Week Low "
             + str.tostring(math.min(st.anchorA, st.anchorB), format.mintick) + " = " + rangeText
             + ". Every percentage below is cut from this range, measured back from the "
             + (st.terminusIsHigh ? "high." : "low.")))
        rows.push(dashEntry("PRICE IN WEEK",
             rangePositionText(close, math.max(st.weekHigh, high), math.min(st.weekLow, low)),
             "(Price - week low) / (week high - week low). Above 50% is premium, below is discount."))
    if not na(monthHigh) and not na(monthLow) and monthHigh > monthLow
        rows.push(dashEntry("PRICE IN MONTH", rangePositionText(close, monthHigh, monthLow),
             "(Price - month low) / (month high - month low), this month so far. Above 50% is premium."))
    if zonesDrawn
        string fromTxt = (st.terminusIsHigh ? "Week High " : "Week Low ") + str.tostring(st.anchorB, format.mintick)
        string sgn     = st.terminusIsHigh ? " - " : " + "
        rows.push(dashEntry(str.upper(targetLabelText), targetGapText,
             "The first objective. " + fromTxt + sgn + str.tostring(targetPct, PCT_FORMAT) + "% x " + rangeText
             + " = " + str.tostring(targetLevel, format.mintick) + ". The reading is the distance from price to it."))
        rows.push(dashEntry(str.upper(retraceLabelText), retraceGapText,
             "The TGIF draw, " + str.tostring(retraceBot, format.mintick) + " to " + str.tostring(retraceTop, format.mintick)
             + ". The reading is the distance from price to its near edge, IN ZONE when inside."))
        if showReversalZone
            rows.push(dashEntry(str.upper(reversalLabelText), reversalGapText,
                 "Not a target. " + str.tostring(reversalBot, format.mintick) + " to " + str.tostring(reversalTop, format.mintick)
                 + ": a move this far back is a larger reversal, not a Friday retracement."))

    int wantRows = rows.size() + 1
    if na(dash) or dashRowsDrawn != wantRows
        if not na(dash)
            table.delete(dash)
        dash := table.new(dashPosition, DASH_COLUMNS, wantRows, frame_color = #000000,
             frame_width = 1, border_width = 0)
        dashRowsDrawn := wantRows
    table.cell(dash, 0, 0, BRAND_TEXT, text_color = TEXT_INK, text_size = TXT_SZ,
         text_halign = text.align_left, text_font_family = font.family_monospace,
         tooltip = "TGIF: the back of the week gives back 20-30% of the weekly range.")
    table.cell(dash, 1, 0, stateWord, text_color = TEXT_INK, text_size = TXT_SZ,
         text_halign = text.align_left, text_font_family = font.family_monospace,
         tooltip = "PROJECTED: zones drawn in anticipation. LOCKED: a held swing has confirmed the turn. REFERENCE: the week has not qualified, so the zones are dotted and drawn only to check by eye. STATUS says why.")
    for i = 0 to rows.size() - 1
        array<string> parts = str.split(rows.get(i), DASH_SEP)
        dashRow(dash, i + 1, parts.get(0), parts.get(1), parts.get(2))
else if not na(dash)
    table.delete(dash)
    dash := na

// == ALERTS ===================================================================

alertcondition(rangeArmed and zonesLive, "TGIF swing confirmed",
     "TGIF swing confirmed on {{ticker}} - retracement draw active")
alertcondition(tapTarget, "TGIF target reached",
     "Price reached the TGIF target on {{ticker}}")
alertcondition(tapRetrace, "TGIF retracement tap",
     "Price tapping the TGIF retracement zone on {{ticker}}")
alertcondition(tapReversal, "TGIF reversal band tap",
     "Price into the reversal band on {{ticker}} - beyond the TGIF draw")
````
