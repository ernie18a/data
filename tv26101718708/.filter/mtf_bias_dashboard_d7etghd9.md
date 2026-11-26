# MTF Bias Dashboard

- url: https://www.tradingview.com/script/D7eTGhD9-MTF-Bias-Dashboard/
- type: indicator
- pine_id: PUB;da89730a7ede4d3bb9d2b61531408bc7
- version: 1.0

## Description

[b]MTF Bias Dashboard[/b]

MTF Bias Dashboard is a multi-timeframe trend and confluence dashboard for traders who want fast directional context across liquid markets. It is designed to answer one question quickly:

[b]Is this symbol aligned enough to trade, or should I wait?[/b]

The indicator combines 1m, 5m, 15m, 30m, 1H, 4H, and 1D trend data on the active chart symbol, so you can see whether a short-term move is likely part of the bigger trend, a pullback, or a lower-quality conflict.

[b]The Dashboard: Read It From Top To Bottom[/b]
[list=1]
[*][b]ACTION[/b] - This is the first cell to read. It gives the current bias state: NO TRADE, WAIT, LONG WATCH, SHORT WATCH, LONG ONLY, SHORT ONLY, LONG BIAS, or SHORT BIAS.
[*][b]WHY[/b] - Explains the main reason behind the action, such as H1/4H disagree, Low volatility, HTF risk, Strong bull confluence, or Bear regime only.
[*][b]TF Rows[/b] - These are diagnostics for each timeframe. Use them to see which timeframe agrees or disagrees.
[*][b]SESSION[/b] - Shows London, New York, London/New York overlap, Asia, or off-hours, plus the session multiplier.
[/list]

[b]How To Decide If It Is A Good Time To Enter[/b]
[list=1]
[*]Start with [b]ACTION[/b].
[*]If ACTION says [b]NO TRADE[/b], do not enter. The dashboard is blocking the setup.
[*]If ACTION says [b]WAIT[/b], there is no clean edge yet.
[*]If ACTION says [b]LONG WATCH[/b] or [b]SHORT WATCH[/b], the intraday regime is starting to lean one way, but confluence is not strong enough yet.
[*]If ACTION says [b]LONG ONLY[/b] or [b]SHORT ONLY[/b], only look for your own setups in that direction. Do not chase immediately unless your execution plan confirms.
[*]If ACTION says [b]LONG BIAS[/b] or [b]SHORT BIAS[/b], confluence is strong in that direction, but entries are still discretionary.
[*]Check [b]WHY[/b] before entering. If it says H1/4H disagree, Low volatility, HTF risk, or No clean setup, the trade quality is weaker.
[*]Use the 5m, 15m, 30m, and 1H rows to confirm your entry chart agrees with the active intraday direction.
[/list]

[b]Dashboard Terms[/b]
[list]
[*][b]SCORE[/b] - A confluence score from -100 to +100. Positive favors long bias. Negative favors short bias.
[*][b]H1+4H BULL[/b] - 1H and 4H are both bullish enough to prefer long setups.
[*][b]H1+4H BEAR[/b] - 1H and 4H are both bearish enough to prefer short setups.
[*][b]H1/4H CONFLICT[/b] - 1H and 4H disagree. In Aggressive and Balanced presets this is a context warning; in Conservative preset it blocks trades.
[*][b]HTF RISK[/b] - The active intraday direction is fighting 4H or 1D context.
[*][b]LIVE[/b] - Preview score from the currently forming candle. It can change before that timeframe closes.
[*][b]ATR / EMA[/b] - Shows volatility condition and whether that timeframe's EMA stack is bullish, bearish, or mixed.
[/list]

[b]Chart Lines[/b]
The indicator can plot local and higher-timeframe moving averages. These are visual context lines, not automatic entry signals.

[list]
[*][b]Local EMA 9[/b] - Cyan. Fast current-chart momentum.
[*][b]Local EMA 21[/b] - Yellow. Short-term pullback/momentum guide.
[*][b]Local EMA 50[/b] - White. Current-chart trend guide.
[*][b]1H EMA 50[/b] - Orange. 1-hour dynamic support/resistance.
[*][b]1H EMA 200[/b] - Dark orange. Major 1-hour structure level.
[*][b]4H EMA 50[/b] - Magenta. 4-hour dynamic support/resistance.
[*][b]4H EMA 200[/b] - Purple. Major 4-hour structure level.
[/list]

