# [3Commas] Trail Hunter - Reversal Long

- url: https://www.tradingview.com/script/d117dN6D-3Commas-Trail-Hunter-Reversal-Long/
- type: strategy
- pine_id: PUB;e275c3df7a164057a7b38a0a2f80e15d
- version: 2.0

## Description

[3Commas] Trail Hunter - Reversal Long

🔷 What it does:
This strategy hunts mean-reversion long entries on liquid instruments using a dual-indicator confluence — a moving-average cross-under combined with a CCI oversold confirmation. Once a position opens, the exit is managed through a trailing take-profit that activates at a configurable profit level and follows price upward with a tight deviation, locking in gains while letting strong moves run. A hard stop loss caps downside on invalidation. No DCA, no safety orders — one entry, one trailing exit, one stop.
  - Entry: SMA(24) crosses below SMA(31) AND CCI(11) crosses below -80 (within configurable signal alignment window)
  - Exit: Trailing take-profit, activation at +1.5%, trailing deviation 0.05%
  - Hard Stop: −3.25% from entry
  - Single entry per cycle; no averaging or safety order ladder

🔷 Who is it for:
  Mean-reversion traders who want a single-entry framework without DCA complexity.
  Bot operators who automate execution through webhook integration with a DCA Bot.
  Traders who prefer trailing exits over fixed take-profit targets for capturing extended moves.
  Cross-instrument users who run the same signal framework across crypto perpetuals, spot pairs, and equity indices.

🔷 How does it work:
  Long Entry: A long position opens when two conditions align - SMA(24) crosses below SMA(31) AND CCI(11) drops below −80, both detected on the signal timeframe. The strategy uses a configurable signal keep-alive window so the two confirmations do not need to fire on the exact same bar - they just need to overlap within a small number of bars to count as a valid setup.
  Short Entry: Not used - strategy is long-only by design.
  Exit Management: Once filled, two exit conditions are armed simultaneously. The trailing take-profit activates when price reaches Entry × (1 + Take Profit %), then follows the highest price reached with a deviation gap; if price retraces by the deviation amount from the peak, the position closes. The hard stop loss closes immediately if price drops to Entry × (1 − Stop Loss %). Whichever fires first wins.

🔷 Why it's unique:
  Dual-indicator confluence - neither signal acts alone. The MA cross-under confirms short-term momentum exhaustion against the medium-term trend, and the CCI extreme confirms statistical oversold conditions. Requiring both filters out single-indicator false positives common to either condition alone, especially during sideways regimes.
  Trailing-exit architecture - fixed take-profits cap gains on trending moves. The trailing exit lets a strong rebound run while protecting the activation-level profit with a tight deviation. On instruments that mean-revert with sharp upward bounces, this design captures significantly more than a fixed +1.5% close would.
  Bot Integration - entry and exit alerts ship with webhook-ready JSON payloads, enabling direct trigger of a connected DCA Bot. Bot ID, Email Token, and pair label are exposed as inputs and automatically embedded into the alert message format.

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: Designed for 1-hour base charts on liquid instruments with frequent intraday MA crossings - major crypto perpetuals (BTC, ETH, SOL), spot pairs on Coinbase and Bybit, and high-volume equity tickers. Performance degrades on illiquid altcoins where the MA pair (SMA 24 vs 31) rarely crosses or where CCI rarely touches −80. The signal timeframe is configurable independently of the chart timeframe.

  Limitations: This is a single-entry strategy with no averaging mechanism. If the entry is wrong and price continues against the position, the hard stop loss at −3.25% caps the loss but does not recover. The strategy does not include a regime filter, so it can enter long during sustained downtrends if the dual signal aligns. For deployment in bearish conditions, consider adding a higher-timeframe trend filter (e.g., 4h or daily moving average direction) above the entry logic.

  Backtesting & Demo Testing: Always validate across multiple market regimes - uptrend, downtrend, and ranging - before deploying real capital. The trailing exit behavior is sensitive to instrument volatility and intra-bar tick density, so live performance can deviate from backtest if the venue has different execution characteristics. Demo-trade for at least one month before live deployment. Past performance is not indicative of future results.

  Parameter Adjustments: Commission and slippage defaults are calibrated for Bybit linear perpetual taker fees (0.055%). Adjust to match your venue — Coinbase Spot taker is ~0.4–0.6%, Binance USD-M Futures ~0.04%, OKX Perpetual ~0.05%. The signal timeframe, MA lengths, CCI threshold, and trailing deviation should all be re-tuned per instrument before going live. Tighter MA pairs and lower CCI threshold for low-volatility assets; the opposite for high-volatility.

