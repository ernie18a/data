# RIFTS Tap & Break Sniper [NICK789]

- url: https://www.tradingview.com/script/npauQ1TB-RIFTS-Tap-Break-Sniper-NICK789/
- type: indicator
- pine_id: PUB;b637b7e08ce24daf8c8d6681e7cf01dc
- version: 3.0

## Description

RIFTS Tap & Break Sniper [NICK789]

The RIFTS Tap & Break Sniper indicator is built around one core price-action idea:

Price creates or leaves behind a reaction zone, later returns to tap or reject from that zone, and then confirms direction by printing a BOS or CHoCH.

RIFTS stands for:

**R** — Reaction Zones
**I** — Imbalance Gaps
**F** — Flip / Structure Confirmation
**T** — Tap & Break Logic
**S** — Sniper Scoring

Together, these describe the full process used by the script: price creates or leaves behind a zone, returns to tap or reject from it, then confirms direction through BOS or CHoCH before the setup is scored and plotted as a Sniper or Sniper+ signal.

The script is designed to help traders identify tap-and-break structures where a zone reaction and a market-structure break occur together. Instead of showing zones by themselves or structure breaks by themselves, RIFTS connects both steps into one workflow:

1. Price creates a Reaction Block or Imbalance Gap.
2. Price returns to tap the zone.
3. Price rejects from the zone.
4. Price confirms direction with BOS or CHoCH.
5. The script scores the setup and plots a Sniper or Sniper+ signal.

🔶 USAGE

RIFTS identifies two main zone types:

Reaction Blocks
Imbalance Gaps

A setup begins when price creates one of these zones. The script then watches for price to return to the zone and either tap or reject from it.

A bullish setup develops when price interacts with a bullish zone and then confirms upward movement through a bullish structure break.

A bearish setup develops when price interacts with a bearish zone and then confirms downward movement through a bearish structure break.

The signal is not based on the zone alone. The main purpose is to find moments where zone interaction and structure confirmation align.

🔹 Reaction Blocks

Reaction Blocks are candle-based zones created after price displaces away from the previous candle.

A bullish Reaction Block forms when a bullish candle closes above the previous candle’s high while the previous candle was bearish.

A bearish Reaction Block forms when a bearish candle closes below the previous candle’s low while the previous candle was bullish.

The script marks the previous candle range as the reaction area. This area becomes important if price later returns to it and reacts.

The Zone Candle Body % setting controls how strong the displacement candle must be before a Reaction Block is created. Higher values require stronger candle bodies and reduce weaker zones.

🔹 Imbalance Gaps

Imbalance Gaps are created when price moves quickly and leaves an untraded gap between the current candle and the candle two bars back.

A bullish Imbalance Gap forms when the current low is above the high from two candles ago.

A bearish Imbalance Gap forms when the current high is below the low from two candles ago.

These gaps represent fast price movement. If price later returns to the gap, the script monitors whether price reacts from that area and then breaks structure.

🔹 Tap and Reaction Logic

After a Reaction Block or Imbalance Gap is created, the script tracks whether price comes back into the zone.

A zone is considered tapped when price trades back inside the zone.

A bullish reaction occurs when price taps a bullish zone and then closes upward out of that zone.

A bearish reaction occurs when price taps a bearish zone and then closes downward out of that zone.

The reaction candle must pass the selected quality filters:

Reject Body %
Reject Range ATR

These filters help avoid weak touches where price enters a zone but does not show enough rejection strength.

🔹 BOS and CHoCH Confirmation

The script tracks swing highs and swing lows using the Structure Swing Length setting.

When price closes above the last confirmed swing high, the script detects a bullish structure break.

When price closes below the last confirmed swing low, the script detects a bearish structure break.

The structure break is classified as either BOS or CHoCH.

BOS means Break of Structure. It represents continuation in the current structure direction.

CHoCH means Change of Character. It represents a break against the previous market bias and may suggest a possible directional shift.

CHoCH and BOS lines are drawn on the chart so users can see exactly which structure level was broken.

🔶 SIGNAL MODES

The Sniper Confirmation setting controls how strict the setup must be before a signal appears.

Reaction Only

A signal can appear when price reacts from a valid zone. This is the fastest mode because it does not require a BOS or CHoCH confirmation.

Tap + Structure

A signal requires price to tap a valid zone and then break structure in the signal direction.

Reaction + Structure

A signal requires both a valid zone reaction and a BOS or CHoCH confirmation. This mode is designed for traders who want zone rejection and structure confirmation together.

🔹 Structure Trigger Type

The Structure Trigger Type setting controls which structure events can trigger signals.

Both
Allows both BOS and CHoCH.

CHoCH Only
Only allows change-of-character signals.

BOS Only
Only allows break-of-structure signals.

This lets traders focus on reversal-style setups, continuation-style setups, or both.

🔶 SNIPER SCORE

Each setup receives a score based on the conditions that are present.

The score can include:

Zone tap or zone reaction
BOS or CHoCH confirmation
Fresh reaction timing
Optional volume confirmation
Optional EMA trend confirmation

A Sniper signal appears when the setup reaches the minimum score threshold.

A Sniper+ signal appears when the setup reaches the higher Sniper+ threshold.

The score is a confluence model. It does not predict guaranteed profit. It simply shows how many of the script’s conditions are aligned.

🔹 Volume Filter

When enabled, the Volume Filter requires current volume to be above a selected moving average multiplier.

Volume MA Length controls the volume average.

Volume Multiplier controls how much stronger current volume must be compared with the average.

This filter can help reduce signals during weaker volume conditions.

🔹 EMA Trend Filter

When enabled, the EMA Trend Filter checks whether price is on the correct side of the selected EMA.

Bullish signals require price to be above the EMA.

Bearish signals require price to be below the EMA.

This filter is optional and can be used when traders want signals to align with broader trend direction.

🔶 TRADE PLAN GUIDE

When a Sniper or Sniper+ signal appears, the script can draw a simple trade plan guide.

Entry is based on the signal candle close.

Stop loss is placed beyond the reaction zone with an optional ATR buffer.

TP1, TP2, and TP3 are calculated using the selected R multiples.

The trade plan is only a visual guide. It does not place trades, manage trades, or act as a strategy tester.

🔶 VISUAL DISPLAY

The script can display:

Bullish and bearish Reaction Blocks
Bullish and bearish Imbalance Gaps
CHoCH and BOS structure lines
Sniper and Sniper+ markers
Latest Entry / SL / TP guide
Master alert and separate bull/bear alert conditions

Used zones and overlapping same-side zones are visually cleaned up to keep the chart easier to read.

🔶 SETTINGS

Core Zones

Show Zones
Toggles the display of Reaction Blocks and Imbalance Gaps.

