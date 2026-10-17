# Super Regression Trend Matrix Scanner

- url: https://www.tradingview.com/script/ntFWqwgO-Super-Regression-Trend-Matrix-Scanner/
- type: indicator
- pine_id: PUB;04869d6f3fa64e56a74b53c8fb4dcb8d
- version: 1.0

## Description

Title
[b]Super Regression Trend Matrix Scanner[/b]

[b]Short summary[/b]
Super Regression Trend Matrix Scanner is a multi-symbol watchlist dashboard built from the regression-trend concept used in Super Regression Trend. It scans multiple stocks at once and combines trend state, fresh flips, ADX strength, relative volume expansion, EMA structure, and RSI/SMA momentum in one matrix. The current chart symbol is pinned at the top, and fresh BUY NOW and SELL NOW signals are highlighted in bright colors and sorted higher in the list. This makes the script especially useful for swing-trading workflows on the weekly and daily timeframes. Attribution to the original open-source basis is included below. 
[b]
Full description[/b]

Super Regression Trend Matrix Scanner is a multi-symbol watchlist dashboard built for traders who want to review trend structure across a focused list of stocks without switching charts one by one.

This script is based on the regression-trend concept used in the open-source Super Regression Trend by Uncle_the_shooter. The original indicator uses a linear regression line and RMSE-based adaptive bands to define bullish and bearish trend changes. This version adapts that same core idea into a matrix scanner designed for watchlist review rather than single-chart overlay analysis.

The matrix evaluates each symbol using the regression-based trend engine and then adds context through ADX trend strength, relative volume expansion, price location versus the 9, 21, 30, 55, 100, and 200 EMAs, and RSI relative to its RSI-SMA baseline. The current chart symbol is pinned at the top of the matrix, and fresh trend changes are pushed higher in the list so new opportunities are easier to spot.

[b]How the scanner works[/b]

The core trend state comes from a regression model with RMSE-based dynamic bands. The regression line is used as the base, RMSE measures price deviation from that line, and adaptive upper and lower bands are formed from that deviation. Trend changes occur when price closes beyond those bands. This scanner applies that same general framework across multiple symbols at once.

Each row then shows whether that symbol has an active bullish or bearish regression-trend state, whether a fresh flip has just occurred, whether trend strength is acceptable, whether participation is expanding, whether price is aligned with key EMAs, and whether momentum is above or below its RSI-SMA baseline.

[b]Signal states and fresh highlights[/b]

The original regression-trend logic expresses direction as Buy or Sell. This matrix keeps that same core meaning, but extends it for watchlist scanning by separating an existing trend state from a fresh trend change.

That means the Signal column can show four states:

* BUY = bullish trend state already in progress
* SELL = bearish trend state already in progress
* BUY NOW = a fresh bullish flip has just occurred
* SELL NOW = a fresh bearish flip has just occurred

This distinction matters because a trend already in progress and a trend that has just changed are not the same thing in a watchlist workflow. The matrix is meant to surface what is new first.

[b]Fresh signals are shown in bright colors [/b]so they stand out immediately in the table. That visual emphasis helps direct attention to symbols that may deserve immediate review rather than symbols whose trend state is already established.

[b]Matrix components and why they matter
[/b]
Each column has a specific role. The goal is not to treat any single column as a standalone signal, but to judge trend, strength, participation, structure, and momentum together.


Ticker
This is the symbol being scanned.

The matrix is designed as a watchlist workflow tool. The current chart symbol is pinned at the top so the active chart can be compared directly against the rest of the list.

Signal

This is the core regression-trend output.

It shows whether the model is currently bullish or bearish, and whether that state has just changed. This is the starting point because it tells you whether the trend is already underway or whether a fresh shift has just appeared.

ADX

ADX is used as a trend-strength filter.

Its role is not to decide direction. Direction already comes from the regression-trend state. ADX answers a different question: is the move strong enough to respect, or is it still weak and noisy?

The default threshold is 15. That value was chosen as a practical minimum-strength filter for a scanner. It is low enough to catch developing trends early, but high enough to filter out some weaker conditions. If the threshold is set too high, the matrix may only surface moves after they are already more mature. If it is set too low, too many weak moves may remain in view.

That makes 15 a balanced default for swing-trading review, especially on daily and weekly charts. It can still be adjusted if a trader prefers a looser or stricter filter.

Volume and standard deviation

The volume section is designed to answer this question: is the move attracting more participation than usual, or is it happening on ordinary volume?

The script measures current volume relative to a recent baseline using:

* a 20-bar average volume
* and the standard deviation of volume over the same lookback

The average volume provides a baseline for what is normal for that symbol on that timeframe.

Standard deviation measures how much volume usually varies around that average. This matters because some stocks have stable volume while others naturally fluctuate much more. Using standard deviation helps normalize the reading so volume is judged relative to that symbol's own recent behavior.

The matrix uses four thresholds:

* Vol > 1
* Vol > 1.5
* Vol > 1.8
* Vol > 2

These represent increasing levels of volume expansion above the average, measured in standard deviations.

That means:

* Vol > 1 = current volume is at least 1 standard deviation above average
* Vol > 1.5 = stronger expansion
* Vol > 1.8 = stronger again
* Vol > 2 = unusually strong participation

These values were chosen to show a progression from moderate participation to stronger participation. One standard deviation can identify early interest, while the higher thresholds help highlight stronger or less common expansion. This makes it easier to distinguish a quiet flip from one that is attracting broader market attention.

E9 and E21

These columns show whether price is above or below the shorter-term EMAs.

They matter because they reflect near-term structure and short-term trend alignment. When price is above both, short-term structure is generally more supportive. When price is below both, short-term structure is generally weaker.

E30 and E55

These columns show intermediate structure.

They help distinguish between a short-term move and a broader trend that is starting to develop across a more meaningful part of the chart. For swing traders, these averages often reflect more durable behavior than the fastest EMAs.

E100 and E200

These columns show broader long-term structure.

They matter because they provide context for the larger trend environment. A bullish flip above long-term EMAs is often structurally stronger than a bullish flip still below them. The reverse applies for bearish setups.

These longer-term EMAs can be especially relevant on weekly charts, where they help identify broader leadership and structural quality.

RSI/SMA

This column shows whether RSI is above or below its smoothing average.

It matters because it provides a quick momentum check.

* RSI above its SMA suggests more supportive momentum
* RSI below its SMA suggests weaker or bearish momentum

This helps confirm whether momentum agrees with the trend state.

What to look for

The matrix is most useful when multiple conditions align.

The strongest bullish candidates are usually the symbols showing a fresh bullish flip, acceptable ADX, improving volume participation, broad EMA alignment, and RSI above its SMA.

The strongest bearish candidates are usually the symbols showing a fresh bearish flip, acceptable ADX, improving volume participation, weaker EMA structure, and RSI below its SMA.

That is the main purpose of the matrix. It is not meant to be read as a single-column signal board. Its value comes from confluence. A fresh flip alone may not be enough, but a fresh flip supported by strength, participation, structure, and momentum is generally more relevant for swing-trading review.

Best use case

This scanner is intended for stock watchlist review and works especially well for weekly and daily timeframe workflows.

A practical use is to review the weekly chart first to identify broader trend changes, leadership, and relative strength across the watchlist, then use the daily chart for closer follow-up and trade planning.

This longer-horizon workflow is consistent with the original Super Regression Trend concept, where longer regression settings are generally more suited to swing and longer-term positions, while shorter settings are more suited to faster trading styles.

What makes this version different

The original Super Regression Trend is a chart overlay built for analyzing one symbol at a time. This script uses the same regression-trend idea in a different format: a watchlist matrix that helps organize, rank, and compare many symbols at once.

