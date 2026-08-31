<!-- tradingview-pine-id: PUB;d1acb625309f493c90fa5061fb8a309d -->
<!-- tradingviewscripts-format: 1 -->
# Atlas Candle Volume Engine V1.1 (Export)

Source: https://www.tradingview.com/script/cDaQA7KT-Atlas-Candle-Volume-Engine/

## Description

Atlas Candle Volume Engine

Read the candle. Measure the participation. Understand the move.

The Atlas Candle Volume Engine is a multi-timeframe candle and volume analysis tool designed to answer one fundamental question:

Is price moving with meaningful participation — or is it moving on weak volume?

Instead of treating every bullish or bearish candle equally, Atlas breaks the candle down into its individual components and compares them across Chart, 1H, 15M and 5M.

The result is a compact market diagnostic table that lets you see direction, candle strength, rejection, volume participation, volatility and volume efficiency at a glance.

How to read the table

🟢 Direction

Shows whether the candle is currently BULL or BEAR.

Don't use Direction by itself.

A bearish candle on extremely low volume is very different from a bearish candle accompanied by a major volume expansion.

Think:

Direction tells you what price did.

The other rows help explain why it may have happened.

📊 Body %

Measures how much of the candle's range is real body.

Example:

80% Body

Price travelled decisively in one direction.

20% Body

Most of the candle's movement was wick.

Reading it:

High Body % + high volume = stronger directional candle

Low Body % + high volume = potential conflict/rejection

📍 Close %

Shows where the candle finished within its high-low range.

Close near 90–100%

Buyers controlled most of the candle.

Close near 0–10%

Sellers controlled most of the candle.

Close around 50%

Neither side clearly controlled the final outcome.

Example

A bullish candle with:

Body 85% Close 95% Volume 2.2×

is much more convincing than:

Body 25% Close 52% Volume 2.2×

The volume is identical, but the result of that volume is completely different.

Wick % — rejection

Upper Wick

A large upper wick means price traded higher but failed to hold those levels.

Lower Wick

A large lower wick means price traded lower but recovered.

Example — potential selling rejection

Bear/Bull candle Upper Wick 45% Volume 2.5×

This tells you there was substantial activity at higher prices, but price couldn't maintain the high.

Example — potential buying rejection

Lower Wick 50% Volume 2.5×

Price was pushed lower but recovered strongly.

Wicks become much more meaningful when accompanied by elevated volume.

🔥 Volume Ratio

This is one of the most important numbers.

It compares current volume with its normal volume.

Example

0.50×

Volume is roughly half normal.

1.00×

Normal participation.

1.50×

50% above normal.

2.00×

Twice normal volume.

3.00×

Extreme participation.

The key rule:

High volume does NOT automatically mean bullish.

It means:

Something significant is happening.

We then look at the candle to determine what price actually did with that participation.

📈 Volume Percentile

This answers a slightly different question:

How unusual is this volume compared with previous candles?

For example:

95% percentile

means current volume is unusually high compared with its historical distribution.

10% percentile

means volume is relatively quiet.

Example

Price suddenly falls with:

Volume Ratio: 2.4× Volume Percentile: 97%

That's a major participation event.

Now look at:

Body + Close + Wicks + Efficiency

to determine what that participation accomplished.

🚀 Volume Acceleration

This tells you whether participation is increasing or decreasing.

Example

0.8×
1.0×
1.3×
1.7×
2.1×

Volume is accelerating.

If price is simultaneously moving upward with strong candles, that can indicate expanding participation behind the move.

Conversely:

2.4×
2.0×
1.6×
1.2×
0.8×

Volume is fading.

If price continues moving but participation keeps disappearing, the move may be losing strength.

⚡ Range / ATR

This tells you how large the candle is compared with normal volatility.

Example

0.40

Small movement.

1.00

Normal movement.

2.00

The candle is approximately twice the normal ATR range.

A large range combined with high volume is much more significant than a tiny candle occurring on the same volume.

💥 Body / ATR

This focuses specifically on directional displacement.

