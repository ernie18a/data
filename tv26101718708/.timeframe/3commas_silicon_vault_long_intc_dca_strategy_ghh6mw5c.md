# [3Commas] Silicon Vault Long - INTC DCA Strategy

- url: https://www.tradingview.com/script/GhH6mW5c-3Commas-Silicon-Vault-Long-INTC-DCA-Strategy/
- type: strategy
- pine_id: PUB;694a9d4e41c84c5daa3b2e9298fe1b67
- version: 1.0

## Description

[3Commas] Silicon Vault Long — INTC DCA Strategy

🔷 What it does:
This strategy executes a long-only Dollar-Cost-Averaging approach on tokenized Intel (INTCUSDT) perpetuals, using an RSI-based exit gate to capture momentum-confirmed take-profits on overbought rebounds. It opens base orders continuously when no active deal exists, layers a structured 8-level safety order ladder during price drawdowns, and exits only when RSI crosses above the overbought threshold AND the position has accumulated the minimum profit target from the average entry. Calibrated for the volatility profile of tokenized semiconductor stocks, where structural bullish drift in mega-cap tech combines with intraday volatility unique to perpetual contracts on equity tokens.
  - Base Order entry: nonstop — opens immediately when no active deal exists
  - Safety Order ladder: 8 levels with cumulative deviation (step coef 1.22), all SOs equal size
  - Exit: RSI(14) on 15m crosses above 70 AND profit ≥ 0.6% from average entry (dual-gate close)
  - 2× leverage (isolated), no stop loss

🔷 Who is it for:
  Traders looking to apply DCA logic to tokenized semiconductor / tech equity perpetuals.
  Bot operators who automate execution through webhook integration with a DCA Bot.
  Traders seeking exposure to mainstream tech stocks through perpetual contracts during structural bull phases.
  Discretionary traders who want a signal framework with momentum-confirmed exits rather than fixed-percentage closes.

🔷 How does it work:
  Long Entry: A base order opens whenever no active deal exists and the bar is confirmed within the configured window. There is no signal-based entry filter — the strategy reloads continuously, treating each new deal as a fresh DCA cycle. This is appropriate for instruments with sustained upward bias, as Intel's tokenized perpetual demonstrates during the reference period.
  Short Entry: Not used — strategy is long-only by design.
  Exit Management: The full position closes when two conditions align simultaneously — RSI(14, 15m) crosses above 70 (momentum-confirmed overbought signal) AND unrealized profit from average entry reaches the minimum threshold (default 0.6%). The dual gate prevents premature exits during shallow rebounds and prevents structural exits when profit is below threshold. The strategy carries no stop loss; invalidation is replaced by the depth of the safety order ladder (cumulative −8.88% from base across 8 levels) plus the underlying bullish drift assumption for tokenized equities.

