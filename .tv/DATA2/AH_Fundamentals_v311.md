<!-- tradingview-pine-id: PUB;99b0b6a35a6a401ba06c9c4f273a5a11 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# AH Fundamentals v3.1.1

Source: https://www.tradingview.com/script/O1f6rAoe-AH-Fundamentals-v3/

## Description

AH Fundamentals brings company data into one compact report on your chart. It combines financial figures, a fixed color-assessment model and changes between available observations, so you can read the company profile, valuation, earnings, debt, cash flow and dividends in one place.

This free, open-source third-generation edition reorganizes the original AH fundamental table into six groups. It is shared as a contribution to the TradingView community. The model's thresholds are visible in the source and can be adapted to your own approach.

This edition is published separately to preserve the original table for its existing users. It introduces grouped reporting, separate current-value and change assessments, comparison tooltips, and operating cash flow, net margin and FCF margin fields. The original publication remains available in its existing form.

Reading the report

https://www.tradingview.com/x/KxCaNcNf/

Figure 1 — Reading the Fundamentals report. The report title identifies the symbol, period and currency. Group headings organize the fields; values and assessment squares describe the current observation, while arrows describe its change.

The main heading identifies the symbol, selected financial period and display currency. The company name, sector and industry appear below when available. Long identity text is shortened on the chart; hover to read it in full.

Each group contains two side-by-side sets of label, value, assessment square and change marker. Read a value and its change separately: a company can have positive earnings while its earnings are falling.

• Green value or square: favorable under that field's model rule. For several fields, it simply means the amount is positive.
• Red value or square: adverse under that field's model rule. Positive total debt, for example, is shown as a debt burden; this is not a solvency verdict.
• Blue value or square: neutral or unclassified under the field's rule. Blue is not a universal middle band: its meaning depends on the field.
• Dash and pale assessment square: the displayed value is unavailable. Missing data is not replaced with zero.
• Up triangle △: the underlying number increased. Down triangle ▽: it decreased. Their green or red color expresses the model's interpretation of that change.
• Unclassified change: the marker uses a fixed neutral gray, independently of Label color. A square marks an unchanged number; a faded square marks unavailable comparison data. Hover to distinguish them.

Hover over a change marker to read Current, Previous available and Change (current − previous). Monetary amounts and share counts use compact K/M/B formatting; ratios and per-share values use up to two decimals. Changes in percentage fields are in percentage points, shown as pp. A move from 10% to 12% is +2 pp. Small underlying changes may round to the same displayed number while the arrow still shows their direction.

Net debt example: a move from −4B to −730M increases net debt by approximately +3.27B. The current value remains green because the company is in a net-cash position; the up arrow is red because the net-cash buffer shrank. Negative net debt means the cash/investment amount used in the provider's definition exceeds debt. It does not mean debt was actually repaid or that gross debt is zero.

Six groups, 47 fields

Company

Enterprise value, Market value, Total Shareholders, Employees (latest), Total shares, Float shares, Total shares (latest), Float shares (latest), Diluted/Buyback shares and Float shares diff.

This group describes company size and ownership. Market value is calculated from reported shares and the requested prior daily close. Enterprise value is a provider financial measure, not an analyst price target. The two share-difference fields compare latest shares with reported shares; a difference alone does not prove a buyback or dilution. Latest snapshots do not have invented previous-period arrows.

Valuation

Price Book Value, Price Earning Ratio, Price Earning Growth, Price Sales Ratio, Book tangible pshare, Price to cash flow, Graham Number and Enterprise to Ebitda.

P/E uses basic TTM earnings per share. P/S uses TTM revenue. Price to cash flow uses diluted shares and TTM operating cash flow. These locally calculated multiples use the requested prior daily close rather than the live chart price. Nonpositive denominators are suppressed in those calculations. Graham Number is compared with the same reference price. A green Price to cash flow indicates a positive cash-flow basis; it does not classify every positive multiple as inexpensive.

Earnings & growth

Earning per share, Revenue 1Y growth, Operation Margin, Return on Equity %, Ebitda margin %, Ebitda, Total Revenue, Net Income and Net margin %.

These fields describe sales, profit and profitability. Net margin is net income divided by revenue, multiplied by 100. The change on Revenue 1Y growth compares the current growth rate with the previous available growth rate. It is separate from the year-over-year calculation already contained in the metric.

Financial position

Quick Ratio, Current Ratio, Working Capital ratio, Cash to Debt, Debt to Equity, Debt to Ebitda, Debt to Revenue, Equity to Asset ratio, Total Debt and Net Debt.

This group describes liquidity and debt. Working Capital ratio intentionally repeats Current Ratio; it is not a monetary working-capital amount. Net Debt and Cash to Debt use the provider's cash and short-term-investment basis, which is broader than the separate Cash & Equivalents field. Do not expect subtracting the displayed Cash & Equivalents from Total Debt to reproduce Net Debt.

Cash & efficiency

Operating cash flow, FCF margin %, Cash & Equivalents, Free Cash Flow, Asset Turnover, Inventory Turnover, Cogs to Revenue and Total Inventory.

Operating cash flow describes cash generated or used by operations. Free cash flow is after capital expenditure; FCF margin divides it by revenue and multiplies by 100. Positive turnover values indicate activity, not a sector-adjusted efficiency grade. Inventory size itself is neutral.

Dividends

Dividend Payout % and Dividend Yield %. Payout relates distributions to earnings; yield describes the provider's dividend yield. A positive yield is not an assessment of dividend safety. Their changes are displayed without a favorable/adverse direction rule.

Settings, in order

Data

Currency — Default, USD or EUR. Default uses the symbol's currency. USD and EUR convert monetary amounts using a daily exchange rate; share counts, percentages and ratios stay unchanged. Current and previous amounts use the same display conversion, so Change describes the financial amount's movement rather than historical currency performance. No conversion is needed when the selected currency already matches the symbol currency.

