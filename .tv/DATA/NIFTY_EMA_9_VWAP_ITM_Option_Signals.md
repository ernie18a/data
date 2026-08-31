<!-- tradingview-pine-id: PUB;c62c7dcf94934d4abeca172a894b4bd9 -->
<!-- tradingviewscripts-format: 1 -->
# NIFTY EMA 9 + VWAP | ITM Option Signals

Source: https://www.tradingview.com/script/rBNnn5TH-NIFTY-EMA-9-VWAP-ITM-Option-Signals/

## Description

# NIFTY 9 EMA & VWAP | ITM Option Signals

This indicator is designed for **NIFTY options trading** using the relationship between the **9 EMA and VWAP** on the NIFTY underlying chart.

The indicator generates **BUY and EXIT signals** based on EMA/VWAP crossovers and an optional premium-based profit target.

## Strategy Logic

### 🟢 Bullish Signal — BUY CE

When the **9 EMA crosses above VWAP**:

* Exit any existing PE position.
* Generate a **BUY CE** signal.
* The CE strike is selected as **1 strike ITM from ATM**.
* The actual option premium at entry is recorded.
* An **8% premium profit target** is calculated from the entry premium.

Example:

```text
NIFTY = 24,379
ATM   = 24,400

1 ITM CE = 24,350 CE
```

If the 24,350 CE premium is ₹100 at entry:

```text
Entry Premium = ₹100
Target        = ₹108
```

When the option premium reaches the target, an **EXIT CE** signal is generated.

---

### 🔴 Bearish Signal — BUY PE

When the **9 EMA crosses below VWAP**:

* Exit any existing CE position.
* Generate a **BUY PE** signal.
* The PE strike is selected as **1 strike ITM from ATM**.
* The actual option premium at entry is recorded.
* An **8% premium profit target** is calculated from the entry premium.

Example:

```text
NIFTY = 24,379
ATM   = 24,400

1 ITM PE = 24,450 PE
```

If the 24,450 PE premium is ₹120 at entry:

```text
Entry Premium = ₹120
Target        = ₹129.60
```

When the option premium reaches the target, an **EXIT PE** signal is generated.

---

## Exit Conditions

There are two primary exit conditions:

### 1. Premium Target Exit

After entering an option, the indicator records the actual entry premium.

The default target is:

**Entry Premium + 8%**

For example:

```text
CE Entry = ₹150
Target   = ₹162
```

When the option premium reaches ₹162, the position is exited.

The premium target can be adjusted through the indicator settings.

### 2. EMA/VWAP Reversal Exit

If a position is already open and the opposite EMA/VWAP crossover occurs:

```text
CE Position
    ↓
9 EMA crosses BELOW VWAP
    ↓
EXIT CE
    ↓
BUY PE
```

And:

```text
PE Position
    ↓
9 EMA crosses ABOVE VWAP
    ↓
EXIT PE
    ↓
BUY CE
```

This allows the indicator to maintain **one directional option position at a time**.

---

## Strike Selection

The indicator uses the NIFTY spot price to determine the nearest ATM strike.

For a 50-point NIFTY strike interval:

```text
ATM = Nearest 50-point strike

1 ITM CE = ATM - 50
1 ITM PE = ATM + 50
```

Example:

```text
NIFTY = 24,379

ATM      = 24,400
ITM CE   = 24,350
ITM PE   = 24,450
```

The live ATM, 1-ITM CE and 1-ITM PE strikes are displayed on the chart.

---

## Chart Signals

The indicator displays:

🟢 **BUY CE** — 9 EMA crosses above VWAP

🔴 **BUY PE** — 9 EMA crosses below VWAP

🟠 **EXIT CE** — CE position closed

🟠 **EXIT PE** — PE position closed

🔵 **8% TARGET** — option premium reached the configured profit target

Entry and exit labels display relevant information such as:

* Option type
* Strike price
* Entry premium
* Exit premium
* Target premium
* Exit reason

---

## Alerts

The indicator provides two unified alert conditions:

### BUY Alert

A single BUY alert is used for both:

* BUY CE
* BUY PE

### EXIT Alert

A single EXIT alert is used for both:

* EXIT CE
* EXIT PE

