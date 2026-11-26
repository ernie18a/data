# Major / Minor BIAS Dashboard 

- url: https://www.tradingview.com/script/8EgMBhri/
- type: indicator
- pine_id: PUB;b9c25062d42347378a93f1ded437475c
- version: 4.0

## Description

1. Purpose of the Script

The script is designed to provide a clear directional view of the Nasdaq/NQ market.

It is not intended to be used as an entry signal. Instead, it works as a higher-level directional filter.

That means the script does not tell you exactly when to enter a trade. It only shows whether the market currently favors long trades, short trades, or caution.

The basic idea is:

If the overall BIAS is Long, only look for long setups.
If the overall BIAS is Short, only look for short setups.
If the script shows Warning or Neutral, no standard trade should be taken.

This helps prevent trading against the broader market direction.

2. Structure of the Dashboard

The script displays a table directly on the chart.

The dashboard is divided into three main parts:

Major
The Major BIAS represents the higher-timeframe market direction.

Minor
The Minor BIAS represents the shorter-term or intraday market direction.

Overall
The Overall BIAS combines Major and Minor and shows whether there is a clear trading direction.

The table is intentionally simple. The first column shows whether the row refers to Major, Minor, or Overall. The middle column displays the current state: Long, Short, Neutral, or Warning. The right column displays a symbol.

A green circle represents Long.
A red circle represents Short.
A grey circle represents Neutral.
A warning symbol represents a conflicting market situation.

3. The Major BIAS

The Major BIAS is used to determine the higher-timeframe market direction.

It is built from several higher-timeframe components:

Daily BIAS
4H BIAS
Previous Day Filter

This means the script does not only check whether the market is moving up or down in the short term. It also checks whether the broader market structure supports that direction.

4. Daily BIAS

For the Daily BIAS, the script uses two exponential moving averages:

Fast EMA
Slow EMA

The default settings are:

Fast EMA: 20
Slow EMA: 50

The logic is simple:

If price is above both Daily EMAs, the Daily BIAS is considered Long.
If price is below both Daily EMAs, the Daily BIAS is considered Short.
If price is between both Daily EMAs, the Daily BIAS is considered Neutral.

There is also an optional ATR buffer.

This buffer prevents the script from switching to Long or Short just because price barely moves above or below the EMAs. As a result, the signal becomes smoother and less sensitive to small market noise.

5. 4H BIAS

The 4H BIAS works in the same way as the Daily BIAS.

It also uses two EMAs:

Fast EMA: 20
Slow EMA: 50

The 4H chart is important because it reacts faster than the Daily chart while still showing a higher-timeframe structure.

For Nasdaq/NQ, this is useful because the Daily chart can sometimes be too slow, while the 1H chart may contain too much short-term noise.

The 4H timeframe acts as a strong middle layer between the Daily trend and intraday movement.

6. Previous Day Filter

The script also includes a Previous Day Filter.

This filter looks at important levels from the previous trading day:

Previous Day High
Previous Day Low
Previous Day Close
Previous Day Mid

The Previous Day Mid is calculated as:

Previous Day High + Previous Day Low divided by 2

The filter can be adjusted. You can choose whether the script should compare price to:

Previous Day Mid
Previous Day Close
Previous Day Mid + Close

If price is above the selected previous-day level, this part of the filter is considered bullish.
If price is below the selected previous-day level, it is considered bearish.

This helps the script understand where the current market is trading compared to the previous day’s structure.

7. When Is the Major BIAS Long or Short?

The Major BIAS only turns Long when all active Major components are Long.

Example:

Daily BIAS: Long
4H BIAS: Long
Previous Day Filter: Long

Then the script shows:

Major: Long

If one of these components does not confirm the direction, Major will not be classified as Long.

The same logic applies to Short.

The Major BIAS only turns Short when all active Major components are Short.

Example:

Daily BIAS: Short
4H BIAS: Short
Previous Day Filter: Short

Then the script shows:

Major: Short

This logic is intentionally strict because Major is meant to act as the higher-timeframe directional filter.

8. The Minor BIAS

The Minor BIAS represents the shorter-term intraday direction.

It is used to check whether the current intraday structure confirms the higher-timeframe direction.

The Minor BIAS consists of three components:

1H BIAS
VWAP
Opening Range

This combination is especially useful for Nasdaq/NQ because the market often reacts strongly to VWAP, the cash open, and short-term trend structure.

9. 1H BIAS

The 1H BIAS also uses two EMAs.

Default settings:

Fast EMA: 20
Slow EMA: 50

The logic is the same:

If price is above both 1H EMAs, the 1H BIAS is Long.
If price is below both 1H EMAs, the 1H BIAS is Short.
If price is between both 1H EMAs, the 1H BIAS is Neutral.

The 1H BIAS is the main EMA-based component of the Minor BIAS because it reflects the shorter-term trading direction.

10. VWAP Filter

VWAP stands for Volume Weighted Average Price.