Period — FQ, FY, FH or TTM. FQ means fiscal quarter, FY fiscal year, FH half year and TTM trailing twelve months. FQ is the default. Not every company supplies every period. With TTM selected, balance-sheet fields and several provider ratios use FQ. Float shares remains FY; Graham Number and PEG use FY for an FH selection. P/E, P/S and Price to cash flow keep TTM denominators. Hover over an individual field for the period actually used.

Report

• Position: nine chart anchors; TopCenter is the default. Choose an anchor that leaves room for the report and chart controls.
• Text size: one shared size for the report, default 12, adjustable from 8 to 20.
• Label color: field-label and company-identity color. Gray is the default; changing it does not change assessment colors or the meaning of change markers.
• Title color: text color of the main heading and group headings. Those headings are always bold; labels and values use normal weight.
• Background color: body-cell background and transparency, transparent by default.
• Highlight color: background and transparency of the main heading and group headings, cream by default.
• Company identity: show or hide the company description, sector and industry row.
• Assessment squares: show or hide the square beside each value. Hiding it retains the value's assessment color.
• Period change: show or hide the change-marker column and its comparison tooltips.

The model's thresholds

These are this edition's fixed model references, not universal standards or a market consensus. They are not calibrated separately for every sector. The following rules apply to available, meaningful values; unsupported calculations remain unavailable.

• Price Book Value: below 3 green; 3 blue; above 3 red. P/E: 0 through 25 green; above 25 blue. PEG: above 0 and below 1 green; otherwise blue. P/S: above 0 through 2 green; above 2 red; otherwise blue.
• Graham Number: a positive value above the positive reference price is green, below it red, equal blue. Enterprise to Ebitda: positive and below 10 green; 10 blue; above 10 red; nonpositive blue.
• Operation Margin: below 9 red; 9 through 15 blue; above 15 green. Return on Equity: 10 or below red; above 10 through 15 blue; above 15 green. The ROE assessment is suppressed when book value per share is missing or nonpositive. Ebitda margin: below 10 red; 10 blue; above 10 green.
• Quick Ratio: below 1 red; 1 blue; above 1 green. Current Ratio and Working Capital ratio: below 1 red; 1 through 1.2 blue; above 1.2 green. Cash to Debt: below 0.5 red; 0.5 or above green.
• Debt to Equity: negative or above 2 red; 0 to below 1 green; 1 through 2 blue. Debt to Ebitda: negative or above 5 red; 0 through 3 green; above 3 through 5 blue.
• Debt to Revenue: negative red; 0 to below 0.40 green; 0.40 blue; above 0.40 red. Cogs to Revenue: the same rule with a 0.65 reference.
• Dividend Payout: negative or above 100 red; zero blue; above 0 through 100 green.

Other sign-assessed values are green above zero, red below zero and blue at zero. They include EPS, revenue growth, tangible book value, EBITDA, revenue, net income, net margin, equity/assets, operating cash flow, FCF margin, cash, free cash flow, turnover and dividend yield. Total Debt, Net Debt and the share-count difference use the inverse sign rule. Company-size snapshots, float-share difference and inventory size are neutral. Price to cash flow assesses only its positive calculation basis.

For changes, increases are favored for earnings, sales growth, margins, revenue, cash and cash flow. Decreases are favored for debt and COGS/revenue. Liquidity ratios favor increases. The ratio-change rules with a nonnegative-data requirement leave sign-crossing observations unclassified. Other available changes retain their direction without a favorable/adverse assessment.

To use different thresholds, edit the relevant field's color expression in the open source. Keep the value rule, direction rule and explanation consistent. No threshold inputs, analyst panel, alerts or combined company score are included in this edition.

Data and interpretation

Previous means the preceding available observation captured by the script, not necessarily the immediately preceding fiscal period. Missing reports can create gaps. The derived margins require matching observation bars for their components; this does not independently verify fiscal-period dates. Financial updates follow the provider's series and should not be read as a record of when an earnings announcement became tradable.

Coverage depends on the symbol, market and reporting period. This report is intended for equities with financial data; company fundamentals will generally be unavailable on cryptocurrency or forex symbols. For consistent financial-data comparisons, use the daily (1D) chart as your reference. Financial observations and the daily price used in calculated valuation ratios can map differently on intraday and weekly charts. Reloading uses the data currently supplied by TradingView, including revisions.

The report is a compact reading aid. Its colors describe individual model conditions, not a recommendation to buy or sell. This is not investment advice.

---

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlpHay

const string indVersion = "3.1.1"
const string indType = "Fundamentals"
const string indName = "AH " + indType + " v" + indVersion
indicator(indName, indType, overlay = true)

const color cxx  = color.rgb(255, 255, 255, 100)
const color cwht = color.rgb(255, 255, 255)
const color cred = color.rgb(242, 53, 69)
const color cgrn = color.rgb(10, 153, 129)
const color cblu = color.rgb(40, 98, 255)
const color ccrm = color.rgb(248, 236, 202)
const color lbc1 = color.rgb(128, 128, 128)

// Report anchors and shared cell rendering.
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

// horAlign/verAlign control text placement; txtSize is the shared report text size.
method addCell(table this, int columnId, int rowId, string title, color txtColor, string horAlign= na, int txtSize= na, string tooltip= na, color bgColor= na, string verAlign= na, bool isBold= false, bool isItalic= false) =>
    table.cell(this, columnId, rowId, title, 0, 0, txtColor, na(horAlign)?text.align_right:horAlign, na(verAlign)?text.align_center:verAlign, na(txtSize)?10:txtSize, na(bgColor)?cxx:bgColor, tooltip, font.family_monospace)
    if isBold and isItalic
        table.cell_set_text_formatting(this, columnId, rowId, text.format_bold+text.format_italic)
    else if isBold
        table.cell_set_text_formatting(this, columnId, rowId, text.format_bold)
    else if isItalic
        table.cell_set_text_formatting(this, columnId, rowId, text.format_italic)
    this