🔷 STRATEGY PROPERTIES
  Symbol: Cross-instrument - defaults to 1-hour base chart on any liquid pair. Reference testing performed on BTC/USD (COINBASE:BTCUSD).
  Timeframe: 1h chart, signals on 1h (configurable).
  Test Period: May 12, 2025 - May 12, 2026 (12 months).
  Initial Capital: 10,000 USDT.
  Order Size per Trade: Base Order 41.55858 USDT (≈ 0.42% of capital per trade). Single entry only - no safety order stacking.
  Commission: 0.055% taker (Bybit linear default). Adjust per venue.
  Slippage: 5 ticks - typical taker execution on liquid pairs.
  Margin for Long and Short Positions: 100% (1× leverage assumed; no margin amplification).
  Indicator Settings: Default Configuration.
    MA Type: SMA
    Fast MA Length: 24
    Slow MA Length: 31
    MA Cross Timeframe: 1h
    CCI Length: 11
    CCI Oversold Threshold: −80
    CCI Timeframe: 1h
    Signal Combine: AND
    Signal Keep-Alive: 3 bars
    Take Profit (activation): 1.5%
    Trailing Deviation: 0.05%
    Stop Loss: 3.25%
  Strategy: Long Only.

🔷 STRATEGY RESULTS
  ⚠️ Remember, past results do not guarantee future performance.
  Net Profit: +13.09 USD (+0.13%)
  Max Drawdown: 7.91 USD (0.08%)
  Total Closed Trades: 66
  Percent Profitable: 69.70% (46 / 66)
  Profit Factor: 1.254
  Average winning Trade: 1.83%
  Average # Bars in Trades: 34

  Reference backtest run on COINBASE:BTCUSD on 1h base chart, May 12 2025 - May 12 2026. Re-run on your own venue with venue-specific commission and slippage before drawing conclusions for live deployment.

🔷 How to Use It:
  🔸 Adjust Settings: Set Base Order volume proportional to your account size. The default 41.55858 USDT structure is calibrated for a 10,000-USDT test account, keeping per-trade risk at ≈ 0.4% of capital under the −3.25% stop. Scale linearly to your equity. MA pair lengths, CCI threshold, and the trailing deviation should be tuned per instrument volatility profile.

  🔸 Results Review: Verify Maximum Drawdown stays within your personal risk budget. The strategy is configured for a very conservative per-trade risk envelope, but trade frequency and DD profile shift significantly across instruments and regimes. Re-test on your own venue using venue-specific commission and slippage values. Demo-trade for at least one month before any live deployment.

  🔸 Create alerts to trigger the DCA Bot: Two alert messages are exposed by the script - "Deal Start" fires on each new entry, and "Deal Close" fires when either the trailing exit or the stop loss triggers. Configure both alerts in TradingView with the webhook URL pointing to your DCA Bot's signal endpoint. Once configured, the strategy publishes the signal and the bot handles execution on the exchange autonomously.

🔷 INDICATOR SETTINGS
  MA Type - Moving average type for entry calculation (SMA or EMA).
  Fast MA Length - Period of the fast moving average (default 24).
  Slow MA Length - Period of the slow moving average (default 31).
  MA Cross Timeframe - Timeframe on which the MA crossing is computed.
  Use MA Cross signal - Toggle the MA condition on or off in the entry stack.
  CCI Length - Period for the CCI indicator (default 11).
  CCI Oversold Threshold - Value below which CCI must cross to qualify as an oversold signal (default −80).
  CCI Timeframe - Timeframe on which the CCI crossing is computed.
  Use CCI signal - Toggle the CCI condition on or off.
  Combine Signals - AND requires both conditions within the keep-alive window; OR fires entry on either condition alone.
  Signal Keep-Alive (bars) - Number of bars within which both signals must align for AND mode (default 3).
  Base Order Volume (USDT) - Notional value of the entry per cycle.
  Take Profit % (activation) - Profit level at which the trailing exit arms.
  Enable Trailing Stop - Toggle trailing behavior on the take-profit exit.
  Trailing Deviation % - Distance from the peak price at which the trailing exit fires.
  Enable Stop Loss - Toggle the hard stop loss on or off.
  Stop Loss % (from entry) - Maximum acceptable loss from entry price.
  Limit by Date Range - Constrain backtest to a specific date window.
  Stats card / Watermark - Display layer controls for on-chart backtest summary and branding.

  Webhook - Bot ID, Email Token, and Pair label for DCA Bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] MA-CCI Trailing Long — Mean Reversion Strategy