The script calculates the session VWAP.

In simple terms:

If price trades above VWAP, buyers are more likely in control.
If price trades below VWAP, sellers are more likely in control.

In the script, this means:

Price above VWAP = VWAP Long
Price below VWAP = VWAP Short

VWAP helps identify whether the market is trading above or below its intraday fair value.

11. Opening Range

The Opening Range is based on the first minutes after the US cash market opens.

By default, the script uses:

15:30 to 15:45 German time

During this period, the script stores:

Opening Range High
Opening Range Low
Opening Range Mid

After the Opening Range is completed, the script evaluates price in relation to the Opening Range Mid.

If price is above the Opening Range Mid, the Opening Range filter is considered Long.
If price is below the Opening Range Mid, the Opening Range filter is considered Short.

Before the Opening Range is completed, this filter is not fully active yet.

That means before 15:45 German time, the Minor BIAS may remain more cautious.

12. When Is the Minor BIAS Long or Short?

The Minor BIAS only turns Long when all active Minor components are Long.

Example:

1H BIAS: Long
VWAP: Long
Opening Range: Long

Then the script shows:

Minor: Long

If one of the components does not confirm the direction, Minor will not be classified as Long.

The same applies to Short:

1H BIAS: Short
VWAP: Short
Opening Range: Short

Then the script shows:

Minor: Short

If the components do not align, Minor remains Neutral.

13. Overall BIAS

The Overall BIAS combines Major and Minor.

The logic is strict and clear:

If Major is Long and Minor is Long, the Overall BIAS is Long.
If Major is Short and Minor is Short, the Overall BIAS is Short.
If Major is Neutral and Minor is Neutral, the Overall BIAS is Neutral.
All other combinations are shown as Warning.

That means:

Major Long + Minor Neutral = Warning
Major Short + Minor Neutral = Warning
Major Long + Minor Short = Warning
Major Short + Minor Long = Warning

The Warning state means the market is not clearly aligned.

14. Meaning for Trading

The script should be used as a trading filter.

If the Overall BIAS is Long, only long setups should be considered.
If the Overall BIAS is Short, only short setups should be considered.
If Warning is shown, no normal trade should be taken.
If Neutral is shown, there is no clear directional advantage.

The script does not replace an entry system. It only helps avoid trading against the clearer market direction.

A clean trading rule would be:

I only trade in the direction of the Overall BIAS.
The BIAS does not give me entries. It only defines the allowed trading direction.
The actual entry must come from my separate setup.
When the script shows Warning or Neutral, I do not take a standard trade.

15. Chart Visualization

The script can display several lines and zones on the chart.

These include:

Daily EMAs
4H EMAs
1H EMAs
VWAP
Opening Range High
Opening Range Low
Opening Range Mid
Previous Day Mid
Previous Day Close

The script also colors the area between the Fast EMA and Slow EMA.

These areas represent the neutral zones of each timeframe.

At the moment, the script can show three EMA zones:

Daily Neutral Zone
4H Neutral Zone
1H Neutral Zone

This is correct because the Major BIAS uses Daily and 4H, while the Minor BIAS uses 1H.

For practical use, however, it may be better not to display all zones at the same time, because the chart can become overloaded.

16. Recommended Visualization Settings

For a clean chart, I would not keep everything visible all the time.

A good setup would be:

Hide Daily EMAs
Show 4H EMAs
Show 1H EMAs
Show VWAP
Show Opening Range
Show Previous Day Levels

The Daily BIAS can still be used in the dashboard even if the Daily EMAs are hidden from the chart.

This keeps the chart cleaner while the full logic continues to work in the background.

17. Strengths of the Script

The script is especially useful for identifying clear trend conditions and focusing only on the correct trading direction.

It helps to:

Avoid countertrend trades.
Identify sideways or unclear market conditions.
Make warning situations visible.
Check direction consciously before entering a trade.
Avoid impulsive trades against the market.

For Nasdaq/NQ, this can be very helpful because the market often moves fast and aggressively. When Major and Minor both point in the same direction, setups in that direction are usually more interesting.

18. Limitations of the Script

The script also has clear limitations.

It does not tell you exactly where to enter.
It does not define your stop loss.
It does not define your position size.
It does not guarantee a profitable trade.
It can react late during fast market reversals.

This is normal because a BIAS system is always a filter, not a complete trading system.

The BIAS gives direction.
Your separate setup gives the entry.

19. Practical Trading Rules

For daily use, the rules can be kept simple:

Overall LONG:
Only look for long setups.

Overall SHORT:
Only look for short setups.

Overall WARNING:
Do not take a normal trade. The market is not clearly aligned.

Overall NEUTRAL:
Wait. There is no clear directional advantage.

These rules make the script useful because they simplify the decision-making process.

20. Conclusion

The script is a Major/Minor BIAS dashboard for Nasdaq/NQ.

It combines higher-timeframe trend structure, intraday levels, and strict confirmation logic.

