<!-- tradingview-pine-id: PUB;ff2bbe0046284d558d449f01dd8a5f6d -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi Timeframe State Dashboard [Pineify]

Source: https://www.tradingview.com/script/80NCX0Vm-Multi-Timeframe-State-Dashboard-Pineify/

## Description

Multi Timeframe State Dashboard [Pineify]

Overview
This confirmation-aware TradingView dashboard condenses six reference timeframes into one matrix. Each row pairs the last closed state with the forming state and shows its trend, RSI, and ATR-percentile evidence.

Problem Definition
A basic multi-timeframe table colors each timeframe from its latest value. It hides whether a higher-timeframe bar has closed, so apparent agreement can disappear before confirmation. It also treats quiet drift and high-volatility impulse alike. Duplicate inputs overweight one horizon, while a reference below the chart requires a different sampling method. The script separates these cases.

Design Rationale
EMA slope is normalized by ATR so direction is comparable across price and volatility scales. RSI adds bounded momentum around 50; ATR percentile labels energy without choosing direction. A weighted score replaces unrelated votes, while strong trend/RSI opposition becomes CONFLICT rather than false neutrality. The matrix sacrifices each component's full path for scan speed. Pairing confirmed and live states preserves the compact view while making temporal uncertainty observable.

Key Features

[*]Six slots with duplicate and lower-timeframe diagnostics.
[*]CONFIRMED and LIVE states with visible drift.
[*]Impulse, directional, bias, quiet, neutral, and conflict classes.
[*]Closed-bar consensus, optional background, and alignment alerts.

How It Works
Each slot makes a live request with lookahead disabled and a prior-bar request for confirmed higher-timeframe data. When a slot equals the chart timeframe, its current value is confirmed only after that chart bar closes.

EMA change over the slope lookback is divided by ATR and a scale, then clipped to -1 through +1. RSI is centered at 50, divided by 25, and clipped likewise. ATR receives a 0-100 percentile rank. Direction is 55% trend and 45% momentum. Strong opposite components produce CONFLICT. Thresholds create bias or direction. Hot direction becomes IMPULSE; a small quiet score becomes QUIET.

Consensus counts only enabled, unique references equal to or higher than the chart. ALL BULLISH or ALL BEARISH requires every valid confirmed state to share direction. DRIFT counts live states that differ from confirmed partners. WARM-UP remains visible until all rolling histories exist; missing values are not replaced with zero.

How Multiple Indicators Work Together
EMA slope supplies persistent direction, RSI tests momentum support, and ATR percentile separates low-energy drift from expansion. Without slope, brief momentum could define trend; without RSI, a slow average could ignore opposition; without volatility, quiet and impulse states would share a label. The sequence is direction, agreement, then energy. Confirmed/live pairing adds time status, not another signal.

Trading Ideas and Insights
Use confirmed consensus as context for a separate setup. A lower-chart process can ask whether higher horizons are bullish, bearish, or mixed. More DRIFT rows show forming bars challenging closed evidence, not a confirmed reversal. QUIET describes low-energy alignment; IMPULSE describes high ATR rank. Price structure, execution, and risk still need independent rules.

Unique Aspects
The contribution is a confirmation-aware state lattice, not adjacent indicator readings. Every row preserves closed and forming versions of one state, flags their difference, and removes duplicate or lower references from consensus. Volatility changes the class but cannot select bullish or bearish direction. Agreement is therefore auditable as confirmed evidence, developing drift, warm-up, or invalid configuration. The implementation is independent.

How to Use

[*]Set enabled references equal to or higher than the chart timeframe.
[*]Read CONFIRMED for stable context and LIVE for the forming bar.
[*]Check TREND, RSI, and ATR % before interpreting color.
[*]Treat LOWER TF, DUPLICATE, and WARM-UP as diagnostics.
[*]Combine alerts with separate entry, exit, sizing, and invalidation rules.

Disable unused rows so the consensus denominator stays intentional.

Customization
EMA length and slope lookback control directional memory; ATR slope scale controls normalization. RSI length changes momentum response. ATR length and percentile lookback define volatility context. Direction and conflict thresholds set classification strictness. Quiet percentile must remain below hot percentile. Timeframe inputs set horizon coverage. Display controls cover numeric suffixes, table corner, dashboard, and chart background.

