# Average Entry Price and Fee-Adjusted Break-Even Workbench

- url: https://www.tradingview.com/script/59YooVtm-Average-Entry-Price-and-Fee-Adjusted-Break-Even-Workbench/
- type: indicator
- pine_id: PUB;bfac33217c1c4fbd97652e32f6f0456f
- version: 2.0

## Description

Overview

Average Entry Price and Fee-Adjusted Break-Even Workbench is an open-source position cost-basis and break-even research indicator. It reconstructs a manually entered position's average entry price, weighted average cost and DCA cost basis, then calculates a cost-adjusted and fee-adjusted break-even level after configurable trading fees, spread or slippage, fixed costs and funding adjustments.

The script supports Long and Short positions, a known average price or up to eight individual fills, scale-in research and position-management scenarios.

It does not predict market direction, generate trade recommendations, read broker positions, access Trading Panel account data or place orders.

Why average entry and break-even are different

A position's average entry price is not always the price at which its estimated net result becomes zero.

Entry fees, exit fees, spread, slippage, fixed order costs and funding adjustments can move the effective break-even away from the weighted average entry.

The script separates three values that are often treated as one:

- Weighted average entry price
- Cost impact between the average entry and break-even
- Current price distance from the calculated break-even

Long and Short positions use separate equations. Percentage exit fees are solved algebraically instead of being approximated by adding a percentage directly to the average entry price.

Before a break-even result is displayed, the calculated level is reinserted into the normalized net P&L equation. The script checks the remaining residual and suppresses the result when the calculation health check does not pass.

Position input methods

The script provides two manual position-input methods.

Known average

Enter:

- Average entry price
- Remaining position quantity
- Long or Short side

This mode is suitable when the broker or another record already provides the current average entry price.

Individual fills

Enter up to eight fill prices and quantities.

The weighted average is calculated as:

Average entry price =
Sum of (fill price x fill quantity) / Sum of fill quantity

The selected number of fills determines which rows are used.

Optional dated fills can activate each fill from its specified time. When dated fills are enabled, the historical development of the weighted average can also be displayed.

Fill validation can either:

- Require all selected rows to contain valid price and quantity values
- Use only the valid rows and report how many selected fills were used

Cost-adjusted break-even

The break-even calculation can include:

- Entry fee as a percentage of entry notional
- Exit fee as a percentage of estimated exit notional
- Exit friction in ticks
- Exit friction in price units
- Fixed entry cost per order
- Fixed exit cost
- Carry or funding adjustment
- Other cash cost or credit

Exit friction can be used to represent a configurable spread or slippage assumption.

Positive fee and cash values represent costs.

Negative percentage fees, carry values or other adjustments can represent rebates or credits where applicable.

The normalized calculation concept is:

Long break-even =
Exit friction
+ (((1 + entry fee rate) x average entry price) + cash cost per unit)
  / (1 - exit fee rate)

Short break-even =
(((1 - entry fee rate) x average entry price) - cash cost per unit)
  / (1 + exit fee rate)
- exit friction

The displayed Long break-even is rounded upward to the symbol's minimum tick.

The displayed Short break-even is rounded downward to the symbol's minimum tick.

Internal calculations retain the unrounded value.

Price Only and Full Cash models

The script separates price-based calculations from cash-converted calculations.

Price Only

Percentage fees and price friction can be calculated without a point value when no fixed cash adjustments are included.

This allows the average entry, break-even, Cost Delta and current-price distance to remain available even when a reliable point value is not available.

Full Cash

Fixed cash costs, realized P&L adjustments and estimated cash P&L require a valid point value.

The script uses the symbol's point value when available. A Point Value Override can be entered when the automatic value does not match the broker, exchange or contract specification being researched.

If cash costs are entered without a valid point value, the script does not silently ignore them. It displays a Point Value Needed state instead.

Chart display

The default Overview layout provides a compact summary of:

- AVG: weighted average entry price
- COST Delta: directional difference between average entry and break-even
- BE: cost-adjusted break-even price
- VS BE: directional distance between current price and break-even

The main chart visuals use:

- A cyan solid line for the weighted average entry price
- An orange dashed line for the cost-adjusted break-even
- A shaded Cost Gap between the average and break-even
- Optional fill markers
- An optional historical weighted-average path
- A compact Position Panel

A positive VS BE value means price is on the favorable side of the calculated break-even for the selected Long or Short position.

A negative VS BE value means price is on the unfavorable side.

This is an arithmetic position-status display. It is not a trading signal.

Position Panel

The Position Panel summarizes the position without requiring the user to inspect every setting.

Depending on the selected panel mode, it can display:

- Input method
- Long or Short side
- Weighted average entry
- Cost Delta
- Cost-adjusted break-even
- Current price distance from break-even
- Price Only or Full Cash model status
- Estimated net cash P&L
- Campaign Recovery break-even
- Next Fill preview
- Target Calculation result
- Fill concentration
- Weighted fill-price dispersion
- Effective fill count
- Calculation residual

The default Bottom Left position includes transparent clearance intended to reduce overlap with TradingView's bottom-left platform mark.

The panel can be set to:

- Off
- Compact
- Overview
- Detailed

Label layout and collision handling

Label placement can be set to:

- Auto
- Split
- Combined
- Right edge
- Off

Auto mode separates the AVG and BE labels when practical.

When the two levels are visually close, Auto mode combines AVG, BE and the cost difference into one label to reduce chart congestion.

The visual-separation model uses:

- The symbol's minimum tick
- ATR
- A recent high-low range
- The configured line span

These values act as price-space proxies for how close labels may appear.

Pine Script cannot read browser zoom, display DPI or exact on-screen pixel coordinates. The collision system therefore reduces likely overlap without claiming pixel-perfect detection.

Campaign and Next Fill labels yield to the primary AVG and BE labels when their levels are too close. Their values remain available in the Detailed panel.

The Current vs BE chart note is optional and disabled by default to keep the chart clean.

Scenario research

Campaign Recovery

Campaign Recovery calculates a separate break-even using manually entered realized P&L from previous partial exits.

A positive realized P&L value reduces the remaining recovery requirement.

A negative realized P&L value increases the remaining recovery requirement.

The result is an arithmetic recovery level based on the entered values. It is not a recovery guarantee.

Next Fill

Next Fill previews:

- New total quantity
- New weighted average entry price
- New cost-adjusted break-even after a proposed additional fill

This is a scenario calculation only. It is not a recommendation to add to a position.

Target Calculation

Target Calculation determines the arithmetic quantity required to reach either:

- A target average entry price
- A target fee-adjusted break-even price

The result is checked by reinserting the calculated quantity into the target calculation.

The resulting quantity is not a recommended, optimal or safe position size.

Adding to a position increases exposure and can magnify losses.

Fill statistics

When Individual Fills is used, the Detailed panel can display:

- Largest fill share
- Weighted fill-price dispersion
- Effective fill count

These statistics help users inspect whether the cost basis is concentrated in one large fill or distributed across several fills.

Alerts

The script provides factual alert conditions for:

- Price crossing the average entry
- Price crossing the cost-adjusted break-even
- Price entering the Cost Gap
- Price exiting the Cost Gap
- Price crossing the optional Campaign Recovery break-even
- Price crossing the optional Next Fill preview break-even

Alerts are evaluated on confirmed bars.

Alert conditions require:

- A valid position
- A healthy break-even calculation
- A standard chart
- A stable calculated level

Alerts are disabled on non-standard charts.

Users must create the desired alerts separately through TradingView's alert dialog.

Realtime and historical behavior

The script does not use future data, lookahead or higher-timeframe data requests.

Live Price mode allows the Position Panel to update during an open realtime bar.

Confirmed Close mode uses the most recent confirmed close while the current realtime bar remains unfinished.

Alerts remain confirmed-bar events regardless of the selected panel price mode.

Changing an input causes the chart history to be recalculated using the new settings.

When dated fills are enabled, each fill becomes active from its manually specified time.

Non-standard charts

Heikin Ashi, Renko, Kagi, Line Break and Point & Figure prices can be synthetic.

User-entered average and break-even levels remain arithmetic levels, but the chart close may not represent an executable market price.

For this reason:

- Current-price calculations are restricted by default
- A synthetic-chart warning remains visible
- Alerts are disabled on non-standard charts

Languages

On-chart text can be selected manually in:

- English
- Japanese
- Spanish
- Portuguese (Brazil)
- German
- French
- Simplified Chinese
- Traditional Chinese
- Korean
- Turkish
- Russian
- Indonesian

English can optionally be displayed alongside the selected language.

Pine Script does not automatically read the TradingView interface language. The display language must be selected manually in the indicator settings.

Settings use stable field identifiers such as:

- P for position settings
- C for cost settings
- F for individual fills
- R for research tools
- D for display settings
- A for advanced settings

An optional localized setup guide maps the main field identifiers to the selected on-chart language.

Main interface terms

AVG = Weighted average entry price

COST Delta = Cost impact between average entry and break-even

BE = Cost-adjusted break-even price

VS BE = Current price distance from break-even

ABOVE BE = Current price is above break-even

BELOW BE = Current price is below break-even

NEAR BE = Current price is within the configured near-break-even tolerance

FULL CASH = A point value is available for cash-converted calculations

PRICE ONLY = Price calculations are available without cash conversion

POINT VALUE NEEDED = A valid point value is required for the entered cash adjustments

Basic use

1. Select Known Average or Individual Fills.
2. Select Long or Short.
3. Enter the average price and remaining quantity, or enter the selected fill prices and quantities.
4. Enter the applicable entry fee, exit fee and exit friction.
5. Enable Detailed Cash Costs only when fixed cash, funding or other cash adjustments are required.
6. Enter a Point Value Override when the automatic symbol value does not match the relevant contract specification.
7. Select the preferred layout, panel position, language, contrast and label configuration.
8. Create any required confirmed-bar alerts through TradingView's alert dialog.

Limitations

- All position information is entered manually.
- The script does not read an actual broker position.
- The script does not read Trading Panel account data.
- The script does not place, modify or close orders.
- Partial exits are not detected automatically.
- Position flips are not detected automatically.
- Remaining quantity must be updated manually.
- Realized P&L must be updated manually.
- Taxes are not calculated.
- Actual trading fees can differ by broker or exchange.
- Actual spread and slippage can differ from the entered assumptions.
- Funding and carry costs can vary over time.
- Currency conversion is not calculated automatically.
- Point value can differ by broker, exchange and contract specification.
- Cash P&L estimates depend on the accuracy of the selected point value.
- Live Price values can change while a realtime bar is open.
- Non-standard chart prices may not represent executable market prices.
- Alerts are disabled on non-standard charts.
- Results depend entirely on the accuracy of the user's inputs.
- The script is an arithmetic visualization and research tool.
- It is not financial advice or a trade recommendation.


日本語概要

このインジケーターは、手動入力したポジションの数量加重平均取得単価と、手数料、スプレッド、スリッページ、固定費、資金調達費などを反映した費用調整後の損益分岐価格を表示するオープンソースの研究ツールです。

主な機能:

- 既知の平均取得単価、または最大8件の個別約定から計算
- ロング・ショート双方に対応
- 平均取得単価、コスト差、損益分岐価格、現在価格との差を表示
- Campaign Recovery、Next Fill、Target Calculation
- 約定集中度、加重分散、実効約定件数
- 確定足による事実通知アラート
- 12言語のオンチャート表示

ポジション情報はすべて手動入力です。ブローカーのポジションやTrading Panelの口座情報を読み取らず、注文も送信しません。

表示結果は入力した価格、数量、手数料、ポイント価値などの正確性に依存します。本スクリプトは算術可視化・研究用であり、金融助言や売買推奨ではありません。

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// © SG_Group

