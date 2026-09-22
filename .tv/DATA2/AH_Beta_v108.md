<!-- tradingview-pine-id: PUB;ebd500a668f14052affa8d9ae9536de9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# AH Beta v1.0.8

Source: https://www.tradingview.com/script/YYkBChom-AH-Beta-v1/

## Description

AH Beta compares an asset with a reference symbol across several fixed daily-bar windows. It places beta and return correlation together in a compact table, so you can see both the asset's historical sensitivity to the reference and the strength of their linear relationship.

AH Beta is a free, open-source indicator shared as a contribution to the TradingView community. It is part of the AH information and education series. The report brings standard beta and correlation calculations together across several horizons, using one selected reference and daily return observations. You can explore the source and adapt it to your own approach.

Why show more than one beta?

A beta value describes a particular comparison and sample. To interpret it, you need to know the reference, return frequency and observation period. A one-month estimate and a five-year estimate answer different questions; two providers can report different betas because their choices differ.

AH Beta makes those choices visible. The reference appears in the heading, calculations use daily prices, and each column identifies its model period. Short windows show recent relationships; longer windows provide a broader history. Comparing them can reveal changes in sensitivity and association, without assuming that any one window is the correct answer for every purpose.

The windows overlap. A difference between columns is descriptive evidence, not a statistical test of a regime change. Shorter samples are more sensitive to individual observations; longer samples can combine very different market conditions.

Reading the report

The heading identifies the reference and the report, for example US500 · US 500 Index (Beta & Correlation). The chart symbol is the asset being measured against that reference. Long reference descriptions are shortened on the chart; the heading tooltip identifies both symbols.

Columns show 1M, 3M, 6M, 9M, 1Y, 2Y, 3Y, 4Y and 5Y. All nine are enabled by default. These labels use a fixed convention: 21 daily bars per month and 252 daily bars per year.

• B — Beta: historical sensitivity of the asset's returns to the reference's returns.
• C — Correlation: Pearson correlation of the same paired returns, from −1 to +1.
• Green: a positive value. Red: a negative value. Blue: zero. These colors describe direction, not investment quality.
• Dash: an unavailable result. Hover to read the reason; missing results are not replaced with zero.

Values use two decimal places. Colors follow the underlying value, so a very small positive or negative result can round to zero while retaining its directional color.

Hover over B or C for the definition. Period and value tooltips show the required daily-bar count, date range and available observations. A short explanation appears if a result is unavailable. The heading tooltip identifies the asset, reference and date of the calculation.

https://www.tradingview.com/x/g0qH6v3p/

Figure 1 — One asset, two references. Two instances of AH Beta compare Exxon Mobil (XOM) with US500 in the upper table and WTI crude oil (USOIL) in the lower table. Read the same period across both tables to see how beta and correlation differ with the selected reference.

To use this arrangement, add the indicator twice, choose a different Reference in each copy and give the tables separate Positions. This example shows another way to use the report: the asset stays the same while the comparison changes.

Beta and correlation measure different things

Beta is the slope of the historical linear relationship between asset and reference returns. It is calculated as:

Beta = covariance(asset returns, reference returns) / variance(reference returns)

A beta of +1.5 describes an estimated sensitivity of 1.5 percentage points in the asset's return for a one-percentage-point difference in the reference's return, within that sample's fitted relationship. It does not mean the asset moves exactly 1.5% whenever the reference moves 1%, and it is not a forecast.

Positive beta indicates a positive estimated relationship; negative beta indicates an inverse one. Beta is relative to the selected reference. It does not measure all of the asset's risk or guarantee that a negative-beta asset will hedge a future decline.

Correlation describes how closely the paired returns follow a linear relationship:

Correlation = covariance(asset returns, reference returns) / (asset return standard deviation × reference return standard deviation)

Values near +1 indicate a strong positive linear relationship; values near −1 indicate a strong inverse relationship. Values near zero indicate a weak linear relationship in the sample, not proof of independence or absence of all relationships.

For nonzero return variances, the formulas are connected:

Beta = correlation × (asset return standard deviation / reference return standard deviation)

This is why both rows matter. A beta of +2.0 alongside correlation of +0.25 describes positive sensitivity with weak linear association; it does not describe the same behavior as beta +2.0 alongside correlation +0.90. Nonzero beta and correlation calculated from the same observations have the same sign.

Daily data and bar counts

The calculation runs on the chart asset's daily bars. Switching to a five-minute or weekly chart changes the display interval, not the calculation into five-minute or weekly returns.

