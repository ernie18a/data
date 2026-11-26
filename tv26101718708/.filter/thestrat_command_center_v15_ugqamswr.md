# TheStrat Command Center v1.5

- url: https://www.tradingview.com/script/uGQamSwr-TheStrat-Command-Center-v1-5/
- type: indicator
- pine_id: PUB;65103c1b15144097bc48f7ae64245db2
- version: 4.0

## Description

[b]TheStrat Command Center[/b]

TheStrat Command Center is a chart-based decision-support tool built for traders who use "The Strat" methodology created by Rob Smith (R.I.P.)

Its purpose is to organize several pieces of TheStrat information that normally have to be monitored separately — current candle structure, possible next directional setups, Full Time Frame Continuity (FTFC), entry and invalidation levels, nearby objectives, and risk-based targets — into one live dashboard.

It is not intended to predict the market or replace the trader's own interpretation of price action. The goal is to make the current Strat structure easier to read and manage.

[b]Strat Structure[/b]

The indicator classifies price bars using the standard Strat framework:

1 - Inside bar
2U - Breaks the previous high without breaking the previous low
2D - Breaks the previous low without breaking the previous high
3 - Outside bar that breaks both sides

The prior closed candle is treated as the current setup candle. The developing candle is then evaluated against that completed setup.

The Command Center uses that relationship to identify possible structures such as:

2-2 reversals
2U or 2D continuation
2-1-2 structures
3-to-2 directional resolution
Failed 2 reversals

Both the upside and downside possibilities remain visible so the trader can see what price would need to do in either direction.

[b]Failed 2 Recognition[/b]

Failed 2 candles are handled separately from ordinary 2 bars.

A Failed 2U must first be a true 2U and then close below its own open.

A Failed 2D must first be a true 2D and then close above its own open.

If the candle breaks both the previous high and previous low, it is classified as a "3", which overrides the Failed 2 condition.

Failed 2 markers are placed on the actual failed candle after it closes.

[b]Full Time Frame Continuity
[/b]
The indicator monitors up to six user-selected timeframes for Full Time Frame Continuity.

Each timeframe is evaluated by comparing its current price with its timeframe open:

Green = above the timeframe open
Red = below the timeframe open
Flat = at the timeframe open

Users can choose which of the six timeframes are [b]required[/b] for FTFC.

Full bullish FTFC exists only when every required timeframe is bullish. Full bearish FTFC exists only when every required timeframe is bearish. A majority or directional lean is not treated as Full Time Frame Continuity.

An optional setting can restrict new suggested trades to setups that agree with Full FTFC. Timeframes that are displayed but not marked as required remain informational and do not block a setup.

[b]Command Center Dashboard[/b]

The dashboard is intended to answer, at a glance:

* What is happening now?
* What was the last completed Strat candle?
* Is a reversal currently available?
* Is Full Time Frame Continuity present?
* What is the best structural play under the selected FTFC rules?
* What are the possible upside and downside plays?
* Where are the applicable entry and stop levels?
* How far is price from the next trigger?
* Where are nearby structural objectives?
* Where is price relative to the trading-session open?

The indicator includes separate Desktop and Mobile layouts. The Desktop dashboard can also hide its lower detail section to conserve chart space.

[b]Entry, Stop and R-Based Target[/b]

For standard Strat setups, the indicator calculates a potential entry beyond the setup candle high or low using a user-selected tick offset.

The opposite side of the setup candle is used as the invalidation/stop reference.

Failed 2 reversals use a fixed rule:

* Failed 2D long: entry one minimum tick above the Failed 2D high and stop one tick below its low.
* Failed 2U short: entry one minimum tick below the Failed 2U low and stop one tick above its high.

Once the entry-to-stop distance is known, the indicator calculates a user-selected reward target from 0.5R through 5R, where 1R equals the initial entry-to-stop risk.

These levels are informational chart references and are not brokerage orders.

[b]Waiting and Active Trade Lines[/b]

Before a setup triggers, optional dashed entry stubs show the available directional trigger levels.

If one side triggers, the opposite waiting setup is removed and the chart can display:

* Entry
* Stop
* Selected R target

The lines remain while that setup is active.

When the target or stop is reached, the active trade lines are removed automatically. A user may also manually dismiss a waiting setup or cancel the indicator's monitoring of an active setup without recording it as a target or stop result.

If both sides of the setup candle are broken by the same developing bar, the condition is treated structurally as an outside/3 bar rather than assuming a directional entry.

[b]Session Levels and Objectives[/b]

The indicator can also display contextual price levels.

For futures, the reference trading session begins at [b]6:00 PM Eastern Time[/b].

For equities, indexes and other non-futures instruments, the reference session begins at [b]9:30 AM Eastern Time[/b].

The dashboard can show:

* Reference session open
* Previous session high
* Previous session low
* Recent range high and low
* Distance to the next upside or downside trigger
* Nearby prior-high or prior-low objectives

The recent-range lookback is user-adjustable.

These objective levels are contextual references. They are not predictions that price will reach those levels.

[b]Alerts[/b]

Alert conditions are included for:

* Confirmed Failed 2U
* Confirmed Failed 2D
* Confirmed upside trigger
* Confirmed downside trigger
* Target reached
* Stop reached

[b]Developing vs. Confirmed Information
[/b]
The Command Center intentionally contains both closed-bar structural information and live developing information.

The setup itself is based on the prior completed candle. Failed 2 identification is confirmed on candle close.

The current developing candle type can change before that candle closes as new highs or lows are made.

FTFC also uses the current state of the selected higher-timeframe candles. Because those candles remain open until their respective timeframes close, their green/red state — and therefore live FTFC — can change intrabar.

Users should distinguish these live contextual readings from closed-bar confirmations.

[b]Limitations[/b]

This is an [b]indicator, not a TradingView strategy or backtest[/b]. It does not provide historical profitability statistics or claim that a displayed setup will be successful.

The indicator does not know the exact sequence of every price movement inside a completed historical candle. If multiple relevant levels are touched within the same bar, OHLC chart data may not reveal which price traded first.

Results and displayed structures can also vary depending on symbol, chart timeframe, market session, selected FTFC timeframes, tick offset, R target, and available chart data.

The tool is designed for standard price charts and should be interpreted alongside the trader's own analysis and risk-management process.

[b]What Makes the Script Different[/b]

The Command Center is designed as an integrated Strat workflow rather than simply placing candle numbers on a chart.

It combines the prior closed-bar setup, live directional resolution, exact Failed 2 handling, user-defined FTFC requirements, two-sided structural possibilities, trigger/invalidation levels, R-based trade planning, session context, nearby objectives, active-setup management, alerts, and desktop/mobile presentation into a single decision hierarchy.

Its purpose is to reduce the amount of separate chart information a Strat trader has to mentally assemble while preserving the underlying price-action structure.

## Source Code

````pine
//@version=6
indicator("TheStrat Command Center v2.2.1.1", shorttitle="Strat Command Center v2.2.1.1", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50)

//=============================================================================
// 1. STRAT ENGINE
//=============================================================================
string GRP_ENGINE = "1. Strat Engine"
int triggerTicks = input.int(1, "Trigger offset (ticks)", minval=0, group=GRP_ENGINE, tooltip="For standard Strat setups, entry is this many minimum ticks beyond the setup candle high/low. Failed 2 reversal ENTRIES remain fixed at exactly 1 tick beyond the Failed 2 candle.")

// Entry can remain fully Strat-driven or become a user-constructed exact-price trade.
string entryMethod = input.string("Strat Setup", "Entry method", options=["Strat Setup", "Custom price"], group=GRP_ENGINE, tooltip="Strat Setup preserves the Command Center entry engine. Custom price lets the user construct a specific LONG or SHORT trade at an exact entry price. Custom trades are armed from the NEXT chart bar after settings are applied so a prior intrabar touch is never invented.")
string customTradeDirection = input.string("Long", "Custom trade direction", options=["Long", "Short"], group=GRP_ENGINE, tooltip="Used only when Entry method = Custom price.")
float customEntryPrice = input.price(0.0, "Custom entry price", group=GRP_ENGINE, tooltip="Used only when Entry method = Custom price. Enter the exact price that should activate the user-constructed trade. A value of 0 is treated as not configured.")
int customTradeTicket = input.int(1, "Custom trade ticket", minval=1, maxval=1000000, group=GRP_ENGINE, tooltip="Custom trades are one-shot for a given configuration. Increment this ticket to arm a NEW custom trade while keeping the same Entry / Stop / Target prices.")

// Stop method: preserve the original structure-based stop as the default, while
// also allowing a user-defined fixed tick distance from entry.
string stopMethod = input.string("Structure stop", "Stop method", options=["Structure stop", "Custom ticks", "Custom price"], group=GRP_ENGINE, tooltip="Structure stop preserves the original Command Center logic. Custom ticks places the stop a fixed number of minimum ticks from the actual entry. Custom price uses the exact stop price entered below. A custom price must be below entry for a LONG and above entry for a SHORT.")
int customStopTicks = input.int(20, "Custom stop distance (ticks)", minval=1, maxval=10000, group=GRP_ENGINE, tooltip="Used only when Stop method = Custom ticks. LONG: stop = entry minus this many ticks. SHORT: stop = entry plus this many ticks.")
float customStopPrice = input.price(0.0, "Custom stop price", group=GRP_ENGINE, tooltip="Used only when Stop method = Custom price. Enter the exact market price for the stop. LONG requires stop below entry. SHORT requires stop above entry. A value of 0 is treated as not configured.")

// Target method: keep every R choice from the earlier builds and add a separate
// user-defined take-profit option. Neither option removes the other.
string targetMethod = input.string("R multiple", "Take-profit method", options=["R multiple", "Custom ticks", "Custom price", "Structured objective"], group=GRP_ENGINE, tooltip="R multiple uses the selected reward multiple of the ACTUAL initial entry-to-stop risk. Custom ticks uses a fixed distance from entry. Custom price uses the exact take-profit price entered below. Structured objective uses the selected higher-timeframe targeting module. A custom price must be above entry for a LONG and below entry for a SHORT.")
string targetRChoice = input.string("2R", "R target", options=["0.5R", "1R", "1.5R", "2R", "2.5R", "3R", "3.5R", "4R", "4.5R", "5R"], group=GRP_ENGINE, tooltip="Used only when Take-profit method = R multiple. Example: 2R targets twice the actual initial entry-to-stop risk.")
float targetR = switch targetRChoice
    "0.5R" => 0.5
    "1R" => 1.0
    "1.5R" => 1.5
    "2R" => 2.0
    "2.5R" => 2.5
    "3R" => 3.0
    "3.5R" => 3.5
    "4R" => 4.0
    "4.5R" => 4.5
    => 5.0
int customTakeProfitTicks = input.int(20, "Custom take-profit distance (ticks)", minval=1, maxval=10000, group=GRP_ENGINE, tooltip="Used only when Take-profit method = Custom ticks. LONG: TP = entry plus this many ticks. SHORT: TP = entry minus this many ticks.")
float customTakeProfitPrice = input.price(0.0, "Custom take-profit price", group=GRP_ENGINE, tooltip="Used only when Take-profit method = Custom price. Enter the exact market price for the target. LONG requires target above entry. SHORT requires target below entry. A value of 0 is treated as not configured.")

int targetLookback = input.int(20, "Recent-range objective lookback", minval=3, maxval=200, group=GRP_ENGINE, tooltip="Used to identify nearby prior high/low objectives and available room.")
bool showLiveBarType = input.bool(true, "Show developing bar type", group=GRP_ENGINE)

//=============================================================================
// 1B. TRADE OUTCOME TRACKING / TIME EXIT
//=============================================================================
string GRP_OUTCOMES = "1B. Trade Outcome Tracking"
int maxBarsInTrade = input.int(0, "Maximum bars in active trade (0 = Off)", minval=0, maxval=100, group=GRP_OUTCOMES, tooltip="Third deterministic exit: Take Profit, Stop, or Time Exit — whichever occurs first. TP and Stop use the methods selected above. The entry candle is Bar 0. If 3 is selected, the trade gets the remainder of the entry candle plus 3 COMPLETE candles. If TP/Stop has not been touched, it closes at the close of that third complete candle. Use 0 for unlimited holding until TP/Stop.")
bool showTradeOutcomeStats = input.bool(true, "Show trade outcome stats in Desktop details", group=GRP_OUTCOMES, tooltip="Adds LAST CLOSED and OUTCOME BUCKETS rows when the Desktop lower-details section is visible. Buckets: TP, Stop, profitable timed exit, losing timed exit, flat timed exit, plus average R. Mobile stays compact.")

