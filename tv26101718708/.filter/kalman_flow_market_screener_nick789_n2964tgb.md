# Kalman Flow Market Screener [NICK789]

- url: https://www.tradingview.com/script/N2964tGb-Kalman-Flow-Market-Screener-NICK789/
- type: indicator
- pine_id: PUB;1243f79769594f38bea59fa057875419
- version: 6.0

## Description

Kalman Flow Market Screener [NICK789]

Kalman Flow Market Screener is a multi-symbol dashboard built around a Kalman-based adaptive trail engine. It scans up to 20 user-selected tickers and displays BULL/BEAR trend state, fresh flips, flip-risk warnings, trend strength, volume flow, relative volume, session timing, higher-timeframe alignment, and possible trade-ready conditions.

This script is designed as a market scanner and decision-support tool. Its purpose is to reduce chart-hopping and help traders quickly identify which symbols may deserve attention.

It is not intended to be a standalone buy/sell system. Entries, exits, stop losses, take profits, and position sizing should still be handled by the trader’s own trading plan.

Core concept

The screener is built around a Kalman Flow Trail engine that combines:

* Fast and slow Kalman filtering
* Market structure impulse
* Adaptive smoothing
* ATR-based trail boundaries
* BULL/BEAR trail direction
* Flip-risk proximity logic
* Volume-flow strength scoring
* Relative volume filtering
* Session-based trade window scoring
* Optional higher-timeframe alignment

How the Kalman Flow engine works

The script first calculates a fast and slow Kalman estimate of price.

The fast Kalman reacts more quickly to price movement, while the slow Kalman acts as a smoother confirmation reference.

The engine also tracks small market-structure breaks using pivot-based structure logic. When price breaks above a recent structure high, it creates a bullish structure impulse. When price breaks below a recent structure low, it creates a bearish structure impulse.

These structure impulses are smoothed into a structure bias and structure activity reading.

The Kalman trail then adapts using:

* Kalman direction
* Kalman agreement between fast and slow estimates
* Structure bias
* Structure activity
* ATR-based movement
* Adaptive smoothing

The result is a dynamic Kalman flow line that responds more when structure is active and stays smoother when the market is quieter.

ATR boundaries are built around the Kalman flow basis. A BULL state is confirmed when price breaks above the upper flow boundary. A BEAR state is confirmed when price breaks below the lower flow boundary.

Once a BULL or BEAR state is established, the trail follows on the opposite side of price. This creates a directional trail similar in purpose to a trend-following stop, but driven by Kalman smoothing, structure bias, and ATR boundaries.

What makes this screener different

This screener is not only checking whether price is above or below a moving average.

It combines Kalman filtering, structure movement, ATR trail logic, flow strength, relative volume, timing conditions, and optional higher-timeframe agreement into one table.

The goal is to answer a practical scanning question:

Which markets are trending, which markets recently flipped, and which markets are worth checking now?

What the table shows

TICKER
The selected symbol being scanned.

TF
The timeframe being scanned.

DIR
The current confirmed BULL or BEAR Kalman Flow direction.

AGE
How long ago the most recent confirmed flip occurred.

STR
Trend strength score based on ATR distance and supportive flow.

FLOW
Estimated volume-flow delta during the active trend.

MTF
Optional higher-timeframe agreement status.

HEAT
Quick trend state label such as Fresh, Hot, Warm, Active, Cold, or Flip Risk.

ATR
Distance between price and the Kalman trail in ATR units.

RVOL
Current volume compared to its volume baseline.

WINDOW
Session and volume-based timing score.

ACTION
Simplified status such as Wait, Watch, BULL Setup, BEAR Setup, Low Vol, Bad Time, Extended, or RSI Hot.

How the filters work together

Trend direction
The Kalman Flow Trail defines whether each symbol is currently in a BULL or BEAR state.

Fresh flip detection
The screener highlights symbols that recently changed from BEAR to BULL or from BULL to BEAR.

Flip-risk warning
The script can warn when price is pressing close to the opposite flow boundary before a confirmed flip. This is a caution state, not a confirmed signal.

Trend age
The script tracks how old the current trend is. This helps separate fresh movement from older, more mature trends.

Trend delta flow
The script estimates buy/sell pressure using candle direction and volume. Up candles contribute to buy volume, down candles contribute to sell volume, and neutral candles are split. This creates a simple volume-flow reading for the current trend.

Trend strength
The strength score combines ATR distance from the Kalman trail with whether volume flow supports the active direction. Stronger movement with supportive flow receives a higher score.

Relative volume
RVOL compares current volume to its moving average baseline. This helps identify whether the current move is happening with above-normal or quiet activity.

Trade window score
The trade window score combines London/New York session timing with relative volume. More active periods and stronger RVOL receive higher scores, while quieter periods receive lower scores.

Higher-timeframe filter
The optional higher-timeframe filter allows traders to focus only on symbols where the selected higher timeframe agrees with the current BULL/BEAR direction.

Action status
The action column combines fresh flip status, RVOL, ATR distance, RSI condition, trade window score, and warning state into one simple readout.

Display modes

All 20 Trend States

* Shows selected tickers and their current Kalman Flow state.
* Useful for general market monitoring.
* Best when traders want a full watchlist overview.

Fresh Signals Only

* Shows only recent flips and optional flip-risk warnings.
* Useful when traders only want to see symbols that may need attention now.
* Helps reduce table noise.

Timeframe behaviour

For best accuracy, use a chart timeframe equal to or lower than the selected screener timeframe.

Examples:

* A 15-minute screener works best on a 15-minute chart or lower.
* A 1-hour screener works best on a 1-hour chart or lower.
* A daily screener can be viewed from intraday charts.

If the chart timeframe is higher than the selected screener timeframe, the script displays a timeframe warning and uses the chart timeframe as a fallback.

This fallback is included to avoid misleading lower-timeframe data when Pine cannot fully process every lower-timeframe bar from a higher-timeframe chart.

Alerts

The script includes TradingView alert conditions for:

* BULL flip
* BEAR flip
* Any confirmed flip
* BULL trade-ready setup
* BEAR trade-ready setup
* Any trade-ready setup
* BULL flip-risk warning
* BEAR flip-risk warning
* Any flip-risk warning
* Master alert

For dynamic ticker messages, create an alert using TradingView’s “Any alert() function call” option. This allows the alert message to include the symbols that triggered during the confirmed bar.

Suggested workflow

1. Choose the screener timeframe.
2. Select up to 20 symbols.
3. Choose All 20 Trend States or Fresh Signals Only.
4. Check the ACTION column for BULL Setup, BEAR Setup, Watch, or Wait.
5. Review RVOL and WINDOW to see whether the market is active.
6. Review FLOW and STR to check whether the move has supportive pressure.
7. Use MTF alignment if higher-timeframe filtering is enabled.
8. Open the individual chart before making any trade decision.
9. Apply your own entry, stop loss, take profit, and risk management rules.

Important notes

