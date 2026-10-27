# Institutional Flow Matrix

- url: https://www.tradingview.com/script/8PYs3W5t-Institutional-Flow-Matrix/
- type: indicator
- pine_id: PUB;c9237cb703e3461190811d724206281f
- version: 1.0

## Description

Institutional Flow Matrix is an open-source market-analysis framework designed to organize trend direction, confirmed market structure, institutional price zones, momentum, and location within a dealing range into one readable chart.

The purpose of this indicator is not to predict every price movement or generate constant entries. It is designed to answer a more practical sequence of questions:

1. What is the current directional bias?
2. Is market structure supporting that direction?
3. Is price trading from a meaningful location?
4. Has price returned to an active institutional zone?
5. Is momentum aligned with the proposed setup?

The script combines these questions into a structured workflow while keeping the default chart intentionally clean.

WHY THIS INDICATOR WAS BUILT

Many market-structure indicators display every swing, imbalance, liquidity level, zone, and signal at the same time. While that information can be useful for detailed analysis, it can also make the chart difficult to interpret during live trading.

Institutional Flow Matrix was built around a visual hierarchy:

* Directional bias is the primary layer.
* Active Order Blocks are the principal reaction zones.
* Momentum is a confirmation layer.
* Premium and Discount provide market location.
* Fair Value Gaps, liquidity pools, sweeps, and higher-timeframe levels are optional study tools.

The default Balanced preset focuses on the information most relevant to a directional pullback setup. Minimal mode removes most supporting visuals for live execution. Full mode reveals the additional market-structure tools for deeper analysis.

WHAT MAKES THE IMPLEMENTATION DIFFERENT

The individual concepts used by this script, including pivots, moving averages, ATR trend filters, Order Blocks, Fair Value Gaps, and Premium/Discount ranges, are established forms of technical analysis.

The original contribution of Institutional Flow Matrix is how those components are synchronized and managed as one decision framework.

Key design elements include:

* Confirmed structure events rather than unconfirmed swing guesses.
* A persistent directional state requiring agreement between structure, EMA alignment, and an ATR-based trend filter.
* Order Block freshness validation before a zone is accepted.
* Separate visual duration and analytical lifetime controls for zones.
* Automatic mitigation and expiration of old zones.
* Limited drawing-object counts to prevent long-term chart clutter.
* A weighted confluence model centered on trend, structure, zone interaction, market location, and momentum.
* Three visual presets that change the information hierarchy without changing the underlying calculations.
* Confirmed-bar signals and event-based alerts.

This is not intended to be a collection of unrelated indicators. Each module has a defined role in the same setup process.

DIRECTIONAL BIAS

The chart background represents the script's confirmed directional state.

A bullish state requires agreement between:

* Bullish market structure.
* Fast EMA positioning above the slow EMA.
* Bullish ATR trend conditions.

A bearish state uses the opposite conditions.

The background changes only after the required conditions are confirmed. A larger BUY or SELL label marks a confirmed change in this directional state.

These shift labels are different from the smaller confluence signals. A shift label identifies a change in directional bias. A confluence signal requires additional location, zone, and momentum conditions.

MARKET STRUCTURE

Confirmed pivot highs and lows form the structure engine.

The script tracks:

* Higher Highs
* Higher Lows
* Lower Highs
* Lower Lows
* Breaks of Structure
* Changes of Character

A bullish break occurs when a confirmed bar closes above the latest unbroken confirmed swing high. A bearish break occurs when a confirmed bar closes below the latest unbroken confirmed swing low.

Swing labels are retrospective by design. A pivot can only be confirmed after the selected number of right-side bars has closed. Once confirmed, its label is placed on the candle where the swing originally occurred. The label was not known on that earlier candle.

ORDER BLOCKS

Order Blocks are the primary reaction zones in the indicator.

After a confirmed structure break or qualifying displacement event, the script searches backward for an opposing candle. A candidate candle can be filtered by:

* Candle range relative to ATR.
* Body size as a percentage of candle range.
* Optional volume expansion.
* Wick-based or body-based zone construction.

Before accepting the candidate, the script checks whether price has already invalidated it. This prevents many stale zones from being created after the fact.

Active Order Blocks can be invalidated by either:

* A close beyond the opposite edge.
* A wick beyond the opposite edge.

The selected mitigation method is used consistently during both zone creation and live zone management.

Order Blocks have separate controls for visual extension and analytical age. This allows users to control how long a box remains visible independently from how long it remains eligible for signal calculations.

PREMIUM, DISCOUNT, AND EQUILIBRIUM

The script creates a rolling dealing range from the highest high and lowest low over the selected lookback.

The range is divided into:

* Premium: the upper portion of the range.
* Discount: the lower portion of the range.
* Equilibrium: the 50% midpoint.

Premium and Discount do not generate trades by themselves. They provide location.

In general:

* Bullish setups receive stronger contextual support in Discount.
* Bearish setups receive stronger contextual support in Premium.
* Equilibrium represents the midpoint of the current rolling range.

Because the range is rolling, its boundaries can change when a new lookback high or low is formed.

MOMENTUM RIBBON

The momentum module uses three exponential moving averages and an ATR-normalized difference between the fast and slow averages.

Bullish momentum requires:

* Fast EMA above the slow EMA.
* Positive normalized momentum.
* Momentum above its signal average.

Bearish momentum uses the opposite conditions.

Diamond markers identify confirmed momentum crossings. The ribbon is intended as confirmation rather than a standalone entry system.

CONFLUENCE SIGNALS

The script calculates a 0-100 Confluence Score from five conditions:

* Directional bias: 25 points.
* Market structure: 15 points.
* Momentum alignment: 15 points.
* Active Order Block interaction: 25 points.
* Premium or Discount location: 20 points.

The score measures condition alignment. It is not a probability, win rate, accuracy estimate, or forecast of future performance.

By default, BUY and SELL signals require:

* Confirmed directional bias.
* Matching confirmed structure.
* Interaction with an active Order Block.
* Correct Premium or Discount location.
* Matching momentum.
* Minimum Confluence Score.
* Completion of the selected signal cooldown.

Signals are displayed only when the complete condition changes from false to true. This prevents repeated labels while the same setup remains active.

OPTIONAL ADVANCED MODULES

Full mode provides additional analytical tools:

* Fair Value Gaps with ATR size filtering.
* Equal-high and equal-low liquidity pools.
* Confirmed liquidity sweeps.
* BOS and CHoCH labels.
* HH, HL, LH, and LL labels.
* Previous day, week, and month highs and lows.
* Optional momentum candle coloring.

These features are disabled or hidden from the default Balanced view to preserve readability.

VISUAL PRESETS

Minimal:
Designed for traders who want the least chart interference. It suppresses the background, ribbon, Premium/Discount display, trailing line, dashboard, and advanced structure annotations.

