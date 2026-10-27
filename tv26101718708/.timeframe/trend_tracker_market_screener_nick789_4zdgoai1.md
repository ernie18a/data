# Trend Tracker Market Screener [NICK789]

- url: https://www.tradingview.com/script/4ZDgoAI1-Trend-Tracker-Market-Screener-NICK789/
- type: indicator
- pine_id: PUB;4ce9216b13f4405f8ebbc3190a2e9ac4
- version: 2.0

## Description

Trend Tracker Market Screener [NICK789]

Trend Tracker Market Screener is a multi-symbol trend dashboard designed to scan up to 20 user-selected tickers from one table. It helps traders monitor trend direction, fresh trend flips, flip-risk warnings, trend strength, volume flow, relative volume, session timing, and possible trade-ready conditions.

This script is built as a market scanner, not a standalone buy/sell system. Its purpose is to reduce chart-hopping and help traders quickly find which symbols deserve attention.

Core concept

The screener is built around a custom Trend Tracker engine that combines:

* EMA-based trend basis
* ATR-based upper and lower bands
* Supertrend-style trailing logic
* Confirmed trend flip detection
* Volume-flow confirmation
* Relative volume filtering
* Session-based trade window scoring
* Optional higher-timeframe alignment

How the Trend Tracker engine works

* The script first calculates an EMA-based centre line.
* In Scalp mode, the faster EMA is used for a more reactive tracker.
* In Trend mode, the tracker uses smoother fast/slow EMA logic for more stable trend tracking.
* ATR bands are built above and below the EMA basis.
* A bullish trend state is confirmed when price breaks above the previous upper ATR band.
* A bearish trend state is confirmed when price breaks below the previous lower ATR band.
* Once direction is set, the tracker trails on the opposite side of price until the opposite band condition is broken.
* Fresh LONG and SHORT flips are detected when the confirmed tracker direction changes.

What the screener displays

The table is designed to give a fast market overview:

* TICKER: selected symbol
* TF: timeframe being scanned
* DIR: current confirmed LONG or SHORT trend state
* AGE: how long ago the latest confirmed flip occurred
* STR: trend strength score
* FLOW: estimated trend-volume delta
* MTF: optional higher-timeframe alignment
* HEAT: quick state label such as Fresh, Hot, Warm, Active, Cold, or Flip Risk
* ATR: distance between price and tracker in ATR units
* RVOL: current volume compared to its volume baseline
* WINDOW: session and volume-based trade window score
* ACTION: simplified status such as Wait, Watch, Long Setup, Short Setup, Low Vol, Bad Time, Extended, or RSI Hot

How the filters work together

This screener is not a random combination of indicators. Each component answers a specific part of the market-scanning process:

* Trend direction shows whether a symbol is currently bullish or bearish.
* Fresh flip logic shows when a new confirmed trend change has happened.
* Flip-risk warning shows when price is pressing near the opposite ATR band before a confirmed flip.
* Trend age helps separate new trends from older trends.
* Trend delta flow estimates whether volume pressure supports the active trend.
* Trend strength combines ATR distance and supportive flow into one strength score.
* RVOL shows whether current activity is above or below normal volume.
* Trade window score uses London/New York session timing and RVOL to judge whether market conditions are more active or quiet.
* Higher-timeframe filter can be used to focus only on symbols aligned with a selected larger timeframe.
* Action status combines the main conditions into one simple readout.

Display modes

All 20 Trend States

* Shows the selected tickers and their current trend state.
* Useful for general watchlist monitoring.

Fresh Signals Only

* Shows only recent flips and optional flip-risk warnings.
* Useful when traders only want to see symbols that may need attention now.

Timeframe behaviour

For best accuracy, use a chart timeframe equal to or lower than the selected screener timeframe.

Examples:

* A 15-minute screener works best on a 15-minute chart or lower.
* A 1-hour screener works best on a 1-hour chart or lower.
* If the chart timeframe is higher than the selected screener timeframe, the script displays a timeframe warning and uses the chart timeframe as a fallback.

This fallback is included to avoid misleading lower-timeframe data when Pine cannot fully process every lower-timeframe bar from a higher-timeframe chart.

Alerts

The script includes TradingView alert conditions for:

* LONG flip
* SHORT flip
* Any confirmed flip
* LONG trade-ready setup
* SHORT trade-ready setup
* Any trade-ready setup
* LONG flip-risk warning
* SHORT flip-risk warning
* Any flip-risk warning
* Master alert

For dynamic ticker messages, create an alert using TradingView’s “Any alert() function call” option. This allows the alert message to include the symbols that triggered during the confirmed bar.

Suggested workflow

