# Bias Status Dashboard

- url: https://www.tradingview.com/script/xAe8yraD-Bias-Status-Dashboard/
- type: indicator
- pine_id: PUB;488d3e2290294a66a98881c110bf08c7
- version: 2.0

## Description

## Bias Status Dashboard

The **Bias Status Dashboard** is designed to help traders quickly identify the current market bias using a clean, structured dashboard directly on the chart. Instead of relying on one signal alone, this indicator organizes multiple pieces of market context into an easy-to-read status panel so you can make faster and more confident trading decisions.

This tool is especially useful for traders who want a simple visual summary of whether the market is leaning **bullish, bearish, ranging, continuation-based, or reversal-based**.

---

## What This Indicator Does

The Bias Status Dashboard evaluates current market conditions and displays the active bias in a compact table format. It helps answer questions such as:

* Is the current market leaning bullish or bearish?
* Are price conditions supporting continuation?
* Is the market showing signs of reversal?
* Are we in a normal, moderate, or extreme projected zone?
* Is the current chart aligned with the active bias?
* Are targets and projections still reasonable based on current price action?

This makes it easier to filter trades instead of taking every possible setup.

---

## Key Features

### Market Bias Status

The dashboard provides a clear bias reading so traders can quickly understand the current market environment.

Bias may display conditions such as:

* Bullish bias
* Bearish bias
* Neutral or ranging market
* Continuation condition
* Reversal condition
* Overextended or extreme condition

This gives a quick directional snapshot without needing to manually interpret every candle.

---

### Current Market Identification

The dashboard includes a row that identifies the current chart market/symbol you are viewing.

This is useful when switching between markets such as:

* MES
* ES
* MNQ
* NQ
* MGC
* GC
* M2K
* Other futures or index charts

The goal is to keep the dashboard tied to the current chart so the information stays relevant to the market being analyzed.

---

### Projection-Based Zones

The indicator includes projected market zones based on the current calculation.

These zones help classify price movement into different strength areas:

* **Normal Zone** – price is within a reasonable projected movement range.
* **Moderate Zone** – price is moving further into projection and should be watched more carefully.
* **Extreme Zone** – price is reaching an extended area where continuation may be less favorable or reversal risk may increase.

This helps traders avoid chasing price when the market is already stretched.

---

### Percentage References

The dashboard also includes percentage-based references so traders can better understand how much of the projected move has already been used.

This is helpful for determining:

* How much room may remain in the current move
* Whether price is still in a healthy continuation area
* Whether the market is becoming overextended
* Whether a trade has enough potential left before entering

Instead of only seeing lines or zones visually, the dashboard gives numerical context.

---

### Chart Zone Lines

Optional chart lines can be plotted based on the projection zones.

These lines allow traders to visually see where the normal, moderate, and extreme areas are located directly on the chart.

The zone lines are useful for:

* Target planning
* Avoiding late entries
* Understanding where price may react
* Seeing when price enters an overextended area
* Comparing current price to projected movement levels

The lines are designed to apply only to the current chart being viewed.

---

### High and Low Projection Areas

The indicator can show both upside and downside projection levels.

This helps traders understand where price may be considered extended in either direction:

* Extreme High areas appear toward the top of the projection.
* Extreme Low areas appear toward the bottom of the projection.
* Moderate and normal zones are placed between them in proper order.

This keeps the projection structure logical and visually cleaner.

---

### Cleaner Visual Layout

The dashboard and chart labels are designed to reduce clutter while still giving detailed information.

Features may include:

* Organized table rows
* Customizable text placement
* Dashed projection lines
* Zone labels
* Cleaner spacing between dashboard elements
* Improved label positioning when levels are close together

This makes the indicator easier to use during live chart analysis.

---

## How Traders Can Use It

The Bias Status Dashboard is best used as a **decision-support tool**, not as a stand-alone buy or sell signal.

It can help traders confirm whether a setup makes sense based on the current market environment.

For example:

### Bullish Continuation

If the dashboard shows bullish bias and price is still within the normal or moderate upside projection zone, a trader may look for long setups that align with their own strategy.

### Bearish Continuation

If the dashboard shows bearish bias and price has room before reaching an extreme downside projection, a trader may look for short setups that match their trading plan.

### Avoiding Late Entries

If price is already in an extreme high or extreme low zone, the dashboard can warn that the move may be stretched. This may help traders avoid chasing entries too late.

### Ranging Conditions

If the dashboard shows a neutral or ranging condition, traders may choose to wait for stronger confirmation before entering.

### Reversal Awareness

When price enters an extreme projection area, traders can use that information to watch for possible rejection, exhaustion, or reversal behavior.

---

## Best Use Cases

This indicator may be helpful for:

* Intraday futures trading
* Bias confirmation
* Continuation trade filtering
* Reversal awareness
* Target planning
* Projection-based analysis
* Avoiding overextended entries
* Comparing bullish and bearish market conditions
* Quickly reading market structure context from a dashboard

It can be used on multiple futures and index markets, but users should test the settings for their preferred symbol and timeframe.

---

## Suggested Workflow

A simple workflow could be:

