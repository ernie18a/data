<!-- tradingview-pine-id: PUB;b47f14bee6404e72b4e6c3f2445b82ad -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Micro Futures Risk / Reward Calculator [V2]

Source: https://www.tradingview.com/script/vbM0gE53-Micro-Futures-Risk-Reward-Calculator-V2/

## Description

Because “eh, three contracts feels about right” is not a risk-management strategy.

The Micro Futures Risk / Reward Calculator is a visual position-sizing tool designed for traders who want to know exactly how many micro futures contracts they can trade before clicking Buy or Sell and suddenly discovering a new emotion.

Set your maximum dollar risk, then drag the red Stop Loss line to where your trade idea is officially wrong. The indicator automatically calculates:

- Stop distance in points and ticks
- Dollar risk per micro contract
- Maximum contracts, always rounded down
- Actual total dollar risk

When applying to different charts you must go to the top left corner on the chart where you see the name of the script, click the ... icon and click reset points

A green draggable Take Profit line also calculates your live risk-to-reward ratio. Trade direction is inferred automatically: a stop below the current price represents a long setup, while a stop above it represents a short setup.

The calculator uses TradingView’s built-in contract information, including `syminfo.pointvalue` and `syminfo.mintick`, so it can adapt across supported USD-denominated micro futures instead of pretending every instrument is MNQ.

Safety checks warn about invalid contract data, incorrectly positioned targets, zero-distance stops, unsupported symbols, and trades where even one contract would exceed the selected risk.

This is an indicator only. It does not place orders, generate entries, predict the market, contact your broker, or stop you from moving your stop because “it’ll probably come back.”

Built for one simple question:

“My stop belongs here, I’m willing to risk this much—how many micro contracts can I trade?”

For educational and risk-management purposes only. Always verify contract specifications and order details before trading.

---

## Source Code

````pine
//@version=6
indicator("Micro Futures Risk / Reward Calculator [V2]", shorttitle = "Micro V2", overlay = true, behind_chart = false)

// =============================================================================
// Inputs
// =============================================================================
string RISK_GROUP = "Risk Settings"

float maxDollarRisk = input.float(
     100.0,
     "Maximum Dollar Risk",
     minval = 0.01,
     step = 25.0,
     tooltip = "The most you are willing to lose on this trade, in USD.",
     group = RISK_GROUP)

float stopPrice = input.price(
     0.0,
     "Stop Loss",
     tooltip = "Drag this red price marker to the intended stop-loss level.",
     group = RISK_GROUP,
     confirm = true)

float takeProfitPrice = input.price(
     0.0,
     "Take Profit",
     tooltip = "Drag this green price marker to the intended take-profit level.",
     group = RISK_GROUP,
     confirm = true)

// Display the interactive prices as horizontal chart lines.
plot(stopPrice, "Stop Loss", color = color.rgb(239, 83, 80), linewidth = 2)
plot(takeProfitPrice, "Take Profit", color = color.rgb(38, 166, 154), linewidth = 2)

// =============================================================================
// Symbol validation and position sizing
// =============================================================================
float entryPrice = close
float pointValue = syminfo.pointvalue
float minimumTick = syminfo.mintick
string cleanTickerId = ticker.standard(syminfo.tickerid)

bool isFutures = syminfo.type == "futures"
bool isMicroContract = str.contains(str.lower(syminfo.description), "micro")
bool isUsdContract = syminfo.currency == "USD"
bool hasValidPointValue = not na(pointValue) and pointValue > 0
bool hasValidMinimumTick = not na(minimumTick) and minimumTick > 0
bool hasValidEntry = not na(entryPrice)
bool hasValidStop = not na(stopPrice)
bool hasValidTarget = not na(takeProfitPrice)
bool metadataIsValid = hasValidPointValue and hasValidMinimumTick
bool instrumentIsSupported = isFutures and isMicroContract and isUsdContract and metadataIsValid and hasValidEntry and hasValidStop

float stopDistancePoints = hasValidEntry and hasValidStop ? math.abs(entryPrice - stopPrice) : na
float stopDistanceTicks = hasValidMinimumTick and not na(stopDistancePoints) ? stopDistancePoints / minimumTick : na
bool stopHasDistance = not na(stopDistancePoints) and stopDistancePoints > 0

