# XAUUSD Session 9EMA Last-Cross + Touch + Enter/R.Enter

- url: https://www.tradingview.com/script/Ohb9NGuk-XAUUSD-Session-9EMA-Last-Cross-Touch-Enter-R-Enter/
- type: indicator
- pine_id: PUB;e88130c201234ec58b03fae538a6dbad
- version: 1.0

## Description

EMA Cross → EMA 9 Touch → Touch Candle Breakout (BOT) → Previous Swing Break (ENTER)

1. EMA setup

The script uses:

EMA 9 = fast EMA
EMA 21 = slow EMA

There are two possible directions:

Bullish

EMA 9 crosses above EMA 21.
This creates a BUY bias.

Bearish

EMA 9 crosses below EMA 21.
This creates a SELL bias.

The crossover itself is not the final entry.

2. Stage 1 — CROSS

After a fresh crossover, the system starts a new setup.

For BUY:

EMA 9 crosses above EMA 21

For SELL:

EMA 9 crosses below EMA 21

The script then waits for price to come back to the 9 EMA.

The previous swing is also captured at this point:

BUY → previous swing high
SELL → previous swing low

The default swing calculation is:

10 bars before the crossover.

3. Stage 2 — TOUCH

After the crossover, the script waits for a candle to touch the 9 EMA.

The condition is:

Low <= EMA 9 AND High >= EMA 9

So the candle's range must contain the 9 EMA.

For example:

BUY setup

        Price
          ↑
          │
   EMA 9 ────────
          │
       Candle
       touches
       EMA 9

When this happens, the script records:

Touch candle high
Touch candle low

This candle becomes the reference candle for the next step.

4. Stage 3 — BOT

BOT means the touch candle's range gets broken.

For a BUY:

The high of the touch candle must be broken.

For a SELL:

The low of the touch candle must be broken.

Example BUY:

Touch candle


High ───────────────
        │
        │
EMA 9 ──────────────
        │
Low  ───────────────


             ↑
       Price breaks
       touch high


             ↓
            BOT

Important:

The script checks:

high > touchHigh

for BUY.

And:

low < touchLow

for SELL.

So BOT happens when price moves beyond the touch candle's range.

5. Stage 4 — ENTER

BOT is still not the final entry.

After BOT, the script waits for price to break the previous swing level.

For BUY:

Candle CLOSE must be above the previous swing high.

For SELL:

Candle CLOSE must be below the previous swing low.

This is important because the script specifically uses the candle body/close, rather than accepting a wick.

BUY
Previous Swing High
──────────────────────


                 █
                 █  ← candle closes above
                 █
                 █
                 ↑
               ENTER

Condition:

close > swingLevel

SELL
Previous Swing Low
──────────────────────


                 █
                 █
                 █
                 ↓
               ENTER

Condition:

close < swingLevel

So the final sequence is:

BUY

9/21 bullish cross
→ 9 EMA touch
→ touch candle high broken (BOT)
→ previous swing high broken by CLOSE
→ ENTER BUY

SELL

9/21 bearish cross
→ 9 EMA touch
→ touch candle low broken (BOT)
→ previous swing low broken by CLOSE
→ ENTER SELL

6. Very important: the setup is sequential

The script uses a state machine:

Stage	Meaning	What it waits for
0	Idle	New crossover
1	CROSS	9 EMA touch
2	TOUCH	Touch candle breakout
3	BOT	Previous swing breakout
4	ENTER	Setup completed

Once ENTER happens, that setup is finished.

The script waits for a new EMA crossover before starting another setup.

7. What happens if the opposite EMA cross occurs?

A new crossover completely resets the setup.

For example:

BUY CROSS
   ↓
TOUCH
   ↓
BOT
   ↓
SELL CROSS

The previous BUY setup is abandoned.

The new SELL crossover starts a fresh setup.

8. The chart displays four different signals

You will see:

BUY / SELL

This is the EMA crossover, not the actual trade entry.

Yellow circle

This is the 9 EMA TOUCH.

BOT

This means the touch candle's high/low has been broken.

ENTER

This is the actual final entry signal.

So for your trading purposes, the most important signal is:

ENTER BUY / ENTER SELL

9. Alerts

The script has separate alerts for:

Cross BUY
Cross SELL
Touch
BOT
ENTER BUY
ENTER SELL

Therefore, if your goal is only to receive the actual trading signal, you would normally use:

