<!-- tradingview-pine-id: PUB;123fd58d7be44b19a8b89d1cf0893073 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# JFX Structure Fib

Source: https://www.tradingview.com/script/fd2fndX4-JFX-Structure-Fib/

## Description

JFX Structure Fib

ENGLISH

JFX Structure Fib is a multi-timeframe market-structure and automatic Fibonacci retracement framework designed for discretionary traders. It does not generate BUY/SELL signals or manage trades. Its purpose is to organize higher-timeframe directional context, confirmed chart-timeframe structure breaks, and retracement levels into one clean workflow.

HOW IT WORKS

1. Adaptive bias timeframe
By default, the script automatically assigns a higher bias timeframe according to the active chart timeframe. Examples include M5 -> H1 and M15 -> H4. A Custom mode is also available for users who prefer a different higher-timeframe relationship.

2. Confirmed higher-timeframe bias
The bias engine reads confirmed higher-timeframe structure. An optional Structure + EMA mode can require both structural direction and EMA alignment. The higher-timeframe values are based on completed higher-timeframe bars to reduce discrepancies between historical and realtime behavior.

3. Valid chart-timeframe BOS
The script displays only BOS events that meet its structural rules. A valid BOS requires a confirmed close through a confirmed swing that has not already been counted as broken, alignment with the active higher-timeframe bias, and a valid opposite structural swing after the broken swing to serve as the impulse origin.

4. BOS-origin impulse tracking
After a valid BOS, the script tracks the continuing impulse rather than fixing the Fibonacci endpoint immediately. The impulse extreme remains dynamic until price produces the configured confirmed retracement. This reduces arbitrary Fibonacci anchoring while an impulse is still extending.

5. Automatic Fibonacci lock
When the retracement threshold is confirmed, the impulse is locked and the script plots four configurable Fibonacci retracement levels. Defaults are 0.618, 0.705, 0.790, and 0.886. The chart displays ratio values only, without prices.

6. Fibonacci history
Completed or superseded Fibonacci structures can be retained as bounded historical references. Users can choose how many recent Fibonacci structures remain visible. Historical levels are visually muted so the active structure remains easy to identify.

7. Compact dashboard
The dashboard summarizes the chart-to-bias timeframe mapping, confirmed higher-timeframe bias, current structural direction, Fibonacci state, and retained Fibonacci history.

HOW TO USE IT

- Apply the indicator to the timeframe on which you want to analyze structure.
- Leave Bias timeframe mode on Auto for the default multi-timeframe mapping, or select Custom if your framework uses a different higher timeframe.
- A bullish or bearish BOS is displayed only when the script's validity conditions are satisfied.
- After the post-BOS impulse retraces by the configured lock threshold, the Fibonacci structure becomes fixed and its retracement levels are displayed.
- Use the Fibonacci levels as location/context within your own trading plan. The script intentionally does not define entries, stop losses, take profits, or expected performance.

KEY SETTINGS

- Bias timeframe mode: Auto or Custom.
- Bias method: Structure or Structure + EMA.
- Bias and chart-structure pivot sensitivity.
- Use newest valid BOS: allows a newer valid BOS to supersede the current structure.
- Structure invalidation: close or wick beyond the impulse origin.
- Fibonacci lock retracement.
- Four customizable Fibonacci ratios.
- Optional minimum impulse size measured in ATR.
- Fibonacci history count.
- Optional bias/chart swing reference levels.
- BOS, Fibonacci, dashboard, and alert visibility controls.

ORIGINALITY AND PROTECTED-SOURCE RATIONALE

BOS, market structure, and Fibonacci retracement are established concepts and are not claimed as original inventions. The original contribution of this script is the specific workflow and implementation that connects adaptive higher-timeframe bias, valid BOS filtering, post-break structural-origin selection, dynamic impulse tracking, confirmed retracement locking, bounded Fibonacci lifecycle/history, and a chart-focused visual state model. The source is protected to preserve this implementation while allowing the community to use the indicator freely.

LIMITATIONS

- Confirmed pivots require right-side bars before a swing is known. This means structure detection intentionally has confirmation delay.
- The higher-timeframe bias uses completed higher-timeframe information, so it will react more slowly than an indicator using an unfinished higher-timeframe candle.
- The automatic timeframe mapping is a practical default, not a universal rule. Different instruments or trading plans may require Custom mode.
- BOS validity depends on the selected pivot sensitivities. Very low settings can identify more minor structure; higher settings can identify fewer but broader swings.
- Fibonacci levels describe retracement location only. They do not establish that price will reverse from a level.
- The script does not calculate trade entries, stop losses, take profits, win rate, profit factor, or profitability.
- A newer valid BOS can replace the active structure when that option is enabled.
- Market behavior varies by instrument, timeframe, volatility regime, session, data feed, and execution environment.

Use the indicator as an analytical framework and validate its behavior on the instruments and timeframes relevant to your own process before relying on it for live decisions.

BAHASA INDONESIA

JFX Structure Fib adalah framework market structure multi-timeframe dan automatic Fibonacci retracement untuk discretionary trader. Indikator ini tidak memberikan sinyal BUY/SELL dan tidak mengatur posisi trading. Tujuannya adalah menyusun higher-timeframe bias, valid chart-timeframe BOS, dan retracement Fibonacci dalam satu workflow yang bersih dan mudah dibaca.

CARA KERJA

