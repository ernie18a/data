# Manhotra Consulting TV Alert (manhotra-consulting)

- url: https://www.tradingview.com/script/b5NOVFfV-Manhotra-Consulting-TV-Alert-manhotra-consulting/
- type: indicator
- pine_id: PUB;90893b7fcec14a658bf05398cd12e636
- version: 7.0

## Description

IP owned by Manhotra Consulting. This has been created to automate trading desk.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  EMA-ADX TradingView → manhotra-consulting-tv-bot
//  Manhotra Consulting · 2026-06-05
//
//  Mirrors the Python `bot/engine/signal.py` rule verbatim so the bot and
//  TradingView agree on entries. Fires `alert()` with a JSON body the bot's
//  POST /api/tv/signal endpoint accepts directly.
//
//  HOW TO INSTALL
//  ──────────────
//   1. Open this script in the Pine editor on tradingview.com.
//   2. "Add to chart" — drop it on a NIFTY 50 chart, 5-minute timeframe
//      (`CANDLE_TIMEFRAME_MIN=5` in the bot's `.env` is the default).
//   3. Set TV_WEBHOOK_SECRET and STRATEGY_TAG in the input dialog so they
//      match the bot's `.env`.
//   4. Right-click chart → "Add alert".
//        Condition       : "Manhotra Consulting TV Alert" → "Any alert() function call"
//        Trigger          : Once Per Bar Close   (also enforced by Pine; both belt + braces)
//        Expiration       : Open-ended (re-create before TV expires it)
//        Message          : leave default — Pine's alert() call carries the JSON
//        Webhook URL      : https://webhook.manhotraconsulting.in/mcs-tv/api/tv/signal
//   5. Click Create.
//
//  HOW IT FIRES
//  ────────────
//   - On every closed 5-min bar the script runs the EMA-ADX entry rule:
//       Touch        : bar.low ≤ EMA ≤ bar.high
//       Distance gate: |close − EMA| / EMA × 100 ≥ MIN_CROSS_DIST_PCT (0.05)
//       Prev-opposite: bar(t-1) must have closed on the OPPOSITE side of EMA
//       Direction    : close > EMA → arm LONG;  close < EMA → arm SHORT
//   - On the NEXT bar, the arm TRIGGERS:
//       LONG  fires when bar.high > setup bar's high
//       SHORT fires when bar.low  < setup bar's low
//   - Arms persist across bars (same-side trailing); they're voided when the
//     underlying closes on the wrong side of EMA by ≥ the distance gate, OR
//     when the trading day rolls.
//   - Regime classifier picks BUY (ADX > 25 + EMA-of-ADX rising) or
//     SELL_HEDGED. The bot uses this to decide CE/PE direction & hedge.
//
//  WHAT'S NOT IN PINE (deliberately bot-side)
//  ──────────────────────────────────────────
//   - Strike selection (ITM / OTM offsets, hedge distance, expiry choice).
//   - Sizing (lots, freeze-qty split, notional + margin caps).
//   - Exits — % SL / target / trailing / NIFTY-pts SL/target / EMA breach /
//     EOD square-off all stay bot-managed.
//   - All guard logic — kill switch, max trades / day, daily loss cap,
//     last-entry-time, spread check, margin pre-flight.
//
//  WEBHOOK PAYLOAD CONTRACT (must stay in sync with bot/api/app.py::TVSignalIn)
//  ───────────────────────────────────────────────────────────────────────────
//   secret           string ≥ 1 char — must match TV_WEBHOOK_SECRET
//   tag              string ≥ 1 char — must match STRATEGY_TAG
//   direction        "LONG" | "SHORT"
//   regime           "SELL_HEDGED" (always — BUY regime removed 2026-07-13)
//   spot             number > 0 (closed bar's close)
//   ts               number (ms since epoch UTC, Pine `time`) OR ISO-8601
//   bar_interval     short string (Pine timeframe.period, e.g. "5")
//   idempotency_key  string ≥ 8 chars (unique per symbol+tf+bar+direction)
//
// ════════════════════════════════════════════════════════════════════════════

