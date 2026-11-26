# EMA 9/21 Cross -> Touch -> Breakout(BOT) -> Enter System

- url: https://www.tradingview.com/script/JjQLyuRb-EMA-9-21-Cross-Touch-Breakout-BOT-Enter-System/
- type: indicator
- pine_id: PUB;31712d756af64dd182821dacd1df444e
- version: 1.0

## Description

1. EMA setup

The script uses two EMAs:

9 EMA = fast EMA
21 EMA = slow EMA
BUY direction

When:

9 EMA crosses above 21 EMA

the script creates a BUY setup.

SELL direction

When:

9 EMA crosses below 21 EMA

the script creates a SELL setup.

The crossover itself is only the beginning of the setup. It is not the final entry.

2. CROSS → Start of a new setup

The script has four stages:

Stage	Meaning
0	No active setup
1	CROSS happened → waiting for TOUCH
2	TOUCH happened → waiting for BOT
3	BOT happened → waiting for ENTER
4	ENTER happened → setup completed

For example, after a bullish crossover:

9 EMA
   ↗
  / 
 /  crosses above
──────── 21 EMA
      ↓
   BUY setup

The script then waits for price to come back and touch the 9 EMA.

3. TOUCH — Price returns to EMA 9

The next requirement is that a candle must touch the 9 EMA.

The condition is:

low <= EMA 9
AND
high >= EMA 9

In simple terms:

The 9 EMA must be inside the candle's high-low range.

Example:

        Candle
      ┌─────────┐
      │         │
      │  EMA 9 ─────
      │         │
      └─────────┘

That candle becomes the Touch Candle.

The script records:

Touch candle high
Touch candle low

These levels are then used for the BOT.

4. BOT — Breakout of the Touch Candle

After TOUCH, the script does not immediately enter.

It waits for the touch candle itself to be broken.

BUY setup

The high of the touch candle must be broken.

Touch candle high
──────────────────
             ↑
             │ Break
             │
          Price

Condition:

high > touchHigh

When this happens:

BOT BUY

SELL setup

The low of the touch candle must be broken.

          Price
             │
             ↓ Break
──────────────────
Touch candle low

Condition:

low < touchLow

When this happens:

BOT SELL

5. ENTER — Final confirmation

BOT is not the final entry.

After BOT, the script waits for the previously identified swing level to break.

This is the final confirmation.

BUY

The candle must CLOSE above the swing high.

Previous Swing High
────────────────────────


                 █
                 █
                 █
                 █ ← CLOSE above

Condition:

close > swingLevel

Then:

ENTER BUY

SELL

The candle must CLOSE below the swing low.

Previous Swing Low
────────────────────────


                 █
                 █
                 █
                 █
                 ↓ CLOSE below

Condition:

close < swingLevel

Then:

ENTER SELL

6. Very important: ENTER uses candle CLOSE

This is one of the most important parts of your script.

It does not consider a simple wick break enough.

For BUY:

high > swingLevel

is not enough.

It requires:

close > swingLevel

For SELL:

low < swingLevel

is not enough.

It requires:

close < swingLevel

So the final ENTER is a body/close confirmation.

7. Where does the swing level come from?

This part of the code is:

swingHighVal = ta.highest(high, swingLookback)[1]
swingLowVal  = ta.lowest(low, swingLookback)[1]

The default:

Swing Lookback = 10 bars

When the EMA crossover occurs:

BUY

The script stores the highest high of the previous 10 bars.

That becomes:

BUY swingLevel

SELL

The script stores the lowest low of the previous 10 bars.

That becomes:

SELL swingLevel

And importantly, that level is stored when the crossover occurs.

It does not continuously update during the setup.

8. Complete BUY example

Suppose XAUUSD does this:

STEP 1
9 EMA crosses ABOVE 21 EMA
        ↓
     BUY bias
        ↓
STEP 2
Price pulls back
        ↓