ENTER BUY

and

ENTER SELL

rather than creating alerts for every intermediate stage.

10. Multi-Timeframe Table

The script also checks the same system on:

Weekly
1 Day
4 Hour
30 Minute

It displays:

Timeframe	Stage	Bias
Weekly	CROSS/TOUCH/BOT/ENTER	BUY/SELL
1 Day	CROSS/TOUCH/BOT/ENTER	BUY/SELL
4 Hour	CROSS/TOUCH/BOT/ENTER	BUY/SELL
30 Min	CROSS/TOUCH/BOT/ENTER	BUY/SELL

For example, you might see:

Timeframe    Stage     Bias
Weekly       ENTER     BUY
1 Day        BOT       BUY
4 Hour       TOUCH     BUY
30 Min       CROSS     BUY

That means each timeframe is independently running the same EMA 9/21 system.

11. One important detail about the swing level

This part is particularly important:

swingHighVal = ta.highest(high, swingLookback)[1]
swingLowVal  = ta.lowest(low, swingLookback)[1]

With the default:

Swing Lookback = 10

the script takes the highest high / lowest low from the preceding 10 bars, excluding the current bar.

That level is stored when the EMA crossover happens.

It does not continuously move afterward.

So if the BUY crossover happens and the swing high is 10 bars back at 3340, the ENTER condition remains:

close > 3340

even if later candles create another higher high.

12. Example of a complete BUY trade

Suppose XAUUSD does this:

1. EMA 9 crosses above EMA 21
          ↓
       BUY bias


2. Price pulls back
          ↓
3. Candle touches EMA 9
          ↓
       TOUCH


4. Price breaks touch candle high
          ↓
        BOT


5. Price continues higher
          ↓
6. Candle CLOSES above previous swing high
          ↓
       ENTER BUY

Your actual entry is at step 6, not at the EMA crossover.

13. In simple words

Your indicator is looking for momentum + pullback + confirmation + structure breakout.

The philosophy is:

EMA crossover tells the direction → price pulls back to EMA 9 → price proves momentum by breaking the touch candle → price confirms the trend by breaking the previous swing → ENTER.

So the system is designed to avoid taking the trade immediately after an EMA crossover.

The complete logic
                 EMA 9 / EMA 21
                       │
             ┌─────────┴─────────┐
             │                   │
        9 crosses UP        9 crosses DOWN
             │                   │
          BUY bias            SELL bias
             │                   │
             └─────────┬─────────┘
                       ↓
                 WAIT FOR TOUCH
                       │
                Price touches EMA 9
                       │
                       ↓
                     TOUCH
                       │
                       ↓
             Break touch candle
                high / low
                       │
                       ↓
                      BOT
                       │
                       ↓
             Break previous swing
              with candle CLOSE
                       │
                       ↓
                    ENTER

## Source Code

````pine
//@version=6
indicator("XAUUSD Session 9EMA Last-Cross + Touch + Enter/R.Enter", overlay=true, max_labels_count=500)

// =========================================================================
// INPUTS
// =========================================================================
emaFastLen = input.int(9,  "Fast EMA Length", minval=1)
emaSlowLen = input.int(21, "Slow EMA Length", minval=1)

grpSessions = "Session First-Hour Windows (Pune / IST time, HHMM-HHMM)"
sydneyZoneStr = input.session("0230-0330", "Sydney (first 1H)",   group=grpSessions)
tokyoZoneStr  = input.session("0530-0630", "Tokyo (first 1H)",    group=grpSessions)
londonZoneStr = input.session("1230-1330", "London (first 1H)",  group=grpSessions)
nyZoneStr     = input.session("1900-2000", "New York (first 1H)", group=grpSessions)

showZoneBg   = input.bool(true, "Shade First-Hour Window")
showCrossLbl = input.bool(true, "Mark Every Intra-Hour Cross")
showFixedLbl = input.bool(true, "Mark Fixed Direction (end of hour)")
showTouchLbl = input.bool(true, "Mark Touch Point")

// =========================================================================
// EMAs
// =========================================================================
ema9  = ta.ema(close, emaFastLen)
ema21 = ta.ema(close, emaSlowLen)

plot(ema9,  "EMA Fast", color=color.new(color.aqua, 0),   linewidth=1)
plot(ema21, "EMA Slow", color=color.new(color.orange, 0), linewidth=1)

