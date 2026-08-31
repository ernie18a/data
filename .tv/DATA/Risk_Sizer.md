<!-- tradingview-pine-id: PUB;da44beb5e6f844e5a2214cdffe92f660 -->
<!-- tradingviewscripts-format: 1 -->
# Risk Sizer

Source: https://www.tradingview.com/script/wlTmzydY-Risk-Sizer/

## Description

### Risk Sizer

**Risk Sizer** is a fast position-sizing and execution-risk tool designed for discretionary intraday and breakout trading.

Instead of choosing a position size first, place the draggable **SL** at the level where your trade idea is invalidated. Risk Sizer then calculates the position size based on your account risk while accounting for trading costs and execution conditions.

The indicator displays:

* **REC QTY** — liquidity-adjusted recommended position size
* **RISK QTY** — maximum size based on your configured risk
* **POSITION** — recommended position notional
* **SL** — stop price and percentage distance
* **ATR** — ATR for the current chart timeframe
* **SL / ATR** — stop distance relative to current volatility
* **BUFFER** — configurable slippage/execution allowance
* **RT FEES** — estimated round-trip trading fees
* **FEE / SL** — how significant fees are relative to the stop distance
* **RISK USED** — estimated total risk versus your configured risk budget
* **CAP USED** — percentage of the configured maximum position limit
* **1M LIQ** — average 1-minute notional volume used as a liquidity proxy
* **LIQ MULT** — suggested size reduction when the position is large relative to observed volume
* **EXECUTION** — simple green / amber / red execution warnings

### Position sizing

Position size accounts for:

**Structural SL + execution buffer + estimated round-trip fees**

This helps prevent extremely tight stops from producing unrealistically large position sizes.

For example, if your stop is only `0.01%` but your round-trip trading costs are `0.08%`, fees are already significantly larger than the structural stop. Risk Sizer highlights this through the **FEE / SL** metric and includes those costs when determining size.

### Liquidity-adjusted sizing

Risk Sizer also calculates an optional liquidity recommendation using average **1-minute TradingView notional volume**.

If your risk-based position would represent more than your configured target percentage of average 1-minute volume, the indicator reduces the recommended size and shows the resulting **LIQ MULT**.

Example:

```text
RISK QTY       100 ETH
LIQ MULT        0.40x
REC QTY         40 ETH
```

The risk-based quantity remains visible so you can distinguish between:

**Risk capacity** — how much you could trade based on your stop and risk budget.

**Execution capacity** — a more conservative recommendation based on observed market activity.

### Execution status

The indicator classifies conditions into simple execution warnings.

**Green — OK**
No obvious sizing or execution issue detected.

**Amber — Review**

* High fees relative to SL
* Very tight or wide SL relative to ATR
* Liquidity-based size reduction
* Position notional cap reached

**Red — Attention**

* Round-trip fees exceed the structural SL percentage
* Invalid or impractical calculated position size

### Typical workflow

**1. Identify the trade setup**
**2. Drag SL to structural invalidation**
**3. Check EXECUTION status**
**4. Read REC QTY**
**5. Execute**

The indicator is intentionally designed for quick visual use during fast-moving markets.

### Important limitations

The liquidity model is a **proxy**, not an order-book or slippage prediction.

It uses TradingView's available 1-minute volume data and does not know the actual depth, spread, liquidity-provider inventory, or execution quality available at your broker or exchange.

Actual fills may differ due to:

* Spread
* Order-book depth
* Market impact
* Latency
* Volatility
* Slippage
* Broker/exchange execution
* Fees and instrument specifications

Fees, quantity increments, point value, maximum notional and liquidity thresholds are configurable and should be adjusted to match the instrument and venue you trade.

**Risk Sizer is an execution and risk-management aid, not a trading signal or financial advice.**

---

## Source Code

````pine
//@version=6
indicator(
     "Risk Sizer",
     "Risk Sizer",
     overlay = true,
     max_lines_count = 10,
     max_labels_count = 10)


