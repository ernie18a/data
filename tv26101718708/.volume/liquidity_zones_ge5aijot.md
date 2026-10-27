# Liquidity Zones

- url: https://www.tradingview.com/script/Ge5aiJoT-Liquidity-Zones/
- type: indicator
- pine_id: PUB;0554766a23d2458089c4f4710168bfa5
- version: 1.0

## Description

Liquidity Zones automatically identifies and displays potentially significant support and resistance zones formed around confirmed local price highs and lows.
The indicator helps traders analyze:
• market structure;
• areas where price may react;
• repeated returns into a zone;
• trading volume associated with candles overlapping the zone;
• zone invalidation or loss of relevance;
• the position of the current price relative to nearby structural areas.
Within this indicator, the term “liquidity zone” refers to a structural price area formed around a confirmed pivot.
The indicator does not use order book data, does not detect the actual number of resting limit orders, and does not display real order book liquidity.
Liquidity Zones does not generate Buy or Sell signals and is not a complete trading system.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 INDICATOR CONCEPT
A traditional horizontal level represents a single price. In practice, however, market reactions rarely occur at one exact price.
For this reason, the indicator works with price ranges rather than isolated horizontal levels. Each range is derived from the candle that formed a confirmed local pivot.
Every zone follows its own lifecycle:
It originates from a local high or low.
It is confirmed after the required number of candles has closed.
Its price range is calculated.
Information about retests and overlapping volume is accumulated.
It remains active until it is broken or replaced by a newer zone.
It remains visible as part of the historical market structure.
The user therefore sees not only the location of a zone, but also its current state.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📍 HOW LOCAL PIVOTS ARE IDENTIFIED
The calculations are based on confirmed Pivot Highs and Pivot Lows.
The Pivot Lookback setting defines the number of candles used on each side of a potential pivot.
A Pivot High is confirmed when the high of the candidate candle remains a local high relative to the selected number of candles on both its left and right sides.
A Pivot Low is confirmed when the low of the candidate candle remains a local low relative to the selected number of candles on both its left and right sides.
For example, with Pivot Lookback set to 15, the indicator uses:
• 15 candles to the left of the potential pivot;
• the pivot candle itself;
• 15 candles to the right of the potential pivot.
The zone becomes known only after all candles required to confirm the pivot have closed.
A higher Pivot Lookback generally identifies larger and less frequent structural pivots.
A lower value makes the algorithm more sensitive and produces more local zones.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧱 HOW THE ZONE RANGE IS CALCULATED
The Swing Area setting provides two methods for defining the zone.
🔹 Wick Extremity
This mode uses the part of the pivot candle located between its body and the outer end of its wick.
For a resistance zone, the range is formed between:
• the upper edge of the pivot candle body;
• the high of the pivot candle.
For a support zone, the range is formed between:
• the low of the pivot candle;
• the lower edge of the pivot candle body.
This mode creates narrower zones around the wicks of pivot candles.
🔹 Full Range
This mode uses the complete range of the pivot candle:
• from its low;
• to its high.
It creates a wider zone that includes both the candle body and its wicks.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 RESISTANCE ZONES
A resistance zone is formed from a confirmed Pivot High.
Its outer boundary is the high of the pivot candle.
Resistance zones are displayed in red by default.
The user can:
• enable or disable resistance zones;
• change the level line color;
• change the zone fill color.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟢 SUPPORT ZONES
A support zone is formed from a confirmed Pivot Low.
Its outer boundary is the low of the pivot candle.
Support zones are displayed in green by default.
The user can:
• enable or disable support zones;
• change the level line color;
• change the zone fill color.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
♻️ ZONE LIFECYCLE
The indicator separately tracks:
• one current resistance zone;
• one current support zone.
When a new Pivot High is confirmed, the previous active resistance zone is retired.
When a new Pivot Low is confirmed, the previous active support zone is also retired.
This preserves historical market structure while keeping the latest confirmed zone of each type visually relevant.
Active zones extend to the right of the latest chart candle.
Broken or retired zones stop extending and are displayed with reduced visual intensity.
The algorithm distinguishes between two separate states.
💥 Broken
Price has violated the outer boundary of the zone according to the selected break confirmation method.
🕰 Retired
The zone has not necessarily been broken, but it is no longer the current zone because a newer confirmed zone of the same type has appeared.
Separating these states allows the user to distinguish an actual boundary break from a normal update in market structure.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ BREAK CONFIRMATION
The Break Confirmation setting determines when a zone is considered broken.
🔹 Close
A resistance zone is considered broken when a completed candle closes above the upper zone boundary.
A support zone is considered broken when a completed candle closes below the lower zone boundary.
In this mode, a wick crossing the boundary is not sufficient.
🔹 Wick
A resistance zone is considered broken when the high of a completed candle moves above the upper boundary.
A support zone is considered broken when the low of a completed candle moves below the lower boundary.
This mode is more sensitive because even a temporary wick movement beyond the boundary can invalidate the zone.
Zone state changes are processed only after the relevant candle has completed.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔁 HOW RETESTS ARE COUNTED
When Filter By = Retests is selected, zones are evaluated by the number of separate price returns.
A retest is recorded only after the following sequence occurs:
Price leaves the zone.
Price remains outside the zone.
Price later returns into the zone.
After this return, the retest counter increases by one.
Several consecutive candles remaining inside the same zone are not counted as several separate retests.
The original pivot candle that formed the zone is also not counted as a retest.
When price has not yet left and returned to the zone, the zone is marked as:
Fresh
The Minimum setting defines the minimum number of retests required before a zone is displayed.
For example:
• Minimum = 0 displays both fresh and retested zones;
• Minimum = 1 hides zones without a confirmed return;
• Minimum = 2 displays only zones with at least two separate retests.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 OVERLAP VOLUME FILTERING
When Filter By = Overlap Volume is selected, the indicator measures the cumulative volume of candles whose price ranges overlap the zone.
A candle is considered to overlap a zone when:
• its high is not below the lower zone boundary;
• its low is not above the upper zone boundary.
The full volume of every overlapping candle is added to the calculation.
The volume of the original pivot candle is also included in Overlap Volume.
It is important to understand that Overlap Volume is not a volume profile and does not show the exact distribution of transactions within the price zone.
The algorithm does not determine which portion of a candle’s volume was traded specifically inside the zone. It adds the full volume of every candle whose range partially or fully overlaps the zone.
In this mode, the Minimum setting defines the minimum accumulated Overlap Volume required for a zone to be displayed.
On instruments without available or representative volume data, this filtering method may provide limited information.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏳ STATE RECONSTRUCTION AFTER PIVOT CONFIRMATION
A pivot becomes known only after the required number of candles to its right has closed.
During the period between the original pivot candle and its confirmation, price may already have:
• left the future zone;
• returned into it;
• crossed its range several times;
• accumulated trading volume;
• broken its outer boundary.
To avoid ignoring these events, the indicator reconstructs the zone lifecycle after the pivot is confirmed.
It processes the candles between the original pivot candle and the confirmation candle in chronological order.
During this reconstruction, the algorithm evaluates:
• price exits from the zone;
• separate returns into the zone;
• accumulated Overlap Volume;
• possible zone breaks;
• the resulting zone state.
As a result, the newly confirmed zone immediately reflects the price behavior that has already occurred instead of starting its calculations only from the confirmation candle.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💎 ORIGINALITY AND PRACTICAL VALUE
Liquidity Zones is not a mechanical combination of unrelated indicators.
All components of the script operate as parts of one unified model describing the lifecycle of a structural price zone.
The algorithm combines:
• confirmed local pivot detection;
• zone construction from the pivot candle;
• a choice between wick-based and full-range zones;
• reconstruction of events that occurred before pivot confirmation;
• counting separate price returns instead of every overlapping candle;
• accumulation of volume from candles overlapping the zone;
• two independent break confirmation methods;
• separation of broken and retired zones;
• preservation of historical market structure;
• visual emphasis on the latest active zone of each type;
• direct display of zone information on the chart.
The practical value of this approach is that the user receives more than a static support or resistance line.
The indicator provides information about:
• the full zone range;
• the zone type;
• its current state;
• the number of separate retests;
• accumulated Overlap Volume;
• distance from the current price;
• zone age;
• the selected break confirmation method;
• the pivot confirmation period.
This allows the zone to be evaluated as an evolving structural object rather than as a fixed horizontal level.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏷 ACTIVE ZONE LABELS
The Show Active Zone Labels setting enables or disables labels for current active zones.
The following abbreviations are used:
• R — Resistance zone;
• S — Support zone;
• Fresh — a zone without a separate confirmed return;
• retest or retests — the number of recorded price returns.
🔹 Compact
Displays:
• the zone type;
• the value of its outer boundary;
• the number of retests.
🔹 Detailed
Additionally displays accumulated Overlap Volume.
When the user hovers over a label, the tooltip provides:
• zone type and status;
• full price range;
• outer boundary value;
• zone width as a percentage;
• number of retests;
• accumulated Overlap Volume;
• zone age in bars;
• distance from the current price to the nearest zone edge;
• selected break confirmation method;
• Pivot Lookback value;
• explanations of the Retests and Overlap Volume calculations.
Labels are displayed only for active zones that pass the selected filter.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ INDICATOR SETTINGS
🔸 Pivot Lookback
The number of candles used on each side of a potential local pivot.
Higher values identify larger and less frequent structural pivots.
Lower values increase the sensitivity of the algorithm.
🔸 Swing Area
Defines the width of the zone:
• Wick Extremity — the wick area of the pivot candle;
• Full Range — the complete range of the pivot candle.
🔸 Filter By
Selects the filtering method:
• Retests;
• Overlap Volume.
🔸 Minimum
The minimum value of the selected filtering metric required before the zone is displayed.
🔸 Break Confirmation
Selects the zone break method:
• Close;
• Wick.
🔸 Show Active Zone Labels
Enables or disables labels for active zones.
🔸 Label Detail
Selects the compact or detailed label format.
🔸 Resistance
Enables, disables, and customizes resistance zone colors.
🔸 Support
Enables, disables, and customizes support zone colors.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧩 EXAMPLE SETUP AND USAGE
1️⃣ Select a chart timeframe that corresponds to your analysis horizon.
2️⃣ Configure Pivot Lookback.
A higher value helps identify larger structural pivots.
A lower value provides a more sensitive view of local price movements.
3️⃣ Select Swing Area.
Wick Extremity creates narrower zones around candle wicks.
Full Range uses the complete pivot candle range.
4️⃣ Select the filtering method.
Retests evaluates the number of separate price returns.
Overlap Volume evaluates the accumulated volume of candles that crossed or touched the zone.
5️⃣ Set the Minimum value.
This setting hides zones that have not yet reached the required filter threshold.
6️⃣ Select Break Confirmation.
Close requires a completed candle to close beyond the zone boundary.
Wick detects a boundary violation based on the wick of a completed candle.
7️⃣ Use the zones as analytical context together with:
• market structure;
• trend direction;
• volatility;
• trading volume;
• price action;
• personal risk management rules.
A touch of a zone does not mean that price will necessarily reverse.
A zone break also does not guarantee that price will continue moving in the same direction.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ INDICATOR LIMITATIONS
• A zone is confirmed with a delay equal to the Pivot Lookback value.
• On historical charts, the zone begins at the original pivot candle, although in real time it becomes known only after the required candles to the right have closed.
• If a zone passes the selected filter at a later point, its visual display still begins from the original pivot candle.
• The displayed areas are a mathematical interpretation of price structure and not information about actual resting limit orders.
• Overlap Volume uses the full volume of an overlapping candle and does not determine the portion traded specifically inside the zone.
• The quality and meaning of volume data depend on the market, instrument, and data source.
• Only the latest confirmed support zone and the latest confirmed resistance zone remain active at the same time.
• Settings require adjustment for the selected instrument, timeframe, and current volatility.
• The indicator does not calculate the probability of a price reaction.
• The indicator does not predict the direction of future price movement.
• The indicator does not contain entry or exit rules.
• The indicator does not determine Stop Loss, Take Profit, or position size.
• The indicator is not a strategy and does not perform historical testing of a trading system.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡 RISK DISCLAIMER
Liquidity Zones is an analytical tool designed to assist with the study of price structure.
It should not be used as the sole basis for making a trading decision.
All trading decisions, parameter selection, zone interpretation, and risk management remain the responsibility of the user.
Past price behavior around the displayed zones does not guarantee a similar reaction in the future.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0.
// © 2026 MarketStructureLab

