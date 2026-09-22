<!-- tradingview-pine-id: PUB;893b4ed765c44a97a380e2894846b948 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Equalhigh — Fair Value & Upside | SBC v1.1 EN

Source: https://www.tradingview.com/script/EKSezF8R-Equalhigh-Fair-Value-Upside/

## Description

Equalhigh — Fair Value & Upside | SBC v1.1

Equalhigh Fair Value & Upside is a fundamentals-based valuation indicator for stocks. It combines financial data available through TradingView with user-defined valuation assumptions to display fair value, a margin-of-safety buy zone, and an optional future price target.

The FCF component explicitly deducts stock-based compensation (SBC).

This is a valuation tool. It does not predict market turning points or calculate the probability of a price increase.

WHAT THE INDICATOR DISPLAYS

• Orange — Base-case fair value.
• Green — Buy-zone threshold after applying your margin of safety.
• Blue dashed line — Optional nominal target at your selected horizon.

Labels display price levels and potential upside or downside. The dashboard shows the underlying financial inputs, valuation multiples, calculation status, and projected annualized price return.

The green level marks the maximum price within the model’s buy zone. It is not an automatic entry signal.

VALUATION MODELS

Choose between three methods:

• EPS: diluted earnings per share × target P/E.
• FCF after SBC: FCF after deducting SBC, divided by diluted shares, multiplied by the target FCF multiple.
• Hybrid: a weighted combination of both methods.

In Hybrid mode, an EPS weight of 50% gives equal weight to the two components. A weight of 100% uses only EPS; 0% uses only FCF.

Core calculations:

FCF after SBC = FCF before SBC − SBC

FCF after SBC per share = FCF after SBC ÷ diluted shares

Hybrid fair value = EPS weight × EPS valuation + remaining weight × FCF valuation

Buy-zone threshold = fair value × (1 − margin of safety)

Upside/downside (%) = (fair value ÷ chart price − 1) × 100

A negative percentage means the chart price exceeds the model’s fair value.

QUICK START

1. Open the stock’s chart and add the indicator.
2. Select FY or TTM as the financial period.
3. Select the valuation model and, if applicable, the EPS weight.
4. Enter your target P/E and target FCF multiple.
5. Enter SBC for the same period as the FCF and confirm that the amount and period have been checked.
6. Review the retrieved financial data and apply manual overrides where necessary.
7. Optionally enable the projection and enter growth assumptions.

Target multiples default to zero. The relevant valuation component remains suspended until a positive multiple is entered.

DATA AND FINANCIAL PERIODS

The indicator requests diluted EPS, free cash flow, and diluted shares through TradingView’s financial data service. Availability depends on the stock and reporting frequency.

• FY: latest available fiscal-year data.
• TTM: trailing-twelve-month EPS and FCF data.

Selecting TTM does not automatically reconstruct missing financial data from individual reports. If a required field is unavailable, use a verified manual override.

Financial data updates independently of the chart timeframe. Switching from a daily to a weekly chart does not turn annual fundamentals into weekly fundamentals.

STOCK-BASED COMPENSATION

SBC must be entered manually in this version.

Enter the amount in millions of the chart currency. For example, 132 means 132 million.

Use the same reporting period for FCF and SBC. Do not combine annual FCF with six-month SBC.

The confirmation checkbox is required even when SBC is zero. Missing SBC is never silently treated as zero.

The FCF input should be before the SBC deduction applied by this script. Entering an already SBC-adjusted FCF and then entering SBC again would deduct the expense twice.

The EPS component uses the supplied diluted EPS without an additional SBC deduction.

SHARE DATA: FQ, FH AND FY

In TTM mode, select the share-data frequency:

• Auto: uses a positive FQ value first, otherwise FH, otherwise FY.
• FQ: quarterly share data.
• FH: semiannual share data.
• FY: annual share data.

Auto follows an availability order; it does not compare publication dates to identify the newest report.

In FY mode, automatic share retrieval uses FY data regardless of the TTM frequency setting.

