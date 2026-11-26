# Rell SMI v4.7 Premium

- url: https://www.tradingview.com/script/kGJYea5L-Rell-SMI-v4-7-Premium/
- type: indicator
- pine_id: PUB;97a7ae7f117f4e33b1e94661b275563a
- version: 5.0

## Description

Full breakdown link: [url=https://rellsmi.com/]https://rellsmi.com/[/url]
My Profile: [url=https://guns.lol/c4r3ll]https://guns.lol/c4r3ll[/url]

Rell SMI v4.7 Premium is a TradingView market intelligence system built to read structure, liquidity, momentum, VWAP position, trend strength, volume pressure, and session participation as one coordinated decision layer.

Instead of blindly firing buy and sell prompts, it grades the environment, measures confluence, highlights trap conditions, and turns noisy chart action into a readable market state.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RellTrades07

//@version=5
indicator("Rell SMI v4.7 Premium", "RSMI47P", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=2000)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Utils
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_pos(posTxt) =>
    switch posTxt
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.small

f_solid(c) =>
    color.rgb(color.r(c), color.g(c), color.b(c))

f_pct(x) =>
    str.tostring(x, "#.##") + "%"

f_prob(x) =>
    str.tostring(math.round(x * 100.0)) + "%"

f_score_text(bull, bear, maxv) =>
    "Bull " + str.tostring(bull) + "/" + str.tostring(maxv) + " | Bear " + str.tostring(bear) + "/" + str.tostring(maxv)

f_sentiment_bar(_pct) =>
    filled = int(math.round(_pct / 10.0))
    empty = 10 - filled
    str.repeat("█", filled) + str.repeat("░", empty)

f_trend_text(c, e50, e200) =>
    string result = "Range"
    if c > e50 and e50 > e200
        result := "Bull"
    else if c < e50 and e50 < e200
        result := "Bear"
    result

f_trend_color(t) =>
    t == "Bull" ? color.lime : t == "Bear" ? color.red : color.gray

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

transparent = color.new(color.white, 100)
atr = ta.atr(14)
atrLong = ta.atr(50)
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
volMa = ta.sma(volume, 20)
rvol = volume / math.max(volMa, 1)

pipSize = syminfo.type == "forex" ? syminfo.mintick * 10.0 : syminfo.mintick
atrPips = atr / pipSize

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gMarket = "Market / Presets"
marketMode = input.string("Auto", "Market Mode", options=["Auto", "Crypto", "Forex", "Stocks", "Futures/Indices", "Custom"], group=gMarket)
applyPresetOverrides = input.bool(true, "Apply Preset Overrides", group=gMarket)
allowAutoDetect = input.bool(true, "Allow Auto Detect When Auto", group=gMarket)
customLabel = input.string("Custom", "Custom Label", group=gMarket)

gDash = "Dashboard Premium"
showDashboard = input.bool(true, "Show Dashboard", group=gDash)
dashMode = input.string("Balanced", "Dashboard Mode", options=["Focused", "Balanced", "Full"], group=gDash)
scannerMode = input.string("Compact", "Scanner Mode", options=["Off", "Compact", "Full"], group=gDash)
dashPosition = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=gDash)
dashTextSize = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=gDash)
dashTheme = input.string("Glass", "Theme", options=["Glass", "Carbon", "Midnight", "Neon"], group=gDash)
dashOpacity = input.int(10, "Panel Opacity", minval=0, maxval=100, group=gDash)
dashBorderOpacity = input.int(70, "Border Opacity", minval=0, maxval=100, group=gDash)
dashUseChartTint = input.bool(false, "Chart Background Tint", group=gDash)

gScanner = "Multi-Market Scanner"
scannerTf = input.timeframe("15", "Scanner Timeframe", group=gScanner)
scan1 = input.symbol("COINBASE:BTCUSD", "Scanner Symbol 1", group=gScanner)
scan2 = input.symbol("OANDA:EURUSD", "Scanner Symbol 2", group=gScanner)
scan3 = input.symbol("NASDAQ:AAPL", "Scanner Symbol 3", group=gScanner)

gMTF = "MTF Backend Context"
useMTFBackend = input.bool(true, "Use MTF Backend Brain", group=gMTF)
mtfLiqTf = input.timeframe("15", "MTF Liquidity TF", group=gMTF)
mtfContextTf = input.timeframe("60", "HTF Context TF", group=gMTF)
mtfMacroTf = input.timeframe("240", "Macro Context TF", group=gMTF)
mtfPivotLen = input.int(5, "MTF Pivot Length", minval=2, maxval=20, group=gMTF)
mtfLiqToleranceAtr = input.float(0.15, "MTF Equal H/L Tolerance ATR", minval=0.02, maxval=0.50, step=0.01, group=gMTF)
mtfMinFvgQuality = input.float(0.55, "Minimum MTF FVG Quality", minval=0.25, maxval=0.90, step=0.05, group=gMTF)


gMain = "Main Controls"
showEMAs = input.bool(false, "Show EMA 20 / 50 / 200", group=gMain)
showDWM = input.bool(true, "Show Daily Open + Previous Day High/Low", group=gMain)
includeDWMInScore = input.bool(true, "Include DWM In Score", group=gMain)

gFVG = "Fair Value Gaps + Quality"
showFVG = input.bool(true, "Show FVGs", group=gFVG)
fvgThreshold = input.float(0.0, "Minimum Gap %", minval=0, step=0.1, group=gFVG)
fvgUseATR = input.bool(true, "Use ATR Gap Filter", group=gFVG)
fvgAtrMult = input.float(0.20, "ATR Filter Multiplier", minval=0.01, step=0.01, group=gFVG)
fvgRequireDisplacement = input.bool(true, "Require Displacement Candle", group=gFVG)
dispBodyAtr = input.float(0.55, "Min Body ATR x", minval=0.1, step=0.05, group=gFVG)
dispBodyRatio = input.float(0.55, "Min Body / Range", minval=0.2, maxval=0.95, step=0.05, group=gFVG)
fvgExtend = input.int(40, "Extend Bars", minval=1, group=gFVG)
fvgMaxZones = input.int(20, "Max Active FVGs", minval=1, maxval=100, group=gFVG)
fvgMaxAge = input.int(250, "Auto Delete After Bars", minval=25, maxval=2000, group=gFVG)
fvgInvalidation = input.string("Full Fill", "Delete FVG When", options=["Full Fill", "Close Through", "Midpoint Touch", "Any Touch"], group=gFVG)
fvgShrinkOnFill = input.bool(true, "Shrink Partially Filled", group=gFVG)
showFvgMidline = input.bool(true, "Show CE / Midline", group=gFVG)
trackIFVG = input.bool(true, "Track IFVG / Inversions", group=gFVG)
ifvgReqDisplacement = input.bool(true, "IFVG Requires Displacement", group=gFVG)
ifvgReqStructure = input.bool(true, "IFVG Requires CHoCH/BOS", group=gFVG)
fvgClearWhenOff = input.bool(true, "Clear All When Disabled", group=gFVG)