🔷 Why it's unique:
  Dual-gate exit logic — most DCA strategies use either a fixed-percentage TP or a signal-only exit. This combines them: the RSI signal acts as a momentum-confirmed exit trigger, but only fires when the position is also profitable above the minimum threshold. This filters out RSI-triggered exits that would close deep-averaged positions at a loss, ensuring every signaled close is both timing-confirmed and economically rational.
  Semiconductor sector focus — calibrated for tokenized semiconductor stocks (Intel, AMD, NVDA proxies) where chip-cycle volatility creates the kind of intraday range that DCA bots monetize through structured averaging. Intel's specific volatility profile of 2025–2026 produced an ideal regime for this framework.
  Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads. Bot ID, Email Token, and pair label are exposed as inputs and automatically embedded into the alert message format.

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: Designed for a 15-minute chart on tokenized equity perpetuals with active intraday range. Best suited to mega-cap tech instruments with sustained bullish drift and regular pullback structure (Intel, AMD, MSFT, GOOGL, NVDA proxies). Less suited for sustained downtrends or instruments without structural upside bias — tokenized stocks have an embedded long-term upward expectation that crypto-native pairs do not always share.

  Limitations: The strategy carries no stop loss. In sustained downtrends extending beyond the deepest safety order (−8.88% from base), the position holds unrealized loss until either the average is recovered through subsequent bounces or the deal is manually closed. The structural assumption is that the underlying tokenized equity will mean-revert upward over time due to its embedded bullish drift. If this assumption breaks (e.g., during a sustained semiconductor sector bear cycle), the strategy is materially exposed.

  Backtesting & Demo Testing: The reference results were generated on Bitget USDT-M Perpetual Futures for INTCUSDT during a strong bullish phase for Intel stock (Jan 2025 — Mar 2026, 437 days). Performance during different equity market regimes (chip cycle downturns, broad tech corrections, rangebound periods) may differ significantly. Always validate on extended history and re-test across multiple instruments before deploying real capital. Demo-trade for at least one month before live deployment. Past performance is not indicative of future results.

  Parameter Adjustments: Commission defaults to 0.06% (Bitget USDT-M taker). Adjust for your venue. Leverage is set to 2× isolated — increase or decrease per your risk tolerance. RSI threshold (70) and the minimum profit gate (0.6%) should be tuned per instrument volatility — tighter thresholds for lower-volatility tokenized stocks, wider for high-beta semiconductor tickers. SO step (0.5%) and step coefficient (1.22) define ladder depth; widen the step for instruments with bigger intraday swings.

🔷 STRATEGY PROPERTIES
  Symbol: BITGET:INTCUSDT.P (Intel Corp tokenized perpetual on Bitget). Strategy is generic — works on any tokenized equity perpetual.
  Timeframe: 15m chart.
  Test Period: Jan 2025 — May 17, 2026.
  Initial Capital: 500 USDT.
  Order Size per Trade: Base Order 11.25 USDT, Safety Orders 7.5 USDT each (×8 = 60 USDT). Maximum cumulative position notional ≈ 71.25 USDT per deal. With 2× isolated leverage, margin requirement ≈ 35.6 USDT.
  Commission: 0.06% taker (Bitget USDT-M Perpetual reference). Adjust per venue.
  Slippage: 2 ticks — typical taker execution on liquid perpetuals.
  Margin for Long and Short Positions: 50% (2× isolated leverage).
  Indicator Settings: Default Configuration.
    Base Order Volume: 11.25 USDT
    Safety Order Volume: 7.5 USDT
    Max Safety Orders: 8
    Price Step (1st SO): 0.5%
    Step Coefficient: 1.22
    Volume Coefficient: 1.0
    RSI Length: 14
    RSI Threshold: 70
    RSI Timeframe: 15m
    Min Profit: 0.6% from average entry
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +55.96 USDT (+11.19%)
  Max Drawdown: 16.75 USDT (3.13%)
  Total Closed Trades: 320
  Percent Profitable: 88.75% (284 / 320)
  Profit Factor: 23.701

  Reference TradingView Pine backtest on BITGET:INTCUSDT.P (15m chart) for the available history window Jan 1 2025 — May 17 2026 (252 days). The exceptional win rate (88.75%) and Profit Factor (23.701) reflect the structurally bullish phase for Intel stock during the test window combined with the strategy's deep safety order ladder that absorbs intraday pullbacks. These metrics are regime-dependent and not expected to persist through semiconductor sector downturns or sustained bear cycles. Re-test on your own venue with venue-specific commission before live deployment.