float riskPerContract = instrumentIsSupported and stopHasDistance ? stopDistancePoints * pointValue : na
int maxContracts = not na(riskPerContract) and riskPerContract > 0 ? int(math.floor(maxDollarRisk / riskPerContract)) : na
float actualDollarRisk = not na(maxContracts) and not na(riskPerContract) ? maxContracts * riskPerContract : na

// =============================================================================
// Direction and reward calculations
// =============================================================================
bool isLongSetup = stopHasDistance and stopPrice < entryPrice
bool isShortSetup = stopHasDistance and stopPrice > entryPrice

float rewardDistancePoints = hasValidEntry and hasValidTarget ? math.abs(takeProfitPrice - entryPrice) : na
bool targetHasDistance = not na(rewardDistancePoints) and rewardDistancePoints > 0
bool targetIsCorrectForDirection = (isLongSetup and takeProfitPrice > entryPrice) or (isShortSetup and takeProfitPrice < entryPrice)
bool rewardSetupIsValid = instrumentIsSupported and stopHasDistance and targetHasDistance and targetIsCorrectForDirection

float riskRewardMultiple = rewardSetupIsValid ? rewardDistancePoints / stopDistancePoints : na

// =============================================================================
// Display helpers
// =============================================================================
formatUsd(float value) =>
    na(value) ? "—" : "$" + str.tostring(value, "#,###.00")

formatPrice(float value) =>
    na(value) ? "—" : str.tostring(value, format.mintick)

formatPoints(float value) =>
    na(value) ? "—" : str.tostring(value, format.mintick)

formatTicks(float value) =>
    na(value) ? "—" : str.tostring(value, "#,###.##")

formatRiskReward(float value) =>
    na(value) ? "—" : "1 : " + str.tostring(value, "0.00")

string directionText = isLongSetup ? "LONG" : isShortSetup ? "SHORT" : "—"
string contractText = na(maxContracts) ? "—" : str.tostring(maxContracts)

string statusText = switch
    not isFutures => "NOT A FUTURES SYMBOL — DO NOT SIZE"
    not isMicroContract => "NOT IDENTIFIED AS A MICRO CONTRACT"
    not metadataIsValid => "INVALID CONTRACT METADATA — DO NOT SIZE"
    not isUsdContract => "NON-USD CONTRACT — CONVERSION REQUIRED"
    not hasValidEntry or not hasValidStop => "PRICE DATA UNAVAILABLE — DO NOT SIZE"
    not stopHasDistance => "MOVE STOP AWAY FROM CURRENT PRICE"
    maxContracts == 0 => "0 CONTRACTS — RISK TOO HIGH"
    not hasValidTarget => "TAKE-PROFIT DATA UNAVAILABLE"
    not targetHasDistance => "MOVE TAKE PROFIT AWAY FROM CURRENT PRICE"
    not targetIsCorrectForDirection => "TAKE PROFIT IS ON THE WRONG SIDE"
    => directionText + " SETUP — WITHIN MAXIMUM RISK"

color statusColor = switch
    instrumentIsSupported and stopHasDistance and maxContracts == 0 => color.rgb(183, 28, 28)
    rewardSetupIsValid and maxContracts > 0 => color.rgb(0, 121, 107)
    => color.rgb(230, 81, 0)

color panelBackground = color.rgb(20, 24, 31)
color labelBackground = color.rgb(31, 38, 48)
color valueBackground = color.rgb(25, 30, 38)
color borderColor = color.rgb(76, 86, 99)
color primaryText = color.rgb(245, 247, 250)
color secondaryText = color.rgb(190, 198, 209)

color maxContractsBackground = na(maxContracts) ? color.rgb(230, 81, 0) : maxContracts == 0 ? color.rgb(183, 28, 28) : color.rgb(0, 121, 107)

// =============================================================================
// Dashboard
// =============================================================================
var table dashboard = table.new(
     position.top_right,
     2,
     14,
     bgcolor = panelBackground,
     frame_color = borderColor,
     frame_width = 1,
     border_color = borderColor,
     border_width = 1)