//@version=6
indicator(
     "Liquidity Zones",
     shorttitle = "Liquidity Zones",
     overlay = true,
     max_bars_back = 1000,
     max_lines_count = 300,
     max_boxes_count = 300,
     max_labels_count = 10
 )

// =============================================================================
// Constants
// =============================================================================

const int PROJECTION_BARS = 3

const string AREA_WICK = "Wick Extremity"
const string AREA_FULL = "Full Range"

const string FILTER_RETESTS = "Retests"
const string FILTER_VOLUME = "Overlap Volume"

const string BREAK_CLOSE = "Close"
const string BREAK_WICK = "Wick"

const string LABEL_COMPACT = "Compact"
const string LABEL_DETAILED = "Detailed"

const string GROUP_ZONES = "Liquidity Zones"
const string GROUP_LABELS = "Labels"
const string GROUP_STYLE = "Style"

const color BULL_COLOR = color.rgb(64, 217, 143)
const color BEAR_COLOR = color.rgb(246, 113, 113)

const string TT_PIVOT =
     "Number of bars used on each side of a pivot. " +
     "A zone is confirmed only after this number of bars has closed."

const string TT_AREA =
     "Wick Extremity uses the area between the candle body and wick. " +
     "Full Range uses the complete high-to-low range of the pivot candle."