[i]Practical use: if the dashboard is bearish and price bounces into a level you care about, such as a fib zone or moving average area, the dashboard helps confirm whether the broader intraday context still supports short-only thinking. The same applies in reverse for bullish pullbacks.[/i]

[b]How The Trend Score Works[/b]
Each timeframe is scored using:
[list]
[*]EMA stack alignment.
[*]EMA slope normalized by ATR.
[*]RSI regime and RSI direction.
[*]Price location versus the EMA band.
[*]VWAP location when available.
[*]Volatility quality using ATR versus its baseline.
[/list]

[b]Bias Presets And Default Weighting[/b]
[list]
[*][b]Aggressive[/b] - Prioritizes 5m, 15m, 30m, and 1H. 4H is light context.
[*][b]Balanced[/b] - Default. Uses 15m, 30m, and 1H as the main intraday stack, with 4H as context.
[*][b]Conservative[/b] - Requires stronger 1H/4H agreement and gives 4H more influence.
[*][b]1D[/b] - Shown as regime context only. It is not part of the confluence weight.
[/list]

[b]Confirmed vs Live Preview[/b]
The main ACTION, WHY, SCORE, and alerts use confirmed multi-timeframe values to reduce repainting. The LIVE column is only an early preview and can change before the candle closes.

[b]Session Weighting[/b]
London, New York, and the London/New York overlap receive higher confidence. Asia and off-hours receive lower confidence because intraday conditions can be less reliable.

[b]Alerts Included[/b]
[list]
[*]Strong Long Bias
[*]Strong Short Bias
[*]HTF Conflict / No-Trade Warning
[/list]

[b]Important Notes[/b]
[list]
[*]This is an indicator, not an automated strategy.
[*]Use it with your own risk management and execution rules.
[*]The dashboard shows multi-timeframe bias and context. It does not mark exact entries.
[*]The cleanest intraday setups usually come when 5m, 15m, 30m, and 1H agree, then price pulls back into a meaningful zone and stalls according to your own execution plan.
[*]4H and 1D are context layers. In Aggressive and Balanced presets they warn about regime risk instead of automatically blocking every trade.
[*]For the cleanest alerts, keep "Alerts only on confirmed chart bars" enabled.
[/list]

## Source Code

````pine
//@version=6
indicator("MTF Bias Dashboard", "MTF Bias", overlay=true, max_labels_count=100, max_lines_count=100)

// MTF Bias Dashboard is a discretionary multi-timeframe bias dashboard.
// Confirmed MTF values drive bias and alerts. Live values are preview-only.

// === Inputs ===
string GP_TIMEFRAMES = "Timeframes"
string tfM1 = input.timeframe("1", "1m timeframe", group=GP_TIMEFRAMES, display=display.none)
string tfM5 = input.timeframe("5", "5m timeframe", group=GP_TIMEFRAMES, display=display.none)
string tfM15 = input.timeframe("15", "15m timeframe", group=GP_TIMEFRAMES, display=display.none)
string tfM30 = input.timeframe("30", "30m timeframe", group=GP_TIMEFRAMES, display=display.none)
string tfH1 = input.timeframe("60", "1H timeframe", group=GP_TIMEFRAMES, display=display.none)
string tfH4 = input.timeframe("240", "4H timeframe", group=GP_TIMEFRAMES, display=display.none)
string tfD1 = input.timeframe("D", "1D timeframe", group=GP_TIMEFRAMES, display=display.none)
string entryMode = input.string("5m", "Entry weighting", options=["5m", "15m"], group=GP_TIMEFRAMES, display=display.none)
string scalpPreset = input.string("Balanced", "Bias preset", options=["Aggressive", "Balanced", "Conservative"], group=GP_TIMEFRAMES, display=display.none)

