# Stock: Snowflake Analysis [invincible3]

- url: https://www.tradingview.com/script/RKrRMHb9-Stock-Snowflake-Analysis-invincible3/
- type: indicator
- pine_id: PUB;fd5e1911c58f4b7db8db84f0405c3ce5
- version: 1.0

## Description

[b]Stock: Snowflake Analysis [invincible3][/b]

Stock: Snowflake Analysis [invincible3] is a visual fundamental-analysis radar indicator designed for stock traders and investors who want a quick, structured view of a company’s financial quality. The indicator converts multiple TradingView financial metrics into normalized 0–100 scores and displays them as a six-axis snowflake/radar chart directly on the price chart.

The purpose of the indicator is to help users quickly evaluate a stock from several key perspectives: dividend quality, growth, inventory efficiency, financial stability, valuation, and future outlook. Each metric is transformed into a score, then plotted visually so the user can immediately see where a company is strong or weak. The current script uses six core categories: Dividend, Growth, Inventory, Stability, Valuation, and Future, and it draws the final score as a radar/snowflake polygon.

[b]Main Concept[/b]
The indicator works by pulling available stock financial data from TradingView using request.financial(). These values are then normalized into scores from 0 to 100.

A score near 100 means the company is strong in that category.
A score near 50 means the company is neutral or average.
A score near 0 means the company is weak in that category.

The final snowflake shape gives a quick visual overview:

A large, balanced snowflake suggests broad financial strength.
A small or uneven snowflake suggests weakness or imbalance.
A stretched shape shows that the company is strong in some areas but weak in others.

[b]Six Core Financial Categories[/b]
[b]1. Dividend Score[/b]
The Dividend axis evaluates whether the stock provides attractive and sustainable shareholder distributions.

It uses:

Dividend yield
Dividend payout ratio

The dividend yield is scored positively when it is higher, while the payout ratio is scored negatively if it becomes too high. A very high payout ratio may suggest that the dividend is less sustainable.

A strong Dividend score usually means the company has a decent yield without excessive payout pressure.

[b]2. Growth Score[/b]
The Growth axis measures how well the company is expanding.

It uses:

Revenue growth
EPS growth
Gross margin

The score rewards companies with improving sales, stronger earnings, and healthier gross margins. A company with strong revenue growth but weak margins may receive a mixed score, while a company with both growth and profitability receives a stronger score.

This category is especially useful for identifying companies with improving business momentum.

[b]3. Inventory Score[/b]
The Inventory axis evaluates operating efficiency, especially for businesses where inventory management matters.

It uses:

Inventory turnover
Inventory-to-revenue ratio

Higher inventory turnover is considered positive because it suggests that the company sells its inventory efficiently. A lower inventory-to-revenue ratio is also considered positive because it indicates that inventory is not becoming too heavy relative to sales.

This score is more useful for retail, manufacturing, consumer goods, and industrial companies. It is less meaningful for banks, software companies, or service businesses.

[b]4. Stability Score[/b]
The Stability axis measures balance-sheet strength.

It uses:

Current ratio
Debt-to-equity ratio

A higher current ratio generally suggests better short-term liquidity, while a lower debt-to-equity ratio suggests lower financial leverage.

A strong Stability score means the company appears financially safer and less dependent on debt. A weak score may suggest liquidity pressure or excessive leverage.

[b]5. Valuation Score[/b]
The Valuation axis evaluates whether the stock appears reasonably priced relative to earnings.

It uses:

Earnings yield
Price-to-earnings ratio

Earnings yield is calculated as:

Earnings Yield = EPS / Price × 100

A higher earnings yield is better. A lower P/E ratio is also better, up to a reasonable threshold. This category rewards companies that generate meaningful earnings relative to their current share price.

A high Valuation score may suggest the stock is cheaper relative to earnings, while a low score may suggest the stock is expensive or earnings are weak.

[b]6. Future Score[/b]
The Future axis attempts to measure forward-looking quality.

It uses:

Sustainable growth rate
Forward P/E ratio

A higher sustainable growth rate improves the score, while a very high forward P/E lowers the score. This category tries to balance future growth potential with future valuation risk.