const string TT_FILTER =
     "Retests counts separate returns after price has left the zone. " +
     "Overlap Volume sums the full volume of bars whose ranges overlap the zone."

const string TT_BREAK =
     "Close invalidates a zone only after a candle closes beyond its boundary. " +
     "Wick invalidates a zone when a completed candle trades beyond its boundary."

const string TT_MINIMUM =
     "Minimum number of retests or minimum overlap volume required " +
     "before the zone is displayed."

// =============================================================================
// Inputs
// =============================================================================

int pivotLookbackInput = input.int(
     15,
     "Pivot Lookback",
     minval = 1,
     maxval = 500,
     tooltip = TT_PIVOT,
     display = display.none,
     group = GROUP_ZONES
 )

string swingAreaInput = input.string(
     AREA_WICK,
     "Swing Area",
     options = [AREA_WICK, AREA_FULL],
     tooltip = TT_AREA,
     display = display.none,
     group = GROUP_ZONES
 )

string filterModeInput = input.string(
     FILTER_RETESTS,
     "Filter By",
     options = [FILTER_RETESTS, FILTER_VOLUME],
     inline = "filter",
     tooltip = TT_FILTER,
     display = display.none,
     group = GROUP_ZONES
 )

float minFilterValueInput = input.float(
     0.0,
     "Minimum",
     minval = 0.0,
     inline = "filter",
     tooltip = TT_MINIMUM,
     display = display.none,
     group = GROUP_ZONES
 )

