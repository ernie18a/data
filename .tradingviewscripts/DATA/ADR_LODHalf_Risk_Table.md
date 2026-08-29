<!-- tradingview-pine-id: PUB;1192b4227aad464795aecc2722706348 -->
<!-- tradingviewscripts-format: 1 -->
# ADR + LOD/Half Risk Table

Source: https://www.tradingview.com/script/Z2zoeiwc-10-20-ADR-LOD-Half-risk-manage-Position-size-table/

## Description

# ADR Risk & Position Sizing Table

A compact trading dashboard designed for momentum and breakout traders.

###Features

**10-Day ADR%**
**20-Day ADR%**
**Market Capitalization**

**LOD (Low of Day) Stop** 
  * Displays the current Low of Day.
  * Shows the percentage move required for price to reach the LOD from the current price.

**Half of the Day Range Stop**
  * Calculates the midpoint between today's High and Low.
  * If price is above the midpoint, the table shows the downside distance.
  * If price is below the midpoint, it shows the upside distance required to reach the midpoint.

**Automatic Position Sizing**
  * Calculates recommended capital allocation based on a user-defined account risk percentage.
  * Supports two stop scenarios:

    * Stop at the Low of Day (LOD)
    * Stop at the Half of the Day Range (available only when price is above the midpoint)

### Position Sizing Formula

Position Size (%) = Account Risk (%) ÷ Stop Distance (%)

Example:

* Account Risk = 1% (default, Can set your own risk level)
* Stop Distance = 5%
* Recommended Position Size = 20% of account equity

### Real-Time Updates

The table updates continuously throughout the trading session as today's High, Low, and current price change.

### Notes

* ADR values follow TradingView's standard ADR calculation.
* Market capitalization is estimated using the latest reported shares outstanding multiplied by the current price.
* Position sizing does not account for commissions, slippage, or overnight gap risk.
* Designed for discretionary traders who manage risk using intraday reference levels rather than fixed ATR-based stops.

---

## Source Code

````pine
//@version=6
indicator("ADR + LOD/Half Risk Table", shorttitle = "ADR Risk", overlay = true)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_ADR  = "ADR"
string GROUP_RISK = "Risk"

bool includeCurrentDay = input.bool(
     true,
     "ADR 계산에 오늘 포함 (TradingView 공식 방식)",
     group = GROUP_ADR,
     tooltip = "켜짐: 진행 중인 오늘 일봉을 포함하므로 장중 ADR%가 실시간으로 변합니다. 꺼짐: 직전 완료 일봉들만 범위 평균에 사용합니다."
)

float accountRiskPct = input.float(
     1.0,
     "거래당 계좌 리스크 (%)",
     minval = 0.01,
     step = 0.1,
     group = GROUP_RISK,
     tooltip = "예: 1.0 = 스탑 체결 시 계좌자산의 1% 손실을 목표로 투입자본 비중을 계산합니다."
)

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
f_adrPct(int length, bool includeToday) =>
    float avgHigh = includeToday ? ta.sma(high, length) : ta.sma(high[1], length)
    float avgLow  = includeToday ? ta.sma(low, length)  : ta.sma(low[1], length)
    float result  = na

    if close > 0 and not na(avgHigh) and not na(avgLow)
        result := (avgHigh - avgLow) / close * 100.0

    result

f_price(float value) =>
    na(value) ? "N/A" : str.tostring(value, format.mintick)

f_pct(float value) =>
    na(value) ? "N/A" : str.tostring(value, "0.00") + "%"

// ─────────────────────────────────────────────────────────────────────────────
// Standard daily data
// ─────────────────────────────────────────────────────────────────────────────
string standardTicker = ticker.standard(syminfo.tickerid)

[dayHigh, dayLow, currentPrice, adr10Pct, adr20Pct] = request.security(
     standardTicker,
     "1D",
     [
         high,
         low,
         close,
         f_adrPct(10, includeCurrentDay),
         f_adrPct(20, includeCurrentDay)
     ],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true
)

