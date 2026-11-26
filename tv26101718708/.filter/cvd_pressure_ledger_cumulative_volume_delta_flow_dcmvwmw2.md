# CVD Pressure Ledger - Cumulative Volume Delta Flow

- url: https://www.tradingview.com/script/DCmVwMW2-CVD-Pressure-Ledger-Cumulative-Volume-Delta-Flow/
- type: indicator
- pine_id: PUB;3914953285d441018fe03a10bd58a2ee
- version: 1.0

## Description

CVD Pressure Ledger - Cumulative Volume Delta Flow

CVD Pressure Ledger is a neutral volume-pressure research tool for studying how cumulative volume delta evolves, resets, normalizes, and interacts with price response.

It is designed for traders who want to observe the slope of supply/demand pressure, volume imbalance, price-flow agreement, and effort-versus-response context without turning those observations into automated trade signals.

This script is a context and visualization tool, not a trading system. It does not generate buy/sell signals. It does not provide entries, exits, targets, stops, position sizing, forecasts, win-rate claims, or performance claims.

What It Visualizes

The script displays a reset-aware cumulative volume delta framework with several optional visual layers:

- CVD line
- CVD candles
- Bar delta histogram
- Rescaled pressure score line
- Zero line and reset anchor tint
- Neutral pressure background
- Compact ledger table
- Data-quality notes for limited volume, fallback mode, live bars, and non-standard charts

The goal is to make volume-pressure context readable without overloading the chart.

Delta Engine

The script offers multiple calculation modes:

1. Auto intrabar
   The script first attempts to use an intrabar CVD calculation when a valid lower timeframe is available. If it cannot use intrabar data safely, it falls back to a bar-based approximation.

2. Intrabar CVD
   Uses TradingView's official TradingView/ta library requestVolumeDelta() function to request lower-timeframe volume delta information and build intrabar-aware CVD candles when the selected lower timeframe is valid.

3. Tick-rule approximation
   Estimates positive or negative delta from the candle direction. This is a bar-based approximation and is not real bid/ask order flow.

4. CLV range-weighted approximation
   Estimates delta from where the close sits within the candle range using a Close Location Value style calculation. This is also an approximation and is not real bid/ask order flow.

Auto lower timeframe mode avoids seconds/tick requests by default for stability. Manual lower timeframe mode remains available for users who want to research smaller timeframes when their data plan, feed, and symbol support them.

What Makes It Different

Many CVD tools focus mainly on a cumulative line, CVD candles, or a delta histogram.

CVD Pressure Ledger adds several context layers around the core CVD calculation:

- Reset-aware CVD state
- Pressure score normalized to a -100 to +100 scale
- CVD z-score and percentile context
- Delta share normalization
- Pressure persistence age
- New positive/negative CVD extremes within the reset period
- Price-flow agreement and mismatch context
- Effort-versus-response classification
- A compact ledger fingerprint that summarizes pressure, z-score bucket, response bucket, state age, and mismatch context

This makes the script more of a volume-pressure ledger than a simple cumulative delta plot.

Pressure Score

The pressure score is a normalized composite value from -100 to +100. It combines several configurable components:

- CVD slope
- Delta share
- CVD z-score
- Pressure persistence

Each component has a user-adjustable weight. The score is not a signal. It is a research value intended to summarize the current pressure context.

Pressure states are classified as Positive, Negative, or Neutral using a configurable threshold, neutral band, and optional hysteresis. Hysteresis helps reduce rapid state flipping around the threshold.

Price-Flow Agreement

The price-flow agreement layer compares price slope and CVD slope over a configurable lookback.

It classifies the context into neutral descriptive states such as:

- Price up / flow up
- Price down / flow down
- Price up / flow soft
- Price down / flow firm
- Mixed / flat

The script can also detect when price-flow mismatch starts or expands. These are contextual observations only, not trade signals.

Effort vs Response

The effort-versus-response layer compares volume-delta effort with normalized price movement.

It can classify contexts such as:

- High effort / muted response
- Flow and price aligned
- Price response leads flow
- Low activity
- Mixed response

This layer is intended to help users study whether large delta activity is accompanied by a proportional price response. It does not imply absorption, reversal, continuation, or a future outcome by itself.

Ledger Fingerprint

The ledger fingerprint is a compact text summary shown in the table.

Example format:

P0 Z1 Rm A5 M0

Meaning:

- P+, P-, P0: pressure polarity
- Z0, Z1, Z2: CVD z-score bucket
- Rh, Rm, Rl: response bucket
- A: pressure state age
- M0, Mx, Mn: mismatch context

This helps users quickly compare the current volume-pressure context across symbols, timeframes, and reset settings.

Inputs and Customization

The script includes grouped inputs for:

- Delta engine
- Reset / anchor mode
- Normalization
- Pressure score
- Price-flow agreement
- Effort vs response
- Display mode
- Colors
- Ledger table
- Alerts
- Safety / data warnings

Users can adjust calculation mode, lower timeframe, reset method, session settings, smoothing, lookbacks, thresholds, weights, display mode, table position, table size, colors, and alert availability.

Display Modes

The script includes several display presets:

- Clean: CVD line, zero line, and compact table
- Candle: CVD candles and delta histogram
- Research: CVD, pressure score, histogram, and table context
- Minimal: CVD line with minimal warnings

The visual design is intentionally restrained so the output remains readable on both dark and light chart themes.

Alerts

The script includes factual alert conditions, such as:

- Pressure state changed
- Positive pressure state started
- Negative pressure state started
- Pressure returned to neutral
- New positive CVD extreme
- New negative CVD extreme
- Price-flow mismatch started
- Price-flow mismatch expanded
- High effort / muted response context
- Reset period started
- Data fallback active

Alerts are descriptive context events only. They are not entry, exit, buy, sell, target, or stop signals.

Limitations

Delta calculations are approximations unless the selected data source and TradingView functions provide suitable lower-timeframe information.

Lower-timeframe and intrabar calculations depend on available historical data, symbol, exchange, feed, and account/data-plan limits.