string breakModeInput = input.string(
     BREAK_CLOSE,
     "Break Confirmation",
     options = [BREAK_CLOSE, BREAK_WICK],
     tooltip = TT_BREAK,
     display = display.none,
     group = GROUP_ZONES
 )

bool showZoneLabelsInput = input.bool(
     true,
     "Show Active Zone Labels",
     display = display.none,
     group = GROUP_LABELS
 )

string labelDetailInput = input.string(
     LABEL_COMPACT,
     "Label Detail",
     options = [LABEL_COMPACT, LABEL_DETAILED],
     display = display.none,
     group = GROUP_LABELS
 )

bool showResistanceInput = input.bool(
     true,
     "Resistance",
     inline = "resistance",
     display = display.none,
     group = GROUP_STYLE
 )

color resistanceLevelColorInput = input.color(
     color.new(BEAR_COLOR, 20),
     "",
     inline = "resistance",
     display = display.none,
     group = GROUP_STYLE
 )

color resistanceAreaColorInput = input.color(
     color.new(BEAR_COLOR, 50),
     "Area",
     inline = "resistance",
     display = display.none,
     group = GROUP_STYLE
 )

bool showSupportInput = input.bool(
     true,
     "Support",
     inline = "support",
     display = display.none,
     group = GROUP_STYLE
 )

