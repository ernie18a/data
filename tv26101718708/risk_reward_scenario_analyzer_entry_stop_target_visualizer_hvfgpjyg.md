# Risk Reward Scenario Analyzer - Entry Stop Target Visualizer

- url: https://www.tradingview.com/script/hVFgpjYG-Risk-Reward-Scenario-Analyzer-Entry-Stop-Target-Visualizer/
- type: indicator
- pine_id: PUB;4f1474a06c56439fb5ba56a0a0cd02d1
- version: 1.0

## Description

Overview

Risk Reward Scenario Analyzer is an interactive trade-planning and scenario-research indicator for manually defined Entry, Stop and Target levels.

The script does not generate a market-direction signal, select an entry, recommend a stop, or predict a target. The user defines the trade geometry. The indicator then measures the planned reward-to-risk multiple, stress-tests that multiple against entry-price drift, and audits whether the Stop or Target was reached first under explicit confirmed-OHLC rules.

The implementation is centered on three connected research tasks:

1. Entry execution drift testing
2. Confirmed-OHLC first-touch auditing
3. Consecutive testing of multiple hypothetical scenarios

This combination is the main reason the script exists as a separate publication rather than as a basic risk/reward box.

Interactive trade plan

The user places four interactive values directly on the chart:

- Entry
- Anchor time
- Stop loss
- Take-profit target

The Entry and Anchor form one interactive chart point. Stop and Target can be repositioned independently.

Direction can be selected manually or derived from the geometry:

Long:
Stop < Entry < Target

Short:
Target < Entry < Stop

Invalid geometry remains visible for correction and is not processed as a valid scenario.

Two activation methods are available:

Assume filled at anchor:
The research scenario begins from the selected anchor.

Wait for entry touch:
The scenario activates only after a confirmed chart bar trades through the selected Entry. Exit evaluation begins on the following confirmed bar because chart OHLC cannot prove whether the Entry, Stop or Target occurred first inside the activation bar.

Planned R multiple

The basic calculations are:

Planned risk distance =
Absolute value of Entry - Stop

Planned reward distance =
Absolute value of Target - Entry

Gross R multiple =
Planned reward distance / Planned risk distance

The displayed gross break-even win rate is:

100 / (1 + Gross R)

This is a mathematical break-even threshold derived from the selected reward-to-risk relationship. It is not a prediction of the strategy's actual win rate.

Entry execution stress test

A planned R multiple can deteriorate when the actual entry is less favorable than the intended entry.

The Entry execution tolerance model keeps the selected Stop and Target fixed, then shifts the Entry in both directions.

The tolerance distance can be defined as:

- A percentage of the planned risk distance
- A number of minimum ticks
- A fraction of ATR captured at the anchor

For a Long scenario, the adverse entry is above the planned Entry and the favorable entry is below it.

For a Short scenario, the adverse entry is below the planned Entry and the favorable entry is above it.

The script calculates:

- Adverse entry R
- Favorable entry R
- Retained R percentage
- Low, Moderate or High R erosion

Retained R is calculated as:

Adverse entry R / Planned R x 100

This section is a sensitivity test. It does not predict spread, slippage or the price at which an order will actually be filled.

Confirmed-OHLC first-touch audit

After activation, the script audits whether the Stop or Target was reached first.

Terminal outcomes are evaluated from confirmed chart bars. The activation bar is excluded from exit evaluation because its intrabar sequence is unavailable from OHLC data alone.

The outcome states are:

- Target
- Stop
- Ambiguous
- Expired
- Active
- Waiting for entry
- Invalid

Gap opens are evaluated at the opening price before the normal high-low touch logic is applied.

If a confirmed bar touches both Stop and Target and the opening price did not already resolve the sequence, chart OHLC cannot reveal which level occurred first.

The default same-bar policy is:

Mark ambiguous

Two optional research assumptions are also available:

- Assume stop first
- Assume target first

These alternatives are explicit user-selected assumptions. They are not presented as reconstructed intrabar facts.

The scenario becomes Expired when the selected research horizon ends before Stop or Target is resolved.

Standard candlestick charts are recommended. Heikin Ashi, Renko, Kagi, Line Break, Point and Figure and other non-standard chart types can contain synthetic OHLC values. The panel identifies non-standard chart data as synthetic.

MFE, MAE and live progress

After activation, the script tracks:

- Maximum favorable excursion in R
- Maximum adverse excursion in R
- Current or terminal R
- Elapsed bars
- Research horizon

The activation bar is excluded from MFE and MAE for the same intrabar-order reason used by the first-touch audit.

Current R can change while the realtime bar is open. Target, Stop, Ambiguous and Expired outcomes are finalized from confirmed bars.

Risk budget, quantity and execution costs

The risk budget can be entered as:

- A percentage of account size
- A fixed cash amount

Cash conversion can use the symbol's point value or a manually entered point value.

Optional execution-cost assumptions include:

- Round-trip cash cost per unit
- Slippage in minimum ticks per side

Modeled loss per unit is:

Price risk per unit + Modeled execution costs

Modeled win per unit is:

Price reward per unit - Modeled execution costs

Raw quantity is:

Risk budget / Modeled loss per unit

The result is rounded down to the selected quantity step.

When costs are enabled, the script also calculates:

- Cost-adjusted R
- Cost-adjusted break-even win rate
- Modeled cash loss at Stop
- Modeled cash result at Target

The modeled quantity is an arithmetic research result. It is not a recommended, optimal or safe order size.

Point values, contract multipliers, lot conventions, commissions and margin requirements can differ by broker, exchange and instrument. Users must verify the applicable contract specifications independently.

Visual workflow

The main chart display includes:

- Reward area
- Risk area
- Entry execution tolerance band
- Entry, Stop and Target references
- Live or terminal R marker
- Compact scenario readout

The readout is intentionally limited to the information most relevant to reviewing the current scenario:

- Direction and state
- Planned or cost-adjusted R
- Mathematical break-even threshold
- Adverse entry R and retained R
- Risk budget and modeled quantity
- Modeled Stop and Target cash outcomes
- Current or terminal R
- Elapsed bars and research horizon

After a scenario resolves, the visual workflow can:

- Keep the full scenario
- Compact the result
- Clear completed visuals

Moving Entry, Anchor, Stop or Target causes Pine to recalculate the scenario from the selected inputs. A completely new placement can be started with TradingView's Reset points command.

This behavior is intended for rapid comparison of several user-defined trade hypotheses. Previous scenarios are not stored as a permanent trade journal.

Alerts

The script provides factual alert conditions for:

- Scenario activation
- Target reached first
- Stop reached first
- Ambiguous same-bar outcome
- Research horizon expiry

Users must create the desired alerts separately through TradingView's alert dialog.

Calculation behavior

The script does not use future data, lookahead or higher-timeframe data requests.

Changing an interactive point or any other input causes the available chart history to be recalculated using the new settings. This is normal input-driven Pine behavior and should not be interpreted as a persistent record of an earlier scenario.

Limitations

- Entry, Stop, Target, account values and cost assumptions are entered manually.
- The script does not identify or recommend a trade setup.
- It does not predict market direction.
- It does not read brokerage positions or Trading Panel account data.
- It does not place, modify or close orders.
- It does not reconstruct tick-by-tick movement inside historical bars.
- Same-bar Stop and Target order is unknowable from OHLC alone.
- Gap handling at the bar open is a research model, not a guaranteed fill model.
- Actual fees, spread, slippage and execution prices can differ from the entered assumptions.
- Point value can differ by broker, exchange and contract specification.
- Currency conversion, taxes, funding changes and margin requirements are not calculated automatically.
- Non-standard chart prices may not represent executable market prices.
- Results depend on the accuracy of the user's inputs.
- The script is a scenario visualization and research tool, not financial advice or a trade recommendation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©SG Group