Reference daily prices are brought into that daily context using TradingView's normal bar mapping. The script does not build a separate list of common trading dates or adjust the sample length for weekends and holidays. When the reference has no new bar, the platform carries its available value forward. Repeated reference closes produce zero reference returns in the mapped series. The resulting comparison follows the asset's daily-bar sequence, so the mapped sample can differ when the two symbols are reversed.

Both beta and correlation use simple returns: close / previous close − 1. The prices are standard, regular-session and split-adjusted where provided. Dividends, risk-free-rate subtraction and currency conversion are not included. Each valid return observation receives equal weight.

The period convention

The model uses fixed counts rather than subtracting calendar dates:

• 1M: 21 daily bars.
• 3M: 63 daily bars.
• 6M: 126 daily bars.
• 9M: 189 daily bars.
• 1Y: 252 daily bars.
• 2Y: 504 daily bars.
• 3Y: 756 daily bars.
• 4Y: 1,008 daily bars.
• 5Y: 1,260 daily bars.

These are model labels, not a claim that every market has the same trading calendar. For example, 252 cryptocurrency daily bars cover a shorter calendar span than 252 weekday-market daily bars. The count stays fixed; the tooltip shows the dates actually covered by the asset's sample.

A 252-bar calculation uses 252 return observations and needs the preceding price to calculate the first return. It does not collect an extra calendar year's history or expand the window to replace invalid observations. If the selected window does not have the required valid returns, its result is unavailable.

If reference returns have zero variance, both beta and correlation are unavailable. If only asset returns are constant, beta is zero and correlation is unavailable. A missing or nonpositive price makes the affected return unavailable; zero price movement is a valid zero return.

Settings, in order

Data

Reference: US500 by default. Select another TradingView symbol to change the comparison. There is no automatic reference selection by asset class. Use a reference that fits the question you want to examine; US500 is a starting choice, not a universally appropriate benchmark. Providers using similar names can have different feeds and sessions, and a US500 CFD is not necessarily identical to a cash or total-return index.

Report

• Position: nine chart anchors; TopCenter by default.
• Text size: shared report size, default 12, adjustable from 8 to 20.
• Label color: B/C labels and unavailable values.
• Title color: reference and period-heading text.
• Background color: body background and transparency; transparent by default.
• Highlight color: reference heading, period headings and B/C label backgrounds; cream by default.
• Border color / Border width: internal cell lines; width 1 by default, adjustable from 0 to 5. Zero hides them.
• Frame color / Frame width: outer table frame; width 1 by default, adjustable from 0 to 5. Zero hides it.

The table is always present while the indicator is visible. Positive, negative and zero assessment colors remain fixed.

Periods

All nine periods are enabled initially. Turn off individual columns to make the report narrower. If every period is disabled, the table displays a reminder to select a period in Settings.

Exploring the open source

The source is organized into fixed period counts, formatting helpers, daily return statistics, report records, settings, data requests and table drawing. Comments explain the choices at each stage.

Window statistics use Pine's correlation and standard-deviation functions. Beta is calculated as correlation multiplied by the ratio of asset to reference return standard deviation, which is equivalent to covariance divided by reference variance. Both rows use the same returns and window. Beta is not smoothed, annualized or adjusted toward one. Correlation is bounded to −1 through +1 to contain floating-point rounding effects.

Data and interpretation

Results depend on provider history, revisions, symbol coverage and the selected reference. Returns remain in each symbol's native quote currency. Comparing symbols quoted in different currencies does not produce the returns of a portfolio converted into a single investor currency. The longest calculation requires 1,260 returns; the daily request includes a history allowance of 1,500 bars.

This is a current report, not a historical signal plot or backtest. A developing daily bar can update the results while markets are open. The data requests use lookahead off, and the report follows the daily data available through the platform. Session hours and feed updates can affect which reference price is available on a given asset bar.

Beta and correlation summarize past observations. Outliers and changing relationships can affect both. The report does not provide buy/sell signals, alerts, price targets, a combined score or a probability of future performance. It is an information and education tool, not investment advice.

---

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0: https://mozilla.org/MPL/2.0/
// © AlpHay

const string indVersion = "1.0.8"
const string indType = "Beta"
const string indName = "AH " + indType + " v" + indVersion

indicator(indName, indType, overlay = true, max_bars_back = 1500)

// Period labels use a fixed model: 21 daily bars per month, 252 per year.
const int len1M = 21
const int len3M = 63
const int len6M = 126
const int len9M = 189
const int len1Y = 252
const int len2Y = 504
const int len3Y = 756
const int len4Y = 1008
const int len5Y = 1260