The dashboard identifies the selected frequency. Combining TTM cash flows with a quarterly or semiannual average share count is an approximation.

A manual share-count override takes priority over automatic retrieval.

MANUAL OVERRIDES

You can replace:

• Diluted EPS — enter a per-share amount in the chart currency.
• FCF before SBC — enter a total amount in millions of the chart currency.
• Diluted shares — enter the number of shares in millions.

For example, 105.002977 represents 105,002,977 shares.

Record the source and period end in the source field. Manual values remain fixed until you change them and should be reviewed whenever you switch stocks.

Check whether your FCF source deducts lease repayments. The script does not automatically harmonize different FCF definitions.

FUTURE PROJECTION

Enable “Enable projection assumptions” to display the blue target.

Enter:

• Horizon in years.
• Annual diluted EPS growth.
• Annual FCF after SBC per share growth.

Each active valuation component grows at its own rate. Target multiples and Hybrid weights remain constant.

Projected component = current component × (1 + annual growth rate)^years

Annualized price return = [(future target ÷ chart price)^(1 ÷ years) − 1] × 100

Growth rates are entered as percentages: enter 8 for 8%.

FCF growth must already be expressed per share and after SBC. The script does not apply an additional dilution adjustment.

The blue line is a reference level for a future nominal target. It is not a forecast price path or a discounted present value.

Growth inputs are your assumptions. They are not automatically retrieved company guidance or analyst consensus.

WHY “SUSPENDED” MAY APPEAR

The dashboard explains what prevents calculation. Possible causes include:

• Missing or non-positive EPS.
• Missing FCF.
• Missing or non-positive share count.
• Unverified SBC.
• Non-positive FCF after SBC.
• An unconfigured target multiple.

Only components required by the selected model and weight must be valid. In Hybrid mode, the script does not silently redistribute weight when a required component is unavailable.

If shares are unavailable in Auto or FQ mode, try FH for a semiannual reporter, or enter a verified diluted share count manually.

DISPLAY SETTINGS

The dashboard can be positioned in any chart corner.

“Label offset (bars)” moves the labels horizontally relative to the latest bar. Labels are not pinned to the price axis.

Valuation lines begin at the latest bar and extend to the right. The indicator deliberately avoids applying today’s manual inputs retrospectively across the chart.

IMPORTANT LIMITATIONS

• Fair value depends on the selected multiples, weights, growth rates, and financial definitions.
• The indicator does not automatically normalize exceptional items or independently audit company filings.
• It does not separately add net cash or subtract net debt.
• The model may be unsuitable for banks, loss-making businesses, or companies requiring specialized valuation methods.
• Financial-data revisions and manual overrides make this version unsuitable as a historical point-in-time valuation backtest.
• Projected returns exclude dividends, fees, taxes, and currency changes.
• A stock can remain above or below modeled fair value for an extended period.

Use the indicator to make valuation assumptions visible and comparable. Combine its output with company research, financial-statement review, and your own risk-management process.

---

## Source Code

````pine
//@version=6
indicator("Equalhigh — Fair Value & Upside | SBC v1.1 EN", overlay = true, max_lines_count = 6, max_labels_count = 6)

// v1.1: FQ/FH/FY share data, explicit fallback, manual overrides preserved.
// Auto uses availability order; it does not compare publication dates.
// QUICK START
// 1. Select FY (last fiscal year) or TTM (trailing twelve months).
// 2. Enter target multiples: zero means not configured; no invented fair value.
// 3. Enter SBC in millions of the chart currency, for the SAME period as FCF.
//    Confirm the SBC input and period, even when SBC is zero.
// 4. If needed, override provider data with manually normalized values.
// 5. The projection is shown only after enabling growth assumptions.
// Automatic data: TradingView / FactSet; not audited against company filings.
// No dedicated SBC field is documented for request.financial: manual input.
// CURRENT levels only: manual inputs are not applied retrospectively.
// The blue level is a nominal future target, not a discounted present value.
// No probability of upside, dividends, fees, or taxes are included.
// Multiples-based valuation is not suitable for every sector (e.g. banks).

