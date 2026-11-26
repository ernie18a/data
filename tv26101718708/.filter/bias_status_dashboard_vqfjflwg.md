# Bias Status Dashboard

- url: https://www.tradingview.com/script/vQFjflWg-Bias-Status-Dashboard/
- type: indicator
- pine_id: PUB;3b77a6b0dd67434cbb82ced9a5c398e7
- version: 1.0

## Description

## Bias Status Dashboard

The Bias Status Dashboard is designed to give traders a quick visual read of the current market bias directly on the chart. It organizes market direction, projection zones, percentage references, and current symbol context into one clean dashboard.

This indicator is useful for traders who want to quickly determine whether price is leaning bullish, bearish, neutral/ranging, continuing, reversing, or becoming overextended.

## Main Features

* Displays current market bias in a simple dashboard format
* Identifies the current chart/symbol being analyzed
* Shows projection-based zones for normal, moderate, and extreme movement
* Includes percentage references to show how much of the projected move has been used
* Plots optional chart lines for upside and downside projection areas
* Helps identify when price still has room for continuation or may be stretched
* Organizes high and low projection zones in a clean, logical order
* Designed to reduce chart clutter while keeping important context visible

## Projection Zones

The dashboard separates movement into three main zones:

**Normal Zone** – Price is within a reasonable projected range.

**Moderate Zone** – Price is moving deeper into projection and should be watched more carefully.

**Extreme Zone** – Price is extended and may carry higher risk for late entries, exhaustion, or reversal behavior.

These zones can help traders avoid chasing trades after price has already moved too far.

## How to Use

Use the dashboard as a trade filter and market context tool.

A simple workflow:

1. Check the current bias.
2. Confirm whether the market is bullish, bearish, neutral, or extended.
3. Compare current price to the normal, moderate, and extreme zones.
4. Avoid late entries when price is already in an extreme area.
5. Use your own strategy for entries, stops, targets, and risk management.

This indicator is not meant to be a standalone buy or sell signal. It is designed to support analysis by showing where price currently sits within the projected movement range.

## Best For

* Intraday futures trading
* Bias confirmation
* Continuation trade filtering
* Reversal awareness
* Target planning
* Projection-based analysis
* Avoiding overextended entries
* Quick market condition review

This tool can be used across multiple futures and index markets, but users should test and adjust settings based on their preferred symbol, session, and timeframe.

## Disclaimer

This indicator does not guarantee future price direction or trade outcomes. It is intended for educational and analysis purposes only. Always use proper risk management and combine this tool with your own tested trading plan.

## Source Code

````pine
//@version=6
indicator("Bias Status Dashboard", overlay = true, max_labels_count = 50)

// =====================================================
// GROUPS
// =====================================================
var G_DASH = "Dashboard Style"
var G_BIAS = "Bias Settings"
var G_SESS = "Session Settings"
var G_MTF  = "Multi-Timeframe Bias"

