<!-- tradingview-pine-id: PUB;639b2cd562ea4e1494251f1b96400d13 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# AlphaVault - Iron Turtle 1D v2.00

Source: https://www.tradingview.com/script/jVO15KW9-AlphaVault-Iron-Turtle-1D-v2-00/

## Description

Iron Turtle — scheduled spot accumulation, bear regimes only
BTC/USDT · Daily chart only · spot · buy-only, never sells

WHAT IT DOES

The Iron Turtle buys a fixed amount of BTC on a fixed schedule, but only while a
long-term downtrend is confirmed. When the downtrend ends it stops buying and tells you
so. It never sells, never uses leverage, and never tries to time a bottom.

It is not a trading strategy and does not pretend to be one. It is a rule that decides
when a recurring purchase should be switched on and off.

HOW IT WORKS

Two things, and that is the whole system.

1. THE REGIME TEST. On each daily close the script compares price against a 200-period
   simple moving average of daily closes and a 20-period exponential moving average of
   weekly closes, both taken from the last COMPLETED bar. Price below BOTH means the
   bear regime is confirmed. Anything else means it is not.

2. THE SCHEDULE. While the bear regime is confirmed, the script marks a buy every N
   days — 7 by default — for a fixed cash amount you set. It plots each one on the
   chart and can fire an alert so you place the order yourself, or route it to a bot.

When price closes back above both filters for a set number of confirming days, the
script stops marking buys and fires a hand-off alert. That is the end of its job. What
you do with the accumulated position is entirely your decision; the script has no
opinion and no sell logic.

The regime test is deliberately the same one our other scripts use to stay OUT of the
market. Here it runs in reverse: what makes a timing strategy go flat is what makes
this one buy.

WHY IT IS OPEN SOURCE

Because there is nothing in it worth hiding, and pretending otherwise would be
dishonest. There are no optimised parameters — the moving average lengths are the
conventional ones, the schedule is a plain interval, and every rule was fixed before
any testing. You are reading the entire method above, and the code says the same thing.
A closed-source version of this would be asking you to trust a black box that has no
box.

HOW TO USE IT

- Set the chart to BTC/USDT on the Daily timeframe. The script blocks signals on any
  other timeframe and shows a warning.
- Set your tranche size — the fixed cash amount per purchase.
- Set the interval in days.
- Right-click a buy marker to create an alert, or use the built-in alert for a bot.
- Add a second alert on the hand-off signal. That is the one that matters most and it
  may be months away.

THE ONE THING THAT DECIDES WHETHER THIS WORKS FOR YOU

Budget for the whole bear before you start. A crypto bear market can run two years.
If you intend to buy weekly, size the tranche so you could keep buying for that long
without stopping — roughly tranche × 100 committed in total. Running out of money
halfway through is the single most common way scheduled accumulation fails, and it
converts a working plan into a realised loss at the worst possible moment.

LIMITATIONS AND SHORTCOMINGS — PLEASE READ

- It will be underwater for most of the time it is running. It buys into falling
  prices by design, so an unrealised loss during accumulation is arithmetic, not
  malfunction. If watching that for months is not something you can sit through,
  this is the wrong tool and it is better to know now.
- No performance figures are shown here, and that is not modesty. An indicator
  produces no strategy report on TradingView, so any number quoted would be
  unverifiable. The rules are fully described above; test them yourself.
- It assumes bear markets eventually end. Every crypto bear so far has resolved into
  a bull, but that is history, not a law, and nothing here guarantees it repeats.
- It never sells, so it gives you a position and no exit plan. That is deliberate,
  and it means the hard decision is still yours.
- It does nothing at all in a bull market. Most of the time, the correct behaviour of
  this script is to sit still.
- It cannot time a bottom and does not try. It will keep buying while price falls
  further, and will stop buying only after the trend has already turned.

NO REPAINTING

