# Composite POCs - Daily, Weekly, Monthly

- url: https://www.tradingview.com/script/azxfeV1F/
- type: indicator
- pine_id: PUB;d126a9f242fd48698ee2aff26dbc4d5e
- version: 1.0

## Description

This indicator displays Daily, Weekly and Monthly Points of Control (POCs) based on either the current chart symbol or a composite volume profile built from up to 9 selectable crypto exchange symbols.

In composite mode, volume from the enabled exchanges is combined into shared price bins to calculate a broader market POC. By default, exchanges are equally weighted so no single venue dominates the result.

Features include developing POCs, historical POCs, untouched/naked POCs, optional price-scale labels and customizable exchange sources via TradingView’s symbol search.

Note: POCs are approximations based on TradingView volume data, selected profile settings and available lower-timeframe data. Results may differ from exchange-native or professional volume-profile platforms.

## Source Code

````pine
//@version=6
indicator(
    "Composite POCs - Daily, Weekly, Monthly v1.0",
    shorttitle="Points of Control",
    overlay=true,
    max_bars_back=5000,
    max_lines_count=500,
    dynamic_requests=true
)

//=============================================================================
// 1. CHART DISPLAY
//=============================================================================

string grpDisplay = "1. Chart Display"

bool showDailyPOCs = input.bool(true, "Show Daily POCs", inline="pocD", group=grpDisplay, tooltip="Shows finalized Daily POCs on the chart. The dotted segment marks the period that created the POC; the solid segment starts when the POC becomes active.", display=display.none)
color dailyPOCColor = input.color(color.red, "", inline="pocD", group=grpDisplay, tooltip="Color used for Daily POC lines and Daily POC price-scale markers.", display=display.none)

bool showWeeklyPOCs = input.bool(true, "Show Weekly POCs", inline="pocW", group=grpDisplay, tooltip="Shows finalized Weekly POCs on the chart.", display=display.none)
color weeklyPOCColor = input.color(color.yellow, "", inline="pocW", group=grpDisplay, tooltip="Color used for Weekly POC lines and Weekly POC price-scale markers.", display=display.none)

bool showMonthlyPOCs = input.bool(true, "Show Monthly POCs", inline="pocM", group=grpDisplay, tooltip="Shows finalized Monthly POCs on the chart.", display=display.none)
color monthlyPOCColor = input.color(color.purple, "", inline="pocM", group=grpDisplay, tooltip="Color used for Monthly POC lines and Monthly POC price-scale markers.", display=display.none)

int pocLineWidth = input.int(1, "POC line width", minval=1, maxval=4, group=grpDisplay, tooltip="Controls the width of finalized and developing POC lines.", display=display.none)

int dailyPOCHistory = input.int(100, "Daily POC history", minval=5, maxval=200, group=grpDisplay, tooltip="Maximum number of historical Daily POC levels retained for display.", display=display.none)
int weeklyPOCHistory = input.int(50, "Weekly POC history", minval=5, maxval=150, group=grpDisplay, tooltip="Maximum number of historical Weekly POC levels retained for display.", display=display.none)
int monthlyPOCHistory = input.int(20, "Monthly POC history", minval=5, maxval=100, group=grpDisplay, tooltip="Maximum number of historical Monthly POC levels retained for display.", display=display.none)

bool showDevelopingPOCs = input.bool(
    true,
    "Show developing POCs",
    group=grpDisplay,
    tooltip="Shows the unfinished Daily, Weekly and Monthly POC as a dotted line from the beginning of the current period to the current bar.",
    display=display.none
)

bool showNearestPOCPrices = input.bool(
    true,
    "Show nearest POCs on price scale",
    group=grpDisplay,
    tooltip="Shows the five nearest untouched POCs above and below the current price on the main price scale.",
    display=display.none
)

bool showOnlyUntouchedPOCs = input.bool(
    false,
    "Show only untouched POCs",
    group=grpDisplay,
    tooltip="When enabled, POCs disappear completely after their first valid touch. When disabled, touched historical POCs remain visible and the solid active segment ends at the first touch.",
    display=display.none
)

//=============================================================================
// 2. POC DATA SOURCE / COMPOSITE EXCHANGES
//=============================================================================

string grpSource = "2. POC Data Source / Composite Exchanges"

string pocDataSource = input.string(
    "Composite exchanges",
    "POC data source",
    options=["Current chart only", "Composite exchanges"],
    group=grpSource,
    tooltip="Current chart only uses the chart symbol. Composite exchanges builds one shared volume profile from all enabled exchange symbols.",
    display=display.none
)

