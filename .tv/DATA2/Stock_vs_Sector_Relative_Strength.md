<!-- tradingview-pine-id: PUB;2c8dc2cb1d1d46c48991031066b7386a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stock vs. Sector Relative Strength

Source: https://www.tradingview.com/script/0UYXC6AX/

## Description

**Stock vs. Sector Relative Strength**

**What it does**
Plots how the stock on the chart has performed relative to *its own sector ETF* over a lookback window (default 20 bars), and how unusual that relative performance is compared to the stock's own recent history (z-score over 60 bars). The sector ETF is detected automatically from TradingView's sector classification and mapped to the matching SPDR sector fund (XLK, XLF, XLV, …). If the sector is unknown — non-US listings, ETFs, crypto — the script falls back to a benchmark you choose (default SPY). You can also set the benchmark manually.

**What you see**
- Z-score line with ±1 bands (default view), or the raw relative return in % as columns.
- Background shading when the z-score is beyond the band: teal = outperforming the sector by more than usual, red = underperforming.
- A small table with the detected sector, the benchmark actually used, the relative return, the z-score and the current state.
- Alerts on state changes: relative return crossing zero, z-score entering the upper or lower band.

**How it works**
`relative return = (close / close[n] − 1) − (benchmark / benchmark[n] − 1)`. The z-score is the relative return minus its 60-bar mean, divided by its 60-bar standard deviation. The benchmark is requested on the chart's timeframe without lookahead, so the value on any bar only uses that bar's closes.

**Why it is different from existing sector-strength scripts**
Most published sector tools compare a *sector ETF against SPY*. This one compares the *stock against its sector*, which answers a different question: is this stock doing better than the peers it is normally traded with?

**Why I built it — the measurement behind it**
This is a state, not a signal. The reason it exists is a filter test. I took 47,013 daily bullish moving-average crossover events (EMA 9 crossing above DEMA 200) on 1,758 US stocks from 2014 to 2026, including names that were later delisted, and asked which conditions at the crossover bar separated better outcomes from worse ones. For the 18,280 events where a sector ETF could be assigned:

| Condition at the crossover bar | Share of events kept | Share positive after 20 bars | after 60 bars |
|---|---:|---:|---:|
| all events with a sector ETF | 100 % | 56.9 % | 59.7 % |
| relative return vs. sector > 0 | 28 % | 57.5 % (vs. 53.7 % for the rest) | 60.2 % (vs. 56.2 %) |
| z-score vs. sector > +1 | 17 % | 57.3 % (vs. 54.2 %) | 59.8 % (vs. 56.8 %) |

Both versions held in the second half of the sample (from September 2020) and were the only conditions in that test that improved *every* measure I looked at, including the outcome of the trades themselves under a trailing exit (+3.2 percentage points). Comparing against SPY instead of the sector gave almost the same 20-bar effect but nothing at 60 bars — the sector benchmark is where the longer-horizon difference comes from.

**Limitations — please read**
- The measurement is conditional: it says that crossovers with positive relative strength were followed by positive returns more often than crossovers without it. It is not a strategy return and says nothing about future performance.
- The sector-mapped subset consisted of today's ~1,000 largest US stocks, so it carries survivorship bias. The comparison *within* that subset (kept vs. removed) is what the numbers above show; the absolute levels are flattered.
- TradingView's sector taxonomy is not GICS. The mapping to SPDR ETFs is approximate (retail, media and REITs are the usual edge cases). Check the table and switch to a manual benchmark if it looks wrong.
- Tested on daily bars only. On intraday timeframes the lookback of 20 bars means something else.
- `syminfo.sector` is only populated for stocks. Everything else uses the fallback benchmark.

No buy or sell signals are generated, and none are implied.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gregorfun

//@version=6
indicator("Stock vs. Sector Relative Strength", "Stock/Sector RS", overlay = false, dynamic_requests = true)
plot(close)
// ── Inputs ────────────────────────────────────────────────────────────────────
lookback    = input.int(20, "Relative-return lookback (bars)", minval = 2)
zWindow     = input.int(60, "Z-score window (bars)", minval = 10)
zBand       = input.float(1.0, "Z-score band", minval = 0.1, step = 0.1)
benchMode   = input.string("Auto (sector ETF)", "Benchmark", options = ["Auto (sector ETF)", "Manual"])
benchManual = input.symbol("AMEX:SPY", "Manual benchmark")
benchFallback = input.symbol("AMEX:SPY", "Fallback when sector is unknown")
display     = input.string("Z-score", "Display", options = ["Z-score", "Relative return %"])
showTable   = input.bool(true, "Show info table")