The regime state and every buy marker use completed daily and weekly bars only,
requested without lookahead. A marker that appears on a closed bar will not move or
disappear afterwards.

---

## Source Code

````pine
//@version=6
// v2.00 (2026-08-25): republished PUBLIC + OPEN SOURCE after the invite-only
// listing was hidden by moderators. Two reasons, both ours:
//   1. The description carried historical performance figures that NOTHING on
//      TradingView could substantiate.
//      This is an indicator, and an indicator generates no strategy report, so
//      no performance claim attached to it can ever be checked by a reader.
//      Every such figure is now gone from both the code and the description.
//   2. There was no defensible answer to "why is the source hidden". The rules
//      are fixed a priori, nothing is optimised, the mechanism was already
//      fully described, and the script is free. TradingView's own guidance is
//      to publish open-source when the closed-source case cannot be made.
// Open source also removes the access bottleneck entirely: nobody has to be
// granted an invite, so nobody can be blocked from getting it.
// NO LINKS OR DOMAIN ANYWHERE. The Author's Instructions exemption applies only
// to invite-only publications; an open-source script may carry none at all.
// Logic is untouched from v1.01.
//
// v1.01 (2026-07-28): DISPLAY-ONLY release. The Iron Turtle became AlphaVault's
// free tier, and TradingView requires a source change to update a published
// script's listing. Everything that decides anything is identical to v1.00:
// the regime test, the buy schedule, the tranche maths, both alert payloads
// and the timeframe guard are untouched, so signals and the published
// characterization still hold exactly.
//   Added : "Bear duration" dashboard row (informational — tells you how deep
//           into the current bear you are, which is what the "budget ~ tranche
//           x 100" sizing rule needs).
//   Added : tooltips on the daily-SMA and hand-off-confirmation inputs.
//   Note  : bearDays is computed for DISPLAY ONLY and is never read by canBuy,
//           doBuy, the regime test or either alert. Do not wire it in.
//
// v1.00 (2026-07-19): Iron Turtle — PUBLISHED as an invite-only INDICATOR.
// TV blocks publishing strategies with zero closed trades, and the Turtle
// never sells by design. This indicator version carries the identical rules,
// alerts and dashboard; the internal strategy version (alphavault-turtle-1d-
// v1.00.pine) remains for backtest verification (matches engine 208~209 buys).
indicator("AlphaVault - Iron Turtle 1D v2.00", overlay=true, max_labels_count=500)

// =====================================================================
// AlphaVault — Iron Turtle 1D v1.00 — Bear-Market Accumulator
// BTC/USD(T) · Daily chart · SPOT · BUY-ONLY
//
// Buys a fixed spot tranche on a fixed schedule ONLY while the bear
// regime is confirmed (close below BOTH the 200-day SMA and the 20-week
// EMA, completed bars), stops when the bull returns, never sells on its
// own. All rules fixed a priori — nothing fitted, nothing optimized.
//
// This is a COST-BASIS machine, not a return strategy: it WILL be
// underwater during every bear — that is the design, and the deeper the
// bear the more it buys. Judge it by average cost when the bear ends,
// never by mid-bear P&L.
//
// NO PERFORMANCE FIGURES IN THIS FILE. An indicator produces no strategy
// report, so nothing here could substantiate one. Anyone wanting numbers
// can read the rules below and run them.
// =====================================================================

// ─── INPUTS ──────────────────────────────────────────────────────────

mode = input.string("Auto (accumulate)", "Mode", group="Direction",
     options=["Auto (accumulate)", "Paused"],
     tooltip="Auto: signal a tranche buy on schedule while the bear regime is confirmed. Paused: no signals.")

trancheUSD = input.float(100, "Tranche size (USD)", group="Accumulation", minval=10, step=10,
     tooltip="Fixed cash amount per tranche. Size it so you can fund a 2-year bear: budget ≈ tranche x 100.")
