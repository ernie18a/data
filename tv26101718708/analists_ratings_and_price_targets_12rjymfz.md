# Analists Ratings and Price Targets

- url: https://www.tradingview.com/script/12RjYMfz-Analists-Ratings-and-Price-Targets/
- type: indicator
- pine_id: PUB;d001ca4bcb254c3183947e216c1d392b
- version: 1.0

## Description

This indicator shows TradingView's analyst data directly on the price chart: the current analyst price-target consensus (high, average and low) and the breakdown of analyst ratings (Buy, Hold, Sell). Its goal is to make these numbers easy to read and easy to judge: every value shows its distance from the current price, how many analysts are behind it and how recent the latest target is. 


[b]Purpose[/b]
I used Claude to help with the script construction, though my original intention was to help not just with stock trading but also provide some context for out-of-the money option puts and calls potential strike selling levels.


[b]Key concepts[/b]
- Price target: an analyst's estimate of where a stock will trade in about 12 months. The script reads the latest consensus TradingView provides for the symbol (syminfo.target_price_*). TradingView's Help Center names FactSet as the provider of its analyst data.
- High and Low are single analysts: the highest and the lowest individual target among all estimates. Avg is the mean of all of them.
- % vs price = (target ÷ current price − 1) × 100. A positive value means the target is above the current price.
- Estimates: the number of price targets behind the consensus, with the date and age of the most recent one.
- The distance between High and Low shows how much analysts disagree.
- Ratings: the number of Buy, Hold and Sell recommendations (syminfo.recommendations_*). TradingView counts ratings separately from price targets, so the ratings total and the number of estimates often differ, and each set has its own date.


[b]What it shows[/b]
- Lines for the High, Avg and Low targets, extended to the right of the last bar (High and Low dashed, Avg solid). Width and colors are configurable.
- Labels with the target price, its % vs the current price and the number of analysts behind it ("highest of 36 analysts", "average of 36 analysts", "lowest of 36 analysts"). Label size and horizontal offset are configurable. When targets are close together, the High and Low labels are moved apart (minimum spacing in multiples of ATR 14), while the lines stay at the exact prices.
- An information panel with configurable position (nine positions) and size:
   – Price, High, Avg and Low, each with its % vs the current price.
   – Estimates: the number of price targets, the date of the most recent one and its age in days.
   – Ratings (optional): Buy, Hold and Sell counts with their share, the total, and the date of the latest set of ratings. An option splits them into Strong Buy, Buy, Hold, Sell and Strong Sell.
   – Hover over any cell for an explanation of the value.


[b]How to use it[/b]
Add the indicator to a stock chart and read the panel and labels:
- Where is the price within the analyst range? A Low target close to the current price means even the most bearish analyst sees little downside; a price above the Avg means the stock has already passed the consensus.
- How wide is the range? A large gap between High and Low signals strong disagreement among analysts.
- How solid is the consensus? Check the number of estimates (an extreme picked from 3 targets says much less than one picked from 30) and the age of the latest target.
- What do analysts recommend? Compare the rating breakdown with the price targets; they are separate datasets and can tell different stories.


[b]Screening signal: planned, currently disabled[/b]
The script was designed with a second, independent component: a strictly binary screening output for TradingView's Pine Screener. It lets users define conditions on each estimate (for example, "Low estimate above −10% of the current price"), combine them with AND or OR, optionally require a recent target, and scan a whole watchlist or index for the stocks that meet them (1 = conditions met, 0 = not met).
This feature is disabled in the current version. Testing showed that the Pine Screener, which is still in Beta, currently returns no analyst or company data to scripts: price data is available, but analyst targets, rating counts and other company fields all come back empty. Without that data the signal would be 0 for every symbol. The complete code is kept in the script as comments, so the feature can be enabled once TradingView makes this data available to the Pine Screener.


[b]What is different[/b]
Several public scripts display analyst targets and ratings. This one focuses on making the reliability of those numbers visible: it identifies High and Low as single-analyst values, shows the number of analysts behind every line and the age of the latest target, keeps price targets and ratings apart with their own counts and dates, and explains every value on hover. It was also built with the screening component described above, which is ready in the code but disabled until the required data is available.