const color cxx = color.rgb(255, 255, 255, 100)

const color cred = color.rgb(242, 53, 69)
const color cgrn = color.rgb(10, 153, 129)
const color cblu = color.rgb(40, 98, 255)
const color ccrm = color.rgb(248, 236, 202)
const color lbc1 = color.rgb(128, 128, 128)

method toText(float this, string format= "#.##", bool isFormatAlt= false, float target= 0.0, int multiplier= 1) =>
    string out = ""
    if not na(this)
        if format == format.percent
            float pct = this * multiplier
            out := str.tostring(pct, "#.##") + "%"
            if isFormatAlt and pct >= target
                out := "+" + out
        else
            out := isFormatAlt ? this <= target ? str.tostring(this, format) : "+" + str.tostring(this, format) : str.tostring(this, format)
    out

method toColor(float this, float target= 0.0, bool isFlipped= false) => isFlipped ? (this > target ? cred : this < target ? cgrn : cblu) : (this > target ? cgrn : this < target ? cred : cblu)

method addCell(table this, int columnId, int rowId, string title, color txtColor, string horAlign= na, int txtSize= na, string tooltip= na, color bgColor= na, string verAlign= na, bool isBold= false, bool isItalic= false) =>
    table.cell(this, columnId, rowId, title, 0, 0, txtColor, na(horAlign)?text.align_right:horAlign, na(verAlign)?text.align_center:verAlign, na(txtSize)?10:txtSize, na(bgColor)?cxx:bgColor, tooltip, font.family_monospace)
    if isBold and isItalic
        table.cell_set_text_formatting(this, columnId, rowId, text.format_bold+text.format_italic)
    else if isBold
        table.cell_set_text_formatting(this, columnId, rowId, text.format_bold)
    else if isItalic
        table.cell_set_text_formatting(this, columnId, rowId, text.format_italic)
    this

enum TablePosition
	TopLeft
	TopCenter
	TopRight
	MidLeft
	MidCenter
	MidRight
	BotLeft
	BotCenter
	BotRight

method getPosition(TablePosition this) =>
    switch this
        TablePosition.TopLeft => position.top_left
        TablePosition.TopCenter => position.top_center
        TablePosition.TopRight => position.top_right
        TablePosition.MidLeft => position.middle_left
        TablePosition.MidCenter => position.middle_center
        TablePosition.MidRight => position.middle_right
        TablePosition.BotLeft => position.bottom_left
        TablePosition.BotCenter => position.bottom_center
        TablePosition.BotRight => position.bottom_right
        => position.middle_center

// Statistics are evaluated inside the asset's daily context.
// Reference prices use TradingView's normal bar mapping, without a separate date join.
dailyStats(float referenceClose, int length) =>
    bool valid = not na(close) and not na(close[1]) and close > 0 and close[1] > 0 and not na(referenceClose) and not na(referenceClose[1]) and referenceClose > 0 and referenceClose[1] > 0
    float assetReturn = valid ? close / close[1] - 1.0 : na
    float referenceReturn = valid ? referenceClose / referenceClose[1] - 1.0 : na
    float runningCount = ta.cum(valid ? 1.0 : 0.0)
    int count = int(runningCount - nz(runningCount[length]))
    float assetDeviation = ta.stdev(assetReturn, length)
    float referenceDeviation = ta.stdev(referenceReturn, length)
    float correlation = ta.correlation(assetReturn, referenceReturn, length)
    float beta = na
    if count == length and referenceDeviation > 0.0
        // Covariance / reference variance = correlation * asset deviation / reference deviation.
        beta := assetDeviation == 0.0 ? 0.0 : correlation * assetDeviation / referenceDeviation
        correlation := assetDeviation > 0.0 ? math.max(-1.0, math.min(1.0, correlation)) : na
    else
        correlation := na
    [beta, correlation, count]