FX, CFD, index, and synthetic symbols may use tick volume, broker-specific volume, or limited volume data. This can affect all volume-based calculations.

If a chart has no usable volume data, CVD may appear as a flat line because there is no volume input to accumulate. In that case, the table will show a volume limitation note. This is expected behavior, not a directional reading.

Non-standard chart types such as Heikin Ashi, Renko, Kagi, Point & Figure, Range, and other synthetic charts can affect price, volume, and derived calculations.

Realtime values can update until the bar closes. When Confirmed bars only is enabled, events and alerts are gated to confirmed bars, but visual values may still update on the live bar.

The default settings are research starting points, not optimized parameters.

What This Script Does Not Do

This script does not:

- Generate buy or sell signals
- Recommend trades
- Forecast price
- Provide entries or exits
- Provide targets or stops
- Provide position sizing
- Claim accuracy, profitability, or statistical reliability
- Reconstruct true bid/ask order flow
- Replace exchange-native order book or footprint data

Suggested Chart Setup

For publication screenshots and general use, a clean chart is recommended:

- Use one liquid symbol with visible volume
- Show the full symbol and timeframe
- Use only this script on the chart unless another script is necessary and explained
- Use Research mode when demonstrating the full context layers
- Use Clean mode when showing the CVD line and ledger table more simply

Japanese Notes / 日本語補足

CVD Pressure Ledger は、累積デルタを単純に表示するだけではなく、出来高デルタの偏り、累積状態、リセット、正規化、価格反応との噛み合いを整理して表示する研究用インジケーターです。

このスクリプトは売買シグナルではありません。エントリー、エグジット、利確、損切り、ポジションサイズ、将来予測、勝率、利益性を示すものではありません。

主な確認項目は次の通りです。

- CVDの累積方向
- Bar deltaの偏り
- Pressure score
- CVD z-score
- Price-flow agreement
- Effort vs response
- Pressure state age
- Ledger fingerprint

Tick-rule と CLV range-weighted は近似計算です。実際のbid/ask約定方向を完全に復元するものではありません。

FX、CFD、指数、合成銘柄では、出来高がティックボリューム、ブローカー依存の出来高、または制限された出来高である場合があります。そのため、出来高ベースの計算は銘柄やデータフィードによって解釈に注意が必要です。

出来高が取得できないチャートでは、累積する出来高入力がないため、CVDが横棒のように表示されることがあります。これはインジケーターの故障ではなく、利用可能な出来高データがないことによる自然な挙動です。

平均足、練行足、カギ足、ポイント＆フィギュア、レンジ足などの非標準足では、価格や出来高の扱いが通常足と異なるため、計算結果の解釈に注意してください。

リアルタイムの未確定足では値が更新される可能性があります。Confirmed bars only を有効にしている場合、イベントとアラートは確定足基準になりますが、表示値はライブバー中に更新されることがあります。

初期設定は研究開始用の値であり、特定の銘柄、時間足、市場に最適化されたものではありません。

## Source Code

````pine
//@version=6
indicator(title = "CVD Pressure Ledger - Cumulative Volume Delta Flow", shorttitle = "CVD Pressure Ledger", overlay = false, max_labels_count = 20, precision = 2)

import TradingView/ta/12 as tvta

// =============================================================================================
// Constants
// =============================================================================================
// Delta engine modes
string MODE_AUTO  = "Auto intrabar"
string MODE_INTRA = "Intrabar CVD"
string MODE_TICK  = "Tick-rule"
string MODE_CLV   = "CLV range-weighted"

// Reset / anchor modes
string RST_NONE   = "None"
string RST_SESS   = "Session"
string RST_DAY    = "Day"
string RST_WEEK   = "Week"
string RST_MONTH  = "Month"
string RST_CUSTOM = "Custom anchor timeframe"
string RST_NBARS  = "N bars"

// Lower timeframe mode
string LTF_AUTO   = "Auto"
string LTF_MANUAL = "Manual"

// Smoothing types
string SM_NONE = "None"
string SM_SMA  = "SMA"
string SM_EMA  = "EMA"
string SM_RMA  = "RMA"

// Display modes
string DSP_CLEAN    = "Clean"
string DSP_CANDLE   = "Candle"
string DSP_RESEARCH = "Research"
string DSP_MINIMAL  = "Minimal"

// Table layout
string TBL_COMPACT  = "Compact"
string TBL_STANDARD = "Standard"
string TBL_DETAILED = "Detailed"

// =============================================================================================
// Inputs
// All inputs use display = display.none so their values do not crowd the pane status line
// (the status line then shows only the indicator name).
// =============================================================================================

// --- 1. Engine ------------------------------------------------------------------------------
string GRP_ENGINE = "1. Engine"
calcMode = input.string(MODE_AUTO, "Delta calculation mode", options = [MODE_AUTO, MODE_INTRA, MODE_TICK, MODE_CLV], group = GRP_ENGINE, display = display.none, tooltip = "Auto intrabar: try official intrabar CVD, fall back to an approximation when unavailable. Intrabar CVD: official TradingView/ta library. Tick-rule / CLV: bar-based approximations (not real order flow).")
ltfMode  = input.string(LTF_AUTO, "Lower timeframe mode", options = [LTF_AUTO, LTF_MANUAL], group = GRP_ENGINE, display = display.none, tooltip = "Auto picks a minute-or-higher lower timeframe from the chart timeframe and never requests seconds/tick data. Manual uses the timeframe below (seconds/tick allowed if your feed/plan supports them). Only used by the intrabar engine.")
ltfManual = input.timeframe("1", "Manual lower timeframe", group = GRP_ENGINE, display = display.none, tooltip = "Lower timeframe for intrabar delta (Manual mode). Must be lower than the chart timeframe. Smaller values use more data and load slower.")