//@version=6
// The chart legend (top-left) shows the full indicator name only: shorttitle == title.
indicator(title = "Average Entry Price and Fee-Adjusted Break-Even Workbench", shorttitle = "Average Entry Price and Fee-Adjusted Break-Even Workbench", overlay = true, max_lines_count = 24, max_labels_count = 30)

// ============================================================================
// CONSTANTS
// ============================================================================
NEAR_BE_TICKS = 1.0
MAX_FILLS     = 8
PRICE_EPS_MIN = 1e-10
FIN_LIMIT     = 1e15
PANEL_COLS    = 12
PANEL_ROWS    = 22
PANEL_SAFE_BOTTOM_ROW = 21   // PANEL_ROWS - 1; reserved transparent bottom clearance

CAMP_COLOR    = #ab47bc
PREVIEW_COLOR = #26a69a
FILL_COLOR    = #2962ff
TEAL_COLOR    = #26a69a
AMBER_COLOR   = #ff9800

MODE_DIRECT   = "Known average"
MODE_FILLS    = "Individual fills"
SIDE_LONG     = "Long"
SIDE_SHORT    = "Short"
FRIC_TICKS    = "Ticks"
FRIC_PRICE    = "Price units"
LAY_CLEAN     = "Clean"
LAY_MINIMAL   = "Minimal"
LAY_OVERVIEW  = "Overview"
LAY_RESEARCH  = "Research"
LAY_CUSTOM    = "Custom"
PANEL_OFF     = "Off"
PANEL_COMPACT = "Compact"
PANEL_OVERVIEW= "Overview"
PANEL_DETAIL  = "Detailed"
VAL_ALL       = "Require all selected rows"
VAL_VALID     = "Use valid rows only"
TIMING_NOW    = "Current state"
TIMING_START  = "From start time"
PRICE_LIVE    = "Live price"
PRICE_CONF    = "Confirmed close"
TGT_AVG       = "Average price"
TGT_BE        = "Fee-adjusted Break-Even"

ROW_HEAD  = 0
ROW_PRIM  = 1
ROW_NORM  = 2
ROW_WARN  = 3

// The public interface is intentionally English-only.

// Label layout modes and contrast modes
LAYOUT_AUTO  = "Auto"
LAYOUT_SPLIT = "Split"
LAYOUT_COMB  = "Combined"
LAYOUT_RIGHT = "Right edge"
LAYOUT_OFF   = "Off"
CONTRAST_AUTO = "Auto"
CONTRAST_HIGH = "High"
CONTRAST_SOFT = "Soft"

// ============================================================================
// INPUTS  (all use display = display.none; only the shorttitle shows top-left)
// ============================================================================
// ---- 01 - Position ---------------------------------------------------------
G1 = "01 - Position"
positionSource = input.string(MODE_DIRECT, "[P1] Input method", options = [MODE_DIRECT, MODE_FILLS], group = G1, display = display.none, tooltip = "Known average: type an average you already hold. Individual fills: build it from up to 8 entries.")
isDirect = positionSource == MODE_DIRECT
isFills  = positionSource == MODE_FILLS
positionSide = input.string(SIDE_LONG, "[P2] Position side", options = [SIDE_LONG, SIDE_SHORT], group = G1, display = display.none, tooltip = "Long or Short.")
directAvg    = input.price(0.0, "[P3] Average price", group = G1, active = isDirect, confirm = false, display = display.none, tooltip = "Your average entry price. Nothing is drawn while it is 0.")
directQty    = input.float(0.0, "[P4] Position quantity", minval = 0.0, step = 0.0001, group = G1, active = isDirect, confirm = false, display = display.none, tooltip = "Quantity held (positive). Nothing is drawn while it is 0.")

// ---- 02 - Costs - Optional -------------------------------------------------
G2 = "02 - Costs - Optional"
entryFeePct = input.float(0.0, "[C1] Entry fee (%)", minval = -50.0, maxval = 50.0, step = 0.001, group = G2, display = display.none, tooltip = "Percent of entry notional. Positive = fee, negative = rebate. 0 = none.")
exitFeePct  = input.float(0.0, "[C2] Exit fee (%)", minval = -50.0, maxval = 50.0, step = 0.001, group = G2, display = display.none, tooltip = "Percent of exit notional, solved into the break-even. Positive = fee, negative = rebate.")
frictionTicks = input.float(0.0, "[C3] Exit friction (ticks)", minval = 0.0, step = 0.1, group = G2, display = display.none, tooltip = "Slippage/spread on exit, in ticks. 0 = none.")
detailedCosts = input.bool(false, "[C4] Detailed cash costs", group = G2, display = display.none, tooltip = "Add fixed, carry and other cash costs. When off they are excluded from the math and need no point value.")
fixedEntry    = input.float(0.0, "[C5] Fixed entry cost per order", minval = 0.0, step = 0.01, group = G2, active = detailedCosts, display = display.none, tooltip = "Fixed cash cost per order. Positive = cost. Needs point value.")
directOrders  = input.int(1, "[C6] Entry orders", minval = 0, group = G2, active = detailedCosts and isDirect and fixedEntry > 0, display = display.none, tooltip = "Order count for the fixed entry cost (Known average). In Individual fills it equals the used fill count.")
fixedExit     = input.float(0.0, "[C7] Fixed exit cost", minval = 0.0, step = 0.01, group = G2, active = detailedCosts, display = display.none, tooltip = "Fixed cash cost to close. Positive = cost. Needs point value.")
carryCost     = input.float(0.0, "[C8] Carry / funding", step = 0.01, group = G2, active = detailedCosts, display = display.none, tooltip = "Positive = cost, negative = credit. Needs point value.")
otherCost     = input.float(0.0, "[C9] Other cost or credit", step = 0.01, group = G2, active = detailedCosts, display = display.none, tooltip = "Positive = cost, negative = credit. Needs point value.")

// ---- 03 - Individual Fills -------------------------------------------------
G3 = "03 - Individual Fills"
numFills = input.int(1, "[F1] Number of fills", minval = 1, maxval = MAX_FILLS, group = G3, active = isFills, display = display.none, tooltip = "How many fills count. Rows beyond this are ignored.")
fP1 = input.price(0.0, "[F2] Fill 1", inline = "f1", group = G3, active = isFills and numFills >= 1, display = display.none, tooltip = "Price and quantity of the fill; both must be > 0 to count.")
fQ1 = input.float(0.0, "Qty", inline = "f1", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 1, display = display.none)
fP2 = input.price(0.0, "[F3] Fill 2", inline = "f2", group = G3, active = isFills and numFills >= 2, display = display.none)
fQ2 = input.float(0.0, "Qty", inline = "f2", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 2, display = display.none)
fP3 = input.price(0.0, "[F4] Fill 3", inline = "f3", group = G3, active = isFills and numFills >= 3, display = display.none)
fQ3 = input.float(0.0, "Qty", inline = "f3", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 3, display = display.none)
fP4 = input.price(0.0, "[F5] Fill 4", inline = "f4", group = G3, active = isFills and numFills >= 4, display = display.none)
fQ4 = input.float(0.0, "Qty", inline = "f4", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 4, display = display.none)
fP5 = input.price(0.0, "[F6] Fill 5", inline = "f5", group = G3, active = isFills and numFills >= 5, display = display.none)
fQ5 = input.float(0.0, "Qty", inline = "f5", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 5, display = display.none)
fP6 = input.price(0.0, "[F7] Fill 6", inline = "f6", group = G3, active = isFills and numFills >= 6, display = display.none)
fQ6 = input.float(0.0, "Qty", inline = "f6", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 6, display = display.none)
fP7 = input.price(0.0, "[F8] Fill 7", inline = "f7", group = G3, active = isFills and numFills >= 7, display = display.none)
fQ7 = input.float(0.0, "Qty", inline = "f7", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 7, display = display.none)
fP8 = input.price(0.0, "[F9] Fill 8", inline = "f8", group = G3, active = isFills and numFills >= 8, display = display.none)
fQ8 = input.float(0.0, "Qty", inline = "f8", group = G3, minval = 0.0, step = 0.0001, active = isFills and numFills >= 8, display = display.none)

// ---- 04 - Research - Optional ----------------------------------------------
G4 = "04 - Research - Optional"
showCampaign  = input.bool(false, "[R1] Campaign recovery", group = G4, display = display.none, tooltip = "Include realized P&L from prior exits to find the price that recovers the whole campaign. Not a guarantee.")
realizedPnl   = input.float(0.0, "[R2] Realized P&L", step = 0.01, group = G4, active = showCampaign, display = display.none, tooltip = "Positive = realized profit (lowers recovery), negative = loss (raises it). Needs point value.")
enableNextFill= input.bool(false, "[R3] Next fill", group = G4, display = display.none, tooltip = "Preview average and break-even after a proposed fill. Arithmetic only; not a recommendation.")
nextPrice     = input.price(0.0, "[R4] Next price", group = G4, active = enableNextFill, display = display.none, tooltip = "Proposed additional fill price.")
nextQty       = input.float(0.0, "[R5] Next quantity", minval = 0.0, step = 0.0001, group = G4, active = enableNextFill, display = display.none, tooltip = "Proposed additional quantity.")
enableTarget  = input.bool(false, "[R6] Target calculation", group = G4, display = display.none, tooltip = "Arithmetic quantity required to reach a target. Not a recommended size.")
targetType    = input.string(TGT_AVG, "[R7] Target type", options = [TGT_AVG, TGT_BE], group = G4, active = enableTarget, display = display.none, tooltip = "Solve to reach a target average price or a target fee-adjusted break-even.")
targetPrice   = input.price(0.0, "[R8] Target price", group = G4, active = enableTarget, display = display.none, tooltip = "Desired average or break-even, depending on Target type.")
tgtFillPrice  = input.price(0.0, "[R9] Additional fill price", group = G4, active = enableTarget, display = display.none, tooltip = "Price of the proposed additional fill used by the solver.")