// ─────────────────────────────────────────────────────────────────────────────
// Market capitalization
// ─────────────────────────────────────────────────────────────────────────────
float sharesFQ = request.financial(
     standardTicker,
     "TOTAL_SHARES_OUTSTANDING",
     "FQ",
     gaps = barmerge.gaps_off,
     ignore_invalid_symbol = true
)

float sharesFH = request.financial(
     standardTicker,
     "TOTAL_SHARES_OUTSTANDING",
     "FH",
     gaps = barmerge.gaps_off,
     ignore_invalid_symbol = true
)

float sharesFY = request.financial(
     standardTicker,
     "TOTAL_SHARES_OUTSTANDING",
     "FY",
     gaps = barmerge.gaps_off,
     ignore_invalid_symbol = true
)

float sharesOutstanding = sharesFQ

if na(sharesOutstanding)
    sharesOutstanding := sharesFH

if na(sharesOutstanding)
    sharesOutstanding := sharesFY

float marketCap = (
     not na(sharesOutstanding) and not na(currentPrice)
     ? sharesOutstanding * currentPrice
     : na
)

// ─────────────────────────────────────────────────────────────────────────────
// Stop distances
// ─────────────────────────────────────────────────────────────────────────────
bool validDayData = (
     not na(dayHigh) and
     not na(dayLow) and
     not na(currentPrice) and
     currentPrice > 0
)

float halfRange = validDayData
     ? (dayHigh + dayLow) / 2.0
     : na

// LOD 거리:
// 현재가의 Half 위/아래 여부와 무관하게 항상 계산
float lodDistancePct = validDayData
     ? math.max(
         0.0,
         (currentPrice - dayLow) / currentPrice * 100.0
       )
     : na

// 현재가에서 Half까지 필요한 절대 이동률
float halfMovePct = validDayData
     ? math.abs(currentPrice - halfRange) / currentPrice * 100.0
     : na

bool priceAboveHalf = (
     validDayData and
     currentPrice > halfRange
)

// Half가 현재가 아래에 있을 때만 스탑 거리로 사용
float halfStopDistancePct = priceAboveHalf
     ? (currentPrice - halfRange) / currentPrice * 100.0
     : na

// ─────────────────────────────────────────────────────────────────────────────
// Position sizing
//
// 투입자본 비중:
// 거래당 계좌 리스크 % ÷ 현재가 대비 스탑 거리 % × 100
// ─────────────────────────────────────────────────────────────────────────────

// LOD 포지션 사이징:
// Half 위/아래 여부와 무관하게 LOD 거리가 0보다 크면 계산
bool validLodStopDistance = (
     validDayData and
     not na(lodDistancePct) and
     lodDistancePct > 0
)

float capitalAtLodPct = validLodStopDistance
     ? accountRiskPct / lodDistancePct * 100.0
     : na

// Half 포지션 사이징:
// 기존 요구대로 현재가가 Half 위일 때만 계산
float capitalAtHalfPct = (
     priceAboveHalf and
     not na(halfStopDistancePct) and
     halfStopDistancePct > 0
     ? accountRiskPct / halfStopDistancePct * 100.0
     : na
)

// ─────────────────────────────────────────────────────────────────────────────
// Display strings
// ─────────────────────────────────────────────────────────────────────────────
string marketCapText = na(marketCap)
     ? "N/A"
     : str.tostring(marketCap, format.volume) + " " + syminfo.currency

// 예:
// 95.50 (↓4.50%)
string lodText = validDayData
     ? f_price(dayLow) + " (↓" + f_pct(lodDistancePct) + ")"
     : "N/A"

string halfArrow = ""

if validDayData
    halfArrow := (
         currentPrice > halfRange
         ? "↓"
         : currentPrice < halfRange
             ? "↑"
             : ""
    )

