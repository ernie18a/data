# Enhanced CVD + Signals

- url: https://www.tradingview.com/script/NrHckTfd-Enhanced-CVD-Signals/
- type: indicator
- pine_id: PUB;9e2c6e554e684b08958c17f983753ec4
- version: 1.0

## Description

[b]OVERVIEW[/b]

Enhanced CVD + Signals plots Cumulative Volume Delta as candles in its own pane, using TradingView's built-in volume delta calculation from the lowest possible timeframe data. It adds Heikin-Ashi smoothing for the candles, an optional session anchor, a detrend option, and four rule-based signals that flag specific delta behavior on the bar close.

[b]MAIN FEATURES[/b]

[list]
[*] Custom smoothed candle types: Heikin Ashi (default), Linear Regression, or Regular
[*] Four configurable signals: Absorption, Turnaround, Delta Climax, and Intrabar Reversal
[*] Lower timeframe: chosen automatically as the finest timeframe. A custom timeframe or 1 tick data (Ultimate plan) can be selected instead.
[*] Detrend: subtracts a rolling average of the candle close so candles stay readable when CVD drifts far from zero. Candle shapes are unchanged.
[*] Anchor mode: Timeframe (CVD resets each anchor period, using the official calculation) or Session (CVD resets at the start of a chosen session and time zone)
[*] Optional vertical highlights on signal bars, in the indicator pane and on the price chart
[*] Optional zero line and anchor reset markers
[/list]

[b]SIGNALS[/b]

[b]Absorption (small triangle, theme accent color)[/b]
Flags a bar where delta was heavy but price made little progress in the direction of that delta. Absorption can be interpreted as price level where aggressive buying or selling is being offset by large passive limit orders opposing positions which can stall the move.
[list]
[*] Above the candle: buying was absorbed (bearish read)
[*] Below the candle: selling was absorbed (bullish read)
[*] Heavy delta means the bar delta is at least a set multiple of the average absolute bar delta (default 1.5x over 50 bars)
[*] Little progress means the price move from open to close in the direction of the delta, measured in ATR(14) units, is at or below a set value (default 0.15). Zero or negative means price stalled or moved against the delta.
[*] Detection modes: [i]Effort vs Result at Extremes[/i] (default) also requires price to be at or within one bar of a swing high or low. [i]Effort vs Result[/i] applies the same test anywhere. [i]Simple Disagreement[/i] flags any bar where price and the displayed CVD candle close in opposite directions, and prints often.
[/list]

[b]Turnaround (larger triangle)[/b]
Flags a run of same-direction delta bars followed by a bar that strongly reverses it. Delta turnarounds should be seen as potential reversal points.
[list]
[*] Above the candle: a run of buy-delta bars followed by a sell flip (bearish read)
[*] Below the candle: a run of sell-delta bars followed by a buy flip (bullish read)
[*] The prior run must be at least a set number of bars (default 3)
[*] The flip bar delta must be at least a set multiple of the average absolute delta (default 1.5x) and must reverse at least a set fraction of the prior run's net delta (default 0.5)
[*] The price candle body in the flip direction must be at least a set size in ATR units (default 0.5)
[*] Optionally requires the flip bar to close beyond the prior bar's low (bearish) or high (bullish). On by default.
[/list]

[b]Delta Climax (diamond)[/b]
Flags a bar whose absolute delta ranks unusually high compared to recent bars. These bars can signal the beginning of a major move, but often at the end of impulsive move as a last push.
[list]
[*] Above the candle: buying climax (bearish read)
[*] Below the candle: selling climax (bullish read)
[*] The absolute bar delta must rank at or above a percentile within a lookback (default 95th percentile over 200 bars)
[*] Optionally requires price to be at or just after a swing high (buying) or swing low (selling). On by default.
[*] Optional close rejection filter: requires the close to sit away from the extreme by a set fraction of the bar range. Off by default.
[/list]

[b]Intrabar Reversal (circle)[/b]
Flags a bar where CVD moved away from its open during the bar and then gave most of that move back by the close. 
[list]
[*] Above the candle: buy delta pushed up and was given back (bearish read)
[*] Below the candle: sell delta pushed down and was recovered (bullish read)
[*] The push must be at least a set multiple of the average CVD candle range (default 1.0x over 50 bars)
[*] At least a set fraction of the push must be reversed by the close (default 0.8)
[*] If both directions qualify, the larger excursion decides which side applies
[*] Optionally requires a swing high or low. On by default.
[/list]