// ── Sector → SPDR ETF ─────────────────────────────────────────────────────────
// TradingView's sector taxonomy (20 sectors) folded into the 11 SPDR sector ETFs.
// Approximate by design: TradingView does not use GICS. Override via "Manual" if the
// mapping is wrong for a specific name (e.g. food retailers land in XLY, not XLP).
sectorEtf(string sector, string industry) =>
    string etf = switch sector
        "Technology Services"    => "AMEX:XLK"
        "Electronic Technology"  => "AMEX:XLK"
        "Finance"                => "AMEX:XLF"
        "Health Technology"      => "AMEX:XLV"
        "Health Services"        => "AMEX:XLV"
        "Consumer Non-Durables"  => "AMEX:XLP"
        "Consumer Durables"      => "AMEX:XLY"
        "Consumer Services"      => "AMEX:XLY"
        "Retail Trade"           => "AMEX:XLY"
        "Producer Manufacturing" => "AMEX:XLI"
        "Industrial Services"    => "AMEX:XLI"
        "Transportation"         => "AMEX:XLI"
        "Commercial Services"    => "AMEX:XLI"
        "Distribution Services"  => "AMEX:XLI"
        "Communications"         => "AMEX:XLC"
        "Energy Minerals"        => "AMEX:XLE"
        "Non-Energy Minerals"    => "AMEX:XLB"
        "Process Industries"     => "AMEX:XLB"
        "Utilities"              => "AMEX:XLU"
        => ""
    // REITs sit under "Finance" in TradingView's taxonomy.
    if sector == "Finance" and str.contains(industry, "Real Estate")
        etf := "AMEX:XLRE"
    etf

string autoEtf  = sectorEtf(syminfo.sector, syminfo.industry)
bool   autoOk   = benchMode == "Auto (sector ETF)" and str.length(autoEtf) > 0
string benchSym = benchMode == "Manual" ? benchManual : autoOk ? autoEtf : benchFallback

// Same timeframe as the chart, no lookahead: the benchmark bar is the one that closed
// together with the chart bar.
float benchClose = request.security(benchSym, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// ── Relative strength ─────────────────────────────────────────────────────────
float stockRet = close / close[lookback] - 1
float benchRet = benchClose / benchClose[lookback] - 1
float rel      = stockRet - benchRet                       // relative return over the lookback
float relMean  = ta.sma(rel, zWindow)
float relSd    = ta.stdev(rel, zWindow)
float z        = relSd > 0 ? (rel - relMean) / relSd : na  // how unusual today's relative return is
int   state    = na(z) ? 0 : z > zBand ? 1 : z < -zBand ? -1 : 0

// ── Plots ─────────────────────────────────────────────────────────────────────
bool  showZ    = display == "Z-score"
color upCol    = color.new(color.teal, 0)
color downCol  = color.new(color.red, 0)

plot(showZ ? z : na, "Z-score", color = z >= 0 ? upCol : downCol, linewidth = 2)
plot(showZ ? na : rel * 100, "Relative return %", style = plot.style_columns, color = rel >= 0 ? upCol : downCol)
plot(showZ ? zBand : na, "Upper band", color = color.new(color.gray, 50), style = plot.style_line)
plot(showZ ? -zBand : na, "Lower band", color = color.new(color.gray, 50), style = plot.style_line)
hline(0, "Zero", color = color.gray)
bgcolor(state == 1 ? color.new(color.teal, 88) : state == -1 ? color.new(color.red, 88) : na)

// ── Info table ────────────────────────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 5, border_width = 1)
if showTable and barstate.islast
    color bg = color.new(color.gray, 70)
    table.cell(info, 0, 0, "Sector",    text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 0, str.length(syminfo.sector) > 0 ? syminfo.sector : "n/a", text_color = color.white, bgcolor = bg)
    table.cell(info, 0, 1, "Benchmark", text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 1, benchSym + (benchMode == "Auto (sector ETF)" and not autoOk ? " (fallback)" : ""), text_color = color.white, bgcolor = bg)
    table.cell(info, 0, 2, "Rel. return " + str.tostring(lookback) + " bars", text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 2, str.tostring(rel * 100, "#.##") + " %", text_color = rel >= 0 ? color.teal : color.red, bgcolor = bg)
    table.cell(info, 0, 3, "Z-score",   text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 3, str.tostring(z, "#.##"), text_color = color.white, bgcolor = bg)
    table.cell(info, 0, 4, "State",     text_color = color.white, bgcolor = bg)
    table.cell(info, 1, 4, state == 1 ? "outperforming" : state == -1 ? "underperforming" : "in line", text_color = state == 1 ? color.teal : state == -1 ? color.red : color.white, bgcolor = bg)

// ── Alerts (state changes, not trade signals) ─────────────────────────────────
alertcondition(ta.crossover(rel, 0),     "Relative return turns positive", "{{ticker}}: relative return vs. benchmark turned positive")
alertcondition(ta.crossunder(rel, 0),    "Relative return turns negative", "{{ticker}}: relative return vs. benchmark turned negative")
alertcondition(ta.crossover(z, zBand),   "Z-score enters upper band",      "{{ticker}}: relative strength z-score above upper band")
alertcondition(ta.crossunder(z, -zBand), "Z-score enters lower band",      "{{ticker}}: relative strength z-score below lower band")
````