Balanced:
The default view. It emphasizes directional background, active Order Blocks, Premium/Discount context, momentum ribbon, diamonds, signals, and the dashboard.

Full:
Designed for detailed study. It adds structure labels, BOS/CHoCH events, Fair Value Gaps, liquidity tools, higher-timeframe levels, and optional candle coloring.

FOR NEWER TRADERS

A simple workflow is:

1. Start with the Balanced preset.
2. Use the background to identify the current directional bias.
3. Wait for price to return to an Order Block matching that bias.
4. Check whether price is in Discount for a bullish setup or Premium for a bearish setup.
5. Confirm that the momentum ribbon agrees.
6. Treat the signal as a point for further analysis, not an automatic order.

The equilibrium line can be used as a reference for the midpoint of the current dealing range. It is not automatically an entry or exit instruction.

FOR ADVANCED TRADERS

Experienced users can customize:

* Pivot confirmation sensitivity.
* ATR and EMA trend parameters.
* Wick-based versus body-based Order Blocks.
* Displacement-created zones.
* Candle body, range, and volume filters.
* Close-based versus wick-based mitigation.
* Zone visual duration and analytical age.
* Premium and Discount percentages.
* Fair Value Gap size.
* Liquidity sensitivity.
* Momentum lengths.
* Individual signal requirements.
* Minimum confluence threshold.
* Signal cooldown.
* Higher-timeframe reference levels.

Advanced users can also disable individual hard requirements and use the Confluence Score as a more flexible filtering system.

ALERTS

Alert conditions are included for:

* Break of Structure.
* Change of Character.
* New Order Block.
* BUY signal.
* SELL signal.
* Bias-aligned Order Block entry.
* Trend and momentum confluence.
* Liquidity sweep.

Alerts should be created using Once Per Bar Close when confirmed signals are required.

NON-REPAINTING AND TIMING

Structure breaks, directional shifts, zone creation, zone mitigation, momentum events, and confluence signals are evaluated on confirmed bars.

Pivot-based swing labels require future bars to confirm that a swing occurred. After confirmation, the label is displayed on the original pivot candle. This is delayed confirmation with retrospective placement, not advance knowledge of the swing.

Previous-period levels use completed higher-timeframe data.

LIMITATIONS

* This indicator does not predict future prices.
* It does not calculate position size, stop loss, or account risk.
* It is not a complete automated trading system.
* Signals can fail during volatile, illiquid, or range-bound conditions.
* Rolling Premium, Discount, and equilibrium levels can move when the lookback range changes.
* Confirmed pivots introduce an intentional delay.
* Order Block definitions vary among trading methodologies; this script uses the documented candle-search and filtering rules described above.
* Volume behavior differs across asset classes and data providers.
* Parameter settings that work on one symbol or timeframe may not be appropriate for another.

Suggested starting points are the 15-minute and 1-hour charts for intraday analysis and the 4-hour chart for broader swing structure. Users should test settings on their own symbols and trading sessions.

OPEN-SOURCE PURPOSE

The script is published open-source so traders can inspect the calculations, understand why signals occur, verify the confirmed-bar methodology, and adapt the framework for their own research.

The goal is to provide a readable and transparent market-structure workflow rather than a black-box prediction tool.

DISCLAIMER

This indicator is provided for educational and analytical purposes only. It is not financial advice and does not guarantee profitable results. Historical chart behavior does not ensure future performance. Users are responsible for their own analysis, testing, risk management, and trading decisions.

## Source Code

````pine
//@version=6
indicator(
     "Institutional Flow Matrix",
     shorttitle = "IFM",
     overlay = true,
     max_bars_back = 5000,
     max_boxes_count = 300,
     max_lines_count = 500,
     max_labels_count = 300)

//------------------------------------------------------------------------------
// CONSTANTS / INPUT GROUPS
//------------------------------------------------------------------------------
const string GRP_STRUCTURE = "1. Market Structure"
const string GRP_SHIFT     = "2. Flow Bias / Trend"
const string GRP_OB        = "3. Order Blocks"
const string GRP_PD        = "4. Premium / Discount"
const string GRP_FVG       = "5. Fair Value Gaps"
const string GRP_LIQ       = "6. Liquidity"
const string GRP_OSC       = "7. Momentum Ribbon"
const string GRP_SIGNALS   = "8. Signals"
const string GRP_MTF       = "9. Multi-Timeframe Levels"
const string GRP_ALERTS    = "10. Alerts"
const string GRP_GENERAL   = "11. General / Dashboard"

// Historical buffer limit synchronized with max_bars_back
const int MAX_HISTORICAL_BARS = 4900

//------------------------------------------------------------------------------
// INPUTS
//------------------------------------------------------------------------------
int pivotLeft = input.int(5, "Pivot left bars", minval = 1, maxval = 50, group = GRP_STRUCTURE)
int pivotRight = input.int(5, "Pivot right bars", minval = 1, maxval = 50, group = GRP_STRUCTURE)
bool showSwingLabels = input.bool(true, "Show HH / HL / LH / LL labels", tooltip = "Note: Swings are confirmed after 'Pivot right bars'. Labels are drawn retrospectively on the originating bar to avoid future data leakage.", group = GRP_STRUCTURE)
bool showBosChoch = input.bool(true, "Show BOS / CHoCH labels", group = GRP_STRUCTURE)

int shiftAtrLen = input.int(14, "ATR period", minval = 1, group = GRP_SHIFT)
float shiftAtrMult = input.float(2.5, "ATR trend multiplier", minval = 0.1, step = 0.1, group = GRP_SHIFT)
int shiftFastLen = input.int(21, "Trend fast EMA", minval = 1, group = GRP_SHIFT)
int shiftSlowLen = input.int(55, "Trend slow EMA", minval = 2, group = GRP_SHIFT)
bool showTrendBackground = input.bool(true, "Show trend background", group = GRP_SHIFT)
bool showShiftLabels = input.bool(true, "Show BUY / SELL shift labels", group = GRP_SHIFT)
bool showTrailingLine = input.bool(true, "Show ATR trailing line", group = GRP_SHIFT)