// ---- 05 - Display ----------------------------------------------------------
G5 = "05 - Display"
layout    = input.string(LAY_OVERVIEW, "[D1] Layout", options = [LAY_CLEAN, LAY_MINIMAL, LAY_OVERVIEW, LAY_RESEARCH, LAY_CUSTOM], group = G5, display = display.none, tooltip = "Overview (default): expanded labels, cost-gap label, fill ladder for quick cost-basis reading. Clean: lines+gap+labels. Minimal: lines+labels. Research: adds detailed paths. Custom: choose below.")
infoPanel = input.string(PANEL_OVERVIEW, "[D2] Position Panel", options = [PANEL_OFF, PANEL_COMPACT, PANEL_OVERVIEW, PANEL_DETAIL], group = G5, display = display.none, tooltip = "Overview (default): a Position Cost Flow card. Off, Compact (meters) or Detailed also available.")
panelPos  = input.string("Bottom Left", "[D3] Panel position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Left","Middle Right"], group = G5, display = display.none, tooltip = "Where the Position Panel sits.")
panelClear = input.string("Auto", "[D4] Bottom-left clearance", options = ["Auto","Extra","Off"], group = G5, active = panelPos == "Bottom Left", display = display.none, tooltip = "Reserves transparent space above the chart's bottom-left platform mark. Use Extra for small windows or high browser zoom.")
// [D5]-[D6] retired with the former language controls.
contrastMode = input.string(CONTRAST_AUTO, "[D7] Contrast mode", options = [CONTRAST_AUTO, CONTRAST_HIGH, CONTRAST_SOFT], group = G5, display = display.none, tooltip = "Auto: light label/panel backgrounds from the chart theme. High: opaque backgrounds and a stronger line halo. Soft: faint backgrounds.")
labelLayout  = input.string(LAYOUT_AUTO, "[D8] Label layout", options = [LAYOUT_AUTO, LAYOUT_SPLIT, LAYOUT_COMB, LAYOUT_RIGHT, LAYOUT_OFF], group = G5, display = display.none, tooltip = "Auto: Average on the left, Break-Even on the right; merges them when their prices are visually close. Split: always separate positions. Combined: one merged label. Right edge: legacy right-side lanes. Off: lines and panel only.")
showCvbNote  = input.bool(false, "[D9] Show Current vs BE chart note", group = G5, display = display.none, tooltip = "Optional on-chart Current-vs-Break-Even note. The Position Panel always shows this value. Off by default to avoid label crowding.")
showSetupGuide = input.bool(false, "[D10] Show setup guide", group = G5, display = display.none, tooltip = "Adds a few rows to the Position Panel mapping the settings field IDs ([P1]..) to their English control names.")
meterRangePct = input.float(1.0, "[D11] Panel meter range (%)", minval = 0.01, maxval = 100.0, step = 0.01, group = G5, display = display.none, tooltip = "Full-scale of the CURRENT VS BE / COST IMPACT meters, in percent.")
isCustom  = layout == LAY_CUSTOM
avgColorIn = input.color(#00b0ff, "[D12] Average color", group = G5, active = isCustom, display = display.none)
beColorIn  = input.color(#ff9800, "[D13] Break-even color", group = G5, active = isCustom, display = display.none)
avgWidthIn = input.int(2, "[D14] Average width", minval = 1, maxval = 5, group = G5, active = isCustom, display = display.none)
beWidthIn  = input.int(3, "[D15] Break-even width", minval = 1, maxval = 5, group = G5, active = isCustom, display = display.none)
gapVisIn   = input.int(10, "[D16] Gap visibility", minval = 0, maxval = 100, group = G5, active = isCustom, display = display.none, tooltip = "0 = invisible, 100 = opaque.")
labelTextIn= input.color(color.white, "[D17] Label text color", group = G5, active = isCustom, display = display.none)
panelSizeIn= input.string("Small", "[D18] Panel size", options = ["Tiny","Small","Normal","Large"], group = G5, active = isCustom, display = display.none)
baseOffsetIn = input.int(3, "[D19] Base label offset", minval = 0, maxval = 400, group = G5, active = isCustom, display = display.none)
laneSpacingIn= input.int(5, "[D20] Label lane spacing", minval = 1, maxval = 30, group = G5, active = isCustom, display = display.none)
minSepIn   = input.int(8, "[D21] Minimum separation (ticks)", minval = 1, maxval = 500, group = G5, active = isCustom, display = display.none)
customPaths   = input.bool(false, "[D22] Historical paths", group = G5, active = isCustom, display = display.none, tooltip = "Show historical average / break-even step paths (needs dated fills).")
customMarkers = input.bool(false, "[D23] Fill markers", group = G5, active = isCustom, display = display.none, tooltip = "Mark each active fill (dated fills).")
showGapLabel  = input.bool(false, "[D24] Show Cost Gap label", group = G5, active = isCustom, display = display.none, tooltip = "Adds a small COST GAP - FEES + FRICTION label between the average and break-even. Always on in Overview and Research.")

// ---- 06 - Advanced ---------------------------------------------------------
G6 = "06 - Advanced"
pvOverride  = input.float(0.0, "[A1] Point value override", minval = 0.0, maxval = 1e9, step = 0.0001, group = G6, display = display.none, tooltip = "0 = Auto (syminfo.pointvalue). Above 0 = cash value of one price unit per unit of quantity. Always applied.")
fillValidation = input.string(VAL_ALL, "[A2] Fill validation", options = [VAL_ALL, VAL_VALID], group = G6, active = isFills, display = display.none, tooltip = "Require all selected rows, or use only the valid rows.")
positionTiming = input.string(TIMING_NOW, "[A3] Position timing", options = [TIMING_NOW, TIMING_START], group = G6, active = isDirect, display = display.none, tooltip = "Current state: active as soon as you enter it. From start time: active from a chosen time.")
directStart = input.time(1717372800000, "[A4] Position start time", group = G6, active = isDirect and positionTiming == TIMING_START, display = display.none, tooltip = "Used only with Position timing = From start time.")
lineSpan    = input.int(150, "[A5] Current line span (bars)", minval = 10, maxval = 5000, group = G6, display = display.none, tooltip = "How far back the current lines are drawn when there is no explicit start.")
useDatedFills = input.bool(false, "[A6] Use dated fills", group = G6, active = isFills, display = display.none, tooltip = "Give each fill a time so it counts only from then and enables historical paths.")
fricUnit    = input.string(FRIC_TICKS, "[A7] Exit friction unit", options = [FRIC_TICKS, FRIC_PRICE], group = G6, active = detailedCosts, display = display.none, tooltip = "Interpret exit friction as ticks or raw price.")
fricPrice   = input.float(0.0, "[A8] Exit friction (price)", minval = 0.0, step = 0.0001, group = G6, active = detailedCosts and fricUnit == FRIC_PRICE, display = display.none, tooltip = "Friction as a raw price amount.")
fT1 = input.time(1717372800000, "[A9] Fill 1 time", group = G6, active = isFills and useDatedFills and numFills >= 1, display = display.none)
fT2 = input.time(1717459200000, "[A10] Fill 2 time", group = G6, active = isFills and useDatedFills and numFills >= 2, display = display.none)
fT3 = input.time(1717545600000, "[A11] Fill 3 time", group = G6, active = isFills and useDatedFills and numFills >= 3, display = display.none)
fT4 = input.time(1717632000000, "[A12] Fill 4 time", group = G6, active = isFills and useDatedFills and numFills >= 4, display = display.none)
fT5 = input.time(1717718400000, "[A13] Fill 5 time", group = G6, active = isFills and useDatedFills and numFills >= 5, display = display.none)
fT6 = input.time(1717977600000, "[A14] Fill 6 time", group = G6, active = isFills and useDatedFills and numFills >= 6, display = display.none)
fT7 = input.time(1718064000000, "[A15] Fill 7 time", group = G6, active = isFills and useDatedFills and numFills >= 7, display = display.none)
fT8 = input.time(1718150400000, "[A16] Fill 8 time", group = G6, active = isFills and useDatedFills and numFills >= 8, display = display.none)
panelPriceMode = input.string(PRICE_LIVE, "[A17] Panel price mode", options = [PRICE_LIVE, PRICE_CONF], group = G6, display = display.none, tooltip = "Live price updates intrabar; Confirmed close uses the last confirmed bar. Alerts are always confirmed-bar.")
probeSynthetic = input.bool(false, "[A18] Use current price on non-standard charts", group = G6, display = display.none, tooltip = "On synthetic charts (Heikin Ashi, Renko, ...) the close is not a tradable price. Off by default.")
visualLookback = input.int(150, "[A19] Visual separation lookback (bars)", minval = 10, maxval = 1000, group = G6, display = display.none, tooltip = "Bars used to estimate the visible price range for label spacing. Not pixel detection — a proxy for how far apart levels look on screen.")
atrSepFactor   = input.float(0.20, "[A20] ATR separation factor", minval = 0.0, maxval = 5.0, step = 0.01, group = G6, display = display.none, tooltip = "Share of ATR(14) used when deciding if two labels are visually close. Higher = merges labels sooner.")
rangeSepPct    = input.float(0.01, "[A21] Range separation (fraction)", minval = 0.0, maxval = 1.0, step = 0.001, group = G6, display = display.none, tooltip = "Share of the visible high-low range used for visual label spacing (0.01 = 1%). Higher = merges labels sooner.")

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
f_isFinite(x) => not na(x) and math.abs(x) < FIN_LIMIT
f_nearZero(x) => na(x) ? true : math.abs(x) < 1e-9
f_approxEqual(a, b) => na(a) or na(b) ? false : math.abs(a - b) <= 1e-9 * math.max(1.0, math.abs(a), math.abs(b)) + 1e-12
f_safeDivide(n, d) => (na(n) or na(d) or f_nearZero(d)) ? na : n / d
f_validMintick() => not na(syminfo.mintick) and syminfo.mintick > 0

// English display-text keys (index into f_tr). Generated; do not renumber without regenerating.
TXT_POSITION_COST_FLOW = 1
TXT_INPUT = 2
TXT_WEIGHTED_AVG = 3
TXT_COST_IMPACT = 4
TXT_BREAK_EVEN = 5
TXT_CURRENT_VS_BE = 6
TXT_FILLS = 7
TXT_KNOWN_AVG = 8
TXT_LONG = 9
TXT_SHORT = 10
TXT_LIVE_ESTIMATE = 11
TXT_CLOSE_CONFIRMED = 12
TXT_COST_GAP = 13
TXT_FEES_FRICTION = 14
TXT_NEAR_BE_FULL = 15
TXT_ABOVE_BE_FULL = 16
TXT_BELOW_BE_FULL = 17
TXT_SETUP_POSITION = 18
TXT_SETUP_FILLS = 19
TXT_SETUP_POSITION_HINT = 20
TXT_SETUP_FILLS_HINT = 21
TXT_STATUS_INSUFFICIENT = 22
TXT_STATUS_CALC_FAILED = 23
TXT_STATUS_PV_NEEDED = 24
TXT_STATUS_NO_POSITION = 25
TXT_STATUS_SYNTH = 26
TXT_STATUS_NEAR = 27
TXT_STATUS_FAVORABLE = 28
TXT_STATUS_UNFAVORABLE = 29
TXT_WARN_PV_CASH = 30
TXT_WARN_SYNTH = 31
TXT_WARN_USED = 32
TXT_WARN_OF = 33
TXT_WARN_FUTURE_IGNORED = 34
TXT_MODEL_FULL_CASH = 35
TXT_MODEL_PRICE_ONLY = 36
TXT_MODEL_PV_NEEDED = 37
TXT_ROW_MODEL = 38
TXT_ROW_QUANTITY = 39
TXT_ROW_NET_PNL = 40
TXT_ROW_CAMPAIGN_BE = 41
TXT_ROW_NEXT_FILL_BE = 42
TXT_ROW_QTY_REQUIRED = 43
TXT_ROW_CONCENTRATION = 44
TXT_ROW_DISPERSION = 45
TXT_ROW_RESIDUAL = 46
TXT_ROW_STATUS = 47
TXT_ROW_PV_LABEL = 48
TXT_ROW_PV_VALUE = 49
TXT_ROW_CHART = 50
TXT_ROW_NOTE = 51
TXT_SOLVER_ENTER = 52
TXT_SOLVER_FILL_EQ = 53
TXT_SOLVER_BETWEEN = 54
TXT_SOLVER_NOT_POSITIVE = 55
TXT_SOLVER_NO_SOLUTION = 56
TXT_SOLVER_CHECK_FAILED = 57
TXT_TT_AVG = 58
TXT_TT_BE = 59
TXT_TT_CAM = 60
TXT_TT_NEXT = 61
TXT_TT_COMBINED = 62
TXT_SG_P1 = 63
TXT_SG_P2 = 64
TXT_SG_P3 = 65
TXT_SG_P4 = 66
TXT_SG_C1 = 67
TXT_SG_C2 = 68
TXT_SG_C3 = 69
TXT_SG_F1 = 70
TXT_COST_BASIS = 71
TXT_COST_DELTA = 72
TXT_VS_BE = 73
TXT_ABOVE_BE_SHORT = 74
TXT_BELOW_BE_SHORT = 75
TXT_NEAR_BE_SHORT = 76
TXT_CLOSE_SHORT = 77
TXT_LIVE_SHORT = 78
TXT_SETUP_STEP_AVG = 79
TXT_SETUP_STEP_QTY = 80
TXT_SETUP_STEP_COUNT = 81
TXT_SETUP_STEP_PRICE = 82
TXT_SETUP_OPTIONAL = 83

// f_tr(key): returns the fixed English display string for a key.
f_tr(key) =>
    switch key
        1 => "POSITION COST FLOW"
        2 => "INPUT"
        3 => "WEIGHTED AVG"
        4 => "COST IMPACT"
        5 => "BREAK-EVEN"
        6 => "CURRENT VS BE"
        7 => "FILLS"
        8 => "KNOWN AVG"
        9 => "LONG"
        10 => "SHORT"
        11 => "LIVE ESTIMATE"
        12 => "CLOSE CONFIRMED"
        13 => "COST GAP"
        14 => "FEES + FRICTION"
        15 => "NEAR COST-ADJUSTED BREAK-EVEN"
        16 => "ABOVE COST-ADJUSTED BREAK-EVEN"
        17 => "BELOW COST-ADJUSTED BREAK-EVEN"
        18 => "SET UP A POSITION"
        19 => "SET UP FILLS"
        20 => "Open Settings to enter average price and quantity"
        21 => "Enter fill prices and quantities"
        22 => "Insufficient input"
        23 => "Calculation check failed"
        24 => "Point value needed for cash costs"
        25 => "No active position"
        26 => "Synthetic chart price"
        27 => "Near break-even"
        28 => "Favorable side of break-even"
        29 => "Unfavorable side of break-even"
        30 => "POINT VALUE NEEDED FOR CASH COSTS"
        31 => "SYNTHETIC CHART PRICE"
        32 => "USED"
        33 => "OF"
        34 => "FUTURE FILL(S) IGNORED"
        35 => "FULL CASH"
        36 => "PRICE ONLY"
        37 => "POINT VALUE NEEDED"
        38 => "Model"
        39 => "Quantity"
        40 => "Net P&L"
        41 => "Campaign BE"
        42 => "Next fill BE"
        43 => "Qty required"
        44 => "Concentration"
        45 => "Dispersion"
        46 => "Residual"
        47 => "STATUS"
        48 => "POINT VALUE"
        49 => "Required for cash costs"
        50 => "CHART"
        51 => "NOTE"
        52 => "Enter target and fill price"
        53 => "Fill price cannot equal target"
        54 => "Target must be between average and fill price"
        55 => "Required quantity is not positive"
        56 => "No solution at this fill price"
        57 => "Solver check failed"
        58 => "Weighted average entry price"
        59 => "Cost-adjusted (fee-adjusted) break-even price"
        60 => "Campaign recovery break-even price"
        61 => "Next-fill preview break-even price"
        62 => "Average, break-even and cost impact"
        63 => "Input method"
        64 => "Position side"
        65 => "Average price"
        66 => "Position quantity"
        67 => "Entry fee"
        68 => "Exit fee"
        69 => "Exit friction"
        70 => "Number of fills"
        71 => "COST BASIS"
        72 => "COST Δ"
        73 => "VS BE"
        74 => "ABOVE BE"
        75 => "BELOW BE"
        76 => "NEAR BE"
        77 => "CLOSE"
        78 => "LIVE"
        79 => "AVG PRICE"
        80 => "QTY"
        81 => "COUNT"
        82 => "PRICE"
        83 => "OPTIONAL"
        => ""

f_timeReached(ts) =>
    barstate.isrealtime ? (timenow >= ts) : (na(time_close) ? time >= ts : time_close > ts)

f_roundToTick(price) =>
    not f_validMintick() or na(price) ? price : math.round(price / syminfo.mintick) * syminfo.mintick

f_roundOutward(price, isLong) =>
    result = price
    if not na(price) and f_validMintick()
        ticks   = price / syminfo.mintick
        nearest = math.round(ticks)
        onTick  = math.abs(ticks - nearest) < 1e-6
        stepped = onTick ? nearest : (isLong ? math.ceil(ticks) : math.floor(ticks))
        result := stepped * syminfo.mintick
    result

// Price-normalized net and break-even (independent of point value).
f_normalizedNetLong(E, e, r, s, c, P)  => (1.0 - r) * (P - s) - (1.0 + e) * E - c
f_normalizedNetShort(E, e, r, s, c, P) => (1.0 - e) * E - (1.0 + r) * (P + s) - c

f_breakEvenLong(E, e, r, s, c) =>
    den = 1.0 - r
    (na(E) or na(c) or f_nearZero(den)) ? na : s + ((1.0 + e) * E + c) / den

f_breakEvenShort(E, e, r, s, c) =>
    den = 1.0 + r
    (na(E) or na(c) or f_nearZero(den)) ? na : ((1.0 - e) * E - c) / den - s

f_breakEvenResidual(isLong, E, e, r, s, c, be) =>
    na(be) ? na : (isLong ? f_normalizedNetLong(E, e, r, s, c, be) : f_normalizedNetShort(E, e, r, s, c, be))

f_getTablePos(s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Middle Right" => position.middle_right
        "Middle Left"  => position.middle_left
        => position.bottom_left

f_txtSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_fmtPrice(p) => na(p) ? "—" : f_validMintick() ? str.tostring(p, format.mintick) : str.tostring(p)
f_fmtCash(c)  => na(c) ? "—" : str.tostring(c, "#,##0.##") + " " + syminfo.currency
f_fmtQty(q)   => na(q) ? "—" : str.tostring(q, "#,##0.####")
f_fmtSignedPrice(d) => na(d) ? "—" : (d > 0 ? "+" : "") + (f_validMintick() ? str.tostring(d, format.mintick) : str.tostring(d))
f_fmtSignedPct(p)   => na(p) ? "—" : (p > 0 ? "+" : "") + str.tostring(p, "#,##0.##") + "%"

// Persistent line update using bar-time coordinates (no bar_index draw limit).
f_showLineT(ln, show, x1t, x2t, y, col, w, styl) =>
    if show and not na(y) and not na(x1t)
        line.set_xy1(ln, x1t, y)
        line.set_xy2(ln, x2t, y)
        line.set_color(ln, col)
        line.set_width(ln, w)
        line.set_style(ln, styl)
        line.set_extend(ln, extend.right)
    else
        line.set_color(ln, na)
        line.set_xy1(ln, x2t, na)
        line.set_xy2(ln, x2t, na)

f_lbl(lb, show, x, y, txt, bgCol, txtCol, sz, styl, tip) =>
    if show and not na(y)
        label.set_xy(lb, x, y)
        label.set_text(lb, txt)
        label.set_color(lb, bgCol)
        label.set_textcolor(lb, txtCol)
        label.set_style(lb, styl)
        label.set_size(lb, sz)
        label.set_tooltip(lb, tip)
    else
        label.set_xy(lb, bar_index, na)
        label.set_text(lb, "")
        label.set_color(lb, na)
        label.set_tooltip(lb, "")

// ============================================================================
// POSITION CALCULATIONS
// ============================================================================
isLong        = positionSide == SIDE_LONG
directionSign = isLong ? 1.0 : -1.0

var pArr = array.from(fP1, fP2, fP3, fP4, fP5, fP6, fP7, fP8)
var qArr = array.from(fQ1, fQ2, fQ3, fQ4, fQ5, fQ6, fQ7, fQ8)
var tArr = array.from(fT1, fT2, fT3, fT4, fT5, fT6, fT7, fT8)

var int startBarIndex = na

float qNow    = na
float avgNow  = na
int   orderCount = 0
int   usedFills  = 0
int   selectedValid = 0
int   futureFills = 0
int   firstMissRow = 0
string firstMissField = ""
bool  outOfOrder = false
int   latestFillTime = na
float dispersion = na
float effFillCount = na
float largestShare = na
bool  blockRequireAll = false

requireAll = fillValidation == VAL_ALL

if isFills
    qSum = 0.0
    mean = 0.0
    m2   = 0.0
    sumSq= 0.0
    maxQ = 0.0
    cnt  = 0
    sel  = 0
    fut  = 0
    int prevT = na
    for i = 0 to MAX_FILLS - 1
        if (i + 1) <= numFills
            pi = array.get(pArr, i)
            qi = array.get(qArr, i)
            ti = array.get(tArr, i)
            validRow = f_isFinite(pi) and pi > 0 and f_isFinite(qi) and qi > 0
            if validRow
                sel += 1
            else if firstMissRow == 0
                firstMissRow := i + 1
                firstMissField := not (f_isFinite(pi) and pi > 0) ? "PRICE" : "QUANTITY"
            reached = not useDatedFills or f_timeReached(ti)
            if validRow and reached
                newQ  = qSum + qi
                delta = pi - mean
                mean := mean + delta * (qi / newQ)
                m2   := m2 + qi * delta * (pi - mean)
                qSum := newQ
                sumSq += qi * qi
                maxQ := math.max(maxQ, qi)
                cnt  += 1
                if na(latestFillTime) or ti > latestFillTime
                    latestFillTime := ti
                if useDatedFills and not na(prevT) and ti < prevT
                    outOfOrder := true
                prevT := ti
            else if validRow and useDatedFills and not reached
                fut += 1
    selectedValid := sel
    futureFills   := fut
    blockRequireAll := requireAll and firstMissRow > 0
    if not blockRequireAll and qSum > 0
        qNow    := qSum
        avgNow  := mean
        orderCount := cnt
        usedFills  := cnt
        dispersion := math.sqrt(math.max(0.0, m2 / qSum))
        effFillCount := sumSq > 0 ? qSum * qSum / sumSq : na
        largestShare := qSum > 0 ? maxQ / qSum : na
else
    reached = positionTiming == TIMING_START ? f_timeReached(directStart) : true
    if reached and f_isFinite(directQty) and directQty > 0 and f_isFinite(directAvg) and directAvg > 0
        qNow    := directQty
        avgNow  := directAvg
        orderCount := directOrders
        usedFills  := 1

isValidPos = f_isFinite(avgNow) and f_isFinite(qNow) and qNow > 0

// Point value + model status
pvRaw   = pvOverride > 0 ? pvOverride : syminfo.pointvalue
pvValid = f_isFinite(pvRaw) and pvRaw > 0
pv      = pvValid ? pvRaw : na
A       = isValidPos and pvValid ? qNow * pv : na

if isValidPos and na(startBarIndex)
    startBarIndex := bar_index

// Costs (normalized). e,r price-based; C = fixed cash only.
e = entryFeePct / 100.0
r = exitFeePct / 100.0
s = detailedCosts and fricUnit == FRIC_PRICE ? fricPrice : frictionTicks * (f_validMintick() ? syminfo.mintick : 0.0)

fixedCash = detailedCosts ? (fixedEntry * orderCount + fixedExit + carryCost + otherCost) : 0.0
cashPresent = not f_nearZero(fixedCash)

string modelStatus = "PRICE ONLY"
float cUnit = 0.0
if isValidPos
    if pvValid
        cUnit := f_nearZero(A) ? na : fixedCash / A
        modelStatus := "FULL CASH"
    else if not cashPresent
        cUnit := 0.0
        modelStatus := "PRICE ONLY"
    else
        cUnit := na
        modelStatus := "POINT VALUE NEEDED"

E = avgNow
beRaw = isValidPos ? (isLong ? f_breakEvenLong(E, e, r, s, cUnit) : f_breakEvenShort(E, e, r, s, cUnit)) : na

// Runtime residual self-check
resid = f_breakEvenResidual(isLong, E, e, r, s, cUnit, beRaw)
residTol = math.max((f_validMintick() ? syminfo.mintick : 1e-6) * 1e-6, math.abs(nz(beRaw)) * 1e-9, 1e-9)
calcHealthy = isValidPos and not na(beRaw) and f_isFinite(beRaw) and not na(resid) and math.abs(resid) <= residTol

// Campaign (needs cash)
campCashUnit = pvValid and not na(cUnit) and f_isFinite(A) and not f_nearZero(A) ? cUnit - realizedPnl / A : na
campBeRaw = isValidPos and pvValid ? (isLong ? f_breakEvenLong(E, e, r, s, campCashUnit) : f_breakEvenShort(E, e, r, s, campCashUnit)) : na

avgDisp  = f_roundToTick(avgNow)
beDisp   = calcHealthy ? f_roundOutward(beRaw, isLong) : na
campDisp = f_roundOutward(campBeRaw, isLong)

// ============================================================================
// NEXT-FILL SCENARIO
// ============================================================================
float previewAvg = na
float previewBeRaw = na
float previewQty = na
if enableNextFill and isValidPos and f_isFinite(nextPrice) and nextPrice > 0 and f_isFinite(nextQty) and nextQty > 0
    nQ = qNow + nextQty
    nAvg = (qNow * E + nextQty * nextPrice) / nQ
    nFixedCash = detailedCosts ? (fixedEntry * (orderCount + 1) + fixedExit + carryCost + otherCost) : 0.0
    nCunit = pvValid ? (nFixedCash / (nQ * pv)) : (f_nearZero(nFixedCash) ? 0.0 : na)
    previewAvg := nAvg
    previewQty := nQ
    previewBeRaw := isLong ? f_breakEvenLong(nAvg, e, r, s, nCunit) : f_breakEvenShort(nAvg, e, r, s, nCunit)
previewBeDisp = f_roundOutward(previewBeRaw, isLong)

// ============================================================================
// TARGET SOLVER (Average price or Fee-adjusted Break-Even)
// ============================================================================
float qtyNeeded = na
int  solverKey = 0        // 0 = not shown; otherwise a TXT_* key. Localized at display.
bool solverOk  = false
if enableTarget
    if not isValidPos
        solverKey := TXT_STATUS_NO_POSITION
    else if not (f_isFinite(targetPrice) and f_isFinite(tgtFillPrice))
        solverKey := TXT_SOLVER_ENTER
    else if targetType == TGT_AVG
        denom = targetPrice - tgtFillPrice
        between = (targetPrice - E) * (targetPrice - tgtFillPrice) < 0
        if f_nearZero(denom)
            solverKey := TXT_SOLVER_FILL_EQ
        else if not between
            solverKey := TXT_SOLVER_BETWEEN
        else
            x = qNow * (E - targetPrice) / denom
            qtyNeeded := f_isFinite(x) and x > 0 ? x : na
            solverOk  := f_isFinite(x) and x > 0
            solverKey := solverOk ? 0 : TXT_SOLVER_NOT_POSITIVE
    else
        nFixedCash = detailedCosts ? (fixedEntry * (orderCount + 1) + fixedExit + carryCost + otherCost) : 0.0
        needPv = not f_nearZero(nFixedCash)
        if needPv and not pvValid
            solverKey := TXT_STATUS_PV_NEEDED
        else
            cashTerm = needPv ? nFixedCash / pv : 0.0
            K = isLong ? (targetPrice - s) * (1.0 - r) : (targetPrice + s) * (1.0 + r)
            num = isLong ? ((1.0 + e) * qNow * E + cashTerm - K * qNow) : ((1.0 - e) * qNow * E - cashTerm - K * qNow)
            den = isLong ? (K - (1.0 + e) * tgtFillPrice) : (K - (1.0 - e) * tgtFillPrice)
            if f_nearZero(den)
                solverKey := TXT_SOLVER_NO_SOLUTION
            else
                x = num / den
                if f_isFinite(x) and x > 0
                    // reinjection check
                    nQ = qNow + x
                    nAvg = (qNow * E + x * tgtFillPrice) / nQ
                    nCunit = needPv ? nFixedCash / (nQ * pv) : 0.0
                    chkBe = isLong ? f_breakEvenLong(nAvg, e, r, s, nCunit) : f_breakEvenShort(nAvg, e, r, s, nCunit)
                    qtyNeeded := (not na(chkBe) and f_approxEqual(chkBe, targetPrice)) ? x : na
                    solverOk  := not na(qtyNeeded)
                    solverKey := solverOk ? 0 : TXT_SOLVER_CHECK_FAILED
                else
                    solverKey := TXT_SOLVER_NOT_POSITIVE

// ============================================================================
// PROBE PRICE, NET P&L, BUFFERS
// ============================================================================
isStandard = chart.is_standard
useProbe   = isStandard or probeSynthetic
confClose  = barstate.isrealtime ? close[1] : close
rawProbe   = panelPriceMode == PRICE_CONF ? confClose : close
probePrice = useProbe ? rawProbe : na
priceModeText = panelPriceMode == PRICE_CONF ? f_tr(TXT_CLOSE_CONFIRMED) : (barstate.isrealtime ? f_tr(TXT_LIVE_ESTIMATE) : f_tr(TXT_CLOSE_CONFIRMED))

normNet = calcHealthy and not na(probePrice) ? (isLong ? f_normalizedNetLong(E, e, r, s, cUnit, probePrice) : f_normalizedNetShort(E, e, r, s, cUnit, probePrice)) : na
cashPnl = pvValid and f_isFinite(A) and not na(normNet) ? A * normNet : na

priceEps = math.max(f_validMintick() ? syminfo.mintick : PRICE_EPS_MIN, PRICE_EPS_MIN)
beBuffer     = na(beRaw) or na(probePrice) ? na : directionSign * (probePrice - beRaw)
beBufferPct  = na(beBuffer) ? na : beBuffer / math.max(math.abs(beRaw), priceEps) * 100.0
costLoad     = na(beRaw) or na(E) ? na : directionSign * (beRaw - E)
costLoadPct  = na(costLoad) ? na : costLoad / math.max(math.abs(E), priceEps) * 100.0
beBufferTicks= na(beBuffer) or not f_validMintick() ? na : beBuffer / syminfo.mintick

int statusKey = TXT_STATUS_INSUFFICIENT
if isValidPos and not calcHealthy and not na(beRaw)
    statusKey := TXT_STATUS_CALC_FAILED
else if isValidPos and modelStatus == "POINT VALUE NEEDED"
    statusKey := TXT_STATUS_PV_NEEDED
else if not isValidPos
    statusKey := TXT_STATUS_NO_POSITION
else if na(probePrice)
    statusKey := TXT_STATUS_SYNTH
else if na(beBuffer)
    statusKey := TXT_STATUS_INSUFFICIENT
else if not na(beBufferTicks) and math.abs(beBufferTicks) <= NEAR_BE_TICKS
    statusKey := TXT_STATUS_NEAR
else if beBuffer > 0
    statusKey := TXT_STATUS_FAVORABLE
else
    statusKey := TXT_STATUS_UNFAVORABLE

// ============================================================================
// DETERMINISTIC PRESETS -> effective visibility/appearance
// ============================================================================
isOverview = layout == LAY_OVERVIEW
effAvgColor = isCustom ? avgColorIn : #00b0ff
effBeColor  = isCustom ? beColorIn  : #ff9800
effAvgWidth = isCustom ? avgWidthIn : isOverview ? 4 : 2
effBeWidth  = isCustom ? beWidthIn  : isOverview ? 4 : 3
effGapVis   = isCustom ? gapVisIn   : isOverview ? 24 : 10
effLabelText= isCustom ? labelTextIn: color.white
effBaseOff  = isCustom ? baseOffsetIn : 3
effLaneGap  = isCustom ? laneSpacingIn : 5
effMinSep   = isCustom ? minSepIn   : 8
effShowGap     = (layout == LAY_CLEAN or isOverview or layout == LAY_RESEARCH or (isCustom and effGapVis > 0))
effShowAvgPath = (isOverview or layout == LAY_RESEARCH or (isCustom and customPaths)) and isFills and useDatedFills
effShowBePath  = (layout == LAY_RESEARCH or (isCustom and customPaths)) and isFills and useDatedFills
effShowMarkers = (isOverview or layout == LAY_RESEARCH or (isCustom and customMarkers)) and isFills and useDatedFills
effShowGapLbl  = (isOverview or layout == LAY_RESEARCH or (isCustom and showGapLabel))
effLblSize     = isCustom ? f_txtSize(panelSizeIn) : isOverview ? size.normal : size.small
panelSize = isOverview ? "Normal" : isCustom ? panelSizeIn : "Small"
// Undated Fill Ladder: show fill price levels in Overview when fills have no dates
showLadder = isOverview and isFills and not useDatedFills

// ============================================================================
// CONTRAST + VISUAL-SEPARATION + LABEL-LAYOUT DERIVATIONS  (global, every bar)
// ============================================================================
// Contrast mode -> label / panel / halo / combined background opacity.
isHighC = contrastMode == CONTRAST_HIGH
isSoftC = contrastMode == CONTRAST_SOFT
lblBgT  = isHighC ? 0  : isSoftC ? 14 : 8      // right-edge label background transparency
cardBgT = isHighC ? 2  : isSoftC ? 14 : 8      // panel cell background
warnBgT = isHighC ? 0  : isSoftC ? 16 : 10     // warning cell background
haloT   = isHighC ? 30 : isSoftC ? 70 : 55     // line shadow (halo) transparency
combBgT = isHighC ? 0  : isSoftC ? 10 : 4      // combined-label near-opaque background
meterTrackT = isHighC ? 50 : isSoftC ? 80 : 66 // meter empty-track transparency (lower = more visible)

// Visual separation for label collision. This is NOT pixel detection: Pine cannot read
// zoom/DPI. It is a price-space proxy for "how far apart two levels look on screen",
// taken as the largest of a tick floor, a share of ATR(14) and a share of the visible range.
atrValue   = nz(ta.atr(14))
rangeProxy = nz(ta.highest(high, visualLookback) - ta.lowest(low, visualLookback))
tickFloor  = effMinSep * (f_validMintick() ? syminfo.mintick : 0.0)
visualSeparation = math.max(tickFloor, atrValue * atrSepFactor, rangeProxy * rangeSepPct)

// Auto lane spacing in bars: wider when the line span (a zoom proxy) is larger.
autoLaneBars = math.max(20, math.min(100, int(math.round(lineSpan * 0.25))))
effLaneBars  = isCustom ? effLaneGap : autoLaneBars

// Resolve the label layout. Auto splits AVG(left)/BE(right); merges to a Combined
// label when their prices are visually close. Campaign/Next yield to the primary labels.
gapAbs    = (not na(avgDisp) and not na(beDisp)) ? math.abs(beDisp - avgDisp) : na
beNearAvg = not na(gapAbs) and gapAbs < visualSeparation
labelsOff    = labelLayout == LAYOUT_OFF
useCombined  = not labelsOff and (labelLayout == LAYOUT_COMB or (labelLayout == LAYOUT_AUTO and beNearAvg))
useRightEdge = not labelsOff and labelLayout == LAYOUT_RIGHT
useSplit     = not labelsOff and not useCombined and not useRightEdge   // Split, or Auto-not-close

// ============================================================================
// HISTORICAL STEP PATHS (display.pane -> off the status line)
// ============================================================================
avgPathSeries = isFills and useDatedFills and isValidPos ? avgNow : na
plot(effShowAvgPath ? avgPathSeries : na, title = "Historical average cost path", color = color.new(effAvgColor, 45), style = plot.style_stepline, linewidth = 1, display = display.pane)
plot(effShowBePath and calcHealthy ? beRaw : na, title = "Historical fee-adjusted break-even path", color = color.new(effBeColor, 55), style = plot.style_stepline, linewidth = 1, display = display.pane)

// ============================================================================
// ANCHOR TIME for the current lines (bar-time; no bar_index limit)
// ============================================================================
barMs = timeframe.in_seconds() > 0 ? timeframe.in_seconds() * 1000 : (na(time[1]) ? 60000 : time - time[1])
anchorTime = isFills and useDatedFills ? latestFillTime : (isDirect and positionTiming == TIMING_START ? directStart : time - lineSpan * barMs)

// ============================================================================
// DRAWING OBJECTS  (created once on the first bar; reused via set_*)
// ============================================================================
// Shadow (halo) lines are created first so they render behind the main lines.
var line  avgShadow  = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  beShadow   = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  campShadow = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  nextShadow = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  avgLine  = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  beLine   = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  campLine = line.new(na, na, na, na, xloc = xloc.bar_time)
var line  nextLine = line.new(na, na, na, na, xloc = xloc.bar_time)
var linefill gapFill = linefill.new(avgLine, beLine, na)
var label avgLbl  = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_left)
var label beLbl   = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_left)
var label campLbl = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_left)
var label nextLbl = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_left)
var label costGapLbl = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_center)
var label curVsBeLbl = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_left)
var label combinedCostLabel = label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_left)
var label[] fillLabels = array.new<label>()
var line[]  fillLevelLines  = array.new<line>()
var label[] fillLevelLabels = array.new<label>()
if barstate.isfirst
    for k = 0 to MAX_FILLS - 1
        array.push(fillLabels, label.new(int(na), na, "", xloc = xloc.bar_time, style = label.style_label_down))
        array.push(fillLevelLines, line.new(na, na, na, na, xloc = xloc.bar_index))
        array.push(fillLevelLabels, label.new(bar_index, na, "", xloc = xloc.bar_index, style = label.style_label_right))