// ============================================================================
// RISK SIZER
//
// Fast discretionary position sizing for breakout / intraday trading.
//
// Workflow:
//   1. Drag SL to structural invalidation.
//   2. Read REC QTY.
//   3. Check EXECUTION.
//   4. Execute.
//
// Risk sizing includes:
//   - Structural stop
//   - Execution/slippage buffer
//   - Round-trip fees
//   - Maximum position notional
//
// Liquidity:
//   - Uses average TradingView 1-minute notional volume as a proxy.
//   - Applies a SOFT size haircut when the risk-sized position is large
//     relative to recent market activity.
//   - It is NOT an order-book or slippage prediction.
// ============================================================================


// ============================================================================
// RISK
// ============================================================================

groupRisk = "RISK"

accountSize = input.float(
     100000,
     "Account Size ($)",
     minval = 1,
     group = groupRisk)

riskPct = input.float(
     0.5,
     "Risk Per Trade (%)",
     minval = 0.01,
     step = 0.05,
     group = groupRisk)

executionBufferPct = input.float(
     0.01,
     "Execution / Slippage Buffer (%)",
     minval = 0,
     step = 0.005,
     tooltip =
         "Extra risk allowance for imperfect fills. " +
         "Example: 0.01 means 0.01% of position notional.",
     group = groupRisk)


// ============================================================================
// TRADE
// ============================================================================

groupTrade = "TRADE"

stopPrice = input.price(
     0.0,
     "STOP — DRAG THIS",
     confirm = true,
     group = groupTrade)

stopLineColor = input.color(
     color.red,
     "Stop Line Color",
     group = groupTrade)


// ============================================================================
// VOLATILITY
// ============================================================================

groupATR = "VOLATILITY"

atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = groupATR)

tightSLATRThreshold = input.float(
     0.25,
     "Tight SL Warning",
     minval = 0,
     step = 0.05,
     tooltip =
         "Warn when SL is smaller than this multiple of ATR.",
     group = groupATR)

wideSLATRThreshold = input.float(
     1.50,
     "Wide SL Warning",
     minval = 0,
     step = 0.10,
     tooltip =
         "Color SL / ATR amber when the stop exceeds this ATR multiple.",
     group = groupATR)


// ============================================================================
// FEES
// ============================================================================

groupFees = "FEES"

feePctPerSide = input.float(
     0.04,
     "Fee Per Side (%)",
     minval = 0,
     step = 0.001,
     tooltip =
         "Example: 0.04 = 0.04% per side.",
     group = groupFees)

feeMultiplier = input.float(
     2.0,
     "Fee Multiplier",
     minval = 0,
     step = 0.5,
     tooltip =
         "2 = approximate entry + exit round trip.",
     group = groupFees)

highFeeRatio = input.float(
     0.50,
     "High Fee / SL Warning",
     minval = 0,
     step = 0.05,
     tooltip =
         "0.50 warns when round-trip fees are at least 50% " +
         "of the structural stop percentage.",
     group = groupFees)


// ============================================================================
// POSITION LIMIT
// ============================================================================

groupLimits = "LIMITS"

maxNotional = input.float(
     1000000,
     "Max Position Notional ($)",
     minval = 1,
     step = 10000,
     tooltip =
         "Set this to the current maximum allowed notional " +
         "for the instrument you trade.",
     group = groupLimits)


// ============================================================================
// LIQUIDITY
// ============================================================================

groupLiquidity = "LIQUIDITY"

useLiquidityRecommendation = input.bool(
     true,
     "Use Liquidity Recommendation",
     tooltip =
         "Applies a conservative SOFT haircut to position size " +
         "when the risk-sized trade is large relative to average " +
         "1-minute TradingView notional volume.",
     group = groupLiquidity)

volumeLookback = input.int(
     20,
     "1m Volume Average Length",
     minval = 1,
     group = groupLiquidity)


// ============================================================================
// CONTRACT
// ============================================================================

groupContract = "CONTRACT"

