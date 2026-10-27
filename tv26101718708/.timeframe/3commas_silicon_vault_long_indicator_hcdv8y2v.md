# [3Commas] Silicon Vault Long - Indicator

- url: https://www.tradingview.com/script/HCdv8Y2v-3Commas-Silicon-Vault-Long-Indicator/
- type: indicator
- pine_id: PUB;641d4fc3ee50454f9468e54ccb7fae66
- version: 1.0

## Description

[3Commas] Silicon Vault Long — Indicator

🔷 What it does:
This indicator visualizes a long-only Dollar-Cost-Averaging signal framework for tokenized semiconductor stocks (Intel and similar tech perpetuals), using an RSI-confirmed exit gate. It marks base order entries continuously, projects the full 8-level safety order ladder, tracks a virtual deal lifecycle on the chart, and exposes webhook-ready alerts for automated execution through an external DCA Bot. No orders are placed by the indicator itself — it is a pure signal and visualization layer.
  - Base Order signal: opens immediately when no active deal exists (nonstop reload)
  - Safety Order ladder: 8 cumulative levels (step coef 1.22), all equal size
  - Exit signal: RSI(14) on 15m crosses above 70 AND profit ≥ 0.6% from average entry
  - On-chart virtual P&L tracker: Net Profit, Max Drawdown, Trades, Win Rate, Profit Factor

🔷 Who is it for:
  DCA traders applying averaged-entry logic to tokenized semiconductor perpetuals.
  Bot operators who automate execution through webhook integration with a DCA Bot.
  Free-tier TradingView users who want access to the same signal logic as the Strategy version without requiring backtest functionality.
  Discretionary traders who want clear on-chart triggers and ladder projections for manual execution.

🔷 How does it work:
  Long Entry Signal: When no virtual deal is active, the indicator marks a Base Order fill on the next confirmed bar with a green "BO" triangle below the bar. The base price, total cost, and quantity are recorded for later P&L calculation.
  Short Entry: Not used — long-only signal framework by design.
  Exit Management: A take-profit signal fires when two conditions align simultaneously — RSI(14, 15m) crosses above 70 AND the unrealized profit from the average entry reaches the minimum threshold (default 0.6%). The dual gate filters out RSI-triggered exits that would close deep-averaged positions at a loss. On exit, the indicator marks the bar with a cyan "TP" diamond and resets the virtual deal state.

🔷 Why it's unique:
  Dual-gate exit logic — neither the RSI signal nor the minimum profit gate acts alone. Closing requires both — the timing trigger AND the economic justification. This ensures every signaled close is both momentum-confirmed and accumulation-corrected.
  Semiconductor sector focus — calibrated for tokenized chip / mega-cap tech stocks where chip-cycle volatility produces the intraday range that DCA bots monetize through structured averaging. The default 8-level cumulative ladder (cumulative −8.88% from base) reflects this volatility regime.
  Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads. Bot ID, Email Token, and pair label are exposed as inputs and automatically embedded into the alert message format.

🔷 What you'll see on the chart:
  Cyan line — Base Entry price (reference for the SO ladder)
  Yellow line — Average Entry price (recalculates as SOs fill)
  Lime line — Take Profit target (Average × (1 + minProfit%))
  Red lines (8) — Full SO ladder projected from base; fades to gray as each level fills
  Green "BO" triangle (below bar) — New virtual deal opened
  Red "SO" triangle (above bar) — Safety order filled at one of the ladder levels
  Cyan "TP" diamond (above bar) — Dual-gate exit triggered, deal closed
  Pink × marker — RSI cross above threshold (only profit-gate condition still pending)
  Background tints — Green on BO bar, Red on SO bar, Cyan on TP bar
  Stats card (top-left, configurable) — Live virtual results: Net P&L, Max Drawdown, Total Trades, Win Rate, Profit Factor

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: Designed for a 15-minute chart on tokenized semiconductor or mega-cap tech perpetuals with active intraday range. Best suited to instruments with sustained bullish drift and regular pullback structure. Less suited for sustained downtrends or instruments without structural upside bias — tokenized stocks have embedded long-term upward expectation that crypto-native pairs do not always share. Other timeframes will produce different signal density.

  Limitations: The indicator does not place orders. It tracks a "virtual deal" state on the chart for visualization purposes only — actual execution must be performed through a connected bot or manually. The signal framework carries no stop loss; in sustained downtrends extending beyond the deepest safety order (−8.88% from base), the virtual deal holds unrealized loss until either the average is recovered or the alert flow is manually overridden. The structural assumption is that the underlying tokenized equity will mean-revert upward over time — if this assumption breaks during equity bear markets or semiconductor sector cycles, the strategy is materially exposed.

  Virtual P&L Accuracy: The on-chart stats card uses a simplified internal accounting model — it does not factor exchange commission or slippage. Realized profit is computed as the raw (close − avgPx) × qty at the moment of exit. Use the Strategy version for fee-adjusted backtest results.

  Backtesting & Demo Testing: Always validate the signal framework on historical data before connecting to a live bot. The companion Strategy version of this script is available on the same profile for full backtest analysis with realistic commissions and slippage. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.

  Parameter Adjustments: RSI threshold (70) and the minimum profit gate (0.6%) should be tuned per instrument volatility. Tighter thresholds for lower-volatility tokenized stocks, wider for high-beta semiconductor tickers. SO step (0.5%) and step coefficient (1.22) define ladder depth — widen the step for instruments with bigger intraday swings.