The main purpose here is workflow efficiency. Instead of opening each chart individually, the matrix helps surface fresh flips and supporting conditions across a full stock watchlist.

Attribution

This script is based on the regression-trend concept used in the open-source Super Regression Trend by Uncle_the_shooter, adapted here into a multi-symbol matrix scanner for watchlist and swing-trading analysis.

Notes

This script is a scanner and decision-support tool. It does not predict future performance and should be used together with your own chart review, market context, and risk management.

[url=https://www.tradingview.com/script/m3kPDnoE/]https://www.tradingview.com/script/m3kPDnoE/[/url]

## Source Code

````pine
//@version=6
indicator("Super Regression Trend Matrix Scanner", overlay=true, dynamic_requests=true)

// =====================
// INPUTS
// =====================
trendGroup = "Trend Engine"
len        = input.int(20, "Regression Length", minval=5, group=trendGroup)
mult       = input.float(2.0, "RMSE Multiplier", minval=0.1, step=0.1, group=trendGroup)

colorGroup     = "Colors"
upColor        = input.color(color.rgb(6, 162, 47), "Uptrend Color", group=colorGroup)
downColor      = input.color(color.rgb(207, 23, 23), "Downtrend Color", group=colorGroup)
newBuyColor    = input.color(color.rgb(0, 255, 102), "Bright New Buy Color", group=colorGroup)
newSellColor   = input.color(color.rgb(255, 0, 85), "Bright New Sell Color", group=colorGroup)
headerColor    = input.color(color.rgb(90, 90, 90), "Header Color", group=colorGroup)
tickerBgColor  = input.color(color.rgb(15, 15, 15), "Ticker Background", group=colorGroup)
naBgColor      = input.color(color.rgb(70, 70, 70), "N/A Background", group=colorGroup)
currentBgColor = input.color(color.rgb(45, 75, 130), "Current Chart Row Color", group=colorGroup)

rsiGroup  = "RSI-SMA"
rsiLen    = input.int(14, "RSI Length", minval=1, group=rsiGroup)
rsiSmaLen = input.int(14, "RSI SMA Length", minval=1, group=rsiGroup)

matrixGroup  = "Matrix"
showMatrix   = input.bool(true, "Show Symbol Matrix", group=matrixGroup)
matrixPos    = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=matrixGroup)
matrixTextSz = input.string("Tiny", "Text Size", options=["Tiny", "Small", "Normal"], group=matrixGroup)
volLookback  = input.int(20, "Volume Lookback", minval=10, group=matrixGroup)
adxLen       = input.int(14, "ADX Length", minval=1, group=matrixGroup)
adxAcceptMin = input.float(15.0, "ADX Acceptable Above", minval=1, step=0.5, group=matrixGroup)

alertGroup      = "Alerts"
enableAlerts    = input.bool(true, "Enable Matrix Alerts", group=alertGroup)
alertOnNewBuy   = input.bool(true, "Alert on BUY NOW", group=alertGroup)
alertOnNewSell  = input.bool(true, "Alert on SELL NOW", group=alertGroup)
alertFreqChoice = input.string("Once Per Bar Close", "Alert Frequency", options=["Once Per Bar", "Once Per Bar Close", "All"], group=alertGroup)

// =====================
// SYMBOL INPUTS
// =====================
symGroup1 = "Symbols 1-10"
sym01 = input.string("NASDAQ:PLTR", "Symbol 01", group=symGroup1)
sym02 = input.string("NASDAQ:RGTI", "Symbol 02", group=symGroup1)
sym03 = input.string("NYSE:QBTS", "Symbol 03", group=symGroup1)
sym04 = input.string("NYSE:KULR", "Symbol 04", group=symGroup1)
sym05 = input.string("NASDAQ:QUBT", "Symbol 05", group=symGroup1)
sym06 = input.string("NASDAQ:ASTS", "Symbol 06", group=symGroup1)
sym07 = input.string("NASDAQ:LUNR", "Symbol 07", group=symGroup1)
sym08 = input.string("NASDAQ:RKLB", "Symbol 08", group=symGroup1)
sym09 = input.string("NYSE:BKSY", "Symbol 09", group=symGroup1)
sym10 = input.string("NASDAQ:CRDO", "Symbol 10", group=symGroup1)

symGroup2 = "Symbols 11-20"
sym11 = input.string("NYSE:JOBY", "Symbol 11", group=symGroup2)
sym12 = input.string("NYSE:NASA", "Symbol 12", group=symGroup2)
sym13 = input.string("NASDAQ:SMCI", "Symbol 13", group=symGroup2)
sym14 = input.string("NASDAQ:CRWD", "Symbol 14", group=symGroup2)
sym15 = input.string("NYSE:ACHR", "Symbol 15", group=symGroup2)
sym16 = input.string("NYSE:DNA", "Symbol 16", group=symGroup2)
sym17 = input.string("NYSE:OKLO", "Symbol 17", group=symGroup2)
sym18 = input.string("NYSE:ZETA", "Symbol 18", group=symGroup2)
sym19 = input.string("NYSE:SMR", "Symbol 19", group=symGroup2)
sym20 = input.string("NYSE:AI", "Symbol 20", group=symGroup2)

symGroup3 = "Symbols 21-30"
sym21 = input.string("NASDAQ:MU", "Symbol 21", group=symGroup3)
sym22 = input.string("NASDAQ:CRSP", "Symbol 22", group=symGroup3)
sym23 = input.string("NYSE:APP", "Symbol 23", group=symGroup3)
sym24 = input.string("NYSE:QS", "Symbol 24", group=symGroup3)
sym25 = input.string("NASDAQ:COHR", "Symbol 25", group=symGroup3)
sym26 = input.string("NYSE:HIMS", "Symbol 26", group=symGroup3)
sym27 = input.string("NYSE:UMC", "Symbol 27", group=symGroup3)
sym28 = input.string("NASDAQ:CELH", "Symbol 28", group=symGroup3)
sym29 = input.string("NASDAQ:SOUN", "Symbol 29", group=symGroup3)
sym30 = input.string("NASDAQ:SOFI", "Symbol 30", group=symGroup3)

// =====================
// HELPERS
// =====================
f_tablePos(string pos) =>
    pos == "Top Left" ? position.top_left : pos == "Bottom Left" ? position.bottom_left : pos == "Bottom Right" ? position.bottom_right : position.top_right

f_textSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

f_boolText(bool cond, string yesTxt, string noTxt) =>
    cond ? yesTxt : noTxt

f_boolBg(bool cond) =>
    cond ? color.new(upColor, 0) : color.new(downColor, 0)

f_signalBg(int dir) =>
    dir == 1 ? color.new(upColor, 0) : color.new(downColor, 0)

f_symbolLabel(string s) =>
    _s = str.trim(s)
    _s := str.replace(_s, "NASDAQ:", "")
    _s := str.replace(_s, "NYSE:", "")
    _s := str.replace(_s, "AMEX:", "")
    _s := str.replace(_s, "BATS:", "")
    _s == "" ? "EMPTY" : _s

f_validSymbolInput(string s) =>
    str.length(str.trim(s)) > 0

f_appendList(string current, string item) =>
    current == "" ? item : item == "" ? current : current + ", " + item

f_standardSymbol(string s) =>
    _s = str.trim(s)
    str.length(_s) > 0 ? ticker.standard(_s) : ""

f_securitySymbol(string s) =>
    _s = f_standardSymbol(s)
    _s == "" ? "__EMPTY__" : _s