useAutoPointValue = input.bool(
     true,
     "Use TradingView Point Value",
     group = groupContract)

manualPointValue = input.float(
     1.0,
     "Manual Point Value",
     minval = 0.00000001,
     active = not useAutoPointValue,
     group = groupContract)

qtyStepOverride = input.float(
     0.0,
     "Quantity Step Override (0 = Auto)",
     minval = 0,
     tooltip =
         "Examples: 0.001 ETH or 1 futures contract.",
     group = groupContract)


// ============================================================================
// MARKET VALUES
// ============================================================================

entryPrice = close

autoPointValue =
     na(syminfo.pointvalue)
     ? 1.0
     : syminfo.pointvalue

pointValue =
     useAutoPointValue
     ? autoPointValue
     : manualPointValue

autoQtyStep =
     na(syminfo.mincontract)
     ? 0.001
     : syminfo.mincontract

qtyStep =
     qtyStepOverride > 0
     ? qtyStepOverride
     : autoQtyStep


// ============================================================================
// STOP + DIRECTION
// ============================================================================

validStop =
     stopPrice > 0 and
     entryPrice > 0 and
     stopPrice != entryPrice

isLong =
     validStop and
     stopPrice < entryPrice

isShort =
     validStop and
     stopPrice > entryPrice

direction =
     isLong
     ? "LONG"
     : isShort
     ? "SHORT"
     : "SET SL"


// ============================================================================
// STOP + ATR
// ============================================================================

atr = ta.atr(atrLength)

stopDistance =
     validStop
     ? math.abs(entryPrice - stopPrice)
     : na

stopPct =
     validStop
     ? stopDistance / entryPrice * 100
     : na

stopATR =
     validStop and atr > 0
     ? stopDistance / atr
     : na


// ============================================================================
// COSTS + RISK BUDGET
// ============================================================================

roundTripFeePct =
     feePctPerSide *
     feeMultiplier

targetRisk =
     accountSize *
     riskPct /
     100

// Position sizing assumes:
//
// structural SL
// + execution buffer
// + round-trip fees
//
totalRiskPct =
     validStop
     ? stopPct +
       executionBufferPct +
       roundTripFeePct
     : na


// ============================================================================
// PURE RISK SIZE
// ============================================================================

riskBasedNotional =
     validStop and totalRiskPct > 0
     ? targetRisk /
       (totalRiskPct / 100)
     : na

riskBasedQty =
     validStop and entryPrice > 0
     ? riskBasedNotional /
       (entryPrice * pointValue)
     : na


// ============================================================================
// MAX POSITION CAP
// ============================================================================

maxQtyByNotional =
     entryPrice > 0
     ? maxNotional /
       (entryPrice * pointValue)
     : na

capHit =
     validStop and
     riskBasedNotional > maxNotional

riskQtyRaw =
     validStop
     ? math.min(
         riskBasedQty,
         maxQtyByNotional)
     : na

riskQty =
     validStop and qtyStep > 0
     ? math.floor(
         riskQtyRaw /
         qtyStep) *
       qtyStep
     : na

riskPositionNotional =
     validStop
     ? riskQty *
       entryPrice *
       pointValue
     : na


// ============================================================================
// FIXED 1-MINUTE LIQUIDITY PROXY
// ============================================================================

avg1mBaseNotional =
     request.security(
         syminfo.tickerid,
         "1",
         ta.sma(
             volume * close,
             volumeLookback),
         barmerge.gaps_off,
         barmerge.lookahead_off)

avg1mNotionalVolume =
     avg1mBaseNotional *
     pointValue

liquidityAvailable =
     not na(avg1mNotionalVolume) and
     avg1mNotionalVolume > 0

riskParticipationPct =
     validStop and liquidityAvailable
     ? riskPositionNotional /
       avg1mNotionalVolume *
       100
     : na