// =====================================================
// DASHBOARD INPUTS
// =====================================================
string dashPosInput = input.string("Top Right", "Main Dashboard Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_DASH)
string mtfDashPosInput = input.string("Middle Right", "MTF Dashboard Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_DASH)
string dashSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = G_DASH)

color headerBg      = input.color(color.rgb(50, 35, 110), "Header Background", group = G_DASH)
color sectionBg     = input.color(color.rgb(35, 25, 85), "MTF Header Background", group = G_DASH)
color tableBg       = input.color(color.new(color.black, 10), "Table Background", group = G_DASH)
color borderColor   = input.color(color.new(color.white, 65), "Border Color", group = G_DASH)
color labelTextCol  = input.color(color.white, "Left Column Text", group = G_DASH)

color bullColor     = input.color(color.lime, "Bullish Text", group = G_DASH)
color bearColor     = input.color(color.red, "Bearish Text", group = G_DASH)
color neutralColor  = input.color(color.orange, "Neutral / Warning Text", group = G_DASH)
color weakColor     = input.color(color.gray, "Weak Text", group = G_DASH)
color starColor     = input.color(color.orange, "Star Color", group = G_DASH)

// =====================================================
// BIAS INPUTS
// =====================================================
int fastEmaLen = input.int(9, "Fast EMA", group = G_BIAS)
int midEmaLen  = input.int(21, "Mid EMA", group = G_BIAS)
int slowEmaLen = input.int(50, "Slow EMA", group = G_BIAS)

int adxLen     = input.int(14, "ADX Length", group = G_BIAS)
float minAdx   = input.float(20.0, "Minimum ADX Trend Strength", step = 0.5, group = G_BIAS)

int atrLen     = input.int(14, "ATR Length", group = G_BIAS)
int atrAvgLen  = input.int(50, "ATR Average Length", group = G_BIAS)
float atrStrongRatio = input.float(1.10, "ATR Expanding Ratio", step = 0.05, group = G_BIAS)
float atrWeakRatio   = input.float(0.85, "ATR Weak Ratio", step = 0.05, group = G_BIAS)

int rsiLen     = input.int(14, "RSI Length", group = G_BIAS)
int volLen     = input.int(20, "Volume Average Length", group = G_BIAS)

int stochRsiLen = input.int(14, "Stoch RSI Length", group = G_BIAS)
int stochLen    = input.int(14, "Stoch Length", group = G_BIAS)
int kSmooth     = input.int(3, "Stoch K Smooth", group = G_BIAS)
int dSmooth     = input.int(3, "Stoch D Smooth", group = G_BIAS)
int stochMid    = input.int(50, "Stoch Midline", group = G_BIAS)

int swingLen   = input.int(5, "Structure Pivot Length", group = G_BIAS)

// =====================================================
// MTF INPUTS
// =====================================================
bool showMtfBias = input.bool(true, "Show Multi-Timeframe Bias Table", group = G_MTF)
int mtfMinAgree  = input.int(5, "Minimum TF Agreement for Strong Bias", minval = 1, maxval = 8, group = G_MTF)

// =====================================================
// SESSION INPUTS
// =====================================================
string tz = input.string("America/New_York", "Timezone", group = G_SESS)

string asiaSession   = input.session("1800-0200", "Asia Session", group = G_SESS)
string londonSession = input.session("0300-1200", "London Session", group = G_SESS)
string nySession     = input.session("0800-1700", "New York Session", group = G_SESS)

// =====================================================
// HELPERS
// =====================================================
f_pos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Top Right" ? position.top_right :
     p == "Middle Left" ? position.middle_left :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center :
     p == "Bottom Right" ? position.bottom_right :
     position.top_right

f_size(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Normal" ? size.normal :
     size.small

f_stars(int score) =>
    string stars = "☆☆☆☆☆"

    if score >= 7
        stars := "★★★★★"
    else if score == 6
        stars := "★★★★☆"
    else if score == 5
        stars := "★★★☆☆"
    else if score == 4
        stars := "★★☆☆☆"
    else if score == 3
        stars := "★☆☆☆☆"

    stars

f_biasTxt(int b) =>
    b == 1 ? "BULL" : b == -1 ? "BEAR" : "MIXED"

f_biasCol(int b) =>
    b == 1 ? bullColor : b == -1 ? bearColor : neutralColor

// =====================================================
// MTF BIAS FUNCTION
// =====================================================
f_calcTfBias() =>
    float _emaFast = ta.ema(close, fastEmaLen)
    float _emaMid  = ta.ema(close, midEmaLen)
    float _emaSlow = ta.ema(close, slowEmaLen)

    float _rsi = ta.rsi(close, rsiLen)

    float _stochBase = ta.rsi(close, stochRsiLen)
    float _k = ta.sma(ta.stoch(_stochBase, _stochBase, _stochBase, stochLen), kSmooth)
    float _d = ta.sma(_k, dSmooth)

    bool _emaBull = _emaFast > _emaMid and _emaMid > _emaSlow
    bool _emaBear = _emaFast < _emaMid and _emaMid < _emaSlow

    bool _rsiBull = _rsi > 50
    bool _rsiBear = _rsi < 50

    bool _stochBull = _k > _d and _k > stochMid
    bool _stochBear = _k < _d and _k < stochMid

    int _bullScore = 0
    int _bearScore = 0

    if _emaBull
        _bullScore += 1
    if _emaBear
        _bearScore += 1

    if _rsiBull
        _bullScore += 1
    if _rsiBear
        _bearScore += 1

    if _stochBull
        _bullScore += 1
    if _stochBear
        _bearScore += 1

    int _bias = 0

    if _bullScore >= 2 and _bullScore > _bearScore
        _bias := 1
    else if _bearScore >= 2 and _bearScore > _bullScore
        _bias := -1
    else
        _bias := 0

    _bias

// =====================================================
// EMA STACK
// =====================================================
float emaFast = ta.ema(close, fastEmaLen)
float emaMid  = ta.ema(close, midEmaLen)
float emaSlow = ta.ema(close, slowEmaLen)

bool emaBull = emaFast > emaMid and emaMid > emaSlow
bool emaBear = emaFast < emaMid and emaMid < emaSlow

string emaTxt = emaBull ? "BULL" : emaBear ? "BEAR" : "MIXED"
color emaCol = emaBull ? bullColor : emaBear ? bearColor : neutralColor

// =====================================================
// ADX
// =====================================================
[diplus, diminus, adxVal] = ta.dmi(adxLen, adxLen)

bool adxStrong = adxVal >= minAdx
bool adxBull = adxStrong and diplus > diminus
bool adxBear = adxStrong and diminus > diplus

string adxTxt = str.tostring(adxVal, "#.0") + (adxStrong ? " ↑" : " ↓")
color adxCol = adxStrong ? bullColor : bearColor

// =====================================================
// ATR
// =====================================================
float atrVal = ta.atr(atrLen)
float atrAvg = ta.sma(atrVal, atrAvgLen)
float atrRatio = atrAvg != 0 ? atrVal / atrAvg : na

bool atrExpanding = atrRatio >= atrStrongRatio
bool atrWeak = atrRatio <= atrWeakRatio
bool atrNormal = not atrExpanding and not atrWeak

string atrTxt = str.tostring(atrVal, "#.##") + " "

if atrExpanding
    atrTxt += "Expanding"
else if atrWeak
    atrTxt += "Weak"
else
    atrTxt += "Normal"

color atrCol = atrExpanding ? bullColor : atrWeak ? bearColor : neutralColor

// =====================================================
// STOCH RSI STATUS
// =====================================================
float stochRsiBase = ta.rsi(close, stochRsiLen)
float stochK = ta.sma(ta.stoch(stochRsiBase, stochRsiBase, stochRsiBase, stochLen), kSmooth)
float stochD = ta.sma(stochK, dSmooth)

bool stochBull = stochK > stochD and stochK > stochMid
bool stochBear = stochK < stochD and stochK < stochMid
bool stochRising = stochK > stochK[1]
bool stochFalling = stochK < stochK[1]

string stochTxt = "Neutral"

if stochBull and stochRising
    stochTxt := "Bull Rising"
else if stochBull
    stochTxt := "Bull"
else if stochBear and stochFalling
    stochTxt := "Bear Falling"
else if stochBear
    stochTxt := "Bear"
else
    stochTxt := "Neutral"

color stochCol = stochBull ? bullColor : stochBear ? bearColor : neutralColor

// =====================================================
// RSI
// =====================================================
float rsiVal = ta.rsi(close, rsiLen)

bool rsiBull = rsiVal > 50
bool rsiBear = rsiVal < 50

string rsiTxt = str.tostring(rsiVal, "#.0")
color rsiCol = rsiBull ? bullColor : rsiBear ? bearColor : neutralColor

// =====================================================
// VOLUME
// =====================================================
float volAvg = ta.sma(volume, volLen)

bool volAbove = volume > volAvg

string volTxt = volAbove ? "Above Avg" : "Below Avg"
color volCol = volAbove ? bullColor : bearColor

// =====================================================
// SESSION
// =====================================================
bool inAsia   = not na(time(timeframe.period, asiaSession, tz))
bool inLondon = not na(time(timeframe.period, londonSession, tz))
bool inNY     = not na(time(timeframe.period, nySession, tz))

bool activeSession = inAsia or inLondon or inNY

string sessionTxt = "Inactive"

if inNY
    sessionTxt := "NY Active"
else if inLondon
    sessionTxt := "London Active"
else if inAsia
    sessionTxt := "Asia Active"

color sessionCol = activeSession ? bullColor : weakColor

// =====================================================
// STRUCTURE / BSMS STATUS
// =====================================================
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var float lastPh = na
var float lastPl = na

if not na(ph)
    lastPh := ph

if not na(pl)
    lastPl := pl

var int structDir = 0

bool bullBreak = not na(lastPh) and close > lastPh
bool bearBreak = not na(lastPl) and close < lastPl

if bullBreak
    structDir := 1
else if bearBreak
    structDir := -1

// =====================================================
// MULTI-TIMEFRAME BIAS
// =====================================================
int bias5m  = request.security(syminfo.tickerid, "5", f_calcTfBias())
int bias15m = request.security(syminfo.tickerid, "15", f_calcTfBias())
int bias30m = request.security(syminfo.tickerid, "30", f_calcTfBias())
int bias1h  = request.security(syminfo.tickerid, "60", f_calcTfBias())
int bias4h  = request.security(syminfo.tickerid, "240", f_calcTfBias())
int biasD   = request.security(syminfo.tickerid, "D", f_calcTfBias())
int biasW   = request.security(syminfo.tickerid, "W", f_calcTfBias())
int biasM   = request.security(syminfo.tickerid, "M", f_calcTfBias())

int mtfBullCount = 0
int mtfBearCount = 0

if bias5m == 1
    mtfBullCount += 1
if bias15m == 1
    mtfBullCount += 1
if bias30m == 1
    mtfBullCount += 1
if bias1h == 1
    mtfBullCount += 1
if bias4h == 1
    mtfBullCount += 1
if biasD == 1
    mtfBullCount += 1
if biasW == 1
    mtfBullCount += 1
if biasM == 1
    mtfBullCount += 1

if bias5m == -1
    mtfBearCount += 1
if bias15m == -1
    mtfBearCount += 1
if bias30m == -1
    mtfBearCount += 1
if bias1h == -1
    mtfBearCount += 1
if bias4h == -1
    mtfBearCount += 1
if biasD == -1
    mtfBearCount += 1
if biasW == -1
    mtfBearCount += 1
if biasM == -1
    mtfBearCount += 1

int mtfBias = 0

if mtfBullCount >= mtfMinAgree and mtfBullCount > mtfBearCount
    mtfBias := 1
else if mtfBearCount >= mtfMinAgree and mtfBearCount > mtfBullCount
    mtfBias := -1
else
    mtfBias := 0

string mtfTxt = mtfBias == 1 ? "BULL " + str.tostring(mtfBullCount) + "/8" :
     mtfBias == -1 ? "BEAR " + str.tostring(mtfBearCount) + "/8" :
     "MIXED " + str.tostring(mtfBullCount) + "B/" + str.tostring(mtfBearCount) + "S"

color mtfCol = mtfBias == 1 ? bullColor : mtfBias == -1 ? bearColor : neutralColor

// =====================================================
// OVERALL SCORE
// =====================================================
int bullScore = 0
int bearScore = 0

if structDir == 1
    bullScore += 1
if structDir == -1
    bearScore += 1

if emaBull
    bullScore += 1
if emaBear
    bearScore += 1

if adxBull
    bullScore += 1
if adxBear
    bearScore += 1

if atrExpanding or atrNormal
    bullScore += 1
    bearScore += 1

if stochBull
    bullScore += 1
if stochBear
    bearScore += 1

if rsiBull
    bullScore += 1
if rsiBear
    bearScore += 1

if volAbove
    bullScore += 1
    bearScore += 1

if activeSession
    bullScore += 1
    bearScore += 1

if mtfBias == 1
    bullScore += 1
if mtfBias == -1
    bearScore += 1

int finalScore = math.max(bullScore, bearScore)

string biasTxt = "WAIT"
color biasCol = neutralColor

if bullScore > bearScore and finalScore >= 6
    biasTxt := "LONGS"
    biasCol := bullColor
else if bearScore > bullScore and finalScore >= 6
    biasTxt := "SHORTS"
    biasCol := bearColor
else
    biasTxt := "WAIT"
    biasCol := neutralColor

string scoreTxt = f_stars(finalScore)

// =====================================================
// DASHBOARD TABLES
// =====================================================
var table dash = table.new(
     f_pos(dashPosInput),
     2,
     10,
     bgcolor = tableBg,
     border_color = borderColor,
     border_width = 1,
     frame_color = borderColor,
     frame_width = 1
)

var table mtfDash = table.new(
     f_pos(mtfDashPosInput),
     2,
     9,
     bgcolor = tableBg,
     border_color = borderColor,
     border_width = 1,
     frame_color = borderColor,
     frame_width = 1
)

textSize = f_size(dashSizeInput)

if barstate.islast
    // MAIN DASHBOARD
    table.cell(dash, 0, 0, "BSMS Status", text_color = color.white, bgcolor = headerBg, text_size = textSize)
    table.cell(dash, 1, 0, "Value", text_color = color.white, bgcolor = headerBg, text_size = textSize)

    table.cell(dash, 0, 1, "Bias", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 1, biasTxt, text_color = biasCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 2, "EMA Stack", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 2, emaTxt, text_color = emaCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 3, "ADX/ Trend Strength", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 3, adxTxt, text_color = adxCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 4, "ATR/ Volatility", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 4, atrTxt, text_color = atrCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 5, "Stoch", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 5, stochTxt, text_color = stochCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 6, "RSI", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 6, rsiTxt, text_color = rsiCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 7, "Volume", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 7, volTxt, text_color = volCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 8, "Session", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 8, sessionTxt, text_color = sessionCol, bgcolor = tableBg, text_size = textSize)

    table.cell(dash, 0, 9, "Score", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
    table.cell(dash, 1, 9, scoreTxt, text_color = starColor, bgcolor = tableBg, text_size = textSize)

    // MTF DASHBOARD
    if showMtfBias
        table.cell(mtfDash, 0, 0, "MTF Bias", text_color = color.white, bgcolor = sectionBg, text_size = textSize)
        table.cell(mtfDash, 1, 0, mtfTxt, text_color = mtfCol, bgcolor = sectionBg, text_size = textSize)

        table.cell(mtfDash, 0, 1, "5m", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 1, f_biasTxt(bias5m), text_color = f_biasCol(bias5m), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 2, "15m", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 2, f_biasTxt(bias15m), text_color = f_biasCol(bias15m), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 3, "30m", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 3, f_biasTxt(bias30m), text_color = f_biasCol(bias30m), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 4, "1H", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 4, f_biasTxt(bias1h), text_color = f_biasCol(bias1h), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 5, "4H", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 5, f_biasTxt(bias4h), text_color = f_biasCol(bias4h), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 6, "Daily", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 6, f_biasTxt(biasD), text_color = f_biasCol(biasD), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 7, "Weekly", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 7, f_biasTxt(biasW), text_color = f_biasCol(biasW), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 8, "Monthly", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 8, f_biasTxt(biasM), text_color = f_biasCol(biasM), bgcolor = tableBg, text_size = textSize)
````