color supportLevelColorInput = input.color(
     color.new(BULL_COLOR, 20),
     "",
     inline = "support",
     display = display.none,
     group = GROUP_STYLE
 )

color supportAreaColorInput = input.color(
     color.new(BULL_COLOR, 50),
     "Area",
     inline = "support",
     display = display.none,
     group = GROUP_STYLE
 )

// =============================================================================
// Zone object
// =============================================================================

// @type Stores the state and drawings of one support or resistance zone.
type Zone
    bool isResistance = false
    float top = na
    float bottom = na
    int startIndex = na

    int retests = 0
    float overlapVolume = 0.0
    bool hasVolume = false
    bool wasInside = true

    bool isBroken = false
    bool isRetired = false
    int endIndex = na

    line levelLine = na
    box areaBox = na
    label infoLabel = na

// =============================================================================
// Formatting helpers
// =============================================================================

formatPrice(float value) =>
    str.tostring(value, format.mintick)

formatVolume(float value, bool available) =>
    available ? str.tostring(value, format.volume) : "N/A"

formatRetests(int value) =>
    string result =
         value == 0 ?
         "Fresh" :
         str.tostring(value) +
         (value == 1 ? " retest" : " retests")

    result

// =============================================================================
// Zone information methods
// =============================================================================

// @function Returns true while a zone is active.
method isActive(Zone this) =>
    not this.isBroken and not this.isRetired

// @function Returns the boundary used to confirm a zone break.
method boundary(Zone this) =>
    this.isResistance ? this.top : this.bottom

// @function Returns the base line color assigned to the zone.
method baseLevelColor(Zone this) =>
    this.isResistance ?
         resistanceLevelColorInput :
         supportLevelColorInput

// @function Returns the base area color assigned to the zone.
method baseAreaColor(Zone this) =>
    this.isResistance ?
         resistanceAreaColorInput :
         supportAreaColorInput

// @function Returns the line color according to the zone state.
method visualLevelColor(Zone this) =>
    color result =
         this.isBroken ?
         color.new(this.baseLevelColor(), 45) :
         this.isRetired ?
         color.new(this.baseLevelColor(), 65) :
         this.baseLevelColor()

    result

// @function Returns the area color according to the zone state.
method visualAreaColor(Zone this) =>
    color result =
         this.isBroken ?
         color.new(this.baseAreaColor(), 82) :
         this.isRetired ?
         color.new(this.baseAreaColor(), 88) :
         this.baseAreaColor()

    result

// @function Checks whether the zone passes the selected filter.
method passesFilter(Zone this) =>
    bool result =
         filterModeInput == FILTER_RETESTS ?
         this.retests >= minFilterValueInput :
         this.hasVolume and
         this.overlapVolume >= minFilterValueInput

    result