//@version=6
indicator(
     "Risk Reward Scenario Analyzer - Entry Stop Target Visualizer",
     overlay = true,
     behind_chart = false,
     max_boxes_count = 10,
     max_lines_count = 20,
     max_labels_count = 20)

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------
const string GROUP_WORKFLOW = "1. Quick next-scenario workflow"
const string GROUP_PLAN     = "2. Interactive trade plan"
const string GROUP_RESEARCH = "3. Scenario research"
const string GROUP_RISK     = "4. Risk budget and execution costs"
const string GROUP_VISUALS  = "5. Visual design"
const string GROUP_PANEL    = "6. Scenario readout"

const int STATUS_BEFORE_ANCHOR = 0
const int STATUS_WAITING_ENTRY = 1
const int STATUS_ACTIVE        = 2
const int STATUS_TARGET        = 3
const int STATUS_STOP          = 4
const int STATUS_AMBIGUOUS     = 5
const int STATUS_EXPIRED       = 6
const int STATUS_INVALID       = 7

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string completedVisualModeInput = input.string(
     "Compact result",
     "After a scenario resolves",
     options = ["Keep full scenario", "Compact result", "Clear completed visuals"],
     group = GROUP_WORKFLOW,
     tooltip = "Keep full scenario preserves every box and level. Compact result automatically removes the completed plan and leaves only a lightweight result marker. Clear completed visuals removes the completed plan and result marker; the optional next-scenario cue and numerical readout remain. Move any interactive point to calculate a fresh scenario. For complete re-placement, use the script's More (...) menu and select Reset points.",
     display = display.none)

bool showNextScenarioCueInput = input.bool(
     true,
     "Show next-scenario cue",
     group = GROUP_WORKFLOW,
     tooltip = "After a scenario resolves, shows a small action cue near the latest bar and a footer in the readout. The cue is informational because Pine scripts cannot receive clicks from labels or tables.",
     display = display.none)

float entryPriceInput = input.price(
     0.0,
     "Entry",
     inline = "entryAnchor",
     group = GROUP_PLAN,
     confirm = true,
     display = display.none)

int anchorTimeInput = input.time(
     0,
     "Anchor",
     inline = "entryAnchor",
     group = GROUP_PLAN,
     confirm = true,
     tooltip = "Place the entry/anchor point on the chart. The scenario begins from the first chart bar at or after this time.",
     display = display.none)

float stopPriceInput = input.price(
     0.0,
     "Stop loss",
     group = GROUP_PLAN,
     confirm = true,
     tooltip = "Place the assumed stop-loss price. Drag its chart marker later to test alternatives.",
     display = display.none)

float targetPriceInput = input.price(
     0.0,
     "Take-profit target",
     group = GROUP_PLAN,
     confirm = true,
     tooltip = "Place the assumed take-profit price. Drag its chart marker later to test alternatives.",
     display = display.none)

string directionInput = input.string(
     "Auto from geometry",
     "Direction",
     options = ["Auto from geometry", "Long", "Short"],
     group = GROUP_PLAN,
     tooltip = "Auto recognizes a long plan when Stop < Entry < Target, and a short plan when Target < Entry < Stop.",
     display = display.none)

string activationInput = input.string(
     "Assume filled at anchor",
     "Activation",
     options = ["Assume filled at anchor", "Wait for entry touch"],
     group = GROUP_RESEARCH,
     tooltip = "Assume filled at anchor starts the study immediately. Wait for entry touch activates only after a confirmed chart bar trades through the entry price. Exit evaluation begins on the following confirmed bar to avoid inventing the price sequence inside the activation bar.",
     display = display.none)

int horizonBarsInput = input.int(
     50,
     "Research horizon (bars)",
     minval = 1,
     maxval = 500,
     group = GROUP_RESEARCH,
     tooltip = "Maximum number of chart bars after the anchor used for first-touch outcome tracking. Until future bars exist, the visual endpoint is projected from the chart timeframe and later resolves to actual bar times.",
     display = display.none)

string sameBarPolicyInput = input.string(
     "Mark ambiguous",
     "When stop and target are touched in one bar",
     options = ["Mark ambiguous", "Assume stop first", "Assume target first"],
     group = GROUP_RESEARCH,
     tooltip = "Chart OHLC does not reveal the intrabar path. Mark ambiguous is the transparent default. Gap opens beyond one level are resolved at the open before this policy is applied.",
     display = display.none)

int atrLengthInput = input.int(
     14,
     "ATR length",
     minval = 1,
     maxval = 500,
     group = GROUP_RESEARCH,
     tooltip = "Used only to express stop and target distances in ATR units at the anchor. It does not generate levels or signals.",
     display = display.none)

float minimumRInput = input.float(
     1.0,
     "Personal minimum R multiple",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     group = GROUP_RESEARCH,
     tooltip = "A user-defined comparison threshold. It is not a recommendation or performance score.",
     display = display.none)

float preferredRInput = input.float(
     2.0,
     "Personal preferred R multiple",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     group = GROUP_RESEARCH,
     tooltip = "A second user-defined comparison threshold for the readout. It does not predict trade quality.",
     display = display.none)

string entryToleranceModeInput = input.string(
     "Percent of planned risk",
     "Entry execution tolerance mode",
     options = ["Percent of planned risk", "Ticks", "ATR fraction"],
     group = GROUP_RESEARCH,
     tooltip = "Stress-tests the planned R multiple against a favorable and adverse entry-price deviation while keeping the selected stop and target fixed.",
     display = display.none)

float entryToleranceRiskPercentInput = input.float(
     5.0,
     "Tolerance (% of planned risk)",
     minval = 0.0,
     maxval = 100.0,
     step = 0.5,
     group = GROUP_RESEARCH,
     active = entryToleranceModeInput == "Percent of planned risk",
     display = display.none)

float entryToleranceTicksInput = input.float(
     2.0,
     "Tolerance (ticks)",
     minval = 0.0,
     maxval = 1000000.0,
     step = 0.1,
     group = GROUP_RESEARCH,
     active = entryToleranceModeInput == "Ticks",
     display = display.none)

float entryToleranceAtrFractionInput = input.float(
     0.05,
     "Tolerance (ATR fraction)",
     minval = 0.0,
     maxval = 10.0,
     step = 0.01,
     group = GROUP_RESEARCH,
     active = entryToleranceModeInput == "ATR fraction",
     tooltip = "Uses the ATR captured at the anchor. For example, 0.05 represents five percent of anchor ATR.",
     display = display.none)

string riskModeInput = input.string(
     "Percent of account",
     "Risk budget mode",
     options = ["Percent of account", "Fixed cash amount"],
     group = GROUP_RISK,
     display = display.none)

float accountSizeInput = input.float(
     10000.0,
     "Account size",
     minval = 0.0,
     step = 100.0,
     group = GROUP_RISK,
     active = riskModeInput == "Percent of account",
     display = display.none)

float accountRiskPercentInput = input.float(
     1.0,
     "Account risk (%)",
     minval = 0.0,
     maxval = 100.0,
     step = 0.1,
     group = GROUP_RISK,
     active = riskModeInput == "Percent of account",
     display = display.none)

float fixedRiskCashInput = input.float(
     100.0,
     "Fixed risk amount",
     minval = 0.0,
     step = 1.0,
     group = GROUP_RISK,
     active = riskModeInput == "Fixed cash amount",
     display = display.none)

string accountCurrencyInput = input.string(
     "USD",
     "Account currency label",
     group = GROUP_RISK,
     tooltip = "Display label only. Pine does not convert currencies in this script.",
     display = display.none)

string pointValueModeInput = input.string(
     "Symbol point value",
     "Value per 1.0 price point",
     options = ["Symbol point value", "Custom point value"],
     group = GROUP_RISK,
     tooltip = "Symbol point value uses syminfo.pointvalue. Select Custom when the chart symbol or broker contract requires a different monetary value per one full price point per unit.",
     display = display.none)

float customPointValueInput = input.float(
     1.0,
     "Custom point value",
     minval = 0.00000001,
     step = 0.01,
     group = GROUP_RISK,
     active = pointValueModeInput == "Custom point value",
     display = display.none)

