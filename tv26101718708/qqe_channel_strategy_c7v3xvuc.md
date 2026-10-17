# QQE Channel Strategy

- url: https://www.tradingview.com/script/c7V3XVUC/
- type: strategy
- pine_id: PUB;5ede6181bb8f483bbdd262f723f1c91f
- version: 1.0

## Description

─────────────────────────────────────────────
QQE Channel Strategy (QCS) — TradingView Description
─────────────────────────────────────────────

█ OVERVIEW

QQE Channel Strategy is a fully original trend-following strategy that combines two independently implemented components:

① Trend Channel — Built from High/Low EMA bands. Price breaking above the upper band signals bullish trend; breaking below the lower band signals bearish. The inner band acts as an exit line.

② Momentum Filter — A QQE-concept oscillator built from scratch. RSI is smoothed, its volatility is ATR-normalized, and trailing bands determine trend direction. Entry is only allowed when both components agree on direction.


█ ENTRY CONDITIONS

Long  : Channel flips bullish while momentum is bullish,
        OR momentum flips bullish while channel is already bullish.
Short : Same logic, opposite direction.


█ EXIT CONDITIONS

• Fixed SL / TP via strategy.exit() (enabled by default)
  — SL: lowest low (long) or highest high (short) over the last N bars
  — TP: SL distance × RR ratio
• Signal-based exit as a safety net:
  — Price crosses back through the exit line
  — Momentum flips against the position


█ DEFAULT SETTINGS

 Group               | Parameter                  | Default
 ─────────────────── | ────────────────────────── | ───────
 Trend Channel       | Channel EMA Length         | 60
 Momentum Filter     | RSI Length                 | 14
 Momentum Filter     | RSI Smoothing (EMA)        | 5
 Momentum Filter     | QQ Factor                  | 4.238
 SL / TP             | Use Fixed SL/TP            | ON
 SL / TP             | Swing Length (SL basis)    | 10
 SL / TP             | Risk/Reward Ratio          | 1.0
 Strategy            | Long / Short               | Both ON
 Strategy            | Lot Size                   | 1.0
 Commission          | (hardcoded)                | 0.05%

All parameters are adjustable from the indicator settings panel.
Commission can also be overridden via Properties tab → Commissions.


█ ALERTS

Four alert conditions are available:
• 🟢 Long Entry
• 🔴 Short Entry
• ⚠️ Exit Arrow
• 📢 All Signals (combined)


█ NOTES

— This strategy is a fully original implementation.
  No external scripts or third-party code were used.
— QQE refers to the Quantitative Qualitative Estimation algorithm concept,
  independently implemented from documented sources.
— Backtested with commission 0.05% and slippage 2 ticks.
  Adjust these in the Properties tab to match your broker's conditions.
— Results vary by symbol and timeframe. Always verify on your target pair
  before live trading.

## Source Code

````pine
//@version=6
// ============================================================
// QQE Channel Strategy  (QCS)
// Original implementation — no third-party code used
// ① Trend Channel  : Direction bias via High / Low EMA bands
// ② Momentum Filter: QQE-concept trailing band on smoothed RSI
// Entry only when both components agree on direction
// ============================================================
// Commission / Slippage can also be changed via Properties tab
strategy(
    title             = "QQE Channel Strategy",
    shorttitle        = "QCS",
    overlay           = true,
    default_qty_type  = strategy.fixed,
    default_qty_value = 1,
    commission_type   = strategy.commission.percent,
    commission_value  = 0.05,   // commission (%). Override in Properties tab
    slippage          = 2       // slippage (ticks)
)

// ================================================================
// ① Inputs
// ================================================================
var GRP_CH   = "📊 Trend Channel"
var GRP_MOM  = "📈 Momentum Filter"
var GRP_SL   = "🛡️  SL / TP"
var GRP_ST   = "⚙️  Strategy"

// Channel
chLen    = input.int  (60,    "Channel EMA Length",       minval = 1,   group = GRP_CH)

// Momentum
rsiLen   = input.int  (14,    "RSI Length",               minval = 1,   group = GRP_MOM)
rsiSmth  = input.int  (5,     "RSI Smoothing (EMA)",      minval = 1,   group = GRP_MOM)
qFactor  = input.float(4.238, "QQ Factor",                minval = 0.1,
     step = 0.001, tooltip = "Higher = fewer but more stable signals. Recommended range: 2–6", group = GRP_MOM)

// SL / TP
useSLTP  = input.bool (true,  "Use Fixed SL / TP",
     tooltip = "When OFF, exits are signal-based only (exit line cross or momentum reversal)", group = GRP_SL)
swingLen = input.int  (10,    "SL Swing Length (bars)",   minval = 1,
     tooltip = "Long: lowest low over N bars. Short: highest high over N bars", group = GRP_SL)
rrRatio  = input.float(1.0,   "Risk / Reward Ratio",      minval = 0.1, step = 0.1,
     tooltip = "TP distance = SL distance × this value. 1.0 = 1:1", group = GRP_SL)

// Strategy
useLong  = input.bool (true,  "Enable Long",  group = GRP_ST)
useShort = input.bool (true,  "Enable Short", group = GRP_ST)
lotSize  = input.float(1.0,   "Lot Size",     minval = 0.01, step = 0.01, group = GRP_ST)