string GP_SETTINGS = "Trend Engine"
int fastLen = input.int(9, "Fast EMA", minval=1, maxval=100, group=GP_SETTINGS, display=display.none)
int midLen = input.int(21, "Mid EMA", minval=2, maxval=200, group=GP_SETTINGS, display=display.none)
int slowLen = input.int(50, "Slow EMA", minval=5, maxval=300, group=GP_SETTINGS, display=display.none)
int structureLen = input.int(200, "Structure EMA", minval=20, maxval=500, group=GP_SETTINGS, display=display.none)
int rsiLen = input.int(14, "RSI length", minval=2, maxval=100, group=GP_SETTINGS, display=display.none)
int rsiSmoothLen = input.int(3, "RSI smoothing", minval=1, maxval=25, group=GP_SETTINGS, display=display.none)
int atrLen = input.int(14, "ATR length", minval=2, maxval=100, group=GP_SETTINGS, display=display.none)
int atrBaseLen = input.int(50, "ATR baseline", minval=10, maxval=300, group=GP_SETTINGS, display=display.none)
int slopeLookback = input.int(5, "EMA slope lookback", minval=1, maxval=50, group=GP_SETTINGS, display=display.none)
int maxBarsBack = input.int(800, "MTF calculation bars", minval=300, maxval=5000, group=GP_SETTINGS, display=display.none)

string GP_THRESHOLDS = "Signals"
float trendThreshold = input.float(25.0, "Trend threshold", minval=5.0, maxval=60.0, step=1.0, group=GP_THRESHOLDS, display=display.none)
float strongThreshold = input.float(65.0, "Strong bias threshold", minval=40.0, maxval=95.0, step=1.0, group=GP_THRESHOLDS, display=display.none)
bool requireConfirmedAlerts = input.bool(true, "Alerts only on confirmed chart bars", group=GP_THRESHOLDS, display=display.none)

string GP_SESSIONS = "Sessions"
bool useSessionWeighting = input.bool(true, "Weight NY/London sessions", group=GP_SESSIONS, display=display.none)
string londonSession = input.session("0700-1600:1234567", "London session", group=GP_SESSIONS, display=display.none)
string londonTimezone = input.string("Europe/London", "London timezone", group=GP_SESSIONS, display=display.none)
string newYorkSession = input.session("0800-1700:1234567", "New York session", group=GP_SESSIONS, display=display.none)
string newYorkTimezone = input.string("America/New_York", "New York timezone", group=GP_SESSIONS, display=display.none)
string asiaSession = input.session("0800-1600:1234567", "Asia reference session", group=GP_SESSIONS, display=display.none)
string asiaTimezone = input.string("Asia/Tokyo", "Asia timezone", group=GP_SESSIONS, display=display.none)

