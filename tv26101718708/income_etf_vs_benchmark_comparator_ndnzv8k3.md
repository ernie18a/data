# Income ETF vs Benchmark Comparator

- url: https://www.tradingview.com/script/NDNZV8K3-Income-ETF-vs-Benchmark-Comparator/
- type: indicator
- pine_id: PUB;9d03fcb59d9e47599c02be460f973edc
- version: 2.0

## Description

Compare the performance of income/covered call ETFs (JEPI, JEPQ, QYLD, QQQI, XYLD, SPYI) against their benchmark ETFs (SPY, QQQ) to determine if income strategies outperform buy-and-hold.

Features:
[list]
[*]Total Returns: Year-by-year and period total returns (price appreciation + dividends, non-reinvested)
[*]Dividend Yields: Annual dividend percentages for both income and benchmark ETFs
[*]NAV Decay: Measures underperformance of income ETF vs benchmark
[*]Dividend Extraction Analysis: Shows hypothetical benchmark returns if you extracted the same dividends by selling shares
[*]Sharpe Ratios: Risk-adjusted returns for performance comparison
[*]Predefined Pairs: Quick selection of common comparisons or custom symbol input
[*]Customizable Display: Adjustable table position and font size
[/list]

How to Use:
[list]
[*]Select a comparison pair (e.g., "JEPI vs SPY") or choose "Custom" to compare any two symbols
[*]Also put the ticker in analysis in the chart and 1D time frame
[*]Review yearly performance, dividends, and risk metrics in the table
[/list]

Ideal for investors evaluating whether income ETF strategies justify their NAV decay compared to traditional index investing.

## Source Code

````pine
//@version=6
indicator("Income ETF vs Benchmark Comparator - DRIP & Equal Cash Flow", overlay = false)

// ============================================================================
// INPUT GROUPS
// ============================================================================

string GROUP_COMPARISON = "Comparison"
string GROUP_DISPLAY    = "Table and Display"
string GROUP_TAX        = "Potential Tax Assessment"

// ============================================================================
// COMPARISON INPUTS
// ============================================================================

comparisonMode = input.string(
     "JEPI vs SPY",
     "Comparison Pair",
     options = [
         "JEPI vs SPY",
         "JEPQ vs QQQ",
         "QYLD vs QQQ",
         "QQQI vs QQQ",
         "XYLD vs SPY",
         "SPYI vs SPY",
         "RYLD vs IWM",
         "DIVO vs SPY",
         "QDTE vs QQQ",
         "XDTE vs SPY",
         "RDTE vs IWM",
         "AMDY vs AMD",
         "TSLY vs TSLA",
         "AMDW vs AMD",
         "TSLW vs TSLA",
         "YBTC vs IBIT",
         "BTCI vs IBIT",
         "Custom"
     ],
     group = GROUP_COMPARISON
)

customIncomeSymbol = input.symbol(
     "AMEX:JEPI",
     "Custom Income ETF",
     group = GROUP_COMPARISON
)

customBenchmarkSymbol = input.symbol(
     "AMEX:SPY",
     "Custom Benchmark",
     group = GROUP_COMPARISON
)

initialCapital = input.float(
     10000.0,
     "Starting Capital",
     minval = 100.0,
     step = 100.0,
     tooltip = "Both strategies begin with the same dollar investment. Fractional shares are assumed.",
     group = GROUP_COMPARISON
)

// ============================================================================
// DISPLAY INPUTS
// ============================================================================

showYearlyReturns = input.bool(
     true,
     "Show Completed Calendar Years",
     group = GROUP_DISPLAY
)

maxYearsToShow = input.int(
     20,
     "Maximum Years to Display",
     minval = 1,
     maxval = 35,
     group = GROUP_DISPLAY
)

showColumnExplanations = input.bool(
     true,
     "Show Column Explanations",
     tooltip = "Adds a short explanation row underneath the column headings.",
     group = GROUP_DISPLAY
)