var table panel = table.new(position.bottom_left, PANEL_COLS, PANEL_ROWS, bgcolor = na)
// Setup guide: field IDs mapped to English control names.
var string[] sgIds  = array.from("[P1]", "[P2]", "[P3]", "[P4]", "[C1]", "[C2]", "[C3]", "[F1]")
var int[]    sgKeys = array.from(TXT_SG_P1, TXT_SG_P2, TXT_SG_P3, TXT_SG_P4, TXT_SG_C1, TXT_SG_C2, TXT_SG_C3, TXT_SG_F1)

// 7-segment meter starting at column mcol (compact). trackT = empty-track transparency
// (lower = more visible); the centre column (j==3) always marks the break-even midpoint;
// segW = per-cell width % (0 = auto). Fill runs from the centre toward the value position.
f_meter(t, rw, mcol, value, rng, favPos, tSize, trackT, segW) =>
    dimC = color.new(color.gray, trackT)            // empty track (clearly visible band)
    midC = color.new(color.gray, 20)                // break-even midpoint marker
    pos = 3
    if not na(value) and not na(rng) and rng > 0
        pos := int(math.round(math.max(-3.0, math.min(3.0, value / rng * 3.0)))) + 3
    for j = 0 to 6
        filled = j >= math.min(3, pos) and j <= math.max(3, pos)
        favDir = (pos > 3) == favPos
        segc = j == 3 ? midC : not filled ? dimC : (favDir ? TEAL_COLOR : AMBER_COLOR)
        table.cell(t, mcol + j, rw, " ", bgcolor = segc, text_size = tSize, width = segW)

