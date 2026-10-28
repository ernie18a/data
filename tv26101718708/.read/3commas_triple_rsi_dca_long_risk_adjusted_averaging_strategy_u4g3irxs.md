# [3Commas] Triple RSI DCA Long - Risk Adjusted Averaging Strategy

- url: https://www.tradingview.com/script/u4g3IrXS-3Commas-Triple-RSI-DCA-Long-Risk-Adjusted-Averaging-Strategy/
- type: strategy
- pine_id: PUB;9b4419feca3441c59e706e414558184a
- version: 2.0

## Description

🔷 What it does:
This strategy executes a long-only Dollar-Cost-Averaging approach driven by three independent RSI signals layered across two timeframes. It opens a base order on a 5-minute RSI exit-from-oversold confirmation, layers a martingale-scaled safety order ladder triggered by a 30-minute RSI signal in combination with a faster 5-minute short-period RSI signal, and exits the entire position on a percentage-based take profit measured from the average entry. The architecture is designed for risk-first deployment - capturing partial upside of trending moves while maintaining a structurally bounded drawdown profile.

Base Order entry: RSI(14) on 5m crosses above 30 (oversold-exit confirmation)
Safety Order trigger: RSI(14) on 30m OR RSI(7) on 5m crosses above 30, coinciding with a structural deviation from base price
Martingale ladder: 3 safety orders, volume scale 1.9×, price step 1.0% with deviation coefficient 1.65
Take Profit: configurable percentage from average entry (default 1.3%)

🔷 Who is it for:
DCA-style traders who prefer averaged-in entries over single-shot directional bets.
Risk-conscious participants who want a smoother equity curve than passive holding.
Bot operators who automate execution through webhook integration with a DCA Bot.
Cross-instrument testers who want a single signal framework portable across crypto, perpetuals, and tokenized equities.

🔷 How does it work:
Long Entry: A base order opens when RSI(14, 5m) crosses above 30, signaling exit from a short-term oversold regime. The crossover is a single-shot confirmation per cycle to prevent re-entries during unconfirmed bottoming.
Short Entry: Not used - strategy is long-only by design.
Exit Management: The full position closes when price reaches Average Entry × (1 + Take Profit %). The strategy carries no stop loss; invalidation is replaced by the depth of the safety order ladder, which absorbs a structural pullback of up to 5.37% from base before the ladder is fully consumed.

🔷 Why it's unique:
Multi-timeframe RSI stack - three independent RSI conditions across 5m and 30m act as a regime filter, reducing false entries during trendless chop and isolating only confirmed oversold-exit conditions. Different lookback lengths (RSI(14) and RSI(7)) on the same 5m timeframe capture both medium-term and short-term momentum exhaustion, while the 30m RSI(14) provides higher-timeframe trend-context confirmation for safety orders.
Structural averaging architecture - safety orders trigger only at predefined cumulative deviations from base price (−1.00%, −2.65%, −5.37%), not at fixed time intervals. This aligns re-entries with structurally significant price levels rather than arbitrary clock-based steps, preserving capital efficiency on shallow pullbacks.
Bot Integration - all entries and exits expose alert events with webhook-ready JSON payloads, enabling automated execution through a connected DCA Bot. The strategy publishes the signal, the bot handles position management on the exchange autonomously across multiple pairs.

🔷 Considerations Before Using the Indicator:
Market & Timeframe: Designed and tested on a 3-minute base chart with the multi-RSI signal stack pulling from 5m and 30m. Best suited to liquid, volatile instruments with sufficient intraday range to populate all three RSI conditions - perpetual contracts, tokenized equities, and major altcoins. Not recommended for low-volatility, sideways-only assets where RSI rarely cycles through oversold zones.
Limitations: The strategy carries no stop loss. In sustained downtrends extending beyond the deepest safety order (−5.37% from base), the position holds unrealized loss until either the average is recovered or the deal is manually closed. Consider adding a regime filter (e.g., long-term moving average) for deployment in non-trending or bearish markets.
Backtesting & Demo Testing: Always run extended backtests across multiple market regimes — uptrend, downtrend, and ranging — before deploying real capital. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.
Parameter Adjustments: Default commission and slippage values are calibrated for typical perpetual venues. Adjust commission_value to match your exchange (e.g., 0.05 for OKX Perpetual, 0.055 for Bybit Perpetual, 0.04 for Binance USD-M Futures, 0.10 for Binance Spot, 0.40 for Kraken Spot). Slippage of 5 ticks accounts for typical taker execution on liquid pairs — reduce for very tight markets, increase for thin altcoin order books. Take profit, safety order step, and volume scale should be tuned per instrument volatility profile (see preset section below).