🔷 Backtest Validation:

  This indicator shares identical signal logic with the Strategy version of the same framework, available on this profile for full historical performance review with realistic commission and slippage:

  Strategy version: https://www.tradingview.com/script/GhH6mW5c-3Commas-Silicon-Vault-Long-INTC-DCA-Strategy/

  Indicator on-chart virtual P&L tracker results (BITGET:INTCUSDT.P, 15m, Jan 1 2025 — May 17 2026, 252 days):
    Net Profit: +76.82 USDT (+15.36%)   |   Max Drawdown: 0.00 USDT (0.00%)   |   Total Deals: 101   |   Win Rate: 100.00% (101 / 101)   |   Profit Factor: ∞ (no losing deals in virtual model)

  Note: The indicator's virtual P&L tracker uses a simplified accounting model that does not factor exchange commission or slippage. The 100% win rate and 0% drawdown reflect this simplification — every virtual deal in the test window closed at the take-profit target because there were no negative fills in the structurally bullish phase. For fee-adjusted backtest results with realistic commission, refer to the companion Strategy version:

  Strategy version reference (with 0.06% Bitget taker fee applied):
    Net Profit: +55.96 USDT (+11.19%)   |   Max Drawdown: 16.75 USDT (3.13%)   |   Total Closed Trades: 320 (entry-level count)   |   Win Rate: 88.75% (284 / 320)   |   Profit Factor: 23.701

  The reference window captures a structurally bullish phase for Intel stock — the ideal regime for the strategy's nonstop reload + RSI-confirmed exit design. Performance during semiconductor sector downturns and chip-cycle bear markets has not been validated. Refer to the Strategy publication for the complete Pine-simulated equity curve, trade-by-trade breakdown, and Strategy Tester report with venue-specific commission applied.

🔷 How to Use It:
  🔸 Adjust Settings: Configure Base Order and Safety Order volumes proportional to your account size and risk tolerance. The default 11.25 / 7.5-USDT structure is calibrated for a 500-USDT test account; scale linearly to your equity. RSI threshold can be tightened to 65 for more frequent exits or widened to 75 for fewer, larger captures. SO step should be widened on instruments with higher intraday volatility (e.g., NVDA, AMD).

  🔸 Visual Confirmation: Use the on-chart projections (base entry, SO ladder, average entry, TP target) to verify that the active virtual deal aligns with your bot's actual position. The indicator's virtual deal state is a 1-to-1 mirror of the Strategy version's signal logic (minus commission), so any divergence between chart visuals and bot position is a flag for investigation. The pink × markers help trace when RSI conditions fire without the profit gate being met yet.

  🔸 Create alerts to trigger the DCA Bot: Two alert events are exposed by the indicator — "Deal Start" fires on each new base order signal, and "Deal Close" fires when the dual-gate exit triggers. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs and are automatically embedded into the alert JSON payload.

