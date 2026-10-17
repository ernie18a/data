# [3Commas] Pullback Sniper Strategy

- url: https://www.tradingview.com/script/XbtQXDMb-3Commas-Pullback-Sniper-Strategy/
- type: strategy
- pine_id: PUB;2e9af158ccbb44ca98700bd827deb173
- version: 1.0

## Description

🔷 What it does:
This strategy executes a long-only Dollar-Cost-Averaging approach driven by a single classic RSI signal on a 3-minute timeframe. It opens a base order when RSI(14) crosses below an oversold threshold, layers a martingale-scaled safety order ladder at predefined cumulative price deviations from the base, and exits the full position when RSI crosses back above an overbought threshold combined with a minimum profit gate from the average entry. The design is built for high-frequency intraday DCA on volatile liquid instruments — clean signal logic, structured averaging, no stop-loss dependency.

Base Order entry: RSI(14) crosses below 31 on 3m
Safety Order ladder: 5 levels, martingale volume scale ×1.25, deviation scale ×1.30
Exit: RSI(14) crosses above 69 on 3m AND profit ≥ 2.4% from average entry
Cumulative deviation mode (deviations measured from BASE price)

🔷 Who is it for:
Intraday DCA traders who prefer aggressive averaging with tight take-profit cycles.
Bot operators who run automated execution through webhook integration with a DCA Bot.
Discretionary traders who want a single-signal framework that is easy to backtest and tune.
Cross-instrument testers who want one signal layer portable across crypto, perpetuals, and tokenized equities.

🔷 How does it work:
Long Entry: A base order opens when RSI(14, 3m) crosses below 31, signaling entry into an oversold regime. The crossover is a single-shot confirmation per cycle to prevent re-entries during the same RSI sweep.
Short Entry: Not used — long-only by design.
Exit Management: The full position closes when two conditions align — RSI(14, 3m) crosses above 69 (overbought exit signal) AND the unrealized profit from average entry reaches the configured minimum threshold (default 2.4%). This dual gate prevents premature exits during shallow rebounds and structural exits when profit has not yet recovered.

🔷 Why it's unique:
Dual-gate exit logic — closing requires both an RSI sell signal AND a minimum profit threshold from average entry. This combination filters out RSI-triggered exits that would close deep-averaged positions at a loss, ensuring every deal closes only when both the signal and the math agree.
Cumulative martingale architecture — safety order trigger prices are computed from the base entry using a cumulative compounding deviation (each successive step multiplied by ×1.30), not by chaining from the previous SO. This produces a smoother, more controlled deepening of the ladder versus pure linear stepping.
Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads, enabling direct trigger of a connected DCA Bot. The strategy publishes the signal, the bot handles order routing on the exchange.

🔷 Considerations Before Using the Indicator:
Market & Timeframe: Designed for a 3-minute base chart on liquid, volatile instruments with active intraday RSI cycling — perpetual contracts, tokenized equities, and major altcoins. Performance degrades on low-volatility assets where RSI rarely reaches the oversold trigger or where 3-minute candles are illiquid.
Limitations: The strategy carries no stop loss. In sustained downtrends extending beyond the deepest safety order, the position holds unrealized loss until either the average is recovered or the deal is closed manually. Consider adding a regime filter (e.g., long-term moving average direction) for deployment in non-trending or sustained bearish markets. The dual-gate exit can hold positions for extended periods if RSI never crosses above 69 while profit threshold is unmet — pair this with a manual review cadence.
Backtesting & Demo Testing: Always run extended backtests across multiple market regimes — uptrend, downtrend, and ranging — before deploying real capital. Demo-trade for at least one month to observe behavior in conditions not represented in historical data. Past performance is not indicative of future results.
Parameter Adjustments: Default commission and slippage values are calibrated for typical perpetual venues. Adjust commission_value to match your exchange (~0.05 for OKX Perpetual, ~0.055 for Bybit Perpetual, ~0.04 for Binance USD-M Futures, ~0.10 for Binance Spot, ~0.40 for Kraken Spot). Slippage of 5 ticks accounts for taker execution on liquid pairs — reduce for very tight markets, increase for thin order books. RSI thresholds (31 / 69) and the SO step (1.3%) should be tuned per instrument volatility profile.