A candle could have a large range because of huge wicks.

Body/ATR helps determine whether price actually travelled directionally.

Example A

Range/ATR = 2.0 Body/ATR = 0.3

Huge candle, but most of it was wick.

Example B

Range/ATR = 1.5 Body/ATR = 1.2

Most of the movement was genuine directional displacement.

That distinction is extremely important.

⚙️ Efficiency

Efficiency brings several of these ideas together.

It asks:

How effectively is the current volume producing price movement?

HIGH efficiency

Volume is producing substantial directional displacement.

MED efficiency

Some movement is occurring, but the signal is less decisive.

LOW efficiency

A lot of activity is producing relatively little directional movement.

Real-world examples

Example 1 — Strong bullish expansion

Direction       BULL
Body %          85%
Close %         94%
Upper Wick      5%
Lower Wick      11%

Vol Ratio       2.3×
Vol Percentile  96%
Vol Accel       UP

Range/ATR       1.7
Body/ATR        1.4
Efficiency      HIGH

Reading:

Bullish direction + strong body + close near high + high volume + increasing participation + strong displacement.

This is a high-quality bullish expansion profile.

Example 2 — Weak bearish move

Direction       BEAR
Body %          72%
Close %         67%
Vol Ratio       0.35×
Vol Percentile  8%
Vol Accel       DOWN

Range/ATR       0.55
Body/ATR        0.40
Efficiency      MED

Price is falling.

But participation is weak.

Reading:

Bearish price action, but little evidence of expanding participation behind the move.

This doesn't automatically mean bullish — it means the bearish move isn't strongly confirmed by volume.

Example 3 — High-volume rejection

Direction       BULL
Body %          25%
Close %         58%
Upper Wick      62%

Vol Ratio       2.8×
Vol Percentile  98%
Vol Accel       UP

Range/ATR       1.9
Body/ATR        0.35
Efficiency      LOW

This is very interesting.

Huge volume.

Huge range.

But very little body.

And a massive upper wick.

Reading:

A lot of activity occurred, but price failed to maintain the move higher.

That is a very different market condition from a clean bullish expansion.

Example 4 — Quiet accumulation/absorption type behaviour

Direction       BULL
Body %          30%
Close %         72%
Lower Wick      48%

Vol Ratio       2.2×
Vol Percentile  94%
Vol Accel       UP

Range/ATR       1.4
Body/ATR        0.30
Efficiency      MED

Price was pushed down, but recovered.

Volume is elevated.

The lower wick is large.

Reading:

Significant activity occurred at lower prices, but sellers failed to maintain control.

This is the sort of pattern where the relationship between volume + wick + close becomes much more informative than candle colour alone.

The golden rule of the table

Never read one row in isolation.

Instead, read it in layers:

1️⃣ Direction

Which way did price move?

↓

2️⃣ Body + Close

How decisively did it move?

↓

3️⃣ Wicks

Was there rejection?

↓

4️⃣ Volume Ratio + Percentile

Was there meaningful participation?

↓

5️⃣ Volume Acceleration

Is participation increasing or fading?

↓

6️⃣ Range/ATR + Body/ATR

How significant was the actual displacement?

↓

7️⃣ Efficiency

Did the volume actually accomplish much?

Multi-timeframe example

This is where the table becomes particularly powerful.

Imagine:

              1H       15M       5M
Direction     BULL     BULL      BEAR
Body %        82%      74%       65%
Vol Ratio     1.8×     2.1×      0.5×
Vol Accel     UP       UP        DOWN
Efficiency    HIGH     HIGH      MED

The 1H and 15M are showing strong bullish participation, while the 5M is currently pulling back on weak volume.

That tells a very different story from:

              1H       15M       5M
Direction     BEAR     BEAR      BEAR
Vol Ratio     2.1×     2.4×      2.7×
Vol Accel     UP       UP        UP
Efficiency    HIGH     HIGH      HIGH

Here, all three time frames are showing expanding bearish participation.

That's the real purpose of the table:

Don't just look at the colour of the candle. Look at what the market had to do to produce it.

