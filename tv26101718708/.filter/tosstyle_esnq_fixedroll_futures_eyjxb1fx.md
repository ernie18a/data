# TOS-style ES/NQ fixed-roll futures

- url: https://www.tradingview.com/script/EYjXB1fX-TOS-style-ES-NQ-fixed-roll-futures/
- type: indicator
- pine_id: PUB;9da4163ab361435fb799eae2f08e0aa9
- version: 1.0

## Description

TOS-Style ES/NQ Futures Basis Adjustment

This indicator creates a continuous ES or NQ futures chart using a rollover-adjustment method similar to thinkorswim.

At each quarterly rollover, historical prices are adjusted using:
New contract’s opening price − previous contract’s closing price

The rollover gaps are hardcoded from TradingView’s individual CME contract data. This avoids timeframe-dependent calculations and keeps adjusted prices consistent across intraday and daily charts.

Setup
1. Add the indicator to an ES1! or NQ1! chart.
2. Select ES or NQ in the indicator settings.
3. Hide the original chart symbol using the eye icon so only the adjusted candles remain visible.
4. Leave the rollover offset at zero unless you specifically need a different switch date.

Notes
- Historical adjustment data begins in January 2024.
- The script uses the customary CME equity-index rollover schedule.
- ES and NQ adjustments are selected automatically.
- The hardcoded table must be updated after each quarterly rollover.
- Adjusted historical prices are synthetic and are not directly tradable prices.
- Weekly and monthly candles spanning a rollover may not match intraday aggregation exactly.

Script development: OpenAI Codex, in collaboration with the publisher.

## Source Code

````pine
//@version=6
indicator("TOS-style ES/NQ fixed-roll futures", shorttitle = "TOS Fixed Roll", overlay = true, behind_chart = false, dynamic_requests = true)
// Fixed-table version. Each completed quarterly gap is a constant input, so the
// adjusted price is independent of the chart timeframe and loaded-bar depth.
// Gap convention: new contract first daily open - old contract last daily close.
string root = input.string("ES", "Contract root", options = ["ES", "NQ"], group = "Contract")
string exchange = input.string("CME_MINI", "TradingView exchange prefix", group = "Contract")
int rollOffset = input.int(0, "Roll trading-day offset", minval = -3, maxval = 3, group = "Contract",
     tooltip = "0 = CME Monday before the third Friday. Keep at 0 when using the dates below.")
// Hardcoded from TradingView daily bars. Each value is the new contract's open
// on the CME roll trading day minus the old contract's preceding daily close.
const float es2403 = 66.50
const float nq2403 = 254.75
const float es2406 = 62.50
const float nq2406 = 269.25
const float es2409 = 54.25
const float nq2409 = 202.75
const float es2412 = 70.00
const float nq2412 = 266.25
const float es2503 = 38.75
const float nq2503 = 173.50
const float es2506 = 21.75
const float nq2506 = 128.25
const float es2509 = 56.75
const float nq2509 = 239.75
const float es2512 = 59.25
const float nq2512 = 249.75
const float es2603 = 23.75
const float nq2603 = 105.75
const float es2606 = 108.50
const float nq2606 = 529.00
const float es2609 = 20.50
const float nq2609 = -6.00
// Populate these two constants after the December 2026 roll.
const float es2612 = 0.00
const float nq2612 = 0.00
bool showCandles = input.bool(true, "Show adjusted candles", group = "Display")
bool fadeChartBodies = input.bool(true, "Make original candle bodies transparent", group = "Display",
     tooltip = "Pine cannot hide native borders and wicks. Click the eye beside the main chart symbol for a clean chart.")
bool showClose = input.bool(false, "Show adjusted close line", group = "Display")
bool showRolls = input.bool(true, "Mark contract changes", group = "Display")
bool showTable = input.bool(true, "Show status table", group = "Display")
f_thirdFriday(int y, int m) =>
    int firstDow = dayofweek(timestamp("UTC", y, m, 1, 0, 0), "UTC")
    int daysToFriday = (dayofweek.friday - firstDow + 7) % 7
    1 + daysToFriday + 14