1. Adaptive bias timeframe
Secara default indikator memilih bias timeframe yang lebih tinggi berdasarkan timeframe chart aktif. Contohnya M5 -> H1 dan M15 -> H4. Mode Custom tetap tersedia jika pengguna ingin menggunakan hubungan timeframe yang berbeda.

2. Confirmed higher-timeframe bias
Bias membaca structure dari higher timeframe yang sudah confirmed. Mode Structure + EMA dapat digunakan untuk meminta alignment tambahan dari EMA. Data higher timeframe berasal dari candle yang sudah selesai agar perilaku historical dan realtime lebih konsisten.

3. Valid chart-timeframe BOS
Indikator hanya menampilkan BOS yang memenuhi aturan structure. BOS harus terjadi melalui confirmed close pada confirmed swing yang belum pernah dihitung sebagai broken, searah dengan higher-timeframe bias, serta memiliki opposite structural swing yang valid setelah swing yang di-break untuk menjadi origin impulse.

4. BOS-origin impulse tracking
Setelah valid BOS, indikator tetap mengikuti extreme impulse selama impulse masih berkembang. Endpoint Fibonacci belum langsung dikunci. Extreme baru dikunci setelah terjadi confirmed retracement sesuai threshold yang dipilih.

5. Automatic Fibonacci lock
Setelah retracement threshold terkonfirmasi, Fibonacci dikunci dan empat retracement level ditampilkan. Default: 0.618, 0.705, 0.790, dan 0.886. Chart hanya menampilkan angka ratio Fibonacci tanpa harga.

6. Fibonacci history
Fibonacci yang telah selesai atau digantikan dapat disimpan sebagai historical reference. Jumlah history dapat diatur oleh pengguna dan tampilannya dibuat lebih redup daripada Fibonacci aktif.

7. Compact dashboard
Dashboard menampilkan mapping chart timeframe ke bias timeframe, confirmed HTF bias, current structure, status Fibonacci, dan jumlah history yang sedang disimpan.

PENGGUNAAN

- Pasang indikator pada timeframe yang ingin digunakan untuk membaca structure.
- Gunakan Auto untuk mapping timeframe default, atau Custom jika menggunakan framework multi-timeframe sendiri.
- BOS bullish/bearish hanya muncul jika seluruh aturan validasinya terpenuhi.
- Setelah impulse pasca-BOS mengalami retracement sesuai threshold, Fibonacci dikunci dan level retracement ditampilkan.
- Gunakan Fibonacci sebagai area location/context dalam trading plan Anda sendiri. Indikator sengaja tidak menentukan entry, stop loss, take profit, atau ekspektasi hasil trading.

ORIGINALITAS DAN ALASAN SOURCE DILINDUNGI

BOS, market structure, dan Fibonacci retracement merupakan konsep yang sudah umum dan tidak diklaim sebagai penemuan baru. Nilai original script ini terletak pada workflow dan implementasinya: adaptive HTF bias, valid BOS filtering, pemilihan structural origin setelah break, dynamic impulse tracking, confirmed retracement lock, bounded Fibonacci history, serta visual state yang dibangun menjadi satu framework. Source dilindungi untuk menjaga implementasi tersebut sementara indikator tetap dapat digunakan gratis oleh komunitas.

KETERBATASAN

- Confirmed pivot membutuhkan sejumlah candle di sisi kanan sehingga swing diketahui dengan delay yang disengaja.
- Bias HTF menggunakan candle HTF yang sudah selesai sehingga lebih lambat dibandingkan metode yang membaca unfinished HTF candle.
- Auto timeframe mapping adalah default praktis dan bukan aturan universal.
- Sensitivitas BOS tergantung pada pivot settings yang digunakan.
- Fibonacci hanya menunjukkan lokasi retracement dan tidak menjamin reversal.
- Indikator tidak menghitung entry, SL, TP, win rate, Profit Factor, atau profitabilitas.
- Valid BOS yang lebih baru dapat menggantikan active structure jika opsi tersebut diaktifkan.
- Hasil visual dan perilaku structure dapat berbeda menurut instrument, timeframe, volatility regime, session, dan data feed.

Gunakan indikator sebagai analytical framework dan lakukan validasi pada instrument serta timeframe yang sesuai dengan proses trading Anda sebelum menggunakannya dalam keputusan live.

---

## Source Code

````pine
//@version=6
// © 2026 JustIqbal. All rights reserved.
// JFX Structure Fib v1.0.0 Release Candidate
// Multi-timeframe structure and automatic Fibonacci retracement framework.
// Core workflow: adaptive higher-timeframe bias -> valid chart-timeframe BOS ->
// BOS-origin impulse tracking -> confirmed retracement lock -> active + historical Fibonacci levels.
// This indicator is designed as a discretionary decision-support tool. It does not generate trade entries or manage positions.
// Validate the behavior on your symbols/timeframes with replay and forward observation before live use.

