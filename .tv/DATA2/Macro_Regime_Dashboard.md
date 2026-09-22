<!-- tradingview-pine-id: PUB;d799cf16735343b3bd30b2a26140fa2c -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Macro Regime Dashboard

Source: https://www.tradingview.com/script/UgtyricM-Macro-Regime-Dashboard/

## Description

█ OVERVIEW

Macro Regime Dashboard is a market-timing checklist for US equities. It evaluates five regime conditions on every daily bar: elevated volatility, a non-rising Fed policy rate, contracting margin debt, the presence of a leading sector, and earnings confirmation from bellwether stocks. It plots the count of conditions met as a stepline in a separate pane, renders a live checklist table, and marks the bars where all conditions and the enabled fail-safes align. The thesis: durable market bottoms tend to form when fear is high, the Fed is not tightening, leverage has been flushed, and a leading theme keeps delivering earnings through the panic.

█ HISTORY / BACKGROUND

The five-condition checklist and its fail-safes are the market-timing framework described by the YouTuber, Defiant Gatekeeper, who distilled it from his buy decisions around volatility spikes. The framework itself synthesizes established concepts: the VIX as a fear gauge, Federal Reserve policy as the dominant liquidity driver, margin debt as a measure of speculative leverage, sector leadership as the engine that attracts institutional capital, and earnings surprises as confirmation that the leading theme is insulated from the broader panic.

The fail-safes address the framework's known failure modes, which the author identifies from historical episodes: leading-sector fundamentals breaking down, systemic accounting fraud destroying trust in reported earnings, a credit freeze that policy easing cannot offset, and inflation high enough to remove the Fed's ability to support asset prices. Two of these are quantifiable and are implemented here as the high-yield credit spread and CPI fail-safes. The concept is his; this Pine implementation, the data-series selections, and the proxy choices are original to this script.

█ HOW IT WORKS

On each daily bar the script requests six external series and evaluates five boolean conditions plus two fail-safes.

Condition 1: Fear. The CBOE Volatility Index (CBOE:VIX) must exceed the threshold input (default 30).

Condition 2: Fed not on an upward trajectory. The effective federal funds rate (FRED:DFF) today must be at or below its value from the lookback number of trading days earlier, with a 0.01 tolerance. The table also flags when the 2-year Treasury yield (TVC:US02Y) sits below the funds rate, indicating that the bond market is pricing cuts; this flag is informational and does not gate the condition. Because the policy trajectory is partly qualitative (guidance, projections), an override input can force this condition to pass or fail.

Condition 3: Margin debt declining. The reference framework uses the monthly FINRA margin debt statistic, which TradingView does not carry. The script substitutes the Federal Reserve Z.1 series for margin accounts at brokers and dealers (FRED:BOGZ1FL663067003Q), requested at 3-month resolution. The condition passes when the latest quarterly value is below the prior quarterly value.

Condition 4: Leading sector. The script loops over eleven S&P sector ETFs plus a semiconductor ETF, computes each one's return over the lookback window, and subtracts the SPY return over the same window. The strongest relative-strength value must exceed the threshold input (default 3 percentage points over 63 days). The table names the current leader.

Condition 5: Bellwether earnings beats. For up to three user-selected bellwether symbols representing the leading theme, the script pulls reported and estimated earnings per share through the earnings request feed and marks a beat when actual is at or above estimate for the most recent report. The condition passes when a majority of the symbols with available data beat. When no earnings data exists for any bellwether, the condition passes neutrally rather than failing, so that missing history does not veto the count. An override input can force this condition either way.

Fail-safes. The ICE BofA US High Yield Option-Adjusted Spread (FRED:BAMLH0A0HYM2) must sit below its threshold (default 10 percent), and CPI year-over-year, computed from FRED:CPIAUCSL as the ratio of the monthly index to its value twelve months earlier, must sit below its threshold (default 2.5 percent). Each fail-safe passes when its data is unavailable. Two toggle inputs decide whether each fail-safe vetoes the composite signal or only displays as a warning. By default the credit fail-safe gates and the CPI fail-safe warns.

Composite. The buy state is true when all five conditions hold and every enabled gate is clear. The script plots the raw condition count (0 to 5) as a stepline, draws a dotted horizontal reference at 5, shades the pane background green while the buy state is active, and prints a green triangle on the first bar of each signal window. A table in the top right shows each condition's current value and pass state, both fail-safe readings, and a composite verdict row. Two alerts are provided: one on the first bar of a new buy signal, and one when the credit spread crosses above its threshold.