The Major BIAS shows the broader market direction.
The Minor BIAS shows whether the short-term structure confirms that direction.
The Overall BIAS shows whether there is a clear trading direction.

The script is not designed as an entry signal. It is designed as a professional directional filter.

Its purpose is to help you trade only when Major and Minor are aligned.

This supports a more disciplined trading approach:

Not every market needs to be traded.
Not every move is a valid setup.
Only when the direction is clear should an entry setup be considered.

## Source Code

````pine
//@version=6
indicator(" Major / Minor / Mini BIAS Dashboard", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// Major BIAS Settings
// Daily + 4H + Previous Day Filter
// ─────────────────────────────────────────────
majorGroup = "Major BIAS Settings"

dailyFastLen = input.int(20, "Daily Fast EMA Length", minval=1, group=majorGroup)
dailySlowLen = input.int(50, "Daily Slow EMA Length", minval=1, group=majorGroup)

h4FastLen = input.int(20, "4H Fast EMA Length", minval=1, group=majorGroup)
h4SlowLen = input.int(50, "4H Slow EMA Length", minval=1, group=majorGroup)

majorUseNeutralZone = input.bool(true, "Use Major ATR Buffer", group=majorGroup)
majorAtrLen = input.int(14, "Major ATR Length", minval=1, group=majorGroup)
majorNeutralAtrMult = input.float(0.10, "Major ATR Neutral Zone Multiplier", minval=0.0, step=0.01, group=majorGroup)

usePrevDayFilter = input.bool(true, "Use Previous Day Filter", group=majorGroup)
prevDayMode = input.string(
     "Mid",
     "Previous Day Filter Basis",
     options=["Mid", "Close", "Mid + Close"],
     group=majorGroup
)

// ─────────────────────────────────────────────
// Minor BIAS Settings
// 1H + VWAP + Opening Range
// ─────────────────────────────────────────────
minorGroup = "Minor BIAS Settings"

h1FastLen = input.int(20, "1H Fast EMA Length", minval=1, group=minorGroup)
h1SlowLen = input.int(50, "1H Slow EMA Length", minval=1, group=minorGroup)

minorUseNeutralZone = input.bool(true, "Use Minor ATR Buffer", group=minorGroup)
minorAtrLen = input.int(14, "Minor ATR Length", minval=1, group=minorGroup)
minorNeutralAtrMult = input.float(0.10, "Minor ATR Neutral Zone Multiplier", minval=0.0, step=0.01, group=minorGroup)

useVwapFilter = input.bool(true, "Use Session VWAP Filter", group=minorGroup)
useOpeningRangeFilter = input.bool(true, "Use Cash Opening Range Filter", group=minorGroup)

cashTimezone = input.string("Europe/Berlin", "Cash Open Timezone", group=minorGroup)
cashOpeningRangeSession = input.session("1530-1545", "Cash Opening Range", group=minorGroup)

// ─────────────────────────────────────────────
// Mini BIAS Settings
// M1 / M5 Scalp Execution Bias
// Does NOT affect Overall BIAS
// ─────────────────────────────────────────────
miniGroup = "Mini BIAS Settings"

useMiniBias = input.bool(true, "Use Mini BIAS", group=miniGroup)

miniTimeframe = input.timeframe(
     "5",
     "Mini BIAS Timeframe",
     options=["1", "5"],
     group=miniGroup
)

miniFastLen = input.int(20, "Mini Fast EMA Length", minval=1, group=miniGroup)
miniSlowLen = input.int(50, "Mini Slow EMA Length", minval=1, group=miniGroup)

miniUseNeutralZone = input.bool(true, "Use Mini ATR Buffer", group=miniGroup)
miniAtrLen = input.int(14, "Mini ATR Length", minval=1, group=miniGroup)
miniNeutralAtrMult = input.float(0.08, "Mini ATR Neutral Zone Multiplier", minval=0.0, step=0.01, group=miniGroup)

miniUseVwapFilter = input.bool(true, "Use Mini VWAP Filter", group=miniGroup)

// ─────────────────────────────────────────────
// Visualization Settings
// ─────────────────────────────────────────────
visualGroup = "Visualization Settings"

showMajorDailyEma = input.bool(true, "Show Major Daily EMAs", group=visualGroup)
showMajorH4Ema = input.bool(true, "Show Major 4H EMAs", group=visualGroup)
showMinorH1Ema = input.bool(true, "Show Minor 1H EMAs", group=visualGroup)

showMajorFill = input.bool(true, "Show Major EMA Neutral Zones", group=visualGroup)
showMinorFill = input.bool(true, "Show Minor EMA Neutral Zone", group=visualGroup)

showMiniEma = input.bool(false, "Show Mini EMAs", group=visualGroup)
showMiniAtrBiasZone = input.bool(false, "Show Mini ATR Bias Zone", group=visualGroup)
showMiniConditionMarkers = input.bool(false, "Show Mini Condition Markers", group=visualGroup)

showVwap = input.bool(true, "Show VWAP", group=visualGroup)
showOpeningRange = input.bool(true, "Show Opening Range", group=visualGroup)
showPreviousDayLevels = input.bool(true, "Show Previous Day Levels", group=visualGroup)

showDiagnostics = input.bool(true, "Show Diagnostics in Dashboard", group=visualGroup)

emaLineWidth = input.int(2, "EMA Line Width", minval=1, maxval=5, group=visualGroup)
fillTransparency = input.int(85, "EMA Zone Transparency", minval=0, maxval=100, group=visualGroup)

// ─────────────────────────────────────────────
// Visualization Colors
// ─────────────────────────────────────────────
colorGroup = "Visualization Colors"

dailyFastColor = input.color(color.rgb(0, 180, 255), "Daily Fast EMA Color", group=colorGroup)
dailySlowColor = input.color(color.rgb(0, 90, 255), "Daily Slow EMA Color", group=colorGroup)

h4FastColor = input.color(color.rgb(160, 80, 255), "4H Fast EMA Color", group=colorGroup)
h4SlowColor = input.color(color.rgb(110, 40, 220), "4H Slow EMA Color", group=colorGroup)

h1FastColor = input.color(color.rgb(255, 180, 0), "1H Fast EMA Color", group=colorGroup)
h1SlowColor = input.color(color.rgb(255, 100, 0), "1H Slow EMA Color", group=colorGroup)

miniFastColor = input.color(color.rgb(0, 255, 180), "Mini Fast EMA Color", group=colorGroup)
miniSlowColor = input.color(color.rgb(0, 170, 120), "Mini Slow EMA Color", group=colorGroup)
miniBoundaryColor = input.color(color.rgb(0, 255, 255), "Mini ATR Zone Boundary Color", group=colorGroup)

vwapColor = input.color(color.rgb(255, 255, 255), "VWAP Color", group=colorGroup)
openingRangeColor = input.color(color.rgb(255, 220, 0), "Opening Range Color", group=colorGroup)
previousDayColor = input.color(color.rgb(180, 180, 180), "Previous Day Level Color", group=colorGroup)

// ─────────────────────────────────────────────
// Dashboard Style
// ─────────────────────────────────────────────
tableGroup = "Dashboard Style"

tablePositionInput = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Left",
         "Top Right",
         "Bottom Left",
         "Bottom Right"
     ],
     group=tableGroup
)

