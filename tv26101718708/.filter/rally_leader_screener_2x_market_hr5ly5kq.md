# Rally Leader Screener (2x Market)

- url: https://www.tradingview.com/script/Hr5LY5kq-Rally-Leader-Screener-2x-Market/
- type: indicator
- pine_id: PUB;74f908c2b64d4b4583675b59db6251c2
- version: 1.0

## Description

Rally Leader Screener (2x Market) — with Resisting-Weakness Flag
What it does
This indicator is built for the Pine Screener and identifies stocks demonstrating institutional-grade relative strength in two distinct market regimes:

Rally Leaders — After a market correction, the first stocks to rally 2x (or more) the index's move during the initial 6–7 session bounce are frequently the emerging leaders of the new uptrend. This tool automates that measurement: it pulls the benchmark index return over your chosen lookback window and flags any stock whose return is at least a user-defined multiple of the index return.
Resisting Weakness — When the market is flat or declining over the lookback window, the "Leader" logic correctly stays silent (there is no rally to lead). Instead, a second flag identifies stocks that are rising strongly despite market weakness — a classic early sign of accumulation and often the leader list of the next cycle.

Concept
The methodology draws on well-known momentum research (O'Neil, Minervini): true market leaders declare themselves in the first days of a new rally by outrunning the index by a wide margin, and/or by refusing to decline while the broad market corrects. This script quantifies both behaviors.
Screener columns

Stock Return % — the stock's return over the lookback window
Nifty Return % — the benchmark's return over the same window (default NSE:NIFTY, changeable to any index)
RS Multiple — stock return ÷ index return; shown only when the index return is positive (a ratio against a negative or near-zero denominator is meaningless, so it displays blank)
Leader — 1 when the index return is positive AND the stock's return ≥ (multiple × index return), plus liquidity/trend filters
Resisting — 1 when the index return is ≤ 0 AND the stock is up by at least the user-set minimum, plus the same filters
Ret Spread % — stock return minus index return; an all-weather relative-strength column that remains valid in up, down, and flat markets, useful for sorting when RS Multiple is blank

Inputs

Rally lookback (sessions): default 7 — match this to the actual length of the bounce
Leadership multiple: default 2.0 (the "2x the market" rule)
Benchmark index: default NSE:NIFTY; set to any index matching your watchlist universe
Minimum price and 20-day average volume: liquidity filters
Optional filters: close above 50 SMA, and up-day requirement
Resist flag minimum return %: threshold for the weak-market flag (default 5%)

How to use

Add the script to favorites, open Pine Screener, and select a watchlist (e.g., a broad index universe).
During/after a 6–7 day market rally: filter Leader == 1, sort by RS Multiple descending, and save the top names as a fixed watchlist. The intended workflow is to trade setups only within that list for the following weeks rather than re-scanning continuously.
During corrections or flat markets: filter Resisting == 1, sort by Ret Spread % descending, to build a pre-watchlist of stocks under accumulation.
Names appearing on both lists across a correction→rally sequence historically carry the highest leadership probability.

Notes

Designed for the daily timeframe.
This is a screening/ranking tool, not a buy/sell signal generator. Entries and exits should be based on your own setup criteria and risk management.
Works on any market — change the benchmark symbol to match (e.g., SPX for US stocks).

## Source Code

````pine
//@version=6
indicator("Rally Leader Screener (2x Market)", overlay = false)

// ── Inputs ─────────────────────────────────────────
len       = input.int(7, "Rally lookback (sessions)", minval = 2, maxval = 30)
mult      = input.float(2.0, "Leadership multiple (x index)", step = 0.25)
idxSym    = input.symbol("NSE:NIFTY", "Benchmark index")
minPrice  = input.float(50, "Min price")
minAvgVol = input.float(100000, "Min 20-day avg volume")
useSMA50  = input.bool(true, "Require close > 50 SMA")
useUpDay  = input.bool(true, "Require up day (still participating)")

// NEW: threshold for the weak-market flag
resistMin = input.float(5.0, "Resist flag: min stock return % when market is flat/down", step = 0.5)

// ── Returns ────────────────────────────────────────
idxClose = request.security(idxSym, timeframe.period, close)

stockRet = (close - close[len]) / close[len] * 100
idxRet   = (idxClose - idxClose[len]) / idxClose[len] * 100

// RS multiple: how many times the market's move this stock did
rsMult = idxRet > 0 ? stockRet / idxRet : na

// ── Filters ────────────────────────────────────────
liquid  = close >= minPrice and ta.sma(volume, 20) >= minAvgVol
trendOK = not useSMA50 or close > ta.sma(close, 50)
upDay   = not useUpDay or close > close[1]

// ── Leader condition (unchanged) ───────────────────
isLeader = idxRet > 0 and stockRet >= mult * idxRet and liquid and trendOK and upDay

// ── NEW: Resisting-weakness condition ──────────────
// Fires when the market is flat or down over the window,
// but the stock is up strongly anyway. Same liquidity/trend filters.
isResisting = idxRet <= 0 and stockRet >= resistMin and liquid and trendOK and upDay

// Spread: stock return minus index return. Works in BOTH regimes,
// so you always have a sortable strength column even when RS Multiple is na.
retSpread = stockRet - idxRet

// ── Screener columns ───────────────────────────────
plot(stockRet,               "Stock Return %",   color.blue)
plot(idxRet,                 "Nifty Return %",   color.gray)
plot(rsMult,                 "RS Multiple",      color.orange)
plot(isLeader ? 1 : 0,       "Leader",           color.green)
plot(isResisting ? 1 : 0,    "Resisting",        color.teal)
plot(retSpread,              "Ret Spread %",     color.purple)
````