Price touches EMA 9
        ↓
      TOUCH
        ↓
STEP 3
Touch candle high breaks
        ↓
       BOT
        ↓
STEP 4
Price continues upward
        ↓
Candle CLOSES above
previous swing high
        ↓
     ENTER BUY

So the trade signal is:

CROSS → TOUCH → BOT → ENTER

9. Complete SELL example
STEP 1
9 EMA crosses BELOW 21 EMA
        ↓
     SELL bias
        ↓
STEP 2
Price pulls back
        ↓
Price touches EMA 9
        ↓
      TOUCH
        ↓
STEP 3
Touch candle low breaks
        ↓
       BOT
        ↓
STEP 4
Price continues downward
        ↓
Candle CLOSES below
previous swing low
        ↓
     ENTER SELL
10. What happens if another EMA cross occurs?

A new crossover starts a completely new setup.

For example:

BUY CROSS
   ↓
TOUCH
   ↓
BOT
   ↓
SELL CROSS

The BUY setup is effectively replaced by the new SELL setup.

The script resets:

Direction
Stage
Touch high
Touch low
Swing level

and starts again from:

Stage 1 = CROSS

11. After ENTER

Once ENTER occurs:

stage = 4

The setup is considered complete.

It will not generate another ENTER from the same crossover.

It waits for another fresh EMA 9/21 crossover to start a new setup.

Therefore, one crossover can produce at most:

1 final ENTER

12. What you see on the chart

The script displays:

Blue line

EMA 9

Orange line

EMA 21

BUY triangle

9 EMA crossed above 21 EMA.

SELL triangle

9 EMA crossed below 21 EMA.

Yellow circle

Price touched EMA 9.

BOT

Touch candle's high/low was broken.

ENTER

Final trading signal.

13. Alerts

The script provides six alert conditions:

Cross - BUY
Cross - SELL
Touch
BOT
ENTER BUY
ENTER SELL

If your purpose is actual trade execution, the most important alerts are:

ENTER BUY

and

ENTER SELL

You don't necessarily need alerts for CROSS, TOUCH, or BOT unless you want to monitor the setup's progress.

14. Multi-Timeframe Table

The script also runs the same signal engine independently on:

Weekly
1 Day
4 Hour
30 Minute

It displays:

┌───────────┬────────┬──────┐
│ Timeframe │ Stage  │ Bias │
├───────────┼────────┼──────┤
│ Weekly    │ ENTER  │ BUY  │
│ 1 Day     │ BOT    │ BUY  │
│ 4 Hour    │ TOUCH  │ BUY  │
│ 30 Min    │ CROSS  │ BUY  │
└───────────┴────────┴──────┘

This lets you see where each timeframe currently is in the setup.

For example:

Weekly = BUY / ENTER
means the Weekly system has completed its setup.

30M = BUY / TOUCH
means the 30-minute system has a BUY setup and is currently waiting for the touch candle to break.

15. The most important distinction

There are four different events, and they should not be confused:

CROSS

Direction identified

TOUCH

Pullback to EMA 9 confirmed

BOT

Touch candle breakout confirmed

ENTER

Previous swing structure breakout confirmed

So the strategy is essentially trying to confirm:

## Source Code

````pine
//@version=6
indicator("EMA 9/21 Cross -> Touch -> Breakout(BOT) -> Enter System", overlay=true, max_labels_count=500)

// ================= INPUTS =================
fastLen       = input.int(9, "Fast EMA Length")
slowLen       = input.int(21, "Slow EMA Length")
swingLookback = input.int(10, "Swing High/Low Lookback (bars before cross)", minval=1)
showTable     = input.bool(true, "Show Multi-Timeframe Table")
tablePos      = input.string("top_right", "Table Position",
     options=["top_right", "top_left", "bottom_right", "bottom_left"])