f_regTrendState(series float _src, int _len, float _mult) =>
    _reg = ta.linreg(_src, _len, 0)
    float _err = 0.0
    for _i = 0 to _len - 1
        _err += math.pow(_src[_i] - _reg[_i], 2)
    _rmse = math.sqrt(_err / (_len - 1))
    _upperRaw = _reg + _rmse * _mult
    _lowerRaw = _reg - _rmse * _mult
    var float _upper = na
    var float _lower = na
    var int _trend = 1
    _upper := na(_upper[1]) ? _upperRaw : _trend == -1 ? math.min(_upperRaw, _upper[1]) : _upperRaw
    _lower := na(_lower[1]) ? _lowerRaw : _trend == 1 ? math.max(_lowerRaw, _lower[1]) : _lowerRaw
    _prevTrend = _trend
    _trend := _trend == 1 and _src < _lower ? -1 : _trend == -1 and _src > _upper ? 1 : _trend
    _flip = _trend != _prevTrend
    [_trend, _flip ? 1 : 0]

f_scanPack() =>
    [_trend, _flip] = f_regTrendState(close, len, mult)
    [_plusDi, _minusDi, _adx] = ta.dmi(adxLen, adxLen)
    _volMean = ta.sma(volume, volLookback)
    _volStd = ta.stdev(volume, volLookback)
    _volGt1 = volume > _volMean + 1.0 * _volStd ? 1 : 0
    _volGt15 = volume > _volMean + 1.5 * _volStd ? 1 : 0
    _volGt18 = volume > _volMean + 1.8 * _volStd ? 1 : 0
    _volGt2 = volume > _volMean + 2.0 * _volStd ? 1 : 0
    _e9 = close >= ta.ema(close, 9) ? 1 : 0
    _e21 = close >= ta.ema(close, 21) ? 1 : 0
    _e30 = close >= ta.ema(close, 30) ? 1 : 0
    _e55 = close >= ta.ema(close, 55) ? 1 : 0
    _e100 = close >= ta.ema(close, 100) ? 1 : 0
    _e200 = close >= ta.ema(close, 200) ? 1 : 0
    _rsiVal = ta.rsi(close, rsiLen)
    _rsiSmaVal = ta.sma(_rsiVal, rsiSmaLen)
    _rsiAboveSma = _rsiVal >= _rsiSmaVal ? 1 : 0
    _rsiFlip = ta.cross(_rsiVal, _rsiSmaVal) ? 1 : 0
    [_trend, _flip, _adx > adxAcceptMin ? 1 : 0, _volGt1, _volGt15, _volGt18, _volGt2, _e9, _e21, _e30, _e55, _e100, _e200, _rsiAboveSma, _rsiFlip]

f_drawRow(
    table _t,
    int _row,
    string _labelText,
    bool _isCurrent,
    bool _hasData,
    int _trendVal,
    int _flipVal,
    int _adxVal,
    int _vol1Val,
    int _vol15Val,
    int _vol18Val,
    int _vol2Val,
    int _e9Val,
    int _e21Val,
    int _e30Val,
    int _e55Val,
    int _e100Val,
    int _e200Val,
    int _rsiAboveVal,
    int _rsiFlipVal,
    string _txtSize
) =>
    txtSize = f_textSize(_txtSize)
    baseNaBg = color.new(naBgColor, 20)
    sigText = not _hasData ? "N/A" : _flipVal == 1 ? (_trendVal == 1 ? "BUY NOW" : "SELL NOW") : (_trendVal == 1 ? "BUY" : "SELL")

    tickerBg = not _hasData ? baseNaBg : _flipVal == 1 ? (_trendVal == 1 ? color.new(newBuyColor, 0) : color.new(newSellColor, 0)) : (_isCurrent ? color.new(currentBgColor, 0) : color.new(tickerBgColor, 0))
    sigBg = not _hasData ? baseNaBg : _flipVal == 1 ? (_trendVal == 1 ? color.new(newBuyColor, 0) : color.new(newSellColor, 0)) : f_signalBg(_trendVal)
    rsiBg = not _hasData ? baseNaBg : _rsiFlipVal == 1 ? (_rsiAboveVal == 1 ? color.new(newBuyColor, 0) : color.new(newSellColor, 0)) : f_boolBg(_rsiAboveVal == 1)

    table.cell(_t, 0, _row, _labelText, text_color=color.white, bgcolor=tickerBg, text_size=txtSize)
    table.cell(_t, 1, _row, sigText, text_color=color.white, bgcolor=sigBg, text_size=txtSize)
    table.cell(_t, 2, _row, not _hasData ? "N/A" : f_boolText(_adxVal == 1, "OK", "WEAK"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_adxVal == 1), text_size=txtSize)
    table.cell(_t, 3, _row, not _hasData ? "N/A" : f_boolText(_vol1Val == 1, "Y", "N"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_vol1Val == 1), text_size=txtSize)
    table.cell(_t, 4, _row, not _hasData ? "N/A" : f_boolText(_vol15Val == 1, "Y", "N"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_vol15Val == 1), text_size=txtSize)
    table.cell(_t, 5, _row, not _hasData ? "N/A" : f_boolText(_vol18Val == 1, "Y", "N"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_vol18Val == 1), text_size=txtSize)
    table.cell(_t, 6, _row, not _hasData ? "N/A" : f_boolText(_vol2Val == 1, "Y", "N"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_vol2Val == 1), text_size=txtSize)
    table.cell(_t, 7, _row, not _hasData ? "N/A" : f_boolText(_e9Val == 1, "+", "-"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_e9Val == 1), text_size=txtSize)
    table.cell(_t, 8, _row, not _hasData ? "N/A" : f_boolText(_e21Val == 1, "+", "-"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_e21Val == 1), text_size=txtSize)
    table.cell(_t, 9, _row, not _hasData ? "N/A" : f_boolText(_e30Val == 1, "+", "-"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_e30Val == 1), text_size=txtSize)
    table.cell(_t, 10, _row, not _hasData ? "N/A" : f_boolText(_e55Val == 1, "+", "-"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_e55Val == 1), text_size=txtSize)
    table.cell(_t, 11, _row, not _hasData ? "N/A" : f_boolText(_e100Val == 1, "+", "-"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_e100Val == 1), text_size=txtSize)
    table.cell(_t, 12, _row, not _hasData ? "N/A" : f_boolText(_e200Val == 1, "+", "-"), text_color=color.white, bgcolor=not _hasData ? baseNaBg : f_boolBg(_e200Val == 1), text_size=txtSize)
    table.cell(_t, 13, _row, not _hasData ? "N/A" : f_boolText(_rsiAboveVal == 1, "Above", "Below"), text_color=color.white, bgcolor=rsiBg, text_size=txtSize)