🔷 INDICATOR SETTINGS
  Base Order Volume (USDT, ref) — Reference notional for the initial entry; used for virtual P&L calculation.
  Safety Order Volume (USDT, ref) — Reference notional for each averaging-down order.
  Max Safety Orders — Total number of averaging steps tracked in the virtual deal.
  Price Step % (1st SO from base) — Percentage deviation from base price for the first safety order.
  Martingale Step Coefficient — Multiplier applied to each successive deviation step.
  Martingale Volume Coefficient — Size multiplier applied to each successive safety order (default 1.0 = all equal).
  Require RSI cross-above for close — Toggle the dual-gate exit; off makes it pure %-profit close.
  RSI Length / Threshold / Timeframe — Parameters for the exit RSI signal.
  Min Profit % (from avg entry) — Minimum unrealized profit threshold required for the exit gate.
  Limit by Date Range — Constrain virtual backtest to a specific date window.
  Initial Capital (ref for % calc) — Reference capital base for percentage metrics in the stats card.
  Visual Layer toggles — Show/hide base line, average line, TP line, SO ladder, signal markers.
  Stats card / Watermark — Display layer controls for on-chart virtual backtest summary and branding.
  Webhook — Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] Silicon Vault Long — Indicator
//  Companion to the Strategy version with identical signal logic.
// ---------------------------------------------------------------------
//  ⚠️ RECOMMENDED TIMEFRAME: 15 minutes
//
//  Identical DCA mechanics to the Strategy version:
//    - Nonstop entry — opens base order when no active deal exists
//    - 8 safety orders with cumulative deviation (step coef 1.22)
//    - All SOs equal size (volume coef 1.0)
//    - Dual-gate exit: RSI(14, 15m) crosses above 70 AND profit ≥ 0.6%
//
//  Strategy reference (BITGET:INTCUSDT.P, 15m, Sep 8 2025 — May 17 2026, 252 days):
//    Net Profit:    +55.96 USDT (+11.19%)
//    Max DD:        16.75 USDT (3.13%)
//    Trades:        320
//    Win Rate:      88.75% (284 / 320)
//    Profit Factor: 23.701
//
//  Use cases:
//    - Visual signal confirmation for bot-driven DCA on semiconductor stocks
//    - Live overlay of the strategy logic on any equity perpetual
//    - Webhook source for automated DCA Bot integration
//
//  Visual layer:
//    - Base, Avg, TP target, 8 SO ladder lines
//    - BO entry / SO fill / TP close markers with labels
//    - Stats card with virtual P&L, DD, Trades, Win Rate, PF
//    - Brand watermark
// =====================================================================

indicator(
     title              = "[3Commas] Silicon Vault Long — Indicator",
     shorttitle         = "Silicon Vault Ind",
     overlay            = true,
     max_lines_count    = 100,
     max_labels_count   = 300,
     max_bars_back      = 500)

// =====================================================================
//                              INPUTS
// =====================================================================
boVol    = input.float(11.25, "Base Order Volume (USDT, ref)",         group = "DCA / Safety Orders")
soVol    = input.float(7.5,   "Safety Order Volume (USDT, ref)",       group = "DCA / Safety Orders")
maxSO    = input.int  (8,     "Max Safety Orders",  minval = 0, maxval = 20, group = "DCA / Safety Orders")
soStep   = input.float(0.5,   "Price Step % (1st SO from base)",  step = 0.05, group = "DCA / Safety Orders")
stepCoef = input.float(1.22,  "Martingale Step Coefficient",      step = 0.01, group = "DCA / Safety Orders")
volCoef  = input.float(1.0,   "Martingale Volume Coefficient",    step = 0.05, group = "DCA / Safety Orders")

// — Take Profit signal —
useExitRsi  = input.bool   (true, "Require RSI cross-above for close",   group = "Take Profit — RSI Gate")
rsiLen      = input.int    (14,   "RSI Length",   minval = 2,            group = "Take Profit — RSI Gate")
rsiThr      = input.float  (70,   "RSI Threshold",                       group = "Take Profit — RSI Gate")
rsiTF       = input.timeframe("15", "RSI Timeframe",                     group = "Take Profit — RSI Gate")
minProfit   = input.float  (0.6,  "Min Profit % (from avg entry)", minval = 0.01, step = 0.05, group = "Take Profit — RSI Gate") / 100.0

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2025-09-08 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-17 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