█ HOW TO USE

Apply the indicator to a broad US index such as SPX or SPY on the daily timeframe. All inputs and thresholds are calibrated to daily bars; the conditions describe the whole market, so the chart symbol only supplies the bar grid.

Read the stepline as regime pressure. A count of 3 or 4 during a selloff means the setup is forming; a touch of 5 with the background shading and a triangle means every condition and enabled gate aligned on that bar. A count of 5 without shading means a fail-safe is blocking, which is exactly the bull-trap situation the fail-safes exist to flag. The table gives the per-condition diagnosis at a glance.

Using the dashboard in tandem with the Stock Screener

The dashboard times entry and sizing. It does not select stocks. The reference framework pairs it with a fundamental selection layer keyed to the liquidity regime, and most of that layer maps directly onto TradingView's Stock Screener fields: revenue growth, EPS growth, forward price-to-earnings, and debt to EBITDA. The workflow:

[*]Determine the liquidity quadrant. The dashboard's Fed condition covers the rate trajectory. Check the Fed balance sheet direction separately by charting FRED:WALCL: rising means expansion, falling means contraction.
[*]Rate falling and balance sheet rising (maximum liquidity): screen for revenue growth above 50 percent and ignore valuation and leverage fields. Unprofitable hypergrowth is the target profile in this quadrant.
[*]Mixed quadrants (one lever easing, one tightening): screen for revenue growth in the 10 to 20 percent range, a moderate forward price-to-earnings, and debt to EBITDA below roughly 3 to 5 depending on which lever is easing.
[*]Rate rising and balance sheet falling (minimum liquidity): screen for forward price-to-earnings below 15, debt to EBITDA below 1.5, and positive earnings. Stability over growth.
[*]When the dashboard signals, run the screener preset for the current quadrant, restricted to the leading sector the table names, to surface candidates.

The final validation step in the reference framework, a regression of price-to-earnings against expected EPS growth across roughly ten same-industry peers with an R-squared above 0.8, is not screenable and is performed outside TradingView in a spreadsheet.

█ SETTINGS

[*]VIX threshold (default 30): level the volatility index must exceed for condition 1.
[*]Fed rate lookback (default 63 trading days): comparison window for the funds-rate trajectory in condition 2.
[*]Fed trajectory override (default Auto): forces condition 2 to pass or fail when guidance contradicts the rate proxy.
[*]Sector RS lookback (default 63 days): return window for the relative-strength computation in condition 4.
[*]RS outperformance vs SPY (default 3 percent): margin by which the leading sector must beat SPY.
[*]Bellwether 1, 2, 3 (defaults are three large semiconductor names): symbols whose earnings reports confirm the leading theme. Change these whenever the leading theme rotates.
[*]Earnings override (default Auto): forces condition 5 to pass or fail.
[*]HY OAS max (default 10 percent): credit-spread ceiling for the credit fail-safe.
[*]CPI YoY max (default 2.5 percent): inflation ceiling for the CPI fail-safe.
[*]Credit fail-safe gates signal (default on): when on, an elevated credit spread vetoes the composite signal.
[*]CPI fail-safe gates signal (default off): when on, elevated inflation vetoes the composite signal; when off it displays as a warning only.

█ WHAT MAKES IT ORIGINAL

The script consolidates a cross-asset macro checklist into a single gated, auditable pane: an equity volatility index, the policy rate, the Treasury 2-year, a quarterly flow-of-funds leverage series, sector ETF relative strength, per-symbol earnings surprise data, a credit spread, and a computed inflation rate. Each series exists elsewhere in isolation; the contribution here is the joint evaluation with explicit pass/fail logic, the separation of hard vetoes from soft warnings through the gate toggles, and two implementation choices that make the framework computable on TradingView at all: the Z.1 quarterly margin-account series as a proxy for the unavailable monthly FINRA margin debt statistic, and the earnings-beat condition built from the earnings request feed on user-configurable bellwethers, with missing data treated as neutral rather than as a veto.

█ NOTES / LIMITATIONS