f_storeSymbol(
    string _stdSym,
    int _trendIn,
    int _flipIn,
    int _adxIn,
    int _vol1In,
    int _vol15In,
    int _vol18In,
    int _vol2In,
    int _e9In,
    int _e21In,
    int _e30In,
    int _e55In,
    int _e100In,
    int _e200In,
    int _rsiAboveIn,
    int _rsiFlipIn,
    string _currentTickerId,
    array<string> _labelsArr,
    array<bool> _hasDataArr,
    array<int> _trendArr,
    array<int> _flipArr,
    array<int> _adxArr,
    array<int> _vol1Arr,
    array<int> _vol15Arr,
    array<int> _vol18Arr,
    array<int> _vol2Arr,
    array<int> _e9Arr,
    array<int> _e21Arr,
    array<int> _e30Arr,
    array<int> _e55Arr,
    array<int> _e100Arr,
    array<int> _e200Arr,
    array<int> _rsiAboveArr,
    array<int> _rsiFlipArr,
    array<int> _orderArr,
    array<int> _scoreArr
) =>
    _buyTriggered = false
    _sellTriggered = false
    _buyLabel = ""
    _sellLabel = ""

    _isDuplicateCurrent = _stdSym == _currentTickerId
    _hasData = f_validSymbolInput(_stdSym) and _trendIn != 0
    _labelText = f_symbolLabel(_stdSym)

    if not _isDuplicateCurrent
        array.push(_labelsArr, _labelText)
        array.push(_hasDataArr, _hasData)
        array.push(_trendArr, _trendIn)
        array.push(_flipArr, _flipIn)
        array.push(_adxArr, _adxIn)
        array.push(_vol1Arr, _vol1In)
        array.push(_vol15Arr, _vol15In)
        array.push(_vol18Arr, _vol18In)
        array.push(_vol2Arr, _vol2In)
        array.push(_e9Arr, _e9In)
        array.push(_e21Arr, _e21In)
        array.push(_e30Arr, _e30In)
        array.push(_e55Arr, _e55In)
        array.push(_e100Arr, _e100In)
        array.push(_e200Arr, _e200In)
        array.push(_rsiAboveArr, _rsiAboveIn)
        array.push(_rsiFlipArr, _rsiFlipIn)

        _rowIndex = array.size(_labelsArr) - 1
        _sortScore = _flipIn == 1 ? (_trendIn == 1 ? 20 : 19) : 0
        array.push(_orderArr, _rowIndex)
        array.push(_scoreArr, _sortScore)

        if _hasData and _flipIn == 1
            if _trendIn == 1
                _buyTriggered := true
                _buyLabel := _labelText
            else if _trendIn == -1
                _sellTriggered := true
                _sellLabel := _labelText

    [_buyTriggered, _sellTriggered, _buyLabel, _sellLabel]

// =====================
// STATIC DATA
// =====================
headers = array.from("Ticker", "Signal", "ADX", "Vol>1", "Vol>1.5", "Vol>1.8", "Vol>2", "E9", "E21", "E30", "E55", "E100", "E200", "RSI/SMA")

// =====================
// CURRENT CHART
// =====================
currentTickerId = ticker.standard(syminfo.tickerid)
[curTrend, curFlip, curAdx, curVol1, curVol15, curVol18, curVol2, curE9, curE21, curE30, curE55, curE100, curE200, curRsiAbove, curRsiFlip] = f_scanPack()
curHasData = true
curLabel = "★ " + f_symbolLabel(currentTickerId)

// =====================
// RESULT ARRAYS
// =====================
var labelsArr    = array.new_string()
var hasDataArr   = array.new_bool()
var trendArr     = array.new_int()
var flipArr      = array.new_int()
var adxArr       = array.new_int()
var vol1Arr      = array.new_int()
var vol15Arr     = array.new_int()
var vol18Arr     = array.new_int()
var vol2Arr      = array.new_int()
var e9Arr        = array.new_int()
var e21Arr       = array.new_int()
var e30Arr       = array.new_int()
var e55Arr       = array.new_int()
var e100Arr      = array.new_int()
var e200Arr      = array.new_int()
var rsiAboveArr  = array.new_int()
var rsiFlipArr   = array.new_int()
var orderArr     = array.new_int()
var scoreArr     = array.new_int()

array.clear(labelsArr)
array.clear(hasDataArr)
array.clear(trendArr)
array.clear(flipArr)
array.clear(adxArr)
array.clear(vol1Arr)
array.clear(vol15Arr)
array.clear(vol18Arr)
array.clear(vol2Arr)
array.clear(e9Arr)
array.clear(e21Arr)
array.clear(e30Arr)
array.clear(e55Arr)
array.clear(e100Arr)
array.clear(e200Arr)
array.clear(rsiAboveArr)
array.clear(rsiFlipArr)
array.clear(orderArr)
array.clear(scoreArr)

// =====================
// ALERT LISTS
// =====================
bool anyNewBuy = false
bool anyNewSell = false
string newBuyList = ""
string newSellList = ""

if curFlip == 1
    if curTrend == 1
        anyNewBuy := true
        newBuyList := f_appendList(newBuyList, f_symbolLabel(currentTickerId))
    else if curTrend == -1
        anyNewSell := true
        newSellList := f_appendList(newSellList, f_symbolLabel(currentTickerId))

// =====================
// TOP-LEVEL SECURITY CALLS
// =====================
sym01Std = f_standardSymbol(sym01)
sym02Std = f_standardSymbol(sym02)
sym03Std = f_standardSymbol(sym03)
sym04Std = f_standardSymbol(sym04)
sym05Std = f_standardSymbol(sym05)
sym06Std = f_standardSymbol(sym06)
sym07Std = f_standardSymbol(sym07)
sym08Std = f_standardSymbol(sym08)
sym09Std = f_standardSymbol(sym09)
sym10Std = f_standardSymbol(sym10)
sym11Std = f_standardSymbol(sym11)
sym12Std = f_standardSymbol(sym12)
sym13Std = f_standardSymbol(sym13)
sym14Std = f_standardSymbol(sym14)
sym15Std = f_standardSymbol(sym15)
sym16Std = f_standardSymbol(sym16)
sym17Std = f_standardSymbol(sym17)
sym18Std = f_standardSymbol(sym18)
sym19Std = f_standardSymbol(sym19)
sym20Std = f_standardSymbol(sym20)
sym21Std = f_standardSymbol(sym21)
sym22Std = f_standardSymbol(sym22)
sym23Std = f_standardSymbol(sym23)
sym24Std = f_standardSymbol(sym24)
sym25Std = f_standardSymbol(sym25)
sym26Std = f_standardSymbol(sym26)
sym27Std = f_standardSymbol(sym27)
sym28Std = f_standardSymbol(sym28)
sym29Std = f_standardSymbol(sym29)
sym30Std = f_standardSymbol(sym30)

[a01, b01, c01, d01, e01, f01, g01, h01, j01, k01, l01, m01, n01, o01, p01] = request.security(f_securitySymbol(sym01), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a02, b02, c02, d02, e02, f02, g02, h02, j02, k02, l02, m02, n02, o02, p02] = request.security(f_securitySymbol(sym02), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a03, b03, c03, d03, e03, f03, g03, h03, j03, k03, l03, m03, n03, o03, p03] = request.security(f_securitySymbol(sym03), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a04, b04, c04, d04, e04, f04, g04, h04, j04, k04, l04, m04, n04, o04, p04] = request.security(f_securitySymbol(sym04), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a05, b05, c05, d05, e05, f05, g05, h05, j05, k05, l05, m05, n05, o05, p05] = request.security(f_securitySymbol(sym05), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a06, b06, c06, d06, e06, f06, g06, h06, j06, k06, l06, m06, n06, o06, p06] = request.security(f_securitySymbol(sym06), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a07, b07, c07, d07, e07, f07, g07, h07, j07, k07, l07, m07, n07, o07, p07] = request.security(f_securitySymbol(sym07), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a08, b08, c08, d08, e08, f08, g08, h08, j08, k08, l08, m08, n08, o08, p08] = request.security(f_securitySymbol(sym08), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a09, b09, c09, d09, e09, f09, g09, h09, j09, k09, l09, m09, n09, o09, p09] = request.security(f_securitySymbol(sym09), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a10, b10, c10, d10, e10, f10, g10, h10, j10, k10, l10, m10, n10, o10, p10] = request.security(f_securitySymbol(sym10), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)

