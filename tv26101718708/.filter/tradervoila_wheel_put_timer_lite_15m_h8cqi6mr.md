# TraderVoila - Wheel Put Timer LITE - 15m

- url: https://www.tradingview.com/script/h8cQi6mr-TraderVoila-Wheel-Put-Timer-LITE-15m/
- type: indicator
- pine_id: PUB;ddfa36483fae4690afaf5fdd4afe01af
- version: 1.0

## Description

[b]TraderVoila — Wheel Put Timer LITE [15m][/b]
Times intraday entries and exits for selling cash-secured puts with the Wheel strategy.

[b]What it does[/b]
Selling puts works best when you sell into weakness (premium is inflated) and close into strength (premium has decayed). This indicator marks both moments on a 15-minute chart:
[b]SELL PUT[/b] — the stock has dipped meaningfully below VWAP, RSI has dipped and is now turning back up, and the stock remains above its daily 50 SMA. A dip in a healthy uptrend, not a falling knife.
[b]BUY CLOSE[/b] — the stock has recovered above VWAP with RSI pushing into strength. The premium you collected has likely decayed — consider closing early to free up capital for the next trade.

[b]How it works[/b]
RSI(14) must dip below your threshold (default 38) and curl back upward — catching the turn, not the fall
Price must be stretched at least 0.4% below VWAP for the dip to matter
Daily trend filter: price must be above the daily 50 SMA, calculated from the daily timeframe regardless of your chart. Orange shading shows when this filter is blocking signals
The first 30 minutes of the session are skipped (red shading) — spreads are wide and fills are poor at the open
A cooldown prevents signal spam; all parameters are adjustable

[b]How to use it[/b]
Apply to a 15m chart of a liquid, optionable stock you'd be comfortable owning
When SELL PUT fires, check your broker's option chain for a put at your preferred delta and expiration
When BUY CLOSE fires on a position you're short, evaluate closing early vs. holding to expiration
Set alerts on both conditions to monitor your watchlist hands-free

[b]Honest limitations[/b]
TradingView cannot see options prices, IV, or Greeks. This tool times the underlying — put premium closely follows the stock's intraday dips and recoveries, so the underlying is a reliable proxy, but always verify the actual contract, premium, and liquidity on your broker before trading. This is a timing aid, not financial advice.
Built by TraderVoila for Wheel strategy traders.

## Source Code

````pine
//@version=6
// ============================================================
// TraderVoila — Wheel Put Timer LITE (15m)
// ============================================================
// A free tool for Wheel strategy traders: finds intraday
// moments when selling cash-secured puts makes sense
// (the stock dips = put premium inflates) and when buying
// them back makes sense (the stock recovers = premium decays).
//
// HOW TO USE:
//   1. Set your chart to 15m on an optionable stock
//   2. SELL PUT label  = intraday dip in a healthy uptrend —
//      check your broker for a put at your preferred delta
//   3. BUY CLOSE label = recovery — premium has likely
//      decayed, consider closing early to free capital
//
// SIGNAL LOGIC:
//   Sell:  RSI dips below threshold then turns up, price is
//          stretched below VWAP, stock is above its daily
//          50 SMA (no falling knives), opening chaos skipped
//   Close: RSI pushes into strength and price reclaims VWAP
//
// NOTE: TradingView can't see options prices or IV — this
// times the underlying. Premium follows the dip. Always
// verify the actual contract on your broker first.
//
// This is the free LITE version. The full TraderVoila Put
// Timer adds 0-100 setup scoring, A/B/C signal tiers,
// per-day signal caps, smart cooldowns, and a live setup-
// score dashboard. Find us at TraderVoila for more Wheel
// strategy tools: trade trackers, a candidate scanner, and
// strategy guides.
// ============================================================

indicator("TraderVoila — Wheel Put Timer LITE [15m]", overlay=true)

// ---------------- Inputs ----------------
rsiLen      = input.int(14, "RSI Length", minval=2)
rsiOversold = input.int(38, "RSI Dip Level", minval=10, maxval=50, tooltip="RSI must dip below this then turn up")
rsiStrong   = input.int(65, "RSI Recovery Level", minval=50, maxval=90, tooltip="Buy-to-close fires at this strength")
vwapDevPct  = input.float(0.4, "Min % Below VWAP", minval=0.0, step=0.1)
dailySmaLen = input.int(50, "Daily SMA (trend filter)", minval=5)
skipOpenMins= input.int(30, "Skip First N Minutes", minval=0, maxval=120)
cooldown    = input.int(12, "Bars Between Signals", minval=0, maxval=50)

// ---------------- Series ----------------
rsi  = ta.rsi(close, rsiLen)
vwap = ta.vwap(hlc3)
dailySma = request.security(syminfo.tickerid, "D", ta.sma(close, dailySmaLen), lookahead=barmerge.lookahead_off)
vwapDist = (close - vwap) / vwap * 100

sessMinutes = (hour - 9) * 60 + (minute - 30)
inOpen = session.ismarket and sessMinutes >= 0 and sessMinutes < skipOpenMins

// ---------------- Signals ----------------
trendOk   = close > dailySma
dipOk     = ta.lowest(rsi, 4) < rsiOversold and rsi > rsi[1]
stretchOk = vwapDist <= -vwapDevPct

var int lastSell = -9999
rawSell = dipOk and stretchOk and trendOk and not inOpen and session.ismarket
sellSig = rawSell and (bar_index - lastSell) > cooldown
if sellSig
    lastSell := bar_index

var int lastClose = -9999
rawClose = rsi >= rsiStrong and close > vwap and not inOpen and session.ismarket
closeSig = rawClose and (bar_index - lastClose) > cooldown
if closeSig
    lastClose := bar_index

// ---------------- Plots ----------------
plot(vwap, "VWAP", color=color.new(#4da6ff, 0), linewidth=2)
plot(dailySma, "Daily 50 SMA", color=color.new(#ffd166, 30), linewidth=2)

plotshape(sellSig, "Sell Put", style=shape.labelup, location=location.belowbar,
     color=color.new(#00c896, 0), textcolor=color.white, text="SELL\nPUT", size=size.small)
plotshape(closeSig, "Buy to Close", style=shape.labeldown, location=location.abovebar,
     color=color.new(#b48eff, 0), textcolor=color.white, text="BUY\nCLOSE", size=size.small)

bgcolor(inOpen ? color.new(#ff5f5f, 93) : na)
bgcolor(not trendOk and session.ismarket ? color.new(#ffa726, 95) : na)

// ---------------- Alerts ----------------
alertcondition(sellSig,  "Sell Put Opportunity", "TraderVoila Lite: {{ticker}} dipped in an uptrend — check put premiums on your broker.")
alertcondition(closeSig, "Buy-to-Close Opportunity", "TraderVoila Lite: {{ticker}} recovered — consider closing your short put.")
````