f_contract(int tradingDay, int offset) =>
    int y = year(tradingDay, "UTC")
    int m = month(tradingDay, "UTC")
    int quarterlyMonth = m <= 3 ? 3 : m <= 6 ? 6 : m <= 9 ? 9 : 12
    int rollDate = timestamp("UTC", y, quarterlyMonth, f_thirdFriday(y, quarterlyMonth) - 4 + offset, 0, 0)
    int contractYear = y
    int contractMonth = quarterlyMonth
    if tradingDay >= rollDate
        if quarterlyMonth == 12
            contractYear := y + 1
            contractMonth := 3
        else
            contractMonth := quarterlyMonth + 3
    string monthCode = contractMonth == 3 ? "H" : contractMonth == 6 ? "M" : contractMonth == 9 ? "U" : "Z"
    root + monthCode + str.tostring(contractYear)
int tableStart = timestamp("UTC", 2024, 1, 1, 0, 0)
int effectiveTradingDay = time_tradingday < tableStart ? tableStart : time_tradingday
string contractTicker = f_contract(effectiveTradingDay, rollOffset)
string contractId = exchange + ":" + contractTicker
[rawOpen, rawHigh, rawLow, rawClose] = request.security(
     contractId, timeframe.period, [open, high, low, close],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)
var array<int> rollDates = array.from(
     timestamp("UTC", 2024, 3, 11, 0, 0), timestamp("UTC", 2024, 6, 17, 0, 0),
     timestamp("UTC", 2024, 9, 16, 0, 0), timestamp("UTC", 2024, 12, 16, 0, 0),
     timestamp("UTC", 2025, 3, 17, 0, 0), timestamp("UTC", 2025, 6, 16, 0, 0),
     timestamp("UTC", 2025, 9, 15, 0, 0), timestamp("UTC", 2025, 12, 15, 0, 0),
     timestamp("UTC", 2026, 3, 16, 0, 0), timestamp("UTC", 2026, 6, 15, 0, 0),
     timestamp("UTC", 2026, 9, 14, 0, 0), timestamp("UTC", 2026, 12, 14, 0, 0))
array<float> selectedGaps = root == "ES" ?
     array.from(es2403, es2406, es2409, es2412, es2503, es2506, es2509, es2512, es2603, es2606, es2609, es2612) :
     array.from(nq2403, nq2406, nq2409, nq2412, nq2503, nq2506, nq2509, nq2512, nq2603, nq2606, nq2609, nq2612)
float adjustment = 0.0
int missingCompleted = 0
float latestGap = na
for i = 0 to array.size(rollDates) - 1
    int rollDate = array.get(rollDates, i) + rollOffset * 86400000
    float gap = array.get(selectedGaps, i)
    if time_tradingday < rollDate
        adjustment += gap
    if time_tradingday >= rollDate
        latestGap := gap
        if gap == 0.0
            missingCompleted += 1
bool inWindow = time_tradingday >= tableStart
bool rollEvent = inWindow and contractTicker != contractTicker[1]
float adjOpen = inWindow ? rawOpen + adjustment : na
float adjHigh = inWindow ? rawHigh + adjustment : na
float adjLow = inWindow ? rawLow + adjustment : na
float adjClose = inWindow ? rawClose + adjustment : na
color candleColor = adjClose >= adjOpen ? color.rgb(38, 166, 154) : color.rgb(239, 83, 80)
barcolor(fadeChartBodies ? color.new(color.black, 100) : na, title = "Fade original chart candle bodies")
plotcandle(showCandles ? adjOpen : na, showCandles ? adjHigh : na, showCandles ? adjLow : na, showCandles ? adjClose : na,
     title = "TOS-adjusted OHLC", color = candleColor, wickcolor = candleColor, bordercolor = candleColor)
plot(showClose ? adjClose : na, "TOS-adjusted close", color = color.orange, linewidth = 2)
plotshape(showRolls and rollEvent, title = "Contract change", style = shape.labelup, location = location.belowbar,
     color = color.blue, text = "ROLL", textcolor = color.white, size = size.tiny)
var table status = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast and showTable
    color header = color.rgb(35, 45, 60)
    color body = color.new(color.black, 15)
    color warning = missingCompleted == 0 ? color.new(color.green, 65) : color.new(color.orange, 35)
    table.cell(status, 0, 0, "TOS fixed roll", bgcolor = header, text_color = color.white, text_size = size.tiny)
    table.cell(status, 1, 0, root, bgcolor = header, text_color = color.white, text_size = size.tiny)
    table.cell(status, 0, 1, "Contract", bgcolor = body, text_color = color.white, text_size = size.tiny)
    table.cell(status, 1, 1, contractId, bgcolor = body, text_color = color.white, text_size = size.tiny)
    table.cell(status, 0, 2, "Bar adjustment", bgcolor = body, text_color = color.white, text_size = size.tiny)
````