string compositeWeighting = input.string(
    "Equal exchange weighting",
    "Composite weighting",
    options=["Reported volume", "Equal exchange weighting"],
    group=grpSource,
    tooltip="Reported volume adds the reported volume of all enabled sources. Equal exchange weighting normalizes each source so every enabled exchange contributes the same total weight to each completed D/W/M profile.",
    display=display.none
)

bool includeCurrentChartInComposite = input.bool(
    false,
    "Include current chart symbol",
    group=grpSource,
    tooltip="Adds the current chart symbol as an additional source. Leave this off if the same symbol is already selected in one of the nine source slots.",
    display=display.none
)

bool useSource1 = input.bool(true, "1", inline="src1", group=grpSource, tooltip="Enable or disable composite source 1.", display=display.none)
string source1 = input.symbol("BINANCE:BTCUSDT", "", inline="src1", group=grpSource, tooltip="TradingView symbol used for composite source 1. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource2 = input.bool(true, "2", inline="src2", group=grpSource, tooltip="Enable or disable composite source 2.", display=display.none)
string source2 = input.symbol("COINBASE:BTCUSD", "", inline="src2", group=grpSource, tooltip="TradingView symbol used for composite source 2. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource3 = input.bool(true, "3", inline="src3", group=grpSource, tooltip="Enable or disable composite source 3.", display=display.none)
string source3 = input.symbol("BINANCEUS:BTCUSD", "", inline="src3", group=grpSource, tooltip="TradingView symbol used for composite source 3. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource4 = input.bool(true, "4", inline="src4", group=grpSource, tooltip="Enable or disable composite source 4.", display=display.none)
string source4 = input.symbol("BYBIT:BTCUSDT", "", inline="src4", group=grpSource, tooltip="TradingView symbol used for composite source 4. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource5 = input.bool(true, "5", inline="src5", group=grpSource, tooltip="Enable or disable composite source 5.", display=display.none)
string source5 = input.symbol("OKX:BTCUSDT", "", inline="src5", group=grpSource, tooltip="TradingView symbol used for composite source 5. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource6 = input.bool(true, "6", inline="src6", group=grpSource, tooltip="Enable or disable composite source 6.", display=display.none)
string source6 = input.symbol("KRAKEN:BTCUSD", "", inline="src6", group=grpSource, tooltip="TradingView symbol used for composite source 6. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource7 = input.bool(true, "7", inline="src7", group=grpSource, tooltip="Enable or disable composite source 7.", display=display.none)
string source7 = input.symbol("BITSTAMP:BTCUSD", "", inline="src7", group=grpSource, tooltip="TradingView symbol used for composite source 7. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource8 = input.bool(true, "8", inline="src8", group=grpSource, tooltip="Enable or disable composite source 8.", display=display.none)
string source8 = input.symbol("BITFINEX:BTCUSD", "", inline="src8", group=grpSource, tooltip="TradingView symbol used for composite source 8. Click the field to search all symbols available on TradingView.", display=display.none)

bool useSource9 = input.bool(true, "9", inline="src9", group=grpSource, tooltip="Enable or disable composite source 9.", display=display.none)
string source9 = input.symbol("GEMINI:BTCUSD", "", inline="src9", group=grpSource, tooltip="TradingView symbol used for composite source 9. Click the field to search all symbols available on TradingView.", display=display.none)

//=============================================================================
// 3. INTERNAL CALCULATION OF VOLUME PROFILES
//=============================================================================

string grpCalc = "3. Internal Calculation of Volume Profiles"

string qualityMode = input.string(
    "Balanced - Range distribution",
    "Quality level",
    options=[
        "Fast - HLC3 bucket",
        "Balanced - Range distribution",
        "High - Lower timeframe"
    ],
    group=grpCalc,
    tooltip="Fast assigns each bar's complete volume to its HLC3 price bucket. Balanced distributes each bar's volume across the full Low-to-High range and is the recommended default. High uses lower-timeframe intrabars for more detailed profiles at higher computational cost.",
    display=display.none
)

int profileRows = input.int(100, "Profile rows", options=[50, 100, 150, 200], group=grpCalc, tooltip="Number of price rows used to build each volume profile. More rows increase price resolution but also calculation load.", display=display.none)
string lowerTf = input.timeframe("15", "Lower timeframe - High quality", group=grpCalc, tooltip="Lower timeframe used by High - Lower timeframe mode. Smaller values increase intrabar detail but require more data and computation.", display=display.none)
int maxSamplesPerPeriod = input.int(30000, "Maximum samples per period", minval=1000, maxval=100000, step=1000, group=grpCalc, tooltip="Composite profiles can contain many more samples than a single exchange. At 15-minute resolution, 30,000 samples are enough for roughly one month across nine continuously traded crypto sources.", display=display.none)
int lowerTfCalcBars = input.int(3000, "Lower-TF chart bars requested", minval=100, maxval=10000, step=100, group=grpCalc, tooltip="Number of chart bars for which TradingView should request lower-timeframe data. Higher values increase historical coverage and resource usage.", display=display.none)
bool roundToTick = input.bool(true, "Round calculated POC to minimum tick", group=grpCalc, tooltip="Rounds each calculated POC to the current chart symbol's minimum tick size.", display=display.none)

//=============================================================================
// CONSTANTS / STATE
//=============================================================================

int KIND_D = 1
int KIND_W = 2
int KIND_M = 3

bool modeFast = qualityMode == "Fast - HLC3 bucket"
bool modeHigh = qualityMode == "High - Lower timeframe"
bool compositeMode = pocDataSource == "Composite exchanges"
bool equalWeighting = compositeMode and compositeWeighting == "Equal exchange weighting"

var array<float> lvlPrice = array.new_float()
var array<int> lvlKind = array.new_int()
var array<bool> lvlTouched = array.new_bool()
var array<int> lvlPeriodEnd = array.new_int()
var array<line> lvlRetroLine = array.new_line()
var array<line> lvlActiveLine = array.new_line()

var line developingDailyPOCLine = na
var line developingWeeklyPOCLine = na
var line developingMonthlyPOCLine = na

// Profile samples. Source IDs: 0=current chart, 1..9=composite slots.
var array<float> dHigh = array.new_float()
var array<float> dLow = array.new_float()
var array<float> dVol = array.new_float()
var array<float> dPrice = array.new_float()
var array<int> dSource = array.new_int()

var array<float> wHigh = array.new_float()
var array<float> wLow = array.new_float()
var array<float> wVol = array.new_float()
var array<float> wPrice = array.new_float()
var array<int> wSource = array.new_int()

var array<float> mHigh = array.new_float()
var array<float> mLow = array.new_float()
var array<float> mVol = array.new_float()
var array<float> mPrice = array.new_float()
var array<int> mSource = array.new_int()

// Current-chart lower-timeframe data.
[chartLtfHigh, chartLtfLow, chartLtfVol, chartLtfPrice] = request.security_lower_tf(
    syminfo.tickerid,
    lowerTf,
    [high, low, volume, hlc3],
    ignore_invalid_timeframe=true,
    calc_bars_count=lowerTfCalcBars
)

// Composite sources on the chart timeframe. These are used in Fast/Balanced mode.
[s1High, s1Low, s1Vol, s1Price] = request.security(source1, timeframe.period, [high, low, volume, hlc3])
[s2High, s2Low, s2Vol, s2Price] = request.security(source2, timeframe.period, [high, low, volume, hlc3])
[s3High, s3Low, s3Vol, s3Price] = request.security(source3, timeframe.period, [high, low, volume, hlc3])
[s4High, s4Low, s4Vol, s4Price] = request.security(source4, timeframe.period, [high, low, volume, hlc3])
[s5High, s5Low, s5Vol, s5Price] = request.security(source5, timeframe.period, [high, low, volume, hlc3])
[s6High, s6Low, s6Vol, s6Price] = request.security(source6, timeframe.period, [high, low, volume, hlc3])
[s7High, s7Low, s7Vol, s7Price] = request.security(source7, timeframe.period, [high, low, volume, hlc3])
[s8High, s8Low, s8Vol, s8Price] = request.security(source8, timeframe.period, [high, low, volume, hlc3])
[s9High, s9Low, s9Vol, s9Price] = request.security(source9, timeframe.period, [high, low, volume, hlc3])

// Composite source intrabars. These are used in High quality mode.
[s1LtfHigh, s1LtfLow, s1LtfVol, s1LtfPrice] = request.security_lower_tf(source1, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s2LtfHigh, s2LtfLow, s2LtfVol, s2LtfPrice] = request.security_lower_tf(source2, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s3LtfHigh, s3LtfLow, s3LtfVol, s3LtfPrice] = request.security_lower_tf(source3, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s4LtfHigh, s4LtfLow, s4LtfVol, s4LtfPrice] = request.security_lower_tf(source4, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s5LtfHigh, s5LtfLow, s5LtfVol, s5LtfPrice] = request.security_lower_tf(source5, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s6LtfHigh, s6LtfLow, s6LtfVol, s6LtfPrice] = request.security_lower_tf(source6, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s7LtfHigh, s7LtfLow, s7LtfVol, s7LtfPrice] = request.security_lower_tf(source7, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s8LtfHigh, s8LtfLow, s8LtfVol, s8LtfPrice] = request.security_lower_tf(source8, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)
[s9LtfHigh, s9LtfLow, s9LtfVol, s9LtfPrice] = request.security_lower_tf(source9, lowerTf, [high, low, volume, hlc3], ignore_invalid_timeframe=true, calc_bars_count=lowerTfCalcBars)

//=============================================================================
// DISPLAY HELPERS
//=============================================================================

f_kindColor(int kind) =>
    kind == KIND_D ? dailyPOCColor : kind == KIND_W ? weeklyPOCColor : monthlyPOCColor

f_kindVisible(int kind) =>
    kind == KIND_D ? showDailyPOCs : kind == KIND_W ? showWeeklyPOCs : showMonthlyPOCs

f_kindHistory(int kind) =>
    kind == KIND_D ? dailyPOCHistory : kind == KIND_W ? weeklyPOCHistory : monthlyPOCHistory

f_removeLevel(int idx) =>
    bool removed = false
    if idx >= 0 and idx < array.size(lvlPrice)
        line retro = array.remove(lvlRetroLine, idx)
        line active = array.remove(lvlActiveLine, idx)
        if not na(retro)
            line.delete(retro)
        if not na(active)
            line.delete(active)
        array.remove(lvlPrice, idx)
        array.remove(lvlKind, idx)
        array.remove(lvlTouched, idx)
        array.remove(lvlPeriodEnd, idx)
        removed := true
    removed

f_countKind(int wantedKind) =>
    int count = 0
    int n = array.size(lvlKind)
    if n > 0
        for i = 0 to n - 1
            if array.get(lvlKind, i) == wantedKind
                count += 1
    count

f_trimKind(int wantedKind) =>
    int historyLimit = f_kindHistory(wantedKind)
    bool keepTrimming = true
    while keepTrimming and f_countKind(wantedKind) > historyLimit
        int removeIdx = -1
        int n = array.size(lvlKind)
        if n > 0
            for i = 0 to n - 1
                if removeIdx == -1 and array.get(lvlKind, i) == wantedKind
                    removeIdx := i
        if removeIdx >= 0
            keepTrimming := f_removeLevel(removeIdx)
        else
            keepTrimming := false
    true

f_countLines() =>
    int count = 0
    int n = array.size(lvlActiveLine)
    if n > 0
        for i = 0 to n - 1
            if not na(array.get(lvlRetroLine, i))
                count += 1
            if not na(array.get(lvlActiveLine, i))
                count += 1
    count

f_deleteOldestKind(int wantedKind) =>
    bool removed = false
    int n = array.size(lvlKind)
    if n > 0
        for i = 0 to n - 1
            if not removed and array.get(lvlKind, i) == wantedKind
                removed := f_removeLevel(i)
    removed

f_hideTouchedLevel(int idx) =>
    bool hidden = false
    if idx >= 0 and idx < array.size(lvlPrice)
        line retro = array.get(lvlRetroLine, idx)
        line active = array.get(lvlActiveLine, idx)
        if not na(retro)
            line.delete(retro)
            array.set(lvlRetroLine, idx, na)
        if not na(active)
            line.delete(active)
            array.set(lvlActiveLine, idx, na)
        hidden := true
    hidden

f_trimGlobalBudget() =>
    bool keepTrimming = true
    while keepTrimming and f_countLines() > 480
        bool removed = false
        if not removed
            removed := f_deleteOldestKind(KIND_D)
        if not removed
            removed := f_deleteOldestKind(KIND_W)
        if not removed
            removed := f_deleteOldestKind(KIND_M)
        if not removed
            keepTrimming := false

f_addPOC(float price, int kind, int periodStartTime, int activeTime, int periodEndTime) =>
    if not na(price) and price != 0.0 and f_kindVisible(kind)
        color pocColor = f_kindColor(kind)
        int oneBarMillis = int(math.max(1.0, timeframe.in_seconds() * 1000.0))
        int safeStartTime = math.min(periodStartTime, activeTime)

        line retro = line.new(
            x1=safeStartTime,
            y1=price,
            x2=activeTime,
            y2=price,
            xloc=xloc.bar_time,
            extend=extend.none,
            color=pocColor,
            style=line.style_dotted,
            width=pocLineWidth
        )

        line active = line.new(
            x1=activeTime,
            y1=price,
            x2=activeTime + oneBarMillis,
            y2=price,
            xloc=xloc.bar_time,
            extend=extend.right,
            color=pocColor,
            style=line.style_solid,
            width=pocLineWidth
        )

        array.push(lvlPrice, price)
        array.push(lvlKind, kind)
        array.push(lvlTouched, false)
        array.push(lvlPeriodEnd, periodEndTime)
        array.push(lvlRetroLine, retro)
        array.push(lvlActiveLine, active)

        f_trimKind(kind)
        f_trimGlobalBudget()

//=============================================================================
// PROFILE SAMPLE HELPERS
//=============================================================================

f_roundTick(float price) =>
    roundToTick and not na(price) ? math.round(price / syminfo.mintick) * syminfo.mintick : price

f_addSample(array<float> ah, array<float> al, array<float> av, array<float> ap, array<int> asrc, float h, float l, float v, float p, int srcId) =>
    if not na(h) and not na(l) and not na(v) and v > 0 and not na(p)
        array.push(ah, h)
        array.push(al, l)
        array.push(av, v)
        array.push(ap, p)
        array.push(asrc, srcId)

f_addSampleAllPeriods(float h, float l, float v, float p, int srcId) =>
    f_addSample(dHigh, dLow, dVol, dPrice, dSource, h, l, v, p, srcId)
    f_addSample(wHigh, wLow, wVol, wPrice, wSource, h, l, v, p, srcId)
    f_addSample(mHigh, mLow, mVol, mPrice, mSource, h, l, v, p, srcId)

f_addIntrabarSet(array<float> srcHigh, array<float> srcLow, array<float> srcVol, array<float> srcPrice, int srcId) =>
    if not na(srcHigh) and not na(srcLow) and not na(srcVol) and not na(srcPrice)
        int n = math.min(math.min(array.size(srcHigh), array.size(srcLow)), math.min(array.size(srcVol), array.size(srcPrice)))
        if n > 0
            for i = 0 to n - 1
                f_addSampleAllPeriods(array.get(srcHigh, i), array.get(srcLow, i), array.get(srcVol, i), array.get(srcPrice, i), srcId)

f_trimSamples(array<float> ah, array<float> al, array<float> av, array<float> ap, array<int> asrc) =>
    while array.size(av) > maxSamplesPerPeriod
        array.shift(ah)
        array.shift(al)
        array.shift(av)
        array.shift(ap)
        array.shift(asrc)

f_trimAllProfiles() =>
    f_trimSamples(dHigh, dLow, dVol, dPrice, dSource)
    f_trimSamples(wHigh, wLow, wVol, wPrice, wSource)
    f_trimSamples(mHigh, mLow, mVol, mPrice, mSource)

f_clearSamples(array<float> ah, array<float> al, array<float> av, array<float> ap, array<int> asrc) =>
    array.clear(ah)
    array.clear(al)
    array.clear(av)
    array.clear(ap)
    array.clear(asrc)

f_calcPOC(array<float> ah, array<float> al, array<float> av, array<float> ap, array<int> asrc) =>
    float result = na
    int n = array.size(av)

    if n > 0
        float periodLow = array.min(al)
        float periodHigh = array.max(ah)
        float priceRange = periodHigh - periodLow

        if not na(periodLow) and not na(periodHigh)
            if priceRange <= syminfo.mintick
                result := f_roundTick((periodHigh + periodLow) * 0.5)
            else
                float binSize = priceRange / profileRows
                array<float> bins = array.new_float(profileRows, 0.0)
                array<float> sourceTotals = array.new_float(10, 0.0)

                if equalWeighting
                    for i = 0 to n - 1
                        float v = array.get(av, i)
                        int srcId = array.get(asrc, i)
                        if not na(v) and v > 0 and srcId >= 0 and srcId <= 9
                            array.set(sourceTotals, srcId, array.get(sourceTotals, srcId) + v)

                for i = 0 to n - 1
                    float h = array.get(ah, i)
                    float l = array.get(al, i)
                    float rawV = array.get(av, i)
                    float p = array.get(ap, i)
                    int srcId = array.get(asrc, i)

                    float v = rawV
                    if equalWeighting
                        float srcTotal = srcId >= 0 and srcId <= 9 ? array.get(sourceTotals, srcId) : na
                        v := not na(srcTotal) and srcTotal > 0 ? rawV / srcTotal : 0.0

                    if not na(v) and v > 0
                        if modeFast
                            int idx = int(math.floor((p - periodLow) / binSize))
                            idx := math.max(0, math.min(profileRows - 1, idx))
                            array.set(bins, idx, array.get(bins, idx) + v)
                        else
                            int firstBin = int(math.floor((l - periodLow) / binSize))
                            int lastBin = int(math.floor((h - periodLow) / binSize))
                            firstBin := math.max(0, math.min(profileRows - 1, firstBin))
                            lastBin := math.max(0, math.min(profileRows - 1, lastBin))
                            int touchedBins = math.max(1, lastBin - firstBin + 1)
                            float volPerBin = v / touchedBins
                            for b = firstBin to lastBin
                                array.set(bins, b, array.get(bins, b) + volPerBin)

                float maxVol = -1.0
                int maxIdx = 0
                for b = 0 to profileRows - 1
                    float binVol = array.get(bins, b)
                    if binVol > maxVol
                        maxVol := binVol
                        maxIdx := b

                result := f_roundTick(periodLow + (maxIdx + 0.5) * binSize)

    result

//=============================================================================
// PERIOD BOUNDARIES
//=============================================================================

bool newDay = timeframe.change("1D")
bool newWeek = timeframe.change("1W")
bool newMonth = timeframe.change("1M")

var int currentDayStartTime = time
var int currentWeekStartTime = time
var int currentMonthStartTime = time

//=============================================================================
// FINALIZE COMPLETED PERIODS
//=============================================================================

if newDay
    int completedStartTime = currentDayStartTime
    currentDayStartTime := time
    if array.size(dVol) > 0
        float poc = f_calcPOC(dHigh, dLow, dVol, dPrice, dSource)
        int completedEndTime = time_close[1]
        f_clearSamples(dHigh, dLow, dVol, dPrice, dSource)
        if not na(poc)
            f_addPOC(poc, KIND_D, completedStartTime, time, completedEndTime)

if newWeek
    int completedStartTime = currentWeekStartTime
    currentWeekStartTime := time
    if array.size(wVol) > 0
        float poc = f_calcPOC(wHigh, wLow, wVol, wPrice, wSource)
        int completedEndTime = time_close[1]
        f_clearSamples(wHigh, wLow, wVol, wPrice, wSource)
        if not na(poc)
            f_addPOC(poc, KIND_W, completedStartTime, time, completedEndTime)

if newMonth
    int completedStartTime = currentMonthStartTime
    currentMonthStartTime := time
    if array.size(mVol) > 0
        float poc = f_calcPOC(mHigh, mLow, mVol, mPrice, mSource)
        int completedEndTime = time_close[1]
        f_clearSamples(mHigh, mLow, mVol, mPrice, mSource)
        if not na(poc)
            f_addPOC(poc, KIND_M, completedStartTime, time, completedEndTime)

//=============================================================================
// BUILD CURRENT D / W / M PROFILES
//=============================================================================

if not compositeMode
    if modeHigh
        f_addIntrabarSet(chartLtfHigh, chartLtfLow, chartLtfVol, chartLtfPrice, 0)
    else
        f_addSampleAllPeriods(high, low, volume, hlc3, 0)
else
    if includeCurrentChartInComposite
        if modeHigh
            f_addIntrabarSet(chartLtfHigh, chartLtfLow, chartLtfVol, chartLtfPrice, 0)
        else
            f_addSampleAllPeriods(high, low, volume, hlc3, 0)

    if modeHigh
        if useSource1
            f_addIntrabarSet(s1LtfHigh, s1LtfLow, s1LtfVol, s1LtfPrice, 1)
        if useSource2
            f_addIntrabarSet(s2LtfHigh, s2LtfLow, s2LtfVol, s2LtfPrice, 2)
        if useSource3
            f_addIntrabarSet(s3LtfHigh, s3LtfLow, s3LtfVol, s3LtfPrice, 3)
        if useSource4
            f_addIntrabarSet(s4LtfHigh, s4LtfLow, s4LtfVol, s4LtfPrice, 4)
        if useSource5
            f_addIntrabarSet(s5LtfHigh, s5LtfLow, s5LtfVol, s5LtfPrice, 5)
        if useSource6
            f_addIntrabarSet(s6LtfHigh, s6LtfLow, s6LtfVol, s6LtfPrice, 6)
        if useSource7
            f_addIntrabarSet(s7LtfHigh, s7LtfLow, s7LtfVol, s7LtfPrice, 7)
        if useSource8
            f_addIntrabarSet(s8LtfHigh, s8LtfLow, s8LtfVol, s8LtfPrice, 8)
        if useSource9
            f_addIntrabarSet(s9LtfHigh, s9LtfLow, s9LtfVol, s9LtfPrice, 9)
    else
        if useSource1
            f_addSampleAllPeriods(s1High, s1Low, s1Vol, s1Price, 1)
        if useSource2
            f_addSampleAllPeriods(s2High, s2Low, s2Vol, s2Price, 2)
        if useSource3
            f_addSampleAllPeriods(s3High, s3Low, s3Vol, s3Price, 3)
        if useSource4
            f_addSampleAllPeriods(s4High, s4Low, s4Vol, s4Price, 4)
        if useSource5
            f_addSampleAllPeriods(s5High, s5Low, s5Vol, s5Price, 5)
        if useSource6
            f_addSampleAllPeriods(s6High, s6Low, s6Vol, s6Price, 6)
        if useSource7
            f_addSampleAllPeriods(s7High, s7Low, s7Vol, s7Price, 7)
        if useSource8
            f_addSampleAllPeriods(s8High, s8Low, s8Vol, s8Price, 8)
        if useSource9
            f_addSampleAllPeriods(s9High, s9Low, s9Vol, s9Price, 9)

f_trimAllProfiles()

//=============================================================================
// FIRST TOUCH OF FINALIZED POC
// Touch testing always uses the CURRENT CHART market, even for composite POCs.
//=============================================================================

int levelCount = array.size(lvlPrice)

if levelCount > 0
    for i = 0 to levelCount - 1
        bool touched = array.get(lvlTouched, i)
        if not touched
            float level = array.get(lvlPrice, i)
            int periodEndTime = array.get(lvlPeriodEnd, i)
            bool touchWindowOpen = time >= periodEndTime
            bool touchesLevel = touchWindowOpen and low <= level and high >= level

            if touchesLevel
                if showOnlyUntouchedPOCs
                    bool didHide = f_hideTouchedLevel(i)
                else
                    line active = array.get(lvlActiveLine, i)
                    if not na(active)
                        int oneBarMillis = int(math.max(1.0, timeframe.in_seconds() * 1000.0))
                        int pocStartTime = line.get_x1(active)
                        line.set_extend(active, extend.none)
                        line.set_x2(active, math.max(time, pocStartTime + oneBarMillis))
                        line.set_y1(active, level)
                        line.set_y2(active, level)
                array.set(lvlTouched, i, true)

//=============================================================================
// DEVELOPING POCs
//=============================================================================

if barstate.islast
    if not na(developingDailyPOCLine)
        line.delete(developingDailyPOCLine)
        developingDailyPOCLine := na
    if not na(developingWeeklyPOCLine)
        line.delete(developingWeeklyPOCLine)
        developingWeeklyPOCLine := na
    if not na(developingMonthlyPOCLine)
        line.delete(developingMonthlyPOCLine)
        developingMonthlyPOCLine := na

    int oneBarMillis = int(math.max(1.0, timeframe.in_seconds() * 1000.0))
    int developingX2 = na(time_close) ? time + oneBarMillis : time_close

    if showDevelopingPOCs
        if showDailyPOCs and array.size(dVol) > 0
            float developingPOC = f_calcPOC(dHigh, dLow, dVol, dPrice, dSource)
            if not na(developingPOC)
                developingDailyPOCLine := line.new(
                    x1=currentDayStartTime,
                    y1=developingPOC,
                    x2=math.max(currentDayStartTime + 1, developingX2),
                    y2=developingPOC,
                    xloc=xloc.bar_time,
                    extend=extend.right,
                    color=dailyPOCColor,
                    style=line.style_dotted,
                    width=pocLineWidth
                )

        if showWeeklyPOCs and array.size(wVol) > 0
            float developingPOC = f_calcPOC(wHigh, wLow, wVol, wPrice, wSource)
            if not na(developingPOC)
                developingWeeklyPOCLine := line.new(
                    x1=currentWeekStartTime,
                    y1=developingPOC,
                    x2=math.max(currentWeekStartTime + 1, developingX2),
                    y2=developingPOC,
                    xloc=xloc.bar_time,
                    extend=extend.right,
                    color=weeklyPOCColor,
                    style=line.style_dotted,
                    width=pocLineWidth
                )

        if showMonthlyPOCs and array.size(mVol) > 0
            float developingPOC = f_calcPOC(mHigh, mLow, mVol, mPrice, mSource)
            if not na(developingPOC)
                developingMonthlyPOCLine := line.new(
                    x1=currentMonthStartTime,
                    y1=developingPOC,
                    x2=math.max(currentMonthStartTime + 1, developingX2),
                    y2=developingPOC,
                    xloc=xloc.bar_time,
                    extend=extend.right,
                    color=monthlyPOCColor,
                    style=line.style_dotted,
                    width=pocLineWidth
                )

//=============================================================================
// NEAREST ACTIVE POCs ON PRICE SCALE
//=============================================================================

var array<int> nearestAboveIdx = array.new_int()
var array<int> nearestBelowIdx = array.new_int()

if barstate.islast
    array.clear(nearestAboveIdx)
    array.clear(nearestBelowIdx)

    int n = array.size(lvlPrice)

    if showNearestPOCPrices and n > 0
        for pick = 0 to 4
            int bestIndex = na
            float bestDistance = na
            for i = 0 to n - 1
                float pocPrice = array.get(lvlPrice, i)
                bool touched = array.get(lvlTouched, i)
                int kind = array.get(lvlKind, i)
                bool visible = f_kindVisible(kind)
                bool alreadySelected = array.includes(nearestAboveIdx, i)
                bool valid = not touched and visible and pocPrice > close and not alreadySelected
                if valid
                    float distance = pocPrice - close
                    if na(bestDistance) or distance < bestDistance
                        bestDistance := distance
                        bestIndex := i
            if not na(bestIndex)
                array.push(nearestAboveIdx, bestIndex)

        for pick = 0 to 4
            int bestIndex = na
            float bestDistance = na
            for i = 0 to n - 1
                float pocPrice = array.get(lvlPrice, i)
                bool touched = array.get(lvlTouched, i)
                int kind = array.get(lvlKind, i)
                bool visible = f_kindVisible(kind)
                bool alreadySelected = array.includes(nearestBelowIdx, i)
                bool valid = not touched and visible and pocPrice < close and not alreadySelected
                if valid
                    float distance = close - pocPrice
                    if na(bestDistance) or distance < bestDistance
                        bestDistance := distance
                        bestIndex := i
            if not na(bestIndex)
                array.push(nearestBelowIdx, bestIndex)

f_scaleSlotPrice(array<int> source, int slot) =>
    float result = na
    if slot >= 0 and slot < array.size(source)
        int idx = array.get(source, slot)
        result := array.get(lvlPrice, idx)
    result

f_scaleSlotColor(array<int> source, int slot) =>
    color result = color.new(color.white, 100)
    if slot >= 0 and slot < array.size(source)
        int idx = array.get(source, slot)
        int kind = array.get(lvlKind, idx)
        result := f_kindColor(kind)
    result

float above1 = f_scaleSlotPrice(nearestAboveIdx, 0)
float above2 = f_scaleSlotPrice(nearestAboveIdx, 1)
float above3 = f_scaleSlotPrice(nearestAboveIdx, 2)
float above4 = f_scaleSlotPrice(nearestAboveIdx, 3)
float above5 = f_scaleSlotPrice(nearestAboveIdx, 4)

color aboveColor1 = f_scaleSlotColor(nearestAboveIdx, 0)
color aboveColor2 = f_scaleSlotColor(nearestAboveIdx, 1)
color aboveColor3 = f_scaleSlotColor(nearestAboveIdx, 2)
color aboveColor4 = f_scaleSlotColor(nearestAboveIdx, 3)
color aboveColor5 = f_scaleSlotColor(nearestAboveIdx, 4)

float below1 = f_scaleSlotPrice(nearestBelowIdx, 0)
float below2 = f_scaleSlotPrice(nearestBelowIdx, 1)
float below3 = f_scaleSlotPrice(nearestBelowIdx, 2)
float below4 = f_scaleSlotPrice(nearestBelowIdx, 3)
float below5 = f_scaleSlotPrice(nearestBelowIdx, 4)

color belowColor1 = f_scaleSlotColor(nearestBelowIdx, 0)
color belowColor2 = f_scaleSlotColor(nearestBelowIdx, 1)
color belowColor3 = f_scaleSlotColor(nearestBelowIdx, 2)
color belowColor4 = f_scaleSlotColor(nearestBelowIdx, 3)
color belowColor5 = f_scaleSlotColor(nearestBelowIdx, 4)

plot(above1, "POC Above 1", color=aboveColor1, display=display.price_scale, format=format.price)
plot(above2, "POC Above 2", color=aboveColor2, display=display.price_scale, format=format.price)
plot(above3, "POC Above 3", color=aboveColor3, display=display.price_scale, format=format.price)
plot(above4, "POC Above 4", color=aboveColor4, display=display.price_scale, format=format.price)
plot(above5, "POC Above 5", color=aboveColor5, display=display.price_scale, format=format.price)

plot(below1, "POC Below 1", color=belowColor1, display=display.price_scale, format=format.price)
plot(below2, "POC Below 2", color=belowColor2, display=display.price_scale, format=format.price)
plot(below3, "POC Below 3", color=belowColor3, display=display.price_scale, format=format.price)
plot(below4, "POC Below 4", color=belowColor4, display=display.price_scale, format=format.price)
plot(below5, "POC Below 5", color=belowColor5, display=display.price_scale, format=format.price)
````