// ============================================================================
// SOFT LIQUIDITY HAIRCUT
//
// Risk-sized position / average 1-minute notional:
//
// < 5%      -> 1.00x
// 5–10%     -> 0.90x
// 10–20%    -> 0.75x
// 20–40%    -> 0.50x
// 40–75%    -> 0.35x
// > 75%     -> 0.25x
//
// This is deliberately a conservative heuristic,
// NOT an estimate of actual market impact.
// ============================================================================

float liquidityMultiplier = 1.0

if validStop and
   useLiquidityRecommendation and
   liquidityAvailable

    liquidityMultiplier :=
         riskParticipationPct < 5
         ? 1.00
         : riskParticipationPct < 10
         ? 0.90
         : riskParticipationPct < 20
         ? 0.75
         : riskParticipationPct < 40
         ? 0.50
         : riskParticipationPct < 75
         ? 0.35
         : 0.25

liquidityLimited =
     validStop and
     liquidityMultiplier < 0.999


// ============================================================================
// RECOMMENDED SIZE
// ============================================================================

recommendedQtyRaw =
     validStop
     ? riskQty *
       liquidityMultiplier
     : na

recommendedQty =
     validStop and qtyStep > 0
     ? math.floor(
         recommendedQtyRaw /
         qtyStep) *
       qtyStep
     : na

recommendedNotional =
     validStop
     ? recommendedQty *
       entryPrice *
       pointValue
     : na


// ============================================================================
// RECOMMENDED RISK BREAKDOWN
// ============================================================================

structuralRisk =
     validStop
     ? recommendedQty *
       stopDistance *
       pointValue
     : na

bufferRisk =
     validStop
     ? recommendedNotional *
       executionBufferPct /
       100
     : na

estimatedFees =
     validStop
     ? recommendedNotional *
       roundTripFeePct /
       100
     : na

estimatedTotalRisk =
     validStop
     ? structuralRisk +
       bufferRisk +
       estimatedFees
     : na

riskUsedPct =
     validStop and targetRisk > 0
     ? estimatedTotalRisk /
       targetRisk *
       100
     : na


// ============================================================================
// EXECUTION METRICS
// ============================================================================

feeStopRatio =
     validStop and stopPct > 0
     ? roundTripFeePct /
       stopPct
     : na

feesGreaterThanSL =
     validStop and
     feeStopRatio >= 1.0

highFees =
     validStop and
     feeStopRatio >= highFeeRatio and
     feeStopRatio < 1.0

veryTightSL =
     validStop and
     stopATR < tightSLATRThreshold

wideSL =
     validStop and
     stopATR > wideSLATRThreshold

invalidSize =
     validStop and
     (
         na(recommendedQty) or
         recommendedQty <= 0
     )

liquidityUnavailable =
     validStop and
     useLiquidityRecommendation and
     not liquidityAvailable


// ============================================================================
// EXECUTION STATUS
//
// Keep this intentionally short.
//
// Wide SL is communicated through SL / ATR color.
// It does not clutter the main status line.
// ============================================================================

int executionSeverity = 0
string executionStatus = "DRAG SL"

if validStop

    // RED
    if invalidSize

        executionSeverity := 3
        executionStatus := "INVALID SIZE"

    else if feesGreaterThanSL

        executionSeverity := 3
        executionStatus := "FEES > SL"

    // AMBER
    else if liquidityLimited and highFees

        executionSeverity := 2
        executionStatus := "LIQUIDITY LIMITED · HIGH FEES"

    else if liquidityLimited

        executionSeverity := 2
        executionStatus := "LIQUIDITY LIMITED"

    else if highFees

        executionSeverity := 2
        executionStatus := "HIGH FEES"

    else if veryTightSL

        executionSeverity := 2
        executionStatus := "TIGHT SL"

    else if capHit

        executionSeverity := 2
        executionStatus := "POSITION CAPPED"

    else if liquidityUnavailable

        executionSeverity := 2
        executionStatus := "LIQUIDITY N/A"

    // GREEN
    else

        executionSeverity := 1
        executionStatus := "OK"