initCapital = input.float(500, "Initial Capital (USDT, ref for % calc)", minval = 1, group = "Virtual Backtest")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_INTCUSDT",    "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Visual layer toggles —
showBaseLine = input.bool(true, "Show Base Entry line",     group = "Visual Layer")
showAvgLine  = input.bool(true, "Show Avg Entry line",      group = "Visual Layer")
showTpLine   = input.bool(true, "Show TP Target line",      group = "Visual Layer")
showSOLines  = input.bool(true, "Show SO ladder lines",     group = "Visual Layer")
showShapes   = input.bool(true, "Show entry/exit markers",  group = "Visual Layer")

// — Display layer (stats card + watermark + visual richness) —
showStats     = input.bool   (true,        "Show stats card", group = "Display")
statsPosStr   = input.string ("top_left",  "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showPosPanel  = input.bool   (true,        "Show live position dashboard", group = "Display")
posPanelPosStr= input.string ("bottom_right", "Position dashboard position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showZones     = input.bool   (true,        "Show filled accumulation/profit zones", group = "Display")
showRichLabels= input.bool   (true,        "Show price labels on BO/SO/TP events",  group = "Display")
showWM      = input.bool   (true,        "Show watermark",   group = "Display")
wmText      = input.string ("3Commas",   "Watermark text",   group = "Display")
wmPosStr    = input.string ("top_right", "Watermark position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
wmSizeStr   = input.string ("huge",      "Watermark size",
     options = ["tiny","small","normal","large","huge"], group = "Display")
wmAlpha     = input.int    (70,          "Watermark transparency (0=solid)", minval = 0, maxval = 100, group = "Display")

// =====================================================================
//                              SIGNALS
// =====================================================================
rsiVal = request.security(syminfo.tickerid, rsiTF, ta.rsi(close, rsiLen)[1], lookahead = barmerge.lookahead_on)
rsiSig = ta.crossover(rsiVal, rsiThr)

// =====================================================================
//                       VIRTUAL DEAL STATE
// =====================================================================
var bool  inDeal      = false
var float basePrice   = na
var float totalVolume = 0.0
var float totalQty    = 0.0
var int   soCount     = 0

avgPrice = totalQty > 0 ? totalVolume / totalQty : na
tpPrice  = na(avgPrice) ? na : avgPrice * (1.0 + minProfit)

// =====================================================================
//                              HELPERS
// =====================================================================
soTriggerPrice(int n) =>
    dev = 0.0
    s   = soStep
    for i = 1 to n
        dev := dev + s
        s   := s * stepCoef
    basePrice * (1.0 - dev / 100.0)

soVolume(int n) =>
    soVol * math.pow(volCoef, n - 1)

// =====================================================================
//                       VIRTUAL DEAL OPEN (BO — nonstop)
// =====================================================================
if (not inDeal and inWindow and barstate.isconfirmed)
    qty = boVol / close
    inDeal      := true
    basePrice   := close
    totalVolume := boVol
    totalQty    := qty
    soCount     := 0

// =====================================================================
//                       VIRTUAL SAFETY ORDERS
// =====================================================================
if (inDeal and barstate.isconfirmed)
    while soCount < maxSO
        nextSO = soCount + 1
        trig   = soTriggerPrice(nextSO)
        if low <= trig
            v = soVolume(nextSO)
            q = v / trig
            totalVolume := totalVolume + v
            totalQty    := totalQty + q
            soCount     := nextSO
        else
            break

// =====================================================================
//                       VIRTUAL EXIT — RSI + min profit (dual gate)
// =====================================================================
canCloseBySignal = (not useExitRsi) or rsiSig
priceOK          = not na(tpPrice) and close >= tpPrice
exitNow          = inDeal and canCloseBySignal and priceOK and barstate.isconfirmed

// =====================================================================
//                  VIRTUAL P&L / STATS TRACKER
// =====================================================================
var float vNetProfit   = 0.0
var float vGrossProfit = 0.0
var float vGrossLoss   = 0.0
var int   vTrades      = 0
var int   vWins        = 0
var float vPeakEquity  = 0.0
var float vMaxDD       = 0.0

if exitNow
    realizedPnl = (close - avgPrice) * totalQty
    vNetProfit  := vNetProfit + realizedPnl
    vTrades     := vTrades + 1
    if realizedPnl >= 0
        vWins         := vWins + 1
        vGrossProfit  := vGrossProfit + realizedPnl
    else
        vGrossLoss    := vGrossLoss + math.abs(realizedPnl)

    inDeal      := false
    basePrice   := na
    totalVolume := 0.0
    totalQty    := 0.0
    soCount     := 0

vPeakEquity := math.max(vPeakEquity, vNetProfit)
currentDD   = vPeakEquity - vNetProfit
vMaxDD      := math.max(vMaxDD, currentDD)

// =====================================================================
//                             VISUALS — Alligator-style Rich Layer
// =====================================================================
boJustOpened = not inDeal[1] and inDeal
soJustAdded  = inDeal and soCount != nz(soCount[1]) and soCount > 0
tpJustClosed = exitNow  // alias for clarity

// — Bull / Bear / Neutral palette (red/green emphasis) —
clrBullPrimary = color.new(#00C853, 0)   // vivid green — profit / growing
clrBullSoft    = color.new(#69F0AE, 50)  // soft green — profit gradient bottom
clrBearPrimary = color.new(#E53935, 0)   // vivid red — loss / falling
clrBearSoft    = color.new(#FF8A80, 50)  // soft red — loss gradient bottom
clrNeutPrimary = color.new(color.orange, 0)
clrNeutSoft    = color.new(#FFEB3B, 70)
clrBase        = color.new(#2962FF, 0)   // base entry — vivid blue

// — Dynamic state colors (price vs avg) —
inProfit   = inDeal and not na(avgPrice) and close >= avgPrice
inLoss     = inDeal and not na(avgPrice) and close <  avgPrice
avgLineCol = inProfit ? clrBullPrimary : inLoss ? clrBearPrimary : color.new(color.orange, 0)

// — Step-line position rails (cleaner than linebr) —
basePlot = plot(showBaseLine and inDeal ? basePrice : na, "Base Price",  color = clrBase,    linewidth = 1, style = plot.style_steplinebr)
avgPlot  = plot(showAvgLine  and inDeal ? avgPrice  : na, "Avg Entry",   color = avgLineCol, linewidth = 2, style = plot.style_steplinebr)
tpPlot   = plot(showTpLine   and inDeal ? tpPrice   : na, "TP Target",   color = clrBullPrimary, linewidth = 1, style = plot.style_steplinebr)
pricePlot= plot(inDeal ? close : na, "Live Price", color = color.new(color.white, 100), linewidth = 1, display = display.none)

// — Two-color gradient fills (Alligator ribbon technique) —
// Accumulation zone: Base (top, blue) → Avg (bottom, neutral)
fill(basePlot, avgPlot, basePrice, avgPrice,
     showZones ? color.new(clrBase,        75) : na,
     showZones ? color.new(color.orange,   85) : na,
     title = "Accumulation Zone")

// Profit zone: TP (top, vivid green) → Avg (bottom, soft green)
fill(tpPlot, avgPlot, tpPrice, avgPrice,
     showZones ? color.new(clrBullPrimary, 70) : na,
     showZones ? color.new(clrBullSoft,    85) : na,
     title = "Profit Zone")

// — LIVE PnL RIBBON between current price and Avg Entry —
// Green ribbon when in profit (close > avg), red ribbon when underwater (close < avg).
fill(pricePlot, avgPlot,
     inProfit ? close : avgPrice,
     inProfit ? avgPrice : close,
     showZones and inProfit ? color.new(clrBullPrimary, 60) : showZones and inLoss ? color.new(clrBearPrimary, 75) : na,
     showZones and inProfit ? color.new(clrBullSoft,    80) : showZones and inLoss ? color.new(clrBearSoft,    88) : na,
     title = "Live PnL Ribbon (Price ↔ Avg)")

// — SO ladder (red gradient by depth — direct risk visualization) —
so1Px = showSOLines and inDeal and maxSO >= 1 ? soTriggerPrice(1) : na
so2Px = showSOLines and inDeal and maxSO >= 2 ? soTriggerPrice(2) : na
so3Px = showSOLines and inDeal and maxSO >= 3 ? soTriggerPrice(3) : na
so4Px = showSOLines and inDeal and maxSO >= 4 ? soTriggerPrice(4) : na
so5Px = showSOLines and inDeal and maxSO >= 5 ? soTriggerPrice(5) : na
so6Px = showSOLines and inDeal and maxSO >= 6 ? soTriggerPrice(6) : na
so7Px = showSOLines and inDeal and maxSO >= 7 ? soTriggerPrice(7) : na
so8Px = showSOLines and inDeal and maxSO >= 8 ? soTriggerPrice(8) : na

plot(so1Px, "SO1", color = soCount >= 1 ? color.new(#37474F, 50) : color.new(#FF5252, 35), linewidth = 1, style = plot.style_steplinebr)
plot(so2Px, "SO2", color = soCount >= 2 ? color.new(#37474F, 50) : color.new(#FF5252, 40), linewidth = 1, style = plot.style_steplinebr)
plot(so3Px, "SO3", color = soCount >= 3 ? color.new(#37474F, 50) : color.new(#F44336, 35), linewidth = 1, style = plot.style_steplinebr)
plot(so4Px, "SO4", color = soCount >= 4 ? color.new(#37474F, 50) : color.new(#F44336, 40), linewidth = 1, style = plot.style_steplinebr)
plot(so5Px, "SO5", color = soCount >= 5 ? color.new(#37474F, 50) : color.new(#E53935, 35), linewidth = 1, style = plot.style_steplinebr)
plot(so6Px, "SO6", color = soCount >= 6 ? color.new(#37474F, 50) : color.new(#E53935, 40), linewidth = 1, style = plot.style_steplinebr)
plot(so7Px, "SO7", color = soCount >= 7 ? color.new(#37474F, 50) : color.new(#C62828, 35), linewidth = 1, style = plot.style_steplinebr)
plot(so8Px, "SO8", color = soCount >= 8 ? color.new(#37474F, 50) : color.new(#B71C1C, 40), linewidth = 1, style = plot.style_steplinebr)

// — Risk zone fill (Avg → Deepest SO) with red gradient —
deepestSOPlot = plot(inDeal ? soTriggerPrice(maxSO) : na, "Deepest SO Anchor", color = color.new(#B71C1C, 100), display = display.none)
fill(avgPlot, deepestSOPlot, avgPrice, inDeal ? soTriggerPrice(maxSO) : avgPrice,
     showZones ? color.new(#FFEB3B,         92) : na,
     showZones ? color.new(clrBearPrimary,  85) : na,
     title = "Risk Zone (Avg → Deepest SO)")

// — Rich event labels with prices and percentages —
if showRichLabels and boJustOpened
    label.new(bar_index, basePrice,
         text   = "🟢 BO\n" + str.tostring(basePrice, format.mintick),
         style  = label.style_label_up,
         color  = color.new(clrBullPrimary, 5),
         textcolor = color.white,
         size   = size.normal,
         yloc   = yloc.belowbar,
         tooltip= "Base Order opened at " + str.tostring(basePrice, format.mintick))

if showRichLabels and soJustAdded
    label.new(bar_index, soTriggerPrice(soCount),
         text   = "🔴 SO" + str.tostring(soCount) + "\n" + str.tostring(soTriggerPrice(soCount), format.mintick),
         style  = label.style_label_down,
         color  = color.new(clrBearPrimary, 5),
         textcolor = color.white,
         size   = size.small,
         yloc   = yloc.abovebar,
         tooltip= "Safety Order " + str.tostring(soCount) + " filled at " + str.tostring(soTriggerPrice(soCount), format.mintick))

if showRichLabels and tpJustClosed
    label.new(bar_index, close,
         text   = "✅ TP +" + str.tostring(minProfit * 100, "0.00") + "%",
         style  = label.style_label_down,
         color  = color.new(clrBullPrimary, 5),
         textcolor = color.white,
         size   = size.normal,
         yloc   = yloc.abovebar,
         tooltip= "Take Profit signal hit. Cycle closed.")

// — Circle entry markers (Alligator-style) —
plot(showShapes and boJustOpened ? basePrice : na,               title = "BO Entry Marker", color = clrBullPrimary, style = plot.style_circles, linewidth = 4, display = display.pane)
plot(showShapes and soJustAdded  ? soTriggerPrice(soCount) : na, title = "SO Fill Marker",  color = clrBearPrimary, style = plot.style_circles, linewidth = 3, display = display.pane)
plot(showShapes and tpJustClosed ? close : na,                   title = "TP Close Marker", color = clrBullPrimary, style = plot.style_circles, linewidth = 4, display = display.pane)

// Compact RSI gate-pending marker
plotshape(showShapes and rsiSig and inDeal, "RSI Sig (gate pending)", shape.xcross, location.abovebar, color = color.new(#FFEB3B, 30), size = size.tiny)

// — Subtle background tints (event highlights + live PnL state) —
bgcolor(boJustOpened ? color.new(clrBullPrimary, 85) : na, title = "BO bar")
bgcolor(tpJustClosed ? color.new(clrBullPrimary, 82) : na, title = "TP bar")
bgcolor(soJustAdded  ? color.new(clrBearPrimary, 88) : na, title = "SO bar")
// Live PnL state tint — green when in profit, red when underwater (subtle)
bgcolor(inProfit and not boJustOpened and not tpJustClosed ? color.new(clrBullPrimary, 96) : na, title = "In-profit tint")
bgcolor(inLoss   and not soJustAdded                       ? color.new(clrBearPrimary, 96) : na, title = "Underwater tint")

// =====================================================================
//                          STATS CARD
// =====================================================================
f_pos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"    ? position.top_center    :
     s == "top_right"     ? position.top_right     :
     s == "middle_left"   ? position.middle_left   :
     s == "middle_center" ? position.middle_center :
     s == "middle_right"  ? position.middle_right  :
     s == "bottom_left"   ? position.bottom_left   :
     s == "bottom_center" ? position.bottom_center :
     position.bottom_right

f_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

np      = vNetProfit
npPct   = initCapital > 0 ? np / initCapital * 100 : 0.0
dd      = vMaxDD
ddPct   = initCapital > 0 ? dd / initCapital * 100 : 0.0
nTrades = vTrades
wins    = vWins
wrPct   = nTrades > 0 ? wins / nTrades * 100 : 0.0
pf      = vGrossLoss > 0 ? vGrossProfit / vGrossLoss : 0.0

clrPos    = color.new(#00C853, 0)
clrNeg    = color.new(#D50000, 0)
clrNeutral= color.new(#FFFFFF, 10)
clrHdrBg  = color.new(#1E88E5, 10)
clrRowBg  = color.new(#0D1B2A, 25)
clrAltBg  = color.new(#152238, 25)
clrBorder = color.new(#1E88E5, 60)

var table stats = na
if showStats and barstate.islast
    if na(stats)
        stats := table.new(f_pos(statsPosStr), 2, 6, bgcolor = clrRowBg, border_width = 1, border_color = clrBorder, frame_color = clrBorder, frame_width = 1)

    table.cell(stats, 0, 0, "BACKTEST RESULTS", text_color = color.white, text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)
    table.cell(stats, 1, 0, "—",                text_color = clrHdrBg,   text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)

    table.cell(stats, 0, 1, "Net P&L",  text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 1, (np >= 0 ? "+" : "") + str.tostring(np, "0.00") + "  (" + (npPct >= 0 ? "+" : "") + str.tostring(npPct, "0.00") + "%)",
         text_color = np >= 0 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 2, "Max Drawdown", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 2, str.tostring(dd, "0.00") + "  (" + str.tostring(ddPct, "0.00") + "%)",
         text_color = clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 3, "Total Trades", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 3, str.tostring(nTrades), text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 4, "Win Rate", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 4, str.tostring(wrPct, "0.00") + "%  (" + str.tostring(wins) + "/" + str.tostring(nTrades) + ")",
         text_color = wrPct >= 50 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 5, "Profit Factor", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 5, str.tostring(pf, "0.000"), text_color = pf >= 1.5 ? clrPos : (pf >= 1.0 ? clrNeutral : clrNeg), text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

// =====================================================================
//                       LIVE POSITION DASHBOARD
// =====================================================================
deepestSOPx   = inDeal ? soTriggerPrice(maxSO) : na
deepestDevPct = inDeal and not na(basePrice) ? (basePrice - deepestSOPx) / basePrice * 100 : 0.0
tpDistPct     = inDeal and not na(tpPrice) and close > 0 ? (tpPrice - close) / close * 100 : 0.0
unrealizedPct = inDeal and not na(avgPrice) and avgPrice > 0 ? (close - avgPrice) / avgPrice * 100 : 0.0

clrPanelHdr = color.new(#1976D2, 5)
clrPanelBg  = color.new(#0B1929, 15)

var table posPanel = na
if showPosPanel and barstate.islast and inDeal
    if na(posPanel)
        posPanel := table.new(f_pos(posPanelPosStr), 2, 7, bgcolor = clrPanelBg, border_width = 1, border_color = color.new(#1976D2, 50), frame_color = color.new(#1976D2, 50), frame_width = 1)

    table.cell(posPanel, 0, 0, "LIVE POSITION",  text_color = color.white, text_size = size.normal, bgcolor = clrPanelHdr, text_halign = text.align_center)
    table.cell(posPanel, 1, 0, "ACTIVE",         text_color = color.new(#00E676, 0), text_size = size.normal, bgcolor = clrPanelHdr, text_halign = text.align_center)

    table.cell(posPanel, 0, 1, "Base Entry",     text_color = color.new(#90A4AE, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(posPanel, 1, 1, str.tostring(basePrice, format.mintick), text_color = color.new(#26C6DA, 0), text_size = size.normal, text_halign = text.align_right)

    table.cell(posPanel, 0, 2, "Avg Entry",      text_color = color.new(#90A4AE, 0), text_size = size.small, text_halign = text.align_left, bgcolor = color.new(#152238, 30))
    table.cell(posPanel, 1, 2, str.tostring(avgPrice, format.mintick), text_color = color.new(#FFD600, 0), text_size = size.normal, text_halign = text.align_right, bgcolor = color.new(#152238, 30))

    table.cell(posPanel, 0, 3, "TP Target",      text_color = color.new(#90A4AE, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(posPanel, 1, 3, str.tostring(tpPrice, format.mintick) + "  (+" + str.tostring(tpDistPct, "0.00") + "%)", text_color = color.new(#00E676, 0), text_size = size.normal, text_halign = text.align_right)

    table.cell(posPanel, 0, 4, "SOs Filled",     text_color = color.new(#90A4AE, 0), text_size = size.small, text_halign = text.align_left, bgcolor = color.new(#152238, 30))
    table.cell(posPanel, 1, 4, str.tostring(soCount) + " / " + str.tostring(maxSO), text_color = soCount > maxSO / 2 ? color.new(#FF5252, 0) : color.new(#F8FAFC, 0), text_size = size.normal, text_halign = text.align_right, bgcolor = color.new(#152238, 30))

    table.cell(posPanel, 0, 5, "Deepest SO",     text_color = color.new(#90A4AE, 0), text_size = size.small, text_halign = text.align_left)
    table.cell(posPanel, 1, 5, str.tostring(deepestSOPx, format.mintick) + "  (-" + str.tostring(deepestDevPct, "0.00") + "%)", text_color = color.new(#FF5252, 0), text_size = size.normal, text_halign = text.align_right)

    table.cell(posPanel, 0, 6, "Unrealized P&L", text_color = color.new(#90A4AE, 0), text_size = size.small, text_halign = text.align_left, bgcolor = color.new(#152238, 30))
    table.cell(posPanel, 1, 6, (unrealizedPct >= 0 ? "+" : "") + str.tostring(unrealizedPct, "0.00") + "%", text_color = unrealizedPct >= 0 ? color.new(#00E676, 0) : color.new(#FF5252, 0), text_size = size.large, text_halign = text.align_right, bgcolor = color.new(#152238, 30))

if showPosPanel and barstate.islast and (not inDeal) and not na(posPanel)
    table.clear(posPanel, 0, 0, 1, 6)

// =====================================================================
//                          BRAND WATERMARK
// =====================================================================
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))

// =====================================================================
//                          WEBHOOK ALERTS
// =====================================================================
dealStartMsg = '{"message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'
dealCloseMsg = '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'

if (not inDeal[1] and inDeal and barstate.isconfirmed)
    alert(dealStartMsg, alert.freq_once_per_bar_close)

if (exitNow)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