bool showOrderBlocks = input.bool(true, "Show order blocks", group = GRP_OB)
string obZoneBasis = input.string("Wick", "Zone basis", options = ["Wick", "Body"], group = GRP_OB)
float obMinAtrMult = input.float(0.50, "Minimum candle range (ATR)", minval = 0.0, step = 0.05, group = GRP_OB)
int obLookback = input.int(8, "Opposing candle scan", minval = 2, maxval = 30, group = GRP_OB)
float obMinBodyPct = input.float(25.0, "Minimum body % of range", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_OB)
bool obUseVolume = input.bool(false, "Require volume confirmation", group = GRP_OB)
float obVolumeMult = input.float(1.20, "Volume vs SMA multiplier", minval = 0.1, step = 0.1, group = GRP_OB)
bool obAllowDisplacement = input.bool(true, "Allow displacement-created OBs", group = GRP_OB)
float obDisplacementAtr = input.float(1.0, "Displacement body (ATR)", minval = 0.1, step = 0.1, group = GRP_OB)
bool showObEquilibrium = input.bool(false, "Show OB 50% line", group = GRP_OB)
bool mitigationOnClose = input.bool(true, "Mitigate on close beyond edge", group = GRP_OB)
bool hideMitigated = input.bool(true, "Delete mitigated zones", group = GRP_OB)
bool onlyShowActiveZones = input.bool(true, "Only show active (unmitigated) zones", group = GRP_OB)
int maxOrderBlocks = input.int(8, "Maximum order blocks", minval = 1, maxval = 50, group = GRP_OB)
int obDisplayBars = input.int(250, "Max bars zones extend visually", minval = 50, maxval = 500, group = GRP_OB)
int obMaxAgeBars = input.int(250, "Order Block max analytical age (bars)", minval = 50, maxval = 500, group = GRP_OB)
int obMaxLoopGuard = input.int(50, "Mitigation scan limit (bars)", minval = 5, maxval = 300, tooltip = "Prevents performance lag by capping how many historical bars are checked during the pre-mitigation scan.", group = GRP_OB)

bool showPdZones = input.bool(true, "Show premium / discount", group = GRP_PD)
int pdLookback = input.int(100, "Range lookback", minval = 20, maxval = 500, group = GRP_PD)
float premiumPct = input.float(20.0, "Premium zone %", minval = 5.0, maxval = 45.0, step = 1.0, group = GRP_PD)
float discountPct = input.float(20.0, "Discount zone %", minval = 5.0, maxval = 45.0, step = 1.0, group = GRP_PD)
bool showPdEquilibrium = input.bool(true, "Show range equilibrium", group = GRP_PD)

bool showFvgs = input.bool(false, "Show fair value gaps", group = GRP_FVG)
float fvgAtrMult = input.float(0.30, "Minimum gap size (ATR)", minval = 0.0, step = 0.05, group = GRP_FVG)
bool showFvgEquilibrium = input.bool(true, "Show FVG 50% line", group = GRP_FVG)
int maxFvgs = input.int(6, "Maximum FVGs", minval = 1, maxval = 50, group = GRP_FVG)
int fvgMaxAgeBars = input.int(250, "FVG max analytical age (bars)", minval = 50, maxval = 500, group = GRP_FVG)

bool showLiquidity = input.bool(false, "Show equal highs / lows", group = GRP_LIQ)
float liquidityToleranceAtr = input.float(0.15, "Equality tolerance (ATR)", minval = 0.01, step = 0.01, group = GRP_LIQ)
bool showSweeps = input.bool(false, "Show liquidity sweeps", group = GRP_LIQ)
int maxLiquidityPools = input.int(8, "Maximum liquidity pools", minval = 1, maxval = 50, group = GRP_LIQ)

bool showRibbon = input.bool(true, "Show MA ribbon", group = GRP_OSC)
int oscFastLen = input.int(8, "Ribbon fast EMA", minval = 1, group = GRP_OSC)
int oscMidLen = input.int(21, "Ribbon middle EMA", minval = 2, group = GRP_OSC)
int oscSlowLen = input.int(34, "Ribbon slow EMA", minval = 3, group = GRP_OSC)
int oscSignalLen = input.int(9, "Momentum signal EMA", minval = 1, group = GRP_OSC)
bool showDiamonds = input.bool(true, "Show momentum diamonds", group = GRP_OSC)
bool colorCandles = input.bool(false, "Color candles by momentum", group = GRP_OSC)

bool enableSignals = input.bool(true, "Enable BUY / SELL signals", group = GRP_SIGNALS)
bool requireObTouch = input.bool(true, "Require active OB touch", group = GRP_SIGNALS)
bool requirePdAlignment = input.bool(true, "Require premium / discount alignment", group = GRP_SIGNALS)
bool requireMomentum = input.bool(true, "Require momentum alignment", group = GRP_SIGNALS)
float minimumSignalScore = input.float(70.0, "Minimum confluence score", minval = 0.0, maxval = 100.0, step = 5.0, group = GRP_SIGNALS)
int signalCooldown = input.int(10, "Signal cooldown bars", minval = 0, maxval = 500, group = GRP_SIGNALS)

bool showPreviousDay = input.bool(false, "Previous day high / low", group = GRP_MTF)
bool showPreviousWeek = input.bool(false, "Previous week high / low", group = GRP_MTF)
bool showPreviousMonth = input.bool(false, "Previous month high / low", group = GRP_MTF)

bool alertBos = input.bool(true, "Alert: BOS", group = GRP_ALERTS)
bool alertChoch = input.bool(true, "Alert: CHoCH", group = GRP_ALERTS)
bool alertNewOb = input.bool(true, "Alert: new order block", group = GRP_ALERTS)
bool alertBuy = input.bool(true, "Alert: BUY signal", group = GRP_ALERTS)
bool alertSell = input.bool(true, "Alert: SELL signal", group = GRP_ALERTS)
bool alertObEntry = input.bool(true, "Alert: aligned OB entry", group = GRP_ALERTS)
bool alertCombo = input.bool(true, "Alert: Bias + Momentum", group = GRP_ALERTS)
bool alertLiquiditySweep = input.bool(true, "Alert: liquidity sweep", group = GRP_ALERTS)

color bullishColor = input.color(color.rgb(0, 184, 148), "Bullish color", group = GRP_GENERAL)
color bearishColor = input.color(color.rgb(214, 48, 49), "Bearish color", group = GRP_GENERAL)
color neutralColor = input.color(color.rgb(149, 165, 166), "Neutral color", group = GRP_GENERAL)
color mitigatedColor = input.color(color.rgb(127, 140, 141), "Mitigated color", group = GRP_GENERAL)
color fvgBullColor = input.color(color.rgb(46, 204, 113), "Bullish FVG color", group = GRP_GENERAL)
color fvgBearColor = input.color(color.rgb(231, 76, 60), "Bearish FVG color", group = GRP_GENERAL)
string visualPreset = input.string("Balanced", "Visual Preset", options = ["Minimal", "Balanced", "Full"], group = GRP_GENERAL)
bool showDashboard = input.bool(true, "Show dashboard", group = GRP_GENERAL)
int maxManagedLabels = input.int(120, "Maximum managed labels", minval = 20, maxval = 300, group = GRP_GENERAL)

bool useMinimal = visualPreset == "Minimal"
bool useBalanced = visualPreset == "Balanced"
bool useFull = visualPreset == "Full"