string GP_DISPLAY = "Display"
string tablePositionInput = input.string("Top Right", "Dashboard position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=GP_DISPLAY, display=display.none)
string themeInput = input.string("Auto", "Dashboard theme", options=["Auto", "Dark", "Light"], group=GP_DISPLAY, display=display.none)
bool showLivePreview = input.bool(true, "Show live preview score", group=GP_DISPLAY, display=display.none)
bool showLocalEmas = input.bool(true, "Show current timeframe EMA 9/21/50", group=GP_DISPLAY, display=display.none)
bool showHtfEmas = input.bool(true, "Show 1H/4H EMA 50/200", group=GP_DISPLAY, display=display.none)

// === Utilities ===
clampValue(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

isLightTheme(color bgColor = chart.bg_color) =>
    float brightness = (color.r(bgColor) + color.g(bgColor) + color.b(bgColor)) / (3.0 * 255.0)
    brightness > 0.55

getTablePosition(string pos) =>
    switch pos
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

scoreDirection(float score, float threshold) =>
    score >= threshold ? 1 : score <= -threshold ? -1 : 0

scoreText(float score) =>
    str.tostring(score, "#")

rsiText(float value) =>
    str.tostring(value, "#.#")

trendLabel(float score) =>
    score >= 65 ? "STRONG UP" :
     score >= 25 ? "UP" :
     score <= -65 ? "STRONG DOWN" :
     score <= -25 ? "DOWN" :
     "MIXED"

stackLabel(float priceValue, float emaFast, float emaMid, float emaSlow) =>
    emaFast > emaMid and emaMid > emaSlow and priceValue > emaMid ? "BULL" :
     emaFast < emaMid and emaMid < emaSlow and priceValue < emaMid ? "BEAR" :
     "MIXED"

getScoreBg(float score) =>
    score >= 65 ? color.new(color.lime, 18) :
     score >= 25 ? color.new(color.green, 30) :
     score <= -65 ? color.new(color.red, 15) :
     score <= -25 ? color.new(color.maroon, 25) :
     color.new(color.gray, 55)

getWeights(string mode, string preset) =>
    float _wM1 = 0.05
    float _wM5 = 0.18
    float _wM15 = 0.23
    float _wM30 = 0.18
    float _wH1 = 0.28
    float _wH4 = 0.08

    if preset == "Aggressive"
        if mode == "5m"
            _wM1 := 0.08
            _wM5 := 0.22
            _wM15 := 0.24
            _wM30 := 0.16
            _wH1 := 0.24
            _wH4 := 0.06
        else
            _wM1 := 0.03
            _wM5 := 0.13
            _wM15 := 0.24
            _wM30 := 0.22
            _wH1 := 0.30
            _wH4 := 0.08
    else if preset == "Conservative"
        if mode == "5m"
            _wM1 := 0.03
            _wM5 := 0.10
            _wM15 := 0.17
            _wM30 := 0.15
            _wH1 := 0.30
            _wH4 := 0.25
        else
            _wM1 := 0.01
            _wM5 := 0.06
            _wM15 := 0.17
            _wM30 := 0.18
            _wH1 := 0.32
            _wH4 := 0.26
    else
        if mode == "15m"
            _wM1 := 0.02
            _wM5 := 0.10
            _wM15 := 0.22
            _wM30 := 0.22
            _wH1 := 0.32
            _wH4 := 0.12

    float _total = _wM1 + _wM5 + _wM15 + _wM30 + _wH1 + _wH4
    [_wM1 / _total, _wM5 / _total, _wM15 / _total, _wM30 / _total, _wH1 / _total, _wH4 / _total]

// === Trend engine ===
calcTfLive() =>
    float emaFast = ta.ema(close, fastLen)
    float emaMid = ta.ema(close, midLen)
    float emaSlow = ta.ema(close, slowLen)
    float emaStructure = ta.ema(close, structureLen)

    float atrValue = ta.atr(atrLen)
    float atrSafe = math.max(nz(atrValue, syminfo.mintick), syminfo.mintick)
    float atrBase = nz(ta.sma(atrValue, atrBaseLen), atrSafe)
    float atrRatio = atrBase > 0 ? clampValue(atrValue / atrBase, 0.25, 3.0) : 1.0

    float rsiRaw = ta.rsi(close, rsiLen)
    float rsiSmooth = nz(ta.ema(rsiRaw, rsiSmoothLen), 50.0)
    float rsiSlope = rsiSmooth - nz(rsiSmooth[3], rsiSmooth)

    float stackScore = emaFast > emaMid and emaMid > emaSlow ? 30.0 :
         emaFast < emaMid and emaMid < emaSlow ? -30.0 :
         emaFast > emaSlow ? 12.0 :
         emaFast < emaSlow ? -12.0 : 0.0

    float emaSlopeAtr = (emaSlow - nz(emaSlow[slopeLookback], emaSlow)) / atrSafe
    float slopeScore = clampValue(emaSlopeAtr * 12.0, -25.0, 25.0)

    float rsiRegimeScore = rsiSmooth >= 60.0 ? 18.0 :
         rsiSmooth >= 55.0 ? 10.0 :
         rsiSmooth <= 40.0 ? -18.0 :
         rsiSmooth <= 45.0 ? -10.0 : 0.0
    float rsiSlopeScore = clampValue(rsiSlope * 2.0, -12.0, 12.0)

    float bandTop = math.max(emaFast, math.max(emaMid, emaSlow))
    float bandBottom = math.min(emaFast, math.min(emaMid, emaSlow))
    float bandMid = (bandTop + bandBottom) / 2.0
    float locationScore = close > bandTop ? 15.0 :
         close < bandBottom ? -15.0 :
         close > bandMid ? 6.0 :
         close < bandMid ? -6.0 : 0.0

    float vwapValue = ta.vwap(hlc3)
    float vwapScore = na(vwapValue) ? 0.0 : close > vwapValue ? 8.0 : -8.0
    float rawScore = stackScore + slopeScore + rsiRegimeScore + rsiSlopeScore + locationScore + vwapScore
    float volatilityQuality = atrRatio < 0.65 ? 0.70 : atrRatio > 2.20 ? 0.85 : 1.0
    float score = clampValue(rawScore * volatilityQuality, -100.0, 100.0)
    float distanceFromMidAtr = (close - emaMid) / atrSafe

    [score, rsiSmooth, rsiSlope, atrRatio, close, emaFast, emaMid, emaSlow, emaStructure, vwapValue, distanceFromMidAtr]

calcTfConfirmed() =>
    [score, rsiSmooth, rsiSlope, atrRatio, priceValue, emaFast, emaMid, emaSlow, emaStructure, vwapValue, distanceFromMidAtr] = calcTfLive()
    [score[1], rsiSmooth[1], rsiSlope[1], atrRatio[1], priceValue[1], emaFast[1], emaMid[1], emaSlow[1], emaStructure[1], vwapValue[1], distanceFromMidAtr[1]]

calcLiveScore() =>
    [score, rsiSmooth, rsiSlope, atrRatio, priceValue, emaFast, emaMid, emaSlow, emaStructure, vwapValue, distanceFromMidAtr] = calcTfLive()
    score

// === MTF data requests ===
[m1Score, m1Rsi, m1RsiSlope, m1AtrRatio, m1Close, m1EmaFast, m1EmaMid, m1EmaSlow, m1EmaStructure, m1Vwap, m1Distance] = request.security(syminfo.tickerid, tfM1, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)
[m5Score, m5Rsi, m5RsiSlope, m5AtrRatio, m5Close, m5EmaFast, m5EmaMid, m5EmaSlow, m5EmaStructure, m5Vwap, m5Distance] = request.security(syminfo.tickerid, tfM5, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)
[m15Score, m15Rsi, m15RsiSlope, m15AtrRatio, m15Close, m15EmaFast, m15EmaMid, m15EmaSlow, m15EmaStructure, m15Vwap, m15Distance] = request.security(syminfo.tickerid, tfM15, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)
[m30Score, m30Rsi, m30RsiSlope, m30AtrRatio, m30Close, m30EmaFast, m30EmaMid, m30EmaSlow, m30EmaStructure, m30Vwap, m30Distance] = request.security(syminfo.tickerid, tfM30, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)
[h1Score, h1Rsi, h1RsiSlope, h1AtrRatio, h1Close, h1EmaFast, h1EmaMid, h1EmaSlow, h1EmaStructure, h1Vwap, h1Distance] = request.security(syminfo.tickerid, tfH1, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)
[h4Score, h4Rsi, h4RsiSlope, h4AtrRatio, h4Close, h4EmaFast, h4EmaMid, h4EmaSlow, h4EmaStructure, h4Vwap, h4Distance] = request.security(syminfo.tickerid, tfH4, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)
[d1Score, d1Rsi, d1RsiSlope, d1AtrRatio, d1Close, d1EmaFast, d1EmaMid, d1EmaSlow, d1EmaStructure, d1Vwap, d1Distance] = request.security(syminfo.tickerid, tfD1, calcTfConfirmed(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on, calc_bars_count=maxBarsBack)

float m1LiveScore = request.security(syminfo.tickerid, tfM1, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)
float m5LiveScore = request.security(syminfo.tickerid, tfM5, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)
float m15LiveScore = request.security(syminfo.tickerid, tfM15, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)
float m30LiveScore = request.security(syminfo.tickerid, tfM30, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)
float h1LiveScore = request.security(syminfo.tickerid, tfH1, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)
float h4LiveScore = request.security(syminfo.tickerid, tfH4, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)
float d1LiveScore = request.security(syminfo.tickerid, tfD1, calcLiveScore(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=maxBarsBack)

// === Confluence and sessions ===
[wM1, wM5, wM15, wM30, wH1, wH4] = getWeights(entryMode, scalpPreset)

float rawConfluence = (m1Score * wM1) + (m5Score * wM5) + (m15Score * wM15) + (m30Score * wM30) + (h1Score * wH1) + (h4Score * wH4)
float avgAtrRatio = (m1AtrRatio * wM1) + (m5AtrRatio * wM5) + (m15AtrRatio * wM15) + (m30AtrRatio * wM30) + (h1AtrRatio * wH1) + (h4AtrRatio * wH4)

bool inLondon = not na(time(timeframe.period, londonSession, londonTimezone))
bool inNewYork = not na(time(timeframe.period, newYorkSession, newYorkTimezone))
bool inAsia = not na(time(timeframe.period, asiaSession, asiaTimezone))
bool inOverlap = inLondon and inNewYork
float sessionFactor = not useSessionWeighting ? 1.0 : inOverlap ? 1.15 : inLondon or inNewYork ? 1.08 : inAsia ? 0.92 : 0.85
string sessionName = inOverlap ? "LON+NY" : inNewYork ? "NY" : inLondon ? "LONDON" : inAsia ? "ASIA" : "OFF-HOURS"

bool lowVolatility = avgAtrRatio < 0.70
float volatilityFactor = lowVolatility ? 0.82 : 1.0
float confluenceScore = clampValue(rawConfluence * sessionFactor * volatilityFactor, -100.0, 100.0)

int h1Dir = scoreDirection(h1Score, trendThreshold)
int h4Dir = scoreDirection(h4Score, trendThreshold)
int d1Dir = scoreDirection(d1Score, trendThreshold)
bool htfBull = h1Dir == 1 and h4Dir == 1
bool htfBear = h1Dir == -1 and h4Dir == -1
bool htfConflict = (h1Dir == 1 and h4Dir == -1) or (h1Dir == -1 and h4Dir == 1)
bool hardHtfConflict = scalpPreset == "Conservative" and htfConflict

bool regimeBull = scalpPreset == "Conservative" ? h1Dir == 1 and h4Dir == 1 :
     scalpPreset == "Aggressive" ? h1Dir == 1 and m15Score > 0 and m5Score > -trendThreshold :
     h1Dir == 1 and m15Score >= trendThreshold and m30Score > -trendThreshold
bool regimeBear = scalpPreset == "Conservative" ? h1Dir == -1 and h4Dir == -1 :
     scalpPreset == "Aggressive" ? h1Dir == -1 and m15Score < 0 and m5Score < trendThreshold :
     h1Dir == -1 and m15Score <= -trendThreshold and m30Score < trendThreshold
bool contextRiskLong = regimeBull and (h4Dir == -1 or d1Dir == -1)
bool contextRiskShort = regimeBear and (h4Dir == 1 or d1Dir == 1)
bool contextRisk = contextRiskLong or contextRiskShort

bool strongLongBias = not hardHtfConflict and regimeBull and confluenceScore >= strongThreshold
bool strongShortBias = not hardHtfConflict and regimeBear and confluenceScore <= -strongThreshold
bool longBias = not hardHtfConflict and regimeBull and confluenceScore >= trendThreshold
bool shortBias = not hardHtfConflict and regimeBear and confluenceScore <= -trendThreshold

string qualityState = hardHtfConflict ? "HTF CONFLICT" :
     lowVolatility ? "LOW VOL" :
     contextRisk ? "HTF RISK" :
     math.abs(confluenceScore) < trendThreshold ? "MIXED" :
     "CLEAN"

string actionState = hardHtfConflict ? "NO TRADE" :
     strongLongBias ? "LONG BIAS" :
     strongShortBias ? "SHORT BIAS" :
     longBias ? "LONG ONLY" :
     shortBias ? "SHORT ONLY" :
     regimeBull ? "LONG WATCH" :
     regimeBear ? "SHORT WATCH" :
     "WAIT"

string reasonState = hardHtfConflict ? "H1/4H disagree" :
     lowVolatility ? "Low volatility" :
     contextRiskLong ? "Long against HTF" :
     contextRiskShort ? "Short against HTF" :
     strongLongBias ? "Strong bull confluence" :
     strongShortBias ? "Strong bear confluence" :
     longBias ? "Bull regime only" :
     shortBias ? "Bear regime only" :
     regimeBull ? "Bull regime forming" :
     regimeBear ? "Bear regime forming" :
     "No clean setup"

string htfStateText = htfBull ? "H1+4H BULL" :
     htfBear ? "H1+4H BEAR" :
     htfConflict ? "H1/4H CONFLICT" :
     "HTF MIXED"

bool actionIsLong = actionState == "LONG BIAS" or actionState == "LONG ONLY" or actionState == "LONG WATCH"
bool actionIsShort = actionState == "SHORT BIAS" or actionState == "SHORT ONLY" or actionState == "SHORT WATCH"
color actionBg = actionIsLong ? color.new(color.lime, 15) :
     actionIsShort ? color.new(color.red, 15) :
     actionState == "NO TRADE" ? color.new(color.red, 10) :
     color.new(color.gray, 55)

// === Chart overlays ===
float localEmaFast = ta.ema(close, fastLen)
float localEmaMid = ta.ema(close, midLen)
float localEmaSlow = ta.ema(close, slowLen)

plot(showLocalEmas ? localEmaFast : na, "Local EMA 9", color=color.new(color.aqua, 0), linewidth=1, display=display.all - display.status_line)
plot(showLocalEmas ? localEmaMid : na, "Local EMA 21", color=color.new(color.yellow, 0), linewidth=1, display=display.all - display.status_line)
plot(showLocalEmas ? localEmaSlow : na, "Local EMA 50", color=color.new(color.white, 15), linewidth=2, display=display.all - display.status_line)

plot(showHtfEmas ? h1EmaSlow : na, "1H EMA 50", color=color.new(#FF9800, 15), linewidth=2, display=display.all - display.status_line)
plot(showHtfEmas ? h1EmaStructure : na, "1H EMA 200", color=color.new(#A65F00, 5), linewidth=3, display=display.all - display.status_line)
plot(showHtfEmas ? h4EmaSlow : na, "4H EMA 50", color=color.new(#E040FB, 10), linewidth=2, display=display.all - display.status_line)
plot(showHtfEmas ? h4EmaStructure : na, "4H EMA 200", color=color.new(#7E57C2, 0), linewidth=3, display=display.all - display.status_line)

// === Alerts ===
bool alertsAllowed = requireConfirmedAlerts ? barstate.isconfirmed : true
alertcondition(alertsAllowed and strongLongBias, "MTF Bias Strong Long Bias", "MTF Bias Dashboard: strong long bias on {{ticker}} {{interval}}.")
alertcondition(alertsAllowed and strongShortBias, "MTF Bias Strong Short Bias", "MTF Bias Dashboard: strong short bias on {{ticker}} {{interval}}.")
alertcondition(alertsAllowed and hardHtfConflict, "MTF Bias HTF Conflict", "MTF Bias Dashboard: HTF conflict / no-trade warning on {{ticker}} {{interval}}.")

// === Dashboard ===
bool useLight = themeInput == "Light" ? true : themeInput == "Dark" ? false : isLightTheme()
color tableBg = useLight ? color.new(color.white, 3) : color.new(#16181D, 3)
color headerBg = useLight ? color.new(#1F5EFF, 0) : color.new(#0A84FF, 10)
color labelBg = useLight ? color.new(#E8EEF8, 0) : color.new(#242832, 0)
color textColor = useLight ? color.black : color.white
color mutedText = useLight ? color.new(color.black, 25) : color.new(color.white, 25)
color borderColor = useLight ? color.new(#1F5EFF, 30) : color.new(#0A84FF, 45)

var table dashboard = table.new(getTablePosition(tablePositionInput), 6, 11, bgcolor=tableBg, border_color=borderColor, border_width=1, frame_color=borderColor, frame_width=1)

fillTfRow(table dash, int row, string tfLabel, float score, float rsiValue, float atrRatio, float priceValue, float emaFast, float emaMid, float emaSlow, float liveScore) =>
    color rowBg = getScoreBg(score)
    table.cell(dash, 0, row, tfLabel, text_color=textColor, bgcolor=labelBg, text_size=size.small)
    table.cell(dash, 1, row, trendLabel(score), text_color=color.white, bgcolor=rowBg, text_size=size.small)
    table.cell(dash, 2, row, scoreText(score), text_color=color.white, bgcolor=rowBg, text_size=size.small)
    table.cell(dash, 3, row, rsiText(rsiValue), text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dash, 4, row, "ATR " + str.tostring(atrRatio, "#.##") + " / " + stackLabel(priceValue, emaFast, emaMid, emaSlow), text_color=mutedText, bgcolor=tableBg, text_size=size.small)
    table.cell(dash, 5, row, showLivePreview ? scoreText(liveScore) : "OFF", text_color=showLivePreview ? color.white : mutedText, bgcolor=showLivePreview ? getScoreBg(liveScore) : tableBg, text_size=size.small)

if barstate.islast
    table.cell(dashboard, 0, 0, "ACTION", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 1, 0, actionState, text_color=color.white, bgcolor=actionBg, text_size=size.small)
    table.cell(dashboard, 2, 0, "SCORE " + scoreText(confluenceScore), text_color=color.white, bgcolor=getScoreBg(confluenceScore), text_size=size.small)
    table.cell(dashboard, 3, 0, "MODE " + entryMode, text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 4, 0, sessionName, text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 5, 0, qualityState, text_color=color.white, bgcolor=qualityState == "CLEAN" ? color.new(color.green, 25) : qualityState == "HTF CONFLICT" ? color.new(color.red, 15) : color.new(color.orange, 25), text_size=size.small)

    table.cell(dashboard, 0, 1, "WHY", text_color=textColor, bgcolor=labelBg, text_size=size.small)
    table.cell(dashboard, 1, 1, reasonState, text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 2, 1, htfStateText, text_color=color.white, bgcolor=hardHtfConflict ? color.new(color.red, 15) : htfConflict ? color.new(color.orange, 20) : (htfBull or htfBear) ? color.new(color.green, 30) : color.new(color.gray, 55), text_size=size.small)
    table.cell(dashboard, 3, 1, "H1 " + scoreText(h1Score), text_color=color.white, bgcolor=getScoreBg(h1Score), text_size=size.small)
    table.cell(dashboard, 4, 1, "4H " + scoreText(h4Score), text_color=color.white, bgcolor=getScoreBg(h4Score), text_size=size.small)
    table.cell(dashboard, 5, 1, "D1 " + scoreText(d1Score), text_color=color.white, bgcolor=getScoreBg(d1Score), text_size=size.small)

    table.cell(dashboard, 0, 2, "TF", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 1, 2, "TREND", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 2, 2, "SCORE", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 3, 2, "RSI", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 4, 2, "ATR / EMA", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashboard, 5, 2, "LIVE", text_color=color.white, bgcolor=headerBg, text_size=size.small)

    fillTfRow(dashboard, 3, "1m", m1Score, m1Rsi, m1AtrRatio, m1Close, m1EmaFast, m1EmaMid, m1EmaSlow, m1LiveScore)
    fillTfRow(dashboard, 4, "5m", m5Score, m5Rsi, m5AtrRatio, m5Close, m5EmaFast, m5EmaMid, m5EmaSlow, m5LiveScore)
    fillTfRow(dashboard, 5, "15m", m15Score, m15Rsi, m15AtrRatio, m15Close, m15EmaFast, m15EmaMid, m15EmaSlow, m15LiveScore)
    fillTfRow(dashboard, 6, "30m", m30Score, m30Rsi, m30AtrRatio, m30Close, m30EmaFast, m30EmaMid, m30EmaSlow, m30LiveScore)
    fillTfRow(dashboard, 7, "1H", h1Score, h1Rsi, h1AtrRatio, h1Close, h1EmaFast, h1EmaMid, h1EmaSlow, h1LiveScore)
    fillTfRow(dashboard, 8, "4H", h4Score, h4Rsi, h4AtrRatio, h4Close, h4EmaFast, h4EmaMid, h4EmaSlow, h4LiveScore)
    fillTfRow(dashboard, 9, "1D", d1Score, d1Rsi, d1AtrRatio, d1Close, d1EmaFast, d1EmaMid, d1EmaSlow, d1LiveScore)

    table.cell(dashboard, 0, 10, "SESSION", text_color=textColor, bgcolor=labelBg, text_size=size.small)
    table.cell(dashboard, 1, 10, sessionName, text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 2, 10, "x" + str.tostring(sessionFactor, "#.##"), text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 3, 10, scalpPreset, text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 4, 10, "30m " + scoreText(m30Score), text_color=textColor, bgcolor=tableBg, text_size=size.small)
    table.cell(dashboard, 5, 10, requireConfirmedAlerts ? "CLOSE ALERTS" : "LIVE ALERTS", text_color=textColor, bgcolor=tableBg, text_size=size.small)
````