## Source Code

````pine
//@version=6
indicator("Enhanced CVD + Signals", shorttitle="CVD", format = format.volume)
import TradingView/ta/12

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════

// ─── CVD source ───
anchorMode = input.string("Timeframe", "Anchor mode", options = ["Timeframe", "Session"], tooltip = "Timeframe: CVD resets on each period of the anchor period input (official calculation).\nSession: CVD resets at the start of the session below (for example the 09:30 RTH open). Session mode uses its own up/down volume calculation from lower timeframe bars and is meant for intraday charts.", group = "CVD")
anchorInput = input.timeframe("1D", "Anchor period", tooltip = "Used in Timeframe anchor mode.", group = "CVD")
sessionInput = input.session("0930-1600", "Anchor session", tooltip = "Used in Session anchor mode. CVD resets at the start of this session and keeps accumulating until the next session start.", group = "CVD")
tzInput = input.string("America/New_York", "Session time zone", group = "CVD")
dataAggregationTooltip = "Defines how lower timeframe data is aggregated for the delta calculation. \"1 tick\" computes the delta on tick data and is available only on Ultimate subscription."
dataAggregationInput = input.string("Time", "Data aggregation", options = ["Time", "1 tick"], tooltip = dataAggregationTooltip, group = "CVD")
useTicks = dataAggregationInput == "1 tick"
lowerTimeframeTooltip = "The indicator scans lower timeframe data to approximate up and down volume used in the delta calculation. By default, the timeframe is chosen automatically. These inputs override this with a custom timeframe. \n\nHigher timeframes provide more historical data, but the data will be less precise."
useCustomTimeframeInput = input.bool(false, "Use custom timeframe", tooltip = lowerTimeframeTooltip, active = not useTicks, group = "CVD")
lowerTimeframeInput = input.timeframe("1", "Timeframe", active = useCustomTimeframeInput and not useTicks, group = "CVD")
autoFloorInput = input.string("5S", "Auto: finest timeframe", options = ["1S", "5S", "10S", "15S", "30S", "1"], tooltip = "When the lower timeframe is automatic, the indicator uses the finest timeframe at or above this value that is still below the chart timeframe. Finer data gives more precise delta but less history. 1S and 5S need a plan with seconds timeframes.", active = not useTicks and not useCustomTimeframeInput, group = "CVD")

// ─── Display ───
candleMode = input.string("Heikin Ashi", "CVD Candle Type", options = ["Heikin Ashi", "Linear Regression", "Regular"], tooltip = "Which version of the CVD candle is drawn. All signals below are calculated from the raw CVD candles regardless of this setting, except Absorption's Simple Disagreement mode, which compares against the displayed candle.", group = "Display")
lrLen      = input.int(7, "Linear Regression Length", minval = 2, group = "Display")
showZero   = input.bool(false, "Show Zero Line", tooltip = "A visible zero line forces the pane scale to include 0, which shrinks candles when CVD has drifted far from it. With Detrend on, the candles stay centered near zero, so the line costs little scale.", group = "Display")
detrend    = input.bool(true, "Detrend (center on rolling average)", tooltip = "Subtracts a rolling average of the candle close from all candle values so candles stay centered around zero and keep a readable size when CVD drifts. Candle shapes are unchanged; only the vertical position shifts.", group = "Display")
detrendLen = input.int(200, "Detrend Length", minval = 2, group = "Display")
swapColors = input.bool(false, "Swap Direction Colors", tooltip = "Off: up candles and bullish-read flags use the Oversold-side theme color, down candles and bearish-read flags use the Overbought-side theme color, matching the Volume Indicator. On: reversed. Absorption flags always use the Accent color.", group = "Display")
showAnchorMarkers = input.bool(true, "Show Anchor Reset Markers", group = "Display")
showHighlight      = input.bool(true, "Highlight Signal Bars (Indicator Pane)", tooltip = "Draws a translucent vertical band behind any bar that prints a signal, in this indicator's pane. Bullish-read signals use the up color, bearish-read signals use the down color.", group = "Display")
showPriceHighlight = input.bool(false, "Highlight Signal Bars (Price Chart)", tooltip = "Draws the same translucent vertical band on the main price chart.", group = "Display")
highlightTransp    = input.int(85, "Highlight Transparency", minval = 0, maxval = 100, tooltip = "0 is opaque, 100 is invisible. Applies to both highlights.", group = "Display")