textSizeInput = input.string(
     "Normal",
     "Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large",
         "Huge"
     ],
     group=tableGroup
)

headerBgColor = input.color(color.rgb(30, 30, 30), "Header Background", group=tableGroup)
cellBgColor = input.color(color.rgb(15, 15, 15), "Cell Background", group=tableGroup)
totalBgColor = input.color(color.rgb(40, 40, 40), "Overall BIAS Background", group=tableGroup)

textColor = input.color(color.white, "Text Color", group=tableGroup)
longColor = input.color(color.lime, "Long Color", group=tableGroup)
shortColor = input.color(color.red, "Short Color", group=tableGroup)
neutralColor = input.color(color.gray, "Neutral Color", group=tableGroup)
warningColor = input.color(color.orange, "Warning Color", group=tableGroup)

borderColor = input.color(color.rgb(80, 80, 80), "Border Color", group=tableGroup)

// ─────────────────────────────────────────────
// Functions
// ─────────────────────────────────────────────
f_tablePosition(_pos) =>
    switch _pos
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right

f_textSize(_size) =>
    switch _size
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge

f_biasFromEmaArea(_fastLen, _slowLen, _useNeutralZone, _atrLen, _neutralAtrMult) =>
    fastEma = ta.ema(close, _fastLen)
    slowEma = ta.ema(close, _slowLen)
    atrValue = ta.atr(_atrLen)
    neutralZone = _useNeutralZone ? atrValue * _neutralAtrMult : 0.0

    upperEma = math.max(fastEma, slowEma)
    lowerEma = math.min(fastEma, slowEma)

    close > upperEma + neutralZone ? 1 :
         close < lowerEma - neutralZone ? -1 :
         0

f_biasText(_bias) =>
    _bias == 1 ? "LONG" : _bias == -1 ? "SHORT" : "NEUTRAL"

f_biasColor(_bias) =>
    _bias == 1 ? longColor : _bias == -1 ? shortColor : neutralColor

f_priceText(_value) =>
    str.tostring(_value, format.mintick)

// ─────────────────────────────────────────────
// Major: Daily Values
// ─────────────────────────────────────────────
dailyBias = request.security(
     syminfo.tickerid,
     "D",
     f_biasFromEmaArea(dailyFastLen, dailySlowLen, majorUseNeutralZone, majorAtrLen, majorNeutralAtrMult),
     lookahead=barmerge.lookahead_off
)

dailyFastEma = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, dailyFastLen),
     lookahead=barmerge.lookahead_off
)