bool showTrendBackgroundFinal = showTrendBackground and not useMinimal
bool showTrailingLineFinal = showTrailingLine and not useMinimal
bool showRibbonFinal = showRibbon and (useBalanced or useFull)
bool showDiamondsFinal = showDiamonds and (useBalanced or useFull)
bool showPdZonesFinal = showPdZones and not useMinimal
bool showSwingLabelsFinal = showSwingLabels and useFull
bool showBosChochFinal = showBosChoch and useFull
bool showFvgsFinal = showFvgs and useFull
bool showLiquidityFinal = showLiquidity and useFull
bool showSweepsFinal = showSweeps and useFull
bool showPreviousDayFinal = showPreviousDay and useFull
bool showPreviousWeekFinal = showPreviousWeek and useFull
bool showPreviousMonthFinal = showPreviousMonth and useFull
bool colorCandlesFinal = colorCandles and useFull
bool showDashboardFinal = showDashboard and not useMinimal

//------------------------------------------------------------------------------
// CORE SERIES
//------------------------------------------------------------------------------
float atrValue = ta.atr(shiftAtrLen)
float volumeSma = ta.sma(volume, 20)

float trendFast = ta.ema(close, shiftFastLen)
float trendSlow = ta.ema(close, shiftSlowLen)
bool trendBullCross = ta.crossover(trendFast, trendSlow)
bool trendBearCross = ta.crossunder(trendFast, trendSlow)
[supertrendValue, supertrendDirection] = ta.supertrend(shiftAtrMult, shiftAtrLen)
bool rawTrendBull = supertrendDirection < 0 and trendFast > trendSlow
bool rawTrendBear = supertrendDirection > 0 and trendFast < trendSlow

float oscFast = ta.ema(close, oscFastLen)
float oscMid = ta.ema(close, oscMidLen)
float oscSlow = ta.ema(close, oscSlowLen)
float momentum = atrValue > 0 ? (oscFast - oscSlow) / atrValue : 0.0
float momentumSignal = ta.ema(momentum, oscSignalLen)
float momentumExpansion = momentum - momentumSignal
bool momentumBullCross = ta.crossover(momentum, momentumSignal)
bool momentumBearCross = ta.crossunder(momentum, momentumSignal)
bool oscillatorBullish = oscFast > oscSlow and momentum > momentumSignal and momentum > 0
bool oscillatorBearish = oscFast < oscSlow and momentum < momentumSignal and momentum < 0

//------------------------------------------------------------------------------
// CUSTOM TYPES
//------------------------------------------------------------------------------
type Zone
    box area
    line equilibrium
    float top
    float bottom
    bool bullish
    bool active
    int bornBar

type LiquidityPool
    line levelLine
    float price
    bool highSide
    bool active
    int bornBar

//------------------------------------------------------------------------------
// HELPERS
//------------------------------------------------------------------------------
f_pushLabel(array<label> labels, label id, int maximum) =>
    array.push(labels, id)
    if array.size(labels) > maximum
        label old = array.shift(labels)
        label.delete(old)
    true

f_deleteZone(Zone zone) =>
    if not na(zone.area)
        box.delete(zone.area)
    if not na(zone.equilibrium)
        line.delete(zone.equilibrium)
    true

f_addZone(array<Zone> zones, float zoneTop, float zoneBottom, int leftBar, bool bullish, color zoneColor, int maximum, bool showEquilibrium, int displayExtendBars) =>
    float normalizedTop = math.max(zoneTop, zoneBottom)
    float normalizedBottom = math.min(zoneTop, zoneBottom)
    box zoneBox = box.new(
         left = leftBar,
         top = normalizedTop,
         right = bar_index,
         bottom = normalizedBottom,
         xloc = xloc.bar_index,
         extend = extend.none,
         border_color = color.new(zoneColor, 35),
         border_width = 1,
         border_style = line.style_solid,
         bgcolor = color.new(zoneColor, 93))
    box.set_right(zoneBox, bar_index + displayExtendBars)
    line midpointLine = na
    if showEquilibrium
        float midpoint = (normalizedTop + normalizedBottom) * 0.5
        midpointLine := line.new(
             x1 = leftBar,
             y1 = midpoint,
             x2 = bar_index + displayExtendBars,
             y2 = midpoint,
             xloc = xloc.bar_index,
             extend = extend.none,
             color = color.new(zoneColor, 45),
             style = line.style_dashed,
             width = 1)
    Zone newZone = Zone.new(zoneBox, midpointLine, normalizedTop, normalizedBottom, bullish, true, bar_index)
    array.push(zones, newZone)
    if array.size(zones) > maximum
        Zone oldest = array.shift(zones)
        f_deleteZone(oldest)
    true

f_updateZones(array<Zone> zones, bool useClose, bool deleteMitigated, color dimColor, int maxAgeBars) =>
    int size = array.size(zones)
    if size > 0
        array<int> toRemove = array.new<int>()
        for i = 0 to size - 1
            Zone zone = array.get(zones, i)
            if zone.active and barstate.isconfirmed
                bool expired = bar_index - zone.bornBar > maxAgeBars
                bool invalidated = bar_index > zone.bornBar and (zone.bullish ?
                     (useClose ? close < zone.bottom : low < zone.bottom) :
                     (useClose ? close > zone.top : high > zone.top))
                if invalidated or expired
                    zone.active := false
                    if deleteMitigated or expired
                        f_deleteZone(zone)
                        array.push(toRemove, i)
                    else
                        box.set_extend(zone.area, extend.none)
                        box.set_right(zone.area, bar_index)
                        box.set_bgcolor(zone.area, color.new(dimColor, 95))
                        box.set_border_color(zone.area, color.new(dimColor, 70))
                        if not na(zone.equilibrium)
                            line.set_extend(zone.equilibrium, extend.none)
                            line.set_x2(zone.equilibrium, bar_index)
                            line.set_color(zone.equilibrium, color.new(dimColor, 70))
                        array.set(zones, i, zone)
        
        int j = array.size(toRemove) - 1
        while j >= 0
            array.remove(zones, array.get(toRemove, j))
            j -= 1
    true

f_activeTouch(array<Zone> zones, bool bullish) =>
    bool touched = false
    if array.size(zones) > 0
        for zone in zones
            if zone.active and zone.bullish == bullish and bar_index > zone.bornBar
                touched := touched or (high >= zone.bottom and low <= zone.top)
    touched

f_countActive(array<Zone> zones, bool bullish) =>
    int count = 0
    if array.size(zones) > 0
        for zone in zones
            if zone.active and zone.bullish == bullish
                count += 1
    count

f_zoneExists(array<Zone> zones, float zoneTop, float zoneBottom, bool bullish) =>
    bool exists = false
    float normalizedTop = math.max(zoneTop, zoneBottom)
    float normalizedBottom = math.min(zoneTop, zoneBottom)
    float tolerance = syminfo.mintick * 2.0
    if array.size(zones) > 0
        for zone in zones
            if zone.active and zone.bullish == bullish
                bool sameTop = math.abs(zone.top - normalizedTop) <= tolerance
                bool sameBottom = math.abs(zone.bottom - normalizedBottom) <= tolerance
                exists := exists or (sameTop and sameBottom)
    exists