1. Select the screener timeframe.
2. Add up to 20 symbols.
3. Choose All 20 Trend States or Fresh Signals Only.
4. Check the ACTION column for Long Setup, Short Setup, Watch, or Wait.
5. Review RVOL and WINDOW to see whether the market is active.
6. Review FLOW and STR to check whether trend pressure supports the move.
7. Use MTF alignment if higher-timeframe filtering is enabled.
8. Open the individual chart before making any trade decision.

Important notes

* Fresh flips are confirmed tracker direction changes.
* Flip-risk warnings are caution signals, not confirmed entries.
* The action column is a decision-support label, not financial advice.
* The trade window score measures activity and timing conditions, not future direction.
* The higher-timeframe filter may reduce signals and can filter out early moves.
* This script is designed for scanning and filtering, not guaranteed trade execution.

Disclaimer

This indicator is for educational and informational purposes only. It is not financial advice. Traders should test the script on their own markets and timeframes, use proper risk management, and make independent trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator("Trend Tracker Market Screener [NICK789]", "TT Market Screener", overlay=false, max_labels_count=500, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE TREND TRACKER ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpCore = "Trend Tracker Engine"

src = input.source(ohlc4, "Source", group=grpCore)
trackerMode = input.string("Scalp", "Tracker Mode", options=["Scalp", "Trend"], group=grpCore, tooltip="Scalp mode reacts faster. Trend mode is smoother.")
trackerFastLen = input.int(9, "Fast Length", minval=1, group=grpCore)
trackerSlowLen = input.int(21, "Slow Length", minval=1, group=grpCore)
trackerATRLen  = input.int(14, "ATR Length", minval=1, group=grpCore)
trackerATRMult = input.float(1.6, "ATR Multiplier", minval=0.1, step=0.1, group=grpCore)
useTrueATR     = input.bool(true, "Use True ATR?", group=grpCore)

fastLen = trackerMode == "Scalp" ? trackerFastLen : trackerSlowLen
slowLen = trackerMode == "Scalp" ? math.max(trackerSlowLen, trackerFastLen + 3) : math.max(trackerSlowLen * 2, trackerFastLen + 5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCREENER SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpScreen = "Screener"

screenTF = input.timeframe("15", "Screener Timeframe", options=["1", "3", "5", "15", "30", "60", "240", "D", "W"], group=grpScreen)

chartTfSec = timeframe.in_seconds(timeframe.period)
screenTfSec = timeframe.in_seconds(screenTF)
screenTfLowerThanChart = not na(chartTfSec) and not na(screenTfSec) and screenTfSec < chartTfSec

scanTF = screenTfLowerThanChart ? timeframe.period : screenTF
scanTfLabel = screenTfLowerThanChart ? timeframe.period + " fallback" : screenTF
scanTfSec = screenTfLowerThanChart ? chartTfSec : screenTfSec

displayMode = input.string("All 20 Trend States", "Display Mode", options=["All 20 Trend States", "Fresh Signals Only"], group=grpScreen)
showOnlyFresh = displayMode == "Fresh Signals Only"

freshBars = input.int(3, "Fresh Signal Window Bars", minval=1, maxval=50, group=grpScreen, tooltip="Used only for fresh signal display and fresh-signal alerts.")
freshFlashBars = input.int(4, "Fresh Flip Yellow Flash Bars", minval=1, maxval=10, group=grpScreen)
showCount = input.int(20, "Tickers To Scan", minval=1, maxval=20, group=grpScreen)

staleGuardBars = input.float(2.0, "Closed-Market Guard Bars", minval=1.0, maxval=10.0, step=0.5, group=grpScreen, tooltip="Prevents closed-market symbols from repeating old alerts on active 24/7 charts. Non-crypto symbols become stale when their last scanned bar is older than this many screener bars.")

useMtfFilter = input.bool(false, "Use Higher-TF Direction Filter", group=grpScreen)
mtfFilterTf = input.timeframe("60", "Higher-TF Filter", options=["5", "15", "30", "60", "240", "D"], group=grpScreen)
showFlow = input.bool(true, "Show Trend Delta Flow", group=grpScreen)

mtfTfSec = timeframe.in_seconds(mtfFilterTf)
mtfTfLowerThanScan = useMtfFilter and not na(mtfTfSec) and not na(scanTfSec) and mtfTfSec < scanTfSec
safeMtfTF = mtfTfLowerThanScan ? scanTF : mtfFilterTf
safeMtfLabel = not useMtfFilter ? "off" : mtfTfLowerThanScan ? scanTfLabel + " fallback" : mtfFilterTf

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE WINDOW / RVOL / ACTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpAction = "Trade Window / RVOL / Action"

showTradeWindow = input.bool(true, "Show Trade Window Column", group=grpAction)
useWindowGate = input.bool(false, "Gate Alerts To GOOD/PRIME Window", group=grpAction)
useActionGate = input.bool(false, "Gate Alerts To LONG/SHORT SETUP Only", group=grpAction)

rvolLen = input.int(20, "RVOL Baseline Length", minval=5, maxval=300, group=grpAction)
rvolHot = input.float(1.50, "RVOL Hot Threshold", minval=0.10, maxval=10.0, step=0.10, group=grpAction)

windowGood = input.float(55.0, "GOOD Window Score", minval=1.0, maxval=100.0, step=1.0, group=grpAction)
windowPrime = input.float(75.0, "PRIME Window Score", minval=1.0, maxval=100.0, step=1.0, group=grpAction)

actionMaxAtrDist = input.float(1.25, "Max ATR Dist For Setup", minval=0.10, maxval=5.0, step=0.05, group=grpAction)

rsiLen = input.int(14, "RSI Filter Length", minval=2, maxval=100, group=grpAction)
rsiLongMax = input.float(72.0, "Avoid LONG Above RSI", minval=50.0, maxval=100.0, step=1.0, group=grpAction)
rsiShortMin = input.float(28.0, "Avoid SHORT Below RSI", minval=0.0, maxval=50.0, step=1.0, group=grpAction)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEAT / STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpHeat = "Heat / Strength"

strengthHot = input.float(70.0, "HOT Strength Threshold", minval=1.0, maxval=100.0, step=1.0, group=grpHeat)
strengthWarm = input.float(40.0, "WARM Strength Threshold", minval=1.0, maxval=100.0, step=1.0, group=grpHeat)
youngTrendBars = input.int(8, "Young Trend Window Bars", minval=1, maxval=200, group=grpHeat, tooltip="Used only for HOT heat label. This is separate from Fresh Signal Window Bars.")
atrNearTracker = input.float(0.25, "Near Tracker ATR Highlight", minval=0.05, maxval=2.0, step=0.05, group=grpHeat)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TICKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpTickers = "Tickers"

s01 = input.symbol("OANDA:EURUSD", "Ticker 01", group=grpTickers)
s02 = input.symbol("OANDA:USDJPY", "Ticker 02", group=grpTickers)
s03 = input.symbol("OANDA:GBPUSD", "Ticker 03", group=grpTickers)
s04 = input.symbol("OANDA:AUDUSD", "Ticker 04", group=grpTickers)
s05 = input.symbol("OANDA:USDCAD", "Ticker 05", group=grpTickers)

s06 = input.symbol("BINANCE:BTCUSDT", "Ticker 06", group=grpTickers)
s07 = input.symbol("BINANCE:ETHUSDT", "Ticker 07", group=grpTickers)
s08 = input.symbol("BINANCE:SOLUSDT", "Ticker 08", group=grpTickers)
s09 = input.symbol("BINANCE:XRPUSDT", "Ticker 09", group=grpTickers)
s10 = input.symbol("BINANCE:BNBUSDT", "Ticker 10", group=grpTickers)

s11 = input.symbol("CME_MINI:ES1!", "Ticker 11", group=grpTickers)
s12 = input.symbol("CME_MINI:NQ1!", "Ticker 12", group=grpTickers)
s13 = input.symbol("NYMEX:CL1!", "Ticker 13", group=grpTickers)
s14 = input.symbol("COMEX:GC1!", "Ticker 14", group=grpTickers)
s15 = input.symbol("CBOT:ZN1!", "Ticker 15", group=grpTickers)

s16 = input.symbol("OANDA:SPX500USD", "Ticker 16", group=grpTickers)
s17 = input.symbol("OANDA:NAS100USD", "Ticker 17", group=grpTickers)
s18 = input.symbol("OANDA:US30USD", "Ticker 18", group=grpTickers)
s19 = input.symbol("OANDA:DE30EUR", "Ticker 19", group=grpTickers)
s20 = input.symbol("OANDA:UK100GBP", "Ticker 20", group=grpTickers)

string[] SYMS = array.from(s01, s02, s03, s04, s05, s06, s07, s08, s09, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpDisp = "Display"

tablePosOpt = input.string("Top Center", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center"], group=grpDisp)
tableSizeOpt = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDisp)

bullColor       = input.color(color.rgb(8, 153, 129), "LONG Color", group=grpDisp)
bearColor       = input.color(color.rgb(242, 54, 69), "SHORT Color", group=grpDisp)
neutralColor    = input.color(color.rgb(150, 150, 150), "Neutral Text", group=grpDisp)
freshFlashColor = input.color(color.yellow, "Fresh Flip Flash Color", group=grpDisp)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpAlert = "Alerts"

useDynamicAlert  = input.bool(true, "Use Dynamic Alert Message", group=grpAlert)
alertLong        = input.bool(true, "Alert LONG Flip", group=grpAlert)
alertShort       = input.bool(true, "Alert SHORT Flip", group=grpAlert)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tblPos(string opt) =>
    switch opt
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Top Center" => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_left

f_size(string opt) =>
    opt == "Tiny" ? size.tiny : opt == "Small" ? size.small : opt == "Normal" ? size.normal : size.large

f_pretty(string s) =>
    string out = s
    int colon = str.pos(out, ":")
    if colon != -1
        out := str.substring(out, colon + 1, str.length(out))
    int dot = str.pos(out, ".")
    if dot != -1
        out := str.substring(out, 0, dot)
    out

f_is_247_symbol(string s) =>
    str.pos(s, "BINANCE:") != -1 or str.pos(s, "BYBIT:") != -1 or str.pos(s, "BITGET:") != -1 or str.pos(s, "COINBASE:") != -1 or str.pos(s, "KRAKEN:") != -1 or str.pos(s, "OKX:") != -1 or str.pos(s, "CRYPTO:") != -1

f_is_scan_stale(int scanBarTime, bool isAlwaysOpen) =>
    bool stale = false
    if not isAlwaysOpen and not na(scanBarTime) and not na(scanTfSec)
        stale := float(time - scanBarTime) > float(scanTfSec) * 1000.0 * staleGuardBars
    stale

f_ageTxt(float bars, float mins) =>
    na(bars) or na(mins) ? "—" : mins < 60 ? str.tostring(mins, "#") + "m" : mins < 1440 ? str.tostring(mins / 60.0, "#.0") + "h" : str.tostring(mins / 1440.0, "#.0") + "d"

f_atrDistTxt(float dist) =>
    na(dist) ? "—" : str.tostring(dist, "#.00") + "x"

f_rvolTxt(float rvol) =>
    na(rvol) ? "—" : str.tostring(rvol, "#.00") + "x"

f_trade_window_score(float rvol, bool isAlwaysOpen, int barTime, bool isStale) =>
    float safeRvol = na(rvol) ? 1.0 : rvol
    float score = na

    if isStale or na(barTime)
        score := na
    else if isAlwaysOpen
        score := math.min(safeRvol, 2.0) / 2.0 * 100.0
    else
        int nyMin = hour(barTime, "America/New_York") * 60 + minute(barTime, "America/New_York")
        int lonMin = hour(barTime, "Europe/London") * 60 + minute(barTime, "Europe/London")

        bool londonOpen = lonMin >= 480 and lonMin < 600
        bool londonNyOverlap = lonMin >= 780 and lonMin < 1020
        bool nyPreOpen = nyMin >= 480 and nyMin < 570
        bool nyCashOpen = nyMin >= 570 and nyMin < 690
        bool nyMidSession = nyMin >= 690 and nyMin < 900
        bool nyPowerHour = nyMin >= 900 and nyMin < 960

        float volScore = math.min(safeRvol, 2.0) / 2.0 * 45.0
        float sessionScore = londonNyOverlap ? 55.0 : nyCashOpen ? 55.0 : londonOpen ? 45.0 : nyPowerHour ? 45.0 : nyPreOpen ? 35.0 : nyMidSession ? 30.0 : 20.0

        score := math.min(sessionScore + volScore, 100.0)

    score

f_window_values(float score, bool isStale) =>
    string txt = isStale ? "CLOSED" : not showTradeWindow ? "off" : na(score) ? "—" : score >= windowPrime ? "PRIME " + str.tostring(score, "#") : score >= windowGood ? "GOOD " + str.tostring(score, "#") : score >= 35.0 ? "WAIT " + str.tostring(score, "#") : "SLEEPY " + str.tostring(score, "#")
    color txtCol = isStale ? neutralColor : not showTradeWindow ? neutralColor : na(score) ? neutralColor : score >= windowPrime ? color.white : score >= windowGood ? color.yellow : score >= 35.0 ? neutralColor : color.rgb(255, 120, 120)
    color bg = isStale ? color.black : not showTradeWindow or na(score) ? color.black : score >= windowPrime ? color.new(color.green, 20) : score >= windowGood ? color.new(color.yellow, 80) : color.black
    [txt, txtCol, bg]

f_window_alert(float score, bool isStale) =>
    isStale or not showTradeWindow or na(score) ? "" : score >= windowPrime ? " | PRIME WINDOW " + str.tostring(score, "#") : score >= windowGood ? " | GOOD WINDOW " + str.tostring(score, "#") : score >= 35.0 ? " | WAIT WINDOW " + str.tostring(score, "#") : " | SLEEPY WINDOW " + str.tostring(score, "#")

f_is_trade_now(int side, bool freshActive, float atrDist, float rvol, float rsiVal, float tradeWindowScore, bool isStale) =>
    bool goodWindow = not showTradeWindow or tradeWindowScore >= windowGood
    bool hotVol = rvol >= rvolHot
    bool atrOk = atrDist <= actionMaxAtrDist
    bool rsiOk = side == 1 ? rsiVal <= rsiLongMax : rsiVal >= rsiShortMin
    not isStale and freshActive and hotVol and goodWindow and atrOk and rsiOk

f_action_values(int side, bool freshActive, float atrDist, float rvol, float rsiVal, float tradeWindowScore, bool isStale) =>
    bool isLong = side == 1
    bool goodWindow = not showTradeWindow or tradeWindowScore >= windowGood
    bool hotVol = rvol >= rvolHot
    bool atrOk = atrDist <= actionMaxAtrDist
    bool rsiOk = isLong ? rsiVal <= rsiLongMax : rsiVal >= rsiShortMin
    bool tradeNow = f_is_trade_now(side, freshActive, atrDist, rvol, rsiVal, tradeWindowScore, isStale)

    string txt = isStale ? "CLOSED" : tradeNow ? (isLong ? "LONG SETUP" : "SHORT SETUP") : not freshActive ? "WAIT" : not hotVol ? "LOW VOL" : not goodWindow ? "BAD TIME" : not atrOk ? "EXTENDED" : not rsiOk ? "RSI HOT" : "WATCH"
    color bg = isStale ? color.black : tradeNow ? color.new(isLong ? bullColor : bearColor, 0) : txt == "LOW VOL" ? color.new(color.gray, 70) : txt == "BAD TIME" ? color.new(color.red, 75) : txt == "EXTENDED" ? color.new(color.orange, 75) : color.black
    color txtCol = isStale ? neutralColor : tradeNow ? color.white : txt == "WAIT" ? neutralColor : color.white

    [txt, txtCol, bg]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRACKER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tracker_raw() =>
    float _basisFast = ta.ema(src, fastLen)
    float _basisSlow = ta.ema(src, slowLen)
    float _basisCore = trackerMode == "Scalp" ? _basisFast : (_basisFast + _basisSlow) / 2.0
    float _atrValue = useTrueATR ? ta.atr(trackerATRLen) : ta.sma(ta.tr(true), trackerATRLen)
    float _upperBand = _basisCore + _atrValue * trackerATRMult
    float _lowerBand = _basisCore - _atrValue * trackerATRMult

    var float _tracker = na
    var int _dir = 1

    if na(_tracker[1])
        _tracker := _lowerBand
        _dir := 1
    else
        float _prevTracker = _tracker[1]
        int _prevDir = nz(_dir[1], 1)

        if src > _upperBand[1]
            _dir := 1
        else if src < _lowerBand[1]
            _dir := -1
        else
            _dir := _prevDir

        float _bullTrack = math.max(_lowerBand, _prevDir == 1 ? _prevTracker : _lowerBand)
        float _bearTrack = math.min(_upperBand, _prevDir == -1 ? _prevTracker : _upperBand)

        _tracker := _dir == 1 ? _bullTrack : _bearTrack

    [_tracker, _dir, _upperBand, _lowerBand, _atrValue]

f_tracker_confirmed_dir() =>
    [_rawTracker, _rawDir, _upperBand, _lowerBand, _atrValue] = f_tracker_raw()
    _rawDir

f_tracker_pack() =>
    [_rawTracker, _rawDir, _upperBand, _lowerBand, _atrValue] = f_tracker_raw()

    int _outDir = _rawDir
    float _outTracker = _rawTracker

    bool _confirmedChanged = _outDir != nz(_outDir[1], _outDir)
    bool _bullFlip = _outDir == 1 and nz(_outDir[1], 1) == -1
    bool _bearFlip = _outDir == -1 and nz(_outDir[1], 1) == 1

    var int _trendStartBar = na

    if na(_trendStartBar) or _confirmedChanged
        _trendStartBar := bar_index

    float _trendAgeBars = na(_trendStartBar) ? na : float(bar_index - _trendStartBar)

    float _buyVol = close > open ? volume : close == open ? volume * 0.5 : 0.0
    float _sellVol = close < open ? volume : close == open ? volume * 0.5 : 0.0

    var float _trendBuyVol = 0.0
    var float _trendSellVol = 0.0

    if _confirmedChanged
        _trendBuyVol := 0.0
        _trendSellVol := 0.0

    _trendBuyVol += _buyVol
    _trendSellVol += _sellVol

    float _totalVol = _trendBuyVol + _trendSellVol
    float _deltaPct = _totalVol > 0 ? (_trendBuyVol - _trendSellVol) / _totalVol * 100.0 : 0.0
    bool _flowOk = _outDir == 1 ? _deltaPct >= 0 : _deltaPct <= 0

    float _distATR = _atrValue > 0 and not na(_outTracker) ? math.abs(src - _outTracker) / _atrValue : 0.0
    float _distScore = math.min(_distATR, 2.0) / 2.0 * 55.0
    float _flowScore = math.min(math.abs(_deltaPct), 100.0) / 100.0 * 45.0
    float _strengthRaw = _distScore + _flowScore
    float _trendStrength = _flowOk ? math.min(_strengthRaw, 100.0) : math.min(_strengthRaw * 0.55, 100.0)

    var int _lastSigBar = na
    var int _lastSigSide = 0

    if _bullFlip or _bearFlip
        _lastSigBar := bar_index
        _lastSigSide := _bullFlip ? 1 : -1

    float _sigAgeBars = na(_lastSigBar) ? na : float(bar_index - _lastSigBar)
    float _tfMin = timeframe.in_seconds(timeframe.period) / 60.0
    float _sigAgeMin = na(_sigAgeBars) ? na : _sigAgeBars * _tfMin

    float _volBase = ta.sma(volume, rvolLen)
    float _rvol = not na(volume) and not na(_volBase) and _volBase > 0 ? volume / _volBase : 0.0
    float _rsiVal = ta.rsi(close, rsiLen)

    [time, close, _outDir, _bullFlip, _bearFlip, float(_lastSigSide), _sigAgeBars, _sigAgeMin, _trendAgeBars, _deltaPct, _flowOk, _trendStrength, _distATR, _rvol, _rsiVal]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int COLS = 12
int ROWS = 21

textSize = f_size(tableSizeOpt)
var table tb = table.new(f_tblPos(tablePosOpt), COLS, ROWS, bgcolor=color.black, border_width=1)
var int[] LAST_SCAN_TIME = array.new_int(20, 0)

f_clear_all() =>
    for r = 0 to ROWS - 1
        for cc = 0 to COLS - 1
            table.cell(tb, cc, r, "", text_color=neutralColor, bgcolor=color.black, text_size=textSize)

f_header() =>
    color hdrBg = color.rgb(25, 38, 68)

    table.cell(tb, 0, 0, "TICKER", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 1, 0, "TF", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 2, 0, "DIR", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 3, 0, "AGE", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 4, 0, "STR", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 5, 0, "FLOW", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 6, 0, "MTF", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 7, 0, "HEAT", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 8, 0, "ATR", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 9, 0, "RVOL", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 10, 0, "WINDOW", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 11, 0, "ACTION", text_color=color.white, bgcolor=hdrBg, text_size=textSize)

f_heat_values(int dir, float sigAgeBars, float trendAgeBars, float trendStrength, bool flowOk, bool freshActive, bool isStale) =>
    bool isFreshNow = freshActive and not na(sigAgeBars) and sigAgeBars < freshFlashBars
    bool isYoungTrend = not na(trendAgeBars) and trendAgeBars <= youngTrendBars
    bool strongTrend = trendStrength >= strengthHot
    bool mediumTrend = trendStrength >= strengthWarm

    string heatTxt = isStale ? "CLOSED" : isFreshNow ? "🔥 FRESH" : isYoungTrend and strongTrend and flowOk ? "🔥 HOT" : mediumTrend and flowOk ? "🟡 WARM" : flowOk ? "🟢 ACTIVE" : "❄ COLD"
    color sideCol = dir == 1 ? bullColor : bearColor
    color heatTxtCol = isStale ? neutralColor : isFreshNow ? color.black : isYoungTrend and strongTrend and flowOk ? color.white : mediumTrend and flowOk ? color.black : flowOk ? sideCol : neutralColor
    color heatBg = isStale ? color.black : isFreshNow ? freshFlashColor : isYoungTrend and strongTrend and flowOk ? color.new(sideCol, 10) : mediumTrend and flowOk ? color.new(color.yellow, 20) : color.black

    [heatTxt, heatTxtCol, heatBg]

f_strength_values(float trendStrength, color sideCol) =>
    string strengthTxt = na(trendStrength) ? "—" : str.tostring(trendStrength, "#") + "%"
    color strengthTxtCol = na(trendStrength) ? neutralColor : trendStrength >= strengthHot ? color.white : trendStrength >= strengthWarm ? color.yellow : neutralColor
    color strengthBg = not na(trendStrength) and trendStrength >= strengthHot ? color.new(sideCol, 10) : color.black

    [strengthTxt, strengthTxtCol, strengthBg]

f_atr_dist_color(float dist) =>
    na(dist) ? neutralColor : dist <= atrNearTracker ? color.orange : dist >= 2.0 ? color.aqua : neutralColor

f_rvol_color(float rvol) =>
    na(rvol) ? neutralColor : rvol >= rvolHot ? color.lime : rvol >= 1.0 ? color.yellow : neutralColor

f_put_row(int row, string sym, int dir, int lastSide, float sigAgeBars, float sigAgeMin, float trendAgeBars, float trendStrength, float atrDist, float rvol, float rsiVal, float tradeWindowScore, float deltaPct, bool flowOk, int mtfDir, bool freshActive, bool scanIsStale) =>
    int activeSide = freshActive ? lastSide : dir
    bool rowIsLong = activeSide == 1
    color sideCol = rowIsLong ? bullColor : bearColor

    string dirTxt = freshActive ? (rowIsLong ? "▲ LONG NOW" : "▼ SHORT NOW") : (rowIsLong ? "▲ LONG" : "▼ SHORT")
    string flowTxt = showFlow ? str.tostring(deltaPct, "+#.0;-#.0") + "%" : "off"
    color flowCol = flowOk ? sideCol : neutralColor

    string mtfTxt = not useMtfFilter ? "off" : mtfDir == 1 ? "HTF LONG" : "HTF SHORT"
    color mtfCol = not useMtfFilter ? neutralColor : mtfDir == activeSide ? sideCol : color.orange

    bool flashTicker = freshActive and not na(sigAgeBars) and sigAgeBars < freshFlashBars
    color tickerBg = flashTicker ? freshFlashColor : color.black
    color tickerTxt = flashTicker ? color.black : color.white

    [strengthTxt, strengthTxtCol, strengthBg] = f_strength_values(trendStrength, sideCol)
    [heatTxt, heatTxtCol, heatBg] = f_heat_values(dir, sigAgeBars, trendAgeBars, trendStrength, flowOk, freshActive, scanIsStale)
    [windowTxt, windowTxtCol, windowBg] = f_window_values(tradeWindowScore, scanIsStale)
    [actionTxt, actionTxtCol, actionBg] = f_action_values(activeSide, freshActive, atrDist, rvol, rsiVal, tradeWindowScore, scanIsStale)

    table.cell(tb, 0, row, f_pretty(sym), text_color=tickerTxt, bgcolor=tickerBg, text_size=textSize)
    table.cell(tb, 1, row, scanTfLabel, text_color=screenTfLowerThanChart ? color.orange : neutralColor, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 2, row, dirTxt, text_color=color.white, bgcolor=color.new(sideCol, 15), text_size=textSize)
    table.cell(tb, 3, row, f_ageTxt(sigAgeBars, sigAgeMin), text_color=sideCol, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 4, row, strengthTxt, text_color=strengthTxtCol, bgcolor=strengthBg, text_size=textSize)
    table.cell(tb, 5, row, flowTxt, text_color=flowCol, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 6, row, mtfTxt, text_color=mtfCol, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 7, row, heatTxt, text_color=heatTxtCol, bgcolor=heatBg, text_size=textSize)
    table.cell(tb, 8, row, f_atrDistTxt(atrDist), text_color=f_atr_dist_color(atrDist), bgcolor=color.black, text_size=textSize)
    table.cell(tb, 9, row, f_rvolTxt(rvol), text_color=f_rvol_color(rvol), bgcolor=color.black, text_size=textSize)
    table.cell(tb, 10, row, windowTxt, text_color=windowTxtCol, bgcolor=windowBg, text_size=textSize)
    table.cell(tb, 11, row, actionTxt, text_color=actionTxtCol, bgcolor=actionBg, text_size=textSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE BUILD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
table.set_position(tb, f_tblPos(tablePosOpt))

f_clear_all()
f_header()

int outRow = 1

if screenTfLowerThanChart
    table.cell(tb, 0, outRow, "TF WARNING", text_color=color.black, bgcolor=color.orange, text_size=textSize)
    table.cell(tb, 1, outRow, "Chart TF > Screener TF", text_color=color.orange, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 2, outRow, "Using chart TF fallback", text_color=color.orange, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 3, outRow, "Set chart <= screener TF", text_color=color.orange, bgcolor=color.black, text_size=textSize)
    outRow += 1

if mtfTfLowerThanScan
    table.cell(tb, 0, outRow, "HTF WARNING", text_color=color.black, bgcolor=color.orange, text_size=textSize)
    table.cell(tb, 1, outRow, "HTF < Scan TF", text_color=color.orange, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 2, outRow, "Using safe HTF fallback", text_color=color.orange, bgcolor=color.black, text_size=textSize)
    table.cell(tb, 3, outRow, safeMtfLabel, text_color=color.orange, bgcolor=color.black, text_size=textSize)
    outRow += 1

int firstDataRow = outRow

bool anyFreshLong = false
bool anyFreshShort = false

bool anyReadyLong = false
bool anyReadyShort = false
string alertMsg = "Trend Tracker Market Screener\n"

for idx = 0 to 19
    if idx < showCount
        string sym = array.get(SYMS, idx)
        bool isAlwaysOpen = f_is_247_symbol(sym)

        [barTime, priceClose, dirFloat, bullFlip, bearFlip, lastSideFloat, sigAgeBars, sigAgeMin, trendAgeBars, deltaPct, flowOk, trendStrength, atrDist, rvol, rsiVal] = request.security(sym, scanTF, f_tracker_pack(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

        bool invalid = na(priceClose)

        int prevScanTime = array.get(LAST_SCAN_TIME, idx)
        bool newScanBar = not invalid and not na(barTime) and (prevScanTime == 0 or barTime != prevScanTime)

        if not invalid and not na(barTime)
            array.set(LAST_SCAN_TIME, idx, barTime)

        bool scanIsStale = not invalid and f_is_scan_stale(barTime, isAlwaysOpen)
        float tradeWindowScore = invalid ? na : f_trade_window_score(rvol, isAlwaysOpen, barTime, scanIsStale)

        int dir = int(dirFloat)
        int lastSide = int(lastSideFloat)

        int mtfDir = useMtfFilter ? request.security(sym, safeMtfTF, f_tracker_confirmed_dir(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : dir

        bool fresh = not invalid and not scanIsStale and lastSide != 0 and not na(sigAgeBars) and sigAgeBars <= freshBars

        bool mtfPassFresh = not useMtfFilter or lastSide == mtfDir
        bool mtfPassTrend = not useMtfFilter or dir == mtfDir

        bool actionNow = f_is_trade_now(lastSide, fresh, atrDist, rvol, rsiVal, tradeWindowScore, scanIsStale)
        bool windowPassAlert = not useWindowGate or not showTradeWindow or (not na(tradeWindowScore) and tradeWindowScore >= windowGood)
        bool actionPassAlert = not useActionGate or actionNow

        bool displayRow = not invalid and (showOnlyFresh ? fresh and mtfPassFresh : mtfPassTrend)

        if displayRow and outRow < ROWS
            f_put_row(outRow, sym, dir, lastSide, sigAgeBars, sigAgeMin, trendAgeBars, trendStrength, atrDist, rvol, rsiVal, tradeWindowScore, deltaPct, flowOk, mtfDir, fresh, scanIsStale)
            outRow += 1

        bool freshLongFlip = newScanBar and not scanIsStale and bullFlip and mtfPassFresh and windowPassAlert and alertLong
        bool freshShortFlip = newScanBar and not scanIsStale and bearFlip and mtfPassFresh and windowPassAlert and alertShort

        bool readyLongFlip = freshLongFlip and actionNow
        bool readyShortFlip = freshShortFlip and actionNow

        bool fireLong = freshLongFlip and actionPassAlert
        bool fireShort = freshShortFlip and actionPassAlert

        string windowNote = f_window_alert(tradeWindowScore, scanIsStale)
        string rvolNote = " | RVOL " + str.tostring(rvol, "#.00") + "x"
        string setupNote = actionNow ? " | SETUP READY" : ""

        if fireLong
            anyFreshLong := true
            alertMsg += "🟢 LONG FLIP  " + f_pretty(sym) + "  " + scanTfLabel + rvolNote + windowNote + setupNote + "\n"

        if fireShort
            anyFreshShort := true
            alertMsg += "🔴 SHORT FLIP " + f_pretty(sym) + "  " + scanTfLabel + rvolNote + windowNote + setupNote + "\n"

        if readyLongFlip
            anyReadyLong := true

        if readyShortFlip
            anyReadyShort := true

if outRow == firstDataRow
    string emptyTxt = showOnlyFresh ? "No fresh signals" : "No tickers passed filter"
    table.cell(tb, 0, outRow, emptyTxt, text_color=neutralColor, bgcolor=color.black, text_size=textSize)
    for cc = 1 to COLS - 1
        table.cell(tb, cc, outRow, "", text_color=neutralColor, bgcolor=color.black, text_size=textSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
anyScreenerSignal = anyFreshLong or anyFreshShort
anyTradeReady = anyReadyLong or anyReadyShort
anyMasterEvent = anyScreenerSignal or anyTradeReady

alertcondition(anyFreshLong, "Trend Tracker Screener LONG Flip", "Trend Tracker Screener: one or more tickers printed a confirmed LONG flip.")
alertcondition(anyFreshShort, "Trend Tracker Screener SHORT Flip", "Trend Tracker Screener: one or more tickers printed a confirmed SHORT flip.")
alertcondition(anyScreenerSignal, "Trend Tracker Screener Any Flip", "Trend Tracker Screener: confirmed LONG or SHORT flip detected.")

alertcondition(anyReadyLong, "Trend Tracker Screener LONG Trade Ready", "Trend Tracker Screener: one or more tickers printed a LONG trade-ready setup.")
alertcondition(anyReadyShort, "Trend Tracker Screener SHORT Trade Ready", "Trend Tracker Screener: one or more tickers printed a SHORT trade-ready setup.")
alertcondition(anyTradeReady, "Trend Tracker Screener Any Trade Ready", "Trend Tracker Screener: one or more tickers printed a trade-ready setup.")

alertcondition(anyMasterEvent, "Trend Tracker Screener Master Alert", "Trend Tracker Screener: confirmed flip or trade-ready setup detected.")

// Create an alert using "Any alert() function call" to receive the ticker list in one message.
if barstate.isconfirmed and useDynamicAlert and anyMasterEvent
    alert(alertMsg, alert.freq_once_per_bar_close)
````
