# COT Index

- url: https://www.tradingview.com/script/re4shOJN-COT-Index/
- type: indicator
- pine_id: PUB;c8953529019e442d9a95c21fb37cebf0
- version: 1.0

## Description

COT Index — Managed Money / Large Spec / Commercials                                                                                                                                                                                     
                                                         
  Short tagline:                                                                                                                                                                                                                           
  Three-line COT Index (0–100) for futures: Large Spec, Managed Money, Commercials. Min-max normalized over a configurable rolling weekly window.
                                                                                                                                                                                                                                           
  ---
  Description:                                                                                                                                                                                                                             
                                                         
  The COT Index plots three trader-group positioning gauges on a single 0–100 scale, derived directly from the CFTC's weekly Commitments of Traders reports. Useful for spotting positioning extremes, divergences between speculator and
  commercial flow, and contrarian setups.                                                                                                                                                                                                  
   
  # What it shows                                                                                                                                                                                                                          
                                                         
  Three colored lines:                                                                                                                                                                                                                     
  - 🔵 **Large Speculator** — Managed Money + Other Reportable (combined non-commercial positioning)
  - 🟣 **Managed Money** — Managed Money only (Disaggregated) or Leveraged Funds (Financial / TFF)                                                                                                                                         
  - 🟠 **Commercials** — Producer/Merchant (Disaggregated) or Dealer/Intermediary (Financial)                                                                                                                                              
                                                                                                                                                                                                                                           
  Plus reference levels:                                                                                                                                                                                                                   
  - Dashed red at **90** — extreme long                                                                                                                                                                                                    
  - Dashed green at **10** — extreme short                                                                                                                                                                                                 
  - Dotted gray at **50** — mid
                                                                                                                                                                                                                                           
  # Formula                                              
                                                                                                                                                                                                                                           
  For each group, the indicator computes net positioning (Long − Short), then min-max normalizes over a rolling N-week window:                                                                                                             
   
  COT Index = (currentNet − min(net, N)) / (max(net, N) − min(net, N)) × 100                                                                                                                                                               
                                                         
  Default N = 156 weeks (3 years). Other common values: 13 (3M), 26 (6M), 52 (1Y).                                                                                                                                                         
                                                                                                                                                                                                                                           
  # Auto contract resolution                                                                                                                                                                                                               
                                                                                                                                                                                                                                           
  Apply to any of the supported futures contracts and the indicator auto-resolves the CFTC code from the chart symbol. No manual configuration needed.                                                                                     
                                                         
  | Asset | Symbol | Report |                                                                                                                                                                                                              
  |---|---|---|                                          
  | Gold | COMEX:GC1! | Disaggregated |                                                                                                                                                                                                    
  | Silver | COMEX:SI1! | Disaggregated |                                                                                                                                                                                                  
  | Copper | COMEX:HG1! | Disaggregated |
  | Platinum | NYMEX:PL1! | Disaggregated |                                                                                                                                                                                                
  | Palladium | NYMEX:PA1! | Disaggregated |             
  | WTI Crude Oil | NYMEX:CL1! | Disaggregated |                                                                                                                                                                                           
  | Brent Crude Oil | NYMEX:BZ1! / ICEEUR:BRN1! | Disaggregated |
  | Natural Gas | NYMEX:NG1! | Disaggregated |                                                                                                                                                                                             
  | RBOB Gasoline | NYMEX:RB1! | Disaggregated |                                                                                                                                                                                           
  | Heating Oil | NYMEX:HO1! | Disaggregated |                                                                                                                                                                                             
  | Euro FX | CME:6E1! | Financial (TFF) |                                                                                                                                                                                                 
  | British Pound | CME:6B1! | Financial (TFF) |                                                                                                                                                                                           
  | Swiss Franc | CME:6S1! | Financial (TFF) |                                                                                                                                                                                             
  | Canadian Dollar | CME:6C1! | Financial (TFF) |                                                                                                                                                                                         
  | Japanese Yen | CME:6J1! | Financial (TFF) |          
  | Australian Dollar | CME:6A1! | Financial (TFF) |                                                                                                                                                                                       
  | New Zealand Dollar | CME:6N1! | Financial (TFF) |                                                                                                                                                                                      
  | Mexican Peso | CME:6M1! | Financial (TFF) |                                                                                                                                                                                            
                                                                                                                                                                                                                                           
  Apply to a non-mapped symbol (e.g. a stock) and the indicator returns a clear runtime error.                                                                                                                                             
                                                                                                                                                                                                                                           
  # Inputs                                                                                                                                                                                                                                 
                                                         
  - **Lookback (weeks)** — rolling window (4–520, default 156)                                                                                                                                                                             
  - **Show Large Speculator / Managed Money / Commercials** — toggle each line independently
  - **Extreme long / short thresholds** — adjust the dashed reference lines                                                                                                                                                                
                                                                                                                                                                                                                                           
  # How to read it                                                                                                                                                                                                                         
                                                                                                                                                                                                                                           
  - **Large Spec / Managed Money near 90+** → speculators are very long, often a contrarian sell signal                                                                                                                                    
  - **Large Spec / Managed Money near 10−** → speculators are very short, often a contrarian buy signal
  - **Commercials are the inverse** of speculators by definition (they take the other side of the trade) — Commercials at 1 typically pairs with Specs near 100                                                                            
  - **Watch divergences** between price and the indicator — speculative positioning peaking while price still rises is a classic distribution warning                                                                                      
                                                                                                                                                                                                                                           
  # Notes                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                           
  - Uses TradingView's official `LibraryCOT` (by TradingView) for ticker construction.                                                                                                                                                     
  - Forces weekly resolution regardless of chart timeframe — values only update on Tuesday COT release days.
  - `lookahead = barmerge.lookahead_off` — no future data leak; backtesting is honest.                                                                                                                                                     
  - Auto-detect requires applying to the **futures** symbol (e.g. `6E1!`), not the spot pair (`EURUSD`). Spot FX charts are not supported.                                                                                                 
  - Data comes from the Disaggregated report for metals/energy and the Traders in Financial Futures (TFF) report for FX. Both are futures-only (`includeOptions=false`).                                                                   
                                                                                                                                                                                                                                           
  # Credits                                                                                                                                                                                                                                
                                                                                                                                                                                                                                           
  Data fetching: [LibraryCOT by TradingView](https://www.tradingview.com/script/ysFf2OTq-LibraryCOT/).                                                                                                                                     
   
  Open-source — feel free to fork and adapt.                                                                                                                                                                                               
                                                         
  ---

## Source Code

````pine
//@version=6
// COT Index — replicates the formula used by the COT positioning dashboard
//   (Current Net − Min) / (Max − Min) × 100, min/max over a rolling weekly window.
// Plots three trader groups in a single pane: Large Speculator, Managed Money, Commercials.
// Apply to a CFTC-tracked futures chart (COMEX:GC1!, NYMEX:CL1!, CME:6E1!, …); see README for full list.
//
// Uses TradingView's official LibraryCOT (https://www.tradingview.com/script/ysFf2OTq-LibraryCOT/)
// to handle CFTC ticker construction.

import TradingView/LibraryCOT/6 as cot

indicator("COT Index", shorttitle="COTI", overlay=false, precision=0, max_bars_back=520)

// ─── Inputs ───────────────────────────────────────────────────────────────────
n               = input.int(156, "Lookback (weeks)", minval=4, maxval=520,
                              tooltip="Rolling window for min-max normalization. Common: 13 (3M), 26 (6M), 52 (1Y), 156 (3Y).")
showLargeSpec   = input.bool(true,  "Show Large Speculator (MM + Other Rept)", group="Display")
showManaged     = input.bool(true,  "Show Managed Money / Leveraged Funds",     group="Display")
showCommercials = input.bool(true,  "Show Commercials (Producer / Dealer)",     group="Display")
extremeUpper    = input.int(90, "Extreme long threshold",  minval=51, maxval=100, group="Thresholds")
extremeLower    = input.int(10, "Extreme short threshold", minval=0,  maxval=49,  group="Thresholds")

// ─── Symbol → CFTC code + report type ────────────────────────────────────────
// Metals/energy use the Disaggregated report; FX uses the Financial (TFF) report.
[rawCode, rawType] = switch syminfo.root
    "GC"  => ["088691", "Disaggregated"]    // Gold
    "SI"  => ["084691", "Disaggregated"]    // Silver
    "HG"  => ["085692", "Disaggregated"]    // Copper - Grade #1
    "PL"  => ["076651", "Disaggregated"]    // Platinum
    "PA"  => ["075651", "Disaggregated"]    // Palladium
    "CL"  => ["067651", "Disaggregated"]    // WTI Crude Oil (Light Sweet)
    "BZ"  => ["06765B", "Disaggregated"]    // Brent Crude Oil Last Day (NYMEX)
    "BRN" => ["06765B", "Disaggregated"]    // Brent (ICE EUR alt root)
    "NG"  => ["023651", "Disaggregated"]    // Natural Gas
    "RB"  => ["111659", "Disaggregated"]    // RBOB Gasoline
    "HO"  => ["022651", "Disaggregated"]    // #2 Heating Oil NY Harbor
    "6E"  => ["099741", "Financial"]        // Euro FX
    "6B"  => ["096742", "Financial"]        // British Pound
    "6S"  => ["092741", "Financial"]        // Swiss Franc
    "6C"  => ["090741", "Financial"]        // Canadian Dollar
    "6J"  => ["097741", "Financial"]        // Japanese Yen
    "6A"  => ["232741", "Financial"]        // Australian Dollar
    "6N"  => ["112741", "Financial"]        // New Zealand Dollar
    "6M"  => ["095741", "Financial"]        // Mexican Peso
    => ["", ""]

// Fallback to Gold so library calls don't choke on an empty code; runtime.error halts before render.
cftcCode   = rawCode == "" ? "088691"        : rawCode
reportType = rawType == "" ? "Disaggregated" : rawType

// ─── Metric names per report type (LibraryCOT vocabulary) ────────────────────
specMetric = reportType == "Disaggregated" ? "Managed Money Positions"   : "Leveraged Funds Positions"
orMetric   = "Other Reportable Positions"
commMetric = reportType == "Disaggregated" ? "Producer Merchant Positions" : "Dealer Positions"

// ─── Fetch CFTC weekly data via LibraryCOT ──────────────────────────────────
// requestCommitmentOfTraders(COTType, CFTCCode, includeOptions, metricName, metricDirection, metricType)
specLong  = cot.requestCommitmentOfTraders(reportType, cftcCode, false, specMetric, "Long",  "All")
specShort = cot.requestCommitmentOfTraders(reportType, cftcCode, false, specMetric, "Short", "All")
orLong    = cot.requestCommitmentOfTraders(reportType, cftcCode, false, orMetric,   "Long",  "All")
orShort   = cot.requestCommitmentOfTraders(reportType, cftcCode, false, orMetric,   "Short", "All")
commLong  = cot.requestCommitmentOfTraders(reportType, cftcCode, false, commMetric, "Long",  "All")
commShort = cot.requestCommitmentOfTraders(reportType, cftcCode, false, commMetric, "Short", "All")

// Halt with a clear message if the chart's root isn't in the mapping.
if rawCode == ""
    runtime.error("COT Index: symbol root '" + syminfo.root + "' is not mapped. Apply this indicator to a supported futures chart — e.g. COMEX:GC1!, NYMEX:CL1!, CME:6E1!. See README for the full list.")

// ─── Compute net positions ───────────────────────────────────────────────────
specNet      = specLong   - specShort
largeSpecNet = (specLong + orLong) - (specShort + orShort)
commNet      = commLong   - commShort

// ─── Min-max normalization (matches src/lib/analytics.ts cotIndex) ───────────
cotIndex(series float net) =>
    minVal = ta.lowest(net, n)
    maxVal = ta.highest(net, n)
    (maxVal == minVal) ? 50.0 : (net - minVal) / (maxVal - minVal) * 100

mmIdx   = cotIndex(specNet)
lspIdx  = cotIndex(largeSpecNet)
commIdx = cotIndex(commNet)

// ─── Plot ────────────────────────────────────────────────────────────────────
// Colors match dashboard ContractDashboard.tsx: blue=Large Spec, purple=MM, amber=Commercials
plot(showLargeSpec   ? lspIdx  : na, "Large Speculator", color=color.rgb(59, 130, 246),  linewidth=2)
plot(showManaged     ? mmIdx   : na, "Managed Money",    color=color.rgb(168, 85, 247),  linewidth=2)
plot(showCommercials ? commIdx : na, "Commercials",      color=color.rgb(245, 158, 11),  linewidth=2)

hline(extremeUpper, "Extreme Long",  color=color.new(color.red,   60), linestyle=hline.style_dashed)
hline(50,           "Mid",           color=color.new(color.gray,  70), linestyle=hline.style_dotted)
hline(extremeLower, "Extreme Short", color=color.new(color.green, 60), linestyle=hline.style_dashed)
````