// 현재가 > Half: 100.00 (↓2.50%)
// 현재가 < Half: 100.00 (↑2.50%)
// 현재가 = Half: 100.00 (0.00%)
string halfText = validDayData
     ? f_price(halfRange) + " (" + halfArrow + f_pct(halfMovePct) + ")"
     : "N/A"

// LOD 투입자본:
// 현재가가 Half 아래여도 LOD 거리가 존재하면 표시
string capitalLodText = (
     not na(capitalAtLodPct)
     ? f_pct(capitalAtLodPct)
     : validDayData and lodDistancePct <= 0
         ? "N/A (LOD 거리 0%)"
         : "N/A"
)

string inactiveHalfSizingText = "N/A (현재가 ≤ Half)"

string capitalHalfText = priceAboveHalf
     ? f_pct(capitalAtHalfPct)
     : inactiveHalfSizingText

string headerValue = (
     syminfo.ticker +
     " | Risk " +
     f_pct(accountRiskPct)
)

// ─────────────────────────────────────────────────────────────────────────────
// Table colors
// ─────────────────────────────────────────────────────────────────────────────
color headerBg  = color.rgb(38, 42, 50)
color labelBg   = color.rgb(24, 27, 33)
color valueBg   = color.rgb(15, 17, 21)
color gridColor = color.new(color.gray, 65)

color halfValueColor = color.gray

if validDayData
    halfValueColor := (
         currentPrice > halfRange
         ? color.orange
         : currentPrice < halfRange
             ? color.lime
             : color.white
    )

// LOD 투입자본 색상 역시 Half 조건과 분리
color capitalLodColor = color.gray

if not na(capitalAtLodPct)
    capitalLodColor := (
         capitalAtLodPct > 100
         ? color.orange
         : color.aqua
    )

color capitalHalfColor = color.gray

if priceAboveHalf and not na(capitalAtHalfPct)
    capitalHalfColor := (
         capitalAtHalfPct > 100
         ? color.orange
         : color.aqua
    )

// ─────────────────────────────────────────────────────────────────────────────
// Table
// ─────────────────────────────────────────────────────────────────────────────
var table riskTable = table.new(
     position.top_right,
     2,
     8,
     bgcolor = valueBg,
     frame_color = gridColor,
     frame_width = 1,
     border_color = gridColor,
     border_width = 1
)

if barstate.islast
    // Header
    table.cell(
         riskTable,
         0,
         0,
         "TRADE RISK",
         text_color = color.white,
         bgcolor = headerBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         0,
         headerValue,
         text_color = color.white,
         bgcolor = headerBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // 10D ADR%
    table.cell(
         riskTable,
         0,
         1,
         "10D ADR%",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         1,
         f_pct(adr10Pct),
         text_color = color.white,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // 20D ADR%
    table.cell(
         riskTable,
         0,
         2,
         "20D ADR%",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         2,
         f_pct(adr20Pct),
         text_color = color.white,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // Market Cap
    table.cell(
         riskTable,
         0,
         3,
         "Market Cap",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         3,
         marketCapText,
         text_color = color.white,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // STOP LOD
    table.cell(
         riskTable,
         0,
         4,
         "STOP — LOD",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         4,
         lodText,
         text_color = color.red,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // STOP Half
    table.cell(
         riskTable,
         0,
         5,
         "STOP — Half",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         5,
         halfText,
         text_color = halfValueColor,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // Capital allocation — LOD stop
    table.cell(
         riskTable,
         0,
         6,
         "투입자본 — LOD",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         6,
         capitalLodText,
         text_color = capitalLodColor,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )

    // Capital allocation — Half stop
    table.cell(
         riskTable,
         0,
         7,
         "투입자본 — Half",
         text_color = color.silver,
         bgcolor = labelBg,
         text_halign = text.align_left,
         text_size = size.small
    )

    table.cell(
         riskTable,
         1,
         7,
         capitalHalfText,
         text_color = capitalHalfColor,
         bgcolor = valueBg,
         text_halign = text.align_right,
         text_size = size.small
    )
````