[*]Designed for the daily timeframe on a broad US index. Other resolutions misalign the lookbacks and the higher-timeframe requests; other symbol classes add no information because every condition is market-wide.
[*]The margin-debt proxy is quarterly. Monthly FINRA data can show a deleveraging turn up to one quarter before the Z.1 series reflects it, so condition 3 is the slowest leg and produces a step-shaped response.
[*]Monthly and quarterly requests update when those periods complete. Within a forming month or quarter the CPI and margin readings can change until the period closes.
[*]Earnings history depth varies by symbol and generally thins in earlier years. On older bars condition 5 frequently passes neutrally for lack of data, and the override and bellwether inputs are static across the whole chart, so the plotted historical count is indicative rather than point-in-time. Treat the history as illustration, not as a backtest.
[*]Economic series have distinct start dates, and all external requests ignore invalid symbols. Missing data renders as n/a in the table, fail-safes pass when their series is absent, and a sector whose ticker fails to resolve is silently skipped in the relative-strength scan.
[*]The checklist table reflects the last bar only.
[*]The Fed condition is a proxy for a qualitative judgment. During fast easing cycles the fixed lookback can briefly misread the trajectory, which is what the override input is for.

---

## Source Code

````pine
//@version=6
// Macro regime buy-timing dashboard
// Five conditions: VIX >30, Fed not hiking, margin debt declining (Z.1 quarterly proxy),
// leading sector present, leading-theme bellwethers beating estimates.
// Fail-safes: HY credit spread below threshold, CPI YoY below threshold.
// Apply to SPX/SPY on a daily chart.
indicator("Macro Regime Dashboard", overlay = false, dynamic_requests = true)

// ---------------- Inputs ----------------
vixThresh      = input.float(30.0, "VIX threshold", group = "Condition 1: Fear")
fedLookback    = input.int(63, "Fed rate lookback (trading days)", group = "Condition 2: Fed")
fedOverride    = input.string("Auto", "Fed trajectory override", options = ["Auto", "Force pass", "Force fail"], group = "Condition 2: Fed")
rsLookback     = input.int(63, "Sector RS lookback (days)", group = "Condition 4: Leadership")
rsThresh       = input.float(3.0, "RS outperformance vs SPY (%)", group = "Condition 4: Leadership")
bell1          = input.symbol("NASDAQ:NVDA", "Bellwether 1", group = "Condition 5: Earnings")
bell2          = input.symbol("NASDAQ:AVGO", "Bellwether 2", group = "Condition 5: Earnings")
bell3          = input.symbol("NYSE:TSM",    "Bellwether 3", group = "Condition 5: Earnings")
epsOverride    = input.string("Auto", "Earnings override", options = ["Auto", "Force pass", "Force fail"], group = "Condition 5: Earnings")
hySpreadMax    = input.float(10.0, "HY OAS max (%)", group = "Fail-safes")
cpiMax         = input.float(2.5, "CPI YoY max (%)", group = "Fail-safes")
gateCredit     = input.bool(true,  "Credit fail-safe gates signal", group = "Fail-safes")
gateCPI        = input.bool(false, "CPI fail-safe gates signal (default: warning only)", group = "Fail-safes")
bsLookback     = input.int(12, "Balance sheet lookback (weeks)", group = "Quadrant")

// ---------------- Data ----------------
vix       = request.security("CBOE:VIX", "D", close, ignore_invalid_symbol = true)
dff       = request.security("FRED:DFF", "D", close, ignore_invalid_symbol = true)
us02y     = request.security("TVC:US02Y", "D", close, ignore_invalid_symbol = true)
hySpread  = request.security("FRED:BAMLH0A0HYM2", "D", close, ignore_invalid_symbol = true)
cpiYoY    = request.security("FRED:CPIAUCSL", "1M", (close / close[12] - 1) * 100, ignore_invalid_symbol = true)
// Z.1 broker/dealer margin accounts, quarterly. Proxy for FINRA monthly margin debt.
[mdNow, mdPrev] = request.security("FRED:BOGZ1FL663067003Q", "3M", [close, close[1]], ignore_invalid_symbol = true)
// Fed balance sheet, weekly. Direction over lookback sets the quadrant's second axis.
[bsNow, bsThen] = request.security("FRED:WALCL", "W", [close, close[bsLookback]], ignore_invalid_symbol = true)

// ---------------- Condition 1: VIX ----------------
c1 = vix > vixThresh

// ---------------- Condition 2: Fed not on upward trajectory ----------------
fedAuto     = not na(dff) and not na(dff[fedLookback]) and dff <= dff[fedLookback] + 0.01
cutsPriced  = not na(us02y) and not na(dff) and us02y < dff
c2 = fedOverride == "Force pass" ? true : fedOverride == "Force fail" ? false : fedAuto