A strong Future score suggests the stock may have a reasonable combination of expected growth and forward valuation.

[b]Final Score[/b]
The center score is calculated as the average of the six category scores:

Final Score = Average of Dividend, Growth, Inventory, Stability, Valuation, and Future

This final score is displayed in the center of the radar chart.

The score color changes dynamically using the indicator’s heatmap color theme:

Low scores appear in purple tones.
Mid scores appear in teal tones.
High scores appear in green/yellow tones.

This makes it easier to visually identify weak, neutral, and strong readings.

[b]Visual Design[/b]
The indicator displays a clean snowflake/radar chart directly on the price chart. Each axis represents one financial category.

Visual components include:

Hexagonal grid rings
Axis lines
Category labels
Score markers
Filled snowflake polygon
Dynamic color based on total score
Optional historical comparison snowflake

The snowflake is placed to the right side of the latest bar using the Right Offset setting, so it does not cover the current candles.

[b]Historical Comparison[/b]
The indicator includes an optional Historical Snowflake feature.

When enabled, it compares the current snowflake with a previous score profile based on the selected historical lookback.

For example:

Historical Lookback = 252 bars

This can be used as an approximate one-year comparison on daily charts.

The historical snowflake helps users see whether the company’s fundamental profile has improved, weakened, or remained stable over time.

[b]Stock-Only Protection[/b]
This indicator is designed for stock symbols only because financial metrics such as dividend yield, payout ratio, EPS, revenue growth, and debt-to-equity are stock/company-specific data.

For non-stock symbols such as:

Gold
Forex pairs
Crypto
Indices
Commodities

the script does not draw the snowflake. Instead, it displays a warning message explaining that financial metrics are not available for those instruments.

This prevents misleading neutral scores from appearing on symbols where company financial data does not exist.

[b]Input Settings
Radar Layout[/b]

[b]Right Offset Bars[/b]
Moves the snowflake to the right side of the latest candle.

[b]Scale Lookback[/b]
Controls the price range used to vertically scale the snowflake on the chart. This does not affect the financial scores.

[b]Width[/b]
Controls the horizontal size of the radar.

[b]Height %[/b]
Controls the vertical size of the radar relative to the recent price range.

[b]Label Distance[/b]
Controls how far the category labels are placed from the radar center.

[b]Visual Styling[/b]
[b]Show Grid Rings[/b]
Turns the hexagonal background rings on or off.

[b]Show Axis Lines[/b]
Turns the center-to-axis guide lines on or off.

[b]Show Axis Labels[/b]
Shows or hides the category names and scores.

[b]Show Score Markers[/b]
Shows or hides circular markers at each snowflake point.

[b]Dynamic Colors[/b]
When enabled, the snowflake color changes based on the total average score.

[b]Marker Size[/b]
Controls the size of the score markers.

[b]Historical Comparison[/b]

[b]Show Historical Snowflake[/b]
Displays a previous score profile for comparison.

[b]Historical Lookback Bars[/b]
Defines how far back the comparison should be calculated.

[b]How to Interpret the Snowflake[/b]
A strong stock usually shows:

A broad and balanced snowflake
High Growth and Stability scores
Reasonable Valuation score
Improving Future score

A risky or weak stock may show:

A compressed snowflake
Very low Stability
Weak Growth
Expensive Valuation
Poor Future score

An unbalanced company may show a stretched snowflake. For example, a high Growth score but low Stability and Valuation scores may indicate a fast-growing but financially risky or expensive company.

[b]Best Use Cases[/b]
This indicator is useful for:

Quick stock screening
Comparing companies visually
Identifying financial strengths and weaknesses
Monitoring changes in a company’s financial profile
Combining fundamentals with technical analysis
Long-term investing and swing-trading research

It is especially helpful when comparing stocks within the same sector.

[b]Important Notes[/b]
The indicator uses a generic scoring model. Different sectors naturally have different financial structures.

For example:

Banks do not use inventory metrics in the same way as retail companies.
Utilities often carry higher debt.
Technology companies may have low dividend scores but strong growth.
Retail and manufacturing companies rely more heavily on inventory efficiency.

Because of this, the scores should be interpreted with sector context.