bool includeCostsInput = input.bool(
     false,
     "Include estimated costs",
     group = GROUP_RISK,
     tooltip = "Adds the user-entered round-trip cost and slippage estimate to quantity sizing and break-even win-rate math.",
     display = display.none)

float roundTripCostPerUnitInput = input.float(
     0.0,
     "Round-trip cash cost per unit",
     minval = 0.0,
     step = 0.01,
     group = GROUP_RISK,
     active = includeCostsInput,
     tooltip = "Total commission and fee estimate for opening and closing one unit, expressed in the account currency.",
     display = display.none)

float slippageTicksPerSideInput = input.float(
     0.0,
     "Slippage ticks per side",
     minval = 0.0,
     step = 0.1,
     group = GROUP_RISK,
     active = includeCostsInput,
     tooltip = "Estimated adverse slippage in minimum ticks for entry and again for exit.",
     display = display.none)

float quantityStepInput = input.float(
     1.0,
     "Quantity step",
     minval = 0.00000001,
     step = 0.01,
     group = GROUP_RISK,
     tooltip = "Calculated quantity is rounded down to this increment.",
     display = display.none)

bool showBoxesInput = input.bool(true, "Show risk and reward boxes", group = GROUP_VISUALS, display = display.none)
bool showEntryToleranceBandInput = input.bool(true, "Show entry execution tolerance band", group = GROUP_VISUALS, display = display.none)
bool showBoxTextInput = input.bool(true, "Show box text", group = GROUP_VISUALS, display = display.none)
bool showPriceLabelsInput = input.bool(true, "Show entry / stop / target labels", group = GROUP_VISUALS, display = display.none)
bool showLiveMarkerInput = input.bool(true, "Show live or terminal R marker", group = GROUP_VISUALS, display = display.none)

int boxTransparencyInput = input.int(
     80,
     "Box transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_VISUALS,
     display = display.none)

int lineWidthInput = input.int(
     2,
     "Level line width",
     minval = 1,
     maxval = 5,
     group = GROUP_VISUALS,
     display = display.none)

color rewardColorInput = input.color(color.rgb(0, 224, 140), "Reward", inline = "colors1", group = GROUP_VISUALS, display = display.none)
color riskColorInput = input.color(color.rgb(255, 74, 96), "Risk", inline = "colors1", group = GROUP_VISUALS, display = display.none)
color entryColorInput = input.color(color.rgb(45, 205, 255), "Entry", inline = "colors2", group = GROUP_VISUALS, display = display.none)
color neutralColorInput = input.color(color.rgb(255, 196, 70), "Neutral", inline = "colors2", group = GROUP_VISUALS, display = display.none)
color toleranceColorInput = input.color(color.rgb(190, 105, 255), "Tolerance", inline = "colors3", group = GROUP_VISUALS, display = display.none)
color textColorInput = input.color(color.rgb(245, 248, 255), "Text", inline = "colors3", group = GROUP_VISUALS, display = display.none)
color panelBackgroundInput = input.color(color.rgb(12, 17, 28), "Panel", group = GROUP_VISUALS, display = display.none)

bool showPanelInput = input.bool(true, "Show scenario readout", group = GROUP_PANEL, display = display.none)
string panelPositionInput = input.string(
     "Top right",
     "Readout position",
     options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"],
     group = GROUP_PANEL,
     display = display.none)

string panelSizeInput = input.string(
     "Small",
     "Readout text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_PANEL,
     display = display.none)

//------------------------------------------------------------------------------
// Utility functions
//------------------------------------------------------------------------------
f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_number(float value, string pattern) =>
    na(value) ? "n/a" : str.tostring(value, pattern)

