<!-- tradingview-pine-id: PUB;d3d88038b2a14fe08cb5893dd8463041 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# COT TRADERS NET (COCOSTA)

Source: https://www.tradingview.com/script/SFevrTNB-COT-TRADERS-NET-COCOSTA/

## Description

COT TRADERS NET (COCOSTA) plots the net number of reportable traders — Long traders minus Short traders — from the CFTC's Commitment of Traders (Financial) report, futures-only.

Instead of tracking position size (contracts/lots), this indicator tracks how many traders are on each side of the market. A rising net count means more distinct traders are building long exposure than short, independent of how large any single trader's position is — a different lens on crowd positioning than the standard net-contracts view.

Traders category (switchable):

Dealer
Asset Manager
Leveraged Funds
Other Reportable
Total Reportable
How it works

Data source: CFTC Commitment of Traders, Financial report, futures-only (options excluded).
For the selected category, the script requests the number of Long traders and the number of Short traders, then plots Net = Long traders − Short traders as a step line.
The zero line marks the balance point between long-leaning and short-leaning trader counts.
Line color flips between the "Net ≥ 0" and "Net < 0" colors (both configurable) so directional shifts are visible at a glance.
The CFTC code is auto-detected from the chart's symbol by default; you can override it by symbol or enter a custom CFTC code.
Inputs

Traders category — pick which group's net trader count to display.
CFTC source — Symbol (auto) or Custom CFTC code.
Symbol / CFTC code override fields.
Net ≥ 0 / Net < 0 colors.
Notes

COT data updates weekly (Friday release, as-of Tuesday), so this indicator is best used on daily and higher timeframes.
Requires the CFTC to publish a Financial-category report for the underlying instrument; not all symbols have Financial COT data available.
Built on top of TradingView's official LibraryCOT.[pine][/pine]

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView (base script) / customized for Traders Net (number of traders), Futures-only

//@version=6
indicator("COT TRADERS NET (COCOSTA)", "COT NET (COCOSTA)", format = format.volume)

// Simplified from TradingView's official "Commitment of Traders: Financial Metrics" script.
// Shows only the Net NUMBER OF TRADERS (Long traders - Short traders) for a selected trader
// category, futures-only. Position size (lots) is intentionally not shown.
// The trader category is switchable: Dealer, Asset Manager, Leveraged Funds, Other Reportable,
// Total Reportable.

import TradingView/LibraryCOT/6 as cot

//#region ———————————————————— Constants and inputs

// Trader category labels (dropdown) mapped to the underlying "Traders" COT metric names.
string CAT_DEALER      = "Dealer"
string CAT_ASSET_MGR   = "Asset Manager"
string CAT_LEV_FUNDS   = "Leveraged Funds"
string CAT_OTHER_REPT  = "Other Reportable"
string CAT_TOTAL_REPT  = "Total Reportable"

// CFTC code selection
string US01 = "Symbol"
string US02 = "Custom CFTC code"

string TT_CATEGORY = "Selects the trader category. Net = Number of Long traders − Number of Short traders, futures-only."
string TT_SYMBOL = (
      "If the selected 'CFTC source' option is 'Symbol', this field specifies the futures instrument for which to "
      + "request COT data. If not empty, the indicator retrieves data using the CFTC code for the instrument referenced "
      + "by the specified symbol. Otherwise, it uses the code for the instrument referenced by the chart's symbol."
)
string TT_OVERRIDE = (
      "If the selected 'CFTC source' option is 'Custom CFTC code' and this field is not empty, the indicator retrieves "
      + "COT data using the specified CFTC code. If the field is empty, it retrieves data using the CFTC code "
      + "for the instrument referenced by the chart's symbol."
)

// Inputs
string categoryInput     = input.string(CAT_LEV_FUNDS, "Traders category", options = [CAT_DEALER, CAT_ASSET_MGR, CAT_LEV_FUNDS, CAT_OTHER_REPT, CAT_TOTAL_REPT], tooltip = TT_CATEGORY)
bool   useSymbolInput    = input.string(US01, "CFTC source", options = [US01, US02]) == US01
string userCFTCSymInput  = input.symbol("", "Symbol", tooltip = TT_SYMBOL, active = useSymbolInput)
string userCFTCCodeInput = input.string("", "CFTC code", tooltip = TT_OVERRIDE, active = not useSymbolInput)
color  netUpColor        = input.color(color.new(color.teal, 0), "Net ≥ 0 color", inline = "colors")
color  netDownColor      = input.color(color.new(color.red, 0), "Net < 0 color", inline = "colors")
//#endregion

//#region ———————————————————— Calculations

// @variable A string containing the CFTC code for the COT data requests.
var string cftcCode = switch
    useSymbolInput          => cot.getCFTCCode(userCFTCSymInput)
    userCFTCCodeInput != "" => str.upper(userCFTCCodeInput)
    => cot.getCFTCCode("")

// @variable The underlying "Traders" (number of traders) COT metric name for the selected category.
var string metricName = switch categoryInput
    CAT_DEALER     => "Traders Dealer"
    CAT_ASSET_MGR  => "Traders Asset Manager"
    CAT_LEV_FUNDS  => "Traders Leveraged Funds"
    CAT_OTHER_REPT => "Traders Other Reportable"
    CAT_TOTAL_REPT => "Traders Total Reportable"

// @variable The requested number of Long traders, futures-only.
float longTraders = cot.requestCommitmentOfTraders("Financial", cftcCode, false, metricName, "Long", "All")
// @variable The requested number of Short traders, futures-only.
float shortTraders = cot.requestCommitmentOfTraders("Financial", cftcCode, false, metricName, "Short", "All")

// @variable Net number of traders (Long traders − Short traders), futures-only.
float netTraders = longTraders - shortTraders
//#endregion

//#region ———————————————————— Display

// Plot `netTraders` as a step line with diamonds, colored by sign.
plot(netTraders, "Traders Net", style = plot.style_stepline_diamond, color = netTraders >= 0 ? netUpColor : netDownColor)
hline(0, "Zero", color = color.new(color.gray, 50))

// @variable References a `table` instance that displays symbol and category information in the bottom-right corner.
var table symbolDisplay = table.new(position.bottom_right, 1, 1)
// Populate the `symbolDisplay` table on the first bar.
if barstate.isfirst
    color  TEXT_COLOR = color.white
    color  BG_COLOR   = color.new(color.blue, 50)
    int    pos        = str.pos(userCFTCSymInput, ":")
    string ticker     = str.substring(userCFTCSymInput, pos + 1)
    string symbol     = userCFTCSymInput != "" and useSymbolInput ? ticker : syminfo.ticker
    string tickerID   = cot.COTTickerid("Financial", cftcCode, false, metricName, "Long", "All") + " − " + cot.COTTickerid("Financial", cftcCode, false, metricName, "Short", "All")
    string txt = switch
        useSymbolInput or userCFTCCodeInput == "" => str.format(
            "COT Traders Net (Futures) — {0}\nSymbol: {1}\nCOT ticker IDs: {2}", categoryInput, symbol, tickerID
        )
        => str.format("COT Traders Net (Futures) — {0}\nCFTC code: {1}\nCOT ticker IDs: {2}", categoryInput, cftcCode, tickerID)
    table.cell(symbolDisplay, 0, 0, txt, text_halign = text.align_left, text_color = TEXT_COLOR, bgcolor = BG_COLOR)
//#endregion
````