[a11, b11, c11, d11, e11, f11, g11, h11, j11, k11, l11, m11, n11, o11, p11] = request.security(f_securitySymbol(sym11), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a12, b12, c12, d12, e12, f12, g12, h12, j12, k12, l12, m12, n12, o12, p12] = request.security(f_securitySymbol(sym12), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a13, b13, c13, d13, e13, f13, g13, h13, j13, k13, l13, m13, n13, o13, p13] = request.security(f_securitySymbol(sym13), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a14, b14, c14, d14, e14, f14, g14, h14, j14, k14, l14, m14, n14, o14, p14] = request.security(f_securitySymbol(sym14), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a15, b15, c15, d15, e15, f15, g15, h15, j15, k15, l15, m15, n15, o15, p15] = request.security(f_securitySymbol(sym15), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a16, b16, c16, d16, e16, f16, g16, h16, j16, k16, l16, m16, n16, o16, p16] = request.security(f_securitySymbol(sym16), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a17, b17, c17, d17, e17, f17, g17, h17, j17, k17, l17, m17, n17, o17, p17] = request.security(f_securitySymbol(sym17), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a18, b18, c18, d18, e18, f18, g18, h18, j18, k18, l18, m18, n18, o18, p18] = request.security(f_securitySymbol(sym18), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a19, b19, c19, d19, e19, f19, g19, h19, j19, k19, l19, m19, n19, o19, p19] = request.security(f_securitySymbol(sym19), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a20, b20, c20, d20, e20, f20, g20, h20, j20, k20, l20, m20, n20, o20, p20] = request.security(f_securitySymbol(sym20), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)

[a21, b21, c21, d21, e21s, f21, g21, h21, j21, k21, l21, m21, n21, o21, p21] = request.security(f_securitySymbol(sym21), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a22, b22, c22, d22, e22s, f22, g22, h22, j22, k22, l22, m22, n22, o22, p22] = request.security(f_securitySymbol(sym22), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a23, b23, c23, d23, e23s, f23, g23, h23, j23, k23, l23, m23, n23, o23, p23] = request.security(f_securitySymbol(sym23), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a24, b24, c24, d24, e24s, f24, g24, h24, j24, k24, l24, m24, n24, o24, p24] = request.security(f_securitySymbol(sym24), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a25, b25, c25, d25, e25s, f25, g25, h25, j25, k25, l25, m25, n25, o25, p25] = request.security(f_securitySymbol(sym25), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a26, b26, c26, d26, e26s, f26, g26, h26, j26, k26, l26, m26, n26, o26, p26] = request.security(f_securitySymbol(sym26), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a27, b27, c27, d27, e27s, f27, g27, h27, j27, k27, l27, m27, n27, o27, p27] = request.security(f_securitySymbol(sym27), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a28, b28, c28, d28, e28s, f28, g28, h28, j28, k28, l28, m28, n28, o28, p28] = request.security(f_securitySymbol(sym28), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a29, b29, c29, d29, e29s, f29, g29, h29, j29, k29, l29, m29, n29, o29, p29] = request.security(f_securitySymbol(sym29), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)
[a30, b30, c30, d30, e30s, f30, g30, h30, j30, k30, l30, m30, n30, o30, p30] = request.security(f_securitySymbol(sym30), timeframe.period, f_scanPack(), ignore_invalid_symbol=true)

// =====================
// STORE RESULTS
// =====================
[buy01, sell01, buyLbl01, sellLbl01] = f_storeSymbol(sym01Std, na(a01) ? 0 : int(a01), na(b01) ? 0 : int(b01), na(c01) ? 0 : int(c01), na(d01) ? 0 : int(d01), na(e01) ? 0 : int(e01), na(f01) ? 0 : int(f01), na(g01) ? 0 : int(g01), na(h01) ? 0 : int(h01), na(j01) ? 0 : int(j01), na(k01) ? 0 : int(k01), na(l01) ? 0 : int(l01), na(m01) ? 0 : int(m01), na(n01) ? 0 : int(n01), na(o01) ? 0 : int(o01), na(p01) ? 0 : int(p01), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy02, sell02, buyLbl02, sellLbl02] = f_storeSymbol(sym02Std, na(a02) ? 0 : int(a02), na(b02) ? 0 : int(b02), na(c02) ? 0 : int(c02), na(d02) ? 0 : int(d02), na(e02) ? 0 : int(e02), na(f02) ? 0 : int(f02), na(g02) ? 0 : int(g02), na(h02) ? 0 : int(h02), na(j02) ? 0 : int(j02), na(k02) ? 0 : int(k02), na(l02) ? 0 : int(l02), na(m02) ? 0 : int(m02), na(n02) ? 0 : int(n02), na(o02) ? 0 : int(o02), na(p02) ? 0 : int(p02), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy03, sell03, buyLbl03, sellLbl03] = f_storeSymbol(sym03Std, na(a03) ? 0 : int(a03), na(b03) ? 0 : int(b03), na(c03) ? 0 : int(c03), na(d03) ? 0 : int(d03), na(e03) ? 0 : int(e03), na(f03) ? 0 : int(f03), na(g03) ? 0 : int(g03), na(h03) ? 0 : int(h03), na(j03) ? 0 : int(j03), na(k03) ? 0 : int(k03), na(l03) ? 0 : int(l03), na(m03) ? 0 : int(m03), na(n03) ? 0 : int(n03), na(o03) ? 0 : int(o03), na(p03) ? 0 : int(p03), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy04, sell04, buyLbl04, sellLbl04] = f_storeSymbol(sym04Std, na(a04) ? 0 : int(a04), na(b04) ? 0 : int(b04), na(c04) ? 0 : int(c04), na(d04) ? 0 : int(d04), na(e04) ? 0 : int(e04), na(f04) ? 0 : int(f04), na(g04) ? 0 : int(g04), na(h04) ? 0 : int(h04), na(j04) ? 0 : int(j04), na(k04) ? 0 : int(k04), na(l04) ? 0 : int(l04), na(m04) ? 0 : int(m04), na(n04) ? 0 : int(n04), na(o04) ? 0 : int(o04), na(p04) ? 0 : int(p04), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy05, sell05, buyLbl05, sellLbl05] = f_storeSymbol(sym05Std, na(a05) ? 0 : int(a05), na(b05) ? 0 : int(b05), na(c05) ? 0 : int(c05), na(d05) ? 0 : int(d05), na(e05) ? 0 : int(e05), na(f05) ? 0 : int(f05), na(g05) ? 0 : int(g05), na(h05) ? 0 : int(h05), na(j05) ? 0 : int(j05), na(k05) ? 0 : int(k05), na(l05) ? 0 : int(l05), na(m05) ? 0 : int(m05), na(n05) ? 0 : int(n05), na(o05) ? 0 : int(o05), na(p05) ? 0 : int(p05), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy06, sell06, buyLbl06, sellLbl06] = f_storeSymbol(sym06Std, na(a06) ? 0 : int(a06), na(b06) ? 0 : int(b06), na(c06) ? 0 : int(c06), na(d06) ? 0 : int(d06), na(e06) ? 0 : int(e06), na(f06) ? 0 : int(f06), na(g06) ? 0 : int(g06), na(h06) ? 0 : int(h06), na(j06) ? 0 : int(j06), na(k06) ? 0 : int(k06), na(l06) ? 0 : int(l06), na(m06) ? 0 : int(m06), na(n06) ? 0 : int(n06), na(o06) ? 0 : int(o06), na(p06) ? 0 : int(p06), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy07, sell07, buyLbl07, sellLbl07] = f_storeSymbol(sym07Std, na(a07) ? 0 : int(a07), na(b07) ? 0 : int(b07), na(c07) ? 0 : int(c07), na(d07) ? 0 : int(d07), na(e07) ? 0 : int(e07), na(f07) ? 0 : int(f07), na(g07) ? 0 : int(g07), na(h07) ? 0 : int(h07), na(j07) ? 0 : int(j07), na(k07) ? 0 : int(k07), na(l07) ? 0 : int(l07), na(m07) ? 0 : int(m07), na(n07) ? 0 : int(n07), na(o07) ? 0 : int(o07), na(p07) ? 0 : int(p07), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy08, sell08, buyLbl08, sellLbl08] = f_storeSymbol(sym08Std, na(a08) ? 0 : int(a08), na(b08) ? 0 : int(b08), na(c08) ? 0 : int(c08), na(d08) ? 0 : int(d08), na(e08) ? 0 : int(e08), na(f08) ? 0 : int(f08), na(g08) ? 0 : int(g08), na(h08) ? 0 : int(h08), na(j08) ? 0 : int(j08), na(k08) ? 0 : int(k08), na(l08) ? 0 : int(l08), na(m08) ? 0 : int(m08), na(n08) ? 0 : int(n08), na(o08) ? 0 : int(o08), na(p08) ? 0 : int(p08), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy09, sell09, buyLbl09, sellLbl09] = f_storeSymbol(sym09Std, na(a09) ? 0 : int(a09), na(b09) ? 0 : int(b09), na(c09) ? 0 : int(c09), na(d09) ? 0 : int(d09), na(e09) ? 0 : int(e09), na(f09) ? 0 : int(f09), na(g09) ? 0 : int(g09), na(h09) ? 0 : int(h09), na(j09) ? 0 : int(j09), na(k09) ? 0 : int(k09), na(l09) ? 0 : int(l09), na(m09) ? 0 : int(m09), na(n09) ? 0 : int(n09), na(o09) ? 0 : int(o09), na(p09) ? 0 : int(p09), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy10, sell10, buyLbl10, sellLbl10] = f_storeSymbol(sym10Std, na(a10) ? 0 : int(a10), na(b10) ? 0 : int(b10), na(c10) ? 0 : int(c10), na(d10) ? 0 : int(d10), na(e10) ? 0 : int(e10), na(f10) ? 0 : int(f10), na(g10) ? 0 : int(g10), na(h10) ? 0 : int(h10), na(j10) ? 0 : int(j10), na(k10) ? 0 : int(k10), na(l10) ? 0 : int(l10), na(m10) ? 0 : int(m10), na(n10) ? 0 : int(n10), na(o10) ? 0 : int(o10), na(p10) ? 0 : int(p10), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)

