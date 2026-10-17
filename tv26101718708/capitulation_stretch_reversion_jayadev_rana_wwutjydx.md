# Capitulation Stretch Reversion [Jayadev Rana]

- url: https://www.tradingview.com/script/WWuTjyDx-Capitulation-Stretch-Reversion-Jayadev-Rana/
- type: strategy
- pine_id: PUB;35cf076b92f6458c811c11d2f1190ce1
- version: 1.0

## Description

OVERVIEW

Capitulation Stretch Reversion is a long-biased, price-action mean-reversion strategy. Its thesis is simple: in an established uptrend, sharp multi-bar pullbacks that stretch price well below its short-term mean tend to snap back. The strategy waits for that stretched, capitulating condition, enters on the first sign of a turn, and exits when price reverts to the mean.

Everything is derived from raw price and range (EMAs of price and Average True Range) - there are no oscillators or external data.

HOW IT WORKS

1. Regime filter. A long EMA (default 200) defines the regime. Long trades are only permitted while price is above it, keeping every entry aligned with the prevailing drift. A symmetric short side exists but is OFF by default (see Direction).

2. Stretch + capitulation. A setup can only arm when price has extended at least a set number of ATRs below a short reversion mean (default 0.5 x ATR from a 5-EMA) AND has printed a run of consecutive lower closes (default 2). This is the "capitulation" filter - it avoids buying shallow noise and waits for a genuine flush.

3. Entry. When the stretched, capitulating condition is met and the current bar closes back up (a reversal bar), a long is taken on the confirmed bar.

4. Exit - three ways. The target is a reversion to the mean: the position is closed once price closes back at or above the reversion EMA. A protective stop sits a wide, volatility-based distance below entry (default 3 x ATR). A time stop closes any trade that has neither hit target nor stop within N bars (default 10).

WHY THE STOP IS WIDE

Mean reversion trades a high hit-rate against an unfavourable reward-to-risk: the target (a snap back to the mean) is near, while the protective stop is deliberately wide so normal wobble does not knock you out. This produces frequent winners but occasional losers that are larger than a typical win. That trade-off is intentional and is shown honestly in the results below - read the LIMITATIONS section carefully.

BACKTEST (defaults, on the loaded history)

Tested on SPY daily with the default inputs and the properties set in the script (10,000 initial capital, 100% of equity per trade, 0.03% commission, 2 ticks slippage). On the sample available in the Strategy Tester this produced roughly a 67% win rate with a profit factor near 1.67, a max drawdown around 10%, and no margin calls, modestly ahead of buy-and-hold over the same window. This is a limited in-sample backtest, not a forward result - your own data window, symbol, fees and fills will differ.

SETTINGS

Regime EMA Length - trend filter that gates entries.
Reversion Mean Length - the EMA used as the snap-back target.
Stretch (ATR from mean) - how far price must extend before a setup arms.
Capitulation Bars - consecutive closes required to confirm exhaustion.
Protective Stop (ATR) and Time Stop (bars) - the exit envelope.
Direction - Trade Longs (on) and Trade Shorts (off by default; counter-trend shorts on up-drifting index ETFs have a much lower hit-rate).
Dashboard - live regime, position, win rate, profit factor and net profit.

LIMITATIONS

Signals are evaluated on bar close, not intraday. The reported win rate is in-sample on a finite history and will not persist unchanged out of sample. Because winners are small and losers wide, a cluster of stopped trades can still produce a meaningful drawdown despite a high win rate - position size accordingly. Percent-of-equity sizing at 100% is for demonstration; use realistic risk-based sizing in practice. Mean reversion underperforms in strong, one-directional trends where price never stretches, and can suffer if a pullback turns into a full regime change. This script is a research and educational tool, not financial advice or a guarantee of future performance.

ORIGINALITY

The contribution is the specific combination: an ATR-normalised "stretch" distance from a fast mean, gated by a consecutive-lower-close capitulation count and a regime filter, with a mean-touch target against a wide ATR stop and a time stop. It is built from first principles on price and range, not a wrapper around a built-in indicator.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Jayadev Rana

