# Stocks: Dashboard [invincible3]

- url: https://www.tradingview.com/script/noHTRxWW-Stocks-Dashboard-invincible3/
- type: indicator
- pine_id: PUB;b6701c6fa4c84d1788ac998a064f475f
- version: 1.0

## Description

[b]Stocks Dashboard [Invincible3][/b] is a professional all-in-one stock analysis dashboard built directly for TradingView charts. It is designed to help investors, traders, and analysts quickly evaluate a stock using a combination of fundamental strength, valuation, financial health, income quality, shareholder return, and price momentum.

The indicator displays a clean table-based dashboard on the chart and converts raw financial and technical data into easy-to-read category scores. Instead of checking many separate financial ratios manually, this dashboard organizes the most important stock metrics into structured sections and gives a clear visual overview of the company’s current condition.

The dashboard includes composite scoring for Quality, Value, Growth, Financial Health, Income / Shareholder Return, and Momentum. Each category is scored from 0 to 100 and classified using simple rating labels such as Elite, Strong, Fair, Weak, or Risk. This allows users to quickly compare the strength and weakness of a stock across multiple dimensions.

The Valuation section includes important valuation metrics such as P/E TTM, Forward P/E, PEG Ratio, P/S, P/B, EV/EBITDA, EV/Sales, Earnings Yield, Operating Earnings Yield, Graham Price, Graham Number Upside, EPS TTM, and BVPS. These metrics help identify whether a stock may be expensive, fairly valued, or potentially undervalued.

The Quality section focuses on profitability and business efficiency. It includes ROE, Asset Return / ROA, ROIC, Piotroski F-Score, Gross Margin, Operating Margin, Net Margin, EBITDA Margin, and Free Cash Flow Margin. These values help evaluate how efficiently the company generates profits from its assets, equity, capital, revenue, and operations.

The Growth section tracks the company’s expansion profile using Revenue Growth, EPS Growth, and Sustainable Growth Rate. These metrics help users understand whether the business is improving, stagnating, or losing earnings momentum.

The Financial Health section evaluates balance sheet strength and risk. It includes Debt / Equity, Debt / Assets, Debt / EBITDA, Net Debt / EBITDA, Cash / Debt, Current Ratio, Quick Ratio, Interest Coverage, Altman Z-Score, Operating Cash Flow, and Free Cash Flow. This section is useful for identifying companies with strong liquidity, manageable debt, and lower financial risk.

The Income / Return section is designed for dividend and shareholder-return analysis. It includes Dividend Yield, Payout Ratio, Free Cash Flow Yield, DPS, Buyback Yield, and Buyback Ratio. These metrics help investors evaluate whether a company is returning value to shareholders through dividends, buybacks, and cash generation.

The Momentum section adds a technical view of the stock. It includes RSI 14, 1-month return, 3-month return, 6-month return, 12-month return, 6-month relative strength versus a selected benchmark, 12-month relative strength versus a selected benchmark, volatility, and moving-average trend using the 20, 50, and 200 daily moving averages.

The Snapshot section provides a quick summary of the selected stock, including current price, market capitalization, enterprise value, 52-week position, and distance from the 52-week high. This gives users a fast overview of where the stock is trading relative to its recent range.

Users can customize the stock symbol, benchmark/index symbol, financial period, table position, text size, color theme, and visible sections. The dashboard supports multiple professional themes, including Dark Terminal, Light Terminal, Emerald Pro, Royal Blue, and Amber Desk. Users can also enable or disable colored score backgrounds, score bars, alternating rows, colorful section headers, and directional symbols.

This indicator is useful for:

* Long-term stock analysis
* Fundamental screening
* Valuation comparison
* Dividend and shareholder-return review
* Financial health analysis
* Momentum confirmation
* Relative strength comparison against an index or benchmark
* Building a structured watchlist review process

The goal of this dashboard is to provide a fast, organized, and visually professional stock overview without requiring users to switch between multiple financial websites or separate indicators. It combines fundamental data and technical momentum into one compact chart-based table, making it easier to identify strong, weak, undervalued, overvalued, or financially risky stocks.

Note: The dashboard uses TradingView’s available financial data. Some metrics may appear unavailable depending on the selected symbol, exchange, market, or financial data coverage. This tool is intended for analysis and research purposes only and should not be considered financial advice.

## Source Code