[buy11, sell11, buyLbl11, sellLbl11] = f_storeSymbol(sym11Std, na(a11) ? 0 : int(a11), na(b11) ? 0 : int(b11), na(c11) ? 0 : int(c11), na(d11) ? 0 : int(d11), na(e11) ? 0 : int(e11), na(f11) ? 0 : int(f11), na(g11) ? 0 : int(g11), na(h11) ? 0 : int(h11), na(j11) ? 0 : int(j11), na(k11) ? 0 : int(k11), na(l11) ? 0 : int(l11), na(m11) ? 0 : int(m11), na(n11) ? 0 : int(n11), na(o11) ? 0 : int(o11), na(p11) ? 0 : int(p11), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy12, sell12, buyLbl12, sellLbl12] = f_storeSymbol(sym12Std, na(a12) ? 0 : int(a12), na(b12) ? 0 : int(b12), na(c12) ? 0 : int(c12), na(d12) ? 0 : int(d12), na(e12) ? 0 : int(e12), na(f12) ? 0 : int(f12), na(g12) ? 0 : int(g12), na(h12) ? 0 : int(h12), na(j12) ? 0 : int(j12), na(k12) ? 0 : int(k12), na(l12) ? 0 : int(l12), na(m12) ? 0 : int(m12), na(n12) ? 0 : int(n12), na(o12) ? 0 : int(o12), na(p12) ? 0 : int(p12), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy13, sell13, buyLbl13, sellLbl13] = f_storeSymbol(sym13Std, na(a13) ? 0 : int(a13), na(b13) ? 0 : int(b13), na(c13) ? 0 : int(c13), na(d13) ? 0 : int(d13), na(e13) ? 0 : int(e13), na(f13) ? 0 : int(f13), na(g13) ? 0 : int(g13), na(h13) ? 0 : int(h13), na(j13) ? 0 : int(j13), na(k13) ? 0 : int(k13), na(l13) ? 0 : int(l13), na(m13) ? 0 : int(m13), na(n13) ? 0 : int(n13), na(o13) ? 0 : int(o13), na(p13) ? 0 : int(p13), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy14, sell14, buyLbl14, sellLbl14] = f_storeSymbol(sym14Std, na(a14) ? 0 : int(a14), na(b14) ? 0 : int(b14), na(c14) ? 0 : int(c14), na(d14) ? 0 : int(d14), na(e14) ? 0 : int(e14), na(f14) ? 0 : int(f14), na(g14) ? 0 : int(g14), na(h14) ? 0 : int(h14), na(j14) ? 0 : int(j14), na(k14) ? 0 : int(k14), na(l14) ? 0 : int(l14), na(m14) ? 0 : int(m14), na(n14) ? 0 : int(n14), na(o14) ? 0 : int(o14), na(p14) ? 0 : int(p14), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy15, sell15, buyLbl15, sellLbl15] = f_storeSymbol(sym15Std, na(a15) ? 0 : int(a15), na(b15) ? 0 : int(b15), na(c15) ? 0 : int(c15), na(d15) ? 0 : int(d15), na(e15) ? 0 : int(e15), na(f15) ? 0 : int(f15), na(g15) ? 0 : int(g15), na(h15) ? 0 : int(h15), na(j15) ? 0 : int(j15), na(k15) ? 0 : int(k15), na(l15) ? 0 : int(l15), na(m15) ? 0 : int(m15), na(n15) ? 0 : int(n15), na(o15) ? 0 : int(o15), na(p15) ? 0 : int(p15), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy16, sell16, buyLbl16, sellLbl16] = f_storeSymbol(sym16Std, na(a16) ? 0 : int(a16), na(b16) ? 0 : int(b16), na(c16) ? 0 : int(c16), na(d16) ? 0 : int(d16), na(e16) ? 0 : int(e16), na(f16) ? 0 : int(f16), na(g16) ? 0 : int(g16), na(h16) ? 0 : int(h16), na(j16) ? 0 : int(j16), na(k16) ? 0 : int(k16), na(l16) ? 0 : int(l16), na(m16) ? 0 : int(m16), na(n16) ? 0 : int(n16), na(o16) ? 0 : int(o16), na(p16) ? 0 : int(p16), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy17, sell17, buyLbl17, sellLbl17] = f_storeSymbol(sym17Std, na(a17) ? 0 : int(a17), na(b17) ? 0 : int(b17), na(c17) ? 0 : int(c17), na(d17) ? 0 : int(d17), na(e17) ? 0 : int(e17), na(f17) ? 0 : int(f17), na(g17) ? 0 : int(g17), na(h17) ? 0 : int(h17), na(j17) ? 0 : int(j17), na(k17) ? 0 : int(k17), na(l17) ? 0 : int(l17), na(m17) ? 0 : int(m17), na(n17) ? 0 : int(n17), na(o17) ? 0 : int(o17), na(p17) ? 0 : int(p17), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy18, sell18, buyLbl18, sellLbl18] = f_storeSymbol(sym18Std, na(a18) ? 0 : int(a18), na(b18) ? 0 : int(b18), na(c18) ? 0 : int(c18), na(d18) ? 0 : int(d18), na(e18) ? 0 : int(e18), na(f18) ? 0 : int(f18), na(g18) ? 0 : int(g18), na(h18) ? 0 : int(h18), na(j18) ? 0 : int(j18), na(k18) ? 0 : int(k18), na(l18) ? 0 : int(l18), na(m18) ? 0 : int(m18), na(n18) ? 0 : int(n18), na(o18) ? 0 : int(o18), na(p18) ? 0 : int(p18), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy19, sell19, buyLbl19, sellLbl19] = f_storeSymbol(sym19Std, na(a19) ? 0 : int(a19), na(b19) ? 0 : int(b19), na(c19) ? 0 : int(c19), na(d19) ? 0 : int(d19), na(e19) ? 0 : int(e19), na(f19) ? 0 : int(f19), na(g19) ? 0 : int(g19), na(h19) ? 0 : int(h19), na(j19) ? 0 : int(j19), na(k19) ? 0 : int(k19), na(l19) ? 0 : int(l19), na(m19) ? 0 : int(m19), na(n19) ? 0 : int(n19), na(o19) ? 0 : int(o19), na(p19) ? 0 : int(p19), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy20, sell20, buyLbl20, sellLbl20] = f_storeSymbol(sym20Std, na(a20) ? 0 : int(a20), na(b20) ? 0 : int(b20), na(c20) ? 0 : int(c20), na(d20) ? 0 : int(d20), na(e20) ? 0 : int(e20), na(f20) ? 0 : int(f20), na(g20) ? 0 : int(g20), na(h20) ? 0 : int(h20), na(j20) ? 0 : int(j20), na(k20) ? 0 : int(k20), na(l20) ? 0 : int(l20), na(m20) ? 0 : int(m20), na(n20) ? 0 : int(n20), na(o20) ? 0 : int(o20), na(p20) ? 0 : int(p20), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)