// Bounded pre-mitigation scan with a user-configurable loop guard
f_findOrderBlock(bool bullish, int lookback, float rangeAtrMult, float minimumBodyPct, bool useVolume, float volumeMult, bool bodyOnly, bool mitigateOnClose, int maxLoopGuard) =>
    float zoneTop = na
    float zoneBottom = na
    int offset = na
    bool found = false
    for i = 1 to lookback
        if not found and not na(close[i]) and not na(atrValue[i])
            float candleRange = high[i] - low[i]
            float candleBody = math.abs(close[i] - open[i])
            float bodyPct = candleRange > 0 ? candleBody / candleRange * 100.0 : 0.0
            bool opposing = bullish ? close[i] < open[i] : close[i] > open[i]
            bool rangeOk = candleRange >= atrValue[i] * rangeAtrMult
            bool bodyOk = bodyPct >= minimumBodyPct
            bool volumeOk = not useVolume or na(volumeSma[i]) or volume[i] >= volumeSma[i] * volumeMult
            
            if opposing and rangeOk and bodyOk and volumeOk
                float tempTop = bodyOnly ? math.max(open[i], close[i]) : high[i]
                float tempBottom = bodyOnly ? math.min(open[i], close[i]) : low[i]
                
                bool alreadyMitigated = false
                if i > 1
                    int scanLimit = math.min(i - 1, maxLoopGuard)
                    for k = 1 to scanLimit
                        if bullish
                            float checkPrice = mitigateOnClose ? close[k] : low[k]
                            if checkPrice < tempBottom
                                alreadyMitigated := true
                                break
                        else
                            float checkPrice = mitigateOnClose ? close[k] : high[k]
                            if checkPrice > tempTop
                                alreadyMitigated := true
                                break
                            
                if not alreadyMitigated
                    zoneTop := tempTop
                    zoneBottom := tempBottom
                    offset := i
                    found := true
    [zoneTop, zoneBottom, offset, found]

// Liquidity drawings use the synchronized historical buffer limit
f_addLiquidity(array<LiquidityPool> pools, float level, int leftBar, int rightBar, bool highSide, color poolColor, int maximum) =>
    int safeLeftBar = math.max(leftBar, bar_index - MAX_HISTORICAL_BARS)
    line poolLine = line.new(
         x1 = safeLeftBar,
         y1 = level,
         x2 = rightBar,
         y2 = level,
         xloc = xloc.bar_index,
         extend = extend.right,
         color = color.new(poolColor, 25),
         style = line.style_dotted,
         width = 1)
    LiquidityPool pool = LiquidityPool.new(poolLine, level, highSide, true, bar_index)
    array.push(pools, pool)
    if array.size(pools) > maximum
        LiquidityPool oldest = array.shift(pools)
        line.delete(oldest.levelLine)
    true

f_updateLiquidity(array<LiquidityPool> pools, bool displaySweeps, color dimColor, array<label> labels, int maximumLabels) =>
    bool highSweep = false
    bool lowSweep = false
    int i = array.size(pools) - 1
    while i >= 0
        LiquidityPool pool = array.get(pools, i)
        if pool.active and barstate.isconfirmed and bar_index > pool.bornBar
            bool swept = pool.highSide ? (high > pool.price and close < pool.price) : (low < pool.price and close > pool.price)
            if swept
                pool.active := false
                line.set_extend(pool.levelLine, extend.none)
                line.set_x2(pool.levelLine, bar_index)
                line.set_color(pool.levelLine, color.new(dimColor, 45))
                if pool.highSide
                    highSweep := true
                else
                    lowSweep := true
                if displaySweeps
                    label sweepLabel = label.new(
                         x = bar_index,
                         y = pool.price,
                         text = pool.highSide ? "SWEEP H" : "SWEEP L",
                         xloc = xloc.bar_index,
                         yloc = yloc.price,
                         style = pool.highSide ? label.style_label_down : label.style_label_up,
                         color = pool.highSide ? color.new(bearishColor, 10) : color.new(bullishColor, 10),
                         textcolor = color.white,
                         size = size.tiny)
                    f_pushLabel(labels, sweepLabel, maximumLabels)
                array.set(pools, i, pool)
        i -= 1
    [highSweep, lowSweep]

f_countActiveLiquidity(array<LiquidityPool> pools) =>
    int count = 0
    if array.size(pools) > 0
        for pool in pools
            if pool.active
                count += 1
    count

//------------------------------------------------------------------------------
// PERSISTENT STATE
//------------------------------------------------------------------------------
var array<Zone> orderBlocks = array.new<Zone>()
var array<Zone> fairValueGaps = array.new<Zone>()
var array<LiquidityPool> liquidityPools = array.new<LiquidityPool>()
var array<label> managedLabels = array.new<label>()

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na
var int lastBrokenHighBar = na
var int lastBrokenLowBar = na
var int structureState = 0
var int flowBias = 0
var string lastStructureEvent = "None"
var int lastLongSignalBar = na
var int lastShortSignalBar = na

//------------------------------------------------------------------------------
// MARKET STRUCTURE / SWINGS / LIQUIDITY POOLS
//------------------------------------------------------------------------------
float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)

if not na(pivotHigh)
    int pivotBar = bar_index - pivotRight
    float pivotAtr = atrValue[pivotRight]
    bool equalHigh = showLiquidityFinal and not na(lastSwingHigh) and not na(pivotAtr) and math.abs(pivotHigh - lastSwingHigh) <= pivotAtr * liquidityToleranceAtr
    string swingText = na(lastSwingHigh) ? "H" : equalHigh ? "EQH" : pivotHigh > lastSwingHigh ? "HH" : "LH"
    if equalHigh
        float equalLevel = (pivotHigh + lastSwingHigh) * 0.5
        f_addLiquidity(liquidityPools, equalLevel, lastSwingHighBar, pivotBar, true, bearishColor, maxLiquidityPools)
    if showSwingLabelsFinal
        label swingLabel = label.new(
             x = pivotBar,
             y = pivotHigh,
             text = swingText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = color.new(bearishColor, 80),
             textcolor = bearishColor,
             size = size.tiny)
        f_pushLabel(managedLabels, swingLabel, maxManagedLabels)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := pivotBar