// Use the same field format for report values and comparison tooltips.
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

// Value assessment: a range takes precedence over a single bound, then target.
// isFlipped reverses the preference; each field below supplies its model references.
method toColor(float this, float upper, float lower, float target, bool isFlipped= false) =>
    color out = na
    if not na(this)
        if not na(upper) and not na(lower)
            out := isFlipped ? (this >= lower and this <= upper ? cred : this < lower ? cgrn : cblu ) :(this >= lower and this <= upper ? cgrn : this < lower ? cred : cblu)
        else if not na(upper)
            out := isFlipped ? (this <= upper ? cred : cblu) : (this <= upper ? cgrn : cblu)
        else if not na(lower)
            out := isFlipped ? (this >= lower ? cred : cblu) : (this >= lower ? cgrn : cblu)
        else if not na(target)
            out := isFlipped ? (this > target ? cred : this < target ? cgrn : cblu) : (this > target ? cgrn : this < target ? cred : cblu)
        else
            out := cblu
    else
        out := cblu
    out

method toColor(int this, float upper, float lower, float target, bool isFlipped= false) =>
    float value = float(this)
    value.toColor(upper, lower, target, isFlipped)

enum CurrencyType
    Default
    USD
    EUR

enum FinancialPeriod
    FQ
    FY
    FH
    TTM

const string s02 = "🟥"
const string s04 = "⬜️"
const string s05 = "🟦"
const string s08 = "🟩"

// Retain consecutive available samples; missing periods do not become zero.
// observedAt tracks the chart bar receiving a sample, not its fiscal period end.
getFinancial(string symbolId, string id, string requestedPeriod, bool monetary = false) =>
    float sample = request.financial(symbolId, id, requestedPeriod, gaps = barmerge.gaps_on, ignore_invalid_symbol = true, currency = monetary ? syminfo.currency : "")
    var float value = na
    var float previous = na
    var int observedAt = na
    var int previousAt = na
    if not na(sample)
        previous := value
        previousAt := observedAt
        value := sample
        observedAt := time
    [value, previous, observedAt, previousAt]

// Suppress ratios whose denominator is missing, zero or negative.
safeRatio(float a, float b) => not na(a) and not na(b) and b > 0 ? a / b : na

type FinanceStyle
    int TextSize
    color LabelColor
    color TitleColor
    color BackgroundColor
    color HighlightColor
    bool ShowIdentity
    bool ShowSymbols
    bool ShowChange

type Finance
    string Title
    float Value
    float Previous
    string Format
    color Color
    string Tooltip
    bool Monetary = false         // Convert amounts only; ratios and counts keep their units.
    int ChangeBias = 0             // +1 favors increases, -1 decreases, 0 leaves direction unclassified.
    bool NonnegativeChange = false // Require nonnegative observations for selected ratio comparisons.
    string ChangeUnit = ""

// Assessment is independent of display colors: -1 adverse, 0 unclassified, +1 favorable.
method changeState(Finance this) =>
    int out = 0
    if not na(this.Value) and not na(this.Previous) and this.Value != this.Previous
        if this.ChangeBias != 0 and (not this.NonnegativeChange or (this.Value >= 0 and this.Previous >= 0))
            bool improved = this.ChangeBias > 0 ? this.Value > this.Previous : this.Value < this.Previous
            out := improved ? 1 : -1
    out

// Arrow shape follows numeric direction; its color follows the independent assessment.
method print(Finance this, table tbl, int col, int row, FinanceStyle style, float exchangeRate) =>
    float value = this.Monetary ? this.Value * exchangeRate : this.Value
    color ink = na(value) ? style.LabelColor : this.Color
    string tip = this.Tooltip
    tbl.addCell(col, row, this.Title, style.LabelColor, text.align_left, style.TextSize, tip, style.BackgroundColor)
    tbl.addCell(col + 1, row, na(value) ? "—" : value.toText(this.Format), ink, text.align_right, style.TextSize, tip, style.BackgroundColor)
    int offset = 2
    if style.ShowSymbols
        string square = na(value) ? s04 : ink == cgrn ? s08 : ink == cred ? s02 : s05
        tbl.addCell(col + offset, row, square, ink, text.align_center, style.TextSize, tip, style.BackgroundColor)
        offset += 1
    if style.ShowChange
        bool known = not na(value) and not na(this.Previous)
        string arrow = not known ? "◻︎" : this.Value > this.Previous ? "△" : this.Value < this.Previous ? "▽" : "◻︎"
        // Apply the same display FX to both observations; this is not historical FX performance.
        float previous = this.Monetary ? this.Previous * exchangeRate : this.Previous
        float delta = value - previous
        int assessment = this.changeState()
        color directionColor = not known ? color.new(lbc1, 65) : assessment > 0 ? cgrn : assessment < 0 ? cred : lbc1
        string changeTip = "Current: " + (na(value) ? "—" : value.toText(this.Format))
        if known
            changeTip += "\nPrevious available: " + previous.toText(this.Format)
            changeTip += "\nChange (current − previous): " + delta.toText(this.Format, true) + this.ChangeUnit
            changeTip += "\n" + (this.Value == this.Previous ? "Unchanged." : assessment > 0 ? "Favorable change under the model." : assessment < 0 ? "Adverse change under the model." : "Direction shown; change not assessed.")
            if this.Title == "Net Debt" and this.Value != this.Previous
                changeTip += "\n" + (this.Value < 0 and this.Previous < 0 ? (this.Value > this.Previous ? "Net cash buffer decreased." : "Net cash buffer increased.") : this.Value >= 0 and this.Previous < 0 ? "Moved from net cash to zero or net debt." : this.Value < 0 and this.Previous >= 0 ? "Moved from zero or net debt to net cash." : this.Value > this.Previous ? "Net debt increased." : "Net debt decreased.")
        else
            changeTip += "\nComparable previous observation or display conversion unavailable."
        tbl.addCell(col + offset, row, arrow, directionColor, text.align_center, style.TextSize, changeTip, style.BackgroundColor)