//@version=6
strategy("Capitulation Stretch Reversion [Jayadev Rana]",
     shorttitle           = "StretchRev",
     overlay              = true,
     initial_capital      = 10000,
     default_qty_type     = strategy.percent_of_equity,
     default_qty_value    = 100,
     commission_type      = strategy.commission.percent,
     commission_value     = 0.03,
     slippage             = 2,
     pyramiding           = 0,
     calc_on_every_tick   = false,
     margin_long          = 100,
     margin_short         = 100,
     max_labels_count     = 500)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
string GRP_REG  = "Regime Filter"
string GRP_STR  = "Stretch / Capitulation"
string GRP_EXIT = "Exits"
string GRP_SIDE = "Direction"
string GRP_UI   = "Dashboard"

int   trendLen   = input.int(200, "Regime EMA Length", minval = 20, group = GRP_REG,
     tooltip = "Longs are only allowed while price is above this EMA (bullish regime); shorts only below it. This keeps mean-reversion aligned with the dominant drift.")

int   meanLen    = input.int(5, "Reversion Mean Length", minval = 2, maxval = 50, group = GRP_STR,
     tooltip = "The short EMA that price is expected to snap back to. The trade target is a return to this mean.")
int   atrLen     = input.int(14, "ATR Length", minval = 2, group = GRP_STR)
float stretchMult= input.float(0.5, "Stretch (ATR from mean)", minval = 0.0, maxval = 5.0, step = 0.1, group = GRP_STR,
     tooltip = "How far, in ATR units, price must be extended away from the mean before a snapback setup can arm.")
int   capBars    = input.int(2, "Capitulation Bars", minval = 1, maxval = 10, group = GRP_STR,
     tooltip = "Number of consecutive closes in the stretch direction (lower closes for longs) required to confirm exhaustion before entry.")

float stopMult   = input.float(3.0, "Protective Stop (ATR)", minval = 0.5, maxval = 10.0, step = 0.5, group = GRP_EXIT,
     tooltip = "Hard stop distance in ATR units from entry. Mean-reversion uses a wide stop and a near target, so wins are frequent but individual losers are larger than winners.")
int   maxBars    = input.int(10, "Time Stop (bars)", minval = 1, maxval = 100, group = GRP_EXIT,
     tooltip = "If neither the mean target nor the stop is hit within this many bars, the position is closed at market.")

bool  tradeLongs = input.bool(true, "Trade Longs", group = GRP_SIDE)
bool  tradeShorts= input.bool(false, "Trade Shorts", group = GRP_SIDE,
     tooltip = "Symmetric short setups in the bearish regime. Off by default: on strongly up-drifting instruments like index ETFs, counter-trend shorts have a much lower hit-rate. Enable only on two-sided or bearish markets.")

bool  showDash   = input.bool(true, "Show Dashboard", group = GRP_UI)
bool  showSignals= input.bool(true, "Show Entry / Exit Markers", group = GRP_UI)

//------------------------------------------------------------------------------
// Core calculations
//------------------------------------------------------------------------------
float mean  = ta.ema(close, meanLen)
float trend = ta.ema(close, trendLen)
float atr   = ta.atr(atrLen)

var int downRun = 0
var int upRun   = 0
downRun := close < close[1] ? downRun + 1 : 0
upRun   := close > close[1] ? upRun + 1 : 0

bool regimeBull = close > trend
bool regimeBear = close < trend

bool stretchLong  = close < mean - stretchMult * atr
bool stretchShort = close > mean + stretchMult * atr

bool revBarUp = close > open
bool revBarDn = close < open

bool longSetup  = tradeLongs  and regimeBull and stretchLong  and downRun >= capBars and revBarUp
bool shortSetup = tradeShorts and regimeBear and stretchShort and upRun   >= capBars and revBarDn

//------------------------------------------------------------------------------
// Order management
//------------------------------------------------------------------------------
var float stopPx    = na
var int   barsHeld  = 0

bool flat = strategy.position_size == 0

if flat and longSetup and barstate.isconfirmed
    strategy.entry("Long", strategy.long)
    stopPx   := close - stopMult * atr
    barsHeld := 0
else if flat and shortSetup and barstate.isconfirmed
    strategy.entry("Short", strategy.short)
    stopPx   := close + stopMult * atr
    barsHeld := 0