This makes the indicator suitable for connecting TradingView alerts to an external execution/notification system.

---

## Important Information

This indicator is intended as a **technical signal-generation tool** and should not be considered investment advice or a recommendation to buy or sell any security.

Option premiums can change rapidly due to:

* Underlying price movement
* Implied volatility
* Time decay
* Liquidity
* Bid/ask spread
* Changes in market conditions

The 8% target is calculated on the **option premium**, not on the NIFTY index.

Users should independently verify the option contract, strike, expiry, liquidity and available premium before executing any trade.

**Past performance does not guarantee future results.**

---

## Source Code

````pine
//@version=6
indicator("NIFTY EMA 9 + VWAP | ITM Option Signals", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaLength = input.int(9, "EMA Length")
strikeStep = input.int(50, "NIFTY Strike Interval")
profitPct = input.float(8.0, "Premium Target %", step=0.1)

// Current weekly option contracts.
// These are ONLY used for actual premium data.
// Strike displayed on chart is calculated automatically
// from the live NIFTY price.
ceSymbol = input.symbol("NSE:NIFTY260818C24350", "CE Premium Contract")
peSymbol = input.symbol("NSE:NIFTY260818P24450", "PE Premium Contract")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NIFTY EMA + VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema9 = ta.ema(close, emaLength)
vwap = ta.vwap(hlc3)
plot(ema9, "9 EMA", color=color.orange, linewidth=2)
plot(vwap, "VWAP", color=color.blue, linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIVE NIFTY STRIKE CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Nearest ATM 50-point strike
atmStrike = math.round(close / strikeStep) * strikeStep

// 1 strike ITM
liveCEStrike = atmStrike - strikeStep
livePEStrike = atmStrike + strikeStep

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTUAL OPTION PREMIUM DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ceClose = request.security(
     ceSymbol,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ceHigh = request.security(
     ceSymbol,
     timeframe.period,
     high,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

peClose = request.security(
     peSymbol,
     timeframe.period,
     close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

peHigh = request.security(
     peSymbol,
     timeframe.period,
     high,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA / VWAP CROSS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaCrossDown = ta.crossunder(ema9, vwap)
emaCrossUp   = ta.crossover(ema9, vwap)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION STATE
//
//  0 = No position
//  1 = CE
// -1 = PE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int position = 0

var float entryPremium = na
var float targetPremium = na

// Store the actual strike entered
var float entryStrike = na
var string entryOption = ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL FLAGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool buyAlert = false
bool exitAlert = false

bool buyCE = false
bool buyPE = false

bool exitCE = false
bool exitPE = false

bool targetExit = false
bool reversalExit = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXIT INFORMATION
//
// These variables are deliberately separate from
// the active position so the EXIT label retains
// the old strike even after a reversal.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float exitStrike = na
var float exitPremium = na
var string exitOption = ""
var string exitReason = ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8% TARGET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ceTargetHit =
     position == 1 and
     not na(targetPremium) and
     ceHigh >= targetPremium

peTargetHit =
     position == -1 and
     not na(targetPremium) and
     peHigh >= targetPremium

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET EXIT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if ceTargetHit

    // SAVE EXIT INFORMATION FIRST
    exitStrike := entryStrike
    exitOption := "CE"
    exitPremium := targetPremium
    exitReason := "8% TARGET"

    exitCE := true
    exitAlert := true
    targetExit := true

    // NOW CLEAR POSITION
    position := 0
    entryPremium := na
    targetPremium := na
    entryStrike := na
    entryOption := ""

if peTargetHit

    // SAVE EXIT INFORMATION FIRST
    exitStrike := entryStrike
    exitOption := "PE"
    exitPremium := targetPremium
    exitReason := "8% TARGET"

    exitPE := true
    exitAlert := true
    targetExit := true

    // NOW CLEAR POSITION
    position := 0
    entryPremium := na
    targetPremium := na
    entryStrike := na
    entryOption := ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA CROSS BELOW VWAP
//
// EXIT CE
// BUY 1 ITM PE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if emaCrossDown

    // First exit existing CE
    if position == 1

        // SAVE OLD CE INFORMATION
        exitStrike := entryStrike
        exitOption := "CE"
        exitPremium := ceClose
        exitReason := "EMA/VWAP REVERSAL"

        exitCE := true
        exitAlert := true
        reversalExit := true

    // BUY PE
    if not na(peClose)

        buyPE := true
        buyAlert := true

        position := -1

        entryPremium := peClose

        targetPremium :=
             entryPremium * (1 + profitPct / 100)

        // IMPORTANT:
        // Strike comes from LIVE NIFTY price
        entryStrike := livePEStrike
        entryOption := "PE"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA CROSS ABOVE VWAP
//
// EXIT PE
// BUY 1 ITM CE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if emaCrossUp

    // First exit existing PE
    if position == -1

        // SAVE OLD PE INFORMATION
        exitStrike := entryStrike
        exitOption := "PE"
        exitPremium := peClose
        exitReason := "EMA/VWAP REVERSAL"

        exitPE := true
        exitAlert := true
        reversalExit := true

    // BUY CE
    if not na(ceClose)

        buyCE := true
        buyAlert := true

        position := 1

        entryPremium := ceClose

        targetPremium :=
             entryPremium * (1 + profitPct / 100)

        // IMPORTANT:
        // Strike comes from LIVE NIFTY price
        entryStrike := liveCEStrike
        entryOption := "CE"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY LABEL — PE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buyPE

    label.new(
         bar_index,
         low,
         "BUY PE\n" +
         "Strike: " +
         str.tostring(entryStrike, "#") +
         "\nEntry: ₹" +
         str.tostring(entryPremium, "#.##") +
         "\n8% Target: ₹" +
         str.tostring(targetPremium, "#.##"),
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY LABEL — CE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buyCE

    label.new(
         bar_index,
         low,
         "BUY CE\n" +
         "Strike: " +
         str.tostring(entryStrike, "#") +
         "\nEntry: ₹" +
         str.tostring(entryPremium, "#.##") +
         "\n8% Target: ₹" +
         str.tostring(targetPremium, "#.##"),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXIT LABEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if exitAlert

    label.new(
         bar_index,
         high,
         "EXIT " +
         exitOption +
         "\nStrike: " +
         str.tostring(exitStrike, "#") +
         "\nExit: ₹" +
         str.tostring(exitPremium, "#.##") +
         "\nReason: " +
         exitReason,
         style=label.style_label_down,
         color=targetExit ? color.blue : color.orange,
         textcolor=color.white,
         size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LIVE STRIKE DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table strikeTable = table.new(
     position.top_right,
     2,
     4,
     bgcolor=color.new(color.black, 20),
     border_width=1)

if barstate.islast

    table.cell(
         strikeTable,
         0,
         0,
         "NIFTY",
         text_color=color.white,
         bgcolor=color.gray)

    table.cell(
         strikeTable,
         1,
         0,
         str.tostring(close, "#.##"),
         text_color=color.white,
         bgcolor=color.gray)

    table.cell(
         strikeTable,
         0,
         1,
         "ATM",
         text_color=color.white)

    table.cell(
         strikeTable,
         1,
         1,
         str.tostring(atmStrike, "#"),
         text_color=color.yellow)

    table.cell(
         strikeTable,
         0,
         2,
         "1 ITM CE",
         text_color=color.white)

    table.cell(
         strikeTable,
         1,
         2,
         str.tostring(liveCEStrike, "#"),
         text_color=color.lime)

    table.cell(
         strikeTable,
         0,
         3,
         "1 ITM PE",
         text_color=color.white)

    table.cell(
         strikeTable,
         1,
         3,
         str.tostring(livePEStrike, "#"),
         text_color=color.red)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     position != 0 ? entryPremium : na,
     "Entry Premium",
     color=color.yellow,
     display=display.data_window)

plot(
     position != 0 ? targetPremium : na,
     "8% Target Premium",
     color=color.aqua,
     display=display.data_window)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ONLY TWO ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buyAlert,
     title="NIFTY OPTION BUY",
     message="NIFTY OPTION BUY")

alertcondition(
     exitAlert,
     title="NIFTY OPTION EXIT",
     message="NIFTY OPTION EXIT")
````