type Fundamentals
    string Period = na
    string Currency = na
    TablePosition Position = TablePosition.TopCenter
    FinanceStyle Style = na
    array<Finance> Items = na
    float __fx = na
    table __report = na

method init(Fundamentals this) =>
    this.Items := array.new<Finance>()
    this

method update(Fundamentals this, array<Finance> items, float exchangeRate) =>
    this.Items := items
    this.__fx := exchangeRate
    this

// Render paired fields under merged headings on the last chart bar.
method print(Fundamentals this) =>
    if barstate.islast
        int block = 2 + (this.Style.ShowSymbols ? 1 : 0) + (this.Style.ShowChange ? 1 : 0)
        int right = block + 1
        int lastCol = right + block - 1
        if not na(this.__report)
            table.delete(this.__report)
        this.__report := table.new(this.Position.getPosition(), lastCol + 1, 34, bgcolor = this.Style.BackgroundColor, frame_width = 0, border_width = 0)
        table.merge_cells(this.__report, 0, 0, lastCol, 0)
        this.__report.addCell(0, 0, syminfo.ticker + " (" + this.Period + " – " + this.Currency + ")", this.Style.TitleColor, text.align_left, this.Style.TextSize, "", this.Style.HighlightColor, na, true)
        int row = 1
        if this.Style.ShowIdentity
            string identity = na(syminfo.sector) ? "" : syminfo.sector
            if not na(syminfo.industry) and syminfo.industry != identity
                identity += (identity == "" ? "" : " · ") + syminfo.industry
            string full = (na(syminfo.description) ? "" : syminfo.description) + (identity == "" ? "" : " · " + identity)
            if full != ""
                table.merge_cells(this.__report, 0, row, lastCol, row)
                this.__report.addCell(0, row, str.length(full) > 64 ? str.substring(full, 0, 63) + "…" : full, this.Style.LabelColor, text.align_left, this.Style.TextSize, full, this.Style.BackgroundColor)
                row += 1
        array<string> groups = array.from("Company", "Valuation", "Earnings & growth", "Financial position", "Cash & efficiency", "Dividends")
        array<int> counts = array.from(10, 8, 9, 10, 8, 2)
        int idx = 0
        for g = 0 to groups.size() - 1
            table.merge_cells(this.__report, 0, row, lastCol, row)
            this.__report.addCell(0, row, groups.get(g), this.Style.TitleColor, text.align_left, this.Style.TextSize, "", this.Style.HighlightColor, na, true)
            row += 1
            int groupEnd = idx + counts.get(g)
            while idx < groupEnd
                this.Items.get(idx).print(this.__report, 0, row, this.Style, this.__fx)
                idx += 1
                if idx < groupEnd
                    this.Items.get(idx).print(this.__report, right, row, this.Style, this.__fx)
                    idx += 1
                row += 1
    this

// Inputs and report style are initialized once per script run.
var CurrencyType currencyInput = input.enum(CurrencyType.Default, "Currency", group = "Data", tooltip = "Default uses the symbol currency. USD and EUR convert monetary values using the daily exchange rate.")
var FinancialPeriod periodInput = input.enum(FinancialPeriod.FQ, "Period", group = "Data", tooltip = "FQ: quarter. FY: year. FH: half year. TTM: trailing twelve months. For TTM, balance-sheet ratios use FQ; FY-only fields remain FY. Price/earnings, price/sales and price/cash flow use TTM denominators. Each row shows its period on hover.")

var TablePosition tablePos = input.enum(TablePosition.TopCenter, "Position", group = "Report")
var int lsz = input.int(12, "Text size", minval = 8, maxval = 20, group = "Report")
var color labelColor = input.color(lbc1, "Label color", group = "Report")
var color titleColor = input.color(lbc1, "Title color", group = "Report")
var color reportBgColor = input.color(cwht, "Background color", group = "Report")
var color reportHighlightColor = input.color(ccrm, "Highlight color", group = "Report", tooltip = "Background color and transparency of the main title and group headings.")
var bool showIdentity = input.bool(true, "Company identity", group = "Report")
var bool showSymbols = input.bool(true, "Assessment squares", group = "Report")
var bool showChange = input.bool(true, "Period change", group = "Report", tooltip = "△ increased; ▽ decreased; ◻︎ unchanged. Green/red follow the metric's improvement/deterioration rule. Neutral gray indicates an unclassified change; a faded square means no comparable previous observation.")

// Resolve supported periods: balance fields use FQ for TTM; annual-only data stays FY.
var string period = str.tostring(periodInput)
var string balancePeriod = period == "TTM" ? "FQ" : period
var string annualOrQuarter = balancePeriod == "FH" ? "FY" : balancePeriod
var string symbolId = ticker.standard(syminfo.tickerid)
var string curr = currencyInput == CurrencyType.Default ? syminfo.currency : str.tostring(currencyInput)

var Fundamentals ind = na
if na(ind)
    ind := Fundamentals.new(
            Period = period,
            Currency = curr,
            Position = tablePos,
            Style = FinanceStyle.new(
                TextSize = lsz,
                LabelColor = labelColor,
                TitleColor = titleColor,
                BackgroundColor = reportBgColor,
                HighlightColor = reportHighlightColor,
                ShowIdentity = showIdentity,
                ShowSymbols = showSymbols,
                ShowChange = showChange
            )
        ).init()

