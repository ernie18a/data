# MSnR Classic StoryLine MTF

- url: https://www.tradingview.com/script/5ZZmsIHj-MSnR-Classic-StoryLine-MTF/
- type: indicator
- pine_id: PUB;7ee4f48a49c9494c9da6b58912d7f7d3
- version: 1.0

## Description

[b]MSnR Classic StoryLine MTF[/b]

A dashboard that reads the trend of five higher timeframes at once, and reports each one as
Bullish or Bearish.

What makes each reading is not an indicator applied to five timeframes. It is a two timeframe
process. The higher timeframe decides WHERE to look: it finds the support or resistance level
that price has just rejected. The lower timeframe then decides WHICH WAY: it waits for price to
break the last structural level standing in the way. Only when both halves complete does that
row change.

Nothing is calculated from the chart you are on, so the table reads the same on every timeframe.
You can sit on M5 and still read the Monthly trend.


[b]THE FIVE PAIRS[/b]

 Monthly    decided on Daily
 Weekly     decided on H4
 Daily      decided on H1
 H4         decided on M30
 H1         decided on M15

Each row is completely independent. They share no state and can disagree with each other, which
is the point: agreement across rows is information, and so is conflict.


[b]WHAT MAKES THIS DIFFERENT[/b]

[b]1. Two timeframes decide one reading.[/b]

Most multi timeframe tools run the same calculation on several timeframes and stack the results.
Here the two timeframes have different jobs. The higher one supplies the context and never
decides direction on its own. The lower one supplies the proof and is never consulted without a
context. Neither half means anything alone.

[b]2. Levels are tracked, not drawn.[/b]

A level is not a line that is placed once and left there. Every level created inside the window
is followed forward, candle by candle, and its state is updated: it can be rejected, it can be
broken, it can flip sides and come back to life. A rejection only counts when it happens on a
level that is still Fresh. This is what stops the same tired level from producing a signal over
and over.

[b]3. Several setups wait at the same time.[/b]

Every rejection opens its own setup, and a newer one never cancels an older one. Two, five, a
dozen can be waiting together, each with its own level and its own breakout target. Whichever
one breaks out FIRST is the one that turns the trend. A tool that tracks only the latest
rejection is late whenever the older one was closer to completing.

[b]4. Both directions are always watched.[/b]

A single higher timeframe candle can reject a resistance and a support at the same time. Both
open a setup. The one that completes first turns the trend, and the other stays alive and can
turn it back afterwards. Nothing is switched off because of what the trend already says.

[b]5. It shows its own reasoning.[/b]

The dashboard alone would be a black box. So for one row of your choosing the script draws the
whole chain on the chart: the level that was rejected, the candle that rejected it, the lower
timeframe candle that touched it, the level that was locked, and the candle that broke it. You
can check every reading against the candles yourself.


[b]THE LEVELS[/b]

Every pair of consecutive candles leaves a level behind, priced at the CLOSE of the first candle
of the pair. Closes are used rather than wicks because a close is where the market actually
agreed on a price.

A candle is Green when close is greater than open and Red when close is less than open. A Doji,
where close equals open, is neither and forms no level.

 A Level         Green then Red      sits above as resistance
 V Level         Red then Green      sits below as support
 Bullish Gap     Green then Green    sits below as support
 Bearish Gap     Red then Red        sits above as resistance

From there each level lives on one of two sides, and every close through it flips it:

 RBS   Resistance Become Support     a resistance a candle CLOSED above
 SBR   Support Become Resistance     a support a candle CLOSED below

A level can flip any number of times. Each flip also makes it Fresh again, because in its new
role it has never been tested.

[b]Fresh and Unfresh[/b]

 Fresh     newly created, or just flipped. Untested on the side it now sits on.
 Unfresh   price has already come back, touched it, and been turned away.

Only a Fresh level can produce a rejection. Once it turns Unfresh it stays quiet until a
breakout flips it and makes it Fresh again.


[b]HOW ONE ROW DECIDES ITS TREND[/b]

[b]Step 1 - the higher timeframe rejection[/b]

A higher timeframe candle reaches a Fresh level and fails to close through it.

  Support side      the LOW touches the level and the CLOSE stays above it
  Resistance side   the HIGH touches the level and the CLOSE stays below it

The level turns Unfresh, and that is the event the row acts on.

A close THROUGH the level is not a rejection. It is a breakout, it flips the level, and it
produces nothing. Breakout is always checked before rejection.

If one candle rejects several Fresh levels at once, the LOWEST is taken on the support side and
the HIGHEST on the resistance side - the level price actually reached.

[b]Step 2 - the reference line[/b]

The rejection candle's OPEN becomes the reference point. On the lower timeframe this lands on
the candle that opens at the same moment, and that candle is the first one examined. Nothing to
the left of it is ever looked at again.

[b]Step 3 - the touch candle[/b]

Moving forward from the reference point, the first lower timeframe candle that reaches the
rejected level is the touch candle. Reaching it is enough; it does not matter whether price
bounces or cuts through.

The touch candle splits the chart in two: everything left of it is External, everything right of
it is Internal.

[b]Step 4 - lock the level to be broken[/b]

On the External side, take the nearest level of the opposite kind:

  Buy side context    the nearest A Level to the left, for an upward break
  Sell side context   the nearest V Level to the left, for a downward break

It does not need to be Fresh. Any A or V will do. Only A and V are used here - Gap, RBS and SBR
are not.

[b]Step 5 - the breakout[/b]

On the Internal side, wait for a lower timeframe candle to CLOSE through the locked level.

  Close above the locked A Level    the row turns Bullish
  Close below the locked V Level    the row turns Bearish

A wick through it is not enough, and the touch candle can never confirm itself - the earliest a
row can turn is the candle after the touch.

There is no time limit on the wait.


[b]WHEN SEVERAL SETUPS ARE WAITING[/b]

Each open setup carries its own rejected level, its own reference line, its own touch candle and
its own locked level. They all run at the same time.

  Setup A   rejected 4050, waiting for a close below 4000
  Setup B   rejected 4040, waiting for a close below 4010

Price reaches 4010 first, so setup B turns the row Bearish. The instant that happens the row is
Bearish, and setup A never gets its turn.

A setup ends in one of three ways: it confirms, the higher timeframe closes through the level it
came from - which flips that level and makes the rejection meaningless - or it is pushed out by
the pending cap.


[b]TREND PERSISTENCE[/b]

Once a row is Bullish it stays Bullish until a Bearish confirmation completes, and the other way
round. There is no sideways or neutral state in between, and no expiry.

Before the very first confirmation on a symbol a row reads No Trend. After that it is always one
or the other.


[b]READING THE CHART[/b]

The dashboard

Five rows, each with a coloured dot, the timeframe name and its current trend. Hovering a row
name shows which lower timeframe confirms it. Rows can be hidden individually.

The setup visualiser

For the row you select, the chain that produced its current trend is drawn in the trend colour:

  a horizontal line the higher timeframe level that was rejected, labelled with the timeframe,
  the level type and its price, starting at the candle whose close created it.
  a vertical line the higher timeframe rejection candle.
  a vertical line the lower timeframe touch candle.
  a horizontal line the locked A or V level, labelled with its timeframe and price.
  a vertical line the lower timeframe candle that broke it.