// Write a label/value pair into the given label and value columns of a panel row.
f_pcell2(t, rw, lcol, vcol, a, b, tc, sz, bg) =>
    table.cell(t, lcol, rw, a, text_color = tc, text_size = sz, text_halign = text.align_left, bgcolor = bg)
    table.cell(t, vcol, rw, b, text_color = tc, text_size = sz, text_halign = text.align_left, bgcolor = bg)

// One text size larger, for the Overview tile values.
f_txtSizeUp(s) =>
    switch s
        "Tiny"   => size.small
        "Small"  => size.normal
        "Normal" => size.large
        => size.large

// Fill a span of columns with one background; text goes in the first cell only.
f_tileRow(t, rw, cfirst, clast, txt, tc, sz, bg) =>
    for cc = cfirst to clast
        table.cell(t, cc, rw, cc == cfirst ? txt : "", text_color = tc, text_size = sz, text_halign = text.align_left, bgcolor = bg)

// One panel cell with explicit width/height (% of chart; 0 = auto). Used by the compact
// Overview to give the columns deterministic widths instead of relying on auto-sizing.
f_panelCell(t, col, rw, txt, wPct, hPct, tc, sz, halign, bg) =>
    table.cell(t, col, rw, txt, width = wPct, height = hPct, text_color = tc, text_size = sz, text_halign = halign, bgcolor = bg)