🔷 STRATEGY PROPERTIES
Symbol: Cross-instrument — tested on Cardano/Tether (BYBIT:ADAUSDT Spot) on 3m. Logic is identical for any liquid pair.
Timeframe: 3m chart.
Test Period: Feb 16, 2026 — May 11, 2026 (≈3 months of recent active trading).
Initial Capital: 10,000 USDT.
Order Size per Trade: Base Order 45 USDT, Safety Orders 55 / 68.75 / 85.94 / 107.42 / 134.28 USDT (martingale ×1.25). Maximum cumulative position notional ≈ 496.39 USDT (≈ 5% of capital). Observed Max Drawdown 0.67% — far inside the ≤10% threshold.
Commission: 0.10% taker — neutral default; adjust per venue (see notes above).
Slippage: 5 ticks — typical taker execution on liquid pairs.
Margin for Long and Short Positions: 100% (1× leverage assumed; no margin amplification applied).
Indicator Settings: Default Configuration.
Base Order Volume: 45 USDT
Safety Order Volume (1st): 55 USDT
Max Safety Orders: 5
Price Step (1st SO): 1.3%
Step Coefficient: 1.30
Volume Coefficient: 1.25
Min Profit (from AVG): 2.4%
Entry: RSI(14, 3m) crossunder 31
Exit Signal: RSI(14, 3m) crossover 69 AND profit ≥ 2.4%
Strategy: Long Only.

🔷 STRATEGY RESULTS
⚠️ Remember, past results do not guarantee future performance.
Net Profit: +95.00 USDT (+0.95%)
Max Drawdown: 67.16 USDT (0.67%)
Total Closed Trades: 47
Percent Profitable: 72.34% (34 / 47)
Profit Factor: 7.377
Average Trade: [to fill from Strategy Tester report]
Average # Bars in Trades: [to fill from Strategy Tester report]
Backtest run on BYBIT:ADAUSDT (Spot) on 3m base chart. Re-run on your own venue with venue-specific commission and slippage before drawing conclusions for live deployment.

🔷 How to Use It:
🔸 Adjust Settings: Set Base Order and Safety Order volumes proportional to your account size. The default 45 / 55-USDT structure is calibrated for a 10,000-USDT test account, so total maximum exposure stays below 5% of capital. Scale linearly to your equity. RSI thresholds (31 / 69) and the SO step (1.3%) can be tightened on lower-volatility instruments or widened on more volatile pairs.
🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy is configured for a very conservative position-size envelope, but extended history may shift the profile. Re-test on your own venue using venue-specific commission and slippage values. Demo-trade for at least one month before any live deployment.
🔸 Create alerts to trigger the DCA Bot: Two alert messages are exposed by the script — "Deal Start" fires on each new base order, and "Deal Close" fires when the dual-gate exit condition triggers. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. Once configured, the strategy publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
RSI Length — Period for the RSI calculation (default 14).
RSI Buy Trigger — Oversold threshold for the base order signal (default 31, cross-below).
RSI Sell Trigger — Overbought threshold for the exit signal (default 69, cross-above).
Base Order Volume (USDT) — Notional value of the initial entry per cycle.
Safety Order Volume (USDT) — Notional value of the first averaging-down order; subsequent SOs scale by Volume Coefficient.
Max Safety Orders — Total number of averaging steps available per deal.
Price Deviation % (SO step from base) — Percentage deviation from base price for the first safety order; subsequent steps scale by Step Coefficient.
Martingale Volume Coefficient — Size multiplier applied to each successive safety order.
Martingale Step Coefficient — Multiplier applied to each successive deviation step.
Min Profit % (from avg entry) — Minimum unrealized profit threshold required for the exit gate.
Require RSI Sell Signal to Close — When enabled, both the RSI sell crossover AND the min profit threshold must align for the position to close (dual-gate exit).
Limit by Date Range — Toggle to constrain backtest to a specific date window.
Stats card / Watermark — Display layer controls for on-chart backtest summary and branding.

Webhook — Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.
__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  Aggressive RSI HYPE/USDT Long  —  DCA Bot Replica
// ---------------------------------------------------------------------
//  Source bot config:
//    Type        : MultiBot (Long, spot)
//    Pair        : USDT_HYPE  (OKX)
//    Entry       : RSI(14) crossing below 31  on 3m
//    Exit        : RSI(14) crossing above 69  on 3m
//                  AND profit >= 2.4% from avg entry (deal_close_type=strategy)
//    Base order  : 45 USDT
//    Safety order: 55 USDT, max 5,
//                  step 1.3% (mode=base, cumulative),
//                  martingale: vol x1.25, step x1.30
//    Stop loss   : disabled
//    TSL         : disabled
//  Backtest period from config: 2026-01-26 14:00 UTC → 2026-04-26 UTC
// =====================================================================

strategy(
     title                   = "[3Commas] Aggressive RSI HYPE/USDT Long",
     shorttitle              = "Agg RSI DCA",
     overlay                 = true,
     pyramiding              = 10,
     initial_capital         = 10000,
     default_qty_type        = strategy.cash,
     default_qty_value       = 45,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.1,
     slippage                = 5,
     calc_on_every_tick      = false,
     process_orders_on_close = false)