// Keep requests in the main flow so all observations are collected across chart history.
var float fx = na
fx := curr == syminfo.currency ? 1.0 : request.currency_rate(syminfo.currency, curr, ignore_invalid_currency = true)
// Daily reference for price-based ratios; use a 1D chart for consistent comparisons.
float prevCloseDaily = request.security(symbolId, "1D", close[1], gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, currency = syminfo.currency, ignore_invalid_symbol = true)

[assetTurn, assetTurnPrev, assetTurnAt, assetTurnPrevAt] = getFinancial(symbolId, "ASSET_TURNOVER", balancePeriod, false)
[bookValuePS, bookValuePSPrev, bookValuePSAt, bookValuePSPrevAt] = getFinancial(symbolId, "BOOK_VALUE_PER_SHARE", balancePeriod, true)
[bookTangiblePS, bookTangiblePSPrev, bookTangiblePSAt, bookTangiblePSPrevAt] = getFinancial(symbolId, "BOOK_TANGIBLE_PER_SHARE", balancePeriod, true)
[cash2Debt, cash2DebtPrev, cash2DebtAt, cash2DebtPrevAt] = getFinancial(symbolId, "CASH_TO_DEBT", balancePeriod, false)
[cashEquivalents, cashEquivalentsPrev, cashEquivalentsAt, cashEquivalentsPrevAt] = getFinancial(symbolId, "CASH_N_EQUIVALENTS", balancePeriod, true)
[cashFOActivity, cashFOActivityPrev, cashFOActivityAt, cashFOActivityPrevAt] = getFinancial(symbolId, "CASH_F_OPERATING_ACTIVITIES", period, true)
[currentRatio, currentRatioPrev, currentRatioAt, currentRatioPrevAt] = getFinancial(symbolId, "CURRENT_RATIO", balancePeriod, false)
[cogs2Revenue, cogs2RevenuePrev, cogs2RevenueAt, cogs2RevenuePrevAt] = getFinancial(symbolId, "COGS_TO_REVENUE", balancePeriod, false)
[dilutedShares, dilutedSharesPrev, dilutedSharesAt, dilutedSharesPrevAt] = getFinancial(symbolId, "DILUTED_SHARES_OUTSTANDING", balancePeriod, false)
[debt2Equity, debt2EquityPrev, debt2EquityAt, debt2EquityPrevAt] = getFinancial(symbolId, "DEBT_TO_EQUITY", balancePeriod, false)
[debt2Revenue, debt2RevenuePrev, debt2RevenueAt, debt2RevenuePrevAt] = getFinancial(symbolId, "DEBT_TO_REVENUE", balancePeriod, false)
[debt2EBITDA, debt2EBITDAPrev, debt2EBITDAAt, debt2EBITDAPrevAt] = getFinancial(symbolId, "DEBT_TO_EBITDA", balancePeriod, false)
[netDebt, netDebtPrev, netDebtAt, netDebtPrevAt] = getFinancial(symbolId, "NET_DEBT", balancePeriod, true)
[dividendPayout, dividendPayoutPrev, dividendPayoutAt, dividendPayoutPrevAt] = getFinancial(symbolId, "DIVIDEND_PAYOUT_RATIO", period, false)
[dividendYield, dividendYieldPrev, dividendYieldAt, dividendYieldPrevAt] = getFinancial(symbolId, "DIVIDENDS_YIELD", balancePeriod, false)
[ebitda, ebitdaPrev, ebitdaAt, ebitdaPrevAt] = getFinancial(symbolId, "EBITDA", period, true)
[ebitdaMargin, ebitdaMarginPrev, ebitdaMarginAt, ebitdaMarginPrevAt] = getFinancial(symbolId, "EBITDA_MARGIN", period, false)
[earningsPS, earningsPSPrev, earningsPSAt, earningsPSPrevAt] = getFinancial(symbolId, "EARNINGS_PER_SHARE_BASIC", period, true)
[enterpriseValue, enterpriseValuePrev, enterpriseValueAt, enterpriseValuePrevAt] = getFinancial(symbolId, "ENTERPRISE_VALUE", balancePeriod, true)
[equity2Asset, equity2AssetPrev, equity2AssetAt, equity2AssetPrevAt] = getFinancial(symbolId, "EQUITY_TO_ASSET", balancePeriod, false)
[ent2Ebitda, ent2EbitdaPrev, ent2EbitdaAt, ent2EbitdaPrevAt] = getFinancial(symbolId, "ENTERPRISE_VALUE_EBITDA", balancePeriod, false)
[floatShareOut, floatShareOutPrev, floatShareOutAt, floatShareOutPrevAt] = getFinancial(symbolId, "FLOAT_SHARES_OUTSTANDING", "FY", false)
[freeCashFlow, freeCashFlowPrev, freeCashFlowAt, freeCashFlowPrevAt] = getFinancial(symbolId, "FREE_CASH_FLOW", period, true)
[grahams, grahamsPrev, grahamsAt, grahamsPrevAt] = getFinancial(symbolId, "GRAHAM_NUMBERS", annualOrQuarter, true)
[inventoryTurnover, inventoryTurnoverPrev, inventoryTurnoverAt, inventoryTurnoverPrevAt] = getFinancial(symbolId, "INVENT_TURNOVER", balancePeriod, false)
[netIncome, netIncomePrev, netIncomeAt, netIncomePrevAt] = getFinancial(symbolId, "NET_INCOME", period, true)
[operationMargin, operationMarginPrev, operationMarginAt, operationMarginPrevAt] = getFinancial(symbolId, "OPERATING_MARGIN", balancePeriod, false)
[pegRatio, pegRatioPrev, pegRatioAt, pegRatioPrevAt] = getFinancial(symbolId, "PEG_RATIO", annualOrQuarter, false)
[quickRatio, quickRatioPrev, quickRatioAt, quickRatioPrevAt] = getFinancial(symbolId, "QUICK_RATIO", balancePeriod, false)
[retEquity, retEquityPrev, retEquityAt, retEquityPrevAt] = getFinancial(symbolId, "RETURN_ON_EQUITY", balancePeriod, false)
[rev1YGrowth, rev1YGrowthPrev, rev1YGrowthAt, rev1YGrowthPrevAt] = getFinancial(symbolId, "REVENUE_ONE_YEAR_GROWTH", period, false)
[totalInventory, totalInventoryPrev, totalInventoryAt, totalInventoryPrevAt] = getFinancial(symbolId, "TOTAL_INVENTORY", balancePeriod, true)
[totalRevenue, totalRevenuePrev, totalRevenueAt, totalRevenuePrevAt] = getFinancial(symbolId, "TOTAL_REVENUE", period, true)
[totalRevenueFY, totalRevenueFYPrev, totalRevenueFYAt, totalRevenueFYPrevAt] = getFinancial(symbolId, "TOTAL_REVENUE", "TTM", true)
[totalShareOut, totalShareOutPrev, totalShareOutAt, totalShareOutPrevAt] = getFinancial(symbolId, "TOTAL_SHARES_OUTSTANDING", balancePeriod, false)
[totalDebt, totalDebtPrev, totalDebtAt, totalDebtPrevAt] = getFinancial(symbolId, "TOTAL_DEBT", balancePeriod, true)
[epsTTM, epsTTMPrev, epsTTMAt, epsTTMPrevAt] = getFinancial(symbolId, "EARNINGS_PER_SHARE_BASIC", "TTM", true)
[cashTTM, cashTTMPrev, cashTTMAt, cashTTMPrevAt] = getFinancial(symbolId, "CASH_F_OPERATING_ACTIVITIES", "TTM", true)