// ─── Signals: master switches ───
showAbsorption = input.bool(true, "Absorption", tooltip = "Triangle in the theme accent color.\nAbove the candle: buying was absorbed (bearish read). Below the candle: selling was absorbed (bullish read).", group = "Signals")
showFlips = input.bool(true, "Turnaround", tooltip = "Larger triangle.\nAbove the candle: a run of buy-delta bars followed by a decisive sell flip (bearish). Below the candle: a run of sell-delta bars followed by a decisive buy flip (bullish).", group = "Signals")
showClimax = input.bool(false, "Delta Climax", tooltip = "Diamond.\nAbove the candle: buying climax (bearish read). Below the candle: selling climax (bullish read).", group = "Signals")
showReversal = input.bool(true, "Intrabar Reversal", tooltip = "Circle.\nAbove the candle: buy delta pushed up intrabar and was given back by the close (bearish read). Below the candle: sell delta pushed down and was recovered (bullish read).\n\nWhen several signals print on the same candle, they stack outward from the candle in the order listed here.", group = "Signals")

// ─── Signal: Absorption ───
absMode = input.string("Effort vs Result at Extremes", "Detection Mode", options = ["Effort vs Result at Extremes", "Effort vs Result", "Simple Disagreement"], tooltip = "Effort vs Result at Extremes: heavy delta with little price progress, only where price is at or just made a swing high (buying absorbed) or swing low (selling absorbed). Fewest flags.\nEffort vs Result: same, anywhere on the chart.\nSimple Disagreement: any bar where price and the displayed CVD candle close in opposite directions. Prints often.", group = "Signal: Absorption")
absDeltaMult = input.float(1.5, "Min Delta (x average)", minval = 0.1, step = 0.1, tooltip = "Bar delta must be at least this multiple of the average absolute bar delta.", group = "Signal: Absorption")
absProgress = input.float(0.15, "Max Price Progress (x ATR)", minval = 0.0, step = 0.05, tooltip = "Price movement in the direction of the delta (close minus open, in ATR units) must be at or below this value. Zero or negative means price stalled or moved against the delta.", group = "Signal: Absorption")
absAvgLen = input.int(50, "Average Length", minval = 5, group = "Signal: Absorption")
absExtLen = input.int(20, "Extreme Lookback", minval = 2, tooltip = "Swing high / low lookback used by the Extremes mode.", group = "Signal: Absorption")
absCooldown = input.int(5, "Min Bars Between Flags", minval = 0, tooltip = "Minimum bars between flags of the same direction.", group = "Signal: Absorption")

// ─── Signal: Turnaround ───
flipMinRun = input.int(3, "Min Prior Run (bars)", minval = 2, tooltip = "Minimum number of consecutive bars with the same delta direction before the flip bar.", group = "Signal: Turnaround")
flipDeltaMult = input.float(1.5, "Min Flip Delta (x average)", minval = 0.1, step = 0.1, tooltip = "Flip bar delta must be at least this multiple of the average absolute bar delta (uses the Average Length from Signal: Absorption).", group = "Signal: Turnaround")
flipRetrace = input.float(0.5, "Min Run Give-Back", minval = 0.0, step = 0.1, tooltip = "Flip bar delta must reverse at least this fraction of the prior run's net delta. 0.5 means the flip bar undoes half the run.", group = "Signal: Turnaround")
flipMinBody = input.float(0.5, "Min Price Body (x ATR)", minval = 0.0, step = 0.1, tooltip = "Price candle body in the flip direction, in ATR units (ATR length 14).", group = "Signal: Turnaround")
flipReqBreak = input.bool(true, "Require Break of Prior Bar", tooltip = "Bearish flip must close below the prior bar's low; bullish flip must close above the prior bar's high.", group = "Signal: Turnaround")
flipCooldown = input.int(5, "Min Bars Between Flags", minval = 0, group = "Signal: Turnaround")