string g1 = "1. Data and valuation model"
string period = input.string("FY", "Financial period", options = ["FY", "TTM"], group = g1)
string model = input.string("Hybrid", "Model", options = ["Hybrid", "EPS", "FCF after SBC"], group = g1)
float weightInput = input.float(50, "EPS weight (%) in hybrid model", minval = 0, maxval = 100, group = g1)
float pe = input.float(0, "Target P/E (0 = not configured)", minval = 0, group = g1)
float pfcf = input.float(0, "Target FCF after SBC multiple (0 = not configured)", minval = 0, group = g1)
float mos = input.float(20, "Margin of safety (%)", minval = 0, maxval = 90, group = g1)

string g2 = "2. SBC required for the FCF component"
float sbcM = input.float(0, "SBC for the period, in millions", minval = 0, group = g2, tooltip = "Use the chart currency. Example: 125 = 125 million. Use the same period as FCF. Enter only SBC to deduct from unadjusted FCF; do not deduct it again if already adjusted.")
bool sbcConfirmed = input.bool(false, "SBC and period verified (including zero)", group = g2)
string sourceNote = input.string("Enter source and period end", "Source / period for manual inputs", group = g2)

string g3 = "3. Optional manual overrides"
bool manualEps = input.bool(false, "Override EPS", group = g3)
float epsInput = input.float(0, "Diluted EPS, chart currency", group = g3)
bool manualFcf = input.bool(false, "Override FCF before SBC", group = g3)
float fcfInputM = input.float(0, "FCF before SBC in millions, chart currency", group = g3)
string sharesFrequency = input.string("Auto", "Share data frequency in TTM mode", options = ["Auto", "FQ", "FH", "FY"], group = g3, tooltip = "Auto: valid FQ, otherwise FH, otherwise FY. This does not compare dates. Select FH for Hermes semiannual reporting. FY mode uses FY shares only. Manual inputs take priority.")
bool manualShares = input.bool(false, "Override share count", group = g3)
float sharesInputM = input.float(0, "Diluted shares in millions", minval = 0, group = g3)

string g4 = "4. Base-case projection"
bool projectionConfirmed = input.bool(false, "Enable projection assumptions", group = g4)
int years = input.int(3, "Horizon (years)", minval = 1, maxval = 10, group = g4)
float epsGrowth = input.float(0, "Annual diluted EPS growth (%)", minval = -99, maxval = 100, group = g4)
float fcfGrowth = input.float(0, "Annual FCF after SBC per share growth (%)", minval = -99, maxval = 100, group = g4, tooltip = "PER-SHARE growth in FCF after SBC. No additional automatic SBC dilution penalty. Valuation multiples remain constant.")

string g5 = "5. Display"
string locationInput = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = g5)
int labelOffset = input.int(8, "Label offset (bars)", minval = 1, maxval = 100, group = g5)