Reaction Blocks
Enables or disables Reaction Block detection.

Imbalance Gaps
Enables or disables Imbalance Gap detection.

Hide Broken Zones
Removes invalidated zones from the chart.

Max Stored Zones
Controls how many zones are stored and tracked.

Zone Candle Body %
Sets the minimum candle body percentage required to create a zone.

Sniper Logic

Sniper Confirmation
Chooses Reaction Only, Tap + Structure, or Reaction + Structure.

Structure Swing Length
Controls the swing pivot length used for BOS and CHoCH detection.

Structure Trigger Type
Chooses whether BOS, CHoCH, or both can trigger signals.

Reaction Valid Bars
Controls how long a zone reaction remains valid for confirmation.

Confirm Signal On Candle Close
When enabled, signals only appear after the candle closes.

Quality Filters

ATR Length
Controls the ATR used for rejection and stop-buffer calculations.

Reject Body %
Sets the minimum body size required for a valid rejection candle.

Reject Range ATR
Sets the minimum candle range relative to ATR for rejection quality.

Require Break Displacement
Requires BOS/CHoCH candles to pass body and ATR strength filters.

Break Body %
Sets the minimum body size required for a valid structure break.

Break Range ATR
Sets the minimum candle range relative to ATR for a valid structure break.

Score Filters

Use Volume Filter
Requires volume confirmation before allowing signals.

Volume MA Length
Controls the moving average used for volume comparison.

Volume Multiplier
Controls how strong current volume must be compared with its average.

Use EMA Trend Filter
Requires signals to align with the EMA trend filter.

EMA Trend Length
Controls the EMA used for trend filtering.

Show Sniper+ Only
Hides normal Sniper signals and only shows Sniper+ signals.

Min Sniper Score
Minimum score required for a normal Sniper signal.

Sniper+ Score
Minimum score required for a Sniper+ signal.

Visuals

Show CHoCH/BOS Lines
Toggles structure lines on the chart.

Max Structure Lines
Controls how many structure lines remain visible.

Show Latest Entry / SL / TP
Toggles the trade plan guide.

RR Lines Bars Ahead
Controls how far the trade plan guide extends to the right.

TP1 R, TP2 R, TP3 R
Controls the risk-multiple targets.

SL ATR Buffer
Adds an ATR-based buffer beyond the reaction zone for the stop guide.

Alerts

The script includes alert conditions for:

Master Sniper signal
Bull Sniper
Bear Sniper
Bull Sniper+
Bear Sniper+

A dynamic master alert option is also available for traders who want alert messages that include symbol, timeframe, close price, and score.

🔶 HOW TO READ THE SIGNALS

A bullish Sniper signal means price has interacted with a bullish zone and passed the selected confirmation rules.

A bearish Sniper signal means price has interacted with a bearish zone and passed the selected confirmation rules.

A Sniper+ signal means the setup reached the higher score threshold.

BOS labels can help identify continuation-style structure breaks.

CHoCH labels can help identify possible shift or reversal-style structure breaks.

The Entry / SL / TP guide is only for planning and should be adjusted to each trader’s own risk management.

🔶 IMPORTANT NOTES

This script is a confluence and visualization tool. It does not guarantee future price movement.

Signals are based on reaction zones, zone taps, rejection candles, and BOS/CHoCH structure breaks.

Swing structure requires confirmed pivots, so BOS and CHoCH lines appear only after the selected swing length confirms the structure point.

Lower timeframes may produce more frequent signals and more noise.

Higher timeframes may produce fewer but cleaner structure events.

Best results usually come from combining the script with higher timeframe context, market session awareness, and proper risk control.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator(
     "RIFTS Tap & Break Sniper [NICK789]",
     shorttitle = "RIFTS",
     overlay = true,
     max_boxes_count = 120,
     max_labels_count = 120,
     max_lines_count = 140,
     max_bars_back = 600)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string G1 = "Core Zones"
showZones       = input.bool(true, "Show Zones", group = G1)
showRB          = input.bool(true, "Reaction Blocks", group = G1)
showGAP         = input.bool(true, "Imbalance Gaps", group = G1)
hideBroken      = input.bool(true, "Hide Broken Zones", group = G1)
maxZones        = input.int(22, "Max Stored Zones", minval = 5, maxval = 60, group = G1)
zoneBodyFilter  = input.float(45.0, "Zone Candle Body %", minval = 0, maxval = 100, step = 1, group = G1)

string G2 = "Sniper Logic + Structure"
signalMode = input.string(
     "Reaction + Structure",
     "Sniper Confirmation",
     options = ["Reaction Only", "Tap + Structure", "Reaction + Structure"],
     group = G2)
sniperStructureSource = input.string(
     "Classic",
     "Structure Confirmation Mode",
     options = ["Classic", "Responsive", "Major"],
     tooltip = "Choose how CHoCH/BOS confirms sniper setups. Classic RIFTS pivot logic. Responsive reacts to smaller local structure for earlier entries, but can be noisier. Major uses larger swing structure for cleaner context, but signals can come later.",
     group = G2)
classicLen = input.int(5, "Classic Structure Length", minval = 2, maxval = 30, group = G2)
responsiveLen = input.int(5, "Responsive Structure Length", minval = 2, maxval = 30, group = G2)
swingLen = input.int(50, "Major Structure Length", minval = 10, maxval = 100, group = G2)
showStructureMarks = input.bool(true, "Show CHoCH/BOS Lines", group = G2)
structureDisplayMode = input.string(
     "Selected",
     "Structure Lines To Show",
     options = ["Selected", "Classic", "Responsive", "Major", "Responsive + Major", "All"],
     tooltip = "Selected shows only the CHoCH/BOS mode used for signals. Responsive + Major shows entry timing with larger structure context. All displays every layer.",
     group = G2)
structureTriggerMode = input.string("Both", "Structure Trigger Type", options = ["Both", "CHoCH Only", "BOS Only"], group = G2)
structureBreakSource = input.string("Close", "Structure Break Source", options = ["Close", "Wick"], group = G2)
reactionWindow = input.int(50, "Reaction Valid Bars", minval = 1, maxval = 300, group = G2)
confirmOnClose = input.bool(true, "Confirm Signal On Candle Close", group = G2)

string G3 = "Quality Filters"
atrLen = input.int(14, "ATR Length", minval = 1, maxval = 100, group = G3)
minRejectBodyPct = input.float(35.0, "Reject Body %", minval = 0, maxval = 100, step = 1, group = G3)
minRejectRangeAtr = input.float(0.10, "Reject Range ATR", minval = 0, maxval = 5, step = 0.05, group = G3)
requireBreakDisplacement = input.bool(false, "Require Break Displacement For Sniper", group = G3)
breakMinBodyPct = input.float(35.0, "Break Body %", minval = 0, maxval = 100, step = 1, group = G3)
breakMinRangeAtr = input.float(0.10, "Break Range ATR", minval = 0, maxval = 5, step = 0.05, group = G3)
oppositeZoneGuard = input.string(
     "Off",
     "Opposite Zone Guard",
     options = ["Off", "Warn Only", "Block Signal"],
     tooltip = "Warns or blocks sniper signals that fire into an active opposite reaction zone without clearing it.",
     group = G3)