// ---------------- Condition 3: Margin debt declining (QoQ proxy) ----------------
c3 = not na(mdNow) and not na(mdPrev) and mdNow < mdPrev

// ---------------- Condition 4: Leading sector via relative strength ----------------
sectorTickers = array.from("AMEX:XLK", "AMEX:XLF", "AMEX:XLE", "AMEX:XLV", "AMEX:XLY", "AMEX:XLP", "AMEX:XLI", "AMEX:XLU", "AMEX:XLB", "AMEX:XLRE", "AMEX:XLC", "NASDAQ:SMH")
sectorNames   = array.from("Tech", "Financials", "Energy", "Health", "Cons Disc", "Staples", "Industrials", "Utilities", "Materials", "Real Estate", "Comms", "Semis")
spyC   = request.security("AMEX:SPY", "D", close)
spyRet = not na(spyC[rsLookback]) ? spyC / spyC[rsLookback] - 1 : na

var float bestRS = na
var string bestName = ""
bestRS := na
bestName := ""
for i = 0 to array.size(sectorTickers) - 1
    sC = request.security(array.get(sectorTickers, i), "D", close, ignore_invalid_symbol = true)
    sRet = not na(sC[rsLookback]) ? sC / sC[rsLookback] - 1 : na
    rs = (sRet - spyRet) * 100
    if not na(rs) and (na(bestRS) or rs > bestRS)
        bestRS := rs
        bestName := array.get(sectorNames, i)
c4 = not na(bestRS) and bestRS > rsThresh

// ---------------- Condition 5: Bellwether earnings beats ----------------
beat(sym) =>
    act = request.earnings(sym, earnings.actual, ignore_invalid_symbol = true)
    est = request.earnings(sym, earnings.estimate, ignore_invalid_symbol = true)
    na(act) or na(est) ? na : act >= est ? 1 : 0
b1 = beat(bell1)
b2 = beat(bell2)
b3 = beat(bell3)
beats = nz(b1) + nz(b2) + nz(b3)
avail = (na(b1) ? 0 : 1) + (na(b2) ? 0 : 1) + (na(b3) ? 0 : 1)
epsAuto = avail == 0 or beats * 2 > avail  // majority of available bellwethers beat; no data = neutral pass
c5 = epsOverride == "Force pass" ? true : epsOverride == "Force fail" ? false : epsAuto

// ---------------- Fail-safes ----------------
fsCredit = na(hySpread) or hySpread < hySpreadMax
fsCPI    = na(cpiYoY) or cpiYoY < cpiMax

// ---------------- Composite ----------------
allFive  = c1 and c2 and c3 and c4 and c5
buySignal = allFive and (not gateCredit or fsCredit) and (not gateCPI or fsCPI)

// ---------------- Quadrant ----------------
bsRising = not na(bsNow) and not na(bsThen) and bsNow > bsThen
bsKnown  = not na(bsNow) and not na(bsThen)
quadrant = not bsKnown ? "n/a" : c2 and bsRising ? "Q1 max liquidity" : not c2 and bsRising ? "Q2 rate high, BS rising" : c2 and not bsRising ? "Q3 rate falling, BS falling" : "Q4 min liquidity"
bsChg = bsKnown ? (bsNow / bsThen - 1) * 100 : na

// ---------------- Dashboard ----------------
green = color.new(color.green, 70)
red   = color.new(color.red, 70)
gray  = color.new(color.gray, 70)

cellBg(bool cond) => cond ? green : red

