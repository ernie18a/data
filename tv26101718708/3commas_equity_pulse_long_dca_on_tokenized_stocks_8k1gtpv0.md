# [3Commas] Equity Pulse Long - DCA on Tokenized Stocks

- url: https://www.tradingview.com/script/8K1gTPV0-3Commas-Equity-Pulse-Long-DCA-on-Tokenized-Stocks/
- type: strategy
- pine_id: PUB;03b5c42557d44dbcae24c97f09620067
- version: 1.0

## Description

[3Commas] Equity Pulse Long - DCA on Tokenized Stocks

🔷 What it does:
This strategy executes a long-only Dollar-Cost-Averaging approach on tokenized equity perpetuals, using an RSI-based exit gate to capture momentum-confirmed take-profits on overbought rebounds. It opens base orders continuously when no active deal exists, layers a structured safety order ladder during price drawdowns, and exits only when the RSI crosses above the overbought threshold AND the position has accumulated the minimum profit target from the average entry. The architecture is calibrated for tokenized stocks where structural bullish drift combines with intraday volatility — instruments like GOOGLUSDT, AAPLUSDT, NVDAUSDT perpetuals on Bitget.
  - Base Order entry: nonstop — opens immediately when no active deal exists
  - Safety Order ladder: 8 levels, cumulative deviation from base with step coefficient 1.22, all SOs equal size (volume coefficient 1.0)
  - Exit: RSI(14) on 15m crosses above 70 AND profit ≥ 0.6% from average entry (dual-gate close)
  - 2× leverage (isolated), no stop loss

🔷 Who is it for:
  Traders looking to apply DCA logic to tokenized equity perpetuals rather than crypto-native pairs.
  Bot operators who automate execution through webhook integration with a DCA Bot.
  Traders seeking exposure to mainstream equities through perpetual contracts during bullish drift periods.
  Cross-instrument testers who want a single signal framework portable across multiple tokenized stocks.

🔷 How does it work:
  Long Entry: A base order opens whenever no active deal exists and the bar is confirmed within the configured window. There is no signal-based entry filter — the strategy reloads continuously, treating each new deal as a fresh DCA cycle.
  Short Entry: Not used — strategy is long-only by design.
  Exit Management: The full position closes when two conditions align simultaneously — RSI(14, 15m) crosses above 70 (momentum-confirmed overbought signal) AND unrealized profit from average entry reaches the minimum threshold (default 0.6%). This dual gate prevents premature exits during shallow rebounds and prevents structural exits when profit is not yet above the threshold. The strategy carries no stop loss; invalidation is replaced by the depth of the safety order ladder (cumulative −8.88% from base across 8 levels) plus the underlying bullish drift assumption for tokenized equities.

🔷 Why it's unique:
  Dual-gate exit logic — most DCA strategies use either a fixed-percentage TP or a signal-only exit. This combines them: the RSI signal acts as a momentum-confirmed exit trigger, but only fires if the position is also profitable above the minimum threshold. This filters out RSI-triggered exits that would close deep-averaged positions at a loss, ensuring every signaled close is both timing-confirmed and economically rational.
  Tokenized equity focus — calibrated for perpetuals on tokenized stocks (GOOGL, AAPL, NVDA, COIN, etc.) where bullish equity drift combines with the intraday volatility of crypto-style perpetual contracts. This is a different volatility regime than native crypto pairs and benefits from different DCA tuning.
  Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads. Bot ID, Email Token, and pair label are exposed as inputs and automatically embedded into the alert message format.