//=============================================================================
// 1C. STRUCTURED OBJECTIVE TARGETING
// v2.1.11: BF and FVG can be enabled independently or together.
// This module NEVER creates a trade. It only identifies possible price-delivery
// objectives and can optionally supply the Take Profit price.
//=============================================================================
string GRP_STRUCT = "1C. Structured Objective Targeting"
bool enableStructuredObjectives = input.bool(false, "Enable structured objective module", group=GRP_STRUCT, tooltip="Master switch for structured targeting/context. This module NEVER creates, qualifies, blocks, or reverses a Strat trade; it can supply the TP only when Take-profit method = Structured objective.")
bool enableBfObjectives = input.bool(true, "Enable Broadening Formation targets/context", group=GRP_STRUCT, inline="mods", tooltip="Controls Broadening Formation features inside Structured Objectives: BF High/Low, midpoint, BF 50/70 zone, BF drawings, BF alerts, and BF eligibility as a structured target.")
bool enableFvgObjectives = input.bool(true, "Enable Fair Value Gap targets/context", group=GRP_STRUCT, inline="mods", tooltip="Controls Fair Value Gap features inside Structured Objectives: FVG boxes/status labels and FVG eligibility as a structured target. Turning this off does not change Strat setup or FTFC logic.")
string targetHTF = input.timeframe("240", "FVG / swing target timeframe", group=GRP_STRUCT, tooltip="Higher timeframe used for FVGs and confirmed swing highs/lows.")
string bfTargetHTF = input.timeframe("240", "Broadening Formation timeframe", group=GRP_STRUCT, tooltip="Timeframe used for the active Strat broadening-formation range. Default 4H. BF High/Low are calculated only from completed candles on this timeframe.")
int bfLookback = input.int(70, "BF maximum search bars", minval=2, maxval=500, group=GRP_STRUCT, tooltip="Maximum number of COMPLETED Broadening Formation timeframe candles scanned backward to find the MOST RECENT two-sided expansion. This is only a search limit; it does NOT define the BF range. A BF may be one literal 3 candle or several candles that, together, take both sides of a prior confirmed candle.")
string structuredTargetSelection = input.string("Nearest Strat objective (BF/Swing/FVG)", "Structured target selection", options=["Nearest Strat objective (BF/Swing/FVG)", "Nearest enabled objective", "BF High / Low", "BF Midpoint", "Swing H/L", "Fair Value Gap", "PDH / PDL", "BF 50/70 zone"], group=GRP_STRUCT, tooltip="The default keeps TheStrat first: the nearest eligible Broadening Formation boundary, confirmed Swing H/L, or FVG in the trade direction. Specific selections let the user explicitly target one structure type.")
bool useStructuredBF = input.bool(true, "Allow BF High/Low as target", group=GRP_STRUCT, inline="obj0")
bool useStructuredBFMid = input.bool(false, "Allow BF midpoint", group=GRP_STRUCT, inline="obj0", tooltip="The BF midpoint is optional. It is considered only when enabled or explicitly selected.")
bool useStructuredSwing = input.bool(true, "Allow confirmed Swing H/L as target", group=GRP_STRUCT, inline="obj1")
bool useStructuredFVG = input.bool(true, "Allow FVG as target", group=GRP_STRUCT, inline="obj1")
bool useStructuredPD = input.bool(false, "Allow PDH / PDL as target", group=GRP_STRUCT, inline="obj2", tooltip="PDH/PDL remain useful day-to-day reference levels, but are OFF by default as automatic structured TP candidates.")
bool useStructured5070 = input.bool(false, "Allow BF 50/70 zone as target", group=GRP_STRUCT, inline="obj2")
int swingLeft = input.int(2, "Swing pivot left bars", minval=1, maxval=20, group=GRP_STRUCT, inline="sw")
int swingRight = input.int(2, "right bars", minval=1, maxval=20, group=GRP_STRUCT, inline="sw", tooltip="A swing is not used until the pivot is confirmed by the selected number of bars on the right. This prevents unfinished pivots from becoming targets.")
float fibLevel1Pct = input.float(50.0, "BF retracement level 1 %", minval=0, maxval=100, step=1, group=GRP_STRUCT, inline="fib")
float fibLevel2Pct = input.float(70.0, "level 2 %", minval=0, maxval=100, step=1, group=GRP_STRUCT, inline="fib", tooltip="The BF 50/70 zone is measured inside the active BF High/Low range. Direction comes from the last confirmed candle on the selected BF timeframe, matching the mature 4H BF structure approach.")
bool showStructuredLevelsOnChart = input.bool(true, "Show structured target drawings on chart", group=GRP_STRUCT, tooltip="Master switch for target drawings only. These drawings never activate a trade.")
bool showStructuredBfRef = input.bool(true, "Chart: BF High/Low", group=GRP_STRUCT, inline="chart0")
bool showStructuredBfMidRef = input.bool(false, "BF midpoint", group=GRP_STRUCT, inline="chart0")
bool showStructuredSwingRef = input.bool(false, "Swing H/L lines", group=GRP_STRUCT, inline="chart1")
bool showStructuredFvgRef = input.bool(true, "FVG boxes", group=GRP_STRUCT, inline="chart1", tooltip="Draws still-unmitigated selected-HTF FVGs as labeled boxes extending from their original formation to the right.")
int historicalFvgsPerSide = input.int(3, "Unmitigated FVGs per side to show", minval=1, maxval=10, group=GRP_STRUCT, tooltip="Shows up to this many of the most recent still-unmitigated BULL FVGs and this many still-unmitigated BEAR FVGs from the selected FVG/swing timeframe. Older active FVGs continue to be tracked internally.")
string fvgMitigationRule = input.string("Full fill", "FVG mitigation rule", options=["Full fill", "50% fill", "First touch"], group=GRP_STRUCT, tooltip="Controls when an active FVG is retired. Full fill: price reaches the far side of the gap. 50% fill: price reaches the midpoint. First touch: price touches the near edge. Default = Full fill.")
int fvgFollowThroughBars = input.int(3, "FVG follow-through candles", minval=1, maxval=10, group=GRP_STRUCT, tooltip="After an FVG is RESPECTED, this is how many subsequent confirmed candles on that SAME FVG/swing timeframe are allowed to create a new same-direction FVG. If none appears, the original FVG is labeled WEAKNESS. This remains target context only.")
bool showStructuredPdRef = input.bool(false, "PDH/PDL lines", group=GRP_STRUCT, inline="chart2")
bool showStructured5070Ref = input.bool(true, "BF 50/70 box", group=GRP_STRUCT, inline="chart2", tooltip="Draws the 50/70 reaction zone inside the active Broadening Formation range.")
int structuredProjectionBars = input.int(8, "Structured box/reference length (bars)", minval=2, maxval=30, group=GRP_STRUCT, tooltip="Controls how far BF rails, BF midpoint, the BF 50/70 box, and optional swing/PDH/PDL references project right. Historical FVG boxes extend right until mitigated.")
string structuredLabelSizeChoice = input.string("Small", "Structured drawing label size", options=["Tiny", "Small", "Normal"], group=GRP_STRUCT)
int structuredBfLineWidth = input.int(3, "BF High/Low line width", minval=1, maxval=4, group=GRP_STRUCT, inline="bfline")
int structuredBfLineTransparency = input.int(0, "line transparency", minval=0, maxval=90, group=GRP_STRUCT, inline="bfline")
int structuredBfRailLeftBars = input.int(30, "BF target rail bars to left", minval=5, maxval=150, group=GRP_STRUCT, inline="bfrail", tooltip="Makes the active BF High/Low visually primary by carrying each target rail back across this many chart bars. This changes drawing only, never the BF calculation.")
int structuredBfBandTicks = input.int(1, "band half-width (ticks)", minval=0, maxval=20, group=GRP_STRUCT, inline="bfrail", tooltip="Optional narrow shaded band centered on the exact BF High/Low. 0 removes the band and leaves only the exact target rail.")
int structuredBfBandTransparency = input.int(88, "BF target band transparency", minval=0, maxval=95, group=GRP_STRUCT)
string structuredBfLabelSizeChoice = input.string("Normal", "BF target label size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_STRUCT)
int structuredBfLabelOffsetBars = input.int(2, "BF label offset right (bars)", minval=0, maxval=20, group=GRP_STRUCT, inline="bflabel", tooltip="Moves only the BF High/Low target labels farther right. The target price and detection do not change.")
color structuredBfLabelTextColor = input.color(color.white, "BF label text", group=GRP_STRUCT, inline="bflabel")
color structuredBfHighColor = input.color(color.rgb(230, 80, 80), "BF High color", group=GRP_STRUCT)
color structuredBfLowColor = input.color(color.rgb(35, 170, 105), "BF Low color", group=GRP_STRUCT)
color structuredBfMidColor = input.color(color.rgb(180, 180, 190), "BF midpoint color", group=GRP_STRUCT)
bool structuredAutoStaggerLabels = input.bool(true, "Auto-stagger overlapping BF / FVG labels", group=GRP_STRUCT, tooltip="If a BF High/Low sits inside or very near the nearest FVG, its label is automatically moved farther right so the two labels remain readable. Drawing only; no target logic changes.")
int structuredOverlapTicks = input.int(8, "Label-overlap proximity (ticks)", minval=0, maxval=100, group=GRP_STRUCT, inline="stagger")
int structuredCollisionExtraBars = input.int(5, "extra BF label bars", minval=1, maxval=20, group=GRP_STRUCT, inline="stagger")
int structuredFvgTransparency = input.int(82, "FVG box fill transparency", minval=0, maxval=95, group=GRP_STRUCT)
int structuredFvgBorderWidth = input.int(1, "FVG border width", minval=1, maxval=4, group=GRP_STRUCT, inline="fvgborder")
int structuredFvgBorderTransparency = input.int(15, "border transparency", minval=0, maxval=90, group=GRP_STRUCT, inline="fvgborder")
string structuredFvgLabelSizeChoice = input.string("Small", "FVG label size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_STRUCT, inline="fvglabel")
int structuredFvgLabelOffsetBars = input.int(1, "offset right", minval=0, maxval=20, group=GRP_STRUCT, inline="fvglabel", tooltip="Places the FVG label this many chart bars to the right of the current bar while the FVG box itself continues to extend from its original formation.")
int structuredFvgLabelBgTransparency = input.int(72, "FVG label background transparency", minval=0, maxval=95, group=GRP_STRUCT)
string structuredFvgLabelDetail = input.string("State + range", "FVG label detail", options=["State + range", "State only", "Range only", "Name only"], group=GRP_STRUCT, tooltip="Controls only the label text. The FVG lifecycle and target calculations remain unchanged.")
color structuredFvgUntestedColor = input.color(color.rgb(255, 193, 7), "FVG UNTESTED color", group=GRP_STRUCT)
color structuredFvgRespectedColor = input.color(color.rgb(46, 125, 50), "FVG RESPECTED color", group=GRP_STRUCT)
color structuredFvgConfirmedColor = input.color(color.rgb(0, 150, 136), "FVG RESPECTED + NEW FVG color", group=GRP_STRUCT)
color structuredFvgWeaknessColor = input.color(color.rgb(245, 124, 0), "FVG WEAKNESS color", group=GRP_STRUCT)
color structuredFvgDisrespectedColor = input.color(color.rgb(198, 40, 40), "FVG DISRESPECTED color", group=GRP_STRUCT)
color structuredFvgLabelTextColor = input.color(color.white, "FVG label text color", group=GRP_STRUCT)
int structuredZoneTransparency = input.int(86, "BF 50/70 box fill transparency", minval=0, maxval=95, group=GRP_STRUCT)
int structuredZoneBorderWidth = input.int(1, "BF 50/70 border width", minval=0, maxval=4, group=GRP_STRUCT, inline="zoneborder")
int structuredZoneBorderTransparency = input.int(20, "border transparency", minval=0, maxval=100, group=GRP_STRUCT, inline="zoneborder")
string structuredZoneLabelSizeChoice = input.string("Small", "BF 50/70 label size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_STRUCT, inline="zonelabel")
color structuredZoneLabelTextColor = input.color(color.white, "label text", group=GRP_STRUCT, inline="zonelabel")
color structuredSwingColor = input.color(color.rgb(33, 150, 243), "Swing color", group=GRP_STRUCT)
color structuredPdColor = input.color(color.rgb(0, 188, 212), "PDH / PDL color", group=GRP_STRUCT)
color structuredZoneColor = input.color(color.rgb(255, 152, 0), "BF 50/70 box color", group=GRP_STRUCT)

//=============================================================================
// 2. FTFC
//=============================================================================
string GRP_FTFC = "2. Full Time Frame Continuity"
string tf1 = input.timeframe("1M", "TF 1", group=GRP_FTFC, inline="ft1")
bool reqTf1 = input.bool(true, "REQ", group=GRP_FTFC, inline="ft1", tooltip="When checked, TF 1 must agree with every other checked timeframe for a setup to qualify as Full Time Frame Continuity.")
string tf2 = input.timeframe("1W", "TF 2", group=GRP_FTFC, inline="ft2")
bool reqTf2 = input.bool(true, "REQ", group=GRP_FTFC, inline="ft2", tooltip="When checked, TF 2 must agree with every other checked timeframe for a setup to qualify as Full Time Frame Continuity.")
string tf3 = input.timeframe("1D", "TF 3", group=GRP_FTFC, inline="ft3")
bool reqTf3 = input.bool(true, "REQ", group=GRP_FTFC, inline="ft3", tooltip="When checked, TF 3 must agree with every other checked timeframe for a setup to qualify as Full Time Frame Continuity.")
string tf4 = input.timeframe("240", "TF 4", group=GRP_FTFC, inline="ft4")
bool reqTf4 = input.bool(true, "REQ", group=GRP_FTFC, inline="ft4", tooltip="When checked, TF 4 must agree with every other checked timeframe for a setup to qualify as Full Time Frame Continuity.")
string tf5 = input.timeframe("60", "TF 5", group=GRP_FTFC, inline="ft5")
bool reqTf5 = input.bool(true, "REQ", group=GRP_FTFC, inline="ft5", tooltip="When checked, TF 5 must agree with every other checked timeframe for a setup to qualify as Full Time Frame Continuity.")
string tf6 = input.timeframe("15", "TF 6", group=GRP_FTFC, inline="ft6")
bool reqTf6 = input.bool(true, "REQ", group=GRP_FTFC, inline="ft6", tooltip="When checked, TF 6 must agree with every other checked timeframe for a setup to qualify as Full Time Frame Continuity.")
bool onlySuggestWithFTFC = input.bool(false, "Enforce required HTFs for suggested trades", group=GRP_FTFC, tooltip="This filter becomes ACTIVE only when at least one timeframe is checked REQ. When active, both UPSIDE and DOWNSIDE structural rows remain visible, but chart suggestions and new trade activation are allowed only when EVERY REQ timeframe agrees in that direction. If zero timeframes are checked REQ, this setting is inert and does not suppress any suggested trades. An already-active trade continues to be managed even if FTFC later changes.")

//=============================================================================
// 3. TRADE LINES
//=============================================================================
string GRP_LINES = "3. Trade Lines"
bool showTradeLines = input.bool(true, "Show short trade lines", group=GRP_LINES)
bool showCandidateLines = input.bool(true, "Show waiting entry stubs", group=GRP_LINES, tooltip="Before a trigger, show short dashed entry stubs for the two available directions.")
bool showLineLabels = input.bool(true, "Show line labels", group=GRP_LINES)
string candidateLabelSizeChoice = input.string("Small", "Waiting setup label size", options=["Tiny", "Small", "Normal", "Large", "XL"], group=GRP_LINES, tooltip="Controls the text size of the two untriggered setup labels.")
string activeLabelSizeChoice = input.string("Normal", "Active trade label size", options=["Tiny", "Small", "Normal", "Large", "XL"], group=GRP_LINES, tooltip="Controls ENTRY, STOP and TARGET label size after a trade triggers.")
int labelOffsetBars = input.int(0, "Label offset right (bars)", minval=0, maxval=10, group=GRP_LINES, tooltip="Moves line labels farther to the right without changing the trade-line length.")
int candidateLabelTransparency = input.int(20, "Waiting label background transparency", minval=0, maxval=90, group=GRP_LINES)
int activeLabelTransparency = input.int(0, "Active label background transparency", minval=0, maxval=90, group=GRP_LINES)
color candidateLabelTextColor = input.color(color.white, "Waiting label text color", group=GRP_LINES)
color entryLabelTextColor = input.color(color.white, "Entry label text color", group=GRP_LINES)
color stopLabelTextColor = input.color(color.black, "Stop label text color", group=GRP_LINES)
color targetLabelTextColor = input.color(color.white, "Target label text color", group=GRP_LINES)
int projectionBars = input.int(3, "Project lines right (bars)", minval=1, maxval=20, group=GRP_LINES)
int activeLineWidth = input.int(2, "Active line width", minval=1, maxval=4, group=GRP_LINES)
color longLineColor = input.color(color.rgb(0, 188, 212), "Long / upside color", group=GRP_LINES)
color shortLineColor = input.color(color.rgb(255, 152, 0), "Short / downside color", group=GRP_LINES)
color targetLineColor = input.color(color.rgb(156, 39, 176), "Target color", group=GRP_LINES)
color stopLineColor = input.color(color.rgb(176, 190, 197), "Stop color", group=GRP_LINES)

//=============================================================================
// 4. OPTIONAL CHART LEVELS
//=============================================================================
string GRP_LEVELS = "4. Optional Chart Levels"
bool showKeyLevels = input.bool(false, "Plot Daily Open / PDH / PDL", group=GRP_LEVELS)
bool showSignalMarkers = input.bool(true, "Plot confirmed trigger markers", group=GRP_LEVELS)
bool showFailed2Markers = input.bool(true, "Mark Failed 2 candles", group=GRP_LEVELS, tooltip="Marks the ACTUAL failed 2 candle on its close. Failed 2U = a true 2U that breaks only the prior high and closes below its own open (red). Failed 2D = a true 2D that breaks only the prior low and closes above its own open (green). If the candle breaks BOTH sides of the prior candle, it is a 3 and 3 overrides Failed 2.")
string failed2LabelSizeChoice = input.string("Normal", "Failed 2 marker size", options=["Tiny", "Small", "Normal", "Large", "XL"], group=GRP_LEVELS)
color failed2UpColor = input.color(color.rgb(210, 55, 55), "Failed 2U marker color", group=GRP_LEVELS)
color failed2DownColor = input.color(color.rgb(20, 145, 85), "Failed 2D marker color", group=GRP_LEVELS)
color failed2TextColor = input.color(color.white, "Failed 2 marker text", group=GRP_LEVELS)

//=============================================================================
// 5. DASHBOARD LAYOUT
//=============================================================================
string GRP_DASH = "5. Dashboard Layout"
bool showDashboard = input.bool(true, "Show Command Center", group=GRP_DASH)
string dashboardMode = input.string("Desktop", "Dashboard mode", options=["Desktop", "Mobile"], group=GRP_DASH, tooltip="Desktop shows the full Command Center. Mobile uses a compact 4-column layout designed for phone screens while preserving the key trading information.")
string dashboardPos = input.string("Top Right", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=GRP_DASH)
string dashboardSize = input.string("Tiny", "Table text size", options=["Tiny", "Small", "Normal", "Large", "XL"], group=GRP_DASH)
string dashboardDetail = input.string("Compact", "Dashboard detail", options=["Compact", "Detailed"], group=GRP_DASH, tooltip="Compact keeps the Command Center narrow. Detailed shows fuller plain-English descriptions.")
bool showDesktopLowerDetails = input.bool(true, "Show lower details section", group=GRP_DASH, tooltip="Desktop only. When off, hides the LEVELS / OBJECTIVES / RULE / NEXT section below the possible-play rows to save chart space. All calculations continue normally in the background. Mobile layout is unchanged.")
int tableTransparency = input.int(0, "Table color transparency", minval=0, maxval=90, group=GRP_DASH)

//=============================================================================
// 6. DASHBOARD COLORS
//=============================================================================
string GRP_COLORS = "6. Dashboard Colors"
color bullInput = input.color(color.rgb(20, 125, 75), "Bull / long", group=GRP_COLORS)
color bearInput = input.color(color.rgb(175, 55, 55), "Bear / short", group=GRP_COLORS)
color neutralInput = input.color(color.rgb(85, 90, 100), "Neutral", group=GRP_COLORS)
color headerInput = input.color(color.rgb(28, 33, 43), "Header", group=GRP_COLORS)
color subheadInput = input.color(color.rgb(45, 52, 66), "Section header", group=GRP_COLORS)
color backgroundInput = input.color(color.rgb(24, 28, 36), "Body background", group=GRP_COLORS)
color textInput = input.color(color.white, "Main text", group=GRP_COLORS)
color mutedInput = input.color(color.rgb(205, 210, 220), "Muted text", group=GRP_COLORS)
color warningInput = input.color(color.rgb(185, 130, 35), "Warning / counter FTFC", group=GRP_COLORS)
color infoInput = input.color(color.rgb(45, 105, 165), "Information", group=GRP_COLORS)

color C_BULL = color.new(bullInput, tableTransparency)
color C_BEAR = color.new(bearInput, tableTransparency)
color C_NEUTRAL = color.new(neutralInput, tableTransparency)
color C_HEADER = color.new(headerInput, tableTransparency)
color C_SUBHEAD = color.new(subheadInput, tableTransparency)
color C_BG = color.new(backgroundInput, tableTransparency)
color C_TEXT = textInput
color C_MUTED = mutedInput
color C_WARN = color.new(warningInput, tableTransparency)
color C_INFO = color.new(infoInput, tableTransparency)

//=============================================================================
// HELPERS
//=============================================================================
f_barType(float h, float l, float ph, float pl) =>
    string t = "?"
    bool inside = h <= ph and l >= pl
    bool outside = h > ph and l < pl
    bool twoUp = h > ph and l >= pl
    bool twoDown = l < pl and h <= ph
    if inside
        t := "1"
    else if outside
        t := "3"
    else if twoUp
        t := "2U"
    else if twoDown
        t := "2D"
    t

f_typeMeaning(string t) =>
    string s = "Undefined"
    if t == "1"
        s := "Inside / compression"
    else if t == "2U"
        s := "Directional up"
    else if t == "2D"
        s := "Directional down"
    else if t == "3"
        s := "Outside / broadening"
    s

f_upPlay(string lastT, string prevT) =>
    string s = "UPSIDE BREAK"
    if lastT == "1"
        s := prevT + "-1-2U"
    else if lastT == "2D"
        s := "2-2U REVERSAL"
    else if lastT == "2U"
        s := "2U CONTINUATION"
    else if lastT == "3"
        s := "3 -> 2U RANGE BREAK"
    s

f_downPlay(string lastT, string prevT) =>
    string s = "DOWNSIDE BREAK"
    if lastT == "1"
        s := prevT + "-1-2D"
    else if lastT == "2U"
        s := "2-2D REVERSAL"
    else if lastT == "2D"
        s := "2D CONTINUATION"
    else if lastT == "3"
        s := "3 -> 2D RANGE BREAK"
    s

f_tfState(float o, float c) =>
    c > o ? 1 : c < o ? -1 : 0

f_stateShort(int s) =>
    s == 1 ? "GREEN" : s == -1 ? "RED" : "FLAT"

f_stateLetter(int s) =>
    s == 1 ? "G" : s == -1 ? "R" : "F"

f_mobileTfLabel(string tf) =>
    tf == "1M" ? "M" :
     tf == "1W" ? "W" :
     tf == "1D" ? "D" :
     tf == "240" ? "4H" :
     tf == "60" ? "1H" : tf

f_desktopFtfcLabel(string tf, bool required, int state) =>
    string shortTf = f_mobileTfLabel(tf)
    (required ? "REQ " : "") + shortTf + "\n" + f_stateShort(state)

f_reqMark(bool required) =>
    required ? "REQ " : ""

f_mobileReqTfLabel(string tf, bool required) =>
    string shortTf = f_mobileTfLabel(tf)
    required ? "[" + shortTf + "]" : shortTf

f_stateColor(int s) =>
    s == 1 ? C_BULL : s == -1 ? C_BEAR : C_NEUTRAL

f_price(float v) =>
    na(v) ? "--" : str.tostring(v, format.mintick)

f_ticks(float distance) =>
    na(distance) or syminfo.mintick <= 0 ? "--" : str.tostring(math.round(distance / syminfo.mintick)) + "t"

f_r(float r) =>
    na(r) ? "--" : str.tostring(r, "#.##") + "R"

f_position(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Top Right" ? position.top_right :
     p == "Middle Left" ? position.middle_left :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center : position.bottom_right

f_textSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "XL" ? size.huge : size.small

string candidateLabelSize = f_textSize(candidateLabelSizeChoice)
string activeLabelSize = f_textSize(activeLabelSizeChoice)
string failed2LabelSize = f_textSize(failed2LabelSizeChoice)
string structuredLabelSize = f_textSize(structuredLabelSizeChoice)
string structuredBfLabelSize = f_textSize(structuredBfLabelSizeChoice)
string structuredFvgLabelSize = f_textSize(structuredFvgLabelSizeChoice)
string structuredZoneLabelSize = f_textSize(structuredZoneLabelSizeChoice)

f_cell(table t, int c, int r, string txt, color bg, color fg, string sz) =>
    table.cell(t, c, r, txt, bgcolor=bg, text_color=fg, text_size=sz)

f_nearestAbove(float entry, float a, float b) =>
    float out = na
    if not na(a) and a > entry
        out := a
    if not na(b) and b > entry and (na(out) or b < out)
        out := b
    out

f_nearestBelow(float entry, float a, float b) =>
    float out = na
    if not na(a) and a < entry
        out := a
    if not na(b) and b < entry and (na(out) or b > out)
        out := b
    out

// Structured-objective helpers.
f_pickAbove(float ref, float best, float candidate) =>
    not na(candidate) and candidate > ref and (na(best) or candidate < best) ? candidate : best

f_pickBelow(float ref, float best, float candidate) =>
    not na(candidate) and candidate < ref and (na(best) or candidate > best) ? candidate : best

f_zoneTargetAbove(float ref, float a, float b) =>
    float zLo = math.min(a, b)
    float zHi = math.max(a, b)
    float out = na
    if not na(zLo) and not na(zHi)
        if ref < zLo
            out := zLo
        else if ref >= zLo and ref < zHi
            out := zHi
    out

f_zoneTargetBelow(float ref, float a, float b) =>
    float zLo = math.min(a, b)
    float zHi = math.max(a, b)
    float out = na
    if not na(zLo) and not na(zHi)
        if ref > zHi
            out := zHi
        else if ref > zLo and ref <= zHi
            out := zLo
    out

f_pivotHighOcc(simple int l, simple int r, simple int occ) =>
    float ph = ta.pivothigh(high, l, r)
    ta.valuewhen(not na(ph), ph, occ)

f_pivotLowOcc(simple int l, simple int r, simple int occ) =>
    float pl = ta.pivotlow(low, l, r)
    ta.valuewhen(not na(pl), pl, occ)

f_bullFvgLoOcc(simple int occ) =>
    bool cond = low[1] > high[3]
    ta.valuewhen(cond, high[3], occ)

f_bullFvgHiOcc(simple int occ) =>
    bool cond = low[1] > high[3]
    ta.valuewhen(cond, low[1], occ)

f_bearFvgLoOcc(simple int occ) =>
    bool cond = high[1] < low[3]
    ta.valuewhen(cond, high[1], occ)

f_bearFvgHiOcc(simple int occ) =>
    bool cond = high[1] < low[3]
    ta.valuewhen(cond, low[3], occ)

// Dynamic Strat broadening-formation detector.
//
// A literal one-candle 3 is only one way to broaden. Several confirmed candles
// can also form the same two-sided geometry: one later candle/sequence takes the
// reference candle high and another later candle/sequence takes its low.
//
// On the selected BF timeframe this function scans backward through COMPLETED
// candles only. For each possible reference candle, it asks whether the more-
// recent confirmed sequence has expanded BOTH above that candle's high and below
// that candle's low. The FIRST match is therefore the MOST RECENT defensible
// broadening formation.
//
// Once found, the active BF boundaries are the highest high / lowest low of that
// more-recent expanding sequence. As new confirmed candles extend either side,
// those boundaries can expand. If a newer reference candle later gets broadened
// on both sides, that newer composite BF automatically becomes the active one.
//
// spanBars = number of confirmed BF-timeframe candles that make up the expanding
// sequence after the reference candle. spanBars == 1 is a literal one-candle 3;
// spanBars > 1 is a multi-candle / composite 3.
f_activeCompositeBf(simple int maxSearch) =>
    float sequenceHigh = high[1]
    float sequenceLow = low[1]
    float outHigh = na
    float outLow = na
    int outSpanBars = na
    bool found = false

    if maxSearch >= 2 and not na(sequenceHigh) and not na(sequenceLow)
        for anchorOffset = 2 to maxSearch
            if not found
                float anchorHigh = high[anchorOffset]
                float anchorLow = low[anchorOffset]
                bool validAnchor = not na(anchorHigh) and not na(anchorLow)
                bool broadenedBothSides = validAnchor and sequenceHigh > anchorHigh and sequenceLow < anchorLow

                if broadenedBothSides
                    outHigh := sequenceHigh
                    outLow := sequenceLow
                    outSpanBars := anchorOffset - 1
                    found := true
                else
                    // For the next older candidate anchor, the just-tested bar
                    // becomes part of the more-recent expanding sequence.
                    sequenceHigh := na(anchorHigh) ? sequenceHigh : math.max(sequenceHigh, anchorHigh)
                    sequenceLow := na(anchorLow) ? sequenceLow : math.min(sequenceLow, anchorLow)

    [outHigh, outLow, open[1], close[1], outSpanBars]

//=============================================================================
// STRUCTURE ENGINE
// The last CLOSED candle is the setup candle. The developing candle is only
// evaluated against that actual setup candle.
//=============================================================================
string liveType = f_barType(high, low, high[1], low[1])
string lastType = f_barType(high[1], low[1], high[2], low[2])
string prevType = f_barType(high[2], low[2], high[3], low[3])

// Failed 2 recognition rules — exact closed-bar hierarchy.
// A Failed 2 must FINISH as a true 2, not as a 3/outside bar.
// Failed 2U: current candle is a true 2U (breaks prior high without also breaking prior low)
//            and closes below ITS OWN open (red).
// Failed 2D: current candle is a true 2D (breaks prior low without also breaking prior high)
//            and closes above ITS OWN open (green).
// If both sides of the prior candle are broken, final classification is 3 and 3 OVERRIDES Failed 2.
// No prior-candle color requirement is imposed.
bool failed2UConfirmed = barstate.isconfirmed and liveType == "2U" and close < open
bool failed2DConfirmed = barstate.isconfirmed and liveType == "2D" and close > open
bool lastFailed2U = lastType == "2U" and close[1] < open[1]
bool lastFailed2D = lastType == "2D" and close[1] > open[1]

float tickOffset = syminfo.mintick * triggerTicks
float oneTick = syminfo.mintick
float setupHigh = high[1]
float setupLow = low[1]
float setupMid = (setupHigh + setupLow) / 2.0
float upTrigger = setupHigh + tickOffset
float downTrigger = setupLow - tickOffset
float longInvalidation = setupLow - tickOffset
float shortInvalidation = setupHigh + tickOffset

// Failed 2 ENTRY levels remain an exact Strat rule and DO NOT inherit the
// configurable trigger offset used by other setups.
// Failed 2D -> LONG entry: exactly 1 tick above the Failed 2D high.
// Failed 2U -> SHORT entry: exactly 1 tick below the Failed 2U low.
float stratUpEntry = lastFailed2D ? setupHigh + oneTick : upTrigger
float stratDownEntry = lastFailed2U ? setupLow - oneTick : downTrigger

bool customEntryMode = entryMethod == "Custom price"
bool customLongMode = customEntryMode and customTradeDirection == "Long"
bool customShortMode = customEntryMode and customTradeDirection == "Short"
float effectiveUpEntry = customEntryMode ? (customLongMode ? customEntryPrice : na) : stratUpEntry
float effectiveDownEntry = customEntryMode ? (customShortMode ? customEntryPrice : na) : stratDownEntry

// Original structure stops remain available even with a custom entry. If a
// structure stop lands on the wrong side of a custom entry, validation blocks
// the trade rather than silently changing the user's instruction.
float structureUpStop = lastFailed2D ? setupLow - oneTick : longInvalidation
float structureDownStop = lastFailed2U ? setupHigh + oneTick : shortInvalidation
float customStopDistance = syminfo.mintick * customStopTicks
float effectiveUpStop = na(effectiveUpEntry) ? na : stopMethod == "Custom ticks" ? effectiveUpEntry - customStopDistance : stopMethod == "Custom price" ? customStopPrice : structureUpStop
float effectiveDownStop = na(effectiveDownEntry) ? na : stopMethod == "Custom ticks" ? effectiveDownEntry + customStopDistance : stopMethod == "Custom price" ? customStopPrice : structureDownStop

// Non-structured target preview. Structured-objective TP is resolved after the
// session + HTF objective engine is calculated below.
float customTargetDistance = syminfo.mintick * customTakeProfitTicks
float effectiveUpRisk = na(effectiveUpEntry) or na(effectiveUpStop) ? na : effectiveUpEntry - effectiveUpStop
float effectiveDownRisk = na(effectiveDownEntry) or na(effectiveDownStop) ? na : effectiveDownStop - effectiveDownEntry
float baseUpTarget = targetMethod == "Custom ticks" and not na(effectiveUpEntry) ? effectiveUpEntry + customTargetDistance : targetMethod == "Custom price" ? customTakeProfitPrice : targetMethod == "R multiple" and not na(effectiveUpRisk) ? effectiveUpEntry + effectiveUpRisk * targetR : na
float baseDownTarget = targetMethod == "Custom ticks" and not na(effectiveDownEntry) ? effectiveDownEntry - customTargetDistance : targetMethod == "Custom price" ? customTakeProfitPrice : targetMethod == "R multiple" and not na(effectiveDownRisk) ? effectiveDownEntry - effectiveDownRisk * targetR : na

// Exact custom-price levels are direction-sensitive.
bool upEntryConfigValid = not customEntryMode or (customLongMode and customEntryPrice > 0)
bool downEntryConfigValid = not customEntryMode or (customShortMode and customEntryPrice > 0)
bool upStopConfigValid = not na(effectiveUpEntry) and (stopMethod != "Custom price" or (customStopPrice > 0 and customStopPrice < effectiveUpEntry))
bool downStopConfigValid = not na(effectiveDownEntry) and (stopMethod != "Custom price" or (customStopPrice > effectiveDownEntry))
bool upTargetConfigValidBase = targetMethod == "Structured objective" or (not na(effectiveUpEntry) and (targetMethod != "Custom price" or customTakeProfitPrice > effectiveUpEntry))
bool downTargetConfigValidBase = targetMethod == "Structured objective" or (not na(effectiveDownEntry) and (targetMethod != "Custom price" or (customTakeProfitPrice > 0 and customTakeProfitPrice < effectiveDownEntry)))
bool baseUpTradeLevelsValid = upEntryConfigValid and upStopConfigValid and upTargetConfigValidBase and not na(effectiveUpRisk) and effectiveUpRisk > 0
bool baseDownTradeLevelsValid = downEntryConfigValid and downStopConfigValid and downTargetConfigValidBase and not na(effectiveDownRisk) and effectiveDownRisk > 0

bool upTouched = not na(effectiveUpEntry) and high >= effectiveUpEntry
bool downTouched = not na(effectiveDownEntry) and low <= effectiveDownEntry
bool bothTouched = upTouched and downTouched
bool upOnly = upTouched and not downTouched
bool downOnly = downTouched and not upTouched

string upPlay = customLongMode ? "CUSTOM LONG" : lastFailed2D ? "FAILED 2D -> 2U REVERSAL" : f_upPlay(lastType, prevType)
string downPlay = customShortMode ? "CUSTOM SHORT" : lastFailed2U ? "FAILED 2U -> 2D REVERSAL" : f_downPlay(lastType, prevType)

// Pattern identity is structural, not clock-based. A 2-1-2 style setup includes
// the prior directional bar plus the inside bar; one-bar setup candles (2, 3,
// Failed 2) use the setup candle itself as the root. The identity remains stable
// while that exact pattern is being monitored and changes only when a distinct
// confirmed Strat pattern becomes the current setup.
int currentPatternStartBar = lastType == "1" ? bar_index - 2 : bar_index - 1
int currentPatternSetupBar = bar_index - 1
string currentPatternKey = str.tostring(currentPatternStartBar) + "|" + str.tostring(currentPatternSetupBar) + "|" + upPlay + "|" + downPlay

//=============================================================================
// FTFC - LIVE CONTEXT
//=============================================================================
[o1, c1] = request.security(syminfo.tickerid, tf1, [open, close])
[o2, c2] = request.security(syminfo.tickerid, tf2, [open, close])
[o3, c3] = request.security(syminfo.tickerid, tf3, [open, close])
[o4, c4] = request.security(syminfo.tickerid, tf4, [open, close])
[o5, c5] = request.security(syminfo.tickerid, tf5, [open, close])
[o6, c6] = request.security(syminfo.tickerid, tf6, [open, close])

// v2.2.1.1: Monthly FTFC uses this month's fixed open versus price now.
// Only OPEN is requested with lookahead_on: it is known at the month start.
// Never request the unfinished monthly CLOSE with lookahead_on (future leak).
// On charts above 1M, preserve the existing lower-timeframe sampling behavior.
float ftfcMonthOpen = request.security(syminfo.tickerid, "1M", open, lookahead=barmerge.lookahead_on)
bool ftfcMonthOnChart = timeframe.in_seconds() <= timeframe.in_seconds("1M")
int s1 = (tf1 == "1M" or tf1 == "M") and ftfcMonthOnChart ? f_tfState(ftfcMonthOpen, close) : f_tfState(o1, c1)
int s2 = (tf2 == "1M" or tf2 == "M") and ftfcMonthOnChart ? f_tfState(ftfcMonthOpen, close) : f_tfState(o2, c2)
int s3 = (tf3 == "1M" or tf3 == "M") and ftfcMonthOnChart ? f_tfState(ftfcMonthOpen, close) : f_tfState(o3, c3)
int s4 = (tf4 == "1M" or tf4 == "M") and ftfcMonthOnChart ? f_tfState(ftfcMonthOpen, close) : f_tfState(o4, c4)
int s5 = (tf5 == "1M" or tf5 == "M") and ftfcMonthOnChart ? f_tfState(ftfcMonthOpen, close) : f_tfState(o5, c5)
int s6 = (tf6 == "1M" or tf6 == "M") and ftfcMonthOnChart ? f_tfState(ftfcMonthOpen, close) : f_tfState(o6, c6)

// All six monitored timeframes remain visible as context. Full Time Frame
// Continuity, however, is determined ONLY by the timeframes the user checks
// as Required. Every required timeframe must agree; majority/lean is not FTFC.
int bullCount = (s1 == 1 ? 1 : 0) + (s2 == 1 ? 1 : 0) + (s3 == 1 ? 1 : 0) + (s4 == 1 ? 1 : 0) + (s5 == 1 ? 1 : 0) + (s6 == 1 ? 1 : 0)
int bearCount = (s1 == -1 ? 1 : 0) + (s2 == -1 ? 1 : 0) + (s3 == -1 ? 1 : 0) + (s4 == -1 ? 1 : 0) + (s5 == -1 ? 1 : 0) + (s6 == -1 ? 1 : 0)

int requiredCount = (reqTf1 ? 1 : 0) + (reqTf2 ? 1 : 0) + (reqTf3 ? 1 : 0) + (reqTf4 ? 1 : 0) + (reqTf5 ? 1 : 0) + (reqTf6 ? 1 : 0)
int requiredBullCount = (reqTf1 and s1 == 1 ? 1 : 0) + (reqTf2 and s2 == 1 ? 1 : 0) + (reqTf3 and s3 == 1 ? 1 : 0) + (reqTf4 and s4 == 1 ? 1 : 0) + (reqTf5 and s5 == 1 ? 1 : 0) + (reqTf6 and s6 == 1 ? 1 : 0)
int requiredBearCount = (reqTf1 and s1 == -1 ? 1 : 0) + (reqTf2 and s2 == -1 ? 1 : 0) + (reqTf3 and s3 == -1 ? 1 : 0) + (reqTf4 and s4 == -1 ? 1 : 0) + (reqTf5 and s5 == -1 ? 1 : 0) + (reqTf6 and s6 == -1 ? 1 : 0)
int requiredFlatCount = requiredCount - requiredBullCount - requiredBearCount

bool ftfcConfigured = requiredCount > 0
bool bullFTFCAligned = ftfcConfigured and requiredBullCount == requiredCount
bool bearFTFCAligned = ftfcConfigured and requiredBearCount == requiredCount
// The enforcement checkbox has NO authority until at least one HTF is marked REQ.
// Zero REQ timeframes = normal structural suggestions; FTFC is simply informationally unconfigured.
bool ftfcFilterActive = onlySuggestWithFTFC and ftfcConfigured

// FTFC is binary with respect to the user-selected REQ timeframes.
// There is no majority, lean, or partial-continuity state: every required
// timeframe must agree in one direction or FTFC is simply mixed/not full.
string ftfcBias = "NO REQUIRED HTFs"
string ftfcStatusShort = "NO REQUIRED HTFs"
color ftfcColor = C_NEUTRAL
if bullFTFCAligned
    ftfcBias := "FULL BULL FTFC"
    ftfcStatusShort := "FULL BULL FTFC"
    ftfcColor := C_BULL
else if bearFTFCAligned
    ftfcBias := "FULL BEAR FTFC"
    ftfcStatusShort := "FULL BEAR FTFC"
    ftfcColor := C_BEAR
else if ftfcConfigured
    ftfcBias := "NOT FULL FTFC - MIXED"
    ftfcStatusShort := "NOT FULL FTFC - MIXED"
    ftfcColor := C_WARN

string bestStructuralPlay = ftfcConfigured ? "WAIT - NO FULL FTFC | STRUCTURE ONLY" : "STRUCTURE ONLY | FTFC NOT CONFIGURED"
color bestStructuralColor = C_NEUTRAL
if bullFTFCAligned
    bestStructuralPlay := upPlay + " | FULL FTFC"
    bestStructuralColor := C_BULL
else if bearFTFCAligned
    bestStructuralPlay := downPlay + " | FULL FTFC"
    bestStructuralColor := C_BEAR

string reversalAvailable = "NONE - CURRENT SETUP IS NOT A 2-2 REVERSAL"
color reversalColor = C_NEUTRAL
if lastFailed2D
    reversalAvailable := "FAILED 2D - REVERSAL ABOVE " + f_price(effectiveUpEntry)
    reversalColor := bullFTFCAligned ? C_BULL : C_WARN
else if lastFailed2U
    reversalAvailable := "FAILED 2U - REVERSAL BELOW " + f_price(effectiveDownEntry)
    reversalColor := bearFTFCAligned ? C_BEAR : C_WARN
else if lastType == "2D"
    reversalAvailable := "2-2U REVERSAL ABOVE " + f_price(upTrigger)
    reversalColor := bullFTFCAligned ? C_BULL : C_WARN
else if lastType == "2U"
    reversalAvailable := "2-2D REVERSAL BELOW " + f_price(downTrigger)
    reversalColor := bearFTFCAligned ? C_BEAR : C_WARN
else if lastType == "1"
    reversalAvailable := "1 BAR - BREAK DECIDES THE NEXT 2"
else if lastType == "3"
    reversalAvailable := "3 BAR - WAIT FOR DIRECTIONAL RESOLUTION"

//=============================================================================
// REFERENCE SESSION / OBJECTIVES
// Futures: 6:00 PM ET -> 5:00 PM ET.
// Equities / indexes / other non-futures: 9:30 AM ET -> 4:00 PM ET.
// This intentionally does NOT use TradingView's generic 1D open, so the
// Command Center's session anchor matches the user's trading-day definition.
//=============================================================================
bool futuresSession = syminfo.type == "futures"
string referenceSession = futuresSession ? "1800-1700:23456" : "0930-1600:23456"
string referenceSessionLabel = futuresSession ? "6PM ET" : "9:30 ET"
int referenceOpenHour = futuresSession ? 18 : 9
int referenceOpenMinute = futuresSession ? 0 : 30
bool inReferenceSession = timeframe.isintraday and not na(time(timeframe.period, referenceSession, "America/New_York"))
bool referenceOpenBar = inReferenceSession and hour(time, "America/New_York") == referenceOpenHour and minute(time, "America/New_York") == referenceOpenMinute

var float dayOpen = na
var float currentSessionHigh = na
var float currentSessionLow = na
var float pdh = na
var float pdl = na

if referenceOpenBar
    if not na(currentSessionHigh)
        pdh := currentSessionHigh
        pdl := currentSessionLow
    dayOpen := open
    currentSessionHigh := high
    currentSessionLow := low
else if inReferenceSession
    // Normal historical processing reaches the actual session-open bar first.
    // This fallback keeps the display usable if history begins mid-session.
    if na(dayOpen)
        dayOpen := open
        currentSessionHigh := high
        currentSessionLow := low
    else
        currentSessionHigh := na(currentSessionHigh) ? high : math.max(currentSessionHigh, high)
        currentSessionLow := na(currentSessionLow) ? low : math.min(currentSessionLow, low)

//=============================================================================
// STRUCTURED OBJECTIVE ENGINE
//=============================================================================
[soO, soH, soL, soC, swH0, swH1, swH2, swH3, swL0, swL1, swL2, swL3, bfl0, bfh0, bfl1, bfh1, bfl2, bfh2, bel0, beh0, bel1, beh1, bel2, beh2] = request.security(
     syminfo.tickerid, targetHTF,
     [open, high, low, close,
      f_pivotHighOcc(swingLeft, swingRight, 0), f_pivotHighOcc(swingLeft, swingRight, 1), f_pivotHighOcc(swingLeft, swingRight, 2), f_pivotHighOcc(swingLeft, swingRight, 3),
      f_pivotLowOcc(swingLeft, swingRight, 0), f_pivotLowOcc(swingLeft, swingRight, 1), f_pivotLowOcc(swingLeft, swingRight, 2), f_pivotLowOcc(swingLeft, swingRight, 3),
      f_bullFvgLoOcc(0), f_bullFvgHiOcc(0), f_bullFvgLoOcc(1), f_bullFvgHiOcc(1), f_bullFvgLoOcc(2), f_bullFvgHiOcc(2),
      f_bearFvgLoOcc(0), f_bearFvgHiOcc(0), f_bearFvgLoOcc(1), f_bearFvgHiOcc(1), f_bearFvgLoOcc(2), f_bearFvgHiOcc(2)],
     barmerge.gaps_off, barmerge.lookahead_off)

// Active Strat Broadening Formation structure.
//
// This is now DYNAMIC and Strat-native rather than "highest/lowest in N bars."
// The selected HTF may create broadening in either of two ways:
//   1) one literal 3 candle takes both sides of its prior candle, or
//   2) several confirmed candles, taken together, take both sides of a prior
//      confirmed reference candle (a composite / multi-candle 3).
//
// bfLookback is only the MAXIMUM backward search depth. The active BF itself is
// the MOST RECENT confirmed two-sided expansion found within that search depth.
// Individual candles keep their true 1 / 2U / 2D / 3 classifications.
[bfHigh, bfLow, bfLastOpen, bfLastClose, bfSpanBars] = request.security(
     syminfo.tickerid, bfTargetHTF,
     f_activeCompositeBf(bfLookback),
     barmerge.gaps_off, barmerge.lookahead_on)
float bfMid = not na(bfHigh) and not na(bfLow) ? math.avg(bfHigh, bfLow) : na
string bfStructureType = na(bfSpanBars) ? "NO ACTIVE BF" : bfSpanBars == 1 ? "1-BAR 3" : "COMPOSITE 3 " + str.tostring(bfSpanBars) + "B"
float bfTargetUp = not na(effectiveUpEntry) and not na(bfHigh) and bfHigh > effectiveUpEntry ? bfHigh : na
float bfTargetDown = not na(effectiveDownEntry) and not na(bfLow) and bfLow < effectiveDownEntry ? bfLow : na
float bfMidTargetUp = not na(effectiveUpEntry) and not na(bfMid) and bfMid > effectiveUpEntry ? bfMid : na
float bfMidTargetDown = not na(effectiveDownEntry) and not na(bfMid) and bfMid < effectiveDownEntry ? bfMid : na

// Historical selected-HTF FVG lifecycle engine.
// The script walks chart history one bar at a time. On the first chart bar of
// each new target-HTF period, the just-closed HTF candle can complete a new
// three-candle FVG. Every active gap is then monitored against actual price and
// retired according to the user's mitigation rule.
[closedHtfTime, closedHtfOpen, closedHtfHigh, closedHtfLow, closedHtfClose, bullFvgCandidateLo, bullFvgCandidateHi, bearFvgCandidateLo, bearFvgCandidateHi] = request.security(
     syminfo.tickerid, targetHTF,
     [time[1], open[1], high[1], low[1], close[1], high[3], low[1], high[1], low[3]],
     barmerge.gaps_off, barmerge.lookahead_on)

// FVG state is TARGETING CONTEXT ONLY. It never creates, filters or validates
// a Strat setup. States are evaluated only from CONFIRMED candles on the user-
// selected Target HTF so a lower-timeframe wick cannot invent HTF respect.
// 0 = UNTESTED
// 1 = RESPECTED, awaiting same-direction follow-through FVG
// 2 = RESPECTED + NEW FVG confirmation
// 3 = WEAKNESS (respected, but no new same-direction FVG in user window)
// 4 = DISRESPECTED
var array<float> activeFvgLo = array.new_float()
var array<float> activeFvgHi = array.new_float()
var array<int> activeFvgDir = array.new_int()   // +1 = bullish FVG, -1 = bearish FVG
var array<int> activeFvgBorn = array.new_int()  // HTF formation candle time
var array<int> activeFvgState = array.new_int()
var array<int> activeFvgRespectAge = array.new_int()

bool newTargetHtfBar = timeframe.change(targetHTF)
bool newBullFvg = newTargetHtfBar and not na(closedHtfTime) and not na(bullFvgCandidateLo) and not na(bullFvgCandidateHi) and bullFvgCandidateHi > bullFvgCandidateLo
bool newBearFvg = newTargetHtfBar and not na(closedHtfTime) and not na(bearFvgCandidateLo) and not na(bearFvgCandidateHi) and bearFvgCandidateHi > bearFvgCandidateLo

// First update the state of FVGs that already existed before the just-closed
// Target-HTF candle. Respect = wick/penetration into the FVG followed by a
// confirmed body close back OUT of the FVG in the expected direction.
// Disrespect = a confirmed body close inside/through the FVG.
if newTargetHtfBar and array.size(activeFvgLo) > 0
    for stateIdx = 0 to array.size(activeFvgLo) - 1
        float stateLo = array.get(activeFvgLo, stateIdx)
        float stateHi = array.get(activeFvgHi, stateIdx)
        int stateDir = array.get(activeFvgDir, stateIdx)
        int stateBorn = array.get(activeFvgBorn, stateIdx)
        int stateCode = array.get(activeFvgState, stateIdx)
        int stateAge = array.get(activeFvgRespectAge, stateIdx)
        bool existedBeforeClosedBar = not na(closedHtfTime) and closedHtfTime > stateBorn
        bool touchedThisHtfBar = existedBeforeClosedBar and closedHtfHigh >= stateLo and closedHtfLow <= stateHi
        bool respectedThisHtfBar = touchedThisHtfBar and (stateDir == 1 ? closedHtfClose > stateHi : closedHtfClose < stateLo)
        bool disrespectedThisHtfBar = touchedThisHtfBar and (stateDir == 1 ? closedHtfClose <= stateHi : closedHtfClose >= stateLo)
        bool sameDirectionFvgCreated = stateDir == 1 ? newBullFvg : newBearFvg

        if disrespectedThisHtfBar
            stateCode := 4
            stateAge := -1
        else if stateCode == 0 and respectedThisHtfBar
            if sameDirectionFvgCreated
                stateCode := 2
                stateAge := -1
            else
                stateCode := 1
                stateAge := 0
        else if stateCode == 1
            if sameDirectionFvgCreated
                stateCode := 2
                stateAge := -1
            else
                stateAge += 1
                if stateAge >= fvgFollowThroughBars
                    stateCode := 3
                    stateAge := -1

        array.set(activeFvgState, stateIdx, stateCode)
        array.set(activeFvgRespectAge, stateIdx, stateAge)

// Add newly completed FVGs only after existing FVG states have been evaluated,
// so a newly born gap cannot test or confirm itself on its own formation candle.
if newBullFvg
    array.push(activeFvgLo, bullFvgCandidateLo)
    array.push(activeFvgHi, bullFvgCandidateHi)
    array.push(activeFvgDir, 1)
    array.push(activeFvgBorn, closedHtfTime)
    array.push(activeFvgState, 0)
    array.push(activeFvgRespectAge, -1)
if newBearFvg
    array.push(activeFvgLo, bearFvgCandidateLo)
    array.push(activeFvgHi, bearFvgCandidateHi)
    array.push(activeFvgDir, -1)
    array.push(activeFvgBorn, closedHtfTime)
    array.push(activeFvgState, 0)
    array.push(activeFvgRespectAge, -1)

// Keep ample internal history while protecting Pine resources. The user can
// display at most 10 per side, but older active gaps are retained so they can
// become visible if a newer gap is mitigated.
while array.size(activeFvgLo) > 80
    array.shift(activeFvgLo)
    array.shift(activeFvgHi)
    array.shift(activeFvgDir)
    array.shift(activeFvgBorn)
    array.shift(activeFvgState)
    array.shift(activeFvgRespectAge)

// Retire mitigated gaps. Bullish gaps are approached from above; bearish gaps
// are approached from below. The rule is evaluated on real chart highs/lows,
// so a touch is recognized as soon as price actually reaches the threshold.
int fvgMitIdx = array.size(activeFvgLo) - 1
while fvgMitIdx >= 0
    float gapLo = array.get(activeFvgLo, fvgMitIdx)
    float gapHi = array.get(activeFvgHi, fvgMitIdx)
    int gapDir = array.get(activeFvgDir, fvgMitIdx)
    float gapMid = (gapLo + gapHi) / 2.0
    float mitigationLevel = gapDir == 1 ? (fvgMitigationRule == "First touch" ? gapHi : fvgMitigationRule == "50% fill" ? gapMid : gapLo) : (fvgMitigationRule == "First touch" ? gapLo : fvgMitigationRule == "50% fill" ? gapMid : gapHi)
    bool gapMitigated = gapDir == 1 ? low <= mitigationLevel : high >= mitigationLevel
    if gapMitigated
        array.remove(activeFvgLo, fvgMitIdx)
        array.remove(activeFvgHi, fvgMitIdx)
        array.remove(activeFvgDir, fvgMitIdx)
        array.remove(activeFvgBorn, fvgMitIdx)
        array.remove(activeFvgState, fvgMitIdx)
        array.remove(activeFvgRespectAge, fvgMitIdx)
    fvgMitIdx -= 1

// Nearest confirmed swing high above / swing low below each potential entry.
float nearestSwingUp = na
nearestSwingUp := f_pickAbove(effectiveUpEntry, nearestSwingUp, swH0)
nearestSwingUp := f_pickAbove(effectiveUpEntry, nearestSwingUp, swH1)
nearestSwingUp := f_pickAbove(effectiveUpEntry, nearestSwingUp, swH2)
nearestSwingUp := f_pickAbove(effectiveUpEntry, nearestSwingUp, swH3)
float nearestSwingDown = na
nearestSwingDown := f_pickBelow(effectiveDownEntry, nearestSwingDown, swL0)
nearestSwingDown := f_pickBelow(effectiveDownEntry, nearestSwingDown, swL1)
nearestSwingDown := f_pickBelow(effectiveDownEntry, nearestSwingDown, swL2)
nearestSwingDown := f_pickBelow(effectiveDownEntry, nearestSwingDown, swL3)

// Still-unmitigated selected-HTF FVGs. For a trade target, the near edge is
// used when entry is outside the zone; if entry is already inside, the far edge
// becomes the next objective. DISRESPECTED FVGs remain visible as context, but
// are intentionally SKIPPED by structured-target selection so the engine looks
// through them to the next eligible FVG/swing objective beyond. WEAKNESS remains
// target-eligible because it is cautionary context, not confirmed disrespect.
float nearestFvgUp = na
string nearestFvgUpSource = ""
float nearestFvgUpLo = na
float nearestFvgUpHi = na
float nearestFvgDown = na
string nearestFvgDownSource = ""
float nearestFvgDownLo = na
float nearestFvgDownHi = na
int activeBullFvgCount = 0
int activeBearFvgCount = 0

if array.size(activeFvgLo) > 0
    for fvgIdx = 0 to array.size(activeFvgLo) - 1
        float gapLo = array.get(activeFvgLo, fvgIdx)
        float gapHi = array.get(activeFvgHi, fvgIdx)
        int gapDir = array.get(activeFvgDir, fvgIdx)
        int gapState = array.get(activeFvgState, fvgIdx)
        string gapSource = gapDir == 1 ? "BULL FVG" : "BEAR FVG"
        activeBullFvgCount += gapDir == 1 ? 1 : 0
        activeBearFvgCount += gapDir == -1 ? 1 : 0

        bool eligibleAsTarget = gapState != 4
        if eligibleAsTarget
            float upCandidate = f_zoneTargetAbove(effectiveUpEntry, gapLo, gapHi)
            if not na(upCandidate) and (na(nearestFvgUp) or upCandidate < nearestFvgUp)
                nearestFvgUp := upCandidate
                nearestFvgUpSource := gapSource
                nearestFvgUpLo := gapLo
                nearestFvgUpHi := gapHi

            float downCandidate = f_zoneTargetBelow(effectiveDownEntry, gapLo, gapHi)
            if not na(downCandidate) and (na(nearestFvgDown) or downCandidate > nearestFvgDown)
                nearestFvgDown := downCandidate
                nearestFvgDownSource := gapSource
                nearestFvgDownLo := gapLo
                nearestFvgDownHi := gapHi

// User's BF 50/70 reaction area. The zone is measured inside the ACTIVE
// Broadening Formation range, using the direction of the last confirmed candle
// on the selected BF timeframe. This matches the established 4H BF 50/70 method.
float bfRange = not na(bfHigh) and not na(bfLow) ? bfHigh - bfLow : na
bool bfBullBias = not na(bfLastOpen) and not na(bfLastClose) ? bfLastClose >= bfLastOpen : true
float fibA = na
float fibB = na
if not na(bfRange) and bfRange > syminfo.mintick
    if bfBullBias
        fibA := bfHigh - bfRange * fibLevel1Pct / 100.0
        fibB := bfHigh - bfRange * fibLevel2Pct / 100.0
    else
        fibA := bfLow + bfRange * fibLevel1Pct / 100.0
        fibB := bfLow + bfRange * fibLevel2Pct / 100.0
float structuredZoneBot = math.min(fibA, fibB)
float structuredZoneTop = math.max(fibA, fibB)
float zoneTargetUp = f_zoneTargetAbove(effectiveUpEntry, structuredZoneBot, structuredZoneTop)
float zoneTargetDown = f_zoneTargetBelow(effectiveDownEntry, structuredZoneBot, structuredZoneTop)

float pdTargetUp = not na(effectiveUpEntry) and not na(pdh) and pdh > effectiveUpEntry ? pdh : na
float pdTargetDown = not na(effectiveDownEntry) and not na(pdl) and pdl < effectiveDownEntry ? pdl : na

// Resolve a target and its source.
// TheStrat remains the center of gravity: BF High/Low are first-class structural
// objectives. FVG/swing/PDH/PDL/50-70 remain target/context choices only.
float structuredUpTarget = na
string structuredUpSource = ""
float structuredDownTarget = na
string structuredDownSource = ""

if enableStructuredObjectives
    if structuredTargetSelection == "BF High / Low"
        if enableBfObjectives
            structuredUpTarget := bfTargetUp
            structuredUpSource := not na(bfTargetUp) ? "BF HIGH" : ""
            structuredDownTarget := bfTargetDown
            structuredDownSource := not na(bfTargetDown) ? "BF LOW" : ""
    else if structuredTargetSelection == "BF Midpoint"
        if enableBfObjectives
            structuredUpTarget := bfMidTargetUp
            structuredUpSource := not na(bfMidTargetUp) ? "BF MID" : ""
            structuredDownTarget := bfMidTargetDown
            structuredDownSource := not na(bfMidTargetDown) ? "BF MID" : ""
    else if structuredTargetSelection == "Swing H/L"
        structuredUpTarget := nearestSwingUp
        structuredUpSource := not na(nearestSwingUp) ? "SWING HIGH" : ""
        structuredDownTarget := nearestSwingDown
        structuredDownSource := not na(nearestSwingDown) ? "SWING LOW" : ""
    else if structuredTargetSelection == "Fair Value Gap"
        if enableFvgObjectives
            structuredUpTarget := nearestFvgUp
            structuredUpSource := not na(nearestFvgUp) ? "FVG OBJECTIVE" : ""
            structuredDownTarget := nearestFvgDown
            structuredDownSource := not na(nearestFvgDown) ? "FVG OBJECTIVE" : ""
    else if structuredTargetSelection == "PDH / PDL"
        structuredUpTarget := pdTargetUp
        structuredUpSource := not na(pdTargetUp) ? "PDH" : ""
        structuredDownTarget := pdTargetDown
        structuredDownSource := not na(pdTargetDown) ? "PDL" : ""
    else if structuredTargetSelection == "BF 50/70 zone"
        if enableBfObjectives
            structuredUpTarget := zoneTargetUp
            structuredUpSource := not na(zoneTargetUp) ? "BF 50/70" : ""
            structuredDownTarget := zoneTargetDown
            structuredDownSource := not na(zoneTargetDown) ? "BF 50/70" : ""
    else if structuredTargetSelection == "Nearest Strat objective (BF/Swing/FVG)"
        if enableBfObjectives and useStructuredBF and not na(bfTargetUp)
            structuredUpTarget := bfTargetUp
            structuredUpSource := "BF HIGH"
        if useStructuredSwing and not na(nearestSwingUp) and (na(structuredUpTarget) or nearestSwingUp < structuredUpTarget)
            structuredUpTarget := nearestSwingUp
            structuredUpSource := "SWING HIGH"
        if enableFvgObjectives and useStructuredFVG and not na(nearestFvgUp) and (na(structuredUpTarget) or nearestFvgUp < structuredUpTarget)
            structuredUpTarget := nearestFvgUp
            structuredUpSource := "FVG OBJECTIVE"

        if enableBfObjectives and useStructuredBF and not na(bfTargetDown)
            structuredDownTarget := bfTargetDown
            structuredDownSource := "BF LOW"
        if useStructuredSwing and not na(nearestSwingDown) and (na(structuredDownTarget) or nearestSwingDown > structuredDownTarget)
            structuredDownTarget := nearestSwingDown
            structuredDownSource := "SWING LOW"
        if enableFvgObjectives and useStructuredFVG and not na(nearestFvgDown) and (na(structuredDownTarget) or nearestFvgDown > structuredDownTarget)
            structuredDownTarget := nearestFvgDown
            structuredDownSource := "FVG OBJECTIVE"
    else
        if enableBfObjectives and useStructuredBF and not na(bfTargetUp)
            structuredUpTarget := bfTargetUp
            structuredUpSource := "BF HIGH"
        if enableBfObjectives and useStructuredBFMid and not na(bfMidTargetUp) and (na(structuredUpTarget) or bfMidTargetUp < structuredUpTarget)
            structuredUpTarget := bfMidTargetUp
            structuredUpSource := "BF MID"
        if useStructuredSwing and not na(nearestSwingUp) and (na(structuredUpTarget) or nearestSwingUp < structuredUpTarget)
            structuredUpTarget := nearestSwingUp
            structuredUpSource := "SWING HIGH"
        if enableFvgObjectives and useStructuredFVG and not na(nearestFvgUp) and (na(structuredUpTarget) or nearestFvgUp < structuredUpTarget)
            structuredUpTarget := nearestFvgUp
            structuredUpSource := "FVG OBJECTIVE"
        if useStructuredPD and not na(pdTargetUp) and (na(structuredUpTarget) or pdTargetUp < structuredUpTarget)
            structuredUpTarget := pdTargetUp
            structuredUpSource := "PDH"
        if enableBfObjectives and useStructured5070 and not na(zoneTargetUp) and (na(structuredUpTarget) or zoneTargetUp < structuredUpTarget)
            structuredUpTarget := zoneTargetUp
            structuredUpSource := "BF 50/70"

        if enableBfObjectives and useStructuredBF and not na(bfTargetDown)
            structuredDownTarget := bfTargetDown
            structuredDownSource := "BF LOW"
        if enableBfObjectives and useStructuredBFMid and not na(bfMidTargetDown) and (na(structuredDownTarget) or bfMidTargetDown > structuredDownTarget)
            structuredDownTarget := bfMidTargetDown
            structuredDownSource := "BF MID"
        if useStructuredSwing and not na(nearestSwingDown) and (na(structuredDownTarget) or nearestSwingDown > structuredDownTarget)
            structuredDownTarget := nearestSwingDown
            structuredDownSource := "SWING LOW"
        if enableFvgObjectives and useStructuredFVG and not na(nearestFvgDown) and (na(structuredDownTarget) or nearestFvgDown > structuredDownTarget)
            structuredDownTarget := nearestFvgDown
            structuredDownSource := "FVG OBJECTIVE"
        if useStructuredPD and not na(pdTargetDown) and (na(structuredDownTarget) or pdTargetDown > structuredDownTarget)
            structuredDownTarget := pdTargetDown
            structuredDownSource := "PDL"
        if enableBfObjectives and useStructured5070 and not na(zoneTargetDown) and (na(structuredDownTarget) or zoneTargetDown > structuredDownTarget)
            structuredDownTarget := zoneTargetDown
            structuredDownSource := "BF 50/70"

float effectiveUpTarget = targetMethod == "Structured objective" ? structuredUpTarget : baseUpTarget
float effectiveDownTarget = targetMethod == "Structured objective" ? structuredDownTarget : baseDownTarget
bool upTradeLevelsValid = baseUpTradeLevelsValid and (targetMethod != "Structured objective" or (enableStructuredObjectives and not na(structuredUpTarget) and structuredUpTarget > effectiveUpEntry))
bool downTradeLevelsValid = baseDownTradeLevelsValid and (targetMethod != "Structured objective" or (enableStructuredObjectives and not na(structuredDownTarget) and structuredDownTarget < effectiveDownEntry))

// Custom trades are user-constructed and are not blocked by FTFC. Strat trades
// continue to obey the optional REQ-timeframe enforcement filter.
bool upSuggestionEligible = customEntryMode ? (customLongMode and upTradeLevelsValid) : (not ftfcFilterActive or bullFTFCAligned) and upTradeLevelsValid
bool downSuggestionEligible = customEntryMode ? (customShortMode and downTradeLevelsValid) : (not ftfcFilterActive or bearFTFCAligned) and downTradeLevelsValid

float recentHigh = ta.highest(high[2], targetLookback)
float recentLow = ta.lowest(low[2], targetLookback)
float upObjective = f_nearestAbove(effectiveUpEntry, pdh, recentHigh)
float downObjective = f_nearestBelow(effectiveDownEntry, pdl, recentLow)
string upRoom = na(upObjective) ? "--" : f_price(upObjective) + " / " + f_ticks(upObjective - effectiveUpEntry)
string downRoom = na(downObjective) ? "--" : f_price(downObjective) + " / " + f_ticks(effectiveDownEntry - downObjective)
string priceVsDayOpen = na(dayOpen) ? "SESSION OPEN --" : close > dayOpen ? "ABOVE " + referenceSessionLabel + " OPEN" : close < dayOpen ? "BELOW " + referenceSessionLabel + " OPEN" : "AT " + referenceSessionLabel + " OPEN"
color priceVsDayOpenColor = na(dayOpen) ? C_NEUTRAL : close > dayOpen ? C_BULL : close < dayOpen ? C_BEAR : C_NEUTRAL

//=============================================================================
// SHORT-LINE TRADE STATE MACHINE
// Candidate lines are short stubs. Once one direction triggers, the opposite
// candidate disappears and Entry / Stop / TP remain only while the trade is
// active. The instant TP or Stop is reached, ALL trade lines are deleted.
//=============================================================================
var bool tradeActive = false
var int tradeDir = 0                 // 1 long, -1 short
var int activeEntryBar = na
var int activeSetupBar = na
var float activeSetupHigh = na
var float activeSetupLow = na
var float activeEntry = na
var float activeStop = na
var float activeTarget = na
var string activePlay = ""
var string activeTargetSource = ""
var bool activeIsCustom = false
var string activeCustomKey = ""
var string lastCompletedCustomKey = ""
var int lastResolvedBar = na
var string lastResult = ""

// Closed-trade ledger. On any settings change Pine deterministically rebuilds
// these buckets from chart history using the CURRENT settings.
var int closedTradeCount = 0
var int targetExitCount = 0
var int stopExitCount = 0
var int timeExitCount = 0
var int timeWinCount = 0
var int timeLossCount = 0
var int timeFlatCount = 0
var int ambiguousExitCount = 0
var float cumulativeClosedR = 0.0
var int closedRCount = 0
var float cumulativeTimeR = 0.0
var int timeRCount = 0
var float lastClosedEntry = na
var float lastClosedExit = na
var float lastClosedR = na
var int lastClosedBars = na
var int lastClosedDir = 0
var string lastClosedReason = ""
var string lastClosedPlay = ""

// Rolling deterministic trade log for later bucketing/research. Counts above
// remain all-history; the detailed log keeps the most recent 1000 closures.
var array<float> tradeLogEntry = array.new_float()
var array<float> tradeLogExit = array.new_float()
var array<float> tradeLogR = array.new_float()
var array<int> tradeLogBars = array.new_int()
var array<int> tradeLogDir = array.new_int()
var array<string> tradeLogReason = array.new_string()
var array<string> tradeLogPlay = array.new_string()

var int candidateSetupBar = na
var string candidatePatternKey = ""
var float candidateUpEntry = na
var float candidateDownEntry = na
var float candidateLongStop = na
var float candidateShortStop = na
var float candidateUpTarget = na
var float candidateDownTarget = na
var string candidateUpTargetSource = ""
var string candidateDownTargetSource = ""
var string candidateUpPlay = ""
var string candidateDownPlay = ""

var line candidateUpLine = na
var line candidateDownLine = na
var label candidateUpLabel = na
var label candidateDownLabel = na
var line activeEntryLine = na
var line activeStopLine = na
var line activeTargetLine = na
var label activeEntryLabel = na
var label activeStopLabel = na
var label activeTargetLabel = na

bool longTriggeredEvent = false
bool shortTriggeredEvent = false
bool targetHitEvent = false
bool stopHitEvent = false
bool timeExitEvent = false
bool outsideEvent = false

// Resolve an already-active trade first.
// Priority on each bar: TP / Stop first; if neither was touched, the optional
// time exit closes at the CLOSE of the Nth COMPLETE bar after the entry bar.
if tradeActive
    bool canResolve = bar_index > activeEntryBar or barstate.isrealtime
    bool targetHit = canResolve and (tradeDir == 1 ? high >= activeTarget : low <= activeTarget)
    bool stopHit = canResolve and (tradeDir == 1 ? low <= activeStop : high >= activeStop)
    bool timeExitDue = maxBarsInTrade > 0 and barstate.isconfirmed and bar_index >= activeEntryBar + maxBarsInTrade

    if targetHit or stopHit or timeExitDue
        float resolvingEntry = activeEntry
        float resolvingStop = activeStop
        float resolvingTarget = activeTarget
        int resolvingDir = tradeDir
        string resolvingPlay = activePlay
        bool resolvingWasCustom = activeIsCustom
        string resolvingCustomKey = activeCustomKey
        int resolvingBars = math.max(bar_index - activeEntryBar - (barstate.isconfirmed ? 0 : 1), 0)
        float initialRisk = math.abs(resolvingEntry - resolvingStop)
        float exitPrice = na
        float realizedR = na
        string exitReason = ""

        if targetHit and stopHit
            exitReason := "TARGET & STOP SAME BAR"
        else if targetHit
            exitPrice := resolvingTarget
            realizedR := initialRisk > 0 ? (resolvingDir == 1 ? (exitPrice - resolvingEntry) / initialRisk : (resolvingEntry - exitPrice) / initialRisk) : na
            exitReason := "TARGET"
        else if stopHit
            exitPrice := resolvingStop
            realizedR := initialRisk > 0 ? (resolvingDir == 1 ? (exitPrice - resolvingEntry) / initialRisk : (resolvingEntry - exitPrice) / initialRisk) : na
            exitReason := "STOP"
        else
            exitPrice := close
            realizedR := initialRisk > 0 ? (resolvingDir == 1 ? (exitPrice - resolvingEntry) / initialRisk : (resolvingEntry - exitPrice) / initialRisk) : na
            exitReason := "TIME " + str.tostring(maxBarsInTrade) + " BARS"

        if not na(activeEntryLine)
            line.delete(activeEntryLine)
        if not na(activeStopLine)
            line.delete(activeStopLine)
        if not na(activeTargetLine)
            line.delete(activeTargetLine)
        if not na(activeEntryLabel)
            label.delete(activeEntryLabel)
        if not na(activeStopLabel)
            label.delete(activeStopLabel)
        if not na(activeTargetLabel)
            label.delete(activeTargetLabel)

        activeEntryLine := na
        activeStopLine := na
        activeTargetLine := na
        activeEntryLabel := na
        activeStopLabel := na
        activeTargetLabel := na

        closedTradeCount += 1
        lastClosedEntry := resolvingEntry
        lastClosedExit := exitPrice
        lastClosedR := realizedR
        lastClosedBars := resolvingBars
        lastClosedDir := resolvingDir
        lastClosedReason := exitReason
        lastClosedPlay := resolvingPlay

        array.push(tradeLogEntry, resolvingEntry)
        array.push(tradeLogExit, exitPrice)
        array.push(tradeLogR, realizedR)
        array.push(tradeLogBars, resolvingBars)
        array.push(tradeLogDir, resolvingDir)
        array.push(tradeLogReason, exitReason)
        array.push(tradeLogPlay, resolvingPlay)
        if array.size(tradeLogEntry) > 1000
            array.shift(tradeLogEntry)
            array.shift(tradeLogExit)
            array.shift(tradeLogR)
            array.shift(tradeLogBars)
            array.shift(tradeLogDir)
            array.shift(tradeLogReason)
            array.shift(tradeLogPlay)

        if exitReason == "TARGET"
            targetExitCount += 1
            targetHitEvent := true
        else if exitReason == "STOP"
            stopExitCount += 1
            stopHitEvent := true
        else if str.contains(exitReason, "TIME")
            timeExitCount += 1
            timeExitEvent := true
            if not na(realizedR)
                cumulativeTimeR += realizedR
                timeRCount += 1
                if realizedR > 0
                    timeWinCount += 1
                else if realizedR < 0
                    timeLossCount += 1
                else
                    timeFlatCount += 1
        else
            // If target and stop were both touched in one historical OHLC bar,
            // order is unknowable. Close the visual trade, but do not invent P/L.
            ambiguousExitCount += 1

        if not na(realizedR)
            cumulativeClosedR += realizedR
            closedRCount += 1

        lastResolvedBar := bar_index
        if exitReason == "TARGET"
            lastResult := "RESOLVED - TARGET HIT | X " + f_price(exitPrice) + " | " + f_r(realizedR)
        else if exitReason == "STOP"
            lastResult := "RESOLVED - STOP HIT | X " + f_price(exitPrice) + " | " + f_r(realizedR)
        else if str.contains(exitReason, "TIME")
            lastResult := "RESOLVED - " + exitReason + " | X " + f_price(exitPrice) + " | " + f_r(realizedR)
        else
            lastResult := "RESOLVED - TARGET & STOP TOUCHED SAME BAR"

        if resolvingWasCustom
            lastCompletedCustomKey := resolvingCustomKey
        tradeActive := false
        tradeDir := 0
        activeEntryBar := na
        activeSetupBar := na
        activeSetupHigh := na
        activeSetupLow := na
        activeEntry := na
        activeStop := na
        activeTarget := na
        activePlay := ""
        activeTargetSource := ""
        activeIsCustom := false
        activeCustomKey := ""
    else
        int activeX2 = bar_index + projectionBars
        if not na(activeEntryLine)
            line.set_x2(activeEntryLine, activeX2)
        if not na(activeStopLine)
            line.set_x2(activeStopLine, activeX2)
        if not na(activeTargetLine)
            line.set_x2(activeTargetLine, activeX2)
        if not na(activeEntryLabel)
            label.set_x(activeEntryLabel, activeX2 + labelOffsetBars)
        if not na(activeStopLabel)
            label.set_x(activeStopLabel, activeX2 + labelOffsetBars)
        if not na(activeTargetLabel)
            label.set_x(activeTargetLabel, activeX2 + labelOffsetBars)

// Build / refresh the waiting setup from the immediately prior CLOSED candle.
// IMPORTANT: do not rely on barstate.isnew here. If the indicator is added or
// recalculated in the middle of a live candle, barstate.isnew can already be
// false. The setup is initialized whenever the prior closed bar changes.
string customConfigKey = "CUSTOM|" + str.tostring(customTradeTicket) + "|" + customTradeDirection + "|" + str.tostring(customEntryPrice, format.mintick) + "|" + stopMethod + "|" + str.tostring(customStopTicks) + "|" + str.tostring(customStopPrice, format.mintick) + "|" + targetMethod + "|" + targetRChoice + "|" + str.tostring(customTakeProfitTicks) + "|" + str.tostring(customTakeProfitPrice, format.mintick) + "|" + structuredTargetSelection + "|" + targetHTF + "|BF" + bfTargetHTF + "/" + str.tostring(bfLookback) + "|" + str.tostring(swingLeft) + "/" + str.tostring(swingRight) + "|" + str.tostring(fibLevel1Pct) + "/" + str.tostring(fibLevel2Pct) + "|" + fvgMitigationRule + "|MOD" + (enableBfObjectives ? "B" : "-") + (enableFvgObjectives ? "F" : "-") + "|" + (useStructuredBF ? "1" : "0") + (useStructuredBFMid ? "1" : "0") + (useStructuredSwing ? "1" : "0") + (useStructuredFVG ? "1" : "0") + (useStructuredPD ? "1" : "0") + (useStructured5070 ? "1" : "0")

bool baseAllowCandidateDisplay = not tradeActive
bool needCandidateRefresh = false
if customEntryMode
    // Arm the custom trade only at the current chart edge, never across old history.
    needCandidateRefresh := baseAllowCandidateDisplay and barstate.islast and customConfigKey != lastCompletedCustomKey and candidatePatternKey != customConfigKey
else
    needCandidateRefresh := baseAllowCandidateDisplay and bar_index >= 3 and (na(candidateSetupBar) or candidateSetupBar != bar_index - 1 or str.contains(candidatePatternKey, "CUSTOM|"))

if needCandidateRefresh
    if not na(candidateUpLine)
        line.delete(candidateUpLine)
    if not na(candidateDownLine)
        line.delete(candidateDownLine)
    if not na(candidateUpLabel)
        label.delete(candidateUpLabel)
    if not na(candidateDownLabel)
        label.delete(candidateDownLabel)

    candidateUpLine := na
    candidateDownLine := na
    candidateUpLabel := na
    candidateDownLabel := na

    candidateSetupBar := customEntryMode ? bar_index : bar_index - 1
    candidatePatternKey := customEntryMode ? customConfigKey : currentPatternKey
    candidateUpEntry := effectiveUpEntry
    candidateDownEntry := effectiveDownEntry
    candidateLongStop := effectiveUpStop
    candidateShortStop := effectiveDownStop
    candidateUpTarget := effectiveUpTarget
    candidateDownTarget := effectiveDownTarget
    candidateUpTargetSource := targetMethod == "Structured objective" ? structuredUpSource : targetMethod == "R multiple" ? targetRChoice : targetMethod == "Custom ticks" ? str.tostring(customTakeProfitTicks) + "t" : "CUSTOM PRICE"
    candidateDownTargetSource := targetMethod == "Structured objective" ? structuredDownSource : targetMethod == "R multiple" ? targetRChoice : targetMethod == "Custom ticks" ? str.tostring(customTakeProfitTicks) + "t" : "CUSTOM PRICE"
    candidateUpPlay := upPlay
    candidateDownPlay := downPlay

bool allowCandidateDisplay = not tradeActive
// After a trade resolves on this bar, the next setup is drawn immediately for
// orientation, but it cannot trigger retroactively until a later bar.
bool allowCandidateTrigger = allowCandidateDisplay and (na(lastResolvedBar) or bar_index > lastResolvedBar)

// Trigger the active trade from the actual candidate setup candle.
bool candidateTimingEligible = customEntryMode ? (customConfigKey != lastCompletedCustomKey and not na(candidateSetupBar) and bar_index > candidateSetupBar) : candidateSetupBar == bar_index - 1
if allowCandidateTrigger and candidateTimingEligible
    bool rawCandidateUpTouched = customEntryMode ? (customLongMode and not na(candidateUpEntry) and low <= candidateUpEntry and high >= candidateUpEntry) : high >= candidateUpEntry
    bool rawCandidateDownTouched = customEntryMode ? (customShortMode and not na(candidateDownEntry) and low <= candidateDownEntry and high >= candidateDownEntry) : low <= candidateDownEntry
    bool candidateUpTouched = rawCandidateUpTouched and upSuggestionEligible
    bool candidateDownTouched = rawCandidateDownTouched and downSuggestionEligible

    // Structure wins over the FTFC filter: if both sides of the setup were
    // broken on the same bar, it is still an outside / 3 condition and no
    // directional trade is assumed.
    if not customEntryMode and rawCandidateUpTouched and rawCandidateDownTouched
        outsideEvent := true
        if not na(candidateUpLine)
            line.delete(candidateUpLine)
        if not na(candidateDownLine)
            line.delete(candidateDownLine)
        if not na(candidateUpLabel)
            label.delete(candidateUpLabel)
        if not na(candidateDownLabel)
            label.delete(candidateDownLabel)
        candidateUpLine := na
        candidateDownLine := na
        candidateUpLabel := na
        candidateDownLabel := na
        lastResolvedBar := bar_index
        lastResult := "NO ENTRY - BOTH SIDES BROKEN / 3"

    else if candidateUpTouched
        longTriggeredEvent := true
        tradeActive := true
        tradeDir := 1
        activeEntryBar := bar_index
        activeSetupBar := candidateSetupBar
        activeSetupHigh := setupHigh
        activeSetupLow := setupLow
        activeEntry := candidateUpEntry
        activeStop := candidateLongStop
        activeTarget := targetMethod == "Structured objective" ? effectiveUpTarget : candidateUpTarget
        activePlay := candidateUpPlay
        activeTargetSource := targetMethod == "Structured objective" ? structuredUpSource : candidateUpTargetSource
        activeIsCustom := customEntryMode
        activeCustomKey := customEntryMode ? customConfigKey : ""

        if not na(candidateUpLine)
            line.delete(candidateUpLine)
        if not na(candidateDownLine)
            line.delete(candidateDownLine)
        if not na(candidateUpLabel)
            label.delete(candidateUpLabel)
        if not na(candidateDownLabel)
            label.delete(candidateDownLabel)
        candidateUpLine := na
        candidateDownLine := na
        candidateUpLabel := na
        candidateDownLabel := na

        if showTradeLines
            int activeX2 = bar_index + projectionBars
            activeEntryLine := line.new(activeSetupBar, activeEntry, activeX2, activeEntry, xloc=xloc.bar_index, extend=extend.none, color=longLineColor, width=activeLineWidth)
            activeStopLine := line.new(activeSetupBar, activeStop, activeX2, activeStop, xloc=xloc.bar_index, extend=extend.none, color=stopLineColor, width=activeLineWidth)
            activeTargetLine := line.new(activeSetupBar, activeTarget, activeX2, activeTarget, xloc=xloc.bar_index, extend=extend.none, color=targetLineColor, width=activeLineWidth)
            if showLineLabels
                activeEntryLabel := label.new(activeX2 + labelOffsetBars, activeEntry, "ENTRY  " + f_price(activeEntry), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(longLineColor, activeLabelTransparency), textcolor=entryLabelTextColor, size=activeLabelSize)
                activeStopLabel := label.new(activeX2 + labelOffsetBars, activeStop, "STOP  " + f_price(activeStop), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(stopLineColor, activeLabelTransparency), textcolor=stopLabelTextColor, size=activeLabelSize)
                activeTargetLabel := label.new(activeX2 + labelOffsetBars, activeTarget, "TP " + (activeTargetSource == "" ? "TARGET" : activeTargetSource) + "  " + f_price(activeTarget), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(targetLineColor, activeLabelTransparency), textcolor=targetLabelTextColor, size=activeLabelSize)

    else if candidateDownTouched
        shortTriggeredEvent := true
        tradeActive := true
        tradeDir := -1
        activeEntryBar := bar_index
        activeSetupBar := candidateSetupBar
        activeSetupHigh := setupHigh
        activeSetupLow := setupLow
        activeEntry := candidateDownEntry
        activeStop := candidateShortStop
        activeTarget := targetMethod == "Structured objective" ? effectiveDownTarget : candidateDownTarget
        activePlay := candidateDownPlay
        activeTargetSource := targetMethod == "Structured objective" ? structuredDownSource : candidateDownTargetSource
        activeIsCustom := customEntryMode
        activeCustomKey := customEntryMode ? customConfigKey : ""

        if not na(candidateUpLine)
            line.delete(candidateUpLine)
        if not na(candidateDownLine)
            line.delete(candidateDownLine)
        if not na(candidateUpLabel)
            label.delete(candidateUpLabel)
        if not na(candidateDownLabel)
            label.delete(candidateDownLabel)
        candidateUpLine := na
        candidateDownLine := na
        candidateUpLabel := na
        candidateDownLabel := na

        if showTradeLines
            int activeX2 = bar_index + projectionBars
            activeEntryLine := line.new(activeSetupBar, activeEntry, activeX2, activeEntry, xloc=xloc.bar_index, extend=extend.none, color=shortLineColor, width=activeLineWidth)
            activeStopLine := line.new(activeSetupBar, activeStop, activeX2, activeStop, xloc=xloc.bar_index, extend=extend.none, color=stopLineColor, width=activeLineWidth)
            activeTargetLine := line.new(activeSetupBar, activeTarget, activeX2, activeTarget, xloc=xloc.bar_index, extend=extend.none, color=targetLineColor, width=activeLineWidth)
            if showLineLabels
                activeEntryLabel := label.new(activeX2 + labelOffsetBars, activeEntry, "ENTRY  " + f_price(activeEntry), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(shortLineColor, activeLabelTransparency), textcolor=entryLabelTextColor, size=activeLabelSize)
                activeStopLabel := label.new(activeX2 + labelOffsetBars, activeStop, "STOP  " + f_price(activeStop), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(stopLineColor, activeLabelTransparency), textcolor=stopLabelTextColor, size=activeLabelSize)
                activeTargetLabel := label.new(activeX2 + labelOffsetBars, activeTarget, "TP " + (activeTargetSource == "" ? "TARGET" : activeTargetSource) + "  " + f_price(activeTarget), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(targetLineColor, activeLabelTransparency), textcolor=targetLabelTextColor, size=activeLabelSize)

// A newly triggered trade can already have touched the user-defined TP or Stop
// on the same historical OHLC bar. Historical OHLC cannot reveal whether entry
// occurred before that extreme, so same-entry-bar TP/Stop touches are treated as
// ambiguous rather than inventing a win/loss. In live/realtime, later ticks are
// resolved normally by the active-trade engine above.
if tradeActive and (longTriggeredEvent or shortTriggeredEvent) and not barstate.isrealtime
    bool targetAlreadyHit = tradeDir == 1 ? high >= activeTarget : low <= activeTarget
    bool stopAlreadyHit = tradeDir == 1 ? low <= activeStop : high >= activeStop
    if targetAlreadyHit or stopAlreadyHit
        if not na(activeEntryLine)
            line.delete(activeEntryLine)
        if not na(activeStopLine)
            line.delete(activeStopLine)
        if not na(activeTargetLine)
            line.delete(activeTargetLine)
        if not na(activeEntryLabel)
            label.delete(activeEntryLabel)
        if not na(activeStopLabel)
            label.delete(activeStopLabel)
        if not na(activeTargetLabel)
            label.delete(activeTargetLabel)

        activeEntryLine := na
        activeStopLine := na
        activeTargetLine := na
        activeEntryLabel := na
        activeStopLabel := na
        activeTargetLabel := na
        closedTradeCount += 1
        ambiguousExitCount += 1
        lastClosedEntry := activeEntry
        lastClosedExit := na
        lastClosedR := na
        lastClosedBars := 0
        lastClosedDir := tradeDir
        lastClosedReason := "ENTRY-BAR TP/STOP AMBIG"
        lastClosedPlay := activePlay
        array.push(tradeLogEntry, activeEntry)
        array.push(tradeLogExit, float(na))
        array.push(tradeLogR, float(na))
        array.push(tradeLogBars, 0)
        array.push(tradeLogDir, tradeDir)
        array.push(tradeLogReason, "ENTRY-BAR TP/STOP AMBIG")
        array.push(tradeLogPlay, activePlay)
        if array.size(tradeLogEntry) > 1000
            array.shift(tradeLogEntry)
            array.shift(tradeLogExit)
            array.shift(tradeLogR)
            array.shift(tradeLogBars)
            array.shift(tradeLogDir)
            array.shift(tradeLogReason)
            array.shift(tradeLogPlay)
        lastResolvedBar := bar_index
        lastResult := "RESOLVED - ENTRY-BAR TP/STOP ORDER AMBIGUOUS"
        if activeIsCustom
            lastCompletedCustomKey := activeCustomKey
        tradeActive := false
        tradeDir := 0
        activeEntryBar := na
        activeSetupBar := na
        activeSetupHigh := na
        activeSetupLow := na
        activeEntry := na
        activeStop := na
        activeTarget := na
        activePlay := ""
        activeTargetSource := ""
        activeIsCustom := false
        activeCustomKey := ""

// Draw the current waiting setup AFTER all trade-resolution logic. This removes
// the old trade lines and immediately restores the next tentative dashed setup
// levels on the very same bar. The FTFC filter uses the user-selected REQ
// timeframe stack; the table continues to show both structural directions.
bool customCandidateCurrent = not customEntryMode or (candidatePatternKey == customConfigKey and customConfigKey != lastCompletedCustomKey)
bool showUpCandidateNow = not tradeActive and customCandidateCurrent and upSuggestionEligible and not na(candidateUpEntry)
bool showDownCandidateNow = not tradeActive and customCandidateCurrent and downSuggestionEligible and not na(candidateDownEntry)
int candidateX2Live = bar_index + projectionBars

if showTradeLines and showCandidateLines and showUpCandidateNow
    if na(candidateUpLine)
        candidateUpLine := line.new(candidateSetupBar, candidateUpEntry, candidateX2Live, candidateUpEntry, xloc=xloc.bar_index, extend=extend.none, color=color.new(longLineColor, 20), style=line.style_dashed, width=1)
    else
        line.set_xy1(candidateUpLine, candidateSetupBar, candidateUpEntry)
        line.set_xy2(candidateUpLine, candidateX2Live, candidateUpEntry)
    if showLineLabels
        if na(candidateUpLabel)
            candidateUpLabel := label.new(candidateX2Live + labelOffsetBars, candidateUpEntry, candidateUpPlay + "  " + f_price(candidateUpEntry), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(longLineColor, candidateLabelTransparency), textcolor=candidateLabelTextColor, size=candidateLabelSize)
        else
            label.set_x(candidateUpLabel, candidateX2Live + labelOffsetBars)
            label.set_y(candidateUpLabel, candidateUpEntry)
    else if not na(candidateUpLabel)
        label.delete(candidateUpLabel)
        candidateUpLabel := na
else
    if not na(candidateUpLine)
        line.delete(candidateUpLine)
        candidateUpLine := na
    if not na(candidateUpLabel)
        label.delete(candidateUpLabel)
        candidateUpLabel := na

if showTradeLines and showCandidateLines and showDownCandidateNow
    if na(candidateDownLine)
        candidateDownLine := line.new(candidateSetupBar, candidateDownEntry, candidateX2Live, candidateDownEntry, xloc=xloc.bar_index, extend=extend.none, color=color.new(shortLineColor, 20), style=line.style_dashed, width=1)
    else
        line.set_xy1(candidateDownLine, candidateSetupBar, candidateDownEntry)
        line.set_xy2(candidateDownLine, candidateX2Live, candidateDownEntry)
    if showLineLabels
        if na(candidateDownLabel)
            candidateDownLabel := label.new(candidateX2Live + labelOffsetBars, candidateDownEntry, candidateDownPlay + "  " + f_price(candidateDownEntry), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(shortLineColor, candidateLabelTransparency), textcolor=candidateLabelTextColor, size=candidateLabelSize)
        else
            label.set_x(candidateDownLabel, candidateX2Live + labelOffsetBars)
            label.set_y(candidateDownLabel, candidateDownEntry)
    else if not na(candidateDownLabel)
        label.delete(candidateDownLabel)
        candidateDownLabel := na
else
    if not na(candidateDownLine)
        line.delete(candidateDownLine)
        candidateDownLine := na
    if not na(candidateDownLabel)
        label.delete(candidateDownLabel)
        candidateDownLabel := na

// Number of COMPLETE bars after entry. Entry bar = Bar 0. A live developing
// bar does not count until that bar closes.
int activeCompletedBars = tradeActive and not na(activeEntryBar) ? math.max(bar_index - activeEntryBar - (barstate.isconfirmed ? 0 : 1), 0) : 0
string activeHoldText = tradeActive and maxBarsInTrade > 0 ? " | HOLD " + str.tostring(activeCompletedBars) + "/" + str.tostring(maxBarsInTrade) : ""

//=============================================================================
// ACTIVE NOW / DECISION HIERARCHY
//=============================================================================
string activeNow = "WAITING - NO TRIGGER"
color activeNowColor = C_NEUTRAL
if tradeActive
    activeNow := (tradeDir == 1 ? "LONG ACTIVE - " : "SHORT ACTIVE - ") + activePlay + " | E " + f_price(activeEntry) + " | S " + f_price(activeStop) + " | TP " + f_price(activeTarget) + (activeTargetSource == "" ? "" : " " + activeTargetSource) + activeHoldText
    activeNowColor := tradeDir == 1 ? C_BULL : C_BEAR
else if not na(lastResolvedBar) and bar_index == lastResolvedBar
    activeNow := lastResult
    activeNowColor := str.contains(lastResult, "TARGET HIT") ? C_BULL : str.contains(lastResult, "STOP HIT") ? C_BEAR : str.contains(lastResult, "TIME ") ? (lastClosedR > 0 ? C_BULL : lastClosedR < 0 ? C_BEAR : C_NEUTRAL) : C_WARN
else if bothTouched
    activeNow := "NO DIRECTIONAL ENTRY - BOTH SIDES / 3"
    activeNowColor := C_WARN
else if close > setupMid
    activeNow := "WAITING - PRICE IN UPPER HALF OF SETUP"
    activeNowColor := C_INFO
else if close < setupMid
    activeNow := "WAITING - PRICE IN LOWER HALF OF SETUP"
    activeNowColor := C_INFO

string upFtfcContext = customEntryMode ? "USER-CONSTRUCTED" : bullFTFCAligned ? "WITH FULL FTFC" : bearFTFCAligned ? "COUNTER FULL FTFC" : ftfcConfigured ? "NOT FULL FTFC" : "FTFC NOT CONFIGURED"
string downFtfcContext = customEntryMode ? "USER-CONSTRUCTED" : bearFTFCAligned ? "WITH FULL FTFC" : bullFTFCAligned ? "COUNTER FULL FTFC" : ftfcConfigured ? "NOT FULL FTFC" : "FTFC NOT CONFIGURED"
string upContext = upTradeLevelsValid ? upFtfcContext : targetMethod == "Structured objective" ? "NO VALID STRUCTURED TARGET" : "INVALID ENTRY / STOP / TP"
color upContextColor = not upTradeLevelsValid ? C_WARN : bullFTFCAligned ? C_BULL : bearFTFCAligned ? C_WARN : C_NEUTRAL
string downContext = downTradeLevelsValid ? downFtfcContext : targetMethod == "Structured objective" ? "NO VALID STRUCTURED TARGET" : "INVALID ENTRY / STOP / TP"
color downContextColor = not downTradeLevelsValid ? C_WARN : bearFTFCAligned ? C_BEAR : bullFTFCAligned ? C_WARN : C_NEUTRAL

//=============================================================================
// OPTIONAL STRUCTURED-OBJECTIVE REFERENCES
// Visual focus: Strat BF High/Low are primary target rails; FVG/50-70 remain supporting target context.
// Swing and PDH/PDL references remain available as optional short lines.
//=============================================================================
var line structBfHighLine = na
var line structBfLowLine = na
var line structBfMidLine = na
var box structBfHighBand = na
var box structBfLowBand = na
var label structBfHighLabel = na
var label structBfLowLabel = na
var label structBfMidLabel = na
var line structSwingUpLine = na
var line structSwingDownLine = na
var line structPdUpLine = na
var line structPdDownLine = na
var array<box> structFvgBoxes = array.new_box()
var array<label> structFvgLabels = array.new_label()
var box struct5070Box = na
var label structSwingUpLabel = na
var label structSwingDownLabel = na
var label structPdUpLabel = na
var label structPdDownLabel = na

f_setStructLine(line ln, float y, int x1, int x2, color c, string styleName) =>
    line out = ln
    if na(out)
        out := line.new(x1, y, x2, y, xloc=xloc.bar_index, color=c, style=styleName == "dotted" ? line.style_dotted : line.style_dashed, width=1)
    else
        line.set_xy1(out, x1, y)
        line.set_xy2(out, x2, y)
        line.set_color(out, c)
        line.set_style(out, styleName == "dotted" ? line.style_dotted : line.style_dashed)
    out

f_setBfLine(line ln, float y, int x1, int x2, color c, int width, bool dashed) =>
    line out = ln
    if na(out)
        out := line.new(x1, y, x2, y, xloc=xloc.bar_index, color=color.new(c, structuredBfLineTransparency), style=dashed ? line.style_dashed : line.style_solid, width=width)
    else
        line.set_xy1(out, x1, y)
        line.set_xy2(out, x2, y)
        line.set_color(out, color.new(c, structuredBfLineTransparency))
        line.set_style(out, dashed ? line.style_dashed : line.style_solid)
        line.set_width(out, width)
    out

f_setBfBand(box bx, int x1, int x2, float y, color c) =>
    box out = bx
    float pad = structuredBfBandTicks * syminfo.mintick
    if structuredBfBandTicks <= 0
        if not na(out)
            box.delete(out)
        out := box(na)
    else
        float top = y + pad
        float bot = y - pad
        if na(out)
            out := box.new(left=x1, top=top, right=x2, bottom=bot, xloc=xloc.bar_index, border_color=color.new(c, 100), border_width=0, bgcolor=color.new(c, structuredBfBandTransparency))
        else
            box.set_lefttop(out, x1, top)
            box.set_rightbottom(out, x2, bot)
            box.set_border_color(out, color.new(c, 100))
            box.set_border_width(out, 0)
            box.set_bgcolor(out, color.new(c, structuredBfBandTransparency))
    out

f_setBfTargetLabel(label lb, int x, float y, string txt, color c) =>
    label out = lb
    if na(out)
        out := label.new(x, y, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c, 12), textcolor=structuredBfLabelTextColor, size=structuredBfLabelSize)
    else
        label.set_xy(out, x, y)
        label.set_text(out, txt)
        label.set_color(out, color.new(c, 12))
        label.set_textcolor(out, structuredBfLabelTextColor)
        label.set_size(out, structuredBfLabelSize)
    out

f_setStructLabel(label lb, int x, float y, string txt, color c) =>
    label out = lb
    if na(out)
        out := label.new(x, y, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c, 78), textcolor=color.white, size=structuredLabelSize)
    else
        label.set_xy(out, x, y)
        label.set_text(out, txt)
        label.set_color(out, color.new(c, 78))
        label.set_textcolor(out, color.white)
        label.set_size(out, structuredLabelSize)
    out

f_setStructBox(box bx, int x1, int x2, float lo, float hi, string txt, color c, int fillTransparency) =>
    box out = bx
    float bot = math.min(lo, hi)
    float top = math.max(lo, hi)
    if na(out)
        out := box.new(left=x1, top=top, right=x2, bottom=bot, xloc=xloc.bar_index, border_color=color.new(c, structuredZoneBorderTransparency), border_width=structuredZoneBorderWidth, bgcolor=color.new(c, fillTransparency), text=txt, text_color=structuredZoneLabelTextColor, text_size=structuredZoneLabelSize, text_halign=text.align_center, text_valign=text.align_center)
    else
        box.set_lefttop(out, x1, top)
        box.set_rightbottom(out, x2, bot)
        box.set_border_color(out, color.new(c, structuredZoneBorderTransparency))
        box.set_border_width(out, structuredZoneBorderWidth)
        box.set_bgcolor(out, color.new(c, fillTransparency))
        box.set_text(out, txt)
        box.set_text_color(out, structuredZoneLabelTextColor)
        box.set_text_size(out, structuredZoneLabelSize)
        box.set_text_halign(out, text.align_center)
        box.set_text_valign(out, text.align_center)
    out

f_delLine(line ln) =>
    if not na(ln)
        line.delete(ln)
    line(na)

f_delLabel(label lb) =>
    if not na(lb)
        label.delete(lb)
    label(na)

f_delBox(box bx) =>
    if not na(bx)
        box.delete(bx)
    box(na)

f_fvgStateText(int stateCode) =>
    stateCode == 1 ? "RESPECTED" :
     stateCode == 2 ? "RESPECTED + NEW FVG" :
     stateCode == 3 ? "WEAKNESS - NO NEW FVG" :
     stateCode == 4 ? "DISRESPECTED" : "UNTESTED"

f_fvgStateColor(int stateCode) =>
    stateCode == 1 ? structuredFvgRespectedColor :
     stateCode == 2 ? structuredFvgConfirmedColor :
     stateCode == 3 ? structuredFvgWeaknessColor :
     stateCode == 4 ? structuredFvgDisrespectedColor : structuredFvgUntestedColor

if barstate.islast
    int sx1 = bar_index + 1
    int sx2 = bar_index + structuredProjectionBars
    bool drawStruct = showStructuredLevelsOnChart and enableStructuredObjectives
    string structTfLabel = f_mobileTfLabel(targetHTF)
    string bfTfLabel = f_mobileTfLabel(bfTargetHTF)

    if drawStruct and enableBfObjectives and showStructuredBfMidRef and not na(bfMid)
        structBfMidLine := f_setBfLine(structBfMidLine, bfMid, sx1, sx2, structuredBfMidColor, 1, true)
        structBfMidLabel := f_setStructLabel(structBfMidLabel, sx2, bfMid, bfTfLabel + " BF MID " + f_price(bfMid), structuredBfMidColor)
    else
        structBfMidLine := f_delLine(structBfMidLine)
        structBfMidLabel := f_delLabel(structBfMidLabel)

    // Optional short swing references. OFF by default so the chart stays target-focused.
    if drawStruct and showStructuredSwingRef and not na(nearestSwingUp)
        structSwingUpLine := f_setStructLine(structSwingUpLine, nearestSwingUp, sx1, sx2, structuredSwingColor, "dashed")
        structSwingUpLabel := f_setStructLabel(structSwingUpLabel, sx2, nearestSwingUp, structTfLabel + " SWING H " + f_price(nearestSwingUp), structuredSwingColor)
    else
        structSwingUpLine := f_delLine(structSwingUpLine)
        structSwingUpLabel := f_delLabel(structSwingUpLabel)

    if drawStruct and showStructuredSwingRef and not na(nearestSwingDown)
        structSwingDownLine := f_setStructLine(structSwingDownLine, nearestSwingDown, sx1, sx2, structuredSwingColor, "dashed")
        structSwingDownLabel := f_setStructLabel(structSwingDownLabel, sx2, nearestSwingDown, structTfLabel + " SWING L " + f_price(nearestSwingDown), structuredSwingColor)
    else
        structSwingDownLine := f_delLine(structSwingDownLine)
        structSwingDownLabel := f_delLabel(structSwingDownLabel)

    // Optional PDH/PDL references. OFF by default; they remain available as context.
    if drawStruct and showStructuredPdRef and not na(pdh)
        structPdUpLine := f_setStructLine(structPdUpLine, pdh, sx1, sx2, structuredPdColor, "dotted")
        structPdUpLabel := f_setStructLabel(structPdUpLabel, sx2, pdh, "PDH " + f_price(pdh), structuredPdColor)
    else
        structPdUpLine := f_delLine(structPdUpLine)
        structPdUpLabel := f_delLabel(structPdUpLabel)

    if drawStruct and showStructuredPdRef and not na(pdl)
        structPdDownLine := f_setStructLine(structPdDownLine, pdl, sx1, sx2, structuredPdColor, "dotted")
        structPdDownLabel := f_setStructLabel(structPdDownLabel, sx2, pdl, "PDL " + f_price(pdl), structuredPdColor)
    else
        structPdDownLine := f_delLine(structPdDownLine)
        structPdDownLabel := f_delLabel(structPdDownLabel)

    // Historical unmitigated FVGs. Redraw only on the last chart bar so the
    // visible set always reflects the user's requested count and current
    // mitigation rule. Each box starts at its original HTF formation and
    // extends right until that FVG is retired by the lifecycle engine.
    if array.size(structFvgBoxes) > 0
        int oldBoxIdx = array.size(structFvgBoxes) - 1
        while oldBoxIdx >= 0
            box.delete(array.get(structFvgBoxes, oldBoxIdx))
            oldBoxIdx -= 1
        array.clear(structFvgBoxes)
    if array.size(structFvgLabels) > 0
        int oldLabelIdx = array.size(structFvgLabels) - 1
        while oldLabelIdx >= 0
            label.delete(array.get(structFvgLabels, oldLabelIdx))
            oldLabelIdx -= 1
        array.clear(structFvgLabels)

    if drawStruct and enableFvgObjectives and showStructuredFvgRef and array.size(activeFvgLo) > 0
        int shownBull = 0
        int shownBear = 0
        int drawFvgIdx = array.size(activeFvgLo) - 1
        while drawFvgIdx >= 0
            int gapDir = array.get(activeFvgDir, drawFvgIdx)
            bool canShow = (gapDir == 1 and shownBull < historicalFvgsPerSide) or (gapDir == -1 and shownBear < historicalFvgsPerSide)
            if canShow
                float gapLo = array.get(activeFvgLo, drawFvgIdx)
                float gapHi = array.get(activeFvgHi, drawFvgIdx)
                int gapBorn = array.get(activeFvgBorn, drawFvgIdx)
                int gapState = array.get(activeFvgState, drawFvgIdx)
                string gapPolarity = gapDir == 1 ? "BULL FVG" : "BEAR FVG"
                string gapStateText = f_fvgStateText(gapState)
                color gapStateColor = f_fvgStateColor(gapState)
                string gapName = structTfLabel + " " + gapPolarity
                string gapRange = f_price(gapLo) + " - " + f_price(gapHi)
                string gapText = structuredFvgLabelDetail == "State + range" ? gapName + " - " + gapStateText + "\n" + gapRange : structuredFvgLabelDetail == "State only" ? gapName + " - " + gapStateText : structuredFvgLabelDetail == "Range only" ? gapName + "\n" + gapRange : gapName
                box gapBox = box.new(left=gapBorn, top=gapHi, right=time_close, bottom=gapLo, xloc=xloc.bar_time, extend=extend.right, border_color=color.new(gapStateColor, structuredFvgBorderTransparency), border_width=structuredFvgBorderWidth, bgcolor=color.new(gapStateColor, structuredFvgTransparency))
                label gapLabel = label.new(bar_index + structuredFvgLabelOffsetBars, (gapLo + gapHi) / 2.0, gapText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(gapStateColor, structuredFvgLabelBgTransparency), textcolor=structuredFvgLabelTextColor, size=structuredFvgLabelSize)
                array.push(structFvgBoxes, gapBox)
                array.push(structFvgLabels, gapLabel)
                if gapDir == 1
                    shownBull += 1
                else
                    shownBear += 1
            drawFvgIdx -= 1

    // The user's selected-HTF 50/70 directional retracement area is also a true zone.
    if drawStruct and enableBfObjectives and showStructured5070Ref and not na(structuredZoneBot) and not na(structuredZoneTop)
        string zoneText = bfTfLabel + " BF 50-70% ZONE\n" + f_price(structuredZoneBot) + " - " + f_price(structuredZoneTop)
        struct5070Box := f_setStructBox(struct5070Box, sx1, sx2, structuredZoneBot, structuredZoneTop, zoneText, structuredZoneColor, structuredZoneTransparency)
    else
        struct5070Box := f_delBox(struct5070Box)


    // Draw the active Strat BF boundaries LAST so FVG boxes cannot visually bury
    // the primary Strat targets. The shaded band is only emphasis; the solid rail
    // remains the exact BF price.
    int bfRailX1 = math.max(0, bar_index - structuredBfRailLeftBars)
    float overlapPad = structuredOverlapTicks * syminfo.mintick
    bool bfHighNearFvg = enableFvgObjectives and not na(bfHigh) and not na(nearestFvgUpLo) and not na(nearestFvgUpHi) and bfHigh >= nearestFvgUpLo - overlapPad and bfHigh <= nearestFvgUpHi + overlapPad
    bool bfLowNearFvg = enableFvgObjectives and not na(bfLow) and not na(nearestFvgDownLo) and not na(nearestFvgDownHi) and bfLow >= nearestFvgDownLo - overlapPad and bfLow <= nearestFvgDownHi + overlapPad
    int bfHighLabelX = sx2 + structuredBfLabelOffsetBars + (structuredAutoStaggerLabels and bfHighNearFvg ? structuredCollisionExtraBars : 0)
    int bfLowLabelX = sx2 + structuredBfLabelOffsetBars + (structuredAutoStaggerLabels and bfLowNearFvg ? structuredCollisionExtraBars : 0)
    int bfHighRailX2 = math.max(sx2, bfHighLabelX)
    int bfLowRailX2 = math.max(sx2, bfLowLabelX)

    if drawStruct and enableBfObjectives and showStructuredBfRef and not na(bfHigh)
        structBfHighBand := f_setBfBand(structBfHighBand, bfRailX1, bfHighRailX2, bfHigh, structuredBfHighColor)
        structBfHighLine := f_setBfLine(structBfHighLine, bfHigh, bfRailX1, bfHighRailX2, structuredBfHighColor, structuredBfLineWidth, false)
        structBfHighLabel := f_setBfTargetLabel(structBfHighLabel, bfHighLabelX, bfHigh, bfTfLabel + " BF HIGH TARGET " + f_price(bfHigh), structuredBfHighColor)
    else
        structBfHighBand := f_delBox(structBfHighBand)
        structBfHighLine := f_delLine(structBfHighLine)
        structBfHighLabel := f_delLabel(structBfHighLabel)

    if drawStruct and enableBfObjectives and showStructuredBfRef and not na(bfLow)
        structBfLowBand := f_setBfBand(structBfLowBand, bfRailX1, bfLowRailX2, bfLow, structuredBfLowColor)
        structBfLowLine := f_setBfLine(structBfLowLine, bfLow, bfRailX1, bfLowRailX2, structuredBfLowColor, structuredBfLineWidth, false)
        structBfLowLabel := f_setBfTargetLabel(structBfLowLabel, bfLowLabelX, bfLow, bfTfLabel + " BF LOW TARGET " + f_price(bfLow), structuredBfLowColor)
    else
        structBfLowBand := f_delBox(structBfLowBand)
        structBfLowLine := f_delLine(structBfLowLine)
        structBfLowLabel := f_delLabel(structBfLowLabel)

//=============================================================================
// OPTIONAL PLOTS / MARKERS
// No full-chart red/green trigger plots anymore.
//=============================================================================
plot(showKeyLevels ? dayOpen : na, "Reference Session Open", color=color.new(color.yellow, 20), linewidth=1, style=plot.style_linebr)
plot(showKeyLevels ? pdh : na, "Previous Session High", color=color.new(color.aqua, 20), linewidth=1, style=plot.style_linebr)
plot(showKeyLevels ? pdl : na, "Previous Session Low", color=color.new(color.aqua, 20), linewidth=1, style=plot.style_linebr)

// Failed 2 markers belong on the FAILED candle itself, not the next trigger bar.
// These are close-confirmed, so they do not repaint after the bar closes.
if showFailed2Markers and failed2UConfirmed
    label.new(bar_index, high, "F2U", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=failed2UpColor, textcolor=failed2TextColor, size=failed2LabelSize)
if showFailed2Markers and failed2DConfirmed
    label.new(bar_index, low, "F2D", xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=failed2DownColor, textcolor=failed2TextColor, size=failed2LabelSize)

plotshape(showSignalMarkers and longTriggeredEvent and barstate.isconfirmed, title="Confirmed Upside Trigger", style=shape.triangleup, location=location.belowbar, color=longLineColor, size=size.tiny, text="UP", textcolor=color.white)
plotshape(showSignalMarkers and shortTriggeredEvent and barstate.isconfirmed, title="Confirmed Downside Trigger", style=shape.triangledown, location=location.abovebar, color=shortLineColor, size=size.tiny, text="DN", textcolor=color.white)
plotshape(showSignalMarkers and outsideEvent and barstate.isconfirmed, title="Confirmed Outside / 3", style=shape.diamond, location=location.abovebar, color=warningInput, size=size.tiny, text="3", textcolor=color.white)

bool bfHighTouchedEvent = enableStructuredObjectives and enableBfObjectives and not na(bfHigh) and high >= bfHigh and nz(high[1], high) < nz(bfHigh[1], bfHigh)
bool bfLowTouchedEvent = enableStructuredObjectives and enableBfObjectives and not na(bfLow) and low <= bfLow and nz(low[1], low) > nz(bfLow[1], bfLow)
bool bfHighClosedBeyondEvent = enableStructuredObjectives and enableBfObjectives and barstate.isconfirmed and not na(bfHigh) and close > bfHigh and nz(close[1], close) <= nz(bfHigh[1], bfHigh)
bool bfLowClosedBeyondEvent = enableStructuredObjectives and enableBfObjectives and barstate.isconfirmed and not na(bfLow) and close < bfLow and nz(close[1], close) >= nz(bfLow[1], bfLow)
alertcondition(bfHighTouchedEvent, "Strat CC - BF High Touched", "TheStrat Command Center: price reached the active Broadening Formation High target area.")
alertcondition(bfLowTouchedEvent, "Strat CC - BF Low Touched", "TheStrat Command Center: price reached the active Broadening Formation Low target area.")
alertcondition(bfHighClosedBeyondEvent, "Strat CC - BF High Closed Beyond", "TheStrat Command Center: a confirmed chart candle closed beyond the active Broadening Formation High.")
alertcondition(bfLowClosedBeyondEvent, "Strat CC - BF Low Closed Beyond", "TheStrat Command Center: a confirmed chart candle closed beyond the active Broadening Formation Low.")

alertcondition(failed2UConfirmed, "Strat CC - Failed 2U", "TheStrat Command Center: Failed 2U confirmed — the candle finished as a true 2U and closed red below its own open. A 3/outside bar is excluded.")
alertcondition(failed2DConfirmed, "Strat CC - Failed 2D", "TheStrat Command Center: Failed 2D confirmed — the candle finished as a true 2D and closed green above its own open. A 3/outside bar is excluded.")
alertcondition(longTriggeredEvent and barstate.isconfirmed, "Strat CC - Confirmed Upside Trigger", "TheStrat Command Center: confirmed upside trigger from the actual setup candle.")
alertcondition(shortTriggeredEvent and barstate.isconfirmed, "Strat CC - Confirmed Downside Trigger", "TheStrat Command Center: confirmed downside trigger from the actual setup candle.")
alertcondition(targetHitEvent, "Strat CC - Target Hit", "TheStrat Command Center: active trade take-profit level was hit and trade lines were removed.")
alertcondition(stopHitEvent, "Strat CC - Stop Hit", "TheStrat Command Center: active trade stop level was hit and trade lines were removed.")
alertcondition(timeExitEvent, "Strat CC - Time Exit", "TheStrat Command Center: active trade reached the user-defined maximum holding period and closed at the completed bar's close.")

// Expose the most recent deterministic closure and counts in TradingView's Data Window.
// These values MUST be declared before the plot() calls; v1.3.18 declared
// lastClosedPLTicks later in the dashboard block, which caused the compile error.
float dataWindowDirectionalMove = na(lastClosedEntry) or na(lastClosedExit) ? na : lastClosedDir == 1 ? lastClosedExit - lastClosedEntry : lastClosedDir == -1 ? lastClosedEntry - lastClosedExit : na
float dataWindowPLTicks = na(dataWindowDirectionalMove) or syminfo.mintick <= 0 ? na : dataWindowDirectionalMove / syminfo.mintick
plot(lastClosedEntry, "Last Closed Trade Entry", display=display.data_window)
plot(lastClosedExit, "Last Closed Trade Exit", display=display.data_window)
plot(lastClosedR, "Last Closed Trade R", display=display.data_window)
plot(dataWindowPLTicks, "Last Closed Trade P/L Ticks", display=display.data_window)
plot(closedTradeCount, "Closed Trade Count", display=display.data_window)
plot(timeExitCount, "Timed Exit Count", display=display.data_window)

//=============================================================================
// COMMAND CENTER - DESKTOP + MOBILE
// Mobile mode is intentionally selective: it keeps Active Now, FTFC, the best
// structural play, both directional opportunities, setup levels, selected TP/stop methods,
// next triggers, and session-open context. Detailed objectives/rules remain in
// Desktop mode so the phone layout stays readable.
//=============================================================================
string dashTextSize = f_textSize(dashboardSize)
bool compactDash = dashboardDetail == "Compact"
bool mobileDash = dashboardMode == "Mobile"
bool useCompactText = compactDash or mobileDash

// During an active trade, freeze the displayed setup H/L on the candle that
// created that trade. The Possible Plays engine continues scanning the newest
// closed candle separately, so a later setup can still be seen without
// overwriting the active trade's original risk structure.
float displaySetupHigh = customEntryMode ? (tradeActive ? activeEntry : customEntryPrice) : tradeActive and not na(activeSetupHigh) ? activeSetupHigh : setupHigh
float displaySetupLow = customEntryMode ? (tradeActive ? activeStop : (customLongMode ? effectiveUpStop : effectiveDownStop)) : tradeActive and not na(activeSetupLow) ? activeSetupLow : setupLow
string setupHighLabel = tradeActive ? "ACTIVE TRADE\nSETUP HIGH" : "CURRENT SETUP\nHIGH"
string setupLowLabel = tradeActive ? "ACTIVE TRADE\nSETUP LOW" : "CURRENT SETUP\nLOW"
string upDistanceLabel = tradeActive ? "TO NEXT UP TRIGGER" : "TO UP TRIGGER"
string downDistanceLabel = tradeActive ? "TO NEXT DOWN TRIGGER" : "TO DOWN TRIGGER"
string lastTypeDesc = lastFailed2U ? "F2U | " + lastType : lastFailed2D ? "F2D | " + lastType : compactDash ? lastType : lastType + " | " + f_typeMeaning(lastType)
string activeDisplay = useCompactText ? str.replace_all(str.replace_all(activeNow, "WAITING - PRICE IN UPPER HALF OF SETUP", "WAIT - UPPER HALF"), "WAITING - PRICE IN LOWER HALF OF SETUP", "WAIT - LOWER HALF") : activeNow
string reversalDisplay = useCompactText ? str.replace_all(str.replace_all(reversalAvailable, " REVERSAL ABOVE ", " REV > "), " REVERSAL BELOW ", " REV < ") : reversalAvailable
string bestDisplay = useCompactText ? str.replace_all(bestStructuralPlay, " | FULL FTFC", " | FTFC") : bestStructuralPlay
color bestDisplayColor = bestStructuralColor
if customEntryMode
    bestDisplay := "CUSTOM " + customTradeDirection + " | E " + f_price(customEntryPrice) + " | USER-CONSTRUCTED"
    bestDisplayColor := customLongMode ? C_BULL : C_BEAR
string upTargetSuffix = targetMethod == "Structured objective" and structuredUpSource != "" ? " " + structuredUpSource : ""
string downTargetSuffix = targetMethod == "Structured objective" and structuredDownSource != "" ? " " + structuredDownSource : ""
string upDisplay = customEntryMode and not customLongMode ? "CUSTOM MODE | LONG INACTIVE" : compactDash ? upPlay + " | E " + f_price(effectiveUpEntry) + " | S " + f_price(effectiveUpStop) + " | TP " + f_price(effectiveUpTarget) + upTargetSuffix + " | ROOM " + upRoom + " | " + upContext : upPlay + " | ENTRY " + f_price(effectiveUpEntry) + " | STOP " + f_price(effectiveUpStop) + " | TP " + f_price(effectiveUpTarget) + upTargetSuffix + " | ROOM " + upRoom + " | " + upContext
string downDisplay = customEntryMode and not customShortMode ? "CUSTOM MODE | SHORT INACTIVE" : compactDash ? downPlay + " | E " + f_price(effectiveDownEntry) + " | S " + f_price(effectiveDownStop) + " | TP " + f_price(effectiveDownTarget) + downTargetSuffix + " | ROOM " + downRoom + " | " + downContext : downPlay + " | ENTRY " + f_price(effectiveDownEntry) + " | STOP " + f_price(effectiveDownStop) + " | TP " + f_price(effectiveDownTarget) + downTargetSuffix + " | ROOM " + downRoom + " | " + downContext
string upDistanceValue = f_ticks(math.max(effectiveUpEntry - close, 0))
string downDistanceValue = f_ticks(math.max(close - effectiveDownEntry, 0))

// Phone-specific strings are deliberately shorter than Desktop mode.
string mobileFtfcA = f_mobileReqTfLabel(tf1, reqTf1) + " " + f_stateLetter(s1) + "  |  " + f_mobileReqTfLabel(tf2, reqTf2) + " " + f_stateLetter(s2) + "  |  " + f_mobileReqTfLabel(tf3, reqTf3) + " " + f_stateLetter(s3)
string mobileFtfcB = f_mobileReqTfLabel(tf4, reqTf4) + " " + f_stateLetter(s4) + "  |  " + f_mobileReqTfLabel(tf5, reqTf5) + " " + f_stateLetter(s5) + "  |  " + f_mobileReqTfLabel(tf6, reqTf6) + " " + f_stateLetter(s6)
string mobileUpDisplay = customEntryMode and not customLongMode ? "CUSTOM LONG INACTIVE" : upPlay + " | E " + f_price(effectiveUpEntry) + " | TP " + f_price(effectiveUpTarget) + upTargetSuffix + " | " + upContext
string mobileDownDisplay = customEntryMode and not customShortMode ? "CUSTOM SHORT INACTIVE" : downPlay + " | E " + f_price(effectiveDownEntry) + " | TP " + f_price(effectiveDownTarget) + downTargetSuffix + " | " + downContext
string mobileSessionStatus = na(dayOpen) ? referenceSessionLabel + "\nOPEN --" : (close > dayOpen ? "ABOVE\n" + referenceSessionLabel : close < dayOpen ? "BELOW\n" + referenceSessionLabel : "AT\n" + referenceSessionLabel)

float avgClosedR = closedRCount > 0 ? cumulativeClosedR / closedRCount : na
float avgTimeR = timeRCount > 0 ? cumulativeTimeR / timeRCount : na
float lastClosedDirectionalMove = dataWindowDirectionalMove
float lastClosedPLTicks = dataWindowPLTicks
string lastClosedSide = lastClosedDir == 1 ? "LONG" : lastClosedDir == -1 ? "SHORT" : "--"
string maxHoldDisplay = maxBarsInTrade > 0 ? str.tostring(maxBarsInTrade) + "B" : "OFF"
string entryMethodDisplay = customEntryMode ? "CUSTOM " + customTradeDirection + " @ " + f_price(customEntryPrice) : "STRAT"
string stopMethodDisplay = stopMethod == "Custom ticks" ? str.tostring(customStopTicks) + "t CUSTOM" : stopMethod == "Custom price" ? "PRICE " + f_price(customStopPrice) : "STRUCTURE"
string targetMethodDisplay = targetMethod == "Custom ticks" ? str.tostring(customTakeProfitTicks) + "t CUSTOM" : targetMethod == "Custom price" ? "PRICE " + f_price(customTakeProfitPrice) : targetMethod == "Structured objective" ? "STRUCT " + targetHTF : targetRChoice
string structuredUpDisplay = not enableStructuredObjectives ? "UP --" : na(structuredUpTarget) ? "UP --" : "UP OBJ " + f_price(structuredUpTarget) + " " + structuredUpSource
string structuredDownDisplay = not enableStructuredObjectives ? "DN --" : na(structuredDownTarget) ? "DN --" : "DN OBJ " + f_price(structuredDownTarget) + " " + structuredDownSource

// IMPORTANT: Use ONE table only. Pine tables are anchored by screen position;
// creating separate Desktop and Mobile tables at the same position can cause
// the later-created table to cover the other even when its cells are cleared.
// The dashboard mode is an input, so changing Desktop/Mobile reloads the script
// and safely recreates this table with the correct dimensions.
int dashRows = mobileDash ? 8 : (showDesktopLowerDetails ? (showTradeOutcomeStats ? 14 : 12) : 7)
var table dash = table.new(f_position(dashboardPos), mobileDash ? 4 : 8, dashRows, frame_color=color.new(color.white, 70), frame_width=1, border_color=color.new(color.white, 84), border_width=1)

if barstate.isfirst
    if not mobileDash
        // Desktop merges.
        table.merge_cells(dash, 0, 0, 7, 0)
        table.merge_cells(dash, 1, 1, 5, 1)
        table.merge_cells(dash, 1, 2, 5, 2)
        table.merge_cells(dash, 1, 4, 7, 4)
        table.merge_cells(dash, 1, 5, 7, 5)
        table.merge_cells(dash, 1, 6, 7, 6)
    else
        // Mobile merges. Four columns keep the footprint phone-friendly.
        table.merge_cells(dash, 0, 0, 3, 0)
        table.merge_cells(dash, 1, 1, 3, 1)
        table.merge_cells(dash, 1, 3, 3, 3)
        table.merge_cells(dash, 1, 4, 3, 4)
        table.merge_cells(dash, 1, 5, 3, 5)

if barstate.islast
    if showDashboard and not mobileDash

        // 0 - Title
        f_cell(dash, 0, 0, "THESTRAT COMMAND CENTER  |  " + syminfo.ticker + "  |  " + timeframe.period, C_HEADER, C_TEXT, dashTextSize)

        // 1 - Active Now
        f_cell(dash, 0, 1, "ACTIVE NOW", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 1, activeDisplay, activeNowColor, C_TEXT, dashTextSize)
        f_cell(dash, 6, 1, showLiveBarType ? "LIVE " + liveType : "LIVE --", liveType == "2U" ? C_BULL : liveType == "2D" ? C_BEAR : liveType == "3" ? C_WARN : C_NEUTRAL, C_TEXT, dashTextSize)
        f_cell(dash, 7, 1, f_price(close), C_HEADER, C_TEXT, dashTextSize)

        // 2 - Reversal Available
        f_cell(dash, 0, 2, "REVERSAL AVAILABLE", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 2, reversalDisplay, reversalColor, C_TEXT, dashTextSize)
        f_cell(dash, 6, 2, lastTypeDesc, C_HEADER, C_MUTED, dashTextSize)
        f_cell(dash, 7, 2, priceVsDayOpen, priceVsDayOpenColor, C_TEXT, dashTextSize)

        // 3 - Compact FTFC strip
        f_cell(dash, 0, 3, "FTFC", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 3, f_desktopFtfcLabel(tf1, reqTf1, s1), f_stateColor(s1), C_TEXT, dashTextSize)
        f_cell(dash, 2, 3, f_desktopFtfcLabel(tf2, reqTf2, s2), f_stateColor(s2), C_TEXT, dashTextSize)
        f_cell(dash, 3, 3, f_desktopFtfcLabel(tf3, reqTf3, s3), f_stateColor(s3), C_TEXT, dashTextSize)
        f_cell(dash, 4, 3, f_desktopFtfcLabel(tf4, reqTf4, s4), f_stateColor(s4), C_TEXT, dashTextSize)
        f_cell(dash, 5, 3, f_desktopFtfcLabel(tf5, reqTf5, s5), f_stateColor(s5), C_TEXT, dashTextSize)
        f_cell(dash, 6, 3, f_desktopFtfcLabel(tf6, reqTf6, s6), f_stateColor(s6), C_TEXT, dashTextSize)
        f_cell(dash, 7, 3, ftfcStatusShort, ftfcColor, C_TEXT, dashTextSize)

        // 4 - Best structural play
        f_cell(dash, 0, 4, "BEST STRUCTURAL PLAY", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 4, bestDisplay, bestDisplayColor, C_TEXT, dashTextSize)

        // 5 - Upside possible play
        f_cell(dash, 0, 5, "UPSIDE", color.new(longLineColor, tableTransparency), C_TEXT, dashTextSize)
        f_cell(dash, 1, 5, upDisplay, C_BG, upContextColor == C_WARN ? warningInput : C_TEXT, dashTextSize)

        // 6 - Downside possible play
        f_cell(dash, 0, 6, "DOWNSIDE", color.new(shortLineColor, tableTransparency), C_TEXT, dashTextSize)
        f_cell(dash, 1, 6, downDisplay, C_BG, downContextColor == C_WARN ? warningInput : C_TEXT, dashTextSize)

        if showDesktopLowerDetails
            // 7 - Key levels
            f_cell(dash, 0, 7, "LEVELS", C_SUBHEAD, C_TEXT, dashTextSize)
            f_cell(dash, 1, 7, setupHighLabel, C_HEADER, C_MUTED, dashTextSize)
            f_cell(dash, 2, 7, f_price(displaySetupHigh), C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 3, 7, setupLowLabel, C_HEADER, C_MUTED, dashTextSize)
            f_cell(dash, 4, 7, f_price(displaySetupLow), C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 5, 7, referenceSessionLabel + "\nOPEN", C_HEADER, C_MUTED, dashTextSize)
            f_cell(dash, 6, 7, f_price(dayOpen), C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 7, 7, "ENTRY / TARGET / STOP / HOLD\n" + entryMethodDisplay + " / " + targetMethodDisplay + " / " + stopMethodDisplay + " / " + maxHoldDisplay, C_HEADER, C_MUTED, dashTextSize)

            // 8 - Previous session / distance / recent range
            f_cell(dash, 0, 8, "OBJECTIVES", C_SUBHEAD, C_TEXT, dashTextSize)
            f_cell(dash, 1, 8, "PREV SESSION H\n" + f_price(pdh), C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 2, 8, "PREV SESSION L\n" + f_price(pdl), C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 3, 8, upDistanceLabel + "\n" + upDistanceValue, C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 4, 8, downDistanceLabel + "\n" + downDistanceValue, C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 5, 8, "RH " + f_price(recentHigh), C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 6, 8, "RL " + f_price(recentLow), C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 7, 8, "LOOKBACK " + str.tostring(targetLookback), C_BG, C_MUTED, dashTextSize)

            // 9 - Structured objective targeting. TheStrat BF range is shown first;
            // FVG/swing information remains supporting target context.
            f_cell(dash, 0, 9, "STRUCTURED", C_SUBHEAD, C_TEXT, dashTextSize)
            string structuredModeText = not enableStructuredObjectives ? "MODULE OFF" : enableBfObjectives and enableFvgObjectives ? "BF ON | FVG ON" : enableBfObjectives ? "BF ON | FVG OFF" : enableFvgObjectives ? "BF OFF | FVG ON" : "BF OFF | FVG OFF"
            f_cell(dash, 1, 9, structuredModeText + (enableStructuredObjectives and enableBfObjectives ? "\n" + f_mobileTfLabel(bfTargetHTF) + " " + bfStructureType : ""), C_BG, enableStructuredObjectives ? C_TEXT : C_MUTED, dashTextSize)
            f_cell(dash, 2, 9, enableStructuredObjectives and enableBfObjectives ? "BF H " + f_price(bfHigh) : "BF H --", C_BG, enableStructuredObjectives and enableBfObjectives ? structuredBfHighColor : C_MUTED, dashTextSize)
            f_cell(dash, 3, 9, enableStructuredObjectives and enableBfObjectives ? "BF L " + f_price(bfLow) : "BF L --", C_BG, enableStructuredObjectives and enableBfObjectives ? structuredBfLowColor : C_MUTED, dashTextSize)
            f_cell(dash, 4, 9, enableStructuredObjectives and enableBfObjectives ? "MID " + f_price(bfMid) : "MID --", C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 5, 9, structuredUpDisplay, C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 6, 9, structuredDownDisplay, C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 7, 9, enableStructuredObjectives and enableBfObjectives ? "BF 50/70 " + f_price(structuredZoneBot) + " - " + f_price(structuredZoneTop) : "BF 50/70 --", C_BG, C_MUTED, dashTextSize)

            // 10 - Operating rule
            f_cell(dash, 0, 10, "RULE", C_SUBHEAD, C_TEXT, dashTextSize)
            f_cell(dash, 1, 10, customEntryMode ? "Custom trade = user levels" : (compactDash ? "Prior closed bar" : "Setup = prior CLOSED candle"), C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 2, 10, tradeActive ? "Trade setup frozen" : "Current setup H/L", C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 3, 10, referenceSessionLabel + " session", C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 4, 10, compactDash ? "R = result/risk" : "R result = P/L ÷ initial stop risk", C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 5, 10, targetMethod == "Structured objective" ? "TP = structured objective" : (compactDash ? "Short stubs" : "Lines = short stubs"), C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 6, 10, compactDash ? "TP/S delete" : "TP/Stop -> lines delete", C_BG, C_MUTED, dashTextSize)
            f_cell(dash, 7, 10, maxBarsInTrade > 0 ? "TIME EXIT " + str.tostring(maxBarsInTrade) + "B" : (ftfcFilterActive ? "FTFC FILTER ON | REQ " + str.tostring(requiredCount) : (compactDash ? "TP/Stop managed" : "Managed until TP/Stop")), C_BG, maxBarsInTrade > 0 or ftfcFilterActive ? C_TEXT : C_MUTED, dashTextSize)

            // 11 - Next action
            string nextText = tradeActive ? "MANAGE ACTIVE " + (tradeDir == 1 ? "LONG" : "SHORT") + " | NEXT SETUP STILL SCANNED" : customEntryMode ? (customConfigKey == lastCompletedCustomKey ? "CUSTOM TRADE COMPLETE | INCREMENT TICKET TO RE-ARM" : "CUSTOM TRADE ARMED FROM NEXT BAR") : lastType == "1" ? "1 BAR: WAIT FOR BREAK" : lastType == "3" ? "3 BAR: WAIT FOR RESOLUTION" : "WATCH REVERSAL VS CONTINUATION"
            string nextUpText = customEntryMode and not customLongMode ? "UP --" : (tradeActive ? "NEXT UP " : "UP ") + f_price(effectiveUpEntry)
            string nextDownText = customEntryMode and not customShortMode ? "DN --" : (tradeActive ? "NEXT DN " : "DN ") + f_price(effectiveDownEntry)
            f_cell(dash, 0, 11, "NEXT", C_SUBHEAD, C_TEXT, dashTextSize)
            f_cell(dash, 1, 11, nextText, C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 2, 11, nextUpText, C_BG, longLineColor, dashTextSize)
            f_cell(dash, 3, 11, nextDownText, C_BG, shortLineColor, dashTextSize)
            f_cell(dash, 4, 11, ftfcStatusShort, ftfcColor, C_TEXT, dashTextSize)
            f_cell(dash, 5, 11, "LIVE " + liveType, C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 6, 11, "PRICE " + f_price(close), C_BG, C_TEXT, dashTextSize)
            f_cell(dash, 7, 11, priceVsDayOpen, priceVsDayOpenColor, C_TEXT, dashTextSize)

            if showTradeOutcomeStats
                // 12 - Last deterministic closed trade
                f_cell(dash, 0, 12, "LAST CLOSED", C_SUBHEAD, C_TEXT, dashTextSize)
                f_cell(dash, 1, 12, lastClosedReason == "" ? "--" : lastClosedReason, C_BG, C_TEXT, dashTextSize)
                f_cell(dash, 2, 12, lastClosedSide, C_BG, C_MUTED, dashTextSize)
                f_cell(dash, 3, 12, "E " + f_price(lastClosedEntry), C_BG, C_MUTED, dashTextSize)
                f_cell(dash, 4, 12, "X " + f_price(lastClosedExit), C_BG, C_MUTED, dashTextSize)
                f_cell(dash, 5, 12, f_r(lastClosedR), C_BG, na(lastClosedR) ? C_MUTED : lastClosedR > 0 ? bullInput : lastClosedR < 0 ? bearInput : C_TEXT, dashTextSize)
                f_cell(dash, 6, 12, (na(lastClosedPLTicks) ? "P/L --" : "P/L " + str.tostring(math.round(lastClosedPLTicks)) + "t") + (na(lastClosedBars) ? " | B --" : " | B " + str.tostring(lastClosedBars)), C_BG, C_MUTED, dashTextSize)
                f_cell(dash, 7, 12, "CLOSED " + str.tostring(closedTradeCount), C_BG, C_MUTED, dashTextSize)

                // 13 - Outcome buckets
                f_cell(dash, 0, 13, "OUTCOME BUCKETS", C_SUBHEAD, C_TEXT, dashTextSize)
                f_cell(dash, 1, 13, "TP " + str.tostring(targetExitCount), C_BG, bullInput, dashTextSize)
                f_cell(dash, 2, 13, "STOP " + str.tostring(stopExitCount), C_BG, bearInput, dashTextSize)
                f_cell(dash, 3, 13, "TIME+ " + str.tostring(timeWinCount), C_BG, bullInput, dashTextSize)
                f_cell(dash, 4, 13, "TIME- " + str.tostring(timeLossCount), C_BG, bearInput, dashTextSize)
                f_cell(dash, 5, 13, "TIME0 " + str.tostring(timeFlatCount), C_BG, C_MUTED, dashTextSize)
                f_cell(dash, 6, 13, "TIME AVG " + f_r(avgTimeR), C_BG, C_MUTED, dashTextSize)
                f_cell(dash, 7, 13, "ALL AVG " + f_r(avgClosedR) + (ambiguousExitCount > 0 ? " | AMB " + str.tostring(ambiguousExitCount) : ""), C_BG, C_MUTED, dashTextSize)

    else if showDashboard and mobileDash
        // 0 - Phone title
        f_cell(dash, 0, 0, "STRAT CC  |  " + syminfo.ticker + "  |  " + timeframe.period, C_HEADER, C_TEXT, dashTextSize)

        // 1 - Active / management state. Active trades include E / S / TP here.
        f_cell(dash, 0, 1, "ACTIVE", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 1, activeDisplay, activeNowColor, C_TEXT, dashTextSize)

        // 2 - FTFC in two compact groups plus the binary overall FTFC state.
        f_cell(dash, 0, 2, "FTFC\n[ ] = REQ", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 2, mobileFtfcA, C_BG, C_TEXT, dashTextSize)
        f_cell(dash, 2, 2, mobileFtfcB, C_BG, C_TEXT, dashTextSize)
        f_cell(dash, 3, 2, ftfcStatusShort, ftfcColor, C_TEXT, dashTextSize)

        // 3 - Best structural play.
        f_cell(dash, 0, 3, "BEST", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 3, bestDisplay, bestDisplayColor, C_TEXT, dashTextSize)

        // 4/5 - Both directions remain visible, including FTFC/counter-FTFC context.
        f_cell(dash, 0, 4, "UP", color.new(longLineColor, tableTransparency), C_TEXT, dashTextSize)
        f_cell(dash, 1, 4, mobileUpDisplay, C_BG, upContextColor == C_WARN ? warningInput : C_TEXT, dashTextSize)
        f_cell(dash, 0, 5, "DN", color.new(shortLineColor, tableTransparency), C_TEXT, dashTextSize)
        f_cell(dash, 1, 5, mobileDownDisplay, C_BG, downContextColor == C_WARN ? warningInput : C_TEXT, dashTextSize)

        // 6 - Essential setup levels plus user-defined TP/Stop and max hold.
        f_cell(dash, 0, 6, "LEVELS", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 6, "H\n" + f_price(displaySetupHigh), C_BG, C_TEXT, dashTextSize)
        f_cell(dash, 2, 6, "L\n" + f_price(displaySetupLow), C_BG, C_TEXT, dashTextSize)
        f_cell(dash, 3, 6, "ENTRY / TARGET / STOP / HOLD\n" + entryMethodDisplay + " / " + targetMethodDisplay + " / " + stopMethodDisplay + " / " + maxHoldDisplay, C_HEADER, C_MUTED, dashTextSize)

        // 7 - Exact next trigger prices plus session-open location.
        f_cell(dash, 0, 7, "NEXT", C_SUBHEAD, C_TEXT, dashTextSize)
        f_cell(dash, 1, 7, "UP\n" + f_price(effectiveUpEntry), C_BG, longLineColor, dashTextSize)
        f_cell(dash, 2, 7, "DN\n" + f_price(effectiveDownEntry), C_BG, shortLineColor, dashTextSize)
        f_cell(dash, 3, 7, mobileSessionStatus, priceVsDayOpenColor, C_TEXT, dashTextSize)

    else
        if mobileDash
            table.clear(dash, 0, 0, 3, 7)
        else
            table.clear(dash, 0, 0, 7, showDesktopLowerDetails ? (showTradeOutcomeStats ? 13 : 11) : 6)
//This is the end of the code.
````