indicator(title="Manhotra Consulting TV Alert (manhotra-consulting)",
          shorttitle="EMA-ADX TV", overlay=true,
          max_labels_count=500)

// JSON-escape an operator-typed string (secret / tag) so a stray `"` or `\`
// can't corrupt the webhook payload. Escape `\` first, then `"`.
jsonEsc(s) => str.replace_all(str.replace_all(s, "\\", "\\\\"), "\"", "\\\"")

// ════════════════════════════════════════════════════════════════════════════
//  Inputs — mirror the bot's `.env` defaults so the signals agree
// ════════════════════════════════════════════════════════════════════════════
gpStrat = "Strategy parameters (match bot's .env)"
emaLen  = input.int(15, "EMA period (EMA_PERIOD)", minval=1, group=gpStrat)
adxLen  = input.int(14, "ADX period (ADX_PERIOD)", minval=1, group=gpStrat)
adxThr  = input.float(25, "ADX threshold (reserved — not used for regime)",
                       minval=0, group=gpStrat)
minDist = input.float(0.05, "Min cross distance % (MIN_CROSS_DISTANCE_PCT)",
                       minval=0.0, step=0.01, group=gpStrat,
                       tooltip="Default 0.05 = 5 bps (~12 pts at NIFTY 23500). " +
                               "Filters knife-edge crossovers whose close lands within " +
                               "noise distance of the EMA.")
reqPrev = input.bool(true, "Require prev bar opposite-side close",
                      group=gpStrat,
                      tooltip="2026-05-27 spec: bar(t-1) must have closed on the " +
                              "OPPOSITE side of EMA for an arm to fire. Makes the " +
                              "current bar a true crossover, not a trend continuation.")
gateOnTrigger = input.bool(true, "Gate on trigger bar (not crossover bar)",
                      group=gpStrat,
                      tooltip="When OFF (default): the distance gate is checked on " +
                              "the CROSSOVER bar — knife-edge closes never arm.\n" +
                              "When ON: any crossover arms; the TRIGGER bar's close " +
                              "must be >= minDist away from EMA to fire. Catches setups " +
                              "where the cross is tight but the breakout bar is clean. " +
                              "Backtest before enabling. Must match GATE_ON_TRIGGER=true " +
                              "in the bot's .env.")

gpWebhook = "Webhook (match bot's .env)"
tvSecret = input.string("", "TV_WEBHOOK_SECRET",
                         group=gpWebhook, confirm=true,
                         display=display.none,
                         tooltip="MUST match the bot's TV_WEBHOOK_SECRET. " +
                                 "Empty string sends an empty secret, which the bot will " +
                                 "reject with HTTP 422 — operator MUST set this before going live. " +
                                 "display=display.none hides the value from the indicator's " +
                                 "status-line / alert-title (would otherwise leak the secret " +
                                 "into alert logs, screenshots, screen shares).")
tvTag    = input.string("EMA_ADX_TV_V1", "STRATEGY_TAG",
                         group=gpWebhook, confirm=true,
                         tooltip="MUST match the bot's STRATEGY_TAG. The bot rejects " +
                                 "any payload whose tag differs from its own with HTTP 409.")

gpDisplay = "Display"
showArm  = input.bool(true, "Show arm levels on chart", group=gpDisplay)
showFire = input.bool(true, "Show trigger arrows (entry)", group=gpDisplay)
showExit = input.bool(true, "Show EMA-breach exit markers", group=gpDisplay,
                       tooltip="Chart annotation only — bot's position_manager." +
                               "on_bar_close is the source of truth for actual " +
                               "exits. Pine and bot both compute EMA(15) on the " +
                               "same 5-min closes; they should agree to within " +
                               "fractions of a point after warmup.")
showHold = input.bool(true, "Shade background while position held", group=gpDisplay)

// ════════════════════════════════════════════════════════════════════════════
//  Indicators
// ════════════════════════════════════════════════════════════════════════════
ema = ta.ema(close, emaLen)
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxEma = ta.ema(adxVal, emaLen)
adxEmaRising = not na(adxEma[1]) and adxEma > adxEma[1]