[b]Limitations[/b]
This indicator should not be used as a standalone buy or sell signal.

Financial data can be delayed, unavailable, or inconsistent depending on the symbol and exchange. When a financial metric is missing, the script uses a neutral internal fallback value to keep the radar visually stable.

The indicator is best used as a summary and comparison tool, not as a complete valuation model.

[b]Disclaimer[/b]
Snowflake Analysis [invincible3] is an educational and research tool. It is not financial advice. Users should always combine this indicator with their own analysis, sector research, risk management, and broader market context before making trading or investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator(
     "Stock: Snowflake Analysis [invincible3]",
     shorttitle          = "Snowflake",
     overlay             = true,
     max_lines_count     = 200,
     max_labels_count    = 200,
     max_polylines_count = 100,
     max_boxes_count     = 20
)

// ─────────────────────────────────────────────
// Groups & Inputs
// ─────────────────────────────────────────────

string GRP_LAYOUT = "Radar Layout"
string GRP_VIS    = "Visual Styling"
string GRP_HIST   = "Historical Comparison"

// Layout Inputs
int offsetInput        = input.int(50, "Right Offset (Bars)", minval = 0, maxval = 500, group = GRP_LAYOUT, tooltip = "Number of bars to shift the radar chart to the right.")
int lookbackBarsInput  = input.int(300, "Scale Lookback", minval = 50, maxval = 5000, group = GRP_LAYOUT, tooltip = "Lookback for determining price-based scaling.")
float radarWidthInput  = input.float(32.0, "Width", minval = 5.0, maxval = 200.0, group = GRP_LAYOUT)
float radarHeightInput = input.float(0.30, "Height %", minval = 0.05, maxval = 1.00, step = 0.01, group = GRP_LAYOUT)
float labelDistInput   = input.float(1.30, "Label Distance", minval = 1.00, maxval = 2.00, step = 0.05, group = GRP_LAYOUT)

// Visualization Inputs
bool showGridInput    = input.bool(true, "Show Grid Rings", group = GRP_VIS)
bool showAxisInput    = input.bool(true, "Show Axis Lines", group = GRP_VIS)
bool showLabelsInput  = input.bool(true, "Show Axis Labels", group = GRP_VIS)
bool showCirclesInput = input.bool(true, "Show Score Markers", group = GRP_VIS)
bool dynamicLineInput = input.bool(true, "Dynamic Colors", group = GRP_VIS)

string markerSizeOpt = input.string(
     "Small",
     "Marker Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GRP_VIS
)

// Historical Comparison Inputs
bool showHistorical = input.bool(false, "Show Historical Snowflake", group = GRP_HIST, tooltip = "Compare current scores with a past period.")
int histLookback    = input.int(252, "Historical Lookback (Bars)", minval = 1, group = GRP_HIST, tooltip = "Commonly 252 bars for 1 trading year.")

// ─────────────────────────────────────────────
// Constants & Colors
// ─────────────────────────────────────────────