// ---------------------------------------------------------------------
//  Source bot config:
//    Type        : Bot::MultiBot (Long, perpetual)
//    Pair        : USDT_BTC
//    Entry       : SMA(24) crosses below SMA(31) on 1h  AND
//                  CCI(11) on 1h falls below −80
//    Exit        : Trailing take profit
//                    Activation: +1.5% from entry
//                    Trailing deviation: 0.05%
//    Stop loss   : −3.25% (hard SL from entry)
//    Base order  : 41.55858 USDT
//    Safety ord  : disabled (max_safety_orders = 0, single entry)
//    Leverage    : 1x cross (no margin amplification)
// =====================================================================

strategy(
     title                   = "[3Commas] MA-CCI Trailing Long",
     shorttitle              = "MA-CCI Trail",
     overlay                 = true,
     pyramiding              = 0,
     initial_capital         = 10000,
     default_qty_type        = strategy.cash,
     default_qty_value       = 41.55858,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.055,        // Bybit linear taker
     slippage                = 5,
     calc_on_every_tick      = false,
     process_orders_on_close = false)

// =====================================================================
//                              INPUTS
// =====================================================================
maType     = input.string ("SMA", "MA Type", options = ["SMA","EMA"], group = "Entry — MA Cross")
maFastLen  = input.int    (24,   "Fast MA Length",            minval = 2, group = "Entry — MA Cross")
maSlowLen  = input.int    (31,   "Slow MA Length",            minval = 2, group = "Entry — MA Cross")
maTF       = input.timeframe("60", "MA Cross Timeframe",                  group = "Entry — MA Cross")
useMACross = input.bool   (true, "Use MA Cross signal",                   group = "Entry — MA Cross")

cciLen   = input.int  (11,   "CCI Length",                    minval = 2, group = "Entry — CCI")
cciThr   = input.float(-80,  "CCI Oversold Threshold",                    group = "Entry — CCI")
cciTF    = input.timeframe("60", "CCI Timeframe",                          group = "Entry — CCI")
useCCI   = input.bool (true, "Use CCI signal",                            group = "Entry — CCI")

combineMode  = input.string("AND", "Combine Signals", options = ["AND","OR"], group = "Entry — Signal Combination")
keepAliveBars= input.int   (3,     "Signal Keep-Alive (bars)", minval = 1, maxval = 20, tooltip = "Bars within which both signals must align for AND mode", group = "Entry — Signal Combination")

boVol = input.float(41.55858, "Base Order Volume (USDT)", minval = 0.01, step = 0.01, group = "Position Sizing")

tpPct        = input.float(1.5,  "Take Profit % (activation)", minval = 0.01, step = 0.05, group = "Take Profit / Trailing") / 100.0
trailEnabled = input.bool (true, "Enable Trailing Stop",                                    group = "Take Profit / Trailing")
trailDevPct  = input.float(0.05, "Trailing Deviation %",       minval = 0.01, step = 0.01, group = "Take Profit / Trailing") / 100.0

useSL = input.bool (true, "Enable Stop Loss",                                  group = "Stop Loss")
slPct = input.float(3.25, "Stop Loss % (from entry)", minval = 0.01, step = 0.05, group = "Stop Loss") / 100.0