// ================================================================
// CORE SIGNAL ENGINE
// Stage machine per active setup:
//   0 = idle
//   1 = CROSS happened, waiting for a candle to TOUCH the 9 EMA
//   2 = TOUCH happened, waiting for touch-candle range to break (BOT)
//   3 = BOT happened, waiting for prior swing high/low to break by BODY (ENTER)
//   4 = ENTER fired (setup complete, waiting for next fresh cross to restart)
// ================================================================
f_signalEngine() =>
    var int   dirNeeded  = 0     // 1 = bullish setup active, -1 = bearish setup active
    var int   stage      = 0
    var float touchHigh  = na
    var float touchLow   = na
    var float swingLevel = na    // "previous higher-high" (buy) / "previous lower-low" (sell) reference

    emaFast = ta.ema(close, fastLen)
    emaSlow = ta.ema(close, slowLen)

    bullCross = ta.crossover(emaFast, emaSlow)   // 9 EMA crosses above 21 EMA -> BUY bias
    bearCross = ta.crossunder(emaFast, emaSlow)  // 9 EMA crosses below 21 EMA -> SELL bias

    swingHighVal = ta.highest(high, swingLookback)[1]
    swingLowVal  = ta.lowest(low,  swingLookback)[1]

    // ---- Any fresh crossover starts a brand new setup ----
    if bullCross
        dirNeeded  := 1
        stage      := 1
        touchHigh  := na
        touchLow   := na
        swingLevel := swingHighVal

    if bearCross
        dirNeeded  := -1
        stage      := 1
        touchHigh  := na
        touchLow   := na
        swingLevel := swingLowVal

    // ---- TOUCH: a candle's range includes the 9 EMA ----
    touchedEma9 = low <= emaFast and high >= emaFast
    isTouch = false
    if stage == 1 and touchedEma9
        touchHigh := high
        touchLow  := low
        stage     := 2
        isTouch   := true

    // ---- BOT: the touching candle's high/low gets broken ----
    isBot = false
    if stage == 2
        if dirNeeded == 1 and high > touchHigh
            stage := 3
            isBot := true
        else if dirNeeded == -1 and low < touchLow
            stage := 3
            isBot := true

    // ---- ENTER: prior swing high/low broken by candle BODY (close), not just a wick ----
    isEnter = false
    if stage == 3
        if dirNeeded == 1 and close > swingLevel
            stage   := 4
            isEnter := true
        else if dirNeeded == -1 and close < swingLevel
            stage   := 4
            isEnter := true

    [stage, dirNeeded, bullCross, bearCross, isTouch, isBot, isEnter, emaFast, emaSlow]

// ================= RUN ON CURRENT CHART =================
[stageC, dirC, bullCrossC, bearCrossC, isTouchC, isBotC, isEnterC, emaFastC, emaSlowC] = f_signalEngine()

plot(emaFastC, "EMA 9",  color=color.blue,   linewidth=1)
plot(emaSlowC, "EMA 21", color=color.orange, linewidth=1)

// ---- CROSS ----
plotshape(bullCrossC, title="CROSS BUY",  location=location.belowbar, style=shape.triangleup,
     color=color.new(color.green, 0), text="BUY", textcolor=color.white, size=size.tiny)
plotshape(bearCrossC, title="CROSS SELL", location=location.abovebar, style=shape.triangledown,
     color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.tiny)

// ---- TOUCH ----
plotshape(isTouchC, title="TOUCH", location=location.absolute, style=shape.circle,
     color=color.yellow, size=size.tiny)
plot(isTouchC ? emaFastC : na, title="Touch Marker", style=plot.style_circles, color=color.yellow, linewidth=3)

// ---- BOT (touch-candle breakout) ----
plotshape(isBotC and dirC == 1,  title="BOT (Buy side)",  location=location.belowbar, style=shape.labelup,
     color=color.lime,   text="BOT", textcolor=color.black, size=size.small)