1. Check the dashboard bias.
2. Confirm whether the market is bullish, bearish, neutral, or extended.
3. Look at the projection zones.
4. Avoid entries if price is already too far into an extreme zone.
5. Use your own strategy for entries, stops, and trade management.
6. Use the dashboard as a filter to support higher-quality decisions.

---

## Important Notes

This indicator does not guarantee price direction or trade outcomes. It is designed to provide market context and help traders organize bias, projection, and zone information in one place.

Traders should always use proper risk management and combine this tool with their own tested trading plan.

The dashboard is intended to support analysis, not replace it.

---

## Summary

The **Bias Status Dashboard** provides a visual and numerical summary of current market bias, projected zones, and percentage-based movement context. It helps traders quickly determine whether the market is bullish, bearish, neutral, normal, moderate, or extreme.

By combining a dashboard with optional chart projection lines, the indicator gives traders a cleaner way to understand where price currently sits within the expected movement range and whether there may still be room for continuation.

## Source Code

````pine
//@version=6
indicator("Bias Status Dashboard Pro", overlay = true, max_labels_count = 50)

// =====================================================
// GROUPS
// =====================================================
var G_DASH   = "01. Dashboard Layout"
var G_STYLE  = "02. Dashboard Colors"
var G_AUTO   = "03. Auto Symbol Presets"
var G_CORE   = "04. Core Bias Engine"
var G_TREND  = "05. Trend Settings"
var G_MOM    = "06. Momentum Settings"
var G_VOL    = "07. Volatility / Market State"
var G_STRUCT = "08. Structure Settings"
var G_SESS   = "09. Session Bias Settings"
var G_MTF    = "10. Multi-Timeframe Bias"