buyEveryN  = input.int(7, "Buy every N days", group="Accumulation", minval=1,
     tooltip="One tranche per N days while the bear regime holds. 7 = weekly (the characterized default).")

smaDLen = input.int(200, "Daily SMA length",  group="Regime", minval=50,
     tooltip="The slower of the two regime filters. 200 is the characterized default — it was fixed in advance, not tuned, so changing it invalidates the published 2018-2026 figures.")
emaWLen = input.int(20,  "Weekly EMA length", group="Regime", minval=5,
     tooltip="BEAR = price below BOTH filters, from the last COMPLETED daily/weekly bar (no repainting).")
confirmBars = input.int(2, "Bull hand-off confirmation (daily closes)", group="Regime", minval=1,
     tooltip="How many consecutive daily closes above BOTH filters before the bull hand-off alert fires. Higher = fewer false hand-offs, later notice. Affects only the informational alert; it never triggers a sell, because the Turtle never sells.")

showDash = input.bool(true, "Dashboard",   group="Display")
showBg   = input.bool(true, "Regime tint", group="Display")

whSym = input.string("BTCUSDT", "Webhook symbol", group="Webhook / Bot",
     tooltip="Symbol string sent in the alert JSON to your trading bot for spot tranche buys.")

// ─── TIMEFRAME GUARD ─────────────────────────────────────────────────

tfOk = timeframe.period == "D" or timeframe.period == "1D"

if not tfOk and barstate.islast
    var table warn = table.new(position.middle_center, 1, 1)
    table.cell(warn, 0, 0,
         "⚠ WRONG TIMEFRAME — set chart to 1D ⚠\n" +
         "Iron Turtle accumulates on the daily chart only.",
         text_color=color.white, bgcolor=color.new(color.red, 10),
         text_size=size.large)

// ─── REGIME (confirmed bars only — no repainting) ────────────────────

smaD = ta.sma(close, smaDLen)[1]
emaW = request.security(syminfo.tickerid, "W", ta.ema(close, emaWLen)[1],
     lookahead=barmerge.lookahead_off)

ready   = not na(smaD) and not na(emaW)
bearReg = ready and close < smaD and close < emaW
bullReg = ready and close > smaD and close > emaW

bullConfirmed = ta.barssince(not bullReg) >= confirmBars

// ─── ACCUMULATION (simulated stack for the dashboard) ────────────────

var int   lastBuyBar = na
var float stackQty   = 0.0
var float investedUSD = 0.0
var int   buysCount  = 0

canBuy = tfOk and mode == "Auto (accumulate)" and bearReg and
     (na(lastBuyBar) or bar_index - lastBuyBar >= buyEveryN)

// mutate simulated stack only on confirmed bars (no intrabar repaint)
doBuy = canBuy and (barstate.isconfirmed or barstate.ishistory)
if doBuy
    stackQty    += trancheUSD / close
    investedUSD += trancheUSD
    buysCount   += 1
    lastBuyBar  := bar_index
    alert("{\"action\":\"buy\",\"symbol\":\"" + whSym + "\",\"leverage\":1,\"tranche\":" + str.tostring(trancheUSD) + "}", alert.freq_once_per_bar_close)

// bull hand-off: informational only — the Turtle never sells your stack
var bool handoffSent = false
if bullConfirmed and not handoffSent and stackQty > 0
    alert("{\"action\":\"info\",\"signal\":\"BULL_HANDOFF\",\"symbol\":\"" + whSym + "\"}", alert.freq_once_per_bar_close)
    handoffSent := true
if bearReg
    handoffSent := false

avgCost   = stackQty > 0 ? investedUSD / stackQty : na
stackVal  = stackQty * close
stackPnl  = stackQty > 0 ? (stackVal / investedUSD - 1) * 100 : na