Assumptions and Limitations
EMA, RSI, and ATR lag and are parameter-sensitive. ATR percentile is relative, not an absolute risk forecast. LIVE can change on every update; CONFIRMED waits for completed reference bars and adds delay. A newly closed higher-timeframe value appears when the next chart bar exposes it. Data gaps or limited history can distort ranks. Lower references are rejected. It does not model execution, risk, performance, or future prices. Alerts report alignment only.

Conclusion
Only valid, unique, closed-bar states determine consensus; live states explain drift. This invariant keeps six horizons readable while exposing calculations, confirmation status, and failure conditions instead of hiding them behind one color.

---

## Source Code

````pine
//@version=6
indicator("Multi Timeframe State Dashboard [Pineify]", overlay = true)

string GROUP_ENGINE = "State Engine"
string GROUP_TIMEFRAMES = "Reference Timeframes"
string GROUP_DISPLAY = "Display"

int trendLength = input.int(34, "Trend EMA length", minval = 5, maxval = 200, group = GROUP_ENGINE)
int slopeLookback = input.int(5, "Trend slope lookback", minval = 1, maxval = 50, group = GROUP_ENGINE)
float trendScale = input.float(1.25, "ATR slope scale", minval = 0.10, maxval = 5.00, step = 0.05, group = GROUP_ENGINE)
int rsiLength = input.int(14, "RSI length", minval = 2, maxval = 100, group = GROUP_ENGINE)
int atrLength = input.int(14, "ATR length", minval = 2, maxval = 100, group = GROUP_ENGINE)
int volatilityLookback = input.int(100, "ATR percentile lookback", minval = 20, maxval = 500, group = GROUP_ENGINE)
float stateThreshold = input.float(0.28, "Directional state threshold", minval = 0.05, maxval = 0.80, step = 0.01, group = GROUP_ENGINE)
float conflictThreshold = input.float(0.20, "Component conflict threshold", minval = 0.05, maxval = 0.80, step = 0.01, group = GROUP_ENGINE)
float quietPercentile = input.float(30.0, "Quiet volatility percentile", minval = 5.0, maxval = 60.0, step = 1.0, group = GROUP_ENGINE)
float hotPercentile = input.float(70.0, "Hot volatility percentile", minval = 40.0, maxval = 95.0, step = 1.0, group = GROUP_ENGINE)

bool enable1 = input.bool(true, "Enable 1", inline = "tf1", group = GROUP_TIMEFRAMES)
string timeframe1 = input.timeframe("15", "Timeframe 1", inline = "tf1", group = GROUP_TIMEFRAMES)
bool enable2 = input.bool(true, "Enable 2", inline = "tf2", group = GROUP_TIMEFRAMES)
string timeframe2 = input.timeframe("60", "Timeframe 2", inline = "tf2", group = GROUP_TIMEFRAMES)
bool enable3 = input.bool(true, "Enable 3", inline = "tf3", group = GROUP_TIMEFRAMES)
string timeframe3 = input.timeframe("240", "Timeframe 3", inline = "tf3", group = GROUP_TIMEFRAMES)
bool enable4 = input.bool(true, "Enable 4", inline = "tf4", group = GROUP_TIMEFRAMES)
string timeframe4 = input.timeframe("D", "Timeframe 4", inline = "tf4", group = GROUP_TIMEFRAMES)
bool enable5 = input.bool(true, "Enable 5", inline = "tf5", group = GROUP_TIMEFRAMES)
string timeframe5 = input.timeframe("W", "Timeframe 5", inline = "tf5", group = GROUP_TIMEFRAMES)
bool enable6 = input.bool(true, "Enable 6", inline = "tf6", group = GROUP_TIMEFRAMES)
string timeframe6 = input.timeframe("M", "Timeframe 6", inline = "tf6", group = GROUP_TIMEFRAMES)