dailySlowEma = request.security(
     syminfo.tickerid,
     "D",
     ta.ema(close, dailySlowLen),
     lookahead=barmerge.lookahead_off
)

dailyAtr = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(majorAtrLen),
     lookahead=barmerge.lookahead_off
)

// ─────────────────────────────────────────────
// Major: 4H Values
// ─────────────────────────────────────────────
h4Bias = request.security(
     syminfo.tickerid,
     "240",
     f_biasFromEmaArea(h4FastLen, h4SlowLen, majorUseNeutralZone, majorAtrLen, majorNeutralAtrMult),
     lookahead=barmerge.lookahead_off
)

h4FastEma = request.security(
     syminfo.tickerid,
     "240",
     ta.ema(close, h4FastLen),
     lookahead=barmerge.lookahead_off
)

h4SlowEma = request.security(
     syminfo.tickerid,
     "240",
     ta.ema(close, h4SlowLen),
     lookahead=barmerge.lookahead_off
)

h4Atr = request.security(
     syminfo.tickerid,
     "240",
     ta.atr(majorAtrLen),
     lookahead=barmerge.lookahead_off
)

// ─────────────────────────────────────────────
// Previous Day Values
// ─────────────────────────────────────────────
prevDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead=barmerge.lookahead_off
)

prevDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead=barmerge.lookahead_off
)

prevDayClose = request.security(
     syminfo.tickerid,
     "D",
     close[1],
     lookahead=barmerge.lookahead_off
)

prevDayMid = (prevDayHigh + prevDayLow) / 2.0

prevDayLongCondition = prevDayMode == "Mid" ? close > prevDayMid :
     prevDayMode == "Close" ? close > prevDayClose :
     close > prevDayMid and close > prevDayClose

prevDayShortCondition = prevDayMode == "Mid" ? close < prevDayMid :
     prevDayMode == "Close" ? close < prevDayClose :
     close < prevDayMid and close < prevDayClose

prevDayBias = not usePrevDayFilter ? 0 :
     prevDayLongCondition ? 1 :
     prevDayShortCondition ? -1 :
     0

// ─────────────────────────────────────────────
// Minor: 1H Values
// ─────────────────────────────────────────────
h1Bias = request.security(
     syminfo.tickerid,
     "60",
     f_biasFromEmaArea(h1FastLen, h1SlowLen, minorUseNeutralZone, minorAtrLen, minorNeutralAtrMult),
     lookahead=barmerge.lookahead_off
)

h1FastEma = request.security(
     syminfo.tickerid,
     "60",
     ta.ema(close, h1FastLen),
     lookahead=barmerge.lookahead_off
)

h1SlowEma = request.security(
     syminfo.tickerid,
     "60",
     ta.ema(close, h1SlowLen),
     lookahead=barmerge.lookahead_off
)

h1Atr = request.security(
     syminfo.tickerid,
     "60",
     ta.atr(minorAtrLen),
     lookahead=barmerge.lookahead_off
)

// ─────────────────────────────────────────────
// Mini: M1 / M5 Values
// ─────────────────────────────────────────────
miniEmaBias = request.security(
     syminfo.tickerid,
     miniTimeframe,
     f_biasFromEmaArea(miniFastLen, miniSlowLen, miniUseNeutralZone, miniAtrLen, miniNeutralAtrMult),
     lookahead=barmerge.lookahead_off
)

miniClose = request.security(
     syminfo.tickerid,
     miniTimeframe,
     close,
     lookahead=barmerge.lookahead_off
)

miniFastEma = request.security(
     syminfo.tickerid,
     miniTimeframe,
     ta.ema(close, miniFastLen),
     lookahead=barmerge.lookahead_off
)

miniSlowEma = request.security(
     syminfo.tickerid,
     miniTimeframe,
     ta.ema(close, miniSlowLen),
     lookahead=barmerge.lookahead_off
)

miniAtr = request.security(
     syminfo.tickerid,
     miniTimeframe,
     ta.atr(miniAtrLen),
     lookahead=barmerge.lookahead_off
)

miniAtrBuffer = miniUseNeutralZone ? miniAtr * miniNeutralAtrMult : 0.0
miniUpperEma = math.max(miniFastEma, miniSlowEma)
miniLowerEma = math.min(miniFastEma, miniSlowEma)
miniUpperBoundary = miniUpperEma + miniAtrBuffer
miniLowerBoundary = miniLowerEma - miniAtrBuffer

// ─────────────────────────────────────────────
// Minor: VWAP
// ─────────────────────────────────────────────
sessionVwap = ta.vwap(hlc3)

vwapBias = not useVwapFilter ? 0 :
     close > sessionVwap ? 1 :
     close < sessionVwap ? -1 :
     0

// ─────────────────────────────────────────────
// Mini: VWAP Filter
// ─────────────────────────────────────────────
miniVwapBias = not miniUseVwapFilter ? 0 :
     miniClose > sessionVwap ? 1 :
     miniClose < sessionVwap ? -1 :
     0