bullFvgColor = input.color(color.new(#089981, 80), "Bullish FVG", group=gFVG)
bearFvgColor = input.color(color.new(#f23645, 80), "Bearish FVG", group=gFVG)
ifvgBullColor = input.color(color.new(#7e57c2, 78), "Bullish IFVG", group=gFVG)
ifvgBearColor = input.color(color.new(#f48fb1, 78), "Bearish IFVG", group=gFVG)

gStructure = "Structure / CHoCH / BOS"
showStructure = input.bool(true, "Show BOS / CHoCH Labels", group=gStructure)
internalLength = input.int(3, "Internal Swing Length", minval=2, maxval=20, group=gStructure)
swingLength = input.int(7, "Swing Length", minval=2, maxval=50, group=gStructure)
msUseClose = input.bool(true, "Use Close For Break", group=gStructure)
htfStructureTf = input.timeframe("60", "HTF Bias TF", group=gStructure)
showStructureLabels = input.bool(true, "Show Structure Labels", group=gStructure)
bullStructureColor = input.color(color.lime, "Bull Structure", group=gStructure)
bearStructureColor = input.color(color.red, "Bear Structure", group=gStructure)

gLiq = "Liquidity Pools"
showLiquidity = input.bool(true, "Show Liquidity Pools", group=gLiq)
liqContactAmount = input.int(2, "Zone Contact Amount", minval=2, group=gLiq)
liqGapCount = input.int(5, "Bars Between Contacts", minval=0, group=gLiq)
liqWaitBars = input.int(10, "Confirmation Bars", minval=1, group=gLiq)
liqSweepConfirm = input.string("Close Back Inside", "Sweep Confirm", options=["Close Back Inside", "Close Through Zone"], group=gLiq)
liqShowVolLabels = input.bool(true, "Volume Labels", group=gLiq)
liqVolSizeInput = input.string("Small", "Vol Label Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=gLiq)
liqDeleteMode = input.string("Never", "Delete Zone", options=["Never", "On Sweep", "On Break"], group=gLiq)
liqMaxZones = input.int(30, "Max Zones", minval=1, maxval=100, group=gLiq)
liqShowSweepLabels = input.bool(true, "Sweep Labels", group=gLiq)
liqBullColor = input.color(color.new(#089981, 80), "Sell-Side SSL Zone", group=gLiq)
liqBearColor = input.color(color.new(#f23645, 80), "Buy-Side BSL Zone", group=gLiq)

gOB = "Backend Order Blocks"
useOB = input.bool(true, "Use OB Backend Confluence", group=gOB)
obLookback = input.int(10, "OB Lookback", minval=3, maxval=30, group=gOB)
obMaxAge = input.int(100, "OB Freshness Bars", minval=20, maxval=500, group=gOB)

gVP = "Backend Volume Profile"
useVP = input.bool(true, "Use POC / Value Area Backend", group=gVP)
vpLookback = input.int(160, "VP Lookback Bars", minval=50, maxval=500, group=gVP)
vpBins = input.int(48, "VP Bins", minval=20, maxval=120, group=gVP)
vpValueAreaPct = input.int(68, "Value Area %", minval=50, maxval=90, group=gVP)

gOR = "Opening Range"
showOR = input.bool(false, "Show Opening Range Lines", group=gOR)
useORBackend = input.bool(true, "Use Opening Range Backend", group=gOR)
orSession = input.session("0930-1000", "Opening Range Session", group=gOR)
orColor = input.color(color.new(color.yellow, 20), "OR Color", group=gOR)

gKZ = "Killzones"
showKillzones = input.bool(true, "Show Killzones", group=gKZ)
kzTimezone = input.string("America/New_York", "Timezone", group=gKZ)
kzTransparency = input.int(85, "Box Transparency", minval=0, maxval=100, group=gKZ)
kzShowHL = input.bool(true, "Draw KZ High/Low", group=gKZ)
kzMaxDays = input.int(3, "Days Limit", minval=1, group=gKZ)
kzEnableOnCrypto = input.bool(false, "Allow Killzones On Crypto", group=gKZ)

useAsia = input.bool(true, "Asia", inline="AS", group=gKZ)
asiaSession = input.session("2000-0000", "", inline="AS", group=gKZ)
asiaColor = input.color(color.blue, "", inline="AS", group=gKZ)

useLondon = input.bool(true, "London", inline="LO", group=gKZ)
londonSession = input.session("0200-0500", "", inline="LO", group=gKZ)
londonColor = input.color(color.red, "", inline="LO", group=gKZ)

useNYAM = input.bool(true, "NY AM", inline="NYA", group=gKZ)
nyamSession = input.session("0930-1100", "", inline="NYA", group=gKZ)
nyamColor = input.color(#089981, "", inline="NYA", group=gKZ)

useNYPM = input.bool(true, "NY PM", inline="NYP", group=gKZ)
nypmSession = input.session("1330-1600", "", inline="NYP", group=gKZ)
nypmColor = input.color(color.purple, "", inline="NYP", group=gKZ)

gTime = "Time / Volume Filters"
useTimeFilter = input.bool(true, "Use Time Blackout Filter", group=gTime)
avoidOpenMin = input.int(5, "Skip First N Minutes NY Open", minval=0, maxval=30, group=gTime)
avoidCloseMin = input.int(10, "Skip Last N Minutes NY Close", minval=0, maxval=30, group=gTime)
avoidLunch = input.bool(true, "Skip NY Lunch Chop", group=gTime)
rvolMin = input.float(0.8, "Minimum RVOL Quality", minval=0.1, step=0.1, group=gTime)
volCompressPct = input.float(0.70, "Compression Threshold", minval=0.4, maxval=0.95, step=0.05, group=gTime)
volExpandPct = input.float(1.30, "Expansion Threshold", minval=1.05, maxval=2.0, step=0.05, group=gTime)

gTL = "Trendlines With Breaks"
showTrendlines = input.bool(true, "Show Trendlines", group=gTL)
tlLength = input.int(14, "Swing Lookback", minval=2, group=gTL)
tlSlopeMult = input.float(1.0, "Slope Mult", minval=0, step=0.1, group=gTL)
tlCalcMethod = input.string("Atr", "Slope Method", options=["Atr", "Stdev", "Linreg"], group=gTL)
tlBackpaint = input.bool(true, "Backpaint", group=gTL)
tlShowBreaks = input.bool(true, "Break Labels", group=gTL)
tlShowExtended = input.bool(true, "Extended Lines", group=gTL)
tlUpColor = input.color(color.teal, "Up TL Color", group=gTL)
tlDownColor = input.color(color.red, "Down TL Color", group=gTL)

gAlerts = "Alerts"
alertFVG = input.bool(true, "FVG Alerts", group=gAlerts)
alertStructure = input.bool(true, "Structure Alerts", group=gAlerts)
alertLiquidity = input.bool(true, "Liquidity Alerts", group=gAlerts)
alertConfluence = input.bool(true, "Confluence Alerts", group=gAlerts)
confluenceThreshold = input.int(5, "Confluence Score", minval=2, maxval=15, group=gAlerts)

gBrain = "v4.7 Premium Backend"
useBrain43 = input.bool(true, "Use v4.3 Brain Engine", group=gBrain)
useAutoThreshold43 = input.bool(true, "Auto Confluence Threshold", group=gBrain)
useMomentumBrain43 = input.bool(true, "Momentum Brain", group=gBrain)
useVwapBrain43 = input.bool(true, "VWAP Deviation Brain", group=gBrain)
useVolumeBrain43 = input.bool(true, "Volume Pressure Brain", group=gBrain)
useTrendBrain43 = input.bool(true, "ADX / DI Trend Brain", group=gBrain)
showSentiment43 = input.bool(true, "Show Sentiment Row", group=gBrain)
usePremium46 = input.bool(true, "Use v4.7 Premium Backend", group=gBrain)
useIT3Backend47 = input.bool(true, "Use IT3 Backend Filter", group=gBrain)
enableIT3Alerts46 = input.bool(true, "Backend IT3 Alerts", group=gBrain)
showBTCycle46 = input.bool(true, "Show BTC Cycle Context", group=gBrain)
showWorkflow461 = input.bool(true, "Show Workflow Row", group=gBrain)
useStrictAction461 = input.bool(true, "Strict Action Guard", group=gBrain)

gGov47 = "v4.7 Risk Governance"
useGovernance47 = input.bool(true, "Use Risk Governance Layer", group=gGov47)
showGovernanceRows47 = input.bool(true, "Show Risk / Research Rows", group=gGov47)
researchStatus47 = input.string("Forward Test", "Research Status", options=["Approved", "Forward Test", "Watchlist", "Rejected", "Untrained"], group=gGov47)
drawdownInputMode47 = input.string("Auto", "Drawdown Mode", options=["Auto", "Normal", "Caution", "Recovery", "Lockout"], group=gGov47)
dailyLossCount47 = input.int(0, "Daily Loss Count", minval=0, maxval=20, group=gGov47)
weeklyLossCount47 = input.int(0, "Weekly Loss Count", minval=0, maxval=50, group=gGov47)
losingStreak47 = input.int(0, "Current Losing Streak", minval=0, maxval=20, group=gGov47)
maxDailyLosses47 = input.int(3, "Lockout After Daily Losses", minval=1, maxval=10, group=gGov47)
reducedRiskPct47 = input.float(0.25, "Reduced Risk %", minval=0.0, maxval=2.0, step=0.05, group=gGov47)
normalRiskPct47 = input.float(0.50, "Normal Risk %", minval=0.0, maxval=2.0, step=0.05, group=gGov47)
premiumRiskPct47 = input.float(0.75, "Premium Risk %", minval=0.0, maxval=2.0, step=0.05, group=gGov47)
maxRiskCapPct47 = input.float(1.00, "Hard Risk Cap %", minval=0.0, maxval=3.0, step=0.05, group=gGov47)
useKellyReference47 = input.bool(false, "Cap With Fractional Kelly Reference", group=gGov47)
kellyWinRate47 = input.float(52.0, "Kelly Win Rate %", minval=1.0, maxval=99.0, step=0.5, group=gGov47)
kellyRR47 = input.float(2.0, "Kelly Reward/Risk", minval=0.25, maxval=10.0, step=0.25, group=gGov47)
correlationOverride47 = input.string("Auto", "Correlation Risk", options=["Auto", "Low", "Medium", "High"], group=gGov47)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Market Presets
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

autoProfile = syminfo.type == "crypto" ? "Crypto" : syminfo.type == "forex" ? "Forex" : syminfo.type == "stock" ? "Stocks" : syminfo.type == "futures" ? "Futures/Indices" : "Custom"
profile = marketMode == "Auto" and allowAutoDetect ? autoProfile : marketMode == "Custom" ? customLabel : marketMode

isCrypto = profile == "Crypto"
isForex = profile == "Forex"
isStocks = profile == "Stocks"
isFut = profile == "Futures/Indices"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// v4.2 Adaptive Market Engine
// Faster crypto reaction logic + smarter auto presets
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fastCalc = input.bool(true, "Fast Calculation", group=gAlerts)

effConfluence = applyPresetOverrides ? (isCrypto ? math.min(confluenceThreshold, 3) : isStocks ? math.max(confluenceThreshold, 5) : isFut ? math.max(confluenceThreshold, 5) : confluenceThreshold) : confluenceThreshold

effFvgAtrMult = applyPresetOverrides ? (isCrypto ? math.max(fvgAtrMult, 0.15) : isStocks ? math.max(fvgAtrMult, 0.18) : fvgAtrMult) : fvgAtrMult

effLiqWait = applyPresetOverrides ? (isCrypto ? math.min(liqWaitBars, 3) : isStocks ? math.max(liqWaitBars, 8) : liqWaitBars) : liqWaitBars

effLiqGap = applyPresetOverrides ? (isCrypto ? math.min(liqGapCount, 2) : isStocks ? math.max(liqGapCount, 4) : liqGapCount) : liqGapCount

effSwingLength = applyPresetOverrides ? (isCrypto ? math.min(swingLength, 5) : swingLength) : swingLength

effInternalLength = applyPresetOverrides ? (isCrypto ? math.min(internalLength, 2) : internalLength) : internalLength

effRvolMin = applyPresetOverrides ? (isCrypto ? math.min(rvolMin, 0.6) : rvolMin) : rvolMin

effShowKillzones = showKillzones and (not isCrypto or kzEnableOnCrypto)

// Fast crypto liquidity sweep logic
bullishSweepFast = low < low[1] and close > low[1]
bearishSweepFast = high > high[1] and close < high[1]

cryptoSweepBull = isCrypto and bullishSweepFast
cryptoSweepBear = isCrypto and bearishSweepFast


var string adaptiveModeText = isCrypto ? "Crypto Fast Engine" : isForex ? "Forex Precision" : isStocks ? "Stocks Volume" : isFut ? "Futures OR Engine" : "Custom"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF Backend Brain: Liquidity / Structure / FVG / Premium-Discount
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_mtf_liq(_len, _tolAtr) =>
    ph = ta.pivothigh(high, _len, _len)
    pl = ta.pivotlow(low, _len, _len)
    a = ta.atr(14)

    var float prevH = na
    var float prevL = na
    var float bsl = na
    var float ssl = na

    if not na(ph)
        if not na(prevH) and math.abs(ph - prevH) <= a * _tolAtr
            bsl := math.avg(ph, prevH)
        prevH := ph

    if not na(pl)
        if not na(prevL) and math.abs(pl - prevL) <= a * _tolAtr
            ssl := math.avg(pl, prevL)
        prevL := pl

    bslSweep = not na(bsl) and high > bsl and close < bsl
    sslSweep = not na(ssl) and low < ssl and close > ssl

    bslArea = not na(bsl) and bsl > close
    sslArea = not na(ssl) and ssl < close

    code = sslSweep ? 2 : bslSweep ? -2 : (bslArea and sslArea ? 3 : sslArea ? 1 : bslArea ? -1 : 0)

    if bslSweep
        bsl := na
    if sslSweep
        ssl := na

    [code, bsl, ssl]

f_mtf_struct(_len, _useClose) =>
    ph = ta.pivothigh(high, _len, _len)
    pl = ta.pivotlow(low, _len, _len)

    var float h = na
    var float l = na
    var bool hLive = false
    var bool lLive = false
    var int dir = 0

    if not na(ph)
        h := ph
        hLive := true

    if not na(pl)
        l := pl
        lLive := true

    bH = _useClose ? close : high
    bL = _useClose ? close : low

    bullBreak = hLive and not na(h) and bH > h
    bearBreak = lLive and not na(l) and bL < l

    event = 0

    if bullBreak
        event := dir == -1 ? 2 : 1
        dir := 1
        hLive := false

    if bearBreak
        event := dir == 1 ? -2 : -1
        dir := -1
        lLive := false

    [dir, event]

f_mtf_pd(_len) =>
    ph = ta.pivothigh(high, _len, _len)
    pl = ta.pivotlow(low, _len, _len)

    var float h = na
    var float l = na

    if not na(ph)
        h := ph
    if not na(pl)
        l := pl

    have = not na(h) and not na(l)
    mid = have ? math.avg(h, l) : na
    code = not have ? 0 : close < mid ? -1 : close > mid ? 1 : 0
    [code, mid]

f_mtf_disp(_ofs, _wantBull, _bodyAtr, _bodyRatio) =>
    a = ta.atr(14)
    body = math.abs(close[_ofs] - open[_ofs])
    rng = math.max(high[_ofs] - low[_ofs], syminfo.mintick)
    big = body / math.max(a, syminfo.mintick) >= _bodyAtr
    solid = body / rng >= _bodyRatio
    dir = _wantBull ? close[_ofs] > open[_ofs] : close[_ofs] < open[_ofs]
    big and solid and dir

f_mtf_fvg(_atrMult, _bodyAtr, _bodyRatio, _pdLen) =>
    a = ta.atr(14)
    vma = ta.sma(volume, 20)
    rv = volume / math.max(vma, 1)
    e20 = ta.ema(close, 20)
    e50 = ta.ema(close, 50)
    e200 = ta.ema(close, 200)

    ph = ta.pivothigh(high, _pdLen, _pdLen)
    pl = ta.pivotlow(low, _pdLen, _pdLen)

    var float rangeH = na
    var float rangeL = na

    if not na(ph)
        rangeH := ph
    if not na(pl)
        rangeL := pl

    haveRangeLocal = not na(rangeH) and not na(rangeL)
    midRange = haveRangeLocal ? math.avg(rangeH, rangeL) : na

    bullGapLocal = low - high[2]
    bearGapLocal = low[2] - high

    bullDispLocal = f_mtf_disp(1, true, _bodyAtr, _bodyRatio)
    bearDispLocal = f_mtf_disp(1, false, _bodyAtr, _bodyRatio)

    newBull = not na(high[2]) and low > high[2] and close[1] > high[2] and bullGapLocal >= a * _atrMult and bullDispLocal
    newBear = not na(low[2]) and high < low[2] and close[1] < low[2] and bearGapLocal >= a * _atrMult and bearDispLocal

    var float top = na
    var float bot = na
    var int dir = 0
    var float q = 0.0
    var int state = 0

    if newBull
        top := low
        bot := high[2]
        dir := 1
        sizeScore = f_clamp((top - bot) / math.max(a, syminfo.mintick), 0.0, 2.0) / 2.0
        trendScore = e20 > e50 ? 1.0 : 0.25
        htfScore = close > e200 ? 0.85 : 0.35
        volScore = rv >= 1.5 ? 1.0 : rv >= 0.8 ? 0.65 : 0.25
        pdScore = not haveRangeLocal ? 0.50 : math.avg(top, bot) < midRange ? 1.0 : 0.25
        q := f_clamp(sizeScore * 0.25 + trendScore * 0.20 + htfScore * 0.20 + volScore * 0.15 + pdScore * 0.20, 0.05, 0.95)
        state := 0

    if newBear
        top := low[2]
        bot := high
        dir := -1
        sizeScore = f_clamp((top - bot) / math.max(a, syminfo.mintick), 0.0, 2.0) / 2.0
        trendScore = e20 < e50 ? 1.0 : 0.25
        htfScore = close < e200 ? 0.85 : 0.35
        volScore = rv >= 1.5 ? 1.0 : rv >= 0.8 ? 0.65 : 0.25
        pdScore = not haveRangeLocal ? 0.50 : math.avg(top, bot) > midRange ? 1.0 : 0.25
        q := f_clamp(sizeScore * 0.25 + trendScore * 0.20 + htfScore * 0.20 + volScore * 0.15 + pdScore * 0.20, 0.05, 0.95)
        state := 0

    inside = dir == 1 ? (high >= bot and low <= top) : dir == -1 ? (high >= bot and low <= top) : false
    ce = dir != 0 ? math.avg(top, bot) : na
    ceTap = dir == 1 ? low <= ce : dir == -1 ? high >= ce : false

    if ceTap and state == 0
        state := 1

    closeThrough = dir == 1 ? close < bot : dir == -1 ? close > top : false
    fullFill = dir == 1 ? low <= bot : dir == -1 ? high >= top : false
    ifvg = fullFill and closeThrough ? -dir : 0

    if ifvg != 0
        dir := ifvg
        state := 3

    [dir, q, inside ? 1 : 0, ceTap ? 1 : 0, ifvg]

f_liq_code_text(_code) =>
    _code == 2 ? "SSL Swept" :
     _code == -2 ? "BSL Swept" :
     _code == 3 ? "BSL/SSL Areas" :
     _code == 1 ? "SSL Below" :
     _code == -1 ? "BSL Above" :
     "No HTF Liq"

f_event_text(_event) =>
    _event == 2 ? "Bull CHoCH" :
     _event == 1 ? "Bull BOS" :
     _event == -2 ? "Bear CHoCH" :
     _event == -1 ? "Bear BOS" :
     "No Event"

f_dir_text(_dir) =>
    _dir == 1 ? "Bull" :
     _dir == -1 ? "Bear" :
     "Neutral"

f_pd_text(_code) =>
    _code == -1 ? "Discount" :
     _code == 1 ? "Premium" :
     "Equilibrium"

[mtfLiqCode, mtfBsl, mtfSsl] = request.security(syminfo.tickerid, mtfLiqTf, f_mtf_liq(mtfPivotLen, mtfLiqToleranceAtr), barmerge.gaps_off, barmerge.lookahead_off)
[ctxStructDir, ctxStructEvent] = request.security(syminfo.tickerid, mtfContextTf, f_mtf_struct(mtfPivotLen, msUseClose), barmerge.gaps_off, barmerge.lookahead_off)
[macroStructDir, macroStructEvent] = request.security(syminfo.tickerid, mtfMacroTf, f_mtf_struct(mtfPivotLen, msUseClose), barmerge.gaps_off, barmerge.lookahead_off)
[ctxPdCode, ctxPdMid] = request.security(syminfo.tickerid, mtfContextTf, f_mtf_pd(mtfPivotLen), barmerge.gaps_off, barmerge.lookahead_off)
[ctxFvgDir, ctxFvgQ, ctxFvgTouch, ctxCeTap, ctxIfvgDir] = request.security(syminfo.tickerid, mtfContextTf, f_mtf_fvg(effFvgAtrMult, dispBodyAtr, dispBodyRatio, mtfPivotLen), barmerge.gaps_off, barmerge.lookahead_off)

mtfBullLiq = mtfLiqCode == 2 or mtfLiqCode == 1
mtfBearLiq = mtfLiqCode == -2 or mtfLiqCode == -1
mtfBullStruct = ctxStructDir == 1 or ctxStructEvent == 1 or ctxStructEvent == 2
mtfBearStruct = ctxStructDir == -1 or ctxStructEvent == -1 or ctxStructEvent == -2
macroBull = macroStructDir == 1
macroBear = macroStructDir == -1
mtfBullFvg = ctxFvgDir == 1 and ctxFvgQ >= mtfMinFvgQuality
mtfBearFvg = ctxFvgDir == -1 and ctxFvgQ >= mtfMinFvgQuality

mtfBullScore = useMTFBackend ? ((mtfLiqCode == 2 ? 2 : mtfLiqCode == 1 ? 1 : 0) + (ctxStructEvent == 2 ? 2 : ctxStructEvent == 1 ? 1 : ctxStructDir == 1 ? 1 : 0) + (macroBull ? 1 : 0) + (ctxPdCode == -1 ? 1 : 0) + (mtfBullFvg ? 1 : 0) + (ctxIfvgDir == 1 ? 1 : 0)) : 0
mtfBearScore = useMTFBackend ? ((mtfLiqCode == -2 ? 2 : mtfLiqCode == -1 ? 1 : 0) + (ctxStructEvent == -2 ? 2 : ctxStructEvent == -1 ? 1 : ctxStructDir == -1 ? 1 : 0) + (macroBear ? 1 : 0) + (ctxPdCode == 1 ? 1 : 0) + (mtfBearFvg ? 1 : 0) + (ctxIfvgDir == -1 ? 1 : 0)) : 0

mtfContextText = useMTFBackend ? mtfLiqTf + " " + f_liq_code_text(mtfLiqCode) + " | " + mtfContextTf + " " + f_dir_text(ctxStructDir) : "Off"
mtfDetailText = useMTFBackend ? "FVG " + f_dir_text(ctxFvgDir) + " " + f_prob(ctxFvgQ) + " | " + f_pd_text(ctxPdCode) : "Off"
// v4.6.2 color fix for MTF backend row.
color mtfContextColor462 = not useMTFBackend ? color.gray : mtfLiqCode > 0 or ctxStructDir > 0 ? color.lime : mtfLiqCode < 0 or ctxStructDir < 0 ? color.red : color.silver
color mtfDetailColor462 = not useMTFBackend ? color.gray : ctxFvgDir > 0 or ctxPdCode < 0 ? color.lime : ctxFvgDir < 0 or ctxPdCode > 0 ? color.red : color.silver



//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DWM + EMAs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dayOpen = request.security(syminfo.tickerid, "D", open, barmerge.gaps_off, barmerge.lookahead_on)
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
prevDayLow = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_on)

plot(showEMAs ? ema20 : na, "EMA 20", color=color.new(color.aqua, 0), linewidth=1)
plot(showEMAs ? ema50 : na, "EMA 50", color=color.new(color.yellow, 0), linewidth=1)
plot(showEMAs ? ema200 : na, "EMA 200", color=color.new(color.orange, 0), linewidth=2)

plot(showDWM ? dayOpen : na, "Daily Open", color=color.new(color.white, 40), linewidth=1, style=plot.style_linebr)
plot(showDWM ? prevDayHigh : na, "Previous Day High", color=color.new(color.red, 35), linewidth=1, style=plot.style_linebr)
plot(showDWM ? prevDayLow : na, "Previous Day Low", color=color.new(color.lime, 35), linewidth=1, style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Time / Volatility Regime
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

nyHour = hour(time, kzTimezone)
nyMinute = minute(time, kzTimezone)
nyMins = nyHour * 60 + nyMinute
openBlackout = nyMins >= 570 and nyMins < 570 + avoidOpenMin
closeBlackout = nyMins >= 960 - avoidCloseMin and nyMins < 960
lunchBlackout = avoidLunch and nyMins >= 690 and nyMins < 810
inBlackout = useTimeFilter and (openBlackout or closeBlackout or lunchBlackout)

volRatio = atr / math.max(atrLong, syminfo.mintick)
volCompressed = volRatio < volCompressPct
volExpanded = volRatio > volExpandPct

// v4.6.2 volatility fix: ATR ratio + short/long ATR behavior.
// The old regime stayed Normal too often across markets. This makes states more responsive.
volAtrFast462 = ta.sma(atr, 14)
volAtrSlow462 = ta.sma(atr, 100)
volAtrRatio462 = volAtrSlow462 != 0.0 ? volAtrFast462 / volAtrSlow462 : 1.0
volVeryLow462 = volAtrRatio462 < 0.72
volLow462 = volAtrRatio462 >= 0.72 and volAtrRatio462 < 0.88
volHigh462 = volAtrRatio462 > 1.18 and volAtrRatio462 <= 1.45
volExtreme462 = volAtrRatio462 > 1.45
volRegime = volVeryLow462 ? "Very Low" : volLow462 ? "Low" : volCompressed ? "Compressed" : volExtreme462 ? "Extreme" : volHigh462 ? "High" : volExpanded ? "Expanding" : "Normal"
rvolState = rvol >= 1.5 ? "High" : rvol >= effRvolMin ? "OK" : rvol >= 0.5 ? "Low" : "Dead"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Killzones
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_killzone(bool enabled, string sess, string name, color col) =>
    inSess = enabled and effShowKillzones and timeframe.isintraday and not na(time(timeframe.period, sess, kzTimezone))
    startSess = inSess and not inSess[1]
    endSess = not inSess and inSess[1]

    var box curBox = na
    var float sHigh = na
    var float sLow = na
    var array<box> boxes = array.new<box>()
    var array<line> hiLines = array.new<line>()
    var array<line> loLines = array.new<line>()

    if startSess
        sHigh := high
        sLow := low
        curBox := box.new(left=time, top=high, right=time, bottom=low, xloc=xloc.bar_time, bgcolor=color.new(col, kzTransparency), border_color=color.new(col, 55), text=name, text_color=color.new(col, 0))
        array.unshift(boxes, curBox)
        if array.size(boxes) > kzMaxDays
            old = array.pop(boxes)
            box.delete(old)

    if inSess
        sHigh := math.max(nz(sHigh, high), high)
        sLow := math.min(nz(sLow, low), low)
        if not na(curBox)
            box.set_right(curBox, time)
            box.set_top(curBox, sHigh)
            box.set_bottom(curBox, sLow)

    if endSess and kzShowHL and not na(sHigh) and not na(sLow)
        hi = line.new(time[1], sHigh, time, sHigh, xloc=xloc.bar_time, extend=extend.right, color=col, style=line.style_dotted)
        lo = line.new(time[1], sLow, time, sLow, xloc=xloc.bar_time, extend=extend.right, color=col, style=line.style_dotted)
        array.unshift(hiLines, hi)
        array.unshift(loLines, lo)
        if array.size(hiLines) > kzMaxDays
            oldH = array.pop(hiLines)
            oldL = array.pop(loLines)
            line.delete(oldH)
            line.delete(oldL)

    inSess

inAsia = f_killzone(useAsia, asiaSession, "Asia", asiaColor)
inLondon = f_killzone(useLondon, londonSession, "London", londonColor)
inNYAM = f_killzone(useNYAM, nyamSession, "NY AM", nyamColor)
inNYPM = f_killzone(useNYPM, nypmSession, "NY PM", nypmColor)

currentSession = inAsia ? "Asia" : inLondon ? "London" : inNYAM ? "NY AM" : inNYPM ? "NY PM" : "None"
killzoneActive = inLondon or inNYAM or inNYPM

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Structure: Internal + Swing BOS / CHoCH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

breakHighPrice = msUseClose ? close : high
breakLowPrice = msUseClose ? close : low

iPh = ta.pivothigh(high, internalLength, internalLength)
iPl = ta.pivotlow(low, internalLength, internalLength)
sPh = ta.pivothigh(high, effSwingLength, effSwingLength)
sPl = ta.pivotlow(low, effSwingLength, effSwingLength)

var float intHigh = na
var float intLow = na
var int intHighBar = na
var int intLowBar = na
var bool intHighLive = false
var bool intLowLive = false
var int internalTrend = 0

var float swHigh = na
var float swLow = na
var int swHighBar = na
var int swLowBar = na
var bool swHighLive = false
var bool swLowLive = false
var int swingTrend = 0

if not na(iPh)
    intHigh := iPh
    intHighBar := bar_index - internalLength
    intHighLive := true

if not na(iPl)
    intLow := iPl
    intLowBar := bar_index - internalLength
    intLowLive := true

if not na(sPh)
    swHigh := sPh
    swHighBar := bar_index - effSwingLength
    swHighLive := true

if not na(sPl)
    swLow := sPl
    swLowBar := bar_index - effSwingLength
    swLowLive := true

internalBullBreak = intHighLive and not na(intHigh) and breakHighPrice > intHigh
internalBearBreak = intLowLive and not na(intLow) and breakLowPrice < intLow
swingBullBreak = swHighLive and not na(swHigh) and breakHighPrice > swHigh
swingBearBreak = swLowLive and not na(swLow) and breakLowPrice < swLow

internalBullCHoCH = internalBullBreak and internalTrend == -1
internalBearCHoCH = internalBearBreak and internalTrend == 1
swingBullCHoCH = swingBullBreak and swingTrend == -1
swingBearCHoCH = swingBearBreak and swingTrend == 1

internalBullBOS = internalBullBreak and not internalBullCHoCH
internalBearBOS = internalBearBreak and not internalBearCHoCH
swingBullBOS = swingBullBreak and not swingBullCHoCH
swingBearBOS = swingBearBreak and not swingBearCHoCH

var string structureEvent = "None"

if internalBullBreak
    structureEvent := internalBullCHoCH ? "Int Bull CHoCH" : "Int Bull BOS"
    internalTrend := 1
    intHighLive := false

if internalBearBreak
    structureEvent := internalBearCHoCH ? "Int Bear CHoCH" : "Int Bear BOS"
    internalTrend := -1
    intLowLive := false

if swingBullBreak
    structureEvent := swingBullCHoCH ? "Swing Bull CHoCH" : "Swing Bull BOS"
    swingTrend := 1
    swHighLive := false
    if showStructure and showStructureLabels
        label.new(bar_index, swHigh, swingBullCHoCH ? "Bull CHoCH" : "Bull BOS", style=label.style_label_down, color=transparent, textcolor=bullStructureColor, size=size.small)

if swingBearBreak
    structureEvent := swingBearCHoCH ? "Swing Bear CHoCH" : "Swing Bear BOS"
    swingTrend := -1
    swLowLive := false
    if showStructure and showStructureLabels
        label.new(bar_index, swLow, swingBearCHoCH ? "Bear CHoCH" : "Bear BOS", style=label.style_label_up, color=transparent, textcolor=bearStructureColor, size=size.small)

bullStructureBreak = internalBullBreak or swingBullBreak
bearStructureBreak = internalBearBreak or swingBearBreak
bullCHoCH = internalBullCHoCH or swingBullCHoCH
bearCHoCH = internalBearCHoCH or swingBearCHoCH
bullBOS = internalBullBOS or swingBullBOS
bearBOS = internalBearBOS or swingBearBOS

f_htf_structure(_len, _useClose) =>
    ph = ta.pivothigh(high, _len, _len)
    pl = ta.pivotlow(low, _len, _len)
    var float h = na
    var float l = na
    var bool hLive = false
    var bool lLive = false
    var int dir = 0
    if not na(ph)
        h := ph
        hLive := true
    if not na(pl)
        l := pl
        lLive := true
    bH = _useClose ? close : high
    bL = _useClose ? close : low
    if hLive and not na(h) and bH > h
        dir := 1
        hLive := false
    if lLive and not na(l) and bL < l
        dir := -1
        lLive := false
    dir

htfDir = request.security(syminfo.tickerid, htfStructureTf, f_htf_structure(effSwingLength, msUseClose), barmerge.gaps_off, barmerge.lookahead_off)
htfBiasText = htfDir == 1 ? "Bullish" : htfDir == -1 ? "Bearish" : "Neutral"

haveRange = not na(swHigh) and not na(swLow)
rangeHi = haveRange ? math.max(swHigh, swLow) : na
rangeLo = haveRange ? math.min(swHigh, swLow) : na
rangeMid = haveRange ? math.avg(rangeHi, rangeLo) : na
inDiscount = haveRange and close < rangeMid
inPremium = haveRange and close > rangeMid
pdState = not haveRange ? "Unknown" : inDiscount ? "Discount" : inPremium ? "Premium" : "Equilibrium"

strongWeakState = swingTrend == 1 ? "Weak High / Strong Low" : swingTrend == -1 ? "Strong High / Weak Low" : "Unknown"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Displacement + OB Backend
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isDisp(ofs, wantBull) =>
    bodyAbs = math.abs(close[ofs] - open[ofs])
    rng = math.max(high[ofs] - low[ofs], syminfo.mintick)
    big = bodyAbs / math.max(atr, syminfo.mintick) >= dispBodyAtr
    solid = bodyAbs / rng >= dispBodyRatio
    dir = wantBull ? close[ofs] > open[ofs] : close[ofs] < open[ofs]
    big and solid and dir

curBullDisp = isDisp(0, true)
curBearDisp = isDisp(0, false)
prevBullDisp = isDisp(1, true)
prevBearDisp = isDisp(1, false)

var array<float> obTop = array.new<float>()
var array<float> obBot = array.new<float>()
var array<bool> obBull = array.new<bool>()
var array<int> obBorn = array.new<int>()

if useOB and curBullDisp
    for k = 1 to obLookback
        if close[k] < open[k]
            array.unshift(obTop, high[k])
            array.unshift(obBot, low[k])
            array.unshift(obBull, true)
            array.unshift(obBorn, bar_index - k)
            break

if useOB and curBearDisp
    for k = 1 to obLookback
        if close[k] > open[k]
            array.unshift(obTop, high[k])
            array.unshift(obBot, low[k])
            array.unshift(obBull, false)
            array.unshift(obBorn, bar_index - k)
            break

if array.size(obTop) > 20
    array.pop(obTop)
    array.pop(obBot)
    array.pop(obBull)
    array.pop(obBorn)

var float lastBullBreakerTop = na
var float lastBullBreakerBot = na
var int lastBullBreakerBorn = na
var float lastBearBreakerTop = na
var float lastBearBreakerBot = na
var int lastBearBreakerBorn = na

obRetestBull = false
obRetestBear = false
obBrokenBull = false
obBrokenBear = false

if useOB and array.size(obTop) > 0
    for i = array.size(obTop) - 1 to 0
        t = array.get(obTop, i)
        b = array.get(obBot, i)
        isB = array.get(obBull, i)
        born = array.get(obBorn, i)
        fresh = bar_index - born <= obMaxAge

        if fresh and isB and low <= t and high >= b and close > b
            obRetestBull := true
        if fresh and not isB and high >= b and low <= t and close < t
            obRetestBear := true

        broken = isB ? close < b : close > t
        if broken
            if isB
                obBrokenBull := true
                lastBullBreakerTop := t
                lastBullBreakerBot := b
                lastBullBreakerBorn := bar_index
            else
                obBrokenBear := true
                lastBearBreakerTop := t
                lastBearBreakerBot := b
                lastBearBreakerBorn := bar_index
            array.remove(obTop, i)
            array.remove(obBot, i)
            array.remove(obBull, i)
            array.remove(obBorn, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG Engine: Quality + CE + IFVG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type FvgZone
    box bx
    line mid
    float top
    float bot
    bool bull
    int born
    float q
    int state

var array<FvgZone> fvgZones = array.new<FvgZone>()

f_delete_fvg(FvgZone z) =>
    box.delete(z.bx)
    if not na(z.mid)
        line.delete(z.mid)

calcFvgQuality(fvgSize, fvgMid, isBull) =>
    sizeScore = f_clamp(fvgSize / math.max(atr, syminfo.mintick), 0.0, 2.0) / 2.0
    trendScore = isBull ? (ema20 > ema50 ? 1.0 : 0.25) : (ema20 < ema50 ? 1.0 : 0.25)
    htfScore = isBull ? (htfDir == 1 ? 1.0 : htfDir == 0 ? 0.55 : 0.20) : (htfDir == -1 ? 1.0 : htfDir == 0 ? 0.55 : 0.20)
    volScore = rvol >= 1.5 ? 1.0 : rvol >= effRvolMin ? 0.65 : 0.25
    pdScore = not haveRange ? 0.50 : isBull ? (fvgMid < rangeMid ? 1.0 : 0.25) : (fvgMid > rangeMid ? 1.0 : 0.25)
    structScore = isBull ? (bullStructureBreak ? 1.0 : 0.45) : (bearStructureBreak ? 1.0 : 0.45)
    kzScore = killzoneActive ? 0.75 : 0.45
    volRegScore = volExpanded ? 0.85 : volCompressed ? 0.25 : 0.60
    q = sizeScore * 0.16 + trendScore * 0.14 + htfScore * 0.16 + volScore * 0.12 + pdScore * 0.16 + structScore * 0.14 + kzScore * 0.06 + volRegScore * 0.06
    f_clamp(q, 0.05, 0.95)

f_add_fvg(bool isBull, float top, float bot, color col, float q) =>
    labelText = f_prob(q)
    b = box.new(left=bar_index - 2, top=top, right=bar_index + fvgExtend, bottom=bot, bgcolor=col, border_color=color.new(f_solid(col), 65), text=labelText, text_color=color.new(f_solid(col), 0), text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_top)
    line midLine = na
    if showFvgMidline
        m = math.avg(top, bot)
        midLine := line.new(bar_index - 2, m, bar_index + fvgExtend, m, color=color.new(f_solid(col), 0), style=line.style_dotted)
    z = FvgZone.new(b, midLine, top, bot, isBull, bar_index, q, 0)
    array.unshift(fvgZones, z)
    if array.size(fvgZones) > fvgMaxZones
        old = array.pop(fvgZones)
        f_delete_fvg(old)

if not showFVG and fvgClearWhenOff and barstate.islast and array.size(fvgZones) > 0
    for i = array.size(fvgZones) - 1 to 0
        oldZ = array.get(fvgZones, i)
        f_delete_fvg(oldZ)
        array.remove(fvgZones, i)

bullGap = low - high[2]
bearGap = low[2] - high

gapFilterBull = not na(high[2]) and ((bullGap / high[2]) * 100 >= fvgThreshold)
gapFilterBear = not na(low[2]) and ((bearGap / high) * 100 >= fvgThreshold)

atrFilterBull = not fvgUseATR or bullGap >= atr * effFvgAtrMult
atrFilterBear = not fvgUseATR or bearGap >= atr * effFvgAtrMult

dispFilterBull = not fvgRequireDisplacement or prevBullDisp
dispFilterBear = not fvgRequireDisplacement or prevBearDisp

bullFVG = showFVG and not na(high[2]) and low > high[2] and close[1] > high[2] and gapFilterBull and atrFilterBull and dispFilterBull
bearFVG = showFVG and not na(low[2]) and high < low[2] and close[1] < low[2] and gapFilterBear and atrFilterBear and dispFilterBear

if bullFVG
    mid = math.avg(low, high[2])
    q = calcFvgQuality(bullGap, mid, true)
    f_add_fvg(true, low, high[2], bullFvgColor, q)

if bearFVG
    mid = math.avg(low[2], high)
    q = calcFvgQuality(bearGap, mid, false)
    f_add_fvg(false, low[2], high, bearFvgColor, q)

priceInBullFVG = false
priceInBearFVG = false
bullCETap = false
bearCETap = false
bullIFVG = false
bearIFVG = false
activeBullFVGs = 0
activeBearFVGs = 0
bestBullFvgQ = 0.0
bestBearFvgQ = 0.0
bullFvgMitigatedNow = false
bearFvgMitigatedNow = false

if showFVG and array.size(fvgZones) > 0
    for i = array.size(fvgZones) - 1 to 0
        z = array.get(fvgZones, i)

        box.set_right(z.bx, bar_index + fvgExtend)
        if not na(z.mid)
            line.set_x2(z.mid, bar_index + fvgExtend)

        overlaps = high >= z.bot and low <= z.top
        midNow = math.avg(z.top, z.bot)

        if overlaps
            if z.bull
                priceInBullFVG := true
                bestBullFvgQ := math.max(bestBullFvgQ, z.q)
            else
                priceInBearFVG := true
                bestBearFvgQ := math.max(bestBearFvgQ, z.q)

        ceTap = z.bull ? low <= midNow : high >= midNow
        if ceTap and z.state == 0
            z.state := 1
            if z.bull
                bullCETap := true
            else
                bearCETap := true

        if fvgShrinkOnFill and overlaps and z.state != 3
            if z.bull and low < z.top and low > z.bot
                z.top := low
                box.set_top(z.bx, z.top)
            if not z.bull and high > z.bot and high < z.top
                z.bot := high
                box.set_bottom(z.bx, z.bot)
            if not na(z.mid)
                nm = math.avg(z.top, z.bot)
                line.set_y1(z.mid, nm)
                line.set_y2(z.mid, nm)

        fullFill = z.bull ? low <= z.bot : high >= z.top
        closeThrough = z.bull ? close < z.bot : close > z.top
        ifvgDispOk = not ifvgReqDisplacement or (z.bull ? curBearDisp : curBullDisp)
        ifvgStructOk = not ifvgReqStructure or (z.bull ? bearStructureBreak : bullStructureBreak)
        validIFVG = trackIFVG and fullFill and closeThrough and ifvgDispOk and ifvgStructOk and z.state != 3

        mitigated = fvgInvalidation == "Any Touch" ? overlaps : fvgInvalidation == "Midpoint Touch" ? ceTap : fvgInvalidation == "Close Through" ? closeThrough : fullFill
        expired = bar_index - z.born > fvgMaxAge

        if validIFVG
            z.bull := not z.bull
            z.state := 3
            if z.bull
                bullIFVG := true
                box.set_bgcolor(z.bx, ifvgBullColor)
                box.set_border_color(z.bx, color.new(f_solid(ifvgBullColor), 40))
            else
                bearIFVG := true
                box.set_bgcolor(z.bx, ifvgBearColor)
                box.set_border_color(z.bx, color.new(f_solid(ifvgBearColor), 40))
            box.set_text(z.bx, "IFVG " + f_prob(z.q))
            array.set(fvgZones, i, z)
        else if mitigated or expired
            bullFvgMitigatedNow := z.bull and mitigated
            bearFvgMitigatedNow := (not z.bull) and mitigated
            f_delete_fvg(z)
            array.remove(fvgZones, i)
        else
            array.set(fvgZones, i, z)
            if z.bull
                activeBullFVGs += 1
            else
                activeBearFVGs += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Liquidity Pools
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

type LiqData
    float h
    float t
    float b
    float l
    int bi

type LiqZone
    box bx
    line ln
    label lab
    float vol
    bool buySide
    bool swept

liqVolSize = f_size(liqVolSizeInput)
liqInvis = color.rgb(0, 0, 0, 100)

liqTop = math.max(open, close)
liqBot = math.min(open, close)
liqCur = LiqData.new(high, liqTop, liqBot, low, bar_index)

var LiqData hst = LiqData.new(high, liqTop, liqBot, low, bar_index)
var LiqData lst = LiqData.new(high, liqTop, liqBot, low, bar_index)

var int hCount = 0
var int lCount = 0
var int lastHighWick = bar_index
var int lastLowWick = bar_index
var int bsHighWick = 0
var int bsLowWick = 0
var float hiVol = 0.0
var float loVol = 0.0
var int lastBSLLeft = na
var int lastSSLLeft = na

var array<LiqZone> bslZones = array.new<LiqZone>()
var array<LiqZone> sslZones = array.new<LiqZone>()

f_del_liq(LiqZone z) =>
    box.delete(z.bx)
    line.delete(z.ln)
    if not na(z.lab)
        label.delete(z.lab)

f_add_liq(bool buySide, int leftBar, float top, float bot, float vol) =>
    col = buySide ? liqBearColor : liqBullColor
    lvl = buySide ? bot : top
    tag = buySide ? "BSL" : "SSL"
    bx = box.new(left=leftBar, top=top, right=bar_index, bottom=bot, bgcolor=col, border_color=color.new(f_solid(col), 85))
    ln = line.new(leftBar, lvl, bar_index, lvl, color=color.new(f_solid(col), 0), style=line.style_dotted)
    txt = liqShowVolLabels ? tag + " " + str.tostring(vol, format.volume) : tag
    lb = label.new(bar_index, lvl, txt, color=liqInvis, textcolor=color.new(f_solid(col), 0), style=label.style_label_right, size=liqVolSize, textalign=text.align_right)
    z = LiqZone.new(bx, ln, lb, vol, buySide, false)
    if buySide
        array.unshift(bslZones, z)
        if array.size(bslZones) > liqMaxZones
            old = array.pop(bslZones)
            f_del_liq(old)
    else
        array.unshift(sslZones, z)
        if array.size(sslZones) > liqMaxZones
            old = array.pop(sslZones)
            f_del_liq(old)

if showLiquidity
    if (high > hst.h) and ((liqTop > hst.h) or (liqTop < hst.t))
        if hCount > 1
            lst := liqCur
            loVol := 0
            lCount := 0
        hst := liqCur
        hiVol := 0
        hCount := 1
        lastHighWick := bar_index

    if (low < lst.l) and ((liqBot < lst.l) or (liqBot > lst.b))
        if lCount > 1
            hst := liqCur
            hiVol := 0
            hCount := 0
        lst := liqCur
        loVol := 0
        lCount := 1
        lastLowWick := bar_index

    h_wick = high > hst.t and liqTop <= hst.t
    l_wick = low < lst.b and liqBot >= lst.b

    if h_wick[1] and hst.t[1] == hst.t[2] and bsHighWick > effLiqGap
        hCount += 1
        lastHighWick := bar_index[1]

    if l_wick[1] and lst.b[1] == lst.b[2] and bsLowWick > effLiqGap
        lCount += 1
        lastLowWick := bar_index[1]

    bsHighWick := math.abs(lastHighWick - bar_index)
    bsLowWick := math.abs(lastLowWick - bar_index)

    if high > hst.h
        hst.h := high

    if low < lst.l
        lst.l := low

    rng = math.max(high - low, syminfo.mintick)
    hiVol += nz((math.max(high - hst.t, 0) / rng) * volume)
    loVol += nz((math.max(lst.b - low, 0) / rng) * volume)

    makeBSL = hCount >= liqContactAmount and ta.crossover(bsHighWick, effLiqWait) and close < hst.t and hst.bi != lastBSLLeft
    if makeBSL
        f_add_liq(true, hst.bi, hst.h, hst.t, hiVol)
        lastBSLLeft := hst.bi

    makeSSL = lCount >= liqContactAmount and ta.crossover(bsLowWick, effLiqWait) and close > lst.b and lst.bi != lastSSLLeft
    if makeSSL
        f_add_liq(false, lst.bi, lst.b, lst.l, loVol)
        lastSSLLeft := lst.bi

bullLiquiditySweep = false
bearLiquiditySweep = false
var string lastLiqEvent = "None"

if showLiquidity and array.size(bslZones) > 0
    for i = array.size(bslZones) - 1 to 0
        z = array.get(bslZones, i)
        top = box.get_top(z.bx)
        bot = box.get_bottom(z.bx)
        lvl = bot

        box.set_right(z.bx, bar_index)
        line.set_x2(z.ln, bar_index)

        if not na(z.lab)
            label.set_x(z.lab, bar_index)
            label.set_y(z.lab, lvl)
            label.set_text(z.lab, liqShowVolLabels ? "BSL " + str.tostring(z.vol, format.volume) : "BSL")

        sweep = liqSweepConfirm == "Close Through Zone" ? (high > top and close < bot) : (high > top and close < top)

        if sweep and not z.swept
            bearLiquiditySweep := true
            z.swept := true
            lastLiqEvent := "BSL Sweep"
            if liqShowSweepLabels
                label.new(bar_index, high, "BSL Sweep", style=label.style_label_down, color=transparent, textcolor=bearStructureColor, size=size.tiny)

        delZone = (liqDeleteMode == "On Sweep" and sweep) or (liqDeleteMode == "On Break" and close > top)
        array.set(bslZones, i, z)
        if delZone
            f_del_liq(z)
            array.remove(bslZones, i)

if showLiquidity and array.size(sslZones) > 0
    for i = array.size(sslZones) - 1 to 0
        z = array.get(sslZones, i)
        top = box.get_top(z.bx)
        bot = box.get_bottom(z.bx)
        lvl = top

        box.set_right(z.bx, bar_index)
        line.set_x2(z.ln, bar_index)

        if not na(z.lab)
            label.set_x(z.lab, bar_index)
            label.set_y(z.lab, lvl)
            label.set_text(z.lab, liqShowVolLabels ? "SSL " + str.tostring(z.vol, format.volume) : "SSL")

        sweep = liqSweepConfirm == "Close Through Zone" ? (low < bot and close > top) : (low < bot and close > bot)

        if sweep and not z.swept
            bullLiquiditySweep := true
            z.swept := true
            lastLiqEvent := "SSL Sweep"
            if liqShowSweepLabels
                label.new(bar_index, low, "SSL Sweep", style=label.style_label_up, color=transparent, textcolor=bullStructureColor, size=size.tiny)

        delZone = (liqDeleteMode == "On Sweep" and sweep) or (liqDeleteMode == "On Break" and close < bot)
        array.set(sslZones, i, z)
        if delZone
            f_del_liq(z)
            array.remove(sslZones, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Opening Range Backend
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inOR = not na(time(timeframe.period, orSession, kzTimezone))
var float orHigh = na
var float orLow = na
var line orHighLine = na
var line orLowLine = na

if inOR and not inOR[1]
    orHigh := high
    orLow := low

if inOR
    orHigh := math.max(nz(orHigh, high), high)
    orLow := math.min(nz(orLow, low), low)

if showOR and barstate.islast and not na(orHigh) and not na(orLow)
    line.delete(orHighLine)
    line.delete(orLowLine)
    orHighLine := line.new(bar_index - 100, orHigh, bar_index + 20, orHigh, color=orColor, style=line.style_solid, extend=extend.right)
    orLowLine := line.new(bar_index - 100, orLow, bar_index + 20, orLow, color=orColor, style=line.style_solid, extend=extend.right)

orBreakUp = useORBackend and not inOR and not na(orHigh) and close > orHigh
orBreakDown = useORBackend and not inOR and not na(orLow) and close < orLow
orState = inOR ? "Building" : orBreakUp ? "Above OR" : orBreakDown ? "Below OR" : "Inside/None"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Profile Backend: POC / VAH / VAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var array<float> vpVols = array.new_float()
if barstate.isfirst
    for i = 0 to vpBins - 1
        array.push(vpVols, 0.0)

var float vpPoc = na
var float vpVah = na
var float vpVal = na
var string vpState = "Off"

if useVP and barstate.islast
    array.fill(vpVols, 0.0)
    lb = math.min(vpLookback, bar_index + 1)
    vpHi = ta.highest(high, vpLookback)
    vpLo = ta.lowest(low, vpLookback)
    step = math.max((vpHi - vpLo) / math.max(vpBins - 1, 1), syminfo.mintick)

    for i = 0 to lb - 1
        idxRaw = int(math.floor((hlc3[i] - vpLo) / step))
        idx = math.max(0, math.min(vpBins - 1, idxRaw))
        array.set(vpVols, idx, array.get(vpVols, idx) + volume[i])

    maxVol = array.max(vpVols)
    pocIdx = array.indexof(vpVols, maxVol)
    vpPoc := vpLo + step * pocIdx

    totalVol = array.sum(vpVols)
    vaTarget = totalVol * vpValueAreaPct / 100.0
    vaSum = maxVol
    up = pocIdx
    dn = pocIdx

    while vaSum < vaTarget and (up < vpBins - 1 or dn > 0)
        upVol = up < vpBins - 1 ? array.get(vpVols, up + 1) : 0.0
        dnVol = dn > 0 ? array.get(vpVols, dn - 1) : 0.0
        if upVol >= dnVol and up < vpBins - 1
            up += 1
            vaSum += upVol
        else if dn > 0
            dn -= 1
            vaSum += dnVol
        else
            break

    vpVah := vpLo + step * up
    vpVal := vpLo + step * dn
    vpState := close > vpVah ? "Above VAH" : close < vpVal ? "Below VAL" : close > vpPoc ? "Above POC" : close < vpPoc ? "Below POC" : "At POC"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trendlines With Breaks
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tlPh = ta.pivothigh(high, tlLength, tlLength)
tlPl = ta.pivotlow(low, tlLength, tlLength)

tlSlope = tlCalcMethod == "Atr" ? ta.atr(tlLength) / tlLength * tlSlopeMult : tlCalcMethod == "Stdev" ? ta.stdev(close, tlLength) / tlLength * tlSlopeMult : math.abs(ta.sma(close * bar_index, tlLength) - ta.sma(close, tlLength) * ta.sma(bar_index, tlLength)) / ta.variance(bar_index, tlLength) / 2 * tlSlopeMult

var float tlUpper = na
var float tlLower = na
var float tlSlopeHigh = na
var float tlSlopeLow = na
var int tlUpState = 0
var int tlDownState = 0

if not na(tlPh)
    tlSlopeHigh := tlSlope
    tlUpper := tlPh
else if not na(tlUpper) and not na(tlSlopeHigh)
    tlUpper := tlUpper - tlSlopeHigh

if not na(tlPl)
    tlSlopeLow := tlSlope
    tlLower := tlPl
else if not na(tlLower) and not na(tlSlopeLow)
    tlLower := tlLower + tlSlopeLow

tlUpState := not na(tlPh) ? 0 : (not na(tlUpper) and not na(tlSlopeHigh) and close > tlUpper - tlSlopeHigh * tlLength ? 1 : tlUpState)
tlDownState := not na(tlPl) ? 0 : (not na(tlLower) and not na(tlSlopeLow) and close < tlLower + tlSlopeLow * tlLength ? 1 : tlDownState)

trendUpBreak = showTrendlines and tlUpState > nz(tlUpState[1])
trendDownBreak = showTrendlines and tlDownState > nz(tlDownState[1])

tlOffset = tlBackpaint ? tlLength : 0
upperPlot = showTrendlines ? (tlBackpaint ? tlUpper : tlUpper - tlSlopeHigh * tlLength) : na
lowerPlot = showTrendlines ? (tlBackpaint ? tlLower : tlLower + tlSlopeLow * tlLength) : na

plot(upperPlot, "Upper TL", color=showTrendlines ? tlUpColor : na, offset=-tlOffset)
plot(lowerPlot, "Lower TL", color=showTrendlines ? tlDownColor : na, offset=-tlOffset)

plotshape(tlShowBreaks and trendUpBreak ? low : na, "Upper Break", shape.labelup, location.absolute, tlUpColor, text="B", textcolor=color.white, size=size.tiny)
plotshape(tlShowBreaks and trendDownBreak ? high : na, "Lower Break", shape.labeldown, location.absolute, tlDownColor, text="B", textcolor=color.white, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Confluence + Dynamic Rule Engine
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendFilterBull = close > ema50 and ema50 > ema200
trendFilterBear = close < ema50 and ema50 < ema200

dwmBull = includeDWMInScore and showDWM ? ((close > dayOpen ? 1 : 0) + (not na(prevDayHigh) and close > prevDayHigh ? 1 : 0)) : 0
dwmBear = includeDWMInScore and showDWM ? ((close < dayOpen ? 1 : 0) + (not na(prevDayLow) and close < prevDayLow ? 1 : 0)) : 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// v4.6 Premium Brain
// Compact hidden data layer. No visual changes.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

brainSource43 = close

// Squeeze / Momentum engine, compressed from LazyBear-style squeeze logic.
momLen43 = isCrypto ? 18 : isForex ? 20 : 20
bbLen43 = momLen43
kcLen43 = momLen43
bbMult43 = 2.0
kcMult43 = isCrypto ? 1.35 : 1.50

bbBasis43 = ta.sma(brainSource43, bbLen43)
bbDev43 = bbMult43 * ta.stdev(brainSource43, bbLen43)
bbUpper43 = bbBasis43 + bbDev43
bbLower43 = bbBasis43 - bbDev43

kcBasis43 = ta.sma(brainSource43, kcLen43)
kcRange43 = ta.sma(ta.tr(true), kcLen43)
kcUpper43 = kcBasis43 + kcRange43 * kcMult43
kcLower43 = kcBasis43 - kcRange43 * kcMult43

sqzOn43 = bbLower43 > kcLower43 and bbUpper43 < kcUpper43
sqzOff43 = bbLower43 < kcLower43 and bbUpper43 > kcUpper43
momBase43 = brainSource43 - math.avg(math.avg(ta.highest(high, momLen43), ta.lowest(low, momLen43)), ta.sma(brainSource43, momLen43))
momOsc43 = ta.linreg(momBase43, momLen43, 0)
momSig43 = ta.sma(momOsc43, 5)
momStrength43 = momOsc43 - momSig43
momBull43 = useMomentumBrain43 and momOsc43 > momSig43 and momStrength43 > 0
momBear43 = useMomentumBrain43 and momOsc43 < momSig43 and momStrength43 < 0
momExpansion43 = useMomentumBrain43 and sqzOff43 and not sqzOn43

// ADX / DI trend strength engine.
[diPlus43, diMinus43, adx43] = ta.dmi(14, 14)
trendStrong43 = useTrendBrain43 and adx43 >= (isForex ? 18 : isCrypto ? 20 : 22)
trendBull43 = trendStrong43 and diPlus43 > diMinus43
trendBear43 = trendStrong43 and diMinus43 > diPlus43
trendChop43 = useTrendBrain43 and adx43 < (isForex ? 15 : 18)

// VWAP deviation engine. Backend only.
vwap43 = ta.vwap(hlc3)
vwapDev43 = ta.stdev(hlc3 - vwap43, 50)
vwapZ43 = vwapDev43 == 0.0 ? 0.0 : (close - vwap43) / vwapDev43
vwapBull43 = useVwapBrain43 and close > vwap43
vwapBear43 = useVwapBrain43 and close < vwap43
vwapOverHigh43 = useVwapBrain43 and vwapZ43 > 2.0
vwapOverLow43 = useVwapBrain43 and vwapZ43 < -2.0
vwapState43 = not useVwapBrain43 ? "Off" : vwapOverHigh43 ? "VWAP High Ext" : vwapOverLow43 ? "VWAP Low Ext" : vwapBull43 ? "Above VWAP" : vwapBear43 ? "Below VWAP" : "At VWAP"

// Volume pressure engine. Uses candle-position volume split, compressed.
range43 = math.max(high - low, syminfo.mintick)
buyVol43 = volume * (close - low) / range43
sellVol43 = volume - buyVol43
buyPct43 = volume == 0 ? 50.0 : buyVol43 / volume * 100.0
sellPct43 = 100.0 - buyPct43
deltaBull43 = useVolumeBrain43 and buyPct43 >= 55.0
deltaBear43 = useVolumeBrain43 and sellPct43 >= 55.0
deltaState43 = not useVolumeBrain43 ? "Off" : deltaBull43 ? "Buy Pressure" : deltaBear43 ? "Sell Pressure" : "Balanced"

// Auto-threshold modifier. Market type + regime, not one dumb fixed number.
baseThreshold43 = isCrypto ? 3 : isForex ? 5 : isStocks ? 5 : isFut ? 5 : confluenceThreshold
thresholdAdj43 = 0
thresholdAdj43 += volCompressed ? 1 : 0
thresholdAdj43 += trendChop43 ? 1 : 0
thresholdAdj43 += rvol < effRvolMin ? 1 : 0
thresholdAdj43 += momExpansion43 ? -1 : 0
thresholdAdj43 += trendStrong43 ? -1 : 0
effConfluenceAuto = useBrain43 and useAutoThreshold43 ? int(f_clamp(baseThreshold43 + thresholdAdj43, 3, 8)) : effConfluence

brainBull43 = (momBull43 ? 1 : 0) + (trendBull43 ? 1 : 0) + (vwapBull43 and not vwapOverHigh43 ? 1 : 0) + (deltaBull43 ? 1 : 0) + (momExpansion43 and momBull43 ? 1 : 0)
brainBear43 = (momBear43 ? 1 : 0) + (trendBear43 ? 1 : 0) + (vwapBear43 and not vwapOverLow43 ? 1 : 0) + (deltaBear43 ? 1 : 0) + (momExpansion43 and momBear43 ? 1 : 0)

brainState43 = not useBrain43 ? "Brain Off" : brainBull43 > brainBear43 ? "Brain Bull " + str.tostring(brainBull43) + "/5" : brainBear43 > brainBull43 ? "Brain Bear " + str.tostring(brainBear43) + "/5" : "Brain Mixed"
momState43 = not useMomentumBrain43 ? "Mom Off" : sqzOn43 ? "Squeeze" : momBull43 ? "Bull Momentum" : momBear43 ? "Bear Momentum" : "Momentum Flat"

bullFvgActive = priceInBullFVG or bullIFVG or (activeBullFVGs > 0 and bestBullFvgQ >= 0.55)
bearFvgActive = priceInBearFVG or bearIFVG or (activeBearFVGs > 0 and bestBearFvgQ >= 0.55)

bullObActive = obRetestBull and not obBrokenBull
bearObActive = obRetestBear and not obBrokenBear

// v4.6 Weighted Market Sentiment Aggregator
// Uses existing brain variables. No extra visuals beyond dashboard row.
W_STRUCT43 = 3.0
W_LIQ43 = 3.0
W_PD43 = 1.0
W_MOM43 = 2.0
W_TREND43 = 1.0
W_VWAP43 = 1.0
W_FLOW43 = 2.0
W_SESSION43 = 1.0

sentBull43 = 0.0
sentBear43 = 0.0

// 1. Market structure vote
if swingTrend == 1 or htfDir == 1 or macroStructDir == 1
    sentBull43 += W_STRUCT43
if swingTrend == -1 or htfDir == -1 or macroStructDir == -1
    sentBear43 += W_STRUCT43

// 2. Liquidity vote
if bullLiquiditySweep or cryptoSweepBull
    sentBull43 += W_LIQ43
if bearLiquiditySweep or cryptoSweepBear
    sentBear43 += W_LIQ43

// 3. OB / FVG / premium-discount vote
if inDiscount or bullFvgActive or bullObActive
    sentBull43 += W_PD43
if inPremium or bearFvgActive or bearObActive
    sentBear43 += W_PD43

// 4. Momentum vote
if momBull43 and not sqzOn43
    sentBull43 += W_MOM43
if momBear43 and not sqzOn43
    sentBear43 += W_MOM43

// 5. ADX / DI trend vote, only when trend is strong enough
if trendStrong43
    if diPlus43 > diMinus43
        sentBull43 += W_TREND43
    else
        sentBear43 += W_TREND43

// 6. VWAP context vote
if vwapBull43 and not vwapOverHigh43
    sentBull43 += W_VWAP43
if vwapBear43 and not vwapOverLow43
    sentBear43 += W_VWAP43

// 7. Volume pressure vote
if deltaBull43
    sentBull43 += W_FLOW43
if deltaBear43
    sentBear43 += W_FLOW43

// 8. Session / participation vote
preSide43 = sentBull43 > sentBear43 ? 1 : sentBear43 > sentBull43 ? -1 : 0
if killzoneActive and preSide43 == 1
    sentBull43 += W_SESSION43
if killzoneActive and preSide43 == -1
    sentBear43 += W_SESSION43

sentTotal43 = sentBull43 + sentBear43
sentBullPct43 = sentTotal43 > 0 ? sentBull43 / sentTotal43 * 100.0 : 50.0
sentBar43 = f_sentiment_bar(sentBullPct43)
sentColor43 = sentBullPct43 > 60 ? color.new(color.green, 10) : sentBullPct43 < 40 ? color.new(color.red, 10) : color.gray
sentText43 = str.tostring(sentBullPct43, "#") + "% Bull | " + str.tostring(100 - sentBullPct43, "#") + "% Bear"

sessionPoint = effShowKillzones and killzoneActive ? 1 : 0
rvolPoint = rvol >= effRvolMin ? 1 : 0
volPoint = volExpanded ? 1 : volCompressed ? -1 : 0

bullScore = (priceInBullFVG ? 1 : 0) + (bestBullFvgQ >= 0.65 ? 2 : bestBullFvgQ >= 0.45 ? 1 : 0) + (bullStructureBreak ? 2 : 0) + (bullCHoCH ? 2 : 0) + (bullLiquiditySweep ? 2 : 0) + (trendUpBreak ? 1 : 0) + (trendFilterBull ? 1 : 0) + (htfDir == 1 ? 1 : 0) + (inDiscount ? 1 : 0) + (obRetestBull ? 1 : 0) + (bullIFVG ? 1 : 0) + sessionPoint + dwmBull + rvolPoint + volPoint + mtfBullScore

bearScore = (priceInBearFVG ? 1 : 0) + (bestBearFvgQ >= 0.65 ? 2 : bestBearFvgQ >= 0.45 ? 1 : 0) + (bearStructureBreak ? 2 : 0) + (bearCHoCH ? 2 : 0) + (bearLiquiditySweep ? 2 : 0) + (trendDownBreak ? 1 : 0) + (trendFilterBear ? 1 : 0) + (htfDir == -1 ? 1 : 0) + (inPremium ? 1 : 0) + (obRetestBear ? 1 : 0) + (bearIFVG ? 1 : 0) + sessionPoint + dwmBear + rvolPoint + volPoint + mtfBearScore

maxScore = useMTFBackend ? 23 : 15
bias = bullScore >= bearScore + 2 ? "Bullish" : bearScore >= bullScore + 2 ? "Bearish" : "Neutral"

longConfluence = bullScore >= effConfluenceAuto and bullScore > bearScore
shortConfluence = bearScore >= effConfluenceAuto and bearScore > bullScore

conflict = (useMTFBackend and macroStructDir == 1 and swingTrend == -1) ? "4H Bull vs LTF Bear" : (useMTFBackend and macroStructDir == -1 and swingTrend == 1) ? "4H Bear vs LTF Bull" : (htfDir == 1 and swingTrend == -1) ? "HTF Bull vs LTF Bear" : (htfDir == -1 and swingTrend == 1) ? "HTF Bear vs LTF Bull" : (bullScore >= effConfluenceAuto and bearScore >= effConfluenceAuto) ? "Two-Sided Conflict" : "None"

marketBad = inBlackout or (volCompressed and rvol < effRvolMin and not momExpansion43)
side43 = bullScore > bearScore ? 1 : bearScore > bullScore ? -1 : 0
activeScore43 = side43 == 1 ? bullScore + brainBull43 : side43 == -1 ? bearScore + brainBear43 : math.max(bullScore, bearScore)
oppositeBrain43 = side43 == 1 ? brainBear43 : side43 == -1 ? brainBull43 : math.max(brainBull43, brainBear43)

longTrapRisk43 = side43 == 1 and (bearLiquiditySweep or bearStructureBreak or (vwapBear43 and momBear43) or oppositeBrain43 >= 3)
shortTrapRisk43 = side43 == -1 and (bullLiquiditySweep or bullStructureBreak or (vwapBull43 and momBull43) or oppositeBrain43 >= 3)
trapRisk43 = useBrain43 and (longTrapRisk43 or shortTrapRisk43)

quality = marketBad ? "No Trade" : trapRisk43 ? "Trap Risk" : activeScore43 >= 13 ? "A+" : activeScore43 >= 11 ? "A" : activeScore43 >= 8 ? "B" : activeScore43 >= 6 ? "C" : activeScore43 >= effConfluenceAuto ? "D" : "No Trade"
qualityDetail43 = quality == "A+" ? "Premium Setup" : quality == "A" ? "Clean Setup" : quality == "B" ? "Wait Retest" : quality == "C" ? "Risky Valid" : quality == "D" ? "Weak Edge" : quality == "Trap Risk" ? "Opposite Reclaim" : "Conflict / Chop"

bullBreakoutNow = bullBOS or trendUpBreak or orBreakUp
bearBreakoutNow = bearBOS or trendDownBreak or orBreakDown
bullSweepSetup = bullLiquiditySweep or str.contains(lastLiqEvent, "SSL")
bearSweepSetup = bearLiquiditySweep or str.contains(lastLiqEvent, "BSL")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// v4.6 Premium Backend: staged liquidity, S/D, breakers, S/R, volume break,
// BTC cycle context, and RellQuantBrain IT3 router.
// Backend deep. Dashboard clear. Chart clean.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Liquidity staged awareness
// v4.6.2 fix: box-array liquidity can be empty when drawings are hidden/trimmed.
// This fallback uses confirmed swing/pivot + DWM context so the dashboard does not get stuck on No Zones.
bool sslBoxArea46 = array.size(sslZones) > 0
bool bslBoxArea46 = array.size(bslZones) > 0
bool sslSwingArea462 = not na(swLow) or not na(prevDayLow)
bool bslSwingArea462 = not na(swHigh) or not na(prevDayHigh)
bool sslArea46 = sslBoxArea46 or sslSwingArea462
bool bslArea46 = bslBoxArea46 or bslSwingArea462
bool sslNearby46 = false
bool bslNearby46 = false
bool sslReaction46 = false
bool bslReaction46 = false

if sslBoxArea46
    for i = 0 to array.size(sslZones) - 1
        z = array.get(sslZones, i)
        zTop = box.get_top(z.bx)
        zBot = box.get_bottom(z.bx)
        zTouch = high >= zBot and low <= zTop
        zDist = close > zTop ? close - zTop : close < zBot ? zBot - close : 0.0
        sslReaction46 := sslReaction46 or zTouch
        sslNearby46 := sslNearby46 or (zDist <= atr * 0.75)

if bslBoxArea46
    for i = 0 to array.size(bslZones) - 1
        z = array.get(bslZones, i)
        zTop = box.get_top(z.bx)
        zBot = box.get_bottom(z.bx)
        zTouch = high >= zBot and low <= zTop
        zDist = close > zTop ? close - zTop : close < zBot ? zBot - close : 0.0
        bslReaction46 := bslReaction46 or zTouch
        bslNearby46 := bslNearby46 or (zDist <= atr * 0.75)

// Swing / DWM liquidity fallback
float sslRef462 = not na(swLow) ? swLow : prevDayLow
float bslRef462 = not na(swHigh) ? swHigh : prevDayHigh
bool sslSwingNearby462 = not na(sslRef462) and close > sslRef462 and (close - sslRef462) <= atr * 1.25
bool bslSwingNearby462 = not na(bslRef462) and close < bslRef462 and (bslRef462 - close) <= atr * 1.25
bool sslSwingReaction462 = not na(sslRef462) and low <= sslRef462 + atr * 0.15 and close > sslRef462
bool bslSwingReaction462 = not na(bslRef462) and high >= bslRef462 - atr * 0.15 and close < bslRef462

sslNearby46 := sslNearby46 or sslSwingNearby462
bslNearby46 := bslNearby46 or bslSwingNearby462
sslReaction46 := sslReaction46 or sslSwingReaction462
bslReaction46 := bslReaction46 or bslSwingReaction462

string liqState = bullLiquiditySweep ? "SSL Swept" : bearLiquiditySweep ? "BSL Swept" : sslReaction46 ? "SSL Reaction" : bslReaction46 ? "BSL Reaction" : sslNearby46 ? "SSL Nearby" : bslNearby46 ? "BSL Nearby" : sslArea46 ? "SSL Area Below" : bslArea46 ? "BSL Area Above" : "No Zones"
color liqStateColor46 = bullLiquiditySweep or sslReaction46 or sslNearby46 or (sslArea46 and not bslArea46) ? color.lime : bearLiquiditySweep or bslReaction46 or bslNearby46 or (bslArea46 and not sslArea46) ? color.red : sslArea46 or bslArea46 ? color.orange : color.silver

// Supply / demand backend-only intelligence
bool demandReaction46 = obRetestBull or priceInBullFVG or bullCETap or bullIFVG
bool supplyReaction46 = obRetestBear or priceInBearFVG or bearCETap or bearIFVG
bool demandBroken46 = obBrokenBull
bool supplyBroken46 = obBrokenBear
bool demandNearby46 = demandReaction46 or (not na(swLow) and math.abs(close - swLow) <= atr * 1.25) or inDiscount
bool supplyNearby46 = supplyReaction46 or (not na(swHigh) and math.abs(close - swHigh) <= atr * 1.25) or inPremium
int demandStrength46 = int(math.min(10, (demandReaction46 ? 3 : 0) + (bullLiquiditySweep ? 2 : 0) + (inDiscount ? 1 : 0) + (htfDir == 1 ? 2 : 0) + (rvol >= effRvolMin ? 1 : 0) + (priceInBullFVG ? 1 : 0)))
int supplyStrength46 = int(math.min(10, (supplyReaction46 ? 3 : 0) + (bearLiquiditySweep ? 2 : 0) + (inPremium ? 1 : 0) + (htfDir == -1 ? 2 : 0) + (rvol >= effRvolMin ? 1 : 0) + (priceInBearFVG ? 1 : 0)))
string sdState46 = demandBroken46 ? "Demand Broken" : supplyBroken46 ? "Supply Broken" : demandReaction46 ? "Demand " + str.tostring(demandStrength46) + "/10 Reaction" : supplyReaction46 ? "Supply " + str.tostring(supplyStrength46) + "/10 Reaction" : demandNearby46 ? "Demand " + str.tostring(demandStrength46) + "/10 Nearby" : supplyNearby46 ? "Supply " + str.tostring(supplyStrength46) + "/10 Nearby" : "No S/D"
color sdColor46 = demandReaction46 or demandNearby46 ? color.lime : supplyReaction46 or supplyNearby46 ? color.red : color.silver

// Breaker block backend from failed order blocks
bool bullBreakerRetest46 = not na(lastBearBreakerTop) and (bar_index - nz(lastBearBreakerBorn, bar_index)) <= obMaxAge and high >= lastBearBreakerBot and low <= lastBearBreakerTop and close > lastBearBreakerBot
bool bearBreakerRetest46 = not na(lastBullBreakerTop) and (bar_index - nz(lastBullBreakerBorn, bar_index)) <= obMaxAge and high >= lastBullBreakerBot and low <= lastBullBreakerTop and close < lastBullBreakerTop
string breakerState46 = bullBreakerRetest46 ? "Bull Breaker Retest" : bearBreakerRetest46 ? "Bear Breaker Retest" : obBrokenBear ? "Bear OB Failed" : obBrokenBull ? "Bull OB Failed" : "No Breaker"
color breakerColor46 = bullBreakerRetest46 or obBrokenBear ? color.lime : bearBreakerRetest46 or obBrokenBull ? color.red : color.silver

// Support / resistance channel backend
float srBand46 = atr * 0.35
bool inSupportChannel46 = not na(swLow) and low <= swLow + srBand46 and high >= swLow - srBand46
bool inResistanceChannel46 = not na(swHigh) and high >= swHigh - srBand46 and low <= swHigh + srBand46
bool supportBroken46 = not na(swLow) and close < swLow - srBand46
bool resistanceBroken46 = not na(swHigh) and close > swHigh + srBand46
int supportStrength46 = int(math.min(10, (inSupportChannel46 ? 3 : 0) + (sslArea46 ? 1 : 0) + (inDiscount ? 2 : 0) + (htfDir == 1 ? 2 : 0) + (rvol >= effRvolMin ? 1 : 0)))
int resistanceStrength46 = int(math.min(10, (inResistanceChannel46 ? 3 : 0) + (bslArea46 ? 1 : 0) + (inPremium ? 2 : 0) + (htfDir == -1 ? 2 : 0) + (rvol >= effRvolMin ? 1 : 0)))
string srState46 = supportBroken46 ? "Support Broken" : resistanceBroken46 ? "Resistance Broken" : inSupportChannel46 ? "In Support Channel " + str.tostring(supportStrength46) + "/10" : inResistanceChannel46 ? "In Resistance Channel " + str.tostring(resistanceStrength46) + "/10" : "No S/R"
color srColor46 = inSupportChannel46 ? color.lime : inResistanceChannel46 ? color.red : color.silver

// Volume-confirmed breakout filter
bool volBreakUp46 = resistanceBroken46 and rvol >= effRvolMin and (volExpanded or volume > volMa)
bool volBreakDown46 = supportBroken46 and rvol >= effRvolMin and (volExpanded or volume > volMa)
bool weakBreakUp46 = resistanceBroken46 and not volBreakUp46
bool weakBreakDown46 = supportBroken46 and not volBreakDown46
string volBreakState46 = volBreakUp46 ? "Volume Break Up" : volBreakDown46 ? "Volume Break Down" : weakBreakUp46 or weakBreakDown46 ? "Weak Break" : "No Break"
color volBreakColor46 = volBreakUp46 ? color.lime : volBreakDown46 ? color.red : weakBreakUp46 or weakBreakDown46 ? color.orange : color.silver
bool volBreakEvent46 = volBreakUp46 or volBreakDown46
color volRegimeColor462 = volRegime == "Extreme" ? color.red : volRegime == "High" or volRegime == "Expanding" ? color.orange : volRegime == "Compressed" or volRegime == "Low" or volRegime == "Very Low" ? color.aqua : color.silver

// BTC macro/cycle context
bool isBTC46 = str.contains(syminfo.tickerid, "BTC")
btcWma200 = request.security(syminfo.tickerid, "W", ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)
btcDHigh365 = request.security(syminfo.tickerid, "D", ta.highest(high, 365), barmerge.gaps_off, barmerge.lookahead_off)
btcDLow365 = request.security(syminfo.tickerid, "D", ta.lowest(low, 365), barmerge.gaps_off, barmerge.lookahead_off)
btcDHigh730 = request.security(syminfo.tickerid, "D", ta.highest(high, 730), barmerge.gaps_off, barmerge.lookahead_off)
btcDLow730 = request.security(syminfo.tickerid, "D", ta.lowest(low, 730), barmerge.gaps_off, barmerge.lookahead_off)
btcAth1460 = request.security(syminfo.tickerid, "D", ta.highest(high, 1460), barmerge.gaps_off, barmerge.lookahead_off)
btcPct1Y = (btcDHigh365 - btcDLow365) != 0 ? (close - btcDLow365) / (btcDHigh365 - btcDLow365) : 0.5
btcPct2Y = (btcDHigh730 - btcDLow730) != 0 ? (close - btcDLow730) / (btcDHigh730 - btcDLow730) : 0.5
btcDist200W = not na(btcWma200) and btcWma200 != 0 ? (close - btcWma200) / btcWma200 : na
btcAthDD = not na(btcAth1460) and btcAth1460 != 0 ? (close / btcAth1460 - 1.0) : na
bool btcCycleDiscount46 = isBTC46 and (btcPct2Y < 0.35 or nz(btcDist200W, 0.0) < 0.15 or nz(btcAthDD, 0.0) < -0.45)
bool btcCyclePremium46 = isBTC46 and (btcPct2Y > 0.75 and nz(btcDist200W, 0.0) > 0.80)
string btcCycleState46 = not isBTC46 or not showBTCycle46 ? "Off" : inDiscount and btcCycleDiscount46 ? "Local Discount | Cycle Discount" : inDiscount ? "Local Discount | Cycle Neutral" : inPremium and btcCyclePremium46 ? "Local Premium | Cycle Expensive" : inPremium ? "Local Premium | Cycle Premium" : btcCycleDiscount46 ? "Cycle Discount" : btcCyclePremium46 ? "Cycle Premium" : "Cycle Neutral"
color btcCycleColor46 = str.contains(btcCycleState46, "Discount") ? color.lime : str.contains(btcCycleState46, "Premium") or str.contains(btcCycleState46, "Expensive") ? color.red : color.silver

// RellQuantBrain IT3 multi-symbol forward-test router
bool it3M15_46 = timeframe.isminutes and timeframe.multiplier == 15
bool it3EURUSD46 = str.contains(syminfo.tickerid, "EURUSD")
bool it3USA50046 = str.contains(syminfo.tickerid, "USA500") or str.contains(syminfo.tickerid, "SPX500")
bool it3BTCUSD46 = str.contains(syminfo.tickerid, "BTCUSD")
bool it3Approved46 = useIT3Backend47 and it3M15_46 and (it3EURUSD46 or it3USA50046)
bool it3Watchlist46 = useIT3Backend47 and it3M15_46 and it3BTCUSD46
string it3Side46 = it3Approved46 ? "Long" : it3Watchlist46 ? "Short" : "None"
string it3Profile46 = it3EURUSD46 ? "EURUSD M15 Long Approved" : it3USA50046 ? "USA500 M15 Long Approved" : it3BTCUSD46 ? "BTC M15 Short Watchlist" : it3M15_46 ? "Not Trained" : "Wrong TF"
float it3Threshold46 = 0.70
float it3Slope46 = atr != 0.0 ? (ema20 - ema20[5]) / atr : 0.0
float it3Sqz46 = atr != 0.0 ? ta.stdev(close, 20) / atr : 1.0
float it3VwapDist46 = atr != 0.0 ? (close - ta.vwap(close)) / atr : 0.0
float it3PriorLow46 = ta.lowest(low, 20)[1]
float it3PriorHigh46 = ta.highest(high, 20)[1]
bool it3SslSweep46 = low < it3PriorLow46 and close > it3PriorLow46
bool it3BslRej46 = high > it3PriorHigh46 and close < it3PriorHigh46
int it3BarsSinceSSL46 = ta.barssince(it3SslSweep46)
int it3BarsSinceBSL46 = ta.barssince(it3BslRej46)
float it3Score46 = 0.0
if it3Side46 == "Long"
    if it3Slope46 > 0.05 and it3VwapDist46 < 0.2
        it3Score46 += 40
    if it3Sqz46 < 1.0
        it3Score46 += 30
    if not na(it3BarsSinceSSL46) and it3BarsSinceSSL46 <= 15
        it3Score46 += 30
else if it3Side46 == "Short"
    if it3Slope46 < -0.05 and it3VwapDist46 > -0.2
        it3Score46 += 40
    if it3Sqz46 < 1.0
        it3Score46 += 30
    if not na(it3BarsSinceBSL46) and it3BarsSinceBSL46 <= 15
        it3Score46 += 30
float it3ScorePct46 = it3Score46 / 100.0
bool it3ApprovedLongSignal46 = it3Approved46 and it3Side46 == "Long" and it3ScorePct46 >= it3Threshold46
bool it3WatchSignal46 = it3Watchlist46 and it3ScorePct46 >= it3Threshold46
string it3State46 = not useIT3Backend47 ? "Off" : not it3M15_46 ? "Wrong TF | Use M15" : it3ApprovedLongSignal46 ? "A+ | " + str.tostring(it3ScorePct46 * 100, "#") + "%" : it3WatchSignal46 ? "Watch | " + str.tostring(it3ScorePct46 * 100, "#") + "%" : it3Approved46 ? "Wait | " + str.tostring(it3ScorePct46 * 100, "#") + "%" : it3Watchlist46 ? "Watchlist | " + str.tostring(it3ScorePct46 * 100, "#") + "%" : "Off"
color it3Color46 = it3ApprovedLongSignal46 ? color.lime : it3WatchSignal46 and it3Side46 == "Short" ? color.red : it3WatchSignal46 ? color.orange : it3Watchlist46 ? color.orange : it3Approved46 ? color.silver : color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// v4.6.2 Trader Workflow / Anti-FOMO Guard
// Purpose: turn the dashboard into a checklist, not a permission slip.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool wfBiasAligned461 = (bias == "Bullish" and htfDir >= 0) or (bias == "Bearish" and htfDir <= 0) or bias == "Neutral"
bool wfLiquidity461 = bullLiquiditySweep or bearLiquiditySweep or sslReaction46 or bslReaction46 or sslNearby46 or bslNearby46
bool wfZone461 = demandReaction46 or supplyReaction46 or bullBreakerRetest46 or bearBreakerRetest46 or inSupportChannel46 or inResistanceChannel46 or priceInBullFVG or priceInBearFVG
bool wfTrigger461 = bullCHoCH or bearCHoCH or bullStructureBreak or bearStructureBreak or volBreakEvent46 or it3ApprovedLongSignal46
bool wfVolume461 = rvol >= effRvolMin or volBreakEvent46 or not useVolumeBrain43
bool wfRiskOk461 = not marketBad and quality != "Trap Risk" and quality != "No Trade"
bool wfIt3Ok461 = not useIT3Backend47 or not it3Approved46 or it3ApprovedLongSignal46

int wfScore461 = (wfBiasAligned461 ? 1 : 0) + (wfLiquidity461 ? 1 : 0) + (wfZone461 ? 1 : 0) + (wfTrigger461 ? 1 : 0) + (wfVolume461 ? 1 : 0) + (wfRiskOk461 ? 1 : 0)

string wfText461 = str.tostring(wfScore461) + "/6 " + (wfScore461 >= 5 ? "Ready" : wfScore461 >= 3 ? "Waiting" : "Incomplete")
color wfColor461 = wfScore461 >= 5 and wfRiskOk461 ? color.lime : wfScore461 >= 3 ? color.orange : color.red

string actionState461 = quality == "No Trade" ? "NO TRADE" : quality == "Trap Risk" ? "TRAP RISK" : marketBad ? "NO TRADE" : useStrictAction461 and wfScore461 < 5 ? "WAIT" : (quality == "A+" or quality == "A") ? "READY" : quality == "B" ? "WAIT RETEST" : "WAIT"
color actionColor461 = actionState461 == "READY" ? color.lime : actionState461 == "TRAP RISK" ? color.red : actionState461 == "NO TRADE" ? color.red : color.orange
string actionNote461 = actionState461 == "READY" ? "Checklist aligned" : actionState461 == "WAIT RETEST" ? "Valid, but wait retest" : actionState461 == "TRAP RISK" ? "Do not chase" : actionState461 == "NO TRADE" ? "Stand down" : "Need trigger"

string playbook = "WAIT"
string guide = "Need sweep, BOS/CHoCH, or FVG retest"
string risk = "No mid-range entry"
string target = bias == "Bullish" ? "Target BSL / EQH / PDH" : bias == "Bearish" ? "Target SSL / EQL / PDL" : "Target range edges"

if marketBad
    playbook := "WAIT"
    guide := inBlackout ? "Time blackout, avoid forced entries" : "Compression/low RVOL, fakeout risk"
    risk := "No trade until expansion"
else if demandReaction46 and (bullCHoCH or bullStructureBreak or trendFilterBull)
    playbook := "LONG Demand Reaction"
    guide := "Demand reaction + bullish structure → wait confirm"
    risk := "SL below demand/sweep | Target BSL"
else if supplyReaction46 and (bearCHoCH or bearStructureBreak or trendFilterBear)
    playbook := "SHORT Supply Reaction"
    guide := "Supply reaction + bearish structure → wait confirm"
    risk := "SL above supply/sweep | Target SSL"
else if bullBreakerRetest46
    playbook := "LONG Breaker Retest"
    guide := "Bear OB failed → retest as support → long"
    risk := "SL below breaker | Target BSL/PDH"
else if bearBreakerRetest46
    playbook := "SHORT Breaker Retest"
    guide := "Bull OB failed → retest as resistance → short"
    risk := "SL above breaker | Target SSL/PDL"
else if volBreakUp46
    playbook := "LONG S/R Breakout Retest"
    guide := "Break resistance with volume → wait retest"
    risk := "SL below broken resistance"
else if volBreakDown46
    playbook := "SHORT S/R Breakdown Retest"
    guide := "Break support with volume → wait retest"
    risk := "SL above broken support"
else if weakBreakUp46 or weakBreakDown46
    playbook := "WAIT: Weak breakout"
    guide := "Volume not confirmed, wait for retest"
    risk := "No chase"
else if isBTC46 and btcCycleDiscount46 and bullLiquiditySweep and bullCHoCH
    playbook := "LONG Cycle Discount Reversal"
    guide := "Cycle discount + SSL sweep + Bull CHoCH → Buy FVG/OB"
    risk := "SL below cycle sweep | Swing target BSL"
else if isBTC46 and btcCyclePremium46 and (bearStructureBreak or priceInBearFVG)
    playbook := "SHORT Cycle Premium Rejection"
    guide := "Cycle premium + Bear BOS/FVG → short retest"
    risk := "SL above premium rejection"
else if (sslArea46 or bslArea46) and not (sslReaction46 or bslReaction46 or bullLiquiditySweep or bearLiquiditySweep)
    playbook := "WAIT: Zone exists"
    guide := "Liquidity area exists, no trigger yet"
    risk := "Wait reaction/sweep"
else if useMTFBackend and mtfLiqCode == 2 and (bullCHoCH or bullStructureBreak) and (ctxStructDir >= 0 or macroStructDir >= 0)
    playbook := "LONG MTF Sweep Reversal"
    guide := mtfLiqTf + " SSL sweep → LTF CHoCH → Buy FVG/CE"
    risk := "SL below MTF sweep | Target 15m BSL/PDH"
else if useMTFBackend and mtfLiqCode == -2 and (bearCHoCH or bearStructureBreak) and (ctxStructDir <= 0 or macroStructDir <= 0)
    playbook := "SHORT MTF Sweep Reversal"
    guide := mtfLiqTf + " BSL sweep → LTF CHoCH → Sell FVG/CE"
    risk := "SL above MTF sweep | Target 15m SSL/PDL"
else if useMTFBackend and ctxFvgTouch == 1 and mtfBullFvg and (bullCETap or priceInBullFVG)
    playbook := "LONG MTF FVG Retest"
    guide := mtfContextTf + " Bull FVG → LTF CE/FVG confirmation"
    risk := "SL below FVG | Target BSL/PDH"
else if useMTFBackend and ctxFvgTouch == 1 and mtfBearFvg and (bearCETap or priceInBearFVG)
    playbook := "SHORT MTF FVG Retest"
    guide := mtfContextTf + " Bear FVG → LTF CE/FVG confirmation"
    risk := "SL above FVG | Target SSL/PDL"
else if bullSweepSetup and bullCHoCH
    playbook := "LONG Sweep Reversal"
    guide := "SSL sweep → Bull CHoCH → Buy FVG/CE"
    risk := "SL below sweep | Target BSL/PDH"
else if bearSweepSetup and bearCHoCH
    playbook := "SHORT Sweep Reversal"
    guide := "BSL sweep → Bear CHoCH → Sell FVG/CE"
    risk := "SL above sweep | Target SSL/PDL"
else if bullIFVG or (priceInBullFVG and bullCETap and bestBullFvgQ >= 0.60)
    playbook := "LONG High-Q FVG"
    guide := "Bull FVG/IFVG → CE tap → Confirm"
    risk := "SL below FVG | Target BSL/PDH"
else if bearIFVG or (priceInBearFVG and bearCETap and bestBearFvgQ >= 0.60)
    playbook := "SHORT High-Q FVG"
    guide := "Bear FVG/IFVG → CE tap → Confirm"
    risk := "SL above FVG | Target SSL/PDL"
else if bullBreakoutNow and (htfDir >= 0 or trendFilterBull)
    playbook := "LONG Breakout Retest"
    guide := "Break high/OR → Retest → Long"
    risk := "SL below retest | Target BSL/PDH"
else if bearBreakoutNow and (htfDir <= 0 or trendFilterBear)
    playbook := "SHORT Breakout Retest"
    guide := "Break low/OR → Retest → Short"
    risk := "SL above retest | Target SSL/PDL"
else if trendFilterBull and htfDir == 1 and inDiscount
    playbook := "LONG Continuation"
    guide := "HTF bullish → Buy discount FVG/OB"
    risk := "SL below swing | Target weak high/BSL"
else if trendFilterBear and htfDir == -1 and inPremium
    playbook := "SHORT Continuation"
    guide := "HTF bearish → Sell premium FVG/OB"
    risk := "SL above swing | Target weak low/SSL"
else if bias == "Neutral"
    playbook := "RANGE Liquidity Play"
    guide := "Buy SSL sweep / Sell BSL sweep"
    risk := "No middle entries"
else if conflict != "None"
    playbook := "COUNTERTREND Caution"
    guide := "Trade smaller, wait for CHoCH + FVG"
    risk := "Fast TP only"
else
    playbook := bias == "Bullish" ? "WAIT For Long Trigger" : bias == "Bearish" ? "WAIT For Short Trigger" : "WAIT"
    guide := bias == "Bullish" ? "Need SSL sweep or breakout retest" : bias == "Bearish" ? "Need BSL sweep or breakdown retest" : "Need cleaner condition"
    risk := "No chase"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// v4.7 Risk Governance Layer
// Conservative behavior engine. Backend IT3 can support the workflow, but it no
// longer prints as a dashboard row or renames the playbook.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rangeAvg47 = ta.sma(high - low, 100)
rangeRatio47 = not na(rangeAvg47) and rangeAvg47 != 0.0 ? (high - low) / rangeAvg47 : 1.0
absVwapZ47 = math.abs(vwapZ43)
int tailScore47 = 0
tailScore47 += volExtreme462 ? 2 : (volHigh462 or volExpanded ? 1 : 0)
tailScore47 += rangeRatio47 > 2.20 ? 2 : rangeRatio47 > 1.50 ? 1 : 0
tailScore47 += absVwapZ47 > 2.25 ? 1 : 0
tailScore47 += rvol > 2.50 ? 1 : 0
tailScore47 += inBlackout ? 1 : 0
string tailRisk47 = not useGovernance47 ? "Off" : tailScore47 >= 4 ? "Extreme" : tailScore47 >= 2 ? "Elevated" : "Normal"
color tailRiskColor47 = tailRisk47 == "Extreme" ? color.red : tailRisk47 == "Elevated" ? color.orange : tailRisk47 == "Normal" ? color.lime : color.gray

string autoDrawdownMode47 = dailyLossCount47 >= maxDailyLosses47 or losingStreak47 >= 3 ? "Lockout" : losingStreak47 == 2 or weeklyLossCount47 >= 5 ? "Recovery" : dailyLossCount47 >= 1 or losingStreak47 == 1 ? "Caution" : "Normal"
string drawdownMode47 = not useGovernance47 ? "Off" : drawdownInputMode47 == "Auto" ? autoDrawdownMode47 : drawdownInputMode47
color drawdownColor47 = drawdownMode47 == "Lockout" ? color.red : drawdownMode47 == "Recovery" ? color.orange : drawdownMode47 == "Caution" ? color.yellow : drawdownMode47 == "Normal" ? color.lime : color.gray

bool researchBlocked47 = researchStatus47 == "Rejected" or researchStatus47 == "Untrained"
bool researchCaution47 = researchStatus47 == "Forward Test" or researchStatus47 == "Watchlist"
color researchColor47 = researchStatus47 == "Approved" ? color.lime : researchBlocked47 ? color.red : color.orange

bool usdPair47 = isForex and str.contains(syminfo.tickerid, "USD")
bool indexGroup47 = str.contains(syminfo.tickerid, "US100") or str.contains(syminfo.tickerid, "NAS") or str.contains(syminfo.tickerid, "SPX") or str.contains(syminfo.tickerid, "USA500") or str.contains(syminfo.tickerid, "US30") or str.contains(syminfo.tickerid, "GER40")
bool cryptoGroup47 = isCrypto or str.contains(syminfo.tickerid, "BTC") or str.contains(syminfo.tickerid, "ETH")
string autoCorrRisk47 = usdPair47 ? "Medium" : indexGroup47 or cryptoGroup47 ? "Medium" : "Low"
string corrRisk47 = correlationOverride47 == "Auto" ? autoCorrRisk47 : correlationOverride47
color corrRiskColor47 = corrRisk47 == "High" ? color.red : corrRisk47 == "Medium" ? color.orange : color.lime
string corrGuide47 = corrRisk47 == "High" ? "Avoid duplicate exposure" : corrRisk47 == "Medium" ? "Check related positions" : "No major overlap"

float kellyWin47 = kellyWinRate47 / 100.0
float kellyRaw47 = kellyRR47 > 0.0 ? kellyWin47 - ((1.0 - kellyWin47) / kellyRR47) : 0.0
float fractionalKellyPct47 = math.max(0.0, kellyRaw47 * 0.25 * 100.0)

string riskMode47 = "OBSERVE"
float riskPctBase47 = 0.0
string riskReason47 = "Need cleaner conditions"

if not useGovernance47
    riskMode47 := "OFF"
    riskPctBase47 := 0.0
    riskReason47 := "Governance disabled"
else if marketBad or quality == "No Trade" or actionState461 == "NO TRADE"
    riskMode47 := "NO TRADE"
    riskPctBase47 := 0.0
    riskReason47 := marketBad ? "Bad market filter" : "No valid setup"
else if quality == "Trap Risk" or actionState461 == "TRAP RISK"
    riskMode47 := "NO TRADE"
    riskPctBase47 := 0.0
    riskReason47 := "Trap risk active"
else if drawdownMode47 == "Lockout"
    riskMode47 := "NO TRADE"
    riskPctBase47 := 0.0
    riskReason47 := "Drawdown lockout"
else if tailRisk47 == "Extreme"
    riskMode47 := "OBSERVE"
    riskPctBase47 := 0.0
    riskReason47 := "Extreme tail risk"
else if researchBlocked47
    riskMode47 := "OBSERVE"
    riskPctBase47 := 0.0
    riskReason47 := "Research not approved"
else if drawdownMode47 == "Recovery" or tailRisk47 == "Elevated" or conflict != "None" or corrRisk47 == "High"
    riskMode47 := "REDUCED"
    riskPctBase47 := reducedRiskPct47
    riskReason47 := drawdownMode47 == "Recovery" ? "Recovery mode" : tailRisk47 == "Elevated" ? "Elevated tail risk" : corrRisk47 == "High" ? "Correlation exposure" : "Context conflict"
else if actionState461 == "READY" and quality == "A+" and researchStatus47 == "Approved" and drawdownMode47 == "Normal" and tailRisk47 == "Normal"
    riskMode47 := "PREMIUM"
    riskPctBase47 := premiumRiskPct47
    riskReason47 := "A+ approved conditions"
else if actionState461 == "READY" and (quality == "A+" or quality == "A")
    riskMode47 := researchCaution47 or drawdownMode47 == "Caution" ? "REDUCED" : "NORMAL"
    riskPctBase47 := researchCaution47 or drawdownMode47 == "Caution" ? reducedRiskPct47 : normalRiskPct47
    riskReason47 := researchCaution47 ? "Forward-test caution" : drawdownMode47 == "Caution" ? "Drawdown caution" : "Checklist aligned"
else if quality == "B" or actionState461 == "WAIT RETEST"
    riskMode47 := "REDUCED"
    riskPctBase47 := reducedRiskPct47
    riskReason47 := "B setup / wait retest"
else
    riskMode47 := "OBSERVE"
    riskPctBase47 := 0.0
    riskReason47 := "Need confirmation"

float riskPctCapped47 = math.min(riskPctBase47, maxRiskCapPct47)
float suggestedRiskPct47 = useKellyReference47 ? math.min(riskPctCapped47, fractionalKellyPct47) : riskPctCapped47
color riskModeColor47 = riskMode47 == "PREMIUM" ? color.yellow : riskMode47 == "NORMAL" ? color.lime : riskMode47 == "REDUCED" ? color.orange : riskMode47 == "OBSERVE" ? color.aqua : riskMode47 == "NO TRADE" ? color.red : color.gray
string riskDisplay47 = riskMode47 + " | " + f_pct(suggestedRiskPct47)
string tailDisplay47 = tailRisk47 + " | Range " + str.tostring(rangeRatio47, "#.##") + "x"
string drawdownDisplay47 = drawdownMode47 + " | L" + str.tostring(dailyLossCount47) + "/S" + str.tostring(losingStreak47)

fvgState = priceInBullFVG ? "Inside Bull FVG " + f_prob(bestBullFvgQ) : priceInBearFVG ? "Inside Bear FVG " + f_prob(bestBearFvgQ) : "No Touch"
// liqState is computed by v4.6 staged liquidity backend above.
structureState = structureEvent
emaState = trendFilterBull ? "Bull Trend" : trendFilterBear ? "Bear Trend" : close > ema50 ? "Bull Lean" : close < ema50 ? "Bear Lean" : "Flat"
dwmState = not showDWM ? "Off" : close > prevDayHigh ? "Above PDH" : close < prevDayLow ? "Below PDL" : close > dayOpen ? "Above D Open" : close < dayOpen ? "Below D Open" : "At D Open"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Scanner
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_scan(sym, tf) =>
    request.security(sym, tf, [close, close[1], ta.ema(close, 50), ta.ema(close, 200), ta.rsi(close, 14)], barmerge.gaps_off, barmerge.lookahead_off)

[s1C, s1P, s1E50, s1E200, s1R] = f_scan(scan1, scannerTf)
[s2C, s2P, s2E50, s2E200, s2R] = f_scan(scan2, scannerTf)
[s3C, s3P, s3E50, s3E200, s3R] = f_scan(scan3, scannerTf)

t1 = f_trend_text(s1C, s1E50, s1E200)
t2 = f_trend_text(s2C, s2E50, s2E200)
t3 = f_trend_text(s3C, s3E50, s3E200)

chgPct(x, p) =>
    p == 0 ? 0.0 : (x - p) / p * 100.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Chart Tint
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

chartTint = not dashUseChartTint ? na : bias == "Bullish" ? color.new(color.lime, 92) : bias == "Bearish" ? color.new(color.red, 92) : color.new(color.gray, 95)
bgcolor(chartTint, title="Bias Background Tint")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard Styling
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

panelBg = dashTheme == "Glass" ? color.new(color.rgb(18, 20, 26), dashOpacity) : dashTheme == "Carbon" ? color.new(color.rgb(12, 12, 12), dashOpacity) : dashTheme == "Midnight" ? color.new(color.rgb(9, 14, 25), dashOpacity) : color.new(color.rgb(10, 10, 10), dashOpacity)
rowOdd = dashTheme == "Glass" ? color.new(color.rgb(28, 30, 38), dashOpacity + 10) : dashTheme == "Carbon" ? color.new(color.rgb(18, 18, 18), dashOpacity + 10) : dashTheme == "Midnight" ? color.new(color.rgb(16, 22, 38), dashOpacity + 10) : color.new(color.rgb(16, 16, 16), dashOpacity + 10)
rowEven = dashTheme == "Glass" ? color.new(color.rgb(22, 24, 30), dashOpacity + 10) : dashTheme == "Carbon" ? color.new(color.rgb(14, 14, 14), dashOpacity + 10) : dashTheme == "Midnight" ? color.new(color.rgb(12, 18, 32), dashOpacity + 10) : color.new(color.rgb(12, 12, 12), dashOpacity + 10)
frameCol = color.new(color.white, dashBorderOpacity)

biasBg = bias == "Bullish" ? color.new(color.lime, 70) : bias == "Bearish" ? color.new(color.red, 70) : color.new(color.gray, 80)
qualityColor = quality == "A+" ? color.yellow : quality == "A" ? color.lime : quality == "B" ? color.aqua : quality == "C" ? color.orange : quality == "Trap Risk" ? color.red : quality == "No Trade" ? color.red : color.gray
signalBg = longConfluence ? color.new(color.lime, 65) : shortConfluence ? color.new(color.red, 65) : color.new(color.gray, 85)
txtSize = f_size(dashTextSize)

f_row_bg(r) =>
    r % 2 == 0 ? rowEven : rowOdd

var table dash = table.new(f_pos(dashPosition), 3, 40, bgcolor=panelBg, border_color=frameCol, border_width=1, frame_color=frameCol, frame_width=1)

if barstate.isfirst
    table.merge_cells(dash, 0, 0, 2, 0)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Rell SMI v4.7 Premium", text_color=color.yellow, bgcolor=color.new(color.black, 0), text_size=txtSize)

    int row = 1

    table.cell(dash, 0, row, "Bias", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, bias, text_color=color.white, bgcolor=biasBg, text_size=txtSize)
    table.cell(dash, 2, row, f_score_text(bullScore, bearScore, maxScore), text_color=color.white, bgcolor=biasBg, text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "Quality", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, quality, text_color=qualityColor, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, "Auto Thr " + str.tostring(effConfluenceAuto), text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    if showWorkflow461
        table.cell(dash, 0, row, "Action / Checklist", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, actionState461 + " | " + wfText461, text_color=actionColor461, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, actionNote461, text_color=actionColor461, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    if showGovernanceRows47
        table.cell(dash, 0, row, "Risk Mode", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, riskDisplay47, text_color=riskModeColor47, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, riskReason47, text_color=riskModeColor47, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "Tail / Drawdown", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, tailDisplay47, text_color=tailRiskColor47, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, drawdownDisplay47, text_color=drawdownColor47, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "Research / Correlation", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, researchStatus47, text_color=researchColor47, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, corrRisk47 + " | " + corrGuide47, text_color=corrRiskColor47, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    table.cell(dash, 0, row, "Playbook", text_color=color.white, bgcolor=signalBg, text_size=txtSize)
    table.cell(dash, 1, row, playbook, text_color=color.white, bgcolor=signalBg, text_size=txtSize)
    table.cell(dash, 2, row, target, text_color=color.white, bgcolor=signalBg, text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "Guide", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, guide, text_color=color.yellow, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, risk, text_color=color.orange, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "HTF / Structure", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, htfBiasText, text_color=htfDir == 1 ? color.lime : htfDir == -1 ? color.red : color.gray, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, structureState, text_color=str.contains(structureState, "Bull") ? color.lime : str.contains(structureState, "Bear") ? color.red : color.gray, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "MTF Backend", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, mtfContextText, text_color=mtfContextColor462, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, mtfDetailText, text_color=mtfDetailColor462, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "Liquidity / FVG", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, liqState, text_color=liqStateColor46, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, fvgState, text_color=priceInBullFVG ? color.lime : priceInBearFVG ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "Supply-Demand / Breaker", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, sdState46, text_color=sdColor46, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, breakerState46, text_color=breakerColor46, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    table.cell(dash, 0, row, "S/R / Volume Break", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, srState46, text_color=srColor46, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, volBreakState46, text_color=volBreakColor46, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    if showBTCycle46 and isBTC46
        table.cell(dash, 0, row, "BTC Cycle", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, btcCycleState46, text_color=btcCycleColor46, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "200W " + str.tostring(nz(btcDist200W) * 100.0, "#") + "% | DD " + str.tostring(nz(btcAthDD) * 100.0, "#") + "%", text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    table.cell(dash, 0, row, "Zone / Volume", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 1, row, pdState, text_color=inDiscount ? color.lime : inPremium ? color.red : color.gray, bgcolor=f_row_bg(row), text_size=txtSize)
    table.cell(dash, 2, row, "RVOL " + str.tostring(rvol, "#.##") + " " + rvolState, text_color=rvol >= effRvolMin ? color.lime : color.red, bgcolor=f_row_bg(row), text_size=txtSize)
    row += 1

    if dashMode == "Full"
        table.cell(dash, 0, row, "Brain / Quality", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, quality + " | " + qualityDetail43, text_color=qualityColor, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, brainState43, text_color=brainBull43 > brainBear43 ? color.lime : brainBear43 > brainBull43 ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        if showSentiment43
            table.cell(dash, 0, row, "Sentiment", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
            table.cell(dash, 1, row, sentBar43, text_color=color.white, bgcolor=sentColor43, text_size=txtSize, tooltip=sentText43)
            table.cell(dash, 2, row, sentText43, text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
            row += 1

        table.cell(dash, 0, row, "Momentum / VWAP", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, momState43, text_color=momBull43 ? color.lime : momBear43 ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, vwapState43, text_color=vwapBull43 ? color.lime : vwapBear43 ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "Trend / Delta", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, trendStrong43 ? "ADX " + str.tostring(adx43, "#") + " Strong" : "ADX " + str.tostring(adx43, "#") + " Weak", text_color=trendBull43 ? color.lime : trendBear43 ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, deltaState43, text_color=deltaBull43 ? color.lime : deltaBear43 ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    if dashMode == "Balanced" or dashMode == "Full"
        table.cell(dash, 0, row, "Session / DWM", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        sessTxt = isCrypto ? "24/7" : (effShowKillzones ? currentSession : "Off")
        table.cell(dash, 1, row, sessTxt, text_color=(killzoneActive or isCrypto) ? color.yellow : color.gray, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, dwmState, text_color=str.contains(dwmState, "Above") ? color.lime : str.contains(dwmState, "Below") ? color.red : color.gray, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "Volatility", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        volTxt = isForex ? str.tostring(atrPips, "#.0") + " pips" : f_pct((atr / close) * 100.0)
        table.cell(dash, 1, row, volRegime, text_color=volRegimeColor462, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "ATR " + volTxt + " | R " + str.tostring(volAtrRatio462, "#.##"), text_color=volRegimeColor462, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "OB / VP", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        obState = obRetestBull ? "Bull OB Retest" : obRetestBear ? "Bear OB Retest" : obBrokenBull ? "Bull OB Broken" : obBrokenBear ? "Bear OB Broken" : "None"
        table.cell(dash, 1, row, obState, text_color=obRetestBull ? color.lime : obRetestBear ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, useVP ? vpState : "VP Off", text_color=str.contains(vpState, "Above") ? color.lime : str.contains(vpState, "Below") ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    if dashMode == "Full"
        table.cell(dash, 0, row, "Market", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, profile, text_color=color.yellow, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, marketMode == "Auto" ? "Auto" : "Manual", text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "OR / Conflict", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, orState, text_color=orBreakUp ? color.lime : orBreakDown ? color.red : color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, conflict, text_color=conflict == "None" ? color.gray : color.orange, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, "Strong/Weak", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, strongWeakState, text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "Active FVG " + str.tostring(array.size(fvgZones)), text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    if scannerMode == "Compact"
        table.cell(dash, 0, row, "Scanner", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        compact = "1:" + t1 + " | 2:" + t2 + " | 3:" + t3
        table.cell(dash, 1, row, compact, text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, scannerTf, text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

    if scannerMode == "Full"
        table.cell(dash, 0, row, "Scanner TF", text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, scannerTf, text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "Trend / RSI", text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        s1p = chgPct(s1C, s1P)
        s2p = chgPct(s2C, s2P)
        s3p = chgPct(s3C, s3P)

        table.cell(dash, 0, row, scan1, text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, t1 + " " + f_pct(s1p), text_color=f_trend_color(t1), bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "RSI " + str.tostring(s1R, "#"), text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, scan2, text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, t2 + " " + f_pct(s2p), text_color=f_trend_color(t2), bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "RSI " + str.tostring(s2R, "#"), text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

        table.cell(dash, 0, row, scan3, text_color=color.white, bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 1, row, t3 + " " + f_pct(s3p), text_color=f_trend_color(t3), bgcolor=f_row_bg(row), text_size=txtSize)
        table.cell(dash, 2, row, "RSI " + str.tostring(s3R, "#"), text_color=color.silver, bgcolor=f_row_bg(row), text_size=txtSize)
        row += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Core FVG alerts
alertcondition(alertFVG and bullFVG, "Bullish FVG", "Rell SMI v4.7: Bullish FVG detected")
alertcondition(alertFVG and bearFVG, "Bearish FVG", "Rell SMI v4.7: Bearish FVG detected")
alertcondition(alertFVG and bullIFVG, "Bullish IFVG", "Rell SMI v4.7: Bullish IFVG active")
alertcondition(alertFVG and bearIFVG, "Bearish IFVG", "Rell SMI v4.7: Bearish IFVG active")
alertcondition(alertFVG and bullFvgMitigatedNow, "Bullish FVG Filled", "Rell SMI v4.7: Bullish FVG filled/deleted")
alertcondition(alertFVG and bearFvgMitigatedNow, "Bearish FVG Filled", "Rell SMI v4.7: Bearish FVG filled/deleted")

// Structure alerts
alertcondition(alertStructure and bullBOS, "Bullish BOS", "Rell SMI v4.7: Bullish BOS")
alertcondition(alertStructure and bearBOS, "Bearish BOS", "Rell SMI v4.7: Bearish BOS")
alertcondition(alertStructure and bullCHoCH, "Bullish CHoCH", "Rell SMI v4.7: Bullish CHoCH")
alertcondition(alertStructure and bearCHoCH, "Bearish CHoCH", "Rell SMI v4.7: Bearish CHoCH")

// Liquidity alerts
alertcondition(alertLiquidity and bullLiquiditySweep, "Sell-Side Liquidity Sweep", "Rell SMI v4.7: SSL swept and reclaimed")
alertcondition(alertLiquidity and bearLiquiditySweep, "Buy-Side Liquidity Sweep", "Rell SMI v4.7: BSL swept and rejected")
alertcondition(cryptoSweepBull, "Crypto SSL Sweep", "Rell SMI v4.7: Crypto sell-side liquidity sweep detected")
alertcondition(cryptoSweepBear, "Crypto BSL Sweep", "Rell SMI v4.7: Crypto buy-side liquidity sweep detected")

// Confluence alerts
alertcondition(alertConfluence and longConfluence and not longConfluence[1], "Bullish Confluence", "Rell SMI v4.7: Bullish confluence formed")
alertcondition(alertConfluence and shortConfluence and not shortConfluence[1], "Bearish Confluence", "Rell SMI v4.7: Bearish confluence formed")

// v4.6 Quality alerts
alertcondition(alertConfluence and quality == "A+" and quality[1] != "A+", "A+ Setup", "Rell SMI v4.7: A+ setup detected")
alertcondition(alertConfluence and quality == "A" and quality[1] != "A", "A Setup", "Rell SMI v4.7: A setup detected")
alertcondition(alertConfluence and quality == "B" and quality[1] != "B", "B Setup / Wait Retest", "Rell SMI v4.7: B setup detected, wait for retest")
alertcondition(alertConfluence and quality == "Trap Risk" and quality[1] != "Trap Risk", "Trap Risk", "Rell SMI v4.7: Trap Risk detected")
alertcondition(alertConfluence and quality == "No Trade" and quality[1] != "No Trade", "No Trade", "Rell SMI v4.7: No Trade state detected")

// v4.6 Sentiment alerts
sentBullDom45 = sentBullPct43 >= 65 and sentBullPct43[1] < 65
sentBearDom45 = sentBullPct43 <= 35 and sentBullPct43[1] > 35
sentNeutral45 = sentBullPct43 > 45 and sentBullPct43 < 55 and (sentBullPct43[1] <= 45 or sentBullPct43[1] >= 55)

alertcondition(alertConfluence and sentBullDom45, "Bull Sentiment Dominance", "Rell SMI v4.7: Bull sentiment dominance detected")
alertcondition(alertConfluence and sentBearDom45, "Bear Sentiment Dominance", "Rell SMI v4.7: Bear sentiment dominance detected")
alertcondition(alertConfluence and sentNeutral45, "Sentiment Neutralized", "Rell SMI v4.7: Sentiment returned to neutral")

// v4.6 Brain state alerts
momBullShift45 = momBull43 and not momBull43[1]
momBearShift45 = momBear43 and not momBear43[1]
vwapHighExt45 = vwapOverHigh43 and not vwapOverHigh43[1]
vwapLowExt45 = vwapOverLow43 and not vwapOverLow43[1]

alertcondition(alertConfluence and momBullShift45, "Bull Momentum Shift", "Rell SMI v4.7: Bull momentum shift detected")
alertcondition(alertConfluence and momBearShift45, "Bear Momentum Shift", "Rell SMI v4.7: Bear momentum shift detected")
alertcondition(alertConfluence and vwapHighExt45, "VWAP High Extension", "Rell SMI v4.7: Price overextended above VWAP")
alertcondition(alertConfluence and vwapLowExt45, "VWAP Low Extension", "Rell SMI v4.7: Price overextended below VWAP")

// v4.6 Premium / IT3 forward-test alerts
alertcondition(enableIT3Alerts46 and it3ApprovedLongSignal46 and not it3ApprovedLongSignal46[1], "IT3 Approved Long Forward Test", "Rell SMI v4.7: IT3 approved long forward-test signal")
alertcondition(usePremium46 and demandReaction46 and not demandReaction46[1], "Demand Reaction", "Rell SMI v4.7: Demand reaction detected")
alertcondition(usePremium46 and supplyReaction46 and not supplyReaction46[1], "Supply Reaction", "Rell SMI v4.7: Supply reaction detected")
alertcondition(usePremium46 and bullBreakerRetest46 and not bullBreakerRetest46[1], "Bull Breaker Retest", "Rell SMI v4.7: Bull breaker retest detected")
alertcondition(usePremium46 and bearBreakerRetest46 and not bearBreakerRetest46[1], "Bear Breaker Retest", "Rell SMI v4.7: Bear breaker retest detected")
alertcondition(usePremium46 and volBreakEvent46 and not volBreakEvent46[1], "Volume Confirmed Break", "Rell SMI v4.7: Volume-confirmed support/resistance break")

// v4.7 Governance alerts
alertcondition(useGovernance47 and riskMode47 == "PREMIUM" and riskMode47[1] != "PREMIUM", "Premium Risk Mode", "Rell SMI v4.7: Risk mode became PREMIUM")
alertcondition(useGovernance47 and riskMode47 == "NO TRADE" and riskMode47[1] != "NO TRADE", "No Trade Risk Mode", "Rell SMI v4.7: Risk governance moved to NO TRADE")
alertcondition(useGovernance47 and tailRisk47 == "Extreme" and tailRisk47[1] != "Extreme", "Tail Risk Extreme", "Rell SMI v4.7: Tail risk became EXTREME")

// Master alert for people who do not want TradingView screaming 40 times like a possessed smoke alarm
majorSignal45 = (quality == "A+" and quality[1] != "A+") or (quality == "Trap Risk" and quality[1] != "Trap Risk") or sentBullDom45 or sentBearDom45 or bullLiquiditySweep or bearLiquiditySweep or bullCHoCH or bearCHoCH or it3ApprovedLongSignal46
alertcondition(alertConfluence and majorSignal45, "Rell SMI Major Signal", "Rell SMI v4.7: Major market brain signal detected")
alertcondition(alertConfluence and actionState461 == "READY" and actionState461[1] != actionState461, "Rell SMI Action State", "Rell SMI v4.7: Action state became READY")
````