🔷 How to Use It:
  🔸 Adjust Settings: Set Base Order and Safety Order volumes proportional to your account size and risk tolerance. The default 11.25 / 7.5-USDT structure is calibrated for a 500-USDT test account with 2× leverage; scale linearly to your equity. RSI threshold can be tightened to 65 for more frequent exits or widened to 75 for fewer, larger captures. The SO step should be widened on instruments with higher intraday volatility.

  🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy is configured for a conservative per-deal risk envelope (max position 71.25 USDT, full ladder coverage at −8.88% from base), but extended history may shift this profile. Re-test on your own venue using venue-specific commission and slippage. The strategy's performance on the tested window is regime-dependent — performance during semiconductor sector downturns has not been validated. Demo-trade for at least one month before any live deployment.

  🔸 Create alerts to trigger the DCA Bot: Two alert messages are exposed by the strategy — "Deal Start" fires on each new base order, and "Deal Close" fires when the dual-gate exit triggers. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. Once configured, the strategy publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
  Base Order Volume (USDT) — Notional value of the initial entry per cycle.
  Safety Order Volume (USDT) — Notional value of each averaging-down order; all SOs equal size by default.
  Max Safety Orders — Total number of averaging steps available per deal.
  Price Step % (1st SO from base) — Percentage deviation from base price for the first safety order.
  Martingale Step Coefficient — Multiplier applied to each successive deviation step.
  Martingale Volume Coefficient — Size multiplier applied to each successive safety order (default 1.0 = all equal).
  Require RSI cross-above for close — Toggle the dual-gate exit; off makes it pure %-profit close.
  RSI Length / Threshold / Timeframe — Parameters for the exit RSI signal.
  Min Profit % (from avg entry) — Minimum unrealized profit threshold required for the exit gate.
  Limit by Date Range — Constrain backtest to a specific date window.
  Stats card / Watermark — Display layer controls for on-chart backtest summary and branding.
  Webhook — Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] INTCUSDT Long DCA — RSI Exit
// ---------------------------------------------------------------------
//  Source bot config (3Commas DCA Bot):
//    Pair         : INTCUSDT/USDT (Bitget USDT-M Perpetual Futures)
//    Direction    : Long
//    Type         : Bot::MultiBot, nonstop
//    Leverage     : 2x isolated
//    Base order   : 11.25 USDT, Limit entry
//    Safety order : 7.5 USDT each, max 8, volume coef 1.0 (all equal)
//                   Step 0.5% from base, step coef 1.22 (cumulative)
//                   3 active SOs at exchange at a time
//    Exit         : RSI(14) on 15m crosses above 70
//                   AND profit >= 0.6% from average entry (dual gate)
//    Stop loss    : disabled
//    Reinvest     : 0%
//
//  3Commas built-in backtest (Jan 1 2025 — May 14 2026, 498 days):
//    PNL: see updated extended-period report on TradingView
//
//  Recommended TF for replication: 15-minute chart (matches RSI signal TF)
//
//  NOTE: Logic is identical to [3Commas] Equity Pulse Long — DCA on
//  Tokenized Stocks. Only the ticker and order sizes differ. Consider
//  publishing as a preset/example WITHIN that strategy rather than as
//  a separate publication, to avoid duplicate-script moderation flags.
// =====================================================================

strategy(
     title                   = "[3Commas] INTCUSDT Long DCA — RSI Exit",
     shorttitle              = "INTC DCA Long",
     overlay                 = true,
     pyramiding              = 9,         // 1 BO + 8 SO
     initial_capital         = 500,
     default_qty_type        = strategy.cash,
     default_qty_value       = 11.25,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.06,      // Bitget USDT-M taker
     slippage                = 2,
     margin_long             = 50.0,      // 100 / 2 = 50% for 2x isolated
     calc_on_every_tick      = false)