* BULL and BEAR flips are confirmed Kalman Flow direction changes.
* Flip-risk warnings are early caution states, not confirmed entries.
* The action column is a decision-support label, not financial advice.
* RVOL and window scoring measure activity and timing conditions, not future direction.
* Higher-timeframe filtering can reduce signals and may filter out early moves.
* This script is designed for scanning and filtering, not guaranteed trade execution.

Disclaimer

This indicator is for educational and informational purposes only. It is not financial advice. Traders should test the script on their own markets and timeframes, use proper risk management, and make independent trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator("Kalman Flow Killzone Screener [NICK789]", "KF KZ Scan", overlay=false, max_labels_count=500, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KALMAN ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpCore = "Kalman Flow Engine"

src = input.source(ohlc4, "Source", group=grpCore, display=display.none)

kalmanMainLen = input.int(50, "Fast Kalman Length", minval=2, maxval=500, group=grpCore, tooltip="Lower value = faster Kalman trail response.", display=display.none)
kalmanSlowLen = input.int(100, "Slow Kalman Length", minval=2, maxval=800, group=grpCore, tooltip="Higher value = smoother Kalman confirmation.", display=display.none)

flowBoundaryMult = input.float(1.5, "Trail Boundary Multiplier", minval=0.1, maxval=10.0, step=0.1, group=grpCore, display=display.none)
useSlopeConfirm  = input.bool(true, "Use Kalman Slope Confirmation", group=grpCore, display=display.none)

int lenFast = 6
int lenSlow = 40
float pushFac = 0.35
float structureWeight = 0.60

float kalmanResponse = 0.50
float kalmanNoise = 0.50
float disagreeFactor = 0.35

float kalmanMainQ = kalmanResponse / kalmanMainLen
float kalmanMainR = kalmanNoise
float kalmanSlowQ = kalmanResponse / kalmanSlowLen
float kalmanSlowR = kalmanNoise

int piv1 = 5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCREENER SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpScreen = "Screener"

screenTF = input.timeframe("15", "Screener Timeframe", options=["1", "3", "5", "15", "30", "60", "240", "D", "W"], group=grpScreen, display=display.none)

chartTfSec = timeframe.in_seconds(timeframe.period)
screenTfSec = timeframe.in_seconds(screenTF)
screenTfLowerThanChart = not na(chartTfSec) and not na(screenTfSec) and screenTfSec < chartTfSec

scanTF = screenTfLowerThanChart ? timeframe.period : screenTF
scanTfLabel = screenTfLowerThanChart ? timeframe.period + " fallback" : screenTF
scanTfSec = screenTfLowerThanChart ? chartTfSec : screenTfSec

displayMode = input.string("All 20 Trend States", "Display Mode", options=["All 20 Trend States", "Fresh Signals Only"], group=grpScreen, display=display.none)
showOnlyFresh = displayMode == "Fresh Signals Only"

freshBars = input.int(3, "Fresh Signal Window Bars", minval=1, maxval=50, group=grpScreen, tooltip="Used for table display. Alerts only fire on a valid new scan bar.", display=display.none)
freshFlashBars = input.int(4, "Fresh Flip Yellow Flash Bars", minval=1, maxval=10, group=grpScreen, display=display.none)
showCount = input.int(20, "Tickers To Scan", minval=1, maxval=20, group=grpScreen, display=display.none)

staleGuardBars = input.float(2.0, "Closed-Market Guard Bars", minval=1.0, maxval=10.0, step=0.5, group=grpScreen, tooltip="Stops closed-market symbols from repeating old alerts on active 24/7 charts.", display=display.none)

showFlipWarning = input.bool(true, "Show Flip Risk Warning", group=grpScreen, display=display.none)
showWarningsInFreshMode = input.bool(true, "Show Flip Risk In Fresh Mode", group=grpScreen, display=display.none)
flipWarnATR = input.float(0.25, "Flip Risk Distance ATR", minval=0.05, maxval=2.0, step=0.05, group=grpScreen, display=display.none)

useMtfFilter = input.bool(false, "Use Higher-TF Direction Filter", group=grpScreen, display=display.none)
mtfFilterTf = input.timeframe("60", "Higher-TF Filter", options=["5", "15", "30", "60", "240", "D"], group=grpScreen, display=display.none)
showFlow = input.bool(true, "Show Trend Delta Flow", group=grpScreen, display=display.none)

mtfTfSec = timeframe.in_seconds(mtfFilterTf)
mtfTfLowerThanScan = useMtfFilter and not na(mtfTfSec) and not na(scanTfSec) and mtfTfSec < scanTfSec
safeMtfTF = mtfTfLowerThanScan ? scanTF : mtfFilterTf
safeMtfLabel = not useMtfFilter ? "off" : mtfTfLowerThanScan ? scanTfLabel + " fallback" : mtfFilterTf

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KILLZONE / RVOL / ACTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpAction = "Killzone / RVOL / Action"

showKillzone = input.bool(true, "Show Killzone Column", group=grpAction, display=display.none)
useKillzoneGate = input.bool(false, "Gate Alerts To Active Killzone", group=grpAction, display=display.none)
useActionGate = input.bool(false, "Gate Alerts To BULL/BEAR SETUP Only", group=grpAction, display=display.none)
waitForScanCandleClose = input.bool(true, "Wait For Screener Candle Close", group=grpAction, tooltip="Prevents BULL/BEAR flip and ACTION alerts from firing while the screener timeframe candle is still forming. Pending flips show WAIT BULL/WAIT BEAR until confirmed.", display=display.none)
showSignalTrack = input.bool(true, "Show Signal Direction Tracker", group=grpAction, tooltip="Adds a paper tracker from the latest confirmed trend-flip close. TRACK keeps running after killzone end and only resets on the next confirmed flip.", display=display.none)
trackFlatThresholdPct = input.float(0.02, "TRACK Flat Threshold %", minval=0.0, maxval=1.0, step=0.01, group=grpAction, tooltip="TRACK shows FLAT when movement from the confirmed signal close is smaller than this percent.", display=display.none)

kzTimezone = input.string("America/New_York", "Killzone Timezone", group=grpAction, display=display.none)
cryptoKillzoneMode = input.string("24/7", "Crypto Killzone Mode", options=["24/7", "Time Windows"], group=grpAction, tooltip="24/7 treats crypto as always active and prevents killzone-end blocking. Time Windows lets crypto use Asia/London/NY killzone labels like other markets.", display=display.none)

trackAsiaKz = input.bool(true, "Track Asian Killzone", group=grpAction, display=display.none)
asiaSession = input.session("2000-0000", "Asian Killzone Time", group=grpAction, display=display.none)

trackLondonKz = input.bool(true, "Track London Killzone", group=grpAction, display=display.none)
londonSession = input.session("0200-0500", "London Killzone Time", group=grpAction, display=display.none)

trackNyKz = input.bool(true, "Track New York Killzone", group=grpAction, display=display.none)
nySession = input.session("0700-1000", "New York Killzone Time", group=grpAction, display=display.none)

blockKillzoneEndSignals = input.bool(true, "Block Last Killzone Bar Alerts", group=grpAction, tooltip="Stops alerts from firing on the final bar of a killzone/session.", display=display.none)
extraKillzoneEndBufferMin = input.int(0, "Extra End-Killzone Buffer Minutes", minval=0, maxval=120, group=grpAction, tooltip="Extra minutes before killzone end to suppress alerts. The script always blocks at least the final screener bar.", display=display.none)

blockMarketCloseSignals = input.bool(true, "Block Non-24/7 NY Close/Rollover", group=grpAction, tooltip="Blocks non-crypto alerts near NY rollover/market close so Friday or session-close signals do not trigger late.", display=display.none)
marketCloseHourNY = input.int(17, "NY Close Hour", minval=0, maxval=23, group=grpAction, display=display.none)
marketCloseMinuteNY = input.int(0, "NY Close Minute", minval=0, maxval=59, group=grpAction, display=display.none)
marketCloseBufferMin = input.int(30, "Close Guard Before Minutes", minval=0, maxval=180, group=grpAction, display=display.none)
marketCloseAfterMin = input.int(15, "Close Guard After Minutes", minval=0, maxval=180, group=grpAction, display=display.none)

rvolLen = input.int(20, "RVOL Baseline Length", minval=5, maxval=300, group=grpAction, display=display.none)
rvolHot = input.float(1.50, "RVOL Hot Threshold", minval=0.10, maxval=10.0, step=0.10, group=grpAction, display=display.none)

actionMaxAtrDist = input.float(1.25, "Max ATR Dist For Setup", minval=0.10, maxval=5.0, step=0.05, group=grpAction, display=display.none)

rsiLen = input.int(14, "RSI Filter Length", minval=2, maxval=100, group=grpAction, display=display.none)
rsiBullMax = input.float(72.0, "Avoid BULL Above RSI", minval=50.0, maxval=100.0, step=1.0, group=grpAction, display=display.none)
rsiBearMin = input.float(28.0, "Avoid BEAR Below RSI", minval=0.0, maxval=50.0, step=1.0, group=grpAction, display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEAT / STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpHeat = "Heat / Strength"

strengthHot = input.float(70.0, "HOT Strength Threshold", minval=1.0, maxval=100.0, step=1.0, group=grpHeat, display=display.none)
strengthWarm = input.float(40.0, "WARM Strength Threshold", minval=1.0, maxval=100.0, step=1.0, group=grpHeat, display=display.none)
heatYoungBarsMult = input.float(2.0, "Young Trend Multiplier", minval=1.0, maxval=10.0, step=0.5, group=grpHeat, display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TICKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpTickers = "Tickers"

s01 = input.symbol("OANDA:EURUSD", "Ticker 01", group=grpTickers, display=display.none)
s02 = input.symbol("OANDA:USDJPY", "Ticker 02", group=grpTickers, display=display.none)
s03 = input.symbol("OANDA:GBPUSD", "Ticker 03", group=grpTickers, display=display.none)
s04 = input.symbol("OANDA:AUDUSD", "Ticker 04", group=grpTickers, display=display.none)
s05 = input.symbol("OANDA:USDCAD", "Ticker 05", group=grpTickers, display=display.none)

s06 = input.symbol("BINANCE:BTCUSDT", "Ticker 06", group=grpTickers, display=display.none)
s07 = input.symbol("BINANCE:ETHUSDT", "Ticker 07", group=grpTickers, display=display.none)
s08 = input.symbol("BINANCE:SOLUSDT", "Ticker 08", group=grpTickers, display=display.none)
s09 = input.symbol("BINANCE:XRPUSDT", "Ticker 09", group=grpTickers, display=display.none)
s10 = input.symbol("BINANCE:BNBUSDT", "Ticker 10", group=grpTickers, display=display.none)

s11 = input.symbol("CME_MINI:ES1!", "Ticker 11", group=grpTickers, display=display.none)
s12 = input.symbol("CME_MINI:NQ1!", "Ticker 12", group=grpTickers, display=display.none)
s13 = input.symbol("NYMEX:CL1!", "Ticker 13", group=grpTickers, display=display.none)
s14 = input.symbol("COMEX:GC1!", "Ticker 14", group=grpTickers, display=display.none)
s15 = input.symbol("CBOT:ZN1!", "Ticker 15", group=grpTickers, display=display.none)

s16 = input.symbol("OANDA:SPX500USD", "Ticker 16", group=grpTickers, display=display.none)
s17 = input.symbol("OANDA:NAS100USD", "Ticker 17", group=grpTickers, display=display.none)
s18 = input.symbol("OANDA:US30USD", "Ticker 18", group=grpTickers, display=display.none)
s19 = input.symbol("OANDA:DE30EUR", "Ticker 19", group=grpTickers, display=display.none)
s20 = input.symbol("OANDA:UK100GBP", "Ticker 20", group=grpTickers, display=display.none)

string[] SYMS = array.from(s01, s02, s03, s04, s05, s06, s07, s08, s09, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpDisp = "Display"

tablePosOpt = input.string("Top Left", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center"], group=grpDisp, display=display.none)
tableSizeOpt = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDisp, display=display.none)

bullColor       = input.color(color.rgb(8, 153, 129), "BULL Color", group=grpDisp, display=display.none)
bearColor       = input.color(color.rgb(242, 54, 69), "BEAR Color", group=grpDisp, display=display.none)
neutralColor    = input.color(color.rgb(150, 150, 150), "Neutral Text", group=grpDisp, display=display.none)
freshFlashColor = input.color(color.yellow, "Fresh Flip Flash Color", group=grpDisp, display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpAlert = "Alerts"

useDynamicAlert  = input.bool(true, "Use Dynamic Alert Message", group=grpAlert, display=display.none)
alertBull        = input.bool(true, "Alert BULL Flip", group=grpAlert, display=display.none)
alertBear        = input.bool(true, "Alert BEAR Flip", group=grpAlert, display=display.none)
alertFlipWarning = input.bool(true, "Alert Flip Risk Warning", group=grpAlert, display=display.none)

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

f_session_start_min(string sess) =>
    float hh = str.tonumber(str.substring(sess, 0, 2))
    float mm = str.tonumber(str.substring(sess, 2, 4))
    na(hh) or na(mm) ? 0 : int(hh) * 60 + int(mm)

f_session_end_min(string sess) =>
    float hh = str.tonumber(str.substring(sess, 5, 7))
    float mm = str.tonumber(str.substring(sess, 7, 9))
    na(hh) or na(mm) ? 0 : int(hh) * 60 + int(mm)

f_bar_min_in_tz(int barTime, string tz) =>
    hour(barTime, tz) * 60 + minute(barTime, tz)

f_in_session_by_time(int barTime, string sess, string tz) =>
    int curMin = f_bar_min_in_tz(barTime, tz)
    int startMin = f_session_start_min(sess)
    int endMin = f_session_end_min(sess)
    bool inside = startMin < endMin ? curMin >= startMin and curMin < endMin : curMin >= startMin or curMin < endMin
    inside

f_session_mins_to_end(int barTime, string sess, string tz) =>
    int curMin = f_bar_min_in_tz(barTime, tz)
    int startMin = f_session_start_min(sess)
    int endMin = f_session_end_min(sess)

    bool inside = startMin < endMin ? curMin >= startMin and curMin < endMin : curMin >= startMin or curMin < endMin

    float mins = na
    if inside
        mins := startMin < endMin ? float(endMin - curMin) : curMin >= startMin ? float(1440 - curMin + endMin) : float(endMin - curMin)

    mins

f_killzone_id_by_time(int barTime) =>
    bool asiaKz = trackAsiaKz and f_in_session_by_time(barTime, asiaSession, kzTimezone)
    bool londonKz = trackLondonKz and f_in_session_by_time(barTime, londonSession, kzTimezone)
    bool nyKz = trackNyKz and f_in_session_by_time(barTime, nySession, kzTimezone)

    nyKz ? 3 : londonKz ? 2 : asiaKz ? 1 : 0

f_killzone_end_mins(int kz, int barTime) =>
    float mins = na
    if kz == 1
        mins := f_session_mins_to_end(barTime, asiaSession, kzTimezone)
    else if kz == 2
        mins := f_session_mins_to_end(barTime, londonSession, kzTimezone)
    else if kz == 3
        mins := f_session_mins_to_end(barTime, nySession, kzTimezone)
    mins

f_is_scan_stale(int scanBarTime, bool isAlwaysOpen) =>
    bool stale = false
    if not isAlwaysOpen and not na(scanBarTime) and not na(scanTfSec)
        stale := float(time - scanBarTime) > float(scanTfSec) * 1000.0 * staleGuardBars
    stale

f_market_close_guard(int barTime, bool isAlwaysOpen) =>
    bool blocked = false
    if blockMarketCloseSignals and not isAlwaysOpen and not na(barTime) and not na(scanTfSec)
        int nyMin = f_bar_min_in_tz(barTime, "America/New_York")
        int closeMin = marketCloseHourNY * 60 + marketCloseMinuteNY
        float tfMins = float(scanTfSec) / 60.0
        float beforeMins = math.max(float(marketCloseBufferMin), tfMins)
        int startBlock = int(math.max(0.0, float(closeMin) - beforeMins))
        int endBlock = int(math.min(1439.0, float(closeMin) + float(marketCloseAfterMin)))
        blocked := nyMin >= startBlock and nyMin <= endBlock
    blocked

f_ageTxt(float bars, float mins) =>
    na(bars) or na(mins) ? "—" : mins < 60 ? str.tostring(mins, "#") + "m" : mins < 1440 ? str.tostring(mins / 60.0, "#.0") + "h" : str.tostring(mins / 1440.0, "#.0") + "d"

f_atrDistTxt(float dist) =>
    na(dist) ? "—" : str.tostring(dist, "#.00") + "x"

f_rvolTxt(float rvol) =>
    na(rvol) ? "—" : str.tostring(rvol, "#.00") + "x"

clamp01(float x) =>
    math.max(0.0, math.min(1.0, x))

structCalc(simple int pLen, float swHi, float swLo, int swHiBar, int swLoBar) =>
    float ph = ta.pivothigh(high, pLen, pLen)
    float pl = ta.pivotlow(low, pLen, pLen)

    float hi = swHi
    float lo = swLo
    int hiBar = swHiBar
    int loBar = swLoBar

    if not na(ph)
        hi := ph
        hiBar := bar_index - pLen

    if not na(pl)
        lo := pl
        loBar := bar_index - pLen

    bool bullBreak = not na(hi) and close > hi and close[1] <= hi
    bool bearBreak = not na(lo) and close < lo and close[1] >= lo

    [ph, pl, hi, lo, hiBar, loBar, bullBreak, bearBreak]

f_kalman_pair(float _src, float _mainQ, float _mainR, float _slowQ, float _slowR) =>
    var float kMainEst = na
    var float kMainErr = 1.0

    if na(kMainEst)
        kMainEst := _src

    float mainK = (kMainErr + _mainQ) / (kMainErr + _mainQ + _mainR)
    kMainEst := kMainEst + mainK * (_src - kMainEst)
    kMainErr := (1.0 - mainK) * (kMainErr + _mainQ)

    var float kSlowEst = na
    var float kSlowErr = 1.0

    if na(kSlowEst)
        kSlowEst := _src

    float slowK = (kSlowErr + _slowQ) / (kSlowErr + _slowQ + _slowR)
    kSlowEst := kSlowEst + slowK * (_src - kSlowEst)
    kSlowErr := (1.0 - slowK) * (kSlowErr + _slowQ)

    [kMainEst, kSlowEst]

f_killzone_txt(int kz) =>
    kz == 4 ? "24/7" : kz == 1 ? "ASIA" : kz == 2 ? "LONDON" : kz == 3 ? "NY" : "OFF"

f_killzone_active(int kz) =>
    not showKillzone or kz != 0

f_killzone_values(int kz, bool scanIsStale, bool sessionEndingSoon) =>
    string txt = scanIsStale ? "CLOSED" : not showKillzone ? "off" : sessionEndingSoon ? "KZ END" : f_killzone_txt(kz)
    color txtCol = scanIsStale ? neutralColor : not showKillzone ? neutralColor : sessionEndingSoon ? color.orange : kz == 0 ? neutralColor : color.white
    color bg = scanIsStale ? color.black : not showKillzone or kz == 0 ? color.black : sessionEndingSoon ? color.new(color.orange, 75) : kz == 4 ? color.new(color.rgb(120, 120, 120), 70) : kz == 1 ? color.new(color.rgb(8, 153, 129), 65) : kz == 2 ? color.new(color.rgb(91, 156, 246), 55) : color.new(color.rgb(242, 54, 69), 55)
    [txt, txtCol, bg]

f_killzone_alert(int kz) =>
    not showKillzone ? "" : kz == 4 ? " | 24/7 CRYPTO" : kz == 0 ? " | OFF KILLZONE" : " | " + f_killzone_txt(kz) + " KILLZONE"

f_is_trade_now(int side, bool freshActive, float atrDist, float rvol, float rsiVal, int killzoneId, int warnSide, bool alertBlocked) =>
    bool hotVol = rvol >= rvolHot
    bool killzoneOk = f_killzone_active(killzoneId)
    bool atrOk = atrDist <= actionMaxAtrDist
    bool rsiOk = side == 1 ? rsiVal <= rsiBullMax : rsiVal >= rsiBearMin
    not alertBlocked and warnSide == 0 and freshActive and hotVol and killzoneOk and atrOk and rsiOk

f_action_values(int side, bool freshActive, float atrDist, float rvol, float rsiVal, int killzoneId, int warnSide, int pendingSide, bool scanIsStale, bool sessionEndingSoon, bool marketCloseBlock) =>
    bool alertBlocked = scanIsStale or sessionEndingSoon or marketCloseBlock
    bool isBull = side == 1
    bool hotVol = rvol >= rvolHot
    bool killzoneOk = f_killzone_active(killzoneId)
    bool atrOk = atrDist <= actionMaxAtrDist
    bool rsiOk = isBull ? rsiVal <= rsiBullMax : rsiVal >= rsiBearMin
    bool tradeNow = f_is_trade_now(side, freshActive, atrDist, rvol, rsiVal, killzoneId, warnSide, alertBlocked)

    string txt = scanIsStale ? "CLOSED" : marketCloseBlock ? "MKT CLOSE" : sessionEndingSoon ? "KZ END" : pendingSide == 1 ? "WAIT BULL" : pendingSide == -1 ? "WAIT BEAR" : warnSide != 0 ? "WATCH" : tradeNow ? (isBull ? "BULL SETUP" : "BEAR SETUP") : not freshActive ? "WAIT" : not killzoneOk ? "OFF KZ" : not hotVol ? "LOW VOL" : not atrOk ? "EXTENDED" : not rsiOk ? "RSI HOT" : "WATCH"
    color bg = scanIsStale or marketCloseBlock or sessionEndingSoon ? color.black : pendingSide != 0 ? color.new(color.orange, 50) : tradeNow ? color.new(isBull ? bullColor : bearColor, 0) : warnSide != 0 ? color.new(color.orange, 55) : txt == "OFF KZ" ? color.new(color.red, 80) : txt == "LOW VOL" ? color.new(color.gray, 70) : txt == "EXTENDED" ? color.new(color.orange, 75) : color.black
    color txtCol = scanIsStale or marketCloseBlock or sessionEndingSoon ? neutralColor : pendingSide != 0 ? color.orange : tradeNow ? color.white : warnSide != 0 ? color.orange : txt == "WAIT" ? neutralColor : color.white

    [txt, txtCol, bg]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KALMAN FLOW FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_kalman_core() =>
    var float _hi1 = na
    var float _lo1 = na
    var int _hiBar1 = na
    var int _loBar1 = na

    [_, __, _newHi1, _newLo1, _newHiBar1, _newLoBar1, _bullBreak1, _bearBreak1] = structCalc(piv1, _hi1, _lo1, _hiBar1, _loBar1)

    _hi1 := _newHi1
    _lo1 := _newLo1
    _hiBar1 := _newHiBar1
    _loBar1 := _newLoBar1

    float _structureImpulse = _bullBreak1 ? 1.0 : _bearBreak1 ? -1.0 : 0.0
    float _structureActivity = ta.rma(math.abs(_structureImpulse), 20)
    float _structureBias = ta.rma(_structureImpulse, 20)

    [_kMain, _kSlow] = f_kalman_pair(src, kalmanMainQ, kalmanMainR, kalmanSlowQ, kalmanSlowR)

    float _weightSum = math.max(structureWeight, 0.0001)
    float _adapt = math.min(1.0, (_structureActivity * structureWeight) / _weightSum)

    float _aFast = 2.0 / (lenFast + 1.0)
    float _aSlow = 2.0 / (lenSlow + 1.0)
    float _alpha = _aSlow + (_aFast - _aSlow) * _adapt

    float _mid = na(_hi1) or na(_lo1) ? na : (_hi1 + _lo1) / 2.0
    float _anchW = 0.20 * _structureActivity

    float _m3 = 1.0
    float _a3 = clamp01(_alpha * _m3)
    float _p3 = pushFac * _m3

    var float _b3 = na
    float _atr = ta.atr(14)

    float _kalmanAgree =
         _structureBias > 0 and _kMain > _kSlow ? 1.0 :
         _structureBias < 0 and _kMain < _kSlow ? 1.0 :
         disagreeFactor

    _b3 := na(_b3[1]) ? _kMain : _b3[1] + _a3 * (_kMain - _b3[1])
    _b3 := _b3 + _p3 * _structureBias * _kalmanAgree * _atr
    _b3 := not na(_mid) ? _b3 + _anchW * (_mid - _b3) : _b3

    _b3

f_kalman_raw() =>
    float _avgMain = f_kalman_core()
    float _atr = ta.atr(14)

    float _flowUpper = _avgMain + _atr * flowBoundaryMult
    float _flowLower = _avgMain - _atr * flowBoundaryMult

    bool _baselineSlopeBull = _avgMain > _avgMain[1]
    bool _baselineSlopeBear = _avgMain < _avgMain[1]

    bool _bullShiftRaw = close > _flowUpper and (not useSlopeConfirm or _baselineSlopeBull)
    bool _bearShiftRaw = close < _flowLower and (not useSlopeConfirm or _baselineSlopeBear)

    var int _macroTrend = 0

    if _macroTrend == 0
        _macroTrend := close >= _avgMain ? 1 : -1
    else if _bullShiftRaw
        _macroTrend := 1
    else if _bearShiftRaw
        _macroTrend := -1
    else
        _macroTrend := nz(_macroTrend[1], _macroTrend)

    float _macroFlowLine = _macroTrend == 1 ? _flowLower : _flowUpper

    [_avgMain, _macroFlowLine, _macroTrend, _flowUpper, _flowLower, _atr]

f_kalman_confirmed_dir() =>
    [_avgMain, _macroFlowLine, _macroTrend, _flowUpper, _flowLower, _atr] = f_kalman_raw()
    waitForScanCandleClose ? nz(_macroTrend[1], _macroTrend) : _macroTrend

f_kalman_pack() =>
    [_avgMainLive, _macroFlowLineLive, _liveDir, _flowUpperLive, _flowLowerLive, _atrLive] = f_kalman_raw()

    bool _useClosed = waitForScanCandleClose

    int _outDir = _useClosed ? nz(_liveDir[1], _liveDir) : _liveDir
    int _prevOutDir = nz(_outDir[1], _outDir)

    int _barTimeOut = _useClosed ? time[1] : time
    float _closeOut = _useClosed ? close[1] : close
    float _openOut = _useClosed ? open[1] : open
    float _volumeOut = _useClosed ? volume[1] : volume

    float _flowUpperOut = _useClosed ? _flowUpperLive[1] : _flowUpperLive
    float _flowLowerOut = _useClosed ? _flowLowerLive[1] : _flowLowerLive
    float _atrValue = _useClosed ? _atrLive[1] : _atrLive
    float _macroFlowLine = _outDir == 1 ? _flowLowerOut : _flowUpperOut

    bool _barReady = not _useClosed or not na(_barTimeOut)

    bool _confirmedChanged = _barReady and _outDir != _prevOutDir
    bool _bullFlip = _barReady and _outDir == 1 and _prevOutDir == -1
    bool _bearFlip = _barReady and _outDir == -1 and _prevOutDir == 1

    bool _liveBullPending = _useClosed and _liveDir == 1 and nz(_liveDir[1], _liveDir) == -1
    bool _liveBearPending = _useClosed and _liveDir == -1 and nz(_liveDir[1], _liveDir) == 1
    int _pendingSide = _liveBullPending ? 1 : _liveBearPending ? -1 : 0

    bool _baselineReady = not na(_closeOut) and not na(_flowUpperOut) and not na(_flowLowerOut) and not na(_atrValue)

    bool _liveBullPress = _baselineReady and _outDir == -1 and (_closeOut > _flowUpperOut or _closeOut >= _flowUpperOut - _atrValue * flipWarnATR)
    bool _liveBearPress = _baselineReady and _outDir == 1 and (_closeOut < _flowLowerOut or _closeOut <= _flowLowerOut + _atrValue * flipWarnATR)

    bool _warnBullActive = showFlipWarning and not _bullFlip and _liveBullPress
    bool _warnBearActive = showFlipWarning and not _bearFlip and _liveBearPress

    int _warnSide = _warnBullActive ? 1 : _warnBearActive ? -1 : 0
    bool _warnStart = _warnSide != 0 and _warnSide != nz(_warnSide[1], 0)

    var int _trendStartBar = na

    if na(_trendStartBar) or _confirmedChanged
        _trendStartBar := bar_index

    float _trendAgeBars = na(_trendStartBar) ? na : float(bar_index - _trendStartBar)

    float _buyVol = _closeOut > _openOut ? _volumeOut : _closeOut == _openOut ? _volumeOut * 0.5 : 0.0
    float _sellVol = _closeOut < _openOut ? _volumeOut : _closeOut == _openOut ? _volumeOut * 0.5 : 0.0

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

    float _distATR = _atrValue > 0 and not na(_macroFlowLine) and not na(_closeOut) ? math.abs(_closeOut - _macroFlowLine) / _atrValue : 0.0
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
    float _tfMin = timeframe.in_seconds(scanTF) / 60.0
    float _sigAgeMin = na(_sigAgeBars) ? na : _sigAgeBars * _tfMin

    float _volBaseLive = ta.sma(volume, rvolLen)
    float _volBase = _useClosed ? _volBaseLive[1] : _volBaseLive
    float _rvol = not na(_volumeOut) and not na(_volBase) and _volBase > 0 ? _volumeOut / _volBase : 0.0

    float _rsiLive = ta.rsi(close, rsiLen)
    float _rsiVal = _useClosed ? _rsiLive[1] : _rsiLive

    var float _paperEntry = na
    var int _paperSide = 0
    var int _paperEntryBar = na

    if _bullFlip or _bearFlip
        _paperEntry := _closeOut
        _paperSide := _bullFlip ? 1 : -1
        _paperEntryBar := bar_index

    float _markPrice = close
    float _paperPnlPct = showSignalTrack and _paperSide != 0 and not na(_paperEntry) and _paperEntry != 0.0 and not na(_markPrice) ? (_paperSide == 1 ? (_markPrice - _paperEntry) / _paperEntry * 100.0 : (_paperEntry - _markPrice) / _paperEntry * 100.0) : na
    float _paperAgeBars = na(_paperEntryBar) ? na : float(bar_index - _paperEntryBar)

    [_barTimeOut, _closeOut, _outDir, _bullFlip, _bearFlip, float(_lastSigSide), _sigAgeBars, _sigAgeMin, _trendAgeBars, _deltaPct, _flowOk, _trendStrength, _distATR, _rvol, _rsiVal, float(_warnSide), _warnStart, float(_pendingSide), float(_paperSide), _paperEntry, _paperPnlPct, _paperAgeBars]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int COLS = 13
int ROWS = 22

textSize = f_size(tableSizeOpt)
var table tb = table.new(f_tblPos(tablePosOpt), COLS, ROWS, bgcolor=color.black, border_width=1)
var int[] LAST_SCAN_TIME = array.new_int(20, 0)

f_clear_all() =>
    for r = 0 to ROWS - 1
        for cc = 0 to COLS - 1
            table.cell(tb, cc, r, "", text_color=neutralColor, bgcolor=color.black, text_size=textSize)

f_header() =>
    color hdrBg = color.rgb(25, 38, 68)

    for cc = 0 to COLS - 1
        table.cell(tb, cc, 0, "", text_color=neutralColor, bgcolor=color.black, text_size=textSize)

    table.cell(tb, 0, 1, "TICKER", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 1, 1, "TF", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 2, 1, "DIR", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 3, 1, "AGE", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 4, 1, "STR", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 5, 1, "FLOW", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 6, 1, "MTF", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 7, 1, "HEAT", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 8, 1, "ATR", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 9, 1, "RVOL", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 10, 1, "KILLZONE", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 11, 1, "ACTION", text_color=color.white, bgcolor=hdrBg, text_size=textSize)
    table.cell(tb, 12, 1, "TRACK", text_color=color.white, bgcolor=hdrBg, text_size=textSize)

f_heat_values(int dir, float sigAgeBars, float trendAgeBars, float trendStrength, bool flowOk, bool freshActive, int warnSide, int pendingSide, bool scanIsStale, bool sessionEndingSoon, bool marketCloseBlock) =>
    // HEAT is intentionally independent from killzone end / market close guards.
    // Those guards affect ACTION + alerts, not trend heat.
    bool isFreshNow = freshActive and not na(sigAgeBars) and sigAgeBars < freshFlashBars
    bool isYoungTrend = not na(trendAgeBars) and trendAgeBars <= freshBars * heatYoungBarsMult
    bool strongTrend = trendStrength >= strengthHot
    bool mediumTrend = trendStrength >= strengthWarm

    color sideCol = pendingSide == 1 ? bullColor : pendingSide == -1 ? bearColor : dir == 1 ? bullColor : bearColor
    string heatTxt = scanIsStale ? "CLOSED" : pendingSide == 1 ? "⏳ BULL" : pendingSide == -1 ? "⏳ BEAR" : warnSide == 1 ? "⚠ BULL RISK" : warnSide == -1 ? "⚠ BEAR RISK" : isFreshNow ? "🔥 FRESH" : isYoungTrend and strongTrend and flowOk ? "🔥 HOT" : mediumTrend and flowOk ? "🟡 WARM" : flowOk ? "🟢 ACTIVE" : "❄ COLD"
    color heatTxtCol = scanIsStale ? neutralColor : pendingSide != 0 ? color.orange : warnSide != 0 ? color.orange : isFreshNow ? color.black : isYoungTrend and strongTrend and flowOk ? color.white : mediumTrend and flowOk ? color.black : flowOk ? sideCol : neutralColor
    color heatBg = scanIsStale ? color.black : pendingSide != 0 ? color.new(color.orange, 70) : warnSide != 0 ? color.new(color.orange, 65) : isFreshNow ? freshFlashColor : isYoungTrend and strongTrend and flowOk ? color.new(sideCol, 10) : mediumTrend and flowOk ? color.new(color.yellow, 20) : color.black

    [heatTxt, heatTxtCol, heatBg]

f_strength_values(float trendStrength, color sideCol) =>
    string strengthTxt = na(trendStrength) ? "—" : str.tostring(trendStrength, "#") + "%"
    color strengthTxtCol = na(trendStrength) ? neutralColor : trendStrength >= strengthHot ? color.white : trendStrength >= strengthWarm ? color.yellow : neutralColor
    color strengthBg = not na(trendStrength) and trendStrength >= strengthHot ? color.new(sideCol, 10) : color.black

    [strengthTxt, strengthTxtCol, strengthBg]

f_atr_dist_color(float dist) =>
    na(dist) ? neutralColor : dist <= flipWarnATR ? color.orange : dist >= 2.0 ? color.aqua : neutralColor

f_rvol_color(float rvol) =>
    na(rvol) ? neutralColor : rvol >= rvolHot ? color.lime : rvol >= 1.0 ? color.yellow : neutralColor

f_track_values(int paperSide, float paperPnlPct, int pendingSide, bool scanIsStale, bool sessionEndingSoon, bool marketCloseBlock) =>
    // TRACK is now based only on the latest confirmed trend flip.
    // Killzone end and NY close blocks can stop new alerts, but they do not stop the tracker.
    bool blocked = scanIsStale
    bool noTrack = not showSignalTrack or paperSide == 0 or na(paperPnlPct)
    bool flatMove = not na(paperPnlPct) and math.abs(paperPnlPct) < trackFlatThresholdPct
    string pnlTxt = na(paperPnlPct) ? "—" : str.tostring(paperPnlPct, "+#.00;-#.00") + "%"
    string txt = blocked ? "CLOSED" : pendingSide != 0 ? "WAIT" : noTrack ? "—" : flatMove ? "FLAT " + pnlTxt : paperPnlPct > 0 ? "FOLLOW " + pnlTxt : "AGAINST " + pnlTxt
    color txtCol = blocked or noTrack ? neutralColor : pendingSide != 0 ? color.orange : flatMove ? neutralColor : paperPnlPct > 0 ? color.lime : color.red
    color bg = blocked or noTrack ? color.black : pendingSide != 0 ? color.new(color.orange, 80) : flatMove ? color.black : paperPnlPct > 0 ? color.new(color.green, 80) : color.new(color.red, 80)
    [txt, txtCol, bg]

f_put_row(int row, string sym, int dir, int lastSide, float sigAgeBars, float sigAgeMin, float trendAgeBars, float trendStrength, float atrDist, float rvol, float rsiVal, int killzoneId, float deltaPct, bool flowOk, int mtfDir, bool freshActive, int warnSide, int pendingSide, int paperSide, float paperPnlPct, bool scanIsStale, bool sessionEndingSoon, bool marketCloseBlock) =>
    int activeSide = pendingSide != 0 ? pendingSide : freshActive ? lastSide : dir
    bool rowIsBull = activeSide == 1
    color sideCol = rowIsBull ? bullColor : bearColor

    string dirTxt = pendingSide != 0 ? (rowIsBull ? "▲ BULL ?" : "▼ BEAR ?") : freshActive ? (rowIsBull ? "▲ BULL NOW" : "▼ BEAR NOW") : (rowIsBull ? "▲ BULL" : "▼ BEAR")
    string flowTxt = showFlow ? str.tostring(deltaPct, "+#.0;-#.0") + "%" : "off"
    color flowCol = flowOk ? sideCol : neutralColor

    string mtfTxt = not useMtfFilter ? "off" : mtfDir == 1 ? "HTF BULL" : "HTF BEAR"
    color mtfCol = not useMtfFilter ? neutralColor : mtfDir == activeSide ? sideCol : color.orange

    bool flashTicker = freshActive and not na(sigAgeBars) and sigAgeBars < freshFlashBars
    color tickerBg = flashTicker ? freshFlashColor : color.black
    color tickerTxt = flashTicker ? color.black : color.white

    [strengthTxt, strengthTxtCol, strengthBg] = f_strength_values(trendStrength, sideCol)
    [heatTxt, heatTxtCol, heatBg] = f_heat_values(dir, sigAgeBars, trendAgeBars, trendStrength, flowOk, freshActive, warnSide, pendingSide, scanIsStale, sessionEndingSoon, marketCloseBlock)
    [kzTxt, kzTxtCol, kzBg] = f_killzone_values(killzoneId, scanIsStale, sessionEndingSoon)
    [actionTxt, actionTxtCol, actionBg] = f_action_values(activeSide, freshActive, atrDist, rvol, rsiVal, killzoneId, warnSide, pendingSide, scanIsStale, sessionEndingSoon, marketCloseBlock)
    [trackTxt, trackTxtCol, trackBg] = f_track_values(paperSide, paperPnlPct, pendingSide, scanIsStale, sessionEndingSoon, marketCloseBlock)

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
    table.cell(tb, 10, row, kzTxt, text_color=kzTxtCol, bgcolor=kzBg, text_size=textSize)
    table.cell(tb, 11, row, actionTxt, text_color=actionTxtCol, bgcolor=actionBg, text_size=textSize)
    table.cell(tb, 12, row, trackTxt, text_color=trackTxtCol, bgcolor=trackBg, text_size=textSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE BUILD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
table.set_position(tb, f_tblPos(tablePosOpt))

f_clear_all()
f_header()

int outRow = 2

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

bool anyFreshBull = false
bool anyFreshBear = false
bool anyWarnBull = false
bool anyWarnBear = false

bool anyReadyBull = false
bool anyReadyBear = false

string alertMsg = "Kalman Flow Killzone Screener\n"

for idx = 0 to 19
    if idx < showCount
        string sym = array.get(SYMS, idx)
        bool isAlwaysOpen = f_is_247_symbol(sym)

        [barTime, priceClose, dirFloat, bullFlip, bearFlip, lastSideFloat, sigAgeBars, sigAgeMin, trendAgeBars, deltaPct, flowOk, trendStrength, atrDist, rvol, rsiVal, warnSideFloat, warnStart, pendingSideFloat, paperSideFloat, paperEntry, paperPnlPct, paperAgeBars] = request.security(sym, scanTF, f_kalman_pack(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

        bool invalid = na(priceClose)

        int dir = invalid ? 0 : int(dirFloat)
        int lastSide = invalid ? 0 : int(lastSideFloat)
        int warnSide = invalid ? 0 : int(warnSideFloat)
        int pendingSide = invalid ? 0 : int(pendingSideFloat)
        int paperSide = invalid ? 0 : int(paperSideFloat)

        int rawKillzoneId = invalid or na(barTime) ? 0 : f_killzone_id_by_time(barTime)
        int killzoneId = isAlwaysOpen and cryptoKillzoneMode == "24/7" ? 4 : rawKillzoneId

        int prevScanTime = array.get(LAST_SCAN_TIME, idx)
        bool newScanBar = not invalid and not na(barTime) and (prevScanTime == 0 or barTime != prevScanTime)

        if not invalid and not na(barTime)
            array.set(LAST_SCAN_TIME, idx, barTime)

        bool scanIsStale = not invalid and f_is_scan_stale(barTime, isAlwaysOpen)

        float tfMins = na(scanTfSec) ? 0.0 : float(scanTfSec) / 60.0
        float kzEndMins = invalid or na(barTime) ? na : f_killzone_end_mins(killzoneId, barTime)
        float kzBlockBuffer = math.max(float(extraKillzoneEndBufferMin), tfMins)
        bool sessionEndingSoon = not invalid and blockKillzoneEndSignals and killzoneId != 0 and not na(kzEndMins) and kzEndMins <= kzBlockBuffer

        bool marketCloseBlock = not invalid and f_market_close_guard(barTime, isAlwaysOpen)
        bool alertBlocked = scanIsStale or sessionEndingSoon or marketCloseBlock

        int mtfDir = useMtfFilter ? request.security(sym, safeMtfTF, f_kalman_confirmed_dir(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true) : dir

        bool fresh = not invalid and not scanIsStale and lastSide != 0 and not na(sigAgeBars) and sigAgeBars <= freshBars
        bool warningActive = not invalid and not scanIsStale and showFlipWarning and warnSide != 0
        bool pendingConfirm = not invalid and not scanIsStale and waitForScanCandleClose and pendingSide != 0

        bool mtfPassFresh = not useMtfFilter or lastSide == mtfDir
        bool mtfPassTrend = not useMtfFilter or dir == mtfDir
        bool mtfPassWarning = not useMtfFilter or warnSide == mtfDir
        bool mtfPassPending = not useMtfFilter or pendingSide == mtfDir

        bool actionNow = f_is_trade_now(lastSide, fresh, atrDist, rvol, rsiVal, killzoneId, warnSide, alertBlocked)
        bool killzonePassAlert = not useKillzoneGate or not showKillzone or killzoneId != 0
        bool actionPassAlert = not useActionGate or actionNow

        bool displayRow = not invalid and (showOnlyFresh ? (fresh and mtfPassFresh) or (pendingConfirm and mtfPassPending) or (showWarningsInFreshMode and warningActive and mtfPassWarning) : mtfPassTrend or (pendingConfirm and mtfPassPending) or (warningActive and mtfPassWarning))

        if displayRow and outRow < ROWS
            f_put_row(outRow, sym, dir, lastSide, sigAgeBars, sigAgeMin, trendAgeBars, trendStrength, atrDist, rvol, rsiVal, killzoneId, deltaPct, flowOk, mtfDir, fresh, warnSide, pendingSide, paperSide, paperPnlPct, scanIsStale, sessionEndingSoon, marketCloseBlock)
            outRow += 1

        bool freshBullFlip = newScanBar and not alertBlocked and bullFlip and mtfPassFresh and killzonePassAlert and alertBull
        bool freshBearFlip = newScanBar and not alertBlocked and bearFlip and mtfPassFresh and killzonePassAlert and alertBear

        bool readyBullFlip = freshBullFlip and actionNow
        bool readyBearFlip = freshBearFlip and actionNow

        bool fireBull = freshBullFlip and actionPassAlert
        bool fireBear = freshBearFlip and actionPassAlert

        bool fireWarnBull = newScanBar and not alertBlocked and alertFlipWarning and warnStart and mtfPassWarning and killzonePassAlert and warnSide == 1
        bool fireWarnBear = newScanBar and not alertBlocked and alertFlipWarning and warnStart and mtfPassWarning and killzonePassAlert and warnSide == -1

        string killzoneNote = f_killzone_alert(killzoneId)
        string rvolNote = " | RVOL " + str.tostring(rvol, "#.00") + "x"
        string setupNote = actionNow ? " | SETUP READY" : ""

        if fireBull
            anyFreshBull := true
            alertMsg += "🟢 BULL FLIP  " + f_pretty(sym) + "  " + scanTfLabel + rvolNote + killzoneNote + setupNote + "\n"

        if fireBear
            anyFreshBear := true
            alertMsg += "🔴 BEAR FLIP  " + f_pretty(sym) + "  " + scanTfLabel + rvolNote + killzoneNote + setupNote + "\n"

        if readyBullFlip
            anyReadyBull := true

        if readyBearFlip
            anyReadyBear := true

        if fireWarnBull
            anyWarnBull := true
            alertMsg += "🟠 BULL FLIP RISK  " + f_pretty(sym) + "  " + scanTfLabel + rvolNote + killzoneNote + "\n"

        if fireWarnBear
            anyWarnBear := true
            alertMsg += "🟠 BEAR FLIP RISK  " + f_pretty(sym) + "  " + scanTfLabel + rvolNote + killzoneNote + "\n"

if outRow == firstDataRow
    string emptyTxt = showOnlyFresh ? "No fresh signals, pending flips, or flip-risk setups" : "No tickers passed filter"
    table.cell(tb, 0, outRow, emptyTxt, text_color=neutralColor, bgcolor=color.black, text_size=textSize)
    for cc = 1 to COLS - 1
        table.cell(tb, cc, outRow, "", text_color=neutralColor, bgcolor=color.black, text_size=textSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
anyScreenerSignal = anyFreshBull or anyFreshBear
anyScreenerWarning = anyWarnBull or anyWarnBear
anyTradeReady = anyReadyBull or anyReadyBear
anyMasterEvent = anyScreenerSignal or anyScreenerWarning or anyTradeReady

alertcondition(anyFreshBull, "Kalman Flow Killzone Screener BULL Flip", "Kalman Flow Killzone Screener: one or more tickers printed a confirmed BULL flip.")
alertcondition(anyFreshBear, "Kalman Flow Killzone Screener BEAR Flip", "Kalman Flow Killzone Screener: one or more tickers printed a confirmed BEAR flip.")
alertcondition(anyScreenerSignal, "Kalman Flow Killzone Screener Any Flip", "Kalman Flow Killzone Screener: confirmed BULL or BEAR flip detected.")

alertcondition(anyReadyBull, "Kalman Flow Killzone Screener BULL Trade Ready", "Kalman Flow Killzone Screener: one or more tickers printed a BULL trade-ready setup.")
alertcondition(anyReadyBear, "Kalman Flow Killzone Screener BEAR Trade Ready", "Kalman Flow Killzone Screener: one or more tickers printed a BEAR trade-ready setup.")
alertcondition(anyTradeReady, "Kalman Flow Killzone Screener Any Trade Ready", "Kalman Flow Killzone Screener: one or more tickers printed a trade-ready setup.")

alertcondition(anyWarnBull, "Kalman Flow Killzone Screener BULL Flip Risk", "Kalman Flow Killzone Screener: one or more tickers are close to a BULL flip.")
alertcondition(anyWarnBear, "Kalman Flow Killzone Screener BEAR Flip Risk", "Kalman Flow Killzone Screener: one or more tickers are close to a BEAR flip.")
alertcondition(anyScreenerWarning, "Kalman Flow Killzone Screener Any Flip Risk", "Kalman Flow Killzone Screener: one or more tickers are close to a trend flip.")

alertcondition(anyMasterEvent, "Kalman Flow Killzone Screener Master Alert", "Kalman Flow Killzone Screener: confirmed flip, trade-ready setup, or flip-risk warning detected.")

// Create an alert using "Any alert() function call" to receive the ticker list in one message.
if barstate.isconfirmed and useDynamicAlert and anyMasterEvent
    alert(alertMsg, alert.freq_once_per_bar_close)
````