// --- 2. Reset / Anchor ----------------------------------------------------------------------
string GRP_RESET = "2. Reset / Anchor"
resetMode = input.string(RST_SESS, "Reset mode", options = [RST_NONE, RST_SESS, RST_DAY, RST_WEEK, RST_MONTH, RST_CUSTOM, RST_NBARS], group = GRP_RESET, display = display.none, tooltip = "When the cumulative delta returns to zero. None = continuous from first bar.")
customTf  = input.timeframe("1D", "Custom anchor timeframe", group = GRP_RESET, display = display.none, tooltip = "Anchor timeframe used when Reset mode = Custom anchor timeframe.")
nBars     = input.int(500, "N bars per reset", minval = 1, group = GRP_RESET, display = display.none, tooltip = "Bars between resets when Reset mode = N bars.")
sessStr   = input.session("0930-1600", "Session string", group = GRP_RESET, display = display.none, tooltip = "Session window used when Reset mode = Session.")
sessTz    = input.string("America/New_York", "Session timezone", group = GRP_RESET, display = display.none, tooltip = "IANA timezone for the session window, e.g. America/New_York, Europe/London, Asia/Tokyo.")
showReset = input.bool(true, "Show reset anchor tint", group = GRP_RESET, display = display.none, tooltip = "Tint the bar where a reset occurs.")

// --- 3. Normalization -----------------------------------------------------------------------
string GRP_NORM = "3. Normalization"
smoothType = input.string(SM_NONE, "Smoothing type", options = [SM_NONE, SM_SMA, SM_EMA, SM_RMA], group = GRP_NORM, display = display.none, tooltip = "Optional smoothing applied to the CVD close line only. Does not change stored CVD values.")
smoothLen  = input.int(9, "Smoothing length", minval = 1, group = GRP_NORM, display = display.none)
slopeLen   = input.int(14, "Slope length", minval = 1, group = GRP_NORM, display = display.none, tooltip = "Bars used to measure CVD slope (rate of change).")
zLen       = input.int(100, "Z-score lookback", minval = 5, group = GRP_NORM, display = display.none, tooltip = "Lookback for the CVD z-score (distance from its mean in standard deviations). Continuous across resets, so the first ~lookback bars after a reset are still warming up.")
pctLen     = input.int(100, "Percentile lookback", minval = 5, group = GRP_NORM, display = display.none, tooltip = "Lookback for the CVD percentile rank. Continuous across resets, so the first ~lookback bars after a reset are still warming up.")
shareCap   = input.float(1.0, "Delta share cap", minval = 0.1, maxval = 1.0, step = 0.05, group = GRP_NORM, display = display.none, tooltip = "Caps |bar delta / volume| so a single bar cannot dominate the score.")

// --- 4. Pressure Score ----------------------------------------------------------------------
string GRP_PRESS = "4. Pressure Score"
pressThresh = input.float(40.0, "Pressure state threshold", minval = 1, maxval = 100, group = GRP_PRESS, display = display.none, tooltip = "Score magnitude required to enter a positive or negative pressure state.")
neutralBand = input.float(15.0, "Neutral band", minval = 0, maxval = 100, group = GRP_PRESS, display = display.none, tooltip = "Release-threshold floor. A state is classified at |score| >= the pressure threshold and returns to neutral once |score| falls inside +/- max(this, threshold - hysteresis amount), or +/- this band when hysteresis is off. Has no effect while it is below (threshold - hysteresis amount).")
hystOn      = input.bool(true, "Use hysteresis", group = GRP_PRESS, display = display.none, tooltip = "Require the score to fall back by the hysteresis amount before leaving a state. Reduces flip-flopping.")
hystAmt     = input.float(10.0, "Hysteresis amount", minval = 0, maxval = 100, group = GRP_PRESS, display = display.none)
wSlope      = input.float(1.0, "Weight: slope", minval = 0, group = GRP_PRESS, display = display.none, tooltip = "Relative weight of CVD slope in the pressure score.")
wShare      = input.float(1.0, "Weight: delta share", minval = 0, group = GRP_PRESS, display = display.none, tooltip = "Relative weight of bar delta / volume in the pressure score.")
wZ          = input.float(1.0, "Weight: z-score", minval = 0, group = GRP_PRESS, display = display.none, tooltip = "Relative weight of the CVD z-score in the pressure score.")
wPersist    = input.float(0.5, "Weight: persistence", minval = 0, group = GRP_PRESS, display = display.none, tooltip = "Relative weight of how long the prior pressure state has persisted.")
persistRef  = input.int(20, "Persistence reference bars", minval = 1, group = GRP_PRESS, display = display.none, tooltip = "Bars of persistence that count as full conviction for the persistence component.")

// --- 5. Price-Flow Agreement ----------------------------------------------------------------
string GRP_AGREE = "5. Price-Flow Agreement"
agreeLen   = input.int(14, "Agreement slope length", minval = 1, group = GRP_AGREE, display = display.none, tooltip = "Bars used to compare price slope with CVD slope.")
agreeZLen  = input.int(100, "Agreement scaling lookback", minval = 5, group = GRP_AGREE, display = display.none, tooltip = "Lookback used to normalize price and CVD slopes before comparing them.")
mismatchTh = input.float(30.0, "Mismatch threshold", minval = 1, maxval = 100, group = GRP_AGREE, display = display.none, tooltip = "Agreement score below minus this value is treated as a price-flow mismatch (neutral, not a signal).")

// --- 6. Effort vs Response ------------------------------------------------------------------
string GRP_EFFORT = "6. Effort vs Response"
effortLen   = input.int(20, "Effort lookback", minval = 1, group = GRP_EFFORT, display = display.none, tooltip = "Bars used to average volume for effort normalization.")
atrLen      = input.int(14, "ATR length", minval = 1, group = GRP_EFFORT, display = display.none, tooltip = "ATR length used to normalize price movement (response).")
effortLow   = input.float(0.5, "Effort low threshold", minval = 0, step = 0.1, group = GRP_EFFORT, display = display.none, tooltip = "Effort at or below this (bar delta vs average volume) is 'low effort'. Separate from the response thresholds.")
effortHigh  = input.float(1.5, "Effort high threshold", minval = 0, step = 0.1, group = GRP_EFFORT, display = display.none, tooltip = "Effort at or above this (bar delta vs average volume) is 'high effort'.")
respMuted   = input.float(0.5, "Response muted threshold", minval = 0, step = 0.1, group = GRP_EFFORT, display = display.none, tooltip = "Response at or below this (price move in ATRs) is 'muted response'.")
respHigh    = input.float(1.5, "Response high threshold", minval = 0, step = 0.1, group = GRP_EFFORT, display = display.none, tooltip = "Response at or above this (price move in ATRs) is 'high response'.")