// =====================================================================
//                              INPUTS
// =====================================================================
boVol    = input.float(11.25, "Base Order Volume (USDT)",            group = "DCA / Safety Orders")
soVol    = input.float(7.5,   "Safety Order Volume (USDT)",          group = "DCA / Safety Orders")
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
startTs  = input.time(timestamp("2025-01-01 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-14 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_INTCUSDT",    "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Display —
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
//                               STATE
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
//                       BASE ORDER (nonstop entry)
// =====================================================================
if (not inDeal and inWindow and barstate.isconfirmed)
    qty = boVol / close
    strategy.entry("BO", strategy.long, qty = qty)
    inDeal      := true
    basePrice   := close
    totalVolume := boVol
    totalQty    := qty
    soCount     := 0

// =====================================================================
//                          SAFETY ORDERS
// =====================================================================
if (inDeal and barstate.isconfirmed)
    while soCount < maxSO
        nextSO = soCount + 1
        trig   = soTriggerPrice(nextSO)
        if low <= trig
            v = soVolume(nextSO)
            q = v / trig
            strategy.entry("SO" + str.tostring(nextSO), strategy.long, qty = q, limit = trig)
            totalVolume := totalVolume + v
            totalQty    := totalQty + q
            soCount     := nextSO
        else
            break

// =====================================================================
//                       EXIT — RSI + min profit (dual gate)
// =====================================================================
canCloseBySignal = (not useExitRsi) or rsiSig
priceOK          = not na(tpPrice) and close >= tpPrice

if (inDeal and canCloseBySignal and priceOK and barstate.isconfirmed)
    strategy.close_all(comment = useExitRsi ? "TP+RSI" : "TP")
    inDeal      := false
    basePrice   := na
    totalVolume := 0.0
    totalQty    := 0.0
    soCount     := 0

// =====================================================================
//                             VISUALS — Alligator-style Rich Layer
// =====================================================================
// Pre-compute event flags
boJustOpened = not inDeal[1] and inDeal
soJustAdded  = inDeal and soCount != nz(soCount[1]) and soCount > 0
tpJustClosed = inDeal[1] and not inDeal

// — Bull / Bear / Neutral palette (Alligator-inspired, red/green emphasis) —
clrBullPrimary = color.new(#00C853, 0)   // vivid green — profit / growing
clrBullSoft    = color.new(#69F0AE, 50)  // soft green — profit gradient bottom
clrBearPrimary = color.new(#E53935, 0)   // vivid red — loss / falling
clrBearSoft    = color.new(#FF8A80, 50)  // soft red — loss gradient bottom
clrNeutPrimary = color.new(color.orange, 0)
clrNeutSoft    = color.new(#FFEB3B, 70)
clrBase        = color.new(#2962FF, 0)   // base entry — vivid blue

// — Dynamic state colors (price vs avg) —
inProfit  = inDeal and not na(avgPrice) and close >= avgPrice
inLoss    = inDeal and not na(avgPrice) and close <  avgPrice
avgLineCol = inProfit ? clrBullPrimary : inLoss ? clrBearPrimary : color.new(color.orange, 0)

// — Step-line position rails (cleaner than linebr) —
basePlot = plot(inDeal ? basePrice : na, "Base Price",  color = clrBase,    linewidth = 1, style = plot.style_steplinebr)
avgPlot  = plot(inDeal ? avgPrice  : na, "Avg Entry",   color = avgLineCol, linewidth = 2, style = plot.style_steplinebr)
tpPlot   = plot(inDeal ? tpPrice   : na, "TP Target",   color = clrBullPrimary, linewidth = 1, style = plot.style_steplinebr)
pricePlot= plot(inDeal ? close     : na, "Live Price",  color = color.new(color.white, 100), linewidth = 1, display = display.none)

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
// This is the dynamic alligator-ribbon effect on the actual position.
fill(pricePlot, avgPlot,
     inProfit ? close : avgPrice,
     inProfit ? avgPrice : close,
     showZones and inProfit ? color.new(clrBullPrimary, 60) : showZones and inLoss ? color.new(clrBearPrimary, 75) : na,
     showZones and inProfit ? color.new(clrBullSoft,    80) : showZones and inLoss ? color.new(clrBearSoft,    88) : na,
     title = "Live PnL Ribbon (Price ↔ Avg)")

// — SO ladder (red gradient by depth — direct risk visualization) —
so1Px = inDeal and maxSO >= 1 ? soTriggerPrice(1) : na
so2Px = inDeal and maxSO >= 2 ? soTriggerPrice(2) : na
so3Px = inDeal and maxSO >= 3 ? soTriggerPrice(3) : na
so4Px = inDeal and maxSO >= 4 ? soTriggerPrice(4) : na
so5Px = inDeal and maxSO >= 5 ? soTriggerPrice(5) : na
so6Px = inDeal and maxSO >= 6 ? soTriggerPrice(6) : na
so7Px = inDeal and maxSO >= 7 ? soTriggerPrice(7) : na
so8Px = inDeal and maxSO >= 8 ? soTriggerPrice(8) : na

so1Plot = plot(so1Px, "SO1", color = soCount >= 1 ? color.new(#37474F, 50) : color.new(#FF5252, 35), linewidth = 1, style = plot.style_steplinebr)
so2Plot = plot(so2Px, "SO2", color = soCount >= 2 ? color.new(#37474F, 50) : color.new(#FF5252, 40), linewidth = 1, style = plot.style_steplinebr)
so3Plot = plot(so3Px, "SO3", color = soCount >= 3 ? color.new(#37474F, 50) : color.new(#F44336, 35), linewidth = 1, style = plot.style_steplinebr)
so4Plot = plot(so4Px, "SO4", color = soCount >= 4 ? color.new(#37474F, 50) : color.new(#F44336, 40), linewidth = 1, style = plot.style_steplinebr)
so5Plot = plot(so5Px, "SO5", color = soCount >= 5 ? color.new(#37474F, 50) : color.new(#E53935, 35), linewidth = 1, style = plot.style_steplinebr)
so6Plot = plot(so6Px, "SO6", color = soCount >= 6 ? color.new(#37474F, 50) : color.new(#E53935, 40), linewidth = 1, style = plot.style_steplinebr)
so7Plot = plot(so7Px, "SO7", color = soCount >= 7 ? color.new(#37474F, 50) : color.new(#C62828, 35), linewidth = 1, style = plot.style_steplinebr)
so8Plot = plot(so8Px, "SO8", color = soCount >= 8 ? color.new(#37474F, 50) : color.new(#B71C1C, 40), linewidth = 1, style = plot.style_steplinebr)

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
         tooltip= "Take Profit hit. Cycle closed.")

// — Circle entry markers (Alligator-style) —
plot(boJustOpened ? basePrice : na,                title = "BO Entry Marker", color = clrBullPrimary, style = plot.style_circles, linewidth = 4, display = display.pane)
plot(soJustAdded  ? soTriggerPrice(soCount) : na,  title = "SO Fill Marker",  color = clrBearPrimary, style = plot.style_circles, linewidth = 3, display = display.pane)
plot(tpJustClosed ? close : na,                    title = "TP Close Marker", color = clrBullPrimary, style = plot.style_circles, linewidth = 4, display = display.pane)

// Compact RSI gate-pending marker
plotshape(rsiSig and inDeal, "RSI Sig (gate pending)", shape.xcross, location.abovebar, color = color.new(#FFEB3B, 30), size = size.tiny)

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

np      = strategy.netprofit
npPct   = strategy.initial_capital > 0 ? np / strategy.initial_capital * 100 : 0.0
dd      = strategy.max_drawdown
ddPct   = strategy.initial_capital > 0 ? dd / strategy.initial_capital * 100 : 0.0
nTrades = strategy.closedtrades
wins    = strategy.wintrades
wrPct   = nTrades > 0 ? wins / nTrades * 100 : 0.0
gp      = strategy.grossprofit
gl      = strategy.grossloss
pf      = gl > 0 ? gp / gl : 0.0

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
// Shows the active deal's current state — only visible while in_deal.
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

// Hide panel when no active deal
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

if (inDeal[1] and not inDeal and barstate.isconfirmed)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