dailyReport(string referenceTicker) =>
    [referenceClose, description] = request.security(referenceTicker, "1D", [close, syminfo.description], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    [b1M, c1M, n1M] = dailyStats(referenceClose, len1M)
    [b3M, c3M, n3M] = dailyStats(referenceClose, len3M)
    [b6M, c6M, n6M] = dailyStats(referenceClose, len6M)
    [b9M, c9M, n9M] = dailyStats(referenceClose, len9M)
    [b1Y, c1Y, n1Y] = dailyStats(referenceClose, len1Y)
    [b2Y, c2Y, n2Y] = dailyStats(referenceClose, len2Y)
    [b3Y, c3Y, n3Y] = dailyStats(referenceClose, len3Y)
    [b4Y, c4Y, n4Y] = dailyStats(referenceClose, len4Y)
    [b5Y, c5Y, n5Y] = dailyStats(referenceClose, len5Y)
    [b1M, c1M, n1M, time_tradingday[len1M], b3M, c3M, n3M, time_tradingday[len3M], b6M, c6M, n6M, time_tradingday[len6M], b9M, c9M, n9M, time_tradingday[len9M], b1Y, c1Y, n1Y, time_tradingday[len1Y], b2Y, c2Y, n2Y, time_tradingday[len2Y], b3Y, c3Y, n3Y, time_tradingday[len3Y], b4Y, c4Y, n4Y, time_tradingday[len4Y], b5Y, c5Y, n5Y, time_tradingday[len5Y], time_tradingday, description]

type BetaWindow
    string Title
    int Length
    int Start
    int End
    int Count
    float Beta
    float Correlation

formatDate(int stamp) => na(stamp) ? "—" : str.format_time(stamp, "yyyy-MM-dd", "UTC")

method toTooltip(BetaWindow this) =>
    string out = str.tostring(this.Length) + " daily bars"
    out += "\n" + formatDate(this.Start) + " to " + formatDate(this.End)
    out += "\nObservations: " + str.tostring(this.Count)
    if this.Count < this.Length
        out += "\nNot enough data for this period."
    else if na(this.Beta)
        out += "\nReference returns do not vary."
    else if na(this.Correlation)
        out += "\nAsset returns do not vary; correlation is unavailable."
    out

// Settings: one user-selected reference, report appearance and visible periods.
var string targetSymbol = input.symbol("US500", "Reference", group = "Data", tooltip = "Symbol to compare with the chart asset.")

var TablePosition tablePos = input.enum(TablePosition.TopCenter, "Position", group = "Report")
var int lsz = input.int(12, "Text size", minval = 8, maxval = 20, group = "Report")
var color labelColor = input.color(lbc1, "Label color", group = "Report", tooltip = "Text color of the B and C row labels.")
var color titleColor = input.color(lbc1, "Title color", group = "Report")
var color backgroundColor = input.color(cxx, "Background color", group = "Report")
var color highlightColor = input.color(ccrm, "Highlight color", group = "Report", tooltip = "Background and transparency of the reference, period headings and row labels.")

var color borderColor = input.color(color.new(lbc1, 75), "Border color", group = "Report", tooltip = "Color and transparency of the internal cell borders.")
var int borderWidth = input.int(1, "Border width", minval = 0, maxval = 5, group = "Report", tooltip = "Internal cell border width in pixels. Set to 0 to hide the borders.")
var color frameColor = input.color(color.new(lbc1, 75), "Frame color", group = "Report", tooltip = "Color and transparency of the outer table frame.")
var int frameWidth = input.int(1, "Frame width", minval = 0, maxval = 5, group = "Report", tooltip = "Outer table frame width in pixels. Set to 0 to hide the frame.")

// Both sides use standard, regular-session, split-adjusted prices in their native currencies.
var string mainTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.regular, adjustment.splits)
var string targetPrefix = syminfo.prefix(targetSymbol)
var string targetTick = syminfo.ticker(targetSymbol)
var string targetTicker = ticker.new(targetPrefix, targetTick, session.regular, adjustment.splits)
var bool has1M = input.bool(true, "1M", group = "Periods", inline = "short", tooltip = "21 daily bars.")
var bool has3M = input.bool(true, "3M", group = "Periods", inline = "short")
var bool has6M = input.bool(true, "6M", group = "Periods", inline = "short")
var bool has9M = input.bool(true, "9M", group = "Periods", inline = "short")
var bool has1Y = input.bool(true, "1Y", group = "Periods", inline = "long")
var bool has2Y = input.bool(true, "2Y", group = "Periods", inline = "long")
var bool has3Y = input.bool(true, "3Y", group = "Periods", inline = "long")
var bool has4Y = input.bool(true, "4Y", group = "Periods", inline = "long")
var bool has5Y = input.bool(true, "5Y", group = "Periods", inline = "long")

var string betaTooltip = "Beta: historical sensitivity of the asset's returns to the reference."
var string corrTooltip = "Correlation: strength and direction of the linear relationship between returns, from -1 to +1."
var string pos = tablePos.getPosition()
var table tbl = na