// --- 7. Display -----------------------------------------------------------------------------
string GRP_DISPLAY = "7. Display"
dspMode     = input.string(DSP_RESEARCH, "Display mode", options = [DSP_CLEAN, DSP_CANDLE, DSP_RESEARCH, DSP_MINIMAL], group = GRP_DISPLAY, display = display.none, tooltip = "Preset visibility. Individual toggles below can suppress elements within a preset.")
showCandles = input.bool(true, "Show CVD candles", group = GRP_DISPLAY, display = display.none)
showLine    = input.bool(true, "Show CVD line", group = GRP_DISPLAY, display = display.none)
showHist    = input.bool(true, "Show bar delta histogram", group = GRP_DISPLAY, display = display.none)
showPress   = input.bool(true, "Show pressure score", group = GRP_DISPLAY, display = display.none, tooltip = "Plots the pressure score rescaled into the CVD value range for readability. The true -100..100 value is in the ledger table and Data Window.")
showZero    = input.bool(true, "Show zero line", group = GRP_DISPLAY, display = display.none)
showBg      = input.bool(true, "Show background state (neutral only)", group = GRP_DISPLAY, display = display.none, tooltip = "Light background tint while pressure is neutral.")
showWarn    = input.bool(true, "Show data-warning label", group = GRP_DISPLAY, display = display.none)
histScale   = input.float(1.0, "Histogram height scaling", minval = 0.01, group = GRP_DISPLAY, display = display.none, tooltip = "Multiplier applied to the bar delta histogram for visibility. Does not change the underlying value.")
pressScale  = input.float(0.8, "Pressure line range factor", minval = 0.05, maxval = 1.0, step = 0.05, group = GRP_DISPLAY, display = display.none, tooltip = "How much of the recent CVD range the rescaled pressure line is allowed to span.")
confirmedOnly = input.bool(true, "Confirmed bars only (events/alerts)", group = GRP_DISPLAY, display = display.none, tooltip = "When on, state-change events and alerts use closed bars only. Plots can still update intrabar in realtime.")

