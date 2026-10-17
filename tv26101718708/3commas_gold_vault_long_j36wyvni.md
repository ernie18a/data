# [3Commas] Gold Vault Long

- url: https://www.tradingview.com/script/j36wYVnI-3Commas-Gold-Vault-Long/
- type: strategy
- pine_id: PUB;486aaa41a7ca4dfea4f6152637710875
- version: 1.0

## Description

[3Commas] Gold Vault Long

🔷 What it does:
This strategy executes a long-only Dollar-Cost-Averaging approach on tokenized gold, designed for traders who want structured accumulation exposure to precious metals through perpetual or spot tokens like XAUT. It opens base orders continuously when no active deal exists, layers a conservative 3-step safety order ladder at constant 2% intervals during price drawdowns, and exits when the position reaches a 1.5% profit from the average entry. The design philosophy is deliberately simple: no signal-based entries, no RSI exit gates, no stop loss — just clean DCA mechanics tuned for the lower-volatility profile of gold versus crypto-native pairs.
  - Base Order entry: nonstop — opens immediately when no active deal exists
  - Safety Order ladder: 3 levels at constant 2% intervals (cumulative −2% / −4% / −6% from base)
  - Volume scale: 1.05× per SO (9.00 / 9.45 / 9.92 USDT)
  - Exit: pure 1.5% take-profit from average entry (no signal gates)
  - Spot trading, no leverage, no stop loss

🔷 Who is it for:
  Traders seeking structured exposure to tokenized gold and precious metals through DCA logic.
  Risk-conservative participants who want low maximum position size relative to capital (≈ 8% in default config).
  Bot operators who automate execution through webhook integration with a DCA Bot.
  Long-term accumulators who prefer steady, predictable returns over leveraged volatility plays.

🔷 How does it work:
  Long Entry: A base order opens whenever no active deal exists and the bar is confirmed within the configured window. There is no signal-based entry filter — the strategy reloads continuously, treating each new deal as a fresh DCA cycle.
  Short Entry: Not used — strategy is long-only by design.
  Exit Management: The full position closes when price reaches Average Entry × (1 + 1.5%). The strategy carries no stop loss; invalidation is replaced by the depth of the safety order ladder (6% cumulative drawdown coverage). Gold's structurally lower volatility versus crypto pairs means the 1.5% take-profit target is hit relatively frequently during normal range trading, producing a high-frequency low-amplitude P&L profile.

🔷 Why it's unique:
  Tokenized gold focus — most DCA strategies target crypto-native pairs with high volatility. This strategy specifically calibrates for the lower-volatility profile of tokenized precious metals like XAUT, with conservative 2% SO steps and a tight 1.5% take-profit. Gold's structurally bullish drift over multi-year horizons combined with intraday liquidity makes it an ideal DCA candidate.
  Simplicity by design — no RSI gates, no trend filters, no signal stacks. Pure DCA mechanics. The strategy depends only on price reaching the average × 1.015 to close, which makes its behavior fully predictable and easy to reason about. Easy to backtest, easy to explain, easy to monitor.
  Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads, enabling direct trigger of a connected DCA Bot. Bot ID, Email Token, and pair label are exposed as inputs.

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: Designed for 2-hour chart on tokenized gold instruments. Best suited for XAUT/USDT and similar precious metals tokens with sustained bullish drift and regular intraday range. Lower timeframes generate more trade frequency but also more commission drag; higher timeframes produce slower-cycling deals with longer holding periods. The default 2h aligns with the reference 3Commas backtest.

  Limitations: The strategy carries no stop loss. In extreme drawdowns extending beyond the deepest safety order (−6% from base), the position holds unrealized loss until either the average is recovered or the deal is manually closed. Gold's historical drawdowns occasionally exceed 6% during macro stress events — pair this strategy with awareness of gold's macro regime context. Without a regime filter, the strategy will continue opening new deals during downtrends.

  Backtesting & Demo Testing: The reference results were generated on a 1-year window covering March 2025 — March 2026 for tokenized gold. Performance during different gold market regimes (bear markets, sustained ranges, geopolitical stress periods) may differ significantly. Always validate on extended history and re-test across different gold rate environments before deploying real capital. Demo-trade for at least one month before live deployment. Past performance is not indicative of future results.

  Parameter Adjustments: Commission defaults to 0.1% (Bybit spot taker). Adjust for your venue — Binance Spot ~0.10%, OKX Spot ~0.08%, Kraken Spot ~0.40%. The 2% SO step and 1.5% TP are tuned for gold's typical intraday range; for higher-volatility precious metals tokens, widen both proportionally.