color COL_GRID = color.new(#96a0af, 50)
color COL_AXIS = color.new(#96a0af, 50)
color COL_HIST = color.new(#96a0af, 50)

color COL_LOW  = #5d2d7f
color COL_MID  = #538687
color COL_HIGH = #9dd960
color COL_NA   = #555a64

// ─────────────────────────────────────────────
// Functions
// ─────────────────────────────────────────────

f_clamp(float x, float lo, float hi) =>
    math.min(math.max(x, lo), hi)

f_scale(float v, float bad, float good) =>
    na(v) ? na : f_clamp((v - bad) / (good - bad) * 100.0, 0.0, 100.0)

f_scaleInv(float v, float good, float bad) =>
    na(v) ? na : f_clamp((bad - v) / (bad - good) * 100.0, 0.0, 100.0)

f_avg(array<float> vals) =>
    float s = 0.0
    int n = 0

    for v in vals
        if not na(v)
            s += v
            n += 1

    n > 0 ? s / n : na

f_heatColor(float v) =>
    float x = f_clamp(nz(v), 0.0, 100.0)

    na(v) ? COL_NA :
     x <= 50.0 ? color.from_gradient(x, 0.0, 50.0, COL_LOW, COL_MID) :
                  color.from_gradient(x, 50.0, 100.0, COL_MID, COL_HIGH)

f_markerSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.large

f_getPoint(int cx, float cy, float rx, float ry, float pct, int i) =>
    float ang = math.pi / 2.0 - i * math.pi / 3.0
    int px = cx + int(math.round(math.cos(ang) * rx * pct))
    float py = cy + math.sin(ang) * ry * pct

    chart.point.from_index(px, py)

// Safe financial request.
// ignore_invalid_symbol=true prevents runtime errors on Gold, Forex, Crypto, Indices, etc.
f_fin(simple string id, simple string period) =>
    request.financial(
         syminfo.tickerid,
         id,
         period,
         ignore_invalid_symbol = true
    )

// ─────────────────────────────────────────────
// Financial Data & Scoring
// ─────────────────────────────────────────────

bool isStock = syminfo.type == "stock"

get_scores() =>
    float divYield     = f_fin("DIVIDENDS_YIELD", "FY")
    float payoutRatio  = f_fin("DIVIDEND_PAYOUT_RATIO", "TTM")
    float revGrowth    = f_fin("REVENUE_ONE_YEAR_GROWTH", "TTM")
    float epsGrowth    = f_fin("EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH", "TTM")
    float grossMargin  = f_fin("GROSS_MARGIN", "TTM")
    float invTurn      = f_fin("INVENT_TURNOVER", "FY")
    float invToRev     = f_fin("INVENT_TO_REVENUE", "FY")
    float currentRatio = f_fin("CURRENT_RATIO", "FQ")
    float debtEquity   = f_fin("DEBT_TO_EQUITY", "FQ")
    float epsBasic     = f_fin("EARNINGS_PER_SHARE_BASIC", "TTM")
    float fwdPE        = f_fin("PRICE_EARNINGS_FORWARD", "FY")
    float sustGrowth   = f_fin("SUSTAINABLE_GROWTH_RATE", "FY")

    float sDiv = f_avg(array.from(
         f_scale(divYield, 0.0, 6.0),
         na(payoutRatio) ? na : payoutRatio <= 65.0 ? 100.0 : f_scaleInv(payoutRatio, 65.0, 120.0)
    ))

    float sGrow = f_avg(array.from(
         f_scale(revGrowth, -5.0, 25.0),
         f_scale(epsGrowth, -10.0, 30.0),
         f_scale(grossMargin, 5.0, 50.0)
    ))

    float sInv = f_avg(array.from(
         f_scale(invTurn, 2.0, 12.0),
         f_scaleInv(invToRev, 2.0, 30.0)
    ))

    float sStab = f_avg(array.from(
         f_scale(currentRatio, 1.0, 2.5),
         f_scaleInv(debtEquity, 0.2, 2.5)
    ))

    float earningsYield = epsBasic > 0 and close > 0 ? epsBasic / close * 100.0 : na
    float peRatio       = epsBasic > 0 ? close / epsBasic : na

    float sVal = f_avg(array.from(
         f_scale(earningsYield, 1.0, 10.0),
         f_scaleInv(peRatio, 10.0, 45.0)
    ))

    float sFut = f_avg(array.from(
         f_scale(sustGrowth, 2.0, 15.0),
         f_scaleInv(fwdPE, 12.0, 40.0)
    ))

    array.from(
         f_clamp(nz(sDiv, 50.0), 0.0, 100.0),
         f_clamp(nz(sGrow, 50.0), 0.0, 100.0),
         f_clamp(nz(sInv, 50.0), 0.0, 100.0),
         f_clamp(nz(sStab, 50.0), 0.0, 100.0),
         f_clamp(nz(sVal, 50.0), 0.0, 100.0),
         f_clamp(nz(sFut, 50.0), 0.0, 100.0)
    )

array<float> currScores = get_scores()
array<float> histScores = currScores[histLookback]

float avgScore = isStock ? f_avg(currScores) : na

// ─────────────────────────────────────────────
// Visual Logic
// ─────────────────────────────────────────────

float highR = ta.highest(high, lookbackBarsInput)
float lowR  = ta.lowest(low, lookbackBarsInput)

// Persistent objects
var polyline sPoly = na
var polyline hPoly = na

var array<polyline> gPolys  = array.new<polyline>()
var array<line> aLines      = array.new<line>()
var array<label> aLabels    = array.new<label>()

var label warningLabel = na

if barstate.islast
    // Geometry
    int cX = bar_index + offsetInput
    float cY = (highR + lowR) / 2.0

    float rX = radarWidthInput
    float pR = math.max(highR - lowR, syminfo.mintick * 100)
    float rY = pR * radarHeightInput

    // Cleanup
    polyline.delete(sPoly)
    polyline.delete(hPoly)

    if not na(warningLabel)
        label.delete(warningLabel)
        warningLabel := na

    while array.size(gPolys) > 0
        polyline.delete(array.pop(gPolys))

    while array.size(aLines) > 0
        line.delete(array.pop(aLines))

    while array.size(aLabels) > 0
        label.delete(array.pop(aLabels))

    // Non-stock warning only.
    // This stops the radar from appearing on Gold, Forex, Crypto, Indices, etc.
    if not isStock
        warningLabel := label.new(
             bar_index,
             high,
             "Snowflake Analysis works on stock symbols only.\nFinancial metrics are not available for Gold, Forex, Crypto, or Indices.",
             style = label.style_label_down,
             color = color.new(color.red, 0),
             textcolor = color.white,
             size = size.small
        )

    else
        // Grid rings
        if showGridInput
            for g = 1 to 5
                array<chart.point> pts = array.new<chart.point>()

                for i = 0 to 5
                    array.push(pts, f_getPoint(cX, cY, rX, rY, g / 5.0, i))

                array.push(gPolys, polyline.new(
                     pts,
                     closed = true,
                     line_color = COL_GRID,
                     line_width = g == 5 ? 2 : 1
                ))

        // Axis labels and axis lines
        array<string> nms = array.from("Dividend", "Growth", "Inventory", "Stability", "Valuation", "Future")

        for i = 0 to 5
            chart.point pE = f_getPoint(cX, cY, rX, rY, 1.0, i)

            if showAxisInput
                array.push(aLines, line.new(
                     chart.point.from_index(cX, cY),
                     pE,
                     color = COL_AXIS,
                     style = line.style_dotted,
                     width = 1
                ))

            if showLabelsInput
                chart.point pL = f_getPoint(cX, cY, rX, rY, labelDistInput, i)
                float s = array.get(currScores, i)

                array.push(aLabels, label.new(
                     pL,
                     array.get(nms, i) + "\n" + str.tostring(s, "0"),
                     style = label.style_none,
                     textcolor = f_heatColor(s),
                     size = size.normal,
                     textalign = text.align_center
                ))

        // Historical snowflake
        if showHistorical and not na(histScores)
            array<chart.point> hPts = array.new<chart.point>()

            for i = 0 to 5
                float hs = array.get(histScores, i)
                array.push(hPts, f_getPoint(cX, cY, rX, rY, hs / 100.0, i))

            hPoly := polyline.new(
                 hPts,
                 closed = true,
                 line_color = COL_HIST,
                 line_width = 1,
                 line_style = line.style_dashed
            )

        // Current snowflake
        array<chart.point> sPts = array.new<chart.point>()

        color radarColor = dynamicLineInput ? f_heatColor(avgScore) : COL_MID

        for i = 0 to 5
            float s = array.get(currScores, i)
            chart.point pM = f_getPoint(cX, cY, rX, rY, s / 100.0, i)

            array.push(sPts, pM)

            if showCirclesInput
                array.push(aLabels, label.new(
                     pM,
                     "",
                     style = label.style_circle,
                     color = f_heatColor(s),
                     size = f_markerSize(markerSizeOpt)
                ))

        sPoly := polyline.new(
             sPts,
             closed = true,
             line_color = radarColor,
             line_width = 3,
             fill_color = color.new(radarColor, 80)
        )

        // Center summary
        array.push(aLabels, label.new(
             chart.point.from_index(cX, cY),
             "Score\n" + str.tostring(avgScore, "0"),
             style = label.style_none,
             textcolor = f_heatColor(avgScore),
             size = size.small,
             textalign = text.align_center
        ))
````