// =====================================================================
//                              INPUTS
// =====================================================================
rsiLen     = input.int  (14,   "RSI Length",                    minval = 2, group = "RSI Settings")
rsiBuyLvl  = input.float(31.0, "RSI Buy Trigger (cross below)",             group = "RSI Settings")
rsiSellLvl = input.float(69.0, "RSI Sell Trigger (cross above)",            group = "RSI Settings")

boVol    = input.float(45.0,  "Base Order Volume (USDT)",            group = "DCA / Safety Orders")
soVol    = input.float(55.0,  "Safety Order Volume (USDT)",          group = "DCA / Safety Orders")
maxSO    = input.int  (5,     "Max Safety Orders",  minval = 0, maxval = 15, group = "DCA / Safety Orders")
soStep   = input.float(1.3,   "Price Deviation % (SO step from base)", step = 0.1, group = "DCA / Safety Orders")
volCoef  = input.float(1.25,  "Martingale Volume Coefficient",       step = 0.05, group = "DCA / Safety Orders")
stepCoef = input.float(1.30,  "Martingale Step Coefficient",         step = 0.05, group = "DCA / Safety Orders")

minProfit   = input.float(2.4,  "Min Profit % (from avg entry)", step = 0.1, group = "Take Profit")
useCloseSig = input.bool (true, "Require RSI Sell Signal to Close (deal_close_type=strategy)", group = "Take Profit")