plotshape(isBotC and dirC == -1, title="BOT (Sell side)", location=location.abovebar, style=shape.labeldown,
     color=color.orange, text="BOT", textcolor=color.black, size=size.small)

// ---- ENTER (final signal) ----
plotshape(isEnterC and dirC == 1,  title="ENTER BUY",  location=location.belowbar, style=shape.labelup,
     color=color.green, text="ENTER", textcolor=color.white, size=size.normal)
plotshape(isEnterC and dirC == -1, title="ENTER SELL", location=location.abovebar, style=shape.labeldown,
     color=color.red,   text="ENTER", textcolor=color.white, size=size.normal)

// ================= ALERTS =================
alertcondition(bullCrossC, title="Cross - BUY",  message="EMA9 crossed ABOVE EMA21 (BUY bias)")
alertcondition(bearCrossC, title="Cross - SELL", message="EMA9 crossed BELOW EMA21 (SELL bias)")
alertcondition(isTouchC,   title="Touch",        message="Candle touched EMA9 (TOUCH)")
alertcondition(isBotC,     title="Breakout of Touch (BOT)", message="Touch-candle range broken (BOT)")
alertcondition(isEnterC and dirC == 1,  title="ENTER BUY",  message="ENTER LONG - prior high broken by candle body")
alertcondition(isEnterC and dirC == -1, title="ENTER SELL", message="ENTER SHORT - prior low broken by candle body")

// ================================================================
// MULTI-TIMEFRAME TABLE  (Weekly / 1D / 4H / 30min)
// ================================================================
f_stageText(stage) =>
    stage == 1 ? "CROSS" : stage == 2 ? "TOUCH" : stage == 3 ? "BOT" : stage == 4 ? "ENTER" : "-"

f_dirText(dir) =>
    dir == 1 ? "BUY" : dir == -1 ? "SELL" : "-"

f_dirColor(dir) =>
    dir == 1 ? color.green : dir == -1 ? color.red : color.gray

getMTF(tf) =>
    [s, d, _, _, _, _, _, _, _] = request.security(syminfo.tickerid, tf, f_signalEngine())
    [s, d]

[stageW,  dirW]   = getMTF("W")
[stageD,  dirD]   = getMTF("D")
[stageH4, dirH4]  = getMTF("240")
[stageM30, dirM30] = getMTF("30")

var table mtfTable = table.new(
     tablePos == "top_right"    ? position.top_right :
     tablePos == "top_left"     ? position.top_left :
     tablePos == "bottom_right" ? position.bottom_right : position.bottom_left,
     3, 5, border_width=1)

if barstate.islast and showTable
    table.cell(mtfTable, 0, 0, "Timeframe", bgcolor=color.gray, text_color=color.white)
    table.cell(mtfTable, 1, 0, "Stage",     bgcolor=color.gray, text_color=color.white)
    table.cell(mtfTable, 2, 0, "Bias",      bgcolor=color.gray, text_color=color.white)

    table.cell(mtfTable, 0, 1, "Weekly")
    table.cell(mtfTable, 1, 1, f_stageText(stageW))
    table.cell(mtfTable, 2, 1, f_dirText(dirW), text_color=f_dirColor(dirW))

    table.cell(mtfTable, 0, 2, "1 Day")
    table.cell(mtfTable, 1, 2, f_stageText(stageD))
    table.cell(mtfTable, 2, 2, f_dirText(dirD), text_color=f_dirColor(dirD))

    table.cell(mtfTable, 0, 3, "4 Hour")
    table.cell(mtfTable, 1, 3, f_stageText(stageH4))
    table.cell(mtfTable, 2, 3, f_dirText(dirH4), text_color=f_dirColor(dirH4))

    table.cell(mtfTable, 0, 4, "30 Min")
    table.cell(mtfTable, 1, 4, f_stageText(stageM30))
    table.cell(mtfTable, 2, 4, f_dirText(dirM30), text_color=f_dirColor(dirM30))
````