Atlas Candle Volume Engine

Price tells you what happened. Volume tells you how much participation was involved. Candle structure tells you how that participation affected price. Efficiency tells you how much the market actually accomplished.

That combination is what makes the table useful as a standalone market-reading tool.

---

## Source Code

````pine
//@version=6
indicator("Atlas Candle Volume Engine V1.1 (Export)", overlay=true, max_bars_back=500)

// ============================================================
// INPUTS
// ============================================================
volAvgLenInput = input.int(20, "Volume Average Length", minval=5, group="Settings")
volPctLenInput = input.int(100, "Volume Percentile Lookback", minval=20, group="Settings")
atrLenInput    = input.int(14, "ATR Length", minval=1, group="Settings")
tablePosInput  = input.string("Top Right", "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")
showMTFInput   = input.bool(true, "Show 1H / 15M / 5M Snapshot Columns", group="Display")

tablePos = tablePosInput == "Top Right"    ? position.top_right    :
           tablePosInput == "Top Left"     ? position.top_left     :
           tablePosInput == "Bottom Right" ? position.bottom_right :
           position.bottom_left

// ============================================================
// FEATURE FUNCTION -- works in any context (chart TF or via request.security)
// Returns: [dirCode, bodyPct, closeLoc, upperWick%, lowerWick%, volRatio, volPercentile, volAccel, rangeATR, bodyATR, efficiency]
// ============================================================
f_features() =>
    float rangeVal   = high - low
    float bodyVal    = math.abs(close - open)
    float bodyPct    = rangeVal != 0 ? bodyVal / rangeVal * 100 : 0
    float closeLoc   = rangeVal != 0 ? (close - low) / rangeVal * 100 : 50
    float upperWick  = rangeVal != 0 ? (high - math.max(close, open)) / rangeVal * 100 : 0
    float lowerWick  = rangeVal != 0 ? (math.min(close, open) - low) / rangeVal * 100 : 0
    int   dirCode    = close > open ? 1 : close < open ? -1 : 0
    float volAvg     = ta.sma(volume, volAvgLenInput)
    float volRatio   = volAvg != 0 ? volume / volAvg : 0
    float volPct     = ta.percentrank(volume, volPctLenInput)
    float volAccel   = volRatio - volRatio[1]
    float atrVal     = ta.atr(atrLenInput)
    float rangeAtr   = atrVal != 0 ? rangeVal / atrVal : 0
    float bodyAtr    = atrVal != 0 ? bodyVal / atrVal : 0
    float efficiency = volRatio != 0 ? rangeAtr / volRatio : 0
    [dirCode, bodyPct, closeLoc, upperWick, lowerWick, volRatio, volPct, volAccel, rangeAtr, bodyAtr, efficiency]

// ============================================================
// CHART-TIMEFRAME FEATURES (used for table's "Chart" column AND for export plots)
// ============================================================
[dirC, bodyPctC, closeLocC, upWickC, lowWickC, volRatioC, volPctC, volAccelC, rangeAtrC, bodyAtrC, effC] = f_features()

// NOTE: Pine cannot reference future bars (negative offsets like close[-1] are not
// supported -- history-referencing only goes 0..10000 bars into the PAST). Forward
// returns for labeling are therefore computed in Python after export, not here:
//   df['future_1_return']  = df['close'].pct_change().shift(-1)  * 100
//   df['future_3_return']  = df['close'].pct_change(3).shift(-3) * 100
//   df['future_5_return']  = df['close'].pct_change(5).shift(-5) * 100
//   df['future_10_return'] = df['close'].pct_change(10).shift(-10) * 100
// The Close plot below (in the export block) provides the price series needed for this.

// ============================================================
// MULTI-TF SNAPSHOTS (current value only, no history arrays -- reliable, no buffering lag)
// ============================================================
[dir1H, bodyPct1H, closeLoc1H, upWick1H, lowWick1H, volRatio1H, volPct1H, volAccel1H, rangeAtr1H, bodyAtr1H, eff1H] =
     request.security(syminfo.tickerid, "60", f_features(), lookahead=barmerge.lookahead_off)