if barstate.islast
    // Header
    table.cell(dashboard, 0, 0, "MICRO FUTURES RISK / REWARD", bgcolor = color.rgb(13, 17, 23), text_color = primaryText, text_size = size.small, text_halign = text.align_left)
    table.cell(dashboard, 1, 0, syminfo.ticker, bgcolor = color.rgb(13, 17, 23), text_color = color.rgb(100, 181, 246), text_size = size.normal, text_halign = text.align_right)

    // Maximum contracts
    table.cell(dashboard, 0, 1, "MAX CONTRACTS", bgcolor = maxContractsBackground, text_color = primaryText, text_size = size.normal, text_halign = text.align_left)
    table.cell(dashboard, 1, 1, contractText, bgcolor = maxContractsBackground, text_color = color.white, text_size = size.huge, text_halign = text.align_right)

    // Status
    table.cell(dashboard, 0, 2, "STATUS", bgcolor = statusColor, text_color = primaryText, text_size = size.small, text_halign = text.align_left)
    table.cell(dashboard, 1, 2, statusText, bgcolor = statusColor, text_color = color.white, text_size = size.small, text_halign = text.align_right)

    // Instrument
    table.cell(dashboard, 0, 3, "Instrument", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 3, cleanTickerId, bgcolor = valueBackground, text_color = primaryText, text_halign = text.align_right)

    // Direction
    table.cell(dashboard, 0, 4, "Direction", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 4, directionText, bgcolor = valueBackground, text_color = isLongSetup ? color.rgb(102, 187, 106) : isShortSetup ? color.rgb(239, 83, 80) : primaryText, text_halign = text.align_right)

    // Assumed entry
    table.cell(dashboard, 0, 5, "Assumed Entry", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 5, formatPrice(entryPrice), bgcolor = valueBackground, text_color = primaryText, text_halign = text.align_right)

    // Stop Loss
    table.cell(dashboard, 0, 6, "Stop Loss", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 6, formatPrice(stopPrice), bgcolor = valueBackground, text_color = color.rgb(255, 138, 128), text_halign = text.align_right)

    // Take Profit
    table.cell(dashboard, 0, 7, "Take Profit", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 7, formatPrice(takeProfitPrice), bgcolor = valueBackground, text_color = color.rgb(128, 203, 196), text_halign = text.align_right)

    // Stop distance
    table.cell(dashboard, 0, 8, "Stop Distance (points)", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 8, formatPoints(stopDistancePoints), bgcolor = valueBackground, text_color = primaryText, text_halign = text.align_right)

    table.cell(dashboard, 0, 9, "Stop Distance (ticks)", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 9, formatTicks(stopDistanceTicks), bgcolor = valueBackground, text_color = primaryText, text_halign = text.align_right)

    // Risk information
    table.cell(dashboard, 0, 10, "Risk / Micro Contract", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 10, formatUsd(riskPerContract), bgcolor = valueBackground, text_color = primaryText, text_halign = text.align_right)

    table.cell(dashboard, 0, 11, "Maximum Dollar Risk", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 11, formatUsd(maxDollarRisk), bgcolor = valueBackground, text_color = primaryText, text_halign = text.align_right)

    table.cell(dashboard, 0, 12, "Actual Total Risk", bgcolor = labelBackground, text_color = secondaryText, text_halign = text.align_left)
    table.cell(dashboard, 1, 12, formatUsd(actualDollarRisk), bgcolor = valueBackground, text_color = color.rgb(255, 183, 77), text_size = size.normal, text_halign = text.align_right)

    // Risk/reward
    table.cell(dashboard, 0, 13, "RISK : REWARD", bgcolor = rewardSetupIsValid ? color.rgb(0, 77, 64) : labelBackground, text_color = primaryText, text_size = size.normal, text_halign = text.align_left)
    table.cell(dashboard, 1, 13, formatRiskReward(riskRewardMultiple), bgcolor = rewardSetupIsValid ? color.rgb(0, 77, 64) : valueBackground, text_color = color.white, text_size = size.large, text_halign = text.align_right)
````