oppositeZoneGuardSource = input.string(
     "Reaction Blocks Only",
     "Guard Zone Type",
     options = ["Reaction Blocks Only", "Reaction Blocks + Gaps"],
     tooltip = "Reaction Blocks Only guards the cleaner RB zones. Reaction Blocks + Gaps also treats imbalance gaps as opposing zones.",
     group = G3)
oppositeZoneClearAtr = input.float(
     0.00,
     "Zone Clear Buffer ATR",
     minval = 0,
     maxval = 2,
     step = 0.05,
     tooltip = "Extra ATR clearance required beyond the opposite zone before the signal is no longer considered conflicted.",
     group = G3)

string G4 = "Score Filters"
useVolumeFilter = input.bool(false, "Use Volume Filter", group = G4)
volLen = input.int(20, "Volume MA Length", minval = 1, maxval = 200, group = G4)
volSurge = input.float(1.20, "Volume Multiplier", minval = 0.1, maxval = 5, step = 0.05, group = G4)
useTrendFilter = input.bool(false, "Use EMA Trend Filter", group = G4)
trendLen = input.int(50, "EMA Trend Length", minval = 1, maxval = 300, group = G4)
sniperPlusOnly = input.bool(false, "Show Sniper+ Only", group = G4)
minScore = input.int(60, "Min Sniper Score", minval = 0, maxval = 100, group = G4)
hqScore = input.int(80, "Sniper+ Score", minval = 0, maxval = 100, group = G4)