// ─── Signal: Delta Climax ───
climaxLen = input.int(200, "Percentile Lookback", minval = 20, tooltip = "Number of bars the absolute bar delta is ranked against.", group = "Signal: Delta Climax")
climaxPct = input.float(95.0, "Min Delta Percentile", minval = 50.0, maxval = 100.0, step = 1.0, tooltip = "Absolute bar delta must rank at or above this percentile within the lookback.", group = "Signal: Delta Climax")
climaxReqExt = input.bool(true, "Require Swing Extreme", tooltip = "Buying climax only at or just after a swing high. Selling climax only at or just after a swing low. Off: any bar that ranks above the percentile.", group = "Signal: Delta Climax")
climaxExtLen = input.int(20, "Extreme Lookback", minval = 2, group = "Signal: Delta Climax")
climaxReject = input.float(0.0, "Min Close Rejection", minval = 0.0, maxval = 1.0, step = 0.05, tooltip = "Fraction of the price bar's range between the close and the extreme (the high after buying, the low after selling). 0 disables the check. 0.5 requires the close to be in the lower half of the bar after a buying climax, or the upper half after a selling climax.", group = "Signal: Delta Climax")
climaxCooldown = input.int(5, "Min Bars Between Flags", minval = 0, group = "Signal: Delta Climax")

// ─── Signal: Intrabar Reversal ───
revAvgLen = input.int(50, "Average Length", minval = 5, tooltip = "Length of the average CVD candle range used to size the intrabar push.", group = "Signal: Intrabar Reversal")
revPushMult = input.float(1.0, "Min Push (x avg range)", minval = 0.1, step = 0.1, tooltip = "How far CVD must move away from the candle open intrabar (CVD high minus open for buying, open minus CVD low for selling), as a multiple of the average CVD candle range.", group = "Signal: Intrabar Reversal")
revGiveBack = input.float(0.8, "Min Give-Back", minval = 0.1, maxval = 1.0, step = 0.05, tooltip = "Fraction of the intrabar push that must be reversed by the close. 1.0 means CVD closed back at the open.", group = "Signal: Intrabar Reversal")
revReqExt = input.bool(true, "Require Swing Extreme", tooltip = "Bearish only at or just after a swing high, bullish only at or just after a swing low. Off: prints on any bar that meets the push and give-back tests.", group = "Signal: Intrabar Reversal")
revExtLen = input.int(20, "Extreme Lookback", minval = 2, group = "Signal: Intrabar Reversal")
revCooldown = input.int(5, "Min Bars Between Flags", minval = 0, group = "Signal: Intrabar Reversal")