bool showDashboard = input.bool(true, "Show dashboard", group = GROUP_DISPLAY)
bool showChartBackground = input.bool(false, "Show current-chart state background", group = GROUP_DISPLAY)
bool showNumericComponents = input.bool(true, "Show component values", group = GROUP_DISPLAY)
string positionInput = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_DISPLAY)

f_clip(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

f_liveBundle() =>
    float atrValue = ta.atr(atrLength)
    float trendBasis = ta.ema(close, trendLength)
    float rawTrend = not na(trendBasis[slopeLookback]) and atrValue > 0.0 ? (trendBasis - trendBasis[slopeLookback]) / (atrValue * trendScale) : na
    float trendScore = na(rawTrend) ? na : f_clip(rawTrend, -1.0, 1.0)
    float rsiValue = ta.rsi(close, rsiLength)
    float momentumScore = na(rsiValue) ? na : f_clip((rsiValue - 50.0) / 25.0, -1.0, 1.0)
    float volatilityRank = ta.percentrank(atrValue, volatilityLookback)
    [trendScore, momentumScore, volatilityRank]

f_confirmedBundle() =>
    float atrValue = ta.atr(atrLength)
    float trendBasis = ta.ema(close, trendLength)
    float rawTrend = not na(trendBasis[slopeLookback]) and atrValue > 0.0 ? (trendBasis - trendBasis[slopeLookback]) / (atrValue * trendScale) : na
    float trendScore = na(rawTrend) ? na : f_clip(rawTrend, -1.0, 1.0)
    float rsiValue = ta.rsi(close, rsiLength)
    float momentumScore = na(rsiValue) ? na : f_clip((rsiValue - 50.0) / 25.0, -1.0, 1.0)
    float volatilityRank = ta.percentrank(atrValue, volatilityLookback)
    [trendScore[1], momentumScore[1], volatilityRank[1]]

f_state(float trendScore, float momentumScore, float volatilityRank) =>
    bool ready = not na(trendScore) and not na(momentumScore) and not na(volatilityRank) and quietPercentile < hotPercentile
    bool conflict = ready and math.abs(trendScore) >= conflictThreshold and math.abs(momentumScore) >= conflictThreshold and trendScore * momentumScore < 0.0
    float directionalScore = 0.55 * trendScore + 0.45 * momentumScore
    int stateCode = 99
    if ready
        if conflict
            stateCode := 9
        else if directionalScore >= stateThreshold and trendScore > 0.0
            stateCode := volatilityRank >= hotPercentile ? 3 : 2
        else if directionalScore <= -stateThreshold and trendScore < 0.0
            stateCode := volatilityRank >= hotPercentile ? -3 : -2
        else if math.abs(directionalScore) < stateThreshold * 0.45 and volatilityRank <= quietPercentile
            stateCode := 8
        else if directionalScore >= stateThreshold * 0.45
            stateCode := 1
        else if directionalScore <= -stateThreshold * 0.45
            stateCode := -1
        else
            stateCode := 0
    stateCode

f_stateLabel(int stateCode) =>
    stateCode == 3 ? "IMPULSE UP" :
     stateCode == 2 ? "UP" :
     stateCode == 1 ? "BIAS UP" :
     stateCode == -1 ? "BIAS DOWN" :
     stateCode == -2 ? "DOWN" :
     stateCode == -3 ? "IMPULSE DOWN" :
     stateCode == 8 ? "QUIET" :
     stateCode == 9 ? "CONFLICT" :
     stateCode == 0 ? "NEUTRAL" : "WARM-UP"

f_stateColor(int stateCode) =>
    stateCode == 3 ? color.rgb(0, 150, 136) :
     stateCode == 2 ? color.rgb(0, 172, 193) :
     stateCode == 1 ? color.rgb(38, 166, 154) :
     stateCode == -1 ? color.rgb(255, 167, 38) :
     stateCode == -2 ? color.rgb(239, 108, 0) :
     stateCode == -3 ? color.rgb(216, 67, 21) :
     stateCode == 8 ? color.rgb(66, 165, 245) :
     stateCode == 9 ? color.rgb(126, 87, 194) :
     color.rgb(96, 125, 139)

f_direction(int stateCode) =>
    stateCode >= 1 and stateCode <= 3 ? 1 : stateCode <= -1 and stateCode >= -3 ? -1 : 0

f_trendText(float value) =>
    na(value) ? "NA" : (value > 0.15 ? "UP " : value < -0.15 ? "DOWN " : "FLAT ") + (showNumericComponents ? str.tostring(value, "#.00") : "")

f_momentumText(float value) =>
    float rsiValue = na(value) ? na : value * 25.0 + 50.0
    na(rsiValue) ? "NA" : (rsiValue >= 55.0 ? "BULL " : rsiValue <= 45.0 ? "BEAR " : "MID ") + (showNumericComponents ? str.tostring(rsiValue, "#.0") : "")

f_volatilityText(float value) =>
    na(value) ? "NA" : (value >= hotPercentile ? "HOT " : value <= quietPercentile ? "QUIET " : "NORMAL ") + (showNumericComponents ? str.tostring(value, "#") : "")

[trend1Live, momentum1Live, volatility1Live] = request.security(syminfo.tickerid, timeframe1, f_liveBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[trend1Closed, momentum1Closed, volatility1Closed] = request.security(syminfo.tickerid, timeframe1, f_confirmedBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[trend2Live, momentum2Live, volatility2Live] = request.security(syminfo.tickerid, timeframe2, f_liveBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[trend2Closed, momentum2Closed, volatility2Closed] = request.security(syminfo.tickerid, timeframe2, f_confirmedBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[trend3Live, momentum3Live, volatility3Live] = request.security(syminfo.tickerid, timeframe3, f_liveBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[trend3Closed, momentum3Closed, volatility3Closed] = request.security(syminfo.tickerid, timeframe3, f_confirmedBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[trend4Live, momentum4Live, volatility4Live] = request.security(syminfo.tickerid, timeframe4, f_liveBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[trend4Closed, momentum4Closed, volatility4Closed] = request.security(syminfo.tickerid, timeframe4, f_confirmedBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[trend5Live, momentum5Live, volatility5Live] = request.security(syminfo.tickerid, timeframe5, f_liveBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[trend5Closed, momentum5Closed, volatility5Closed] = request.security(syminfo.tickerid, timeframe5, f_confirmedBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)
[trend6Live, momentum6Live, volatility6Live] = request.security(syminfo.tickerid, timeframe6, f_liveBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[trend6Closed, momentum6Closed, volatility6Closed] = request.security(syminfo.tickerid, timeframe6, f_confirmedBundle(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

float chartSeconds = timeframe.in_seconds()
float seconds1 = timeframe.in_seconds(timeframe1)
float seconds2 = timeframe.in_seconds(timeframe2)
float seconds3 = timeframe.in_seconds(timeframe3)
float seconds4 = timeframe.in_seconds(timeframe4)
float seconds5 = timeframe.in_seconds(timeframe5)
float seconds6 = timeframe.in_seconds(timeframe6)

bool duplicate1 = false
bool duplicate2 = enable2 and enable1 and seconds2 == seconds1
bool duplicate3 = enable3 and ((enable1 and seconds3 == seconds1) or (enable2 and seconds3 == seconds2))
bool duplicate4 = enable4 and ((enable1 and seconds4 == seconds1) or (enable2 and seconds4 == seconds2) or (enable3 and seconds4 == seconds3))
bool duplicate5 = enable5 and ((enable1 and seconds5 == seconds1) or (enable2 and seconds5 == seconds2) or (enable3 and seconds5 == seconds3) or (enable4 and seconds5 == seconds4))
bool duplicate6 = enable6 and ((enable1 and seconds6 == seconds1) or (enable2 and seconds6 == seconds2) or (enable3 and seconds6 == seconds3) or (enable4 and seconds6 == seconds4) or (enable5 and seconds6 == seconds5))

bool valid1 = enable1 and not duplicate1 and seconds1 >= chartSeconds
bool valid2 = enable2 and not duplicate2 and seconds2 >= chartSeconds
bool valid3 = enable3 and not duplicate3 and seconds3 >= chartSeconds
bool valid4 = enable4 and not duplicate4 and seconds4 >= chartSeconds
bool valid5 = enable5 and not duplicate5 and seconds5 >= chartSeconds
bool valid6 = enable6 and not duplicate6 and seconds6 >= chartSeconds

bool same1 = seconds1 == chartSeconds
bool same2 = seconds2 == chartSeconds
bool same3 = seconds3 == chartSeconds
bool same4 = seconds4 == chartSeconds
bool same5 = seconds5 == chartSeconds
bool same6 = seconds6 == chartSeconds

float trend1Confirmed = same1 and barstate.isconfirmed ? trend1Live : trend1Closed
float momentum1Confirmed = same1 and barstate.isconfirmed ? momentum1Live : momentum1Closed
float volatility1Confirmed = same1 and barstate.isconfirmed ? volatility1Live : volatility1Closed
float trend2Confirmed = same2 and barstate.isconfirmed ? trend2Live : trend2Closed
float momentum2Confirmed = same2 and barstate.isconfirmed ? momentum2Live : momentum2Closed
float volatility2Confirmed = same2 and barstate.isconfirmed ? volatility2Live : volatility2Closed
float trend3Confirmed = same3 and barstate.isconfirmed ? trend3Live : trend3Closed
float momentum3Confirmed = same3 and barstate.isconfirmed ? momentum3Live : momentum3Closed
float volatility3Confirmed = same3 and barstate.isconfirmed ? volatility3Live : volatility3Closed
float trend4Confirmed = same4 and barstate.isconfirmed ? trend4Live : trend4Closed
float momentum4Confirmed = same4 and barstate.isconfirmed ? momentum4Live : momentum4Closed
float volatility4Confirmed = same4 and barstate.isconfirmed ? volatility4Live : volatility4Closed
float trend5Confirmed = same5 and barstate.isconfirmed ? trend5Live : trend5Closed
float momentum5Confirmed = same5 and barstate.isconfirmed ? momentum5Live : momentum5Closed
float volatility5Confirmed = same5 and barstate.isconfirmed ? volatility5Live : volatility5Closed
float trend6Confirmed = same6 and barstate.isconfirmed ? trend6Live : trend6Closed
float momentum6Confirmed = same6 and barstate.isconfirmed ? momentum6Live : momentum6Closed
float volatility6Confirmed = same6 and barstate.isconfirmed ? volatility6Live : volatility6Closed

int state1Live = f_state(trend1Live, momentum1Live, volatility1Live)
int state2Live = f_state(trend2Live, momentum2Live, volatility2Live)
int state3Live = f_state(trend3Live, momentum3Live, volatility3Live)
int state4Live = f_state(trend4Live, momentum4Live, volatility4Live)
int state5Live = f_state(trend5Live, momentum5Live, volatility5Live)
int state6Live = f_state(trend6Live, momentum6Live, volatility6Live)
int state1Confirmed = f_state(trend1Confirmed, momentum1Confirmed, volatility1Confirmed)
int state2Confirmed = f_state(trend2Confirmed, momentum2Confirmed, volatility2Confirmed)
int state3Confirmed = f_state(trend3Confirmed, momentum3Confirmed, volatility3Confirmed)
int state4Confirmed = f_state(trend4Confirmed, momentum4Confirmed, volatility4Confirmed)
int state5Confirmed = f_state(trend5Confirmed, momentum5Confirmed, volatility5Confirmed)
int state6Confirmed = f_state(trend6Confirmed, momentum6Confirmed, volatility6Confirmed)

array<string> timeframeValues = array.from(timeframe1, timeframe2, timeframe3, timeframe4, timeframe5, timeframe6)
array<bool> enabledValues = array.from(enable1, enable2, enable3, enable4, enable5, enable6)
array<bool> validValues = array.from(valid1, valid2, valid3, valid4, valid5, valid6)
array<bool> duplicateValues = array.from(duplicate1, duplicate2, duplicate3, duplicate4, duplicate5, duplicate6)
array<bool> sameValues = array.from(same1, same2, same3, same4, same5, same6)
array<int> liveStates = array.from(state1Live, state2Live, state3Live, state4Live, state5Live, state6Live)
array<int> confirmedStates = array.from(state1Confirmed, state2Confirmed, state3Confirmed, state4Confirmed, state5Confirmed, state6Confirmed)
array<float> confirmedTrends = array.from(trend1Confirmed, trend2Confirmed, trend3Confirmed, trend4Confirmed, trend5Confirmed, trend6Confirmed)
array<float> confirmedMomentum = array.from(momentum1Confirmed, momentum2Confirmed, momentum3Confirmed, momentum4Confirmed, momentum5Confirmed, momentum6Confirmed)
array<float> confirmedVolatility = array.from(volatility1Confirmed, volatility2Confirmed, volatility3Confirmed, volatility4Confirmed, volatility5Confirmed, volatility6Confirmed)

int validCount = 0
int bullishCount = 0
int bearishCount = 0
int warmupCount = 0
int driftCount = 0
for index = 0 to 5
    if array.get(validValues, index)
        validCount += 1
        int confirmedState = array.get(confirmedStates, index)
        int liveState = array.get(liveStates, index)
        int direction = f_direction(confirmedState)
        bullishCount += direction == 1 ? 1 : 0
        bearishCount += direction == -1 ? 1 : 0
        warmupCount += confirmedState == 99 ? 1 : 0
        driftCount += liveState != 99 and confirmedState != 99 and liveState != confirmedState ? 1 : 0

bool allBullishConfirmed = validCount > 0 and warmupCount == 0 and bullishCount == validCount
bool allBearishConfirmed = validCount > 0 and warmupCount == 0 and bearishCount == validCount
string consensusText = validCount == 0 ? "NO VALID SLOTS" : warmupCount > 0 ? "WARM-UP" : allBullishConfirmed ? "ALL BULLISH" : allBearishConfirmed ? "ALL BEARISH" : "MIXED"
color consensusColor = allBullishConfirmed ? color.rgb(0, 150, 136) : allBearishConfirmed ? color.rgb(239, 108, 0) : warmupCount > 0 ? color.rgb(96, 125, 139) : color.rgb(126, 87, 194)

[localTrend, localMomentum, localVolatility] = f_liveBundle()
int localState = f_state(localTrend, localMomentum, localVolatility)
color localColor = f_stateColor(localState)
bgcolor(showChartBackground and localState != 99 ? color.new(localColor, 92) : na, title = "Current chart state background")

string dashboardPosition = positionInput == "Top Left" ? position.top_left : positionInput == "Bottom Right" ? position.bottom_right : positionInput == "Bottom Left" ? position.bottom_left : position.top_right
var table dashboard = table.new(dashboardPosition, 7, 9, bgcolor = color.new(chart.bg_color, 3), frame_color = color.new(chart.fg_color, 58), frame_width = 1, border_color = color.new(chart.fg_color, 82), border_width = 1)
if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 6, 0)

if barstate.islast
    table.clear(dashboard, 0, 0, 6, 8)
    if showDashboard
        table.cell(dashboard, 0, 0, "MULTI TIMEFRAME STATE LATTICE", text_color = color.white, bgcolor = color.new(consensusColor, 5), text_size = size.small)
        table.cell(dashboard, 0, 1, "TF", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        table.cell(dashboard, 1, 1, "CONFIRMED", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        table.cell(dashboard, 2, 1, "LIVE", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        table.cell(dashboard, 3, 1, "TREND", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        table.cell(dashboard, 4, 1, "RSI", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        table.cell(dashboard, 5, 1, "ATR %", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        table.cell(dashboard, 6, 1, "PHASE", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 6), text_size = size.tiny)
        for index = 0 to 5
            int row = index + 2
            bool enabled = array.get(enabledValues, index)
            bool valid = array.get(validValues, index)
            bool duplicate = array.get(duplicateValues, index)
            bool sameTimeframe = array.get(sameValues, index)
            int confirmedState = array.get(confirmedStates, index)
            int liveState = array.get(liveStates, index)
            string issueText = not enabled ? "OFF" : duplicate ? "DUPLICATE" : not valid ? "LOWER TF" : ""
            string timeframeText = enabled ? array.get(timeframeValues, index) : "—"
            string confirmedText = valid ? f_stateLabel(confirmedState) : issueText
            string liveText = valid ? f_stateLabel(liveState) : issueText
            string phaseText = not valid ? issueText : sameTimeframe and barstate.isconfirmed ? "CONFIRMED" : liveState != confirmedState ? "DEVELOPING / DRIFT" : "DEVELOPING"
            color confirmedColor = valid ? f_stateColor(confirmedState) : color.rgb(96, 125, 139)
            color liveColor = valid ? f_stateColor(liveState) : color.rgb(96, 125, 139)
            color rowBackground = color.new(chart.bg_color, index % 2 == 0 ? 8 : 2)
            table.cell(dashboard, 0, row, timeframeText, text_color = chart.fg_color, bgcolor = rowBackground, text_size = size.tiny)
            table.cell(dashboard, 1, row, confirmedText, text_color = color.white, bgcolor = color.new(confirmedColor, valid ? 10 : 55), text_size = size.tiny)
            table.cell(dashboard, 2, row, liveText, text_color = color.white, bgcolor = color.new(liveColor, valid ? 18 : 60), text_size = size.tiny)
            table.cell(dashboard, 3, row, valid ? f_trendText(array.get(confirmedTrends, index)) : "—", text_color = valid ? confirmedColor : color.new(chart.fg_color, 45), bgcolor = rowBackground, text_size = size.tiny)
            table.cell(dashboard, 4, row, valid ? f_momentumText(array.get(confirmedMomentum, index)) : "—", text_color = valid ? confirmedColor : color.new(chart.fg_color, 45), bgcolor = rowBackground, text_size = size.tiny)
            table.cell(dashboard, 5, row, valid ? f_volatilityText(array.get(confirmedVolatility, index)) : "—", text_color = valid ? confirmedColor : color.new(chart.fg_color, 45), bgcolor = rowBackground, text_size = size.tiny)
            table.cell(dashboard, 6, row, phaseText, text_color = valid and liveState != confirmedState ? color.rgb(255, 193, 7) : chart.fg_color, bgcolor = rowBackground, text_size = size.tiny)
        table.cell(dashboard, 0, 8, "CONSENSUS", text_color = color.white, bgcolor = color.new(consensusColor, 5), text_size = size.tiny)
        table.cell(dashboard, 1, 8, consensusText, text_color = color.white, bgcolor = color.new(consensusColor, 5), text_size = size.tiny)
        table.cell(dashboard, 2, 8, "VALID " + str.tostring(validCount) + "/6", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 4), text_size = size.tiny)
        table.cell(dashboard, 3, 8, "DRIFT " + str.tostring(driftCount), text_color = driftCount > 0 ? color.rgb(255, 193, 7) : chart.fg_color, bgcolor = color.new(chart.bg_color, 4), text_size = size.tiny)
        table.cell(dashboard, 4, 8, "BULL " + str.tostring(bullishCount), text_color = color.rgb(0, 150, 136), bgcolor = color.new(chart.bg_color, 4), text_size = size.tiny)
        table.cell(dashboard, 5, 8, "BEAR " + str.tostring(bearishCount), text_color = color.rgb(239, 108, 0), bgcolor = color.new(chart.bg_color, 4), text_size = size.tiny)
        table.cell(dashboard, 6, 8, quietPercentile < hotPercentile ? "CLOSED BASIS" : "CHECK BANDS", text_color = quietPercentile < hotPercentile ? chart.fg_color : color.rgb(239, 108, 0), bgcolor = color.new(chart.bg_color, 4), text_size = size.tiny)

bool bullishAlignmentStarted = barstate.isconfirmed and allBullishConfirmed and not allBullishConfirmed[1]
bool bearishAlignmentStarted = barstate.isconfirmed and allBearishConfirmed and not allBearishConfirmed[1]
alertcondition(bullishAlignmentStarted, "Confirmed bullish timeframe alignment", "Multi Timeframe State Dashboard: all enabled valid reference timeframes are bullish on confirmed data.")
alertcondition(bearishAlignmentStarted, "Confirmed bearish timeframe alignment", "Multi Timeframe State Dashboard: all enabled valid reference timeframes are bearish on confirmed data.")
````