if not na(pivotLow)
    int pivotBar = bar_index - pivotRight
    float pivotAtr = atrValue[pivotRight]
    bool equalLow = showLiquidityFinal and not na(lastSwingLow) and not na(pivotAtr) and math.abs(pivotLow - lastSwingLow) <= pivotAtr * liquidityToleranceAtr
    string swingText = na(lastSwingLow) ? "L" : equalLow ? "EQL" : pivotLow < lastSwingLow ? "LL" : "HL"
    if equalLow
        float equalLevel = (pivotLow + lastSwingLow) * 0.5
        f_addLiquidity(liquidityPools, equalLevel, lastSwingLowBar, pivotBar, false, bullishColor, maxLiquidityPools)
    if showSwingLabelsFinal
        label swingLabel = label.new(
             x = pivotBar,
             y = pivotLow,
             text = swingText,
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = color.new(bullishColor, 80),
             textcolor = bullishColor,
             size = size.tiny)
        f_pushLabel(managedLabels, swingLabel, maxManagedLabels)
    lastSwingLow := pivotLow
    lastSwingLowBar := pivotBar

bool bullishBreak = barstate.isconfirmed and not na(lastSwingHigh) and close > lastSwingHigh and close[1] <= lastSwingHigh and (na(lastBrokenHighBar) or lastBrokenHighBar != lastSwingHighBar)
bool bearishBreak = barstate.isconfirmed and not na(lastSwingLow) and close < lastSwingLow and close[1] >= lastSwingLow and (na(lastBrokenLowBar) or lastBrokenLowBar != lastSwingLowBar)

bool bullishChoch = bullishBreak and structureState == -1
bool bearishChoch = bearishBreak and structureState == 1
bool bullishBos = bullishBreak and not bullishChoch
bool bearishBos = bearishBreak and not bearishChoch

if bullishBreak
    lastBrokenHighBar := lastSwingHighBar
    structureState := 1
    lastStructureEvent := bullishChoch ? "Bullish CHoCH" : "Bullish BOS"
    if showBosChochFinal
        label structureLabel = label.new(
             x = bar_index,
             y = lastSwingHigh,
             text = bullishChoch ? "CHoCH" : "BOS",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_up,
             color = color.new(bullishColor, 5),
             textcolor = color.white,
             size = size.tiny)
        f_pushLabel(managedLabels, structureLabel, maxManagedLabels)

if bearishBreak
    lastBrokenLowBar := lastSwingLowBar
    structureState := -1
    lastStructureEvent := bearishChoch ? "Bearish CHoCH" : "Bearish BOS"
    if showBosChochFinal
        label structureLabel = label.new(
             x = bar_index,
             y = lastSwingLow,
             text = bearishChoch ? "CHoCH" : "BOS",
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_down,
             color = color.new(bearishColor, 5),
             textcolor = color.white,
             size = size.tiny)
        f_pushLabel(managedLabels, structureLabel, maxManagedLabels)

[highLiquiditySweep, lowLiquiditySweep] = f_updateLiquidity(liquidityPools, showSweepsFinal, mitigatedColor, managedLabels, maxManagedLabels)

//------------------------------------------------------------------------------
// FLOW BIAS / CONFIRMED TREND
//------------------------------------------------------------------------------
bool bullishShiftCandidate = (bullishBreak and rawTrendBull) or (structureState == 1 and trendBullCross and rawTrendBull)
bool bearishShiftCandidate = (bearishBreak and rawTrendBear) or (structureState == -1 and trendBearCross and rawTrendBear)

if barstate.isconfirmed
    if bullishShiftCandidate
        flowBias := 1
    else if bearishShiftCandidate
        flowBias := -1
    else if flowBias == 0
        if structureState == 1 and rawTrendBull
            flowBias := 1
        else if structureState == -1 and rawTrendBear
            flowBias := -1

bool bullishShift = barstate.isconfirmed and flowBias == 1 and nz(flowBias[1], 0) != 1
bool bearishShift = barstate.isconfirmed and flowBias == -1 and nz(flowBias[1], 0) != -1

if bullishShift and showShiftLabels
    label shiftLabel = label.new(
         x = bar_index,
         y = low,
         text = "BUY",
         xloc = xloc.bar_index,
         yloc = yloc.belowbar,
         style = label.style_label_up,
         color = bullishColor,
         textcolor = color.white,
         size = size.small)
    f_pushLabel(managedLabels, shiftLabel, maxManagedLabels)

if bearishShift and showShiftLabels
    label shiftLabel = label.new(
         x = bar_index,
         y = high,
         text = "SELL",
         xloc = xloc.bar_index,
         yloc = yloc.abovebar,
         style = label.style_label_down,
         color = bearishColor,
         textcolor = color.white,
         size = size.small)
    f_pushLabel(managedLabels, shiftLabel, maxManagedLabels)

//------------------------------------------------------------------------------
// ORDER BLOCK ENGINE
//------------------------------------------------------------------------------
bool deleteMitigatedOrderBlocks = hideMitigated or onlyShowActiveZones
f_updateZones(orderBlocks, mitigationOnClose, deleteMitigatedOrderBlocks, mitigatedColor, obMaxAgeBars)

float currentBody = math.abs(close - open)
bool bullishDisplacementRaw = barstate.isconfirmed and close > open and currentBody >= atrValue * obDisplacementAtr and close > high[1]
bool bearishDisplacementRaw = barstate.isconfirmed and close < open and currentBody >= atrValue * obDisplacementAtr and close < low[1]
bool bullishDisplacement = bullishDisplacementRaw and not bullishDisplacementRaw[1]
bool bearishDisplacement = bearishDisplacementRaw and not bearishDisplacementRaw[1]

bool bullishObTrigger = bullishBreak or (obAllowDisplacement and bullishDisplacement)
bool bearishObTrigger = bearishBreak or (obAllowDisplacement and bearishDisplacement)
bool bodyOnlyZones = obZoneBasis == "Body"

bool newBullishOb = false
bool newBearishOb = false

if showOrderBlocks and bullishObTrigger
    [obTop, obBottom, obOffset, obFound] = f_findOrderBlock(true, obLookback, obMinAtrMult, obMinBodyPct, obUseVolume, obVolumeMult, bodyOnlyZones, mitigationOnClose, obMaxLoopGuard)
    if obFound and not f_zoneExists(orderBlocks, obTop, obBottom, true)
        f_addZone(orderBlocks, obTop, obBottom, bar_index - obOffset, true, bullishColor, maxOrderBlocks, showObEquilibrium, obDisplayBars)
        newBullishOb := true

if showOrderBlocks and bearishObTrigger
    [obTop, obBottom, obOffset, obFound] = f_findOrderBlock(false, obLookback, obMinAtrMult, obMinBodyPct, obUseVolume, obVolumeMult, bodyOnlyZones, mitigationOnClose, obMaxLoopGuard)
    if obFound and not f_zoneExists(orderBlocks, obTop, obBottom, false)
        f_addZone(orderBlocks, obTop, obBottom, bar_index - obOffset, false, bearishColor, maxOrderBlocks, showObEquilibrium, obDisplayBars)
        newBearishOb := true

//------------------------------------------------------------------------------
// FAIR VALUE GAP ENGINE
//------------------------------------------------------------------------------
f_updateZones(fairValueGaps, mitigationOnClose, hideMitigated, mitigatedColor, fvgMaxAgeBars)