🔷 Considerations Before Using the Indicator:
  Market & Timeframe: Designed for a 15-minute chart on tokenized equity perpetuals with active intraday range. Best suited to instruments with sustained bullish drift and regular pullback structure. Less suited for sustained downtrends or instruments without structural upside bias — tokenized stocks have an embedded long-term upward expectation that crypto-native pairs do not always share. The runtime expectation is 15m; other timeframes will produce different signal density.

  Limitations: The strategy carries no stop loss. In sustained downtrends extending beyond the deepest safety order (−8.88% from base), the position holds unrealized loss until either the average is recovered through subsequent bounces or the deal is manually closed. The structural assumption is that the underlying instrument (tokenized equity) will mean-revert upward over time due to its embedded bullish drift. If this assumption breaks (e.g., during sustained equity bear markets), the strategy is materially exposed.

  Backtesting & Demo Testing: The reference results were generated on Bitget USDT-M Perpetual Futures for GOOGLUSDT during a strong bullish phase for Google stock (Aug 2025 — May 2026). Performance during different equity market regimes (bearish, rangebound) may differ significantly. Always validate on extended history and re-test across multiple instruments before deploying real capital. Demo-trade for at least one month before live deployment. Past performance is not indicative of future results.

  Parameter Adjustments: Commission defaults to 0.06% (Bitget USDT-M taker). Adjust for your venue. Leverage is set to 2× isolated — increase or decrease per your risk tolerance. RSI threshold (70) and the minimum profit gate (0.6%) should be tuned per instrument volatility — tighter thresholds for lower-volatility tokenized stocks, wider for high-beta tickers. SO step (0.5%) and step coefficient (1.22) define ladder depth; widen the step for instruments with bigger intraday swings.

🔷 STRATEGY PROPERTIES
  Symbol: BITGET:GOOGLUSDT.P (GOOGLUSDTPERP Perpetual Mix Contract on Bitget). Strategy is generic — works on any tokenized equity perpetual.
  Timeframe: 15m chart.
  Test Period: Aug 26, 2025 — May 15, 2026 (≈ 9 months).
  Initial Capital: 500 USDT.
  Order Size per Trade: Base Order 13.5 USDT, Safety Orders 9 USDT each (×8 = 72 USDT). Maximum cumulative position notional ≈ 85.5 USDT per deal. With 2× isolated leverage, margin requirement ≈ 42.75 USDT.
  Commission: 0.06% taker (Bitget USDT-M Perpetual reference). Adjust per venue.
  Slippage: 2 ticks — typical taker execution on liquid perpetuals.
  Margin for Long and Short Positions: 50% (2× isolated leverage).
  Indicator Settings: Default Configuration.
    Base Order Volume: 13.5 USDT
    Safety Order Volume: 9.0 USDT
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
  Net Profit: +33.57 USDT (+6.71%)
  Max Drawdown: 16.37 USDT (3.11%)
  Total Closed Trades: 243
  Percent Profitable: 86.42% (210 / 243)
  Profit Factor: 10.54
  Average Trade: [to fill from Strategy Tester report]
  Average # Bars in Trades: [to fill from Strategy Tester report]

  Reference backtest run on BITGET:GOOGLUSDT.P on 15m base chart, Aug 26 2025 — May 15 2026. This window captures a strong bullish phase for Google stock — the structurally ideal regime for the strategy's nonstop reload + RSI-confirmed exit design. The unusually high Profit Factor (8.78) reflects this regime favorability and is not expected to persist through bear markets or extended sideways periods. Re-test on your own venue and across different equity regimes before live deployment.

🔷 How to Use It:
  🔸 Adjust Settings: Set Base Order and Safety Order volumes proportional to your account size and risk tolerance. The default 13.5 / 9-USDT structure is calibrated for a 500-USDT test account with 2× leverage; scale linearly to your equity. RSI threshold can be tightened to 65 for more frequent exits or widened to 75 for fewer, larger captures. The SO step should be widened on instruments with higher intraday volatility.

  🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy is configured for a conservative per-deal risk envelope (max position 85.5 USDT, DD 3.11% on the tested period), but extended history may shift this profile. Re-test on your own venue using venue-specific commission and slippage. The strategy's high Profit Factor on the tested window is regime-dependent — performance during bearish equity periods has not been validated. Demo-trade for at least one month before any live deployment.

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
//  [3Commas] GOOGLUSDT Long DCA — RSI Exit
// ---------------------------------------------------------------------
//  Source bot config (3Commas DCA Bot):
//    Pair         : GOOGLUSDT/USDT (Bitget USDT-M Perpetual Futures)
//    Direction    : Long
//    Type         : Bot::MultiBot, nonstop
//    Leverage     : 2x isolated
//    Base order   : 13.5 USDT, Limit entry
//    Safety order : 9 USDT each, max 8, volume coef 1.0 (all equal)
//                   Step 0.5% from base, step coef 1.22 (cumulative)
//                   3 active SOs at exchange at a time
//    Exit         : RSI(14) on 15m crosses above 70
//                   AND profit >= 0.6% from average entry (dual gate)
//    Stop loss    : disabled
//    Reinvest     : 0%
//
//  3Commas built-in backtest (Aug 26 2025 — Feb 11 2026, 169 days):
//    PNL: +$353.88 (+74.5%)
//
//  Recommended TF for replication: 15-minute chart (matches RSI signal TF)
// =====================================================================