[b]Limitations[/b]
- Only symbols with analyst coverage have data. ETFs, indices, futures and crypto usually have none; the panel then shows "—" or "no data".
- TradingView provides the latest consensus, not its history, so the indicator shows current values only (drawn on the last bar) and cannot show how targets have changed over time.
- Price targets are opinions, not forecasts of known accuracy, and different data providers can report different consensus values for the same stock.
- Pine does not expose which firms are behind the High or Low target, nor the age of individual targets; the age shown is that of the most recent target.
- Percentages use the chart's closing price. Use standard candles in the symbol's own currency.

[b]Disclaimer[/b]
This script is a tool for information and analysis. It does not produce buy or sell recommendations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © apdusp

//@version=6
// ═════════════════════════════════════════════════════════════════════════════
//  Analists Ratings and Price Targets · Pine Script® v6
//  Data: syminfo.target_price_* and syminfo.recommendations_* — the latest analyst
//  price-target consensus and rating counts TradingView exposes to Pine
//  (na when a symbol has no coverage).
//
//  ACTIVE · Chart display → estimate lines, labels and info panel, drawn on the
//           last bar only.
//
//  DISABLED · Screening signal (kept for future use) → a strictly binary 1/0 plot
//           designed for the Pine Screener. The Pine Screener (Beta) currently
//           returns no analyst or company data to scripts (tested: every syminfo
//           analyst/company field came back empty), so the feature cannot work
//           there yet. All of its code is kept below on lines starting with
//           "//SCR ". To re-enable it, use Find & Replace in the Pine Editor to
//           replace "//SCR " with nothing; no other edit is needed.
// ═════════════════════════════════════════════════════════════════════════════
indicator("Analists Ratings and Price Targets", shorttitle = "Analists Ratings and Price Targets v1.9", overlay = true, behind_chart = false)

// ─── Types ────────────────────────────────────────────────────────────────────
enum PanelPos
    tr = "Top right"
    tc = "Top center"
    tl = "Top left"
    mr = "Middle right"
    mc = "Middle center"
    ml = "Middle left"
    br = "Bottom right"
    bc = "Bottom center"
    bl = "Bottom left"

enum TextSize
    tiny   = "Tiny"
    small  = "Small"
    normal = "Normal"
    large  = "Large"
    huge   = "Huge"

//SCR enum Measure
//SCR     pct   = "% vs current price"
//SCR     price = "Target price"
//SCR
//SCR enum Combine
//SCR     all = "All enabled conditions (AND)"
//SCR     any = "Any enabled condition (OR)"

// ═════════════════════════════════════════════════════════════════════════════
//  INPUTS · Chart display (visual only)
// ═════════════════════════════════════════════════════════════════════════════
const string G_DISP = "1 · Chart display"