bool bullishFvg = showFvgsFinal and barstate.isconfirmed and bar_index >= 2 and low > high[2] and (low - high[2]) >= atrValue * fvgAtrMult
bool bearishFvg = showFvgsFinal and barstate.isconfirmed and bar_index >= 2 and high < low[2] and (low[2] - high) >= atrValue * fvgAtrMult

if bullishFvg and not f_zoneExists(fairValueGaps, low, high[2], true)
    f_addZone(fairValueGaps, low, high[2], bar_index - 2, true, fvgBullColor, maxFvgs, showFvgEquilibrium, obDisplayBars)

if bearishFvg and not f_zoneExists(fairValueGaps, low[2], high, false)
    f_addZone(fairValueGaps, low[2], high, bar_index - 2, false, fvgBearColor, maxFvgs, showFvgEquilibrium, obDisplayBars)

//------------------------------------------------------------------------------
// PREMIUM / DISCOUNT
//------------------------------------------------------------------------------
float rangeHigh = ta.highest(high, pdLookback)
float rangeLow = ta.lowest(low, pdLookback)
float dealingRange = math.max(rangeHigh - rangeLow, syminfo.mintick)
float premiumFloor = rangeHigh - dealingRange * premiumPct / 100.0
float discountCeiling = rangeLow + dealingRange * discountPct / 100.0
float rangeEquilibrium = (rangeHigh + rangeLow) * 0.5

string currentZone = close >= premiumFloor ? "Premium" :
     close <= discountCeiling ? "Discount" :
     math.abs(close - rangeEquilibrium) <= dealingRange * 0.05 ? "Equilibrium" : "Mid-range"

//------------------------------------------------------------------------------
// OSCILLATOR STATES / SIGNALS
//------------------------------------------------------------------------------
bool bullishDiamond = barstate.isconfirmed and momentumBullCross
bool bearishDiamond = barstate.isconfirmed and momentumBearCross

color momentumColor = oscillatorBullish and momentumExpansion > 0 ? bullishColor :
     momentum > momentumSignal ? color.rgb(241, 196, 15) :
     oscillatorBearish and momentumExpansion < 0 ? bearishColor :
     color.rgb(230, 126, 34)

bool bullishObTouch = f_activeTouch(orderBlocks, true)
bool bearishObTouch = f_activeTouch(orderBlocks, false)
bool enteringBullishOb = barstate.isconfirmed and bullishObTouch and not bullishObTouch[1]
bool enteringBearishOb = barstate.isconfirmed and bearishObTouch and not bearishObTouch[1]

float longScore = 0.0
longScore += flowBias == 1 ? 25.0 : 0.0
longScore += structureState == 1 ? 15.0 : 0.0
longScore += oscillatorBullish ? 15.0 : 0.0
longScore += bullishObTouch ? 25.0 : 0.0
longScore += close <= discountCeiling ? 20.0 : 0.0

float shortScore = 0.0
shortScore += flowBias == -1 ? 25.0 : 0.0
shortScore += structureState == -1 ? 15.0 : 0.0
shortScore += oscillatorBearish ? 15.0 : 0.0
shortScore += bearishObTouch ? 25.0 : 0.0
shortScore += close >= premiumFloor ? 20.0 : 0.0

bool longRequirements = flowBias == 1 and structureState == 1 and
     (not requireObTouch or bullishObTouch) and
     (not requirePdAlignment or close <= discountCeiling) and
     (not requireMomentum or oscillatorBullish) and
     longScore >= minimumSignalScore

bool shortRequirements = flowBias == -1 and structureState == -1 and
     (not requireObTouch or bearishObTouch) and
     (not requirePdAlignment or close >= premiumFloor) and
     (not requireMomentum or oscillatorBearish) and
     shortScore >= minimumSignalScore

bool longEdge = longRequirements and not longRequirements[1]
bool shortEdge = shortRequirements and not shortRequirements[1]
bool longCooldownOk = na(lastLongSignalBar) or bar_index - lastLongSignalBar >= signalCooldown
bool shortCooldownOk = na(lastShortSignalBar) or bar_index - lastShortSignalBar >= signalCooldown

bool buySignal = enableSignals and barstate.isconfirmed and longEdge and longCooldownOk
bool sellSignal = enableSignals and barstate.isconfirmed and shortEdge and shortCooldownOk

if buySignal
    lastLongSignalBar := bar_index

if sellSignal
    lastShortSignalBar := bar_index

bool bullishCombo = bullishShift and oscillatorBullish
bool bearishCombo = bearishShift and oscillatorBearish
bool alignedObEntry = (enteringBullishOb and flowBias == 1) or (enteringBearishOb and flowBias == -1)

//------------------------------------------------------------------------------
// VISUALS
//------------------------------------------------------------------------------
color backgroundColor = flowBias == 1 ? color.new(bullishColor, 89) :
     flowBias == -1 ? color.new(bearishColor, 89) : na
bgcolor(showTrendBackgroundFinal ? backgroundColor : na, title = "Trend Background")

plot(
     showTrailingLineFinal ? supertrendValue : na,
     title = "Flow Bias ATR Trail",
     color = flowBias == 1 ? bullishColor : flowBias == -1 ? bearishColor : neutralColor,
     linewidth = 2,
     style = plot.style_linebr)

plotFast = plot(showRibbonFinal ? oscFast : na, "Ribbon Fast", color = color.new(momentumColor, 0), linewidth = 1)
plotMid = plot(showRibbonFinal ? oscMid : na, "Ribbon Mid", color = color.new(momentumColor, 35), linewidth = 1)
plotSlow = plot(showRibbonFinal ? oscSlow : na, "Ribbon Slow", color = color.new(momentumColor, 10), linewidth = 2)
fill(plotFast, plotSlow, color = showRibbonFinal ? color.new(momentumColor, 88) : na, title = "Momentum Ribbon Fill")

barcolor(colorCandlesFinal ? color.new(momentumColor, 15) : na, title = "Momentum Candle Color")

plotshape(
     showDiamondsFinal and bullishDiamond,
     title = "Bullish Momentum Diamond",
     style = shape.diamond,
     location = location.belowbar,
     color = bullishColor,
     size = size.tiny)

plotshape(
     showDiamondsFinal and bearishDiamond,
     title = "Bearish Momentum Diamond",
     style = shape.diamond,
     location = location.abovebar,
     color = bearishColor,
     size = size.tiny)

plotshape(
     buySignal,
     title = "BUY Signal",
     style = shape.labelup,
     location = location.belowbar,
     color = bullishColor,
     text = "BUY",
     textcolor = color.white,
     size = size.tiny)

plotshape(
     sellSignal,
     title = "SELL Signal",
     style = shape.labeldown,
     location = location.abovebar,
     color = bearishColor,
     text = "SELL",
     textcolor = color.white,
     size = size.tiny)