// ─── BEAR DURATION (v1.01 — DISPLAY ONLY) ────────────────────────────
// How long the current bear regime has run, so you can see where you are
// against the "budget ~ tranche x 100" sizing rule. Called unconditionally
// so the series stays correct on every bar. NEVER read by canBuy, doBuy,
// the regime test or either alert — keep it that way.
barsSinceNotBear = ta.barssince(not bearReg)
bearDays = bearReg and not na(barsSinceNotBear) ? barsSinceNotBear + 1 : na

// ─── PLOTS ───────────────────────────────────────────────────────────

plot(smaD, "200D SMA", color=color.new(color.orange, 30), linewidth=2)
plot(emaW, "20W EMA",  color=color.new(color.aqua,   30), linewidth=2)

bgcolor(showBg ? (bearReg ? color.new(color.teal, 92) :
     bullReg ? color.new(color.green, 96) : na) : na)

plotshape(doBuy, "Tranche buy", shape.triangleup,
     location.belowbar, color.new(color.teal, 0), size=size.small,
     text="BUY", textcolor=color.new(color.teal, 20))

// ─── DASHBOARD ───────────────────────────────────────────────────────

if showDash and barstate.islast
    table dash = table.new(position.top_right, 2, 10,
         bgcolor=color.new(color.black, 15), border_width=1,
         border_color=color.new(color.gray, 50))
    cG = color.new(color.lime, 0)
    cR = color.new(color.red, 0)
    cT = color.new(color.teal, 0)
    cGr = color.new(color.gray, 0)
    cW = color.new(color.white, 0)
    cH = color.new(color.teal, 30)

    table.cell(dash, 0, 0, "IRON TURTLE 1D v2.00", text_color=cW, bgcolor=cH)
    table.cell(dash, 1, 0, "BTC · SPOT · BUY-ONLY", text_color=cW, bgcolor=cH)

    regTxt = bearReg ? "BEAR — accumulating" : bullReg ? "BULL — resting" : "NEUTRAL — resting"
    table.cell(dash, 0, 1, "Regime", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 1, regTxt, text_color=bearReg ? cT : bullReg ? cG : cGr, text_size=size.small)

    table.cell(dash, 0, 2, "Tranche", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 2, "$" + str.tostring(trancheUSD, "#") + " every " + str.tostring(buyEveryN) + "d",
         text_color=cW, text_size=size.small)

    nextTxt = bearReg ? (na(lastBuyBar) ? "next close" :
         str.tostring(math.max(0, buyEveryN - (bar_index - lastBuyBar))) + " days") : "—"
    table.cell(dash, 0, 3, "Next buy", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 3, nextTxt, text_color=cT, text_size=size.small)

    table.cell(dash, 0, 4, "Buys (backtest)", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(buysCount) + "  ($" + str.tostring(investedUSD, "#,###") + ")",
         text_color=cW, text_size=size.small)

    table.cell(dash, 0, 5, "Stack", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(stackQty, "#.####") + " BTC", text_color=cW, text_size=size.small)

    table.cell(dash, 0, 6, "Avg cost", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 6, stackQty > 0 ? "$" + str.tostring(avgCost, "#,###") : "—",
         text_color=cW, text_size=size.small)

    table.cell(dash, 0, 7, "Stack value / P&L", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 7, stackQty > 0 ? "$" + str.tostring(stackVal, "#,###") + "  " +
         str.tostring(stackPnl, "+#.0") + "%" : "—",
         text_color=stackPnl >= 0 ? cG : cR, text_size=size.small)

    table.cell(dash, 0, 8, "Sells", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 8, "never automatic — the stack is yours", text_color=cGr, text_size=size.small)

    // v1.01 — informational only. Bears have run ~1-2 years historically, so
    // this is the number to check your remaining budget against.
    table.cell(dash, 0, 9, "Bear duration", text_color=cW, text_size=size.small)
    table.cell(dash, 1, 9, na(bearDays) ? "—" : str.tostring(bearDays, "#,###") + " days",
         text_color=bearReg ? cT : cGr, text_size=size.small)
````