[dir15, bodyPct15, closeLoc15, upWick15, lowWick15, volRatio15, volPct15, volAccel15, rangeAtr15, bodyAtr15, eff15] =
     request.security(syminfo.tickerid, "15", f_features(), lookahead=barmerge.lookahead_off)
[dir5, bodyPct5, closeLoc5, upWick5, lowWick5, volRatio5, volPct5, volAccel5, rangeAtr5, bodyAtr5, eff5] =
     request.security(syminfo.tickerid, "5", f_features(), lookahead=barmerge.lookahead_off)

// ============================================================
// FORMAT HELPERS
// ============================================================
f_dir(d) => d == 1 ? "BULL" : d == -1 ? "BEAR" : "DOJI"
f_dirColor(d) => d == 1 ? color.lime : d == -1 ? color.red : color.gray
f_accel(a) => a > 0.05 ? "UP" : a < -0.05 ? "DOWN" : "FLAT"
f_effLabel(e) => e > 1.2 ? "HIGH" : e > 0.6 ? "MED" : "LOW"
f_pct(v) => str.tostring(v, "#.#") + "%"
f_num(v) => str.tostring(v, "#.##")

// ============================================================
// DIAGNOSTIC TABLE
// ============================================================
var table diagTable = table.new(tablePos, columns=5, rows=12,
     bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray,
     frame_width=1, frame_color=color.gray)

if barstate.islast
    // Header
    table.cell(diagTable, 0, 0, "FEATURE", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 40))
    table.cell(diagTable, 1, 0, "CHART",   text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 40))
    if showMTFInput
        table.cell(diagTable, 2, 0, "1H",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 40))
        table.cell(diagTable, 3, 0, "15M", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 40))
        table.cell(diagTable, 4, 0, "5M",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.gray, 40))

    // Direction
    table.cell(diagTable, 0, 1, "Direction", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 1, f_dir(dirC), text_color=f_dirColor(dirC), text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 1, f_dir(dir1H), text_color=f_dirColor(dir1H), text_size=size.tiny)
        table.cell(diagTable, 3, 1, f_dir(dir15), text_color=f_dirColor(dir15), text_size=size.tiny)
        table.cell(diagTable, 4, 1, f_dir(dir5),  text_color=f_dirColor(dir5),  text_size=size.tiny)

    // Body %
    table.cell(diagTable, 0, 2, "Body %", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 2, f_pct(bodyPctC), text_color=color.white, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 2, f_pct(bodyPct1H), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 3, 2, f_pct(bodyPct15), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 4, 2, f_pct(bodyPct5),  text_color=color.white, text_size=size.tiny)

    // Close Location %
    table.cell(diagTable, 0, 3, "Close Loc %", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 3, f_pct(closeLocC), text_color=color.white, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 3, f_pct(closeLoc1H), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 3, 3, f_pct(closeLoc15), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 4, 3, f_pct(closeLoc5),  text_color=color.white, text_size=size.tiny)

    // Upper Wick %
    table.cell(diagTable, 0, 4, "Upper Wick %", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 4, f_pct(upWickC), text_color=color.white, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 4, f_pct(upWick1H), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 3, 4, f_pct(upWick15), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 4, 4, f_pct(upWick5),  text_color=color.white, text_size=size.tiny)

    // Lower Wick %
    table.cell(diagTable, 0, 5, "Lower Wick %", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 5, f_pct(lowWickC), text_color=color.white, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 5, f_pct(lowWick1H), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 3, 5, f_pct(lowWick15), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 4, 5, f_pct(lowWick5),  text_color=color.white, text_size=size.tiny)

    // Volume Ratio
    table.cell(diagTable, 0, 6, "Vol Ratio", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 6, f_num(volRatioC) + "x", text_color=color.yellow, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 6, f_num(volRatio1H) + "x", text_color=color.yellow, text_size=size.tiny)
        table.cell(diagTable, 3, 6, f_num(volRatio15) + "x", text_color=color.yellow, text_size=size.tiny)
        table.cell(diagTable, 4, 6, f_num(volRatio5)  + "x", text_color=color.yellow, text_size=size.tiny)

    // Volume Percentile
    table.cell(diagTable, 0, 7, "Vol Percentile", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 7, f_pct(volPctC), text_color=color.yellow, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 7, f_pct(volPct1H), text_color=color.yellow, text_size=size.tiny)
        table.cell(diagTable, 3, 7, f_pct(volPct15), text_color=color.yellow, text_size=size.tiny)
        table.cell(diagTable, 4, 7, f_pct(volPct5),  text_color=color.yellow, text_size=size.tiny)

    // Volume Acceleration
    table.cell(diagTable, 0, 8, "Vol Accel", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 8, f_accel(volAccelC), text_color=color.aqua, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 8, f_accel(volAccel1H), text_color=color.aqua, text_size=size.tiny)
        table.cell(diagTable, 3, 8, f_accel(volAccel15), text_color=color.aqua, text_size=size.tiny)
        table.cell(diagTable, 4, 8, f_accel(volAccel5),  text_color=color.aqua, text_size=size.tiny)

    // Range / ATR
    table.cell(diagTable, 0, 9, "Range/ATR", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 9, f_num(rangeAtrC), text_color=color.white, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 9, f_num(rangeAtr1H), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 3, 9, f_num(rangeAtr15), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 4, 9, f_num(rangeAtr5),  text_color=color.white, text_size=size.tiny)

    // Body / ATR
    table.cell(diagTable, 0, 10, "Body/ATR", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 10, f_num(bodyAtrC), text_color=color.white, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 10, f_num(bodyAtr1H), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 3, 10, f_num(bodyAtr15), text_color=color.white, text_size=size.tiny)
        table.cell(diagTable, 4, 10, f_num(bodyAtr5),  text_color=color.white, text_size=size.tiny)

    // Efficiency
    table.cell(diagTable, 0, 11, "Efficiency", text_color=color.silver, text_size=size.tiny)
    table.cell(diagTable, 1, 11, f_effLabel(effC), text_color=color.orange, text_size=size.tiny)
    if showMTFInput
        table.cell(diagTable, 2, 11, f_effLabel(eff1H), text_color=color.orange, text_size=size.tiny)
        table.cell(diagTable, 3, 11, f_effLabel(eff15), text_color=color.orange, text_size=size.tiny)
        table.cell(diagTable, 4, 11, f_effLabel(eff5),  text_color=color.orange, text_size=size.tiny)