[buy21, sell21, buyLbl21, sellLbl21] = f_storeSymbol(sym21Std, na(a21) ? 0 : int(a21), na(b21) ? 0 : int(b21), na(c21) ? 0 : int(c21), na(d21) ? 0 : int(d21), na(e21s) ? 0 : int(e21s), na(f21) ? 0 : int(f21), na(g21) ? 0 : int(g21), na(h21) ? 0 : int(h21), na(j21) ? 0 : int(j21), na(k21) ? 0 : int(k21), na(l21) ? 0 : int(l21), na(m21) ? 0 : int(m21), na(n21) ? 0 : int(n21), na(o21) ? 0 : int(o21), na(p21) ? 0 : int(p21), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy22, sell22, buyLbl22, sellLbl22] = f_storeSymbol(sym22Std, na(a22) ? 0 : int(a22), na(b22) ? 0 : int(b22), na(c22) ? 0 : int(c22), na(d22) ? 0 : int(d22), na(e22s) ? 0 : int(e22s), na(f22) ? 0 : int(f22), na(g22) ? 0 : int(g22), na(h22) ? 0 : int(h22), na(j22) ? 0 : int(j22), na(k22) ? 0 : int(k22), na(l22) ? 0 : int(l22), na(m22) ? 0 : int(m22), na(n22) ? 0 : int(n22), na(o22) ? 0 : int(o22), na(p22) ? 0 : int(p22), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy23, sell23, buyLbl23, sellLbl23] = f_storeSymbol(sym23Std, na(a23) ? 0 : int(a23), na(b23) ? 0 : int(b23), na(c23) ? 0 : int(c23), na(d23) ? 0 : int(d23), na(e23s) ? 0 : int(e23s), na(f23) ? 0 : int(f23), na(g23) ? 0 : int(g23), na(h23) ? 0 : int(h23), na(j23) ? 0 : int(j23), na(k23) ? 0 : int(k23), na(l23) ? 0 : int(l23), na(m23) ? 0 : int(m23), na(n23) ? 0 : int(n23), na(o23) ? 0 : int(o23), na(p23) ? 0 : int(p23), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy24, sell24, buyLbl24, sellLbl24] = f_storeSymbol(sym24Std, na(a24) ? 0 : int(a24), na(b24) ? 0 : int(b24), na(c24) ? 0 : int(c24), na(d24) ? 0 : int(d24), na(e24s) ? 0 : int(e24s), na(f24) ? 0 : int(f24), na(g24) ? 0 : int(g24), na(h24) ? 0 : int(h24), na(j24) ? 0 : int(j24), na(k24) ? 0 : int(k24), na(l24) ? 0 : int(l24), na(m24) ? 0 : int(m24), na(n24) ? 0 : int(n24), na(o24) ? 0 : int(o24), na(p24) ? 0 : int(p24), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy25, sell25, buyLbl25, sellLbl25] = f_storeSymbol(sym25Std, na(a25) ? 0 : int(a25), na(b25) ? 0 : int(b25), na(c25) ? 0 : int(c25), na(d25) ? 0 : int(d25), na(e25s) ? 0 : int(e25s), na(f25) ? 0 : int(f25), na(g25) ? 0 : int(g25), na(h25) ? 0 : int(h25), na(j25) ? 0 : int(j25), na(k25) ? 0 : int(k25), na(l25) ? 0 : int(l25), na(m25) ? 0 : int(m25), na(n25) ? 0 : int(n25), na(o25) ? 0 : int(o25), na(p25) ? 0 : int(p25), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy26, sell26, buyLbl26, sellLbl26] = f_storeSymbol(sym26Std, na(a26) ? 0 : int(a26), na(b26) ? 0 : int(b26), na(c26) ? 0 : int(c26), na(d26) ? 0 : int(d26), na(e26s) ? 0 : int(e26s), na(f26) ? 0 : int(f26), na(g26) ? 0 : int(g26), na(h26) ? 0 : int(h26), na(j26) ? 0 : int(j26), na(k26) ? 0 : int(k26), na(l26) ? 0 : int(l26), na(m26) ? 0 : int(m26), na(n26) ? 0 : int(n26), na(o26) ? 0 : int(o26), na(p26) ? 0 : int(p26), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy27, sell27, buyLbl27, sellLbl27] = f_storeSymbol(sym27Std, na(a27) ? 0 : int(a27), na(b27) ? 0 : int(b27), na(c27) ? 0 : int(c27), na(d27) ? 0 : int(d27), na(e27s) ? 0 : int(e27s), na(f27) ? 0 : int(f27), na(g27) ? 0 : int(g27), na(h27) ? 0 : int(h27), na(j27) ? 0 : int(j27), na(k27) ? 0 : int(k27), na(l27) ? 0 : int(l27), na(m27) ? 0 : int(m27), na(n27) ? 0 : int(n27), na(o27) ? 0 : int(o27), na(p27) ? 0 : int(p27), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy28, sell28, buyLbl28, sellLbl28] = f_storeSymbol(sym28Std, na(a28) ? 0 : int(a28), na(b28) ? 0 : int(b28), na(c28) ? 0 : int(c28), na(d28) ? 0 : int(d28), na(e28s) ? 0 : int(e28s), na(f28) ? 0 : int(f28), na(g28) ? 0 : int(g28), na(h28) ? 0 : int(h28), na(j28) ? 0 : int(j28), na(k28) ? 0 : int(k28), na(l28) ? 0 : int(l28), na(m28) ? 0 : int(m28), na(n28) ? 0 : int(n28), na(o28) ? 0 : int(o28), na(p28) ? 0 : int(p28), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy29, sell29, buyLbl29, sellLbl29] = f_storeSymbol(sym29Std, na(a29) ? 0 : int(a29), na(b29) ? 0 : int(b29), na(c29) ? 0 : int(c29), na(d29) ? 0 : int(d29), na(e29s) ? 0 : int(e29s), na(f29) ? 0 : int(f29), na(g29) ? 0 : int(g29), na(h29) ? 0 : int(h29), na(j29) ? 0 : int(j29), na(k29) ? 0 : int(k29), na(l29) ? 0 : int(l29), na(m29) ? 0 : int(m29), na(n29) ? 0 : int(n29), na(o29) ? 0 : int(o29), na(p29) ? 0 : int(p29), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)
[buy30, sell30, buyLbl30, sellLbl30] = f_storeSymbol(sym30Std, na(a30) ? 0 : int(a30), na(b30) ? 0 : int(b30), na(c30) ? 0 : int(c30), na(d30) ? 0 : int(d30), na(e30s) ? 0 : int(e30s), na(f30) ? 0 : int(f30), na(g30) ? 0 : int(g30), na(h30) ? 0 : int(h30), na(j30) ? 0 : int(j30), na(k30) ? 0 : int(k30), na(l30) ? 0 : int(l30), na(m30) ? 0 : int(m30), na(n30) ? 0 : int(n30), na(o30) ? 0 : int(o30), na(p30) ? 0 : int(p30), currentTickerId, labelsArr, hasDataArr, trendArr, flipArr, adxArr, vol1Arr, vol15Arr, vol18Arr, vol2Arr, e9Arr, e21Arr, e30Arr, e55Arr, e100Arr, e200Arr, rsiAboveArr, rsiFlipArr, orderArr, scoreArr)