// @function Returns the width of the zone as a percentage.
method widthPercent(Zone this) =>
    float referencePrice =
         math.max(
              math.abs(this.boundary()),
              syminfo.mintick
          )

    float result =
         (this.top - this.bottom) /
         referencePrice *
         100.0

    result

// @function Returns the distance from price to the nearest zone edge.
method distancePercent(Zone this) =>
    float priceDistance =
         close < this.bottom ? this.bottom - close :
         close > this.top ? close - this.top :
         0.0

    float referencePrice =
         math.max(
              math.abs(close),
              syminfo.mintick
          )

    float result =
         priceDistance /
         referencePrice *
         100.0

    result

// @function Builds the text displayed directly on the chart.
method labelText(Zone this) =>
    string zoneCode =
         this.isResistance ? "R" : "S"

    string result =
         zoneCode +
         " " +
         formatPrice(this.boundary()) +
         " | " +
         formatRetests(this.retests)

    if labelDetailInput == LABEL_DETAILED
        result +=
             "\nVol " +
             formatVolume(
                  this.overlapVolume,
                  this.hasVolume
              )

    result

// @function Builds the detailed tooltip displayed on hover.
method tooltipText(Zone this) =>
    string zoneName =
         this.isResistance ?
         "Resistance zone" :
         "Support zone"

    string result =
         zoneName +
         "\nStatus: Active" +
         "\nRange: " +
         formatPrice(this.bottom) +
         " - " +
         formatPrice(this.top) +
         "\nBoundary: " +
         formatPrice(this.boundary()) +
         "\nWidth: " +
         str.tostring(this.widthPercent(), "0.00") +
         "%" +
         "\nRetests: " +
         str.tostring(this.retests) +
         "\nOverlap volume: " +
         formatVolume(
              this.overlapVolume,
              this.hasVolume
          ) +
         "\nAge: " +
         str.tostring(bar_index - this.startIndex) +
         " bars" +
         "\nDistance: " +
         str.tostring(this.distancePercent(), "0.00") +
         "%" +
         "\nBreak confirmation: " +
         breakModeInput +
         "\nPivot confirmation: " +
         str.tostring(pivotLookbackInput) +
         " bars" +
         "\n\nA retest is counted only after price leaves " +
         "the zone and later returns." +
         "\nOverlap Volume is the full volume of bars " +
         "whose ranges overlap the zone."

    result

// =============================================================================
// Zone calculation methods
// =============================================================================

// @function Checks whether the current completed candle overlaps the zone.
method overlapsCurrentBar(Zone this) =>
    high >= this.bottom and low <= this.top

// @function Checks whether the current completed candle breaks the zone.
method breaksCurrentBar(Zone this) =>
    bool result =
         this.isResistance ?
         (
              breakModeInput == BREAK_CLOSE ?
              close > this.top :
              high > this.top
          ) :
         (
              breakModeInput == BREAK_CLOSE ?
              close < this.bottom :
              low < this.bottom
          )

    result

// @function Updates retests, overlap volume and break state.
method processConfirmedBar(Zone this) =>
    if this.isActive() and barstate.isconfirmed
        bool isInside =
             this.overlapsCurrentBar()

        // A retest starts only after price enters from outside.
        if isInside and not this.wasInside
            this.retests += 1

        // Full candle volume is counted when its range overlaps the zone.
        if isInside and not na(volume)
            this.overlapVolume += volume
            this.hasVolume := true

        this.wasInside := isInside

        if this.breaksCurrentBar()
            this.isBroken := true
            this.endIndex := bar_index

    this

// =============================================================================
// Zone drawing methods
// =============================================================================