// Currency explicitly aligned for monetary fields; shares are dimensionless.
float epsAuto = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", period, ignore_invalid_symbol = true, currency = syminfo.currency)
float fcfAuto = request.financial(syminfo.tickerid, "FREE_CASH_FLOW", period, ignore_invalid_symbol = true, currency = syminfo.currency)
float sharesFQ = request.financial(syminfo.tickerid, "DILUTED_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
float sharesFH = request.financial(syminfo.tickerid, "DILUTED_SHARES_OUTSTANDING", "FH", ignore_invalid_symbol = true)
float sharesFY = request.financial(syminfo.tickerid, "DILUTED_SHARES_OUTSTANDING", "FY", ignore_invalid_symbol = true)
bool fqOK = not na(sharesFQ) and sharesFQ > 0
bool fhOK = not na(sharesFH) and sharesFH > 0
bool fyOK = not na(sharesFY) and sharesFY > 0
// In FY mode, preserve the annual denominator. In TTM, expose the proxy period.
string sharesPeriod = period == "FY" ? "FY" : sharesFrequency != "Auto" ? sharesFrequency : fqOK ? "FQ" : fhOK ? "FH" : fyOK ? "FY" : "N/A"
float sharesCandidate = sharesPeriod == "FQ" ? sharesFQ : sharesPeriod == "FH" ? sharesFH : sharesPeriod == "FY" ? sharesFY : na
float sharesAuto = not na(sharesCandidate) and sharesCandidate > 0 ? sharesCandidate : na
float eps = manualEps ? epsInput : epsAuto
float fcf = manualFcf ? fcfInputM * 1e6 : fcfAuto
float shares = manualShares ? sharesInputM * 1e6 : sharesAuto
float sbc = sbcConfirmed ? sbcM * 1e6 : na
float netFcf = fcf - sbc
float fcfps = not na(shares) and shares > 0 ? netFcf / shares : na
float w = model == "EPS" ? 1.0 : model == "FCF after SBC" ? 0.0 : weightInput / 100
bool needEps = w > 0
bool needFcf = w < 1
bool epsOK = not na(eps) and eps > 0 and pe > 0
bool fcfOK = sbcConfirmed and not na(fcfps) and fcfps > 0 and pfcf > 0
bool valid = (not needEps or epsOK) and (not needFcf or fcfOK)
float epsValue = epsOK ? eps * pe : na
float fcfValue = fcfOK ? fcfps * pfcf : na
// Conditional terms prevent 0 * na from poisoning a deliberately unused branch.
float fv = valid ? (needEps ? w * epsValue : 0) + (needFcf ? (1 - w) * fcfValue : 0) : na
float buy = fv * (1 - mos / 100)
float future = valid and projectionConfirmed ? (needEps ? w * epsValue * math.pow(1 + epsGrowth / 100, years) : 0) + (needFcf ? (1 - w) * fcfValue * math.pow(1 + fcfGrowth / 100, years) : 0) : na
float upside = close > 0 ? (fv / close - 1) * 100 : na
float futureUpside = close > 0 ? (future / close - 1) * 100 : na
float cagr = close > 0 and future > 0 ? (math.pow(future / close, 1.0 / years) - 1) * 100 : na

string reason = "MODEL ACTIVE - verify source data"
if not valid
    reason := "SUSPENDED: "
    if needEps and pe <= 0
        reason += "target P/E; "
    if needEps and (na(eps) or eps <= 0)
        reason += "EPS missing/non-positive; "
    if needFcf and pfcf <= 0
        reason += "FCF multiple; "
    if needFcf and not sbcConfirmed
        reason += "SBC not verified; "
    if needFcf and na(fcf)
        reason += "FCF missing; "
    if needFcf and (na(shares) or shares <= 0)
        reason += "shares " + sharesPeriod + " missing: select FH or enter manually; "
    if needFcf and not na(netFcf) and netFcf <= 0
        reason += "FCF after SBC non-positive; "

color orange = color.rgb(255, 174, 35)
color green = color.rgb(0, 230, 153)
color blue = color.rgb(50, 175, 255)
color bg = color.rgb(15, 21, 34)
f_num(float v) => na(v) ? "N/A" : str.tostring(v, "#.##")
f_pct(float v) => na(v) ? "N/A" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + " %"
f_price(float v) => na(v) ? "N/A" : str.tostring(v, format.mintick) + " " + syminfo.currency
f_sign(float v) => na(v) ? color.silver : v >= 0 ? green : color.rgb(255, 90, 110)
f_row(table t, int r, string k, string v, color c) =>
    table.cell(t, 0, r, k, text_color = color.silver, bgcolor = bg, text_halign = text.align_left, text_size = size.small)
    table.cell(t, 1, r, v, text_color = c, bgcolor = bg, text_halign = text.align_right, text_size = size.small)

string pos = locationInput == "Top right" ? position.top_right : locationInput == "Top left" ? position.top_left : locationInput == "Bottom left" ? position.bottom_left : position.bottom_right
var table panel = table.new(pos, 2, 19, border_width = 1, border_color = color.rgb(45, 55, 75))
var line lv = na
var line lb = na
var line lf = na
var label tv = na
var label tb = na
var label tf = na

if barstate.islast
    line.delete(lv)
    line.delete(lb)
    line.delete(lf)
    label.delete(tv)
    label.delete(tb)
    label.delete(tf)
    if valid
        lv := line.new(bar_index, fv, bar_index + labelOffset, fv, extend = extend.right, color = orange, width = 2)
        lb := line.new(bar_index, buy, bar_index + labelOffset, buy, extend = extend.right, color = green, width = 2)
        tv := label.new(bar_index + labelOffset, fv, "FAIR VALUE  " + f_price(fv) + " | " + f_pct(upside), style = label.style_label_left, color = orange, textcolor = color.black)
        tb := label.new(bar_index + labelOffset, buy, "BUY ZONE <= " + f_price(buy), style = label.style_label_left, color = green, textcolor = color.black)
        if projectionConfirmed
            // A horizontal reference to the future target, not a price path.
            lf := line.new(bar_index, future, bar_index + labelOffset, future, extend = extend.right, color = blue, width = 2, style = line.style_dashed)
            tf := label.new(bar_index + labelOffset, future, "TARGET " + str.tostring(years) + " YEARS  " + f_price(future) + " | " + f_pct(futureUpside), style = label.style_label_left, color = blue, textcolor = color.black)
    f_row(panel, 0, "EQUALHIGH | FV + SBC", syminfo.ticker + " | " + period, blue)
    f_row(panel, 1, "Status", reason, valid ? green : orange)
    f_row(panel, 2, "Chart price", f_price(close), color.white)
    f_row(panel, 3, "Diluted EPS | " + (manualEps ? "manual" : "TV"), f_num(eps), color.white)
    f_row(panel, 4, "FCF before SBC (M) | " + (manualFcf ? "manual" : "TV"), f_num(fcf / 1e6), color.white)
    f_row(panel, 5, "SBC (M) | manual", sbcConfirmed ? f_num(sbcM) : "VERIFY INPUT", orange)
    f_row(panel, 6, "FCF after SBC (M)", f_num(netFcf / 1e6), color.white)
    f_row(panel, 7, "Diluted shares (M)", (na(shares) ? "N/A" : str.tostring(shares / 1e6, "#.######")) + (manualShares ? " | manual" : " | " + sharesPeriod), color.white)
    f_row(panel, 8, "FCF after SBC / share", f_num(fcfps), color.white)
    f_row(panel, 9, "P/E / FCF multiple", f_num(pe) + " / " + f_num(pfcf), color.silver)
    f_row(panel, 10, "Base-case fair value", f_price(fv), orange)
    f_row(panel, 11, "Upside / downside to FV", f_pct(upside), f_sign(upside))
    f_row(panel, 12, "Buy zone | MoS " + f_num(mos) + "%", f_price(buy), green)
    f_row(panel, 13, "Nominal target: " + str.tostring(years) + " years", f_price(future), blue)
    f_row(panel, 14, "Upside / downside at horizon", f_pct(futureUpside), f_sign(futureUpside))
    f_row(panel, 15, "Annualized price return", f_pct(cagr), f_sign(cagr))
    f_row(panel, 16, "Manual source / period", sourceNote, color.silver)
    f_row(panel, 17, "Share count basis", manualShares ? "Manual override active" : period == "TTM" ? "Basis " + sharesPeriod + " / TTM flows: approximation" : "Annual FY basis", color.silver)
    f_row(panel, 18, "Interpretation", "Excludes dividends | not a probability", color.silver)

// No historical valuation series or backtest alerts: manual SBC is a snapshot.
// Official fields: https://www.tradingview.com/support/solutions/43000564727-what-financial-data-is-available-in-pine/
````