// Calculate on daily bars first, then display the results on the chart interval.
[b1M, c1M, n1M, s1M, b3M, c3M, n3M, s3M, b6M, c6M, n6M, s6M, b9M, c9M, n9M, s9M, b1Y, c1Y, n1Y, s1Y, b2Y, c2Y, n2Y, s2Y, b3Y, c3Y, n3Y, s3Y, b4Y, c4Y, n4Y, s4Y, b5Y, c5Y, n5Y, s5Y, lastDay, targetDescription] = request.security(mainTicker, "1D", dailyReport(targetTicker), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true, calc_bars_count = 1500)

if barstate.islast
    array<BetaWindow> windows = array.new<BetaWindow>()
    if has1M
        windows.push(BetaWindow.new("1M", len1M, s1M, lastDay, n1M, b1M, c1M))
    if has3M
        windows.push(BetaWindow.new("3M", len3M, s3M, lastDay, n3M, b3M, c3M))
    if has6M
        windows.push(BetaWindow.new("6M", len6M, s6M, lastDay, n6M, b6M, c6M))
    if has9M
        windows.push(BetaWindow.new("9M", len9M, s9M, lastDay, n9M, b9M, c9M))
    if has1Y
        windows.push(BetaWindow.new("1Y", len1Y, s1Y, lastDay, n1Y, b1Y, c1Y))
    if has2Y
        windows.push(BetaWindow.new("2Y", len2Y, s2Y, lastDay, n2Y, b2Y, c2Y))
    if has3Y
        windows.push(BetaWindow.new("3Y", len3Y, s3Y, lastDay, n3Y, b3Y, c3Y))
    if has4Y
        windows.push(BetaWindow.new("4Y", len4Y, s4Y, lastDay, n4Y, b4Y, c4Y))
    if has5Y
        windows.push(BetaWindow.new("5Y", len5Y, s5Y, lastDay, n5Y, b5Y, c5Y))

    // Keep room for a settings hint when all period columns are hidden.
    int lastCol = math.max(1, windows.size())
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(pos, lastCol + 1, 4, bgcolor = backgroundColor, frame_color = frameColor, frame_width = frameWidth, border_color = borderColor, border_width = borderWidth)
    table.merge_cells(tbl, 0, 0, lastCol, 0)
    string referenceName = na(targetDescription) ? "" : targetDescription
    string referenceTitle = targetTick + (referenceName == "" or referenceName == targetTick ? "" : " · " + referenceName)
    string referenceTip = "Asset: " + syminfo.prefix + ":" + syminfo.ticker
    referenceTip += "\nReference: " + targetSymbol
    referenceTip += "\nAs of: " + formatDate(lastDay)
    string analysisTitle = " (Beta & Correlation)"
    int titleLimit = math.max(20, math.min(64, lastCol * 8) - str.length(analysisTitle))
    string title = (str.length(referenceTitle) > titleLimit ? str.substring(referenceTitle, 0, titleLimit - 1) + "…" : referenceTitle) + analysisTitle
    tbl.addCell(0, 0, title, titleColor, text.align_left, lsz, referenceTip, highlightColor, isBold = true)
    tbl.addCell(0, 1, "", titleColor, text.align_center, lsz, bgColor = highlightColor)
    tbl.addCell(0, 2, "B", labelColor, text.align_center, lsz, betaTooltip, highlightColor, isBold = true)
    tbl.addCell(0, 3, "C", labelColor, text.align_center, lsz, corrTooltip, highlightColor, isBold = true)
    if windows.size() == 0
        tbl.addCell(1, 1, "Select a period in Settings", labelColor, text.align_left, lsz, bgColor = backgroundColor)
    for i = 0 to (windows.size() == 0 ? na : windows.size() - 1)
        BetaWindow window = windows.get(i)
        string details = window.toTooltip()
        string betaText = na(window.Beta) ? "—" : window.Beta.toText("0.00", true)
        string corrText = na(window.Correlation) ? "—" : window.Correlation.toText("0.00", true)
        tbl.addCell(i + 1, 1, " " + window.Title + " ", titleColor, text.align_center, lsz, details, highlightColor, isBold = true)
        tbl.addCell(i + 1, 2, " " + betaText + " ", na(window.Beta) ? labelColor : window.Beta.toColor(), text.align_right, lsz, "Beta\n" + details, backgroundColor)
        tbl.addCell(i + 1, 3, " " + corrText + " ", na(window.Correlation) ? labelColor : window.Correlation.toColor(), text.align_right, lsz, "Correlation\n" + details, backgroundColor)
````