// =========================================================================
// SESSION FIRST-HOUR WINDOWS (fixed to Asia/Kolkata timezone, independent
// of your chart's display timezone)
// =========================================================================
sydneyZone = not na(time(timeframe.period, sydneyZoneStr, "Asia/Kolkata"))
tokyoZone  = not na(time(timeframe.period, tokyoZoneStr,  "Asia/Kolkata"))
londonZone = not na(time(timeframe.period, londonZoneStr, "Asia/Kolkata"))
nyZone     = not na(time(timeframe.period, nyZoneStr,     "Asia/Kolkata"))

sydneyZoneStart = sydneyZone and not sydneyZone[1]
tokyoZoneStart  = tokyoZone  and not tokyoZone[1]
londonZoneStart = londonZone and not londonZone[1]
nyZoneStart     = nyZone     and not nyZone[1]

bgcolor(showZoneBg and sydneyZone ? color.new(color.blue, 88)   : na, title="Sydney Window")
bgcolor(showZoneBg and tokyoZone  ? color.new(color.purple, 88) : na, title="Tokyo Window")
bgcolor(showZoneBg and londonZone ? color.new(color.teal, 88)   : na, title="London Window")
bgcolor(showZoneBg and nyZone     ? color.new(color.maroon, 88) : na, title="New York Window")

// =========================================================================
// CORE STATE MACHINE (one independent instance per call-site / per session)
//
// state: 0 = inside/before first-hour window, tracking the LAST cross
//        1 = window ended, direction fixed, waiting for first TOUCH
//        2 = TOUCH found, waiting for ENTER (correct-side break)
//        3 = ENTER fired, waiting for R.ENTER (opposite-side break of the
//            SAME original touch candle)
//        4 = done for this session (R.ENTER fired, or no cross this window)
//
// All state gating uses `stateNow`, a snapshot taken at the top of the bar,
// so a transition (e.g. state 2 -> 3) cannot cascade into checking the next
// stage on the very same bar.
// =========================================================================
f_process(zoneCond, zoneStart, fastEma, slowEma) =>
    var int state = 0
    var int dir = 0
    var float touchHigh = na
    var float touchLow = na
    var int touchBarIdx = na

    if zoneStart
        state := 0
        dir := 0
        touchHigh := na
        touchLow := na
        touchBarIdx := na

    stateNow = state

    bullCross = ta.crossover(fastEma, slowEma)
    bearCross = ta.crossunder(fastEma, slowEma)

    // Step 1: during the first-hour window, every cross updates the
    // direction -- the LAST one before the window ends wins.
    crossEventDir = 0
    if zoneCond and stateNow == 0
        if bullCross
            dir := 1
            crossEventDir := 1
        else if bearCross
            dir := -1
            crossEventDir := -1

    // Step 2: the bar right after the window closes, direction is locked.
    // If no cross ever happened this window, this session is skipped.
    zoneEnded = zoneCond[1] and not zoneCond
    zoneFixedEvent = zoneEnded and stateNow == 0
    if zoneFixedEvent
        state := dir != 0 ? 1 : 4

    bodyHigh = math.max(open, close)
    bodyLow = math.min(open, close)
    touched = low <= fastEma and high >= fastEma

    // Step 3: first candle (after direction is fixed) that touches the EMA
    if stateNow == 1 and touched
        state := 2
        touchHigh := bodyHigh
        touchLow := bodyLow
        touchBarIdx := bar_index

    // Step 4: ENTER on breakout of the correct side of the touch candle
    enterSignal = false
    if stateNow == 2
        if dir == 1 and high > touchHigh
            enterSignal := true
            state := 3
        else if dir == -1 and low < touchLow
            enterSignal := true
            state := 3

    // Step 5: R.ENTER on breakout of the OPPOSITE side of that same touch
    // candle, any time after ENTER has already fired
    reEnterSignal = false
    if stateNow == 3
        if dir == 1 and low < touchLow
            reEnterSignal := true
            state := 4
        else if dir == -1 and high > touchHigh
            reEnterSignal := true
            state := 4

    [enterSignal, reEnterSignal, dir, touchBarIdx, state, crossEventDir, zoneFixedEvent]