🔷 STRATEGY PROPERTIES
  Symbol: BYBIT:XAUTUSDT (Tether Gold / Tether spot). Strategy is generic — works on any tokenized precious metal or stable-volatility instrument.
  Timeframe: 2h chart (reference; lower TFs increase trade frequency).
  Test Period: April 11, 2025 — May 16, 2026 (≈ 13 months).
  Initial Capital: 500 USDT.
  Order Size per Trade: Base Order 12 USDT, Safety Orders 9.00 / 9.45 / 9.92 USDT (volume coef 1.05). Maximum cumulative position notional ≈ 40.37 USDT per deal — ≈ 8% of capital, very conservative envelope.
  Commission: 0.1% taker (Bybit spot reference).
  Slippage: 2 ticks — typical taker execution on liquid spot pairs.
  Margin for Long and Short Positions: 100% (1× leverage assumed; no margin amplification).
  Indicator Settings: Default Configuration.
    Base Order Volume: 12 USDT
    Safety Order Volume: 9.0 USDT
    Max Safety Orders: 3
    Price Step (1st SO): 2.0%
    Deviation Step Multiplier: 1.0 (constant 2% step)
    Order Size Multiplier: 1.05
    Take Profit: 1.5% from average entry (pure %-TP)
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +4.66 USDT (+0.93%)
  Max Drawdown: 8.64 USDT (1.69%)
  Total Closed Trades: 82
  Percent Profitable: 80.49% (66 / 82)
  Profit Factor: 6.15
  Average Trade: [to fill from Strategy Tester report]
  Average # Bars in Trades: [to fill from Strategy Tester report]

  Reference backtest run on BYBIT:XAUTUSDT (Spot, 2h chart), Apr 11 2025 — May 16 2026. The high Profit Factor (6.15) reflects gold's structurally bullish drift during the test window combined with low intraday volatility — the ideal regime for a conservative DCA framework with no stop loss. The 80.49% win rate and 1.69% max drawdown demonstrate the strategy's low-risk profile on tokenized gold. Re-test on your own venue with venue-specific commission before live deployment.

🔷 How to Use It:
  🔸 Adjust Settings: Set Base Order and Safety Order volumes proportional to your account size. The default 12 / 9-USDT structure is calibrated for a 500-USDT test account with maximum 8% capital deployment per deal; scale linearly to your equity. The 2% SO step and 1.5% TP are tuned for gold's typical intraday range — widen both for higher-volatility instruments.

  🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy is configured for a conservative per-deal risk envelope (max position ≈ 8% of capital), but extended history may shift this profile. Re-test on your own venue using venue-specific commission. The conservative SO ladder (6% cumulative drawdown coverage) means deep gold drawdowns can leave positions underwater for extended periods — plan for this scenario.

  🔸 Create alerts to trigger the DCA Bot: Two alert messages are exposed by the strategy — "Deal Start" fires on each new base order, and "Deal Close" fires when the 1.5% take-profit target is hit. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. Once configured, the strategy publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
  Base Order Volume (USDT) — Notional value of the initial entry per cycle.
  Safety Order Volume (USDT) — Notional value of each averaging-down order (first SO).
  Max Safety Orders — Total number of averaging steps available per deal.
  Price Step % (1st SO from base) — Percentage deviation from base price for the first safety order.
  Deviation Step Multiplier — Multiplier applied to each successive deviation step (default 1.0 = constant step).
  Order Size Multiplier — Size multiplier applied to each successive safety order (default 1.05 = 5% per step).
  Take Profit % (from avg entry) — Profit target percentage measured from average entry price.
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
//  [3Commas] Gold DCA Long — XAUT/USDT
// ---------------------------------------------------------------------
//  Source bot config (3Commas DCA Bot):
//    Pair         : XAUT/USDT (Bybit Spot, tokenized gold)
//    Direction    : Long
//    Type         : Bot::MultiBot, nonstop reload
//    Base order   : 12 USDT, Limit entry
//    Safety order : 9 USDT each, max 3
//                   Volume coef 1.05 → 9 / 9.45 / 9.9225 USDT
//                   Deviation step 2%, step coef 1.0 (constant step)
//                   Cumulative dev: −2% / −4% / −6% from base
//    Take profit  : 1.5% from average entry (pure %, no signal gate)
//    Stop loss    : disabled
//    Trailing     : disabled
//    Reinvest     : 100%
//
//  3Commas built-in backtest (Mar 5 2025 — Mar 5 2026, 1 year):
//    PNL: +$19.66 (+29.21%)
//
//  Recommended chart TF for replication: 2h (matches reference backtest)
// =====================================================================