useDates = input.bool(false, "Limit by Date Range",                       group = "Backtest Period")
startTs  = input.time(timestamp("2026-01-26 14:00 +0000"), "Start",       group = "Backtest Period")
endTs    = input.time(timestamp("2026-04-26 23:59 +0000"), "End",         group = "Backtest Period")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_HYPE",        "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Display layer —
showStats   = input.bool   (true,        "Show stats card",                                  group = "Display")
statsPosStr = input.string ("top_left",  "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showWM      = input.bool   (true,        "Show watermark",                                   group = "Display")
wmText      = input.string ("3Commas",   "Watermark text",                                   group = "Display")
wmPosStr    = input.string ("top_right", "Watermark position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
wmSizeStr   = input.string ("huge",      "Watermark size",
     options = ["tiny","small","normal","large","huge"], group = "Display")
wmAlpha     = input.int    (70,          "Watermark transparency (0=solid)", minval = 0, maxval = 100, group = "Display")

// =====================================================================
//                              SIGNALS
// =====================================================================
inRange = (not useDates) or (time >= startTs and time <= endTs)
rsiVal  = ta.rsi(close, rsiLen)
buySig  = ta.crossunder(rsiVal, rsiBuyLvl)
sellSig = ta.crossover (rsiVal, rsiSellLvl)

// =====================================================================
//                               STATE
// =====================================================================
var bool  inDeal      = false
var float basePrice   = na
var float totalVolume = 0.0
var float totalQty    = 0.0
var int   soCount     = 0

avgPrice = totalQty > 0 ? totalVolume / totalQty : na
tpPrice  = na(avgPrice) ? na : avgPrice * (1.0 + minProfit / 100.0)

// =====================================================================
//                              HELPERS
// =====================================================================
// Cumulative price deviation in % for SO_n (mode = base):
//   dev_n = sum_{i=1..n} ( soStep * stepCoef^(i-1) )
// Trigger price for SO_n = basePrice * (1 - dev_n/100)
soTriggerPrice(int n) =>
    dev = 0.0
    s   = soStep
    for i = 1 to n
        dev := dev + s
        s   := s * stepCoef
    basePrice * (1.0 - dev / 100.0)

// Volume of SO_n in quote currency:
//   v_n = soVol * volCoef^(n-1)
soVolume(int n) =>
    soVol * math.pow(volCoef, n - 1)

// =====================================================================
//                            BASE ORDER
// =====================================================================
if (not inDeal and buySig and inRange and barstate.isconfirmed)
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
// Several SOs can trigger inside one bar — process all that the bar
// low has reached, in order.
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
//                              EXIT
// =====================================================================
canCloseBySignal = (not useCloseSig) or sellSig
priceOK          = not na(tpPrice) and close >= tpPrice

if (inDeal and canCloseBySignal and priceOK and barstate.isconfirmed)
    strategy.close_all(comment = "TP")
    inDeal      := false
    basePrice   := na
    totalVolume := 0.0
    totalQty    := 0.0
    soCount     := 0

// =====================================================================
//                             VISUALS
// =====================================================================
plot(inDeal ? avgPrice  : na, "Avg Entry",  color = color.yellow, style = plot.style_linebr, linewidth = 2)
plot(inDeal ? tpPrice   : na, "TP Target",  color = color.lime,   style = plot.style_linebr, linewidth = 2)
plot(inDeal ? basePrice : na, "Base Price", color = color.aqua,   style = plot.style_linebr)
plot(inDeal and soCount < 1 ? soTriggerPrice(1) : na, "SO1", color = color.new(color.red, 40), style = plot.style_linebr)
plot(inDeal and soCount < 2 ? soTriggerPrice(2) : na, "SO2", color = color.new(color.red, 50), style = plot.style_linebr)
plot(inDeal and soCount < 3 ? soTriggerPrice(3) : na, "SO3", color = color.new(color.red, 60), style = plot.style_linebr)
plot(inDeal and soCount < 4 ? soTriggerPrice(4) : na, "SO4", color = color.new(color.red, 70), style = plot.style_linebr)
plot(inDeal and soCount < 5 ? soTriggerPrice(5) : na, "SO5", color = color.new(color.red, 80), style = plot.style_linebr)

plotshape(buySig  and not inDeal[1], "Buy Sig",  shape.triangleup,   location.belowbar, color = color.green, size = size.tiny)
plotshape(sellSig and inDeal,        "Sell Sig", shape.triangledown, location.abovebar, color = color.red,   size = size.tiny)

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

// Live metrics
np         = strategy.netprofit
npPct      = strategy.initial_capital > 0 ? np / strategy.initial_capital * 100 : 0.0
dd         = strategy.max_drawdown
ddPct      = strategy.initial_capital > 0 ? dd / strategy.initial_capital * 100 : 0.0
nTrades    = strategy.closedtrades
wins       = strategy.wintrades
wrPct      = nTrades > 0 ? wins / nTrades * 100 : 0.0
gp         = strategy.grossprofit
gl         = strategy.grossloss
pf         = gl > 0 ? gp / gl : 0.0

// Color rules
clrPos    = color.new(#00C853, 0)
clrNeg    = color.new(#D50000, 0)
clrNeutral= color.new(#FFFFFF, 10)
clrHdrBg  = color.new(#1E88E5, 10)
clrRowBg  = color.new(#0D1B2A, 25)
clrAltBg  = color.new(#152238, 25)
clrBorder = color.new(#1E88E5, 60)

var table stats = table.new(f_pos(statsPosStr), 2, 6, bgcolor = clrRowBg, border_width = 1, border_color = clrBorder, frame_color = clrBorder, frame_width = 1)

if showStats and barstate.islast
    // Header
    table.cell(stats, 0, 0, "BACKTEST RESULTS", text_color = color.white, text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)
    table.cell(stats, 1, 0, "—",                text_color = clrHdrBg,   text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)

    // Net P&L
    table.cell(stats, 0, 1, "Net P&L",  text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 1, (np >= 0 ? "+" : "") + str.tostring(np, "0.00") + "  (" + (npPct >= 0 ? "+" : "") + str.tostring(npPct, "0.00") + "%)",
         text_color = np >= 0 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    // Max Drawdown
    table.cell(stats, 0, 2, "Max Drawdown", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 2, str.tostring(dd, "0.00") + "  (" + str.tostring(ddPct, "0.00") + "%)",
         text_color = clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    // Total Trades
    table.cell(stats, 0, 3, "Total Trades", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 3, str.tostring(nTrades), text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    // Win Rate
    table.cell(stats, 0, 4, "Win Rate", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 4, str.tostring(wrPct, "0.00") + "%  (" + str.tostring(wins) + "/" + str.tostring(nTrades) + ")",
         text_color = wrPct >= 50 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    // Profit Factor
    table.cell(stats, 0, 5, "Profit Factor", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 5, str.tostring(pf, "0.000"), text_color = pf >= 1.5 ? clrPos : (pf >= 1.0 ? clrNeutral : clrNeg), text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

// =====================================================================
//                          BRAND WATERMARK
// =====================================================================
var table wm = table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
if showWM and barstate.islast
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))

// =====================================================================
//                          WEBHOOK ALERTS
// =====================================================================
// Format compatible with DCA Bot signals. In TradingView alert dialog:
//      Webhook URL: https://app.3commas.io/trade_signal/trading_view
//      Message: leave default — the script's alert() supplies it.
dealStartMsg = '{"message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'
dealCloseMsg = '{"action":"close_at_market_price","message_type":"bot","bot_id":' + botId +
     ',"email_token":"' + emailToken + '","delay_seconds":0,"pair":"' + pairLabel + '"}'

// Deal Start (BO entry)
if (buySig and not inDeal[1] and inRange and barstate.isconfirmed)
    alert(dealStartMsg, alert.freq_once_per_bar_close)

// Deal Close (TP via close strategy + min profit gate)
exitNow = inDeal and ((not useCloseSig) or sellSig) and (not na(tpPrice)) and (close >= tpPrice)
if (exitNow and barstate.isconfirmed)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