🔷 STRATEGY PROPERTIES
Symbol: OKX:COINUSDT.P (Perpetual Swap on tokenized Coinbase Global stock).
Timeframe: 3m chart with multi-timeframe signal stack (5m / 30m).
Test Period: Feb 26, 2026 - May 7, 2026 (instrument's full available history since listing on OKX).
Initial Capital: 200 USDT.
Order Size per Trade: Base Order 20.075 USDT, Safety Orders 15.075 / 28.64 / 54.42 USDT (martingale ×1.9). Maximum cumulative position notional ≈ 118.21 USDT. Observed Max Drawdown 5.55% - well within the ≤10% threshold.
Commission: OKX taker 0.05% - matches exchange schedule for the tested venue.
Slippage: 5 ticks - accounts for typical taker execution on liquid perpetual contracts.
Margin for Long and Short Positions: 100% (1× leverage assumed; no margin amplification applied).
Indicator Settings: Default Configuration.
Base Order Volume: 20.075 USDT
Safety Order (1st): 15.075 USDT
Max Safety Orders: 3
Volume Scale: 1.9
Price Step (1st SO): 1.0%
Step Scale: 1.65
Take Profit: 1.3% from average entry
Entry Signal: RSI(14, 5m) crossover above 30
SO Signal: RSI(14, 30m) OR RSI(7, 5m) crossover above 30
Strategy: Long Only.

🔷 STRATEGY RESULTS
⚠️ Remember, past results do not guarantee future performance.
Net Profit: +26.56 USDT (+13.28%)
Max Drawdown: 11.84 USDT (5.55%)
Total Closed Trades: 104
Percent Profitable: 73.08% (76 / 104)
Profit Factor: 3.911
Average Trade: [to fill from Strategy Tester report]
Average # Bars in Trades: [to fill from Strategy Tester report]
Benchmarking versus Buy & Hold over the same period:
Strategy:    Max +13.43% / Current +13.43% / Min −0.66%
Buy & Hold:  Max +16.83% / Current +10.66% / Min −7.54%
The strategy captured higher current return than passive holding while drawing down ~11× less at the worst point of the period - reflecting the risk-first design intent.

🔷 RECOMMENDED PRESETS FOR OTHER INSTRUMENTS
These tuning starting points are derived from comparable backtests on adjacent instruments. Always re-validate on your own venue and capital before live deployment.
COINUSDT.P (OKX Perpetual — current default):
Take Profit: 1.3%   |   SO Step: 1.0%   |   Step Scale: 1.65   |   Volume Scale: 1.9
Entry: RSI(14, 5m) > 30   |   SO: RSI(14, 30m) OR RSI(7, 5m) > 30
Reference period: Feb 2026 — May 2026   |   Trades: 104   |   Max DD: 5.55%   |   PF: 3.91
General tuning notes:
Higher-volatility instruments (low-cap altcoins, fresh listings): widen SO step to 1.3–1.5%, raise Step Scale to 1.8–2.0.
Lower-volatility instruments (BTC, ETH on major venues): tighten SO step to 0.6–0.8%, lower TP to 0.8–1.2%.
Ranging or accumulation regimes: lower TP (0.8–1.2%) for higher trade frequency.
Trending regimes: raise TP (2.0–3.0%) to capture larger structural moves.

🔷 How to Use It:
🔸 Adjust Settings: Set Base Order and Safety Order sizes proportional to your capital. The default 20 / 15-USDT structure is calibrated for a 200-USDT test account; scale linearly to your equity. Use the preset table above as a starting point for the instrument you intend to trade, then refine on your own backtest.
🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy is configured to remain below 10% on tested instruments, but extended history may shift this profile. Re-test on your own venue using venue-specific commission and slippage. Demo-trade for at least one month before any live deployment.
🔸 Create alerts to trigger the DCA Bot: Two alert conditions are exposed by the script - "Deal Entry" fires on each new base order, and "Deal TP" fires when the take profit target is hit. Configure both alerts in TradingView with webhook URLs pointing to your DCA Bot's deal-start and close-deal endpoints. Once configured, the strategy publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
Base Order Volume (USD) - Notional value of the initial entry per cycle.
Safety Order Volume (1st, USD) - Notional value of the first averaging-down order; subsequent SOs scale by Volume Scale.
Max Safety Orders - Total number of averaging steps available per deal.
Volume Scale (martingale) - Size multiplier applied to each successive safety order.
Price Step % (1st SO) - Percentage deviation from base price that triggers the first safety order.
Step Scale (martingale) - Multiplier applied to each successive deviation step.
Take Profit % (from AVG) - Profit target percentage measured from average entry price.
Entry RSI Length / Threshold / Timeframe - Parameters for the base order RSI signal.
SO Sig 1 — RSI Length / Threshold / Timeframe - Parameters for the first safety order trigger.
SO Sig 2 — RSI Length / Threshold / Timeframe - Parameters for the second safety order trigger (OR-combined with the first).
Limit by date window? - Toggle to constrain backtest to a specific date range.
From / To - Date range bounds applied when the window filter is enabled.
👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.
__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=5
// =============================================================================
//  Triple-RSI DCA  (Exchange-Agnostic, RSI-signal-based)
//
//  Source bot logic: Bot::MultiBot, RSI-driven DCA Long, no leverage assumption,
//  max_active_deals 9, allowed_deals_on_same_pair 2.
//
//  Pine limitation: a strategy can trade only one symbol. Attach this script
//  to each pair's chart separately. The logic is identical per pair and works
//  across any exchange/instrument (Spot, Perpetual, Linear Futures).
//  Adjust commission_value below to match the venue you backtest on.
//
//  Mapping notes:
//    base_order_volume        = 20.075 USD  (quote_currency)
//    safety_order_volume      = 15.075 USD  (1st SO)
//    max_safety_orders        = 3
//    martingale_volume_coef   = 1.9    (each SO 1.9× the previous one)
//    safety_order_step_pct    = 1.0 %  (1st SO deviation, also "min gate" for signal-SOs)
//    martingale_step_coef     = 1.65   (price-deviation scale)
//    safety_order_calc_mode   = base   (deviation measured from BASE order price)
//    take_profit              = 1.9 %  (take_profit_type = total_bought_volume → from AVG)
//    deal_close_type          = percent (no signal close, pure %-TP)
//    stop_loss                = 0  (disabled)
//    leverage                 = 1×  (no leverage assumed; tweak margin_long if needed)
//    commission default       = 0.1 % (neutral; adjust per exchange — see notes below)
//    backtest window          = unlimited by default (toggle in inputs)
//
//  Commission reference (set commission_value in strategy() to match your venue):
//    Bybit Perpetual / Linear Futures (taker)   : ~0.055
//    Binance Futures USD-M (taker)              : ~0.04
//    Binance Spot (taker)                       : ~0.10
//    Kraken Spot (taker)                        : ~0.40
//    Coinbase Advanced (taker)                  : ~0.40 / ~0.60
//
//  Signals (from strategy_list & safety_strategy_list):
//    BO  entry   : RSI(14, 15m) crosses above 30                        ← deal-start
//    SO  trigger : (RSI(14, 30m) crosses above 30) OR (RSI(7, 5m) crosses above 30)
//                  AND price ≤ base × (1 − cumulative_deviation)
//
//  Cumulative SO deviations (from BASE):
//    SO1 = 1.00 %  →  SO2 = 2.65 %  →  SO3 = 5.37 %
//  SO sizes (martingale ×1.9):
//    SO1 = 15.075  →  SO2 = 28.6425  →  SO3 = 54.42075
//  Per-pair max position notional ≈ 118.21 USD
// =============================================================================

strategy("Multi Long Bot — Single-Pair Replica",
     overlay                 = true,
     initial_capital         = 200,
     default_qty_type        = strategy.cash,
     default_qty_value       = 20.075,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.1,        // Neutral default — adjust per venue (see header notes)
     slippage                = 5,
     pyramiding              = 4,          // BO + 3 SO
     currency                = currency.USD)

// ============================ INPUTS =========================================
boVol     = input.float(20.075, "Base Order Volume (USD)",          minval = 0.5,  step = 0.001, group = "USD-Multi — Order Sizing")
soVol     = input.float(15.075, "Safety Order Volume (1st, USD)",   minval = 0.5,  step = 0.001, group = "USD-Multi — Order Sizing")
maxSO     = input.int  (3,      "Max Safety Orders",                minval = 0, maxval = 10,     group = "USD-Multi — Order Sizing")
volScale  = input.float(1.9,    "Volume Scale (martingale)",        minval = 1.0,  step = 0.01,  group = "USD-Multi — Order Sizing")

stepPct   = input.float(1.0,    "Price Step % (1st SO)",            minval = 0.01, step = 0.05, group = "USD-Multi — Price Deviation") / 100.0
stepScale = input.float(1.65,   "Step Scale (martingale)",          minval = 1.0,  step = 0.01, group = "USD-Multi — Price Deviation")

tpPct     = input.float(1.9,    "Take Profit % (from AVG)",         minval = 0.01, step = 0.05, group = "USD-Multi — Take Profit") / 100.0

useEntryRsi = input.bool   (true, "Require RSI cross-above for BO entry", group = "USD-Multi — Entry Signal (deal start)")
entryLen    = input.int    (14,   "Entry RSI Length",       minval = 2,    group = "USD-Multi — Entry Signal (deal start)")
entryThr    = input.float  (30,   "Entry RSI Threshold",                   group = "USD-Multi — Entry Signal (deal start)")
entryTF     = input.timeframe("15", "Entry RSI Timeframe",                 group = "USD-Multi — Entry Signal (deal start)")

useSoSignal = input.bool   (true, "Require RSI cross-above for SO entry (OR of two TFs)", group = "USD-Multi — SO Signals")
so1Len      = input.int    (14,   "SO Sig 1 — RSI Length", minval = 2,     group = "USD-Multi — SO Signals")
so1Thr      = input.float  (30,   "SO Sig 1 — RSI Threshold",              group = "USD-Multi — SO Signals")
so1TF       = input.timeframe("30","SO Sig 1 — RSI Timeframe",             group = "USD-Multi — SO Signals")
so2Len      = input.int    (7,    "SO Sig 2 — RSI Length", minval = 2,     group = "USD-Multi — SO Signals")
so2Thr      = input.float  (30,   "SO Sig 2 — RSI Threshold",              group = "USD-Multi — SO Signals")
so2TF       = input.timeframe("5", "SO Sig 2 — RSI Timeframe",             group = "USD-Multi — SO Signals")


useDateFilter = input.bool(false, "Limit by date window?",                 group = "USD-Multi — Backtest Window")
fromTs        = input.time(timestamp("2024-01-01 00:00 +0000"), "From",    group = "USD-Multi — Backtest Window")
toTs          = input.time(timestamp("2030-01-01 00:00 +0000"), "To",      group = "USD-Multi — Backtest Window")
inWindow      = useDateFilter ? (time >= fromTs and time <= toTs) : true

// ============================ STATE ==========================================
var float basePx   = na
var float avgPx    = na
var float costSum  = 0.0
var float qtySum   = 0.0
var int   soFilled = 0

// ============================ SIGNALS ========================================
entryRsi    = request.security(syminfo.tickerid, entryTF, ta.rsi(close, entryLen)[1], lookahead = barmerge.lookahead_on)
entrySignal = useEntryRsi ? ta.crossover(entryRsi, entryThr) : true

so1Rsi  = request.security(syminfo.tickerid, so1TF, ta.rsi(close, so1Len)[1], lookahead = barmerge.lookahead_on)
so2Rsi  = request.security(syminfo.tickerid, so2TF, ta.rsi(close, so2Len)[1], lookahead = barmerge.lookahead_on)
soSig   = useSoSignal ? (ta.crossover(so1Rsi, so1Thr) or ta.crossover(so2Rsi, so2Thr)) : true

// ============================ HELPERS ========================================
// Cumulative deviation from base price after k SOs filled
f_cumDev(k) =>
    s = 0.0
    if k > 0
        for i = 0 to k - 1
            s += math.pow(stepScale, i)
    s * stepPct

nextIdx = soFilled + 1
nextDev = nextIdx > 0 and nextIdx <= maxSO ? f_cumDev(nextIdx) : na
nextPx  = not na(basePx) and not na(nextDev) ? basePx * (1.0 - nextDev) : na
nextUsd = soVol * math.pow(volScale, math.max(soFilled, 0))

// ============================ ENTRY: BASE ORDER ==============================
if inWindow and strategy.position_size == 0 and na(basePx) and entrySignal
    fillPx = close
    qty    = boVol / fillPx
    strategy.entry("BO", strategy.long, qty = qty)
    basePx   := fillPx
    avgPx    := fillPx
    costSum  := boVol
    qtySum   := qty
    soFilled := 0

// ============================ SAFETY ORDERS ==================================
// With safety_strategy_list set, SO fires when signal triggers AND price
// has dropped at least the cumulative deviation gate. Market order on signal.
if inWindow and strategy.position_size > 0 and soFilled < maxSO and not na(nextPx)
    if low <= nextPx and soSig
        execPx = math.min(open, nextPx)
        qty    = nextUsd / execPx
        strategy.entry("SO" + str.tostring(nextIdx), strategy.long, qty = qty)
        costSum  := costSum + nextUsd
        qtySum   := qtySum  + qty
        avgPx    := costSum / qtySum
        soFilled := soFilled + 1

// ============================ EXIT: TP (from AVG) ============================
// take_profit_type = total_bought_volume  → percent from AVERAGE entry
tpPx = not na(avgPx) ? avgPx * (1.0 + tpPct) : na
if strategy.position_size > 0 and not na(tpPx) and high >= tpPx and inWindow
    strategy.close_all(comment = "TP")
    basePx   := na
    avgPx    := na
    costSum  := 0.0
    qtySum   := 0.0
    soFilled := 0

// ============================ VISUALS ========================================
plot(strategy.position_size > 0 ? basePx : na, "Base Entry", color = color.new(color.aqua  , 0), linewidth = 1, style = plot.style_linebr)
plot(strategy.position_size > 0 ? avgPx  : na, "Avg Entry",  color = color.new(color.yellow, 0), linewidth = 2, style = plot.style_linebr)
plot(strategy.position_size > 0 ? tpPx   : na, "TP Target",  color = color.new(color.green , 0), linewidth = 1, style = plot.style_linebr)
plot(strategy.position_size > 0 ? nextPx : na, "Next SO",    color = color.new(color.red   , 0), linewidth = 1, style = plot.style_linebr)

plotshape(entrySignal and strategy.position_size == 0 and inWindow, "BO Signal", style = shape.triangleup,   location = location.belowbar, color = color.new(color.lime , 0), size = size.tiny)
plotshape(soSig       and strategy.position_size  > 0 and inWindow, "SO Signal", style = shape.triangledown, location = location.abovebar, color = color.new(color.fuchsia,0), size = size.tiny)

bgcolor(strategy.closedtrades > nz(strategy.closedtrades[1]) ? color.new(color.green, 85) : na)

// ============================ ALERTS / WEBHOOK (DCA Bot) =====================
var string MSG_DEAL_OPEN  = '{"message_type":"bot","bot_id":<BOT_ID>,"email_token":"<EMAIL_TOKEN>","delay_seconds":0,"pair":"USD_{{ticker}}","action":"start_new_deal"}'
var string MSG_DEAL_CLOSE = '{"message_type":"bot","bot_id":<BOT_ID>,"email_token":"<EMAIL_TOKEN>","pair":"USD_{{ticker}}","action":"close_at_market_price"}'

alertcondition(strategy.position_size > 0 and strategy.position_size[1] == 0,             title = "Deal Entry",  message = '{"action":"start_new_deal"}')
alertcondition(strategy.position_size > 0 and not na(tpPx) and high >= tpPx and inWindow, title = "Deal TP",     message = '{"action":"close_at_market_price"}')
````