var table t = table.new(position.top_right, 3, 10, border_width = 1)
txt = chart.fg_color
if barstate.islast
    table.cell(t, 0, 0, "Condition", text_color = color.white, bgcolor = color.new(color.black, 30))
    table.cell(t, 1, 0, "Value", text_color = color.white, bgcolor = color.new(color.black, 30))
    table.cell(t, 2, 0, "Pass", text_color = color.white, bgcolor = color.new(color.black, 30))

    table.cell(t, 0, 1, "1. VIX > " + str.tostring(vixThresh, "#.#"), text_color = txt)
    table.cell(t, 1, 1, str.tostring(vix, "#.##"), text_color = txt)
    table.cell(t, 2, 1, c1 ? "YES" : "no", text_color = txt, bgcolor = cellBg(c1))

    fedTxt = str.tostring(dff, "#.##") + "%" + (cutsPriced ? " (cuts priced)" : "")
    table.cell(t, 0, 2, "2. Fed not hiking", text_color = txt)
    table.cell(t, 1, 2, fedTxt, text_color = txt)
    table.cell(t, 2, 2, c2 ? "YES" : "no", text_color = txt, bgcolor = cellBg(c2))

    mdChg = not na(mdNow) and not na(mdPrev) ? (mdNow / mdPrev - 1) * 100 : na
    table.cell(t, 0, 3, "3. Margin debt falling (Z.1 QoQ)", text_color = txt)
    table.cell(t, 1, 3, na(mdChg) ? "n/a" : str.tostring(mdChg, "#.##") + "%", text_color = txt)
    table.cell(t, 2, 3, c3 ? "YES" : "no", text_color = txt, bgcolor = cellBg(c3))

    table.cell(t, 0, 4, "4. Leading sector (RS > " + str.tostring(rsThresh, "#.#") + "%)", text_color = txt)
    table.cell(t, 1, 4, bestName + " " + str.tostring(bestRS, "#.##") + "%", text_color = txt)
    table.cell(t, 2, 4, c4 ? "YES" : "no", text_color = txt, bgcolor = cellBg(c4))

    table.cell(t, 0, 5, "5. Bellwether EPS beats", text_color = txt)
    table.cell(t, 1, 5, str.tostring(beats) + "/" + str.tostring(avail), text_color = txt)
    table.cell(t, 2, 5, c5 ? "YES" : "no", text_color = txt, bgcolor = cellBg(c5))

    table.cell(t, 0, 6, "FS: HY OAS < " + str.tostring(hySpreadMax, "#.#") + "%", text_color = txt)
    table.cell(t, 1, 6, na(hySpread) ? "n/a" : str.tostring(hySpread, "#.##") + "%", text_color = txt)
    table.cell(t, 2, 6, fsCredit ? "OK" : "RISK", text_color = txt, bgcolor = fsCredit ? green : red)

    table.cell(t, 0, 7, "FS: CPI YoY < " + str.tostring(cpiMax, "#.#") + "%", text_color = txt)
    table.cell(t, 1, 7, na(cpiYoY) ? "n/a" : str.tostring(cpiYoY, "#.##") + "%", text_color = txt)
    table.cell(t, 2, 7, fsCPI ? "OK" : "RISK", text_color = txt, bgcolor = fsCPI ? green : red)

    table.cell(t, 0, 8, "QUADRANT (screener preset)", text_color = txt)
    table.cell(t, 1, 8, na(bsChg) ? "WALCL n/a" : "WALCL " + (bsChg >= 0 ? "+" : "") + str.tostring(bsChg, "#.#") + "% / " + str.tostring(bsLookback) + "w", text_color = txt)
    table.cell(t, 2, 8, quadrant, text_color = txt, bgcolor = quadrant == "Q1 max liquidity" ? green : quadrant == "Q4 min liquidity" ? red : gray)

    table.cell(t, 0, 9, "COMPOSITE", text_color = color.white, bgcolor = color.new(color.black, 30))
    table.cell(t, 1, 9, buySignal ? "ALL CLEAR" : allFive ? "5/5 but fail-safe risk" : str.tostring((c1?1:0)+(c2?1:0)+(c3?1:0)+(c4?1:0)+(c5?1:0)) + "/5", text_color = color.white, bgcolor = color.new(color.black, 30))
    table.cell(t, 2, 9, buySignal ? "BUY" : "wait", text_color = txt, bgcolor = buySignal ? color.new(color.green, 40) : gray)

// Plot condition count for history/backtest reference
condCount = (c1?1:0)+(c2?1:0)+(c3?1:0)+(c4?1:0)+(c5?1:0)
plot(condCount, "Conditions met", color = buySignal ? color.green : color.gray, style = plot.style_stepline, linewidth = 2)
hline(5, "All five", color = color.green, linestyle = hline.style_dotted)
bgcolor(buySignal ? color.new(color.green, 55) : na)
plotshape(buySignal and not buySignal[1], "Signal start", style = shape.triangleup, location = location.bottom, color = color.green, size = size.small)

// ---------------- Alerts ----------------
alertcondition(buySignal and not buySignal[1], "Regime buy signal", "All five conditions met, fail-safes clear")
alertcondition(not fsCredit and fsCredit[1], "Credit spread warning", "HY OAS crossed above threshold")
````