// Warmup gate — match bot's `IndicatorEngine.is_warm`. ADX needs ≥ 2× the
// ADX period to stabilise (Wilder smoothing).
isWarm = bar_index >= (adxLen * 2 + emaLen)

// ════════════════════════════════════════════════════════════════════════════
//  Persistent arm + position state
// ════════════════════════════════════════════════════════════════════════════
var float setupHigh = na
var float setupLow  = na
var int   armedDir  = 0   // +1 LONG, -1 SHORT, 0 idle
// Position state mirrors what the bot does after a trigger fires: entry on
// trigger, exit on EMA-breach close. Chart-only visualisation — bot is the
// authoritative source via position_manager.on_bar_close.
var int   inTrade   = 0   // +1 LONG open, -1 SHORT open, 0 flat

// Overnight invalidation. Python: setups don't carry across the trading-day
// boundary. Pine: detect a calendar-date change. Resets state BEFORE this
// bar's trigger check so a setup armed yesterday cannot trigger today.
// Position state also resets — bot's INTRADAY_SQUARE_OFF_TIME at 15:15 IST
// guarantees no overnight holds in reality.
newDay = not na(time[1]) and (dayofmonth != dayofmonth[1] or
                              month != month[1] or
                              year != year[1])
if newDay
    armedDir  := 0
    setupHigh := na
    setupLow  := na
    inTrade   := 0

// ────────── Step 3 — Trigger check (prior arm + this bar's range) ──────────
// `armedDir` / `setupHigh` / `setupLow` at the TOP of this bar's run hold the
// values set during the PREVIOUS bar's run, because they're `var` (persistent).
// That matches Python's `prev_long = self._armed_long` snapshot.
//
// gateOnTrigger=true: also require trigger bar's close to be on the correct
// side of EMA with >= minDist clearance (mirrors Python _trigger_gate_ok).
triggerBreachPct = ema > 0 ? math.abs(close - ema) / ema * 100.0 : 0.0
triggerGateOk = not gateOnTrigger or (
    triggerBreachPct >= minDist and
    (armedDir == 1 ? close > ema : close < ema))
triggerLong  = isWarm and armedDir == 1  and not na(setupHigh) and high > setupHigh and triggerGateOk
triggerShort = isWarm and armedDir == -1 and not na(setupLow)  and low  < setupLow  and triggerGateOk
firedDir     = triggerLong ? 1 : triggerShort ? -1 : 0
if firedDir != 0
    armedDir  := 0
    setupHigh := na
    setupLow  := na
    // ENTRY: open position. Note: if we were somehow still flagged in_trade
    // (e.g. the previous bar's exit didn't reset inTrade — defensive), the
    // new entry simply overwrites. Symmetric with the bot's behaviour: each
    // approved TV signal creates a new Trade row.
    inTrade   := firedDir

// ────────── Step 4 — EMA-breach VOID ──────────
// Python: an arm is voided only when the bar closes on the wrong side AND
// the breach distance ≥ the same gate used for fresh arms. Knife-edge
// wrong-side closes (under the gate) keep the arm alive — the 2026-05-21
// 10:40 case the comment in signal.py:209-213 documents.
breachPct = ema > 0 ? math.abs(close - ema) / ema * 100.0 : 0.0
if firedDir == 0 and armedDir == 1 and close < ema and breachPct >= minDist
    armedDir  := 0
    setupHigh := na
if firedDir == 0 and armedDir == -1 and close > ema and breachPct >= minDist
    armedDir  := 0
    setupLow  := na

// ────────── Step 4b — EMA-breach EXIT (position close) ──────────
// Mirrors bot/engine/position_manager.py::on_bar_close — same EMA, same
// distance gate. When the bar closes on the wrong side of EMA by ≥ minDist,
// the open position is squared off.
//
// Operator spec 2026-06-08:
//   LONG exit  → bar.close < EMA(15) by ≥ MIN_CROSS_DISTANCE_PCT
//   SHORT exit → bar.close > EMA(15) by ≥ MIN_CROSS_DISTANCE_PCT
//
// inTrade is RESET here so a follow-on opposite-side trigger on the next
// bar(s) is captured cleanly without a stale position flag.
exitLong  = inTrade ==  1 and close < ema and breachPct >= minDist
exitShort = inTrade == -1 and close > ema and breachPct >= minDist
if exitLong or exitShort
    inTrade := 0