miniLong = useMiniBias and miniEmaBias == 1 and (not miniUseVwapFilter or miniVwapBias == 1)
miniShort = useMiniBias and miniEmaBias == -1 and (not miniUseVwapFilter or miniVwapBias == -1)

miniBias = not useMiniBias ? 0 :
     miniLong ? 1 :
     miniShort ? -1 :
     0

// ─────────────────────────────────────────────
// Minor: Cash Opening Range
// ─────────────────────────────────────────────
inOpeningRange = not na(time(timeframe.period, cashOpeningRangeSession, cashTimezone))
newOpeningRange = inOpeningRange and not inOpeningRange[1]
endOpeningRange = not inOpeningRange and inOpeningRange[1]

newCashDay = ta.change(time("D", "0000-2359", cashTimezone)) != 0

var float openingRangeHigh = na
var float openingRangeLow = na
var bool openingRangeReady = false

if newCashDay
    openingRangeHigh := na
    openingRangeLow := na
    openingRangeReady := false

if newOpeningRange
    openingRangeHigh := high
    openingRangeLow := low
    openingRangeReady := false
else if inOpeningRange
    openingRangeHigh := math.max(nz(openingRangeHigh, high), high)
    openingRangeLow := math.min(nz(openingRangeLow, low), low)

if endOpeningRange and not na(openingRangeHigh) and not na(openingRangeLow)
    openingRangeReady := true

openingRangeMid = (openingRangeHigh + openingRangeLow) / 2.0

openingRangeBias = not useOpeningRangeFilter ? 0 :
     openingRangeReady and close > openingRangeMid ? 1 :
     openingRangeReady and close < openingRangeMid ? -1 :
     0

// ─────────────────────────────────────────────
// Major BIAS Combination
// ─────────────────────────────────────────────
majorLong = dailyBias == 1 and h4Bias == 1 and (not usePrevDayFilter or prevDayBias == 1)
majorShort = dailyBias == -1 and h4Bias == -1 and (not usePrevDayFilter or prevDayBias == -1)

majorBias = majorLong ? 1 :
     majorShort ? -1 :
     0

// ─────────────────────────────────────────────
// Minor BIAS Combination
// ─────────────────────────────────────────────
minorLong = h1Bias == 1 and (not useVwapFilter or vwapBias == 1) and (not useOpeningRangeFilter or openingRangeBias == 1)
minorShort = h1Bias == -1 and (not useVwapFilter or vwapBias == -1) and (not useOpeningRangeFilter or openingRangeBias == -1)

minorBias = minorLong ? 1 :
     minorShort ? -1 :
     0

// ─────────────────────────────────────────────
// Overall BIAS Logic
// Mini BIAS does NOT affect Overall
// ─────────────────────────────────────────────
isTotalLong = majorBias == 1 and minorBias == 1
isTotalShort = majorBias == -1 and minorBias == -1
isTotalNeutral = majorBias == 0 and minorBias == 0
isWarning = not isTotalLong and not isTotalShort and not isTotalNeutral

totalBiasText = isTotalLong ? "LONG" :
     isTotalShort ? "SHORT" :
     isTotalNeutral ? "NEUTRAL" :
     "WARNING"

totalBiasColor = isTotalLong ? longColor :
     isTotalShort ? shortColor :
     isTotalNeutral ? neutralColor :
     warningColor

totalSymbol = isWarning ? "⚠" : "●"

// ─────────────────────────────────────────────
// EMA Visualization
// ─────────────────────────────────────────────
plot(
     showMajorDailyEma ? dailyFastEma : na,
     title="Major Daily Fast EMA",
     color=dailyFastColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMajorDailyEma ? dailySlowEma : na,
     title="Major Daily Slow EMA",
     color=dailySlowColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMajorH4Ema ? h4FastEma : na,
     title="Major 4H Fast EMA",
     color=h4FastColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMajorH4Ema ? h4SlowEma : na,
     title="Major 4H Slow EMA",
     color=h4SlowColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMinorH1Ema ? h1FastEma : na,
     title="Minor 1H Fast EMA",
     color=h1FastColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMinorH1Ema ? h1SlowEma : na,
     title="Minor 1H Slow EMA",
     color=h1SlowColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMiniEma ? miniFastEma : na,
     title="Mini Fast EMA",
     color=miniFastColor,
     linewidth=emaLineWidth,
     editable=false
)

plot(
     showMiniEma ? miniSlowEma : na,
     title="Mini Slow EMA",
     color=miniSlowColor,
     linewidth=emaLineWidth,
     editable=false
)

// ─────────────────────────────────────────────
// EMA Zone Fills
// ─────────────────────────────────────────────
dailyFastFillPlot = plot(
     showMajorFill ? dailyFastEma : na,
     title="Daily EMA Fill Fast",
     color=color.new(dailyFastColor, 100),
     editable=false
)