strategy(
     title                   = "[3Commas] GOOGLUSDT Long DCA — RSI Exit",
     shorttitle              = "GOOGL DCA Long",
     overlay                 = true,
     pyramiding              = 9,         // 1 BO + 8 SO
     initial_capital         = 500,
     default_qty_type        = strategy.cash,
     default_qty_value       = 13.5,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.06,      // Bitget USDT-M taker (matches bot fee_rate)
     slippage                = 2,
     margin_long             = 50.0,      // 100 / 2 = 50% for 2x isolated
     calc_on_every_tick      = false)

// =====================================================================
//                              INPUTS
// =====================================================================
boVol    = input.float(13.5, "Base Order Volume (USDT)",            group = "DCA / Safety Orders")
soVol    = input.float(9.0,  "Safety Order Volume (USDT)",          group = "DCA / Safety Orders")
maxSO    = input.int  (8,    "Max Safety Orders",  minval = 0, maxval = 20, group = "DCA / Safety Orders")
soStep   = input.float(0.5,  "Price Step % (1st SO from base)",  step = 0.05, group = "DCA / Safety Orders")
stepCoef = input.float(1.22, "Martingale Step Coefficient",      step = 0.01, group = "DCA / Safety Orders")
volCoef  = input.float(1.0,  "Martingale Volume Coefficient",    step = 0.05, group = "DCA / Safety Orders")

// — Take Profit signal —
useExitRsi  = input.bool   (true, "Require RSI cross-above for close",   group = "Take Profit — RSI Gate")
rsiLen      = input.int    (14,   "RSI Length",   minval = 2,            group = "Take Profit — RSI Gate")
rsiThr      = input.float  (70,   "RSI Threshold",                       group = "Take Profit — RSI Gate")
rsiTF       = input.timeframe("15", "RSI Timeframe",                     group = "Take Profit — RSI Gate")
minProfit   = input.float  (0.6,  "Min Profit % (from avg entry)", minval = 0.01, step = 0.05, group = "Take Profit — RSI Gate") / 100.0

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2025-08-26 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-14 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_GOOGLUSDT",   "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Display —
showStats   = input.bool   (true,        "Show stats card", group = "Display")
statsPosStr = input.string ("top_left",  "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
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
// RSI on selected TF — look-ahead-safe pattern ([1] + lookahead_on)
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
// Cumulative deviation in % for SO_n (mode = base):
//   dev_n = sum_{i=1..n} ( soStep * stepCoef^(i-1) )
// Trigger price for SO_n = basePrice * (1 - dev_n/100)
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
//                             VISUALS
// =====================================================================
plot(inDeal ? basePrice : na, "Base Price", color = color.aqua,   style = plot.style_linebr)
plot(inDeal ? avgPrice  : na, "Avg Entry",  color = color.yellow, style = plot.style_linebr, linewidth = 2)
plot(inDeal ? tpPrice   : na, "TP Target",  color = color.lime,   style = plot.style_linebr, linewidth = 1)

plot(inDeal and soCount < 1 ? soTriggerPrice(1) : na, "SO1", color = color.new(color.red, 40), style = plot.style_linebr)
plot(inDeal and soCount < 2 ? soTriggerPrice(2) : na, "SO2", color = color.new(color.red, 50), style = plot.style_linebr)
plot(inDeal and soCount < 3 ? soTriggerPrice(3) : na, "SO3", color = color.new(color.red, 60), style = plot.style_linebr)
plot(inDeal and soCount < 4 ? soTriggerPrice(4) : na, "SO4", color = color.new(color.red, 70), style = plot.style_linebr)
plot(inDeal and soCount < 5 ? soTriggerPrice(5) : na, "SO5", color = color.new(color.red, 80), style = plot.style_linebr)

plotshape(rsiSig and inDeal, "RSI Exit Sig", shape.triangledown, location.abovebar, color = color.fuchsia, size = size.tiny, text = "RSI")

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