// ────────── Step 5 — Same-side trailing ──────────
// Python: if a prior arm survived AND this bar closed on the same side,
// refresh the setup level to THIS bar. The v0.2.5 fix that makes the
// 10:50 SHORT fire off the 10:45 setup low, not the stale 10:35 low.
if firedDir == 0 and armedDir == 1 and close > ema
    setupHigh := high
if firedDir == 0 and armedDir == -1 and close < ema
    setupLow  := low

// ────────── Step 6 — Fresh-crossover check ──────────
// The full gate from `_is_crossover`:
//   touch + distance + close ≠ EMA + (optional) prev-opposite-close.
touched   = low <= ema and ema <= high
distOk    = ema > 0 ? (math.abs(close - ema) / ema * 100.0) >= minDist : false
// gateOnTrigger=true: skip the distance gate at ARM time — any crossover arms.
// The gate will be checked on the trigger bar instead (step 3 above).
armGateOk = not gateOnTrigger ? distOk : true
notFlat   = close != ema
// `prevValid` mirrors `signal.py:188-192` — on a session boundary, the
// Python side nulls `prev_close`/`prev_ema` so the first morning bar can
// NOT satisfy the t-1-opposite-close condition against yesterday's
// 15:25 close. Without `not newDay` here, Pine would compare today's
// 09:15 close to yesterday's 15:25 close and arm on a false crossover.
prevValid = not na(close[1]) and not na(ema[1]) and not newDay
prevBelow = prevValid and close[1] < ema[1]
prevAbove = prevValid and close[1] > ema[1]
freshLong  = isWarm and touched and armGateOk and notFlat and close > ema and
             (not reqPrev or prevBelow)
freshShort = isWarm and touched and armGateOk and notFlat and close < ema and
             (not reqPrev or prevAbove)
if firedDir == 0 and freshLong
    armedDir  := 1
    setupHigh := high
    setupLow  := na
if firedDir == 0 and freshShort
    armedDir  := -1
    setupLow  := low
    setupHigh := na

// ════════════════════════════════════════════════════════════════════════════
//  Regime + direction string
// ════════════════════════════════════════════════════════════════════════════
// Always SELL_HEDGED: selling options (with hedge) survives retracements
// far better than outright BUY at the 10-pt SL threshold. The bot's own
// MIN_ADX_SELL_HEDGED floor (default 18) still blocks signals in truly
// ranging markets without needing a BUY fallback here.
// adxThr input is preserved for potential future use as an entry ADX gate.
regime = "SELL_HEDGED"
direction = firedDir == 1 ? "LONG" : firedDir == -1 ? "SHORT" : ""

// ════════════════════════════════════════════════════════════════════════════
//  Visualisation
// ════════════════════════════════════════════════════════════════════════════
plot(ema, "EMA", color=color.new(color.orange, 0), linewidth=2)

// Show the live arm level so the operator can sanity-check the indicator.
plot(showArm and armedDir == 1  ? setupHigh : na, "Setup HIGH (LONG arm)",
     color=color.new(color.lime, 30), style=plot.style_linebr, linewidth=2)
plot(showArm and armedDir == -1 ? setupLow  : na, "Setup LOW (SHORT arm)",
     color=color.new(color.red,  30), style=plot.style_linebr, linewidth=2)

// ENTRY markers — fired on t+1 when prior arm's setup high/low is taken out.
// Green ▲ below the bar = LONG entry; red ▼ above the bar = SHORT entry.
// Text "LONG" / "SHORT" makes the direction unambiguous on screenshots.
plotshape(showFire and triggerLong, "LONG entry",
          shape.triangleup, location.belowbar,
          color=color.new(color.lime, 0), size=size.small, text="LONG")
plotshape(showFire and triggerShort, "SHORT entry",
          shape.triangledown, location.abovebar,
          color=color.new(color.red, 0), size=size.small, text="SHORT")