dailySlowFillPlot = plot(
     showMajorFill ? dailySlowEma : na,
     title="Daily EMA Fill Slow",
     color=color.new(dailySlowColor, 100),
     editable=false
)

dailyFillColor = dailyBias == 1 ? color.new(longColor, fillTransparency) :
     dailyBias == -1 ? color.new(shortColor, fillTransparency) :
     color.new(neutralColor, fillTransparency)

fill(
     dailyFastFillPlot,
     dailySlowFillPlot,
     color=dailyFillColor,
     title="Daily EMA Zone"
)

h4FastFillPlot = plot(
     showMajorFill ? h4FastEma : na,
     title="4H EMA Fill Fast",
     color=color.new(h4FastColor, 100),
     editable=false
)

h4SlowFillPlot = plot(
     showMajorFill ? h4SlowEma : na,
     title="4H EMA Fill Slow",
     color=color.new(h4SlowColor, 100),
     editable=false
)

h4FillColor = h4Bias == 1 ? color.new(longColor, fillTransparency) :
     h4Bias == -1 ? color.new(shortColor, fillTransparency) :
     color.new(neutralColor, fillTransparency)

fill(
     h4FastFillPlot,
     h4SlowFillPlot,
     color=h4FillColor,
     title="4H EMA Zone"
)

h1FastFillPlot = plot(
     showMinorFill ? h1FastEma : na,
     title="1H EMA Fill Fast",
     color=color.new(h1FastColor, 100),
     editable=false
)

h1SlowFillPlot = plot(
     showMinorFill ? h1SlowEma : na,
     title="1H EMA Fill Slow",
     color=color.new(h1SlowColor, 100),
     editable=false
)

h1FillColor = h1Bias == 1 ? color.new(longColor, fillTransparency) :
     h1Bias == -1 ? color.new(shortColor, fillTransparency) :
     color.new(neutralColor, fillTransparency)

fill(
     h1FastFillPlot,
     h1SlowFillPlot,
     color=h1FillColor,
     title="1H EMA Zone"
)

// ─────────────────────────────────────────────
// Mini Condition Visualization
// ─────────────────────────────────────────────
miniUpperBoundaryPlot = plot(
     showMiniAtrBiasZone ? miniUpperBoundary : na,
     title="Mini Upper ATR Bias Boundary",
     color=miniBoundaryColor,
     linewidth=1,
     editable=false
)

miniLowerBoundaryPlot = plot(
     showMiniAtrBiasZone ? miniLowerBoundary : na,
     title="Mini Lower ATR Bias Boundary",
     color=miniBoundaryColor,
     linewidth=1,
     editable=false
)

miniZoneFillColor = miniEmaBias == 1 ? color.new(longColor, fillTransparency) :
     miniEmaBias == -1 ? color.new(shortColor, fillTransparency) :
     color.new(neutralColor, fillTransparency)

fill(
     miniUpperBoundaryPlot,
     miniLowerBoundaryPlot,
     color=showMiniAtrBiasZone ? miniZoneFillColor : na,
     title="Mini ATR Bias Zone"
)

plotshape(
     showMiniConditionMarkers and miniBias == 1 and miniBias[1] != 1,
     title="Mini LONG Condition Marker",
     style=shape.triangleup,
     location=location.belowbar,
     color=longColor,
     text="M",
     textcolor=longColor,
     size=size.tiny,
     editable=false
)

plotshape(
     showMiniConditionMarkers and miniBias == -1 and miniBias[1] != -1,
     title="Mini SHORT Condition Marker",
     style=shape.triangledown,
     location=location.abovebar,
     color=shortColor,
     text="M",
     textcolor=shortColor,
     size=size.tiny,
     editable=false
)

// ─────────────────────────────────────────────
// VWAP / Opening Range / Previous Day Visualization
// ─────────────────────────────────────────────
plot(
     showVwap and useVwapFilter ? sessionVwap : na,
     title="Session VWAP",
     color=vwapColor,
     linewidth=2,
     editable=false
)

plot(
     showOpeningRange and useOpeningRangeFilter and openingRangeReady ? openingRangeHigh : na,
     title="Opening Range High",
     color=openingRangeColor,
     linewidth=1,
     editable=false
)

plot(
     showOpeningRange and useOpeningRangeFilter and openingRangeReady ? openingRangeLow : na,
     title="Opening Range Low",
     color=openingRangeColor,
     linewidth=1,
     editable=false
)

plot(
     showOpeningRange and useOpeningRangeFilter and openingRangeReady ? openingRangeMid : na,
     title="Opening Range Mid",
     color=openingRangeColor,
     linewidth=2,
     editable=false
)

plot(
     showPreviousDayLevels and usePrevDayFilter ? prevDayMid : na,
     title="Previous Day Mid",
     color=previousDayColor,
     linewidth=1,
     editable=false
)

plot(
     showPreviousDayLevels and usePrevDayFilter ? prevDayClose : na,
     title="Previous Day Close",
     color=previousDayColor,
     linewidth=1,
     editable=false
)