// --- 8. Colors ------------------------------------------------------------------------------
string GRP_COLOR = "8. Colors"
colUp     = input.color(color.new(#26a69a, 0), "CVD up / positive", group = GRP_COLOR, display = display.none)
colDn     = input.color(color.new(#ef5350, 0), "CVD down / negative", group = GRP_COLOR, display = display.none)
colLine   = input.color(color.new(#42a5f5, 0), "CVD line", group = GRP_COLOR, display = display.none)
colSmooth = input.color(color.new(#ab47bc, 0), "Smoothing line", group = GRP_COLOR, display = display.none)
colPress  = input.color(color.new(#ffa726, 0), "Pressure line", group = GRP_COLOR, display = display.none)
colZero   = input.color(color.new(color.gray, 0), "Zero line", group = GRP_COLOR, display = display.none)
colReset  = input.color(color.new(color.gray, 80), "Reset anchor tint", group = GRP_COLOR, display = display.none)
colBg     = input.color(color.new(color.gray, 92), "Neutral background", group = GRP_COLOR, display = display.none)
histAlpha = input.int(35, "Histogram transparency", minval = 0, maxval = 100, group = GRP_COLOR, display = display.none)
lineWidth = input.int(2, "Line width", minval = 1, maxval = 6, group = GRP_COLOR, display = display.none)

// --- 9. Ledger Table ------------------------------------------------------------------------
string GRP_TABLE = "9. Ledger Table"
showTable  = input.bool(true, "Show context (ledger) table", group = GRP_TABLE, display = display.none)
tblLayout  = input.string(TBL_STANDARD, "Table layout", options = [TBL_COMPACT, TBL_STANDARD, TBL_DETAILED], group = GRP_TABLE, display = display.none)
tblPos     = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right", "Middle left"], group = GRP_TABLE, display = display.none)
tblSize    = input.string("Small", "Table text size", options = ["Tiny", "Small", "Normal", "Large"], group = GRP_TABLE, display = display.none)
tblText    = input.color(color.new(#f8fafc, 0), "Table header/key text color", group = GRP_TABLE, display = display.none)
tblValText = input.color(color.new(#ffffff, 0), "Table value text color", group = GRP_TABLE, display = display.none)
tblBg      = input.color(color.new(#111827, 0), "Table background", group = GRP_TABLE, display = display.none)
tblAltBg   = input.color(color.new(#161e2c, 0), "Table alternate row background", group = GRP_TABLE, display = display.none)
tblHdrBg   = input.color(color.new(#374151, 0), "Table header background", group = GRP_TABLE, display = display.none)
tblBorder  = input.color(color.new(#4b5563, 20), "Table border color", group = GRP_TABLE, display = display.none)
tblBold    = input.bool(true, "Bold ledger text", group = GRP_TABLE, display = display.none, tooltip = "Uses Pine v6 text formatting to improve readability without increasing the table size.")

// --- 10. Alerts -----------------------------------------------------------------------------
string GRP_ALERT = "10. Alerts"
enableAlerts = input.bool(true, "Enable alert conditions", group = GRP_ALERT, display = display.none, tooltip = "Alerts describe factual pressure/flow events. They are not trade signals.")

// --- 11. Safety / Data Warnings -------------------------------------------------------------
string GRP_SAFE = "11. Safety / Data Warnings"
warnNonStd   = input.bool(true, "Warn on non-standard charts", group = GRP_SAFE, display = display.none, tooltip = "Show a caution when the chart is Heikin Ashi, Renko, Kagi, PnF, Range, etc.")
warnVol      = input.bool(true, "Warn on limited volume", group = GRP_SAFE, display = display.none, tooltip = "Show a caution when volume is missing or effectively zero.")
showLiveNote = input.bool(true, "Show live-bar note in ledger table", group = GRP_SAFE, display = display.none, tooltip = "Shows a compact table note while the realtime bar is still updating. It does not create a floating label.")

// =============================================================================================
// Utility functions
// =============================================================================================
f_safeDiv(float a, float b) => na(a) or na(b) or b == 0.0 ? 0.0 : a / b
f_clamp(float x, float lo, float hi) => math.max(lo, math.min(hi, x))
f_slope(float src, int len) => f_safeDiv(src - src[len], len)

// Compute every moving average unconditionally, then select, so each keeps its series state.
f_smooth(float src, string t, int len) =>
    float s = ta.sma(src, len)
    float e = ta.ema(src, len)
    float r = ta.rma(src, len)
    t == SM_SMA ? s : t == SM_EMA ? e : t == SM_RMA ? r : src

f_pos(string s) =>
    switch s
        "Top left"      => position.top_left
        "Bottom right"  => position.bottom_right
        "Bottom left"   => position.bottom_left
        "Middle right"  => position.middle_right
        "Middle left"   => position.middle_left
        => position.top_right

f_txtSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_num(float x, string f) => na(x) ? "n/a" : str.tostring(x, f)

// =============================================================================================
// Delta engine functions
// =============================================================================================
// Per-bar delta from candle direction. Neutral fallback: carry the sign of the last close change.
f_tickDelta() =>
    float v = nz(volume)
    close > open ? v : close < open ? -v : math.sign(nz(close - close[1])) * v

// Per-bar delta from Close Location Value (where close sits inside the bar range).
f_clvDelta() =>
    float rng = high - low
    float v = nz(volume)
    rng > 0 ? ((close - low) - (high - close)) / rng * v : f_tickDelta()

// Choose a lower timeframe (string) and report whether an intrabar request is valid.
f_resolveLtf() =>
    int cs = timeframe.in_seconds()
    string tf = ltfManual
    if ltfMode == LTF_AUTO
        // Auto uses only minute-or-higher lower timeframes; it never requests seconds/tick data.
        // On 1-minute or faster charts no minute LTF is strictly lower, so intrabar is marked
        // invalid and the engine falls back to the Tick-rule approximation. Manual mode may still
        // choose seconds/tick timeframes when the feed/plan supports them.
        tf := cs >= 86400 ? "60" : cs >= 14400 ? "15" : cs >= 3600 ? "5" : "1"
    int ltfSec = timeframe.in_seconds(tf)
    bool valid = not na(cs) and cs > 0 and not na(ltfSec) and ltfSec > 0 and ltfSec < cs
    [tf, valid]

// =============================================================================================
// Reset / anchor detection
// Each candidate reset signal is evaluated unconditionally so its internal series state is
// maintained every bar (avoids lazy-eval / conditional-branch state gaps), then one is selected.
// =============================================================================================
int    sessTime = time(timeframe.period, sessStr, sessTz)
bool   rSession = not na(sessTime) and na(sessTime[1])
bool   rDay     = timeframe.change("1D")
bool   rWeek    = timeframe.change("1W")
bool   rMonth   = timeframe.change("1M")
bool   rCustom  = timeframe.change(customTf)
bool   rNbars   = bar_index % math.max(1, nBars) == 0
bool   newPeriod = resetMode == RST_SESS ? rSession : resetMode == RST_DAY ? rDay : resetMode == RST_WEEK ? rWeek : resetMode == RST_MONTH ? rMonth : resetMode == RST_CUSTOM ? rCustom : resetMode == RST_NBARS ? rNbars : false

// =============================================================================================
// Build the unified CVD candle for this bar
// =============================================================================================
[ltf, ltfValid] = f_resolveLtf()

bool wantIntrabar = calcMode == MODE_INTRA or calcMode == MODE_AUTO
bool canIntrabar  = wantIntrabar and ltfValid

// Official intrabar volume-delta candle (open, high/max, low/min, close/last), anchored to the
// chart bar so 'last' is this bar's net delta. Called only when a valid lower timeframe exists.
float iOpen = na
float iHigh = na
float iLow  = na
float iClose = na
bool  iOk = false
if canIntrabar
    [ov, mx, mn, lv] = tvta.requestVolumeDelta(ltf, timeframe.period)
    iOpen := ov
    iHigh := mx
    iLow  := mn
    iClose := lv
    iOk := not na(lv)

// Resolve the effective per-bar delta and intrabar excursion.
float barDelta = na
float intraMax = na   // max running delta within the bar (>= 0), relative to bar open
float intraMin = na   // min running delta within the bar (<= 0), relative to bar open
bool  usedFallback = false
string engineStatus = ""

if calcMode == MODE_TICK
    barDelta := f_tickDelta()
    engineStatus := "Tick-rule"
else if calcMode == MODE_CLV
    barDelta := f_clvDelta()
    engineStatus := "CLV"
else
    // Intrabar or Auto
    if iOk
        barDelta := iClose
        intraMax := math.max(0.0, nz(iHigh))
        intraMin := math.min(0.0, nz(iLow))
        engineStatus := "Intrabar"
    else
        usedFallback := true
        barDelta := f_tickDelta()
        engineStatus := calcMode == MODE_AUTO ? "Auto->Tick" : "Intrabar n/a->Tick"

// Cumulate with resets (newPeriod computed in the Reset / anchor section above).
var float cvdRun = 0.0
float base = newPeriod ? 0.0 : nz(cvdRun)

float cvdOpen  = base
float cvdClose = base + nz(barDelta)
float cvdHigh  = na(intraMax) ? math.max(cvdOpen, cvdClose) : base + intraMax
float cvdLow   = na(intraMin) ? math.min(cvdOpen, cvdClose) : base + intraMin
// Guard: keep OHLC consistent even if intrabar extremes are noisy.
cvdHigh := math.max(cvdHigh, math.max(cvdOpen, cvdClose))
cvdLow  := math.min(cvdLow, math.min(cvdOpen, cvdClose))
cvdRun := cvdClose

// Optional visual smoothing of the CVD close (does not feed the calculations below).
float cvdSmoothed = f_smooth(cvdClose, smoothType, smoothLen)

// =============================================================================================
// Normalization functions
// =============================================================================================
float cvdChange = cvdClose - nz(cvdClose[1], cvdClose)
float cvdSlope  = f_slope(cvdClose, slopeLen)
float deltaShare = f_clamp(f_safeDiv(barDelta, nz(volume)), -shareCap, shareCap)

// NOTE: z-score, percentile and slope use fixed rolling lookbacks over raw CVD history and are
// CONTINUOUS across resets (they do not re-anchor on newPeriod). Just after a reset, cvdClose jumps
// to ~barDelta while the lookback still holds pre-reset levels, so these readings (and pressureScore)
// warm up over the first lookback bars of a new period. Period-aware highs/lows are handled separately.
float cvdMean = ta.sma(cvdClose, zLen)
float cvdStd  = ta.stdev(cvdClose, zLen)
float cvdZ    = f_safeDiv(cvdClose - cvdMean, cvdStd)
float cvdPct  = ta.percentrank(cvdClose, pctLen)

float slopeStd = ta.stdev(cvdSlope, zLen)
float slopeZ   = f_safeDiv(cvdSlope, slopeStd)

// New extremes over a lookback (period-aware highs/lows).
var float periodHigh = na
var float periodLow  = na
if newPeriod
    periodHigh := cvdClose
    periodLow  := cvdClose
else
    periodHigh := math.max(nz(periodHigh, cvdClose), cvdClose)
    periodLow  := math.min(nz(periodLow, cvdClose), cvdClose)
bool newPosExtreme = cvdClose > nz(periodHigh[1], cvdClose) and not newPeriod
bool newNegExtreme = cvdClose < nz(periodLow[1], cvdClose) and not newPeriod

// =============================================================================================
// Pressure state functions
// =============================================================================================
// Directional components, each mapped to roughly [-1, 1].
float compSlope = f_clamp(slopeZ / 2.0, -1.0, 1.0)
float compShare = f_clamp(deltaShare / shareCap, -1.0, 1.0)
float compZ     = f_clamp(cvdZ / 3.0, -1.0, 1.0)

// Persistence component uses the PRIOR bar's state to avoid circular dependence.
var int stateDir = 0
var int stateAge = 0
float compPersist = math.sign(stateDir) * math.min(f_safeDiv(stateAge, persistRef), 1.0)

float wSum = wSlope + wShare + wZ + wPersist
float pressureScore = f_clamp(100.0 * f_safeDiv(wSlope * compSlope + wShare * compShare + wZ * compZ + wPersist * compPersist, wSum), -100.0, 100.0)

// State machine with neutral band and optional hysteresis.
f_state(float score, int prev, float enterTh, float releaseTh) =>
    int d = prev
    if prev == 1
        d := score < releaseTh ? (score <= -enterTh ? -1 : 0) : 1
    else if prev == -1
        d := score > -releaseTh ? (score >= enterTh ? 1 : 0) : -1
    else
        d := score >= enterTh ? 1 : score <= -enterTh ? -1 : 0
    d

// releaseTh is capped at pressThresh so a state classified at |score| >= pressThresh can always
// return toward neutral without needing a larger-magnitude score (prevents per-bar flip-flop if neutralBand > pressThresh).
float releaseTh = math.min(pressThresh, hystOn ? math.max(neutralBand, pressThresh - hystAmt) : neutralBand)
int prevDir = stateDir
int newDir = f_state(pressureScore, prevDir, pressThresh, releaseTh)
stateAge := newDir == prevDir ? stateAge + 1 : 1
stateDir := newDir
bool stateChanged = newDir != prevDir

// =============================================================================================
// Agreement / effort-response functions
// =============================================================================================
float priceSlope = f_slope(close, agreeLen)
float cvdSlopeA  = f_slope(cvdClose, agreeLen)
float pzN = f_safeDiv(priceSlope, ta.stdev(priceSlope, agreeZLen))
float czN = f_safeDiv(cvdSlopeA, ta.stdev(cvdSlopeA, agreeZLen))
float agreementScore = 100.0 * f_clamp(pzN * czN / 4.0, -1.0, 1.0)

bool priceUp = priceSlope > 0
bool priceDn = priceSlope < 0
bool cvdUp   = cvdSlopeA > 0
bool cvdDn   = cvdSlopeA < 0
string agreeState = priceUp and cvdUp ? "Price up / flow up" : priceDn and cvdDn ? "Price down / flow down" : priceUp and not cvdUp ? "Price up / flow soft" : priceDn and not cvdDn ? "Price down / flow firm" : "Mixed / flat"

bool mismatch = agreementScore < -mismatchTh
var int mismatchAge = 0
mismatchAge := mismatch ? nz(mismatchAge[1]) + 1 : 0
bool mismatchStarted = mismatch and not mismatch[1]
float spread = math.abs(pzN - czN)
bool mismatchExpanding = mismatch and spread > nz(spread[1])

// Effort vs response. Effort uses its own low/high thresholds (independent of the response thresholds).
float avgVol   = ta.sma(volume, effortLen)
float effort   = f_safeDiv(math.abs(barDelta), avgVol)
float atr      = ta.atr(atrLen)
float response = f_safeDiv(math.abs(close - nz(close[1], close)), atr)
// A zero response with real effort means muted response (not a balanced context): cap the ratio high
// (999) rather than returning 0. ATR still warming up -> na (shown as n/a).
float effResp  = na(atr) or atr == 0.0 ? na : (response == 0.0 and effort > 0.0 ? 999.0 : math.min(f_safeDiv(effort, response), 999.0))

string erState = effort >= effortHigh and response <= respMuted ? "High effort / muted response" : effort <= effortLow and response >= respHigh ? "Price response leads flow" : effort >= effortHigh and response >= respHigh ? "Flow and price aligned" : effort <= effortLow and response <= respMuted ? "Low activity" : "Mixed response"
bool highEffortMuted = effort >= effortHigh and response <= respMuted

// =============================================================================================
// Ledger fingerprint
// =============================================================================================
string pTag = stateDir == 1 ? "P+" : stateDir == -1 ? "P-" : "P0"
string zTag = math.abs(cvdZ) < 1.0 ? "Z0" : math.abs(cvdZ) < 2.0 ? "Z1" : "Z2"
string rTag = response <= respMuted ? "Rl" : response >= respHigh ? "Rh" : "Rm"
string mTag = not mismatch ? "M0" : mismatchExpanding ? "Mx" : "Mn"
string fingerprint = str.format("{0} {1} {2} A{3} {4}", pTag, zTag, rTag, stateAge, mTag)

// =============================================================================================
// Data-quality warnings and volume state
// =============================================================================================
float cumVolume = ta.cum(nz(volume))
bool volLimited = cumVolume == 0                          // no usable volume at all -> CVD stays flat
bool volNowMissing = na(volume) or volume == 0.0         // volume absent on the current bar only
string volState = volLimited ? "Unavailable / flat CVD" : volNowMissing ? "Zero or n/a now" : "Available"
bool nonStd = not chart.is_standard
bool liveBar = barstate.isrealtime and not barstate.isconfirmed

string dataWarnText = ""
if warnVol and volLimited
    dataWarnText := "Volume unavailable: CVD may stay flat"
if usedFallback
    dataWarnText := dataWarnText == "" ? "Data fallback active" : dataWarnText + " | Data fallback active"
if warnNonStd and nonStd
    dataWarnText := dataWarnText == "" ? "Synthetic chart caution" : dataWarnText + " | Synthetic chart caution"

string liveText = showLiveNote and liveBar ? "Live update" : ""
string warnText = dataWarnText
if liveText != ""
    warnText := warnText == "" ? liveText : warnText + " | " + liveText

bool hasWarn = warnText != ""
bool hasDataWarn = dataWarnText != ""

// =============================================================================================
// Display resolution (preset AND per-element toggle)
// =============================================================================================
bool presetCandle   = dspMode == DSP_CANDLE
bool presetLine     = dspMode == DSP_CLEAN or dspMode == DSP_RESEARCH or dspMode == DSP_MINIMAL
bool presetHist     = dspMode == DSP_CANDLE or dspMode == DSP_RESEARCH
bool presetPress    = dspMode == DSP_RESEARCH
bool presetTable    = dspMode == DSP_CLEAN or dspMode == DSP_RESEARCH
bool presetBg       = dspMode != DSP_MINIMAL

bool eCandle = presetCandle and showCandles
bool eLine   = presetLine and showLine
bool eHist   = presetHist and showHist
bool ePress  = presetPress and showPress
bool eTable  = presetTable and showTable
bool eBg     = presetBg and showBg

// =============================================================================================
// Visualization (visual plots use display.pane so they draw in the pane but not the status line)
// =============================================================================================
color candleCol = cvdClose >= cvdOpen ? colUp : colDn
plotcandle(eCandle ? cvdOpen : na, eCandle ? cvdHigh : na, eCandle ? cvdLow : na, eCandle ? cvdClose : na, title = "CVD candles", color = candleCol, wickcolor = color.new(color.gray, 30), bordercolor = candleCol, display = display.pane)

plot(eLine ? cvdClose : na, title = "CVD line", color = colLine, linewidth = lineWidth, display = display.pane)
plot(eLine and smoothType != SM_NONE ? cvdSmoothed : na, title = "Smoothing line", color = colSmooth, linewidth = 1, display = display.pane)

color histCol = color.new(barDelta >= 0 ? colUp : colDn, histAlpha)
plot(eHist ? barDelta * histScale : na, title = "Bar delta histogram", color = histCol, style = plot.style_columns, display = display.pane)

// Pressure score rescaled into the recent CVD band (readability only). True value is in the table / Data Window.
float bandHi = ta.highest(cvdHigh, math.max(zLen, 2))
float bandLo = ta.lowest(cvdLow, math.max(zLen, 2))
float bandMid = ta.sma(cvdClose, math.max(zLen, 2))
float halfRange = math.max(bandHi - bandLo, 0.0) / 2.0 * pressScale
plot(ePress ? bandMid + pressureScore / 100.0 * halfRange : na, title = "Pressure score (rescaled)", color = colPress, linewidth = lineWidth, display = display.pane)

// Zero line and reset tint.
// hline supports only display.all / display.none; zero-line visibility is handled via the color alpha.
hline(0.0, "Zero line", color = showZero ? colZero : color.new(colZero, 100), linestyle = hline.style_solid, linewidth = 1, display = display.all)
bgcolor(showReset and newPeriod ? colReset : na, title = "Reset anchor tint")
bgcolor(eBg and stateDir == 0 ? colBg : na, title = "Neutral pressure background")

// Raw numeric series for the Data Window only (do not affect the pane scale or status line).
plot(barDelta, "Bar delta (value)", display = display.data_window)
plot(cvdClose, "CVD close (value)", display = display.data_window)
plot(cvdChange, "CVD change (value)", display = display.data_window)
plot(cvdSlope, "CVD slope (value)", display = display.data_window)
plot(pressureScore, "Pressure score (value)", display = display.data_window)
plot(cvdZ, "CVD z-score (value)", display = display.data_window)
plot(cvdPct, "CVD percentile (value)", display = display.data_window)
plot(agreementScore, "Agreement score (value)", display = display.data_window)
plot(effResp, "Effort/response (value)", display = display.data_window)
plot(stateAge, "Pressure state age (value)", display = display.data_window)

// Single managed warning label. Live-bar updates are shown in the ledger table only; the floating
// label is reserved for data-quality cautions so it does not distract during normal realtime updates.
var label warnLabel = na
if barstate.islast
    label.delete(warnLabel)
    if showWarn and hasDataWarn
        warnLabel := label.new(bar_index + 1, cvdClose, dataWarnText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, 70), textcolor = color.white, size = size.tiny, textalign = text.align_left, tooltip = dataWarnText, text_formatting = text.format_bold)

// =============================================================================================
// Table
// =============================================================================================
f_pushRow(array<string> keys, array<string> vals, string k, string v) =>
    array.push(keys, k)
    array.push(vals, v)

var table tbl = table.new(f_pos(tblPos), 2, 18, bgcolor = tblBg, frame_color = tblBorder, frame_width = 1, border_color = color.new(tblBorder, 20), border_width = 1)

if barstate.islast
    if eTable
        table.set_position(tbl, f_pos(tblPos))
        table.set_bgcolor(tbl, tblBg)
        table.set_frame_color(tbl, tblBorder)
        table.set_border_color(tbl, color.new(tblBorder, 20))

        array<string> keys = array.new_string()
        array<string> vals = array.new_string()

        string stateStr = stateDir == 1 ? "Positive" : stateDir == -1 ? "Negative" : "Neutral"

        // Compact (always shown)
        f_pushRow(keys, vals, "Engine", engineStatus + (usedFallback ? " (fallback)" : ""))
        f_pushRow(keys, vals, "Volume", volState)
        f_pushRow(keys, vals, "Pressure", f_num(pressureScore, "#") + " / 100")
        f_pushRow(keys, vals, "State", stateStr + " (" + str.tostring(stateAge) + ")")
        f_pushRow(keys, vals, "Fingerprint", fingerprint)

        if tblLayout == TBL_STANDARD or tblLayout == TBL_DETAILED
            f_pushRow(keys, vals, "CVD", f_num(cvdClose, "#.##"))
            f_pushRow(keys, vals, "Z-score", f_num(cvdZ, "#.##"))
            f_pushRow(keys, vals, "Delta share", f_num(deltaShare, "#.##"))
            f_pushRow(keys, vals, "Agreement", f_num(agreementScore, "#") + "  " + agreeState)
            f_pushRow(keys, vals, "Effort/Resp", erState)

        if tblLayout == TBL_DETAILED
            f_pushRow(keys, vals, "Bar delta", f_num(barDelta, "#.##"))
            f_pushRow(keys, vals, "CVD slope", f_num(cvdSlope, "#.##"))
            f_pushRow(keys, vals, "Percentile", f_num(cvdPct, "#") + "%")
            f_pushRow(keys, vals, "Effort / Resp", f_num(effort, "#.##") + " / " + f_num(response, "#.##"))
            f_pushRow(keys, vals, "Extreme", newPosExtreme ? "New + extreme" : newNegExtreme ? "New - extreme" : "-")
            f_pushRow(keys, vals, "Reset / LTF", resetMode + " / " + (canIntrabar ? ltf : "n/a"))

        f_pushRow(keys, vals, "Note", hasWarn ? warnText : "OK")

        tableFmt = tblBold ? text.format_bold : text.format_none

        // Header
        table.cell(tbl, 0, 0, "CVD Pressure Ledger", text_color = tblText, text_size = f_txtSize(tblSize), bgcolor = tblHdrBg, text_halign = text.align_left, text_formatting = tableFmt)
        table.cell(tbl, 1, 0, syminfo.ticker + " " + timeframe.period, text_color = tblValText, text_size = f_txtSize(tblSize), bgcolor = tblHdrBg, text_halign = text.align_right, text_formatting = tableFmt)

        int n = array.size(keys)
        for i = 0 to 16
            int row = i + 1
            color rowBg = i % 2 == 0 ? tblBg : tblAltBg
            if i < n
                table.cell(tbl, 0, row, array.get(keys, i), text_color = tblText, text_size = f_txtSize(tblSize), bgcolor = rowBg, text_halign = text.align_left, text_formatting = tableFmt)
                table.cell(tbl, 1, row, array.get(vals, i), text_color = tblValText, text_size = f_txtSize(tblSize), bgcolor = rowBg, text_halign = text.align_right, text_formatting = tableFmt)
            else
                table.cell(tbl, 0, row, "", bgcolor = rowBg)
                table.cell(tbl, 1, row, "", bgcolor = rowBg)
    else
        // Clear stale table cells if the user hides the ledger or selects Minimal mode.
        table.set_bgcolor(tbl, color.new(tblBg, 100))
        table.set_frame_color(tbl, color.new(tblBorder, 100))
        table.set_border_color(tbl, color.new(tblBorder, 100))
        for row = 0 to 17
            table.cell(tbl, 0, row, "", bgcolor = color.new(tblBg, 100))
            table.cell(tbl, 1, row, "", bgcolor = color.new(tblBg, 100))

// =============================================================================================
// Alerts (factual events only - not trade signals)
// =============================================================================================
bool gate = enableAlerts and (not confirmedOnly or barstate.isconfirmed)

alertcondition(gate and stateChanged, "Pressure state changed", "CVD Pressure Ledger: pressure state changed.")
alertcondition(gate and newDir == 1 and prevDir != 1, "Positive pressure state started", "CVD Pressure Ledger: positive pressure state started.")
alertcondition(gate and newDir == -1 and prevDir != -1, "Negative pressure state started", "CVD Pressure Ledger: negative pressure state started.")
alertcondition(gate and newDir == 0 and prevDir != 0, "Pressure returned to neutral", "CVD Pressure Ledger: pressure returned to neutral.")
alertcondition(gate and newPosExtreme, "New positive CVD extreme", "CVD Pressure Ledger: new positive CVD extreme in the current period.")
alertcondition(gate and newNegExtreme, "New negative CVD extreme", "CVD Pressure Ledger: new negative CVD extreme in the current period.")
alertcondition(gate and mismatchStarted, "Price-flow mismatch started", "CVD Pressure Ledger: price-flow mismatch started.")
alertcondition(gate and mismatchExpanding and not mismatchExpanding[1], "Price-flow mismatch expanded", "CVD Pressure Ledger: price-flow mismatch expanded.")
alertcondition(gate and highEffortMuted and not highEffortMuted[1], "High effort / muted response context", "CVD Pressure Ledger: high effort with muted price response.")
alertcondition(gate and newPeriod, "Reset period started", "CVD Pressure Ledger: a new reset period started.")
alertcondition(gate and usedFallback and not usedFallback[1], "Data fallback active", "CVD Pressure Ledger: delta engine fell back to an approximation.")
````