If a setup is still waiting, it is drawn the same way in the opposite colour with dashed lines,
so you can see what the row is waiting for next. Everything can be switched off if you only want
the table.


[b]SETTINGS[/b]

[b]Dashboard Settings[/b]
- Table Position and Table Size.

[b]Engine Settings[/b]
- Max Stored Levels (per HTF): how many levels each timeframe keeps in memory. Older ones are
  forgotten, so a rejection from a very old level is only seen while it is still inside this
  window.
- Max Pending Setups (per side): how many setups may wait at once. When full, the oldest is
  dropped.
- History Depth (bars per timeframe): how far back each engine runs. Bars older than this are
  skipped, because the levels they create would have been pushed out of the level window long
  before reaching the present. Lower it if the script is slow on a heavy symbol.

[b]Dashboard Rows[/b]
- An individual switch for each of the five rows.

[b]Colors[/b]
- Bullish, Bearish and No Trend colours, used by both the table and the visualiser.

[b]Setup Visualiser[/b]
- Show Active Setup On Chart, the row to draw, and whether to also draw the setup still waiting.


[b]ALERTS[/b]

Ten alert conditions, one per row per direction:

Monthly Trend Bullish / Bearish, Weekly Trend Bullish / Bearish, Daily Trend Bullish / Bearish,
H4 Trend Bullish / Bearish, H1 Trend Bullish / Bearish.

Each fires only when a row actually FLIPS, not on every bar. Each message carries the row, the
direction, the symbol and the closing price. The same messages are sent through the alert
function, so the "Any alert() function call" alert type delivers every flip through one alert.

One thing worth knowing: an alert can only fire on a bar of the chart it was created on. If you
create it on a Weekly chart, a row that flips twice inside that week produces one alert, not two.
Create alerts on a chart timeframe at or below M15 and nothing is missed.


[b]REPAINTING[/b]

[b]The values do not repaint.[/b]

- Every engine reads confirmed candles only. It works on the previous, already closed candle of
  its own timeframe, so the candle still forming can never enter the calculation and cannot
  change what has already been decided.
- Each candle is processed exactly once. A timestamp guard makes a second pass over the same
  candle impossible.
- No request uses lookahead, so no calculation can see data that had not happened yet.
- A row's value changes only when a candle of the timeframe that decides it closes. Once a row
  has turned, that reading does not change afterwards.
- Because the calculation is independent of the chart, the table reads the same whichever
  timeframe you are on.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint.
That banner appears automatically for any script that requests data from other timeframes, no
matter how carefully it is done, because the platform cannot check the intent behind the request.


[b]NOTES AND LIMITATIONS[/b]

- Intended for intraday charts, roughly M1 up to H4. On Daily and higher, the M15 and M30
  requests have to cover a very long range and TradingView may refuse them with a memory  
  error on symbols with deep history. There is nothing to gain from a high chart timeframe  
  anyway, as the table reads the same everywhere.
- The far left of the chart reads No Trend. Each engine starts from a fixed depth, so it needs a
  stretch of candles before the first confirmation completes. This never affects the current
  reading.
- Levels older than the Max Stored Levels window are forgotten. A rejection from a very old
  level will not be seen once it has aged out.
- Detection is purely structural. It reports which way a timeframe has turned and why. It does
  not rank readings by quality, measure what happened afterwards, or produce entries, targets     
  or stops.


[b]HOW TO USE IT[/b]

Read the rows as a stack. When the slow rows agree, the market has one direction and the faster
rows tend to give pullbacks inside it. When they disagree, the faster rows are usually working
against the slower ones, and that is normally where the choppy trading is.

The visualiser is there so you never have to take a reading on faith. Point it at the row you
care about and the whole chain is on the chart: which level was rejected, when, where price
touched it, and exactly which level had to break. If a reading looks wrong, the drawing shows you
why it is what it is.

These are structural readings, not entry signals. Use them as direction and context alongside
your own levels, your own entry method and proper risk management.


[b]DISCLAIMER[/b]

This indicator is a market structure analysis tool. It is not financial advice and it makes no
claim about profitability. Trading involves risk. Always apply your own analysis and risk
management.

## Source Code

````pine
//@version=6
indicator("MSnR Classic StoryLine MTF", overlay=true, dynamic_requests=true, max_bars_back=1000, max_lines_count=100, max_labels_count=100)

// ==========================================================
// Multi-timeframe support/resistance trend dashboard.
//
// Each row pairs one Higher Time Frame with one Lower Time Frame. The HTF
// supplies the context: the most recent support/resistance level that price
// rejected. The LTF then confirms a direction from that context, and the
// result is reported as Bullish or Bearish for the HTF.
//
// HTF -> LTF pairs: M->D, W->H4, D->H1, H4->M30, H1->M15
//
// Nothing is plotted on the chart itself, so the dashboard reads the same
// on any chart timeframe.
// ==========================================================

// ==========================================
// 1. USER SETTINGS
// ==========================================
tablePosStr = input.string("Top Right", title="Table Position", options=["Top Right", "Middle Right", "Bottom Right"], group="Dashboard Settings")
tablePos = tablePosStr == "Top Right" ? position.top_right : tablePosStr == "Middle Right" ? position.middle_right : position.bottom_right

tableSizeStr = input.string("Normal", title="Table Size", options=["Tiny", "Small", "Normal", "Large"], group="Dashboard Settings")
tableSize = tableSizeStr == "Tiny" ? size.tiny : tableSizeStr == "Small" ? size.small : tableSizeStr == "Large" ? size.large : size.normal

maxLvls = input.int(300, title="Max Stored Levels (per HTF)", minval=50, maxval=500, group="Engine Settings",
     tooltip="How many levels each Higher Time Frame keeps in memory. Older levels are forgotten, so a rejection from a very old level is only seen while it is still inside this window.")

maxPending = input.int(12, title="Max Pending Setups (per side)", minval=3, maxval=20, group="Engine Settings",
     tooltip="Every HTF rejection opens a setup that waits for its Lower Time Frame confirmation, and they all run in parallel. This caps how many can wait at once; when the cap is reached the oldest one is dropped.")

historyDepth = input.int(3000, title="History Depth (bars per timeframe)", minval=500, maxval=10000, group="Engine Settings",
     tooltip="How far back each timeframe's engine runs. Bars older than this are skipped: the levels they create would be pushed out of the Max Stored Levels window long before reaching the present, so computing them is wasted work. Lower this if the script times out on a heavy symbol; raise it only if a slow timeframe reads No Trend for longer than you expect.")

groupRows = "Dashboard Rows"
showRowMonthly = input.bool(true, "Show Monthly Row", group=groupRows)
showRowWeekly  = input.bool(true, "Show Weekly Row",  group=groupRows)
showRowDaily   = input.bool(true, "Show Daily Row",   group=groupRows)
showRowH4      = input.bool(true, "Show H4 Row",      group=groupRows)
showRowH1      = input.bool(true, "Show H1 Row",      group=groupRows)