// ─────────────────────────────────────────────
// Diagnostic Texts
// ─────────────────────────────────────────────
majorDiagnosticText = showDiagnostics ?
     f_biasText(majorBias) +
     "\nD: " + f_biasText(dailyBias) +
     " | 4H: " + f_biasText(h4Bias) +
     "\nPD: " + (usePrevDayFilter ? f_biasText(prevDayBias) : "OFF") +
     "\nPD Mid: " + f_priceText(prevDayMid) +
     "\nPD Close: " + f_priceText(prevDayClose)
     :
     f_biasText(majorBias)

minorDiagnosticText = showDiagnostics ?
     f_biasText(minorBias) +
     "\n1H: " + f_biasText(h1Bias) +
     "\nVWAP: " + (useVwapFilter ? f_biasText(vwapBias) : "OFF") +
     "\nOR: " + (useOpeningRangeFilter ? f_biasText(openingRangeBias) : "OFF") +
     "\nOR Mid: " + (openingRangeReady ? f_priceText(openingRangeMid) : "Not ready")
     :
     f_biasText(minorBias)

miniDiagnosticText = showDiagnostics ?
     (useMiniBias ? f_biasText(miniBias) : "OFF") +
     "\nTF: M" + miniTimeframe +
     "\nEMA: " + f_biasText(miniEmaBias) +
     "\nVWAP: " + (miniUseVwapFilter ? f_biasText(miniVwapBias) : "OFF")
     :
     useMiniBias ? f_biasText(miniBias) : "OFF"

// ─────────────────────────────────────────────
// Dashboard Timeframe Texts
// Only pure timeframes, no filter names
// ─────────────────────────────────────────────
majorTimeframeText = "D + 4H"
minorTimeframeText = "1H"

miniTimeframeText =
     not useMiniBias ? "OFF" :
     "M" + miniTimeframe

overallTimeframeText = "Major + Minor"

// ─────────────────────────────────────────────
// Dashboard Table
// ─────────────────────────────────────────────
var table biasTable = table.new(
     f_tablePosition(tablePositionInput),
     4,
     6,
     border_width=1,
     border_color=borderColor
)

txtSize = f_textSize(textSizeInput)

if barstate.islast
    // Header
    table.cell(
         biasTable,
         0,
         0,
         "Art",
         text_color=textColor,
         bgcolor=headerBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         1,
         0,
         "Timeframe",
         text_color=textColor,
         bgcolor=headerBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         2,
         0,
         "BIAS",
         text_color=textColor,
         bgcolor=headerBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         3,
         0,
         "Signal",
         text_color=textColor,
         bgcolor=headerBgColor,
         text_size=txtSize
    )

    // Major
    table.cell(
         biasTable,
         0,
         1,
         "Major",
         text_color=textColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         1,
         1,
         majorTimeframeText,
         text_color=textColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         2,
         1,
         majorDiagnosticText,
         text_color=f_biasColor(majorBias),
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         3,
         1,
         "●",
         text_color=f_biasColor(majorBias),
         bgcolor=cellBgColor,
         text_size=size.huge
    )

    // Minor
    table.cell(
         biasTable,
         0,
         2,
         "Minor",
         text_color=textColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         1,
         2,
         minorTimeframeText,
         text_color=textColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         2,
         2,
         minorDiagnosticText,
         text_color=f_biasColor(minorBias),
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         3,
         2,
         "●",
         text_color=f_biasColor(minorBias),
         bgcolor=cellBgColor,
         text_size=size.huge
    )

    // Mini
    table.cell(
         biasTable,
         0,
         3,
         "Mini",
         text_color=textColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         1,
         3,
         miniTimeframeText,
         text_color=textColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         2,
         3,
         miniDiagnosticText,
         text_color=useMiniBias ? f_biasColor(miniBias) : neutralColor,
         bgcolor=cellBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         3,
         3,
         "●",
         text_color=useMiniBias ? f_biasColor(miniBias) : neutralColor,
         bgcolor=cellBgColor,
         text_size=size.huge
    )

    // Separator
    table.cell(biasTable, 0, 4, "", bgcolor=borderColor)
    table.cell(biasTable, 1, 4, "", bgcolor=borderColor)
    table.cell(biasTable, 2, 4, "", bgcolor=borderColor)
    table.cell(biasTable, 3, 4, "", bgcolor=borderColor)

    // Overall
    table.cell(
         biasTable,
         0,
         5,
         "Overall:",
         text_color=textColor,
         bgcolor=totalBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         1,
         5,
         overallTimeframeText,
         text_color=textColor,
         bgcolor=totalBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         2,
         5,
         totalBiasText,
         text_color=totalBiasColor,
         bgcolor=totalBgColor,
         text_size=txtSize
    )

    table.cell(
         biasTable,
         3,
         5,
         totalSymbol,
         text_color=totalBiasColor,
         bgcolor=totalBgColor,
         text_size=size.huge
    )
````