string G5 = "Visuals"
maxStructureMarks = input.int(60, "Max Structure Lines", minval = 10, maxval = 80, group = G5)
showCandleTrendColor = input.bool(false, "Color Candles By Trend", group = G5)
candleBullCol = input.color(#00ffcc, "Bull Candle Color", group = G5)
candleBearCol = input.color(#ff007f, "Bear Candle Color", group = G5)
showTradePlan = input.bool(true, "Show Latest Entry / SL / TP", group = G5)
rrAheadBars = input.int(10, "RR Lines Bars Ahead", minval = 1, maxval = 50, group = G5)
tp1R = input.float(0.5, "TP1 R", minval = 0.1, maxval = 20, step = 0.1, group = G5)
tp2R = input.float(1.0, "TP2 R", minval = 0.1, maxval = 20, step = 0.1, group = G5)
tp3R = input.float(1.5, "TP3 R", minval = 0.1, maxval = 20, step = 0.1, group = G5)
stopAtrBuffer = input.float(0.20, "SL ATR Buffer", minval = 0, maxval = 5, step = 0.05, group = G5)
hideUsedZoneBoxes        = input.bool(true, "Hide Used Zones", group = G5)
useVisualOverlapCleanup = input.bool(true, "Auto Clean Overlapping Zones", group = G5)
visualOverlapThreshold  = input.float(0.45, "Overlap Cleanup Strength", minval = 0.10, maxval = 1.00, step = 0.05, group = G5)

string G6 = "Alerts"
useDynamicAlert = input.bool(false, "Use Dynamic Master alert()", group = G6)

color bullZoneColor = color.new(#089981, 82)
color bearZoneColor = color.new(#f23645, 82)
color bullGapColor = color.new(#089981, 92)
color bearGapColor = color.new(#f23645, 92)
color bullReactColor = color.new(#00c853, 76)
color bearReactColor = color.new(#ff1744, 76)
color brokenColor = color.new(color.gray, 92)
color structureColor = color.new(color.gray, 35)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type Zone
    float top
    float bottom
    int left
    bool isBull
    bool isRB
    bool active
    bool tapped
    bool reacted
    bool used
    bool invalidated
    int touchBar
    int reactBar
    box bx

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GLOBALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var zones = array.new<Zone>()
var structureLabels = array.new<label>()
var structureLines = array.new<line>()

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var float lastBrokenHigh = na
var float lastBrokenLow = na
var int classicBias = 0

var int responsiveLeg = 0
var int swingLeg = 0

var float responsiveHighLevel = na
var float responsiveLowLevel = na
var int responsiveHighBar = na
var int responsiveLowBar = na
var bool responsiveHighCrossed = true
var bool responsiveLowCrossed = true
var int responsiveBias = 0

var float swingHighLevel = na
var float swingLowLevel = na
var int swingHighBar = na
var int swingLowBar = na
var bool swingHighCrossed = true
var bool swingLowCrossed = true
var int swingBias = 0

var line planEntryLine = na
var line planSLLine = na
var line planTP1Line = na
var line planTP2Line = na
var line planTP3Line = na

var label planEntryLabel = na
var label planSLLabel = na
var label planTP1Label = na
var label planTP2Label = na
var label planTP3Label = na

var int planAnchorBar = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_body_pct(float o, float h, float l, float c) =>
    float rng = h - l
    rng > 0 ? math.abs(c - o) / rng * 100.0 : 0.0

f_next_structure_leg(int len, int currentLeg) =>
    int nextLeg = currentLeg
    bool canCheck = bar_index > len
    bool newHighPivot = canCheck and high[len] > ta.highest(high, len)
    bool newLowPivot = canCheck and low[len] < ta.lowest(low, len)

    if newHighPivot
        nextLeg := -1
    else if newLowPivot
        nextLeg := 1

    nextLeg

f_overlap(float t1, float b1, float t2, float b2) =>
    float overlap = math.max(0.0, math.min(t1, t2) - math.max(b1, b2))
    float size1 = t1 - b1
    float size2 = t2 - b2
    size1 > 0 and size2 > 0 ? overlap / math.min(size1, size2) > 0.70 : false

f_zone_idx_valid(int idx) =>
    not na(idx) and idx >= 0 and idx < array.size(zones)

f_zone_fill(bool isBull, bool isRB, bool reacted, bool invalidated) =>
    invalidated ? brokenColor :
     reacted and isBull ? bullReactColor :
     reacted and not isBull ? bearReactColor :
     isRB and isBull ? bullZoneColor :
     isRB and not isBull ? bearZoneColor :
     isBull ? bullGapColor :
     bearGapColor

f_zone_border(bool isBull, bool isRB) =>
    color.new(isBull ? #089981 : #f23645, isRB ? 35 : 70)

f_zone_text(bool isBull, bool isRB) =>
    (isBull ? "Bull " : "Bear ") + (isRB ? "RB" : "GAP")

f_overlap_ratio(float t1, float b1, float t2, float b2) =>
    float overlap = math.max(0.0, math.min(t1, t2) - math.max(b1, b2))
    float size1 = math.max(t1 - b1, syminfo.mintick)
    float size2 = math.max(t2 - b2, syminfo.mintick)
    overlap / math.min(size1, size2)

f_should_draw_zone(int idx) =>
    bool visible = true
    int zoneCount = array.size(zones)

    if idx >= 0 and idx < zoneCount
        Zone z = array.get(zones, idx)

        if z.invalidated and hideBroken
            visible := false
        else if z.used and hideUsedZoneBoxes
            visible := false
        else if useVisualOverlapCleanup and z.active and not z.invalidated and idx < zoneCount - 1
            for j = idx + 1 to zoneCount - 1
                Zone newer = array.get(zones, j)

                if newer.active and not newer.invalidated and not (newer.used and hideUsedZoneBoxes) and newer.isBull == z.isBull
                    float ov = f_overlap_ratio(z.top, z.bottom, newer.top, newer.bottom)
                    bool sameKind = newer.isRB == z.isRB
                    bool newerInsideOld = newer.top <= z.top and newer.bottom >= z.bottom
                    bool oldInsideNewer = newer.top >= z.top and newer.bottom <= z.bottom
                    bool nested = newerInsideOld or oldInsideNewer

                    if ov >= visualOverlapThreshold or (sameKind and nested)
                        visible := false
                        break

    visible

f_is_duplicate(float top, float bottom, bool isBull, bool isRB) =>
    bool duplicated = false

    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)

            if z.active and not z.invalidated and z.isBull == isBull and z.isRB == isRB
                if f_overlap(top, bottom, z.top, z.bottom)
                    duplicated := true
                    break

    duplicated

f_delete_zone(Zone z) =>
    if not na(z.bx)
        box.delete(z.bx)

f_create_zone(float top, float bottom, int leftBar, bool isBull, bool isRB) =>
    box bx = na

    if showZones
        bx := box.new(
             left = leftBar,
             top = top,
             right = bar_index,
             bottom = bottom,
             bgcolor = f_zone_fill(isBull, isRB, false, false),
             border_color = f_zone_border(isBull, isRB),
             border_style = isRB ? line.style_solid : line.style_dashed,
             border_width = isRB ? 2 : 1,
             text = f_zone_text(isBull, isRB),
             text_color = color.new(isBull ? #089981 : #f23645, 25),
             text_size = size.tiny,
             text_halign = text.align_center,
             text_valign = text.align_center)

    Zone.new(top, bottom, leftBar, isBull, isRB, true, false, false, false, false, na, na, bx)

f_push_structure_mark(int x1, int x2, float y, string txt, bool isBull, bool isSignal) =>
    if showStructureMarks
        color markColor = isSignal ? (isBull ? #00ffbb : #ff1744) : structureColor

        line ln = line.new(
             x1 = x1,
             y1 = y,
             x2 = x2,
             y2 = y,
             color = markColor,
             style = line.style_dashed,
             width = isSignal ? 2 : 1)

        label lbl = label.new(
             x = int(math.round((x1 + x2) / 2.0)),
             y = y,
             text = txt,
             style = isBull ? label.style_label_down : label.style_label_up,
             color = color.new(chart.bg_color, 100),
             textcolor = markColor,
             size = size.tiny)

        array.push(structureLines, ln)
        array.push(structureLabels, lbl)

        while array.size(structureLines) > maxStructureMarks
            line oldLine = array.shift(structureLines)
            line.delete(oldLine)

        while array.size(structureLabels) > maxStructureMarks
            label oldLbl = array.shift(structureLabels)
            label.delete(oldLbl)

f_delete_trade_plan() =>
    if not na(planEntryLine)
        line.delete(planEntryLine)
    if not na(planSLLine)
        line.delete(planSLLine)
    if not na(planTP1Line)
        line.delete(planTP1Line)
    if not na(planTP2Line)
        line.delete(planTP2Line)
    if not na(planTP3Line)
        line.delete(planTP3Line)

    if not na(planEntryLabel)
        label.delete(planEntryLabel)
    if not na(planSLLabel)
        label.delete(planSLLabel)
    if not na(planTP1Label)
        label.delete(planTP1Label)
    if not na(planTP2Label)
        label.delete(planTP2Label)
    if not na(planTP3Label)
        label.delete(planTP3Label)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASE SERIES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
atrSafe = math.max(nz(atr), syminfo.mintick)
candleRange = high - low
bodyPct = f_body_pct(open, high, low, close)

avgVol = ta.sma(volume, volLen)
volPass = not useVolumeFilter or (not na(avgVol) and avgVol > 0 and volume >= avgVol * volSurge)

trendEma = ta.ema(close, trendLen)
bullTrendPass = not useTrendFilter or close >= trendEma
bearTrendPass = not useTrendFilter or close <= trendEma

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE TREND COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
candleTrendAtr = ta.sma(high - low, 50)
candleUpperBand = hl2 + 3.5 * candleTrendAtr
candleLowerBand = hl2 - 3.5 * candleTrendAtr

var float candleTrendStop = na
var int candleTrend = 1

candleTrendStop := candleTrend == 1 ? math.max(candleLowerBand, nz(candleTrendStop[1], candleLowerBand)) : math.min(candleUpperBand, nz(candleTrendStop[1], candleUpperBand))

if close > candleTrendStop[1] and close[1] <= candleTrendStop[1]
    candleTrend := 1
    candleTrendStop := candleLowerBand
else if close < candleTrendStop[1] and close[1] >= candleTrendStop[1]
    candleTrend := -1
    candleTrendStop := candleUpperBand

barcolor(showCandleTrendColor ? candleTrend == 1 ? candleBullCol : candleBearCol : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE CREATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
zoneBodyPass = bodyPct >= zoneBodyFilter

bullGap = showGAP and low > high[2] and close > open and zoneBodyPass
bearGap = showGAP and high < low[2] and close < open and zoneBodyPass

bullRB = showRB and close > high[1] and close > open and close[1] < open[1] and zoneBodyPass
bearRB = showRB and close < low[1] and close < open and close[1] > open[1] and zoneBodyPass

if barstate.isconfirmed
    if bullGap and not f_is_duplicate(low, high[2], true, false)
        array.push(zones, f_create_zone(low, high[2], bar_index - 2, true, false))

    if bearGap and not f_is_duplicate(low[2], high, false, false)
        array.push(zones, f_create_zone(low[2], high, bar_index - 2, false, false))

    if bullRB and not f_is_duplicate(high[1], low[1], true, true)
        array.push(zones, f_create_zone(high[1], low[1], bar_index - 1, true, true))

    if bearRB and not f_is_duplicate(high[1], low[1], false, true)
        array.push(zones, f_create_zone(high[1], low[1], bar_index - 1, false, true))

while array.size(zones) > maxZones
    Zone oldZone = array.shift(zones)
    f_delete_zone(oldZone)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ZONE TRACKING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool bullTapReady = false
bool bearTapReady = false
bool bullReady = false
bool bearReady = false
bool bullReactionNow = false
bool bearReactionNow = false

int bullTapIdx = na
int bearTapIdx = na
int bullReadyIdx = na
int bearReadyIdx = na
int bullReactIdx = na
int bearReactIdx = na

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)

        bool inZone = z.active and not z.invalidated and high >= z.bottom and low <= z.top
        bool newReaction = false

        if z.active and not z.invalidated
            if inZone
                z.tapped := true
                z.touchBar := na(z.touchBar) ? bar_index : z.touchBar

            bool broken = z.isBull ? close < z.bottom : close > z.top

            if broken
                z.active := false
                z.invalidated := true

                if hideBroken
                    f_delete_zone(z)
                    z.bx := na

            bool rejectRangePass = minRejectRangeAtr <= 0 or candleRange >= atrSafe * minRejectRangeAtr
            bool rejectBodyPass = bodyPct >= minRejectBodyPct

            bool bullReject = z.isBull and z.tapped and close > open and close > z.top and rejectRangePass and rejectBodyPass
            bool bearReject = not z.isBull and z.tapped and close < open and close < z.bottom and rejectRangePass and rejectBodyPass

            if z.active and not z.used and not z.reacted and (bullReject or bearReject)
                z.reacted := true
                z.reactBar := bar_index
                newReaction := true

            if z.active and not z.used
                if z.isBull and z.tapped and na(bullTapIdx)
                    bullTapReady := true
                    bullTapIdx := i

                if not z.isBull and z.tapped and na(bearTapIdx)
                    bearTapReady := true
                    bearTapIdx := i

                bool recentReaction = z.reacted and not na(z.reactBar) and bar_index - z.reactBar <= reactionWindow

                if z.isBull and recentReaction and na(bullReadyIdx)
                    bullReady := true
                    bullReadyIdx := i

                if not z.isBull and recentReaction and na(bearReadyIdx)
                    bearReady := true
                    bearReadyIdx := i

                if newReaction and z.isBull and na(bullReactIdx)
                    bullReactionNow := true
                    bullReactIdx := i

                if newReaction and not z.isBull and na(bearReactIdx)
                    bearReactionNow := true
                    bearReactIdx := i

        bool drawZone = f_should_draw_zone(i)

        if not na(z.bx)
            if drawZone and showZones
                box.set_left(z.bx, z.left)
                box.set_right(z.bx, bar_index)
                box.set_top(z.bx, z.top)
                box.set_bottom(z.bx, z.bottom)
                box.set_bgcolor(z.bx, f_zone_fill(z.isBull, z.isRB, z.reacted, z.invalidated))
                box.set_border_color(z.bx, f_zone_border(z.isBull, z.isRB))
                box.set_border_style(z.bx, z.isRB ? line.style_solid : line.style_dashed)
                box.set_text(z.bx, f_zone_text(z.isBull, z.isRB))
                box.set_text_color(z.bx, color.new(z.isBull ? #089981 : #f23645, 25))
            else
                box.set_right(z.bx, z.left)
                box.set_bgcolor(z.bx, color.new(color.gray, 100))
                box.set_border_color(z.bx, color.new(color.gray, 100))
                box.set_text(z.bx, "")

        array.set(zones, i, z)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPPOSITE ZONE GUARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool oppositeZoneGuardOn = oppositeZoneGuard != "Off"
bool oppositeZoneBlocks = oppositeZoneGuard == "Block Signal"
bool guardRbOnly = oppositeZoneGuardSource == "Reaction Blocks Only"

bool bullOppZoneConflict = false
bool bearOppZoneConflict = false

if oppositeZoneGuardOn and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)

        bool guardKindPass = guardRbOnly ? z.isRB : true
        bool liveGuardZone = z.active and not z.invalidated and not z.used and guardKindPass
        bool tappedGuardZone = high >= z.bottom and low <= z.top
        bool bullClearedBearZone = close > z.top + atrSafe * oppositeZoneClearAtr
        bool bearClearedBullZone = close < z.bottom - atrSafe * oppositeZoneClearAtr

        if liveGuardZone and not z.isBull and tappedGuardZone and not bullClearedBearZone and not bullOppZoneConflict
            bullOppZoneConflict := true

        if liveGuardZone and z.isBull and tappedGuardZone and not bearClearedBullZone and not bearOppZoneConflict
            bearOppZoneConflict := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRUCTURE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Three selectable structure modes:
// Classic = the classic RIFTS pivot model.
// Responsive = smaller local CHoCH/BOS timing for earlier entries.
// Major   = slower swing structure context.

// Classic pivot memory
classicPh = ta.pivothigh(high, classicLen, classicLen)
classicPl = ta.pivotlow(low, classicLen, classicLen)

if not na(classicPh)
    lastSwingHigh := classicPh
    lastSwingHighBar := bar_index - classicLen

if not na(classicPl)
    lastSwingLow := classicPl
    lastSwingLowBar := bar_index - classicLen

bool useWickBreak = structureBreakSource == "Wick"
float bullBreakSource = useWickBreak ? high : close
float bullBreakPrevSource = useWickBreak ? high[1] : close[1]
float bearBreakSource = useWickBreak ? low : close
float bearBreakPrevSource = useWickBreak ? low[1] : close[1]

classicBullBreakRaw = not na(lastSwingHigh) and bullBreakSource > lastSwingHigh and bullBreakPrevSource <= lastSwingHigh
classicBearBreakRaw = not na(lastSwingLow) and bearBreakSource < lastSwingLow and bearBreakPrevSource >= lastSwingLow

classicBullBreak = classicBullBreakRaw and (na(lastBrokenHigh) or lastBrokenHigh != lastSwingHigh)
classicBearBreak = classicBearBreakRaw and (na(lastBrokenLow) or lastBrokenLow != lastSwingLow)

classicBullBreakIsChoch = classicBullBreak and classicBias == -1
classicBearBreakIsChoch = classicBearBreak and classicBias == 1
classicBullBreakIsBos = classicBullBreak and not classicBullBreakIsChoch
classicBearBreakIsBos = classicBearBreak and not classicBearBreakIsChoch

if classicBullBreak
    lastBrokenHigh := lastSwingHigh
    classicBias := 1

if classicBearBreak
    lastBrokenLow := lastSwingLow
    classicBias := -1

// Responsive pivot memory
int nextResponsiveLeg = f_next_structure_leg(responsiveLen, responsiveLeg)
bool responsiveNewPivot = nextResponsiveLeg != responsiveLeg
bool responsivePivotLow = responsiveNewPivot and nextResponsiveLeg == 1
bool responsivePivotHigh = responsiveNewPivot and nextResponsiveLeg == -1

if responsiveNewPivot
    if responsivePivotLow
        responsiveLowLevel := low[responsiveLen]
        responsiveLowBar := bar_index - responsiveLen
        responsiveLowCrossed := false
    else if responsivePivotHigh
        responsiveHighLevel := high[responsiveLen]
        responsiveHighBar := bar_index - responsiveLen
        responsiveHighCrossed := false

responsiveLeg := nextResponsiveLeg

// Swing pivot memory
int nextSwingLeg = f_next_structure_leg(swingLen, swingLeg)
bool swingNewPivot = nextSwingLeg != swingLeg
bool swingPivotLow = swingNewPivot and nextSwingLeg == 1
bool swingPivotHigh = swingNewPivot and nextSwingLeg == -1

if swingNewPivot
    if swingPivotLow
        swingLowLevel := low[swingLen]
        swingLowBar := bar_index - swingLen
        swingLowCrossed := false
    else if swingPivotHigh
        swingHighLevel := high[swingLen]
        swingHighBar := bar_index - swingLen
        swingHighCrossed := false

swingLeg := nextSwingLeg

// Responsive breaks
bool responsiveBullBreak = not na(responsiveHighLevel) and not responsiveHighCrossed and bullBreakSource > responsiveHighLevel and bullBreakPrevSource <= responsiveHighLevel
bool responsiveBearBreak = not na(responsiveLowLevel) and not responsiveLowCrossed and bearBreakSource < responsiveLowLevel and bearBreakPrevSource >= responsiveLowLevel

bool responsiveBullBreakIsChoch = responsiveBullBreak and responsiveBias == -1
bool responsiveBearBreakIsChoch = responsiveBearBreak and responsiveBias == 1
bool responsiveBullBreakIsBos = responsiveBullBreak and not responsiveBullBreakIsChoch
bool responsiveBearBreakIsBos = responsiveBearBreak and not responsiveBearBreakIsChoch

if responsiveBullBreak
    responsiveHighCrossed := true
    responsiveBias := 1

if responsiveBearBreak
    responsiveLowCrossed := true
    responsiveBias := -1

// Swing breaks
bool swingBullBreak = not na(swingHighLevel) and not swingHighCrossed and bullBreakSource > swingHighLevel and bullBreakPrevSource <= swingHighLevel
bool swingBearBreak = not na(swingLowLevel) and not swingLowCrossed and bearBreakSource < swingLowLevel and bearBreakPrevSource >= swingLowLevel

bool swingBullBreakIsChoch = swingBullBreak and swingBias == -1
bool swingBearBreakIsChoch = swingBearBreak and swingBias == 1
bool swingBullBreakIsBos = swingBullBreak and not swingBullBreakIsChoch
bool swingBearBreakIsBos = swingBearBreak and not swingBearBreakIsChoch

if swingBullBreak
    swingHighCrossed := true
    swingBias := 1

if swingBearBreak
    swingLowCrossed := true
    swingBias := -1

// Selected structure layer for sniper confirmation
bool useClassicForSniper = sniperStructureSource == "Classic"
bool useResponsiveForSniper = sniperStructureSource == "Responsive"
bool useSwingForSniper = sniperStructureSource == "Major"

bullBreak = useClassicForSniper ? classicBullBreak : useResponsiveForSniper ? responsiveBullBreak : swingBullBreak
bearBreak = useClassicForSniper ? classicBearBreak : useResponsiveForSniper ? responsiveBearBreak : swingBearBreak

bullBreakIsChoch = useClassicForSniper ? classicBullBreakIsChoch : useResponsiveForSniper ? responsiveBullBreakIsChoch : swingBullBreakIsChoch
bearBreakIsChoch = useClassicForSniper ? classicBearBreakIsChoch : useResponsiveForSniper ? responsiveBearBreakIsChoch : swingBearBreakIsChoch

bullBreakIsBos = useClassicForSniper ? classicBullBreakIsBos : useResponsiveForSniper ? responsiveBullBreakIsBos : swingBullBreakIsBos
bearBreakIsBos = useClassicForSniper ? classicBearBreakIsBos : useResponsiveForSniper ? responsiveBearBreakIsBos : swingBearBreakIsBos


bullBreakDisplacement = not requireBreakDisplacement or (close > open and bodyPct >= breakMinBodyPct and candleRange >= atrSafe * breakMinRangeAtr)
bearBreakDisplacement = not requireBreakDisplacement or (close < open and bodyPct >= breakMinBodyPct and candleRange >= atrSafe * breakMinRangeAtr)

bullStructTypePass =
     structureTriggerMode == "Both" or
     (structureTriggerMode == "CHoCH Only" and bullBreakIsChoch) or
     (structureTriggerMode == "BOS Only" and bullBreakIsBos)

bearStructTypePass =
     structureTriggerMode == "Both" or
     (structureTriggerMode == "CHoCH Only" and bearBreakIsChoch) or
     (structureTriggerMode == "BOS Only" and bearBreakIsBos)

bullStructRawPass = bullBreak and bullBreakDisplacement
bearStructRawPass = bearBreak and bearBreakDisplacement

bullStructPass = bullStructRawPass and bullStructTypePass
bearStructPass = bearStructRawPass and bearStructTypePass

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SNIPER SCORE + SIGNAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int bullScore = 0
int bearScore = 0

bullScore += bullReady ? 35 : bullTapReady ? 20 : 0
bullScore += bullStructPass ? 30 : 0
bullScore += bullReactionNow ? 20 : bullReady ? 10 : 0
bullScore += volPass ? 10 : 0
bullScore += bullTrendPass ? 5 : 0

bearScore += bearReady ? 35 : bearTapReady ? 20 : 0
bearScore += bearStructPass ? 30 : 0
bearScore += bearReactionNow ? 20 : bearReady ? 10 : 0
bearScore += volPass ? 10 : 0
bearScore += bearTrendPass ? 5 : 0

bullScore := math.min(bullScore, 100)
bearScore := math.min(bearScore, 100)

bullBase = switch signalMode
    "Reaction Only" => bullReactionNow
    "Tap + Structure" => bullTapReady and bullStructPass
    => bullReady and bullStructPass

bearBase = switch signalMode
    "Reaction Only" => bearReactionNow
    "Tap + Structure" => bearTapReady and bearStructPass
    => bearReady and bearStructPass

bullSignalIndex = signalMode == "Reaction Only" ? bullReactIdx : signalMode == "Tap + Structure" ? bullTapIdx : bullReadyIdx
bearSignalIndex = signalMode == "Reaction Only" ? bearReactIdx : signalMode == "Tap + Structure" ? bearTapIdx : bearReadyIdx

scoreThreshold = sniperPlusOnly ? hqScore : minScore

bullSetupRaw = bullBase and bullScore >= scoreThreshold and volPass and bullTrendPass and f_zone_idx_valid(bullSignalIndex) and (not confirmOnClose or barstate.isconfirmed)
bearSetupRaw = bearBase and bearScore >= scoreThreshold and volPass and bearTrendPass and f_zone_idx_valid(bearSignalIndex) and (not confirmOnClose or barstate.isconfirmed)

bullFireRaw = bullSetupRaw and (not bearSetupRaw or bullScore >= bearScore)
bearFireRaw = bearSetupRaw and (not bullSetupRaw or bearScore > bullScore)

bullZoneConflictWarn = oppositeZoneGuardOn and bullFireRaw and bullOppZoneConflict
bearZoneConflictWarn = oppositeZoneGuardOn and bearFireRaw and bearOppZoneConflict

bullSetup = bullSetupRaw and not (oppositeZoneBlocks and bullOppZoneConflict)
bearSetup = bearSetupRaw and not (oppositeZoneBlocks and bearOppZoneConflict)

bullFire = bullSetup and (not bearSetup or bullScore >= bearScore)
bearFire = bearSetup and (not bullSetup or bearScore > bullScore)

isHqBull = bullFire and bullScore >= hqScore
isHqBear = bearFire and bearScore >= hqScore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRUCTURE LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool showClassicMarks = showStructureMarks and (structureDisplayMode == "Classic" or structureDisplayMode == "All" or (structureDisplayMode == "Selected" and useClassicForSniper))
bool showResponsiveMarks = showStructureMarks and (structureDisplayMode == "Responsive" or structureDisplayMode == "Responsive + Major" or structureDisplayMode == "All" or (structureDisplayMode == "Selected" and useResponsiveForSniper))
bool showSwingMarks = showStructureMarks and (structureDisplayMode == "Major" or structureDisplayMode == "Responsive + Major" or structureDisplayMode == "All" or (structureDisplayMode == "Selected" and useSwingForSniper))

if classicBullBreak and showClassicMarks
    string txt = classicBullBreakIsChoch ? "CHoCH" : "BOS"
    bool signalMark = useClassicForSniper and bullFire
    f_push_structure_mark(lastSwingHighBar, bar_index, lastSwingHigh, txt, true, signalMark)

if classicBearBreak and showClassicMarks
    string txt = classicBearBreakIsChoch ? "CHoCH" : "BOS"
    bool signalMark = useClassicForSniper and bearFire
    f_push_structure_mark(lastSwingLowBar, bar_index, lastSwingLow, txt, false, signalMark)

if responsiveBullBreak and showResponsiveMarks
    string txt = responsiveBullBreakIsChoch ? "CHoCH" : "BOS"
    bool signalMark = useResponsiveForSniper and bullFire
    f_push_structure_mark(responsiveHighBar, bar_index, responsiveHighLevel, txt, true, signalMark)

if responsiveBearBreak and showResponsiveMarks
    string txt = responsiveBearBreakIsChoch ? "CHoCH" : "BOS"
    bool signalMark = useResponsiveForSniper and bearFire
    f_push_structure_mark(responsiveLowBar, bar_index, responsiveLowLevel, txt, false, signalMark)

if swingBullBreak and showSwingMarks
    string txt = swingBullBreakIsChoch ? "CHoCH" : "BOS"
    bool signalMark = useSwingForSniper and bullFire
    f_push_structure_mark(swingHighBar, bar_index, swingHighLevel, txt, true, signalMark)

if swingBearBreak and showSwingMarks
    string txt = swingBearBreakIsChoch ? "CHoCH" : "BOS"
    bool signalMark = useSwingForSniper and bearFire
    f_push_structure_mark(swingLowBar, bar_index, swingLowLevel, txt, false, signalMark)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     bullFire and not isHqBull,
     title = "Bull Sniper",
     style = shape.triangleup,
     location = location.belowbar,
     color = #089981,
     size = size.small,
     text = "SNIPER",
     textcolor = chart.fg_color)

plotshape(
     isHqBull,
     title = "Bull Sniper+",
     style = shape.triangleup,
     location = location.belowbar,
     color = #00ffbb,
     size = size.small,
     text = "SNIPER+",
     textcolor = chart.fg_color)

plotshape(
     bearFire and not isHqBear,
     title = "Bear Sniper",
     style = shape.triangledown,
     location = location.abovebar,
     color = #f23645,
     size = size.small,
     text = "SNIPER",
     textcolor = chart.fg_color)

plotshape(
     isHqBear,
     title = "Bear Sniper+",
     style = shape.triangledown,
     location = location.abovebar,
     color = #ff1744,
     size = size.small,
     text = "SNIPER+",
     textcolor = chart.fg_color)

plotshape(
     bullZoneConflictWarn,
     title = "Bull Opposite Zone Warning",
     style = shape.xcross,
     location = location.abovebar,
     color = #ffcc00,
     size = size.tiny,
     text = "OPP",
     textcolor = #ffcc00)

plotshape(
     bearZoneConflictWarn,
     title = "Bear Opposite Zone Warning",
     style = shape.xcross,
     location = location.belowbar,
     color = #ffcc00,
     size = size.tiny,
     text = "OPP",
     textcolor = #ffcc00)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE PLAN
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if not showTradePlan and not na(planEntryLine)
    f_delete_trade_plan()
    planEntryLine := na
    planSLLine := na
    planTP1Line := na
    planTP2Line := na
    planTP3Line := na
    planEntryLabel := na
    planSLLabel := na
    planTP1Label := na
    planTP2Label := na
    planTP3Label := na
    planAnchorBar := na

if showTradePlan and (bullFire or bearFire)
    bool isBullPlan = bullFire and not bearFire ? true : bearFire and not bullFire ? false : bullScore >= bearScore
    int planIdx = isBullPlan ? bullSignalIndex : bearSignalIndex

    if f_zone_idx_valid(planIdx)
        Zone z = array.get(zones, planIdx)

        f_delete_trade_plan()
        planEntryLine := na
        planSLLine := na
        planTP1Line := na
        planTP2Line := na
        planTP3Line := na
        planEntryLabel := na
        planSLLabel := na
        planTP1Label := na
        planTP2Label := na
        planTP3Label := na
        planAnchorBar := na

        float entry = close
        float sl = isBullPlan ? math.min(z.bottom, low) - atrSafe * stopAtrBuffer : math.max(z.top, high) + atrSafe * stopAtrBuffer
        float risk = math.abs(entry - sl)
        bool validRisk = risk > syminfo.mintick and (isBullPlan ? entry > sl : entry < sl)

        if validRisk
            float tp1 = isBullPlan ? entry + risk * tp1R : entry - risk * tp1R
            float tp2 = isBullPlan ? entry + risk * tp2R : entry - risk * tp2R
            float tp3 = isBullPlan ? entry + risk * tp3R : entry - risk * tp3R

            color entryCol = color.new(color.white, 20)
            color slCol = color.new(isBullPlan ? #f23645 : #089981, 0)
            color tpCol = color.new(isBullPlan ? #089981 : #f23645, 0)

            planAnchorBar := bar_index
            int rrX2 = bar_index + rrAheadBars

            planEntryLine := line.new(planAnchorBar, entry, rrX2, entry, color = entryCol, style = line.style_dashed, width = 1)
            planSLLine := line.new(planAnchorBar, sl, rrX2, sl, color = slCol, style = line.style_solid, width = 2)
            planTP1Line := line.new(planAnchorBar, tp1, rrX2, tp1, color = color.new(tpCol, 45), style = line.style_dashed, width = 1)
            planTP2Line := line.new(planAnchorBar, tp2, rrX2, tp2, color = color.new(tpCol, 25), style = line.style_dashed, width = 1)
            planTP3Line := line.new(planAnchorBar, tp3, rrX2, tp3, color = tpCol, style = line.style_solid, width = 2)

            planEntryLabel := label.new(rrX2, entry, "ENTRY " + str.tostring(entry, format.mintick), color = color.new(color.black, 100), textcolor = entryCol, style = label.style_label_left, size = size.tiny)
            planSLLabel := label.new(rrX2, sl, "SL " + str.tostring(sl, format.mintick), color = color.new(color.black, 100), textcolor = slCol, style = label.style_label_left, size = size.tiny)
            planTP1Label := label.new(rrX2, tp1, "TP1 " + str.tostring(tp1R, "#.#") + "R", color = color.new(color.black, 100), textcolor = color.new(tpCol, 45), style = label.style_label_left, size = size.tiny)
            planTP2Label := label.new(rrX2, tp2, "TP2 " + str.tostring(tp2R, "#.#") + "R", color = color.new(color.black, 100), textcolor = color.new(tpCol, 25), style = label.style_label_left, size = size.tiny)
            planTP3Label := label.new(rrX2, tp3, "TP3 " + str.tostring(tp3R, "#.#") + "R", color = color.new(color.black, 100), textcolor = tpCol, style = label.style_label_left, size = size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KEEP RR LINES AHEAD OF CURRENT CHART
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if showTradePlan and not na(planEntryLine)
    int rrLiveX2 = bar_index + rrAheadBars
    int rrX1 = na(planAnchorBar) ? bar_index : planAnchorBar

    line.set_x1(planEntryLine, rrX1)
    line.set_x2(planEntryLine, rrLiveX2)
    line.set_x1(planSLLine, rrX1)
    line.set_x2(planSLLine, rrLiveX2)
    line.set_x1(planTP1Line, rrX1)
    line.set_x2(planTP1Line, rrLiveX2)
    line.set_x1(planTP2Line, rrX1)
    line.set_x2(planTP2Line, rrLiveX2)
    line.set_x1(planTP3Line, rrX1)
    line.set_x2(planTP3Line, rrLiveX2)

    label.set_x(planEntryLabel, rrLiveX2)
    label.set_x(planSLLabel, rrLiveX2)
    label.set_x(planTP1Label, rrLiveX2)
    label.set_x(planTP2Label, rrLiveX2)
    label.set_x(planTP3Label, rrLiveX2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK USED ZONE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bullFire and f_zone_idx_valid(bullSignalIndex)
    Zone z = array.get(zones, bullSignalIndex)
    z.used := true
    if not na(z.bx)
        if hideUsedZoneBoxes
            box.set_right(z.bx, z.left)
            box.set_bgcolor(z.bx, color.new(color.gray, 100))
            box.set_border_color(z.bx, color.new(color.gray, 100))
            box.set_text(z.bx, "")
        else
            box.set_text(z.bx, "USED")
            box.set_bgcolor(z.bx, color.new(#089981, 90))
    array.set(zones, bullSignalIndex, z)

if bearFire and f_zone_idx_valid(bearSignalIndex)
    Zone z = array.get(zones, bearSignalIndex)
    z.used := true
    if not na(z.bx)
        if hideUsedZoneBoxes
            box.set_right(z.bx, z.left)
            box.set_bgcolor(z.bx, color.new(color.gray, 100))
            box.set_border_color(z.bx, color.new(color.gray, 100))
            box.set_text(z.bx, "")
        else
            box.set_text(z.bx, "USED")
            box.set_bgcolor(z.bx, color.new(#f23645, 90))
    array.set(zones, bearSignalIndex, z)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC MASTER ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if useDynamicAlert and bullFire
    alert(
         "RIFTS Bull " + (isHqBull ? "SNIPER+" : "SNIPER") +
         " | " + syminfo.ticker +
         " | TF " + timeframe.period +
         " | Close " + str.tostring(close, format.mintick) +
         " | Score " + str.tostring(bullScore) +
         (bullZoneConflictWarn ? " | Opposite Zone Warning" : ""),
         alert.freq_once_per_bar_close)

if useDynamicAlert and bearFire
    alert(
         "RIFTS Bear " + (isHqBear ? "SNIPER+" : "SNIPER") +
         " | " + syminfo.ticker +
         " | TF " + timeframe.period +
         " | Close " + str.tostring(close, format.mintick) +
         " | Score " + str.tostring(bearScore) +
         (bearZoneConflictWarn ? " | Opposite Zone Warning" : ""),
         alert.freq_once_per_bar_close)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullFire or bearFire, title = "RIFTS Master Signal", message = "RIFTS Master Signal on {{ticker}} @ {{close}}")
alertcondition(bullFire and not isHqBull, title = "Bull Sniper Entry", message = "Bull Sniper Entry on {{ticker}} @ {{close}}")
alertcondition(bearFire and not isHqBear, title = "Bear Sniper Entry", message = "Bear Sniper Entry on {{ticker}} @ {{close}}")
alertcondition(isHqBull, title = "Bull Sniper+ Entry", message = "Bull Sniper+ Entry on {{ticker}} @ {{close}}")
alertcondition(isHqBear, title = "Bear Sniper+ Entry", message = "Bear Sniper+ Entry on {{ticker}} @ {{close}}")
````