// @function Creates, updates or removes the active-zone label.
method refreshLabel(Zone this, int rightIndex) =>
    if barstate.islast
        bool shouldShow =
             showZoneLabelsInput and
             this.isActive() and
             this.passesFilter()

        if shouldShow
            color backgroundColor =
                 color.new(
                      this.baseLevelColor(),
                      75
                  )

            if na(this.infoLabel)
                this.infoLabel := label.new(
                     x = rightIndex,
                     y = this.boundary(),
                     text = this.labelText(),
                     xloc = xloc.bar_index,
                     yloc = yloc.price,
                     color = backgroundColor,
                     style = label.style_label_left,
                     textcolor = chart.fg_color,
                     size = size.tiny,
                     tooltip = this.tooltipText()
                 )

            if not na(this.infoLabel)
                label.set_xy(
                     this.infoLabel,
                     rightIndex,
                     this.boundary()
                 )

                label.set_text(
                     this.infoLabel,
                     this.labelText()
                 )

                label.set_tooltip(
                     this.infoLabel,
                     this.tooltipText()
                 )

                label.set_color(
                     this.infoLabel,
                     backgroundColor
                 )

                label.set_textcolor(
                     this.infoLabel,
                     chart.fg_color
                 )

        if not shouldShow and not na(this.infoLabel)
            label.delete(this.infoLabel)
            this.infoLabel := na

    this

// @function Creates and updates the zone drawings.
method refreshVisuals(Zone this) =>
    int rightIndex =
         this.isActive() ?
         bar_index + PROJECTION_BARS :
         int(nz(this.endIndex, bar_index))

    bool shouldDraw =
         this.passesFilter()

    if shouldDraw and na(this.areaBox)
        this.areaBox := box.new(
             left = this.startIndex,
             top = this.top,
             right = rightIndex,
             bottom = this.bottom,
             xloc = xloc.bar_index,
             border_color = na,
             bgcolor = this.visualAreaColor()
         )

    if shouldDraw and not na(this.areaBox)
        box.set_left(
             this.areaBox,
             this.startIndex
         )

        box.set_right(
             this.areaBox,
             rightIndex
         )

        box.set_top(
             this.areaBox,
             this.top
         )

        box.set_bottom(
             this.areaBox,
             this.bottom
         )

        box.set_bgcolor(
             this.areaBox,
             this.visualAreaColor()
         )

    if shouldDraw and na(this.levelLine)
        this.levelLine := line.new(
             x1 = this.startIndex,
             y1 = this.boundary(),
             x2 = rightIndex,
             y2 = this.boundary(),
             xloc = xloc.bar_index,
             color = this.visualLevelColor(),
             width = 1,
             style = line.style_solid
         )

    if shouldDraw and not na(this.levelLine)
        line.set_x1(
             this.levelLine,
             this.startIndex
         )

        line.set_y1(
             this.levelLine,
             this.boundary()
         )

        line.set_x2(
             this.levelLine,
             rightIndex
         )

        line.set_y2(
             this.levelLine,
             this.boundary()
         )

        line.set_color(
             this.levelLine,
             this.visualLevelColor()
         )

        line.set_style(
             this.levelLine,
             this.isBroken ?
             line.style_dashed :
             line.style_solid
         )

    this.refreshLabel(rightIndex)

    this

// @function Retires an active zone when a newer zone is confirmed.
method retire(Zone this, int retirementIndex) =>
    if this.isActive()
        this.isRetired := true
        this.endIndex := retirementIndex

    int finalIndex =
         int(nz(this.endIndex, retirementIndex))

    if not na(this.areaBox)
        box.set_right(
             this.areaBox,
             finalIndex
         )

        box.set_bgcolor(
             this.areaBox,
             this.visualAreaColor()
         )

    if not na(this.levelLine)
        line.set_x2(
             this.levelLine,
             finalIndex
         )

        line.set_color(
             this.levelLine,
             this.visualLevelColor()
         )

        line.set_style(
             this.levelLine,
             this.isBroken ?
             line.style_dashed :
             line.style_solid
         )

    if not na(this.infoLabel)
        label.delete(this.infoLabel)
        this.infoLabel := na

    this