// ================================================================
// ② Trend Channel (original implementation)
//    High EMA / Low EMA bands — breakout direction = trend bias
// ================================================================
chHigh = ta.ema(high, chLen)
chLow  = ta.ema(low,  chLen)

var int chDir = 0
chDir := close > chHigh ?  1
       : close < chLow  ? -1
       : nz(chDir[1])

// Exit line: inner EMA — price crossing back signals trend exhaustion
chExit = chDir >= 0 ? chLow : chHigh

chBull  = chDir ==  1
chBear  = chDir == -1

chFlipL = ta.change(chDir) != 0 and chBull
chFlipS = ta.change(chDir) != 0 and chBear

exitLong  = chBull[1] and ta.crossunder(close, chExit)
exitShort = chBear[1] and ta.crossover (close, chExit)

// ================================================================
// ③ Momentum Filter (original implementation)
//    RSI → smooth → ATR-normalize volatility → trailing bands
// ================================================================
rsiVal = ta.rsi(close, rsiLen)
rsiSm  = ta.ema(rsiVal, rsiSmth)

wilderLen = rsiLen * 2 - 1
rsiDelta  = math.abs(rsiSm - nz(rsiSm[1]))
rsiAtr1   = ta.ema(rsiDelta, wilderLen)
dar       = ta.ema(rsiAtr1, wilderLen) * qFactor

float lBand = rsiSm - dar
float sBand = rsiSm + dar

lBand := rsiSm > nz(lBand[1]) ? math.max(lBand, nz(lBand[1])) : lBand
sBand := rsiSm < nz(sBand[1]) ? math.min(sBand, nz(sBand[1])) : sBand

var int qDir = 0
qDir := ta.crossover (rsiSm, sBand[1]) ?  1
      : ta.crossunder(rsiSm, lBand[1]) ? -1
      : nz(qDir[1])

qBull = qDir ==  1
qBear = qDir == -1

// ================================================================
// ④ Entry / Exit Logic
// ================================================================
entryLong  = (chFlipL and qBull)
           or (ta.change(qDir) != 0 and qBull and chBull)

entryShort = (chFlipS and qBear)
           or (ta.change(qDir) != 0 and qBear and chBear)

exitL = exitLong  or (qBear and strategy.position_size > 0)
exitS = exitShort or (qBull and strategy.position_size < 0)

// ── Long ─────────────────────────────────────────────────────
if useLong
    if entryLong
        slPrice = ta.lowest(low, swingLen)                    // swing low over N bars
        risk    = math.max(close - slPrice, syminfo.mintick)  // SL distance (zero-div guard)
        tpPrice = close + risk * rrRatio                      // TP via RR ratio
        strategy.entry("Long", strategy.long, qty = lotSize)
        if useSLTP
            strategy.exit("Long SLTP", "Long",
                 stop           = slPrice,
                 limit          = tpPrice,
                 comment_loss   = "SL",
                 comment_profit = "TP")
    // Signal-based exit fires before SL/TP if reached first
    if exitL
        strategy.close("Long", comment = "Signal Exit")

// ── Short ────────────────────────────────────────────────────
if useShort
    if entryShort
        slPrice = ta.highest(high, swingLen)                  // swing high over N bars
        risk    = math.max(slPrice - close, syminfo.mintick)
        tpPrice = close - risk * rrRatio
        strategy.entry("Short", strategy.short, qty = lotSize)
        if useSLTP
            strategy.exit("Short SLTP", "Short",
                 stop           = slPrice,
                 limit          = tpPrice,
                 comment_loss   = "SL",
                 comment_profit = "TP")
    if exitS
        strategy.close("Short", comment = "Signal Exit")

// ================================================================
// ⑤ Visuals
// ================================================================
chColor = chBull ? color.new(#00c3ff, 0) : color.new(#ff0062, 0)

plot(chHigh, "CH High", color.new(chColor, 75), 1)
plot(chLow,  "CH Low",  color.new(chColor, 75), 1)
fill(
    plot(chHigh, display = display.none),
    plot(chLow,  display = display.none),
    color.new(chColor, 92)
)
plot(chExit, "Exit Line", chColor, 2)

plotshape(entryLong,  "BUY",  shape.triangleup,   location.belowbar,
     color.new(color.green, 0), size = size.normal, text = "BUY",  textcolor = color.white)
plotshape(entryShort, "SELL", shape.triangledown,  location.abovebar,
     color.new(color.red,   0), size = size.normal, text = "SELL", textcolor = color.white)

plotshape(exitLong,  "Exit↑", shape.xcross, location.abovebar,
     color.new(color.orange, 0), size = size.small)
plotshape(exitShort, "Exit↓", shape.xcross, location.belowbar,
     color.new(color.orange, 0), size = size.small)

barcolor(
    chBull and qBull ? color.new(#00c3ff, 65)
  : chBear and qBear ? color.new(#ff0062, 65)
  : na
)

// ================================================================
// ⑥ Alerts
// ================================================================
alertcondition(entryLong,                        "🟢 Long Entry",  "{{ticker}} {{interval}}: Long Entry")
alertcondition(entryShort,                       "🔴 Short Entry", "{{ticker}} {{interval}}: Short Entry")
alertcondition(exitLong or exitShort,            "⚠️ Exit Arrow",  "{{ticker}} {{interval}}: Exit Signal")
alertcondition(entryLong or entryShort or exitLong or exitShort,
     "📢 All Signals", "{{ticker}} {{interval}}: Signal")
````