// Derived values reuse the requested series without additional data calls.
float eps = earningsPS
float priceEarningR = safeRatio(prevCloseDaily, epsTTM)
float price2Book = safeRatio(prevCloseDaily, bookValuePS)
float marketValue = totalShareOut > 0 ? totalShareOut * prevCloseDaily : na
float workingCapital = currentRatio
float priceSalesRatio = safeRatio(marketValue, totalRevenueFY)
float price2cashflow = safeRatio(prevCloseDaily * dilutedShares, cashTTM)
float totalShareDiff = syminfo.shares_outstanding_total - totalShareOut
float floatShareDiff = syminfo.shares_outstanding_float - floatShareOut
float closeDaily = prevCloseDaily

// Matching observation bars reduce mixed-sample margins; they do not prove fiscal-date alignment.
float netMargin = netIncomeAt == totalRevenueAt ? 100 * safeRatio(netIncome, totalRevenue) : na
float netMarginPrev = netIncomePrevAt == totalRevenuePrevAt ? 100 * safeRatio(netIncomePrev, totalRevenuePrev) : na
float fcfMargin = freeCashFlowAt == totalRevenueAt ? 100 * safeRatio(freeCashFlow, totalRevenue) : na
float fcfMarginPrev = freeCashFlowPrevAt == totalRevenuePrevAt ? 100 * safeRatio(freeCashFlowPrev, totalRevenuePrev) : na