// =========================================================================
// RUN PER SESSION (each call keeps its own independent persistent state)
// =========================================================================
[sydEnter, sydReEnter, sydDir, sydTouchIdx, sydState, sydCrossDir, sydFixedEvt] = f_process(sydneyZone, sydneyZoneStart, ema9, ema21)
[tokEnter, tokReEnter, tokDir, tokTouchIdx, tokState, tokCrossDir, tokFixedEvt] = f_process(tokyoZone, tokyoZoneStart, ema9, ema21)
[lonEnter, lonReEnter, lonDir, lonTouchIdx, lonState, lonCrossDir, lonFixedEvt] = f_process(londonZone, londonZoneStart, ema9, ema21)
[nyEnter, nyReEnter, nyDir, nyTouchIdx, nyState, nyCrossDir, nyFixedEvt] = f_process(nyZone, nyZoneStart, ema9, ema21)

// =========================================================================
// INTRA-HOUR CROSS MARKERS (small, every cross while direction is still
// being decided)
// =========================================================================
if showCrossLbl and sydCrossDir != 0
    label.new(bar_index, sydCrossDir == 1 ? low : high, sydCrossDir == 1 ? "up" : "dn", style=label.style_none, textcolor=color.new(color.blue, 0), size=size.tiny)
if showCrossLbl and tokCrossDir != 0
    label.new(bar_index, tokCrossDir == 1 ? low : high, tokCrossDir == 1 ? "up" : "dn", style=label.style_none, textcolor=color.new(color.purple, 0), size=size.tiny)
if showCrossLbl and lonCrossDir != 0
    label.new(bar_index, lonCrossDir == 1 ? low : high, lonCrossDir == 1 ? "up" : "dn", style=label.style_none, textcolor=color.new(color.teal, 0), size=size.tiny)
if showCrossLbl and nyCrossDir != 0
    label.new(bar_index, nyCrossDir == 1 ? low : high, nyCrossDir == 1 ? "up" : "dn", style=label.style_none, textcolor=color.new(color.maroon, 0), size=size.tiny)

// =========================================================================
// FIXED-DIRECTION LABELS (shown once, right when the first hour closes)
// =========================================================================
sydFixedTxt = sydDir == 1 ? "Sydney\nBUY FIXED" : sydDir == -1 ? "Sydney\nSELL FIXED" : "Sydney\nNO CROSS"
sydFixedStyle = sydDir == 1 ? label.style_label_up : label.style_label_down
sydFixedPrice = sydDir == 1 ? low : high
if showFixedLbl and sydFixedEvt
    label.new(bar_index, sydFixedPrice, sydFixedTxt, style=sydFixedStyle, color=color.new(color.blue, 40), textcolor=color.white, size=size.small)

tokFixedTxt = tokDir == 1 ? "Tokyo\nBUY FIXED" : tokDir == -1 ? "Tokyo\nSELL FIXED" : "Tokyo\nNO CROSS"
tokFixedStyle = tokDir == 1 ? label.style_label_up : label.style_label_down
tokFixedPrice = tokDir == 1 ? low : high
if showFixedLbl and tokFixedEvt
    label.new(bar_index, tokFixedPrice, tokFixedTxt, style=tokFixedStyle, color=color.new(color.purple, 40), textcolor=color.white, size=size.small)

lonFixedTxt = lonDir == 1 ? "London\nBUY FIXED" : lonDir == -1 ? "London\nSELL FIXED" : "London\nNO CROSS"
lonFixedStyle = lonDir == 1 ? label.style_label_up : label.style_label_down
lonFixedPrice = lonDir == 1 ? low : high
if showFixedLbl and lonFixedEvt
    label.new(bar_index, lonFixedPrice, lonFixedTxt, style=lonFixedStyle, color=color.new(color.teal, 40), textcolor=color.white, size=size.small)

nyFixedTxt = nyDir == 1 ? "New York\nBUY FIXED" : nyDir == -1 ? "New York\nSELL FIXED" : "New York\nNO CROSS"
nyFixedStyle = nyDir == 1 ? label.style_label_up : label.style_label_down
nyFixedPrice = nyDir == 1 ? low : high
if showFixedLbl and nyFixedEvt
    label.new(bar_index, nyFixedPrice, nyFixedTxt, style=nyFixedStyle, color=color.new(color.maroon, 40), textcolor=color.white, size=size.small)

// =========================================================================
// TOUCH POINT LABELS
// =========================================================================
if showTouchLbl and not na(sydTouchIdx) and sydTouchIdx == bar_index
    label.new(bar_index, sydDir == 1 ? low : high, "Touch (Sydney)", style=label.style_circle, color=color.new(color.blue, 40), size=size.tiny)
