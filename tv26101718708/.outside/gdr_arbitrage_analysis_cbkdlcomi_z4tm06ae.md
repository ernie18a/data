# GDR Arbitrage Analysis (CBKDL/COMI)

- url: https://www.tradingview.com/script/Z4tM06AE-GDR-Arbitrage-Analysis-CBKDL-COMI/
- type: indicator
- pine_id: PUB;9c125a783c8c44bcae12292445cd664d
- version: 1.0

## Description

Evaluating the arbitrage or price discrepancy between local shares and Global Depositary Receipts (GDRs) is a standard practice to gauge market sentiment and currency expectations.

the equation CBKDL * USDEGP - COMI

CBKDL (GDR Price): London Stock Exchange in USD
USDEGP: (Bank rate/Market rate)
GX:COMI: Local EGX price
GDR Ratio 1:1 (1 GDR = 1 Ordinary Share)

If the result is Positive (+): The GDR is trading at a premium.
This often suggests that international investors expect the EGP to devalue further or that there is high demand for the stock that cannot be met locally.

If the result is Negative (-): The local stock is trading at a premium (GDR is at a discount).
This suggests that local buying pressure is currently stronger than international appetite, or that the local market has already "priced in" a higher value than what the global market is currently reflecting.

Market Insight
Historically, a negative spread in this equation (where COMI > CBKDL converted) can happen during periods of local market rallies or when liquidity in London is thin. If you see this negative spread widening significantly, it may suggest that the local price is overextended in the short term, or that the "implied" exchange rate in the stock market is slightly higher than the official rate you are using in your formula.

Sector Context: As the heavy-lifter of the EGX30, COMI’s movement often dictates the direction of the entire index. Tracking this spread is vital for understanding foreign institutional flows, as these investors often arbitrage between the two listings.

🟢 Green Bars: GDR Premium — International investors are paying more via London GDR than the local EGX price implies. Signals foreign institutional bullishness or hedging against EGP devaluation.

🔴 Red Bars: Local Premium — Local EGX price exceeds the GDR-implied fair value. Signals stronger local buying pressure or international outflows from the GDR.

The indicator is flexible: if you want to analyze other Egyptian GDRs (like ETEL, EFID, or others), just change the symbol inputs in the indicator settings without editing code.

## Source Code

````pine
//@version=6
indicator("GDR Arbitrage Analysis (CBKDL/COMI)", shorttitle="GDR Arb", overlay=false, format=format.price, precision=2)

// ==========================================
// 1. INPUTS
// ==========================================
gdrSym   = input.symbol("TURQUOISE:CBKDL", "GDR Symbol (USD)")
fxSym    = input.symbol("FX_IDC:USDEGP", "USD/EGP Rate")
localSym = input.symbol("EGX:COMI", "Local Listing (EGP)")

emaLen   = input.int(14, "Signal Line EMA Length", minval=1)

// ==========================================
// 2. DATA CALCULATION
// ==========================================
// Fetch data for all three legs of the arbitrage
gdrPrice = request.security(gdrSym, timeframe.period, close)
fxRate   = request.security(fxSym, timeframe.period, close)
localPrice = request.security(localSym, timeframe.period, close)

// Arbitrage Formula: GDR_USD * FX_Rate - Local_Price
// Positive = GDR is trading at a premium to local (International Bullish/Devaluation expectations)
// Negative = Local is trading at a premium to GDR (Local Buying Pressure)
spread = (gdrPrice * fxRate) - localPrice
signal = ta.ema(spread, emaLen)

// ==========================================
// 3. VISUALS
// ==========================================
// Color Logic
histColor = spread >= 0 ? color.new(color.green, 50) : color.new(color.red, 50)

// Plotting
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
plot(spread, "Spread Histogram", color=histColor, style=plot.style_histogram, linewidth=2)
plot(signal, "Signal Line (EMA)", color=color.white, linewidth=1)

// ==========================================
// 4. ANNOTATIONS & LABELS
// ==========================================
var table infoTable = table.new(position.top_right, 1, 1, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    string interpretation = spread >= 0 ? 
         "REIGME: GDR PREMIUM\nInternational investors are paying more\nthan local market. Suggests foreign\nbullishness or EGP devaluation hedge." : 
         "REGIME: LOCAL PREMIUM\nLocal EGX price is higher than the\nGDR equivalent. Suggests local buying\npressure or international outflow."
    
    table.cell(infoTable, 0, 0, interpretation, text_color=color.white, text_size=size.small, text_halign=text.align_left)

// ==========================================
// 5. ALERTS
// ==========================================
alertcondition(ta.cross(spread, 0), "Regime Change", "GDR Arbitrage spread crossed the Zero Line")
alertcondition(ta.crossover(spread, 0), "GDR Premium Entry", "GDR has moved to a premium vs Local")
alertcondition(ta.crossunder(spread, 0), "Local Premium Entry", "Local has moved to a premium vs GDR")
````