// =====================================================
// 01. DASHBOARD LAYOUT
// =====================================================
bool showMainDash = input.bool(true, "Show Main Dashboard", group = G_DASH)
string dashLayoutInput = input.string("Moderate", "Dashboard Layout", options = ["Compact", "Moderate", "Full"], group = G_DASH, tooltip = "Compact = cleanest. Moderate = best default. Full = full component breakdown.")
string dashPosInput = input.string("Middle Right", "Main Dashboard Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_DASH)
string mtfDashPosInput = input.string("Top Right", "MTF Dashboard Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = G_DASH)
string dashSizeInput = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = G_DASH)
bool showTickerRow = input.bool(true, "Show Ticker Row", group = G_DASH)
bool showPresetRow = input.bool(true, "Show Market Preset Row", group = G_DASH)
bool showReasonRow = input.bool(true, "Show Reason Row in Full Layout", group = G_DASH)

// =====================================================
// 02. DASHBOARD COLORS
// =====================================================
color headerBg      = input.color(color.rgb(50, 35, 110), "Main Header Background", group = G_STYLE)
color sectionBg     = input.color(color.rgb(35, 25, 85), "MTF Header Background", group = G_STYLE)
color tableBg       = input.color(color.new(color.black, 10), "Table Background", group = G_STYLE)
color borderColor   = input.color(color.new(color.white, 65), "Border Color", group = G_STYLE)
color labelTextCol  = input.color(color.white, "Left Column Text", group = G_STYLE)

color bullColor     = input.color(color.lime, "Bullish Text", group = G_STYLE)
color bearColor     = input.color(color.red, "Bearish Text", group = G_STYLE)
color neutralColor  = input.color(color.orange, "Neutral / Warning Text", group = G_STYLE)
color weakColor     = input.color(color.gray, "Weak Text", group = G_STYLE)
color starColor     = input.color(color.orange, "Star Color", group = G_STYLE)

// =====================================================
// 03. AUTO SYMBOL PRESETS
// =====================================================
bool useAutoSymbolPresets = input.bool(true, "Auto-Detect Symbol Presets", group = G_AUTO, tooltip = "Automatically adjusts common sensitivity settings based on the ticker type. Users can turn this off and use the manual settings instead.")
string manualMarketType = input.string("Auto", "Market Type Override", options = ["Auto", "General", "Index Futures", "Gold Futures", "Oil Futures", "Other Futures", "Crypto", "Stocks", "Forex"], group = G_AUTO, tooltip = "Auto lets the script detect the ticker. Pick a market type manually if the chart symbol is unusual.")
string presetSensitivity = input.string("Balanced", "Preset Sensitivity", options = ["Responsive", "Balanced", "Conservative"], group = G_AUTO, tooltip = "Responsive changes bias faster. Conservative requires stronger confirmation.")
bool applyAutoAdxAtr = input.bool(true, "Auto-Adjust ADX / ATR Thresholds", group = G_AUTO)
bool applyAutoMomentum = input.bool(true, "Auto-Adjust RSI Thresholds", group = G_AUTO)
bool applyAutoVwapBand = input.bool(true, "Auto-Adjust VWAP Neutral Band", group = G_AUTO)

// =====================================================
// 04. CORE BIAS ENGINE
// =====================================================
string biasMode = input.string("Hybrid Score", "Primary Bias Mode", options = ["Hybrid Score", "Trend Only", "VWAP Only", "Momentum Only", "Structure Only", "MTF Only", "Session Sweep Only", "Manual"], group = G_CORE, tooltip = "Hybrid Score is best for general users. Session Sweep Only keeps the older Asia sweep style as an optional mode.")
string manualBias = input.string("All", "Manual Bias", options = ["All", "Longs Only", "Shorts Only"], group = G_CORE)

bool useTrendBias     = input.bool(true, "Use Trend Bias", group = G_CORE)
bool useVwapBias      = input.bool(true, "Use VWAP Bias", group = G_CORE)
bool useMomentumBias  = input.bool(true, "Use Momentum Bias", group = G_CORE)
bool useStructureBias = input.bool(true, "Use Structure Bias", group = G_CORE)
bool useMtfBias       = input.bool(true, "Use MTF Bias", group = G_CORE)
bool useSessionBias   = input.bool(false, "Use Session Sweep Bias", group = G_CORE, tooltip = "Off by default so this dashboard does not force your personal Asia sweep logic on users.")

int minDirectionalScore = input.int(2, "Minimum Score for Bull/Bear Bias", minval = 1, maxval = 6, group = G_CORE)
float neutralStrengthPct = input.float(35.0, "Weak / Neutral Strength Below %", minval = 0, maxval = 100, step = 5, group = G_CORE)

// =====================================================
// 05. TREND SETTINGS
// =====================================================
string maType = input.string("EMA", "Moving Average Type", options = ["EMA", "SMA", "VWMA"], group = G_TREND)
int fastMaLen = input.int(9, "Fast MA", minval = 1, group = G_TREND)
int midMaLen  = input.int(21, "Mid MA", minval = 1, group = G_TREND)
int slowMaLen = input.int(50, "Slow MA", minval = 1, group = G_TREND)

// =====================================================
// 06. MOMENTUM SETTINGS
// =====================================================
int rsiLen       = input.int(14, "RSI Length", minval = 1, group = G_MOM)
float rsiBullLvl = input.float(52.0, "RSI Bull Level", step = 0.5, group = G_MOM)
float rsiBearLvl = input.float(48.0, "RSI Bear Level", step = 0.5, group = G_MOM)

int stochRsiLen = input.int(14, "Stoch RSI Length", minval = 1, group = G_MOM)
int stochLen    = input.int(14, "Stoch Length", minval = 1, group = G_MOM)
int kSmooth     = input.int(3, "Stoch K Smooth", minval = 1, group = G_MOM)
int dSmooth     = input.int(3, "Stoch D Smooth", minval = 1, group = G_MOM)
int stochMid    = input.int(50, "Stoch Midline", minval = 1, maxval = 99, group = G_MOM)

int volLen = input.int(20, "Volume Average Length", minval = 1, group = G_MOM)

// =====================================================
// 07. VOLATILITY / MARKET STATE
// =====================================================
int adxLen     = input.int(14, "ADX Length", minval = 1, group = G_VOL)
float minAdx   = input.float(20.0, "Minimum ADX Trend Strength", step = 0.5, group = G_VOL)

int atrLen     = input.int(14, "ATR Length", minval = 1, group = G_VOL)
int atrAvgLen  = input.int(50, "ATR Average Length", minval = 1, group = G_VOL)
float atrStrongRatio = input.float(1.10, "ATR Expanding Ratio", step = 0.05, group = G_VOL)
float atrWeakRatio   = input.float(0.85, "ATR Weak Ratio", step = 0.05, group = G_VOL)

float vwapNeutralAtrPct = input.float(0.10, "VWAP Neutral Band as ATR %", minval = 0.0, step = 0.05, group = G_VOL, tooltip = "Prevents VWAP bias from flipping too aggressively when price is sitting very close to VWAP.")

// =====================================================
// 08. STRUCTURE SETTINGS
// =====================================================
int swingLen = input.int(5, "Structure Pivot Length", minval = 1, group = G_STRUCT)

// =====================================================
// 09. SESSION BIAS SETTINGS
// =====================================================
string tz = input.string("America/New_York", "Timezone", group = G_SESS)

string asiaSession   = input.session("1800-0200", "Asia Session", group = G_SESS)
string londonSession = input.session("0300-1200", "London Session", group = G_SESS)
string nySession     = input.session("0800-1700", "New York Session", group = G_SESS)

string sessionSweepSource = input.string("Asia", "Sweep Bias Source", options = ["Asia", "Current Active Session"], group = G_SESS, tooltip = "Asia keeps the old behavior. Current Active Session makes the session logic more general.")
bool resetSessionBiasAtNewAsia = input.bool(true, "Reset Session Sweep Bias at New Asia", group = G_SESS)

// =====================================================
// 10. MULTI-TIMEFRAME BIAS
// =====================================================
bool showMtfBias = input.bool(true, "Show Multi-Timeframe Bias Table", group = G_MTF)
int mtfMinAgree  = input.int(5, "Minimum TF Agreement for Strong Bias", minval = 1, maxval = 8, group = G_MTF)

string tf1 = input.timeframe("5", "TF 1", group = G_MTF)
string tf2 = input.timeframe("15", "TF 2", group = G_MTF)
string tf3 = input.timeframe("30", "TF 3", group = G_MTF)
string tf4 = input.timeframe("60", "TF 4", group = G_MTF)
string tf5 = input.timeframe("240", "TF 5", group = G_MTF)
string tf6 = input.timeframe("D", "TF 6", group = G_MTF)
string tf7 = input.timeframe("W", "TF 7", group = G_MTF)
string tf8 = input.timeframe("M", "TF 8", group = G_MTF)

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

f_ma(float src, int len) =>
    maType == "SMA" ? ta.sma(src, len) :
     maType == "VWMA" ? ta.vwma(src, len) :
     ta.ema(src, len)

f_biasTxt(int b) =>
    b == 1 ? "BULL" : b == -1 ? "BEAR" : "MIXED"

f_biasCol(int b) =>
    b == 1 ? bullColor : b == -1 ? bearColor : neutralColor

f_stars(float strengthPct) =>
    strengthPct >= 85 ? "★★★★★" :
     strengthPct >= 70 ? "★★★★☆" :
     strengthPct >= 55 ? "★★★☆☆" :
     strengthPct >= 35 ? "★★☆☆☆" :
     strengthPct > 0 ? "★☆☆☆☆" :
     "☆☆☆☆☆"

f_strengthTxt(float strengthPct) =>
    strengthPct >= 85 ? "Very Strong" :
     strengthPct >= 70 ? "Strong" :
     strengthPct >= 55 ? "Moderate" :
     strengthPct >= 35 ? "Weak" :
     "Neutral"

f_dirScoreTxt(int score, int enabledCount) =>
    str.tostring(score) + " / " + str.tostring(enabledCount)

f_tfLabel(string tf) =>
    tf == "60" ? "1H" :
     tf == "240" ? "4H" :
     tf == "D" ? "Daily" :
     tf == "W" ? "Weekly" :
     tf == "M" ? "Monthly" :
     tf + "m"

f_presetDisplay(string mode, string marketType) =>
    mode == "Auto" ? "Auto: " + marketType : "Manual: " + marketType

// =====================================================
// AUTO SYMBOL PRESET ENGINE
// =====================================================
string symbolRoot = str.upper(syminfo.root)
string symbolTicker = str.upper(syminfo.ticker)
string symbolType = syminfo.type

bool isIndexFuture = symbolRoot == "NQ" or symbolRoot == "MNQ" or symbolRoot == "ES" or symbolRoot == "MES" or symbolRoot == "YM" or symbolRoot == "MYM" or symbolRoot == "RTY" or symbolRoot == "M2K"
bool isGoldFuture = symbolRoot == "GC" or symbolRoot == "MGC"
bool isOilFuture = symbolRoot == "CL" or symbolRoot == "MCL"
bool isCryptoSymbol = symbolType == "crypto" or str.contains(symbolTicker, "BTC") or str.contains(symbolTicker, "ETH")

string detectedMarketType = isIndexFuture ? "Index Futures" :
     isGoldFuture ? "Gold Futures" :
     isOilFuture ? "Oil Futures" :
     isCryptoSymbol ? "Crypto" :
     symbolType == "stock" ? "Stocks" :
     symbolType == "forex" ? "Forex" :
     symbolType == "futures" ? "Other Futures" :
     "General"

string activeMarketType = manualMarketType == "Auto" ? detectedMarketType : manualMarketType
string presetModeTxt = useAutoSymbolPresets and manualMarketType == "Auto" ? "Auto" : "Manual"
string presetTxt = f_presetDisplay(presetModeTxt, activeMarketType)

float sensitivityFactor = presetSensitivity == "Conservative" ? 1.10 : presetSensitivity == "Responsive" ? 0.90 : 1.00
float rsiOffset = presetSensitivity == "Conservative" ? 1.0 : presetSensitivity == "Responsive" ? -0.5 : 0.0

float presetMinAdxBase = activeMarketType == "Gold Futures" ? 18.0 :
     activeMarketType == "Crypto" ? 22.0 :
     activeMarketType == "Forex" ? 18.0 :
     activeMarketType == "Stocks" ? 20.0 :
     20.0

float presetAtrStrongBase = activeMarketType == "Gold Futures" ? 1.15 :
     activeMarketType == "Oil Futures" ? 1.15 :
     activeMarketType == "Crypto" ? 1.20 :
     activeMarketType == "Forex" ? 1.05 :
     1.10

float presetAtrWeakBase = activeMarketType == "Crypto" ? 0.80 :
     activeMarketType == "Forex" ? 0.90 :
     0.85

float presetVwapBandBase = activeMarketType == "Gold Futures" ? 0.12 :
     activeMarketType == "Oil Futures" ? 0.13 :
     activeMarketType == "Crypto" ? 0.15 :
     activeMarketType == "Stocks" ? 0.08 :
     activeMarketType == "Forex" ? 0.07 :
     0.10

float presetRsiBullBase = activeMarketType == "Gold Futures" ? 53.0 :
     activeMarketType == "Crypto" ? 54.0 :
     activeMarketType == "Forex" ? 51.0 :
     52.0

float presetRsiBearBase = activeMarketType == "Gold Futures" ? 47.0 :
     activeMarketType == "Crypto" ? 46.0 :
     activeMarketType == "Forex" ? 49.0 :
     48.0

float effMinAdx = useAutoSymbolPresets and applyAutoAdxAtr ? presetMinAdxBase * sensitivityFactor : minAdx
float effAtrStrongRatio = useAutoSymbolPresets and applyAutoAdxAtr ? presetAtrStrongBase * sensitivityFactor : atrStrongRatio
float effAtrWeakRatio = useAutoSymbolPresets and applyAutoAdxAtr ? math.min(presetAtrWeakBase / sensitivityFactor, 0.98) : atrWeakRatio
float effVwapNeutralAtrPct = useAutoSymbolPresets and applyAutoVwapBand ? presetVwapBandBase * sensitivityFactor : vwapNeutralAtrPct
float effRsiBullLvl = useAutoSymbolPresets and applyAutoMomentum ? presetRsiBullBase + rsiOffset : rsiBullLvl
float effRsiBearLvl = useAutoSymbolPresets and applyAutoMomentum ? presetRsiBearBase - rsiOffset : rsiBearLvl

// =====================================================
// MTF BIAS FUNCTION
// =====================================================
f_calcTfBias() =>
    float _maFast = f_ma(close, fastMaLen)
    float _maMid  = f_ma(close, midMaLen)
    float _maSlow = f_ma(close, slowMaLen)

    float _rsi = ta.rsi(close, rsiLen)

    float _stochBase = ta.rsi(close, stochRsiLen)
    float _k = ta.sma(ta.stoch(_stochBase, _stochBase, _stochBase, stochLen), kSmooth)
    float _d = ta.sma(_k, dSmooth)

    bool _trendBull = _maFast > _maMid and _maMid > _maSlow
    bool _trendBear = _maFast < _maMid and _maMid < _maSlow

    bool _rsiBull = _rsi >= effRsiBullLvl
    bool _rsiBear = _rsi <= effRsiBearLvl

    bool _stochBull = _k > _d and _k > stochMid
    bool _stochBear = _k < _d and _k < stochMid

    int _bullScore = 0
    int _bearScore = 0

    if _trendBull
        _bullScore += 1
    if _trendBear
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
// TREND
// =====================================================
float maFast = f_ma(close, fastMaLen)
float maMid  = f_ma(close, midMaLen)
float maSlow = f_ma(close, slowMaLen)

bool trendBull = maFast > maMid and maMid > maSlow
bool trendBear = maFast < maMid and maMid < maSlow

int trendDir = trendBull ? 1 : trendBear ? -1 : 0
string trendTxt = trendBull ? "Bull Stack" : trendBear ? "Bear Stack" : "Mixed"
color trendCol = trendBull ? bullColor : trendBear ? bearColor : neutralColor

// =====================================================
// VWAP
// =====================================================
float vwapVal = ta.vwap(hlc3)
float atrVal = ta.atr(atrLen)
float vwapBand = atrVal * effVwapNeutralAtrPct

bool aboveVwap = close > vwapVal + vwapBand
bool belowVwap = close < vwapVal - vwapBand

int vwapDir = aboveVwap ? 1 : belowVwap ? -1 : 0
string vwapTxt = aboveVwap ? "Above VWAP" : belowVwap ? "Below VWAP" : "Near VWAP"
color vwapCol = aboveVwap ? bullColor : belowVwap ? bearColor : neutralColor

// =====================================================
// ADX / ATR / MARKET STATE
// =====================================================
[diplus, diminus, adxVal] = ta.dmi(adxLen, adxLen)

bool adxStrong = adxVal >= effMinAdx
bool adxBull = adxStrong and diplus > diminus
bool adxBear = adxStrong and diminus > diplus

string adxTxt = str.tostring(adxVal, "#.0") + (adxStrong ? " Trend" : " Weak")
color adxCol = adxStrong ? bullColor : weakColor

float atrAvg = ta.sma(atrVal, atrAvgLen)
float atrRatio = atrAvg != 0 ? atrVal / atrAvg : na

bool atrExpanding = atrRatio >= effAtrStrongRatio
bool atrWeak = atrRatio <= effAtrWeakRatio

string atrTxt = str.tostring(atrVal, "#.##") + " "
if atrExpanding
    atrTxt += "Expanding"
else if atrWeak
    atrTxt += "Weak"
else
    atrTxt += "Normal"

color atrCol = atrExpanding ? bullColor : atrWeak ? weakColor : neutralColor

string marketState = "Transition"
color marketStateCol = neutralColor

if adxStrong and atrExpanding
    marketState := "Expansion"
    marketStateCol := bullColor
else if adxStrong and not atrWeak
    marketState := "Trending"
    marketStateCol := bullColor
else if not adxStrong and atrWeak
    marketState := "Range / Chop"
    marketStateCol := neutralColor
else if not adxStrong
    marketState := "Range"
    marketStateCol := neutralColor
else
    marketState := "Transition"
    marketStateCol := neutralColor

// =====================================================
// MOMENTUM
// =====================================================
float rsiVal = ta.rsi(close, rsiLen)

bool rsiBull = rsiVal >= effRsiBullLvl
bool rsiBear = rsiVal <= effRsiBearLvl

float stochRsiBase = ta.rsi(close, stochRsiLen)
float stochK = ta.sma(ta.stoch(stochRsiBase, stochRsiBase, stochRsiBase, stochLen), kSmooth)
float stochD = ta.sma(stochK, dSmooth)

bool stochBull = stochK > stochD and stochK > stochMid
bool stochBear = stochK < stochD and stochK < stochMid
bool stochRising = stochK > stochK[1]
bool stochFalling = stochK < stochK[1]

int momentumBullScore = 0
int momentumBearScore = 0

if rsiBull
    momentumBullScore += 1
if rsiBear
    momentumBearScore += 1

if stochBull
    momentumBullScore += 1
if stochBear
    momentumBearScore += 1

int momentumDir = momentumBullScore > momentumBearScore ? 1 : momentumBearScore > momentumBullScore ? -1 : 0

string momentumTxt = momentumDir == 1 and stochRising ? "Bull Rising" :
     momentumDir == 1 ? "Bullish" :
     momentumDir == -1 and stochFalling ? "Bear Falling" :
     momentumDir == -1 ? "Bearish" :
     "Neutral"

color momentumCol = momentumDir == 1 ? bullColor : momentumDir == -1 ? bearColor : neutralColor

string rsiTxt = str.tostring(rsiVal, "#.0")
color rsiCol = rsiBull ? bullColor : rsiBear ? bearColor : neutralColor

string stochTxt = str.tostring(stochK, "#.0") + "/" + str.tostring(stochD, "#.0")
color stochCol = stochBull ? bullColor : stochBear ? bearColor : neutralColor

float volAvg = ta.sma(volume, volLen)
bool volAbove = volume > volAvg

string volTxt = volAbove ? "Above Avg" : "Below Avg"
color volCol = volAbove ? bullColor : weakColor

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
// OPTIONAL SESSION SWEEP BIAS
// =====================================================
var float asiaHigh = na
var float asiaLow  = na
var float activeSessHigh = na
var float activeSessLow  = na
var int sessionDir = 0 // 0 = Neutral, 1 = Longs, -1 = Shorts

if inAsia and not inAsia[1]
    asiaHigh := high
    asiaLow  := low
    if resetSessionBiasAtNewAsia
        sessionDir := 0

if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow  := math.min(nz(asiaLow, low), low)

if activeSession and not activeSession[1]
    activeSessHigh := high
    activeSessLow := low

if activeSession
    activeSessHigh := math.max(nz(activeSessHigh, high), high)
    activeSessLow := math.min(nz(activeSessLow, low), low)

float sweepHighRef = sessionSweepSource == "Asia" ? asiaHigh : activeSessHigh
float sweepLowRef  = sessionSweepSource == "Asia" ? asiaLow : activeSessLow

if sessionSweepSource == "Asia"
    if not inAsia and not na(sweepHighRef) and not na(sweepLowRef)
        if high > sweepHighRef
            sessionDir := -1
        if low < sweepLowRef
            sessionDir := 1
else
    if activeSession and not na(sweepHighRef) and not na(sweepLowRef)
        if high > sweepHighRef[1]
            sessionDir := -1
        if low < sweepLowRef[1]
            sessionDir := 1

string sweepTxt = sessionDir == 1 ? "Sweep Low = Longs" :
     sessionDir == -1 ? "Sweep High = Shorts" :
     "No Sweep Bias"

color sweepCol = sessionDir == 1 ? bullColor : sessionDir == -1 ? bearColor : neutralColor

// =====================================================
// STRUCTURE
// =====================================================
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var float lastPh = na
var float lastPl = na

if not na(ph)
    lastPh := ph

if not na(pl)
    lastPl := pl

var int structureDir = 0

bool bullBreak = not na(lastPh) and close > lastPh
bool bearBreak = not na(lastPl) and close < lastPl

if bullBreak
    structureDir := 1
else if bearBreak
    structureDir := -1

string structureTxt = structureDir == 1 ? "Bull Break" :
     structureDir == -1 ? "Bear Break" :
     "Neutral"

color structureCol = structureDir == 1 ? bullColor : structureDir == -1 ? bearColor : neutralColor

// =====================================================
// MULTI-TIMEFRAME BIAS
// =====================================================
int bias1 = request.security(syminfo.tickerid, tf1, f_calcTfBias())
int bias2 = request.security(syminfo.tickerid, tf2, f_calcTfBias())
int bias3 = request.security(syminfo.tickerid, tf3, f_calcTfBias())
int bias4 = request.security(syminfo.tickerid, tf4, f_calcTfBias())
int bias5 = request.security(syminfo.tickerid, tf5, f_calcTfBias())
int bias6 = request.security(syminfo.tickerid, tf6, f_calcTfBias())
int bias7 = request.security(syminfo.tickerid, tf7, f_calcTfBias())
int bias8 = request.security(syminfo.tickerid, tf8, f_calcTfBias())

int mtfBullCount = 0
int mtfBearCount = 0

if bias1 == 1
    mtfBullCount += 1
if bias2 == 1
    mtfBullCount += 1
if bias3 == 1
    mtfBullCount += 1
if bias4 == 1
    mtfBullCount += 1
if bias5 == 1
    mtfBullCount += 1
if bias6 == 1
    mtfBullCount += 1
if bias7 == 1
    mtfBullCount += 1
if bias8 == 1
    mtfBullCount += 1

if bias1 == -1
    mtfBearCount += 1
if bias2 == -1
    mtfBearCount += 1
if bias3 == -1
    mtfBearCount += 1
if bias4 == -1
    mtfBearCount += 1
if bias5 == -1
    mtfBearCount += 1
if bias6 == -1
    mtfBearCount += 1
if bias7 == -1
    mtfBearCount += 1
if bias8 == -1
    mtfBearCount += 1

int mtfDir = 0

if mtfBullCount >= mtfMinAgree and mtfBullCount > mtfBearCount
    mtfDir := 1
else if mtfBearCount >= mtfMinAgree and mtfBearCount > mtfBullCount
    mtfDir := -1
else
    mtfDir := 0

string mtfTxt = mtfDir == 1 ? "BULL " + str.tostring(mtfBullCount) + "/8" :
     mtfDir == -1 ? "BEAR " + str.tostring(mtfBearCount) + "/8" :
     "MIXED " + str.tostring(mtfBullCount) + "B/" + str.tostring(mtfBearCount) + "S"

color mtfCol = mtfDir == 1 ? bullColor : mtfDir == -1 ? bearColor : neutralColor

// =====================================================
// OVERALL BIAS ENGINE
// =====================================================
int enabledCount = 0
int directionalScore = 0
int bullScore = 0
int bearScore = 0

if useTrendBias
    enabledCount += 1
    directionalScore += trendDir
    if trendDir == 1
        bullScore += 1
    if trendDir == -1
        bearScore += 1

if useVwapBias
    enabledCount += 1
    directionalScore += vwapDir
    if vwapDir == 1
        bullScore += 1
    if vwapDir == -1
        bearScore += 1

if useMomentumBias
    enabledCount += 1
    directionalScore += momentumDir
    if momentumDir == 1
        bullScore += 1
    if momentumDir == -1
        bearScore += 1

if useStructureBias
    enabledCount += 1
    directionalScore += structureDir
    if structureDir == 1
        bullScore += 1
    if structureDir == -1
        bearScore += 1

if useMtfBias
    enabledCount += 1
    directionalScore += mtfDir
    if mtfDir == 1
        bullScore += 1
    if mtfDir == -1
        bearScore += 1

if useSessionBias
    enabledCount += 1
    directionalScore += sessionDir
    if sessionDir == 1
        bullScore += 1
    if sessionDir == -1
        bearScore += 1

int hybridDir = 0

if enabledCount > 0
    if directionalScore >= minDirectionalScore
        hybridDir := 1
    else if directionalScore <= -minDirectionalScore
        hybridDir := -1
    else
        hybridDir := 0

int selectedDir = 0

if biasMode == "Hybrid Score"
    selectedDir := hybridDir
else if biasMode == "Trend Only"
    selectedDir := trendDir
else if biasMode == "VWAP Only"
    selectedDir := vwapDir
else if biasMode == "Momentum Only"
    selectedDir := momentumDir
else if biasMode == "Structure Only"
    selectedDir := structureDir
else if biasMode == "MTF Only"
    selectedDir := mtfDir
else if biasMode == "Session Sweep Only"
    selectedDir := sessionDir
else if biasMode == "Manual"
    selectedDir := manualBias == "Longs Only" ? 1 : manualBias == "Shorts Only" ? -1 : 0

float strengthPct = enabledCount > 0 ? math.abs(directionalScore) / enabledCount * 100.0 : 0.0

string mainBiasTxt = "NEUTRAL"
color mainBiasCol = neutralColor

if biasMode == "Manual" and manualBias == "All"
    mainBiasTxt := "ALL"
    mainBiasCol := weakColor
else if selectedDir == 1 and strengthPct >= neutralStrengthPct
    mainBiasTxt := "BULLISH"
    mainBiasCol := bullColor
else if selectedDir == -1 and strengthPct >= neutralStrengthPct
    mainBiasTxt := "BEARISH"
    mainBiasCol := bearColor
else
    mainBiasTxt := "NEUTRAL"
    mainBiasCol := neutralColor

string strengthTxt = f_strengthTxt(strengthPct) + " " + str.tostring(strengthPct, "#") + "%"
color strengthCol = strengthPct >= 70 ? bullColor : strengthPct >= 35 ? neutralColor : weakColor

string scoreTxt = f_stars(strengthPct)

string contextTxt = "Wait for cleaner bias"
color contextCol = neutralColor

if marketState == "Range / Chop" or marketState == "Range"
    contextTxt := selectedDir == 1 ? "Bull bias, avoid chasing" :
         selectedDir == -1 ? "Bear bias, avoid chasing" :
         "Range: wait or fade extremes"
    contextCol := neutralColor
else if selectedDir == 1
    contextTxt := "Favor pullback longs"
    contextCol := bullColor
else if selectedDir == -1
    contextTxt := "Favor pullback shorts"
    contextCol := bearColor
else
    contextTxt := "Mixed: wait for confirmation"
    contextCol := neutralColor

string reasonTxt = ""
if selectedDir == 1
    reasonTxt := "Bull: "
else if selectedDir == -1
    reasonTxt := "Bear: "
else
    reasonTxt := "Mixed: "

reasonTxt += str.tostring(bullScore) + " bull / " + str.tostring(bearScore) + " bear"

// =====================================================
// DASHBOARD TABLES
// =====================================================
var table dash = table.new(
     f_pos(dashPosInput),
     2,
     16,
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
    table.clear(dash, 0, 0, 1, 15)
    table.clear(mtfDash, 0, 0, 1, 8)

    bool isCompact = dashLayoutInput == "Compact"
    bool isModerate = dashLayoutInput == "Moderate"
    bool isFull = dashLayoutInput == "Full"

    if showMainDash
        int r = 0

        table.cell(dash, 0, r, "Bias Status", text_color = color.white, bgcolor = headerBg, text_size = textSize)
        table.cell(dash, 1, r, dashLayoutInput, text_color = color.white, bgcolor = headerBg, text_size = textSize)
        r += 1

        if showTickerRow
            table.cell(dash, 0, r, "Ticker", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, syminfo.ticker, text_color = color.white, bgcolor = tableBg, text_size = textSize)
            r += 1

        if showPresetRow
            table.cell(dash, 0, r, "Preset", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, presetTxt, text_color = neutralColor, bgcolor = tableBg, text_size = textSize)
            r += 1

        table.cell(dash, 0, r, "Main Bias", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(dash, 1, r, mainBiasTxt, text_color = mainBiasCol, bgcolor = tableBg, text_size = textSize)
        r += 1

        table.cell(dash, 0, r, "Strength", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(dash, 1, r, strengthTxt, text_color = strengthCol, bgcolor = tableBg, text_size = textSize)
        r += 1

        table.cell(dash, 0, r, "Market State", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(dash, 1, r, marketState, text_color = marketStateCol, bgcolor = tableBg, text_size = textSize)
        r += 1

        table.cell(dash, 0, r, "Context", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(dash, 1, r, contextTxt, text_color = contextCol, bgcolor = tableBg, text_size = textSize)
        r += 1

        if isModerate or isFull
            table.cell(dash, 0, r, "Trend", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, trendTxt, text_color = trendCol, bgcolor = tableBg, text_size = textSize)
            r += 1

            table.cell(dash, 0, r, "VWAP", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, vwapTxt, text_color = vwapCol, bgcolor = tableBg, text_size = textSize)
            r += 1

            table.cell(dash, 0, r, "Momentum", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, momentumTxt, text_color = momentumCol, bgcolor = tableBg, text_size = textSize)
            r += 1

            table.cell(dash, 0, r, "MTF", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, mtfTxt, text_color = mtfCol, bgcolor = tableBg, text_size = textSize)
            r += 1

        if isFull
            table.cell(dash, 0, r, "Structure", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, structureTxt, text_color = structureCol, bgcolor = tableBg, text_size = textSize)
            r += 1

            table.cell(dash, 0, r, "Session", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, sessionTxt, text_color = sessionCol, bgcolor = tableBg, text_size = textSize)
            r += 1

            table.cell(dash, 0, r, "Sweep Bias", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, sweepTxt, text_color = sweepCol, bgcolor = tableBg, text_size = textSize)
            r += 1

            table.cell(dash, 0, r, "Score", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, scoreTxt + "  " + f_dirScoreTxt(directionalScore, enabledCount), text_color = starColor, bgcolor = tableBg, text_size = textSize)
            r += 1

        if isFull and showReasonRow and r <= 15
            table.cell(dash, 0, r, "Reason", text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
            table.cell(dash, 1, r, reasonTxt, text_color = color.white, bgcolor = tableBg, text_size = textSize)

    if showMtfBias
        table.cell(mtfDash, 0, 0, "MTF Bias", text_color = color.white, bgcolor = sectionBg, text_size = textSize)
        table.cell(mtfDash, 1, 0, mtfTxt, text_color = mtfCol, bgcolor = sectionBg, text_size = textSize)

        table.cell(mtfDash, 0, 1, f_tfLabel(tf1), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 1, f_biasTxt(bias1), text_color = f_biasCol(bias1), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 2, f_tfLabel(tf2), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 2, f_biasTxt(bias2), text_color = f_biasCol(bias2), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 3, f_tfLabel(tf3), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 3, f_biasTxt(bias3), text_color = f_biasCol(bias3), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 4, f_tfLabel(tf4), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 4, f_biasTxt(bias4), text_color = f_biasCol(bias4), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 5, f_tfLabel(tf5), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 5, f_biasTxt(bias5), text_color = f_biasCol(bias5), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 6, f_tfLabel(tf6), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 6, f_biasTxt(bias6), text_color = f_biasCol(bias6), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 7, f_tfLabel(tf7), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 7, f_biasTxt(bias7), text_color = f_biasCol(bias7), bgcolor = tableBg, text_size = textSize)

        table.cell(mtfDash, 0, 8, f_tfLabel(tf8), text_color = labelTextCol, bgcolor = tableBg, text_size = textSize)
        table.cell(mtfDash, 1, 8, f_biasTxt(bias8), text_color = f_biasCol(bias8), bgcolor = tableBg, text_size = textSize)
````