if showTouchLbl and not na(tokTouchIdx) and tokTouchIdx == bar_index
    label.new(bar_index, tokDir == 1 ? low : high, "Touch (Tokyo)", style=label.style_circle, color=color.new(color.purple, 40), size=size.tiny)
if showTouchLbl and not na(lonTouchIdx) and lonTouchIdx == bar_index
    label.new(bar_index, lonDir == 1 ? low : high, "Touch (London)", style=label.style_circle, color=color.new(color.teal, 40), size=size.tiny)
if showTouchLbl and not na(nyTouchIdx) and nyTouchIdx == bar_index
    label.new(bar_index, nyDir == 1 ? low : high, "Touch (NY)", style=label.style_circle, color=color.new(color.maroon, 40), size=size.tiny)

// =========================================================================
// COMBINE ENTER SIGNALS ACROSS SESSIONS
// =========================================================================
anyEnter = sydEnter or tokEnter or lonEnter or nyEnter
enterDir = sydEnter ? sydDir : tokEnter ? tokDir : lonEnter ? lonDir : nyEnter ? nyDir : 0
enterSession = sydEnter ? "Sydney" : tokEnter ? "Tokyo" : lonEnter ? "London" : nyEnter ? "New York" : ""

isBuyEnter = anyEnter and enterDir == 1
isSellEnter = anyEnter and enterDir == -1

plotshape(isBuyEnter, title="Buy Enter", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), size=size.small)
plotshape(isSellEnter, title="Sell Enter", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.small)

enterTxt = "ENTER\n" + (enterDir == 1 ? "BUY " : "SELL ") + enterSession
enterStyle = enterDir == 1 ? label.style_label_up : label.style_label_down
enterPrice = enterDir == 1 ? low : high
enterYloc = enterDir == 1 ? yloc.belowbar : yloc.abovebar
enterColor = enterDir == 1 ? color.new(color.lime, 20) : color.new(color.red, 20)
if anyEnter
    label.new(bar_index, enterPrice, enterTxt, style=enterStyle, color=enterColor, textcolor=color.black, size=size.small, yloc=enterYloc)

// =========================================================================
// COMBINE R.ENTER SIGNALS ACROSS SESSIONS
// =========================================================================
anyReEnter = sydReEnter or tokReEnter or lonReEnter or nyReEnter
reEnterDir = sydReEnter ? sydDir : tokReEnter ? tokDir : lonReEnter ? lonDir : nyReEnter ? nyDir : 0
reEnterSession = sydReEnter ? "Sydney" : tokReEnter ? "Tokyo" : lonReEnter ? "London" : nyReEnter ? "New York" : ""

// R.ENTER direction is the REVERSE of the original setup direction
isBuyReEnter = anyReEnter and reEnterDir == -1   // original SELL setup reversing into a buy
isSellReEnter = anyReEnter and reEnterDir == 1   // original BUY setup reversing into a sell

plotshape(isBuyReEnter, title="Buy R.Enter", style=shape.triangleup, location=location.belowbar, color=color.new(color.yellow, 0), size=size.small)
plotshape(isSellReEnter, title="Sell R.Enter", style=shape.triangledown, location=location.abovebar, color=color.new(color.yellow, 0), size=size.small)

reEnterTxt = "R.ENTER\n" + (reEnterDir == 1 ? "reverse to SELL " : "reverse to BUY ") + reEnterSession
reEnterStyle = reEnterDir == 1 ? label.style_label_down : label.style_label_up
reEnterPrice = reEnterDir == 1 ? high : low
reEnterYloc = reEnterDir == 1 ? yloc.abovebar : yloc.belowbar
if anyReEnter
    label.new(bar_index, reEnterPrice, reEnterTxt, style=reEnterStyle, color=color.new(color.yellow, 20), textcolor=color.black, size=size.small, yloc=reEnterYloc)

// =========================================================================
// ALERTS
// =========================================================================
alertcondition(isBuyEnter, title="Buy Enter", message="XAUUSD: BUY Enter signal")
alertcondition(isSellEnter, title="Sell Enter", message="XAUUSD: SELL Enter signal")
alertcondition(anyReEnter, title="R.Enter", message="XAUUSD: R.Enter (reverse) signal")
````