f_r(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "R"

f_percent(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + "%"

f_cash(float value, string currencyLabel) =>
    na(value) ? "n/a" : str.tostring(value, "#.##") + " " + currencyLabel

f_signed_cash(float value, string currencyLabel) =>
    na(value) ? "n/a" : (value > 0.0 ? "+" : value < 0.0 ? "−" : "") + str.tostring(math.abs(value), "#.##") + " " + currencyLabel

f_contrast_text(color backgroundColor) =>
    float luminance = 0.2126 * color.r(backgroundColor) + 0.7152 * color.g(backgroundColor) + 0.0722 * color.b(backgroundColor)
    luminance > 127.5 ? color.rgb(4, 10, 18) : color.rgb(255, 255, 255)

f_r_at_entry(float candidateEntry, int planDirection, float stopLevel, float targetLevel) =>
    bool candidateValid = planDirection == 1 ? stopLevel < candidateEntry and candidateEntry < targetLevel : planDirection == -1 ? targetLevel < candidateEntry and candidateEntry < stopLevel : false
    candidateValid ? math.abs(targetLevel - candidateEntry) / math.abs(candidateEntry - stopLevel) : na

//------------------------------------------------------------------------------
// Plan geometry and static calculations
//------------------------------------------------------------------------------
bool longGeometry = stopPriceInput < entryPriceInput and entryPriceInput < targetPriceInput
bool shortGeometry = targetPriceInput < entryPriceInput and entryPriceInput < stopPriceInput

int direction = switch directionInput
    "Long"  => 1
    "Short" => -1
    => longGeometry ? 1 : shortGeometry ? -1 : 0

bool geometryValid = direction == 1 ? longGeometry : direction == -1 ? shortGeometry : false
string directionText = direction == 1 ? "Long" : direction == -1 ? "Short" : "Unresolved"

float riskDistance = math.abs(entryPriceInput - stopPriceInput)
float rewardDistance = math.abs(targetPriceInput - entryPriceInput)
float rewardRisk = geometryValid and riskDistance > 0.0 ? rewardDistance / riskDistance : na
float riskTicks = geometryValid and syminfo.mintick > 0.0 ? riskDistance / syminfo.mintick : na
float rewardTicks = geometryValid and syminfo.mintick > 0.0 ? rewardDistance / syminfo.mintick : na
float riskPercentOfPrice = geometryValid and entryPriceInput != 0.0 ? riskDistance / math.abs(entryPriceInput) * 100.0 : na
float rewardPercentOfPrice = geometryValid and entryPriceInput != 0.0 ? rewardDistance / math.abs(entryPriceInput) * 100.0 : na

float atrSeries = ta.atr(atrLengthInput)
int barEndTime = na(time_close) ? time : time_close

//------------------------------------------------------------------------------
// Anchor discovery and scenario state
//------------------------------------------------------------------------------
var int anchorBarIndex = na
var int anchorBarTime = na
var float anchorAtr = na
var int horizonBarCloseTime = na

if na(anchorBarIndex) and time >= anchorTimeInput
    anchorBarIndex := bar_index
    anchorBarTime := time
    anchorAtr := atrSeries

if not na(anchorBarIndex) and bar_index == anchorBarIndex + horizonBarsInput
    horizonBarCloseTime := barEndTime

float riskInAtr = geometryValid and not na(anchorAtr) and anchorAtr > 0.0 ? riskDistance / anchorAtr : na
float rewardInAtr = geometryValid and not na(anchorAtr) and anchorAtr > 0.0 ? rewardDistance / anchorAtr : na

float entryToleranceDistance = if not geometryValid
    na
else
    switch entryToleranceModeInput
        "Ticks"        => entryToleranceTicksInput * syminfo.mintick
        "ATR fraction" => not na(anchorAtr) ? entryToleranceAtrFractionInput * anchorAtr : na
        => entryToleranceRiskPercentInput / 100.0 * riskDistance

float adverseEntryPrice = not na(entryToleranceDistance) ? entryPriceInput + direction * entryToleranceDistance : na
float favorableEntryPrice = not na(entryToleranceDistance) ? entryPriceInput - direction * entryToleranceDistance : na
float adverseEntryR = f_r_at_entry(adverseEntryPrice, direction, stopPriceInput, targetPriceInput)
float favorableEntryR = f_r_at_entry(favorableEntryPrice, direction, stopPriceInput, targetPriceInput)
bool entryToleranceValid = not na(entryToleranceDistance) and not na(adverseEntryR) and not na(favorableEntryR)
float entryToleranceTicks = not na(entryToleranceDistance) and syminfo.mintick > 0.0 ? entryToleranceDistance / syminfo.mintick : na
float entryToleranceRiskPercent = not na(entryToleranceDistance) and riskDistance > 0.0 ? entryToleranceDistance / riskDistance * 100.0 : na
float retainedRPercent = entryToleranceValid and rewardRisk > 0.0 ? adverseEntryR / rewardRisk * 100.0 : na

var int scenarioStatus = STATUS_BEFORE_ANCHOR
var int activationBarIndex = na
var int activationBarTime = na
var int resolutionBarIndex = na
var int resolutionBarTime = na
var float resolutionPrice = na
var float maximumFavorableR = 0.0
var float maximumAdverseR = 0.0
var float terminalR = na
var bool expiredUnfilled = false
var string resolutionDetail = ""

bool targetEvent = false
bool stopEvent = false
bool ambiguousEvent = false
bool expiryEvent = false
bool activationEvent = false

if not geometryValid
    scenarioStatus := STATUS_INVALID
else if not na(anchorBarIndex)
    int barsFromAnchorNow = bar_index - anchorBarIndex
    bool insideHorizonNow = barsFromAnchorNow >= 0 and barsFromAnchorNow <= horizonBarsInput

    if scenarioStatus == STATUS_BEFORE_ANCHOR and barsFromAnchorNow >= 0
        if activationInput == "Assume filled at anchor"
            scenarioStatus := STATUS_ACTIVE
            activationBarIndex := anchorBarIndex
            activationBarTime := anchorBarTime
            activationEvent := barstate.isconfirmed
        else
            scenarioStatus := STATUS_WAITING_ENTRY

    if scenarioStatus == STATUS_WAITING_ENTRY and insideHorizonNow and barstate.isconfirmed
        bool entryTouchedNow = low <= entryPriceInput and high >= entryPriceInput
        if entryTouchedNow
            scenarioStatus := STATUS_ACTIVE
            activationBarIndex := bar_index
            activationBarTime := time
            activationEvent := true

    if scenarioStatus == STATUS_ACTIVE and insideHorizonNow and not na(activationBarIndex) and bar_index > activationBarIndex and barstate.isconfirmed
        bool targetTouchedNow = direction == 1 ? high >= targetPriceInput : low <= targetPriceInput
        bool stopTouchedNow = direction == 1 ? low <= stopPriceInput : high >= stopPriceInput
        bool targetGapNow = direction == 1 ? open >= targetPriceInput : open <= targetPriceInput
        bool stopGapNow = direction == 1 ? open <= stopPriceInput : open >= stopPriceInput

        int barOutcome = 0
        float barFillPrice = na
        string barOutcomeDetail = ""

        if targetGapNow and not stopGapNow
            barOutcome := STATUS_TARGET
            barFillPrice := open
            barOutcomeDetail := "Gap opened beyond target; modeled at bar open"
        else if stopGapNow and not targetGapNow
            barOutcome := STATUS_STOP
            barFillPrice := open
            barOutcomeDetail := "Gap opened beyond stop; modeled at bar open"
        else if targetTouchedNow and stopTouchedNow
            if sameBarPolicyInput == "Assume stop first"
                barOutcome := STATUS_STOP
                barFillPrice := stopPriceInput
                barOutcomeDetail := "Both touched; stop-first assumption"
            else if sameBarPolicyInput == "Assume target first"
                barOutcome := STATUS_TARGET
                barFillPrice := targetPriceInput
                barOutcomeDetail := "Both touched; target-first assumption"
            else
                barOutcome := STATUS_AMBIGUOUS
                barFillPrice := entryPriceInput
                barOutcomeDetail := "Both touched; intrabar order unknown"
        else if targetTouchedNow
            barOutcome := STATUS_TARGET
            barFillPrice := targetPriceInput
            barOutcomeDetail := "Target first"
        else if stopTouchedNow
            barOutcome := STATUS_STOP
            barFillPrice := stopPriceInput
            barOutcomeDetail := "Stop first"

        float favorableExcursionNow = direction == 1 ? (high - entryPriceInput) / riskDistance : (entryPriceInput - low) / riskDistance
        float adverseExcursionNow = direction == 1 ? (entryPriceInput - low) / riskDistance : (high - entryPriceInput) / riskDistance

        if barOutcome == 0
            maximumFavorableR := math.max(maximumFavorableR, math.max(0.0, favorableExcursionNow))
            maximumAdverseR := math.max(maximumAdverseR, math.max(0.0, adverseExcursionNow))
        else
            scenarioStatus := barOutcome
            resolutionBarIndex := bar_index
            resolutionBarTime := barEndTime
            resolutionPrice := barFillPrice
            resolutionDetail := barOutcomeDetail

            if barOutcome == STATUS_TARGET
                terminalR := direction * (barFillPrice - entryPriceInput) / riskDistance
                maximumFavorableR := math.max(maximumFavorableR, math.max(rewardRisk, terminalR))
                targetEvent := true
            else if barOutcome == STATUS_STOP
                terminalR := direction * (barFillPrice - entryPriceInput) / riskDistance
                maximumAdverseR := math.max(maximumAdverseR, math.max(1.0, -terminalR))
                stopEvent := true
            else
                maximumFavorableR := math.max(maximumFavorableR, rewardRisk)
                maximumAdverseR := math.max(maximumAdverseR, 1.0)
                terminalR := na
                ambiguousEvent := true

    if (scenarioStatus == STATUS_WAITING_ENTRY or scenarioStatus == STATUS_ACTIVE) and barsFromAnchorNow >= horizonBarsInput and barstate.isconfirmed
        bool activeAtExpiry = scenarioStatus == STATUS_ACTIVE
        scenarioStatus := STATUS_EXPIRED
        resolutionBarIndex := bar_index
        resolutionBarTime := barEndTime
        resolutionPrice := activeAtExpiry ? close : entryPriceInput
        expiredUnfilled := not activeAtExpiry
        resolutionDetail := activeAtExpiry ? "Horizon ended before either level" : "Entry was not touched within horizon"
        terminalR := activeAtExpiry ? direction * (close - entryPriceInput) / riskDistance : na
        expiryEvent := true

//------------------------------------------------------------------------------
// Risk budget, quantity and break-even calculations
//------------------------------------------------------------------------------
float riskBudget = riskModeInput == "Percent of account" ? accountSizeInput * accountRiskPercentInput / 100.0 : fixedRiskCashInput
float symbolPointValue = syminfo.pointvalue
float selectedPointValue = pointValueModeInput == "Symbol point value" ? symbolPointValue : customPointValueInput
bool pointValueValid = not na(selectedPointValue) and selectedPointValue > 0.0
float priceRiskPerUnit = geometryValid and pointValueValid ? riskDistance * selectedPointValue : na
float priceRewardPerUnit = geometryValid and pointValueValid ? rewardDistance * selectedPointValue : na
float slippageCashPerUnit = includeCostsInput ? slippageTicksPerSideInput * 2.0 * syminfo.mintick * selectedPointValue : 0.0
float explicitCashCostPerUnit = includeCostsInput ? roundTripCostPerUnitInput : 0.0
float totalCostPerUnit = slippageCashPerUnit + explicitCashCostPerUnit
float modeledLossPerUnit = geometryValid and pointValueValid ? priceRiskPerUnit + totalCostPerUnit : na
float modeledWinPerUnit = geometryValid and pointValueValid ? priceRewardPerUnit - totalCostPerUnit : na
float rawQuantity = geometryValid and not na(modeledLossPerUnit) and modeledLossPerUnit > 0.0 ? riskBudget / modeledLossPerUnit : na
float modeledQuantity = not na(rawQuantity) ? math.floor(rawQuantity / quantityStepInput) * quantityStepInput : na
float modeledGrossRewardCash = not na(modeledQuantity) ? modeledQuantity * priceRewardPerUnit : na
float modeledCostsCash = not na(modeledQuantity) ? modeledQuantity * totalCostPerUnit : na
float modeledNetWinCash = not na(modeledGrossRewardCash) ? modeledGrossRewardCash - modeledCostsCash : na
float modeledNetLossCash = not na(modeledQuantity) ? modeledQuantity * priceRiskPerUnit + modeledCostsCash : na
float grossBreakEvenWinRate = geometryValid and rewardRisk >= 0.0 ? 100.0 / (1.0 + rewardRisk) : na
float costAdjustedRewardRisk = includeCostsInput and not na(modeledLossPerUnit) and modeledLossPerUnit > 0.0 and not na(modeledWinPerUnit) ? modeledWinPerUnit / modeledLossPerUnit : na
float costDragInRiskR = includeCostsInput and not na(priceRiskPerUnit) and priceRiskPerUnit > 0.0 ? totalCostPerUnit / priceRiskPerUnit : na
float costAdjustedBreakEvenWinRate = includeCostsInput and not na(modeledLossPerUnit) and not na(modeledWinPerUnit) and modeledWinPerUnit > 0.0 ? modeledLossPerUnit / (modeledLossPerUnit + modeledWinPerUnit) * 100.0 : na

bool thresholdsValid = preferredRInput >= minimumRInput
string thresholdText = not geometryValid ? "Invalid geometry" : not thresholdsValid ? "Set preferred R at or above minimum R" : rewardRisk < minimumRInput ? "Below personal minimum" : rewardRisk < preferredRInput ? "Meets personal minimum" : "At or above preference"
color thresholdColor = not geometryValid or not thresholdsValid ? riskColorInput : rewardRisk >= preferredRInput ? rewardColorInput : rewardRisk >= minimumRInput ? neutralColorInput : riskColorInput
string entryToleranceText = na(entryToleranceDistance) ? "n/a" : f_price(entryToleranceDistance) + "  |  " + f_number(entryToleranceTicks, "#.##") + " ticks  |  " + f_percent(entryToleranceRiskPercent) + " of risk"
string entryToleranceErosionText = not entryToleranceValid ? "n/a" : retainedRPercent >= 90.0 ? "Low R erosion" : retainedRPercent >= 75.0 ? "Moderate R erosion" : "High R erosion"
string entryDriftText = not geometryValid ? "Invalid plan geometry" : na(entryToleranceDistance) ? "Anchor ATR unavailable" : entryToleranceValid ? "Adverse " + f_r(adverseEntryR) + "  |  Favorable " + f_r(favorableEntryR) + "  |  Retained " + f_percent(retainedRPercent) + "  |  " + entryToleranceErosionText : "Tolerance crosses stop or target"
color entryToleranceStatusColor = not geometryValid ? riskColorInput : na(entryToleranceDistance) ? neutralColorInput : entryToleranceValid ? toleranceColorInput : riskColorInput

//------------------------------------------------------------------------------
// Dynamic status text and display parameters
//------------------------------------------------------------------------------
string statusText = switch scenarioStatus
    STATUS_BEFORE_ANCHOR => "Before anchor"
    STATUS_WAITING_ENTRY => "Waiting for entry"
    STATUS_ACTIVE        => "Active"
    STATUS_TARGET        => "Target reached first"
    STATUS_STOP          => "Stop reached first"
    STATUS_AMBIGUOUS     => "Ambiguous same bar"
    STATUS_EXPIRED       => expiredUnfilled ? "Expired unfilled" : "Expired unresolved"
    => "Invalid geometry"

color statusColor = switch scenarioStatus
    STATUS_TARGET        => rewardColorInput
    STATUS_STOP          => riskColorInput
    STATUS_AMBIGUOUS     => neutralColorInput
    STATUS_EXPIRED       => neutralColorInput
    STATUS_ACTIVE        => entryColorInput
    STATUS_WAITING_ENTRY => entryColorInput
    STATUS_INVALID       => riskColorInput
    => neutralColorInput

float currentR = geometryValid and scenarioStatus == STATUS_ACTIVE ? direction * (close - entryPriceInput) / riskDistance : terminalR
int barsFromAnchor = not na(anchorBarIndex) ? math.max(0, bar_index - anchorBarIndex) : 0
int elapsedBars = not na(activationBarIndex) ? math.max(0, (not na(resolutionBarIndex) ? resolutionBarIndex : bar_index) - activationBarIndex) : 0
float displayedMfeR = not na(activationBarIndex) ? maximumFavorableR : na
float displayedMaeR = not na(activationBarIndex) ? maximumAdverseR : na
int chartTimeframeSeconds = timeframe.in_seconds()
int observedBarMilliseconds = not na(time_close) ? math.max(1, time_close - time) : bar_index > 0 ? math.max(1, time - time[1]) : 60000
int typicalBarMilliseconds = not na(chartTimeframeSeconds) ? chartTimeframeSeconds * 1000 : observedBarMilliseconds
int estimatedPlanEndTime = not na(anchorBarTime) ? (not na(horizonBarCloseTime) ? horizonBarCloseTime : barEndTime + math.max(0, horizonBarsInput - barsFromAnchor) * typicalBarMilliseconds) : na

string panelPosition = switch panelPositionInput
    "Middle right" => position.middle_right
    "Bottom right" => position.bottom_right
    "Top left"     => position.top_left
    "Bottom left"  => position.bottom_left
    => position.top_right

string panelTextSize = switch panelSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

string panelHeaderTextSize = switch panelSizeInput
    "Tiny"   => size.small
    "Normal" => size.large
    => size.normal

string ohlcAuditText = switch scenarioStatus
    STATUS_TARGET    => (chart.is_standard ? "Standard" : "Synthetic") + " • " + resolutionDetail
    STATUS_STOP      => (chart.is_standard ? "Standard" : "Synthetic") + " • " + resolutionDetail
    STATUS_AMBIGUOUS => (chart.is_standard ? "Standard" : "Synthetic") + " • " + resolutionDetail
    STATUS_EXPIRED   => (chart.is_standard ? "Standard" : "Synthetic") + " • " + resolutionDetail
    STATUS_ACTIVE    => (chart.is_standard ? "Standard" : "Synthetic") + " • Confirmed bars • Entry bar excluded"
    STATUS_WAITING_ENTRY => (chart.is_standard ? "Standard" : "Synthetic") + " • Waiting for confirmed entry touch"
    STATUS_BEFORE_ANCHOR => (chart.is_standard ? "Standard" : "Synthetic") + " • Before anchor"
    => (chart.is_standard ? "Standard" : "Synthetic") + " • Invalid geometry"

color ohlcAuditColor = chart.is_standard ? textColorInput : neutralColorInput

bool scenarioResolved = scenarioStatus == STATUS_TARGET or scenarioStatus == STATUS_STOP or scenarioStatus == STATUS_AMBIGUOUS or scenarioStatus == STATUS_EXPIRED
bool keepFullResolvedScenario = completedVisualModeInput == "Keep full scenario"
bool showFullPlanVisuals = not scenarioResolved or keepFullResolvedScenario
bool showCompactResolvedVisuals = scenarioResolved and completedVisualModeInput == "Compact result"
bool clearResolvedVisuals = scenarioResolved and completedVisualModeInput == "Clear completed visuals"
string nextScenarioText = scenarioResolved ? "Drag handles  •  Reset points" : scenarioStatus == STATUS_INVALID ? "Reposition Entry / Stop / Target" : "Move any handle to recalculate"
string nextScenarioTooltip = "Select the indicator, then drag its Entry/Anchor, Stop, or Target handle. Any input move makes Pine re-execute the script and rebuild the scenario from a clean state. For a completely fresh placement, open the script's More (...) menu and choose Reset points."

//------------------------------------------------------------------------------
// Drawings: recreate only on the last bar so the chart stays clean
//------------------------------------------------------------------------------
var box rewardBox = na
var box riskBox = na
var box toleranceBox = na
var line entryLine = na
var line stopLine = na
var line targetLine = na
var line anchorLine = na
var line horizonLine = na
var line progressLine = na
var line resolutionLine = na
var line activationLine = na
var label entryLabel = na
var label stopLabel = na
var label targetLabel = na
var label progressLabel = na
var label outcomeLabel = na
var label warningLabel = na
var label activationLabel = na
var label nextScenarioLabel = na
var label rewardInfoLabel = na
var label riskInfoLabel = na

if barstate.islast
    if not na(rewardBox)
        box.delete(rewardBox)
    if not na(riskBox)
        box.delete(riskBox)
    if not na(toleranceBox)
        box.delete(toleranceBox)
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(targetLine)
        line.delete(targetLine)
    if not na(anchorLine)
        line.delete(anchorLine)
    if not na(horizonLine)
        line.delete(horizonLine)
    if not na(progressLine)
        line.delete(progressLine)
    if not na(resolutionLine)
        line.delete(resolutionLine)
    if not na(activationLine)
        line.delete(activationLine)
    if not na(entryLabel)
        label.delete(entryLabel)
    if not na(stopLabel)
        label.delete(stopLabel)
    if not na(targetLabel)
        label.delete(targetLabel)
    if not na(progressLabel)
        label.delete(progressLabel)
    if not na(outcomeLabel)
        label.delete(outcomeLabel)
    if not na(warningLabel)
        label.delete(warningLabel)
    if not na(activationLabel)
        label.delete(activationLabel)
    if not na(nextScenarioLabel)
        label.delete(nextScenarioLabel)
    if not na(rewardInfoLabel)
        label.delete(rewardInfoLabel)
    if not na(riskInfoLabel)
        label.delete(riskInfoLabel)

    rewardBox := na
    riskBox := na
    toleranceBox := na
    entryLine := na
    stopLine := na
    targetLine := na
    anchorLine := na
    horizonLine := na
    progressLine := na
    resolutionLine := na
    activationLine := na
    entryLabel := na
    stopLabel := na
    targetLabel := na
    progressLabel := na
    outcomeLabel := na
    warningLabel := na
    activationLabel := na
    nextScenarioLabel := na
    rewardInfoLabel := na
    riskInfoLabel := na

    if geometryValid and not na(anchorBarTime) and not na(estimatedPlanEndTime)
        float rewardTop = math.max(entryPriceInput, targetPriceInput)
        float rewardBottom = math.min(entryPriceInput, targetPriceInput)
        float riskTop = math.max(entryPriceInput, stopPriceInput)
        float riskBottom = math.min(entryPriceInput, stopPriceInput)
        float fullTop = math.max(targetPriceInput, math.max(entryPriceInput, stopPriceInput))
        float fullBottom = math.min(targetPriceInput, math.min(entryPriceInput, stopPriceInput))
        int levelLabelTime = math.min(estimatedPlanEndTime, barEndTime + typicalBarMilliseconds * 3)

        string rewardBoxText = ""
        string riskBoxText = ""
        string rewardInfoText = showBoxTextInput ? "Reward  " + f_r(rewardRisk) + "  •  " + f_percent(rewardPercentOfPrice) : ""
        string riskInfoText = showBoxTextInput ? "Risk  1.00R  •  " + f_percent(riskPercentOfPrice) : ""
        int planSpanMilliseconds = math.max(typicalBarMilliseconds, estimatedPlanEndTime - anchorBarTime)
        int infoLabelTime = anchorBarTime + int(math.round(float(planSpanMilliseconds) * 0.62))
        float rewardInfoY = (rewardTop + rewardBottom) * 0.5
        float riskInfoY = (riskTop + riskBottom) * 0.5

        if showFullPlanVisuals
            if showBoxesInput
                rewardBox := box.new(
                     left = anchorBarTime,
                     top = rewardTop,
                     right = estimatedPlanEndTime,
                     bottom = rewardBottom,
                     xloc = xloc.bar_time,
                     border_color = color.new(rewardColorInput, 10),
                     border_width = 2,
                     border_style = line.style_solid,
                     bgcolor = color.new(rewardColorInput, boxTransparencyInput),
                     text = rewardBoxText,
                     text_color = textColorInput,
                     text_size = size.small,
                     text_halign = text.align_left,
                     text_valign = text.align_center,
                     text_formatting = text.format_bold)

                riskBox := box.new(
                     left = anchorBarTime,
                     top = riskTop,
                     right = estimatedPlanEndTime,
                     bottom = riskBottom,
                     xloc = xloc.bar_time,
                     border_color = color.new(riskColorInput, 10),
                     border_width = 2,
                     border_style = line.style_solid,
                     bgcolor = color.new(riskColorInput, boxTransparencyInput),
                     text = riskBoxText,
                     text_color = textColorInput,
                     text_size = size.small,
                     text_halign = text.align_left,
                     text_valign = text.align_center,
                     text_formatting = text.format_bold)

                if showBoxTextInput
                    rewardInfoLabel := label.new(
                         x = infoLabelTime,
                         y = rewardInfoY,
                         text = rewardInfoText,
                         xloc = xloc.bar_time,
                         yloc = yloc.price,
                         color = color.new(rewardColorInput, 8),
                         style = label.style_label_left,
                         textcolor = f_contrast_text(rewardColorInput),
                         size = size.large,
                         textalign = text.align_left,
                         text_formatting = text.format_bold)

                    riskInfoLabel := label.new(
                         x = infoLabelTime,
                         y = riskInfoY,
                         text = riskInfoText,
                         xloc = xloc.bar_time,
                         yloc = yloc.price,
                         color = color.new(riskColorInput, 8),
                         style = label.style_label_left,
                         textcolor = f_contrast_text(riskColorInput),
                         size = size.large,
                         textalign = text.align_left,
                         text_formatting = text.format_bold)

            if showEntryToleranceBandInput and entryToleranceValid and entryToleranceDistance > 0.0
                float toleranceTop = math.max(adverseEntryPrice, favorableEntryPrice)
                float toleranceBottom = math.min(adverseEntryPrice, favorableEntryPrice)
                toleranceBox := box.new(
                     left = anchorBarTime,
                     top = toleranceTop,
                     right = estimatedPlanEndTime,
                     bottom = toleranceBottom,
                     xloc = xloc.bar_time,
                     border_color = toleranceColorInput,
                     border_width = 1,
                     border_style = line.style_dashed,
                     bgcolor = color.new(toleranceColorInput, 76))

            anchorLine := line.new(
                 x1 = anchorBarTime,
                 y1 = fullBottom,
                 x2 = anchorBarTime,
                 y2 = fullTop,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = color.new(entryColorInput, 25),
                 style = line.style_dashed,
                 width = 1)

            horizonLine := line.new(
                 x1 = estimatedPlanEndTime,
                 y1 = fullBottom,
                 x2 = estimatedPlanEndTime,
                 y2 = fullTop,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = color.new(neutralColorInput, 45),
                 style = line.style_dotted,
                 width = 1)

            if activationInput == "Wait for entry touch" and not na(activationBarTime)
                activationLine := line.new(
                     x1 = activationBarTime,
                     y1 = fullBottom,
                     x2 = activationBarTime,
                     y2 = fullTop,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = color.new(entryColorInput, 10),
                     style = line.style_dotted,
                     width = 2)
                activationLabel := label.new(
                     x = activationBarTime,
                     y = entryPriceInput,
                     text = "◆  Entry activated",
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     color = entryColorInput,
                     style = label.style_label_up,
                     textcolor = f_contrast_text(entryColorInput),
                     size = size.normal,
                     textalign = text.align_center,
                     tooltip = "The first confirmed chart bar that traded through the selected entry price. Exit evaluation begins on the next confirmed bar.",
                     text_formatting = text.format_bold)

            targetLine := line.new(
                 x1 = anchorBarTime,
                 y1 = targetPriceInput,
                 x2 = estimatedPlanEndTime,
                 y2 = targetPriceInput,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = rewardColorInput,
                 style = line.style_solid,
                 width = lineWidthInput)

            entryLine := line.new(
                 x1 = anchorBarTime,
                 y1 = entryPriceInput,
                 x2 = estimatedPlanEndTime,
                 y2 = entryPriceInput,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = entryColorInput,
                 style = line.style_solid,
                 width = math.min(5, lineWidthInput + 1))

            stopLine := line.new(
                 x1 = anchorBarTime,
                 y1 = stopPriceInput,
                 x2 = estimatedPlanEndTime,
                 y2 = stopPriceInput,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = riskColorInput,
                 style = line.style_solid,
                 width = lineWidthInput)

            if showPriceLabelsInput
                targetLabel := label.new(
                     x = levelLabelTime,
                     y = targetPriceInput,
                     text = "Target  " + f_price(targetPriceInput) + "\n" + f_r(rewardRisk),
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     color = rewardColorInput,
                     style = label.style_label_right,
                     textcolor = f_contrast_text(rewardColorInput),
                     size = size.normal,
                     textalign = text.align_center,
                     text_formatting = text.format_bold)

                entryLabel := label.new(
                     x = levelLabelTime,
                     y = entryPriceInput,
                     text = "Entry  " + f_price(entryPriceInput),
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     color = entryColorInput,
                     style = label.style_label_right,
                     textcolor = f_contrast_text(entryColorInput),
                     size = size.normal,
                     textalign = text.align_center,
                     text_formatting = text.format_bold)

                stopLabel := label.new(
                     x = levelLabelTime,
                     y = stopPriceInput,
                     text = "Stop  " + f_price(stopPriceInput) + "\n-1.00R",
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     color = riskColorInput,
                     style = label.style_label_right,
                     textcolor = f_contrast_text(riskColorInput),
                     size = size.normal,
                     textalign = text.align_center,
                     text_formatting = text.format_bold)

            if showLiveMarkerInput and scenarioStatus == STATUS_ACTIVE
                int activeMarkerTime = math.min(time, estimatedPlanEndTime)
                progressLine := line.new(
                     x1 = activeMarkerTime,
                     y1 = entryPriceInput,
                     x2 = activeMarkerTime,
                     y2 = close,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = currentR >= 0.0 ? rewardColorInput : riskColorInput,
                     style = line.style_solid,
                     width = 3)

                progressLabel := label.new(
                     x = activeMarkerTime,
                     y = close,
                     text = "Live  " + f_r(currentR),
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     color = currentR >= 0.0 ? rewardColorInput : riskColorInput,
                     style = currentR >= 0.0 ? label.style_label_up : label.style_label_down,
                     textcolor = f_contrast_text(currentR >= 0.0 ? rewardColorInput : riskColorInput),
                     size = size.normal,
                     textalign = text.align_center,
                     text_formatting = text.format_bold)

        if showLiveMarkerInput and not na(resolutionBarTime) and scenarioResolved and not clearResolvedVisuals
            float outcomePrice = na(resolutionPrice) ? entryPriceInput : resolutionPrice

            float compactMarkerHalfHeight = math.max(riskDistance * 0.12, syminfo.mintick * 8.0)
            float resolutionTop = showCompactResolvedVisuals ? outcomePrice + compactMarkerHalfHeight : math.max(fullTop, outcomePrice)
            float resolutionBottom = showCompactResolvedVisuals ? outcomePrice - compactMarkerHalfHeight : math.min(fullBottom, outcomePrice)

            if showCompactResolvedVisuals
                entryLine := line.new(
                     x1 = anchorBarTime,
                     y1 = entryPriceInput,
                     x2 = resolutionBarTime,
                     y2 = entryPriceInput,
                     xloc = xloc.bar_time,
                     extend = extend.none,
                     color = color.new(entryColorInput, 52),
                     style = line.style_dotted,
                     width = 1)

            resolutionLine := line.new(
                 x1 = resolutionBarTime,
                 y1 = resolutionBottom,
                 x2 = resolutionBarTime,
                 y2 = resolutionTop,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = statusColor,
                 style = line.style_dashed,
                 width = 2)
            string outcomeIcon = scenarioStatus == STATUS_TARGET ? "✓" : scenarioStatus == STATUS_STOP ? "✕" : scenarioStatus == STATUS_AMBIGUOUS ? "◇" : "⏱"
            string outcomeText = outcomeIcon + "  " + statusText + (not na(terminalR) ? "\n" + f_r(terminalR) : "")
            color outcomeColor = statusColor

            outcomeLabel := label.new(
                 x = resolutionBarTime,
                 y = outcomePrice,
                 text = outcomeText,
                 xloc = xloc.bar_time,
                 yloc = yloc.price,
                 color = outcomeColor,
                 style = outcomePrice >= entryPriceInput ? label.style_label_down : label.style_label_up,
                 textcolor = f_contrast_text(outcomeColor),
                 size = size.normal,
                 textalign = text.align_center,
                 tooltip = resolutionDetail,
                 text_formatting = text.format_bold)

        if showNextScenarioCueInput and scenarioResolved
            float cueRange = nz(atrSeries, math.max(high - low, syminfo.mintick * 20.0))
            float cuePrice = high + cueRange * 0.28
            nextScenarioLabel := label.new(
                 x = bar_index - 2,
                 y = cuePrice,
                 text = "↻  NEXT SCENARIO\nDrag handles  •  Reset points",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 color = color.new(entryColorInput, 4),
                 style = label.style_label_down,
                 textcolor = f_contrast_text(entryColorInput),
                 size = size.small,
                 textalign = text.align_center,
                 tooltip = nextScenarioTooltip,
                 text_formatting = text.format_bold)
    else
        int warningTime = time
        float warningRange = nz(atrSeries, math.max(high - low, syminfo.mintick * 20.0))
        float warningPrice = high + warningRange * 0.35
        string warningText = not geometryValid ? "Invalid plan geometry\nLong: Stop < Entry < Target\nShort: Target < Entry < Stop" : "Anchor is outside the loaded chart range"
        warningLabel := label.new(
             x = warningTime,
             y = warningPrice,
             text = warningText,
             xloc = xloc.bar_time,
             yloc = yloc.price,
             color = color.new(riskColorInput, 5),
             style = label.style_label_down,
             textcolor = f_contrast_text(riskColorInput),
             size = size.normal,
             textalign = text.align_center,
             text_formatting = text.format_bold)

//------------------------------------------------------------------------------
// Scenario readout
//------------------------------------------------------------------------------
var table scenarioTable = table.new(
     panelPosition,
     3,
     8,
     bgcolor = color.new(panelBackgroundInput, 4),
     frame_color = color.new(entryColorInput, 22),
     frame_width = 1,
     border_color = color.new(textColorInput, 68),
     border_width = 1)

if barstate.islast
    color clearCell = color.new(panelBackgroundInput, 100)

    if showPanelInput
        table.set_bgcolor(scenarioTable, color.new(panelBackgroundInput, 4))
        table.set_frame_color(scenarioTable, color.new(entryColorInput, 22))
        table.set_border_color(scenarioTable, color.new(textColorInput, 68))

        color headerBackground = color.new(statusColor, 0)
        color headerTextColor = f_contrast_text(headerBackground)
        color labelBackground = color.new(panelBackgroundInput, 5)
        color valueBackground = color.new(panelBackgroundInput, 0)
        string headerLeftText = direction == 1 ? "▲  Long" : direction == -1 ? "▼  Short" : "◆  Plan"
        string headerStateText = switch scenarioStatus
            STATUS_BEFORE_ANCHOR => "◌  Before"
            STATUS_WAITING_ENTRY => "○  Waiting"
            STATUS_ACTIVE        => "●  Active"
            STATUS_TARGET        => "✓  Target"
            STATUS_STOP          => "✕  Stop"
            STATUS_AMBIGUOUS     => "◇  Ambiguous"
            STATUS_EXPIRED       => "◷  Expired"
            => "!  Invalid"
        string headerStatusText = headerStateText + (chart.is_standard ? "" : " • Synth")
        string planSummaryText = includeCostsInput ? f_r(rewardRisk) + " → " + f_r(costAdjustedRewardRisk) + " net  •  BE " + f_percent(costAdjustedBreakEvenWinRate) : f_r(rewardRisk) + "  •  BE " + f_percent(grossBreakEvenWinRate)
        string executionSummaryText = not geometryValid ? "Invalid geometry" : na(entryToleranceDistance) ? "Tolerance unavailable" : entryToleranceValid ? f_r(adverseEntryR) + " adverse  •  " + f_percent(retainedRPercent) + " kept" : "Tolerance crosses a level"
        string riskSizeSummaryText = f_cash(riskBudget, accountCurrencyInput) + "  •  Qty " + f_number(modeledQuantity, "#.########")
        string cashSummaryText = f_signed_cash(-modeledNetLossCash, accountCurrencyInput) + "  /  " + f_signed_cash(modeledNetWinCash, accountCurrencyInput)
        string resolvedPathText = (not na(terminalR) ? f_r(terminalR) : f_r(currentR)) + " final  •  " + str.tostring(elapsedBars) + "/" + str.tostring(horizonBarsInput) + " bars"
        string activePathText = f_r(currentR) + " now  •  " + str.tostring(elapsedBars) + "/" + str.tostring(horizonBarsInput) + " bars"
        string pathSummaryText = scenarioStatus == STATUS_ACTIVE ? activePathText : scenarioResolved ? resolvedPathText : scenarioStatus == STATUS_WAITING_ENTRY ? "Waiting  •  " + str.tostring(barsFromAnchor) + "/" + str.tostring(horizonBarsInput) + " bars" : scenarioStatus == STATUS_BEFORE_ANCHOR ? "Before anchor" : "Reposition levels"
        string pathTooltip = "MFE / MAE: " + f_r(displayedMfeR) + " / " + f_r(displayedMaeR) + " | " + ohlcAuditText + (resolutionDetail != "" ? " | " + resolutionDetail : "")

        // Invisible top spacer row and right spacer column preserve the approved offset.
        for col = 0 to 2
            table.cell(scenarioTable, col, 0, "   ", text_color = clearCell, bgcolor = clearCell)
        for row = 0 to 7
            table.cell(scenarioTable, 2, row, "   ", text_color = clearCell, bgcolor = clearCell)

        table.cell(scenarioTable, 0, 1, headerLeftText, text_color = headerTextColor, bgcolor = headerBackground, text_size = panelHeaderTextSize, text_halign = text.align_left, tooltip = "Scenario direction.", text_formatting = text.format_bold)
        table.cell(scenarioTable, 1, 1, headerStatusText, text_color = headerTextColor, bgcolor = headerBackground, text_size = panelHeaderTextSize, text_halign = text.align_right, tooltip = ohlcAuditText, text_formatting = text.format_bold)

        table.cell(scenarioTable, 0, 2, "◎ Plan R", text_color = textColorInput, bgcolor = labelBackground, text_size = panelTextSize, text_halign = text.align_left, tooltip = "Planned reward-to-risk, optional cost-adjusted R, and the corresponding break-even win rate.", text_formatting = text.format_bold)
        table.cell(scenarioTable, 1, 2, planSummaryText, text_color = rewardColorInput, bgcolor = valueBackground, text_size = panelTextSize, text_halign = text.align_right, tooltip = includeCostsInput ? "Gross R is shown before modeled costs. Net R and break-even use the selected commission and slippage assumptions." : "Break-even win rate is derived from the planned gross R multiple.", text_formatting = text.format_bold)

        table.cell(scenarioTable, 0, 3, "↕ Entry stress", text_color = textColorInput, bgcolor = labelBackground, text_size = panelTextSize, text_halign = text.align_left, tooltip = "Shows the R multiple after the selected adverse entry-price deviation and how much of the planned R remains.", text_formatting = text.format_bold)
        table.cell(scenarioTable, 1, 3, executionSummaryText, text_color = entryToleranceStatusColor, bgcolor = valueBackground, text_size = panelTextSize, text_halign = text.align_right, tooltip = entryDriftText, text_formatting = text.format_bold)

        table.cell(scenarioTable, 0, 4, "¤ Risk / size", text_color = textColorInput, bgcolor = labelBackground, text_size = panelTextSize, text_halign = text.align_left, tooltip = "Selected risk budget and arithmetic quantity. Verify point value and contract specifications with the relevant broker or exchange.", text_formatting = text.format_bold)
        table.cell(scenarioTable, 1, 4, riskSizeSummaryText, text_color = entryColorInput, bgcolor = valueBackground, text_size = panelTextSize, text_halign = text.align_right, text_formatting = text.format_bold)

        table.cell(scenarioTable, 0, 5, "± Stop / target", text_color = textColorInput, bgcolor = labelBackground, text_size = panelTextSize, text_halign = text.align_left, tooltip = "Modeled net cash loss at the stop and modeled net cash gain at the target.", text_formatting = text.format_bold)
        table.cell(scenarioTable, 1, 5, cashSummaryText, text_color = textColorInput, bgcolor = valueBackground, text_size = panelTextSize, text_halign = text.align_right, text_formatting = text.format_bold)

        table.cell(scenarioTable, 0, 6, "◷ Live / result", text_color = textColorInput, bgcolor = labelBackground, text_size = panelTextSize, text_halign = text.align_left, tooltip = pathTooltip, text_formatting = text.format_bold)
        table.cell(scenarioTable, 1, 6, pathSummaryText, text_color = statusColor, bgcolor = valueBackground, text_size = panelTextSize, text_halign = text.align_right, tooltip = pathTooltip, text_formatting = text.format_bold)

        if showNextScenarioCueInput
            color workflowBackground = scenarioResolved ? color.new(entryColorInput, 6) : color.new(panelBackgroundInput, 0)
            color workflowTextColor = scenarioResolved ? color.black : entryColorInput
            table.cell(scenarioTable, 0, 7, "↻ Next test", text_color = workflowTextColor, bgcolor = workflowBackground, text_size = panelTextSize, text_halign = text.align_left, tooltip = nextScenarioTooltip, text_formatting = text.format_bold)
            table.cell(scenarioTable, 1, 7, nextScenarioText, text_color = workflowTextColor, bgcolor = workflowBackground, text_size = panelTextSize, text_halign = text.align_right, tooltip = nextScenarioTooltip, text_formatting = text.format_bold)
        else
            table.cell(scenarioTable, 0, 7, "", text_color = clearCell, bgcolor = clearCell)
            table.cell(scenarioTable, 1, 7, "", text_color = clearCell, bgcolor = clearCell)
    else
        table.set_bgcolor(scenarioTable, clearCell)
        table.set_frame_color(scenarioTable, clearCell)
        table.set_border_color(scenarioTable, clearCell)

        for row = 0 to 7
            for col = 0 to 2
                table.cell(scenarioTable, col, row, "", text_color = clearCell, bgcolor = clearCell)

//------------------------------------------------------------------------------
// Alerts: neutral scenario events, not trade instructions
//------------------------------------------------------------------------------
alertcondition(activationEvent, "Scenario activated", "The selected risk/reward scenario has activated.")
alertcondition(targetEvent, "Scenario target reached first", "The selected risk/reward scenario reached its target before its stop under the chosen OHLC policy.")
alertcondition(stopEvent, "Scenario stop reached first", "The selected risk/reward scenario reached its stop before its target under the chosen OHLC policy.")
alertcondition(ambiguousEvent, "Scenario outcome ambiguous", "The selected risk/reward scenario touched its stop and target in the same bar, so the intrabar order is unknown.")
alertcondition(expiryEvent, "Scenario horizon ended", "The selected risk/reward scenario reached the end of its research horizon.")
````