// Field definitions contain the fixed model thresholds, formats and change preferences.
// Edit a field here to adapt its assessment; keep its tooltip and change rule consistent.
var array<Finance> rows = array.new<Finance>()
if barstate.islast
    rows.clear()
    rows.push(Finance.new("Enterprise value", enterpriseValue, enterpriseValuePrev, format.volume, enterpriseValue.toColor(na, na, na, false), "Enterprise value: provider valuation including equity and net debt." + "\nPeriod: " + balancePeriod, true))
    rows.push(Finance.new("Market value", marketValue, float(na), format.volume, marketValue.toColor(na, na, na, false), "Reported total shares multiplied by the previous daily close." + "\nPeriod: " + balancePeriod, true))
    rows.push(Finance.new("Total Shareholders", syminfo.shareholders, float(na), format.volume, syminfo.shareholders.toColor(na, na, na, false), "Latest shareholder count supplied by TradingView." + "\nPeriod: " + "Latest", false))
    rows.push(Finance.new("Employees (latest)", syminfo.employees, float(na), format.volume, syminfo.employees.toColor(na, na, na, false), "Latest employee count supplied by TradingView." + "\nPeriod: " + "Latest", false))
    rows.push(Finance.new("Total shares", totalShareOut, totalShareOutPrev, format.volume, totalShareOut.toColor(na, na, na, false), "Total shares outstanding for the selected reporting period." + "\nPeriod: " + balancePeriod, false))
    rows.push(Finance.new("Float shares", floatShareOut, floatShareOutPrev, format.volume, floatShareOut.toColor(na, na, na, false), "Publicly tradable shares in the latest annual financial series." + "\nPeriod: " + "FY", false))
    rows.push(Finance.new("Total shares (latest)", syminfo.shares_outstanding_total, float(na), format.volume, syminfo.shares_outstanding_total.toColor(na, na, na, true), "Latest total shares outstanding supplied by TradingView." + "\nPeriod: " + "Latest", false))
    rows.push(Finance.new("Float shares (latest)", syminfo.shares_outstanding_float, float(na), format.volume, syminfo.shares_outstanding_float.toColor(na, na, na, false), "Latest float shares supplied by TradingView." + "\nPeriod: " + "Latest", false))
    rows.push(Finance.new("Diluted/Buyback shares", totalShareDiff, float(na), format.volume, totalShareDiff.toColor(na, na, 0, true), "Latest total shares minus reported total shares. The model favors fewer shares. This difference alone does not establish dilution or a buyback; dates and corporate actions can differ." + "\nPeriod: " + balancePeriod, false))
    rows.push(Finance.new("Float shares diff", floatShareDiff, float(na), format.volume, cblu, "Latest float shares minus annual reported float shares. Change in available float is not assigned a favorable or unfavorable score." + "\nPeriod: " + "Latest", false))
    rows.push(Finance.new("Price Book Value", price2Book, float(na), "#.##", price2Book.toColor(na, na, 3, true), "Previous daily close / book value per share. Model reference: 3." + (na(bookValuePS) ? " Book value unavailable." : bookValuePS <= 0 ? " Multiple not meaningful with nonpositive book value." : "") + "\nPeriod: " + balancePeriod, false))
    rows.push(Finance.new("Price Earning Ratio", priceEarningR, float(na), "#.##", priceEarningR.toColor(25, 0, 0, false), "Previous daily close / TTM basic EPS. Model reference: 0 to 25." + (na(epsTTM) ? " EPS unavailable." : epsTTM <= 0 ? " Multiple not meaningful with nonpositive EPS." : "") + "\nPeriod: " + "TTM", false))
    rows.push(Finance.new("Price Earning Growth", pegRatio, pegRatioPrev, "#.##", pegRatio > 0 and pegRatio < 1.00 ? cgrn : cblu, "Provider price/earnings-to-growth ratio. The model favors values between 0 and 1; nonpositive values are unclassified." + "\nPeriod: " + annualOrQuarter, false))
    rows.push(Finance.new("Price Sales Ratio", priceSalesRatio, float(na), "#.##", priceSalesRatio > 0 and priceSalesRatio <= 2 ? cgrn : priceSalesRatio > 2 ? cred : cblu, "Market value divided by trailing twelve-month revenue." + "\nPeriod: " + "TTM", false))
    rows.push(Finance.new("Book tangible pshare", bookTangiblePS, bookTangiblePSPrev, "#.##", bookTangiblePS < 0 ? cred : bookTangiblePS > 0 ? cgrn : cblu, "Tangible book value per share, excluding intangible assets." + "\nPeriod: " + balancePeriod, true))
    rows.push(Finance.new("Price to cash flow", price2cashflow, float(na), "#.##", price2cashflow.toColor(na, na, 0, false), "Previous daily close multiplied by diluted shares / TTM operating cash flow. Green denotes a positive cash-flow basis, not a cheap valuation." + (na(cashTTM) ? " Operating cash flow unavailable." : cashTTM <= 0 ? " Multiple not meaningful with nonpositive operating cash flow." : "") + "\nPeriod: " + "TTM", false))
    rows.push(Finance.new("Graham Number", grahams, grahamsPrev, "#.##", grahams > 0 and closeDaily > 0 ? (grahams - closeDaily).toColor(na, na, 0, false) : cblu, "Graham valuation reference based on earnings and book value. Compared with the previous daily close." + "\nPeriod: " + annualOrQuarter, true))
    rows.push(Finance.new("Enterprise to Ebitda", ent2Ebitda, ent2EbitdaPrev, "#.##", ent2Ebitda <= 0 ? cblu : ent2Ebitda.toColor(na, na, 10, true), "Provider enterprise value / EBITDA. Model reference: 10. Nonpositive multiples are unclassified because numerator and denominator signs need separate interpretation." + "\nPeriod: " + balancePeriod, false))
    rows.push(Finance.new("Earning per share", eps, earningsPSPrev, "#.##", eps.toColor(na, na, 0, false), "Basic earnings per share supplied by the financial provider." + "\nPeriod: " + period, true, 1, false))
    rows.push(Finance.new("Revenue 1Y growth", rev1YGrowth, rev1YGrowthPrev, "#.##", rev1YGrowth > 0 ? cgrn : rev1YGrowth < 0 ? cred : cblu, "Revenue growth versus the corresponding period one year earlier." + "\nPeriod: " + period, false, 1, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Operation Margin", operationMargin, operationMarginPrev, "#.##", operationMargin > 15 ? cgrn : operationMargin < 9 ? cred : cblu, "Operating profit as a percentage of revenue." + "\nPeriod: " + balancePeriod, false, 1, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Return on Equity %", retEquity, retEquityPrev, "#.##", na(bookValuePS) or bookValuePS <= 0 ? cblu : retEquity > 15 ? cgrn : retEquity > 10 ? cblu : cred, "Net income as a percentage of equity. Model references: 10 and 15. Nonpositive or missing book value suppresses assessment; positive book value alone cannot validate average equity." + "\nPeriod: " + balancePeriod, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Ebitda margin %", ebitdaMargin, ebitdaMarginPrev, "#.##", ebitdaMargin.toColor(na, na, 10, false), "EBITDA as a percentage of revenue." + "\nPeriod: " + period, false, 1, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Ebitda", ebitda, ebitdaPrev, format.volume, ebitda.toColor(na, na, 0, false), "Earnings before interest, taxes, depreciation and amortization." + "\nPeriod: " + period, true, 1, false))
    rows.push(Finance.new("Total Revenue", totalRevenue, totalRevenuePrev, format.volume, totalRevenue.toColor(na, na, 0, false), "Total revenue during the reporting period." + "\nPeriod: " + period, true, 1, false))
    rows.push(Finance.new("Net Income", netIncome, netIncomePrev, format.volume, netIncome.toColor(na, na, 0, false), "Net profit or loss during the reporting period." + "\nPeriod: " + period, true, 1, false))
    rows.push(Finance.new("Net margin %", netMargin, netMarginPrev, "#.##", netMargin.toColor(na, na, 0, false), "Net income / revenue × 100. Net profit remaining from each 100 units of sales." + "\nPeriod: " + period, false, 1, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Quick Ratio", quickRatio, quickRatioPrev, "#.##", quickRatio.toColor(na, na, 1, false), "Liquid current assets / current liabilities, excluding inventory under the provider definition. Model reference: 1." + "\nPeriod: " + balancePeriod, false, 1, true))
    rows.push(Finance.new("Current Ratio", currentRatio, currentRatioPrev, "#.##", currentRatio > 1.2 ? cgrn : currentRatio < 1 ? cred : cblu, "Current assets divided by current liabilities." + "\nPeriod: " + balancePeriod, false, 1, true))
    rows.push(Finance.new("Working Capital ratio", workingCapital, currentRatioPrev, "#.##", currentRatio > 1.2 ? cgrn : currentRatio < 1 ? cred : cblu, "Current assets divided by current liabilities; the same underlying ratio as Current Ratio." + "\nPeriod: " + balancePeriod, false, 1, true))
    rows.push(Finance.new("Cash to Debt", cash2Debt, cash2DebtPrev, "#.##", cash2Debt >= 0.50 ? cgrn : cash2Debt < 0.5 ? cred : cblu, "Cash and short-term investments divided by total debt. Model reference: 0.50." + "\nPeriod: " + balancePeriod, false, 1, true))
    rows.push(Finance.new("Debt to Equity", debt2Equity, debt2EquityPrev, "#.##", debt2Equity < 0 ? cred : debt2Equity > 2 ? cred : debt2Equity < 1 ? cgrn : cblu, "Total debt relative to equity." + "\nPeriod: " + balancePeriod, false, -1, true))
    rows.push(Finance.new("Debt to Ebitda", debt2EBITDA, debt2EBITDAPrev, "#.##", debt2EBITDA < 0 ? cred : debt2EBITDA <= 3 ? cgrn : debt2EBITDA <= 5 ? cblu : cred, "Total debt relative to EBITDA." + "\nPeriod: " + balancePeriod, false, -1, true))
    rows.push(Finance.new("Debt to Revenue", debt2Revenue, debt2RevenuePrev, "#.##", debt2Revenue < 0 ? cred : debt2Revenue.toColor(na, na, 0.40, true), "Debt relative to revenue." + "\nPeriod: " + balancePeriod, false, -1, true))
    rows.push(Finance.new("Equity to Asset ratio", equity2Asset, equity2AssetPrev, "#.##", equity2Asset.toColor(na, na, 0, false), "Equity as a proportion of total assets." + "\nPeriod: " + balancePeriod, false, 1, true))
    rows.push(Finance.new("Total Debt", totalDebt, totalDebtPrev, format.volume, totalDebt.toColor(na, na, 0, true), "Total debt reported on the balance sheet." + "\nPeriod: " + balancePeriod, true, -1, false))
    rows.push(Finance.new("Net Debt", netDebt, netDebtPrev, format.volume, netDebt.toColor(na, na, 0, true), "Total debt minus cash and short-term investments. Negative: net cash. Lower values mean a stronger net cash/debt position." + "\nPeriod: " + balancePeriod, true, -1, false))
    rows.push(Finance.new("Operating cash flow", cashFOActivity, cashFOActivityPrev, format.volume, cashFOActivity.toColor(na, na, 0, false), "Cash generated or used by business operations, before capital expenditure." + "\nPeriod: " + period, true, 1, false))
    rows.push(Finance.new("FCF margin %", fcfMargin, fcfMarginPrev, "#.##", fcfMargin.toColor(na, na, 0, false), "Free cash flow / revenue × 100. Cash remaining after capital expenditure per 100 units of sales." + "\nPeriod: " + period, false, 1, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Cash & Equivalents", cashEquivalents, cashEquivalentsPrev, format.volume, cashEquivalents.toColor(na, na, 0, false), "Cash and cash equivalents reported on the balance sheet." + "\nPeriod: " + balancePeriod, true, 1, false))
    rows.push(Finance.new("Free Cash Flow", freeCashFlow, freeCashFlowPrev, format.volume, freeCashFlow.toColor(na, na, 0, false), "Operating cash flow after capital expenditure." + "\nPeriod: " + period, true, 1, false))
    rows.push(Finance.new("Asset Turnover", assetTurn, assetTurnPrev, "#.##", assetTurn.toColor(na, na, 0, false), "Revenue relative to the asset base." + "\nPeriod: " + balancePeriod, false))
    rows.push(Finance.new("Inventory Turnover", inventoryTurnover, inventoryTurnoverPrev, "#.##", inventoryTurnover.toColor(na, na, 0, false), "Inventory turnover during the reporting period." + "\nPeriod: " + balancePeriod, false))
    rows.push(Finance.new("Cogs to Revenue", cogs2Revenue, cogs2RevenuePrev, "#.##", cogs2Revenue < 0 ? cred : cogs2Revenue.toColor(na, na, 0.65, true), "Cost of goods sold as a proportion of revenue." + "\nPeriod: " + balancePeriod, false, -1, true))
    rows.push(Finance.new("Total Inventory", totalInventory, totalInventoryPrev, format.volume, cblu, "Inventory reported on the balance sheet." + "\nPeriod: " + balancePeriod, true))
    rows.push(Finance.new("Dividend Payout %", dividendPayout, dividendPayoutPrev, "#.##", dividendPayout < 0 or dividendPayout > 100 ? cred : dividendPayout > 0 ? cgrn : cblu, "Dividends as a percentage of earnings. Model: 0 neutral; above 0 through 100 favorable; above 100 or negative adverse." + "\nPeriod: " + period, false, ChangeUnit = " pp"))
    rows.push(Finance.new("Dividend Yield %", dividendYield, dividendYieldPrev, "#.##", dividendYield.toColor(na, na, 0, false), "Provider annual dividend yield for the selected series. Green denotes a positive distribution yield, not dividend safety or superior value." + "\nPeriod: " + balancePeriod, false, ChangeUnit = " pp"))

ind.update(rows, fx)
ind.print()
````