````pine
//@version=6
indicator("Stocks: Dashboard Pro [invincible3]", "Dashboard", overlay=true, max_labels_count=50, calc_bars_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpMain = "Main Settings"

symInput = input.symbol("", "Stock Symbol", group=grpMain)
sym      = symInput == "" ? syminfo.tickerid : symInput

benchSym  = input.symbol("SPY", "Benchmark / Index", group=grpMain)
finPeriod = input.string("FQ", "Financial Period", options=["FQ", "FY", "TTM"], group=grpMain)

posInput = input.string("Top Right", "Table Position", 
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpMain)

txtSizeInput = input.string("Tiny", "Text Size", options=["Tiny", "Small", "Normal"], group=grpMain)

colorTheme = input.string(
     "Dark Terminal", 
     "Color Theme", 
     options=["Dark Terminal", "Light Terminal", "Emerald Pro", "Royal Blue", "Amber Desk"], 
     group=grpMain)

showScoreBg       = input.bool(true, "Use Colored Score Backgrounds", group=grpMain)
showScoreBars     = input.bool(true, "Show Score Bars", group=grpMain)
useAltRows        = input.bool(true, "Subtle Alternating Rows", group=grpMain)
colorfulSections  = input.bool(true, "Colorful Section Headers", group=grpMain)
showStatusSymbols = input.bool(true, "Show ▲ ▼ Symbols", group=grpMain)

showSnapshot  = input.bool(true, "Show Snapshot", group=grpMain)
showValuation = input.bool(true, "Show Valuation", group=grpMain)
showQuality   = input.bool(true, "Show Quality", group=grpMain)
showGrowth    = input.bool(true, "Show Growth", group=grpMain)
showHealth    = input.bool(true, "Show Financial Health", group=grpMain)
showIncome    = input.bool(true, "Show Income / Shareholder Return", group=grpMain)
showMomentum  = input.bool(true, "Show Momentum", group=grpMain)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POSITION / SIZE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pos = switch posInput
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

txtSize = switch txtSizeInput
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIC FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
statPeriod = finPeriod == "TTM" ? "FQ" : finPeriod

f_fin(id) =>
    request.financial(sym, id, finPeriod, ignore_invalid_symbol=true)

f_stat(id) =>
    request.financial(sym, id, statPeriod, ignore_invalid_symbol=true)

f_ttm(id) =>
    request.financial(sym, id, "TTM", ignore_invalid_symbol=true)

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_safeDiv(float a, float b) =>
    na(a) or na(b) or b == 0 ? na : a / b

f_scoreHigher(float v, float bad, float good) =>
    na(v) ? na : f_clamp((v - bad) / (good - bad) * 100, 0, 100)

f_scoreLower(float v, float good, float bad) =>
    na(v) ? na : f_clamp((bad - v) / (bad - good) * 100, 0, 100)

f_scoreMid(float v, float low, float ideal, float high) =>
    na(v) ? na : v <= ideal ? f_clamp((v - low) / (ideal - low) * 100, 0, 100) : f_clamp((high - v) / (high - ideal) * 100, 0, 100)

f_scorePositive(float v) =>
    na(v) ? na : v > 0 ? 100 : 0

f_avg5(float a, float b, float c, float d, float e) =>
    float sum = 0.0
    int n = 0
    if not na(a)
        sum += a
        n += 1
    if not na(b)
        sum += b
        n += 1
    if not na(c)
        sum += c
        n += 1
    if not na(d)
        sum += d
        n += 1
    if not na(e)
        sum += e
        n += 1
    n == 0 ? na : sum / n

f_avg3(float a, float b, float c) =>
    f_avg5(a, b, c, na, na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREMIUM COLOR THEMES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isLightTheme = colorTheme == "Light Terminal"
isEmerald    = colorTheme == "Emerald Pro"
isRoyal      = colorTheme == "Royal Blue"
isAmber      = colorTheme == "Amber Desk"
isDarkTheme  = not isLightTheme

tableBg = isLightTheme ? color.rgb(246, 247, 250) :
     isEmerald ? color.rgb(5, 18, 15) :
     isRoyal ? color.rgb(7, 12, 28) :
     isAmber ? color.rgb(19, 15, 9) :
     color.rgb(8, 14, 26)

altBg = isLightTheme ? color.rgb(235, 238, 243) :
     isEmerald ? color.rgb(7, 27, 22) :
     isRoyal ? color.rgb(10, 20, 45) :
     isAmber ? color.rgb(29, 23, 13) :
     color.rgb(10, 20, 36)

headerBg = isLightTheme ? color.rgb(215, 220, 228) :
     isEmerald ? color.rgb(5, 64, 49) :
     isRoyal ? color.rgb(14, 45, 105) :
     isAmber ? color.rgb(95, 58, 14) :
     color.rgb(15, 40, 78)

sectionBg = isLightTheme ? color.rgb(226, 230, 236) :
     isEmerald ? color.rgb(8, 38, 31) :
     isRoyal ? color.rgb(11, 28, 60) :
     isAmber ? color.rgb(49, 34, 14) :
     color.rgb(13, 27, 48)

gridCol = isLightTheme ? color.rgb(178, 184, 195) :
     isEmerald ? color.rgb(23, 91, 74) :
     isRoyal ? color.rgb(34, 69, 125) :
     isAmber ? color.rgb(112, 78, 32) :
     color.rgb(31, 59, 98)

mainTxt = isLightTheme ? color.rgb(24, 27, 33) : color.rgb(215, 224, 238)
mutedTxt = isLightTheme ? color.rgb(78, 84, 96) : color.rgb(142, 158, 182)

titleTxt = isLightTheme ? color.rgb(15, 35, 60) :
     isEmerald ? color.rgb(95, 255, 197) :
     isRoyal ? color.rgb(105, 190, 255) :
     isAmber ? color.rgb(255, 197, 85) :
     color.rgb(94, 190, 255)

bullTxt = isLightTheme ? color.rgb(24, 145, 91) : color.rgb(73, 220, 165)
bearTxt = isLightTheme ? color.rgb(205, 52, 68) : color.rgb(255, 92, 120)
purpleTxt = isLightTheme ? color.rgb(107, 79, 202) : color.rgb(160, 135, 255)
goldTxt = isLightTheme ? color.rgb(168, 123, 25) : color.rgb(238, 207, 92)
cyanTxt = isLightTheme ? color.rgb(34, 132, 156) : color.rgb(86, 204, 255)
neutralTxt = isLightTheme ? color.rgb(95, 101, 112) : color.rgb(164, 176, 195)

secValueBg     = color.rgb(16, 80, 55)
secQualityBg   = color.rgb(18, 70, 105)
secGrowthBg    = color.rgb(105, 75, 20)
secHealthBg    = color.rgb(105, 42, 50)
secMomentumBg  = color.rgb(72, 55, 125)
secIncomeBg    = color.rgb(95, 68, 18)
secSnapshotBg  = color.rgb(55, 65, 82)
secCompositeBg = color.rgb(20, 87, 95)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STYLE FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_rowBg(int row) =>
    useAltRows and row % 2 == 0 ? altBg : tableBg

f_scoreColor(float s) =>
    na(s) ? neutralTxt :
     s >= 80 ? bullTxt :
     s >= 60 ? purpleTxt :
     s >= 40 ? goldTxt :
     bearTxt

f_scoreBg(float s) =>
    not showScoreBg ? tableBg :
     na(s) ? tableBg :
     color.new(f_scoreColor(s), isLightTheme ? 86 : 84)

f_sectionBg(string title) =>
    not colorfulSections ? sectionBg :
     str.contains(title, "COMPOSITE") ? secCompositeBg :
     str.contains(title, "SNAPSHOT") ? secSnapshotBg :
     str.contains(title, "VALUATION") ? secValueBg :
     str.contains(title, "QUALITY") ? secQualityBg :
     str.contains(title, "GROWTH") ? secGrowthBg :
     str.contains(title, "HEALTH") ? secHealthBg :
     str.contains(title, "MOMENTUM") ? secMomentumBg :
     str.contains(title, "INCOME") ? secIncomeBg :
     sectionBg

f_categoryColor(string name, color fallback) =>
    str.contains(name, "Momentum") or str.contains(name, "RSI") or str.contains(name, "Return") or str.contains(name, "RS vs") ? purpleTxt :
     str.contains(name, "Growth") or str.contains(name, "Income") or str.contains(name, "Yield") or str.contains(name, "Payout") or str.contains(name, "Buyback") or str.contains(name, "Cash") or str.contains(name, "Health") or str.contains(name, "Debt") or str.contains(name, "Ratio") or str.contains(name, "Cover") or str.contains(name, "Altman") or str.contains(name, "OCF") or str.contains(name, "FCF") ? goldTxt :
     str.contains(name, "Quality") or str.contains(name, "ROE") or str.contains(name, "ROA") or str.contains(name, "Asset") or str.contains(name, "Piotroski") or str.contains(name, "ROIC") or str.contains(name, "Margin") or str.contains(name, "Profit") ? cyanTxt :
     str.contains(name, "Value") or str.contains(name, "P/E") or str.contains(name, "PEG") or str.contains(name, "P/S") or str.contains(name, "P/B") or str.contains(name, "EV/") or str.contains(name, "Graham") or str.contains(name, "EPS") or str.contains(name, "BVPS") or str.contains(name, "52W") ? bullTxt :
     fallback

f_fmt(float v) =>
    na(v) ? "—" : str.tostring(v, "#.##")

f_pct(float v) =>
    na(v) ? "—" : str.tostring(v, "#.##") + "%"

f_money(float v) =>
    na(v) ? "—" :
     math.abs(v) >= 1e12 ? str.tostring(v / 1e12, "#.##") + "T" :
     math.abs(v) >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" :
     math.abs(v) >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" :
     str.tostring(v, "#.##")

f_grade(float s) =>
    na(s) ? "N/A" :
     s >= 85 ? "ELITE" :
     s >= 70 ? "STRONG" :
     s >= 55 ? "FAIR" :
     s >= 40 ? "WEAK" :
     "RISK"

f_overallBadge(float s) =>
    na(s) ? "N/A " :
     s >= 85 ? "ELITE " :
     s >= 70 ? "STRONG " :
     s >= 55 ? "FAIR " :
     s >= 40 ? "WEAK " :
     "RISK "

f_arrow(float v) =>
    not showStatusSymbols or na(v) ? "" : v > 0 ? "▲ " : v < 0 ? "▼ " : "■ "

f_scoreText(float score) =>
    string result = "—"
    if not na(score)
        if showScoreBars
            int filled = int(math.round(f_clamp(score, 0, 100) / 100 * 6))
            string bar = ""
            for i = 0 to 5
                bar += i < filled ? "█" : "░"
            result := bar + " " + str.tostring(score, "#")
        else
            result := str.tostring(score, "#")
    result

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE / MOMENTUM DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type SecData
    float dClose
    float rsi14
    float sma20
    float sma50
    float sma200
    float high52
    float low52
    float ret1m
    float ret3m
    float ret6m
    float ret12m
    float volatility

getSecData() =>
    SecData.new(
         close,
         ta.rsi(close, 14),
         ta.sma(close, 20),
         ta.sma(close, 50),
         ta.sma(close, 200),
         ta.highest(high, 252),
         ta.lowest(low, 252),
         (close / nz(close[21]) - 1) * 100,
         (close / nz(close[63]) - 1) * 100,
         (close / nz(close[126]) - 1) * 100,
         (close / nz(close[252]) - 1) * 100,
         ta.stdev(close / nz(close[1]) - 1, 63) * math.sqrt(252) * 100
     )

secData = request.security(sym, "D", getSecData(), ignore_invalid_symbol=true)

dClose = na(secData) ? na : secData.dClose
rsi14  = na(secData) ? na : secData.rsi14
sma20  = na(secData) ? na : secData.sma20
sma50  = na(secData) ? na : secData.sma50
sma200 = na(secData) ? na : secData.sma200
high52 = na(secData) ? na : secData.high52
low52  = na(secData) ? na : secData.low52
ret1m  = na(secData) ? na : secData.ret1m
ret3m  = na(secData) ? na : secData.ret3m
ret6m  = na(secData) ? na : secData.ret6m
ret12m = na(secData) ? na : secData.ret12m
volatility = na(secData) ? na : secData.volatility

[bench6m, bench12m] = request.security(
     benchSym, 
     "D", 
     [(close / nz(close[126]) - 1) * 100, (close / nz(close[252]) - 1) * 100], 
     ignore_invalid_symbol=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINANCIAL DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sharesOut       = f_stat("TOTAL_SHARES_OUTSTANDING")
enterpriseValue = f_stat("ENTERPRISE_VALUE")

epsTtm     = f_ttm("EARNINGS_PER_SHARE_DILUTED")
fpe        = f_stat("PRICE_EARNINGS_FORWARD")
bvps       = f_stat("BOOK_VALUE_PER_SHARE")
revenueTtm = f_ttm("TOTAL_REVENUE")
evEbitda   = f_stat("ENTERPRISE_VALUE_EBITDA")
evSales    = f_stat("EV_REVENUE")

roe       = f_stat("RETURN_ON_EQUITY")
roa       = f_stat("RETURN_ON_ASSETS")
roic      = f_stat("RETURN_ON_INVESTED_CAPITAL")
grossM    = f_fin("GROSS_MARGIN")
opM       = f_fin("OPERATING_MARGIN")
netM      = f_fin("NET_MARGIN")
ebitdaM   = f_fin("EBITDA_MARGIN")
fcfMargin = f_fin("FREE_CASH_FLOW_MARGIN")
piotroski = f_stat("PIOTROSKI_F_SCORE")

revGrowth = f_fin("REVENUE_ONE_YEAR_GROWTH")
epsGrowth = f_fin("EARNINGS_PER_SHARE_DILUTED_ONE_YEAR_GROWTH")
sgr       = f_stat("SUSTAINABLE_GROWTH_RATE")

debtEq          = f_stat("DEBT_TO_EQUITY")
debtAsset       = f_stat("DEBT_TO_ASSET")
debtEbitda      = f_stat("DEBT_TO_EBITDA")
netDebtEbitda   = f_stat("NET_DEBT_TO_EBITDA")
cashDebt        = f_stat("CASH_TO_DEBT")
currRatio       = f_stat("CURRENT_RATIO")
quickRatio      = f_stat("QUICK_RATIO")
interestCover   = f_stat("INTERST_COVER")
altmanZ         = f_stat("ALTMAN_Z_SCORE")
ocf             = f_fin("CASH_F_OPERATING_ACTIVITIES")
fcf             = f_fin("FREE_CASH_FLOW")

divYield     = f_stat("DIVIDENDS_YIELD")
payout       = f_fin("DIVIDEND_PAYOUT_RATIO")
dps          = f_fin("DPS_COMMON_STOCK_PRIM_ISSUE")
buybackYield = f_stat("BUYBACK_YIELD")
buybackRatio = f_stat("SHARE_BUYBACK_RATIO")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
const int ROWS = 78

var table dash = table.new(
     pos, 
     6, 
     ROWS, 
     bgcolor=tableBg, 
     border_color=gridCol, 
     border_width=0, 
     frame_color=gridCol, 
     frame_width=2)

f_cell(int col, int row, string txt, color bg, color tc) =>
    if row < ROWS
        table.cell(dash, col, row, txt, bgcolor=bg, text_color=tc, text_size=txtSize)

f_boldCell(int col, int row, string txt, color bg, color tc) =>
    if row < ROWS
        table.cell(dash, col, row, txt, bgcolor=bg, text_color=tc, text_size=txtSize, text_formatting=text.format_bold)

f_headerCell(int col, string txt, color bg, color tc) =>
    table.cell(dash, col, 0, txt, bgcolor=bg, text_color=tc, text_size=txtSize, text_formatting=text.format_bold)

f_section(int base, int row, string title) =>
    bg = f_sectionBg(title)
    f_boldCell(base, row, title, bg, color.white)
    f_boldCell(base + 1, row, "Value", bg, color.white)
    f_boldCell(base + 2, row, "Score", bg, color.white)
    row + 1

f_row(int base, int row, string name, string value, float score) =>
    bg = f_rowBg(row)
    scoreBg = showScoreBg ? f_scoreBg(score) : bg
    scoreTxt = f_scoreText(score)
    valTxtCol = na(score) ? mainTxt : isDarkTheme ? f_scoreColor(score) : f_categoryColor(name, f_scoreColor(score))
    f_cell(base, row, name, bg, mutedTxt)
    f_cell(base + 1, row, value, bg, valTxtCol)
    f_cell(base + 2, row, scoreTxt, scoreBg, valTxtCol)
    row + 1

f_scoreCard(int base, int row, string name, float score) =>
    bg = showScoreBg ? f_scoreBg(score) : f_rowBg(row)
    tc = isDarkTheme ? f_scoreColor(score) : f_categoryColor(name, f_scoreColor(score))
    f_cell(base, row, name, bg, mainTxt)
    f_cell(base + 1, row, f_scoreText(score), bg, tc)
    f_cell(base + 2, row, f_grade(score), bg, tc)
    row + 1

if barstate.islast
    relStr6m  = ret6m - bench6m
    relStr12m = ret12m - bench12m

    pos52 = na(high52) or na(low52) or high52 == low52 ? na : (dClose - low52) / (high52 - low52) * 100
    dist52High = na(high52) ? na : (dClose / high52 - 1) * 100

    maStatus = dClose > sma20 and dClose > sma50 and dClose > sma200 ? "Bullish" :
         dClose > sma50 and dClose > sma200 ? "Strong" :
         dClose > sma200 ? "Neutral" :
         dClose > sma50 ? "Weak" :
         "Bearish"

    maScore = 
         dClose > sma20 and dClose > sma50 and dClose > sma200 ? 100 :
         dClose > sma50 and dClose > sma200 ? 80 :
         dClose > sma200 ? 60 :
         dClose > sma50 ? 45 :
         25

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // DERIVED RATIOS
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    mcap = na(sharesOut) or na(dClose) ? na : sharesOut * dClose

    pe = f_safeDiv(dClose, epsTtm)
    ps = f_safeDiv(mcap, revenueTtm)
    pb = f_safeDiv(dClose, bvps)

    peg = na(pe) or na(epsGrowth) or epsGrowth <= 0 ? na : pe / epsGrowth

    earnYield = na(dClose) or na(epsTtm) or dClose == 0 ? na : epsTtm / dClose * 100
    opEarnYield = na(opM) or na(ps) or ps == 0 ? na : opM / ps
    fcfYield = na(fcf) or na(mcap) or mcap == 0 ? na : fcf / mcap * 100

    grahamPrice = na(epsTtm) or na(bvps) or epsTtm <= 0 or bvps <= 0 ? na : math.sqrt(22.5 * epsTtm * bvps)
    grahamUpside = na(grahamPrice) or na(dClose) or dClose == 0 ? na : (grahamPrice / dClose - 1) * 100

    dpsEst = na(dps) and not na(divYield) and not na(dClose) ? dClose * divYield / 100 : dps

    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // SCORES
    //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    peScore        = f_scoreLower(pe, 8, 45)
    fpeScore       = f_scoreLower(fpe, 8, 40)
    psScore        = f_scoreLower(ps, 1, 15)
    pbScore        = f_scoreLower(pb, 1, 12)
    pegScore       = f_scoreLower(peg, 0.5, 3.5)
    evScore        = f_scoreLower(evEbitda, 5, 30)
    evSalesScore   = f_scoreLower(evSales, 1, 15)
    earnYieldScore = f_scoreHigher(earnYield, 2, 12)
    opYieldScore   = f_scoreHigher(opEarnYield, 3, 15)
    grahamScore    = f_scoreHigher(grahamUpside, -30, 50)

    valueScore = f_avg5(
         f_avg3(peScore, fpeScore, pegScore),
         f_avg3(psScore, pbScore, evScore),
         evSalesScore,
         f_avg3(earnYieldScore, opYieldScore, na),
         grahamScore)

    roeScore       = f_scoreHigher(roe, 5, 25)
    roaScore       = f_scoreHigher(roa, 2, 15)
    roicScore      = f_scoreHigher(roic, 5, 25)
    grossScore     = f_scoreHigher(grossM, 20, 60)
    opScore        = f_scoreHigher(opM, 5, 30)
    netScore       = f_scoreHigher(netM, 3, 25)
    ebitdaScore    = f_scoreHigher(ebitdaM, 8, 35)
    fcfMarginScore = f_scoreHigher(fcfMargin, 0, 20)
    piotroskiScore = na(piotroski) ? na : f_clamp(piotroski / 9 * 100, 0, 100)

    qualityScore = f_avg5(
         f_avg3(roeScore, roaScore, roicScore),
         f_avg3(grossScore, opScore, netScore),
         f_avg3(ebitdaScore, fcfMarginScore, na),
         piotroskiScore,
         na)

    revScore = f_scoreHigher(revGrowth, 0, 25)
    epsScore = f_scoreHigher(epsGrowth, 0, 30)
    sgrScore = f_scoreHigher(sgr, 0, 20)

    growthScore = f_avg3(revScore, epsScore, sgrScore)

    debtEqNorm     = na(debtEq) ? na : math.abs(debtEq) <= 5 ? debtEq * 100 : debtEq
    debtAssetNorm  = na(debtAsset) ? na : math.abs(debtAsset) <= 5 ? debtAsset * 100 : debtAsset
    cashDebtNorm   = na(cashDebt) ? na : math.abs(cashDebt) > 10 ? cashDebt / 100 : cashDebt

    debtEqScore        = f_scoreLower(debtEqNorm, 0, 250)
    debtAssetScore     = f_scoreLower(debtAssetNorm, 0, 80)
    debtEbitdaScore    = f_scoreLower(debtEbitda, 0, 6)
    netDebtEbitdaScore = f_scoreLower(netDebtEbitda, 0, 5)
    cashDebtScore      = f_scoreHigher(cashDebtNorm, 0, 1.5)
    currScore          = f_scoreMid(currRatio, 0.5, 2.0, 5.0)
    quickScore         = f_scoreMid(quickRatio, 0.3, 1.5, 4.0)
    interestScore      = f_scoreHigher(interestCover, 2, 20)
    altmanScore        = f_scoreHigher(altmanZ, 1.8, 3.5)
    ocfScore           = f_scorePositive(ocf)
    fcfScore           = f_scorePositive(fcf)

    healthScore = f_avg5(
         f_avg3(debtEqScore, debtAssetScore, debtEbitdaScore),
         f_avg3(netDebtEbitdaScore, cashDebtScore, interestScore),
         f_avg3(currScore, quickScore, na),
         altmanScore,
         f_avg3(ocfScore, fcfScore, na))

    yieldScore         = f_scoreHigher(divYield, 0, 5)
    payoutScore        = f_scoreMid(payout, 0, 40, 100)
    buybackYieldScore  = f_scoreHigher(buybackYield, 0, 5)
    buybackRatioScore  = f_scoreHigher(buybackRatio, 0, 5)
    fcfYieldScore      = f_scoreHigher(fcfYield, 0, 8)
    dpsScore           = f_scorePositive(dpsEst)

    incomeScore = f_avg5(
         yieldScore, 
         payoutScore, 
         fcfYieldScore, 
         f_avg3(buybackYieldScore, buybackRatioScore, na), 
         dpsScore)

    rsiScore  = f_scoreMid(rsi14, 30, 60, 85)
    posScore  = f_scoreHigher(pos52, 20, 90)
    rs6Score  = f_scoreHigher(relStr6m, -20, 25)
    rs12Score = f_scoreHigher(relStr12m, -25, 35)
    volScore  = f_scoreLower(volatility, 10, 80)

    momentumScore = f_avg5(
         rsiScore, 
         posScore, 
         rs6Score, 
         rs12Score, 
         f_avg3(maScore, volScore, na))

    overallScore = f_avg5(
         valueScore, 
         qualityScore, 
         growthScore, 
         healthScore, 
         f_avg3(momentumScore, incomeScore, na))

    table.clear(dash, 0, 0, 5, ROWS - 1)

    overallTxt = f_overallBadge(overallScore) + f_fmt(overallScore)

    f_headerCell(0, "STOCK DASHBOARD", headerBg, titleTxt)
    f_headerCell(1, sym, headerBg, titleTxt)
    f_headerCell(2, finPeriod, headerBg, titleTxt)
    f_headerCell(3, "Benchmark", headerBg, titleTxt)
    f_headerCell(4, benchSym, headerBg, titleTxt)
    f_headerCell(5, overallTxt, headerBg, f_scoreColor(overallScore))

    int l = 1
    int r = 1

    l := f_section(0, l, "COMPOSITE SCORES")
    l := f_scoreCard(0, l, "Quality", qualityScore)
    l := f_scoreCard(0, l, "Value", valueScore)
    l := f_scoreCard(0, l, "Growth", growthScore)
    l := f_scoreCard(0, l, "Health", healthScore)
    l := f_scoreCard(0, l, "Income", incomeScore)
    l := f_scoreCard(0, l, "Momentum", momentumScore)

    if showSnapshot
        l := f_section(0, l, "SNAPSHOT")
        l := f_row(0, l, "Price", f_fmt(dClose), na)
        l := f_row(0, l, "Market Cap", f_money(mcap), na)
        l := f_row(0, l, "Enterprise Value", f_money(enterpriseValue), na)
        l := f_row(0, l, "52W Position", f_arrow(pos52 - 50) + f_pct(pos52), posScore)
        l := f_row(0, l, "Dist. From 52W High", f_arrow(dist52High) + f_pct(dist52High), posScore)

    if showValuation
        l := f_section(0, l, "VALUATION")
        l := f_row(0, l, "P/E TTM", f_fmt(pe), peScore)
        l := f_row(0, l, "Forward P/E", f_fmt(fpe), fpeScore)
        l := f_row(0, l, "PEG Ratio", f_fmt(peg), pegScore)
        l := f_row(0, l, "P/S TTM", f_fmt(ps), psScore)
        l := f_row(0, l, "P/B", f_fmt(pb), pbScore)
        l := f_row(0, l, "EV/EBITDA", f_fmt(evEbitda), evScore)
        l := f_row(0, l, "EV/Sales", f_fmt(evSales), evSalesScore)
        l := f_row(0, l, "Earnings Yield", f_pct(earnYield), earnYieldScore)
        l := f_row(0, l, "Operating Earn. Yield", f_pct(opEarnYield), opYieldScore)
        l := f_row(0, l, "Graham Price", f_fmt(grahamPrice), grahamScore)
        l := f_row(0, l, "Graham No. Upside", f_arrow(grahamUpside) + f_pct(grahamUpside), grahamScore)
        l := f_row(0, l, "EPS TTM", f_fmt(epsTtm), na)
        l := f_row(0, l, "BVPS", f_fmt(bvps), pbScore)

    if showIncome
        l := f_section(0, l, "INCOME / RETURN")
        l := f_row(0, l, "Dividend Yield", f_pct(divYield), yieldScore)
        l := f_row(0, l, "Payout Ratio", f_pct(payout), payoutScore)
        l := f_row(0, l, "FCF Yield", f_pct(fcfYield), fcfYieldScore)
        l := f_row(0, l, "DPS", f_fmt(dpsEst), dpsScore)
        l := f_row(0, l, "Buyback Yield", f_pct(buybackYield), buybackYieldScore)
        l := f_row(0, l, "Buyback Ratio", f_pct(buybackRatio), buybackRatioScore)

    if showQuality
        r := f_section(3, r, "QUALITY")
        r := f_row(3, r, "ROE", f_pct(roe), roeScore)
        r := f_row(3, r, "Asset Return / ROA", f_pct(roa), roaScore)
        r := f_row(3, r, "ROIC", f_pct(roic), roicScore)
        r := f_row(3, r, "Piotroski F-Score", f_fmt(piotroski), piotroskiScore)
        r := f_row(3, r, "Gross Margin", f_pct(grossM), grossScore)
        r := f_row(3, r, "Operating Margin", f_pct(opM), opScore)
        r := f_row(3, r, "Net Margin", f_pct(netM), netScore)
        r := f_row(3, r, "EBITDA Margin", f_pct(ebitdaM), ebitdaScore)
        r := f_row(3, r, "FCF Margin", f_pct(fcfMargin), fcfMarginScore)

    if showGrowth
        r := f_section(3, r, "GROWTH")
        r := f_row(3, r, "Revenue Growth", f_arrow(revGrowth) + f_pct(revGrowth), revScore)
        r := f_row(3, r, "EPS Growth", f_arrow(epsGrowth) + f_pct(epsGrowth), epsScore)
        r := f_row(3, r, "Sustainable Growth", f_arrow(sgr) + f_pct(sgr), sgrScore)

    if showHealth
        r := f_section(3, r, "FINANCIAL HEALTH")
        r := f_row(3, r, "Debt / Equity", f_fmt(debtEq), debtEqScore)
        r := f_row(3, r, "Debt / Assets", f_fmt(debtAsset), debtAssetScore)
        r := f_row(3, r, "Debt / EBITDA", f_fmt(debtEbitda), debtEbitdaScore)
        r := f_row(3, r, "Net Debt / EBITDA", f_fmt(netDebtEbitda), netDebtEbitdaScore)
        r := f_row(3, r, "Cash / Debt", f_fmt(cashDebt), cashDebtScore)
        r := f_row(3, r, "Current Ratio", f_fmt(currRatio), currScore)
        r := f_row(3, r, "Quick Ratio", f_fmt(quickRatio), quickScore)
        r := f_row(3, r, "Interest Cover", f_fmt(interestCover), interestScore)
        r := f_row(3, r, "Altman Z-Score", f_fmt(altmanZ), altmanScore)
        r := f_row(3, r, "OCF", f_money(ocf), ocfScore)
        r := f_row(3, r, "FCF", f_money(fcf), fcfScore)

    if showMomentum
        r := f_section(3, r, "MOMENTUM")
        r := f_row(3, r, "RSI 14", f_fmt(rsi14), rsiScore)
        r := f_row(3, r, "1M Return", f_arrow(ret1m) + f_pct(ret1m), na)
        r := f_row(3, r, "3M Return", f_arrow(ret3m) + f_pct(ret3m), na)
        r := f_row(3, r, "6M Return", f_arrow(ret6m) + f_pct(ret6m), na)
        r := f_row(3, r, "12M Return", f_arrow(ret12m) + f_pct(ret12m), na)
        r := f_row(3, r, "6M RS vs Index", f_arrow(relStr6m) + f_pct(relStr6m), rs6Score)
        r := f_row(3, r, "12M RS vs Index", f_arrow(relStr12m) + f_pct(relStr12m), rs12Score)
        r := f_row(3, r, "Volatility", f_pct(volatility), volScore)
        r := f_row(3, r, "MA 20/50/200", maStatus, maScore)
````