pdHighPlot = plot(showPdZonesFinal ? rangeHigh : na, "Dealing Range High", color = color.new(bearishColor, 70), linewidth = 1)
pdPremiumPlot = plot(showPdZonesFinal ? premiumFloor : na, "Premium Boundary", color = color.new(bearishColor, 55), linewidth = 1)
pdDiscountPlot = plot(showPdZonesFinal ? discountCeiling : na, "Discount Boundary", color = color.new(bullishColor, 55), linewidth = 1)
pdLowPlot = plot(showPdZonesFinal ? rangeLow : na, "Dealing Range Low", color = color.new(bullishColor, 70), linewidth = 1)
plot(showPdZonesFinal and showPdEquilibrium ? rangeEquilibrium : na, "Dealing Range Equilibrium", color = color.new(neutralColor, 20), linewidth = 1)
fill(pdHighPlot, pdPremiumPlot, color = showPdZonesFinal ? color.new(bearishColor, 92) : na, title = "Premium Zone")
fill(pdDiscountPlot, pdLowPlot, color = showPdZonesFinal ? color.new(bullishColor, 92) : na, title = "Discount Zone")

// Completed higher-timeframe levels using an offset expression and lookahead_on
float previousDayHigh = request.security(syminfo.tickerid, "D", high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousDayLow = request.security(syminfo.tickerid, "D", low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousWeekHigh = request.security(syminfo.tickerid, "W", high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousWeekLow = request.security(syminfo.tickerid, "W", low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousMonthHigh = request.security(syminfo.tickerid, "M", high[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
float previousMonthLow = request.security(syminfo.tickerid, "M", low[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

plot(showPreviousDayFinal ? previousDayHigh : na, "PDH", color = color.new(bearishColor, 25), linewidth = 1, style = plot.style_stepline)
plot(showPreviousDayFinal ? previousDayLow : na, "PDL", color = color.new(bullishColor, 25), linewidth = 1, style = plot.style_stepline)
plot(showPreviousWeekFinal ? previousWeekHigh : na, "PWH", color = color.new(bearishColor, 10), linewidth = 1, style = plot.style_stepline)
plot(showPreviousWeekFinal ? previousWeekLow : na, "PWL", color = color.new(bullishColor, 10), linewidth = 1, style = plot.style_stepline)
plot(showPreviousMonthFinal ? previousMonthHigh : na, "PMH", color = bearishColor, linewidth = 1, style = plot.style_stepline)
plot(showPreviousMonthFinal ? previousMonthLow : na, "PML", color = bullishColor, linewidth = 1, style = plot.style_stepline)

//------------------------------------------------------------------------------
// DASHBOARD
//------------------------------------------------------------------------------
int activeBullishObs = f_countActive(orderBlocks, true)
int activeBearishObs = f_countActive(orderBlocks, false)
int activeBullishFvgs = f_countActive(fairValueGaps, true)
int activeBearishFvgs = f_countActive(fairValueGaps, false)
int activeLiquidity = f_countActiveLiquidity(liquidityPools)

string biasText = flowBias == 1 ? "Bullish" : flowBias == -1 ? "Bearish" : "Neutral"
color biasColor = flowBias == 1 ? bullishColor : flowBias == -1 ? bearishColor : neutralColor
float displayedScore = flowBias == 1 ? longScore : flowBias == -1 ? shortScore : math.max(longScore, shortScore)

var table dashboard = table.new(
     position.top_right,
     2,
     7,
     bgcolor = color.new(color.black, 82),
     frame_color = color.new(color.white, 80),
     frame_width = 1,
     border_color = color.new(color.white, 88),
     border_width = 1)

if barstate.islast
    if showDashboardFinal
        table.cell(dashboard, 0, 0, "FLOW MATRIX", text_color = color.white, bgcolor = color.new(biasColor, 65))
        table.cell(dashboard, 1, 0, "Confluence", text_color = color.white, bgcolor = color.new(biasColor, 65))
        table.cell(dashboard, 0, 1, "Score", text_color = color.silver)
        table.cell(dashboard, 1, 1, str.tostring(displayedScore, "#") + " / 100", text_color = color.white)
        table.cell(dashboard, 0, 2, "Bias", text_color = color.silver)
        table.cell(dashboard, 1, 2, biasText, text_color = biasColor)
        table.cell(dashboard, 0, 3, "Structure", text_color = color.silver)
        table.cell(dashboard, 1, 3, lastStructureEvent, text_color = color.white)
        table.cell(dashboard, 0, 4, "Order Blocks", text_color = color.silver)
        table.cell(dashboard, 1, 4, str.tostring(activeBullishObs) + " B / " + str.tostring(activeBearishObs) + " S", text_color = color.white)
        table.cell(dashboard, 0, 5, "FVGs & Liquidity", text_color = color.silver)
        table.cell(dashboard, 1, 5, str.tostring(activeBullishFvgs) + "B " + str.tostring(activeBearishFvgs) + "S | " + str.tostring(activeLiquidity) + " Liq", text_color = color.white)
        table.cell(dashboard, 0, 6, "Range Zone", text_color = color.silver)
        table.cell(dashboard, 1, 6, currentZone, text_color = currentZone == "Discount" ? bullishColor : currentZone == "Premium" ? bearishColor : color.white)
    else
        for row = 0 to 6
            table.cell(dashboard, 0, row, "", bgcolor = color.new(color.black, 100))
            table.cell(dashboard, 1, row, "", bgcolor = color.new(color.black, 100))

//------------------------------------------------------------------------------
// ALERTS
//------------------------------------------------------------------------------
alertcondition(alertBos and (bullishBos or bearishBos), "New BOS", "New confirmed BOS on {{ticker}} {{interval}}.")
alertcondition(alertChoch and (bullishChoch or bearishChoch), "New CHoCH", "New confirmed CHoCH on {{ticker}} {{interval}}.")
alertcondition(alertNewOb and (newBullishOb or newBearishOb), "New Order Block", "New unmitigated order block on {{ticker}} {{interval}}.")
alertcondition(alertBuy and buySignal, "BUY Signal", "Flow Matrix BUY signal on {{ticker}} {{interval}} at {{close}}.")
alertcondition(alertSell and sellSignal, "SELL Signal", "Flow Matrix SELL signal on {{ticker}} {{interval}} at {{close}}.")
alertcondition(alertObEntry and alignedObEntry, "Aligned Order Block Entry", "Price entered an active order block aligned with bias on {{ticker}} {{interval}}.")
alertcondition(alertCombo and (bullishCombo or bearishCombo), "Bias + Momentum Confluence", "Directional bias and momentum are aligned on {{ticker}} {{interval}}.")
alertcondition(alertLiquiditySweep and (highLiquiditySweep or lowLiquiditySweep), "Liquidity Sweep", "Confirmed liquidity sweep on {{ticker}} {{interval}}.")
````