// ============================================================================
// COLORS
//
// White  = action / normal information
// Gray   = secondary/reference
// Green  = healthy
// Amber  = review / reduced / unusual
// Red    = execution problem
// ============================================================================

directionColor =
     isLong
     ? color.rgb(0, 150, 100)
     : isShort
     ? color.rgb(190, 60, 60)
     : color.gray

statusColor =
     executionSeverity == 1
     ? color.rgb(0, 140, 90)
     : executionSeverity == 2
     ? color.rgb(190, 130, 20)
     : executionSeverity == 3
     ? color.rgb(190, 60, 60)
     : color.gray

bgPrimary =
     color.rgb(20, 20, 20)

bgSecondary =
     color.rgb(32, 32, 32)

secondaryText =
     color.rgb(155, 155, 155)


// ============================================================================
// FINAL COMPACT EXECUTION HUD
//
// Priority:
//
//   ACTION
//   STRUCTURE
//   RISK
//   EXECUTION QUALITY
// ============================================================================

var table dashboard =
     table.new(
         position.top_right,
         2,
         9,
         border_width = 1)

if barstate.islast

    // ========================================================================
    // HEADER
    // ========================================================================

    table.cell(
         dashboard,
         0,
         0,
         direction,
         bgcolor = directionColor,
         text_color = color.white,
         text_size = size.normal)

    table.cell(
         dashboard,
         1,
         0,
         syminfo.ticker,
         bgcolor = directionColor,
         text_color = color.white,
         text_size = size.normal)


    // ========================================================================
    // REC QTY + POSITION
    //
    // PRIMARY ACTION ROW.
    // No warning color — this is the number to execute.
    // ========================================================================

    table.cell(
         dashboard,
         0,
         1,
         "REC QTY",
         bgcolor = bgPrimary,
         text_color = color.white,
         text_size = size.normal)

    table.cell(
         dashboard,
         1,
         1,
         validStop
             ? str.tostring(
                   recommendedQty,
                   "#.####")
               +
               " · $" +
               str.tostring(
                   recommendedNotional,
                   "#,###")
             : "—",
         bgcolor = bgPrimary,
         text_color = color.white,
         text_size = size.normal)


    // ========================================================================
    // RISK QTY — SECONDARY REFERENCE ONLY
    // ========================================================================

    table.cell(
         dashboard,
         0,
         2,
         "RISK QTY",
         bgcolor = bgSecondary,
         text_color = secondaryText)

    table.cell(
         dashboard,
         1,
         2,
         validStop
             ? str.tostring(
                 riskQty,
                 "#.####")
             : "—",
         bgcolor = bgSecondary,
         text_color = secondaryText)


    // ========================================================================
    // STRUCTURAL STOP
    // ========================================================================

    table.cell(
         dashboard,
         0,
         3,
         "SL",
         bgcolor = bgPrimary,
         text_color = secondaryText)

    table.cell(
         dashboard,
         1,
         3,
         validStop
             ? str.tostring(
                   stopPrice,
                   format.mintick)
               +
               " · " +
               str.tostring(
                   stopPct,
                   "#.###")
               +
               "%"
             : "DRAG SL",
         bgcolor = bgPrimary,
         text_color = color.white)


    // ========================================================================
    // ACTUAL RISK AFTER RECOMMENDED SIZE
    // ========================================================================

    table.cell(
         dashboard,
         0,
         4,
         "RISK",
         bgcolor = bgSecondary,
         text_color = secondaryText)

    table.cell(
         dashboard,
         1,
         4,
         validStop
             ? "$" +
               str.tostring(
                   estimatedTotalRisk,
                   "#.##")
               +
               " / $" +
               str.tostring(
                   targetRisk,
                   "#.##")
               +
               " · " +
               str.tostring(
                   riskUsedPct,
                   "#")
               +
               "%"
             : "$" +
               str.tostring(
                   targetRisk,
                   "#.##"),
         bgcolor = bgSecondary,
         text_color = color.white)


    // ========================================================================
    // STOP RELATIVE TO VOLATILITY
    // ========================================================================

    table.cell(
         dashboard,
         0,
         5,
         "SL / ATR",
         bgcolor = bgPrimary,
         text_color = secondaryText)

    table.cell(
         dashboard,
         1,
         5,
         validStop
             ? str.tostring(
                   stopATR,
                   "#.##")
               +
               "x"
             : "—",
         bgcolor = bgPrimary,
         text_color =
             veryTightSL or wideSL
             ? color.orange
             : color.white)


    // ========================================================================
    // FEES
    //
    // Example:
    //
    // $33.82 · 0.39x SL
    // ========================================================================

    table.cell(
         dashboard,
         0,
         6,
         "FEES",
         bgcolor = bgSecondary,
         text_color = secondaryText)

    table.cell(
         dashboard,
         1,
         6,
         validStop
             ? "$" +
               str.tostring(
                   estimatedFees,
                   "#.##")
               +
               " · " +
               str.tostring(
                   feeStopRatio,
                   "#.##")
               +
               "x SL"
             : "—",
         bgcolor = bgSecondary,
         text_color =
             feesGreaterThanSL
             ? color.red
             : highFees
             ? color.orange
             : color.white)


    // ========================================================================
    // LIQUIDITY LOAD
    //
    // Example:
    //
    // 285% → 0.25x
    //
    // Meaning:
    // Risk-sized position is 285% of average 1m notional volume.
    // Suggested liquidity haircut = 0.25x.
    // ========================================================================

    table.cell(
         dashboard,
         0,
         7,
         "LIQ LOAD",
         bgcolor = bgPrimary,
         text_color = secondaryText)

    table.cell(
         dashboard,
         1,
         7,
         validStop and liquidityAvailable
             ? str.tostring(
                   riskParticipationPct,
                   "#.#")
               +
               "% → " +
               str.tostring(
                   liquidityMultiplier,
                   "#.##")
               +
               "x"
             : "N/A",
         bgcolor = bgPrimary,
         text_color =
             liquidityLimited
             ? color.orange
             : color.white)


    // ========================================================================
    // EXECUTION STATUS
    // ========================================================================

    table.cell(
         dashboard,
         0,
         8,
         "EXECUTION",
         bgcolor = statusColor,
         text_color = color.white)

    table.cell(
         dashboard,
         1,
         8,
         executionStatus,
         bgcolor = statusColor,
         text_color = color.white)