if buy01
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl01)
if sell01
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl01)
if buy02
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl02)
if sell02
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl02)
if buy03
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl03)
if sell03
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl03)
if buy04
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl04)
if sell04
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl04)
if buy05
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl05)
if sell05
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl05)
if buy06
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl06)
if sell06
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl06)
if buy07
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl07)
if sell07
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl07)
if buy08
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl08)
if sell08
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl08)
if buy09
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl09)
if sell09
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl09)
if buy10
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl10)
if sell10
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl10)

if buy11
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl11)
if sell11
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl11)
if buy12
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl12)
if sell12
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl12)
if buy13
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl13)
if sell13
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl13)
if buy14
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl14)
if sell14
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl14)
if buy15
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl15)
if sell15
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl15)
if buy16
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl16)
if sell16
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl16)
if buy17
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl17)
if sell17
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl17)
if buy18
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl18)
if sell18
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl18)
if buy19
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl19)
if sell19
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl19)
if buy20
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl20)
if sell20
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl20)

if buy21
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl21)
if sell21
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl21)
if buy22
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl22)
if sell22
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl22)
if buy23
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl23)
if sell23
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl23)
if buy24
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl24)
if sell24
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl24)
if buy25
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl25)
if sell25
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl25)
if buy26
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl26)
if sell26
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl26)
if buy27
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl27)
if sell27
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl27)
if buy28
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl28)
if sell28
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl28)
if buy29
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl29)
if sell29
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl29)
if buy30
    anyNewBuy := true
    newBuyList := f_appendList(newBuyList, buyLbl30)
if sell30
    anyNewSell := true
    newSellList := f_appendList(newSellList, sellLbl30)

// =====================
// SORT WATCHLIST ROWS
// =====================
orderCount = array.size(orderArr)
if orderCount > 1
    for i = 0 to orderCount - 2
        bestPos = i
        bestScore = array.get(scoreArr, i)
        for j = i + 1 to orderCount - 1
            candidateScore = array.get(scoreArr, j)
            if candidateScore > bestScore
                bestScore := candidateScore
                bestPos := j
        if bestPos != i
            tempScore = array.get(scoreArr, i)
            tempOrder = array.get(orderArr, i)
            array.set(scoreArr, i, array.get(scoreArr, bestPos))
            array.set(orderArr, i, array.get(orderArr, bestPos))
            array.set(scoreArr, bestPos, tempScore)
            array.set(orderArr, bestPos, tempOrder)

// =====================
// ALERTS
// =====================
buyCondition = enableAlerts and alertOnNewBuy and anyNewBuy
sellCondition = enableAlerts and alertOnNewSell and anyNewSell

alertcondition(buyCondition, title="Matrix BUY NOW", message="One or more symbols flipped to BUY NOW in the matrix.")
alertcondition(sellCondition, title="Matrix SELL NOW", message="One or more symbols flipped to SELL NOW in the matrix.")

if barstate.isrealtime and enableAlerts
    if buyCondition
        if alertFreqChoice == "All"
            alert("Matrix BUY NOW: " + newBuyList, alert.freq_all)
        else if alertFreqChoice == "Once Per Bar"
            alert("Matrix BUY NOW: " + newBuyList, alert.freq_once_per_bar)
        else
            alert("Matrix BUY NOW: " + newBuyList, alert.freq_once_per_bar_close)

    if sellCondition
        if alertFreqChoice == "All"
            alert("Matrix SELL NOW: " + newSellList, alert.freq_all)
        else if alertFreqChoice == "Once Per Bar"
            alert("Matrix SELL NOW: " + newSellList, alert.freq_once_per_bar)
        else
            alert("Matrix SELL NOW: " + newSellList, alert.freq_once_per_bar_close)

// =====================
// TABLE
// =====================
matrixCols = 14
matrixRows = 32
var table statusMatrix = table.new(f_tablePos(matrixPos), matrixCols, matrixRows, frame_color=color.gray, frame_width=1, border_width=1)

if barstate.islast
    if showMatrix
        table.clear(statusMatrix, 0, 0, matrixCols - 1, matrixRows - 1)

        txtSize = f_textSize(matrixTextSz)
        for col = 0 to matrixCols - 1
            table.cell(statusMatrix, col, 0, array.get(headers, col), text_color=color.white, bgcolor=headerColor, text_size=txtSize)

        f_drawRow(statusMatrix, 1, curLabel, true, curHasData, curTrend, curFlip, curAdx, curVol1, curVol15, curVol18, curVol2, curE9, curE21, curE30, curE55, curE100, curE200, curRsiAbove, curRsiFlip, matrixTextSz)

        drawRow = 2
        for i = 0 to array.size(orderArr) - 1
            srcIndex = array.get(orderArr, i)

            rowLabel = array.get(labelsArr, srcIndex)
            hasData = array.get(hasDataArr, srcIndex)
            trendVal = array.get(trendArr, srcIndex)
            flipVal = array.get(flipArr, srcIndex)
            adxVal = array.get(adxArr, srcIndex)
            vol1Val = array.get(vol1Arr, srcIndex)
            vol15Val = array.get(vol15Arr, srcIndex)
            vol18Val = array.get(vol18Arr, srcIndex)
            vol2Val = array.get(vol2Arr, srcIndex)
            e9Val = array.get(e9Arr, srcIndex)
            e21Val = array.get(e21Arr, srcIndex)
            e30Val = array.get(e30Arr, srcIndex)
            e55Val = array.get(e55Arr, srcIndex)
            e100Val = array.get(e100Arr, srcIndex)
            e200Val = array.get(e200Arr, srcIndex)
            rsiAboveVal = array.get(rsiAboveArr, srcIndex)
            rsiFlipVal = array.get(rsiFlipArr, srcIndex)

            f_drawRow(statusMatrix, drawRow, rowLabel, false, hasData, trendVal, flipVal, adxVal, vol1Val, vol15Val, vol18Val, vol2Val, e9Val, e21Val, e30Val, e55Val, e100Val, e200Val, rsiAboveVal, rsiFlipVal, matrixTextSz)
            drawRow += 1
    else
        table.clear(statusMatrix, 0, 0, matrixCols - 1, matrixRows - 1)
````
