# TASC 2026.07 Risk-On, Risk-Off, Or Caution

- url: https://www.tradingview.com/script/wu1VhNpf-TASC-2026-07-Risk-On-Risk-Off-Or-Caution/
- type: strategy
- pine_id: PUB;93155e1fab544f5f8630917203f8d8b5
- version: 1.0

## Description

[b]█ OVERVIEW[/b]

This strategy implements the portfolio allocation strategy presented by Gaetano Di Prima & Fabio Baruffa in the [url=https://traders.com/Documentation/FEEDbk_docs/2026/07/TradersTips.html]July 2026 edition of the TASC Traders' Tips[/url] "Market Regime Identification Using Trend, Volatility, And Credit Conditions". The article describes a regime-based allocation strategy, which uses a combination of trend, volatility, and credit spread measures to indicate three regime states and adjust exposure accordingly.

[b]█ COMPONENTS[/b]

The regime classification combines three components:
[list=1]
[*]Trend Filter: The system uses a 200-day Simple Moving Average (SMA) of SPX. A popular long-term trend filter, this is not intended to detect tops and bottoms, and simply serves as a baseline condition for taking on risk. When SPX is above its 200 SMA, conditions are seen as favorable.
[*]Volatility Filter: The system measures market stress by comparing the short-term CBOE Volatility Index (VIX) to its longer term three-month counterpart (VIX3M). During market stress, short-term volatility typically rises sharply, which is associated with uncertainty and higher short-term risk. For this reason, the system checks for VIX to be less-than VIX3M under favorable conditions.
[*]Risk Appetite: Credit markets can provide insight into the willingness of investors to take on risk. By computing a ratio between High Yield Corporate Bonds (HYG) and 7–10 Year Treasury bonds (IEF), the specific appetite of investors can be determined. When the 100MA of the rolling Z-score for the HYG/IEF spread is positive, conditions are considered favorable.
[/list]

[b]█ THE RULES[/b]

The rules are simple. At the end of every week, the script assesses the conditions and adjusts the position accordingly. 

The strategy places an order to be executed at Monday's open with the changes to the position, if any.
[list=1]
[*] If all conditions are favorable, modify the position to have full exposure.
[*] If 2/3 conditions are favorable, modify the position to only have 50% exposure.
[*] If 1/3 or 0/3 conditions are favorable, modify the position to have no exposure.
[/list]
[b]▌Properties[/b]
[list]
[*][b]Position Sizing[/b]: This strategy manages and allocates up to 100% of equity, the same as in the article.
[*][b]Commissions[/b]: Commission value is set to $0. Most major US brokers charge $0 commission on stocks and ETF trades.
[*][b]Slippage[/b]: Slippage is set to three ticks to simulate less-than-ideal execution conditions.
[/list]
[b]█ DISPLAY[/b]

[image]https://www.tradingview.com/x/JxpXq7yb/[/image]
The display shows blue bars in a separate pane, indicating the specific conditions and their Boolean values at the time. Together, these values determine the specific "regime" state that the system is in.
The script colors the background of the chart pane to indicate the current regime. Red indicates "Risk OFF", yellow indicates "Caution", and green indicates "Risk ON". A table in the separate pane provides a key for the colors as well.

## Source Code

````pine
//  TASC Issue: July 2026
//     Article: Risk-On, Risk-Off, Or Caution
//              Market Regime Identification
//              Using Trend, Volatility, And
//              Credit Conditions
//  Article By: Gaetano Di Prima and Fabio Baruffa
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com

//@version=6

TITLE = "TASC 2026.07 Risk-On, Risk-Off, Or Caution"
SHORTTITLE = "Regime Positioning"

strategy(
    TITLE, 
    SHORTTITLE, 
    slippage = 3, 
    initial_capital = 10000)

// Raise an error if the script is not running on 
// a daily SPY chart. 
if syminfo.ticker != "SPY" or timeframe.period != "1D"
    runtime.error(
        "This strategy requires a daily SPY chart."
    )


//#region --- Data requests ---

float vix   = request.security("VIX",   "", close)
float vix3m = request.security("VIX3M", "", close)
float spx   = request.security("SPX",   "", close)
float hyg   = request.security("HYG",   "", close)
float ief   = request.security("IEF",   "", close)
//#endregion


//#region --- Regime signals ---

// @variable Difference between SPX value & its 200-bar SMA.
float spxDist = spx - ta.sma(spx, 200)

// @variable The ratio of the VIX value to the VIX3M value.
float ts = vix / vix3m

// @variable The ratio of the HYG value to the IEF value.
float creditRatio = hyg / ief
// @variable The 100-bar z-score of the `creditRatio` value.
float creditZscore = (
    (creditRatio - ta.sma(creditRatio, 100))
    / ta.stdev(creditRatio, 100)
) 

// @variable `true` if SPX is above the SMA, uptrend.
bool s1 = spxDist > 0.0
// @variable `true` if VIX is below VIX3M, "stable" risk.
bool s2 = ts < 1.0
// @variable `true` if `creditZscore` value is above -2.
bool s3 = creditZscore > -2.0

// @variable Regime signal: "Risk ON","Caution","Risk OFF"
int regime = (s1 ? 1 : 0) + (s2 ? 1 : 0) + (s3 ? 1 : 0)

// @variable The background color for regime signal states.
color rColor = switch regime
    3 => #4caf5033
    2 => #ffeb3b33
    =>   #ff525233
//#endregion


//#region --- Order logic ---

// This strategy places orders to adjust the 
// current position only at the close of each week. 

// @variable `true` if the bar is the last of the week.
bool isEow = time_close == time_close("W")

if isEow and barstate.isconfirmed
    // @variable The target position size for reallocation.
    float targetPosition = switch regime
        3 => strategy.equity        // 100% for "Risk ON"
        2 => 0.5 * strategy.equity  // 50% for "Caution"     
        =>   0.0                    // 0% for "Risk OFF"

    // @variable The shares to add to or remove.
    float diff = math.floor(
        targetPosition / close - strategy.position_size
    )
    // Modify the position if `diff` is nonzero.
    switch
        diff > 0 => 
            strategy.order("Buy", strategy.long, diff)
        diff < 0 => 
            strategy.close("Buy", "Sell", -diff)
//#endregion


//#region --- Display ---

// Legend display
if barstate.isfirst
    table tbl = table.new(position.bottom_center, 1, 3)
    tbl.cell(
        row = 0, 
        column = 0, 
        text = "🟩 Risk ON\n🟥 Risk OFF\n🟨 Caution", 
        text_color = #ffffff, 
        text_halign = text.align_left, 
        bgcolor = #363a4580
    )

// Chart background highlight
bgcolor(
    rColor, 
    title = "Regime highlight", 
    force_overlay = true
)

// Signal plots
plot(
    s1 ? 1 : na, 
    title = "Trend signal", 
    color = #00a2ff, 
    style = plot.style_columns
)

plot(
    s2 ? 2 : na, 
    title = "Volatility signal", 
    color = #015f96,
    style = plot.style_columns, 
    histbase = 1.1
)

plot(
    s3 ? 3 : na, 
    title = "Credit signal", 
    color = #00314d,
    style = plot.style_columns, 
    histbase = 2.1
)
//#endregion
````