bool     linesInput     = input.bool(true, "Estimate lines", inline = "ln", group = G_DISP, display = display.none)
int      lineWidthInput = input.int(2, "width", minval = 1, maxval = 4, inline = "ln", group = G_DISP, display = display.none)
color    colHighInput   = input.color(#26a69a, "Colors: high", inline = "col", group = G_DISP, display = display.none)
color    colAvgInput    = input.color(#ffa726, "avg", inline = "col", group = G_DISP, display = display.none)
color    colLowInput    = input.color(#ef5350, "low", inline = "col", group = G_DISP, display = display.none)
bool     labelsInput    = input.bool(true, "Labels", inline = "lb", group = G_DISP, display = display.none)
TextSize labelSizeInput = input.enum(TextSize.large, "size", inline = "lb", group = G_DISP, display = display.none)
int      labelOffInput  = input.int(3, "offset (bars)", minval = 0, maxval = 200, inline = "lb", group = G_DISP, display = display.none)
float    labelGapInput  = input.float(1.0, "Label min spacing (× ATR 14)", minval = 0.0, step = 0.25, group = G_DISP, display = display.none, tooltip = "When two estimates are close, their labels are pushed apart by at least this distance. The lines always stay at the exact target prices. 0 = off.")
bool     labelCountInput = input.bool(true, "Show analyst count in labels", group = G_DISP, display = display.none, tooltip = "TradingView exposes a single count: the number of price targets behind the consensus. The average uses all of them; the high and low are the single highest and lowest target of that same set.")
bool     panelInput     = input.bool(true, "Panel", inline = "pn", group = G_DISP, display = display.none)
PanelPos panelPosInput  = input.enum(PanelPos.tc, "position", inline = "pn", group = G_DISP, display = display.none)
TextSize panelSizeInput = input.enum(TextSize.large, "size", inline = "pn", group = G_DISP, display = display.none)
bool     ratingsInput   = input.bool(true, "Show analyst ratings in panel", inline = "rt", group = G_DISP, display = display.none)
bool     ratingsSplitInput = input.bool(false, "split strong buy/sell", inline = "rt", group = G_DISP, display = display.none, tooltip = "Off: Buy (strong buy + buy), Hold, Sell (sell + strong sell). On: all five categories.\nRatings are counted separately from price targets, so their total can differ from 'Estimates'.")
//SCR bool     panelSigInput  = input.bool(true, "Show screening result in panel", group = G_DISP, display = display.none)
//SCR bool     thrLevelsInput = input.bool(false, "Show screening thresholds as price levels", group = G_DISP, display = display.none, tooltip = "Dotted lines at the price each enabled threshold corresponds to (in % mode, relative to the current price).")

//SCR // ═════════════════════════════════════════════════════════════════════════════
//SCR //  INPUTS · 2 — Screening signal (drives only the 1/0 output)
//SCR // ═════════════════════════════════════════════════════════════════════════════
//SCR const string G_SCR = "2 · Screening signal"
//SCR const string T_THR = "Checkbox = whether the condition is used; the value stays editable and is ignored while unchecked. 'below' is strict (<), 'above' is strict (>). Units follow 'Measure thresholds as'."
//SCR
//SCR Measure measureInput = input.enum(Measure.pct, "Measure thresholds as", group = G_SCR, tooltip = "% vs current price: (estimate ÷ price − 1) × 100, so −10 means 10% below the price.\nTarget price: absolute level in the symbol's quote currency.")
//SCR
//SCR bool  lowBelowOn  = input.bool(false, "Low estimate · below", inline = "lo", group = G_SCR)
//SCR float lowBelow    = input.float(-10.0, "", step = 1.0, inline = "lo", group = G_SCR)
//SCR bool  lowAboveOn  = input.bool(true,  "above", inline = "lo", group = G_SCR)
//SCR float lowAbove    = input.float(-10.0, "", step = 1.0, inline = "lo", group = G_SCR, tooltip = T_THR)
//SCR
//SCR bool  avgBelowOn  = input.bool(false, "Avg estimate · below", inline = "av", group = G_SCR)
//SCR float avgBelow    = input.float(-10.0, "", step = 1.0, inline = "av", group = G_SCR)
//SCR bool  avgAboveOn  = input.bool(false, "above", inline = "av", group = G_SCR)
//SCR float avgAbove    = input.float(10.0, "", step = 1.0, inline = "av", group = G_SCR, tooltip = T_THR)
//SCR
//SCR bool  highBelowOn = input.bool(false, "High estimate · below", inline = "hi", group = G_SCR)
//SCR float highBelow   = input.float(-10.0, "", step = 1.0, inline = "hi", group = G_SCR)
//SCR bool  highAboveOn = input.bool(false, "above", inline = "hi", group = G_SCR)
//SCR float highAbove   = input.float(10.0, "", step = 1.0, inline = "hi", group = G_SCR, tooltip = T_THR)
//SCR
//SCR Combine combineInput = input.enum(Combine.all, "Signal = 1 when", group = G_SCR, tooltip = "With no condition enabled, the signal is 1 for every symbol that has analyst targets and 0 for symbols without coverage.")
//SCR
//SCR bool freshOn   = input.bool(false, "Latest target no older than", inline = "fr", group = G_SCR)
//SCR int  freshDays = input.int(20, "days", minval = 1, maxval = 3650, inline = "fr", group = G_SCR, tooltip = "Optional data-quality filter, applied on top of the conditions above with either AND or OR: the most recent analyst price target must be at most N days old.\nTradingView only provides the date of the newest target, so this cannot tell whether the high or low target itself is stale.")
//SCR
//SCR // With AND, 'above A' and 'below B' on the same estimate need A < B; otherwise the signal could never be 1.
//SCR bool impossibleBand = combineInput == Combine.all and (
//SCR      (lowBelowOn  and lowAboveOn  and lowAbove  >= lowBelow)  or
//SCR      (avgBelowOn  and avgAboveOn  and avgAbove  >= avgBelow)  or
//SCR      (highBelowOn and highAboveOn and highAbove >= highBelow))
//SCR if impossibleBand
//SCR     runtime.error("An estimate has 'above' ≥ 'below' while combining with AND, so the signal could never be 1. Fix the thresholds or switch to 'Any'.")

// ═════════════════════════════════════════════════════════════════════════════
//  DATA
// ═════════════════════════════════════════════════════════════════════════════
float tLow    = syminfo.target_price_low
float tAvg    = syminfo.target_price_average
float tHigh   = syminfo.target_price_high
nEst          = syminfo.target_price_estimates
tDate         = syminfo.target_price_date
bool  hasData = not (na(tLow) and na(tAvg) and na(tHigh))
// Age of the most recent analyst price target, in days (TradingView exposes only the newest target's date).
float tAgeDays = na(tDate) ? na : (timenow - tDate) / 86400000.0

// Analyst ratings (display only; na when the symbol has no rating coverage).
rBuyStrong    = syminfo.recommendations_buy_strong
rBuy          = syminfo.recommendations_buy
rHold         = syminfo.recommendations_hold
rSell         = syminfo.recommendations_sell
rSellStrong   = syminfo.recommendations_sell_strong
rTotal        = syminfo.recommendations_total
rDate         = syminfo.recommendations_date
float rBuyAll  = na(rBuyStrong) and na(rBuy) ? na : nz(rBuyStrong) + nz(rBuy)
float rSellAll = na(rSell) and na(rSellStrong) ? na : nz(rSell) + nz(rSellStrong)

//@function % distance from the current price to `t`; na without a target or a valid price.
pctVsPrice(float t) =>
    not na(t) and close > 0 ? (t / close - 1.0) * 100.0 : na

//SCR //@function The value the screening thresholds are compared against, per 'Measure thresholds as'.
//SCR metric(float t) =>
//SCR     measureInput == Measure.pct ? pctVsPrice(t) : t

float pLow  = pctVsPrice(tLow)
float pAvg  = pctVsPrice(tAvg)
float pHigh = pctVsPrice(tHigh)

//SCR // ═════════════════════════════════════════════════════════════════════════════
//SCR //  PURPOSE 2 · SCREENING SIGNAL
//SCR // ═════════════════════════════════════════════════════════════════════════════
//SCR float mLow  = metric(tLow)
//SCR float mAvg  = metric(tAvg)
//SCR float mHigh = metric(tHigh)
//SCR
//SCR int nEnabled = (lowBelowOn ? 1 : 0) + (lowAboveOn ? 1 : 0) + (avgBelowOn ? 1 : 0) + (avgAboveOn ? 1 : 0) + (highBelowOn ? 1 : 0) + (highAboveOn ? 1 : 0)
//SCR // A condition on a missing estimate (na) is never met.
//SCR int nMet = (
//SCR      (lowBelowOn  and mLow  < lowBelow  ? 1 : 0) + (lowAboveOn  and mLow  > lowAbove  ? 1 : 0) +
//SCR      (avgBelowOn  and mAvg  < avgBelow  ? 1 : 0) + (avgAboveOn  and mAvg  > avgAbove  ? 1 : 0) +
//SCR      (highBelowOn and mHigh < highBelow ? 1 : 0) + (highAboveOn and mHigh > highAbove ? 1 : 0))
//SCR
//SCR bool  condOk    = nEnabled == 0 ? hasData : combineInput == Combine.all ? nMet == nEnabled : nMet > 0
//SCR // Data-quality gate, applied on top of the conditions regardless of AND/OR.
//SCR bool  freshOk   = not freshOn or (not na(tAgeDays) and tAgeDays <= freshDays)
//SCR bool  screenOk  = condOk and freshOk
//SCR // Strictly binary, never na: 1 = user-defined conditions met · 0 = not met (including no coverage).
//SCR float screenSig = screenOk ? 1.0 : 0.0
//SCR
//SCR // Screener outputs. The first ten plots become Pine Screener columns/filters, so the signal comes first.
//SCR // No "pane" in display: these values never draw on the price chart or distort its scale.
//SCR plot(screenSig,            "Screen signal (1/0)",   color = screenOk ? color.green : color.red, display = display.data_window + display.status_line, precision = 0)
//SCR plot(hasData ? 1.0 : 0.0,  "Has target data (1/0)", color = chart.fg_color, display = display.data_window, precision = 0)
//SCR plot(pLow,                 "Low est. % vs price",   color = colLowInput,  display = display.data_window, format = format.percent, precision = 2)
//SCR plot(pAvg,                 "Avg est. % vs price",   color = colAvgInput,  display = display.data_window, format = format.percent, precision = 2)
//SCR plot(pHigh,                "High est. % vs price",  color = colHighInput, display = display.data_window, format = format.percent, precision = 2)
//SCR plot(tLow,                 "Low estimate",          color = colLowInput,  display = display.data_window, format = format.price)
//SCR plot(tAvg,                 "Avg estimate",          color = colAvgInput,  display = display.data_window, format = format.price)
//SCR plot(tHigh,                "High estimate",         color = colHighInput, display = display.data_window, format = format.price)
//SCR plot(nEst,                 "Estimates (count)",     color = chart.fg_color, display = display.data_window, precision = 0)
//SCR plot(tAgeDays,             "Latest target age (days)", color = chart.fg_color, display = display.data_window, precision = 0)
//SCR
//SCR // Placeholders reference plots by title, so reordering plots cannot break the messages.
//SCR alertcondition(screenOk, "Screen conditions met", '{{ticker}}: analyst-target screen met (low {{plot("Low est. % vs price")}}%, high {{plot("High est. % vs price")}}%)')
//SCR alertcondition(screenOk and not screenOk[1], "Screen conditions newly met", '{{ticker}}: analyst-target screen just became true (low {{plot("Low est. % vs price")}}%, high {{plot("High est. % vs price")}}%)')

// ═════════════════════════════════════════════════════════════════════════════
//  CHART DISPLAY (last bar only)
// ═════════════════════════════════════════════════════════════════════════════
toPos(PanelPos p) =>
    switch p
        PanelPos.tc => position.top_center
        PanelPos.tl => position.top_left
        PanelPos.mr => position.middle_right
        PanelPos.mc => position.middle_center
        PanelPos.ml => position.middle_left
        PanelPos.br => position.bottom_right
        PanelPos.bc => position.bottom_center
        PanelPos.bl => position.bottom_left
        => position.top_right

toSize(TextSize s) =>
    switch s
        TextSize.tiny   => size.tiny
        TextSize.normal => size.normal
        TextSize.large  => size.large
        TextSize.huge   => size.huge
        => size.small

fmtPct(float p) =>
    na(p) ? "—" : (p >= 0 ? "+" : "") + str.tostring(p, "0.00") + "%"

fmtPrice(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

//SCR fmtThr(float x) =>
//SCR     measureInput == Measure.pct ? (x > 0 ? "+" : "") + str.tostring(x, "0.##") + "%" : str.tostring(x, format.mintick)
//SCR
//SCR condTxt(string name, bool bOn, float b, bool aOn, float a) =>
//SCR     string s = ""
//SCR     if bOn
//SCR         s := name + " < " + fmtThr(b)
//SCR     if aOn
//SCR         s := s + (s == "" ? "" : " · ") + name + " > " + fmtThr(a)
//SCR     s
//SCR
//SCR joinTxt(string a, string b) =>
//SCR     a == "" ? b : b == "" ? a : a + " · " + b

//@function Second label line with the analyst count. `kind` is "avg", "high" or "low"; empty when no count is available.
analystTxt(string kind) =>
    if na(nEst) or not labelCountInput
        ""
    else
        int    n   = int(nEst)
        string who = str.tostring(n) + (n == 1 ? " analyst" : " analysts")
        kind == "avg" ? "average of " + who : kind == "high" ? "highest of " + who : "lowest of " + who

drawEstimate(array<line> ls, array<label> lbs, float y, float labelY, string name, color c, string lineStyle, string countTxt) =>
    if not na(y)
        if linesInput
            ls.push(line.new(bar_index, y, bar_index + 1, y, extend = extend.right, color = c, width = lineWidthInput, style = lineStyle))
        if labelsInput
            string txt = name + "  " + fmtPrice(y) + "  (" + fmtPct(pctVsPrice(y)) + ")" + (countTxt == "" ? "" : "\n" + countTxt)
            lbs.push(label.new(bar_index + labelOffInput, labelY, txt, style = label.style_label_left, color = color.new(c, 15), textcolor = color.white, size = toSize(labelSizeInput), textalign = text.align_left))

//SCR drawThreshold(array<line> ls, array<label> lbs, bool on, float thr, string name) =>
//SCR     float y = measureInput == Measure.pct ? close * (1.0 + thr / 100.0) : thr
//SCR     if on and not na(y)
//SCR         ls.push(line.new(bar_index, y, bar_index + 1, y, extend = extend.right, color = color.new(chart.fg_color, 50), width = 1, style = line.style_dotted))
//SCR         lbs.push(label.new(bar_index, y, name + " " + fmtThr(thr), style = label.style_label_right, color = color.new(chart.fg_color, 85), textcolor = chart.fg_color, size = toSize(labelSizeInput)))

celT(table t, int c, int r, string txt, color tc, color bg, string tip) =>
    t.cell(c, r, txt, text_color = tc, bgcolor = bg, text_size = toSize(panelSizeInput), text_halign = c == 0 ? text.align_left : text.align_right, tooltip = tip)

estRow(table t, int r, string name, float price, float pct, color c, string tip) =>
    celT(t, 0, r, name, c, na, tip)
    celT(t, 1, r, fmtPrice(price), chart.fg_color, na, tip)
    celT(t, 2, r, fmtPct(pct), chart.fg_color, na, tip)

const color COL_BUY  = #26a69a
const color COL_HOLD = #9e9e9e
const color COL_SELL = #ef5350

//@function One ratings row: count and share of all ratings.
ratingRow(table t, int r, string name, float n, float total, color c, string tip) =>
    celT(t, 0, r, name, c, na, tip)
    celT(t, 1, r, na(n) ? "—" : str.tostring(n, "0"), chart.fg_color, na, tip)
    celT(t, 2, r, na(n) or na(total) or total <= 0 ? "" : str.tostring(n / total * 100.0, "0") + "%", chart.fg_color, na, tip)

// Panel layout: fixed rows for price/targets, then the optional ratings block (sub-header + categories + total)
// and the screening block (disabled: sigRows stays 0 until the //SCR lines are re-enabled).
const int BASE_ROWS = 6
int ratingRows  = ratingsInput ? (ratingsSplitInput ? 7 : 5) : 0
int ratingsRow0 = BASE_ROWS
int sigRows     = 0
//SCR sigRows  := panelSigInput ? 2 : 0
int sigRow0     = BASE_ROWS + ratingRows
int panelRows   = sigRow0 + sigRows

// Minimum vertical distance between estimate labels, in price units.
float labelGap = ta.atr(14) * labelGapInput

var array<line>  drawnLines  = array.new<line>()
var array<label> drawnLabels = array.new<label>()
var table        panel       = na
//SCR var bool         panelMerged = false

if barstate.islast
    for ln in drawnLines
        ln.delete()
    drawnLines.clear()
    for lb in drawnLabels
        lb.delete()
    drawnLabels.clear()

    // Keep the average label at its price; push the high label up and the low label down when they would overlap.
    float yHighLbl = tHigh
    float yLowLbl  = tLow
    if labelGap > 0
        if not na(tAvg)
            if not na(tHigh) and tHigh - tAvg < labelGap
                yHighLbl := tAvg + labelGap
            if not na(tLow) and tAvg - tLow < labelGap
                yLowLbl := tAvg - labelGap
        else if not na(tHigh) and not na(tLow) and tHigh - tLow < labelGap
            float mid = (tHigh + tLow) / 2.0
            yHighLbl := mid + labelGap / 2.0
            yLowLbl  := mid - labelGap / 2.0

    drawEstimate(drawnLines, drawnLabels, tHigh, yHighLbl, "High", colHighInput, line.style_dashed, analystTxt("high"))
    drawEstimate(drawnLines, drawnLabels, tAvg,  tAvg,     "Avg",  colAvgInput,  line.style_solid,  analystTxt("avg"))
    drawEstimate(drawnLines, drawnLabels, tLow,  yLowLbl,  "Low",  colLowInput,  line.style_dashed, analystTxt("low"))

//SCR     if thrLevelsInput
//SCR         drawThreshold(drawnLines, drawnLabels, lowBelowOn,  lowBelow,  "Low <")
//SCR         drawThreshold(drawnLines, drawnLabels, lowAboveOn,  lowAbove,  "Low >")
//SCR         drawThreshold(drawnLines, drawnLabels, avgBelowOn,  avgBelow,  "Avg <")
//SCR         drawThreshold(drawnLines, drawnLabels, avgAboveOn,  avgAbove,  "Avg >")
//SCR         drawThreshold(drawnLines, drawnLabels, highBelowOn, highBelow, "High <")
//SCR         drawThreshold(drawnLines, drawnLabels, highAboveOn, highAbove, "High >")

    if panelInput
        if na(panel)
            panel := table.new(toPos(panelPosInput), 3, panelRows, bgcolor = color.new(chart.bg_color, 5), frame_color = color.new(chart.fg_color, 60), frame_width = 1, border_color = color.new(chart.fg_color, 85), border_width = 1)

        color  fg     = chart.fg_color
        color  subBg  = color.new(chart.fg_color, 88)
        string nTxt   = na(nEst) ? "?" : str.tostring(nEst, "0")
        string ageTxt = na(tAgeDays) ? "" : " · " + str.tostring(math.floor(tAgeDays), "0") + "d"

        // Price-target section.
        celT(panel, 0, 0, syminfo.ticker + " · " + syminfo.currency, fg, subBg, syminfo.description)
        celT(panel, 1, 0, "Value", fg, subBg, "Price level")
        celT(panel, 2, 0, "vs price", fg, subBg, "Distance from the current price")
        string priceTip = "Current price (last bar). All percentages are measured from it."
        celT(panel, 0, 1, "Price", fg, na, priceTip)
        celT(panel, 1, 1, fmtPrice(close), fg, na, priceTip)
        celT(panel, 2, 1, "", fg, na, priceTip)
        estRow(panel, 2, "High", tHigh, pHigh, colHighInput, "Highest single analyst price target among " + nTxt + " estimates.")
        estRow(panel, 3, "Avg",  tAvg,  pAvg,  colAvgInput,  "Average (mean) of " + nTxt + " analyst price targets.")
        estRow(panel, 4, "Low",  tLow,  pLow,  colLowInput,  "Lowest single analyst price target among " + nTxt + " estimates.")
        string estTip = "Number of analyst price targets behind the consensus, and the date (and age) of the most recent one."
        celT(panel, 0, 5, "Estimates", fg, na, estTip)
        celT(panel, 1, 5, na(nEst) ? "—" : nTxt, fg, na, estTip)
        celT(panel, 2, 5, na(tDate) ? "" : str.format_time(tDate, "yyyy-MM-dd") + ageTxt, fg, na, estTip)

        // Ratings section, with its own sub-header so the columns read "Count | Share".
        if ratingsInput
            bool   hasRatings = not na(rTotal) and rTotal > 0
            string rTip       = "Analyst ratings are counted separately from price targets, so their total can differ from 'Estimates'."
            int    totalRow   = ratingsRow0 + ratingRows - 1
            celT(panel, 0, ratingsRow0, "Ratings" + (na(rDate) ? "" : " · " + str.format_time(rDate, "yyyy-MM-dd")), fg, subBg, rTip + " The date is when the latest set of ratings starts.")
            celT(panel, 1, ratingsRow0, "Count", fg, subBg, rTip)
            celT(panel, 2, ratingsRow0, "Share", fg, subBg, "Share of all ratings")
            if ratingsSplitInput
                ratingRow(panel, ratingsRow0 + 1, "Strong buy",  rBuyStrong,  rTotal, COL_BUY,  rTip)
                ratingRow(panel, ratingsRow0 + 2, "Buy",         rBuy,        rTotal, COL_BUY,  rTip)
                ratingRow(panel, ratingsRow0 + 3, "Hold",        rHold,       rTotal, COL_HOLD, rTip)
                ratingRow(panel, ratingsRow0 + 4, "Sell",        rSell,       rTotal, COL_SELL, rTip)
                ratingRow(panel, ratingsRow0 + 5, "Strong sell", rSellStrong, rTotal, COL_SELL, rTip)
            else
                ratingRow(panel, ratingsRow0 + 1, "Buy",  rBuyAll,  rTotal, COL_BUY,  "Strong buy + buy ratings.")
                ratingRow(panel, ratingsRow0 + 2, "Hold", rHold,    rTotal, COL_HOLD, "Hold ratings.")
                ratingRow(panel, ratingsRow0 + 3, "Sell", rSellAll, rTotal, COL_SELL, "Sell + strong sell ratings.")
            celT(panel, 0, totalRow, "Total", fg, na, rTip)
            celT(panel, 1, totalRow, hasRatings ? str.tostring(rTotal, "0") : "no data", hasRatings ? fg : COL_SELL, na, rTip)
            celT(panel, 2, totalRow, "", fg, na, rTip)

//SCR         // Read-only mirror of Purpose 2, so a single chart shows what the screener will see.
//SCR         if panelSigInput
//SCR             string conds  = joinTxt(joinTxt(condTxt("Low", lowBelowOn, lowBelow, lowAboveOn, lowAbove), condTxt("Avg", avgBelowOn, avgBelow, avgAboveOn, avgAbove)), condTxt("High", highBelowOn, highBelow, highAboveOn, highAbove))
//SCR             if freshOn
//SCR                 conds := (conds == "" ? "" : conds + "  |  ") + "latest target ≤ " + str.tostring(freshDays) + "d old"
//SCR             string sigTxt = screenOk ? "1 · met" : not hasData ? "0 · no data" : condOk and not freshOk ? "0 · target too old" : "0 · not met"
//SCR             color  sigBg  = screenOk ? color.new(color.green, 15) : hasData ? color.new(color.red, 15) : color.gray
//SCR             string sigTip = "Same value as the 'Screen signal (1/0)' plot used by the Pine Screener: 1 when the conditions below are met, 0 otherwise (including symbols without analyst targets)."
//SCR             celT(panel, 0, sigRow0, "Screen signal", fg, subBg, sigTip)
//SCR             celT(panel, 1, sigRow0, sigTxt, color.white, sigBg, sigTip)
//SCR             celT(panel, 2, sigRow0, combineInput == Combine.all ? "AND" : "OR", fg, subBg, "How the enabled conditions are combined. The target-age filter, when enabled, always applies on top.")
//SCR             celT(panel, 0, sigRow0 + 1, conds == "" ? "No conditions · unrestricted" : conds, fg, na, "Conditions set in '2 · Screening signal'.")
//SCR             if not panelMerged
//SCR                 panel.merge_cells(0, sigRow0 + 1, 2, sigRow0 + 1)
//SCR                 panelMerged := true
````