indicator("JFX Structure Fib", shorttitle="JFX Structure Fib", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================================
// CONSTANTS
// ============================================================================
int STATE_IDLE     = 0
int STATE_TRACKING = 1
int STATE_FIB      = 2

int DIR_NONE  = 0
int DIR_LONG  = 1
int DIR_SHORT = -1

// ============================================================================
// INPUTS
// ============================================================================
string GROUP_BIAS      = "01 - Bias"
string GROUP_STRUCTURE = "02 - Chart Structure & BOS"
string GROUP_FIB       = "03 - Fibonacci"
string GROUP_VISUAL    = "04 - Visuals"
string GROUP_ALERTS    = "05 - Alerts"

string biasTimeframeMode = input.string("Auto", "Bias timeframe mode", options=["Auto", "Custom"], group=GROUP_BIAS, tooltip="Auto maps the current chart timeframe to a higher bias timeframe. Example: M5 → H1 and M15 → H4.")
string customBiasTimeframe = input.timeframe("240", "Custom bias timeframe", group=GROUP_BIAS, tooltip="Used only when Bias timeframe mode = Custom.")
string biasMethod = input.string("Structure", "Bias method", options=["Structure", "Structure + EMA"], group=GROUP_BIAS)
int biasPivotLeft = input.int(2, "Bias swing left bars", minval=1, maxval=10, group=GROUP_BIAS)
int biasPivotRight = input.int(2, "Bias swing right bars", minval=1, maxval=10, group=GROUP_BIAS)
int biasEmaLength = input.int(50, "Bias EMA length", minval=5, maxval=300, group=GROUP_BIAS)

int structurePivotLeft = input.int(3, "Structure swing left bars", minval=1, maxval=10, group=GROUP_STRUCTURE)
int structurePivotRight = input.int(3, "Structure swing right bars", minval=1, maxval=10, group=GROUP_STRUCTURE)
bool replaceWithNewBos = input.bool(true, "Use newest valid BOS", group=GROUP_STRUCTURE, tooltip="When enabled, a newer valid BOS in the bias direction replaces the active Fibonacci setup.")
string setupInvalidation = input.string("Close beyond origin", "Structure invalidation", options=["Close beyond origin", "Wick beyond origin"], group=GROUP_STRUCTURE)
int bosHistory = input.int(40, "Valid BOS history", minval=5, maxval=120, group=GROUP_STRUCTURE, tooltip="Maximum number of historical valid BOS line/text pairs retained on chart.")

float fibLockRetracement = input.float(0.382, "Lock impulse after retracement", minval=0.10, maxval=0.60, step=0.001, group=GROUP_FIB, tooltip="After a valid BOS, the impulse extreme remains dynamic. Fibonacci locks after a confirmed close retraces this fraction of the impulse.")
float fibLevel1 = input.float(0.618, "Fibonacci level 1", minval=0.50, maxval=0.75, step=0.001, group=GROUP_FIB)
float fibLevel2 = input.float(0.705, "Fibonacci level 2", minval=0.55, maxval=0.85, step=0.001, group=GROUP_FIB)
float fibLevel3 = input.float(0.790, "Fibonacci level 3", minval=0.60, maxval=0.90, step=0.001, group=GROUP_FIB)
float fibLevel4 = input.float(0.886, "Fibonacci level 4", minval=0.70, maxval=0.98, step=0.001, group=GROUP_FIB)
float minimumImpulseAtr = input.float(0.0, "Minimum impulse size (ATR)", minval=0.0, maxval=10.0, step=0.1, group=GROUP_FIB, tooltip="0 disables the impulse-size filter. Increase only if you want to ignore very small BOS impulses relative to current volatility.")
bool showFibonacciHistory = input.bool(true, "Show Fibonacci history", group=GROUP_FIB)
int fibonacciHistoryCount = input.int(4, "Fibonacci history count", minval=0, maxval=12, group=GROUP_FIB, tooltip="Number of completed/replaced Fibonacci structures retained behind the active setup. 0 keeps only the active Fibonacci.")

bool showBiasLevels = input.bool(false, "Show confirmed bias-TF swing levels", group=GROUP_VISUAL)
bool showChartLevels = input.bool(false, "Show current chart-TF swing levels", group=GROUP_VISUAL)
bool showValidBos = input.bool(true, "Show valid BOS", group=GROUP_VISUAL)
bool showFibonacci = input.bool(true, "Show active Fibonacci retracement", group=GROUP_VISUAL)
bool showDashboard = input.bool(true, "Show compact dashboard", group=GROUP_VISUAL)

bool enableDynamicAlerts = input.bool(false, "Enable dynamic alert() messages", group=GROUP_ALERTS)

// ============================================================================
// AUTO BIAS TIMEFRAME
// Keeps a practical multi-timeframe hierarchy while allowing Custom override.
// M1 → M15 | M2-M5 → H1 | M10-M30 → H4 | H1-H4 → D1 | D1 → W1 | W1 → 1M.
// ============================================================================
f_autoBiasTimeframe() =>
    float chartSeconds = timeframe.in_seconds(timeframe.period)
    chartSeconds <= 60 ? "15" :
     chartSeconds <= 300 ? "60" :
     chartSeconds <= 1800 ? "240" :
     chartSeconds <= 14400 ? "1D" :
     chartSeconds <= 86400 ? "1W" :
     chartSeconds <= 604800 ? "1M" :
     chartSeconds <= 2678400 ? "3M" : "12M"

string autoBiasTimeframe = f_autoBiasTimeframe()
string biasTimeframe = biasTimeframeMode == "Auto" ? autoBiasTimeframe : customBiasTimeframe

// ============================================================================
// VALIDATION
// ============================================================================
if barstate.isfirst
    if timeframe.in_seconds(biasTimeframe) <= timeframe.in_seconds(timeframe.period)
        runtime.error("Bias timeframe must be higher than the chart timeframe. Change the chart timeframe or use a higher Custom bias timeframe.")
    if not (fibLevel1 < fibLevel2 and fibLevel2 < fibLevel3 and fibLevel3 < fibLevel4)
        runtime.error("Fibonacci levels must be ordered from shallow to deep.")
    if fibLockRetracement >= fibLevel1
        runtime.error("Impulse lock retracement must be shallower than Fibonacci level 1.")

// ============================================================================
// FUNCTIONS
// ============================================================================
f_structureBias(int leftBars, int rightBars) =>
    float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
    float pivotLow = ta.pivotlow(low, leftBars, rightBars)
    float lastHigh = ta.valuewhen(not na(pivotHigh), pivotHigh, 0)
    float lastLow = ta.valuewhen(not na(pivotLow), pivotLow, 0)
    bool bullBreak = not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
    bool bearBreak = not na(lastLow) and close < lastLow and close[1] >= lastLow
    int lastBullBreakBar = ta.valuewhen(bullBreak, bar_index, 0)
    int lastBearBreakBar = ta.valuewhen(bearBreak, bar_index, 0)
    int structureBias = na(lastBullBreakBar) and na(lastBearBreakBar) ? DIR_NONE : na(lastBearBreakBar) ? DIR_LONG : na(lastBullBreakBar) ? DIR_SHORT : lastBullBreakBar > lastBearBreakBar ? DIR_LONG : DIR_SHORT
    structureBias

f_lastPivotHigh(int leftBars, int rightBars) =>
    float pivotHigh = ta.pivothigh(high, leftBars, rightBars)
    ta.valuewhen(not na(pivotHigh), pivotHigh, 0)

f_lastPivotLow(int leftBars, int rightBars) =>
    float pivotLow = ta.pivotlow(low, leftBars, rightBars)
    ta.valuewhen(not na(pivotLow), pivotLow, 0)

f_biasText(int value) =>
    value == DIR_LONG ? "BULLISH" : value == DIR_SHORT ? "BEARISH" : "NEUTRAL"

f_stateText(int value) =>
    value == STATE_IDLE ? "WAIT BOS" : value == STATE_TRACKING ? "TRACK IMPULSE" : value == STATE_FIB ? "FIB LOCKED" : "UNKNOWN"

f_fibPrice(int direction, float origin, float extreme, float ratio) =>
    direction == DIR_LONG ? extreme - (extreme - origin) * ratio : extreme + (origin - extreme) * ratio

f_tfText(string tf) =>
    tf == "1" ? "M1" : tf == "2" ? "M2" : tf == "3" ? "M3" : tf == "5" ? "M5" : tf == "10" ? "M10" : tf == "15" ? "M15" : tf == "30" ? "M30" : tf == "45" ? "M45" : tf == "60" ? "H1" : tf == "120" ? "H2" : tf == "180" ? "H3" : tf == "240" ? "H4" : tf == "1D" ? "D1" : tf == "1W" ? "W1" : tf == "1M" ? "1M" : tf == "3M" ? "3M" : tf == "12M" ? "12M" : tf

f_archiveFibObject(line fibLine, label fibText, int endBar, bool keepHistory, int historyCount, array<line> historyLines, array<label> historyTexts, color historyColor) =>
    if not na(fibLine)
        if keepHistory and historyCount > 0
            line.set_extend(fibLine, extend.none)
            line.set_x2(fibLine, endBar)
            line.set_color(fibLine, color.new(historyColor, 45))
            array.push(historyLines, fibLine)
        else
            line.delete(fibLine)
    if not na(fibText)
        if keepHistory and historyCount > 0
            label.set_x(fibText, endBar + 1)
            label.set_textcolor(fibText, color.new(historyColor, 30))
            array.push(historyTexts, fibText)
        else
            label.delete(fibText)

f_trimFibHistory(array<line> historyLines, array<label> historyTexts, int historyCount) =>
    int maxObjects = math.max(historyCount, 0) * 4
    while array.size(historyLines) > maxObjects
        line.delete(array.shift(historyLines))
    while array.size(historyTexts) > maxObjects
        label.delete(array.shift(historyTexts))

// ============================================================================
// CONFIRMED BIAS-TIMEFRAME DATA
// Uses the documented non-repainting HTF pattern: expression[1] + lookahead_on.
// ============================================================================
int biasStructureBias = request.security(syminfo.tickerid, biasTimeframe, f_structureBias(biasPivotLeft, biasPivotRight)[1], lookahead=barmerge.lookahead_on)
float biasSwingHigh = request.security(syminfo.tickerid, biasTimeframe, f_lastPivotHigh(biasPivotLeft, biasPivotRight)[1], lookahead=barmerge.lookahead_on)
float biasSwingLow = request.security(syminfo.tickerid, biasTimeframe, f_lastPivotLow(biasPivotLeft, biasPivotRight)[1], lookahead=barmerge.lookahead_on)
float biasConfirmedClose = request.security(syminfo.tickerid, biasTimeframe, close[1], lookahead=barmerge.lookahead_on)
float biasConfirmedEma = request.security(syminfo.tickerid, biasTimeframe, ta.ema(close, biasEmaLength)[1], lookahead=barmerge.lookahead_on)
float biasPreviousEma = request.security(syminfo.tickerid, biasTimeframe, ta.ema(close, biasEmaLength)[2], lookahead=barmerge.lookahead_on)

bool biasBullEma = biasConfirmedClose > biasConfirmedEma and biasConfirmedEma > biasPreviousEma
bool biasBearEma = biasConfirmedClose < biasConfirmedEma and biasConfirmedEma < biasPreviousEma
int effectiveBias = biasMethod == "Structure" ? biasStructureBias : biasStructureBias == DIR_LONG and biasBullEma ? DIR_LONG : biasStructureBias == DIR_SHORT and biasBearEma ? DIR_SHORT : DIR_NONE

// ============================================================================
// CHART-TIMEFRAME SWINGS
// ============================================================================
float chartPivotHigh = ta.pivothigh(high, structurePivotLeft, structurePivotRight)
float chartPivotLow = ta.pivotlow(low, structurePivotLeft, structurePivotRight)

var float lastChartSwingHigh = na
var float lastChartSwingLow = na
var int lastChartSwingHighBar = na
var int lastChartSwingLowBar = na

if not na(chartPivotHigh)
    lastChartSwingHigh := chartPivotHigh
    lastChartSwingHighBar := bar_index - structurePivotRight

if not na(chartPivotLow)
    lastChartSwingLow := chartPivotLow
    lastChartSwingLowBar := bar_index - structurePivotRight

// A raw BOS requires a CONFIRMED chart-TF close through a confirmed structural pivot.
var int lastBullBrokenSwingBar = na
var int lastBearBrokenSwingBar = na

bool rawBullBos = barstate.isconfirmed and not na(lastChartSwingHigh) and close > lastChartSwingHigh and close[1] <= lastChartSwingHigh
bool rawBearBos = barstate.isconfirmed and not na(lastChartSwingLow) and close < lastChartSwingLow and close[1] >= lastChartSwingLow
bool uniqueBullBos = rawBullBos and (na(lastBullBrokenSwingBar) or lastChartSwingHighBar != lastBullBrokenSwingBar)
bool uniqueBearBos = rawBearBos and (na(lastBearBrokenSwingBar) or lastChartSwingLowBar != lastBearBrokenSwingBar)

if uniqueBullBos
    lastBullBrokenSwingBar := lastChartSwingHighBar
if uniqueBearBos
    lastBearBrokenSwingBar := lastChartSwingLowBar

// Valid BOS definition for this build:
// 1) confirmed close through an unbroken confirmed chart-TF swing,
// 2) aligned with confirmed bias-timeframe bias,
// 3) a valid opposite swing exists AFTER the broken swing, providing a structural BOS-origin anchor.
bool validBullOrigin = not na(lastChartSwingLow) and not na(lastChartSwingLowBar) and not na(lastChartSwingHighBar) and lastChartSwingLowBar > lastChartSwingHighBar and lastChartSwingLowBar < bar_index and lastChartSwingLow < close
bool validBearOrigin = not na(lastChartSwingHigh) and not na(lastChartSwingHighBar) and not na(lastChartSwingLowBar) and lastChartSwingHighBar > lastChartSwingLowBar and lastChartSwingHighBar < bar_index and lastChartSwingHigh > close

bool validBullBos = uniqueBullBos and effectiveBias == DIR_LONG and validBullOrigin
bool validBearBos = uniqueBearBos and effectiveBias == DIR_SHORT and validBearOrigin

// ============================================================================
// BOS VISUALS - horizontal structure line + text only.
// Pine line objects cannot contain text, so label.style_none is used only as
// transparent text centered on the line; there is no badge/box background.
// ============================================================================
// High-contrast palette. White is intentionally avoided for text-only chart
// objects so BOS/Fibonacci remain noticeable on both dark and light themes.
color brandBlue    = color.rgb(36, 105, 255)
color accentCyan   = color.rgb(0, 194, 255)
color accentAmber  = color.rgb(255, 200, 87)
color accentOrange = color.rgb(255, 138, 61)
color bearCoral    = color.rgb(255, 92, 112)
color brandBlack   = color.rgb(18, 22, 28)
color textPrimary  = color.rgb(181, 205, 232)
color softGray     = color.rgb(126, 138, 154)
color historyTone  = color.rgb(96, 116, 142)
color panelHeader  = color.rgb(11, 19, 32)
color panelDark    = color.rgb(16, 23, 34)
color panelAlt     = color.rgb(21, 30, 43)
color panelLine    = color.rgb(39, 54, 74)

var array<line> bosLines = array.new_line()
var array<label> bosTexts = array.new_label()

if showValidBos and validBullBos
    int textBar = int(math.floor((lastChartSwingHighBar + bar_index) * 0.5))
    line bosLine = line.new(lastChartSwingHighBar, lastChartSwingHigh, bar_index, lastChartSwingHigh, xloc=xloc.bar_index, extend=extend.none, color=brandBlue, style=line.style_solid, width=1)
    label bosText = label.new(textBar, lastChartSwingHigh, "BOS", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=brandBlue, size=size.tiny)
    array.push(bosLines, bosLine)
    array.push(bosTexts, bosText)

if showValidBos and validBearBos
    int textBar = int(math.floor((lastChartSwingLowBar + bar_index) * 0.5))
    line bosLine = line.new(lastChartSwingLowBar, lastChartSwingLow, bar_index, lastChartSwingLow, xloc=xloc.bar_index, extend=extend.none, color=bearCoral, style=line.style_solid, width=1)
    label bosText = label.new(textBar, lastChartSwingLow, "BOS", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=bearCoral, size=size.tiny)
    array.push(bosLines, bosLine)
    array.push(bosTexts, bosText)

while array.size(bosLines) > bosHistory
    line.delete(array.shift(bosLines))
while array.size(bosTexts) > bosHistory
    label.delete(array.shift(bosTexts))

// ============================================================================
// STRUCTURE -> IMPULSE -> FIBONACCI STATE
// ============================================================================
float atr = ta.atr(14)

var int state = STATE_IDLE
var int setupDirection = DIR_NONE
var float impulseOrigin = na
var int impulseOriginBar = na
var float impulseExtreme = na
var int impulseExtremeBar = na
var float brokenStructureLevel = na
var int brokenStructureBar = na
var int fibLockBar = na

var float fib1 = na
var float fib2 = na
var float fib3 = na
var float fib4 = na

bool fibLockedEvent = false

// Active Fibonacci objects. Only the CURRENT valid structure setup is shown.
var line fibLine1 = na
var line fibLine2 = na
var line fibLine3 = na
var line fibLine4 = na
var label fibText1 = na
var label fibText2 = na
var label fibText3 = na
var label fibText4 = na

// Historical Fibonacci sets. Each completed set contributes four lines + four ratio texts.
var array<line> fibHistoryLines = array.new_line()
var array<label> fibHistoryTexts = array.new_label()

// Reset active Fibonacci visual helper block (inline to keep object ownership clear).
bool activeStructure = state == STATE_TRACKING or state == STATE_FIB
bool activeOriginBroken = false
if activeStructure and barstate.isconfirmed
    if setupDirection == DIR_LONG
        activeOriginBroken := setupInvalidation == "Wick beyond origin" ? low < impulseOrigin : close < impulseOrigin
    else if setupDirection == DIR_SHORT
        activeOriginBroken := setupInvalidation == "Wick beyond origin" ? high > impulseOrigin : close > impulseOrigin

bool biasInvalidated = activeStructure and effectiveBias != setupDirection

if activeOriginBroken or biasInvalidated
    // Freeze a locked Fibonacci as history before resetting the structure.
    f_archiveFibObject(fibLine1, fibText1, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_archiveFibObject(fibLine2, fibText2, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_archiveFibObject(fibLine3, fibText3, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_archiveFibObject(fibLine4, fibText4, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_trimFibHistory(fibHistoryLines, fibHistoryTexts, fibonacciHistoryCount)
    fibLine1 := na
    fibLine2 := na
    fibLine3 := na
    fibLine4 := na
    fibText1 := na
    fibText2 := na
    fibText3 := na
    fibText4 := na

    state := STATE_IDLE
    setupDirection := DIR_NONE
    impulseOrigin := na
    impulseOriginBar := na
    impulseExtreme := na
    impulseExtremeBar := na
    brokenStructureLevel := na
    brokenStructureBar := na
    fibLockBar := na
    fib1 := na
    fib2 := na
    fib3 := na
    fib4 := na

bool canStartNew = state == STATE_IDLE or replaceWithNewBos
bool startBullSetup = validBullBos and canStartNew
bool startBearSetup = validBearBos and canStartNew

if startBullSetup or startBearSetup
    // A newer valid BOS supersedes the previous active Fibonacci. Preserve it as bounded history.
    f_archiveFibObject(fibLine1, fibText1, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_archiveFibObject(fibLine2, fibText2, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_archiveFibObject(fibLine3, fibText3, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_archiveFibObject(fibLine4, fibText4, bar_index, showFibonacciHistory, fibonacciHistoryCount, fibHistoryLines, fibHistoryTexts, historyTone)
    f_trimFibHistory(fibHistoryLines, fibHistoryTexts, fibonacciHistoryCount)
    fibLine1 := na
    fibLine2 := na
    fibLine3 := na
    fibLine4 := na
    fibText1 := na
    fibText2 := na
    fibText3 := na
    fibText4 := na

    state := STATE_TRACKING
    fibLockBar := na
    fib1 := na
    fib2 := na
    fib3 := na
    fib4 := na

    if startBullSetup
        setupDirection := DIR_LONG
        impulseOrigin := lastChartSwingLow
        impulseOriginBar := lastChartSwingLowBar
        impulseExtreme := high
        impulseExtremeBar := bar_index
        brokenStructureLevel := lastChartSwingHigh
        brokenStructureBar := lastChartSwingHighBar
    else
        setupDirection := DIR_SHORT
        impulseOrigin := lastChartSwingHigh
        impulseOriginBar := lastChartSwingHighBar
        impulseExtreme := low
        impulseExtremeBar := bar_index
        brokenStructureLevel := lastChartSwingLow
        brokenStructureBar := lastChartSwingLowBar

// Track the post-BOS impulse until a confirmed retracement locks the extreme.
if state == STATE_TRACKING and barstate.isconfirmed
    if setupDirection == DIR_LONG
        if high > impulseExtreme
            impulseExtreme := high
            impulseExtremeBar := bar_index
        float currentRange = impulseExtreme - impulseOrigin
        float lockPrice = impulseExtreme - currentRange * fibLockRetracement
        bool largeEnough = minimumImpulseAtr <= 0.0 or currentRange >= atr * minimumImpulseAtr
        if currentRange > syminfo.mintick and largeEnough and close <= lockPrice
            fib1 := f_fibPrice(DIR_LONG, impulseOrigin, impulseExtreme, fibLevel1)
            fib2 := f_fibPrice(DIR_LONG, impulseOrigin, impulseExtreme, fibLevel2)
            fib3 := f_fibPrice(DIR_LONG, impulseOrigin, impulseExtreme, fibLevel3)
            fib4 := f_fibPrice(DIR_LONG, impulseOrigin, impulseExtreme, fibLevel4)
            fibLockBar := bar_index
            state := STATE_FIB
            fibLockedEvent := true
    else if setupDirection == DIR_SHORT
        if low < impulseExtreme
            impulseExtreme := low
            impulseExtremeBar := bar_index
        float currentRange = impulseOrigin - impulseExtreme
        float lockPrice = impulseExtreme + currentRange * fibLockRetracement
        bool largeEnough = minimumImpulseAtr <= 0.0 or currentRange >= atr * minimumImpulseAtr
        if currentRange > syminfo.mintick and largeEnough and close >= lockPrice
            fib1 := f_fibPrice(DIR_SHORT, impulseOrigin, impulseExtreme, fibLevel1)
            fib2 := f_fibPrice(DIR_SHORT, impulseOrigin, impulseExtreme, fibLevel2)
            fib3 := f_fibPrice(DIR_SHORT, impulseOrigin, impulseExtreme, fibLevel3)
            fib4 := f_fibPrice(DIR_SHORT, impulseOrigin, impulseExtreme, fibLevel4)
            fibLockBar := bar_index
            state := STATE_FIB
            fibLockedEvent := true

// ============================================================================
// ACTIVE FIBONACCI VISUALS
// Dotted horizontal levels + ratio text only. NO price is displayed.
// ============================================================================
if fibLockedEvent and showFibonacci
    int fibStartBar = math.min(impulseOriginBar, impulseExtremeBar)
    fibLine1 := line.new(fibStartBar, fib1, bar_index, fib1, xloc=xloc.bar_index, extend=extend.right, color=color.new(brandBlue, 0), style=line.style_dotted, width=1)
    fibLine2 := line.new(fibStartBar, fib2, bar_index, fib2, xloc=xloc.bar_index, extend=extend.right, color=color.new(accentCyan, 5), style=line.style_dotted, width=1)
    fibLine3 := line.new(fibStartBar, fib3, bar_index, fib3, xloc=xloc.bar_index, extend=extend.right, color=color.new(accentAmber, 0), style=line.style_dotted, width=1)
    fibLine4 := line.new(fibStartBar, fib4, bar_index, fib4, xloc=xloc.bar_index, extend=extend.right, color=color.new(accentOrange, 0), style=line.style_dotted, width=1)

    fibText1 := label.new(bar_index + 1, fib1, str.tostring(fibLevel1, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=brandBlue, size=size.tiny)
    fibText2 := label.new(bar_index + 1, fib2, str.tostring(fibLevel2, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=accentCyan, size=size.tiny)
    fibText3 := label.new(bar_index + 1, fib3, str.tostring(fibLevel3, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=accentAmber, size=size.tiny)
    fibText4 := label.new(bar_index + 1, fib4, str.tostring(fibLevel4, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=accentOrange, size=size.tiny)

// Keep ratio text at the current right edge while the Fibonacci remains active.
if state == STATE_FIB and showFibonacci
    if not na(fibText1)
        label.set_x(fibText1, bar_index + 1)
        label.set_y(fibText1, fib1)
    if not na(fibText2)
        label.set_x(fibText2, bar_index + 1)
        label.set_y(fibText2, fib2)
    if not na(fibText3)
        label.set_x(fibText3, bar_index + 1)
        label.set_y(fibText3, fib3)
    if not na(fibText4)
        label.set_x(fibText4, bar_index + 1)
        label.set_y(fibText4, fib4)

// Visual toggle can hide/show an already locked active Fibonacci without changing its logic state.
if state == STATE_FIB and not showFibonacci
    if not na(fibLine1)
        line.delete(fibLine1)
        fibLine1 := na
    if not na(fibLine2)
        line.delete(fibLine2)
        fibLine2 := na
    if not na(fibLine3)
        line.delete(fibLine3)
        fibLine3 := na
    if not na(fibLine4)
        line.delete(fibLine4)
        fibLine4 := na
    if not na(fibText1)
        label.delete(fibText1)
        fibText1 := na
    if not na(fibText2)
        label.delete(fibText2)
        fibText2 := na
    if not na(fibText3)
        label.delete(fibText3)
        fibText3 := na
    if not na(fibText4)
        label.delete(fibText4)
        fibText4 := na

if state == STATE_FIB and showFibonacci and na(fibLine1)
    int fibStartBar = math.min(impulseOriginBar, impulseExtremeBar)
    fibLine1 := line.new(fibStartBar, fib1, bar_index, fib1, xloc=xloc.bar_index, extend=extend.right, color=color.new(brandBlue, 0), style=line.style_dotted, width=1)
    fibLine2 := line.new(fibStartBar, fib2, bar_index, fib2, xloc=xloc.bar_index, extend=extend.right, color=color.new(accentCyan, 5), style=line.style_dotted, width=1)
    fibLine3 := line.new(fibStartBar, fib3, bar_index, fib3, xloc=xloc.bar_index, extend=extend.right, color=color.new(accentAmber, 0), style=line.style_dotted, width=1)
    fibLine4 := line.new(fibStartBar, fib4, bar_index, fib4, xloc=xloc.bar_index, extend=extend.right, color=color.new(accentOrange, 0), style=line.style_dotted, width=1)
    fibText1 := label.new(bar_index + 1, fib1, str.tostring(fibLevel1, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=brandBlue, size=size.tiny)
    fibText2 := label.new(bar_index + 1, fib2, str.tostring(fibLevel2, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=accentCyan, size=size.tiny)
    fibText3 := label.new(bar_index + 1, fib3, str.tostring(fibLevel3, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=accentAmber, size=size.tiny)
    fibText4 := label.new(bar_index + 1, fib4, str.tostring(fibLevel4, "#.###"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=accentOrange, size=size.tiny)

// ============================================================================
// OPTIONAL REFERENCE LEVELS
// ============================================================================
plot(showBiasLevels ? biasSwingHigh : na, "Bias-TF confirmed swing high", color=color.new(bearCoral, 45), linewidth=1, style=plot.style_linebr)
plot(showBiasLevels ? biasSwingLow : na, "Bias-TF confirmed swing low", color=color.new(brandBlue, 45), linewidth=1, style=plot.style_linebr)
plot(showChartLevels ? lastChartSwingHigh : na, "Chart-TF swing high", color=color.new(bearCoral, 68), linewidth=1, style=plot.style_linebr)
plot(showChartLevels ? lastChartSwingLow : na, "Chart-TF swing low", color=color.new(brandBlue, 72), linewidth=1, style=plot.style_linebr)

// ============================================================================
// COMPACT DASHBOARD - structure information only; no trade assumptions.
// Uses hierarchy, tinted status cells, and alternating panels for fast scanning.
// ============================================================================
var table dashboard = table.new(position.top_right, 2, 6, bgcolor=panelDark, frame_color=color.new(brandBlue, 15), frame_width=1, border_color=color.new(panelLine, 15), border_width=1)

if barstate.islast and showDashboard
    color biasAccent = effectiveBias == DIR_LONG ? brandBlue : effectiveBias == DIR_SHORT ? bearCoral : softGray
    color biasBg = effectiveBias == DIR_LONG ? color.new(brandBlue, 82) : effectiveBias == DIR_SHORT ? color.new(bearCoral, 82) : color.new(softGray, 88)
    color structureAccent = setupDirection == DIR_LONG ? brandBlue : setupDirection == DIR_SHORT ? bearCoral : softGray
    color structureBg = setupDirection == DIR_LONG ? color.new(brandBlue, 86) : setupDirection == DIR_SHORT ? color.new(bearCoral, 86) : color.new(softGray, 90)
    color stateAccent = state == STATE_FIB ? accentCyan : state == STATE_TRACKING ? accentAmber : softGray
    color stateBg = state == STATE_FIB ? color.new(accentCyan, 86) : state == STATE_TRACKING ? color.new(accentAmber, 88) : color.new(softGray, 92)
    string fibStatus = state == STATE_FIB ? "LOCKED" : state == STATE_TRACKING ? "BUILDING" : "—"
    int retainedHistory = int(array.size(fibHistoryLines) / 4)

    table.cell(dashboard, 0, 0, "JFX STRUCTURE FIB", bgcolor=panelHeader, text_color=accentCyan, text_size=size.small)
    table.cell(dashboard, 1, 0, "v1.0 RC", bgcolor=color.new(brandBlue, 72), text_color=textPrimary, text_size=size.tiny)

    table.cell(dashboard, 0, 1, "TIMEFRAME", bgcolor=panelAlt, text_color=softGray, text_size=size.tiny)
    table.cell(dashboard, 1, 1, f_tfText(timeframe.period) + "  →  " + f_tfText(biasTimeframe), bgcolor=panelDark, text_color=accentCyan, text_size=size.small)

    table.cell(dashboard, 0, 2, "HTF BIAS", bgcolor=panelAlt, text_color=softGray, text_size=size.tiny)
    table.cell(dashboard, 1, 2, f_biasText(effectiveBias), bgcolor=biasBg, text_color=biasAccent, text_size=size.small)

    table.cell(dashboard, 0, 3, "STRUCTURE", bgcolor=panelAlt, text_color=softGray, text_size=size.tiny)
    table.cell(dashboard, 1, 3, setupDirection == DIR_LONG ? "BULL BOS" : setupDirection == DIR_SHORT ? "BEAR BOS" : "—", bgcolor=structureBg, text_color=structureAccent, text_size=size.small)

    table.cell(dashboard, 0, 4, "FIB STATE", bgcolor=panelAlt, text_color=softGray, text_size=size.tiny)
    table.cell(dashboard, 1, 4, fibStatus, bgcolor=stateBg, text_color=stateAccent, text_size=size.small)

    table.cell(dashboard, 0, 5, "HISTORY", bgcolor=panelAlt, text_color=softGray, text_size=size.tiny)
    table.cell(dashboard, 1, 5, str.tostring(retainedHistory) + " / " + str.tostring(fibonacciHistoryCount), bgcolor=panelDark, text_color=accentAmber, text_size=size.small)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 5)

// ============================================================================
// ALERTS — structure only.
// ============================================================================
alertcondition(validBullBos, "JFX Valid Bullish BOS", "JFX Structure Fib: valid bullish BOS confirmed in the active bias-timeframe direction.")
alertcondition(validBearBos, "JFX Valid Bearish BOS", "JFX Structure Fib: valid bearish BOS confirmed in the active bias-timeframe direction.")
alertcondition(fibLockedEvent, "JFX Fibonacci Locked", "JFX Structure Fib: BOS impulse locked; Fibonacci retracement levels are active.")

if enableDynamicAlerts
    if validBullBos
        alert("JFX Structure Fib | VALID BULLISH BOS", alert.freq_once_per_bar_close)
    if validBearBos
        alert("JFX Structure Fib | VALID BEARISH BOS", alert.freq_once_per_bar_close)
    if fibLockedEvent
        alert("JFX Structure Fib | FIBONACCI LOCKED | " + f_biasText(setupDirection), alert.freq_once_per_bar_close)
````
