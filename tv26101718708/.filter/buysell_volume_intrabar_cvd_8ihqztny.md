# Buy/Sell Volume (Intrabar CVD)

- url: https://www.tradingview.com/script/8ihqZTNY-Buy-Sell-Volume-Intrabar-CVD/
- type: indicator
- pine_id: PUB;8c2554c381b1433daa4b02b445b9607f
- version: 1.0

## Description

A cumulative volume delta indicator that separates buying and selling pressure into two distinct lines, giving you a cleaner read on who is in control of each candle and session.
How It Works
Rather than guessing buy and sell volume from a single candle's OHLC values — which produces results that mirror price and add no new information — this indicator uses TradingView's intrabar analysis engine to examine sub-bars inside each candle. Each sub-bar is independently classified as buying volume (close above open) or selling volume (close below open). Those sub-bar totals are then summed into a per-candle figure and accumulated into running cumulative lines across the session.
The result is a genuine separation of buying and selling pressure that can diverge meaningfully from price, revealing when volume is not confirming the move.
What You See

Green line — Cumulative buying volume (aggressive buyers lifting the ask)
Red line — Cumulative selling volume (aggressive sellers hitting the bid)
Delta histogram — Optional per-candle bar showing the imbalance between buyers and sellers on that specific candle
Delta line — Optional cumulative line showing the net difference between total buying and selling volume

Key Signals to Watch

Divergence — Price making new highs while cumulative sell volume is rising faster than buy volume often precedes a reversal
Crossovers — When the cumulative sell line crosses above the buy line mid-session, selling pressure has taken control
Histogram spikes — Large single-candle imbalances at key price levels confirm or deny the strength of a move

Settings

Reset At — Choose to reset cumulation at the session open (9:30 AM ET), at daily midnight, or never for a fully continuous read
Intrabar Timeframe — Controls the precision of the buy/sell classification. Use 1-minute intrabars on 5-minute charts for best results
Delta Histogram — Toggle the per-candle imbalance bars on or off
Delta Line — Toggle the cumulative net delta line on or off
All colors fully customizable

Important Notes
This indicator uses request.security_lower_tf() for intrabar analysis, the same method used by TradingView's own official CVD indicators. While this approach is significantly more accurate than single-bar OHLC methods, it is still an approximation of true bid/ask tick data. True tick-level classification requires raw transaction data that is not available in Pine Script. The depth of historical data available depends on your TradingView plan — lower plan tiers cover fewer historical bars when using 1-minute intrabars.
Recommended Usage
Best used on intraday timeframes of 1 to 15 minutes. Pair with supply and demand zones or key levels to confirm whether volume is supporting or rejecting a move at those levels.

## Source Code

````pine
//@version=5
indicator("Buy/Sell Volume (Intrabar CVD)", overlay=false, max_bars_back=1000)

// ─── Inputs ───────────────────────────────────────────────────────────────────
resetMode  = input.string("Session Open", title="Reset At",
                 options=["Session Open", "Daily Midnight", "Never"])
ltfInput   = input.string("1", title="Intrabar Timeframe (minutes)",
                 options=["1", "3", "5"])
buyColor   = input.color(color.new(color.green, 0), title="Buy Line Color")
sellColor  = input.color(color.new(color.red,   0), title="Sell Line Color")
showDelta  = input.bool(false, title="Show Delta (Buy − Sell)")
deltaColor = input.color(color.new(color.white, 30), title="Delta Line Color")
showHist   = input.bool(true,  title="Show Per-Bar Delta Histogram")
histBuy    = input.color(color.new(color.green, 50), title="Histogram Buy Color")
histSell   = input.color(color.new(color.red,   50), title="Histogram Sell Color")

// ─── Intrabar volume classification ──────────────────────────────────────────
// Pull close, open, volume from a lower timeframe
// Each intrabar: close > open = buy volume, close < open = sell volume, equal = split 50/50
ltf = ltfInput

[ibBuyVol, ibSellVol] = request.security_lower_tf(syminfo.tickerid, ltf,
     [close > open ? volume : close < open ? 0.0 : volume * 0.5,
      close < open ? volume : close > open ? 0.0 : volume * 0.5])

// Sum intrabar arrays into per-bar buy/sell totals
barBuyVol  = 0.0
barSellVol = 0.0

if array.size(ibBuyVol) > 0
    for i = 0 to array.size(ibBuyVol) - 1
        barBuyVol  += array.get(ibBuyVol,  i)
        barSellVol += array.get(ibSellVol, i)

// ─── Session reset ────────────────────────────────────────────────────────────
nyHour   = hour(time,   "America/New_York")
nyMinute = minute(time, "America/New_York")
isNewDay      = dayofweek != dayofweek[1]
isSessionOpen = nyHour == 9 and nyMinute == 30

shouldReset = switch resetMode
    "Session Open"    => isSessionOpen
    "Daily Midnight"  => isNewDay
    "Never"           => false
    => false

// ─── Cumulative totals ────────────────────────────────────────────────────────
var float cumBuy  = 0.0
var float cumSell = 0.0

if shouldReset
    cumBuy  := barBuyVol
    cumSell := barSellVol
else
    cumBuy  += barBuyVol
    cumSell += barSellVol

cumDelta   = cumBuy - cumSell
barDelta   = barBuyVol - barSellVol

// ─── Plots ────────────────────────────────────────────────────────────────────
plot(cumBuy,  title="Cumulative Buy Volume",  color=buyColor,  linewidth=2)
plot(cumSell, title="Cumulative Sell Volume", color=sellColor, linewidth=2)

plot(showDelta ? cumDelta : na, title="Cumulative Delta",
     color=deltaColor, linewidth=1, style=plot.style_line)

plot(showHist ? barDelta : na, title="Bar Delta Histogram",
     color=barDelta >= 0 ? histBuy : histSell,
     style=plot.style_columns, linewidth=1)

hline(0, "Zero", color=color.new(color.white, 70), linestyle=hline.style_dotted)

// ─── Data window ──────────────────────────────────────────────────────────────
plot(barBuyVol,  title="Bar Buy Vol",  display=display.data_window, color=color.green)
plot(barSellVol, title="Bar Sell Vol", display=display.data_window, color=color.red)
plot(cumDelta,   title="Cum Delta",    display=display.data_window, color=color.white)
````