groupColors = "Colors"
bullColor    = input.color(color.rgb(16, 122, 52), "Bullish Color",  group=groupColors)
bearColor    = input.color(color.rgb(178, 34, 34), "Bearish Color",  group=groupColors)
neutralColor = input.color(color.gray,             "No Trend Color", group=groupColors)

groupDbg = "Setup Visualiser"
showSetup = input.bool(true, "Show Active Setup On Chart", group=groupDbg,
     tooltip="Draws the setup that produced the current trend for ONE row: the HTF level that was rejected, the vertical line on the rejection candle, the LTF touch candle, the locked A/V level and the candle that confirmed. Turn it off if you only want the dashboard.")
setupRow = input.string("H1", "Row To Show", options=["Monthly", "Weekly", "Daily", "H4", "H1"], group=groupDbg)
showWaiting = input.bool(true, "Also Show The Setup Still Waiting", group=groupDbg,
     tooltip="Draws the newest setup that has not confirmed yet, dashed. Shows what the row is currently waiting for.")

bgColor = color.new(#1e222d, 0)
headerBgColor = color.new(#000000, 0)
borderColor = color.new(#363a45, 0)

// Precision/tick safety
f_roundTick(float x) =>
    math.round(x / syminfo.mintick) * syminfo.mintick

// Level type codes. A level keeps its birth type until it is broken; every break
// flips it, and from then on it reads as SBR (resistance side) or RBS (support side).
TY_A       = 0
TY_V       = 1
TY_BULLGAP = 2
TY_BEARGAP = 3
TY_SBR     = 4
TY_RBS     = 5

f_typeName(int t) =>
    switch t
        TY_A       => "A Level"
        TY_V       => "V Level"
        TY_BULLGAP => "Bullish Gap"
        TY_BEARGAP => "Bearish Gap"
        TY_SBR     => "SBR"
        TY_RBS     => "RBS"
        => "Level"

// ==========================================
// 2. HTF LEVEL ENGINE
// Builds every level from a two-candle pair and tracks its state forward.
// Levels: V / Bullish Gap (support), A / Bearish Gap (resistance).
// Breakout (close beyond) -> side FLIP + Fresh again (= RBS / SBR).
// Rejection counts ONLY on a Fresh level (Fresh -> Unfresh transition).
// Creation bar is never checked (level is born Fresh, checks start next bar).
// ==========================================
f_htfEngine() =>
    var float[] lvlP = array.new_float()
    var int[]   lvlSide = array.new_int()    // 1 = support , -1 = resistance
    var bool[]  lvlFresh = array.new_bool()
    var int[]   lvlType = array.new_int()    // current type: A / V / Gap / SBR / RBS
    var int[]   lvlBirth = array.new_int()   // open time of the candle whose CLOSE set the level
    var float buyLvl = na                    // level of the newest buy-side rejection
    var float sellLvl = na                   // level of the newest sell-side rejection
    var int buyTy = na                       // its type, carried through for the visualiser
    var int sellTy = na
    var int buyBt = na                       // its birth candle, carried through for the visualiser
    var int sellBt = na
    var int buyId = 0                        // bumped once per new buy-side rejection
    var int sellId = 0
    var int buyT = na                        // open time of the HTF rejection candle (vertical line)
    var int sellT = na
    var float htfClose = na                  // close of the last completed HTF bar
    var int barId = 0                        // bumped once per completed HTF bar
    var int lastT = 0                        // open time of the last bar this engine processed

    // Only the recent slice of history is worth running. Measured in bar durations
    // of THIS context, so the window means the same number of bars on every timeframe.
    // Anchored to the LAST BAR, not to the wall clock, so bar replay slides the
    // window back with it instead of leaving every replayed bar outside it.
    bool inWindow = (last_bar_time - time[1]) <= historyDepth * timeframe.in_seconds() * 1000

    // The engine never looks at the bar that is still forming. It always works on
    // bar [1], which is already closed, so its values can never change underneath it.
    // barstate is deliberately not used here: inside request.security() it is not
    // reliable, and a forming bar slipping into the state machine corrupts it.
    // The time guard makes sure one bar is never processed twice.
    if inWindow and bar_index >= 2 and time[1] > lastT
        lastT := time[1]
        barId += 1
        htfClose := close[1]
        float tol = syminfo.mintick * 0.5
        float candBuy = na
        float candSell = na
        int candBuyTy = na
        int candSellTy = na
        int candBuyBt = na
        int candSellBt = na
        int n = array.size(lvlP)
        if n > 0
            for i = 0 to n - 1
                p = array.get(lvlP, i)
                s = array.get(lvlSide, i)
                f = array.get(lvlFresh, i)
                if s == 1
                    // Breakout has priority over rejection
                    if close[1] < p
                        array.set(lvlSide, i, -1)      // support -> resistance, Fresh again
                        array.set(lvlFresh, i, true)
                        array.set(lvlType, i, TY_SBR)  // it is an SBR from now on
                    else if f and low[1] <= p + tol and close[1] > p
                        array.set(lvlFresh, i, false)  // Fresh -> Unfresh = valid rejection event
                        if na(candBuy) or p < candBuy  // keep the lowest rejected buy-side level
                            candBuy := p
                            candBuyTy := array.get(lvlType, i)
                            candBuyBt := array.get(lvlBirth, i)
                else
                    if close[1] > p
                        array.set(lvlSide, i, 1)       // resistance -> support, Fresh again
                        array.set(lvlFresh, i, true)
                        array.set(lvlType, i, TY_RBS)  // it is an RBS from now on
                    else if f and high[1] >= p - tol and close[1] < p
                        array.set(lvlFresh, i, false)
                        if na(candSell) or p > candSell // keep the highest rejected sell-side level
                            candSell := p
                            candSellTy := array.get(lvlType, i)
                            candSellBt := array.get(lvlBirth, i)

        // Publish the rejection found on this bar. The id is what tells the LTF
        // engine that a brand new setup has to be opened.
        if not na(candBuy)
            buyLvl := candBuy
            buyTy := candBuyTy
            buyBt := candBuyBt
            buyId += 1
            buyT := time[1]
        if not na(candSell)
            sellLvl := candSell
            sellTy := candSellTy
            sellBt := candSellBt
            sellId += 1
            sellT := time[1]

        // Create the level from the 2-candle pair that completed on bar [1] (born Fresh)
        bool g  = close[1] > open[1]
        bool r  = close[1] < open[1]
        bool gP = close[2] > open[2]
        bool rP = close[2] < open[2]
        if rP and g                    // V Level (support)
            array.push(lvlP, f_roundTick(close[2])), array.push(lvlSide, 1),  array.push(lvlFresh, true), array.push(lvlType, TY_V),       array.push(lvlBirth, time[2])
        if gP and g                    // Bullish Gap (support)
            array.push(lvlP, f_roundTick(close[2])), array.push(lvlSide, 1),  array.push(lvlFresh, true), array.push(lvlType, TY_BULLGAP), array.push(lvlBirth, time[2])
        if gP and r                    // A Level (resistance)
            array.push(lvlP, f_roundTick(close[2])), array.push(lvlSide, -1), array.push(lvlFresh, true), array.push(lvlType, TY_A),       array.push(lvlBirth, time[2])
        if rP and r                    // Bearish Gap (resistance)
            array.push(lvlP, f_roundTick(close[2])), array.push(lvlSide, -1), array.push(lvlFresh, true), array.push(lvlType, TY_BEARGAP), array.push(lvlBirth, time[2])

        // Cap memory
        while array.size(lvlP) > maxLvls
            array.remove(lvlP, 0)
            array.remove(lvlSide, 0)
            array.remove(lvlFresh, 0)
            array.remove(lvlType, 0)
            array.remove(lvlBirth, 0)

    [buyLvl, buyId, buyT, buyTy, buyBt, sellLvl, sellId, sellT, sellTy, sellBt, htfClose, barId]

// ==========================================
// 3. LTF TREND ENGINE
// Every HTF rejection opens a SETUP. A setup waits for its first touch of the
// rejected level, locks the nearest A/V level sitting to the LEFT of that touch
// (External side), and confirms when a later close breaks the locked level
// (Internal side).
//
// Setups run in PARALLEL: a newer rejection never cancels an older one, so
// whichever setup breaks out first is the one that turns the trend. A setup ends
// only when it confirms, or when the HTF itself closes through the level it came
// from, or when it is pushed out by the pending cap.
//
// Only the side opposite the current trend is hunted. While the trend is Bullish
// there is nothing to gain from another Bullish confirmation, so only sell-side
// setups are tracked, and the other way round. Trend persists until the opposite
// side confirms, so there is no Sideway state.
// ==========================================
f_ltfEngine(float buyLvl, int buyId, int buyT, int buyTy, int buyBt, float sellLvl, int sellId, int sellT, int sellTy, int sellBt, float htfClose, int htfBarId) =>
    var float  recentA    = na   // nearest completed A level (external side)
    var int    recentAT   = na   // open time of the candle whose CLOSE set recentA
    var float  recentV    = na   // nearest completed V level (external side)
    var int    recentVT   = na
    var string trend      = "No Trend"
    var int    lastBuyId  = 0
    var int    lastSellId = 0
    var int    lastHtfBar = 0
    var int    lastT      = 0   // open time of the last bar this engine processed

    // The story of the setup that produced the CURRENT trend, kept only so the
    // chart can draw it. None of it feeds back into the detection.
    var float cLvl   = na        // HTF level that was rejected
    var int   cTy    = na        // that level's type (A / V / Gap / SBR / RBS)
    var int   cBt    = na        // the candle whose CLOSE created that level
    var int   cRejT  = na        // open time of the HTF rejection candle
    var int   cTchT  = na        // open time of the LTF touch candle
    var float cLock  = na        // locked External A / V level
    var int   cLockT = na        // the candle whose CLOSE created the locked level
    var int   cConfT = na        // open time of the LTF candle that confirmed
    // Same for the newest setup that is still waiting
    var float wLvl   = na
    var int   wTy    = na
    var int   wBt    = na
    var int   wRejT  = na
    var int   wTchT  = na
    var float wLock  = na
    var int   wLockT = na

    // Rolling window of recent closed LTF bars.
    // Needed because the HTF rejection is only knowable at the HTF candle CLOSE,
    // while the LTF touch has to be searched from the HTF candle OPEN onwards.
    // So when a new rejection arrives, we REPLAY the already-closed LTF bars of that HTF candle.
    var int[]   tW = array.new_int()
    var float[] hW = array.new_float()
    var float[] lW = array.new_float()
    var float[] cW = array.new_float()
    var float[] aW  = array.new_float()  // nearest A level as of that bar
    var int[]   atW = array.new_int()    // birth candle of that A level
    var float[] vW  = array.new_float()  // nearest V level as of that bar
    var int[]   vtW = array.new_int()    // birth candle of that V level

    // Pending setups, parallel arrays per side.
    var float[] pbLvl   = array.new_float()  // buy side: the HTF level that was rejected
    var int[]   pbTy    = array.new_int()    // buy side: that level's type
    var int[]   pbBt    = array.new_int()    // buy side: the candle whose CLOSE created it
    var int[]   pbT     = array.new_int()    // buy side: open time of the HTF rejection candle
    var bool[]  pbTouch = array.new_bool()   // buy side: has the LTF touched that level yet
    var int[]   pbTchT  = array.new_int()    // buy side: open time of the touch candle
    var float[] pbLock  = array.new_float()  // buy side: locked External A level
    var int[]   pbLockT = array.new_int()    // buy side: birth candle of that locked level
    var float[] psLvl   = array.new_float()  // sell side, same eight
    var int[]   psTy    = array.new_int()
    var int[]   psBt    = array.new_int()
    var int[]   psT     = array.new_int()
    var bool[]  psTouch = array.new_bool()
    var int[]   psTchT  = array.new_int()
    var float[] psLock  = array.new_float()
    var int[]   psLockT = array.new_int()

    // Same history window as the HTF engine, also anchored to the last bar.
    bool inWindow = (last_bar_time - time[1]) <= historyDepth * timeframe.in_seconds() * 1000

    // Like the HTF engine, this one only ever reads bar [1], which is already closed.
    // No barstate, and the time guard stops a bar being processed more than once.
    if inWindow and bar_index >= 2 and time[1] > lastT
        lastT := time[1]
        float tol = syminfo.mintick * 0.5

        // ---- 0. Record the A / V level bar [1] completes with the one before it.
        // Done FIRST so the touch candle can lock a level whose price candle sits
        // immediately to its left, even though the pair only closes on the touch itself.
        bool g  = close[1] > open[1]
        bool r  = close[1] < open[1]
        bool gP = close[2] > open[2]
        bool rP = close[2] < open[2]
        if gP and r
            recentA := f_roundTick(close[2])
            recentAT := time[2]
        if rP and g
            recentV := f_roundTick(close[2])
            recentVT := time[2]

        // ---- 1. Store bar [1] in the window
        array.push(tW, time[1])
        array.push(hW, high[1])
        array.push(lW, low[1])
        array.push(cW, close[1])
        array.push(aW, recentA)
        array.push(atW, recentAT)
        array.push(vW, recentV)
        array.push(vtW, recentVT)
        while array.size(tW) > 200
            array.remove(tW, 0)
            array.remove(hW, 0)
            array.remove(lW, 0)
            array.remove(cW, 0)
            array.remove(aW, 0)
            array.remove(atW, 0)
            array.remove(vW, 0)
            array.remove(vtW, 0)
        int n = array.size(tW)

        // ---- 2. A new HTF bar closed. Drop every setup whose level that close went
        // through: once the level breaks it flips side and turns Fresh again, so the
        // rejection it produced no longer means anything.
        if htfBarId != lastHtfBar
            lastHtfBar := htfBarId
            if not na(htfClose)
                int nb0 = array.size(pbLvl)
                if nb0 > 0
                    for i = nb0 - 1 to 0
                        if htfClose < array.get(pbLvl, i)
                            array.remove(pbLvl, i), array.remove(pbTy, i), array.remove(pbBt, i), array.remove(pbT, i), array.remove(pbTouch, i), array.remove(pbTchT, i), array.remove(pbLock, i), array.remove(pbLockT, i)
                int ns0 = array.size(psLvl)
                if ns0 > 0
                    for i = ns0 - 1 to 0
                        if htfClose > array.get(psLvl, i)
                            array.remove(psLvl, i), array.remove(psTy, i), array.remove(psBt, i), array.remove(psT, i), array.remove(psTouch, i), array.remove(psTchT, i), array.remove(psLock, i), array.remove(psLockT, i)

        // ---- 3. A new HTF rejection opens a setup. BOTH sides are always tracked,
        // even the one that matches the current trend: a single HTF candle can reject
        // a resistance and a support at once, and the second one is what turns the
        // trend back later. Dropping it would lose that flip entirely.
        int  newBuyIdx  = -1
        int  newSellIdx = -1

        if buyId != lastBuyId
            lastBuyId := buyId
            if not na(buyLvl) and not na(buyT)
                array.push(pbLvl, buyLvl), array.push(pbTy, buyTy), array.push(pbBt, buyBt), array.push(pbT, buyT), array.push(pbTouch, false), array.push(pbTchT, na), array.push(pbLock, na), array.push(pbLockT, na)
                while array.size(pbLvl) > maxPending
                    array.remove(pbLvl, 0), array.remove(pbTy, 0), array.remove(pbBt, 0), array.remove(pbT, 0), array.remove(pbTouch, 0), array.remove(pbTchT, 0), array.remove(pbLock, 0), array.remove(pbLockT, 0)
                newBuyIdx := array.size(pbLvl) - 1
        if sellId != lastSellId
            lastSellId := sellId
            if not na(sellLvl) and not na(sellT)
                array.push(psLvl, sellLvl), array.push(psTy, sellTy), array.push(psBt, sellBt), array.push(psT, sellT), array.push(psTouch, false), array.push(psTchT, na), array.push(psLock, na), array.push(psLockT, na)
                while array.size(psLvl) > maxPending
                    array.remove(psLvl, 0), array.remove(psTy, 0), array.remove(psBt, 0), array.remove(psT, 0), array.remove(psTouch, 0), array.remove(psTchT, 0), array.remove(psLock, 0), array.remove(psLockT, 0)
                newSellIdx := array.size(psLvl) - 1

        // ---- 4. Advance every pending setup.
        // A setup opened on this bar REPLAYS the window from its own vertical line;
        // the others only need the bar that has just closed. Touch and confirmation
        // can never land on the same bar, so a setup is never judged by its own touch.
        int buyConfIdx  = na
        int sellConfIdx = na
        // Story of the winning setup on each side, copied out before it is swept
        float bcLvl   = na
        float bcLock  = na
        int   bcTy    = na
        int   bcBt    = na
        int   bcRejT  = na
        int   bcTchT  = na
        int   bcLockT = na
        int   bcConfT = na
        float scLvl   = na
        float scLock  = na
        int   scTy    = na
        int   scBt    = na
        int   scRejT  = na
        int   scTchT  = na
        int   scLockT = na
        int   scConfT = na

        int nb = array.size(pbLvl)
        if nb > 0
            for i = 0 to nb - 1
                float lvl = array.get(pbLvl, i)
                if not na(lvl)
                    int   t0    = array.get(pbT, i)
                    bool  tc    = array.get(pbTouch, i)
                    int   tt    = array.get(pbTchT, i)
                    float lk    = array.get(pbLock, i)
                    int   lkT   = array.get(pbLockT, i)
                    bool  fired = false
                    int   start = i == newBuyIdx ? 0 : n - 1
                    for j = start to n - 1
                        if array.get(tW, j) >= t0
                            if not tc
                                if array.get(lW, j) <= lvl + tol
                                    tc := true
                                    tt := array.get(tW, j)
                                    lk := array.get(aW, j)
                                    lkT := array.get(atW, j)
                            else if not na(lk) and array.get(cW, j) > lk
                                // The EARLIEST breakout is the one that counts: the moment it
                                // fires the trend turns and every other buy setup is released,
                                // so a later one never gets its chance. On a tie the newer
                                // setup wins, since it came from the more recent rejection.
                                if na(buyConfIdx) or j <= buyConfIdx
                                    buyConfIdx := j
                                    bcLvl  := lvl
                                    bcTy   := array.get(pbTy, i)
                                    bcBt   := array.get(pbBt, i)
                                    bcRejT := t0
                                    bcTchT := tt
                                    bcLock := lk
                                    bcLockT := lkT
                                    bcConfT := array.get(tW, j)
                                fired := true
                                break
                    array.set(pbTouch, i, tc)
                    array.set(pbTchT, i, tt)
                    array.set(pbLock, i, lk)
                    array.set(pbLockT, i, lkT)
                    if fired
                        array.set(pbLvl, i, na)   // marked, swept below

        int ns = array.size(psLvl)
        if ns > 0
            for i = 0 to ns - 1
                float sLvl = array.get(psLvl, i)
                if not na(sLvl)
                    int   sT0    = array.get(psT, i)
                    bool  sTc    = array.get(psTouch, i)
                    int   sTt    = array.get(psTchT, i)
                    float sLk    = array.get(psLock, i)
                    int   sLkT   = array.get(psLockT, i)
                    bool  sFired = false
                    int   sStart = i == newSellIdx ? 0 : n - 1
                    for j = sStart to n - 1
                        if array.get(tW, j) >= sT0
                            if not sTc
                                if array.get(hW, j) >= sLvl - tol
                                    sTc := true
                                    sTt := array.get(tW, j)
                                    sLk := array.get(vW, j)
                                    sLkT := array.get(vtW, j)
                            else if not na(sLk) and array.get(cW, j) < sLk
                                // Same rule on the sell side: earliest breakout wins,
                                // newer setup wins a tie.
                                if na(sellConfIdx) or j <= sellConfIdx
                                    sellConfIdx := j
                                    scLvl  := sLvl
                                    scTy   := array.get(psTy, i)
                                    scBt   := array.get(psBt, i)
                                    scRejT := sT0
                                    scTchT := sTt
                                    scLock := sLk
                                    scLockT := sLkT
                                    scConfT := array.get(tW, j)
                                sFired := true
                                break
                    array.set(psTouch, i, sTc)
                    array.set(psTchT, i, sTt)
                    array.set(psLock, i, sLk)
                    array.set(psLockT, i, sLkT)
                    if sFired
                        array.set(psLvl, i, na)

        // Sweep out the setups that fired - a setup confirms once and is then done.
        int nb1 = array.size(pbLvl)
        if nb1 > 0
            for i = nb1 - 1 to 0
                if na(array.get(pbLvl, i))
                    array.remove(pbLvl, i), array.remove(pbTy, i), array.remove(pbBt, i), array.remove(pbT, i), array.remove(pbTouch, i), array.remove(pbTchT, i), array.remove(pbLock, i), array.remove(pbLockT, i)
        int ns1 = array.size(psLvl)
        if ns1 > 0
            for i = ns1 - 1 to 0
                if na(array.get(psLvl, i))
                    array.remove(psLvl, i), array.remove(psTy, i), array.remove(psBt, i), array.remove(psT, i), array.remove(psTouch, i), array.remove(psTchT, i), array.remove(psLock, i), array.remove(psLockT, i)

        // ---- 5. Apply confirmations chronologically (the LATER one is the final trend).
        // Both-side case: whichever completes first decides; a later opposite
        // completion flips the trend, because trend persists until the opposite confirms.
        bool buyWon  = false
        bool sellWon = false
        if not na(buyConfIdx) and not na(sellConfIdx)
            buyWon  := buyConfIdx > sellConfIdx
            sellWon := not buyWon
        else if not na(buyConfIdx)
            buyWon := true
        else if not na(sellConfIdx)
            sellWon := true

        if buyWon
            trend := "Bullish"
            cLvl := bcLvl, cTy := bcTy, cBt := bcBt, cRejT := bcRejT
            cTchT := bcTchT, cLock := bcLock, cLockT := bcLockT, cConfT := bcConfT
        else if sellWon
            trend := "Bearish"
            cLvl := scLvl, cTy := scTy, cBt := scBt, cRejT := scRejT
            cTchT := scTchT, cLock := scLock, cLockT := scLockT, cConfT := scConfT

        // Nothing is released here. A setup leaves only when it confirms, when the HTF
        // closes through the level it came from, or when the pending cap pushes it out.
        // A confirmation that matches the trend already running simply leaves it as is.

        // Snapshot of the newest setup still waiting, purely for the chart.
        wLvl := na, wTy := na, wBt := na, wRejT := na, wTchT := na, wLock := na, wLockT := na
        int kb = array.size(pbLvl) - 1
        int ks = array.size(psLvl) - 1
        int pick = trend == "Bearish" ? kb : trend == "Bullish" ? ks : (kb >= 0 ? kb : ks)
        bool pickBuy = trend == "Bearish" or (trend == "No Trend" and kb >= 0)
        if pick >= 0
            if pickBuy
                wLvl := array.get(pbLvl, pick), wTy := array.get(pbTy, pick), wBt := array.get(pbBt, pick), wRejT := array.get(pbT, pick)
                wTchT := array.get(pbTchT, pick), wLock := array.get(pbLock, pick), wLockT := array.get(pbLockT, pick)
            else
                wLvl := array.get(psLvl, pick), wTy := array.get(psTy, pick), wBt := array.get(psBt, pick), wRejT := array.get(psT, pick)
                wTchT := array.get(psTchT, pick), wLock := array.get(psLock, pick), wLockT := array.get(psLockT, pick)

    [trend, cLvl, cTy, cBt, cRejT, cTchT, cLock, cLockT, cConfT, wLvl, wTy, wBt, wRejT, wTchT, wLock, wLockT]

// ==========================================
// 4. MULTI-TIMEFRAME PROCESSOR
// HTF -> LTF pairs: M->D, W->H4, D->H1, H4->M30, H1->M15
// Every engine advances only on confirmed bars of the timeframe it is asked
// for, and no request uses lookahead, so the dashboard reads only the CURRENT
// state and any chart timeframe gives the same answer.
// ==========================================
[mBuyLvl,   mBuyId,   mBuyT,   mBuyTy,   mBuyBt,   mSellLvl,   mSellId,   mSellT,   mSellTy,   mSellBt,   mClose,   mBar  ] = request.security(syminfo.tickerid, "M",   f_htfEngine(), lookahead=barmerge.lookahead_off)
[wBuyLvl,   wBuyId,   wBuyT,   wBuyTy,   wBuyBt,   wSellLvl,   wSellId,   wSellT,   wSellTy,   wSellBt,   wClose,   wBar  ] = request.security(syminfo.tickerid, "W",   f_htfEngine(), lookahead=barmerge.lookahead_off)
[dBuyLvl,   dBuyId,   dBuyT,   dBuyTy,   dBuyBt,   dSellLvl,   dSellId,   dSellT,   dSellTy,   dSellBt,   dClose,   dBar  ] = request.security(syminfo.tickerid, "D",   f_htfEngine(), lookahead=barmerge.lookahead_off)
[h4BuyLvl,  h4BuyId,  h4BuyT,  h4BuyTy,  h4BuyBt,  h4SellLvl,  h4SellId,  h4SellT,  h4SellTy,  h4SellBt,  h4Close,  h4Bar ] = request.security(syminfo.tickerid, "240", f_htfEngine(), lookahead=barmerge.lookahead_off)
[h1BuyLvl,  h1BuyId,  h1BuyT,  h1BuyTy,  h1BuyBt,  h1SellLvl,  h1SellId,  h1SellT,  h1SellTy,  h1SellBt,  h1Close,  h1Bar ] = request.security(syminfo.tickerid, "60",  f_htfEngine(), lookahead=barmerge.lookahead_off)

[monthlyTrend, moCLvl, moCTy, moCBt, moCRejT, moCTchT, moCLock, moCLockT, moCConfT, moWLvl, moWTy, moWBt, moWRejT, moWTchT, moWLock, moWLockT] = request.security(syminfo.tickerid, "D",   f_ltfEngine(mBuyLvl,   mBuyId,   mBuyT,   mBuyTy,   mBuyBt,   mSellLvl,   mSellId,   mSellT,   mSellTy,   mSellBt,   mClose,   mBar),   lookahead=barmerge.lookahead_off)
[weeklyTrend,  wkCLvl, wkCTy, wkCBt, wkCRejT, wkCTchT, wkCLock, wkCLockT, wkCConfT, wkWLvl, wkWTy, wkWBt, wkWRejT, wkWTchT, wkWLock, wkWLockT] = request.security(syminfo.tickerid, "240", f_ltfEngine(wBuyLvl,   wBuyId,   wBuyT,   wBuyTy,   wBuyBt,   wSellLvl,   wSellId,   wSellT,   wSellTy,   wSellBt,   wClose,   wBar),   lookahead=barmerge.lookahead_off)
[dailyTrend,   dyCLvl, dyCTy, dyCBt, dyCRejT, dyCTchT, dyCLock, dyCLockT, dyCConfT, dyWLvl, dyWTy, dyWBt, dyWRejT, dyWTchT, dyWLock, dyWLockT] = request.security(syminfo.tickerid, "60",  f_ltfEngine(dBuyLvl,   dBuyId,   dBuyT,   dBuyTy,   dBuyBt,   dSellLvl,   dSellId,   dSellT,   dSellTy,   dSellBt,   dClose,   dBar),   lookahead=barmerge.lookahead_off)
[h4Trend,      h4CLvl, h4CTy, h4CBt, h4CRejT, h4CTchT, h4CLock, h4CLockT, h4CConfT, h4WLvl, h4WTy, h4WBt, h4WRejT, h4WTchT, h4WLock, h4WLockT] = request.security(syminfo.tickerid, "30",  f_ltfEngine(h4BuyLvl,  h4BuyId,  h4BuyT,  h4BuyTy,  h4BuyBt,  h4SellLvl,  h4SellId,  h4SellT,  h4SellTy,  h4SellBt,  h4Close,  h4Bar),  lookahead=barmerge.lookahead_off)
[h1Trend,      h1CLvl, h1CTy, h1CBt, h1CRejT, h1CTchT, h1CLock, h1CLockT, h1CConfT, h1WLvl, h1WTy, h1WBt, h1WRejT, h1WTchT, h1WLock, h1WLockT] = request.security(syminfo.tickerid, "15",  f_ltfEngine(h1BuyLvl,  h1BuyId,  h1BuyT,  h1BuyTy,  h1BuyBt,  h1SellLvl,  h1SellId,  h1SellT,  h1SellTy,  h1SellBt,  h1Close,  h1Bar),  lookahead=barmerge.lookahead_off)

// ==========================================
// 5. DASHBOARD TABLE
// ==========================================
var table trendTable = table.new(tablePos, 3, 6, border_width=1, border_color=borderColor)

getTrendColor(trendStr) =>
    trendStr == "Bullish" ? bullColor : trendStr == "Bearish" ? bearColor : neutralColor

setCell(row, col, txt, bgColorCell, txtColor, tip) =>
    table.cell(trendTable, col, row, txt, bgcolor=bgColorCell, text_color=txtColor, text_size=tableSize, text_halign=text.align_center, text_valign=text.align_center, tooltip=tip)

if barstate.islast
    table.clear(trendTable, 0, 0, 2, 5)
    setCell(0, 0, "",          headerBgColor, color.white, "")
    setCell(0, 1, "Timeframe", headerBgColor, color.white, "")
    setCell(0, 2, "Trend",     headerBgColor, color.white, "")

    int r = 1
    if showRowMonthly
        setCell(r, 0, "●",       bgColor, getTrendColor(monthlyTrend), "")
        setCell(r, 1, "Monthly", bgColor, color.white, "Confirmed on D1")
        setCell(r, 2, monthlyTrend, bgColor, getTrendColor(monthlyTrend), "")
        r += 1
    if showRowWeekly
        setCell(r, 0, "●",      bgColor, getTrendColor(weeklyTrend), "")
        setCell(r, 1, "Weekly", bgColor, color.white, "Confirmed on H4")
        setCell(r, 2, weeklyTrend, bgColor, getTrendColor(weeklyTrend), "")
        r += 1
    if showRowDaily
        setCell(r, 0, "●",     bgColor, getTrendColor(dailyTrend), "")
        setCell(r, 1, "Daily", bgColor, color.white, "Confirmed on H1")
        setCell(r, 2, dailyTrend, bgColor, getTrendColor(dailyTrend), "")
        r += 1
    if showRowH4
        setCell(r, 0, "●",  bgColor, getTrendColor(h4Trend), "")
        setCell(r, 1, "H4", bgColor, color.white, "Confirmed on M30")
        setCell(r, 2, h4Trend, bgColor, getTrendColor(h4Trend), "")
        r += 1
    if showRowH1
        setCell(r, 0, "●",  bgColor, getTrendColor(h1Trend), "")
        setCell(r, 1, "H1", bgColor, color.white, "Confirmed on M15")
        setCell(r, 2, h1Trend, bgColor, getTrendColor(h1Trend), "")
        r += 1

// ==========================================
// 6. SETUP VISUALISER
// Draws, for ONE chosen row, the setup that produced its current trend and the
// setup it is waiting on next. Nothing here feeds back into the detection - it
// only makes the engine's own reasoning visible on the chart.
// ==========================================
selTrend = setupRow == "Monthly" ? monthlyTrend : setupRow == "Weekly" ? weeklyTrend : setupRow == "Daily" ? dailyTrend : setupRow == "H4" ? h4Trend : h1Trend

selCLvl   = setupRow == "Monthly" ? moCLvl   : setupRow == "Weekly" ? wkCLvl   : setupRow == "Daily" ? dyCLvl   : setupRow == "H4" ? h4CLvl   : h1CLvl
selCTy    = setupRow == "Monthly" ? moCTy    : setupRow == "Weekly" ? wkCTy    : setupRow == "Daily" ? dyCTy    : setupRow == "H4" ? h4CTy    : h1CTy
selCBt    = setupRow == "Monthly" ? moCBt    : setupRow == "Weekly" ? wkCBt    : setupRow == "Daily" ? dyCBt    : setupRow == "H4" ? h4CBt    : h1CBt
selCRejT  = setupRow == "Monthly" ? moCRejT  : setupRow == "Weekly" ? wkCRejT  : setupRow == "Daily" ? dyCRejT  : setupRow == "H4" ? h4CRejT  : h1CRejT
selCTchT  = setupRow == "Monthly" ? moCTchT  : setupRow == "Weekly" ? wkCTchT  : setupRow == "Daily" ? dyCTchT  : setupRow == "H4" ? h4CTchT  : h1CTchT
selCLock  = setupRow == "Monthly" ? moCLock  : setupRow == "Weekly" ? wkCLock  : setupRow == "Daily" ? dyCLock  : setupRow == "H4" ? h4CLock  : h1CLock
selCLockT = setupRow == "Monthly" ? moCLockT : setupRow == "Weekly" ? wkCLockT : setupRow == "Daily" ? dyCLockT : setupRow == "H4" ? h4CLockT : h1CLockT
selCConfT = setupRow == "Monthly" ? moCConfT : setupRow == "Weekly" ? wkCConfT : setupRow == "Daily" ? dyCConfT : setupRow == "H4" ? h4CConfT : h1CConfT

selWLvl   = setupRow == "Monthly" ? moWLvl   : setupRow == "Weekly" ? wkWLvl   : setupRow == "Daily" ? dyWLvl   : setupRow == "H4" ? h4WLvl   : h1WLvl
selWTy    = setupRow == "Monthly" ? moWTy    : setupRow == "Weekly" ? wkWTy    : setupRow == "Daily" ? dyWTy    : setupRow == "H4" ? h4WTy    : h1WTy
selWBt    = setupRow == "Monthly" ? moWBt    : setupRow == "Weekly" ? wkWBt    : setupRow == "Daily" ? dyWBt    : setupRow == "H4" ? h4WBt    : h1WBt
selWRejT  = setupRow == "Monthly" ? moWRejT  : setupRow == "Weekly" ? wkWRejT  : setupRow == "Daily" ? dyWRejT  : setupRow == "H4" ? h4WRejT  : h1WRejT
selWTchT  = setupRow == "Monthly" ? moWTchT  : setupRow == "Weekly" ? wkWTchT  : setupRow == "Daily" ? dyWTchT  : setupRow == "H4" ? h4WTchT  : h1WTchT
selWLock  = setupRow == "Monthly" ? moWLock  : setupRow == "Weekly" ? wkWLock  : setupRow == "Daily" ? dyWLock  : setupRow == "H4" ? h4WLock  : h1WLock
selWLockT = setupRow == "Monthly" ? moWLockT : setupRow == "Weekly" ? wkWLockT : setupRow == "Daily" ? dyWLockT : setupRow == "H4" ? h4WLockT : h1WLockT

// Names used in the labels, so it is always obvious which timeframe a line came from.
htfName = setupRow
ltfName = setupRow == "Monthly" ? "D1" : setupRow == "Weekly" ? "H4" : setupRow == "Daily" ? "H1" : setupRow == "H4" ? "M30" : "M15"

var line[]  dbgLines  = array.new_line()
var label[] dbgLabels = array.new_label()

f_dbgClear() =>
    int nl = array.size(dbgLines)
    if nl > 0
        for i = 0 to nl - 1
            line ln = array.get(dbgLines, i)
            if not na(ln)
                line.delete(ln)
        array.clear(dbgLines)
    int nb = array.size(dbgLabels)
    if nb > 0
        for i = 0 to nb - 1
            label lb = array.get(dbgLabels, i)
            if not na(lb)
                label.delete(lb)
        array.clear(dbgLabels)

// Horizontal level, starting at the bar whose CLOSE created it and running to the right.
f_dbgHLine(int t1, float p, color c, string st, string txt) =>
    if not na(t1) and not na(p)
        line ln = line.new(x1 = t1, y1 = p, x2 = time, y2 = p, xloc = xloc.bar_time,
             extend = extend.right, color = c, width = 2, style = st)
        array.push(dbgLines, ln)
        label lb = label.new(x = time, y = p, xloc = xloc.bar_time,
             text = txt + "  " + str.tostring(p, format.mintick),
             style = label.style_label_left, color = c, textcolor = color.white, size = size.small)
        array.push(dbgLabels, lb)

// Vertical marker on one candle.
f_dbgVLine(int t, color c, string st, string txt) =>
    if not na(t)
        line ln = line.new(x1 = t, y1 = low, x2 = t, y2 = high, xloc = xloc.bar_time,
             extend = extend.both, color = c, width = 1, style = st)
        array.push(dbgLines, ln)
        label lb = label.new(x = t, y = high, xloc = xloc.bar_time, text = txt,
             style = label.style_label_down, color = c, textcolor = color.white, size = size.small)
        array.push(dbgLabels, lb)

if barstate.islast
    f_dbgClear()
    if showSetup
        // Solid = the setup that produced the trend now on the dashboard.
        // A Bullish trend came from a buy-side setup, so its locked level is an A Level.
        color cCol = selTrend == "Bullish" ? bullColor : selTrend == "Bearish" ? bearColor : neutralColor
        string cLockName = selTrend == "Bullish" ? "A" : "V"
        // Each horizontal line starts on the candle whose CLOSE created that level.
        f_dbgHLine(selCBt,    selCLvl,  cCol, line.style_solid, htfName + " " + f_typeName(selCTy))
        f_dbgVLine(selCRejT,  cCol, line.style_solid, htfName + " Rejection")
        f_dbgVLine(selCTchT,  cCol, line.style_solid, ltfName + " Touch")
        f_dbgHLine(selCLockT, selCLock, cCol, line.style_solid, "Locked " + ltfName + " " + cLockName)
        f_dbgVLine(selCConfT, cCol, line.style_solid, ltfName + " Breakout")

        // Dashed = the setup still waiting, which runs on the opposite side.
        if showWaiting
            color  wCol = selTrend == "Bullish" ? bearColor : bullColor
            string wLockName = selTrend == "Bullish" ? "V" : "A"
            f_dbgHLine(selWBt,    selWLvl,  wCol, line.style_dashed, "Waiting " + htfName + " " + f_typeName(selWTy))
            f_dbgVLine(selWRejT,  wCol, line.style_dashed, "Waiting " + htfName + " Rejection")
            f_dbgVLine(selWTchT,  wCol, line.style_dashed, "Waiting " + ltfName + " Touch")
            f_dbgHLine(selWLockT, selWLock, wCol, line.style_dashed, "Waiting Lock " + ltfName + " " + wLockName)

// ==========================================
// 7. ALERTS (trend flip only - Bullish / Bearish)
// ==========================================
mFlipBull   = monthlyTrend == "Bullish" and monthlyTrend[1] != "Bullish"
mFlipBear   = monthlyTrend == "Bearish" and monthlyTrend[1] != "Bearish"
wFlipBull   = weeklyTrend  == "Bullish" and weeklyTrend[1]  != "Bullish"
wFlipBear   = weeklyTrend  == "Bearish" and weeklyTrend[1]  != "Bearish"
dFlipBull   = dailyTrend   == "Bullish" and dailyTrend[1]   != "Bullish"
dFlipBear   = dailyTrend   == "Bearish" and dailyTrend[1]   != "Bearish"
h4FlipBull  = h4Trend      == "Bullish" and h4Trend[1]      != "Bullish"
h4FlipBear  = h4Trend      == "Bearish" and h4Trend[1]      != "Bearish"
h1FlipBull  = h1Trend      == "Bullish" and h1Trend[1]      != "Bullish"
h1FlipBear  = h1Trend      == "Bearish" and h1Trend[1]      != "Bearish"

alertcondition(mFlipBull,   title="Monthly Trend Bullish", message="Monthly Trend -> Bullish | {{ticker}} | Close {{close}}")
alertcondition(mFlipBear,   title="Monthly Trend Bearish", message="Monthly Trend -> Bearish | {{ticker}} | Close {{close}}")
alertcondition(wFlipBull,   title="Weekly Trend Bullish",  message="Weekly Trend -> Bullish | {{ticker}} | Close {{close}}")
alertcondition(wFlipBear,   title="Weekly Trend Bearish",  message="Weekly Trend -> Bearish | {{ticker}} | Close {{close}}")
alertcondition(dFlipBull,   title="Daily Trend Bullish",   message="Daily Trend -> Bullish | {{ticker}} | Close {{close}}")
alertcondition(dFlipBear,   title="Daily Trend Bearish",   message="Daily Trend -> Bearish | {{ticker}} | Close {{close}}")
alertcondition(h4FlipBull,  title="H4 Trend Bullish",      message="H4 Trend -> Bullish | {{ticker}} | Close {{close}}")
alertcondition(h4FlipBear,  title="H4 Trend Bearish",      message="H4 Trend -> Bearish | {{ticker}} | Close {{close}}")
alertcondition(h1FlipBull,  title="H1 Trend Bullish",      message="H1 Trend -> Bullish | {{ticker}} | Close {{close}}")
alertcondition(h1FlipBear,  title="H1 Trend Bearish",      message="H1 Trend -> Bearish | {{ticker}} | Close {{close}}")

// Dynamic message for the "Any alert() function call" alert type.
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " | Close " + str.tostring(close, format.mintick)

if mFlipBull
    alert(alertMsg("Monthly Trend -> Bullish"), alert.freq_once_per_bar)
if mFlipBear
    alert(alertMsg("Monthly Trend -> Bearish"), alert.freq_once_per_bar)
if wFlipBull
    alert(alertMsg("Weekly Trend -> Bullish"), alert.freq_once_per_bar)
if wFlipBear
    alert(alertMsg("Weekly Trend -> Bearish"), alert.freq_once_per_bar)
if dFlipBull
    alert(alertMsg("Daily Trend -> Bullish"), alert.freq_once_per_bar)
if dFlipBear
    alert(alertMsg("Daily Trend -> Bearish"), alert.freq_once_per_bar)
if h4FlipBull
    alert(alertMsg("H4 Trend -> Bullish"), alert.freq_once_per_bar)
if h4FlipBear
    alert(alertMsg("H4 Trend -> Bearish"), alert.freq_once_per_bar)
if h1FlipBull
    alert(alertMsg("H1 Trend -> Bullish"), alert.freq_once_per_bar)
if h1FlipBear
    alert(alertMsg("H1 Trend -> Bearish"), alert.freq_once_per_bar)
````