useDates = input.bool(false, "Limit by Date Range", group = "Backtest Period")
startTs  = input.time(timestamp("2025-05-11 16:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-12 16:00 +0000"), "End",   group = "Backtest Period")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (DCA Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (DCA Bot)")
pairLabel  = input.string("USDT_ETHUSDT",     "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (DCA Bot)")

// — Display —
showStats   = input.bool   (true,        "Show stats card",  group = "Display")
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
inRange = (not useDates) or (time >= startTs and time <= endTs)

// MA values on selected TF — for plotting only (look-ahead-safe [1] + lookahead_on)
maFastVal = request.security(syminfo.tickerid, maTF, (maType == "SMA" ? ta.sma(close, maFastLen) : ta.ema(close, maFastLen))[1], lookahead = barmerge.lookahead_on)
maSlowVal = request.security(syminfo.tickerid, maTF, (maType == "SMA" ? ta.sma(close, maSlowLen) : ta.ema(close, maSlowLen))[1], lookahead = barmerge.lookahead_on)

// Cross detection MUST be computed INSIDE security context to capture every
// signal-TF crossing event regardless of chart timeframe. Otherwise on a 1h
// chart with 15m signals, intra-hour crosses are aggregated away and missed.
maCrossSig = request.security(syminfo.tickerid, maTF,
     ta.crossunder(
         maType == "SMA" ? ta.sma(close, maFastLen) : ta.ema(close, maFastLen),
         maType == "SMA" ? ta.sma(close, maSlowLen) : ta.ema(close, maSlowLen)
     ),
     lookahead = barmerge.lookahead_off)

cciSig = request.security(syminfo.tickerid, cciTF,
     ta.crossunder(ta.cci(close, cciLen), cciThr),
     lookahead = barmerge.lookahead_off)

// Keep-alive tracker — bar_index of last fire for each signal
// Use explicit -1 sentinel (more reliable than na for int in Pine v6)
var int maLastBar  = -1
var int cciLastBar = -1

if maCrossSig
    maLastBar := bar_index
if cciSig
    cciLastBar := bar_index

maAlive  = (not useMACross) or (maLastBar  >= 0 and (bar_index - maLastBar)  <= keepAliveBars)
cciAlive = (not useCCI)     or (cciLastBar >= 0 and (bar_index - cciLastBar) <= keepAliveBars)

// Either signal must have just fired on this bar
freshlyFired = (useMACross and maCrossSig) or (useCCI and cciSig)

// Combined entry condition
entrySignal = combineMode == "AND" ? (maAlive and cciAlive and freshlyFired) : (maCrossSig or cciSig)

// =====================================================================
//                               STATE
// =====================================================================
var float entryPx = na

// =====================================================================
//                              ENTRY
// =====================================================================
if (strategy.position_size == 0 and entrySignal and inRange and barstate.isconfirmed)
    qty = boVol / close
    strategy.entry("Long", strategy.long, qty = qty)
    entryPx := close

// =====================================================================
//                              EXIT
// =====================================================================
// One strategy.exit call handles both SL + trailing TP (or fixed TP if trailing off).
if (strategy.position_size > 0 and not na(entryPx))
    slPx          = entryPx * (1.0 - slPct)
    tpActivPx     = entryPx * (1.0 + tpPct)
    // trail_offset requires integer ticks in Pine v6 — cast explicitly
    trailOffTicks = math.max(1, int(math.round(entryPx * trailDevPct / syminfo.mintick)))

    strategy.exit("Exit",
         from_entry   = "Long",
         stop         = useSL        ? slPx          : na,
         trail_price  = trailEnabled ? tpActivPx     : na,
         trail_offset = trailEnabled ? trailOffTicks : na,
         limit        = (not trailEnabled) ? tpActivPx : na)

// Reset state when position closes
if (strategy.position_size == 0 and strategy.position_size[1] > 0)
    entryPx := na

// =====================================================================
//                             VISUALS
// =====================================================================
// MA debug lines — visible always so you can see if signals are computing
showMAs = input.bool(true, "Show MA lines on chart", group = "Display")
plot(showMAs ? maFastVal : na, "Fast MA", color = color.new(#00BCD4, 0), linewidth = 1)
plot(showMAs ? maSlowVal : na, "Slow MA", color = color.new(#FF9800, 0), linewidth = 1)

// Position-related lines (only when in trade)
plot(strategy.position_size > 0 ? entryPx                    : na, "Entry",   color = color.aqua,   style = plot.style_linebr, linewidth = 2)
plot(strategy.position_size > 0 ? entryPx * (1.0 + tpPct)    : na, "TP/Trail",color = color.lime,   style = plot.style_linebr, linewidth = 1)
plot(strategy.position_size > 0 and useSL ? entryPx * (1.0 - slPct) : na, "SL", color = color.red, style = plot.style_linebr, linewidth = 1)

// Signal markers — fire on every signal, even without entry
plotshape(useMACross and maCrossSig, "MA Cross",     shape.triangledown, location.abovebar, color = color.new(#FF9800, 30), size = size.tiny, text = "MA",  textcolor = color.new(#FF9800, 0))
plotshape(useCCI and cciSig,         "CCI Oversold", shape.triangleup,   location.belowbar, color = color.new(#00BCD4, 30), size = size.tiny, text = "CCI", textcolor = color.new(#00BCD4, 0))
plotshape(entrySignal and strategy.position_size == 0, "Long Entry", shape.triangleup, location.belowbar, color = color.green, size = size.small, text = "L", textcolor = color.green)

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

// Safer pattern: create table lazily inside the if-block (avoids Pine v6 issues
// with `var table` initializing from input-derived position).
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

// Deal Start
if (entrySignal and strategy.position_size == 0 and inRange and barstate.isconfirmed)
    alert(dealStartMsg, alert.freq_once_per_bar_close)

// Deal Close (when position transitions from open to flat)
if (strategy.position_size == 0 and strategy.position_size[1] > 0 and barstate.isconfirmed)
    alert(dealCloseMsg, alert.freq_once_per_bar_close)
````