tablePosition = input.string(
     "Middle Center",
     "Table Position",
     options = [
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group = GROUP_DISPLAY
)

fontSize = input.string(
     "Small",
     "Font Size",
     options = [
         "Tiny",
         "Small",
         "Normal",
         "Large",
         "Huge"
     ],
     group = GROUP_DISPLAY
)

// ============================================================================
// TAX INPUTS
// ============================================================================

showTaxAssessment = input.bool(
     true,
     "Show Potential Tax Edge",
     tooltip = "Shows a general U.S. federal tax assessment relative to owning the benchmark. Disable this to remove the tax column.",
     group = GROUP_TAX
)

accountType = input.string(
     "Taxable Account",
     "Account Type",
     options = [
         "Taxable Account",
         "Traditional IRA / 401(k)",
         "Roth IRA"
     ],
     tooltip = "Tax differences generally matter most in a taxable account.",
     group = GROUP_TAX
)

// Dividend-event processing is designed for daily bars.
if not timeframe.isdaily or timeframe.multiplier != 1
    runtime.error("This indicator must be used on a 1D chart.")

// ============================================================================
// SYMBOL SELECTION
// ============================================================================

var string incomeSymbol = na
var string benchmarkSymbol = na

if comparisonMode == "JEPI vs SPY"
    incomeSymbol := "AMEX:JEPI"
    benchmarkSymbol := "AMEX:SPY"

else if comparisonMode == "JEPQ vs QQQ"
    incomeSymbol := "NASDAQ:JEPQ"
    benchmarkSymbol := "NASDAQ:QQQ"

else if comparisonMode == "QYLD vs QQQ"
    incomeSymbol := "NASDAQ:QYLD"
    benchmarkSymbol := "NASDAQ:QQQ"

else if comparisonMode == "QQQI vs QQQ"
    incomeSymbol := "NASDAQ:QQQI"
    benchmarkSymbol := "NASDAQ:QQQ"

else if comparisonMode == "XYLD vs SPY"
    incomeSymbol := "AMEX:XYLD"
    benchmarkSymbol := "AMEX:SPY"

else if comparisonMode == "SPYI vs SPY"
    incomeSymbol := "CBOE:SPYI"
    benchmarkSymbol := "AMEX:SPY"

else if comparisonMode == "RYLD vs IWM"
    incomeSymbol := "AMEX:RYLD"
    benchmarkSymbol := "AMEX:IWM"

else if comparisonMode == "DIVO vs SPY"
    incomeSymbol := "AMEX:DIVO"
    benchmarkSymbol := "AMEX:SPY"

else if comparisonMode == "QDTE vs QQQ"
    incomeSymbol := "CBOE:QDTE"
    benchmarkSymbol := "NASDAQ:QQQ"

else if comparisonMode == "XDTE vs SPY"
    incomeSymbol := "CBOE:XDTE"
    benchmarkSymbol := "AMEX:SPY"

else if comparisonMode == "RDTE vs IWM"
    incomeSymbol := "CBOE:RDTE"
    benchmarkSymbol := "AMEX:IWM"

else if comparisonMode == "AMDY vs AMD"
    incomeSymbol := "AMEX:AMDY"
    benchmarkSymbol := "NASDAQ:AMD"

else if comparisonMode == "TSLY vs TSLA"
    incomeSymbol := "AMEX:TSLY"
    benchmarkSymbol := "NASDAQ:TSLA"

else if comparisonMode == "AMDW vs AMD"
    incomeSymbol := "CBOE:AMDW"
    benchmarkSymbol := "NASDAQ:AMD"

else if comparisonMode == "TSLW vs TSLA"
    incomeSymbol := "CBOE:TSLW"
    benchmarkSymbol := "NASDAQ:TSLA"

else if comparisonMode == "YBTC vs IBIT"
    incomeSymbol := "CBOE:YBTC"
    benchmarkSymbol := "NASDAQ:IBIT"

else if comparisonMode == "BTCI vs IBIT"
    incomeSymbol := "CBOE:BTCI"
    benchmarkSymbol := "NASDAQ:IBIT"

else
    incomeSymbol := customIncomeSymbol
    benchmarkSymbol := customBenchmarkSymbol

// ============================================================================
// POTENTIAL TAX ASSESSMENT
// ============================================================================
//
// taxRank:
//  1 = Potential advantage
//  0 = Mixed, neutral or unknown
// -1 = Potential disadvantage
//
// This is only a qualitative assessment. Pine cannot access:
// - The investor's tax bracket.
// - State and local taxes.
// - Cost basis and tax lots.
// - Final Form 1099-DIV classifications.
// - The actual percentage of ROC, ordinary income or qualified dividends.

string taxVerdict = ""
string taxReason = ""
int taxRank = 0

if accountType == "Traditional IRA / 401(k)"
    taxVerdict := "LOW CURRENT RELEVANCE"
    taxReason := "Current ETF distribution character is generally deferred inside the account. Future account withdrawals may be taxable."
    taxRank := 0

else if accountType == "Roth IRA"
    taxVerdict := "LOW CURRENT RELEVANCE"
    taxReason := "Distribution character generally does not create current federal tax inside a qualified Roth account."
    taxRank := 0

else
    if comparisonMode == "JEPI vs SPY" or comparisonMode == "JEPQ vs QQQ"
        taxVerdict := "POTENTIAL DISADVANTAGE"
        taxReason := "Frequent taxable distributions may provide less control over realization than selling selected benchmark shares."
        taxRank := -1

    else if comparisonMode == "QYLD vs QQQ" or comparisonMode == "XYLD vs SPY" or comparisonMode == "RYLD vs IWM"
        taxVerdict := "MIXED / DEPENDS"
        taxReason := "Return of capital may defer tax but reduces cost basis. Other portions may be taxable in the current year."
        taxRank := 0

    else if comparisonMode == "QQQI vs QQQ" or comparisonMode == "SPYI vs SPY"
        taxVerdict := "POTENTIAL ADVANTAGE"
        taxReason := "Section 1256 index options and tax-loss harvesting may improve tax efficiency, but the final result varies."
        taxRank := 1

    else if comparisonMode == "DIVO vs SPY"
        taxVerdict := "MIXED / DEPENDS"
        taxReason := "Distributions may combine dividends, option income, capital gains and return of capital."
        taxRank := 0

    else if comparisonMode == "QDTE vs QQQ" or comparisonMode == "XDTE vs SPY" or comparisonMode == "RDTE vs IWM"
        taxVerdict := "MIXED / DEFERRAL"
        taxReason := "Return of capital may defer current tax, but it reduces cost basis and is not necessarily an economic gain."
        taxRank := 0

    else if comparisonMode == "AMDY vs AMD" or comparisonMode == "TSLY vs TSLA"
        taxVerdict := "POTENTIAL DISADVANTAGE"
        taxReason := "Frequent distributions may create current income or basis reductions. Direct stock ownership provides more realization control."
        taxRank := -1

    else if comparisonMode == "AMDW vs AMD" or comparisonMode == "TSLW vs TSLA"
        taxVerdict := "MIXED / DEPENDS"
        taxReason := "Weekly distributions may include return of capital. Deferral may help initially, but cost basis can decline quickly."
        taxRank := 0

    else if comparisonMode == "YBTC vs IBIT"
        taxVerdict := "MIXED / DEPENDS"
        taxReason := "Return of capital may defer tax, while direct IBIT ownership provides more control over when gains are realized."
        taxRank := 0

    else if comparisonMode == "BTCI vs IBIT"
        taxVerdict := "POTENTIAL ADVANTAGE"
        taxReason := "Tax-managed option techniques may help, but direct IBIT ownership still offers greater control over realization timing."
        taxRank := 1

    else
        taxVerdict := "UNKNOWN"
        taxReason := "Review the custom fund's final Form 1099-DIV, tax supplement, prospectus and distribution history."
        taxRank := 0

color taxAssessmentColor = taxRank > 0 ? color.new(color.green, 60) : taxRank < 0 ? color.new(color.red, 60) : color.new(color.orange, 65)

// ============================================================================
// DATA
// ============================================================================

incomeClose = request.security(
     incomeSymbol,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

benchmarkClose = request.security(
     benchmarkSymbol,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

incomeDividends = request.dividends(
     incomeSymbol,
     dividends.gross,
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off
)

benchmarkDividends = request.dividends(
     benchmarkSymbol,
     dividends.gross,
     gaps = barmerge.gaps_on,
     lookahead = barmerge.lookahead_off
)

bool dataValid = not na(incomeClose) and not na(benchmarkClose) and incomeClose > 0 and benchmarkClose > 0

bool incomeDividendEvent = not na(incomeDividends) and incomeDividends != 0

bool benchmarkDividendEvent = not na(benchmarkDividends) and benchmarkDividends != 0

// ============================================================================
// FUNCTIONS
// ============================================================================

// Uses available benchmark dividend cash first.
// Benchmark shares are sold only for the remaining withdrawal.
fApplyWithdrawal(float shares, float cash, float withdrawal, float price) =>
    float cashUsed = math.min(cash, withdrawal)
    float remainingCash = cash - cashUsed
    float saleNeeded = withdrawal - cashUsed
    float sharesToSell = price > 0 ? math.min(shares, saleNeeded / price) : 0.0
    float remainingShares = math.max(shares - sharesToSell, 0.0)
    [remainingShares, remainingCash, sharesToSell]

// Total return when payouts are kept as cash.
fCashTotalReturn(float shares, float price, float distributedCash, float startingCapital) =>
    float endingValue = shares * price + distributedCash
    (endingValue / startingCapital - 1.0) * 100.0

// Total return when every distribution is reinvested.
fDripReturn(float shares, float price, float startingCapital) =>
    float endingValue = shares * price
    (endingValue / startingCapital - 1.0) * 100.0

// Portfolio value still invested after payouts have been removed.
fCapitalLeftReturn(float shares, float price, float remainingCash, float startingCapital) =>
    float capitalLeft = shares * price + remainingCash
    (capitalLeft / startingCapital - 1.0) * 100.0

fPct(float value) =>
    not na(value) ? str.tostring(value, "#.##") + "%" : "-"

fValueColor(float value) =>
    na(value) ? color.gray : value >= 0 ? color.green : color.red

// ============================================================================
// COMPLETED-YEAR ARRAYS
// ============================================================================

var array<int> years = array.new<int>()

var array<float> incomeCashReturns = array.new<float>()
var array<float> benchmarkCashReturns = array.new<float>()

var array<float> incomeDripReturns = array.new<float>()
var array<float> benchmarkDripReturns = array.new<float>()
var array<float> dripEdges = array.new<float>()

var array<float> incomeCashYields = array.new<float>()

var array<float> incomeCapitalReturns = array.new<float>()
var array<float> benchmarkCapitalReturns = array.new<float>()
var array<float> sellEdges = array.new<float>()

var array<float> benchmarkSharesSoldPcts = array.new<float>()

// ============================================================================
// CURRENT CALENDAR-YEAR STATE
// ============================================================================

var int currentYear = na
var bool currentYearIsFull = false

// Income ETF with payouts taken as cash.
var float yearIncomeCashShares = na
var float yearIncomeCashPaid = 0.0

// Benchmark with dividends taken as cash.
var float yearBenchmarkCashShares = na
var float yearBenchmarkCashPaid = 0.0

// DRIP portfolios.
var float yearIncomeDripShares = na
var float yearBenchmarkDripShares = na

// Benchmark delivering the income ETF's cash flow.
var float yearBenchmarkExtractShares = na
var float yearBenchmarkExtractCash = 0.0
var float yearBenchmarkSharesSold = 0.0

// ============================================================================
// ENTIRE LOADED-PERIOD STATE
// ============================================================================

// Income ETF with payouts taken as cash.
var float periodIncomeCashShares = na
var float periodIncomeCashPaid = 0.0

// Benchmark with dividends taken as cash.
var float periodBenchmarkCashShares = na
var float periodBenchmarkCashPaid = 0.0

// DRIP portfolios.
var float periodIncomeDripShares = na
var float periodBenchmarkDripShares = na

// Benchmark delivering the income ETF's cash flow.
var float periodBenchmarkExtractShares = na
var float periodBenchmarkExtractCash = 0.0
var float periodBenchmarkSharesSold = 0.0

// ============================================================================
// PORTFOLIO SIMULATION
// ============================================================================

if dataValid
    bool firstValidPeriodBar = false

    // Initialize the loaded-period portfolios.
    if na(periodIncomeCashShares)
        periodIncomeCashShares := initialCapital / incomeClose
        periodBenchmarkCashShares := initialCapital / benchmarkClose

        periodIncomeDripShares := initialCapital / incomeClose
        periodBenchmarkDripShares := initialCapital / benchmarkClose

        periodBenchmarkExtractShares := initialCapital / benchmarkClose

        firstValidPeriodBar := true

    int barYear = year(time)

    // Initialize the first visible calendar year.
    if na(currentYear)
        currentYear := barYear

        yearIncomeCashShares := initialCapital / incomeClose
        yearBenchmarkCashShares := initialCapital / benchmarkClose

        yearIncomeDripShares := initialCapital / incomeClose
        yearBenchmarkDripShares := initialCapital / benchmarkClose

        yearBenchmarkExtractShares := initialCapital / benchmarkClose

        // The first visible year might start in the middle of the year.
        currentYearIsFull := false

    // Finish the previous calendar year.
    if barYear != currentYear
        if currentYearIsFull and not na(incomeClose[1]) and not na(benchmarkClose[1])
            float completedIncomeCashReturn = fCashTotalReturn(
                 yearIncomeCashShares,
                 incomeClose[1],
                 yearIncomeCashPaid,
                 initialCapital
            )

            float completedBenchmarkCashReturn = fCashTotalReturn(
                 yearBenchmarkCashShares,
                 benchmarkClose[1],
                 yearBenchmarkCashPaid,
                 initialCapital
            )

            float completedIncomeDripReturn = fDripReturn(
                 yearIncomeDripShares,
                 incomeClose[1],
                 initialCapital
            )

            float completedBenchmarkDripReturn = fDripReturn(
                 yearBenchmarkDripShares,
                 benchmarkClose[1],
                 initialCapital
            )

            float completedDripEdge = completedIncomeDripReturn - completedBenchmarkDripReturn

            float completedCashYield = yearIncomeCashPaid / initialCapital * 100.0

            float completedIncomeCapital = fCapitalLeftReturn(
                 yearIncomeCashShares,
                 incomeClose[1],
                 0.0,
                 initialCapital
            )

            float completedBenchmarkCapital = fCapitalLeftReturn(
                 yearBenchmarkExtractShares,
                 benchmarkClose[1],
                 yearBenchmarkExtractCash,
                 initialCapital
            )

            float completedSellEdge = completedBenchmarkCapital - completedIncomeCapital

            float completedSharesSoldPct = yearBenchmarkCashShares > 0 ? yearBenchmarkSharesSold / yearBenchmarkCashShares * 100.0 : na

            array.push(years, currentYear)

            array.push(incomeCashReturns, completedIncomeCashReturn)
            array.push(benchmarkCashReturns, completedBenchmarkCashReturn)

            array.push(incomeDripReturns, completedIncomeDripReturn)
            array.push(benchmarkDripReturns, completedBenchmarkDripReturn)
            array.push(dripEdges, completedDripEdge)

            array.push(incomeCashYields, completedCashYield)

            array.push(incomeCapitalReturns, completedIncomeCapital)
            array.push(benchmarkCapitalReturns, completedBenchmarkCapital)
            array.push(sellEdges, completedSellEdge)

            array.push(benchmarkSharesSoldPcts, completedSharesSoldPct)

        // Start the new year using the preceding year's final close.
        currentYear := barYear
        currentYearIsFull := true

        float incomeStartPrice = not na(incomeClose[1]) ? incomeClose[1] : incomeClose
        float benchmarkStartPrice = not na(benchmarkClose[1]) ? benchmarkClose[1] : benchmarkClose

        yearIncomeCashShares := initialCapital / incomeStartPrice
        yearBenchmarkCashShares := initialCapital / benchmarkStartPrice

        yearIncomeDripShares := initialCapital / incomeStartPrice
        yearBenchmarkDripShares := initialCapital / benchmarkStartPrice

        yearBenchmarkExtractShares := initialCapital / benchmarkStartPrice

        yearIncomeCashPaid := 0.0
        yearBenchmarkCashPaid := 0.0

        yearBenchmarkExtractCash := 0.0
        yearBenchmarkSharesSold := 0.0

    // Do not process a distribution on the loaded period's initial bar,
    // because the simulation starts at that bar's closing price.
    if not firstValidPeriodBar

        // --------------------------------------------------------------------
        // BENCHMARK DIVIDEND
        // --------------------------------------------------------------------

        if benchmarkDividendEvent
            float yearBenchmarkDistribution = yearBenchmarkCashShares * benchmarkDividends

            yearBenchmarkCashPaid += yearBenchmarkDistribution

            yearBenchmarkDripShares += (
                 yearBenchmarkDripShares *
                 benchmarkDividends
            ) / benchmarkClose

            yearBenchmarkExtractCash += (
                 yearBenchmarkExtractShares *
                 benchmarkDividends
            )

            float periodBenchmarkDistribution = periodBenchmarkCashShares * benchmarkDividends

            periodBenchmarkCashPaid += periodBenchmarkDistribution

            periodBenchmarkDripShares += (
                 periodBenchmarkDripShares *
                 benchmarkDividends
            ) / benchmarkClose

            periodBenchmarkExtractCash += (
                 periodBenchmarkExtractShares *
                 benchmarkDividends
            )

        // --------------------------------------------------------------------
        // INCOME ETF DISTRIBUTION
        // --------------------------------------------------------------------

        if incomeDividendEvent
            // Same-capital income ETF portfolio's dollar payout.
            float yearRequiredWithdrawal = yearIncomeCashShares * incomeDividends

            yearIncomeCashPaid += yearRequiredWithdrawal

            // Reinvest the income ETF distribution.
            yearIncomeDripShares += (
                 yearIncomeDripShares *
                 incomeDividends
            ) / incomeClose

            // Correct single-statement tuple declaration.
            [newYearShares, newYearCash, yearSharesSoldNow] = fApplyWithdrawal(yearBenchmarkExtractShares, yearBenchmarkExtractCash, yearRequiredWithdrawal, benchmarkClose)

            yearBenchmarkExtractShares := newYearShares
            yearBenchmarkExtractCash := newYearCash
            yearBenchmarkSharesSold += yearSharesSoldNow

            float periodRequiredWithdrawal = periodIncomeCashShares * incomeDividends

            periodIncomeCashPaid += periodRequiredWithdrawal

            periodIncomeDripShares += (
                 periodIncomeDripShares *
                 incomeDividends
            ) / incomeClose

            // Correct single-statement tuple declaration.
            [newPeriodShares, newPeriodCash, periodSharesSoldNow] = fApplyWithdrawal(periodBenchmarkExtractShares, periodBenchmarkExtractCash, periodRequiredWithdrawal, benchmarkClose)

            periodBenchmarkExtractShares := newPeriodShares
            periodBenchmarkExtractCash := newPeriodCash
            periodBenchmarkSharesSold += periodSharesSoldNow

// ============================================================================
// CURRENT-YEAR RESULTS
// ============================================================================

float ytdIncomeCashReturn = na
float ytdBenchmarkCashReturn = na

float ytdIncomeDripReturn = na
float ytdBenchmarkDripReturn = na
float ytdDripEdge = na

float ytdIncomeCashYield = na

float ytdIncomeCapital = na
float ytdBenchmarkCapital = na
float ytdSellEdge = na

float ytdSharesSoldPct = na

if dataValid and not na(yearIncomeCashShares)
    ytdIncomeCashReturn := fCashTotalReturn(
         yearIncomeCashShares,
         incomeClose,
         yearIncomeCashPaid,
         initialCapital
    )

    ytdBenchmarkCashReturn := fCashTotalReturn(
         yearBenchmarkCashShares,
         benchmarkClose,
         yearBenchmarkCashPaid,
         initialCapital
    )

    ytdIncomeDripReturn := fDripReturn(
         yearIncomeDripShares,
         incomeClose,
         initialCapital
    )

    ytdBenchmarkDripReturn := fDripReturn(
         yearBenchmarkDripShares,
         benchmarkClose,
         initialCapital
    )

    ytdDripEdge := ytdIncomeDripReturn - ytdBenchmarkDripReturn

    ytdIncomeCashYield := yearIncomeCashPaid / initialCapital * 100.0

    ytdIncomeCapital := fCapitalLeftReturn(
         yearIncomeCashShares,
         incomeClose,
         0.0,
         initialCapital
    )

    ytdBenchmarkCapital := fCapitalLeftReturn(
         yearBenchmarkExtractShares,
         benchmarkClose,
         yearBenchmarkExtractCash,
         initialCapital
    )

    ytdSellEdge := ytdBenchmarkCapital - ytdIncomeCapital

    ytdSharesSoldPct := yearBenchmarkCashShares > 0 ? yearBenchmarkSharesSold / yearBenchmarkCashShares * 100.0 : na

// ============================================================================
// ENTIRE LOADED-PERIOD RESULTS
// ============================================================================

float periodIncomeCashReturn = na
float periodBenchmarkCashReturn = na

float periodIncomeDripReturn = na
float periodBenchmarkDripReturn = na
float periodDripEdge = na

float periodIncomeCashYield = na

float periodIncomeCapital = na
float periodBenchmarkCapital = na
float periodSellEdge = na

float periodSharesSoldPct = na

if dataValid and not na(periodIncomeCashShares)
    periodIncomeCashReturn := fCashTotalReturn(
         periodIncomeCashShares,
         incomeClose,
         periodIncomeCashPaid,
         initialCapital
    )

    periodBenchmarkCashReturn := fCashTotalReturn(
         periodBenchmarkCashShares,
         benchmarkClose,
         periodBenchmarkCashPaid,
         initialCapital
    )

    periodIncomeDripReturn := fDripReturn(
         periodIncomeDripShares,
         incomeClose,
         initialCapital
    )

    periodBenchmarkDripReturn := fDripReturn(
         periodBenchmarkDripShares,
         benchmarkClose,
         initialCapital
    )

    periodDripEdge := periodIncomeDripReturn - periodBenchmarkDripReturn

    periodIncomeCashYield := periodIncomeCashPaid / initialCapital * 100.0

    periodIncomeCapital := fCapitalLeftReturn(
         periodIncomeCashShares,
         incomeClose,
         0.0,
         initialCapital
    )

    periodBenchmarkCapital := fCapitalLeftReturn(
         periodBenchmarkExtractShares,
         benchmarkClose,
         periodBenchmarkExtractCash,
         initialCapital
    )

    periodSellEdge := periodBenchmarkCapital - periodIncomeCapital

    periodSharesSoldPct := periodBenchmarkCashShares > 0 ? periodBenchmarkSharesSold / periodBenchmarkCashShares * 100.0 : na

// ============================================================================
// TABLE SETTINGS
// ============================================================================

var string tablePos = position.middle_center

if tablePosition == "Top Left"
    tablePos := position.top_left

else if tablePosition == "Top Center"
    tablePos := position.top_center

else if tablePosition == "Top Right"
    tablePos := position.top_right

else if tablePosition == "Middle Left"
    tablePos := position.middle_left

else if tablePosition == "Middle Center"
    tablePos := position.middle_center

else if tablePosition == "Middle Right"
    tablePos := position.middle_right

else if tablePosition == "Bottom Left"
    tablePos := position.bottom_left

else if tablePosition == "Bottom Center"
    tablePos := position.bottom_center

else if tablePosition == "Bottom Right"
    tablePos := position.bottom_right

var string textSize = size.small

if fontSize == "Tiny"
    textSize := size.tiny

else if fontSize == "Small"
    textSize := size.small

else if fontSize == "Normal"
    textSize := size.normal

else if fontSize == "Large"
    textSize := size.large

else if fontSize == "Huge"
    textSize := size.huge

// The table always has 12 possible columns.
// When tax is disabled, column 11 is left empty and has no visible content.
var table resultsTable = table.new(
     tablePos,
     12,
     50,
     border_width = 1,
     border_color = color.gray
)

// ============================================================================
// TABLE DISPLAY
// ============================================================================

if barstate.islast
    table.clear(resultsTable, 0, 0, 11, 49)

    color headerColor = color.new(color.blue, 40)
    color explanationColor = color.new(color.gray, 68)
    color neutralColor = color.new(color.gray, 80)
    color ytdColor = color.new(color.teal, 45)
    color totalColor = color.new(color.orange, 40)

    // ------------------------------------------------------------------------
    // COLUMN HEADERS
    // ------------------------------------------------------------------------

    table.cell(
         resultsTable, 0, 0,
         "Period",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 1, 0,
         incomeSymbol + "\nCash Return",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 2, 0,
         benchmarkSymbol + "\nCash Return",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 3, 0,
         incomeSymbol + "\nDRIP Return",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 4, 0,
         benchmarkSymbol + "\nDRIP Return",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 5, 0,
         "DRIP Edge",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 6, 0,
         "Cash Paid",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 7, 0,
         incomeSymbol + "\nValue Left",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 8, 0,
         benchmarkSymbol + "\nValue Left",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 9, 0,
         "Index + Sell\nEdge",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 10, 0,
         "Index Shares\nSold",
         text_color = color.white,
         bgcolor = headerColor,
         text_size = textSize
    )

    if showTaxAssessment
        table.cell(
             resultsTable, 11, 0,
             "Potential\nTax Edge",
             text_color = color.white,
             bgcolor = headerColor,
             text_size = textSize
        )

    // This must not use `var`; it resets whenever the table redraws.
    int row = 1

    // ------------------------------------------------------------------------
    // OPTIONAL EXPLANATION ROW
    // ------------------------------------------------------------------------

    if showColumnExplanations
        table.cell(
             resultsTable, 0, row,
             "Completed year,\nYTD or full history",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 1, row,
             "Price change + payouts.\nPayouts kept as cash.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 2, row,
             "Index price change + dividends.\nDividends kept as cash.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 3, row,
             "All income ETF payouts\nbuy additional shares.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 4, row,
             "All benchmark dividends\nbuy additional shares.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 5, row,
             "Income DRIP minus index DRIP.\nPositive = income ETF wins.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 6, row,
             "Income ETF payouts received\nas % of starting capital.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 7, row,
             "Income ETF shares still owned.\nAll payouts assumed spent.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 8, row,
             "Index value after delivering\nthe same cash payouts.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 9, row,
             "Index value left minus income value.\nPositive = index + sell wins.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        table.cell(
             resultsTable, 10, row,
             "% of original index shares sold\nto match income payouts.",
             text_color = color.white,
             bgcolor = explanationColor,
             text_size = size.tiny
        )

        if showTaxAssessment
            table.cell(
                 resultsTable, 11, row,
                 "Potential U.S. tax advantage\nrelative to the benchmark.",
                 text_color = color.white,
                 bgcolor = explanationColor,
                 text_size = size.tiny
            )

        row += 1

    // ------------------------------------------------------------------------
    // COMPLETED CALENDAR YEARS
    // ------------------------------------------------------------------------

    if showYearlyReturns
        int numberOfYears = array.size(years)

        if numberOfYears > 0
            int firstYearIndex = math.max(0, numberOfYears - maxYearsToShow)

            for i = firstYearIndex to numberOfYears - 1
                int displayedYear = array.get(years, i)

                float incomeCashRet = array.get(incomeCashReturns, i)
                float benchmarkCashRet = array.get(benchmarkCashReturns, i)

                float incomeDripRet = array.get(incomeDripReturns, i)
                float benchmarkDripRet = array.get(benchmarkDripReturns, i)
                float dripEdge = array.get(dripEdges, i)

                float cashYield = array.get(incomeCashYields, i)

                float incomeCapital = array.get(incomeCapitalReturns, i)
                float benchmarkCapital = array.get(benchmarkCapitalReturns, i)
                float sellEdge = array.get(sellEdges, i)

                float soldPct = array.get(benchmarkSharesSoldPcts, i)

                table.cell(
                     resultsTable, 0, row,
                     str.tostring(displayedYear),
                     text_color = color.white,
                     bgcolor = neutralColor,
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 1, row,
                     fPct(incomeCashRet),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(incomeCashRet), 70),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 2, row,
                     fPct(benchmarkCashRet),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(benchmarkCashRet), 70),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 3, row,
                     fPct(incomeDripRet),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(incomeDripRet), 70),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 4, row,
                     fPct(benchmarkDripRet),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(benchmarkDripRet), 70),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 5, row,
                     fPct(dripEdge),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(dripEdge), 60),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 6, row,
                     fPct(cashYield),
                     text_color = color.white,
                     bgcolor = neutralColor,
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 7, row,
                     fPct(incomeCapital),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(incomeCapital), 70),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 8, row,
                     fPct(benchmarkCapital),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(benchmarkCapital), 70),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 9, row,
                     fPct(sellEdge),
                     text_color = color.white,
                     bgcolor = color.new(fValueColor(sellEdge), 60),
                     text_size = textSize
                )

                table.cell(
                     resultsTable, 10, row,
                     fPct(soldPct),
                     text_color = color.white,
                     bgcolor = neutralColor,
                     text_size = textSize
                )

                if showTaxAssessment
                    table.cell(
                         resultsTable, 11, row,
                         taxVerdict,
                         text_color = color.white,
                         bgcolor = taxAssessmentColor,
                         text_size = textSize
                    )

                row += 1

    // ------------------------------------------------------------------------
    // CURRENT YEAR
    // ------------------------------------------------------------------------

    string ytdLabel = na(currentYear) ? "NO DATA" : currentYearIsFull ? str.tostring(currentYear) + " YTD" : str.tostring(currentYear) + " Partial"

    table.cell(
         resultsTable, 0, row,
         ytdLabel,
         text_color = color.white,
         bgcolor = ytdColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 1, row,
         fPct(ytdIncomeCashReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdIncomeCashReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 2, row,
         fPct(ytdBenchmarkCashReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdBenchmarkCashReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 3, row,
         fPct(ytdIncomeDripReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdIncomeDripReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 4, row,
         fPct(ytdBenchmarkDripReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdBenchmarkDripReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 5, row,
         fPct(ytdDripEdge),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdDripEdge), 60),
         text_size = textSize
    )

    table.cell(
         resultsTable, 6, row,
         fPct(ytdIncomeCashYield),
         text_color = color.white,
         bgcolor = neutralColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 7, row,
         fPct(ytdIncomeCapital),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdIncomeCapital), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 8, row,
         fPct(ytdBenchmarkCapital),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdBenchmarkCapital), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 9, row,
         fPct(ytdSellEdge),
         text_color = color.white,
         bgcolor = color.new(fValueColor(ytdSellEdge), 60),
         text_size = textSize
    )

    table.cell(
         resultsTable, 10, row,
         fPct(ytdSharesSoldPct),
         text_color = color.white,
         bgcolor = neutralColor,
         text_size = textSize
    )

    if showTaxAssessment
        table.cell(
             resultsTable, 11, row,
             taxVerdict,
             text_color = color.white,
             bgcolor = taxAssessmentColor,
             text_size = textSize
        )

    row += 1

    // ------------------------------------------------------------------------
    // ENTIRE LOADED PERIOD
    // ------------------------------------------------------------------------

    table.cell(
         resultsTable, 0, row,
         "LOADED PERIOD",
         text_color = color.white,
         bgcolor = totalColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 1, row,
         fPct(periodIncomeCashReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodIncomeCashReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 2, row,
         fPct(periodBenchmarkCashReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodBenchmarkCashReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 3, row,
         fPct(periodIncomeDripReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodIncomeDripReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 4, row,
         fPct(periodBenchmarkDripReturn),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodBenchmarkDripReturn), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 5, row,
         fPct(periodDripEdge),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodDripEdge), 60),
         text_size = textSize
    )

    table.cell(
         resultsTable, 6, row,
         fPct(periodIncomeCashYield),
         text_color = color.white,
         bgcolor = neutralColor,
         text_size = textSize
    )

    table.cell(
         resultsTable, 7, row,
         fPct(periodIncomeCapital),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodIncomeCapital), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 8, row,
         fPct(periodBenchmarkCapital),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodBenchmarkCapital), 70),
         text_size = textSize
    )

    table.cell(
         resultsTable, 9, row,
         fPct(periodSellEdge),
         text_color = color.white,
         bgcolor = color.new(fValueColor(periodSellEdge), 60),
         text_size = textSize
    )

    table.cell(
         resultsTable, 10, row,
         fPct(periodSharesSoldPct),
         text_color = color.white,
         bgcolor = neutralColor,
         text_size = textSize
    )

    if showTaxAssessment
        string loadedPeriodTaxText = showColumnExplanations ? taxVerdict + "\n" + taxReason : taxVerdict

        table.cell(
             resultsTable, 11, row,
             loadedPeriodTaxText,
             text_color = color.white,
             bgcolor = taxAssessmentColor,
             text_size = textSize
        )
````