// ============================================================================
// SL LINE + LABEL
// ============================================================================

var line slLine = na
var label slLabel = na

if barstate.islast

    if validStop

        // ====================================================================
        // SL LINE
        // ====================================================================

        if na(slLine)

            slLine :=
                 line.new(
                     x1 = bar_index - 20,
                     y1 = stopPrice,
                     x2 = bar_index + 1,
                     y2 = stopPrice,
                     extend = extend.right,
                     color = stopLineColor,
                     width = 2)

        else

            line.set_xy1(
                 slLine,
                 bar_index - 20,
                 stopPrice)

            line.set_xy2(
                 slLine,
                 bar_index + 1,
                 stopPrice)

            line.set_color(
                 slLine,
                 stopLineColor)


        // ====================================================================
        // SL LABEL
        // ====================================================================

        slText =
             "SL " +
             str.tostring(
                 stopPct,
                 "#.##")
             +
             "%"

        if na(slLabel)

            slLabel :=
                 label.new(
                     x = bar_index + 2,
                     y = stopPrice,
                     text = slText,
                     style = label.style_label_left,
                     color = stopLineColor,
                     textcolor = color.white,
                     size = size.small)

        else

            label.set_xy(
                 slLabel,
                 bar_index + 2,
                 stopPrice)

            label.set_text(
                 slLabel,
                 slText)

            label.set_color(
                 slLabel,
                 stopLineColor)

    else

        if not na(slLine)

            line.delete(slLine)
            slLine := na

        if not na(slLabel)

            label.delete(slLabel)
            slLabel := na
````