bool longOpen  = strategy.position_size > 0
bool shortOpen = strategy.position_size < 0

if longOpen or shortOpen
    barsHeld += 1

// Protective stops (intrabar)
if longOpen and not na(stopPx)
    strategy.exit("L-Stop", from_entry = "Long", stop = stopPx)
if shortOpen and not na(stopPx)
    strategy.exit("S-Stop", from_entry = "Short", stop = stopPx)

// Mean-reversion target + time stop (evaluated on confirmed close)
bool longTP  = longOpen  and close >= mean
bool shortTP = shortOpen and close <= mean
bool longTime  = longOpen  and barsHeld >= maxBars
bool shortTime = shortOpen and barsHeld >= maxBars

if barstate.isconfirmed
    if longTP
        strategy.close("Long", comment = "Mean")
    else if longTime
        strategy.close("Long", comment = "Time")
    if shortTP
        strategy.close("Short", comment = "Mean")
    else if shortTime
        strategy.close("Short", comment = "Time")

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------
plot(mean,  "Reversion Mean", color = color.new(color.orange, 0), linewidth = 1)
plot(trend, "Regime EMA",     color = color.new(color.gray, 40), linewidth = 1)

bgcolor(regimeBull ? color.new(color.teal, 92) : color.new(color.red, 92), title = "Regime tint")

plotshape(showSignals and flat and longSetup  and barstate.isconfirmed, "Long Setup",  style = shape.triangleup,   location = location.belowbar, color = color.new(#26a69a, 0), size = size.tiny)
plotshape(showSignals and flat and shortSetup and barstate.isconfirmed, "Short Setup", style = shape.triangledown, location = location.abovebar, color = color.new(#ef5350, 0), size = size.tiny)

//------------------------------------------------------------------------------
// Dashboard
//------------------------------------------------------------------------------
var table dash = na
if showDash and barstate.islast
    if na(dash)
        dash := table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 25), border_width = 1, border_color = color.new(color.gray, 70))
    float wr  = strategy.closedtrades > 0 ? strategy.wintrades / strategy.closedtrades * 100.0 : na
    float pf  = strategy.grossloss > 0 ? strategy.grossprofit / strategy.grossloss : na
    float net = strategy.netprofit
    string posTxt = longOpen ? "LONG" : shortOpen ? "SHORT" : "FLAT"
    table.cell(dash, 0, 0, "STRETCH REVERSION", text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(dash, 1, 0, regimeBull ? "BULL" : "BEAR", text_color = regimeBull ? #26a69a : #ef5350, text_size = size.small, bgcolor = color.new(color.black, 10))
    table.cell(dash, 0, 1, "Position", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 1, posTxt, text_color = longOpen ? #26a69a : shortOpen ? #ef5350 : color.gray, text_size = size.small)
    table.cell(dash, 0, 2, "Win Rate", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 2, na(wr) ? "—" : str.tostring(wr, "#.#") + " %", text_color = not na(wr) and wr >= 60 ? #26a69a : color.white, text_size = size.small)
    table.cell(dash, 0, 3, "Trades", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 3, str.tostring(strategy.closedtrades), text_color = color.white, text_size = size.small)
    table.cell(dash, 0, 4, "Profit Factor", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 4, na(pf) ? "—" : str.tostring(pf, "#.##"), text_color = not na(pf) and pf >= 1 ? #26a69a : #ef5350, text_size = size.small)
    table.cell(dash, 0, 5, "Net Profit", text_color = color.silver, text_size = size.small)
    table.cell(dash, 1, 5, str.tostring(net, "#.##"), text_color = net >= 0 ? #26a69a : #ef5350, text_size = size.small)

//------------------------------------------------------------------------------
// Alerts (order-fill alerts fire automatically; these mirror the raw setups)
//------------------------------------------------------------------------------
if flat and longSetup and barstate.isconfirmed
    alert("Stretch Reversion: LONG setup on " + syminfo.ticker, alert.freq_once_per_bar_close)
if flat and shortSetup and barstate.isconfirmed
    alert("Stretch Reversion: SHORT setup on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