// Fill a span with one background at a fixed per-column width; text (if any) in the first cell.
f_panelSpan(t, cfirst, clast, rw, txt, wPct, hPct, tc, sz, halign, bg) =>
    for cc = cfirst to clast
        table.cell(t, cc, rw, cc == cfirst ? txt : "", width = wPct, height = hPct, text_color = tc, text_size = sz, text_halign = cc == cfirst ? halign : text.align_left, bgcolor = bg)

// Panel cell with a tooltip — used by the compact Overview to carry the full English
// name of each short tile/row (AVG, COST Δ, BE, VS BE, status) without widening the panel.
f_panelCellTip(t, col, rw, txt, wPct, hPct, tc, sz, halign, bg, tip) =>
    table.cell(t, col, rw, txt, width = wPct, height = hPct, text_color = tc, text_size = sz, text_halign = halign, bgcolor = bg, tooltip = tip)

if barstate.islast
    themeText = chart.fg_color
    cardBg = color.new(chart.bg_color, cardBgT)
    warnBg = color.new(#ff6d00, warnBgT)
    tSize  = f_txtSize(panelSize)

    // ---- current lines: shadow (halo) behind, then the themed line ----
    shadowCol = color.new(chart.fg_color, haloT)
    f_showLineT(avgShadow , isValidPos, anchorTime, time, avgDisp, shadowCol, effAvgWidth + 3, line.style_solid)
    f_showLineT(beShadow  , calcHealthy, anchorTime, time, beDisp, shadowCol, effBeWidth + 3, line.style_dashed)
    f_showLineT(campShadow, showCampaign and calcHealthy, anchorTime, time, campDisp, shadowCol, 4, line.style_dotted)
    f_showLineT(nextShadow, enableNextFill and isValidPos and not na(previewBeDisp), anchorTime, time, previewBeDisp, shadowCol, 3, line.style_dashed)
    f_showLineT(avgLine , isValidPos, anchorTime, time, avgDisp, effAvgColor, effAvgWidth, line.style_solid)
    f_showLineT(beLine  , calcHealthy, anchorTime, time, beDisp, effBeColor, effBeWidth, line.style_dashed)
    f_showLineT(campLine, showCampaign and calcHealthy, anchorTime, time, campDisp, CAMP_COLOR, 2, line.style_dotted)
    f_showLineT(nextLine, enableNextFill and isValidPos and not na(previewBeDisp), anchorTime, time, previewBeDisp, color.new(PREVIEW_COLOR, 40), 1, line.style_dashed)

    gapVisible = effShowGap and calcHealthy and not na(avgDisp) and not na(beDisp)
    linefill.set_color(gapFill, gapVisible ? color.new(effBeColor, 100 - effGapVis) : na)

    // ---- Collision-free label layout ----------------------------------------
    // Priority: BE > AVG > Cost Impact > Campaign > Next > Current-vs-BE note.
    // Short labels (AVG / BE / CAM / NEXT) keep a fixed width across languages; the
    // full English name is on each label's tooltip. Price levels never move — only
    // the labels do (via visual-separation-based placement, not pixel detection).
    aOn = isValidPos and not na(avgDisp)
    bOn = calcHealthy and not na(beDisp)
    cOn = showCampaign and calcHealthy and not na(campDisp)
    nOn = enableNextFill and isValidPos and not na(previewBeDisp)
    xR  = bar_index + effBaseOff
    xL  = math.max(0, bar_index - effLaneBars)

    // Combined label (Auto-when-close or Combined mode): AVG + BE + DELTA in one box.
    showCombo = useCombined and aOn and bOn
    comboY = (not na(avgDisp) and not na(beDisp)) ? (avgDisp + beDisp) / 2.0 : avgDisp
    comboTxt = "AVG " + f_fmtPrice(avgDisp) + "\nBE " + f_fmtPrice(beDisp) + "\nDELTA " + f_fmtSignedPrice(costLoad) + " / " + f_fmtSignedPct(costLoadPct)
    f_lbl(combinedCostLabel, showCombo, xR, comboY, comboTxt, color.new(chart.bg_color, combBgT), themeText, effLblSize, label.style_label_left, f_tr(TXT_TT_COMBINED))

    // Individual AVG / BE (Split: AVG left + BE right; Right edge / Auto-not-close: right).
    beAvgClose = aOn and bOn and math.abs(beDisp - avgDisp) < visualSeparation
    avgShow = aOn and not showCombo and not labelsOff
    beShow  = bOn and not showCombo and not labelsOff
    avgAtLeft = useSplit and bOn                     // split with both -> AVG on the left
    avgLaneR  = (useRightEdge and beAvgClose) ? effLaneBars : 0
    avgX = avgAtLeft ? xL : (xR + avgLaneR)
    avgStyle = avgAtLeft ? label.style_label_right : label.style_label_left
    f_lbl(avgLbl, avgShow, avgX, avgDisp, "AVG " + f_fmtPrice(avgDisp), color.new(effAvgColor, lblBgT), effLabelText, effLblSize, avgStyle, f_tr(TXT_TT_AVG))
    f_lbl(beLbl , beShow , xR, beDisp, "BE " + f_fmtPrice(beDisp), color.new(effBeColor, lblBgT), effLabelText, effLblSize, label.style_label_left, f_tr(TXT_TT_BE))

    // Campaign / Next yield to the primary labels: hidden on-chart when visually close
    // to AVG or BE (the values still appear in the Detailed panel).
    campClose = cOn and ((aOn and math.abs(campDisp - avgDisp) < visualSeparation) or (bOn and math.abs(campDisp - beDisp) < visualSeparation))
    nextClose = nOn and ((aOn and math.abs(previewBeDisp - avgDisp) < visualSeparation) or (bOn and math.abs(previewBeDisp - beDisp) < visualSeparation) or (cOn and math.abs(previewBeDisp - campDisp) < visualSeparation))
    campShow = cOn and not campClose and not labelsOff and not showCombo
    nextShow = nOn and not nextClose and not labelsOff and not showCombo
    f_lbl(campLbl, campShow, xR, campDisp, "CAM " + f_fmtPrice(campDisp), color.new(CAMP_COLOR, lblBgT), effLabelText, effLblSize, label.style_label_left, f_tr(TXT_TT_CAM))
    f_lbl(nextLbl, nextShow, xR, previewBeDisp, "NEXT " + f_fmtPrice(previewBeDisp), color.new(PREVIEW_COLOR, lblBgT), effLabelText, effLblSize, label.style_label_left, f_tr(TXT_TT_NEXT))

    // ---- fill markers (bar-time; dated fills only) ----
    for i = 0 to MAX_FILLS - 1
        lb = array.get(fillLabels, i)
        pi = array.get(pArr, i)
        qi = array.get(qArr, i)
        ti = array.get(tArr, i)
        validRow = f_isFinite(pi) and pi > 0 and f_isFinite(qi) and qi > 0
        showThis = effShowMarkers and isValidPos and (i + 1) <= numFills and validRow and f_timeReached(ti)
        if showThis
            share = qi / qNow * 100.0
            markerTxt = isOverview ? ("F" + str.tostring(i + 1) + "  " + str.tostring(share, "#,##0") + "%") : ("F" + str.tostring(i + 1) + "  " + str.tostring(qi, "#,##0.##") + "  " + str.tostring(share, "#,##0.#") + "%")
            label.set_xy(lb, ti, pi)
            label.set_text(lb, markerTxt)
            label.set_color(lb, FILL_COLOR)
            label.set_textcolor(lb, effLabelText)
            label.set_style(lb, label.style_label_down)
            label.set_size(lb, size.tiny)
        else
            label.set_xy(lb, int(na), na)
            label.set_text(lb, "")
            label.set_color(lb, na)

    // ---- Undated Fill Ladder (Overview, individual fills, no dates) ----
    ladX1 = math.max(0, bar_index - 32)
    ladX2 = math.max(1, bar_index - 16)
    for i = 0 to MAX_FILLS - 1
        lvl = array.get(fillLevelLines, i)
        llb = array.get(fillLevelLabels, i)
        pi = array.get(pArr, i)
        qi = array.get(qArr, i)
        validRow = f_isFinite(pi) and pi > 0 and f_isFinite(qi) and qi > 0
        showLad = showLadder and isValidPos and (i + 1) <= numFills and validRow
        if showLad
            ladShare = qi / qNow * 100.0
            line.set_xy1(lvl, ladX1, pi)
            line.set_xy2(lvl, ladX2, pi)
            line.set_color(lvl, color.new(FILL_COLOR, 25))
            line.set_width(lvl, 1)
            line.set_style(lvl, line.style_solid)
            line.set_extend(lvl, extend.none)
            label.set_xy(llb, ladX1, pi)
            label.set_text(llb, "F" + str.tostring(i + 1) + "  " + str.tostring(ladShare, "#,##0") + "%")
            label.set_color(llb, color.new(FILL_COLOR, 15))
            label.set_textcolor(llb, effLabelText)
            label.set_style(llb, label.style_label_right)
            label.set_size(llb, size.small)
        else
            line.set_color(lvl, na)
            line.set_xy1(lvl, bar_index, na)
            line.set_xy2(lvl, bar_index, na)
            label.set_xy(llb, bar_index, na)
            label.set_text(llb, "")
            label.set_color(llb, na)

    // ---- Cost Impact / Cost Gap label (between the lines; only when there is room) ----
    // Shown only when the AVG-to-BE gap is wide enough to be legible (>= visualSeparation)
    // and the labels are not merged into the Combined box; otherwise the value stays in
    // the panel and only the clean AVG / BE lines remain.
    gapMid = not na(avgDisp) and not na(beDisp) ? (avgDisp + beDisp) / 2.0 : na
    showCostGapLbl = effShowGapLbl and calcHealthy and effShowGap and not beNearAvg and not showCombo and not labelsOff and not na(gapMid)
    if showCostGapLbl
        gapOff = math.max(12, math.min(30, int(lineSpan / 4)))
        gapLblTxt = isOverview ? (f_tr(TXT_COST_IMPACT) + "\n" + f_fmtSignedPrice(costLoad) + " / " + f_fmtSignedPct(costLoadPct)) : (f_tr(TXT_COST_GAP) + "\n" + f_tr(TXT_FEES_FRICTION))
        label.set_xy(costGapLbl, math.max(0, bar_index - (showLadder ? 8 : gapOff)), gapMid)
        label.set_text(costGapLbl, gapLblTxt)
        label.set_color(costGapLbl, color.new(AMBER_COLOR, 80))
        label.set_textcolor(costGapLbl, effLabelText)
        label.set_style(costGapLbl, label.style_label_center)
        label.set_size(costGapLbl, size.small)
    else
        label.set_xy(costGapLbl, bar_index, na)
        label.set_text(costGapLbl, "")
        label.set_color(costGapLbl, na)

    // ---- Current vs Break-Even chart note (opt-in; the panel always shows this value) ----
    // Off by default to avoid crowding; hidden when current price sits within
    // visualSeparation of BE (where it would overlap the BE label).
    showCvb = showCvbNote and calcHealthy and isStandard and not labelsOff and not na(beRaw) and not na(probePrice) and not na(beBuffer) and math.abs(beBuffer) >= visualSeparation
    if showCvb
        label.set_xy(curVsBeLbl, bar_index + 2, (probePrice + beRaw) / 2.0)
        label.set_text(curVsBeLbl, f_tr(TXT_CURRENT_VS_BE) + "\n" + f_fmtSignedPrice(beBuffer) + " / " + f_fmtSignedPct(beBufferPct))
        label.set_color(curVsBeLbl, color.new(color.gray, 30))
        label.set_textcolor(curVsBeLbl, effLabelText)
        label.set_style(curVsBeLbl, label.style_label_left)
        label.set_size(curVsBeLbl, size.small)
    else
        label.set_xy(curVsBeLbl, bar_index, na)
        label.set_text(curVsBeLbl, "")
        label.set_color(curVsBeLbl, na)

    // ---- Position Panel (bottom-left transparent Safe Area via spacer cells) ----
    useSafe = panelPos == "Bottom Left" and panelClear != "Off"
    colOff  = useSafe ? 1 : 0
    lcol    = colOff
    vcol    = colOff + 1
    mcol    = colOff + 2
    safeLeft   = panelClear == "Auto" ? 1.25 : panelClear == "Extra" ? 2.5 : 0.0
    safeBottom = panelClear == "Auto" ? 4.5  : panelClear == "Extra" ? 6.5 : 0.0

    table.set_position(panel, f_getTablePos(panelPos))
    table.clear(panel, 0, 0, PANEL_COLS - 1, PANEL_ROWS - 1)
    // transparent left gutter + bottom clearance (Bottom Left only, clearance on)
    if useSafe
        table.cell(panel, 0, 0, "", width = safeLeft, bgcolor = na)
        table.cell(panel, 0, PANEL_SAFE_BOTTOM_ROW, "", width = safeLeft, height = safeBottom, bgcolor = na)
    modelTxt = modelStatus == "FULL CASH" ? f_tr(TXT_MODEL_FULL_CASH) : modelStatus == "PRICE ONLY" ? f_tr(TXT_MODEL_PRICE_ONLY) : f_tr(TXT_MODEL_PV_NEEDED)
    if infoPanel != PANEL_OFF
        detail = infoPanel == PANEL_DETAIL
        row = 0
        // Shared compact grid — the empty state and the Overview use the same columns/widths.
        ovA = lcol            // AVG tile / VS BE label / header / status / step 1
        ovB = lcol + 1        // COST Δ tile / VS BE value / step 2
        ovC = lcol + 2        // BE tile / step 3
        ovM = lcol + 3        // 7-segment meter start
        ovLast = lcol + 9     // last content column
        wA = 8.0
        wB = 11.0
        wC = 8.0
        wM = 1.1
        if not isValidPos
            // Empty state = compact setup card at the Overview width. Neutral, not a warning:
            // a title band and three numbered step chips naming what to enter, coloured by role
            // (cyan = price/count entry, neutral = quantity, muted amber = optional costs).
            // No numbers and no fake AVG / BE / fills / P&L — it is "before start", not an error.
            titleBg = color.new(color.gray, isSoftC ? 60 : 46)
            cyanBg  = color.new(#00b0ff, isSoftC ? 78 : 66)
            neutBg  = color.new(color.gray, isSoftC ? 72 : 60)
            optBg   = color.new(#ff9800, isSoftC ? 84 : 74)
            eTitle = isDirect ? f_tr(TXT_SETUP_POSITION) : f_tr(TXT_SETUP_FILLS)
            s1 = "1  " + (isDirect ? f_tr(TXT_SETUP_STEP_AVG) : f_tr(TXT_SETUP_STEP_COUNT))
            s2 = "2  " + (isDirect ? f_tr(TXT_SETUP_STEP_QTY) : f_tr(TXT_SETUP_STEP_PRICE))
            s3 = "3  " + (isDirect ? f_tr(TXT_SETUP_OPTIONAL) : f_tr(TXT_SETUP_STEP_QTY))
            s3bg = isDirect ? optBg : neutBg
            f_panelCell(panel, ovA, 0, eTitle, wA, 0.0, themeText, size.small, text.align_left, titleBg)
            f_panelCell(panel, ovB, 0, "", wB, 0.0, themeText, size.small, text.align_left, titleBg)
            f_panelCell(panel, ovC, 0, "", wC, 0.0, themeText, size.small, text.align_left, titleBg)
            f_panelSpan(panel, ovM, ovLast, 0, "", wM, 0.0, themeText, size.small, text.align_left, titleBg)
            f_panelCell(panel, ovA, 1, s1, wA, 0.0, themeText, size.small, text.align_left, cyanBg)
            f_panelCell(panel, ovB, 1, s2, wB, 0.0, themeText, size.small, text.align_left, neutBg)
            f_panelCell(panel, ovC, 1, s3, wC, 0.0, themeText, size.small, text.align_left, s3bg)
            f_panelSpan(panel, ovM, ovLast, 1, "", wM, 0.0, themeText, size.small, text.align_left, cardBg)
            row := 2
        else if infoPanel == PANEL_OVERVIEW
            // Compact 4-row Overview (excluding warnings): a short header, three metric tiles
            // (AVG / COST Δ / BE), a VS BE row with a 7-segment meter, and a short status pill.
            // Explicit column widths keep the footprint small instead of relying on table
            // auto-sizing. The INPUT tile and the big flow header are gone; full names and all
            // research values live in the Detailed panel, tooltips and docs. (Grid columns
            // ovA/ovB/ovC/ovM/ovLast and widths wA/wB/wC/wM are defined once, above.)
            hdrSz  = size.small
            tileSz = size.normal
            vsSz   = size.small
            // Light, low header (chart-background based) + faint category tiles read with the
            // chart text color in both themes. COST Δ is muted so AVG / BE dominate.
            hdrBg    = color.new(chart.bg_color, isHighC ? 0 : 12)
            avgBg    = color.new(#00b0ff, isSoftC ? 78 : 66)
            impactBg = color.new(#f57c00, isSoftC ? 84 : 74)
            beBg     = color.new(#ff9800, isSoftC ? 78 : 66)
            cvbChip  = color.new(color.gray, isSoftC ? 66 : 54)
            // Row 0 — compact header: COST BASIS | mode | side · price-mode
            modeTxt  = isFills ? (str.tostring(usedFills) + " " + f_tr(TXT_FILLS)) : f_tr(TXT_KNOWN_AVG)
            sideTxt  = isLong ? f_tr(TXT_LONG) : f_tr(TXT_SHORT)
            closeTxt = panelPriceMode == PRICE_CONF ? f_tr(TXT_CLOSE_SHORT) : (barstate.isrealtime ? f_tr(TXT_LIVE_SHORT) : f_tr(TXT_CLOSE_SHORT))
            f_panelCell(panel, ovA, 0, f_tr(TXT_COST_BASIS), wA, 0.0, themeText, hdrSz, text.align_left, hdrBg)
            f_panelCell(panel, ovB, 0, modeTxt, wB, 0.0, themeText, hdrSz, text.align_left, hdrBg)
            f_panelCell(panel, ovC, 0, sideTxt + "  ·  " + closeTxt, wC, 0.0, themeText, hdrSz, text.align_left, hdrBg)
            f_panelSpan(panel, ovM, ovLast, 0, "", wM, 0.0, themeText, hdrSz, text.align_left, hdrBg)
            // Row 1 — three metric tiles (short label above value)
            impactVal = na(costLoad) ? "—" : f_fmtSignedPrice(costLoad) + " / " + f_fmtSignedPct(costLoadPct)
            f_panelCellTip(panel, ovA, 1, "AVG\n" + f_fmtPrice(avgDisp), wA, 0.0, themeText, tileSz, text.align_left, avgBg, f_tr(TXT_TT_AVG))
            f_panelCellTip(panel, ovB, 1, f_tr(TXT_COST_DELTA) + "\n" + impactVal, wB, 0.0, themeText, tileSz, text.align_left, impactBg, f_tr(TXT_COST_IMPACT))
            f_panelCellTip(panel, ovC, 1, "BE\n" + (na(beDisp) ? "—" : f_fmtPrice(beDisp)), wC, 0.0, themeText, tileSz, text.align_left, beBg, f_tr(TXT_TT_BE))
            f_panelSpan(panel, ovM, ovLast, 1, "", wM, 0.0, themeText, tileSz, text.align_left, beBg)
            // Row 2 — VS BE: short label, compact value, 7-segment meter on the same row
            cvbRange = meterRangePct / 100.0 * math.max(math.abs(nz(beRaw)), priceEps)
            cvbVal = na(beBuffer) ? "—" : f_fmtSignedPrice(beBuffer) + " / " + f_fmtSignedPct(beBufferPct)
            f_panelCellTip(panel, ovA, 2, f_tr(TXT_VS_BE), wA, 0.0, themeText, vsSz, text.align_left, cvbChip, f_tr(TXT_CURRENT_VS_BE))
            f_panelCell(panel, ovB, 2, cvbVal, wB, 0.0, themeText, vsSz, text.align_left, cvbChip)
            f_panelCell(panel, ovC, 2, "", wC, 0.0, themeText, vsSz, text.align_left, cvbChip)
            f_meter(panel, 2, ovM, beBuffer, cvbRange, true, vsSz, meterTrackT, wM)
            // Row 3 — short status pill; the full phrase is on the pill's tooltip + Detailed panel
            cvbNear  = not na(beBufferTicks) and math.abs(beBufferTicks) <= NEAR_BE_TICKS
            cvbAbove = not na(probePrice) and not na(beRaw) and probePrice > beRaw
            shortStat = na(probePrice) or na(beRaw) ? f_tr(statusKey) : (cvbNear ? f_tr(TXT_NEAR_BE_SHORT) : cvbAbove ? f_tr(TXT_ABOVE_BE_SHORT) : f_tr(TXT_BELOW_BE_SHORT))
            fullStat  = na(probePrice) or na(beRaw) ? f_tr(statusKey) : (cvbNear ? f_tr(TXT_NEAR_BE_FULL) : cvbAbove ? f_tr(TXT_ABOVE_BE_FULL) : f_tr(TXT_BELOW_BE_FULL))
            concBg = (na(probePrice) or na(beRaw) or cvbNear) ? color.new(color.gray, isHighC ? 58 : 72) : cvbAbove ? color.new(TEAL_COLOR, isHighC ? 62 : 80) : color.new(AMBER_COLOR, isHighC ? 62 : 80)
            f_panelCellTip(panel, ovA, 3, shortStat, wA, 0.0, themeText, vsSz, text.align_left, concBg, fullStat)
            f_panelCell(panel, ovB, 3, "", wB, 0.0, themeText, vsSz, text.align_left, concBg)
            f_panelCell(panel, ovC, 3, "", wC, 0.0, themeText, vsSz, text.align_left, concBg)
            f_panelSpan(panel, ovM, ovLast, 3, "", wM, 0.0, themeText, vsSz, text.align_left, concBg)
            // Warnings (only when applicable; excluded from the 4-row target)
            orow = 4
            if modelStatus == "POINT VALUE NEEDED"
                f_tileRow(panel, orow, ovA, ovLast, f_tr(TXT_WARN_PV_CASH), color.white, vsSz, warnBg)
                orow += 1
            if not isStandard
                f_tileRow(panel, orow, ovA, ovLast, f_tr(TXT_WARN_SYNTH), color.white, vsSz, warnBg)
                orow += 1
            if isFills and not requireAll and selectedValid < numFills
                f_tileRow(panel, orow, ovA, ovLast, f_tr(TXT_WARN_USED) + " " + str.tostring(usedFills) + " " + f_tr(TXT_WARN_OF) + " " + str.tostring(numFills) + " " + f_tr(TXT_FILLS), color.white, vsSz, warnBg)
                orow += 1
            if futureFills > 0
                f_tileRow(panel, orow, ovA, ovLast, str.tostring(futureFills) + " " + f_tr(TXT_WARN_FUTURE_IGNORED), color.white, vsSz, warnBg)
                orow += 1
            row := orow
        else
            // Row 0: side | price mode
            table.cell(panel, lcol, row, isLong ? f_tr(TXT_LONG) : f_tr(TXT_SHORT), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            table.cell(panel, vcol, row, priceModeText, text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            row += 1
            table.cell(panel, lcol, row, "AVG", text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            table.cell(panel, vcol, row, f_fmtPrice(avgDisp), text_color = themeText, text_size = f_txtSize(panelSize), text_halign = text.align_left, bgcolor = cardBg)
            row += 1
            table.cell(panel, lcol, row, "BE", text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            table.cell(panel, vcol, row, na(beDisp) ? "—" : f_fmtPrice(beDisp), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            row += 1
            // CURRENT VS BE meter
            beRange = meterRangePct / 100.0 * math.max(math.abs(nz(beRaw)), priceEps)
            table.cell(panel, lcol, row, f_tr(TXT_CURRENT_VS_BE), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            table.cell(panel, vcol, row, na(beBuffer) ? "—" : f_fmtSignedPrice(beBuffer) + " / " + f_fmtSignedPct(beBufferPct), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            f_meter(panel, row, mcol, beBuffer, beRange, true, tSize, meterTrackT, 0)
            row += 1
            // COST IMPACT meter (positive cost = amber, so favorable-positive = false)
            costRange = meterRangePct / 100.0 * math.max(math.abs(nz(E)), priceEps)
            table.cell(panel, lcol, row, f_tr(TXT_COST_IMPACT), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            table.cell(panel, vcol, row, na(costLoad) ? "—" : f_fmtSignedPrice(costLoad) + " / " + f_fmtSignedPct(costLoadPct), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            f_meter(panel, row, mcol, costLoad, costRange, false, tSize, meterTrackT, 0)
            row += 1
            table.cell(panel, lcol, row, f_tr(TXT_ROW_STATUS), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            table.cell(panel, vcol, row, f_tr(statusKey), text_color = themeText, text_size = tSize, text_halign = text.align_left, bgcolor = cardBg)
            row += 1
            // warnings
            if modelStatus == "POINT VALUE NEEDED"
                table.cell(panel, lcol, row, f_tr(TXT_ROW_PV_LABEL), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                table.cell(panel, vcol, row, f_tr(TXT_ROW_PV_VALUE), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                row += 1
            if not isStandard
                table.cell(panel, lcol, row, f_tr(TXT_ROW_CHART), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                table.cell(panel, vcol, row, f_tr(TXT_STATUS_SYNTH), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                row += 1
            if isFills and not requireAll and selectedValid < numFills
                table.cell(panel, lcol, row, f_tr(TXT_FILLS), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                table.cell(panel, vcol, row, f_tr(TXT_WARN_USED) + " " + str.tostring(usedFills) + " " + f_tr(TXT_WARN_OF) + " " + str.tostring(numFills), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                row += 1
            if futureFills > 0
                table.cell(panel, lcol, row, f_tr(TXT_ROW_NOTE), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                table.cell(panel, vcol, row, str.tostring(futureFills) + " " + f_tr(TXT_WARN_FUTURE_IGNORED), text_color = color.white, text_size = tSize, text_halign = text.align_left, bgcolor = warnBg)
                row += 1
            // detailed rows
            if detail
                f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_MODEL), modelTxt, themeText, tSize, cardBg)
                row += 1
                f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_QUANTITY), f_fmtQty(qNow), themeText, tSize, cardBg)
                row += 1
                if pvValid
                    f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_NET_PNL), f_fmtCash(cashPnl), themeText, tSize, cardBg)
                    row += 1
                if showCampaign
                    f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_CAMPAIGN_BE), na(campDisp) ? "—" : f_fmtPrice(campDisp), themeText, tSize, cardBg)
                    row += 1
                if enableNextFill
                    f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_NEXT_FILL_BE), f_fmtPrice(previewBeDisp), themeText, tSize, cardBg)
                    row += 1
                if enableTarget
                    f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_QTY_REQUIRED), solverOk ? f_fmtQty(qtyNeeded) : (solverKey == 0 ? "—" : f_tr(solverKey)), themeText, tSize, cardBg)
                    row += 1
                if isFills and not na(largestShare)
                    f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_CONCENTRATION), str.tostring(largestShare * 100.0, "#,##0.#") + "%", themeText, tSize, cardBg)
                    row += 1
                if isFills and not na(dispersion)
                    f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_DISPERSION), f_fmtPrice(dispersion), themeText, tSize, cardBg)
                    row += 1
                f_pcell2(panel, row, lcol, vcol, f_tr(TXT_ROW_RESIDUAL), na(resid) ? "—" : str.tostring(resid, "#.#########"), themeText, tSize, cardBg)
                row += 1
        // ---- Setup guide (field IDs -> English control names) ---------------------
        if showSetupGuide
            gLast = mcol + 8
            for gi = 0 to array.size(sgIds) - 1
                if row <= PANEL_ROWS - 2
                    f_tileRow(panel, row, lcol, gLast, array.get(sgIds, gi) + "  " + f_tr(array.get(sgKeys, gi)), themeText, tSize, cardBg)
                    row += 1

// ============================================================================
// ALERTS (factual, confirmed bar, standard chart, healthy calc, stable level)
// ============================================================================
rawCrossAvg  = ta.cross(close, avgNow)
rawCrossBe   = ta.cross(close, beRaw)
rawCrossCamp = ta.cross(close, campBeRaw)
rawCrossNext = ta.cross(close, previewBeRaw)

loGap = na(avgNow) or na(beRaw) ? na : math.min(avgNow, beRaw)
hiGap = na(avgNow) or na(beRaw) ? na : math.max(avgNow, beRaw)
inGap = not na(loGap) and close >= loGap and close <= hiGap

gate = barstate.isconfirmed and isStandard and isValidPos and calcHealthy

avgStable  = f_approxEqual(avgNow, avgNow[1])
beStable   = f_approxEqual(beRaw, beRaw[1])
campStable = f_approxEqual(campBeRaw, campBeRaw[1])
nextStable = f_approxEqual(previewBeRaw, previewBeRaw[1])
gapPrev    = not na(loGap[1]) and close[1] >= loGap[1] and close[1] <= hiGap[1]

crossAvg   = gate and avgStable and rawCrossAvg
crossBe    = gate and beStable  and rawCrossBe
enteredGap = gate and avgStable and beStable and inGap and not gapPrev
exitedGap  = gate and avgStable and beStable and not inGap and gapPrev
crossCamp  = gate and showCampaign   and pvValid and campStable and not na(campBeRaw) and rawCrossCamp
crossNext  = gate and enableNextFill and nextStable and not na(previewBeRaw) and rawCrossNext

// Alert titles/messages are fixed English. They are
// concise and factual: no buy/sell wording and no advice. On-chart text is English-only.
alertcondition(crossAvg,   title = "Price crossed Average Entry", message = "{{ticker}} {{interval}}: price crossed the user-calculated average entry price. Close {{close}}.")
alertcondition(crossBe,    title = "Price crossed Break-Even", message = "{{ticker}} {{interval}}: price crossed the user-calculated cost-adjusted break-even price. Close {{close}}.")
alertcondition(enteredGap, title = "Price entered Cost Gap", message = "{{ticker}} {{interval}}: price entered the cost gap between average entry and break-even. Close {{close}}.")
alertcondition(exitedGap,  title = "Price exited Cost Gap", message = "{{ticker}} {{interval}}: price exited the cost gap between average entry and break-even. Close {{close}}.")
alertcondition(crossCamp,  title = "Price crossed Campaign Recovery Break-Even", message = "{{ticker}} {{interval}}: price crossed the user-calculated campaign recovery break-even price. Close {{close}}.")
alertcondition(crossNext,  title = "Price crossed Next-Fill Preview Break-Even", message = "{{ticker}} {{interval}}: price crossed the previewed next-fill break-even price. Close {{close}}.")
````