// ============================================================
// EXPORT PLOTS -- hidden from chart, included in TradingView's "Export chart data" CSV.
// Computed on the CHART's own timeframe. Apply this script on 1H, export, then 15M,
// export, then 5M, export -- three raw datasets, one per timeframe. Forward-return
// labels (future_1/3/5/10) get added afterward in Python via close.shift(-N) -- see
// the note above; Pine itself cannot compute them.
// ============================================================
plot(dirC,      "Direction Code (1=Bull -1=Bear 0=Doji)", display=display.data_window)
plot(bodyPctC,  "Body %",              display=display.data_window)
plot(closeLocC, "Close Location %",    display=display.data_window)
plot(upWickC,   "Upper Wick %",        display=display.data_window)
plot(lowWickC,  "Lower Wick %",        display=display.data_window)
plot(volRatioC, "Volume Ratio",        display=display.data_window)
plot(volPctC,   "Volume Percentile",   display=display.data_window)
plot(volAccelC, "Volume Acceleration", display=display.data_window)
plot(rangeAtrC, "Range/ATR",           display=display.data_window)
plot(bodyAtrC,  "Body/ATR",            display=display.data_window)
plot(effC,      "Efficiency Ratio",    display=display.data_window)
plot(open,      "Open",                display=display.data_window)
plot(high,      "High",                display=display.data_window)
plot(low,       "Low",                 display=display.data_window)
plot(close,     "Close",               display=display.data_window)
plot(volume,    "Volume",              display=display.data_window)
````