strategy(
     title                   = "[3Commas] Gold DCA Long — XAUT/USDT",
     shorttitle              = "Gold DCA Long",
     overlay                 = true,
     pyramiding              = 4,         // 1 BO + 3 SO
     initial_capital         = 500,
     default_qty_type        = strategy.cash,
     default_qty_value       = 12,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.1,       // Bybit spot taker
     slippage                = 2,
     calc_on_every_tick      = false)

// =====================================================================
//                              INPUTS
// =====================================================================
boVol    = input.float(12.0, "Base Order Volume (USDT)",            group = "DCA / Safety Orders")
soVol    = input.float(9.0,  "Safety Order Volume (USDT)",          group = "DCA / Safety Orders")
maxSO    = input.int  (4,    "Max Safety Orders",  minval = 0, maxval = 15, group = "DCA / Safety Orders")
soStep   = input.float(2.0,  "Price Step % (1st SO from base)",  step = 0.05, group = "DCA / Safety Orders")
stepCoef = input.float(1.0,  "Deviation Step Multiplier",       step = 0.01, group = "DCA / Safety Orders")
volCoef  = input.float(1.05, "Order Size Multiplier",            step = 0.01, group = "DCA / Safety Orders")

// — Take Profit —
tpPct = input.float(1.5, "Take Profit % (from avg entry)", minval = 0.01, step = 0.05, group = "Take Profit") / 100.0

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2025-03-05 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-14 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_XAUT",        "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

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
//                               STATE
// =====================================================================
var bool  inDeal      = false
var float basePrice   = na
var float totalVolume = 0.0
var float totalQty    = 0.0
var int   soCount     = 0

avgPrice = totalQty > 0 ? totalVolume / totalQty : na
tpPrice  = na(avgPrice) ? na : avgPrice * (1.0 + tpPct)

// =====================================================================
//                              HELPERS
// =====================================================================
// Cumulative deviation in % for SO_n (mode = base):
//   dev_n = sum_{i=1..n} ( soStep * stepCoef^(i-1) )
// With stepCoef = 1.0 → constant 2% step: SO1=-2%, SO2=-4%, SO3=-6%
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
//                       EXIT — pure %-TP from average
// =====================================================================
priceOK = not na(tpPrice) and high >= tpPrice

if (inDeal and priceOK and barstate.isconfirmed)
    strategy.close_all(comment = "TP")
    inDeal      := false
    basePrice   := na
    totalVolume := 0.0
    totalQty    := 0.0
    soCount     := 0

// =====================================================================
//                             VISUALS
// =====================================================================
// Position-related lines (when deal active)
plot(inDeal ? basePrice : na, "Base Price", color = color.new(color.aqua,   0), style = plot.style_linebr, linewidth = 2)
plot(inDeal ? avgPrice  : na, "Avg Entry",  color = color.new(color.yellow, 0), style = plot.style_linebr, linewidth = 3)
plot(inDeal ? tpPrice   : na, "TP Target",  color = color.new(color.lime,   0), style = plot.style_linebr, linewidth = 2)

// SO ladder (3 levels — fade when filled)
plot(inDeal and maxSO >= 1 ? soTriggerPrice(1) : na, "SO1", color = soCount >= 1 ? color.new(color.gray, 70) : color.new(color.red, 20), style = plot.style_linebr, linewidth = 1)
plot(inDeal and maxSO >= 2 ? soTriggerPrice(2) : na, "SO2", color = soCount >= 2 ? color.new(color.gray, 70) : color.new(color.red, 35), style = plot.style_linebr, linewidth = 1)
plot(inDeal and maxSO >= 3 ? soTriggerPrice(3) : na, "SO3", color = soCount >= 3 ? color.new(color.gray, 70) : color.new(color.red, 50), style = plot.style_linebr, linewidth = 1)

// Entry / Exit markers
boJustOpened = not inDeal[1] and inDeal
soJustAdded  = inDeal and soCount != nz(soCount[1]) and soCount > 0
tpJustClosed = inDeal[1] and not inDeal

plotshape(boJustOpened, "BO Entry",  shape.triangleup,   location.belowbar, color = color.new(color.green,    0), size = size.normal, text = "BO",  textcolor = color.new(color.lime,    0))
plotshape(soJustAdded,  "SO Fill",   shape.triangledown, location.abovebar, color = color.new(color.red,      0), size = size.small,  text = "SO",  textcolor = color.new(color.red,     0))
plotshape(tpJustClosed, "TP Close",  shape.diamond,      location.abovebar, color = color.new(color.aqua,     0), size = size.normal, text = "TP",  textcolor = color.new(color.aqua,    0))

bgcolor(boJustOpened ? color.new(color.green, 90) : na, title = "BO bar")
bgcolor(tpJustClosed ? color.new(color.aqua,  90) : na, title = "TP bar")
bgcolor(soJustAdded  ? color.new(color.red,   92) : na, title = "SO bar")

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