// =============================================================================
// Zone creation
// =============================================================================

// @function Creates a zone and reconstructs its lifecycle between the pivot
// candle and the candle that confirms the pivot.
createZone(
     bool isResistance,
     float zoneTop,
     float zoneBottom,
     int startIndex
 ) =>
    Zone newZone = Zone.new(
         isResistance = isResistance,
         top = zoneTop,
         bottom = zoneBottom,
         startIndex = startIndex
     )

    // The pivot candle forms the zone and is not counted as a retest.
    bool wasInside = true

    // Include the pivot candle's volume in Overlap Volume.
    float pivotBarVolume =
         volume[pivotLookbackInput]

    if not na(pivotBarVolume)
        newZone.overlapVolume += pivotBarVolume
        newZone.hasVolume := true

    // Process every candle after the pivot in chronological order.
    for step = 1 to pivotLookbackInput
        int offset =
             pivotLookbackInput - step

        bool isInside =
             high[offset] >= zoneBottom and
             low[offset] <= zoneTop

        if isInside and not wasInside
            newZone.retests += 1

        if isInside and not na(volume[offset])
            newZone.overlapVolume += volume[offset]
            newZone.hasVolume := true

        wasInside := isInside

        bool brokenOnHistoricalBar =
             isResistance ?
             (
                  breakModeInput == BREAK_CLOSE ?
                  close[offset] > zoneTop :
                  high[offset] > zoneTop
              ) :
             (
                  breakModeInput == BREAK_CLOSE ?
                  close[offset] < zoneBottom :
                  low[offset] < zoneBottom
              )

        if brokenOnHistoricalBar
            newZone.isBroken := true
            newZone.endIndex := bar_index - offset
            break

    newZone.wasInside := wasInside

    newZone

// =============================================================================
// Pivot calculations
// =============================================================================

float resistancePivot = ta.pivothigh(
     pivotLookbackInput,
     pivotLookbackInput
 )

float supportPivot = ta.pivotlow(
     pivotLookbackInput,
     pivotLookbackInput
 )

bool newResistanceDetected =
     barstate.isconfirmed and
     showResistanceInput and
     not na(resistancePivot)

bool newSupportDetected =
     barstate.isconfirmed and
     showSupportInput and
     not na(supportPivot)

// =============================================================================
// Active zones
// =============================================================================

var Zone activeResistance = na
var Zone activeSupport = na

// -----------------------------------------------------------------------------
// Resistance
// -----------------------------------------------------------------------------

if not na(activeResistance)
    activeResistance.processConfirmedBar()
    activeResistance.refreshVisuals()

if newResistanceDetected
    if not na(activeResistance)
        activeResistance.retire(bar_index)

    float resistanceTop =
         high[pivotLookbackInput]

    float resistanceBottom =
         swingAreaInput == AREA_WICK ?
         math.max(
              open[pivotLookbackInput],
              close[pivotLookbackInput]
          ) :
         low[pivotLookbackInput]

    activeResistance := createZone(
         true,
         resistanceTop,
         resistanceBottom,
         bar_index - pivotLookbackInput
     )

    activeResistance.refreshVisuals()

// -----------------------------------------------------------------------------
// Support
// -----------------------------------------------------------------------------

if not na(activeSupport)
    activeSupport.processConfirmedBar()
    activeSupport.refreshVisuals()

if newSupportDetected
    if not na(activeSupport)
        activeSupport.retire(bar_index)

    float supportTop =
         swingAreaInput == AREA_WICK ?
         math.min(
              open[pivotLookbackInput],
              close[pivotLookbackInput]
          ) :
         high[pivotLookbackInput]

    float supportBottom =
         low[pivotLookbackInput]

    activeSupport := createZone(
         false,
         supportTop,
         supportBottom,
         bar_index - pivotLookbackInput
     )

    activeSupport.refreshVisuals()
````