// EXIT markers — fired when an open position's bar closes wrong-side of EMA
// by ≥ minDist. Orange X cross sits OPPOSITE the entry triangle so the open
// and close visually bracket the trade. Text "EXIT" with a hint of which
// side closed it (close vs EMA was the trigger).
plotshape(showExit and exitLong, "LONG exit",
          shape.xcross, location.abovebar,
          color=color.new(color.orange, 0), size=size.small, text="EXIT")
plotshape(showExit and exitShort, "SHORT exit",
          shape.xcross, location.belowbar,
          color=color.new(color.orange, 0), size=size.small, text="EXIT")

// Hold-period shading — subtle background tint while a position is open.
// Green for LONG, red for SHORT, transparent (alpha 92) so candles stay
// readable. Toggles via the "Shade background while position held" input.
bgcolor(showHold and inTrade ==  1 ? color.new(color.lime, 92) : na,
        title="LONG held")
bgcolor(showHold and inTrade == -1 ? color.new(color.red,  92) : na,
        title="SHORT held")

// ════════════════════════════════════════════════════════════════════════════
//  Webhook payload — JSON body sent on every trigger fire
// ════════════════════════════════════════════════════════════════════════════
// Pine has no native JSON builder. We concatenate carefully and pass numbers
// through `str.tostring()`. Numeric fields (spot, ts) are unquoted so the
// bot's pydantic schema receives float / int (NOT string-of-number).
//
// `ts` = bar CLOSE time (`time_close`), ms since epoch UTC. Close time is ≈"now"
// when TV fires + posts, so `now − ts` ≈ network latency on EVERY timeframe —
// the alert never trips the bot's STALE freshness check even if this script is
// accidentally dropped on a chart other than 5-min. (`_parse_alert_ts` parses
// the all-digit string as ms epoch; a smaller age only ever HELPS the window.)
//
// `idempotency_key`: unique per (symbol, timeframe, bar CLOSE time, direction).
// Length ≥ 8 chars required by the bot's schema; trivially satisfied.
idempKey = syminfo.ticker + "-" + timeframe.period + "-" +
           str.tostring(time_close) + "-" + direction

// 2026-06-08: include minDist so the bot's EMA-breach exit uses the SAME
// gate value that armed this trade's entry. Unquoted number → pydantic
// receives a float. Bot stores it on Trade.min_cross_distance_override and
// consults it in position_manager.on_bar_close instead of .env's default.
msgJson = "{" +
  "\"secret\":\""                  + jsonEsc(tvSecret) + "\"," +
  "\"tag\":\""                     + jsonEsc(tvTag)    + "\"," +
  "\"direction\":\""               + direction   + "\"," +
  "\"regime\":\""                  + regime      + "\"," +
  "\"spot\":"                      + str.tostring(close, format.mintick) + "," +
  "\"ts\":"                        + str.tostring(time_close) + "," +
  "\"bar_interval\":\""            + timeframe.period + "\"," +
  "\"min_cross_distance_pct\":"    + str.tostring(minDist)  + "," +
  "\"idempotency_key\":\""         + idempKey   + "\"" +
  "}"

// Fire INTRABAR — the moment price breaks the setup level (2026-07-30).
// `alert.freq_once_per_bar` fires on the first tick `firedDir != 0` within the
// bar, i.e. the instant `high > setupHigh` (LONG) / `low < setupLow` (SHORT),
// instead of waiting up to ~5 min for the bar to close. This is repaint-SAFE:
// Pine rolls back `var` mutations on the forming bar each tick, so Step 3 reads
// `armedDir` / `setupHigh` / `setupLow` from the PRIOR confirmed bar — the break
// is of a fixed, already-confirmed level (monotonic within the bar, never
// un-fires). The ARM (Step 6) still commits only at bar close, so a same-bar
// arm-then-fire cannot happen. `ts = time_close` stays in the FUTURE for an
// intrabar fire → the bot sees a negative age → never STALE; `idempotency_key`
// uses `time_close` (stable per bar) so multi-tick fires collapse to one signal.
if firedDir != 0
    alert(msgJson, alert.freq_once_per_bar)
````