// ─── Color theme ───
color_theme = input.string("Modern", "Color Theme", options = ["Modern", "Neon", "Classic", "Gold Standard", "Infrared", "Arctic", "Vaporwave", "Matrix", "Terminal"], tooltip = "Same theme set as the Volume Indicator, CCO and FisherRSI. Up candles and bullish-read flags use the Oversold-side color, down candles and bearish-read flags use the Overbought-side color, absorption flags use the Accent color, and the zero line and anchor markers use the Neutral color. Overridden entirely if Use Custom Colors below is on.", group = "Color Theme")
use_custom_colors = input.bool(false, "Use Custom Colors (Override Theme)", tooltip = "Ignores the Color Theme above and uses the four colors below instead.", group = "Color Theme")
custom_bearish_color = input.color(#00D4AA, "Custom Oversold Color", group = "Color Theme")
custom_bullish_color = input.color(#FF073A, "Custom Overbought Color", group = "Color Theme")
custom_neutral_color = input.color(#9D4EDD, "Custom Neutral/Mixed Color", group = "Color Theme")
custom_accent_color = input.color(#FFC107, "Custom Accent Color (Absorption Flags)", group = "Color Theme")

// ═══════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════

// Finest candidate at or above the floor input that is still below the chart timeframe.
// If none qualifies (chart at or below the floor), fall back to 1S.
f_autoLowerTimeframe() =>
    int chartSec = timeframe.in_seconds()
    int floorSec = timeframe.in_seconds(autoFloorInput)
    string result = na
    for c in array.from("1S", "5S", "10S", "15S", "30S", "1", "5", "15", "60")
        int s = timeframe.in_seconds(c)
        if na(result) and s >= floorSec and s < chartSec
            result := c
    na(result) ? "1S" : result

// Each call site keeps its own state, so every flag has an independent cooldown.
// Flags print on bar close only.
f_cooldown(bool raw, int cooldown) =>
    var int last = na
    bool ok = raw and barstate.isconfirmed and (na(last) or bar_index - last >= cooldown)
    if ok
        last := bar_index
    ok

// Price is at, or within one bar of, the highest high / lowest low of the lookback.
f_nearHigh(int len) => ta.highest(high, 2) >= ta.highest(high, len)
f_nearLow(int len) => ta.lowest(low, 2) <= ta.lowest(low, len)

f_theme_colors() =>
    var color bearish = na, var color bullish = na, var color neutral = na, var color accent = na
    switch color_theme
        'Modern'        => bearish := #00D4AA, bullish := #FF073A, neutral := #9D4EDD, accent := #FFC107
        'Neon'          => bearish := #00FFFF, bullish := #FF00FF, neutral := #9932CC, accent := #FFFF00
        'Classic'       => bearish := color.rgb(0,200,83), bullish := color.rgb(255,23,68), neutral := color.rgb(136,136,136), accent := color.rgb(255,179,0)
        'Gold Standard' => bearish := #FFD700, bullish := #B0B0B0, neutral := #CD7F32, accent := #FFFFFF
        'Infrared'      => bearish := #FFFFFF, bullish := #CC0000, neutral := #882200, accent := #FF6600
        'Arctic'        => bearish := #A8D8FF, bullish := #4488CC, neutral := #3A5A8A, accent := #F0F8FF
        'Vaporwave'     => bearish := #FF6B9D, bullish := #9B30FF, neutral := #6622AA, accent := #00FFFF
        'Matrix'        => bearish := #00FF41, bullish := #007A1F, neutral := #003D0F, accent := #FFFFFF
        'Terminal'      => bearish := #00FF00, bullish := #FF6000, neutral := #707070, accent := #FFFFFF
    [bearish, bullish, neutral, accent]

// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════

[_theme_bearish, _theme_bullish, _theme_neutral, _theme_accent] = f_theme_colors()

theme_bearish = use_custom_colors ? custom_bearish_color : _theme_bearish
theme_bullish = use_custom_colors ? custom_bullish_color : _theme_bullish
theme_neutral = use_custom_colors ? custom_neutral_color : _theme_neutral
theme_accent = use_custom_colors ? custom_accent_color : _theme_accent

upColor = swapColors ? theme_bullish : theme_bearish
downColor = swapColors ? theme_bearish : theme_bullish
absColor = theme_accent
anchorMarkerColor = color.new(theme_neutral, 75)

// ═══════════════════════════════════════════════════════════════
// CVD
// ═══════════════════════════════════════════════════════════════

lowerTimeframe = switch
    useTicks                => "1T"
    useCustomTimeframeInput => lowerTimeframeInput
    => f_autoLowerTimeframe()

// ─── Timeframe anchor (official) ───
[lib_o, lib_h, lib_l, lib_c] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

// ─── Session anchor (own calculation from lower timeframe bars) ───
sessionTime  = time(timeframe.period, sessionInput, tzInput)
inSession    = not na(sessionTime)
sessionStart = inSession and not inSession[1]

signedVol = close > open ? volume : close < open ? -volume : close >= nz(close[1], close) ? volume : -volume
ltfDelta  = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, signedVol)
hasLtf    = not na(ltfDelta) and array.size(ltfDelta) > 0

var float sessCum = 0.0
if sessionStart
    sessCum := 0.0
float s_o = sessCum
float s_h = sessCum
float s_l = sessCum
float runCum = sessCum
if hasLtf
    for v in ltfDelta
        runCum += nz(v)
        s_h := math.max(s_h, runCum)
        s_l := math.min(s_l, runCum)
sessCum := runCum

useSession = anchorMode == "Session"
cvd_o = useSession ? (hasLtf ? s_o : na) : lib_o
cvd_h = useSession ? (hasLtf ? s_h : na) : lib_h
cvd_l = useSession ? (hasLtf ? s_l : na) : lib_l
cvd_c = useSession ? (hasLtf ? runCum : na) : lib_c

// ─── Anchor reset event ───
tfAnchorChange = timeframe.change(anchorInput)
newAnchor = useSession ? sessionStart : tfAnchorChange

// ─── Heikin Ashi of CVD ───
var float ha_o = na
ha_c = (cvd_o + cvd_h + cvd_l + cvd_c) / 4.0
ha_o := na(ha_o[1]) or newAnchor ? cvd_o : (ha_o[1] + nz(ha_c[1])) / 2.0
ha_h = math.max(cvd_h, math.max(ha_o, ha_c))
ha_l = math.min(cvd_l, math.min(ha_o, ha_c))

// ─── Linear Regression of CVD ───
lr_o = ta.linreg(cvd_o, lrLen, 0)
lr_h = ta.linreg(cvd_h, lrLen, 0)
lr_l = ta.linreg(cvd_l, lrLen, 0)
lr_c = ta.linreg(cvd_c, lrLen, 0)

// ─── Selected candle series ───
d_o = switch candleMode
    "Heikin Ashi"       => ha_o
    "Linear Regression" => lr_o
    => cvd_o
d_h = switch candleMode
    "Heikin Ashi"       => ha_h
    "Linear Regression" => lr_h
    => cvd_h
d_l = switch candleMode
    "Heikin Ashi"       => ha_l
    "Linear Regression" => lr_l
    => cvd_l
d_c = switch candleMode
    "Heikin Ashi"       => ha_c
    "Linear Regression" => lr_c
    => cvd_c

// ─── Optional detrend ───
baseline = detrend ? ta.sma(d_c, detrendLen) : 0.0
p_o = d_o - baseline
p_h = d_h - baseline
p_l = d_l - baseline
p_c = d_c - baseline

// ═══════════════════════════════════════════════════════════════
// SHARED SIGNAL INPUTS (raw CVD candle, price context)
// ═══════════════════════════════════════════════════════════════

barDelta    = cvd_c - cvd_o
avgAbsDelta = ta.sma(math.abs(barDelta), absAvgLen)
atrVal      = ta.atr(14)
deltaRatio  = avgAbsDelta > 0 ? barDelta / avgAbsDelta : na
progress    = atrVal > 0 ? (close - open) / atrVal : na
hasCvd      = not na(cvd_c)

// ═══════════════════════════════════════════════════════════════
// SIGNAL: ABSORPTION
// ═══════════════════════════════════════════════════════════════

heavyBuy  = deltaRatio >= absDeltaMult
heavySell = deltaRatio <= -absDeltaMult
stallUp   = progress <= absProgress
stallDown = -progress <= absProgress
absNearHigh = f_nearHigh(absExtLen)
absNearLow  = f_nearLow(absExtLen)

// Bear: buying absorbed. Bull: selling absorbed.
rawAbsBear = switch absMode
    "Simple Disagreement" => close < open and p_c > p_o
    "Effort vs Result"    => heavyBuy and stallUp
    => heavyBuy and stallUp and absNearHigh
rawAbsBull = switch absMode
    "Simple Disagreement" => close > open and p_c < p_o
    "Effort vs Result"    => heavySell and stallDown
    => heavySell and stallDown and absNearLow

absBearFlag = f_cooldown(showAbsorption and rawAbsBear, absCooldown)
absBullFlag = f_cooldown(showAbsorption and rawAbsBull, absCooldown)

// ═══════════════════════════════════════════════════════════════
// SIGNAL: TURNAROUND (run of same-direction delta, then a decisive flip)
// ═══════════════════════════════════════════════════════════════

int dirSign = barDelta > 0 ? 1 : barDelta < 0 ? -1 : 0
var int runLen = 0
var float runSum = 0.0
bool sameDir = dirSign != 0 and dirSign == dirSign[1]
runLen := sameDir ? nz(runLen[1]) + 1 : (dirSign != 0 ? 1 : 0)
runSum := sameDir ? nz(runSum[1]) + barDelta : (dirSign != 0 ? barDelta : 0.0)

prevRun = nz(runLen[1])
prevSum = nz(runSum[1])
giveBack = prevSum != 0 ? -barDelta / prevSum : na

rawFlipBear = dirSign == -1 and dirSign[1] == 1 and prevRun >= flipMinRun and -barDelta >= flipDeltaMult * avgAbsDelta and -barDelta >= flipRetrace * math.abs(prevSum) and (open - close) >= flipMinBody * atrVal and (not flipReqBreak or close < low[1])
rawFlipBull = dirSign == 1 and dirSign[1] == -1 and prevRun >= flipMinRun and barDelta >= flipDeltaMult * avgAbsDelta and barDelta >= flipRetrace * math.abs(prevSum) and (close - open) >= flipMinBody * atrVal and (not flipReqBreak or close > high[1])

flipBearFlag = f_cooldown(showFlips and rawFlipBear, flipCooldown)
flipBullFlag = f_cooldown(showFlips and rawFlipBull, flipCooldown)

// ═══════════════════════════════════════════════════════════════
// SIGNAL: DELTA CLIMAX (outsized bar delta, usually at a swing extreme)
// ═══════════════════════════════════════════════════════════════

deltaPct = ta.percentrank(math.abs(barDelta), climaxLen)
climaxNearHigh = f_nearHigh(climaxExtLen)
climaxNearLow = f_nearLow(climaxExtLen)
barRange = high - low
climaxRejectBear = climaxReject <= 0.0 or (barRange > 0 and (high - close) / barRange >= climaxReject)
climaxRejectBull = climaxReject <= 0.0 or (barRange > 0 and (close - low) / barRange >= climaxReject)
isClimax = deltaPct >= climaxPct

// Bear: buying climax. Bull: selling climax.
rawClimaxBear = isClimax and barDelta > 0 and (not climaxReqExt or climaxNearHigh) and climaxRejectBear
rawClimaxBull = isClimax and barDelta < 0 and (not climaxReqExt or climaxNearLow) and climaxRejectBull

climaxBearFlag = f_cooldown(showClimax and rawClimaxBear, climaxCooldown)
climaxBullFlag = f_cooldown(showClimax and rawClimaxBull, climaxCooldown)

// ═══════════════════════════════════════════════════════════════
// SIGNAL: INTRABAR REVERSAL (CVD pushed one way inside the bar, closed back)
// ═══════════════════════════════════════════════════════════════

avgCvdRange = ta.sma(cvd_h - cvd_l, revAvgLen)
upPush = cvd_h - cvd_o
downPush = cvd_o - cvd_l
upGiveBack = upPush > 0 ? (cvd_h - cvd_c) / upPush : na
downGiveBack = downPush > 0 ? (cvd_c - cvd_l) / downPush : na
revNearHigh = f_nearHigh(revExtLen)
revNearLow = f_nearLow(revExtLen)

// Bear: buy push given back. Bull: sell push recovered. The larger excursion decides which side applies.
rawRevBear = avgCvdRange > 0 and upPush >= revPushMult * avgCvdRange and upPush > downPush and upGiveBack >= revGiveBack and (not revReqExt or revNearHigh)
rawRevBull = avgCvdRange > 0 and downPush >= revPushMult * avgCvdRange and downPush > upPush and downGiveBack >= revGiveBack and (not revReqExt or revNearLow)

revBearFlag = f_cooldown(showReversal and rawRevBear, revCooldown)
revBullFlag = f_cooldown(showReversal and rawRevBull, revCooldown)

// ═══════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════

plot(showZero ? 0.0 : na, "Zero", color = color.new(theme_neutral, 50), editable = false)

bgcolor(showAnchorMarkers and newAnchor ? anchorMarkerColor : na, title = "Anchor Reset")

candleColor = p_c >= p_o ? upColor : downColor
plotcandle(p_o, p_h, p_l, p_c, "CVD", color = candleColor, bordercolor = candleColor, wickcolor = candleColor)

// ─── Flag stacking ───
// When several signals print on the same candle, each takes the next slot outward from the candle.
// Order from the candle: Absorption, Turnaround, Delta Climax, Intrabar Reversal.
absOffset = nz(ta.sma(p_h - p_l, 20)) * 0.5
slotStep = 1.5

bearSlotFlip = absBearFlag ? 1 : 0
bearSlotClimax = bearSlotFlip + (flipBearFlag ? 1 : 0)
bearSlotRev = bearSlotClimax + (climaxBearFlag ? 1 : 0)

bullSlotFlip = absBullFlag ? 1 : 0
bullSlotClimax = bullSlotFlip + (flipBullFlag ? 1 : 0)
bullSlotRev = bullSlotClimax + (climaxBullFlag ? 1 : 0)

// Absorption: triangle
plotshape(absBearFlag ? p_h + absOffset : na, "Absorption: buying absorbed", style = shape.triangledown, location = location.absolute, color = absColor, size = size.tiny)
plotshape(absBullFlag ? p_l - absOffset : na, "Absorption: selling absorbed", style = shape.triangleup, location = location.absolute, color = absColor, size = size.tiny)

// Turnaround: larger triangle
plotshape(flipBearFlag ? p_h + absOffset * (1.0 + slotStep * bearSlotFlip) : na, "Turnaround: bearish", style = shape.triangledown, location = location.absolute, color = downColor, size = size.small)
plotshape(flipBullFlag ? p_l - absOffset * (1.0 + slotStep * bullSlotFlip) : na, "Turnaround: bullish", style = shape.triangleup, location = location.absolute, color = upColor, size = size.small)

// Delta Climax: diamond
plotshape(climaxBearFlag ? p_h + absOffset * (1.0 + slotStep * bearSlotClimax) : na, "Delta Climax: buying climax", style = shape.diamond, location = location.absolute, color = downColor, size = size.small)
plotshape(climaxBullFlag ? p_l - absOffset * (1.0 + slotStep * bullSlotClimax) : na, "Delta Climax: selling climax", style = shape.diamond, location = location.absolute, color = upColor, size = size.small)

// Intrabar Reversal: circle
plotshape(revBearFlag ? p_h + absOffset * (1.0 + slotStep * bearSlotRev) : na, "Intrabar Reversal: bearish", style = shape.circle, location = location.absolute, color = downColor, size = size.small)
plotshape(revBullFlag ? p_l - absOffset * (1.0 + slotStep * bullSlotRev) : na, "Intrabar Reversal: bullish", style = shape.circle, location = location.absolute, color = upColor, size = size.small)

// ─── Signal bar highlight ───
anyBullFlag = absBullFlag or flipBullFlag or climaxBullFlag or revBullFlag
anyBearFlag = absBearFlag or flipBearFlag or climaxBearFlag or revBearFlag

bgcolor(showHighlight and anyBullFlag ? color.new(upColor, highlightTransp) : na, title = "Highlight: bullish-read signal")
bgcolor(showHighlight and anyBearFlag ? color.new(downColor, highlightTransp) : na, title = "Highlight: bearish-read signal")

// Same bands drawn on the main price chart
bgcolor(showPriceHighlight and anyBullFlag ? color.new(upColor, highlightTransp) : na, title = "Price Highlight: bullish-read signal", force_overlay = true)
bgcolor(showPriceHighlight and anyBearFlag ? color.new(downColor, highlightTransp) : na, title = "Price Highlight: bearish-read signal", force_overlay = true)

// Data window only
plot(prevRun, "Prior Run Length", display = display.data_window)
plot(giveBack, "Run Give-Back (flip delta / prior run net)", display = display.data_window)
plot(deltaRatio, "Bar Delta / Avg |Delta|", display = display.data_window)
plot(progress, "Price Progress / ATR", display = display.data_window)
plot(deltaPct, "Delta Percentile (|bar delta| rank)", display = display.data_window)
plot(upGiveBack, "Intrabar Give-Back (buy push)", display = display.data_window)
plot(downGiveBack, "Intrabar Give-Back (sell push)", display = display.data_window)

// ═══════════════════════════════════════════════════════════════
// DATA CHECKS
// ═══════════════════════════════════════════════════════════════

var cumVol = 0.
cumVol += nz(volume)
deltaIsNa = na(cvd_o) and na(cvd_h) and na(cvd_l) and na(cvd_c)
if barstate.islast
    if cumVol == 0
        runtime.error("The data vendor doesn't provide volume data for this symbol.")
    if str.endswith(lowerTimeframe, "T") and deltaIsNa
        runtime.error("Not enough tick depth for the current anchor period. The available tick depth ends before reaching the start of the anchor period (" + anchorInput + "). Please shorten the 'Anchor period' input or switch the calculation base from '1 Tick' to 'Time' or higher custom timeframe.")
````
